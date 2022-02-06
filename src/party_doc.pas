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
* Some of this was trimmed when I converted the form to being modal (somewhat
  necessary because the calling form is now modal, and a quick search did not
  turn up a way to launch this window outside the modal loop).
* Form text changed as nw_i0_plot does not help (GetPLocalInt is bugged).
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit party_doc;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons, LResources;

type

  { Tpartydoc }

  Tpartydoc = class(TForm)
    // Form elements
    BitBtn1: TBitBtn;
    Label1: TLabel;
    LabelInfoFromLS: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    TextIntro: TStaticText;
  end;


implementation


initialization
  {$i party_doc.lrs}
end.
