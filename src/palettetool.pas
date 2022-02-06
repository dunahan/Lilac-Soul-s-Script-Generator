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
* Gutted significant parts to streamline the unit.
* Added ability to search hak paks and .erf's.
* Added capability to use custom talk tables.
* Added a cancel button.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit palettetool;

interface

uses
  {Windows,} {Messages,} SysUtils, Classes, {Graphics,} {Controls,} Forms,
  Dialogs, {registry,} StdCtrls, ExtCtrls, ComCtrls, Buttons, {clipbrd,}
  LResources,
  LCLType, FileUtil, BioFiles;


const
    // SEARCH_* constants for which group of resources to search.
    // (These end with plural nouns; singular nouns are another set of constants.)
    SEARCH_ITEMS      = 0;
    SEARCH_CREATURES  = 1;
    SEARCH_PLACEABLES = 2;


type

  { TPaletteWindow }

  TPaletteWindow = class(TForm)
    // Form elements
    ButtonCancel: TBitBtn;
    SearchBar: TEdit;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    ScriptList: TListBox;
    SearchProgress: TProgressBar;
    propwindow: TMemo;
    RadioGroup3: TRadioGroup;
    openmod: TOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    ContButton: TBitBtn;
    BitBtn1: TBitBtn;
    Button2: TBitBtn;
    // Event handlers
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ContButtonClick(Sender: TObject);
    procedure ScriptListClick(Sender: TObject);
    procedure ScriptListDblClick(Sender: TObject);
    procedure ScriptListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchBarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

  public
    // Overridden methods
    destructor Destroy(); override;
    function ShowModal(): Integer; override;  // Do not use. Use Load() instead.

    // This should be used instead of ShowModal.
    // The _Which_ parameter is a SEARCH_* constant, initalizing the search.
    class function Load(ResultTo: TCustomEdit; NameTo: TCustomEdit; Which: integer;
                        WantResRef: boolean=false): Integer;
    class procedure ResetPalette();

  private
    // Blueprint info:
    CreatureList:  TResourceList;
    ItemList:      TResourceList;
    PlaceableList: TResourceList;
    // Custom blueprints.
    ModCreatureList:  TResourceList;
    ModItemList:      TResourceList;
    ModPlaceableList: TResourceList;
    // Custom talk table.
    ModTalkName: ansistring;

    // Extra data for the search results list.
    // (Not using AddObject() because TListBox does not acknowledge the objects;
    //  they are neither preserved while sorting nor released upon clearing.)
    SearchListData: TGFFLocators;
    // Initial directory when opening modules.
    ModDefDirectory: ansistring;
    // How we return stuff.
    SendTo:     TCustomEdit;
    SendResRef: boolean; // The other option is sending the tag.
    SendName:   TCustomEdit;

    // Helper methods.
    procedure PrintProperties(var GFF: TMemoryStream);
    procedure SetCustomRadioButton(const mod_name: ansistring);

    // Private access to the inherited ShowModal() (called from a class function).
    function LaunchModal(): integer;
  end;


var
  PaletteWindow: TPaletteWindow = nil;


// -----------------------------------------------------------------------------
implementation

uses
    start;

const
    // Symbolic constants for the radio button values.
    PALETTE_STANDARD = 0;
    PALETTE_CUSTOM   = 1;
    PALETTE_MODULE   = 2;


// -----------------------------------------------------------------------------
// TPaletteWindow


// Called when the user tries to close the form.
// (This will just hide the window instead of destroying it.
//  This lets us avoid generating the palette again.)
procedure TPaletteWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caHide;
end;


// Called when this form is created.
// This is where the pallete is generated.
procedure TPaletteWindow.FormCreate(Sender: TObject);
var
    files_found: boolean;
