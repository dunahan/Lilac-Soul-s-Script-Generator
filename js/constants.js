/**
 * NWScript Constants
 *
 * Extracted from Lilac Soul's Script Generator (The Krit revision, NWN 1.69)
 * Extended with NWN Enhanced Edition additions from nwnlexicon.com
 *
 * Copyright 2011 The Krit, Copyright 2006 Carsten Hjorthøj (Lilac Soul)
 * EE additions: NWN Lexicon contributors
 * License: GPL-2.0
 *
 * Format of each entry: { label: string, nwscript: string, version: 'base'|'ee' }
 * Arrays without EE additions contain only 'base' entries and omit the version field
 * for brevity — treat missing version as 'base'.
 *
 * Usage:
 *   import { ALIGNMENT, NWNCLASS, SPELL, ... } from './constants.js';
 *
 *   // Populate a <select>:
 *   NWNCLASS.forEach(c => {
 *     const opt = document.createElement('option');
 *     opt.value = c.nwscript;
 *     opt.textContent = c.label;
 *     select.appendChild(opt);
 *   });
 *
 *   // NWNLexicon link for a function name:
 *   `https://nwnlexicon.com/index.php?title=${fnName}`
 */

// =============================================================================
// ALIGNMENT
// =============================================================================

/** All alignment constants (for combined use). */
export const ALIGNMENT = [
  { label: 'Good',    nwscript: 'ALIGNMENT_GOOD'    },
  { label: 'Evil',    nwscript: 'ALIGNMENT_EVIL'    },
  { label: 'Neutral', nwscript: 'ALIGNMENT_NEUTRAL' },
  { label: 'Lawful',  nwscript: 'ALIGNMENT_LAWFUL'  },
  { label: 'Chaotic', nwscript: 'ALIGNMENT_CHAOTIC' },
];

/** Good/Neutral/Evil axis only. */
export const ALIGNMENT_GE = [
  { label: 'Good',    nwscript: 'ALIGNMENT_GOOD'    },
  { label: 'Neutral', nwscript: 'ALIGNMENT_NEUTRAL' },
  { label: 'Evil',    nwscript: 'ALIGNMENT_EVIL'    },
];

/** Lawful/Neutral/Chaotic axis only. */
export const ALIGNMENT_LC = [
  { label: 'Lawful',  nwscript: 'ALIGNMENT_LAWFUL'  },
  { label: 'Neutral', nwscript: 'ALIGNMENT_NEUTRAL' },
  { label: 'Chaotic', nwscript: 'ALIGNMENT_CHAOTIC' },
];

// =============================================================================
// AC TYPE
// =============================================================================

export const AC_TYPE = [
  { label: 'Armour enchantment bonus', nwscript: 'AC_ARMOUR_ENCHANTMENT_BONUS' },
  { label: 'Deflection bonus',         nwscript: 'AC_DEFLECTION_BONUS'         },
  { label: 'Dodge bonus',              nwscript: 'AC_DODGE_BONUS'              },
  { label: 'Natural bonus',            nwscript: 'AC_NATURAL_BONUS'            },
  { label: 'Shield enchantment bonus', nwscript: 'AC_SHIELD_ENCHANTMENT_BONUS' },
];

// =============================================================================
// AMBIENT SOUND
// =============================================================================

export const AMBIENT_SOUND = [
  { label: '(No Ambient Sound)',          nwscript: 'AMBIENT_SOUND_NONE'                       },
  { label: 'Blacksmith Shop',             nwscript: 'AMBIENT_SOUND_BLACK_SMITH'                },
  { label: 'Bordello Men and Women',      nwscript: 'AMBIENT_SOUND_BORDELLO_MEN_AND_WOMEN'     },
  { label: 'Bordello Women',              nwscript: 'AMBIENT_SOUND_BORDELLO_WOMEN'             },
  { label: 'Castle Interior Large',       nwscript: 'AMBIENT_SOUND_CASTLE_INTERIOR_LARGE'      },
  { label: 'Castle Interior Medium',      nwscript: 'AMBIENT_SOUND_CASTLE_INTERIOR_MEDIUM'     },
  { label: 'Castle Interior Small',       nwscript: 'AMBIENT_SOUND_CASTLE_INTERIOR_SMALL'      },
  { label: 'Cave Evil 1',                 nwscript: 'AMBIENT_SOUND_CAVE_EVIL_1_XP2'            },
  { label: 'Cave Evil 2',                 nwscript: 'AMBIENT_SOUND_CAVE_EVIL_2_XP2'            },
  { label: 'Cave Evil 3',                 nwscript: 'AMBIENT_SOUND_CAVE_EVIL_3_XP2'            },
  { label: 'Cave Insects 1',              nwscript: 'AMBIENT_SOUND_CAVE_INSECTS_1'             },
  { label: 'Cave Insects 2',              nwscript: 'AMBIENT_SOUND_CAVE_INSECTS_2'             },
  { label: 'Cave Large',                  nwscript: 'AMBIENT_SOUND_CAVE_LARGE'                 },
  { label: 'Cave Medium',                 nwscript: 'AMBIENT_SOUND_CAVE_MEDIUM'                },
  { label: 'Cave Small',                  nwscript: 'AMBIENT_SOUND_CAVE_SMALL'                 },
  { label: 'City Day Crowded',            nwscript: 'AMBIENT_SOUND_CITY_DAY_CROWDED'           },
  { label: 'City Day Sparse',             nwscript: 'AMBIENT_SOUND_CITY_DAY_SPARSE'            },
  { label: 'City Market',                 nwscript: 'AMBIENT_SOUND_CITY_MARKET'                },
  { label: 'City Night',                  nwscript: 'AMBIENT_SOUND_CITY_NIGHT'                 },
  { label: 'City Slums Day Crowded',      nwscript: 'AMBIENT_SOUND_CITY_SLUMS_DAY_CROWDED'     },
  { label: 'City Slums Day Sparse',       nwscript: 'AMBIENT_SOUND_CITY_SLUMS_DAY_SPARSE'      },
  { label: 'City Slums Night',            nwscript: 'AMBIENT_SOUND_CITY_SLUMS_NIGHT'           },
  { label: 'City Temple District',        nwscript: 'AMBIENT_SOUND_CITY_TEMPLE_DISTRICT'       },
  { label: 'Combat Muffled 1',            nwscript: 'AMBIENT_SOUND_COMBAT_MUFFLED_1'           },
  { label: 'Combat Muffled 2',            nwscript: 'AMBIENT_SOUND_COMBAT_MUFFLED_2'           },
  { label: 'Combat Outside 1',            nwscript: 'AMBIENT_SOUND_COMBAT_OUTSIDE_1'           },
  { label: 'Combat Outside 2',            nwscript: 'AMBIENT_SOUND_COMBAT_OUTSIDE_2'           },
  { label: 'Commoner Tavern Talk',        nwscript: 'AMBIENT_SOUND_COMMONER_TAVERN_TALK'       },
  { label: 'Crow Caws 1',                 nwscript: '110'                                       },
  { label: 'Crow Caws 2',                 nwscript: '111'                                       },
  { label: 'Crypt Medium 1',              nwscript: 'AMBIENT_SOUND_CRYPT_MEDIUM_1'             },
  { label: 'Crypt Medium 2',              nwscript: 'AMBIENT_SOUND_CRYPT_MEDIUM_2'             },
  { label: 'Desert 1',                    nwscript: 'AMBIENT_SOUND_DESERT_1'                   },
  { label: 'Desert Night',                nwscript: 'AMBIENT_SOUND_DESERT_NIGHT'               },
  { label: 'Dragon Cave',                 nwscript: 'AMBIENT_SOUND_DRAGON_CAVE'                },
  { label: 'Dungeon/Crypt 1',             nwscript: 'AMBIENT_SOUND_DUNGEON_CRYPT_1'            },
  { label: 'Dungeon/Crypt 2',             nwscript: 'AMBIENT_SOUND_DUNGEON_CRYPT_2'            },
  { label: 'Dungeon/Crypt 3',             nwscript: 'AMBIENT_SOUND_DUNGEON_CRYPT_3'            },
  { label: 'Dungeon Dripping',            nwscript: 'AMBIENT_SOUND_DUNGEON_DRIPPING'           },
  { label: 'Forest Day',                  nwscript: 'AMBIENT_SOUND_FOREST_DAY'                 },
  { label: 'Forest Night',               nwscript: 'AMBIENT_SOUND_FOREST_NIGHT'               },
  { label: 'Graveyard Day',              nwscript: 'AMBIENT_SOUND_GRAVEYARD_DAY'              },
  { label: 'Graveyard Night',            nwscript: 'AMBIENT_SOUND_GRAVEYARD_NIGHT'            },
  { label: 'Ice Cave 1',                 nwscript: 'AMBIENT_SOUND_ICE_CAVE_1_XP1'            },
  { label: 'Ice Cave 2',                 nwscript: 'AMBIENT_SOUND_ICE_CAVE_2_XP1'            },
  { label: 'Ice Cave 3',                 nwscript: 'AMBIENT_SOUND_ICE_CAVE_3_XP1'            },
  { label: 'Interior City 1',            nwscript: 'AMBIENT_SOUND_INTERIOR_CITY_1'           },
  { label: 'Interior City 2',            nwscript: 'AMBIENT_SOUND_INTERIOR_CITY_2'           },
  { label: 'Interior City 3',            nwscript: 'AMBIENT_SOUND_INTERIOR_CITY_3'           },
  { label: 'Interior Dungeon 1',         nwscript: 'AMBIENT_SOUND_INTERIOR_DUNGEON_1'        },
  { label: 'Interior Dungeon 2',         nwscript: 'AMBIENT_SOUND_INTERIOR_DUNGEON_2'        },
  { label: 'Interior Dungeon 3',         nwscript: 'AMBIENT_SOUND_INTERIOR_DUNGEON_3'        },
  { label: 'Interior Forest 1',          nwscript: 'AMBIENT_SOUND_INTERIOR_FOREST_1'         },
  { label: 'Lava Cave',                  nwscript: 'AMBIENT_SOUND_LAVA_CAVE_XP2'             },
  { label: 'Marsh Day',                  nwscript: 'AMBIENT_SOUND_MARSH_DAY'                 },
  { label: 'Marsh Night',               nwscript: 'AMBIENT_SOUND_MARSH_NIGHT'               },
  { label: 'Mountains',                  nwscript: 'AMBIENT_SOUND_MOUNTAINS'                 },
  { label: 'Ocean Day',                  nwscript: 'AMBIENT_SOUND_OCEAN_DAY'                 },
  { label: 'Ocean Night',               nwscript: 'AMBIENT_SOUND_OCEAN_NIGHT'               },
  { label: 'Rural Day',                  nwscript: 'AMBIENT_SOUND_RURAL_DAY'                 },
  { label: 'Rural Night',               nwscript: 'AMBIENT_SOUND_RURAL_NIGHT'               },
  { label: 'Sewers',                     nwscript: 'AMBIENT_SOUND_SEWERS'                    },
  { label: 'Ship',                       nwscript: 'AMBIENT_SOUND_SHIP_XP2'                  },
  { label: 'Tavern',                     nwscript: 'AMBIENT_SOUND_TAVERN'                    },
  { label: 'Underdark Cave 1',           nwscript: 'AMBIENT_SOUND_UNDERDARK_CAVE_1'          },
  { label: 'Underdark Cave 2',           nwscript: 'AMBIENT_SOUND_UNDERDARK_CAVE_2'          },
  { label: 'Underdark Cave 3',           nwscript: 'AMBIENT_SOUND_UNDERDARK_CAVE_3'          },
  { label: 'Underdark Large 1',          nwscript: 'AMBIENT_SOUND_UNDERDARK_LARGE_1'         },
  { label: 'Underdark Large 2',          nwscript: 'AMBIENT_SOUND_UNDERDARK_LARGE_2'         },
  { label: 'Underdark Large 3',          nwscript: 'AMBIENT_SOUND_UNDERDARK_LARGE_3'         },
  { label: 'Underdark Medium 1',         nwscript: 'AMBIENT_SOUND_UNDERDARK_MEDIUM_1'        },
  { label: 'Underdark Medium 2',         nwscript: 'AMBIENT_SOUND_UNDERDARK_MEDIUM_2'        },
  { label: 'Underdark Medium 3',         nwscript: 'AMBIENT_SOUND_UNDERDARK_MEDIUM_3'        },
  { label: 'Underdark Small',            nwscript: 'AMBIENT_SOUND_UNDERDARK_SMALL'           },
  { label: 'Underwater',                 nwscript: 'AMBIENT_SOUND_UNDERWATER_XP2'            },
  { label: 'Village Day',               nwscript: 'AMBIENT_SOUND_VILLAGE_DAY'               },
  { label: 'Village Night',             nwscript: 'AMBIENT_SOUND_VILLAGE_NIGHT'             },
  { label: 'Water (small stream)',       nwscript: 'AMBIENT_SOUND_WATER_SMALL_STREAM'        },
  { label: 'Water (fast stream)',        nwscript: 'AMBIENT_SOUND_WATER_FAST_STREAM'         },
  { label: 'Water (lake day)',           nwscript: 'AMBIENT_SOUND_WATER_LAKE_DAY'            },
  { label: 'Water (lake night)',         nwscript: 'AMBIENT_SOUND_WATER_LAKE_NIGHT'          },
  { label: 'Water (waterfall)',          nwscript: 'AMBIENT_SOUND_WATER_WATERFALL'           },
  { label: 'Wind (strong)',              nwscript: 'AMBIENT_SOUND_WIND_STRONG'               },
  { label: 'Wind (gentle)',              nwscript: 'AMBIENT_SOUND_WIND_GENTLE'               },
];

