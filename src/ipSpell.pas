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
* Most of this was trimmed when I converted the form to actually being modal.
* Added "Close" button and trimmed irrelevant bits of the BioWare comment.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit ipSpell;


interface

uses
  {Windows,} Buttons, {Messages, SysUtils, Classes, Graphics, Controls,} Forms,
  {Dialogs,} StdCtrls, LResources;

type

  { TipCastSpell }

  TipCastSpell = class(TForm)
      BitBtn4: TBitBtn;
      LabelInfo: TLabel;
    Memo1: TMemo;
  end;


implementation


initialization
  {$i ipSpell.lrs}
end.