begin
    // NOTE: I am currently not implementing the fix that I implemented in the
    //       BioSearcher though it would probably be the correct thing to do.
    //       However, my tests have not shown any missing results, so I think
    //       it's safe to leave it as it is. --Lilac Soul

    // I do not know what the fix is that Lilac Soul was talking about, so
    // the above might still be relevant. My best guess is that the fix was
    // to always look at chitin.key, which I have now fixed. One reason I
    // guess this is that I ran a debugging test and discovered that all
    // creature, item, and placeable blueprints from chitin.key are being
    // discarded as duplicates, at least with HotU installed and running
    // patch 1.69. I'll keep the chitin.key check in the code, though, since
    // the situation might change under different versions/expansions. --TK


    // --------------------
    // Primary initializations
    CreatureList  := TResourceList.Create();
    ItemList      := TResourceList.Create();
    PlaceableList := TResourceList.Create();

    ModCreatureList  := nil;
    ModItemList      := nil;
    ModPlaceableList := nil;

    ModTalkName := '';
    ModDefDirectory := '';  // Not initialized yet in case nwnloc changes before
                            // a module's palette is loaded.

    // --------------------
    // Load the appropriate .key files into memory.
    files_found := false;
    // This should be done in priority order, as in the case of conflicts,
    // Script Generator will keep the first record read.

    // Patch 1.69
    if fileexists(main.nwnloc+'xp3.key') then
      begin
        LoadBifKey(main.nwnloc+'xp3.key', CreatureList, ItemList, PlaceableList);
        files_found := true;
      end;

    // HotU:
    if fileexists(main.nwnloc+'xp2.key') then
      begin
        if fileexists(main.nwnloc+'xp2patch.key') then
            LoadBifKey(main.nwnloc+'xp2patch.key', CreatureList, ItemList, PlaceableList);
        LoadBifKey(main.nwnloc+'xp2.key', CreatureList, ItemList, PlaceableList);
        files_found := true;
      end

    // else, SoU:
    else if fileexists(main.nwnloc+'xp1.key') then
      begin
        if fileexists(main.nwnloc+'xp1patch.key') then
            LoadBifKey(main.nwnloc+'xp1patch.key', CreatureList, ItemList, PlaceableList);
        LoadBifKey(main.nwnloc+'xp1.key', CreatureList, ItemList, PlaceableList);
        files_found := true;
      end;

    // Vanilla: (not an "else" clause here -- always check chitin.key)
    if fileexists(main.nwnloc+'chitin.key') then
      begin
        // Always read chitin.key, but read patch.key only if no expansions.
        if not files_found and fileexists(main.nwnloc+'patch.key') then
            LoadBifKey(main.nwnloc+'patch.key', CreatureList, ItemList, PlaceableList);
        LoadBifKey(main.nwnloc+'chitin.key', CreatureList, ItemList, PlaceableList);
      end

    // Error detection -- NWN not detected.
    else if not files_found then
        Application.MessageBox('NWN not found. Unable to search standard palette. ' +
                               'If you are receiving this error but have NWN installed, ' +
                               'go to the "options" menu on the main program window and ' +
                               'locate NWN manually.',
                               'Error: NWN not located', mb_OK);

    // Let the lists release no longer needed memory.
    ItemList.DoneAdding();
    CreatureList.DoneAdding();
    PlaceableList.DoneAdding();
end;


// Called when this form is hidden.
procedure TPaletteWindow.FormHide(Sender: TObject);
begin
    // Reset the search.
    SearchBar.Text := '';
    ScriptList.Clear();
    PropWindow.Clear();
    ContButton.Enabled := false;
    SetLength(SearchListData, 0);
    // Restore default focus.
    FocusControl(SearchBar);
    // Other settings can be preserved between searches.
end;


// -------------------------------------

// Handles the clicking of the "Search" button.
procedure TPaletteWindow.Button1Click(Sender: TObject);
var
    PList: ^TResourceList;
    suppress_hak: boolean = false;
