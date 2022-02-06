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
* Most of this was trimmed when I converted the form to being really modal, and
    when I pushed some error checking into the backend of the TEdit.
* Added the ability to use underscores in the script name.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit erfname;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms,
  {Dialogs,} StdCtrls, Buttons,
  {ShellAPI, LCLType,} LResources;


type
  TErfNameForm = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    procedure Edit1Change(Sender: TObject);
  end;


{var
  ErfNameForm: TErfNameForm;
}

// -----------------------------------------------------------------------------

implementation

{uses start, PaletteTool;}


// Validates the script name (only alphanumeric characters and underscores allowed).
procedure TErfNameForm.Edit1Change(Sender: TObject);
var
    iEntered, iAccepted: integer;
    sEntered, sAccepted: string[16];
begin
    sEntered := Edit1.Text;

    // Check for illegal characters.
    iAccepted := 0;
    for iEntered := 1 to length(sEntered) do
        case sEntered[iEntered] of
            'a'..'z', '0'..'9', '_':
                begin
                    Inc(iAccepted);
                    sAccepted[iAccepted] := sEntered[iEntered];
                end;
        end;
    // Truncate if needed.
    SetLength(sAccepted, iAccepted);

    // Update the TEdit?
    if sAccepted <> sEntered then
        Edit1.Text := sAccepted;

    // Enable the button?
    BitBtn1.Enabled := sAccepted <> '';
end;


initialization
  {$i erfname.lrs}
end.
