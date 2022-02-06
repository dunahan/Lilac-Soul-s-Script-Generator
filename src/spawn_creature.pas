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
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit spawn_creature;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics,} Controls, Forms, {Dialogs,}
  StdCtrls, ExtCtrls, start, nwn, {ComCtrls,} Buttons,
  LResources, ExtForm;

type

  { Tcrspawn }

  Tcrspawn = class(TExtForm)
    // Form elements
    EditName: TEdit;
    GroupWhere: TGroupBox;
    Label1: TLabel;
    LabelName: TLabel;
    LabelQueue: TLabel;
    LabelVFX: TLabel;
    MemoQueue: TMemo;
    RadioActor: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    RadioPC: TRadioButton;
    RadioOwner: TRadioButton;
    RadioActivator: TRadioButton;
    StaticPalette: TStaticText;
    resref: TEdit;
    spawnaction: TRadioGroup;
    Memo1: TMemo;
    EditTagged: TEdit;
    ComboBox1: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    // Together with MemoQueue, these implement the creature queue.
    ListAction: array of integer;
    ListResRef: array of shortstring;
    ListVFX:    array of integer;
    ListWhere:  array of shortstring;

    // Private methods.
    procedure ClearForm();
    function  QueueSpawn(): boolean;
    procedure SendQueue();

  public
    // Methods made public so they can be shared by the placeable-spawning unit.
    class procedure SendSpawn(const sResRef: shortstring; const sType: shortstring;
                              const sWhere: shortstring;  nAction, nVFX: integer;
                              var new_lines: TStringAry;  var last_line:integer);
    class procedure SendSpawnForDelay(const sResRef: shortstring; const sType: shortstring;
                                      const sWhere: shortstring;  nAction, nVFX: integer;
                                      var new_lines: TStringAry;  var last_line:integer);
  end;


implementation

uses
    {event,} palettetool, {black_smith,}
    constants, LCLType;


const
    // The action-after-spawn options.
    SPAWN_AND_ATTACK = 0;
    SPAWN_AND_TALK   = 1;
    SPAWN_AND_NADA   = 2;


// -----------------------------------------------------------------------------


// Configures the form based on current circumstances.
procedure Tcrspawn.FormCreate(Sender: TObject);
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
procedure Tcrspawn.Button1Click(Sender: TObject);
begin
    if QueueSpawn() then
        ClearForm();
end;


// Handles clicks of the "Okay - exit" button.
procedure Tcrspawn.Button2Click(Sender: TObject);
begin
    if QueueSpawn() then
        SendQueue()
    else
        // Prevent this form from closing.
        ModalResult := mrNone;
end;


// Handles clicks of the "Close" button.
procedure Tcrspawn.Button3Click(Sender: TObject);
begin
    SendQueue();
end;


// Handles clicks of the "Palette" button.
procedure Tcrspawn.Button4Click(Sender: TObject);
begin
    // Call up the palette window, creatures by default.
    TPaletteWindow.Load(resref, EditName, SEARCH_CREATURES, true);
end;


// Enables/disables the "Okay" buttons as appropriate.
procedure Tcrspawn.ToggleOkay(Sender: TObject);
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
procedure Tcrspawn.ClearForm();
begin
    EditTagged.text := '';
end;


// Records the creature to spawn, for later batch processing.
function  Tcrspawn.QueueSpawn(): boolean;
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
    SetLength(ListAction, SpawnCount+1);
    SetLength(ListResRef, SpawnCount+1);
    SetLength(ListVFX,    SpawnCount+1);
    SetLength(ListWhere,  SpawnCount+1);

    // Record the specified info.
    if EditName.Text <> '' then
        MemoQueue.Append(EditName.Text)
    else
        MemoQueue.Append('"'+resref.text+'"');
    ListAction[SpawnCount] := spawnaction.itemindex;
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


// Adds lines to the script window to spawn the recorded creatures.
procedure Tcrspawn.SendQueue();
var
    nCritter: integer;
    last_critter: integer;

    last_line: integer;
    new_lines: array of shortstring;
begin
    last_critter := Length(ListResRef) - 1;

    // Abort if nothing to add.
    if last_critter < 0 then
        exit;

    // Allocate space (comment plus possibly six lines per creature).
    SetLength(new_lines, 2 + 6*Length(ListResRef));

    // The comment.
    if (last_critter = 0) and (MemoQueue.Lines.Count > 0) then begin
        new_lines[0] := '// Spawn '+MemoQueue.Lines[0]+'.';
        last_line := 0;
    end
    else begin
        new_lines[0] := '// Spawn some critters.';
        new_lines[1] := '';
        last_line := 1;
    end;


    // We need special handling (squeeze stuff onto one line) if this will be delayed.
    if Tlilac.MustReturnVoid() then begin
        // Loop through the creatures to spawn.
        for nCritter := 0 to last_critter do
            SendSpawnForDelay(ListResRef[nCritter], 'CREATURE', ListWhere[nCritter],
                              ListAction[nCritter], ListVFX[nCritter], new_lines,
                              last_line);
        // Remove the last blank line.
        Dec(last_line);
        // Add the lines to the script.
        Tlilac.AddLines(new_lines[0..last_line], 1, last_line);
    end

    else begin
        // Loop through the creatures to spawn.
        for nCritter := 0 to last_critter do
            SendSpawn(ListResRef[nCritter], 'CREATURE', ListWhere[nCritter],
                      ListAction[nCritter], ListVFX[nCritter], new_lines,
                      last_line);
        // Remove the last blank line.
        Dec(last_line);
        // Add the lines to the script.
        Tlilac.AddLines(new_lines[0..last_line]);

        // Update global tracking of the last spawn.
        Tlilac.last_spawn_type := OBJECT_TYPE_CREATURE;
        if MemoQueue.Lines.Count > last_critter then // Should always be the case, but MemoQueue is public...
            Tlilac.last_spawn := MemoQueue.Lines[last_critter]
        else
            Tlilac.last_spawn := ListResRef[last_critter];
    end;
