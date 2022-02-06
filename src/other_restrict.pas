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
* Some of this was trimmed when I converted the form to being really modal instead
*   of simulated modal, and simulated radio buttons to actual radio buttons.
* Cleanup of the generated scripts.
}
{
NOTE:

This form is largely a copy of "chooseif", with a few labels changed and the
addition of an "okay - more" button and of options of what to do if the
condition is not met. In addition (or subtraction, as the case may be), this
form lacks the die-rolling randomness option.

The code is (now) largely copied from the "chooseif" unit, with logical operators
reversed (chooseif detects if a condition is met, while this unit detects if
it is not met), with the addition of handling what to do if the condition is
not met.

It seems like there should be some way to merge this unit, chooseif, and the
various units devoted to making a conditional script, but that would probably
be more time than it is worth. --TK
}


{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit other_restrict;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, ExtCtrls, Spin, Buttons,
  LResources, QueueForm;

type

  { Totherrestrictions }

  Totherrestrictions = class(TQueueForm)
    // Form elements.
      ability: TSpinEdit;
      abilitychoice: TRadioGroup;
      abilitycondition: TRadioGroup;
      abilitygroup: TRadioGroup;
      abilitypanel: TPanel;
      alignment: TRadioGroup;
      alignmentconditional: TRadioGroup;
      alignmentpanel: TPanel;
      AlignmentShader: TShape;
      arcanearcherx: TCheckBox;
      assassinx: TCheckBox;
      EditMessage: TEdit;
      BarbarianX: TCheckBox;
      BardX: TCheckBox;
      BevelAlignment: TBevel;
      blackguardx: TCheckBox;
      ButtonPalette: TBitBtn;
      ButtonPartyInfo: TBitBtn;
      CheckBox1: TCheckBox;
      CheckLocalCaseSensitive: TCheckBox;
      CheckShowSkillRoll: TCheckBox;
      classcond: TRadioGroup;
      classrestriction: TPanel;
      ClericX: TCheckBox;
      ComboBox2: TComboBox;
      ComboBox3: TComboBox;
      ComboLocalType: TComboBox;
      dawncheck: TCheckBox;
      daycheck: TCheckBox;
      defenderx: TCheckBox;
      DeityCase: TCheckBox;
      deitypanel: TPanel;
      difficulty: TSpinEdit;
      dragonx: TCheckBox;
      DruidX: TCheckBox;
      duskcheck: TCheckBox;
      dwarfX: TCheckBox;
      Edit1: TEdit;
      Edit2: TEdit;
      EditItemName: TLabeledEdit;
      EditLocalValue: TEdit;
      EditWaypoint: TEdit;
      elfX: TCheckBox;
      featbox: TComboBox;
      featpanel: TPanel;
      FighterX: TCheckBox;
      fromhour: TSpinEdit;
      Gender: TRadioGroup;
      GenderPanel: TPanel;
      GnomeX: TCheckBox;
      goldcond: TRadioGroup;
      goldrestriction: TPanel;
      goldvalue: TSpinEdit;
      GroupFeatType: TRadioGroup;
      GroupGoldParty: TRadioGroup;
      GroupItemParty: TRadioGroup;
      GroupJournalCompare: TRadioGroup;
      GroupLevelParty: TRadioGroup;
      GroupLocalCompare: TRadioGroup;
      GroupLocalParty: TRadioGroup;
      GroupUnsatisfy: TGroupBox;
      halfelfX: TCheckBox;
      halflingX: TCheckBox;
      halforcX: TCheckBox;
      harperscoutx: TCheckBox;
      HumanX: TCheckBox;
      intname: TEdit;
      itemrestriction: TPanel;
      itemtag: TEdit;
      journalint: TPanel;
      journaltag: TEdit;
      Label11: TLabel;
      Label12: TLabel;
      Label13: TLabel;
      Label14: TLabel;
      Label15: TLabel;
      Label16: TLabel;
      Label18: TLabel;
      Label20: TLabel;
      Label22: TLabel;
      Label23: TLabel;
      Label24: TLabel;
      Label25: TLabel;
      Label26: TLabel;
      Label27: TLabel;
      Label6: TLabel;
      Label8: TLabel;
      Label9: TLabel;
      LabelAbilityRestriction: TLabel;
      LabelAlignmentRestriction: TLabel;
      LabelClassRestriction: TLabel;
      LabelDeityRestriction: TLabel;
      LabelFeatRestriction: TLabel;
      LabelGenderRestriction: TLabel;
      LabelGoldRestriction: TLabel;
      LabelItemRestriction: TLabel;
      LabelJournalStage: TLabel;
      LabelLevelByClass: TLabel;
      LabelLevelRestriction: TLabel;
      LabelLocalName: TLabel;
      LabelLocalType: TLabel;
      LabelRaceRestriction: TLabel;
      LabelSaveVersus: TLabel;
      LabelSaveWhich: TLabel;
      LabelSubraceRestriction: TLabel;
      LabelTime: TLabel;
      LabelCondition: TLabel;
      levelbyclassrestriction: TPanel;
      levelclass: TComboBox;
      levelclasscond: TRadioGroup;
      levelcond: TRadioGroup;
      levelrestriction: TPanel;
      levels: TSpinEdit;
      levelvalue: TSpinEdit;
      localpanel: TPanel;
    Memo1: TMemo;
    ComboBox1: TComboBox;
    MemoHoursOfDay: TMemo;
    MemoTimeOfDay: TMemo;
    MonkX: TCheckBox;
    nightcheck: TCheckBox;
    PaladinX: TCheckBox;
    palemasterx: TCheckBox;
    PanelHoursOfDay: TPanel;
    PanelPartyInfo: TPanel;
    PanelTimeOfDay: TPanel;
    PurpleDragonX: TCheckBox;
    racecond: TRadioGroup;
    racerestriction: TPanel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    RadioGroup3: TRadioGroup;
    RadioGroup4: TRadioGroup;
    RadioHoursOfDay: TRadioButton;
    RadioLocalEqual: TRadioButton;
    RadioLocalGreater: TRadioButton;
    RadioLocalLess: TRadioButton;
    RadioLocalNotEqual: TRadioButton;
    RadioTimeOfDay: TRadioButton;
    randompanel: TPanel;
    RangerX: TCheckBox;
    RogueX: TCheckBox;
    savepanel: TPanel;
    savetype: TComboBox;
    shadowdancerx: TCheckBox;
    shifterx: TCheckBox;
    skillcheckpanel: TPanel;
    skilllist: TComboBox;
    SorcererX: TCheckBox;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SubraceCase: TCheckBox;
    subracepanel: TPanel;
    TextItemPalettes: TStaticText;
    TextPartyInfo: TStaticText;
    Timepanel: TPanel;
    tohour: TSpinEdit;
    tormx: TCheckBox;
    RadioWaypoint: TRadioButton;
    RadioMessage: TRadioButton;
    RadioNothing: TRadioButton;
    Memo2: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    weaponmasterx: TCheckBox;
    WizardX: TCheckBox;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    // Events for widgets in the subpanels:
    procedure GroupFeatTypeClick(Sender: TObject);
    procedure ButtonPaletteClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ComboLocalTypeChange(Sender: TObject);
    procedure EditLocalValueChange(Sender: TObject);
    procedure GroupLocalPartyClick(Sender: TObject);
    procedure ButtonPartyInfoClick(Sender: TObject);

  private
    // Bookkeeping field.
    ShownPanel: TPanel;  // Tracks which auxiliary panel is currently shown.

  protected
    // Helper methods.
    procedure ClearForm(); override;
    procedure QueueThis(); override;

  private
    // Panel-specific script producers.
    procedure Abilityres();
    procedure Alignmentres();
    procedure Classres();
    procedure DeityRes();
    procedure FeatRes();
    procedure GenderRes();
    procedure Goldres();
    procedure Itemres();
    procedure Journalres();
    procedure LevelClassRes();
    procedure Levelres();
    procedure Localintres();
    procedure Raceres();
    procedure RandomRes();
    procedure SaveRes();
    procedure SkillRes();
    procedure SubRaceRes();
    procedure Timeres();
    // The script producers called by the panel-specific procedures.
    procedure Restrain(const condition, cond_desc: shortstring); overload;
    procedure Restrain(const conditions: array of shortstring; const cond_desc: shortstring); overload;
    function  DenyFirst(): shortstring;
    procedure DenyFinish();
  end;

{var
  otherrestrictions: Totherrestrictions;
}

// -----------------------------------------------------------------------------

implementation

uses
    start, nwn, {event, chooseif}
    palettetool, constants, party_doc, ExtForm;


// Initializes the form based on the current situation.
procedure Totherrestrictions.FormCreate(Sender: TObject);
begin
    // Initializations.
    ShownPanel := nil;

    // Load some list boxes.
    LoadConstants(featbox.Items, FEAT_COMMON);
    LoadConstants(SkillList.Items, SKILL_NAME);
    LoadConstants(ComboBox3.Items, SAVING_THROW_TYPE);
    ComboBox3.ItemIndex := 0;
    LoadConstants(ComboBox2.Items, INVENTORY_SLOT);
    // Add the multiple choice slots.
    // These must be done in order from largest index to smallest!
    ComboBox2.Items.Insert(INVENTORY_SLOT_ANY_CREATURE, INVENTORY_SLOT_ANY_CREATURE_NAME);
    ComboBox2.Items.Insert(INVENTORY_SLOT_EITHER_RING, INVENTORY_SLOT_EITHER_RING_NAME);
    ComboBox2.Items.Insert(INVENTORY_SLOT_EITHER_HAND, INVENTORY_SLOT_EITHER_HAND_NAME);
    ComboBox2.ItemIndex := 0;

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


// Handles the selection of the type of restriction by showing the appropriate
// panel.
procedure Totherrestrictions.ComboBox1Change(Sender: TObject);
begin
    // Hide the previous panel.
    if ShownPanel <> nil then begin
        ShownPanel.Visible := false;
        ShownPanel := nil;
    end;

    // Determine the next panel to show.
    case combobox1.itemindex of
         0: ShownPanel := abilitypanel;
         1: ShownPanel := alignmentpanel;
         2: ShownPanel := Classrestriction;
         3: ShownPanel := deitypanel;
         4: ShownPanel := Featpanel;
         5: ShownPanel := GenderPanel;
         6: ShownPanel := Goldrestriction;
         7: ShownPanel := Itemrestriction;
         8: ShownPanel := journalint;
         9: ShownPanel := Levelrestriction;
        10: ShownPanel := Levelbyclassrestriction;
        11: ShownPanel := localpanel;
        12: ShownPanel := Racerestriction;
        13: ShownPanel := randompanel;
        14: ShownPanel := savepanel;
        15: ShownPanel := skillcheckpanel;
        16: ShownPanel := subracepanel;
        17: ShownPanel := timepanel;
    end;

    // Show the panel.
    if ShownPanel <> nil then
        ShownPanel.visible := true;

    // Update the "Okay" button.
    ToggleOkay(Sender);
end;


// Handles the enabled state of the "Okay" buttons.
procedure Totherrestrictions.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // Whether more info is needed depends on the selection.
    case combobox1.itemindex of
        // Panels with full defaults (nothing needs checking here):
        // Alignment, deity, gender, gold, total level, random, and subrace panels:
        1,3,5,6,9,13,16: bEnable := TRUE;

        // Ability panel:
        0 : bEnable := abilitychoice.itemindex >= 0;
        // Class panel:
        2 : bEnable := barbarianx.checked  or  bardx.checked     or  clericx.checked  or
                       druidx.checked      or  fighterx.checked  or  monkx.checked    or
                       paladinx.checked    or  rangerx.checked   or  roguex.checked   or
                       sorcererx.checked   or  wizardx.checked   or
                       arcanearcherx.checked  or  assassinx.checked          or
                       blackguardx.checked    or  tormx.checked              or
                       defenderx.checked      or  harperscoutx.checked       or
                       palemasterx.checked    or  PurpleDragonX.Checked  or
                       dragonx.checked        or  shadowdancerx.checked      or
                       shifterx.checked       or  weaponmasterx.checked;
        // Feat panel:
        4 : bEnable := featbox.ItemIndex >= 0;
        // Item panel
        7 : bEnable := itemtag.text <> '';
        // Journal panel
        8 : bEnable := journaltag.text <> '';
        // Level by class panel
        10: bEnable := levelclass.ItemIndex >= 0;
        // Local variable panel
        11: bEnable := intname.Text <> '';
        // Race panel
        12: bEnable := dwarfX.Checked   or elfX.Checked      or GnomeX.Checked   or
                       halfelfX.Checked or halflingX.Checked or halforcX.Checked or
                       HumanX.Checked;
        // Save panel:
        14: bEnable := savetype.ItemIndex >= 0;
        // Skill panel:
        15: bEnable := SkillList.ItemIndex >= 0;
        // Time panel:
        17: bEnable := nightcheck.checked  or  daycheck.checked   or
                       duskcheck.checked   or  dawncheck.checked  or
                       RadioHoursOfDay.checked;

        // Else, no selection made, so there is nothing to "okay".
        else bEnable := FALSE;
    end;

    // Also verify the stuff to do if the condition fails.
    if bEnable then begin
        if      RadioMessage.Checked  then bEnable := EditMessage.Text  <> ''
        else if RadioWaypoint.Checked then bEnable := EditWaypoint.Text <> '';
        // Else we leave bEnable as is (that is, TRUE).
    end;

    // Update the buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------


// Handles the selection of the feat type (common, special, epic).
procedure Totherrestrictions.GroupFeatTypeClick(Sender: TObject);
begin
    // Update the feat box.
    case GroupFeatType.ItemIndex of
        0: LoadConstants(featbox.Items, FEAT_COMMON);
        1: LoadConstants(featbox.Items, FEAT_SPECIAL);
        2: LoadConstants(featbox.Items, FEAT_EPIC);
    end;

    // Update the "Okay" button.
    ToggleOkay(Sender);
end;


// Handles clicks of the item "Palette" button.
procedure Totherrestrictions.ButtonPaletteClick(Sender: TObject);
begin
    // Call up the palette window, items by default.
    TPaletteWindow.Load(itemtag, EditItemName, SEARCH_ITEMS, FALSE);
end;


// Handles changes to the "item must be equipped" checkbox.
procedure Totherrestrictions.CheckBox1Click(Sender: TObject);
begin
    // When checked, the combo box is enabled, but not the radio group.
    // When not checked, vice versa.
    combobox2.enabled := checkbox1.checked;
    GroupItemParty.Enabled := not checkbox1.checked;
    // Reset the selection to reduce confusion.
    if not GroupItemParty.Enabled then
        GroupItemParty.ItemIndex := 0;
end;


// Handles changes in the selection of int vs. string vs. float.
procedure Totherrestrictions.ComboLocalTypeChange(Sender: TObject);
var
    bString:  boolean;
begin
    bString := ComboLocalType.ItemIndex = 2;

    // Update the available radio/check buttons.
    if bString and ( RadioLocalLess.Checked or RadioLocalGreater.Checked ) then
        RadioLocalNotEqual.Checked := TRUE;
    RadioLocalLess.Visible    := not bString;
    RadioLocalGreater.Visible := not bString;
    CheckLocalCaseSensitive.Visible := bString;

    // Validate the value.
    EditLocalValueChange(Sender);
end;


// Validates the value entered for a local variable, based on local variable type.
procedure Totherrestrictions.EditLocalValueChange(Sender: TObject);
begin
    EditChangeValidateNumeric(EditLocalValue, ComboLocalType.ItemIndex, Sender = EditLocalValue);
end;


// Shows/hides the party info panel as appropriate.
procedure Totherrestrictions.GroupLocalPartyClick(Sender: TObject);
begin
    PanelPartyInfo.Visible := GroupLocalParty.ItemIndex = 1;
end;


// Calls up the party info form.
procedure Totherrestrictions.ButtonPartyInfoClick(Sender: TObject);
begin
    main.ShowPopup(TPartydoc);
end;


// -----------------------------------------------------------------------------


// Clears the old selection so a new one can be made.
// LS cleared everything, but I think just resetting the type of restriction
// (and hiding the subpanel) should be enough and should make it easier for the
// user to keep track of what has been done. --TK
procedure Totherrestrictions.ClearForm();
begin
    // Reset the selection.
    ComboBox1.ItemIndex := -1;
    // Force an update of the subpanels.
    ComboBox1Change(ComboBox1);
end;


// Sends the currently selected restriction to the script window.
procedure Totherrestrictions.QueueThis();
begin
    case combobox1.itemindex of
        0 : abilityres();
        1 : alignmentres();
        2 : classres();
        3 : deityres();
        4 : featres();
        5 : GenderRes();
        6 : goldres();
        7 : Itemres();
        8 : Journalres();
        9 : levelres();
        10: levelclassres();
        11: localintres();
        12: raceres();
        13: randomres();
        14: saveres();
        15: skillres();
        16: subraceres();
        17: timeres();
    end;
end;


// -----------------------------------------------------------------------------


// Adds an ability restriction to the script window.
procedure Totherrestrictions.Abilityres();
var
    sAbility:   shortstring;
    base_param: shortstring;    base_desc: shortstring;
    compare:    string[2];      at_least:  shortstring;
begin
    // Let's shorten how to refer to the selection.
    sAbility := lowercase(abilitychoice.Items[abilitychoice.ItemIndex]);

    // Modified or base score?
    case abilitygroup.itemindex of
        0: begin base_param := '';             base_desc := 'current '; end;
        1: begin base_param := s_comma_TRUE;   base_desc := 'base ';    end;
    end;

    // At least or at most?
    case abilitycondition.itemindex of
        0: begin compare := '< ';      at_least := 'at least '; end;
        1: begin compare := '> ';      at_least := 'at most ';   end;
    end;

    // Create the restraint.
    Restrain('GetAbilityScore('+s_oPC+', ABILITY_'+uppercase(sAbility)+base_param+') '+
                 compare +ability.Text,
             'the PC''s '+base_desc +sAbility+ ' is not '+at_least + ability.Text);
end;


// Adds an alignment restriction to the script window.
procedure Totherrestrictions.Alignmentres();
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
    is_not:  string[7];

    last_cond:  integer;
    conditions: array[0..1] of shortstring;
begin
    // Initializations.
    good_evil := alignment.itemindex div 4;
    law_chaos := alignment.itemindex mod 4;
    case alignmentconditional.itemindex of
        0: begin compare := '!= ';  joiner := '  ||';   is_not := 'is not '; end;
        1: begin compare := '== ';  joiner := '  &&';   is_not := 'is ';     end;
    end;
    // Special case: "any neutral" reverses the joiner.
    if alignment.itemindex = 15 then
        case alignmentconditional.itemindex of
            0: joiner := '  &&';
            1: joiner := '  ||';
        end;
    last_cond := 0;

    // Make a good-evil check?
    if good_evil < 3 then begin
        // Add a check for the good-evil alignment.
        conditions[0] := 'GetAlignmentGoodEvil('+s_oPC+') ' + compare +
                         SymConst(ALIGNMENT_GE, good_evil);

        // Is there also a law-chaos check?
        if law_chaos < 3 then begin
            // Join with an "and" or "or".
            conditions[0] += joiner;
            // Advance to the next line.
            last_cond := 1;
        end;
    end;

    // Make a law-chaos check?
    if law_chaos < 3 then
        // Add a check for the law-chaos alignment.
        conditions[last_cond] := 'GetAlignmentLawChaos('+s_oPC+') ' + compare +
                                 SymConst(ALIGNMENT_LC, law_chaos);

    // Special case: any neutral.
    if (good_evil = 3)  and  (law_chaos = 3) then begin
        conditions[0] := 'GetAlignmentGoodEvil('+s_oPC+') '+compare +SymConst(ALIGNMENT_GE, 1) +joiner;
        conditions[1] := 'GetAlignmentLawChaos('+s_oPC+') '+compare +SymConst(ALIGNMENT_LC, 1);
        last_cond := 1;
    end;

    // Create the restraint.
    Restrain(conditions[0..last_cond],
             'the PC''s alignment '+is_not +lowercase(alignment.Items[alignment.ItemIndex]));
end;


// Adds a class restriction to the script window.
procedure Totherrestrictions.Classres();
var
    classes: ClassCheck;
    eClass:  TClassEnum;
    compare, joiner: shortstring;
    sNot:            shortstring;
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

    // Configuring the two cases:
    if classcond.itemindex = 0 then begin
        // Must be one of these classes.
        sNot    := 'not ';
        compare := ' == 0';
        joiner  := '  &&';
    end
    else begin
        // Must not be one of these classes.
        sNot    := '';
        compare := ' != 0';
        joiner  := '  ||';
    end;

    // Add the appropriate lines.
    Tlilac.AddClassString('// Abort if the PC is '+sNot+'a certain class.',
                          'if ( ', classes, compare, joiner, ' )',
                          DenyFirst());
    DenyFinish();
end;


// Adds a deity restriction to the script window.
procedure Totherrestrictions.DeityRes();
var
    func_call:  shortstring;
    compare:    string[4];   is_not:     shortstring;
    compare_to: shortstring; deity_name: shortstring;
begin
    // Mess with the provided name.
    deity_name := edit2.text;
    compare_to := QuoteSwap(deity_name);
    if deity_name = '' then
        deity_name := 'blank';

    // Construct the function to call.
    func_call := 'GetDeity('+s_oPC+')';
    // See if this should be made case-insensitive.
    if not DeityCase.Checked  and  (compare_to <> '') then begin
        func_call := 'GetStringLowerCase('+func_call+')';
        compare_to := lowercase(compare_to);
    end;

    // Is this "equals" or "not equals"?
    case radiogroup3.itemindex of
        0: begin compare := ' != ';    is_not := 'is not '; end;
        1: begin compare := ' == ';    is_not := 'is ';     end;
    end;

    // Create the restraint.
    Restrain(func_call + compare + '"'+compare_to+'"', 'the PC''s deity '+is_not +deity_name);
end;


// Adds a feat restriction to the script window.
procedure Totherrestrictions.FeatRes();
var
    has:    shortstring;
    prefix: string[1];
    feat:   shortstring;
begin
    // Check for negation.
    case radiogroup4.itemindex of
        0: prefix := '!'; // has it
        1: prefix := '';  // does not have it
    end;
    has := radiogroup4.Items[1-radiogroup4.itemindex];

    // Look up the feat's NWScript constant.
    case GroupFeatType.ItemIndex of
        0: feat := SymConst(FEAT_COMMON, featbox.ItemIndex);
        1: feat := SymConst(FEAT_SPECIAL, featbox.ItemIndex);
        2: feat := SymConst(FEAT_EPIC, featbox.ItemIndex);
    end;

    // Create the restraint.
    Restrain(prefix+'GetHasFeat('+feat+', '+s_oPC+')',
             'the PC '+has+' the '+lowercase(featbox.text)+' feat');
end;


// Adds a gender restriction to the script window.
procedure Totherrestrictions.GenderRes();
var
    gender_text: shortstring;
begin
    // For simpler reference:
    gender_text := gender.Items[gender.ItemIndex];

    // Create the restraint.
    Restrain('GetGender('+s_oPC+') != GENDER_'+uppercase(gender_text),
             'the PC is not '+gender_text);
end;


// Adds a gold restriction to the script window.
procedure Totherrestrictions.Goldres();
var
    func_call: shortstring;
    compare:   string[3];
    at_least:  shortstring;
begin
    // Party or PC?
    case GroupGoldParty.itemindex of
        0: func_call := 'GetGold';
        1: func_call := 'GetFactionGold';
    end;
    func_call += '('+s_oPC+') ';

    // Which comparison?
    case goldcond.itemindex of
        0: begin  compare := '< ';      at_least := 'at least ';    end;
        1: begin  compare := '>= ';     at_least := 'less than ';   end;
    end;

    // Create the restraint.
    Restrain(func_call + compare +goldvalue.Text,
             GroupGoldParty.Items[GroupGoldParty.ItemIndex]+' does not have '+
             at_least +goldvalue.Text+' gold');
end;


// Adds an item restriction to the script window.
procedure Totherrestrictions.Itemres();
var
    slot, num_slots:      integer;
    item_tag, item_name:  shortstring;
    not_have, party:      shortstring;

    last_cond:  integer;
    conditions: array of shortstring;
begin
    // Shorter way to refer to the item tag.
    item_tag := QuoteSwap(itemtag.text);

    // Must the item be equipped?
    if checkbox1.checked then begin
        slot := ComboBox2.ItemIndex;
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

        // Conditions:
        SetLength(conditions, num_slots);
        last_cond := -1;
        while num_slots > 0 do begin
            Inc(last_cond);
            conditions[last_cond] := '"'+item_tag+'" '+
                                     BoolToStr(radiogroup1.itemindex = 0, '!=', '==')+
                                     ' GetTag('+ Script.GetItemInSlot(slot, s_oPC)+')  '+
                                     BoolToStr(radiogroup1.itemindex = 0, '&&', '||');
            // Update counts.
            Inc(slot);
            Dec(num_slots);
        end;
        // Trim off the final '  ||' or '  &&'.
        SetLength(conditions[last_cond], Length(conditions[last_cond])-4);
    end

    // Else, just checking for possessing. By just the PC?
    else if GroupItemParty.ItemIndex = 0 then begin
        SetLength(conditions, 1);
        conditions[0] := Script.GetItemPossessedBy(s_oPC, item_tag) +
                         BoolToStr(radiogroup1.itemindex = 0, ' == ', ' != ') +
                         s_OBJECT_INVALID
    end

    // Else, checking for possession by the party.
    else begin
        SetLength(conditions, 1);
        conditions[0] := 'GetIsItemPossessedByParty('+s_oPC+', "'+item_tag+'")';
        if radiogroup1.itemindex = 0 then
            conditions[0] := '!'+conditions[0];
        // This will require including x0_i0_partywide.
        Tlilac.Include(INC_PARTYWIDE);
    end;


    // Build  a description for this condition.
    case radiogroup1.itemindex of
        0: not_have := 'does not have ';
        1: not_have := 'has ';
    end;
    case GroupItemParty.ItemIndex of
        0: party := ' ';
        1: party := '''s party ';
    end;
    item_name := EditItemName.Text;
    if item_name = '' then
        item_name := '"'+itemtag.Text+'"';
    if checkbox1.checked then
        item_name += ' equipped';

    // Create the restraint.
    Restrain(conditions, 'the PC'+party +not_have +'the item '+item_name);
end;


// Adds a journal restriction to the script window.
procedure Totherrestrictions.Journalres();
var
    compare: string[4];
    at_least: shortstring;
begin
    // Get the comparison to use.
    case GroupJournalCompare.ItemIndex of
        0: compare := ' < ';
        1: compare := ' != ';
        2: compare := ' >= ';
    end;
    at_least := GroupJournalCompare.Items[GroupJournalCompare.ItemIndex];

    // Create the restraint.
    Restrain(Script.JournalRead(s_oPC, QuoteSwap(journaltag.text))+ compare +spinedit1.Text,
             'the PC is not '+at_least+' stage '+spinedit1.Text+' of journal quest "'+journaltag.text+'"');
end;


// Adds a class level restriction to the script window.
procedure Totherrestrictions.LevelClassRes();
var
    compare:   string[3];      exactly:  shortstring;
begin
    // Less, more, or exactly?
    case levelclasscond.itemindex of
        0: begin compare := '!= ';  exactly := 'exactly ';   end;
        1: begin compare := '>= ';  exactly := 'less than '; end;
        2: begin compare := '<= ';  exactly := 'more than '; end;
    end;

    // Create the restraint.
    Restrain('GetLevelByClass('+SymConst(NWNCLASS, levelclass.ItemIndex)+', '+
                              s_oPC+') '+compare + levels.Text,
             'the PC does not have '+exactly +levels.Text+' levels of '+lowercase(levelclass.text));
end;


// Adds a character level restriction to the script window.
procedure Totherrestrictions.Levelres();
var
    compare:   string[2];       at_least: shortstring;
    func_name: shortstring;     party: shortstring;
begin
    // At least or at most?
    case levelcond.itemindex of
        0: begin compare := '< ';  at_least := 'at least '; end;
        1: begin compare := '> ';  at_least := 'at most ';  end;
    end;

    // PC or party?
    case GroupLevelParty.ItemIndex of
        0: begin func_name := 'GetHitDice';             party := 'total ';            end;
        1: begin func_name := 'GetFactionAverageLevel'; party := 'party''s average '; end;
    end;

    // Create the restraint.
    Restrain(func_name+'('+s_oPC+') '+compare +levelvalue.Text,
             'the PC''s '+party +'level is not '+at_least +levelvalue.Text);
end;


// Adds a local variable restriction to the script window.
procedure Totherrestrictions.Localintres();
var
    bString: boolean;
    func_name, var_type, params:  shortstring;
    goal_value: shortstring;
    compare: string[4];  comp_desc: shortstring;
    quote: string[1];
begin
    bString := ComboLocalType.ItemIndex = LV_STRING;
    quote := BoolToStr(bString, '"', '');

    // Construct parts of the function call that will retrieve the local value.
    if GroupLocalParty.ItemIndex = 0 then
        func_name := 'GetLocal'
    else begin
        Tlilac.Include(INC_LS_PARTY);
        func_name := 'GetParty';
    end;
    case ComboLocalType.ItemIndex of
        LV_INT:     var_type := 'Int';
        LV_FLOAT:   var_type := 'Float';
        LV_STRING:  var_type := 'String';
    end;
    params := '('+s_oPC+', "'+QuoteSwap(intname.text)+'")';

    // The goal value might need to be formatted.
    goal_value := EditLocalValue.Text;
    if bString then
        goal_value := '"'+QuoteSwap(goal_value)+'"'
    else if ComboLocalType.ItemIndex = LV_FLOAT then begin
        if Pos('.', goal_value) < 1 then
            goal_value += '.0';
    end;

    // Apply case sensitive.
    if bString and not CheckLocalCaseSensitive.Checked then begin
        func_name  := 'GetStringLowerCase('+func_name;
        params     += ')';
        goal_value := lowercase(goal_value);
    end;

    // Determine the comparison operator to use.
    if RadioLocalEqual.Checked        then begin compare := ' != ';  comp_desc := 'exactly ';   end
    else if RadioLocalLess.Checked    then begin compare := ' >= ';   comp_desc := 'less than '; end
    else if RadioLocalGreater.Checked then begin compare := ' <= ';   comp_desc := 'more than '; end
    else (* RadioLocalNotEqual.Checked *)  begin compare := ' == ';  comp_desc := 'not ';       end;

    // Create the restraint.
    Restrain(func_name+var_type+params + compare + goal_value,
             'the local '+lowercase(var_type)+' is not '+comp_desc +quote+EditLocalValue.Text+quote);
end;


// Adds a race restriction to the script window.
procedure Totherrestrictions.Raceres();
var
    racex: racialcheck;
    eRace: TRaceEnum;
    sNot, compare, joiner: shortstring;
begin
    // Make sure the RacialCheck is initialized to false (in case it covers
    // any races we don't cover here).
    for eRace := Low(TRaceEnum) to High(TRaceEnum) do
        racex[eRace] := false;

    // Mark which classes were selected.
    racex[E_Dwarf]    := dwarfx.checked;
    racex[E_Elf]      := elfx.checked;
    racex[E_Gnome]    := gnomex.checked;
    racex[E_HalfElf]  := halfelfx.checked;
    racex[E_Halfling] := halflingx.checked;
    racex[E_HalfOrc]  := halforcx.checked;
    racex[E_Human]    := humanx.checked;

    // Configuring the two cases:
    if racecond.itemindex <> 0 then begin
        // Must not be one of these races.
        sNot     := '';
        compare  := ' == ';
        joiner   := '  ||';
    end
    else begin
        // Must be one of these races.
        sNot     := 'not ';
        compare  := ' != ';
        joiner   := '  &&';
    end;

    // Add the appropriate lines.
    Tlilac.AddRaceString('// Abort if the PC is '+sNot+'a certain race.',
                         'if ( ', s_oPC, compare, racex, joiner, ' )',
                         DenyFirst());
    DenyFinish();
end;


// Adds a random (percentage) restriction to the script window.
procedure Totherrestrictions.RandomRes();
begin
    // Create the restraint.
    Restrain('Random(100) >= '+spinedit2.text,
             'failed a '+spinedit2.text+'% chance');
end;


// Adds a saving throw restriction to the script window.
procedure Totherrestrictions.saveres();
var
   versus: shortstring;
begin
    // An optional parameter:
    if combobox3.itemindex > 0 then
        versus := ', '+SymConst(SAVING_THROW_TYPE, combobox3.ItemIndex)
    else
        versus := '';

    // Create the restraint.
    Restrain('!'+savetype.Text+'Save('+s_oPC+', '+spinedit3.Text + versus+')',
             'a '+lowercase(savetype.Text)+' saving throw is failed');
end;


// Adds a skill restriction to the script window.
procedure Totherrestrictions.SkillRes();
var
    skill, condition: shortstring;
begin
    skill := SymConst(SKILL_NAME, skilllist.ItemIndex);

    // Decide which condition to use.
    if CheckShowSkillRoll.Checked then
        condition := '!GetIsSkillSuccessful('+s_oPC+', '+skill+', '+difficulty.Text+')'
    else
        condition := 'd20() + GetSkillRank('+skill+', '+s_oPC+') < '+difficulty.Text;

    // Plus, the PC should be able to use the skill in the first place.
    if RestrictedSkill[skilllist.ItemIndex] then
        condition := '!GetHasSkill('+skill+', '+s_oPC+')  ||  '+condition;

    // Create the restraint.
    Restrain(condition, 'a skill check ('+lowercase(skilllist.text)+') is failed');
end;


// Adds a subrace restriction to the script window.
procedure Totherrestrictions.SubRaceRes();
var
    func_call, compare_to, subrace_name: shortstring;
    compare: string[4];
    is_not:  string[7];
begin
    // Mess with the provided name.
    subrace_name := edit1.text;
    compare_to := QuoteSwap(subrace_name);
    if subrace_name = '' then
        subrace_name := 'blank';

    // Construct the function to call.
    func_call := 'GetSubRace('+s_oPC+')';
    // See if this should be made case-insensitive.
    if not SubraceCase.Checked  and  (compare_to <> '') then begin
        func_call := 'GetStringLowerCase('+func_call+')';
        compare_to := lowercase(compare_to);
    end;

    // The comparison to use.
    if radiogroup2.itemindex = 0 then begin
        compare := ' != ';
        is_not := 'is not ';
    end
    else begin
        compare := ' == ';
        is_not := 'is ';
    end;

    // Create the restraint.
    Restrain(func_call + compare + '"'+compare_to+'"',
             'the PC''s subrace '+is_not +subrace_name);
end;


// Adds a time restriction to the script window.
procedure Totherrestrictions.Timeres();
var
    condition, cond_desc: shortstring;
begin
    // Some strings for the opening comment and conditional.
    if RadioHoursOfDay.Checked then begin
        if fromhour.value = tohour.value then begin
            // A single hour.
            cond_desc := 'the current hour is not '+fromhour.Text;
            condition := 'GetTimeHour() != '+fromhour.Text;
        end
        else begin
            // An interval, possibly crossing midnight.
            cond_desc := 'the time is not from '+fromhour.Text+' to '+tohour.Text;
            condition := 'GetTimeHour() < '+fromhour.Text+
                         BoolToStr(fromhour.value < tohour.value, '  ||  ', '  &&  ')+
                         tohour.Text+' < GetTimeHour()';
        end;
    end
    else begin
        // One or more parts of the day were selected.
        cond_desc := 'it is not ';
        condition := '';
        // Build up the strings.
        if dawncheck.checked  then begin cond_desc += 'dawn nor '; condition += '!GetIsDawn()  &&  '; end;
        if daycheck.checked   then begin cond_desc += 'day nor ';  condition += '!GetIsDay()  &&  ';  end;
        if duskcheck.checked  then begin cond_desc += 'dusk nor '; condition += '!GetIsDusk()  &&  '; end;
        if nightcheck.checked then begin cond_desc += 'night';     condition += '!GetIsNight()';      end
        else begin
            // Trim off the last ' nor ' and '  &&  '.
            SetLength(cond_desc, Length(cond_desc)-5);
            SetLength(condition, Length(condition)-6);
        end;
    end;

    // Create the restraint.
    Restrain(condition, cond_desc);
end;


// -----------------------------------------------------------------------------


// Supplies the first line of the denial block (the script for what happens when
// a restraint is failed).
// (I split LS's "Deny" procedure into two routines. --TK)
function Totherrestrictions.DenyFirst(): shortstring;
begin
    // A simple return is a one-liner. Everything else needs a code block.
    if RadioNothing.Checked then
        result := s_Return
    else
        result := '{';
end;


// Adds to the script window all but the first line of the denial block (the
// script for what happens when a restraint is failed).
// (I split LS's "Deny" procedure into two routines. --TK)
procedure Totherrestrictions.DenyFinish();
var
    new_lines: array[0..2] of shortstring;
begin
    // The "nothing" option is only one line long, so nothing to do here.
    if RadioNothing.Checked then
        exit;

    if RadioMessage.Checked then begin
        // Send the requested message to the player and return.
        new_lines[0] := 'SendMessageToPC(oPC, "'+QuoteSwap(EditMessage.Text)+'");';
        new_lines[1] := 'return;';
        Tlilac.AddLines(new_lines[0..1]);
    end
    else if RadioWaypoint.Checked then begin
        // Jump the PC to the designated waypoint.
        new_lines[0] := s_oTarget+' = '+s_GetWaypoint + QuoteSwap(EditWaypoint.Text)+'");';
        new_lines[1] := s_AssignCommand + s_oPC +', JumpToObject('+s_oTarget+'));';
        new_lines[2] := 'return;';
        Tlilac.AddLines(new_lines[0..2]);
    end;

    // End the denial block.
    new_lines[0] := '}';
    Tlilac.AddLines(new_lines[0..0]);
end; //function


// The script producer called by the panel-specific procedures.
// _condition_ is NWScript to be put inside "if ( " and " )", while
// _cond_desc_ is English for comments.
procedure Totherrestrictions.Restrain(const condition, cond_desc: shortstring);
var
    conditions: array[0..0] of shortstring;
begin
    // This is now just a wrapper for the version that can handle multiple
    // lines of conditions.
    conditions[0] := condition;
    Restrain(conditions, cond_desc);
end;


// The script producer called by the panel-specific procedures.
// _conditions_ is NWScript to be put inside "if ( " and " )", while
// _cond_desc_ is English for comments.
// _conditions_ must not be zero-length.
// This procedure may be optimized for the common case of a single condition.
procedure Totherrestrictions.Restrain(const conditions: array of shortstring; const cond_desc: shortstring);
var
    iCondition: integer;
    last_line: integer;
    new_lines: array of shortstring;
begin
    // Allocate space.
    SetLength(new_lines, 2+Length(conditions)); // comment, conditions, plus first "deny" line.

    // The initial comment.
    new_lines[0] := '// Abort if '+cond_desc+'.';

    // The "if" statement.
    new_lines[1] := 'if ( '+conditions[0];
    // The remaining conditions (if any).
    for iCondition := 1 to High(conditions) do
        new_lines[1+iCondition] := '     '+conditions[iCondition];
    // End the "if" conditional.
    new_lines[1+High(conditions)] += ' )';
    last_line := High(conditions) + 2;

    // Start the denial block.
    new_lines[last_line] := DenyFirst();

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line]);

    // Finish the denial block.
    DenyFinish();
end;


initialization
  {$i other_restrict.lrs}
end.
