--- @type Mq
local mq            = require('mq')
local RGMercUtils   = require("utils.rgmercs_utils")
local RGMercsLogger = require("utils.rgmercs_logger")

local Tooltips      = {
    Epic            = 'Item: Casts Epic Weapon Ability',
    BardRunBuff     = "Song Line: Movement Speed Modifier",
    MainAriaSong    = "Song Line: Spell Damage Focus / Haste v3 Modifier",
    WarMarchSong    = "Song Line: Melee Haste / DS / STR/ATK Increase",
    SufferingSong   = "Song Line: Melee Proc With Damage and Agro Reduction",
    SpitefulSong    = "Song Line: Increase AC / Agro Increase Proc",
    SprySonataSong  = "Song Line: Magic Asorb / AC Increase / Mitigate Damage Shield / Resist Spells",
    DotBuffSong     = "Song Line: Fire and Magic DoT Modifier",
    CrescendoSong   = "Song Line: Group v2 Increase Hit Points and Mana",
    ArcaneSong      = "Song Line: Group Melee and Spell Proc",
    InsultSong      = "Song Line: Single Target DD (Group Spell Proc Effect at higher levels)",
    DichoSong       = "Song Line: HP/Mana/End Increase / Melee and Caster Damage Increase",
    BardDPSAura     = "Aura Line: OverHaste / Melee and Caster DPS",
    BardRegenAura   = "Aura Line: HP/Mana Regen",
    AreaRegenSong   = "Song Line: AE HP/Mana Regen",
    GroupRegenSong  = "Song Line: Group HP/Mana Regen",
    FireBuffSong    = "Song Line: Fire DD Spell Damage Increase and Effiency",
    SlowSong        = "Song Line: ST Melee Attack Slow",
    AESlowSong      = "Song Line: PBAE Melee Attack Slow",
    AccelerandoSong = "Song Line: Reduce Beneficial Spell Casttime / Agro Reduction Modifier",
    RecklessSong    = "Song Line: Increase Crit Heal and Crit HoT Chance",
    ColdBuffSong    = "Song Line: Cold DD Damage Increase and Effiency",
    FireDotSong     = "Song Line: Fire DoT and minor resist debuff",
    DiseaseDotSong  = "Song Line: Disease DoT and minor resist debuff",
    PoisonDotSong   = "Song Line: Poison DoT and minor resist debuff",
    IceDotSong      = "Song Line: Ice DoT and minor resist debuff",
    EndBreathSong   = "Song Line: Enduring Breath",
    CureSong        = "Song Line: Single Target Cure: Poison/Disease/Corruption",
    AllianceSong    = "Song Line: Mob Debuff Increase Insult Damage for other Bards",
    CharmSong       = "Song Line: Charm Mob",
    ReflexStrike    = "Disc Line: Attack 4 times to restore Mana to Group",
    ChordsAE        = "Song Line: PBAE Damage if Target isn't moving",
    LowAriaSong     = "Song Line: Warsong and BattleCry prior to combination of effects into Aria",
    AmpSong         = "Song Line: Increase Singing Skill",
    DispelSong      = "Song Line: Dispel a Benefical Effect",
    ResistSong      = "Song Line: Damage Shield / Group Resist Increase",
    MezSong         = "Song Line: Single Target Mez",
    MezAESong       = "Song Line: PBAE Mez",
    Bellow          = "AA: DD + Resist Debuff that leads to a much larger DD upon expiry",
    Spire           = "AA: Lowers Incoming Melee Damage / Increases Melee and Spell Damage",
    FuneralDirge    = "AA: DD / Increases Melee Damage Taken on Target",
    FierceEye       = "AA: Increases Base and Crit Melee Damage / Increase Proc Rate / Increase Spell Crit Chance",
    QuickTime       = "AA: Hundred Hands Effect / Increase Melee Hit / Increase Atk",
    BladedSong      = "AA: Reverse Damage Shield",
    Jonthan         = "Song Line: (Self-only) Haste / Melee Damage Modifier / Melee Min Damage Modifier / Proc Modifier",
}

