local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    ['Modes'] = {
        'Tank',
        'DPS',
        'Healer',
        'Hybrid',
    },
    ['ItemSets'] = {
        ['Epic'] = {
            "Crafted Talisman of Fates",
            "Blessed Spiritstaff of the Heyokah",
        },
    },
    ['AbilitySets'] = {
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
    ['Rotations'] = {
        ['Tank'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    {},
                },
                ['Debuff'] = {
                    {},
                },
                ['Heal'] = {
                    {},
                },
                ['DPS'] = {
                    {},
                },
                ['Downtime'] = {
                    {},
                },
            },
            ['Spells'] = {
                { name = "", gem = 1, },
                { name = "", gem = 2, },
                { name = "", gem = 3, },
                { name = "", gem = 4, },
                { name = "", gem = 5, },
                { name = "", gem = 6, },
                { name = "", gem = 7, },
                { name = "", gem = 8, },
                { name = "", gem = 9, },
                { name = "", gem = 10, },
                { name = "", gem = 11, },
                { name = "", gem = 12, },
            },
        },
        ['DPS'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    {},
                },
                ['Debuff'] = {
                    {},
                },
                ['Heal'] = {
                    {},
                },
                ['DPS'] = {
                    {},
                },
                ['Downtime'] = {
                    {},
                },
            },
            ['Spells'] = {
                { name = "", gem = 1, },
                { name = "", gem = 2, },
                { name = "", gem = 3, },
                { name = "", gem = 4, },
                { name = "", gem = 5, },
                { name = "", gem = 6, },
                { name = "", gem = 7, },
                { name = "", gem = 8, },
                { name = "", gem = 9, },
                { name = "", gem = 10, },
                { name = "", gem = 11, },
                { name = "", gem = 12, },
            },
        },
        ['Healer'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    {},
                },
                ['Debuff'] = {
                    {},
                },
                ['Heal'] = {
                    {},
                },
                ['DPS'] = {
                    {},
                },
                ['Downtime'] = {
                    {},
                },
            },
            ['Spells'] = {
                { name = "", gem = 1, },
                { name = "", gem = 2, },
                { name = "", gem = 3, },
                { name = "", gem = 4, },
                { name = "", gem = 5, },
                { name = "", gem = 6, },
                { name = "", gem = 7, },
                { name = "", gem = 8, },
                { name = "", gem = 9, },
                { name = "", gem = 10, },
                { name = "", gem = 11, },
                { name = "", gem = 12, },
            },
        },
        ['Hybrid'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    {},
                },
                ['Debuff'] = {
                    {},
                },
                ['Heal'] = {
                    {},
                },
                ['DPS'] = {
                    {},
                },
                ['Downtime'] = {
                    {},
                },
            },
            ['Spells'] = {
                { name = "", gem = 1, },
                { name = "", gem = 2, },
                { name = "", gem = 3, },
                { name = "", gem = 4, },
                { name = "", gem = 5, },
                { name = "", gem = 6, },
                { name = "", gem = 7, },
                { name = "", gem = 8, },
                { name = "", gem = 9, },
                { name = "", gem = 10, },
                { name = "", gem = 11, },
                { name = "", gem = 12, },
            },
        },
        ['DefaultConfig'] = {
            ['Mode'] = '1',
        },
    },
}
