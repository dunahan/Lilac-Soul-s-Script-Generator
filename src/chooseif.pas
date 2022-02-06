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

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit chooseif;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Spin, ExtCtrls, {ComCtrls,} Buttons,
  LResources, ExtForm;


type

  { Tifchoose }

  Tifchoose = class(TExtForm)
    // Form elements.
    AlignmentShader: TShape;
    BevelAlignment: TBevel;
    BevelCompoundInfo: TBevel;
    BevelFinishingInfo: TBevel;
    ButtonPartyInfo: TBitBtn;
    CheckLocalCaseSensitive: TCheckBox;
    CheckShowSkillRoll: TCheckBox;
    ComboBox1: TComboBox;
    dawncheck: TCheckBox;
    daycheck: TCheckBox;
    die: TComboBox;
    dierollpanel: TPanel;
    EditLocalValue: TEdit;
    GroupGoldParty: TRadioGroup;
    GroupLocalCompare: TRadioGroup;
    GroupDieRolls: TCheckGroup;
    GroupLevelParty: TRadioGroup;
    EditItemName: TLabeledEdit;
    LabelRaceRestriction: TLabel;
    LabelSubraceRestriction: TLabel;
    LabelAlignmentRestriction: TLabel;
    LabelAbilityRestriction: TLabel;
    LabelDeityRestriction: TLabel;
    LabelClassRestriction: TLabel;
    LabelGenderRestriction: TLabel;
    LabelFeatRestriction: TLabel;
    LabelItemRestriction: TLabel;
    LabelGoldRestriction: TLabel;
    LabelJournalStage: TLabel;
    LabelLevelByClass: TLabel;
    Label21: TLabel;
    LabelLevelRestriction: TLabel;
    LabelLocalName: TLabel;
    LabelDieToRoll: TLabel;
    ComboLocalType: TComboBox;
    LabelLocalType: TLabel;
    PurpleDragonX: TCheckBox;
    PanelDice: TPanel;
    duskcheck: TCheckBox;
    fromhour: TSpinEdit;
    Label15: TLabel;
    Label16: TLabel;
    LabelSaveWhich: TLabel;
    LabelCondition: TLabel;
    LabelSaveVersus: TLabel;
    levelrestriction: TPanel;
    Label5: TLabel;
    levelcond: TRadioGroup;
    levelvalue: TSpinEdit;
    MemoHoursOfDay: TMemo;
    nightcheck: TCheckBox;
    PanelHoursOfDay: TPanel;
    PanelPartyInfo: TPanel;
    PanelTimeOfDay: TPanel;
    PanelCompundInfo: TPanel;
    PanelFinishingInfo: TPanel;
    racerestriction: TPanel;
    racecond: TRadioGroup;
    halflingX: TCheckBox;
    dwarfX: TCheckBox;
    elfX: TCheckBox;
    GnomeX: TCheckBox;
    halfelfX: TCheckBox;
    HumanX: TCheckBox;
    halforcX: TCheckBox;
    goldrestriction: TPanel;
    Label6: TLabel;
    goldcond: TRadioGroup;
    goldvalue: TSpinEdit;
    journalint: TPanel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    GroupLocalParty: TRadioGroup;
    GroupJournalCompare: TRadioGroup;
    GroupItemParty: TRadioGroup;
    GroupFeatType: TRadioGroup;
    RadioLocalEqual: TRadioButton;
    RadioLocalGreater: TRadioButton;
    RadioHoursOfDay: TRadioButton;
    RadioLocalLess: TRadioButton;
    RadioLocalNotEqual: TRadioButton;
    RadioTimeOfDay: TRadioButton;
    ScrollDieRolls: TScrollBox;
    SpinEdit1: TSpinEdit;
    journaltag: TEdit;
    alignmentpanel: TPanel;
    alignment: TRadioGroup;
    alignmentconditional: TRadioGroup;
    TextItemPalettes: TStaticText;
    TextCompoundInfo: TStaticText;
    TextFinishingInfo: TStaticText;
    TextPartyInfo: TStaticText;
    Timepanel: TPanel;
    Label17: TLabel;
    MemoTimeOfDay: TMemo;
    localpanel: TPanel;
    Label18: TLabel;
    intname: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    randompanel: TPanel;
    Label20: TLabel;
    SpinEdit2: TSpinEdit;
    savepanel: TPanel;
    Label22: TLabel;
    savetype: TComboBox;
    Label23: TLabel;
    SpinEdit3: TSpinEdit;
    ComboBox3: TComboBox;
    skillcheckpanel: TPanel;
    Label24: TLabel;
    skilllist: TComboBox;
    Label25: TLabel;
    Label26: TLabel;
    difficulty: TSpinEdit;
    featpanel: TPanel;
    RadioGroup4: TRadioGroup;
    featbox: TComboBox;
    classrestriction: TPanel;
    classcond: TRadioGroup;
    FighterX: TCheckBox;
    BarbarianX: TCheckBox;
    BardX: TCheckBox;
    ClericX: TCheckBox;
    DruidX: TCheckBox;
    RangerX: TCheckBox;
    PaladinX: TCheckBox;
    MonkX: TCheckBox;
    tohour: TSpinEdit;
    WizardX: TCheckBox;
    SorcererX: TCheckBox;
    RogueX: TCheckBox;
    arcanearcherx: TCheckBox;
    assassinx: TCheckBox;
    blackguardx: TCheckBox;
    harperscoutx: TCheckBox;
    shadowdancerx: TCheckBox;
    tormx: TCheckBox;
    defenderx: TCheckBox;
    palemasterx: TCheckBox;
    dragonx: TCheckBox;
    shifterx: TCheckBox;
    weaponmasterx: TCheckBox;
    levelbyclassrestriction: TPanel;
    Label27: TLabel;
    levelclasscond: TRadioGroup;
    levels: TSpinEdit;
    levelclass: TComboBox;
    itemrestriction: TPanel;
    Label7: TLabel;
    RadioGroup1: TRadioGroup;
    itemtag: TEdit;
    CheckBox1: TCheckBox;
    ComboBox2: TComboBox;
    BitBtn3: TBitBtn;
    GenderPanel: TPanel;
    Gender: TRadioGroup;
    deitypanel: TPanel;
    RadioGroup3: TRadioGroup;
    Edit2: TEdit;
    DeityCase: TCheckBox;
    subracepanel: TPanel;
    RadioGroup2: TRadioGroup;
    Edit1: TEdit;
    SubraceCase: TCheckBox;
    abilitypanel: TPanel;
    Label14: TLabel;
    abilitychoice: TRadioGroup;
    abilitycondition: TRadioGroup;
    ability: TSpinEdit;
    abilitygroup: TRadioGroup;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure ToggleOkayItem(Sender: TObject; Index: integer);
    procedure ClickOkay(Sender: TObject);
    // Events for widgets in the subpanels:
    procedure GroupFeatTypeClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ComboLocalTypeChange(Sender: TObject);
    procedure EditLocalValueChange(Sender: TObject);
    procedure GroupLocalPartyClick(Sender: TObject);
    procedure ButtonPartyInfoClick(Sender: TObject);
    procedure dieChange(Sender: TObject);

  public
    // Communication with other units.
    class procedure EndIf();
    class function  GetIfCount(): integer; inline;
    class function  IsElseAllowed(): boolean; inline;
    class procedure MakeElse();
    class procedure MakeElseIf();
    class procedure ResetIfs();

  private
    // Bookkeeping fields.
    RunElseIf:  boolean; // Tracks when we are making an "else-if" instead of "if".
    ShownPanel: TPanel;  // Tracks which auxiliary panel is currently shown.

  private
    // Utilities
    function  CountSelections(CheckGroup: TCustomCheckGroup): integer;
    function  RepresentsSwitch(iCond: shortint): boolean; inline;

    // Panel-specific script producers.
    procedure Abilityres();
    procedure Alignmentres();
    procedure Classres();
    procedure DeityRes();
    procedure DieRollRes();
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
    procedure MakeIf(const condition, cond_desc: shortstring); overload;
    procedure MakeIf(const conditions: array of shortstring; const cond_desc: shortstring); overload;
    // Broken out of the script-producers because some panels bypass those.
    procedure UpdateTracking(const cond_desc: shortstring);
  end;


