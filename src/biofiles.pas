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
The Krit created this unit to collect the file-handling routines and type
definitions, with the hope of cutting down some repetition (and to make the units
that use this more focused).
}


{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit BioFiles;


interface

uses
  Classes, SysUtils, Contnrs, StdCtrls, ComCtrls, LCLType;


const
    // SEARCH_* constants for which field(s) to search.
    // (These end with singular nouns; plural nouns are another set of constants.)
    SEARCH_NAME    = 0;
    SEARCH_TAG     = 1;
    SEARCH_DESC    = 2;
    SEARCH_COMMENT = 3;
    SEARCH_ALL     = 4;


type
    // Miscellaneous useful types for BioWare formats.
    TString16    = string[16]; // For ResRefs
    TString16Ary = array of TString16;


type
    // The information needed to locate a GFF embedded in an ERF/BIF.
    // The info will come from this unit and will be used by this unit. Other
    // units only need this type block so they can declare variables of type
    // "TGFFLocator" (or "TGFFLocators").
    TGFFLocator = record
        FileName: ansistring;
        Offset:   DWORD;
        Length:   DWORD;
    end;
    TGFFLocators = array of TGFFLocator;


type
    // A class to store resource information.
    // The info will come from this unit and will be used by this unit. Other
    // units only need this type block so they can declare variables of type
    // "TResourceList".

    // The types of files we can handle (deduced from which Add() method is used).
    TEResourceFile = ( BifFileType, ErfFileType );
    // For storing info about a resource in a BIF/ERF so we can later retrieve it.
    TResourceKey = record
        ResRef: TString16;
        index:  DWORD;
    end;
    TResourceKeys = array of TResourceKey;

    // For holding a list of resources, and later retrieval via searches.
    // (A "black box" class)
    TResourceList = class
    private
        // Fields
        HashPtr:   TFPHashList;
        Resources: array of TResourceKeys;
        FileNames: array of ansistring;
        FileTypes: array of TEResourceFile;

    public
        // Methods
        constructor Create();
        destructor  Destroy(); override;

        // Overloaded Add() method:
        // The one taking a single file name takes the ResID from a MOD/ERF file.
        // The one taking an array of names takes the ResID from a KEY file.
        procedure Add(const ResRef: array of char; ResID: DWORD; const file_name: ansistring); overload; inline;
        procedure Add(const ResRef: array of char; ResID: DWORD; const bif_names: array of ansistring); overload;
        procedure DoneAdding(); // Called to let the list know no more adds will take place.
        function  EnsureFile(const file_name: ansistring; file_type: TEResourceFile): integer;  // Ensure mod_name is in the list of files covered.
        procedure Search(const MatchLine:shortstring; SearchCode: integer;
                         var OutList: TListBox; var OutListData: TGFFLocators;
                         var ProgressBar: TProgressBar; const ModTalkName: ansistring;
                         first_file_only: boolean);
    private
        // Overloaded Add() method: The others are wrappers for this one.
        procedure Add(const ResRef: array of char; index: DWORD;  const file_name: ansistring;
                      file_type: TEResourceFile); overload;
        procedure DoSort(FileNum:integer);
        procedure FixMinHeap(FileNum:integer; var Indices: array of integer;
                             KeyIndex:integer; Root:integer; HeapEnd:integer);
        function  GetResourceCount(): integer;
        function  IsMatch(GFF: TStream; const MatchLine: shortstring; SearchCode: integer;
                          TLK, CustTLK: TStream; LanguageID: DWORD): boolean;
        function  LabelMatchesCriteria(const ThisLabel: array of char; SearchCode: integer): boolean;
        procedure ReadFileHeader(NWN: TStream; FileType: TEResourceFile;
                                 out ResourceCount:  DWORD;
                                 out ResTableOffset: DWORD;
                                 out ResTableWidth:  DWORD);
        procedure RecordSearch(var OutList:TListBox; var OutListData:TGFFLocators;
                               const FoundResRef: array of TString16Ary;
                               const FoundData: array of TGFFLocators);
    end;



// Public interface to this unit:

function  GetGFF(const GFFLocator: TGFFLocator; out sError: shortstring) : TMemoryStream;
procedure LoadBifKey(const keyname:ansistring; var CreatureList, ItemList, PlaceableList: TResourceList);
function  LoadMod(const mod_name:ansistring; var ModCreatureList, ModItemList, ModPlaceableList: TResourceList;
                  var ModTalkName: ansistring) : boolean;
function  ReadBlueprintProperties(GFF: TStream; out Name, Tag, Desc, DescID, Comment: ansistring;
                                  const ModTalkName: ansistring) : shortstring;

function  AppendToERF(const ScriptName: TString16; const ERFName: ansistring; NSS, NCS: TStream; bBackup: boolean) : boolean;
function  OverwriteERF(const ScriptName: TString16; const ERFName: ansistring; NSS, NCS: TStream) : boolean;


// -----------------------------------------------------------------------------
implementation

uses
    FileUtil, Forms, start; // start is needed (just) to get the NWN location.


type // KEY format:
    TKeyHeader = packed record
        filetype, fileversion: array[0..3] of char;
        bifcount, keycount, offsettofiletable,
        offsettokeytable, buildyear, buildday: DWORD;
        UnUsed: array[0..31] of byte;
    end;

    TFileEntry = packed record
        filesize, filenameoffset: DWORD;
        FileNameSize, Drives: WORD;
    end;

    TKeyEntry = packed record
        ResRef: array [0..15] of char;
        ResourceType: WORD;
        ResID: DWORD;
    end;


type // ERF format:
    TERFHeader = packed record
        FileType, Version: array [0..3] of char;
        LanguageCount, LocalizedStringSize,
        EntryCount, OffsetToLocalizedString,
        OffsetToKeyList, OffsetToResourceList,
        BuildYear, BuildDay, DescStrRef: DWORD;
        UnusedByProgram: array [0..115] of char;
    end;

    TErfString = packed record
        Language: DWORD;
        Size:     DWORD;
        AString:  array of char;
    end;
    TErfStringList = array of TErfString;

    TErfKey = packed record
        ResRef:  array[0..15] of char;
        ResID:   DWORD;
        ResType: WORD;
        Unused:  WORD;
    end;
    TErfKeyList = array of TErfKey;

    TErfResource = packed record
        Offset: DWORD;
        Size:   DWORD;
    end;
    TErfResourceList = array of TErfResource;

    // The resource data will be implemented as a TMemoryStream.


// -----------------------------------------------------------------------------
// Some utilities for processing BioWare's file formats


// Converts a StringRef into a string.
// The streams can be nil (in which case '' is returned).
function DoTalkLookup(StrRef: DWORD; TLK, CustTLK: TStream): ansistring;
var
    PTLK: ^TStream;

    DataSize:      DWORD;
    MaxString:     DWORD;
    EntriesOffset: DWORD;
    StringFlags:   DWORD;
    StringOffset:  DWORD;
    StringLength:  DWORD;

    tempchar: char;
    counter:  integer;
begin
    // In case nothing is found:
    result := '';

    // Abort if the StrRef is "none".
    if StrRef = $FFFFFFFF then
        exit;

    // Which file should we be looking at?
    if StrRef < $01000000 then
        PTLK := @TLK
    else begin
        PTLK := @CustTLK;
        // Mask the StrRef in this case
        StrRef := StrRef and $00FFFFFF;
    end;
    // Officially, BioWare says custom StrRefs not in the cutom talk table should
    // be resolved in the standard talk table, but that would not be useful here.

    // Abort if there is no file to use.
    if PTLK^ = nil then
        exit;

    // Read the relevant header data.
    PTLK^.Seek(5, soFromBeginning);
    PTLK^.Read(tempchar, sizeof(tempchar));
    if (tempchar = '2') or (tempchar = '1') or (tempchar = '0') then
        // Pre-version 3.0 did not have a SoundLength field.
        DataSize := 36
    else
        DataSize := 40;
    PTLK^.Seek(12, soFromBeginning);
    PTLK^.Read(MaxString, sizeof(MaxString));
    PTLK^.Read(EntriesOffset, sizeof(EntriesOffset));

    // Validate the StringRef.
    if StrRef < MaxString then begin
        // Read the data record for the desired string.
        PTLK^.Seek(StrRef * DataSize, soFromCurrent);
        PTLK^.Read(StringFlags, SizeOf(StringFlags));
        PTLK^.Seek(24, soFromCurrent);  // Skipping sound ResRef, volume variance, and pitch variance
        PTLK^.Read(StringOffset, SizeOf(StringOffset));
        PTLK^.Read(StringLength, SizeOf(StringLength));

        // Validate the text flag and string location.
        if ((StringFlags and $01) = $01) and
           (EntriesOffset + StringOffset + StringLength <= PTLK^.Size)  then
        begin
            // Read the string.
            PTLK^.Seek(EntriesOffset + StringOffset, soFromBeginning);
            for counter := 1 to StringLength do
            begin
                PTLK^.Read(TempChar, SizeOf(TempChar));
                // Having trouble with extended characters, so I'll just convert
                // them all to question marks. (Faster than writing a decoder.) --TK
                if TempChar > #126 then
                    TempChar := '?';
                {$ifdef WIN32}
                // Convert newlines
                if TempChar = #10 then
                    result := result + #13;
                {$endif}
                result := result + TempChar;
            end;
        end;
    end;
end;


// Reads a localized string from the current location in GFF.
// TLK and Language ID are used in the case where the string is a StringRef.
function ReadGFFLocString(GFF: TStream; TLK, CustTLK: TStream; LanguageID: DWORD): ansistring;
var
    buffer: ansistring;
    tempchar: char;
    i: integer;

    StringSize, StringRef,
    StringCount, StringID: DWORD;
begin
    SetLength(buffer, 0);

    // Read the localized string's header.
    GFF.Seek(4, soFromCurrent); // Skipping the number of bytes in this structure.
    GFF.Read(StringRef, SizeOf(StringRef));
    GFF.Read(StringCount, SizeOf(StringCount));

    // Look for a localized string for our language.
    while (StringCount > 0) and (Length(buffer) = 0) do begin
        // Read the localized header.
        GFF.Read(StringID, SizeOf(StringID));
        GFF.Read(StringSize, SizeOf(StringSize));

        // Test the language.
        if (StringID / 2 = LanguageID) and (StringSize > 0) then
            // This is what we want.
            for i:= 1 to StringSize do begin
                GFF.Read(tempchar, sizeof(tempchar));
                // Having trouble with extended characters, so I'll just convert
                // them all to question marks. (Faster than writing a decoder.) --TK
                if tempchar > #126 then
                    tempchar := '?';
                {$ifdef WIN32}
                // Convert newlines
                if tempchar = #10 then
                    result := result + #13;
                {$endif}
                buffer := buffer + tempchar;
            end
        else
            // Go on to the next localized string.
            GFF.Seek(StringSize, soFromCurrent);

        // Update the loop counter.
        StringCount -= 1;
    end;

    // Should we consult the .tlk?
    if (Length(buffer) = 0) and (StringRef <> $FFFFFFFF) then
        result := DoTalkLookup(StringRef, TLK, CustTLK)
    else
        result := buffer;
end;


// Reads a localized string from the current location in GFF.
function ReadGFFString(GFF: TStream): ansistring;
var
    StringSize: DWORD;
    tempchar: char;
    i: integer;
begin
    result := '';

    // Read the string's header.
    GFF.Read(StringSize, SizeOf(StringSize));

    // Read the string.
    if ( StringSize > 0 ) then
        for i := 1 to StringSize do begin
            GFF.Read(tempchar, sizeof(tempchar));
            // Having trouble with extended characters, so I'll just convert
            // them all to question marks. (Faster than writing a decoder.) --TK
            if tempchar > #126 then
                tempchar := '?';
            {$ifdef WIN32}
            // Convert newlines
            if tempchar = #10 then
                result := result + #13;
            {$endif}
            result := result + tempchar;
        end;
end;


// Checks Header for validitiy for an ERF of size ErfSize.
// ErfName is used in error messages.
function ValidateERFHeader(const Header: TERFHeader; ErfSize: Int64; const ErfName: string) : boolean;
begin
    // Assume invalid until all tests are passed.
    result := FALSE;

    // Validate internally-stored file type.
    if (Header.FileType <> 'MOD ') and
       (Header.FileType <> 'ERF ') and
       (Header.FileType <> 'HAK ') and
       (Header.FileType <> 'SAV ')
    then
        Application.MessageBox(PChar('Error reading file: ' + ansistring(ErfName) + '.'#10#10 +
                                          'This does not appear to be a NWN module, ' +
                                          'hak pak, or Toolset export.'),
                               'Error - loading aborted!', MB_OK)

    // Validate file format version.
    else if Header.Version <> 'V1.0' then
        Application.MessageBox(PChar('Error reading file: ' + ansistring(ErfName) + '.'#10#10 +
                                     'This file appears to be an encrypted version.'),
                               'Error - loading aborted!', MB_OK)

    // Validate file section offsets and lengths.
    else if (Header.OffsetToLocalizedString + Header.LocalizedStringSize > ErfSize) or
            (Header.OffsetToKeyList         + Header.EntryCount*24       > ErfSize) or
            (Header.OffsetToResourceList    + Header.EntryCount*8        > ErfSize)
    then
        Application.MessageBox(PChar('Error reading file: ' + ansistring(ErfName) + '.'#10#10 +
                                     'The file appears to be corrupt.'),
                               'Error - loading aborted!', MB_OK)

    else
        // Passed all tests.
        result := TRUE;
end;


// -----------------------------------------------------------------------------
// Private pieces of the public interface
// (Broken out to be more manageable.)

// -----------------------------------------------------------------------------
// Reading


// Reads creature, item, and placeable data from the specified file (module,
// hak pak, or .erf) into ModCreatureList, ModItemList, and ModPlaceableList.
//
// Returns TRUE upon succes; FALSE upon failure.
//
// Called from LoadMod() and LoadModuleHaks().
function LoadERF(const mod_name:ansistring; var ModCreatureList, ModItemList, ModPlaceableList: TResourceList): boolean;
var
    ModFile: TFileStream;
    Header: TERFHeader;

    ResRef : array [0..15] of char;
    ResID  : DWORD;
    ResType: WORD;
    UnUsed : array [0..1] of char;

    res_num: integer;
begin
    result := false;

    // Open the module and read the header.
    ModFile := TFileStream.Create(mod_name, fmOpenRead or fmShareDenynone);
    ModFile.Read(Header, SizeOf(Header));

    // Is this a valid module?
    if not ValidateERFHeader(Header, ModFile.Size, mod_name) then
        exit;

    // Loop through the entries in the file, and store retrieval information for
    // later on these filetypes:
    // item (.uti; 2025), creature (.utc; 2027), or placeable (.utp; 2044)
    ModFile.Seek(Header.OffsetToKeyList, soFromBeginning);
    for res_num := 0 to Header.EntryCount-1 do begin
        // Read this resource's information.
        ModFile.Read(ResRef, SizeOf(ResRef));
        ModFile.Read(ResID, SizeOf(ResID));
        ModFile.Read(ResType, SizeOf(ResType));
        ModFile.Read(UnUsed, SizeOf(UnUsed));

        // Decide where to add this resource (if anywhere).
        case ResType of
            2025: ModItemList.Add(ResRef, ResID, mod_name);
            2027: ModCreatureList.Add(ResRef, ResID, mod_name);
            2044: ModPlaceableList.Add(ResRef, ResID, mod_name);
        end;
    end;

    // Cleanup.
    ModFile.Free();

    // Flag success.
    result := true;
end;


// Given a GFF containing module.ifo, this loads that module's hak paks
// (and records the custom talk table, if any).
//
// Called from LoadMod().
procedure LoadModuleHaks(GFF: TStream; var ModCreatureList, ModItemList, ModPlaceableList: TResourceList;
                         var ModTalkName: ansistring);
var
    // GFF header info.
    FileType, FileVersion: array [0..3] of char;
    FieldOffset, FieldCount,
    LabelOffset, LabelCount,
    FieldDataOffset, FieldDataCount: DWORD;

    // GFF field and string info.
    FieldType, FieldLabel, FieldData: DWORD;
    StringLength: DWORD;

    // Misc.
    field_num:  integer;
    ThisLabel:  array[0..15] of char;
    ReturnHere: int64;
    HakName:    ansistring;
    HakDir:     ansistring;
begin
    HakDir := AppendPathDelim(main.nwnloc + 'hak');

    // ----------
    // Read the GFF header info.
    GFF.Seek(0, soFromBeginning);
    GFF.Read(FileType, SizeOf(FileType));
    GFF.Read(FileVersion, SizeOf(FileVersion));
    GFF.Seek(8, soFromCurrent);     // Skipping structure offset and count.
    GFF.Read(FieldOffset, SizeOf(FieldOffset));
    GFF.Read(FieldCount, SizeOf(FieldCount));
    GFF.Read(LabelOffset, SizeOf(LabelOffset));
    GFF.Read(LabelCount, SizeOf(LabelCount));
    GFF.Read(FieldDataOffset, SizeOf(FieldDataOffset));
    GFF.Read(FieldDataCount, SizeOf(FieldDataCount));

    // Safety checks.
    if (FileType <> 'IFO ') or (FileVersion <> 'V3.2')          or
       (GFF.Size < FieldOffset + FieldCount*12)                 or
       (GFF.Size < LabelOffset + LabelCount*SizeOf(ThisLabel))  or
       (GFF.Size < FieldDataOffset + FieldDataCount) then
        // We are missing key data; cannot continue.
        exit;


    // ----------
    // Loop through the GFF fields.
    GFF.Seek(FieldOffset, soFromBeginning);
    for field_num := 0 to FieldCount-1 do begin
        // Read the field.
        GFF.Read(FieldType, SizeOf(FieldType));
        GFF.Read(FieldLabel, SizeOf(FieldLabel));
        GFF.Read(FieldData, SizeOf(FieldData));

        // We only care about CExoStrings (type 10)
        // (and also make sure the offset data is not obviously corrupt).
        if (FieldType = 10) and
           (FieldData + SizeOf(DWORD) < FieldDataCount) then
        begin
            // Record our location so we can restore it.
            ReturnHere := GFF.Position;

            // See if the label interests us.
            GFF.Seek(LabelOffset + FieldLabel*16, soFromBeginning);
            GFF.Read(ThisLabel, SizeOf(ThisLabel));
            if (ThisLabel = 'Mod_Hak') or (ThisLabel = 'Mod_CustomTlk') then
            begin
                // Locate the string.
                GFF.Seek(FieldDataOffset + FieldData, soFromBeginning);
                // Peek at its length in the GFF.
                GFF.Read(StringLength, sizeof(StringLength));
                GFF.Seek(-sizeof(StringLength), soFromCurrent);
                // Validate the length.
                if FieldData + sizeof(WORD) + StringLength < FieldDataCount then begin
                    if ThisLabel = 'Mod_CustomTlk' then
                        // Save the name of the custom .tlk for later.
                        ModTalkName := AppendPathDelim(main.nwnloc+'tlk') + ReadGFFString(GFF) + '.tlk'
                    else begin
                        // Load the hak resources.
                        HakName := HakDir + ReadGFFString(GFF) + '.hak';
                        if FileExists(HakName) then
                            LoadERF(HakName, ModCreatureList, ModItemList, ModPlaceableList)
                        else
                            Application.MessageBox(PChar('Unable to locate hak pak ' +
                                                         HakName +'. Skipping.'),
                                                   'Missing file', MB_OK);
                    end;
                end;
            end;

            // Restore the stream's previous position.
            GFF.Seek(ReturnHere, soFromBeginning);
        end;//if FieldType
    end;//for field_num
end;


// -----------------------------------------------------------------------------
// Writing


// Instead of recalculating ERF offsets to match the data we have, we can mostly
// re-use existing offsets. This simplifies the retrieval of resource data
// (assuming that data is the tail of the file after the resource list), but means
// we may have to jump around the file at times, possibly padding with nulls.
// This function takes care of that.
// Returns FALSE on error.
//
// Called by WriteScriptIntoErf().
function MoveStreamToPos(var Stream: TFileStream; MoveTo: int64): boolean;
const
    NullChar : char = #0;
var
    iNeeded: integer;
begin
    // Assume things will go well.
    Result := true;

    try
        // Start by guessing everything might be "normal" (so nothing to do).
        if Stream.Position = MoveTo then
            exit;

        // Moving within the existing file is easy.
        if Stream.Size >= MoveTo then
            Stream.Seek(MoveTo, soFromBeginning)
        else begin
            // We are trying to move beyond end of Stream, so we will have to fill it.
            Stream.Seek(0, soFromEnd);
            for iNeeded := MoveTo - Stream.Position downto 1 do
                Stream.Write(NullChar, SizeOf(char));
        end;
    except
        // Flag a problem.
        Result:=false;
    end;
end;


// Writes an ERF file using the information provided, appending the given streams
// to the resources under then name ScriptName with types .nss and .ncs.
// This will append just the .nss if the second stream is nil.
// (ErfName is a full path; ScriptName is just a ResRef.)
// Returns TRUE if the save was successful.
//
// The provided information may be updated for the appended ERF. Basically, they
// are mostly passed as VAR parameters for efficiency, while the calling routines
// do not look at their contents after calling this function. Probably safest to
// consider them junk after calling this.
//
// Called by AppendToERF() and OverwriteERF().
function  WriteScriptIntoErf(const ScriptName: TString16; const ERFName: ansistring;
                             var MyHeader:    TErfHeader;
                             var MyStrings:   TErfStringList;
                             var MyKeys:      TErfKeyList;
                             var MyResources: TErfResourceList;
                                 MyData:      TStream; // Can be nil if there is no data yet.
                                 MySize:      Int64;
                             NSS, NCS: TStream) : boolean;
const
    NullChar : char = #0;
    NullWord : WORD = 0;
    NSS_Type : WORD = 2009;
    NCS_Type : WORD = 2010;
var
    ERF: TFileStream;

    iResource, iLanguage, iChar: integer;
    OldResources, NewResources: DWORD;
    dwBuffer: DWORD; // For storing DWORDs that will be written to a TStream.
begin
    result := FALSE;
    OldResources := MyHeader.EntryCount;
    if NCS = nil then
        NewResources := 1
    else
        NewResources := 2;

    // Catch exceptions while writing.
    try
        // There are more entries.
        MyHeader.EntryCount += NewResources;
        // This pushes the resource list back by X keys.
        MyHeader.OffsetToResourceList += NewResources * SizeOf(TErfKey);
        // Resources get pushed back by keys plus resource headers.
        for iResource := 0 to High(MyResources) do
            MyResources[iResource].Offset += NewResources * (SizeOf(TErfKey) + SizeOf(TErfResource));
        // Also increase MySize, as this is where the new resource(s) will be added.
        MySize += NewResources * (SizeOf(TErfKey) + SizeOf(TErfResource));

        // (Re)build the ERF file.
        if FileExists(ERFName) then
            DeleteFile(ERFName);
        ERF := TFileStream.Create(ERFName, fmCreate or fmShareExclusive);

        // Header:
        ERF.Write(MyHeader, SizeOf(MyHeader));

        // String list:
        if not MoveStreamToPos(ERF, MyHeader.OffsetToLocalizedString) then
            raise Exception.Create('Stream move error');
        for iLanguage := 0 to MyHeader.LanguageCount - 1 do
            with MyStrings[iLanguage] do begin
                // Language, size, then the string itself.
                ERF.Write(Language, SizeOf(Language));
                ERF.Write(Size,     SizeOf(Size));
                for iChar := 0 to Size - 1 do
                    ERF.Write(AString[iChar], SizeOf(AString[iChar]));
            end;

        // Key list:
        if not MoveStreamToPos(ERF, MyHeader.OffsetToKeyList) then
            raise Exception.Create('Stream move error');
        for iResource := 0 to OldResources - 1 do
            with MyKeys[iResource] do begin
                // ResRef, ResID, ResType, then unused bytes.
                // (I could possibly further simplify this by writing a record at a time,
                //  but that would require additional testing to make sure I did not
                //  break this part. Same goes for writing the resources. --TK)
                for iChar := 0 to 15 do
                    ERF.Write(ResRef[iChar], SizeOf(ResRef[iChar]));
                ERF.Write(ResId,   SizeOf(ResID));
                ERF.Write(ResType, SizeOf(ResType));
                ERF.Write(UnUsed,  SizeOf(UnUsed));
            end;
        // Now the key for the script source.
        for iChar := 1 to Length(ScriptName) do
            ERF.Write(ScriptName[iChar], SizeOf(char));
        for iChar := Length(ScriptName) + 1 to 16 do
            ERF.Write(NullChar, SizeOf(char));
        ERF.Write(DWORD(OldResources), SizeOf(DWORD));
        ERF.Write(NSS_Type, SizeOf(WORD));
        ERF.Write(NullWord, SizeOf(WORD));
        // Now the key for the compiled script.
        if NCS <> nil then begin
            for iChar := 1 to Length(ScriptName) do
                ERF.Write(ScriptName[iChar], SizeOf(char));
            for iChar := Length(ScriptName) + 1 to 16 do
                ERF.Write(NullChar, SizeOf(char));
            dwBuffer := OldResources + 1;
            ERF.Write(dwBuffer, SizeOf(DWORD));
            ERF.Write(NCS_Type, SizeOf(WORD));
            ERF.Write(NullWord, SizeOf(WORD));
        end;

        // Resource list:
        if not MoveStreamToPos(ERF, MyHeader.OffsetToResourceList) then
            raise Exception.Create('Stream move error');
        for iResource := 0 to OldResources - 1 do
            with MyResources[iResource] do begin
                // Offset then size.
                ERF.Write(Offset, SizeOf(Offset));
                ERF.Write(Size,   SizeOf(Size));
            end;
        // Now the resource element for the script source.
        dwBuffer := DWORD(MySize);      ERF.Write(dwBuffer, SizeOf(dwBuffer));
        dwBuffer := DWORD(NSS.Size);    ERF.Write(dwBuffer, SizeOf(dwBuffer));
        // Now the resource element for the compiled script.
        if NCS <> nil then begin
            dwBuffer := DWORD(MySize + NSS.Size);   ERF.Write(dwBuffer, SizeOf(dwBuffer));
            dwBuffer := DWORD(NCS.Size);            ERF.Write(dwBuffer, SizeOf(dwBuffer));
        end;

        // Resource data:
        if MyData <> nil then
            ERF.CopyFrom(MyData, 0);
        ERF.CopyFrom(NSS, 0);
        if NCS <> nil then
            ERF.CopyFrom(NCS, 0);

        // Done.
        ERF.Destroy();
        result := TRUE;
    except
        Application.MessageBox(PChar(AnsiString('') +
            'There was an error while writing to the '+ExtractFileExt(ERFName)+' file. '+
            'A likely cause for this error is that the file was already open, '+
            'e.g. in the Toolset. Close all programs using the original file and try again. '+
            'You may also need to restart the Script Generator.'),
            'Error', mb_OK);
    end;
end;


// -----------------------------------------------------------------------------
// Public interface
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Reading


// Returns a newly-created TMemoryStream containing the GFF identified by GFFLocator.
// On error, sError will be set to a message.
function GetGFF(const GFFLocator: TGFFLocator; out sError: shortstring) : TMemoryStream;
var
    BIF: TFileStream;
begin
    // Default values.
    result := nil;
    sError := '';

    // Find the file containing the GFF.
    if not fileexists(GFFLocator.FileName) then
        sError := 'Error reading resource. File is missing.'
    else begin
        // Open the file and validate the position of the GFF.
        BIF := TFileStream.Create(GFFLocator.FileName, fmOpenRead or fmShareDenyWrite);
        if GFFLocator.Offset > BIF.Size then
            sError := 'Error reading resource. GFF is missing.'
        else if GFFLocator.Offset + GFFLocator.Length > BIF.Size then
            sError := 'Error reading resource. GFF is truncated.'
        else begin
            // Copy the GFF into a memory stream.
            BIF.Seek(GFFLocator.Offset, soFromBeginning);
            result := TMemoryStream.Create();
            result.CopyFrom(BIF, GFFLocator.Length);
        end;

        // Cleanup.
        BIF.Free();
    end;
end;


// Loads creature, item, and placeable data from the specified .key file into
// the specified lists.
//
// For more info on BioWare file formats, check out http://nwn.bioware.com/developers
//
// If someone wants to make this more general (for use outside the Script Generator,
// maybe a backport into BioSearcher?), the likely parts to change are the parameters
// (to specify which resource types to load and to make the number of lists variable)
// and the "case" statement towards the end of this procedure. --TK
procedure LoadBifKey(const keyname:ansistring; var CreatureList, ItemList, PlaceableList: TResourceList);
var
    BifKey:   TFileStream;

    // For reading the .key:
    KeyHeader: TKeyHeader;
    FileEntry: array of TFileEntry;
    FileNames: array of ansistring;
    KeyEntry: TKeyEntry;

    // Misc.
    entry, charcount: integer;
    tempchar: char;
begin
    // Open the .key and read its header.
    BifKey := Tfilestream.create(keyname, fmOpenRead or fmShareDenyWrite);
    BifKey.Read(KeyHeader, sizeof(KeyHeader));

    // Read the list of .bif files into FileEntry[].
    BifKey.Seek(KeyHeader.OffsetToFileTable, soFromBeginning);
    SetLength(FileEntry, KeyHeader.BifCount);
    for entry := 0 to KeyHeader.BifCount-1 do
        BifKey.Read(FileEntry[entry], SizeOf(FileEntry[entry]));

    // Read the .bif names into FileNames[].
    SetLength(FileNames, KeyHeader.BifCount);
    for entry := 0 to KeyHeader.BifCount-1 do
    begin
        BifKey.Seek(FileEntry[entry].FileNameOffset, soFromBeginning);
        // Read this file name into FileNames[entry].
        FileNames[entry] := main.nwnloc;
        for charcount := 1 to FileEntry[entry].FileNameSize do
        begin
            BifKey.Read(tempchar, sizeof(tempchar));
            // Convert directory separators (potential Linux support).
            if tempchar = '\' then
                FileNames[entry] := AppendPathDelim(FileNames[entry])
            else
                FileNames[entry] += tempchar;
        end;
    end;


    // Read the list of resources.
    BifKey.seek(KeyHeader.OffsetToKeyTable, soFromBeginning);
    for entry := 0 to KeyHeader.KeyCount-1 do
    begin
        // Read an entry.
        BifKey.read(KeyEntry.ResRef,       sizeof(KeyEntry.ResRef));
        BifKey.read(KeyEntry.ResourceType, sizeof(KeyEntry.ResourceType));
        BifKey.read(KeyEntry.ResID,        sizeof(KeyEntry.ResID));

        // Determine which list should recieve this entry.
        case KeyEntry.ResourceType of
            2025: ItemList.Add(KeyEntry.ResRef, KeyEntry.ResID, FileNames);
            2027: CreatureList.Add(KeyEntry.ResRef, KeyEntry.ResID, FileNames);
            2044: PlaceableList.Add(KeyEntry.ResRef, KeyEntry.ResID, FileNames);
        end;
    end;

    // Cleanup.
    BifKey.Free();
end;


// Loads creature, item, and placeable data from the specified module/hak pak/.erf
// file into ModCreatureList, ModItemList, and ModPlaceableList. In addition,
// if the file is a module, any associated hak paks and talk file are attempted
// to be loaded.
// Returns TRUE upon succes; FALSE upon failure.
function LoadMod(const mod_name:ansistring; var ModCreatureList, ModItemList, ModPlaceableList: TResourceList;
                 var ModTalkName: ansistring): boolean;
var
    ModFile: TFileStream;
    Header:  TERFHeader;
    GFF:     TMemoryStream;

    ResRef : array [0..15] of char;
    ResID  : DWORD;
    ResType: WORD;
    UnUsed : array [0..1] of char;
    ResourceOffset, ResourceLength: DWORD;

    res_num: integer;
begin
    // Dump any old data.
    if ModCreatureList <> nil then
        ModCreatureList.Free();
    if ModItemList <> nil then
        ModItemList.Free();
    if ModPlaceableList <> nil then
        ModPlaceableList.Free();
    // ModTalkName := ''; // Uncommenting this would be correct, I suppose, but
                          // not resetting the talk name should not cause problems,
                          // and it would allow, for example, opening a CEP module
                          // to set the custom talk table, then loading a specific
                          // CEP hak pak.
    // Start fresh with new lists.
    ModCreatureList  := TResourceList.Create();
    ModItemList      := TResourceList.Create();
    ModPlaceableList := TResourceList.Create();

    // Load the data.
    result := LoadERF(mod_name, ModCreatureList, ModItemList, ModPlaceableList);

    // -------------
    if result then begin
        // Go for the hak list.
        ModFile := TFileStream.Create(mod_name, fmOpenRead or fmShareDenynone);
        ModFile.Read(Header, SizeOf(Header));
        // Most header data was validated by LoadErf(), aside from the resource list.
        // In addition, we only need to proceed if this is a module.
        if (Header.FileType = 'MOD ') and
           (Header.OffsetToResourceList + Header.EntryCount*8 <= ModFile.Size) then begin

            // Make sure we can search just the module (not haks) if desired.
            ModItemList.EnsureFile(mod_name, ErfFileType);
            ModCreatureList.EnsureFile(mod_name, ErfFileType);
            ModPlaceableList.EnsureFile(mod_name, ErfFileType);

            // Loop through the entries in the file, looking for module.ifo.
            ModFile.Seek(Header.OffsetToKeyList, soFromBeginning);
            for res_num := 0 to Header.EntryCount-1 do begin
                // Read this resource's information.
                ModFile.Read(ResRef, SizeOf(ResRef));
                ModFile.Read(ResID, SizeOf(ResID));
                ModFile.Read(ResType, SizeOf(ResType));
                ModFile.Read(UnUsed, SizeOf(UnUsed));

                // Is this what we are looking for (module.ifo)?
                if (lowercase(ResRef) = 'module') and (ResType = 2014) then begin
                    // Locate the GFF in the module.
                    ModFile.Seek(Header.OffsetToResourceList + res_num*8,
                                 soFromBeginning);
                    ModFile.Read(ResourceOffset, SizeOf(ResourceOffset));
                    ModFile.Read(ResourceLength, SizeOf(ResourceLength));

                    // Safety check
                    if ResourceOffset + ResourceLength <= ModFile.Size then begin
                        // Extract the GFF
                        ModFile.Seek(ResourceOffset, soFromBeginning);
                        GFF := TMemoryStream.Create();
                        GFF.CopyFrom(ModFile, ResourceLength);
                        // Process the GFF.
                        LoadModuleHaks(GFF, ModCreatureList, ModItemList, ModPlaceableList, ModTalkName);
                        // Cleanup.
                        GFF.Free();
                    end;

                    // We found module.ifo, so no need to continue looping.
                    break;
                end;//if module.ifo
            end;//for res_num
        end;//if safety check

        // Cleanup.
        ModFile.Free();
    end;//if result
    // -------------

    // Cleanup.
    ModItemList.DoneAdding();
    ModCreatureList.DoneAdding();
    ModPlaceableList.DoneAdding();
end;


// Parses the provided GFF and, if it is a blueprint (UT*), returns the name,
// tag, description, and comment.
// Returns '' or an error string.
function ReadBlueprintProperties(GFF: TStream; out Name, Tag, Desc, DescID, Comment: ansistring;
                                 const ModTalkName: ansistring) : shortstring;
var
    // Talk table
    TLK: TFileStream;
    CustTLK: TFileStream;
    LanguageID: DWORD = 0;

    // GFF header and info
    FileType, FileVersion: array [0..3] of char;
    FieldOffset, FieldCount,
    LabelOffset, LabelCount,
    FieldDataOffset, FieldDataCount: DWORD;
    FieldType, FieldLabel, FieldData: DWORD;
    StringLength: DWORD;

    // Misc.
    field_num:  integer;
    ReturnHere: int64;
    ThisLabel:  array[0..15] of char;
    sData:      ansistring;
    psOut:      ^ansistring;
begin
    // Initialize our output.
    Name    := '';
    Tag     := '';
    Desc    := '';
    DescID  := '';
    Comment := '';
    result  := '';

    // Read the GFF header info.
    GFF.Seek(0, soFromBeginning);
    GFF.Read(FileType, SizeOf(FileType));
    GFF.Read(FileVersion, SizeOf(FileVersion));
    GFF.Seek(8, soFromCurrent);     // Skipping structure offset and count.
    GFF.Read(FieldOffset, SizeOf(FieldOffset));
    GFF.Read(FieldCount, SizeOf(FieldCount));
    GFF.Read(LabelOffset, SizeOf(LabelOffset));
    GFF.Read(LabelCount, SizeOf(LabelCount));
    GFF.Read(FieldDataOffset, SizeOf(FieldDataOffset));
    GFF.Read(FieldDataCount, SizeOf(FieldDataCount));

    // Safety checks.
    if (copy(FileType, 1, 2) <> 'UT') or (FileVersion <> 'V3.2') or
       (GFF.Size < LabelOffset + LabelCount*SizeOf(ThisLabel))   or
       (GFF.Size < FieldOffset + FieldCount*3*SizeOf(DWORD))     or
       (GFF.Size < FieldDataOffset + FieldDataCount) then
    begin
        // We are missing key data; cannot continue.
        result := 'Error reading resource. GFF is corrupt.';
        exit;
    end;

    // Load the talk files in case they will be referenced.
    if not fileexists(main.nwnloc+'dialog.tlk') then
        TLK := nil
    else begin
        TLK := TFileStream.Create(main.nwnloc+'dialog.tlk', fmOpenRead or fmShareDenyWrite);
        // Also grab the language ID.
        TLK.Seek(8, soFromBeginning);
        TLK.Read(LanguageID, sizeof(LanguageID));
    end;
    // Custom talk file, if any:
    if ModTalkName = '' then
        CustTLK := nil
    else if not fileexists(ModTalkName) then
        CustTLK := nil
    else
        CustTLK := TFileStream.Create(ModTalkName, fmOpenRead or fmShareDenyWrite);

    // ----------
    // Loop through the GFF fields.
    GFF.Seek(FieldOffset, soFromBeginning);
    for field_num := 0 to FieldCount-1 do begin
        // Read the field.
        GFF.Read(FieldType,  SizeOf(FieldType));
        GFF.Read(FieldLabel, SizeOf(FieldLabel));
        GFF.Read(FieldData,  SizeOf(FieldData));

        // We only care about CExoStrings and CExoLocStrings (types 10 and 12)
        // (and also make sure the offset data is not obviously corrupt).
        if ((FieldType = 10) or (FieldType = 12)) and
           (FieldData + SizeOf(DWORD) < FieldDataCount) then
        begin
            // Record our location so we can restore it.
            ReturnHere := GFF.Position;

            // See if the label interests us.
            GFF.Seek(LabelOffset + FieldLabel*16, soFromBeginning);
            GFF.Read(ThisLabel, SizeOf(ThisLabel));
            if (ThisLabel = 'LocName')    or  (ThisLabel = 'LocalizedName')  or
               (ThisLabel = 'FirstName')  or  (ThisLabel = 'LastName') then
                psOut := @Name
            else if ThisLabel = 'Tag' then
                psOut := @Tag
            else if ThisLabel = 'DescIdentified' then
                psOut := @DescID
            else if ThisLabel = 'Description' then
                psOut := @Desc
            else if ThisLabel = 'Comment' then
                psOut := @Comment
            else
                psOut := nil;

            // Read this?
            if psOut <> nil then begin
                // Locate the string.
                GFF.Seek(FieldDataOffset + FieldData, soFromBeginning);
                // Peek at its length in the GFF.
                GFF.Read(StringLength, sizeof(StringLength));
                GFF.Seek(-sizeof(StringLength), soFromCurrent);
                // Validate the length.
                if FieldData + sizeof(WORD) + StringLength < FieldDataCount then
                    // Get the string.
                    case FieldType of
                        10: sData := ReadGFFString(GFF);
                        12: sData := ReadGFFLocString(GFF, TLK, CustTLK, LanguageID);
                    end
                else
                    // Erase any old value that might be present.
                    sData := '';

                // Add this data to the appropriate output string.
                // Two special cases:
                if ThisLabel = 'FirstName' then
                    Name := sData + Name
                else if ThisLabel = 'LastName' then
                    Name := Name + sData
                else
                    psOut^ := sData;
            end;//if psOut

            // Restore the stream's previous position.
            GFF.Seek(ReturnHere, soFromBeginning);
        end;//if FieldType
    end;//for field_num

    // Cleanup.
    if TLK <> nil then
        TLK.Free();
    if CustTLK <> nil then
        CustTLK.Free();
end;


// -----------------------------------------------------------------------------
// Writing


// Appends the TStreams to the file named ERFName. The names within the ERF
// will be ScriptName, while the types will be .nss and .ncs.
// (ERFName is a full path; ScriptName is just a ResRef.)
// Returns TRUE if the save was successful.
function  AppendToErf(const ScriptName: TString16; const ERFName: ansistring; NSS, NCS: TStream; bBackup: boolean) : boolean;
var
    BackupName: ansistring;
    iLanguage, iResource, iChar: integer;

    ERF: TFileStream = nil;
    // Reading from ERF:
    MyHeader:    TERFHeader;
    MyStrings:   TErfStringList;
    MyKeys:      TErfKeyList;
    MyResources: TErfResourceList;
    MyData:      TMemoryStream;
    MySize:      Int64;
begin
    // Not saved yet.
    result := FALSE;

    // Catch exceptions when reading the .erf.
    try
        // Firest we read the ERF into memory.
        ERF := TFileStream.create(ERFName, fmOpenRead or fmShareExclusive);
        MySize := ERF.Size;

        // Header data:
        ERF.Read(MyHeader, SizeOf(MyHeader));
        if not ValidateERFHeader(MyHeader, MySize, ERFName) then begin
            ERF.Destroy();
            exit;
        end;

        // Localized string list:
        SetLength(MyStrings, MyHeader.LanguageCount);
        ERF.Seek(MyHeader.OffsetToLocalizedString, soFromBeginning);
        for iLanguage := 0 to MyHeader.LanguageCount-1 do
            with MyStrings[iLanguage] do begin
                // Each entry in the list is a language ID, a length, then a string.
                ERF.Read(Language, SizeOf(Language));
                ERF.Read(Size,     SizeOf(Size));
                // And now the variable-length string.
                SetLength(AString, Size);
                for iChar := 0 to Size - 1 do
                    ERF.Read (AString[iChar], Sizeof(char));
            end;

        // Key list:
        SetLength(MyKeys, MyHeader.EntryCount);
        ERF.Seek(MyHeader.OffsetToKeyList, soFromBeginning);
        for iResource := 0 to MyHeader.EntryCount-1 do
            with MyKeys[iResource] do begin
                // Each entry in the list is a ResRef, ResID, ResType, then two unused bytes.
                // (I could possibly further simplify this by reading a record at a time,
                //  but that would require additional testing to make sure I did not
                //  break this part. Same goes for reading the resources. --TK)
                ERF.Read(ResRef,  SizeOf(ResRef));
                ERF.Read(ResID,   SizeOf(ResId));
                ERF.Read(ResType, SizeOf(ResType));
                ERF.Read(UnUsed,  SizeOf(UnUsed));

                // We do not overwrite resources, so make sure we did not just find
                // an .nss or .ncs of the chosen name.
                if ( (2009 = ResType)  or  (2010 = ResType) )
                   and  (ScriptName = ResRef) then
                begin
                    Application.MessageBox(AnsiString('')+
                        'The file already contains a script of the chosen name. '+
                        'The Script Generator does not allow overwriting existing '+
                        'resources. Please try again with a different script name.',
                        'Error', mb_OK);
                    ERF.Destroy();
                    exit;
                end;
            end;

        // Resource list:
        SetLength(MyResources, MyHeader.EntryCount);
        ERF.Seek(MyHeader.OffsetToResourceList, soFromBeginning);
        for iResource := 0 to MyHeader.EntryCount-1 do
            with MyResources[iResource] do begin
                // Each entry in the list is an offset then a size.
                ERF.Read(Offset, SizeOf(Offset));
                ERF.Read(Size,   SizeOf(Size));
            end;

        // Resource data:
        // We are assuming that the data does immediately follow the list.
        // (Usually a good assumption, I guess. --TK)
        MyData := TMemoryStream.Create();
        MyData.CopyFrom(ERF, MySize-ERF.Position);

        // Cleanup.
        ERF.Destroy();
    except
        Application.MessageBox(PChar(AnsiString('')+
            'There was an error while reading from the '+ExtractFileExt(ERFName)+' file. '+
            'The most likely cause for this error is that the file was already open, e.g. '+
            'in the Toolset. Close all programs using the original file and try again. '+
            'You may also need to restart the Script Generator.'),
            'Error', mb_OK);
        if ERF <> nil then
            ERF.Destroy();
        exit;
    end;

    // Make a backup?
    if bBackup then
        try
            BackupName := ERFName+'.bak';
            if fileexists(BackupName) then
                DeleteFile(BackupName);
            CopyFile(ERFName, BackupName, false);
        except
            if Application.MessageBox('Could not create backup file. Would you '+
                                      'like to continue without creating a backup?',
                                      'Error creating backup', mb_YESNO) = IDNO then
            begin
                // Cleanup and abort.
                MyData.Destroy();
                exit;
            end;
        end;

    // Write this out.
    result := WriteScriptIntoErf(ScriptName, ERFName, MyHeader, MyStrings, MyKeys,
                                 MyResources, MyData, MySize, NSS, NCS);
    if result then
        Application.MessageBox(PChar(AnsiString('')+
            'Your '+ExtractFileExt(ERFName)+' file has been appended to successfully.'),
            'Success!', mb_OK);

    // Cleanup.
    MyData.Destroy();
end;


// Creates an ERF file named ERFName that contains the TStreams as resources
// named ScriptName, with types .nss and .ncs.
// (ERFName is a full path; ScriptName is just a ResRef.)
// Returns TRUE if the save was successful.
function  OverwriteErf(const ScriptName: TString16; const ERFName: ansistring; NSS, NCS: TStream) : boolean;
const
    FileComment = 'ERF made by Script Generator'#0; // Should be null-terminated.
    CommentLength = Length(FileComment);
var
    MyHeader:    TERFHeader;
    MyStrings:   TErfStringList;
    MyKeys:      TErfKeyList;
    MyResources: TErfResourceList;

    SystemTime: TSystemTime;
    iChar: integer;
begin
    // Not saved yet.
    result := FALSE;

    // Build an empty ERF.
    MyHeader.FileType := 'ERF ';
    MyHeader.Version := 'V1.0';
    MyHeader.LanguageCount := 1;
    MyHeader.LocalizedStringSize := 8 + CommentLength; // 37 currently.
    MyHeader.EntryCount := 0;
    MyHeader.OffsetToLocalizedString := 160;
    MyHeader.OffsetToKeyList := 160 + MyHeader.LocalizedStringSize; // 197 currently.
    MyHeader.OffsetToResourceList := MyHeader.OffsetToKeyList;
    MyHeader.DescStrRef := $FFFFFFFF;
    // The build year and date are not really important. We will make some effort
    // to fill these in, but simplicity will reign over accuracy.
    GetLocalTime(SystemTime);
    MyHeader.BuildYear := SystemTime.Year - 1900;
    MyHeader.BuildDay := 30*(SystemTime.Month-1) + SystemTime.Day; // This is the simplification/approximation.
    // Pad with nulls.
    for iChar := Low(MyHeader.UnusedByProgram) to High(MyHeader.UnusedByProgram) do
        MyHeader.UnusedByProgram[iChar] := #0;

    // Localized string list:
    SetLength(MyStrings, 1);
    MyStrings[0].Language := 0;
    MyStrings[0].Size     := CommentLength;
    SetLength(MyStrings[0].AString, CommentLength);
    for iChar := 1 to CommentLength do
        MyStrings[0].AString[iChar-1] := FileComment[iChar];

    // No resources
    SetLength(MyKeys, 0);
    SetLength(MyResources, 0);

    // Write this out.
    result := WriteScriptIntoErf(ScriptName, ERFName, MyHeader, MyStrings, MyKeys,
                                 MyResources, nil, MyHeader.OffsetToResourceList,
                                 NSS, NCS);
    if result then
        Application.MessageBox('Your .erf file was created successfully.',
                               'Success!', mb_OK);
end;


// -----------------------------------------------------------------------------
    { TResourceList }
// -----------------------------------------------------------------------------


// Constructor for TResourceList.
constructor TResourceList.Create();
begin
    // Initialize our fields.
    SetLength(FileNames, 0);
    SetLength(FileTypes, 0);
    SetLength(Resources, 0);
    HashPtr := TFPHashList.Create();
    // An estimate on how big a hash we might need.
    // The largest of creatures, items, and placeables appears to be items,
    // weighing in at 4197. Do we need to inflate this number to reduce
    // collisions? Not sure, and there should be enough memory, so let's go
    // with something about 50% bigger, maybe a prime number?
    HashPtr.Capacity := 6299;
end;


// Destructor for TResourceList.
destructor TResourceList.Destroy();
var
    index: integer;
begin
    // Release all memory associated with this instance.
    if HashPtr <> nil then
        HashPtr.Free();
    // The following is probably not necessary, but I judge the cost of coding
    // it to be less than the cost of testing its necessity.
    for index := High(Resources) downto 0 do
        SetLength(Resources[index], 0);
    SetLength(Resources, 0);
    SetLength(FileTypes, 0);
    SetLength(FileNames, 0);

    // Daisy chain.
    inherited Destroy();
end;


// Private version of Add() -- this stores ResRef and the index into file_name,
// as well as flagging file_name to be of a certain type (file_type), so we know
// how to retrieve the corresponding GFF later.
procedure TResourceList.Add(const ResRef: array of char; index: DWORD; const file_name: ansistring;
                            file_type: TEResourceFile);
var
    i, max_i: integer;
    sResRef : TString16;
    file_num: integer;
    res_num : integer;
begin
    // Possible quick abort if DoneAdding() was called.
    if HashPtr = nil then
        exit;

    // Convert the character array to an official short string.
    SetLength(sResRef, 16);
    // (I'll add some error checking here in case someone messes with
    //  code that calls this.)
    max_i := High(ResRef);
    if max_i > 15 then
        max_i := 15;
    // Copy characters.
    for i := 0 to max_i do
        sResRef[i+1] := lowercase(ResRef[i]); // Should be lowercase already, but just in case...
    // Fill in nulls if needed.
    for i := max_i+1 to 15 do
        sResRef[i+1] := #0;
    // Of course, maybe the compiler would take care of most of that if I just
    // assigned ResRef to sResRef, but better safe than sorry.


    // Make sure ResRefs are only added once.
    if HashPtr.FindIndexOf(sResRef) > -1 then
        exit;
    HashPtr.Add(sResRef, 1); // Do not care what the second parameters is, but it cannot be nil.

    // Make sure this file has a reference.
    file_num := EnsureFile(file_name, file_type);

    // Create space in which to record this resource.
    res_num := Length(Resources[file_num]);
    SetLength(Resources[file_num], res_num+1);
    // Store the resource.
    Resources[file_num][res_num].ResRef := sResRef;
    Resources[file_num][res_num].index  := index;
end;


// Adds a resource record, where the resource is specified by ResRef and
// index (ResID) into the file file_name. This is for use when the file is
// an ERF (includes modules).
procedure TResourceList.Add(const ResRef: array of char; ResID: DWORD; const file_name: ansistring); inline;
begin
    // Call the private Add(), with a flag that this is an ERF.
    Add(ResRef, ResID, file_name, ErfFileType);
end;


// Adds a resource record, where the resource is specified by ResRef and ResID,
// as read directly from a .key file.
// The (order-preserved) list of .bif names contained in the .key must also be supplied.
procedure TResourceList.Add(const ResRef: array of char; ResID: DWORD; const bif_names: array of ansistring);
var
    file_index: DWORD;
    res_index:  DWORD;
begin
    // Decompose the ResID.
    file_index := ResID shr 20;
    res_index  := ResID and $3FFF; // 14 bits.

    // Validate the file index.
    if file_index <= High(bif_names) then
        // Call the private Add(), with a flag that this is a BIF.
        Add(ResRef, res_index, bif_names[file_index], BifFileType);
end;


// Called to let the list know no more adds will take place.
// (Not strictly necessary, unless you want your results sorted.
//  Calling this also allows earlier release of some memory.)
procedure TResourceList.DoneAdding();
var
    FileNum: integer;
begin
    // Release the hash.
    if HashPtr <> nil then
        HashPtr.Free();
    HashPtr := nil;
    // You could keep the hash around if you wanted to allow later additions,
    // but since there is currently no need for that, might as well free the
    // memory.

    // Sort the resources.
    for FileNum := 0 to High(Resources) do
        DoSort(FileNum);
end;


// Sorts the resources for file file_num.
procedure TResourceList.DoSort(FileNum:integer);
var
    Indices: array of integer;
    TotalCount, i: integer;
    smallest: integer;
    TempAry:  TResourceKeys;
begin
    TotalCount := Length(Resources[FileNum]);

    // The sorting algorithm will work on an array of indices into
    // Resources[FileNum], reducing the cost of swaps.
    SetLength(Indices, TotalCount);

    // This will be a min-heap sort, which should be more efficient than
    // a traditional max-heap sort if the are already mostly sorted (because
    // a sorted array is a min-heap, no adjustments necessary). --TK

    // Construct the min-heap.
    // The tail end can just be filled in.
    for i := TotalCount-1 downto TotalCount div 2 do
        Indices[i] := i;
    // The remaining elements have children in the min-heap, so we need to be
    // sure to preserve the min-heap structure.
    for i := TotalCount div 2 - 1 downto 0 do
        FixMinHeap(FileNum, Indices, i, i, TotalCount-1);

    // Convert the min-heap to an ordered array.
    // After each iteration, the heap will be in [0..i-1], while the ordered
    // array will be in [i..TotalCount-1].
    for i := TotalCount-1 downto 1 do begin
        // "Swap" Indices[0] and Indices[i], but preserve the min-heap.
        smallest := Indices[0];
        FixMinHeap(FileNum, Indices, Indices[i], 0, i-1);
        Indices[i] := smallest;
    end;

    // Re-order Resources[FileNum] based on Indices.
    SetLength(TempAry, TotalCount);
    for i := 0 to TotalCount-1 do
        TempAry[i] := Resources[FileNum][Indices[i]];
    // Reverse the order (to increasing) in the final array.
    for i := 0 to TotalCount-1 do
        Resources[FileNum][i] := TempAry[TotalCount-1 - i];
    SetLength(TempAry, 0);
end;


// Ensures mod_name is in the list of files covered.
// Returns the index of the file in the list.
function TResourceList.EnsureFile(const file_name: ansistring; file_type: TEResourceFile): integer;
var
    file_num: integer;
begin
    // Locate the specified file in our list of file names.
    // (Probably at the end. Maybe? Trying to optimize a little here.)
    file_num := High(FileNames);
    if file_num < 0 then
        // Need to start the list somewhere...
        file_num := 0
    else begin
        // Look through our list of file names
        while (file_num > 0) and (FileNames[file_num] <> file_name) do
            file_num -= 1;
        // Check for not found.
        if (FileNames[file_num] <> file_name) then
            // Trigger an append operation.
            file_num := High(FileNames)+1;
    end;

    // Test for this being a new file.
    if file_num > High(FileNames) then
    begin
        // Create space for info about this file.
        SetLength(FileNames, file_num+1);
        SetLength(FileTypes, file_num+1);
        SetLength(Resources, file_num+1);
        // Initialize said info.
        FileNames[file_num] := file_name;
        FileTypes[file_num] := file_type;
        SetLength(Resources[file_num], 0);
    end;

    // Return this index.
    result := file_num;
end;


// Part of min-heap sort.
// Indices is the array being sorted and contains indices into Resources[FileNum][].
// KeyIndex is the value to be inserted into the min-heap.
// Root and HeapEnd define the first and last elements of the min-heap.
procedure TResourceList.FixMinHeap(FileNum:integer; var Indices: array of integer;
                                   KeyIndex:integer; Root:integer; HeapEnd:integer);
var
    vacant, smaller: integer;
begin
    // The vacancy starts at the root.
    vacant := root;

    // While the vacancy has a child.
    // (Since Indices is 0-based, children are 2*vacant+1 and 2*vacant+2.)
    while 2*vacant + 1 <= HeapEnd do begin
        // Choose the vacancy's smaller child.
        smaller := 2*vacant + 1;
        if 2*vacant + 2 <= HeapEnd then
            if Resources[FileNum][Indices[2*vacant + 2]].ResRef <=
               Resources[FileNum][Indices[2*vacant + 1]].ResRef then
                // Little sibling demands attention.
                smaller := 2*vacant + 2;

        // See if the new element stands firm against the smaller child.
        if Resources[FileNum][KeyIndex].ResRef <=
           Resources[FileNum][Indices[smaller]].ResRef then
            // I usually don't like "break"s, but efficiency is somewhat important here.
            break;

        // Advance the smaller child then slide down the min-heap.
        Indices[vacant] := Indices[smaller];
        vacant := smaller;
    end;//while

    // The current vacancy is KeyIndex's new home.
    Indices[vacant] := KeyIndex;
end;


// Populates OutList with the resources (stored in ourself) that contain
// MatchLine in the fields indicated by SearchCode.
// ProgressBar is used to display the progress of the search.
procedure TResourceList.Search(const MatchLine:shortstring; SearchCode: integer;
                               var OutList: TListBox; var OutListData: TGFFLocators;
                               var ProgressBar: TProgressBar; const ModTalkName: ansistring;
                               first_file_only: boolean);
var
    TLK: TFileStream;
    CustTLK: TFileStream;
    BIF: TFileStream;   // Sometimes will be an ERF.
    GFF: TMemoryStream;

    LanguageID:     DWORD = 0;
    ResourceCount:  DWORD;
    ResTableOffset: DWORD;
    ResTableWidth:  DWORD;
    ResourceOffset: DWORD;
    ResourceLength: DWORD;

    NumFiles:   integer;
    file_num:   integer;
    res_num:    integer;
    seek_to:    integer;
    search_num: integer;

    MatchLC:     shortstring;
    FoundResRef: array of TString16Ary;
    FoundData:   array of TGFFLocators;
begin
    // Some initializations.
    if not first_file_only then
        NumFiles := Length(FileNames)
    else if Length(FileNames) > 0 then
        NumFiles := 1
    else
        NumFiles := 0;
    SetLength(FoundResRef, NumFiles);
    SetLength(FoundData, NumFiles);
    // Possibly unnecessary, but explicit initializations might be more portable.
    for file_num := 0 to NumFiles - 1 do begin
        SetLength(FoundResRef[file_num], 0);
        SetLength(FoundData[file_num], 0);
    end;

    // Clear a place to put the results.
    OutList.Clear();

    // Initialize the progress meter.
    ProgressBar.Position := 0;
    ProgressBar.Max := GetResourceCount();

    // Make this search case-insensitive.
    MatchLC := lowercase(MatchLine);

    // Open the .tlk files once for the entire search.
    if not fileexists(main.nwnloc+'dialog.tlk') then
        TLK := nil
    else begin
        TLK := TFileStream.Create(main.nwnloc+'dialog.tlk', fmOpenRead or fmShareDenyWrite);
        // Also grab the language ID.
        TLK.Seek(8, soFromBeginning);
        TLK.Read(LanguageID, sizeof(LanguageID));
    end;
    // Custom talk file, if any:
    if ModTalkName = '' then
        CustTLK := nil
    else if not fileexists(ModTalkName) then
        CustTLK := nil
    else
        CustTLK := TFileStream.Create(ModTalkName, fmOpenRead or fmShareDenyWrite);

    // Loop through the relevant files.
    for file_num := 0 to NumFiles-1 do
        if fileexists(FileNames[file_num]) then begin
            // Open the next file and read the header data.
            BIF := TFileStream.Create(FileNames[file_num], fmOpenRead or fmShareDenyWrite);
            ReadFileHeader(BIF, FileTypes[file_num], ResourceCount, ResTableOffset, ResTableWidth);

            // Validate the resource table.
            // (Technically, this is overly strict for .bifs, as for them,
            //  ResTableOffset is 4 bytes past the beginning of the table,
            //  but the resource table is not supposed to be the last thing
            //  in the file, so do not worry about it.)
            if ResTableOffset + ResourceCount*ResTableWidth <= BIF.Size then
                // Loop through the relevant resources in this .bif.
                for res_num := 0 to High(Resources[file_num]) do
                    // Safety check
                    if Resources[file_num][res_num].index < ResourceCount then begin
                        // Read this resource's offset and length info.
                        seek_to := ResTableOffset +
                                   Resources[file_num][res_num].index*ResTableWidth;
                        BIF.Seek(seek_to, soFromBeginning);
                        BIF.Read(ResourceOffset, SizeOf(ResourceOffset));
                        BIF.Read(ResourceLength, SizeOf(ResourceLength));

                        // Safety check
                        if ResourceOffset + ResourceLength <= BIF.Size then begin
                            // Extract the GFF
                            BIF.Seek(ResourceOffset, soFromBeginning);
                            GFF := TMemoryStream.Create();
                            GFF.CopyFrom(BIF, ResourceLength);

                            // Test for a match.
                            if IsMatch(GFF, MatchLC, SearchCode, TLK, CustTLK, LanguageID) then begin
                                // Store this in memory for now.
                                search_num := Length(FoundResRef[file_num]);
                                SetLength(FoundResRef[file_num], search_num+1);
                                SetLength(FoundData[file_num], search_num+1);
                                // And the assignments...
                                FoundResRef[file_num][search_num] := Resources[file_num][res_num].ResRef;
                                FoundData[file_num][search_num].FileName := FileNames[file_num];
                                FoundData[file_num][search_num].Offset := ResourceOffset;
                                FoundData[file_num][search_num].Length := ResourceLength;
                            end;

                            // Cleanup.
                            GFF.Free();
                        end;

                        // Update the progress meter.
                        ProgressBar.Position := ProgressBar.Position + 1;
                    end;//if valid index & for res_num

            // Cleanup.
            BIF.Free();
        end;//if fileexists & for file_num

    // Record the results (sorted merge of each file's results).
    RecordSearch(OutList, OutListData, FoundResRef, FoundData);

    // We are done messing with the list.
    if OutList.Items.Count > 0 then
        OutList.ItemIndex := 0;
    OutList.Click();
    beep;

    // Cleanup.
    ProgressBar.Position := 0;
    if TLK <> nil then
        TLK.Free();
    if CustTLK <> nil then
        CustTLK.Free();
end;


// Records the search results in the list and data.
// Pulled out of Search() because that procedure is already long enough.
procedure TResourceList.RecordSearch(var OutList:TListBox; var OutListData:TGFFLocators;
                                     const FoundResRef: array of TString16Ary;
                                     const FoundData: array of TGFFLocators);
var
    NumFiles: integer;
    file_num: integer;
    smallest: integer;
    data_num: integer = 0;          // Index of the next element of OutListData to receive data.
    TotalLength: integer;           // Just used so the length of OutListData is set only once.
    SubLengths:  array of integer;  // Length of each list.
    CurIndex:  array of integer;    // Index of the next element to add for each list.
    ListsLeft: integer;             // Number of lists with data left to add.
begin;
    // Initialize
    NumFiles  := Length(FoundResRef);
    ListsLeft := NumFiles;
    SetLength(SubLengths, NumFiles);
    SetLength(CurIndex, NumFiles);
    for file_num := 0 to NumFiles-1 do begin
        SubLengths[file_num] := Length(FoundResRef[file_num]);
        CurIndex[file_num] := 0;
        // Adjust for 0-length arrays.
        if SubLengths[file_num] = 0 then
            ListsLeft -= 1;
    end;

    // Allocate space for the results data.
    TotalLength := 0;
    for file_num := 0 to NumFiles-1 do
        TotalLength += SubLengths[file_num];
    SetLength(OutListData, TotalLength);

    // While there is merging left to do.
    while ListsLeft > 1 do begin
        // Find a list with a remaining element.
        file_num := 0;
        while (file_num < NumFiles-1) and (CurIndex[file_num] >= SubLengths[file_num]) do
            file_num += 1;
        // Should not happen, but just in case...
        if CurIndex[file_num] >= SubLengths[file_num] then
            ListsLeft := 0

        else begin
            // See which list has the smallest remaining element.
            smallest := file_num;
            file_num += 1;
            while file_num < NumFiles do begin
                if CurIndex[file_num] < SubLengths[file_num] then
                    if FoundResRef[file_num][CurIndex[file_num]] <
                       FoundResRef[smallest][CurIndex[smallest]] then
                        // New smallest element.
                        smallest := file_num;
                // Update the loop.
                file_num += 1;
            end;

            // Add this smallest element.
            OutList.Items.Append(FoundResRef[smallest][CurIndex[smallest]]);
            OutListData[data_num] := FoundData[smallest][CurIndex[smallest]];
            // Update our counts.
            CurIndex[smallest] += 1;
            data_num += 1;
            if CurIndex[smallest] = SubLengths[smallest] then
                ListsLeft -= 1;
        end;
    end;

    // No more merging, so whatever list is left just gets added.
    for file_num := 0 to NumFiles-1 do
        while CurIndex[file_num] < SubLengths[file_num] do begin
            // Record this data.
            OutList.Items.Append(FoundResRef[file_num][CurIndex[file_num]]);
            OutListData[data_num] := FoundData[file_num][CurIndex[file_num]];
            // Update our counts.
            CurIndex[file_num] += 1;
            data_num += 1;
        end;
end;


// Returns the number of resources in all .bifs.
function TResourceList.GetResourceCount(): integer;
var
    bif_num: integer;
begin
    // Add up the lengths of the resource arrays.
    result := 0;
    for bif_num := 0 to High(Resources) do
        result += Length(Resources[bif_num]);
end;


// Parses GFF to see if matchline is contained in it.
// Uses TLK/CustTLK to resolve StringRefs.
function TResourceList.IsMatch(GFF:TStream; const MatchLine:shortstring; SearchCode: integer;
                               TLK, CustTLK: TStream; LanguageID: DWORD): boolean;
var
    // GFF header info.
    FileType, FileVersion: array [0..3] of char;
    FieldOffset, FieldCount,
    LabelOffset, LabelCount,
    FieldDataOffset, FieldDataCount: DWORD;

    // GFF field and string info.
    FieldType, FieldLabel, FieldData: DWORD;
    StringLength: DWORD;

    // Misc.
    field_num:   integer;
    ThisLabel:   array[0..15] of char;
    ReturnHere:  int64;
    CompareLine: ansistring;
begin
    // Initialize.
    result := false;

    // ----------
    // Read the GFF header info.
    GFF.Seek(0, soFromBeginning);
    GFF.Read(FileType, SizeOf(FileType));
    GFF.Read(FileVersion, SizeOf(FileVersion));
    GFF.Seek(8, soFromCurrent);     // Skipping structure offset and count.
    GFF.Read(FieldOffset, SizeOf(FieldOffset));
    GFF.Read(FieldCount, SizeOf(FieldCount));
    GFF.Read(LabelOffset, SizeOf(LabelOffset));
    GFF.Read(LabelCount, SizeOf(LabelCount));
    GFF.Read(FieldDataOffset, SizeOf(FieldDataOffset));
    GFF.Read(FieldDataCount, SizeOf(FieldDataCount));

    // Safety checks.
    if (copy(FileType, 1, 2) <> 'UT') or (FileVersion <> 'V3.2') or
       (GFF.Size < LabelOffset + LabelCount*SizeOf(ThisLabel))   or
       (GFF.Size < FieldOffset + FieldCount*3*SizeOf(DWORD))     or
       (GFF.Size < FieldDataOffset + FieldDataCount) then
        // We are missing key data; cannot continue.
        exit;


    // ----------
    // Loop through the GFF fields.
    GFF.Seek(FieldOffset, soFromBeginning);
    for field_num := 0 to FieldCount-1 do begin
        // Read the field.
        GFF.Read(FieldType, SizeOf(FieldType));
        GFF.Read(FieldLabel, SizeOf(FieldLabel));
        GFF.Read(FieldData, SizeOf(FieldData));

        // We only care about CExoStrings and CExoLocStrings (types 10 and 12)
        // (and also make sure the offset data is not obviously corrupt).
        if ((FieldType = 10) or (FieldType = 12)) and
           (FieldData + SizeOf(DWORD) < FieldDataCount) then
        begin
            // Record our location so we can restore it.
            ReturnHere := GFF.Position;

            // See if the label interests us.
            GFF.Seek(LabelOffset + FieldLabel*16, soFromBeginning);
            GFF.Read(ThisLabel, SizeOf(ThisLabel));
            if LabelMatchesCriteria(ThisLabel, SearchCode) then
            begin
                // Locate the string.
                GFF.Seek(FieldDataOffset + FieldData, soFromBeginning);
                // Peek at its length in the GFF.
                GFF.Read(StringLength, sizeof(StringLength));
                GFF.Seek(-sizeof(StringLength), soFromCurrent);
                // Validate the length.
                if FieldData + sizeof(WORD) + StringLength < FieldDataCount then
                    // Get the string.
                    case FieldType of
                        10: CompareLine := lowercase(ReadGFFString(GFF));
                        12: CompareLine := lowercase(ReadGFFLocString(GFF, TLK, CustTLK, LanguageID));
                    end
                else
                    // Erase any old value that is present.
                    CompareLine := '';

                // Look for a match.
                if pos(MatchLine, CompareLine) > 0 then
                begin
                    // Match found, search no longer!
                    result := true;
                    exit;
                end;
            end;//if LabelMatches

            // Restore the stream's previous position.
            GFF.Seek(ReturnHere, soFromBeginning);
        end;//if FieldType
    end;//for field_num
end;


// Returns TRUE if ThisLabel is a label of a field that should be included in
// searches based on SearchCode (selection of the radio button that allows
// choosing "name", "tag", "description", "comment", or "all").
function TResourceList.LabelMatchesCriteria(const ThisLabel: array of char; SearchCode: integer): boolean;
begin
    if (ThisLabel = 'LocName')   or (ThisLabel = 'LocalizedName') or
       (ThisLabel = 'FirstName') or (ThisLabel = 'LastName') then
        // Search these if searching for names or everything.
        result := (SearchCode = SEARCH_NAME) or (SearchCode = SEARCH_ALL)

    else if ThisLabel = 'Tag' then
        // Search this if searching for tags or everything.
        result := (SearchCode = SEARCH_TAG) or (SearchCode = SEARCH_ALL)

    else if (ThisLabel = 'DescIdentified') or (ThisLabel = 'Description') then
        // Search this if searching for descriptions or everything.
        result := (SearchCode = SEARCH_DESC) or (SearchCode = SEARCH_ALL)

    else if ThisLabel = 'Comment' then
        // Search this if searching for comments or everything.
        result := (SearchCode = SEARCH_COMMENT) or (SearchCode = SEARCH_ALL)

    else
        // Not interested in anything else.
        result := false;
end;


// Reads the header info of the given stream, assuming it is of the indicated type,
// and returns some header info in the DWORD parameters.
procedure TResourceList.ReadFileHeader(NWN: TStream; FileType: TEResourceFile;
                                       out ResourceCount:  DWORD;
                                       out ResTableOffset: DWORD;
                                       out ResTableWidth:  DWORD);
begin
    // How to proceed depends on the file type.
    case FileType of
        BifFileType: begin
            // Read a BIF header.
            NWN.Seek(8, soFromBeginning);   // Skip "BIFFV1  "
            NWN.Read(ResourceCount, SizeOf(ResourceCount));
            NWN.Seek(4, soFromCurrent);     // Skip fixed resource count.
            NWN.Read(ResTableOffset, SizeOf(ResTableOffset));
            // Each resource table entry consists of four DWORDS:
            // ID, Offset, Length, and Type.
            ResTableWidth := 16;
            // Align the table offset with where the resource offsets are found.
            ResTableOffset += 4;
        end;

        ErfFileType: begin
            // Read an ERF header.
            NWN.Seek(16, soFromBeginning);  // Skip "MOD V1.0", language count, and localized string size.
            NWN.Read(ResourceCount, SizeOf(ResourceCount));
            NWN.Seek(8, soFromCurrent);     // Skip offsets to localized string and key list.
            NWN.Read(ResTableOffset, SizeOf(ResTableOffset));
            // Each resource table entry consists of two DWORDS:
            // Offset, and Length.
            ResTableWidth := 8;
        end;
    end;
end;


end.

