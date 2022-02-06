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
* Reorganized and rewrote much of this unit.
* Several parts of this unit were shifted to other units. This unit is now focused
*   on the overall structure of the script (and generating some common strings),
*   while the logic for each task is handled by the unit generating that task.
* Several parts of the start unit (formerly global variables) were shifted here.
* Cleanup of the generated scripts.
}
{
A few how-to's:

NWScript variables:
If you want to use a new variable (that needs to be declared if it is used), just
    add it to TVarEnum and var_list, and list its type in var_type.
You might also want to define a symbolic constant for the string in the constants unit.
If you need a new variable type, just add it to TVarTypes and decl_prefix.
The automatically declaration of the variable -- when it is assigned a value in
    a line submitted to AddLines() -- should now accommodate it.
NOTE: The variable type serves a second purpose of identifying which variables'
      assignment lines can be suppressed (when they match the previous assignment).

NWScript #includes:
If you want to use a new include file in a script, just add it to TIncEnum and
    inc_list.
The Include() function should now accommodate it.

NWScript helper functions:
If you need a new helper function, add it to TFuncEnum and func_list. Blank
    lines will be omitted, and there is a preset limit on how many lines can
    be used. The lilmit can be raised, but that means adding padding to all
    existing entries of func_list.
}

{This is a major 'include' file which
handles all the scripting for normal scripts
and can be called from everywhere. If
nothing else, it adds to clarity, IMHO (-- Lilac Soul)}
{
Now handles mostly "global" formatting for (all) scripts,
along with generating some function calls (in cases where
the function is generated from multiple units or when there
are optional parameters that might get suppressed),
while the script production has been largely shifted
to the various modules. I think this adds more clarity, as
the parameters to the procedure calls LS used were not all
that obvious as to their purpose. -- The Krit

I started adding the function-generating functions somewhat
late during my revisions. That is why their use is somewhat
inconsistent. The idea is to have a SCRIPT function for each
NWScript command, with parameters of the Pascal function
corresponding to parameters to the NWScript command. --The Krit
}

{
Note: None of the Tlilac and Script methods take or use ansistrings. (This
      should reduce overhead, as we rarely would benefit from ansistring
      features.) Usually not an issue, but make sure strings fed to these
      methods are less than 256 characters long.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}


unit nwn;


interface

uses
  {Windows,} {Messages,} SysUtils, Classes, {Graphics, Controls, Forms, Dialogs,}
  {ExtCtrls, StdCtrls, Menus, Spin, CheckLst,}
  constants;


// -----------------------------------------------------------------------------
// Some types/parameters for public methods.
type
    // For DefineFunc():
    // The helper functions that may be required.
    // Keep in sync with func_list defined in Tlilac.DefineFunc().
    TFuncEnum = (FUNC_CLEAR_JUMP_LOCATION,
                 FUNC_CLEAR_JUMP_OBJECT,
                 FUNC_OBJ_VOID,
                 FUNC_INT_VOID,
                 FUNC_TAKE_ALL_ITEM,
                 FUNC_TAKE_GOLD_PARTY,
                 FUNC_TAKE_XP,
                 FUNC_TAKE_XP_PARTY);
    TFuncList = array[TFuncEnum] of boolean;

    // For Include():
    // The include files that may be requested.
    // Keep in sync with inc_list defined in Tlilac.Include().
    TIncEnum = (INC_GENERIC,
                INC_HORSE,
                INC_ITEMPROP,
                INC_LUSKAN,
                INC_PARTYWIDE,
                INC_PLOT,
                INC_SPELLS, // The "nw_" version.
                // Non-BioWare include:
                INC_LS_PARTY);
    TIncList = array[TIncEnum] of boolean;

    // For Declare():
    // The variables that may be declared.
    // Keep in sync with var_list defined in the implementation section.
    TVarEnum = (VAR_bCURSTATE,
                VAR_eDAMAGE,
                VAR_eEFFECT,
                VAR_eVFX,
                VAR_fVALUE,
                VAR_ipADD,
                VAR_lTARGET,
                VAR_nCOUNT,
                VAR_nHENCH,
                VAR_nTYPE,
                VAR_nVALUE,
                VAR_oACTOR,
                VAR_oAREA,
                VAR_oDELAYER,
                VAR_oHENCH,
                VAR_oITEM,
                VAR_oMASTER,
                VAR_oPARTY,
                VAR_oSELF,
                VAR_oSPAWN,
                VAR_oTARGET,
                VAR_oTRAP,
                VAR_sVALUE );
    TVarList = array[TVarEnum] of boolean;

    // Types for tracking what was selected for something.
    ClassCheck = array[TClassEnum] of boolean;
    RacialCheck = array[TRaceEnum] of boolean;

    // Miscellaneous, useful at times.
    TStringAry = array of shortstring;
    TPCharAry12 = array[0..11] of pchar;


// -----------------------------------------------------------------------------
type

  // This class is intended to manage all changes to the script window.
  // All write operations will be routed through here so they can be centrally managed.
  // Note: all fields are to be (re)set in ClearScript().
  Tlilac = class
    private
        // Bookkeeping variables.
        // (LS had most of these as globals in the _start_ module.)
        declare_flags: TVarList; static;
        define_flags: TFuncList; static;
        include_flags: TIncList; static;
        declare_lines: array[TVarEnum] of shortstring; static;
        declare_level: array[TVarEnum] of byte; static;

        delayed_something: boolean; static;
        indent:        shortstring; static; // Current indent for the script window.
        dirty_flag:        boolean; static;

    public
        // Not used by Tlilac, but defined here so multiple units can share the
        // information.
        last_actor:  shortstring; static;
        last_spawn:  shortstring; static;
        last_spawn_type:    word; static; // An OBJECT_TYPE_* code, as defined in start.

    private
        // Internal utilities.
        class function  FindTwoBlanks(nStart:integer=0) : integer;
        class function  FindMainStart() : integer;
        class function  GetInsertionPoint(backtrack:integer=0) : integer;
        class function  HandleDeclares(const to_insert:shortstring; var to_declare:TVarList) : shortstring;
        class function  HandleDelays(const to_insert:shortstring; var delay_param:integer;
                                    var to_declare:TVarList) : shortstring;
        class procedure InitTagBasedOldVars(script_type: integer);
        class function  IsVarDef(const sScript:shortstring; out which_var:TVarEnum) : boolean;
        class procedure ReduceIndent();

    public
        // How the rest of the program will access this module.
        class procedure AddDirections(const new_line:shortstring; const extra_line:shortstring='');
        class procedure AddLines(const new_lines:array of shortstring; delay_first:integer=-1;
                                 delay_last:integer=-1; delay_more:boolean=false; backtrack:integer=0); overload;
        class procedure AddLines(const new_lines:array of pchar); overload;
        class procedure AddLinesBT(const new_lines:array of shortstring; backtrack:integer); inline;
        class procedure AddLinesDone();
        class procedure ClearScript();
        class procedure Declare(var_num: TVarEnum);
        class procedure DefineFunc(func_num: TFuncEnum);
        class procedure EndBlock();
        class procedure Include(inc_num: TIncEnum);
        class procedure InitScript(const script_type:integer; bUseOld: boolean=FALSE);
        class function  IsDeclared(var_num: TVarEnum): boolean; inline;

        class function  MergeTemplate(script_type: integer) : TStringList;

        // Special types of lines to add:
        class function  AddClassString(const first_line:shortstring; const prefix:shortstring;
                                       const classes:ClassCheck; const compare:shortstring;
                                       const joiner:shortstring; const suffix:shortstring;
                                       const last_line: shortstring; end_block:boolean=FALSE) : boolean;
        class function  AddRaceString(const first_line:shortstring; const prefix:shortstring;
                                      const who:shortstring;        const compare:shortstring;
                                      const races:RacialCheck;      const joiner:shortstring;
                                      const suffix:shortstring;     const last_line: shortstring;
                                      end_block:boolean=FALSE) : boolean;

        // Some handy utilities for other units.
        class function  IsComplete(): boolean;
        class function  IsDirty():    boolean; inline;
        class procedure MarkClean();           inline;
        class function  MustReturnVoid(): boolean; inline;
        class function  WillBeAssigned(): boolean; inline;
  end;


// -----------------------------------------------------------------------------

  // This class is intended to produce all NWScript function calls.
  // (Not there yet, but that is the idea.)
  // This will take the checking for optional parameters out of the other units,
  // as well as centralizing the location of a number of string resources.
  Script = class
    public
        class function  AddJournalQuestEntry(const sPlotID, sState, sCreature:shortstring;
                                             bAllParty, bAllPlayers, bAllowHigher: boolean) : shortstring;
        class function  ApplyEffect(const sEffect, sSubject:shortstring;
                                    isLocation:boolean;  nDuration: integer=0) : shortstring;
        class function  AssignCommand(const sActor: shortstring; const sAction:shortstring) : shortstring; overload;
        class function  AssignCommand(const eActor: TObjectEnum; const sAction:shortstring;
                                      const sAlt:shortstring='') : shortstring; overload;
        class function  AssignCommandML(const sActor, sAction:shortstring; out sIndent, sEnd: shortstring) : shortstring;
        class function  CreateTrap(const sType, sWhere: shortstring;
                                   const sDisarm: shortstring=''; const sTriggered: shortstring='';
                                   bAtLocation: boolean=FALSE; const sSize: shortstring='') : shortstring;
        class function  GetNearest(const sTag:shortstring; const sToWhom:shortstring=''; iNth:integer=1) : shortstring;
        class function  GetItemInSlot(const sSlot: shortstring;  const sWhose: shortstring='') : shortstring; overload;
        class function  GetItemInSlot(const nSlot: integer;      const sWhose: shortstring='') : shortstring; overload; inline;
        class function  GetItemPossessedBy(   const sWho, sItemTag: shortstring) : shortstring;
        class function  GetItemPossessedByVar(const sWho, sItemTag: shortstring) : shortstring;
        class function  JournalRead(const sWho, sQuestTag:shortstring) : shortstring;
        class function  PlayVoicechat(const sChat: shortstring; Who: TObjectEnum;
                                      const sAlt:shortstring='') : shortstring;
        class function  SpeakString(const sWhat: shortstring; nVolume:integer; bAsAction: boolean=FALSE) : shortstring;
        class function  StartConvo(const sWithWhom:shortstring; const sDialog:shortstring='';
                                   bPrivate:boolean=FALSE; bPlayHello:boolean=TRUE) : shortstring;
  end;


