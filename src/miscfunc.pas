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
* Expanded form options.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit miscfunc;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, Buttons, ExtCtrls, Spin,
  LResources, ExtForm;

type

  { Tmisc }

  Tmisc = class(TExtForm)
    // Form elements
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BoxWeather: TComboBox;
    EditStripChest: TEdit;
    GroupWhatStrip: TCheckGroup;
    EditMapTagged: TEdit;
    EditFacerTagged: TEdit;
    EditTowardTagged: TEdit;
    EditWeatherTagged: TEdit;
    GroupSubjectFacing: TGroupBox;
    GroupTargetFacing: TGroupBox;
    GroupWhereStrip: TGroupBox;
    GroupWhichWeather: TGroupBox;
    GroupWhichMap: TGroupBox;
    CheckMap: TCheckBox;
    GroupShowMap: TRadioGroup;
    GroupAreaWeather: TGroupBox;
    RadioFacerActivator: TRadioButton;
    RadioStripDestroy: TRadioButton;
    RadioStripChest: TRadioButton;
    RadioTowardActivator: TRadioButton;
    RadioFacerActor: TRadioButton;
    RadioTowardActor: TRadioButton;
    RadioMapOwner: TRadioButton;
    RadioFacerOwner: TRadioButton;
    RadioTowardOwner: TRadioButton;
    RadioFacerPC: TRadioButton;
    RadioTowardPC: TRadioButton;
    RadioFacerSpawn: TRadioButton;
    RadioTowardSpawn: TRadioButton;
    RadioFacerTagged: TRadioButton;
    RadioTowardTagged: TRadioButton;
    RadioFacerTargeted: TRadioButton;
    RadioTowardTargeted: TRadioButton;
    RadioTowardTargetLoc: TRadioButton;
    RadioWeatherOwner: TRadioButton;
    RadioWeatherPC: TRadioButton;
    RadioWeatherModule: TRadioButton;
    RadioMapTagged: TRadioButton;
    RadioMapPC: TRadioButton;
    RadioWeatherTagged: TRadioButton;
    CheckWeather: TCheckBox;
    CheckFacing: TCheckBox;
    CheckStrip: TCheckBox;
    CheckScale: TCheckBox;
    ShapeSpacer: TShape;
    SpinScale: TSpinEdit;
    LabelScale: TLabel;
    TextDelayedTargeting: TStaticText;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure GroupWhatStripItemClick(Sender: TObject; Index: integer);
    procedure RadioFacerActivatorChange(Sender: TObject);
    procedure RadioFacerActorChange(Sender: TObject);
    procedure RadioFacerOwnerChange(Sender: TObject);
    procedure RadioFacerPCChange(Sender: TObject);
    procedure RadioFacerSpawnChange(Sender: TObject);
    procedure RadioFacerTargetedChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    procedure SendExploreMap();
    procedure SendSetFacing();
    procedure SendSetScale();
    procedure SendSetWeather();
    procedure SendStrip();
  end;

{var
  misc: Tmisc;
}

implementation

uses
    {event,} nwn, start,
    constants, delay;


