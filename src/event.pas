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
* Redid some presentation aspects.
* Reorganized some backend functionality.
Note: Potential additions include ActionExamine(), ActionRandomWalk(), and ActionRest().
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit event;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, ExtCtrls, Buttons, {Registry,} {jpeg,}
  LResources;

type

  { Teventchooser }

  Teventchooser = class(TForm)
    // Form elements
    eventgroup: TRadioGroup;
    ifpanel: TPanel;
    Memo1: TMemo;
    Label1: TLabel;
    ifcounter: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Image1: TImage;
    Image2: TImage;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Image3: TImage;
    // Event handlers
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure scriptClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);

  private
    // Utility
    procedure ConfigureDisplay();

  public
    // Communication from other units.
    class procedure ResetEvents(); inline;

  end;

{var
  eventchooser: Teventchooser;
}

// -----------------------------------------------------------------------------


implementation

uses
    start, popup, {nwn,}
    itemxp_give, itemxp_take, adjustreputation, alignmentreputation,
    localvar, startmerchant, attackpc, spawn_creature, spawn_placeable,
    startconv, teleport_pc, applyvisual, destroyobject, ifinspector,
    make_else, chooseif, journaladd, damage_pc, spellcast,
    openlock, effect, actionqueue, storepcparty, lights_onoff, commform,
    sound_object, subracedeity, companions, delay,
    miscfunc, cut_scene, itemscript, removeeffect, appear, traps,
    HorseMount;

var // Unit-wide variables because static class fields were causing crashes.
    FirstShow: boolean;


// Resets the FirstShow variable when a new script is started.
class procedure Teventchooser.ResetEvents(); inline;
begin
    FirstShow := TRUE;
end;


// -----------------------------------------------------------------------------


// Possibly pops up the "welcome to events" popup (when this form is shown for
// the first time for a given script).
procedure Teventchooser.FormActivate(Sender: TObject);
begin
    if FirstShow and not Tpopup_ev.IsSuppressed() then
    begin
        FirstShow := false;
        main.ShowPopup(Tpopup_ev);
    end;
end;


// Configures the form upon creation to match the current setting.
procedure Teventchooser.FormCreate(Sender: TObject);
begin
    ConfigureDisplay();
end;


// Responds to the "Script" button being clicked.
procedure Teventchooser.scriptClick(Sender: TObject);
begin
    // Big old case statement to determine which window to show.
    case eventgroup.itemindex of
         0: main.ShowPopup(Tqueue);             // Other actions
         1: main.ShowPopup(Tadjalignment);      // Alignment adjustment
         2: main.ShowPopup(TAppearance);        // Appearance and names
         3: main.ShowPopup(Tcompanion);         // Associates
         4: main.ShowPopup(Tattack);            // Attack PC
         5: main.ShowPopup(Tcastspell);         // Cast a spell
         6: main.ShowPopup(Tconversation);      // Start conversation
         7: main.ShowPopup(Tcrspawn);           // Spawn creature
         8: main.ShowPopup(Tplspawn);           // Spawn placeable
         9: main.ShowPopup(Tcutscene);          // Cutscenes
        10: main.ShowPopup(Tdamagepc);          // Damage someone
        11: main.ShowPopup(Tdestroyobj);        // Destroy object
        12: main.ShowPopup(Tapplyeffect);       // Apply effect
        13: main.ShowPopup(TRemEffect);         // Remove effect
        14: main.ShowPopup(Tgiveitem);          // Give items, etc.
        15: main.ShowPopup(Ttakestuff);         // Take items
        16: main.ShowPopup(THorseForm);         // Horses
        17: main.ShowPopup(Titemscripting);     // Item scripting
        18: main.ShowPopup(Tentryupdate);       // Add journal entry
        19: main.ShowPopup(Tlights);            // Turn lights on/off
        20: main.ShowPopup(Tlocvar);            // Set locals
        21: main.ShowPopup(Tmerchant);          // Start merchant
        22: main.ShowPopup(Tmisc);              // Misc.
        23: main.ShowPopup(Tlockopen);          // Lock functions
        24: main.ShowPopup(Tstoreinfo);         // Store info about PC
        25: main.ShowPopup(Trepadjust);         // Reputation adjustment
        26: main.ShowPopup(Tsoundobject);       // Sounds
        27: main.ShowPopup(Tcommunicationform); // Messages
        28: main.ShowPopup(Tsubrace_deity);     // Subrace & deity
        29: main.ShowPopup(Tteleport);          // Teleport PC
        30: main.ShowPopup(TTrapForm);          // Traps
        31: main.ShowPopup(Tvfx);               // Apply VFX
        32: main.ShowPopup(Tdelaycommand);      // Delays
        33: main.ShowPopup(Tifchoose);          // If's
    end;//case

    // The window just shown may have altered how this form is presented.
    ConfigureDisplay();

    // Reset the selection.
    eventgroup.itemindex := -1;
end;


// Handles clicks to the "View structure" button in the "if" panel.
procedure Teventchooser.Button3Click(Sender: TObject);
begin
    main.ShowPopup(Tinspect);
end;


// Handles clicks of the "Finish current if" button.
procedure Teventchooser.Button4Click(Sender: TObject);
begin
    if Tifchoose.IsElseAllowed() then
        main.ShowPopup(Tmakeelse)
    else
       // This was an else; it is now finished.
        Tifchoose.EndIf();

    // Update the display (in case the last "if" was closed).
    ConfigureDisplay();
end;


// -----------------------------------------------------------------------------

// Changes some display elements to match the current setting.
procedure Teventchooser.ConfigureDisplay();
var
    ifcount: integer;
begin
    // Respond to a delay time being set.
    image3.visible := TdelayCommand.DelaySet();
    if not TdelayCommand.DelaySet() then
        caption := 'Event / action chooser'
    else
        caption := 'Event / action chooser - next thing you script is delayed by '+
                   Tdelaycommand.DescString();

    // Update the "if tracking" display.
    ifcount := Tifchoose.GetIfCount();
    ifcounter.text := inttostr(ifcount);
    ifpanel.visible := ifcount > 0;
end;


initialization
  {$i event.lrs}
end.
