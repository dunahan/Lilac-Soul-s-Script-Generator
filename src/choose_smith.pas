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
    instead of simulated modal.
* Most of the rest got shunted off to the black_smith unit to promote modularity.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit choose_smith;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics,} Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  LResources;

type

  { Tchoose_blacksmith }

  Tchoose_blacksmith = class(TForm)
    // Form elements
    ComboBox1: TComboBox;
    copywindow: TMemo;
    Label1: TLabel;
    BitBtn2: TBitBtn;
    LabelBadScript: TLabel;
    LabelDoWhat: TLabel;
    Panel1: TPanel;
    loadnss: TOpenDialog;
    // Event handlers
    procedure ComboBox1Change(Sender: TObject);
  end;

{var
  choose_blacksmith: Tchoose_blacksmith;
}

// -----------------------------------------------------------------------------

implementation


uses
    start, black_smith;


procedure Tchoose_blacksmith.ComboBox1Change(Sender: TObject);
var
    nss: textfile;
    nssline: string;
begin
    // Combobox1.itemindex codes:
    //  0: New blacksmith script
    //  1: Continue script that was pasted into the box on this form
    //  2: Continue script loaded from .nss file
    case combobox1.itemindex of
        0:  ModalResult := mrOk;

        1:  // Try to load the script.
            if not Tblacksmith.LoadExistingScript(copywindow.Lines) then
                // Show the error panel.
                panel1.visible := true
            else
                ModalResult := mrOk;

        2:  // Get a file from which to read.
            if not loadnss.execute then
                panel1.visible := false
            else begin
                // Copy the file's contents into this form.
                copywindow.clear();
                AssignFile(nss, loadnss.filename);
                reset(nss);
                while not eof(nss) do begin
                    readln(nss, nssline);
                    copywindow.lines.add(nssline);
                end;
                Closefile(nss);
                // Restore the old working directory.
                main.RestoreWorkingDirectory();

                // Try to load the script.
                if not Tblacksmith.LoadExistingScript(copywindow.Lines) then
                    panel1.visible := true
                else
                    ModalResult := mrOk;
            end;
    end;

    if ModalResult <> mrOk then begin
        // Reset (so the same option can be chosen again, if desired).
        combobox1.ClearSelection();
        combobox1.text := '';
    end;
end;


initialization
  {$i choose_smith.lrs}
end.
