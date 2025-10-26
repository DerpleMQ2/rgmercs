local mq        = require('mq')
local Config    = require('utils.config')
local Core      = require("utils.core")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Strings   = require("utils.strings")
local Logger    = require("utils.logger")

return {
    _version            = "2.1 - EQ Might (WIP)",
    _author             = "Derple, Algar, mackal",
    ['ModeChecks']      = {
        IsRezing = function() return mq.TLO.FindItem("Legendary Staff of Forbidden Rites")() end,
    },
    ['Modes']           = {
        'DPS',
    },
    ['ItemSets']        = {
        ['OoW_Chest'] = {
            "Whisperer's Ascendant Tunic of Shadows",
            "Whispering Tunic of Shadows",
            "Darkraider's Vest",
        },
        ['Epic'] = {
            "Fatestealer",
            "Nightshade, Blade of Entropy",
        },
    },
    ['AbilitySets']     = {
        ["ThiefBuff"] = {
            "Brigand's Gaze", -- Level 70
            "Thief's Eyes",   -- Level 65
        },
        ["Kinesthetics"] = {
            "Kinesthetics Discipline", -- Level 57
        },
        ['Duelist'] = {
            "Duelist Discipline", -- Level 59
        },
        ["ChanceDisc"] = {
            "Twisted Chance Discipline", -- Level 65
            "Deadeye Discipline",        -- Level 54
        },
        ["Frenzied"] = {
            "Frenzied Stabbing Discipline", -- Level 70
        },
        ["SneakAttack"] = {
            "Razorarc",              -- Level 70
            "Daggerfall",            -- Level 69
            "Ancient: Chaos Strike", -- Level 65
            "Kyv Strike",            -- Level 65
            "Assassin's Strike",     -- Level 63
            "Thief's Vengeance",     -- Level 52
            "Sneak Attack",          -- Level 20
        },
        ["FellStrike"] = {
            "Assault", -- Level 70 on Laz
        },
        ["Pinpoint"] = {
            "Pinpoint Vulnerability", -- Level 69 on Laz
        },
        ['EndRegen'] = {
            "Third Wind",
            --"Second Wind",
        },
        ["CADisc"] = {
            "Counterattack Discipline",
        },
        ["AimDisc"] = {
            "Deadly Aim Discipline", --  Level 68
        },
        ['Precision'] = {
            "Deadly Precision Discipline",
        },
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
            name = 'Aggro Management',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctAggro() > Config:GetSetting('HideAggro')
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or (Targeting.IsNamed(Targeting.GetAutoTarget()) and mq.TLO.Me.PctAggro() > 99))
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
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
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['Rotations']       = {
        ['Burn'] = {
            {
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, itemName, target)
                    return Casting.DetItemCheck(itemName, target)
                end,
            },
            {
                name = "Rogue's Fury",
                type = "AA",
            },
            {
                name = "Fundament: Second Spire of the Rake",
                type = "AA",
            },
            {
                name = "Pinpoint",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Casting.DetSpellCheck(discSpell, target)
                end,
            },
            {
                name = "Dirty Fighting",
                type = "AA",
            },
        },
        ['BurnDisc'] = {
            {
                name = "Frenzied",
                type = "Disc",
            },
            {
                name = "Duelist",
                type = "Disc",
            },
            {
                name = "ChanceDisc",
                type = "Disc",
            },
            {
                name = "Kinesthetics",
                type = "Disc",
            },
            {
                name = "Precision",
                type = "Disc",
            },
        },
        ["Aggro Management"] = {
            {
                name = "Escape",
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Hide",
                type = "Ability",
                pre_activate = function(self, abilityName)
                    Core.DoCmd("/attack off")
                    mq.delay(100, function() return not mq.TLO.Me.Combat() end)
                end,
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > Config:GetSetting('HideAggro')
                end,
                post_activate = function(self, abilityName, success)
                    if not mq.TLO.Me.Combat() then
                        Core.DoCmd("/attack on")
                    end
                end,
            },
            {
                name = "Sleight of Hand",
                type = "AA",
            },
        },
        ['DPS'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if Config:GetSetting('UseEpic') == 1 then return false end
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "Ligament Slice",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName, target)
                end,
            },
            {
                name = "Backstab",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Casting.CanUseAA("Chaotic Stab") or mq.TLO.Stick.Behind()
                end,
            },
            {
                name = "FellStrike",
                type = "Disc",
            },
            {
                name = "Twisted Shank",
                type = "AA",
            },
            {
                name = "PoisonName",
                type = "ClickyItem",
                cond = function(self)
                    return Casting.SelfBuffItemCheck(Config:GetSetting('PoisonName'))
                end,
            },
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Tumble",
                type = "AA",
            },
            {
                name = "CADisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Targeting.IHaveAggro(100)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "ThiefBuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "PoisonClicky",
                type = "ClickyItem",
                active_cond = function(self, _)
                    return (mq.TLO.FindItemCount(Config:GetSetting('PoisonName'))() or 0) >= Config:GetSetting('PoisonItemCount')
                end,
                cond = function(self, _)
                    return (mq.TLO.FindItemCount(Config:GetSetting('PoisonName'))() or 0) < Config:GetSetting('PoisonItemCount') and
                        mq.TLO.Me.ItemReady(Config:GetSetting('PoisonClicky'))()
                end,
            },
            {
                name = "PoisonName",
                type = "ClickyItem",
                active_cond = function(self, _)
                    local poisonItem = mq.TLO.FindItem(Config:GetSetting('PoisonName'))
                    return poisonItem and poisonItem() and Casting.IHaveBuff(poisonItem.Spell.ID() or 0)
                end,
                cond = function(self)
                    return Casting.SelfBuffItemCheck(Config:GetSetting('PoisonName'))
                end,
            },
            {
                name = "Envenomed Blades",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Hide & Sneak",
                type = "CustomFunc",
                active_cond = function(self)
                    return mq.TLO.Me.Invis() and mq.TLO.Me.Sneaking()
                end,
                cond = function(self)
                    return Config:GetSetting('DoHideSneak')
                end,
                custom_func = function(_)
                    if Config:GetSetting('ChaseOn') then
                        if not mq.TLO.Me.Sneaking() then
                            Core.DoCmd("/doability sneak")
                        end
                    else
                        if mq.TLO.Me.AbilityReady("hide")() then Core.DoCmd("/doability hide") end
                        if mq.TLO.Me.AbilityReady("sneak")() then Core.DoCmd("/doability sneak") end
                    end
                    return true
                end,
            },
        },
    },
    ['HelperFunctions'] = {
        DoRez = function(self, corpseId)
            if mq.TLO.Me.ItemReady("Legendary Staff of Forbidden Rites")() then
                if Casting.OkayToRez(corpseId) then
                    return Casting.UseItem("Legendary Staff of Forbidden Rites", corpseId)
                end
            end

            return false
        end,
        PreEngage = function(target)
            local openerAbility = Core.GetResolvedActionMapItem('SneakAttack')

            if not Config:GetSetting("DoOpener") or not openerAbility then return end

            Logger.log_debug("\ayPreEngage(): Testing Opener ability = %s", openerAbility or "None")

            if mq.TLO.Me.CombatAbilityReady(openerAbility)() and not mq.TLO.Me.AbilityReady("Hide")() and mq.TLO.Me.AbilityTimer("Hide")() <= math.max(0, mq.TLO.Me.AbilityTimerTotal("Hide")() - 4000) and mq.TLO.Me.Invis() then
                Casting.UseDisc(openerAbility, target)
                Logger.log_debug("\agPreEngage(): Using Opener ability = %s", openerAbility or "None")
            else
                Logger.log_debug("\arPreEngage(): NOT using Opener ability = %s, DoOpener = %s, Hide Ready = %s, Hide Timer = %d, Invis = %s", openerAbility or "None",
                    Strings.BoolToColorString(Config:GetSetting("DoOpener")), Strings.BoolToColorString(mq.TLO.Me.AbilityReady("Hide")()),
                    mq.TLO.Me.AbilityTimer("Hide")(), Strings.BoolToColorString(mq.TLO.Me.Invis()))
            end
        end,
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
        UnwantedAggroCheck = function(self) --Self-Explanatory. Add isTanking to this if you ever make a mode for roguetanks!
            if Targeting.GetXTHaterCount() == 0 or Core.IAmMA() or mq.TLO.Group.Puller.ID() == mq.TLO.Me.ID() then return false end
            return Targeting.IHaveAggro(100)
        end,
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
            FAQ = "What do the different Modes do?",
            Answer = "Currently Rogues only have DPS mode, this may change in the future",
        },
        -- Poison
        ['PoisonName']      = {
            DisplayName = "Poison Item",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Tooltip = "Click the poison you want to use here.",
            Type = "ClickyItem",
            Default = "",
        },
        ['PoisonClicky']    = {
            DisplayName = "Poison Clicky",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Tooltip = "Click the poison summoner you want to use here.",
            Type = "ClickyItem",
            Default = "",
        },
        ['PoisonItemCount'] = {
            DisplayName = "Poison Item Count",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Tooltip = "Min number of poison before we start summoning more.",
            Default = 3,
            Min = 1,
            Max = 50,
        },
        -- Abilities
        ['DoHideSneak']     = {
            DisplayName = "Do Hide/Sneak Click",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = "Use Hide/Sneak during Downtime.",
            Default = true,
        },
        ['DoOpener']        = {
            DisplayName = "Use Openers",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Use Sneak Attack line to start combat (e.g, Daggerslash).",
            Default = true,
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
        ['EmergencyStart']  = {
            DisplayName = "Emergency HP%",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 101,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['HideAggro']       = {
            DisplayName = "Hide Aggro%",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 102,
            Tooltip = "Your Aggro % before we will attempt to Hide from our current target.",
            Default = 90,
            Min = 1,
            Max = 100,
        },
        --Equipment
        ['UseEpic']         = {
            DisplayName = "Epic Use:",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
    },
    ['ClassFAQ']        = {
        [1] = {
            Question = "What is the current status of this class config?",
            Answer = "This class config is currently a Work-In-Progress that was originally based off of the Project Lazarus config.\n\n" ..
                "  Up until level 65, it should work quite well, but may need some clickies managed on the clickies tab.\n\n" ..
                "  After level 65, expect performance to degrade somewhat as not all EQMight custom spells or items are added, and some Laz-specific entries may remain.\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}
