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
This new unit is intended to reduce the redundancy of some event handler
implementations in the Script Generator.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit ExtForm;


interface

uses
  Forms, StdCtrls;


const
    // Choices for the type of a local variable.
    LV_INT    = 0;
    LV_FLOAT  = 1;
    LV_STRING = 2;


type

    // This class is an extension of the standard TForm. It adds common
    // event handlers that were being coded over and over again, and provides
    // a hook (ToggleOkay) that passes execution back to a descendent class
    // for the purpose of validating a form. (ToggleOkay happens to also be
    // a simplistic, but repeatedly used, event handler.)

    {TExtForm }

    TExtForm = class(TForm)
        procedure CheckChangeToggleEnable(Sender: TObject);
        procedure ControlChangeToggleChecked(Sender:TObject);
        procedure EditChangeToggleChecked(Sender:TObject);
        procedure RadioChangeToggleVisible(Sender: TObject);
        procedure ToggleOkay(Sender:TObject); virtual;

        // Not called directly as an event handler, but used in processing events:
        procedure EditChangeValidateNumeric(TheEdit: TCustomEdit; iType: integer;
                                            bTextEntry:boolean=TRUE);

        // A utility shared by multiple units.
        procedure DisableAndUnselect(ToDisable: TRadioButton; bDisable: boolean;
                                     AltSelect: TRadioButton);
    end;


implementation

uses Classes, Controls, SysUtils;


// -----------------------------------------------------------------------------
    {TExtForm }


// Handler for a check box that enables/disables associated controls.
// A control is associated if it has the same parent and if its name
// ends the same as the check box's name (compared to all but the first
// five characters of the check box's name).
procedure TExtForm.CheckChangeToggleEnable(Sender: TObject);
var
    _Sender:       TCheckBox;
    CompareName:   TComponentName;
    CompareLength: integer;
    Sibling:       TControl;
    control_num:   integer;
begin
    // This is only to be used to handle events sent from a TCheckBox.
    _Sender := TCheckBox(Sender);
    // Affected elements must have a name that ends the same as Sender.
    CompareLength := Length(_Sender.Name) - 5;
    CompareName := copy(_Sender.Name, 6, CompareLength);

    // Enable/disable all sibling controls whose name ends with CompareName.
    for control_num := 0 to _Sender.Parent.ControlCount - 1 do begin
        Sibling := _Sender.Parent.Controls[control_num];
        if (Sibling <> _Sender) and
           (CompareName = copy(Sibling.Name,
                               Length(Sibling.Name) + 1 - CompareLength,
                               CompareLength)) then
            // Found a match.
            Sibling.Enabled := _Sender.Checked;
    end;

    // Also update the "Okay" button.
    ToggleOkay(Sender);
end;


// Selects the radio/check button associated with Sender.
// Also calls ToggleOkay().
//
// A control is associated if it has the same parent and if its name:
// 1) starts with 'Radio' (assumed a TRadioButton) or 'Check' (assumed a TCheckBox); and
// 2) ends with (everything after 'Radio'/'Check') the end of Sender's name.
procedure TExtForm.ControlChangeToggleChecked(Sender:TObject);
var
    _Sender:    TControl;
    Sibling:    TControl;
    control_num: integer;

    len_suffix:    integer;
    len_name_send: integer;
begin
    // This is only to be used to handle events sent from a TControl.
    _Sender := TControl(Sender);
    len_name_send := Length(_Sender.Name);

    // Look for an associated control.
    for control_num := 0 to _Sender.Parent.ControlCount - 1 do begin
        Sibling := _Sender.Parent.Controls[control_num];
        len_suffix := Length(Sibling.Name) - 5;
        // Is this an associated control?
        if (Sibling <> _Sender) and
           (copy(Sibling.Name, 6, len_suffix)
            = copy(_Sender.Name, 1+len_name_send-len_suffix, len_suffix)) then
        begin
            // Does the name suggest this is a control we can handle?
            if 'Radio' = copy(Sibling.Name, 1, 5) then
                // Select this radio button.
                TRadioButton(Sibling).Checked := true
            else if 'Check' = copy(Sibling.Name, 1, 5) then
                // Select this check box.
                TCheckBox(Sibling).Checked := true;
        end;
    end;

    // Also update the "Okay" button(s).
    ToggleOkay(Sender);
end;


// Selects the radio/check button associated with Sender unless
// Sender (assumed a TCustomEdit) was cleared.
// Also calls ToggleOkay().
//
// A control is associated if it has the same parent and if its name:
// 1) starts with 'Radio' (assumed a TRadioButton) or 'Check' (assumed a TCheckBox); and
// 2) ends with (everything after 'Radio'/'Check') the end of Sender's name.
procedure TExtForm.EditChangeToggleChecked(Sender:TObject);
begin
    // This is only to be used to handle events sent from a TCustomEdit.
    if TCustomEdit(Sender).Text <> '' then
        // Pass control to the more generic handler.
        ControlChangeToggleChecked(Sender)
    else
        // Just update the "Okay" button.
        ToggleOkay(Sender);
end;


