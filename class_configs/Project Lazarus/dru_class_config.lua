local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Logger       = require("utils.logger")

local _ClassConfig = {
    _version              = "2.0 - Lazarus",
    _author               = "Algar",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return Core.IsModeActive("Heal") end,
        IsRezing = function() return Config:GetSetting('DoBattleRez') or Targeting.GetXTHaterCount() == 0 end,
    },
    ['Modes']             = {
        'Heal',
    },
    ['Cures']             = {
        CureNow = function(self, type, targetId)
            if Config:GetSetting('DoCureAA') then
                if Casting.AAReady("Radiant Cure") then
                    return Casting.UseAA("Radiant Cure", targetId)
                elseif targetId == mq.TLO.Me.ID() and Casting.AAReady("Purified Spirits") then
                    return Casting.UseAA("Purified Spirits", targetId)
                end
            end

            if Config:GetSetting('DoCureSpells') then
                local cureSpell
                --If we have Word of Reconstitution, we can use this as our poison/disease/curse cure. Before that, they don't cure or have low counter count
                local groupHeal = (Config:GetSetting('GroupHealAsCure') and (Core.GetResolvedActionMapItem('GroupHeal').Level() or 0) >= 70) and "GroupHeal"

                if type:lower() == "disease" then
                    --simply choose the first available option (also based on the groupHeal criteria above)
                    local diseaseCure = Casting.GetFirstMapItem({ groupHeal, "PureBlood", "CureDisease", })
                    cureSpell = Core.GetResolvedActionMapItem(diseaseCure)
                elseif type:lower() == "poison" then
                    local poisonCure = Casting.GetFirstMapItem({ groupHeal, "PureBlood", "CurePoison", })
                    cureSpell = Core.GetResolvedActionMapItem(poisonCure)
                elseif type:lower() == "curse" then
                    --if we selected to keep it memmed, prioritize it over the group heal, since RGC clears a LOT more counters
                    cureSpell = Core.GetResolvedActionMapItem((not Config:GetSetting('KeepCurseMemmed') and (groupHeal or 'CureCurse') or 'CureCurse'))
                end

                if not cureSpell or not cureSpell() then return false end
                return Casting.UseSpell(cureSpell.RankName.Name(), targetId, true)
            end

            return false
        end,
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Staff of Living Brambles",
            "Staff of Everliving Brambles",
        },
    },
    ['AbilitySets']       = {
        ['HealingAura'] = {
            -- Healing Aura >= 55
            "Aura of Life",
            "Aura of the Grove",
        },
        ['HealSpell'] = {
            -- Long Heal >= 1 -- skipped 10s cast heals.
            "Ancient: Chlorobon",
            "Chlorotrope",
            "Sylvan Infusion",
            "Nature's Infusion",
            "Nature's Touch",
            "Chloroblast",
            "Forest's Renewal",
            "Superior Healing",
            "Nature's Renewal",
            "Healing Water",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
        },
        ['GroupHeal'] = { -- Laz specific, some taken from cleric, some custom
            "Word of Reconstitution",
            -- "Moonshadow", -- The above spell is superior and both level 70
            "Word of Redemption",
            "Word of Restoration",
            "Word of Vigor",
            "Word of Healing",
            "Word of Health",
        },
        ['ATKDebuff'] = { -- ATK Debuff
            "Sun's Corona",
            "Ro's Illumination",
        },
        ['ATKACDebuff'] = { -- ATK/AC Debuff, replaced by AA (Fixation > Blessing of Ro)
            "Fixation of Ro",
        },
        ['FireDebuff'] = { -- Fire and some other stats, replaced by AA (Hand > Blessing of Ro)
            "Hand of Ro",
            "Ro's Smoldering Disjunction",
            "Ro's Fiery Sundering",
        },
        ['ColdDebuff'] = { -- Cold/AC Debuff
            "Glacier Breath",
            "E`ci's Frosty Breath",
            "Twilight Breath",
        },
        ['ReptileBuff'] = {
            "Skin of the Reptile",
        },
        ['SwarmDot'] = { -- Magic Dot, 54s
            "Wasp Swarm",
            "Swarming Death",
            "Winged Death",
            "Drifting Death",
            "Drones of Doom",
            "Creeping Crud",
            "Stinging Swarm",
        },
        ['VengeanceDot'] = { -- Fire Dot, 30s
            "Vengeance of the Sun",
            "Vengeance of Tunare",
            "Vengeance of Nature",
            "Vengeance of the Wild",
        },
        ['FlameLickDot'] = { -- Fire Dot with Fire Resist Reduction, 60s
            "Immolation of the Sun",
            "Sylvan Embers",
            "Immolation of Ro",
            "Breath of Ro",
            "Immolate",
            "Flame Lick",
        },
        ['StunNuke'] = {
            "Stormwatch",
            "Storm's Fury",
            -- "Breath of Karana", -- Only cast outdoors
            -- "Dustdevil", --Does not Stun
            "Fury of Air",
            -- "Dizzying Wind", -- Only cast outdoors
            -- "Whirling Wind", -- Only cast outdoors
        },
        ['SnareSpell'] = {
            -- "Hungry Vines", -- The out-of-era Serpent Vines is much less mana and lasts longer without the Dot And melee guard
            "Serpent Vines",
            "Entangle",
            "Mire Thorns",
            "Bonds of Tunare",
            "Ensnare",
            "Snare",
            "Tangling Weeds",
        },
        ['FireNuke'] = {
            "Solstice Strike",
            "Sylvan Fire",
            "Summer's Flame",
            "Ancient: Starfire of Ro",
            "Wildfire",
            "Scoriae",
            "Starfire",
            "Firestrike",
            "Combust",
            "Ignite",
            "Burst of Fire",
            "Burst of Flame",
        },
        ['IceNuke'] = {
            "Ancient: Glacier Frost",
            "Glitterfrost",
            "Ancient: Chaos Frost",
            "Winter's Frost",
            "Moonfire",
            "Frost",
        },
        ['IceRain'] = {
            "Tempest Wind",
            "Winter's Storm",
            "Blizzard",
            "Avalanche",
            "Pogonip",
            "Cascade of Hail",
        },
        ['SelfDS'] = {
            "Nettlecoat",
            "Brackencoat",
            "Bladecoat",
            "Thorncoat",
            "Spikecoat",
            "Bramblecoat",
            "Barbcoat",
            "Thistlecoat",
        },
        ['SelfManaRegen'] = {
            "Mask of the Wild",
            "Mask of the Forest",
            "Mask of the Hunter",
            "Mask of the Stalker",
        },
        ['HPTypeOneGroup'] = {
            "Blessing of Steeloak",
            "Blessing of the Nine",
            "Protection of the Glades",
            "Protection of Nature",
            "Protection of Diamond",
            "Protection of Steel",
            "Protection of Rock",
            "Protection of Wood",
            'Skin like Wood',
        },
        ['GroupRegenBuff'] = {
            "Blessing of Oak",
            "Blessing of Replenishment",
            "Regrowth of the Grove",
            "Pack Chloroplast",
            "Pack Regeneration",
            "Regeneration",
        },
        ['AtkBuff'] = {        --Hit Damage/STR Buff
            "Lion's Strength", -- 5% Hit Damage
            "Nature's Might",  -- STR Buff
            "Girdle of Karana",
            "Storm Strength",
            "Strength of Stone",
            "Strength of Earth",
        },
        ['GroupDmgShield'] = {
            "Legacy of Nettles",
            "Legacy of Bracken",
            "Ancient: Legacy of Blades",
            "Legacy of Thorn",
            "Legacy of Spike",
            -- Before this, use ST filler
            "Shield of Thorns",
            "Shield of Spikes",
            "Shield of Brambles",
            "Shield of Barbs",
            "Shield of Thistles",
        },
        ['MoveSpells'] = {
            "Flight of Eagles",
            "Spirit of Eagle",
            "Pack Spirit",
            "Spirit of Wolf",
        },
        ['PetSpell'] = {
            "Nature Wanderer's Behest",
            "Nature Walker's Behest",
        },
        ['Dawnstrike'] = { -- I think better to just spam solstice strike
            "Dawnstrike",
        },
        -- ['BurstDS'] = { -- Laz specific, short duration 210pt damge shield
        --     "Barkspur",
        -- },
        ['RezSpell'] = {
            'Incarnate Anew', -- Level 59
            'Resuscitate',    --emu only
            'Revive',         --emu only
            'Reanimation',    --emu only
        },
        ['CurePoison'] = {
            --"Eradicate Poison",
            "Counteract Poison",
            "Cure Poison",
        },
        ['CureDisease'] = {
            --"Eradicate Disease",
            "Counteract Disease",
            "Cure Disease",
        },
        ['CureCurse'] = {
            --"Eradicate Curse",
            "Remove Greater Curse",
            "Remove Curse",
            "Remove Lesser Curse",
            "Remove Minor Curse",
        },
        ['PureBlood'] = {
            "Pure Blood",
        },
        ['TwinHealNuke'] = {
            "Sunburst Blessing", -- Laz custom, description wrong, target mob
        },
        ['PBAEMagic'] = {
            "Earth Shiver",
            "Castastrophe",
            "Upheaval",
            "Earthquake",
            "Tremor",
        },
        ['PetHaste'] = {
            "Savage Spirit",
            "Feral Spirit",
        },
        ['GroupResistBuff'] = { -- Fire/Cold Resist
            "Protection of Seasons",
            "Circle of Seasons",
        },
        ['Elixir'] = { --Laz gives these to druids
            "Celestial Elixir",
            "Celestial Healing",
            "Celestial Health",
            "Celestial Remedy",
        },
        ['EvacSpell'] = {
            "Succor",
            "Lesser Succor",
        },
    },
    ['HealRotationOrder'] = {
        {
            name  = 'BigHealPoint',
            state = 1,
            steps = 1,
            cond  = function(self, target) return Targeting.BigHealsNeeded(target) end,
        },
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ['BigHealPoint'] = {
            {
                name = "Protection of Direwood",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "Convergence of Spirits",
                type = "AA",
            },
            {
                name = "Spirit of the Bear",
                type = "AA",
            },
            {
                name = "Kelp-Covered Hammer",
                type = "Item",
            },
            { --Let's make the mainheal autocrit since we have nothing better
                name = "Nature's Blessing",
                type = "AA",
            },
        },
        ['GroupHealPoint'] = {
            {
                name = "GroupHeal",
                type = "Spell",
            },
        },
        ['MainHealPoint'] = {
            {
                name = "Elixir",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoElixir') or Targeting.BigHealsNeeded(target) then return false end
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
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Core.OkayToNotHeal() and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            load_cond = function(self) return Core.OnEMU() end,
            cond = function(self, combat_state)
                if not Config:GetSetting('DoPet') or mq.TLO.Me.Pet.ID() ~= 0 then return false end
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.OkayToPetBuff() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 60,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds tops.
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Core.OkayToNotHeal() and Casting.OkayToBuff()
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            load_cond = function()
                return (Config:GetSetting('DoFireDebuff') and Core.GetResolvedActionMapItem("FireDebuff")) or
                    (Config:GetSetting('DoColdDebuff') and Core.GetResolvedActionMapItem("ColdDebuff")) or
                    (Config:GetSetting('DoATKDebuff') and Core.GetResolvedActionMapItem("ATKDebuff"))
            end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal() and Casting.OkayToDebuff() and Casting.HaveManaToDebuff()
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal() and not Targeting.IsNamed(Targeting.GetAutoTarget()) and
                    Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck() and Core.OkayToNotHeal()
            end,
        },
        {
            name = 'DPS(AE)',
            state = 1,
            steps = 1,
            load_cond = function(self) return Config:GetSetting('DoPBAE') and self:GetResolvedActionMapItem('PBAEMagic') end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal() and Config:GetSetting('DoAEDamage') and
                    self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('AETargetCnt'), true)
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 71 end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal()
            end,
        },
        {
            name = 'ArcanumWeave',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoArcanumWeave') and Casting.CanUseAA("Acute Focus of Arcanum") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal() and not mq.TLO.Me.Buff("Focus of Arcanum")()
            end,
        },
    },
    ['Rotations']         = {
        ['DPS'] = {
            {
                name = "Epic",
                type = "Item",
                allowDead = true,
                cond = function(self, itemName, target)
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Storm Strike",
                type = "AA",
            },
            {
                name = "Nature Walkers Scimitar",
                type = "Item",
                cond = function(self, itemName, target)
                    if Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target) then return false end
                    return Targeting.MobNotLowHP(target) and Casting.DetItemCheck(itemName, target)
                end,
            },
            {
                name = "FlameLickDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoFlameLickDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "SwarmDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSwarmDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "VengeanceDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoVengeanceDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "StunNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStunNuke') then return false end
                    return Casting.DetSpellCheck(spell) and Casting.HaveManaToNuke()
                end,
            },
            { -- in-game description is incorrect, mob must be targeted.
                name = "TwinHealNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoTwinHealNuke') then return false end
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "FireNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoFireNuke') then return false end
                    return Casting.HaveManaToNuke(true)
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoIceNuke') then return false end
                    return Casting.HaveManaToNuke(true)
                end,
            },
        },
        ['DPS(AE)'] = {
            {
                name = "PBAEMagic",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke(true) and Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "IceRain",
                type = "Spell",
                cond = function(self, spell, target)
                    if not self.ClassConfig.HelperFunctions.RainCheck(target) then return false end
                    return Casting.HaveManaToNuke(true)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            {
                name = "Group Spirit of the Black Wolf",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Nature's Fury",
                type = "AA",
            },
            {
                name = "Spirit of the Wood",
                type = "AA",
            },
            {
                name = "Nature's Boon",
                type = "AA",
            },
            {
                name = "Nature's Guardian",
                type = "AA",
            },
            {
                name = "Spirits of Nature",
                type = "AA",
            },
            { -- Spire, the SpireChoice setting will determine which ability is displayed/used.
                name_func = function(self)
                    local spireAbil = string.format("Fundament: %s Spire of Nature", Config.Constants.SpireChoices[Config:GetSetting('SpireChoice') or 4])
                    return Casting.CanUseAA(spireAbil) and spireAbil or "Spire Not Purchased/Selected"
                end,
                type = "AA",
            },
            {
                name = "Shattered Gnoll Slayer",
                type = "Item",
            },
        },
        ['Debuff'] = {
            { -- Fire Debuff AA, will use the first(best) available
                name_func = function(self)
                    return Casting.GetFirstAA({ "Blessing of Ro", "Hand of Ro", })
                end,
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoFireDebuff') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "FireDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoFireDebuff') or Casting.CanUseAA("Hand of Ro") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "ColdDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoColdDebuff') then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "ATKDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoATKDebuff') then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Snare'] = {
            {
                name = "Entrap",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target)
                end,
            },
            {
                name = "SnareSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Entrap") then return false end
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Communion of the Cheetah",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoMoveBuffs') then return false end
                    return Casting.GroupBuffAACheck(aaName)
                end,
            },
            {
                name = "Flight of Eagles",
                type = "AA",
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(Casting.GetAASpell(aaName))
                end,
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoMoveBuffs') then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "MoveSpells",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting("DoMoveBuffs") or Casting.CanUseAA("Flight of Eagles") then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ReptileBuff",
                type = "Spell",
                active_cond = function(self, spell) return true end,
                cond = function(self, spell, target)
                    return Targeting.TargetClassIs({ "WAR", "SHD", }, target) and Casting.GroupBuffCheck(spell, target) --does not stack with PAL innate buff
                end,
            },
            {
                name = "AtkBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Targeting.TargetIsAMelee(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HPTypeOneGroup",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHPBuff') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupRegenBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupRegen') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupDmgShield",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupDmgShield') or ((spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsMA(target)) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Wrath of the Wild",
                type = "AA",
                active_cond = function(self, aaName) return true end,
                cond = function(self, aaName, target)
                    if Targeting.TargetIsMA(target) then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "Communion of the Cheetah",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoMoveBuffs') then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "HealingAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.BaseName()) end,
                cond = function(self, spell)
                    if self:GetResolvedActionMapItem('IceAura') then return false end
                    return (spell and spell() and not Casting.AuraActiveByName(spell.BaseName()))
                end,
            },
            { -- Wolf Spirit, the WolfSpiritChoice setting will determine which color you use.
                name_func = function(self)
                    local wolves = { 'White', 'Black', }
                    local spiritChoice = wolves[Config:GetSetting('WolfSpiritChoice')]
                    return string.format("Spirit of the %s Wolf", spiritChoice)
                end,
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName) and not Casting.IHaveBuff("Group " .. aaName)
                end,
            },
            {
                name = "SelfShield",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfManaRegen",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function() return mq.TLO.Me.Pet.ID() ~= 0 end,
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
                name = "PetHaste",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },
            {
                name = "Crystalized Soul Gem", -- This isn't a typo
                type = "Item",
                cond = function(self, itemName)
                    return Casting.PetBuffItemCheck(itemName)
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
    ['SpellList']         = { -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
        {
            name = "Heal Mode",
            cond = function(self) return Core.IsModeActive("Heal") end,
            spells = {
                { name = "HealSpell", },
                { name = "GroupHeal", },
                { name = "Elixir",      cond = function(self) return Config:GetSetting('DoElixir') end, },
                { name = "SnareSpell",  cond = function(self) return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Entrap") end, },
                { name = "ReptileBuff", },
                { name = "ATKDebuff",   cond = function(self) return Config:GetSetting('DoATKDebuff') end, },
                { name = "FireDebuff",  cond = function(self) return Config:GetSetting('DoFireDebuff') and not Casting.CanUseAA("Hand of Ro") end, },
                { name = "ColdDebuff",  cond = function(self) return Config:GetSetting('DoColdDebuff') end, },
                {
                    name = "PureBlood",
                    cond = function(self)
                        return (Config:GetSetting('KeepDiseaseMemmed') or Config:GetSetting('KeepPoisonMemmed')) and
                            not Casting.CanUseAA("Radiant Cure")
                    end,
                },
                {
                    name = "CurePoison",
                    cond = function(self)
                        return not Core.GetResolvedActionMapItem('PureBlood') and Config:GetSetting('KeepPoisonMemmed') and
                            not Casting.CanUseAA("Radiant Cure")
                    end,
                },
                {
                    name = "CureDisease",
                    cond = function(self)
                        return not Core.GetResolvedActionMapItem('PureBlood') and Config:GetSetting('KeepDiseaseMemmed') and
                            not Casting.CanUseAA("Radiant Cure")
                    end,
                },
                { name = "CureCurse",      cond = function(self) return Config:GetSetting('KeepCurseMemmed') end, },
                { name = "EvacSpell",      cond = function(self) return Config:GetSetting('KeepEvacMemmed') and not Casting.CanUseAA("Exodus") end, },
                { name = "StunNuke",       cond = function(self) return Config:GetSetting('DoStunNuke') end, },
                { name = "TwinHealNuke",   cond = function(self) return Config:GetSetting('DoTwinHealNuke') end, },
                { name = "FireNuke",       cond = function(self) return Config:GetSetting('DoFireNuke') end, },
                { name = "IceNuke",        cond = function(self) return Config:GetSetting('DoIceNuke') end, },
                { name = "PBAEMagic",      cond = function(self) return Config:GetSetting('DoPBAE') end, },
                { name = "IceRain",        cond = function(self) return Config:GetSetting('DoRain') end, },
                { name = "FlameLickDot",   cond = function(self) return Config:GetSetting('DoFlameLickDot') end, },
                { name = "SwarmDot",       cond = function(self) return Config:GetSetting('DoSwarmDot') end, },
                { name = "VengeanceDot",   cond = function(self) return Config:GetSetting('DoVengeanceDot') end, },
                -- { name = "BurstDS",      cond = function(self) return Config:GetSetting('DoBurstDS') end, },
                { name = "PureBlood",      cond = function(self) return Config:GetSetting('KeepPoisonMemmed') or Config:GetSetting('KeepDiseaseMemmed') end, },
                { name = "CurePoison",     cond = function(self) return not Core.GetResolvedActionMapItem('PureBlood') and Config:GetSetting('KeepPoisonMemmed') end, },
                { name = "CureDisease",    cond = function(self) return not Core.GetResolvedActionMapItem('PureBlood') and Config:GetSetting('KeepDiseaseMemmed') end, },
                { name = "CureCurse",      cond = function(self) return Config:GetSetting('KeepCurseMemmed') end, },
                --fallback QoL to take up extra slots
                { name = "GroupRegenBuff", cond = function(self) return Config:GetSetting('DoGroupRegen') end, },
                { name = "GroupDmgShield", cond = function(self) return Config:GetSetting('DoGroupDmgShield') end, },
                { name = "HPTypeOneGroup", cond = function(self) return Config:GetSetting('DoHPBuff') end, },
            },
        },
    },
    ['HelperFunctions']   = {
        DoRez = function(self, corpseId)
            local rezAction = false
            local rezSpell = Core.GetResolvedActionMapItem('RezSpell')
            local okayToRez = Casting.OkayToRez(corpseId)
            local combatState = mq.TLO.Me.CombatState():lower() or "unknown"

            if combatState == "combat" and Config:GetSetting('DoBattleRez') and Core.OkayToNotHeal() then
                if mq.TLO.FindItem("Staff of Forbidden Rites")() and mq.TLO.Me.ItemReady("Staff of Forbidden Rites")() then
                    rezAction = okayToRez and Casting.UseItem("Staff of Forbidden Rites", corpseId)
                elseif Casting.AAReady("Call of the Wild") and corpseId ~= mq.TLO.Me.ID() then
                    rezAction = okayToRez and Casting.UseAA("Call of the Wild", corpseId, true, 1)
                end
            elseif combatState == "active" or combatState == "resting" then
                if Casting.AAReady("Rejuvenation of Spirit") then
                    rezAction = okayToRez and Casting.UseAA("Rejuvenation of Spirit", corpseId, true, 1)
                elseif not Casting.CanUseAA("Rejuvenation of Spirit") and Casting.SpellReady(rezSpell, true) then
                    rezAction = okayToRez and Casting.UseSpell(rezSpell, corpseId, true, true)
                end
            end

            if rezAction and mq.TLO.Spawn(corpseId).Distance3D() > 25 then
                Targeting.SetTarget(corpseId)
                Core.DoCmd("/corpse")
            end

            return rezAction
        end,

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
            if not Config:GetSetting('DoRain') or not Config:GetSetting('DoAEDamage') then return false end
            return Targeting.GetTargetDistance() >= Config:GetSetting('RainDistance')
        end,
    },
    --TODO: These are nearly all in need of Display and Tooltip updates.
    ['DefaultConfig']     = {
        ['Mode']              = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 3, },

        -- Buffs
        ['DoMoveBuffs']       = {
            DisplayName = "Do Movement Buffs",
            Category = "Buffs",
            Index = 1,
            Tooltip = "Cast Movement Spells/AA.",
            Default = false,
            FAQ = "Why am I spamming movement buffs?",
            Answer = "Some move spells freely overwrite those of other classes, so if multiple movebuffs are being used, a buff loop may occur.\n" ..
                "Simply turn off movement buffs for the undesired class in their class options.",
        },
        ['DoHPBuff']          = {
            DisplayName = "Group HP Buff",
            Category = "Buffs",
            Index = 2,
            Tooltip = "Use your group HP Buff. Disable as desired to prevent conflicts with CLR or PAL buffs.",
            Default = true,
            FAQ = "Why am I in a buff war with my Paladin or Druid? We are constantly overwriting each other's buffs.",
            Answer = "Disable [DoHPBuff] to prevent issues with Aego/Symbol lines overwriting. Alternatively, you can adjust the settings for the other class instead.",
        },
        ['DoGroupRegen']      = {
            DisplayName = "Group Regen Buff",
            Category = "Buffs",
            Index = 3,
            Tooltip = "Use your Group Regen buff.",
            Default = true,
            FAQ = "Why am I spamming my Group Regen buff?",
            Answer = "Certain Shaman and Druid group regen buffs report cross-stacking. You should deselect the option on one of the PCs if they are grouped together.",
        },
        ['DoGroupDmgShield']  = {
            DisplayName = "Group Dmg Shield",
            Category = "Buffs",
            Index = 4,
            Tooltip = "Use your group damage shield buff.",
            Default = true,
            FAQ = "Why do my druid and mage constantly both try to use the damage shield?",
            Answer = "You can disable the group damage shield (DS) buff option on the Buffs tab.",
        },
        ['SpireChoice']       = {
            DisplayName = "Spire Choice:",
            Category = "Buffs",
            Index = 5,
            Tooltip = "Choose which Fundament you would like to use during burns:\n" ..
                "First Spire: Spell Crit Buff to Self.\n" ..
                "Second Spire: Healing Power Buff to Self.\n" ..
                "Third Spire: Large Group HP Buff.",
            Type = "Combo",
            ComboOptions = Config.Constants.SpireChoices,
            Default = 3,
            Min = 1,
            Max = #Config.Constants.SpireChoices,
            FAQ = "Why am I using the wrong spire?",
            Answer = "You can choose which spire you prefer in the Class Options.",
        },
        ['WolfSpiritChoice']  = {
            DisplayName = "Self Wolfbuff Choice:",
            Category = "Buffs",
            Index = 6,
            Tooltip = "Choose which wolf spirit buff you would like to maintain on yourself:\n" ..
                "White: Increased healing and reduced mana cost for healing spells. Mana Regeneration and Cold Resist.\n" ..
                "Black: Increased damage and reduced mana cost for damage spells. Mana Regeneration and Fire Resist.",
            Type = "Combo",
            ComboOptions = { 'White', 'Black', },
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "Why am I using the wrong wolf form?",
            Answer = "You can choose which wolf form you prefer in the Class Options.",
        },
        -- ['DoBurstDS']         = {
        --     DisplayName = "Do Burst DS",
        --     Category = "Buffs",
        --     Index = 5,
        --     Tooltip = "Use your Barkspur buff.",
        --     Default = false,
        --     FAQ = "Why am I spamming my Group Regen buff?",
        --     Answer = "Certain Shaman and Druid group regen buffs report cross-stacking. You should deselect the option on one of the PCs if they are grouped together.",
        -- },

        --Debuffs
        ['DoSnare']           = {
            DisplayName = "Use Snares",
            Category = "Debuffs",
            Index = 1,
            Tooltip = "Use Snare(Snare Dot used until AA is available).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not snaring?",
            Answer = "Make sure Use Snares is enabled in your class settings.",
        },
        ['SnareCount']        = {
            DisplayName = "Snare Max Mob Count",
            Category = "Debuffs",
            Index = 2,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
            Min = 1,
            Max = 99,
            FAQ = "Why is my Shadow Knight Not snaring?",
            Answer = "Make sure you have [DoSnare] enabled in your class settings.\n" ..
                "Double check the Snare Max Mob Count setting, it will prevent snare from being used if there are more than [x] mobs on aggro.",
        },
        ['DoFireDebuff']      = {
            DisplayName = "Fire Debuff",
            Category = "Debuffs",
            Index = 3,
            Tooltip = "Use your fire resist debuff (to include the (Hand > Blessing) of Ro AA).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my fire resist debuff?",
            Answer = "Make sure the debuff is enabled in your class settings.",
        },
        ['DoColdDebuff']      = {
            DisplayName = "Cold Debuff",
            Category = "Debuffs",
            Index = 4,
            Tooltip = "Use your cold resist debuff.",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my cold resist debuff?",
            Answer = "Make sure the debuff is enabled in your class settings.",
        },
        ['DoATKDebuff']       = {
            DisplayName = "ATK Debuff",
            Category = "Debuffs",
            Index = 5,
            Tooltip = "Use your attack resist debuff.",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my attack resist debuff?",
            Answer = "Make sure the debuff is enabled in your class settings.",
        },

        --Damage
        ['DoFireNuke']        = {
            DisplayName = "Fire Nuke",
            Category = "Damage",
            Index = 1,
            Tooltip = "Use your single-target fire nukes.",
            Default = true,
            FAQ = "Why am I nuking? A druid is a healer.",
            Answer = "You can disable this in your class settings.",
        },
        ['DoIceNuke']         = {
            DisplayName = "Cold Nuke",
            Category = "Damage",
            Index = 2,
            Tooltip = "Use your single-target cold nukes.",
            Default = false,
            FAQ = "Why am I using fire nukes? The mobs are fire-resistant.",
            Answer = "You can change which nukes you are using in your class settings.",
        },
        ['DoStunNuke']        = {
            DisplayName = "Stun Nuke",
            Category = "Damage",
            Index = 3,
            Tooltip = "Use your stun nukes (magic damage with stun component).",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why is my twinheal nuke targeting the mob, that isn't how it works?!",
            Answer = "On Lazarus, the twinheal nuke targets the mob to function, the in-game description is incorrect.",
        },
        ['DoTwinHealNuke']    = {
            DisplayName = "Twinheal Nuke",
            Category = "Damage",
            Index = 4,
            Tooltip = "Use your twinheal nuke (fire damage with a twinheal buff effect).",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why is my twinheal nuke targeting the mob, that isn't how it works?!",
            Answer = "On Lazarus, the twinheal nuke targets the mob to function, the in-game description is incorrect.",
        },
        ['DoFlameLickDot']    = {
            DisplayName = "Fire Debuff Dot",
            Category = "Damage",
            Index = 5,
            Tooltip = "Use your Flame Lick line of dots (fire damage, fire resist debuff, 60s duration).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my fire debuff (Flame Lick) dot?",
            Answer = "Make sure the dot is enabled in your class settings.",
        },
        ['DoVengeanceDot']    = {
            DisplayName = "Fire Dot",
            Category = "Damage",
            Index = 6,
            Tooltip = "Use your Vengeance line of dots (fire damage, 30s duration).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my fire (Vengeance) dot?",
            Answer = "Make sure the dot is enabled in your class settings.",
        },
        ['DoSwarmDot']        = {
            DisplayName = "Magic Dot",
            Category = "Damage",
            Index = 7,
            Tooltip = "Use your Swarm line of dots (magic damage, 54s duration).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my magic (Swarm) dot?",
            Answer = "Make sure the dot is enabled in your class settings.",
        },
        ['DotNamedOnly']      = {
            DisplayName = "Only Dot Named",
            Category = "Damage",
            Index = 8,
            Tooltip = "Any selected dot above will only be used on a named mob.",
            Default = true,
            FAQ = "Why am I not using my dots?",
            Answer = "Make sure the dot is enabled in your class settings and make sure that the mob is named if that option is selected.\n" ..
                "You can read more about named mobs on the RGMercs named tab (and learn how to add one on your own!)",
        },

        --Damage(AE)
        ['DoAEDamage']        = {
            DisplayName = "Do AE Damage",
            Category = "Damage(AE)",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['DoPBAE']            = {
            DisplayName = "Use PBAE Spells",
            Category = "Damage(AE)",
            Index = 2,
            RequiresLoadoutChange = true,
            Tooltip =
            "**WILL BREAK MEZ** Use your Magic PB AE Spells . **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['DoRain']            = {
            DisplayName = "Use Ice Rain",
            Category = "Damage(AE)",
            Index = 3,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            Tooltip = "**WILL BREAK MEZ** Use your cold damage rain spell. **WILL BREAK MEZ***",
            Default = false,
            FAQ = "How can I use my rain nuke?",
            Answer = "This can be enabled on the AEDamage tab, ensure you also have AE damage on.",
        },
        ['RainDistance']      = {
            DisplayName = "Min Rain Distance",
            Category = "Damage(AE)",
            Index = 4,
            ConfigType = "Advanced",
            Tooltip = "The minimum distance a target must be to use a Rain (Rain AE Range: 25').",
            Default = 30,
            Min = 0,
            Max = 100,
            FAQ = "Why does minimum rain distance matter?",
            Answer = "Rain spells, if cast close enough, can damage the caster. The AE range of a Rain is 25'.",
        },
        ['AETargetCnt']       = {
            DisplayName = "AE Tgt Cnt",
            Category = "Damage(AE)",
            Index = 5,
            Tooltip = "Minimum number of valid targets before using PB Spells like the of Flame line.",
            Default = 4,
            Min = 1,
            Max = 10,
            FAQ = "Why am I not using my PBAE spells?",
            Answer =
            "You can adjust the AE Target Count to control when you will use the abilities.",
        },
        ['MaxAETargetCnt']    = {
            DisplayName = "Max AE Targets",
            Category = "Damage(AE)",
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
        ['SafeAEDamage']      = {
            DisplayName = "AE Proximity Check",
            Category = "Damage(AE)",
            Index = 7,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },

        -- Utility
        ['DoElixir']          = {
            DisplayName = "Use Elixir",
            Category = "Utility",
            Index = 1,
            Tooltip = "Use the Elixir Line (Yes, druids get Elixirs on Laz).",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my druid using the elixir line?",
            Answer = "Since the elixirs druids get are slighly behind clerics of equal level, we will bypass their use if your target is already in \"BigHeal\" range.",
        },
        ['KeepPoisonMemmed']  = {
            DisplayName = "Mem Cure Poison",
            Category = "Utility",
            Index = 2,
            Tooltip = "Memorize cure poison spell when possible (depending on other selected options). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if available.",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why do I have to stop to memorize a cure every time someone gets an effect?",
            Answer =
            "You can choose to keep a cure memorized in the class options. If you have selected it, and it isn't being memmed, you may have chosen too many other optional spells to use/memorize.",
        },
        ['KeepDiseaseMemmed'] = {
            DisplayName = "Mem Cure Disease",
            Category = "Utility",
            Index = 3,
            Tooltip = "Memorize cure disease spell when possible (depending on other selected options). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if available.",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why do I have to stop to memorize a cure every time someone gets an effect?",
            Answer =
            "You can choose to keep a cure memorized in the class options. If you have selected it, and it isn't being memmed, you may have chosen too many other optional spells to use/memorize.",
        },
        ['KeepCurseMemmed']   = {
            DisplayName = "Mem Remove Curse",
            Category = "Utility",
            Index = 4,
            Tooltip = "Memorize remove curese spell when possible (depending on other selected options). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if available.",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why do I have to stop to memorize a cure every time someone gets an effect?",
            Answer =
            "You can choose to keep a cure memorized in the class options. If you have selected it, and it isn't being memmed, you may have chosen too many other optional spells to use/memorize.",
        },
        ['GroupHealAsCure']   = {
            DisplayName = "Use Group Heal to Cure",
            Category = "Utility",
            Index = 4,
            Tooltip = "If Word of Reconstitution is available, use this to cure instead of individual cure spells. \n" ..
                "Please note that we will prioritize Remove Greater Curse if you have selected to keep it memmed as above (due to the counter disparity).",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I using my Group Heal when I should be curing?",
            Answer =
                "Word of Reconsitatutioon claers poison/disease/curse counters and is used optionally as a cure. You can disable this behavior in your class options on the Utility tab.\n" ..
                "Some earlier group heal spells also clear counters, but the config must be customized to use them.",
        },
        ['DoArcanumWeave']    = {
            DisplayName = "Weave Arcanums",
            Category = "Utility",
            Index = 6,
            Tooltip = "Weave Empowered/Enlighted/Acute Focus of Arcanum into your standard combat routine (Focus of Arcanum is saved for burns).",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = true,
            FAQ = "What is an Arcanum and why would I want to weave them?",
            Answer =
            "The Focus of Arcanum series of AA decreases your spell resist rates.\nIf you have purchased all four, you can likely easily weave them to keep 100% uptime on one.",
        },
        ['KeepEvacMemmed']    = {
            DisplayName = "Memorize Evac",
            Category = "Utility",
            Index = 7,
            Tooltip = "Keep (Lesser) Succor memorized.",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "I want my druid to keep an evac memorized, is this possible?",
            Answer = "Enable the Memorize Evac setting to keep Succor or Lessor Succor on your spell bar.",
        },
    },
}

return _ClassConfig
