local mq           = require('mq')
local Config       = require('utils.config')
local Globals      = require("utils.globals")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Logger       = require("utils.logger")
local Core         = require("utils.core")
local Combat       = require("utils.combat")

local _ClassConfig = {
    _version            = "2.1 - The Hidden Forest WIP",
    _author             = "Algar, Derple",
    ['Modes']           = {
        'DPS',
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Ancient Fistwraps of Eternity (Tier 1)",
        },
        ['OoW_Chest'] = {
            "Fiercehand's Ascendant Shroud of the Focused",
            "Fiercehand Shroud of the Focused",
            "Stillmind Tunic",
        },
    },
    ['AbilitySets']     = {
        ['EndRegen'] = {
            "Third Wind",
            --"Second Wind",
        },
        ['MonkAura'] = {
            "Master's Aura",
            "Disciple's Aura",
        },
        ['Fang'] = {
            "Dragon Fang",
            "Clawstriker's Flurry",
        },
        ['FistsOfWu'] = {
            "Fists Of Wu",
        },
        ['MeleeMit'] = {
            "Impenetrable Discipline",
            "Earthwalk Discipline",
            "Stonestance Discipline",
        },
        ['FistDisc'] = {
            "Scaledfist Discipline",
            "Ashenhand Discipline",
            "Thunderkick Discipline",
        },
        ['Heel'] = {
            "Heel of Kai",
            "Heel of Kanji",
        },
        ['Speed'] = {
            "Speed Focus Discipline",
        },
        ['Palm'] = {
            "Crystalpalm Discipline",
            "Hundred Fists Discipline",
            "Innerflame Discipline",
        },
        -- ['ResistantDisc'] = {
        --     "Dreamwalk Discipline",
        --     "Resistant Discipline",
        -- },
    },
    ['HelperFunctions'] = {
        --function to make sure we don't have non-hostiles in range before we use AE damage

    },
    ['RotationOrder']   = {
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and not Casting.IAmFeigning() and
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or (Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 99))
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'BurnDisc',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and Casting.NoDiscActive()
            end,
        },
        {
            name = 'CombatBuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
    },
    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "MonkAura",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.AuraActiveByName(discSpell.RankName.Name())
                end,
                cond = function(self, discSpell)
                    return not mq.TLO.Me.Aura(1).ID()
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Frozen Fiercehand Shroud (Tier 2)",
                type = "Item",
                cond = function(self, itemName, target)
                    return (mq.TLO.Me.PctHPs() <= 40 and Targeting.IHaveAggro(100)) or (Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 99)
                        and not Core.IAmMA()
                end,
            },
            {
                name = "Imitate Death",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('AggroFeign') end,
                cond = function(self, aaName, target)
                    return (mq.TLO.Me.PctHPs() <= 40 and Targeting.IHaveAggro(100)) or (Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 99)
                        and not Core.IAmMA()
                end,
            },
            {
                name = "Feign Death",
                type = "Ability",
                load_cond = function(self) return Config:GetSetting('AggroFeign') end,
                cond = function(self, abilityName)
                    return Targeting.IHaveAggro(80) and not Core.IAmMA()
                end,
            },
            {
                name = "MeleeMit",
                type = "Disc",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() < 35
                end,
            },

            {
                name = "Mend",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.PctHPs() < Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "Epic",
                type = "Item",
            },
            {
                name = "OoW_Chest",
                type = "Item",
            },
        },
        ['Burn'] = {
            {
                name = "Fundament: Third Spire of the Sensei",
                type = "AA",
            },
            {
                name = "Zan Fi's Thunderous Whistle", --overwrites infusion of thunder
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Destructive Force",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting("DoAEDamage") then return false end
                    return Combat.AETargetCheck()
                end,
            },
            {
                name = "Silent Strikes",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and (mq.TLO.Me.PctAggro() or 0) > 60
                end,
            },

            {
                name = "Five Point Palm",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoFivePointPalm') end,
                cond = function(self, aaName)
                    return Core.GetMainAssistPctHPs() > 80 and mq.TLO.Me.PctHPs() > 80
                end,
            },
        },
        ['BurnDisc'] = {
            {
                name = "Fordel Star Ring (Tier 1)",
                type = "Item",
                cond = function(self, itemName, target)
                    return Casting.SelfBuffItemCheck(itemName) and Casting.NoDiscActive()
                end,
            },
            {
                name = "Incarnadine Chestwraps (Tier 1)",
                type = "Item",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed
                end,
            },
            {
                name = "Heel",
                type = "Disc",
            },
            {
                name = "Palm",
                type = "Disc",
            },
            {
                name = "FistDisc",
                type = "Disc",
            },
            {
                name = "Speed",
                type = "Disc",
            },
        },
        ['CombatBuff'] = {
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "FistsOfWu",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "Infusion of Thunder",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Me.Buff("Zan Fi's Thunderous Whistle")() then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Eye Gouge",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName, target)
                end,
            },
            {
                name = "Fang",
                type = "Disc",
            },
            {
                name = "Tiger Claw",
                type = "Ability",
            },
            {
                name = "Flying Kick",
                type = "Ability",
            },
        },
    },
    ['PullAbilities']   = {
        {
            id = 'Grappling Strike',
            Type = "AA",
            DisplayName = 'Grappling Strike',
            AbilityName = 'Grappling Strike',
            AbilityRange = 50,
            cond = function(self)
                return mq.TLO.Me.AltAbility('Grappling Strike')
            end,
        },
    },
    ['DefaultConfig']   = {
        ['Mode']            = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes Do?",
            Answer = "Currently there is only DPS mode for Monks, more modes may be added in the future.",
        },
        ['DoFivePointPalm'] = {
            DisplayName = "Do Five Point Palm",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = "Use your Five Point Palm proc AA (slowly drains your life but adds a heavy proc effect).",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['AggroFeign']      = {
            DisplayName = "Emergency Feign",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 102,
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a mob detected as a 'named' by RGMercs (see Named tab)..",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['EmergencyStart']  = {
            DisplayName = "Emergency HP%",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 101,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
    },
    ['ClassFAQ']        = {
        {
            Question = "What is the current status of this class config?",
            Answer = "This class config is currently a Work-In-Progress that was originally based off of the Project Lazarus config.\n\n" ..
                "  Up until the end of T2 progression, it should work quite well, but may need some clickies managed on the clickies tab.\n\n" ..
                "  After that, expect performance to degrade somewhat as not all THF custom spells or items are added, and some Laz-specific entries may remain.\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}

return _ClassConfig
