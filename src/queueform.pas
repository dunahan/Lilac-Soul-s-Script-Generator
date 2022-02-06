{
Copyright 2011 The Krit

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
This new unit is intended to reduce the redundancy of some event handler
implementations in the Script Generator.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit QueueForm;


interface

uses
  ExtForm;

type

    // This class is an extension of the TExtForm that adds event handlers
    // aimed at the forms with "Okay - more", "Okay - exit", and "Close" buttons.

    {TQueueForm }

    TQueueForm = class(TExtForm)
        // Provided event handlers.
        procedure ButtonClickOkayMore(Sender: TObject);
        procedure ButtonClickOkayExit(Sender: TObject);
        procedure ButtonClickClose(Sender: TObject);

      protected
        // Abstract methods required in descendent classes.
        procedure ClearForm();  virtual; abstract;
        procedure QueueThis();  virtual; abstract;
        // Sending the queue is no longer abstract.
        procedure SendQueue();  virtual;
    end;


implementation

// -----------------------------------------------------------------------------
    {TQueueForm }


// Handles clicks of an "Okay - more" button.
procedure TQueueForm.ButtonClickOkayMore(Sender: TObject);
begin
    QueueThis();
    ClearForm();
end;


// Handles clicks of an "Okay - exit" button.
procedure TQueueForm.ButtonClickOkayExit(Sender: TObject);
begin
    QueueThis();
    SendQueue();
end;


// Handles clicks of a "Close" button on forms with a queue to send.
procedure TQueueForm.ButtonClickClose(Sender: TObject);
begin
    SendQueue();
end;


// Dummy function because some forms are using TQueueForm but not actually
// queueing anything.
procedure TQueueForm.SendQueue();
begin
end;


end.

