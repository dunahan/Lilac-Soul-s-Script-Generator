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
* Much of this was trimmed when I converted the form to being modal (but then
*   a chunk got transferred from Tlilac).
* Removed the "damage power" radio group as that setting does nothing in-game.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit damage_pc;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, ExtCtrls, Spin, Buttons, nwn,
  LResources, ExtForm;

type

  { Tdamagepc }

  Tdamagepc = class(TExtForm)
    // Form elements.
    CheckOwner: TCheckBox;
    CheckSpawn: TCheckBox;
    CheckActor: TCheckBox;
    GroupAmount: TGroupBox;
    GroupTarget: TGroupBox;
    CheckPC: TCheckBox;
    LabelVFX: TLabel;
    PanelDamageOrigin: TPanel;
    pctarget: TCheckBox;
    pcuser: TCheckBox;
    RadioGroup1: TRadioGroup;
    ComboBox1: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    RadioGroupDice: TRadioGroup;
    SpinEdit1: TSpinEdit;
    EditTagged: TEdit;
    CheckTagged: TCheckBox;
    // Event handlers.
    procedure FormCreate(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure Button1Click(Sender: TObject);

  private
    // Private methods.
    procedure DoDamage(const towhom: shortstring; bVFX: boolean;
                       var new_lines: TStringAry; var last_line: integer);
  end;


implementation

uses {event, black_smith,}
     start, constants;

const
    OBJECT_TYPE_DAMAGEABLE = OBJECT_TYPE_CREATURE or OBJECT_TYPE_DOOR or
                             OBJECT_TYPE_PLACEABLE;


// -----------------------------------------------------------------------------

// Configures the form based on the current situation.
procedure Tdamagepc.FormCreate(Sender: TObject);
begin
    // Load the list of visual effects.
    LoadConstants(combobox1.Items, VFX_IMPACT);
    ComboBox1.ItemIndex := 0;

    // Initialize check buttons.
    main.InitRadioWhos(CheckOwner, CheckSpawn, CheckActor, OBJECT_TYPE_DAMAGEABLE);
    main.InitActivationRadios(CheckOwner, CheckPC, pcuser, pctarget, OBJECT_TYPE_DAMAGEABLE);
end;


// Enables/disables the "Okay" button as appropriate.
procedure Tdamagepc.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // If selecting a creature by tag, the tag must be provided.
    if CheckTagged.Checked then
        bEnable := EditTagged.Text <> ''

    // Otherwise, we're OK as long as something is picked as the target.
    else
        bEnable := CheckOwner.Checked or CheckPC.Checked    or pctarget.Checked or
                   CheckSpawn.Checked or CheckActor.Checked or pcuser.Checked;

    // Update the "Okay" button.
    BitBtn1.Enabled := bEnable;
end;


// Handles clicks of the "Okay" button.
procedure Tdamagepc.Button1Click(Sender: TObject);
var
    bVFX: boolean;
    sDamage: shortstring;

    start_line, last_line: integer;
    new_lines: array of shortstring;
begin
    bVFX := combobox1.itemindex > 0;
    SetLength(new_lines, 4 + 2*7);  // Possibly 4 header lines, plus up to 2 per check box.
                                    // (Using a variable length array so I can use it as a TStringAry parameter.)

    // Construct a string describing how much damage will be inflicted.
    // Note: If dice are specified, we will roll the damage once for all targets.
    //       This allows the most flexibility, as the user still has the option
    //       of using this form once per target, which would cause damage to be
    //       rolled separately for each target.
    sDamage := inttostr(spinedit1.value);
    // Need more text if dice are to be rolled.
    if RadioGroupDice.ItemIndex > 0 then begin
        // Wrap the number of dice in parentheses.
        if sDamage = '1' then
            sDamage := '()'
        else
            sDamage := '('+sDamage+')';
        // Add the die-rolling command.
        case RadioGroupDice.ItemIndex of
            1:  sDamage := 'd2'   + sDamage;
            2:  sDamage := 'd3'   + sDamage;
            3:  sDamage := 'd4'   + sDamage;
            4:  sDamage := 'd6'   + sDamage;
            5:  sDamage := 'd8'   + sDamage;
            6:  sDamage := 'd10'  + sDamage;
            7:  sDamage := 'd12'  + sDamage;
            8:  sDamage := 'd20'  + sDamage;
            9:  sDamage := 'd100' + sDamage;
        end;
    end;

    // The comment line and defining the damage effect.
    new_lines[0] := '// Cause damage.';
    new_lines[1] := s_eDamage+' = EffectDamage('+sDamage+', '+
                    NameToConstant('DAMAGE_TYPE', radiogroup1.items[radiogroup1.itemindex])+');';
    start_line := 2;

    // Will we need a visual effect?
    if bVFX then begin
        new_lines[start_line] := s_eVFX+' = '+s_EffectVisual +
                                 SymConst(VFX_IMPACT, combobox1.itemindex)+');';
        Inc(start_line);
    end;

    // Will we need to define oTarget?
    if CheckTagged.Checked then begin
        new_lines[start_line] :=
                s_oTarget+' = '+s_GetObject + QuoteSwap(EditTagged.text)+'");';
        Inc(start_line);
    end;

    // Switching from tracking the starting line to tracking the last line.
    last_line := start_line-1;

    // See who (possibly multiple targets) gets damaged.
    if CheckPC.Checked     then  DoDamage(s_oPC,        bVFX, new_lines, last_line);
    if pctarget.Checked    then  DoDamage(s_oActTarget, bVFX, new_lines, last_line);
    if pcuser.Checked      then  DoDamage(s_oActivator, bVFX, new_lines, last_line);
    if CheckSpawn.Checked  then  DoDamage(s_oSpawn,     bVFX, new_lines, last_line);
    if CheckTagged.Checked then  DoDamage(s_oTarget,    bVFX, new_lines, last_line);
    if CheckActor.Checked  then  DoDamage(s_oActor,     bVFX, new_lines, last_line);
    if CheckOwner.Checked  then begin
        Tlilac.Declare(VAR_oSELF);
        DoDamage(s_oSelf, bVFX, new_lines, last_line);
    end;

    // Send these lines to the script window.
    Tlilac.AddLines(new_lines[0..last_line], start_line, last_line);
end;


// Adds the NWScript lines to damage a specific someone.
procedure Tdamagepc.DoDamage(const towhom: shortstring; bVFX: boolean;
                             var new_lines: TStringAry; var last_line: integer);
begin
    // Apply a damage effect.
    Inc(last_line);
    new_lines[last_line] := Script.ApplyEffect(s_eDamage, towhom, false);

    // Apply a visual effect?
    if bVFX then begin
        Inc(last_line);
        new_lines[last_line] := Script.ApplyEffect(s_eVFX+'   ', towhom, false);
    end;
end;


initialization
  {$i damage_pc.lrs}
end.
