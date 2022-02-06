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
* Parts trimmed when I converted the form to being modal.
* Reorganized the transistions from step to step; should be easier to add new
  steps now.
* Cleanup of the generated scripts and a few new options available.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit pcstats_int;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics,} Controls, Forms, {Dialogs,}
  StdCtrls, ExtCtrls, Spin, Buttons, CheckLst,
  LResources, LCLType{, InterfaceBase};


// -----------------------------------------------------------------------------
type

    // Enumerated type to encode the various views of this form.
    TPCStatsEnum =
        ( PCSTAT_Ability,    PCSTAT_Alignment,  PCSTAT_Class,
          PCSTAT_Multiclass, PCSTAT_Deity,      PCSTAT_Feat,
          PCSTAT_Gender,     PCSTAT_Level,      PCSTAT_ClassLevel,
          PCSTAT_Race,       PCSTAT_Subrace,    PCSTAT_SavingThrow,
          PCSTAT_HasSkill,   PCSTAT_SkillRank,  PCSTAT_SkillRoll );


  { Tpcstats }

  Tpcstats = class(TForm)
      abilityScore: TSpinEdit;
      abilitychoice: TRadioGroup;
      abilitycondition: TRadioGroup;
      alignmentSelection: TRadioGroup;
      alignmentconditional: TRadioGroup;
      arcanearcherx: TCheckBox;
      assassinx: TCheckBox;
      BarbarianX: TCheckBox;
      BardX: TCheckBox;
      BevelRace: TBevel;
      BevelAlignment: TBevel;
      blackguardx: TCheckBox;
      CheckBox1: TCheckBox;
      CheckBoxHuman: TCheckBox;
      CheckBoxHalfOrc: TCheckBox;
      CheckBoxHalfElf: TCheckBox;
      CheckBoxHalfling: TCheckBox;
      CheckBoxGnome: TCheckBox;
      CheckBoxElf: TCheckBox;
      CheckBoxDwarf: TCheckBox;
      CheckBoxDeityCase: TCheckBox;
      CheckListBox1: TCheckListBox;
      CheckListBox2: TCheckListBox;
      CheckListSkillRoll: TCheckListBox;
      classcond: TRadioGroup;
      classrestriction: TPanel;
      ClericX: TCheckBox;
      defenderx: TCheckBox;
      dragonx: TCheckBox;
      DruidX: TCheckBox;
      featbox: TComboBox;
      FighterX: TCheckBox;
      fortitude: TCheckBox;
      fortitudeDC: TSpinEdit;
      gender: TRadioGroup;
    harperscoutx: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LabelAlignment: TLabel;
    LabelRace: TLabel;
    LabelFeats: TLabel;
    Label59: TLabel;
    LabelDeity: TLabel;
    LabelSubrace: TLabel;
    level: TSpinEdit;
    levelbyclassrestriction: TPanel;
    levelclass: TComboBox;
    levelclasscond: TRadioGroup;
    levelcondition: TRadioGroup;
    levels: TSpinEdit;
    MonkX: TCheckBox;
    multiclass: TRadioGroup;
    PaladinX: TCheckBox;
    palemasterx: TCheckBox;
    Panel1: TPanel;
    Panel2: TPanel;
    PanelSkillRoll: TPanel;
    PanelSubrace: TPanel;
    PanelRace: TPanel;
    PanelLevels: TPanel;
    PanelFeats: TPanel;
    PanelDeity: TPanel;
    PurpleDragonX: TCheckBox;
    PanelAlignment: TPanel;
    PanelAbilities: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    racecondition: TRadioGroup;
    RadioGroup1: TRadioGroup;
    GroupPartyLevel: TRadioGroup;
    RadioGroupFeatType: TRadioGroup;
    RangerX: TCheckBox;
    reflex: TCheckBox;
    reflexDC: TSpinEdit;
    RogueX: TCheckBox;
    SaveRestriction: TPanel;
    SaveType: TComboBox;
    shadowdancerx: TCheckBox;
    AlignmentShader: TShape;
    shifterx: TCheckBox;
    skilldclabel: TLabel;
    LabelSkillRoll: TLabel;
    skillgroup: TRadioGroup;
    RadioSkillRoll: TRadioGroup;
    skilllabel: TLabel;
    SorcererX: TCheckBox;
    DeityEdit: TEdit;
    DeityConditional: TRadioGroup;
    SpinEdit1: TSpinEdit;
    SpinEditSkillRoll: TSpinEdit;
    RaceAdvisor: TStaticText;
    StaticTextHasSkill: TStaticText;
    subrace: TEdit;
    subraceconditional: TRadioGroup;
    tormx: TCheckBox;
    weaponmasterx: TCheckBox;
    abilitygroup: TRadioGroup;
    will: TCheckBox;
    willDC: TSpinEdit;
    WizardX: TCheckBox;
    // Event handlers.
    procedure FormCreate(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure RaceClick(Sender: TObject);
    procedure RadioGroupFeatTypeClick(Sender: TObject);

    // Overridden methods
    function ShowModal(): Integer; override; overload;  // Do not use. Use the overload instead.
    function ShowModal(const ToShow: array of TPCStatsEnum): Integer; overload;

  private
    // Bookkeeping.
    Views: array of TPCStatsEnum;
    ViewIndex: integer;

    // Script generating functions.
    procedure AbilityScript();
    procedure AlignmentScript();
    procedure ClassScript();
    procedure MulticlassScript();
    procedure DeityScript();
    procedure FeatScript();
    procedure GenderScript();
    procedure LevelScript();
    procedure LevelByClassScript();
    procedure RaceScript();
    procedure SubraceScript();
    procedure SaveScript();
    procedure HasSkillScript();
    procedure SkillRankScript();
    procedure SkillcheckScript();

    // Helper functions.
    procedure MakeNextVisible();
    function  ViewToPanel(View: TPCStatsEnum) : TControl;
  end;


// -----------------------------------------------------------------------------
implementation

uses {start, statchoose_box,} nwn, {chooseif,} constants;


// -----------------------------------------------------------------------------
// Overridden methods


// Override the default function to do nothing.
// Call the overloaded version instead.
function Tpcstats.ShowModal(): Integer;
begin
    Application.MessageBox('An attempt was made to load the PC stats window ' +
                           'through a discontinued mechanism. Aborting.',
                           'You found a bug', MB_OK);
    result := 0;
end;


// Overloaded replacement for the default ShowModal().
// This version requires a list of which views to show.
function Tpcstats.ShowModal(const ToShow: array of TPCStatsEnum): Integer;
var
    index : integer;
begin
    // Record the list of views.
    // (Apparently an assignment does not work.)
    SetLength(Views, Length(ToShow));
    for index := 0 to High(ToShow) do
        Views[index] := ToShow[index];
    // Start before the first view.
    ViewIndex := -1;

    // Update what will be displayed.
    MakeNextVisible();
    // Show the window.
    result := inherited ShowModal();

    // Cleanup.
    SetLength(Views, 0);
end;


// -----------------------------------------------------------------------------
// Script production functions.


// Generates the NWScript lines for a check on oPC's abilities.
procedure Tpcstats.AbilityScript();
var
    ability:    shortstring;
    base_param: shortstring;    base_desc: shortstring;
    compare:    string[2];      at_least:  shortstring;
    new_lines: array[0..2] of shortstring;
begin
    // Let's shorten how to refer to the selection.
    ability := abilitychoice.Items[abilitychoice.ItemIndex];

    // Modified or base score?
    case abilitygroup.ItemIndex of
        0: begin base_param := '';             base_desc := 'current '; end;
        1: begin base_param := s_comma_TRUE;   base_desc := 'base ';    end;
    end;

    // At least or at most?
    case abilitycondition.ItemIndex of
        0: begin compare := '< ';      at_least := ' must be at least '; end;
        1: begin compare := '> ';      at_least := ' can be at most ';   end;
    end;

    // The code to add to the script:
    new_lines[0] := '// The PC''s '+base_desc + lowercase(ability) + at_least + abilityScore.Text+'.';
    new_lines[1] := 'if ( GetAbilityScore('+s_oPC+', ABILITY_'+uppercase(ability)+base_param+') '+
                          compare + abilityScore.Text+' )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Generates the NWScript lines for a check on oPC's alignment.
procedure Tpcstats.AlignmentScript();
// The current codes for each alignment choice are:
//
//   0: Lawful good     1: Neutral good      2: Chaotic good     3: ** Any good
//   4: Lawful neutral  5: True neutral      6: Chaotic neutral  7: ** Neutral (G/E)
//   8: Lawful evil     9: Neutral evil     10: Chaotic evil    11: ** Any evil
//  12: ** Any lawful  13: ** Neutral (L/C) 14: ** Any chaotic  15: ** Any neutral
//
// (The "**" is to distinguish alignment groups from specific alignments.)
var
    good_evil, law_chaos: integer;
    compare: string[3];
    joiner:  string[4];
    notbe:   string[7];

    last_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // Initializations.
    good_evil := alignmentSelection.ItemIndex div 4;
    law_chaos := alignmentSelection.ItemIndex mod 4;
    case alignmentConditional.ItemIndex of
        0: begin compare := '!= ';  joiner := '  ||';   notbe := 'be ';     end;
        1: begin compare := '== ';  joiner := '  &&';   notbe := 'not be '; end;
    end;
    // Special case: "any neutral" reverses the joiner.
    if alignmentSelection.ItemIndex = 15 then
        case alignmentConditional.ItemIndex of
            0: joiner := '  &&';
            1: joiner := '  ||';
        end;

    // The comment line:
    new_lines[0] := '// The PC''s alignment must '+notbe +
                    lowercase(alignmentSelection.Items[alignmentSelection.ItemIndex])+'.';

    // Start the first non-comment line.
    new_lines[1] := 'if ( ';
    new_lines[2] := '     '; // Not used yet, but the spaces should line up.
    last_line := 1;

    // Make a good-evil check?
    if good_evil < 3 then begin
        // Add a check for the good-evil alignment.
        new_lines[1] += 'GetAlignmentGoodEvil('+s_oPC+') ' + compare +
                        SymConst(ALIGNMENT_GE, good_evil);

        // Is there also a law-chaos check?
        if law_chaos < 3 then begin
            // Join with an "and" or "or".
            new_lines[1] += joiner;
            // Advance to the next line.
            last_line := 2;
        end;
    end;

    // Make a law-chaos check?
    if law_chaos < 3 then
        // Add a check for the law-chaos alignment.
        new_lines[last_line] += 'GetAlignmentLawChaos('+s_oPC+') ' + compare +
                                SymConst(ALIGNMENT_LC, law_chaos);

    // Special case: any neutral.
    if (good_evil = 3)  and  (law_chaos = 3) then begin
        new_lines[1] += 'GetAlignmentGoodEvil('+s_oPC+') '+compare +SymConst(ALIGNMENT_GE, 1) +joiner;
        new_lines[2] += 'GetAlignmentLawChaos('+s_oPC+') '+compare +SymConst(ALIGNMENT_LC, 1);
        last_line := 2;
    end;

    // Finish the lines.
    new_lines[last_line] += ' )';
    inc(last_line);
    new_lines[last_line] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line]);
