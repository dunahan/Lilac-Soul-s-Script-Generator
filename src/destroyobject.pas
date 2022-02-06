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
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit destroyobject;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} {Forms,} {Dialogs,}
  StdCtrls, {event,} start, nwn, Buttons, {ExtCtrls,}
  LResources, QueueForm;

type

  { Tdestroyobj }

  Tdestroyobj = class(TQueueForm)
      CheckScriptItem: TCheckBox;
    // Form elements.
    CheckWaypoint: TCheckBox;
    CheckOwner: TCheckBox;
    CheckActor: TCheckBox;
    GroupTarget: TGroupBox;
    Memo1: TMemo;
    Label1: TLabel;
    CheckSpawn: TCheckBox;
    ComboBox1: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    CheckTargeted: TCheckBox;
    CheckTagged: TCheckBox;
    EditTagged: TEdit;
    // Event handlers.
    procedure FormCreate(Sender: TObject);
    procedure CheckTaggedChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  private
    // These implement the destruction queue.
    ListVFX: array of integer;
    ListWho: array of shortstring;

  protected
    procedure ClearForm(); override;
    procedure QueueThis(); override;
    procedure QueueSingle(const who: shortstring; nVFX: integer);
    procedure SendQueue(); override;
    procedure SendSingle(const whom: shortstring; bUseVFX, bUseLoc: boolean;
                         var new_lines: TStringAry; var last_line: integer);
  end;


implementation

uses {black_smith,}
     constants;

const
    OBJECT_TYPE_DESTROYABLE = not (OBJECT_TYPE_AREA or OBJECT_TYPE_MODULE)
                              and OBJECT_TYPE_ALL;


// -----------------------------------------------------------------------------

// Configures the form based on current circumstances.
procedure Tdestroyobj.FormCreate(Sender: TObject);
begin
    // Guarantee that we start with a 0-length array of things to destroy.
    // (The other array will be assumed the same length.)
    SetLength(ListWho, 0);

    // Load the list of visual effects.
    LoadConstants(combobox1.Items, VFX_IMPACT);
    ComboBox1.ItemIndex := 0;

    // Initialize check boxes.
    main.InitRadioWhos(CheckOwner, CheckSpawn, CheckActor, OBJECT_TYPE_DESTROYABLE);
    main.InitActivationRadios(CheckOwner, nil, nil, CheckTargeted, OBJECT_TYPE_DESTROYABLE);
    CheckScriptItem.Visible := main.GetIsItemScript();
end;


// Controls the enabled state of the waypoint checkbox, as well as the "Okay"
// buttons.
procedure Tdestroyobj.CheckTaggedChange(Sender: TObject);
begin
    CheckWaypoint.Enabled := CheckTagged.Checked;

    // Also update the "Okay" buttons.
    ToggleOkay(Sender);
end;


// Enables/disables the "Okay" buttons as appropriate.
procedure Tdestroyobj.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // If destroying by tag, a tag is required.
    if CheckTagged.Checked then
        bEnable := EditTagged.Text <> ''

    // Otherwise, we're OK as long as something is picked as the target.
    else
        bEnable := CheckOwner.Checked or CheckTargeted.Checked or
                   CheckSpawn.Checked or CheckActor.Checked    or
                   CheckScriptItem.Checked;

    // Update the "Okay" buttons.
    BitBtn1.Enabled := bEnable;
    BitBtn2.Enabled := bEnable;
end;


// -----------------------------------------------------------------------------

// Clears the form for new data to be entered.
procedure Tdestroyobj.ClearForm();
begin
    // Most checkboxes can only be chosen once.
    with CheckOwner      do if Checked then begin Checked := false; Enabled := false; end;
    with CheckTargeted   do if Checked then begin Checked := false; Enabled := false; end;
    with CheckSpawn      do if Checked then begin Checked := false; Enabled := false; end;
    with CheckActor      do if Checked then begin Checked := false; Enabled := false; end;
    with CheckScriptItem do if Checked then begin Checked := false; Enabled := false; end;

    // It is the tags that presumably justify having an "and more" button on this form.
    CheckTagged.checked   := false;
    EditTagged.text := '';
    EditTagged.SetFocus();
end;


// Adds the selected objects and accompanying VFX to the queue for later batch processing.
procedure Tdestroyobj.QueueThis();
var
    sFlaggedTag: shortstring;
