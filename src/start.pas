// Make clcompile.exe work with spaces in a directory name.
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
  * System tray support did not survive the adaptation.
* Major revision of how global variables are used (moving or elimintating many).
* Several parts were shifted into the nwn unit.
* Some cleanup of the GUI.
* Cleanup of the generated scripts.
}

{Design note:
 Global information can be found both here and in the "nwn" unit. The nwn unit
 focuses on information that can change as a script is written, while this unit
 (start) focuses on more static information about the script as a whole, such as
 how it will be used. Generally, the information from this unit is used to control
 visibility, while that from nwn is used to control enabled/disabled. (Or at least
 that is the goal; I might fail to be consistent at some point.) -- TK
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

unit start;

{ $WARN UNIT_PLATFORM OFF }

interface

uses
  {Windows,} {Messages,} SysUtils, Classes, {Graphics,} Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Menus, {Spin, CheckLst, ComCtrls,}
  {jpeg,} {clipbrd,} Buttons, registry, {ImgList, filectrl,}
  LResources,
  {shellAPI, wininet,}
  LCLType, {InterfaceBase,} FileUtil, Process, ActnList, BioFiles;


// -----------------------------------------------------------------------------
type

  { Tmain }

  Tmain = class(TForm)
    // Form elements
      ActionSave: TAction;
      ActionCompile: TAction;
      ActionExport: TAction;
      ActionMerge: TAction;
      ActionClear: TAction;
      ActionListScript: TActionList;
    MItemFirePCOnlyWhenCritical: TMenuItem;
    MItemFirePCOnlyAlways:       TMenuItem;
    scripttype:     TComboBox;
    scriptwindow:   TMemo;
    conditional:    TComboBox;
    savescript:     TSaveDialog;
    MainMenu1:      TMainMenu;
    Scriptactions1: TMenuItem;
    Help1:          TMenuItem;
    howto:          TMenuItem;
    Exit2:          TMenuItem;
    Savescript1:    TMenuItem;
    Clearscript1:   TMenuItem;
    Bugssuggestionsfurtherhelp1:    TMenuItem;
    normalpanel:                    TPanel;
    calledfrom:                     TComboBox;
    Helpwithsomeconcepts1:          TMenuItem;
    Aboutthegeneratedcode1:         TMenuItem;
    Helpwithlocalvariablesdoonce1:  TMenuItem;
    BitBtn1:        TBitBtn;
    BitBtn2:        TBitBtn;
    BitBtn3:        TBitBtn;
    BitBtn4:        TBitBtn;
    BitBtn5:        TBitBtn;
    Options1:       TMenuItem;
    MItemFirePCOnlyNever: TMenuItem;
    Image2:                 TImage;
    Label1:                 TLabel;
    PopupMenu1:             TPopupMenu;
    Copyscripttoclipboard1: TMenuItem;
    N1:                     TMenuItem;
    saveandcompile:         TMenuItem;
    Savescript2:            TMenuItem;
    N2:                     TMenuItem;
    Saveappendtoerffile1:   TMenuItem;
    Savetomodulemodfile1:   TMenuItem;
    erfsave:                TSaveDialog;
    ErfMod:                 TOpenDialog;
    BackupSetting:          TMenuItem;
    Saveandcompilescript1:  TMenuItem;
    N3:                     TMenuItem;
    Saveappendandcompiletoerffile1:     TMenuItem;
    Saveappendandcompiletoerffile2:     TMenuItem;
    N4:                                 TMenuItem;
    // N5 was deleted.
    N6:                                 TMenuItem;
    LocateNeverwinterNightsmanually1:   TMenuItem;
    Deletemanuallystoredlocations1:     TMenuItem;
    // Event handlers
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    // (file menu)
    procedure Savescript1Click(Sender: TObject);
    procedure saveandcompileClick(Sender: TObject);
    procedure Saveappendtoerffile1Click(Sender: TObject);
    procedure Savetomodulemodfile1Click(Sender: TObject);
    procedure Clearscript1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    // (options menu)
    procedure MItemFirePCOnlyNeverClick(Sender: TObject);
    procedure MItemFirePCOnlyWhenCriticalClick(Sender: TObject);
    procedure MItemFirePCOnlyAlwaysClick(Sender: TObject);
    procedure BackupSettingClick(Sender: TObject);
    procedure LocateNeverwinterNightsmanually1Click(Sender: TObject);
    procedure Deletemanuallystoredlocations1Click(Sender: TObject);
    // (help menu)
    procedure howtoClick(Sender: TObject);
    procedure Aboutthegeneratedcode1Click(Sender: TObject);
    procedure Helpwithlocalvariablesdoonce1Click(Sender: TObject);
    procedure Helpwithsomeconcepts1Click(Sender: TObject);
    procedure Bugssuggestionsfurtherhelp1Click(Sender: TObject);
    // (popup)
    procedure Copyscripttoclipboard1Click(Sender: TObject);
    // (script creation)
    procedure scripttypeChange(Sender: TObject);
    procedure conditionalChange(Sender: TObject);
    procedure calledfromChange(Sender: TObject);
    procedure scriptwindowKeyDown(Sender: TObject; var Key: Word;
                                  Shift: TShiftState);
    procedure testClick(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);

  public
    // Some handy utilities.
    function  GetIsActivation()   : boolean; inline;
    function  GetIsConversation() : boolean; inline;
    function  GetIsItemScript()   : boolean; inline;
    function  GetUsePCCheck(option: integer): boolean;
    procedure InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted: TCustomCheckBox;
                                   goal_object: word; RadioLocation: TCustomCheckBox = nil);
    procedure InitRadioWhos(RadioOwner, RadioSpawn, RadioActor: TCustomCheckBox;
                            goal_object: word);
    procedure RestoreWorkingDirectory(); inline;
    function  ShowPopup(InstanceClass: TComponentClass) : integer;

  private
    // General information about the type of script.
    FActType:  word;        // The expected object type(s) of the target of item activation.
    FTagType:  word;        // The subtype of a tag-based script. (Possibly junk if not currently creating a tag-based script.)
    OwnerType: word;        // The possible OBJECT_TYPES of what will run this script.
    OwnerDesc: shortstring; // For display; a description of the object running this script.

    // Directory tracking.
    NWN_dir:      ansistring;   // Only changed in FormCreate() and LocateNeverwinterNightsmanually1Click().
    scriptgendir: ansistring;
    compiler_loc: byte;         // COMPILE_LOC_*

    // Helper methods.
    procedure CheckForCompiler();
    procedure SetScriptActions(bEnable: boolean);
    procedure StartScriptGeneration(FirstForm, SecondForm: TComponentClass);
    procedure StartOver();

    // Helper methods related to file saving/compiling.
    function  DoCompile(const sScriptName: ansistring) : boolean;
    procedure ExecNewProcess(const sCommandLine : string);
    function  GetScriptName(): TString16;
    procedure SaveToERF(const ScriptName: TString16; const ERFName: ansistring; bAppend: boolean);
    procedure SaveToNSS(const sFileName: ansistring);

  published
    property ActTargetType:  word        read FActType  write FActType;
    property ObjectType:     word        read OwnerType;
    property nwnloc:         ansistring  read NWN_dir;
    property ScriptOwner:    shortstring read OwnerDesc;
    property TagBasedType:   word        read FTagType  write FTagType;

  public
  end;


// -----------------------------------------------------------------------------
// Globals
var
  main:           Tmain;