end;


// Generates the NWScript lines for a check on oPC's classes.
procedure Tpcstats.ClassScript();
const
    comment0 = '// The PC must ';
    comment1 = ' of the listed classes.';
var
    classes: ClassCheck;
    eClass: TClassEnum;
begin
    // Make sure the ClassCheck is initialized to false (in case it covers
    // any classes we don't cover here).
    for eClass := Low(TClassEnum) to High(TClassEnum) do
        classes[eClass] := false;

    // Mark which classes were selected.
    classes[E_Barbarian]      := barbarianx.checked;
    classes[E_Bard]           := bardx.checked;
    classes[E_Cleric]         := clericx.checked;
    classes[E_Druid]          := druidx.checked;
    classes[E_Fighter]        := fighterx.checked;
    classes[E_Monk]           := monkx.checked;
    classes[E_Paladin]        := paladinx.checked;
    classes[E_Ranger]         := rangerx.checked;
    classes[E_Rogue]          := roguex.checked;
    classes[E_Sorcerer]       := sorcererx.checked;
    classes[E_Wizard]         := wizardx.checked;
    classes[E_Archer]         := arcanearcherx.checked;
    classes[E_Assassin]       := assassinx.checked;
    classes[E_Blackguard]     := blackguardx.checked;
    classes[E_Champion]       := tormx.checked;
    classes[E_Defender]       := defenderx.checked;
    classes[E_Harper]         := harperscoutx.checked;
    classes[E_PaleMaster]     := palemasterx.checked;
    classes[E_PurpleDragon]   := PurpleDragonX.Checked;
    classes[E_DragonDisciple] := dragonx.checked;
    classes[E_Shadowdancer]   := shadowdancerx.checked;
    classes[E_Shifter]        := shifterx.checked;
    classes[E_WeaponMaster]   := weaponmasterx.checked;

    // Add the appropriate lines.
    if classcond.ItemIndex = 0 then // Must be one of these classes.
        Tlilac.AddClassString(comment0 +'be one'+ comment1,
                              'if ( ', classes, ' == 0', '  &&', ' )',
                                  s_ReturnFalse)
    else // Must not be one of these classes.
        Tlilac.AddClassString(comment0 +'not be any'+ comment1,
                              'if ( ', classes,  ' > 0', '  ||', ' )',
                                  s_ReturnFalse);
