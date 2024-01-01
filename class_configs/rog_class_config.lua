local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    ['Modes'] = {
        ['DPS'] = 0,
        ['TLP'] = 2,
    },
    ['ItemSets'] = {
        ['Epic'] = {
            [1] = "Fatestealer",
            [2] = "Nightshade, Blade of Entropy",
        },
    },
    ['AbilitySets'] = {
        ["ConditionedReflexes"] = {
            [1] = "Conditioned Reflexes",
            [2] = "Practiced Reflexes",
        },
        ["PracticedReflexes"] = {
            [1] = "Practiced Reflexes",
        },
        ["Vision"] = {
            [1] = "Thief's Sight",  -- Level 117
            [2] = "Thief's Vision", -- Level 96
            [3] = "Thief's Eyes",   -- Level 68
        },
        ["Shadowhunter"] = {
            [1] = "Shadow-Hunter's Dagger", -- Level 102
        },
        ["Slice"] = {
            [1] = "Carve",    -- Level 123
            [2] = "Lance",    -- Level 118
            [3] = "Slash",    -- Level 113
            [4] = "Slice",    -- Level 108
            [5] = "Hack",     -- Level 103
            [6] = "Gash",     -- Level 98
            [7] = "Lacerate", -- Level 93
            [8] = "Wound",    -- Level 88
            [9] = "Bleed",    -- Level 83
        },
        ["Executioner"] = {
            [1] = "Executioner Discipline",  -- Level 100
            [2] = "Eradicator's Discipline", -- Level 95
            [3] = "Assassin Discipline",     -- Level 75
            [4] = "Duelist Discipline",      -- Level 59
            [5] = "Kinesthetics Discipline", -- Level 57
        },
        ["Twisted"] = {
            [1] = "Twisted Chance Discipline", -- Level 65
            [2] = "Deadeye Discipline",        -- Level 54
        },
        ["ProcBuff"] = {
            [1] = "Weapon Covenant",    -- Level 97
            [2] = "Weapon Bond",        -- Level 92
            [3] = "Weapon Affiliation", -- Level 87
        },
        ["Frenzied"] = {
            [1] = "Frenzied Stabbing Discipline", -- Level 70
        },
        ["Ambush"] = {
            [1] = "Bamboozle",       -- Level 121
            [2] = "Ambuscade",       -- Level 116
            [3] = "Bushwhack",       -- Level 111
            [4] = "Lie in Wait",     -- Level 106
            [5] = "Surprise Attack", -- Level 101
            [6] = "Beset",           -- Level 96
            [7] = "Accost",          -- Level 91
            [8] = "Assail",          -- Level 86
            [9] = "Ambush",          -- Level 81
            [10] = "Waylay",         -- Level 76
        },
        ["SneakAttack"] = {
            [1] = "Daggerslash",            -- Level 115
            [2] = "Daggerslice",            -- Level 110
            [3] = "Daggergash",             -- Level 105
            [4] = "Daggerthrust",           -- Level 100
            [5] = "Daggerstrike",           -- Level 95
            [6] = "Daggerswipe",            -- Level 90
            [7] = "Daggerlunge",            -- Level 85
            [8] = "Swiftblade",             -- Level 80
            [9] = "Razorarc",               -- Level 70
            [10] = "Daggerfall",            -- Level 69
            [11] = "Ancient: Chaos Strike", -- Level 65
            [12] = "Kyv Strike",            -- Level 65
            [13] = "Assassin's Strike",     -- Level 63
            [14] = "Thief's Vengeance",     -- Level 52
            [15] = "Sneak Attack",          -- Level 20
        },
        ["PoisonBlade"] = {
            [1] = "Venomous Blade",    -- Level 123
            [2] = "Netherbian Blade",  -- Level 118
            [3] = "Drachnid Blade",    -- Level 113
            [4] = "Skorpikis Blade",   -- Level 108
            [5] = "Reefcrawler Blade", -- Level 103
            [6] = "Asp Blade",         -- Level 98
            [7] = "Toxic Blade",       -- Level 93
        },
        ["FellStrike"] = {
            [1] = "Mayhem",       -- Level 125
            [2] = "Shadowstrike", -- Level 120
            [3] = "Blitzstrike",  -- Level 115
            [4] = "Fellstrike",   -- Level 110
            [5] = "Barrage",      -- Level 105
            [6] = "Incursion",    -- Level 100
            [7] = "Onslaught",    -- Level 95
            [8] = "Battery",      -- Level 90
            [9] = "Assault",      -- Level 85
        },
        ["Pinpoint"] = {
            [1] = "Pinpoint Fault",         -- Level 124
            [2] = "Pinpoint Defects",       -- Level 114
            [3] = "Pinpoint Shortcomings",  -- Level 109
            [4] = "Pinpoint Deficiencies",  -- Level 99
            [5] = "Pinpoint Liabilities",   -- Level 94
            [6] = "Pinpoint Flaws",         -- Level 89
            [7] = "Pinpoint Vitals",        -- Level 84
            [8] = "Pinpoint Weaknesses",    -- Level 79
            [9] = "Pinpoint Vulnerability", -- Level 74
        },
        ["Puncture"] = {
            [1] = "Disorienting Puncture",   -- Level 119
            [2] = "Vindictive Puncture",     -- Level 114
            [3] = "Vexatious Puncture",      -- Level 109
            [4] = "Disassociative Puncture", -- Level 104
        },
        ["EndRegen"] = {
            [1] = "Breather",    -- Level 101
            -- [] = "Seventh Wind",    -- Level 97 - Sac Endurance for Regen
            [2] = "Rest",        -- Level 96
            -- [] = "Sixth Wind",    -- Level 92 - Sac Endurance for Regen
            [3] = "Reprieve",    -- Level 91
            -- [] = "Fifth Wind",    -- Level 87 - Sac Endurance for Regen
            [4] = "Respite",     -- Level 86
            -- [] = "Fourth Wind",    -- Level 82 - Sac Endurance for Regen
            [5] = "Third Wind",  -- Level 77
            [6] = "Second Wind", -- Level 72
        },
        ["EdgeDisc"] = {
            [1] = "Reckless Edge Discipline", -- Level 121
            [2] = "Ragged Edge Discipline",   -- Level 107
            [3] = "Razor's Edge Discipline",  -- Level 92
        },
        ["AspDisc"] = {
            [1] = "Crinotoxin Discipline", -- Level 124
            [2] = "Exotoxin Discipline",   -- Level 119
            [3] = "Chelicerae Discipline", -- Level 114
            [4] = "Aculeus Discipline",    -- Level 109
            [5] = "Arcwork Discipline",    -- Level 104
            [6] = "Aspbleeder Discipline", -- Level 99
        },
        ["AimDisc"] = {
            [1] = "Baleful Aim Discipline", --  Level 116
            [2] = "Lethal Aim Discipline",  --  Level 108
            [3] = "Fatal Aim Discipline",   --  Level 98
            [4] = "Deadly Aim Discipline",  --  Level 68
        },
        ["MarkDisc"] = {
            [1] = "Unsuspecting Mark", -- Level 121
            [2] = "Foolish Mark",      -- Level 116
            [3] = "Naive Mark",        -- Level 111
            [4] = "Dim-Witted Mark",   -- Level 106
            [5] = "Wide-Eyed Mark",    -- Level 101
            [6] = "Gullible Mark",     -- Level 96
            [7] = "Gullible Mark",     -- Level 91
            [8] = "Easy Mark",         -- Level 86
        },
        ["Jugular"] = {
            [1] = "Jugular Slash",    -- Level 77
            [2] = "Jugular,",         -- Level 82
            [3] = "Jugular Sever",    -- Level 87
            [4] = "Jugular Gash",     -- Level 92
            [5] = "Jugular Lacerate", -- Level 97
            [6] = "Jugular Hack",     -- Level 102
            [7] = "Jugular Strike",   -- Level 107
            [8] = "Jugular Cut",      -- Level 112
            [9] = "Jugular Rend",     -- Level 117
        },
        ["Phantom"] = {
            [1] = "Phantom Assassin", -- Level 100
        },
        ["SecretBlade"] = {
            [1] = "Veiled Blade",     -- Level 124
            [2] = "Obfuscated Blade", -- Level 119
            [3] = "Cloaked Blade",    -- Level 114
            [4] = "Secret Blade",     -- Level 109
            [5] = "Hidden Blade",     -- Level 104
            [6] = "Holdout Blade",    -- Level 99
        },
        ["DichoSpell"] = {
            [1] = "Ecliptic Weapons",   -- Level 116
            [2] = "Composite Weapons",  -- Level 111
            [3] = "Dissident Weapons",  -- Level 106
            [4] = "Dichotomic Weapons", -- Level 101
        },
        ["Alliance"] = {
            [1] = "Poisonous Covenant",    -- Level 118
            [2] = "Poisonous Alliance",    -- Level 113
            [3] = "Poisonous Coalition",   -- Level 108
            [4] = "Poisonous Conjunction", -- Level 103
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
                [1] = { name = "", gem = 1 },
                [2] = { name = "", gem = 2 },
                [3] = { name = "", gem = 3 },
                [4] = { name = "", gem = 4 },
                [5] = { name = "", gem = 5 },
                [6] = { name = "", gem = 6 },
                [7] = { name = "", gem = 7 },
                [8] = { name = "", gem = 8 },
                [9] = { name = "", gem = 9 },
                [10] = { name = "", gem = 10 },
                [11] = { name = "", gem = 11 },
                [12] = { name = "", gem = 12 },
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
                [1] = { name = "", gem = 1 },
                [2] = { name = "", gem = 2 },
                [3] = { name = "", gem = 3 },
                [4] = { name = "", gem = 4 },
                [5] = { name = "", gem = 5 },
                [6] = { name = "", gem = 6 },
                [7] = { name = "", gem = 7 },
                [8] = { name = "", gem = 8 },
                [9] = { name = "", gem = 9 },
                [10] = { name = "", gem = 10 },
                [11] = { name = "", gem = 11 },
                [12] = { name = "", gem = 12 },
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
                [1] = { name = "", gem = 1 },
                [2] = { name = "", gem = 2 },
                [3] = { name = "", gem = 3 },
                [4] = { name = "", gem = 4 },
                [5] = { name = "", gem = 5 },
                [6] = { name = "", gem = 6 },
                [7] = { name = "", gem = 7 },
                [8] = { name = "", gem = 8 },
                [9] = { name = "", gem = 9 },
                [10] = { name = "", gem = 10 },
                [11] = { name = "", gem = 11 },
                [12] = { name = "", gem = 12 },
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
                [1] = { name = "", gem = 1 },
                [2] = { name = "", gem = 2 },
                [3] = { name = "", gem = 3 },
                [4] = { name = "", gem = 4 },
                [5] = { name = "", gem = 5 },
                [6] = { name = "", gem = 6 },
                [7] = { name = "", gem = 7 },
                [8] = { name = "", gem = 8 },
                [9] = { name = "", gem = 9 },
                [10] = { name = "", gem = 10 },
                [11] = { name = "", gem = 11 },
                [12] = { name = "", gem = 12 },
            },
        },
        ['DefaultConfig'] = {
            ['Mode'] = '1',
        },
    },
}
