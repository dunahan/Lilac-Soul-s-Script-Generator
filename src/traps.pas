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
* Some of this was trimmed when I converted the form to being really modal instead
*   of simulated modal, and simulated radio buttons to actual radio buttons.
* Expanded options of what to trap.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit traps;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms,
  {Dialogs,} StdCtrls, ExtCtrls, Spin, Buttons, nwn,
  LResources, QueueForm, constants, Classes;

type

  { Ttrapform }

  Ttrapform = class(TQueueForm)
    // Form elements.
      ComboStrength: TComboBox;
      ComboType: TComboBox;
      EditCreateTagged: TEdit;
      GroupCreate: TGroupBox;
      Label2: TLabel;
      PanelDelayInfo: TPanel;
      PanelLocationCreate: TPanel;
      RadioCreateActor: TRadioButton;
      RadioCreateActivator: TRadioButton;
      RadioCreatePC: TRadioButton;
      RadioCreateTargetLoc: TRadioButton;
      RadioLocationCreate: TRadioButton;
      RadioObjectCreate: TRadioButton;
      RadioCreateOwner: TRadioButton;
      RadioCreateSpawn: TRadioButton;
      RadioCreateTagged: TRadioButton;
      RadioCreateTargeted: TRadioButton;
      ShapeFormSpacer: TShape;
      LabelTriggerScript: TLabel;
      LabelStrength: TLabel;
      LabelDisarmScript: TLabel;
      LabelType: TLabel;
      CheckManipulate: TCheckBox;
      Disable: TCheckBox;
      GroupManipulate: TGroupBox;
      EditChangeTagged: TEdit;
      OnDisarm: TEdit;
      OnTriggered: TEdit;
      PanelCreate: TPanel;
      RadioChangePCDetected: TRadioButton;
      RadioChangeNearPC: TRadioButton;
      RadioChangeRecent: TRadioButton;
      RadioChangeTagged: TRadioButton;
      RadioChangeSpawn: TRadioButton;
      RadioChangeTargeted: TRadioButton;
      RadioChangeOwner: TRadioButton;
      CheckKeyTag: TCheckBox;
      CheckDisarmDC: TCheckBox;
      CheckDetectDC: TCheckBox;
    CheckCreate: TCheckBox;
    ShapePanelSpacer: TShape;
    SpinSize: TFloatSpinEdit;
    TextTriggerScript: TStaticText;
    PanelManipulate: TPanel;
    Label1: TLabel;
    ActiveStatus: TRadioGroup;
    DetectableStatus: TRadioGroup;
    Detected: TRadioGroup;
    Disarmability: TRadioGroup;
    Oneshot: TRadioGroup;
    Recover: TRadioGroup;
    SpinDetectDC: TSpinEdit;
    SpinDisarmDC: TSpinEdit;
    EditKeyTag: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure CheckCreateChange(Sender: TObject);
    procedure RadioLocationCreateChange(Sender: TObject);
    procedure ComboStrengthChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  protected
    // Helper methods
    procedure ClearForm(); override;
    procedure QueueThis(); override;

  private
    // Bookkeeping
    LastNonEpicType: integer;

    // Helper methods
    procedure SetRecent();
    procedure DoTrapCreate(the_trap: TObjectEnum; bLocation: boolean;
                           var last_line: integer; var new_lines: TStringAry);
    procedure DoTrapChange(the_trap: TObjectEnum; bMergeSections: boolean;
                           var start_line, last_line: integer; var new_lines: TStringAry);
    procedure DoTrapStatus(Status: integer; const sCommand, sTrap: shortstring;
                           var last_line: integer; var new_lines: TStringAry;
                           const sExtraParam: shortstring='');
  end;

{var
  trapform: Ttrapform;
}

// -----------------------------------------------------------------------------
implementation

uses
    {event,} start,
    delay;

const
    OBJECT_TYPE_TRAPABLE = OBJECT_TYPE_DOOR or OBJECT_TYPE_PLACEABLE;


