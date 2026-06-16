# PCGen → Roll20: Quick Import Guide

Move your PCGen character into the Roll20 Pathfinder Community sheet in 4 steps.

## One-time setup

1. Grab the template file `csheet_roll20_pf_community.json.ftl`.
2. Drop it into your PCGen folder:
   `…\PCGen\outputsheets\d20\fantasy\htmlxml\`
3. Restart PCGen.

## Every character

1. **In PCGen:** load your character, then go to
   **File → Export → Standard**.
2. Pick **csheet_roll20_pf_community** from the list and **Export** it.
   Save somewhere easy to find.
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

## Check these after import

A quick once-over to confirm it worked. Compare against your PCGen sheet:

- **Core tab:** ability scores, HP, AC (Total / Touch / Flat-Footed), saves
  (Fort/Ref/Will), initiative, and BAB/CMB/CMD.
- **Skills:** a couple of your trained skills show the right totals, and class
  skills are flagged.
- **Combat/Inventory:** your weapons show the right damage and crit, worn armor
  and shield show their AC bonus, and item counts look right.
- **Feats & Abilities:** your feats and traits are present.
- **Spells (casters only):** the spellcasting class appears with the right caster
  level, spells per day, and concentration, and your spells are listed with the
  correct level, school, and save DC.

## If something didn't import correctly

Send us these three things so we can reproduce it:

1. **The PCGen export file** you pasted (the `.json` you generated). This is the
   single most useful item — it's exactly what the importer received.
2. **What's wrong, specifically:** the field/section, what it shows, and what it
   should show (e.g. "Reflex save shows +4, should be +6"). A screenshot of the
   sheet area is great.
3. **A saved copy of the sheet** (optional but helpful): in your browser, with the
   character sheet popped out of roll 20, use **File → Save Page As → Web Page, Complete**, and
   send the resulting `.htm` file. This captures the actual values that landed.

Also note your **PCGen version** and the character's **class/level** (especially
if it's a multiclass or prestige caster), since those affect how data exports.

