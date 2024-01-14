local mq           = require('mq')
local RGMercUtils  = require("utils.rgmercs_utils")

local _ClassConfig = {
    _version              = "0.1a",
    _author               = "Derple",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return true end,
    },
    ['Modes']             = {
        'Heal',
        'Hybrid',
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Crafted Talisman of Fates",
            "Blessed Spiritstaff of the Heyokah",
        },
    },
    ['AbilitySets']       = {
        ["FocusSpell"] = {
            -- Focus Spell - Lower Levels Mix in Single Target, Higher Prefer Group Target
            "Inner Fire",                 -- Level 1 - Single
            "Talisman of Tnarg",          -- Level 32 - Single
            "Talisman of Altuna",         -- Level 40 - Single
            "Talisman of Kragg",          -- Level 55 - Single
            "Khura's Focusing",           -- Level 60 - Group
            "Focus of the Seventh",       -- Level 65 - Group
            "Talisman of Wunshi",         -- Level 70 - Group
            "Talisman of the Dire",       -- Level 75 - Group
            "Talisman of the Bloodworg",  -- Level 80 - Group
            "Talisman of Unity",          -- Level 85 - Group
            "Talisman of Soul's Unity",   -- Level 90 - Group
            "Talisman of Kolos' Unity",   -- Level 95 - Group
            "Talisman of the Courageous", -- Level 100 - Group
            "Talisman of the Doomscale",  -- Level 105 - Group
            "Talisman of the Wulthan",    -- Level 110 - Group
            "Unity of the Kromrif",       -- Level 111 - Single
            "Talisman of the Ry'Gorr",    -- Level 115 - Group
            "Unity of the Vampyre",       -- Level 116 - Single
            "Talisman of the Usurper",    -- Level 120 - Group
            "Celeritous Unity",           -- Level 121 - Single
            "Talisman of the Heroic",     -- Level 125 - Group
        },
        ["RunSpeedBuff"] = {
            -- Run Speed Buff - 9 - 74
            "Spirit of Tala'Tak",
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
        ["GrowthBuff"] = {
            -- Growth Buff 111 -> 81
            "Overwhelming Growth",
            "Fervent Growth",
            "Frenzied Growth",
            "Savage Growth",
            "Ferocious Growth",
            "Rampant Growth",
            "Unfettered Growth",
            "Untamed Growth",
            "Wild Growth",
        },
        ["LowLvlStaminaBuff"] = {
            -- Low Level Stamina Buff --- Use under Level 85
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
        ["LowLvlAttackBuff"] = {
            -- Low Level Attack Buff --- user under level 85
            "Primal Avatar",
            "Ferine Avatar",
            "Champion",
        },
        ["LowLvlStrBuff"] = {
            -- Low Level Strength Buff -- use under evel 85
            "Talisman of Might",
            "Spirit of Might",
            "Talisman of the Diaku",
            "Strength of the Diaku",
            "Voice of the Berserker",
            "Talisman of the Rhino",
            "Maniacal Strength",
            "Primal Essence",
            "Strength",
            "Rage",
            "Furious Strength",
            "Tumultuous Strength",
            "Fury",
            "Raging Strength",
            "Frenzy",
            "Spirit Strength",
            "Burst of Strength",
        },
        ["LowLvlDexBuff"] = {
            -- Low Level Dex Buff -- use under level 70
            "Talisman of the Raptor",
            "Mortal Deftness",
            "Dexterity",
            "Deftness",
            "Rising Dexterity",
            "Spirit of Monkey",
            "Dexterous Aura",
        },
        ["LowLvlAgiBuff"] = {
            --- Low Level AGI Buff -- Use under level 85
            "Talisman of Foresight",
            "Preternatural Foresight",
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
            "Wind of Malisene",
            "Wind of Malis",
        },
        ["MaloSpell"] = {
            -- AA Starts at LVL 75
            "Malosinera",
            "Malosinetra",
            "Malosinise",
            "Malos",
            "Malosinia",
            "Malo",
            "Malosini",
            "Malosi",
            "Malaisement",
            "Malaise",
        },
        ["AESlowSpell"] = {
            "Tigir's Insects",
        },
        ["SlowSpell"] = {
            "Balance of Discord",
            "Balance of the Nihil",
            "Turgur's Insects",
            "Togor's Insects",
            "Tagar's Insects",
            "Walking Sleep",
            "Drowsy",
        },
        ["DieaseSlow"] = {
            "Cloud of Grummus",
            "Plague of Insects",
        },
        ["GroupHealProcBuff"] = {
            "Watchful Spirit",
            "Responsive Spirit",
            "Attentive Spirit",
        },
        ["SelfHealProcBuff"] = {
            -- Self Heal Ward Spells -- LVL 115 -> LVL 80
            "Ward of Heroic Deeds",
            "Ward of Recuperation",
            "Ward of Remediation",
            "Ward of Regeneration",
            "Ward of Rejuvenation",
            "Ward of Reconstruction",
            "Ward of Recovery",
            "Ward of Restoration",
            "Ward of Resurgence",
            "Ward of Rebirth",
        },
        ["DichoSpell"] = {
            "Ecliptic Roar",
            "Composite Roar",
            "Dissident Roar",
            "Roar of the Lion",
        },
        ["MeleeProcBuff"] = {
            -- Melee Proc Buff - Level 50 - 111
            -- To be used when the Shaman does not have Dicho
            "Talisman of the Manul",
            "Talisman of the Kerran",
            "Talisman of the Lioness",
            "Talisman of the Sabretooth",
            "Talisman of the Leopard",
            "Talisman of the Snow Leopard",
            "Talisman of the Lion",
            "Talisman of the Tiger",
            "Talisman of the Lynx",
            "Talisman of the Cougar",
            "Talisman of the Panther",
            -- Below Level 71 This is a single target buff
            "Spirit of the Panther",
            "Spirit of the Leopard",
            "Spirit of the Jaguar",
            "Spirit of the Puma",
        },
        ["SlowProcBuff"] = {
            -- Slow Proc Buff for MA - Level 68 - 122
            "Moroseness",
            "Melancholy",
            "Ennui",
            "Incapacity",
            "Sluggishness",
            "Fatigue",
            "Apathy",
            "Lethargy",
            "Listlessness",
            "Languor",
            "Lassitude",
            "Lingering Sloth",
        },
        ["PackSelfBuff"] = {
            -- Pack Self Buff - Level 90 - 115
            --- Ignoring the LVL 85 Call the Pack buff due to the decrease in mana per tick.
            "Pack of Ancestral Beasts",
            "Pack of Lunar Wolves",
            "Pack of The Black Fang",
            "Pack of Mirtuk",
            "Pack of Olesira",
            "Pack of Kriegas",
            "Pack of Hilnaah",
            "Pack of Wurt",
        },
        ["AllianceBuff"] = {
            "Ancient Alliance",
            "Ancient Coalition",
        },
        ["IcefixSpell"] = {
            -- Eradicate Curse
            "Remove Greater Curse",
            "Eradicate Curse",
        },
        ["RecklessHeal"] = {
            "Reckless Reinvigoration",
            "Reckless Resurgence",
            "Reckless Renewal",
            "Reckless Rejuvenation",
            "Reckless Regeneration",
            "Reckless Restoration",
            "Reckless Remedy",
            "Reckless Mending",
            "Qirik's Mending",
            "Dannal's Mending",
            "Gemmi's Mending",
            "Ahnkaul's Mending",
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
        ["RecklessHeal1"] = {
            "Reckless Reinvigoration",
            "Reckless Resurgence",
            "Reckless Renewal",
            "Reckless Rejuvenation",
            "Reckless Regeneration",
            "Reckless Restoration",
            "Reckless Remedy",
            "Reckless Mending",
            "Qirik's Mending",
            "Dannal's Mending",
            "Gemmi's Mending",
            "Ahnkaul's Mending",
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
        ["RecklessHeal2"] = {
            "Reckless Reinvigoration",
            "Reckless Resurgence",
            "Reckless Renewal",
            "Reckless Rejuvenation",
            "Reckless Regeneration",
            "Reckless Restoration",
            "Reckless Remedy",
            "Reckless Mending",
            "Qirik's Mending",
            "Dannal's Mending",
            "Gemmi's Mending",
            "Ahnkaul's Mending",
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
        ["AESpiritualHeal"] = {
            -- LVL 115-LVL100
            "Spiritual Shower",
            "Spiritual Squall",
            "Spiritual Swell",
            "Spiritual Surge",
        },
        ["RecourseHeal"] = {
            --- RecourseHeal LVL115-87
            "Grayleaf's Recourse",
            "Rowain's Recourse",
            "Zrelik's Recourse",
            "Eyrzekla's Recourse",
            "Krasir's Recourse",
            "Blezon's Recourse",
            "Gotikan's Recourse",
            "Qirik's Recourse",
        },
        ["InterventionHeal"] = {
            -- Intervention Heal LVL 113 -> 78
            "Immortal Intervention",
            "Primordial Intervention",
            "Prehistoric Intervention",
            "Historian's Intervention",
            "Antecessor's Intervention",
            "Progenitor's Intervention",
            "Ascendant's Intervention",
            "Antecedent's Intervention",
            "Ancestral Intervention",
            "Antediluvian Intervention",
        },
        ["GroupRenewalHoT"] = {
            -- LVL 115->70 -- Prior to 70 Breath of Trushar as a non-group HoTs will be used including the
            --- the Torpor/Stoicism line. LVL 44 is the lowest level.
            "Reverie of Renewal",
            "Spirit of Renewal",
            "Spectre of Renewal",
            "Cloud of Renewal",
            "Shear of Renewal",
            "Wisp of Renewal",
            "Phantom of Renewal",
            "Penumbra of Renewal",
            "Shadow of Renewal",
            "Shade of Renewal",
            "Specter of Renewal",
            "Ghost of Renewal",
            "Spiritual Serenity",
            "Breath of Trushar",
            "Quiescence",
            "Torpor",
            "Stoicism",
        },
        ["CanniSpell"] = {
            -- Convert Health to Mana - Level  23 - 113
            "Hoary Agreement",
            "Ancient Bargain",
            "Tribal Bargain",
            "Tribal Pact",
            "Ancestral Pact",
            "Ancestral Arrangement",
            "Ancestral Covenant",
            "Ancestral Obligation",
            "Ancestral Hearkening",
            "Ancestral Bargain",
            "Ancient: Ancestral Calling",
            "Pained Memory",
            "Ancient: Chaotic Pain",
            "Cannibalize IV",
            "Cannibalize",
        },
        ["CureSpell"] = {
            "Blood of Mayong",
            "Blood of Tevik",
            "Blood of Rivans",
            "Blood of Sanera",
            "Blood of Klar",
            "Blood of Corbeth",
            "Blood of Avoling",
            "Blood of Nadox",
        },
        ["TwinHealNuke"] = {
            -- Nuke the MA Not the assist target - Levels 85 - 115
            "Gelid Gift",
            "Polar Gift",
            "Wintry Gift",
            "Frostbitten Gift",
            "Glacial Gift",
            "Frigid Gift",
            "Freezing Gift",
            "Frozen Gift",
            "Frost Gift",
        },
        ["PoisonNuke"] = {
            -- Poison Nuke LVL115->LVL34
            "Red Eye's Spear of Venom",
            "Fleshrot's Spear of Venom",
            "Narandi's Spear of Venom",
            "Nexona's Spear of Venom",
            "Serisaria's Spear of Venom",
            "Slaunk's Spear of Venom",
            "Hiqork's Spear of Venom",
            "Spinechiller's Spear of Venom",
            "Severilous' Spear of Venom",
            "Vestax's Spear of Venom",
            "Ahnkaul's Spear of Venom",
            "Yoppa's Spear of Venom",
            "Spear of Torment",
            "Blast of Venom",
            "Shock of Venom",
            "Blast of Poison",
            "Shock of the Tainted",
        },
        ["FastPoisonNuke"] = {
            -- Fast Poison Nuke LVL115->LVL73
            "Oka's Bite",
            "Ander's Bite",
            "Direfang's Bite",
            "Mawmun's Bite",
            "Reefmaw's Bite",
            "Seedspitter's Bite",
            "Bite of the Grendlaen",
            "Bite of the Blightwolf",
            "Bite of the Ukun",
            "Bite of the Brownie",
            "Sting of the Queen",
        },
        ["FrostNuke"] = {
            --- rostNuke - Levels 4 - 114
            "Ice Barrage",
            "Heavy Sleet",
            "Ice Salvo",
            "Ice Shards",
            "Ice Squall",
            "Ice Burst",
            "Ice Mass",
            "Ice Floe",
            "Ice Sheet",
            "Tundra Crumble",
            "Glacial Avalanche",
            "Ice Age",
            "Velium Strike",
            "Ice Strike",
            "Blizzard Blast",
            "Winter's Roar",
            "Frost Strike",
            "Spirit Strike",
            "Frost Rift",
        },
        ["ChaoticDoT"] = {
            -- Long Dot(42s) LVL 109 -> LVL104
            -- Two resist types because it throws 2 dots
            -- Stacking: Nectar of Pain - Stacking: Blood of Saryrn
            "Chaotic Poison",
            "Chaotic Venom",
            "Chaotic Venin",
            "Chaotic Toxin",
        },
        ["PandemicDot"] = {
            -- Pandemic Dot Long Dot(84s) Level 103 - 108
            -- Two resist types because it throws 2 dots
            -- Stacking: Kralbor's Pandemic  -    Stacking: Breath of Ultor
            "Skraiw's Pandemic",
            "Elkikatar's Pandemic",
            "Hemocoraxius' Pandemic",
            "Bledrek's Pandemic",
            "Doomshade's Pandemic",
            "Tegi Pandemic",
        },
        ["MaloDot"] = {
            -- Malo Dot Stacking: Yubai's Affliction - LongDot(96s) Level 99 - 114
            "Svartmane's Malosinara",
            "Rirwech's Malosinata",
            "Livio's Malosenia",
            "Falhotep's Malosenia",
            "Txiki's Malosinara",
            "Krizad's Malosinera",
        },
        ["CurseDoT1"] = {
            -- Curse Dot 1 Stacking: Curse - Long Dot(30s) - Level 34 - 115
            "Malediction",
            "Obeah",
            "Evil Eye",
            "Jinx",
            "Garugaru",
            "Naganaga",
            "Hoodoo",
            "Hex",
            "Mojo",
            "Pocus",
            "Juju",
            "Curse of Sisslak",
            "Bane",
            "Anathema",
            "Odium",
            "Curse",
        },
        ["CurseDoT2"] = {
            ---, Stacking: Enalam's Curse - Long Dot(54s) - 100 - 115
            "Lenrel's Curse",
            "Marlek's Curse",
            "Erogo's Curse",
            "Sraskus' Curse",
            "Enalam's Curse",
            "Fandrel's Curse",
        },
        ["FastPoisonDoT"] = {
            ---, Stacking: Blood of Saryrn - Fast Dot(12s) - Level 89 - 115
            "Korsh's Venom",
            "Namdrows' Venom",
            "Xalgoti's Venom",
            "Mawmun's Venom",
            "Serpentil's Venom",
            "Banescale's Venom",
            "Stranglefang's Venom",
            "Undaleen's Venom",
        },
        ["SaryrnDot"] = {
            -- Stacking: Blood of Saryrn - Long Dot(42s) - Level 8 - 115
            "Desperate Vampyre Blood",
            "Restless Blood",
            "Reef Crawler Blood",
            "Phase Spider Blood",
            "Naeya Blood",
            "Spinechiller Blood",
            "Blood of Jaled'Dar",
            "Blood of Kerafyrm",
            "Vengeance of Ahnkaul",
            "Blood of Yoppa",
            "Blood of Saryrn",
            "Ancient: Scourge of Nife",
            "Bane of Nife",
            "Envenomed Bolt",
            "Venom of the Snake",
            "Envenomed Breath",
            "Tainted Breath",
        },
        ["FastDiseaseDoT"] = {
            -- Fast Disease Dot Stacking: Breath of Ultor - Fast Dot(12s) - Level 87 - 115
            "Krizad's Malady",
            "Cruor's Malady",
            "Malvus's Malady",
            "Hoshkar's Malady",
            "Sephry's Malady",
            "Elsrop's Malady",
            "Giaborn's Malady",
            "Nargul's Malady",
        },
        ["UltorDot"] = {
            ---, Stacking: Breath of Ultor - Long Dot(84s) - Level 4 - 111
            "Breath of the Hotariton",
            "Breath of the Tegi",
            "Breath of Bledrek",
            "Breath of Hemocoraxius",
            "Breath of Natigo",
            "Breath of Silbar",
            "Breath of the Shiverback",
            "Breath of Queen Malarian",
            "Breath of Big Bynn",
            "Breath of Ternsmochin",
            "Breath of Wunshi",
            "Breath of Ultor",
            "Pox of Bertoxxulous",
            "Plague",
            "Scourge",
            "Affliction",
            "Sicken",
        },
        ["NectarDot"] = {
            --- Nectar Dot Line
            "Nectar of Obscurity",
            "Nectar of Pain",
            "Nectar of Agony",
            "Nectar of Rancor",
            "Nectar of the Slitheren",
            "Nectar of Torment",
            "Nectar of Sholoth",
            "Nectar of Anguish",
            "Nectar of Woe",
            "Nectar of Suffering",
            "Nectar of Misery",
            "Nectar of Destitution",
        },
        ["PetSpell"] = {
            -- Pet Spell - 32 - 112
            "Suja's Faithful",
            "Diabo Sivuela's Faithful",
            "Grondo's Faithful",
            "Mirtuk's Faithful",
            "Olesira's Faithful",
            "Kriegas' Faithful",
            "Hilnaah's Faithful",
            "Wurt's Faithful",
            "Aina's Faithful",
            "Vegu's Faithful",
            "Kyrah's Faithful",
            "Farrel's Companion",
            "True Spirit",
            "Spirit of the Howler",
            "Frenzied Spirit",
            "Guardian spirit",
            "Vigilant Spirit",
            "Companion Spirit",
        },
        ["PetBuffSpell"] = {
            ---Pet Buff Spell - 50 - 112
            "Spirit Augmentation",
            "Spirit Reinforcement",
            "Spirit Bracing",
            "Spirit Bolstering",
            "Spirit Quickening",
        },
        ["TLPCureDisease"] = {
            "Cure Disease",
            "Counteract Disease",
            "Eradicate Disease",
        },
        ["TLPCurePoison"] = {
            "Counteract Poison",
            "Abolish Poison",
            "Eradicate Poison",
        },
    },
    ['HelperFunctions']   = {
        -- helper function for advanced logic to see if we want to use Dark Lord's Unity
        DoRez = function(self, corpseId)
            if not RGMercUtils.PCSpellReady(mq.TLO.Spell("Incarnate Anew")) and
                not mq.TLO.FindItem("Staff of Forbidden Rites")() and
                not RGMercUtils.CanUseAA("Rejuvenation of Spirit") and
                not RGMercUtils.CanUseAA("Call of the Wild") then
                return false
            end

            RGMercUtils.SetTarget(corpseId)

            local target = mq.TLO.Target

            if not target or not target() then return false end

            if mq.TLO.Target.Distance() > 25 then
                RGMercUtils.DoCmd("/corpse")
            end

            local targetClass = target.Class.ShortName()

            if mq.TLO.Me.CombatState():lower() == "combat" and (targetClass == "dru" or targetClass == "clr" or RGMercConfig:GetSettings().DoBattleRez) then
                if mq.TLO.FindItem("Staff of Forbidden Rites")() and mq.TLO.Me.ItemReady("=Staff of Forbidden Rites")() then
                    return RGMercUtils.UseItem("Staff of Forbidden Rites", corpseId)
                end

                if RGMercUtils.AAReady("Call of the Wild") then
                    return RGMercUtils.UseAA("Call of the Wild", corpseId)
                end
            else
                if RGMercUtils.CanUseAA("Rejuvenation of Spirit") then
                    return RGMercUtils.UseAA("Rejuvenation of Spirit", corpseId)
                end

                if RGMercUtils.PCSpellReady(mq.TLO.Spell("Incarnate Anew")) then
                    return RGMercUtils.UseSpell("Incarnate Anew", corpseId, true)
                end
            end

            return false
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
            cond = function(self, target) return mq.TLO.Me.Level() < 65 and (target.PctHPs() or 999) < 80 end,
        },
        {
            name  = 'BigHealPoint',
            state = 1,
            steps = 1,
            cond  = function(self, target) return (target.PctHPs() or 999) < RGMercConfig:GetSettings().BigHealPoint end,
        },
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return mq.TLO.Group.Injured(RGMercConfig:GetSettings().GroupHealPoint)() > RGMercConfig:GetSettings().GroupInjureCnt end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return (target.PctHPs() or 999) < RGMercConfig:GetSettings().MainHealPoint end,
        },
    },
    ['HealRotations']     = {
        ["LowLevelHealPoint"] = {
            {
                name = "RecklessHeal1",
                type = "Spell",
                cond = function(self, _) return RGMercUtils.GetMainAssistPctHPs() <= RGMercUtils.GetSetting('RecklessHealPct') end,
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetMainAssistPctHPs() <= RGMercConfig:GetSettings().MainHealPoint and RGMercUtils.GetSetting('DoHOT') and spell.StacksTarget() and
                        not RGMercUtils.TargetHasBuff(spell)
                end,
            },
            {
                name = "Call of the Ancients",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetMainAssistPctHPs() <= RGMercConfig:GetSettings().MainHealPoint
                end,
            },
        },
        ["GroupHealPoint"] = {
            {
                name = "RecourseHeal",
                type = "Spell",
            },

        },
        ["BigHealPoint"] = {
            {
                name = "InterventionHeal",
                type = "Spell",
            },
            {
                name = "Soothsayer's Intervention",
                type = "AA",
            },

        },
        ["MainHealPoint"] = {
            {
                name = "RecourseHeal",
                type = "Spell",
                cond = function(self, _, target)
                    return (target.ID() or 0) == RGMercUtils.GetMainAssistId()
                end,
            },
            {
                name = "AESpiritualHeal",
                type = "Spell",
                cond = function(self, _, target)
                    return (target.ID() or 0) == RGMercUtils.GetMainAssistId()
                end,
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.GetSetting('DoHOT') and spell.StacksTarget() and not RGMercUtils.TargetHasBuff(spell)
                end,
            },
            {
                name = "Spirit Guardian",
                type = "AA",
                cond = function(self, _, target)
                    return (target.ID() or 0) == RGMercUtils.GetMainAssistId()
                end,
            },
            {
                name = "RecklessHeal1",
                type = "Spell",
                cond = function(self, _, target) return (target.PctHPs() or 999) <= RGMercUtils.GetSetting('RecklessHealPct') end,
            },
            {
                name = "RecklessHeal2",
                type = "Spell",
                cond = function(self, _, target) return true end,
            },
            {
                name = "Soothsayer's Intervention",
                type = "AA",
                cond = function(self, _, target)
                    return true
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
                return combat_state == "Downtime" and
                    RGMercUtils.DoBuffCheck()
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
            name = 'Debuff',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.IsModeActive("Hybrid") and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.BurnCheck() and RGMercUtils.IsModeActive("Hybrid") and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.IsModeActive("Hybrid") and not RGMercUtils.Feigning()
            end,
        },

    },
    ['Rotations']         = {
        ['Splash'] = {
            {
                name = "TwinHealNuke",
                type = "Spell",
                cond = function(self, _)
                    local targetSpawn = RGMercUtils.GetAutoTarget()
                    local settings = RGMercConfig:GetSettings()
                    if targetSpawn() and (targetSpawn.Distance() or 999) < settings.AssistRange and
                        not RGMercUtils.SongActive("Healing Twincast") and targetSpawn.PctHPs() <= settings.AutoAssistAt then
                        return true
                    end
                    return false
                end,
            },
            {
                name = "TwinHealNuke",
                type = "Spell",
                cond = function(self, _) return RGMercUtils.SongActive("Healing Twincast") end,
            },
        },
        ['Burn'] = {
            {
                name = "Ancestral Aid",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.MedBurn()
                end,
            },
            {
                name = "Spirit Call",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SmallBurn()
                end,
            },
            {
                name = "Rabid Bear",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercConfig:GetSettings().DoMelee and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "UltorDot",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) and RGMercUtils.SmallBurn() and RGMercUtils.ManaCheck() end,
            },
        },
        ['Debuff'] = {
            {
                name = "AEMaloSpell",
                type = "Spell",
                cond = function(self, _) return RGMercUtils.GetSetting('DoMalo') and RGMercUtils.GetSetting('DoAEMalo') end,
            },
            {
                name = "MaloSpell",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.GetSetting('DoMalo') and RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "AESlowSpell",
                type = "Spell",
                cond = function(self, _) return RGMercUtils.GetSetting('DoSlow') and RGMercUtils.GetSetting('DoAESlow') end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.GetSetting('DoSlow') and RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Turgur's Virulent Swarm",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoSlow') and RGMercUtils.GetSetting('DoAESlow')
                end,
            },
            {
                name = "Turgur's Swarm",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoSlow') and not RGMercUtils.GetSetting('DoAESlow') and
                        not RGMercUtils.TargetHasBuffByName(mq.TLO.Spell("Turgur's Swarm").Trigger(1).RankName())
                end,
            },
            {
                name = "Wind of Malaise",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoMalo') and RGMercUtils.GetSetting('DoAEMalo')
                end,
            },
            {
                name = "Malaise",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoMalo') and not RGMercUtils.GetSetting('DoAEMalo')
                end,
            },
            {
                name = "DieaseSlow",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.GetSetting('DoSlow') and RGMercUtils.DetSpellCheck(spell) end,
            },
        },
        ['DPS'] = {
            {
                name = "AESpiritualHeal",
                type = "Spell",
                cond = function(self) return RGMercUtils.IsHealing() and RGMercUtils.SongActive("Healing Twincast") end,
            },
            {
                name = "MeleeProcBuff",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "Cannibalization",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoAACani') and RGMercUtils.AAReady(aaName) and
                        mq.TLO.Me.PctMana() < RGMercUtils.GetSetting('AACanniManaPct') and
                        mq.TLO.Me.PctHPs() >= RGMercUtils.GetSetting('AACanniMinHP')
                end,
            },
            {
                name = "CanniSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoSpellCani') and RGMercUtils.CastReady(spell.RankName()) and
                        mq.TLO.Me.PctMana() < RGMercUtils.GetSetting('SpellCanniManaPct') and
                        mq.TLO.Me.PctHPs() >= RGMercUtils.GetSetting('SpellCanniMinHP')
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self)
                    return true
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "Rabid Bear",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercConfig:GetSettings().DoMelee and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "PandemicDot",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) and RGMercUtils.DetGOMCheck(spell) end,
            },
            {
                name = "CurseDoT2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) end,
            },
            {
                name = "CurseDoT1",
                type = "Spell",
                -- first check is for live second is for TLP
                cond = function(self, spell)
                    return (mq.TLO.Me.Level() > 65 and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell)) or
                        (mq.TLO.Me.Level() <= 65 and RGMercUtils.ManaCheck() and (RGMercConfig:GetSettings().BurnAuto or RGMercUtils.SmallBurn()))
                end,
            },
            {
                name = "ChaoticDoT",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) and mq.TLO.Me.PctMana() > 50 end,
            },
            {
                name = "PandemicDot",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) and mq.TLO.Me.PctMana() > 50 end,
            },
            {
                name = "FastPoisonDoT",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) end,
            },
            {
                name = "SaryrnDot",
                type = "Spell",
                -- first check is for live second is for TLP
                cond = function(self, spell)
                    return (mq.TLO.Me.Level() > 65 and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell)) or
                        (mq.TLO.Me.Level() <= 65 and RGMercUtils.ManaCheck() and (RGMercConfig:GetSettings().BurnAuto or RGMercUtils.SmallBurn()))
                end,
            },
            {
                name = "FastDiseaseDoT",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) end,
            },
            {
                name = "UltorDot",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) end,
            },
            {
                name = "MaloDot",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) end,
            },
            {
                name = "PoisonNuke",
                type = "Spell",
            },
            {
                name = "FastPoisonNuke",
                type = "Spell",
            },
            {
                name = "FrostNuke",
                type = "Spell",
                -- first check is for live second is for TLP
                cond = function(self, spell)
                    if mq.TLO.Me.Level() > 65 then
                        return true
                    end
                    return RGMercConfig:GetSettings().BurnAuto or RGMercUtils.SmallBurn() and RGMercUtils.ManaCheck() and RGMercUtils.GetSetting('DoNuke')
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 end,
                cond = function(self, _) return RGMercConfig:GetSettings().DoPet and mq.TLO.Me.Pet.ID() == 0 end,
                post_activate = function(self, spell)
                    local pet = mq.TLO.Me.Pet
                    if pet.ID() > 0 then
                        RGMercUtils.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(), pet.Class.Name(), pet.CleanName(), spell.RankName())
                    end
                end,
            },
            {
                name = "PetBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell) return RGMercUtils.SelfBuffPetCheck(spell) end,
            },
            {
                name = "Cannibalization",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoAACani') and RGMercUtils.AAReady(aaName) and
                        mq.TLO.Me.PctMana() < RGMercUtils.GetSetting('AACanniManaPct') and
                        mq.TLO.Me.PctHPs() >= RGMercUtils.GetSetting('AACanniMinHP')
                end,
            },
            {
                name = "CanniSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoSpellCani') and RGMercUtils.CastReady(spell.RankName()) and
                        mq.TLO.Me.PctMana() < RGMercUtils.GetSetting('SpellCanniManaPct') and
                        mq.TLO.Me.PctHPs() >= RGMercUtils.GetSetting('SpellCanniMinHP')
                end,
            },
            {
                name = "Pact of the Wolf",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.Me.Aura(aaName)() ~= nil end,
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoAura') and not RGMercUtils.SongActive(aaName) and mq.TLO.Me.Aura(aaName)() == nil
                end,
            },
            {
                name = "Talisman of Celerity",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.Me.Haste() end,
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoHaste') and not mq.TLO.Me.Haste() and RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "RunSpeedBuff",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoRunSpeed') and RGMercUtils.SelfBuffCheck(spell) and not RGMercUtils.CanUseAA("Lupine Spirit")
                end,
            },
            {
                name = "Lupine Spirit",
                type = "AA",
                active_cond = function(self, aaName) return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID()) end,
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoRunSpeed') and RGMercUtils.CanUseAA(aaName) and RGMercUtils.SelfBuffAACheck(aaName) and
                        not mq.TLO.Me.FindBuff("id " .. mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())
                end,
            },
            {
                name = "Preincarnation",
                type = "AA",
                active_cond = function(self, aaName) return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID()) end,
                cond = function(self, aaName)
                    return mq.TLO.Me.AltAbility(aaName)() and mq.TLO.Me.AltAbility(aaName).Rank() > 2 and RGMercUtils.SelfBuffAACheck(aaName) and
                        not RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())
                end,
            },
            {
                name = "PackSelfBuff",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfHealProcBuff",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
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
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                -- [ HEAL MODE ] --
                { name = "RecklessHeal1", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "RecklessHeal1", },
            },
        },
        {
            gem = 2,
            spells = {
                -- [ HEAL MODE ] --
                { name = "SlowSpell",       cond = function(self) return RGMercUtils.IsModeActive("Heal") and mq.TLO.Me.AltAbility("Turgur's Swarm")() == nil end, },
                { name = "RecklessHeal2",   cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "FrostNuke", },
                -- [ TLP FALL BACK ] --
                { name = "GroupRenewalHoT", },
            },
        },
        {
            gem = 3,
            spells = {
                -- [ HEAL MODE ] --
                { name = "RecourseHeal",    cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "GroupRenewalHoT", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "RecourseHeal", },
                { name = "GroupRenewalHoT", },
                -- [ TLP FALL BACK ] --
                { name = "CurseDoT1",       cond = function(self) return RGMercUtils.GetSetting('DoMagicDot') end, },
                { name = "SaryrnDot", },
            },
        },
        {
            gem = 4,
            spells = {
                -- [ HEAL MODE ] --
                { name = "InterventionHeal", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "InterventionHeal", },
                -- [ TLP FALL BACK ] --
                { name = "UltorDot", },
            },
        },
        {
            gem = 5,
            spells = {
                -- [ HEAL MODE ] --
                { name = "ChaoticDoT", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "SaryrnDot",  cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "ChaoticDoT", },
                { name = "SaryrnDot", },
                -- [ TLP FALL BACK ] --
                { name = "DieaseSlow", cond = function(self) return RGMercUtils.GetSetting('DoDieaseSlow') end, },
                { name = "SlowSpell", },
            },
        },
        {
            gem = 6,
            spells = {
                -- [ HEAL MODE ] --
                { name = "CanniSpell",       cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "CanniSpell", },
                -- [ TLP FALL BACK ] --
                { name = "LowLvlAttackBuff", },
            },
        },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "GrowthBuff",   cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "SlowProcBuff", },
                -- [ TLP FALL BACK ] --
                { name = "CanniSpell", },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "GroupRenewalHoT", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "FocusSpell",      cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "CurseDoT1", },
                { name = "FocusSpell", },
            },
            -- [ TLP FALL BACK ] --
            { name = "MaloSpell", },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "IcefixSpell", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "PandemicDot", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "UltorDot",    cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "PandemicDot", },
                { name = "UltorDot", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "DichoSpell",    cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                { name = "MeleeProcBuff", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "DichoSpell", },
                { name = "MeleeProcBuff", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "AESpiritualHeal", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "CurseDoT2", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                { name = "TwinHealNuke", cond = function(self) return RGMercUtils.IsModeActive("Heal") end, },
                -- [ Hybrid MODE ] --
                { name = "IcefixSpell", },
                { name = "PoisonNuke", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ HEAL MODE ] --
                -- [ Hybrid MODE ] --
                { name = "GrowthBuff", },
            },
        },
    },
    ['DefaultConfig']     = {
        ['Mode']              = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 3, },
        ['DoNuke']            = { DisplayName = "Cast Nukes", Category = "Spells and Abilities", Tooltip = "Use Nuke Spells", Default = true, },
        ['DoHOT']             = { DisplayName = "Cast HOTs", Category = "Spells and Abilities", Tooltip = "Use Heal Over Time Spells", Default = true, },
        ['RecklessHealPct']   = { DisplayName = "Reckless Heal %", Category = "Spells and Abilities", Tooltip = "Use Reckless Heal When Assist hits [X]% HPs", Default = 80, Min = 1, Max = 100, },
        ['DoDieaseSlow']      = { DisplayName = "Cast Diease Slows", Category = "Spells and Abilities", Tooltip = "Use Diease Slow Spells", Default = true, },
        ['DoMagicDot']        = { DisplayName = "Cast Magic DOT", Category = "Spells and Abilities", Tooltip = "Use Magic DOTs", Default = true, },
        ['DoAACani']          = { DisplayName = "Use AA Cani", Category = "Spells and Abilities", Tooltip = "Use Cani AA during downtime", Default = true, },
        ['AACanniManaPct']    = { DisplayName = "AA Cani Mana %", Category = "Spells and Abilities", Tooltip = "Use Cani AA Under [X]% mana", Default = 70, Min = 1, Max = 100, },
        ['AACanniMinHP']      = { DisplayName = "AA Cani HP %", Category = "Spells and Abilities", Tooltip = "Dont Use Cani AA Under [X]% HP", Default = 70, Min = 1, Max = 100, },
        ['DoSpellCani']       = { DisplayName = "Use AA Cani", Category = "Spells and Abilities", Tooltip = "Use Cani Spell during downtime", Default = true, },
        ['SpellCanniManaPct'] = { DisplayName = "AA Cani Mana %", Category = "Spells and Abilities", Tooltip = "Use Cani Spell Under [X]% mana", Default = 70, Min = 1, Max = 100, },
        ['SpellCanniMinHP']   = { DisplayName = "AA Cani HP %", Category = "Spells and Abilities", Tooltip = "Dont Use Cani Spell Under [X]% HP", Default = 70, Min = 1, Max = 100, },
        ['DoAura']            = { DisplayName = "Use Aura", Category = "Buffs", Tooltip = "Use Aura (Pact of Wolf)", Default = true, },
        ['DoHaste']           = { DisplayName = "Use Haste", Category = "Buffs", Tooltip = "Do Haste Spells/AAs", Default = true, },
        ['DoRunSpeed']        = { DisplayName = "Do Run Speed", Category = "Buffs", Tooltip = "Do Run Speed Spells/AAs", Default = true, },
        ['DoMalo']            = { DisplayName = "Cast Malo", Category = "Debuffs", Tooltip = "Do Malo Spells/AAs", Default = true, },
        ['DoAEMalo']          = { DisplayName = "Cast AE Malo", Category = "Debuffs", Tooltip = "Do AE Malo Spells/AAs", Default = false, },
        ['DoSlow']            = { DisplayName = "Cast Slow", Category = "Debuffs", Tooltip = "Do Slow Spells/AAs", Default = true, },
        ['DoAESlow']          = { DisplayName = "Cast AE Slow", Category = "Debuffs", Tooltip = "Do AE Slow Spells/AAs", Default = false, },
        ['HPStopDOT']         = { DisplayName = "HP Stop DOTs", Category = "Spells and Abilities", Tooltip = "Stop casting DOTs when the mob hits [x] HP %.", Default = 30, Min = 1, Max = 100, },
    },
}

return _ClassConfig