// Form initializations.
procedure Ttrapform.FormCreate(Sender: TObject);
begin
    // Initialize bookkeeping.
    LastNonEpicType := -1;

    // Initialize radio buttons.
    main.InitRadioWhos(RadioCreateOwner, RadioCreateSpawn, RadioCreateActor, OBJECT_TYPE_IN_AREA);
    // We do not want the labels of the "Change" options to change, so not calling
    // InitRadioWhos() for these.
    RadioChangeOwner.Visible := 0 <> OBJECT_TYPE_TRAPABLE and main.ObjectType;
    RadioChangeSpawn.Visible := 0 <> OBJECT_TYPE_TRAPABLE and Tlilac.last_spawn_type;
    // Back to the usual function call to handle activation visibility.
    main.InitActivationRadios(RadioCreatePC, RadioCreateOwner, RadioCreateActivator,
                              RadioCreateTargeted, OBJECT_TYPE_IN_AREA, RadioCreateTargetLoc);
    main.InitActivationRadios(nil, RadioChangeOwner, nil, RadioChangeTargeted, OBJECT_TYPE_TRAPABLE);

    // Make sure a visible choice is the default selection.
    with RadioCreateOwner do
        if Checked and not Visible then
            RadioCreateTagged.Checked := true;
    with RadioChangeOwner do
        if Checked and not Visible then
            RadioChangeTagged.Checked := true;

    // Now enable and disable the radio buttons as necessary.
    RadioLocationCreateChange(RadioLocationCreate);

    // Show an explanatory message if we are on a delay.
    PanelDelayInfo.Visible := Tdelaycommand.DelaySet();
end;


// Lets Tlilac know that we are done adding lines.
procedure Ttrapform.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    Tlilac.AddLinesDone()
end;


// Intercepts changes to CheckCreate so that the option to change the most recent
// trap gets updated (rather than updating it every time someone calls ToggleOkay() ).
procedure Ttrapform.CheckCreateChange(Sender: TObject);
begin
    // Handle the enabled state of stuff with a generic function, so the form can
    // be changed independent of this function.
    CheckChangeToggleEnable(Sender);

    // Also update the option to make changes to the most recent trap.
    SetRecent();
end;


// Handles changes to the form based on creating a trap at a location vs. on an object.
procedure Ttrapform.RadioLocationCreateChange(Sender: TObject);
begin
    // Update the target selection group.
    if RadioLocationCreate.Checked then begin
        // Update the caption to indicate we want a location.
        GroupCreate.Caption := 'Create the trap at the location of what?';
        // All options are enabled (but possibly not visible; that is handled elsewhere).
        RadioCreateOwner.Enabled     := TRUE;
        RadioCreatePC.Enabled        := TRUE;
        RadioCreateActivator.Enabled := TRUE;
        RadioCreateTargeted.Enabled  := TRUE;
        RadioCreateTargetLoc.Enabled := TRUE;
        RadioCreateSpawn.Enabled     := TRUE;
        RadioCreateActor.Enabled     := TRUE;
    end
    else begin
        // Update the caption to indicate we want a door or placeable.
        GroupCreate.Caption := 'Create the trap on what? (Door or placeable only)';
        // Disable things that are not a door or placeable.
        RadioCreateOwner.Enabled     := 0 <> main.ObjectType and OBJECT_TYPE_TRAPABLE;
        RadioCreatePC.Enabled        := FALSE;
        RadioCreateActivator.Enabled := FALSE;
        RadioCreateTargeted.Enabled  := 0 <> main.ActTargetType and OBJECT_TYPE_TRAPABLE;
        RadioCreateTargetLoc.Enabled := FALSE;
        RadioCreateSpawn.Enabled     := 0 <> Tlilac.last_spawn_type and OBJECT_TYPE_TRAPABLE;
        RadioCreateActor.Enabled     := FALSE;

        // Supply a default selection if the old selection just got disabled.
        with RadioCreateOwner do
            if not Enabled and Checked then
                RadioCreateTagged.Checked := TRUE;
        with RadioCreateTargeted do
            if not Enabled and Checked then
                RadioCreateTagged.Checked := TRUE;
        with RadioCreateSpawn do
            if not Enabled and Checked then
                RadioCreateTagged.Checked := TRUE;
        // And the ones we know are not enabled.
        if RadioCreatePC.Checked         or  RadioCreateActivator.Checked  or
           RadioCreateTargetLoc.Checked  or  RadioCreateActor.Checked then
            RadioCreateTagged.Checked := TRUE;
    end;

    // Handle the visibility of stuff with a generic function, so the form can
    // be changed independent of this function.
    RadioChangeToggleVisible(Sender);


    // Also update the radio button for making changes to the most recent trap.
    SetRecent();
end;


