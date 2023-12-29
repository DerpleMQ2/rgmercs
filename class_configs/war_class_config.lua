local mq             = require('mq')
local RGMercUtils    = require("rgmercs.utils.rgmercs_utils")

return {
    ['Modes'] = {
        [1] = 'Tank',
        [2] = 'DPS',
        [3] = 'Healer',
        [4] = 'Hybrid',
    },
    ['ItemSets'] = {
        ['Epic'] = {
            [1] = "Kreljnok's Sword of Eternal Power",
            [2] = "Champion's Sword of Eternal Power",
        },
    },
    ['AbilitySets'] = {
        ['meleemit'] = {
            [1] = "Climactic Stand",
            [2] = "Resolute Stand",
            [3] = "Ultimate Stand Discipline",
            [4] = "Culminating Stand Discipline",
            [5] = "Last Stand Discipline",
            [6] = "Final Stand Discipline",
            --[] = "Stonewall Discipline",
            [7] = "Defensive Discipline",
        },
        ['missall'] = {
            [1] = "Fortitude Discipline",
        },
        ['absorball'] = {
            [1] = "Finish the Fight",
            [2] = "Pain Doesn't Hurt",
            [3] = "No Time to Bleed",
        },
        ['parryall'] = {
            [1] = "Flash of Anger",
        },
        ['shieldhit'] = {
            [1] = "Shield Sunder",
            [2] = "Shield Break"	,
            [3] = "Shield Topple",
            [4] = "Shield Splinter",
            [5] = "Shield Rupture",
        },
        ['groupac'] = {
            [1] = "Field Bulwark",
            [2] = "Full Moon's Champion",
            [3] = "Paragon Champion",
            [4] = "Field Champion",
            [5] = "Field Protector",
            [6] = "Field Guardian",
            [7] = "Field Defender",
            [8] = "Field Outfitter",
            [9] = "Field Armorer",
        },
        ['groupdodge'] = {
            [1] = "Commanding Voice",
        },
        ['defenseac'] = {
            [1] = "Vigorous Defense",
            [2] = "Primal Defense",
            [3] = "Courageous Defense",
            [4] = "Resolute Defense",
            [5] = "Stout Defense",
            [6] = "Steadfast Defense",
            [7] = "Stalwart Defense",
            [8] = "Staunch Defense",
            [9] = "Bracing Defense",
        },
        ['bmdisc'] = {
            [1] = "Ecliptic Shield",
            [2] = "Composite Shield",
            [3] = "Dissident Shield",
            [4] = "Dichotomic Shield",
        },
        ['aeroar'] = {
            [1] = "Roar of Challenge",
            [2] = "Rallying Roar",
        },
        ['aeselfbuff'] = {
            [1] = "Wade into Battle",
            [2] = "Wade into Conflict",
        },
        ['aehealhate'] = {
            [1] = "Penumbral Expanse",
            [2] = "Confluent Expanse",
            [3] = "Concordant Expanse",
            [4] = "Harmonious Expanse",
        },
        ['singlehealhate'] = {
            [1] = "Penumbral Precision",
            [2] = "Confluent Precision",
            [3] = "Concordant Precision",
            [4] = "Harmonious Precision",
        },
        ['aehitall'] = {
            [1] = "Tempest Blades",
            [2] = "Dragonstrike Blades",
            [3] = "Stormstrike Blades",
            [4] = "Stormwheel Blades",
            [5] = "Cyclonic Blades",
            [6] = "Wheeling Blades",
            [7] = "Maelstrom Blade",
            [8] = "Whorl Blade",
            [9] = "Vortex Blade",
            [10] = "Cyclone Blade",
            [11] = "Whirlwind Blade",
            [12] = "Hurricane Blades",
            [13] = "Spiraling Blades",
        },
        ['AddHate1'] = {
            [1] = "Mortimus' Roar",
            [2] = "Namdrows' Roar",
            [3] = "Kragek's Roar",
            [4] = "Kluzen's Roar",
            [5] = "Cyclone Roar",
            [6] = "Krondal's Roar",
            [7] = "Grendlaen Roar",
            [8] = "Bazu Roar",
            [9] = "Ancient: Chaos Cry",
            [10] = "Bazu Bluster",
            [11] = "Bazu Bellow",
            [12] = "Bellow of the Mastruq",
            [13] = "Incite",
            [14] = "Berate",
            [15] = "Bellow",
            [16] = "Provoke",
        },
        ['AddHate2'] = {
            [1] = "Distressing Shout",
            [2] = "Twilight Shout",
            [3] = "Oppressing Shout",
            [4] = "Burning Shout",
            [5] = "Tormenting Shout",
            [6] = "Harassing Shout",
        },
        ['Taunt1'] = {
            [1] = "Infuriate",
            [2] = "Bristle",
            [3] = "Aggravate",
            [4] = "Slander",
            [5] = "Insult",
            [6] = "Ridicule"	,
            [7] = "Scorn",
            [8] = "Scoff",
            [9] = "Jeer",
            [10] = "Sneer",
            [11] = "Scowl",
            [12] = "Mock",
        },
        ['StrikeDisc'] = {
            [1] = "Decisive Strike",
            [2] = "Precision Strike",
            [3] = "Cunning Strike",
            [4] = "Calculated Strike",
            [5] = "Vital Strike",
            [6] = "Strategic Strike"	,
            [7] = "Opportunistic Strike",
            [8] = "Exploitive Strike",
        },
        ['endregen'] = {
            [1] = "Convalesce",
            [2] = "Night's Calming",
            [3] = "Hiatus",
            [4] = "Breather",
            [5] = "Rest",
            [6] = "Reprieve",
            [7] = "Respite",
            [8] = "Fourth Wind",
            [9] = "Third Wind",
            [10] = "Second Wind",
        },
        ['waraura'] = {
            [1] = "Champion's Aura",
            [2] = "Myrmidon's Aura",
        },
        ['AgroLock'] = {
            [1] = "Unending Attention",
            [2] = "Unyielding Attention",
            [3] = "Unflinching Attention",
            [4] = "Unbroken Attention",
            [5] = "Undivided Attention",
            [6] = "Unrelenting Attention",
            [7] = "Unconditional Attention",
        },
        ['AgroPet'] = {
            [1] = "Phantom Aggressor",
        },
        ['OnslaughtDisc'] = {
            [1] = "Savage Onslaught Discipline",
            [2] = "Brutal Onslaught Discipline",
            [3] = "Brightfeld's Onslaught Discipline",
        },
        ['RuneShield'] = {
            [1] = "Warrior's Resolve",
            [2] = "Warrior's Rampart",
            [3] = "Warrior's Aegis",
        },
    },
    ['Rotations'] = {
        ['Tank'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    [1] = {},
                },
                ['Debuff'] = {
                    [1] = {},
                },
                ['Heal'] = {
                    [1] = {},
                },
                ['DPS'] = {
                    [1] = {},
                },
                ['Downtime'] = {
                    [1] = {},
                },
            },
            ['Spells'] = {
                [1] = { name="", gem=1 },
                [2] = { name="", gem=2 },
                [3] = { name="", gem=3},
                [4] = { name="", gem=4},
                [5] = { name="", gem=5 },
                [6] = { name="", gem=6 },
                [7] = { name="", gem=7 },
                [8] = { name="", gem=8 },
                [9] = { name="", gem=9 },
                [10] = { name="", gem=10 },
                [11] = { name="", gem=11 },
                [12] = { name="", gem=12 },
            },
        },
        ['DPS'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    [1] = {},
                },
                ['Debuff'] = {
                    [1] = {},
                },
                ['Heal'] = {
                    [1] = {},
                },
                ['DPS'] = {
                    [1] = {},
                },
                ['Downtime'] = {
                    [1] = {},
                },
            },
            ['Spells'] = {
                [1] = { name="", gem=1 },
                [2] = { name="", gem=2 },
                [3] = { name="", gem=3},
                [4] = { name="", gem=4},
                [5] = { name="", gem=5 },
                [6] = { name="", gem=6 },
                [7] = { name="", gem=7 },
                [8] = { name="", gem=8 },
                [9] = { name="", gem=9 },
                [10] = { name="", gem=10 },
                [11] = { name="", gem=11 },
                [12] = { name="", gem=12 },
            },
        },
        ['Healer'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    [1] = {},
                },
                ['Debuff'] = {
                    [1] = {},
                },
                ['Heal'] = {
                    [1] = {},
                },
                ['DPS'] = {
                    [1] = {},
                },
                ['Downtime'] = {
                    [1] = {},
                },
            },
            ['Spells'] = {
                [1] = { name="", gem=1 },
                [2] = { name="", gem=2 },
                [3] = { name="", gem=3},
                [4] = { name="", gem=4},
                [5] = { name="", gem=5 },
                [6] = { name="", gem=6 },
                [7] = { name="", gem=7 },
                [8] = { name="", gem=8 },
                [9] = { name="", gem=9 },
                [10] = { name="", gem=10 },
                [11] = { name="", gem=11 },
                [12] = { name="", gem=12 },
            },
        },
        ['Hybrid'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    [1] = {},
                },
                ['Debuff'] = {
                    [1] = {},
                },
                ['Heal'] = {
                    [1] = {},
                },
                ['DPS'] = {
                    [1] = {},
                },
                ['Downtime'] = {
                    [1] = {},
                },
            },
            ['Spells'] = {
                [1] = { name="", gem=1 },
                [2] = { name="", gem=2 },
                [3] = { name="", gem=3},
                [4] = { name="", gem=4},
                [5] = { name="", gem=5 },
                [6] = { name="", gem=6 },
                [7] = { name="", gem=7 },
                [8] = { name="", gem=8 },
                [9] = { name="", gem=9 },
                [10] = { name="", gem=10 },
                [11] = { name="", gem=11 },
                [12] = { name="", gem=12 },
            },
        },
        ['DefaultConfig'] = {
            ['Mode'] = '1',
        },
    },
}