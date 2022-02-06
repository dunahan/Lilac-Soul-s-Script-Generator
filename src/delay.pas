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
* Much of this was trimmed when I converted the form to being modal.
* Updated text to better reflect current functionality.
* Added note about there being better ways to implement multiple delays of the
*   same length.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit delay;

interface

uses
  {Windows,} {Messages,} ExtCtrls, SysUtils, {Forms,} {Dialogs,}
  StdCtrls, Spin, {nwn,} Buttons,
  LResources, ExtForm, Classes;

type

  { Tdelaycommand }

  Tdelaycommand = class(TExtForm)
    // Form elements.
    Memo1: TMemo;
    Label1: TLabel;
    PanelTimed: TPanel;
    PanelQueue: TPanel;
    RadioOwner: TRadioButton;
    RadioPC: TRadioButton;
    RadioActor: TRadioButton;
    RadioTargeted: TRadioButton;
    RadioTag: TRadioButton;
    EditTag: TEdit;
    RadioSpawn: TRadioButton;
    RadioQueue: TRadioButton;
    RadioActivator: TRadioButton;
    RadioTimed: TRadioButton;
    SpinEdit1: TSpinEdit;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    // Event handlers.
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;

  public
    class procedure ResetDelay();               inline;
    class function  DelayTime():   integer;     inline;
    class function  DelayString(): shortstring;
    class function  DelaySet() :   boolean;     inline;
    class function  DescString():  shortstring;
  end;


implementation

uses
    start, nwn,
    constants;

const
    // The types of delays possible.
    DELAY_NONE      = 0;
    DELAY_TIME      = 1;
    DELAY_OWNER     = 2;
    DELAY_PC        = 3;
    DELAY_ACTIVATOR = 4;
    DELAY_TARGET    = 5;
    DELAY_ACTOR     = 6;
    DELAY_SPAWN     = 7;
    DELAY_TAG       = 8;

var // Unit-wide variables because static class fields were causing crashes.

    // Persistent storage of the current delay:
    nType: integer;
    nTime: integer;
    sTime: shortstring;


// -----------------------------------------------------------------------------

// Initializes the form.
procedure Tdelaycommand.FormCreate(Sender: TObject);
begin
    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted, OBJECT_TYPE_CREATURE);

    // Load current delay.
    if nType = DELAY_TIME then
        spinedit1.Value := nTime
    else if nType <> DELAY_NONE then begin
        RadioQueue.Checked := true;
        case nType of
            DELAY_OWNER:     RadioOwner.Checked     := true;
            DELAY_PC:        RadioPC.Checked        := true;
            DELAY_ACTIVATOR: RadioActivator.Checked := true;
            DELAY_TARGET:    RadioTargeted.Checked  := true;
            DELAY_ACTOR:     RadioActor.Checked     := true;
            DELAY_SPAWN:     RadioSpawn.Checked     := true;
            DELAY_TAG: begin RadioTag.Checked       := true; EditTag.Text := sTime; end;
        end;
    end;
end;


// Saves the selected delay time.
procedure Tdelaycommand.BitBtn2Click(Sender: TObject);
var
    sTag: shortstring;
    new_lines: array[0..0] of shortstring;
begin
    // Reset our settings (some might not be needed).
    nType := DELAY_NONE;
    nTime := 0;
    sTime := '';

    if RadioTimed.Checked then begin
        if spinedit1.Value > 0 then begin
            // Store the timed delay (number of seconds)
            nType := DELAY_TIME;
            nTime := spinedit1.Value;
            sTime := inttostr(nTime);
        end;
    end
    else if RadioOwner.Checked then      nType := DELAY_OWNER
    else if RadioPC.Checked then         nType := DELAY_PC
    else if RadioActivator.Checked then  nType := DELAY_ACTIVATOR
    else if RadioTargeted.Checked then   nType := DELAY_TARGET
    else if RadioActor.Checked then      nType := DELAY_ACTOR
    else if RadioSpawn.Checked then      nType := DELAY_SPAWN
    else begin // Tag
        sTag := QuoteSwap(EditTag.Text);

        // Define the creature for this delay.
        new_lines[0] := s_oDelay+' = '+s_GetObject + sTag+'");';
        Tlilac.AddLines(new_lines);

        // After that (which resets the delay), define the delay.
        nType := DELAY_TAG;
        sTime := sTag;
    end;
end;


// Enables/disables the "Okay" button as appropriate.
procedure Tdelaycommand.ToggleOkay(Sender: TObject);
begin
    BitBtn2.Enabled := RadioTimed.Checked or not RadioTag.Checked or
                       (EditTag.Text <> '');
end;


// -----------------------------------------------------------------------------


// Called after the delay is used.
class procedure Tdelaycommand.ResetDelay(); inline;
begin
    nType := DELAY_NONE;
    nTime := 0;
    sTime := '';
end;


// Read-only access to the static field nTime.
// This is positive iff a timed delay is set.
class function Tdelaycommand.DelayTime(): integer; inline;
begin
    result := nTime;
end;


// Supplies the string corresponding to the current delay. If DelayTime() > 0,
// then this is that number converted to a string, for use in DelayCommand().
// Otherwise, (if a delay is set) this is the object whose action queue is to
// be used, for use in ActionDoCommand().
class function Tdelaycommand.DelayString(): shortstring;
begin
    case nType of
        DELAY_TIME:      result := sTime + '.0';
        DELAY_OWNER:     result := s_OBJECT_SELF;
        DELAY_PC:        result := s_oPC;
        DELAY_ACTIVATOR: result := s_oActivator;
        DELAY_TARGET:    result := s_oActTarget;
        DELAY_ACTOR:     result := s_oActor;
        DELAY_SPAWN:     result := s_oSpawn;
        DELAY_TAG:       result := s_oDelay;
        else result := ''; // No delay set.
    end;
end;


// Returns TRUE if a delay has been set.
class function Tdelaycommand.DelaySet(): boolean; inline;
begin
    result := nType <> DELAY_NONE;
end;


// Supplies a description of the delay for display to the user (in the event
// window title).
class function Tdelaycommand.DescString(): shortstring;
begin
    case nType of
        DELAY_TIME: begin result := sTime + ' second'; if nTime <> 1 then result += 's'; end;
        DELAY_OWNER:      result := 'the script owner';
        DELAY_PC:         result := 'the PC';
        DELAY_ACTIVATOR:  result := 'the item activator';
        DELAY_TARGET:     result := 'the activation target';
        DELAY_ACTOR:      result := Tlilac.last_actor;
        DELAY_SPAWN:      result := Tlilac.last_spawn;
        DELAY_TAG:        result := sTime;
        else result := ''; // No delay set.
    end;
end;


initialization
  {$i delay.lrs}
end.