// Hides the non-epic trap types when epic strength is requested.
procedure Ttrapform.ComboStrengthChange(Sender: TObject);
const
    // Converts indices of normal trap types to indices of epic trap types.
    ToEpic: array[0..10] of integer =
        ( -1, -1,
          0, // Electrical
          1, // Fire
          2, // Frost
          -1, -1, -1,
          3, // Sonic
          -1, -1 );

    // Converts indices of epic trap types to indices of normal trap types.
    FromEpic: array[0..3] of integer =
        ( 2, 3, 4, 8 );
var
    current_selection: integer;
begin
    // If a strength other than "Epic" was selected:
    if ComboStrength.ItemIndex < 4 then begin
        // Are some options hidden?
        if ComboType.Items[0] = 'Electrical' then begin
            // Save the selection.
            current_selection := ComboType.ItemIndex;
            // Fill in the missing options.
            with ComboType.Items do begin
                Insert(0, 'Acid blob');
                Insert(1, 'Acid splash');
                Insert(5, 'Gas');
                Insert(6, 'Holy');
                Insert(7, 'Negative');
                Insert(9, 'Spike');
                Insert(10,'Tangle');
            end;
            // Restore the selection.
            if current_selection >= 0 then
                ComboType.ItemIndex := FromEpic[current_selection]
            else
                ComboType.ItemIndex := LastNonEpicType;

            // Update the "Okay" buttons.
            ToggleOkay(Sender);
        end;
    end

    // Else, epic strength:
    else begin
        // Do some options need to be hidden?
        if ComboType.Items[0] <> 'Electrical' then begin
            // Save the selection.
            LastNonEpicType := ComboType.ItemIndex;
            // Remove the non-epic types.
            with ComboType.Items do begin
                Delete(10); // Tangle
                Delete(9);  // Spike
                Delete(7);  // Negative
                Delete(6);  // Holy
                Delete(5);  // Gas
                Delete(1);  // Acid splash
                Delete(0);  // Acid blob
            end;
            // Restore the selection.
            if LastNonEpicType >= 0 then
                ComboType.ItemIndex := ToEpic[LastNonEpicType];

            // Update the "Okay" buttons.
            ToggleOkay(Sender);
        end;
    end;
end;


// Controls the enabled state of the "Okay" buttons.
procedure TTrapform.ToggleOkay(Sender: TObject);
var
    bDoingSomething, bEnable: boolean;
begin
    bDoingSomething := FALSE;
    bEnable := TRUE;

    // Checks for creating a trap:
    if CheckCreate.Checked then begin
        bDoingSomething := TRUE;
        // Tagged objects need a tag.
        if RadioCreateTagged.Checked and (EditCreateTagged.text = '') then
            bEnable := FALSE
        // A trap type is required (can be lost when switching to epic traps).
        else
            bEnable := ComboType.ItemIndex >= 0;
    end;

    // Checks for modifying a trap:
    if bEnable and CheckManipulate.Checked then begin
        // We need a further check to see if we are really doing something.
        // (This will override the flag if we are creating a trap.)
        bDoingSomething :=
            CheckDetectDC.Checked  or  CheckDisarmDC.Checked or
            CheckKeyTag.Checked    or  Disable.Checked       or
            (ActiveStatus.ItemIndex     > 0)  or  (Oneshot.ItemIndex  > 0)  or
            (Disarmability.ItemIndex    > 0)  or  (Recover.ItemIndex  > 0)  or
            (DetectableStatus.ItemIndex > 0)  or  (Detected.ItemIndex > 0);
        // Tagged objects need a tag.
        bEnable := not RadioChangeTagged.Checked or (EditChangeTagged.Text <> '');
    end;

    // Update the "Okay" buttons.
    BitBtn1.Enabled := bEnable and bDoingSomething;
    BitBtn2.Enabled := bEnable and bDoingSomething;
end;


// -----------------------------------------------------------------------------


// Clears the form so that another trap may be created/changed.
procedure TTrapform.ClearForm();
begin
    // Select nothing to do.
    CheckCreate.Checked     := false;
    CheckManipulate.Checked := false;
    // On the manipulate panel:
    CheckDetectDC.Checked := FALSE;
    CheckDisarmDC.Checked := FALSE;
    CheckKeyTag.Checked   := FALSE;
    Disable.Checked       := FALSE;
    ActiveStatus.ItemIndex     := 0;
    OneShot.ItemIndex          := 0;
    Disarmability.ItemIndex    := 0;
    Recover.ItemIndex          := 0;
    DetectableStatus.ItemIndex := 0;
    Detected.ItemIndex         := 0;

    // Blank out some info that probably is not reusable.
    EditCreateTagged.Text := '';
    EditChangeTagged.Text := '';
