local mq           = require('mq')
local Config       = require('utils.config')
local Comms        = require("utils.comms")
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")

local _ClassConfig = {
    _version              = "3.0 - Project Lazarus",
    _author               = "Algar, Derple",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return true end,
        IsRezing = function() return Config:GetSetting('DoBattleRez') or Targeting.GetXTHaterCount() == 0 end,
    },
    ['Modes']             = {
        'Heal',
        'Hybrid',
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
                    local diseaseCure = Casting.GetFirstMapItem({ groupHeal, "GroupCure", "CureDisease", })
                    cureSpell = Core.GetResolvedActionMapItem(diseaseCure)
                elseif type:lower() == "poison" then
                    local poisonCure = Casting.GetFirstMapItem({ groupHeal, "GroupCure", "CurePoison", })
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
            "Crafted Talisman of Fates",
            "Blessed Spiritstaff of the Heyokah",
        },
    },
    ['AbilitySets']       = {
        ["GroupFocusSpell"] = {
            -- Focus Spell - Group Spells will be used on everyone
            "Khura's Focusing",     -- Level 60 - Group
            "Focus of the Seventh", -- Level 65 - Group
            "Talisman of Wunshi",   -- Level 70 - Group
        },
        ["RunSpeedBuff"] = {
            -- Run Speed Buff - 9 - 74
            "Spirit of Bih`Li",
            "Pack Shrew",
            "Spirit of Wolf",
        },
        ["HasteBuff"] = {
            -- Haste Buff - 26 - 64
            "Talisman of Celerity",
            "Swift Like the Wind",
            "Celerity",
            "Quickness",
        },
        ["Unification"] = { -- Many buffs combined: 75 Sta, 50 sta cap, 7% evasion, 5% damage
            "Talisman of Unification",
        },
        ["LowLvlStaBuff"] = {
            -- Low Level Stamina Buff --- I guess this may be okay for tanks (but largely a raid thing). Need to scrub which levels. Not currently used.
            "Spirit of Bear",
            "Spirit of Ox",
            "Health",
            "Stamina",
            "Riotous Health",
            "Talisman of the Brute",
            "Endurance of the Boar",
            "Talisman of the Boar",
            "Spirit of Fortitude",
            "Talisman of Fortitude",
            "Talisman of Persistence",
            "Talisman of Vehemence",
            "Spirit of Vehemence",
        },
        ["LowLvlAtkBuff"] = {
            -- Low Level Attack Buff --- user under level 86. Including Harnessing of Spirit as they will have similar usecases and targets.
            "Harnessing of Spirit",
            "Primal Avatar",
            "Ferine Avatar",
            "Champion",
        },
        ["LowLvlHPBuff"] = {
            "Inner Fire",         -- Level 1 - Single
            "Talisman of Tnarg",  -- Level 32 - Single
            "Talisman of Altuna", -- Level 40 - Single
            "Talisman of Kragg",  -- Level 55 - Single
        },
        ["LowLvlStrBuff"] = {
            -- Low Level Strength Buff -- Below 68 these are only worthwhile on non-live, defiant stat caps too easily. Even then arguable.
            "Talisman of Might",  -- Level 70, Group
            "Spirit of Might",    -- Level 68, Single Target
            "Talisman of the Diaku",
            "Infusion of Spirit", -- Level 49, Str/Dex/Sta, can use HP buff
            "Tumultuous Strength",
            "Raging Strength",
            "Spirit Strength", -- Level 18, Can't see this as being very worth but keeping for now.
        },
        ["LowLvlDexBuff"] = {
            -- Low Level Dex Buff -- This has no real place outside of raids on select tanks. Waste of mana.
            "Talisman of the Raptor",
            "Mortal Deftness",
            "Dexterity",
            "Deftness",
            "Rising Dexterity",
            "Spirit of Monkey",
            "Dexterous Aura",
        },
        ["LowLvlAgiBuff"] = {
            --- Low Level AGI Buff -- This has no real place outside of raids on select tanks. Waste of mana.
            "Talisman of Sense",
            "Spirit of Sense",
            "Talisman of the Wrulan",
            "Agility of the Wrulan",
            "Talisman of the Cat",
            "Deliriously Nimble",
            "Agility",
            "Nimble",
            "Spirit of Cat",
            "Feet like Cat",
        },
        ["AEMaloSpell"] = {
            "Idol of Malos",
        },
        ["MaloSpell"] = {
            "Malos",
            "Malosinia",
            "Malo",
            "Malosini",
            --Below this these spells are considered by many to be a waste of mana, but the user can elect to turn this off.
            "Malosi",
            "Malaisement",
            "Malaise",
        },
        ["AESlowSpell"] = { --Often considered a waste of mana in group situations, user option.
            "Tigir's Insects",
        },
        ["SlowSpell"] = {
            "Balance of Discord",
            "Balance of the Nihil",
            "Turgur's Insects", --Can save mana by continuing to use Togor's on group mobs, but this is problematic for automation. Not worth splitting the entry.
            "Togor's Insects",
            "Tagar's Insects",
            --"Walking Sleep", --Too much mana with little benefit at these levels
            --"Drowsy", --Too much mana with little benefit at these levels
        },
        ["DiseaseSlow"] = {
            "Cloud of Grummus",
            "Plague of Insects",
        },
        ["CrippleSpell"] = {   -- needs to be added to spell list and have entries made
            "Crippling Spasm", -- Level 66
            "Cripple",         -- Level 53, Starts to become worth it, depending on target
            "Incapacitate",    -- Level 41, Likely not worth
            "Listless Power",  -- Level 29, Definitely not worth
        },
        ["MeleeProcBuff"] = {
            "Talisman of the Panther",
            -- Below Level 70 This is a single target buff and will be keyed off of the MA
            "Spirit of the Panther",
            "Spirit of the Leopard",
            "Spirit of the Jaguar",
            "Spirit of the Puma",
        },
        ["SlowProcBuff"] = {
            "Lingering Sloth",
        },
        ['RezSpell'] = {
            'Incarnate Anew', -- Level 59
            'Resuscitate',    --emu only
            'Revive',         --emu only
            'Reanimation',    --emu only
        },
        ["HealSpell"] = {
            "Ancient: Wilslik's Mending",
            "Yoppa's Mending",
            "Daluda's Mending",
            "Tnarg's Mending",
            "Chloroblast",
            "Kragg's Salve",
            "Superior Healing",
            "Spirit Salve",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
        },
        ['GroupHeal'] = { -- Laz specific, some taken from cleric, some custom
            "Word of Reconstitution",
            "Word of Redemption",
            "Word of Restoration",
            "Word of Vigor",
            "Word of Healing",
            "Word of Health",
        },
        ["GroupRenewalHoT"] = {
            --This seems entirely not worth using since they were given direct group heals
            "Ghost of Renewal",
        },
        ['SnareHot'] = {
            "Transcendent Torpor",
            "Torpor",
            "Stoicism",
        },
        ["SingleHot"] = { -- some elixirs given to shm/dru on laz
            "Spiritual Serenity",
            "Breath of Trushar",
            "Quiescence",
            -- "Celestial Elixir" -- Quiescence same level and better
            "Celestial Healing",
            "Celestial Health",
            "Celestial Remedy",
        },
        ["CanniSpell"] = {
            -- Convert Health to Mana - Level  23 -
            "Ancient: Ancestral Calling",
            "Pained Memory",
            "Ancient: Chaotic Pain",
            "Cannibalize IV",
            "Cannibalize III",
            "Cannibalize II",
            "Cannibalize",
        },
        -- ["CureSpell"] = { --This is not useful in light of the alternatives
        --     "Blood of Nadox",
        -- },
        ["TwinHealNuke"] = {
            -- Nuke the MA Not the assist target - Levels 70
            "Frostfall Boon",
        },
        ["PoisonNuke"] = {
            -- Poison Nuke LVL34 +
            "Yoppa's Spear of Venom",
            "Spear of Torment",
            "Blast of Venom",
            "Shock of Venom",
            "Blast of Poison",
            "Shock of the Tainted",
        },
        ["ColdNuke"] = {
            --- ColdNuke - Level 4+
            --"Dire Avalanche", -- In resources but not scribable I think?
            "Ice Age",
            "Velium Strike",
            "Ice Strike",
            "Blizzard Blast",
            "Winter's Roar",
            "Frost Strike",
            "Spirit Strike",
            "Frost Rift",
        },
        ["CurseDot"] = {
            -- Curse Dot 1 Stacking: Curse - Long Dot(30s) - Level 34+
            "Curse of Sisslak",
            "Bane",
            "Anathema",
            "Odium",
            "Curse",
        },
        ["SaryrnDot"] = {
            -- Stacking: Blood of Saryrn - Long Dot(42s) - Level 8+
            "Nectar of Pain",
            "Blood of Saryrn",
            "Ancient: Scourge of Nife",
            "Bane of Nife",
            "Envenomed Bolt",
            "Venom of the Snake",
            "Envenomed Breath",
            "Tainted Breath",
        },
        ["UltorDot"] = {
            ---, Stacking: Breath of Ultor - Long Dot(84s) - Level 4+
            "Breath of Wunshi",
            "Breath of Ultor",
            "Pox of Bertoxxulous",
            "Plague",
            "Scourge",
            "Affliction",
            "Sicken",
        },
        ["AEDot"] = { -- do homework for Laz
            "Blood of Yoppa",
        },
        ["PetSpell"] = { --We need to add handling for commune to get the mammoth/etc
            -- Pet Spell - 32+
            "Commune with the Wild",
            "Farrel's Companion",
            "True Spirit",
            "Spirit of the Howler",
            "Frenzied Spirit",
            "Guardian spirit",
            "Vigilant Spirit",
            "Companion Spirit",
        },
        -- ["PetBuffSpell"] = { -- Haste is generally better
        --     ---Pet Buff Spell - 50+
        --     "Spirit Quickening",
        -- },
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
        ['GroupCure'] = {
            "Blood of Nadox",
        },
        ["GroupRegenBuff"] = {
            "Talisman of Perseverance",
            "Regrowth of Dar Khura", -- Level 56
        },
        ["SingleRegenBuff"] = {
            "Regrowth",
            "Chloroplast",
            "Regeneration", -- Level 22
        },
        ["ShrinkSpell"] = {
            "Shrink",
        },
        ["PutridDecay"] = { -- Level 66 Poi/Dis resist debuff
            "Putrid Decay",
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

            return rezAction
        end,
    },
    -- These are handled differently from normal rotations in that we try to make some intelligent desicions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'BigHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.BigHealsNeeded(target) end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ["GroupHealPoint"] = {
            {
                name = "Call of the Ancients",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.BigHealsNeeded(target)
                end,
            },
            {
                name = "GroupHeal",
                type = "Spell",
            },
        },
        ["BigHealPoint"] = {
            {
                name = "SnareHot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSnareHot') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Ancestral Guard",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "Zun'Muram's Spear of Doom",
                type = "Item",
            },
            {
                name = "Union of Spirits",
                type = "AA",
            },
            { --The stuff above is down, lets make mainhealpoint chonkier.
                name = "Spiritual Blessing",
                type = "AA",
            },
            {
                name = "Armor of Ancestral Spirits",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target)
                end,
            },
        },
        ["MainHealPoint"] = {
            {
                name = "SingleHot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSingleHot') then return false end
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
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.OkayToBuff() and
                    Casting.AmIBuffable()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and
                    Casting.AmIBuffable()
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
        { --Spells that should be checked on group members
            name = 'GroupBuff',
            timer = 60,
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.OkayToBuff()
            end,
        },
        {
            name = 'Malo',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSTMalo') or Config:GetSetting('DoAEMalo') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff() and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'Slow',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSTSlow') or Config:GetSetting('DoAESlow') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff() and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'PutridDecay',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoPutrid') and Core.GetResolvedActionMapItem("PutridDecay") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff() and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and
                    (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'CombatBuff',
            timer = 10,
            state = 1,
            steps = 1,
            load_cond = function(self) return self:GetResolvedActionMapItem('MeleeProcBuff') end,
            targetId = function(self) return { Core.GetMainAssistId(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'ArcanumWeave',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoArcanumWeave') and Casting.CanUseAA("Acute Focus of Arcanum") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not mq.TLO.Me.Buff("Focus of Arcanum")() and
                    (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },

    },
    ['Rotations']         = {
        ['CombatBuff'] = {
            {
                name = "MeleeProcBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Fleeting Spirit",
                type = "AA",
            },
            {
                name = "Ancestral Aid",
                type = "AA",
            },
            {
                name = "Fundament: Second Spire of Ancestors",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target)
                end,
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            {
                name = "Spirit Call",
                type = "AA",
            },
            {
                name = "Extended Pestilence",
                type = "AA",
            },
            {
                name = "Rabid Bear",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "Spear of Fate",
                type = "Item",
                cond = function(self, itemName, target)
                    return Targeting.IsNamed(target)
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVetAA')
                end,
            },
            {
                name = "Shattered Gnoll Slayer",
                type = "Item",
            },
        },
        ['Malo'] = {
            {
                name = "AEMaloSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAEMalo') then return false end
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AEMaloCount') and Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "Malosinete",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoSTMalo') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "MaloSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSTMalo') or Casting.CanUseAA("Malosinete") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Slow'] = {
            {
                name = "Tigir's Insect Swarm",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoAESlow') then return false end
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AESlowCount') and Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "AESlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAESlow') or Casting.CanUseAA("Tigir's Insect Swarm") then return false end
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AESlowCount') and Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "Turgur's Swarm",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoSTSlow') or Config:GetSetting('DoDiseaseSlow') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name_func = function(self)
                    return Config:GetSetting('DoDiseaseSlow') and "DiseaseSlow" or "SlowSpell"
                end,
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSTSlow') or (not Config:GetSetting('DoDiseaseSlow') and Casting.CanUseAA("Turgur's Swarm")) then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['PutridDecay'] = {
            {
                name = "PutridDecay",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
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
                name = "CurseDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoCurseDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "SaryrnDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSaryrnDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "UltorDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoUltorDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "Cannibalization",
                type = "AA",
                allowDead = true,
                cond = function(self, aaName)
                    if not (Config:GetSetting('DoAACanni') and Config:GetSetting('DoCombatCanni')) then return false end
                    return mq.TLO.Me.PctMana() < Config:GetSetting('AACanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('AACanniMinHP')
                end,
            },
            {
                name = "CanniSpell",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell)
                    if not (Config:GetSetting('DoSpellCanni') and Config:GetSetting('DoCombatCanni')) then return false end
                    return mq.TLO.Me.PctMana() < Config:GetSetting('SpellCanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('SpellCanniMinHP')
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
                name = "ColdNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoColdNuke') then return false end
                    return (Targeting.MobHasLowHP or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target))) and Casting.HaveManaToNuke()
                end,
            },
            {
                name = "PoisonNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoPoisonNuke') then return false end
                    return (Targeting.MobHasLowHP or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target))) and Casting.HaveManaToNuke()
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 end,
                cond = function(self, _) return Config:GetSetting('DoPet') and mq.TLO.Me.Pet.ID() == 0 end,
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
                name = "Cannibalization",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoAACanni') and mq.TLO.Me.PctMana() < Config:GetSetting('AACanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('AACanniMinHP')
                end,
            },
            {
                name = "CanniSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoSpellCanni') and Casting.CastReady(spell) and mq.TLO.Me.PctMana() < Config:GetSetting('SpellCanniManaPct') and
                        mq.TLO.Me.PctHPs() >= Config:GetSetting('SpellCanniMinHP')
                end,
            },
            {
                name = "Pact of the Wolf",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },

            -- {
            --     -- this is emu only and lands only on your group but not yourself
            --     name = "Pact of the Wolf",
            --     type = "CustomFunc",
            --     active_cond = function(self) return mq.TLO.Me.Aura("Pact of the Wolf Effect")() ~= nil end,
            --     custom_func = function(self)
            --         if not Config:GetSetting('DoAura') or mq.TLO.Me.Aura("Pact of the Wolf Effect")() ~= nil then return false end
            --         Casting.UseAA("Pact of the Wolf", mq.TLO.Me.ID())
            --         mq.delay(500, function() return Casting.AAReady('Group Pact of the Wolf') end)
            --         Casting.UseAA("Group Pact of the Wolf", mq.TLO.Me.ID())
            --         return true
            --     end,
            -- },
        },
        ['PetBuff'] = {
            {
                name = "HasteBuff",
                type = "Spell",
                active_cond = function(self, aaName) return mq.TLO.Me.Haste() end,
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Pet Affinity") then return false end
                    return Casting.PetBuffCheck(spell)
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
                name = "Crystalized Soul Gem", -- This isn't a typo
                type = "Item",
                cond = function(self, itemName)
                    return Casting.PetBuffItemCheck(itemName)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Spirit Guardian",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.TargetIsMA(target) then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "SlowProcBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
                post_activate = function(self, spell, success)
                    local petName = mq.TLO.Me.Pet.CleanName() or "None"
                    mq.delay("3s", function() return not mq.TLO.Me.Casting() end)
                    if success and mq.TLO.Me.XTarget(petName)() then
                        Comms.PrintGroupMessage("It seems %s has triggered combat due to a server bug, calling the pet back.", spell)
                        Core.DoCmd('/pet back off')
                    end
                end,
            },
            { --Used on the entire group
                name = "GroupFocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Unification",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            { --Fix this, some priests will want this, adjust options
                name = "LowLvlAtkBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsAMelee(target) and Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Talisman of Celerity",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.Me.Haste() end,
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoHaste') then return false end
                    return mq.TLO.Me.Level() < 111 and Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "HasteBuff",
                type = "Spell",
                active_cond = function(self, aaName) return mq.TLO.Me.Haste() end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHaste') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupRegenBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoRegenBuff') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SingleRegenBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoRegenBuff') or Core.GetResolvedActionMapItem('GroupRegenBuff') then return false end --We don't need this once we can use the group version
                    return (Targeting.TargetIsATank(target) or Targeting.TargetIsMyself(target)) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell, target) --We get Tala'tak at 74, but don't get the AA version until 90
                    if not Config:GetSetting('DoRunSpeed') or (mq.TLO.Me.AltAbility("Lupine Spirit").Rank() or -1) > 3 then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Group Shrink",
                type = "AA",
                active_cond = function(self) return mq.TLO.Me.Height() < 2 end,
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoGroupShrink') then return false end
                    return target.Height() > 2.2
                end,
            },
            {
                name = "ShrinkSpell",
                type = "Spell",
                active_cond = function(self) return mq.TLO.Me.Height() < 2 end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupShrink') or Casting.CanUseAA("Group Shrink") then return false end
                    return target.Height() > 2.2
                end,
            },
            {
                name = "LowLvlHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLHPBuff') then return false end
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "LowLvlAgiBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLAgiBuff') then return false end
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "LowLvlStaBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLStaBuff') then return false end
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "LowLvlStrBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLStrBuff') then return false end
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsAMelee(target) and Casting.GroupBuffCheck(spell, target)
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
    -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
    -- Conditions are not limited to modes. Virtually any helper function or TLO can be used. Example: Level-based lists.
    -- The first list whose conditions returns true will be loaded, all subsequent lists will be ignored.
    -- Loadout checks (such as scribing a spell or using the "Rescan Loadout" or "Reload Spells" buttons) will re-check these lists and may load a different set if things have changed.
    ['SpellList']         = {
        {
            name = "Heal Mode", --This name is abitrary, it is simply what shows up in the UI when this spell list is loaded.
            cond = function(self) return Core.IsModeActive("Heal") end,
            spells = {          -- Spells will be loaded in order (if the conditions are met), until all gem slots are full.
                { name = "HealSpell", },
                { name = "SingleHot", cond = function(self) return Config:GetSetting('DoSingleHot') end, },
                { name = "SnareHot",  cond = function(self) return Config:GetSetting('DoSnareHot') end, },
                { name = "GroupHeal", },
                {
                    name = "GroupCure",
                    cond = function(self)
                        return (Config:GetSetting('KeepDiseaseMemmed') or Config:GetSetting('KeepPoisonMemmed')) and
                            not Casting.CanUseAA("Radiant Cure")
                    end,
                },
                {
                    name = "CurePoison",
                    cond = function(self)
                        return not Core.GetResolvedActionMapItem('GroupCure') and Config:GetSetting('KeepPoisonMemmed') and
                            not Casting.CanUseAA("Radiant Cure")
                    end,
                },
                {
                    name = "CureDisease",
                    cond = function(self)
                        return not Core.GetResolvedActionMapItem('GroupCure') and Config:GetSetting('KeepDiseaseMemmed') and
                            not Casting.CanUseAA("Radiant Cure")
                    end,
                },
                { name = "CureCurse",       cond = function(self) return Config:GetSetting('KeepCurseMemmed') end, },
                { name = "SlowSpell",       cond = function(self) return not Casting.CanUseAA("Turgur's Swarm") and Config:GetSetting('DoSTSlow') end, },
                { name = "AESlowSpell",     cond = function(self) return not Casting.CanUseAA("Tigir's Insect Swarm") and Config:GetSetting('DoAESlow') end, },
                { name = "DiseaseSlow",     cond = function(self) return Config:GetSetting('DoSTSlow') and Config:GetSetting('DoDiseaseSlow') end, },
                { name = "MaloSpell",       cond = function(self) return not Casting.CanUseAA("Malosinete") and Config:GetSetting('DoSTMalo') end, },
                { name = "AEMaloSpell",     cond = function(self) return Config:GetSetting('DoAEMalo') end, },
                { name = "PutridDecay",     cond = function(self) return Config:GetSetting('DoPutrid') end, },
                { name = "CanniSpell",      cond = function(self) return Config:GetSetting('DoSpellCanni') end, },
                { name = "MeleeProcBuff", },
                { name = "SlowProcBuff", },
                { name = "LowLvlAtkBuff", },
                { name = "SingleRegenBuff", cond = function(self) return not Core.GetResolvedActionMapItem('GroupRegenBuff') and Config:GetSetting('DoRegenBuff') end, },
                { name = "TwinHealNuke",    cond = function(self) return Config:GetSetting('DoTwinHealNuke') end, },
                { name = "ColdNuke",        cond = function(self) return Config:GetSetting('DoColdNuke') end, },
                { name = "PoisonNuke",      cond = function(self) return Config:GetSetting('DoPoisonNuke') end, },
                { name = "GroupCure",       cond = function(self) return Config:GetSetting('KeepPoisonMemmed') or Config:GetSetting('KeepDiseaseMemmed') end, },
                { name = "CurePoison",      cond = function(self) return not Core.GetResolvedActionMapItem('GroupCure') and Config:GetSetting('KeepPoisonMemmed') end, },
                { name = "CureDisease",     cond = function(self) return not Core.GetResolvedActionMapItem('GroupCure') and Config:GetSetting('KeepDiseaseMemmed') end, },
                { name = "CureCurse",       cond = function(self) return Config:GetSetting('KeepCurseMemmed') end, },
                { name = "CurseDot",        cond = function(self) return Config:GetSetting('DoCurseDot') end, },
                { name = "SaryrnDot",       cond = function(self) return Config:GetSetting('DoSaryrnDot') end, },
                { name = "UltorDot",        cond = function(self) return Config:GetSetting('DoUltorDot') end, },
            },
        },
        {
            name = "Hybrid Mode",
            cond = function(self) return Core.IsModeActive("Hybrid") end,
            spells = {
                { name = "HealSpell", },
                { name = "SlowSpell",     cond = function(self) return not Casting.CanUseAA("Turgur's Swarm") and Config:GetSetting('DoSTSlow') end, },
                { name = "AESlowSpell",   cond = function(self) return not Casting.CanUseAA("Tigir's Insect Swarm") and Config:GetSetting('DoAESlow') end, },
                { name = "DiseaseSlow",   cond = function(self) return Config:GetSetting('DoSTSlow') and Config:GetSetting('DoDiseaseSlow') end, },
                { name = "MaloSpell",     cond = function(self) return not Casting.CanUseAA("Malosinete") and Config:GetSetting('DoSTMalo') end, },
                { name = "AEMaloSpell",   cond = function(self) return Config:GetSetting('DoAEMalo') end, },
                { name = "PutridDecay",   cond = function(self) return Config:GetSetting('DoPutrid') end, },
                { name = "CanniSpell",    cond = function(self) return Config:GetSetting('DoSpellCanni') end, },
                { name = "MeleeProcBuff", },
                { name = "SlowProcBuff", },
                { name = "LowLvlAtkBuff", },
                { name = "ColdNuke",      cond = function(self) return Config:GetSetting('DoColdNuke') end, },
                { name = "PoisonNuke",    cond = function(self) return Config:GetSetting('DoPoisonNuke') end, },
                { name = "CurseDot",      cond = function(self) return Config:GetSetting('DoCurseDot') end, },
                { name = "SaryrnDot",     cond = function(self) return Config:GetSetting('DoSaryrnDot') end, },
                { name = "UltorDot",      cond = function(self) return Config:GetSetting('DoUltorDot') end, },
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHealNuke') end, },
                { name = "SingleHot",     cond = function(self) return Config:GetSetting('DoSingleHot') end, },
                { name = "SnareHot",      cond = function(self) return Config:GetSetting('DoSnareHot') end, },
                { name = "GroupHeal", },
                { name = "GroupCure",     cond = function(self) return Config:GetSetting('KeepPoisonMemmed') or Config:GetSetting('KeepDiseaseMemmed') end, },
                { name = "CurePoison",    cond = function(self) return not Core.GetResolvedActionMapItem('GroupCure') and Config:GetSetting('KeepPoisonMemmed') end, },
                { name = "CureDisease",   cond = function(self) return not Core.GetResolvedActionMapItem('GroupCure') and Config:GetSetting('KeepDiseaseMemmed') end, },
                { name = "CureCurse",     cond = function(self) return Config:GetSetting('KeepCurseMemmed') end, },
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
        {
            id = 'DDSpell',
            Type = "Spell",
            DisplayName = "Burst of Flame",
            AbilityName = "Burst of Flame",
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = mq.TLO.Spell("Burst of Flame")
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = {
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes do?",
            Answer =
            "Heal Mode: Primarily focuses on healing, cures, and maintaining HoTs. Secondary DPS focus with remaining spell gems. Hybrid: Prioritizes DPS spells over some utility healing abilities on the spell bar.",
        },

        -- Damage
        ['DoColdNuke']        = {
            DisplayName = "Cold Nuke",
            Category = "Damage",
            Index = 1,
            Tooltip = "Use your single-target cold nukes.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I using poison nukes? The mobs are poison-resistant.",
            Answer = "You can change which nukes you are using in your class settings.",
        },
        ['DoPoisonNuke']      = {
            DisplayName = "Poison Nuke",
            Category = "Damage",
            Index = 2,
            Tooltip = "Use your single-target poison nukes.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I nuking? A shaman is a healer.",
            Answer = "You can disable this in your class settings.",
        },
        ['DoTwinHealNuke']    = {
            DisplayName = "Twinheal Nuke",
            Category = "Damage",
            Index = 4,
            Tooltip = "Use your twinheal nuke (cold damage with a twinheal buff effect).",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why is my twinheal nuke targeting the mob, that isn't how it works?!",
            Answer = "On Lazarus, the twinheal nuke targets the mob to function, the in-game description is incorrect.",
        },
        ['DoSaryrnDot']       = {
            DisplayName = "Poison Dot",
            Category = "Damage",
            Index = 5,
            Tooltip = "Use your Saryrn line of dots (poison damage, single target).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my fire debuff (Flame Lick) dot?",
            Answer = "Make sure the dot is enabled in your class settings.",
        },
        ['DoUltorDot']        = {
            DisplayName = "Disease Dot",
            Category = "Damage",
            Index = 6,
            Tooltip = "Use your Ultor line of dots (disease damage, single target).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my fire (Vengeance) dot?",
            Answer = "Make sure the dot is enabled in your class settings.",
        },
        ['DoCurseDot']        = {
            DisplayName = "Magic Dot",
            Category = "Damage",
            Index = 7,
            Tooltip = "Use your Curse line of dots (magic damage, single target).",
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

        -- Healing
        ['DoSingleHot']       = {
            DisplayName = "Use Single HoT",
            Category = "Healing",
            Index = 1,
            Tooltip = "Use single target (non-snaring) HoTs like Spiritual Serenity as a main heal.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why does my Shaman randomly use HoTs in downtime?",
            Answer = "Maintaining HoTs prevents emergencies and hopefully allows for better DPS. It also grants Synergy Procs at high level.",
        },
        ['DoSnareHot']        = {
            DisplayName = "Use Snare HoT",
            Category = "Healing",
            Index = 2,
            Tooltip = "Use snaring HoTs like torpor when HP is very low.",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why does my Shaman randomly use HoTs in downtime?",
            Answer = "Maintaining HoTs prevents emergencies and hopefully allows for better DPS. It also grants Synergy Procs at high level.",
        },
        ['KeepPoisonMemmed']  = {
            DisplayName = "Mem Cure Poison",
            Category = "Healing",
            Index = 3,
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
            Category = "Healing",
            Index = 4,
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
            Category = "Healing",
            Index = 5,
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
            Category = "Healing",
            Index = 6,
            Tooltip = "If Word of Reconstitution is available, use this to cure instead of individual cure spells. \n" ..
                "Please note that we will prioritize Remove Greater Curse if you have selected to keep it memmed as above (due to the counter disparity).",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I using my Group Heal when I should be curing?",
            Answer =
                "Word of Reconsitatutioon claers poison/disease/curse counters and is used optionally as a cure. You can disable this behavior in your class options on the Utility tab.\n" ..
                "Some earlier group heal spells also clear counters, but the config must be customized to use them.",
        },

        -- Canni
        ['DoAACanni']         = {
            DisplayName = "Use AA Canni",
            Category = "Canni",
            Index = 4,
            Tooltip = "Use Canni AA",
            RequiresLoadoutChange = true, -- This is a load condition
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I not using the Canni AA?",
            Answer = "Check your HP/Mana percent settings, and, for combat, ensure you have selected the combat option as well.",
        },
        ['AACanniManaPct']    = {
            DisplayName = "AA Canni Mana %",
            Category = "Canni",
            Index = 5,
            Tooltip = "Use Canni AA Under [X]% mana",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Can you explain Canni Mana Settings?",
            Answer = "Setting the Mana % setting will use that form of Canni when you are below that mana percent.",
        },
        ['AACanniMinHP']      = {
            DisplayName = "AA Canni HP %",
            Category = "Canni",
            Index = 6,
            Tooltip = "Dont Use Canni AA Under [X]% HP",
            Default = 90,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Can you explain Canni HP Settings?",
            Answer = "Setting the HP % setting will stop you from using the form of Canni if you are below that HP percent.",
        },
        ['DoSpellCanni']      = {
            DisplayName = "Use Spell Canni",
            Category = "Canni",
            Index = 1,
            Tooltip = "Mem and use Canni Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I still using a Canni spell, now that I have the AA?",
            Answer =
            "By default, the Canni spell will be used while the gems are still available to do so, as Canni AA may not be enough at earlier levels. Use Spell Canni can be turned off at any time.",
        },
        ['SpellCanniManaPct'] = {
            DisplayName = "Spell Canni Mana %",
            Category = "Canni",
            Index = 2,
            Tooltip = "Use Canni Spell Under [X]% mana",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why do I wait so long to use my canni spell?",
            Answer = "Your Spell Canni Mana % governs how low you mana gets before you start using the spell.",
        },
        ['SpellCanniMinHP']   = {
            DisplayName = "Spell Canni HP %",
            Category = "Canni",
            Index = 3,
            Tooltip = "Dont Use Canni Spell Under [X]% HP",
            Default = 85,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why are Canni HP % settings so high?",
            Answer = "Default thresholds are conservative to prevent knee-jerk healing and can configured as needed.",
        },
        ['DoCombatCanni']     = {
            DisplayName = "Canni in Combat",
            Category = "Canni",
            Index = 7,
            Tooltip = "Use Canni AA and Spells in combat",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "My shaman spends his time in combat doing canni while I prefer him to do xyz other thing, what gives?",
            Answer =
            "Canni in Combat can be disabled at your discretion; you could also tune HP or Mana settings for Canni Spell or AA.",
        },

        -- Buffs
        ['UseEpic']           = {
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
        ['DoRunSpeed']        = {
            DisplayName = "Do Run Speed",
            Category = "Buffs",
            Index = 2,
            Tooltip = "Do Run Speed Spells/AAs",
            Default = true,
            FAQ = "Why are my buffers in a run speed buff war?",
            Answer = "Many run speed spells freely stack and overwrite each other, you will need to disable Run Speed Buffs on some of the buffers.",
        },
        ['DoGroupShrink']     = {
            DisplayName = "Group Shrink",
            Category = "Buffs",
            Index = 3,
            Tooltip = "Use Group Shrink Buff",
            Default = true,
            FAQ = "Group Shrink is enabled, why are my dudes still big?",
            Answer =
            "For simplicity, the check to use it is keyed to the Shaman's height, rather than checking each group member. Also, the AA isn't available until level 80 (on official servers).",
        },
        ['DoRegenBuff']       = {
            DisplayName = "Regen Buff",
            Category = "Buffs",
            Index = 6,
            Tooltip = "Use your Regen buff (single target will be used until the group version is available).",
            Default = true,
            FAQ = "Why am I spamming my Group Regen buff?",
            Answer = "Certain Shaman and Druid group regen buffs report cross-stacking. You should deselect the option on one of the PCs if they are grouped together.",
        },
        ['DoHaste']           = {
            DisplayName = "Use Haste",
            Category = "Buffs",
            Index = 7,
            Tooltip = "Do Haste Spells/AAs",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why aren't I casting Talisman of Celerity or other haste buffs?",
            Answer = "Even with Use Haste enabled, these buffs are part of your Focus spell (Unity) at very high levels, so they may not be needed.",
        },
        ['DoArcanumWeave']    = {
            DisplayName = "Weave Arcanums",
            Category = "Buffs",
            Index = 8,
            Tooltip = "Weave Empowered/Enlighted/Acute Focus of Arcanum into your standard combat routine (Focus of Arcanum is saved for burns).",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = true,
            FAQ = "What is an Arcanum and why would I want to weave them?",
            Answer =
            "The Focus of Arcanum series of AA decreases your spell resist rates.\nIf you have purchased all four, you can likely easily weave them to keep 100% uptime on one.",
        },
        ['DoVetAA']           = {
            DisplayName = "Do Vet AA",
            Category = "Buffs",
            Index = 9,
            Tooltip = "Use Veteran AA during burns (See FAQ).",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "What Veteran AA's will be used with Do Vet AA set?",
            Answer = "Currently, Shaman will use Intensity of the Resolute during burns. More may be added in the future.",
        },

        -- Debuffs
        ['DoSTMalo']          = {
            DisplayName = "Do ST Malo",
            Category = "Debuffs",
            Index = 1,
            Tooltip = "Do ST Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Cast Malo is selected, why am I not using it?",
            Answer = "Ensure that your Debuff settings in the RGMercs Main config are set properly, as there are options for con colors and named mobs there.",
        },
        ['DoAEMalo']          = {
            DisplayName = "Do AE Malo",
            Category = "Debuffs",
            Index = 2,
            Tooltip = "Do AE Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "I have Do AE Malo selected, why isn't it being used?",
            Answer = "The AE Malo Spell comes later in the levels for Shaman than AE Slows, and the AA later than that. Check your level. Also, ensure your count is set properly. ",
        },
        ['DoSTSlow']          = {
            DisplayName = "Do ST Slow",
            Category = "Debuffs",
            Index = 4,
            Tooltip = "Do ST Slow Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not slowing mobs?",
            Answer =
            "Certain low level slow spells are omitted due to the defensive benefit not being worth the mana. Also, check your debuff settings on the RGMercs Main config tabs, as there are options such as the minimum con color to debuff.",
        },
        ['DoAESlow']          = {
            DisplayName = "Do AE Slow",
            Category = "Debuffs",
            Index = 5,
            Tooltip = "Do AE Slow Spells/AAs",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why am I using a single-target slow after the AE Slow Spell?",
            Answer = "The AE Slow Spell is a lower slow percentage than the ST Version. AA, however, are identical other than number of targets.",
        },
        ['AESlowCount']       = {
            DisplayName = "AE Slow Count",
            Category = "Debuffs",
            Index = 6,
            Tooltip = "Number of XT Haters before we use AE Slow.",
            Min = 1,
            Default = 2,
            Max = 10,
            ConfigType = "Advanced",
            FAQ = "We are fighting more than one mob, why am I not using my AE Slow?",
            Answer = "AE Slow Count governs the minimum number of targets before the AE Slow is used.",
        },
        ['AEMaloCount']       = {
            DisplayName = "AE Malo Count",
            Category = "Debuffs",
            Index = 3,
            Tooltip = "Number of XT Haters before we use AE Malo.",
            Min = 1,
            Default = 2,
            Max = 10,
            ConfigType = "Advanced",
            FAQ = "We are fighting more than one mob, why am I not using my AE Malo?",
            Answer = "AE Malo Count governs the minimum number of targets before the AE Malo is used.",
        },
        ['DoDiseaseSlow']     = {
            DisplayName = "Disease Slow",
            Category = "Debuffs",
            Index = 7,
            Tooltip = "Use Disease Slow instead of normal ST Slow",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "What is a Disease Slow?",
            Answer =
            "During early eras of play, a slow that checked against disease resist was added to slow magic-resistant mobs. If selected, this will be used instead of a magic-based slow until the Turgur's AA becomes available.",
        },
        ['DoPutrid']          = {
            DisplayName = "Putrid Decay",
            Category = "Debuffs",
            Index = 7,
            Tooltip = "Use your disease/poison resist debuff.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I not using Putrid Decay",
            Answer = "Ensure the option is enabled on the Debuffs tab and ensure that your debuff settings are set in the main options.",
        },

        -- Low Level Buffs
        ['DoLLHPBuff']        = {
            DisplayName = "HP Buff (LowLvl)",
            Category = "Buffs (Low Level)",
            Index = 1,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using HP buffs at lower levels?",
            Answer =
                "They are not enabled by default as they can in many cases be a waste of mana or time to cast in automation.\n" ..
                "You can select the low level buffs you would like to use on the Buffs (Low Level) tab.",
        },
        ['DoLLAgiBuff']       = {
            DisplayName = "Agility Buff (LowLvl)",
            Category = "Buffs (Low Level)",
            Index = 2,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using stat buffs at lower levels?",
            Answer =
                "They are not enabled by default as they can in many cases be a waste of mana or time to cast in automation.\n" ..
                "You can select the low level buffs you would like to use on the Buffs (Low Level) tab.",
        },
        ['DoLLStaBuff']       = {
            DisplayName = "Stamina Buff (LowLvl)",
            Category = "Buffs (Low Level)",
            Index = 3,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using stat buffs at lower levels?",
            Answer =
                "They are not enabled by default as they can in many cases be a waste of mana or time to cast in automation.\n" ..
                "You can select the low level buffs you would like to use on the Buffs (Low Level) tab.",
        },
        ['DoLLStrBuff']       = {
            DisplayName = "Strength Buff (LowLvl)",
            Category = "Buffs (Low Level)",
            Index = 4,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using stat buffs at lower levels?",
            Answer =
                "They are not enabled by default as they can in many cases be a waste of mana or time to cast in automation.\n" ..
                "You can select the low level buffs you would like to use on the Buffs (Low Level) tab.",
        },
    },
}

return _ClassConfig