// =============================================================================
// ANIMATION
// =============================================================================

/**
 * PlayAnimation() constants.
 * EE adds LOOPING_CUSTOM21–40 (values 43–62) plus DOOR_* variants.
 */
export const ANIMATION = [
  // Fire-and-forget (base 1.69)
  { label: 'Fire-forget: bow',                      nwscript: 'ANIMATION_FIREFORGET_BOW'                   },
  { label: 'Fire-forget: dodge (duck)',              nwscript: 'ANIMATION_FIREFORGET_DODGE_DUCK'            },
  { label: 'Fire-forget: dodge (side)',              nwscript: 'ANIMATION_FIREFORGET_DODGE_SIDE'            },
  { label: 'Fire-forget: drink',                     nwscript: 'ANIMATION_FIREFORGET_DRINK'                 },
  { label: 'Fire-forget: greeting',                  nwscript: 'ANIMATION_FIREFORGET_GREETING'              },
  { label: 'Fire-forget: head turn left',            nwscript: 'ANIMATION_FIREFORGET_HEAD_TURN_LEFT'        },
  { label: 'Fire-forget: head turn right',           nwscript: 'ANIMATION_FIREFORGET_HEAD_TURN_RIGHT'       },
  { label: 'Fire-forget: pause (bored)',             nwscript: 'ANIMATION_FIREFORGET_PAUSE_BORED'           },
  { label: 'Fire-forget: pause (scratch head)',      nwscript: 'ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD'    },
  { label: 'Fire-forget: read',                      nwscript: 'ANIMATION_FIREFORGET_READ'                  },
  { label: 'Fire-forget: salute',                    nwscript: 'ANIMATION_FIREFORGET_SALUTE'                },
  { label: 'Fire-forget: spasm',                     nwscript: 'ANIMATION_FIREFORGET_SPASM'                 },
  { label: 'Fire-forget: steal',                     nwscript: 'ANIMATION_FIREFORGET_STEAL'                 },
  { label: 'Fire-forget: taunt',                     nwscript: 'ANIMATION_FIREFORGET_TAUNT'                 },
  { label: 'Fire-forget: victory 1',                 nwscript: 'ANIMATION_FIREFORGET_VICTORY1'              },
  { label: 'Fire-forget: victory 2',                 nwscript: 'ANIMATION_FIREFORGET_VICTORY2'              },
  { label: 'Fire-forget: victory 3',                 nwscript: 'ANIMATION_FIREFORGET_VICTORY3'              },
  // Looping (base 1.69)
  { label: 'Looping: conjure 1',                     nwscript: 'ANIMATION_LOOPING_CONJURE1'                 },
  { label: 'Looping: conjure 2',                     nwscript: 'ANIMATION_LOOPING_CONJURE2'                 },
  { label: 'Looping: dead (back)',                   nwscript: 'ANIMATION_LOOPING_DEAD_BACK'                },
  { label: 'Looping: dead (front)',                  nwscript: 'ANIMATION_LOOPING_DEAD_FRONT'               },
  { label: 'Looping: get low',                       nwscript: 'ANIMATION_LOOPING_GET_LOW'                  },
  { label: 'Looping: get mid',                       nwscript: 'ANIMATION_LOOPING_GET_MID'                  },
  { label: 'Looping: listen',                        nwscript: 'ANIMATION_LOOPING_LISTEN'                   },
  { label: 'Looping: look far',                      nwscript: 'ANIMATION_LOOPING_LOOK_FAR'                 },
  { label: 'Looping: meditate',                      nwscript: 'ANIMATION_LOOPING_MEDITATE'                 },
  { label: 'Looping: pause',                         nwscript: 'ANIMATION_LOOPING_PAUSE'                    },
  { label: 'Looping: pause 2',                       nwscript: 'ANIMATION_LOOPING_PAUSE2'                   },
  { label: 'Looping: pause (drunk)',                 nwscript: 'ANIMATION_LOOPING_PAUSE_DRUNK'              },
  { label: 'Looping: pause (tired)',                 nwscript: 'ANIMATION_LOOPING_PAUSE_TIRED'              },
  { label: 'Looping: sit chair',                     nwscript: 'ANIMATION_LOOPING_SIT_CHAIR'                },
  { label: 'Looping: sit cross',                     nwscript: 'ANIMATION_LOOPING_SIT_CROSS'                },
  { label: 'Looping: spasm',                         nwscript: 'ANIMATION_LOOPING_SPASM'                    },
  { label: 'Looping: talk forceful',                 nwscript: 'ANIMATION_LOOPING_TALK_FORCEFUL'            },
  { label: 'Looping: talk laughing',                 nwscript: 'ANIMATION_LOOPING_TALK_LAUGHING'            },
  { label: 'Looping: talk normal',                   nwscript: 'ANIMATION_LOOPING_TALK_NORMAL'              },
  { label: 'Looping: talk pleading',                 nwscript: 'ANIMATION_LOOPING_TALK_PLEADING'            },
  { label: 'Looping: worship',                       nwscript: 'ANIMATION_LOOPING_WORSHIP'                  },
  // 1.69 custom slots (values 21–40)
  { label: 'Looping: custom 1',                      nwscript: 'ANIMATION_LOOPING_CUSTOM1'                  },
  { label: 'Looping: custom 2',                      nwscript: 'ANIMATION_LOOPING_CUSTOM2'                  },
  { label: 'Looping: custom 3',                      nwscript: 'ANIMATION_LOOPING_CUSTOM3'                  },
  { label: 'Looping: custom 4',                      nwscript: 'ANIMATION_LOOPING_CUSTOM4'                  },
  { label: 'Looping: custom 5',                      nwscript: 'ANIMATION_LOOPING_CUSTOM5'                  },
  { label: 'Looping: custom 6',                      nwscript: 'ANIMATION_LOOPING_CUSTOM6'                  },
  { label: 'Looping: custom 7',                      nwscript: 'ANIMATION_LOOPING_CUSTOM7'                  },
  { label: 'Looping: custom 8',                      nwscript: 'ANIMATION_LOOPING_CUSTOM8'                  },
  { label: 'Looping: custom 9',                      nwscript: 'ANIMATION_LOOPING_CUSTOM9'                  },
  { label: 'Looping: custom 10',                     nwscript: 'ANIMATION_LOOPING_CUSTOM10'                 },
  { label: 'Looping: custom 11',                     nwscript: 'ANIMATION_LOOPING_CUSTOM11'                 },
  { label: 'Looping: custom 12',                     nwscript: 'ANIMATION_LOOPING_CUSTOM12'                 },
  { label: 'Looping: custom 13',                     nwscript: 'ANIMATION_LOOPING_CUSTOM13'                 },
  { label: 'Looping: custom 14',                     nwscript: 'ANIMATION_LOOPING_CUSTOM14'                 },
  { label: 'Looping: custom 15',                     nwscript: 'ANIMATION_LOOPING_CUSTOM15'                 },
  { label: 'Looping: custom 16',                     nwscript: 'ANIMATION_LOOPING_CUSTOM16'                 },
  { label: 'Looping: custom 17',                     nwscript: 'ANIMATION_LOOPING_CUSTOM17'                 },
  { label: 'Looping: custom 18',                     nwscript: 'ANIMATION_LOOPING_CUSTOM18'                 },
  { label: 'Looping: custom 19',                     nwscript: 'ANIMATION_LOOPING_CUSTOM19'                 },
  { label: 'Looping: custom 20',                     nwscript: 'ANIMATION_LOOPING_CUSTOM20'                 },
  // EE additions (values 42–62)
  { label: 'Dismount 1',                             nwscript: 'ANIMATION_DISMOUNT1',         version: 'ee' },
  { label: 'Looping: custom 21 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM21',  version: 'ee' },
  { label: 'Looping: custom 22 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM22',  version: 'ee' },
  { label: 'Looping: custom 23 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM23',  version: 'ee' },
  { label: 'Looping: custom 24 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM24',  version: 'ee' },
  { label: 'Looping: custom 25 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM25',  version: 'ee' },
  { label: 'Looping: custom 26 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM26',  version: 'ee' },
  { label: 'Looping: custom 27 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM27',  version: 'ee' },
  { label: 'Looping: custom 28 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM28',  version: 'ee' },
  { label: 'Looping: custom 29 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM29',  version: 'ee' },
  { label: 'Looping: custom 30 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM30',  version: 'ee' },
  { label: 'Looping: custom 31 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM31',  version: 'ee' },
  { label: 'Looping: custom 32 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM32',  version: 'ee' },
  { label: 'Looping: custom 33 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM33',  version: 'ee' },
  { label: 'Looping: custom 34 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM34',  version: 'ee' },
  { label: 'Looping: custom 35 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM35',  version: 'ee' },
  { label: 'Looping: custom 36 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM36',  version: 'ee' },
  { label: 'Looping: custom 37 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM37',  version: 'ee' },
  { label: 'Looping: custom 38 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM38',  version: 'ee' },
  { label: 'Looping: custom 39 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM39',  version: 'ee' },
  { label: 'Looping: custom 40 [EE]',               nwscript: 'ANIMATION_LOOPING_CUSTOM40',  version: 'ee' },
  // EE: Door animations
  { label: 'Door: close [EE]',                      nwscript: 'ANIMATION_DOOR_CLOSE',        version: 'ee' },
  { label: 'Door: destroy [EE]',                    nwscript: 'ANIMATION_DOOR_DESTROY',      version: 'ee' },
  { label: 'Door: open 1 [EE]',                     nwscript: 'ANIMATION_DOOR_OPEN1',        version: 'ee' },
  { label: 'Door: open 2 [EE]',                     nwscript: 'ANIMATION_DOOR_OPEN2',        version: 'ee' },
];