end;


// Sends the requestes NWScript to the script window.
procedure TTrapform.QueueThis();
var
    new_trap, change_trap: TObjectEnum;
    bLocation, bMergeSections: boolean;

    start_line, last_line: integer;
    new_lines: array of shortstring;
begin
    SetLength(new_lines, 15); // 3 lines to create a trap plus 12 to manipulate.
    bLocation := RadioLocationCreate.Checked  or  RadioCreateTargetLoc.Checked;

    // ---------------------------------
    // Get info about the objects we will be using.
    new_trap := GetChosenObject(RadioCreateOwner, RadioCreatePC,
                                RadioCreateActivator, RadioCreateTargeted,
                                RadioCreateTagged, RadioCreateActor,
                                RadioCreateSpawn, FALSE);
    change_trap := GetChosenObject(RadioChangeOwner, nil, nil, RadioChangeTargeted,
                                   RadioChangeTagged, nil, RadioChangeSpawn, FALSE);
    // If we will be creating a trap then changing that same trap, combine the
    // code into one block (in the script).
    bMergeSections := CheckCreate.Checked  and  CheckManipulate.Checked;
    if bMergeSections then begin
        if bLocation then
            bMergeSections := RadioChangeRecent.Checked
        else if (new_trap = E_CHOOSE_Tagged)  and  (change_trap = E_CHOOSE_Tagged) then
            bMergeSections := EditCreateTagged.Text = EditChangeTagged.Text
        else
            bMergeSections := new_trap = change_trap;
    end;

    // ---------------------------------
    // Trap creation.
    if CheckCreate.Checked then begin
        DoTrapCreate(new_trap, bLocation, last_line, new_lines); // At most 3 lines.

        // Submit this (not delayed) if there is nothing else to do to this trap.
        if not bMergeSections then
            Tlilac.AddLines(new_lines[0..last_line], -1, -1, TRUE);
    end;


    // ---------------------------------
    // Trap manipulation.
    if CheckManipulate.Checked then begin
        DoTrapChange(change_trap, bMergeSections, start_line, last_line, new_lines); // At most 12 lines.

        // Submit this.
        Tlilac.AddLines(new_lines[0..last_line], start_line, last_line, TRUE);
    end;
end;


// -----------------------------------------------------------------------------


// Updates the caption and enabled state of RadioChangeRecent based on wheter
// or not a trap is being created at a location.
procedure Ttrapform.SetRecent();
begin
    // If we are creating a trap at a location.
    if CheckCreate.Checked  and  RadioLocationCreate.Checked then begin
        RadioChangeRecent.Caption := 'The ground trap created above';
        RadioChangeRecent.Enabled := TRUE;
    end
    else begin
        RadioChangeRecent.Caption := 'The last ground trap created';
        RadioChangeRecent.Enabled := Tlilac.IsDeclared(VAR_oTRAP);

        // Do not allow selection of a disabled option.
        with RadioChangeRecent do
            if not Enabled and Checked then
                RadioChangeTagged.Checked := TRUE;
    end;
    {$ifdef WIN32}
    // Windows widgets seem to have trouble displaying enabled radio buttons as
    // disabled when their containing widget is disabled.
    if RadioChangeRecent.Enabled and not GroupManipulate.Enabled then begin
        // Force a correct display.
        GroupManipulate.Enabled := TRUE;
        GroupManipulate.Enabled := FALSE;
    end;
    {$endif}
end;


// Supplies the NWScript for creating a trap.
// (Split into its own procedure because QueueThis() was fairly long.)
// Can fill up to 3 lines in new_lines.
procedure Ttrapform.DoTrapCreate(the_trap: TObjectEnum; bLocation: boolean;
                                 var last_line: integer; var new_lines: TStringAry);
var
    trap_type: shortstring;
