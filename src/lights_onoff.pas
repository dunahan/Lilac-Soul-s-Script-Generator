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
*   of simulated modal, and converted simulated radio buttons into radio buttons.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit lights_onoff;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  Spin, StdCtrls, ExtCtrls, Buttons, nwn,
  LResources, QueueForm, Forms;

type

  { Tlights }

  Tlights = class(TQueueForm)
    // Form elements.
    EditTagged: TEdit;
    EditTagAll: TEdit;
    GroupTarget: TGroupBox;
    LabelTag: TLabel;
    LabelNth: TLabel;
    lightchoice: TRadioGroup;
    Memo2: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    RadioOwner: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTagAll: TRadioButton;
    RadioTargeted: TRadioButton;
    SpinNth: TSpinEdit;
    TextSameArea: TStaticText;
    // Event handlers.
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SpinNthChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  protected
    // Helper methods
    procedure ClearForm(); override;
    procedure QueueThis(); override;
    procedure SendQueue(); override;

  private
    // The queue.
    ListTag:    array of shortstring;
    ListNth:    array of shortint; // Can be made a larger integer if needed.
    ListAction: array of shortint; // Can be made a larger integer if needed.

    // Helper methods
    procedure SendTagLoop(const sTag: shortstring; action: shortint);
    procedure ScriptLight(const sLight: shortstring; action: shortint;
                          var last_line: integer; var new_lines:TStringAry);
    procedure ScriptRecomputeLighting(const sLight: shortstring; bSingleLight: boolean);
  end;

{var
  lights: Tlights;}


implementation

uses
    {event,} start, constants;


// -----------------------------------------------------------------------------


// Configures the form based on current circumstances.
procedure Tlights.FormCreate(Sender: TObject);
begin
    // Initialize the queue.
    SetLength(ListTag, 0);
    // ListAction and ListNth are assumed the same length.

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, nil, OBJECT_TYPE_PLACEABLE);
    main.InitActivationRadios(nil, RadioOwner, nil, RadioTargeted, OBJECT_TYPE_PLACEABLE);
end;


// Lets Tlilac know that the form is done.
procedure Tlights.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    Tlilac.AddLinesDone();
end;


// Updates the "st/nd/rd/th" label (and other standard stuff).
procedure Tlights.SpinNthChange(Sender: TObject);
var
    iNth: integer;
begin
    iNth := SpinNth.Value;

    // Which label?
    if iNth div 10 = 1 then
        LabelNth.Caption := 'th' // e.g. 11th, not 11st.
    else
        case iNth mod 10 of
            1:   LabelNth.Caption := 'st';
            2:   LabelNth.Caption := 'nd';
            3:   LabelNth.Caption := 'rd';
            else LabelNth.Caption := 'th';
        end;

    // Select the associated radio button.
    RadioTagged.Checked := true;

    // Update the okay buttons.
    ToggleOkay(Sender);
end;


// Enables/disables the "Okay" buttons as appropriate.
procedure Tlights.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // A tagged object needs a tag.
    if      RadioTagged.Checked and (EditTagged.text = '') then
        bEnable := false
    else if RadioTagAll.Checked and (EditTagAll.text = '') then
        bEnable := false
    else
        // Passed all tests.
        bEnable := true;

    // Update the "Okay" buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------


// Clears the form for new input.
// (Well, actually it changes the specification of the target, so that some
// settings can be re-used. LS reset too much, in my opinion.)
procedure Tlights.ClearForm();
begin
    // Repeating the same target does not make a lot of sense.
    if RadioOwner.Checked or RadioTargeted.Checked then
        RadioTagged.Checked := true
    else if RadioTagAll.Checked then
        EditTagAll.Text := ''
    else if SpinNth.Value = 1 then
        EditTagged.text := ''
    else begin
        SpinNth.Value := SpinNth.Value + 1;
        SpinNthChange(SpinNth);
    end;
end;


// Records the info in the form for later processing.
procedure Tlights.QueueThis();
var
    light: shortstring;
    list_length: integer;
