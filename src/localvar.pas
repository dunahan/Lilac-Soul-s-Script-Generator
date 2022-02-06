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
* Generally redesigned the form, allowing more choices for where to set locals.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit localvar;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  {Spin, ExtCtrls,} StdCtrls, Buttons,
  LResources, QueueForm;

type

  { Tlocvar }

  Tlocvar = class(TQueueForm)
    // Form elements
    CheckParty: TCheckBox;
    EditTagged: TEdit;
    EditVarName: TEdit;
    EditVarValue: TEdit;
    GroupTarget: TGroupBox;
    LabelVarValue: TLabel;
    LabelVarType: TLabel;
    BoxVarType: TComboBox;
    LabelVarName: TLabel;
    RadioActivator: TRadioButton;
    RadioActor: TRadioButton;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    incbox: TCheckBox;
    // Event handlers.
    procedure CheckPartyChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditVarValueChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  protected
    // Helper methods
    procedure ClearForm(); override;
    procedure QueueThis(); override;
  end;

{var
  locvar: Tlocvar;
}

// -----------------------------------------------------------------------------
implementation

uses
    {event,} start, nwn,
    constants, ExtForm;


// Configures the form based on current circumstances.
procedure Tlocvar.FormCreate(Sender: TObject);
begin
    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_TYPE_ALL);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted, OBJECT_TYPE_ALL);
end;


// Handles closing of this form.
procedure Tlocvar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    // Let Tlilac know that we are done.
    Tlilac.AddLinesDone();
end;


// Prevents the combination of adding to an existing value and setting party-wide
// (which goes beyond the scope of the Script Generator).
procedure Tlocvar.CheckPartyChange(Sender: TObject);
begin
    incbox.Enabled := not CheckParty.Checked;
    if CheckParty.Checked then
        incbox.Checked := false;
end;


// Validates text entry for numbers.
// Integers must consist of digits, while floats are allowed a decimal point.
// Sender need not be the TEdit to validate.
procedure Tlocvar.EditVarValueChange(Sender: TObject);
begin
    EditChangeValidateNumeric(EditVarValue, BoxVarType.ItemIndex, Sender = EditVarValue);
end;


// Controls the enabled state of the "Okay" buttons.
procedure Tlocvar.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // Tagged objects need a tag.
    if RadioTagged.Checked and (EditTagged.Text = '') then
        bEnable := false

    // Variables require names.
    else if EditVarName.Text = '' then
        bEnable := false

    // Increments require a value.
    else if incbox.Checked and (EditVarValue.Text = '') then
        bEnable := false

    else
        // Passed all tests.
        bEnable := true;

    // Update the "Okay" buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------


// Clears the form so more locals can be entered.
procedure Tlocvar.ClearForm();
begin
    EditVarName.Text := '';
    case BoxVarType.ItemIndex of
        LV_STRING: EditVarValue.Text := '';
        LV_INT:    EditVarValue.Text := '0';
        LV_FLOAT:  EditVarValue.Text := '0.0';
    end;
end;


// Sends the requested NWScript to the script window.
// ("Queue this" is a bit of a misnomer here, but using TQueueForm seems
//  appropriate, given the buttons on the form.)
procedure Tlocvar.QueueThis();
var
    kind, desc, variable: shortstring;
    on_whom: TObjectEnum;
    local_type:  integer;
    local_name:  shortstring;
    local_value: shortstring;

    last_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // For better readability:
    local_type := BoxVarType.ItemIndex;
    local_name := QuoteSwap(EditVarName.text);
    local_value := EditVarValue.text;

    // Possible formatting of the goal value.
    if local_type = LV_STRING then
        local_value := '"'+QuoteSwap(local_value)+'"'
    else if local_type = LV_FLOAT then begin
        if Pos('.', local_value) < 1 then
            local_value += '.0';
    end;

    // On whom do we set this?
    on_whom := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                             RadioTagged, RadioActor, RadioSpawn);
    // Declare a variable if needed.
    if on_whom = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // Determine the kind of local variable.
    case local_type of
        LV_STRING: begin variable := s_sValue;  kind := 'String';  desc := 'string';  end;
        LV_INT:    begin variable := s_nValue;  kind := 'Int';     desc := 'integer'; end;
        LV_FLOAT:  begin variable := s_fValue;  kind := 'Float';   desc := 'floating point number'; end;
    end;
    // Accomodate party-wide setting.
    if CheckParty.Checked then begin
        TLilac.Include(INC_PARTYWIDE);
        kind += 'OnAll';
    end;

    // The opening comment.
    new_lines[0] := '// Set a local '+desc+'.';
    last_line := 0;

    // Define oTarget?
    if on_whom = E_CHOOSE_Tagged then begin
        new_lines[1] := s_oTarget+' = '+s_GetObject + QuoteSwap(EditTagged.Text)+'");';
        last_line := 1;
    end;

    // What value will be actually be given the local variable?
    // (Set _variable_ to it, if not the NWScript variable already in _variable_.)
    if not incbox.checked then
        // Just use the specified value.
        variable := local_value
    else begin
        // We need to retrieve the current local value.
        Inc(last_line);
        new_lines[last_line] := variable+' = GetLocal'+kind+'('+ObjectVar(on_whom)+', '+
                                                              '"'+local_name+'")';
        // Decrementing or incrementing?
        if local_value[1] = '-' then
            new_lines[last_line] += ' - '+copy(local_value, 2, Length(local_value))+';'
        else
            new_lines[last_line] += ' + '+local_value+';';
    end;

    // Assign the new value.
    Inc(last_line);
    new_lines[last_line] := 'SetLocal'+kind+'('+ObjectVar(on_whom)+', '+
                                              '"'+local_name+'", '+variable+');';

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


initialization
  {$i localvar.lrs}
end.
