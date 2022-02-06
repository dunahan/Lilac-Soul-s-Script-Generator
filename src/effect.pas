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
* Some of this was trimmed when I converted the form to being modal (and converted
    simulated radio buttons into actual radio butons).
* Significant interface changes.
* Added some new effects and some new options to existing effects.
* Added spell constant panel to improve performance when selecting it. (There
    was a short but noticeable delay as the TComboBox loaded.)
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit effect;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} {Forms,} {Dialogs,}
  Spin, ExtCtrls, StdCtrls, start, nwn, Buttons,
  LResources, QueueForm;

type

  { Tapplyeffect }

  Tapplyeffect = class(TQueueForm)
      // Form elements.
      CheckPolyCancel: TCheckBox;
      ComboACType: TComboBox;
      SpellConstantBox: TComboBox;
      DamageShieldBonus: TComboBox;
      DamageShieldPanel: TPanel;
      DamageShieldType: TComboBox;
      DamageReductLimit: TSpinEdit;
      DamageResistLimit: TSpinEdit;
      DamageResistType: TComboBox;
      LabelSpellShieldLimit: TLabel;
      SpellConstantDescription: TLabel;
      SpellConstantPanel: TPanel;
      SpinSpellShieldLevel: TSpinEdit;
      LabelSpellShieldSchool: TLabel;
      LabelSpellShieldLevel: TLabel;
      LabelDamageShieldBase: TLabel;
      LabelDamageShieldBonus: TLabel;
      LabelDamageShieldType: TLabel;
      LabelResistLimit: TLabel;
      SpellShieldPanel: TPanel;
      SpellShieldSchool: TComboBox;
      SpinDamageResistance: TSpinEdit;
      LabelDamageResistance: TLabel;
      DamageResistPanel: TPanel;
    EditTagged: TEdit;
    effectlist: TComboBox;
    GroupApplyTo: TGroupBox;
    GroupDuration: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LabelResistType: TLabel;
    LabelReductLimit: TLabel;
    LabelAbility: TLabel;
    LabelACType: TLabel;
    LabelACAmount: TLabel;
    LabelEffect: TLabel;
    LabelSeconds: TLabel;
    nonepanel: TPanel;
    ArmorClassPanel: TPanel;
    SpinACAmount: TSpinEdit;
    percentpanel: TPanel;
    percentvalue: TSpinEdit;
    RadioActivator: TRadioButton;
    RadioActor: TRadioButton;
    RadioTemporary: TRadioButton;
    RadioPermanent: TRadioButton;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    numberpanel: TPanel;
    Label3: TLabel;
    numbervalue: TSpinEdit;
    abilitypanel: TPanel;
    ability: TComboBox;
    Label4: TLabel;
    abilityvalue: TSpinEdit;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    polymorphpanel: TPanel;
    Label5: TLabel;
    polylist: TComboBox;
    SavingThrow: TComboBox;
    SpinDamageShield: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinSpellShieldLimit: TSpinEdit;
    TextReductLimit: TStaticText;
    SubType: TRadioGroup;
    CursePanel: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    strength: TSpinEdit;
    dexterity: TSpinEdit;
    constitution: TSpinEdit;
    intelligence: TSpinEdit;
    TextResistLimit: TStaticText;
    TextShieldLimit: TStaticText;
    wisdom: TSpinEdit;
    charisma: TSpinEdit;
    DamageTypePanel: TPanel;
    Label14: TLabel;
    DamageTypeInt: TSpinEdit;
    DamageTypeIntDescription: TLabel;
    DamageTypeBox: TComboBox;
    DamageIncreasePanel: TPanel;
    Label15: TLabel;
    Label16: TLabel;
    DamageBonusBox: TComboBox;
    DamageIncTypeBox: TComboBox;
    DamageReductionPanel: TPanel;
    Label17: TLabel;
    Label18: TLabel;
    DamageReduction: TSpinEdit;
    DamagePowerBox: TComboBox;
    SingleConstantPanel: TPanel;
    SingleConstantDescription: TLabel;
    ConstantBox: TComboBox;
    RegeneratePanel: TPanel;
    Label19: TLabel;
    RegenHP: TSpinEdit;
    Label20: TLabel;
    Interval: TSpinEdit;
    SavePanel: TPanel;
    Label21: TLabel;
    SaveModifier: TSpinEdit;
    Label22: TLabel;
    Label23: TLabel;
    SavingThrowType: TComboBox;
    SkillPanel: TPanel;
    Label24: TLabel;
    Label25: TLabel;
    SkillValue: TSpinEdit;
    SkillBox: TComboBox;
    SpellFailurePanel: TPanel;
    Label26: TLabel;
    Label27: TLabel;
    FailChance: TSpinEdit;
    SpellSchool: TComboBox;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure effectlistChange(Sender: TObject);

  private
    // Bookkeeping fields.
    ShownPanel: TPanel; // Tracks which auxiliary panel is currently shown.
    subtype_default: integer;   // The last subtype of a submitted effect.
    duration_temp:   boolean;   // The last duration type of a submitted effect.
    QueuedLines: array of shortstring;  // The NWScript lines to add to the script.

  protected
    // Helper methods.
    procedure ClearForm(); override;
    procedure FillConstantBox(ConstantType: smallint);
    function  MakeEffectString(): shortstring;
    procedure QueueThis(); override;
    procedure SendQueue(); override;
  end;


