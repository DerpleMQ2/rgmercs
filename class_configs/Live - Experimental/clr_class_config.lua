local mq           = require('mq')
local RGMercUtils  = require("utils.rgmercs_utils")

local _ClassConfig = {
    _version              = "1.1 - Experimental",
    _author               = "Algar, Derple",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return true end,
        IsRezing = function() return RGMercUtils.GetSetting('DoBattleRez') or RGMercUtils.GetXTHaterCount() == 0 end,
    },
    ['Modes']             = {
        'Heal',
    },
    ['Cures']             = {
        CureNow = function(self, type, targetId)
            if RGMercUtils.AAReady("Group Purify Soul") then --TODO: Refactor this, I'm short on time.
                return RGMercUtils.UseAA("Group Purify Soul", targetId)
            elseif RGMercUtils.AAReady("Radiant Cure") then
                return RGMercUtils.UseAA("Radiant Cure", targetId)
            elseif RGMercUtils.AAReady("Purify Soul") then
                return RGMercUtils.UseAA("Purify Soul", targetId)
            end

            local cureSpell = RGMercUtils.GetResolvedActionMapItem('GroupHealCure')


            -- local cureSpell = RGMercUtils.GetResolvedActionMapItem('CureDisease')

            -- if type:lower() == "poison" then
            --     cureSpell = RGMercUtils.GetResolvedActionMapItem('CurePoison')
            -- elseif type:lower() == "curse" then
            --     cureSpell = RGMercUtils.GetResolvedActionMapItem('CureCurse')
            -- elseif type:lower() == "corruption" then
            --     cureSpell = RGMercUtils.GetResolvedActionMapItem('CureCorrupt')
            -- end

            if not cureSpell or not cureSpell() then return false end
            return RGMercUtils.UseSpell(cureSpell.RankName.Name(), targetId, true)
        end,
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Harmony of the Soul",
            "Aegis of Superior Divinity",
        },
    },
    ['AbilitySets']       = {
        ['WardBuff'] = {
            -----Ward Spell Slot 1 or Heal over time for low level
            "Celestial Remedy",
            "Celestial Health",
            "Celestial Healing",
            "Celestial Elixir",
            "Supernal Elixir",
            "Holy Elixir",
            "Pious Elixir",
            "Sacred Elixir",
            "Solemn Elixir",
            "Devout Elixir",
            "Earnest Elixir",
            "Zealous Elixir",
            "Ward of Certitude",
            "Ward of Surety",
            "Ward of Assurance",
            "Ward of Righteousness",
            "Ward of Persistence",
            "Ward of Commitment",
        },
        ['RemedyHeal'] = {
            --Remedy Slot 1 & 2 Primary Remedy Slot - Picks best Spell
            "Minor Healing",
            "Light Healing",
            "Healing",
            "Greater Healing",
            "Celestial Health",
            "Superior Healing",
            "Remedy",
            "Ethereal Remedy",
            "Supernal Remedy",
            "Pious Remedy",
            "Sacred Remedy",
            "Solemn Remedy",
            "Devout Remedy",
            "Earnest Remedy",
            "Faithful Remedy",
            "Graceful Remedy",
            "Spiritual Remedy",
            "Merciful Remedy",
            "Sincere Remedy",
            "Guileless Remedy",
            "Avowed Remedy",
        },
        ['RemedyHeal2'] = {
            --Remedy Slot 1 & 2 Primary Remedy Slot - Picks best Spell
            "Superior Healing",
            "Remedy",
            "Ethereal Remedy",
            "Supernal Remedy",
            "Pious Remedy",
            "Sacred Remedy",
            "Solemn Remedy",
            "Devout Remedy",
            "Earnest Remedy",
            "Faithful Remedy",
            "Graceful Remedy",
            "Spiritual Remedy",
            "Merciful Remedy",
            "Sincere Remedy",
            "Guileless Remedy",
            "Avowed Remedy",
        },
        ['DichoHeal'] = {
            "Fraught Renewal",
            "Undying Life",
            "Dissident Blessing",
            "Composite Blessing",
            "Ecliptic Blessing",
        },
        ['GroupFastHeal'] = {
            -----Group Fast Heal 98+ Only
            "Syllable of Acceptance",
            "Syllable of Convalescence",
            "Syllable of Mending",
            "Syllable of Soothing",
            "Syllable of Invigoration",
            "Syllable of Renewal",
        },
        ['GroupHealCure'] = {
            -----Group Heals Slot 5
            "Word of Health",
            "Word of Healing",
            "Word of Vigor",
            "Word of Restoration",
            -- 12 second Cast makes this Spell Unfeasible
            -- [] = "Word of Redemption",
            "Word of Replenishment",
            "Word of Vivification",
            "Word of Vivacity",
            "Word of Recovery",
            "Word of Resurgence",
            "Word of Rehabilitation",
            "Word of Reformation",
            "Word of Greater Reformation",
            "Word of Greater Restoration",
            "Word of Greater Replenishment",
            "Word of Greater Rejuvenation",
            "Word of Greater Vivification",
        },
        ['GroupHealNoCure'] = {
            -----Group Heals No Cure Slot 5
            "Word of Health",
            "Word of Healing",
            "Word of Vigor",
            "Word of Redemption",
            "Word of Awakening",
            "Word of Recuperation",
            "Word of Renewal",
            "Word of Convalescence",
            "Word of Mending",
            "Word of Soothing",
            "Word of Redress",
            "Word of Acceptance",
        },
        ['HealNuke'] = {
            -- Heal Tank and Nuke Tanks Target -- Intervention Lines
            "Holy Intervention",
            "Celestial Intervention",
            "Elysian Intervention",
            "Virtuous Intervention",
            "Mystical Intervention",
            "Merciful Intervention",
            "Sincere Intervention",
            "Atoned Intervention",
            "Avowed Intervention",
        },
        ['NukeHeal'] = {
            -- Nuke Target and Heal Tank -  Dps Heals
            "Holy Contravention",
            "Celestial Contravention",
            "Elysian Contravention",
            "Virtuous Contravention",
            "Ardent Contravention",
            "Merciful Contravention",
            "Sincere Contravention",
            "Divine Contravention",
            "Avowed Contravention",
        },
        ['ReverseDS'] = {
            -- Reverse Damage Shield Proc (LVL >=85) -- Ignoring the Mark Line
            "Erud's Retort",
            "Fintar's Retort",
            "Galvos' Retort",
            "Olsif's Retort",
            "Vicarum's Retort",
            "Curate's Retort",
            "Jorlleag's Retort",
            "Axoeviq's Retort",
        },
        ['SelfHPBuff'] = {
            --Self Buff for Mana Regen and armor
            "Armor of Protection",
            "Blessed Armor of the Risen",
            "Ancient: High Priest's Bulwark",
            "Armor of the Zealot",
            "Armor of the Pious",
            "Armor of the Sacred",
            "Armor of the Solemn",
            "Armor of the Devout",
            "Armor of the Earnest",
            "Armor of the Zealous",
            "Armor of the Reverent",
            "Armor of the Ardent",
            "Armor of the Merciful",
            "Armor of Sincerity",
            "Armor of Penance",
            "Armor of the Avowed",
        },
        ['GroupHealProcBuff'] = {
            ----Self buff casts group heal on AE spell damage
            "Divine Consequence",
            "Divine Reaction",
            "Divine Response",
            "Divine Contingency",
        },
        ['AegoBuff'] = {
            ----Group Buff All Levels starts at 45 - Group Aego Buff
            "Courage",
            "Center",
            "Daring",
            "Bravery",
            "Valor",
            -- [] = "Resolution",
            "Temperance",
            "]Blessing of Temperance",
            -- [] = "Heroic Bond",
            "Blessing of Aegolism",
            "Hand of Virtue",
            "Hand of Conviction",
            "Hand of Tenacity",
            "Hand Of Temerity",
            "Hand of Gallantry",
            "Hand of Reliance",
            "Unified Hand of Credence",
            "Unified Hand of Certitude",
            "Unified Hand of Surety",
            "Unified Hand of Assurance",
            "Unified Hand of Righteousness",
            "Unified Hand of Persistence",
            "Unified Hand of Infallibility",
        },
        ['ShiningBuff'] = {
            --Tank Buff Traditionally Shining Series of Buffs
            "Holy Armor",
            "Spirit Armor",
            "Armor of Faith",
            "Shining Rampart",
            "Shining Armor",
            "Shining Bastion",
            "Shining Bulwark",
            "Shining Fortress",
            "Shining Aegis",
            "Shining Fortitude",
            "Shining Steel",
        },
        ['GroupVieBuff'] = {
            ----Group Vie Buff
            "Rallied Aegis of Vie",
            "Rallied Shield of Vie",
            "Rallied Palladium of Vie",
            "Rallied Rampart of Vie",
            "Rallied Armor of Vie",
            "Rallied Bastion of Vie",
            "Rallied Greater Ward of Vie",
            "Rallied Greater Guard of Vie",
            "Rallied Greater Protection of Vie",
            "Rallied Greater Aegis of Vie",
        },
        ['GroupSymbolBuff'] = {
            ----Group Symbols
            "Symbol of Transal",
            "Symbol of Ryltan",
            "Symbol of Pinzarn",
            "Symbol of Naltron",
            "Symbol of Marzin",
            "Naltron's Mark",
            "Kazad's Mark",
            "Balikor's Mark",
            "Elushar's Mark",
            "Kaerra's Mark",
            "Darianna's Mark",
            "Ealdun's Mark",
            "Unified Hand of the Triumvirate",
            "Unified Hand of Gezat",
            "Unified Hand of Nonia",
            "Unified Hand of Emra",
            "Unified Hand of Jorlleag",
            "Unified Hand of Assurance",
            "Unified Hand of the Diabo",
            "Unified Hand of Helmsbane",
        },
        ['AbsorbAura'] = {
            ----Aura Buffs - Aura Name is seperate than the buff name
            "Aura of the Pious",
            "Aura of the Zealot",
            "Aura of the Reverent",
            "Aura of the Persistent",
        },
        ['HPAura'] = {
            ---- Aura Buff 2 - Aura Name is the same as the buff name
            "Bastion of Divinity",
            "Circle of Divinity",
            "Aura of Divinity",
        },
        ['DivineBuff'] = {
            --Divine Buffs REQUIRES extra spell slot because of the 90s recast
            "Death Pact",
            "Divine Intervention",
            "Divine Intercession",
            "Divine Invocation",
            "Divine Interposition",
            "Divine Indemnification",
            "Divine Imposition",
            "Divine Intermediation",
            "Divine Interference",
        },
        ['TwinHealNuke'] = {
            "Glorious Denunciation",
            "Glorious Censure",
            "Glorious Admonition",
            "Glorious Rebuke",
            "Glorious Judgment",
            "Unyielding Judgment",
            "Unyielding Censure",
            "Unyielding Rebuke",
            "Unyielding Admonition",
        },
        ['RezSpell'] = {
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
        ['AERezSpell'] = {
            "Superior Reviviscence",
            "Eminent Reviviscence",
            "Greater Reviviscence",
            "Larger Reviviscence",
        },
        ['ClutchHeal'] = {
            -- 11th-17th Rejuv Spell Line Clutch Heals Require Life below 35-45% to cast
            "Eleventh-Hour",
            "Twelfth Night",
            "Thirteenth Salve",
            "Fourteenth Catalyst",
            "Fifteenth Emblem",
            "Sixteenth Serenity",
            "Seventeenth Rejuvenation",
            "Eighteenth Rejuvenation",
            "Nineteenth Commandment",
        },
        ['GroupInfusionBuff'] = {
            -- Hand of Infusion Line
            "Hand of Faithful Infusion",
            "Hand of Graceful Infusion",
            "Hand of Merciful Infusion",
            "Hand of Sincere Infusion",
            "Hand of Unyielding Infusion",
            "Hand of Avowed Infusion",
        },
        ['GroupElixir'] = {
            -- Group Hot Line - Elixirs No Cure
            "Elixir of Expiation",
            "Elixir of the Ardent",
            "Elixir of the Beneficent",
            "Elixir of the Acquittal",
            "Elixir of the Seas",
            "Elixir of Wulthan",
            "Elixir of Transcendence",
            "Elixir of Benevolence",
            "Elixir of Realization",
        },
        ['GroupAcquittal'] = {
            -- Group Hot Line Cure + Hot 99+
            "Cleansing Acquittal",
            "Ardent Acquittal",
            "Merciful Acquittal",
            "Sincere Acquittal",
            "Devout Acquittal",
            "Avowed Acquittal",
        },
        ['SpellBlessing'] = {
            -- Spell Speed Blessings 15-92(112)Becomes Defunct due to Unifieds.)
            -- [] = "Benediction of Resplendence",
            "Blessing of Piety",
            "Blessing of Faith",
            "Blessing of Reverence",
            "Aura of Reverence",
            "Blessing of Devotion",
            "Aura of Devotion",
            "Blessing of Purpose",
            "Aura of Purpose",
            "Blessing of Resolve",
            "Aura of Resolve",
            "Blessing of Loyalty",
            "Aura of Loyalty",
            "Blessing of Will",
            "Hand of Will",
            "Blessing of Fervor",
            "Hand of Fervor",
            "Benediction of Piety",
            "Hand of Zeal",
        },
    }, -- end AbilitySets
    ['HelperFunctions']   = {
        -- helper function for advanced logic to see if we want to use Dark Lord's Unity
        DoRez = function(self, corpseId)
            if RGMercUtils.GetSetting('DoBattleRez') or RGMercUtils.DoBuffCheck() then
                RGMercUtils.SetTarget(corpseId, true)

                local target = mq.TLO.Target

                if not target or not target() then return false end

                if mq.TLO.Target.Distance() > 25 then
                    RGMercUtils.DoCmd("/corpse")
                end

                if RGMercUtils.AAReady("Blessing of Resurrection") then
                    return RGMercUtils.UseAA("Blessing of Resurrection", corpseId)
                end

                if mq.TLO.FindItem("Water Sprinkler of Nem Ankh")() and mq.TLO.Me.ItemReady("Water Sprinkler of Nem Ankh")() then
                    RGMercUtils.UseItem("Water Sprinkler of Nem Ankh", corpseId)
                end

                if RGMercUtils.PCSpellReady(self.ResolvedActionMap['RezSpell']) and RGMercUtils.GetXTHaterCount() == 0 and not RGMercUtils.CanUseAA("Blessing of Resurrection") then
                    RGMercUtils.UseSpell(self.ResolvedActionMap['RezSpell'], corpseId, true, true)
                end
            end
        end,
        GetMainAssistPctMana = function()
            local groupMember = mq.TLO.Group.Member(RGMercConfig.Globals.MainAssist)
            if groupMember and groupMember() then
                return groupMember.PctMana() or 0
            end

            local ret = tonumber(DanNet.query(RGMercConfig.Globals.MainAssist, "Me.PctMana", 1000))

            if ret and type(ret) == 'number' then return ret end

            return mq.TLO.Spawn(string.format("PC =%s", RGMercConfig.Globals.MainAssist)).PctMana() or 0
        end,
    },
    -- These are handled differently from normal rotations in that we try to make some intelligent desicions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        -- {
        --     name = 'LowLevelHealPoint',
        --     state = 1,
        --     steps = 1,
        --     cond = function(self, target)
        --         return mq.TLO.Me.Level() < 65 and (target.PctHPs() or 999) <= RGMercUtils.GetSetting('MainHealPoint')
        --     end,
        -- },
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target)
                return (mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() or 0) >= RGMercUtils.GetSetting('GroupInjureCnt')
            end,
        },
        {
            name  = 'BigHealPoint',
            state = 1,
            steps = 1,
            cond  = function(self, target) return (target.PctHPs() or 999) < RGMercUtils.GetSetting('BigHealPoint') end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return (target.PctHPs() or 999) < RGMercUtils.GetSetting('MainHealPoint') end,
        },
    },
    ['HealRotations']     = {
        -- ["LowLevelHealPoint"] = {
        -- },
        ["GroupHealPoint"] = {
            {
                name = "DichoHeal",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.CastReady(spell.RankName) and RGMercUtils.PCSpellReady(spell) and
                        (mq.TLO.Group.Injured(RGMercUtils.GetSetting('BigHealPoint'))() or 0) >= RGMercUtils.GetSetting('GroupInjureCnt')
                end,
            },
            {
                name = "Beacon of Life",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "GroupFastHeal",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.CastReady(spell.RankName) and RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "GroupHealCure",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.CastReady(spell.RankName) and RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "GroupElixir",
                type = "Spell",
                cond = function(self, spell, target)
                    --if not RGMercUtils.GetSetting('DoHealOverTime') then return false end
                    return RGMercUtils.CastReady(spell.RankName) and RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
        },
        ["BigHealPoint"] = {
            {
                name = "ClutchHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.CastReady(spell.RankName) and RGMercUtils.PCSpellReady(spell) and RGMercUtils.GetTargetPctHPs() < 35
                end,
            },
            {
                name = "Sanctuary",
                type = "AA",
                cond = function(self, aaName, target)
                    return (target.ID() or 0) == mq.TLO.Me.ID() and RGMercUtils.PCAAReady(aaName)
                end,
            },
            {
                name = "DichoHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.CastReady(spell.RankName) and RGMercUtils.PCSpellReady(spell) and target.ID() == RGMercUtils.GetMainAssistId
                end,
            },
            {
                name = "Divine Arbitration",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID(), true) and target.ID() == RGMercUtils.GetMainAssistId
                end,
            },
            {
                name = "Burst of Life",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID(), true)
                end,
            },
            {
                name = "Blessing of Sanctuary",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID(), true) and target.ID() == (mq.TLO.Target.AggroHolder.ID() and not RGMercUtils.GetMainAssistId())
                end,
            },
            {
                name = "Veturika's Perseverence",
                type = "AA",
                cond = function(self, aaName, target)
                    return (target.ID() or 0) == mq.TLO.Me.ID() and RGMercUtils.PCAAReady(aaName)
                end,
            },
            { --The stuff above is down, lets make mainhealpoint chonkier. Homework: Wondering if we should be using this more/elsewhere.
                name = "Channeling of the Divine",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.PCAAReady(aaName)
                end,
            },
            -- {
            --     name = "VP2Hammer",
            --     type = "Item",
            --     cond = function(self, itemName)
            --         return mq.TLO.FindItem(itemName).TimerReady() == 0
            --     end,
            -- },
            { --if we hit this we need spells back ASAP
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.PCAAReady(aaName)
                end,
            },
        },
        ["MainHealPoint"] = {
            {
                name = "Focused Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID(), true) and target.ID() == RGMercUtils.GetMainAssistId
                end,
            },
            {
                name = "HealNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.NPCSpellReady(spell, target.ID(), true) and mq.TLO.Me.CombatState():lower() == "combat"
                end,
            },
            {
                name = "RemedyHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.NPCSpellReady(spell, target.ID(), true)
                end,
            },
            {
                name = "RemedyHeal2",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.NPCSpellReady(spell, target.ID(), true)
                end,
            },
            -- {
            --     name = "VP2Hammer",
            --     type = "Item",
            --     cond = function(self, itemName)
            --         return mq.TLO.FindItem(itemName).TimerReady() == 0
            --     end,
            -- },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not RGMercUtils.IsModeActive('Heal') or RGMercUtils.OkayToNotHeal()) and RGMercUtils.DoBuffCheck() and
                    RGMercUtils.AmIBuffable()
            end,
        },
        { --Spells that should be checked on group members
            name = 'GroupBuff',
            timer = 60,
            targetId = function(self)
                local groupIds = { mq.TLO.Me.ID(), }
                local count = mq.TLO.Group.Members()
                for i = 1, count do
                    local rezSearch = string.format("pccorpse %s radius 100 zradius 50", mq.TLO.Group.Member(i).DisplayName())
                    if RGMercUtils.GetSetting('BuffRezables') or mq.TLO.SpawnCount(rezSearch)() == 0 then
                        table.insert(groupIds, mq.TLO.Group.Member(i).ID())
                    end
                end
                return groupIds
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not RGMercUtils.IsModeActive('Heal') or RGMercUtils.OkayToNotHeal()) and RGMercUtils.DoBuffCheck()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.BurnCheck() and not RGMercUtils.Feigning() and
                    (not RGMercUtils.IsModeActive('Heal') or RGMercUtils.OkayToNotHeal())
            end,
        },
        {
            name = 'ManaRestore',
            timer = 30,
            targetId = function(self)
                return { RGMercUtils.FindWorstHurtManaGroupMember(RGMercUtils.GetSetting('ManaRestorePct')),
                    RGMercUtils.FindWorstHurtManaXT(RGMercUtils.GetSetting('ManaRestorePct')), }
            end,
            cond = function(self, combat_state)
                if not RGMercUtils.GetSetting('DoManaRestore') then return false end
                local downtime = combat_state == "Downtime" and RGMercUtils.DoBuffCheck()
                local combat = combat_state == "Combat" and not RGMercUtils.Feigning()
                return (downtime or combat) and (not RGMercUtils.IsModeActive('Heal') or RGMercUtils.OkayToNotHeal())
            end,
        },
        {
            name = 'CombatBuff',
            timer = 10,
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercUtils.GetMainAssistId(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning() and
                    (not RGMercUtils.IsModeActive('Heal') or RGMercUtils.OkayToNotHeal())
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning() and
                    (not RGMercUtils.IsModeActive('Heal') or RGMercUtils.OkayToNotHeal())
            end,
        },
    },
    ['Rotations']         = {
        ['ManaRestore'] = {
            {
                name = "Veturika's Perseverence",
                type = "AA",
                cond = function(self, aaName, target)
                    return (target.ID() or 0) == mq.TLO.Me.ID() and RGMercUtils.PCAAReady(aaName) and RGMercUtils.AmIBuffable()
                end,
            },
            {
                name = "Quiet Prayer",
                type = "AA",
                cond = function(self, aaName, target)
                    if target.ID() == mq.TLO.Me.ID() then return false end
                    local rezSearch = string.format("pccorpse %s radius 100 zradius 50", target.DisplayName())
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and mq.TLO.SpawnCount(rezSearch)() == 0
                end,
            },
        },
        ['CombatBuff'] = {
            {
                name = "ReverseDS",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.CastReady(spell.RankName) and RGMercUtils.NPCSpellReady(spell, target.ID(), true) and RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "WardBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.CastReady(spell.RankName) and RGMercUtils.PCSpellReady(spell) and RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Celestial Hammer",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Flurry of Life",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Healing Frenzy",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Spire of the Vicar",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Divine Avatar",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            { --homework: This is a defensive proc, likely need to add elsewhere
                name = "Divine Retribution",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "Battle Frenzy",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    if not RGMercUtils.GetSetting('DoVetAA') then return false end
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            { --homework: Check if this is necessary (does not exceed 50% spell haste cap)
                name = "Celestial Rapidity",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "TwinHealNuke",
                type = "Spell",
                retries = 0,
                cond = function(self, spell)
                    if not RGMercUtils.GetSetting('DoTwinHeal') then return false end
                    return RGMercUtils.CastReady(spell.RankName) and RGMercUtils.PCSpellReady(spell) and
                        not RGMercUtils.SongActiveByName("Healing Twincast")
                end,
            },
            {
                name = "NukeHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.GetMainAssistPctHPs() < RGMercUtils.GetSetting('LightHealPoint') and (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()) and
                        RGMercUtils.NPCSpellReady(spell, target.ID())
                end,
            },
            {
                name = "Turn Undead",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.TargetBodyIs(target, "Undead") and RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Yaulp",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "GroupElixir",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SpellStacksOnMe(spell) and (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 15
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "Saint's Unity",
                type = "AA",
                active_cond = function(self, aaName)
                    return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName)
                        .Spell.Trigger(1).ID())
                end,
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "GroupHealProcBuff",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "AbsorbAura",
                type = "Spell",
                cond = function(self, spell)
                    return not RGMercUtils.AuraActiveByName(spell.BaseName()) and not RGMercUtils.AuraActiveByName("Reverent Aura") and
                        RGMercUtils.SpellStacksOnMe(spell)
                end,
            },
            {
                name = "HPAura",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.CanUseAA('Spirit Mastery') and not RGMercUtils.AuraActiveByName(spell.BaseName()) and RGMercUtils.SpellStacksOnMe(spell)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Divine Guardian",
                type = "AA",
                cond = function(self, aaName, target)
                    if target.ID() ~= RGMercUtils.GetMainAssistId() then return false end
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "AegoBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if RGMercUtils.GetSetting('AegoSymbol') ~= 1 then return false end
                    return RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupSymbolBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if RGMercUtils.GetSetting('AegoSymbol') ~= 2 then return false end
                    return RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupVieBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "DivineBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if target.ID() ~= RGMercUtils.GetMainAssistId() then return false end
                    return RGMercUtils.GroupBuffCheck(spell, target) and RGMercUtils.ReagentCheck(spell)
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "RemedyHeal", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "RemedyHeal2", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "ClutchHeal", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "DichoHeal", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "GroupHealCure", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "GroupFastHeal", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "GroupElixir", },
            },
        },
        { --We will leave this gem open for buffing until we have 9
            gem = 8,
            cond = function(self) return mq.TLO.Me.NumGems() >= 9 end,
            spells = {
                { name = "HealNuke", },
            },
        },
        { --55, we will leave this gem open for buffing until we have 10
            gem = 9,
            cond = function(self) return mq.TLO.Me.NumGems() >= 10 end,
            spells = {
                { name = "NukeHeal", },
            },
        },
        { --75, we will leave this gem open for buffing until we have 11
            gem = 10,
            cond = function(self) return mq.TLO.Me.NumGems() >= 11 end,
            spells = {
                { name = "TwinHealNuke", },
            },
        },
        { --80, we will leave this gem open for buffing until we have 12
            gem = 11,
            cond = function(self) return mq.TLO.Me.NumGems() >= 12 end,
            spells = {
                { name = "ReverseDS", },
            },
        },
        { --80, we will allow this gem to be filled for the convenience of buffing at the risk of having it overwritten due to a pause, etc.
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "WardBuff", },
            },
        },
        { --105, we will allow this gem to be filled for the convenience of buffing (or an extra nuke) at the risk of having it overwritten due to a pause, etc.
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DivineBuff", },

            },
        },
    },
    ['DefaultConfig']     = {
        ['Mode']           = {
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
                "Hybrid Mode is for when you are the secondary healer in a group and need to do some DPS.",
        },
        ['AegoSymbol']     = {
            DisplayName = "Aego/Symbol Choice:",
            Category = "Buffs",
            Index = 1,
            Tooltip = "WIP",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Aegolism', 'Symbol', 'None', },
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "WIP?",
            Answer = "WIP.",
        },
        ['DoManaRestore']  = {
            DisplayName = "Use Mana Restore AAs",
            Category = "Spells and Abilities",
            Tooltip = "Use Veturika's Prescence (on self) or Quiet Prayer (on others) at critically low mana.",
            Default = true,
            FAQ = "WIP?",
            Answer = "WIP.",
        },
        ['ManaRestorePct'] = {
            DisplayName = "Mana Restore Pct",
            Category = "Spells and Abilities",
            Tooltip = "Min Mana to use restore AA.",
            Default = 10,
            Min = 1,
            Max = 99,
            FAQ = "WIP?",
            Answer = "WIP.",
        },
        ['DoTwinHeal']     = {
            DisplayName = "Twin Heal Nuke",
            Category = "Spells and Abilities",
            Index = 3,
            Tooltip = "Heal Mode: Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I using the Twin Heal Nuke?",
            Answer =
            "Due to the nature of automation, we are likely to have the time to do so, and it helps hedge our bets against spike damage. Drivers that manually target switch may wish to disable this setting to allow for more cross-dotting. ",
        },
        ['DoVetAA']        = {
            DisplayName = "Use Vet AA",
            Category = "Buffs/Debuffs",
            Index = 8,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does SHD use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },
        -- ['DoHOT']           = {
        --     DisplayName = "Cast HOTs",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Heal Over Time Spells",
        --     Default = true,
        --     FAQ = "Why is my cleric not using his Heal over Time Spells?",
        --     Answer = "Make sure you have [DoHOT] enabled in your settings, and ajust your thresholds for when to use them.",
        -- },
        -- ['DoHOT']           = {
        --     DisplayName = "Cast HOTs",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Heal Over Time Spells",
        --     Default = true,
        --     FAQ = "Why is my cleric not using his Heal over Time Spells?",
        --     Answer = "Make sure you have [DoHOT] enabled in your settings, and ajust your thresholds for when to use them.",
        -- },
        -- ['DoCure']          = {
        --     DisplayName = "Cast Cure SPells",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Cure Spells",
        --     Default = true,
        --     FAQ = "Why is my cleric not using his Cure Spells?",
        --     Answer = "Make sure you have [DoCure] enabled in your settings.",
        -- },
        -- ['DoProm']          = {
        --     DisplayName = "Cast Promised Heal Spells",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Prom Spells",
        --     Default = true,
        --     FAQ = "Can I use Promised Heal Spells as well as normal heals?",
        --     Answer = "Yes, you can use Promised Heal Spells as well as normal heals. Enable them with the [DoProm] setting.",
        -- },
        -- ['DoClutchHeal']    = {
        --     DisplayName = "Do Clutch Heal",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = true,
        --     FAQ = "My squishies in the group keep dying - how can I help them?",
        --     Answer = "Enable [DoClutchHeal] in your settings to use clutch heals on low health targets.",
        -- },
        -- ['CompHealPoint']   = {
        --     DisplayName = "Comp Heal Point",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Min PctHPs to use Complete Healing.",
        --     Default = 65,
        --     Min = 1,
        --     Max = 99,
        --     FAQ = "I am using Complete Heal and my tank is still dying - what can I do?",
        --     Answer = "You can adjust the [CompHealPoint] setting to increase the health percentage at which Complete Heal is used.",
        -- },
        -- ['RemedyHealPoint'] = {
        --     DisplayName = "Remedy Heal Point",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Min PctHPs to use Remedy Heals.",
        --     Default = 80,
        --     Min = 1,
        --     Max = 99,
        --     FAQ = "My casters keep dying to fast, which heal do I need to adjust?",
        --     Answer = "You can adjust the [RemedyHealPoint] setting to increase the health percentage at which Remedy Heals are used.",
        -- },
        -- ['DoAutoWard']      = {
        --     DisplayName = "Do Auto Ward",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = true,
        --     FAQ = "I like to use Wards can I set them to auto cast?",
        --     Answer = "Yes, you can enable [DoAutoWard] in your settings to use Wards automatically.",
        -- },
        -- ['ClutchHealPoint'] = {
        --     DisplayName = "Clutch Heal Point",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = 34,
        --     Min = 1,
        --     Max = 99,
        --     FAQ = "My squishies in the group keep dying - how can I help them?",
        --     Answer = "You can adjust the [ClutchHealPoint] setting to increase the health percentage at which clutch heals are used.",
        -- },
        -- ['DoNuke']          = {
        --     DisplayName = "Do Nuke",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = true,
        --     FAQ = "Why is my cleric not using his Nuke Spells?",
        --     Answer = "Make sure you have [DoNuke] enabled in your settings.",
        -- },
        -- ['NukePct']         = {
        --     DisplayName = "Nuke Pct",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = 90,
        --     Min = 1,
        --     Max = 100,
        --     FAQ = "I am running out of mana?",
        --     Answer = "You can adjust the [NukePct] setting to a higher mana requirement before nuke spells are used.",
        -- },
        -- ['DoReverseDS']     = {
        --     DisplayName = "Do ReverseDS",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = true,
        --     FAQ = "Why is my cleric not using his Reverse Damage Shield Spells?",
        --     Answer = "Make sure you have [DoReverseDS] enabled in your settings.",
        -- },
        -- ['DoQp']            = {
        --     DisplayName = "Do Qp",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = true,
        --     FAQ = "Why is my cleric not using his Quickening of the Prophet Spells?",
        --     Answer = "Make sure you have [DoQp] enabled in your settings.",
        -- },
        -- ['QPManaPCT']       = {
        --     DisplayName = "QP Mana PCT",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = 40,
        --     Min = 1,
        --     Max = 99,
        --     FAQ = "I am running out of mana?",
        --     Answer = "You can adjust the [QPManaPCT] setting to a higher mana requirement before Quickening of the Prophet spells are used.",
        -- },
        -- ['VetManaPCT']      = {
        --     DisplayName = "Vet Mana PCT",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = 70,
        --     Min = 1,
        --     Max = 99,
        --     FAQ = "I am running out of mana?",
        --     Answer = "You can adjust the [VetManaPCT] setting to a higher mana requirement before Veteran's Wrath spells are used.",
        -- },
        -- ['DivineBuffOn']    = {
        --     DisplayName = "Divine Buff On",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = false,
        --     FAQ = "Why is my cleric not using his Divine Buff Spells?",
        --     Answer = "Make sure you have [DivineBuffOn] enabled in your settings.",
        -- },
        -- ['DoDruid']         = {
        --     DisplayName = "Do Druid",
        --     Category = "Spells and Abilities",
        --     Tooltip = "Use Spells",
        --     Default = false,
        --     FAQ = "TODO",
        --     Answer = "TODO",
        -- },
        -- ['DoCH']            = {
        --     DisplayName = "Do CH",
        --     Category = "Heals",
        --     Tooltip = "Use Complete Heal Spell",
        --     Default = false,
        --     FAQ = "Why is my cleric not using his Complete Heal Spells?",
        --     Answer = "Make sure you have [DoCH] enabled in your settings.",
        -- },
        -- ['DoSymbol']        = {
        --     DisplayName = "Do Symbol",
        --     Category = "Heals",
        --     Tooltip = "Use Spells",
        --     Default = false,
        --     FAQ = "Why is my cleric not using his Symbol Spells?",
        --     Answer = "Make sure you have [DoSymbol] enabled in your settings. Also make sure you have reagents for the spell.",
        -- },
    },
}

return _ClassConfig
