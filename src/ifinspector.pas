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
* Much of this was trimmed when I converted the form to being really modal instead
*   of simulated modal.
* The tracking of the "if"-tree got shifted here from the nwn unit.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit ifinspector;


interface

uses
  {Windows,} {Messages, SysUtils, Classes, Graphics, Controls,} Forms, {Dialogs,}
  StdCtrls, Buttons, LResources;

type

  { Tinspect }

  Tinspect = class(TForm)
    // Form elements
    iflist: TMemo;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    // Event handler.
    procedure FormCreate(Sender: TObject);

    // Communication from other units.
    class procedure ResetIfs();
    class procedure TrackIfTree(const if_this: shortstring; is_elseif: boolean=FALSE);
    class procedure UntrackIfTree();
  end;


{var
  inspect: Tinspect;
}

implementation

uses
    {event, nwn,}
    constants;

var // Unit-wide variables because static class fields were causing crashes.

    IfTree: array of shortstring; // Text to be displayed.
    indent: shortstring; // Not to be confused with Tlilac.indent.

// -----------------------------------------------------------------------------

{ Tinspect }


// Resets/initializes our private tracking of the "if" tree.
class procedure Tinspect.ResetIfs();
begin
    SetLength(IfTree, 0);
    indent := '';
end;


// Adds a clause to the "if"-tree.
// Set if_this to '' if this is an "else" clause.
// Do not set if_this to '' if the tree is empty!
class procedure Tinspect.TrackIfTree(const if_this: shortstring; is_elseif: boolean=FALSE);
var
    nLength: integer;
begin
    // We will be appending to the tree.
    nLength := Length(IfTree);
    SetLength(IfTree, nLength+1);

    // Increase the indent?
    // (Done for all but the first "if" -- not "else-if", not "else".)
    if (nLength > 0)  and  not is_elseif  and  (if_this <> '') then
        indent += '      ';

    // Which case are we handling?
    if if_this = '' then
        // "Else" clause
        IfTree[nLength] := indent + 'else (not the above)'
    else if is_elseif then
        // "Else-if" clause.
        IfTree[nLength] := indent + 'else, if '+if_this
    else
        // "If" clause.
        IfTree[nLength] := indent + 'If '+if_this;
end;


// Rolls back a level from the "if"-tree.
// (Called when an "if" statement is finally ended, after any "else" clauses).
// Do not call more often than TrackIfTree() is called with an "if" statement!
class procedure Tinspect.UntrackIfTree();
var
    iLine: integer;
begin
    // Find the beginning of the current "if".
    if indent = '' then
        iLine := -1
    else begin
        iLine := Length(IfTree)-1;
        while (iLine > 0)  and  StartsWith(IfTree[iLine], indent) do
            Dec(iLine);
    end;

    // Cut the entire current "if"-chain.
    SetLength(IfTree, iLine+1);

    // Decrease the indent.
    if indent <> '' then
        SetLength(indent, Length(indent)-6);
end;


// -----------------------------------------------------------------------------


// Load the "if"-tree when this form is created.
// This may assume that there is an "if"-tree to load.
procedure Tinspect.FormCreate(Sender: TObject);
var
    iLine: integer;
begin
    for iLine := 0 to High(IfTree) do
        iflist.Lines.Append(IfTree[iLine]);
end;


initialization
  {$i ifinspector.lrs}
end.
