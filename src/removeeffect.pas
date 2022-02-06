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
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit removeeffect;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls, Forms,}
  {Dialogs,} StdCtrls, {ExtCtrls,} Buttons,
  LResources, QueueForm;

type

  { TRemEffect }

  TRemEffect = class(TQueueForm)
    // Form elements
    EditTagged: TEdit;
    GroupRemoveFrom: TGroupBox;
    LabelEffect: TLabel;
    RadioActivator: TRadioButton;
    RadioActor: TRadioButton;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    effectlist: TComboBox;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    // The queued removals.
    ListIndices: array of integer;
    ListTargets: array of shortstring;

  protected
    // Helper methods.
    procedure ClearForm(); override;
    procedure QueueThis(); override;
    procedure SendQueue(); override;
  end;


implementation

uses {event,} start, nwn,
     constants;

const
    OBJECT_TYPE_AFFECTABLE = OBJECT_TYPE_CREATURE or OBJECT_TYPE_DOOR or
                             OBJECT_TYPE_PLACEABLE;


// -----------------------------------------------------------------------------


procedure TRemEffect.FormCreate(Sender: TObject);
begin
    // Initialize the queue. (Both arrays are assumed the same length, so only
    // one needs to be set. Well, maybe none *need* to be set, but I like
    // explicit initializations.)
    SetLength(ListIndices, 0);

    // Load the list of effect types.
    LoadConstants(EffectList.Items, EFFECT_TYPE);

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_TYPE_AFFECTABLE);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted, OBJECT_TYPE_AFFECTABLE);

    // Make sure a visible option is selected.
    with RadioPC do
        if Checked and not Visible then
            RadioTagged.Checked := TRUE;
end;


// Handles the enabled state of the "Okay" buttons.
procedure TRemEffect.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // We need an effect type selected.
    if effectlist.ItemIndex < 0 then
        bEnable := false
    else
        // Tagged targets require a tag.
        bEnable := not RadioTagged.Checked or (EditTagged.Text <> '');

    // Update the buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------


// Resets the form for additional submissions.
procedure TRemEffect.ClearForm();
begin
    EffectList.ItemIndex:=-1;
    ToggleOkay(EffectList);
end;


// Records the target/effect type pair for later batch processing.
procedure TRemEffect.QueueThis();
var
   target:  TObjectEnum;
   nLength: integer;
begin
    // Who has the effect to remove?
    target := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                         RadioTagged, RadioActor, RadioSpawn, FALSE);
    // Declare a variable if needed.
    if target = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // Allocate space on the queue.
    nLength := Length(ListIndices);
    SetLength(ListIndices, nLength+1);
    SetLength(ListTargets, nLength+1);

    // Save this.
    ListIndices[nLength] := EffectList.ItemIndex;
    if target = E_CHOOSE_Tagged then
        ListTargets[nLength] := TAG_FLAG + QuoteSwap(EditTagged.text)
    else
        ListTargets[nLength] := ObjectVar(target);
end;


// Sends the stored effect removals to the script window.
procedure TRemEffect.SendQueue();
var
    nCount: integer;
    target, effect: shortstring;

    last_line: integer;
    new_lines: array of shortstring;
begin
    // Abort if there is nothing to send.
    if Length(ListIndices) < 1 then
        exit;

    // Allocate space for all potential lines and start with a comment.
    SetLength(new_lines, 1 + 2*Length(ListIndices));
    new_lines[0] := '// Remove all effects of a specified type.';
    last_line := 0;

    // Loop through the queue.
    for nCount := 0 to High(ListIndices) do begin
        // Retrieve the target.
        if not StartsWith(ListTargets[nCount], TAG_FLAG) then
            target := ListTargets[nCount]
        else begin
            target := s_oTarget;
            // We need to define oTarget; the tag is stored after TAG_FLAG.
            Inc(last_line);
            new_lines[last_line] := s_oTarget+' = '+s_GetObject +
                    copy(ListTargets[nCount], 1+Length(TAG_FLAG), 32)+'");';    // 32 is the maximum tag length.
        end;

        // Retrieve the effect.
        effect := SymConst(EFFECT_TYPE, ListIndices[nCount]);

        // Add the effect-removing line.
        Inc(last_line);
        new_lines[last_line] := 'RemoveSpecificEffect('+effect+', '+target+');';
    end;

    // Send this off to the script window.
    Tlilac.Include(INC_SPELLS);
    Tlilac.AddLines(new_lines[0..last_line], 1, last_line);
end;


initialization
  {$i removeeffect.lrs}
end.
