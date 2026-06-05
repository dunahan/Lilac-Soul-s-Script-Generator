# NWN Script Generator — Web Port

A browser-based NWScript code generator for **Neverwinter Nights 1** (including Enhanced Edition), ported from [Lilac Soul's Script Generator](https://github.com/dunahan/Lilac-Soul-s-Script-Generator) (Pascal/Lazarus) to a standalone HTML/JavaScript web application.

## Features

- **No installation required** — open `index.html` directly in any modern browser
- **No backend, no server** — fully client-side, works offline (except Google Fonts)
- **18 action modules** covering the most common NWScript patterns:
  - Journal entry, teleport, local variables, floating text
  - Apply / remove effects, damage, visual effects
  - Spawn creature, destroy object, lock/unlock
  - Henchman management, alignment/reputation adjustment
  - Sound & music, NPC speak, cast spell
  - Give XP/gold, create/destroy items, set appearance, delay command
- **22 script event types** — OnEnter, OnDeath, OnConversation, OnActivateItem, and many more
- **NWN:EE compatible** — constants extended with Enhanced Edition additions
- **Live code generation** with NWScript syntax highlighting
- **NWNLexicon links** — every function name links to [nwnlexicon.com](https://nwnlexicon.com)
- **Export as `.nss`** — download the generated script directly
- **Collapsible UI** — script type groups and action modules fold away to save space

## Usage

1. Download or clone this repository
2. Open `index.html` in your browser — no server needed
3. Select a **Script Type** in the left panel (e.g. *OnEnter*, *OnConversation*)
4. Add **Action Modules** from the palette (e.g. *Journal Entry*, *Teleport PC*)
5. Configure each module — the script generates live in the right panel
6. Click **↓ .nss** to download, or **Copy** to paste into the NWN Toolset

## Project Structure

```
nwn-scriptgen/
├── index.html                  # Main application (self-contained)
├── js/
│   ├── constants.js            # Core NWScript constants + EE additions
│   ├── constants_large.js      # SPELL, FEAT, SPELLABILITY, TRACK, POLYMORPH, POISON
│   ├── constants_vfx.js        # VFX_DURATION (381), VFX_IMPACT (229)
│   └── constants_appearance.js # APPEARANCE types (518 entries)
├── docs/
├── LICENSE
└── README.md
```

> **Note:** The JS files in `js/` are extracted from `constants.pas` for reference and
> future use. The current `index.html` is fully self-contained and does not import them
> yet — integration is planned for a future refactoring step.

## Roadmap

- [ ] Import `constants.js` modules into `index.html` (replace inline data)
- [ ] Conditional checks (`ifinspector.pas` — class, race, skill, item, journal, alignment)
- [ ] Cutscene module (`cutscene.pas`)
- [ ] Trap creation (`traps.pas`)
- [ ] Blacksmith crafting system (`black_smith.pas`)
- [ ] Action queue chaining (`actionqueue.pas`)
- [ ] Store PC info to local variables (`storepcparty.pas`)
- [ ] Item property scripting (`itemscript.pas`)
- [ ] Color / creature part editor (`colorc.pas`)
- [ ] Horse/mount module (`horsemount.pas`)
- [ ] GitHub Pages deployment
- [ ] Dark/light theme toggle

## Credits

- **Original tool:** [Lilac Soul's Script Generator](https://neverwintervault.org/project/nwn1/other/tool/lilac-souls-nwn-script-generator) by Carsten Hjorthøj (Lilac Soul)
- **NWN 1.69 revision:** [The Krit](https://github.com/dunahan/Lilac-Soul-s-Script-Generator)
- **NWScript reference:** [NWN Lexicon](https://nwnlexicon.com) contributors
- **Web port:** developed with Claude (Anthropic)

## License

GPL-2.0 — inherited from the original Lilac Soul's Script Generator.
See [LICENSE](LICENSE) for details.
