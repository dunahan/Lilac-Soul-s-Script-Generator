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
*   of simulated modal.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit applyvisual;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, Buttons,
  LResources, QueueForm, Spin, constants;

type

  { Tvfx }

  Tvfx = class(TQueueForm)
      CheckActor: TCheckBox;
      CheckLocation: TCheckBox;
      CheckOwner: TCheckBox;
      CheckPC: TCheckBox;
      CheckSpawn: TCheckBox;
      CheckTagged: TCheckBox;
      ComboDuration: TComboBox;
      ComboImpact: TComboBox;
      EditTagged: TEdit;
      GroupDuration: TGroupBox;
      GroupVFX: TGroupBox;
      GroupTarget: TGroupBox;
      RadioSeconds: TRadioButton;
      RadioExtraordinary: TRadioButton;
      RadioSupernatural: TRadioButton;
      RadioImpact: TRadioButton;
      RadioDuration: TRadioButton;
      SpinSeconds: TSpinEdit;
      TextLocation: TStaticText;
    uniquetarget: TCheckBox;
    CheckTargetLoc: TCheckBox;
    uniqueuser: TCheckBox;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  protected
    // Helper methods
    procedure ClearForm(); override;
    procedure QueueThis(); override;
    procedure SendQueue(); override;

  private
    // The queue
    ListVFX: array of integer;
    ListDur: array of integer;
    ListSubtype: array of char;
    ListTargets: array of TObjectList;
    ListTags:    array of shortstring;
    ListLocFlag: array of boolean;
  end;

{var
  vfx: Tvfx;
}

implementation

uses
    {event, black_smith,} start, nwn;


// Configures the form based on the current situation.
procedure Tvfx.FormCreate(Sender: TObject);
begin
    // Initialize the queue (all arrays are assumed the same length as ListVFX).
    SetLength(ListVFX, 0);

    // Load the lists of visual effects.
    LoadConstants(ComboDuration.Items, VFX_DURATION);
    LoadConstants(ComboImpact.Items, VFX_IMPACT);
    // Remove the "none" options.
    ComboDuration.items.Delete(0);
    ComboImpact.items.Delete(0);

    // Configure the check boxes.
    main.InitRadioWhos(CheckOwner, CheckSpawn, CheckActor, OBJECT_TYPE_IN_AREA);
    main.InitActivationRadios(CheckOwner, CheckPC, uniqueuser, uniquetarget,
                              OBJECT_TYPE_IN_AREA, CheckTargetLoc);
end;


// Controls the enabled state of the "Okay" buttons.
procedure Tvfx.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // A subject for the effect must be chosen.
    if not (CheckOwner.checked  or  CheckPC.checked       or  CheckTagged.checked     or
            uniqueuser.checked  or  uniquetarget.checked  or  CheckTargetLoc.Checked  or
            CheckSpawn.Checked  or  CheckActor.Checked) then
        bEnable := FALSE

    // A tagged object needs a tag.
    else if CheckTagged.checked  and  (EditTagged.text = '') then
        bEnable := FALSE

    // A visual effect must be selected.
    else if RadioDuration.Checked then
        bEnable := ComboDuration.itemindex >= 0
    else
        bEnable := ComboImpact.itemindex >= 0;

    // Update the "Okay" buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------

// Clears the form so more visuals can be specified.
procedure Tvfx.ClearForm();
begin
    // Clear the subjects.
    CheckOwner.checked     := false;
    CheckPC.checked        := false;
    uniqueuser.checked     := false;
    uniquetarget.checked   := false;
    CheckTargetLoc.checked := FALSE;
    CheckTagged.checked    := false;
    CheckSpawn.Checked     := FALSE;
    CheckActor.Checked     := FALSE;

    // Clear the selected visual.
    ComboDuration.itemindex := -1;
    ComboImpact.ItemIndex   := -1;
end;


// Stores the entered information for later processing.
procedure Tvfx.QueueThis();
var
    list_length: integer;
    eType: TObjectEnum;
