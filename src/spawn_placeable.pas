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
* Added some possibilities for scripts.
* Added visible queue.
* Cleanup of the generated scripts.

Actually, I prtty much ended up copying spawn_creature and changing a few
occurrences of "creature" to "placeable" -- the main difference between
spawning placeables and creatures is that creatures can be given an action.
If I wanted to spend even more time on this, I would look into a way to merge
these two units/forms.
Meh, if I had time I would probably merge more than that -- there is still
a lot of similar code in the different modules, but for now I am going to avoid
delving into how to share widgets in Lazarus -- too much potential for unforseen
problems (meaning delays).
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit spawn_placeable;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics,} Controls, Forms, {Dialogs,}
  StdCtrls, start, nwn, {ComCtrls,} Buttons, {ExtCtrls,}
  LResources, ExtForm;

type

  { Tplspawn }

  Tplspawn = class(TExtForm)
    // Form elements.
    EditName: TEdit;
    GroupWhere: TGroupBox;
    Label1: TLabel;
    LabelName: TLabel;
    LabelQueue: TLabel;
    LabelVFX: TLabel;
    Memo1: TMemo;
    MemoQueue: TMemo;
    RadioActor: TRadioButton;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    RadioActivator: TRadioButton;
    resref: TEdit;
    EditTagged: TEdit;
    TextPalette: TStaticText;
    ComboBox1: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    // Event handlers.
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    // Together with MemoQueue, these implement the placeable queue.
    ListResRef: array of shortstring;
    ListVFX:    array of integer;
    ListWhere:  array of shortstring;

    // Private methods.
    procedure ClearForm();
    function  QueueSpawn() : boolean;
    procedure SendQueue();
  end;


implementation

uses {event,} palettetool, {black_smith,}
    constants, LCLType, spawn_creature;

const
    // Copied from spawn_creature:
    SPAWN_AND_NADA   = 2;


// -----------------------------------------------------------------------------


procedure Tplspawn.FormCreate(Sender: TObject);
begin
    // Guarantee that we start with a 0-length array of ResRefs.
    // (The other arrays will be assumed the same length.)
    SetLength(ListResRef, 0);

    // Load the list of visual effects.
    LoadConstants(combobox1.Items, VFX_IMPACT);
    ComboBox1.ItemIndex := 0;

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, nil, RadioActor, OBJECT_TYPE_IN_AREA);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                              OBJECT_TYPE_IN_AREA, RadioTargeted);
end;


// Handles clicks of the "Okay - more" button.
procedure Tplspawn.Button1Click(Sender: TObject);
begin
    if QueueSpawn() then
        ClearForm();
end;


// Handles clicks of the "Okay - exit" button.
procedure Tplspawn.Button2Click(Sender: TObject);
begin
    if QueueSpawn() then
        SendQueue()
    else
        // Prevent this form from closing.
        ModalResult := mrNone;
end;


// Handles clicks of the "Close" button.
procedure Tplspawn.Button3Click(Sender: TObject);
begin
    SendQueue();
end;


// Handles clicks of the "Palette" button.
procedure Tplspawn.Button4Click(Sender: TObject);
begin
    // Call up the palette window, placeables by default.
    TPaletteWindow.Load(resref, EditName, SEARCH_PLACEABLES, true);
end;


// Enables/disables the "Okay" buttons as appropriate.
procedure Tplspawn.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // ResRef is required.
    if resref.Text = '' then
        bEnable := false

    // Waypoint tag is required if that option is selected.
    else
        bEnable := not RadioTagged.Checked or (EditTagged.Text <> '');

    // Configure buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------


// Resets the form so more spawns can be entered.
// LS had more stuff cleared, but I'd think some of the data has a decent chance
// of being re-used, so I'll only clear the destination waypoint tag. -- TK
procedure Tplspawn.ClearForm();
begin
    EditTagged.text := '';
end;


// Records the placeable to spawn, for later batch processing.
function  Tplspawn.QueueSpawn() : boolean;
var
    SpawnCount:  integer;