const
    // Various string constants.
    ThisVersion   = 'TK.0';
    VaultID       = '1502';

    // Registry strings.
    RegKey        = '\Software\Lilac Soul\Script generator';
    RegVersion    = 'CurrentVersion';
    RegErfBackup  = 'BackupErfMod';
    RegNWNLoc     = 'AlternateNWNLocation';
    RegPCChecks   = 'CheckForPCs';
    RegEvSuppress = 'SuppressEventPopup';

    // For tracking what types of objects might be running a script.
    // (Bit flags; extended from NWScript.)
    OBJECT_TYPE_CREATURE       = $0001;
    OBJECT_TYPE_ITEM           = $0002;
    OBJECT_TYPE_TRIGGER        = $0004;
    OBJECT_TYPE_DOOR           = $0008;
    OBJECT_TYPE_AREA_OF_EFFECT = $0010;
    OBJECT_TYPE_WAYPOINT       = $0020;
    OBJECT_TYPE_PLACEABLE      = $0040;
    OBJECT_TYPE_STORE          = $0080;
    OBJECT_TYPE_ENCOUNTER      = $0100;
    OBJECT_TYPE_ALL            = $7FFF;
    // Non-NWScript:
    OBJECT_TYPE_NONE           = $0000;
    OBJECT_TYPE_MODULE         = $4000;
    OBJECT_TYPE_AREA           = $2000;
    // Used a number of times:
    OBJECT_TYPE_IN_AREA = not (OBJECT_TYPE_MODULE or OBJECT_TYPE_AREA or OBJECT_TYPE_ITEM)
                          and OBJECT_TYPE_ALL;

    // The options from the script type drop-down.
    // (Used in unit nwn.)
    SCRIPTTYPE_CONDITIONAL = 0;
    SCRIPTTYPE_NORMAL      = 1;
    SCRIPTTYPE_BLACKSMITH  = 2;
    SCRIPTTYPE_ACTIVATE    = 3;
    SCRIPTTYPE_TAGBASED    = 4;
    SCRIPTTYPE_TEMPLATE    = 5;
    // Larger indices for the tag-based subtypes.
    // (Mostly based on radio group options in Tacquire.)
    SCRIPTTYPE_TAG_BASE       = 32;
    SCRIPTTYPE_TAG_ACQUIRE    = SCRIPTTYPE_TAG_BASE + 0;
    SCRIPTTYPE_TAG_UNACQUIRE  = SCRIPTTYPE_TAG_BASE + 1;
    SCRIPTTYPE_TAG_EQUIP      = SCRIPTTYPE_TAG_BASE + 2;
    SCRIPTTYPE_TAG_UNEQUIPPED = SCRIPTTYPE_TAG_BASE + 3;
    SCRIPTTYPE_TAG_ACTIVATE   = SCRIPTTYPE_TAG_BASE + 8; // Not a Tacquire option.

    // The options from the called-from (normal script) drop-down.
    USED_INCONVERSATION    =  0;
    USED_ONENTER           =  1;
    USED_ONEXIT            =  2;
    USED_ONUSED            =  3;
    USED_ONDEATH           =  4;
    USED_ONOPEN            =  5;
    USED_ONCLOSED          =  6;
    USED_ONCLICK_DOOR      =  7;
    USED_ONCLICK_PLACEABLE =  8;
    USED_ONCLICK_TRIGGER   =  9;
    USED_ONHOSTILITIES     = 10;
    USED_ONPERCEIVED       = 11;
    USED_ONHEARTBEAT       = 12;
    USED_ONPCDEATH         = 13;
    USED_ONPCRESPAWN       = 14;
    CALLED_FROM_LAST       = 14; // Sizes some key arrays.


// -----------------------------------------------------------------------------
implementation

uses random_int, confirm_clear, confirm_exit, item_int, howto_use,
  numitems_int, pcgold_int, {pcstats_int,} statchoose_box, oncetut, local_int,
  help_doc, nwn, normscript_help, event, other_restrict, help_concept,
  codegen_doc, restraint_norm, {itemxp_give,} journal_int, {if_warning,}
  heartbeat_notice, black_smith, choose_smith, unique_power,
  iffollower, {delay,} acquire_item, PaletteTool, erfname, popup,
  constants, TimeConditional, TypeChoose;


const
    // Text for some drop-downs.
    condline  = 'What do you want to check for?';
    fromline  = 'Where is this script called from?';
    typeline  = 'Choose script type:';

    // The options from the conditional drop-down.
    CONDITIONAL_RANDOMNESS =  1;
    CONDITIONAL_HAS_ITEM   =  2;
    CONDITIONAL_HAS_ITEMS  =  3;
    CONDITIONAL_HAS_GOLD   =  4;
    CONDITIONAL_STATS      =  5;
    CONDITIONAL_JOURNAL    =  6;
    CONDITIONAL_LOCALS     =  7;
    CONDITIONAL_TIME       =  8;
    CONDITIONAL_DO_ONCE    = 10;

    // The degree of checking for PCs.
    // It is assumed that increasing values means checking in more places.
    CHECK_PCS_NEVER  = 0; // Program setting, not a script-type setting.
    CHECK_PCS_CRIT   = 1;
    CHECK_PCS_ALWAYS = 2;
    CHECK_PCS_NONEED = 3; // Script-type setting, not a program setting.

    // The location of the command-line compiler (so we do not have to keep checking the disk).
    COMPILE_LOC_NONE = 0;
    COMPILE_LOC_NWN  = 1;
    COMPILE_LOC_CUR  = 2;


// -----------------------------------------------------------------------------
// ****  Form events  ****
// -----------------------------------------------------------------------------


// Called when the main form is closed (e.g. by the system menu).
// See also Exit2Click().
procedure Tmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    // No need to confirm if the script has not really been started.
    if Tlilac.IsDirty() then
        if ShowPopUp(Tconfirmexit) <> mrOk then begin
            // Block the closing of this form.
            Action := caNone;
            exit;
        end;
end;


// Called when the program creates the main form.
procedure Tmain.FormCreate(Sender: TObject);
var
    Registry: TRegistry;
    old_version: boolean;