// Configures the form based on current circumstances.
procedure Tmisc.FormCreate(Sender: TObject);
begin
    // Initialize radio buttons.
    main.InitRadioWhos(RadioMapOwner, nil, nil, OBJECT_TYPE_AREA);
    main.InitRadioWhos(RadioWeatherOwner, nil, nil, OBJECT_TYPE_AREA);
    main.InitRadioWhos(RadioFacerOwner, RadioFacerSpawn, RadioFacerActor, OBJECT_TYPE_CREATURE);
    main.InitRadioWhos(RadioTowardOwner, RadioTowardSpawn, RadioTowardActor, OBJECT_TYPE_IN_AREA);
    main.InitActivationRadios(RadioFacerOwner, RadioFacerPC, RadioFacerActivator, RadioFacerTargeted, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(RadioTowardOwner, RadioTowardPC, RadioTowardActivator, RadioTowardTargeted,
                              OBJECT_TYPE_IN_AREA, RadioTowardTargetLoc);
    // Special case: on a delay, the target object's location and the target location
    // might be different.
    if RadioTowardTargeted.Visible  and  (0 <> main.ActTargetType and OBJECT_TYPE_CREATURE)  and
       Tdelaycommand.DelaySet() then
    begin
        RadioTowardTargetLoc.Visible := TRUE;
        TextDelayedTargeting.Visible := TRUE;
    end
    else
        // Since not both of these will be visible, line them up in the same column.
        RadioTowardTargetLoc.Left := RadioTowardTargeted.Left;

    // Make sure default selections are still visible.
    with RadioFacerOwner do
        if Checked and not Visible then
            // Still being checked implies not item activation, so the PC radio
            // is visible.
            RadioFacerPC.Checked := TRUE;
    with RadioTowardPC do
        if Checked and not Visible then
            // Not being visible implies item activation with a target that has no area.
            RadioTowardTagged.Checked := TRUE;

    // Default to stripping all items (but not gold).
    GroupWhatStrip.Checked[0] := true;
    GroupWhatStrip.Checked[1] := true;
end;


// Wrapper for ToggleOkay becuase this takes an extra parameter.
procedure Tmisc.GroupWhatStripItemClick(Sender: TObject; Index: integer);
begin
    ToggleOkay(Sender);
end;


// Prevents telling an object to face itself.
procedure Tmisc.RadioFacerActivatorChange(Sender: TObject);
begin
    with RadioTowardActivator do begin
        Enabled := not RadioFacerActivator.Checked;
        // Do not keep a selection that is now disabled.
        if not Enabled and Checked then begin
            if RadioTowardTargeted.Visible then
                RadioTowardTargeted.Checked := true
            else
                RadioTowardTargetLoc.Checked := true;
        end;
    end;
end;


// Prevents telling an object to face itself.
procedure Tmisc.RadioFacerActorChange(Sender: TObject);
begin
    with RadioTowardActor do begin
        Enabled := not RadioFacerActor.Checked;
        // Do not keep a selection that is now disabled.
        if not Enabled and Checked then
            RadioTowardTagged.Checked := true;
    end;
end;


// Prevents telling an object to face itself.
procedure Tmisc.RadioFacerOwnerChange(Sender: TObject);
begin
    with RadioTowardOwner do begin
        Enabled := not RadioFacerOwner.Checked;
        // Do not keep a selection that is now disabled.
        if not Enabled and Checked then
            RadioTowardPC.Checked := true;
    end;
end;


// Prevents telling an object to face itself.
procedure Tmisc.RadioFacerPCChange(Sender: TObject);
begin
    with RadioTowardPC do begin
        Enabled := not RadioFacerPC.Checked;
        // Do not keep a selection that is now disabled.
        if not Enabled and Checked then begin
            if RadioTowardOwner.Visible then
                RadioTowardOwner.Checked := true
            else
                RadioTowardTagged.Checked := true;
        end;
    end;
end;


// Prevents telling an object to face itself.
procedure Tmisc.RadioFacerSpawnChange(Sender: TObject);
begin
    with RadioTowardSpawn do begin
        Enabled := not RadioFacerSpawn.Checked;
        // Do not keep a selection that is now disabled.
        if not Enabled and Checked then
            RadioTowardTagged.Checked := true;
    end;
end;


// Prevents telling an object to face itself.
procedure Tmisc.RadioFacerTargetedChange(Sender: TObject);
begin
    with RadioTowardTargeted do begin
        Enabled := not RadioFacerTargeted.Checked;
        // Do not keep a selection that is now disabled.
        if not Enabled and Checked then
            RadioTowardActivator.Checked := true;
    end;
end;


// Handles the enabled state of the "Okay" button.
procedure Tmisc.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // Something must be selected to do.
    if not ( CheckMap.Checked   or CheckWeather.Checked or CheckStrip.Checked or
             CheckScale.Checked or CheckFacing.Checked ) then
        bEnable := false

    // When options are selected, tagged objects need tags.
    else if CheckMap.Checked and
            RadioMapTagged.Checked and (EditMapTagged.Text = '') then
        bEnable := false

    else if CheckWeather.Checked and
            RadioWeatherTagged.Checked and (EditWeatherTagged.Text = '') then
        bEnable := false

    else if CheckStrip.Checked and
            RadioStripChest.Checked and (EditStripChest.Text = '') then
        bEnable := false

    else if CheckFacing.Checked then begin
        if RadioFacerTagged.Checked and (EditFacerTagged.Text = '') then
            bEnable := false
        else
            bEnable := not (RadioTowardTagged.Checked and (EditTowardTagged.Text = ''));
    end

    else
        // Passed all tests.
        bEnable := true;

    // Also, if we are stripping, something must be selected to be stripped.
    if bEnable and CheckStrip.Checked then
        bEnable := GroupWhatStrip.Checked[0] or GroupWhatStrip.Checked[1] or
                   GroupWhatStrip.Checked[2];

    // Update the button.
    BitBtn1.Enabled := bEnable;
end;


// Handles clicks of the "Okay" button, submitting NWScript to the script window.
procedure Tmisc.BitBtn1Click(Sender: TObject);
begin
    // Call the various sub-options as requested.
    if CheckMap.checked then
        SendExploreMap();

    if CheckWeather.checked then
        SendSetWeather();

    if CheckStrip.checked then
        SendStrip();

    if CheckScale.checked then
        SendSetScale();

    if CheckFacing.checked then
        SendSetFacing();
end;


// -----------------------------------------------------------------------------


// Send NWScript to the script window for exploring/obscuring a minimap.
procedure Tmisc.SendExploreMap();
var
    bExplore: boolean;
    area: shortstring;

    last_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    bExplore := GroupShowMap.ItemIndex = 0;

    // Which area?
         if RadioMapPC.Checked      then  area := s_GetAreaPC
    else if RadioMapTagged.Checked  then  area := s_oArea
    else // RadioMapOwner.Checked
        if Tlilac.WillBeAssigned()  then  area := s_oSelf
                                    else  area := s_OBJECT_SELF;

    // The opening comment.
    new_lines[0] := '// '+BoolToStr(bExplore, 'Reveal', 'Blank')+' the area map.';
    last_line := 1;

    // Define the area?
    if area = s_oSelf then
        Tlilac.Declare(VAR_oSELF)
    else if area = s_oArea then begin
        new_lines[1] := s_oArea+' = '+s_GetObject + QuoteSwap(EditMapTagged.Text)+'");';
        last_line := 2;
    end;

    // Explore the area.
    new_lines[last_line] := 'ExploreAreaForPlayer('+area+', '+s_oPC+
                            BoolToStr(bExplore, '', s_comma_FALSE)+');';

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line);
end;


