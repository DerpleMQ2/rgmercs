--- @type Mq
local mq             = require('mq')
local BL             = require("biggerlib")
local RGMercUtils    = require("utils.rgmercs_utils")
local RGMercsLogger  = require("utils.rgmercs_logger")

local Tooltips       = {
    Epic             = 'Item: Casts Epic Weapon Ability',
    BardRunBuff      = "Song Line: Movement Speed Modifier",

    MainAriaSong     = "Song Line: Spell Damage Focus Haste v3 Modifier",
    WarMarchSong     = "Song Line: Melee Haste + DS + STR/ATK Increase",
    SufferingSong    = "Song Line Line: Melee Proc With Agro Reduction",
    SpitefulSong     = "Song Line: Increase AC Agro Increase Proc",
    SprySonataSong   = "Song Line: Magic Asorb AC Increase Mitigate Damage Shield Resist Spells",
    PotencySong      = "Song Line: Fire and Magic DoT Modifier",
    CrescendoSong    = "Song Line: Group v2 Increase Hit Points and Mana",
    ArcaneSong       = "Song Line: Caster Spell Proc",
    InsultSong       = "Song Line: Single Target DD",
    DichoSong        =
    "Song Line: Triggers Psalm of Empowerment and Psalm of Potential H/M/E Increase Melee and Caster Dam Increase",
    BardDPSAura      = "Aura Line: OverHaste, Melee/Caster DPS",
    BardRegenAura    = "Aura Line: HP/Mana Regen",
    PulseRegenSong   = "Song Line: HP/Mana/Endurence Regen Increases Healing Yield",
    ChorusRegenSong  = "Song Line: AE HP/Mana Regen",
    CantataRegenSong = "Song Line: Group HP/Mana Regen",
    CasterAriaSong   = "Song Line: Fire DD Damage Increase + Effiency",
    SlowSong         = "Song Line: Melee Attack Slow",
    AESlowSong       = "Song Line: PBAE Melee Attack Slow",
    AccelerandoSong  = "Song Line: Reduce Cast Time (Beneficial Only) Agro Reduction Modifier",
    RecklessSong     = "Song Line: Increase Crit Heal and Crit HoT",
    FateSong         = "Song Line: Cold DD Damage Increae + Effiency",
    -- Splitting DoT lines into individual dots because it is often useful to drop 1-2 dots for some other song on raids
    FireDotSong      = "Song Line: Fire Dots",
    ColdDotSong      = "Song Line: Cold Dots",
    DiseaseDotSong   = "Song Line: Disease Dots",
    PoisonDotSong    = "Song Line: Poison Dots",

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
    FierceEye        =
    "AA: Increases Base Melee Damage and Increase Melee Crit Damage and Increase Proc Rate and Increase Crit Chance on Spells",
    QuickTime        = "AA: Hundred Hands Effect and Increase Melee Hit and Increase Atk",
    BladedSong       = "AA: Reverse Damage Shield",
    Jonthans         = "Song Line: Self-only Haste Melee Damage Modifier Melee Min Damage Modifier Proc Modifier",
}

