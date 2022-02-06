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


unit numitems_int;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, Spin, Buttons,
  LResources,
  {start,} nwn, palettetool, ExtForm;

// -----------------------------------------------------------------------------
type

  { Tnumitems }

  Tnumitems = class(TExtForm)
    // Form elements.
    Edit1: TEdit;
    EditName: TEdit;
    LabelPalette: TLabel;
    LabelName: TLabel;
    SpinEdit1: TSpinEdit;
    ComboBox1: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn4: TBitBtn;
    // Event handlers.
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  end;


// -----------------------------------------------------------------------------
implementation

uses
    constants;


// Handles clicks of the "OK" button.
// (Closes this window and sends a script snippet to the script window.)
procedure Tnumitems.Button1Click(Sender: TObject);
var
    num_string: shortstring;
    copies_of:  shortstring;
    item_name:  shortstring;
    compare:    string[3];      at_least: shortstring;
    new_lines:  array[0..2] of shortstring;
begin
    num_string := inttostr(spinedit1.value);
    if spinedit1.value = 1 then
        copies_of := ' copy of '
    else
        copies_of := ' copies of ';

    // Get something to use as the item name.
    if EditName.Text <> '' then
        item_name := EditName.Text
    else
        item_name := Edit1.Text;

    // Find the comparison to use.
    case combobox1.itemindex of
        0: begin  compare := '< ';      at_least := 'at least ';  end;
        1: begin  compare := '<= ';     at_least := 'more than '; end;
        2: begin  compare := '> ';      at_least := 'at most ';   end;
        3: begin  compare := '>= ';     at_least := 'less than '; end;
        4: begin  compare := '!= ';     at_least := 'exactly ';   end;
    end;

    // The lines to add to the script.
    Tlilac.Include(INC_PLOT);
    new_lines[0] := '// The PC must have '+at_least +num_string+ copies_of +item_name+'.';
    new_lines[1] := 'if ( GetNumItems(oPC, "'+QuoteSwap(edit1.text)+'") '+
                          compare +num_string+ ' )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Handles clicks of the "Palette" button
procedure Tnumitems.Button4Click(Sender: TObject);
begin
    // Call up the palette window.
    TPaletteWindow.Load(Edit1, EditName, SEARCH_ITEMS);
end;


initialization
  {$i numitems_int.lrs}

end.