begin
    // Special case for all objects with a tag.
    if RadioTagAll.Checked then begin
        // This option does not fit nicely into the queue, so flush the queue.
        SendQueue();
        SetLength(ListTag, 0);

        // The details are deferred to another procedure.
        SendTagLoop(QuoteSwap(EditTagAll.Text), lightchoice.itemindex);

        // Done.
        exit;
    end;

    // What is having its lighting changed?
    if      RadioTargeted.Checked then  light := s_oActTarget
    else if RadioSpawn.Checked    then  light := s_oSpawn
    else if RadioTagged.Checked   then  light := TAG_FLAG + QuoteSwap(EditTagged.text)
    else // RadioOwner.Checked
        if not Tlilac.WillBeAssigned() then   light := s_OBJECT_SELF
        else begin Tlilac.Declare(VAR_oSELF); light := s_oSelf;       end;

    // Make space for recording the current info.
    list_length := Length(ListTag);
    SetLength(ListTag,    list_length+1);
    SetLength(ListAction, list_length+1);
    SetLength(ListNth,    list_length+1);
    // Save the current info.
    ListTag[list_length]    := light;
    ListAction[list_length] := lightchoice.itemindex;
    ListNth[list_length]    := SpinNth.Value;
end;


// Send the queued info to the script window.
procedure Tlights.SendQueue();
var
    iLight, last_light: integer;
    sLight: shortstring;

    last_line: integer;
    new_lines: array of shortstring;
begin
    last_light := Length(ListTag) - 1;

    // Make sure there is something to send.
    if last_light < 0 then
        exit;

    // Allocate space (Comment plus up to five lines per light).
    SetLength(new_lines, 1 + 5*(1+last_light));

    // The opening comment.
    new_lines[0] := '// Flip some light switches.';
    last_line := 0;

    // Loop through the lights to switch.
    for iLight := 0 to last_light do begin
        // Retrieve the current light.
        if not StartsWith(ListTag[iLight], TAG_FLAG) then
            sLight := ListTag[iLight]
        else begin
            sLight := s_oTarget;
            // Define oTarget.
            Inc(last_line);
            new_lines[last_line] := s_oTarget+' = '+s_GetObject +
                                    copy(ListTag[iLight], 1+Length(TAG_FLAG), 32)+'"'+  // Max length of a tag is 32.
                                    BoolToStr(ListNth[iLight] > 1,
                                              ', '+IntToStr(ListNth[iLight]),
                                              '') +
                                    ');';
        end;

        // Script this (up to 4 lines added).
        ScriptLight(sLight, ListAction[iLight], last_line, new_lines);
    end;// for iLight

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], 1, last_line, true);

    // Add the intruction to recompute the lighting.
    ScriptRecomputeLighting(sLight, last_light = 0);
end;


// Sends to the script window a loop through all objects with the specified tag.
// _action_ is 0/1/2 meaning on/off/toggle.
procedure Tlights.SendTagLoop(const sTag: shortstring; action: shortint);
var
    last_line: integer;
    new_lines: array of shortstring;
begin
    // Max needed length of the array is 5, but it needs to be dynamic in order
    // to be used as a parameter to ScriptLight().
    SetLength(new_lines, 5);

    // The opening comment.
    case action of
        0: new_lines[0] := '// Turn on all "'+sTag+'" lights.';
        1: new_lines[0] := '// Turn off all "'+sTag+'" lights.';
        2: new_lines[0] := '// Toggle all "'+sTag+'" lights.';
    end;

    // The beginning of the loop.
    new_lines[1] := s_nCount+' = 1;';
    new_lines[2] := s_oTarget+' = '+s_GetObject + sTag+'", 1);';
    new_lines[3] := 'while ( '+s_oTarget+' != '+s_OBJECT_INVALID+' )';
    new_lines[4] := '{';
    Tlilac.AddLines(new_lines[0..4]);

        // The inside of the loop.
        last_line := 0;
        ScriptLight(s_oTarget, action, last_line, new_lines);
        Tlilac.AddLines(new_lines[1..last_line], 1, last_line, true);

        // The end of the loop.
        new_lines[0] := '// Update the loop.';
        new_lines[1] := s_oTarget+' = '+s_GetObject + sTag+'", ++'+s_nCount+');';
        Tlilac.AddLines(new_lines[0..1]);

    // Close the loop.
    new_lines[0] := '}';
    Tlilac.AddLines(new_lines[0..0]);

    // Add the intruction to recompute the lighting.
    ScriptRecomputeLighting(s_oTarget, false);
