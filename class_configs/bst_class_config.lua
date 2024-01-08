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
            "Savage Lord's Totem",             -- Epic    -- Epic 1.5
            "Spiritcaller Totem of the Feral", -- Epic    -- Epic 2.0
        },
    },
    ['AbilitySets'] = {
        ['SwarmPet'] = {
            -- Swarm Pet
            "Bestial Empathy",       -- Level 68
            "Bark at the Moon",      -- Level 75
            "Howl at the Moon",      -- Level 80
            "Haergen's Feralgia",    -- Level 85
            "Tuzil's Feralgia",      -- Level 90
            "Yahnoa's Feralgia",     -- Level 95
            "Kesar's Feralgia",      -- Level 100
            "Krenk's Feralgia",      -- Level 105
            "Akalit's Feralgia",     -- Level 110
            "Griklor's Feralgia",    -- Level 115
            "Ander's Feralgia",      -- Level 120
            "SingleMalt's Feralgia", -- Level 125
        },
        ['FrozenPoi'] = {
            -- Cold/Poison Nuke Fast Cast
            "Frozen Venom",      -- Level 84
            "Frozen Venin",      -- Level 89
            "Frozen Cyanin",     -- Level 94
            "Frozen Carbomate",  -- Level 99
            "Frozen Miasma",     -- Level 103
            "Frozen Toxin",      -- Level 108
            "Frozen Malignance", -- Level 113
            "Frozen Blight",     -- Level 118
            "Frozen Creep",      -- Level 123
        },
        ['Maelstrom'] = {
            -- Cold/Poison/Disease Nuke Fast Cast
            "Kron's Maelstrom",      -- Level 90
            "Bale's Maelstrom",      -- Level 95
            "Nak's Maelstrom",       -- Level 100
            "Visoracius' Maelstrom", -- Level 105
            "Beramos' Maelstrom",    -- Level 110
            "Vkjen's Maelstrom",     -- Level 115
            "Va Xakra's Maelstrom",  -- Level 120
            "Rimeclaw's Maelstrom",  -- Level 125
        },
        ['PoiBite'] = {
            -- Poison Nuke Fast Cast
            "Bite of the Empress",  -- Level 73
            "Bite of the Borrower", -- Level 78
            "Bite of the Vitrik",   -- Level 83
            "Sarsez' Bite",         -- Level 88
            "Rotsil's Bite",        -- Level 93
            "Poantaar's Bite",      -- Level 98
            "Kreig's Bite",         -- Level 103
            "Mawmun's Bite",        -- Level 108
            "Bloodmaw's Bite",      -- Level 113
            "Zelniak's Bite",       -- Level 118
            "Mortimus' Bite",       -- Level 123
        },
        ['Icelance1'] = {
            -- Lance 1 Timer 7 Ice Nuke Fast Cast
            "Blast of Frost",        -- Level 12 - Timer 7
            "Frost Shard",           -- Level 47 - Timer 7
            "Blizzard Blast",        -- Level 59 - Timer ???
            "Frost Spear",           -- Level 63 - Timer 7
            "Ancient: Frozen Chaos", -- Level 65 - Timer 7
            "Ancient: Savage Ice",   -- Level 70 - Timer 7
            "Jagged Torrent",        -- Level 79 - Timer 7
            "Glacial Lance",         -- Level 89 - Timer 7
            "Kromrif Lance",         -- Level 99 - Timer 7
            "Frostbite Lance",       -- Level 107 - Timer 7
            "Crystalline Lance",     -- Level 117 - Timer 7
            "Ankexfen Lance",        -- Level 122 - Timer 7
        },
        ['Icelance2'] = {
            -- Lance 2 Timer 11 Ice Nuke Fast Cast
            "Ice Spear",       -- Level 33 - Timer 11
            "Ice Shard",       -- Level 54 - Timer 11
            "Trushar's Frost", -- Level 65 - Timer 11
            "Glacier Spear",   -- Level 69 - Timer 11
            "Spiked Sleet",    -- Level 74 - Timer 11
            "Frigid Lance",    -- Level 84 - Timer 11
            "Frostrift Lance", -- Level 94 - Timer 11
            "Kromtus Lance",   -- Level 102 - Timer 11
            "Restless Lance",  -- Level 112 - Timer 11
        },
        ['EndemicDot'] = {
            -- Disease DoT Instant Cast
            "Sicken",                -- Level 14
            "Malaria",               -- Level 40
            "Plague",                -- Level 65
            "Festering Malady",      -- Level 70
            "Fever Spike",           -- Level 72
            "Fever Surge",           -- Level 77
            "Tsetsian Endemic",      -- Level 82
            "Shiverback Endemic",    -- Level 87
            "Silbar's Endemic",      -- Level 92
            "Natigo's Endemic",      -- Level 97
            "Hemocoraxius' Endemic", -- Level 102
            "Elkikatar's Endemic",   -- Level 107
            "Neemzaq's Endemic",     -- Level 112
            "Vampyric Endemic",      -- Level 117
            "Fevered Endemic",       -- Level 122
        },
        ['Blooddot'] = {

            -- Poison DoT Instant Cast
            "Tainted Breath",      -- Level 19
            "Envenomed Breath",    -- Level 35
            "Venom of the Snake",  -- Level 52
            "Scorpion Venom",      -- Level 61
            "Turepta Blood",       -- Level 65
            "Chimera Blood",       -- Level 66
            "Diregriffon's Bite",  -- Level 71
            "Falrazim's Gnashing", -- Level 76
            "Ikaav Blood",         -- Level 81
            "Spinechiller Blood",  -- Level 90
            "Binaesa Blood",       -- Level 91
            "Asp Blood",           -- Level 96
            "Glistenwing Blood",   -- Level 101
            "Polybiad Blood",      -- Level 106
            "Ikatiar's Blood",     -- Level 111
            "Akhevan Blood",       -- Level 116
            "Forgebound Blood",    -- Level 121
        },
        ['Colddot'] = {
            -- Cold DoT Instant Cast
            "Edoth's Chill",     -- Level 99
            "Kirchen's Chill",   -- Level 104
            "Ekron's Chill",     -- Level 109
            "Endaroky's Chill",  -- Level 114
            "Sylra Fris' Chill", -- Level 119
            "Lazam's Chill",     -- Level 124

        },
        ['SlowSpell'] = {
            -- Slow Spell
            "Drowsy",          -- Level 20
            "Sha's Lethargy",  -- Level 50
            "Sha's Advantage", -- Level 60
            "Sha's Revenge",   -- Level 65
            "Sha's Legacy",    -- Level 70
            "Sha's Reprisal",  -- Level 87
        },
        ['DichoSpell'] = {
            -- Dicho Spell
            "Dichotomic Fury", -- Level 101
            "Dissident Fury",  -- Level 106
            "Composite Fury",  -- Level 111
            "Ecliptic Fury",   -- Level 116

        },
        ['HealSpell'] = {
            "Salve",               -- Level 1
            "Minor Healing",       -- Level 6
            "Light Healing",       -- Level 18
            "Healing",             -- Level 28
            "Greater Healing",     -- Level 38
            "Spirit Salve",        -- Level 48
            "Chloroblast",         -- Level 59
            "Trushar's Mending",   -- Level 65
            "Muada's Mending",     -- Level 67
            "Minohten Mending",    -- Level 72
            "Daria's Mending",     -- Level 77
            "Cadmael's Mending",   -- Level 82
            "Jorra's Mending",     -- Level 87
            "Mending of the Izon", -- Level 92
            "Jaerol's Mending",    -- Level 97
            "Sabhattin's Mending", -- Level 102
            "Deltro's Mending",    -- Level 107
            "Bethun's Mending",    -- Level 112
            "Korah's Mending",     -- Level 117
            "Thornhost's Mending", -- Level 122
        },
        ['PetHealSpell'] = {
            "Sharik's Replenishing",   -- Level 9
            "Keshuval's Rejuvenation", -- Level 15
            "Herikol's Soothing",      -- Level 27
            "Yekan's Recovery",        -- Level 36
            "Vigor of Zehkes",         -- Level 49
            "Aid of Khurenz",          -- Level 52
            "Sha's Restoration",       -- Level 55
            "Healing of Sorsha",       -- Level 61
            "Healing of Mikkily",      -- Level 66
            "Healing of Uluanes",      -- Level 71
            "Salve of Feldan",         -- Level 76
            "Salve of Reshan",         -- Level 81
            "Salve of Sevna",          -- Level 86
            "Salve of Yubai",          -- Level 91
            "Salve of Blezon",         -- Level 96
            "Salve of Clorith",        -- Level 101
            "Salve of Artikla",        -- Level 106
            "Salve of Tobart",         -- Level 111
            "Salve of Jaegir",         -- Level 116
            "Salve of Homer",          -- Level 121
        },
        ['PetSpell'] = {
            "Spirit of Sharik",     -- Level 8
            "Spirit of Khaliz",     -- Level 15
            "Spirit of Keshuval",   -- Level 21
            "Spirit of Herikol",    -- Level 30
            "Spirit of Yekan",      -- Level 39
            "Spirit of Kashek",     -- Level 46
            "Spirit of Omakin",     -- Level 54
            "Spirit of Zehkes",     -- Level 56
            "Spirit of Khurenz",    -- Level 58
            "Spirit of Khati Sha",  -- Level 60
            "Spirit of Arag",       -- Level 62
            "Spirit of Sorsha",     -- Level 64
            "Spirit of Alladnu",    -- Level 68
            "Spirit of Rashara",    -- Level 70
            "Spirit of Uluanes",    -- Level 73
            "Spirit of Silverwing", -- Level 78
            "Spirit of Hoshkar",    -- Level 83
            "Spirit of Averc",      -- Level 88
            "Spirit of Kolos",      -- Level 93
            "Spirit of Lachemit",   -- Level 98
            "Spirit of Avalit",     -- Level 103
            "Spirit of Akalit",     -- Level 108
            "Spirit of Blizzent",   -- Level 113
            "Spirit of Panthea",    -- Level 118
            "Spirit of Shae",       -- Level 123
        },
        [','] = {
            --Pet Group End Regen Proc*
            "Fatiguing Bite",
            "Exhausting Bite",
            "Depleting Bite",
            "Wearying Bite",
            "Sapping Bite",
        },
        ['PetSpellGuard'] = {
            "Spellbreaker's Guard",
            "Spellbreaker's Bulwark",
            "Spellbreaker's Aegis",
            "Spellbreaker's Rampart",
            "Spellbreaker's Armor",
            "Spellbreaker's Ward",
            "Spellbreaker's Palisade",
            "Spellbreaker's Keep",
            "Spellbreaker's Citadel",
            "Spellbreaker's Fortress",
            "Spellbreaker's Synergy",
        },
        ['PetSlowProc'] = {
            --Pet Slow Proc*
            "Steeltrap Jaws",
            "Lockfang Jaws",
            "Fellgrip Jaws",
            "Deadlock Jaws",
        },
        ['PetOffenseBuff'] = {
            --Pet DPS buff*
            "Neivr's Aggression",
            "Mea's Aggression",
            "Plakt's Aggression",
            "Sekmoset's Aggression",
            "Virzak's Aggression",
            "Horasug's Aggression",
            "Panthea's Aggression",
            "Magna's Aggression",
        },
        ['PetDefenseBuff'] = {

            --Pet Tanking buff*
            "Neivr's Protection",
            "Mea's Protection",
            "Plakt's Protection",
            "Sekmoset's Protection",
            "Virzak's Protection",
            "Horasug's Protection",
            "Panthea's Protection",
            "Magna's Protection",
        },
        ['PetHaste'] = {
            --Pet Haste*
            "Yekan's Quickening",
            "Bond of The Wild",
            "Omakin's Alacrity",
            "Sha's Ferocity",
            "Arag's Celerity",
            "Growl of the Beast",
            "Unparalleled Voracity",
            "Peerless Penchant",
            "Unrivaled Rapidity",
            "Incomparable Velocity",
            "Exceptional Velocity",
            "Extraordinary Velocity",
            "Tremendous Velocity",
            "Astounding Velocity",
            "Unsurpassed Velocity",
            "Insatiable Voracity",


        },
        ['PetGrowl'] = {
            --Pet Growl Buff* 69-115
            "Growl of the Panther",
            "Growl of the Puma",
            "Growl of the Jaguar",
            "Growl of the Tiger",
            "Growl of the Lion",
            "Growl of the Snow Leopard",
            "Growl of the Leopard",
            "Growl of the Sabretooth",
            "Growl of the Lioness",
            "Growl of the Clouded Leopard",
        },
        ['PetHealProc'] = {
            --Pet Heal proc buff*
            "Protective Warder",
            "Sympathetic Warder",
            "Convivial Warder",
            "Mending Warder",
            "Invigorating Warder",
            "Empowering Warder",
            "Bolstering Warder",
            "Friendly Pet",
        },
        ['PetDamageProc'] = {
            "Spirit of Shoru",
            "Spirit of Lightning",
            "Spirit of the Blizzard",
            "Spirit of Inferno",
            "Spirit of the Scorpion",
            "Spirit of Vermin",
            "Spirit of Wind",
            "Spirit of the Storm",
            "Spirit of Snow",
            "Spirit of Flame",
            "Spirit of Rellic",
            "Spirit of Irionu",
            "Spirit of Oroshar",
            "Spirit of Lairn",
            "Spirit of Jeswin",
            "Spirit of Vaxztn",
            "Spirit of Kron",
            "Spirit of Bale",
            "Spirit of Nak",
            "Spirit of Visoracius",
            "Spirit of Beramos",
            "Spirit of Mandrikai",
            "Spirit of Siver",
            "Ally's Unity",
            "Comrade's Unity",
        },
        ['UnityBuff'] = {
            -- Unity Mana/Hp/End Regen + Atk/HP Buff*
            "Spiritual Unity",
            "Stormblood's Unity",
            "Feralist's Unity",
            "Reclaimer's Unity",
            "Chieftain's Unity",
            "Wildfang's Unity",

        },
        ['KillShotBuff'] = {
            --Pet Dmg Absorb + HoT buff*
            "Natural Collaboration",
            "Natural Cooperation",
            "Natural Affiliation",
            "Natural Cooperation",
            "Natural Alliance",
            "Symbiotic Alliance",
            "Warder's Alliance",
        },
        ['RunSpeedBuff'] = {
            "Spirit of wolf",
            -- Spirit of the Shrew Is Only 30% Speed Flat So Removed it from the List as its To Slow
            --   [] = "Spirit of the Shrew"],
            --   [] = "Pack Shrew"].
            "Spirit of Tala'Tak",

        },
        ['ManaRegenBuff'] = {
            --Mana/Hp/End Regen Buff*
            "Spiritual Light",
            "Spiritual Radiance",
            "Spiritual Purity",
            "Spiritual Dominion",
            "Spiritual Ascendance",
            "Spiritual Enlightenment",
            "Spiritual Epiphany",
            "Spiritual Edification",
            "Spiritual Enhancement",
            "Spiritual Enrichment",
            "Spiritual Evolution",
            "Spiritual Elaboration",
            "Spiritual Empowerment",
            "Spiritual Enhancement",
            "Spiritual Insight",
            "Spiritual Erudition",
            "Spiritual Enduement",
        },
        ['AllianceDot'] = {
            -- Alliance Spell for Beastlords 100+
            "Venomous Alliance",    -- Level 101
            "Venomous Covenant",    -- Level 108
            "Venomous Coalition",   -- Level 113
            "Venomous Conjunction", -- Level 118
        },
        ['PetBlockSpell'] = {
            "Ward of Calliav",       -- Level 49
            "Guard of Calliav",      -- Level 58
            "Protection of Calliav", -- Level 64
            "Feral Guard",           -- Level 69
            "Mammoth-Hide Guard",    -- Level 71
            "Dragonscale Guard",     -- Level 76
            "Bulwark of Tri'Qaras",  -- Level 77
            "Spectral Rampart",      -- Level 88
            "Beastwood Rampart",     -- Level 93
            "Aegis of Nefori",       -- Level 99
            "Aegis of Japac",        -- Level 104
            "Aegis of Zeklor",       -- Level 109
            "Aegis of Orfur",        -- Level 114
            "Aegis of Rumblecrush",  -- Level 119
            "Aegis of Valorforged",  -- Level 124
        },
        ['PetBlockAuspice'] = {

            -- Pet Block Auspice - Timer 16
            "Auspice of Shadows",    -- Level 96
            "Auspice of Eternity",   -- Level 102
            "Auspice of Esianti",    -- Level 107
            "Auspice of Kildrukaun", -- Level 112
            "Auspice of Valia",      -- Level 117
        },
        ['PetHotSpell'] = {
            -- Pet Hot Spell
            "Minax's Mending",       -- Level 82
            "Wilap's Mending",       -- Level 87
            "Yurv's Mending",        -- Level 92
            "Huaene's Melioration",  -- Level 97
            "Tirik's Melioration",   -- Level 102
            "Virzak's Melioration",  -- Level 107
            "Kallis' Melioration",   -- Level 112
            "Cissela's Melioration", -- Level 117
        },
        ['PetPromisedSpell'] = {
            -- Pet Promised
            "Promised Mending",        -- Level 73
            "Promised Recovery",       -- Level 78
            "Promised Rejuvenation",   -- Level 83
            "Promised Wardmending",    -- Level 88
            "Promised Amendment",      -- Level 93
            "Promised Amelioration",   -- Level 98
            "Promised Invigoration",   -- Level 103
            "Promised Alleviation",    -- Level 108
            "Promised Healing",        -- Level 113
            "Promised Relief",         -- Level 118
            "Promised Reconstitution", -- Level 123
        },
        ['AvatarSpell'] = {
            -- Str Stam Dex Buff
            "Infusion of Spirit", -- Level 61
        },
        ['PetCrippleBite'] = {
            "Dire Bite",
        },
        ['SingleFocusSpell'] = {
            -- Focus Spells -
            -- Single target Talismans ( Like Focus)
            "Inner Fire",
            "Talisman of Tnarg",
            "Talisman of Altuna",
            "Talisman of Kragg",
            "Focus of Alladnu",
        },
        ['SingleAtkHPBuff'] = {
            --Atk+HP Buff* - Does Not Stack with Pally brells or Ranger Buff - is Middle ground Buff has HP & Atk
            "Spiritual Brawn",
            "Spiritual Strength",
        },
        ['SingleAtkBuff'] = {
            -- ATK Buff
            -- - Single Ferocity
            "Savagery",           -- Level 60
            "Ferocity",           -- Level 65
            "Ferocity of Irionu", -- Level 70
            "Ruthless Ferocity",  -- Level 75
            "Vicious Ferocity",   -- Level 80
            "Savage Ferocity",    -- Level 85
            "Callous Ferocity",   -- Level 90
            "Brutal Ferocity",    -- Level 92

        },

        ['GroupFocusSpell'] = {
            -- Group Focus Spells
            "Focus of Amilan",
            "Focus of Zott",
            "Focus of Yemall",
            "Focus of Emiq",
            "Focus of Klar",
            "Focus of Sanera",
            "Focus of Okasi",
            "Focus of Artikla",
            "Focus of Tobart",
            "Focus of Jaegir",
            "Focus of Skull Crusher",
        },
        ['GroupAtkHPBuff'] = {
            -- Group Attack+ Hp Buff
            "Spiritual Vigor",
            "Spiritual Vitality",
            "Spiritual Vim",
            "Spiritual Vivacity",
            "Spiritual Verve",
            "Spiritual Valor",
            "Spiritual Valiance",
            "Spiritual Vindication",
            "Spiritual Vivification",
            "Spiritual Vibrancy",
            "Spiritual Vehemence",
            "Spiritual Vigor",
            "Spiritual Valiancy",
        },
        ['GroupAtkBuff'] = {
            -- Group Ferocity
            "Shared Brutal Ferocity",    -- Level 95
            "Shared Merciless Ferocity", -- Level 100
        },
        ['EndRegenDisc'] = {
            "Respite",
            "Reprieve",
            "Rest",
            "Breather",
            "Hiatus",
            "Relax",
            "Night's Calming",
            "Convalesce",
        },
        ['Maul'] = {
            -- Maul Disc - This is Used with Beastlord Synergy Buffs
            "Rake",
            "Harrow",
            "Foray",
            "Rush",
            "Barrage",
            "Pummel",
            "Maul",
            "Mangle",
            "Batter",
            "Clobber",
            "Wallop",
        },
        ['SingleClaws'] = {
            --Single target claws*
            "Focused Clamor of Claws",

        },
        ['BeastialBuffDisc'] = {
            --Beastial Buff*
            "Bestial Vivisection",
            "Bestial Rending",
            "Bestial Evulsing",
            "Bestial Savagery",
            "Bestial Fierceness",
        },
        ['AEClaws'] = {

            "Flurry of Claws",
            "Tumult of Claws",
            "Clamor of Claws",
            "Tempest of Claws",
            "Storm of Claws",
            "Maelstrom of Claws",
            "Eruption of Claws",
            "Barrage of Claws",
        },
        ['HHEFuryDisc'] = {
            --HHE Burn Disc* - Dicho/Dissident Replace this @ 101
            "Nature's Fury",
            "Kolos' Fury",
            "Ruaabri's Fury",
        },
        ['DmgModDisc'] = {
            --All Skills Damage Modifier*
            "Bestial Fury Discipline",
            "Empathic Fury",
            "Savage Fury",
            "Savage Rage",
            "Savage Rancor",

        },
        ['EndRegenProcDisc'] = {
            "Reflexive Rending",
            "Reflexive Sundering",
            "Reflexive Riving",
        },
        ['Vindisc'] = {
            -- Vindication Disc
            "Al`ele's Vindication",
            "Venon's Vindication",
            "Ikatiar's Vindication",
            "Kejaan's Vindication",
            "Ikatiar's Vindication",
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