{var
   lilac: Tlilac;
}

// -----------------------------------------------------------------------------

implementation

uses {journaladd, openlock, localvar, teleport_pc,} chooseif, ifinspector,
     {other_restrict, companions, spawn_creature, lights_onoff,} start,
     delay, if_warning;


type
    // Keep in sync with decl_prefix, defined in Declare().
    // The _KEEP suffix indicates a variable whose assignments must never
    // be suppressed (for being the same as the previous one). This is not
    // automatic; HandleDeclares() needs to be updated for new "_KEEP" types.
    TVarTypes = ( VARTYPE_EFFECT, VARTYPE_ITEMPROP, VARTYPE_OBJECT,
                  VARTYPE_FLOAT_KEEP, VARTYPE_INT_KEEP, VARTYPE_LOC_KEEP,
                  VARTYPE_OBJECT_KEEP, VARTYPE_STRING_KEEP );

const
    // A special return value indicating that a line should be skipped.
    sSkipThis = '****';

    // The names of the variables to potentially declare.
    // Keep in sync with the definition of TVarEnum (and with var_type, which
    // follows this).
    var_list: array[TVarEnum] of pChar =
               ( s_bCurState,
                 s_eDamage,
                 s_eEffect,
                 s_eVFX,
                 s_fValue,
                 s_ipAdd,
                 s_lTarget,
                 s_nCount,
                 s_nHench,
                 s_nType,
                 s_nValue,
                 s_oActor,
                 s_oArea,
                 s_oDelay,
                 s_oHench,
                 s_oItem,
                 s_oMaster,
                 s_oParty,
                 s_oSelf +' = '+ s_OBJECT_SELF,
                 s_oSpawn,
                 s_oTarget,
                 s_oTrap,
                 s_sValue );
    // The types of the just-listed variables.
    var_type: array[TVarEnum] of TVarTypes =
              ( VARTYPE_INT_KEEP,   // bCurState
                VARTYPE_EFFECT,     // eDamage
                VARTYPE_EFFECT,     // eEffect
                VARTYPE_EFFECT,     // eVFX
                VARTYPE_FLOAT_KEEP, // fValue
                VARTYPE_ITEMPROP,   // ipAdd
                VARTYPE_LOC_KEEP,   // lTarget
                VARTYPE_INT_KEEP,   // nCount
                VARTYPE_INT_KEEP,   // nHench
                VARTYPE_INT_KEEP,   // nType
                VARTYPE_INT_KEEP,   // nValue
                VARTYPE_OBJECT,     // oActor
                VARTYPE_OBJECT,     // oArea
                VARTYPE_OBJECT,     // oDelay
                VARTYPE_OBJECT_KEEP,// oHench
                VARTYPE_OBJECT_KEEP,// oItem
                VARTYPE_OBJECT,     // oMaster
                VARTYPE_OBJECT_KEEP,// oParty
                VARTYPE_OBJECT,     // oSelf
                VARTYPE_OBJECT_KEEP,// oSpawn
                VARTYPE_OBJECT,     // oTarget
                VARTYPE_OBJECT_KEEP,// oTrap
                VARTYPE_STRING_KEEP // sValue
              );

    // -------------------------------------------------------------------------
    // Text for the scripts.
    introlines : array[1..8] of pChar =
              // This array must contain two entries of '' in a row to indicate
              // where additional instructions and #include's get inserted.
              ( '/* ',
                ' *  Script generated by LS Script Generator, v.'+ThisVersion,
                ' *',
                ' *  For download info, please visit:',
                ' *  http://nwvault.ign.com/View.php?view=Other.Detail&id='+VaultID,
                ' */',
                '',
                '' );
    skel_cond : array[1..8] of pChar =
              // This array must contain '' to indicate where stuff gets inserted.
              ( 'int StartingConditional()',
                '{',
                '    // Get the PC who is involved in this conversation',
                '    object oPC = GetPCSpeaker();',
                '',
                '    // If we make it this far, we have passed all tests.',
                '    return TRUE;',
                '}' );
    skel_norm : array[1..3] of pChar =
              ( 'void main()',
                '{',
                '}' );

    skel_template: array[383..545] of pChar = // The indices are the line numbers in this .pas file at the time I added this constant. (Makes it easy to pick out individual lines.)
             (  '// Tag-based script template.',
                '// This is intended to be a starting point for writing an item''s tag-based script.',
                '// Copy this to a script whose name is the tag of the item in question.',
                '// Edit the event handlers (scroll down to find them) as desired.',
                '',
                '',
                '#include "x2_inc_switches"',
                '',
                '',
                '// -----------------------------------------------------------------------------',
                '// This first part is standard and generic.',
                '// There should be no need to edit it; just skip down to the next part.',
                '// -----------------------------------------------------------------------------',
                '',
                '',
                '// The individual event handlers.',
                '',
                'void OnAcquire(object oEventItem, object oAcquiredBy, object oTakenFrom, int nStackSize);',
                'void OnActivate(object oEventItem, object oActTarget, location lActTarget, object oActivator);',
                'void OnEquip(object oEventItem, object oEquippedBy);',
                'void OnHit(object oEventItem, object oHitTarget, object oCaster);',
                'int  OnSpellCast(object oEventItem, int nSpell, object oCaster);',
                'void OnUnacquire(object oEventItem, object oLostBy);',
                'void OnUnequip(object oEventItem, object oUnequippedBy);',
                '',
                '',
                '// The main function.',
                'void main()',
                '{',
                '    int nEvent = GetUserDefinedItemEventNumber();',
                '',
                '    // Spells might continue to their spell scripts. All other events are',
                '    // completely handled by this script.',
                '    if ( nEvent != X2_ITEM_EVENT_SPELLCAST_AT )',
                '        SetExecutedScriptReturnValue();',
                '',
                '    // Determine which event triggered this script''s execution.',
                '    switch ( nEvent )',
                '    {',
                '        // Item was acquired.',
                '        case X2_ITEM_EVENT_ACQUIRE:',
                '                OnAcquire(GetModuleItemAcquired(), GetModuleItemAcquiredBy(),',
                '                          GetModuleItemAcquiredFrom(), GetModuleItemAcquiredStackSize());',
                '                break;',
                '',
                '        // Item was activated ("activate item" or "unique power").',
                '        case X2_ITEM_EVENT_ACTIVATE:',
                '                OnActivate(GetItemActivated(), GetItemActivatedTarget(),',
                '                           GetItemActivatedTargetLocation(), GetItemActivator());',
                '                break;',
                '',
                '        // Item was equipped by a PC.',
                '        case X2_ITEM_EVENT_EQUIP:',
                '                OnEquip(GetPCItemLastEquipped(), GetPCItemLastEquippedBy());',
                '                break;',
                '',
                '        // Item is a weapon that just hit a target, or it is the armor of someone',
                '        // who was just hit.',
                '        case X2_ITEM_EVENT_ONHITCAST:',
                '                OnHit(GetSpellCastItem(), GetSpellTargetObject(), OBJECT_SELF);',
                '                break;',
                '',
                '        // A PC (or certain NPCs) cast a spell at the item.',
                '        case X2_ITEM_EVENT_SPELLCAST_AT:',
                '                if ( OnSpellCast(GetSpellTargetObject(), GetSpellId(), OBJECT_SELF) )',
                '                    SetExecutedScriptReturnValue();',
                '                break;',
                '',
                '        // Item was unacquired.',
                '        case X2_ITEM_EVENT_UNACQUIRE:',
                '                OnUnacquire(GetModuleItemLost(), GetModuleItemLostBy());',
                '                break;',
                '',
                '        // Item was unequipped by a PC.',
                '        case X2_ITEM_EVENT_UNEQUIP:',
                '                OnUnequip(GetPCItemLastUnequipped(), GetPCItemLastUnequippedBy());',
                '                break;',
                '    }',
                '}',
                '',
                '',
                '// -----------------------------------------------------------------------------',
                '// Event handlers',
                '// -----------------------------------------------------------------------------',
                '// This second part is where you add your desired functionality. Each event',
                '// has its own function with relavant information passed as parameters.',
                '// -----------------------------------------------------------------------------',
                '',
                '',
                '// -----------------------------------------------------------------------------',
                '// oEventItem was acquired (by a PC or an NPC).',
                '// Run by the module.',
                'void OnAcquire(object oEventItem, object oAcquiredBy, object oTakenFrom, int nStackSize)',
                '{',
                '    // Default: do nothing.',
                '}',
                '',
                '',
                '// -----------------------------------------------------------------------------',
                '// oEventItem was activated ("activate item" or "unique power").',
                '// Run by the module.',
                'void OnActivate(object oEventItem, object oActTarget, location lActTarget, object oActivator)',
                '{',
                '    // Default: do nothing.',
                '}',
                '',
                '',
                '// -----------------------------------------------------------------------------',
                '// oEventItem was equipped by a PC.',
                '// Run by the module.',
                'void OnEquip(object oEventItem, object oEquippedBy)',
                '{',
                '    // Default: do nothing.',
                '}',
                '',
                '',
                '// -----------------------------------------------------------------------------',
                '// oEventItem is a weapon that just hit a target, or it is the armor of someone who',
                '// was just hit by someone else''s weapon.',
                '// Run by the caster.',
                'void OnHit(object oEventItem, object oHitTarget, object oCaster)',
                '{',
                '    // Default: do nothing.',
                '}',
                '',
                '',
                '// -----------------------------------------------------------------------------',
                '// Someone cast a spell at oEventItem.',
                '// This usually only fires if a PC cast the spell, but it also fires for',
                '// DM-possessed NPCs and NPCs in an area with the "X2_L_WILD_MAGIC" local integer set.',
                '//',
                '// Return TRUE to prevent the spell script from firing.',
                '// Return FALSE to proceed normally.',
                '//',
                '// This fires after the UMD check, module spellhook, item creation, and',
                '// sequencer handlers decide they do not want to handle/interrupt this spell.',
                '// This fires before the check to see if this is a spell that normally can',
                '// target items (and before the spell script itself runs).',
                '//',
                '// Run by the caster.',
                'int OnSpellCast(object oEventItem, int nSpell, object oCaster)',
                '{',
                '    // Default: just proceed normally.',
                '    return FALSE;',
                '}',
                '',
                '',
                '// -----------------------------------------------------------------------------',
                '// oEventItem was unacquired/lost (by a PC or NPC).',
                '// Run by the module.',
                'void OnUnacquire(object oEventItem, object oLostBy)',
                '{',
                '    // Default: do nothing.',
                '}',
                '',
                '',
                '// -----------------------------------------------------------------------------',
                '// oEventItem was unequipped by a PC.',
                '// Run by the module.',
                'void OnUnequip(object oEventItem, object oUnequippedBy)',
                '{',
                '    // Default: do nothing.',
                '}' );
    // Indices of special lines in the above template.
    // (This is why I used Pascal line numbers.)

    // Function definitions (start)
    TEMPLATE_LINE_ACQUIRE   = 475;
    TEMPLATE_LINE_ACTIVATE  = 484;
    TEMPLATE_LINE_EQUIP     = 493;
    TEMPLATE_LINE_UNACQUIRE = 533;
    TEMPLATE_LINE_UNEQUIP   = 542;
    // Function definitions (end)
    TEMPLATE_LINE_ACQUIRE_END   = 478;
    TEMPLATE_LINE_ACTIVATE_END  = 487;
    TEMPLATE_LINE_EQUIP_END     = 496;
    TEMPLATE_LINE_UNACQUIRE_END = 536;
    TEMPLATE_LINE_UNEQUIP_END   = 545;
    // The place to stick header info (#includes and helper functions)
    // (More accurately, this is the line to come right after such info.)
    TEMPLATE_LINE_HEADER = 472;


