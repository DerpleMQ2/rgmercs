local mq           = require('mq')
local Combat       = require('utils.combat')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local DanNet       = require('lib.dannet.helpers')
local Logger       = require("utils.logger")

local _ClassConfig = {
    _version              = "2.2 - Project Lazarus",
    _author               = "Algar, Derple, Robban",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return Config:GetSetting('DoCureAA') or Config:GetSetting('DoCureSpells') end,
        IsRezing = function() return Config:GetSetting('DoBattleRez') or Targeting.GetXTHaterCount() == 0 end,
    },
    ['Modes']             = {
        'Heal',
    },
    ['Cures']             = {
        GetCureSpells = function(self)
            --(re)initialize the table for loadout changes
            self.TempSettings.CureSpells = {}

            -- Choose whether we should be trying to resolve the groupheal based on our settings and whether it cures at its level
            local ghealSpell = Core.GetResolvedActionMapItem('GroupHeal')
            local groupHeal = (Config:GetSetting('GroupHealAsCure') and (ghealSpell and ghealSpell.Level() or 0) >= 64) and "GroupHeal"

            -- Find the map for each cure spell we need, given availability of groupheal, groupcure. fallback to curespell
            -- These are convoluted: If Keepmemmed, always use cure, if not, use groupheal if available and fallback to cure
            local neededCures = {
                ['Poison'] = not Config:GetSetting('KeepPoisonMemmed') and (groupHeal or 'CurePoison') or 'CurePoison',
                ['Disease'] = not Config:GetSetting('KeepDiseaseMemmed') and (groupHeal or 'CureDisease') or 'CureDisease',
                ['Curse'] = not Config:GetSetting('KeepCurseMemmed') and (groupHeal or 'CureCurse') or 'CureCurse',
                -- ['Corruption'] = -- Project Lazarus does not currently have any Corruption Cures.
            }

            -- iterate to actually resolve the selected map item, if it is valid, add it to the cure table
            for k, v in pairs(neededCures) do
                local cureSpell = Core.GetResolvedActionMapItem(v)
                if cureSpell then
                    self.TempSettings.CureSpells[k] = cureSpell
                end
            end
        end,
        CureNow = function(self, type, targetId)
            local targetSpawn = mq.TLO.Spawn(targetId)
            if not targetSpawn and targetSpawn() then return false end

            if Config:GetSetting('DoCureAA') then
                local cureAA = Casting.AAReady("Purify Soul") and "Purify Soul"
                if Casting.AAReady("Group Purify Soul") and Targeting.GroupedWithTarget(targetSpawn) then
                    cureAA = "Group Purify Soul"
                elseif Casting.AAReady("Radiant Cure") then
                    cureAA = "Radiant Cure"
                    -- I am finding self-cures to be less than helpful when most effects on a healer are group-wide
                    -- elseif targetId == mq.TLO.Me.ID() and Casting.AAReady("Purified Spirits") then
                    --   cureAA = "Purified Spirits"
                end
                if cureAA then
                    Logger.log_debug("CureNow: Using %s for %s on %s.", cureAA, type:lower() or "unknown", mq.TLO.Spawn(targetId).CleanName() or "Unknown")
                    return Casting.UseAA(cureAA, targetId)
                end
            end

            if Config:GetSetting('DoCureSpells') then
                for effectType, cureSpell in pairs(self.TempSettings.CureSpells) do
                    if type:lower() == effectType:lower() then
                        if cureSpell.TargetType():lower() == "group v1" and not Targeting.GroupedWithTarget(targetSpawn) then
                            Logger.log_debug("CureNow: We cannot use %s on %s, because it is a group-only spell and they are not in our group!", cureSpell.RankName(),
                                targetSpawn.CleanName() or "Unknown")
                            return false
                        end
                        Logger.log_debug("CureNow: Using %s for %s on %s.", cureSpell.RankName(), type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
                        return Casting.UseSpell(cureSpell.RankName(), targetId, true)
                    end
                end
            end

            Logger.log_debug("CureNow: No valid cure at this time for %s on %s.", type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
            return false
        end,
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Harmony of the Soul",
            "Aegis of Superior Divinity",
        },
    },
    ['AbilitySets']       = {
        -- ['WardSelfBuff'] = {
        --     "Ward of Retribution",
        -- },
        ['HealingLight'] = {
            "Minor Healing",
            "Light Healing",
            "Healing",
            "Greater Healing",
            "Superior Healing",
            "Healing Light",
            "Divine Light",
            "Ethereal Light",
            "Supernal Light",
            "Holy Light",
            "Pious Light",
            "Ancient: Hallowed Light",
        },
        ['RemedyHeal'] = { -- Not great until 96/RoF (Graceful)
            "Remedy",
            "Ethereal Remedy",
            "Supernal Remedy",
            "Pious Remedy",
        },
        ['Renewal'] = { -- Level 70 +, large heal, slower cast
            "Desperate Renewal",
        },
        ['GroupHeal'] = {
            -----Group Heals No Cure Slot 5
            "Word of Health",
            "Word of Healing",
            "Word of Vigor",
            "Word of Restoration", -- No good NoCure in these level ranges using w/Cure... Note Word of Redemption omitted (12sec cast)
            "Word of Replenishment",
            "Word of Vivification",
            "Word of Vivacity",
        },
        ['SelfHPBuff'] = {
            --Self Buff for Mana Regen and armor
            "Armor of Protection",
            "Blessed Armor of the Risen",
            "Ancient: High Priest's Bulwark",
            "Armor of the Zealot",
            "Armor of the Pious",
        },
        ['AegoBuff'] = {
            ----Use HP Type one until Temperance at 40... Group Buff at 45 (Blessing of Temperance)
            "Hand of Conviction",
            "Hand of Virtue",
            "Blessing of Aegolism",
            "Blessing of Temperance",
            "Temperance",
            "Valor",
            "Bravery",
            "Daring",
            "Center",
            "Courage",
        },
        ['ACBuff'] = {
            "Ward of Valiance",
            "Ward of Gallantry",
            "Bulwark of Faith",
            "Shield of Words",
            "Armor of Faith",
            "Guard",
            "Spirit Armor",
            "Holy Armor",
        },
        ['SingleVieBuff'] = {
            "Panoply of Vie",
            "Bulwark of Vie",
            "Protection of Vie",
            "Guard of Vie",
            "Ward of Vie",
        },
        ['GroupSymbolBuff'] = {
            ----Group Symbols
            "Symbol of Transal",
            "Symbol of Ryltan",
            "Symbol of Pinzarn",
            "Symbol of Naltron",
            "Symbol of Marzin",
            "Naltron's Mark",
            "Marzin's Mark",
            "Kazad's Mark",
            "Balikor's Mark",
        },
        ['AbsorbAura'] = {
            ----Aura Buffs - Aura Name is seperate than the buff name
            "Aura of the Pious",
            "Aura of the Zealot",
        },
        ['HPAura'] = {
            ---- Aura Buff 2 - Aura Name is the same as the buff name
            "Aura of Divinity",
        },
        ['DivineBuff'] = {
            --Divine Buffs REQUIRES extra spell slot because of the 90s recast
            "Death Pact",
            "Divine Intervention",
        },
        ['TwinHealNuke'] = {
            "Vigilant Condemnation",
        },
        ['RezSpell'] = {
            "Spiritual Awakening",
            "Reviviscence",
            "Resurrection",
            "Restoration",
            "Resuscitate",
            "Renewal",
            "Revive",
            "Reparation",
            "Reconstitution",
            "Reanimation",
        },
        ['SingleElixir'] = {
            "Pious Elixir",
            "Holy Elixir",
            "Supernal Elixir",
            "Celestial Elixir",
            "Celestial Healing",
            "Celestial Health",
            "Celestial Remedy", -- Level 19
        },
        ['GroupElixir'] = {
            "Elixir of Divinity",
            "Ethereal Elixir",
        },
        ['SpellBlessing'] = {
            "Aura of Devotion",
            "Blessing of Devotion",
            "Aura of Reverence",
            "Blessing of Reverence",
            "Blessing of Faith",
            "Blessing of Piety",
        },
        -- ['CureAll'] = { -- The single target cures that come after outclass this
        --     "Pure Blood",
        -- },
        ['CurePoison'] = {
            -- "Puratas", -- Excessive Cast Time
            "Antidote",
            -- "Eradicate Poison", -- not currently available on Laz
            "Abolish Poison",
            "Counteract Poison",
            "Cure Poison",
        },
        ['CureDisease'] = {
            -- "Eradicate Disease", -- not currently available on Laz
            "Counteract Disease",
            "Cure Disease",
        },
        ['CureCurse'] = {
            -- "Eradicate Curse", -- not currently available on Laz
            "Remove Greater Curse",
            "Remove Curse",
            "Remove Lesser Curse",
            "Remove Minor Curse",
        },
        ['YaulpSpell'] = {
            "Yaulp VII",
            "Yaulp VI",
            "Yaulp V",           -- Level 56, first rank with haste/mana regen. We won't use it before this.
        },
        ['StunTimer6'] = {       -- Timer 6 Stun, Fast Cast, Level 63+ (with ToT Heal 88+)
            "Sound of Divinity", -- works up to level 70
            "Sound of Might",
            --Filler before this
            "Tarnation",     -- Timer 4, up to Level 65
            "Force",         -- No Timer #, up to Level 58
            "Holy Might",    -- No Timer #, up to Level 55
        },
        ['LowLevelStun'] = { --Adding a second stun at low levels
            "Stun",
        },
        ['UndeadNuke'] = { -- Level 4+
            "Desolate Undead",
            "Destroy Undead",
            "Exile Undead",
            "Banish Undead",
            "Expel Undead",
            "Dismiss Undead",
            "Expulse Undead",
            "Ward Undead",
        },
        ['MagicNuke'] = {
            "Chromastrike", --Laz specific
            -- "Calamity", -- Chroma is better
            "Reproach",
            "Order",
            "Condemnation",
            "Judgment",
            "Retribution",
            "Wrath",
            "Smite",
            "Furor",
            "Strike",
        },
        -- ['HammerPet'] = {
        --     "Unswerving Hammer of Retribution",
        --     "Unswerving Hammer of Justice",
        --     "Unswerving Hammer of Faith",
        -- },
        ['CompleteHeal'] = {
            "Complete Heal",
        },
        ['PBAENuke'] = { --This isn't worthwhile before these spells come around.
            "Calamity",
            "Catastrophe",
        },
        ['PBAEStun'] = { --This isn't worthwhile before these spells come around. The stun won't land in many cases (level) but the damage is okay.
            "Silent Dictation",
            "The Silent Command",
        },
    }, -- end AbilitySets
    ['HelperFunctions']   = {
        DoRez = function(self, corpseId)
            local rezAction = false
            local rezSpell = self.ResolvedActionMap['RezSpell']
            local okayToRez = Casting.OkayToRez(corpseId)
            local combatState = mq.TLO.Me.CombatState():lower() or "unknown"

            if combatState == "active" or combatState == "resting" then
                if mq.TLO.SpawnCount("pccorpse radius 80 zradius 30")() > 2 and Casting.SpellReady(mq.TLO.Spell("Larger Reviviscence"), true) then
                    rezAction = okayToRez and Casting.UseSpell("Larger Reviviscence", corpseId, true, true)
                end
            end

            if combatState == "combat" and Config:GetSetting('DoBattleRez') and Core.OkayToNotHeal() then
                if Casting.AAReady("Blessing of Resurrection") then
                    rezAction = okayToRez and Casting.UseAA("Blessing of Resurrection", corpseId, true, 1)
                elseif mq.TLO.FindItem("Water Sprinkler of Nem Ankh")() and mq.TLO.Me.ItemReady("Water Sprinkler of Nem Ankh")() then
                    rezAction = okayToRez and Casting.UseItem("Water Sprinkler of Nem Ankh", corpseId)
                end
            else
                if Casting.AAReady("Blessing of Resurrection") then
                    rezAction = okayToRez and Casting.UseAA("Blessing of Resurrection", corpseId, true, 1)
                end
                if not Casting.CanUseAA("Blessing of Resurrection") and Casting.SpellReady(rezSpell, true) then
                    rezAction = okayToRez and Casting.UseSpell(rezSpell, corpseId, true, true)
                end
            end

            return rezAction
        end,
        GetMainAssistPctMana = function()
            local groupMember = mq.TLO.Group.Member(Config.Globals.MainAssist)
            if groupMember and groupMember() then
                return groupMember.PctMana() or 0
            end

            local ret = tonumber(DanNet.query(Config.Globals.MainAssist, "Me.PctMana", 1000))

            if ret and type(ret) == 'number' then return ret end

            return mq.TLO.Spawn(string.format("PC =%s", Config.Globals.MainAssist)).PctMana() or 0
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
    },
    -- These are handled differently from normal rotations in that we try to make some intelligent desicions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        {
            name = 'GroupHeal',
            state = 1,
            steps = 1,
            cond = function(self, target) Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'BigHeal',
            state = 1,
            steps = 1,
            cond = function(self, target)
                return Targeting.BigHealsNeeded(target)
            end,
        },
        {
            name = 'MainHeal',
            state = 1,
            steps = 1,
            cond = function(self, target)
                return Targeting.MainHealsNeeded(target)
            end,
        },
    },
    ['HealRotations']     = {
        ['GroupHeal'] = {
            {
                name = "Beacon of Life",
                type = "AA",
            },
            {
                name = "Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.BigHealsNeeded(target) -- if multiples are hurt with at least one needing big heals
                end,
            },
            {
                name = "GroupElixir",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupElixir') or (target.PctHPs() or 999) <= Config:GetSetting('BigHealPoint') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
                cond = function(self)
                    return Casting.BurnCheck()
                end,
            },
            {
                name = "GroupHeal",
                type = "Spell",
            },
        },
        ['BigHeal'] = {
            {
                name = "Divine Arbitration",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "Sanctuary",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "Burst of Life",
                type = "AA",
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "Weighted Hammer of Conviction",
                type = "Item",
            },
            { --This entry is for RemedyHeal until we learn a Renewal
                name_func = function(self)
                    return Casting.GetFirstMapItem({ "Renewal", "RemedyHeal", })
                end,
                type = "Spell",
            },
            {
                name = "Focused Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "Blessing of Sanctuary",
                type = "AA",
                cond = function(self, aaName, target)
                    return target.ID() == (mq.TLO.Target.AggroHolder.ID() and not Targeting.TargetIsMA(target))
                end,
            },
            { --The stuff above is down, lets make mainhealpoint faster.
                name = "Celestial Rapidity",
                type = "AA",
            },
            { --if we hit this we need spells back ASAP
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ['MainHeal'] = {
            {
                name = "SingleElixir",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSingleElixir') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "CompleteHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting("DoCompleteHeal") or not Targeting.TargetIsMA(target) then return false end
                    return (target.PctHPs() or 999) <= Config:GetSetting('CompleteHealPct')
                end,
            },
            {
                name = "HealingLight",
                type = "Spell",
                cond = function(self, spell, target)
                    return not (Config:GetSetting("DoCompleteHeal") and Targeting.TargetIsMA(target))
                end,
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Spells that should be checked on group members
            name = 'GroupBuff',
            timer = 60,
            targetId = function(self) return Casting.GetBuffableGroupIDs() end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.OkayToBuff()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'ManaRestore',
            timer = 30,
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoManaRestore') and (Casting.CanUseAA("Veturika's Perseverence") or Casting.CanUseAA("Quiet Miracle")) end,
            targetId = function(self)
                return { Combat.FindWorstHurtManaGroupMember(Config:GetSetting('ManaRestorePct')),
                    Combat.FindWorstHurtManaXT(Config:GetSetting('ManaRestorePct')), }
            end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and Casting.OkayToBuff()
                local combat = combat_state == "Combat"
                return (downtime or combat) and Core.OkayToNotHeal()
            end,
        },
        {
            name = 'DPS(AE)',
            state = 1,
            steps = 1,
            load_cond = function(self)
                return (Config:GetSetting('DoPBAENuke') and self:GetResolvedActionMapItem('PBAENuke')) or
                    (Config:GetSetting('DoPBAEStun') and self:GetResolvedActionMapItem('PBAEStun'))
            end,
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
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal()
            end,
        },
    },
    ['Rotations']         = {
        ['ManaRestore'] = {
            {
                name = "Veturika's Perseverence",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target) and Casting.AmIBuffable()
                end,
            },
            {
                name = "Quiet Miracle",
                type = "AA",
                cond = function(self, aaName, target)
                    if Targeting.TargetIsMyself(target) then return false end
                    local rezSearch = string.format("pccorpse %s radius 100 zradius 50", target.DisplayName())
                    return mq.TLO.SpawnCount(rezSearch)() == 0
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Celestial Hammer",
                type = "AA",
            },
            {
                name = "Flurry of Life",
                type = "AA",
            },
            {
                name = "Healing Frenzy",
                type = "AA",
            },
            {
                name = "Spire of the Vicar",
                type = "AA",
            },
            {
                name = "Divine Avatar",
                type = "AA",
                cond = function(self)
                    return Config:GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            { --homework: This is a defensive proc, likely need to add elsewhere
                name = "Divine Retribution",
                type = "AA",
                cond = function(self)
                    return Config:GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "Battle Frenzy",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self)
                    return Config:GetSetting('DoVetAA')
                end,
            },
            { --homework: Check if this is necessary (does not exceed 50% spell haste cap)
                name = "Celestial Rapidity",
                type = "AA",
            },
            {
                name = "Graverobber's Icon",
                type = "Item",
            },
        },
        ['DPS'] = {
            {
                name = "GroupElixir",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell)
                    if not Config:GetSetting('DoGroupElixir') or not Config:GetSetting('GroupElixirUptime') then return false end
                    return spell.RankName.Stacks() and (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 6
                end,
            },
            {
                name = "Yaulp",
                type = "AA",
                allowDead = true,
                cond = function(self, aaName)
                    if not Config:GetSetting('DoYaulp') then return false end
                    return not mq.TLO.Me.Mount() and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "YaulpSpell",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell)
                    if not Config:GetSetting('DoYaulp') or Casting.CanUseAA("Yaulp") then return false end
                    return not mq.TLO.Me.Mount() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "TwinHealNuke",
                type = "Spell",
                cond = function(self, spell)
                    if not Config:GetSetting('DoTwinHeal') then return false end
                    return not mq.TLO.Me.Buff("Twincast")()
                end,
            },
            {
                name = "StunTimer6",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHealStun') then return false end
                    return Casting.HaveManaToNuke(true) and Targeting.TargetNotStunned() and not Targeting.IsNamed(target)
                end,
            },
            {
                name = "LowLevelStun",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLStun') then return false end
                    return Casting.HaveManaToNuke(true) and Targeting.TargetNotStunned() and not Targeting.IsNamed(target)
                end,
            },
            {
                name = "Turn Undead",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetBodyIs(target, "Undead") and Targeting.AggroCheckOkay()
                end,
            },
            {
                name = "UndeadNuke",
                type = "Spell",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoUndeadNuke') or not Targeting.TargetBodyIs(target, "Undead") then return false end
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self)
                    if not Config:GetSetting('DoMagicNuke') then return false end
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Config:GetSetting('DoMelee') and Core.ShieldEquipped()
                end,
            },
        },
        ['DPS(AE)'] = {
            {
                name = "PBAEStun",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke(true) and Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "PBAENuke",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Casting.OkayToNuke() and Targeting.InSpellRange(spell, target)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "SelfHPBuff",
                type = "Spell",
                cond = function(self, spell)
                    if Config:GetSetting('AegoSymbol') == 3 then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Spirit Mastery",
                type = "AA",
                pre_activate = function(self, aaName) --remove the old aura if we just purchased the AA, otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not Casting.AuraActiveByName("Aura of Pious Divinity") then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, aaName)
                    return not Casting.AuraActiveByName("Aura of Pious Divinity")
                end,
            },
            {
                name = "AbsorbAura",
                type = "Spell",
                pre_activate = function(self, spell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not Casting.AuraActiveByName(spell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, spell)
                    if Casting.CanUseAA('Spirit Mastery') then return false end
                    return not Casting.AuraActiveByName(spell.BaseName()) and Config:GetSetting('UseAura') == 1
                end,
            },
            {
                name = "HPAura",
                type = "Spell",
                pre_activate = function(self, spell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not Casting.AuraActiveByName(spell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, spell)
                    if Casting.CanUseAA('Spirit Mastery') then return false end
                    return not Casting.AuraActiveByName(spell.BaseName()) and Config:GetSetting('UseAura') == 2
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Divine Guardian",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.TargetIsMA(target) then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "AegoBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('AegoSymbol') > 2 then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupSymbolBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('AegoSymbol') == (1 or 4) or ((spell.TargetType() or ""):lower() == "single" and target.ID() ~= Core.GetMainAssistId()) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SpellBlessing",
                type = "Spell",
                cond = function(self, spell, target)
                    if mq.TLO.Me.Level() > 91 then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ACBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoACBuff') or ((spell.TargetType() or ""):lower() == "single" and target.ID() ~= Core.GetMainAssistId()) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SingleVieBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoVieBuff') or self:GetResolvedActionMapItem('GroupVieBuff') or not Targeting.TargetIsMA(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "DivineBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDivineBuff') or not Targeting.TargetIsMA(target) then return false end
                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
        },
    },
    -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
    -- The list name ("Default" in the list below) is abitrary, it is simply what shows up in the UI when this spell list is loaded.
    -- Virtually any helper function or TLO can be used as a condition. Example: Mode or level-based lists.
    -- The first list without conditions or whose conditions returns true will be loaded, all subsequent lists will be ignored.
    -- Spells will be loaded in order (if the conditions are met), until all gem slots are full.
    -- Loadout checks (such as scribing a spell or using the "Rescan Loadout" or "Reload Spells" buttons) will re-check these lists and may load a different set if things have changed.
    ['SpellList']         = {
        {
            name = "Default",
            -- cond = function(self) return true end, --Kept here for illustration, this line could be removed in this instance since we aren't using conditions.
            spells = {
                { name = "HealingLight",  cond = function(self) return not Config:GetSetting('DoCompleteHeal') or not Core.GetResolvedActionMapItem("CompleteHeal") end, },
                { name = "CompleteHeal",  cond = function(self) return Config:GetSetting('DoCompleteHeal') end, },
                { name = "Renewal", },
                { name = "RemedyHeal",    cond = function(self) return not Core.GetResolvedActionMapItem("Renewal") end, },
                { name = "GroupHeal", },
                { name = "SingleElixir",  cond = function(self) return Config:GetSetting('DoSingleElixir') end, },
                { name = "GroupElixir",   cond = function(self) return Config:GetSetting('DoGroupElixir') end, },
                { name = "CurePoison",    cond = function(self) return Config:GetSetting('KeepPoisonMemmed') end, },
                { name = "CureDisease",   cond = function(self) return Config:GetSetting('KeepDiseaseMemmed') end, },
                { name = "CureCurse",     cond = function(self) return Config:GetSetting('KeepCurseMemmed') end, },
                { name = "DivineBuff",    cond = function(self) return Config:GetSetting('DoDivineBuff') end, },
                { name = "YaulpSpell",    cond = function(self) return Config:GetSetting('DoYaulp') and not Casting.CanUseAA("Yaulp") end, },
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, },
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, },
                { name = "LowLevelStun",  cond = function(self) return mq.TLO.Me.Level() < 59 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "PBAEStun",      cond = function(self) return Config:GetSetting('DoPBAEStun') end, },
                { name = "PBAENuke",      cond = function(self) return Config:GetSetting('DoPBAENuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "RezSpell",      cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
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
            Max = 1,
            FAQ = "What is the difference between Heal and Hybrid Modes?",
            Answer = "Heal Mode is for when you are the primary healer in a group.\n" ..
                "Hybrid Mode is for when you are the secondary healer in a group and need to do some DPS. (Temp Disabled)",
        },
        --Buffs
        ['AegoSymbol']        = {
            DisplayName = "Aego/Symbol Choice:",
            Category = "Buffs",
            Index = 1,
            Tooltip =
            "Choose whether to use the Aegolism or Symbol Line of HP Buffs.\nPlease note using both is supported for party members who block buffs, but these buffs do not stack once we transition from using a HP Type-One buff in place of Aegolism.",
            Type = "Combo",
            ComboOptions = { 'Aegolism', 'Both (See Tooltip!)', 'Symbol', 'None', },
            Default = 1,
            Min = 1,
            Max = 4,
            FAQ = "Why aren't I using Aego and/or Symbol buffs?",
            Answer = "Please set which buff you would like to use on the Buffs/Debuffs tab.",
        },
        ['DoACBuff']          = {
            DisplayName = "Use AC Buff",
            Category = "Buffs",
            Index = 2,
            Tooltip =
                "Use your single-slot AC Buff on the Main Assist. USE CASES:\n" ..
                "You have Aegolism selected and are below level 40 (We are still using a HP Type One buff).\n" ..
                "You have Symbol selected and you are below level 95 (We don't have Unified Symbols yet).\n" ..
                "Leaving this on in other cases is not likely to cause issue, but may cause unnecessary buff checking.",
            Default = false,
            FAQ = "Why aren't I used my AC Buff Line?",
            Answer =
            "You may need to select the option in Buffs/Debuffs. Alternatively, this line does not stack with Aegolism, and it is automatically included in \"Unified\" Symbol buffs.",
        },
        ['DoVieBuff']         = {
            DisplayName = "Use Vie Buff",
            Category = "Buffs",
            Index = 3,
            Tooltip = "Use your Melee Damage absorb (Vie) line.",
            Default = true,
            FAQ = "Why am I using the Vie and Shining buffs together when the melee gaurd does not stack?",
            Answer = "We will always use the Shining line on the tank, but if selected, we will also use the Vie Buff on the Group.\n" ..
                "Before we have the Shining Buff, we will use our single-target Vie buff only on the tank.",
        },
        ['UseAura']           = {
            DisplayName = "Aura Spell Choice:",
            Category = "Buffs",
            Index = 4,
            Tooltip = "Select the Aura to be used, prior to purchasing the Spirit Mastery AA.",
            Type = "Combo",
            ComboOptions = { 'Absorb', 'HP', 'None', },
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "Why am I not using the aura I prefer?",
            Answer = "You can select which aura to use (prior to purchase of Spirit Mastery) by changing your Aura Spell Choice option.",
        },
        ['DoDivineBuff']      = {
            DisplayName = "Do Divine Buff",
            Category = "Buffs",
            Index = 5,
            Tooltip = "Use your Divine Intervention line (death save) on the MA.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my Cleric using the Divine Intervention buff?",
            Answer = "The Divine Intervention buff line requires a pair of emeralds.",
        },

        --Combat
        ['DoTwinHeal']        = {
            DisplayName = "Twin Heal Nuke",
            Category = "Combat",
            Index = 1,
            Tooltip = "Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I using the Twin Heal Nuke?",
            Answer =
            "You can turn off the Twin Heal Nuke in the Spells and Abilities tab.",
        },
        ['DoHealStun']        = {
            DisplayName = "Timer 6 Stun",
            Category = "Combat",
            Index = 2,
            Tooltip = "Use the Timer 6 Stun (\"Sound of\" Line).",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Which stun spells does the Cleric use?",
            Answer =
                "At low levels, we will use the \"Stun\" spell (until 58, if selected) and either \"Holy Might\", \"Force\", or \"Tarnation\" until level 65.\n" ..
                "After that, we transition to the Timer 6 stuns (\"Sound of\" line), which have a ToT heal from Level 88.\n" ..
                "Please note that the low level spell named \"Stun\" is controlled by the Low Level Stun option.",
        },
        ['DoLLStun']          = {
            DisplayName = "Low Level Stun",
            Category = "Combat",
            Index = 3,
            Tooltip = "Use the Level 2 \"Stun\" spell, as long as it is level-appropriate (works on targets up to Level 58).",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why is a Cleric stunning? It should be healing!?",
            Answer =
            "At low levels, Cleric stuns are often more efficient than healing the damage an non-stunned mob would cause.",
        },
        ['DoUndeadNuke']      = {
            DisplayName = "Do Undead Nuke",
            Category = "Combat",
            Index = 4,
            Tooltip = "Use the Undead nuke line.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How can I use my Undead Nuke?",
            Answer = "You can enable the undead nuke line in the Spells and Abilities tab.",
        },
        ['DoMagicNuke']       = {
            DisplayName = "Do Magic Nuke",
            Category = "Combat",
            Index = 5,
            Tooltip = "Use the Magic nuke line.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How can I use my Magic Nuke?",
            Answer = "You can enable the magic nuke line in the Spells and Abilities tab.",
        },
        -- Heals and Cures
        ['DoCompleteHeal']    = {
            DisplayName = "Use Complete Heal",
            Category = "Heals and Cures",
            Index = 1,
            Tooltip = "Use Complete Heal on the MA (instead of the healing Light line).",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why isn't my cleric using Complete Heal?",
            Answer =
            "Complete Heal use can be enabled in the Spells and Abilities tab. Please note that, if enabled, we will not use the healing Light line on the MA.",
        },
        ['CompleteHealPct']   = {
            DisplayName = "Complete Heal Pct",
            Category = "Heals and Cures",
            Index = 2,
            Tooltip = "Pct we will use Complete Heal on the MA.",
            Default = 80,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
            FAQ = "How can I stagger my clerics to use Complete Heal at different times?",
            Answer = "Adjust the Complete Heal Pct on the Spells and Abilities tab to different amounts to help stagger Complete Heals.",
        },
        ['DoSingleElixir']    = {
            DisplayName = "Single Elixir",
            Category = "Heals and Cures",
            Index = 3,
            Tooltip = "Use your single-target Elixir Line.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my Cleric using the Single Elixir?",
            Answer = "You can adjust this behavior in the class options tab.",
        },
        ['DoGroupElixir']     = {
            DisplayName = "Group Elixir",
            Category = "Heals and Cures",
            Index = 4,
            Tooltip = "Use your group-wide Elixir Line.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why is my cleric running out of mana keeping up the group Elixir HoT?",
            Answer = "You can adjust Elixir Uptime in the Class options..",
        },
        ['GroupElixirUptime'] = {
            DisplayName = "Group Elixir Uptime",
            Category = "Heals and Cures",
            Index = 5,
            Tooltip = "In combat, attempt to keep full uptime on your Group Elixir. Note: There are scenarios where single elixirs could interfere with uptime.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my Cleric keeping the Group Elixir on the tank when I the uptime option selected?",
            Answer = "Clerics will check themselves for the group elixir and recast as necessary. Single elixirs may at time interfere with this.",
        },
        ['KeepPoisonMemmed']  = {
            DisplayName = "Mem Cure Poison",
            Category = "Heals and Cures",
            Index = 6,
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
            Category = "Heals and Cures",
            Index = 7,
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
            Category = "Heals and Cures",
            Index = 8,
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
            Category = "Heals and Cures",
            Index = 9,
            Tooltip = "If Word of Replenishment or Vivification are available, use these to cure instead of individual cure spells. \n" ..
                "Please note that we will prioritize single target cures if you have selected to keep them memmed above (due to the counter disparity).",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I using my Group Heal when I should be curing?",
            Answer =
                "Word of Reconsitatutioon claers poison/disease/curse counters and is used optionally as a cure. You can disable this behavior in your class options on the Utility tab.\n" ..
                "Some earlier group heal spells also clear counters, but the config must be customized to use them.",
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
        ['DoPBAENuke']        = {
            DisplayName = "Use PBAE Nuke",
            Category = "Damage(AE)",
            Index = 2,
            RequiresLoadoutChange = true,
            Tooltip =
            "**WILL BREAK MEZ** Use your Magic PB AE Spells . **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['DoPBAEStun']        = {
            DisplayName = "Use PBAE Stun",
            Category = "Damage(AE)",
            Index = 4,
            RequiresLoadoutChange = true,
            Tooltip =
            "**WILL BREAK MEZ** Use your Magic PB AE Stun Spells . **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
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

        --Utility
        ['DoManaRestore']     = {
            DisplayName = "Use Mana Restore AAs",
            Category = "Utility",
            Index = 1,
            Tooltip = "Use Veturika's Prescence (on self) or Quiet Miracle (on others) at critically low mana.",
            RequiresLoadoutChange = true, -- used as a load condition
            Default = true,
            ConfigType = "Advanced",
            FAQ = "What circumstances do we use Veturika's or Quiet Miracle?",
            Answer =
                "If the Mana Restore AA setting is set on the Spells and Abilities tab, we will use either of these once the Mana Restore Pct threshold is crossed.\n" ..
                "We will also use Veturika's as an emergency self-heal if required.",
        },
        ['ManaRestorePct']    = {
            DisplayName = "Mana Restore Pct",
            Category = "Utility",
            Index = 2,
            Tooltip = "Min Mana to use restore AA.",
            Default = 10,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
            FAQ = "Why am I not using Veturika's or Quiet Miracle?",
            Answer = "Ensure that your Mana Restore Pct is configured to the value you would like to start using these abilities.",
        },
        ['DoYaulp']           = {
            DisplayName = "Use Yaulp",
            Category = "Utility",
            Index = 3,
            Tooltip = "Use your Yaulp (AA or spell line) to help maintain your mana and buff your melee ability.",
            Default = true,
            FAQ = "Why am I using Yaulp? Clerics are not supposed to melee!",
            Answer = "The Yaulp spells we use also contain a mana regen component. You can disable this behavior on the Utility tab in the Class Options.",
        },
        ['DoVetAA']           = {
            DisplayName = "Use Vet AA",
            Category = "Utility",
            Index = 4,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does CLR use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns. Clerics have tools that largely leave Armor of Experience unused.",
        },
    },
}

return _ClassConfig