begin
    // Initializations.
    GetDir(0, scriptgendir);
    NWN_dir := '';
    Tpopup_ev.SetSuppressed(false); // In case there is no registry value to read.

    // Initialize local variables.
    old_version := true;
    Registry := TRegistry.Create();
    Registry.RootKey := HKEY_LOCAL_MACHINE;


    // Deal with the registry.

    // First, check to see if the registry version matches our version.
    if Registry.OpenKey(RegKey, false) then
        try
            if Registry.ValueExists(RegVersion) then
                old_version := ThisVersion <> Registry.ReadString(RegVersion);
            Registry.CloseKey();
        except // Possibly raised if RegVersion refers to a non-string value.
            Registry.CloseKey();
        end;

    // Second, sync our variables with the stored settings.
    if Registry.OpenKey(RegKey, true) then
      begin
        // Sync the backup setting.
        try
            if Registry.ValueExists(RegErfBackup) then
                BackupSetting.Checked := Registry.ReadBool(RegErfBackup)
            else
                Registry.WriteBool(RegErfBackup, BackupSetting.Checked);
        except  // Possibly raised if RegErfBackup refers to a non-boolean value.
        end;

        // Get the preference for checking for PCs ("always" vs. "critical"; the
        // "never" option is not saved).
        try
            if not Registry.ValueExists(RegPCChecks) then
                Registry.WriteBool(RegPCChecks, MItemFirePCOnlyAlways.Checked)
            else if Registry.ReadBool(RegPCChecks) then
                MItemFirePCOnlyAlways.Checked := TRUE
            else
                MItemFirePCOnlyWhenCritical.Checked := TRUE;
        except  // Possibly raised if RegPCChecks refers to a non-boolean value.
        end;

        // Grab the stored NWN location.
        try
            if Registry.ValueExists(RegNWNLoc) then
                NWN_dir := Registry.ReadString(RegNWNLoc);
        except  // Possibly raised if RegNWNLoc refers to a non-string value.
        end;

        // See if the event info popup is to be suppressed.
        try
            if Registry.ValueExists(RegEvSuppress) then
                Tpopup_ev.SetSuppressed(Registry.ReadBool(RegEvSuppress));
        except  // Possibly raised if RegEvSuppress refers to a non-boolean value.
        end;

        // Done for now.
        Registry.CloseKey();
      end;

    // Third, get rid of potential registry junk if we had a version mismatch.
    if old_version then
    begin
        // Delete the old...
        Registry.DeleteKey(RegKey);
        // ...then restore just the values we care about.
        if Registry.OpenKey(RegKey, true) then
        begin
            Registry.WriteString(RegVersion, ThisVersion);
            Registry.WriteBool(RegPCChecks,  MItemFirePCOnlyAlways.Checked);
            Registry.WriteBool(RegErfBackup, BackupSetting.Checked);
            if NWN_dir <> '' then
                Registry.WriteString(RegNWNLoc, NWN_dir);
            if Tpopup_ev.IsSuppressed() then
                Registry.WriteBool(RegEvSuppress, True);
            Registry.CloseKey();
        end;
    end;

    // See if we still need to locate a NWN installation.
    if NWN_dir = '' then
        // Try the BioWare registry entries.
        if Registry.OpenKey('\Software\BioWare\NWN\Neverwinter', false) then
            try
                if Registry.ValueExists('Location') then
                    // Found BioWare's location. Use it.
                    NWN_dir := AppendPathDelim(Registry.ReadString('Location'));
                Registry.CloseKey();
            except // Possibly raised if 'Location' refers to a non-string value.
                Registry.CloseKey();
            end;

    // Finally, release memory.
    Registry.Free();

    // Some configurations of the main window.
    CheckForCompiler();

    // Now that the global stuff is taken care of, initialize the major parts
    // of the Script Generator.
    Tlilac.ClearScript();
    Teventchooser.ResetEvents();
    Tblacksmith.ResetSmith();
end;


// -----------------------------------------------------------------------------
// ****  Menu events  ****
// -----------------------------------------------------------------------------


// -------------------------------------
// File menu

// Called when either of the "save script" menu options are used.
procedure Tmain.Savescript1Click(Sender: TObject);
begin
    // Make sure the script is syntactically complete.
    if Tlilac.IsComplete() then
        // Prompt for a file to which to save.
        if savescript.execute then begin
            // Save the script.
            SaveToNSS(savescript.filename);
            // Mark the script as clean (unchanged since last save).
            Tlilac.MarkClean();
        end;

    // Return to our home directory.
    RestoreWorkingDirectory();
end;


// Called when either of the "save and compile" menu options are used.
procedure Tmain.saveandcompileClick(Sender: TObject);
begin
    // Make sure the script is syntactically complete.
    if not Tlilac.IsComplete() then
        exit;

    // Prompt for a file to which to save.
    if savescript.execute then begin
        // Save the script.
        SaveToNSS(savescript.filename);
        Tlilac.MarkClean();

        // And compile it.
        DoCompile(savescript.FileName);
    end;

    // Return to our home directory.
    RestoreWorkingDirectory();
end;


// Called when either of the "save to erf" menu options are used.
procedure Tmain.Saveappendtoerffile1Click(Sender: TObject);
begin
    // Make sure the script is syntactically complete.
    if not Tlilac.IsComplete() then
        exit;

    // Prompt for an .erf file to which to save/append, probably in the erf directory.
    erfsave.InitialDir := nwnloc+'erf';
    if erfsave.execute then begin
        // Overwriting or appending?
        if not fileexists(erfsave.filename) then
            SaveToERF(GetScriptName(), erfsave.FileName, FALSE)
        else
            case Application.MessageBox(
                                'Do you want to append to this file?'#10#10 +
                                'Press "Yes" to append the current script to the existing .erf file.'#10 +
                                'Press "No" to overwrite the contents of the existing .erf file.'#10 +
                                'Press "Cancel" to do nothing.',
                                'Please choose how to proceed', MB_YESNOCANCEL) of

                IDYES: SaveToERF(GetScriptName(), erfsave.FileName, TRUE);  // Append
                IDNO:  SaveToERF(GetScriptName(), erfsave.FileName, FALSE); // Overwrite
                //IDCANCEL: Do nothing.
            end;
    end;

    // Return to our home directory.
    RestoreWorkingDirectory();
end;


// Called when either of the "save to module" menu options are used.
procedure Tmain.Savetomodulemodfile1Click(Sender: TObject);
begin
    // Make sure the script is syntactically complete.
    if not Tlilac.IsComplete() then
        exit;

    // Prompt for a module to which to save/append, probably in the modules directory.
    erfmod.InitialDir := nwnloc+'modules';
    if ErfMod.Execute then
        SaveToERF(GetScriptName(), ErfMod.FileName, TRUE);

    // Return to our home directory.
    RestoreWorkingDirectory();
end;


// Called when the "clear script" button or menu item is used.
procedure Tmain.Clearscript1Click(Sender: TObject);
begin
    if Tlilac.IsDirty() then
        // Really clear the script?
        if ShowPopUp(Tconfirmclear) <> mrOk then
            exit;

    StartOver();
end;


// Called when the "exit" button or menu item is used.
// See also FormClose().
procedure Tmain.Exit2Click(Sender: TObject);
begin
    // No need to confirm if the script has not really been started.
    if Tlilac.IsDirty() then
        if ShowPopUp(Tconfirmexit) <> mrOk then
            exit;

    // User said to end this thing, so end it.
    halt;
end;


// -------------------------------------
// Options menu

// Called when the user selects the option for "normal" scripts to never make
// an "is PC" check.
procedure Tmain.MItemFirePCOnlyNeverClick(Sender: TObject);
var
    OldSelection: TMenuItem;
begin
    // Confirm turning on this option.
    if not MItemFirePCOnlyNever.checked then
        if Application.MessageBox(AnsiString('')+ // Too long for a shortstring.
                'Using this option is generally not recommended, as most events '   +
                'are only interesting if triggered by a PC, yet some are also '     +
                'regularly triggered by NPCs. (For example, each placed or spawned '+
                'NPC triggers an OnEnter event for at least its area, and likely '  +
                'triggers OnPerception events for other NPCs in the area, even if ' +
                'there are no PCs logged into the game yet, much less present in '  +
                'that area.) This setting will not be saved, so the next time you ' +
                'start the Script Generator, this option will be turned off. In '   +
                'addition, this option will be turned off the next time the script '+
                'is cleared (to avoid problems if you forget  that you have it on).'+
                #10#10                                                              +
                'Are you sure you want to turn this option on?',
                'Please confirm', MB_YESNO) = IDYES then
            MItemFirePCOnlyNever.checked := TRUE;

    // Hack because the menu is visually changing the selection, even when the
    // selection does not change.
    if not MItemFirePCOnlyNever.Checked then begin
        // Get the option that is still selected (but not displayed as such).
        if MItemFirePCOnlyWhenCritical.Checked then
            OldSelection := MItemFirePCOnlyWhenCritical
        else // MItemFirePCOnlyAlways.Checked
            OldSelection := MItemFirePCOnlyAlways;

        // Force a recalculation of that option's painting.
        MItemFirePCOnlyNever.Checked := TRUE;
        OldSelection.Checked := TRUE;
    end;
