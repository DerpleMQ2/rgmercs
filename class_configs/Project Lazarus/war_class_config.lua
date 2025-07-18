local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.Targeting")
local Casting      = require("utils.casting")
local ItemManager  = require("utils.item_manager")
local Logger       = require("utils.logger")
local Set          = require('mq.set')

local _ClassConfig = {
    _version            = "3.0 - Project Lazarus",
    _author             = "Algar, Derple",
    ['ModeChecks']      = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
    },
    ['Modes']           = {
        'Tank',
        'DPS',
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Kreljnok's Sword of Eternal Power",
            "Champion's Sword of Eternal Power",
        },
        ['OoW_Chest'] = {
            "Armsmaster's Breastplate",
            "Gladiator's Plate Chestguard of War",
        },
        ['Coating'] = {
            "Blood Drinker's Coating",
        },
    },
    ['AbilitySets']     = {
        ['StandDisc'] = {           -- Timer 2
            "Stonewall Discipline", -- no lost movement on laz, more mitigation than defensive
            "Defensive Discipline",
            "Evasive Discipline",
        },
        ['Fortitude'] = { -- Timer 3
            "Fortitude Discipline",
            "Furious Discipline",
        },
        ['GroupACBuff'] = { -- Has Commanding Voice (Dodge Buff) baked in
            "Field Armorer",
        },
        ['AEBlades'] = {
            "Vortex Blade",
            "Cyclone Blade",
            "Whirlwind Blade",
        },
        ['AddHate'] = {
            "Ancient: Chaos Cry",
            "Bellow of the Mastruq",
            "Incite",
            "Berate",
            "Bellow",
            "Provoke",
        },
        ['AbsorbTaunt'] = {
            "Mock",
        },
        ['EndRegen'] = {
            "Third Wind", -- also does HP
            "Second Wind",
        },
        ['AuraBuff'] = {
            "Champion's Aura",
            "Myrmidon's Aura",
        },
        ['Attention'] = {
            "Unyielding Attention",
            "Undivided Attention",
        },
        ['Onslaught'] = {
            "Savage Onslaught Discipline",
            "Brutal Onslaught Discipline",
        },
        ['StrikeDisc'] = {
            "Fellstrike Discipline",
            "Mighty Strike Discipline",
        },
        ['Throat'] = {
            "Throat Jab",
        },
        ['Flaunt'] = {
            "Flaunt",
        },
        ['ShockDisc'] = { -- Timer 7, defensive stun proc
            "Shocking Defense Discipline",
        },
    },
    ['HelperFunctions'] = {
        --function to determine if we should AE taunt and optionally, if it is safe to do so
        AETauntCheck = function(printDebug)
            local mobs = mq.TLO.SpawnCount("NPC radius 50 zradius 50")()
            local xtCount = mq.TLO.Me.XTarget() or 0

            if (mobs or xtCount) < Config:GetSetting('AETauntCnt') then return false end

            local tauntme = Set.new({})
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater")) and xtarg.PctAggro() < 100 and (xtarg.Distance() or 999) <= 50 then
                    if printDebug then
                        Logger.log_verbose("AETauntCheck(): XT(%d) Counting %s(%d) as a hater eligible to AE Taunt.", i, xtarg.CleanName() or "None",
                            xtarg.ID())
                    end
                    tauntme:add(xtarg.ID())
                end
                if not Config:GetSetting('SafeAETaunt') and #tauntme:toList() > 0 then return true end --no need to find more than one if we don't care about safe taunt
            end
            return #tauntme:toList() > 0 and not (Config:GetSetting('SafeAETaunt') and #tauntme:toList() < mobs)
        end,
        --function to make sure we don't have non-hostiles in range before we use AE damage or non-taunt AE hate abilities
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
        --function to determine if we have enough mobs in range to use a defensive disc
        DefensiveDiscCheck = function(printDebug)
            local xtCount = mq.TLO.Me.XTarget() or 0
            if xtCount < Config:GetSetting('DiscCount') then return false end
            local haters = Set.new({})
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater")) and (xtarg.Distance() or 999) <= 30 then
                    if printDebug then
                        Logger.log_verbose("DefensiveDiscCheck(): XT(%d) Counting %s(%d) as a hater in range.", i, xtarg.CleanName() or "None", xtarg.ID())
                    end
                    haters:add(xtarg.ID())
                end
                if #haters:toList() >= Config:GetSetting('DiscCount') then return true end -- no need to keep counting once this threshold has been reached
            end
            return false
        end,
        BurnDiscCheck = function(self)
            if mq.TLO.Me.ActiveDisc.Name() == "Fortitude Discipline" or mq.TLO.Me.PctHPs() < Config:GetSetting('EmergencyStart') then return false end
            local burnDisc = { "Onslaught", "StrikeDisc", "ChargeDisc", }
            for _, buffName in ipairs(burnDisc) do
                local resolvedDisc = self:GetResolvedActionMapItem(buffName)
                if resolvedDisc and resolvedDisc.RankName() == mq.TLO.Me.ActiveDisc.Name() then return false end
            end
            return true
        end,
        DefenseBuffCheck = function(self)
            local standDisc = Core.GetResolvedActionMapItem('StandDisc')
            if standDisc() and mq.TLO.Me.ActiveDisc.Name() == standDisc.RankName() then return false end
            local defBuff = { "Guardian's Boon", "Guardian's Bravery", "Warlord's Bravery", }
            for _, buffName in ipairs(defBuff) do
                if mq.TLO.Me.Buff(buffName)() then return false end
            end
            return true
        end,
    },
    ['RotationOrder']   = {
        { --Self Buffs
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'HateTools',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function() return Core.IsTanking() end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and Targeting.HateToolsNeeded()
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'AEHateTools',
            state = 1,
            steps = 1,
            timer = 1, -- Don't check this more often than once a second to avoid blowing every ability at once (aggro takes time to update)
            doFullRotation = true,
            load_cond = function()
                return Core.IsTanking() and Config:GetSetting('DoAETaunt') and
                    (Casting.CanUseAA("Area Taunt") or Core.GetResolvedActionMapItem("Epic") or Core.GetResolvedActionMapItem("AEBlades"))
            end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and self.ClassConfig.HelperFunctions.AETauntCheck(true)
            end,
        },
        { --Dynamic weapon swapping if UseBandolier is toggled
            name = 'Weapon Management',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('UseBandolier') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        { --Defensive actions triggered by low HP
            name = 'EmergencyDefenses',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
            end,
        },
        { --Defensive actions used proactively to prevent emergencies
            name = 'Defenses',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= Config:GetSetting('DefenseStart') or Targeting.IsNamed(Targeting.GetAutoTarget()) or
                    self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true)
            end,
        },
        { --Offensive actions to temporarily boost damage dealt
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        { --Non-threat combat actions
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat"
            end,
        },
    },
    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "AuraBuff",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.AuraActiveByName(discSpell.RankName.Name())
                end,
                cond = function(self, discSpell)
                    return not mq.TLO.Me.Aura(1).ID()
                end,
            },
            {
                name = "GroupACBuff",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.IHaveBuff(discSpell)
                end,
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "Infused by Rage",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsTanking() and Casting.SelfBuffAACheck(aaName)
                end,
            },

        },
        ['HateTools'] = {
            { --more valuable on laz because we have less hate tools and no other hatelist + 1 abilities
                name = "Taunt",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Targeting.LostAutoTargetAggro() and Targeting.GetTargetDistance(target) < 30
                end,
            },
            { --8min reuse, save for we still can't get a mob back after trying to taunt, try not to use it on the pull
                name = "Ageless Enmity",
                type = "AA",
                cond = function(self, aaName, target)
                    return (Targeting.IsNamed(target) or Targeting.GetAutoTargetPctHPs() < 90) and Targeting.LostAutoTargetAggro()
                end,
            },
            { --used to jumpstart hatred on named from the outset and prevent early rips from burns
                name = "Attention",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Targeting.IsNamed(target)
                end,
            },
            {
                name = "Blast of Anger",
                type = "AA",
            },
            {
                name = "AddHate",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DetSpellCheck(discSpell)
                end,
            },
            {
                name = "Projection of Fury",
                type = "AA",
                cond = function(self, aaName, target)
                    ---@diagnostic disable-next-line: undefined-field
                    return Targeting.IsNamed(target)
                end,
            },
        },
        ['AEHateTools'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if not Config:GetSetting('DoEpic') then return false end
                    return Config:GetSetting('DoAEDamage')
                end,
            },
            {
                name = "AEBlades",
                type = "Disc",
                cond = function(self, discSpell)
                    return Config:GetSetting('DoAEDamage')
                end,
            },
            {
                name_func = function(self) return Casting.GetFirstAA({ "Enhanced Area Taunt", "Area Taunt", }) end,
                type = "AA",
            },
        },
        ['EmergencyDefenses'] = {
            --Note that in Tank Mode, defensive discs are preemptively cycled on named in the (non-emergency) Defenses rotation
            --Abilities should be placed in order of lowest to highest triggered HP thresholds
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') and Config:GetSetting('DoVetAA')
                end,
            },
            {
                name = "Fortitude",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Warlord's Tenacity",
                type = "AA",
            },
            {
                name = "Warlord's Resurgence",
                type = "AA",
            },
            {
                name = "Mark of the Mage Hunter",
                type = "AA",
            },
            { --here for use in emergencies regarldless of ability staggering below
                name = "StandDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsTanking() and Casting.NoDiscActive()
                end,
            },
        },
        ['Weapon Management'] = {
            {
                name = "Equip Shield",
                type = "CustomFunc",
                active_cond = function(self, target)
                    return mq.TLO.Me.Bandolier("Shield").Active()
                end,
                cond = function()
                    if mq.TLO.Me.Bandolier("Shield").Active() then return false end
                    return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EquipShield')) or (Targeting.IsNamed(Targeting.GetAutoTarget()) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("Shield") end,
            },
            {
                name = "Equip DW",
                type = "CustomFunc",
                active_cond = function(self, target)
                    return mq.TLO.Me.Bandolier("DW").Active()
                end,
                cond = function()
                    if mq.TLO.Me.Bandolier("DW").Active() then return false end
                    return mq.TLO.Me.PctHPs() >= Config:GetSetting('EquipDW') and not (Targeting.IsNamed(Targeting.GetAutoTarget()) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("DW") end,
            },
        },
        ['Defenses'] = {
            { --shares effect with OoW Chest and Warlord's Bravery
                name = "StandDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.ClassConfig.HelperFunctions.DefenseBuffCheck(self)
                end,
            },
            { --shares effect with StandDisc and Warlord's Bravery
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, itemName)
                    return self.ClassConfig.HelperFunctions.DefenseBuffCheck(self)
                end,
            },
            { --shares effect with StandDisc and OoW_Chest
                name = "Warlord's Bravery",
                type = "AA",
                cond = function(self, aaName)
                    return self.ClassConfig.HelperFunctions.DefenseBuffCheck(self)
                end,
            },
            {
                name = "Hold the Line",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Coating",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCoating') then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
        },
        ['Burn'] = {
            {
                name_func = function(self)
                    return string.format("Fundament: %s Spire of the Warlord", Core.IsTanking() and "Third" or "Second")
                end,
                type = "AA",
            },
            {
                name = "Onslaught",
                type = "Disc",
                cond = function(self, discSpell)
                    return not Core.IsTanking() and self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            {
                name = "StrikeDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return not Core.IsTanking() and self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            {
                name = "Vehement Rage",
                type = "AA",
                cond = function(self, aaName)
                    return not Core.IsTanking()
                end,
            },
            {
                name = "Rage of Rallos Zek",
                type = "AA",
            },
            {
                name = "Warlord's Fury",
                type = "AA",
                cond = function(self, aaName, target)
                    return Core.IsTanking() and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Battered Smuggler's Barrel",
                type = "Item",
            },
            {
                name = "Resplendent Glory",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsTanking()
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVetAA')
                end,
            },
        },
        ['Combat'] = {
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Battle Leap",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoBattleLeap') then return false end
                    return not Casting.IHaveBuff(aaName) and not Casting.IHaveBuff('Group Bestial Alignment')
                        ---@diagnostic disable-next-line: undefined-field --Defs are not updated with HeadWet
                        and not mq.TLO.Me.HeadWet() --Stops Leap from launching us above the water's surface
                end,
            },
            {
                name = "AbsorbTaunt",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Core.IsTanking()
                end,
            },
            {
                name = "Flaunt",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return not Core.IsTanking()
                end,
            },
            {
                name = "Gut Punch",
                type = "AA",
                cond = function(self, aaName, target)
                    return Core.IsTanking()
                end,
            },
            {
                name = "Knee Strike",
                type = "AA",
            },
            {
                name = "Throat",
                type = "Disc",
            },
            {
                name = "Rampage",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting("DoAEDamage") or Config:GetSetting('UseRampage') == 1 then return false end
                    return (Config:GetSetting('UseRampage') == 3 or (Config:GetSetting('UseRampage') == 2 and Casting.BurnCheck())) and
                        self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            {
                name = "Call of Challenge",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoSnare') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Press the Attack",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting("DoPress") then return false end
                    return Core.IsTanking()
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Core.ShieldEquipped()
                end,
            },
            {
                name = "Slam",
                type = "Ability",
            },
            {
                name = "Kick",
                type = "Ability",
            },
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
            Max = 2,
            FAQ = "What do the different Modes Do?",
            Answer = "Tank Mode is for when you are the main tank. DPS Mode is for when you are not the main tank and want to focus on damage.",
        },

        --Abilities
        ['DoBattleLeap']    = {
            DisplayName = "Do Battle Leap",
            Category = "Abilities",
            Tooltip = "Do Battle Leap",
            Default = true,
            FAQ = "How do I use Battle Leap?",
            Answer = "Enable [DoBattleLeap] in the settings and you will use Battle Leap.",
        },
        ['DoPress']         = {
            DisplayName = "Do Press the Attack",
            Category = "Abilities",
            Tooltip = "Use the Press to Attack stun/push AA.",
            Default = false,
            FAQ = "Why isn't Press the Attack working?",
            Answer = "This ability must be turned on in the Abilities tab.",
        },
        ['DoSnare']         = {
            DisplayName = "Use Snares",
            Category = "Abilities",
            Tooltip = "Use Call of Challenge to snare enemies.",
            Default = true,
            FAQ = "How do I use Snares?",
            Answer = "Enable [DoSnare] in the settings and you will use Snares.",
        },
        ['DoVetAA']         = {
            DisplayName = "Use Vet AA",
            Category = "Abilities",
            Index = 8,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does WAR use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },

        --AE Damage
        ['DoAEDamage']      = {
            DisplayName = "Do AE Damage",
            Category = "AE Damage",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Discs and AA. **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['AETargetCnt']     = {
            DisplayName = "AE Target Count",
            Category = "AE Damage",
            Index = 2,
            Tooltip = "Minimum number of valid targets before using AE Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['MaxAETargetCnt']  = {
            DisplayName = "Max AE Targets",
            Category = "AE Damage",
            Index = 3,
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
            Category = "AE Damage",
            Index = 4,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },
        ['UseRampage']      = {
            DisplayName = "Rampage Use:",
            Category = "AE Damage",
            Index = 5,
            Tooltip = "Use Rampage 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my WAR using Rampage on these trash mobs?",
            Answer = "By default, we use the Rampage in any combat with enough AE targets (per your AE settings).\n" ..
                "This can be adjusted in the Buffs tab.",
        },

        --Hate Tools
        ['DoAETaunt']       = {
            DisplayName = "Do AE Taunts",
            Category = "Hate Tools",
            Index = 1,
            Tooltip = "Use AE hatred Discs and AA (see FAQ for specifics).",
            Default = false,
            FAQ = "What AE Taunts are used?",
            Answer =
            "If Do AE Taunts is enabled, we will use (Enhanced) Area Taunt as needed. If we also enable Do AE Damage, we will use the blades line, and if the epic is enabled, it will be used.",
        },
        ['AETauntCnt']      = {
            DisplayName = "AE Taunt Count",
            Category = "Hate Tools",
            Index = 2,
            Tooltip = "Minimum number of haters before using AE Taunt Discs or AA.",
            Default = 2,
            Min = 1,
            Max = 30,
            FAQ = "Why don't we use AE taunts on single targets?",
            Answer =
            "AE taunts are configured to only be used if a target has less than 100% hate on you, at whatever count you configure, so abilities with similar conditions may be used instead.",
        },
        ['SafeAETaunt']     = {
            DisplayName = "AE Taunt Safety Check",
            Category = "Hate Tools",
            Index = 3,
            Tooltip =
            "*THIS IS NOT A CHECK FOR MEZ SETTING* Check to ensure there aren't neutral mobs in range we could aggro if AE taunts are used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Taunt Safety Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the taunt.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the taunt not being used when it is safe to do so.",
        },
        --Defenses
        ['DiscCount']       = {
            DisplayName = "Def. Disc. Count",
            Category = "Defenses",
            Index = 1,
            Tooltip = "Number of mobs around you before you use preemptively use Defensive Discs.",
            Default = 4,
            Min = 1,
            Max = 10,
            ConfigType = "Advanced",
            FAQ = "What are the Defensive Discs and what order are they triggered in when the Disc Count is met?",
            Answer = "Carapace, Mantle, Guardian, Unholy Aura, in that order. Note some may also be used preemptively on named, or in emergencies.",
        },
        ['DefenseStart']    = {
            DisplayName = "Defense HP",
            Category = "Defenses",
            Index = 2,
            Tooltip = "The HP % where we will use defensive actions like discs, epics, etc.\nNote that fighting a named will also trigger these actions.",
            Default = 60,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "My SHD health spikes up and down a lot and abilities aren't being triggered, what gives?",
            Answer = "You may need to tailor the emergency thresholds to your current survivability and target choice.",
        },
        ['EmergencyStart']  = {
            DisplayName = "Emergency Start",
            Category = "Defenses",
            Index = 3,
            Tooltip = "The HP % before all but essential rotations are cut in favor of emergency or defensive abilities.",
            Default = 40,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "What rotations are cut during emergencies?",
            Answer = "Snare, Burn, Combat Weave and Combat rotations are disabled when your health is at emergency levels.\nAdditionally, we will only use non-spell hate tools.",
        },
        ['HPCritical']      = {
            DisplayName = "HP Critical",
            Category = "Defenses",
            Index = 4,
            Tooltip =
            "The HP % that we will use disciplines like Deflection, Leechcurse, and Leech Touch.\nMost other rotations are cut to give our full focus to survival (See FAQ).",
            Default = 20,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "What rotations are cut when HP % is critical?",
            Answer =
            "Hate Tools (including AE) and Leech Effect rotations are cut when HP% is critical.\nAdditionally, reaching the emergency threshold would've also cut the Snare, Burn, Combat Weave and Combat Rotations.",
        },

        --Equipment
        ['DoEpic']          = {
            DisplayName = "Do Epic",
            Category = "Equipment",
            Index = 1,
            Tooltip = "Click your Epic Weapon when AE Threat is needed. Also relies on Do AE Damage setting.",
            Default = false,
            FAQ = "How do I use my Epic Weapon?",
            Answer = "Enable Do Epic to click your Epic Weapon.",
        },
        ['DoCoating']       = {
            DisplayName = "Use Coating",
            Category = "Equipment",
            Index = 2,
            Tooltip = "Click your Blood/Spirit Drinker's Coating when defenses are triggered.",
            Default = false,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },
        ['UseBandolier']    = {
            DisplayName = "Dynamic Weapon Swap",
            Category = "Equipment",
            Index = 3,
            Tooltip = "Enable 1H+S/2H swapping based off of current health. ***YOU MUST HAVE BANDOLIER ENTRIES NAMED \"Shield\" and \"DW\" TO USE THIS FUNCTION.***",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why is my Warrior not using Dynamic Weapon Swapping?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"DW\" to use this function.",
        },
        ['EquipShield']     = {
            DisplayName = "Equip Shield",
            Category = "Equipment",
            Index = 4,
            Tooltip = "Under this HP%, you will swap to your \"Shield\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Warrior not using a shield?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"DW\" to use this function.",
        },
        ['EquipDW']         = {
            DisplayName = "Equip DW",
            Category = "Equipment",
            Index = 5,
            Tooltip = "Over this HP%, you will swap to your \"DW\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 75,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Warrior not using DW?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"DW\" to use this function.",
        },
        ['NamedShieldLock'] = {
            DisplayName = "Shield on Named",
            Category = "Equipment",
            Index = 6,
            Tooltip = "Keep Shield equipped for Named mobs(must be in SpawnMaster or named.lua)",
            Default = true,
            FAQ = "Why does my WAR switch to a Shield on puny gray named?",
            Answer = "The Shield on Named option doesn't check levels, so feel free to disable this setting (or Bandolier swapping entirely) if you are farming fodder.",
        },
    },
}

return _ClassConfig
