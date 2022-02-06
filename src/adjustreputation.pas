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
*   of simulated modal.
* Added party-wide option.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit adjustreputation;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls, Forms, Dialogs,}
  StdCtrls, ExtCtrls, ComCtrls, Buttons,
  LResources, ExtForm;

type

  { Trepadjust }

  Trepadjust = class(TExtForm)
    // Form elements
    adjustbar: TTrackBar;
    CheckParty: TCheckBox;
    EditTagged: TEdit;
    GroupFactionMember: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    RadioActor: TRadioButton;
    GroupLikeDislike: TRadioGroup;
    RadioOwner: TRadioButton;
    RadioSpawn: TRadioButton;
    RadioTagged: TRadioButton;
    RadioTargeted: TRadioButton;
    adjust: TStaticText;
    TextNotPlot: TStaticText;
    // Event handlers
    procedure FormCreate(Sender: TObject);
    procedure adjustbarChange(Sender: TObject);
    procedure ToggleOkay(Sender: TObject); override;
    procedure Button1Click(Sender: TObject);
  end;

{var
  repadjust: Trepadjust;
}

// -----------------------------------------------------------------------------

implementation

uses
    {event,} start, nwn,
    constants;


// Configures the form based on current circumstances.
procedure Trepadjust.FormCreate(Sender: TObject);
begin
    // Initialize radio buttons.
    main.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor, OBJECT_TYPE_CREATURE);
    main.InitActivationRadios(nil, RadioOwner, nil, RadioTargeted, OBJECT_TYPE_CREATURE);
    // Make sure the default is set to something visible.
    if RadioOwner.Checked and not RadioOwner.Visible then
        RadioTagged.Checked := true;
end;


// Keeps the feedback of the chosen value up-to-date.
procedure Trepadjust.adjustbarChange(Sender: TObject);
begin
    adjust.caption := inttostr(adjustbar.position);
end;


// Controls the enabled state of the "Okay" button.
procedure Trepadjust.ToggleOkay(Sender: TObject);
begin
    // All we need to check is that a tagged creature has a tag.
    BitBtn1.Enabled := not RadioTagged.Checked or (EditTagged.Text <> '');
end;


// Handles clicks of the "Okay" button.
procedure Trepadjust.Button1Click(Sender: TObject);
var
    adjust_who: TObjectEnum;
    party, dislike_flag: shortstring;
    party_desc, dislike: shortstring;

    last_line: integer;
    new_lines: array[0..2] of shortstring;
begin
    // Who will be liking the PC more/less?
    adjust_who := GetChosenObject(RadioOwner, nil, nil, RadioTargeted,
                                  RadioTagged, RadioActor, RadioSpawn);
    // Declare a variable if needed.
    if adjust_who = E_CHOOSE_Self then
        Tlilac.Declare(VAR_oSELF);

    // Party-wide?
    if CheckParty.Checked then begin
        Tlilac.Include(INC_PARTYWIDE);
        party := 'WithFaction';
        party_desc := 'the PC''s party ';
    end
    else begin
        party := '';
        party_desc := 'the PC ';
    end;

    // Like or dislike? (This is prepended to the amount of change.)
    if GroupLikeDislike.ItemIndex > 0 then begin
        dislike_flag := '-';
        dislike := ' dislike ';
    end
    else begin
        dislike_flag := '';
        dislike := ' like ';
    end;

    // The opening comment.
    new_lines[0] := '// Make '+ObjectDesc(adjust_who, EditTagged.Text)+
                        dislike +party_desc +'more.';
    last_line := 1;

    // Handle target definition.
    if adjust_who = E_CHOOSE_Tagged then begin
        new_lines[1] := s_oTarget+' = '+s_GetObject + QuoteSwap(EditTagged.text) +'");';
        last_line := 2;
    end;

    // Adjust the reputation.
    new_lines[last_line] := 'AdjustReputation'+party+'('+s_oPC+', '+ObjectVar(adjust_who)+', '+
                            dislike_flag + inttostr(adjustbar.position)+');';

    // Add the lines.
    Tlilac.AddLines(new_lines[0..last_line], last_line, last_line);
end;


initialization
  {$i adjustreputation.lrs}
end.
