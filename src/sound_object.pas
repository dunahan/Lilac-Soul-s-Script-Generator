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
*   of simulated modal.
* Added use of symbolic constants for ambient sounds.
* Added option to set the battle music.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit sound_object;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  Spin, StdCtrls, {ExtCtrls,} Buttons,
  LResources, ExtForm;

type

  { Tsoundobject }

  Tsoundobject = class(TExtForm)
    // Form elements
      CheckBox1: TCheckBox;
      CheckBox11: TCheckBox;
      CheckBox12: TCheckBox;
      CheckPlayBattle: TCheckBox;
      CheckStopBattle: TCheckBox;
      CheckBox2: TCheckBox;
      CheckBox3: TCheckBox;
      CheckBox7: TCheckBox;
      CheckBox8: TCheckBox;
      CheckDayMusic: TCheckBox;
      CheckBattleMusic: TCheckBox;
      CheckNightSounds: TCheckBox;
      CheckDaySounds: TCheckBox;
      CheckNightMusic: TCheckBox;
      CheckVolume: TCheckBox;
      ComboDaySounds: TComboBox;
      ComboDayMusic: TComboBox;
      ComboBattleMusic: TComboBox;
      ComboNightSounds: TComboBox;
      ComboNightMusic: TComboBox;
      Edit1: TEdit;
      GroupMusic: TGroupBox;
      GroupSoundObject: TGroupBox;
      GroupAmbiance: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    SpinVolume: TSpinEdit;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure ToggleOkay(Sender:TObject); override;
    procedure BitBtn1Click(Sender: TObject);

  private
    // Helper methods
    procedure HandleAmbientSounds();
    procedure HandleMusic();
    procedure HandleSoundObjects();
  end;

{var
  soundobject: Tsoundobject;
}

// -----------------------------------------------------------------------------
implementation

uses
    {event, start,} nwn,
    constants;


// Loads some data to the form from the constants unit.
procedure Tsoundobject.FormCreate(Sender: TObject);
begin
    // Load the ambient sounds.
    LoadConstants(ComboDaySounds.Items, AMBIENT_SOUND);
    LoadConstants(ComboNightSounds.Items, AMBIENT_SOUND);

    // Load the music tracks.
    LoadConstants(ComboDayMusic.Items, TRACK);
    LoadConstants(ComboNightMusic.Items, TRACK);
    LoadConstants(ComboBattleMusic.Items, TRACK);
end;


// Controls the enabled state of the "Okay" button.
procedure Tsoundobject.ToggleOkay(Sender: TObject);
var
    bEnable, bSelectionMade: Boolean;
begin
    bSelectionMade := false;

    // Sound object actions:
    // If actions are selected, a sound object must be provided, and vice versa.
    if  checkbox1.checked or checkbox2.checked or checkbox3.checked or CheckVolume.checked then
    begin
        bSelectionMade := true;
        bEnable := edit1.text <> '';
    end
    else
        bEnable := edit1.text = '';

    // The options with TComboBoxes require a selection.
    // (But a selection in the TComboBox does not require the option be chosen.)
    if bEnable and CheckDaySounds.checked then begin
        bSelectionMade := true;
        bEnable := ComboDaySounds.ItemIndex >= 0;
    end;
    if bEnable and CheckNightSounds.checked then begin
        bSelectionMade := true;
        bEnable := ComboNightSounds.ItemIndex >= 0;
    end;
    if bEnable and CheckDayMusic.checked then begin
        bSelectionMade := true;
        bEnable := ComboDayMusic.ItemIndex >= 0;
    end;
    if bEnable and CheckNightMusic.checked then begin
        bSelectionMade := true;
        bEnable := ComboNightMusic.ItemIndex >= 0;
    end;
    if bEnable and CheckBattleMusic.checked then begin
        bSelectionMade := true;
        bEnable := ComboBattleMusic.ItemIndex >= 0;
    end;
    // Well, it seems a read-only TComboBox always has a selection made; it
    // defaults to ItemIndex 0 when I had set it to -1. Oh well, there is no
    // harm in keeping the above, other than slightly more work for the computer,
    // and the logic is in place should a different widget set allow ItemIndex
    // to be -1.

    // Check the remaining options to see if something was selected.
    if bEnable and not bSelectionMade then
        bSelectionMade := checkbox7.checked       or checkbox8.checked  or
                          checkbox11.checked      or checkbox12.checked or
                          CheckPlayBattle.Checked or CheckStopBattle.Checked;

    // Update the button.
    BitBtn1.Enabled := bEnable and bSelectionMade;
end;


// Handles clicks of the "Okay" button.
procedure Tsoundobject.BitBtn1Click(Sender: TObject);
begin
    // Split this into three pieces.
    HandleAmbientSounds();
    HandleMusic();
    HandleSoundObjects();

    // Tell Tlilac that we are done.
    Tlilac.AddLinesDone();
end;


