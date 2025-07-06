local mq           = require('mq')
local Config       = require('utils.config')
local Comms        = require("utils.comms")
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local DanNet       = require('lib.dannet.helpers')
local Logger       = require("utils.logger")

local _ClassConfig = {
    _version            = "1.4 - Project Lazarus",
    _author             = "Derple, Grimmier, Algar, Robban",
    ['ModeChecks']      = {
        CanMez     = function() return true end,
        CanCharm   = function() return true end,
        IsCharming = function() return Config:GetSetting('CharmOn') end,
        IsMezzing  = function() return Config:GetSetting('MezOn') end,
    },
    ['Modes']           = {
        'Default',
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Staff of Eternal Eloquence",
            "Oculus of Persuasion",
        },
    },
    ['AbilitySets']     = {
        --Commented any currently unused spell lines
        --Laz spells to look into: Echoing Madness
        ['TwincastAura'] = {
            "Twincast Aura",
        },
        ['SpellProcAura'] = {
            "Illusionist's Aura",
            "Beguiler's Aura",
        },
        ['VisageAura'] = {
            "Aura of Endless Glamour",
        },
        ['GroupHasteBuff'] = {
            "Hastening of Salik",
            "Vallon's Quickening",
            "Speed of the Brood",
        },
        ['SingleHasteBuff'] = {
            "Speed of Salik",
            "Speed of Vallon",
            "Visions of Grandeur",
            "Wondrous Rapidity",
            "Aanya's Quickening",
            "Swift Like the Wind",
            "Celerity",
            "Alacrity",
            "Quickness",
        },
        ['ManaRegen'] = {
            "Voice of Clairvoyance",
            "Clairvoyance",
            "Voice of Quellious",
            "Tranquility",
            "Koadic's Endless Intellect",
            "Gift of Pure Thought",
            "Clarity II",
            "Boon of the Clear Mind",
            "Clarity",
            "Breeze",
        },
        ['MezBuff'] = {
            "Ward of Bedazzlement",
        },
        ['NdtBuff'] = {
            "Boon of the Legion",
            "Night's Dark Terror",
            "Boon of the Garou",
        },
        ['SelfHPBuff'] = {
            "Mystic Shield",
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
        ['SelfRune1'] = {
            "Ethereal Rune",
            "Arcane Rune",
        },
        ['SingleRune'] = {
            "Rune of Salik",
            "Rune of Zebuxoruk",
            "Rune V",
            "Rune IV",
            "Rune III",
            "Rune II",
            "Rune I",
        },
        ['GroupRune'] = {
            "Rune of Rikkukin",
            "Rune of the Scale",
        },
        -- ['AggroBuff'] = {
        --     "Horrifying Visage",
        --     "Haunting Visage",
        -- },
        -- ['SingleSpellShield'] = {
        --     "Wall of Alendar",
        --     "Bulwark of Alendar",
        --     "Protection of Alendar",
        --     "Guard of Alendar",
        --     "Ward of Alendar",
        -- },
        ['GroupSpellShield'] = {
            "Circle of Alendar",
        },
        ['SpellProcBuff'] = {
            "Mana Recursion",
            "Mana Flare",
        },
        ['PBAEStunSpell'] = {
            "Color Snap",
            "Color Cloud",
            "Color Slant",
            "Color Skew",
            "Color Shift",
            "Color Flux",
        },
        -- ['SingleStunSpell1'] = {
        --     "Largarn's Lamentation",
        --     "Dyn's Dizzying Draught",
        --     "Whirl till you hurl",
        -- },
        ['CharmSpell'] = {
            "Ancient: Voice of Muram",
            "True Name",
            "Compel",
            "Command of Druzzil",
            "Beckon",
            "Dictate",
            "Boltran's Agacerie",
            "Ordinance",
            "Allure",
            "Cajoling Whispers",
            "Beguile",
            "Charm",
        },
        ['CrippleSpell'] = {
            -- "Synaptic Seizure", -- In resources but not available
            "Synapsis Spasm",
            "Cripple",
            "Incapacitate",
            "Listless Power",
            "Disempower",
            "Enfeeblement",
        },
        ['SlowSpell'] = {
            "Desolate Deeds",
            "Dreary Deeds",
            "Forlorn Deeds",
            "Shiftless Deeds",
            "Tepid Deeds",
            "Languid Pace",
        },
        ['StripBuffSpell'] = {
            "Abashi's Disempowerment",
            "Recant Magic",
            "Pillage Enchantment",
            "Nullify Magic",
            "Strip Enchantment",
            "Cancel Magic",
            "Taper Enchantment",
        },
        ['TashSpell'] = {
            "Echo of Tashan",
            "Howl of Tashan",
            "Tashanian",
            "Tashania",
            "Tashani",
            "Tashina",
        },
        -- ['ManaDrainNuke'] = {
        --     "Torment of Scio",
        --     "Torment of Argli",
        --     "Scryer's Trespass",
        --     "Wandering Mind",
        --     "Mana Sieve",
        -- },
        ['StrangleDot'] = {
            "Arcane Noose",
            "Strangle",
            "Asphyxiate",
            "Gasping Embrace",
            "Suffocate",
            "Choke",
            "Suffocating Sphere",
            "Shallow Breath",
        },
        ['MindDot'] = {
            "Mind Shatter",
        },
        ['MagicNuke'] = {
            "Ancient: Neurosis",
            "Psychosis",
            "Ancient: Chaos Madness",
            "Madness of Ikkibi",
            "Insanity",
            "Ancient: Chaotic Visions",
            "Dementing Visions",
            "Dementia",
            "Discordant Mind",
            "Anarchy",
            "Chaos Flux",
            "Sanity Warp",
            "Chaotic Feedback",
            "Chromarcana",
        },
        ['PetSpell'] = {
            "Salik's Animation",
            "Aeldorb's Animation",
            "Zumaik's Animation",
            "Kintaz's Animation",
            "Yegoreff's Animation",
            "Aanya's Animation",
            "Boltran's Animation",
            "Uleen's Animation",
            "Sagar's Animation",
            "Sisna's Animation",
            "Shalee's Animation",
            "Kilan's Animation",
            "Mircyl's Animation",
            "Juli's Animation",
            "Pendril's Animation",
        },
        ['MezAESpell'] = {
            "Wake of Felicity",
            "Bliss of the Nihil",
            "Fascination",
            "Mesmerization",
            "Bewildering Wave",
            "Stupefying Wave",
        },
        -- ['MezPBAESpell'] = {
        --     "Circle of Dreams",
        --     "Word of Morell",
        --     "Entrancing Lights",
        --     "Bewilderment",
        --     "Wonderment",
        -- },
        ['MezSpell'] = {
            "Euphoria",
            "Felicity",
            "Bliss",
            "Sleep",
            "Apathy",
            "Ancient: Eternal Rapture",
            "Rapture",
            "Glamour of Kintaz",
            "Enthrall",
            "Mesmerize",
        },
        -- ['MezSpellFast'] = {
        --     "Perplexing Flash",
        -- },
        -- ['BlurSpell'] = {
        --     "Memory Flux",
        --     "Reoccurring Amnesia",
        --     "Memory Blur",
        -- },
        -- ['AEBlurSpell'] = {
        --     "Blanket of Forgetfulness",
        --     "Mind Wipe",
        -- },
        -- ['CalmSpell'] = {
        --     "Placate",
        --     "Pacification",
        --     "Pacify",
        --     "Calm",
        --     "Soothe",
        --     "Lull",
        -- },
        -- ['FearSpell'] = {
        --     "Anxiety Attack",
        --     "Jitterskin",
        --     "Phobia",
        --     "Trepidation",
        --     "Invoke Fear",
        --     "Chase the Moon",
        --     "Fear",
        -- },
        -- ['RootSpell'] = {
        --     "Greater Fetter",
        --     "Fetter",
        --     "Paralyzing Earth",
        --     "Immobilize",
        --     "Instill",
        --     "Root",
        -- },
        ['HasteManaCombo'] = {
            "Unified Alacrity",
        },
        ['ColoredNuke'] = {
            "Colored Chaos",
        },
        ['Chromaburst'] = {
            "Chromaburst",
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
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and not Core.IsCharming() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 60,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        { --Slow and Tash separated so we use both before we start DPS
            name = 'Tash',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoTash') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff()
            end,
        },
        { --Slow and Tash separated so we use both before we start DPS
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
            name = 'StripBuff',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoStripBuff') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff()
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
        { --AA Stuns, Runes, etc, moved from previous home in DPS
            name = 'CombatSupport',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            doFullRotation = true,
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
    ['HelperFunctions'] = { --used to autoinventory our crystals after summon. Crystal is a group-wide spell on Laz.
        StashCrystal = function(aaName)
            mq.delay("2s", function() return mq.TLO.Cursor() and mq.TLO.Cursor.ID() == mq.TLO.Me.AltAbility(aaName).Spell.Base(1)() end)

            if not mq.TLO.Cursor() then
                Logger.log_debug("No valid item found on cursor, item handling aborted.")
                return false
            end

            Logger.log_info("Sending the %s to our bags.", mq.TLO.Cursor())

            Comms.PrintGroupMessage("%s summoned, issuing autoinventory command momentarily.", mq.TLO.Cursor())
            mq.delay(Config:GetSetting("AICrystalDelay"))
            Core.DoGroupCmd("/autoinventory")
        end,
    },
    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "Eldritch Rune",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if Casting.CanUseAA("Eldritch Rune") then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end, --Laz stacking fix
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) and not Casting.IHaveBuff("Talisman of Wunshi") end,
            },
            {
                name = "MezBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            { -- Mana Restore AA, will use the first(best) available
                name_func = function(self)
                    return Casting.GetFirstAA({ "Mana Draw", "Gather Mana", })
                end,
                type = "AA",
                cond = function(self, aaName) return mq.TLO.Me.PctMana() < 30 end,
            },
            {
                name = "Auroria Mastery",
                type = "AA",
                active_cond = function(self) return Casting.AuraActiveByName("Aura of Bedazzlement") end,
                pre_activate = function(self) -- remove the old aura if we leveled up, otherwise we will be spammed because of no focus.
                    if not Casting.AuraActiveByName("Aura of Bedazzlement") then
                        ---@diagnostic disable-next-line: undefined-field
                        mq.TLO.Me.Aura(1).Remove()
                    end
                end,
                cond = function(self, aaName)
                    return not Casting.AuraActiveByName("Aura of Bedazzlement")
                end,
            },
            {
                name = "SpellProcAura",
                type = "Spell",
                active_cond = function(self, spell)
                    local aura = string.sub(spell.Name() or "", 1, 8)
                    return Casting.AuraActiveByName(aura) or Casting.AuraActiveByName("Aura of Bedazzlement")
                end,
                pre_activate = function(self, spell)                  -- remove the old aura if we leveled up or changed options, otherwise we will be spammed because of no focus.
                    local aura = string.sub(spell.Name() or "", 1, 8) -- we use a string sub because aura name doesn't have the apostrophe the spell name does
                    if not Casting.AuraActiveByName(aura) then
                        ---@diagnostic disable-next-line: undefined-field
                        mq.TLO.Me.Aura(1).Remove()
                    end
                end,
                cond = function(self, spell)
                    if Casting.CanUseAA('Auroria Mastery') or Config:GetSetting('UseAura') ~= 1 then return false end
                    local aura = string.sub(spell.Name() or "", 1, 8)
                    return not Casting.AuraActiveByName(aura)
                end,
            },
            {
                name = "TwincastAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.Name()) end,
                pre_activate = function(self, spell) -- remove the old aura if we changed options, otherwise we will be spammed because of no focus.
                    if not Casting.AuraActiveByName(spell.Name()) then
                        ---@diagnostic disable-next-line: undefined-field
                        mq.TLO.Me.Aura(1).Remove()
                    end
                end,
                cond = function(self, spell)
                    if Casting.CanUseAA('Auroria Mastery') or Config:GetSetting('UseAura') ~= 2 then return false end
                    return not Casting.AuraActiveByName(spell.Name())
                end,
            },
            {
                name = "VisageAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.Name()) end,
                pre_activate = function(self, spell) -- remove the old aura if we changed options, otherwise we will be spammed because of no focus.
                    if not Casting.AuraActiveByName(spell.Name()) then
                        ---@diagnostic disable-next-line: undefined-field
                        mq.TLO.Me.Aura(1).Remove()
                    end
                end,
                cond = function(self, spell)
                    if Casting.CanUseAA('Auroria Mastery') or Config:GetSetting('UseAura') ~= 3 then return false end
                    return not Casting.AuraActiveByName(spell.Name())
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell) return Casting.ReagentCheck(spell) end,
                post_activate = function(self, spell, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "SingleHasteBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.ID()).ID() end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) and Casting.PetBuffCheck(mq.TLO.Spell("Unified Alacrity")) end,
            },
            {
                name = "Fortify Companion",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "Crystalized Soul Gem", -- This isn't a typo
                type = "Item",
                cond = function(self, itemName)
                    return Casting.PetBuffItemCheck(itemName)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "HasteManaCombo",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ManaRegen",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if self:GetResolvedActionMapItem('HasteManaCombo') or not Targeting.TargetIsACaster(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name_func = function(self)
                    return Casting.GetFirstMapItem({ "GroupHasteBuff", "SingleHasteBuff", })
                end,
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if self:GetResolvedActionMapItem('HasteManaCombo') or not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.GroupBuffCheck(mq.TLO.Spell("Unified Alacrity"), target) -- Fixes bad stacking check
                end,
            },
            {
                name = "GroupSpellShield",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupSpellShield') then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "NdtBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    --Single target versions of the spell will only be used on Melee, group versions will be cast if they are missing from any groupmember
                    if not Config:GetSetting('DoNDTBuff') or ((spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target)) then return false end

                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SpellProcBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoProcBuff') or not Targeting.TargetIsACaster(target) then return false end
                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if Config:GetSetting('RuneChoice') ~= 2 then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            -- {
            --     name = "AggroRune",
            --     type = "Spell",
            --     active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
            --     cond = function(self, spell, target)
            --         if not Config:GetSetting('DoAggroRune') or not Targeting.TargetIsATank(target) then return false end
            --         return Casting.GroupBuffCheck(spell, target)
            --     end,
            -- },
            {
                name = "SingleRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if Config:GetSetting('RuneChoice') ~= 1 then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "Azure Mind Crystal",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('SummonAzure') or not Targeting.GroupedWithTarget(target) then return false end
                    local crystal = mq.TLO.Spell(aaName).RankName.Base(1)()
                    return crystal and DanNet.query(target.CleanName(), string.format("FindItemCount[%d]", crystal), 1000) == "0" and (mq.TLO.Cursor.ID() or 0) == 0
                end,
                post_activate = function(self, aaName, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.StashCrystal(aaName))
                    end
                end,
            },
            {
                name = "Sanguine Mind Crystal",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('SummonSanguine') or not Targeting.GroupedWithTarget(target) then return false end
                    local crystal = mq.TLO.Spell(aaName).RankName.Base(1)()
                    return crystal and DanNet.query(target.CleanName(), string.format("FindItemCount[%d]", crystal), 1000) == "0" and (mq.TLO.Cursor.ID() or 0) == 0
                end,
                post_activate = function(self, aaName, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.StashCrystal(aaName))
                    end
                end,
            },
        },
        ['CombatSupport'] = {
            {
                name = "Fundament: Second Spire of Enchantment",
                type = "AA",
                cond = function(self, aaName, target)
                    return ((mq.TLO.Group.LowMana(30)() or 0) + (mq.TLO.Me.PctMana() < 30 and 1 or 0)) > 1
                end,
            },
            {
                name = "Glyph Spray",
                type = "AA",
            },
            {
                name = "Reactive Rune",
                type = "AA",
                cond = function(self, aaName, target)
                    return ((Targeting.IsNamed(target) and target.Level() > mq.TLO.Me.Level()) or Core.GetMainAssistPctHPs() < 40)
                end,
            },
            {
                name = "PBAEStunSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if (Config:GetSetting('DoAEStun') == 2 and Core.GetMainAssistPctHPs() > Config:GetSetting('EmergencyStart')) or Config:GetSetting('DoAEStun') == 1 then return false end
                    return Casting.DetSpellCheck(spell) and Targeting.GetXTHaterCount() >= Config:GetSetting("AECount")
                end,
            },
            { --this can be readded once we creat a post_activate to cancel the debuff you receive after
                name = "Self Stasis",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Config.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 30
                end,
                post_activate = function(self, aaName, success)
                    if success and mq.TLO.Me.Buff("Self Stasis")() then
                        Comms.PrintGroupMessage("We're out of combat, removing the Self Statis buff so we can act again.")
                        Core.DoCmd('/removebuff =Self Stasis')
                    end
                end,
            },
            -- { --This can interrupt spellcasting which can just make something worse. Let us trust healers and tanks.
            --     name = "Dimensional Instability",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Config.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 30            --     end,
            -- },
            {
                name = "Beguiler's Directed Banishment",
                type = "AA",
                cond = function(self, aaName, target)
                    if target.ID() == Config.Globals.AutoTargetID then return false end
                    return mq.TLO.Me.PctAggro() > 99 and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,

            },
            {
                name = "Beguiler's Banishment",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and mq.TLO.SpawnCount("npc radius 20")() > 2
                end,

            },
            {
                name = "Doppelganger",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            -- { --This can interrupt spellcasting which can just make something worse. Let us trust healers and tanks.
            --     name = "Dimensional Shield",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Config.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 80            --     end,

            -- },
            {
                name = "Veil of Mindshadow",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= 80 and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() >= 90
                end,

            },
            {
                name = "Color Shock",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() >= 90
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() >= 60
                end,
            },
            {
                name = "Soothing Words",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting("DoSoothing") then return false end
                    return Targeting.IsNamed(target) and (mq.TLO.Me.TargetOfTarget.ID() or Core.GetMainAssistId()) ~= Core.GetMainAssistId()
                end,
            }, },
        ['StripBuff'] = {
            {
                name = "StripBuffSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStripBuff') or mq.TLO.Target.ID() == 0 then return false end
                    return mq.TLO.Target.Beneficial() ~= nil
                end,
            },
        },
        ['DPS'] = {
            {
                name = "ColoredNuke",
                type = "Spell",
                cond = function(self)
                    if not Config:GetSetting('DoNuke') then return false end
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Chromaburst",
                type = "Spell",
                cond = function(self)
                    if not Config:GetSetting('DoChroma') then return false end
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if Config:GetSetting('UseEpic') == 1 then return false end
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "MindDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoMindDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return not mq.TLO.Me.Buff("Mind Shatter Recourse") or Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "StrangleDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStrangleDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoColored') then return false end
                    return Casting.HaveManaToNuke()
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Illusions of Grandeur",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName, target) return Targeting.IsNamed(target) end,
            },
            {
                name = "Calculated Insanity",
                type = "AA",
            },
            {
                name = "Mental Contortion",
                type = "AA",
                cond = function(self, aaName, target) return Targeting.IsNamed(target) end,
            },
            {
                name = "Chromatic Haze",
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
            {
                name = "Fundament: Third Spire of Enchantment",
                type = "AA",
                cond = function(self) return not Casting.IHaveBuff("Illusions of Grandeur") end,
            },
            {
                name = "Crippling Aurora",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoCrippleAA') then return false end
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AECount') or
                        (not Config:GetSetting('DoCrippleSpell') and Targeting.IsNamed(target) and Casting.DetSpellAACheck(aaName))
                end,
            },
            {
                name = "CrippleSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoCrippleSpell') then return false end
                    return Targeting.IsNamed(target) and Casting.DetSpellCheck(spell)
                end,
            },
            -- { --Temporarily commented out due to high prevalance of xtarget bugs with this pet. will revisit.
            --     name = "Phantasmal Opponent",
            --     type = "AA",
            -- },
            {
                name = "Tarnished Skeleton Key",
                type = "Item",
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ['Tash'] = {
            {
                name = "Bite of Tashani",
                type = "AA",
                cond = function(self, aaName)
                    if Targeting.GetXTHaterCount() < Config:GetSetting('AECount') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "TashSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and (not Casting.TargetHasBuff("Bite of Tashani") or Targeting.IsNamed(target))
                end,
            },
        },
        ['Slow'] = {
            {
                name = "Enveloping Helix",
                type = "AA",
                cond = function(self, aaName)
                    if Targeting.GetXTHaterCount() < Config:GetSetting('AECount') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Dreary Deeds",
                type = "AA",
                cond = function(self, aaName)
                    local aaSpell = Casting.GetAASpell(aaName)
                    return Casting.DetAACheck(aaName) and (aaSpell.SlowPct() or 0) > Targeting.GetTargetSlowedPct()
                end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell)
                    if Casting.CanUseAA("Dreary Deeds") then return false end
                    return Casting.DetSpellCheck(spell) and (spell.RankName.SlowPct() or 0) > (Targeting.GetTargetSlowedPct())
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
    ['SpellList']       = { -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
        {
            name = "Default Mode",
            -- cond = function(self) return true end, --Code kept here for illustration, if there is no condition to check, this line is not required
            spells = {
                { name = "MezSpell",         cond = function(self) return Config:GetSetting('DoSTMez') end, },
                { name = "MezAESpell",       cond = function(self) return Config:GetSetting('DoAEMez') end, },
                { name = "CharmSpell",       cond = function(self) return Config:GetSetting('CharmOn') end, },
                { name = "TashSpell",        cond = function(self) return Config:GetSetting('DoTash') end, },
                { name = "SlowSpell",        cond = function(self) return Config:GetSetting('DoSlow') and not Casting.CanUseAA("Dreary Deeds") end, },
                { name = "CrippleSpell",     cond = function(self) return Config:GetSetting('DoCrippleSpell') end, },
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "ColoredNuke",      cond = function(self) return Config:GetSetting('DoColored') end, },
                { name = "Chromaburst",      cond = function(self) return Config:GetSetting('DoChroma') end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
            },
        },
    },
    ['PullAbilities']   = {
        {
            id = 'TashSpell',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('TashSpell').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('TashSpell').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('TashSpell')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'StripBuffSpell',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('StripBuffSpell').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('StripBuffSpell').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('StripBuffSpell')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']   = {
        ['Mode']               = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this PC.",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What are the different Modes about?",
            Answer = "The Default Mode is designed for all levels on Project Lazarus.",
        },

        --Buffs
        ['UseAura']            = {
            DisplayName = "Aura Selection:",
            Category = "Buffs",
            Index = 1,
            Tooltip = "Select the Aura to be used, if any, prior to purchasing the Auroria Mastery AA.",
            Type = "Combo",
            ComboOptions = { 'Spell Proc', 'Twincast', 'Visage', 'None', },
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 4,
            FAQ = "Why am I using the wrong aura?",
            Answer = "Aura choice can be made on the buff tab.\n" ..
                "Once the PC has purchased Auroria Mastery, this setting is ignored in favor of using the AA.",
        },
        ['RuneChoice']         = {
            DisplayName = "Rune Selection:",
            Category = "Buffs",
            Index = 2,
            Tooltip = "Select which line of Rune spells you prefer to use.\nPlease note that after level 73, the group rune has a built-in hate reduction when struck.",
            Type = "Combo",
            ComboOptions = { 'Single Target', 'Group', 'Off', },
            Default = 2,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            FAQ = "Why am I putting an aggro-reducing buff on the tank?",
            Answer =
            "You can configure your rune selections to use a single-target hate increasing rune on the tank, while using group (hate reducing) or single target runes on others.",
        },
        ['DoGroupSpellShield'] = {
            DisplayName = "Do Group Spellshield",
            Category = "Buffs",
            Index = 3,
            Tooltip = "Enable casting the Group Spell Shield Line.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not using Group Spell Shield?",
            Answer = "The Do Group Spellshield setting determines whether or not your PC will cast the Group Spell Shield Line.\n" ..
                "If you are not using Group DoT Shield, you may need to Enable the Do Group Spellshield setting.",
        },
        ['DoProcBuff']         = {
            DisplayName = "Do Spellproc Buff",
            Category = "Buffs",
            Index = 4,
            Tooltip = "Enable casting the spell proc (Mana ... ) line.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I using a spell proc buff on ... class?",
            Answer = "By default, the spell proc buff will be used on any casters (including tanks/hybrids). You can change this option on the Buffs tab.",
        },
        ['DoNDTBuff']          = {
            DisplayName = "Cast NDT",
            Category = "Buffs",
            Index = 5,
            Tooltip = "Enable casting use Melee Proc Buff (Night's Dark Terror Line).",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not using NDT?",
            Answer = "The [DoNDTBuff] setting determines whether or not your PC will cast the Night's Dark Terror Line.\n" ..
                "Please note that the single target versions are only set to be used on melee.",
        },
        ['DoArcanumWeave']     = {
            DisplayName = "Weave Arcanums",
            Category = "Buffs",
            Index = 6,
            Tooltip = "Weave Empowered/Enlighted/Acute Focus of Arcanum into your standard combat routine (Focus of Arcanum is saved for burns).",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = true,
            FAQ = "What is an Arcanum and why would I want to weave them?",
            Answer =
            "The Focus of Arcanum series of AA decreases your spell resist rates.\nIf you have purchased all four, you can likely easily weave them to keep 100% uptime on one.",
        },

        --Debuffs
        ['DoTash']             = {
            DisplayName = "Do Tash",
            Category = "Debuffs",
            Tooltip = "Cast Tash Spells",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not Tashing?",
            Answer = "The [DoTash] setting determines whether or not your PC will cast Tash Spells.\n" ..
                "If you are not Tashing, you may need to Enable the [DoTash] setting.",
        },
        ['DoSlow']             = {
            DisplayName = "Cast Slow",
            Category = "Debuffs",
            Tooltip = "Enable casting Slow spells.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not Slowing?",
            Answer = "The [DoSlow] setting determines whether or not your PC will cast Slow spells.\n" ..
                "If you are not Slowing, you may need to Enable the [DoSlow] setting.",
        },
        ['DoCrippleSpell']     = {
            DisplayName = "Cast Cripple Spell",
            Category = "Debuffs",
            Tooltip = "Enable casting Cripple spells.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not Crippling?",
            Answer = "The [DoCrippleSpell] setting determines whether or not your PC will cast Cripple spells.\n" ..
                "If you are not Crippling, you may need to Enable the [DoCrippleSpell] setting.",
        },
        ['DoCrippleAA']        = {
            DisplayName = "Use AE Cripple AA",
            Category = "Debuffs",
            Tooltip = "Enable casting Crippling Aurora when we meet the AE threshold, or on a named if we don't have the spell above selected.",
            Default = true,
            FAQ = "Why am I not AE Crippling?",
            Answer = "The [DoCrippleAA] setting determines whether or not your PC will cast AE Cripple spells.\n" ..
                "If you are not Crippling, you may need to Enable the settings in the Debuffs tab.",
        },
        ['DoStripBuff']        = {
            DisplayName = "Do Strip Buffs",
            Category = "Debuffs",
            Tooltip = "Enable removing beneficial enemy effects.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not stripping buffs?",
            Answer = "The [DoStripBuff] setting determines whether or not your PC will remove beneficial enemy effects.\n" ..
                "If you are not stripping buffs, you may need to Enable the [DoStripBuff] setting.",
        },

        --Combat
        ['UseEpic']            = {
            DisplayName = "Epic Use:",
            Category = "Buffs",
            Index = 1,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my SHM using Epic on these trash mobs?",
            Answer = "By default, we use the Epic in any combat, as saving it for burns ends up being a DPS loss over a long frame of time.\n" ..
                "This can be adjusted in the Buffs tab.",
        },
        ['AECount']            = {
            DisplayName = "AE Count",
            Category = "Combat",
            Index = 2,
            Tooltip = "Number of XT Haters before we will use AE Slow, Tash, or Stun.",
            Min = 1,
            Default = 3,
            Max = 15,
            FAQ = "Why am I not using AE Abilities?",
            Answer = "Adjust your AE Count on the Combat Tab.",
        },
        ['DoAEStun']           = {
            DisplayName = "PBAE Stun use:",
            Category = "Combat",
            Index = 3,
            Tooltip = "When to use your PBAE Stun Line.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Never', 'At low MA health', 'Whenever Possible', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why am I stunning everything?!??",
            Answer = "You can choose the conditions under which you will use your PBAE Stun on the Combat tab.",
        },
        ['EmergencyStart']     = {
            DisplayName = "Emergency Start",
            Category = "Combat",
            Index = 4,
            Tooltip = "The HP % emergency abilities will be used (Abilities used depend on whose health is low, the ENC or the MA).",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my emergency abilities?",
            Answer = "You may need to tailor the emergency thresholds to your current survivability and target choice.",
        },
        ['DoChestClick']       = {
            DisplayName = "Do Chest Click",
            Category = "Combat",
            Index = 5,
            Tooltip = "Click your equipped chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "Why am I not clicking my chest item?",
            Answer = "Most Chest slot items after level 75ish have a clickable effect.\n" ..
                "ENC is set to use theirs during burns, so long as the item equipped has a clicky effect.",
        },
        ['DoSoothing']         = {
            DisplayName = "Do Soothing Words",
            Category = "Combat",
            Index = 6,
            Tooltip = "Use the Soothing Words AA (large aggro reduction) on a named whose target is not our MA.",
            Default = false,
            FAQ = "Why won't I use the Soothing Words AA?",
            Answer = "Ensure the option is selected on the combat tab and that the current target is designated as a named (check named tab or add in spawnmaster).",
        },

        --DPS
        ['DoNuke']             = {
            DisplayName = "Magic Nuke",
            Category = "DPS",
            Index = 1,
            Tooltip = "Use your primary magic nuke line.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "How can I use my magic Nuke?",
            Answer = "You can enable the magic nuke line in the Spells and Abilities tab.",
        },
        ['DoColored']          = {
            DisplayName = "Colored Chaos",
            Category = "DPS",
            Index = 2,
            Tooltip = "Use the Colored Chaos magic nuke.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "How can I use my Colored Chaos?",
            Answer = "You can enable the Colored Chaos line in the Spells and Abilities tab.",
        },
        ['DoChroma']           = {
            DisplayName = "Chromaburst",
            Category = "DPS",
            Index = 3,
            Tooltip = "Use the Chromaburst magic nuke.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "How can I use my Chromaburst nuke?",
            Answer = "You can enable the Chromaburst nuke line in the Spells and Abilities tab.",
        },
        ['DoStrangleDot']      = {
            DisplayName = "Strangle Dot",
            Category = "DPS",
            Index = 4,
            Tooltip = "Use your magic damage (Strangle Line) Dot.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "I turned Cast DOTS off, why am I still using them?",
            Answer = "The Modern Era mode does not respect this setting, as DoTs are integral to the DPS rotation.",
        },
        ['DoMindDot']          = {
            DisplayName = "Mind Dot",
            Category = "DPS",
            Index = 5,
            Tooltip = "Use your mana drain/magic damage (Mind Line) Dot on Named.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not using my Mind Dot when I have it selected?",
            Answer = "This Dot is set to be used on named or when you don't already have the recourse active.",
        },
        ['DotNamedOnly']       = {
            DisplayName = "Only Dot Named",
            Category = "DPS",
            Index = 6,
            Tooltip = "Any selected dot above will only be used on a named mob.",
            Default = true,
            FAQ = "Why am I not using my dots?",
            Answer = "Make sure the dot is enabled in your class settings and make sure that the mob is named if that option is selected.\n" ..
                "You can read more about named mobs on the RGMercs named tab (and learn how to add one on your own!)",
        },

        -- Crystal Summoning
        ['SummonAzure']        = {
            DisplayName = "Azure Mind Crystal",
            Category = "Crystals",
            Index = 1,
            Tooltip = "Summon Azure Mind Crystals (Mana Restore) for the group.",
            RequiresLoadoutChange = true, -- this is a load condition
            Default = true,
            FAQ = "Why am I not summoning crystals for my group?",
            Answer = "Ensure that you have purchased the AA and your settings are as desired on the Crystals tab.",
        },
        ['SummonSanguine']     = {
            DisplayName = "Sanguine Mind Crystal",
            Category = "Crystals",
            Index = 2,
            Tooltip = "Summon Sanguine Mind Crystals (Health Restore) for the group.",
            RequiresLoadoutChange = true, -- this is a load condition
            Default = true,
            FAQ = "When will my party use the (Azure or Sanguine) crystals I have summoned for them?",
            Answer = "Azure Crystals use ModRod mana percent settings; Sanguine Crystals will be used based off of Emergency HP settings (or 45% as a fallback.)",
        },
        ['AICrystalDelay']     = {
            DisplayName = "Crystal Autoinv Delay",
            Category = "Crystals",
            Tooltip = "Delay in ms before /autoinventory after summoning, adjust if you notice items left on cursors regularly.",
            Default = 150,
            Min = 1,
            Max = 500,
            FAQ = "Why do I always have items stuck on the cursor?",
            Answer = "You can adjust the delay before autoinventory by setting the [AICrystalDelay] setting.\n" ..
                "Increase the delay if you notice items left on cursors regularly.",
        },
    },
}

return _ClassConfig
