return {
    ['Modes'] = {
        ['Heal'] = 0,
        ['DOT'] = 1,
        ['TLP'] = 2,
    },
    ['ItemSets'] = {
        ['Epic'] = {
            [1] = "Crafted Talisman of Fates",
            [2] = "Blessed Spiritstaff of the Heyokah",
        },
    },
    ['AbilitySets'] = {
        ["FocusSpell"] = {
            -- Focus Spell - Lower Levels Mix in Single Target, Higher Prefer Group Target
            [1] = "Inner Fire",                    -- Level 1 - Single
            [2] = "Talisman of Tnarg",             -- Level 32 - Single
            [3] = "Talisman of Altuna",            -- Level 40 - Single 
            [4] = "Talisman of Kragg",             -- Level 55 - Single
            [5] = "Khura's Focusing",              -- Level 60 - Group
            [6] = "Focus of the Seventh",          -- Level 65 - Group
            [7] = "Talisman of Wunshi",            -- Level 70 - Group
            [8] = "Talisman of the Dire",          -- Level 75 - Group
            [9] = "Talisman of the Bloodworg",     -- Level 80 - Group
            [10] = "Talisman of Unity",             -- Level 85 - Group
            [11] = "Talisman of Soul's Unity",      -- Level 90 - Group
            [12] = "Talisman of Kolos' Unity",      -- Level 95 - Group
            [13] = "Talisman of the Courageous",    -- Level 100 - Group
            [14] = "Talisman of the Doomscale",     -- Level 105 - Group
            [15] = "Talisman of the Wulthan",       -- Level 110 - Group
            [16] = "Unity of the Kromrif",          -- Level 111 - Single
            [17] = "Talisman of the Ry'Gorr",       -- Level 115 - Group
            [18] = "Unity of the Vampyre",          -- Level 116 - Single
            [19] = "Talisman of the Usurper",       -- Level 120 - Group
            [20] = "Celeritous Unity",              -- Level 121 - Single
            [21] = "Talisman of the Heroic",      -- Level 125 - Group
        },
        ["RunSpeedBuff"] = {
            -- Run Speed Buff - 9 - 74
            [1] = "Spirit of Tala'Tak",
            [2] = "Spirit of Bih`Li",
            [3] = "Pack Shrew",
            [4] = "Spirit of Wolf",
        },
        ["HasteBuff"] = {
            -- Haste Buff - 26 - 64
            [1] = "Talisman of Celerity",
            [2] = "Swift Like the Wind",
            [3] = "Celerity",
            [4] = "Quickness",
        },
        ["GrowthBuff"] = {
            -- Growth Buff 111 -> 81
            [1] = "Overwhelming Growth",
            [2] = "Fervent Growth",
            [3] = "Frenzied Growth",
            [4] = "Savage Growth",
            [5] = "Ferocious Growth",
            [6] = "Rampant Growth",
            [7] = "Unfettered Growth",
            [8] = "Untamed Growth",
            [9] = "Wild Growth"
        },
        ["LowLvlStaminaBuff"] = {
            -- Low Level Stamina Buff --- Use under Level 85
            [1] = "Spirit of Bear",
            [2] = "Spirit of Ox",
            [3] = "Health",
            [4] = "Stamina",
            [5] = "Riotous Health",
            [6] = "Talisman of the Brute",
            [7] = "Endurance of the Boar",
            [8] = "Talisman of the Boar",
            [9] = "Spirit of Fortitude",
            [10] = "Talisman of Fortitude",
            [11] = "Talisman of Persistence",
            [12] = "Talisman of Vehemence",
            [13] = "Spirit of Vehemence",
        },
        ["LowLvlAttackBuff"] = {
            -- Low Level Attack Buff --- user under level 85
            [1] = "Primal Avatar",
            [2] = "Ferine Avatar",
            [3] = "Champion",
        },
        ["LowLvlStrBuff"] = {
            -- Low Level Strength Buff -- use under evel 85
            [1] = "Talisman of Might",
            [2] = "Spirit of Might",
            [3] = "Talisman of the Diaku",
            [4] = "Strength of the Diaku",
            [5] = "Voice of the Berserker",
            [6] = "Talisman of the Rhino",
            [7] = "Maniacal Strength",
            [8] = "Primal Essence",
            [9] = "Strength",
            [10] = "Rage",
            [11] = "Furious Strength",
            [12] = "Tumultuous Strength",
            [13] = "Fury",
            [14] = "Raging Strength",
            [15] = "Frenzy",
            [16] = "Spirit Strength",
            [17] = "Burst of Strength",
        },
        ["LowLvlDexBuff"] = {
            -- Low Level Dex Buff -- use under level 70
            [1] = "Talisman of the Raptor",
            [2] = "Mortal Deftness",
            [3] = "Dexterity",
            [4] = "Deftness",
            [5] = "Rising Dexterity",
            [6] = "Spirit of Monkey",
            [7] = "Dexterous Aura",
        },
        ["LowLvlAgiBuff"] = {
            --- Low Level AGI Buff -- Use under level 85
            [1] = "Talisman of Foresight",
            [2] = "Preternatural Foresight",
            [3] = "Talisman of Sense",
            [4] = "Spirit of Sense",
            [5] = "Talisman of the Wrulan",
            [6] = "Agility of the Wrulan",
            [7] = "Talisman of the Cat",
            [8] = "Deliriously Nimble",
            [9] = "Agility",
            [10] = "Nimble",
            [11] = "Spirit of Cat",
            [12] = "Feet like Cat",
        },
        ["AEMaloSpell"] = {
            [1] = "Wind of Malisene",
            [2] = "Wind of Malis",
        },
        ["MaloSpell"] = {
            -- AA Starts at LVL 75
            [1] = "Malosinera",
            [2] = "Malosinetra",
            [3] = "Malosinise",
            [4] = "Malos",
            [5] = "Malosinia",
            [6] = "Malo",
            [7] = "Malosini",
            [8] = "Malosi",   
            [9] = "Malaisement",
            [10] = "Malaise",
        },
        ["AESlowSpell"] = {
            [1] = "Tigir's Insects",
        },
        ["SlowSpell"] = {
            [1] = "Balance of Discord",
            [2] = "Balance of the Nihil",
            [3] = "Turgur's Insects",
            [4] = "Togor's Insects",
            [5] = "Tagar's Insects",
            [6] = "Walking Sleep",
            [7] = "Drowsy",
        },
        ["DieaseSlow"] = {
            [1] = "Cloud of Grummus",
            [2] = "Plague of Insects",
        },
        ["GroupHealProcBuff"] = {
            [1] = "Watchful Spirit",
            [2] = "Responsive Spirit",
            [3] = "Attentive Spirit",
        },
        ["SelfHealProcBuff"] = {
            -- Self Heal Ward Spells -- LVL 115 -> LVL 80
            [1] = "Ward of Heroic Deeds",
            [2] = "Ward of Recuperation",
            [3] = "Ward of Remediation",
            [4] = "Ward of Regeneration",
            [5] = "Ward of Rejuvenation",
            [6] = "Ward of Reconstruction",
            [7] = "Ward of Recovery",
            [8] = "Ward of Restoration",
            [9] = "Ward of Resurgence",
            [10] = "Ward of Rebirth",
        },
        ["DichoSpell"] = {
            [1] = "Ecliptic Roar",
            [2] = "Composite Roar",
            [3] = "Dissident Roar",
            [4] = "Roar of the Lion",
        },
        ["MeleeProcBuff"] = {
            -- Melee Proc Buff - Level 50 - 111
            -- To be used when the Shaman does not have Dicho
            [1] = "Talisman of the Manul",
            [2] = "Talisman of the Kerran",
            [3] = "Talisman of the Lioness",
            [4] = "Talisman of the Sabretooth",
            [5] = "Talisman of the Leopard",
            [6] = "Talisman of the Snow Leopard",
            [7] = "Talisman of the Lion",
            [8] = "Talisman of the Tiger",
            [9] = "Talisman of the Lynx",
            [10] = "Talisman of the Cougar",
            [11] = "Talisman of the Panther",
            -- Below Level 71 This is a single target buff
            [12] = "Spirit of the Panther",
            [13] = "Spirit of the Leopard",
            [14] = "Spirit of the Jaguar",
            [15] = "Spirit of the Puma",
        },
        ["SlowProcBuff"] = {
            -- Slow Proc Buff for MA - Level 68 - 122
            [1] = "Moroseness",
            [2] = "Melancholy",
            [3] = "Ennui",
            [4] = "Incapacity",
            [5] = "Sluggishness",
            [6] = "Fatigue",
            [7] = "Apathy",
            [8] = "Lethargy",
            [9] = "Listlessness",
            [10] = "Languor",
            [11] = "Lassitude",
            [12] = "Lingering Sloth",
        },
        ["PackSelfBuff"] = {
            -- Pack Self Buff - Level 90 - 115
            --- Ignoring the LVL 85 Call the Pack buff due to the decrease in mana per tick.
            [1] = "Pack of Ancestral Beasts",
            [2] = "Pack of Lunar Wolves",
            [3] = "Pack of The Black Fang",
            [4] = "Pack of Mirtuk",
            [5] = "Pack of Olesira",
            [6] = "Pack of Kriegas",
            [7] = "Pack of Hilnaah",
            [8] = "Pack of Wurt",
        },
        ["AllianceBuff"] = {
            [1] = "Ancient Alliance",
            [2] = "Ancient Coalition",
        },
        ["IcefixSpell"] = {
            -- Eradicate Curse
            [1] = "Remove Greater Curse",
            [2] = "Eradicate Curse",
        },
        ["RecklessHeal"] = {
            [1] = "Reckless Reinvigoration",
            [2] = "Reckless Resurgence",
            [3] = "Reckless Renewal",
            [4] = "Reckless Rejuvenation",
            [5] = "Reckless Regeneration",
            [6] = "Reckless Restoration",
            [7] = "Reckless Remedy",
            [8] = "Reckless Mending",
            [9] = "Qirik's Mending",
            [10] = "Dannal's Mending",
            [11] = "Gemmi's Mending",
            [12] = "Ahnkaul's Mending",
            [13] = "Ancient: Wilslik's Mending",
            [14] = "Yoppa's Mending",
            [15] = "Daluda's Mending",
            [16] = "Tnarg's Mending",
            [17] = "Chloroblast",
            [18] = "Kragg's Salve",
            [19] = "Superior Healing",
            [20] = "Spirit Salve",
            [21] = "Greater Healing",
            [22] = "Healing",
            [23] = "Light Healing",
            [24] = "Minor Healing",
        },
        ["AESpiritualHeal"] = {
            -- LVL 115-LVL100
            [1] = "Spiritual Shower",
            [2] = "Spiritual Squall",
            [3] = "Spiritual Swell",
            [4] = "Spiritual Surge",
        },
        ["RecourseHeal"] = {
            --- RecourseHeal LVL115-87
            [1] = "Grayleaf's Recourse",
            [2] = "Rowain's Recourse",
            [3] = "Zrelik's Recourse",
            [4] = "Eyrzekla's Recourse",
            [5] = "Krasir's Recourse",
            [6] = "Blezon's Recourse",
            [7] = "Gotikan's Recourse",
            [8] = "Qirik's Recourse",
        },
        ["InterventionHeal"] = {
            -- Intervention Heal LVL 113 -> 78
            [1] = "Immortal Intervention",
            [2] = "Primordial Intervention",
            [3] = "Prehistoric Intervention",
            [4] = "Historian's Intervention",
            [5] = "Antecessor's Intervention",
            [6] = "Progenitor's Intervention",
            [7] = "Ascendant's Intervention",
            [8] = "Antecedent's Intervention",
            [9] = "Ancestral Intervention",
            [10] = "Antediluvian Intervention",
        },
        ["GroupRenewalHoT"] = {
            -- LVL 115->70 -- Prior to 70 Breath of Trushar as a non-group HoTs will be used including the
            --- the Torpor/Stoicism line. LVL 44 is the lowest level.
            [1] = "Reverie of Renewal",
            [2] = "Spirit of Renewal",
            [3] = "Spectre of Renewal",
            [4] = "Cloud of Renewal",
            [5] = "Shear of Renewal",
            [6] = "Wisp of Renewal",
            [7] = "Phantom of Renewal",
            [8] = "Penumbra of Renewal",
            [9] = "Shadow of Renewal",
            [10] = "Shade of Renewal",
            [11] = "Specter of Renewal",
            [12] = "Ghost of Renewal",
            [13] = "Spiritual Serenity",
            [14] = "Breath of Trushar",
            [15] = "Quiescence",
            [16] = "Torpor",
            [17] = "Stoicism",
        },
        ["CanniSpell"] = {
            -- Convert Health to Mana - Level  23 - 113
            [1] = "Hoary Agreement",
            [2] = "Ancient Bargain",
            [3] = "Tribal Bargain",
            [4] = "Tribal Pact",
            [5] = "Ancestral Pact",
            [6] = "Ancestral Arrangement",
            [7] = "Ancestral Covenant",
            [8] = "Ancestral Obligation",
            [9] = "Ancestral Hearkening",
            [10] = "Ancestral Bargain",
            [11] = "Ancient: Ancestral Calling",
            [12] = "Pained Memory",
            [13] = "Ancient: Chaotic Pain",
            [14] = "Cannibalize IV",
            [15] = "Cannibalize",
        },
        ["CureSpell"] = {
            [1] = "Blood of Mayong",
            [2] = "Blood of Tevik",
            [3] = "Blood of Rivans",
            [4] = "Blood of Sanera",
            [5] = "Blood of Klar",
            [6] = "Blood of Corbeth",
            [7] = "Blood of Avoling",
            [8] = "Blood of Nadox",
        },
        ["TwinHealNuke"] = {
            -- Nuke the MA Not the assist target - Levels 85 - 115
            [1] = "Gelid Gift",
            [2] = "Polar Gift",
            [3] = "Wintry Gift",
            [4] = "Frostbitten Gift",
            [5] = "Glacial Gift",
            [6] = "Frigid Gift",
            [7] = "Freezing Gift",
            [8] = "Frozen Gift",
            [9] = "Frost Gift",
        },
        ["PoisonNuke"] = {
            -- Poison Nuke LVL115->LVL34
            [1] = "Red Eye's Spear of Venom",
            [2] = "Fleshrot's Spear of Venom",
            [3] = "Narandi's Spear of Venom",
            [4] = "Nexona's Spear of Venom",
            [5] = "Serisaria's Spear of Venom",
            [6] = "Slaunk's Spear of Venom",
            [7] = "Hiqork's Spear of Venom",
            [8] = "Spinechiller's Spear of Venom",
            [9] = "Severilous' Spear of Venom",
            [10] = "Vestax's Spear of Venom",
            [11] = "Ahnkaul's Spear of Venom",
            [12] = "Yoppa's Spear of Venom",
            [13] = "Spear of Torment",
            [14] = "Blast of Venom",
            [15] = "Shock of Venom",
            [16] = "Blast of Poison",
            [17] = "Shock of the Tainted",
        },
        ["FastPoisonNuke"] = {
            -- Fast Poison Nuke LVL115->LVL73
            [1] = "Oka's Bite",
            [2] = "Ander's Bite",
            [3] = "Direfang's Bite",
            [4] = "Mawmun's Bite",
            [5] = "Reefmaw's Bite",
            [6] = "Seedspitter's Bite",
            [7] = "Bite of the Grendlaen",
            [8] = "Bite of the Blightwolf",
            [9] = "Bite of the Ukun",
            [10] = "Bite of the Brownie",
            [11] = "Sting of the Queen",
        },
        ["FrostNuke"] = {
            --- rostNuke - Levels 4 - 114
            [1] = "Ice Barrage",
            [2] = "Heavy Sleet",
            [3] = "Ice Salvo",
            [4] = "Ice Shards",
            [5] = "Ice Squall",
            [6] = "Ice Burst",
            [7] = "Ice Mass",
            [8] = "Ice Floe",
            [9] = "Ice Sheet",
            [10] = "Tundra Crumble",
            [11] = "Glacial Avalanche",
            [12] = "Ice Age",
            [13] = "Velium Strike",
            [14] = "Ice Strike",
            [15] = "Blizzard Blast",
            [16] = "Winter's Roar",
            [17] = "Frost Strike",
            [18] = "Spirit Strike",
            [19] = "Frost Rift",
        },
        ["ChaoticDoT"] = {
            -- Long Dot(42s) LVL 109 -> LVL104
            -- Two resist types because it throws 2 dots
            -- Stacking: Nectar of Pain - Stacking: Blood of Saryrn 
            [1] = "Chaotic Poison",
            [2] = "Chaotic Venom",
            [3] = "Chaotic Venin",
            [4] = "Chaotic Toxin",
        },
        ["PandemicDot"] = {
            -- Pandemic Dot Long Dot(84s) Level 103 - 108
            -- Two resist types because it throws 2 dots    
            -- Stacking: Kralbor's Pandemic  -    Stacking: Breath of Ultor
            [1] = "Skraiw's Pandemic",
            [2] = "Elkikatar's Pandemic",
            [3] = "Hemocoraxius' Pandemic",
            [4] = "Bledrek's Pandemic",
            [5] = "Doomshade's Pandemic",
            [6] = "Tegi Pandemic",
        },
        ["MaloDot"] = {
            -- Malo Dot Stacking: Yubai's Affliction - LongDot(96s) Level 99 - 114
            [1] = "Svartmane's Malosinara",
            [2] = "Rirwech's Malosinata",
            [3] = "Livio's Malosenia",
            [4] = "Falhotep's Malosenia",
            [5] = "Txiki's Malosinara",
            [6] = "Krizad's Malosinera",
        },
        ["CurseDoT1"] = {
            -- Curse Dot 1 Stacking: Curse - Long Dot(30s) - Level 34 - 115
            [1] = "Malediction",
            [2] = "Obeah",
            [3] = "Evil Eye",
            [4] = "Jinx",
            [5] = "Garugaru",
            [6] = "Naganaga",
            [7] = "Hoodoo",
            [8] = "Hex",
            [9] = "Mojo",
            [10] = "Pocus",
            [11] = "Juju",
            [12] = "Curse of Sisslak",
            [13] = "Bane",
            [14] = "Anathema",
            [15] = "Odium",
            [16] = "Curse",
        },
        ["CurseDoT2"] = {
            ---, Stacking: Enalam's Curse - Long Dot(54s) - 100 - 115
            [1] = "Lenrel's Curse",
            [2] = "Marlek's Curse",
            [3] = "Erogo's Curse",
            [4] = "Sraskus' Curse",
            [5] = "Enalam's Curse",
            [6] = "Fandrel's Curse",
        },
        ["FastPoisonDoT"] = {
            ---, Stacking: Blood of Saryrn - Fast Dot(12s) - Level 89 - 115
            [1] = "Korsh's Venom",
            [2] = "Namdrows' Venom",
            [3] = "Xalgoti's Venom",
            [4] = "Mawmun's Venom",
            [5] = "Serpentil's Venom",
            [6] = "Banescale's Venom",
            [7] = "Stranglefang's Venom",
            [8] = "Undaleen's Venom",
        },
        ["SaryrnDot"] = {
            -- Stacking: Blood of Saryrn - Long Dot(42s) - Level 8 - 115
            [1] = "Desperate Vampyre Blood",
            [2] = "Restless Blood",
            [3] = "Reef Crawler Blood",
            [4] = "Phase Spider Blood",
            [5] = "Naeya Blood",
            [6] = "Spinechiller Blood",
            [7] = "Blood of Jaled'Dar",
            [8] = "Blood of Kerafyrm",
            [9] = "Vengeance of Ahnkaul",
            [10] = "Blood of Yoppa",
            [11] = "Blood of Saryrn",
            [12] = "Ancient: Scourge of Nife",
            [13] = "Bane of Nife",
            [14] = "Envenomed Bolt",
            [15] = "Venom of the Snake",
            [16] = "Envenomed Breath",
            [17] = "Tainted Breath",
        },
        ["FastDiseaseDoT"] = {
            -- Fast Disease Dot Stacking: Breath of Ultor - Fast Dot(12s) - Level 87 - 115
            [1] = "Krizad's Malady",
            [2] = "Cruor's Malady",
            [3] = "Malvus's Malady",
            [4] = "Hoshkar's Malady",
            [5] = "Sephry's Malady",
            [6] = "Elsrop's Malady",
            [7] = "Giaborn's Malady",
            [8] = "Nargul's Malady",
        }, 
        ["UltorDot"] = {
            ---, Stacking: Breath of Ultor - Long Dot(84s) - Level 4 - 111
            [1] = "Breath of the Hotariton",
            [2] = "Breath of the Tegi",
            [3] = "Breath of Bledrek",
            [4] = "Breath of Hemocoraxius",
            [5] = "Breath of Natigo",
            [6] = "Breath of Silbar",
            [7] = "Breath of the Shiverback",
            [8] = "Breath of Queen Malarian",
            [9] = "Breath of Big Bynn",
            [10] = "Breath of Ternsmochin",
            [11] = "Breath of Wunshi",
            [12] = "Breath of Ultor",
            [13] = "Pox of Bertoxxulous",
            [14] = "Plague",
            [15] = "Scourge",
            [16] = "Affliction",
            [17] = "Sicken",
        },
        ["NectarDot"] = {
            --- Nectar Dot Line
            [1] = "Nectar of Obscurity",
            [2] = "Nectar of Pain",
            [3] = "Nectar of Agony",
            [4] = "Nectar of Rancor",
            [5] = "Nectar of the Slitheren",
            [6] = "Nectar of Torment",
            [7] = "Nectar of Sholoth",
            [8] = "Nectar of Anguish",
            [9] = "Nectar of Woe",
            [10] = "Nectar of Suffering",
            [11] = "Nectar of Misery",
            [12] = "Nectar of Destitution",
        },
        ["PetSpell"] = {
            -- Pet Spell - 32 - 112
            [1] = "Suja's Faithful",
            [2] = "Diabo Sivuela's Faithful",
            [3] = "Grondo's Faithful",
            [4] = "Mirtuk's Faithful",
            [5] = "Olesira's Faithful",
            [6] = "Kriegas' Faithful",
            [7] = "Hilnaah's Faithful",
            [8] = "Wurt's Faithful",
            [9] = "Aina's Faithful",
            [10] = "Vegu's Faithful",
            [11] = "Kyrah's Faithful",
            [12] = "Farrel's Companion",
            [13] = "True Spirit",
            [14] = "Spirit of the Howler",
            [15] = "Frenzied Spirit",
            [16] = "Guardian spirit",
            [17] = "Vigilant Spirit",
            [18] = "Companion Spirit",
        },
        ["PetBuffSpell"] = {
            ---Pet Buff Spell - 50 - 112
            [1] = "Spirit Augmentation",
            [2] = "Spirit Reinforcement",
            [3] = "Spirit Bracing",
            [4] = "Spirit Bolstering",
            [5] = "Spirit Quickening",
        },
        ["TLPCureDisease"] = {
            [1] = "Cure Disease",
            [2] = "Counteract Disease",
            [3] = "Eradicate Disease",
        },
        ["TLPCurePoison"] = {
            [1] = "Counteract Poison",
            [2] = "Abolish Poison",
            [3] = "Eradicate Poison",
        },
    },
    ['Rotations'] = {
    },

    ['DefaultConfig'] = {
    },
}