end;


// Generates the NWScript lines for a check on oPC's multiclass status.
procedure Tpcstats.MulticlassScript();
var
    selection: integer;
    class_pos: string[1];   multi: shortstring;
    compare:   string[2];   notbe: shortstring;
    new_lines: array[0..2] of shortstring;
begin
    selection := multiclass.ItemIndex;

    // Selections 0 and 1 are for multiclassing; 2 and 3 are for triple-classing.
    if selection div 2 = 0 then
        begin class_pos := '2';     multi := 'multi';   end
    else
        begin class_pos := '3';     multi := 'triple-'; end;

    // Selections 0 and 2 are for having multiple classes; 1 and 3 are for not.
    if selection mod 2 = 0 then
        begin compare := '==';      notbe := 'be ';     end
    else
        begin compare := '!=';      notbe := 'not be '; end;

    // The code to add to the script:
    new_lines[0] := '// The PC must '+notbe + multi+'classed.';
    new_lines[1] := 'if ( GetClassByPosition('+class_pos+', '+s_oPC+') '+compare+' CLASS_TYPE_INVALID )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Generates the NWScript lines for a check on oPC's deity.
procedure Tpcstats.DeityScript();
var
    func_call:  shortstring;
    compare:    string[4];   notbe: shortstring;
    compare_to: shortstring;
    new_lines:  array[0..2] of shortstring;
