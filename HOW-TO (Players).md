# PCGen → Roll20: Quick Import Guide

Move your PCGen character into the Roll20 Pathfinder Community sheet in 4 steps.

## One-time setup

1. Grab the template file `csheet_roll20_pf_community.json.ftl` (ask your GM).
2. Drop it into your PCGen folder:
   `…\PCGen\outputsheets\d20\fantasy\htmlxml\`
3. Restart PCGen.

## Every character

1. **In PCGen:** load your character, then go to
   **File → Export → Standard**.
2. Pick **csheet_roll20_pf_community** from the list and **Export** it.
   Save as something like `MyHero.json` (if it saves as `.htm`, just rename it).
3. Open that file in Notepad, press **Ctrl+A** then **Ctrl+C** to copy everything.
4. **In Roll20:** open your character sheet → **Settings** tab →
   expand **HeroLab Character Import** → paste into the box → click anywhere
   outside the box.

Done. Your stats, skills, saves, feats, gear, and bio fill in automatically.

## Good to know

- You'll set each item's **Equip Type** and **Location** by hand (the importer
  doesn't carry those over).
- Spells import automatically for spellcasters (Wizards bring their whole
  spellbook, which can be a long list).
- Re-importing overwrites the sheet, so do it before you start customizing.