// =============================================================================
// ASSOCIATE TYPE
// =============================================================================

export const ASSOCIATE_TYPE = [
  { label: 'None',            nwscript: 'ASSOCIATE_TYPE_NONE'            },
  { label: 'Animal companion',nwscript: 'ASSOCIATE_TYPE_ANIMALCOMPANION' },
  { label: 'Dominated',       nwscript: 'ASSOCIATE_TYPE_DOMINATED'       },
  { label: 'Familiar',        nwscript: 'ASSOCIATE_TYPE_FAMILIAR'        },
  { label: 'Summoned',        nwscript: 'ASSOCIATE_TYPE_SUMMONED'        },
  { label: 'Henchman',        nwscript: 'ASSOCIATE_TYPE_HENCHMAN'        },
];

// =============================================================================
// CLASS TYPE  (NWNCLASS)
// =============================================================================

/**
 * All class types. The first 23 entries (indices 0–22) correspond to TClassEnum.
 * INVALID is an EE sentinel, not selectable in most contexts.
 */
export const NWNCLASS = [
  // Playable base classes (TClassEnum 0–10)
  { label: 'Barbarian',            nwscript: 'CLASS_TYPE_BARBARIAN'        },
  { label: 'Bard',                 nwscript: 'CLASS_TYPE_BARD'             },
  { label: 'Cleric',               nwscript: 'CLASS_TYPE_CLERIC'           },
  { label: 'Druid',                nwscript: 'CLASS_TYPE_DRUID'            },
  { label: 'Fighter',              nwscript: 'CLASS_TYPE_FIGHTER'          },
  { label: 'Monk',                 nwscript: 'CLASS_TYPE_MONK'             },
  { label: 'Paladin',              nwscript: 'CLASS_TYPE_PALADIN'          },
  { label: 'Ranger',               nwscript: 'CLASS_TYPE_RANGER'           },
  { label: 'Rogue',                nwscript: 'CLASS_TYPE_ROGUE'            },
  { label: 'Sorcerer',             nwscript: 'CLASS_TYPE_SORCERER'         },
  { label: 'Wizard',               nwscript: 'CLASS_TYPE_WIZARD'           },
  // Prestige classes (TClassEnum 11–22)
  { label: 'Arcane archer',        nwscript: 'CLASS_TYPE_ARCANE_ARCHER'    },
  { label: 'Assassin',             nwscript: 'CLASS_TYPE_ASSASSIN'         },
  { label: 'Blackguard',           nwscript: 'CLASS_TYPE_BLACKGUARD'       },
  { label: 'Champion of Torm',     nwscript: 'CLASS_TYPE_DIVINE_CHAMPION'  },
  { label: 'Dwarven defender',     nwscript: 'CLASS_TYPE_DWARVEN_DEFENDER' },
  { label: 'Harper scout',         nwscript: 'CLASS_TYPE_HARPER'           },
  { label: 'Pale master',          nwscript: 'CLASS_TYPE_PALE_MASTER'      },
  { label: 'Purple dragon knight', nwscript: 'CLASS_TYPE_PURPLE_DRAGON_KNIGHT' },
  { label: 'Red dragon disciple',  nwscript: 'CLASS_TYPE_DRAGON_DISCIPLE'  },
  { label: 'Shadowdancer',         nwscript: 'CLASS_TYPE_SHADOWDANCER'     },
  { label: 'Shifter',              nwscript: 'CLASS_TYPE_SHIFTER'          },
  { label: 'Weapon master',        nwscript: 'CLASS_TYPE_WEAPON_MASTER'    },
  // Monster / NPC classes
  { label: 'Aberration',           nwscript: 'CLASS_TYPE_ABERRATION'       },
  { label: 'Animal',               nwscript: 'CLASS_TYPE_ANIMAL'           },
  { label: 'Beast',                nwscript: 'CLASS_TYPE_BEAST'            },
  { label: 'Commoner',             nwscript: 'CLASS_TYPE_COMMONER'         },
  { label: 'Construct',            nwscript: 'CLASS_TYPE_CONSTRUCT'        },
  { label: 'Dragon',               nwscript: 'CLASS_TYPE_DRAGON'           },
  { label: 'Elemental',            nwscript: 'CLASS_TYPE_ELEMENTAL'        },
  { label: 'Fey',                  nwscript: 'CLASS_TYPE_FEY'              },
  { label: 'Giant',                nwscript: 'CLASS_TYPE_GIANT'            },
  { label: 'Humanoid',             nwscript: 'CLASS_TYPE_HUMANOID'         },
  { label: 'Magical beast',        nwscript: 'CLASS_TYPE_MAGICAL_BEAST'    },
  { label: 'Monstrous',            nwscript: 'CLASS_TYPE_MONSTROUS'        },
  { label: 'Ooze',                 nwscript: 'CLASS_TYPE_OOZE'             },
  { label: 'Outsider',             nwscript: 'CLASS_TYPE_OUTSIDER'         },
  { label: 'Shapechanger',         nwscript: 'CLASS_TYPE_SHAPECHANGER'     },
  { label: 'Undead',               nwscript: 'CLASS_TYPE_UNDEAD'           },
  { label: 'Vermin',               nwscript: 'CLASS_TYPE_VERMIN'           },
  // EE sentinel
  { label: '(Invalid / none)',     nwscript: 'CLASS_TYPE_INVALID', version: 'ee' },
];

// =============================================================================
// DISEASE
// =============================================================================