// -----------------------------------------------------------------------------
// Private methods
// -----------------------------------------------------------------------------


// This utility returns the line in the script window after the first occurrence
// of two blank lines starting at line _nStart_.
// When nStart is left at its default value, this is where #include lines should
// be inserted.
class function Tlilac.FindTwoBlanks(nStart:integer=0) : integer;
begin
    // This function is easier to read in the context of the script window.
    with main.scriptwindow do
        if lines.count > 2+nStart then begin
            // Loop through the lines, looking for two blanks.
            while (nStart < lines.count-2) and
                  ( (lines[nStart] <> '') or (lines[nStart+1] <> '') ) do
                nStart += 1;

            // At this point, either nStart is the first of the two blank lines
            // (so 2 less than the line after them) or nStart is 2 less than
            // the end of the script. Either way, we return nStart + 2.
            result := nStart + 2;
        end
        else
            result := lines.count;
end;


// This utility returns the line in the script window after the first line that
// is simply (and exactly) '{'. This should be the first line of the main function.
//
// (Any secondary functions added before the main function must have something
//  else on the line with their opening brace -- even just a trailing space.
class function Tlilac.FindMainStart() : integer;
var
    nStart: integer = 0;
begin
    // This function is easier to read in the context of the script window.
    with main.scriptwindow do
        if lines.count >= 1 then begin
            // Look for a line with just an opening brace.
            while (nStart < lines.count-1) and (lines[nStart] <> '{') do
                nStart += 1;

            // Regardless of how we exited the above loop, _nStart_ is 1 less
            // than where we want (end of script or after the opening brace).
            result := nStart + 1;
        end
        else
            result := 0;
end;


// This utility locates and returns where in the script text should be added.
// The second parameter allows backtracking from that point, but not past the
// opening brace of a function. Backtracks are counted per blank line, rather
// per code line.
class function Tlilac.GetInsertionPoint(backtrack:integer=0) : integer;
var
    insert_at : integer;
begin
    with main.scriptwindow do
    begin
        // Begin by assuming we insert at the closing brace (the last string).
        insert_at := lines.count - 1;

        // Safety check, in case the script window is empty.
        if insert_at <= 0 then
            result := 0
        else begin
            // Are we in a conditional script?
            if lines[insert_at-1] = skel_cond[High(skel_cond)-1] then
                // Increase the backtrack to skip the ending block.
                backtrack += 1;

            // Now we backtrack as requested. This will stop prematurely if we run
            // out of lines or encounter the beginning of a function.
            while (backtrack > 0) and (insert_at > 1) and
                  ('{' <> lines[insert_at-1]) do
            begin
                if '' = lines[insert_at] then
                    // We made it back another chunk of lines.
                    backtrack -= 1;
                if backtrack > 0 then
                    // Step back another line.
                    insert_at -= 1;
            end;

            // We have our result.
            result := insert_at;
        end;
    end;
end;


// Converts the indicated string to the current indentation level and flags which
// variables will need to be declared.
// Will return the special string sSkipThis if the provided line should be
// omitted from the script window (such as when oTarget is being re-defined,
// but to the same thing it had before).
class function Tlilac.HandleDeclares(const to_insert:shortstring; var to_declare:TVarList) : shortstring;
var
    sTrimmed: shortstring;
    var_num:     TVarEnum;
begin
    // Abort if there is nothing to work with.
    if Length(to_insert) = 0 then begin
        result := '';
        exit;
    end;

    // The return value unless we decide to skip this line:
    result := indent + to_insert;

    // Ignore leading blanks.
    sTrimmed := TrimLeft(to_insert);

    // Look for matches to the known variables.
    if IsVarDef(sTrimmed, var_num) then begin
        // This is where we decide if this sort of definition can be skipped.
        // A definition can only be skipped if it was already made, and if the
        // variable type allows skipping.
        if (declare_lines[var_num] = sTrimmed) and
           (var_type[var_num] <> VARTYPE_FLOAT_KEEP)  and
           (var_type[var_num] <> VARTYPE_INT_KEEP)    and
           (var_type[var_num] <> VARTYPE_LOC_KEEP)    and
           (var_type[var_num] <> VARTYPE_OBJECT_KEEP) and
           (var_type[var_num] <> VARTYPE_STRING_KEEP) then
            result := sSkipThis
        else begin
            to_declare[var_num] := true;
            declare_lines[var_num] := sTrimmed;
            declare_level[var_num] := Length(indent); // Good enough since we use shortstrings.
        end;
    end;
end;


// Converts the indicated string to handle the global delay and the current
// indentation level.
// delay_param should be initialized to 0 for each group of lines, then not
// touched outside this function.
//
// Assumes there is a delay to add.
// Assumes statements end with ';' not, e.g., '; '.
//
// (If I make this function sophisticated enough, maybe AddLines() will no longer
//  really need its delay_first and delay_last hints.)
class function Tlilac.HandleDelays(const to_insert:shortstring; var delay_param:integer;
                                   var to_declare:TVarList) : shortstring;
const
    s_ActionDo = 'ActionDoCommand(';
    s_Delay = 'DelayCommand(';
    // Values for delay_param:
    OLD_NONE          = 0; // Between statements.
    OLD_SIMPLE        = 1;
    OLD_DOUBLE_SIMPLE = 2; // Two layers of parentheses were added.
    OLD_COMPOUND      = 3; // Our delay gets compounded with an existing delay.
var
    line_indent: shortstring;
    sTrimmed:    shortstring;
    point_index: integer;
    full_delay:  integer;
    var_num:     TVarEnum;  // Just a placeholder.
