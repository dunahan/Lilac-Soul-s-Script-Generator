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
* Cleanup of the generated scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit iffollower;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, ExtCtrls,
  LResources;


type
  Tfollowers = class(TForm)
    Memo1: TMemo;
    RadioGroup1: TRadioGroup;
    procedure RadioGroup1Click(Sender: TObject);
  end;


{var
  followers: Tfollowers;
}

implementation

uses
    start, {restraint_norm,} nwn,
    constants;


procedure Tfollowers.RadioGroup1Click(Sender: TObject);
const
    master_check: array[0..2] of shortstring =
      ( '// We are really interested in the ultimate master of the killer.',
        'while ( GetMaster('+s_oPC+') != '+s_OBJECT_INVALID+' )',
        '    oPC = GetMaster(oPC);' );
var
    back_track: integer;
begin
    // Do we need to backtrack before the "is PC" check?
    if main.GetUsePCCheck(USED_ONDEATH) then
        back_track := 1
    else
        back_track := 0;

    // Add the code to shift the killing credit up to the master?
    if radiogroup1.itemindex = 0 then
        Tlilac.AddLinesBT(master_check, back_track);

    // This form is done.
    Close();
end;


initialization
  {$i iffollower.lrs}
end.