begin
    // Construct the function to call.
    func_call := 'GetDeity('+s_oPC+')';
    compare_to := QuoteSwap(DeityEdit.Text);

    // See if this should be made case-insensitive.
    if not CheckboxDeityCase.Checked  and  (compare_to <> '') then begin
        func_call := 'GetStringLowerCase('+func_call+')';
        compare_to := lowercase(compare_to);
    end;

    // Is this "equals" or "not equals"?
    case DeityConditional.ItemIndex of
        0: begin compare := ' != ';    notbe := 'be ';     end;
        1: begin compare := ' == ';    notbe := 'not be '; end;
    end;

    // The code to add to the script:
    new_lines[0] := '// The deity of the PC must '+notbe + '"'+DeityEdit.Text+'".';
    new_lines[1] := 'if ( '+func_call + compare + '"'+compare_to+'" )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Generates the NWScript lines for a check on oPC's feats.
procedure Tpcstats.FeatScript();
var
    negation:  string[1];   nothave: shortstring;
    feat:      shortstring;
    new_lines: array[0..2] of shortstring;
begin
    // Abort if nothing selected.
    if featbox.ItemIndex < 0 then
        exit;

    // Is this "have" or "not have"?
    case RadioGroup1.ItemIndex of
        0: begin negation := '!';  nothave := 'have ';     end;
        1: begin negation := '';   nothave := 'not have '; end;
    end;

    // Look up the feat's NWScript constant.
    case RadioGroupFeatType.ItemIndex of
        0: feat := SymConst(FEAT_COMMON, featbox.ItemIndex);
        1: feat := SymConst(FEAT_SPECIAL, featbox.ItemIndex);
        2: feat := SymConst(FEAT_EPIC, featbox.ItemIndex);
    end;

    // The code to add to the script:
    new_lines[0] := '// The PC must '+nothave + lowercase(featbox.Text)+'.';
    new_lines[1] := 'if ( '+negation+'GetHasFeat('+feat+', '+s_oPC+') )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Generates the NWScript lines for a check on oPC's gender.
