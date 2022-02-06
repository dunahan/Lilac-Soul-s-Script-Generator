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
* Added the "exactly at" option and tweaked the form's presentation.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit journal_int;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} {Forms,} {Dialogs,}
  StdCtrls, Spin, ExtCtrls, {start,} nwn, Buttons,
  LResources, ExtForm, Classes;

type

  { Tjournalsint }

  Tjournalsint = class(TExtForm)
    // Form elements
    journalint: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    RadioGroupCompare: TRadioGroup;
    SpinEdit1: TSpinEdit;
    journaltag: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    // Event handlers
    procedure Button1Click(Sender: TObject);
  end;


// -----------------------------------------------------------------------------
implementation

uses
    constants;


// Handles clicks of the "Okay" button.
procedure Tjournalsint.Button1Click(Sender: TObject);
var
    stage: shortstring;
    compare: string[4];     at_least: shortstring;
    new_lines: array[0..2] of shortstring;
begin
    // Pull some data from the form.
    stage := spinedit1.Text;
    at_least := RadioGroupCompare.Items[RadioGroupCompare.ItemIndex];
    case RadioGroupCompare.ItemIndex of
        0: compare := ' < ';
        1: compare := ' != ';
        2: compare := ' >= ';
    end;

    // The code to add to the script.
    new_lines[0] := '// The PC must be '+at_least+' stage '+stage+' of quest '+journaltag.Text+'.';
    new_lines[1] := 'if ( '+Script.JournalRead(s_oPC, QuoteSwap(journaltag.Text)) +
                          compare + stage + ' )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


initialization
  {$i journal_int.lrs}
end.