end;


// Called when the user selects the option for "normal" scripts to make an
// "is PC" check only when typically desired.
procedure Tmain.MItemFirePCOnlyWhenCriticalClick(Sender: TObject);
var
    Registry: TRegistry;
begin
    // If already selected, nothing to do.
    if MItemFirePCOnlyWhenCritical.Checked then
        exit;

    // Turn on this option.
    MItemFirePCOnlyWhenCritical.Checked := TRUE;

    // Record this for future sessions.
    Registry := TRegistry.Create();
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey(RegKey, True) then
        Registry.WriteBool(RegPCChecks, FALSE);
    Registry.CloseKey();
    Registry.Free();
end;


// Called when the user selects the option for "normal" scripts to always make
// an "is PC" check.
procedure Tmain.MItemFirePCOnlyAlwaysClick(Sender: TObject);
var
    Registry: TRegistry;
begin
    // If already selected, nothing to do.
    if MItemFirePCOnlyAlways.Checked then
        exit;

    // Turn on this option.
    MItemFirePCOnlyAlways.Checked := TRUE;

    // Record this for future sessions.
    Registry := TRegistry.Create();
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey(RegKey, True) then
        Registry.WriteBool(RegPCChecks, TRUE);
    Registry.CloseKey();
    Registry.Free();
end;


// Called when the user toggles the selection for backing up files.
procedure Tmain.BackupSettingClick(Sender: TObject);
var
    Registry: TRegistry;
begin
    // Toggle the checked state.
    BackupSetting.checked := not BackupSetting.checked;

    // Record this for future sessions.
    Registry := TRegistry.Create();
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey(RegKey, True) then
        Registry.WriteBool(RegErfBackup, BackupSetting.checked);
    Registry.CloseKey();
    Registry.Free();
end;


// Called when the user wants to locate NWN manually (menu option).
procedure Tmain.LocateNeverwinterNightsmanually1Click(Sender: TObject);
var
    tempdir: ansistring;
    Registry: TRegistry;
begin
    // Let the user select a directory. If not canceled then...
    if SelectDirectory('NWN Installation directory', '', tempdir) then
    begin
        // Save the selected directory.
        NWN_dir := AppendPathDelim(tempdir);
        // Erase info cached from the old selection.
        CheckForCompiler();
        TPaletteWindow.ResetPalette();

        // Give the user the option of saving this selection.
        if Application.MessageBox('Would you like to store this new location so ' +
                                  'it will be remembered when you load the Script ' +
                                  'Generator in the future?',
                                  'Store location?', mb_yesno) = IDYES then
        begin
            // Save this directory for future sessions.
            Registry := TRegistry.Create();
            Registry.RootKey := HKEY_LOCAL_MACHINE;
            if Registry.OpenKey(RegKey, True) then
                Registry.WriteString(RegNWNLoc, NWN_dir);
            Registry.CloseKey();
            Registry.Free();
        end;
    end;
end;


// Called when the user wants to forget the stored NWN location (menu option).
procedure Tmain.Deletemanuallystoredlocations1Click(Sender: TObject);
var
    Registry: TRegistry;
begin
    // Remove the directory info from the registry.
    Registry := TRegistry.Create();
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey(RegKey, False) then
        Registry.DeleteValue(RegNWNLoc);
    Registry.CloseKey();
    Registry.Free();

    // A little feedback so it does not seem like nothing happened.
    Application.MessageBox('The program will continue using the current NWN ' +
                           'installation directory until you restart the program. ' +
                           'At the next restart of the program, NWN will be located ' +
                           'automatically, if possible.',
                           'Takes full effect next time', mb_ok);
end;


// -------------------------------------
// Help menu

// Called when the "how to use the scripts" help menu option is used.
procedure Tmain.howtoClick(Sender: TObject);
begin
    ShowPopup(Tusehow);
end;


// Called when the "about the generated code" help menu option is used.
procedure Tmain.Aboutthegeneratedcode1Click(Sender: TObject);
begin
    ShowPopup(Tcodegen);
end;


// Called when the "local variables / do once" help menu option is used.
procedure Tmain.Helpwithlocalvariablesdoonce1Click(Sender: TObject);
begin
    ShowPopup(Tonce_tut);
end;


// Called when the "concepts / ResRef" help menu option is used.
procedure Tmain.Helpwithsomeconcepts1Click(Sender: TObject);
begin
    ShowPopup(Tconcept_help);
end;


// Called when the "about" help menu option is used.
procedure Tmain.Bugssuggestionsfurtherhelp1Click(Sender: TObject);
begin
    ShowPopup(Thelpdoc);
end;


// -------------------------------------
// Popup menu


// Copies the script to the clipboard.
procedure Tmain.Copyscripttoclipboard1Click(Sender: TObject);
begin
    scriptwindow.SelectAll();
    scriptwindow.CopyToClipboard();
end;


// -----------------------------------------------------------------------------
// ****  Other events  ****
// -----------------------------------------------------------------------------


// Begins a new script in the script window.
// Called when the user selects a new script type from the drop-down.
procedure Tmain.scripttypeChange(Sender: TObject);
begin
    // Better make sure a valid selection was made...
    if ScriptType.ItemIndex < 0 then begin
        scripttype.text := typeline;
        exit;
    end;

    // Disable the drop-down (so users do not accidentally delete their script
    // with a misclick).
    scripttype.enabled := false;
    // Enable script actions.
    SetScriptActions(true);

    // Store some information about this selection.
    case scripttype.itemindex of
        SCRIPTTYPE_CONDITIONAL: begin
            OwnerType := OBJECT_TYPE_CREATURE or OBJECT_TYPE_PLACEABLE or
                         OBJECT_TYPE_DOOR;
            OwnerDesc := 'the NPC speaker';
        end;
        // SCRIPTTYPE_NORMAL:       // Deferred to next selection.
        SCRIPTTYPE_BLACKSMITH: begin
            OwnerType := OBJECT_TYPE_PLACEABLE; // or OBJECT_TYPE_CREATURE; but maybe the creature aspect should be suppressed? Not currently used anyway.
            OwnerDesc := 'the forge';
        end;
        SCRIPTTYPE_ACTIVATE: begin
            OwnerType := OBJECT_TYPE_CREATURE;
            OwnerDesc := 'the item activator';
            // In this case, we already know the tag-based type.
            TagBasedType := SCRIPTTYPE_TAG_ACTIVATE;
        end;
        SCRIPTTYPE_TAGBASED: begin
            OwnerType := OBJECT_TYPE_MODULE;
            OwnerDesc := 'the module';
        end;
        SCRIPTTYPE_TEMPLATE: begin
            OwnerType := OBJECT_TYPE_MODULE;
            OwnerDesc := 'the module';
        end;
    end;


    // What happens next?
    case scripttype.itemindex of
        SCRIPTTYPE_CONDITIONAL: begin
            // Start the script.
            Tlilac.InitScript(SCRIPTTYPE_CONDITIONAL);
            Tlilac.AddDirections('Put this under "Text Appears When" in the conversation editor.');
            Tlilac.MarkClean();
            // Allow selection of conditional types.
            conditional.visible := true;
        end;
        SCRIPTTYPE_NORMAL: begin
            // Start the script.
            Tlilac.InitScript(SCRIPTTYPE_NORMAL);
            // Allow selection of how this script will be invoked.
            normalpanel.visible := true;
        end;
        SCRIPTTYPE_BLACKSMITH: StartScriptGeneration(Tchoose_blacksmith, Tblacksmith);
        SCRIPTTYPE_ACTIVATE:   StartScriptGeneration(Tuniquepower, Teventchooser);
        SCRIPTTYPE_TAGBASED:   StartScriptGeneration(Tacquire, Teventchooser);
        SCRIPTTYPE_TEMPLATE:   Tlilac.InitScript(SCRIPTTYPE_TEMPLATE); // And nothing more.
    end;