procedure Tpcstats.GenderScript();
var
    gender_text: shortstring;
    new_lines: array[0..2] of shortstring;
begin
    // For simpler reference:
    gender_text := gender.Items[gender.ItemIndex];

    // The code to add to the script:
    new_lines[0] := '// The PC must be '+lowercase(gender_text)+'.';
    new_lines[1] := 'if ( GetGender('+s_oPC+') != GENDER_'+uppercase(gender_text)+' )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Generates the NWScript lines for a check on oPC's level.
procedure Tpcstats.LevelScript();
var
    compare:   string[2];      at_least: shortstring;
    func_name: shortstring;    party:    shortstring;
    new_lines: array[0..2] of shortstring;
begin
    // At least or at most?
    case levelcondition.ItemIndex of
        0: begin compare := '< ';   at_least := 'at least '; end;
        1: begin compare := '> ';   at_least := 'at most ';   end;
    end;

    // PC or party?
    case GroupPartyLevel.ItemIndex of
        0: begin func_name := 'GetHitDice';             party := 'total ';            end;
        1: begin func_name := 'GetFactionAverageLevel'; party := 'party''s average '; end;
    end;

    // The code to add to the script:
    new_lines[0] := '// The PC''s '+party +'level must be '+at_least + level.Text+'.';
    new_lines[1] := 'if ( '+func_name+'('+s_oPC+') '+compare + level.Text+' )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Generates the NWScript lines for a check on oPC's class level.
procedure Tpcstats.LevelByClassScript();
var
    compare:    string[3];      exactly:  shortstring;
    new_lines: array[0..2] of shortstring;
begin
    // At least, at most, or exactly?
    case levelclasscond.ItemIndex of
        0: begin compare := '!= ';  exactly := 'exactly ';   end;
        1: begin compare := '>= ';  exactly := 'less than '; end;
        2: begin compare := '<= ';  exactly := 'more than '; end;
    end;

    // The code to add to the script:
    new_lines[0] := '// The PC must have '+exactly + levels.Text+' levels of '+lowercase(levelclass.Text)+'.';
    new_lines[1] := 'if ( GetLevelByClass('+SymConst(NWNCLASS, levelclass.ItemIndex)+', '+s_oPC+') '+
                          compare + levels.Text+' )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Generates the NWScript lines for a check on oPC's race.
procedure Tpcstats.RaceScript();
const
    comment0 = '// The PC must ';
    comment1 = ' of the listed races.';
var
    races: RacialCheck;
    eRace: TRaceEnum;
begin
    // Make sure the RacialCheck is initialized to false (in case it covers
    // any races we don't cover here).
    for eRace := Low(TRaceEnum) to High(TRaceEnum) do
        races[eRace] := false;

    // Mark which classes were selected.
    races[E_Dwarf]    := CheckBoxDwarf.Checked;
    races[E_Elf]      := CheckBoxElf.Checked;
    races[E_Gnome]    := CheckBoxGnome.Checked;
    races[E_Halfling] := CheckBoxHalfling.Checked;
    races[E_HalfElf]  := CheckBoxHalfElf.Checked;
    races[E_HalfOrc]  := CheckBoxHalfOrc.Checked;
    races[E_Human]    := CheckBoxHuman.Checked;

    // Add the appropriate lines.
    if racecondition.ItemIndex = 0 then // Must be one of these races.
        Tlilac.AddRaceString(comment0 +'be one'+ comment1,
                             'if ( ', s_oPC, ' != ', races, '  &&', ' )',
                                 s_ReturnFalse)
    else // Must not be one of these races.
        Tlilac.AddRaceString(comment0 +'not be any'+ comment1,
                             'if ( ', s_oPC, ' == ', races, '  ||', ' )',
                                 s_ReturnFalse);
end;


// Generates the NWScript lines for a check on oPC's subrace.
procedure Tpcstats.SubraceScript();
var
    func_call:  shortstring;
    compare:    string[4];   notbe: shortstring;
    compare_to: shortstring;
    new_lines:  array[0..2] of shortstring;
