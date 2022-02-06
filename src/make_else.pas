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
* The rest basically got shifted over to the chooseif unit for better modularity.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit make_else;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons,
  LResources;

type
  Tmakeelse = class(TForm)
    // Form elements
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    // Event handlers
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  end;

{var
  makeelse: Tmakeelse;
}

// -----------------------------------------------------------------------------
implementation

uses
    {event, ifinspector, start, nwn,} chooseif;


// Handles the button for making an "else" clause.
procedure Tmakeelse.Button1Click(Sender: TObject);
begin
    // Handled by the ifchoose unit because of the bookkeeping involved.
    Tifchoose.MakeElse();
end;


// Handles the button for finishing an "if" statement.
procedure Tmakeelse.Button2Click(Sender: TObject);
begin
    // Handled by the ifchoose unit because of the bookkeeping involved.
    Tifchoose.EndIf();
end;


// Handles the button for making an "else-if" clause.
procedure Tmakeelse.BitBtn3Click(Sender: TObject);
begin
    // Turn this over to the ifchoose unit so the condition can be selected.
    Tifchoose.MakeElseIf();
end;


initialization
  {$i make_else.lrs}
end.
