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
* Much of this was trimmed when I converted the form to being modal (but then
*   a chunk got transferred from Tlilac).
* Edits of the "Important - please read" text: the (now deleted) part about not
*   being able to delay the cutscene start appears false. (Plus some minor cleanup.)
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit cut_scene;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons, ExtCtrls, LResources;

type
  Tcutscene = class(TForm)
    // Form elements;
    Memo1: TMemo;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    RadioGroup3: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    // Event handler.
    procedure BitBtn1Click(Sender: TObject);
  end;



implementation

uses {event,} nwn;


// -----------------------------------------------------------------------------


// Handles clicks of the "Okay" button.
procedure Tcutscene.BitBtn1Click(Sender: TObject);
var
    last_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // Add comment.
    new_lines[0] := '// Cutscene functions:';
    last_line := 0;

    // Add start/stop cutscene commands.
    if radiogroup1.itemindex > 0 then begin
        Inc(last_line);
        case radiogroup1.itemindex of
            1: new_lines[last_line] := 'SetCutsceneMode(oPC, TRUE);';
            2: new_lines[last_line] := 'SetCutsceneMode(oPC, FALSE);';
        end;
    end;

    // Fade to/from black.
    if radiogroup2.itemindex > 0 then begin
        Inc(last_line);
        case radiogroup2.itemindex of
            1: new_lines[last_line] := 'FadeFromBlack(oPC, FADE_SPEED_SLOW);';
            2: new_lines[last_line] := 'FadeFromBlack(oPC);';
            3: new_lines[last_line] := 'FadeToBlack(oPC, FADE_SPEED_SLOW);';
            4: new_lines[last_line] := 'FadeToBlack(oPC);';
            5: new_lines[last_line] := 'BlackScreen(oPC);';
            6: new_lines[last_line] := 'StopFade(oPC);';
        end;
    end;

    // Camera mode.
    if radiogroup3.itemindex > 0 then begin
        Inc(last_line);
        new_lines[last_line] := 'SetCameraMode(oPC, CAMERA_MODE_CHASE_CAMERA);';
    end;

    if last_line > 0 then
        // Add this to the script window.
        Tlilac.AddLines(new_lines[0..last_line], 1, last_line);
end;


initialization
  {$i cut_scene.lrs}
end.