{var
  ifchoose: Tifchoose;
}

// -----------------------------------------------------------------------------

implementation

uses
    {event,} start, nwn, palettetool,
    constants, party_doc, ifinspector;

const
    // The actual index of the TComboBox that indicates a die roll:
    CONDITION_DIE_ROLL = 14;
    // Larger than any TComboBox index for conditions; used to pack extra info
    // about a die roll (the index of an array gets added to this):
    CONDITION_DIE_FLAG = 32;
    // Invalid indices; used to flag "else" clauses.
    CONDITION_NOT_APPLICABLE = -1;
    CONDITION_DEFAULT_CASE   = -2;


var // Unit-wide variables because static class fields were causing crashes.

    // Tracking active "if" statements.
    IfConds: array of shortint;         // ComboBox1 indices, more or less.
    IfData:  array of array of boolean; // Flags for die rolls.


// -----------------------------------------------------------------------------

// Ends the current "if" statement in the script window.
class procedure Tifchoose.EndIf();
var
    last_if: integer;

    new_lines: array[0..0] of shortstring;
begin
    last_if := High(IfConds);

    // Cannot very well end something that does not exist.
    if last_if < 0 then
        exit;

    // End the last block.
    new_lines[0] := '}';
    Tlilac.AddLines(new_lines);

    // "Switch" statements have two code blocks to end.
    if RepresentsSwitch(IfConds[last_if]) then begin
        Tlilac.AddLines(new_lines);
        // We can also clean up one entry from IfData.
        if Length(IfData) > 0 then
            SetLength(IfData, Length(IfData)-1);
    end;

    // Pop the IfConds stack.
    SetLength(IfConds, last_if);
    // Update the display of the "if" structure.
    Tinspect.UntrackIfTree();