local function generateSongList()
    if mq.TLO.Plugin('MQ2Medley').IsLoaded() then
        mq.cmd("/plugin medley unload")
    end
    RGMercsLogger.log_info(
        "Bard Gem List being calculated. *** PLEASE NOTE: Click-happy behavior when selecting songs in the configuration may lead to low uptime or songs not being gemmed at all! YOU HAVE BEEN WARNED. ***")
    local songCache = { CollapseGems = true, }
    local songCount = 0
    local myLevel = mq.TLO.Me.Level()
    --------------------------------------------------------------------------------------
    local function addSong(songToAdd)
        if songCount >= mq.TLO.Me.NumGems() then return end
        songCount = songCount + 1
        table.insert(songCache, {
            gem = songCount,
            spells = {
                { name = songToAdd, cond = function(self) return true end, },
            },
        })
    end

    local function ConditionallyAddSong(settingToCheck, songToAdd, minLevel, configType)
        if myLevel < minLevel then return false end
        if configType == "combo" then
            if RGMercUtils.GetSetting(settingToCheck) > 1 then addSong(songToAdd) end
        else --if a third category is ever needed this can become "toggle" or somesuch
            if RGMercUtils.GetSetting(settingToCheck) then addSong(songToAdd) end
        end
    end

    local function AddCriticalSongs()
        ConditionallyAddSong("UseAEAAMez", "MezAESong", 85)
        ConditionallyAddSong("UseSingleTgtMez", "MezSong", 15)
        ConditionallyAddSong("DoSTSlow", "SlowSong", 23)
        ConditionallyAddSong("DoAESlow", "AESlowSong", 20)
        if RGMercUtils.GetSetting('UseRunBuff') == 2 and myLevel >= 49 then
            addSong("LongRunBuff")
        elseif RGMercUtils.GetSetting('UseRunBuff') == 3 then
            addSong("ShortRunBuff")
        end
        ConditionallyAddSong("UseEndBreath", "EndBreathSong", 16)
        -- TODO maybe someday
        ConditionallyAddSong("CharmOn", "CharmSong", 16)
        ConditionallyAddSong("DoDispel", "DispelSong", 40)
    end

    local function AddMainGroupDPSSongs()
        if myLevel >= 10 then addSong('WarMarchSong') end --leaving this mandatory but may revisit pending feedback
        if myLevel >= 45 then addSong('MainAriaSong') end
        ConditionallyAddSong("UseArcane", "ArcaneSong", 70, "combo")
        ConditionallyAddSong('UseDicho', 'DichoSong', 101, "combo")
    end

    local function AddSelfDPSSongs()
        ConditionallyAddSong("UseAlliance", "AllianceSong", 102)
        if RGMercUtils.GetSetting('UseInsult') > 1 and myLevel >= 85 then addSong("InsultSong") end
        ConditionallyAddSong("UseFireDots", "FireDotSong", 30)
        ConditionallyAddSong("UseIceDots", "IceDotSong", 30)
        ConditionallyAddSong("UseDiseaseDots", "DiseaseDotSong", 30)
        ConditionallyAddSong("UsePoisonDots", "PoisonDotSong", 30)
        ConditionallyAddSong("UseJonthan", "Jonthan", 7, "combo")
        if RGMercUtils.GetSetting('UseInsult') == 3 and myLevel >= 90 then addSong("InsultSong2") end
    end

    local function AddMeleeDPSSongs()
        ConditionallyAddSong("UseSuffering", "SufferingSong", 89, "combo")
    end

    local function AddTankSongs()
        ConditionallyAddSong("UseSpiteful", "SpitefulSong", 90, "combo")
        ConditionallyAddSong("UseSpry", "SprySonataSong", 77, "combo")
        ConditionallyAddSong("UseResist", "ResistSong", 33, "combo")
    end

    local function AddHealerSongs()
        ConditionallyAddSong("UseReckless", "RecklessSong", 93, "combo")
    end

    local function AddCasterDPSSongs()
        ConditionallyAddSong("UseFireBuff", "FireBuffSong", 78, "combo")
        ConditionallyAddSong("UseColdBuff", "ColdBuffSong", 72, "combo")
        ConditionallyAddSong("UseDotBuff", "DotBuffSong", 78, "combo")
    end

    local function AddRegenSongs()
        if RGMercUtils.GetSetting('RegenSong') == 2
        then
            addSong("GroupRegenSong")
        elseif RGMercUtils.GetSetting('RegenSong') == 3 and myLevel >= 58
        then
            addSong("AreaRegenSong")
        end
        ConditionallyAddSong("UseCrescendo", "CrescendoSong", 75)
        ConditionallyAddSong("UseAmp", "AmpSong", 30, "combo")
    end
    -----------------------------------------------------------------------------------------

    AddCriticalSongs()
    if RGMercUtils.IsModeActive("General") then
        AddMainGroupDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddMeleeDPSSongs()
        AddCasterDPSSongs()
        AddHealerSongs()
        AddTankSongs()
    elseif RGMercUtils.IsModeActive("Tank") then -- Tank
        AddTankSongs()
        AddMainGroupDPSSongs()
        AddHealerSongs()
        AddMeleeDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddCasterDPSSongs()
    elseif RGMercUtils.IsModeActive("Caster") then
        AddMainGroupDPSSongs()
        AddCasterDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddMeleeDPSSongs()
        AddHealerSongs()
        AddTankSongs()
    elseif RGMercUtils.IsModeActive("Healer") then -- Healer
        AddHealerSongs()
        AddMainGroupDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddCasterDPSSongs()
        AddTankSongs()
        AddMeleeDPSSongs()
    else
        RGMercsLogger.log_warn("Bard Mode not found!  Adding DPS songs, but you should select a mode.")
        AddMainGroupDPSSongs()
        AddSelfDPSSongs()
        AddRegenSongs()
        AddMeleeDPSSongs()
        AddCasterDPSSongs()
    end
    return songCache
end

