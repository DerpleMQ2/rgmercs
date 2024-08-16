local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    _version              = "1.0 Beta",
    _author               = "Derple",
    ['Modes']             = {
        'DPS',
    },
    ['ModeChecks']        = {
        IsHealing = function() return true end,
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Savage Lord's Totem",             -- Epic    -- Epic 1.5
            "Spiritcaller Totem of the Feral", -- Epic    -- Epic 2.0
        },
    },
    ['AbilitySets']       = {
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
    ['HealRotationOrder'] = {
        {
            name = 'PetHealpoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return target.ID() == mq.TLO.Me.Pet.ID() end,
        },
        {
            name  = 'LightHealPoint',
            state = 1,
            steps = 1,
            cond  = function(self, target) return (target.PctHPs() or 999) < RGMercUtils.GetSetting('LightHealPoint') end,
        },
    },
    ['HealRotations']     = {
        ["PetHealpoint"] = {
            {
                name = "PetHealSpell",
                type = "Spell",
                cond = function(self, spell) return true end,
            },
        },
        ["LightHealPoint"] = {
            {
                name = "HealSpell",
                type = "Spell",
                cond = function(self, spell) return mq.TLO.Me.Level() < 112 end,
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
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
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    RGMercUtils.DoBuffCheck() and RGMercConfig:GetTimeSinceLastMove() > RGMercUtils.GetSetting('BuffWaitMoveTimer')
            end,
        },
        {
            name = 'Pet Downtime',
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    RGMercUtils.DoBuffCheck() and mq.TLO.Me.Pet.ID() > 0 and RGMercConfig:GetTimeSinceLastMove() > RGMercUtils.GetSetting('BuffWaitMoveTimer')
            end,
        },
        {
            name = 'FocusedParagon',
            targetId = function(self)
                return { RGMercUtils.FindWorstHurtManaGroupMember(RGMercUtils.GetSetting('ParagonPct')),
                    RGMercUtils.FindWorstHurtManaXT(RGMercUtils.GetSetting('ParagonPct')), }
            end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.GetSetting('DoParagon') and not RGMercUtils.BuffActive(mq.TLO.Me.AltAbility('Paragon of Spirit').Spell) and
                    not RGMercUtils.Feigning()
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
                return combat_state == "Combat" and not RGMercUtils.Feigning() and RGMercUtils.BurnCheck()
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

    },
    ['HelperFunctions']   = {
        BeastialAligmentCheck = function(self)
            local discSpell = self.ResolvedActionMap['HHEFuryDisc']
            return discSpell and discSpell() and not RGMercUtils.SongActiveByName(discSpell.RankName()) and
                not RGMercUtils.SongActiveByName('Bestial Alignment') and
                not RGMercUtils.BuffActiveByName('Ferociousness')
        end,
        HHEFuryDiscCheckPrimary = function(self)
            local discSpell = self.ResolvedActionMap['HHEFuryDisc']
            return discSpell and discSpell() and not RGMercUtils.SongActiveByName(discSpell.RankName()) and
                not RGMercUtils.SongActiveByName('Bestial Alignment') and
                not RGMercUtils.BuffActiveByName('Ferociousness') and
                not RGMercUtils.PCAAReady("Bestial Alignment")
        end,
        HHEFuryDiscCheckSecondary = function(self)
            local discSpell = self.ResolvedActionMap['HHEFuryDisc']
            return discSpell and discSpell() and not RGMercUtils.SongActiveByName(discSpell.RankName()) and
                not RGMercUtils.SongActiveByName('Bestial Alignment') and
                not RGMercUtils.BuffActiveByName('Ferociousness')
        end,
        FerociousnessCheck = function(self)
            local discSpell = self.ResolvedActionMap['HHEFuryDisc']
            return discSpell and discSpell() and not RGMercUtils.SongActiveByName(discSpell.RankName()) and
                not RGMercUtils.SongActiveByName('Bestial Alignment')
        end,
    },
    ['Rotations']         = {
        ['Burn'] = {
            -- Set 1
            -- Besial Alignment (65+) when HHEFuryDisc (88+) and Ferociousness (105+) not active
            {
                name = "Bestial Alignment",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.ClassConfig.HelperFunctions.BeastialAligmentCheck(self)
                end,
            },
            -- Vindisc (102+) when HHEFuryDisc (88+) and Ferociousness (105+) not active, but Besial Alignment active
            {
                name = "Vindisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return self.ClassConfig.HelperFunctions.BeastialAligmentCheck(self)
                end,
            },
            -- Frenzy of Spirit (59+) when HHEFuryDisc (88+) and Ferociousness (105+) not active, but Besial Alignment active
            {
                name = "renzy of Spirit",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.ClassConfig.HelperFunctions.BeastialAligmentCheck(self)
                end,
            },
            -- Bloodlust (95+) when HHEFuryDisc (88+) and Ferociousness (105+) not active, but Besial Alignment active
            {
                name = "Bloodlust",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.ClassConfig.HelperFunctions.BeastialAligmentCheck(self)
                end,
            },
            -- Frenzied Swipes (100+) when HHEFuryDisc (88+) and Ferociousness (105+) not active, but Besial Alignment active
            {
                name = "Frenzied Swipes",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.ClassConfig.HelperFunctions.BeastialAligmentCheck(self)
                end,
            },
            -- Set 2
            -- HHEFuryDisc (88+) when Besial Alignment (65+) down and not active, and Ferociousness (105+) not active
            {
                name = "HHEFuryDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return self.ClassConfig.HelperFunctions.HHEFuryDiscCheckPrimary(self)
                end,
            },
            -- Spire of the Savage Lord (85+) when Besial Alignment (65+) and Ferociousness (105+) not active, but HHEFuryDisc active
            {
                name = "Spire of the Savage Lord",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.ClassConfig.HelperFunctions.HHEFuryDiscCheckSecondary(self)
                end,
            },
            -- DmgModDisc (60+) when Besial Alignment (65+) and Ferociousness (105+) not active, but HHEFuryDisc active
            {
                name = "DmgModDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return self.ClassConfig.HelperFunctions.HHEFuryDiscCheckSecondary(self)
                end,
            },
            -- Chest Click when Besial Alignment (65+) and Ferociousness (105+) not active, but HHEFuryDisc active (When we dont have HHEFuryDisc, fire off when available)
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return self.ClassConfig.HelperFunctions.BeastialAligmentCheck(self) and
                        RGMercUtils.GetSetting('DoChestClick') and item() and item.Spell.Stacks() and
                        item.TimerReady() == 0
                end,
            },
            -- Set 3
            -- Ferociousness (105+) when Besial Alignment (65+) and HHEFuryDisc (88+) down and not active
            {
                name = "Ferociousness",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.ClassConfig.HelperFunctions.FerociousnessCheck(self) and RGMercUtils.BuffActiveByName(aaName) and RGMercUtils.PCAAReady(aaName) and
                        not RGMercUtils.PCDiscReady(self.ResolvedActionMap['HHEFuryDisc'])
                end,
            },
            -- Companion's Fury (86+) when Ferociousness (105+) active and HHEFuryDisc (88+) and Besial Alignment (65+) not active (When we dont have Ferociousness, fire off when other conditions met)
            {
                name = "Companion's Fury",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.ClassConfig.HelperFunctions.FerociousnessCheck(self) and (not RGMercUtils.BuffActiveByName("Ferociousness") or
                        not RGMercUtils.CanUseAA("Ferociousness"))
                end,
            },
            -- Group Bestial Alignment (83+) when Ferociousness (105+) active and HHEFuryDisc (88+) and Besial Alignment (65+) not active (When we dont have Ferociousness, fire off when other conditions met)
            {
                name = "Group Bestial Alignment",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.ClassConfig.HelperFunctions.FerociousnessCheck(self) and (not RGMercUtils.BuffActiveByName("Ferociousness") or
                        not RGMercUtils.CanUseAA("Ferociousness"))
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
                    return RGMercUtils.GetSetting('DoSlow') and not RGMercUtils.CanUseAA("Sha's Reprisal") and not RGMercUtils.TargetHasBuff(spell) and
                        RGMercUtils.SpellStacksOnTarget(spell) and
                        spell.SlowPct() > (RGMercUtils.GetTargetSlowedPct())
                end,
            },
            {
                name = "Sha's Reprisal",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.GetSetting('DoSlow') and not RGMercUtils.TargetHasBuffByName(aaName) and
                        (mq.TLO.Me.AltAbility(aaName).Spell.SlowPct() or 0) > (RGMercUtils.GetTargetSlowedPct())
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
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetSetting('DoParagon') and (mq.TLO.Group.LowMana(RGMercUtils.GetSetting('ParagonPct'))() or -1) > 0
                end,
            },
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
                name = "Blooddot",
                type = "Spell",
                cond = function(self, spell, target)
                    local vindDisc = self.ResolvedActionMap['Vindisc']
                    if not vindDisc then return false end
                    return mq.TLO.Me.ActiveDisc.ID() == (vindDisc.ID() or 0)
                end,
            },
            {
                name = "Enduring Frenzy",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.GetTargetPctHPs() > 90
                end,
            },
            {
                name = "EndRegenProcDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return mq.TLO.Me.PctEndurance() < 10
                end,
            },
            {
                name = "Chameleon Strike",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "SingleClaws",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return not RGMercUtils.GetSetting('DoAoe')
                end,
            },
            {
                name = "AEClaws",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercUtils.GetSetting('DoAoe')
                end,
            },
            {
                name = "Maul",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return true
                end,
            },
            {
                name = "BeastialBuffDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercUtils.BuffActive(discSpell)
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return true
                end,
            },
            {
                name = "Maelstrom",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()
                end,
            },
            {
                name = "PoiBite",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()
                end,
            },
            {
                name = "FrozenPoi",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()
                end,
            },
            {
                name = "Icelance1",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()
                end,
            },
            {
                name = "Icelance2",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck()
                end,
            },
            {
                name = "Colddot",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.ManaCheck() and RGMercUtils.GetSetting('DoDot') and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell)
                end,
            },
            {
                name = "Blooddot",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.ManaCheck() and RGMercUtils.GetSetting('DoDot') and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell)
                end,
            },
            {
                name = "EndemicDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.ManaCheck() and RGMercUtils.GetSetting('DoDot') and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return RGMercUtils.GetSetting('DoRunSpeed') and not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "ManaRegenBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return RGMercConfig.Constants.RGCasters:contains(target.Class.ShortName()) and not RGMercUtils.TargetHasBuff(spell)
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return RGMercConfig.Constants.RGMelee:contains(target.Class.ShortName()) and not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.SpellStacksOnTarget(spell) and
                        RGMercUtils.GetSetting('DoAvatar')
                end,
            },
            {
                name = "GroupAtkBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "SingleAtkHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    local targetClass = target.Class.ShortName()
                    return (targetClass == "WAR" or targetClass == "PAL" or targetClass == "SHD") and not RGMercUtils.TargetHasBuff(spell) and
                        RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "GroupAtkHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "SingleAtkHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    local targetClass = target.Class.ShortName()
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return (targetClass == "WAR" or targetClass == "PAL" or targetClass == "SHD") and not RGMercUtils.TargetHasBuff(spell) and
                        RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "GroupFocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "SingleFocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    local targetClass = target.Class.ShortName()
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return (targetClass == "WAR" or targetClass == "PAL" or targetClass == "SHD") and not RGMercUtils.TargetHasBuff(spell) and
                        RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "PetSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Pet.ID() == 0
                end,
            },
            {
                name = "KillShotBuff",
                type = "Spell",
                cond = function(self, spell)
                    if not spell or not spell then return false end
                    return RGMercUtils.SelfBuffCheck(spell) and mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() == nil
                end,
            },
            {
                name = "Pact of The Wurine",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.SelfBuffAACheck(aaName) and (mq.TLO.Me.PctEndurance() < 21) end,
            },
            {
                name = "Consumption of Spirit",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.SelfBuffAACheck(aaName) and (mq.TLO.Me.PctHPs() > 70 and mq.TLO.Me.PctMana() < 80) end,
            },
            -- TODO: Does anyone even want this?
            --{
            --    name = "VerifyFerocity",
            --    type = "CustomFunc",
            --    custom_func = function(self, targetId)
            --        if not RGMercUtils.GetSetting('DoCombatFero') or not RGMercUtils.NPCSpellReady(self.ResolvedActionMap['SingleAtkBuff'], targetId, false) then return false end
            --        -- TODO: Ferocity List?
            --        return false
            --    end,
            --},
        },
        ['Pet Downtime'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    return RGMercUtils.GetSetting('DoEpic') and
                        mq.TLO.FindItem(itemName)() and mq.TLO.Me.ItemReady(itemName)() and
                        (mq.TLO.Me.PetBuff("Savage Wildcaller's Blessing")() == nil and mq.TLO.Me.PetBuff("Might of the Wild Spirits")() == nil)
                end,
            },
            {
                name = "Hobble of Spirits",
                type = "AA",
                cond = function(self, aaName, target)
                    local slowProc = self.ResolvedActionMap['PetSlowProc']
                    return RGMercUtils.GetSetting('DoSnare') and (slowProc and slowProc() and mq.TLO.Me.PetBuff(slowProc.RankName()) == nil) and
                        mq.TLO.Me.PetBuff(mq.TLO.Me.AltAbility(aaName).Spell.RankName.Name())() == nil
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell) and RGMercUtils.GetSetting('DoAvatar')
                end,
            },
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoRunSpeed') and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetOffenseBuff",
                type = "Spell",
                cond = function(self, spell)
                    return (not RGMercUtils.GetSetting('DoTankPet')) and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetDefenseBuff",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoTankPet') and RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetSlowProc",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoPetSlow') and RGMercUtils.SelfBuffPetCheck(spell)
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
                    return (not RGMercUtils.GetSetting('DoTankPet')) and RGMercUtils.SelfBuffPetCheck(spell)
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
                    return RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetGrowl",
                type = "Spell",
                cond = function(self, spell)
                    return (not RGMercUtils.GetSetting('DoSwarmPet')) and not RGMercUtils.SongActiveByName(spell.RankName())
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "HealSpell", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "PetHealSpell", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "Icelance1", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "Icelance2", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "Blooddot", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "GroupAtkBuff", },
                { name = "SingleAtkBuff", },
                { name = "RunSpeedBuff", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "SlowSpell",  cond = function(self) return RGMercUtils.GetSetting('DoSlow') end, },
                { name = "EndemicDot", cond = function(self) return RGMercUtils.GetSetting('DoDot') end, },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "PoiBite", },
                { name = "SwarmPet", cond = function(self) return RGMercUtils.GetSetting('DoSwarmPet') end, },
                { name = "PetGrowl", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PoiBite", },
                { name = "SwarmPet", cond = function(self) return RGMercUtils.GetSetting('DoSwarmPet') end, },
                { name = "PetGrowl", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "FrozenPoi", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Maelstrom", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Colddot", },
            },
        },
    },
    ['PullAbilities']     = {
        {
            id = 'Slow',
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
    ['DefaultConfig']     = {
        ['Mode']         = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 1, },
        ['DoCombatFero'] = { DisplayName = "Do Combat Fero", Category = "Combat", Tooltip = "Do Combat Fero", Default = true, },
        ['DoParagon']    = { DisplayName = "Do Paragon", Category = "Combat", Tooltip = "Cast Paragon on lowest mana in Group / XT", Default = true, },
        ['ParagonPct']   = { DisplayName = "Paragon Min Pct", Category = "Combat", Tooltip = "Minimum mana % before we cast Paragon on someone", Default = 60, Min = 1, Max = 99, },
        ['DoEpic']       = { DisplayName = "Do Epic", Category = "Abilities", Tooltip = "Enable using your epic clicky", Default = true, },
        ['DoSnare']      = { DisplayName = "Cast Snares", Category = "Spells and Abilities", Tooltip = "Enable casting Snare spells.", Default = true, },
        ['DoRunSpeed']   = { DisplayName = "Do Run Speed", Category = "Buffs", Tooltip = "Do Run Speed Spells/AAs", Default = true, },
        ['DoTankPet']    = { DisplayName = "Do Tank Pet", Category = "Buffs", Tooltip = "DoTankPet", Default = true, },
        ['DoPetSlow']    = { DisplayName = "Do Pet Slow", Category = "Buffs", Tooltip = "DoPetSlow", Default = true, },
        ['DoSlow']       = { DisplayName = "Do Slow", Category = "Buffs", Tooltip = "DoSlow", Default = true, },
        ['DoSwarmPet']   = { DisplayName = "Do Swarm Pet", Category = "Buffs", Tooltip = "DoSwarmPet", Default = true, },
        ['DoChestClick'] = { DisplayName = "Do Chest Click", Category = "Utilities", Tooltip = "Click your chest item", Default = true, },
        ['DoAoe']        = { DisplayName = "Do AoE", Category = "Abilities", Tooltip = "Enable using AoE Abilities", Default = true, },
        ['DoDot']        = { DisplayName = "Cast DOTs", Category = "Spells and Abilities", Tooltip = "Enable casting Damage Over Time spells.", Default = true, },
        ['HPStopDOT']    = { DisplayName = "HP Stop DOTs", Category = "Spells and Abilities", Tooltip = "Stop casting DOTs when the mob hits [x] HP %.", Default = 30, Min = 1, Max = 100, },
        ['DoAvatar']     = { DisplayName = "Do Avatar", Category = "Buffs", Tooltip = "Buff Group/Pet with Avatar", Default = true, },
    },
}