begin
    // Abort if there is nothing to work with.
    if Length(to_insert) = 0 then begin
        result := '';
        exit;
    end;

    // We can stop here if there is nothing on this line.
    sTrimmed := TrimLeft(to_insert);
    if sTrimmed = '' then begin
        result := indent + to_insert;
        exit;
    end;

    // Non-statements and language primitives cannot be delayed.
    // (Incomplete checks for primitives; adding them as needed.)
    if (delay_param = OLD_NONE) and
       ( (sTrimmed[1] = ';')  or  (sTrimmed[1] = '{')  or  (sTrimmed[1] = '}')  or
         StartsWith(sTrimmed, '//')  or  StartsWith(sTrimmed, 'while')  or
         StartsWith(sTrimmed, 'if')  or  StartsWith(sTrimmed, 'else') ) then
    begin
        result := indent + to_insert;
        exit;
    end;

    // Variable assignments cannot be delayed.
    if (delay_param = OLD_NONE) and IsVarDef(sTrimmed, var_num) then begin
        result := HandleDeclares(to_insert, to_declare);
        exit;
    end;


    if (delay_param = OLD_NONE) then begin
        // We have a new statement to delay.
        // In this block, we will adjust the beginning of to_insert and set
        // delay_param to indicate what should be done to the end of the
        // statement (which may or may not be the end of this line).

        line_indent := Spaces(Length(to_insert) - Length(sTrimmed));

        // First case: not a timed delay.
        if Tdelaycommand.DelayTime() = 0 then begin
            if Tdelaycommand.DelayString() = s_OBJECT_SELF then begin
                // Insert "ActionDoCommand" before the provided script line.
                result := indent + line_indent + s_ActionDo + sTrimmed;
                delay_param := OLD_SIMPLE;
            end
            else begin
                // Insert "AssignCommand" and "ActionDoCommand" before the provided script line.
                result := indent + line_indent + s_AssignCommand +
                          Tdelaycommand.DelayString()+', '+s_ActionDo + sTrimmed;
                delay_param := OLD_DOUBLE_SIMPLE;
            end;
        end

        // Simple case: not a compound delay.
        else if not StartsWith(sTrimmed, s_Delay) then begin
            result := indent + line_indent + s_Delay + Tdelaycommand.DelayString()+
                      ', ' + sTrimmed;
            delay_param := OLD_SIMPLE;
        end

        // Hard case: compound delay, so merge the DelayCommand() commands;
        else begin
            // We will need to find the integer part of the delay within sTrimmed.
            point_index := Length(s_Delay); // Could add 1 here, but might it crash if sTrimmed = s_Delay?
            while (point_index < Length(sTrimmed)) and ('.' <> sTrimmed[point_index]) do
                Inc(point_index);

            // Sum the line's delay with the global delay.
            full_delay := strtoint(copy(sTrimmed, Length(s_Delay)+1, point_index-Length(s_Delay)-1))
                          + Tdelaycommand.DelayTime();

            result := indent + line_indent + s_Delay + inttostr(full_delay) +
                      copy(sTrimmed, point_index, Length(sTrimmed));
            delay_param := OLD_COMPOUND;
        end;
    end//if (OLD_NONE)
    else begin
        // We are continuing a previous statement.
        // Still need to handle the indentation.
        result := indent;

        // Plus extra space to line this up past the delaying commands.
        if Tdelaycommand.DelayTime = 0 then begin
            // Indent past "ActionDoCommand"
            result += Spaces(Length(s_ActionDo));
            // Possibly past the assignment command as well.
            if Tdelaycommand.DelayString() <> s_OBJECT_SELF then
                result += Spaces(Length(s_AssignCommand) +
                                 Length(Tdelaycommand.DelayString()) + 2);
        end
        else if delay_param <> OLD_COMPOUND then
            // Indent past "DelayCommand"
            result += Spaces(Length(s_Delay) + Length(Tdelaycommand.DelayString()) + 2);

        // And, of course, the line itself.
        result += to_insert;
    end;

    // Check to see if the statement ends on this line.
    if LastChar(result) = ';' then begin
        if delay_param = OLD_SIMPLE then
            // Trim off the terminal semicolon and end the delay statement we added.
            result := copy(result, 1, Length(result)-1) + ');'
        else if delay_param = OLD_DOUBLE_SIMPLE then
            // Trim off the terminal semicolon and end the delay statements we added.
            result := copy(result, 1, Length(result)-1) + '));';
        // else, nothing extra to do for OLD_COMPOUND (or OLD_NONE).

        // This statement is complete.
        delay_param := OLD_NONE;
    end;
end;


// Adds variable definitions to the script for the old system tag-based events.
// (Just the variables that the new system passes as parameters.)
// Assumes a script skeleton is already in place.
class procedure Tlilac.InitTagBasedOldVars(script_type: integer);
var
    new_lines: array[0..3] of shortstring;
begin
    case script_type of
        SCRIPTTYPE_TAG_ACTIVATE: begin
            // Variables assumed defined during item activation:
            new_lines[0] := 'object '+s_oEventItem+' = GetItemActivated();';
            new_lines[1] := 'object '+s_oActTarget+' = GetItemActivatedTarget();';
            new_lines[2] := 'location '+s_lActTarget+' = GetItemActivatedTargetLocation();';
            new_lines[3] := 'object '+s_oActivator+' = GetItemActivator();';
            AddLines(new_lines[0..3]);
        end;
        SCRIPTTYPE_TAG_ACQUIRE: begin
            // Variables assumed defined during item acquisition:
            new_lines[0] := 'object '+s_oEventItem+' = GetModuleItemAcquired();';
            new_lines[1] := 'object oAcquiredBy = GetModuleItemAcquiredBy();';
            AddLines(new_lines[0..1]);
        end;
        SCRIPTTYPE_TAG_UNACQUIRE: begin
            // Variables assumed defined during item unacquisition:
            new_lines[0] := 'object '+s_oEventItem+' = GetModuleItemLost();';
            new_lines[1] := 'object oLostBy = GetModuleItemLostBy();';
            AddLines(new_lines[0..1]);
        end;
        SCRIPTTYPE_TAG_EQUIP: begin
            // Variables assumed defined during item equipping:
            new_lines[0] := 'object '+s_oEventItem+' = GetPCItemLastEquipped();';
            new_lines[1] := 'object oEquippedBy = GetPCItemLastEquippedBy();';
            AddLines(new_lines[0..1]);
        end;
        SCRIPTTYPE_TAG_UNEQUIPPED: begin
            // Variables assumed defined during item unequipping:
            new_lines[0] := 'object '+s_oEventItem+' = GetPCItemLastUnequipped();';
            new_lines[1] := 'object oUnequippedBy = GetPCItemLastUnequippedBy();';
            AddLines(new_lines[0..1]);
        end;
    end;
end;


// Returns true if sScript begins with a known variable name (the defines a variable).
// If so, the variable is returned via var_num.
class function Tlilac.IsVarDef(const sScript:shortstring; out which_var:TVarEnum) : boolean;
var
    var_num: TVarEnum;
begin
    // Iterate through the variables.
    for var_num := Low(TVarEnum) to High(TVarEnum) do
        if StartsWith(sScript, var_list[var_num]+' ') then begin
            result := true;
            which_var := var_num;
            exit;
        end;

    // No match was found.
    result := false;
end;


// Handles the reduction of the indentation level.
// Is its own procedure because this also involves some bookkeeping updates.
class procedure Tlilac.ReduceIndent();
var
    var_count:    TVarEnum;
    indent_level: byte;
begin
    indent_level := Length(indent);

    // First, remove one indentation level, if possible.
    // (Should be possible, but only as long as scripts are well-formed.)
    if ( indent_level > 4 ) then
        indent_level -= 4
    else
        indent_level := 0;
    SetLength(indent, indent_level);


    // Variables defined at a higher indentation level than the new one were
    // presumably defined inside an optional code block. Since the definition
    // was optional, we cannot assume their values are anything.
    if declare_level[VAR_oACTOR] > indent_level then
        last_actor := '';
    if declare_level[VAR_oSPAWN] > indent_level then
        last_spawn_type := OBJECT_TYPE_NONE;
    // Now clear out the stored definition lines and reset the levels.
    for var_count := Low(TVarEnum) to High(TVarEnum) do
        if declare_level[var_count] > indent_level then begin
            // Clear this stored definition.
            declare_lines[var_count] := '';
            declare_level[var_count] := 0;
        end;
end;


// -----------------------------------------------------------------------------
// Public methods
// -----------------------------------------------------------------------------


// This utility is for adding additional comments to the header comment block.
// It allows adding up to two lines at a time because that is all I need.
// (Only one line will be added if the second string is left at the default ''.)
//
// The supplied strings should not contain "//"; this function will make sure
// the supplied text ends up in a comment.
class procedure Tlilac.AddDirections(const new_line:shortstring; const extra_line:shortstring='');
var
    insert_at : integer;
begin
    // Look for the place to add the new directions (the first blank line).
    insert_at := 0;
    while (insert_at < main.scriptwindow.lines.count-1) and
          ('' <> main.scriptwindow.lines[insert_at]) do
        insert_at += 1;
    // If something buggered up and there are lines but no blank lines, then
    // the insertion point will be right before the last line. Should not happen
    // and is not a crash, so we will not add code to handle that.

    // Add the new directions (extra_line first is inserted first, but will be
    // after new_line in the end result).
    if extra_line <> '' then
        main.scriptwindow.lines.insert(insert_at, '// ' + extra_line);
    main.scriptwindow.lines.insert(insert_at, '// ' + new_line);
end;