// Handler for a radio button that shows/hides associated controls.
// A control is associated if it has the same parent and if its name
// ends the same as the radio box's name (compared to all but the first
// five characters of the radio box's name).
procedure TExtForm.RadioChangeToggleVisible(Sender: TObject);
var
    _Sender:       TRadioButton;
    CompareName:   TComponentName;
    CompareLength: integer;
    Sibling:       TControl;
    control_num:   integer;
begin
    // This is only to be used to handle events sent from a TRadioButton.
    _Sender := TRadioButton(Sender);
    // Affected elements must have a name that ends the same as Sender.
    CompareLength := Length(_Sender.Name) - 5;
    CompareName := copy(_Sender.Name, 6, CompareLength);

    // Enable/disable all sibling controls whose name ends with CompareName.
    for control_num := 0 to _Sender.Parent.ControlCount - 1 do begin
        Sibling := _Sender.Parent.Controls[control_num];
        if (Sibling <> _Sender) and
           (CompareName = copy(Sibling.Name,
                               Length(Sibling.Name) + 1 - CompareLength,
                               CompareLength)) then
            // Found a match.
            Sibling.Visible := _Sender.Checked;
    end;

    // Also update the "Okay" button.
    ToggleOkay(Sender);
end;


// Simple procedure for use when there is a single "Okay" button (the default
// control of the form) and the only required data is Sender.Text.
//
// More complex forms should override this.
procedure TExtForm.ToggleOkay(Sender: TObject);
begin
    // A little error checking as this can be called in many contexts.
    if (DefaultControl <> nil) and (Sender is TCustomEdit) then
        DefaultControl.Enabled :=  TCustomEdit(Sender).Text <>  '';
end;


// Validates text entry (for local variable values).
// Integers must consist of digits, while floats are allowed a decimal point.
// iType is a LV_* constant indicating what kind of data is acceptable.
// bTextEntry should be true if it should be assumed the user is in the middle
//      of entering text (often this will be "Sender = TheEdit").
procedure TExtForm.EditChangeValidateNumeric(TheEdit: TCustomEdit; iType: integer;
                                             bTextEntry:boolean=TRUE);
var
    sText, sOrig:  shortstring;
    bNegative:     boolean;
    bAllowDecimal: boolean;

    iChar: integer;
begin
    // Initializations.
    sOrig         := TheEdit.Text;
    sText         := sOrig;
    bAllowDecimal := iType = LV_FLOAT;
    bNegative     := FALSE;

    // We do not need to validate strings.
    if iType = LV_STRING then begin
        // However, we may want to default some zeros to blanks,
        // for consistency when changing variable types.
        if not bTextEntry  and  ( (sText = '0')  or  (sText = '0.0') ) then
            TheEdit.Text := '';
        exit;
    end;

    // Remove leading zeros.
    if Length(sText) > 1 then begin
        iChar := 1;
        while (sText[iChar] = '0') and (Length(sText) > iChar) do
            Inc(iChar);
        if iChar > 1 then
            sText := copy(sText, iChar, Length(sText));
    end;

    // Allow an initial negative sign.
    if Length(sText) > 0 then
        if sText[1] = '-' then begin
            bNegative := TRUE;
            sText := copy(sText, 2, Length(sText));
        end;

    // Remove leading zeros.
    if Length(sText) > 1 then begin
        iChar := 1;
        while (sText[iChar] = '0') and (Length(sText) > iChar) do
            Inc(iChar);
        if iChar > 1 then
            sText := copy(sText, iChar, Length(sText));
    end;

    // Allow a second negative sign to cancel the first.
    if bNegative and (Length(sText) > 0) then
        if sText[1] = '-' then begin
            bNegative := FALSE;
            sText := copy(sText, 2, Length(sText));
        end;

    // Force a (single) leading zero in front of a decimal point.
    if Length(sText) > 0 then
        if sText[1] = '.' then
            sText := '0'+sText;

    // Validate the numeric text.
    iChar := 0;
    while iChar < Length(sText) do begin
        Inc(iChar);
        if (sText[iChar] = '.') and bAllowDecimal then
            // No more decimal points will be allowed.
            bAllowDecimal := FALSE
        else if (sText[iChar] < '0') or ('9' < sText[iChar]) then
            // Unacceptable character. Truncate.
            SetLength(sText, iChar-1);
    end;

    // Convert blanks to zero.
    if sText = '' then begin
        if bAllowDecimal and not bTextEntry then
            sText := '0.0'
        else
            sText := '0';
    end
    // Also append the '.0' if the user is not in the middle of typing.
    else if not bTextEntry and bAllowDecimal then
        sText += '.0';

    // Restore the negative sign.
    if bNegative then
        sText := '-'+sText;

    if sText <> sOrig then begin
        // Update the widget.
        TheEdit.Text := sText;
        if bTextEntry then
            beep();
    end;
end;


// -----------------------------------------------------------------------------


// Utility to disable a radio button and select a different button if the
// now-disabled button was selected.
procedure TExtForm.DisableAndUnselect(ToDisable: TRadioButton; bDisable: boolean;
                                      AltSelect: TRadioButton);
begin
    ToDisable.Enabled := not bDisable;
    // Make sure we did not just disable the selection.
    if bDisable and ToDisable.Checked then
        AltSelect.Checked := true;
end;


end.