export const DISEASE_NAME = [
  { label: 'Blinding sickness', nwscript: 'DISEASE_BLINDING_SICKNESS'  },
  { label: 'Cackle fever',      nwscript: 'DISEASE_CACKLE_FEVER'       },
  { label: 'Demon fever',       nwscript: 'DISEASE_DEMON_FEVER'        },
  { label: 'Devil chills',      nwscript: 'DISEASE_DEVIL_CHILLS'       },
  { label: 'Filth fever',       nwscript: 'DISEASE_FILTH_FEVER'        },
  { label: 'Mindfire',          nwscript: 'DISEASE_MINDFIRE'           },
  { label: 'Mummy rot',         nwscript: 'DISEASE_MUMMY_ROT'          },
  { label: 'Red ache',          nwscript: 'DISEASE_RED_ACHE'           },
  { label: 'Shakes',            nwscript: 'DISEASE_SHAKES'             },
  { label: 'Slimy doom',        nwscript: 'DISEASE_SLIMY_DOOM'         },
  { label: 'Red slaad eggs',    nwscript: 'DISEASE_RED_SLAAD_EGGS'     },
  { label: 'Ghoul rot',         nwscript: 'DISEASE_GHOUL_ROT'          },
  { label: 'Zombie creep',      nwscript: 'DISEASE_ZOMBIE_CREEP'       },
  { label: 'Dread blisters',    nwscript: 'DISEASE_DREAD_BLISTERS'     },
  { label: 'Burrow maggots',    nwscript: 'DISEASE_BURROW_MAGGOTS'     },
  { label: 'Soldier shakes',    nwscript: 'DISEASE_SOLDIER_SHAKES'     },
  { label: 'Vermin madness',    nwscript: 'DISEASE_VERMIN_MADNESS'     },
];

// =============================================================================
// EFFECT TYPE
// =============================================================================

/**
 * Used with GetEffectType().
 * EE 1.88+: pass bAllTypes=TRUE to also return the EE-tagged entries below.
 */
export const EFFECT_TYPE = [
  { label: 'Ability decrease',         nwscript: 'EFFECT_TYPE_ABILITY_DECREASE'         },
  { label: 'Ability increase',         nwscript: 'EFFECT_TYPE_ABILITY_INCREASE'         },
  { label: 'AC decrease',              nwscript: 'EFFECT_TYPE_AC_DECREASE'              },
  { label: 'AC increase',              nwscript: 'EFFECT_TYPE_AC_INCREASE'              },
  { label: 'Arcane spell failure',     nwscript: 'EFFECT_TYPE_ARCANE_SPELL_FAILURE'     },
  { label: 'Attack decrease',          nwscript: 'EFFECT_TYPE_ATTACK_DECREASE'          },
  { label: 'Attack increase',          nwscript: 'EFFECT_TYPE_ATTACK_INCREASE'          },
  { label: 'Beam',                     nwscript: 'EFFECT_TYPE_BEAM'                     },
  { label: 'Blindness',                nwscript: 'EFFECT_TYPE_BLINDNESS'                },
  { label: 'Charmed',                  nwscript: 'EFFECT_TYPE_CHARMED'                  },
  { label: 'Concealment',              nwscript: 'EFFECT_TYPE_CONCEALMENT'              },
  { label: 'Confused',                 nwscript: 'EFFECT_TYPE_CONFUSED'                 },
  { label: 'Curse',                    nwscript: 'EFFECT_TYPE_CURSE'                    },
  { label: 'Cutscene ghost',           nwscript: 'EFFECT_TYPE_CUTSCENEGHOST'            },
  { label: 'Cutscene immobilize',      nwscript: 'EFFECT_TYPE_CUTSCENEIMMOBILIZE'       },
  { label: 'Cutscene paralyze',        nwscript: 'EFFECT_TYPE_CUTSCENE_PARALYZE'        },
  { label: 'Damage decrease',          nwscript: 'EFFECT_TYPE_DAMAGE_DECREASE'          },
  { label: 'Damage increase',          nwscript: 'EFFECT_TYPE_DAMAGE_INCREASE'          },
  { label: 'Damage immunity decrease', nwscript: 'EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE' },
  { label: 'Damage immunity increase', nwscript: 'EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE' },
  { label: 'Damage reduction',         nwscript: 'EFFECT_TYPE_DAMAGE_REDUCTION'         },
  { label: 'Damage resistance',        nwscript: 'EFFECT_TYPE_DAMAGE_RESISTANCE'        },
  { label: 'Dazed',                    nwscript: 'EFFECT_TYPE_DAZED'                    },
  { label: 'Deaf',                     nwscript: 'EFFECT_TYPE_DEAF'                     },
  { label: 'Disease',                  nwscript: 'EFFECT_TYPE_DISEASE'                  },
  { label: 'Dominated',                nwscript: 'EFFECT_TYPE_DOMINATED'                },
  { label: 'Enemy attack bonus',       nwscript: 'EFFECT_TYPE_ENEMY_ATTACK_BONUS'       },
  { label: 'Entangle',                 nwscript: 'EFFECT_TYPE_ENTANGLE'                 },
  { label: 'Ethereal',                 nwscript: 'EFFECT_TYPE_ETHEREAL'                 },
  { label: 'Frightened',               nwscript: 'EFFECT_TYPE_FRIGHTENED'               },
  { label: 'Haste',                    nwscript: 'EFFECT_TYPE_HASTE'                    },
  { label: 'Heal',                     nwscript: 'EFFECT_TYPE_HEAL'                     },
  { label: 'Hit point change when dying', nwscript: 'EFFECT_TYPE_HITPOINTCHANGEWHENDYING' },
  { label: 'Immunity',                 nwscript: 'EFFECT_TYPE_IMMUNITY'                 },
  { label: 'Invisibility',             nwscript: 'EFFECT_TYPE_INVISIBILITY'             },
  { label: 'Knockdown',                nwscript: 'EFFECT_TYPE_KNOCKDOWN'                },
  { label: 'Miss chance',              nwscript: 'EFFECT_TYPE_MISS_CHANCE'              },
  { label: 'Modify attacks',           nwscript: 'EFFECT_TYPE_MODIFY_ATTACKS'           },
  { label: 'Movement speed decrease',  nwscript: 'EFFECT_TYPE_MOVEMENT_SPEED_DECREASE'  },
  { label: 'Movement speed increase',  nwscript: 'EFFECT_TYPE_MOVEMENT_SPEED_INCREASE'  },
  { label: 'Negative level',           nwscript: 'EFFECT_TYPE_NEGATIVELEVEL'            },
  { label: 'Paralyze',                 nwscript: 'EFFECT_TYPE_PARALYZE'                 },
  { label: 'Petrify',                  nwscript: 'EFFECT_TYPE_PETRIFY'                  },
  { label: 'Poison',                   nwscript: 'EFFECT_TYPE_POISON'                   },
  { label: 'Polymorph',                nwscript: 'EFFECT_TYPE_POLYMORPH'                },
  { label: 'Regenerate',               nwscript: 'EFFECT_TYPE_REGENERATE'               },
  { label: 'Resurrection',             nwscript: 'EFFECT_TYPE_RESURRECTION'             },
  { label: 'Saving throw decrease',    nwscript: 'EFFECT_TYPE_SAVING_THROW_DECREASE'    },
  { label: 'Saving throw increase',    nwscript: 'EFFECT_TYPE_SAVING_THROW_INCREASE'    },
  { label: 'See invisible',            nwscript: 'EFFECT_TYPE_SEE_INVISIBLE'            },
  { label: 'Silence',                  nwscript: 'EFFECT_TYPE_SILENCE'                  },
  { label: 'Skill decrease',           nwscript: 'EFFECT_TYPE_SKILL_DECREASE'           },
  { label: 'Skill increase',           nwscript: 'EFFECT_TYPE_SKILL_INCREASE'           },
  { label: 'Sleep',                    nwscript: 'EFFECT_TYPE_SLEEP'                    },
  { label: 'Slow',                     nwscript: 'EFFECT_TYPE_SLOW'                     },
  { label: 'Spell failure',            nwscript: 'EFFECT_TYPE_SPELL_FAILURE'            },
  { label: 'Spell immunity',           nwscript: 'EFFECT_TYPE_SPELL_IMMUNITY'           },
  { label: 'Spell level absorption',   nwscript: 'EFFECT_TYPE_SPELL_LEVEL_ABSORPTION'   },
  { label: 'Spell resistance decrease',nwscript: 'EFFECT_TYPE_SPELL_RESISTANCE_DECREASE'},
  { label: 'Spell resistance increase',nwscript: 'EFFECT_TYPE_SPELL_RESISTANCE_INCREASE'},
  { label: 'Stunned',                  nwscript: 'EFFECT_TYPE_STUNNED'                  },
  { label: 'Summon creature',          nwscript: 'EFFECT_TYPE_SUMMON_CREATURE'          },
  { label: 'Swarm',                    nwscript: 'EFFECT_TYPE_SWARM'                    },
  { label: 'Taunt',                    nwscript: 'EFFECT_TYPE_TAUNT'                    },
  { label: 'Temporary hitpoints',      nwscript: 'EFFECT_TYPE_TEMPORARY_HITPOINTS'      },
  { label: 'True seeing',              nwscript: 'EFFECT_TYPE_TRUESEEING'               },
  { label: 'Turn resistance decrease', nwscript: 'EFFECT_TYPE_TURN_RESISTANCE_DECREASE' },
  { label: 'Turn resistance increase', nwscript: 'EFFECT_TYPE_TURN_RESISTANCE_INCREASE' },
  { label: 'Visual effect',            nwscript: 'EFFECT_TYPE_VISUALEFFECT'             },
  { label: 'Wounding',                 nwscript: 'EFFECT_TYPE_WOUNDING'                 },
  // EE additions (require bAllTypes=TRUE in GetEffectType, added EE 1.84–1.88)
  { label: 'Appear [EE]',              nwscript: 'EFFECT_TYPE_APPEAR',              version: 'ee' },
  { label: 'Bonus feat [EE]',          nwscript: 'EFFECT_TYPE_BONUS_FEAT',          version: 'ee' },
  { label: 'Cutscene dominated [EE]',  nwscript: 'EFFECT_TYPE_CUTSCENE_DOMINATED', version: 'ee' },
  { label: 'Damage [EE bAllTypes]',    nwscript: 'EFFECT_TYPE_DAMAGE',             version: 'ee' },
  { label: 'Death [EE bAllTypes]',     nwscript: 'EFFECT_TYPE_DEATH',              version: 'ee' },
  { label: 'Disappear [EE]',           nwscript: 'EFFECT_TYPE_DISAPPEAR',          version: 'ee' },
  { label: 'Effect icon [EE]',         nwscript: 'EFFECT_TYPE_ICON',               version: 'ee' },
  { label: 'Run script [EE]',          nwscript: 'EFFECT_TYPE_RUN_SCRIPT',         version: 'ee' },
];

