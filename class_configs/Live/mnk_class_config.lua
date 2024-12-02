local mq           = require('mq')
local Config       = require('utils.config')
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")

local _ClassConfig = {
    _version          = "1.0 - Live",
    _author           = "Derple",
    ['Modes']         = {
        'DPS',
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Transcended Fistwraps of Immortality",
            "Fistwraps of Celestial Discipline",
        },
    },
    ['AbilitySets']   = {
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
        ['MonkAura'] = {
            "Disciple's Aura",
            "Master's Aura",
        },
        ['DichoSpell'] = {
            "Dichotomic Form",
            "Dissident Form",
            "Composite Form",
            "Ecliptic Form",
            "Reciprocal Form",
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
            "Curse of Seventeen Facets",     -- 123 TOB
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
        ['Precision1'] = {
            "Doomwalker's Precision Strike",
            "Firewalker's Precision Strike",
            "Icewalker's Precision Strike",
            "Bloodwalker's Precision Strike",
            "Fatewalker's Precision Strike",
        },
        ['Precision2'] = {
            "Doomwalker's Precision Strike",
            "Firewalker's Precision Strike",
            "Icewalker's Precision Strike",
            "Bloodwalker's Precision Strike",
            "Fatewalker's Precision Strike",
        },
        ['Precision3'] = {
            "Doomwalker's Precision Strike",
            "Firewalker's Precision Strike",
            "Icewalker's Precision Strike",
            "Bloodwalker's Precision Strike",
            "Fatewalker's Precision Strike",
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
            "Fatewalker's Covariance",   -- TOB
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
    ['RotationOrder'] = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    Casting.DoBuffCheck() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck() and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
    },
    ['Rotations']     = {
        ['Downtime'] = {
            {
                name = "MonkAura",
                type = "Disc",
                cond = function(self, aaName)
                    return not mq.TLO.Me.Aura(1)() and mq.TLO.Me.PctEndurance() > 10
                end,
            },
            {
                name = "Breaths",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() <= 75
                end,
            },
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Mend",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and mq.TLO.Me.PctHPs() < 85
                end,
            },
        },
        ['Burn'] = {
            -- Set 1
            {
                name = "Silent Strikes",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Swift Tails' Chant",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Infusion of Thunder",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Spire of the Sensei",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "DichoSpell",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "CraneStance",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Five Point Palm",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Heel",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            -- Set 2
            {
                name = "Focused Destructive Force",
                type = "AA",
                cond = function(self, aaName)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Poise",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "DichoSpell",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "CraneStance",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Five Point Palm",
                type = "AA",
                cond = function(self, aaName)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Palm",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            -- Set 3
            {
                name = "Infusion of Thunder",
                type = "AA",
                cond = function(self, aaName)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Speed'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Spire of the Sensei",
                type = "AA",
                cond = function(self, aaName)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Speed'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Ton Po's Stance",
                type = "AA",
                cond = function(self, aaName)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Speed'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "DichoSpell",
                type = "Disc",
                cond = function(self, aaName)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Speed'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "CraneStance",
                type = "Disc",
                cond = function(self, aaName)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Speed'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Five Point Palm",
                type = "AA",
                cond = function(self, aaName)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Speed'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Speed",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Heel'])() and not mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Palm'])() and
                        mq.TLO.Me.CombatAbilityReady(self.ResolvedActionMap['Speed'])() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            -- Set 4
            {
                name = "Focused Destructive Force",
                type = "AA",
                cond = function(self, aaName)
                    return not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Poise",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Infusion of Thunder",
                type = "AA",
                cond = function(self, aaName)
                    return not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Spire of the Sensei",
                type = "AA",
                cond = function(self, aaName)
                    return not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Storm",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Mend",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and mq.TLO.Me.PctHPs() < 45
                end,
            },
            {
                name = "FistsWu",
                type = "Disc",
                cond = function(self, discSpell)
                    return not Casting.SongActive(discSpell)
                end,
            },
            {
                name = "Alliance",
                type = "Disc",
                cond = function(self, aaName)
                    return Config:GetSetting('DoAlliance') and Casting.CanAlliance() and not Casting.TargetHasBuffByName("Firewalker's Covenant Trigger") and
                        not Casting.TargetHasBuffByName("Doomwalker's Alliance Trigger")
                end,
            },
            {
                name = "Vehement Rage",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.GetTargetPctHPs() > 10 and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Iron",
                type = "Disc",
                cond = function(self, aaName)
                    return not mq.TLO.Me.ActiveDisc.ID() and Targeting.IsNamed(mq.TLO.Target)
                end,
            },
            {
                name = "DichoSpell",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "CraneStance",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "Five Point Palm",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Zan Fi's Whistle",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Two-Finger Wasp Touch",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Drunken",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() >= 20 and Targeting.GetTargetPctHPs() > 10
                end,
            },
            {
                name = "Curse",
                type = "Disc",
                cond = function(self, discSpell)
                    return Targeting.GetTargetPctHPs() > 5
                end,
            },
            {
                name = "Curse",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "Synergy",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "Fang",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "Fists",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "Precision1",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "Precision2",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "Precision3",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "Shuriken",
                type = "Disc",
                cond = function(self, discSpell)
                    return true
                end,
            },
            {
                name = "Intimidation",
                type = "Ability",
                cond = function(self, abilityName)
                    return Config:GetSetting('DoIntimidation')
                        and Casting.AbilityReady(abilityName)
                end,
            },
            {
                name = "Round Kick",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.AbilityReady(abilityName)() and Casting.AbilityRangeCheck(target)
                end,
            },
            {
                name = "Kick",
                type = "Ability",
                cond = function(self, abilityName)
                    return Casting.AbilityReady(abilityName)
                end,
            },
            {
                name = "Disarm",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Casting.AbilityReady(abilityName) and Casting.AbilityRangeCheck(target)
                end,
            },
        },
    },
    ['PullAbilities'] = {
        {
            id = 'Distant Strike',
            Type = "AA",
            DisplayName = 'Distant Strike',
            AbilityName = 'Distant Strike',
            AbilityRange = 250,
            cond = function(self)
                return mq.TLO.Me.AltAbility('Distant Strike')
            end,
        },
    },
    ['DefaultConfig'] = {
        ['Mode']           = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes Do?",
            Answer = "Currently there is only DPS mode for Monks, More modes may be added in the future.",
        },
        ['DoIntimidation'] = {
            DisplayName = "Do Intimidation",
            Category = "Combat",
            Tooltip = "Select Use Intimidation",
            Default = false,
            FAQ = "Why am I not using Intimidation?",
            Answer = "Adjust your [DoIntimidation] setting to true.",
        },
    },
}

return _ClassConfig
