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
* Much of this was trimmed when I converted the form to being modal.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit random_int;


interface

uses
    {Windows,} {Messages,} SysUtils, {Classes,} {Graphics,} {Controls,}
    Forms, {Dialogs,} {start,}
    StdCtrls, Spin, Buttons, LResources,
    nwn;

// -----------------------------------------------------------------------------
type

  { TRandomint }

  TRandomint = class(TForm)
    // Form elements.
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    // Event handlers.
    procedure ButtonOKClick(Sender: TObject);
  end;


// -----------------------------------------------------------------------------
implementation

uses
    constants;


// Handles clicks of the "OK" button by sending text to the script window,
// then closing.
procedure TRandomint.ButtonOKClick(Sender: TObject);
var
    new_lines : array[0..2] of shortstring;
begin
    // Add appropriate code to the script.
    new_lines[0] := '// Show this conversation node only ' +
                    inttostr(spinedit1.value) + '% of the time.';
    new_lines[1] := 'if ( d100() > ' + inttostr(spinedit1.value) + ' )';
    new_lines[2] := s_ReturnFalse;
    Tlilac.AddLines(new_lines);
end;


initialization
  {$i random_int.lrs}
end.