begin
    // Get the NWScript constant for the requested trap type/strength.
    trap_type := ComboType.Text;
    // I used one name that does not match the NWScript constant.
    if trap_type = 'Acid blob' then
        trap_type := 'ACID';
    // The conversion:
    trap_type := NameToConstant('TRAP_BASE_TYPE', ComboStrength.text+' '+trap_type);

    // The opening comment.
    new_lines[0] := '// Create a trap.';
    last_line := 1;

    // Do we need to define the target?
    if the_trap = E_CHOOSE_Tagged then begin
        new_lines[1] := s_oTarget+' = '+s_GetObject + QuoteSwap(EditCreateTagged.text)+'");';
        last_line := 2;
    end;

    // Create the trap
    new_lines[last_line] := Script.CreateTrap(
                                trap_type, ObjectVar(the_trap, s_lActTarget, bLocation),
                                QuoteSwap(OnDisarm.Text), QuoteSwap(OnTriggered.Text),
                                bLocation, SpinSize.Text)+
                            ';';
    // Remember this trap if it was at a location.
    if bLocation then
        new_lines[last_line] := s_oTrap+' = '+new_lines[last_line];
end;


// Supplies the NWScript for changing a trap's attributes.
// (Split into its own procedure because QueueThis() was fairly long.)
// Can fill up to 12 lines in new_lines.
procedure Ttrapform.DoTrapChange(the_trap: TObjectEnum; bMergeSections: boolean;
                                 var start_line, last_line: integer; var new_lines: TStringAry);
var
    trap_var: shortstring;
begin
    // If we are not manipulating the trap we just created:
    if not bMergeSections then begin
        // The opening comment.
        last_line := 0;
        new_lines[0] := '// Manipulate an existing trap.';

        // Define the target?
        if the_trap = E_CHOOSE_Tagged then begin
            last_line := 1;
            new_lines[1] := s_oTarget+' = '+s_GetObject + QuoteSwap(EditChangeTagged.Text)+'");';
        end
        else if (the_trap = E_CHOOSE_Other) and not RadioChangeRecent.Checked then begin
            // Some special cases.
            last_line := 1;
            new_lines[1] := s_oTarget+' = GetNearestTrapToObject('+s_oPC;
            if not RadioChangePCDetected.Checked then
                new_lines[1] += s_comma_FALSE;
            new_lines[1] +=  ');';
        end;
    end;

    // Remember the line at which to start delaying things.
    start_line := last_line + 1;
    // Cache the variable to be used in all the NWScript commands that follow.
    if RadioChangeRecent.Checked then
        trap_var := s_oTrap
    else
        trap_var := ObjectVar(the_trap, s_oTarget);

    // The unchanged/on/off settings:
    DoTrapStatus(ActiveStatus.ItemIndex,     'SetTrapActive',      trap_var, last_line, new_lines);
    DoTrapStatus(OneShot.ItemIndex,          'SetTrapOneShot',     trap_var, last_line, new_lines);
    DoTrapStatus(Disarmability.ItemIndex,    'SetTrapDisarmable',  trap_var, last_line, new_lines);
    DoTrapStatus(Recover.ItemIndex,          'SetTrapRecoverable', trap_var, last_line, new_lines);
    DoTrapStatus(DetectableStatus.ItemIndex, 'SetTrapDetectable',  trap_var, last_line, new_lines);
    DoTrapStatus(Detected.ItemIndex,         'SetTrapDetectedBy',  trap_var, last_line, new_lines,
                 s_oPC);

    // The other settings.
    if CheckDetectDC.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetTrapDetectDC('+trap_var+', '+SpinDetectDC.Text+');';
    end;
    if CheckDisarmDC.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetTrapDisarmDC('+trap_var+', '+SpinDisarmDC.Text+');';
    end;
    if CheckKeyTag.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetTrapKeyTag('+trap_var+', "'+QuoteSwap(EditKeyTag.Text)+'");';
    end;
    if Disable.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetTrapDisabled('+trap_var+');';
    end;
end;


// Supplies the NWScript for changing a trap's status, if that was requested.
// This is for the NWScript commands whose prototype looks like:
//   <sCommand>(object oTrapObject, int <something>=TRUE);
// The status codes are:
//  0 = no change
//  1 = turn on
//  2 = turn off
procedure Ttrapform.DoTrapStatus(Status: integer; const sCommand, sTrap: shortstring;
                                 var last_line: integer; var new_lines: TStringAry;
                                 const sExtraParam: shortstring='');
begin
    // See if a change was requested.
    if Status > 0 then begin
        Inc(last_line);
        new_lines[last_line] := sCommand+'('+sTrap;
        // A second required parameter?
        if sExtraParam <> '' then
            new_lines[last_line] += ', '+sExtraParam;
        // Optional parameter.
        if Status > 1 then
            new_lines[last_line] += s_comma_FALSE;
        // End the line.
        new_lines[last_line] += ');';
    end;
end;


initialization
  {$i traps.lrs}
end.
