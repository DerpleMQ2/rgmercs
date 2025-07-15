local mq        = require('mq')
local Combat    = require('utils.combat')
local Config    = require('utils.config')
local Core      = require("utils.core")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Logger    = require("utils.logger")

return {
    _version              = "1.3 - Live",
    _author               = "Derple, Algar",
    ['Modes']             = {
        'DPS',
    },
    ['ModeChecks']        = {
        IsHealing = function() return true end,
    },
    ['ItemSets']          = {                  --TODO: Add Omens Chest
        ['Epic'] = {
            "Savage Lord's Totem",             -- Epic    -- Epic 1.5
            "Spiritcaller Totem of the Feral", -- Epic    -- Epic 2.0
        },
        ['OoW_Chest'] = {
            "Beast Tamer's Jerkin",
            "Savagesoul Jerkin of the Wilds",
        },
        ['Coating'] = {
            "Spirit Drinker's Coating",
            "Blood Drinker's Coating",
        },
    },
    ['AbilitySets']       = { --TODO/Under Consideration: Add AoE Roar line, add rotation entry (tie it to Do AoE setting), swap in instead of lance 2, especially since the last lance2 is level 112
        ['SwarmPet'] = {
            -- Swarm Pet
            "Bestial Empathy",    -- Level 68
            "Bark at the Moon",   -- Level 75
            "Howl at the Moon",   -- Level 80
            "Yowl at the Moon",   -- Level 85
            "Shout at the Moon",  -- Level 90
            "Scream at the Moon", -- Level 95
            "Yell at the Moon",   -- Level 100
            "Cry at the Moon",    -- Level 105
            "Roar at the Moon",   -- Level 110
            "Bay at the Moon",    -- Level 115
            "Bellow at the Moon", -- Level 120
            "Shriek at the Moon", -- Level 125
        },
        ['Feralgia'] = {
            -- Swarm Pet and Growl combination
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
        ['AERoar'] = {
            -- PBAE Roar Timer 11 Ice Nuke Fast Cast
            "Glacial Roar",   -- Level 89 - Timer 11
            "Frostrift Roar", -- Level 94 - Timer 11
            "Kromrif Roar",   -- Level 99 - Timer 11
            "Kromtus Roar",   -- Level 104 - Timer 11
            "Frostbite Roar", -- Level 109 - Timer 11
            "Restless Roar",  -- Level 114 - Timer 11
            "Polar Roar",     -- Level 119 - Timer 11
            "Hoarfrost Roar", -- Level 124 - Timer 11
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
        ['BloodDot'] = {
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
        ['ColdDot'] = {
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
            "Reciprocal Fury", -- Level 121
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
        ['PetGroupEndRegenProc'] = {
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
            -- --Combined ManaRegenBuff and AtkHPBuff
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
            -- Spirit of the Shrew Is Only 30% Speed Flat So Removed it from the List as its too slow
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
            "Venomous Covariance",  -- Level 123
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
            "Auspice of Usira",      -- Level 122
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
        ['FocusSpell'] = {
            -- Single target Talismans ( Like Focus)
            "Inner Fire",
            "Talisman of Tnarg",
            "Talisman of Altuna",
            "Talisman of Kragg",
            "Focus of Alladnu",
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
        ['AtkHPBuff'] = {
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
            --Single Target Atk+HP Buff* - Does Not Stack with Pally brells or Ranger Buff - is Middle ground Buff has HP & Atk
            "Spiritual Brawn",
            "Spiritual Strength",
        },
        ['AtkBuff'] = {
            -- - Single Ferocity
            "Savagery",                  -- Level 60
            "Ferocity",                  -- Level 65
            "Ferocity of Irionu",        -- Level 70
            "Ruthless Ferocity",         -- Level 75
            "Vicious Ferocity",          -- Level 80
            "Savage Ferocity",           -- Level 85
            "Callous Ferocity",          -- Level 90
            "Brutal Ferocity",           -- Level 92
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
        ['BestialBuffDisc'] = {
            --Bestial Buff*
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
        ['FuryDisc'] = {
            --HHE Burn Disc* - Dicho/Dissident Replace this @ 101 outside of burns
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
            "Reflexive Slashing", -- Level 124
        },
        ['VinDisc'] = {
            -- Vindication Disc
            "Al`ele's Vindication",
            "Venon's Vindication",
            "Ikatiar's Vindication",
            "Kejaan's Vindication",
            "Ikatiar's Vindication",
            "Xanathan's Vindication", -- Level 125
        },
    },
    ['HealRotationOrder'] = {
        {
            name = 'PetHealAA',
            state = 1,
            steps = 1,
            load_cond = function() return Casting.CanUseAA("Mend Companion") end,
            cond = function(self, target) return target.ID() == mq.TLO.Me.Pet.ID() and Targeting.MainHealsNeeded(mq.TLO.Me.Pet) end,
        },
        {
            name = 'PetHealSpell',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoPetHealSpell') end,
            cond = function(self, target) return target.ID() == mq.TLO.Me.Pet.ID() and Targeting.BigHealsNeeded(mq.TLO.Me.Pet) end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoHeals') end,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ['PetHealAA'] = {
            {
                name = "Mend Companion",
                type = "AA",
            },
        },
        ['PetHealSpell'] = {
            {
                name = "PetHealSpell",
                type = "Spell",
            },
        },
        ['MainHealPoint'] = {
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
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 30,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or (Targeting.IsNamed(Targeting.GetAutoTarget()) and mq.TLO.Me.PctAggro() > 99))
            end,
        },
        {
            name = 'FocusedParagon',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoParagon') and Casting.CanUseAA("Focused Paragon of Spirits") end,
            targetId = function(self)
                return { Combat.FindWorstHurtManaGroupMember(Config:GetSetting('FParaPct')),
                    Combat.FindWorstHurtManaXT(Config:GetSetting('FParaPct')), }
            end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and Config:GetSetting('DowntimeFP') and Casting.OkayToBuff()
                local combat = combat_state == "Combat"
                return (downtime or combat) and not Casting.IHaveBuff(mq.TLO.Me.AltAbility('Paragon of Spirit').Spell)
            end,
        },
        {
            name = 'Slow',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSlow') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['HelperFunctions']   = {
        FlurryActive = function(self)
            local fury = self.ResolvedActionMap['FuryDisc']
            local dicho = self.ResolvedActionMap['DichoSpell']
            return (dicho and dicho() and Casting.IHaveBuff(dicho.Name()))
                or (fury and fury() and Casting.IHaveBuff(fury.Name()))
        end,
        DmgModActive = function(self) --Song active by name will check both Bestial Alignments (Self and Group)
            local disc = self.ResolvedActionMap['DmgModDisc']
            return Casting.IHaveBuff("Bestial Alignment") or (disc and disc() and Casting.IHaveBuff(disc.Name()))
                or Casting.IHaveBuff("Ferociousness")
        end,
        --function to make sure we don't have non-hostiles in range before we use AE damage or non-taunt AE hate abilities
        AETargetCheck = function(printDebug)
            local haters = mq.TLO.SpawnCount("NPC xtarhater radius 80 zradius 50")()
            local haterPets = mq.TLO.SpawnCount("NPCpet xtarhater radius 80 zradius 50")()
            local totalHaters = haters + haterPets
            if totalHaters < Config:GetSetting('AETargetCnt') or totalHaters > Config:GetSetting('MaxAETargetCnt') then return false end

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
    ['Rotations']         = {
        ['Burn'] = {
            {
                name = "Group Bestial Alignment",
                type = "AA",
                cond = function(self, aaName)
                    return not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "Attack of the Warder",
                type = "AA",
            },
            {
                name = "Frenzy of Spirit",
                type = "AA",
            },
            {
                name = "Bloodlust",
                type = "AA",
            },
            {
                name = "VinDisc",
                type = "Disc",
            },
            {
                name = "Spire of the Savage Lord",
                type = "AA",
            },
            {
                name = "Companion's Fury",
                type = "AA",
            },
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Frenzied Swipes",
                type = "AA",
            },
            {
                name = "BloodDot",
                type = "Spell",
                cond = function(self, spell, target)
                    local vinDisc = self.ResolvedActionMap['VinDisc']
                    if not vinDisc then return false end
                    return Casting.IHaveBuff(vinDisc)
                end,
            },
            {
                name = "FuryDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return not self.ClassConfig.HelperFunctions.FlurryActive(self)
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    local dichoSpell = self.ResolvedActionMap['DichoSpell'].RankName() or "None"
                    return not self.ClassConfig.HelperFunctions.FlurryActive(self) and (mq.TLO.Me.GemTimer(dichoSpell)() or -1) > 15
                end,
            },
            {
                name = "DmgModDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "Ferociousness",
                type = "AA",
                cond = function(self, aaName, target)
                    return not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "Bestial Alignment",
                type = "AA",
                cond = function(self, aaName)
                    return not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, itemName)
                    return not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVetAA')
                end,
            },
        },
        ['Slow'] = {
            {
                name = "Sha's Reprisal",
                type = "AA",
                cond = function(self, aaName, target)
                    local aaSpell = Casting.GetAASpell(aaName)
                    return Casting.DetAACheck(aaName) and (aaSpell.SlowPct() or 0) > (Targeting.GetTargetSlowedPct())
                end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Sha's Reprisal") then return false end
                    return Casting.DetSpellCheck(spell) and (spell.RankName.SlowPct() or 0) > (Targeting.GetTargetSlowedPct())
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Falsified Death",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('AggroFeign') then return false end
                    return (mq.TLO.Me.PctHPs() <= 40 and Targeting.IHaveAggro(100)) or (Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 99) and not Core.IAmMA
                end,
            },
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoVetAA') then return false end
                    return mq.TLO.Me.PctHPs() < 35
                end,
            },
            {
                name = "Warder's Gift",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.Pet.PctHPs() and mq.TLO.Me.Pet.PctHPs() > 50)
                end,
            },
            {
                name = "Protection of the Warder",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Coating",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCoating') then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
        },
        ['FocusedParagon'] = {
            {
                name = "Focused Paragon of Spirits",
                type = "AA",
            },
        },
        ['DPS'] = {
            {
                name = "PetSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Pet.ID() == 0
                end,
            },
            {
                name = "Paragon of Spirit",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoParagon') then return false end
                    return (mq.TLO.Group.LowMana(Config:GetSetting('ParaPct'))() or -1) > 0
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.FlurryActive(self)
                end,
            },
            {
                name = "Feralgia",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoFeralgia') then return false end
                    --This checks to see if the Growl portion is up on the pet (or about to expire) before using this, those who prefer the swarm pets can use the actual swarm pet spell in conjunction with this for mana savings.
                    --There are some instances where the Growl isn't needed, but that is a giant TODO and of minor benefit.
                    ---@diagnostic disable-next-line: undefined-field
                    return (mq.TLO.Pet.BuffDuration(spell.RankName.Trigger(2)).TotalSeconds() or 0) < 10
                end,
            },
            {
                name = "BloodDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "ColdDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "EndemicDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "Maelstrom",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "FrozenPoi",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "PoiBite",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Icelance1",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Icelance2",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting("DoAERoar") then return false end
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "AERoar",
                type = "Spell",
                cond = function(self, spell, target)
                    if not (Config:GetSetting("DoAERoar") and Config:GetSetting("DoAEDamage")) then return false end
                    return Casting.OkayToNuke() and self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            {
                name = "SwarmPet",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSwarmPet') then return false end
                    --We will let Feralgia apply swarm pets if our pet currently doesn't have its Growl Effect.
                    local feralgia = self.ResolvedActionMap['Feralgia']
                    return (feralgia and feralgia() and mq.TLO.Me.PetBuff(mq.TLO.Spell(feralgia).RankName.Trigger(2).ID())) and Casting.HaveManaToNuke()
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Round Kick",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Casting.CanUseAA("Feral Swipe")
                end,
            },
            {
                name = "Kick",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return not Casting.CanUseAA("Feral Swipe")
                end,
            },
            {
                name = "Tiger Claw",
                type = "Ability",
            },
            {
                name = "Enduring Frenzy",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.GetTargetPctHPs() > 90
                end,
            },
            {
                name = "EndRegenProcDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return mq.TLO.Me.PctEndurance() < Config:GetSetting('ParaPct')
                end,
            },
            {
                name = "Chameleon Strike",
                type = "AA",
            },
            {
                name = "SingleClaws",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return not Config:GetSetting('DoAEDamage')
                end,
            },
            {
                name = "AEClaws",
                type = "Disc",
                cond = function(self, discSpell, target)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            {
                name = "Maul",
                type = "Disc",
            },
            {
                name = "BestialBuffDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "Consumption of Spirit",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.PctHPs() > 90 and mq.TLO.Me.PctMana() < 60)
                end,
            },
            {
                name = "Nature's Salve",
                type = "AA",
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return mq.TLO.Me.TotalCounters() > 0
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoRunSpeed') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAvatar') or not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Make sure this is gemmed due to long refresh, and only use the single target versions on classes that need it.
                    if ((spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target)) or not Casting.CastReady(spell) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "UnityBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    local atkHPBuff = self:GetResolvedActionMapItem('AtkHPBuff')
                    local manaRegenBuff = self:GetResolvedActionMapItem('ManaRegenBuff')
                    local triggerone = atkHPBuff and atkHPBuff.Level() or 999
                    local triggertwo = manaRegenBuff and manaRegenBuff.Level() or 999
                    if (spell.Level() or 0) < (triggerone or triggertwo) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ManaRegenBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Only use the single target versions on classes that need it
                    if (spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "FocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Only use the single target versions on classes that need it
                    if (spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Pet.ID() == 0
                end,
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
                name = "Consumption of Spirit",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.PctHPs() > 70 and mq.TLO.Me.PctMana() < 80)
                end,
            },
            {
                name = "Feralist's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "KillShotBuff",
                type = "Spell",
                cond = function(self, spell)
                    if Casting.CanUseAA("Feralist's Unity") then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Pact of The Wurine",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if not Config:GetSetting('DoEpic') then return false end
                    return not mq.TLO.Me.PetBuff("Savage Wildcaller's Blessing")() and not mq.TLO.Me.PetBuff("Might of the Wild Spirits")()
                end,
            },
            {
                name = "Hobble of Spirits",
                type = "AA",
                cond = function(self, aaName, target)
                    local slowProc = self.ResolvedActionMap['PetSlowProc']
                    return Config:GetSetting('DoPetSnare') and (slowProc and slowProc() and mq.TLO.Me.PetBuff(slowProc.RankName()) == nil) and
                        mq.TLO.Me.PetBuff(mq.TLO.Me.AltAbility(aaName).Spell.RankName.Name())() == nil
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoAvatar') and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoRunSpeed') and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetOffenseBuff",
                type = "Spell",
                cond = function(self, spell)
                    return (not Config:GetSetting('DoTankPet')) and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetDefenseBuff",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoTankPet') and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetSlowProc",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoPetSlow') and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetHaste",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetDamageProc",
                type = "Spell",
                cond = function(self, spell)
                    return (not Config:GetSetting('DoTankPet')) and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetHealProc",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetSpellGuard",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoSpellGuard') and Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetGrowl",
                type = "Spell",
                cond = function(self, spell)
                    if Config:GetSetting('DoFeralgia') then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Companion's Aegis",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "HealSpell",    cond = function(self) return Config:GetSetting('DoHeals') end, },
                { name = "PetHealSpell", cond = function(self) return Config:GetSetting('DoPetHealSpell') end, },
                { name = "Icelance1", },

            },
        },
        {
            gem = 2,
            spells = {
                { name = "PetHealSpell", cond = function(self) return Config:GetSetting('DoPetHealSpell') end, },
                { name = "Icelance1", },
                { name = "AERoar",       cond = function(self) return Config:GetSetting('DoAERoar') end, },
                { name = "Icelance2", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "Icelance1", },
                { name = "AERoar",    cond = function(self) return Config:GetSetting('DoAERoar') end, },
                { name = "Icelance2", },
                { name = "BloodDot", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "AERoar",    cond = function(self) return Config:GetSetting('DoAERoar') end, },
                { name = "Icelance2", },
                { name = "BloodDot", },
                { name = "ColdDot",   cond = function(self) return Config:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "BloodDot", },
                { name = "ColdDot",    cond = function(self) return Config:GetSetting('DoDot') end, },
                { name = "EndemicDot", cond = function(self) return Config:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "AtkBuff", },
                { name = "RunSpeedBuff", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "SlowSpell",  cond = function(self) return Config:GetSetting('DoSlow') and not Casting.CanUseAA("Sha's Reprisal") end, },
                { name = "DichoSpell", },
                { name = "EndemicDot", cond = function(self) return Config:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "Feralgia",   cond = function(self) return Config:GetSetting('DoFeralgia') end, },
                { name = "PetGrowl", },
                { name = "EndemicDot", cond = function(self) return Config:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PoiBite", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Maelstrom", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "FrozenPoi", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ColdDot",     cond = function(self) return Config:GetSetting('DoDot') end, },
                { name = "PetHealProc", },

            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PetHealProc", },
                { name = "EndemicDot",  cond = function(self) return Config:GetSetting('DoDot') end, },
                { name = "SwarmPet",    cond = function(self) return Config:GetSetting('DoSwarmPet') end, },
            },
        },
    },
    ['PullAbilities']     = {
        {
            id = 'SlowAA',
            Type = "AA",
            DisplayName = "Sha's Reprisal",
            AbilityName = "Sha's Reprisal",
            AbilityRange = 150,
            cond = function(self)
                return mq.TLO.Me.AltAbility("Sha's Reprisal")
            end,
        },
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
    },
    ['DefaultConfig']     = { --TODO: Condense pet proc options into a combo box and update entry conditions appropriately
        ['Mode']           = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What is the difference between the modes?",
            Answer = "Beastlords currently only have one Mode. This may change in the future.",
        },
        --Mana Management
        ['DoParagon']      = {
            DisplayName = "Use Paragon",
            Category = "Mana Mgmt.",
            Index = 1,
            Tooltip = "Use Group or Focused Paragon AAs.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "How do I use my Paragon of Spirit(s) abilities?",
            Answer = "Make sure you have [DoParagon] enabled.\n" ..
                "Set the [ParaPct] to the minimum mana % before we use Paragon of Spirit.\n" ..
                "Set the [FParaPct] to the minimum mana % before we use Focused Paragon.\n" ..
                "If you want to use Focused Paragon outside of combat, enable [DowntimeFP].",
        },
        ['ParaPct']        = {
            DisplayName = "Paragon %",
            Category = "Mana Mgmt.",
            Index = 2,
            Tooltip = "Minimum mana % before we use Paragon of Spirit.",
            Default = 80,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my Paragon Abilities?",
            Answer = "Make sure you have [DoParagon] enabled.\n" ..
                "Set the [ParaPct] to the minimum mana % before we use Paragon of Spirit.\n" ..
                "Set the [FParaPct] to the minimum mana % before we use Focused Paragon.\n" ..
                "If you want to use Focused Paragon outside of combat, enable [DowntimeFP].",
        },
        ['FParaPct']       = {
            DisplayName = "F.Paragon %",
            Category = "Mana Mgmt.",
            Index = 3,
            Tooltip = "Minimum mana % before we use Focused Paragon.",
            Default = 90,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my Paragon Abilities?",
            Answer = "Make sure you have [DoParagon] enabled.\n" ..
                "Set the [ParaPct] to the minimum mana % before we use Paragon of Spirit.\n" ..
                "Set the [FParaPct] to the minimum mana % before we use Focused Paragon.\n" ..
                "If you want to use Focused Paragon outside of combat, enable [DowntimeFP].",
        },
        ['DowntimeFP']     = {
            DisplayName = "Downtime F.Paragon",
            Category = "Mana Mgmt.",
            Index = 4,
            Tooltip = "Use Focused Paragon outside of Combat.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my Paragon Abilities?",
            Answer = "Make sure you have [DoParagon] enabled.\n" ..
                "Set the [ParaPct] to the minimum mana % before we use Paragon of Spirit.\n" ..
                "Set the [FParaPct] to the minimum mana % before we use Focused Paragon.\n" ..
                "If you want to use Focused Paragon outside of combat, enable [DowntimeFP].",
        },
        --Pets
        ['DoTankPet']      = {
            DisplayName = "Do Tank Pet",
            Category = "Pet Mgmt.",
            Index = 1,
            Tooltip = "Use abilities designed for your pet to tank.",
            Default = false,
            FAQ = "Why am I not giving my pet tank buffs?",
            Answer = "Enable [DoTankPet] to use abilities designed for your pet to tank.\n" ..
                "Disable [DoTankPet] to use abilities designed for your pet to DPS.",
        },
        ['DoPetHealSpell'] = {
            DisplayName = "Do Pet Heals",
            Category = "Pet Mgmt.",
            Index = 2,
            Tooltip = "Mem and cast your Pet Heal (Salve) spell. AA Pet Heals are always used in emergencies.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "My Pet Keeps Dying, What Can I Do?",
            Answer = "Make sure you have [DoPetHealSpell] enabled.\n" ..
                "If your pet is still dying, consider using [PetHealPct] to adjust the pet heal threshold.",
        },
        ['DoPetSlow']      = {
            DisplayName = "Pet Slow Proc",
            Category = "Pet Mgmt.",
            Index = 3,
            Tooltip = "Use your Pet Slow Proc Buff (does not stack with Pet Damage or Snare Proc Buff).",
            Default = false,
            FAQ = "Why am I not buffing my pet with (Slow, Damage, Snare) proc buff?",
            Answer =
                "Pet proc buffs do not stack with each other and the one you wish to use should be selected.\n" ..
                "If neither Snare nor Slow proc are selected, the Damage proc will be used.",
        },
        ['DoPetSnare']     = {
            DisplayName = "Pet Snare Proc",
            Category = "Pet Mgmt.",
            Index = 4,
            Tooltip = "Use your Pet Snare Proc Buff (does not stack with Pet Damage or Slow Proc Buff).",
            Default = false,
            FAQ = "Why am I continually buffing my pet?",
            Answer = "Pet proc buffs do not stack, you should only select one.\n" ..
                "If neither Snare nor Slow proc are selected, the Damage proc will be used.",
        },
        ['DoSpellGuard']   = {
            DisplayName = "Do Spellguard",
            Category = "Pet Mgmt.",
            Index = 5,
            Tooltip = "Do Pet Spell Guard. (Warning! Long refresh time.)",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "How do I use my Pet Spell Guard?",
            Answer = "Enable [DoSpellGuard] to use your Pet Spell Guard.\n" ..
                "This has a long refresh time, so expect delays in use.",
        },
        ['DoFeralgia']     = {
            DisplayName = "Do Feralgia",
            Category = "Pet Mgmt.",
            Index = 6,
            Tooltip = "Use Feralgia for the Growl Effect on your Pet instead of the Growl Spell.",
            Default = true,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why is my BST not using the Growl Buff?",
            Answer = "Feralgia provides a similar buff and also summons swarm pets and is enabled by default. Disable it to use Growl.",
        },
        ['DoSwarmPet']     = {
            DisplayName = "Do Swarm Pet",
            Category = "Pet Mgmt.",
            Index = 7,
            Tooltip = "Use your Swarm Pet spell in addition to Feralgia",
            Default = false,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why am I only using swarm pets every couple of minutes?",
            Answer = "By default, our only source of swarm pet is the Feralgia line. In many situations, using swarm pets outside of this can be a DPS loss.\n" ..
                "For those situations where swarm pet DPS is greatly boosted (BRD SHM and MAG in group comes to mind), you can enable Do Swarm Pet to summon them outside of Feralgia.",
        },
        ['DoEpic']         = {
            DisplayName = "Do Epic",
            Category = "Pet Mgmt.",
            Index = 8,
            Tooltip = "Click your Epic Weapon.",
            Default = false,
            FAQ = "How do I use my Epic Weapon?",
            Answer = "Enable Do Epic to click your Epic Weapon.",
        },
        --Spells/Abilities
        ['DoHeals']        = {
            DisplayName = "Do Heals",
            Category = "Spells and Abilities",
            Index = 1,
            Tooltip = "Mem and cast your Mending spell.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "I want to help with healing, what can I do?",
            Answer = "Make sure you have [DoHeals] enabled.\n" ..
                "If you want to help with pet healing, enable [DoPetHealSpell].",
        },
        ['DoSlow']         = {
            DisplayName = "Do Slow",
            Category = "Spells and Abilities",
            Index = 2,
            Tooltip = "Use your slow spell or AA.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why is my BST slowing, when I have a SHM in group?",
            Answer = "Simply deselect the option to Do Slow.",
        },
        ['DoDot']          = {
            DisplayName = "Cast DOTs",
            Category = "Spells and Abilities",
            Index = 3,
            Tooltip = "Enable casting Damage Over Time spells.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why am I using so many DOTs? I'm always running low mana!",
            Answer = "Generally, BST DoT spells are worth using at all levels of play.\n" ..
                "Dots have additional settings in the RGMercs Main config, such as the min mana% to use them, or mob HP to stop using them",
        },
        ['DoRunSpeed']     = {
            DisplayName = "Do Run Speed",
            Category = "Spells and Abilities",
            Index = 4,
            Tooltip = "Do Run Speed Spells/AAs",
            Default = true,
            FAQ = "Why are my buffers in a run speed buff war?",
            Answer = "Many run speed spells freely stack and overwrite each other, you will need to disable Run Speed Buffs on some of the buffers.",
        },
        ['DoAvatar']       = {
            DisplayName = "Do Avatar",
            Category = "Spells and Abilities",
            Index = 5,
            Tooltip = "Buff Group/Pet with Infusion of Spirit",
            Default = false,
            FAQ = "How do I use my Avatar Buffs?",
            Answer = "Make sure you have [DoAvatar] enabled.\n" ..
                "Also double check [DoBuffs] is enabled so you can cast on others.",
        },
        ['DoVetAA']        = {
            DisplayName = "Use Vet AA",
            Category = "Spells and Abilities",
            Index = 6,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does SHD use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },
        --Combat
        ['DoAEDamage']     = {
            DisplayName = "Do AE Damage",
            Category = "Combat",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['DoAERoar']       = {
            DisplayName = "Use AE Roar",
            Category = "Combat",
            Index = 2,
            Tooltip = "Use your AE Roar (Timer 11) spell line.",
            Default = false,
            FAQ = "Why am I not using the Roar line? It is better than this weak Ice Lance?",
            Answer = "Enable Use AE Roar to memorize the spell.\nNote that Do AE Damage must also be enabled for the Roar to be used.",
        },
        ['AETargetCnt']    = {
            DisplayName = "AE Target Count",
            Category = "Combat",
            Index = 3,
            Tooltip = "Minimum number of valid targets before using AE Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['MaxAETargetCnt'] = {
            DisplayName = "Max AE Targets",
            Category = "Combat",
            Index = 4,
            Tooltip =
            "Maximum number of valid targets before using AE Spells, Disciplines or AA.\nUseful for setting up AE Mez at a higher threshold on another character in case you are overwhelmed.",
            Default = 5,
            Min = 2,
            Max = 30,
            FAQ = "How do I take advantage of the Max AE Targets setting?",
            Answer =
            "By limiting your max AE targets, you can set an AE Mez count that is slightly higher, to allow for the possiblity of mezzing if you are being overwhelmed.",
        },
        ['SafeAEDamage']   = {
            DisplayName = "AE Proximity Check",
            Category = "Combat",
            Index = 5,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },
        ['EmergencyStart'] = {
            DisplayName = "Emergency HP%",
            Category = "Combat",
            Index = 6,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "How do I use my Emergency Mitigation Abilities?",
            Answer = "Make sure you have [EmergencyStart] set to the HP % before we begin to use emergency mitigation abilities.",
        },
        ['AggroFeign']     = {
            DisplayName = "Emergency Feign",
            Category = "Combat",
            Index = 7,
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
            Default = true,
            FAQ = "How do I use my Feign Death?",
            Answer = "Make sure you have [AggroFeign] enabled.\n" ..
                "This will use your Feign Death AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
        },
        ['DoCoating']      = {
            DisplayName = "Use Coating",
            Category = "Combat",
            Index = 8,
            Tooltip = "Click your Blood/Spirit Drinker's Coating in an emergency.",
            Default = false,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },
        ['DoChestClick']   = {
            DisplayName = "Do Chest Click",
            Category = "Combat",
            Index = 9,
            Tooltip = "Click your chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            ConfigType = "Advanced",
            FAQ = "What is a Chest Click?",
            Answer = "Most Chest slot items after level 75ish have a clickable effect.\n" ..
                "BST is set to use theirs during burns, so long as the item equipped has a clicky effect.",
        },
    },
}