local _ClassConfig = {
    _version            = "2.1",
    _author             = "Algar, Derple, Grimmier, Tiddliestix, SonicZentropy",
    ['Modes']           = { --simply determine the priority you gem spells in. Perhaps one day this could be configured to save different loadouts/change options.
        'General',
        'Tank',
        'Caster',
        'Healer',
    },

    ['ModeChecks']      = {
        CanMez     = function() return true end,
        CanCharm   = function() return true end,
        IsMezzing  = function() return RGMercUtils.GetSetting('UseSingleTgtMez') or RGMercUtils.GetSetting('UseAEAAMez') end,
        IsCuring   = function() return RGMercUtils.GetSetting('UseCure') end,
        IsCharming = function() return RGMercUtils.GetSetting('CharmOn') and mq.TLO.Pet.ID() == 0 end,
    },
    ['Cures']           = {
        CureNow = function(self, type, targetId)
            local cureSong = RGMercUtils.GetResolvedActionMapItem('CureSong')
            if not cureSong or not cureSong() then return false end
            return RGMercUtils.UseSong(cureSong.RankName.Name(), targetId, true)
        end,
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Blade of Vesagran",
            "Prismatic Dragon Blade",
        },
        ['Dreadstone'] = {
            "Possessed Dreadstone Minstrel's Rapier",
        },
        ['SymphonyOfBattle'] = {
            "Rapier of Somber Notes",
            "Songblade of the Eternal",
        },
    },
    ['AbilitySets']     = {
        ['ShortRunBuff'] = {
            --runbuffs are split to cover the level spread where we have accelerato but not selo's AA, if not, we force the bard into short duration only.
            "Selo's Accelerato",
            "Selo's Accelerando",
        },
        ['LongRunBuff'] = {
            --Removed due to causing Bugs with Invis and rotation.
            -- "Selo's Accelerating Canto",
            -- "Selo's Song of Travel",
            "Selo's Accelerating Chorus",
        },
        ['EndBreathSong'] = {
            "Tarew's Aquatic Ayre", --Level 16
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
            -- SprySonataSong - Level Range 77 - 118
            "Dhakka's Spry Sonata",
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
            --Bard Timers alternate between 6 and 3 every expansion.
            --If we have push and nopush from the same tier active this will lead to issues with InsultSong2/timer stacking.
            --Choosing which to prioritize is problematic, but for now, nopush will be prioritized to potentially help reduce movement in combat.
            --Do to current F2P expansion limits, the ToL push will be chosen over the NoS nopush, I see no good solution for this.
            "Eoreg's Insult",   -- 122 push, timer 3, LS
            --"Nord's Disdain",       -- 118 nopush, timer 6, NoS
            "Sogran's Insult",  -- 117 push, timer 6, ToL
            "Yelinak's Insult", -- 115 nopush, timer 3
            --"Omorden's Insult",     -- 112 push, timer 3
            "Sathir's Insult",  -- 110 nopush, timer 6
            --"Travenro's Insult",    -- 107 push, timer 6
            "Tsaph's Insult",   -- 105 nopush, timer 3
            --"Fjilnauk's Insult",    -- 102 push, timer 3
            --"Kaficus' Insult",      -- 100 push, timer 6 --Note push/nopush levels reversed this expansion compared to later
            "Garath's Insult",  -- 97 nopush, timer 6
            "Hykast's Insult",  -- 95 nopush, timer 3
            "Lyrin's Insult",   -- 90 nopush, timer 6
            "Venimor's Insult", -- 85, nopush, timer 3
            -- Below Level 85 This line turns into "bellow" instead of "Insult" and I don't know of anyone who uses them, but keeping for posterity
            -- "Bellow of Chaos", --66, interrupt
            -- "Brusco's Bombastic Bellow", --55, stun
            -- "Brusco's Boastful Bellow", --12,
        },
        ['InsultSong2'] = {
            "Eoreg's Insult",   -- 122 push, timer 3, LS
            --"Nord's Disdain",       -- 118 nopush, timer 6, NoS
            "Sogran's Insult",  -- 117 push, timer 6, ToL
            "Yelinak's Insult", -- 115 nopush, timer 3
            --"Omorden's Insult",     -- 112 push, timer 3
            "Sathir's Insult",  -- 110 nopush, timer 6
            --"Travenro's Insult",    -- 107 push, timer 6
            "Tsaph's Insult",   -- 105 nopush, timer 3
            --"Fjilnauk's Insult",    -- 102 push, timer 3
            --"Kaficus' Insult",      -- 100 push, timer 6 --Note push/nopush levels reversed this expansion compared to later
            "Garath's Insult",  -- 97 nopush, timer 6
            "Hykast's Insult",  -- 95 nopush, timer 3
            "Lyrin's Insult",   -- 90 nopush, timer 6
            "Venimor's Insult", -- 85, nopush, timer 3
        },
        ['DichoSong'] = {
            -- DichoSong Level Range - 101 - 116
            "Ecliptic Psalm",
            "Composite Psalm",
            "Dissident Psalm",
            "Dichotomic Psalm",
        },
        ['BardDPSAura'] = {
            -- BardDPSAura - Level Ranges 55 - 125
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
        ['GroupRegenSong'] = {
            --Note level 77 pulse only offers a heal% buff and is not included here.
            "Pulse of August", -- 125
            "Pulse of Nikolas",
            "Pulse of Vhal`Sera",
            "Pulse of Xigam",
            "Pulse of Sionachie",
            "Pulse of Salarra",
            "Pulse of Lunanyn",
            "Pulse of Renewal",             -- 86 start hp/mana/endurance
            "Cantata of Rodcet",            -- 81
            "Cantata of Restoration",       -- 76
            "Erollisi's Cantata",           -- 71
            "Cantata of Life",              -- 67
            "Wind of Marr",                 -- 62
            "Cantata of Replenishment",     -- 55
            "Cantata of Soothing",          -- 34 start hp/mana
            "Cassindra's Chant of Clarity", --20, mana only
            "Hymn of Restoration",          -- 7, hp only

        },
        ['AreaRegenSong'] = {
            -- ChorusRegenSong - Level Range 58 - 113
            "Chorus of Shalowain",     -- 123
            "Chorus of Shei Vinitras", -- 118
            "Chorus of Vhal`Sera",     -- 113
            "Chorus of Xigam",         -- 108
            "Chorus of Sionachie",     -- 103
            "Chorus of Salarra",       -- 98
            "Chorus of Lunanyn",       -- 93
            "Chorus of Renewal",       -- 88
            "Chorus of Rodcet",        -- 83
            "Chorus of Restoration",   -- 78
            "Erollisi's Chorus",       -- 73
            "Chorus of Life",          -- 69
            "Chorus of Marr",          -- 64
            "Ancient: Lcea's Lament",  -- 60
            "Chorus of Replenishment", -- 58
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
        ['FireBuffSong'] = {
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
        },
        ['SlowSong'] = {
            "Requiem of Time",
            "Angstlich's Assonance",    --snare/slow
            "Largo's Assonant Binding", --snare/slow
            "Selo's Consonant Chain",   --snare/slow
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
        ['ColdBuffSong'] = {
            -- ColdBuffSong - Level Range 72 - 112 **
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
            "Weshlu's Chillsong Aria",
        },

        ['DotBuffSong'] = {
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
            "Aria of Absolution",
            "Aria of Impeccability",
            "Aria of Amelioration",
            --"Aria of Innocence", --curse only
            "Aria of Asceticism", --poison/disease Only

        },
        ['AllianceSong'] = {
            "Conjunction of Sticks and Stones",
            "Alliance of Sticks and Stones",
            "Covenant of Sticks and Stones",
            "Coalition of Sticks and Stones",
        },
        ['CharmSong'] = {
            "Voice of Suja", -- 125
            "Voice of the Diabo",
            "Omiyad's Demand",
            "Voice of Zburator",
            "Desirae's Demand",
            "Voice of Jembel",
            "Dawnbreeze's Demand",
            "Voice of Silisia",
            "Silisia's Demand",
            "Voice of Motlak",
            "Voice of Kolain",
            "Voice of Sionachie",
            "Voice of the Mindshear",
            "Yowl of the Bloodmoon",
            "Beckon of the Tuffein",
            "Voice of the Vampire",
            "Call of the Banshee",        -- 65
            "Solon's Bewitching Bravura", -- 39
            "Solon's Song of the Sirens", -- 27
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
        ['Jonthan'] = {
            "Jonthan's Mightful Caretaker",
            "Jonthan's Inspiration",
            "Jonthan's Provocation",
            "Jonthan's Whistling Warsong",
        },
    },
    ['HelperFunctions'] = {
        SwapInst = function(type)
            if not RGMercUtils.GetSetting('SwapInstruments') then return end
            RGMercsLogger.log_verbose("\ayBard SwapInst(): Swapping to Instrument Type: %s", type)
            if type == "Percussion Instruments" then
                RGMercUtils.SwapItemToSlot("offhand", RGMercUtils.GetSetting('PercInst'))
                return
            elseif type == "Wind Instruments" then
                RGMercUtils.SwapItemToSlot("offhand", RGMercUtils.GetSetting('WindInst'))
                return
            elseif type == "Brass Instruments" then
                RGMercUtils.SwapItemToSlot("offhand", RGMercUtils.GetSetting('BrassInst'))
                return
            elseif type == "Stringed Instruments" then
                RGMercUtils.SwapItemToSlot("offhand", RGMercUtils.GetSetting('StringedInst'))
                return
            end
            RGMercUtils.SwapItemToSlot("offhand", RGMercUtils.GetSetting('Offhand'))
        end,
        CheckSongStateUse = function(self, config)     --determine whether a song should be song by comparing combat state to settings
            local usestate = RGMercUtils.GetSetting(config)
            if RGMercUtils.GetXTHaterCount() == 0 then --I have tried this with combat_state nand XTHater, and both have their ups and downs. Keep an eye on this.
                return usestate > 2                    --I think XTHater will work better if the bard autoassists at 99 or 100.
            else
                return usestate < 4
            end
        end,
        RefreshBuffSong = function(songSpell) --determine how close to a buff's expiration we will resing to maintain full uptime
            if not songSpell or not songSpell() then return false end
            local me = mq.TLO.Me
            local threshold = RGMercUtils.GetSetting('RefreshCombat')
            --an earlier version of this function checked your cast speed to add to this value, but cast speed TLO is always rounded down and is virtually always "2"
            if RGMercUtils.GetXTHaterCount() == 0 then threshold = RGMercUtils.GetSetting('RefreshDT') end

            local res = RGMercUtils.SongMemed(songSpell) and
                ((me.Buff(songSpell.Name()).Duration.TotalSeconds() or 999) <= threshold or
                    (me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) <= threshold)
            RGMercsLogger.log_verbose("\ayRefreshBuffSong(%s) => memed(%s), song: duration(%0.2f) < reusetime(%0.2f) buff: duration(%0.2f) < reusetime(%0.2f) --> result(%s)",
                songSpell.Name(),
                RGMercUtils.BoolToColorString(me.Gem(songSpell.RankName.Name())() ~= nil),
                me.Song(songSpell.Name()).Duration.TotalSeconds() or 0, threshold,
                me.Buff(songSpell.Name()).Duration.TotalSeconds() or 0,
                threshold,
                RGMercUtils.BoolToColorString(res))
            return res
        end,
        UnwantedAggroCheck = function(self) --Self-Explanatory. Add isTanking to this if you ever make a mode for bardtanks!
            if RGMercUtils.GetXTHaterCount() == 0 or RGMercUtils.IAmMA() or mq.TLO.Group.Puller.ID() == mq.TLO.Me.ID() then return false end
            return RGMercUtils.IHaveAggro(100)
        end,
        DotSongCheck = function(songSpell) --Check dot stacking, stop dotting when HP threshold is reached based on mob type, can't use utils function because we try to refresh just as the dot is ending
            if not songSpell or not songSpell() then return false end
            local named = RGMercUtils.IsNamed(mq.TLO.Target)
            local targethp = RGMercUtils.GetTargetPctHPs()

            return RGMercUtils.SpellStacksOnTarget(songSpell) and ((named and (RGMercUtils.GetSetting('NamedStopDOT') < targethp)) or
                (not named and RGMercUtils.GetSetting('HPStopDOT') < targethp))
        end,
        GetDetSongDuration = function(songSpell) -- Checks target for duration remaining on dot songs
            local duration = mq.TLO.Target.FindBuff("name " .. songSpell.Name()).Duration.TotalSeconds() or 0
            RGMercsLogger.log_debug("getDetSongDuration() Current duration for %s : %d", songSpell, duration)
            return duration
        end,
    },
    ['RotationOrder']   = {
        {
            name = 'Melody',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return not RGMercUtils.Feigning() and not (combat_state == "Downtime" and mq.TLO.Me.Invis())
            end,
        },
        {
            name = 'Downtime',
            state = 1,
            steps = 1,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and not (RGMercUtils.Feigning() or mq.TLO.Me.Invis())
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return RGMercUtils.GetXTHaterCount() > 0 and not RGMercUtils.Feigning() and
                    (mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('EmergencyStart') or self.ClassConfig.HelperFunctions.UnwantedAggroCheck(self))
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
            name = 'Combat',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
    },
    --TODO: Triple-check usage of PCAAReady and NPCAAReady, etc, depending on ability
    ['Rotations']       = {
        ['Burn'] = {
            {
                name = "Quick Time",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Funeral Dirge",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) -- and RGMercUtils.GetSetting('UseFuneralDirge') --see note in config settings
                end,
            },
            {
                name = "Spire of the Minstrels",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Bladed Song",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Thousand Blades",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Flurry of Notes",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Dance of Blades",
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
                    return item() and mq.TLO.Me.Song(item.Spell.RankName.Name())() ~= nil
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.GetSetting('DoChestClick') and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
            {
                name = "Cacophony",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Frenzied Kicks",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    if not RGMercUtils.GetSetting('DoVetAA') then return false end
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.BigBurn()
                end,
            },
        },
        ['Debuff'] = {
            {
                name = "MezAESong",
                type = "Song",
                cond = function(self, songSpell)
                    if not RGMercUtils.GetSetting('UseAEAAMez') and RGMercUtils.SongMemed(songSpell) then return false end
                    return RGMercUtils.GetXTHaterCount() >= RGMercUtils.GetSetting("MezAECount") and (mq.TLO.Me.GemTimer(songSpell.RankName.Name())() or -1) == 0
                end,
            },
            {
                name = "AESlowSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.GetSetting("DoAESlow") and RGMercUtils.DetSpellCheck(songSpell) and RGMercUtils.GetXTHaterCount() > 2 and not mq.TLO.Target.Slowed()
                end,
            },
            {
                name = "SlowSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.GetSetting("DoSTSlow") and RGMercUtils.DetSpellCheck(songSpell) and not mq.TLO.Target.Slowed()
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
        ['Combat'] = {
            -- Kludge that addresses bards not attempting to start attacking until after a song completes
            -- Uncomment if you'd like to occasionally start attacking earlier than normal
            --[[{
                name = "Force Attack",
                type = "AA",
                cond = function(self, itemName)
                    local mytar = mq.TLO.Target
                    if not mq.TLO.Me.Combat() and mytar() and mytar.Distance() < 50 then
                        RGMercUtils.DoCmd("/keypress AUTOPRIM")
                    end
                end,
            },]]
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if RGMercUtils.GetSetting('UseEpic') == 1 then return false end
                    return (RGMercUtils.GetSetting('UseEpic') == 3 or (RGMercUtils.GetSetting('UseEpic') == 2 and RGMercUtils.BurnCheck())) and mq.TLO.FindItem(itemName)() and
                        mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
            {
                name = "Fierce Eye",
                type = "AA",
                cond = function(self, aaName)
                    if RGMercUtils.GetSetting('UseFierceEye') == 1 then return false end
                    return (RGMercUtils.GetSetting('UseFierceEye') == 3 or (RGMercUtils.GetSetting('UseFierceEye') == 2 and RGMercUtils.BurnCheck())) and
                        RGMercUtils.PCAAReady(aaName)
                end,
            },
            {
                name = "Dreadstone",
                type = "Item",
                cond = function(self, itemName)
                    -- This item is instant cast for free with almost no CD, just mash it forever when it's available
                    if not RGMercUtils.GetSetting('UseDreadstone') then return false end
                    return mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
            {
                name = "ReflexStrike",
                type = "Disc",
                tooltip = Tooltips.ReflexStrike,
                cond = function(self, discSpell)
                    local pct = RGMercUtils.GetSetting('GroupManaPct')
                    return RGMercUtils.NPCDiscReady(discSpell) and (mq.TLO.Group.LowMana(pct)() or -1) >= RGMercUtils.GetSetting('GroupManaCt')
                end,
            },
            {
                name = "Boastful Bellow",
                type = "AA",
                cond = function(self, aaName, target)
                    if RGMercUtils.GetSetting('UseBellow') == 1 then return false end
                    return ((RGMercUtils.GetSetting('UseBellow') == 3 and mq.TLO.Me.PctEndurance() > RGMercUtils.GetSetting('SelfEndPct')) or (RGMercUtils.GetSetting('UseBellow') == 2 and RGMercUtils.BurnCheck())) and
                        RGMercUtils.DetSpellCheck(mq.TLO.AltAbility(aaName).Spell) and RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "DichoSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseDicho') == 1 then return false end
                    return (RGMercUtils.GetSetting('UseDicho') == 3 and (mq.TLO.Me.PctEndurance() > RGMercUtils.GetSetting('SelfEndPct') or RGMercUtils.BurnCheck()))
                        or (RGMercUtils.GetSetting('UseDicho') == 2 and RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility("Quick Time").Spell.ID()))
                end,
            },
            {
                name = "InsultSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not RGMercUtils.GetSetting('UseInsult') then return false end
                    return (mq.TLO.Me.GemTimer(songSpell.RankName.Name())() or -1) == 0 and (mq.TLO.Me.PctMana() > RGMercUtils.GetSetting('SelfManaPct') or RGMercUtils.BurnCheck())
                end,
            },
            {
                name = "FireDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not RGMercUtils.GetSetting('UseFireDots') and RGMercUtils.SongMemed(songSpell) then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "IceDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not RGMercUtils.GetSetting('UseIceDots') and RGMercUtils.SongMemed(songSpell) then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "PoisonDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not RGMercUtils.GetSetting('UsePoisonDots') and RGMercUtils.SongMemed(songSpell) then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "DiseaseDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not RGMercUtils.GetSetting('UseDiseaseDots') and RGMercUtils.SongMemed(songSpell) then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "InsultSong2",
                type = "Song",
                cond = function(self, songSpell)
                    if not RGMercUtils.GetSetting('UseInsult') then return false end
                    return (mq.TLO.Me.GemTimer(songSpell.RankName.Name())() or -1) == 0 and (mq.TLO.Me.PctMana() > RGMercUtils.GetSetting('SelfManaPct') or RGMercUtils.BurnCheck())
                end,
            },
            {
                name = "AllianceSong",
                type = "Song",
                cond = function(self, songSpell)
                    return RGMercUtils.SongMemed(songSpell) and RGMercUtils.GetSetting('UseAlliance') and
                        (mq.TLO.Me.PctMana() > RGMercUtils.GetSetting('SelfManaPct') or RGMercUtils.BurnCheck()) and RGMercUtils.DetSpellCheck(songSpell)
                end,
            },
            --used in combat when we have nothing else to refresh rather than standing there. Initial testing good, need more to ensure this doesn't interfere with Melody.
            {
                name = "MainAriaSong",
                type = "Song",
                cond = function(self, songSpell)
                    return (mq.TLO.Me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) <= 18
                end,
            },
            {
                name = "WarMarchSong",
                type = "Song",
                cond = function(self, songSpell)
                    return (mq.TLO.Me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) <= 18
                end,
            },
        },
        ['Melody'] = {
            {
                name = "EndBreathSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not (RGMercUtils.GetSetting('UseEndBreath') and (mq.TLO.Me.FeetWet() or mq.TLO.Zone.ShortName() == 'thegrey')) then return false end
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "MainAriaSong",
                type = "Song",
                cond = function(self, songSpell)
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "WarMarchSong",
                type = "Song",
                cond = function(self, songSpell)
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "Jonthan",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseJonthan') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseJonthan") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "ArcaneSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseArcane') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseArcane") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "CrescendoSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not RGMercUtils.GetSetting('UseCrescendo') then return false end
                    local pct = RGMercUtils.GetSetting('GroupManaPct')
                    return (mq.TLO.Me.GemTimer(songSpell.RankName.Name())() or -1) == 0 and (mq.TLO.Group.LowMana(pct)() or -1) >= RGMercUtils.GetSetting('GroupManaCt')
                end,
            },
            {
                name = "GroupRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('RegenSong') ~= 2 then return false end
                    local pct = RGMercUtils.GetSetting('GroupManaPct')
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell) and
                        ((RGMercUtils.GetSetting('UseRegen') == 1 and (mq.TLO.Group.LowMana(pct)() or 999) >= RGMercUtils.GetSetting('GroupManaCt'))
                            or (RGMercUtils.GetSetting('UseRegen') > 1 and self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseRegen")))
                end,
            },
            {
                name = "AreaRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('RegenSong') ~= 3 then return false end
                    local pct = RGMercUtils.GetSetting('GroupManaPct')
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell) and
                        not (mq.TLO.Me.Combat() and (mq.TLO.Group.LowMana(pct)() or 999) < RGMercUtils.GetSetting('GroupManaCt'))
                end,
            },
            {
                name = "AmpSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseAmp') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseAmp") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "SufferingSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseSuffering') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseSuffering") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "SpitefulSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseSpiteful') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseSpiteful") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "SprySonataSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseSpry') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseSpry") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "ResistSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseResist') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseResist") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "RecklessSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseReckless') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseReckless") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "AccelerandoSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseAccelerando') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseAccelerando") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "FireBuffSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseFireBuff') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseFireBuff") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "ColdBuffSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseColdBuff') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseColdBuff") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "DotBuffSong",
                type = "Song",
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseDotBuff') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseDotBuff") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "ShortRunBuff",
                type = "Song",
                targetId = function(self) return { mq.TLO.Me.ID(), } end,
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseRunBuff') ~= 3 then return false end
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "LongRunBuff",
                type = "Song",
                targetId = function(self) return { mq.TLO.Me.ID(), } end,
                cond = function(self, songSpell)
                    if RGMercUtils.GetSetting('UseRunBuff') ~= 2 then return false end
                    return (mq.TLO.Me.Buff(songSpell.Name()).Duration.TotalSeconds() or 0) <= 15
                end,
            },
            {
                name = "Selo's Sonata",
                type = "AA",
                targetId = function(self) return { mq.TLO.Me.ID(), } end,
                cond = function(self, aaName)
                    if RGMercUtils.GetSetting('UseRunBuff') ~= 1 then return false end
                    --refreshes slightly before expiry for better uptime
                    return RGMercUtils.AAReady(aaName) and (mq.TLO.Me.Buff(mq.TLO.AltAbility(aaName).Spell.Trigger(1)).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "Rallying Solo", --Rallying Call theoretically possible but problematic, needs own rotation akin to Focused Paragon, etc
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and (mq.TLO.Me.PctEndurance() < 30 or mq.TLO.Me.PctMana() < 30)
                end,
            },
            {
                name = "BardDPSAura",
                type = "Song",
                pre_activate = function(self, songSpell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not RGMercUtils.AuraActiveByName(songSpell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, songSpell)
                    return not RGMercUtils.AuraActiveByName(songSpell.BaseName()) and RGMercUtils.GetSetting('UseAura') == 1
                end,
            },
            {
                name = "BardRegenAura",
                type = "Song",
                pre_activate = function(self, songSpell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not RGMercUtils.AuraActiveByName(songSpell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, songSpell)
                    return not RGMercUtils.AuraActiveByName(songSpell.BaseName()) and RGMercUtils.GetSetting('UseAura') == 2
                end,
            },
            {
                name = "SymphonyOfBattle",
                type = "Item",
                targetId = function(self) return { mq.TLO.Me.ID(), } end,
                cond = function(self, itemName)
                    if not RGMercUtils.GetSetting('UseSoBItems') then return false end
                    return RGMercUtils.SelfBuffCheck("Symphony of Battle") and mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
            {
                name = "EndBreathSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not (RGMercUtils.GetSetting('UseEndBreath') and (mq.TLO.Me.FeetWet() or mq.TLO.Zone.ShortName() == 'thegrey')) then return false end
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self, aaName)
                    if not RGMercUtils.GetSetting('DoVetAA') then return false end
                    return mq.TLO.Me.PctHPs() < 35 and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Fading Memories",
                type = "AA",
                cond = function(self, aaName)
                    if not RGMercUtils.GetSetting('UseFading') then return false end
                    return RGMercUtils.PCAAReady(aaName) and self.ClassConfig.HelperFunctions.UnwantedAggroCheck(self)
                    --I wanted to use XTAggroCount here but it doesn't include your current target in the number it returns and I don't see a good workaround. For Loop it is.
                end,
            },
            {
                name = "Hymn of the Last Stand",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('EmergencyStart') and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Shield of Notes",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('EmergencyStart') and RGMercUtils.AAReady(aaName)
                end,
            },
        },
    },
    ['PullAbilities']   = {
        {
            id = 'Sonic Disturbance',
            Type = "AA",
            DisplayName = 'Sonic Disturbance',
            AbilityName = 'Sonic Disturbance',
            AbilityRange = 250,
            cond = function(self)
                return mq.TLO.Me.AltAbility('Sonic Disturbance')() ~= nil
            end,
        },
        {
            id = 'Boastful Bellow',
            Type = "AA",
            DisplayName = 'Boastful Bellow',
            AbilityName = 'Boastful Bellow',
            AbilityRange = 250,
            cond = function(self)
                return mq.TLO.Me.AltAbility('Boastful Bellow')() ~= nil
            end,
        },
    },
    ['DefaultConfig']   = {
        ['Mode']            = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 4, },
        --Mana/Endurance Sustainment
        ['SelfManaPct']     = { DisplayName = "Self Min Mana %", Category = "Mana/End Sustain", Index = 1, Tooltip = "Minimum Mana% to use Insult and Alliance outside of burns.", Default = 20, Min = 1, Max = 100, ConfigType = "Advanced", },
        ['SelfEndPct']      = { DisplayName = "Self Min End%", Category = "Mana/End Sustain", Index = 2, Tooltip = "Minimum End% to use Bellow or Dicho outside of burns.", Default = 20, Min = 1, Max = 100, ConfigType = "Advanced", },
        ['GroupManaPct']    = { DisplayName = "Group Mana %", Category = "Mana/End Sustain", Index = 3, Tooltip = "Mana% to begin managing group mana by using Crescendoes and Reflexive Strikes. If configured, also governs when Regen Song will be sung.", Default = 80, Min = 1, Max = 100, ConfigType = "Advanced", },
        ['GroupManaCt']     = { DisplayName = "Group Mana Count", Category = "Mana/End Sustain", Index = 4, Tooltip = "The number of party members (including yourself) that need to be under the above mana percentage.", Default = 2, Min = 1, Max = 6, ConfigType = "Advanced", },
        --Debuffs
        ['DoSTSlow']        = { DisplayName = "Use Slow (ST)", Category = "Debuffs", Index = 1, Tooltip = Tooltips.SlowSong, RequiresLoadoutChange = true, Default = false, },
        ['DoAESlow']        = { DisplayName = "Use Slow (AE)", Category = "Debuffs", Index = 2, Tooltip = Tooltips.AESlowSong, RequiresLoadoutChange = true, Default = false, },
        ['DoDispel']        = { DisplayName = "Use Dispel", Category = "Debuffs", Index = 3, Tooltip = Tooltips.DispelSong, RequiresLoadoutChange = true, Default = false, },
        --Regen/Healing
        ['RegenSong']       = { DisplayName = "Regen Song Choice:", Category = "Regen/Healing", Index = 1, Tooltip = "Select the Regen Song to be used, if any. Always used out of combat if selected. Use in-combat is determined by sustain settings.", RequiresLoadoutChange = true, Type = "Combo", ComboOptions = { 'None', 'Group', 'Area', }, Default = 2, Min = 1, Max = 3, },
        ['UseRegen']        = { DisplayName = "Regen Song Use:", Category = "Regen/Healing", Index = 2, Tooltip = "When to use the Regen Song selected above.", Type = "Combo", ComboOptions = { 'Under Group Mana % (Advanced Options Setting)', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 3, Min = 1, Max = 4, },
        ['UseCrescendo']    = { DisplayName = "Crescendo Delayed Heal", Category = "Regen/Healing", Index = 3, Tooltip = Tooltips.CrescendoSong, RequiresLoadoutChange = true, Default = true, },
        ['UseCure']         = { DisplayName = "Cure Ailments", Category = "Regen/Healing", Index = 4, Tooltip = Tooltips.CureSong, RequiresLoadoutChange = true, Default = false, },
        --DPS - Self
        ['UseBellow']       = { DisplayName = "Use Bellow:", Category = "DPS - Self", Index = 1, Tooltip = "Use Boastful Bellow", Type = "Combo", ComboOptions = { 'Never', 'Burns Only', 'All Combat', }, Default = 3, Min = 1, Max = 3, ConfigType = "Advanced", },
        ['UseInsult']       = { DisplayName = "Insults to Use:", Category = "DPS - Self", Index = 2, Tooltip = Tooltips.InsultSong, Type = "Combo", ComboOptions = { 'None', 'Current Tier', 'Current + Old Tier', }, Default = 3, Min = 1, Max = 3, RequiresLoadoutChange = true, },
        ['UseFireDots']     = { DisplayName = "Use Fire Dots", Category = "DPS - Self", Index = 3, Tooltip = Tooltips.FireDotSong, RequiresLoadoutChange = true, Default = false, },
        ['UseIceDots']      = { DisplayName = "Use Ice Dots", Category = "DPS - Self", Index = 4, Tooltip = Tooltips.IceDotSong, RequiresLoadoutChange = true, Default = false, },
        ['UsePoisonDots']   = { DisplayName = "Use Poison Dots", Category = "DPS - Self", Index = 5, Tooltip = Tooltips.PoisonDotSong, RequiresLoadoutChange = true, Default = false, },
        ['UseDiseaseDots']  = { DisplayName = "Use Disease Dots", Category = "DPS - Self", Index = 6, Tooltip = Tooltips.DiseaseDotSong, RequiresLoadoutChange = true, Default = false, },
        ['UseJonthan']      = { DisplayName = "Use Jonthan", Category = "DPS - Self", Index = 7, Tooltip = Tooltips.Jonthan, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, ConfigType = "Advanced", },
        --DPS - Group
        ['UseFierceEye']    = { DisplayName = "Fierce Eye Use:", Category = "DPS - Group", Index = 7, Tooltip = "When to use the Fierce Eye AA.", Type = "Combo", ComboOptions = { 'Never', 'Burns Only', 'All Combat', }, Default = 3, Min = 1, Max = 3, ConfigType = "Advanced", },
        ['UseArcane']       = { DisplayName = "Use Arcane Line", Category = "DPS - Group", Index = 1, Tooltip = Tooltips.ArcaneSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 3, Min = 1, Max = 4, RequiresLoadoutChange = true, },
        ['UseDicho']        = { DisplayName = "Psalm (Dicho) Use:", Category = "DPS - Group", Index = 3, Tooltip = Tooltips.DichoSong, Type = "Combo", ComboOptions = { 'Never', 'During QuickTime', 'All Combat', }, Default = 3, Min = 1, Max = 3, RequiresLoadoutChange = true, ConfigType = "Advanced", },
        ['UseSuffering']    = { DisplayName = "Use Suffering Line", Category = "DPS - Group", Index = 2, Tooltip = Tooltips.SufferingSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 4, Min = 1, Max = 4, RequiresLoadoutChange = true, },
        ['UseFireBuff']     = { DisplayName = "Use Fire Spell Buff", Category = "DPS - Group", Index = 4, Tooltip = Tooltips.FireBuffSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, ConfigType = "Advanced", },
        ['UseColdBuff']     = { DisplayName = "Use Cold Spell Buff", Category = "DPS - Group", Index = 5, Tooltip = Tooltips.ColdBuffSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, ConfigType = "Advanced", },
        ['UseDotBuff']      = { DisplayName = "Use Fire/Magic DoT Buff", Category = "DPS - Group", Index = 6, Tooltip = Tooltips.DotBuffSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, ConfigType = "Advanced", },
        ['UseAlliance']     = { DisplayName = "Use Alliance", Category = "DPS - Group", Index = 8, Tooltip = Tooltips.AllianceSong, RequiresLoadoutChange = true, Default = false, ConfigType = "Advanced", },
        --Why is this optional? I can't think of a situation that it should be false, keeping it here until I find out.Maybe a stacking thing?
        --['UseFuneralDirge']		= { DisplayName = "Funeral Dirge (Burn)", Category = "DPS - Group", Index = 2, Tooltip = "Use Funeral Dirge during Burns", Default = true, },
        --Buffs and Defenses
        ['UseAura']         = { DisplayName = "Use Bard Aura", Category = "Buffs and Defenses", Index = 1, Tooltip = "Select the Aura to be used, if any.", Type = "Combo", ComboOptions = { 'DPS Aura', 'Regen', 'None', }, RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 3, },
        ['UseAmp']          = { DisplayName = "Use Amp", Category = "Buffs and Defenses", Index = 2, Tooltip = Tooltips.AmpSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, },
        ['UseSpiteful']     = { DisplayName = "Use Spiteful", Category = "Buffs and Defenses", Index = 3, Tooltip = Tooltips.SpitefulSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, },
        ['UseSpry']         = { DisplayName = "Use Spry", Category = "Buffs and Defenses", Index = 4, Tooltip = Tooltips.SprySonataSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, },
        ['UseResist']       = { DisplayName = "Use DS/Resist Psalm", Category = "Buffs and Defenses", Index = 5, Tooltip = Tooltips.ResistSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, },
        ['UseReckless']     = { DisplayName = "Use Reckless", Category = "Buffs and Defenses", Index = 6, Tooltip = Tooltips.RecklessSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 4, Min = 1, Max = 4, RequiresLoadoutChange = true, },
        ['UseAccelerando']  = { DisplayName = "Use Accelerando", Category = "Buffs and Defenses", Index = 7, Tooltip = Tooltips.AccelerandoSong, Type = "Combo", ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, ConfigType = "Advanced", },
        --Utility/Items/Misc
        ['UseEpic']         = { DisplayName = "Epic Use:", Category = "Utility/Items/Misc", Index = 1, Tooltip = "Use Epic 1-Never 2-Burns 3-Always", Type = "Combo", ComboOptions = { 'Never', 'Burns Only', 'All Combat', }, Default = 3, Min = 1, Max = 3, ConfigType = "Advanced", },
        ['DoChestClick']    = { DisplayName = "Chest Click", Category = "Utility/Items/Misc", Index = 2, Tooltip = "Click your equipped chest item.", Default = true, ConfigType = "Advanced", },
        ['UseSoBItems']     = { DisplayName = "Symph. of Battle", Category = "Utility/Items/Misc", Index = 3, Tooltip = "Click your Symphony of Battle items.", Default = false, ConfigType = "Advanced", },
        ['UseDreadstone']   = { DisplayName = "Dreadstone", Category = "Utility/Items/Misc", Index = 4, Tooltip = "Use your Dreadstone when able.", Default = false, ConfigType = "Advanced", },
        ['UseRunBuff']      = { DisplayName = "Runspeed Buff:", Category = "Utility/Items/Misc", Index = 5, Tooltip = "Select Runspeed Buff to use. NOTE: This setting may need user adjustment during the early level range!", Type = "Combo", ComboOptions = { 'AA', 'Song (Long Duration Only)', 'Song (Fastest Available)', 'Off', }, Default = 1, Min = 1, Max = 4, RequiresLoadoutChange = true, ConfigType = "Advanced", },
        ['UseEndBreath']    = { DisplayName = "Use Enduring Breath", Category = "Utility/Items/Misc", Index = 6, Tooltip = Tooltips.EndBreathSong, Default = false, ConfigType = "Advanced", },
        ['DoVetAA']         = { DisplayName = "Use Vet AA", Category = "Utility/Items/Misc", Index = 7, Tooltip = "Use Veteran AA's in emergencies or during BigBurn", Default = true, ConfigType = "Advanced", },
        ['EmergencyStart']  = { DisplayName = "Emergency HP%", Category = "Utility/Items/Misc", Index = 8, Tooltip = "Your HP % before we begin to use emergency mitigation abilities.", Default = 50, Min = 1, Max = 100, ConfigType = "Advanced", },
        ['UseFading']       = { DisplayName = "Use Combat Escape", Category = "Utility/Items/Misc", Index = 9, Tooltip = "Use Fading Memories when you have aggro and you aren't the Main Assist.", Default = true, ConfigType = "Advanced", },
        ['RefreshDT']       = { DisplayName = "Downtime Threshold", Category = "Utility/Items/Misc", Index = 10, Tooltip = "The duration threshold for refreshing a buff song outside of combat. ***WARNING: Editing this value can drastically alter your ability to maintain buff songs!*** This needs to be carefully tailored towards your song line-up.", Default = 12, Min = 0, Max = 30, ConfigType = "Advanced", },
        ['RefreshCombat']   = { DisplayName = "Combat Threshold", Category = "Utility/Items/Misc", Index = 11, Tooltip = "The duration threshold for refreshing a buff song in combat. ***WARNING: Editing this value can drastically alter your ability to maintain buff songs!*** This needs to be carefully tailored towards your song line-up.", Default = 6, Min = 0, Max = 30, ConfigType = "Advanced", },
        --Instruments--
        ['SwapInstruments'] = { DisplayName = "Auto Swap Instruments", Index = 1, Category = "Instruments", Tooltip = "Auto swap instruments for songs", Default = false, },
        ['BrassInst']       = { DisplayName = "Brass Instrument", Index = 3, Category = "Instruments", Tooltip = "Brass Instrument to Swap in as needed.", Type = "ClickyItem", Default = "", },
        ['WindInst']        = { DisplayName = "Wind Instrument", Index = 4, Category = "Instruments", Tooltip = "Wind Instrument to Swap in as needed.", Type = "ClickyItem", Default = "", },
        ['PercInst']        = { DisplayName = "Percussion Instrument", Index = 5, Category = "Instruments", Tooltip = "Percussion Instrument to Swap in as needed.", Type = "ClickyItem", Default = "", },
        ['StringedInst']    = { DisplayName = "Stringed Instrument", Index = 6, Category = "Instruments", Tooltip = "Stringed Instrument to Swap in as needed.", Type = "ClickyItem", Default = "", },
        ['Offhand']         = { DisplayName = "Offhand", Index = 2, Category = "Instruments", Tooltip = "Item to swap in when no instrument is available or needed.", Type = "ClickyItem", Default = "", },
    },
    ['Spells']          = { getSpellCallback = generateSongList, },
}
return _ClassConfig
