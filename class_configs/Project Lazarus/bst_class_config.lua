local mq        = require('mq')
local Combat    = require('utils.combat')
local Config    = require('utils.config')
local Core      = require("utils.core")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Logger    = require("utils.logger")

return {
    _version              = "1.5 - Project Lazarus",
    _author               = "Derple, Algar",
    ['Modes']             = {
        'DPS',
    },
    ['ModeChecks']        = {
        IsHealing = function() return true end,
    },
    ['ItemSets']          = {                  --TODO: Add Omens Chest
        ['Epic'] = {
            "Savage Lord's Totem",             -- Epic    -- Epic 1.5
            "Spiritcaller Totem of the Feral", -- Epic    -- Epic 2.0
        },
        ['OoW_Chest'] = {
            "Beast Tamer's Jerkin",
            "Savagesoul Jerkin of the Wilds",
        },
    },
    ['AbilitySets']       = { --TODO/Under Consideration: Add AoE Roar line, add rotation entry (tie it to Do AoE setting), swap in instead of lance 2, especially since the last lance2 is level 112
        ['SwarmPet'] = {
            -- Swarm Pet
            "Reptilian Venom",
            "Amphibious Toxin",
        },
        ['Icelance1'] = {
            -- Lance 1 Timer 7 Ice Nuke Fast Cast
            "Blast of Frost",        -- Level 12 - Timer 7
            "Frost Shard",           -- Level 47 - Timer 7
            "Blizzard Blast",        -- Level 59 - Timer ???
            "Frost Spear",           -- Level 63 - Timer 7
            "Ancient: Frozen Chaos", -- Level 65 - Timer 7
            "Ancient: Savage Ice",   -- Level 70 - Timer 7
        },
        ['Icelance2'] = {
            -- Lance 2 Timer 11 Ice Nuke Fast Cast
            "Ice Spear",       -- Level 33 - Timer 11
            "Ice Shard",       -- Level 54 - Timer 11
            "Trushar's Frost", -- Level 65 - Timer 11
            "Glacier Spear",   -- Level 69 - Timer 11
        },
        ['EndemicDot'] = {
            -- Disease DoT Instant Cast
            "Sicken",           -- Level 14
            "Malaria",          -- Level 40
            "Plague",           -- Level 65
            "Festering Malady", -- Level 70
        },
        ['BloodDot'] = {
            -- Poison DoT Instant Cast
            "Tainted Breath",     -- Level 19
            "Envenomed Breath",   -- Level 35
            "Venom of the Snake", -- Level 52
            "Scorpion Venom",     -- Level 61
            "Turepta Blood",      -- Level 65
            "Chimera Blood",      -- Level 66
        },
        ['SlowSpell'] = {
            -- Slow Spell
            "Drowsy",          -- Level 20
            "Sha's Lethargy",  -- Level 50
            "Sha's Advantage", -- Level 60
            "Sha's Revenge",   -- Level 65
            "Sha's Legacy",    -- Level 70
        },
        ['HealSpell'] = {
            "Salve",             -- Level 1
            "Minor Healing",     -- Level 6
            "Light Healing",     -- Level 18
            "Healing",           -- Level 28
            "Greater Healing",   -- Level 38
            "Spirit Salve",      -- Level 48
            "Chloroblast",       -- Level 59
            "Trushar's Mending", -- Level 65
            "Muada's Mending",   -- Level 67
        },
        ['PetHealSpell'] = {
            "Sharik's Replenishing",   -- Level 9
            "Keshuval's Rejuvenation", -- Level 15
            "Herikol's Soothing",      -- Level 27
            "Yekan's Recovery",        -- Level 36
            "Vigor of Zehkes",         -- Level 49
            "Aid of Khurenz",          -- Level 52
            "Sha's Restoration",       -- Level 55
            "Healing of Sorsha",       -- Level 61
            "Healing of Mikkily",      -- Level 66
        },
        ['PetSpell'] = {
            "Spirit of Sharik",    -- Level 8
            "Spirit of Khaliz",    -- Level 15
            "Spirit of Keshuval",  -- Level 21
            "Spirit of Herikol",   -- Level 30
            "Spirit of Yekan",     -- Level 39
            "Spirit of Kashek",    -- Level 46
            "Spirit of Omakin",    -- Level 54
            "Spirit of Zehkes",    -- Level 56
            "Spirit of Khurenz",   -- Level 58
            "Spirit of Khati Sha", -- Level 60
            "Spirit of Arag",      -- Level 62
            "Spirit of Sorsha",    -- Level 64
            "Spirit of Alladnu",   -- Level 68
            "Spirit of Rashara",   -- Level 70
        },
        ['PetHaste'] = {
            "Yekan's Quickening",
            "Bond of The Wild",
            "Omakin's Alacrity",
            "Sha's Ferocity",
            "Arag's Celerity",
            "Growl of the Beast",
        },
        ['PetSlowProc'] = {
            "Spirit of Sha",
        },
        ['PetGrowl'] = {
            "Growl of the Panther",
        },
        ['PetDamageProc'] = {
            "Spirit of Shoru",
            "Spirit of Lightning",
            "Spirit of the Blizzard",
            "Spirit of Inferno",
            "Spirit of the Scorpion",
            "Spirit of Vermin",
            "Spirit of Wind",
            "Spirit of the Storm",
            "Spirit of Snow",
            "Spirit of Flame",
            "Spirit of Rellic",
            "Spirit of Irionu",
            "Spirit of Oroshar",
        },
        ['RunSpeedBuff'] = {
            "Spirit of Wolf",
        },
        ['ManaRegenBuff'] = {
            --Mana/Hp/End Regen Buff*
            "Spiritual Light",
            "Spiritual Radiance",
            "Spiritual Purity",
            "Spiritual Dominion",
            "Spiritual Ascendance",
            "Spiritual Rejuvenation",
        },
        ['PetBlockSpell'] = {
            "Ward of Calliav",       -- Level 49
            "Guard of Calliav",      -- Level 58
            "Protection of Calliav", -- Level 64
            "Feral Guard",           -- Level 69
        },
        ['AvatarSpell'] = {
            -- Str Stam Dex Buff
            "Infusion of Spirit", -- Level 61
        },
        ['FocusSpell'] = {
            -- Single target Talismans ( Like Focus)
            "Inner Fire",
            "Talisman of Tnarg",
            "Talisman of Altuna",
            "Talisman of Kragg",
            "Focus of Alladnu",
        },
        ['AtkHPBuff'] = {
            "Spiritual Vitality",
            "Spiritual Vigor",
            "Spiritual Brawn",
            "Spiritual Strength",
        },
        ['AtkBuff'] = {
            -- - Single Ferocity
            "Savagery",           -- Level 60
            "Ferocity",           -- Level 65
            "Ferocity of Irionu", -- Level 70
        },
        ['DmgModDisc'] = {
            --All Skills Damage Modifier*
            "Empathic Fury",
            "Bestial Fury Discipline",
        },
        ['ProtDisc'] = {
            "Protective Spirit Discipline",
        },
        ['VigorBuff'] = {
            "Feral Vigor",
        },
    },
    ['HealRotationOrder'] = {
        {
            name = 'PetHealAA',
            state = 1,
            steps = 1,
            load_cond = function() return Casting.CanUseAA("Mend Companion") or Casting.CanUseAA("Replenish Companion") end,
            cond = function(self, target) return target.ID() == mq.TLO.Me.Pet.ID() and Targeting.BigHealsNeeded(mq.TLO.Me.Pet) end,
        },
        {
            name = 'PetHealSpell',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoPetHealSpell') end,
            cond = function(self, target) return target.ID() == mq.TLO.Me.Pet.ID() and Targeting.MainHealsNeeded(mq.TLO.Me.Pet) end,
        },
        { -- configured as a backup healer, will not cast in the mainpoint
            name = 'BigHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoHeals') end,
            cond = function(self, target) return Targeting.BigHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ['PetHealAA'] = {
            {
                name_func = function() return Casting.CanUseAA("Replenish Companion") and "Replenish Companion" or "Mend Companion" end,
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.Me.Pet.PctHPs() <= Config:GetSetting('BigHealPoint')
                end,
            },
            {
                name = "Minion's Memento",
                type = "Item",
            },
        },
        ['PetHealSpell'] = {
            {
                name = "PetHealSpell",
                type = "Spell",
            },
        },
        ['BigHealPoint'] = {
            {
                name = "VigorBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HealSpell",
                type = "Spell",
            },
        },
    },
    ['RotationOrder']     = {
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 30,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
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
            name = 'FocusedParagon',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoParagon') and Casting.CanUseAA("Focused Paragon of Spirits") end,
            targetId = function(self)
                return { Combat.FindWorstHurtManaGroupMember(Config:GetSetting('FParaPct')),
                    Combat.FindWorstHurtManaXT(Config:GetSetting('FParaPct')), }
            end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and Config:GetSetting('DowntimeFP') and Casting.OkayToBuff()
                local combat = combat_state == "Combat"
                return (downtime or combat) and not Casting.IHaveBuff(mq.TLO.Me.AltAbility('Paragon of Spirit').Spell)
            end,
        },
        {
            name = 'Slow',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSlow') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff()
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
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['HelperFunctions']   = {
        DmgModActive = function(self) --Song active by name will check both Bestial Alignments (Self and Group)
            local disc = self.ResolvedActionMap['DmgModDisc']
            return Casting.IHaveBuff("Bestial Alignment") or (disc and disc() and Casting.IHaveBuff(disc.Name()))
                or Casting.IHaveBuff("Ferociousness")
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
    },
    ['Rotations']         = {
        ['Burn'] = {
            {
                name = "Bestial Bloodrage",
                type = "AA",
            },
            {
                name = "Group Bestial Alignment",
                type = "AA",
                cond = function(self, aaName)
                    return not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "Attack of the Warders",
                type = "AA",
            },
            {
                name = "Frenzy of Spirit",
                type = "AA",
            },
            {
                name = "Fundament: Third Spire of the Savage Lord",
                type = "AA",
            },
            {
                name = "DmgModDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "Bestial Alignment",
                type = "AA",
                cond = function(self, aaName)
                    return not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, itemName)
                    return not self.ClassConfig.HelperFunctions.DmgModActive(self)
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
        ['Slow'] = {
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and (spell.RankName.SlowPct() or 0) > (Targeting.GetTargetSlowedPct())
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoVetAA') then return false end
                    return mq.TLO.Me.PctHPs() < 35
                end,
            },
            {
                name = "Warder's Gift",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.Pet.PctHPs() and mq.TLO.Me.Pet.PctHPs() > 50)
                end,
            },
            {
                name = "Protection of the Warder",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Blood Drinker's Coating",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCoating') then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "ProtDisc",
                type = "Discipline",
            },
        },
        ['FocusedParagon'] = {
            {
                name = "Focused Paragon of Spirits",
                type = "AA",
            },
        },
        ['DPS'] = {
            {
                name = "PetSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Pet.ID() == 0
                end,
            },
            {
                name = "Paragon of Spirit",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoParagon') then return false end
                    return (mq.TLO.Group.LowMana(Config:GetSetting('ParaPct'))() or -1) > 0
                end,
            },
            {
                name = "BloodDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "EndemicDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "SwarmPet",
                type = "Spell",
            },
            {
                name = "Icelance1",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Icelance2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Roar of Thunder",
                type = "AA",
            },
            {
                name = "Raven's Claw",
                type = "AA",
            },
            {
                name = "Gorilla Smash",
                type = "AA",
            },
            {
                name = "Feral Swipe",
                type = "AA",
            },
            {
                name = "Kick",
                type = "Ability",
            },
            {
                name = "Tiger Claw",
                type = "Ability",
            },
            {
                name = "Bite of the Asp",
                type = "AA",
            },
            {
                name = "Chameleon Strike",
                type = "AA",
            },
            {
                name = "Nature's Salve",
                type = "AA",
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return mq.TLO.Me.TotalCounters() > 0
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoRunSpeed') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Make sure this is gemmed due to long refresh, and only use the single target versions on classes that need it.
                    if ((spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target)) or not Casting.CastReady(spell) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ManaRegenBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Only use the single target versions on classes that need it
                    if (spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target) and not Casting.TargetHasBuff("Brell's Vibrant Barricade", target, true)
                end,
            },
            {
                name = "VigorBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Targeting.TargetIsMA() then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "FocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Only use the single target versions on classes that need it
                    if (spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAvatar') or not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Pet.ID() == 0
                end,
                post_activate = function(self, spell, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "Gelid Rending",
                type = "AA",
            },
            {
                name = "Pact of The Wurine",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if not Config:GetSetting('DoEpic') then return false end
                    return not mq.TLO.Me.PetBuff("Savage Wildcaller's Blessing")() and not mq.TLO.Me.PetBuff("Might of the Wild Spirits")()
                end,
            },
            {
                name = "Hobble of Spirits",
                type = "AA",
                cond = function(self, aaName, target)
                    local slowProc = self.ResolvedActionMap['PetSlowProc']
                    return Config:GetSetting('DoPetSnare') and (slowProc and slowProc() and mq.TLO.Me.PetBuff(slowProc.RankName()) == nil) and
                        mq.TLO.Me.PetBuff(mq.TLO.Me.AltAbility(aaName).Spell.RankName.Name())() == nil
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoAvatar') and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoRunSpeed') and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetSlowProc",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoPetSlow') and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetHaste",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetDamageProc",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetGrowl",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Fortify Companion",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "Taste of Blood",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
        },
    },
    ['SpellList']         = { -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
        {
            name = "Default Mode",
            -- cond = function(self) return true end, --Code kept here for illustration, if there is no condition to check, this line is not required
            spells = {
                { name = "HealSpell",     cond = function(self) return Config:GetSetting('DoHeals') end, },
                { name = "PetHealSpell",  cond = function(self) return Config:GetSetting('DoPetHealSpell') end, },
                { name = "SlowSpell",     cond = function(self) return Config:GetSetting('DoSlow') end, },
                { name = "Icelance1", },
                { name = "Icelance2", },
                { name = "BloodDot",      cond = function(self) return Config:GetSetting('DoDot') end, },
                { name = "EndemicDot",    cond = function(self) return Config:GetSetting('DoDot') end, },
                { name = "SwarmPet", },
                { name = "AtkBuff", },
                { name = "VigorBuff", },
                { name = "PetGrowl", },
                { name = "PetBlockSpell", },
                { name = "PetSpell",      cond = function(self) return Config:GetSetting('KeepPetMemmed') end, },
                --filler
                { name = "PetHaste", },
                { name = "PetDamageProc", },
                { name = "RunSpeedBuff",  cond = function(self) return Config:GetSetting('DoRunSpeed') end, },
            },
        },
    },
    ['PullAbilities']     = {
        {
            id = 'SlowSpell',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('SlowSpell')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('SlowSpell')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('SlowSpell')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = { --TODO: Condense pet proc options into a combo box and update entry conditions appropriately
        ['Mode']           = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What is the difference between the modes?",
            Answer = "Beastlords currently only have one Mode. This may change in the future.",
        },
        --Mana Management
        ['DoParagon']      = {
            DisplayName = "Use Paragon",
            Category = "Mana Mgmt.",
            Index = 1,
            Tooltip = "Use Group or Focused Paragon AAs.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "How do I use my Paragon of Spirit(s) abilities?",
            Answer = "Make sure you have [DoParagon] enabled.\n" ..
                "Set the [ParaPct] to the minimum mana % before we use Paragon of Spirit.\n" ..
                "Set the [FParaPct] to the minimum mana % before we use Focused Paragon.\n" ..
                "If you want to use Focused Paragon outside of combat, enable [DowntimeFP].",
        },
        ['ParaPct']        = {
            DisplayName = "Paragon %",
            Category = "Mana Mgmt.",
            Index = 2,
            Tooltip = "Minimum mana % before we use Paragon of Spirit.",
            Default = 80,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my Paragon Abilities?",
            Answer = "Make sure you have [DoParagon] enabled.\n" ..
                "Set the [ParaPct] to the minimum mana % before we use Paragon of Spirit.\n" ..
                "Set the [FParaPct] to the minimum mana % before we use Focused Paragon.\n" ..
                "If you want to use Focused Paragon outside of combat, enable [DowntimeFP].",
        },
        ['FParaPct']       = {
            DisplayName = "F.Paragon %",
            Category = "Mana Mgmt.",
            Index = 3,
            Tooltip = "Minimum mana % before we use Focused Paragon.",
            Default = 90,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my Paragon Abilities?",
            Answer = "Make sure you have [DoParagon] enabled.\n" ..
                "Set the [ParaPct] to the minimum mana % before we use Paragon of Spirit.\n" ..
                "Set the [FParaPct] to the minimum mana % before we use Focused Paragon.\n" ..
                "If you want to use Focused Paragon outside of combat, enable [DowntimeFP].",
        },
        ['DowntimeFP']     = {
            DisplayName = "Downtime F.Paragon",
            Category = "Mana Mgmt.",
            Index = 4,
            Tooltip = "Use Focused Paragon outside of Combat.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my Paragon Abilities?",
            Answer = "Make sure you have [DoParagon] enabled.\n" ..
                "Set the [ParaPct] to the minimum mana % before we use Paragon of Spirit.\n" ..
                "Set the [FParaPct] to the minimum mana % before we use Focused Paragon.\n" ..
                "If you want to use Focused Paragon outside of combat, enable [DowntimeFP].",
        },
        --Pets
        ['DoPetHealSpell'] = {
            DisplayName = "Do Pet Heals",
            Category = "Pet Mgmt.",
            Index = 2,
            Tooltip = "Mem and cast your Pet Heal (Salve) spell. AA Pet Heals are always used in emergencies.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "My Pet Keeps Dying, What Can I Do?",
            Answer = "Make sure you have [DoPetHealSpell] enabled.\n" ..
                "If your pet is still dying, consider using [PetHealPct] to adjust the pet heal threshold.",
        },
        ['DoPetSlow']      = {
            DisplayName = "Pet Slow Proc",
            Category = "Pet Mgmt.",
            Index = 3,
            Tooltip = "Use your Pet Slow Proc Buff (does not stack with Pet Damage or Snare Proc Buff).",
            Default = false,
            FAQ = "Why am I not buffing my pet with (Slow, Damage, Snare) proc buff?",
            Answer =
                "Pet proc buffs do not stack with each other and the one you wish to use should be selected.\n" ..
                "If neither Snare nor Slow proc are selected, the Damage proc will be used.",
        },
        ['DoPetSnare']     = {
            DisplayName = "Pet Snare Proc",
            Category = "Pet Mgmt.",
            Index = 4,
            Tooltip = "Use your Pet Snare Proc Buff (does not stack with Pet Damage or Slow Proc Buff).",
            Default = false,
            FAQ = "Why am I continually buffing my pet?",
            Answer = "Pet proc buffs do not stack, you should only select one.\n" ..
                "If neither Snare nor Slow proc are selected, the Damage proc will be used.",
        },
        ['DoEpic']         = {
            DisplayName = "Do Epic",
            Category = "Pet Mgmt.",
            Index = 8,
            Tooltip = "Click your Epic Weapon.",
            Default = false,
            FAQ = "How do I use my Epic Weapon?",
            Answer = "Enable Do Epic to click your Epic Weapon.",
        },
        ['KeepPetMemmed']  = {
            DisplayName = "Always Mem Pet",
            Category = "Pet Mgmt.",
            Index = 9,
            Tooltip = "Keep your pet spell memorized (allows combat resummoning).",
            Default = false,
            FAQ = "Why won't I resummon my pet on combat?",
            Answer = "Enable the setting to Always Mem your Pet on the Pet Management tab in the class options.",
        },
        --Spells/Abilities
        ['DoHeals']        = {
            DisplayName = "Do Heals",
            Category = "Spells and Abilities",
            Index = 1,
            Tooltip = "Mem and cast your Mending spell.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "I want to help with healing, what can I do?",
            Answer = "Make sure you have [DoHeals] enabled.\n" ..
                "If you want to help with pet healing, enable [DoPetHealSpell].",
        },
        ['DoSlow']         = {
            DisplayName = "Do Slow",
            Category = "Spells and Abilities",
            Index = 2,
            Tooltip = "Use your slow spell or AA.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why is my BST slowing, when I have a SHM in group?",
            Answer = "Simply deselect the option to Do Slow.",
        },
        ['DoDot']          = {
            DisplayName = "Cast DOTs",
            Category = "Spells and Abilities",
            Index = 3,
            Tooltip = "Enable casting Damage Over Time spells.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why am I using so many DOTs? I'm always running low mana!",
            Answer = "Generally, BST DoT spells are worth using at all levels of play.\n" ..
                "Dots have additional settings in the RGMercs Main config, such as the min mana% to use them, or mob HP to stop using them",
        },
        ['DotNamedOnly']   = {
            DisplayName = "Only Dot Named",
            Category = "Spells and Abilities",
            Index = 4,
            Tooltip = "Any selected dot above will only be used on a named mob.",
            Default = true,
            FAQ = "Why am I not using my dots?",
            Answer = "Make sure the dot is enabled in your class settings and make sure that the mob is named if that option is selected.\n" ..
                "You can read more about named mobs on the RGMercs named tab (and learn how to add one on your own!)",
        },
        ['DoRunSpeed']     = {
            DisplayName = "Do Run Speed",
            Category = "Spells and Abilities",
            Index = 5,
            Tooltip = "Do Run Speed Spells/AAs",
            Default = false,
            FAQ = "Why are my buffers in a run speed buff war?",
            Answer = "Many run speed spells freely stack and overwrite each other, you will need to disable Run Speed Buffs on some of the buffers.",
        },
        ['DoAvatar']       = {
            DisplayName = "Do Avatar",
            Category = "Spells and Abilities",
            Index = 6,
            Tooltip = "Buff Group/Pet with Infusion of Spirit",
            Default = false,
            FAQ = "How do I use my Avatar Buffs?",
            Answer = "Make sure you have [DoAvatar] enabled.\n" ..
                "Also double check [DoBuffs] is enabled so you can cast on others.",
        },
        ['DoVetAA']        = {
            DisplayName = "Use Vet AA",
            Category = "Spells and Abilities",
            Index = 7,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does SHD use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },
        --Combat
        ['DoAEDamage']     = {
            DisplayName = "Do AE Damage",
            Category = "Combat",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['AETargetCnt']    = {
            DisplayName = "AE Target Count",
            Category = "Combat",
            Index = 3,
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
            Category = "Combat",
            Index = 4,
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
            Category = "Combat",
            Index = 5,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },
        ['EmergencyStart'] = {
            DisplayName = "Emergency HP%",
            Category = "Combat",
            Index = 6,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "How do I use my Emergency Mitigation Abilities?",
            Answer = "Make sure you have [EmergencyStart] set to the HP % before we begin to use emergency mitigation abilities.",
        },
        ['DoCoating']      = {
            DisplayName = "Use Coating",
            Category = "Combat",
            Index = 8,
            Tooltip = "Click your Blood/Spirit Drinker's Coating in an emergency.",
            Default = false,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },
    },
}
