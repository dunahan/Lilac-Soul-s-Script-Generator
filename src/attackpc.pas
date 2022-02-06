{
Copyright 2006 Carsten Hjorthøj (Lilac Soul)

The Script Generator is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

The Script Generator is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
{
Modified by: The Krit, March 2011
* Adapted from Delphi to Lazarus/fpc.
* Some of this was trimmed when I converted the form to being modal.
* Enabled the "script owner attacks" option if this form is reloaded -- no
*   reason to disable it if, say, one is dealyed or occurs in a different
*   branch of an if-tree.
* Added choice of who to attack.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit attackpc;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} {Forms,} {Dialogs,}
  StdCtrls, ExtCtrls, start, nwn, Buttons,
  LResources, Spin, QueueForm;

type

  { Tattack }

  Tattack = class(TQueueForm)
    // Form elements
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    LabelAttacked: TLabel;
    LabelAttackerTag: TLabel;
    EditAttackedName: TLabeledEdit;
    Memo1: TMemo;
    panelattacker: TPanel;
    Label1: TLabel;
    PanelAttacked: TPanel;
    RadioActivatorAttacks: TRadioButton;
    RadioOwnerAttacked: TRadioButton;
    RadioPCAttacked: TRadioButton;
    RadioActorAttacks: TRadioButton;
    RadioActorAttacked: TRadioButton;
    RadioTaggedAttacked: TRadioButton;
    RadioSpawnAttacked: TRadioButton;
    RadioActivatorAttacked: TRadioButton;
    RadioTargetedAttacks: TRadioButton;
    RadioTargetedAttacked: TRadioButton;
    RadioSpawnAttacks: TRadioButton;
    EditTaggedAttacks: TEdit;
    PanelReputation: TPanel;
    RadioTaggedAttacks: TRadioButton;
    RadioOwnerAttacks: TRadioButton;
    RadioGroup1: TRadioGroup;
    SpinNthTag: TSpinEdit;
    EditTaggedAttacked: TEdit;
    TextNth: TStaticText;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure RadioOwnerAttackedChange(Sender: TObject);
    procedure RadioActivatorAttackedChange(Sender: TObject);
    procedure RadioTargetedAttackedChange(Sender: TObject);
    procedure RadioSpawnAttackedChange(Sender: TObject);
    procedure RadioActorAttackedChange(Sender: TObject);
    procedure SpinNthTagChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    AttackQueue: array of shortstring;
    ReputeQueue: array of shortstring;

  protected
    procedure ClearForm(); override;
    procedure QueueThis(); override;
    procedure SendQueue(); override;
  end;


implementation

uses
    constants;


// -----------------------------------------------------------------------------

// Sets the visibility of some elements based on the current situation.
procedure Tattack.FormCreate(Sender: TObject);
const
    OBJECT_CREATURE_DOOR_PLACEABLE = OBJECT_TYPE_CREATURE or
                                     OBJECT_TYPE_DOOR     or
                                     OBJECT_TYPE_PLACEABLE;
begin
    // Initializations.
    SetLength(AttackQueue, 0);
    SetLength(ReputeQueue, 0);

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwnerAttacks,  RadioSpawnAttacks,  RadioActorAttacks,  OBJECT_TYPE_CREATURE);
    main.InitRadioWhos(RadioOwnerAttacked, RadioSpawnAttacked, RadioActorAttacked, OBJECT_CREATURE_DOOR_PLACEABLE);
    // The next to lines may appear to have parameters reversed. This is intentional.
    // If it is actiavtion, the default "owner attack PC" should become "targeted
    // attacks activator", which is a bit of a role-reversal.
    main.InitActivationRadios(nil, RadioOwnerAttacks, RadioActivatorAttacks, RadioTargetedAttacks, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(RadioPCAttacked, RadioOwnerAttacked, RadioActivatorAttacked, RadioTargetedAttacked, OBJECT_CREATURE_DOOR_PLACEABLE);

    // There is one bad case where we might have hidden a checked button.
    if RadioOwnerAttacks.Checked and not RadioOwnerAttacks.Visible then
        RadioTaggedAttacks.Checked := true;
end;


// Prevents requesting the script owner to attack itself.
procedure Tattack.RadioOwnerAttackedChange(Sender: TObject);
begin
    if RadioOwnerAttacked.Checked and RadioOwnerAttacks.Checked then
        RadioTaggedAttacks.Checked := true;

    RadioOwnerAttacks.Enabled := not RadioOwnerAttacked.Checked;
end;


// Prevents requesting the item activator to attack itself.
procedure Tattack.RadioActivatorAttackedChange(Sender: TObject);
begin
    if RadioActivatorAttacked.Checked and RadioActivatorAttacks.Checked then
        RadioTaggedAttacks.Checked := true;

    RadioActivatorAttacks.Enabled := not RadioActivatorAttacked.Checked;
end;


// Prevents requesting the targeted creature to attack itself.
procedure Tattack.RadioTargetedAttackedChange(Sender: TObject);
begin
    if RadioTargetedAttacked.Checked and RadioTargetedAttacks.Checked then
        RadioTaggedAttacks.Checked := true;

    RadioTargetedAttacks.Enabled := not RadioTargetedAttacked.Checked;
end;


// Prevents requesting the spawned creature to attack itself.
procedure Tattack.RadioSpawnAttackedChange(Sender: TObject);
begin
    if RadioSpawnAttacked.Checked and RadioSpawnAttacks.Checked then
        RadioTaggedAttacks.Checked := true;

    RadioSpawnAttacks.Enabled := not RadioSpawnAttacked.Checked;
end;


// Prevents requesting the last actor to attack itself.
procedure Tattack.RadioActorAttackedChange(Sender: TObject);
begin
    if RadioActorAttacked.Checked and RadioActorAttacks.Checked then
        RadioTaggedAttacks.Checked := true;

    RadioActorAttacks.Enabled := not RadioActorAttacked.Checked;
end;


// Updates the "st/nd/rd/th" text based on the spin edit.
procedure Tattack.SpinNthTagChange(Sender: TObject);
begin
    case SpinNthTag.Value of
        1:   TextNth.Caption := 'st';
        2:   TextNth.Caption := 'nd';
        3:   TextNth.Caption := 'rd';
        else TextNth.Caption := 'th';
    end;
end;


// Updates the status of the "Okay" buttons.
procedure Tattack.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // If a tagged victim is selected, a tag must be supplied.
    bEnable := not RadioTaggedAttacked.Checked or (EditTaggedAttacked.Text <> '');

    // If a tagged attacker is selected, a tag must be supplied.
    if bEnable then
        bEnable := not RadioTaggedAttacks.Checked or (EditTaggedAttacks.Text <> '');

    // Update the "Okay" buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------


// Resets the form so another attacker can be specified.
procedure Tattack.ClearForm();
begin
    // Can no longer change the attack target.
    PanelAttacked.Enabled := false;

    // Block a second attack from the same creature (aside from tagged creatures,
    // as that would be more involved than worthwhile).
    if RadioOwnerAttacks.Checked then begin
        RadioTaggedAttacks.Checked := true;
        RadioOwnerAttacks.Enabled := false;
    end
    else if RadioActivatorAttacks.Checked then begin
        RadioTaggedAttacks.Checked := true;
        RadioActivatorAttacks.Enabled := false;
    end
    else if RadioTargetedAttacks.Checked then begin
        RadioTaggedAttacks.Checked := true;
        RadioTargetedAttacks.Enabled := false;
    end
    else if RadioSpawnAttacks.Checked then begin
        RadioTaggedAttacks.Checked := true;
        RadioSpawnAttacks.Enabled := false;
    end
    else if RadioActorAttacks.Checked then begin
        RadioTaggedAttacks.Checked := true;
        RadioActorAttacks.Enabled := false;
    end;

    // Make a guess as to how to reset the tagged creature specification.
    if SpinNthTag.Value > 1 then begin
        SpinNthTag.Value := SpinNthTag.Value  + 1;
        SpinNthTagChange(SpinNthTag); // Not being called automatically. :(
    end
    else
        EditTaggedAttacks.text := '';
end;


// Generates the NWScript lines and sends them to the script window.
// For reference:
//
//    AdjustReputation(Victim, Attacker, -100);
//    SetIsTemporaryEnemy(Victim, Attacker);
//    AssignCommand(Attacker, DetermineCombatRound(Victim));
//
procedure Tattack.SendQueue();
var
    eVictim:    TObjectEnum;
    sVictim:    shortstring;
    start_line: integer;
    last_line:  integer;
    q_index:    integer;
    new_lines:  array of shortstring;
begin
    // Abort if there is nothing to send.
    if Length(AttackQueue) = 0 then
        exit;

    // Determine who is getting attacked.
    eVictim := GetChosenObject(RadioOwnerAttacked, RadioPCAttacked,
                               RadioActivatorAttacked, RadioTargetedAttacked,
                               RadioTaggedAttacked, RadioActorAttacked,
                               RadioSpawnAttacked, FALSE);
    // Declare a variable if needed.
    if eVictim = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);
    // Convert the code to NWScript (it's used multiple times).
    sVictim := ObjectVar(eVictim);

    // Allocate space.
    SetLength(new_lines, 2 + Length(ReputeQueue) + 2*Length(AttackQueue));

    // The opening comment.
    if eVictim = E_CHOOSE_Self then // E_CHOOSE_Owner has been blocked as an option.
        new_lines[0] := '// We are attacked!'
    else
        new_lines[0] := '// Attack '+ObjectDesc(eVictim, EditTaggedAttacked.Text)+'.';
    start_line := 1;

    // Define oTarget?
    if RadioTaggedAttacked.Checked then begin
        // Possibly override the opening comment.
        if EditAttackedName.Text <> '' then
            new_lines[0] := '// Attack '+EditAttackedName.Text+'.';
        // Define oTarget.
        new_lines[1] := s_oTarget+' = '+s_GetNearest + QuoteSwap(EditTaggedAttacked.Text)+'");';
        start_line := 2;
    end;

    // A little more preparation, then on to the queues.
    last_line := start_line - 1;
    Tlilac.Include(INC_GENERIC);   // For DetermineCombatRound().

    // Add the reputation adjustments.
    for q_index := 0 to Length(ReputeQueue)-1 do begin
        Inc(last_line);
        new_lines[last_line] := 'AdjustReputation('+sVictim+', '+
                                ReputeQueue[q_index]+', -100);';
    end;

    // Add the temporary enemy commands.
    for q_index := 0 to Length(AttackQueue)-1 do begin
        Inc(last_line);
        if AttackQueue[q_index] = s_OBJECT_SELF then
            new_lines[last_line] := 'SetIsTemporaryEnemy('+sVictim+');'
        else
            new_lines[last_line] := 'SetIsTemporaryEnemy('+sVictim+', '+ AttackQueue[q_index]+');';
    end;

    // Add the attack commands.
    for q_index := 0 to Length(AttackQueue)-1 do begin
        Inc(last_line);
        new_lines[last_line] := Script.AssignCommand(AttackQueue[q_index],
                                        'DetermineCombatRound('+sVictim+')')+';';
    end;

    // Add these lines to the script window.
    Tlilac.AddLines(new_lines[0..last_line], start_line, last_line)