-- Some durations are not accurate/updated (all missing ones will be 30000s right now)
local _SongDurations = {
    Epic             = { duration = 180000, lastUsed = 0 },
    BardRunBuff      = { duration = 280000, lastUsed = 0 },
    MainAriaSong     = { duration = 30000, lastUsed = 0 },
    SufferingSong    = { duration = 30000, lastUsed = 0 },
    SprySonataSong   = { duration = 30000, lastUsed = 0 },
    PsalmSong        = { duration = 30000, lastUsed = 0 },
    CrescendoSong    = { duration = 45000, lastUsed = 0 },
    ArcaneSong       = { duration = 30000, lastUsed = 0 },
    InsultSong       = { duration = 6000, lastUsed = 0 },
    DichoSong        = { duration = 66000, lastUsed = 0 },
    BardDPSAura      = { duration = 999999, lastUsed = 0 },
    BardRegenAura    = { duration = 999999, lastUsed = 0 },
    PulseRegenSong   = { duration = 30000, lastUsed = 0 },
    ChorusRegenSong  = { duration = 30000, lastUsed = 0 },
    CantataRegenSong = { duration = 30000, lastUsed = 0 },
    WarMarchSong     = { duration = 30000, lastUsed = 0 },
    CasterAriaSong   = { duration = 30000, lastUsed = 0 },
    SlowSong         = { duration = 30000, lastUsed = 0 },
    AESlowSong       = { duration = 30000, lastUsed = 0 },
    AccelerandoSong  = { duration = 30000, lastUsed = 0 },
    SpitefulSong     = { duration = 30000, lastUsed = 0 },
    RecklessSong     = { duration = 30000, lastUsed = 0 },
    FateSong         = { duration = 30000, lastUsed = 0 },
    FireDotSong      = { duration = 18000, lastUsed = 0 },
    IceDotSong       = { duration = 18000, lastUsed = 0 },
    PoisonDotSong    = { duration = 18000, lastUsed = 0 },
    DiseaseDotSong   = { duration = 18000, lastUsed = 0 },
    CureSong         = { duration = 30000, lastUsed = 0 },
    AllianceSong     = { duration = 30000, lastUsed = 0 },
    CharmSong        = { duration = 30000, lastUsed = 0 },
    ReflexStrike     = { duration = 30000, lastUsed = 0 },
    ChordsAE         = { duration = 30000, lastUsed = 0 },
    LowAriaSong      = { duration = 30000, lastUsed = 0 },
    AmpSong          = { duration = 66000, lastUsed = 0 },
    DispelSong       = { duration = 30000, lastUsed = 0 },
    ResistSong       = { duration = 30000, lastUsed = 0 },
    MezSong          = { duration = 60000, lastUsed = 0 },
    MezAESong        = { duration = 60000, lastUsed = 0 },
    Bellow           = { duration = 18000, lastUsed = 0 },
    Spire            = { duration = 450000, lastUsed = 0 },
    FuneralDirge     = { duration = 540000, lastUsed = 0 },
    FierceEye        = { duration = 180000, lastUsed = 0 },
    QuickTime        = { duration = 600000, lastUsed = 0 },
    BladedSong       = { duration = 240000, lastUsed = 0 },
    Jonthans         = { duration = 30000, lastUsed = 0 },
}

-- IDEAS FROM DISCORD https://discord.com/channels/511690098136580097/840375268685119499/1203685271577825310
-- mq.TLO.Me.BardSongPlaying
--  mq.TLO.Me.Casting().ID
-- mq.TLO.Me.CastTimeLeft()
-- I think the combination of Casting() and CastTimeLeft() should work for you.
-- CastTimeLeft, when a song is casting is the number of miliseconds left on the cast.   If you know what you're going to cast,
--say "Selo's Accelerando", you can see that it has a cast time of 3 seconds, so any value > 3000 on
--CastTimeLeft() means the song is currenly being sung.   Casting() will return nil when no songs are sung.
-- Currently casttimeleft OVERFLOWS so you want to check to see if the number > some very large number like 99999999
-- So something like BardSongPlaying && Me.CastTimeLeft() > 9999 means that song is done casting.

-- mq.TLO.Me.FindBuff("name Spiritual Enduement").Duration -- This gives how much time is left on a buff/debuff, becomes null in macroland once it wears off

-- Trying to remain somewhat efficient but this cache is going to end up outdated without some sort of dirty flag from the UI signaling an option change


-- This function parses Config and builds a list of 13 gems via priority as follows:
-- AoE Mez goes first if enabled
-- Aria and Warmarch are both "Primary" and should always be used