end;


// Returns the number of open "if" statements.
class function  Tifchoose.GetIfCount(): integer; inline;
begin
    result := Length(IfConds);
end;


// Returns whether or not the "if"-tree is in a state that allows an "else" clause.
class function  Tifchoose.IsElseAllowed(): boolean; inline;
begin
    if High(IfConds) < 0 then
        result := FALSE
    else
        result := IfConds[High(IfConds)] >= 0;
end;


// Starts an "else" clause in the script window.
// Assumes IsElseAllowed() would return TRUE.
class procedure Tifchoose.MakeElse();
var
    last_if: integer;

    new_lines: array[0..2] of shortstring;
begin
    last_if := High(IfConds);

    // The first and last lines, probably:
    new_lines[0] := '}';
    new_lines[2] := '{';

    // Is this an "else" for an "if" or a "default" for a "switch"?
    if RepresentsSwitch(IfConds[last_if]) then begin
        new_lines[0] += ' break;';
        new_lines[1] := 'default:';
        IfConds[last_if] := CONDITION_DEFAULT_CASE;
    end
    else begin
        new_lines[1] := 'else';
        IfConds[last_if] := CONDITION_NOT_APPLICABLE;
    end;

    // Add this to the script window.
    Tlilac.AddLines(new_lines);

    // Update the display of the "if" structure.
    Tinspect.TrackIfTree('', FALSE);
end;


// Starts an "else-if" clause in the script window.
// Assumes IsElseAllowed() would return TRUE.
class procedure Tifchoose.MakeElseIf();
var
    new_form: Tifchoose;

    last_selection: shortint;
    iData, iRoll: integer;
begin
    // Create a new ifchoose form.
    Application.CreateForm(Tifchoose, new_form);

    // Configure this form for an "else-if" clause.
    new_form.RunElseIf := TRUE;
    // Default to the last condition.
    last_selection := IfConds[High(IfConds)];
    if last_selection < CONDITION_DIE_FLAG then begin
        new_form.ComboBox1.ItemIndex := last_selection;
        new_form.ComboBox1Change(new_form.ComboBox1);
        // Block the selection of a die roll.
        new_form.dierollpanel.Visible := FALSE;
    end
    else begin
        // Force this condition to be a die roll.
        new_form.ComboBox1.ItemIndex := CONDITION_DIE_ROLL;
        new_form.ComboBox1Change(new_form.ComboBox1);
        new_form.ComboBox1.Enabled := FALSE;
        // Recall (and fix) which die was rolled.
        new_form.die.ItemIndex := last_selection - CONDITION_DIE_FLAG;
        new_form.dieChange(new_form.die);
        new_form.die.enabled := FALSE;
        // Recall which rolls are already accounted for.
        iData := High(IfData);
        if iData >= 0 then
            for iRoll := 0 to High(IfData[iData]) do
                if IfData[iData][iRoll] then
                    new_form.GroupDieRolls.CheckEnabled[iRoll] := FALSE;
    end;

    // Display the form.
    new_form.ShowModal();
    // Clean up.
    new_form.Release();
end;


// Resets/initializes our private tracking of the "if" tree.
class procedure Tifchoose.ResetIfs();
begin
    SetLength(IfConds, 0);
    SetLength(IfData, 0);
end;


// -----------------------------------------------------------------------------

// Initializes the form based on the current situation.
procedure Tifchoose.FormCreate(Sender: TObject);
begin
    // Initializations.
    RunElseIf  := FALSE;
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
procedure Tifchoose.ComboBox1Change(Sender: TObject);
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
        14: ShownPanel := PanelDice;
        15: ShownPanel := savepanel;
        16: ShownPanel := skillcheckpanel;
        17: ShownPanel := subracepanel;
        18: ShownPanel := timepanel;
    end;

    // Show the panel.
    if ShownPanel <> nil then
        ShownPanel.visible := true;

    // Update the "Okay" button.
    ToggleOkay(Sender);
end;


