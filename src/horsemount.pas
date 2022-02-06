{
Copyright 2011 The Krit

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
This is a new unit to provide access to select horse functions, introduced in
NWN 1.69. --TK
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit HorseMount;


interface

uses
  Buttons, ExtCtrls, StdCtrls, {SysUtils,} LResources, {Forms,}
  ExtForm, Classes, constants;

type

  { THorseForm }

  THorseForm = class(TExtForm)
      // Form elements.
      ButtonOkay: TBitBtn;
      ButtonCancel: TBitBtn;
      BoxHorseTails: TComboBox;
      CheckMountIsAction: TCheckBox;
      CheckDismountIsAction: TCheckBox;
      EditHorseTagged: TEdit;
      EditAssignTagged: TEdit;
      EditTagged: TEdit;
      GroupHorse: TGroupBox;
      GroupDismountType: TRadioGroup;
      GroupAssignedHorse: TGroupBox;
      GroupRider: TGroupBox;
      LabelHorseTails: TLabel;
      PanelDoAssign: TPanel;
      PanelStuck: TPanel;
      PanelDoMount: TPanel;
      PanelDismount: TPanel;
      RadioActivator: TRadioButton;
      RadioDoAssign: TRadioButton;
      RadioHorseAssigned: TRadioButton;
      RadioAssignPaladin: TRadioButton;
      RadioAssignOwner: TRadioButton;
      RadioAssignSpawn: TRadioButton;
      RadioHorseTagged: TRadioButton;
      RadioAssignTagged: TRadioButton;
      RadioHorseTargeted: TRadioButton;
      RadioHorseOwner: TRadioButton;
      RadioDismount: TRadioButton;
      RadioDoMount: TRadioButton;
      GroupMountType: TRadioGroup;
      RadioHorseSpawn: TRadioButton;
      RadioAssignTargeted: TRadioButton;
      RadioOwner: TRadioButton;
      RadioPC: TRadioButton;
      RadioSpawn: TRadioButton;
      RadioTagged: TRadioButton;
      RadioTargeted: TRadioButton;
      TextCheat: TStaticText;
      TextDismountTypes: TStaticText;
      // Event handlers.
      procedure FormCreate(Sender: TObject);
      procedure GroupDismountTypeClick(Sender: TObject);
      procedure GroupMountTypeClick(Sender: TObject);
      procedure LabelStuckClick(Sender: TObject);
      procedure RadioOwnerChange(Sender: TObject);
      procedure RadioSpawnChange(Sender: TObject);
      procedure ToggleOkay(Sender: TObject); override;
      procedure ButtonOkayClick(Sender: TObject);

    private
      procedure DoAssign(const rider: TObjectEnum; const rider_def: shortstring);
      procedure DoMount(const rider: TObjectEnum; const rider_def: shortstring);
      procedure Dismount(const rider: TObjectEnum; const rider_def: shortstring);
  end;


// -----------------------------------------------------------------------------
implementation

uses
    start, nwn, delay;


{ THorseForm }

procedure THorseForm.FormCreate(Sender: TObject);
begin
    // Load the horse tails.
    LoadConstants(BoxHorseTails.Items, TAIL_TYPE_SCALED[TAIL_HORSE_START..TAIL_HORSE_END]);
    // Plus three nightmare tails.
    BoxHorseTails.Items.Append(ConstDisplay(TAIL_TYPE_SCALED, TAIL_NIGHTMARE_1));
    BoxHorseTails.Items.Append(ConstDisplay(TAIL_TYPE_SCALED, TAIL_NIGHTMARE_2));
    BoxHorseTails.Items.Append(ConstDisplay(TAIL_TYPE_SCALED, TAIL_NIGHTMARE_3));

    // Default the rider tag to the most recent actor.
    EditTagged.Text := Tlilac.last_actor;
    // But don't change the default selection.
    RadioPC.Checked := true;

    // Initialize the radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, nil, OBJECT_TYPE_CREATURE);
    main.InitRadioWhos(RadioHorseOwner, RadioHorseSpawn, nil, OBJECT_TYPE_CREATURE);
    main.InitRadioWhos(RadioAssignOwner, RadioAssignSpawn, nil, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(RadioPC, RadioOwner, RadioActivator, RadioTargeted, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(nil, RadioHorseOwner, nil, RadioHorseTargeted, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(nil, RadioAssignOwner, nil, RadioAssignTargeted, OBJECT_TYPE_CREATURE);

    // Hide the action queue option if this is a delayed command.
    // (Too many things can go wrong, as per the action queue form.)
    CheckMountIsAction.Visible    := not Tdelaycommand.DelaySet();
    CheckDismountIsAction.Visible := not Tdelaycommand.DelaySet();
end;


// Makes the correct elements of the dismounting panel appear, based on the type
// of dismounting.
procedure THorseForm.GroupDismountTypeClick(Sender: TObject);
begin
    // The action queue is only an option for regular dismountings (the things
    // that need to be run by the rider).
    CheckDismountIsAction.Visible := (GroupDismountType.ItemIndex <= 1) and
                                     not Tdelaycommand.DelaySet();

    // Update the "Okay" button.
    ToggleOkay(Sender);
end;


// Makes the correct elements of the mounting panel appear, based on the type
// of mounting.
procedure THorseForm.GroupMountTypeClick(Sender: TObject);
var
    bCheat: boolean;
begin
    bCheat := GroupMountType.ItemIndex = 2;

    // When not cheating, the horse is an object.
    GroupHorse.Visible         := not bCheat;
    CheckMountIsAction.Visible := not bCheat and not Tdelaycommand.DelaySet();

    // When cheating, the horse is selected from the list of tails.
    TextCheat.Visible       := bCheat;
    LabelHorseTails.Visible := bCheat;
    BoxHorseTails.Visible   := bCheat;

    // Update the "Okay" button.
    ToggleOkay(Sender);
end;


// Faked radio button label.
procedure THorseForm.LabelStuckClick(Sender: TObject);
begin
    GroupDismountType.ItemIndex := 3;
    FocusControl(GroupDismountType);
end;


// Prevents the script owner from mounting itself.
procedure THorseForm.RadioOwnerChange(Sender: TObject);
begin
    DisableAndUnselect(RadioHorseOwner, RadioOwner.Checked, RadioHorseTagged);
    DisableAndUnselect(RadioAssignOwner, RadioOwner.Checked, RadioAssignTagged);
end;


// Prevents the spawn from mounting itself.
procedure THorseForm.RadioSpawnChange(Sender: TObject);
begin
    DisableAndUnselect(RadioHorseSpawn, RadioSpawn.Checked, RadioHorseTagged);
    DisableAndUnselect(RadioAssignSpawn, RadioSpawn.Checked, RadioAssignTagged);
end;


// Enables/disables the "Okay" button as appropriate.
procedure THorseForm.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // A tagged rider needs a tag.
    if RadioTagged.Checked and (EditTagged.Text = '') then
        bEnable := false

    else if RadioDoAssign.Checked then
        // A tagged horse needs a tag.
        bEnable := not RadioAssignTagged.Checked or (EditAssignTagged.Text <> '')

    else if RadioDismount.Checked then
        // No additional info required for dismounting.
        bEnable := true

    else
        if GroupMountType.ItemIndex = 2 then
            // Cheat mounting requires a tail-horse.
            bEnable := BoxHorseTails.ItemIndex >= 0
        else
            // A tagged horse needs a tag.
            bEnable := not RadioHorseTagged.Checked or (EditHorseTagged.Text <> '');

    // Update the button.
    ButtonOkay.Enabled := bEnable;
end;


procedure THorseForm.ButtonOkayClick(Sender: TObject);
var
    rider: TObjectEnum;
    rider_def: shortstring;
begin
    // Include the horse functions.
    Tlilac.Include(INC_HORSE);

    // Determine who is the rider.
    rider := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                             nil, RadioTagged, RadioSpawn);
    // Adjust for some special cases.
    case rider of
        E_CHOOSE_Self:  Tlilac.Declare(VAR_oSELF);
        E_CHOOSE_Actor: Tlilac.last_actor := EditTagged.Text;
    end;
    // How will the rider be defined?
    if rider = E_CHOOSE_Actor then
        rider_def := s_oActor+' = '+s_getObject + QuoteSwap(EditTagged.Text) + '");'
    else
        // Will have already been defined.
        rider_def := '';

    // Mount, dismount, or assign?
    if RadioDoMount.Checked then
        DoMount(rider, rider_def)
    else if RadioDismount.Checked then
        Dismount(rider, rider_def)
    else
        DoAssign(rider, rider_def);
end;


// -----------------------------------------------------------------------------


// Handles adding the lines for assigning a mount to the script window.
procedure THorseForm.DoAssign(const rider: TObjectEnum; const rider_def: shortstring);
var
    horse: TObjectEnum;
    rider_var, params: shortstring;

    last_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // Initialize.
    rider_var := ObjectVar(rider);

    // Which horse will be assigned?
    horse := GetChosenObject(RadioAssignOwner, nil, nil, RadioAssignTargeted,
                             RadioAssignTagged, nil, RadioAssignSpawn, FALSE);
    // Declare a variable if needed.
    if horse = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // The initial comment.
    new_lines[0] := '// Assign a horse to '+ObjectDesc(rider, EditTagged.Text)+'.';
    last_line := 1; // At least one more line will be added.

    // Do we need to define oActor?
    if rider_def <> '' then begin
        new_lines[last_line] := rider_def;
        Inc(last_line);
    end;

    // Do we need to define oTarget?
    if horse = E_CHOOSE_Tagged then begin
        // Define oTarget.
        params := BoolToStr(rider = E_CHOOSE_Owner, '', ', '+rider_var);
        new_lines[last_line] := s_oTarget+' = '+s_getNearest +
                                QuoteSwap(EditAssignTagged.Text)+'"' + params+');';
        Inc(last_line);
    end;

    // Assign the horse.
    params := ObjectVar(horse, 'HorseGetPaladinMount('+rider_var+')') + ', ';
    new_lines[last_line] := 'HorseSetOwner('+params + rider_var + s_comma_TRUE+');';

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line);
end;


// Handles adding the lines for mounting to the script window.
procedure THorseForm.DoMount(const rider: TObjectEnum; const rider_def: shortstring);
var
    nTail:     integer;
    horse:     TObjectEnum;
    rider_var: shortstring;
    params:    shortstring;

    last_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // Initialize
    rider_var := ObjectVar(rider);

    // Do we need to define oActor?
    // (Line 0 will be filled in with a comment later.)
    if rider_def = '' then
        last_line := 1
    else begin
        new_lines[1] := rider_def;
        last_line := 2;
    end;

    // Cheat mounting is a special case.
    if GroupMountType.ItemIndex = 2 then begin
        // Which horse will the rider appear to ride?
        nTail := BoxHorseTails.ItemIndex + TAIL_HORSE_START;
        // Adjust for nightmares.
        case nTail - TAIL_HORSE_END of
            1: nTail := TAIL_NIGHTMARE_1;
            2: nTail := TAIL_NIGHTMARE_2;
            3: nTail := TAIL_NIGHTMARE_3;
        end;

        // The lines to add.
        new_lines[0] := '// Have '+ObjectDesc(rider, EditTagged.Text)+' become mounted.';
        new_lines[last_line] := 'HorseInstantMount('+rider_var+', '+
                                SymConst(TAIL_TYPE_SCALED, nTail)+');';
    end

    else begin
        // Which horse will be mounted?
        horse := GetChosenObject(RadioHorseOwner, nil, nil, RadioHorseTargeted,
                                 RadioHorseTagged, nil, RadioHorseSpawn, FALSE);
        // Declare a variable if needed.
        if horse = E_CHOOSE_Self then
            Tlilac.Declare(VAR_oSELF);

        // Do we need to define oTarget?
        if horse = E_CHOOSE_Tagged then begin
            // Define oTarget.
            new_lines[last_line] := s_oTarget+' = '+s_getNearest +
                                        QuoteSwap(EditHorseTagged.Text)+'"';
            // Optional parameter?
            if rider <> E_CHOOSE_Owner then
                new_lines[last_line] += ', '+rider_var;
            // End the line.
            new_lines[last_line] += ');';
            Inc(last_line);
        end;

        // Convert the horse to a string.
        params := ObjectVar(horse, 'HorseGetMyHorse('+rider_var+')');
        // Handle instant mounts.
        if GroupMountType.ItemIndex = 1 then
            params += ', FALSE, TRUE';

        // The lines to add.
        new_lines[0] := '// Have '+ObjectDesc(rider, EditTagged.Text)+' mount a horse.';
        new_lines[last_line] := 'HorseMount('+params+')';
        // Use the action queue?
        if CheckMountIsAction.Checked then
            new_lines[last_line] := 'ActionDoCommand('+new_lines[last_line]+')';
        // Does this need to be assigned?
        if rider <> E_CHOOSE_Owner then
            new_lines[last_line] := s_AssignCommand + rider_var+', '+new_lines[last_line]+')';
        // End the command.
        new_lines[last_line] += ';';
    end;

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line);
end;


// Handles adding the lines for dismounting to the script window.
procedure THorseForm.Dismount(const rider: TObjectEnum; const rider_def: shortstring);
var
    params: shortstring;

    last_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    // Do we need to define oActor?
    // (Line 0 will be filled in with a comment later.)
    if rider_def = '' then
        last_line := 1
    else begin
        new_lines[1] := rider_def;
        last_line := 2;
    end;

    // Forceful dismounting is a special case.
    if GroupDismountType.ItemIndex = 3 then begin
        // The lines to add.
        new_lines[0] := '// Force '+ObjectDesc(rider, EditTagged.Text)+' to a dismounted appearance.';
        new_lines[last_line] := 'HorseChangeToDefault('+ObjectVar(rider)+');';
    end

    // Cheat dismounting is a special case.
    else if GroupDismountType.ItemIndex = 2 then begin
        // The lines to add.
        new_lines[0] := '// Have '+ObjectDesc(rider, EditTagged.Text)+' become unmounted.';
        new_lines[last_line] := 'HorseInstantDismount('+ObjectVar(rider)+');';
    end

    else begin
        // Handle instant dismounts.
        if GroupDismountType.ItemIndex = 1 then
            params := s_FALSE
        else
            params := '';

        // The lines to add.
        new_lines[0] := '// Have '+ObjectDesc(rider, EditTagged.Text)+' dismount.';
        new_lines[last_line] := 'HorseDismount('+params+')';

        // Do we need to typecast to void?
        if (rider <> E_CHOOSE_Owner) or CheckDismountIsAction.Checked or
           Tlilac.MustReturnVoid() then
        begin
            Tlilac.DefineFunc(FUNC_OBJ_VOID);
            new_lines[last_line] := 'ObjectToVoid('+new_lines[last_line]+')';

            // Use the action queue?
            if CheckDismountIsAction.Checked then
                new_lines[last_line] := 'ActionDoCommand('+new_lines[last_line]+')';
            // Does this need to be assigned?
            if rider <> E_CHOOSE_Owner then
                new_lines[last_line] := s_AssignCommand + ObjectVar(rider)+', '+new_lines[last_line]+')';
        end;
        // End the command.
        new_lines[last_line] += ';';
    end;

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line);
end;


initialization
  {$I horsemount.lrs}
end.