begin
    PList := nil; // Just in case.

    // Which list to search depends on radio button group 3 (custom/standard)
    // and radio button group 1 (item/creature/placeable).
    case RadioGroup3.ItemIndex of
        PALETTE_MODULE:
            begin
                suppress_hak := true;
                case radiogroup1.ItemIndex of
                    SEARCH_ITEMS:      PList := @ModItemList;
                    SEARCH_CREATURES:  PList := @ModCreatureList;
                    SEARCH_PLACEABLES: PList := @ModPlaceableList;
                end;
            end;
        PALETTE_CUSTOM:
            case radiogroup1.ItemIndex of
                SEARCH_ITEMS:      PList := @ModItemList;
                SEARCH_CREATURES:  PList := @ModCreatureList;
                SEARCH_PLACEABLES: PList := @ModPlaceableList;
            end;

        PALETTE_STANDARD:
            case radiogroup1.ItemIndex of
                SEARCH_ITEMS:      PList := @ItemList;
                SEARCH_CREATURES:  PList := @CreatureList;
                SEARCH_PLACEABLES: PList := @PlaceableList;
            end;
    end;

    // Perform the selected search.
    if PList^ <> nil then
        PList^.Search(SearchBar.Text, RadioGroup2.ItemIndex,
                      ScriptList, SearchListData, SearchProgress,
                      ModTalkName, suppress_hak)

    // Some feedback in case things go wrong.
    else if RadioGroup3.ItemIndex <> PALETTE_STANDARD then
        Application.MessageBox('The selected custom palette was not loaded. ' +
                               'Please try to reload the module palettes, ' +
                               'then try searching again.',
                               'Search Failure', MB_OK)
    else
        Application.MessageBox('Something has gone really wrong, as the ' +
                               'standard palettes are missing. Sorry.',
                               'Search Failure', MB_OK);

    if ScriptList.Items.Count > 0 then
        // Might as well move the focus to someplace useful.
        ScriptList.SetFocus();

    // Update the ability to continue.
    ContButton.Enabled := ScriptList.Items.Count > 0;
end;


// Handles the clicking oF the "Load custom" button.
procedure TPaletteWindow.Button2Click(Sender: TObject);
begin
    // Set the initial directory ("modules" unless something was opened before).
    if ModDefDirectory = '' then
        openmod.InitialDir := main.nwnloc+'modules'
    else
        openmod.InitialDir := ModDefDirectory;

    // Let the user select a module to load.
    if openmod.Execute() then begin
        // Save this directory.
        ModDefDirectory := ExtractFilePath(openmod.Filename);
        if ModDefDirectory = main.nwnloc+'modules' then
            ModDefDirectory := ''; // In case nwnloc changes.

        // Try to load the module's palette.
        if LoadMod(openmod.Filename, ModCreatureList, ModItemList, ModPlaceableList, ModTalkName) then
            // Success! Update the relevant radio button.
            SetCustomRadioButton(openmod.Filename)
        else
            // Failure! Update the relevant radio button.
            SetCustomRadioButton('');
    end;
end;


// Handles the button click that returns the requested data to the calling form.
procedure TPaletteWindow.ContButtonClick(Sender: TObject);
var
    line_num: integer;
    copy_length: integer;
    name: shortstring;
begin
    // ResRef/Tag return:
    if SendTo <> nil then begin
        // Returning a ResRef is easy.
        if SendResRef then
            SendTo.Text := ScriptList.Items[ScriptList.ItemIndex]
        else
            // Tags need to be located in the PropWindow.
            for line_num := 0 to PropWindow.Lines.Count-1 do
                if copy(PropWindow.Lines[line_num], 1, 5) = 'Tag: ' then begin
                    copy_length := Length(PropWindow.Lines[line_num]) - 5;
                    // Check for overflow.
                    if copy_length > SendTo.MaxLength then
                        copy_length := SendTo.MaxLength;
                    SendTo.Text := copy(PropWindow.Lines[line_num], 6, copy_length);
                    break;
                end;
    end;

    // Name return:
    if SendName <> nil then
        // Locate this name in the PropWindow.
        for line_num := 0 to PropWindow.Lines.Count-1 do
            if (copy(PropWindow.Lines[line_num], 1, 6) = 'Name: ') then begin
                copy_length := Length(PropWindow.Lines[line_num]) - 6;
                // Check for overflow.
                if copy_length > SendName.MaxLength then
                    copy_length := SendName.MaxLength;
                // Make sure we have something before overwriting the TEdit.
                name := copy(PropWindow.Lines[line_num], 7, copy_length);
                if name <> '' then
                    SendName.Text := name;
                break;
            end;
