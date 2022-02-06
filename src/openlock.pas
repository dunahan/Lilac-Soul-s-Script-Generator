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
* Removed some unnecssary restrictions.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit openlock;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, Buttons, ExtCtrls, Spin, nwn,
  LResources, ExtForm;

type

  { Tlockopen }

  Tlockopen = class(TExtForm)
    // Form elements
      closedoor: TCheckBox;
      EditTagged: TEdit;
      GroupDoor: TGroupBox;
      GroupActions: TGroupBox;
      GroupAllowLock: TRadioGroup;
      lock: TCheckBox;
      opendoor: TCheckBox;
      GroupRequireKey: TRadioGroup;
      RadioOwner: TRadioButton;
      RadioSpawn: TRadioButton;
      RadioTagged: TRadioButton;
      RadioTargeted: TRadioButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckKeyTag: TCheckBox;
    EditKeyTag: TEdit;
    CheckDCLock: TCheckBox;
    CheckDCUnlock: TCheckBox;
    SpinDCLock: TSpinEdit;
    SpinDCUnlock: TSpinEdit;
    unlock: TCheckBox;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure Button1Click(Sender: TObject);

  private
    // Helper methods.
    function  GetCommentAction() : shortstring;
    procedure ScriptClose(const door:shortstring; var new_lines:TStringAry;  var last_line:integer);
    procedure ScriptLock(const door:shortstring; var new_lines:TStringAry;  var last_line:integer);
    procedure ScriptOpen(const door:shortstring; var new_lines:TStringAry;  var last_line:integer);
    procedure ScriptUnlock(const door:shortstring; var new_lines:TStringAry;  var last_line:integer);
  end;

{var
  lockopen: Tlockopen;
}


// -----------------------------------------------------------------------------

implementation

uses
    {event,} start,
    constants, delay;

const
    OBJECT_TYPE_DOOR_PLACEABLE = OBJECT_TYPE_DOOR or OBJECT_TYPE_PLACEABLE;


// -----------------------------------------------------------------------------

// Configures the form based on current circumstances.
procedure Tlockopen.FormCreate(Sender: TObject);
begin
    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, nil, OBJECT_TYPE_DOOR_PLACEABLE);
    main.InitActivationRadios(nil, RadioOwner, nil, RadioTargeted, OBJECT_TYPE_DOOR_PLACEABLE);

    // Make sure the pre-selected option is one that is visible.
    if RadioOwner.Checked and not RadioOwner.Visible then
        RadioTagged.Checked := true;
end;


// Controls the enabled state of the "Okay" button.
procedure Tlockopen.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // Something to do must be selected.
    if not (unlock.checked or lock.checked or opendoor.checked or closedoor.checked or
           (GroupRequireKey.ItemIndex > 0) or (GroupAllowLock.ItemIndex > 0) or
            CheckKeyTag.checked or CheckDCLock.checked or CheckDCUnlock.checked) then
        bEnable := false

    // Tagged objects need a tag.
    else if RadioTagged.Checked and (EditTagged.text = '') then
        bEnable := false

    else
        // Passed all tests.
        bEnable := true;

    // Enable/disable the button.
    BitBtn1.Enabled := bEnable;
end;


// Submits the requested NWScript to the script window.
procedure Tlockopen.Button1Click(Sender: TObject);
var
    door_code: TObjectEnum;
    door:      shortstring;
    door_def:  shortstring = '';
    do_this, what: shortstring;

    start_line, last_line: integer;
    new_lines: array of shortstring;
