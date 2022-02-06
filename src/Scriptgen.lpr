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
* General overhaul of the behind-the-scenes workings.
* Cleanup of the GUI.
* Cleanup of the generated scripts.
* Some 1.69 features added.
}

{$MODE Delphi}
{$LONGSTRINGS OFF}
{$WRITEABLECONST OFF}

program Scriptgen;

{%ToDo 'Scriptgen.todo'}

uses
  Forms, Interfaces,
  start in 'start.pas' {main},
  random_int in 'random_int.pas' {Randomint},
  confirm_clear in 'confirm_clear.pas' {confirmclear},
  confirm_exit in 'confirm_exit.pas' {confirmexit},
  item_int in 'item_int.pas' {itemint},
  howto_use in 'howto_use.pas' {usehow},
  numitems_int in 'numitems_int.pas' {numitems},
  pcgold_int in 'pcgold_int.pas' {goldint},
  pcstats_int in 'pcstats_int.pas' {pcstats},
  statchoose_box in 'statchoose_box.pas' {statchoose},
  statwarning_box in 'statwarning_box.pas' {statwarning},
  oncetut in 'oncetut.pas' {once_tut},
  local_int in 'local_int.pas' {local},
  party_doc in 'party_doc.pas' {partydoc},
  help_doc in 'help_doc.pas' {helpdoc},
  nwn in 'nwn.pas',
  normscript_help in 'normscript_help.pas' {normscripthelp},
  event in 'event.pas' {eventchooser},
  restraint_norm in 'restraint_norm.pas' {restraint},
  other_restrict in 'other_restrict.pas' {otherrestrictions},
  itemxp_give in 'itemxp_give.pas' {givestuff},
  itemxp_take in 'itemxp_take.pas' {takestuff},
  adjustreputation in 'adjustreputation.pas' {repadjust},
  alignmentreputation in 'alignmentreputation.pas' {adjalignment},
  localvar in 'localvar.pas' {locvar},
  startmerchant in 'startmerchant.pas' {merchant},
  attackpc in 'attackpc.pas' {attack},
  spawn_creature in 'spawn_creature.pas' {crspawn},
  spawn_placeable in 'spawn_placeable.pas' {plspawn},
  help_concept in 'help_concept.pas' {concept_help},
  codegen_doc in 'codegen_doc.pas' {codegen},
  startconv in 'startconv.pas' {conversation},
  teleport_pc in 'teleport_pc.pas' {teleport},
  applyvisual in 'applyvisual.pas' {vfx},
  destroyobject in 'destroyobject.pas' {destroyobj},
  popup in 'popup.pas' {popup_ev},
  ifinspector in 'ifinspector.pas' {inspect},
  chooseif in 'chooseif.pas' {ifchoose},
  make_else in 'make_else.pas' {makeelse},
  journaladd in 'journaladd.pas' {entryupdate},
  journal_int in 'journal_int.pas' {journalsint},
  damage_pc in 'damage_pc.pas' {damagepc},
  spellcast in 'spellcast.pas' {castspell},
  openlock in 'openlock.pas' {lockopen},
  effect in 'effect.pas' {applyeffect},
  actionqueue in 'actionqueue.pas' {queue},
  if_warning in 'if_warning.pas' {ifwarning},
  heartbeat_notice in 'heartbeat_notice.pas' {heartbeatnotice},
  storepcparty in 'storepcparty.pas' {storeinfo},
  lights_onoff in 'lights_onoff.pas' {lights},
  fakespell in 'fakespell.pas' {fakespelldoc},
  black_smith in 'black_smith.pas' {blacksmith},
  choose_smith in 'choose_smith.pas' {choose_blacksmith},
  smith_when in 'smith_when.pas' {whentofire},
  unique_power in 'unique_power.pas' {uniquepower},
  commform in 'commform.pas' {communicationform},
  sound_object in 'sound_object.pas' {soundobject},
  subracedeity in 'subracedeity.pas' {subrace_deity},
  iffollower in 'iffollower.pas' {followers},
  companions in 'companions.pas' {companion},
  delay in 'delay.pas' {delaycommand},
  miscfunc in 'miscfunc.pas' {misc},
  acquire_item in 'acquire_item.pas' {acquire},
  cut_scene in 'cut_scene.pas' {cutscene},
  itemscript in 'itemscript.pas' {itemscripting},
  ipSpell in 'ipSpell.pas' {ipCastSpell},
  palettetool in 'palettetool.pas' {PaletteWindow},
  erfname in 'erfname.pas' {ErfNameForm},
  removeeffect in 'removeeffect.pas' {RemEffect},
  EventHelper in 'EventHelper.pas' {EventHelp},
  appear in 'appear.pas' {appearance},
  traps in 'traps.pas' {trapform},
  constants in 'constants.pas',
  ExtForm in 'ExtForm.pas',
  QueueForm in 'QueueForm.pas',
  ColorC in 'ColorC.pas',
  HorseMount in 'HorseMount.pas',
  TimeConditional in 'TimeConditional.pas',
  TypeChoose in 'TypeChoose.pas',
  BioFiles in 'BioFiles.pas';

// {$IFDEF WINDOWS}{$R Scriptgen.rc}{$ENDIF}

{$R *.res}

begin
  Application.Initialize();
  Application.CreateForm(Tmain, main);
  Application.Run();
end.
