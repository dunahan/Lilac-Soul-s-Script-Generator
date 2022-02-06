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
* Form presentation revised.
* Some animations added.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit actionqueue;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} {Forms,} {Dialogs,}
  StdCtrls, ExtCtrls, Spin, start, nwn, Buttons,
  LResources, QueueForm, Classes;


// -----------------------------------------------------------------------------

type

  { Tqueue }

  Tqueue = class(TQueueForm)
      CheckEquipEventItem: TCheckBox;
      CheckItemTreeEventItem: TCheckBox;
      LabelVolume: TLabel;
    // Form elements
    LabelAnimation: TLabel;
    LabelTheQueue: TLabel;
    LabelActionQueue: TLabel;
    MemoTheQueue: TMemo;
    Panel1: TPanel;
    EditTagged: TEdit;
    Memo2: TMemo;
    ComboBox1: TComboBox;
    PanelAboutQueues: TPanel;
    CaptionAboutQueues: TStaticText;
    RadioSpawn: TRadioButton;
    RadioActivator: TRadioButton;
    RadioTargetOwner: TRadioButton;
    RadioTargetPC: TRadioButton;
    RadioTargetSpawn: TRadioButton;
    RadioTargetTargeted: TRadioButton;
    RadioTargetTag: TRadioButton;
    RadioTargeted: TRadioButton;
    RadioPC: TRadioButton;
    RadioOwner: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargetActivator: TRadioButton;
    TextAboutQueues: TStaticText;
    TargetPanel: TPanel;
    EditTargetTag: TEdit;
    nonepanel: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    itemtreepanel: TPanel;
    EditItemTreeTag: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    animationpanel: TPanel;
    ComboBox2: TComboBox;
    SpinEdit1: TSpinEdit;
    Label7: TLabel;
    durationpanel: TPanel;
    SpinEdit2: TSpinEdit;
    Label8: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    speakpanel: TPanel;
    Label9: TLabel;
    speakline: TEdit;
    slotpanel: TPanel;
    slotbox: TComboBox;
    Label10: TLabel;
    equippanel: TPanel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    EditEquipTag: TEdit;
    BitBtn5: TBitBtn;
    equipslotbox: TComboBox;
    Label14: TLabel;
    Panel3: TPanel;
    Memo3: TMemo;
    ComboVolume: TComboBox;
    // Event handlers
    procedure CheckEquipEventItemChange(Sender: TObject);
    procedure CheckItemTreeEventItemChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure EnableTargets(Sender: TObject);
    procedure ToggleAnimDuration(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    // Bookkeeping fields.
    ShownPanel: TPanel; // Tracks which auxiliary panel is currently shown.

  protected
    // Helper methods.
    procedure ClearForm(); override;
    function  GetAnimationString(): shortstring;
    function  GetEquipItem(): shortstring;
    function  GetItem(is_possessed: boolean=true): shortstring;
    function  GetTarget(use_nearest: boolean=true): shortstring;
    procedure QueueThis(); override;
    procedure SendQueue(); override;
  end;


// -----------------------------------------------------------------------------

implementation

uses {event,} palettetool,
    constants, delay;

const
    NUM_FIREFORGET_ANIMS = 17;


// -----------------------------------------------------------------------------
// Event handlers


// Initializes the form.
procedure Tqueue.FormCreate(Sender: TObject);
begin
    // Initialize private variables.
    ShownPanel := nil;

    // Load some TComboBoxes.
    LoadConstants(slotbox.Items, INVENTORY_SLOT);
    LoadConstants(equipslotbox.Items, INVENTORY_SLOT);

    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, nil, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(RadioTargetOwner,     RadioTargetPC,
                              RadioTargetActivator, RadioTargetTargeted, OBJECT_TYPE_ALL);
    CheckEquipEventItem.Visible := main.GetIsItemScript();
    CheckItemTreeEventItem.Visible := main.GetIsItemScript();
    // Check for having hidden the current selection.
    if RadioOwner.Checked and not RadioOwner.Visible then
        RadioTagged.Checked := true;

    // Possibly default to the last actor.
    EditTagged.Text := Tlilac.last_actor;

    if Tdelaycommand.DelaySet() then begin
        // Disable most of this form, and display the reason why we cannot do this.
        Panel1.Enabled    := false;
        combobox1.enabled := false;
        Memo2.Enabled     := false;
        panel3.visible := true;
   end;
end;


// Handles clicks of the "Okay - more" button.
procedure Tqueue.Button1Click(Sender: TObject);
begin
    // The owner of this queue is now fixed (to prevent confusion).
    LabelActionQueue.Caption := 'All actions in this queue will be given to:';
    Panel1.Enabled := false;

    // Proceed to standard processing.
    ButtonClickOkayMore(Sender);
end;


// Handles clicks of the palette button in the "itemtree" panel.
procedure Tqueue.Button4Click(Sender: TObject);
begin
    // Call up the palette window.
    TPaletteWindow.Load(EditItemTreeTag, nil, SEARCH_ITEMS);
end;


// Handles clicks of the "event item" check box in the "equip" panel.
procedure Tqueue.CheckEquipEventItemChange(Sender: TObject);
begin
    EditEquipTag.Enabled := not CheckEquipEventItem.Checked;
    BitBtn5.Enabled      := not CheckEquipEventItem.Checked; // The palette button.

    // This might affect the okay buttons.
    ToggleOkay(Sender);
end;


// Handles clicks of the "event item" check box in the "item tree" panel.
procedure Tqueue.CheckItemTreeEventItemChange(Sender: TObject);
begin
    EditItemTreeTag.Enabled := not CheckItemTreeEventItem.Checked;
    BitBtn4.Enabled         := not CheckItemTreeEventItem.Checked; // The palette button.

    // This might affect the okay buttons.
    ToggleOkay(Sender);
end;


// Handles clicks of the palette button in the "equip" panel.
procedure Tqueue.BitBtn5Click(Sender: TObject);
begin
    // Call up the palette window.
    TPaletteWindow.Load(EditEquipTag, nil, SEARCH_ITEMS);
end;


// Handles selection of an action from the drop-down list (TComboBox).
//
// Index codes are:
//  0: Clear all actions
//  1: Attack someone
//  2: Close door
//  3: Equip item by tag
//  4: Equip most damaging melee weapon
//  5: Equip most damaging ranged weapon
//  6: Equip most effective armor
//  7: Face something
//  8: Follow someone
//  9: Give item to PC
// 10: Jump to an object
// 11: Lock something
// 12: Move (walk) to an object
// 13: Move away from object
// 14: Open door
// 15: Pick up item
// 16: Play animation
// 17: Put down item
// 18: Sit down on object
// 19: Speak a line
// 20: Take item from PC
// 21: Unequip item by position
// 22: Unequip item by tag
// 23: Unlock something
// 24: Wait a specified amount of time
procedure Tqueue.ComboBox1Change(Sender: TObject);
const
    // A quick hack to control the visibility of the options to target.
    // (Only needed for one panel, but might as well make the settings accurate
    //  for all options.)
    ReqObject: array[0..24] of integer =
          ( OBJECT_TYPE_NONE,       // Clear all actions
            OBJECT_TYPE_CREATURE or OBJECT_TYPE_DOOR or OBJECT_TYPE_PLACEABLE, // Attack
            OBJECT_TYPE_DOOR,       // Close door
            OBJECT_TYPE_ITEM,       // Equip (by tag -- really requires a string)
            OBJECT_TYPE_NONE,       // Equip most damaging melee
            OBJECT_TYPE_NONE,       // Equip most damaging ranged
            OBJECT_TYPE_NONE,       // Equip most effective armor
            OBJECT_TYPE_IN_AREA,    // Face something
            OBJECT_TYPE_CREATURE,   // Follow someone
            OBJECT_TYPE_ITEM,       // Give item (by tag -- really requires a string)
            OBJECT_TYPE_IN_AREA,    // Jump to
            OBJECT_TYPE_DOOR     or OBJECT_TYPE_PLACEABLE,  // Lock
            OBJECT_TYPE_IN_AREA,    // Move to
            OBJECT_TYPE_IN_AREA,    // Move from
            OBJECT_TYPE_DOOR,       // Open door
            OBJECT_TYPE_ITEM,       // Pick up item (by tag -- really requires a string)
            OBJECT_TYPE_NONE,       // Play animation
            OBJECT_TYPE_ITEM,       // Put down item (by tag -- really requires a string)
            OBJECT_TYPE_PLACEABLE,  // Sit
            OBJECT_TYPE_NONE,       // Speak
            OBJECT_TYPE_ITEM,       // Take item (by tag -- really requires a string)
            OBJECT_TYPE_ITEM,       // Unequip (by position -- really requires an integer)
            OBJECT_TYPE_ITEM,       // Unequip (by tag -- really requires a string)
            OBJECT_TYPE_DOOR     or OBJECT_TYPE_PLACEABLE,  // Unlock
            OBJECT_TYPE_NONE );     // Wait
var
    index: integer;
begin
    index := combobox1.itemindex;

    // Hide the previous panel.
    if ShownPanel <> nil then
        ShownPanel.Visible := false;

    // Determine the next panel to show.
    case index of
        // Actions that require no additional information:
        0, 4..6: ShownPanel := nonepanel;

        // Actions that require an object target.
        1, 2, 7, 8, 10..14, 18, 23: ShownPanel := TargetPanel;

        // Actions that require an item tag.
        9, 15, 17, 20, 22: ShownPanel := itemtreepanel;

        // Relatively unique actions.
        3:  ShownPanel := equippanel;       // Requires item tag and slot.
        16: ShownPanel := animationpanel;   // Requires an animation and duration.
        19: ShownPanel := speakpanel;       // Requires text to speak.
        21: ShownPanel := slotpanel;        // Requires an inventory slot.
        24: ShownPanel := durationpanel;    // Requires a duration.
        else ShownPanel := nil;
    end;
    if ShownPanel <> nil then
        ShownPanel.Visible := true;

    // Possibly reset the auxiliary panel.
    if ShownPanel = TargetPanel then begin
        // Hide buttons that represent disallowed object types.
        // Also make sure hidden options are not selected.

        with RadioTargetOwner do begin
            Visible := (ReqObject[index] and main.ObjectType <> 0) and
                       not main.GetIsActivation();
            if not Visible and Checked then
                RadioTargetTag.Checked := true;
        end;

        with RadioTargetActivator do begin
            Visible := (ReqObject[index] and OBJECT_TYPE_CREATURE <> 0) and
                       main.GetIsActivation();
            if not Visible and Checked then
                RadioTargetTag.Checked := true;
        end;

        with RadioTargetPC do begin
            Visible :=(ReqObject[index] and OBJECT_TYPE_CREATURE <> 0)
                      and not main.GetIsActivation();
            if not Visible and Checked then
                RadioTargetTag.Checked := true;
        end;

        with RadioTargetSpawn do begin
            Visible := ReqObject[index] and Tlilac.last_spawn_type <> 0;
            if not Visible and Checked then
                RadioTargetTag.Checked := true;
        end;

        // Now that visibility is handled, update enabled status.
        EnableTargets(Sender);
    end;

    // Update the "Okay" buttons.
    ToggleOkay(Sender);
end;


// Updates sub-options based on who this action queue will be assigned to.
procedure Tqueue.EnableTargets(Sender: TObject);
const
    // Defines which actions can target the queue owner.
    // (Only needed for one panel, but might as well make the settings accurate
    //  for all options.)
    SelfTarget: array[0..24] of boolean =
          ( false,      // Clear all actions
            false,      // Attack
            true,       // Close door
            false,      // Equip item
            false,      // Equip most damaging melee
            false,      // Equip most damaging ranged
            false,      // Equip most effective armor
            false,      // Face
            false,      // Follow
            false,      // Give item
            false,      // Jump to
            true,       // Lock
            false,      // Move to
            false,      // Move from
            true,       // Open door
            false,      // Pick up item
            false,      // Play animation
            false,      // Put down item (by tag -- really requires a string)
            false,      // Sit
            false,      // Speak
            false,      // Take item
            false,      // Unequip item (by position)
            false,      // Unequip item (by tag)
            true,       // Unlock
            false );    // Wait
var
    bSelfTarget: boolean = false;
begin
    // We only need to do something if TargetPanel is shown.
    if ShownPanel <> TargetPanel then
        exit;

    // Determine if self-targeting is allowed.
    if combobox1.ItemIndex >= 0 then
        bSelfTarget := SelfTarget[combobox1.ItemIndex];

    // Disable buttons that would be a disallowed self-target, and make sure
    // those buttons are not selected (default to target by tag for simplicity).

    with RadioTargetOwner do begin
        Enabled := bSelfTarget or not RadioOwner.Checked;
        if not Enabled and Checked then
            RadioTargetTag.Checked := true;
    end;

    with RadioTargetPC do begin
        Enabled := bSelfTarget or not RadioPC.Checked;
        if not Enabled and Checked then
            RadioTargetTag.Checked := true;
    end;

    with RadioTargetTargeted do begin
        Enabled := bSelfTarget or not RadioTargeted.Checked;
        if not Enabled and Checked then
            RadioTargetTag.Checked := true;
    end;

    with RadioTargetActivator do begin
        Enabled := bSelfTarget or not RadioActivator.Checked;
        if not Enabled and Checked then
            RadioTargetTag.Checked := true;
    end;

    with RadioTargetSpawn do begin
        Enabled := bSelfTarget or not RadioSpawn.Checked;
        if not Enabled and Checked then
            RadioTargetTag.Checked := true;
    end;
end;


// Toggles the enabled state of the animation duration spin edit based on the
// currently selected animation.
procedure Tqueue.ToggleAnimDuration(Sender: TObject);
begin
    SpinEdit1.Enabled := ComboBox2.ItemIndex >= NUM_FIREFORGET_ANIMS;

    // Update the "Okay" buttons.
    ToggleOkay(Sender);
end;


// Controls the enabled state of the two "Okay" buttons based on the status of
// the rest of the form.
procedure Tqueue.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // Validate the creature to whom this will be assigned.
    if RadioTagged.Checked and (EditTagged.Text = '') then
        bEnable := false

    // Validate (indirectly) that an action is selected.
    else if ShownPanel = nil then
        bEnable := false

    // Make sure the visible panel has all required info.
    else if ShownPanel = nonepanel then
        bEnable := true
    else if ShownPanel = TargetPanel then
        bEnable := not RadioTargetTag.Checked or (EditTargetTag.Text <> '')
    else if ShownPanel = ItemTreePanel then
        bEnable := (EditItemTreeTag.Text <> '')  or  CheckItemTreeEventItem.Checked
    else if ShownPanel = EquipPanel then
        bEnable := ( (EditEquipTag.Text <> '')  or  CheckEquipEventItem.Checked )
                   and  (EquipSlotBox.ItemIndex >= 0)
    else if ShownPanel = AnimationPanel then
        bEnable := ComboBox2.ItemIndex >= 0
    else if ShownPanel = SpeakPanel then
        bEnable := SpeakLine.Text <> ''
    else if ShownPanel = SlotPanel then
        bEnable := SlotBox.ItemIndex >= 0
    else if ShownPanel = DurationPanel then
        bEnable := SpinEdit2.Value > 0
    else
        // If we get here, something is buggy, so default to not enabled.
        bEnable := false;

    // Update the buttons' status.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------
// Helper methods.


procedure TQueue.ClearForm();
begin
    // Reset the action choice and hide whatever panel is shown.
    ComboBox1.Text := 'Choose your action';
    // It seems I need to manually trigger this event?
    ComboBox1.OnChange(ComboBox1);

    // Reset some of the sub-options.
    // (I'll leave some alone since that data has a decent chance of being
    // intentionally re-used. -- TK)
    CheckEquipEventItem.Checked    := FALSE;
    EditEquipTag.Text    := '';
    EditItemTreeTag.Text := '';
    CheckItemTreeEventItem.Checked := FALSE;
    SpeakLine.Text := '';
    ComboBox2.ItemIndex    := -1;// Animation selection.
    EquipSlotBox.ItemIndex := -1;
    SlotBox.ItemIndex      := -1;
    if not RadioTargetTag.Checked then
        EditTargetTag.Text := '';
end;


// Returns the parameters for ActionPlayAnimation().
function TQueue.GetAnimationString(): shortstring;
begin
    // The index will have been validated before this function is called.
    result := SymConst(ANIMATION, combobox2.itemindex);

    // Some animations require a duration.
    if combobox2.itemindex >= NUM_FIREFORGET_ANIMS then
        result += ', 1.0, '+inttostr(spinedit1.value)+'.0';
end;


// Returns the string representation of the item indicated by equippanel.
function TQueue.GetEquipItem(): shortstring;
begin
    if CheckEquipEventItem.Checked then
        result := s_oEventItem
    else
        result := Script.GetItemPossessedBy(s_OBJECT_SELF, QuoteSwap(EditEquipTag.text));
end;


// Returns the string representation of the item indicated by itemtreepanel.
function TQueue.GetItem(is_possessed: boolean=true): shortstring;
begin
    if CheckItemTreeEventItem.Checked then
        result := s_oEventItem
    else if is_possessed then
        result := Script.GetItemPossessedBy(s_OBJECT_SELF, QuoteSwap(EditItemTreeTag.text))
    else
        result := s_GetNearest + QuoteSwap(EditItemTreeTag.text)+'")';
end;


// Returns the string representing the target indicated by TargetPanel.
// _use_nearest_ only affects finding objects by tag.
function TQueue.GetTarget(use_nearest: boolean=true): shortstring;
begin
    if RadioTargetOwner.checked then
        begin result := s_oSelf;    Tlilac.Declare(VAR_oSELF); end
    else if RadioTargetActivator.checked then
        result := s_oActivator
    else if RadioTargetPC.checked then
        result := s_oPC
    else if RadioTargetTargeted.checked then
        result := s_oActTarget
    else if RadioTargetSpawn.checked then
        result := s_oSpawn
    else if use_nearest then
        result := s_GetNearest + QuoteSwap(EditTargetTag.text) + '")'
    else
        result := s_GetObject + QuoteSwap(EditTargetTag.text) + '")';
end;


// Sends the command for doing the selected option to the action queue.
//
// Index codes are:
//  0: Clear all actions
//  1: Attack someone
//  2: Close door
//  3: Equip item by tag
//  4: Equip most damaging melee weapon
//  5: Equip most damaging ranged weapon
//  6: Equip most effective armor
//  7: Face something
//  8: Follow someone
//  9: Give item to PC
// 10: Jump to an object
// 11: Lock something
// 12: Move (walk) to an object
// 13: Move away from object
// 14: Open door
// 15: Pick up item
// 16: Play animation
// 17: Put down item
// 18: Sit down on object
// 19: Speak a line
// 20: Take item from PC
// 21: Unequip item by position
// 22: Unequip item by tag
// 23: Unlock something
// 24: Wait a specified amount of time
procedure TQueue.QueueThis();
var
   func_call: shortstring;
begin
    // Determine the function to call.
    case combobox1.itemindex of
         0: func_call := 'ClearAllActions()';
         1: func_call := 'ActionDoCommand(ActionAttack('+GetTarget()+'))';
         2: func_call := 'ActionCloseDoor('+GetTarget()+')';
         3: func_call := 'ActionEquipItem('+GetEquipItem()+', '+
                                            SymConst(INVENTORY_SLOT, equipslotbox.ItemIndex)+')';
         4: func_call := 'ActionEquipMostDamagingMelee()';
         5: func_call := 'ActionEquipMostDamagingRanged()';
         6: func_call := 'ActionEquipMostEffectiveArmor()';
         7: func_call := 'ActionDoCommand(SetFacingPoint(GetPosition('+GetTarget()+')))';
         8: func_call := 'ActionForceFollowObject('+GetTarget()+')';
         9: func_call := 'ActionGiveItem('+GetItem()+', '+s_oPC+')';
        10: func_call := 'ActionJumpToObject('+GetTarget(false)+')';
        11: func_call := 'ActionLockObject('+GetTarget()+')';
        12: func_call := 'ActionMoveToObject('+GetTarget()+')';
        13: func_call := 'ActionMoveAwayFromObject('+GetTarget()+')';
        14: func_call := 'ActionOpenDoor('+GetTarget()+')';
        15: func_call := 'ActionPickUpItem('+GetItem(false)+')';
        16: func_call := 'ActionPlayAnimation('+GetAnimationString()+')';
        17: func_call := 'ActionPutDownItem('+GetItem()+')';
        18: func_call := 'ActionSit('+GetTarget()+')';
        19: func_call := Script.SpeakString(QuoteSwap(speakline.text), ComboVolume.ItemIndex, TRUE);
        20: func_call := 'ActionTakeItem('+GetItem()+', '+s_oPC+')';
        21: func_call := 'ActionUnequipItem('+Script.GetItemInSlot(slotbox.ItemIndex)+')';
        22: func_call := 'ActionUnequipItem('+GetItem()+')';
        23: func_call := 'ActionUnlockObject('+GetTarget()+')';
        24: func_call := 'ActionWait('+inttostr(spinedit2.value)+'.0)';
    end;

    // Add this to the queue.
    MemoTheQueue.Lines.Append(func_call);
end;


// Sends the queue to the script window.
procedure TQueue.SendQueue();
var
    assign_code: TObjectEnum;
    line_num:    integer;
    start_line:  integer;
    assign_to:   shortstring;
    line_ending: string[2];
    new_lines:   array of shortstring;
begin
    // Quick check: is there a queue to send?
    if MemoTheQueue.Lines.Count = 0 then
        exit;

    // Who will be receiving this action queue?
    assign_code := GetChosenObject(RadioOwner, RadioPC, RadioActivator, RadioTargeted,
                                   nil, RadioTagged, RadioSpawn);
    // Adjust for some special cases.
    case assign_code of
        E_CHOOSE_Self:  Tlilac.Declare(VAR_oSELF);
        E_CHOOSE_Actor: Tlilac.last_actor := EditTagged.Text;
    end;

    // Text for assigning stuff.
    if assign_code = E_CHOOSE_Owner then begin
        assign_to := '';
        line_ending := ';';
    end
    else begin
        assign_to := s_AssignCommand + ObjectVar(assign_code) + ', ';
        line_ending := ');';
    end;

    // Initialize the lines to add to the script window.
    SetLength(new_lines, 2+MemoTheQueue.Lines.Count);
    new_lines[0] := '// Have '+ObjectDesc(assign_code, '')+' perform a sequence of actions.';
    start_line := 1;

    // Check to see if we need to define (in the script) who gets this queue.
    if assign_code = E_CHOOSE_Actor then begin
        new_lines[1] := s_oActor+' = '+s_GetObject + QuoteSwap(EditTagged.Text)+'");';
        start_line := 2;
    end;

    // Construct the array of commands to add to the script window.
    for line_num := 0 to MemoTheQueue.Lines.Count-1 do
        new_lines[start_line+line_num] :=
                assign_to + MemoTheQueue.Lines[line_num] + line_ending;

    // Add the lines.
    line_num := start_line + MemoTheQueue.Lines.Count - 1;
    Tlilac.AddLines(new_lines[0..line_num], start_line, line_num);
end;


initialization
    {$i actionqueue.lrs}
end.