end;


// Adds the NWScript for switching light sLight, with on/off/toggle specified
// by _action_ (0/1/2, respectively).
// Uses up to 4 lines.
//
// For the "toggle" option, the produced NWScript looks like:
//
//    bCurState = GetPlaceableIllumination(oTarget);
//    AssignCommand(oTarget, PlayAnimation(bCurState ? ANIMATION_PLACEABLE_DEACTIVATE :
//                                                     ANIMATION_PLACEABLE_ACTIVATE));
//    SetPlaceableIllumination(oTarget, !bCurState);
//
procedure Tlights.ScriptLight(const sLight: shortstring; action: shortint;
                              var last_line: integer; var new_lines:TStringAry);
const
    s_ACTIVATE   = 'ANIMATION_PLACEABLE_ACTIVATE';
    s_DEACTIVATE = 'ANIMATION_PLACEABLE_DEACTIVATE';
    s_PlayAnimation = 'PlayAnimation(';
    s_PlayIndent    = '              '; // Exactly as long as s_PlayAnimation.
var
    indent, suffix: shortstring;
    param1:  shortstring; // Parameter to PlayAnimation()
    param1a: shortstring; // Second part of parameter to PlayAnimation, or ''
    param2:  shortstring; // Parameter to SetPlaceableIllumination()
begin
    // What do we do with this light? (Define some parameters.)
    case action of
        0: begin
            param1  := s_ACTIVATE;
            param1a := '';
            param2  := s_comma_TRUE;
        end;

        1: begin
            param1  := s_DEACTIVATE;
            param1a := '';
            param2  := s_comma_FALSE;
        end;

        2: begin
            param1  := s_bCurState+' ? '+s_DEACTIVATE+' :';
            param1a := Spaces(Length(s_bCurState)+3) + s_ACTIVATE;
            param2  := ', !'+s_bCurState;

            // Also define bCurState.
            Inc(last_line);
            new_lines[last_line] :=
                    s_bCurState+' = GetPlaceableIllumination('+sLight+');';
        end;
    end;

    // NWSCRIPT:

    // Play the associated animation.
    Inc(last_line);
    new_lines[last_line] := Script.AssignCommandML(sLight, s_PlayAnimation + param1, indent, suffix);
    if param1a <> '' then begin
        Inc(last_line);
        new_lines[last_line] := indent + s_PlayIndent + param1a;
    end;
    new_lines[last_line] += suffix + ');'; // Technically, ')'+suffix+';', but same result.

    // Set the illumination.
    Inc(last_line);
    new_lines[last_line] := 'SetPlaceableIllumination('+sLight + param2+');';
end;


// Adds the line to recompute static lighting in the area of the specified light.
// This is needed to have the lighting changes affect clients currently displaying
// that area, but only is needed per area, rather than per light.
procedure Tlights.ScriptRecomputeLighting(const sLight: shortstring; bSingleLight: boolean);
var
    last_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    new_lines[0] := '// Apply the results of the above lighting changes to clients showing the area.';
    if bSingleLight then
        last_line := 1
    else begin
        new_lines[1] := '// (All of the preceding lights must be in the same area.)';
        last_line := 2;
    end;
    new_lines[last_line] := 'RecomputeStaticLighting(GetArea('+sLight+'));';

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


initialization
  {$i lights_onoff.lrs}
end.
