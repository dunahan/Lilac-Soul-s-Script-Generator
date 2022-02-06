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
* Merged the nonpcgive unit into this one.
* Some of this was trimmed when I converted the forms to being modal (and when I
*   converted simulated radio buttons into actual radio buttons).
* Added some possibilities for scripts.
* Added visible queue.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit itemxp_give;


interface

uses
  {Windows,} {Messages,} SysUtils,  {Classes, Graphics, Controls,} Forms, {Dialogs,}
  Spin, StdCtrls, {ExtCtrls, Spin,} start, nwn, Buttons,
  LResources, QueueForm, Classes;

type

  { Tgiveitem }

  Tgiveitem = class(TQueueForm)
    // Form elements.
    CheckPartyGold: TCheckBox;
    CheckPartyXP: TCheckBox;
    EditName: TEdit;
    goldgive: TSpinEdit;
    GroupRecipient: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    LabelQueue: TLabel;
    Label2: TLabel;
    LabelName: TLabel;
    MemoQueue: TMemo;
    EditTagged: TEdit;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioTargeted: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioTagged: TRadioButton;
    RadioActor: TRadioButton;
    RadioActivator: TRadioButton;
    resrefgive: TEdit;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    TextPalette: TStaticText;
    XPgive: TSpinEdit;
    // Event handlers.
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Button4Click(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    // Together with MemoQueue, these implement the item queue.
    ListResRef: array of shortstring;
    ListGold:   array of integer;
    ListXP:     array of integer;
    ToWhom: shortstring;

  protected
    procedure ClearForm(); override;
    procedure QueueThis(); override;
    procedure SendQueue(); override;
  end;


// -----------------------------------------------------------------------------
implementation

uses {event,} palettetool,
     constants;

const
    OBJECT_WITH_INVENTORY = OBJECT_TYPE_CREATURE or OBJECT_TYPE_PLACEABLE or
                            OBJECT_TYPE_STORE;


// Configures the form based on current circumstances.
procedure Tgiveitem.FormCreate(Sender: TObject);
begin
    // Initialize fields.
    SetLength(ListResRef, 0); // The other arrays are assumed the same length.
    ToWhom := '';

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_WITH_INVENTORY);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted, OBJECT_WITH_INVENTORY);
end;


// Informs Tlilac that there will be no more lines from us.
procedure Tgiveitem.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    Tlilac.AddLinesDone();
end;


// Handles clicks of the "Palette" button.
procedure Tgiveitem.Button4Click(Sender: TObject);
begin
    // Call up the palette window, items by default.
    TPaletteWindow.Load(resrefgive, EditName, SEARCH_ITEMS, true);
end;


// Controls the enabled state of the "Okay" buttons.
procedure Tgiveitem.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // See if required information has been provided.
    if (xpgive.value = 0) and (goldgive.value = 0) and (resrefgive.text = '') then
        bEnable := FALSE
    else
        bEnable := not RadioTagged.Checked or (EditTagged.Text <> '');

    // Enable the "Okay" buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------

// Clears (some of) the form so a new item can be entered.
procedure Tgiveitem.ClearForm();
begin
    EditName.Text   := '';
    resrefgive.text := '';
    goldgive.value  := 0;
    XPgive.value    := 0;
    CheckPartyGold.Checked := false;
    CheckPartyXP.Checked   := false;
    // Reset the focus as well.
    resrefgive.SetFocus();

    // Disable the "Okay" buttons.
    ToggleOkay(resrefgive);
end;


// Stores the provided information in the queue for later batch processing.
procedure Tgiveitem.QueueThis();
var
    give_code: TObjectEnum;
    give_to:   shortstring;
    num_items: integer;

    gold_append: shortstring = '';
    XP_append:   shortstring = '';
begin
    // Who is receiving this?
    give_code := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                                 RadioTagged, RadioActor, RadioSpawn, FALSE);
    if give_code = E_CHOOSE_Tagged then
        give_to := TAG_FLAG + QuoteSwap(EditTagged.text)
    else
        give_to := ObjectVar(give_code);

    // Send out a batch of NWScript if this is going to a new object.
    if give_to <> ToWhom then begin
        SendQueue();
        MemoQueue.Clear();
        SetLength(ListResRef, 0);
        ToWhom := give_to;
    end;

    // Save the current info.
    num_items := Length(ListResRef);
    SetLength(ListResRef, num_items+1);
    SetLength(ListGold,   num_items+1);
    SetLength(ListXP,     num_items+1);
    ListResRef[num_items] := QuoteSwap(resrefgive.text);
    ListGold[num_items]   := goldgive.value;
    ListXP[num_items]     := xpgive.value;
    // Flag the numeric values for party-wide by making them negative.
    if CheckPartyGold.Checked then begin
        ListGold[num_items] := -ListGold[num_items];
        gold_append := ' (to party)';
    end;
    if CheckPartyXP.Checked then begin
        ListXP[num_items] := -ListXP[num_items];
        XP_append := ' (to party)';
    end;

    // Feedback for the user.
    if goldgive.Value > 0 then
        MemoQueue.Append(IntToStr(goldgive.Value) + ' gold' + gold_append);
    if XPgive.Value > 0 then
        MemoQueue.Append(IntToStr(XPgive.Value) + ' experience' + XP_append);
    if ResRefGive.Text <> '' then begin
        if EditName.Text <> '' then
            MemoQueue.Append(EditName.Text)
        else
            MemoQueue.Append('"'+ResRefGive.Text+'"');
    end;