end;


// Handles clicks on the list of ResRefs that matched the last search.
// (Called "ScriptList" because Lilac Soul re-used BioSearcher code here.)
procedure TPaletteWindow.ScriptListClick(Sender: TObject);
var
    GFF: TMemoryStream;
    sError: shortstring;
    StartPos: TPoint = (X:0; Y:0);
begin
    // Empty the old output info.
    PropWindow.Clear();

    // Abort if no item was clicked.
    if ScriptList.ItemIndex < 0 then
        exit;

    // Check for data corruption.
    if ScriptList.ItemIndex > High(SearchListData) then begin
        PropWindow.Append('Internal error: list out of bounds (' +
                          inttostr(ScriptList.ItemIndex+1) + ' of ' + // "+1" for looks (in case ItemIndex equals the length).
                          inttostr(Length(SearchListData)) + ').');
        exit;
    end;

    // Find the file containing the GFF associated with the clicked entry.
    GFF := GetGFF(SearchListData[ScriptList.ItemIndex], sError);
    if GFF = nil then
        PropWindow.Append(sError)
    else begin
        // Print the desired properties in the output panel.
        PrintProperties(GFF);
        // Cleanup.
        GFF.Free();
    end;

    // Reset the output position.
    PropWindow.CaretPos := StartPos;
    // Hack for the Window version to reset the output position:
    PropWindow.Lines.Insert(0, '');
    PropWindow.Lines.Delete(0);
end;


// Handles double clicks of the list of search results.
// The first click should have selected the item, so this just
// sends the selection back to the calling form (via the
// "Continue" button).
procedure TPaletteWindow.ScriptListDblClick(Sender: TObject);
begin
    ContButton.Click();
end;


// When the <RETURN> key is (pressed and) released, select this item.
procedure TPaletteWindow.ScriptListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    // Only interested in the <RETURN> key.
    if key = VK_RETURN then
        // Simulate a click of the "Continue" button.
        ContButton.Click();
end;


// When the <RETURN> key is (pressed and) released, do a search.
procedure TPaletteWindow.SearchBarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    // Only interested in the <RETURN> key.
    if key = VK_RETURN then
        // Simulate a click of the "Search" button.
        BitBtn1.Click();
end;


// -------------------------------------

// An instance can be destroyed when someone wants to change the NWN directory.
destructor TPaletteWindow.Destroy();
begin
    // Release memory.
    CreatureList.Free();
    ItemList.Free();
    PlaceableList.Free();

    if ModCreatureList <> nil then
        ModCreatureList.Free();
    if ModItemList <> nil then
        ModItemList.Free();
    if ModPlaceableList <> nil then
        ModPlaceableList.Free();

    SetLength(SearchListData, 0);

    // Daisy chain.
    inherited Destroy();
end;


// Override the default function to do nothing.
// Call Load() instead.
function TPaletteWindow.ShowModal(): Integer;
begin
    Application.MessageBox('An attempt was made to load the palette window ' +
                           'through a discontinued mechanism. Aborting.',
                           'You found a bug', MB_OK);
    result := 0;
end;


// Private access to the inherited ShowModal() from a class function.
// Was inlined, but that caused a weird bug -- LCL thought the form was already visible.
function TPaletteWindow.LaunchModal(): integer;
begin
    result := inherited ShowModal();
end;