end;


// Called when the user selects a new conditional type from the drop-down.
procedure Tmain.conditionalChange(Sender: TObject);
begin
    // Determine which form should appear.
    case conditional.itemindex of
        CONDITIONAL_RANDOMNESS: ShowPopup(TRandomint);
        CONDITIONAL_HAS_ITEM:   ShowPopup(Titemint);
        CONDITIONAL_HAS_ITEMS:  ShowPopup(Tnumitems);
        CONDITIONAL_HAS_GOLD:   ShowPopup(Tgoldint);
        CONDITIONAL_STATS:      ShowPopup(Tstatchoose);
        CONDITIONAL_JOURNAL:    ShowPopup(Tjournalsint);
        CONDITIONAL_LOCALS:     ShowPopup(Tlocal);
        CONDITIONAL_TIME:       ShowPopup(TCondTime);
        CONDITIONAL_DO_ONCE:    ShowPopup(Tonce_tut);
    end;

    // Reset the drop-down.
    conditional.ClearSelection();
    conditional.text := condline;
end;


// Called when the user selects a new "called from" source from the drop-down.
// It supplies the definition of oPC for "normal" scripts and starts up further options.
procedure Tmain.calledfromChange(Sender: TObject);
const
    // Here are some arrays defining parameters for each of the options that
    // might have been selected. There is one array per parameter, and the
    // index of the array corresponds to the index of the selected option.

    // The types of objects that might run each script.
    ObjectTypes: array[0..CALLED_FROM_LAST] of word =
              ( OBJECT_TYPE_CREATURE  or OBJECT_TYPE_DOOR           or
                                         OBJECT_TYPE_PLACEABLE,         // Conversations
                OBJECT_TYPE_TRIGGER   or OBJECT_TYPE_DOOR           or
                                         OBJECT_TYPE_AREA_OF_EFFECT or
                                         OBJECT_TYPE_ENCOUNTER      or
                                         OBJECT_TYPE_AREA           or
                                         OBJECT_TYPE_MODULE,            // OnEnter
                OBJECT_TYPE_TRIGGER   or OBJECT_TYPE_AREA_OF_EFFECT or
                                         OBJECT_TYPE_ENCOUNTER      or
                                         OBJECT_TYPE_AREA           or
                                         OBJECT_TYPE_MODULE,            // OnExit
                OBJECT_TYPE_PLACEABLE,                                  // OnUsed
                OBJECT_TYPE_CREATURE  or OBJECT_TYPE_DOOR           or
                                         OBJECT_TYPE_PLACEABLE,         // OnDeath
                OBJECT_TYPE_DOOR      or OBJECT_TYPE_PLACEABLE,         // OnOpen
                OBJECT_TYPE_DOOR      or OBJECT_TYPE_PLACEABLE,         // OnClose
                OBJECT_TYPE_DOOR,                                       // OnFailedToOpen (click door)
                OBJECT_TYPE_PLACEABLE,                                  // OnClick, placeable version
                OBJECT_TYPE_TRIGGER   or OBJECT_TYPE_DOOR,              // OnClick, trigger version
                OBJECT_TYPE_CREATURE  or OBJECT_TYPE_DOOR           or
                                         OBJECT_TYPE_PLACEABLE,         // On Hostilities
                OBJECT_TYPE_CREATURE,                                   // OnPerceived
                OBJECT_TYPE_CREATURE,                                   // OnHeartbeat
                OBJECT_TYPE_MODULE,                                     // OnPCDeath
                OBJECT_TYPE_MODULE );                                   // OnPCRespawn

    // A description of the object running each script (displayed in the Generator).
    ObjectDescs: array [0..CALLED_FROM_LAST] of shortstring =
              ( 'the NPC speaker',          // Conversations
                'the thing entered',        // OnEnter
                'the thing exited',         // OnExit
                'the thing used',           // OnUsed
                'the thing killed',         // OnDeath
                'the thing opened',         // OnOpen
                'the thing closed',         // OnClosed
                'the door that did not open',   // OnFailedToOpen (click a door)
                'the placeable clicked',    // OnClick (placeable)
                'the thing clicked',        // OnClick (trigger)
                'the thing that was attacked',  // OnHostilities
                'the NPC who saw',          // OnPerceived
                'the NPC',                  // OnHeartbeat
                'the module',               // OnPCDeath
                'the module' );             // OnPCRespawn

    // Instructions for where this script is to be put.
    PutThis: array[0..CALLED_FROM_LAST] of pChar =
                ('Put this under "Actions Taken" in the conversation editor.',  // USED_INCONVERSATION
                 'Put this script OnEnter.',                        // USED_ONENTER
                 'Put this script OnExit.',                         // USED_ONEXIT
                 'Put this script OnUsed.',                         // USED_ONUSED
                 'Put this script OnDeath.',                        // USED_ONDEATH
                 'Put this script OnOpen.',                         // USED_ONOPEN
                 'Put this script OnClose.',                        // USED_ONCLOSED
                 'Put this script OnFailToOpen.',                   // USED_ONCLICK_DOOR
                 'Put this script OnClick of a placeable.',         // USED_ONCLICK_PLACEABLE
                 'Put this script OnClick (trigger) or OnAreaTransitionClick (door).',  // USED_ONCLICK_TRIGGER
                 'Can go OnDamaged, OnDisturbed, OnSpellCastAt, etc.',  // USED_ONHOSTILITIES
                 'Put this script OnPerceived (of a creature).',    // USED_ONPERCEIVED
                 'Put this OnHeartbeat.',                           // USED_ONHEARTBEAT
                 'Put this OnPlayerDeath (module properties).',     // USED_ONPCDEATH
                 'Put this OnPlayerRespawn (module properties).');  // USED_ONPCRESPAWN

    // The function used to define oPC.
    PCdef: array[0..CALLED_FROM_LAST] of pChar =
                ('GetPCSpeaker()',                  // USED_INCONVERSATION
                 'GetEnteringObject()',             // USED_ONENTER
                 'GetExitingObject()',              // USED_ONEXIT
                 'GetLastUsedBy()',                 // USED_ONUSED
                 'GetLastKiller()',                 // USED_ONDEATH
                 'GetLastOpenedBy()',               // USED_ONOPEN
                 'GetLastClosedBy()',               // USED_ONCLOSED
                 'GetClickingObject()',             // USED_ONCLICK_DOOR
                 'GetPlaceableLastClickedBy()',     // USED_ONCLICK_PLACEABLE
                 'GetClickingObject()',             // USED_ONCLICK_TRIGGER
                 'GetLastHostileActor()',           // USED_ONHOSTILITIES
                 'GetLastPerceived()',              // USED_ONPERCEIVED
                 'GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF, 1,'#10'                                    CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)', // USED_ONHEARTBEAT
                 'GetLastPlayerDied()',             // USED_ONPCDEATH
                 'GetLastRespawnButtonPresser()');  // USED_ONPCRESPAWN


    // The rest of this const section defines most of the remaining text that
    // might get written.
    preempt_HB: array[1..7] of shortstring =
                ('// If running the lowest AI, abort for performance reasons.',
                 'if ( GetAILevel() == AI_LEVEL_VERY_LOW )',
                 '    return;',
                 '',
                 '// If busy with combat or conversation, skip this heartbeat.',
                 'if ( IsInConversation(OBJECT_SELF)  ||  GetIsInCombat() )',
                 '    return;');

    preempt_perc: array[1..3] of shortstring =
                ('// We are only interested in "seen" events.',
                 'if ( !GetLastPerceptionSeen() )',
                 '    return;');

    preempt_PC: array[1..3] of shortstring =
                ('// Only fire for (real) PCs.',
                 'if ( !GetIsPC('+s_oPC+')  ||  GetIsDMPossessed('+s_oPC+') )',
                 '    return;');

    code_respawn: array[1..4] of shortstring =
                ('// Revitalize (raise and heal) the PC.',
                 'RemoveEffects('+s_oPC+');',
                 'ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), '+s_oPC+');',
                 'ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints('+s_oPC+')), '+s_oPC+');');
