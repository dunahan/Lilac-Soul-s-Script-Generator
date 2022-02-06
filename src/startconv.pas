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
* Added options for who starts the conversation.
* Removed the need to have a sound in the conversation in order to suppress the
*   opening greeting.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit startconv;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} {Forms,} {Dialogs,}
  StdCtrls, ExtCtrls, start, nwn, Buttons,
  LResources, ExtForm;

type

  { Tconversation }

  Tconversation = class(TExtForm)
    // Form elements
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckHello: TCheckBox;
    CheckPublic: TCheckBox;
    EditCustomConvo: TEdit;
    LabelConvo: TLabel;
    PanelConvo: TPanel;
    RadioTargeted: TRadioButton;
    RadioCustomConvo: TRadioButton;
    RadioDefaultConvo: TRadioButton;
    RadioActivator: TRadioButton;
    TextName: TLabeledEdit;
    RadioTagged: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioPC: TRadioButton;
    RadioOwner: TRadioButton;
    speakpanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    normpanel: TPanel;
    Label3: TLabel;
    EditTagged: TEdit;
    BitBtn3: TBitBtn;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure RadioPCChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure Button1Click(Sender: TObject);
  end;



// -----------------------------------------------------------------------------
implementation

uses {event,}
     constants;

const
    OBJECT_TALKABLE = OBJECT_TYPE_CREATURE  or OBJECT_TYPE_DOOR    or
                      OBJECT_TYPE_PLACEABLE or OBJECT_TYPE_TRIGGER;


// Configures the form for current circumstances.
procedure Tconversation.FormCreate(Sender: TObject);
begin
    // This form is disabled if the script would be called from a conversation.
    if main.GetIsConversation() then begin
        // Show the error message.
        speakpanel.visible := true;
        // Hide everything else.
        normpanel.visible  := false;
        PanelConvo.Visible := false;
        BitBtn1.Visible    := false;
        BitBtn2.Visible    := false;
        // No need to proceed any further.
        exit;
    end;

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, nil, OBJECT_TALKABLE);
    main.InitActivationRadios(RadioOwner, nil, RadioActivator, RadioTargeted, OBJECT_TALKABLE);
    // Item activation should default to the PC having a conversation with itself.
    if main.GetIsActivation() then
        RadioPC.Checked := true;
    // Check for having hidden the current selection.
    if RadioOwner.Checked and not RadioOwner.Visible then
        RadioTagged.Checked := true;

    // Possibly default to the last actor.
    EditTagged.Text := Tlilac.last_actor;
end;


// Blocks the default conversation file when a PC is talking to itself.
procedure Tconversation.RadioPCChange(Sender: TObject);
begin
    // The default convo should be neither enabled or selected when the selection
    // is the PC talking to itself.
    with RadioDefaultConvo do begin
        Enabled := not RadioPC.Checked;
        if not Enabled and Checked then
            RadioCustomConvo.Checked := true;
    end;

    // When talking to oneself, it usually not seen or heard by others.
    if RadioPC.Checked then begin
        CheckPublic.Checked := false;
        CheckHello.Checked  := false;
    end;

    // Update the "Okay" button.
    ToggleOkay(Sender);
end;


// Makes sure the "Okay" button is only enabled if all required info is supplied.
procedure Tconversation.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // If "tagged" is selected, then a tag must be supplied.
    if RadioTagged.Checked and (EditTagged.Text = '') then
        bEnable := false
    // If a custom convo file is requested, then its name must be supplied.
    else
        bEnable := not RadioCustomConvo.Checked or (EditCustomConvo.Text <> '');

    // Enable/disable the "Okay" button.
    BitBtn1.Enabled := bEnable;
end;


// Handles clicks of the "Okay" button.
procedure Tconversation.Button1Click(Sender: TObject);
var
    speaker: TObjectEnum;
    speaker_name, convo: shortstring;

    start_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    // Who will be speaking?
    speaker := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                               nil, RadioTagged, RadioSpawn);
    // Adjust for some special cases.
    case speaker of
        E_CHOOSE_Self:  Tlilac.Declare(VAR_oSELF);
        E_CHOOSE_Actor: Tlilac.last_actor := EditTagged.Text;
    end;

    // Possibly override the description.
    speaker_name := ObjectDesc(speaker, '');
    if RadioTagged.Checked  and  (TextName.Text <> '') then
        speaker_name := TextName.Text;

    // What will be said?
    if RadioDefaultConvo.checked then
        convo := ''
    else
        convo := QuoteSwap(EditCustomConvo.text);


    // -------------
    // The opening comment.
    if speaker = E_CHOOSE_PC then
        new_lines[0] := '// The PC holds an inner dialog.'
    else
        new_lines[0] := '// Have '+speaker_name+' strike up a conversation with the PC.';
    start_line := 1;

    // Possible definition of oActor.
    if speaker = E_CHOOSE_Actor then begin
        new_lines[1] := s_oActor+' = '+s_GetNearest + QuoteSwap(EditTagged.text)+'", '+
                                                      s_oPC+');';
        start_line := 2;
    end;

    // The instruction to start the conversation.
    new_lines[start_line] := Script.AssignCommand(speaker,
        Script.StartConvo(s_oPC, convo, not CheckPublic.checked, CheckHello.Checked))+';';

    // Add these lines.
    Tlilac.AddLines(new_lines[0..start_line], start_line, start_line);
end;


initialization
  {$i startconv.lrs}
end.