begin
    // Construct the function to call.
    func_call := 'GetSubRace('+s_oPC+')';
    compare_to := QuoteSwap(subrace.Text);

    // See if this should be made case-insensitive.
    if not Checkbox1.Checked  and  (compare_to <> '') then begin
        func_call := 'GetStringLowerCase('+func_call+')';
        compare_to := lowercase(compare_to);
    end;

    // Is this "equals" or "not equals"?
    if subraceconditional.ItemIndex = 0 then
        begin compare := ' != ';    notbe := 'be ';     end
    else
        begin compare := ' == ';    notbe := 'not be '; end;

    // The code to add to the script:
    new_lines[0] := '// The subrace of oPC must '+notbe + '"'+subrace.Text+'".';
    new_lines[1] := 'if ( '+func_call + compare + '"'+compare_to+'" )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Generates the NWScript lines for a check on oPC's saves.
procedure Tpcstats.SaveScript();
var
    versus: shortstring;
    DC:     shortstring;
    new_lines:  array[0..2] of shortstring;
begin
    // For all three saves:
    new_lines[2] := s_ReturnFalse;
    if SaveType.ItemIndex = 0 then
        versus := ''  // For a slightly prettier script.
    else
        versus := ', '+SymConst(SAVING_THROW_TYPE, SaveType.ItemIndex);

    if fortitude.checked then begin
        // Require a fortitude saving throw.
        DC := fortitudeDC.Text;
        new_lines[0] := '// The PC must pass a DC '+DC+' fortitude save.';
        new_lines[1] := 'if ( !FortitudeSave('+s_oPC+', '+DC+ versus+') )';
        Tlilac.AddLines(new_lines);
    end;

    if reflex.checked then begin
        // Require a reflex saving throw.
        DC := reflexDC.Text;
        new_lines[0] := '// The PC must pass a DC '+DC+' reflex save.';
        new_lines[1] := 'if ( !ReflexSave('+s_oPC+', '+DC+ versus+') )';
        Tlilac.AddLines(new_lines);
    end;

    if will.checked then begin
        // Require a will saving throw.
        DC := willDC.Text;
        new_lines[0] := '// The PC must pass a DC '+DC+' will save.';
        new_lines[1] := 'if ( !WillSave('+s_oPC+', '+DC+ versus+') )';
        Tlilac.AddLines(new_lines);
    end;

end;


// Generates the NWScript lines for a check of oPC having a skill.
procedure Tpcstats.HasSkillScript();
var
    nCount: integer;
    new_lines: array[0..2] of shortstring;
begin
    // Look for what selections were made.
    for nCount := 0 to CheckListBox2.Items.Count - 1 do
        if checklistbox2.Checked[nCount] then begin
            new_lines[0] := '// The PC must be able to use the ' + lowercase(CheckListBox2.Items[nCount]) + ' skill.';
            new_lines[1] := 'if ( !GetHasSkill('+
                             NameToConstant('SKILL', CheckListBox2.Items[nCount])+
                             ', '+s_oPC+') )';
            new_lines[2] := s_ReturnFalse;
            Tlilac.AddLines(new_lines);
        end;
end;


procedure Tpcstats.SkillRankScript();
var
    req_level:  shortstring;
    base_param: shortstring;     base_desc: shortstring;
    nCount:     integer;
    new_lines: array[0..2] of shortstring;
begin
    // The information that is invariant over the skills chosen.
    req_level := SpinEdit1.Text;
    if skillgroup.itemindex = 1 then
        begin base_param := s_comma_TRUE;   base_desc := req_level + ' base ranks'; end
    else
        begin base_param := '';             base_desc := 'a skill of ' + req_level; end;

    // Look for what selections were made.
    for nCount := 0 to CheckListBox1.Items.Count -1 do
        if CheckListBox1.Checked[nCount] then begin
            new_lines[0] := '// The PC must have at least ' + base_desc + ' in ' +
                                lowercase(CheckListBox1.Items[nCount]) + '.';
            new_lines[1] := 'if ( GetSkillRank('+ SymConst(SKILL_NAME, nCount)+
                                  ', '+s_oPC + base_param+') < '+ req_level +' )';
            new_lines[2] := s_ReturnFalse;
            Tlilac.AddLines(new_lines);
        end;