var
    caution, explain: shortstring;
    index: integer;
    code_PC: array[1..2] of shortstring;
// ----------------
begin
    // For simpler reading.
    index := calledfrom.itemindex;
    // Abort on bad data.
    if (index < 0) or (CALLED_FROM_LAST < index) then begin
        calledfrom.text := fromline;
        exit;
    end;

    // Store some information about this selection.
    OwnerType := TTypeChooser.UserChoice(ObjectTypes[index]);
    OwnerDesc := ObjectDescs[index];

    // Initialize.
    caution := '';
    explain := 'creature who triggered this event';

    // Adjust the defaults in a few cases.
    case index of
        USED_INCONVERSATION:    explain := 'PC who is in this conversation';
        USED_ONPCDEATH:         explain := 'PC who died';
        USED_ONPCRESPAWN:       explain := 'PC who chose to respawn';

        USED_ONHOSTILITIES:     caution := 'This is a generic script, calling GetLastHostileActor() instead of the event-sepcific command.';

        USED_ONHEARTBEAT: begin explain := 'PC who will be referenced in this event';
                                caution := 'Will abort (do nothing) if fighting or talking or if no PCs are in the area.';
                          end;
    end;
    // Disable the controls that initiated this.
    calledfrom.enabled := false;

    // Insert the directions for where to put this.
    Tlilac.AddDirections(PutThis[index], caution);

    // Pre-emptive aborts for some events.
    if index = USED_ONHEARTBEAT then
        Tlilac.AddLines(preempt_HB)
    else if index = USED_ONPERCEIVED then
        // For now, preserve LS' abort for all perception but the "seen" event.
        Tlilac.AddLines(preempt_perc);

    // Insert the definition of oPC.
    code_PC[1] := '// Get the ' + explain + '.';
    code_PC[2] := 'object oPC = ' + PCdef[index] + ';';
    Tlilac.AddLines(code_PC);

    // If oPC should be checked for being player-controlled.
    if GetUsePCCheck(index) then
        Tlilac.AddLines(preempt_PC);


    // On to the meat of the script:

    // Some special cases that have a pop-up (or special code) before the
    // restraint and event windows:
    case index of
        USED_ONDEATH:     ShowPopup(Tfollowers);
        USED_ONHEARTBEAT: ShowPopup(Theartbeatnotice);

        USED_ONPCRESPAWN: begin
            // The code for the actual respawn:
            Tlilac.Include(INC_PLOT);
            Tlilac.AddLines(code_respawn);
        end;
    end;

    // This is the point at which the standard stuff ends and the user starts
    // to customize the script for a particular purpose.
    Tlilac.MarkClean();

    // The restraint window for most cases:
    if index <> USED_INCONVERSATION then
        if ShowPopup(Trestraint) = mrYes then
            ShowPopup(Totherrestrictions);


    // Finally, the event window (for all cases):
    ShowPopup(Teventchooser);

    // Show the "Add to script" button.
    bitbtn5.visible := true;
end;


// Called when the user presses a key while the script area has the focus.
procedure Tmain.scriptwindowKeyDown(Sender: TObject; var Key: Word;
                                    Shift: TShiftState);
begin
    // We want to detect CTRL-A.
    if ( (key = Ord('a')) or (key = Ord('A')) ) and ( ssCtrl in Shift ) then
        // CTRL-A means select all.
        scriptwindow.SelectAll();
end;


// Called when the user clicks the "Need help?" button displayed under the
// "called from" drop-down for "normal" scripts.
procedure Tmain.testClick(Sender: TObject);
begin
    ShowPopup(Tnormscripthelp);
end;


// Called when the user clicks the "Copy / other script actions" button.
procedure Tmain.BitBtn3Click(Sender: TObject);
var
    P : TPoint;
begin
    // Make sure the script is syntactically complete.
    if Tlilac.IsComplete() then begin
        // Figure out where to pop up the menu. Try to get it just above BitBtn3?
        P := Point(BitBtn3.Left, BitBtn3.Top - 120);
        P := ClientToScreen(P);

        // Pop up the menu.
        popupmenu1.Popup(P.x, P.y);
    end;
end;


// Called when the user clicks the "Add to script" button.
procedure Tmain.Button5Click(Sender: TObject);
begin
    // A different form is used for blacksmith scripts.
    if scripttype.itemindex = SCRIPTTYPE_BLACKSMITH then
        ShowPopup(Tblacksmith)
    else
        ShowPopup(Teventchooser);
end;


// -----------------------------------------------------------------------------
// ****  Support functions  ****
// -----------------------------------------------------------------------------


// Prompts the user to enter a script name and returns the result.
// May return '' if the user cancels the action.
function Tmain.GetScriptName(): TString16;
var
    the_form: TErfNameForm;
begin
    // Popup the form that will be used.
    Application.CreateForm(TErfNameForm, the_form);
    if the_form.ShowModal() = mrCancel then
        result := ''
    else
        result := the_form.Edit1.Text;

    // Clean up.
    the_form.Release();
end;


// Returns whether or not the current script is item activation (allowing
// several forms to decide whether or not to use "activation target" as
// an option).
function Tmain.GetIsActivation(): boolean; inline;
begin
    result :=  ScriptType.ItemIndex = SCRIPTTYPE_ACTIVATE;
end;


// Returns whether or not the current script is used in a conversation.
function Tmain.GetIsConversation(): boolean; inline;
begin
    result := (ScriptType.ItemIndex = SCRIPTTYPE_CONDITIONAL) or
              (CalledFrom.ItemIndex = USED_INCONVERSATION);
end;


// Returns whether or not the current script is associated with an item
// (i.e. is a tag-based script, so oEventItem is defined).
function Tmain.GetIsItemScript(): boolean; inline;
begin
    result :=  (ScriptType.ItemIndex = SCRIPTTYPE_ACTIVATE)  or
               (ScriptType.ItemIndex = SCRIPTTYPE_TAGBASED);
end;


