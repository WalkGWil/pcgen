<#ftl encoding="UTF-8" strip_whitespace=true>
<#--
================================================================================
  Roll20 Pathfinder Community Sheet - PCGen Export Template
================================================================================
  Emits JSON in the SAME shape the sheet's built-in "HeroLab Character Import"
  already consumes (document.public.character...), so PCGen characters import
  through the existing, unmodified Roll20 importer (HLImport.js).

  INSTALL  : copy into <PCGen>/outputsheets/d20/fantasy/htmlxml/
  EXPORT   : File > Export > Standard > pick this template > save .json
  IMPORT   : Roll20 sheet Settings > HeroLab Character Import > paste
================================================================================
-->
<#function j s>
  <#local t = s!"">
  <#local t = t?replace("\\", "\\\\")>
  <#local t = t?replace("\"", "\\\"")>
  <#local t = t?replace("\r", "")>
  <#local t = t?replace("\n", "\\n")>
  <#local t = t?replace("\t", " ")>
  <#return t>
</#function>
<#function p token>
  <#return j(pcstring(token))>
</#function>
<#function clean s>
  <#local t = s!"">
  <#list ["*", "#", "+"] as mark>
    <#list 1..3 as n>
      <#if t?starts_with(mark)><#local t = t?substring(1)></#if>
    </#list>
  </#list>
  <#return j(t?trim)>
</#function>
<#function num s>
  <#local t = (s!"")?replace("[^0-9\\.\\-].*$", "", "r")>
  <#return (t == "")?then("0", t)>
</#function>
<#-- Strip "(archetype)" parentheticals from a class name and JSON-escape. -->
<#function bare s>
  <#local t = s!"">
  <#if t?contains("(")><#local t = t?substring(0, t?index_of("("))></#if>
  <#return j(t?trim)>
</#function>
<#-- Normalize PCGen range text ("Close (35 ft.)", "Medium (140 ft.)", "Touch",
     "Personal") to the exact strings the importer's range switch expects.
     Other ranges (e.g. "20 ft.") pass through and the importer treats them as a
     literal number. -->
<#function range s>
  <#local t = (s!"")?lower_case>
  <#if t?starts_with("close")><#return "close (25 + 5 ft./2 levels)">
  <#elseif t?starts_with("medium")><#return "medium (100 + 10 ft./level)">
  <#elseif t?starts_with("long")><#return "long (400 + 40 ft./level)">
  <#elseif t?starts_with("touch")><#return "touch">
  <#elseif t?starts_with("personal")><#return "personal">
  <#else><#return j(s!"")>
  </#if>
