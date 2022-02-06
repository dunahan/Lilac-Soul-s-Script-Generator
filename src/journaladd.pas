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
* Most of this was trimmed when I converted the form to being really modal
*   instead of simulated modal.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit journaladd;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, ExtCtrls, Spin, Buttons,
  LResources, ExtForm;

type

  { Tentryupdate }

  Tentryupdate = class(TExtForm)
    // Form elements.
    journaltag: TEdit;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    Label2: TLabel;
    CheckBox1: TCheckBox;
    RadioGroup1: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    TextNotRecommendOverride: TStaticText;
    // Event handlers.
    procedure Button1Click(Sender: TObject);
  end;

{var
  entryupdate: Tentryupdate;}


// -----------------------------------------------------------------------------
implementation

uses
    nwn, {start,} constants;


// Handles clicks of the "Okay" button; sends the requested scripting to the
// script window.
procedure Tentryupdate.Button1Click(Sender: TObject);
var
    journals: shortstring;

    new_lines: array[0..1] of shortstring;
begin
    // Some nice text for the comment.
    case radiogroup1.itemindex of
        0: journals := 'the player''s journal';
        1: journals := 'the party''s journals';
        2: journals := 'all players'' journals';
    end;

    new_lines[0] := '// Update '+journals+'.';
    new_lines[1] := Script.AddJournalQuestEntry(QuoteSwap(journaltag.text),
                                                inttostr(spinedit1.value), s_oPC,
                                                radiogroup1.itemindex = 1,
                                                radiogroup1.itemindex = 2,
                                                checkbox1.checked) +';';
    Tlilac.AddLines(new_lines, 1, 1);
end;


initialization
  {$i journaladd.lrs}
end.