// Given a USED_* constant, returns whether or not that script type gets an
// "is PC" check, based on current settings.
function  Tmain.GetUsePCCheck(option: integer): boolean;
const
    // How much each script type needs to check oPC for being player-controlled.
    //    CHECK_PCS_CRIT   = critcal script to check
    //    CHECK_PCS_ALWAYS = only check if checking always
    //    CHECK_PCS_NONEED = no need to check ever; guaranteed to be a PC
    PCchecked: array[0..CALLED_FROM_LAST] of byte =
                (CHECK_PCS_NONEED,     // USED_INCONVERSATION
                 CHECK_PCS_CRIT,       // USED_ONENTER
                 CHECK_PCS_CRIT,       // USED_ONEXIT
                 CHECK_PCS_ALWAYS,     // USED_ONUSED
                 CHECK_PCS_ALWAYS,     // USED_ONDEATH
                 CHECK_PCS_ALWAYS,     // USED_ONOPEN
                 CHECK_PCS_ALWAYS,     // USED_ONCLOSED
                 CHECK_PCS_ALWAYS,     // USED_ONCLICK_DOOR
                 CHECK_PCS_NONEED,     // USED_ONCLICK_PLACEABLE
                 CHECK_PCS_ALWAYS,     // USED_ONCLICK_TRIGGER
                 CHECK_PCS_ALWAYS,     // USED_ONHOSTILITIES
                 CHECK_PCS_CRIT,       // USED_ONPERCEIVED
                 CHECK_PCS_NONEED,     // USED_ONHEARTBEAT
                 CHECK_PCS_NONEED,     // USED_ONPCDEATH
                 CHECK_PCS_NONEED);    // USED_ONPCRESPAWN
var
    setting: byte;
begin
    // Get the program setting.
         if MItemFirePCOnlyNever.Checked        then  setting := CHECK_PCS_NEVER
    else if MItemFirePCOnlyWhenCritical.Checked then  setting := CHECK_PCS_CRIT
    else if MItemFirePCOnlyAlways.Checked       then  setting := CHECK_PCS_ALWAYS;

    // The logic is that the program's current setting is the maximum
    // script-type setting that gets a check.
    result := PCchecked[option] <= setting;
end;


// Initializes the captions of the provided radio buttons, and sets their
// visibility based on the caller wanting _goal_object_ object types available.
// Parameters may be nil.
procedure TMain.InitRadioWhos(RadioOwner, RadioSpawn, RadioActor: TCustomCheckBox;
                              goal_object: word);
begin
    if RadioOwner <> nil then begin
        RadioOwner.Caption := TrimRight(RadioOwner.Caption)+' ('+self.ScriptOwner+')';
        RadioOwner.Visible := goal_object and self.ObjectType <> 0;
    end;

    if RadioSpawn <> nil then begin
        RadioSpawn.Caption := TrimRight(RadioSpawn.Caption)+' ('+Tlilac.last_spawn+')';
        RadioSpawn.Visible := goal_object and Tlilac.last_spawn_type <> 0;
    end;

    // Slight difference in the actor check as oActor is assumed always a creature.
    if RadioActor <> nil then begin
        RadioActor.Caption := TrimRight(RadioActor.Caption)+' ('+Tlilac.last_actor+')';
        RadioActor.Visible := (goal_object and OBJECT_TYPE_CREATURE <> 0) and
                              (Tlilac.last_actor <> '');
    end;
end;


// If this is item activation, the first two parameters will be hidden, while
// the second two will be shown, subject to the fourth parameter remaining hidden
// if the expected object type of the target does not match goal_object.
// In addition (if activation), the checked state of the first parameter will
// be transferred to the third, and the second to the fourth (only if the fourth
// is made visible), but neither of these will trigger an OnChanged event (probably).
// (So basically, the first two parameters can be swapped to invert the default
// selection.)
// Parameters may be nil.
// The optional parameter is for a replacement for RadioTargeted in the above if
// this is item activation and the recorded object type of the target is "none".
procedure TMain.InitActivationRadios(RadioOwner, RadioPC, RadioActivator, RadioTargeted: TCustomCheckBox;
                                     goal_object: word; RadioLocation: TCustomCheckBox = nil);
begin
    // Only make changes if this is activation.
    if not GetIsActivation() then
        exit;

    // Show the activator and targeted buttons.
    if RadioActivator <> nil then
        RadioActivator.Visible := true;
    if RadioTargeted <> nil then
        RadioTargeted.Visible  := goal_object and self.ActTargetType <> 0;
    // The location radio becomes visible if the target radio would stay invisible
    // regardless if the goal object.
    if RadioLocation <> nil then
        RadioLocation.Visible  := self.ActTargetType = OBJECT_TYPE_NONE;

    // Hide the owner button, transferring the checked state.
    if RadioOwner <> nil then begin
        RadioOwner.Visible := false;
        if RadioActivator <> nil then
            RadioActivator.State := RadioOwner.State;
    end;
    // Hide the PC button, transferring the checked state.
    if RadioPC <> nil then begin
        RadioPC.Visible := false;
        // Note that only one of RadioTargeted and RadioLocation will be visible.
        if RadioLocation <> nil then
            if RadioLocation.Visible then
                RadioLocation.State := RadioPC.State;
        if RadioTargeted <> nil then
            if RadioTargeted.Visible then
                RadioTargeted.State := RadioPC.State;
    end;
end;


// Creates the specified form, displays it as a modal window, destroys the
// form, and returns whatever selection was made.
function Tmain.ShowPopup(InstanceClass: TComponentClass) : integer;
var
    the_form: TCustomForm;
begin
    // Create the form. It must have been defined as not initially visible.
    Application.CreateForm(InstanceClass, the_form);
    // Display the form.
    result := the_form.ShowModal();
    // Clean up.
    the_form.Release();
end;


// Enables/disables the various menu options that only make sense when the
// Script Window is not clear.
// Using actions was supposed to help with this, but I could not get an entire
// ActionList to disable itself.
procedure Tmain.SetScriptActions(bEnable: boolean);
begin
    ActionSave.Enabled := bEnable;
    ActionExport.Enabled := bEnable;
    ActionMerge.Enabled := bEnable;
    ActionClear.Enabled := bEnable;

    // The "Copy / other script actions" button.
    BitBtn3.Enabled := bEnable;

    // Special case: ActionCompile also needs a compiler available.
    ActionCompile.Enabled := bEnable  and  (compiler_loc <> COMPILE_LOC_NONE);
end;


// The workhorse for going to the next step for blacksmiths and tag-based scripting.
procedure Tmain.StartScriptGeneration(FirstForm, SecondForm: TComponentClass);
begin
    // Give the user a chance to continue an existing script.
    if ShowPopup(FirstForm) <> mrOk then
        StartOver()
    else begin
        Tlilac.MarkClean();
        ShowPopup(SecondForm);
        // Show the "Add to script" button.
        bitbtn5.visible := true;
    end;
end;


// Cleans up everything and starts a new script.
//
// This was in Tconfirmclear.Button1Click(), but I think it makes
// more sense (and makes the program more modular) to have it here. --TK
procedure Tmain.StartOver();
var
    Registry: TRegistry;
    bRegSetting: boolean;
