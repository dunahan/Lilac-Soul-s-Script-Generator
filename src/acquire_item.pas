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
* Some of this was trimmed when I converted the form to being officially modal
    instead of simulated modal.
* Converted the "new" method so that it requires only one script, rather than
    one script plus one script per handled event.
* Merged this form with the equip/unequip one.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit acquire_item;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons, ExtCtrls,
  LResources;

type

  { Tacquire }

  Tacquire = class(TForm)
    // Form elements
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    BitBtn3: TBitBtn;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn4: TBitBtn;
    GroupSystem: TRadioGroup;
    // Event handlers.
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  end;

{var
  acquire: Tacquire;
}

// -----------------------------------------------------------------------------

implementation

uses
    start, nwn, {event,} EventHelper,
    constants;


// Handles clicks of the "show old system" button.
procedure Tacquire.BitBtn1Click(Sender: TObject);
begin
    TEventHelp.Popop(EventHelpOldSystem);
end;


// Handles clicks of the "show new system" button.
procedure Tacquire.BitBtn2Click(Sender: TObject);
begin
    TEventHelp.Popop(EventHelpNewSystem);
end;


// Handles clicks of the "compare systems" button.
procedure Tacquire.BitBtn4Click(Sender: TObject);
begin
    TEventHelp.Popop(EventHelpOldOrNew);
end;


// Handles clicks of the "continue" button.
procedure Tacquire.BitBtn3Click(Sender: TObject);
var
    var_name, store_on: shortstring;
    per_game: string[8];
    new_lines: array[0..3] of shortstring;
begin
    // Start the script.
    Tlilac.InitScript(SCRIPTTYPE_TAG_BASE + radiogroup1.itemindex, GroupSystem.ItemIndex=1);
    main.TagBasedType := SCRIPTTYPE_TAG_BASE + radiogroup1.itemindex;

    // Define oPC.
    new_lines[0] := 'object '+s_oPC+' = ';
    case radiogroup1.itemindex of
        0: new_lines[0] += 'oAcquiredBy;';
        1: new_lines[0] += 'oLostBy;';
        2: new_lines[0] += 'oEquippedBy;';
        3: new_lines[0] += 'oUnequippedBy;';
    end;
    Tlilac.AddLines(new_lines[0..0]);

    // Add a "PC only" restriction? (Only applicable in the (un)acquire events.)
    if (radiogroup1.itemindex < 2)  and  not main.MItemFirePCOnlyNever.Checked then begin
            // Make this abort on non-PCs.
            new_lines[0] := '// Only fire for PCs.';
            new_lines[1] := 'if ( !GetIsPC('+s_oPC+') )';
            new_lines[2] :=     s_Return;
            Tlilac.AddLines(new_lines[0..2]);
        end;

    // Add a "do once" restriction?
    if radiogroup2.itemindex > 0 then begin
        // Settings based on how often this is allowed to fire.
        case radiogroup2.itemindex of
            1:  begin  store_on := s_oPC;           per_game := 'per PC';   end;
            2:  begin  store_on := s_GetModule;     per_game := 'per game'; end;
        end;
        // Settings based on which event this is.
        case radiogroup1.itemindex of
            0: var_name := 'OnAcquire';
            1: var_name := 'OnUnAcquire';
            2: var_name := 'OnEquip';
            3: var_name := 'OnUnEquip';
        end;
        var_name := '"DOONCE_'+var_name+'_" + GetTag('+s_oEventItem+')';

        // Add the restriction.
        new_lines[0] := '// Only fire once '+per_game+'.';
        new_lines[1] := 'if ( GetLocalInt('+store_on+', '+var_name+') )';
        new_lines[2] :=     s_return;
        new_lines[3] := 'SetLocalInt('+store_on+', '+var_name + s_comma_TRUE +');';
        Tlilac.AddLines(new_lines);
    end;
end;


initialization
  {$i acquire_item.lrs}
end.
