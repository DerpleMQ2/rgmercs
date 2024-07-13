local mq           = require('mq')
local RGMercUtils  = require("utils.rgmercs_utils")

local _ClassConfig = {
    _version              = "1.0 Beta",
    _author               = "Pureleaf, Derple",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return true end,
        IsRezing = function() return RGMercUtils.GetSetting('DoBattleRez') or RGMercUtils.GetXTHaterCount() == 0 end,
    },
    ['Modes']             = {
        'Heal',
        'Hybrid',
    },
    ['Cures']             = {
        CureNow = function(self, type, targetId)
            if RGMercUtils.CanUseAA("Radiant Cure") then
                return RGMercUtils.UseAA("Radiant Cure", targetId)
            end

            local cureSpell = RGMercUtils.GetResolvedActionMapItem('CureDisease')

            if type:lower() == "poison" then
                cureSpell = RGMercUtils.GetResolvedActionMapItem('CurePoison')
            elseif type:lower() == "curse" then
                cureSpell = RGMercUtils.GetResolvedActionMapItem('CureCurse')
            elseif type:lower() == "corruption" then
                cureSpell = RGMercUtils.GetResolvedActionMapItem('CureCorrupt')
            end

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
        ['wardspell'] = {
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
        ['remedyheal1'] = {
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
        ['remedyheal2'] = {
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
        ['patchheal1'] = {
            -----Patch Heals Slot 4 Dissident Blessing
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
            -- [] = "Merciful Light",
            -- [] = "Sincere Light",
            "Fervent Light",
            "Undying Life",
            "Dissident Blessing",
            "Composite Blessing",
            "Ecliptic Blessing",
        },
        ['patchheal2'] = {
            -----Patch Heals Slot 4 Dissident Blessing
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
            -- [] = "Merciful Light",
            -- [] = "Sincere Light",
            "Fervent Light",
            "Undying Life",
            "Dissident Blessing",
            "Composite Blessing",
            "Ecliptic Blessing",
        },
        ['groupfastheal'] = {
            -----Group Fast Heal 103+ Only
            "Syllable of Acceptance",
            "Syllable of Convalescence",
            "Syllable of Mending",
            "Syllable of Soothing",
            "Syllable of Invigoration",
        },
        ['groupheal'] = {
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
        ['grouphealnocure'] = {
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
        ['promheal'] = {
            -----Promised Heals
            "Promised Renewal",
            "Promised Restoration",
            "Promised Recuperation",
            "Promised Resurgence",
            "Promised Restitution",
            "Promised Reformation",
            "Promised Rehabilitation",
            "Promised Remedy",
            "Promised Redemption",
            "Promised Reclamation",
            "Promised Remediation",
        },
        ['bigheal'] = {
            -----Renewal Big Heal Lines
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
        ['yaulpspell'] = {
            --Yaulp Setup Pre-91 AA
            "Yaulp V",
            "Yaulp VI",
            "Yaulp VII",
            "Yaulp VIII",
            "Yaulp IX",
            "Yaulp X",
            "Yaulp XI",
        },
        ['stunnuke'] = {
            -----Stun Nukes - DISABLED Auto mem
            "Aweshake",
            "Awecrash",
            "Aweburst",
            "Aweclash",
            "Awecrush",
            "Awestrike",
            "Aweflash",
            "Aweblast",
            "Awebolt",
        },
        ['healnuke'] = {
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
        ['healnuke1'] = {
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
        ['healnuke2'] = {
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
        ['nukeheal'] = {
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
        ['nukeheal1'] = {
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
        ['nukeheal2'] = {
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
        ['SelfBuffhp'] = {
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
            "Unified Hand of Helmsbane",
        },
        ['TankBuff'] = {
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
        ['SingleSymbolBuff'] = {
            ----Symbols
            "Symbol of Transal",
            "Symbol of Ryltan",
            "Symbol of Pinzarn",
            "Symbol of Naltron",
            "Symbol of Marzin",
            "Symbol of Kazad",
            "Symbol of Balikor",
            "Symbol of Elushar",
            "Symbol of Kaerra",
            "Symbol of Darianna",
            "Symbol of Ealdun",
            "Unity of the Triumvirate",
            "Unity of Gezat",
            "Unity of Nonia",
            "Unity of Emra",
            "Unity of Jorlleag",
            "Unity of Helmsbane",
        },
        ['SymbolBuff'] = {
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
            "Unified Hand of Infallibility",
        },
        ['HPBuff'] = {
            ----Single Target HP Buffs
            "Courage",
            "Center",
            "Daring",
            "Bravery",
            "Valor",
            "Heroism",
            "Temperance",
            "Aegolism",
            "Virtue",
            "Conviction",
            "Tenacity",
            "Temerity",
            "Gallantry",
            "Reliance",
            "Unified Credence",
            "Unified Certitude",
            "Unified Surety",
            "Unified Assurance",
            "Unified Righteousness",
            "Unified Persistence",
            "Unified Commitment",
        },
        ['aurabuff1'] = {
            ----Aura Buffs - Aura Name is seperate than the buff name
            "Aura of the Pious",
            "Aura of the Zealot",
            "Aura of the Reverent",
            "Aura of the Persistent",
        },
        ['aurabuff2'] = {
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
        ['Icespellcure'] = {
            ----- Spell Cure--------
            "Expurgated Blood",
            "Unblemished Blood",
            "Cleansed Blood",
            "Perfected Blood",
            "Purged Blood",
            "Sanctified Blood",
        },
        ['AllianceBuff'] = {
            ----AllianceBuff
            "Sincere Coalition",
            "Divine Alliance",
        },
        ['Hammerpet'] = {
            "Unswerving Hammer of Faith",
            "Unswerving Hammer of Retribution",
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
        ['SingleHot'] = {
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
            "Reverent Elixir",
            "Ardent Elixir",
            "Merciful Elixir",
            "Sincere Elixir",
            "Hallowed Elixir",
            "Avowed Elixir",
        },
        ['twincastnuke'] = {
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
        ['CurePoison'] = {
            --Cure poison Lines Single Target
            "Cure Poison",
            "Counteract Poison",
            "Abolish Poison",
            "Eradicate Poison",
            "Antidote",
            "Purged Blood",
            "Perfected Blood",
            "Cleansed Blood",
            "Unblemished Blood",
            "Expurgated Blood",
            "Sanctified Blood",
        },
        ['CureDisease'] = {
            --Cure Diease Lines Single Target
            "Cure Disease",
            "Counteract Disease",
            "Pure Blood",
            "Eradicate Disease",
            "Purified Blood",
            "Purged Blood",
            "Perfected Blood",
            "Cleansed Blood",
            "Unblemished Blood",
            "Expurgated Blood",
            "Sanctified Blood",
        },
        ['CureCurse'] = {
            -- Single target Curse Removal Line.
            "Remove Minor Curse",
            "Remove Lesser Curse",
            "Remove Curse",
            "Remove Greater Curse",
            "Eradicate Curse",
            "Purged Blood",
            "Perfected Blood",
            "Cleansed Blood",
            "Unblemished Blood",
            "Expurgated Blood",
            "Sanctified Blood",
        },
        ['CureCorrupt'] = {
            --Cure Corrupt Single Target Cures. begins at level 74 and Evolves into Blood Line for Cureall.
            "Expunge Corruption",
            "Vitiate Corruption",
            "Abolish Corruption",
            "Pristine Blood",
            "Dissolve Corruption",
            "Perfected Blood",
            "Cleansed Blood",
            "Unblemished Blood",
            "Expurgated Blood",
            "Purged Blood",
            "Sanctified Blood",
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
        ['InfusionHand'] = {
            -- Hand of Infusion Line
            "Hand of Faithful Infusion",
            "Hand of Graceful Infusion",
            "Hand of Merciful Infusion",
            "Hand of Sincere Infusion",
            "Hand of Unyielding Infusion",
            "Hand of Avowed Infusion",
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
        ['AnticipatedHeal'] = {
            -- Anticipated Heal Line
            "Anticipated Interposition",
            "Anticipated Intercession",
            "Anticipated Intervention",
            "Anticipated Intercalation",
            "Anticipated Interdiction",
        },
        ['GroupHot'] = {
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
        ['GroupHotCure'] = {
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
        ['CompHeal'] = {
            --Complete Heal
            "Complete Heal",
        },

    }, -- end AbilitySets
    ['HelperFunctions']   = {
        -- helper function for advanced logic to see if we want to use Dark Lord's Unity
        DoRez = function(self, corpseId)
            if RGMercUtils.GetSetting('DoBattleRez') or RGMercUtils.DoBuffCheck() then
                RGMercUtils.SetTarget(corpseId)

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
    },
    -- These are handled differently from normal rotations in that we try to make some intelligent desicions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        {
            name = 'LowLevelHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return mq.TLO.Me.Level() < 85 and (target.PctHPs() or 999) < RGMercUtils.GetSetting('LightHealPoint') end,
        },
        {
            name  = 'BigHealPoint',
            state = 1,
            steps = 1,
            cond  = function(self, target) return (target.PctHPs() or 999) < RGMercUtils.GetSetting('BigHealPoint') end,
        },
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return (mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() or 0) > RGMercUtils.GetSetting('GroupInjureCnt') end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return (target.PctHPs() or 999) < RGMercUtils.GetSetting('MainHealPoint') end,
        },
    }, -- end HealRotationOrder
    ['HealRotations']     = {
        ["LowLevelHealPoint"] = {
            -- TLP Heals - because this is Intended for TLP and levels 1-84 all 85+ AAs& Spells Are Not present.
            --Darby & Epic Darby - First heals to use so if we have Incoming issues we try to not aggro.
            {
                name = "Divine Arbitration",
                type = "AA",
                cond = function(self, _) return RGMercUtils.GetMainAssistPctHPs() <= RGMercUtils.GetSetting('LightHealPoint') end,
            },
            -- To Do: next in rotation is the epic
            -- To Do: next in rotation is the tacvihammer, but it didnt work in rgmercs mac
            --Next we use Group AA Then Spell heals if nessicary These are all gated By Checks to ensure they are needed.

            {
                name = "Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName, target, uiCheck)
                    -- force the target for StacksTarget to work.
                    if not uiCheck then RGMercUtils.SetTarget(target.ID() or 0) end
                    local spell = mq.TLO.AltAbility(aaName).Spell
                    return RGMercUtils.GetMainAssistPctHPs() <= RGMercUtils.GetSetting('GroupHealPoint') and RGMercUtils.GetSetting('DoHOT') and
                        RGMercUtils.SpellStacksOnTarget(spell) and
                        not RGMercUtils.TargetHasBuff(spell) and (mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() or 0) > RGMercUtils.GetSetting('GroupInjureCnt')
                end,
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
                cond = function(self, aaName, target, uiCheck) -- note: Is aaName the correct arg here? or should be 'spell'?
                    -- force the target for StacksTarget to work.
                    if not uiCheck then RGMercUtils.SetTarget(target.ID() or 0) end
                    local spell = mq.TLO.AltAbility(aaName).Spell
                    return RGMercUtils.GetMainAssistPctHPs() <= RGMercUtils.GetSetting('GroupHealPoint') and RGMercUtils.GetSetting('DoHOT') and
                        RGMercUtils.SpellStacksOnTarget(spell) and
                        not RGMercUtils.TargetHasBuff(spell) and (mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() or 0) > RGMercUtils.GetSetting('GroupInjureCnt')
                end,
            },
            {
                name = "groupheal",
                type = "spell",
                cond = function(self, spell, target, uiCheck)
                    -- force the target for StacksTarget to work.
                    if not uiCheck then RGMercUtils.SetTarget(target.ID() or 0) end
                    return RGMercUtils.GetMainAssistPctHPs() <= RGMercUtils.GetSetting('GroupHealPoint') and RGMercUtils.GetSetting('DoHOT') and
                        RGMercUtils.SpellStacksOnTarget(spell) and
                        not RGMercUtils.TargetHasBuff(spell) and (mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() or 0) > RGMercUtils.GetSetting('GroupInjureCnt')
                end,
            },
            {
                name = "patchheal1",
                type = "spell",
                cond = function(self, _, target) return (target.PctHPs() or 999) <= RGMercUtils.GetSetting('LightHealPoint') end,
            },
            {
                name = "remedyheal1",
                type = "spell",
                cond = function(self, _, target) return (target.PctHPs() or 999) <= RGMercUtils.GetSetting('RemedyHealPoint') end,
            },
            {
                name = "remedyheal2",
                type = "spell",
                cond = function(self, _, target) return (target.PctHPs() or 999) <= RGMercUtils.GetSetting('RemedyHealPoint') end,
            },
            {
                name = "CompHeal",
                type = "spell",
                cond = function(self, _) return RGMercUtils.GetMainAssistPctHPs() <= RGMercUtils.GetSetting('CompHealPoint') end,
            },
            {
                name = "wardspell",
                type = "spell",
                cond = function(self, spell)
                    return RGMercUtils.GetMainAssistPctHPs() <= RGMercUtils.GetSetting('GroupHealPoint') and RGMercUtils.GetSetting('DoHOT') and
                        RGMercUtils.SpellStacksOnTarget(spell) and
                        not RGMercUtils.TargetHasBuff(spell) and (mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() or 0) > RGMercUtils.GetSetting('GroupInjureCnt')
                end,
            },
        },
        ["GroupHealPoint"] = {
            {
                name = "groupfastheal",
                type = "Spell",
                cond = function(self, _, target)
                    return true
                end,
            },
            {
                name = "groupheal",
                type = "Spell",
                cond = function(self, _, target)
                    return true
                end,
            },
            {
                name = "GroupHot",
                type = "Spell",
                cond = function(self, _, target)
                    return true
                end,
            },
            {
                name = "Celestial Regeneration",
                type = "AA",
                cond = function(self, _, target)
                    return true
                end,
            },
            {
                name = "Beacon of Life",
                type = "AA",
                cond = function(self, _, target)
                    return true
                end,
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
                cond = function(self, _, target)
                    return true
                end,
            },
        },
        ["BigHealPoint"] = {
            {
                name = "Divine Arbitration",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Burst of Life",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "ClutchHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.GetSetting('DoClutchHeal') and ((mq.TLO.Me.Level() <= 87 and RGMercUtils.GetTargetPctHPs() < 45) or RGMercUtils.GetTargetPctHPs() < 35)
                end,
            },
            {
                name = "patchheal1",
                type = "Spell",
                cond = function(self, spell, target)
                    return true
                end,
            },
        },
        ["MainHealPoint"] = {
            {
                name = "Focused Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName) and (RGMercUtils.GetTargetDistance() < RGMercUtils.GetSetting('AssistRange'))
                end,
            },
            {
                name = "SingleHot",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.GetSetting('DoHOT') and not target.CachedBuff(spell.RankName())()
                end,
            },
            {
                name = "healnuke1",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.GetSetting('DoNuke') and RGMercUtils.GetTargetPctHPs() < RGMercUtils.GetSetting('NukePct')
                end,
            },
            {
                name = "healnuke2",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.GetSetting('DoNuke') and RGMercUtils.GetTargetPctHPs() < RGMercUtils.GetSetting('NukePct')
                end,
            },
            {
                name = "remedyheal1",
                type = "Spell",
                cond = function(self, spell, target)
                    return true
                end,
            },
            {
                name = "remedyheal2",
                type = "Spell",
                cond = function(self, spell, target)
                    return true
                end,
            },
        },
    }, -- end HealRotations
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    RGMercUtils.DoBuffCheck() and RGMercConfig:GetTimeSinceLastMove() > RGMercUtils.GetSetting('BuffWaitMoveTimer')
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
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
                return combat_state == "Downtime" and RGMercUtils.DoBuffCheck() and
                    RGMercConfig:GetTimeSinceLastMove() > RGMercUtils.GetSetting('BuffWaitMoveTimer')
            end,
        },
        {
            name = 'Splash',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercUtils.GetMainAssistId(), } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.IsHealing() and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.BurnCheck() and RGMercUtils.IsModeActive("Hybrid") and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.IsModeActive("Hybrid") and not RGMercUtils.Feigning()
            end,
        },

    },
    ['Rotations']         = {
        ['Splash'] = {
            {
                name = "twincastnuke",
                type = "Spell",
                cond = function(self)
                    return RGMercUtils.GetTargetDistance() < RGMercUtils.GetSetting('AssistRange') and
                        not RGMercUtils.SongActiveByName("Healing Twincast") and
                        RGMercUtils.GetTargetPctHPs() <= RGMercUtils.GetSetting('AutoAssistAt')
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Celestial Hammer",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.MedBurn()
                end,
            },
            {
                name = "Flurry of Life",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SmallBurn()
                end,
            },
            {
                name = "Spire of the Vicar",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "Divine Avatar",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "Divine Retribution",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Turn Undead",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.TargetBodyIs(target, "Undead")
                end,
            },
            {
                name = "nukeheal1",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive('Hybrid') and RGMercUtils.GetTargetPctHPs() < RGMercUtils.GetSetting('NukePct') and RGMercUtils.GetSetting('DoNuke')
                end,
            },
            {
                name = "nukeheal2",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive('Hybrid') and RGMercUtils.GetTargetPctHPs() < RGMercUtils.GetSetting('NukePct') and RGMercUtils.GetSetting('DoNuke')
                end,
            },
            {
                name = "twincastnuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive('Hybrid') and RGMercUtils.GetTargetPctHPs() < RGMercUtils.GetSetting('NukePct') and RGMercUtils.GetSetting('DoNuke')
                end,
            },
            {
                name = "yaulpspell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive('Heal') and RGMercUtils.GetSetting('DoMount') == 2 and mq.TLO.Zone.Indoor()
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive('Heal') and RGMercUtils.GetTargetPctHPs() < RGMercUtils.GetSetting('NukePct') and RGMercUtils.GetSetting('DoNuke')
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "aurabuff1",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.CanUseAA('Spirit Mastery') and not RGMercUtils.AuraActiveByName("Reverent Aura") and RGMercUtils.SpellStacksOnMe(spell)
                end,
            },
            {
                name = "aurabuff2",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.CanUseAA('Spirit Mastery') and not RGMercUtils.AuraActiveByName(spell.BaseName()) and RGMercUtils.SpellStacksOnMe(spell)
                end,
            },
            {
                name = "Saint's Unity",
                type = "AA",
                cond = function(self, aaName)
                    local selfBuffHP = self:GetResolvedActionMapItem('SelfBuffhp')
                    local selfBuffHPLevel = selfBuffHP and selfBuffHP.Level() or 0
                    local aaSpell = mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName)() and mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).BaseName() or "")
                    local aaLevel = aaSpell and aaSpell.Level() or 0
                    return RGMercUtils.AAReady(aaName) and selfBuffHPLevel <= aaLevel and RGMercUtils.SpellStacksOnMe(aaSpell)
                end,
            },
            {
                name = "SelfBuffhp",
                type = "Spell",
                cond = function(self, spell)
                    local aaSpell = mq.TLO.Spell(mq.TLO.Me.AltAbility("Saint's Unity").Spell.Trigger(1).BaseName() or "")
                    local aaLevel = aaSpell and aaSpell.Level() or 0
                    return aaLevel < (spell.Level() or 0) and RGMercUtils.GetSetting('DoDruid') and spell.Stacks() and RGMercUtils.CanUseAA('Spirit Mastery') and
                        not RGMercUtils.BuffActive(spell)
                end,
            },
            {
                name = "GroupHealProcBuff",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SpellStacksOnMe(spell) and not RGMercUtils.BuffActive(spell)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "SymbolBuff",
                type = "Spell",
                cond = function(self, spell, target, uiCheck)
                    -- force the target for StacksTarget to work.
                    if not uiCheck then RGMercUtils.SetTarget(target.ID() or 0) end
                    return RGMercUtils.GetSetting('DoSymbol') and RGMercUtils.TargetClassIs({ "WAR", "PAL", "SHD", }, target) and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "AegoBuff",
                type = "Spell",
                cond = function(self, spell, target, uiCheck)
                    -- force the target for StacksTarget to work.
                    if not uiCheck then RGMercUtils.SetTarget(target.ID() or 0) end
                    return RGMercUtils.GetSetting('DoDruid') and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                -- [ HEAL MODE ] --
                { name = "remedyheal1", cond = function(self) return true end, },
            },
        },
        {
            gem = 2,
            spells = {
                -- [ HEAL MODE ] --
                -- Macro chooses 2 remedy heals for gem 1 and 2, need method to choose second best from list
                { name = "remedyheal2", cond = function(self) return true end, },
            },
        },
        {
            gem = 3,
            spells = {
                -- [ HEAL MODE ] --
                { name = "DivineBuff", cond = function(self) return RGMercUtils.IsModeActive("Heal") and RGMercUtils.GetSetting('DivineBuffOn') end, },
                {
                    name = "SingleHot",
                    cond = function(self)
                        return RGMercUtils.IsModeActive("Heal") and not RGMercUtils.GetSetting('DivineBuffOn') and
                            not RGMercUtils.GetSetting('DoClutchHeal') and RGMercUtils.GetSetting('DoHOT')
                    end,
                },
                { name = "ClutchHeal", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "nukeheal1",  cond = function(self) return true end, },
            },
        },
        {
            gem = 4,
            spells = {
                -- [ HEAL MODE ] --
                { name = "patchheal2", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "nukeheal2",  cond = function(self) return true end, },
            },
        },
        {
            gem = 5,
            spells = {
                -- [ HEAL MODE ] --
                { name = "twincastnuke", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "promheal",     cond = function(self) return true end, },
            },
        },
        {
            gem = 6,
            spells = {
                -- [ HEAL MODE ] --
                {
                    name = "Icespellcure",
                    cond = function(self)
                        local yaulpSpell = self:GetResolvedActionMapItem('yaulpspell')
                        local yaulpSpellLevel = yaulpSpell and yaulpSpell.Level() or 0
                        local yaulpAA = mq.TLO.Me.AltAbility('Yaulp')
                        local yaulpAALevel = yaulpAA and yaulpAA.Spell.BaseName() and mq.TLO.Spell(yaulpAA.Spell.BaseName()).Level() or 0
                        return RGMercUtils.IsModeActive("Heal") and RGMercUtils.CanUseAA('Yaulp') and yaulpSpellLevel <= yaulpAALevel
                    end,
                },
                { name = "yaulpspell", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "healnuke1",  cond = function(self) return true end, },
            },
        },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "GroupHot",      cond = function(self) return RGMercUtils.IsModeActive("Heal") and RGMercUtils.GetSetting('DoHOT') end, },
                { name = "groupheal",     cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "groupfastheal", cond = function(self) return true end, },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "groupfastheal", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "patchheal1",    cond = function(self) return true end, },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "healnuke1", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "ReverseDS", cond = function(self) return true end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "nukeheal1",    cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "Icespellcure", cond = function(self) return true end, },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "ReverseDS", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "SingleHot", cond = function(self) return RGMercUtils.GetSetting('DoHOT') end, },
                { name = "healnuke2", cond = function(self) return true end, },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "promheal",     cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "twincastnuke", cond = function(self) return true end, },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "GroupHealProcBuff", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
            },
        },
    }, -- spells config
    ['DefaultConfig']     = {
        ['Mode']            = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 2, },
        ['DoHOT']           = { DisplayName = "Cast HOTs", Category = "Spells and Abilities", Tooltip = "Use Heal Over Time Spells", Default = true, },
        ['DoCure']          = { DisplayName = "Cast Cure SPells", Category = "Spells and Abilities", Tooltip = "Use Cure Spells", Default = true, },
        ['DoProm']          = { DisplayName = "Cast Promised Heal Spells", Category = "Spells and Abilities", Tooltip = "Use Prom Spells", Default = true, },
        ['DoClutchHeal']    = { DisplayName = "Do Clutch Heal", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = true, },
        ['DoAutoWard']      = { DisplayName = "Do Auto Ward", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = true, },
        ['ClutchHealPoint'] = { DisplayName = "Clutch Heal Point", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = 34, Min = 1, Max = 99, },
        ['DoNuke']          = { DisplayName = "Do Nuke", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = true, },
        ['NukePct']         = { DisplayName = "Nuke Pct", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = 90, Min = 1, Max = 100, },
        ['DoReverseDS']     = { DisplayName = "Do ReverseDS", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = true, },
        ['DoQp']            = { DisplayName = "Do Qp", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = true, },
        ['QPManaPCT']       = { DisplayName = "QP Mana PCT", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = 40, Min = 1, Max = 99, },
        ['VetManaPCT']      = { DisplayName = "Vet Mana PCT", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = 70, Min = 1, Max = 99, },
        ['DivineBuffOn']    = { DisplayName = "Divine Buff On", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = false, },
        ['DoDruid']         = { DisplayName = "Do Druid", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = false, },
        ['DoCH']            = { DisplayName = "Do CH", Category = "Heals", Tooltip = "Use Spells", Default = false, },
        ['DoSymbol']        = { DisplayName = "Do Symbol", Category = "Heals", Tooltip = "Use Spells", Default = false, },
    }, -- end DefaultConfig
}

return _ClassConfig
