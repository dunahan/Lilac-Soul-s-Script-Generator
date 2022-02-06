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
* Re-organization of the form, with several options added.
* Merged the level_up form into this one.
* Cleanup of the generated scripts, including support for multiple henchmen.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit companions;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, Buttons, ExtCtrls, Spin,
  LResources, ExtForm, Classes;

type

  { Tcompanion }

  Tcompanion = class(TExtForm)
      BevelFakePanel: TBevel;
      BoxClassLevelup: TComboBox;
      BoxPackageLevelup: TComboBox;
      CheckAddHenchman: TCheckBox;
      CheckDominate: TCheckBox;
      CheckLevelup: TCheckBox;
      CheckReleasePaladinMount: TCheckBox;
      CheckRecordPaladinMount: TCheckBox;
      CheckSpellsLevelup: TCheckBox;
      EditAddHenchTagged: TEdit;
      EditDominateTagged: TEdit;
      EditLevelTagged: TEdit;
      EditMasterTagged: TEdit;
      GroupAddHenchman: TGroupBox;
      GroupDominate: TGroupBox;
      GroupDurationDominate: TRadioGroup;
      GroupHowMuchLevelup: TRadioGroup;
      GroupMaster: TGroupBox;
      GroupWhoLevelup: TGroupBox;
      LabelClassLevelup: TLabel;
      LabelPackageLevelup: TLabel;
      LabelResRefSummon: TLabel;
      nuke: TButton;
    ButtonPalette: TBitBtn;
    BoxVFXSummon: TComboBox;
    destroyanimal: TCheckBox;
    CheckDestroyReleaseDominated: TCheckBox;
    destroyfamiliar: TCheckBox;
    CheckDestroyRemHenchman: TCheckBox;
    EditRemHenchTagged: TEdit;
    GroupDurationSummon: TRadioGroup;
    GroupRemHenchman: TGroupBox;
    LabelVFXSummon: TLabel;
    PanelRightExisting: TPanel;
    PanelMaster: TPanel;
    PanelLeftExisting: TPanel;
    PanelLeftNew: TPanel;
    PanelRightNew: TPanel;
    RadioAddHenchActor: TRadioButton;
    RadioAddHenchOwner: TRadioButton;
    RadioAddHenchSpawn: TRadioButton;
    RadioAddHenchTagged: TRadioButton;
    RadioAddHenchTargeted: TRadioButton;
    RadioDominateActor: TRadioButton;
    RadioDominateOwner: TRadioButton;
    RadioDominateSpawn: TRadioButton;
    RadioDominateTagged: TRadioButton;
    RadioDominateTargeted: TRadioButton;
    RadioLevelActor: TRadioButton;
    RadioLevelAll: TRadioButton;
    RadioLevelOwner: TRadioButton;
    RadioLevelSpawn: TRadioButton;
    RadioLevelTagged: TRadioButton;
    RadioLevelTargeted: TRadioButton;
    RadioMasterActivator: TRadioButton;
    RadioMasterActor: TRadioButton;
    RadioMasterOwner: TRadioButton;
    RadioMasterPC: TRadioButton;
    RadioMasterSpawn: TRadioButton;
    RadioMasterTagged: TRadioButton;
    RadioMasterTargeted: TRadioButton;
    RadioRemHenchAll: TRadioButton;
    RadioRemHenchActor: TRadioButton;
    RadioRemHenchOwner: TRadioButton;
    RadioRemHenchSpawn: TRadioButton;
    RadioRemHenchTagged: TRadioButton;
    RadioRemHenchTargeted: TRadioButton;
    RadioNew: TRadioButton;
    RadioExisting: TRadioButton;
    CheckReleaseDominated: TCheckBox;
    releasesummoned: TCheckBox;
    CheckRemHenchman: TCheckBox;
    ShapeFakePanel: TShape;
    SpinAbsoluteLevel: TSpinEdit;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    CheckSummonPaladinMount: TCheckBox;
    SpinRelativeLevel: TSpinEdit;
    summonanimal: TCheckBox;
    CheckSummon: TCheckBox;
    summonfamiliar: TCheckBox;
    EditSummon: TEdit;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    TextLevelupNote: TStaticText;
    unpossess: TCheckBox;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure BoxClassLevelupChange(Sender: TObject);
    procedure ButtonPaletteClick(Sender: TObject);
    procedure CheckSummonPaladinMountChange(Sender: TObject);
    procedure destroyfamiliarChange(Sender: TObject);
    procedure unpossessChange(Sender: TObject);
    procedure nukeClick(Sender: TObject);
    procedure RadioMasterActorChange(Sender: TObject);
    procedure RadioMasterOwnerChange(Sender: TObject);
    procedure RadioMasterSpawnChange(Sender: TObject);
    procedure RadioMasterTargetedChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure BitBtn2Click(Sender: TObject);

  private
    // Helper methods
    procedure AddHenchman(const master_var, master_desc, master_def: shortstring);
    procedure CallAnimal(const master_var, master_desc, master_def: shortstring);
    procedure CallFamiliar(const master_var, master_desc, master_def: shortstring);
    procedure CallPaladinMount(const master_var, master_desc, master_def: shortstring);
    procedure DoDominate(const master_var, master_desc, master_def: shortstring);
    procedure DoSummon(const master_var, master_desc, master_def: shortstring);

    procedure LevelCreature(const master_var, master_desc, master_def: shortstring);
    procedure ReleaseAssociate(const assoc_type, assoc_desc: shortstring;
                               const master_var, master_desc, master_def: shortstring);
    procedure ReleaseDominated(const master_var, master_desc, master_def: shortstring);
    procedure ReleaseHenchman(const master_var, master_desc, master_def: shortstring);
    procedure ReleasePaladinMount(const master_var, master_desc, master_def: shortstring);
    procedure StopPossession(const master_var, master_desc, master_def: shortstring);
  end;


