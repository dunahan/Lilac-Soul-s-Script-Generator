{
Copyright 2011 The Krit

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
This is a new form that allows the user to customize which options become
available when defining events, based upon the type of object exepcted to
execute the script. --TK
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit TypeChoose;

interface

uses
  Buttons, Classes, ExtCtrls, StdCtrls, SysUtils, LResources, Forms, Controls;

type

  { TTypeChooser }

  // This form should not be invoked directly. Call the class function
  // UserChoice() instead.
  TTypeChooser = class(TForm)
      // Form elements
      ButtonContinue: TBitBtn;
      GroupTypes: TCheckGroup;
      TextExplanation: TStaticText;
      TextTitle: TStaticText;
      // No event handlers needed

  public
      // The way to access this form:
      class function UserChoice(options: word) : word;

  private
      // Bookkeeping
      MyOptions: word; // Uninitialized until SetOptions() is called.

      // Communication between an instance and UserChoice().
      procedure SetOptions(options: word);
      function  GetOptions(): word;
  end;

{var
  TypeChooser: TTypeChooser;
}

// -----------------------------------------------------------------------------

implementation


const
    // The names of object types, indexed by bit in an OBJECT_TYPE_* constant.
    OBJECT_NAMES: array[0..15] of pchar =
      ( 'Creatures',        // OBJECT_TYPE_CREATURE       = $0001
        'Items',            // OBJECT_TYPE_ITEM           = $0002
        'Triggers',         // OBJECT_TYPE_TRIGGER        = $0004
        'Doors',            // OBJECT_TYPE_DOOR           = $0008
        'Areas of effect',  // OBJECT_TYPE_AREA_OF_EFFECT = $0010
        'Waypoints',        // OBJECT_TYPE_WAYPOINT       = $0020
        'Placeables',       // OBJECT_TYPE_PLACEABLE      = $0040
        'Stores',           // OBJECT_TYPE_STORE          = $0080
        'Encounters',       // OBJECT_TYPE_ENCOUNTER      = $0100
        '',                 // N/A                          $0200
        '',                 // N/A                          $0400
        '',                 // N/A                          $0800
        '',                 // N/A                          $1000
        'Areas',            // OBJECT_TYPE_AREA           = $2000
        'The module',       // OBJECT_TYPE_MODULE         = $4000
        ''                  // N/A                          $8000
      );


// If _options_ encodes more than one object type, a window will be popped up,
// giving the user a chance to select just one (or a few, if that is desired).
// The returned value is the code for the user's selection.
class function TTypeChooser.UserChoice(options: word) : word;
var
    bit_counter: integer;
    num_choices: integer;

    choice_form: TTypeChooser;
begin
    // Count the number of objects encoded by _options_.
    num_choices := 0;
    for bit_counter := 0 to 15 do
        // Each bit that is turned on is a choice.
        if options and ($0001 << bit_counter) <> 0 then
            Inc(num_choices);

    // Nothing to do unless at least two choices were presented.
    if num_choices < 2 then begin
        result := options;
        exit;
    end;

    // Ask the user for a selection.
    Application.CreateForm(TTypeChooser, choice_form);
    choice_form.SetOptions(options);
    choice_form.ShowModal();

    // Retrieve the selection and clean up.
    result := choice_form.GetOptions();
    choice_form.Release();
end;


// -----------------------------------------------------------------------------

procedure TTypeChooser.SetOptions(options: word);
var
    bit_counter: integer;
begin
    // Record the option set, so we will later know which options had been available.
    MyOptions := options;

    // Fill in the CheckGroup.
    for bit_counter := 0 to 15 do
        // Each bit that is turned on is a choice.
        if options and ($0001 << bit_counter) <> 0 then
            GroupTypes.Items.Append(OBJECT_NAMES[bit_counter]);
end;


function  TTypeChooser.GetOptions(): word;
var
    bit_counter: integer;
    index:       integer;
begin
    // Convert the selections into a bitfield code.
    result := 0;
    index := 0;
    for bit_counter := 0 to 15 do
        // Each bit that is turned on is an item of GroupTypes.
        if MyOptions and ($0001 << bit_counter) <> 0 then begin
            // If this was selected, track it.
            if GroupTypes.Checked[index] then
                result += $0001 << bit_counter;
            // Go on to the next item.
            Inc(index);
        end;

    // If nothing was selected, use the entire option set.
    if result = 0 then
        result := MyOptions;
end;


initialization
  {$I typechoose.lrs}

end.

