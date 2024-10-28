local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    _version              = "1.2 - Project Lazarus",
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
        },
        ['VinDisc'] = {
            -- Vindication Disc
            "Al`ele's Vindication",
            "Venon's Vindication",
            "Ikatiar's Vindication",
            "Kejaan's Vindication",
            "Ikatiar's Vindication",
        },
    },
    ['HealRotationOrder'] = {
        {
            name = 'PetHealpoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return target.ID() == mq.TLO.Me.Pet.ID() end,
        },
        {
            name  = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond  = function(self, target) return RGMercConfig:GetSetting('DoHeals') and (target.PctHPs() or 999) < RGMercConfig:GetSetting('MainHealPoint') end,
        },
    },
    ['HealRotations']     = {
        ["PetHealpoint"] = {
            {
                name = "Mend Companion",
                type = "AA",
                cond = function(self, aaName, target) return mq.TLO.Me.Pet.PctHPs() <= RGMercConfig:GetSetting('BigHealPoint') and RGMercUtils.AAReady(aaName) end,
            },
            {
                name = "PetHealSpell",
                type = "Spell",
                cond = function(self, spell) return RGMercConfig:GetSetting('DoPetHeals') and RGMercUtils.PCSpellReady(spell) end,
            },
        },
        ["MainHealPoint"] = {
            {
                name = "HealSpell",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.PCSpellReady(spell) end,
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and RGMercUtils.DoBuffCheck() and RGMercUtils.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                return RGMercUtils.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and RGMercUtils.DoBuffCheck()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and RGMercUtils.DoPetCheck()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 30,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and RGMercUtils.DoPetCheck()
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return RGMercUtils.GetXTHaterCount() > 0 and not RGMercUtils.Feigning() and
                    (mq.TLO.Me.PctHPs() <= RGMercConfig:GetSetting('EmergencyStart') or (RGMercUtils.IsNamed(mq.TLO.Target) and mq.TLO.Me.PctAggro() > 99))
            end,
        },
        {
            name = 'FocusedParagon',
            state = 1,
            steps = 1,
            targetId = function(self)
                return { RGMercUtils.FindWorstHurtManaGroupMember(RGMercConfig:GetSetting('FParaPct')),
                    RGMercUtils.FindWorstHurtManaXT(RGMercConfig:GetSetting('FParaPct')), }
            end,
            cond = function(self, combat_state)
                if not RGMercConfig:GetSetting('DoParagon') then return false end
                local downtime = combat_state == "Downtime" and RGMercConfig:GetSetting('DowntimeFP') and RGMercUtils.DoBuffCheck()
                local combat = combat_state == "Combat" and not RGMercUtils.Feigning()
                return (downtime or combat) and not RGMercUtils.BuffActive(mq.TLO.Me.AltAbility('Paragon of Spirit').Spell)
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.BurnCheck() and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
    },
    ['HelperFunctions']   = {
        FlurryActive = function(self)
            local fury = self.ResolvedActionMap['FuryDisc']
            local dicho = self.ResolvedActionMap['DichoSpell']
            return (dicho and dicho() and RGMercUtils.SongActiveByName(dicho.Name()))
                or (fury and fury() and RGMercUtils.SongActiveByName(fury.Name()))
        end,
        DmgModActive = function(self) --Song active by name will check both Bestial Alignments (Self and Group)
            local disc = self.ResolvedActionMap['DmgModDisc']
            return RGMercUtils.SongActiveByName("Bestial Alignment") or (disc and disc() and RGMercUtils.SongActiveByName(disc.Name()))
                or RGMercUtils.BuffActiveByName("Ferociousness")
        end,
    },
    ['Rotations']         = {
        ['Burn'] = {
            {
                name = "Group Bestial Alignment",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "Attack of the Warder",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Frenzy of Spirit",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Bloodlust",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "VinDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Spire of the Savage Lord",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Companion's Fury",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return item() and RGMercUtils.TargetHasBuff(item.Spell, mq.TLO.Me)
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercConfig:GetSetting('DoChestClick') and item() and RGMercUtils.SpellStacksOnMe(item.Spell) and item.TimerReady() == 0
                end,
            },
            {
                name = "Frenzied Swipes",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Blooddot",
                type = "Spell",
                cond = function(self, spell, target)
                    local vinDisc = self.ResolvedActionMap['VinDisc']
                    if not vinDisc then return false end
                    return RGMercUtils.BuffActive(vinDisc) and RGMercUtils.NPCSpellReady(spell, target.ID())
                end,
            },
            {
                name = "FuryDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercUtils.PCDiscReady(discSpell) and not self.ClassConfig.HelperFunctions.FlurryActive(self)
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and not self.ClassConfig.HelperFunctions.FlurryActive(self) and
                        (mq.TLO.Me.GemTimer(self.ResolvedActionMap['DichoSpell'])() or -1) > 15
                end,
            },
            {
                name = "DmgModDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
            {
                name = "Ferociousness",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName) and not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },

            -- omens chest would go here with fero (I think same conditions excepting fero can be active, but more study needed to make sure)

            {
                name = "Bestial Alignment",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and not self.ClassConfig.HelperFunctions.DmgModActive(self)
                end,
            },
        },
        ['Debuff'] = {
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return RGMercConfig:GetSetting('DoSlow') and not RGMercUtils.CanUseAA("Sha's Reprisal") and not RGMercUtils.TargetHasBuff(spell) and
                        RGMercUtils.SpellStacksOnTarget(spell) and spell.SlowPct() > (RGMercUtils.GetTargetSlowedPct()) and RGMercUtils.NPCSpellReady(spell)
                end,
            },
            {
                name = "Sha's Reprisal",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercConfig:GetSetting('DoSlow') and not RGMercUtils.TargetHasBuffByName(aaName) and
                        (mq.TLO.Me.AltAbility(aaName).Spell.SlowPct() or 0) > (RGMercUtils.GetTargetSlowedPct()) and RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Falsified Death",
                type = "AA",
                cond = function(self, aaName)
                    if not RGMercConfig:GetSetting('AggroFeign') then return false end
                    return (mq.TLO.Me.PctHPs() <= 40 and RGMercUtils.IHaveAggro(100)) or (RGMercUtils.IsNamed(mq.TLO.Target) and mq.TLO.Me.PctAggro() > 99)
                        and RGMercUtils.PCAAReady(aaName) and not RGMercUtils.IAmMA
                end,
            },
            {
                name = "Warder's Gift",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.Pet.PctHPs() > 50 and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Protection of the Warder",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IHaveAggro(100) and RGMercUtils.AAReady(aaName)
                end,
            },
        },
        ['FocusedParagon'] = {
            {
                name = "Focused Paragon of Spirits",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
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
                    if not RGMercConfig:GetSetting('DoParagon') then return false end
                    return (mq.TLO.Group.LowMana(RGMercConfig:GetSetting('ParaPct'))() or -1) > 0 and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and not self.ClassConfig.HelperFunctions.FlurryActive(self)
                end,
            },
            {
                name = "Feralgia",
                type = "Spell",
                cond = function(self, spell, target)
                    if not RGMercConfig:GetSetting('DoFeralgia') then return false end
                    --This checks to see if the Growl portion is up on the pet (or about to expire) before using this, those who prefer the swarm pets can use the actual swarm pet spell in conjunction with this for mana savings.
                    --There are some instances where the Growl isn't needed, but that is a giant TODO and of minor benefit.
                    ---@diagnostic disable-next-line: undefined-field
                    return (mq.TLO.Pet.BuffDuration(spell.RankName.Trigger(2)).TotalSeconds() or 0) < 10 and RGMercUtils.NPCSpellReady(spell)
                        and (mq.TLO.Me.GemTimer(spell.RankName.Name())() or -1) == 0
                end,
            },
            {
                name = "Blooddot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not RGMercConfig:GetSetting('DoDot') then return false end
                    return RGMercUtils.DotSpellCheck(spell) and (RGMercUtils.DotManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.NPCSpellReady(spell)
                end,
            },
            {
                name = "Colddot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not RGMercConfig:GetSetting('DoDot') then return false end
                    return RGMercUtils.DotSpellCheck(spell) and (RGMercUtils.DotManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.NPCSpellReady(spell)
                end,
            },
            {
                name = "EndemicDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not RGMercConfig:GetSetting('DoDot') then return false end
                    return RGMercUtils.DotSpellCheck(spell) and (RGMercUtils.DotManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.NPCSpellReady(spell)
                end,
            },
            {
                name = "Maelstrom",
                type = "Spell",
                cond = function(self, spell, target)
                    return (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.NPCSpellReady(spell)
                end,
            },
            {
                name = "FrozenPoi",
                type = "Spell",
                cond = function(self, spell, target)
                    return (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.NPCSpellReady(spell)
                end,
            },
            {
                name = "PoiBite",
                type = "Spell",
                cond = function(self, spell, target)
                    return (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.NPCSpellReady(spell)
                end,
            },
            {
                name = "Icelance1",
                type = "Spell",
                cond = function(self, spell, target)
                    return (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.NPCSpellReady(spell)
                end,
            },
            {
                name = "Icelance2",
                type = "Spell",
                cond = function(self, spell, target)
                    return (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.NPCSpellReady(spell)
                end,
            },
            {
                name = "SwarmPet",
                type = "Spell",
                cond = function(self, spell, target)
                    if not RGMercConfig:GetSetting('DoSwarmPet') then return false end
                    --We will let Feralgia apply swarm pets if our pet currently doesn't have its Growl Effect.
                    local feralgia = self.ResolvedActionMap['Feralgia']
                    return (feralgia and feralgia() and mq.TLO.Me.PetBuff(mq.TLO.Spell(feralgia).RankName.Trigger(2).ID()))
                        and (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.NPCSpellReady(spell)
                        and (mq.TLO.Me.GemTimer(spell.RankName.Name())() or -1) == 0
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Round Kick",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return RGMercUtils.CanUseAA("Feral Swipe") and mq.TLO.Me.AbilityReady(abilityName)() and RGMercUtils.GetTargetDistance() <= (target.MaxRangeTo() or 0)
                end,
            },
            {
                name = "Kick",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return not RGMercUtils.CanUseAA("Feral Swipe") and mq.TLO.Me.AbilityReady(abilityName)() and RGMercUtils.GetTargetDistance() <= (target.MaxRangeTo() or 0)
                end,
            },
            {
                name = "Tiger Claw",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.AbilityReady(abilityName)() and RGMercUtils.GetTargetDistance() <= (target.MaxRangeTo() or 0)
                end,
            },
            {
                name = "Enduring Frenzy",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.GetTargetPctHPs() > 90 and RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "EndRegenProcDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return mq.TLO.Me.PctEndurance() < RGMercConfig:GetSetting('ParaPct') and RGMercUtils.NPCDiscReady(discSpell)
                end,
            },
            {
                name = "Chameleon Strike",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "SingleClaws",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return not RGMercConfig:GetSetting('DoAoe') and RGMercUtils.NPCDiscReady(discSpell, target.ID())
                end,
            },
            {
                name = "AEClaws",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercConfig:GetSetting('DoAoe') and RGMercUtils.NPCDiscReady(discSpell, target.ID())
                end,
            },
            {
                name = "Maul",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercUtils.NPCDiscReady(discSpell)
                end,
            },
            {
                name = "BestialBuffDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return not RGMercUtils.BuffActive(discSpell) and RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Consumption of Spirit",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.PctHPs() > 90 and mq.TLO.Me.PctMana() < 60) and RGMercUtils.PCAAReady(aaName)
                end,
            },
            {
                name = "Nature's Salve",
                type = "AA",
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return mq.TLO.Me.TotalCounters() > 0 and RGMercUtils.AAReady(aaName)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not RGMercConfig:GetSetting('DoRunSpeed') then return false end
                    return RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not RGMercConfig:GetSetting('DoAvatar') or not RGMercConfig.Constants.RGMelee:contains(target.Class.ShortName()) then return false end
                    return RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Make sure this is gemmed due to long refresh, and only use the single target versions on classes that need it.
                    if (spell and spell() and ((spell.TargetType() or ""):lower() ~= "group v2")) and (not RGMercUtils.CastReady(spell.RankName)
                            or not RGMercConfig.Constants.RGMelee:contains(target.Class.ShortName())) then
                        return false
                    end
                    return RGMercUtils.GroupBuffCheck(spell, target)
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
                    return RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ManaRegenBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Only use the single target versions on classes that need it
                    if (spell and spell() and ((spell.TargetType() or ""):lower() ~= "group v2"))
                        and not RGMercConfig.Constants.RGMelee:contains(target.Class.ShortName()) then
                        return false
                    end
                    return RGMercUtils.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "FocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Only use the single target versions on classes that need it
                    if (spell and spell() and ((spell.TargetType() or ""):lower() ~= "group v2"))
                        and not RGMercConfig.Constants.RGMelee:contains(target.Class.ShortName()) then
                        return false
                    end
                    return RGMercUtils.GroupBuffCheck(spell, target)
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
            },
        },
        ['Downtime'] = {
            {
                name = "Consumption of Spirit",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.PctHPs() > 70 and mq.TLO.Me.PctMana() < 80) and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Feralist's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and RGMercUtils.PCAAReady(aaName)
                end,
            },
            {
                name = "KillShotBuff",
                type = "Spell",
                cond = function(self, spell)
                    if RGMercUtils.CanUseAA("Feralist's Unity") then return false end
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Pact of The Wurine",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and RGMercUtils.AAReady(aaName)
                end,
            },
            -- TODO: Does anyone even want this?
            --{
            --    name = "VerifyFerocity",
            --    type = "CustomFunc",
            --    custom_func = function(self, targetId)
            --        if not RGMercConfig:GetSetting('DoCombatFero') or not RGMercUtils.NPCSpellReady(self.ResolvedActionMap['SingleAtkBuff'], targetId, false) then return false end
            --        -- TODO: Ferocity List?
            --        return false
            --    end,
            --},
        },
        ['PetBuff'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    return RGMercConfig:GetSetting('DoEpic') and
                        mq.TLO.FindItem(itemName)() and mq.TLO.Me.ItemReady(itemName)() and
                        (mq.TLO.Me.PetBuff("Savage Wildcaller's Blessing")() == nil and mq.TLO.Me.PetBuff("Might of the Wild Spirits")() == nil)
                end,
            },
            {
                name = "Hobble of Spirits",
                type = "AA",
                cond = function(self, aaName, target)
                    local slowProc = self.ResolvedActionMap['PetSlowProc']
                    return RGMercConfig:GetSetting('DoPetSnare') and (slowProc and slowProc() and mq.TLO.Me.PetBuff(slowProc.RankName()) == nil) and
                        mq.TLO.Me.PetBuff(mq.TLO.Me.AltAbility(aaName).Spell.RankName.Name())() == nil
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercConfig:GetSetting('DoAvatar') and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercConfig:GetSetting('DoRunSpeed') and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetOffenseBuff",
                type = "Spell",
                cond = function(self, spell)
                    return (not RGMercConfig:GetSetting('DoTankPet')) and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetDefenseBuff",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercConfig:GetSetting('DoTankPet') and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetSlowProc",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercConfig:GetSetting('DoPetSlow') and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetHaste",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetDamageProc",
                type = "Spell",
                cond = function(self, spell)
                    return (not RGMercConfig:GetSetting('DoTankPet')) and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetHealProc",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetSpellGuard",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercConfig:GetSetting('DoSpellGuard') and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetGrowl",
                type = "Spell",
                cond = function(self, spell)
                    if RGMercConfig:GetSetting('DoFeralgia') then return false end
                    return not RGMercUtils.SongActive(spell)
                end,
            },
            {
                name = "Companion's Aegis",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffPetCheck(mq.TLO.Spell(aaName)) and RGMercUtils.PCAAReady(aaName)
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "HealSpell",    cond = function(self) return RGMercConfig:GetSetting('DoHeals') end, },
                { name = "PetHealSpell", cond = function(self) return RGMercConfig:GetSetting('DoPetHeals') end, },
                { name = "Icelance1", },

            },
        },
        {
            gem = 2,
            spells = {
                { name = "PetHealSpell", cond = function(self) return RGMercConfig:GetSetting('DoPetHeals') end, },
                { name = "Icelance1", },
                { name = "Icelance2", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "Icelance1", },
                { name = "Icelance2", },
                { name = "Blooddot", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "Icelance2", },
                { name = "Blooddot", },
                { name = "Colddot",   cond = function(self) return RGMercConfig:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "Blooddot", },
                { name = "Colddot",    cond = function(self) return RGMercConfig:GetSetting('DoDot') end, },
                { name = "EndemicDot", cond = function(self) return RGMercConfig:GetSetting('DoDot') end, },
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
                { name = "SlowSpell",  cond = function(self) return RGMercConfig:GetSetting('DoSlow') and not RGMercUtils.CanUseAA("Sha's Reprisal") end, },
                { name = "DichoSpell", },
                { name = "EndemicDot", cond = function(self) return RGMercConfig:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "Feralgia",   cond = function(self) return RGMercConfig:GetSetting('DoFeralgia') end, },
                { name = "PetGrowl", },
                { name = "EndemicDot", cond = function(self) return RGMercConfig:GetSetting('DoDot') end, },
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
                { name = "Colddot",     cond = function(self) return RGMercConfig:GetSetting('DoDot') end, },
                { name = "PetHealProc", },

            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PetHealProc", },
                { name = "EndemicDot",  cond = function(self) return RGMercConfig:GetSetting('DoDot') end, },
                { name = "SwarmPet",    cond = function(self) return RGMercConfig:GetSetting('DoSwarmPet') end, },
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
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('SlowSpell')() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('SlowSpell')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('SlowSpell')
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
        ['DoPetHeals']     = {
            DisplayName = "Do Pet Heals",
            Category = "Pet Mgmt.",
            Index = 2,
            Tooltip = "Mem and cast your Pet Heal (Salve) spell. AA Pet Heals are always used in emergencies.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "My Pet Keeps Dying, What Can I Do?",
            Answer = "Make sure you have [DoPetHeals] enabled.\n" ..
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
                "If you want to help with pet healing, enable [DoPetHeals].",
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
        ['DoAoe']          = {
            DisplayName = "Do AoE",
            Category = "Spells and Abilities",
            Index = 4,
            Tooltip = "Enable using AoE Claw Ability. --TODO: Add AoE DD Nuke",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "I have Do AoE selected, why am I not using my Roar line?",
            Answer = "Roar line will be added soon™, until then, Do AoE only governs your \"Of Claws\" ability selection.",
        },
        ['DoRunSpeed']     = {
            DisplayName = "Do Run Speed",
            Category = "Spells and Abilities",
            Index = 5,
            Tooltip = "Do Run Speed Spells/AAs",
            Default = true,
            FAQ = "Why are my buffers in a run speed buff war?",
            Answer = "Many run speed spells freely stack and overwrite each other, you will need to disable Run Speed Buffs on some of the buffers.",
        },
        ['DoAvatar']       = {
            DisplayName = "Do Avatar",
            Category = "Spells and Abilities",
            Index = 6,
            Tooltip = "Buff Group/Pet with Infusion of Spirit",
            Default = false,
            FAQ = "How do I use my Avatar Buffs?",
            Answer = "Make sure you have [DoAvatar] enabled.\n" ..
                "Also double check [DoBuffs] is enabled so you can cast on others.",
        },
        ['DoChestClick']   = {
            DisplayName = "Do Chest Click",
            Category = "Spells and Abilities",
            Index = 7,
            Tooltip = "Click your chest item during burns.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "What is a Chest Click?",
            Answer = "Most Chest slot items after level 75ish have a clickable effect.\n" ..
                "BST is set to use theirs during burns, so long as the item equipped has a clicky effect.",
        },
        ['AggroFeign']     = {
            DisplayName = "Emergency Feign",
            Category = "Spells and Abilities",
            Index = 8,
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
            Default = true,
            FAQ = "How do I use my Feign Death?",
            Answer = "Make sure you have [AggroFeign] enabled.\n" ..
                "This will use your Feign Death AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
        },
        ['EmergencyStart'] = {
            DisplayName = "Emergency HP%",
            Category = "Spells and Abilities",
            Index = 9,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "How do I use my Emergency Mitigation Abilities?",
            Answer = "Make sure you have [EmergencyStart] set to the HP % before we begin to use emergency mitigation abilities.",
        },
        --['DoCombatFero']    = { DisplayName = "Do Combat Fero", Category = "Combat", Tooltip = "Do Combat Fero", Default = true, }, --commented like the respective entry.
    },
}
