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
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit statchoose_box;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons,
  LResources;


// -----------------------------------------------------------------------------
type

  { Tstatchoose }

  Tstatchoose = class(TForm)
    // Form elements
    gender: TCheckBox;
    LabelSkills: TLabel;
    level: TCheckBox;
    pcclass: TCheckBox;
    multiclass: TCheckBox;
    feat: TCheckBox;
    ability: TCheckBox;
    skill: TCheckBox;
    subrace: TCheckBox;
    race: TCheckBox;
    alignment: TCheckBox;
    hasskill: TCheckBox;
    DCskillroll: TCheckBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    levelbyclass: TCheckBox;
    SavingThrow: TCheckBox;
    Deity: TCheckBox;
    // Event handlers
    procedure Button1Click(Sender: TObject);
  end;


// -----------------------------------------------------------------------------
implementation

uses
  start, statwarning_box, pcstats_int;


procedure Tstatchoose.Button1Click(Sender: TObject);
var
    CheckedBoxes: array[0..14] of TPCStatsEnum;
    ArrayIndex:   integer = 0;
    NextForm: Tpcstats;
begin
    // Record which boxes were checked.
    if ability.checked      then begin CheckedBoxes[ArrayIndex] := PCSTAT_Ability;     ArrayIndex += 1; end;
    if alignment.checked    then begin CheckedBoxes[ArrayIndex] := PCSTAT_Alignment;   ArrayIndex += 1; end;
    if pcclass.checked      then begin CheckedBoxes[ArrayIndex] := PCSTAT_Class;       ArrayIndex += 1; end;
    if multiclass.checked   then begin CheckedBoxes[ArrayIndex] := PCSTAT_Multiclass;  ArrayIndex += 1; end;
    if deity.checked        then begin CheckedBoxes[ArrayIndex] := PCSTAT_Deity;       ArrayIndex += 1; end;
    if feat.checked         then begin CheckedBoxes[ArrayIndex] := PCSTAT_Feat;        ArrayIndex += 1; end;
    if gender.checked       then begin CheckedBoxes[ArrayIndex] := PCSTAT_Gender;      ArrayIndex += 1; end;
    if level.checked        then begin CheckedBoxes[ArrayIndex] := PCSTAT_Level;       ArrayIndex += 1; end;
    if levelbyclass.checked then begin CheckedBoxes[ArrayIndex] := PCSTAT_ClassLevel;  ArrayIndex += 1; end;
    if race.checked         then begin CheckedBoxes[ArrayIndex] := PCSTAT_Race;        ArrayIndex += 1; end;
    if subrace.checked      then begin CheckedBoxes[ArrayIndex] := PCSTAT_Subrace;     ArrayIndex += 1; end;
    if SavingThrow.checked  then begin CheckedBoxes[ArrayIndex] := PCSTAT_SavingThrow; ArrayIndex += 1; end;
    if hasskill.checked     then begin CheckedBoxes[ArrayIndex] := PCSTAT_HasSkill;    ArrayIndex += 1; end;
    if skill.checked        then begin CheckedBoxes[ArrayIndex] := PCSTAT_SkillRank;   ArrayIndex += 1; end;
    if DCskillroll.checked  then begin CheckedBoxes[ArrayIndex] := PCSTAT_SkillRoll;   ArrayIndex += 1; end;

    // Alert if no boxes checked.
    if ArrayIndex = 0 then
        main.ShowPopup(Tstatwarning)
    else begin
        // Hide this form.
        Visible := false;

        // Move on to the next form.
        Application.CreateForm(Tpcstats, NextForm);
        NextForm.ShowModal(CheckedBoxes[0..ArrayIndex-1]);

        // Clean up.
        NextForm.Release();
    end;
end;


// -----------------------------------------------------------------------------
initialization
  {$i statchoose_box.lrs}
end.
