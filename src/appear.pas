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
* Some of this was trimmed when I converted the form to being modal.
* Renamed most of the form elements and revised presentation.
* Added several 1.69 features.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit appear;


interface

uses
  {Windows,} {Messages,} SysUtils, Classes, {Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, ExtCtrls, start, nwn, Spin, Buttons,
  LResources, {ColorBox,} QueueForm;

type

  { Tappearance }

  Tappearance = class(TQueueForm)
      // Form elements
      ButtonColors: TBitBtn;
      CheckDescription: TCheckBox;
      CheckAppendName: TCheckBox;
      CheckName: TCheckBox;
      CheckAppendDescription: TCheckBox;
      CheckPortraitResRef: TCheckBox;
      CheckPortraitID: TCheckBox;
      CheckScaledAppearance: TCheckBox;
      CheckScaledWing: TCheckBox;
      CheckScaling: TCheckBox;
      CheckNormalAppearance: TCheckBox;
      CheckNormalWing: TCheckBox;
      CheckNormalTail: TCheckBox;
      ComboNormalAppearance: TComboBox;
      ComboNormalWing: TComboBox;
      ComboNormalTail: TComboBox;
      ComboScaledAppearance: TComboBox;
      ComboScaledWing: TComboBox;
      ComboAppearanceScaling: TComboBox;
      ComboSizeScaling: TComboBox;
      EditName: TEdit;
      EditPortraitResRef: TEdit;
      GroupCreatureOptions: TGroupBox;
      GroupNonItemOptions: TGroupBox;
      GroupNameDesc: TGroupBox;
      MemoDescription: TMemo;
      MemoPortraitResRef: TMemo;
      MemoPortraitID: TMemo;
      PanelPolyNote: TPanel;
    PanelAffectWho: TPanel;
    EditTagged: TEdit;
    PanelNameDesc: TPanel;
    PanelNormalAppearances: TPanel;
    PanelScaledAppearances: TPanel;
    PanelNonItemOptions: TPanel;
    RadioSpawn: TRadioButton;
    RadioIDDescription: TRadioButton;
    RadioActor: TRadioButton;
    RadioActivator: TRadioButton;
    RadioScriptItem: TRadioButton;
    RadioUnIDDescription: TRadioButton;
    RadioNormalAppearances: TRadioButton;
    RadioScaledAppearances: TRadioButton;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    SpinPortraitID: TSpinEdit;
    TextNameReversion: TStaticText;
    TextPolyNote: TStaticText;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ButtonColorsClick(Sender: TObject);
    procedure CheckNormalAppearanceChange(Sender: TObject);
    procedure CheckScalingChange(Sender: TObject);
    procedure ComboAppearanceScalingChange(Sender: TObject);
    procedure ComboNormalAppearanceChange(Sender: TObject);
    procedure CheckPortraitIDChange(Sender: TObject);
    procedure CheckPortraitResRefChange(Sender: TObject);
    procedure RadioPCChange(Sender: TObject);
    procedure RadioTypeChange(Sender: TObject);
    procedure SpinPortraitIDChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    // Feedback from the color window.
    HairColor: integer;
    SkinColor: integer;
    Tattoo1Color: integer;
    Tattoo2Color: integer;

  protected
    // Helper methods.
    procedure ClearForm(); override;
    procedure QueueThis(); override;
    procedure SendDescription(var new_lines:TStringAry; var last_line:integer;
                              const who:shortstring);
    procedure SendNormalAppearanceChanges(var new_lines:TStringAry;
                                          var last_line:integer; const who:shortstring);
    procedure SendScaledAppearanceChanges(var new_lines:TStringAry;
                                          var last_line:integer; const who:shortstring);
  end;


// -----------------------------------------------------------------------------
implementation

uses FileUtil, constants, ColorC;

const
    NUM_RACE_TAILS = 7; // The number of fixed race scalers for creature-tails.

    OBJECT_TYPE_CHANGEABLE = OBJECT_TYPE_CREATURE  or OBJECT_TYPE_ITEM or OBJECT_TYPE_TRIGGER or
                             OBJECT_TYPE_DOOR      or OBJECT_TYPE_AREA_OF_EFFECT or
                             OBJECT_TYPE_PLACEABLE;

// -----------------------------------------------------------------------------
// Prepares some elements.
procedure Tappearance.FormCreate(Sender: TObject);
begin
    // Initialize colors to none selected.
    HairColor    := -1;
    SkinColor    := -1;
    Tattoo1Color := -1;
    Tattoo2Color := -1;

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_TYPE_CHANGEABLE);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted, OBJECT_TYPE_CHANGEABLE);
    RadioScriptItem.Visible := main.GetIsItemScript();

    // Load some long lists and some shared lists.
    // (Easier to maintain the link to NWScript codes this way.)
    LoadConstants(ComboNormalAppearance.Items, APPEARANCE);
    LoadConstants(ComboNormalTail.Items, TAIL_TYPE_NORMAL);
    LoadConstants(ComboNormalWing.Items, WING_TYPE);
    LoadConstants(ComboScaledWing.Items, WING_TYPE);
    LoadConstants(ComboScaledAppearance.Items, TAIL_TYPE_SCALED);
    // Default these loaded lists to their first item.
    ComboNormalAppearance.ItemIndex := 0;
    ComboNormalTail.ItemIndex       := 0;
    ComboNormalWing.ItemIndex       := 0;
    ComboScaledWing.ItemIndex       := 0;
    ComboScaledAppearance.ItemIndex := 0;