begin
    // Check for the one case that goes beyond the Script Generator's scope:
    // Spawning with a visual effect when we cannot define oSpawn (i.e. when delayed).
    if not (RadioTagged.Checked or RadioTargeted.Checked) and
       (ComboBox1.ItemIndex > 0) and Tlilac.MustReturnVoid() then
    begin
        result := Application.MessageBox(
                        'Because this will be delayed, the Script Generator only ' +
                        'supports visual effects when the spawn occurs at a waypoint.' +
                        #10#10 +
                        'Would you like to proceed without the visual effect?',
                        'Sorry', mb_YesNo) = IDYES;
        if result then
            ComboBox1.ItemIndex := 0
        else
            exit;
    end;

    // Find space to record the specified info.
    SpawnCount := Length(ListResRef);
    SetLength(ListResRef, SpawnCount+1);
    SetLength(ListVFX,    SpawnCount+1);
    SetLength(ListWhere,  SpawnCount+1);

    // Record the specified info.
    if EditName.Text <> '' then
        MemoQueue.Append(EditName.Text)
    else
        MemoQueue.Append('"'+resref.text+'"');
    ListResRef[SpawnCount] := QuoteSwap(resref.text);
    ListVFX   [SpawnCount] := combobox1.itemindex;
    if RadioTagged.Checked then
        ListWhere[SpawnCount] := TAG_FLAG + QuoteSwap(EditTagged.text)
    else if RadioPC.Checked then
        ListWhere[SpawnCount] := s_oPC
    else if RadioActivator.Checked then
        ListWhere[SpawnCount] := s_oActivator
    else if RadioTargeted.Checked then
        ListWhere[SpawnCount] := s_lActTarget
    else if RadioActor.Checked then
        ListWhere[SpawnCount] := s_oActor
    else begin // RadioOwner.Checked
        ListWhere[SpawnCount] := s_oSelf;
        Tlilac.Declare(VAR_oSELF);
    end;

    // Done.
    result := true;
end;


// Adds lines to the script window to spawn the recorded placeables.
procedure Tplspawn.SendQueue();
var
    nSpawn: integer;
    last_spawn: integer;

    last_line: integer;
    new_lines: array of shortstring;
begin
    last_spawn := Length(ListResRef) - 1;

    // Abort if nothing to add.
    if last_spawn < 0 then
        exit;

    // Allocate space (comment plus possibly six lines per placeable).
    // (Well, placeables won't use six lines, but it's not too gross an overestimate.)
    SetLength(new_lines, 2 + 6*Length(ListResRef));

    // The comment.
    if (last_spawn = 0) and (MemoQueue.Lines.Count > 0) then begin
        new_lines[0] := '// Spawn '+MemoQueue.Lines[0]+'.';
        last_line := 0;
    end
    else begin
        new_lines[0] := '// Spawn some placeables.';
        new_lines[1] := '';
        last_line := 1;
    end;

    // We need special handling (squeeze it all on one line) if this will be delayed.
    if Tlilac.MustReturnVoid() then begin
        // Loop through the creatures to spawn.
        for nSpawn := 0 to last_spawn do
            Tcrspawn.SendSpawnForDelay(ListResRef[nSpawn], 'PLACEABLE',
                                       ListWhere[nSpawn], SPAWN_AND_NADA,
                                       ListVFX[nSpawn], new_lines, last_line);
        // Remove the last blank line.
        Dec(last_line);
        // Add the lines to the script.
        Tlilac.AddLines(new_lines[0..last_line], 1, last_line);
    end

    else begin
        // Loop through the creatures to spawn.
        for nSpawn := 0 to last_spawn do
            Tcrspawn.SendSpawn(ListResRef[nSpawn], 'PLACEABLE', ListWhere[nSpawn],
                               SPAWN_AND_NADA, ListVFX[nSpawn], new_lines, last_line);
        // Remove the last blank line.
        Dec(last_line);
        // Add the lines to the script.
        Tlilac.AddLines(new_lines[0..last_line]);

        // Update global tracking of the last spawn.
        Tlilac.last_spawn_type := OBJECT_TYPE_PLACEABLE;
        if MemoQueue.Lines.Count > last_spawn then // Should always be the case, but MemoQueue is public...
            Tlilac.last_spawn := MemoQueue.Lines[last_spawn]
        else
            Tlilac.last_spawn := ListResRef[last_spawn];
    end;
end;


initialization
  {$i spawn_placeable.lrs}
end.