// -----------------------------------------------------------------------------


// Adds lines to the script window (if requested) that change the ambient sounds
// of the PC's area.
procedure Tsoundobject.HandleAmbientSounds();
var
    last_line: integer;
    new_lines: array[0..4] of shortstring;
begin
    // Quick abort if there is nothing to do.
    if not ( CheckDaySounds.checked or CheckNightSounds.checked or
             checkbox7.checked      or checkbox8.checked ) then
        exit;

    // The opening comment.
    new_lines[0] := '// Make changes to the PC''s area''s ambient sounds.';
    last_line := 0;

    // Stopping the sounds.
    if checkbox8.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'AmbientSoundStop('+s_GetAreaPC+');';
    end;

    // Setting the daytime sounds.
    if CheckDaySounds.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'AmbientSoundChangeDay('+s_GetAreaPC+', '+
                                SymConst(AMBIENT_SOUND, ComboDaySounds.ItemIndex)+');';
    end;

    // Setting the nighttime sounds.
    if CheckNightSounds.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'AmbientSoundChangeNight('+s_GetAreaPC+', '+
                                SymConst(AMBIENT_SOUND, ComboNightSounds.ItemIndex)+');';
    end;

    // Starting the sounds.
    if checkbox7.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'AmbientSoundPlay('+s_GetAreaPC+');';
    end;

    // Send this to the script window.
    Tlilac.AddLines(new_lines[0..last_line], 1, last_line, true);
end;


// Adds lines to the script window (if requested) that change the background music
// of the PC's area.
procedure Tsoundobject.HandleMusic();
var
    last_line: integer;
    new_lines: array[0..7] of shortstring;
begin
    // Quick abort if there is nothing to do.
    if not ( CheckDayMusic.checked    or CheckNightMusic.checked or
             checkbox11.checked       or checkbox12.checked or
             CheckBattleMusic.Checked or
             CheckPlayBattle.Checked  or CheckStopBattle.Checked ) then
        exit;

    // The opening comment.
    new_lines[0] := '// Make changes to the PC''s area''s background music.';
    last_line := 0;


    // Stopping the background music.
    if checkbox12.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'MusicBackgroundStop('+s_GetAreaPC+');';
    end;

    // Setting the daytime music.
    if CheckDayMusic.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'MusicBackgroundChangeDay('+s_GetAreaPC+', '+
                                SymConst(TRACK, ComboDayMusic.ItemIndex)+');';
    end;

    // Setting the nighttime music.
    if CheckNightMusic.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'MusicBackgroundChangeNight('+s_GetAreaPC+', '+
                                SymConst(TRACK, ComboNightMusic.ItemIndex)+');';
    end;

    // Stopping the battle music.
    if CheckStopBattle.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'MusicBattleStop('+s_GetAreaPC+');';
    end;

    // Setting the battle music.
    if CheckBattleMusic.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'MusicBattleChange('+s_GetAreaPC+', '+
                                SymConst(TRACK, ComboBattleMusic.ItemIndex)+');';
    end;
    // Starting the background music.
    if checkbox11.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'MusicBackgroundPlay('+s_GetAreaPC+');';
    end;

    // Starting the battle music.
    if CheckPlayBattle.Checked then begin
        Inc(last_line);
        new_lines[last_line] := 'MusicBattlePlay('+s_GetAreaPC+');';
    end;

    // Send this to the script window.
    Tlilac.AddLines(new_lines[0..last_line], 1, last_line, true);
end;


// Adds lines to the script window (if requested) that change the sound object
// identified in the form.
procedure Tsoundobject.HandleSoundObjects();
var
    last_line: integer;
    new_lines: array[0..5] of shortstring;
begin
    // Quick abort if there is nothing to do.
    if not ( checkbox1.checked or checkbox2.checked or
             checkbox3.checked or CheckVolume.checked ) then
        exit;

    // The opening comment & definition of oTarget.
    new_lines[0] := '// Make changes to the sound object "'+Edit1.Text+'.';
    new_lines[1] := s_oTarget+' = '+s_GetObject + QuoteSwap(edit1.text)+'");';
    last_line := 1;

    // Stopping the object.
    if checkbox3.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SoundObjectStop('+s_oTarget+');';
    end;

    // Setting the object's position.
    if checkbox1.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SoundObjectSetPosition('+s_oTarget+', '+
                                'GetPosition('+s_oPC+'));';
    end;

    // Setting the volume of the object.
    if CheckVolume.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SoundObjectSetVolume('+s_oTarget+', '+
                                inttostr(SpinVolume.value)+');';
    end;

    // Playing the object.
    if checkbox2.checked then begin
        Inc(last_line);
        new_lines[last_line] := 'SoundObjectPlay('+s_oTarget+');';
    end;

    // Send this to the script window.
    Tlilac.AddLines(new_lines[0..last_line], 2, last_line, true);
end;


initialization
  {$i sound_object.lrs}
end.