// Handles the enabled state of the "Okay" button.
procedure Tifchoose.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // Whether more info is needed depends on the selection.
    case combobox1.itemindex of
        // Panels with full defaults (nothing needs checking here):
        // Alignment, deity, gender, gold, total level, percentage, and subrace panels:
        1,3,5,6,9,13,17: bEnable := TRUE;

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
        // Die roll panel:
        14: bEnable := dierollpanel.Visible  and  (CountSelections(GroupDieRolls) > 0);
        // Save panel:
        15: bEnable := savetype.ItemIndex >= 0;
        // Skill panel:
        16: bEnable := SkillList.ItemIndex >= 0;
        // Time panel:
        18: bEnable := nightcheck.checked  or  daycheck.checked   or
                       duskcheck.checked   or  dawncheck.checked  or
                       RadioHoursOfDay.checked;

        // Else, no selection made, so there is nothing to "okay".
        else bEnable := FALSE;
    end;

    // Update the button.
    BitBtn1.Enabled := bEnable;
end;


// Wrapper for ToggleOkay() so that it can be called in response to clicking
// an item in a TCheckGroup.
procedure Tifchoose.ToggleOkayItem(Sender: TObject; Index: integer);
begin
    ToggleOkay(Sender);
end;


// Handles clicks of the "Okay" button.
procedure Tifchoose.ClickOkay(Sender: TObject);
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
        14: dierollres();
        15: saveres();
        16: skillres();
        17: subraceres();
        18: timeres();
    end;
end;


// Handles the selection of the feat type (common, special, epic).
procedure Tifchoose.GroupFeatTypeClick(Sender: TObject);
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
procedure Tifchoose.Button3Click(Sender: TObject);
begin
    // Call up the palette window, items by default.
    TPaletteWindow.Load(itemtag, EditItemName, SEARCH_ITEMS, FALSE);
end;


// Handles changes to the "item must be equipped" checkbox.
procedure Tifchoose.CheckBox1Click(Sender: TObject);
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
procedure Tifchoose.ComboLocalTypeChange(Sender: TObject);
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
procedure Tifchoose.EditLocalValueChange(Sender: TObject);
begin
    EditChangeValidateNumeric(EditLocalValue, ComboLocalType.ItemIndex, Sender = EditLocalValue);
end;


// Shows/hides the party info panel as appropriate.
procedure Tifchoose.GroupLocalPartyClick(Sender: TObject);
begin
    PanelPartyInfo.Visible := GroupLocalParty.ItemIndex = 1;
end;


// Calls up the party info form.
procedure Tifchoose.ButtonPartyInfoClick(Sender: TObject);
begin
    main.ShowPopup(TPartydoc);
end;


// Keeps the roll options synched with the selected die.
procedure Tifchoose.dieChange(Sender: TObject);
const
    // A conversion between die.itemindex and the number of sides of the die.
    DieMax: array[0..8] of shortint =
        ( 2, 3, 4, 6, 8, 10, 12, 20, 100 );
    // The number of columns to use to display the rolls for each die.
    RollCols: array[0..8] of shortint =
        ( 2, 3, 4, 6, 4,  5,  6,  5,  10 );
var
    iRoll, iDieIndex: shortint;
begin
    iDieIndex := die.itemindex;

    // Update GroupDieRolls.
    with GroupDieRolls do begin
        // Adjust the height (need extra room for a d100).
        if iDieIndex = 8 then
            Height := 230
        else
            Height :=  90;

        // Update the list of rolls, preserving selections when possible.
        Items.BeginUpdate();
        try
            for iRoll := Items.Count + 1 to DieMax[iDieIndex] do
                Items.Append(IntToStr(iRoll));
            for iRoll := Items.Count - 1 downto DieMax[iDieIndex] do
                Items.Delete(iRoll);
        finally
            // End the batched changes.
            Items.EndUpdate();

        end;
        // Set the number of columns.
        Columns := RollCols[iDieIndex];
    end;

    // Update the "Okay" button.
    ToggleOkay(Sender);
end;


// -----------------------------------------------------------------------------

// Returns the number of checked (and enabled) items in a TCustomCheckGroup.
function Tifchoose.CountSelections(CheckGroup: TCustomCheckGroup): integer;
var
    iItem: integer;
begin
    result := 0;

    // Loop through the possible selections.
    for iItem := 0 to CheckGroup.Items.Count-1 do
        if CheckGroup.Checked[iItem]  and  CheckGroup.CheckEnabled[iItem] then
            // Count this one.
            Inc(result);
end;


// Convenience function to test a condition for representing a "switch" instead
// of an "if".
function  Tifchoose.RepresentsSwitch(iCond: shortint): boolean; inline;
begin
    result := (iCond >= CONDITION_DIE_FLAG)  or  (iCond = CONDITION_DEFAULT_CASE);