</#function>
<#assign isPC = (pcstring('CHARACTERTYPE') != "NPC")>
<#assign role = isPC?then("pc", "npc")>
<#assign dexMod = pcvar('STAT.1.MOD')>
<#assign cmdVal = pcvar('VAR.CMD.INTVAL')>
<#assign dodgeVal = pcvar('AC.Dodge')>
<#assign ffCmd = cmdVal - ((dexMod > 0)?then(dexMod, 0)) - dodgeVal>
<#assign hitDiceClean = j(pcstring('HITDICE')?replace("(", "")?replace(")", ""))>
{
"document": {
"public": {
"character": {
  "_name": "${p('NAME')}",
  "_playername": "${p('PLAYERNAME')}",
  "_role": "${role}",
  "attributes": {
    "attribute": [
<@loop from=0 to=pcvar('COUNT[STATS]-1') ; stat, stat_has_next>
      {
        "_name": "${p('STAT.${stat}.LONGNAME')}",
        "attrvalue": { "_base": "${p('STAT.${stat}.NOTEMP.NOEQUIP')}", "_modified": "${p('STAT.${stat}')}" },
        "attrbonus": { "_modified": "${p('STAT.${stat}.MOD')}" }
      }<#if stat_has_next>,</#if>
</@loop>
    ]
  },
  "saves": {
    "allsaves": { "situationalmodifiers": { "_text": "" } },
    "save": [
<@loop from=0 to=pcvar('COUNT[CHECKS]-1') ; check, check_has_next>
      {
        "_abbr": "${p('CHECK.${check}.NAME')}",
        "_save": "${p('CHECK.${check}.TOTAL')}",
        "_base": "${p('CHECK.${check}.BASE')}",
        "_fromresist": "0",
        "_fromattr": "${p('CHECK.${check}.STATMOD')}",
        "situationalmodifiers": { "_text": "" }
      }<#if check_has_next>,</#if>
</@loop>
    ]
  },
  "classes": {
    "_level": "${p('TOTALLEVELS')}",
    "class": [
<#assign firstClass = true>
<#assign spellRace = pcvar('COUNT[SPELLRACE]')>
<@loop from=0 to=pcvar('COUNT[CLASSES]-1') ; class, class_has_next>
<#if (pcvar(pcstring('CLASS.${class}.LEVEL')) > 0)>
<#if !firstClass>,</#if><#assign firstClass = false>
<#-- PCGen indexes spell lists separately from classes, offset by the number of
     racial spell lists. The spell list for CLASS.n lives at SPELLLISTCLASS.(n+spellRace). -->
<#assign slIdx = class + spellRace>
      {
        "_name": "${p('CLASS.${class}')}",
        "_level": "${p('CLASS.${class}.LEVEL')}",
<#if (pcvar('SPELLLISTCLASS.${slIdx}.LEVEL') > 0)>
        "_casterlevel": "${num(pcstring('SPELLLISTCLASS.${slIdx}.CASTERLEVEL'))}",
        "_basespelldc": "${num(pcstring('SPELLLISTDC.${slIdx}.0'))}",
        "_concentrationcheck": "${num(pcstring('SPELLLISTCLASS.${slIdx}.CONCENTRATION'))}"
<#else>
        "_casterlevel": "0"
</#if>
      }
</#if>
</@loop>
    ]
  },
  "spellclasses": {
    "spellclass": [
<#assign firstSC = true>
<@loop from=0 to=pcvar('COUNT[CLASSES]-1') ; class, class_has_next>
<#assign slIdx = class + spellRace>
<#if (pcvar(pcstring('CLASS.${class}.LEVEL')) > 0) && (pcvar('SPELLLISTCLASS.${slIdx}.LEVEL') > 0)>
<#if !firstSC>,</#if><#assign firstSC = false>
      {
        "_name": "${p('CLASS.${class}')}",
        "spelllevel": [
<#assign firstLvl = true>
<@loop from=0 to=pcvar('MAXSPELLLEVEL.${slIdx}') ; lvl, lvl_has_next>
<#if !firstLvl>,</#if><#assign firstLvl = false>
          { "_level": "${lvl}", "_maxcasts": "${num(pcstring('SPELLLISTCAST.${slIdx}.${lvl}'))}" }
</@loop>
        ]
      }
</#if>
</@loop>
    ]
  },
  "spellsknown": {
    "spell": [
<#assign firstSpell = true>
<@loop from=0 to=pcvar('COUNT[CLASSES]-1') ; class, class_has_next>
<#assign slIdx = class + spellRace>
<#if (pcvar(pcstring('CLASS.${class}.LEVEL')) > 0) && (pcvar('SPELLLISTCLASS.${slIdx}.LEVEL') > 0)>
<#assign scName = p('CLASS.${class}')>
<@loop from=0 to=pcvar('MAXSPELLLEVEL.${slIdx}') ; lvl, lvl_has_next>
<@loop from=0 to=pcvar('COUNT[SPELLSINBOOK.${slIdx}.0.${lvl}]-1') ; sp, sp_has_next>
<#assign base = 'SPELLMEM.${slIdx}.0.${lvl}.${sp}'>
<#if !firstSpell>,</#if><#assign firstSpell = false>
      {
        "_name": "${p('${base}.NAME')}",
        "_level": "${lvl}",
        "_class": "${scName}",
        "_componenttext": "${p('${base}.COMPONENTS')}",
        "_duration": "${p('${base}.DURATION')}",
        "_save": "${p('${base}.SAVEINFO')}",
        "_dc": "${num(pcstring('${base}.DC'))}",
        "_casttime": "${p('${base}.CASTINGTIME')}",
        "_casterlevel": "${num(pcstring('${base}.CASTERLEVEL'))}",
        "_resist": "${p('${base}.SR')}",
        "_range": "${range(pcstring('${base}.RANGE'))}",
        "_area": "",
        "_effect": "${p('${base}.EFFECT')}",
        "_target": "${p('${base}.TARGET')}",
        "_schooltext": "${p('${base}.SCHOOL')}",
        "_subschooltext": "${p('${base}.SUBSCHOOL')}",
        "_descriptortext": "${p('${base}.DESCRIPTOR')}",
        "description": "${p('${base}.DESCRIPTION')}"
      }
</@loop>
</@loop>
</#if>
</@loop>
    ]
  },
  "spellbook": {},
  "spellsmemorized": {},
  "penalties": {
    "penalty": [
      { "_name": "Armor Check Penalty", "_value": "${p('ACCHECK')}" },
      { "_name": "Max Dex Bonus", "_value": "${p('MAXDEX')}" }
    ]
  },
  "armorclass": {
    "_ac": "${p('AC.Total')}",
    "_touch": "${p('AC.Touch')}",
    "_flatfooted": "${p('AC.Flatfooted')}",
    "_fromnatural": "${p('AC.NaturalArmor')}",
    "_fromdeflect": "${p('AC.Deflection')}",
    "_fromdodge": "${p('AC.Dodge')}",
    "_fromarmor": "${p('AC.Armor')}",
    "_fromshield": "${p('AC.Shield')}",
    "_fromsize": "${p('AC.Size')}",
    "_fromdexterity": "${p('AC.Ability')}",
    "_fromcharisma": "",
    "_fromwisdom": ""
  },
  "defenses": {
    "armor": [
<#assign firstArmor = true>
<#-- Body armor -->
<@loop from=0 to=pcvar('COUNT[EQTYPE.Armor]-1') ; armor, armor_has_next>
<#if !firstArmor>,</#if><#assign firstArmor = false>
      {
        "_name": "${clean(pcstring('EQTYPE.Armor.${armor}.NAME'))}",
        "_ac": "${p('EQTYPE.Armor.${armor}.ACMOD')}",
        "_equipped": "<#if pcstring('EQTYPE.Armor.${armor}.LOCATION')?lower_case?contains('equipped')>yes<#else>no</#if>"
      }
</@loop>
<#-- Shields: HeroLab lists shields in the armor array too; the importer's
     nameIsShield() routes "buckler"/"shield"/"klar" to the shield3 slot. -->
<@loop from=0 to=pcvar('COUNT[EQTYPE.SHIELD]-1') ; shld, shld_has_next>
<#if !firstArmor>,</#if><#assign firstArmor = false>
      {
        "_name": "${clean(pcstring('ARMOR.SHIELD.ALL.${shld}.NAME'))}",
        "_ac": "${num(pcstring('ARMOR.SHIELD.ALL.${shld}.ACBONUS'))}",
        "_equipped": "<#if pcstring('ARMOR.SHIELD.ALL.${shld}.LOCATION')?lower_case?contains('equipped')>yes<#else>no</#if>"
      }
</@loop>
    ],
    "special": []
  },
  "melee": {
    "weapon": [
<#assign firstMw = true>
<@loop from=0 to=pcvar('COUNT[EQTYPE.Weapon]-1') ; weap, weap_has_next>
<#assign wcat = pcstring('WEAPON.${weap}.CATEGORY')?lower_case>
<#if !(wcat?contains('ranged'))>
<#if !firstMw>,</#if><#assign firstMw = false>
      {
        "_name": "${clean(pcstring('WEAPON.${weap}.NAME'))}",
        "_damage": "${p('WEAPON.${weap}.DAMAGE')}",
        "_crit": "${p('WEAPON.${weap}.CRIT')}/x${p('WEAPON.${weap}.MULT')}",
        "_typetext": "${p('WEAPON.${weap}.TYPE')}"
      }
</#if>
</@loop>
    ]
  },
  "ranged": {
    "weapon": [
<#assign firstRw = true>
<@loop from=0 to=pcvar('COUNT[EQTYPE.Weapon]-1') ; weap, weap_has_next>
<#assign wcat = pcstring('WEAPON.${weap}.CATEGORY')?lower_case>
<#if (wcat?contains('ranged'))>
<#if !firstRw>,</#if><#assign firstRw = false>
      {
        "_name": "${clean(pcstring('WEAPON.${weap}.NAME'))}",
        "_damage": "${p('WEAPON.${weap}.DAMAGE')}",
        "_crit": "${p('WEAPON.${weap}.CRIT')}/x${p('WEAPON.${weap}.MULT')}",
        "_typetext": "${p('WEAPON.${weap}.TYPE')}",
        "rangedattack": { "_rangeincvalue": "${num(pcstring('WEAPON.${weap}.RANGE'))}" }
      }
</#if>
</@loop>
    ]
  },
  "trackedresources": { "trackedresource": [] },
  "magicitems": { "item": [] },
  "gear": {
    "item": [
<#assign firstItem = true>
<@loop from=0 to=(pcvar("COUNT[EQUIPMENT.NOT.Coin.NOT.Gem.NOT.Temporary]")-1) ; equip, equip_has_next>
<#if !firstItem>,</#if><#assign firstItem = false>
      {
        "_name": "${clean(pcstring('EQ.NOT.Coin.NOT.Gem.NOT.Temporary.${equip}.NAME'))}",
        "_quantity": "${p('EQ.NOT.Coin.NOT.Gem.NOT.Temporary.${equip}.QTY')}",
        "weight": { "_value": "${num(pcstring('EQ.NOT.Coin.NOT.Gem.NOT.Temporary.${equip}.WT'))}" },
        "cost": { "_value": "${num(pcstring('EQ.NOT.Coin.NOT.Gem.NOT.Temporary.${equip}.COST'))}" },
        "description": "${p('EQ.NOT.Coin.NOT.Gem.NOT.Temporary.${equip}.DESC')}"
      }
</@loop>
    ]
  },
  "attack": {
    "_baseattack": "${p('ATTACK.MELEE.BASE')}",
    "_meleeattack": "${p('ATTACK.MELEE.TOTAL')}",
    "_rangedattack": "${p('ATTACK.RANGED.TOTAL')}",
    "special": []
  },
  "otherspecials": { "special": [] },
  "movement": {
    "speed": { "_value": "${num(pcstring('MOVE.0.RATE'))}" },
    "special": []
  },
  "defensive": { "special": [] },
  "feats": {
    "feat": [
<@loop from=0 to=pcvar('COUNT[FEATS.VISIBLE]-1') ; feat, feat_has_next>
      {
        "_name": "${p('FEAT.VISIBLE.${feat}')}",
        "description": "${p('FEAT.VISIBLE.${feat}.DESC')}"
      }<#if feat_has_next>,</#if>
</@loop>
    ]
  },
  "traits": {
    "trait": [
<@loop from=0 to=pcvar('countdistinct("ABILITIES","CATEGORY=Special Ability","TYPE=Trait")-1') ; trait, trait_has_next>
      {
        "_name": "${p('ABILITYALL.Special Ability.${trait}.TYPE=Trait')}",
        "description": "${p('ABILITYALL.Special Ability.${trait}.TYPE=Trait.DESC')}"
      }<#if trait_has_next>,</#if>
</@loop>
    ]
  },
  "spelllike": { "special": [] },
  "xp": { "_total": "${p('EXP.CURRENT')}" },
  "initiative": {
    "_total": "${p('INITIATIVEMOD')}",
    "_attrtext": "${p('STAT.1.MOD')}",
    "_attrname": "Dexterity",
    "situationalmodifiers": { "_text": "" }
  },
  "health": {
    "_hitpoints": "${p('HP')}",
    "_hitdice": "${hitDiceClean}"
  },
  "size": { "_name": "${p('SIZELONG')}" },
  "skills": {
    "skill": [
<@loop from=0 to=pcvar('count("SKILLSIT", "VIEW=VISIBLE_EXPORT")')-1 ; skill, skill_has_next>
      {
        "_name": "${p('SKILLSIT.${skill}')}",
        "_value": "${p('SKILLSIT.${skill}.TOTAL')}",
        "_ranks": "${pcstring('SKILLSIT.${skill}.RANK')?replace('.0','')}",
        "_attrname": "${p('SKILLSIT.${skill}.ABILITY')}",
        "_attrbonus": "${p('SKILLSIT.${skill}.ABMOD')}",
        "_classskill": "<#if pcstring('SKILLSIT.${skill}.EXPLAIN_LONG')?contains('cskill')>yes<#else>no</#if>",
        "_armorcheck": "no",
        "_trainedonly": "<#if (pcstring('SKILLSIT.${skill}.UNTRAINED') == 'N')>yes<#else>no</#if>",
        "situationalmodifiers": {}
      }<#if skill_has_next>,</#if>
</@loop>
    ]
  },
  "senses": { "special": [] },
  "damagereduction": { "special": [] },
  "resistances": { "special": [] },
  "immunities": { "special": [] },
  "weaknesses": { "special": [] },
  "languages": {
    "language": [
<@loop from=0 to=pcvar('COUNT[LANGUAGES]-1') ; lang, lang_has_next>
      { "_name": "${p('LANGUAGES.${lang}')}" }<#if lang_has_next>,</#if>
</@loop>
    ]
  },
  "types": { "type": { "_name": "${p('RACETYPE')}" } },
<#if (pcvar('COUNT[RACESUBTYPE]') > 0)>
  "subtypes": {
    "subtype": [
<@loop from=0 to=pcvar('COUNT[RACESUBTYPE]-1') ; rst, rst_has_next>
      { "_name": "${p('RACESUBTYPE.${rst}')}" }<#if rst_has_next>,</#if>
</@loop>
    ]
  },
<#else>
  "subtypes": {},
</#if>
  "deity": { "_name": "${p('DEITY')}" },
  "race": { "_racetext": "${p('RACE')}" },
  "alignment": { "_name": "${p('ALIGNMENT')}" },
  "personal": {
    "_gender": "${p('GENDER.LONG')}",
    "_age": "${p('AGE')}",
    "charheight": { "_text": "${p('HEIGHT')}" },
    "charweight": { "_text": "${p('WEIGHT')}" },
    "_hair": "${p('COLOR.HAIR')}",
    "_eyes": "${p('COLOR.EYE')}",
    "_skin": "${p('COLOR.SKIN')}",
    "description": "${p('BIO')}"
  },
  "challengerating": { "_text": "${p('CR')}" },
  "xpaward": { "_value": "0" },
  "maneuvers": {
    "_total": "${p('VAR.CMB.INTVAL')}",
    "_cmd": "${cmdVal}",
    "_cmdflatfooted": "${ffCmd}"
  },
  "favoredclasses": {
    "favoredclass": [
<#assign firstFav = true>
<@loop from=0 to=pcvar('COUNT[CLASSES]-1') ; class, class_has_next>
<#if (pcstring('CLASS.${class}.TYPE')?contains('Base') && pcvar(pcstring('CLASS.${class}.LEVEL')) > 0)>
<#if !firstFav>,</#if><#assign firstFav = false>
      { "_name": "${p('CLASS.${class}')}" }
</#if>
</@loop>
    ]
  },
  "money": {
<#assign pp = "0" gp = "0" sp = "0" cp = "0">
<@loop from=0 to=pcvar('COUNT[EQTYPE.Coin]')-1 ; c, c_has_next>
<#assign cname = pcstring('EQTYPE.Coin.${c}.NAME')>
<#assign cqty = pcstring('EQTYPE.Coin.${c}.QTY')>
<#if cname?contains('Platinum')><#assign pp = cqty>
<#elseif cname?contains('Gold')><#assign gp = cqty>
<#elseif cname?contains('Silver')><#assign sp = cqty>
<#elseif cname?contains('Copper')><#assign cp = cqty>
</#if>
</@loop>
    "_pp": "${j(pp)}",
    "_gp": "${j(gp)}",
    "_sp": "${j(sp)}",
    "_cp": "${j(cp)}"
  },
  "encumbrance": {
    "_encumstr": "${p('VAR.LOADSCORE.INTVAL')}",
    "_light": "${num(pcstring('WEIGHT.LIGHT'))}",
    "_medium": "${num(pcstring('WEIGHT.MEDIUM'))}",
    "_heavy": "${num(pcstring('WEIGHT.HEAVY'))}"
  },
  "factions": {}
}
}
}
}