// Send NWScript to the script window for setting a creature's facing.
procedure Tmisc.SendSetFacing();
var
    facer, target: TObjectEnum;
    tag: shortstring;

    last_line: integer;
    new_lines: array[0..3] of shortstring;
begin
    // Who will be turning?
    facer := GetChosenObject(RadioFacerOwner, RadioFacerPC, RadioFacerActivator,
                             RadioFacerTargeted, RadioFacerTagged,
                             RadioFacerActor, RadioFacerSpawn);
    // Who will be faced?
    target := GetChosenObject(RadioTowardOwner, RadioTowardPC, RadioTowardActivator,
                              RadioTowardTargeted, RadioTowardTagged,
                              RadioTowardActor, RadioTowardSpawn, FALSE);
    // Declare a variable if needed.
    if (facer = E_CHOOSE_Self)  or  (target = E_CHOOSE_Self) then
        Tlilac.Declare(VAR_oSELF);

    // The opening comment.
    new_lines[0] := '// Have '+ObjectDesc(facer, EditFacerTagged.Text)+
                    ' turn to face '+ObjectDesc(target, EditTowardTagged.Text, FALSE, 'the activation location')+'.';
    last_line := 1;

    // Define the turner if needed.
    if facer = E_CHOOSE_Tagged then begin
        tag := QuoteSwap(EditFacerTagged.text);
        // We might swap over to oActor.
        if target <> E_CHOOSE_Actor then begin
            // oActor is available and more appropriate.
            // This also handles the case where both turner and target were oTarget.
            facer := E_CHOOSE_Actor;
            Tlilac.last_actor := tag;
        end;
        new_lines[1] := ObjectVar(facer)+' = '+s_GetObject + tag+'");';
        last_line := 2;
    end;

    // Define the target if needed.
    if target = E_CHOOSE_Tagged then begin
        tag := QuoteSwap(EditTowardTagged.text);
        new_lines[last_line] := s_oTarget+' = '+Script.GetNearest(tag, ObjectVar(facer))+';';
        Inc(last_line);
    end;

    // Do the facing.
    if ( (target = E_CHOOSE_ActTarget)  and  not RadioTowardTargetLoc.Visible )  or
       (target = E_CHOOSE_Other) then
        new_lines[last_line] := Script.AssignCommand(facer,
                                    'SetFacingPoint(GetPositionFromLocation('+s_lActTarget+'))')+';'
    else
        new_lines[last_line] := Script.AssignCommand(facer,
                                    'SetFacingPoint(GetPosition('+ObjectVar(target)+'))')+';';

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line);
end;


// Send NWScript to the script window for setting the module's XP scale.
procedure Tmisc.SendSetScale();
var
    new_lines: array[0..1] of shortstring;
begin
    new_lines[0] := '// Set the scale used for hardcoded creature kill XP.';
    new_lines[1] := 'SetModuleXPScale('+IntToStr(SpinScale.value)+');';

    Tlilac.AddLines(new_lines, 1, 1);
end;