end;


procedure Tpcstats.SkillcheckScript();
var
    req_level:    shortstring;
    part1, part2: shortstring;
    nCount:       integer;
    new_lines:    array[0..2] of shortstring;
begin
    // The information that is invariant over the skills chosen.
    req_level := SpinEditSkillRoll.Text;

    // Should the player see the roll?
    if RadioSkillRoll.itemindex = 0 then begin
        part1 := '!GetIsSkillSuccessful('+s_oPC+', '; // followed by: SKILL_*
        part2 := ', '+req_level+')';
      end
    else begin
        part1 := 'd20() + GetSkillRank(';       // followed by: SKILL_*
        part2 := ', '+s_oPC+') < '+req_level;
    end;

    // Look for what selections were made.
    for nCount := 0 to CheckListSkillRoll.Items.Count - 1 do
        if CheckListSkillRoll.Checked[nCount] then begin
            new_lines[0] := '// The PC must pass a DC '+req_level+' '+
                            lowercase(CheckListSkillRoll.Items[nCount]) + ' check.';
            new_lines[1] := 'if (  ';
            if RestrictedSkill[nCount] then
                // The PC needs to be able to use the skill in the first place.
                new_lines[1] += '!GetHasSkill('+SymConst(SKILL_NAME, nCount)+', '+s_oPC+')  ||  ';
            new_lines[1] += part1 + SymConst(SKILL_NAME, nCount) + part2 + ' )';
            new_lines[2] := s_ReturnFalse;
            Tlilac.AddLines(new_lines);
        end;
end;


// -----------------------------------------------------------------------------
// Event handlers


// Initializes the form.
// (The feat data is generated from a central source referenced by multiple forms.)
procedure Tpcstats.FormCreate(Sender: TObject);
begin
    // Load the initial set of feats.
    LoadConstants(featbox.Items, FEAT_COMMON);
    // Load the "save vs." types.
    LoadConstants(SaveType.Items, SAVING_THROW_TYPE);
    SaveType.ItemIndex := 0;

    // Load the skill names.
    LoadConstants(CheckListBox1.Items, SKILL_NAME);
    LoadConstants(CheckListSkillRoll.Items, SKILL_NAME);

    // Adjust for Windows' widget layout.
    {$ifdef WIN32}
    BevelAlignment.Left := BevelAlignment.Left - 2;
    BevelAlignment.Top := BevelAlignment.Top + 16;
    BevelAlignment.Height := BevelAlignment.Height - 12;
    AlignmentShader.Left := AlignmentShader.Left - 2;
    AlignmentShader.Top := AlignmentShader.Top + 16;
    AlignmentShader.Height := AlignmentShader.Height - 12;
    {$endif}
end;


// Handles clicks of the "Next" and "Okay" buttons.
procedure Tpcstats.ButtonClick(Sender: TObject);
begin
    // Update the script in the script window.
    case Views[ViewIndex] of
        PCSTAT_Ability:     AbilityScript();
        PCSTAT_Alignment:   AlignmentScript();
        PCSTAT_Class:       ClassScript();
        PCSTAT_Multiclass:  MulticlassScript();
        PCSTAT_Deity:       DeityScript();
        PCSTAT_Feat:        FeatScript();
        PCSTAT_Gender:      GenderScript();
        PCSTAT_Level:       LevelScript();
        PCSTAT_ClassLevel:  LevelbyclassScript();
        PCSTAT_Race:        RaceScript();
        PCSTAT_Subrace:     SubraceScript();
        PCSTAT_SavingThrow: SaveScript();
        PCSTAT_HasSkill:    HasSkillScript();
        PCSTAT_SkillRank:   SkillRankScript();
        PCSTAT_SkillRoll:   SkillcheckScript();
    end;

    // Update our display.
    // (Possibly closes the window.)
    MakeNextVisible();
end;


// Responds to toggles of the race checkboxes.
procedure Tpcstats.RaceClick(Sender: TObject);
var
    race_count: integer = 0;