end;


// Adds an ability restriction to the script window.
procedure Tifchoose.Abilityres();
var
    sAbility:   shortstring;
    base_param: shortstring;    base_desc: shortstring;
    compare:    string[3];      at_least:  shortstring;
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
        0: begin compare := '>= ';      at_least := ' is at least '; end;
        1: begin compare := '<= ';      at_least := ' is at most ';   end;
    end;

    // Create the "if" statement.
    MakeIf('GetAbilityScore('+s_oPC+', ABILITY_'+uppercase(sAbility)+base_param+') '+
               compare +ability.Text,
           'the PC''s '+base_desc +sAbility+ at_least + ability.Text);
end;


// Adds an alignment restriction to the script window.
procedure Tifchoose.Alignmentres();
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
        0: begin compare := '== ';  joiner := '  &&';   is_not := 'is ';     end;
        1: begin compare := '!= ';  joiner := '  ||';   is_not := 'is not '; end;
    end;
    // Special case: "any neutral" reverses the joiner.
    if alignment.itemindex = 15 then
        case alignmentconditional.itemindex of
            0: joiner := '  ||';
            1: joiner := '  &&';
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

    // Create the "if" statement.
    MakeIf(conditions[0..last_cond],
           'the PC''s alignment '+is_not +lowercase(alignment.Items[alignment.ItemIndex]));
end;


// Adds a class restriction to the script window.
procedure Tifchoose.Classres();
var
    classes: ClassCheck;
    eClass:  TClassEnum;
    sDesc, compare, joiner: shortstring;
    sComment, sIf:          shortstring;
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
        sDesc    := '';
        compare  := ' > 0';
        joiner   := '  ||';
    end
    else begin
        // Must not be one of these classes.
        sDesc    := 'not ';
        compare  := ' == 0';
        joiner   := '  &&';
    end;
    // Finish the description:
    sDesc := 'the PC is '+sDesc+'a certain class';

    // Insert "else's"?
    if RunElseIf then begin
        sComment := '// Else, if ';
        sIf      := 'else if ( ';
    end
    else begin
        sComment := '// If ';
        sIf      := 'if ( ';
    end;

    // Add the appropriate lines.
    Tlilac.AddClassString(sComment +sDesc+'.',
                          sIf, classes, compare, joiner, ' )',
                             '{', RunElseIf);
    // Update the tree tracking.
    UpdateTracking(sDesc);
end;


// Adds a deity restriction to the script window.
procedure Tifchoose.DeityRes();
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
        0: begin compare := ' == ';    is_not := 'is ';     end;
        1: begin compare := ' != ';    is_not := 'is not '; end;
    end;

    // Create the "if" statement.
    MakeIf(func_call + compare + '"'+compare_to+'"', 'the PC''s deity '+is_not +deity_name);
end;


// Adds a die roll restriction to the script window.
// This is a "switch", not an "if", so cannot be combined with other types of
// conditions through an "else" clause.
procedure Tifchoose.DieRollRes();
var
    iData, iRoll, iMaxRoll: integer;
    roll_list: shortstring;

    last_line: integer;
    new_lines: array of shortstring;
begin
    iMaxRoll := GroupDieRolls.Items.Count;
    iData := Length(IfData) - 1;

    if (iData < 0)  or  not RunElseIf then begin
        // We need to start a new data set.
        Inc(iData);
        SetLength(IfData, iData + 1);
        SetLength(IfData[iData], iMaxRoll);
        for iRoll := 0 to iMaxRoll - 1 do
            IfData[iData][iRoll] := FALSE;
    end;

    if not RunElseIf then begin
        // Start a new switch statement.
        SetLength(new_lines, 3);
        new_lines[0] := '// Decide what to do based on a die roll.';
        new_lines[1] := 'switch ( '+die.Text+'() )';
        new_lines[2] := '{';
        Tlilac.AddLines(new_lines);
    end;

    // Prepare to loop through the die rolls.
    SetLength(new_lines, iMaxRoll + 2);
    last_line := -1;
    roll_list := '';

    // End the previous block?
    if RunElseIf then begin
        last_line := 0;
        new_lines[0] := '} break;'
    end;

    // Loop through the die rolls.
    for iRoll := 0 to iMaxRoll - 1 do
        if GroupDieRolls.Checked[iRoll]  and  GroupDieRolls.CheckEnabled[iRoll] then
        begin
            Inc(last_line);
            new_lines[last_line] := 'case '+GroupDieRolls.Items[iRoll]+':';
            roll_list += GroupDieRolls.Items[iRoll]+', ';
            // Remember this for next time.
            IfData[iData][iRoll] := TRUE;
        end;
    // Trim off the last ', '.
    SetLength(roll_list, Length(roll_list)-2);

    // Start the next block.
    Inc(last_line);
    new_lines[last_line] := '{';

    // Send this to the script window.
    Tlilac.AddLines(new_lines[0..last_line]);

    // Update the tree tracking.
    UpdateTracking('the die roll is '+roll_list);
    // Change the IfConds stack to also track which die is selected.
    IfConds[Length(IfConds)-1] := CONDITION_DIE_FLAG + die.ItemIndex;
