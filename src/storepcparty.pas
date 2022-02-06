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
* Much of this was trimmed when I converted the form to being really modal instead
*   of simulated modal, and got rid of the "Okay - more" button. (I barely see a
*   use for this form, much less the need to store the same information in multiple
*   local variables.)
* Made it possible to simultaneously save PC and party info.
* Made it possible to delay the calculation of info.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit storepcparty;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, ExtCtrls, Buttons,
  LResources;

type

  { Tstoreinfo }

  Tstoreinfo = class(TForm)
      EditPartyGold: TEdit;
      EditPartyLevel: TEdit;
      EditPCGold: TEdit;
      EditPCLevel: TEdit;
      GroupPartyGold: TRadioGroup;
      GroupPartyLevel: TRadioGroup;
      GroupPCGold: TRadioGroup;
      GroupPCLevel: TRadioGroup;
      Label1: TLabel;
      Label2: TLabel;
      LabelPartyGold: TLabel;
      LabelPartyLevel: TLabel;
    Memo1: TMemo;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    TextAboutBlanks: TStaticText;
    // Event handlers
    procedure ToggleOkay(Sender: TObject);
    procedure SendInfo(Sender: TObject);
  end;

{var
  storeinfo: Tstoreinfo;
}


// -----------------------------------------------------------------------------

implementation

uses
    {event, start,} nwn,
    constants;


// Controls the enabled state of the "Okay" button.
procedure Tstoreinfo.ToggleOkay(Sender: TObject);
begin
    // Enable the button iff there is something to do.
    BitBtn2.Enabled := (EditPCGold.Text <> '')    or (EditPCLevel.Text <> '') or
                       (EditPartyGold.Text <> '') or (EditPartyLevel.Text <> '');
end;


// Sends the requested NWScript to the script window.
procedure Tstoreinfo.SendInfo(Sender: TObject);
var
    last_line: integer;
    new_lines: array[0..4] of shortstring;
begin
    // The opening comment:
    new_lines[0] := '// Store some information in local variables.';
    last_line := 0;

    // PC gold:
    if EditPCGold.text <> '' then begin
        Inc(last_line);
        new_lines[last_line] := 'SetLocalInt';
        if GroupPCGold.itemindex = 1 then begin
            // Make this party-wide.
            Tlilac.Include(INC_PARTYWIDE);
            new_lines[last_line] += 'OnAll';
        end;
        new_lines[last_line] += '('+s_oPC+', "'+QuoteSwap(EditPCGold.text)+'", '+
                                'GetGold('+s_oPC+'));';
    end;

    // PC level:
    if EditPCLevel.text <> '' then begin
        Inc(last_line);
        new_lines[last_line] := 'SetLocalInt';
        if GroupPCLevel.itemindex = 1 then begin
            // Make this party-wide.
            Tlilac.Include(INC_PARTYWIDE);
            new_lines[last_line] += 'OnAll';
        end;
        new_lines[last_line] += '('+s_oPC+', "'+QuoteSwap(EditPCLevel.text)+'", '+
                                'GetHitDice('+s_oPC+'));';
    end;

    // Party gold:
    if EditPartyGold.text <> '' then begin
        Inc(last_line);
        new_lines[last_line] := 'SetLocalInt';
        if GroupPartyGold.itemindex = 1 then begin
            // Make this party-wide.
            Tlilac.Include(INC_PARTYWIDE);
            new_lines[last_line] += 'OnAll';
        end;
        new_lines[last_line] += '('+s_oPC+', "'+QuoteSwap(EditPartyGold.text)+'", '+
                                'GetFactionGold('+s_oPC+'));';
    end;

    // Party level:
    if EditPartyLevel.text <> '' then begin
        Inc(last_line);
        new_lines[last_line] := 'SetLocalInt';
        if GroupPartyLevel.itemindex = 1 then begin
            // Make this party-wide.
            Tlilac.Include(INC_PARTYWIDE);
            new_lines[last_line] += 'OnAll';
        end;
        new_lines[last_line] += '('+s_oPC+', "'+QuoteSwap(EditPartyLevel.text)+'", '+
                                'GetFactionAverageLevel('+s_oPC+'));';
    end;

    // Add to the script window.
    Tlilac.AddLines(new_lines[0..last_line], 1, last_line);
end;


initialization
  {$i storepcparty.lrs}
end.