end;


// Tells the script window to expect no more lines from us.
procedure Tappearance.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    Tlilac.AddLinesDone();
end;


// Opens the color-choosing window.
procedure Tappearance.ButtonColorsClick(Sender: TObject);
begin
    TColorCreature.NewModal(@HairColor, @SkinColor, @Tattoo1Color, @Tattoo2Color);
end;


// Handles checking/unchecking the normal appearance checkbox.
// Possibly enables/disables wing and tail selection as well as appearances.
procedure Tappearance.CheckNormalAppearanceChange(Sender: TObject);
begin
    // The appearance TComboBox is enabled iff the TCheckBox is checked.
    ComboNormalAppearance.Enabled := CheckNormalAppearance.Checked;

    if CheckNormalAppearance.Checked then
        // Let the combo box control the status of the other check boxes.
        ComboNormalAppearanceChange(Sender)
    else begin
        // The other check boxes should be enabled.
        CheckNormalWing.Enabled := true;
        CheckNormalTail.Enabled := true;
        ButtonColors.Enabled := true;
    end;
end;


// Handles checking/unchecking the scaling checkbox.
// Possibly enables/disables wing selection as well as scale choices.
procedure Tappearance.CheckScalingChange(Sender: TObject);
begin
    // The appearance scaling TComboBox is enabled iff the TCheckBox is checked.
    ComboAppearanceScaling.Enabled := CheckScaling.Checked;

    if CheckScaling.Checked then
        // Let the combo box control the status of the other controls.
        ComboAppearanceScalingChange(Sender)
    else begin
        // The wing check box should be enabled, while the scale size should not.
        CheckScaledWing.Enabled  := true;
        ComboSizeScaling.Enabled := false;
    end;
end;


// Disables the wing selection if this scaling appearance does not support it.
procedure Tappearance.ComboAppearanceScalingChange(Sender: TObject);
begin
    // This only matters if the scaling is slated to be changed.
    if not ComboAppearanceScaling.enabled then
        exit;

    // The first seven items do not support scale numbers; the rest do.
    // The first seven items do not support wings; the rest do.
    if ComboAppearanceScaling.ItemIndex >= NUM_RACE_TAILS then begin
        ComboSizeScaling.Enabled := true;
        CheckScaledWing.Enabled  := true;
    end
    else begin
        ComboSizeScaling.Enabled := false;
        CheckScaledWing.Checked  := false;
        CheckScaledWing.Enabled  := false;
    end;
end;


// Disables the wing and tail selections if this appearance does not support them.
procedure Tappearance.ComboNormalAppearanceChange(Sender: TObject);
var
    sCode: pChar;
