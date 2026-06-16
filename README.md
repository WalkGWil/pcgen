# PCGen → Roll20 Pathfinder Community Sheet Importer

A PCGen output-sheet template that exports a character as JSON in the exact shape
the Roll20 **Pathfinder Community** sheet's built-in *HeroLab Character Import*
already accepts. This lets you move PCGen characters into Roll20 through the
sheet's existing, unmodified importer — no sheet changes required.

## How it works

The Roll20 Pathfinder Community sheet ships with a HeroLab importer
(`HLImport.js`) that reads a JSON object (`document.public.character...`) from a
text box and fills in the sheet. Instead of forking that importer, this project
makes PCGen emit JSON in the same shape, so the stock importer does all the work.

```
PCGen character ──(this template)──► JSON ──(paste)──► Roll20 HeroLab Import box
```

## Files

| File | Purpose |
|------|---------|
| `csheet_roll20_pf_community.json.ftl` | The PCGen FreeMarker export template (the deliverable) |
| `HOW-TO (Players).md` | Short player-facing quick-start |
| `dev/` | Verification harness that runs the real importer against generated JSON |

## Install & use

1. Copy `csheet_roll20_pf_community.json.ftl` into your PCGen output sheets:
   `<PCGen>/outputsheets/d20/fantasy/htmlxml/`
2. In PCGen: load a character, **File → Export → Standard**, pick
   `csheet_roll20_pf_community`, export to a `.json` file (rename from `.htm` if needed).
3. Open the file, copy all of it.
4. In Roll20: character sheet **Settings** tab → expand **HeroLab Character
   Import** → paste → click outside the box.

See `HOW-TO (Players).md` for the condensed version to hand to players.

## What imports

- Identity, ability scores, saves, BAB, CMB/CMD, initiative, AC (incl. equipped
  armor and shields)
- Skills (with class-skill, ability, and ranks), feats, traits
- Inventory with weights, costs, quantities, descriptions, weapon damage/crit,
  armor/shield AC
- HP, speed, languages, money, encumbrance, alignment, deity, bio
- Spellcasters: spellclass, caster level, spells/day, concentration, and the full
  spell list (school, components, DC, range, duration, description). Validated on
  single-class casters and a multiclass + prestige caster (Evoker/Rogue/Arcane
  Trickster).

## Known limitations

- **Equip Type & Location** import as uncategorized / Carried. The stock importer
  has no field for these, so they're set manually after import.
- **Wizards** import their entire spellbook (can be 100+ spells at high level).
- Special abilities / class features beyond feats and traits are not yet mapped.

## Verifying changes (dev)

The `dev/` harness runs the **real** `HLImport.js` against generated JSON so you
can confirm a character maps correctly before touching Roll20. See `dev/README.md`.

## Credits

Reuses the Roll20 Pathfinder Community sheet's HeroLab importer
(`HLImport.js`, not redistributed here). Built against PCGen's FreeMarker output
token set.