// This utility is for adding strings to the main body of the current script.
//
// _delay_first_ and _delay_last_ indicate the first and lastlines to which a
// delay can be added (if requested by TdelayCommand). Do not set either of
// these to be larger than High(new_lines). Variable definitions will not be
// delayed in any case.
// _delay_more_ can be set to true if a form will be submitting more lines
// later. It will be ignored if _delay_last_ is negative.
//
// The last parameter controls how many "blocks" of code back (from the
// normal insertion point to add the strings. For this, a "block" of code means
// what was added by one call to this function. Using backtracks after starting
// a compound statement is not supported.
//
// This procedure will take care of adding indents, blank lines, and global
// delays when necessary.
//
// (Lilac Soul's version was "Addline", which only accepted a single string,
//  did not allow for backtracking, and did not automate blank lines, indents,
//  and delays.)
class procedure Tlilac.AddLines(const new_lines:array of shortstring; delay_first:integer=-1;
                                delay_last:integer=-1; delay_more:boolean=false; backtrack:integer=0); overload;
var
    insert_at:  integer;
    index:      integer;
    len:        integer;
    to_insert:  shortstring;
    no_blank:   boolean = false; // Suppress the blank line before new_lines?
    to_declare: TVarList;
    var_num:    TVarEnum;

    // Not directly used in this procedure, but needs to persist for exactly
    // the life of this procedure call:
    delay_param: integer = 0;
begin
    // Initialize.
    insert_at := GetInsertionPoint(backtrack);
    for var_num := Low(TVarEnum) to High(TVarEnum) do
        to_declare[var_num] := false;

    // See if we should decrease the indent.
    if '}' = new_lines[0][1] then begin
        no_blank := true;
        ReduceIndent();
    end;

    with main.scriptwindow do
        try
            // Let the implementation optimize the addition of multiple lines.
            lines.BeginUpdate();

            // See if we should begin with a blank line.
            if not no_blank and (insert_at > 0) then begin
                len := Length(lines[insert_at-1]);
                if len > 0 then
                    if '{' <> lines[insert_at-1][len] then begin
                        // Start with a blank line.
                        lines.Insert(insert_at, '');
                        Inc(insert_at);
                    end;
            end;

            // ----------
            // Insert the lines.
            index := 0;

            // Process the initial non-delayed lines.
            while index < delay_first do begin
                to_insert := HandleDeclares(new_lines[index], to_declare);
                if to_insert <> sSkipThis then begin
                    lines.Insert(insert_at, to_insert);
                    Inc(insert_at);
                end;
                Inc(index);
            end;

            // Process the delayed commands.
            if Tdelaycommand.DelaySet() then
                while index <= delay_last do begin
                    to_insert := HandleDelays(new_lines[index], delay_param, to_declare);
                    if to_insert <> sSkipThis then begin
                        lines.Insert(insert_at, to_insert);
                        Inc(insert_at);
                    end;
                    Inc(index);
                end;

            // Process any remaining lines.
            while index <= High(new_lines) do begin
                to_insert := HandleDeclares(new_lines[index], to_declare);
                if to_insert <> sSkipThis then begin
                    lines.Insert(insert_at, to_insert);
                    Inc(insert_at);
                end;
                Inc(index);
            end;

            // Now make sure that all needed NWScript variables are declared.
            for var_num := Low(TVarEnum) to High(TVarEnum) do
                if to_declare[var_num] then
                    Declare(var_num);

        finally
            // End the insertion optimization (in a "finally" clause, as recommended).
            lines.EndUpdate();
        end;

    // See if we should increase the indent.
    if '{' = new_lines[High(new_lines)][1] then
        // Add an indentation level.
        indent := indent + '    ';

    // If there was a delay, it has been handled.
    if (delay_last >= 0) and Tdelaycommand.DelaySet() then begin
        if delay_more then
            delayed_something := true
        else begin
            delayed_something := false;
            Tdelaycommand.ResetDelay();
        end;
    end;

    // A change has been made.
    dirty_flag := true;
end;


// Alias for using pchars (constants) instead of shortstrings.
class procedure Tlilac.AddLines(const new_lines:array of pchar); overload;
var
    iLine: integer;
    converted: array of shortstring;
begin
    SetLength(converted, Length(new_lines));
    for iLine := 0 to High(new_lines) do
        converted[iLine] := shortstring(new_lines[iLine]);
    AddLines(converted);
end;


// Shorthand for supplying just the backtrack.
class procedure Tlilac.AddLinesBT(const new_lines:array of shortstring; backtrack:integer); inline;
begin
    AddLines(new_lines, -1, -1, false, backtrack);
end;


// A little follow-up to AddLines() that lets Tlilac know that a window is done
// adding lines (so delays can be ended if there was something sent earlier).
class procedure Tlilac.AddLinesDone();
begin
    // If we actually delayed something, end the delay.
    if delayed_something then begin
        Tdelaycommand.ResetDelay();
        delayed_something := false;
    end;
end;


// Clears the script window and all tracking data associated with it. This
// includes data of the "if" and "delay" features (because those are used by
// Tlilac to format the script). All other resetting needs to be done by the caller.
//
// This was in Tconfirmclear.Button1Click(), but I think it makes
// more sense to have it here. Well, has to be here since I converted
// some globals to private fields. --TK
class procedure Tlilac.ClearScript();
var
    func_count: TFuncEnum;
    inc_count: TIncEnum;
    var_count: TVarEnum;
begin
    // Clear the script text.
    main.scriptwindow.clear();

    // Reset our bookkeeping variables.
    dirty_flag := false;
    indent := '    '; // Because this is not used until after a function is started.
    for func_count := Low(TFuncEnum) to High(TFuncEnum) do
        define_flags[func_count] := false;
    for inc_count := Low(TIncEnum) to High(TIncEnum) do
        include_flags[inc_count] := false;
    for var_count := Low(TVarEnum) to High(TVarEnum) do begin
        declare_flags[var_count] := false;
        declare_lines[var_count] := '';
        declare_level[var_count] := 0;
    end;
    // ...and those variables used exclusively by other modules.
    last_actor := '';
    last_spawn := '';
    last_spawn_type := OBJECT_TYPE_NONE;

    // There are no "if" statements active.
    Tinspect.ResetIfs();
    Tifchoose.ResetIfs();

    // Reset the global delay.
    Tdelaycommand.ResetDelay();
    delayed_something := false;
end;


// Ensures that the indicated variable is declared.
class procedure Tlilac.Declare(var_num: TVarEnum);
const
    // How to define variable types in NWScript.
    decl_prefix: array[TVarTypes] of shortstring =
        ( '    effect ',
          '    itemproperty ',
          '    object ',
          '    float ',
          '    int ',
          '    location ',
          '    object ',
          '    string '
        );
var
    insert_at: integer;
    add_blank: boolean;
    enumType:  TVarTypes;
begin
    // Nothing to do if the variable is already declared.
    if declare_flags[var_num] then
        exit;

    // Find the place to insert the declaration.
    // (Specifically, the opening brace.)
    insert_at := FindMainStart();

    with main.scriptwindow do begin
        // See if we should add a blank line after this declaration
        // (meaning this is the first declaration.)
        if insert_at < lines.count then begin
            add_blank := true;
            for enumType := Low(TVarTypes) to High(TVarTypes) do
                add_blank := add_blank and
                             not StartsWith(lines[insert_at], decl_prefix[enumType]);
            // Add the line?
            if add_blank then
                lines.Insert(insert_at, '');
        end;

        // Add the variable declaration.
        lines.Insert(insert_at, decl_prefix[var_type[var_num]] + var_list[var_num]+';');
    end;

    // Remember that we declared this variable.
    declare_flags[var_num] := true;
end;