// -----------------------------------------------------------------------------

implementation

uses {event,} {spellcast,}
     constants;

// Types and constants to define the various effects we can Generate.
type
    {$PACKENUM 1}
    TPanelEnum = ( PANEL_NONE, PANEL_PERCENT, PANEL_NUMBER, PANEL_ABILITY,
                   PANEL_POLYMORPH, PANEL_CURSE, PANEL_D_TYPE, PANEL_D_TYPE_R,
                   PANEL_D_INC, PANEL_D_REDUCT, PANEL_CONSTANT, PANEL_REGEN,
                   PANEL_SAVE, PANEL_SKILL, PANEL_SPELL_FAIL, PANEL_AC,
                   PANEL_D_RESIST, PANEL_D_SHIELD, PANEL_SP_SHIELD, PANEL_SPELLS );
    {$PACKENUM DEFAULT}

    {$PACKRECORDS 1}
    TEffectData = record
        Name:  pchar;       // The NWScript function is 'Effect' followed by Name with the spaces removed.
        Panel: TPanelEnum;  // The auxiliary panel that collects additional info.
        Param: smallint;    // Some additional info for some panels.
    end;
    {$PACKRECORDS DEFAULT}

const
    // Parameters for PANEL_CONSTANT:
    LIST_DISEASE       = 0;
    LIST_IMMUNITY_TYPE = 1;
    LIST_INVISIBILITY  = 2;
    LIST_POISON        = 3;

    // The parameter for PANEL_NUMBER is the maximum number that can be accepted.
    // If the parameter is negative, the absolute value is used and the label
    // is changed (somewhat haphazardly; see effectlistChange() for details).

    EffectArray: array[0..67] of TEffectData = (
        ( Name: 'Ability Decrease';          Panel: PANEL_ABILITY;    Param: 0 ),
        ( Name: 'Ability Increase';          Panel: PANEL_ABILITY;    Param: 0 ),
        ( Name: 'AC Decrease';               Panel: PANEL_AC;         Param: 0 ),
        ( Name: 'AC Increase';               Panel: PANEL_AC;         Param: 0 ),
        ( Name: 'Attack Decrease';           Panel: PANEL_NUMBER;     Param: 20 ),
        ( Name: 'Attack Increase';           Panel: PANEL_NUMBER;     Param: 20 ),
        ( Name: 'Blindness';                 Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Charmed';                   Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Concealment';               Panel: PANEL_PERCENT;    Param: 0 ),
        ( Name: 'Confused';                  Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Curse';                     Panel: PANEL_CURSE;      Param: 0 ),
        ( Name: 'Cutscene Ghost';            Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Cutscene Immobilize';       Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Cutscene Paralyze';         Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Damage Decrease';           Panel: PANEL_D_TYPE_R;   Param: 0 ),
        ( Name: 'Damage Increase';           Panel: PANEL_D_INC;      Param: 0 ),
        ( Name: 'Damage Immunity Decrease';  Panel: PANEL_D_TYPE;     Param: 0 ),
        ( Name: 'Damage Immunity Increase';  Panel: PANEL_D_TYPE;     Param: 0 ),
        ( Name: 'Damage Reduction';          Panel: PANEL_D_REDUCT;   Param: 0 ),
        ( Name: 'Damage Resistance';         Panel: PANEL_D_RESIST;   Param: 0 ),
        ( Name: 'Damage Shield';             Panel: PANEL_D_SHIELD;   Param: 0 ),
        ( Name: 'Dazed';                     Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Deaf';                      Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Death';                     Panel: PANEL_NONE;       Param: 0 ),   // Spectacular death (boolean)? Feedback (boolean)?
        ( Name: 'Disease';                   Panel: PANEL_CONSTANT;   Param: LIST_DISEASE ),
        ( Name: 'Dispel Magic All';          Panel: PANEL_NUMBER;     Param: -60 ),
        ( Name: 'Dispel Magic Best';         Panel: PANEL_NUMBER;     Param: -60 ),
        ( Name: 'Entangle';                  Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Ethereal';                  Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Frightened';                Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Haste';                     Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Heal';                      Panel: PANEL_NUMBER;     Param: 9999 ),
        ( Name: 'Immunity';                  Panel: PANEL_CONSTANT;   Param: LIST_IMMUNITY_TYPE ),
        ( Name: 'Invisibility';              Panel: PANEL_CONSTANT;   Param: LIST_INVISIBILITY ),
        ( Name: 'Knockdown';                 Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Miss Chance';               Panel: PANEL_PERCENT;    Param: 0 ), // Miss chance type?
        ( Name: 'Modify Attacks';            Panel: PANEL_NUMBER;     Param: 5 ),
        ( Name: 'Movement Speed Decrease';   Panel: PANEL_PERCENT;    Param: 0 ),
        ( Name: 'Movement Speed Increase';   Panel: PANEL_PERCENT;    Param: 0 ),
        ( Name: 'Negative Level';            Panel: PANEL_NUMBER;     Param: -100 ),
        ( Name: 'Paralyze';                  Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Petrify';                   Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Poison';                    Panel: PANEL_CONSTANT;   Param: LIST_POISON ),
        ( Name: 'Polymorph';                 Panel: PANEL_POLYMORPH;  Param: 0 ),
        ( Name: 'Regenerate';                Panel: PANEL_REGEN;      Param: 0 ),
        ( Name: 'Resurrection';              Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Sanctuary';                 Panel: PANEL_NUMBER;     Param: -255 ),
        ( Name: 'Saving Throw Decrease';     Panel: PANEL_SAVE;       Param: 0 ),
        ( Name: 'Saving Throw Increase';     Panel: PANEL_SAVE;       Param: 0 ),
        ( Name: 'See Invisible';             Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Silence';                   Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Skill Decrease';            Panel: PANEL_SKILL;      Param: 0 ),
        ( Name: 'Skill Increase';            Panel: PANEL_SKILL;      Param: 0 ),
        ( Name: 'Sleep';                     Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Slow';                      Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Spell Failure';             Panel: PANEL_SPELL_FAIL; Param: 0 ),
        ( Name: 'Spell Immunity';            Panel: PANEL_SPELLS;     Param: 0 ),
        ( Name: 'Spell Level Absorption';    Panel: PANEL_SP_SHIELD;  Param: 0 ),
        ( Name: 'Spell Resistance Decrease'; Panel: PANEL_NUMBER;     Param: 90 ),
        ( Name: 'Spell Resistance Increase'; Panel: PANEL_NUMBER;     Param: 90 ),
        ( Name: 'Stunned';                   Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Temporary Hitpoints';       Panel: PANEL_NUMBER;     Param: -9999 ),
        ( Name: 'Time Stop';                 Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'True Seeing';               Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Turned';                    Panel: PANEL_NONE;       Param: 0 ),
        ( Name: 'Turn Resistance Decrease';  Panel: PANEL_NUMBER;     Param: 50 ),
        ( Name: 'Turn Resistance Increase';  Panel: PANEL_NUMBER;     Param: 50 ),
        ( Name: 'Ultravision';               Panel: PANEL_NONE;       Param: 0 )
    );


// -----------------------------------------------------------------------------
// Event handlers

// Configures the form based on current circumstances.
procedure Tapplyeffect.FormCreate(Sender: TObject);
var
    i: integer;
begin
    // Initialize private variables.
    ShownPanel := nil;
    subtype_default := 0;
    duration_temp   := true;
    SetLength(QueuedLines, 1);
    QueuedLines[0] := '// Apply some effects.';

    // Load the effects.
    effectlist.Items.Capacity := Length(EffectArray);
    for i := Low(EffectArray) to High(EffectArray) do
        effectlist.Items.Append(EffectArray[i].Name);
    effectlist.ItemIndex := -1;

    // Load the polymorphs.
    LoadConstants(polylist.Items, POLYMORPH);
    polylist.itemindex := 0;

    // Load the spell constants.
    LoadConstants(SpellConstantBox.Items, SPELL);
    SpellConstantBox.Items.Insert(0, 'All spells');
    SpellConstantBox.ItemIndex := 0;

    // Load the save versus types.
    LoadConstants(SavingThrowType.Items, SAVING_THROW_TYPE);
    SavingThrowType.ItemIndex := 0;

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted, OBJECT_TYPE_CREATURE);
    // Make sure the selection is defaulted to something visible.
    with RadioPC do
        if Checked and not Visible then
            RadioTagged.Checked := TRUE;
end;


// Makes sure the "Okay" buttons are only enabled if all required info is supplied.
procedure Tapplyeffect.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // An effect must be selected.
    if effectlist.ItemIndex < 0 then
        bEnable := false
    // Also, a tagged target needs a tag.
    else
        bEnable :=  not RadioTagged.Checked or (EditTagged.Text <> '');

    // Update the buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// Handles selection of an effect from the drop-down list (TComboBox).
procedure Tapplyeffect.effectlistChange(Sender: TObject);
var
    index: integer;
begin
    index := effectlist.itemindex;

    // Hide the previous panel.
    if ShownPanel <> nil then begin
        ShownPanel.Visible := false;
        ShownPanel := nil;
    end;
    // Undo what the last selection might done to the form.
    GroupDuration.Enabled := true;
    SubType.Enabled := true;
    SubType.ItemIndex := subtype_default;
    if duration_temp then
        RadioTemporary.Checked := true
    else
        RadioPermanent.Checked := true;

    // Determine the next panel to show.
    if index >= 0 then
        case EffectArray[index].Panel of
            PANEL_NONE:       ShownPanel := nonepanel;
            PANEL_PERCENT:    ShownPanel := percentpanel;
            PANEL_NUMBER:     ShownPanel := numberpanel;
            PANEL_ABILITY:    ShownPanel := abilitypanel;
            PANEL_POLYMORPH:  ShownPanel := polymorphpanel;
            PANEL_CURSE:      ShownPanel := CursePanel;
            PANEL_D_TYPE:     ShownPanel := DamageTypePanel;
            PANEL_D_TYPE_R:   ShownPanel := DamageTypePanel;    // The "_R" means reversed parameter order in NWScript.
            PANEL_D_INC:      ShownPanel := DamageIncreasePanel;
            PANEL_D_REDUCT:   ShownPanel := DamageReductionPanel;
            PANEL_CONSTANT:   ShownPanel := SingleConstantPanel;
            PANEL_REGEN:      ShownPanel := RegeneratePanel;
            PANEL_SAVE:       ShownPanel := SavePanel;
            PANEL_SKILL:      ShownPanel := SkillPanel;
            PANEL_SPELL_FAIL: ShownPanel := SpellFailurePanel;
            PANEL_AC:         ShownPanel := ArmorClassPanel;
            PANEL_D_RESIST:   ShownPanel := DamageResistPanel;
            PANEL_D_SHIELD:   ShownPanel := DamageShieldPanel;
            PANEL_SP_SHIELD:  ShownPanel := SpellShieldPanel;
            PANEL_SPELLS:     ShownPanel := SpellConstantPanel;
        end;

    if ShownPanel <> nil then
        ShownPanel.Visible := true;

    // Auxiliary panel configuration.
    if ShownPanel = SingleConstantPanel then begin
        // We need to load the constants and set the label.
        FillConstantBox(EffectArray[index].Param);
        SingleConstantDescription.Caption :=
                'Choose the type of '+Lowercase(EffectArray[index].Name)+':';
    end
    else if ShownPanel = numberpanel then begin
        // We need to set the maximum value and label.
        if EffectArray[index].Param > 0 then begin
            NumberValue.MaxValue := EffectArray[index].Param;
            Label3.Caption := 'How much?';
        end
        else begin
            NumberValue.MaxValue := -EffectArray[index].Param;
            // Labels are somewhat haphazardly done in this case.
            if EffectArray[index].Param = -60 then
                Label3.Caption := 'Caster level:'
            else if EffectArray[index].Param = -255 then
                Label3.Caption := 'DC:'
            else
                Label3.Caption := 'How many?';
        end;
    end;

    // A few special cases.
    if index >= 0 then
        with EffectArray[index] do
            if (Name = 'Death') or (Name = 'Dispel Magic All')  or
               (Name = 'Heal')  or (Name = 'Dispel Magic Best') or
               (Name = 'Resurrection') then begin
                // Must be applied instantaneously.
                RadioPermanent.Checked := true; // Yes, "permanent" is standing in for "instant".
                GroupDuration.Enabled := false;
            end
            else if Name = 'Disease' then begin
                // Default to permanent and supernatural.
                RadioPermanent.Checked := true;
                SubType.ItemIndex := 2;
                // Prevent changing the subtype of diseases.
                SubType.Enabled := false;
            end
            else if Name = 'Poison' then begin
                // Default to permanent and supernatural.
                RadioPermanent.Checked := true;
                SubType.ItemIndex := 2;
            end;

    // Update the Okay buttons.
    ToggleOkay(Sender);
end;


// -----------------------------------------------------------------------------
// Private methods


// Clears most settings in the form so a new selection can be enetered.
// I am not sure that clearing everything is going to be all that convenient
// for the user, though. I think I shall comment out the resets of the auxiliary
// panel fields in case the user wants similar effects on multiple targets. --TK
procedure Tapplyeffect.ClearForm();
begin
    // Store some current settings.
    if SubType.Enabled then
        subtype_default := SubType.ItemIndex;
    if GroupDuration.Enabled then
        duration_temp := RadioTemporary.Checked;

    // Unselect the effect type.
    effectlist.ItemIndex := -1;
    // Need to manually trigger this:
    effectlistChange(effectlist);

    // Everything else in this procedure is commented out, but I kept it around
    // in case it is needed.


    // Reset values in the various auxiliary panels.

    // Spell constant panel:
    //SpellConstantBox.ItemIndex := 0;

    // Spell shield panel:
    //SpinSpellShieldLevel.Value := -1;
    //SpinSpellShieldLimit.Value := 0;
    //SpellShieldSchool.ItemIndex := 0;

    // Damage shield panel:
    //SpinDamageShield.Value := 0;
    //DamageShieldBonus.ItemIndex := 0;
    //DamageShieldType.ItemIndex := 0;

    // Damage resist panel:
    //DamageTypeBox.ItemIndex := 0;
    //DamageTypeInt.Value := 5;
    //DamageResistLimit.Value := 0;

    // AC panel:
    //SpinACAmount.Value := 1;
    //ComboACType.ItemIndex := 2;

    // Spell failure panel:
    //SpellSchool.ItemIndex := 0;
    //FailChance.Value := 100;

    // Skill panel:
    //SkillBox.ItemIndex := 0;
    //SkillValue.Value := 1;

    // Save panel:
    //SavingThrow.ItemIndex := 0;
    //SaveModifier.Value := 1;
    //SavingThrowType.ItemIndex := 0;

    // Regenerate panel:
    //RegenHP.Value := 1;
    //Interval.Value := 6;

    // Single constant panel:
    // (Reset when viewed)

    // Damage reduction panel:
    //DamagePowerBox.ItemIndex := 0;
    //DamageReduction.Value := 5;
    //DamageReductLimit.Value := 0;

    // Damage increase panel:
    //DamageIncTypeBox.ItemIndex := 0;
    //DamageBonusBox.ItemIndex := 0;

    // Damage type panel:
    //DamageTypeBox.ItemIndex := 0;
    //DamageTypeInt.Value := 5;

    // Curse panel:
    //strength.Value := 2;
    //dexterity.Value := 2;
    //constitution.value := 2;
    //intelligence.value := 2;
    //wisdom.value := 2;
    //charisma.value := 2;

    // Polymorph panel:
    //polylist.itemindex := 0;
    //CheckPolyCancel.Checked := true;

    // Ability panel:
    //abilityvalue.value := 2;
    //ability.ItemIndex := 2;

    // Number panel
    //numbervalue.value := 1;

    // Percent panel
    //percentvalue.value := 10;

    // None panel
    // (Nothing to reset)
end;


// Fills the TComboBox in the "single constant" panel with the requested set of
// constants.
// ConstantType is one of the LIST_* constants defined earlier in this unit.
procedure TApplyEffect.FillConstantBox(ConstantType: smallint);
begin
    case ConstantType of
        LIST_DISEASE:       LoadConstants(ConstantBox.Items, DISEASE_NAME);
        LIST_IMMUNITY_TYPE: LoadConstants(ConstantBox.Items, IMMUNITY_NAME);
        LIST_INVISIBILITY:  LoadConstants(ConstantBox.Items, INVISIBILITY_NAME);
        LIST_POISON:        LoadConstants(ConstantBox.Items, POISON);
        else ConstantBox.Clear(); // Bad input.
    end;

    // Select the first constant.
    ConstantBox.ItemIndex := 0;
end;


// Returns the command that creates the effect specified by the current state
// of the form.
// Do not call if effectlist does not have a selection!
function Tapplyeffect.MakeEffectString(): shortstring;
const
    // A conversion array.
    IntName: array[0..19] of pchar =
      ( 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE',
        'TEN', 'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN', 'SIXTEEN',
        'SEVENTEEN', 'EIGHTEEN', 'NINETEEN', 'TWENTY' );
var
    iEffect:  integer;
    sCommand: shortstring;
begin
    iEffect := effectlist.itemindex;

    // Start with the command name.
    sCommand := NameToCommand('Effect', EffectArray[iEffect].Name) + '(';

    // Add the parameters.
    case EffectArray[iEffect].Panel of
        PANEL_NONE:       ; // No parameters.
        PANEL_PERCENT:    sCommand += inttostr(percentvalue.value);
        PANEL_NUMBER:     sCommand += inttostr(numbervalue.value);
        PANEL_ABILITY:    sCommand += 'ABILITY_'+UpperCase(ability.Text)+', '+
                                      inttostr(abilityvalue.value);
        PANEL_CURSE:      sCommand += inttostr(strength.value)    +', '+
                                      inttostr(dexterity.value)   +', '+
                                      inttostr(constitution.value)+', '+
                                      inttostr(intelligence.value)+', '+
                                      inttostr(wisdom.value)      +', '+
                                      inttostr(charisma.value);
        PANEL_D_TYPE:     sCommand += 'DAMAGE_TYPE_'+UpperCase(DamageTypeBox.Text)+', '+
                                      inttostr(DamageTypeInt.Value);
        PANEL_D_TYPE_R:   sCommand += inttostr(DamageTypeInt.Value)+', '+
                                      'DAMAGE_TYPE_'+UpperCase(DamageTypeBox.Text);
        PANEL_D_INC:      sCommand += 'DAMAGE_BONUS_'+copy(DamageBonusBox.Text, 2, 4)+', '+
                                      'DAMAGE_TYPE_'+UpperCase(DamageIncTypeBox.Text);
        PANEL_REGEN:      sCommand += inttostr(RegenHP.Value)+', '+
                                      inttostr(Interval.Value)+'.0';
        PANEL_SKILL:      sCommand += NameToConstant('SKILL', SkillBox.Text)+', '+
                                      inttostr(SkillValue.Value);
        PANEL_AC:         sCommand += inttostr(SpinACAmount.Value)+', '+
                                      SymConst(AC_TYPE, ComboACType.ItemIndex);
        PANEL_D_SHIELD:   sCommand += inttostr(SpinDamageShield.Value)+', '+
                                      'DAMAGE_BONUS_'+copy(DamageShieldBonus.Text, 2, 4)+', '+
                                      'DAMAGE_TYPE_'+UpperCase(DamageShieldType.Text);
        PANEL_SPELLS:
            if SpellConstantBox.ItemIndex > 0 then
                sCommand += SymConst(SPELL, SpellConstantBox.ItemIndex-1)
            else
                sCommand += 'SPELL_ALL_SPELLS';

        PANEL_CONSTANT:
            // Which set of constants did we load?
            case EffectArray[iEffect].Param of
                LIST_DISEASE:       sCommand += SymConst(DISEASE_NAME, ConstantBox.ItemIndex);
                LIST_IMMUNITY_TYPE: sCommand += SymConst(IMMUNITY_NAME, ConstantBox.ItemIndex);
                LIST_INVISIBILITY:  sCommand += SymConst(INVISIBILITY_NAME, ConstantBox.ItemIndex);
                LIST_POISON:        sCommand += SymConst(POISON, ConstantBox.ItemIndex);
            end;

        // Panels with optional NWScript parameters:
        PANEL_POLYMORPH:
            sCommand += SymConst(POLYMORPH, polylist.ItemIndex) +
                        BoolToStr(not CheckPolyCancel.Checked, s_comma_TRUE, '');
        PANEL_D_REDUCT: begin
            sCommand += inttostr(DamageReduction.Value)+', '+
                        'DAMAGE_POWER_PLUS_'+IntName[DamagePowerBox.ItemIndex];
            if DamageReductLimit.Value > 0 then
                sCommand += ', '+inttostr(DamageReductLimit.Value);
        end;
        PANEL_SAVE: begin
            sCommand += 'SAVING_THROW_'+UpperCase(SavingThrow.Text)+', '+
                        inttostr(SaveModifier.Value);
            if SavingThrowType.ItemIndex > 0 then
                sCommand += ', '+SymConst(SAVING_THROW_TYPE, SavingThrowType.ItemIndex);
        end;
        PANEL_SPELL_FAIL: begin
            sCommand += inttostr(FailChance.Value);
            if SpellSchool.ItemIndex > 0 then
                sCommand += ', SPELL_SCHOOL_'+UpperCase(SpellSchool.Text);
        end;
        PANEL_D_RESIST: begin
            sCommand += 'DAMAGE_TYPE_'+UpperCase(DamageResistType.Text)+', '+
                        inttostr(SpinDamageResistance.Value);
            if DamageResistLimit.Value > 0 then
                sCommand += ', '+inttostr(DamageResistLimit.Value);
        end;
        PANEL_SP_SHIELD: begin
            sCommand += inttostr(SpinSpellShieldLevel.Value);
            if (SpinSpellShieldLimit.Value > 0) or (SpellShieldSchool.ItemIndex > 0) then
                sCommand += ', '+IntToStr(SpinSpellShieldLimit.Value);
            if SpellShieldSchool.ItemIndex > 0 then
                sCommand += ', SPELL_SCHOOL_'+UpperCase(SpellShieldSchool.Text);
        end;

    end;//case

    // End the function call.
    sCommand += ')';

    if SubType.Enabled then
        // Assign a subtype to this effect.
        case SubType.ItemIndex of
            1: sCommand := 'ExtraordinaryEffect('+sCommand+')';
            2: sCommand := 'SupernaturalEffect('+sCommand+')';
        end;

    // Return the result.
    result := sCommand;
end;


// Sends the currently specified effect to the queue for later batch submission.
procedure Tapplyeffect.QueueThis();
var
    target:   TObjectEnum;
    duration: integer;

    queue_length: integer;
begin
    queue_length := Length(QueuedLines);

    // Who will receive this effect?
    target := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                              RadioTagged, RadioActor, RadioSpawn, FALSE);
    // Declare a variable if needed.
    if target = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    if target = E_CHOOSE_Tagged then begin
        // Queue the definition of oTarget.
        SetLength(QueuedLines, queue_length + 1);
        QueuedLines[queue_length] :=
                s_oTarget+' = '+s_GetObject + QuoteSwap(EditTagged.text)+'");';
        Inc(queue_length);
   end;

    // What effect will this be? (Assign it to eEffect in the script.)
    SetLength(QueuedLines, queue_length + 1);
    QueuedLines[queue_length] := s_eEffect+' = '+MakeEffectString()+';';
    Inc(queue_length);

    // For how long will this effect endure?
    if RadioTemporary.checked then
        duration := spinedit2.value
    else if GroupDuration.Enabled then
        duration := -1  // Permanent effect.
    else
        duration := 0;  // Instantaneous effect.

    // Queue the effect-applying line.
    SetLength(QueuedLines, queue_length + 1);
    QueuedLines[queue_length] :=
                Script.ApplyEffect(s_eEffect, ObjectVar(target), FALSE, duration)+';';
end;


// Sends the stored scripting lines to the script window.
procedure Tapplyeffect.SendQueue();
var
    last_line: integer;
begin
    last_line := High(QueuedLines);

    // Abort if there is nothing to send.
    if last_line < 1 then
        exit;

    // Change the opening comment if only one effect is being applied.
    if last_line <= 3 then
        QueuedLines[0] := '// Apply an effect.';

    // Submit these lines.
    Tlilac.AddLines(QueuedLines, 1, last_line);
end;


initialization
  {$i effect.lrs}
end.
