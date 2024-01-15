local mq           = require('mq')
local RGMercUtils  = require("utils.rgmercs_utils")

local Tooltips     = {
    Epic             = 'Item: Casts Epic Weapon Ability',
    BardRunBuff      = "Song Line: Movement Speed Modifier",
    MainAriaSong     = "Song Line: Spell Focus Modifier",
    SufferingSong    = "Song Line Line: Melee Proc With Agro Reduction",
    SprySonataSong   = "Song Line: Magic Asorb AC Increase Mitigate Damage Shield Resist Spells",
    PsalmSong        = "Song Line: Spell Damage Focus Haste v3",
    CrescendoSong    = "Song Line: Group v2 Increase Hit Points and Mana",
    ArcaneSong       = "Song Line: Caster Spell Proc",
    InsultSong       = "Song Line: Single Target DD",
    DichoSong        = "Song Line: Triggers Psalm of Empowerment and Psalm of Potential H/M/E Increase Melee and Caster Dam Increase",
    BardDPSAura      = "Aura Line: OverHaste, Melee/Caster DPS",
    BardRegenAura    = "Aura Line: HP/Mana Regen",
    PulseRegenSong   = "Song Line: HP/Mana/Endurence Regen Increases Healing Yield",
    ChorusRegenSong  = "Song Line: AE HP/Mana Regen",
    CantataRegenSong = "Song Line: Group HP/Mana Regen",
    WarMarchSong     = "Song Line: Melee Haste + DS + STR/ATK Increase",
    CasterAriaSong   = "Song Line: Fire DD Damage Increase + Effiency",
    SlowSong         = "Song Line: Melee Attack Slow",
    AESlowSong       = "Song Line: PBAE Melee Attack Slow",
    AccelerandoSong  = "Song Line: Reduce Cast Time (Beneficial Only) Agro Reduction Modifier",
    SpitefulSong     = "Song Line: Increase AC Agro Increase Proc",
    RecklessSong     = "Song Line: Increase Crit Heal and Crit HoT",
    FateSong         = "Song Line: Cold DD Damage Increae + Effiency",
    DotSong          = "Song Line:  DoT Damage Songs",
    CureSong         = "Song Line: Single Target Cure Poison Disease and Corruption",
    AllianceSong     = "Song Line: Mob Debuff Increase Insult Damage for other Bards",
    CharmSong        = "Song Line: Charm Mob",
    ReflexStrike     = "Disc Line: Attack 4 times to restore Mana to Group",
    ChordsAE         = "Song Line: PBAE Damage if Target isn't moving",
    LowAriaSong      = "Song Line: Warsong and BattleCry prior to combination of effects into Aria",
    AmpSong          = "Song Line: Increase Singing Skill",
    DispelSong       = "Song Line: Dispell",
    ResistSong       = "Song Line: Group Resist Increase",
    MezSong          = "Song Line: Single Target Mez",
    MezAESong        = "Song Line: PBAE Mez",
    Bellow           = "AA: Stuns Initial DD Damage and Increases Resist Modifier on Mob Concludes with DD",
    Spire            = "AA: Lowers Incoming Melee Damage and Increases Melee and Spell Damage",
    FuneralDirge     = "AA: DD and Increases Melee Damage to Target",
    FierceEye        = "AA: Increases Base Melee Damage and Increase Melee Crit Damage and Increase Proc Rate and Increase Crit Chance on Spells",
    QuickTime        = "AA: Hundred Hands Effect and Increase Melee Hit and Increase Atk",
    BladedSong       = "AA: Reverse Damage Shield",
    Jonthans         = "Song Line: Self-only Haste Melee Damage Modifier Melee Min Damage Modifier Proc Modifier",
}