// Defines the indicated function in the script, if not done already.
class procedure Tlilac.DefineFunc(func_num: TFuncEnum);
const
    // The functions to include.
    // Keep in sync with the definition of TFuncEnum.
    // Remeber to not have any line be just '{'; you can have '{ ' though.
    func_list: array[TFuncEnum] of TPCharAry12 =
                  // FUNC_CLEAR_JUMP_LOCATION
                ( ( '// Clears all actions and jumps the caller to the provided location.',
                    '// (Useful when this needs to be delayed.)',
                    'void ClearAndJumpToLocation(location lDestination);',
                    'void ClearAndJumpToLocation(location lDestination)',
                    '{ ',
                    '    ClearAllActions();',
                    '    JumpToLocation(lDestination);',
                    '}',
                    '', '', '', ''
                  ),
                  // FUNC_CLEAR_JUMP_OBJECT
                  ( '// Clears all actions and jumps the caller to the provided object.',
                    '// (Useful when this needs to be delayed.)',
                    'void ClearAndJumpToObject(object oDestination);',
                    'void ClearAndJumpToObject(object oDestination)',
                    '{ ',
                    '    ClearAllActions();',
                    '    JumpToObject(oDestination);',
                    '}',
                    '', '', '', ''
                  ),
                  // FUNC_OBJ_VOID,
                  ( '// Converts objects to void. Useful for delaying functions that return an object.',
                    'void ObjectToVoid(object oObject);',
                    'void ObjectToVoid(object oObject)',
                    '{ }',
                    '', '', '', '', '', '', '', ''
                  ),
                  // FUNC_INT_VOID
                  ( '// Converts integers to void. Useful for delaying functions that return int.',
                    'void IntToVoid(int nInt);',
                    'void IntToVoid(int nInt)',
                    '{ }',
                    '', '', '', '', '', '', '', ''
                  ),
                  // FUNC_TAKE_ALL_ITEM
                  ( '// Removes all items (with the specified tag, if provided) from oCreature.',
                    'void RemoveAllItems(object oCreature, string sTag="");',
                    'void RemoveAllItems(object oCreature, string sTag="")',
                    '{ ',
                    '    object oItem = GetFirstItemInInventory(oCreature);',
                    '    while ( oItem != OBJECT_INVALID )',
                    '    {',
                    '        if ( "" == sTag  ||  GetTag(oItem) == sTag )',
                    '            DestroyObject(oItem);',
                    '        oItem = GetNextItemInInventory(oCreature);',
                    '    }',
                    '}'
                  ),
                  // FUNC_TAKE_GOLD_PARTY
                  ( '// Removes the specified gold from all PCs in oPC''s party.',
                    '// Specifying a negative amount means to take all gold.',
                    'void TakeGoldFromAll(int nGold, object oPC);',
                    'void TakeGoldFromAll(int nGold, object oPC)',
                    '{ ',
                    '    object oMember = GetFirstFactionMember(oPC, TRUE);',
                    '    while ( oMember != OBJECT_INVALID )',
                    '    {',
                    '        TakeGoldFromCreature(nGold < 0 ? GetGold(oMember) : nGold, oMember, TRUE);',
                    '        oMember = GetNextFactionMember(oPC, TRUE);',
                    '    }',
                    '}'
                  ),
                  // FUNC_TAKE_XP
                  ( '// Lowers oPC''s XP by nXP.',
                    'void RemoveXPFromCreature(object oPC, int nXP);',
                    'void RemoveXPFromCreature(object oPC, int nXP)',
                    '{ ',
                    '    // Convert the XP to lose into the XP to end up with.',
                    '    nXP = GetXP(oPC) > nXP ? GetXP(oPC) - nXP : 0;',
                    '    SetXP(oPC, nXP);',
                    '}',
                    '', '', '', ''
                  ),
                  // FUNC_TAKE_XP_PARTY
                  ( '// Lowers the XP of all PCs in oPC''s party by nXP.',
                    'void RemoveXPFromAll(object oPC, int nXP);',
                    'void RemoveXPFromAll(object oPC, int nXP)',
                    '{ ',
                    '    object oMember = GetFirstFactionMember(oPC, TRUE);',
                    '    while ( oMember != OBJECT_INVALID )',
                    '    {',
                    '        int nResultXP = GetXP(oMember) > nXP ? GetXP(oMember) - nXP : 0;',
                    '        SetXP(oMember, nResultXP);',
                    '        oMember = GetNextFactionMember(oPC, TRUE);',
                    '    }',
                    '}'
                  )
                );
var
    insert_at, func_line: integer;
begin
    // Nothing to do if the function is already defined.
    if define_flags[func_num] then
        exit;
    define_flags[func_num] := true;

    // Find the place to insert #includes.
    insert_at := FindTwoBlanks(0);

    with main.scriptwindow do begin
        // See if there is an #include here.
        if insert_at < lines.count then // Ignore the case where we ran out of lines.
            if Length(lines[insert_at]) > 0 then // Ignore the case where there is another blank line.
                if lines[insert_at][1] = '#' then
                    // There is an #include here. Skip to the next pair of blank lines.
                    insert_at := FindTwoBlanks(insert_at);

        // Add the specified function, followed by two blank lines.
        // (Lines are added in reverse order so the insertion point does not
        //  need to move.)
        lines.Insert(insert_at, '');
        lines.Insert(insert_at, '');
        for func_line := High(func_list[func_num]) downto Low(func_list[func_num]) do
            // Skip padding lines.
            if func_list[func_num][func_line] <> '' then
                lines.Insert(insert_at, func_list[func_num][func_line]);
    end;
end;


// Convenience shortcut for ending a block in the text window.
// Just calls AddLines with the single line '}'.
class procedure Tlilac.EndBlock();
const
    new_lines: array[0..0] of shortstring = ( '}' );
begin
    AddLines(new_lines);
end;


// Includes the indicated file in the script, if not done already.
class procedure Tlilac.Include(inc_num: TIncEnum);
const
    // The names of the scripts to include.
    // Keep in sync with the definition of TIncEnum.
    inc_list: array[TIncEnum] of pChar =
               ( 'nw_i0_generic',
                 'x3_inc_horse',
                 'x2_inc_itemprop',
                 'nw_i0_2q4luskan',
                 'x0_i0_partywide',
                 'nw_i0_plot',
                 'nw_i0_spells',
                 // Non-BioWare include
                 'ls_party'
               );
var
    insert_at: integer;
begin
    // Nothing to do if the file is already #included.
    if include_flags[inc_num] then
        exit;

    // Find the place to insert #includes.
    insert_at := FindTwoBlanks();

    with main.scriptwindow do begin
        // See if this is the first #include.
        if insert_at < lines.count then // Ignore the case where we ran out of lines.
            if Length(lines[insert_at]) > 0 then // Ignore the case where there is already another blank line.
                if lines[insert_at][1] <> '#' then begin
                    // This is the first include. Add some extra space.
                    lines.Insert(insert_at, '');
                    lines.Insert(insert_at, '');
                end;

        // Add the line to #include the requested script.
        lines.Insert(insert_at, '#include "' + inc_list[inc_num] + '"');
    end;

    // Remember that we included this file.
    include_flags[inc_num] := true;
end;


// Initializes the script to one of the available skeleton scripts.
// Assumes ClearScript() has already been called.
class procedure Tlilac.InitScript(const script_type:integer; bUseOld: boolean=FALSE);
var
    index: integer;
begin
    try
        // Let the implementation optimize the addition of multiple lines.
        main.scriptwindow.lines.BeginUpdate();

        // Tag-based handling:
        if script_type >=  SCRIPTTYPE_TAG_BASE then begin
            // New or old system?
            if bUseOld then begin
                // Add the standard intro lines.
                for index := 1 to High(introlines) do
                    main.scriptwindow.lines.Append(introlines[index]);
                // Add a skeleton main function.
                for index := 1 to High(skel_norm) do
                    main.scriptwindow.lines.Append(skel_norm[index]);
                // Define the major variables.
                InitTagBasedOldVars(script_type)
            end
            else begin
                // Find the function declaration line to use.
                case script_type of
                    SCRIPTTYPE_TAG_ACTIVATE   : index := TEMPLATE_LINE_ACTIVATE;
                    SCRIPTTYPE_TAG_ACQUIRE    : index := TEMPLATE_LINE_ACQUIRE;
                    SCRIPTTYPE_TAG_UNACQUIRE  : index := TEMPLATE_LINE_UNACQUIRE;
                    SCRIPTTYPE_TAG_EQUIP      : index := TEMPLATE_LINE_EQUIP;
                    SCRIPTTYPE_TAG_UNEQUIPPED : index := TEMPLATE_LINE_UNEQUIP;
                end;
                // Fill in a rough outline.
                // Start with two blank lines to support #include's.
                main.scriptwindow.lines.Append('');
                main.scriptwindow.lines.Append('');
                main.scriptwindow.lines.Append(skel_template[index]);
                main.scriptwindow.lines.Append('{');
                main.scriptwindow.lines.Append('}');
            end;
        end

        // Non-tag-based scripts:
        else case script_type of
            SCRIPTTYPE_CONDITIONAL: begin
                // Add the standard intro lines.
                for index := 1 to High(introlines) do
                    main.scriptwindow.lines.Append(introlines[index]);
                // Add a skeleton main function.
                for index := 1 to High(skel_cond) do
                    main.scriptwindow.lines.Append(skel_cond[index]);
            end;

            SCRIPTTYPE_NORMAL: begin
                // Add the standard intro lines.
                for index := 1 to High(introlines) do
                    main.scriptwindow.lines.Append(introlines[index]);
                // Add a skeleton main function.
                for index := 1 to High(skel_norm) do
                    main.scriptwindow.lines.Append(skel_norm[index]);
            end;

            //SCRIPTTYPE_BLACKSMITH: // Not handled here.
            //SCRIPTTYPE_ACTIVATE: // Not enough info yet.
            //SCRIPTTYPE_TAGBASED: // Not enough info yet.

            SCRIPTTYPE_TEMPLATE:
                // Add the tag-based template.
                for index := Low(skel_template) to High(skel_template) do
                    main.scriptwindow.lines.Append(skel_template[index]);
        end;
    finally
        // End the insertion optimization (in a "finally" clause, as recommended).
        main.scriptwindow.lines.EndUpdate();
    end;
end;


// Returns whether or not the indicated variable has been declared (and used, presumably).
class function  Tlilac.IsDeclared(var_num: TVarEnum): boolean; inline;
begin
    result := declare_flags[var_num];
end;


// Merges the script in the script window into the tag-based template, assuming
// the parameter indicates which tag-based event this is (SCRIPTTYPE_TAG_*).
// Returns the result as a newly allocated TSTringList.
class function  Tlilac.MergeTemplate(script_type: integer) : TStringList;
var
    iLine: integer;
    insert_at, insert_to, main_start: integer;
