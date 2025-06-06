local mq           = require('mq')
local Config       = require('utils.config')
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Logger       = require("utils.logger")
local Core         = require("utils.core")

local _ClassConfig = {
    _version            = "2.0 - Live",
    _author             = "Algar, Derple",
    ['Modes']           = {
        'DPS',
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Transcended Fistwraps of Immortality",
            "Fistwraps of Celestial Discipline",
        },
        ['Coating'] = {
            "Spirit Drinker's Coating",
            "Blood Drinker's Coating",
        },
    },
    ['AbilitySets']     = {
        ['EndRegen'] = {
            --Timer 13, can't be used in combat
            "Second Wind", -- Level 72
            "Third Wind",
            "Fourth Wind",
            "Respite",
            "Reprieve",
            "Rest",
            "Breather", --Level 101
        },
        ['CombatEndRegen'] = {
            --Timer 13, can be used in combat.
            "Hiatus", --Level 106
            "Relax",
            "Night's Calming",
            "Convalesce",
        },
        ['MonkAura'] = {
            "Disciple's Aura",
            "Master's Aura",
        },
        ['Dicho'] = {
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
        ['Precision4'] = {
            "Doomwalker's Precision Strike",
            "Firewalker's Precision Strike",
            "Icewalker's Precision Strike",
            "Bloodwalker's Precision Strike",
            "Fatewalker's Precision Strike",
        },
        ['Precision5'] = {
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
        ['EarthDisc'] = {
            -- EarthDisc - Melee Mitigation
            "Earthwalk Discipline",
            "Earthforce Discipline",
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
        ['FistDisc'] = {
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
    ['HelperFunctions'] = {
        BurnDiscCheck = function(self)
            if mq.TLO.Me.PctHPs() < Config:GetSetting('EmergencyStart') then return false end
            local burnDisc = { "Heel", "Speed", "FistDisc", "Palm", }
            for _, buffName in ipairs(burnDisc) do
                local resolvedDisc = self:GetResolvedActionMapItem(buffName)
                if resolvedDisc and resolvedDisc.RankName() == mq.TLO.Me.ActiveDisc.Name() then return false end
            end
            return true
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
        {
            name = 'Precision',
            state = 1,
            steps = 1,
            load_cond = function(self) return self:GetResolvedActionMapItem('Precision1') end,
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
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    if self:GetResolvedActionMapItem("CombatEndRegen") then return false end
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "CombatEndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Breaths",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Mend",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.PctHPs() < 50
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Imitate Death",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('AggroFeign') then return false end
                    return (mq.TLO.Me.PctHPs() <= 40 and Targeting.IHaveAggro(100)) or (Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 99)
                        and not Core.IAmMA
                end,
            },
            {
                name = "Feign Death",
                type = "Ability",
                cond = function(self, abilityName)
                    if not Config:GetSetting('AggroFeign') then return false end
                    return Targeting.IHaveAggro(95) and not Core.IAmMA
                end,
            },
            {
                name = "Defy Death",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() < 25
                end,
            },
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoVetAA') then return false end
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
                name = "Coating",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCoating') then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Epic",
                type = "Item",
            },
        },
        ['Burn'] = {
            { -- 5m reuse
                name = "Dicho",
                type = "Disc",
            },
            { -- 5m reuse
                name = "Ton Po's Stance",
                type = "AA",
            },
            {
                name = "Heel",
                type = "Disc",
            },
            {
                name = "Speed",
                type = "Disc",
            },
            {
                name = "FistDisc",
                type = "Disc",
            },
            {
                name = "Palm",
                type = "Disc",
            },
            {
                name = "Spire of the Sensei",
                type = "AA",
            },
            {
                name = "Infusion of Thunder",
                type = "AA",
            },
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            { --10m reuse
                name = "CraneStance",
                type = "Disc",
            },
            { --20m reuse, using NOT burndisccheck means we will only use this with a burn disc active
                name = "Poise",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            { --pairs with Speed Focus Disc, AE, T2
                name = "Destructive Force",
                type = "AA",
                cond = function(self, aaName)
                    local speedDisc = self:GetResolvedActionMapItem("Speed")
                    if not Config:GetSetting("DoAEDamage") or not speedDisc then return false end
                    return mq.TLO.Me.ActiveDisc.Name() == speedDisc.RankName() and self.ClassConfig.HelperFunctions.AETargetCheck()
                end,
            },
            { --pairs with Speed Focus Disc, single target, T2
                name = "Focused Destructive Force",
                type = "AA",
                cond = function(self, aaName)
                    local speedDisc = self:GetResolvedActionMapItem("Speed")
                    if Config:GetSetting("DoAEDamage") or not speedDisc then return false end
                    return mq.TLO.Me.ActiveDisc.Name() == speedDisc.RankName()
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
                name = "Swift Tails' Chant",
                type = "AA",
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVetAA')
                end,
            },
        },
        ['CombatBuff'] = {
            {
                name = "CombatEndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Drunken",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "Zan Fi's Whistle",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "FistsOfWu",
                type = "Disc",
                cond = function(self, discSpell)
                    if mq.TLO.Me.Level() >= 100 then return false end
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "Alliance",
                type = "Disc",
                cond = function(self, discSpell)
                    if not Config:GetSetting('DoAlliance') then return false end
                    return not Casting.TargetHasBuff(discSpell.Trigger(1))
                end,
            },
            {
                name = "Storm",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "EarthDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Synergy",
                type = "Disc",
            },
            {
                name = "Curse",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "Two-Finger Wasp Touch",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "Fists",
                type = "Disc",
            },
            {
                name = "Fang",
                type = "Disc",
            },
            {
                name = "Shuriken",
                type = "Disc",
            },
            {
                name = "Five Point Palm",
                type = "AA",
            },
            {
                name = "Intimidation",
                type = "Ability",
                cond = function(self, abilityName)
                    return Casting.AARank("Intimidation") > 1
                end,
            },
            {
                name = "Flying Kick",
                type = "Ability",
            },
            {
                name = "Eagle Strike",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.PctEndurance() < 25
                end,
            },
            {
                name = "Tiger Claw",
                type = "Ability",
            },
        },
        ['Precision'] = {
            {
                name = "Precision5",
                type = "Disc",
            },
            {
                name = "Precision4",
                type = "Disc",
            },
            {
                name = "Precision3",
                type = "Disc",
            },
            {
                name = "Precision2",
                type = "Disc",
            },
            {
                name = "Precision1",
                type = "Disc",
            },
        },
    },
    ['PullAbilities']   = {
        {
            id = 'Distant Strike',
            Type = "AA",
            DisplayName = 'Distant Strike',
            AbilityName = 'Distant Strike',
            AbilityRange = 300,
            cond = function(self)
                return mq.TLO.Me.AltAbility('Distant Strike')
            end,
        },
    },
    ['DefaultConfig']   = {
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
            Answer = "Currently there is only DPS mode for Monks, more modes may be added in the future.",
        },
        ['DoIntimidation'] = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoVetAA']        = {
            DisplayName = "Use Vet AA",
            Category = "Abilities",
            Index = 8,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does MNK use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },
        ['DoAEDamage']     = {
            DisplayName = "Do AE Damage",
            Category = "Abilities",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Discs and AA. **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['AETargetCnt']    = {
            DisplayName = "AE Target Count",
            Category = "Abilities",
            Index = 2,
            Tooltip = "Minimum number of valid targets before using AE Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['MaxAETargetCnt'] = {
            DisplayName = "Max AE Targets",
            Category = "Abilities",
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
        ['SafeAEDamage']   = {
            DisplayName = "AE Proximity Check",
            Category = "Abilities",
            Index = 5,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },
        ['AggroFeign']     = {
            DisplayName = "Emergency Feign",
            Category = "Abilities",
            Index = 9,
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
            Default = true,
            FAQ = "How do I use my Feign Death?",
            Answer = "Make sure you have [AggroFeign] enabled.\n" ..
                "This will use your Feign Death AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
        },
        ['EmergencyStart'] = {
            DisplayName = "Emergency HP%",
            Category = "Abilities",
            Index = 10,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "How do I use my Emergency Mitigation Abilities?",
            Answer = "Make sure you have [EmergencyStart] set to the HP % before we begin to use emergency mitigation abilities.",
        },
        ['DoChestClick']   = {
            DisplayName = "Do Chest Click",
            Category = "Abilities",
            Index = 8,
            Tooltip = "Click your chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            ConfigType = "Advanced",
            FAQ = "What is a Chest Click?",
            Answer = "Most Chest slot items after level 75ish have a clickable effect.\n" ..
                "MNK is set to use theirs during burns, so long as the item equipped has a clicky effect.",
        },
        ['DoCoating']      = {
            DisplayName = "Use Coating",
            Category = "Equipment",
            Index = 6,
            Tooltip = "Click your Blood/Spirit Drinker's Coating in an emergency.",
            Default = false,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },
    },
}

return _ClassConfig