begin
    // We need a dynamic array to pass it as a parameter, but we know a max length.
    SetLength(new_lines, 6);

    // Which door are we using?
    door_code := GetChosenObject(RadioOwner, nil, nil, RadioTargeted,
                                 RadioTagged, nil, RadioSpawn);
    // Declare a variable if needed.
    if door_code = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // Convert the code to strings.
    door := ObjectVar(door_code);
    what := ObjectDesc(door_code, EditTagged.Text, TRUE);
    if door_code = E_CHOOSE_Tagged then
        door_def := s_oTarget+' = '+s_GetObject + QuoteSwap(EditTagged.Text)+'");';


    // The primary four actions (unlock, open, close, and lock).
    do_this := GetCommentAction();
    if do_this <> '' then begin
        // The opening comment.
        new_lines[0] := '// '+do_this +what+'.';
        start_line := 1;

        // Define oTarget?
        if door_def <> '' then begin
            new_lines[1] := door_def;
            start_line := 2;
            // Save some effort later.
            door_def := '';
        end;
        last_line := start_line-1;

        // The order we do things might depend on the delay.
        // (Delayed commands are LIFO, while assigned and regular commands are FIFO.)
        // (Coding for LIFO/FIFO is not recommended practice, but the Generator
        //  has its limits.)
        if Tdelaycommand.DelayTime() > 0 then begin
            ScriptLock(door, new_lines, last_line);
            ScriptClose(door, new_lines, last_line);
            ScriptOpen(door, new_lines, last_line);
            ScriptUnlock(door, new_lines, last_line);
        end
        else begin
            ScriptUnlock(door, new_lines, last_line);
            ScriptOpen(door, new_lines, last_line);
            ScriptClose(door, new_lines, last_line);
            ScriptLock(door, new_lines, last_line);
        end;

        // Add the lines.
        Tlilac.Addlines(new_lines[0..last_line], start_line, last_line);
    end;

    // Required key
    if (GroupRequireKey.ItemIndex > 0) or CheckKeyTag.Checked then begin
        new_lines[0] := '// Setting the requirement for a specific key to unlock '+what+'.';
        start_line := 1;

        // Define oTarget?
        if door_def <> '' then begin
            new_lines[1] := door_def;
            start_line := 2;
            // Save some effort later.
            door_def := '';
        end;
        last_line := start_line-1;

        // Set if the key is required.
        if GroupRequireKey.ItemIndex > 0 then begin
            Inc(last_line);
            new_lines[last_line] :=
                'SetLockKeyRequired('+door +
                    BoolToStr(GroupRequireKey.ItemIndex = 1, '', s_comma_FALSE)+');';
        end;

        // Set which key is required.
        if CheckKeyTag.checked then begin
            Inc(last_line);
            new_lines[last_line] :=
                'SetLockKeyTag('+door+', "'+QuoteSwap(EditKeyTag.text)+'");';
        end;

        // Add the lines.
        Tlilac.Addlines(new_lines[0..last_line], start_line, last_line);
    end;

    // Lockable and DCs
    if (GroupAllowLock.ItemIndex > 0) or CheckDCLock.Checked or CheckDCUnlock.Checked then begin
        new_lines[0] := '// Setting lock data for '+what+'.';
        start_line := 1;

        // Define oTarget?
        if door_def <> '' then begin
            new_lines[1] := door_def;
            start_line := 2;
        end;
        last_line := start_line-1;

        // Set if locking is allowed.
        if GroupAllowLock.ItemIndex > 0 then begin
            Inc(last_line);
            new_lines[last_line] :=
                'SetLockLockable('+door +
                    BoolToStr(GroupAllowLock.ItemIndex = 1, '', s_comma_FALSE)+');';
        end;

        // Set the lock DC
        if CheckDCLock.checked then begin
            Inc(last_line);
            new_lines[last_line] :=
                'SetLockLockDC('+door+', '+IntToStr(SpinDCLock.value)+');';
        end;

        // Set the unlock DC
        if CheckDCUnlock.checked then begin
            Inc(last_line);
            new_lines[last_line] :=
                'SetLockUnlockDC('+door+', '+IntToStr(SpinDCUnlock.value)+');';
        end;

        // Add the lines.
        Tlilac.Addlines(new_lines[0..last_line], start_line, last_line);
    end;
end;


// -----------------------------------------------------------------------------


// Returns a word or phrase (ending with a space) that describes whether we
// are to unlock, open, close, and/or lock something.
// Returns '' if none of those actions were requested.
// (A separate function to make the major function easier to read.)
function Tlockopen.GetCommentAction(): shortstring;
begin
    // Unlock?
    if unlock.Checked then
        result := 'Unlock '
    else
        result := '';

    // Open?
    if opendoor.Checked then begin
        if result = '' then
            result := 'Open '
        else
            result += 'and open ';
    end;

    // Close?
    if closedoor.Checked then begin
        if result = '' then
            result := 'Close '
        else
            result += 'and close ';
    end;

    // Lock?
    if lock.Checked then begin
        if result = '' then
            result := 'Lock '
        else
            result += 'and lock ';
    end;
end;


// Adds the scripting line for closing a door to new_lines, if it was requested.
procedure Tlockopen.ScriptClose(const door:shortstring; var new_lines:TStringAry;  var last_line:integer);
begin
    if closedoor.Checked then begin
        Inc(last_line);
        new_lines[last_line] := Script.AssignCommand(door, 'ActionCloseDoor('+door+')')+';';
    end;
end;


// Adds the scripting line for locking a door/chest to new_lines, if it was requested.
procedure Tlockopen.ScriptLock(const door:shortstring; var new_lines:TStringAry;  var last_line:integer);
begin
    if lock.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetLocked('+door + s_comma_TRUE+')';

        // Oddball timing issue: if locking and opening the same door, we should
        // assign the lock command so that it occurs after the (assigned) open
        // command.
        if opendoor.Checked then
            new_lines[last_line] := Script.AssignCommand(door, new_lines[last_line]);

        // End with a semicolon.
        new_lines[last_line] += ';';
    end;
end;


// Adds the scripting line for opening a door to new_lines, if it was requested.
procedure Tlockopen.ScriptOpen(const door:shortstring; var new_lines:TStringAry;  var last_line:integer);
begin
    if opendoor.Checked then begin
        Inc(last_line);
        new_lines[last_line] := Script.AssignCommand(door, 'ActionOpenDoor('+door+')')+';';
    end;
end;


// Adds the scripting line for unlocking a door/chest to new_lines, if it was requested.
procedure Tlockopen.ScriptUnlock(const door:shortstring; var new_lines:TStringAry;  var last_line:integer);
begin
    if unlock.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetLocked('+door + s_comma_FALSE+');';
    end;
end;


initialization
  {$i openlock.lrs}
end.