begin
    // Just go through the check boxes and queue the selected ones.
    if CheckTargeted.Checked   then QueueSingle(s_oActTarget, ComboBox1.ItemIndex);
    if CheckSpawn.Checked      then QueueSingle(s_oSpawn,     ComboBox1.ItemIndex);
    if CheckActor.Checked      then QueueSingle(s_oActor,     ComboBox1.ItemIndex);
    if CheckScriptITem.Checked then QueueSingle(s_oEventItem, ComboBox1.ItemIndex);
    if CheckOwner.Checked then begin
        QueueSingle(s_oSelf, ComboBox1.ItemIndex);
        Tlilac.Declare(VAR_oSELF);
    end;
    if CheckTagged.Checked then begin
        // Need to store a bit of information in the "Who" queue.
        sFlaggedTag := TAG_FLAG;
        if CheckWaypoint.Checked then
            sFlaggedTag += 'L'  // VFX at location
        else
            sFlaggedTag += 'O'; // VFX on object
        sFlaggedTag += QuoteSwap(EditTagged.Text);
        QueueSingle(sFlaggedTag, ComboBox1.ItemIndex);
    end;
end;


// Adds the specified objects and accompanying VFX to the queue.
procedure Tdestroyobj.QueueSingle(const who: shortstring; nVFX: integer);
var
    nLength: integer;
begin
    // Allocate space.
    nLength := Length(ListWho);
    SetLength(ListWho, nLength+1);
    SetLength(ListVFX, nLength+1);

    // Store the data.
    ListWho[nLength] := who;
    ListVFX[nLength] := nVFX;
end;


// Sends NWScript to the script window.
procedure Tdestroyobj.SendQueue();
var
    index:   integer;
    whom:    shortstring;
    bUseVFX: boolean;
    bUseLoc: boolean;

    an_object: shortstring;

    last_line: integer;
    new_lines: array of shortstring;
begin
    // Abort if there is nothing to destroy.
    If Length(ListWho) = 0 then
        exit;

    // Allocate space.
    SetLength(new_lines, 1 + 5*Length(ListWho));  // The intro comment plus up to 5 lines per object to destroy.

    // The intro comment.

    if Length(ListWho) = 1 then
        an_object := 'an object '
    else
        an_object := 'objects ';
    new_lines[0] := '// Destroy '+an_object +'(not fully effective until this script ends).';
    last_line := 0;

    for index := 0 to Length(ListWho)-1 do begin
        bUseVFX := ListVFX[index] > 0;

        // Define a visual effect?
        if bUseVFX then begin
            // Since this destruction will use multiple lines, add a blank.
            Inc(last_line);
            new_lines[last_line] := '';
            Inc(last_line);
            new_lines[last_line] := s_eVFX+' = '+s_EffectVisual +
                                    SymConst(VFX_IMPACT, ListVFX[index])+');';
        end;

        // Extract the information from the "Who" queue.
        if not StartsWith(ListWho[index], TAG_FLAG) then begin
            // Simple case.
            bUseLoc := false;
            whom := ListWho[index];
        end
        else begin
            // List who contains TAG_FLAG + [L|O] + <tag>.
            bUseLoc :=  'L' = ListWho[index][Length(TAG_FLAG)+1];
            whom := s_GetObject + copy(ListWho[index], Length(TAG_FLAG)+2, 32)+'")';// Max tag length is 32.
            // Should we define oTarget instead of inlining the GetObject*() call?
            if bUseVFX then begin
                Inc(last_line);
                new_lines[last_line] := s_oTarget+' = '+whom+';';
                whom := s_oTarget;
            end;
        end;

        SendSingle(whom, bUseVFX, bUseLoc, new_lines, last_line);
    end;

    // Add the lines to the script window.
    Tlilac.AddLines(new_lines[0..last_line], 1, last_line);
end;


// Adds the NWScript lines to destroy a specific object.
procedure Tdestroyobj.SendSingle(const whom: shortstring; bUseVFX, bUseLoc: boolean;
                                 var new_lines: TStringAry; var last_line: integer);
var
    apply_to: shortstring;
    linger:   shortstring = '';
begin
    // Apply a visual effect?
    if bUseVFX then begin
        if bUseLoc then
            apply_to := s_GetLocation + whom+')'
        else
            apply_to := whom;
        // We will want the destruction delayed.
        linger := ', 3.0';

        Inc(last_line);
        new_lines[last_line] := Script.ApplyEffect(s_eVFX, apply_to, bUseLoc)+';';
    end;

    // Destroy the object.
    Inc(last_line);
    new_lines[last_line] := 'DestroyObject('+whom+ linger+');';
end;


initialization
  {$i destroyobject.lrs}
end.