implementation

uses {event,} start, nwn, {level_up,} {black_smith,}
     constants, palettetool;


// -----------------------------------------------------------------------------
// Private utilities


// Adds scripting lines that start a loop through all henchmen to new_lines.
// This requires 4 lines.
procedure StartHenchLoop(const master_var: shortstring;
                         var last_line: integer; var new_lines: array of shortstring);
begin
    Inc(last_line);
    new_lines[last_line] := s_nHench+' = 1;';
    Inc(last_line);
    new_lines[last_line] := s_oHench+' = GetHenchman('+master_var+', 1);';
    Inc(last_line);
    new_lines[last_line] := 'while ( '+s_oHench+' != '+s_OBJECT_INVALID+' )';
    Inc(last_line);
    new_lines[last_line] := '{';
end;


// Adds scripting lines that end a loop through all henchmen to new_lines.
// This requires 4 lines.
procedure EndHenchLoop(const master_var: shortstring;
                       var last_line: integer; var new_lines: array of shortstring);
begin
    Inc(last_line);
    new_lines[last_line] := '';
    Inc(last_line);
    new_lines[last_line] := '    // Update the loop.';
    Inc(last_line);
    new_lines[last_line] := '    '+s_oHench+' = GetHenchman('+master_var+', ++'+s_nHench+');';
    Inc(last_line);
    new_lines[last_line] := '}';
end;


// -----------------------------------------------------------------------------
// Event handlers