end;


// Adds a feat restriction to the script window.
procedure Tifchoose.FeatRes();
var
    has:    shortstring;
    prefix: string[1];
    feat:   shortstring;
begin
    // Check for negation.
    case radiogroup4.itemindex of
        0: prefix := '';  // has it
        1: prefix := '!'; // does not have it
    end;
    has := radiogroup4.Items[radiogroup4.itemindex];

    // Look up the feat's NWScript constant.
    case GroupFeatType.ItemIndex of
        0: feat := SymConst(FEAT_COMMON, featbox.ItemIndex);
        1: feat := SymConst(FEAT_SPECIAL, featbox.ItemIndex);
        2: feat := SymConst(FEAT_EPIC, featbox.ItemIndex);
    end;

    // Create the "if" statement.
    MakeIf(prefix+'GetHasFeat('+feat+', '+s_oPC+')',
           'the PC '+has+' the '+lowercase(featbox.text)+' feat');
end;


// Adds a gender restriction to the script window.
procedure Tifchoose.GenderRes();
var
    gender_text: shortstring;
begin
    // For simpler reference:
    gender_text := gender.Items[gender.ItemIndex];

    // Create the "if" statement.
    MakeIf('GetGender('+s_oPC+') == GENDER_'+uppercase(gender_text),
           'the PC is '+gender_text);
end;


// Adds a gold restriction to the script window.
procedure Tifchoose.Goldres();
var
    func_call: shortstring;
    compare:   string[3];
begin
    // Party or PC?
    case GroupGoldParty.itemindex of
        0: func_call := 'GetGold';
        1: func_call := 'GetFactionGold';
    end;
    func_call += '('+s_oPC+') ';

    // Which comparison?
    case goldcond.itemindex of
        0: compare := '>= ';
        1: compare := '< ';
    end;

    // Create the "if" statement.
    MakeIf(func_call + compare +goldvalue.Text,
           GroupGoldParty.Items[GroupGoldParty.ItemIndex]+' '+
           goldcond.Items[goldcond.itemindex]+' '+goldvalue.Text+' gold');
end;


// Adds an item restriction to the script window.
procedure Tifchoose.Itemres();
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
                                     BoolToStr(radiogroup1.itemindex = 0, '==', '!=')+
                                     ' GetTag('+ Script.GetItemInSlot(slot, s_oPC)+')  '+
                                     BoolToStr(radiogroup1.itemindex = 0, '||', '&&');
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
                         BoolToStr(radiogroup1.itemindex = 0, ' != ', ' == ') +
                         s_OBJECT_INVALID
    end

    // Else, checking for possession by the party.
    else begin
        SetLength(conditions, 1);
        conditions[0] := 'GetIsItemPossessedByParty('+s_oPC+', "'+item_tag+'")';
        if radiogroup1.itemindex = 1 then
            conditions[0] := '!'+conditions[0];
        // This will require including x0_i0_partywide.
        Tlilac.Include(INC_PARTYWIDE);
    end;


    // Build  a description for this condition.
    case radiogroup1.itemindex of
        0: not_have := 'has ';
        1: not_have := 'does not have ';
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

    // Create the "if" statement.
    MakeIf(conditions, 'the PC'+party +not_have +'the item '+item_name);
end;


// Adds a journal restriction to the script window.
procedure Tifchoose.Journalres();
var
    compare: string[4];
    at_least: shortstring;
begin
    // Get the comparison to use.
    case GroupJournalCompare.ItemIndex of
        0: compare := ' >= ';
        1: compare := ' == ';
        2: compare := ' < ';
    end;
    at_least := GroupJournalCompare.Items[GroupJournalCompare.ItemIndex];

    // Create the "if" statement.
    MakeIf(Script.JournalRead(s_oPC, QuoteSwap(journaltag.text))+ compare +spinedit1.Text,
           'the PC is '+at_least+' stage '+spinedit1.Text+' of journal quest "'+journaltag.text+'"');
end;


// Adds a class level restriction to the script window.
procedure Tifchoose.LevelClassRes();
var
    compare:   string[3];      exactly:  shortstring;