begin
    // Find the split between header and "main" function in the current script.
    main_start := FindMainStart(); // The line after the opening brace; two lines later than we want.
    if main_start > 2 then
        main_start -= 2
    else
        main_start := 0;

    // Figure out what to replace with the "main" function.
    case script_type of
        SCRIPTTYPE_TAG_ACTIVATE   : begin insert_at := TEMPLATE_LINE_ACTIVATE;  insert_to := TEMPLATE_LINE_ACTIVATE_END;  end;
        SCRIPTTYPE_TAG_ACQUIRE    : begin insert_at := TEMPLATE_LINE_ACQUIRE;   insert_to := TEMPLATE_LINE_ACQUIRE_END;   end;
        SCRIPTTYPE_TAG_UNACQUIRE  : begin insert_at := TEMPLATE_LINE_UNACQUIRE; insert_to := TEMPLATE_LINE_UNACQUIRE_END; end;
        SCRIPTTYPE_TAG_EQUIP      : begin insert_at := TEMPLATE_LINE_EQUIP;     insert_to := TEMPLATE_LINE_EQUIP_END;     end;
        SCRIPTTYPE_TAG_UNEQUIPPED : begin insert_at := TEMPLATE_LINE_UNEQUIP;   insert_to := TEMPLATE_LINE_UNEQUIP_END;   end;
    end;

    // Allocate space.
    result := TStringList.Create();

    // The beginning of the template.
    for iLine := Low(skel_template) to TEMPLATE_LINE_HEADER - 1 do
        result.Append(skel_template[iLine]);
    // The script's header (minus the two blank lines that always start it).
    for iLine := 2 to main_start - 1 do
        result.Append(main.scriptwindow.Lines[iLine]);
    // More template.
    for iLine := TEMPLATE_LINE_HEADER to insert_at - 1 do
        result.Append(skel_template[iLine]);
    // The "main" function.
    for iLine := main_start to main.scriptwindow.Lines.Count - 1 do
        result.Append(main.scriptwindow.Lines[iLine]);
    // The rest of the template.
    for iLine := insert_to + 1 to High(skel_template) do
        result.Append(skel_template[iLine]);
end;


// -----------------------------------------------------------------------------
// Special types of lines that can get added.


// Adds lines to the script that involve a string of classes.
// The first lone output will be _first_line_ unless that is empty.
// The _prefix_ is followed by GetLevelByClass() and _compare_ for each selected
// class in _classes_, with _joiner_ inserted between _compare_ and the next class.
// The _suffix_ is appended after the final _compare_, then _last_line_ is tacked
// on the end (as its own line) unless it is empty.
//
// If no classes are selected, this will return FALSE without adding any lines.
class function Tlilac.AddClassString(const first_line:shortstring; const prefix:shortstring;
                                     const classes:ClassCheck; const compare:shortstring;
                                     const joiner:shortstring; const suffix:shortstring;
                                     const last_line: shortstring; end_block:boolean=FALSE) : boolean;
var
    new_lines: array of shortstring;
    cur_line: integer;
    cur_class: TClassEnum;
    blanks: shortstring;
const
    func_name = 'GetLevelByClass(';
    func_end  = ', '+s_oPC+')';
begin
    result := false;
    blanks := Spaces(Length(prefix));
    // Allocate maximum space to avoid re-allocations later.
    SetLength(new_lines, 3+Integer(High(TClassEnum))-Integer(Low(TClassEnum))); // Potentially every class plus _first_line_ and _last_line_.

    // Locate the first class to use.
    cur_class := Low(TClassEnum);
    while (cur_class < High(TClassEnum)) and not classes[cur_class] do
        Inc(cur_class);
    // Abort if no classes found.
    if not classes[cur_class] then
        exit;

    // Begin with the block closer, if requested.
    if not end_block then
        cur_line := 0
    else begin
        new_lines[0] := '}';
        cur_line := 1;
    end;

    // Add _first_line_, if not empty.
    if first_line <> '' then begin
        new_lines[cur_line] := first_line;
        Inc(cur_line);
    end;

    // Construct the first line with classes in it.
    new_lines[cur_line] := prefix + func_name + SymConst(NWNCLASS, integer(cur_class)) +
                                                func_end + compare;

    // Loop through the remaining classes.
    while cur_class < High(TClassEnum) do begin
        Inc(cur_class);
        if classes[cur_class] then begin
            // Add this class to the output.
            new_lines[cur_line] += joiner;
            Inc(cur_line);
            new_lines[cur_line] := blanks + func_name + SymConst(NWNCLASS, integer(cur_class)) +
                                                        func_end + compare;
        end;
    end;

    // Finsh this off.
    new_lines[cur_line] += suffix;
    if last_line <> '' then begin
        Inc(cur_line);
        new_lines[cur_line] := last_line;
    end;

    // Add this to the script window.
    AddLines(new_lines[0..cur_line]);
    result := true;
end;


// Adds lines to the script that involve a string of races.
// The first lone output will be _first_line_ unless that is empty.
// The _prefix_ is followed by GetRacialType(_who_)m _compare_ and the race for
// each selected race in _races_, with _joiner_ inserted between the race and the
// next GetRacialType(). The _suffix_ is appended after the final race, then
// _last_line_ is tacked on the end (as its own line) unless it is empty.
//
// If no races are selected, this will return FALSE without adding any lines.
class function Tlilac.AddRaceString(const first_line:shortstring; const prefix:shortstring;
                                    const who:shortstring;        const compare:shortstring;
                                    const races:RacialCheck;      const joiner:shortstring;
                                    const suffix:shortstring;     const last_line: shortstring;
                                    end_block:boolean=FALSE) : boolean;
const
    func_name = 'GetRacialType(';
    func_end  = ')';
var
    new_lines: array of shortstring;
    cur_line:  integer;
    cur_race:  TRaceEnum;
    func_full: shortstring;
    blanks:    shortstring;
begin
    result := false;
    blanks := Spaces(Length(prefix));
    // Allocate maximum space to avoid re-allocations later.
    SetLength(new_lines, 4+Integer(High(TRaceEnum))-Integer(Low(TRaceEnum))); // Potentially every race plus _first_line_, _last_line_, and the block closer.
    // Construct the function call.
    func_full := func_name + who + func_end;

    // Locate the first race to use.
    cur_race := Low(TRaceEnum);
    while (cur_race < High(TRaceEnum)) and not races[cur_race] do
        Inc(cur_race);
    // Abort if no races found.
    if not races[cur_race] then
        exit;

    // Begin with the block closer, if requested.
    if not end_block then
        cur_line := 0
    else begin
        new_lines[0] := '}';
        cur_line := 1;
    end;

    // Add _first_line_, if not empty.
    if first_line <> '' then begin
        new_lines[cur_line] := first_line;
        Inc(cur_line);
    end;

    // Construct the first line with races in it.
    new_lines[cur_line] := prefix + func_full + compare + SymConst(RACIAL_TYPE, integer(cur_race));

    // Loop through the remaining races.
    while cur_race < High(TRaceEnum) do begin
        Inc(cur_race);
        if races[cur_race] then begin
            // Add this race to the output.
            new_lines[cur_line] += joiner;
            Inc(cur_line);
            new_lines[cur_line] := blanks + func_full + compare + SymConst(RACIAL_TYPE, integer(cur_race));
        end;
    end;

    // Finsh this off.
    new_lines[cur_line] += suffix;
    if last_line <> '' then begin
        Inc(cur_line);
        new_lines[cur_line] := last_line;
    end;

    // Add this to the script window.
    AddLines(new_lines[0..cur_line]);
    result := true;
end;


// -----------------------------------------------------------------------------
// Handy utilities.


// Returns whether or nor the script is in a state that will compile.
// If the script cannot be compiled as-is, this will inform the user why that is so.
class function  Tlilac.IsComplete(): boolean;
begin
    // To be changed if we pass all tests:
    result := false;

    // Incomplete "if" statements would be a problem.
    if Tifchoose.GetIfCount() > 0 then
        main.ShowPopup(Tifwarning)
    else
        // Currently that is the only reason a script might be incomplete.
        result := true;
end;


// Returns whether or not the script has been modified since it was marked as clean.
// Well, not quite that strong. The flag gets turned on by AddLines() (hence and
// those functions that call that), not the more structural routines AddDirections(),
// Include(), etc. (in part because of how those are actually used -- at the moment,
// there is no difference in the end result because those procedures do not set the flag).
class function  Tlilac.IsDirty(): boolean; inline;
begin
    result := dirty_flag;
end;


// Flags the script as unmodified since the last save.
class procedure Tlilac.MarkClean(); inline;
begin
    dirty_flag := false;
end;


// Returns TRUE if Tlilac will wrap the next batch of lines in something that
// requires an action (void return value).
class function  Tlilac.MustReturnVoid(): boolean; inline;
begin
    // Currently, this only happens when a delay is in effect.
    result := Tdelaycommand.DelaySet();
end;


// Returns TRUE if Tlilac will assign the next batch of lines to another object
// (something other than OBJECT_SELF).
class function  Tlilac.WillBeAssigned(): boolean; inline;
begin
    // Currently, assignments will only happen if a non-timed delay has been
    // set, and then only if the object implementing the delay is not OBJECT_SELF.
    result := Tdelaycommand.DelaySet() and (TdelayCommand.DelayTime() = 0) and
              (TdelayCommand.DelayString <> s_OBJECT_SELF);
end;


// -----------------------------------------------------------------------------
// NWScript function calls
// -----------------------------------------------------------------------------
// Note: These functions do not handle quote characters; it is up to the calling
//       routine to call QuoteSwap().


// Returns a NWScript function call that adds the specified journal entry to
// the specified creature, and possibly all party members or all PCs.
// This will put quotes around the plot ID.
class function  Script.AddJournalQuestEntry(const sPlotID, sState, sCreature:shortstring;
                                             bAllParty, bAllPlayers, bAllowHigher: boolean) : shortstring;
