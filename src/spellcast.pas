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
* Some of this was trimmed when I converted the form to being modal (and when I
*   converted simulated radio buttons into actual radio buttons).
* Removed link to Lexicon's list of spell constants. (Of what use was it?)
* Added options for caster and target.
* Redid the list of spell constants.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit spellcast;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, {Spin,} start, nwn, Buttons, {ExtCtrls,}
  LResources, {shellAPI,} ExtForm, Classes;

type

  { Tcastspell }

  Tcastspell = class(TExtForm)
      // Form elements
      BitBtn3: TBitBtn;
      cheat: TCheckBox;
      CheckBox1: TCheckBox;
      CheckCasterNearest: TCheckBox;
      CheckLocation: TCheckBox;
      EditCasterName: TEdit;
      GroupTarget: TGroupBox;
      GroupSpell: TGroupBox;
      GroupCaster: TGroupBox;
      instantspell: TCheckBox;
      LabelNearestExplain1: TLabel;
      LabelNearestExplain2: TLabel;
      LabelLocation: TLabel;
      LabelCasterName: TLabel;
      RadioCasterActivator: TRadioButton;
      RadioSpells: TRadioButton;
      RadioSpellAbilities: TRadioButton;
      RadioTargetOwner: TRadioButton;
      RadioCasterOwner: TRadioButton;
      RadioCasterPC: TRadioButton;
      RadioCasterSpawn: TRadioButton;
      RadioCasterTagged: TRadioButton;
      RadioCasterTargeted: TRadioButton;
      RadioTargetCaster: TRadioButton;
      RadioTargetPC: TRadioButton;
      RadioTargetTagged: TRadioButton;
      RadioTargetSpawn: TRadioButton;
      RadioTargetTargeted: TRadioButton;
      RadioTargetActivator: TRadioButton;
      RadioTargetTargetLoc: TRadioButton;
      Spells: TComboBox;
      SpellAbilities: TComboBox;
      EditCasterTagged: TEdit;
      EditTargetTagged: TEdit;
      BitBtn1: TBitBtn;
      BitBtn2: TBitBtn;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure RadioTargetTargetLocChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure CheckBox1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  end;


// -----------------------------------------------------------------------------
implementation

uses {event,} fakespell, constants;

const
    OBJECT_CREATURE_PLACEABLE = OBJECT_TYPE_CREATURE or OBJECT_TYPE_PLACEABLE;


// Configures the form for the current situation.
procedure Tcastspell.FormCreate(Sender: TObject);
begin
    // Load up the list of spells.
    LoadConstants(Spells.Items, SPELL);
    LoadConstants(SpellAbilities.Items, SPELLABILITY);

    // Initialize radio buttons.
    main.InitRadioWhos(RadioCasterOwner, RadioCasterSpawn, nil, OBJECT_CREATURE_PLACEABLE);
    main.InitRadioWhos(RadioTargetOwner, RadioTargetSpawn, nil, OBJECT_TYPE_IN_AREA or OBJECT_TYPE_ITEM);
    main.InitActivationRadios(RadioCasterOwner,     RadioCasterPC,
                              RadioCasterActivator, RadioCasterTargeted,
                              OBJECT_CREATURE_PLACEABLE);
    main.InitActivationRadios(RadioTargetOwner,     RadioTargetPC,
                              RadioTargetActivator, RadioTargetTargeted,
                              OBJECT_TYPE_IN_AREA or OBJECT_TYPE_ITEM,
                              RadioTargetTargetLoc);
    // Check for having hidden the current selection.
    if RadioCasterOwner.Checked and not RadioCasterOwner.Visible then
        RadioCasterTagged.Checked := true;

    // Possibly default to the last actor.
    EditCasterTagged.Text := Tlilac.last_actor;
end;


// Handles changes to the "activation target location" radio button.
procedure Tcastspell.RadioTargetTargetLocChange(Sender: TObject);
begin
    // The target location is necessarily a location.
    if not RadioTargetTargetLoc.Checked then
        CheckLocation.Enabled := TRUE
    else begin
        CheckLocation.Checked := TRUE;
        CheckLocation.Enabled := FALSE;
    end;
end;


// Enables/disables the "Okay" buttons as appropriate.
procedure Tcastspell.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // Caster tag must be entered if that option is selected.
    if RadioCasterTagged.Checked and (EditCasterTagged.Text = '') then
        bEnable := false
    // Similarly for target tag.
    else if RadioTargetTagged.Checked and (EditTargetTagged.Text = '') then
        bEnable := false
    // In addition, a spell must be selected.
    else if RadioSpells.Checked then
        bEnable := Spells.ItemIndex > -1
    else
        bEnable := SpellAbilities.ItemIndex > -1;

    // Enable/disable the okay button.
    BitBtn1.Enabled := bEnable;
