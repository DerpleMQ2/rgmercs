local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    ['Modes'] = {
        'Tank',
        'DPS',
        'Healer',
        'Hybrid',
    },
    ['ItemSets'] = {
        ['Epic'] = {
            "Vengeful Taelosian Blood Axe",
            "Raging Taelosian Alloy Axe",
        },
    },
    ['AbilitySets'] = {
        ['endregen'] = {
            "Second Wind",
            "Third Wind",
            "Fourth Wind",
            "Respite",
            "Reprieve",
            "Rest",
            "Breather",
            "Hiatus",
            "Relax",
            "Night's Calming",
            "Convalesce",
        },
        ['beraura'] = {
            "Aura of Rage",
            "Bloodlust Aura",
        },
        ['Dicho'] = {
            "Dichotomic Rage",
            "Dissident Rage",
            "Composite Rage",
            "Ecliptic Rage",

        },
        ['Dfrenzy'] = {
            "Eviscerating Frenzy",
            "Heightened Frenzy",
            "Oppressing Frenzy",
            "Overpowering Frenzy",
            "Overwhelming Frenzy",
            "Conquering Frenzy",
            "Vanquishing Frenzy",
            "Demolishing Frenzy",
            "Mangling Frenzy",
            "Vindicating Frenzy",
        },
        ['Dvolley'] = {
            "Rage Volley",
            "Destroyer's Volley",
            "Annihilator's Volley",
            "Decimator's Volley",
            "Eradicator's Volley",
            "Savage Volley",
            "Sundering Volley",
            "Brutal Volley",
            "Demolishing Volley",
            "Mangling Volley",
            "Vindicating Volley",
            "Pulverizing Volley",
            "Eviscerating Volley",
        },
        ['Daxethrow'] = {
            "Maiming Axe Throw",
            "Vigorous Axe Throw",
            "Energetic Axe Throw",
            "Spirited Axe Throw",
            "Brutal Axe Throw",
            "Demolishing Axe Throw",
            "Mangling Axe Throw",
            "Vindicating Axe Throw",
            "Rending Axe Throw",
        },
        ['Daxeof'] = {
            "Axe of Rallos",
            "Axe of Graster",
            "Axe of Illdaera",
            "Axe of Zurel",
            "Axe of the Aeons",
            "Axe of Empyr",
            "Axe of Derakor",
            "Axe of Xin Diabo",
            "Axe of Orrak",
        },
        ['Phantom'] = {
            "Phantom Assailant",
        },
        ['Alliance'] = {
            "Demolisher's,",
            "Mangler's Covenant",
            "Vindicator's Coalition",
            "Conqueror's Conjunction",

        },
        ['CheapShot'] = {
            "Slap in the Face",
            "Kick in the Teeth",
            "Punch in The Throat",
            "Kick in the Shins",
            "Sucker Punch",
            "Rabbit Punch",
            "Swift Punch",
        },
        ['AESlice'] = {
            "Arcblade",
            "Arcslice",
            "Arcsteel",
            "Arcslash",
            "Arcshear",
        },
        ['AEVicious'] = {
            "Vicious Spiral",
            "Vicious Cyclone",
            "Vicious Cycle",
            "Vicious Revolution",
            "Vicious Whirl",
        },
        ['FrenzyBoost'] = {
            "Augmented Frenzy",
            "Amplified Frenzy",
            "Bolstered Frenzy",
            "Magnified Frenzy",
            "Buttressed Frenzy",
            "Heightened Frenzy",
        },
        ['RageStrike'] = {
            "Roiling Rage",
            "Festering Rage",
            "Bubbling Rage",
            "Smoldering Rage",
            "Seething Rage",
            "Frothing Rage",
        },
        ['SharedBuff'] = {
            "Shared Barbarism",
            "Shared Bloodlust",
            "Shared Brutality",
            "Shared Savagery",
            "Shared Viciousness",
            "Shared Cruelty",
            "Shared Ruthlessness",
            "Shared Atavism",
            "Shared Violence",
        },
        ['PrimaryBurnDisc'] = {
            "Berserking Discipline",
            "Sundering Discipline",
            "Brutal Discipline",
        },
        ['CleavingDisc'] = {
            "Cleaving Rage Discipline",
            "Cleaving Anger Discipline",
            "Cleaving Acrimony Discipline",
        },
        ['FlurryDisc'] = {
            "Vengeful Flurry Discipline",
            "Avenging Flurry Discipline",
        },
        ['DisconDisc'] = {
            "Disconcerting Discipline",
        },
        ['ResolveDisc'] = {
            "Frenzied Resolve Discipline",
        },
        ['HHEBuff'] = {
            "Battle Cry",
            "War Cry",
            "Battle Cry of Dravel",
            "War Cry of Dravel",
            "Battle Cry of the Mastruq",
            "Ancient: Cry of Chaos",
        },
        ['CryDmg'] = {
            "Cry Havoc",
            "Cry Carnage",
        },
        ['AutoAxe'] = {
            "Corroded Axe",
            "Blunt Axe",
            "Steel Axe",
            "Bearded Axe",
            "Mithril Axe",
            "Balanced War Axe",
            "Bonesplicer Axe",
            "Fleshtear Axe",
            "Cold Steel Cleaving Axe",
            "Mithril Bloodaxe",
            "Rage Axe",
            "Bloodseeker's Axe",
            "Battlerage Axe",
            "Deathfury Axe",
            "Tainted Axe of Hatred",
            "Axe of The Destroyer",
            "Axe of The Annihilator",
            "Axe of The Decimator",
            "Axe of The Eradicator",
            "Axe of The Savage",
            "Axe of the Sunderer",
            "Axe of The Brute",
            "Axe of The Demolisher",
            "Axe of The Mangler",
            "Axe of The Vindicator",
            "Axe of the Conqueror",
            "Axe of the Eviscerator",
        },
        ['DichoAxe'] = {
            "Axe of The Demolisher",
            "Axe of The Mangler",
            "Axe of the Conqueror",
        },
        ['Tendon'] = {
            "Tendon Slice",
            "Tendon Shred",
            "Tendon Cleave",
            "Tendon Sever",
            "Tendon Shear",
            "Tendon Lacerate",
            "Tendon Slash",
            "Tendon Gash",
            "Tendon Tear",
            "Tendon Rupture",
            "Tendon Rip",
        },
        ['SappingStrike'] = {
            "Sapping Strikes",
            "Shriveling Strikes",
        },
        ['ReflexDisc'] = {
            "Reflexive Retaliation",
            "Instinctive Retaliation",
        },
        ['RestFrenzy'] = {
            "Desperate Frenzy",
            "Blinding Frenzy",
            "Restless Frenzy",

        },
        ['RetaliationDodge'] = {
            "Preemptive Retaliation",
            "Primed Retaliation",
            "Premature Retaltion",
            "Proactive Retaliation",
            "Prior Retaliation",
            "Advanced Retaliation",
            "Early Retaliation",
        },
        ['TempleStun'] = {
            "Temple Shatter",
            "Temple Bash",
            "Temple Blow",
            "Temple Chop",
            "Temple Crack",
            "Temple Crush",
            "Temple Demolish",
            "Temple Shatter",
            "Temple Slam",
            "Temple Smash",
            "Temple Strike",
        },
        ['JarringStrike'] = {
            "Jarring Crash",
            "Jarring Strike",
            "Jarring Smash",
            "Jarring Clash",
            "Jarring Slam",
            "Jarring Blow",
            "Jarring Crush",
            "Jarring Smite",
            "Jarring Jolt",
            "Jarring Shock",
            "Jarring Impact",
        },
    },
    ['Rotations'] = {
        ['Tank'] = {
            ["Available"] = 0,
            ['Combat'] = {},
            ['Downtime'] = {},
            ['Burn'] = {},
        },
        ['DPS'] = {
            ["Available"] = 1,
            ['Combat'] = {},
            ['Downtime'] = {},
            ['Burn'] = {},
        },
        ['Healer'] = {
            ["Available"] = 0,
            ['Combat'] = {},
            ['Downtime'] = {},
            ['Burn'] = {},
        },
        ['Hybrid'] = {
            ["Available"] = 0,
            ['Combat'] = {},
            ['Downtime'] = {},
            ['Burn'] = {},
        },
    },
    ['DefaultConfig'] = {
        ['Mode'] = '2',
    },
}