begin
    list_length := Length(ListVFX);

    // Allocate space for the current info.
    SetLength(ListVFX,     list_length+1);
    SetLength(ListDur,     list_length+1);
    SetLength(ListSubtype, list_length+1);
    SetLength(ListTargets, list_length+1);
    SetLength(ListTags,    list_length+1);
    SetLength(ListLocFlag, list_length+1);

    // Store the selected visual effect index.
    if RadioDuration.Checked then
        ListVFX[list_length] := ComboDuration.itemindex + 1  // +1 because we took out the "none" option.
    else
        ListVFX[list_length] := ComboImpact.itemindex + 1 +  // +1 because we took out the "none" option.
                                High(VFX_DURATION);          // To distinguish these from VFX_DURATIONs.

    // Store the duration of this visual.
    if RadioImpact.Checked then
        ListDur[list_length] := 0   // instantaneous
    else if RadioSeconds.Checked then
        ListDur[list_length] := SpinSeconds.Value
    else
        ListDur[list_length] := -1; // permanent

    // Store the implied subtype of the selected visual effect.
    if RadioImpact.Checked then
        ListSubtype[list_length] := ' '  // no need to change the subtype
    else if RadioExtraordinary.Checked then
        ListSubtype[list_length] := 'E'  // extraordinary effect
    else
        ListSubtype[list_length] := 'S'; // supernatural effect

    // Store the target information.
    ListTags[list_length] := QuoteSwap(EditTagged.text);
    ListLocFlag[list_length] := CheckLocation.Checked;
    // Initialize the sublist to false, in case there are options we do not cover.
    for eType := Low(TObjectEnum) to High(TObjectEnum) do
        ListTargets[list_length][eType] := FALSE;
    // Now set the entries of the sublist we do cover.
    ListTargets[list_length][E_CHOOSE_Self] := CheckOwner.Checked;
    ListTargets[list_length][E_CHOOSE_PC]   := CheckPC.Checked;
    ListTargets[list_length][E_CHOOSE_Activator] := uniqueuser.Checked;
    ListTargets[list_length][E_CHOOSE_ActTarget] := uniquetarget.Checked;
    ListTargets[list_length][E_CHOOSE_Other]     := CheckTargetLoc.Checked;
    ListTargets[list_length][E_CHOOSE_Tagged] := CheckTagged.Checked;
    ListTargets[list_length][E_CHOOSE_Actor]  := CheckActor.Checked;
    ListTargets[list_length][E_CHOOSE_Spawn]  := CheckSpawn.Checked;
end;


// Send the NWScript corresponding to the stored info to the script window.
procedure Tvfx.SendQueue();
var
    list_length, iVFX: integer;
    which_visual: shortstring;
    prefix, suffix: shortstring; // For setting the subtype of effects.
    eType: TObjectEnum;

    last_line: integer;
    new_lines: array of shortstring;
begin
    list_length := Length(ListVFX);

    // Abort if there is nothing to do.
    if list_length = 0 then
        exit;

    // Allocate space. Opening comment plus up to 9 lines per queue entry (even
    // though we should effectively only need 7).
    SetLength(new_lines, 1 + 9*list_length);

    // The opening comment.
    if list_length > 1 then
        new_lines[0] := '// Apply some visual effects.'
    else
        new_lines[0] := '// Apply a visual effect.';
    last_line := 0;

    for iVFX := 0 to list_length-1 do begin
        // Get the symbolic constant for the selected visual effect.
        if ListVFX[iVFX] <= High(VFX_DURATION) then
            which_visual := SymConst(VFX_DURATION, ListVFX[iVFX])
        else
            which_visual := SymConst(VFX_IMPACT, ListVFX[iVFX] - High(VFX_DURATION));

        // Determine the type of visual effect.
        prefix := '';
        suffix := ')'; // One of prefix or suffix will be right at this point.
        case ListSubtype[iVFX] of
            'E': prefix := 'ExtraordinaryEffect(';
            'S': prefix := 'SupernaturalEffect(';
            else suffix := ''
        end;

        // Define the effect.
        Inc(last_line);
        new_lines[last_line] := s_eVFX+' = '+prefix + s_EffectVisual + which_visual +
                                suffix + ');';

        // Define oSelf?
        if ListTargets[iVFX][E_CHOOSE_Self] then
            Tlilac.Declare(VAR_oSELF);

        // Define oTarget?
        if ListTargets[iVFX][E_CHOOSE_Tagged] then begin
            Inc(last_line);
            new_lines[last_line] := s_oTarget+' = '+s_GetObject + ListTags[iVFX]+'");';
        end;

        // Go through the possible targets.
        for eType := Low(TObjectEnum) to High(TObjectEnum) do
            if ListTargets[iVFX][eType] then begin
                Inc(last_line);
                // E_CHOOSE_Other signals the activation target location, regardless
                // of the location flag.
                if eType = E_CHOOSE_Other then
                    new_lines[last_line] := Script.ApplyEffect(s_eVFX, s_lActTarget,
                                                               TRUE, ListDur[iVFX]) +
                                            ';'
                else
                    new_lines[last_line] := Script.ApplyEffect(s_eVFX,
                                                ObjectVar(eType, '', ListLocFlag[iVFX]),
                                                ListLocFlag[iVFX], ListDur[iVFX]) +
                                            ';';
            end;
    end;//for

    // Add these lines to the script window.
    Tlilac.AddLines(new_lines[0..last_line], 1, last_line);
end;


initialization
  {$i applyvisual.lrs}
end.
