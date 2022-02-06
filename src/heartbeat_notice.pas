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
* Most of this was trimmed when I converted the form to being really modal instead
*   of simulated modal, and reorganized how the next form is called.
* Added the option to abort if no PC is seen.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit heartbeat_notice;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons,
  LResources;

type

  { Theartbeatnotice }

  Theartbeatnotice = class(TForm)
    // Form elements
    ButtonNo: TBitBtn;
    ButtonYes: TBitBtn;
    Memo1: TMemo;
    MemoQuestion: TMemo;
    // Event handlers
    procedure ButtonYesClick(Sender: TObject);
  end;


{var
    heartbeatnotice: Theartbeatnotice;
}

implementation

uses
    {start, restraint_norm,}
    nwn, constants;


// Adds a validation of oPC to the script. (This is instead of checking if
// oPC is player-controlled, since we defined oPC as the nearest seen PC.)
procedure Theartbeatnotice.ButtonYesClick(Sender: TObject);
const
    validate_PC: array[0..2] of shortstring =
      ( '// Only fire if a PC is seen.',
        'if ( '+s_OBJECT_INVALID+' == '+s_oPC+' )',
        '    return;');
begin
    Tlilac.AddLines(validate_PC);
end;


initialization
  {$i heartbeat_notice.lrs}
end.
