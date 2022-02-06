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
* Some of this was trimmed when I converted the forms to being modal.
* Added some options for whom to take from.
* Added visible queue.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit itemxp_take;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, {ExtCtrls,} Spin, start, nwn, Buttons,
  LResources, QueueForm;

type

  { Ttakestuff }

  Ttakestuff = class(TQueueForm)
    // Form elements.
    CheckPartyGold: TCheckBox;
    CheckPartyXP: TCheckBox;
    EditName: TEdit;
    EditTagged: TEdit;
    GroupTarget: TGroupBox;
    Label1: TLabel;
    LabelAllGold: TLabel;
    LabelName: TLabel;
    LabelQueue: TLabel;
    MemoQueue: TMemo;
    RadioActivator: TRadioButton;
    RadioActor: TRadioButton;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    TextPalette: TStaticText;
    XPtake: TSpinEdit;
    Label2: TLabel;
    tagtake: TEdit;
    Memo1: TMemo;
    Label3: TLabel;
    goldtake: TSpinEdit;
    allgold: TCheckBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    allitems: TCheckBox;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure allgoldChange(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    // Together with MemoQueue, these implement the item queue.
    ListTag:  array of shortstring;
    ListGold: array of integer;
    ListXP:   array of integer;
    FromWhom: shortstring;

  protected
    // Helper methods
    procedure ClearForm(); override;
    procedure QueueThis(); override;
    procedure SendQueue(); override;
    procedure ItemsToLines(nItem:integer; const take_from:shortstring;
                           var last_line:integer; var new_lines:TStringAry);
  end;


// -----------------------------------------------------------------------------
implementation

uses {event,} palettetool,
    constants;

const
    OBJECT_WITH_INVENTORY = OBJECT_TYPE_CREATURE or OBJECT_TYPE_PLACEABLE or
                            OBJECT_TYPE_STORE;


// Configures the form based on current circumstances.
procedure Ttakestuff.FormCreate(Sender: TObject);
begin
    // Initialize fields.
    SetLength(ListTag, 0); // The other arrays are assumed the same length.
    FromWhom := '';

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_WITH_INVENTORY);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted, OBJECT_WITH_INVENTORY);
end;


// Informs Tlilac that there will be no more lines from us.
procedure Ttakestuff.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Tlilac.AddLinesDone();
end;


// Disables the spinner if all gold will be taken.
procedure Ttakestuff.allgoldChange(Sender: TObject);
begin
    goldtake.Enabled := not allgold.Checked;
    ToggleOkay(Sender);
end;


// Handles clicks of the "Palette" button.
procedure Ttakestuff.Button4Click(Sender: TObject);
begin
    // Call up the palette window, items by default.
    TPaletteWindow.Load(tagtake, EditName, SEARCH_ITEMS);
end;


// Controls the enabled state of the "Okay" buttons.
procedure Ttakestuff.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // See if required information has been provided.
    if (xptake.value = 0) and (goldtake.value = 0) and not allgold.checked and
       (tagtake.text = '') then
        bEnable := FALSE
    else
        bEnable := not RadioTagged.Checked or (EditTagged.Text <> '');

    // Enable the "Okay" buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------

// Clears (some of) the form so a new item can be entered.
procedure Ttakestuff.ClearForm();
begin
    xptake.value   := 0;
    goldtake.value := 0;
    tagtake.text   := '';
    allgold.checked        := false;
    CheckPartyGold.Checked := false;
    CheckPartyXP.Checked   := false;
    allitems.checked       := false;
    // Reset the focus as well.
    tagtake.SetFocus();

    // Disable the "Okay" buttons.
    ToggleOkay(tagtake);
end;


// Stores the provided information in the queue for later batch processing.
procedure Ttakestuff.QueueThis();
var
    take_code: TObjectEnum;
    take_from: shortstring;
    num_items: integer;

    gold_append: shortstring = '';
    XP_append:   shortstring = '';
begin
    // Who is receiving this?
    take_code := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                                 RadioTagged, RadioActor, RadioSpawn, FALSE);
    if take_code = E_CHOOSE_Tagged then
        take_from := TAG_FLAG + QuoteSwap(EditTagged.text)
    else
        take_from := ObjectVar(take_code);

    // Send out a batch of NWScript if this is going to a new object.
    if take_from <> FromWhom then begin
        SendQueue();
        MemoQueue.Clear();
        SetLength(ListTag, 0);
        FromWhom := take_from;
    end;

    // Make space for recording the current info.
    num_items := Length(ListTag);
    SetLength(ListTag,  num_items+1);
    SetLength(ListGold, num_items+1);
    SetLength(ListXP,   num_items+1);
    // Record "A"ll or "S"ingle item.
    if allitems.checked then
        ListTag[num_items] := 'A'
    else
        ListTag[num_items] := 'S';
    // Save the current info.
    ListTag[num_items]  += QuoteSwap(tagtake.text);
    ListGold[num_items] := goldtake.value;
    ListXP[num_items]   := XPtake.value;
    // Override the gold value for "all gold".
    if allgold.checked then
        ListGold[num_items] := goldtake.MaxValue + 1;
    // Flag the numeric values for party-wide by making them negative.
    if CheckPartyGold.Checked then begin
        ListGold[num_items] := -ListGold[num_items];
        gold_append := ' (from party)';
    end;
    if CheckPartyXP.Checked then begin
        ListXP[num_items] := -ListXP[num_items];
        XP_append := ' (from party)';
    end;

    // Feedback for the user.
    if allgold.checked then
        MemoQueue.Append('all gold' + gold_append)
    else if goldtake.Value > 0 then
        MemoQueue.Append(IntToStr(goldtake.Value) + ' gold' + gold_append);
    if XPtake.Value > 0 then
        MemoQueue.Append(IntToStr(XPtake.Value) + ' experience' + XP_append);
    if tagtake.Text <> '' then begin
        if EditName.Text <> '' then
            MemoQueue.Append(EditName.Text)
        else
            MemoQueue.Append('"'+tagtake.Text+'"');
    end;
