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
* Much of this was trimmed when I converted the form to being modal.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit popup;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons,
  LResources, Registry;

type

  { Tpopup_ev }

  Tpopup_ev = class(TForm)
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    BitBtn1: TBitBtn;
    procedure NeverAgain(Sender: TObject);

  public
    class function  IsSuppressed(): boolean;          inline;
    class procedure SetSuppressed(bSetting: boolean); inline;
  end;


implementation

uses
    start;

var  // Unit-wide variable because static class fields were causing crashes.
     // Not made global because I want the namespace qualifier used, to identify
     // which unit "owns" this.
    Suppress: boolean;


// Records the "Never again" choice.
procedure Tpopup_ev.NeverAgain(Sender: TObject);
var
    Registry: TRegistry;
begin
    // Record this choice in active memory.
    Suppress := checkbox1.Checked;

    // Also make a more permanent record.
    Registry := TRegistry.Create();
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    // There is no need to create a key to record "false".
    if Registry.OpenKey(RegKey, Suppress) then begin
        // Record this directive.
        Registry.WriteBool(RegEvSuppress, Suppress);
        Registry.CloseKey();
    end;
    registry.Free();
end;


// Provides read access to Suppress.
class function  Tpopup_ev.IsSuppressed(): boolean;          inline;
begin
    result := Suppress;
end;


// Provides write access to Suppress.
class procedure Tpopup_ev.SetSuppressed(bSetting: boolean); inline;
begin
    Suppress := bSetting;
end;


initialization
  {$i popup.lrs}
end.