end;


// Stores the specified attacker to memory, for later sending to the script window.
procedure Tattack.QueueThis();
var
    eAttacker: TObjectEnum;
    sAttacker: shortstring;
    iLength:   integer;
begin
    // Who is the attacker?
    eAttacker := GetChosenObject(RadioOwnerAttacks, nil, RadioActivatorAttacks,
                                 RadioTargetedAttacks, RadioTaggedAttacks,
                                 RadioActorAttacks, RadioSpawnAttacks);
    // Declare a variable if needed.
    if eAttacker = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // Convert the attacker to NWScript.
    if eAttacker <> E_CHOOSE_Tagged then
        sAttacker := ObjectVar(eAttacker)
    else
        // Instead of a variable, we will inline the call to GetNearestObjectByTag().
        // The thinking is that there is a reasonably high likelihood of defining
        // multiple attackers, especially if someone takes advantage of SpinNthTag.
        sAttacker := Script.GetNearest(QuoteSwap(EditTaggedAttacks.Text), '',
                                       SpinNthTag.Value);

    // Adjust reputation?
    if radiogroup1.itemindex = 0 then begin
        // Append sAttacker to the reputation queue.
        iLength := Length(ReputeQueue);
        SetLength(ReputeQueue, iLength+1);
        ReputeQueue[iLength] := sAttacker;
    end;

    // Append sAttacker to the attack queue.
    iLength := Length(AttackQueue);
    SetLength(AttackQueue, iLength+1);
    AttackQueue[iLength] := sAttacker;
end;


initialization
  {$i attackpc.lrs}
end.
