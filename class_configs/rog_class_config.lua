local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    ['Modes'] = {
        ['DPS'] = 0,
        ['TLP'] = 2,
    },
    ['ItemSets'] = {
        ['Epic'] = {
            "Fatestealer",
            "Nightshade, Blade of Entropy",
        },
    },
    ['AbilitySets'] = {
        ["ConditionedReflexes"] = {
            "Conditioned Reflexes",
            "Practiced Reflexes",
        },
        ["PracticedReflexes"] = {
            "Practiced Reflexes",
        },
        ["Vision"] = {
            "Thief's Sight",  -- Level 117
            "Thief's Vision", -- Level 96
            "Thief's Eyes",   -- Level 68
        },
        ["Shadowhunter"] = {
            "Shadow-Hunter's Dagger", -- Level 102
        },
        ["Slice"] = {
            "Carve",    -- Level 123
            "Lance",    -- Level 118
            "Slash",    -- Level 113
            "Slice",    -- Level 108
            "Hack",     -- Level 103
            "Gash",     -- Level 98
            "Lacerate", -- Level 93
            "Wound",    -- Level 88
            "Bleed",    -- Level 83
        },
        ["Executioner"] = {
            "Executioner Discipline",  -- Level 100
            "Eradicator's Discipline", -- Level 95
            "Assassin Discipline",     -- Level 75
            "Duelist Discipline",      -- Level 59
            "Kinesthetics Discipline", -- Level 57
        },
        ["Twisted"] = {
            "Twisted Chance Discipline", -- Level 65
            "Deadeye Discipline",        -- Level 54
        },
        ["ProcBuff"] = {
            "Weapon Covenant",    -- Level 97
            "Weapon Bond",        -- Level 92
            "Weapon Affiliation", -- Level 87
        },
        ["Frenzied"] = {
            "Frenzied Stabbing Discipline", -- Level 70
        },
        ["Ambush"] = {
            "Bamboozle",       -- Level 121
            "Ambuscade",       -- Level 116
            "Bushwhack",       -- Level 111
            "Lie in Wait",     -- Level 106
            "Surprise Attack", -- Level 101
            "Beset",           -- Level 96
            "Accost",          -- Level 91
            "Assail",          -- Level 86
            "Ambush",          -- Level 81
            "Waylay",          -- Level 76
        },
        ["SneakAttack"] = {
            "Daggerslash",           -- Level 115
            "Daggerslice",           -- Level 110
            "Daggergash",            -- Level 105
            "Daggerthrust",          -- Level 100
            "Daggerstrike",          -- Level 95
            "Daggerswipe",           -- Level 90
            "Daggerlunge",           -- Level 85
            "Swiftblade",            -- Level 80
            "Razorarc",              -- Level 70
            "Daggerfall",            -- Level 69
            "Ancient: Chaos Strike", -- Level 65
            "Kyv Strike",            -- Level 65
            "Assassin's Strike",     -- Level 63
            "Thief's Vengeance",     -- Level 52
            "Sneak Attack",          -- Level 20
        },
        ["PoisonBlade"] = {
            "Venomous Blade",    -- Level 123
            "Netherbian Blade",  -- Level 118
            "Drachnid Blade",    -- Level 113
            "Skorpikis Blade",   -- Level 108
            "Reefcrawler Blade", -- Level 103
            "Asp Blade",         -- Level 98
            "Toxic Blade",       -- Level 93
        },
        ["FellStrike"] = {
            "Mayhem",       -- Level 125
            "Shadowstrike", -- Level 120
            "Blitzstrike",  -- Level 115
            "Fellstrike",   -- Level 110
            "Barrage",      -- Level 105
            "Incursion",    -- Level 100
            "Onslaught",    -- Level 95
            "Battery",      -- Level 90
            "Assault",      -- Level 85
        },
        ["Pinpoint"] = {
            "Pinpoint Fault",         -- Level 124
            "Pinpoint Defects",       -- Level 114
            "Pinpoint Shortcomings",  -- Level 109
            "Pinpoint Deficiencies",  -- Level 99
            "Pinpoint Liabilities",   -- Level 94
            "Pinpoint Flaws",         -- Level 89
            "Pinpoint Vitals",        -- Level 84
            "Pinpoint Weaknesses",    -- Level 79
            "Pinpoint Vulnerability", -- Level 74
        },
        ["Puncture"] = {
            "Disorienting Puncture",   -- Level 119
            "Vindictive Puncture",     -- Level 114
            "Vexatious Puncture",      -- Level 109
            "Disassociative Puncture", -- Level 104
        },
        ["EndRegen"] = {
            "Breather",    -- Level 101
            -- [] = "Seventh Wind",    -- Level 97 - Sac Endurance for Regen
            "Rest",        -- Level 96
            -- [] = "Sixth Wind",    -- Level 92 - Sac Endurance for Regen
            "Reprieve",    -- Level 91
            -- [] = "Fifth Wind",    -- Level 87 - Sac Endurance for Regen
            "Respite",     -- Level 86
            -- [] = "Fourth Wind",    -- Level 82 - Sac Endurance for Regen
            "Third Wind",  -- Level 77
            "Second Wind", -- Level 72
        },
        ["EdgeDisc"] = {
            "Reckless Edge Discipline", -- Level 121
            "Ragged Edge Discipline",   -- Level 107
            "Razor's Edge Discipline",  -- Level 92
        },
        ["AspDisc"] = {
            "Crinotoxin Discipline", -- Level 124
            "Exotoxin Discipline",   -- Level 119
            "Chelicerae Discipline", -- Level 114
            "Aculeus Discipline",    -- Level 109
            "Arcwork Discipline",    -- Level 104
            "Aspbleeder Discipline", -- Level 99
        },
        ["AimDisc"] = {
            "Baleful Aim Discipline", --  Level 116
            "Lethal Aim Discipline",  --  Level 108
            "Fatal Aim Discipline",   --  Level 98
            "Deadly Aim Discipline",  --  Level 68
        },
        ["MarkDisc"] = {
            "Unsuspecting Mark", -- Level 121
            "Foolish Mark",      -- Level 116
            "Naive Mark",        -- Level 111
            "Dim-Witted Mark",   -- Level 106
            "Wide-Eyed Mark",    -- Level 101
            "Gullible Mark",     -- Level 96
            "Gullible Mark",     -- Level 91
            "Easy Mark",         -- Level 86
        },
        ["Jugular"] = {
            "Jugular Slash",    -- Level 77
            "Jugular,",         -- Level 82
            "Jugular Sever",    -- Level 87
            "Jugular Gash",     -- Level 92
            "Jugular Lacerate", -- Level 97
            "Jugular Hack",     -- Level 102
            "Jugular Strike",   -- Level 107
            "Jugular Cut",      -- Level 112
            "Jugular Rend",     -- Level 117
        },
        ["Phantom"] = {
            "Phantom Assassin", -- Level 100
        },
        ["SecretBlade"] = {
            "Veiled Blade",     -- Level 124
            "Obfuscated Blade", -- Level 119
            "Cloaked Blade",    -- Level 114
            "Secret Blade",     -- Level 109
            "Hidden Blade",     -- Level 104
            "Holdout Blade",    -- Level 99
        },
        ["DichoSpell"] = {
            "Ecliptic Weapons",   -- Level 116
            "Composite Weapons",  -- Level 111
            "Dissident Weapons",  -- Level 106
            "Dichotomic Weapons", -- Level 101
        },
        ["Alliance"] = {
            "Poisonous Covenant",    -- Level 118
            "Poisonous Alliance",    -- Level 113
            "Poisonous Coalition",   -- Level 108
            "Poisonous Conjunction", -- Level 103
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