// =============================================================================
// IMMUNITY TYPE
// =============================================================================

export const IMMUNITY_NAME = [
  { label: 'All (= none)',             nwscript: 'IMMUNITY_TYPE_NONE'               },
  { label: 'Ability decrease',         nwscript: 'IMMUNITY_TYPE_ABILITY_DECREASE'   },
  { label: 'AC decrease',              nwscript: 'IMMUNITY_TYPE_AC_DECREASE'        },
  { label: 'Attack decrease',          nwscript: 'IMMUNITY_TYPE_ATTACK_DECREASE'    },
  { label: 'Blindness',                nwscript: 'IMMUNITY_TYPE_BLINDNESS'          },
  { label: 'Charm',                    nwscript: 'IMMUNITY_TYPE_CHARM'              },
  { label: 'Confusion',                nwscript: 'IMMUNITY_TYPE_CONFUSION'          },
  { label: 'Critical hits',            nwscript: 'IMMUNITY_TYPE_CRITICAL_HIT'       },
  { label: 'Curse',                    nwscript: 'IMMUNITY_TYPE_CURSE'              },
  { label: 'Damage decrease',          nwscript: 'IMMUNITY_TYPE_DAMAGE_DECREASE'    },
  { label: 'Dazed',                    nwscript: 'IMMUNITY_TYPE_DAZED'              },
  { label: 'Deafness',                 nwscript: 'IMMUNITY_TYPE_DEAFNESS'           },
  { label: 'Death magic',              nwscript: 'IMMUNITY_TYPE_DEATH'              },
  { label: 'Disease',                  nwscript: 'IMMUNITY_TYPE_DISEASE'            },
  { label: 'Domination',               nwscript: 'IMMUNITY_TYPE_DOMINATE'           },
  { label: 'Entangle',                 nwscript: 'IMMUNITY_TYPE_ENTANGLE'           },
  { label: 'Fear',                     nwscript: 'IMMUNITY_TYPE_FEAR'               },
  { label: 'Knockdown',                nwscript: 'IMMUNITY_TYPE_KNOCKDOWN'          },
  { label: 'Mind spells',              nwscript: 'IMMUNITY_TYPE_MIND_SPELLS'        },
  { label: 'Movement speed decrease',  nwscript: 'IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE' },
  { label: 'Negative energy',          nwscript: 'IMMUNITY_TYPE_NEGATIVE_LEVEL'     },
  { label: 'Paralysis',                nwscript: 'IMMUNITY_TYPE_PARALYSIS'          },
  { label: 'Poison',                   nwscript: 'IMMUNITY_TYPE_POISON'             },
  { label: 'Saving throw decrease',    nwscript: 'IMMUNITY_TYPE_SAVING_THROW_DECREASE' },
  { label: 'Silence',                  nwscript: 'IMMUNITY_TYPE_SILENCE'            },
  { label: 'Skill decrease',           nwscript: 'IMMUNITY_TYPE_SKILL_DECREASE'     },
  { label: 'Sleep',                    nwscript: 'IMMUNITY_TYPE_SLEEP'              },
  { label: 'Slow',                     nwscript: 'IMMUNITY_TYPE_SLOW'               },
  { label: 'Sneak attack',             nwscript: 'IMMUNITY_TYPE_SNEAK_ATTACK'       },
  { label: 'Spell resistance decrease',nwscript: 'IMMUNITY_TYPE_SPELL_RESISTANCE_DECREASE' },
  { label: 'Stun',                     nwscript: 'IMMUNITY_TYPE_STUN'               },
  { label: 'Trap',                     nwscript: 'IMMUNITY_TYPE_TRAP'               },
];

// =============================================================================
// INVENTORY SLOT
// =============================================================================

export const INVENTORY_SLOT = [
  { label: 'Head',              nwscript: 'INVENTORY_SLOT_HEAD',         itemType: 'Helmet'          },
  { label: 'Chest',             nwscript: 'INVENTORY_SLOT_CHEST',        itemType: 'Armour'          },
  { label: 'Cloak',             nwscript: 'INVENTORY_SLOT_CLOAK',        itemType: 'Cloak'           },
  { label: 'Boots',             nwscript: 'INVENTORY_SLOT_BOOTS',        itemType: 'Boots'           },
  { label: 'Gloves',            nwscript: 'INVENTORY_SLOT_GLOVES',       itemType: 'Gloves'          },
  { label: 'Left ring',         nwscript: 'INVENTORY_SLOT_LEFTRING',     itemType: 'Ring'            },
  { label: 'Right ring',        nwscript: 'INVENTORY_SLOT_RIGHTRING',    itemType: 'Ring'            },
  { label: 'Neck',              nwscript: 'INVENTORY_SLOT_NECK',         itemType: 'Amulet'          },
  { label: 'Belt',              nwscript: 'INVENTORY_SLOT_BELT',         itemType: 'Belt'            },
  { label: 'Arms',              nwscript: 'INVENTORY_SLOT_ARMS',         itemType: 'Bracers'         },
  { label: 'Right hand',        nwscript: 'INVENTORY_SLOT_RIGHTHAND',    itemType: 'Weapon'          },
  { label: 'Left hand',         nwscript: 'INVENTORY_SLOT_LEFTHAND',     itemType: 'Shield/offhand'  },
  { label: 'Left hand (both hands)', nwscript: 'INVENTORY_SLOT_LEFTHAND', itemType: '2H weapon'     },
  { label: 'Creature left fist',nwscript: 'INVENTORY_SLOT_CWEAPON_L',   itemType: 'Creature weapon' },
  { label: 'Creature right fist',nwscript: 'INVENTORY_SLOT_CWEAPON_R',  itemType: 'Creature weapon' },
  { label: 'Creature bite',     nwscript: 'INVENTORY_SLOT_CWEAPON_B',   itemType: 'Creature weapon' },
  { label: 'Creature skin',     nwscript: 'INVENTORY_SLOT_CARMOUR',      itemType: 'Creature armour' },
  { label: 'Arrows',            nwscript: 'INVENTORY_SLOT_ARROWS',       itemType: 'Ammunition'      },
  { label: 'Bolts',             nwscript: 'INVENTORY_SLOT_BOLTS',        itemType: 'Ammunition'      },
  { label: 'Bullets',           nwscript: 'INVENTORY_SLOT_BULLETS',      itemType: 'Ammunition'      },
];

// =============================================================================
// RACIAL TYPE
// =============================================================================

export const RACIAL_TYPE = [
  // Playable (TRaceEnum 0–6)
  { label: 'Dwarf',              nwscript: 'RACIAL_TYPE_DWARF'                   },
  { label: 'Elf',                nwscript: 'RACIAL_TYPE_ELF'                     },
  { label: 'Gnome',              nwscript: 'RACIAL_TYPE_GNOME'                   },
  { label: 'Halfling',           nwscript: 'RACIAL_TYPE_HALFLING'                },
  { label: 'Half-elf',           nwscript: 'RACIAL_TYPE_HALFELF'                 },
  { label: 'Half-orc',           nwscript: 'RACIAL_TYPE_HALFORC'                 },
  { label: 'Human',              nwscript: 'RACIAL_TYPE_HUMAN'                   },
  // Non-playable
  { label: 'Aberration',         nwscript: 'RACIAL_TYPE_ABERRATION'              },
  { label: 'Animal',             nwscript: 'RACIAL_TYPE_ANIMAL'                  },
  { label: 'Beast',              nwscript: 'RACIAL_TYPE_BEAST'                   },
  { label: 'Construct',          nwscript: 'RACIAL_TYPE_CONSTRUCT'               },
  { label: 'Dragon',             nwscript: 'RACIAL_TYPE_DRAGON'                  },
  { label: 'Elemental',          nwscript: 'RACIAL_TYPE_ELEMENTAL'               },
  { label: 'Fey',                nwscript: 'RACIAL_TYPE_FEY'                     },
  { label: 'Giant',              nwscript: 'RACIAL_TYPE_GIANT'                   },
  { label: 'Goblinoid',          nwscript: 'RACIAL_TYPE_HUMANOID_GOBLINOID'      },
  { label: 'Magical beast',      nwscript: 'RACIAL_TYPE_MAGICAL_BEAST'           },
  { label: 'Monstrous humanoid', nwscript: 'RACIAL_TYPE_HUMANOID_MONSTROUS'      },
  { label: 'Ooze',               nwscript: 'RACIAL_TYPE_OOZE'                    },
  { label: 'Orc',                nwscript: 'RACIAL_TYPE_HUMANOID_ORC'            },
  { label: 'Outsider',           nwscript: 'RACIAL_TYPE_OUTSIDER'                },
  { label: 'Reptilian',          nwscript: 'RACIAL_TYPE_HUMANOID_REPTILIAN'      },
  { label: 'Shapechanger',       nwscript: 'RACIAL_TYPE_SHAPECHANGER'            },
  { label: 'Undead',             nwscript: 'RACIAL_TYPE_UNDEAD'                  },
  { label: 'Vermin',             nwscript: 'RACIAL_TYPE_VERMIN'                  },
  // EE addition
  { label: 'All (unrestricted)', nwscript: 'RACIAL_TYPE_ALL', version: 'ee'      },
];

