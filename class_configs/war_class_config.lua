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
            "Kreljnok's Sword of Eternal Power",
            "Champion's Sword of Eternal Power",
        },
    },
    ['AbilitySets'] = {
        ['meleemit'] = {
            "Climactic Stand",
            "Resolute Stand",
            "Ultimate Stand Discipline",
            "Culminating Stand Discipline",
            "Last Stand Discipline",
            "Final Stand Discipline",
            --[] = "Stonewall Discipline",
            "Defensive Discipline",
        },
        ['missall'] = {
            "Fortitude Discipline",
        },
        ['absorball'] = {
            "Finish the Fight",
            "Pain Doesn't Hurt",
            "No Time to Bleed",
        },
        ['parryall'] = {
            "Flash of Anger",
        },
        ['shieldhit'] = {
            "Shield Sunder",
            "Shield Break",
            "Shield Topple",
            "Shield Splinter",
            "Shield Rupture",
        },
        ['groupac'] = {
            "Field Bulwark",
            "Full Moon's Champion",
            "Paragon Champion",
            "Field Champion",
            "Field Protector",
            "Field Guardian",
            "Field Defender",
            "Field Outfitter",
            "Field Armorer",
        },
        ['groupdodge'] = {
            "Commanding Voice",
        },
        ['defenseac'] = {
            "Vigorous Defense",
            "Primal Defense",
            "Courageous Defense",
            "Resolute Defense",
            "Stout Defense",
            "Steadfast Defense",
            "Stalwart Defense",
            "Staunch Defense",
            "Bracing Defense",
        },
        ['bmdisc'] = {
            "Ecliptic Shield",
            "Composite Shield",
            "Dissident Shield",
            "Dichotomic Shield",
        },
        ['aeroar'] = {
            "Roar of Challenge",
            "Rallying Roar",
        },
        ['aeselfbuff'] = {
            "Wade into Battle",
            "Wade into Conflict",
        },
        ['aehealhate'] = {
            "Penumbral Expanse",
            "Confluent Expanse",
            "Concordant Expanse",
            "Harmonious Expanse",
        },
        ['singlehealhate'] = {
            "Penumbral Precision",
            "Confluent Precision",
            "Concordant Precision",
            "Harmonious Precision",
        },
        ['aehitall'] = {
            "Tempest Blades",
            "Dragonstrike Blades",
            "Stormstrike Blades",
            "Stormwheel Blades",
            "Cyclonic Blades",
            "Wheeling Blades",
            "Maelstrom Blade",
            "Whorl Blade",
            "Vortex Blade",
            "Cyclone Blade",
            "Whirlwind Blade",
            "Hurricane Blades",
            "Spiraling Blades",
        },
        ['AddHate1'] = {
            "Mortimus' Roar",
            "Namdrows' Roar",
            "Kragek's Roar",
            "Kluzen's Roar",
            "Cyclone Roar",
            "Krondal's Roar",
            "Grendlaen Roar",
            "Bazu Roar",
            "Ancient: Chaos Cry",
            "Bazu Bluster",
            "Bazu Bellow",
            "Bellow of the Mastruq",
            "Incite",
            "Berate",
            "Bellow",
            "Provoke",
        },
        ['AddHate2'] = {
            "Distressing Shout",
            "Twilight Shout",
            "Oppressing Shout",
            "Burning Shout",
            "Tormenting Shout",
            "Harassing Shout",
        },
        ['Taunt1'] = {
            "Infuriate",
            "Bristle",
            "Aggravate",
            "Slander",
            "Insult",
            "Ridicule",
            "Scorn",
            "Scoff",
            "Jeer",
            "Sneer",
            "Scowl",
            "Mock",
        },
        ['StrikeDisc'] = {
            "Decisive Strike",
            "Precision Strike",
            "Cunning Strike",
            "Calculated Strike",
            "Vital Strike",
            "Strategic Strike",
            "Opportunistic Strike",
            "Exploitive Strike",
        },
        ['endregen'] = {
            "Convalesce",
            "Night's Calming",
            "Hiatus",
            "Breather",
            "Rest",
            "Reprieve",
            "Respite",
            "Fourth Wind",
            "Third Wind",
            "Second Wind",
        },
        ['waraura'] = {
            "Champion's Aura",
            "Myrmidon's Aura",
        },
        ['AgroLock'] = {
            "Unending Attention",
            "Unyielding Attention",
            "Unflinching Attention",
            "Unbroken Attention",
            "Undivided Attention",
            "Unrelenting Attention",
            "Unconditional Attention",
        },
        ['AgroPet'] = {
            "Phantom Aggressor",
        },
        ['OnslaughtDisc'] = {
            "Savage Onslaught Discipline",
            "Brutal Onslaught Discipline",
            "Brightfeld's Onslaught Discipline",
        },
        ['RuneShield'] = {
            "Warrior's Resolve",
            "Warrior's Rampart",
            "Warrior's Aegis",
        },
    },
    ['Rotations'] = {
        ['Tank'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    {},
                },
                ['Debuff'] = {
                    {},
                },
                ['Heal'] = {
                    {},
                },
                ['DPS'] = {
                    {},
                },
                ['Downtime'] = {
                    {},
                },
            },
            ['Spells'] = {
                { name = "", gem = 1, },
                { name = "", gem = 2, },
                { name = "", gem = 3, },
                { name = "", gem = 4, },
                { name = "", gem = 5, },
                { name = "", gem = 6, },
                { name = "", gem = 7, },
                { name = "", gem = 8, },
                { name = "", gem = 9, },
                { name = "", gem = 10, },
                { name = "", gem = 11, },
                { name = "", gem = 12, },
            },
        },
        ['DPS'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    {},
                },
                ['Debuff'] = {
                    {},
                },
                ['Heal'] = {
                    {},
                },
                ['DPS'] = {
                    {},
                },
                ['Downtime'] = {
                    {},
                },
            },
            ['Spells'] = {
                { name = "", gem = 1, },
                { name = "", gem = 2, },
                { name = "", gem = 3, },
                { name = "", gem = 4, },
                { name = "", gem = 5, },
                { name = "", gem = 6, },
                { name = "", gem = 7, },
                { name = "", gem = 8, },
                { name = "", gem = 9, },
                { name = "", gem = 10, },
                { name = "", gem = 11, },
                { name = "", gem = 12, },
            },
        },
        ['Healer'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    {},
                },
                ['Debuff'] = {
                    {},
                },
                ['Heal'] = {
                    {},
                },
                ['DPS'] = {
                    {},
                },
                ['Downtime'] = {
                    {},
                },
            },
            ['Spells'] = {
                { name = "", gem = 1, },
                { name = "", gem = 2, },
                { name = "", gem = 3, },
                { name = "", gem = 4, },
                { name = "", gem = 5, },
                { name = "", gem = 6, },
                { name = "", gem = 7, },
                { name = "", gem = 8, },
                { name = "", gem = 9, },
                { name = "", gem = 10, },
                { name = "", gem = 11, },
                { name = "", gem = 12, },
            },
        },
        ['Hybrid'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    {},
                },
                ['Debuff'] = {
                    {},
                },
                ['Heal'] = {
                    {},
                },
                ['DPS'] = {
                    {},
                },
                ['Downtime'] = {
                    {},
                },
            },
            ['Spells'] = {
                { name = "", gem = 1, },
                { name = "", gem = 2, },
                { name = "", gem = 3, },
                { name = "", gem = 4, },
                { name = "", gem = 5, },
                { name = "", gem = 6, },
                { name = "", gem = 7, },
                { name = "", gem = 8, },
                { name = "", gem = 9, },
                { name = "", gem = 10, },
                { name = "", gem = 11, },
                { name = "", gem = 12, },
            },
        },
        ['DefaultConfig'] = {
            ['Mode'] = '1',
        },
    },
}