begin
    // This only matters if the appearance is slated to be changed.
    if not ComboNormalAppearance.enabled then
        exit;
    // This only matters if an appearance is selected.
    if ComboNormalAppearance.ItemIndex < 0 then
        // Should be a temporary state; wait for the program to select something.
        exit;

    // Check the code for this appearance.
    sCode := ConstInfo(APPEARANCE, ComboNormalAppearance.ItemIndex);
    if (sCode = 'both') or (sCode = 'wing') then
        CheckNormalWing.Enabled := true
    else begin
        CheckNormalWing.Checked := false;
        CheckNormalWing.Enabled := false;
    end;

    if (sCode = 'both') or (sCode = 'tail') then
        CheckNormalTail.Enabled := true
    else begin
        CheckNormalTail.Checked := false;
        CheckNormalTail.Enabled := false;
    end;

    // And the color button -- all "both" appearances are part-based.
    ButtonColors.Enabled :=  sCode = 'both';
end;


// Handles visibility and enabling controls when a new portrait will be selected
// by ID.
procedure Tappearance.CheckPortraitIDChange(Sender: TObject);
begin
    // The controls directly based on CheckPortraitID:
    SpinPortraitID.Enabled := CheckPortraitID.Checked;
    MemoPortraitID.Visible := CheckPortraitID.Checked;

    // Cannot select by ID and ResRef at the same time.
    if CheckPortraitID.Checked then
        CheckPortraitResRef.Checked := false;
end;


// Handles visibility and enabling controls when a new portrait will be selected
// by ResRef.
procedure Tappearance.CheckPortraitResRefChange(Sender: TObject);
begin
    // The controls directly based on CheckPortraitResRef:
    EditPortraitResRef.Enabled := CheckPortraitResRef.Checked;
    MemoPortraitResRef.Visible := CheckPortraitResRef.Checked;

    // Cannot select by ResRef and ID at the same time.
    if CheckPortraitResRef.Checked then
        CheckPortraitID.Checked := false;

    // Update "Okay" buttons.
    ToggleOkay(Sender);
end;


// Emphasizes that PC names cannot be changed.
procedure Tappearance.RadioPCChange(Sender: TObject);
begin
    if RadioPC.Checked or RadioActivator.Checked then
        CheckName.Checked := false;
    CheckName.Enabled := not (RadioPC.Checked or RadioActivator.Checked);
end;


// Blocks options not applicable to the current selection.
procedure Tappearance.RadioTypeChange(Sender: TObject);
begin
    // Block the creature options for non-creatures.
    if RadioSpawn.Checked then
        GroupCreatureOptions.Enabled := 0 <> Tlilac.last_spawn_type and OBJECT_TYPE_CREATURE
    else
        GroupCreatureOptions.Enabled := not RadioScriptItem.Checked;

    // Block the non-item options for items.
    GroupNonItemOptions.Enabled := not RadioScriptItem.Checked;

    // Update the "Okay" buttons.
    ToggleOkay(Sender);
end;


// Some potential spiffy results of changing the chosen portrait ID.
procedure Tappearance.SpinPortraitIDChange(Sender: TObject);
var
    file_name: string;
    PortFile:  TFileStream;
    line_num:  integer;
    temp_char: char;
    portrait:  shortstring = '';