// =============================================================================
// SAVING THROW TYPE
// =============================================================================

export const SAVING_THROW_TYPE = [
  { label: 'Standard',             nwscript: 'SAVING_THROW_TYPE_NONE'        },
  { label: 'Versus acid',          nwscript: 'SAVING_THROW_TYPE_ACID'        },
  { label: 'Versus chaos',         nwscript: 'SAVING_THROW_TYPE_CHAOS'       },
  { label: 'Versus cold',          nwscript: 'SAVING_THROW_TYPE_COLD'        },
  { label: 'Versus death',         nwscript: 'SAVING_THROW_TYPE_DEATH'       },
  { label: 'Versus disease',       nwscript: 'SAVING_THROW_TYPE_DISEASE'     },
  { label: 'Versus divine',        nwscript: 'SAVING_THROW_TYPE_DIVINE'      },
  { label: 'Versus electricity',   nwscript: 'SAVING_THROW_TYPE_ELECTRICITY' },
  { label: 'Versus evil',          nwscript: 'SAVING_THROW_TYPE_EVIL'        },
  { label: 'Versus fear',          nwscript: 'SAVING_THROW_TYPE_FEAR'        },
  { label: 'Versus fire',          nwscript: 'SAVING_THROW_TYPE_FIRE'        },
  { label: 'Versus good',          nwscript: 'SAVING_THROW_TYPE_GOOD'        },
  { label: 'Versus law',           nwscript: 'SAVING_THROW_TYPE_LAW'         },
  { label: 'Versus mind spells',   nwscript: 'SAVING_THROW_TYPE_MIND_SPELLS' },
  { label: 'Versus negative energy',nwscript: 'SAVING_THROW_TYPE_NEGATIVE'   },
  { label: 'Versus poison',        nwscript: 'SAVING_THROW_TYPE_POISON'      },
  { label: 'Versus positive',      nwscript: 'SAVING_THROW_TYPE_POSITIVE'    },
  { label: 'Versus sonic',         nwscript: 'SAVING_THROW_TYPE_SONIC'       },
  { label: 'Versus spells',        nwscript: 'SAVING_THROW_TYPE_SPELL'       },
  { label: 'Versus traps',         nwscript: 'SAVING_THROW_TYPE_TRAP'        },
];

// =============================================================================
// SKILL
// =============================================================================

/**
 * SKILL_NAME parallel to RestrictedSkill boolean array.
 * restricted=true means the skill requires training to use.
 */
export const SKILL_NAME = [
  { label: 'Animal empathy',  nwscript: 'SKILL_ANIMAL_EMPATHY',  restricted: true  },
  { label: 'Appraise',        nwscript: 'SKILL_APPRAISE',         restricted: false },
  { label: 'Bluff',           nwscript: 'SKILL_BLUFF',            restricted: false },
  { label: 'Concentration',   nwscript: 'SKILL_CONCENTRATION',    restricted: false },
  { label: 'Craft armor',     nwscript: 'SKILL_CRAFT_ARMOR',      restricted: true  },
  { label: 'Craft trap',      nwscript: 'SKILL_CRAFT_TRAP',       restricted: true  },
  { label: 'Craft weapon',    nwscript: 'SKILL_CRAFT_WEAPON',     restricted: true  },
  { label: 'Disable trap',    nwscript: 'SKILL_DISABLE_TRAP',     restricted: true  },
  { label: 'Discipline',      nwscript: 'SKILL_DISCIPLINE',       restricted: false },
  { label: 'Heal',            nwscript: 'SKILL_HEAL',             restricted: false },
  { label: 'Hide',            nwscript: 'SKILL_HIDE',             restricted: false },
  { label: 'Intimidate',      nwscript: 'SKILL_INTIMIDATE',       restricted: false },
  { label: 'Listen',          nwscript: 'SKILL_LISTEN',           restricted: false },
  { label: 'Lore',            nwscript: 'SKILL_LORE',             restricted: false },
  { label: 'Move silently',   nwscript: 'SKILL_MOVE_SILENTLY',    restricted: false },
  { label: 'Open lock',       nwscript: 'SKILL_OPEN_LOCK',        restricted: true  },
  { label: 'Parry',           nwscript: 'SKILL_PARRY',            restricted: false },
  { label: 'Perform',         nwscript: 'SKILL_PERFORM',          restricted: true  },
  { label: 'Persuade',        nwscript: 'SKILL_PERSUADE',         restricted: false },
  { label: 'Pick pocket',     nwscript: 'SKILL_PICK_POCKET',      restricted: true  },
  { label: 'Ride',            nwscript: 'SKILL_RIDE',             restricted: false },
  { label: 'Search',          nwscript: 'SKILL_SEARCH',           restricted: false },
  { label: 'Set trap',        nwscript: 'SKILL_SET_TRAP',         restricted: true  },
  { label: 'Spellcraft',      nwscript: 'SKILL_SPELLCRAFT',       restricted: false },
  { label: 'Spot',            nwscript: 'SKILL_SPOT',             restricted: false },
  { label: 'Taunt',           nwscript: 'SKILL_TAUNT',            restricted: false },
  { label: 'Tumble',          nwscript: 'SKILL_TUMBLE',           restricted: true  },
  { label: 'Use magic device',nwscript: 'SKILL_USE_MAGIC_DEVICE', restricted: true  },
];

// =============================================================================
// TALKVOLUME
// =============================================================================

export const TALKVOLUME = [
  { label: 'Silent shout (everyone in area)', nwscript: 'TALKVOLUME_SILENT_SHOUT' },
  { label: 'Shout (large radius)',            nwscript: 'TALKVOLUME_SHOUT'        },
  { label: 'Talk (normal radius)',            nwscript: 'TALKVOLUME_TALK'         },
  { label: 'Silent talk (very short range)', nwscript: 'TALKVOLUME_SILENT_TALK'  },
  { label: 'Whisper (short range)',           nwscript: 'TALKVOLUME_WHISPER'      },
];

// =============================================================================
// CREATURE WING TYPE
// =============================================================================

export const WING_TYPE = [
  { label: 'None',                 nwscript: 'CREATURE_WING_TYPE_NONE'       },
  { label: 'Angel',                nwscript: 'CREATURE_WING_TYPE_ANGEL'      },
  { label: 'Backpack',             nwscript: '79'                            },
  { label: 'Backpack (bedroll)',   nwscript: '80'                            },
  { label: 'Bat',                  nwscript: 'CREATURE_WING_TYPE_BAT'        },
  { label: 'Bird',                 nwscript: 'CREATURE_WING_TYPE_BIRD'       },
  { label: 'Butterfly',            nwscript: 'CREATURE_WING_TYPE_BUTTERFLY'  },
  { label: 'Demon',                nwscript: 'CREATURE_WING_TYPE_DEMON'      },
  { label: 'Dragon',               nwscript: 'CREATURE_WING_TYPE_DRAGON'     },
  { label: 'Dragon wing, black',   nwscript: '65'                            },
  { label: 'Dragon wing, black 2', nwscript: '75'                            },
  { label: 'Dragon wing, blue',    nwscript: '67'                            },
  { label: 'Dragon wing, blue 2',  nwscript: '77'                            },
  { label: 'Dragon wing, brass',   nwscript: '59'                            },
  { label: 'Dragon wing, brass 2', nwscript: '69'                            },
  { label: 'Dragon wing, bronze',  nwscript: '60'                            },
  { label: 'Dragon wing, bronze 2',nwscript: '70'                            },
  { label: 'Dragon wing, copper',  nwscript: '61'                            },
  { label: 'Dragon wing, copper 2',nwscript: '71'                            },
  { label: 'Dragon wing, gold',    nwscript: '63'                            },
  { label: 'Dragon wing, gold 2',  nwscript: '73'                            },
  { label: 'Dragon wing, green',   nwscript: '66'                            },
  { label: 'Dragon wing, green 2', nwscript: '76'                            },
  { label: 'Dragon wing, red',     nwscript: '68'                            },
  { label: 'Dragon wing, red 2',   nwscript: '78'                            },
  { label: 'Dragon wing, silver',  nwscript: '62'                            },
  { label: 'Dragon wing, silver 2',nwscript: '72'                            },
  { label: 'Dragon wing, white',   nwscript: '64'                            },
  { label: 'Dragon wing, white 2', nwscript: '74'                            },
  { label: 'Greatsword',           nwscript: '89'                            },
  { label: 'Quiver',               nwscript: '81'                            },
  { label: 'Quiver (empty)',        nwscript: '82'                            },
  { label: 'Scabbard',             nwscript: '83'                            },
  { label: 'Scabbard A',           nwscript: '85'                            },
  { label: 'Scabbard A (empty)',    nwscript: '86'                            },
  { label: 'Scabbard B',           nwscript: '87'                            },
  { label: 'Scabbard B (empty)',    nwscript: '88'                            },
  { label: 'Scabbard (empty)',      nwscript: '84'                            },
];

// =============================================================================
// CREATURE TAIL TYPE (normal non-horse)
// =============================================================================

