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
* Cleanup of the generated scripts.
* Changes to form functionality/presentation.
* Allow checking of party ints.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit local_int;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, {Spin,} ExtCtrls, Buttons,
  LResources, QueueForm;

type

  { Tlocal }

  Tlocal = class(TQueueForm)
    // Form elements.
    ButtonOkExit: TBitBtn;
    ButtonOkMore: TBitBtn;
    CBoxCaseSensitive: TCheckBox;
    LabelCalled: TLabel;
    LabelSelectType: TLabel;
    localchoice: TComboBox;
    PanelPartyInfo: TPanel;
    RadioGreater: TRadioButton;
    RadioGroupParty: TRadioGroup;
    RadioLess: TRadioButton;
    RadioNotEqual: TRadioButton;
    RadioEqual: TRadioButton;
    GroupCompares: TRadioGroup;
    EditVarName: TEdit;
    PanelInput: TPanel;
    EditVarValue: TEdit;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    TextPartyInfo: TStaticText;
    // Event handlers.
    procedure Button8Click(Sender: TObject);
    procedure RadioGroupPartyClick(Sender: TObject);
    procedure ToggleOkay(Sender: TObject);           override;
    procedure VarValueChange(Sender: TObject);
    procedure localchoiceChange(Sender: TObject);

  protected
    // Helper methods
    procedure ClearForm(); override;
    procedure QueueThis(); override;
  end;


// -----------------------------------------------------------------------------
implementation

uses start, party_doc, nwn,
     constants, ExtForm;


// -----------------------------------------------------------------------------

// Handles clicks of the button for getting more info about party locals.
procedure Tlocal.Button8Click(Sender: TObject);
begin
    main.ShowPopup(TPartydoc);
end;


// Handles changes to the "PC / PC party" selection.
procedure Tlocal.RadioGroupPartyClick(Sender: TObject);
begin
    if RadioGroupParty.ItemIndex = 1 then
        PanelPartyInfo.Visible := true;
    // Not going to re-hide the panel if the selectin changes again.
end;


// Toggles the enabled state of the "Okay" buttons based on having stuff entered.
procedure Tlocal.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    bEnable :=  EditVarName.Text <> '';

    ButtonOkMore.Enabled := bEnable;
    ButtonOkExit.Enabled := bEnable;
end;


// Validates text entry for numbers.
// Integers must consist of digits, while floats are allowed a decimal point.
procedure Tlocal.VarValueChange(Sender: TObject);
begin
    EditChangeValidateNumeric(EditVarValue, LocalChoice.ItemIndex, EditVarValue = Sender);
end;


// Handles changes in the selection of int vs. string vs. float.
procedure Tlocal.localchoiceChange(Sender: TObject);
var
    bString:  boolean;
begin
    // Update a label.
    case LocalChoice.ItemIndex of
        LV_INT:    LabelCalled.Caption := 'The local integer called:';
        LV_FLOAT:  LabelCalled.Caption := 'The local float called:';
        LV_STRING: LabelCalled.Caption := 'The local string called:';
    end;

    // Update the available radio/check buttons.
    bString := LocalChoice.ItemIndex = LV_STRING;
    if bString and ( RadioLess.Checked or RadioGreater.Checked ) then
        RadioNotEqual.Checked := true;
    RadioLess.Visible    := not bString;
    RadioGreater.Visible := not bString;
    CBoxCaseSensitive.Visible := bString;

    // Validate the value.
    VarValueChange(Sender);
end;


// -----------------------------------------------------------------------------


// Clears info about the local variable so a new variable can be entered.
procedure Tlocal.ClearForm();
begin
    EditVarName.Text := '';
    RadioEqual.Checked := true;
    case LocalChoice.ItemIndex of
        LV_STRING: EditVarValue.Text := '';
        LV_INT:    EditVarValue.Text := '0';
        LV_FLOAT:  EditVarValue.Text := '0.0';
    end;
    // Intentionally leaving CBoxCaseSensitive alone.
end;


// Adds appropriate NWScript to the script window.
procedure Tlocal.QueueThis();
var
    bString:    boolean;
    func_name:  shortstring;
    goal_value: shortstring;
    compare:    string[4];
    new_lines:  array[0..2] of shortstring;
begin
    bString := LocalChoice.ItemIndex = LV_STRING;

    // Construct the function call that will retrieve the local value.
    if RadioGroupParty.ItemIndex = 0 then
        func_name := 'GetLocal'
    else begin
        Tlilac.Include(INC_LS_PARTY);
        func_name := 'GetParty';
    end;
    case LocalChoice.ItemIndex of
        LV_INT:     func_name += 'Int';
        LV_FLOAT:   func_name += 'Float';
        LV_STRING:  func_name += 'String';
    end;
    // Add parameters.
    func_name += '('+s_oPC+', "'+QuoteSwap(EditVarName.Text)+'")';

    // The goal value might need to be formatted.
    goal_value := EditVarValue.Text;
    if bString then
        goal_value := '"'+QuoteSwap(goal_value)+'"'
    else if LocalChoice.ItemIndex = LV_FLOAT then begin
        if Pos('.', goal_value) < 1 then
            goal_value += '.0';
    end;

    // Apply case sensitive.
    if bString and not CBoxCaseSensitive.Checked then begin
        func_name := 'GetStringLowerCase('+func_name+')';
        goal_value := lowercase(goal_value);
    end;

    // Determine the comparison operator to use.
    if RadioEqual.Checked then
        compare := ' != '
    else if RadioLess.Checked then
        compare := ' >= '
    else if RadioGreater.Checked then
        compare := ' <= '
    else // RadioNotEqual.Checked
        compare := ' == ';

    // The code to add to the script.
    new_lines[0] := '// Check a local variable.';
    new_lines[1] := 'if ( '+func_name + compare + goal_value+' )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


initialization
  {$i local_int.lrs}
end.