// Send NWScript to the script window for setting an area's weather.
procedure Tmisc.SendSetWeather();
var
    area, weather: shortstring;

    last_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    // Which area?
         if RadioWeatherPC.Checked      then  area := s_GetAreaPC
    else if RadioWeatherTagged.Checked  then  area := s_oArea
    else if RadioWeatherModule.Checked  then  area := s_GetModule
    else // RadioWeatherOwner.Checked
        if Tlilac.WillBeAssigned()      then  area := s_oSelf
                                        else  area := s_OBJECT_SELF;

    // What weather?
    if BoxWeather.itemindex = 0 then
        weather := 'WEATHER_USE_AREA_SETTINGS'
    else
        weather := 'WEATHER_'+uppercase(BoxWeather.text);

    // The opening comment.
    if RadioWeatherModule.Checked then
        new_lines[0] := '// Set the weather for all (outside) areas.'
    else
        new_lines[0] := '// Set an area''s weather.';
    last_line := 1;

    // Define the area?
    if area = s_oSelf then
        Tlilac.Declare(VAR_oSELF)
    else if area = s_oArea then begin
        new_lines[1] := s_oArea+' = '+s_GetObject + QuoteSwap(EditWeatherTagged.Text)+'");';
        last_line := 2;
    end;

    // Set the weather.
    new_lines[last_line] := 'SetWeather('+area+', '+weather+');';

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line);
end;


// Send NWScript to the script window for stripping a PC of possessions.
procedure Tmisc.SendStrip();
var
    chest_def, take_line: shortstring;

    start_line: integer;
    new_lines: array[0..7] of shortstring;
begin
    // Define how items will be made to disappear.
    if RadioStripChest.checked then begin
        chest_def := s_oTarget+' = '+s_GetObject + QuoteSwap(EditStripChest.text)+'");';
        take_line := s_AssignCommand + s_oTarget+', ActionTakeItem('+s_oItem+', '+
                                                                    s_oPC+'));';
    end
    else begin
        chest_def := '';
        take_line := 'DestroyObject('+s_oItem+');';
    end;


    // Stripping main inventory.
    if GroupWhatStrip.Checked[0] then begin
        // The opening comment.
        new_lines[0] := '// Relieve the PC of its possessions.';
        start_line := 1;

        // Define oTarget?
        if chest_def <> '' then begin
            new_lines[1] := chest_def;
            start_line := 2;
            // Save some effort later.
            chest_def := '';
        end;

        // The loop.
        new_lines[start_line+0] := s_oItem+' = GetFirstItemInInventory('+s_oPC+');';
        new_lines[start_line+1] := 'while ( '+s_oItem+' != '+s_OBJECT_INVALID+' )';
        new_lines[start_line+2] := '{';
        new_lines[start_line+3] := '    '+take_line;
        new_lines[start_line+4] := '    '+s_oItem+' = GetNextItemInInventory('+s_oPC+');';
        new_lines[start_line+5] := '}';

        // Add to the script window.
        Tlilac.AddLines(new_lines[0..start_line+5], start_line+3, start_line+3);
    end;


    // Stripping equipped inventory.
    if GroupWhatStrip.Checked[1] then begin
        // The opening comment.
        new_lines[0] := '// Relieve the PC of its equipment.';
        start_line := 1;

        // Define oTarget?
        if chest_def <> '' then begin
            new_lines[1] := chest_def;
            start_line := 2;
            // Save some effort later.
            chest_def := '';
        end;

        // The loop.
        new_lines[start_line+0] := s_nCount+' = NUM_INVENTORY_SLOTS;';
        new_lines[start_line+1] := 'while ( '+s_nCount+'-- > 0 )';
        new_lines[start_line+2] := '{';
        new_lines[start_line+3] := '    '+s_oItem+' = GetItemInSlot('+s_nCount+', '+s_oPC+');';
        new_lines[start_line+4] := '    '+take_line;
        new_lines[start_line+5] := '}';

        // Add to the script window.
        Tlilac.AddLines(new_lines[0..start_line+5], start_line+4, start_line+4);
    end;


    // Stripping gold.
    if GroupWhatStrip.Checked[2] then begin
        // The opening comment.
        new_lines[0] := '// Relieve the PC of its gold.';
        start_line := 1;

        // Define oTarget?
        if chest_def <> '' then begin
            new_lines[1] := chest_def;
            start_line := 2;
        end;

        // Take gold.
        new_lines[start_line] :=  'TakeGoldFromCreature(GetGold('+s_oPC+'), '+s_oPC;
        if RadioStripChest.Checked then
            new_lines[start_line] :=
                    s_AssignCommand + s_oTarget+', '+new_lines[start_line]+'));'
        else
            new_lines[start_line] := new_lines[start_line] + s_comma_TRUE+');';

        // Add to the script window.
        Tlilac.AddLines(new_lines[0..start_line], start_line, start_line);
    end;
end;


initialization
  {$i miscfunc.lrs}
end.