begin
    // Less, more, or exactly?
    case levelclasscond.itemindex of
        0: begin compare := '== ';  exactly := 'exactly ';   end;
        1: begin compare := '< ';   exactly := 'less than '; end;
        2: begin compare := '> ';   exactly := 'more than '; end;
    end;

    // Create the "if" statement.
    MakeIf('GetLevelByClass('+SymConst(NWNCLASS, levelclass.ItemIndex)+', '+
                            s_oPC+') '+compare + levels.Text,
           'the PC has '+exactly +levels.Text+' levels of '+lowercase(levelclass.text));
end;


// Adds a character level restriction to the script window.
procedure Tifchoose.Levelres();
var
    compare:   string[3];       at_least: shortstring;
    func_name: shortstring;     party: shortstring;
begin
    // At least or at most?
    case levelcond.itemindex of
        0: begin compare := '>= ';  at_least := 'at least '; end;
        1: begin compare := '<= ';  at_least := 'at most ';  end;
    end;

    // PC or party?
    case GroupLevelParty.ItemIndex of
        0: begin func_name := 'GetHitDice';             party := 'total ';            end;
        1: begin func_name := 'GetFactionAverageLevel'; party := 'party''s average '; end;
    end;

    // Create the "if" statement.
    MakeIf(func_name+'('+s_oPC+') '+compare +levelvalue.Text,
           'the PC''s '+party +'level is '+at_least +levelvalue.Text);
end;


// Adds a local variable restriction to the script window.
procedure Tifchoose.Localintres();
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
    if RadioLocalEqual.Checked        then begin compare := ' == ';  comp_desc := 'exactly ';   end
    else if RadioLocalLess.Checked    then begin compare := ' < ';   comp_desc := 'less than '; end
    else if RadioLocalGreater.Checked then begin compare := ' > ';   comp_desc := 'more than '; end
    else (* RadioLocalNotEqual.Checked *)  begin compare := ' != ';  comp_desc := 'not ';       end;

    // Create the "if" statement.
    MakeIf(func_name+var_type+params + compare + goal_value,
           'the local '+lowercase(var_type)+' is '+comp_desc +quote+EditLocalValue.Text+quote);
end;


// Adds a race restriction to the script window.
procedure Tifchoose.Raceres();
var
    racex: racialcheck;
    eRace: TRaceEnum;
    sDesc, compare, joiner: shortstring;
    sComment, sIf: shortstring;
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
        sDesc    := 'not ';
        compare  := ' != ';
        joiner   := '  &&';
    end
    else begin
        // Must be one of these races.
        sDesc    := '';
        compare  := ' == ';
        joiner   := '  ||';
    end;
    // Finish the description:
    sDesc := 'the PC is '+sDesc+'a certain race';

    // Insert "else's"?
    if RunElseIf then begin
        sComment := '// Else, if ';
        sIf      := 'else if ( ';
    end
    else begin
        sComment := '// If ';
        sIf      := 'if ( ';
    end;

    // Add the appropriate lines.
    Tlilac.AddRaceString(sComment +sDesc+'.',
                         sIf, s_oPC, compare, racex, joiner, ' )',
                             '{', RunElseIf);
    // Update the tree tracking.
    UpdateTracking(sDesc);
end;


// Adds a random (percentage) restriction to the script window.
procedure Tifchoose.RandomRes();
begin
    // Create the "if" statement.
    MakeIf('Random(100) < '+spinedit2.text,
           'success on a '+spinedit2.text+'% chance');
end;


// Adds a saving throw restriction to the script window.
procedure Tifchoose.saveres();
var
   versus: shortstring;
begin
    // An optional parameter:
    if combobox3.itemindex > 0 then
        versus := ', '+SymConst(SAVING_THROW_TYPE, combobox3.ItemIndex)
    else
        versus := '';

    // Create the "if" statement.
    MakeIf(savetype.Text+'Save('+s_oPC+', '+spinedit3.Text + versus+')',
           'a '+lowercase(savetype.Text)+' saving throw is successful');
end;


// Adds a skill restriction to the script window.
procedure Tifchoose.SkillRes();
var
    skill, condition: shortstring;
begin
    skill := SymConst(SKILL_NAME, skilllist.ItemIndex);

    // Decide which condition to use.
    if CheckShowSkillRoll.Checked then
        condition := 'GetIsSkillSuccessful('+s_oPC+', '+skill+', '+difficulty.Text+')'
    else
        condition := 'd20() + GetSkillRank('+skill+', '+s_oPC+') >= '+difficulty.Text;

    // Plus, the PC should be able to use the skill in the first place.
    if RestrictedSkill[skilllist.ItemIndex] then
        condition := 'GetHasSkill('+skill+', '+s_oPC+')  &&  '+condition;

    // Create the "if" statement.
    MakeIf(condition, 'a skill check ('+lowercase(skilllist.text)+') is successful');
