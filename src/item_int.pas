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
* Added "either" slots.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit item_int;


interface

uses
    {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
    StdCtrls, ExtCtrls, Buttons,
    LResources,
    nwn, {start,} palettetool, ExtForm, Classes;


// -----------------------------------------------------------------------------
type

  { Titemint }

  Titemint = class(TExtForm)
    // Form elements.
    Edit1: TEdit;
    EditName: TEdit;
    Label1: TLabel;
    LabelPallete: TLabel;
    LabelName: TLabel;
    RadioGroup1: TRadioGroup;
    BitBtn4: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    // Event handlers.
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;


// -----------------------------------------------------------------------------
implementation

uses
    constants;

// Initializes the form with data from the constants unit
procedure Titemint.FormCreate(Sender: TObject);
begin
    // Load the slot names.
    LoadConstants(ComboBox1.Items, INVENTORY_SLOT);
    // Add the multiple choice slots.
    // These must be done in order from largest index to smallest!
    ComboBox1.Items.Insert(INVENTORY_SLOT_ANY_CREATURE, INVENTORY_SLOT_ANY_CREATURE_NAME);
    ComboBox1.Items.Insert(INVENTORY_SLOT_EITHER_RING, INVENTORY_SLOT_EITHER_RING_NAME);
    ComboBox1.Items.Insert(INVENTORY_SLOT_EITHER_HAND, INVENTORY_SLOT_EITHER_HAND_NAME);
    // Supply a default slot.
    ComboBox1.ItemIndex := 0;
end;


// Handles the clicking of the "OK" button.
procedure Titemint.Button1Click(Sender: TObject);
var
    slot:        integer;
    num_slots:   integer;
    item_name:   shortstring;
    item_tag:    shortstring;
    last_line:   integer;
    new_lines:   array[0..4] of shortstring;
begin
    // Shorter way to refer to the item tag.
    item_tag := QuoteSwap(edit1.text);
    // Get something to use as the item name.
    item_name := EditName.Text;
    if item_name = '' then
        // Backup plan: use the tag.
        item_name := '"'+Edit1.Text+'"';


    // Determine which kind of scripting lines to add.
    if checkbox1.checked then begin
        // The script should check to see if the given item is equipped in a given slot.
        new_lines[0] := '// The PC must have ' + item_name + ' equipped.';
        slot := ComboBox1.ItemIndex;
        num_slots := 1;

        // Special handling for the "either" slots.
        // The order is important here, as the smaller constants must come first.
        // Hands
        if slot = INVENTORY_SLOT_EITHER_HAND then
            num_slots := 2
        else if slot > INVENTORY_SLOT_EITHER_HAND then
            slot -= 1;
        // Rings
        if slot = INVENTORY_SLOT_EITHER_RING then
            num_slots := 2
        else if slot > INVENTORY_SLOT_EITHER_RING then
            slot -= 1;
        // Creature weapons.
        if slot = INVENTORY_SLOT_ANY_CREATURE then
            num_slots := 3
        else if slot > INVENTORY_SLOT_ANY_CREATURE then
            slot -= 1;

        // First coding line.
        new_lines[1] := 'if ( "'+item_tag+'" != GetTag('+
                              Script.GetItemInSlot(slot, s_oPC)+') ';
        last_line := 1;
        // Remaining conditionals.
        while num_slots > 1 do begin
            // Update counts.
            Inc(slot);
            Dec(num_slots);
            // Go on to the next line.
            new_lines[last_line] += ' &&';
            Inc(last_line);
            new_lines[last_line] := '     "'+item_tag+'" != GetTag('+
                                          Script.GetItemInSlot(slot, s_oPC)+') ';
        end;
        // Finish the final line.
        new_lines[last_line] += ')';
        Inc(last_line);
    end
    else if radiogroup1.itemindex = 0 then begin
        // The script should check for oPC (only) possessing the given item.
        new_lines[0] := '// The PC must possess '+item_name+'.';
        new_lines[1] := 'if ( '+Script.GetItemPossessedBy(s_oPC, item_tag)+' == '+
                              s_OBJECT_INVALID+' )';
        last_line := 2;
    end
    else begin
        // The script should check for oPC's party possessing the given item.
        new_lines[0] := '// The PC''s party must possess '+item_name+'.';
        new_lines[1] := 'if ( !GetIsItemPossessedByParty('+s_oPC+', "'+item_tag+'") )';
        last_line := 2;
        // This will require including x0_i0_partywide.
        Tlilac.Include(INC_PARTYWIDE);
    end;

    // In all cases, the last line returns FALSE.
    new_lines[last_line] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line]);
end;


// Handles the clicking of the "Palette" button.
procedure Titemint.Button4Click(Sender: TObject);
begin
    // Call up the palette window.
    TPaletteWindow.Load(Edit1, EditName, SEARCH_ITEMS);
end;


// Handles the clicking of the "must be equipped" checkbox.
procedure Titemint.CheckBox1Click(Sender: TObject);
begin
    // When checked, the combo box is enabled, but not the radio group.
    // When not checked, vice versa.
    combobox1.enabled := checkbox1.checked;
    radiogroup1.enabled := not checkbox1.checked;
    // Reset the selection to reduce confusion.
    if not radiogroup1.Enabled then
        radiogroup1.ItemIndex := 0;
end;


initialization
  {$i item_int.lrs}
end.
