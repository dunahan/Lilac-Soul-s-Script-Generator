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


unit pcgold_int;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, ExtCtrls, Spin, Buttons,
  LResources,
  {start,} nwn;


// -----------------------------------------------------------------------------
type

  { Tgoldint }

  Tgoldint = class(TForm)
    // Form elements.
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    // Event handlers.
    procedure Button1Click(Sender: TObject);
  end;


// -----------------------------------------------------------------------------
implementation

uses
    constants;


// Handles clicks of the "OK" button.
procedure Tgoldint.Button1Click(Sender: TObject);
var
    func_call: shortstring;     party:    shortstring;
    compare:   string[3];       at_least: shortstring;
    new_lines: array[0..2] of shortstring;
begin
    // Party or PC?
    case radiogroup1.itemindex of
        0: begin func_call := 'GetGold';         party := 'The PC ';          end;
        1: begin func_call := 'GetFactionGold';  party := 'The PC''s party '; end;
    end;
    func_call += '('+s_oPC+') ';

    // Which comparison?
    case radiogroup2.itemindex of
        0: begin compare := '< ';      at_least := 'at least ';  end;
        1: begin compare := '>= ';     at_least := 'less than '; end;
    end;

    // The lines to add to the script.
    new_lines[0] := '// ' +party +'must have '+at_least +spinedit1.Text+' gold.';
    new_lines[1] := 'if ( '+func_call +compare +spinedit1.Text+' )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


initialization
  {$i pcgold_int.lrs}
end.