end;


// Converts the stored information to NWScript and sends it to the script window.
procedure Tgiveitem.SendQueue();
var
    item_prefix: shortstring = '';
    item_suffix: shortstring = '';
    sTag, give_to: shortstring;
    whom, what: shortstring;
    nItem, last_item: integer;

    start_line, last_line: integer;
    new_lines: array of shortstring;
begin
    last_item := Length(ListResRef) - 1;
    // Make sure there is something to send.
    if last_item < 0 then
        exit;

    // Extract the tag (for readability -- will be ignored if no tag is stored).
    sTag := copy(ToWhom, 1+Length(TAG_FLAG), 32);   // Max length of a tag is 32.

    // Wrapper for item-giving script lines.
    if Tlilac.MustReturnVoid() then begin
        Tlilac.DefineFunc(FUNC_OBJ_VOID);
        item_prefix := 'ObjectToVoid(';
        item_suffix := ')';
    end;


    // To whom do we send this?
    if not StartsWith(ToWhom, TAG_FLAG) then
        give_to := ToWhom
    else
        give_to := s_oTarget;
    // Make sure oSelf is defined, if needed.
    if give_to = s_oSelf then
        Tlilac.Declare(VAR_oSELF);

    // Allocate space (comment, oTarget defnition, plus three lines per item).
    SetLength(new_lines, 2 + 3*(1+last_item));

    // Prepare the opening comment.
    if (last_item = 0) and (MemoQueue.Lines.Count > 0) then
        what := MemoQueue.Lines[0]
    else
        what := 'stuff';
    // How to describe the target in the opening comment.
    if      give_to = s_oSelf      then  whom := 'us'
    else if give_to = s_oPC        then  whom := 'the PC'
    else if give_to = s_oActivator then  whom := 'the item activator'
    else if give_to = s_oActTarget then  whom := 'the activation target'
    else if give_to = s_oSpawn     then  whom := Tlilac.last_spawn
    else if give_to = s_oActor     then  whom := Tlilac.last_actor
    else                                 whom := '"'+sTag+'"';
    // Now the actual comment.
    new_lines[0] := '// Give '+what+' to '+whom+'.';
    start_line := 1;

    // Define oTarget?
    if give_to = s_oTarget then begin
        new_lines[1] := s_oTarget+' = '+s_GetObject + sTag + '");';
        start_line := 2;
    end;
    last_line := start_line - 1;


    // Loop through the items to create.
    for nItem := 0 to last_item do begin
        // GOLD:
        if ListGold[nItem] <> 0 then begin
            Inc(last_line);
            if ListGold[nItem] > 0 then
                new_lines[last_line] := 'GiveGoldToCreature('+give_to+', '+
                                         IntToStr(ListGold[nItem])+');'
            else begin
                // Partywide
                Tlilac.Include(INC_PARTYWIDE);
                new_lines[last_line] := 'GiveGoldToAll('+give_to+', '+
                                         IntToStr(-ListGold[nItem])+');';
            end;
        end;

        // XP:
        if ListXP[nItem] <> 0 then begin
            Inc(last_line);
            if ListXP[nItem] > 0 then
                new_lines[last_line] := 'GiveXPToCreature('+give_to+', '+
                                         IntToStr(ListXP[nItem])+');'
            else begin
                // Partywide
                Tlilac.Include(INC_PARTYWIDE);
                new_lines[last_line] := 'GiveXPToAll('+give_to+', '+
                                         IntToStr(-ListXP[nItem])+');';
            end;
        end;

        // ITEM:
        if ListResRef[nItem] <> '' then begin
            Inc(last_line);
            new_lines[last_line] := item_prefix +
                                    'CreateItemOnObject("'+ListResRef[nItem]+'", '+
                                    give_to+')'+item_suffix+';';
        end;
    end;//for nItem

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], start_line, last_line, true);
end;


initialization
  {$i itemxp_give.lrs}
end.