local function generateSongList()
    local songCache = {}
    local songCount = 0

    --------------------------------------------------------------------------------------
    local function addSong(songToAdd)
        songCount = songCount + 1
        table.insert(songCache, {
            gem = songCount,
            spells = {
                { name = songToAdd, cond = function(self) return true end, },
            },
        })
    end

    local function ConditionallyAddSong(settingToCheck, songToAdd)
        if RGMercUtils.GetSetting(settingToCheck) then
            addSong(songToAdd)
        end
    end

    local function AddCriticalSongs()
        ConditionallyAddSong("DoAEMez", "MezAESong")
        ConditionallyAddSong("DoSlow", "SlowSong")
        ConditionallyAddSong("DoAESlow", "AESlowSong")
        -- TODO maybe someday
        --ConditionallyAddSong("DoCharm", "CharmSong")
        ConditionallyAddSong("DoDispel", "DispelSong")
    end

    local function AddMainGroupDPSSongs()
        addSong('WarMarchSong')
        addSong('MainAriaSong')
        ConditionallyAddSong('UseProgressive', 'DichoSong')
    end

    local function AddSelfDPSSongs()
        ConditionallyAddSong("UseAlliance", "AllianceSong")
        ConditionallyAddSong("UseInsult", 'InsultSong')
        ConditionallyAddSong("UseFireDots", "FireDotSong")
        ConditionallyAddSong("UseIceDots", "IceDotSong")
        ConditionallyAddSong("UseDiseaseDots", "DiseaseDotSong")
        ConditionallyAddSong("UsePoisonDots", "PoisonDotSong")
    end

    local function AddMeleeDPSSongs()
        ConditionallyAddSong("UseSuffering", "SufferingSong")
    end

    local function AddTankSongs()
        ConditionallyAddSong("UseSpiteful", "SpitefulSong")
        ConditionallyAddSong("UseSpry", "SprySonataSong")
        ConditionallyAddSong("UseResist", "ResistSong")
    end

    local function AddHealerSongs()
        ConditionallyAddSong("UseReckless", "RecklessSong")
        ConditionallyAddSong("UsePulse", "PulseRegenSong")
    end

    local function AddCasterDPSSongs()
        ConditionallyAddSong("UseArcane", "ArcaneSong")
        ConditionallyAddSong("UseFireDDMod", "CasterAriaSong")
        ConditionallyAddSong("UseFate", "FateSong")
        ConditionallyAddSong("UsePotency", "PotencySong")
    end

    local function AddRegenSongs()
        ConditionallyAddSong("UseAmp", "AmpSong")
        ConditionallyAddSong("UseCrescendo", "CrescendoSong")
        ConditionallyAddSong("UseChorus", "ChorusRegenSong")
        ConditionallyAddSong("UseCantata", "CantataRegenSong")
    end
    -----------------------------------------------------------------------------------------
    local mode = RGMercUtils.GetSetting("Mode")
    AddCriticalSongs()
    if mode == 1 then -- General
        AddMainGroupDPSSongs()
        AddSelfDPSSongs()
        AddRegenSongs()
        AddMeleeDPSSongs()
        AddCasterDPSSongs()
        AddHealerSongs()
        AddTankSongs()
    elseif mode == 2 then -- Tank
        AddTankSongs()
        AddMainGroupDPSSongs()
        AddHealerSongs()
        AddMeleeDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddCasterDPSSongs()
    elseif mode == 3 then -- Caster
        AddMainGroupDPSSongs()
        AddCasterDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddMeleeDPSSongs()
        AddHealerSongs()
        AddTankSongs()
    elseif mode == 4 then -- Healer
        AddHealerSongs()
        AddMainGroupDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddCasterDPSSongs()
        AddTankSongs()
        AddMeleeDPSSongs()
    else
        RGMercsLogger.log_warning("Bard Mode not found!  Adding DPS songs, but you should select a mode.")
        AddMainGroupDPSSongs()
        AddSelfDPSSongs()
        AddRegenSongs()
        AddMeleeDPSSongs()
        AddCasterDPSSongs()
    end

    if songCount > 13 then
        RGMercsLogger.log_warning("WARNING your bard is trying to memorize too many songs!  Please unselect some.")
        while #songCache > 13 do
            table.remove(songCache)
        end
    end

    return songCache