export const TAIL_TYPE_NORMAL = [
  { label: 'None',                                nwscript: 'CREATURE_TAIL_TYPE_NONE'   },
  { label: 'Bone',                                nwscript: 'CREATURE_TAIL_TYPE_BONE'   },
  { label: 'Devil',                               nwscript: 'CREATURE_TAIL_TYPE_DEVIL'  },
  { label: 'Dragon, black',                       nwscript: '9'                         },
  { label: 'Dragon, blue',                        nwscript: '10'                        },
  { label: 'Dragon, brass',                       nwscript: '4'                         },
  { label: 'Dragon, bronze',                      nwscript: '5'                         },
  { label: 'Dragon, copper',                      nwscript: '6'                         },
  { label: 'Dragon, gold',                        nwscript: '8'                         },
  { label: 'Dragon, green',                       nwscript: '11'                        },
  { label: 'Dragon, red',                         nwscript: '12'                        },
  { label: 'Dragon, silver',                      nwscript: '7'                         },
  { label: 'Dragon, white',                       nwscript: '13'                        },
  { label: 'Lizard',                              nwscript: 'CREATURE_TAIL_TYPE_LIZARD' },
  { label: 'Null tail (loads horse animations)',   nwscript: '14'                        },
];

// =============================================================================
// DURATION TYPE
// =============================================================================

export const DURATION_TYPE = [
  { label: 'Instant',   nwscript: 'DURATION_TYPE_INSTANT'   },
  { label: 'Permanent', nwscript: 'DURATION_TYPE_PERMANENT' },
  { label: 'Temporary', nwscript: 'DURATION_TYPE_TEMPORARY' },
];

// =============================================================================
// DAMAGE TYPE
// =============================================================================

export const DAMAGE_TYPE = [
  { label: 'Bludgeoning', nwscript: 'DAMAGE_TYPE_BLUDGEONING' },
  { label: 'Piercing',    nwscript: 'DAMAGE_TYPE_PIERCING'    },
  { label: 'Slashing',    nwscript: 'DAMAGE_TYPE_SLASHING'    },
  { label: 'Magical',     nwscript: 'DAMAGE_TYPE_MAGICAL'     },
  { label: 'Acid',        nwscript: 'DAMAGE_TYPE_ACID'        },
  { label: 'Cold',        nwscript: 'DAMAGE_TYPE_COLD'        },
  { label: 'Divine',      nwscript: 'DAMAGE_TYPE_DIVINE'      },
  { label: 'Electrical',  nwscript: 'DAMAGE_TYPE_ELECTRICAL'  },
  { label: 'Fire',        nwscript: 'DAMAGE_TYPE_FIRE'        },
  { label: 'Negative',    nwscript: 'DAMAGE_TYPE_NEGATIVE'    },
  { label: 'Positive',    nwscript: 'DAMAGE_TYPE_POSITIVE'    },
  { label: 'Sonic',       nwscript: 'DAMAGE_TYPE_SONIC'       },
];

// =============================================================================
// EE-ONLY: EVENT_SCRIPT_*
// =============================================================================

/**
 * EE only (added 1.74.8164, extended through 1.85).
 * Used with SetEventScript(oObject, nHandler, sScript) and GetEventScript().
 */
