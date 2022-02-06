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
*   of simulated modal and reorganized how the next form is invoked.
* Redesigned the window with expanded options.
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit restraint_norm;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, ExtCtrls, Buttons,
  LResources;

type

  { Trestraint }

  Trestraint = class(TForm)
    // FOrm elements
    BitBtn1: TBitBtn;
    ButtonOK: TBitBtn;
    ButtonMore: TBitBtn;
    GroupEach: TRadioGroup;
    GroupOnly: TRadioGroup;
    TextEach2: TStaticText;
    TextMakeRestraint: TStaticText;
    // Event handlers
    procedure ButtonOKClick(Sender: TObject);
  end;


{var
  restraint: Trestraint;
}

// -----------------------------------------------------------------------------

implementation

uses
    {start, event,} nwn, {other_restrict,}
    constants;


// Makes the restraint for this window.
procedure Trestraint.ButtonOKClick(Sender: TObject);
var
    on_whom:   shortstring;
    per_what:  string[7];
    var_name:  shortstring;
    new_lines: array[0..3] of shortstring;
begin
    var_name := '"DO_ONCE'; // Double quote ended in the following "case" statement.

    // There are four cases to cover.
    case GroupOnly.ItemIndex of
        0:  begin // Once per PC.
                per_what := ' per PC';
                case GroupEach.ItemIndex of
                    0:  begin // Once per object running the script.
                            on_whom  := s_OBJECT_SELF;
                            var_name += '__" + ObjectToString('+s_oPC+')';
                        end;
                    1:  begin // Once per tag
                            on_whom := s_oPC;
                            var_name += '__" + GetTag('+s_OBJECT_SELF+')';
                        end;
                end;
            end;

        1:  begin // Once per game.
                per_what := '';
                case GroupEach.ItemIndex of
                    0:  begin // Once per object running the script.
                            on_whom  := s_OBJECT_SELF;
                            var_name += '"';
                        end;
                    1:  begin // Once per tag
                            on_whom := s_GetModule;
                            var_name += '__" + GetTag('+s_OBJECT_SELF+')';
                        end;
                end;
            end;
    end;

    // The lines to add.
    new_lines[0] := '// Only fire once'+ per_what+'.';
    new_lines[1] := 'if ( GetLocalInt('+on_whom+', '+var_name+') )';
    new_lines[2] := s_Return;
    new_lines[3] := 'SetLocalInt('+on_whom+', '+var_name + s_comma_TRUE+');';

    // Add them.
    Tlilac.AddLines(new_lines);
end;


initialization
  {$i restraint_norm.lrs}
end.
