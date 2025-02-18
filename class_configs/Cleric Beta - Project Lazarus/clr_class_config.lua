local mq           = require('mq')
local Combat       = require('utils.combat')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.Targeting")
local Casting      = require("utils.casting")
local DanNet       = require('lib.dannet.helpers')

local _ClassConfig = {
    _version              = "1.2 - Beta (Project Lazarus)",
    _author               = "Algar, Derple, Robban",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return true end,
        IsRezing = function() return Config:GetSetting('DoBattleRez') or Targeting.GetXTHaterCount() == 0 end,
    },
    ['Modes']             = {
        'Heal',
    },
    ['Cures']             = {
        CureNow = function(self, type, targetId)
            if Casting.AAReady("Group Purify Soul") then
                return Casting.UseAA("Group Purify Soul", targetId)
            elseif Casting.AAReady("Radiant Cure") then
                return Casting.UseAA("Radiant Cure", targetId)
            elseif targetId == mq.TLO.Me.ID() and Casting.AAReady("Purified Spirits") then
                return Casting.UseAA("Purified Spirits", targetId)
            elseif Casting.AAReady("Purify Soul") then
                return Casting.UseAA("Purify Soul", targetId)
            end

            local cureSpell = Config:GetSetting('KeepCureMemmed') == 3 and Core.GetResolvedActionMapItem('GroupHealCure') or Core.GetResolvedActionMapItem('CureAll')

            if type:lower() == "disease" then
                if not cureSpell then
                    cureSpell = Core.GetResolvedActionMapItem('CureDisease')
                end
            elseif type:lower() == "poison" then
                if not cureSpell then
                    cureSpell = Core.GetResolvedActionMapItem('CurePoison')
                end
            elseif type:lower() == "curse" then
                if not cureSpell or cureSpell.Level() == (51 or 57 or 84) then --First two group cures and first cureall don't cure curse
                    cureSpell = Core.GetResolvedActionMapItem('CureCurse')
                end
            elseif type:lower() == "corruption" then
                cureSpell = Core.GetResolvedActionMapItem('CureCorrupt')
            end

            if not cureSpell or not cureSpell() then return false end
            return Casting.UseSpell(cureSpell.RankName.Name(), targetId, true)
        end,
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Harmony of the Soul",
            "Aegis of Superior Divinity",
        },
        ['VP2Hammer'] = {
            "Apothic Dragon Spine Hammer",
        },
    },
    ['AbilitySets']       = {
        ['WardBuff'] = { -- Level 97+
            "Ward of Certitude",
            "Ward of Surety",
            "Ward of Assurance",
            "Ward of Righteousness",
            "Ward of Persistence",
            "Ward of Commitment",
        },
        ['HealingLight'] = {
            "Minor Healing",
            "Light Healing",
            "Healing",
            "Greater Healing",
            "Celestial Health",
            "Superior Healing",
            "Healing Light",
            "Divine Light",
            "Ethereal Light",
            "Supernal Light",
            "Holy Light",
            "Pious Light",
            "Ancient: Hallowed Light",
            "Sacred Light",
            "Solemn Light",
            "Devout Light",
            "Earnest Light",
            "Zealous Light",
            "Reverent Light",
            "Ardent Light",
            "Merciful Light",
            "Sincere Light",
            "Fervent Light",
            "Avowed Light",
        },
        ['RemedyHeal'] = { -- Not great until 96/RoF (Graceful)
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
            "Graceful Remedy",
            "Spiritual Remedy",
            "Merciful Remedy",
            "Sincere Remedy",
            "Guileless Remedy",
            "Avowed Remedy",
        },
        ['Renewal'] = { -- Level 70 +, large heal, slower cast
            "Desperate Renewal",
            "Frantic Renewal",
            "Frenetic Renewal",
            "Frenzied Renewal",
            "Fervent Renewal",
            "Fraught Renewal",
            "Furial Renewal",
            "Dire Renewal",
            "Determined Renewal",
            "Heroic Renewal",
        },
        ['Renewal2'] = { -- Level 70 +, large heal, slower cast
            "Desperate Renewal",
            "Frantic Renewal",
            "Frenetic Renewal",
            "Frenzied Renewal",
            "Fervent Renewal",
            "Fraught Renewal",
            "Furial Renewal",
            "Dire Renewal",
            "Determined Renewal",
            "Heroic Renewal",
        },
        ['Renewal3'] = { -- Level 70 +, large heal, slower cast
            "Desperate Renewal",
            "Frantic Renewal",
            "Frenetic Renewal",
            "Frenzied Renewal",
            "Fervent Renewal",
            "Fraught Renewal",
            "Furial Renewal",
            "Dire Renewal",
            "Determined Renewal",
            "Heroic Renewal",
        },
        ['DichoHeal'] = {
            "Undying Life",
            "Dissident Blessing",
            "Composite Blessing",
            "Ecliptic Blessing",
            "Reciprocal Blessing",
        },
        ['GroupFastHeal'] = { -- Level 98
            "Syllable of Acceptance",
            "Syllable of Convalescence",
            "Syllable of Mending",
            "Syllable of Soothing",
            "Syllable of Invigoration",
            "Syllable of Renewal",
        },
        ['GroupHealCure'] = {
            "Word of Restoration",   -- Poi/Dis
            "Word of Replenishment", -- Poi/Dis/Curse
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
            "Word of Restoration", -- No good NoCure in these level ranges using w/Cure... Note Word of Redemption omitted (12sec cast)
            "Word of Replenishment",
            "Word of Vivification",
            "Word of Vivacity",
            "Word of Recovery",
            "Word of Awakening", --86, back to no cures
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
        ['HealNuke2'] = {
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
        ['HealNuke3'] = {
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
        ['NukeHeal2'] = {
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
        ['NukeHeal3'] = {
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
            "Hazuri's Retort",
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
            "Divine Rejoinder",
        },
        ['AegoBuff'] = {
            ----Use HP Type one until Temperance at 40... Group Buff at 45 (Blessing of Temperance)
            "Courage",
            "Center",
            "Daring",
            "Bravery",
            "Valor",
            "Temperance",
            "Blessing of Temperance",
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
        ['ACBuff'] = { --Sometimes single, sometimes group, used on tank before Aego or until it is rolled into Unified (Symbol)
            "Ward of the Avowed",
            "Ward of the Guileless",
            "Ward of Sincerity",
            "Ward of the Merciful",
            "Order of the Earnest",
            "Ward of the Earnest",
            "Order of the Devout",
            "Ward of the Devout",
            "Order of the Resolute",
            "Ward of the Resolute",
            "Ward of the Dauntless",
            "Ward of Valliance",
            "Ward of Gallantry",
            "Bulwark of Faith",
            "Shield of Words",
            "Armor of Faith",
            "Guard",
            "Spirit Armor",
            "Holy Armor",
        },
        ['ShiningBuff'] = {
            --Tank Buff Traditionally Shining Series of Buffs
            "Shining Rampart",
            "Shining Armor",
            "Shining Bastion",
            "Shining Bulwark",
            "Shining Fortress",
            "Shining Aegis",
            "Shining Fortitude",
            "Shining Steel",
        },
        ['SingleVieBuff'] = { -- Level 20-73
            "Aegis of Vie",
            "Panoply of Vie",
            "Bulwark of Vie",
            "Protection of Vie",
            "Guard of Vie",
            "Ward of Vie",
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
        ['SingleElixir'] = {
            "Celestial Remedy", -- Level 19
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
        },
        ['GroupElixir'] = {
            -- Group Hot Line - Elixirs No Cure
            "Ethereal Elixir", -- Level 59
            "Elixir of Divinity",
            "Elixir of Redemption",
            "Elixir of Atonement",
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
        ['CureAll'] = {
            "Sanctified Blood",
            "Expurgated Blood",
            "Unblemished Blood",
            "Cleansed Blood",
            "Perfected Blood",
            "Purged Blood",   -- does not cure corruption
            "Purified Blood", -- does not cure curse, 5 level gap where we will use this without curing curse, but AA should cover
            -- "Pure Blood", --Much better single cures occur after this one
        },
        ['CureCorrupt'] = {
            "Dissolve Corruption",
            "Abolish Corruption",
            "Vitiate Corruption",
            "Expunge Corruption",
        },
        ['CurePoison'] = {
            "Antidote",
            "Eradicate Poison",
            "Abolish Poison",
            "Counteract Poison",
            "Cure Poison",
        },
        ['CureDisease'] = {
            "Eradicate Disease",
            "Counteract Disease",
            "Cure Disease",
        },
        ['CureCurse'] = {
            "Eradicate Curse",
            "Remove Greater Curse",
            "Remove Curse",
            "Remove Lesser Curse",
            "Remove Minor Curse",
        },
        ['YaulpSpell'] = {
            "Yaulp V", -- Level 56, first rank with haste/mana regen
            "Yaulp VI",
            "Yaulp VII",
            "Yaulp VIII",
            "Yaulp IX",    -- Level 76, AA starts at 75 with Yaulp IX
        },
        ['StunTimer6'] = { -- Timer 6 Stun, Fast Cast, Level 63+ (with ToT Heal 88+)
            "Sound of Heroism",
            "Sound of Providence",
            "Sound of Rebuke",
            "Sound of Wrath",
            "Sound of Thunder",
            "Sound of Plangency",
            "Sound of Fervor",
            "Sound of Fury",
            "Sound of Reverberance",
            "Sound of Resonance",
            "Sound of Zeal",
            "Sound of Divinity",
            "Sound of Might",
            --Filler before this
            "Tarnation",     -- Timer 4, up to Level 65
            "Force",         -- No Timer, up to Level 58
            "Holy Might",    -- No Timer, up to Level 55
        },
        ['LowLevelStun'] = { --Adding a second stun at low levels
            "Stun",
        },
        ['UndeadNuke'] = { -- Level 4+
            "Banish the Undead",
            "Extirpate the Undead",
            "Obliterate the Undead",
            "Repudiate the Undead",
            "Eradicate the Undead",
            "Abrogate the Undead",
            "Abolish the Undead",
            "Annihilate the Undead",
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
            -- Basic Nuke
            "Strike",
            "Furor",
            "Smite",
            "Wrath",
            "Retribution",
            "Judgment",
            "Condemnation",
            "Order",
            "Reproach",
            "Reproval",
            "Reprehend",
            "Rebuke",
            "Remonstrance",
            "Castigation",
            "Justice",
            "Sanction",
            "Injunction",
            "Divine Writ",
            "Decree",
        },
        ['HammerPet'] = {
            "Unswerving Hammer of Faith",
            "Unswerving Hammer of Retribution",
            "Unswerving Hammer of Justice",
            "Unflinching Hammer of Zeal",
            "Indomitable Hammer of Zeal",
            "Unwavering Hammer of Zeal",
            "Devout Hammer of Zeal",
            "Infallible Hammer of Zeal",
            "Infallible Hammer of Reverence",
            "Ardent Hammer of Zeal",
            "Unyielding Hammer of Zeal",
            "Unyielding Hammer of Obliteration",
            "Incorruptible Hammer of Obliteration",
            "Unrelenting Hammer of Zeal",
        },
    }, -- end AbilitySets
    ['HelperFunctions']   = {
        DoRez = function(self, corpseId)
            local rezAction = false
            local rezSpell = self.ResolvedActionMap['RezSpell']

            if mq.TLO.Me.CombatState():lower() == "combat" and Config:GetSetting('DoBattleRez') then
                if Casting.AAReady("Blessing of Resurrection") then
                    rezAction = Casting.UseAA("Blessing of Resurrection", corpseId, true, 1)
                elseif mq.TLO.FindItem("Water Sprinkler of Nem Ankh")() and mq.TLO.Me.ItemReady("Water Sprinkler of Nem Ankh")() then
                    rezAction = Casting.UseItem("Water Sprinkler of Nem Ankh", corpseId)
                end
            end

            if mq.TLO.Me.CombatState():lower() == "active" or mq.TLO.Me.CombatState():lower() == "resting" then
                if mq.TLO.SpawnCount("pccorpse radius 80 zradius 30")() > 2 and Casting.SpellReady(mq.TLO.Spell("Larger Reviviscence")) then
                    rezAction = Casting.UseSpell("Larger Reviviscence", corpseId, true, true)
                elseif Casting.AAReady("Blessing of Resurrection") then
                    rezAction = Casting.UseAA("Blessing of Resurrection", corpseId, true, 1)
                elseif not Casting.CanUseAA("Blessing of Resurrection") and Casting.SpellReady(rezSpell) then
                    rezAction = Casting.UseSpell(rezSpell, corpseId, true, true)
                end
            end

            if rezAction and mq.TLO.Spawn(corpseId).Distance3D() > 25 then
                Targeting.SetTarget(corpseId)
                Core.DoCmd("/corpse")
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
    },
    -- These are handled differently from normal rotations in that we try to make some intelligent desicions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        { -- Level 98+
            name = 'GroupHeal(98+)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 97 end,
            cond = function(self, target)
                if not Targeting.GroupedWithTarget(target) then return false end
                return (mq.TLO.Group.Injured(Config:GetSetting('GroupHealPoint'))() or 0) >= Config:GetSetting('GroupInjureCnt')
            end,
        },
        { -- Level 70+
            name = 'BigHeal(70+)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 69 end,
            cond = function(self, target)
                return (target.PctHPs() or 999) < Config:GetSetting('BigHealPoint')
            end,
        },
        { -- Level 101+
            name = 'MainHeal(101+)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 100 end,
            cond = function(self, target)
                return (target.PctHPs() or 999) < Config:GetSetting('MainHealPoint')
            end,
        },
        { -- Level 1-97
            name = 'GroupHeal(1-97)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 98 end,
            cond = function(self, target)
                if not Targeting.GroupedWithTarget(target) then return false end
                return (mq.TLO.Group.Injured(Config:GetSetting('GroupHealPoint'))() or 0) >= Config:GetSetting('GroupInjureCnt')
            end,
        },
        { -- Level 70-100
            name = 'MainHeal(70-100)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 69 and mq.TLO.Me.Level() < 101 end,
            cond = function(self, target)
                return (target.PctHPs() or 999) <= Config:GetSetting('MainHealPoint')
            end,
        },
        { -- Level 1-69, includes BigHeal
            name = 'Heal(1-69)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 70 end,
            cond = function(self, target)
                return (target.PctHPs() or 999) <= Config:GetSetting('MainHealPoint')
            end,
        },
    },
    ['HealRotations']     = {
        ["GroupHeal(98+)"] = {
            {
                name = "DichoHeal",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.CastReady(spell.RankName) and Casting.SpellReady(spell) and
                        (mq.TLO.Group.Injured(Config:GetSetting('BigHealPoint'))() or 0) >= Config:GetSetting('GroupInjureCnt')
                end,
            },
            {
                name = "Beacon of Life",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "GroupFastHeal",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.CastReady(spell.RankName) and Casting.SpellReady(spell)
                end,
            },
            {
                name = "Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "GroupHealCure",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.CastReady(spell.RankName) and Casting.SpellReady(spell)
                end,
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "GroupElixir",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHealOverTime') then return false end
                    return Casting.CastReady(spell.RankName) and Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ["BigHeal(70+)"] = {
            {
                name = "ClutchHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell.RankName) and Casting.SpellReady(spell) and Targeting.GetTargetPctHPs() < 35
                end,
            },
            {
                name = "Sanctuary",
                type = "AA",
                cond = function(self, aaName, target)
                    return (target.ID() or 0) == mq.TLO.Me.ID() and Casting.AAReady(aaName)
                end,
            },
            {
                name = "DichoHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell.RankName) and Casting.SpellReady(spell) and target.ID() == Core.GetMainAssistId
                end,
            },
            {
                name = "Divine Arbitration",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Casting.TargetedAAReady(aaName, target.ID(), true) and target.ID() == Core.GetMainAssistId
                end,
            },
            {
                name = "Burst of Life",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID(), true)
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName, target)
                    return mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0 and target.ID() == Core.GetMainAssistId
                end,
            },
            {
                name = "Blessing of Sanctuary",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID(), true) and target.ID() == (mq.TLO.Target.AggroHolder.ID() and not Core.GetMainAssistId())
                end,
            },
            {
                name = "Veturika's Perseverence",
                type = "AA",
                cond = function(self, aaName, target)
                    return (target.ID() or 0) == mq.TLO.Me.ID() and Casting.AAReady(aaName)
                end,
            },
            { --The stuff above is down, lets make mainhealpoint chonkier. Homework: Wondering if we should be using this more/elsewhere.
                name = "Channeling of the Divine",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "VP2Hammer",
                type = "Item",
                cond = function(self, itemName)
                    return mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
            { --if we hit this we need spells back ASAP
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
        },
        ["MainHeal(101+)"] = {
            {
                name = "Focused Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID(), true) and target.ID() == Core.GetMainAssistId
                end,
            },
            {
                name = "HealNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID(), true) and mq.TLO.Me.CombatState():lower() == "combat"
                end,
            },
            {
                name = "RemedyHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID(), true)
                end,
            },
            {
                name = "RemedyHeal2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID(), true)
                end,
            },
            {
                name = "VP2Hammer",
                type = "Item",
                cond = function(self, itemName)
                    return mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
        },
        ["GroupHeal(1-97)"] = { --Level 1-97
            {
                name = "GroupHealNoCure",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.CastReady(spell.RankName) and Casting.SpellReady(spell)
                end,
            },
            {
                name = "GroupElixir",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHealOverTime') then return false end
                    return Casting.CastReady(spell.RankName) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
        },
        ["MainHeal(70-100)"] = { --Level 70-100
            {
                name = "Focused Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID(), true) and target.ID() == Core.GetMainAssistId
                end,
            },
            {
                name = "HealNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell) and Casting.TargetedSpellReady(spell, target.ID(), true) and mq.TLO.Me.CombatState():lower() == "combat"
                end,
            },
            {
                name = "HealNuke2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell) and Casting.TargetedSpellReady(spell, target.ID(), true) and mq.TLO.Me.CombatState():lower() == "combat"
                end,
            },
            {
                name = "RemedyHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell) and Casting.TargetedSpellReady(spell, target.ID(), true)
                end,
            },
            {
                name = "Renewal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell) and Casting.TargetedSpellReady(spell, target.ID(), true)
                end,
            },
            {
                name = "Renewal2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell) and Casting.TargetedSpellReady(spell, target.ID(), true)
                end,
            },
            {
                name = "Renewal3",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell) and Casting.TargetedSpellReady(spell, target.ID(), true)
                end,
            },
            {
                name = "SingleElixir",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHealOverTime') then return false end
                    return Casting.CastReady(spell.RankName) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HealingLight",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell) and Casting.TargetedSpellReady(spell, target.ID(), true)
                end,
            },
        },
        ["Heal(1-69)"] = { --Level 1-69, includes Main and Big Healing
            {
                name = "Divine Arbitration",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Casting.TargetedAAReady(aaName, target.ID(), true) and target.ID() == Core.GetMainAssistId and
                        (target.PctHPs() or 999) <= Config:GetSetting('BigHealPoint')
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName, target)
                    if mq.TLO.FindItemCount(itemName)() == 0 or not Targeting.GroupedWithTarget(target) then return false end
                    return mq.TLO.FindItem(itemName).TimerReady() == 0 and target.ID() == Core.GetMainAssistId and
                        (target.PctHPs() or 999) <= Config:GetSetting('BigHealPoint')
                end,
            },
            {
                name = "RemedyHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell) and Casting.TargetedSpellReady(spell, target.ID(), true) and (target.PctHPs() or 999) <= Config:GetSetting('BigHealPoint')
                end,
            },
            {
                name = "SingleElixir",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHealOverTime') then return false end
                    return Casting.CastReady(spell.RankName) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HealingLight",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell) and Casting.TargetedSpellReady(spell, target.ID(), true)
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
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.DoBuffCheck() and Casting.AmIBuffable()
            end,
        },
        { --Spells that should be checked on group members
            name = 'GroupBuff',
            timer = 60,
            targetId = function(self) return Casting.GetBuffableGroupIDs() end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.DoBuffCheck()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and not Casting.IAmFeigning() and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'ManaRestore',
            timer = 30,
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoManaRestore') and (Casting.CanUseAA("Veturika's Perseverence") or Casting.CanUseAA("Quiet Prayer")) end,
            targetId = function(self)
                return { Combat.FindWorstHurtManaGroupMember(Config:GetSetting('ManaRestorePct')),
                    Combat.FindWorstHurtManaXT(Config:GetSetting('ManaRestorePct')), }
            end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and Casting.DoBuffCheck()
                local combat = combat_state == "Combat" and not Casting.IAmFeigning()
                return (downtime or combat) and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'CombatBuff',
            timer = 10,
            state = 1,
            steps = 1,
            load_cond = function(self) return self:GetResolvedActionMapItem('ReverseDS') or self:GetResolvedActionMapItem('WardBuff') end,
            targetId = function(self) return { Core.GetMainAssistId(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
    },
    ['Rotations']         = {
        ['ManaRestore'] = {
            {
                name = "Veturika's Perseverence",
                type = "AA",
                cond = function(self, aaName, target)
                    return (target.ID() or 0) == mq.TLO.Me.ID() and Casting.AAReady(aaName) and Casting.AmIBuffable()
                end,
            },
            {
                name = "Quiet Prayer",
                type = "AA",
                cond = function(self, aaName, target)
                    if target.ID() == mq.TLO.Me.ID() then return false end
                    local rezSearch = string.format("pccorpse %s radius 100 zradius 50", target.DisplayName())
                    return Casting.TargetedAAReady(aaName, target.ID()) and mq.TLO.SpawnCount(rezSearch)() == 0
                end,
            },
        },
        ['CombatBuff'] = {
            {
                name = "ReverseDS",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.CastReady(spell.RankName) and Casting.TargetedSpellReady(spell, target.ID(), true) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "WardBuff",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Casting.CastReady(spell.RankName) and Casting.SpellReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Celestial Hammer",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Flurry of Life",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Healing Frenzy",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Spire of the Vicar",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Divine Avatar",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and Config:GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            { --homework: This is a defensive proc, likely need to add elsewhere
                name = "Divine Retribution",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and Config:GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "Battle Frenzy",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoVetAA') then return false end
                    return Casting.AAReady(aaName)
                end,
            },
            { --homework: Check if this is necessary (does not exceed 50% spell haste cap)
                name = "Celestial Rapidity",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "TwinHealNuke",
                type = "Spell",
                retries = 0,
                cond = function(self, spell)
                    if not Config:GetSetting('DoTwinHeal') then return false end
                    return Casting.CastReady(spell.RankName) and Casting.SpellReady(spell) and
                        not Casting.SongActiveByName("Healing Twincast")
                end,
            },
            {
                name = "StunTimer6",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHealStun') then return false end
                    return Casting.CastReady(spell.RankName) and Casting.DetSpellCheck(spell) and (Casting.HaveManaToNuke() or Casting.BurnCheck()) and
                        Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "NukeHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    if Core.GetMainAssistPctHPs() > Config:GetSetting('LightHealPoint') then return false end
                    return Casting.CastReady(spell.RankName) and (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "NukeHeal2",
                type = "Spell",
                cond = function(self, spell, target)
                    if Core.GetMainAssistPctHPs() > Config:GetSetting('LightHealPoint') then return false end
                    return Casting.CastReady(spell.RankName) and (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "NukeHeal3",
                type = "Spell",
                cond = function(self, spell, target)
                    if Core.GetMainAssistPctHPs() > Config:GetSetting('LightHealPoint') then return false end
                    return Casting.CastReady(spell.RankName) and (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "Yaulp",
                type = "AA",
                allowDead = true,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "YaulpSpell",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell)
                    if Casting.CanUseAA("Yaulp") then return false end
                    return Casting.CastReady(spell) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "GroupElixir",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell)
                    if (mq.TLO.Me.Level() < 101 and not Casting.DetGOMCheck()) then return false end
                    return Casting.CastReady(spell.RankName) and Casting.SpellStacksOnMe(spell.RankName) and (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 15
                end,
            },
            {
                name = "LowLevelStun",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLStun') then return false end
                    return Casting.CastReady(spell.RankName) and Casting.DetSpellCheck(spell) and Casting.HaveManaToDebuff() and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "Turn Undead",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.TargetBodyIs(target, "Undead") then return false end
                    return Casting.TargetedAAReady(aaName, target.ID()) and Casting.DetSpellCheck(mq.TLO.Me.AltAbility(aaName).Spell)
                end,
            },
            {
                name = "UndeadNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoUndeadNuke') or not Targeting.TargetBodyIs(target, "Undead") then return false end
                    return Casting.CastReady(spell.RankName) and (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoMagicNuke') then return false end
                    return Casting.CastReady(spell.RankName) and (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
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
                name = "GroupHealProcBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Spirit Mastery",
                type = "AA",
                pre_activate = function(self, spell) --remove the old aura if we just purchased the AA, otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if mq.TLO.Me.Aura(1)() then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, aaName)
                    return not Casting.AuraActiveByName("Aura of Pious Divinity") and Casting.AAReady(aaName)
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
                    if target.ID() ~= Core.GetMainAssistId() then return false end
                    return Casting.AAReady(aaName) and Casting.GroupBuffCheck(mq.TLO.Me.AltAbility(aaName).Spell, target)
                end,
            },
            {
                name = "AegoBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('AegoSymbol') > 2 then return false end
                    ---@diagnostic disable-next-line: undefined-field
                    return Casting.GroupBuffCheck(spell, target, mq.TLO.Me.Spell(spell).ID())
                end,
            },
            {
                name = "GroupSymbolBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('AegoSymbol') == (1 or 4) then return false end
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
                    if not Config:GetSetting('DoACBuff') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupVieBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoVieBuff') or (target.ID() == Core.GetMainAssistId() and self:GetResolvedActionMapItem('ShiningBuff')) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ShiningBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if target.ID() ~= Core.GetMainAssistId() then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SingleVieBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoVieBuff') or self:GetResolvedActionMapItem('GroupVieBuff') or target.ID() ~= Core.GetMainAssistId() then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "DivineBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDivineBuff') or target.ID() ~= Core.GetMainAssistId() then return false end
                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "RemedyHeal",   cond = function(self) return mq.TLO.Me.Level() >= 96 end, }, -- Level 96+
                { name = "Renewal", },                                                                -- Level 70-95
                { name = "HealingLight", },                                                           -- Main Heal, Level 1-69
            },
        },
        {
            gem = 2,
            spells = {
                { name = "RemedyHeal2", },                                                           -- Level 101+
                { name = "Renewal", },                                                               -- Level 96-100 (When we only have one Remedy)
                { name = "Renewal2", },                                                              -- Level 75+
                { name = "HealingLight", },                                                          -- Fallback, Level 70-74
                { name = "RemedyHeal", },                                                            -- Emergency/fallback, 59-69, these aren't good until 96
                { name = "LowLevelStun", cond = function(self) return mq.TLO.Me.Level() < 59 end, }, -- Level 2-58
            },
        },
        {
            gem = 3,
            spells = {
                { name = "HealNuke2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, }, -- Level 88+
                { name = "NukeHeal", },                                                                                    -- Level 85+
                { name = "Renewal3", },                                                                                    -- Level 80-85/87
                { name = "SingleElixir",  cond = function(self) return Config:GetSetting('DoHealOverTime') end, },         -- Level 19-79
                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, },             -- 84+
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "RezSpell",      cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "NukeHeal2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, }, -- Level 90+
                { name = "HealNuke", },                                                                                    -- Level 83+
                { name = "HealingLight", },                                                                                -- Fallback, Level 75-82
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },              -- Level 20-74
                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, },             -- 84+
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "RezSpell",      cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "ClutchHeal", },                                                                      -- Level 77+
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, }, -- Level 16 - 76 (moved gems after)
                --fallback
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "RezSpell",      cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "GroupFastHeal", },   -- Syllable, 98+
                { name = "GroupHealNoCure", }, -- Level 30-97
                --fallback
                { name = "CureAll",         cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure",   cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",       cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",      cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",    cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff",   cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "RezSpell",        cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "DivineBuff",    cond = function(self) return Config:GetSetting('DoDivineBuff') end, }, -- Level 51+
                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, },   -- 84+
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, },   -- 88+ has ToT heal
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "HealNuke3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "NukeHeal3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "NukeHeal", },
                { name = "HealNuke", },
                { name = "HealNuke2", },
                { name = "NukeHeal2", },
                { name = "RezSpell",      cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "YaulpSpell",    cond = function(self) return not Casting.CanUseAA("Yaulp") end, }, -- Level 56-75

                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, }, -- 84+
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, }, -- 88+ has ToT heal
                { name = "WardBuff", },                                                                        -- Level 97
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "HealNuke3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "NukeHeal3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "NukeHeal", },
                { name = "HealNuke", },
                { name = "HealNuke2", },
                { name = "NukeHeal2", },
                { name = "RezSpell",      cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
        },
        { --55, we will use this and allow GroupElixir to be poofed by buffing if it happens from 60-74.
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- Leve 56-59 free
                { name = "GroupElixir",   cond = function(self) return Config:GetSetting('DoHealOverTime') end, }, -- Level 60+, gets better from 70 on, this may be overwritten before 75
                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, },     -- 84+
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, },     -- 88+ has ToT heal
                { name = "WardBuff", },                                                                            -- Level 97
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "HealNuke3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "NukeHeal3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "NukeHeal", },
                { name = "HealNuke", },
                { name = "HealNuke2", },
                { name = "NukeHeal2", },
                { name = "RezSpell",      cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
        },
        { --75
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ReverseDS", },                                                                       -- Level 85+
                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, }, -- 84+
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, }, -- 88+ has ToT heal
                { name = "WardBuff", },                                                                        -- Level 97
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "HealNuke3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "NukeHeal3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "NukeHeal", },
                { name = "HealNuke", },
                { name = "HealNuke2", },
                { name = "NukeHeal2", },
                { name = "RezSpell",      cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
        },
        { --80
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, }, -- 84+
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, }, -- 88+ has ToT heal
                { name = "WardBuff", },                                                                        -- Level 97
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "HealNuke3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "NukeHeal3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff", cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "NukeHeal", },
                { name = "HealNuke", },
                { name = "HealNuke2", },
                { name = "NukeHeal2", },
                { name = "RezSpell",      cond = function(self) return not Casting.CanUseAA('Blessing of Resurrection') end, },
            },
        },
        { --80, we will allow this gem to be filled for the convenience of buffing at the risk of having it overwritten due to a pause, etc.
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DichoHeal", },                                                                       -- Level 101+ --may be overwritten from 101-104
                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, }, -- 84+
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, }, -- 88+ has ToT heal
                { name = "WardBuff", },                                                                        -- Level 97
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "HealNuke3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "NukeHeal3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "NukeHeal", },
                { name = "HealNuke", },
                { name = "HealNuke2", },
                { name = "NukeHeal2", },
            },
        },
        { --105, we will allow this gem to be filled for the convenience of buffing (or an extra nuke) at the risk of having it overwritten due to a pause, etc.
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, }, -- 84+
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, }, -- 88+ has ToT heal
                { name = "WardBuff", },                                                                        -- Level 97
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "HealNuke3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "NukeHeal3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "NukeHeal", },
                { name = "HealNuke", },
                { name = "HealNuke2", },
                { name = "NukeHeal2", },
            },
        },
        { --125, we will allow this gem to be filled for the convenience of buffing (or an extra nuke) at the risk of having it overwritten due to a pause, etc.
            gem = 14,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                --fallback
                { name = "TwinHealNuke",  cond = function(self) return Config:GetSetting('DoTwinHeal') end, }, -- 84+
                { name = "StunTimer6",    cond = function(self) return Config:GetSetting('DoHealStun') end, }, -- 88+ has ToT heal
                { name = "WardBuff", },                                                                        -- Level 97
                { name = "CureAll",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "GroupHealCure", cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "MagicNuke",     cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",    cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "HealNuke3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal2",     cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "NukeHeal3",     cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "ShiningBuff", },
                { name = "GroupVieBuff",  cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "NukeHeal", },
                { name = "HealNuke", },
                { name = "HealNuke2", },
                { name = "NukeHeal2", },
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
        --Buffs/Debuffs
        ['AegoSymbol']        = {
            DisplayName = "Aego/Symbol Choice:",
            Category = "Buffs/Debuffs",
            Index = 1,
            Tooltip =
            "Choose whether to use the Aegolism or Symbol Line of HP Buffs.\nPlease note using both is supported for party members who block buffs, but these buffs do not stack.",
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
            Category = "Buffs/Debuffs",
            Index = 2,
            Tooltip =
                "Use your single-slot AC Buff. USE CASES:\n" ..
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
            Category = "Buffs/Debuffs",
            Index = 3,
            Tooltip = "Use your Melee Damage absorb (Vie) line.",
            Default = true,
            FAQ = "Why am I using the Vie and Shining buffs together when the melee gaurd does not stack?",
            Answer = "We will always use the Shining line on the tank, but if selected, we will also use the Vie Buff on the Group.\n" ..
                "Before we have the Shining Buff, we will use our single-target Vie buff only on the tank.",
        },
        ['UseAura']           = {
            DisplayName = "Aura Spell Choice:",
            Category = "Buffs/Debuffs",
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
        ['DoVetAA']           = {
            DisplayName = "Use Vet AA",
            Category = "Buffs/Debuffs",
            Index = 5,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does CLR use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns. Clerics have tools that largely leave Armor of Experience unused.",
        },
        --Combat
        ['InterContraChoice'] = {
            DisplayName = "Inter/Contra:",
            Category = "Combat",
            Index = 1,
            Tooltip = "Select your preference between the Intervention and Contravention lines.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Prefer Intervention', 'Balanced (usually one of each)', 'Prefer Contravention', },
            Default = 2,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why am I not using the \"correct\" number of Intervention or Contravention spells?",
            Answer = "Please set your spell preference on the Spells and Abilities tab.\n" ..
                "Note that there are certain level ranges where additional spells may be loaded to fill available gems.",
        },
        ['DoTwinHeal']        = {
            DisplayName = "Twin Heal Nuke",
            Category = "Combat",
            Index = 2,
            Tooltip = "Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I using the Twin Heal Nuke?",
            Answer =
            "You can turn off the Twin Heal Nuke in the Spells and Abilities tab.",
        },
        ['DoHealStun']        = {
            DisplayName = "ToT-Heal Stun",
            Category = "Combat",
            Index = 3,
            Tooltip = "Use the Timer 6 HoT Stun (\"Sound of\" Line).",
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
            Index = 4,
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
            Index = 5,
            Tooltip = "Use the Undead nuke line.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How can I use my Undead Nuke?",
            Answer = "You can enable the undead nuke line in the Spells and Abilities tab.",
        },
        ['DoMagicNuke']       = {
            DisplayName = "Do Magic Nuke",
            Category = "Combat",
            Index = 6,
            Tooltip = "Use the Undead nuke line.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How can I use my Magic Nuke?",
            Answer = "You can enable the magic nuke line in the Spells and Abilities tab.",
        },
        --Spells and Abilities
        ['DoManaRestore']     = {
            DisplayName = "Use Mana Restore AAs",
            Category = "Spells and Abilities",
            Index = 1,
            Tooltip = "Use Veturika's Prescence (on self) or Quiet Prayer (on others) at critically low mana.",
            RequiresLoadoutChange = true, -- used as a load condition
            Default = true,
            ConfigType = "Advanced",
            FAQ = "What circumstances do we use Veturika's or Quiet Prayer?",
            Answer =
                "If the Mana Restore AA setting is set on the Spells and Abilities tab, we will use either of these once the Mana Restore Pct threshold is crossed.\n" ..
                "We will also use Veturika's as an emergency self-heal if required.",
        },
        ['ManaRestorePct']    = {
            DisplayName = "Mana Restore Pct",
            Category = "Spells and Abilities",
            Index = 2,
            Tooltip = "Min Mana to use restore AA.",
            Default = 10,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
            FAQ = "Why am I not using Veturika's or Quiet Prayer?",
            Answer = "Ensure that your Mana Restore Pct is configured to the value you would like to start using these abilities.",
        },
        ['DoHealOverTime']    = {
            DisplayName = "Use HoTs",
            Category = "Spells and Abilities",
            Index = 3,
            Tooltip = "Use the Elixir Line (Low Level: Single, Mid-Level: Both (situationally), High Level: Group).",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my Cleric using the Group Elixir HoT?",
            Answer = "Before Level 100, we will only use the Group Elixir if we have a GOM proc or the if the \"Group Injured Count\" is met (See Heal settings in RGMain config).",
        },
        ['DoDivineBuff']      = {
            DisplayName = "Do Divine Buff",
            Category = "Spells and Abilities",
            Index = 4,
            Tooltip = "Use your Divine Intervention line (death save) on the MA.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my Cleric using the Divine Intervention buff?",
            Answer = "The Divine Intervention buff line requires a pair of emeralds.",
        },
        ['KeepCureMemmed']    = {
            DisplayName = "Mem Cure:",
            Category = "Spells and Abilities",
            Index = 5,
            Tooltip = "Select your preference of a Cure spell to keep loaded (if a gem is availabe). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if available.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'None (Suggested for most cases)', 'Mem Cure-All (\"Blood\" line) when possible', 'Mem GroupHealCure (\"Word of\" Line) when possible', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why don't the Mem Cure options include low-level cures?",
            Answer =
            "This would add an undesired level of complexity to the config. Before the \"Blood\" line is learned, feel free to memorize any cure you'd like in an open gem! It will be used, if appropriate.",
        },

        --Orphaned: Not used in this config, to be deleted when config is default. Only here so we don't delete settings for the current default config in case people switch back and forth.
        ['DoHOT']             = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoCure']            = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoProm']            = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoClutchHeal']      = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['CompHealPoint']     = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['RemedyHealPoint']   = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoAutoWard']        = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['ClutchHealPoint']   = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoNuke']            = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['NukePct']           = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoReverseDS']       = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoQp']              = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['QPManaPCT']         = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['VetManaPCT']        = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DivineBuffOn']      = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoCH']              = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
    },
}

return _ClassConfig