begin
    // This is just a nice little extra, so I'll go for the quicker route --
    // look for portraits .2da in source, rather than (more correctly)
    // digging through .key's and .bif's.
    file_name := AppendPathDelim(main.nwnloc+'source') + 'portraits.2da';
    if not fileexists(file_name) then
        exit;

    PortFile := TFileStream.Create(file_name, fmOpenRead or fmShareDenyWrite);

    // Skip ahead to the row corresponding to the selection. (The +3 is for headers.)
    line_num := SpinPortraitID.Value + 3;
    while (line_num > 0) and (PortFile.Position < PortFile.Size) do begin
        PortFile.Read(temp_char, sizeof(char));
        if temp_char = #10 then
            line_num -= 1;
    end;

    // Prepare to read the BaseResRef column (first after the row number).
    if PortFile.Position < PortFile.Size then
        PortFile.Read(temp_char, sizeof(char));
    // Skip any leading spaces.
    while ((temp_char = ' ') or (temp_char = #9)) and (PortFile.Position < PortFile.Size) do
        PortFile.Read(temp_char, sizeof(char));
    // Skip the row number.
    while ((temp_char <> ' ') and (temp_char <> #9)) and (PortFile.Position < PortFile.Size) do
        PortFile.Read(temp_char, sizeof(char));
    // Skip the spaces between columns
    while ((temp_char = ' ') or (temp_char = #9)) and (PortFile.Position < PortFile.Size) do
        PortFile.Read(temp_char, sizeof(char));

    // Read this column into a string.
    while ((temp_char <> ' ') and (temp_char <> #9)) and (PortFile.Position < PortFile.Size) do begin
        portrait += temp_char;
        PortFile.Read(temp_char, sizeof(char));
    end;

    // Done with the file.
    PortFile.Free();

    if (portrait <> '') and (portrait <> '****') then
        // Fill this into a text edit for the user's reference.
        EditPortraitResref.Text := 'po_'+portrait
    else
        EditPortraitResref.Text := '';
end;


// Controls the enabled state of the two "Okay" buttons based on the status of
// the rest of the form.
procedure Tappearance.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // Validate the creature to whom this will be assigned.
    if RadioTagged.Checked and (EditTagged.Text = '') then
        bEnable := false

    // Validate the portrait ResRef to be assigned.
    else if GroupNonItemOptions.Enabled  and  CheckPortraitResRef.Checked  and
            (EditPortraitResRef.Text = '') then
        bEnable := false

    // Passed!
    else
        bEnable := true;

    // Update the buttons' status.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------


// Resets the form so another appearance/name change can occur.
procedure Tappearance.ClearForm();
begin
    // Reset the color selection.
    HairColor    := -1;
    SkinColor    := -1;
    Tattoo1Color := -1;
    Tattoo2Color := -1;

    // Unselect the various check boxes.
    CheckNormalAppearance.checked  := false;
    CheckNormalWing.checked        := false;
    CheckNormalTail.checked        := false;

    CheckScaledAppearance.checked  := false;
    CheckScaling.checked           := false;
    CheckScaledWing.checked        := false;

    CheckPortraitID.checked        := false;
    CheckPortraitResRef.checked    := false;

    CheckName.checked              := false;
    CheckAppendName.Checked        := false;
    CheckDescription.checked       := false;
    CheckAppendDescription.Checked := false;

    // Reset the radio button.
    RadioNormalAppearances.Checked := true;
    RadioIDDescription.Checked     := true;

    // Blank the text edits.
    EditTagged.text         := '';
    EditPortraitResRef.text := '';
    EditName.Text           := '';
    // ... and blank some related controls.
    MemoDescription.Clear();
    SpinPortraitID.Value := 0;
end;


// Adds the designated changes to the script window.
// (Working out better than queueing it.)
procedure Tappearance.QueueThis();
var
    who:       TObjectEnum;
    who_var:   shortstring;
    who_looks: shortstring;
    add_in:    shortstring;

    start_line: integer;
    last_line:  integer;
    new_lines:  array of shortstring;
begin
    // Determine who to affect.
    who := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                           RadioTagged, RadioActor, RadioSpawn, FALSE);
    who_var := ObjectVar(who, s_oEventItem);

    // Some of the grammar depends on who was chosen.
    if who = E_CHOOSE_Self then
        who_looks := 'we look.'
    else
        who_looks := ObjectDesc(who, EditTagged.Text, false, 'the script''s item')+' looks.';

    // Allocate enough space (possibly) for the lines to add.
    // Figure: 10 options that can be changed, plus the comment
    // line, plus a line defining oTarget, plus the final parameter
    // to SetDescription(), and then a guess as to how many lines
    // we will need to transcribe the new description.
    SetLength(new_lines, 13 + MemoDescription.Lines.Count);


    // The intro comment.
    new_lines[0] := '// Change how '+who_looks;
    start_line := 1;

    // Do we need to define oTarget?
    if who = E_CHOOSE_Tagged then begin
        new_lines[1] := s_oTarget+' = '+s_GetObject+ QuoteSwap(EditTagged.Text)+'");';
        start_line := 2;
    end;

    // Switch from tracking the start line to tracking the last line.
    last_line := start_line - 1;

    // Creature options.
    if GroupCreatureOptions.Enabled then begin
        if RadioNormalAppearances.Checked then
            SendNormalAppearanceChanges(new_lines, last_line, who_var)
        else // Scaled appearances checked.
            SendScaledAppearanceChanges(new_lines, last_line, who_var)
    end;

    // Portrait changing (only one of ID and ResRef can be selected).
    if GroupNonItemOptions.Enabled then begin
        if CheckPortraitID.Checked then begin
            Inc(last_line);
            new_lines[last_line] := 'SetPortraitId('+who_var+', '+
                                    IntToStr(SpinPortraitID.Value)+');';
        end
        else if CheckPortraitResRef.Checked then begin
            Inc(last_line);
            new_lines[last_line] := 'SetPortraitResRef('+who_var+', "'+
                                    QuoteSwap(EditPortraitResRef.Text)+'");';
        end;
   end;

    // Name changing.
    if CheckName.Checked then begin
        if CheckAppendName.Checked and (EditName.text <> '') then
            add_in := 'GetName('+who_var+') + "'
        else
            add_in := '"';
        Inc(last_line);
        new_lines[last_line] := 'SetName('+who_var+', '+add_in +QuoteSwap(EditName.text)+'");';
   end;

    // Description changing.
    if CheckDescription.Checked then
        SendDescription(new_lines, last_line, who_var);

    // Time to acutally send this puppy off.
    // Wait... is there something to send off?
    if last_line >= start_line then begin
        Tlilac.AddLines(new_lines[0..last_line], start_line, last_line, true);
        // And do not forget that oSelf might need to be defined.
        if who = E_CHOOSE_Self then
            Tlilac.Declare(VAR_oSELF);
    end;
end;


// Adds the description changes to new_lines and updates last_line.
procedure Tappearance.SendDescription(var new_lines:TStringAry; var last_line:integer;
                                      const who:shortstring);
var
    memo_line: integer;
    add_in, id_flag: shortstring;

    memo_text:   ansistring; // Might need to be longer than 255 characters.
    memo_start:  integer;
    memo_length: integer;
begin
    // Set the identified parameter (for NWScript).
    if RadioUnIDDescription.Checked then
        id_flag := s_comma_FALSE
    else
        id_flag := '';

    // Do we insert the current description?
    if CheckAppendDescription.Checked then
        add_in := ' GetDescription('+who + s_comma_FALSE + id_flag+') +'
    else
        add_in := '';

    // Begin constructing the NWScript command.
    Inc(last_line);
    new_lines[last_line] := 'SetDescription('+who+',' + add_in;
    // We are now ready to insert what the user typed (followed by id_flag).
    // Should we do this in one line?
    if MemoDescription.Lines.Count = 0 then
        // Could not get shorter.
        new_lines[last_line] += ' ""'
    else if (MemoDescription.Lines.Count = 1) and
            (Length(MemoDescription.Lines[0]) < 40) then
        // Fairly short line.
        new_lines[last_line] += ' "'+QuoteSwap(MemoDescription.Lines[0])+'"'
    else begin
        // We will split the description over several lines.
        // This is a loop through 80-character splits of the memo lines.
        memo_line   := 0;
        memo_text   := '';
        memo_start  := 1;
        memo_length := 0;
        while memo_line < MemoDescription.Lines.Count do begin
            // Read the next line if we are ready for it.
            if memo_start > memo_length then begin
                memo_text := MemoDescription.Lines[memo_line];
                memo_start := 1;
                memo_length := Length(memo_text);
            end;

            // Make sure we have enough space.
            Inc(last_line);
            if last_line = Length(new_lines) then
                SetLength(new_lines, 2*last_line);

            // Add the next NWScript line.
            new_lines[last_line] := '               "' +
                                    QuoteSwap(copy(memo_text, memo_start, 80));

            // Update our loop controls.
            memo_start += 80;
            if memo_start > memo_length then
                Inc(memo_line);

            // How do we end this script line? (Is there more text?)
            if memo_line = MemoDescription.Lines.Count then
                new_lines[last_line] += '"'        // Done with the text.
            else if memo_start > memo_length then
                new_lines[last_line] += '\n" +'    // Starting a new line of text.
            else
                new_lines[last_line] += '" +';     // More text in this (input) line.
        end;//while
    end;//else long description.

    // Finish the last line.
    new_lines[last_line] += id_flag+');';
end;


// Adds the normal appearance changes to new_lines and updates last_line.
procedure Tappearance.SendNormalAppearanceChanges(var new_lines:TStringAry;
                                                  var last_line:integer;
                                                  const who:shortstring);
begin
    // Appearance changing.
    if CheckNormalAppearance.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetCreatureAppearanceType('+who+', '+
                SymConst(APPEARANCE, ComboNormalAppearance.ItemIndex)+');';
    end;

    // Wing changing.
    if CheckNormalWing.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetCreatureWingType('+
                SymConst(WING_TYPE, ComboNormalWing.ItemIndex)+', '+who+');';
    end;

    // Tail changing.
    if CheckNormalTail.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetCreatureTailType('+
                SymConst(TAIL_TYPE_NORMAL, ComboNormalTail.ItemIndex)+', '+who+');';
    end;

    if ButtonColors.Enabled then begin
        // Hair color.
        if HairColor >= 0 then begin
            Inc(last_line);
            new_lines[last_line] := 'SetColor('+who+', COLOR_CHANNEL_HAIR, '+
                                    IntToStr(HairColor)+');';
        end;

        // Skin color.
        if SkinColor >= 0 then begin
            Inc(last_line);
            new_lines[last_line] := 'SetColor('+who+', COLOR_CHANNEL_SKIN, '+
                                    IntToStr(SkinColor)+');';
        end;

        // Tattoo1 color.
        if Tattoo1Color >= 0 then begin
            Inc(last_line);
            new_lines[last_line] := 'SetColor('+who+', COLOR_CHANNEL_TATTOO_1, '+
                                    IntToStr(Tattoo1Color)+');';
        end;

        // Tattoo2 color.
        if Tattoo2Color >= 0 then begin
            Inc(last_line);
            new_lines[last_line] := 'SetColor('+who+', COLOR_CHANNEL_TATTOO_2, '+
                                    IntToStr(Tattoo2Color)+');';
        end;
    end;//if colors
end;


// Adds the scaled appearance changes to new_lines and updates last_line.
procedure Tappearance.SendScaledAppearanceChanges(var new_lines:TStringAry;
                                                  var last_line:integer;
                                                  const who:shortstring);
const
    // Conversion table for ComboAppearanceScaling.
    SCALE_BASE: array[0..21] of integer =
      ( 562,   // Horse, dwarf-sized
        563,   // Horse, elf-sized
        564,   // Horse, gnome-sized
        565,   // Horse, halfling-sized
        566,   // Horse, half-elf-sized
        567,   // Horse, half-orc-sized
        568,   // Horse, human-sized
        829,   // Simple animation set; scale:
        849,   // Large animtion set; scale:
        569,   // Dragon animation set; scale:
        589,   // Dwarf, female scale:
        709,   // Dwarf, male scale:
        609,   // Elf, female scale:
        729,   // Elf, male scale:
        629,   // Gnome, female scale:
        749,   // Gnome, male scale:
        649,   // Halfling, female scale:
        769,   // Halfling, male scale:
        669,   // Half-orc, female scale:
        789,   // Half-orc, male scale:
        689,   // Human female scale:
        809);  // Human, male scale:
var
    app_num: integer;
begin
    // Setting the scale.
    if CheckScaling.Checked then begin
        app_num := SCALE_BASE[ComboAppearanceScaling.ItemIndex];
        // Some bases have multiple scales.
        if ComboAppearanceScaling.ItemIndex >= NUM_RACE_TAILS then
            app_num += ComboSizeScaling.ItemIndex;
        // Now we have the appearance number to use.
        Inc(last_line);
        new_lines[last_line] := 'SetCreatureAppearanceType('+who+', '+
                                inttostr(app_num)+');';
    end;

    // Wing changing.
    if CheckScaledWing.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetCreatureWingType('+
            SymConst(WING_TYPE, ComboScaledWing.ItemIndex)+', '+who+');';
    end;

    // "Tail" (but appears to be appearance) changing.
    if CheckScaledAppearance.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SetCreatureTailType('+
                SymConst(TAIL_TYPE_SCALED, ComboScaledAppearance.ItemIndex)+
                ', '+who+');';
    end;
end;


initialization
  {$i appear.lrs}
end.
