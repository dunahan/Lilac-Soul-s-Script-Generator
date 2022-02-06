{
Copyright 2011 The Krit
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
This is a new unit for starting conditional scripts, so that their options more
closely match the options for "if" statements. --TK
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit TimeConditional;


interface

uses
  Buttons, Classes, ExtCtrls, Spin, StdCtrls, SysUtils, LResources,
  {Forms,} Controls, ExtForm;

type

  { TCondTime }

  TCondTime = class(TExtForm)
      // Form elements
      ButtonClose: TBitBtn;
      ButtonOkay: TBitBtn;
      CheckDawn: TCheckBox;
      CheckDay: TCheckBox;
      CheckDusk: TCheckBox;
      SpinFrom: TSpinEdit;
      LabelFrom: TLabel;
      LabelTo: TLabel;
      LabelTitle: TLabel;
      MemoHoursOfDay: TMemo;
      MemoTimeOfDay: TMemo;
      CheckNight: TCheckBox;
      PanelHoursOfDay: TPanel;
      PanelTimeOfDay: TPanel;
      RadioHoursOfDay: TRadioButton;
      RadioTimeOfDay: TRadioButton;
      SpinTo: TSpinEdit;
      // Event handlers
      procedure ButtonOkayClick(Sender: TObject);
      procedure ToggleOkay(Sender: TObject); override;
  end;

{var
  CondTime: TCondTime;
}

// -----------------------------------------------------------------------------
implementation

{ TCondTime }

uses
    nwn, constants;

// Send the requested NWScript to the script window.
procedure TCondTime.ButtonOkayClick(Sender: TObject);
var
    hour_desc, hour_which: shortstring;
    condition: shortstring;

    new_lines: array[0..2] of shortstring;
begin
    // Some strings for the opening comment and conditional.
    if RadioHoursOfDay.Checked then begin
        hour_desc := 'hour';
        if SpinFrom.Value = SpinTo.Value then begin
            // A single hour.
            hour_which := SpinFrom.Text;
            condition  := 'GetTimeHour() != '+hour_which;
        end
        else begin
            // An interval, possibly crossing midnight.
            hour_which := 'from '+SpinFrom.Text+' to '+SpinTo.Text;
            condition  := 'GetTimeHour() < '+SpinFrom.Text+'  '+
                          BoolToStr(SpinFrom.value < SpinTo.value, '||', '&&')+
                          '  '+SpinTo.Text+' < GetTimeHour()';
        end;
    end
    else begin
        // One or more parts of the day were selected.
        hour_desc := 'time of day';
        hour_which := '';
        condition := '';
        // Build up the strings.
        if CheckDawn.Checked  then begin hour_which += 'dawn or '; condition += '!GetIsDawn()  &&  '; end;
        if CheckDay.Checked   then begin hour_which += 'day or ';  condition += '!GetIsDay()  &&  ';  end;
        if CheckDusk.Checked  then begin hour_which += 'dusk or '; condition += '!GetIsDusk()  &&  '; end;
        if CheckNight.Checked then begin hour_which += 'night';    condition += '!GetIsNight()';      end
        else begin
            // Trim off the last ' or ' and '  &&  '.
            SetLength(hour_which, Length(hour_which)-4);
            SetLength(condition, Length(condition)-6);
        end;
    end;

    // The opening comment.
    new_lines[0] := '// The current '+hour_desc+' must be '+hour_which+'.';
    new_lines[1] := 'if ( '+condition+' )';
    new_lines[2] := s_ReturnFalse;

    // Add the lines.
    Tlilac.AddLines(new_lines);
end;


// Controls the enabled state of the "Okay" button.
procedure TCondTime.ToggleOkay(Sender: TObject);
var
    bEnable: boolean;
begin
    // If selecting a time of day, at least one choice must be selected.
    if RadioTimeOfDay.Checked then
        bEnable := CheckNight.Checked  or  CheckDay.Checked  or
                   CheckDusk.Checked   or  CheckDawn.Checked
    else
        bEnable := TRUE;

    // Update the button.
    ButtonOkay.Enabled := bEnable;
end;


initialization
  {$I timeconditional.lrs}
end.

