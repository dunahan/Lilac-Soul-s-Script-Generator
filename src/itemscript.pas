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
* Some of this was trimmed when I converted the forms to being modal.
* Added some options for who can possess the item.
* Added "cursed" flag.
* Reorganized the form's layout.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit itemscript;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms,
  {Dialogs,} StdCtrls, ExtCtrls, Buttons, Spin,
  LResources, QueueForm, nwn;

type

  { Titemscripting }

  Titemscripting = class(TQueueForm)
    // Form elements
      BitBtnPalette: TBitBtn;
      ComboBox2: TComboBox;
      EditItemName: TEdit;
      EditItemTagged: TEdit;
      EditTagged: TEdit;
      GroupDuration: TGroupBox;
      GroupItem: TGroupBox;
      GroupPossessor: TGroupBox;
      ipOnHitConst: TComboBox;
      LabelItemName: TLabel;
      LabelPropDetails: TLabel;
      LabelPropAmount: TLabel;
      LabelPropType: TLabel;
      LabelPropSubtype: TLabel;
      LabelSeconds: TLabel;
    RadioActivator: TRadioButton;
    RadioGroup3: TRadioGroup;
    RadioGroup4: TRadioGroup;
    RadioGroup5: TRadioGroup;
    RadioGroup6: TRadioGroup;
    CheckBox1: TCheckBox;
    iprop: TComboBox;
    ipconst: TComboBox;
    BitBtn1: TBitBtn;
    GroupCursed: TRadioGroup;
    RadioItemScriptItem: TRadioButton;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioPermanent: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioActor: TRadioButton;
    RadioTagged: TRadioButton;
    RadioItemTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    RadioItemSlot: TRadioButton;
    RadioTemporary: TRadioButton;
    secondparam: TComboBox;
    SpinEdit1: TSpinEdit;
    SpinPropAmount: TSpinEdit;
    thirdparam: TComboBox;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    // Event handlers:
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtnPaletteClick(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ipOnHitConstChange(Sender: TObject);
    procedure ipropChange(Sender: TObject);
    procedure RadioGroup6Click(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  protected
    // Helper methods
    procedure ClearForm(); override;
    procedure QueueThis(); override;
    procedure SendQueue(); override;

  private
    // The queue:
    sPossessor: shortstring;
    sItem: shortstring;
    sName: shortstring;
    // Settings for which only the last one matters:
    flagPlot, flagStolen, flagDrop, flagCursed: shortint;
    // Settings that actually get queued:
    ListFlags: array of shortint;
    ListTypes: array of shortint; // Could be made a larger int if needed.
    ListSubtypes: array of shortstring;
    ListDetails1: array of shortstring;
    ListDetails2: array of shortstring;
    ListAmounts:  array of shortint; // Could be made a larger int if needed.
    ListDurations:array of longword; // Values of zero indicate permanent.

    // Helper method
    procedure PropsToLines(nProp:integer; const item_var: shortstring;
                           var last_line:integer; var new_lines:TStringAry);
  end;

{var
  itemscripting: Titemscripting;
}

implementation

uses
    {event,} ipSpell, start, constants, palettetool;

const
    OBJECT_WITH_INVENTORY = OBJECT_TYPE_CREATURE or OBJECT_TYPE_PLACEABLE or
                            OBJECT_TYPE_STORE;

    // The choices for item properties and flags:
    IP_SEL_NOTHING = 0;
    IP_SEL_ADD     = 1; // Also "set flag".
    IP_SEL_REMOVE  = 2; // Also "clear flag".
    IP_SEL_ALL     = 3;

    // An amount that will never be a valid choice.
    IP_AMOUNT_IGNORE = -1;

    // A flag that is not an inventory slot nor does it start with TAG_FLAG:
    TAGBASED = 'TB';

// -----------------------------------------------------------------------------
// Types and constants to define the various properties we can Generate.
type
    {$PACKENUM 1}
    TIPConstEnum =
      ( IPC_NONE, IPC_SPECIAL,
        IPC_ABILITY,       IPC_ACTYPE,        IPC_ADDITIONAL,    IPC_ALIGNMENT,
        IPC_ALIGNGROUP,    IPC_ARCANEFAIL,    IPC_CAST_SPELL,    IPC_CAST_USES,
        IPC_CLASS,         IPC_CLASS_CASTER,  IPC_CONTAINER,     IPC_DAMAGE_BONUS,
        IPC_DAMAGE_IMM,    IPC_DAMAGE_RED,    IPC_DAMAGE_RES,    IPC_DAMAGE_SOAK,
        IPC_DAMAGE_TYPE,   IPC_DAMAGE_TYPE_P, IPC_DAMAGE_VULN,   IPC_DISEASE,
        IPC_FEAT,          IPC_IMMUNE_MISC,   IPC_IMMUNE_SPELL,  IPC_ITEM_POISON,
        IPC_LIGHT_BRIGHT,  IPC_LIGHT_COLOR,   IPC_MATERIAL,      IPC_MON_DAMAGE,
        IPC_ONHIT,         IPC_ONHIT_DUR,     IPC_ONHIT_SAVE,    IPC_ONHIT_SPELL,
        IPC_ONMONSTERHIT,  IPC_POISON,        IPC_QUALITY,       IPC_RACE,
        IPC_REDUCEWEIGHT,  IPC_SAVETYPE,      IPC_SAVEVS,        IPC_SKILL,
        IPC_SPELLRESIST,   IPC_SPELLSCHOOL,   IPC_TRAP_POWER,    IPC_TRAP_TYPE,
        IPC_UNLIMIT_AMMO,  IPC_VISUAL,        IPC_WEIGHT,        IPC_1_TO_5 );
    {$PACKENUM DEFAULT}

    {$PACKRECORDS 1}
    TItemPropData = record
        Name:      pchar;        // The NWScript function is 'ItemProperty' followed by Name with the spaces removed.
        Subtype:   TIPConstEnum; // The choices for the subtype. IPC_NONE to hide this.
        Detail1:   TIPConstEnum; // The choices for the first set of details. IPC_NONE to hide this.
        Detail2:   TIPConstEnum; // The choices for the second set of details. IPC_NONE to hide this.
        Low, High: shortint;     // The low and high values of the spinner. High = Low to hide this.
        ValLabel:  pchar;        // The label for the spinner. Can be nil for 'Amount:'.
    end;
    {$PACKRECORDS DEFAULT}

const
    ItemPropArray: array[0..77] of TItemPropData = (
        ( Name: 'Ability Bonus';                  Subtype: IPC_ABILITY;       Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 12; ValLabel: nil ),
        ( Name: 'AC Bonus';                       Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'AC Bonus Vs. Align';             Subtype: IPC_ALIGNGROUP;    Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'AC Bonus Vs. Dmg Type';          Subtype: IPC_DAMAGE_TYPE_P; Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'AC Bonus Vs. Race';              Subtype: IPC_RACE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'AC Bonus Vs. S. Align';          Subtype: IPC_ALIGNMENT;     Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Additional';                     Subtype: IPC_NONE;          Detail1: IPC_ADDITIONAL;  Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Arcane Spell Failure';           Subtype: IPC_NONE;          Detail1: IPC_ARCANEFAIL;  Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Attack Bonus';                   Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Attack Bonus Vs. Align';         Subtype: IPC_ALIGNGROUP;    Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Attack Bonus Vs. Race';          Subtype: IPC_RACE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Attack Bonus Vs. S. Align';      Subtype: IPC_ALIGNMENT;     Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Attack Penalty';                 Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 5;  ValLabel: nil ),
        ( Name: 'Bonus Feat';                     Subtype: IPC_NONE;          Detail1: IPC_FEAT;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Bonus Level Spell';              Subtype: IPC_CLASS_CASTER;  Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 9;  ValLabel: 'Level:' ),
        ( Name: 'Bonus Saving Throw';             Subtype: IPC_SAVETYPE;      Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Bonus Saving Throw Vs. X';       Subtype: IPC_SAVEVS;        Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Bonus Spell Resistance';         Subtype: IPC_NONE;          Detail1: IPC_SPELLRESIST; Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Cast Spell';                     Subtype: IPC_NONE;          Detail1: IPC_CAST_SPELL;  Detail2: IPC_CAST_USES;    Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Container Reduced Weight';       Subtype: IPC_NONE;          Detail1: IPC_CONTAINER;   Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Damage Bonus';                   Subtype: IPC_NONE;          Detail1: IPC_DAMAGE_TYPE; Detail2: IPC_DAMAGE_BONUS; Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Damage Bonus Vs. Align';         Subtype: IPC_ALIGNGROUP;    Detail1: IPC_DAMAGE_TYPE; Detail2: IPC_DAMAGE_BONUS; Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Damage Bonus Vs. Race';          Subtype: IPC_RACE;          Detail1: IPC_DAMAGE_TYPE; Detail2: IPC_DAMAGE_BONUS; Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Damage Bonus Vs. S. Align';      Subtype: IPC_ALIGNMENT;     Detail1: IPC_DAMAGE_TYPE; Detail2: IPC_DAMAGE_BONUS; Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Damage Immunity';                Subtype: IPC_NONE;          Detail1: IPC_DAMAGE_TYPE; Detail2: IPC_DAMAGE_IMM;   Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Damage Penalty';                 Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 5;  ValLabel: nil ),
        ( Name: 'Damage Reduction';               Subtype: IPC_NONE;          Detail1: IPC_DAMAGE_RED;  Detail2: IPC_DAMAGE_SOAK;  Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Damage Resistance';              Subtype: IPC_NONE;          Detail1: IPC_DAMAGE_TYPE; Detail2: IPC_DAMAGE_RES;   Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Damage Vulnerability';           Subtype: IPC_NONE;          Detail1: IPC_DAMAGE_TYPE; Detail2: IPC_DAMAGE_VULN;  Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Darkvision';                     Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Decrease Ability';               Subtype: IPC_ABILITY;       Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 10; ValLabel: nil ),
        ( Name: 'Decrease AC';                    Subtype: IPC_ACTYPE;        Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 5;  ValLabel: nil ),
        ( Name: 'Decrease Skill';                 Subtype: IPC_SKILL;         Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 10; ValLabel: nil ),
        ( Name: 'Enhancement Bonus';              Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Enhancement Bonus Vs. Align';    Subtype: IPC_ALIGNGROUP;    Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Enhancement Bonus Vs. Race';     Subtype: IPC_RACE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Enhancement Bonus Vs. S. Align'; Subtype: IPC_ALIGNMENT;     Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Enhancement Penalty';            Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 5;  ValLabel: nil ),
        ( Name: 'Extra Melee Damage Type';        Subtype: IPC_DAMAGE_TYPE_P; Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Extra Range Damage Type';        Subtype: IPC_DAMAGE_TYPE_P; Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Free Action';                    Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Haste';                          Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Healers'' Kit';                  Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 12; ValLabel: 'Bonus:' ),
        ( Name: 'Holy Avenger';                   Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Immunity Misc.';                 Subtype: IPC_IMMUNE_MISC;   Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Immunity To Spell Level';        Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 9;  ValLabel: 'This level and below:' ),
        ( Name: 'Improved Evasion';               Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Keen';                           Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Light';                          Subtype: IPC_NONE;          Detail1: IPC_LIGHT_BRIGHT;Detail2: IPC_LIGHT_COLOR;  Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Limit Use By Align';             Subtype: IPC_ALIGNGROUP;    Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Limit Use By Class';             Subtype: IPC_CLASS;         Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Limit Use By Race';              Subtype: IPC_RACE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Limit Use By S. Align';          Subtype: IPC_ALIGNMENT;     Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Massive Critical';               Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_DAMAGE_BONUS; Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Material';                       Subtype: IPC_NONE;          Detail1: IPC_MATERIAL;    Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Max. Range Strength Mod';        Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Monster Damage';                 Subtype: IPC_NONE;          Detail1: IPC_MON_DAMAGE;  Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'No Damage';                      Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'On Hit Cast Spell';              Subtype: IPC_ONHIT_SPELL;   Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 40; ValLabel: 'Caster level:' ),
        ( Name: 'On Hit Props';                   Subtype: IPC_ONHIT;         Detail1: IPC_ONHIT_SAVE;  Detail2: IPC_SPECIAL;      Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'On Monster Hit Properties';      Subtype: IPC_ONMONSTERHIT;  Detail1: IPC_NONE;        Detail2: IPC_SPECIAL;      Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Quality';                        Subtype: IPC_NONE;          Detail1: IPC_QUALITY;     Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Reduced Saving Throw';           Subtype: IPC_SAVETYPE;      Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Reduced Saving Throw Vs. X';     Subtype: IPC_SAVEVS;        Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Regeneration';                   Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Skill Bonus';                    Subtype: IPC_SKILL;         Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 50; ValLabel: nil ),
        ( Name: 'Special Walk';                   Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Spell Immunity School';          Subtype: IPC_SPELLSCHOOL;   Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Spell Immunity Specific';        Subtype: IPC_IMMUNE_SPELL;  Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Thieves'' Tools';                Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 12; ValLabel: 'Bonus:' ),
        ( Name: 'Trap';                           Subtype: IPC_NONE;          Detail1: IPC_TRAP_POWER;  Detail2: IPC_TRAP_TYPE;    Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'True Seeing';                    Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Turn Resistance';                Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 50; ValLabel: nil ),
        ( Name: 'Unlimited Ammo';                 Subtype: IPC_NONE;          Detail1: IPC_UNLIMIT_AMMO;Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Vampiric Regeneration';          Subtype: IPC_NONE;          Detail1: IPC_NONE;        Detail2: IPC_NONE;         Low: 1; High: 20; ValLabel: nil ),
        ( Name: 'Visual Effect';                  Subtype: IPC_NONE;          Detail1: IPC_VISUAL;      Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Weight Increase';                Subtype: IPC_NONE;          Detail1: IPC_WEIGHT;      Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil ),
        ( Name: 'Weight Reduction';               Subtype: IPC_NONE;          Detail1: IPC_REDUCEWEIGHT;Detail2: IPC_NONE;         Low: 0; High: 0;  ValLabel: nil )
      );


// Returns the current IPC_* code for an IPC_SPECIAL, based on the property and
// subtype selections. (prop_index should be iprop.ItemIndex, and const_index
// should be ipOnHitConst.ItemIndex.) On error, returns IPC_NONE.
// (This will not automatically update itself if a subtype other than IPC_ONHIT
// or IPC_ONMONSTERHIT is given an IPC_SPECIAL parameter.)
// MUST NOT RETURN IPC_SPECIAL. EVER!
function GetSpecialCode(prop_index, const_index: integer): TIPConstEnum;
var
    sCode: pchar;
begin
    // Get the code for the current selection.
    if (prop_index < 0) or (const_index < 0) then
        sCode := nil
    else
        case ItemPropArray[prop_index].Subtype of
            IPC_ONHIT:        sCode := ConstInfo(IP_CONST_ONHIT, const_index);
            IPC_ONMONSTERHIT: sCode := ConstInfo(IP_CONST_ONMONSTERHIT, const_index);
            else              sCode := nil;
        end;

    // Convert the string code to an enumerated code.
    if      sCode = nil   then result := IPC_NONE
    else if sCode = '1-5' then result := IPC_1_TO_5
    else if sCode = 'abi' then result := IPC_ABILITY
    else if sCode = 'alg' then result := IPC_ALIGNGROUP
    else if sCode = 'ali' then result := IPC_ALIGNMENT
    else if sCode = 'dis' then result := IPC_DISEASE
    else if sCode = 'dur' then result := IPC_ONHIT_DUR
    else if sCode = 'itp' then result := IPC_ITEM_POISON
    else if sCode = 'poi' then result := IPC_POISON
    else if sCode = 'rac' then result := IPC_RACE
    else
        // Should not get to here, but just in case.
        result := IPC_NONE;
end;


// Loads _load_to_ with the names of the item property details specified by _load_which_.
// Also sets the visibility.
procedure BuildIPConst(load_to: TComboBox; load_which: TIPConstEnum);
var
    sTest: string;
begin
    // Allow selections to remain if the items have not changed.
    if load_to.Items.Count > 0 then
        sTest := load_to.Items[0]
    else
        sTest := '';

    // Just a big old case statement, which is needed because not all the item
    // property details are the same type (some are names, while others are
    // StringPairs), so there are actually different function calls involved.
    case load_which of
        IPC_ABILITY      : LoadConstants(load_to.Items, IP_CONST_ABILITY);
        IPC_ACTYPE       : LoadConstants(load_to.Items, IP_CONST_ACMODIFIERTYPE_NAME);
        IPC_ADDITIONAL   : LoadConstants(load_to.Items, IP_CONST_ADDITIONAL_NAME);
        IPC_ALIGNMENT    : LoadConstants(load_to.Items, IP_CONST_ALIGNMENT);
        IPC_ALIGNGROUP   : LoadConstants(load_to.Items, IP_CONST_ALIGNMENTGROUP_NAME);
        IPC_ARCANEFAIL   : LoadConstants(load_to.Items, IP_CONST_ARCANE_SPELL_FAILURE_NAME);
        IPC_CAST_SPELL   : LoadConstants(load_to.Items, IP_CONST_CASTSPELL);
        IPC_CAST_USES    : LoadConstants(load_to.Items, IP_CONST_CASTSPELL_NUMUSES_NAME);
        IPC_CLASS        : LoadConstants(load_to.Items, NWNCLASS);
        IPC_CLASS_CASTER : LoadConstants(load_to.Items, IP_CONST_CLASS_CASTER);
        IPC_CONTAINER    : LoadConstants(load_to.Items, IP_CONST_CONTAINERWEIGHTRED_NAME);
        IPC_DAMAGE_BONUS : LoadConstants(load_to.Items, IP_CONST_DAMAGEBONUS);
        IPC_DAMAGE_IMM   : LoadConstants(load_to.Items, IP_CONST_DAMAGEIMMUNITY_NAME);
        IPC_DAMAGE_RED   : LoadConstants(load_to.Items, IP_CONST_DAMAGEREDUCTION);
        IPC_DAMAGE_RES   : LoadConstants(load_to.Items, IP_CONST_DAMAGERESIST_NAME);
        IPC_DAMAGE_SOAK  : LoadConstants(load_to.Items, IP_CONST_DAMAGESOAK_NAME);
        IPC_DAMAGE_TYPE  : LoadConstants(load_to.Items, IP_CONST_DAMAGETYPE_NAME);
        IPC_DAMAGE_TYPE_P: LoadConstants(load_to.Items, IP_CONST_DAMAGETYPE_NAME[0..3]); // The last element is ignored.
        IPC_DAMAGE_VULN  : LoadConstants(load_to.Items, IP_CONST_DAMAGEVULNERABILITY_NAME);
        IPC_DISEASE      : LoadConstants(load_to.Items, DISEASE_NAME);
        IPC_FEAT         : LoadConstants(load_to.Items, IP_CONST_FEAT);
        IPC_IMMUNE_MISC  : LoadConstants(load_to.Items, IP_CONST_IMMUNITYMISC);
        IPC_IMMUNE_SPELL : LoadConstants(load_to.Items, IP_CONST_IMMUNITYSPELL);
        IPC_ITEM_POISON  : LoadConstants(load_to.Items, IP_CONST_POISON);
        IPC_LIGHT_BRIGHT : LoadConstants(load_to.Items, IP_CONST_LIGHTBRIGHTNESS_NAME);
        IPC_LIGHT_COLOR  : LoadConstants(load_to.Items, IP_CONST_LIGHTCOLOR_NAME);
        IPC_MATERIAL     : LoadConstants(load_to.Items, IP_CONST_MATERIAL);
        IPC_MON_DAMAGE   : LoadConstants(load_to.Items, IP_CONST_MONSTERDAMAGE_NAME);
        IPC_ONHIT        : LoadConstants(load_to.Items, IP_CONST_ONHIT);
        IPC_ONHIT_DUR    : LoadConstants(load_to.Items, IP_CONST_ONHIT_DURATION_NAME);
        IPC_ONHIT_SAVE   : LoadConstants(load_to.Items, IP_CONST_ONHIT_SAVEDC);
        IPC_ONHIT_SPELL  : LoadConstants(load_to.Items, IP_CONST_ONHIT_CASTSPELL);
        IPC_ONMONSTERHIT : LoadConstants(load_to.Items, IP_CONST_ONMONSTERHIT);
        IPC_POISON       : LoadConstants(load_to.Items, POISON);
        IPC_QUALITY      : LoadConstants(load_to.Items, IP_CONST_QUALITY_NAME);
        IPC_RACE         : LoadConstants(load_to.Items, RACIAL_TYPE);
        IPC_REDUCEWEIGHT : LoadConstants(load_to.Items, IP_CONST_REDUCEDWEIGHT_NAME);
        IPC_SAVETYPE     : LoadConstants(load_to.Items, IP_CONST_SAVEBASETYPE_NAME);
        IPC_SAVEVS       : LoadConstants(load_to.Items, IP_CONST_SAVEVS_NAME);
        IPC_SKILL        : LoadConstants(load_to.Items, SKILL_NAME);
        IPC_SPELLRESIST  : LoadConstants(load_to.Items, IP_CONST_SPELLRESISTANCEBONUS_NAME);
        IPC_SPELLSCHOOL  : LoadConstants(load_to.Items, IP_CONST_SPELLSCHOOL_NAME);
        IPC_TRAP_POWER   : LoadConstants(load_to.Items, IP_CONST_TRAPSTRENGTH);
        IPC_TRAP_TYPE    : LoadConstants(load_to.Items, IP_CONST_TRAPTYPE_NAME);
        IPC_UNLIMIT_AMMO : LoadConstants(load_to.Items, IP_CONST_UNLIMITEDAMMO);
        IPC_VISUAL       : LoadConstants(load_to.Items, IP_CONST_VISUAL_NAME);
        IPC_WEIGHT       : LoadConstants(load_to.Items, IP_CONST_WEIGHTINCREASE_NAME);
        IPC_1_TO_5       : LoadConstants(load_to.Items, IP_CONST_AMOUNT );
    end;

    // Allow selections to remain (only) if the items have not changed.
    if load_to.Items.Count > 0 then
        if sTest <> load_to.Items[0] then
            load_to.ItemIndex := -1;

    // Also handle visibility.
    load_to.Visible := (load_which <> IPC_NONE) and (load_which <> IPC_SPECIAL);
end;


// Returns the NWScript symbolic constant for item number _index_ in the list
// spcified by _get_which_.
// On error (including getting an IPC_NONE), returns ''.
//
// If _get_which_ might be IPC_SPECIAL, then prop_index should be iprop.ItemIndex,
// and const_index should be ipOnHitConst.ItemIndex.
// These can be omitted when IPC_SPECIAL is not a possibility. (Currently, only
// Detail2 is ever made to be IPC_SPECIAL.)
function GetIPConst(get_which: TIPConstEnum; index: integer;
                    prop_index: integer=-1;  const_index: integer=-1) : shortstring;
begin
    // Default value.
    result := '';

    // Safety check.
    if index < 0 then
        exit;

    // Just a big old case statement, which is needed because not all the item
    // property details are the same type (some are names, while others are
    // StringPairs), so there are actually different function calls involved.
    case get_which of
        IPC_ABILITY      : result := SymConst(IP_CONST_ABILITY, index);
        IPC_ACTYPE       : result := SymConst(IP_CONST_ACMODIFIERTYPE_NAME, index);
        IPC_ADDITIONAL   : result := SymConst(IP_CONST_ADDITIONAL_NAME, index);
        IPC_ALIGNMENT    : result := SymConst(IP_CONST_ALIGNMENT, index);
        IPC_ALIGNGROUP   : result := SymConst(IP_CONST_ALIGNMENTGROUP_NAME, index);
        IPC_ARCANEFAIL   : result := SymConst(IP_CONST_ARCANE_SPELL_FAILURE_NAME, index);
        IPC_CAST_SPELL   : result := SymConst(IP_CONST_CASTSPELL, index);
        IPC_CAST_USES    : result := SymConst(IP_CONST_CASTSPELL_NUMUSES_NAME, index);
        IPC_CLASS        : result := SymConst(NWNCLASS, index);
        IPC_CLASS_CASTER : result := SymConst(IP_CONST_CLASS_CASTER, index);
        IPC_CONTAINER    : result := SymConst(IP_CONST_CONTAINERWEIGHTRED_NAME, index);
        IPC_DAMAGE_BONUS : result := SymConst(IP_CONST_DAMAGEBONUS, index);
        IPC_DAMAGE_IMM   : result := SymConst(IP_CONST_DAMAGEIMMUNITY_NAME, index);
        IPC_DAMAGE_RED   : result := SymConst(IP_CONST_DAMAGEREDUCTION, index);
        IPC_DAMAGE_RES   : result := SymConst(IP_CONST_DAMAGERESIST_NAME, index);
        IPC_DAMAGE_SOAK  : result := SymConst(IP_CONST_DAMAGESOAK_NAME, index);
        IPC_DAMAGE_TYPE  : result := SymConst(IP_CONST_DAMAGETYPE_NAME, index);
        IPC_DAMAGE_TYPE_P: result := SymConst(IP_CONST_DAMAGETYPE_NAME, index);
        IPC_DAMAGE_VULN  : result := SymConst(IP_CONST_DAMAGEVULNERABILITY_NAME, index);
        IPC_DISEASE      : result := SymConst(DISEASE_NAME, index);
        IPC_FEAT         : result := SymConst(IP_CONST_FEAT, index);
        IPC_IMMUNE_MISC  : result := SymConst(IP_CONST_IMMUNITYMISC, index);
        IPC_IMMUNE_SPELL : result := SymConst(IP_CONST_IMMUNITYSPELL, index);
        IPC_ITEM_POISON  : result := SymConst(IP_CONST_POISON, index);
        IPC_LIGHT_BRIGHT : result := SymConst(IP_CONST_LIGHTBRIGHTNESS_NAME, index);
        IPC_LIGHT_COLOR  : result := SymConst(IP_CONST_LIGHTCOLOR_NAME, index);
        IPC_MATERIAL     : result := SymConst(IP_CONST_MATERIAL, index);
        IPC_MON_DAMAGE   : result := SymConst(IP_CONST_MONSTERDAMAGE_NAME, index);
        IPC_ONHIT        : result := SymConst(IP_CONST_ONHIT, index);
        IPC_ONHIT_DUR    : result := SymConst(IP_CONST_ONHIT_DURATION_NAME, index);
        IPC_ONHIT_SAVE   : result := SymConst(IP_CONST_ONHIT_SAVEDC, index);
        IPC_ONHIT_SPELL  : result := SymConst(IP_CONST_ONHIT_CASTSPELL, index);
        IPC_ONMONSTERHIT : result := SymConst(IP_CONST_ONMONSTERHIT, index);
        IPC_POISON       : result := SymConst(POISON, index);
        IPC_QUALITY      : result := SymConst(IP_CONST_QUALITY_NAME, index);
        IPC_RACE         : result := SymConst(RACIAL_TYPE, index);
        IPC_REDUCEWEIGHT : result := SymConst(IP_CONST_REDUCEDWEIGHT_NAME, index);
        IPC_SAVETYPE     : result := SymConst(IP_CONST_SAVEBASETYPE_NAME, index);
        IPC_SAVEVS       : result := SymConst(IP_CONST_SAVEVS_NAME, index);
        IPC_SKILL        : result := SymConst(SKILL_NAME, index);
        IPC_SPELLRESIST  : result := SymConst(IP_CONST_SPELLRESISTANCEBONUS_NAME, index);
        IPC_SPELLSCHOOL  : result := SymConst(IP_CONST_SPELLSCHOOL_NAME, index);
        IPC_TRAP_POWER   : result := SymConst(IP_CONST_TRAPSTRENGTH, index);
        IPC_TRAP_TYPE    : result := SymConst(IP_CONST_TRAPTYPE_NAME, index);
        IPC_UNLIMIT_AMMO : result := SymConst(IP_CONST_UNLIMITEDAMMO, index);
        IPC_VISUAL       : result := SymConst(IP_CONST_VISUAL_NAME, index);
        IPC_WEIGHT       : result := SymConst(IP_CONST_WEIGHTINCREASE_NAME, index);
        IPC_1_TO_5       : result := SymConst(IP_CONST_AMOUNT, index);

        // Special case: This is why GetSpecialCode() must never return IPC_SEPCIAL.
        IPC_SPECIAL      : result := GetIPConst(GetSpecialCode(prop_index, const_index), index);
    end;
end;


// -----------------------------------------------------------------------------


// Configures the form for current circumstances.
procedure Titemscripting.FormCreate(Sender: TObject);
var
    i: integer;
begin
    // Initialize the queue.
    sPossessor := '';
    sItem := '';
    sName := '';
    flagPlot   := IP_SEL_NOTHING;
    flagStolen := IP_SEL_NOTHING;
    flagDrop   := IP_SEL_NOTHING;
    flagCursed := IP_SEL_NOTHING;
    SetLength(ListFlags, 0);
    // The other arrays are assumed the same length as ListFlags.

    // Load the item property list.
    iprop.Items.Capacity := Length(ItemPropArray);
    for i := Low(ItemPropArray) to High(ItemPropArray) do
        iprop.Items.Append(ItemPropArray[i].Name);
    iprop.ItemIndex := -1;

    // Load the inventory slots.
    LoadConstants(ComboBox2.Items, INVENTORY_SLOT);
    ComboBox2.ItemIndex := 8;

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_WITH_INVENTORY);
    main.InitActivationRadios(RadioPC, RadioOwner, RadioActivator, RadioTargeted, OBJECT_WITH_INVENTORY);
    RadioItemScriptItem.Visible := main.GetIsItemScript();
end;


// Informs Tlilac that there will be no more lines from us.
procedure Titemscripting.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Tlilac.AddLinesDone();
end;


// Shows the BioWare comments documenting which spells can be cast from which items.
procedure Titemscripting.BitBtn1Click(Sender: TObject);
begin
    main.ShowPopup(TipCastSpell);
end;


// Shows the palette search window.
procedure Titemscripting.BitBtnPaletteClick(Sender: TObject);
begin
    // Call up the palette window, items by default.
    TPaletteWindow.Load(EditItemTagged, EditItemName, SEARCH_ITEMS, false);
end;


// Selects the associated radio button when the selection changes.
procedure Titemscripting.ComboBox2Change(Sender: TObject);
begin
    RadioItemSlot.Checked := true;
    ToggleOkay(Sender);
end;


// Handles changes to the on-hit subtypes, as the third parameter depends on this.
// Also does monster on-hits.
// (Specifically, this is active when the current item property type has a third
// parameter of IPC_SPECIAL.)
procedure Titemscripting.ipOnHitConstChange(Sender: TObject);
begin
    // Fill in the combo box.
    BuildIPConst(thirdparam, GetSpecialCode(iprop.ItemIndex, ipOnHitConst.ItemIndex));

    // Label visibility.
    LabelPropDetails.Visible := thirdparam.Visible or secondparam.Visible;

    // Update the "Okay" buttons.
    ToggleOkay(Sender);
end;


// Handles changes to the type of item property.
// Only does more than call ToggleOkay() if we are adding a property, in which
// case we update the parameters for that property.
procedure Titemscripting.ipropChange(Sender: TObject);
var
    IPData: ^TItemPropData;
begin
    if (radiogroup6.itemindex = IP_SEL_ADD) and (iprop.ItemIndex >= 0) then begin
        // For readability:
        IPData := @ItemPropArray[iprop.ItemIndex];

        // Configure the parameter selection.
        if IPData^.Detail2 = IPC_SPECIAL then begin
            ipconst.Visible := false;
            BuildIPConst(ipOnHitConst, IPData^.Subtype);
            if ipOnHitConst.Visible then
                ipconst.ItemIndex := -1;
        end
        else begin
            ipOnHitConst.Visible := false;
            BuildIPConst(ipconst, IPData^.Subtype);
            if ipconst.Visible then
                ipOnHitConst.ItemIndex := -1;
        end;
        BuildIPConst(secondparam, IPData^.Detail1);
        BuildIPConst(thirdparam,  IPData^.Detail2);

        // The spinner for some integer values:
        if IPData^.Low = IPData^.High then
            SpinPropAmount.Visible := false
        else begin
            // Only reset the value if this is a different range.
            // For present purposes, it is sufficient to check just
            // the high end of the range.
            if SpinPropAmount.MaxValue <> IPData^.High then begin
                SpinPropAmount.Value := 1;
                // Might as well slide this into the "if" statement.
                SpinPropAmount.MaxValue := IPData^.High;
            end;
            SpinPropAmount.MinValue := IPData^.Low;
            SpinPropAmount.Visible := true;
        end;

        // Set the "amount" label.
        if IPData^.ValLabel <> nil then
            LabelPropAmount.Caption := IPData^.ValLabel
        else
            LabelPropAmount.Caption := 'Amount:';

        // Visibility of labels:
        LabelPropSubtype.Visible := ipconst.Visible or ipOnHitConst.Visible;
        LabelPropDetails.Visible := secondparam.Visible or thirdparam.Visible;
        LabelPropAmount.Visible  := SpinPropAmount.Visible;

        // Show the "cast spell" help?
        bitbtn1.Visible :=  ItemPropArray[iprop.ItemIndex].Name = 'Cast Spell';
    end;//if IP_SEL_ADD

    // Update the "Okay" buttons.
    ToggleOkay(Sender);
end;


// Handles changes to the selction of what -- if anything -- is to be done with
// item properties.
procedure Titemscripting.RadioGroup6Click(Sender: TObject);
var
    iAction : integer;
begin
    iAction := radiogroup6.itemindex;

    // Show the appropriate duration selection.
    GroupDuration.Visible := iAction = IP_SEL_ADD;
    checkbox1.visible := (iAction = IP_SEL_REMOVE) or (iAction = IP_SEL_ALL);

    // Show the choice of property type.
    iprop.visible := (iAction = IP_SEL_ADD) or (iAction = IP_SEL_REMOVE);
    LabelPropType.Visible := iprop.visible;

    // Hide the parameters until a property type is chosen.
    ipOnHitConst.Visible   := false;
    ipconst.Visible        := false;
    secondparam.Visible    := false;
    thirdparam.Visible     := false;
    SpinPropAmount.Visible := false;
    // Hide labels too.
    LabelPropSubtype.Visible := false;
    LabelPropDetails.Visible := false;
    LabelPropAmount.Visible  := false;

    // Maybe a property type is left in the selection box?
    // (This also updates the "Okay" buttons.)
    ipropChange(Sender);
end;//ends function


// Enables/disables the "Okay" buttons as appropriate.
procedure Titemscripting.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // Tagged objects need a tag.
    if RadioTagged.Checked and (EditTagged.text = '') then
        bEnable := false
    else if RadioItemTagged.Checked and (EditItemTagged.text = '') then
        bEnable := false

    // Something must be selected to do.
    // (Indices are never negative, and if all are zero, nothing is selected.)
    else if radiogroup3.itemindex + radiogroup4.itemindex + radiogroup5.itemindex +
            GroupCursed.ItemIndex + radiogroup6.itemindex = 0 then
        bEnable := false

    // An item property type must be selected for addition and removal.
    else if iprop.Visible and (iprop.itemindex < 0) then
        bEnable := false
    // Id applicable, the parameters must also be supplied.
    else if ipconst.visible and (ipconst.itemindex < 0) then
        bEnable := false
    else if ipOnHitConst.visible and (ipOnHitConst.itemindex < 0) then
        bEnable := false
    else if secondparam.visible and (secondparam.itemindex < 0) then
        bEnable := false
    else if thirdparam.visible and (thirdparam.itemindex < 0) then
        bEnable := false

    // Else, passed all tests.
    else
        bEnable := true;

    // Update the "Okay" buttons.
    BitBtn2.Enabled := bEnable;
    BitBtn3.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------


// Clears the form so new info can be entered.
procedure Titemscripting.ClearForm();
begin
    // Reset the selections of what to do.
    radiogroup3.itemindex := 0;
    radiogroup4.itemindex := 0;
    radiogroup5.itemindex := 0;
    GroupCursed.ItemIndex := 0;
    radiogroup6.itemindex := 0;
end;


// Stores the information on the form for later submission to the script window.
procedure Titemscripting.QueueThis();
var
    owner_enum: TObjectEnum;
    item_owner: shortstring;
    the_item, item_desc: shortstring;
    list_length: integer;

    IPData: ^TItemPropData;
begin
    // Who owns the item?
    owner_enum := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                                  RadioTagged, RadioActor, RadioSpawn, FALSE);
    if owner_enum = E_CHOOSE_Tagged then
        item_owner := TAG_FLAG + QuoteSwap(EditTagged.Text)
    else
        item_owner := ObjectVar(owner_enum);

    // Which item?
    if RadioItemSlot.Checked then begin
        the_item := SymConst(INVENTORY_SLOT, ComboBox2.ItemIndex);
        item_desc := ConstInfo(INVENTORY_SLOT, ComboBox2.ItemIndex);
    end
    else if RadioItemScriptItem.Checked then begin
        the_item := TAGBASED;
        item_desc := 'the script''s item';
    end
    else begin // RadioItemTagged.Checked
        the_item := TAG_FLAG + QuoteSwap(EditItemTagged.Text);
        item_desc := EditItemName.Text;
        if item_desc = '' then
            item_desc := '"'+EditItemTagged.Text+'"';
    end;

    // --------
    // Send out a batch of NWScript if this is going to a new object.
    if (item_owner <> sPossessor) or (the_item <> sItem) then begin
        SendQueue();
        // Remember which item is current.
        sPossessor := item_owner;
        sItem := the_item;
        sName := item_desc;
        // Clear the stored information.
        flagPlot   := IP_SEL_NOTHING;
        flagStolen := IP_SEL_NOTHING;
        flagDrop   := IP_SEL_NOTHING;
        flagCursed := IP_SEL_NOTHING;
        SetLength(ListFlags, 0); // The other queues will be assumed the same length.
    end;

    // --------
    // Only record flag changes if a change is being made.
    if RadioGroup3.ItemIndex <> IP_SEL_NOTHING then  flagPlot   := RadioGroup3.ItemIndex;
    if RadioGroup4.ItemIndex <> IP_SEL_NOTHING then  flagStolen := RadioGroup4.ItemIndex;
    if RadioGroup5.ItemIndex <> IP_SEL_NOTHING then  flagDrop   := RadioGroup5.ItemIndex;
    if GroupCursed.ItemIndex <> IP_SEL_NOTHING then  flagCursed := GroupCursed.ItemIndex;

    // --------
    // Add item property handling to the queue?
    if RadioGroup6.ItemIndex <> IP_SEL_NOTHING then begin
        // Make space for recording the item property changes.
        list_length := Length(ListFlags);
        SetLength(ListFlags,     list_length+1);
        SetLength(ListTypes,     list_length+1);
        SetLength(ListSubtypes,  list_length+1);
        SetLength(ListDetails1,  list_length+1);
        SetLength(ListDetails2,  list_length+1);
        SetLength(ListAmounts,   list_length+1);
        SetLength(ListDurations, list_length+1);

        // Record the requested changes.
        ListFlags[list_length] := RadioGroup6.ItemIndex;
        ListTypes[list_length] := iprop.ItemIndex;  // ToggleOkay() ensures that this is not negative if it will be used.

        if CheckBox1.Visible then
            ListDurations[list_length] := LongWord(CheckBox1.Checked)
        else // either GroupDuration.Visible or this will be ignored
            if RadioPermanent.Checked then
                ListDurations[list_length] := 0
            else // RadioTemporary.Checked
                ListDurations[list_length] := SpinEdit1.Value;

        // Some fields are only meaningful if an item property is being added.
        if (radiogroup6.itemindex <> IP_SEL_ADD) or (iprop.ItemIndex < 0) then begin
            // Provide default values.
            ListSubtypes[list_length] := '';
            ListDetails1[list_length] := '';
            ListDetails2[list_length] := '';
            ListAmounts[list_length] := IP_AMOUNT_IGNORE;
        end
        else begin
            // For readability:
            IPData := @ItemPropArray[iprop.ItemIndex];

            // Subtype:
            if ipOnHitConst.Visible then
                ListSubtypes[list_length] := GetIPConst(IPData^.Subtype,
                                                        ipOnHitConst.ItemIndex)
            else
                ListSubtypes[list_length] := GetIPConst(IPData^.Subtype,
                                                        ipconst.ItemIndex);
            // Details:
            ListDetails1[list_length] := GetIPConst(IPData^.Detail1, secondparam.ItemIndex);
            ListDetails2[list_length] := GetIPConst(IPData^.Detail2, thirdparam.ItemIndex,
                                                    // Extra parameters in case this is IPC_SPECIAL:
                                                    iprop.ItemIndex, ipOnHitConst.ItemIndex);

            // Amount:
            if SpinPropAmount.Visible then
                ListAmounts[list_length] := SpinPropAmount.Value
            else
                ListAmounts[list_length] := IP_AMOUNT_IGNORE;
        end;
    end;//if RadioGroup6.ItemIndex <> IP_SEL_NOTHING
end;

procedure Titemscripting.SendQueue();
var
    owner, owner_tag: shortstring;
    owned_by, whom: shortstring;
    item_finder: shortstring;
    item_var, item_desc: shortstring;

    nProp, list_end: integer;

    start_line, last_line: integer;
    new_lines: array of shortstring;
begin
    list_end := Length(ListFlags) - 1;

    // Check for nothing to do.
    if (flagPlot = IP_SEL_NOTHING) and (flagStolen = IP_SEL_NOTHING) and
       (flagDrop = IP_SEL_NOTHING) and (flagCursed = IP_SEL_NOTHING) and
       (list_end < 0) then
        // Abort.
        exit;

    // Who owns the item?
    if not StartsWith(sPossessor, TAG_FLAG) then begin
        owner := sPossessor;
        owner_tag := '';
    end
    else begin
        owner := s_oTarget;
        owner_tag := copy(sPossessor, 1+Length(TAG_FLAG), 32);  // Max length of a tag is 32.
    end;
    // Make sure oSelf is defined, if needed.
    if owner = s_oSelf then
        Tlilac.Declare(VAR_oSELF);
    // Prepare text for the comment.
    if      owner = s_oSelf      then  whom := 'us'
    else if owner = s_oPC        then  whom := 'the PC'
    else if owner = s_oActivator then  whom := 'the item activator'
    else if owner = s_oActTarget then  whom := 'the activation target'
    else if owner = s_oSpawn     then  whom := 'the spawn'
    else if owner = s_oActor     then  whom := Tlilac.last_actor
    else                               whom := '"'+owner_tag+'"';

    // Which item?
    if sItem = TAGBASED then begin
        item_var  := s_oEventItem;
        item_desc := 'item that invoked this script'
    end
    else begin
        if not StartsWith(sItem, TAG_FLAG) then begin
            item_finder := Script.GetItemInSlot(sItem, owner);
            owned_by := ' equipped by ';
        end
        else begin
            item_finder := Script.GetItemPossessedBy(owner,
                                copy(sItem, 1+Length(TAG_FLAG), 32));   // Max length of a tag is 32.
            owned_by := ' possessed by ';
        end;
        item_var  := s_oItem;
        item_desc := sName+ owned_by +whom;
    end;

    // Allocate space (comment, oTarget defnition, oItem definition, four flags,
    // plus two lines per item property).
    SetLength(new_lines, 7 + 2*(1+list_end));

    // The opening comment.
    new_lines[0] := '// Alter the '+item_desc+'.';
    start_line := 1;

    if sItem <> TAGBASED then begin
        // Define oTarget?
        if owner = s_oTarget then begin
            new_lines[1] := s_oTarget+' = '+s_GetObject + owner_tag + '");';
            start_line := 2;
        end;

        // Define oItem.
        new_lines[start_line] := s_oItem+' = '+item_finder+';';
        Inc(start_line);
    end;
    last_line := start_line - 1;

    // Set the plot flag.
    if flagPlot <> IP_SEL_NOTHING then begin
        Inc(last_line);
        new_lines[last_line] := 'SetPlotFlag('+item_var +
                                BoolToStr(flagPlot = IP_SEL_ADD, s_comma_TRUE, s_comma_FALSE)+
                                ');';
    end;

    // Set the stolen flag.
    if flagStolen <> IP_SEL_NOTHING then begin
        Inc(last_line);
        new_lines[last_line] := 'SetStolenFlag('+item_var +
                                BoolToStr(flagStolen = IP_SEL_ADD, s_comma_TRUE, s_comma_FALSE)+
                                ');';
    end;

    // Set the droppable flag.
    if flagDrop <> IP_SEL_NOTHING then begin
        Inc(last_line);
        new_lines[last_line] := 'SetDroppableFlag('+item_var +
                                BoolToStr(flagDrop = IP_SEL_ADD, s_comma_TRUE, s_comma_FALSE)+
                                ');';
    end;

    // Set the cursed flag.
    if flagCursed <> IP_SEL_NOTHING then begin
        Inc(last_line);
        new_lines[last_line] := 'SetItemCursedFlag('+item_var +
                                BoolToStr(flagCursed = IP_SEL_ADD, s_comma_TRUE, s_comma_FALSE)+
                                ');';
    end;

    // Loop through the item properties to change.
    for nProp := 0 to list_end do
        PropsToLines(nProp, item_var, last_line, new_lines);

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], start_line, last_line, true);
end;


// Adds the lines to new_lines (and updates last_line) for the nProp-th entry
// in the queue.
procedure Titemscripting.PropsToLines(nProp:integer; const item_var: shortstring;
                                      var last_line:integer; var new_lines:TStringAry);
begin
    case ListFlags[nProp] of
        IP_SEL_ADD: begin
            // Need x2_inc_itemprop for IPSafeAddItemProperty().
            Tlilac.Include(INC_ITEMPROP);

            // Define the new property.
            Inc(last_line);
            new_lines[last_line] :=
                s_ipAdd+' = '+NameToCommand('ItemProperty',
                                            ItemPropArray[ListTypes[nProp]].Name)+
                              '(';
            // Plus the parameters. They will be in order, but some might be
            // skipped, so we need conditionals for when the commas are added.
            new_lines[last_line] += ListSubtypes[nProp];
            if (ListDetails1[nProp] <> '') and (LastChar(new_lines[last_line]) <> '(') then
                new_lines[last_line] += ', ';
            new_lines[last_line] += ListDetails1[nProp];
            if (ListDetails2[nProp] <> '') and (LastChar(new_lines[last_line]) <> '(') then
                new_lines[last_line] += ', ';
            new_lines[last_line] += ListDetails2[nProp];
            // End the function call.
            new_lines[last_line] += ');';

            // Add the property.
            Inc(last_line);
            new_lines[last_line] := 'IPSafeAddItemProperty('+item_var+', '+s_ipAdd;
            // Make this temporary?
            if ListDurations[nProp] > 0 then
                new_lines[last_line] += ', '+IntToStr(ListDurations[nProp])+'.0';
            new_lines[last_line] += ');';
        end;

        IP_SEL_REMOVE: begin
            // Need x2_inc_itemprop for IPRemoveMatchingItemProperties().
            Tlilac.Include(INC_ITEMPROP);

            // Remove matching properties.
            Inc(last_line);
            new_lines[last_line] := 'IPRemoveMatchingItemProperties('+item_var+', '+
                                    SymConst(ITEM_PROPERTY, ListTypes[nProp]);
            // Default is only temporary; need to flag all if that was requested.
            if not Boolean(ListDurations[nProp]) then
                new_lines[last_line] += ', -1';
            new_lines[last_line] += ');';
        end;

        IP_SEL_ALL: begin
            // Need x2_inc_itemprop for IPRemoveAllItemProperties().
            Tlilac.Include(INC_ITEMPROP);

            // Remove temporary properties.
            Inc(last_line);
            new_lines[last_line] :=
                'IPRemoveAllItemProperties('+item_var+', DURATION_TYPE_TEMPORARY);';

            // Remove permanent properties?
            if not Boolean(ListDurations[nProp]) then begin
                Inc(last_line);
                new_lines[last_line] :=
                    'IPRemoveAllItemProperties('+item_var+', DURATION_TYPE_PERMANENT);';
            end;
        end;
    end;//case
end;


initialization
  {$i itemscript.lrs}
end.