local _ClassConfig = {
    _version          = "0.1a",
    _author           = "Tiddliestix",

    ['Modes']         = {
        'DPS',
        'Hybrid',
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Blade of Vesagran",
            "Priismatic Dragon Blade",
        },
    },
    ['AbilitySets']   = {
        ['BardRunBuff'] = {
            -- Bard RunSpeed
            "Selo's Accelerato",
            -- Song of travel has been removed due to causing Bugs with Invis and rotation.
            -- [] = ["Selo's Song of Travel"],
            "Selo's Accelerating Chorus",
            "Selo's Accelerando",
        },
        ['MainAriaSong'] = {
            -- MainAriaSong - Level Ranges 45 - 111
            -- What differs between PsalmSong and MainAriaSong ???
            "Aria of Pli Xin Liako",
            "Aria of Margidor",
            "Aria of Begalru",
            "Aria of Maetanrus",
            "Aria of Va'Ker",
            "Aria of the Orator",
            "Aria of the Composer",
            "Aria of the Poet",
            "Ancient: Call of Power",
            "Aria of the Artist",
            "Yelhun's Mystic Call",
            "Ancient: Call of Power",
            "Rizlona's Call of Flame",
            "Rizlona's Fire",
            "Rizlona's Embers",
        },
        ['SufferingSong'] = {
            -- SufferingSong - Level Range 89 - 114
            "Shojralen's Song of Suffering",
            "Omorden's Song of Suffering",
            "Travenro's Song of Suffering",
            "Fjilnauk's Song of Suffering",
            "Kaficus' Song of Suffering",
            "Hykast's Song of Suffering",
            "Noira's Song of Suffering",
        },
        ['SprySonataSong'] = {
            -- Adding misc songs below level 77 to fill in first spell gem
            -- [] = 'Psalm of Veeshan",
            -- [] = "Nillipus' March of the Wee",
            -- [] = "Verses of Victory",
            -- [] = "Psalm of Mystic Shielding",
            -- [] = "Psalm of Cooling",
            -- [] = "Psalm of Vitality",
            -- [] = "Psalm of Warmth",
            -- [] = "Guardian Rhythms",
            -- [] = Purifying Rhythms",
            -- [] = "Elemental Rhythms",
            -- [] = "Jonthan's Whistling Warsong",
            -- [] = "Chant of Battle",
            -- SprySonataSong - Level Range 77 - 118
            "Xetheg's Spry Sonata",
            "Kellek's Spry Sonata",
            "Kluzen's Spry Sonata",
            "Doben's Spry Sonata",
            "Terasal's Spry Sonata",
            "Sionachie's Spry Sonata",
            "Coldcrow's Spry Sonata",
        },
        ['CrescendoSong'] = {
            -- CrescendoSong - Level Range 75 - 114
            "Zelinstein's Lively Crescendo",
            "Zburator's Lively Crescendo",
            "Jembel's Lively Crescendo",
            "Silisia's Lively Crescendo",
            "Motlak's Lively Crescendo",
            "Kolain's Lively Crescendo",
            "Lyssa's Lively Crescendo",
            "Gruber's Lively Crescendo",
            "Kaerra's Spirited Crescendo",
            "Veshma's Lively Crescendo",
        },
        ['ArcaneSong'] = {
            -- ArcaneSong - Level Range 70 - 115
            "Arcane Harmony",
            "Arcane Symphony",
            "Arcane Ballad",
            "Arcane Melody",
            "Arcane Hymn",
            "Arcane Address",
            "Arcane Chorus",
            "Arcane Arietta",
            "Arcane Anthem",
            "Arcane Aria",
        },
        ['InsultSong'] = {
            "Nord's Disdain",
            "Sogran's Insult",
            "Yelinak's Insult",
            "Omorden's Insult",
            "Sathir's Insult",
            "Travenro's Insult",
            "Tsaph's Insult",
            "Fjilnauk's Insult",
            "Kaficus' Insult",
            "Garath's Insult",
            "Hykast's Insult",
            "Venimor's Insult",
            -- Below Level 85 This line turns into "bellow" instead of "Insult"
            "Bellow of Chaos",
            "Brusco's Bombastic Bellow",
            "Brusco's Boastful Bellow",
        },
        ['DichoSong'] = {
            -- DichoSong Level Range - 101 - 106
            "Ecliptic Psalm",
            "Composite Psalm",
            "Dissident Psalm",
            "Dichotomic Psalm",
        },
        ['BardDPSAura'] = {
            -- BardDPSAura - Level Ranges 55 - 115
            "Aura of Pli Xin Liako",
            "Aura of Margidor",
            "Aura of Begalru",
            "Aura of Maetanrus",
            "Aura of Va'Ker",
            "Aura of the Orator",
            "Aura of the Composer",
            "Aura of the Poet",
            "Aura of the Artist",
            "Aura of the Muse",
            "Aura of Insight",
        },
        ['BardRegenAura'] = {
            "Aura of Shei Vinitras",
            "Aura of Vhal`Sera",
            "Aura of Xigam",
            "Aura of Sionachie",
            "Aura of Salarra",
            "Aura of Lunanyn",
            "Aura of Renewal",
            "Aura of Rodcet",
        },
        ['PulseRegenSong'] = {
            -- PulseRegenSong - Level Range 77 - 111 ** -- Low level regens are for TLP users thus preferring mana over health.
            "Pulse of Nikolas",
            "Pulse of Vhal`Sera",
            "Pulse of Xigam",
            "Pulse of Sionachie",
            "Pulse of Salarra",
            "Pulse of Lunanyn",
            "Pulse of Renewal",
            "Pulse of Rodcet",
            "Cassindra's Chorus of Clarity",
            "Cassindra's Chant of Clarity",
            "Rhythm of Restoration",
        },
        ['ChorusRegenSong'] = {
            -- ChorusRegenSong - Level Range 6 - 113
            "Chorus of Shei Vinitras",
            "Chorus of Vhal`Sera",
            "Chorus of Xigam",
            "Chorus of Sionachie",
            "Chorus of Salarra",
            "Chorus of Lunanyn",
            "Chorus of Renewal",
            "Chorus of Rodcet",
            "Cantata of Rodcet",
            "Chorus of Restoration",
            "Cantata of Restoration",
            "Erollisi's Cantata",
            "Chorus of Life",
            "Cantata of Life",
            "Chorus of Marr",
            "Wind of Marr",
            "Chorus of Replenishment",
            "Cantata of Replenishment",
            "Cantata of Soothing",
            "Hymn of Restoration",
        },
        ['CantataRegenSong'] = {
            -- CantataRegenSong - Level Range 6 - 113
            "Cantata of Rodcet",
            "Cantata of Restoration",
            "Erollisi's Cantata",
            "Cantata of Life",
            "Wind of Marr",
            "Cantata of Replenishment",
            "Cantata of Soothing",
            "Hymn of Restoration",
        },
        ['WarMarchSong'] = {
            -- WarMarchSong Level Range 10 - 114
            "War March of Centien Xi Va Xakra",
            "War March of Radiwol",
            "War March of Dekloaz",
            "War March of Jocelyn",
            "War March of Protan",
            "War March of Illdaera",
            "War March of Dagda",
            "War March of Brekt",
            "War March of Meldrath",
            "War March of Muram",
            "War March of the Mastruq",
            "Warsong of Zek",
            "McVaxius' Rousing Rondo",
            "Vilia's Chorus of Celerity",
            "Verses of Victory",
            "McVaxius' Berserker Crescendo",
            "Vilia's Verses of Celerity",
            "Anthem de Arms",
        },
        ['CasterAriaSong'] = {
            -- CasterAriaSong - Level Range 72 - 113
            "Constance's Aria",
            "Sontalak's Aria",
            "Qunard's Aria",
            "Nilsara's Aria",
            "Gosik's Aria",
            "Daevan's Aria",
            "Sotor's Aria",
            "Talendor's Aria",
            "Performer's Explosive Aria",
            "Weshlu's Chillsong Aria",
        },
        ['SlowSong'] = {
            -- SlowSong - We only get 1 single target slow
            "Requiem of Time",
        },
        ['AESlowSong'] = {
            -- AESlowSong - Level Range 20 - 114 (Single target works better)
            "Radiwol's Melodic Binding",
            "Dekloaz's Melodic Binding",
            "Protan's Melodic Binding",
            "Largo's Melodic Binding",
        },
        ['AccelerandoSong'] = {
            -- AccelerandoSong - Level Range 88 - 113 **
            "Satisfying Accelerando",
            "Placating Accelerando",
            "Atoning Accelerando",
            "Allaying Accelerando",
            "Ameliorating Accelerando",
            "Assuaging Accelerando",
            "Alleviating Accelerando",
        },
        ['SpitefulSong'] = {
            -- SpitefulSong - Level Range 90 -
            "Von Deek's Spiteful Lyric",
            "Omorden's Spiteful Lyric",
            "Travenro's Spiteful Lyric",
            "Fjilnauk's Spiteful Lyric",
            "Kaficus' Spiteful Lyric",
            "Hykast's Spiteful Lyric",
            "Lyrin's Spiteful Lyric",
        },
        ['RecklessSong'] = {
            -- RecklessSong - Level Range 93 - 113 **
            "Kai's Reckless Renewal",
            "Reivaj's Reckless Renewal",
            "Rigelon's Reckless Renewal",
            "Rytan's Reckless Renewal",
            "Ruaabri's Reckless Renewal",
            "Ryken's Reckless Renewal",
        },
        ['FateSong'] = {
            -- Fatesong - Level Range 77 - 112 **
            "Fatesong of Lucca",
            "Fatesong of Radiwol",
            "Fatesong of Dekloaz",
            "Fatesong of Jocelyn",
            "Fatesong of Protan",
            "Fatesong of Illdaera",
            "Fatesong of Fergar",
            "Fatesong of the Gelidran",
            "Garadell's Fatesong",
        },
        ['PsalmSong'] = {
            -- PsalmSong - Level Range 69 - 112 **
            -- What differs between PsalmSong and MainAriaSong ???
            "Fyrthek Fior's Psalm of Potency",
            "Velketor's Psalm of Potency",
            "Akett's Psalm of Potency",
            "Horthin's Psalm of Potency",
            "Siavonn's Psalm of Potency",
            "Wasinai's Psalm of Potency",
            "Lyrin's Psalm of Potency",
            "Druzzil's Psalm of Potency",
            "Erradien's Psalm of Potency",
            "Performer's Psalm of Pyrotechnics",
            "Ancient: Call of Power",
            "Eriki's Psalm of Power",
        },
        ['DotSong'] = {
            -- DotSongs - Level Range 30 - 115

            -- Fire Dot
            "Shak Dathor's Chant of Flame",
            "Sontalak's Chant of Flame",
            "Qunard's Chant of Flame",
            "Nilsara's Chant of Flame",
            "Gosik's Chant of Flame",
            "Daevan's Chant of Flame",
            "Sotor's Chant of Flame",
            "Talendor's Chant of Flame",
            "Tjudawos' Chant of Flame",
            "Vulka's Chant of Flame",
            "Tuyen's Chant of Fire",
            "Tuyen's Chant of Flame",

            -- Posion Dot
            "Cruor's Chant of Poison",
            "Malvus's Chant of Poison",
            "Nexona's Chant of Poison",
            "Serisaria's Chant of Poison",
            "Slaunk's Chant of Poison",
            "Hiqork's Chant of Poison",
            "Spinechiller's Chant of Poison",
            "Severilous' Chant of Poison",
            "Kildrukaun's Chant of Poison",
            "Vulka's Chant of Poison",
            "Tuyen's Chant of Venom",
            "Tuyen's Chant of Poison",

            -- Ice Dot
            "Sylra Fris' Chant of Frost",
            "Yelinak's Chant of Frost",
            "Ekron's Chant of Frost",
            "Kirchen's Chant of Frost",
            "Edoth's Chant of Frost",
            "Kalbrok's Chant of Frost",
            "Fergar's Chant of Frost",
            "Gorenaire's Chant of Frost",
            "Zeixshi-Kar's Chant of Frost",
            "Vulka's Chant of Frost",
            "Tuyen's Chant of Ice",
            "Tuyen's Chant of Frost",

            -- Disease Dot
            "Coagulus' Chant of Disease",
            "Zlexak's Chant of Disease",
            "Hoshkar's Chant of Disease",
            "Horthin's Chant of Disease",
            "Siavonn's Chant of Disease",
            "Wasinai's Chant of Disease",
            "Shiverback's Chant of Disease",
            "Trakanon's Chant of Disease",
            "Vyskudra's Chant of Disease",
            "Vulka's Chant of Disease",
            "Tuyen's Chant of the Plague",
            "Tuyen's Chant of Disease",

            -- Misc Dot -- Or Minsc Dot (HEY HEY BOO BOO!)
            "Ancient: Chaos Chant",
            "Angstlich's Assonance",
            "Fufil's Diminishing Dirge",
            "Fufil's Curtailing Chant",
        },
        ['CureSong'] = {
            -- Multiple Missing --
            "Aria of Absolution",
        },
        ['AllianceSong'] = {
            "Conjunction of Sticks and Stones",
            "Alliance of Sticks and Stones",
            "Covenant of Sticks and Stones",
            "Coalition of Sticks and Stones",
        },
        ['CharmSong'] = {
            "Omiyad's Demand",
            "Voice of the Diabo",
            "Silisia's Demand",
            "Dawnbreeze's Demand",
            "Desirae's Demand",
            -- Low Level Aria Song - before Combination of Effects Under Level 68
            "Battlecry of the Vah Shir",
            "Warsong of the Vah Shir",
        },
        ['ReflexStrike'] = {
            -- Bard ReflexStrike - Restores mana to group
            "Reflexive Retort",
            "Reflexive Rejoinder",
            "Reflexive Rebuttal",
        },
        ['ChordsAE'] = {
            "Chords of Dissonance",
        },
        ['LowAriaSong'] = {
            -- Low Level Aria Song - before Combination of Effects Under Level 68
            "Battlecry of the Vah Shir",
            "Warsong of the Vah Shir",
        },
        ['AmpSong'] = {
            "Amplification",
        },
        ['DispelSong'] = {
            -- Dispel Song - For pulling to avoid Summons
            "Syvelian's Anti-Magic Aria",
            "Druzzil's Disillusionment",
        },
        ['ResistSong'] = {
            -- Resists Song
            "Psalm of Cooling",
            "Psalm of Purity",
            "Psalm of Warmth",
            "Psalm of Vitality",
            "Psalm of Veeshan",
            "Psalm of the Forsaken",
            "Second Psalm of Veeshan",
            "Psalm of the Restless",
            "Psalm of the Pious",
        },
        ['MezSong'] = {
            -- MezSong - Level Range 15 - 114
            "Slumber of the Diabo",
            -- [] = "Lullaby of Nightfall",
            -- [] = "Lullaby of Zburator",
            "Slumber of Zburator",
            "Slumber of Jembel",
            -- [] = "Lullaby of Jembel",
            "Slumber of Silisia",
            -- [] = "Lullaby of Silisia",
            "Slumber of Motlak",
            -- [] = "Lullaby of the Forsaken",
            "Slumber of Kolain",
            -- [] = "Lullaby of the Forlorn",
            "Slumber of Sionachie",
            -- [] = "Lullaby of the Lost",
            "Slumber of the Mindshear",
            "Serenity of Oceangreen",
            "Amber's Last Lullaby",
            "Queen Eletyl's Screech",
            "Command of Queen Veneneu",
            "Aelfric's Last Lullaby",
            "Vulka's Lullaby",
            "Creeping Dreams",
            "Luvwen's Lullaby",
            "Lullaby of Morell",
            "Dreams of Terris",
            "Dreams of Thule",
            "Dreams of Ayonae",
            "Song of Twilight",
            "Sionachie's Dreams",
            "Crission's Pixie Strike",
            "Kelin's Lucid Lullaby",
        },
        ['MezAESong'] = {
            -- MezAESong - Level Range 85 - 115 **
            "Wave of Nocturn",
            "Wave of Sleep",
            "Wave of Somnolence",
            "Wave of Torpor",
            "Wave of Quietude",
            "Wave of the Conductor",
            "Wave of Dreams",
            "Wave of Slumber",
        },
    },
    ['Rotations']     = {
        ['Burn'] = {
        },
        ['Debuff'] = {
        },
        ['Heal'] = {
        },
        ['DPS'] = {
        },
        ['Downtime'] = {
        },
    },
    ['Spells']        = {
        {
            gem = 1,
            spells = {
                -- { name = "NAME FROM ABILITY SET LIST", cond = function(self) return mq.TLO.Me.Level() < 86 end, },
            },
        },
        {
            gem = 2,
            spells = {
            },
        },
        {
            gem = 3,
            spells = {
            },
        },
        {
            gem = 4,
            spells = {
            },
        },
        {
            gem = 5,
            spells = {
            },
        },
        {
            gem = 6,
            spells = {
            },
        },
        {
            gem = 7,
            spells = {
            },
        },
        {
            gem = 8,
            spells = {
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
            },
        },
    },
    ['DefaultConfig'] = {
        ['Mode'] = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 2, },
    },

}
return _ClassConfig
