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
            "Transcended Fistwraps of Immortality",
            "Fistwraps of Celestial Discipline",
        },
    },
    ['AbilitySets'] = {
        ['EndRegen'] = {
            -- Fast Endurance regen - No Update
            "Second Wind",
            "Third Wind",
            "Fourth Wind",
            "Respite",
            "Reprieve",
            "Rest",
            "Breather",
            "Relax",
            "Night's Calming",
            "Convalesce",
        },
        ['Aura'] = {
            "Disciple's Aura",
            "Master's Aura",
        },
        ['DichoSpell'] = {
            "Dichotomic Form",
            "Dissident Form",
            "Composite Form",
            "Ecliptic Form",
        },
        ['Drunken'] = {
            "Drunken Monkey Style",
        },
        ['Curse'] = {
            -- Curse Line - Alternating expansions
            "Curse of the Thirteen Fingers", -- 103 TBM
            "Curse of Fourteen Fists",       -- 108 TBM
            "Curse of Fifteen Strikes",      -- 113 COV
            "Curse of Sixteen Shadows",      -- 118 NOS
        },
        ['Fang'] = {
            "Dragon Fang",
            "Zalikor's Fang",
            "Hoshkar's Fang",
            "Zlexak's Fang",
            "Uncia's Fang",
        },
        ['Fists'] = {
            "Buffeting of Fists",
            "Wheel of Fists",
            "Whorl of Fists",
            "Torrent of Fists",
            "Firestorm of Fists",
            "Barrage of Fists",
            "Flurry of Fists",
        },
        ['Precision'] = {
            "Doomwalker's Precision Strike",
            "Firewalker's Precision Strike",
            "Icewalker's Precision Strike",
            "Bloodwalker's Precision Strike",
        },
        ['Shuriken'] = {
            "Vigorous Shuriken",
        },
        ['CraneStance'] = {
            "Crane Stance",
            "Heron Stance",
        },
        ['Synergy'] = {
            "Fatewalker's Synergy",  -- LS 125
            "Bloodwalker's Synergy", -- TOL 120
            "Calanin's Synergy",
            "Dreamwalker's Synergy",
            "Veilwalker's Synergy",
            "Shadewalker's Synergy",
            "Doomwalker's Synergy",
            "Firewalker's Synergy",
            "Icewalker's Synergy",
        },
        ['Alliance'] = {
            -- Alliance line - Alternates expansions
            "Doomwalker's Alliance",
            "Firewalker's Covenant",
            "Icewalker's Coalition",     -- COV
            "Bloodwalker's Conjunction", -- NOS
        },
        ['Storm'] = {
            "Eye of the Storm",
        },
        ['Breaths'] = {
            --- Breaths Endurance Line
            "Five Breaths",
            "Six Breaths",
            "Seven Breaths",
            "Eight Breaths",
            "Nine Breaths",
            "Breath of Tranquility",
            "Breath of Stillness",
            "Moment of Stillness",
        },
        ['FistsOfWu'] = {
            --- Fists of Wu - Double Attack
            "Fists Of Wu",
        },
        ['EarthForce'] = {
            -- EarthForce - Melee Mitigation
            "Earthwalk Discipline",
            "EarthForce Discipline",
        },
        ['ShadedStep'] = {
            -- ShadedStep - Dodge Bonus 18 Seconds
            "Void Step",
            "Shaded Step",
        },
        ['RejectDeath'] = {
            "Repeal Death",
            "Delay Death",
            "Defer Death",
            "Deny Death",
            "Decry Death",
            "Forestall Death",
            "Refuse Death",
            "Reject Death",
            "Rescind Death",
            "Defy Death",
        },
        ['DodgeBody'] = {
            "Void Body",
            "Veiled Body",
        },
        ['MezSpell'] = {
            "Echo of Disorientation",
            "Echo of Flinching",
            "Echo of Diversion",
        },
        ['Iron'] = {
            "Ashenhand Discipline",
            "Scaledfist Discipline",
            "Ironfist Discipline",
        },
        ['Heel'] = {
            "Rapid Kick Discipline",
            "Heel of Kanji",
            "Heel of Kai",
            "Heel of Kojai",
            "Heel of Zagali",
        },
        ['Speed'] = {
            "Hundred Fists Discipline",
            "Speed Focus Discipline",
        },
        ['Palm'] = {
            "Innerflame Discipline",
            "Crystalpalm Discipline",
            "Diamondpalm Discipline",
            "Terrorpalm Discipline",
        },
        ['Poise'] = {
            "Dragon's Poise",
            "Tiger's Poise",
            "Eagle's Poise",
            "Tiger's Symmetry",
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