// Initializes the form based on current circumstances.
procedure Tcompanion.FormCreate(Sender: TObject);
begin
    // Load the visual effects.
    LoadConstants(BoxVFXSummon.Items, VFX_IMPACT);
    BoxVFXSummon.ItemIndex := 0;

    // Initialize radio buttons.
    main.InitRadioWhos(RadioMasterOwner,   RadioMasterSpawn,   RadioMasterActor,   OBJECT_TYPE_CREATURE);
    main.InitRadioWhos(RadioAddHenchOwner, RadioAddHenchSpawn, RadioAddHenchActor, OBJECT_TYPE_CREATURE);
    main.InitRadioWhos(RadioDominateOwner, RadioDominateSpawn, RadioDominateActor, OBJECT_TYPE_CREATURE);
    main.InitRadioWhos(RadioRemHenchOwner, RadioRemHenchSpawn, RadioRemHenchActor, OBJECT_TYPE_CREATURE);
    main.InitRadioWhos(RadioLevelOwner,    RadioLevelSpawn,    RadioLevelActor,    OBJECT_TYPE_CREATURE);

    main.InitActivationRadios(RadioMasterPC, RadioMasterOwner, RadioMasterActivator, RadioMasterTargeted, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(nil, RadioAddHenchOwner, nil, RadioAddHenchTargeted, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(nil, RadioDominateOwner, nil, RadioDominateTargeted, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(nil, RadioRemHenchOwner, nil, RadioRemHenchTargeted, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(nil, RadioLevelOwner,    nil, RadioLevelTargeted,    OBJECT_TYPE_CREATURE);

    // Make sure the selections are defaulted to something that is visible.
    with RadioAddHenchOwner do
        if Checked and not Visible then
            RadioAddHenchTagged.Checked := TRUE;
    with RadioDominateOwner do
        if Checked and not Visible then
            RadioDominateTagged.Checked := TRUE;

    // Don't offer to save something that cannot be saved.
    CheckRecordPaladinMount.Visible := RadioMasterOwner.Visible  and
                                       not Tlilac.MustReturnVoid();
end;


// Updates the available packages when a new class is selected.
procedure Tcompanion.BoxClassLevelupChange(Sender: TObject);
var
    iClass:    integer;
    iLastPack: integer;
begin
    // For brevity:
    iClass := BoxClassLevelup.ItemIndex;

    // Now shift focus to the package TComboBox.
    with BoxPackageLevelup do begin
        // Being a little fancy with the initial selection here.
        iLastPack := ItemIndex;

        // Replace the existing contents with the packages for this class (if any).
        if ( iClass < Low(PACKAGES)) or (High(PACKAGES) < iClass) then
            Items.Clear()
        else begin
            LoadConstants(Items, PACKAGES[iClass]);
            // Trim off the blanks at the end (possibly everything).
            if Items[0] = '' then
                Items.Clear()
            else
                while Items[Items.Count-1] = '' do
                    Items.Delete(Items.Count-1);
        end;

        // Load in the default selection.
        Items.Insert(0, 'Preselected package');

        // Select something.
        if iLastPack < Items.Count then
            ItemIndex := iLastPack
        else
            ItemIndex := Items.Count - 1;
    end;
end;


// Handles clicks of the "Palette" button.
procedure Tcompanion.ButtonPaletteClick(Sender: TObject);
begin
    TPaletteWindow.Load(EditSummon, nil, SEARCH_CREATURES, true);
end;


// Controls the enabled state of the checkbox offering to remember the paladin mount.
procedure Tcompanion.CheckSummonPaladinMountChange(Sender: TObject);
begin
    // We can only record OBJECT_SELF's summoned mount.
    CheckRecordPaladinMount.Enabled := CheckSummonPaladinMount.Checked and
                                       RadioMasterOwner.Checked;
end;


// Makes sure that a familiar will be unpossessed before being destroyed.
procedure Tcompanion.destroyfamiliarChange(Sender: TObject);
begin
    if destroyfamiliar.checked then
        unpossess.checked := true;
    ToggleOkay(Sender);
end;


// Makes sure that a familiar will not be destroyed if not unpossessed first.
procedure Tcompanion.unpossessChange(Sender: TObject);
begin
    if not unpossess.checked then
        destroyfamiliar.checked := false;
    ToggleOkay(Sender);
end;


// Causes all associates to be released.
procedure Tcompanion.nukeClick(Sender: TObject);
begin
    destroyanimal.checked := true;
    destroyfamiliar.checked := true;
    CheckReleasePaladinMount.Checked := true;
    releasesummoned.checked := true;
    CheckReleaseDominated.checked := true;
    CheckRemHenchman.checked := true;
    RadioRemHenchAll.checked := true;
end;


// Disable the associate selections they would be the master.
procedure Tcompanion.RadioMasterActorChange(Sender: TObject);
var
    bDisable: boolean;
begin
    bDisable := RadioMasterActor.Checked;

    // The associate selections corresponding to the last actor:
    DisableAndUnselect(RadioAddHenchActor, bDisable, RadioAddHenchTagged);
    DisableAndUnselect(RadioDominateActor, bDisable, RadioDominateTagged);
    DisableAndUnselect(RadioRemHenchActor, bDisable, RadioRemHenchTagged);
    // Omitting RadioLevel* as that can be used for non-henchmen by design.
end;


// Disable the associate selections they would be the master.
procedure Tcompanion.RadioMasterOwnerChange(Sender: TObject);
var
    bDisable: boolean;
begin
    bDisable := RadioMasterOwner.Checked;

    // The associate selections corresponding to the script owner:
    DisableAndUnselect(RadioAddHenchOwner, bDisable, RadioAddHenchTagged);
    DisableAndUnselect(RadioDominateOwner, bDisable, RadioDominateTagged);
    DisableAndUnselect(RadioRemHenchOwner, bDisable, RadioRemHenchTagged);
    // Omitting RadioLevel* as that can be used for non-henchmen by design.

    // We can only record OBJECT_SELF's summoned mount.
    CheckRecordPaladinMount.Enabled := CheckSummonPaladinMount.Checked and
                                       RadioMasterOwner.Checked;
end;


// Disable the associate selections they would be the master.
procedure Tcompanion.RadioMasterSpawnChange(Sender: TObject);
var
    bDisable: boolean;
begin
    bDisable := RadioMasterSpawn.Checked;

    // The associate selections corresponding to the last spawn:
    DisableAndUnselect(RadioAddHenchSpawn, bDisable, RadioAddHenchTagged);
    DisableAndUnselect(RadioDominateSpawn, bDisable, RadioDominateTagged);
    DisableAndUnselect(RadioRemHenchSpawn, bDisable, RadioRemHenchTagged);
    // Omitting RadioLevel* as that can be used for non-henchmen by design.
end;


// Disable the associate selections they would be the master.
procedure Tcompanion.RadioMasterTargetedChange(Sender: TObject);
var
    bDisable: boolean;
begin
    bDisable := RadioMasterTargeted.Checked;

    // The associate selections corresponding to the activation target:
    DisableAndUnselect(RadioAddHenchTargeted, bDisable, RadioAddHenchTagged);
    DisableAndUnselect(RadioDominateTargeted, bDisable, RadioDominateTagged);
    DisableAndUnselect(RadioRemHenchTargeted, bDisable, RadioRemHenchTagged);
    // Omitting RadioLevel* as that can be used for non-henchmen by design.
end;


// Keeps the "Okay" button enabled when (and only when) appropriate.
// (LS had most of this in a function called "Insufficient()".)
// Also has a small hack to keep PanelMaster visible.
procedure Tcompanion.ToggleOkay(Sender: TObject);
var
    bEnable: boolean = true;
begin
    // Tagged masters must have a tag.
    if RadioMasterTagged.Checked and (EditMasterTagged.Text = '') then
        bEnable := false

    // The remaining conditions depend upon which panel is visible.
    else if RadioNew.Checked then begin
        // Need something to do.
        if not ( CheckAddHenchman.checked or CheckDominate.checked  or
                 summonanimal.checked     or summonfamiliar.checked or
                 CheckSummon.checked      or CheckSummonPaladinMount.Checked ) then
            bEnable := false

        // Tagged targets need tags.
        else if CheckAddHenchman.Checked and RadioAddHenchTagged.Checked and
                (EditAddHenchTagged.text = '') then
            bEnable := false
        else if CheckDominate.checked and RadioDominateTagged.Checked and
                (EditDominateTagged.text = '') then
            bEnable := false
        else if CheckSummon.checked and (EditSummon.text = '') then
            bEnable := false;
    end

    // RadioExisting.Checked:
    else begin
        // Need something to do.
        if not ( destroyanimal.checked    or destroyfamiliar.checked       or
                 releasesummoned.checked  or CheckReleaseDominated.checked or
                 CheckRemHenchman.checked or unpossess.checked             or
                 CheckLevelup.Checked     or CheckReleasePaladinMount.Checked ) then
            bEnable := false

        // Tagged targets need tags.
        else if CheckRemHenchman.Checked and RadioRemHenchTagged.checked and
                (EditRemHenchTagged.text = '') then
            bEnable := false
        else if CheckLevelup.Checked and RadioLevelTagged.Checked and
                (EditLevelTagged.text = '') then
            bEnable := false;
    end;

    // Update the "Okay" button.
    BitBtn2.Enabled := bEnable;
end;


// Adds the requested scripting lines to the script window.
procedure Tcompanion.BitBtn2Click(Sender: TObject);
var
    master_obj:  TObjectEnum;
    master_var:  shortstring;
    master_desc: shortstring;
    master_def:  shortstring;
begin
    // Determine the master to use.
    master_obj := GetChosenObject(RadioMasterOwner, RadioMasterPC,
                                  RadioMasterActivator, RadioMasterTargeted,
                                  RadioMasterTagged, RadioMasterActor, RadioMasterSpawn);
    // Declare a variable if needed.
    if master_obj = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // Convert the code to strings.
    master_var := ObjectVar(master_obj);
    master_desc := ObjectDesc(master_obj, EditMasterTagged.Text);
    master_def := '';
    // Override the defaults in some special cases.
    case master_obj of
        E_CHOOSE_Owner,
        E_CHOOSE_Self:  master_desc := 'the script owner';

        E_CHOOSE_Tagged: begin
            master_var  := s_oMaster;
            master_def  := s_oMaster+' = '+s_GetObject + QuoteSwap(EditMasterTagged.Text)+'");';
        end;
    end;

    // Which pieces do we need to add?
    if RadioNew.Checked then begin
        // Check the "new associate" options.
        if summonanimal.checked then
            CallAnimal(master_var, master_desc, master_def);
        if summonfamiliar.checked then
            CallFamiliar(master_var, master_desc, master_def);
        if CheckSummonPaladinMount.Checked then
            CallPaladinMount(master_var, master_desc, master_def);
        if CheckSummon.checked then
            DoSummon(master_var, master_desc, master_def);
        if CheckAddHenchman.checked then
            AddHenchman(master_var, master_desc, master_def);
        if CheckDominate.checked then
            DoDominate(master_var, master_desc, master_def);
    end
    else begin
        // Check the "existing associate" options.
        if unpossess.checked then
            StopPossession(master_var, master_desc, master_def);
        if destroyanimal.checked then
            ReleaseAssociate('ANIMALCOMPANION', 'animal companion', master_var,
                             master_desc, master_def);
        if destroyfamiliar.checked then
            ReleaseAssociate('FAMILIAR', 'familiar', master_var, master_desc,
                             master_def);
        if CheckReleasePaladinMount.Checked then
            ReleasePaladinMount(master_var, master_desc, master_def);
        if releasesummoned.checked then
            ReleaseAssociate('SUMMONED', 'summoned creature', master_var,
                             master_desc, master_def);
        if CheckReleaseDominated.checked then
            ReleaseDominated(master_var, master_desc, master_def);
        if CheckRemHenchman.checked then
            ReleaseHenchman(master_var, master_desc, master_def);
        if CheckLevelup.Checked then
            LevelCreature(master_var, master_desc, master_def);
    end;

    // End any delay that might be in effect.
    Tlilac.AddLinesDone();
end;


// -----------------------------------------------------------------------------

// Adds the scripting lines for adding a henchman to the script window.
procedure Tcompanion.AddHenchman(const master_var, master_desc, master_def: shortstring);
var
    assoc: TObjectEnum;

    last_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // Who will get added?
    assoc := GetChosenObject(RadioAddHenchOwner, nil, nil, RadioAddHenchTargeted,
                             RadioAddHenchTagged, RadioAddHenchActor, RadioAddHenchSpawn);
    // Declare a variable if needed.
    if assoc = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Give '+master_desc+' a new henchman.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // Do we need to define oTarget?
    if assoc = E_CHOOSE_Tagged then begin
        Inc(last_line);
        new_lines[last_line] := s_oTarget+' = '+
            Script.GetNearest(QuoteSwap(EditAddHenchTagged.text), master_var)+';';
    end;

    // The henchman-adding line.
    Inc(last_line);
    new_lines[last_line] := 'AddHenchman('+master_var;
    if assoc <> E_CHOOSE_Owner then
        new_lines[last_line] += ', '+ObjectVar(assoc);
    new_lines[last_line] += ');';

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


// Adds the scripting lines for summoning an animal companion to the script window.
procedure Tcompanion.CallAnimal(const master_var, master_desc, master_def: shortstring);
var
    last_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' summon its animal companion.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // The summoning line.
    Inc(last_line);
    new_lines[last_line] := Script.AssignCommand(master_var, 'SummonAnimalCompanion()')+';';

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


// Adds the scripting lines for summoning a familiar to the script window.
procedure Tcompanion.CallFamiliar(const master_var, master_desc, master_def: shortstring);
var
    last_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' summon its familiar.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // The summoning line.
    Inc(last_line);
    new_lines[last_line] := Script.AssignCommand(master_var, 'SummonFamiliar()')+';';

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


// Adds the scripting lines for summoning a familiar to the script window.
procedure Tcompanion.CallPaladinMount(const master_var, master_desc, master_def: shortstring);
var
    last_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' summon its paladin mount.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // The summoning line.
    Tlilac.Include(INC_HORSE);
    Inc(last_line);
    new_lines[last_line] := 'HorseSummonPaladinMount()';
    // Wrap it to return void?
    if (master_var <> s_OBJECT_SELF) or Tlilac.MustReturnVoid() then begin
        Tlilac.DefineFunc(FUNC_OBJ_VOID);
        new_lines[last_line] := 'ObjectToVoid('+new_lines[last_line]+')';
    end
    else if CheckRecordPaladinMount.Checked then begin
        new_lines[last_line] := s_oSpawn+' = '+new_lines[last_line];
        Tlilac.last_spawn := 'paladin mount';
        Tlilac.last_spawn_type := OBJECT_TYPE_CREATURE;
    end;
    // Assign this?
    if master_var <> s_OBJECT_SELF then
        new_lines[last_line] := s_AssignCommand + master_var+', '+new_lines[last_line]+')';
    // End with a semicolon.
    new_lines[last_line] += ';';

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


// Adds the scripting lines for dominating a creature to the script window.
procedure Tcompanion.DoDominate(const master_var, master_desc, master_def: shortstring);
var
    assoc:     TObjectEnum;
    duration:  integer;

    last_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // Who will be dominated?
    assoc := GetChosenObject(RadioDominateOwner, nil, nil, RadioDominateTargeted,
                             RadioDominateTagged, RadioDominateActor,
                             RadioDominateSpawn, FALSE);
    // Declare a variable if needed.
    if assoc = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // For how long?
    if GroupDurationDominate.ItemIndex = 0 then
        duration := -1  // permanent
    else
        duration := spinedit2.value;

    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' dominate someone.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // Do we need to define oTarget?
    if assoc = E_CHOOSE_Tagged then begin
        Inc(last_line);
        new_lines[last_line] := s_oTarget+' = '+
                Script.GetNearest(QuoteSwap(EditDominateTagged.text), master_var)+';';
    end;

    // The domination line.
    Inc(last_line);
    new_lines[last_line] := Script.AssignCommand(master_var,
                                Script.ApplyEffect('EffectDominated()',
                                        ObjectVar(assoc), FALSE, duration))+';';

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


// Adds the scripting lines for summoning a creature to the script window.
procedure Tcompanion.DoSummon(const master_var, master_desc, master_def: shortstring);
var
    duration:  integer;

    last_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // For how long?
    if GroupDurationSummon.ItemIndex = 0 then
        duration := -1  // permanent
    else
        duration := spinedit1.value;

    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' summon a creature.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // Define the summoning effect.
    Inc(last_line);
    new_lines[last_line] := s_eEffect+' = '+'EffectSummonCreature("'+
                                             QuoteSwap(EditSummon.text)+'"';
    if BoxVFXSummon.itemindex > 0 then
        new_lines[last_line] += ', '+SymConst(VFX_IMPACT, BoxVFXSummon.itemindex) +', 1.0';
    new_lines[last_line] += ');';

    // The summoning line.
    Inc(last_line);
    new_lines[last_line] :=
        Script.ApplyEffect(s_eEffect, master_var, false, duration)+';';

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


// -----------------------------------------------------------------------------


// Adds the scripting lines for leveling a creature to the script window.
procedure Tcompanion.LevelCreature(const master_var, master_desc, master_def: shortstring);
var
    bMakeLoop:         boolean;
    bRelativeToMaster: boolean;
    level_who:  TObjectEnum;
    indent:     shortstring = '';
    prefix:     shortstring = '';
    suffix:     shortstring = '';

    delay_line: integer;
    last_line:  integer;
    new_lines:  array[0..15] of shortstring;
begin
    bMakeLoop := RadioLevelAll.Checked or RadioLevelTagged.Checked;
    bRelativeToMaster := GroupHowMuchLevelup.ItemIndex = 0;

    // Will we need to wrap the function call?
    if Tlilac.MustReturnVoid() then begin
        Tlilac.DefineFunc(FUNC_INT_VOID);
        prefix := 'IntToVoid(';
        suffix := ')';
    end;

    // Who is the target?
    level_who := GetChosenObject(RadioLevelOwner, nil, nil, RadioLevelTargeted,
                                 nil, RadioLevelActor, RadioLevelSpawn);
    // Declare a variable if needed.
    if level_who = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Level up '+ObjectDesc(level_who, '', TRUE,
                                              'the henchman of '+master_desc)+'.';

    // Do we need to define oMaster?
    if ( bRelativeToMaster or bMakeLoop )  and  (master_def <> '') then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // Should we loop through all henchmen?
    if bMakeLoop then begin
        StartHenchLoop(master_var, last_line, new_lines);
        // Indent the inside of the loop.
        indent := '    ';

        // Should we check the henchman's tag?
        if RadioLevelTagged.checked then begin
            Inc(last_line);
            new_lines[last_line] := indent + 'if ( GetTag('+s_oHench+') == "'+
                                              QuoteSwap(EditLevelTagged.Text)+'" )';
            Inc(last_line);
            new_lines[last_line] := indent + '{';
            // Indent the next line even more.
            indent += '    ';
        end;
    end;

    // Do we need a loop for the number of levels?
    if bRelativeToMaster or (SpinAbsoluteLevel.Value > 1) then begin
        // Define the number of levels to give.
        Inc(last_line);
        new_lines[last_line] := indent + s_nCount + ' = ';
        if not bRelativeToMaster then
            new_lines[last_line] += inttostr(SpinAbsoluteLevel.Value)+';'
        else begin
            new_lines[last_line] += 'GetHitDice('+master_var+')';
            if SpinRelativeLevel.Value > 0 then
                new_lines[last_line] += ' - '+IntToStr(SpinRelativeLevel.Value);
            new_lines[last_line] += ' - GetHitDice('+ObjectVar(level_who, s_oHench)+');';
        end;
        // Start the loop.
        Inc(last_line);
        new_lines[last_line] := indent + 'while ( '+s_nCount+'-- > 0 )';
        // indent the inside of the loop.
        indent += '    ';
    end;


    // Do the actual leveling.
    Inc(last_line);
    new_lines[last_line] := indent + prefix+'LevelUpHenchman('+ObjectVar(level_who, s_oHench);
    // Optional parameters.
    if (BoxPackageLevelup.ItemIndex > 0) or CheckSpellsLevelup.Checked or
       (BoxClassLevelup.itemindex > 0) then
        new_lines[last_line] += ', '+NameToConstant('CLASS_TYPE', BoxClassLevelup.text);
    if (BoxPackageLevelup.ItemIndex > 0) or CheckSpellsLevelup.Checked then
        new_lines[last_line] += BoolToStr(CheckSpellsLevelup.Checked, s_comma_TRUE, s_comma_FALSE);
    if BoxPackageLevelup.ItemIndex > 0 then
        new_lines[last_line] += ', '+SymConst(PACKAGES[BoxClassLevelup.ItemIndex],
                                              BoxPackageLevelup.ItemIndex - 1);
    // End the command.
    new_lines[last_line] += ')'+suffix+';';
    // This is the line that might get delayed.
    delay_line := last_line;


    // Commenting out some currently unnecessary bookkeeping.
    //// End the loop for the number of levels?
    //if bRelativeToMaster or (SpinEditAbsoluteLevel.Value > 1) then
    //    SetLength(indent, Length(indent)-4);

    // End the loop through all henchmen?
    if bMakeLoop then begin
        // End the 'if' statement?
        if RadioLevelTagged.checked then begin
            //SetLength(indent, Length(indent)-4);  // Restore this bookkeeping
            Inc(last_line);                         // if the hardcoded 4 spaces
            new_lines[last_line] := '    }';        // becomes wrong here.
        end;
        EndHenchLoop(master_var, last_line, new_lines);
    end;

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], delay_line, delay_line, true);
end;


// Adds the scripting lines for destroying an associate to the script window.
// _assoc_type_ is the suffix appended to 'ASSOCIATE_TYPE_', and _assoc_desc_
// is used in a comment.
procedure Tcompanion.ReleaseAssociate(const assoc_type, assoc_desc: shortstring;
                                      const master_var, master_desc, master_def: shortstring);
var
    last_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' release its '+assoc_desc+'.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // Destroy the animal companion.
    // Inlining the call to GetAssociate() to make this more robust if delayed.
    Inc(last_line);
    new_lines[last_line] := 'DestroyObject(GetAssociate(ASSOCIATE_TYPE_'+assoc_type;
    if master_var <> s_OBJECT_SELF then
        new_lines[last_line] += ', '+master_var;
    new_lines[last_line] += '));';

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


// Adds the scripting lines for ending a domination to the script window.
procedure Tcompanion.ReleaseDominated(const master_var, master_desc, master_def: shortstring);
var
    dom_string: shortstring;

    last_line:  integer;
    new_lines:  array[0..2] of shortstring;
begin
    // Who is being released?
    // (This will be inlined to make the script more robust if a delay is used.)
    dom_string := 'GetAssociate(ASSOCIATE_TYPE_DOMINATED';
    if master_var <> s_OBJECT_SELF then
        dom_string += ', '+master_var;
    dom_string += ')';

    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' release its dominated creature.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    if CheckDestroyReleaseDominated.checked then begin
        // Destroy the dominated creature.
        Inc(last_line);
        new_lines[last_line] := 'DestroyObject('+dom_string+');';
    end
    else begin
        // Just release the dominated creature.
        Tlilac.Include(INC_SPELLS);
        Inc(last_line);
        new_lines[last_line] := 'RemoveSpecificEffect(EFFECT_TYPE_DOMINATED, '+
                                dom_string+');';
    end;

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


// Adds the scripting lines for releasing a henchman to the script window.
procedure Tcompanion.ReleaseHenchman(const master_var, master_desc, master_def: shortstring);
var
    bMakeLoop: boolean;
    assoc:     TObjectEnum;
    indent:    shortstring = '';

    delay_line: integer;
    last_line:  integer;
    new_lines:  array[0..11] of shortstring;
begin
    // In two cases we will loop through all henchmen.
    bMakeLoop := RadioRemHenchTagged.checked or RadioRemHenchAll.Checked;

    // Who will get released?
    assoc := GetChosenObject(RadioRemHenchOwner, nil, nil, RadioRemHenchTargeted,
                             nil, RadioRemHenchActor, RadioRemHenchSpawn);
    // Declare a variable if needed.
    if assoc = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' release its henchman.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // Should we loop through all henchmen?
    if bMakeLoop then begin
        StartHenchLoop(master_var, last_line, new_lines);
        // Indent the inside of the loop.
        indent := '    ';

        // Should we check the henchman's tag?
        if RadioRemHenchTagged.checked then begin
            Inc(last_line);
            new_lines[last_line] := indent + 'if ( GetTag('+s_oHench+') == "'+
                                    QuoteSwap(EditRemHenchTagged.text)+'" )';
            // Indent the next line even more.
            indent += '    ';
        end;
    end;

    // Do the actual destruction or firing.
    Inc(last_line);
    delay_line := last_line;
    if CheckDestroyRemHenchman.Checked then
        // Destroy the henchman.
        new_lines[last_line] := indent + 'DestroyObject('+ObjectVar(assoc, s_oHench)+');'
    else begin
        // Just release the henchman from service.
        new_lines[last_line] := indent + 'RemoveHenchman('+master_var;
        if assoc <> E_CHOOSE_Owner then
            new_lines[last_line] += ', '+ObjectVar(assoc, s_oHench);
        new_lines[last_line] += ');';
    end;

    // End the loop through all henchmen?
    if bMakeLoop then
        EndHenchLoop(master_var, last_line, new_lines);

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], delay_line, delay_line, true);
end;


