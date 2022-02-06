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


unit subracedeity;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, {ExtCtrls,} Buttons,
  LResources, ExtForm;

type

  { Tsubrace_deity }

  Tsubrace_deity = class(TExtForm)
    // Form elements
    Checksubrace: TCheckBox;
    Checkdeity: TCheckBox;
    subrace: TEdit;
    deity: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    // Event handlers
    procedure BitBtn1Click(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
  end;

{var
  subrace_deity: Tsubrace_deity;
}

// -----------------------------------------------------------------------------
implementation

uses
    {start, event,} nwn,
    constants;


// Controls the enabled state of the "Okay" button.
procedure Tsubrace_deity.ToggleOkay(Sender: TObject);
begin
    BitBtn1.Enabled := Checksubrace.checked  or  Checkdeity.checked;
end;


// Send the requested NWScript to the script window.
procedure Tsubrace_deity.BitBtn1Click(Sender: TObject);
var
    new_lines: array[0..1] of shortstring;
begin
    // Subrace:
    if Checksubrace.checked then begin
        new_lines[0] := '// Set the PC''s subrace.';
        new_lines[1] := 'SetSubRace('+s_oPC+', "'+QuoteSwap(subrace.text)+'");';
        Tlilac.AddLines(new_lines, 1, 1, TRUE);
   end;

    // Deity:
    if Checkdeity.checked then begin
        new_lines[0] := '// Set the PC''s deity.';
        new_lines[1] := 'SetDeity('+s_oPC+', "'+QuoteSwap(deity.text)+'");';
        Tlilac.AddLines(new_lines, 1, 1, FALSE);
    end
    else
        // Tell Tlilac that there will be no more lines from us.
        Tlilac.AddLinesDone();
end;


initialization
  {$i subracedeity.lrs}
end.