end;


// Converts the stored information to NWScript and sends it to the script window.
procedure Ttakestuff.SendQueue();
var
    sTag: shortstring = '';
    take_from: shortstring;
    whom, what: shortstring;
    nItem, last_item: integer;

    start_line, last_line: integer;
    new_lines: array of shortstring;
begin
    last_item := Length(ListTag) - 1;
    // Make sure there is something to send.
    if last_item < 0 then
        exit;

    // To whom do we send this?
    if not StartsWith(FromWhom, TAG_FLAG) then
        take_from := FromWhom
    else begin
        take_from := s_oTarget;
        sTag := copy(FromWhom, 1+Length(TAG_FLAG), 32);   // Max length of a tag is 32.
    end;

    // Make sure oSelf is defined, if needed.
    if take_from = s_oSelf then
        Tlilac.Declare(VAR_oSELF);

    // Allocate space (comment, oTarget defnition, plus three lines per item).
    SetLength(new_lines, 2 + 3*(1+last_item));

    // Prepare the opening comment.
    if MemoQueue.Lines.Count = 1 then
        what := MemoQueue.Lines[0]
    else
        what := 'stuff';
    // How to describe the target in the opening comment.
    if      take_from = s_oSelf      then  whom := 'us'
    else if take_from = s_oPC        then  whom := 'the PC'
    else if take_from = s_oActivator then  whom := 'the item activator'
    else if take_from = s_oActTarget then  whom := 'the activation target'
    else if take_from = s_oSpawn     then  whom := Tlilac.last_spawn
    else if take_from = s_oActor     then  whom := Tlilac.last_actor
    else                                   whom := '"'+sTag+'"';
    // Now the actual comment.
    new_lines[0] := '// Take '+what+' from '+whom+'.';
    start_line := 1;

    // Define oTarget?
    if take_from = s_oTarget then begin
        new_lines[1] := s_oTarget+' = '+s_GetObject + sTag + '");';
        start_line := 2;
    end;
    last_line := start_line - 1;


    // Loop through the items to create.
    for nItem := 0 to last_item do
        ItemsToLines(nItem, take_from, last_line, new_lines);

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], start_line, last_line, true);
end;


// Adds the lines to new_lines (and updates last_line) for the nItem-th entry
// in the queue.
procedure Ttakestuff.ItemsToLines(nItem:integer; const take_from:shortstring;
                                  var last_line:integer; var new_lines:TStringAry);
var
    sTag: shortstring;
begin
    // GOLD:
    if ListGold[nItem] <> 0 then begin
        Inc(last_line);

        if ListGold[nItem] > goldtake.MaxValue then
            // Take all gold from the target.
            new_lines[last_line] := 'TakeGoldFromCreature(GetGold('+
                                     take_from+'), '+take_from+', TRUE);'
        else if ListGold[nItem] > 0 then
            // Take the specified gold from the target.
            new_lines[last_line] := 'TakeGoldFromCreature(' +
                                     IntToStr(ListGold[nItem])+', '+
                                     take_from+', TRUE);'
        else begin
            Tlilac.DefineFunc(FUNC_TAKE_GOLD_PARTY);

            if ListGold[nItem] < -goldtake.MaxValue then
                // Take all gold from each PC in the party.
                new_lines[last_line] := 'TakeGoldFromAll(-1, '+take_from+');'
            else
                // Take the specified gold from each PC in the party.
                new_lines[last_line] := 'TakeGoldFromAll('+
                                         IntToStr(-ListGold[nItem])+', '+
                                         take_from+');';
        end;
    end;

    // XP:
    if ListXP[nItem] <> 0 then begin
        Inc(last_line);

        if ListXP[nItem] > 0 then begin
            // Take XP from the target.
            Tlilac.DefineFunc(FUNC_TAKE_XP);
            new_lines[last_line] := 'RemoveXPFromCreature('+take_from+', '+
                                     IntToStr(ListXP[nItem])+');'
        end
        else begin
            // Take XP from each PC in the party.
            Tlilac.DefineFunc(FUNC_TAKE_XP_PARTY);
            new_lines[last_line] := 'RemoveXPFromAll('+take_from+', '+
                                     IntToStr(-ListXP[nItem])+');';
        end;
    end;

    // ITEM:
    if Length(ListTag[nItem]) > 1 then begin
        Inc(last_line);
        // Split the stored entry into tag and code.
        sTag := copy(ListTag[nItem], 2, Length(ListTag[nItem])-1);
        case ListTag[nItem][1] of
            // "S"ingle or "A"ll?
            'S': new_lines[last_line] := 'DestroyObject('+
                                         Script.GetItemPossessedBy(take_from, sTag)+
                                         ');';
            'A': begin
                    Tlilac.DefineFunc(FUNC_TAKE_ALL_ITEM);
                    new_lines[last_line] := 'RemoveAllItems('+take_from+', "'+sTag+'");';
                 end;
        end;
    end;
end;


initialization
  {$i itemxp_take.lrs}
end.

