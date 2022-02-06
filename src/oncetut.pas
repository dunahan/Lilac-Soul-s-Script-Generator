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
* Most of this was trimmed when I converted the form to being modal.
* Did some revisions to the text. (Tried to clarify some things, make other
    things more accurate, and the use of "I" was going to be ambiguous with
    a second person involved in coding the Generator.)
* Added a prefix to the local variable name to avoid conflicts with other
* "do once" scripts.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit oncetut;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons,
  LResources;

type

  { Tonce_tut }

  Tonce_tut = class(TForm)
      LabelAppearsWen: TLabel;
      LabelActionsTaken: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    BitBtn1: TBitBtn;
    TextAppearsWhen: TStaticText;
    TextActionsTaken: TStaticText;
    TextAppearsWhenNote: TStaticText;
    TextActionsTakenNote: TStaticText;
  end;


implementation


initialization
  {$i oncetut.lrs}
end.
