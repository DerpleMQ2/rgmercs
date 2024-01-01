local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    ['Modes'] = {
        ['Tank'] = 0,
        ['DPS']  = 1,
        ['TLP']  = 2,
    },
    ['ItemSets'] = {
        ['Epic'] = {
            [1] = "Transcended Fistwraps of Immortality",
            [2] = "Fistwraps of Celestial Discipline",
        },
    },
    ['AbilitySets'] = {
        ['EndRegen'] = {
            -- Fast Endurance regen - No Update
            [1]  = "Second Wind",
            [2]  = "Third Wind",
            [3]  = "Fourth Wind",
            [4]  = "Respite",
            [5]  = "Reprieve",
            [6]  = "Rest",
            [7]  = "Breather",
            [8]  = "Relax",
            [9]  = "Night's Calming",
            [10] = "Convalesce",
        },
        ['Aura'] = {
            [1] = "Disciple's Aura",
            [2] = "Master's Aura",
        },
        ['DichoSpell'] = {
            [1] = "Dichotomic Form",
            [2] = "Dissident Form",
            [3] = "Composite Form",
            [4] = "Ecliptic Form",
        },
        ['Drunken'] = {
            [1] = "Drunken Monkey Style",
        },
        ['Curse'] = {
            -- Curse Line - Alternating expansions
            [1] = "Curse of the Thirteen Fingers", -- 103 TBM
            [2] = "Curse of Fourteen Fists",       -- 108 TBM
            [3] = "Curse of Fifteen Strikes",      -- 113 COV
            [4] = "Curse of Sixteen Shadows",      -- 118 NOS
        },
        ['Fang'] = {
            [1] = "Dragon Fang",
            [2] = "Zalikor's Fang",
            [3] = "Hoshkar's Fang",
            [4] = "Zlexak's Fang",
            [5] = "Uncia's Fang",
        },
        ['Fists'] = {
            [1] = "Buffeting of Fists",
            [2] = "Wheel of Fists",
            [3] = "Whorl of Fists",
            [4] = "Torrent of Fists",
            [5] = "Firestorm of Fists",
            [6] = "Barrage of Fists",
            [7] = "Flurry of Fists",
        },
        ['Precision'] = {
            [1] = "Doomwalker's Precision Strike",
            [2] = "Firewalker's Precision Strike",
            [3] = "Icewalker's Precision Strike",
            [4] = "Bloodwalker's Precision Strike",
        },
        ['Shuriken'] = {
            [1] = "Vigorous Shuriken",
        },
        ['CraneStance'] = {
            [1] = "Crane Stance",
            [2] = "Heron Stance",
        },
        ['Synergy'] = {
            [1] = "Fatewalker's Synergy",  -- LS 125
            [2] = "Bloodwalker's Synergy", -- TOL 120
            [3] = "Calanin's Synergy",
            [4] = "Dreamwalker's Synergy",
            [5] = "Veilwalker's Synergy",
            [6] = "Shadewalker's Synergy",
            [7] = "Doomwalker's Synergy",
            [8] = "Firewalker's Synergy",
            [9] = "Icewalker's Synergy",
        },
        ['Alliance'] = {
            -- Alliance line - Alternates expansions
            [1] = "Doomwalker's Alliance",
            [2] = "Firewalker's Covenant",
            [3] = "Icewalker's Coalition",     -- COV
            [4] = "Bloodwalker's Conjunction", -- NOS
        },
        ['Storm'] = {
            [1] = "Eye of the Storm",
        },
        ['Breaths'] = {
            --- Breaths Endurance Line
            [1] = "Five Breaths",
            [2] = "Six Breaths",
            [3] = "Seven Breaths",
            [4] = "Eight Breaths",
            [5] = "Nine Breaths",
            [6] = "Breath of Tranquility",
            [7] = "Breath of Stillness",
            [8] = "Moment of Stillness",
        },
        ['FistsOfWu'] = {
            --- Fists of Wu - Double Attack
            [1] = "Fists Of Wu",
        },
        ['EarthForce'] = {
            -- EarthForce - Melee Mitigation
            [1] = "Earthwalk Discipline",
            [2] = "EarthForce Discipline",
        },
        ['ShadedStep'] = {
            -- ShadedStep - Dodge Bonus 18 Seconds
            [1] = "Void Step",
            [2] = "Shaded Step",
        },
        ['RejectDeath'] = {
            [1]  = "Repeal Death",
            [2]  = "Delay Death",
            [3]  = "Defer Death",
            [4]  = "Deny Death",
            [5]  = "Decry Death",
            [6]  = "Forestall Death",
            [7]  = "Refuse Death",
            [8]  = "Reject Death",
            [9]  = "Rescind Death",
            [10] = "Defy Death",
        },
        ['DodgeBody'] = {
            [1] = "Void Body",
            [2] = "Veiled Body",
        },
        ['MezSpell'] = {
            [1] = "Echo of Disorientation",
            [2] = "Echo of Flinching",
            [3] = "Echo of Diversion",
        },
        ['Iron'] = {
            [1] = "Ashenhand Discipline",
            [2] = "Scaledfist Discipline",
            [3] = "Ironfist Discipline",
        },
        ['Heel'] = {
            [1] = "Rapid Kick Discipline",
            [2] = "Heel of Kanji",
            [3] = "Heel of Kai",
            [4] = "Heel of Kojai",
            [5] = "Heel of Zagali",
        },
        ['Speed'] = {
            [1] = "Hundred Fists Discipline",
            [2] = "Speed Focus Discipline",
        },
        ['Palm'] = {
            [1] = "Innerflame Discipline",
            [2] = "Crystalpalm Discipline",
            [3] = "Diamondpalm Discipline",
            [4] = "Terrorpalm Discipline",
        },
        ['Poise'] = {
            [1] = "Dragon's Poise",
            [2] = "Tiger's Poise",
            [3] = "Eagle's Poise",
            [4] = "Tiger's Symmetry",
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
