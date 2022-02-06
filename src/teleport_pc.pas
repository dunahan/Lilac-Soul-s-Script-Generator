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
* Added option to jump PC & associates (not other PCs in the party).
* Added option to only jump party members in the current area.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit teleport_pc;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, ExtCtrls, Buttons, nwn,
  LResources, ExtForm;

type

  { Tteleport }

  Tteleport = class(TExtForm)
    // Form elements
      GroupDestination: TGroupBox;
      CheckVFX: TCheckBox;
      GroupWho: TRadioGroup;
    RadioStored: TRadioButton;
    RadioWaypoint: TRadioButton;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBox1: TCheckBox;
    EditWaypoint: TEdit;
    // Event handlers
    procedure Button1Click(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    // Helper methods
    procedure AddAssociates(const jump_who, jump_command: shortstring;
                            const bUseVFX, bClearActions: boolean);
    function  AddDestination(out helper_func: TFuncEnum) : shortstring;
    procedure DoJump(const jump_who, jump_command, delay_duration: shortstring;
                     const bClearActions: boolean; var last_line: integer;
                     var new_lines: TStringAry);
    function  LoopStart(var last_line: integer; var new_lines: TStringAry) : shortstring;
    procedure LoopEnd();
  end;

{var
  teleport: Tteleport;
}

// -----------------------------------------------------------------------------
implementation

uses
    {event,} {start,}
    constants, delay;


// Controls the enabled state of the "Okay" button.
procedure Tteleport.ToggleOkay(Sender: TObject);
begin
    // A waypoint needs a tag.
    BitBtn1. Enabled := (EditWaypoint.text<>'') or (not RadioWaypoint.checked);
end;


// Sends the requested NWScript to the script window.
procedure Tteleport.Button1Click(Sender: TObject);
var
    bUseVFX, bAssociates, bClearActions: boolean;
    jump_who, jump_command: shortstring;
    helper_func: TFuncEnum;

    delay_start, last_line: integer;
    new_lines: array of shortstring;
begin
    bUseVFX := CheckVFX.Checked;
    bAssociates := GroupWho.ItemIndex = 1;
    bClearActions := not bUseVFX  and  not Tdelaycommand.DelaySet();

    // Max length of new_lines:
    SetLength(new_lines, 7);

    // Find the destination of the jump.
    // (Also takes care of storing the current location.)
    jump_command := AddDestination(helper_func);
    if not bClearActions then begin
        // Make this a "ClearAnd" combined function call.
        Tlilac.DefineFunc(helper_func);
        jump_command := 'ClearAnd'+jump_command;
    end;

    // Introducing the jump(s).
    case GroupWho.ItemIndex of
        0: new_lines[0] := '// Teleport the PC.';
        1: new_lines[0] := '// Teleport the PC.';
        2: new_lines[0] := '// Teleport the PC''s party (only those in the same area, though).';
        3: new_lines[0] := '// Teleport the PC''s party.';
    end;
    last_line := 0;

    // Define a visual effect for this jump?
    if bUseVFX then begin
        new_lines[1] := s_eVFX+' = '+s_EffectVisual + 'VFX_IMP_UNSUMMON);';
        last_line := 1;
    end;

    // Handle looping through the party.
    jump_who := LoopStart(last_line, new_lines); // Requires Length(new_lines) > last_line + 5.
                                                 // last_line will be at most 1 after this.
    // The NWScript.
    delay_start := last_line+1;
    if bUseVFX then begin
        // Apply an effect.
        Inc(last_line);
        new_lines[last_line] := Script.ApplyEffect(s_eVFX, jump_who, FALSE)+';';
    end;
    DoJump(jump_who, jump_command, BoolToStr(bUseVFX, '3.0', ''), bClearActions,
           last_line, new_lines); // Adds at most 2 to last_line.

    // Add what we have so far to the script window.
    Tlilac.AddLines(new_lines[0..last_line], delay_start, last_line, TRUE);


    // Handle associate jumps.
    if bAssociates then
        AddAssociates(jump_who, jump_command, bUseVFX, bClearActions);

    // End the looping through the party.
    LoopEnd();

    // Tell Tlilac that we are done adding lines.
    Tlilac.AddLinesDone();
end;


// -----------------------------------------------------------------------------


// Sends NWScript to the script window that jumps all associates of jump_who
// Assumes the user requested associates be jumped.
procedure Tteleport.AddAssociates(const jump_who, jump_command: shortstring;
                                  const bUseVFX, bClearActions: boolean);
var
    iAssoc: integer;
    delay_duration: shortstring;

    last_line: integer;
    new_lines: array of shortstring;
begin
    delay_duration := BoolToStr(bUseVFX, '3.1', ''); // A hair longer than the master's delay.
    SetLength(new_lines, 1 + 3*High(ASSOCIATE_TYPE)); // Slight overestimate.

    // The opening comment.
    new_lines[0] := '// Also teleport associates'+
                    BoolToStr(bUseVFX, ' (but no visual effect for them)', '')+'.';
    last_line := 0;

    // Loop through associate types, excluding "none" (0) and "henchman" (high-1).
    for iAssoc := 1 to High(ASSOCIATE_TYPE)-2 do begin
        // Define this associate.
        Inc(last_line);
        new_lines[last_line] := s_oHench+' = GetAssociate('+
                                                SymConst(ASSOCIATE_TYPE, iAssoc)+
                                                ', '+jump_who+');';
        // Jump it.
        DoJump(s_oHench, jump_command, delay_duration, bClearActions,
               last_line, new_lines); // Adds up to 2 to last_line.
    end;
    // Add this block.
    Tlilac.AddLines(new_lines[0..last_line], 2, last_line, TRUE);

    // Now the henchman loop.
    SetLength(new_lines, 5);
    new_lines[0] := '// Support for multiple henchmen (includes horses).';
    new_lines[1] := s_nHench+' = 1;';
    new_lines[2] := s_oHench+' = GetHenchman('+jump_who+', 1);';
    new_lines[3] := 'while ( '+s_oHench+' != '+s_OBJECT_INVALID+' )';
    new_lines[4] := '{';
    // Add this block (to take advantage of automatic indentation).
    Tlilac.AddLines(new_lines, -1, -1, TRUE);

    // Inside the loop.
    //SetLength(new_lines, 4); -- Not necessary here; length 5 from before is fine.
    last_line := -1;
    DoJump(s_oHench, jump_command, delay_duration, bClearActions,
           last_line, new_lines); // Adds 1 or 2 to last_line.
    new_lines[last_line+1] := '// Next henchman.';
    new_lines[last_line+2] := s_oHench+' = GetHenchman('+jump_who+', ++'+s_nHench+');';
    // Add this block.
    Tlilac.AddLines(new_lines[0..last_line+2], 0, last_line, TRUE);

    // End the henchman loop.
    Tlilac.EndBlock();
end;


// Defines in the script window the destination of the teleport, and returns
// the "JumpTo" command.
// _helper_func_ gets set to the function to define if prepending 'ClearAnd' to
// the "JumpTo" command.
// Also takes care of storing the current location if requested (so that the
// local variable involved only needs to be named in one Pascal function).
function Tteleport.AddDestination(out helper_func: TFuncEnum) : shortstring;
const
    // The name of the local variable storing the location from which we teleport.
    local_name = '"ls_stored_loc"';
var
    last_line: integer;
    new_lines: array[0..5] of shortstring;
begin
    // The opening comment.
    new_lines[0] := '// Find the location to which to teleport.';

    // Jumping to waypoint or location?
    if RadioWaypoint.checked then begin
        new_lines[1] := s_oTarget+' = '+s_GetWaypoint + QuoteSwap(EditWaypoint.text)+'");';
        last_line := 1;
        result := 'JumpToObject('+s_oTarget+')';
        helper_func := FUNC_CLEAR_JUMP_OBJECT;
    end
    else begin
        new_lines[1] := s_lTarget+' = GetLocalLocation('+s_oPC+', '+local_name+');';
        // Verify the destination.
        new_lines[2] := '// Verify that the location is valid before attempting to teleport.';
        new_lines[3] := '// (The script will stop here if no location was previously stored.)';
        new_lines[4] := 'if ( GetAreaFromLocation('+s_lTarget+') == '+s_OBJECT_INVALID+' )';
        new_lines[5] := s_Return;
        last_line := 5;
        result := 'JumpToLocation('+s_lTarget+')';
        helper_func := FUNC_CLEAR_JUMP_LOCATION;
    end;

    // Send this to the script window.
    Tlilac.AddLines(new_lines[0..last_line]);


    // Store the current location?
    if checkbox1.checked then begin
        new_lines[0] := '// Save the PC''s current location for the return trip.';
        new_lines[1] := 'SetLocalLocation('+s_oPC+', '+local_name+', '+
                                          s_GetLocation + s_oPC+'));';
        Tlilac.AddLines(new_lines[0..1]); // Not delayed.
        // NOTE: This is storing the current location, which might not be where
        // the PC actually departs from if the jump gets delayed. Probably a good
        // idea in case the PC ends up between areas when the jump fires.
    end;

end;


// Augments new_lines (and updates last_line) with the NWScript line(s) that
// causes jump_who to execute the command jump_command.
// If delay_duration is not '', then it is the number of seconds to delay jump_command.
// If bClearActions is true, then ClearAllActions() will be called first (not
// delayed though, since we won't need that case).
//
// Fills at most 2 lines.
procedure Tteleport.DoJump(const jump_who, jump_command, delay_duration: shortstring;
                           const bClearActions: boolean; var last_line: integer;
                           var new_lines: TStringAry);
begin
    if bClearActions then begin
        // Separate line for clearing actions.
        Inc(last_line);
        new_lines[last_line] := s_AssignCommand + jump_who+', ClearAllActions());';
    end;

    // The actual jump.
    Inc(last_line);
    new_lines[last_line] := s_AssignCommand + jump_who+', '+jump_command+')';
    // Delayed?
    if delay_duration <> '' then
        new_lines[last_line] := 'DelayCommand('+delay_duration+', '+new_lines[last_line]+')';
    // End the line.
    new_lines[last_line] += ';';
end;


// Continues the provided lines, and starts a loop through the PC's party, if
// that was requested.
// Submits the lines to the script window iff there is a loop, resetting last_line to -1.
// Returns the variable to use for jumping ('oParty' if there is a loop; 'oPC' otherwise.
//
// This function can add up to 5 lines to new_lines, and that space must be
// allocated in advance.
function Tteleport.LoopStart(var last_line: integer; var new_lines: TStringAry) : shortstring;
var
    bAreaCheck: boolean;
begin
    bAreaCheck  := GroupWho.ItemIndex = 2;

    // Quick case: no loop, so nothing to do. Just set s_oPC as the variable to use.
    if GroupWho.ItemIndex < 2 then begin
        result := s_oPC;
        exit;
    end;

    // Store the area in a variable?
    if bAreaCheck then begin
        Inc(last_line);
        new_lines[last_line] := s_oArea+' = '+s_GetAreaPC+';';
    end;

    // Loop through the party.
    new_lines[last_line+1] := '// Loop through the PC''s party.';
    new_lines[last_line+2] := s_oParty+' = GetFirstFactionMember('+s_oPC + s_comma_FALSE+');';
    new_lines[last_line+3] := 'while ( '+s_oParty+' != '+s_OBJECT_INVALID+' )';
    new_lines[last_line+4] := '{';
    last_line += 4;

    // Submit what we have so far (to get automatic indentation).
    Tlilac.AddLines(new_lines[0..last_line], -1, -1, TRUE);

    // Same area check?
    if bAreaCheck then begin
        new_lines[0] := '// Only teleport those in the same area.';
        new_lines[1] := 'if ( GetArea('+s_oParty+') == '+s_oArea+' )';
        new_lines[2] := '{';

        // Submit this (to get automatic indentation).
        Tlilac.AddLines(new_lines[0..2], -1, -1, TRUE);
    end;

    // No lines in new_lines at this point.
    last_line := -1;

    // We will use 'oParty' inside the loop.
    result := s_oParty;
end;


procedure Tteleport.LoopEnd();
var
    bAreaCheck: boolean;

    new_lines: array[0..1] of shortstring;
begin
    bAreaCheck  := GroupWho.ItemIndex = 2;

    // Quick case: no loop, so nothing to do.
    if GroupWho.ItemIndex < 2 then
        exit;

    // End the same area check.
    if bAreaCheck then
        Tlilac.EndBlock();

    // End of the loop through the party.
    new_lines[0] := '// Update the loop.';
    new_lines[1] := s_oParty+' = GetNextFactionMember('+s_oPC + s_comma_FALSE+');';
    Tlilac.AddLines(new_lines[0..1], -1, -1, TRUE);

    // And end the automatic indentation for the loop.
    Tlilac.EndBlock();
end;


initialization
  {$i teleport_pc.lrs}
end.
