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
* Changed the Show() function to be a class funciton that also takes care of
    making the form visible (as a modal popup).
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit EventHelper;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons,
  LResources, ExtCtrls, ExtForm;

type

  TEventHelpType = (EventHelpOldSystem, EventHelpNewSystem, EventHelpOldOrNew);

  { TEventHelp }

  TEventHelp = class(TExtForm)
    // Form elements
      GroupOldSystemScripts: TGroupBox;
      GroupNewSystemScripts: TGroupBox;
      LabelOldToNewScript: TLabel;
      MemoOldToNewScript: TMemo;
      MemoOldAcquire: TMemo;
      MemoNewAcquire: TMemo;
      MemoOldActivate: TMemo;
      MemoNewActivate: TMemo;
      MemoNewEquip: TMemo;
      MemoNewSystem: TMemo;
      MemoOldUnacquire: TMemo;
      MemoOldSystem: TMemo;
      MemoOldEquip: TMemo;
      MemoNewUnacquire: TMemo;
      MemoOldUnequip: TMemo;
    BitBtn1: TBitBtn;
    MemoNewUnequip: TMemo;
    OldOrNew: TMemo;
    PanelOldOrNew: TPanel;
    PanelOldSystem: TPanel;
    PanelNewSystem: TPanel;
    RadioNewAcquire: TRadioButton;
    RadioOldActivate: TRadioButton;
    RadioOldAcquire: TRadioButton;
    RadioNewActivate: TRadioButton;
    RadioOldEquip: TRadioButton;
    RadioNewEquip: TRadioButton;
    RadioOldUnacquire: TRadioButton;
    RadioNewUnacquire: TRadioButton;
    RadioOldUnequip: TRadioButton;
    RadioNewUnequip: TRadioButton;

  public
    class procedure Popop(which: TEventHelpType);
  end;

{var
  EventHelp: TEventHelp;
}

// -----------------------------------------------------------------------------

implementation


// Shows the form as a popup, with the specified topic visible.
class procedure TEventHelp.Popop(which: TEventHelpType);
var
    help_form: TEventHelp;
begin
    // Create the form to show.
    Application.CreateForm(TEventHelp, help_form);
    // Make the specified help visible.
    case which of
        EventHelpOldSystem:   help_form.PanelOldSystem.Visible := TRUE;
        EventHelpNewSystem:   help_form.PanelNewSystem.Visible := TRUE;
        EventHelpOldOrNew:    help_form.PanelOldOrNew.Visible  := TRUE;
    end;
    // Display the form.
    help_form.ShowModal();
    // Clean up.
    help_form.Release();
end;


initialization
  {$i EventHelper.lrs}
end.
