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
This is a new unit because the appearance form is rather full. It provides
access to SetColor(), introduced in NWN 1.69. --TK
}


{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit ColorC;


interface

uses
  Classes, LResources, Forms, Controls, ExtCtrls, StdCtrls, Buttons;

type

  { TColorCreature }

  TColorCreature = class(TForm)
      // Form elements
      ButtonMore: TBitBtn;
      ButtonOkay: TBitBtn;
      ButtonClose: TBitBtn;
      ImageTattoo: TImage;
      ImageSkin: TImage;
      ImageHair: TImage;
      PanelPCOnly: TPanel;
      RadioGroupChannel: TRadioGroup;
      ShapeChoseHair: TShape;
      ShapeChoseSkin: TShape;
      ShapeChoseTat1: TShape;
      ShapeChoseTat2: TShape;
      ShapeHighlight: TShape;
      TextPCOnly: TStaticText;
      // Event handlers
      procedure ButtonOkayClick(Sender: TObject);
      procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
                               Shift: TShiftState; X, Y: Integer);
      procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
                             Shift: TShiftState; X, Y: Integer);
      procedure RadioGroupChannelClick(Sender: TObject);

      // Redefine the interface for calling this.
      class function NewModal(HairTo, SkinTo, Tat1To, Tat2To : PInteger): integer;
      function ShowModal(): integer; override;
  private
      function  LaunchModal(): integer;

  private
      TrackMouse: boolean;
      RetHair, RetSkin, RetTat1, RetTat2 : PInteger;

      // Helper methods
      function  FeedbackShape(Selected: Integer): TShape; inline;
      procedure Select(ColorIndex: integer; Reference: TObject);
  end;


implementation

const
    // The channel selection
    CHANNEL_HAIR = 0;
    CHANNEL_SKIN = 1;
    CHANNEL_TAT1 = 2;
    CHANNEL_TAT2 = 3;

// -----------------------------------------------------------------------------
// Some short inline conversion utilities.

// Converts a column number to the x-coordinate of its left side.
function ColToLeft(Col: integer; Sender:TObject): integer; inline;
begin
    result := 1 + 32*Col + TControl(Sender).Left;
end;


// Converts a row number to the y-coordinate of its top side.
function RowToTop(Row: integer; Sender:TObject): integer; inline;
begin
    result := 1 + 32*Row + TControl(Sender).Top;
end;


// Converts an x-coordinate to the column (of colored squares).
function XToCol(x: integer): integer; inline;
begin
    // A few special cases because the images have a slight border.
    if      x < 33  then result := 0
    else if x > 480 then result := 15
    else                 result := (x-1) div 32;
end;


// Converts a y-coordinate to the row (of colored squares).
function YToRow(y: integer): integer; inline;
begin
    // A few special cases because the images have a slight border.
    if      y < 33  then result := 0
    else if y > 320 then result := 10
    else                 result := (y-1) div 32;
end;


// -----------------------------------------------------------------------------

{ TColorCreature }


// Handles clicks of the "Okay" buttons.
procedure TColorCreature.ButtonOkayClick(Sender: TObject);
var
    Selected: Integer;
    SendTo:   PInteger;
    RefImage: TImage;
    Feedback: TShape;
    Row, Col: Integer;
begin
    Selected := RadioGroupChannel.ItemIndex;

    // Determine what we should be working with.
    case Selected of
        CHANNEL_HAIR: begin SendTo := RetHair; RefImage := ImageHair;   end;
        CHANNEL_SKIN: begin SendTo := RetSkin; RefImage := ImageSkin;   end;
        CHANNEL_TAT1: begin SendTo := RetTat1; RefImage := ImageTattoo; end;
        CHANNEL_TAT2: begin SendTo := RetTat2; RefImage := ImageTattoo; end;
    end;
    Feedback := FeedbackShape(Selected);

    if SendTo <> nil then
    begin
        // Convert the selection to a color index.
        Row := YToRow(ShapeHighlight.Top - RefImage.Top);
        Col := XToCol(ShapeHighlight.Left - RefImage.Left);
        SendTo^ := Row*16 + Col;

        // Visual feedback that this was recorded.
        Feedback.Visible := true;
    end;

    // Advance to the next channel if we are sticking around.
    if TCustomButton(Sender).ModalResult = mrNone then
        repeat
            RadioGroupChannel.ItemIndex := (RadioGroupChannel.ItemIndex + 1) mod 4;
        until not FeedbackShape(RadioGroupChannel.ItemIndex).Visible or
              (RadioGroupChannel.ItemIndex = Selected);
end;


// Begins visual feedback as to which color is selected.
procedure TColorCreature.ImageMouseDown(Sender: TObject; Button: TMouseButton;
                                        Shift: TShiftState; X, Y: Integer);
begin
    // Only respond to left-clicks.
    if Button <> mbLeft then
        exit;

    // Wake up the mouse-move event.
    TrackMouse := true;

    // Initialize the highlight.
    ShapeHighlight.Left := ColToLeft(XToCol(X), Sender);
    ShapeHighlight.Top  := RowToTop(YToRow(Y), Sender);
    ShapeHighlight.Visible := true;
end;


// Updates the highlight as the mouse moves with the button down.
procedure TColorCreature.ImageMouseMove(Sender: TObject; Shift: TShiftState;
                                        X, Y: Integer);