begin
    // See how many races are selected.
    if CheckBoxDwarf.Checked    then Inc(race_count);
    if CheckBoxElf.Checked      then Inc(race_count);
    if CheckBoxGnome.Checked    then Inc(race_count);
    if CheckBoxHalfling.Checked then Inc(race_count);
    if CheckBoxHalfElf.Checked  then Inc(race_count);
    if CheckBoxHalfOrc.Checked  then Inc(race_count);
    if CheckBoxHuman.Checked    then Inc(race_count);

    // Update the visibility of the warning.
    RaceAdvisor.Visible := race_count > 3;
end;


// Updates the feat drop-down when the radio buttons are clicked.
procedure Tpcstats.RadioGroupFeatTypeClick(Sender: TObject);
begin
    // Update the feat box.
    case RadioGroupFeatType.ItemIndex of
        0: LoadConstants(featbox.Items, FEAT_COMMON);
        1: LoadConstants(featbox.Items, FEAT_SPECIAL);
        2: LoadConstants(featbox.Items, FEAT_EPIC);
    end;
end;


// -----------------------------------------------------------------------------
// Private methods.


// Morphs the form to show the next view that was requested.
procedure Tpcstats.MakeNextVisible();
begin
    // Hide the current panel (if there is a current).
    if ViewIndex >= 0 then
        ViewToPanel(Views[ViewIndex]).Visible := false;
    // Also hide an info box that might have appeared.
    RaceAdvisor.Visible := FALSE;

    // Advance to the next view.
    ViewIndex += 1;

    // Check for running out of views.
    if ViewIndex > High(Views) then begin
        Close();
        exit;
    end;

    // Size the window for the next panel.
    case Views[ViewIndex] of
        PCSTAT_Ability:     begin height := 280; width := 360; end;
        PCSTAT_Alignment:   begin height := 280; width := 430; end;
        PCSTAT_Class:       begin height := 280; width := 550; end;
        PCSTAT_Multiclass:  begin height := 280; width := 360; end;
        PCSTAT_Deity:       begin height := 280; width := 220; end;
        PCSTAT_Feat:        begin height := 280; width := 400; end;
        PCSTAT_Gender:      begin height := 280; width := 200; end;
        PCSTAT_Level:       begin height := 280; width := 220; end;
        PCSTAT_ClassLevel:  begin height := 280; width := 410; end;
        PCSTAT_Race:        begin height := 280; width := 380; end;
        PCSTAT_Subrace:     begin height := 280; width := 220; end;
        PCSTAT_SavingThrow: begin height := 280; width := 400; end;
        PCSTAT_HasSkill:    begin height := 540; width := 477; end;
        PCSTAT_SkillRank:   begin height := 540; width := 477; end;
        PCSTAT_SkillRoll:   begin height := 540; width := 477; end;
    end;

    // Display the new panel.
    ViewToPanel(Views[ViewIndex]).Visible := true;
    Position := poMainFormCenter;   // Does not seem to do anything, but maybe
                                    // it will with a different widget set.

    // Make sure the correct button is displayed.
    bitbtn1.visible := ViewIndex = High(Views); // "Okay"
    bitbtn2.visible := ViewIndex < High(Views); // "Next"
end;


// Converts an enumerated view to the panel/TControl that is that view (the
// one that needs to be shown/hidden to make the view shown/hidden).
function Tpcstats.ViewToPanel(View: TPCStatsEnum) : TControl;
begin
    // A simple lookup. Split into its own function because it is called
    // in more than one spot.
    case View of
        PCSTAT_Ability:     result := PanelAbilities;
        PCSTAT_Alignment:   result := PanelAlignment;
        PCSTAT_Class:       result := classrestriction;
        PCSTAT_Multiclass:  result := multiclass;
        PCSTAT_Deity:       result := PanelDeity;
        PCSTAT_Feat:        result := PanelFeats;
        PCSTAT_Gender:      result := gender;
        PCSTAT_Level:       result := PanelLevels;
        PCSTAT_ClassLevel:  result := levelbyclassrestriction;
        PCSTAT_Race:        result := PanelRace;
        PCSTAT_Subrace:     result := PanelSubrace;
        PCSTAT_SavingThrow: result := SaveRestriction;
        PCSTAT_HasSkill:    result := panel2;
        PCSTAT_SkillRank:   result := panel1;
        PCSTAT_SkillRoll:   result := PanelSkillRoll;
    end;
end;


initialization
  {$i pcstats_int.lrs}
end.
