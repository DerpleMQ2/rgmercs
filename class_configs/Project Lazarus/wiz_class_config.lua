-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

local mq        = require('mq')
local Config    = require('utils.config')
local Modules   = require("utils.modules")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Core      = require("utils.core")
local Logger    = require("utils.logger")

return {
    _version            = "2.0 - Project Lazarus",
    _author             = "Derple, Algar",
    ['Modes']           = {
        'DPS',
        'PBAE',
    },
    ['OnModeChange']    = function(self, mode)
        -- if this is enabled weaves will break.
        Config:GetSettings().WaitOnGlobalCooldown = false
    end,
    ['ItemSets']        = {
        ['Epic'] = {
            "Staff of Phenomenal Power",
            "Staff of Prismatic Power",
        },

        ['OoW_Chest'] = {
            "Academic's Robe of the Arcanists",
            "Spelldeviser's Cloth Robe",
        },
    },
    ['AbilitySets']     = {
        ['IceClaw'] = {
            "Claw of Vox",
            "Claw of Frost",
        },
        ['FireEtherealNuke'] = {
            "Ether Flame",
        },
        ['ChaosNuke'] = {
            "Chaos Flame",
        },
        ['WildNuke'] = {
            "Wildmagic Burst",
        },
        ['FireNuke'] = {
            "Spark of Fire",
            "Draught of Ro",
            "Draught of Fire",
            "Conflagration",
            "Inferno Shock",
            "Flame Shock",
            "Fire Bolt",
            "Shock of Fire",
        },
        ['BigFireNuke'] = { -- Level 51-70, Long Cast, Heavy Damage
            -- "Ancient: Core Fire", --Ether Flame beats this soundly at the same level
            -- "Corona Flare",       --Ether Flame beats this soundly at the same level
            "Ancient: Strike of Chaos",
            "White Fire",
            "Strike of Solusek",
            "Garrison's Superior Sundering",
            "Sunstrike",
        },
        ['IceNuke'] = {
            -- "Ancient: Spear of Gelaqua" -- Commented for now, because of the recast... considering, need to playtest.
            "Spark of Ice",
            "Black Ice",
            "Draught of E`ci",
            "Draught of Ice",
            "Ice Comet",
            "Ice Shock",
            "Frost Shock",
            "Shock of Ice",
            "Blast of Cold",
        },
        ['BigIceNuke'] = { -- Level 60-70, Timed with great Ratio or High Cast Time/Damage
            "Gelidin Comet",
            "Ice Meteor",
            "Ancient: Destruction of Ice", --13s T1
            "Ice Spear of Solist",         --13s T2
        },
        ['MagicNuke'] = {
            "Spark of Lightning",
            "Draught of Lightning",
            "Voltaic Draught",
            "Rend",
            "Lightning Shock",
            "Garrison's Mighty Mana Shock",
            "Shock of Lightning",
        },
        ['BigMagicNuke'] = { -- Level 60-68, High Cast Time/Damage
            "Thundaka",
            "Shock of Magic",
            "Agnarr's Thunder",
            "Elnerick's Electrical Rending",
        },
        ['StunSpell'] = {
            "Telakemara",
            "Telekara",
            "Telaka",
            "Telekin",
            "Markar's Discord",
            "Markar's Clash",
            "Tishan's Clash",
        },
        ['SelfHPBuff'] = {
            "Ether Shield",
            "Shield of Maelin",
            "Shield of the Arcane",
            "Shield of the Magi",
            "Arch Shielding",
            "Greater Shielding",
            "Major Shielding",
            "Shielding",
            "Lesser Shielding",
            "Minor Shielding",
        },
        ['FamiliarBuff'] = {
            "Greater Familiar",
            "Familiar",
            "Lesser Familiar",
            "Minor Familiar",
        },
        ['SelfRune1'] = {
            "Ether Skin",
            "Force Shield",
        },
        ['StripBuffSpell'] = {
            "Annul Magic",
            "Nullify Magic",
            "Cancel Magic",
        },
        ['TwincastSpell'] = {
            "Twincast",
        },
        ['RootSpell'] = {
            "Greater Fetter",
            "Fetter",
            "Paralyzing Earth",
            "Immobilize",
            "Instill",
            "Root",
        },
        ['SnareSpell'] = {
            "Atol's Spectral Shackles",
            "Bonds of Force",
        },
        ['EvacSpell'] = {
            "Evacuate",
            "Lesser Evacuate",
        },
        ['HarvestSpell'] = {
            "Harvest",
        },
        ['JoltSpell'] = {
            "Ancient: Greater Concussion",
            "Concussion",
        },
        -- Lure Spells
        -- ['IceLureNuke'] = {
        --     "Icebane",
        --     "Lure of Ice",
        --     "Lure of Frost",
        -- },
        -- ['FireLureNuke'] = {
        --     "Firebane",
        --     "Lure of Ro",
        --     "Lure of Flame",
        --     "Enticement of Flame",
        -- },
        -- ['MagicLureNuke'] = {
        --     "Lightningbane",
        --     "Lure of Thunder",
        --     "Lure of Lightning",
        -- },
        -- ['StunMagicNuke'] = {
        --     "Spark of Thunder",
        --     "Draught of Thunder",
        --     "Draught of Jiva",
        --     "Force Strike",
        --     "Thunder Strike",
        --     "Force Snap",
        --     "Lightning Bolt",
        -- },
        -- ['MagicRain'] = { -- Last one is at 54, not sustainable
        --     "Pillar of Lightning",
        --     "Tears of Druzzil",
        --     "Energy Storm",
        -- },
        ['IceRain'] = {
            "Gelid Rains",
            "Tears of Marr",
            "Tears of Prexus",
            "Frost Storm",
            "Icestrike",
        },
        ['FireRain'] = {
            "Tears of the Sun",
            "Tears of Ro",
            "Tears of Solusek",
            "Lava Storm",
            "Firestorm",
        },
        -- ['FireLureRain'] = {
        --     "Meteor Storm",
        --     "Tears of Arlyxir",
        -- },
        ['PBTimer4'] = {
            "Circle of Thunder", -- Level 70, Magic
            "Circle of Fire",    -- Level 67, Fire
            "Winds of Gelid",    -- Level 60, Ice
            "Supernova",         -- Level 45, Fire
            "Thunderclap",       -- Level 30, Magic
        },
        ['FireJyll'] = {
            "Jyll's Wave of Heat", -- Level 59
        },
        ['IceJyll'] = {
            "Jyll's Zephyr of Ice", -- Level 56
        },
        ['MagicJyll'] = {
            "Jyll's Static Pulse", -- Level 53
        },
        ['ManaWeave'] = {
            "Mana Weave",
        },
        ['SwarmPet'] = {
            -- "Solist's Frozen Sword", -- Bugged, does not attack on Laz/Emu
            "Flaming Sword of Xuzl", --homework
        },
    },
    ['HelperFunctions'] = {
        --function to make sure we don't have non-hostiles in range before we use AE damage or non-taunt AE hate abilities
        AETargetCheck = function(minCount, printDebug)
            local haters = mq.TLO.SpawnCount("NPC xtarhater radius 80 zradius 50")()
            local haterPets = mq.TLO.SpawnCount("NPCpet xtarhater radius 80 zradius 50")()
            local totalHaters = haters + haterPets
            if totalHaters < minCount or totalHaters > Config:GetSetting('MaxAETargetCnt') then return false end

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
        RainCheck = function(target) -- I made a funny
            if not (Config:GetSetting('DoRain') and Config:GetSetting('DoAEDamage')) then return false end
            return Targeting.GetTargetDistance() >= Config:GetSetting('RainDistance') and Targeting.MobNotLowHP(target)
        end,
    },
    ['RotationOrder']   = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Aggro Management',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctAggro() > (Config:GetSetting('JoltAggro') or 90)
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Targeting.IsNamed(Targeting.GetAutoTarget()) and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        { --Keep things from doing
            name = 'Stun',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoStun') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS(Level70)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 101 and mq.TLO.Me.Level() > 69 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'DPS(FireLowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 70 and Config:GetSetting('ElementChoice') == 1 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'DPS(IceLowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 70 and Config:GetSetting('ElementChoice') == 2 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'DPS(MagicLowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 70 and Config:GetSetting('ElementChoice') == 3 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'DPS(PBAE)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive('PBAE') end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if not Config:GetSetting('DoAEDamage') then return false end
                return combat_state == "Combat" and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true)
            end,
        },
        {
            name = 'Force of Will',
            state = 1,
            steps = 1,
            load_cond = function() return Casting.CanUseAA("Force of Will") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'CombatBuff',
            state = 1,
            steps = 1,
            timer = 30, -- only run every 30 seconds at most.
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'ArcanumWeave',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoArcanumWeave') and Casting.CanUseAA("Acute Focus of Arcanum") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not mq.TLO.Me.Buff("Focus of Arcanum")()
            end,
        },
    },
    ['Rotations']       = {
        ['Burn'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            {
                name = "OoW_Chest",
                type = "Item",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
            },
            {
                name = "Fundament: Second Spire of Arcanum",
                type = "AA",
            },
            {
                name = "Fury of Ro",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            { --Crit Chance AA, will use the first(best) one found
                name_func = function(self)
                    return Casting.GetFirstAA({ "Prolonged Destruction", "Frenzied Devastation", })
                end,
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
            },
            {
                name_func = function(self)
                    return Casting.GetFirstAA({ "Volatile Mana Blaze", "Mana Blaze", "Mana Blast", "Mana Burn", })
                end,
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoManaBurn') end,
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() < 70 and Casting.OkayToNuke(true) and not mq.TLO.Target.FindBuff("detspa 350")()
                end,
            },
            {
                name = "Call of Xuzl",
                type = "AA",
            },
        },
        ['Aggro Management'] =
        {
            {
                name = "Mind Crash",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 90
                end,
            },
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 90
                end,
            },
            {
                name = "A Hole in Space",
                type = "AA",
                cond = function(self)
                    return Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Concussive Intuition",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > Config:GetSetting('JoltAggro')
                end,
            },
            {
                name = "JoltSpell",
                type = "Spell",
                load_cond = function(self) return not Casting.CanUseAA("Concussive Intuition") end,
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > Config:GetSetting('JoltAggro')
                end,
            },
        },
        ['Snare'] = {
            {
                name = "Atol's Shackles",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target)
                end,
            },
            {
                name = "SnareSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target)
                end,
            },
        },
        ['Stun'] = {
            {
                name = "StunSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToDebuff() and Targeting.TargetNotStunned() and not Targeting.IsNamed(target)
                end,
            },
        },
        ['CombatBuff'] =
        {
            {
                name = "Harvest of Druzzil",
                type = "AA",
                load_cond = function(self) return Casting.CanUseAA("Harvest of Druzzil") end,
                allowDead = true,
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('CombatHarvestManaPct')
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                load_cond = function(self) return not Casting.CanUseAA("Harvest of Druzzil") end,
                allowDead = true,
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('CombatHarvestManaPct')
                end,
            },
        },
        ['Force of Will'] = {
            {
                name = "Force of Will",
                type = "AA",
            },
        },
        ['DPS(Level70)'] = {
            {
                name = "ManaWeave",
                type = "Spell",
                cond = function(self, spell, target)
                    return not Casting.IHaveBuff("Weave of Power")
                end,
            },
            {
                name = "ChaosNuke",
                type = "Spell",
            },
            {
                name = "WildNuke",
                type = "Spell",
            },
            {
                name = "Scepter of Incantations",
                type = "Item",
            },
            {
                name = "FireEtherealNuke",
                type = "Spell",
            },
        },
        ['DPS(FireLowLevel)'] = {
            {
                name = "FireRain",
                type = "Spell",
                cond = function(self, spell, target)
                    if not self.ClassConfig.HelperFunctions.RainCheck(target) then return false end
                    return Targeting.AggroCheckOkay()
                end,
            },
            {
                name = "BigFireNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MobNotLowHP(target) and Targeting.AggroCheckOkay()
                end,
            },
            {
                name = "FireNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.AggroCheckOkay()
                end,
            },
        },
        ['DPS(IceLowLevel)'] = {
            {
                name = "IceRain",
                type = "Spell",
                cond = function(self, spell, target)
                    if not self.ClassConfig.HelperFunctions.RainCheck(target) then return false end
                    return Targeting.AggroCheckOkay()
                end,
            },
            {
                name = "BigIceNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MobNotLowHP(target) and Targeting.AggroCheckOkay()
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.AggroCheckOkay()
                end,
            },
        },
        ['DPS(MagicLowLevel)'] = {
            {
                name = "BigMagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MobNotLowHP(target) and Targeting.AggroCheckOkay()
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.AggroCheckOkay()
                end,
            },
        },
        ['DPS(PBAE)'] = {
            {
                name = "PBTimer4",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.AggroCheckOkay() and Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "FireJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.AggroCheckOkay() and Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "IceJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.AggroCheckOkay() and Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "MagicJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.AggroCheckOkay() and Targeting.InSpellRange(spell, target)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return (spell.Level() or 0) > (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            { --Familiar AA, will use the first(best) one found
                name_func = function(self)
                    return Casting.GetFirstAA({ "Kerafyrm's Prismatic Familiar", "Ro's Flaming Familiar", "Improved Familiar", })
                end,
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "FamiliarBuff",
                type = "Spell",
                load_cond = function(self) return not Casting.CanUseAA("Improved Familiar") end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                load_cond = function(self) return Casting.CanUseAA("Harvest of Druzzil") end,
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct')
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                load_cond = function(self) return not Casting.CanUseAA("Harvest of Druzzil") end,
                cond = function(self, spell)
                    return Casting.CastReady(spell) and mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct')
                end,
            },
        },
        ['ArcanumWeave'] = {
            {
                name = "Empowered Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Enlightened Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Acute Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
    },
    ['Spells']          = {
        {
            gem = 1,
            spells = {
                { name = "ManaWeave", },
                { name = "FireNuke",  cond = function() return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "IceNuke",   cond = function() return Config:GetSetting('ElementChoice') == 2 end, },
                { name = "MagicNuke", cond = function() return Config:GetSetting('ElementChoice') == 3 end, },

            },
        },
        {
            gem = 2,
            spells = {
                { name = "FireEtherealNuke", },
                { name = "BigFireNuke",      cond = function() return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "BigIceNuke",       cond = function() return Config:GetSetting('ElementChoice') == 2 end, },
                { name = "BigMagicNuke",     cond = function() return Config:GetSetting('ElementChoice') == 3 end, },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "WildNuke", },
                { name = "FireRain",     cond = function() return Config:GetSetting('DoRain') and Config:GetSetting('ElementChoice') == 1 end, },
                { name = "IceRain",      cond = function() return Config:GetSetting('DoRain') and Config:GetSetting('ElementChoice') == 2 end, },
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "ChaosNuke", },
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "PBTimer4",     cond = function() return Core.IsModeActive('PBAE') end, },
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "FireJyll",     cond = function() return Core.IsModeActive('PBAE') end, },
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "IceJyll",      cond = function() return Core.IsModeActive('PBAE') end, },
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", },


            },
        },
        {
            gem = 8,
            spells = {
                { name = "MagicJyll",    cond = function() return Core.IsModeActive('PBAE') end, },
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", }, },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", },

            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HarvestSpell", cond = function() return not Casting.CanUseAA("Harvest of Druzzil") end, },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell",    cond = function() return not Casting.CanUseAA("Concussive Intuition") end, },
                { name = "SelfRune1", },
                { name = "EvacSpell",    cond = function() return not Casting.CanUseAA("Exodus") end, },
                { name = "SelfHPBuff", },
            },
        },
    },
    ['DefaultConfig']   = {
        ['Mode']                 = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes Do?",
            Answer = "Wizard only has a single mode, but the spells used will adjust based on your level range.",
        },

        -- Damage (ST)
        ['ElementChoice']        = {
            DisplayName = "Element Choice:",
            Category = "Damage",
            Index = 1,
            Tooltip = "Choose an element to focus on.",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Ice', 'Magic', },
            Default = 1,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            FAQ = "WIP?",
            Answer = "WIP.",
        },
        ['DoManaBurn']           = {
            DisplayName = "Use Mana Burn AA",
            Category = "Damage",
            Index = 2,
            Tooltip = "Enable usage of the Mana Burn series of AA.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Can I use Mana Burn?",
            Answer = "Yes, you can enable [DoManaBurn] to use Mana Burn when it is available.",
        },
        ['DoRain']               = {
            DisplayName = "Do Rain",
            Category = "Damage",
            Index = 3,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            Tooltip = "**WILL BREAK MEZ** Use your selected element's Rain Spell as a single-target nuke. **WILL BREAK MEZ***",
            Default = false,
            FAQ = "Why is Rain being used a single target nuke?",
            Answer = "In some situations, using a Rain can be an efficient single target nuke at low levels.\n" ..
                "Note that PBAE spells tend to be superior for AE dps at those levels.",
        },
        ['RainDistance']         = {
            DisplayName = "Min Rain Distance",
            Category = "Damage",
            Index = 4,
            ConfigType = "Advanced",
            Tooltip = "The minimum distance a target must be to use a Rain (Rain AE Range: 25').",
            Default = 30,
            Min = 0,
            Max = 100,
            FAQ = "Why does minimum rain distance matter?",
            Answer = "Rain spells, if cast close enough, can damage the caster. The AE range of a Rain is 25'.",
        },

        --Damage (AE)
        ['DoAEDamage']           = {
            DisplayName = "Do AE Damage",
            Category = "Damage (PBAE)",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['PBAETargetCnt']        = {
            DisplayName = "PBAE Tgt Cnt",
            Category = "Damage (PBAE)",
            Index = 5,
            Tooltip = "Minimum number of valid targets before using PB Spells like the of Flame line.",
            Default = 4,
            Min = 1,
            Max = 10,
            FAQ = "Why am I not using my PBAE spells?",
            Answer =
            "You can adjust the PB Target Count to control when you will use actions PBAE Spells such as the of Flame line.",
        },
        ['MaxAETargetCnt']       = {
            DisplayName = "Max AE Targets",
            Category = "Damage (PBAE)",
            Index = 6,
            Tooltip =
            "Maximum number of valid targets before using AE Spells, Disciplines or AA.\nUseful for setting up AE Mez at a higher threshold on another character in case you are overwhelmed.",
            Default = 6,
            Min = 2,
            Max = 30,
            FAQ = "How do I take advantage of the Max AE Targets setting?",
            Answer =
            "By limiting your max AE targets, you can set an AE Mez count that is slightly higher, to allow for the possiblity of mezzing if you are being overwhelmed.",
        },
        ['SafeAEDamage']         = {
            DisplayName = "AE Proximity Check",
            Category = "Damage (PBAE)",
            Index = 7,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },

        -- Utility
        ['JoltAggro']            = {
            DisplayName = "Jolt Aggro %",
            Category = "Utility",
            Index = 1,
            Tooltip = "Aggro at which to use Jolt",
            Default = 90,
            Min = 1,
            Max = 100,
            FAQ = "Can I customize when to use Jolt?",
            Answer = "Yes, you can set the aggro % at which to use Jolt with the [JoltAggro] setting.",
        },
        ['DoSnare']              = {
            DisplayName = "Use Snares",
            Category = "Utility",
            Index = 3,
            Tooltip = "Use Snare Spells.",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not snaring?",
            Answer = "Make sure Use Snares is enabled in your class settings.",
        },
        ['SnareCount']           = {
            DisplayName = "Snare Max Mob Count",
            Category = "Utility",
            Index = 4,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
            Min = 1,
            Max = 99,
            FAQ = "Why is my Shadow Knight Not snaring?",
            Answer = "Make sure you have [DoSnare] enabled in your class settings.\n" ..
                "Double check the Snare Max Mob Count setting, it will prevent snare from being used if there are more than [x] mobs on aggro.",
        },
        ['DoStun']               = {
            DisplayName = "Do Stun",
            Category = "Utility",
            Index = 5,
            Tooltip = "Use your Stun Nukes (Stun with DD, not mana efficient).",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "WIP?",
            Answer =
            "WIP.",
        },
        ['HarvestManaPct']       = {
            DisplayName = "Harvest Mana %",
            Category = "Utility",
            Index = 7,
            ConfigType = "Advanced",
            Tooltip = "What Mana % to hit before using a harvest spell or aa.",
            Default = 85,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
        ['CombatHarvestManaPct'] = {
            DisplayName = "Combat Harvest %",
            Category = "Utility",
            Index = 8,
            ConfigType = "Advanced",
            Tooltip = "What Mana % to hit before using a harvest spell or aa in Combat.",
            Default = 60,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
        ['DoArcanumWeave']       = {
            DisplayName = "Weave Arcanums",
            Category = "Utility",
            Index = 9,
            Tooltip = "Weave Empowered/Enlighted/Acute Focus of Arcanum into your standard combat routine (Focus of Arcanum is saved for burns).",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = true,
            FAQ = "What is an Arcanum and why would I want to weave them?",
            Answer =
            "The Focus of Arcanum series of AA decreases your spell resist rates.\nIf you have purchased all four, you can likely easily weave them to keep 100% uptime on one.",
        },
    },
}