// Adds the scripting lines for dismissing a paladin mount.
procedure Tcompanion.ReleasePaladinMount(const master_var, master_desc, master_def: shortstring);
var
    last_line:  integer;
    new_lines:  array[0..2] of shortstring;
begin
    // The opening comment.
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' dismiss its paladin mount.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // Release the mount.
    Tlilac.Include(INC_HORSE);
    Inc(last_line);
    new_lines[last_line] := Script.AssignCommand(master_var,
                            'HorseUnsummonPaladinMount()')+';';

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line, true);
end;


// Adds the scripting lines for unpossessing a familiar to the script window.
procedure Tcompanion.StopPossession(const master_var, master_desc, master_def: shortstring);
var
    indent: string[4] = '';

    delay_line: integer = -1;
    last_line:  integer;
    new_lines:  array[0..5] of shortstring;
begin
    // The initial comment:
    last_line := 0;
    new_lines[0] := '// Have '+master_desc+' unpossess its familiar.';

    // Do we need to define oMaster?
    if master_def <> '' then begin
        Inc(last_line);
        new_lines[last_line] := master_def;
    end;

    // Everyone except spawns might be possesed familiars, rather than "true" masters.
    if master_var <> s_oSpawn then begin
        Inc(last_line);
        new_lines[last_line] := 'if ( GetIsPossessedFamiliar('+master_var+') )';
        // Special case: if the master is oPC, it gets reset to the true PC.
        if master_var = s_oPC then begin
            Inc(last_line);
            new_lines[last_line] := '    // The PC is really the master of what is currently oPC.';
            Inc(last_line);
            new_lines[last_line] := '    '+s_oPC+' = GetMaster('+s_oPC+');';
        end
        else begin
            Inc(last_line);
            new_lines[last_line] := '    UnpossessFamiliar('+master_var+');';
            // We can begin delaying with this line.
            delay_line := last_line;
            Inc(last_line);
            new_lines[last_line] := 'else';
            // Indent the next line.
            indent := '    ';
        end;
    end;

    // The unpossession line.
    Inc(last_line);
    new_lines[last_line] := indent +
                        'UnpossessFamiliar(GetAssociate(ASSOCIATE_TYPE_FAMILIAR';
    if master_var <> s_OBJECT_SELF then
        new_lines[last_line] += ', '+master_var;
    new_lines[last_line] += '));';
    // If not set earlier, this is the first line that can be delayed.
    if delay_line < 0 then
        delay_line := last_line;

    // Send the lines over to the script window.
    Tlilac.AddLines(new_lines[0..last_line], delay_line, last_line, true);
end;


initialization
  {$i companions.lrs}
end.