end;


// Handles clicks to the "cast fake spell" check box.
procedure Tcastspell.CheckBox1Click(Sender: TObject);
begin
    // Fake spells cannot be instant, and they are always cheats.
    instantspell.enabled := not checkbox1.checked;
    cheat.enabled        := not checkbox1.checked;
end;


// Opens the window explaining what a fake spell is.
procedure Tcastspell.BitBtn3Click(Sender: TObject);
begin
    main.ShowPopup(Tfakespelldoc);
end;


// Submits the specified action to the script window.
procedure Tcastspell.Button1Click(Sender: TObject);
var
    target, caster: TObjectEnum;
    target_var, caster_var, caster_desc: shortstring;
    spell_constant, spell_name: shortstring;
    fake, fake_cast: shortstring;

    start_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // Who will be casting this spell?
    caster := GetChosenObject(RadioCasterOwner, RadioCasterPC, RadioCasterActivator,
                              RadioCasterTargeted, nil, RadioCasterTagged,
                              RadioCasterSpawn);
    caster_var := ObjectVar(caster);
    if (caster = E_CHOOSE_Actor)  and  (EditCasterName.Text <> '') then
        caster_desc := EditCasterName.Text
    else
        caster_desc := ObjectDesc(caster, '');

    // Who will be the target?
    if RadioTargetTargetLoc.Checked then
        target_var := s_lActTarget
    else begin
        target := GetChosenObject(RadioTargetOwner, RadioTargetPC, RadioTargetActivator,
                                  RadioTargetTargeted, RadioTargetTagged, nil,
                                  RadioTargetSpawn, FALSE);
        target_var := ObjectVar(target, caster_var, CheckLocation.checked);
    end;

    // React to some special cases.
    if (caster = E_CHOOSE_Self)  or  (target = E_CHOOSE_Self) then
        Tlilac.Declare(VAR_oSELF);
    if caster = E_CHOOSE_Actor then
        Tlilac.last_actor := EditCasterTagged.Text;


    // Which spell?
    if RadioSpells.Checked then begin
        spell_constant := SymConst(SPELL, Spells.ItemIndex);
        spell_name := Spells.Text;
    end
    else begin
        spell_constant := SymConst(SPELLABILITY, SpellAbilities.ItemIndex);
        spell_name := SpellAbilities.Text;
    end;

    // Fake cast?
    if checkbox1.checked then
        begin fake := 'Fake';   fake_cast := ' fake-cast '; end
    else
        begin fake := '';       fake_cast := ' cast ';      end;


    // -------------
    // The opening comment.
    new_lines[0] := '// Have '+caster_desc + fake_cast + spell_name+'.';
    start_line := 1;

    // Possible definition of oActor.
    if caster = E_CHOOSE_Actor then begin
        new_lines[start_line] := s_oActor+' = ' +
                                    BoolToStr(CheckCasterNearest.Checked,
                                               s_GetNearest, s_GetObject) +
                                    QuoteSwap(EditCasterTagged.text)+'");';
        start_line += 1;
    end;

    // Possible definition of oTarget.
    if target = E_CHOOSE_Tagged then begin
        new_lines[start_line] := s_oTarget+' = '+
                                 s_GetNearest + QuoteSwap(EditTargetTagged.Text)+'", '+
                                                caster_var+');';
        start_line += 1;
    end;

    // The instruction to cast the spell.
    new_lines[start_line] := 'ActionCast'+fake+'SpellAt'+
                             BoolToStr(CheckLocation.checked, 'Location', 'Object')+
                             '('+spell_constant+', '+target_var;
    // non-fake spells might get additional parameters.
    if not checkbox1.checked then begin
        if instantspell.checked or cheat.checked then
            new_lines[start_line] += ', METAMAGIC_ANY, '+ BoolToStr(cheat.checked, s_TRUE, s_FALSE);
        if instantspell.checked then
            new_lines[start_line] += BoolToStr(CheckLocation.checked, '', ', 0')+
                                     ', PROJECTILE_PATH_TYPE_DEFAULT, TRUE';
    end;
    // End the function call.
    new_lines[start_line] += ')';

    // Make sure the correct object casts the spell.
    if caster <> E_CHOOSE_Owner then
        new_lines[start_line] := s_AssignCommand + caster_var+', '+new_lines[start_line]+')';
    // Terminal semicolon.
    new_lines[start_line] += ';';

    // Add these lines.
    Tlilac.AddLines(new_lines[0..start_line], start_line, start_line);
end;


initialization
  {$i spellcast.lrs}
end.
