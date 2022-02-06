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
* Some of this was trimmed when I converted the form to being officially modal
    instead of simulated modal.
* Converted the "new" method so that it requires only one script, rather than
    one script plus one script per handled event.
* Cleanup of the generated scripts. Including fixing the part where the user
    could require the target to be both a door and a placeable (and a creature).
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit unique_power;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, Buttons,
  LResources, ExtCtrls, ExtForm;

type

  { Tuniquepower }

  Tuniquepower = class(TExtForm)
    // Form elements
      GroupRestrictTarget: TGroupBox;
    dmonly: TCheckBox;
    BitBtn3: TBitBtn;
    GroupRestrictType: TCheckGroup;
    GroupSystem: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    Edit1: TEdit;
    Label4: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn4: TBitBtn;
    GroupPC: TRadioGroup;
    RadioRestrictType: TRadioButton;
    RadioRestrictPC: TRadioButton;
    RadioRestrictObject: TRadioButton;
    RadioRestrictLocation: TRadioButton;
    RadioRestrictNone: TRadioButton;
    // Event handlers
    procedure dmonlyChange(Sender: TObject);
    procedure GroupRestrictTypeItemClick(Sender: TObject; Index: integer);
    procedure TogglePCChoice(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  end;


{var
    uniquepower: Tuniquepower;
}

// -----------------------------------------------------------------------------

implementation

uses
    start, nwn, {event,} EventHelper,
    constants;

const
    OBJECT_TYPE_TARGETABLE = OBJECT_TYPE_CREATURE or OBJECT_TYPE_ITEM or
                             OBJECT_TYPE_DOOR     or OBJECT_TYPE_PLACEABLE;


// Quick handly little utility for seeing if anything in a TCheckGroup is checked.
function NoneChecked(the_group: TCustomCheckGroup) : boolean;
var
    index: integer;
begin
    // Begin by assuming something is checked.
    result := FALSE;
    // Check each item to verify this assumption.
    for index := 0 to the_group.Items.Count - 1 do
        if the_group.Checked[index] then
            exit;
    // Our assumption was wrong; nothing is checked.
    result := TRUE;
end;


// -----------------------------------------------------------------------------


// Handles changes to the "useable by DMs only" checkbox.
procedure Tuniquepower.dmonlyChange(Sender: TObject);
begin
    // Something used by the DM is likely to target the PC.
    if dmonly.Checked then
        GroupPC.ItemIndex := 1;
end;


// Handles selections of which item types to allow as targets of the activation.
procedure Tuniquepower.GroupRestrictTypeItemClick(Sender: TObject; Index: integer);
begin
    // Auto-select the associated radio button if a selection was added.
    if GroupRestrictType.Checked[Index] then
        RadioRestrictType.Checked := TRUE
    // Else, if nothing is selected, then the associated radio button really
    // means "no object allowed".
    else if RadioRestrictType.Checked  and NoneChecked(GroupRestrictType) then
        RadioRestrictLocation.Checked := TRUE;

    // Update the PC selection.
    TogglePCChoice(Sender);
end;


// Defines when "the PC" can logically be chosen to be the activation target.
procedure Tuniquepower.TogglePCChoice(Sender: TObject);
var
    bEnable: boolean;
begin
    // If no object is targeted, the PC has to be the activator.
    if RadioRestrictLocation.Checked then
        bEnable := FALSE
    // If the object type is forced, creatures must be included.
    else if RadioRestrictType.Checked then
        bEnable := GroupRestrictType.Checked[0]
    else
        // The target might be a creature, so allow the choice.
        bEnable := TRUE;

    // Update the choice.
    GroupPC.Enabled := bEnable;
end;


// Overrides the default procedure to do nothing.
// (This is so that I can have a default button on this form that is always enabled.)
procedure Tuniquepower.ToggleOkay(Sender: TObject);
begin
end;


// Handles clicks of the "show old system" button.
procedure Tuniquepower.BitBtn1Click(Sender: TObject);
begin
    TEventHelp.Popop(EventHelpOldSystem);
end;


// Handles clicks of the "show new system" button.
procedure Tuniquepower.BitBtn2Click(Sender: TObject);
begin
    TEventHelp.Popop(EventHelpNewSystem);
end;


// Handles clicks of the "compare systems" button.
procedure Tuniquepower.BitBtn4Click(Sender: TObject);
begin
    TEventHelp.Popop(EventHelpOldOrNew);
end;


// Handles clicks of the "continue" button.
procedure Tuniquepower.BitBtn3Click(Sender: TObject);
const
    // The object types corresponding to indices of GroupRestrictType, NWScript constants.
    RESTRICT_OBJECT: array[0..3] of pchar =
      ( 'OBJECT_TYPE_CREATURE',
        'OBJECT_TYPE_DOOR',
        'OBJECT_TYPE_ITEM',
        'OBJECT_TYPE_PLACEABLE' );
    // The object types corresponding to indices of GroupRestrictType, Pascal constants.
    RESTRICT_TYPE: array[0..3] of word =
      ( OBJECT_TYPE_CREATURE,
        OBJECT_TYPE_DOOR,
        OBJECT_TYPE_ITEM,
        OBJECT_TYPE_PLACEABLE );
var
    index: integer;
    first_line, last_line: integer;
    new_lines: array[-6..3] of shortstring;
begin
    // Start the script.
    Tlilac.InitScript(SCRIPTTYPE_TAG_ACTIVATE, GroupSystem.ItemIndex=1);

    // Define oPC.
    new_lines[0] := 'object '+s_oPC+' = ';
    if GroupPC.Enabled  and  (GroupPC.ItemIndex = 1) then
        new_lines[0] += s_oActTarget+';'
    else
        new_lines[0] += s_oActivator+';';
    Tlilac.AddLines(new_lines[0]);

    // A little backward-seeming perhaps, but start by constructing the
    // script's "then" clause, starting at line 0.
    // (This is used by each potential "if" statement in the script.)
    if not checkbox7.checked then begin
            new_lines[0] := s_Return;
            last_line := 0;
    end
    else begin
        new_lines[0] := '{';
        new_lines[1] := '    SendMessageToPC('+s_oActivator+', "'+QuoteSwap(edit1.text)+'");';
        new_lines[2] := '    return;';
        new_lines[3] := '}';
        last_line := 3;
    end;

    // Now construct the "if" conditional in the lines with negative indices.
    // Add a DM-only restriction?
    if dmonly.checked then begin
        new_lines[-2] := '// Only DMs are allowed to use this item.';
        new_lines[-1] := 'if ( !GetIsDM('+s_oActivator+') )';
        Tlilac.AddLines(new_lines[-2..last_line]);
    end;

    // Add a no-combat restriction?
    if checkbox6.checked then begin
        new_lines[-2] := '// This item cannot be used in combat.';
        new_lines[-1] := 'if ( GetIsInCombat('+s_oActivator+') )';
        Tlilac.AddLines(new_lines[-2..last_line]);
    end;

    // Add a target check? (if-else-if chain)
    if RadioRestrictNone.Checked then
        main.ActTargetType := OBJECT_TYPE_TARGETABLE
    else if RadioRestrictLocation.checked  or
            ( RadioRestrictType.Checked and NoneChecked(GroupRestrictType) ) then
    begin
        main.ActTargetType := OBJECT_TYPE_NONE;
        // The target object must be invalid (i.e. a location).
        new_lines[-2] := '// This item must target a location (not an object).';
        new_lines[-1] := 'if ( GetIsObjectValid('+s_oActTarget+') )';
        Tlilac.AddLines(new_lines[-2..last_line]);
    end
    else if RadioRestrictObject.checked then begin
        main.ActTargetType := OBJECT_TYPE_TARGETABLE;
        // The target object must not be invalid.
        new_lines[-2] := '// This item must target an object.';
        new_lines[-1] := 'if ( !GetIsObjectValid('+s_oActTarget+') )';
        Tlilac.AddLines(new_lines[-2..last_line]);
    end
    else if RadioRestrictPC.checked then begin
        main.ActTargetType := OBJECT_TYPE_CREATURE;
        // The target must be a PC.
        new_lines[-2] := '// This item must target a PC.';
        new_lines[-1] := 'if ( !GetIsPC('+s_oActTarget+') )';
        Tlilac.AddLines(new_lines[-2..last_line]);
    end
    else begin // RadioRestrictType.checked
        main.ActTargetType := OBJECT_TYPE_NONE; // To be added to later.
        // The target object type must be one of the selected types.
        // (At least one type will be selected if we made it this far.)
        new_lines[-1] := ' )';
        first_line := -1;

        // Scan the checked options.
        for index := High(RESTRICT_OBJECT) downto 0 do
            if GroupRestrictType.Checked[index] then begin
                new_lines[first_line] := '     '+s_nType+' != '+RESTRICT_OBJECT[index]+
                                         new_lines[first_line];
                Dec(first_line);
                new_lines[first_line] := '  ||';
                // Also record this in main for later use.
                main.ActTargetType := main.ActTargetType or RESTRICT_TYPE[index];
            end;
        // Add the "if" keyword.
        Inc(first_line);
        new_lines[first_line][1] := 'i';
        new_lines[first_line][2] := 'f';
        new_lines[first_line][4] := '(';

        // Start the "if" statement.
        first_line -= 2;
        new_lines[first_line+0] := '// The target must be a certain type of object.';
        new_lines[first_line+1] := s_nType+' = GetObjectType('+s_oActTarget+');';

        // Now add this contraption.
        Tlilac.AddLines(new_lines[first_line..last_line]);
    end;
end;


initialization
  {$i unique_power.lrs}
end.