// Replacement for ShowModal().
// This requires the TEdit to which a tag or ResRef will be sent. one to which
// the name will be sent, and a parameter indicating what kinds of blueprints
// to search by default.
// The final parameter specifies whether a tag or a ResRef will be returned.
class function TPaletteWindow.Load(ResultTo: TCustomEdit; NameTo: TCustomEdit;
                                   Which: integer; WantResRef: boolean=false): Integer;
begin
    // Create the palette window if needed.
    if PaletteWindow = nil then
        Application.CreateForm(TPaletteWindow, PaletteWindow);

    // Specify the type of ResRef to search by default.
    PaletteWindow.RadioGroup1.ItemIndex := Which;

    // Record where to send the result.
    PaletteWindow.SendTo := ResultTo;
    PaletteWindow.SendName := NameTo;
    PaletteWindow.SendResRef := WantResRef;

    // Show the window.
    result := PaletteWindow.LaunchModal();
end;


// Dumps the palette so it will be reloaded from disk when/if needed.
class procedure TPaletteWindow.ResetPalette();
begin
    if PaletteWindow <> nil then begin
        PaletteWindow.Free();
        Palettewindow := nil;
    end;
end;


// Parses the provided GFF and outputs name, tag, description, and comment
// to the PropWindow.
procedure TPaletteWindow.PrintProperties(var GFF: TMemoryStream);
var
    Name, Tag, Desc, DescID, Comment: ansistring;
    sError: shortstring;
begin
    // Grab the information from the GFF.
    sError := ReadBlueprintProperties(GFF, Name, Tag, Desc, DescID, Comment, ModTalkName);
    if sError <> '' then begin
        // Problem reading the GFF. Abort.
        PropWindow.Append(sError);
        exit;
    end;

    // Format the output.
    PropWindow.Append('Name: ' + Name);
    PropWindow.Append('');
    PropWindow.Append('Tag: ' + Tag);
    // If only one of description/identified description is supplied, suppress the other.
    if (Desc <> '') or (DescID = '') then begin
        PropWindow.Append('');
        PropWindow.Append('Description:');
        PropWindow.Append(Desc);
    end;
    if DescID <> '' then begin
        PropWindow.Append('');
        PropWindow.Append('Description (identified):');
        PropWindow.Append(DescID);
    end;
    // Only display the comment if there is one.
    if Comment <> '' then begin
        PropWindow.Append('');
        PropWindow.Append('Comment:');
        PropWindow.Append(Comment);
    end;
end;


// Simple convenience procedure called when the custom palette is loaded
// or emptied. Send '' as a parameter to indicate the palette was emptied.
procedure TPaletteWindow.SetCustomRadioButton(const mod_name: ansistring);
var
    short_name: string[35];
begin
    // Squeeze mod_name down to 35 characters.
    if Length(mod_name) <= 35 then
        short_name := mod_name
    else
        // We take 10 letters from the left, then "(...)", then 20 letters from the right
        short_name := copy(mod_name, 1, 10) + '(...)' +
                      copy(mod_name, length(mod_name)-19, 20);

    // Is this setting or resetting the button?
    if mod_name = '' then begin
        // Custom palette emptied, so reset the radio button label, select
        // the standard palette, and prohibit the user from changing this.
        RadioGroup3.Items[PALETTE_CUSTOM] := 'Custom palette: None loaded';
        RadioGroup3.ItemIndex := PALETTE_STANDARD;
        RadioGroup3.Enabled := false;
      end
    else begin
        // Custom palette loaded, so update the radio button label, select
        // the newly-loaded palette, and give the user a choice.
        RadioGroup3.Enabled := true;
        RadioGroup3.Items[PALETTE_CUSTOM] := 'Custom palette: ' + short_name;
        RadioGroup3.ItemIndex := PALETTE_CUSTOM;
      end
end;


// -----------------------------------------------------------------------------
initialization
  {$i palettetool.lrs}
end.