end

local function gs(setting)
    -- print out in gs
    
    return RGMercUtils.GetSetting(setting)
end

--- Checks target for duration remaining on dot songs
local function getDetSongDuration(songSpell)
    local duration = mq.TLO.Target.FindBuff("name " .. songSpell.Name()).Duration.TotalSeconds() or 0
    --BL.info("Det song duration is: ", duration)
    return duration
end

local _ClassConfig = {
    _version          = "0.2a",
    _author           = "Derple, Tiddliestix, SonicZentropy",
    ['Modes']         = {
        'General',
        'Tank',
        'Caster',
        'Healer'
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Blade of Vesagran",
            "Prismatic Dragon Blade",
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
            "Aria of Tenisbre", -- 125
            "Aria of Pli Xin Liako",
            "Aria of Margidor",
            "Aria of Begalru",
            "Aria of Maetanrus",
            "Aria of Va'Ker",
            "Aria of the Orator",
            "Aria of the Composer",
            "Aria of the Poet",
            "Performer's Psalm of Pyrotechnics",
            "Ancient: Call of Power",
            "Aria of the Artist",
            "Yelhun's Mystic Call",
            "Ancient: Call of Power",
            "Rizlona's Call of Flame",
            "Rizlona's Fire",
            "Rizlona's Embers",
            "Eriki's Psalm of Power",
        },
        ['SufferingSong'] = {
            -- SufferingSong - Level Range 89 - 114
            "Kanghammer's Song of Suffering", -- 125
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
            "Dhakka's Spry Sonata", -- 125, really bad song, nobody should ever use this
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
            "Regar's Lively Crescendo", -- 125
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
            "Arcane Rhythm", -- 125
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
            "Eoreg's Insult", -- 125
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
            "Aura of Tenisbre", -- 125
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
            "Aura of Shalowain",
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
            "Pulse of August", -- 125
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
            "Chorus of Shalowain", -- 125
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
            "War March of Nokk", -- 125
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
            "Flariton's Aria", -- 125
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
            "Zinnia's Melodic Binding", -- 125
            "Radiwol's Melodic Binding",
            "Dekloaz's Melodic Binding",
            "Protan's Melodic Binding",
            "Largo's Melodic Binding",
        },
        ['AccelerandoSong'] = {
            -- AccelerandoSong - Level Range 88 - 113 **
            "Appeasing Accelerando", -- 125
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
            "Tatalros' Spiteful Lyric", -- 125
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
            "Grayleaf's Reckless Renewal", -- 125
            "Kai's Reckless Renewal",
            "Reivaj's Reckless Renewal",
            "Rigelon's Reckless Renewal",
            "Rytan's Reckless Renewal",
            "Ruaabri's Reckless Renewal",
            "Ryken's Reckless Renewal",
        },
        ['FateSong'] = {
            -- Fatesong - Level Range 77 - 112 **
            "Fatesong of Zoraxmen", -- 125
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

        ['PotencySong'] = {
            -- Fire & Magic Dots song
            "Tatalros' Psalm of Potency", -- 125
            "Fyrthek Fior's Psalm of Potency",
            "Velketor's Psalm of Potency",
            "Akett's Psalm of Potency",
            "Horthin's Psalm of Potency",
            "Siavonn's Psalm of Potency",
            "Wasinai's Psalm of Potency",
            "Lyrin's Psalm of Potency",
            "Druzzil's Psalm of Potency",
            "Erradien's Psalm of Potency",
        },
        ['FireDotSong'] = {
            "Kindleheart's Chant of Flame", -- 125
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

            -- Misc Dot -- Or Minsc Dot (HEY HEY BOO BOO!)
            "Ancient: Chaos Chant",
            "Angstlich's Assonance",
            "Fufil's Diminishing Dirge",
            "Fufil's Curtailing Chant",
        },
        ['IceDotSong'] = {

            -- Ice Dot
            "Swarn's Chant of Frost",
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



            -- Misc Dot -- Or Minsc Dot (HEY HEY BOO BOO!)
            "Ancient: Chaos Chant",
            "Angstlich's Assonance",
            "Fufil's Diminishing Dirge",
            "Fufil's Curtailing Chant",
        },
        ['PoisonDotSong'] = {
            -- DotSongs - Level Range 30 - 115


            "Marsin's Chant of Poison",
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



            -- Misc Dot -- Or Minsc Dot (HEY HEY BOO BOO!)
            "Ancient: Chaos Chant",
            "Angstlich's Assonance",
            "Fufil's Diminishing Dirge",
            "Fufil's Curtailing Chant",
        },
        ['DiseaseDotSong'] = {
            -- DotSongs - Level Range 30 - 115

            "Goremand's Chant of Disease", -- 125
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
            "Voice of Suja", -- 125
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
            "Slumber of Suja", -- 125
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
            "Wave of Stupor", -- 125
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
    ['RotationOrder'] = {
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
            name = 'Debuff',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.BurnCheck() and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },

    },
    ['Rotations']     = {
        ['Burn'] = {
        },
        ['Debuff'] = {
            {
                name = "AESlowSong",
                type = "Song",
                cond = function(self, songSpell)
                    return gs("DoAESlow")
                        and RGMercUtils.DetSpellCheck(songSpell)
                        and RGMercUtils.GetXTHaterCount() > 2
                        and not mq.TLO.Target.Slowed()
                end,
            },
            {
                name = "SlowSong",
                type = "Song",
                cond = function(self, songSpell)
                    return gs("DoSlow")
                        and RGMercUtils.DetSpellCheck(songSpell)
                        and not mq.TLO.Target.Slowed()
                end,
            },
            {
                name = "DispelSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.GetSetting('DoDispel') and mq.TLO.Target.Beneficial()
                end,
            },
        },
        ['Heal'] = {
        },

        ['Testing'] = {
            {
                name = "FireDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseFireDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 4
                end,
            },
            {
                name = "IceDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseIceDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 4
                end,
            },
        
        },
        ['DPSOrig'] = {
            doFullRotation = true,
            {
                name = "MainAriaSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell)
                end,
            },
            {
                name = "WarMarchSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell)
                end,
            },
            {
                name = "Progressive",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell)
                        and gs("UseProgressive")
                end,
            },
            {
                name = "RecklessSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseReckless")
                end,
            },
            {
                name = "PulseRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UsePulse")
                end,
            },
            {
                name = "ChorusRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseChorus")
                end,
            },
            {
                name = "CrescendoSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseCrescendo') and
                        -- If dot is about to wear off, recast
                        RGMercUtils.BuffSong(songSpell) and
                        (mq.TLO.Group.LowMana(95)() or -1) > 0 and
                        -- Don't use up *ALL* mana or we lose fade
                        mq.TLO.Me.PctMana() > 20
                end,
            },
            {
                name = "DichoSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseProgressive') and
                        RGMercUtils.BuffSong(songSpell)
                end,
            },
            {
                name = "FireDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseFireDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 3500
                end,
            },
            {
                name = "IceDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseIceDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 3500
                end,
            },
            {
                name = "PoisonDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UsePoisonDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 3500
                end,
            },
            {
                name = "DiseaseDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseDiseaseDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 3500
                end,
            },
        },
        ['DPS'] = {
            -- This makes the full rotation execute each round, 
            --so it'll never pick up and resume wherever it left off the previous cast
            doFullRotation = true,
            -- Don't put mez in debuff or it won't cast except at beginning of fight
            {
                name = "MezAESong",
                type = "Song",
                cond = function(self, songSpell)
                    local setting = RGMercUtils.GetSetting('DoAEMez')
                    local memmed = RGMercUtils.SongMemed(songSpell)
                    local spellReady = mq.TLO.Me.SpellReady(songSpell)()
                    local aeMezCt = RGMercUtils.GetSetting("AEMezCount")

                    local res = setting and memmed and spellReady
                        and RGMercUtils.GetXTHaterCount() >= aeMezCt
                    print("AE MEz song name: ", songSpell.Name())
                    if res == false then
                        BL.warn("FAILED TO AE MEZ BECAUSE ONE OF THESE WAS FALSE:")
                        BL.warn("Setting: ", setting)
                        BL.warn("Memmed: ", memmed)
                        BL.warn("Spell Ready?: ", spellReady)
                        BL.warn("Mez count setting: %s is higher than xtar count %s", tostring(aeMezCt),
                            tostring(RGMercUtils.GetXTHaterCount()))
                    else
                        print("AOE MEZZING!")
                    end

                    return res
                end,
            },
            {
                name = "MainAriaSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell)
                end,
            },
            {
                name = "WarMarchSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell)
                end,
            },
            {
                name = "AllianceSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell)
                        and gs("UseAlliance")
                        and RGMercUtils.DetSpellCheck(songSpell)
                end,
            },
            {
                name = "CrescendoSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseCrescendo') and
                        -- If dot is about to wear off, recast
                        RGMercUtils.BuffSong(songSpell) and
                        (mq.TLO.Group.LowMana(95)() or -1) > 0 and
                        -- Don't use up *ALL* mana or we lose fade
                        mq.TLO.Me.PctMana() > 20
                end,
            },
            {
                name = "DichoSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseProgressive') and
                        RGMercUtils.BuffSong(songSpell)
                end,
            },
            -- Self Deeps
            {
                name = "InsultSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseFireDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 4
                end,
            },
            {
                name = "FireDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseFireDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 4
                end,
            },
            {
                name = "IceDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseIceDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 4
                end,
            },
            {
                name = "PoisonDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UsePoisonDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 4
                end,
            },
            {
                name = "DiseaseDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseDiseaseDots') and
                        -- If dot is about to wear off, recast
                        getDetSongDuration(songSpell) <= 4
                end,
            },
            -- Regens
            {
                name = "AmpSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseAmp")
                end,
            },
            {
                name = "PulseRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UsePulse")
                end,
            },
            {
                name = "ChorusRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseChorus")
                end,
            },
            {
                name = "CantataSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseCantata")
                end,
            },
            -- Melee DPS
            {
                name = "SufferingSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseSuffering")
                end,
            },
            {
                name = "ArcaneSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseArcane")
                end,
            },
            {
                name = "CasterAriaSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseFireDDMod")
                end,
            },
            {
                name = "FateSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseFate")
                end,
            },
            {
                name = "PotencySong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UsePotency")
                end,
            },
            --heals
            {
                name = "RecklessSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseReckless")
                end,
            },
            -- tank
            {
                name = "SpitefulSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseSpiteful")
                end,
            },
            {
                name = "SprySonataSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseSpry")
                end,
            },
            {
                name = "ResistSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell) and RGMercUtils.GetSetting("UseResist")
                end,
            },
        },

        ['Downtime'] = {
            doFullRotation = true,
            --{
            --    name = "BardDPSAura",
            --    type = "Song",
            --    cond = function(self, songSpell)
            --        return RGMercUtils.SongMemed(songSpell) and not RGMercUtils.AuraActiveByName(songSpell.RankName()) and
            --            not RGMercUtils.GetSetting('UseRegenAura')
            --    end,
            --},
            --{
            --    name = "BardRegenAura",
            --    type = "Song",
            --    cond = function(self, songSpell)
            --        return RGMercUtils.SongMemed(songSpell) and not RGMercUtils.AuraActiveByName(songSpell.RankName()) and
            --            RGMercUtils.GetSetting('UseRegenAura')
            --    end,
            --},
            {
                name = "ChorusRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell)
                        and RGMercUtils.GetSetting('DoMed')
                        and not mq.TLO.Me.Invis()
                end,
            },
            {
                name = "AccelerandoSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.BuffSong(songSpell)
                        and not mq.TLO.Me.Invis()
                end,
            },
            {
                name = "BardRunBuff",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.BuffSong(songSpell) and
                        not RGMercUtils.GetSetting('UseAASelo') and
                        RGMercUtils.GetSetting('DoRunSpeed')
                        and not mq.TLO.Me.Invis()
                end,
            },
            {
                name = "CrescendoSong",
                type = "Song",
                cond = function(self, songSpell)
                    local gemTimer = mq.TLO.Me.GemTimer(songSpell.Name())() or 0
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.BuffSong(songSpell) and gemTimer == 0 and
                        mq.TLO.Me.PctMana() < 75
                        and not mq.TLO.Me.Invis()
                end,
            },
            {
                name = "PulseRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.BuffSong(songSpell)
                        and not mq.TLO.Me.Invis()
                end,
            },
            {
                name = "ResistSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.BuffSong(songSpell)
                        and not mq.TLO.Me.Invis()
                end,
            },
            {
                name = "WarMarchSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.BuffSong(songSpell)
                        and not mq.TLO.Me.Invis()
                end,
            },
            {
                name = "MainAriaSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.BuffSong(songSpell)
                        and not mq.TLO.Me.Invis()
                end,
            },
            -- Loop on Chorus/regen if selected
            {
                name = "ChorusRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.GetSetting("UseChorus") and RGMercUtils.SongMemed(songSpell)
                        and not mq.TLO.Me.Invis()
                end,
            },
            -- FINAL STEP: If not loop on regen, loop on Aria as most widely applicable buff to maintain
            {
                name = "MainAriaSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell)
                end,
            },

        },
    },

    ['DefaultConfig'] = {
        ['Mode']           = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 4 },
        ['UseAASelo']      = { DisplayName = "Use AA Selo", Category = "Buffs", Tooltip = "Do Selo's AAs", Default = true },
        ['DoRunSpeed']     = { DisplayName = "Cast Run Speed Buffs", Category = "Buffs", Tooltip = "Use Selos.", Default = true },
        ['UseRegenAura']   = { DisplayName = "Use Regen Aura", Category = "Buffs", Tooltip = "UseRegenAura", Default = false },
        ['UseAlliance']    = { DisplayName = "Use Alliance", Category = "Combat", Tooltip = Tooltips.AllianceSong, Default = false },
        -- Debuffs
        ['DoSlow']         = { DisplayName = "Cast Slow", Category = "Combat", Tooltip = Tooltips.SlowSong, Default = false, },
        ['DoAESlow']       = { DisplayName = "Cast AE Slow", Category = "Combat", Tooltip = Tooltips.AESlowSong, Default = false },
        ['DoDispel']       = { DisplayName = "Use Dispel", Category = "Combat", Tooltip = Tooltips.DispelSong, Default = false },
        
        -- TODO
        --['DoCharm']       = { DisplayName = "Use Charm", Category = "Songs", Tooltip = Tooltips.CharmSong, Default = false },
        --['STMez']         = { DisplayName = "Do AoE Mez", Category = "Combat", Tooltip = "AEMez", Default = false },
        ['DoAEMez']          = { DisplayName = "Do AoE Mez", Category = "Combat", Tooltip = "AEMez", Default = false },
        ['AEMezCount']     = { DisplayName = "AoE Mez Count", Category = "Combat", Tooltip = "Mob count before AE mez casts", Default = 3, Min = 1, Max = 12 },
        --healer
        ['UseResist']      = { DisplayName = "Use Resists", Category = "Songs/Heals", Tooltip = Tooltips.ResistSong, Default = false },
        ['UseReckless']    = { DisplayName = "Use Reckless", Category = "Songs/Heals", Tooltip = Tooltips.RecklessSong, Default = false },
        ['UseCure']        = { DisplayName = "Use Cure", Category = "Songs/Heals", Tooltip = Tooltips.CureSong, Default = false },
        ['UsePulse']       = { DisplayName = "Use Pulse", Category = "Songs/Heals", Tooltip = Tooltips.PulseRegenSong, Default = true },
        --Regen
        ['UseAmp']         = { DisplayName = "Use Amp", Category = "Songs/Regen", Tooltip = Tooltips.AmpSong, Default = false },
        ['UseChorus']      = { DisplayName = "Use Chorus", Category = "Songs/Regen", Tooltip = Tooltips.ChorusRegenSong, Default = true },
        ['UseCantata']     = { DisplayName = "Use Cantata", Category = "Songs/Regen", Tooltip = Tooltips.CantataRegenSong, Default = false },
        ['UseCrescendo']   = { DisplayName = "Use Crescendo", Category = "Songs/Regen", Tooltip = Tooltips.CrescendoSong, Default = true },
        ['UseAccelerando'] = { DisplayName = "Use Accelerando", Category = "Songs/Regen", Tooltip = Tooltips.AccelerandoSong, Default = false },
        --DPS
        ['UseInsult']      = { DisplayName = "Use Insult Nuke", Category = "Songs/DPS", Tooltip = Tooltips.InsultSong, Default = true },
        ['UseFireDots']    = { DisplayName = "Use Fire Dots", Category = "Songs/DPS", Tooltip = Tooltips.FireDotSong, Default = true },
        ['UseIceDots']     = { DisplayName = "Use Ice Dots", Category = "Songs/DPS", Tooltip = Tooltips.IceDotSong, Default = true },
        ['UsePoisonDots']  = { DisplayName = "Use Poison Dots", Category = "Songs/DPS", Tooltip = Tooltips.PoisonDotSong, Default = true },
        ['UseDiseaseDots'] = { DisplayName = "Use Disease Dots", Category = "Songs/DPS", Tooltip = Tooltips.DiseaseDotSong, Default = true },

        --Tank
        ['UseSpiteful']    = { DisplayName = "Use Spiteful", Category = "Songs/Tank", Tooltip = Tooltips.SpitefulSong, Default = false },
        ['UseSpry']        = { DisplayName = "Use Spry", Category = "Songs/Tank", Tooltip = Tooltips.SprySonataSong, Default = false },
        --Caster
        ['UseArcane']      = { DisplayName = "Use Arcane", Category = "Songs/Caster", Tooltip = Tooltips.ArcaneSong, Default = false },
        ['UseFireDDMod']   = { DisplayName = "Use Fire Aria", Category = "Songs/Caster", Tooltip = Tooltips.CasterAriaSong, Default = false },
        ['UsePotency']     = { DisplayName = "Use Potency", Category = "Songs/Caster", Tooltip = Tooltips.PotencySong, Default = false },
        ['UseFate']        = { DisplayName = "Use Fate", Category = "Songs/Caster", Tooltip = Tooltips.FateSong, Default = false },
        -- Melee DPS Only
        ['UseSuffering']   = { DisplayName = "Use Suffering", Category = "Songs/Melee", Tooltip = Tooltips.SufferingSong, Default = false },
        ['UseProgressive'] = { DisplayName = "Use Progressive", Category = "Songs/Melee", Tooltip = Tooltips.DichoSong, Default = true },
        ['UseJonthan']     = { DisplayName = "Use Jonthan", Category = "Songs/Melee", Tooltip = Tooltips.Jonthans, Default = false },

    
    },
    ['Spells']        = { getSpellCallback = generateSongList }

}
return _ClassConfig
