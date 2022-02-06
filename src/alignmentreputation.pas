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
* Added option to suppress the "knock" effect on party members.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit alignmentreputation;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, ComCtrls, ExtCtrls, Buttons,
  LResources;

type

  { Tadjalignment }

  Tadjalignment = class(TForm)
    adjustbar: TTrackBar;
    CheckBoxParty: TCheckBox;
    direction: TRadioGroup;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    adjust: TStaticText;
    // Event handlers
    procedure Button1Click(Sender: TObject);
    procedure adjustbarChange(Sender: TObject);
  end;


// -----------------------------------------------------------------------------
implementation

uses
    {start,} nwn,
    constants;


// Handles clicks of the "Okay" button.
procedure Tadjalignment.Button1Click(Sender: TObject);
var
    param, only: shortstring;
    new_lines: array[0..1] of shortstring;
begin
    // Note if only the target gets adjusted.
    if CheckBoxParty.Checked then begin
        param := '';
        only := '';
    end
    else begin
        param := s_comma_FALSE;
        only := '(only) ';
    end;

    // The lines to add.
    new_lines[0] := '// The PC '+only +'has become more '+ALIGNMENT_NAME[direction.itemindex]+'.';
    new_lines[1] := 'AdjustAlignment('+s_oPC+', '+
                                     SymConst(ALIGNMENT_NAME, direction.itemindex)+
                                     ', '+adjust.caption + param+');';

    // Add the lines.
    Tlilac.AddLines(new_lines, 1, 1);
end;


// Updates the displayed value of the slider.
procedure Tadjalignment.adjustbarChange(Sender: TObject);
begin
    adjust.caption := inttostr(adjustbar.position);
end;


initialization
  {$i alignmentreputation.lrs}
end.