begin
    // Reset the major parts of the Script Generator.
    Tlilac.ClearScript();
    Teventchooser.ResetEvents();
    Tblacksmith.ResetSmith();
    SetScriptActions(false);

    // Re-enable widgets that get disabled along the way.
    scripttype.enabled := true;
    calledfrom.enabled := true;

    // Hide widgets that start hidden.
    conditional.visible := false;
    normalpanel.visible := false;
    bitbtn5.visible := false;

    // Reset some drop-downs.
    calledfrom.ClearSelection();
    conditional.ClearSelection();
    scripttype.ClearSelection();
    calledfrom.text  := fromline;
    conditional.text := condline;
    scripttype.text  := typeline;

    // Reset the "never fire only for PCs" setting?
    if MItemFirePCOnlyNever.checked then begin
        // Default value in case we do not find something in the registry.
        bRegSetting := FALSE;

        // Look up the option saved in the registry.
        Registry := TRegistry.Create();
        try
            Registry.RootKey := HKEY_LOCAL_MACHINE;
            if Registry.OpenKey(RegKey, FALSE) then begin
                if Registry.ValueExists(RegPCChecks) then
                    bRegSetting := Registry.ReadBool(RegPCChecks);
                Registry.CloseKey();
            end;
        except  // Possibly raised if RegPCChecks refers to a non-boolean value.
        end;
        Registry.Free();

        // Restore the previous selection.
        if bRegSetting then
            MItemFirePCOnlyAlways.Checked := TRUE
        else
            MItemFirePCOnlyWhenCritical.Checked := TRUE;
    end;
end;


// -----------------------------------------------------------------------------
// ****  File-related support functions  ****
// -----------------------------------------------------------------------------


// Enables or disables some options based on whether or not a command line
// compiler is available.
procedure Tmain.CheckForCompiler();
begin
    // See where, if anywhere, the compiler is located.
    if fileexists(AppendPathDelim(nwnloc+'utils') + 'clcompile.exe') then
        compiler_loc := COMPILE_LOC_NWN
    else if fileexists('clcompile.exe') then
        compiler_loc := COMPILE_LOC_CUR
    else
        compiler_loc := COMPILE_LOC_NONE;

    // Did we find the comppiler?
    if compiler_loc <> COMPILE_LOC_NONE then begin
        // Enable compilation.
        ActionCompile.Enabled := scriptwindow.Lines.Count > 0;
        ActionExport.Caption := 'Compile and save / append to .&erf file';
        ActionMerge.Caption := 'Compile and save to &module (.mod file)';
    end
    else begin
        // Disable compilation.
        ActionCompile.Enabled := FALSE;
        ActionExport.Caption := 'Save / append to .&erf file';
        ActionMerge.Caption := 'Save to &module (.mod file)';
    end;
end;


// Conpiles the file sScriptName using BioWare's command line compiler.
// Returns TRUE if the compilation was successful.
function Tmain.DoCompile(const sScriptName: ansistring) : boolean;
var
    sCompileDir: ansistring;
begin
    result := FALSE;

    // Locate the compiler.
    case compiler_loc of
        COMPILE_LOC_NWN: sCompileDir := nwnloc+'utils';
        COMPILE_LOC_CUR: sCompileDir := scriptgendir;
        else
            // No compiler located. We should only get to here if saving just the
            // .nss to a .mod or .erf, so just quietly abort and proceed with the
            // saving.
            exit;
    end;

    try
        // Execute the compiler from the target directory.
        chdir(ExtractFilePath(sScriptName));
        ExecNewProcess(AppendPathDelim(sCompileDir)+'clcompile.exe "'+sScriptName+'"');
        result := TRUE;
        RestoreWorkingDirectory();
    except
        Application.MessageBox('Unexpected error encountered. ' +
                               'The script may have been not compiled. ',
                               'Error', mb_OK);
    end
end;


// Launches a new process to execute the given command line, and waits for
// that process to finish.
// (Basically a wrapper for TProcess now.)
procedure Tmain.ExecNewProcess(const sCommandLine : string);
var
    AProcess: TProcess;
begin
    // Create a TProcess object that will execute the program.
    AProcess := TProcess.Create(nil);
    AProcess.CommandLine := sCommandLine;

    // Set various options.
    AProcess.Options := AProcess.Options + [poWaitOnExit, poNewProcessGroup];
    AProcess.ShowWindow := swoHIDE;

    // Run the program.
    AProcess.Execute();

    // We are done with the process.
    AProcess.Free();
end;


// Restores the Script Generator's directory as the working directory.
procedure Tmain.RestoreWorkingDirectory(); inline;
begin
    chdir(scriptgendir);
end;


// Saves the script to the indictated ERF, using the given name for the script.
// This will overwrite the ERF if bAppend is FALSE; otherwise the script will
// be added to the ERF.
procedure Tmain.SaveToERF(const ScriptName: TString16; const ERFName: ansistring; bAppend: boolean);
var
    bCompiled, bSaved: boolean;
    NSSName, NCSName, NDBName: ansistring;
    NSS, NCS: TFileStream;
begin
    // Check for the user aborting this operation.
    if ScriptName = '' then
        exit;

    // The (temporary) script file names.
    NDBName := AppendPathDelim(ExtractFilePath(ERFName)) + ScriptName; // '.ndb' to be appended later.
    NSSName := NDBName + '.nss';
    NCSName := NDBName + '.ncs';
    NDBName := NDBName + '.ndb';
    // Remove any existing .nss or .ncs.
    if FileExists(NSSName) then
        DeleteFile(NSSName);
    if fileexists(NCSName) then
        DeleteFile(NCSName);

    // Save the script so the compiler can see it.
    SaveToNSS(NSSName);
    if not fileexists(NSSNAME) then begin
        Application.MessageBox('A temporary file is missing. Are you out of disk space?',
                               'Critical error - aborting', mb_OK);
        exit;
    end;

    // Compile our little friend...
    bCompiled := DoCompile(NSSName);
    if bCompiled and not fileexists(NCSName) then begin
        Application.MessageBox('The compiled script is missing. This may indicate that '+
                               'the generated script is flawed. Aborting procedure.',
                               'Critical error - aborting', mb_OK);
        exit;
    end;

    // Create streams for the script.
    NSS := TFileStream.Create(NSSName, fmOpenRead or fmShareDenyWrite);
    if bCompiled then
        NCS := TFileStream.Create(NCSName, fmOpenRead or fmShareDenyWrite)
    else
        NCS := nil;

    // Write the BioWare file format.
    if bAppend then
        bSaved := AppendToERF(ScriptName, ERFName, NSS, NCS, BackupSetting.Checked)
    else
        bSaved := OverwriteERF(ScriptName, ERFName, NSS, NCS);
    if bSaved then
        // Mark the script as clean.
        Tlilac.MarkClean();

    // Cleanup.
    NSS.Destroy();
    DeleteFile(NSSName);
    if NCS <> nil then begin
        NCS.Destroy();
        DeleteFile(NCSName);
        DeleteFile(NDBName);
    end;
end;


// Saves the script to its own file.
procedure Tmain.SaveToNSS(const sFileName: ansistring);
var
    FilledTemplate: TStrings;
begin
    // The complication here is that tag-based scripts are supposed to be inserted
    // into the template.
    case scripttype.ItemIndex of
        SCRIPTTYPE_ACTIVATE, SCRIPTTYPE_TAGBASED:
        begin
            // Ask Tlilac to fill in the template for us.
            FilledTemplate := Tlilac.MergeTemplate(TagBasedType);
            FilledTemplate.SaveToFile(sFileName);
            FilledTemplate.Destroy();
        end;
        else
            // Standard: just save whatever is in the script window.
            scriptwindow.lines.savetofile(sFileName);
    end;
end;


initialization
  {$i start.lrs}
end.
