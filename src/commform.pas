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
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit commform;  // That is "comm" as in "communication", not "common".


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, ExtCtrls, Buttons,
  LResources, QueueForm;

type

  { Tcommunicationform }

  Tcommunicationform = class(TQueueForm)
    // Form elements
      ComboQChat: TComboBox;
      EditTagged: TEdit;
      GroupSpeaker: TGroupBox;
      LabelQChat: TLabel;
    PanelText: TPanel;
    Label1: TLabel;
    PanelDefault: TPanel;
    PanelFloatText: TPanel;
    PanelSpeaker: TPanel;
    GroupPartywide: TRadioGroup;
    PanelQChat: TPanel;
    RadioActivator: TRadioButton;
    RadioActor: TRadioButton;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    receiver: TRadioGroup;
    TextTokens: TStaticText;
    tospeak: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    volume: TLabel;
    volumebox: TComboBox;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure receiverClick(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  protected
    // Helper methods
    procedure ClearForm(); override;
    procedure QueueThis(); override;
  end;

{var
  communicationform: Tcommunicationform;
}

// -----------------------------------------------------------------------------
implementation

uses
    {event,} start, nwn,
    constants;

const
    // Technically, other types of objects -- such as triggers -- can speak, but
    // it's easier to exclude them here than to try to explain to the user the
    // intricacies of when such speaking works. Besides, such speaking is rare.
    OBJECT_TYPE_CAN_SPEAK = OBJECT_TYPE_CREATURE        or
                            OBJECT_TYPE_DOOR            or
                            OBJECT_TYPE_AREA_OF_EFFECT  or
                            OBJECT_TYPE_PLACEABLE;

// -----------------------------------------------------------------------------


// Configures the form based on current circumstances.
procedure Tcommunicationform.FormCreate(Sender: TObject);
begin
    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_TYPE_CAN_SPEAK);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted, OBJECT_TYPE_CAN_SPEAK);

    // Make sure a visible choice is the default selection.
    if RadioOwner.Checked and not RadioOwner.Visible then
        RadioTagged.Checked := true;
end;


// A bit of cleanup when the form closes.
procedure Tcommunicationform.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    // Let Tlilac know that we are done.
    Tlilac.AddLinesDone();
end;


// Controls sub-panel visibility based on what action was selected.
procedure Tcommunicationform.receiverClick(Sender: TObject);
var
    iSelection: integer;
begin
    iSelection := receiver.itemindex;

    PanelText.Visible  := iSelection <> 4;
    PanelQChat.Visible := iSelection = 4;

    PanelFloatText.Visible  := iSelection = 2;
    PanelSpeaker.Visible    := iSelection > 2;
    volumebox.Enabled := iSelection = 3;

    // Daisy-chain to the "okay" button enabler.
    ToggleOkay(Sender);
end;


// Controls the enabled state of the "Okay" buttons.
procedure Tcommunicationform.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // A tagged object requires a tag.
    if PanelSpeaker.Visible and RadioTagged.Checked and (EditTagged.Text = '') then
        bEnable := false

    // A message must be specified.
    else if PanelText.Visible then
        bEnable := tospeak.text <> ''
    else // PanelQChat.Visible
        bEnable := ComboQChat.ItemIndex >= 0;

    // Update the "Okay" buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------


// Clears the form so more messages can be sent.
procedure Tcommunicationform.ClearForm();
begin
    tospeak.text := '';
    ComboQChat.ItemIndex := -1;
    // LS had a bunch more stuff reset, but I think some of that has a good
    // chance of being reused. Just clear the text so the user can see some
    // result of clicking "Okay - and more".
end;


// Sends the requested scripting to the script window (no actual queue used).
procedure Tcommunicationform.QueueThis();
var
    speaker:      TObjectEnum;
    msg, tmp_msg: shortstring;
    new_lines:    array[0..1] of shortstring;
begin
    // Prepare the message to be sent.
    if not PanelText.Visible then
        msg := SymConst(VOICE_CHAT, ComboQChat.ItemIndex)
    else begin
        // The " character is not allowed, so replace it with the ' character.
        msg := QuoteSwap(tospeak.text);

        // Support some special tokens (not case-sensitive).
        tmp_msg := StringReplace(msg, '<PC>', '" + GetName('+s_oPC+') + "', [rfReplaceAll, rfIgnoreCase]);
        msg := StringReplace(tmp_msg, '<ME>', '" + GetName('+s_oSelf+') + "', [rfReplaceAll, rfIgnoreCase]);

        // Did we use oSelf?
        if msg <> tmp_msg then
            Tlilac.Declare(VAR_oSELF);
    end;

    // The NWScript:
    case receiver.itemindex of
        0: begin
            new_lines[0] := '// Write a message to the system log.';
            new_lines[1] := 'WriteTimestampedLogEntry("'+msg+'");';
        end;
        1: begin
            new_lines[0] := '// Send a message to the player''s chat window.';
            new_lines[1] := 'SendMessageToPC('+s_oPC+', "'+msg+'");';
        end;
        2: begin
            new_lines[0] := '// Have text appear over the PC''s head.';
            new_lines[1] := 'FloatingTextStringOnCreature("'+msg+'", '+s_oPC+
                            BoolToStr(GroupPartywide.ItemIndex = 0, '', s_comma_FALSE)+');';
        end;
        3, 4: begin
            // Get the speaker; nil for RadioTagged because we want to override the variable.
            speaker := GetChosenObject(RadioOwner, RadioPC, RadioActivator,
                                       RadioTargeted, nil, RadioActor, RadioSpawn);
            // Declare a variable if needed.
            if speaker = E_CHOOSE_Self then
                Tlilac.Declare(VAR_oSELF);

            new_lines[0] := '// Have '+ObjectDesc(speaker, '', FALSE, '"'+EditTagged.text+'"')+
                            ' say something.';
            if receiver.itemindex = 3 then // Speak text
                new_lines[1] := Script.AssignCommand(speaker,
                                    Script.SpeakString(msg, volumebox.itemindex),
                                    s_GetObject + QuoteSwap(EditTagged.text)+'")')
                                +';'
            else // Quick chat
                new_lines[1] := Script.PlayVoicechat(msg, speaker,
                                    s_GetObject + QuoteSwap(EditTagged.text)+'")')
                                +';';
        end;
    end;
    Tlilac.AddLines(new_lines, 1, 1, TRUE);
end;


initialization
  {$i commform.lrs}
end.
