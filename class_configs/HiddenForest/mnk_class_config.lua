local mq           = require('mq')
local Config       = require('utils.config')
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Logger       = require("utils.logger")
local Core         = require("utils.core")

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
        AETargetCheck = function(printDebug)
            local haters = mq.TLO.SpawnCount("NPC xtarhater radius 80 zradius 50")()
            local haterPets = mq.TLO.SpawnCount("NPCpet xtarhater radius 80 zradius 50")()
            local totalHaters = haters + haterPets
            if totalHaters < Config:GetSetting('AETargetCnt') or totalHaters > Config:GetSetting('MaxAETargetCnt') then return false end

            if Config:GetSetting('SafeAEDamage') then
                local npcs = mq.TLO.SpawnCount("NPC radius 80 zradius 50")()
                local npcPets = mq.TLO.SpawnCount("NPCpet radius 80 zradius 50")()
                if totalHaters < (npcs + npcPets) then
                    if printDebug then
                        Logger.log_verbose("AETargetCheck(): %d mobs in range but only %d xtarget haters, blocking AE damage actions.", npcs + npcPets, haters + haterPets)
                    end
                    return false
                end
            end

            return true
        end,
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
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or (Targeting.IsNamed(Targeting.GetAutoTarget()) and mq.TLO.Me.PctAggro() > 99))
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
                    return (mq.TLO.Me.PctHPs() <= 40 and Targeting.IHaveAggro(100)) or (Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 99)
                        and not Core.IAmMA
                end,
            },
            {
                name = "Imitate Death",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('AggroFeign') end,
                cond = function(self, aaName, target)
                    return (mq.TLO.Me.PctHPs() <= 40 and Targeting.IHaveAggro(100)) or (Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 99)
                        and not Core.IAmMA
                end,
            },
            {
                name = "Feign Death",
                type = "Ability",
                load_cond = function(self) return Config:GetSetting('AggroFeign') end,
                cond = function(self, abilityName)
                    return Targeting.IHaveAggro(80) and not Core.IAmMA
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
                    return self.ClassConfig.HelperFunctions.AETargetCheck()
                end,
            },
            {
                name = "Silent Strikes",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and (mq.TLO.Me.PctAggro() or 0) > 60
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
                    return Targeting.IsNamed(target)
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
        ['DoAEDamage']      = {
            DisplayName = "Do AE Damage",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 101,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Discs and AA. **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['AETargetCnt']     = {
            DisplayName = "AE Target Count",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 102,
            Tooltip = "Minimum number of valid targets before using AE Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
        },
        ['MaxAETargetCnt']  = {
            DisplayName = "Max AE Targets",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 103,
            Tooltip =
            "Maximum number of valid targets before using AE Spells, Disciplines or AA.\nUseful for setting up AE Mez at a higher threshold on another character in case you are overwhelmed.",
            Default = 5,
            Min = 2,
            Max = 30,
            FAQ = "How do I take advantage of the Max AE Targets setting?",
            Answer =
            "By limiting your max AE targets, you can set an AE Mez count that is slightly higher, to allow for the possiblity of mezzing if you are being overwhelmed.",
        },
        ['SafeAEDamage']    = {
            DisplayName = "AE Proximity Check",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 104,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
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
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
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
        [1] = {
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