end;


// Encapsulates the adding of a single spawn to the script window.
class procedure Tcrspawn.SendSpawn(const sResRef: shortstring; const sType: shortstring;
                                   const sWhere: shortstring;  nAction, nVFX: integer;
                                   var new_lines: TStringAry;  var last_line:integer);
var
    spawn_here: shortstring;
begin
    // Define a visual effect?
    if nVFX > 0 then begin
        Inc(last_line);
        new_lines[last_line] :=
            s_eVFX+' = '+s_EffectVisual + SymConst(VFX_IMPACT, nVFX)+');';
    end;

    // Determine where to do the spawn.
    if sWhere = s_lActTarget then
        spawn_here := s_lActTarget
    else if not StartsWith(sWhere, TAG_FLAG) then
        spawn_here := s_GetLocation + sWhere+')'
    else begin
        spawn_here := s_GetLocation + s_oTarget+')';
        // Also need to define oTarget; the waypoint tag is in sWhere after TAG_FLAG.
        Inc(last_line);
        new_lines[last_line] := s_oTarget+' = '+s_GetWaypoint+
                                copy(sWhere, 1+Length(TAG_FLAG), 32)+'");';     // Max tag length is 32.
    end;

    // Create the spawn.
    Inc(last_line);
    new_lines[last_line] := s_oSpawn+' = CreateObject(OBJECT_TYPE_'+sType+', '+
                            '"'+sResRef+'", '+spawn_here+');';

    // What will the spawn do?
    case nAction of
        SPAWN_AND_ATTACK: begin
                Tlilac.Include(INC_GENERIC);
                Inc(last_line);
                new_lines[last_line] := s_AssignCommand + s_oSpawn +
                                        ', DetermineCombatRound(oPC));';
            end;
        SPAWN_AND_TALK: begin
                Inc(last_line);
                new_lines[last_line] := s_AssignCommand + s_oSpawn +
                                        ', ActionStartConversation(oPC));';
            end;
        // else, do nothing.
    end;

    // Add a visual effect?
    if nVFX > 0 then begin
        Inc(last_line);
        new_lines[last_line] :=
            'DelayCommand(0.5, '+Script.ApplyEffect(s_eVFX, s_oSpawn, false)+');';
    end;

    // End with a blank line.
    Inc(last_line);
    new_lines[last_line] := '';
end;


// Encapsulates the adding of a single delayed spawn to the script window.
class procedure Tcrspawn.SendSpawnForDelay(const sResRef: shortstring; const sType: shortstring;
                                           const sWhere: shortstring;  nAction, nVFX: integer;
                                           var new_lines: TStringAry;  var last_line:integer);
var
    spawn_here: shortstring;
begin
    // Define a visual effect?
    if nVFX > 0 then begin
        Inc(last_line);
        new_lines[last_line] :=
            s_eVFX+' = '+s_EffectVisual + SymConst(VFX_IMPACT, nVFX)+');';
    end;

    // Determine where to do the spawn.
    if sWhere = s_lActTarget then
        spawn_here := s_lActTarget
    else if not StartsWith(sWhere, TAG_FLAG) then
        spawn_here := s_GetLocation + sWhere+')'
    else begin
        spawn_here := s_GetLocation + s_oTarget+')';
        // Also need to define oTarget; the waypoint tag is in sWhere after TAG_FLAG.
        Inc(last_line);
        new_lines[last_line] := s_oTarget+' = '+s_GetWaypoint+
                                copy(sWhere, 1+Length(TAG_FLAG), 32)+'");';     // Max tag length is 32.
    end;

    // The next part is a bit detailed as it could produce a multi-line instruction.

    // Decide how we will wrap this (in NWSCript) to have no return value.
    Inc(last_line);
    case nAction of
        SPAWN_AND_ATTACK, SPAWN_AND_TALK:
                    new_lines[last_line] := s_AssignCommand + 'CreateObject(';
        else begin
                    Tlilac.Include(INC_LUSKAN);
                    new_lines[last_line] := 'CreateObjectVoid(';
             end
    end;
    // Add the parameters to create the spawn and close the "CreateObject[Void]()" call.
    new_lines[last_line] += 'OBJECT_TYPE_'+sType+', "'+sResRef+'", '+spawn_here+')';

    // What will the spawn do after it spawns?
    // Also closes the "AssignCommand()" call (if applicable) and ends the line
    // with a semicolon.
    case nAction of
        SPAWN_AND_ATTACK: begin
                Tlilac.Include(INC_GENERIC);
                new_lines[last_line] += ',';
                Inc(last_line);
                new_lines[last_line] := '              DetermineCombatRound(oPC));';
            end;
        SPAWN_AND_TALK: begin
                new_lines[last_line] += ',';
                Inc(last_line);
                new_lines[last_line] := '              ActionStartConversation(oPC));';
            end;
        else    // Just finish the line.
                new_lines[last_line] += ';';
    end;

    // Add a visual effect?
    if nVFX > 0 then begin
        Inc(last_line);
        new_lines[last_line] :=
            'DelayCommand(0.5, '+Script.ApplyEffect(s_eVFX, spawn_here, true)+');';
    end;

    // End with a blank line.
    Inc(last_line);
    new_lines[last_line] := '';
end;


initialization
  {$i spawn_creature.lrs}
end.