begin
    // Do nothing if we are not in the middle of tracking the mouse.
    if not TrackMouse then
        exit;

    if not (ssLeft in Shift) then
        // Mouse up must have happened outside the image.
        Select(-1, Sender)
    else begin
        // Update our highlight.
        ShapeHighlight.Left := ColToLeft(XToCol(X), Sender);
        ShapeHighlight.Top  := RowToTop(YToRow(Y), Sender);
    end;
end;


// Records the selection made.
procedure TColorCreature.ImageMouseUp(Sender: TObject; Button: TMouseButton;
                                      Shift: TShiftState; X, Y: Integer);
begin
    // Only track left-clicks.
    if Button <> mbLeft then
        exit;

    // Put the mouse-move event to sleep.
    TrackMouse := false;

    // Allow this color to be confirmed.
    ButtonMore.Enabled := true;
    ButtonOkay.Enabled := true;
end;


// Handles changes to the channel selection.
procedure TColorCreature.RadioGroupChannelClick(Sender: TObject);
var
    OldColor: integer;
begin
    // Update which colors are shown
    ImageHair.Visible := RadioGroupChannel.ItemIndex = 0;
    ImageSkin.Visible := RadioGroupChannel.ItemIndex = 1;
    ImageTattoo.Visible := RadioGroupChannel.ItemIndex > 1;

    // Update the selection.
    case RadioGroupChannel.ItemIndex of
        CHANNEL_HAIR: if RetHair <> nil then OldColor := RetHair^ else OldColor := -1;
        CHANNEL_SKIN: if RetSkin <> nil then OldColor := RetSkin^ else OldColor := -1;
        CHANNEL_TAT1: if RetTat1 <> nil then OldColor := RetTat1^ else OldColor := -1;
        CHANNEL_TAT2: if RetTat2 <> nil then OldColor := RetTat2^ else OldColor := -1;
    end;
    // I am going to assume the compiler will optimize these two case statements.
    case RadioGroupChannel.ItemIndex of
        CHANNEL_HAIR: Select(OldColor, ImageHair);
        CHANNEL_SKIN: Select(OldColor, ImageSkin);
        CHANNEL_TAT1: Select(OldColor, ImageTattoo);
        CHANNEL_TAT2: Select(OldColor, ImageTattoo);
    end;
end;


// -----------------------------------------------------------------------------


function TColorCreature.FeedbackShape(Selected: Integer): TShape; inline;
begin
 case Selected of
        CHANNEL_HAIR: result := ShapeChoseHair;
        CHANNEL_SKIN: result := ShapeChoseSkin;
        CHANNEL_TAT1: result := ShapeChoseTat1;
        CHANNEL_TAT2: result := ShapeChoseTat2;
    end;
end;


// Selects the indicated color, or selects none if negative.
procedure TColorCreature.Select(ColorIndex: integer; Reference: TObject);
begin
    // Move the selection.
    if ColorIndex >= 0 then begin
        ShapeHighlight.Left := ColToLeft(ColorIndex mod 16, Reference);
        ShapeHighlight.Top  := RowToTop(ColorIndex div 16, Reference);
    end;

    // Adjust visibility.
    ShapeHighlight.Visible := ColorIndex >= 0;
    ButtonMore.Enabled     := ColorIndex >= 0;
    ButtonOkay.Enabled     := ColorIndex >= 0;
end;


// -----------------------------------------------------------------------------


// Private access to the inherited ShowModal() from a class function.
function TColorCreature.LaunchModal(): integer;
begin
    result := inherited ShowModal();
end;


class function TColorCreature.NewModal(HairTo, SkinTo, Tat1To, Tat2To : PInteger) : integer;
var
  NewForm: TColorCreature;
begin
    // Create a color selection window.
    Application.CreateForm(TColorCreature, NewForm);

    // Record where to send the result.
    NewForm.RetHair := HairTo;
    NewForm.RetSkin := SkinTo;
    NewForm.RetTat1 := Tat1To;
    NewForm.RetTat2 := Tat2To;

    // Some initializations.
    NewForm.TrackMouse := false;
    if HairTo^ >= 0 then begin
        NewForm.ShapeChoseHair.Visible := true;
        NewForm.RadioGroupChannel.ItemIndex := 1;
    end;
    if SkinTo^ >= 0 then begin
        NewForm.ShapeChoseSkin.Visible := true;
        if NewForm.RadioGroupChannel.ItemIndex = 1 then
            NewForm.RadioGroupChannel.ItemIndex := 2;
    end;
    if Tat1To^ >= 0 then begin
        NewForm.ShapeChoseTat1.Visible := true;
        if NewForm.RadioGroupChannel.ItemIndex = 2 then
            NewForm.RadioGroupChannel.ItemIndex := 3;
    end;
    if Tat2To^ >= 0 then begin
        NewForm.ShapeChoseTat2.Visible := true;
        if NewForm.RadioGroupChannel.ItemIndex = 3 then
            NewForm.RadioGroupChannel.ItemIndex := 0;
    end;

    // Show the window.
    result := NewForm.LaunchModal();
    NewForm.Free();
end;


// Blocks the uncerlying ShowModal(); use NewModal() instead.
function TColorCreature.ShowModal(): integer;
begin
    Application.MessageBox('An attempt was made to load the color window ' +
                           'through a discontinued mechanism. Aborting.',
                           'You found a bug', 0);
    result := 0;
end;


initialization
  {$I colorc.lrs}
end.

