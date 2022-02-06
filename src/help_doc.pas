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
* Consolidated the "Click" procedures.
* Updated the credits, dropping those portions that have been dropped.
* Got in contact with Martin Verna, and he suggested dropping the 140th
    Pennsylvania Volunteer Infantry Reenactors website (http://www.140pvi.com/)
    as an example of his work.
}


{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit help_doc;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics,} Controls, Forms, {Dialogs,}
  ExtCtrls, StdCtrls, {ShellAPI, jpeg,} Buttons,
  LResources, LCLIntf, ClipBrd;

type

  { Thelpdoc }

  Thelpdoc = class(TForm)
    // Form elements
    Image1: TImage;
    Label1: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label21b: TLabel;
    Label3: TLabel;
    TheLabel4: TLabel;
    Panel1: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Image3: TImage;
    BitBtn1: TBitBtn;
    Image2: TImage;
    Label21: TLabel;
    // Event handlers
    procedure Image3Click(Sender: TObject);
    procedure LabelHTMLClick(Sender: TObject);
    procedure LabelEmailClick(Sender: TObject);
  end;


{var
  helpdoc: Thelpdoc;
}

// -----------------------------------------------------------------------------

implementation


// Handles clicks to the compiler logo so people can more easily find out about
// the Lazarus project.
procedure Thelpdoc.Image3Click(Sender: TObject);
begin
    // Try to open the web page stored in the hint (it's there so people can see
    // where they are going before clicking).
    if not OpenURL(Image3.Hint) then
        // Backup plan: copy the address.
        Clipboard.AsText := Image3.Hint;
end;


// Handles clicks to a label that is a web page address.
procedure Thelpdoc.LabelHTMLClick(Sender: TObject);
begin
    // Try to open the web page (stored in the caption).
    if not OpenURL(TControl(Sender).Caption) then
        // Backup plan: copy the address.
        Clipboard.AsText := TControl(Sender).Caption;
end;


// Handles clicks to a label that is an email address.
procedure Thelpdoc.LabelEmailClick(Sender: TObject);
begin
    // Try to start an email message to the address stored in the caption.
    if not OpenURL('mailto:'+TControl(Sender).Caption) then
        // Backup plan: copy the address.
        Clipboard.AsText := TControl(Sender).Caption;
end;


initialization
  {$i help_doc.lrs}
end.