end;


// Adds a subrace restriction to the script window.
procedure Tifchoose.SubRaceRes();
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
        compare := ' == ';
        is_not := 'is ';
    end
    else begin
        compare := ' != ';
        is_not := 'is not ';
    end;

    // Create the "if" statement.
    MakeIf(func_call + compare + '"'+compare_to+'"',
           'the PC''s subrace '+is_not +subrace_name);
end;


// Adds a time restriction to the script window.
procedure TIfchoose.Timeres();
var
    condition, cond_desc: shortstring;
begin
    // Some strings for the opening comment and conditional.
    if RadioHoursOfDay.Checked then begin
        if fromhour.value = tohour.value then begin
            // A single hour.
            cond_desc := 'the current hour is '+fromhour.Text;
            condition := 'GetTimeHour() == '+fromhour.Text;
        end
        else begin
            // An interval, possibly crossing midnight.
            cond_desc := 'the time is from '+fromhour.Text+' to '+tohour.Text;
            condition := fromhour.Text+' <= GetTimeHour()  '+
                         BoolToStr(fromhour.value < tohour.value, '&&', '||')+
                         '  GetTimeHour() <= '+tohour.Text;
        end;
    end
    else begin
        // One or more parts of the day were selected.
        cond_desc := 'it is ';
        condition := '';
        // Build up the strings.
        if dawncheck.checked  then begin cond_desc += 'dawn or '; condition += 'GetIsDawn()  ||  '; end;
        if daycheck.checked   then begin cond_desc += 'day or ';  condition += 'GetIsDay()  ||  ';  end;
        if duskcheck.checked  then begin cond_desc += 'dusk or '; condition += 'GetIsDusk()  ||  '; end;
        if nightcheck.checked then begin cond_desc += 'night';    condition += 'GetIsNight()';      end
        else begin
            // Trim off the last ' or ' and '  ||  '.
            SetLength(cond_desc, Length(cond_desc)-4);
            SetLength(condition, Length(condition)-6);
        end;
    end;

    // Create the "if" statement.
    MakeIf(condition, cond_desc);
end;


// The script producer called by the panel-specific procedures.
// _condition_ is NWScript to be put inside "if ( " and " )", while
// _cond_desc_ is English for comments and Script Generator feedback.
procedure TIfchoose.MakeIf(const condition, cond_desc: shortstring);
var
    conditions: array[0..0] of shortstring;
begin
    // This is now just a wrapper for the version that can handle multiple
    // lines of conditions.
    conditions[0] := condition;
    MakeIf(conditions, cond_desc);
end;


// The script producer called by the panel-specific procedures.
// _conditions_ is NWScript to be put inside "if ( " and " )", while
// _cond_desc_ is English for comments and Script Generator feedback.
// _conditions_ must not be zero-length.
// This procedure may be optimized for the common case of a single condition.
procedure TIfchoose.MakeIf(const conditions: array of shortstring; const cond_desc: shortstring);
var
    iCondition: integer;
    indent:     shortstring;
    last_line: integer;
    new_lines: array of shortstring;
begin
    // Allocate space.
    SetLength(new_lines, 3+Length(conditions)); // '}', comment, conditions, plus '{'.

    // Fill in the NWScript up to "if".
    if RunElseIf then begin
        new_lines[0] := '}';
        new_lines[1] := '// Else, if '+cond_desc+'.';
        new_lines[2] := 'else ';
        indent       := '     ';
        last_line := 2;
    end
    else begin
        new_lines[0] := '// If '+cond_desc+'.';
        new_lines[1] := '';
        indent       := '';
        last_line := 1;
    end;

    // The "if" statement.
    new_lines[last_line] += 'if ( '+conditions[0];
    // The remaining conditions (if any).
    for iCondition := 1 to High(conditions) do begin
        Inc(last_line);
        new_lines[last_line] := indent+'     '+conditions[iCondition];
    end;
    new_lines[last_line] += ' )';

    // Start the code block.
    Inc(last_line);
    new_lines[last_line] := '{';

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line]);

    // Update the tracking of where in the "if" structure we are.
    UpdateTracking(cond_desc);
end;


// Updates everyone's tracking of the "if"-tree.
procedure TIfchoose.UpdateTracking(const cond_desc: shortstring);
begin
    // The IfConds stack needs a "push" on an "if".
    if not RunElseIf then
        SetLength(IfConds, Length(IfConds)+1);
    // Push on an "if"; replace top element on "else-if".
    IfConds[Length(IfConds)-1] := ComboBox1.ItemIndex;

    // Also update the display of the structure.
    Tinspect.TrackIfTree(cond_desc, RunElseIf);
end;



initialization
  {$i chooseif.lrs}
end.