begin
    result := 'AddJournalQuestEntry("'+sPlotID+'", '+sState+', '+sCreature;

    // Optional parameters.
    if bAllowHigher or bAllPlayers or not bAllParty then
        result += BoolToStr(bAllParty, s_comma_TRUE, s_comma_FALSE);
    if bAllowHigher or bAllPlayers then
        result += BoolToStr(bAllPlayers, s_comma_TRUE, s_comma_FALSE);
    if bAllowHigher then
        result += s_comma_TRUE;

    // End the function call.
    result += ')';
end;


// Returns a NWScript function call that applies the given effect to the given subject
// for the given duration. Use a negative duration to flag a permanent effect.
class function  Script.ApplyEffect(const sEffect, sSubject:shortstring;
                                   isLocation:boolean;  nDuration: integer=0) : shortstring;
var
    sDuration, sType: shortstring;
begin
    // Determine the duration parameters to the NWScript command.
    if nDuration = 0 then begin
        sDuration := '';
        sType := 'DURATION_TYPE_INSTANT, ';
    end
    else if nDuration < 0 then begin
        sDuration := '';
        sType := 'DURATION_TYPE_PERMANENT, ';
    end
    else begin
        sDuration := ', '+IntToStr(nDuration)+'.0';
        sType := 'DURATION_TYPE_TEMPORARY, ';
    end;

    // Construct the command.
    if isLocation then
        result := 'ApplyEffectAtLocation('
    else
        result := 'ApplyEffectToObject(';
    result += sType + sEffect+', '+sSubject + sDuration+')';
end;


// Returns a NWScript function call that assigns sAction to sActor.
// This will return sAction itself is sActor is 'OBJECT_SELF' (which is the primary
// reason for calling this instead of constructing the command explicitly).
class function  Script.AssignCommand(const sActor: shortstring; const sAction:shortstring) : shortstring;
begin
    if sActor = s_OBJECT_SELF then
        result := sAction
    else
        result := s_AssignCommand + sActor+', '+sAction+')';
end;


// Returns a NWScript function call that assigns sAction to eActor, with sAlt as
// in ObjectVar().
// This will return sAction itself is eActor is E_CHOOSE_Owner (which is the primary
// reason for calling this instead of constructing the command explicitly).
class function  Script.AssignCommand(const eActor: TObjectEnum; const sAction:shortstring;
                                     const sAlt:shortstring='') : shortstring;
begin
    if eActor = E_CHOOSE_Owner then
        result := sAction
    else
        result := s_AssignCommand + ObjectVar(eActor, sAlt)+', '+sAction+')';
end;


// Returns a NWScript function call that assigns sAction to sActor, assuming
// sAction is incomplete (to be split over Multiple Lines).
// This will return sAction itself is sActor is 'OBJECT_SELF' (which is the primary
// reason for calling this instead of constructing the command explicitly).
//
// sIndent will return the extra indentation that should be added to the second
//      (and third, etc.) lines because of the AssignCommand() command.
// sEnd will return either ')' or '', which should be appended when the assigned
//      instruction is ended.
class function  Script.AssignCommandML(const sActor, sAction:shortstring; out sIndent, sEnd: shortstring) : shortstring;
begin
    if sActor = s_OBJECT_SELF then begin
        sIndent := '';
        result := sAction;
        sEnd := '';
    end
    else begin
        result := s_AssignCommand + sActor+', ';
        sIndent := Spaces(Length(result));

        result += sAction;
        sEnd := ')';
    end;
end;


// Returns a NWScript function call that creates a trap.
// sDisarm and sTriggered are the names of the scripts to call on those events.
// sSize is optional in NWScript, but it is required here if creating at a location.
class function  Script.CreateTrap(const sType, sWhere: shortstring;
                                  const sDisarm: shortstring=''; const sTriggered: shortstring='';
                                  bAtLocation: boolean=FALSE; const sSize: shortstring='') : shortstring;
begin
    result := 'CreateTrap'+BoolToStr(bAtLocation, 'AtLocation', 'OnObject')+'('+
                    sType+', '+sWhere;
    // Locations also get a size (optional if '2.0', but that is getting messy
    // to check here with all the other optional parameters).
    if bAtLocation then
        result += ', '+sSize;

    // Optional parameters.
    if (sTriggered <> '') or (sDisarm <> '') then begin
        if bAtLocation then
            result += ', ""'; // Optional tag is only for locations.
        result += ', STANDARD_FACTION_HOSTILE, "'+sDisarm+'"';
    end;
    if sTriggered <> '' then
        result += ', "'+sTriggered+'"';

    // End the line.
    result += ')';
end;


// Returns a NWScript function call that returns the _iNth_ nearest object with
// the tag _sTag_. If sToWhom is '', "nearest" will be with respect to the script
// owner (even if this will be assigned). To get the nearest with respect to
// whoever this gets assigned to, pass 'OBJECT_SELF' as sToWhom.
class function  Script.GetNearest(const sTag:shortstring; const sToWhom:shortstring=''; iNth:integer=1) : shortstring;
begin
    result := s_GetNearest + sTag+'"';

    // Optional parameter 1:
    if sToWhom = '' then begin
        // Interpret this as "OBJECT_SELF" that could become "oSelf".
        if Tlilac.WillBeAssigned() then begin
            Tlilac.Declare(VAR_oSELF);
            result += ', '+s_oSelf;
        end
        else if iNth > 1 then
            // Will need to fill this parameter so the second option can be filled.
            result += ', '+s_OBJECT_SELF;
    end
    else if (iNth > 1) or (sToWhom <> s_OBJECT_SELF) then
        result += ', '+sToWhom;

    // Optional parameter 2:
    if iNth > 1 then
        result += ', '+IntToStr(iNth);

    // End the command.
    result += ')';
end;


// Returns a NWScript function call that returns the item in slot sSlot (a string
// representing a NWScript integer) of sWhose.
// If sWhose is '' or 'OBJECT_SELF', that parameter will be suppressed in the NWScript.
class function  Script.GetItemInSlot(const sSlot: shortstring;  const sWhose: shortstring='') : shortstring;
begin
    result := 'GetItemInSlot('+sSlot;
    if (sWhose <> '') and (sWhose <> s_OBJECT_SELF) then
        result += ', '+sWhose;
    result += ')';
end;


// Shorthand for the above when the slot will be a symbolic constant.
// Provide the index of the slot in INVENTORY_SLOT instead of a string.
class function  Script.GetItemInSlot(const nSlot: integer; const sWhose: shortstring='') : shortstring; inline;
begin
    result := GetItemInSlot(SymConst(INVENTORY_SLOT, nSlot), sWhose);
end;


// Returns a NWScript function call that returns an item with the tag sItemTag
// possessed by sWho.
class function  Script.GetItemPossessedBy(const sWho, sItemTag: shortstring) : shortstring;
begin
    result := 'GetItemPossessedBy('+sWho+', "'+sItemTag+'")';
end;


// Returns a NWScript function call that returns an item with the tag sItemTag
// possessed by sWho. Does not add quotes.
class function  Script.GetItemPossessedByVar(const sWho, sItemTag: shortstring) : shortstring;
begin
    result := 'GetItemPossessedBy('+sWho+', '+sItemTag+')';
end;


// Returns a NWScript function that will return how far _Who_ has progressed in
// the journal quest _QuestTag_. (Progress is measured as the ID of _Who_'s
// current journal entry for this quest.)
class function  Script.JournalRead(const sWho, sQuestTag:shortstring) : shortstring;
begin
    result := 'GetLocalInt('+sWho+', "NW_JOURNAL_ENTRY'+sQuestTag+'")';
end;


// Returns a NWScript function that will cause _Who_ to play the voicechat indicated
// by _sChat_, with _sAlt_ being as in ObjectVar().
class function  Script.PlayVoicechat(const sChat: shortstring; Who: TObjectEnum;
                                     const sAlt:shortstring='') : shortstring;
begin
    result := 'PlayVoiceChat('+sChat;
    // Optional parameter.
    if Who <> E_CHOOSE_Owner then
        result += ', '+ObjectVar(Who, sAlt);
    result += ')';
end;


// Returns a NWScript function that will cause the caller to speak _sWhat_.
// _nVolume_ is an index for TALKVOLUME.
// Setting _bAsAction_ will produce an ActionSpeakString() instead of SpeakString().
class function  Script.SpeakString(const sWhat: shortstring; nVolume:integer; bAsAction: boolean=FALSE) : shortstring;
begin
    result := 'SpeakString("'+sWhat+'"';
    // Make this an action?
    if bAsAction then
        result := 'Action'+result;
    // Suppress the parameter if it is the default.
    if (nVolume <> 2) and (nVolume >= 0) then
        result += ', '+SymConst(TALKVOLUME, nVolume);
    // End the function call.
    result += ')';
end;


// Returns a NWScript function that will cause the caller to start a conversation
// with _sWithWhom_.
class function  Script.StartConvo(const sWithWhom:shortstring; const sDialog:shortstring='';
                                  bPrivate:boolean=FALSE; bPlayHello:boolean=TRUE) : shortstring;
begin
    result := 'ActionStartConversation('+sWithWhom;
    // Optional parameters?
    if (sDialog <> '') or bPrivate or not bPlayHello then
        result += ', "'+sDialog+'"';
    if bPrivate or not bPlayHello then
        result += BoolToStr(bPrivate, s_comma_TRUE, s_comma_FALSE);
    if not bPlayHello then
        result += s_comma_FALSE;
    // End the function call.
    result += ')';
end;


end.
