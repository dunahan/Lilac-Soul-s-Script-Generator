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
* Some of this was trimmed when I converted the form to being really modal
    instead of simulated modal, and the rest got shunted off to more appropriate
    units (main and nwn).
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit confirm_clear;


interface

uses
  {Windows,} {Messages,} SysUtils, {Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons, {Registry,}
  LResources, Classes;

type

  { Tconfirmclear }

  Tconfirmclear = class(TForm)
    Label1: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
  end;

{var
  confirmclear: Tconfirmclear;
}

implementation


{ Tconfirmclear }


// This is a warning window, so beep when it is created.
procedure Tconfirmclear.FormCreate(Sender: TObject);
begin
    beep();
end;


initialization
  {$i confirm_clear.lrs}
end.
