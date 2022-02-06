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
* Much of this was trimmed when I converted the form to being really modal instead
*   of simulated modal.
* Removed the warning about conflicting includes, as that no longer applies.
* Added note about existing standard scripts.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit startmerchant;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, Spin, Buttons, ExtCtrls,
  LResources, ExtForm;

type

  { Tmerchant }

  Tmerchant = class(TExtForm)
    // Form elements
    GroupStore: TGroupBox;
    MemoStandardScripts: TMemo;
    GroupAppraise: TRadioGroup;
    RadioTagged: TRadioButton;
    RadioClosest: TRadioButton;
    markup: TSpinEdit;
    markdown: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    EditTagged: TEdit;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure Button1Click(Sender: TObject);
  end;


{var
  merchant: Tmerchant;
}

// -----------------------------------------------------------------------------
implementation

uses
    {event, } nwn, start,
    constants;


// Configures the form based on current circumstances.
procedure Tmerchant.FormCreate(Sender: TObject);
begin
    // Initialize radio buttons.
    main.InitRadioWhos(RadioClosest, nil, nil, OBJECT_TYPE_IN_AREA);
end;


// Controls the enabled state of the "Okay" button.
procedure Tmerchant.ToggleOkay(Sender: TObject);
begin
    BitBtn1.Enabled := not RadioTagged.Checked or (EditTagged.Text <> '');
end;


// Sends the requeted NWScript to the script window.
procedure Tmerchant.Button1Click(Sender: TObject);
var
    new_lines: array[0..2] of shortstring;
begin
    // Opening comment and store definition:
    new_lines[0] := '// Open a store for the PC.';
    if RadioTagged.Checked then
        new_lines[1] := s_oTarget+' = '+s_GetObject + QuoteSwap(EditTagged.text)+'");'
    else // RadioClosest.Checked
        new_lines[1] := s_oTarget+' = GetNearestObject(OBJECT_TYPE_STORE);';

    // Make sure we include a file if needed.
    if GroupAppraise.ItemIndex > 0 then
        Tlilac.Include(INC_PLOT);

    // Which function to open the store?
    case GroupAppraise.ItemIndex of
        0: new_lines[2] := 'OpenStore';
        1: new_lines[2] := 'gplotAppraiseOpenStore';
        2: new_lines[2] := 'gplotAppraiseFavOpenStore';
    end;
    // Parameters to the store opening function.
    new_lines[2] += '('+s_oTarget+', '+s_oPC;
    if (markdown.value <> 0) or (markup.value <> 0) then
        new_lines[2] += ', '+inttostr(markup.value);
    if markdown.value <> 0 then
        new_lines[2] += ', '+inttostr(markdown.value);
    // Handle an oddball case -- if this will be assigned, we need to assign
    // the store opening back to the script owner in order to use the proper
    // appraise check.
    if (GroupAppraise.ItemIndex > 0) and Tlilac.WillBeAssigned() then begin
        Tlilac.Declare(VAR_oSELF);
        new_lines[2] := s_AssignCommand + s_oSelf+', '+new_lines[2]+')';
    end;
    // End the line.
    new_lines[2] += ');';

    // Add the lines
    Tlilac.AddLines(new_lines, 2, 2);
end;


initialization
  {$i startmerchant.lrs}
end.