export const EVENT_SCRIPT = [
  // Area events
  { label: 'Area: On enter',                 nwscript: 'EVENT_SCRIPT_AREA_ON_ENTER',                    version: 'ee' },
  { label: 'Area: On exit',                  nwscript: 'EVENT_SCRIPT_AREA_ON_EXIT',                     version: 'ee' },
  { label: 'Area: On heartbeat',             nwscript: 'EVENT_SCRIPT_AREA_ON_HEARTBEAT',                version: 'ee' },
  { label: 'Area: On user defined',          nwscript: 'EVENT_SCRIPT_AREA_ON_USER_DEFINED_EVENT',       version: 'ee' },
  // Creature events
  { label: 'Creature: On attacked',         nwscript: 'EVENT_SCRIPT_CREATURE_ON_ATTACKED',             version: 'ee' },
  { label: 'Creature: On blocked',          nwscript: 'EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR',      version: 'ee' },
  { label: 'Creature: On combat round end', nwscript: 'EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND',      version: 'ee' },
  { label: 'Creature: On conversation',     nwscript: 'EVENT_SCRIPT_CREATURE_ON_DIALOGUE',             version: 'ee' },
  { label: 'Creature: On damaged',          nwscript: 'EVENT_SCRIPT_CREATURE_ON_DAMAGED',              version: 'ee' },
  { label: 'Creature: On death',            nwscript: 'EVENT_SCRIPT_CREATURE_ON_DEATH',                version: 'ee' },
  { label: 'Creature: On disturbed',        nwscript: 'EVENT_SCRIPT_CREATURE_ON_DISTURBED',            version: 'ee' },
  { label: 'Creature: On heartbeat',        nwscript: 'EVENT_SCRIPT_CREATURE_ON_HEARTBEAT',            version: 'ee' },
  { label: 'Creature: On perception',       nwscript: 'EVENT_SCRIPT_CREATURE_ON_NOTICE',               version: 'ee' },
  { label: 'Creature: On rested',           nwscript: 'EVENT_SCRIPT_CREATURE_ON_RESTED',               version: 'ee' },
  { label: 'Creature: On spawn',            nwscript: 'EVENT_SCRIPT_CREATURE_ON_SPAWN_IN',             version: 'ee' },
  { label: 'Creature: On spell cast at',    nwscript: 'EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT',          version: 'ee' },
  { label: 'Creature: On user defined',     nwscript: 'EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT',   version: 'ee' },
  // Door events
  { label: 'Door: On attacked',             nwscript: 'EVENT_SCRIPT_DOOR_ON_ATTACKED',                 version: 'ee' },
  { label: 'Door: On click',                nwscript: 'EVENT_SCRIPT_DOOR_ON_CLICKED',                  version: 'ee' },
  { label: 'Door: On closed',               nwscript: 'EVENT_SCRIPT_DOOR_ON_CLOSE',                    version: 'ee' },
  { label: 'Door: On damaged',              nwscript: 'EVENT_SCRIPT_DOOR_ON_DAMAGE',                   version: 'ee' },
  { label: 'Door: On death',                nwscript: 'EVENT_SCRIPT_DOOR_ON_DEATH',                    version: 'ee' },
  { label: 'Door: On fail to open',         nwscript: 'EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN',             version: 'ee' },
  { label: 'Door: On heartbeat',            nwscript: 'EVENT_SCRIPT_DOOR_ON_HEARTBEAT',                version: 'ee' },
  { label: 'Door: On lock',                 nwscript: 'EVENT_SCRIPT_DOOR_ON_LOCK',                     version: 'ee' },
  { label: 'Door: On open',                 nwscript: 'EVENT_SCRIPT_DOOR_ON_OPEN',                     version: 'ee' },
  { label: 'Door: On spell cast at',        nwscript: 'EVENT_SCRIPT_DOOR_ON_SPELLCASTAT',              version: 'ee' },
  { label: 'Door: On unlock',               nwscript: 'EVENT_SCRIPT_DOOR_ON_UNLOCK',                   version: 'ee' },
  { label: 'Door: On user defined',         nwscript: 'EVENT_SCRIPT_DOOR_ON_USER_DEFINED',             version: 'ee' },
  // Module events
  { label: 'Module: On acquire item',       nwscript: 'EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM',           version: 'ee' },
  { label: 'Module: On activate item',      nwscript: 'EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM',          version: 'ee' },
  { label: 'Module: On client enter',       nwscript: 'EVENT_SCRIPT_MODULE_ON_CLIENT_ENTER',           version: 'ee' },
  { label: 'Module: On client leave',       nwscript: 'EVENT_SCRIPT_MODULE_ON_CLIENT_EXIT',            version: 'ee' },
  { label: 'Module: On cutscene abort',     nwscript: 'EVENT_SCRIPT_MODULE_ON_CUTSCENE_ABORT',         version: 'ee' },
  { label: 'Module: On equip item',         nwscript: 'EVENT_SCRIPT_MODULE_ON_EQUIP_ITEM',             version: 'ee' },
  { label: 'Module: On heartbeat',          nwscript: 'EVENT_SCRIPT_MODULE_ON_HEARTBEAT',              version: 'ee' },
  { label: 'Module: On load',               nwscript: 'EVENT_SCRIPT_MODULE_ON_MODULE_LOAD',            version: 'ee' },
  { label: 'Module: On module start',       nwscript: 'EVENT_SCRIPT_MODULE_ON_MODULE_START',           version: 'ee' },
  { label: 'Module: On NUI event [EE]',     nwscript: 'EVENT_SCRIPT_MODULE_ON_NUI_EVENT',              version: 'ee' },
  { label: 'Module: On player death',       nwscript: 'EVENT_SCRIPT_MODULE_ON_PLAYER_DEATH',           version: 'ee' },
  { label: 'Module: On player dying',       nwscript: 'EVENT_SCRIPT_MODULE_ON_PLAYER_DYING',           version: 'ee' },
  { label: 'Module: On player GUI event [EE]',nwscript: 'EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT',      version: 'ee' },
  { label: 'Module: On player level up',    nwscript: 'EVENT_SCRIPT_MODULE_ON_PLAYER_LEVEL_UP',        version: 'ee' },
  { label: 'Module: On player respawn',     nwscript: 'EVENT_SCRIPT_MODULE_ON_RESPAWN_BUTTON_PRESSED', version: 'ee' },
  { label: 'Module: On player rest',        nwscript: 'EVENT_SCRIPT_MODULE_ON_PLAYER_REST',            version: 'ee' },
  { label: 'Module: On player target [EE]', nwscript: 'EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET',          version: 'ee' },
  { label: 'Module: On player tile action [EE]',nwscript:'EVENT_SCRIPT_MODULE_ON_PLAYER_TILE_ACTION',  version: 'ee' },
  { label: 'Module: On unacquire item',     nwscript: 'EVENT_SCRIPT_MODULE_ON_LOSE_ITEM',              version: 'ee' },
  { label: 'Module: On unequip item',       nwscript: 'EVENT_SCRIPT_MODULE_ON_UNEQUIP_ITEM',           version: 'ee' },
  { label: 'Module: On user defined',       nwscript: 'EVENT_SCRIPT_MODULE_ON_USER_DEFINED_EVENT',     version: 'ee' },
  // Placeable events
  { label: 'Placeable: On attacked',        nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_ATTACKED',            version: 'ee' },
  { label: 'Placeable: On click',           nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_CLICK',               version: 'ee' },
  { label: 'Placeable: On closed',          nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_CLOSED',              version: 'ee' },
  { label: 'Placeable: On damaged',         nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_DAMAGED',             version: 'ee' },
  { label: 'Placeable: On death',           nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_DEATH',               version: 'ee' },
  { label: 'Placeable: On disturbed',       nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_DISTURBED',           version: 'ee' },
  { label: 'Placeable: On heartbeat',       nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT',           version: 'ee' },
  { label: 'Placeable: On lock',            nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_LOCK',                version: 'ee' },
  { label: 'Placeable: On opened',          nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_OPEN',                version: 'ee' },
  { label: 'Placeable: On spell cast at',   nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT',         version: 'ee' },
  { label: 'Placeable: On unlock',          nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_UNLOCK',              version: 'ee' },
  { label: 'Placeable: On used',            nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_USED',                version: 'ee' },
  { label: 'Placeable: On user defined',    nwscript: 'EVENT_SCRIPT_PLACEABLE_ON_USER_DEFINED',        version: 'ee' },
  // Store events
  { label: 'Store: On open',                nwscript: 'EVENT_SCRIPT_STORE_ON_OPEN',                    version: 'ee' },
  { label: 'Store: On close',               nwscript: 'EVENT_SCRIPT_STORE_ON_CLOSE',                   version: 'ee' },
  // Trigger events
  { label: 'Trigger: On click',             nwscript: 'EVENT_SCRIPT_TRIGGER_ON_CLICKED',               version: 'ee' },
  { label: 'Trigger: On disarm',            nwscript: 'EVENT_SCRIPT_TRIGGER_ON_DISARMED',              version: 'ee' },
  { label: 'Trigger: On enter',             nwscript: 'EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER',          version: 'ee' },
  { label: 'Trigger: On exit',              nwscript: 'EVENT_SCRIPT_TRIGGER_ON_OBJECT_EXIT',           version: 'ee' },
  { label: 'Trigger: On heartbeat',         nwscript: 'EVENT_SCRIPT_TRIGGER_ON_HEARTBEAT',             version: 'ee' },
  { label: 'Trigger: On trap triggered',    nwscript: 'EVENT_SCRIPT_TRIGGER_ON_TRAPTRIGGERED',         version: 'ee' },
  { label: 'Trigger: On user defined',      nwscript: 'EVENT_SCRIPT_TRIGGER_ON_USER_DEFINED_EVENT',    version: 'ee' },
];

// =============================================================================
// EE-ONLY: OBJECT_VISUAL_TRANSFORM_*
// =============================================================================

/**
 * EE only. Used with SetObjectVisualTransform(oObject, nTransform, fValue).
 */
export const OBJECT_VISUAL_TRANSFORM = [
  { label: 'Scale (uniform)',    nwscript: 'OBJECT_VISUAL_TRANSFORM_SCALE',           version: 'ee' },
  { label: 'Rotate X',          nwscript: 'OBJECT_VISUAL_TRANSFORM_ROTATE_X',        version: 'ee' },
  { label: 'Rotate Y',          nwscript: 'OBJECT_VISUAL_TRANSFORM_ROTATE_Y',        version: 'ee' },
  { label: 'Rotate Z',          nwscript: 'OBJECT_VISUAL_TRANSFORM_ROTATE_Z',        version: 'ee' },
  { label: 'Translate X',       nwscript: 'OBJECT_VISUAL_TRANSFORM_TRANSLATE_X',     version: 'ee' },
  { label: 'Translate Y',       nwscript: 'OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y',     version: 'ee' },
  { label: 'Translate Z',       nwscript: 'OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z',     version: 'ee' },
  { label: 'Animation speed',   nwscript: 'OBJECT_VISUAL_TRANSFORM_ANIMATE_PLAY_SPEED', version: 'ee' },
];

// =============================================================================
// EE-ONLY: EFFECT_ICON_*
// =============================================================================

/**
 * EE only (added 1.84). Used with EffectIcon(nIcon).
 * Values are rows in effecticons.2da.
 */
export const EFFECT_ICON = [
  { label: 'Haste',              nwscript: 'EFFECT_ICON_HASTE',              version: 'ee' },
  { label: 'Slow',               nwscript: 'EFFECT_ICON_SLOW',               version: 'ee' },
  { label: 'Poison',             nwscript: 'EFFECT_ICON_POISON',             version: 'ee' },
  { label: 'Disease',            nwscript: 'EFFECT_ICON_DISEASE',            version: 'ee' },
  { label: 'Blindness',          nwscript: 'EFFECT_ICON_BLINDNESS',          version: 'ee' },
  { label: 'Deafness',           nwscript: 'EFFECT_ICON_DEAFNESS',           version: 'ee' },
  { label: 'Sleep',              nwscript: 'EFFECT_ICON_SLEEP',              version: 'ee' },
  { label: 'Paralysis',          nwscript: 'EFFECT_ICON_PARALYSIS',          version: 'ee' },
  { label: 'Petrify',            nwscript: 'EFFECT_ICON_PETRIFY',            version: 'ee' },
  { label: 'Dazed',              nwscript: 'EFFECT_ICON_DAZED',              version: 'ee' },
  { label: 'Confusion',          nwscript: 'EFFECT_ICON_CONFUSION',          version: 'ee' },
  { label: 'Fear',               nwscript: 'EFFECT_ICON_FEAR',               version: 'ee' },
  { label: 'Doom',               nwscript: 'EFFECT_ICON_DOOM',               version: 'ee' },
  { label: 'Curse',              nwscript: 'EFFECT_ICON_CURSE',              version: 'ee' },
  { label: 'Silence',            nwscript: 'EFFECT_ICON_SILENCE',            version: 'ee' },
  { label: 'Stun',               nwscript: 'EFFECT_ICON_STUNNED',            version: 'ee' },
  { label: 'Entangle',           nwscript: 'EFFECT_ICON_ENTANGLE',           version: 'ee' },
  { label: 'Knockdown',          nwscript: 'EFFECT_ICON_KNOCKDOWN',          version: 'ee' },
  { label: 'Negative level',     nwscript: 'EFFECT_ICON_NEGATIVELEVEL',      version: 'ee' },
  { label: 'True seeing',        nwscript: 'EFFECT_ICON_TRUESEEING',         version: 'ee' },
  { label: 'See invisible',      nwscript: 'EFFECT_ICON_SEEINVISIBLE',       version: 'ee' },
  { label: 'Invisibility',       nwscript: 'EFFECT_ICON_INVISIBILITY',       version: 'ee' },
  { label: 'Ethereal',           nwscript: 'EFFECT_ICON_ETHEREAL',           version: 'ee' },
  { label: 'Regenerate',         nwscript: 'EFFECT_ICON_REGENERATE',         version: 'ee' },
  { label: 'Haste (spell)',      nwscript: 'EFFECT_ICON_SPELLHASTE',         version: 'ee' },
  // Note: full list in effecticons.2da — many rows are unused/invalid (shown orange in Lexicon)
  // Additional entries can be added by row number as numeric strings
];

// =============================================================================
// HELPER: Filter by version
// =============================================================================

/**
 * Returns only base-game (1.69) entries from any array.
 * @param {Array} arr - Any constant array from this module.
 */
export function baseOnly(arr) {
  return arr.filter(e => !e.version || e.version === 'base');
}

/**
 * Returns all entries including EE additions.
 * @param {Array} arr - Any constant array from this module.
 */
export function allVersions(arr) {
  return arr;
}

/**
 * Returns only EE-specific entries.
 * @param {Array} arr - Any constant array from this module.
 */
export function eeOnly(arr) {
  return arr.filter(e => e.version === 'ee');
}

// =============================================================================
// HELPER: NWNLexicon URL
// =============================================================================

/**
 * Returns the NWNLexicon URL for a given NWScript function or constant name.
 * @param {string} name - e.g. 'ApplyEffectToObject' or 'EFFECT_TYPE_HASTE'
 */
export function lexiconUrl(name) {
  return `https://nwnlexicon.com/index.php?title=${encodeURIComponent(name)}`;
}

/**
 * Wraps all known NWScript function names in a code string with <a> links
 * to the NWNLexicon. Use when rendering the generated script in the output panel.
 * @param {string} code - Raw NWScript code string.
 * @returns {string} HTML string with function names wrapped in <a> tags.
 */
export function linkifyNWScript(code) {
  // Match capitalized function names that look like NWScript built-ins
  return code.replace(
    /\b([A-Z][a-zA-Z0-9]+(?:Command|Effect|Object|Creature|Item|Script|PC|Action|Event|Assign|Apply|Create|Destroy|Get|Set|Add|Remove|Jump|Send|Float|Play|Adjust|Signal|Execute|Speak|Pop|Push|Clear|Has|Is|Can|Make|Give|Take|Open|Close|Lock|Unlock|Face|Move|Do|Check|Find|Random|String|Int|Float|Vector|Location|Talent|Feat|Skill|Spell|Class|Race|Align|Hostile|Enemy|Faction|Inventory|Equip|Unequip|Store|Merchant|Portal|Trigger|Trap|Mine|Door|Area|Module|Ambient|Music|Weather|Time|Day|Month|Year|Hour|Minute|Second|Calendar|Campaign|Local|Database|Json|Regexp|Post|Nui|Sql|Cassowary)\w*)\b/g,
    (fn) => `<a href="${lexiconUrl(fn)}" target="_blank" rel="noopener">${fn}</a>`
  );
}
