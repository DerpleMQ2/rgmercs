--- @type Mq
local mq          = require('mq')
local Config      = require('utils.config')
local Core        = require("utils.core")
local Targeting   = require("utils.targeting")
local Casting     = require("utils.casting")
local Strings     = require("utils.strings")
local Logger      = require("utils.logger")
local ItemManager = require('utils.item_manager')

local Tooltips    = {
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
        Core.DoCmd("/plugin medley unload")
    end
    Logger.log_info(
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
            if Config:GetSetting(settingToCheck) > 1 then addSong(songToAdd) end
        else --if a third category is ever needed this can become "toggle" or somesuch
            if Config:GetSetting(settingToCheck) then addSong(songToAdd) end
        end
    end

    local function AddCriticalSongs()
        ConditionallyAddSong("UseAEAAMez", "MezAESong", 85)
        ConditionallyAddSong("UseSingleTgtMez", "MezSong", 15)
        ConditionallyAddSong("DoSTSlow", "SlowSong", 23)
        ConditionallyAddSong("DoAESlow", "AESlowSong", 20)
        if Config:GetSetting('UseRunBuff') == 2 and myLevel >= 49 then
            addSong("LongRunBuff")
        elseif Config:GetSetting('UseRunBuff') == 3 then
            addSong("ShortRunBuff")
        end
        ConditionallyAddSong("UseEndBreath", "EndBreathSong", 16)
        ConditionallyAddSong("CharmOn", "CharmSong", 16)
        ConditionallyAddSong("DoDispel", "DispelSong", 40)
    end

    local function AddMainGroupDPSSongs()
        if myLevel >= 10 then addSong('WarMarchSong') end --leaving this mandatory but may revisit pending feedback
        if myLevel >= 64 or (myLevel >= 45 and Config:GetSetting('AriaBeforeOverhaste')) then addSong('MainAriaSong') end
        ConditionallyAddSong("UseArcane", "ArcaneSong", 70, "combo")
        ConditionallyAddSong('UseDicho', 'DichoSong', 101, "combo")
    end

    local function AddSelfDPSSongs()
        ConditionallyAddSong("UseAlliance", "AllianceSong", 102)
        if Config:GetSetting('UseInsult') > 1 and myLevel >= 85 then addSong("InsultSong") end
        ConditionallyAddSong("UseFireDots", "FireDotSong", 30)
        ConditionallyAddSong("UseIceDots", "IceDotSong", 30)
        ConditionallyAddSong("UseDiseaseDots", "DiseaseDotSong", 30)
        ConditionallyAddSong("UsePoisonDots", "PoisonDotSong", 30)
        ConditionallyAddSong("UseJonthan", "Jonthan", 7, "combo")
        if Config:GetSetting('UseInsult') == 3 and myLevel >= 90 then addSong("InsultSong2") end
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
        if Config:GetSetting('RegenSong') == 2
        then
            addSong("GroupRegenSong")
        elseif Config:GetSetting('RegenSong') == 3 and myLevel >= 58
        then
            addSong("AreaRegenSong")
        end
        ConditionallyAddSong("UseCrescendo", "CrescendoSong", 75)
        ConditionallyAddSong("UseAmp", "AmpSong", 30, "combo")
    end
    -----------------------------------------------------------------------------------------

    AddCriticalSongs()
    if Core.IsModeActive("General") then
        AddMainGroupDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddMeleeDPSSongs()
        AddCasterDPSSongs()
        AddHealerSongs()
        AddTankSongs()
    elseif Core.IsModeActive("Tank") then -- Tank
        AddTankSongs()
        AddMainGroupDPSSongs()
        AddHealerSongs()
        AddMeleeDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddCasterDPSSongs()
    elseif Core.IsModeActive("Caster") then
        AddMainGroupDPSSongs()
        AddCasterDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddMeleeDPSSongs()
        AddHealerSongs()
        AddTankSongs()
    elseif Core.IsModeActive("Healer") then -- Healer
        AddHealerSongs()
        AddMainGroupDPSSongs()
        AddRegenSongs()
        AddSelfDPSSongs()
        AddCasterDPSSongs()
        AddTankSongs()
        AddMeleeDPSSongs()
    else
        Logger.log_warn("Bard Mode not found!  Adding DPS songs, but you should select a mode.")
        AddMainGroupDPSSongs()
        AddSelfDPSSongs()
        AddRegenSongs()
        AddMeleeDPSSongs()
        AddCasterDPSSongs()
    end
    return songCache
end

local _ClassConfig = {
    _version            = "2.1 - Project Lazarus",
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
        IsMezzing  = function() return Config:GetSetting('UseSingleTgtMez') or Config:GetSetting('UseAEAAMez') end,
        IsCuring   = function() return Config:GetSetting('UseCure') end,
        IsCharming = function() return Config:GetSetting('CharmOn') and mq.TLO.Pet.ID() == 0 end,
    },
    ['Cures']           = {
        CureNow = function(self, type, targetId)
            local cureSong = Core.GetResolvedActionMapItem('CureSong')
            if not cureSong or not cureSong() then return false end
            return Casting.UseSong(cureSong.RankName.Name(), targetId, true)
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
            "Eriki's Psalm of Power",
            "Rizlona's Call of Flame",
            "Rizlona's Fire",
            "Rizlona's Embers",
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
        ['CalmSong'] = {
            -- CalmSong - Level Range 8+ --Included for manual use with /rgl usemap
            "Kelin's Lugubrious Lament", -- Level 8 (Max Mob Level of 60)
            "Silent Song of Quellious",  -- Level 61
            "Luvwen's Aria of Serenity", -- Level 66
        },
    },
    ['HelperFunctions'] = {
        SwapInst = function(type)
            if not Config:GetSetting('SwapInstruments') then return end
            Logger.log_verbose("\ayBard SwapInst(): Swapping to Instrument Type: %s", type)
            if type == "Percussion Instruments" then
                ItemManager.SwapItemToSlot("offhand", Config:GetSetting('PercInst'))
                return
            elseif type == "Wind Instruments" then
                ItemManager.SwapItemToSlot("offhand", Config:GetSetting('WindInst'))
                return
            elseif type == "Brass Instruments" then
                ItemManager.SwapItemToSlot("offhand", Config:GetSetting('BrassInst'))
                return
            elseif type == "Stringed Instruments" then
                ItemManager.SwapItemToSlot("offhand", Config:GetSetting('StringedInst'))
                return
            end
            ItemManager.SwapItemToSlot("offhand", Config:GetSetting('Offhand'))
        end,
        CheckSongStateUse = function(self, config)   --determine whether a song should be song by comparing combat state to settings
            local usestate = Config:GetSetting(config)
            if Targeting.GetXTHaterCount() == 0 then --I have tried this with combat_state nand XTHater, and both have their ups and downs. Keep an eye on this.
                return usestate > 2                  --I think XTHater will work better if the bard autoassists at 99 or 100.
            else
                return usestate < 4
            end
        end,
        RefreshBuffSong = function(songSpell) --determine how close to a buff's expiration we will resing to maintain full uptime
            if not songSpell or not songSpell() then return false end
            local me = mq.TLO.Me
            local threshold = Config:GetSetting('RefreshCombat')
            --an earlier version of this function checked your cast speed to add to this value, but cast speed TLO is always rounded down and is virtually always "2"
            if Targeting.GetXTHaterCount() == 0 then threshold = Config:GetSetting('RefreshDT') end

            local res = Casting.SongMemed(songSpell) and
                ((me.Buff(songSpell.Name()).Duration.TotalSeconds() or 999) <= threshold or
                    (me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) <= threshold)
            Logger.log_verbose("\ayRefreshBuffSong(%s) => memed(%s), song: duration(%0.2f) < reusetime(%0.2f) buff: duration(%0.2f) < reusetime(%0.2f) --> result(%s)",
                songSpell.Name(),
                Strings.BoolToColorString(me.Gem(songSpell.RankName.Name())() ~= nil),
                me.Song(songSpell.Name()).Duration.TotalSeconds() or 0, threshold,
                me.Buff(songSpell.Name()).Duration.TotalSeconds() or 0,
                threshold,
                Strings.BoolToColorString(res))
            return res
        end,
        UnwantedAggroCheck = function(self) --Self-Explanatory. Add isTanking to this if you ever make a mode for bardtanks!
            if Targeting.GetXTHaterCount() == 0 or Core.IAmMA() or mq.TLO.Group.Puller.ID() == mq.TLO.Me.ID() then return false end
            return Targeting.IHaveAggro(100)
        end,
        DotSongCheck = function(songSpell) --Check dot stacking, stop dotting when HP threshold is reached based on mob type, can't use utils function because we try to refresh just as the dot is ending
            if not songSpell or not songSpell() then return false end
            local named = Targeting.IsNamed(mq.TLO.Target)
            local targethp = Targeting.GetTargetPctHPs()

            return Casting.SpellStacksOnTarget(songSpell) and ((named and (Config:GetSetting('NamedStopDOT') < targethp)) or
                (not named and Config:GetSetting('HPStopDOT') < targethp))
        end,
        GetDetSongDuration = function(songSpell) -- Checks target for duration remaining on dot songs
            local duration = mq.TLO.Target.FindBuff("name " .. songSpell.Name()).Duration.TotalSeconds() or 0
            Logger.log_debug("getDetSongDuration() Current duration for %s : %d", songSpell, duration)
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
                return not Casting.IAmFeigning() and not (combat_state == "Downtime" and mq.TLO.Me.Invis())
            end,
        },
        {
            name = 'Downtime',
            state = 1,
            steps = 1,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and not (Casting.IAmFeigning() or mq.TLO.Me.Invis())
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and not Casting.IAmFeigning() and
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or self.ClassConfig.HelperFunctions.UnwantedAggroCheck(self))
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting("DoSTSlow") or Config:GetSetting("DoAESlow") or Config:GetSetting("DoDispel") end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and Casting.DebuffConCheck()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'CombatSongs',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
    },
    ['Rotations']       = {
        ['Burn'] = {
            {
                name = "Quick Time",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Funeral Dirge",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID()) -- and Config:GetSetting('UseFuneralDirge') --see note in config settings
                end,
            },
            {
                name = "Spire of the Minstrels",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Bladed Song",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Song of Stone",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Thousand Blades",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell)
                end,
            },
            {
                name = "Flurry of Notes",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Dance of Blades",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
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
                    return Config:GetSetting('DoChestClick') and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
            {
                name = "Cacophony",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Frenzied Kicks",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoVetAA') then return false end
                    return Casting.AAReady(aaName)
                end,
            },
        },
        ['Debuff'] = {
            -- {
            --     name = "MezAESong",
            --     type = "Song",
            --     cond = function(self, songSpell)
            --         if not (Config:GetSetting('MezOn') and Config:GetSetting('UseAEAAMez') and Casting.SongMemed(songSpell)) then return false end
            --         return Targeting.GetXTHaterCount() >= Config:GetSetting("MezAECount") and (mq.TLO.Me.GemTimer(songSpell.RankName.Name())() or -1) == 0
            --     end,
            -- },
            {
                name = "AESlowSong",
                type = "Song",
                cond = function(self, songSpell)
                    return Config:GetSetting("DoAESlow") and Casting.DetSpellCheck(songSpell) and Targeting.GetXTHaterCount() > 2 and not mq.TLO.Target.Slowed()
                end,
            },
            {
                name = "SlowSong",
                type = "Song",
                cond = function(self, songSpell)
                    return Config:GetSetting("DoSTSlow") and Casting.DetSpellCheck(songSpell) and not mq.TLO.Target.Slowed()
                end,
            },
            {
                name = "DispelSong",
                type = "Song",
                cond = function(self, songSpell)
                    return Config:GetSetting('DoDispel') and mq.TLO.Target.Beneficial()
                end,
            },
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
                        Core.DoCmd("/keypress AUTOPRIM")
                    end
                end,
            },]]
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if Config:GetSetting('UseEpic') == 1 then return false end
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck())) and mq.TLO.FindItem(itemName)() and
                        mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
            {
                name = "Fierce Eye",
                type = "AA",
                cond = function(self, aaName)
                    if Config:GetSetting('UseFierceEye') == 1 then return false end
                    return (Config:GetSetting('UseFierceEye') == 3 or (Config:GetSetting('UseFierceEye') == 2 and Casting.BurnCheck())) and
                        Casting.AAReady(aaName)
                end,
            },
            {
                name = "Dreadstone",
                type = "Item",
                cond = function(self, itemName)
                    -- This item is instant cast for free with almost no CD, just mash it forever when it's available
                    if not Config:GetSetting('UseDreadstone') then return false end
                    return mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
            {
                name = "ReflexStrike",
                type = "Disc",
                tooltip = Tooltips.ReflexStrike,
                cond = function(self, discSpell)
                    local pct = Config:GetSetting('GroupManaPct')
                    return Casting.TargetedDiscReady(discSpell) and (mq.TLO.Group.LowMana(pct)() or -1) >= Config:GetSetting('GroupManaCt')
                end,
            },
            {
                name = "Boastful Bellow",
                type = "AA",
                cond = function(self, aaName, target)
                    if Config:GetSetting('UseBellow') == 1 then return false end
                    return ((Config:GetSetting('UseBellow') == 3 and mq.TLO.Me.PctEndurance() > Config:GetSetting('SelfEndPct')) or (Config:GetSetting('UseBellow') == 2 and Casting.BurnCheck())) and
                        Casting.DetSpellCheck(mq.TLO.Me.AltAbility(aaName).Spell) and Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Intimidation",
                type = "Ability",
                cond = function(self, abilityName)
                    if (mq.TLO.Me.AltAbility("Intimidation").Rank() or 0) < 2 then return false end
                    return mq.TLO.Me.AbilityReady(abilityName)()
                end,
            },
        },
        ['CombatSongs'] = {
            {
                name = "DichoSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseDicho') == 1 then return false end
                    return (Config:GetSetting('UseDicho') == 3 and (mq.TLO.Me.PctEndurance() > Config:GetSetting('SelfEndPct') or Casting.BurnCheck()))
                        or (Config:GetSetting('UseDicho') == 2 and Casting.BuffActiveByID(mq.TLO.Me.AltAbility("Quick Time").Spell.ID()))
                end,
            },
            {
                name = "InsultSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseInsult') then return false end
                    return (mq.TLO.Me.GemTimer(songSpell.RankName.Name())() or -1) == 0 and (mq.TLO.Me.PctMana() > Config:GetSetting('SelfManaPct') or Casting.BurnCheck())
                end,
            },
            {
                name = "FireDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseFireDots') and Casting.SongMemed(songSpell) then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "IceDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseIceDots') and Casting.SongMemed(songSpell) then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "PoisonDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UsePoisonDots') and Casting.SongMemed(songSpell) then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "DiseaseDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseDiseaseDots') and Casting.SongMemed(songSpell) then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "InsultSong2",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseInsult') then return false end
                    return (mq.TLO.Me.GemTimer(songSpell.RankName.Name())() or -1) == 0 and (mq.TLO.Me.PctMana() > Config:GetSetting('SelfManaPct') or Casting.BurnCheck())
                end,
            },
            {
                name = "AllianceSong",
                type = "Song",
                cond = function(self, songSpell)
                    return Casting.SongMemed(songSpell) and Config:GetSetting('UseAlliance') and
                        (mq.TLO.Me.PctMana() > Config:GetSetting('SelfManaPct') or Casting.BurnCheck()) and Casting.DetSpellCheck(songSpell)
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
                    if not (Config:GetSetting('UseEndBreath') and (mq.TLO.Me.FeetWet() or mq.TLO.Zone.ShortName() == 'thegrey')) then return false end
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
                    if Config:GetSetting('UseJonthan') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseJonthan") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "ArcaneSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseArcane') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseArcane") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "CrescendoSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseCrescendo') then return false end
                    local pct = Config:GetSetting('GroupManaPct')
                    return (mq.TLO.Me.GemTimer(songSpell.RankName.Name())() or -1) == 0 and (mq.TLO.Group.LowMana(pct)() or -1) >= Config:GetSetting('GroupManaCt')
                end,
            },
            {
                name = "GroupRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('RegenSong') ~= 2 then return false end
                    local pct = Config:GetSetting('GroupManaPct')
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell) and
                        ((Config:GetSetting('UseRegen') == 1 and (mq.TLO.Group.LowMana(pct)() or 999) >= Config:GetSetting('GroupManaCt'))
                            or (Config:GetSetting('UseRegen') > 1 and self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseRegen")))
                end,
            },
            {
                name = "AreaRegenSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('RegenSong') ~= 3 then return false end
                    local pct = Config:GetSetting('GroupManaPct')
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell) and
                        not (mq.TLO.Me.Combat() and (mq.TLO.Group.LowMana(pct)() or 999) < Config:GetSetting('GroupManaCt'))
                end,
            },
            {
                name = "AmpSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseAmp') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseAmp") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "SufferingSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseSuffering') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseSuffering") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "SpitefulSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseSpiteful') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseSpiteful") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "SprySonataSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseSpry') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseSpry") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "ResistSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseResist') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseResist") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "RecklessSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseReckless') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseReckless") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "AccelerandoSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseAccelerando') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseAccelerando") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "FireBuffSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseFireBuff') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseFireBuff") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "ColdBuffSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseColdBuff') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseColdBuff") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "DotBuffSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseDotBuff') == 1 then return false end
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
                    if Config:GetSetting('UseRunBuff') ~= 3 then return false end
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "LongRunBuff",
                type = "Song",
                targetId = function(self) return { mq.TLO.Me.ID(), } end,
                cond = function(self, songSpell)
                    if Config:GetSetting('UseRunBuff') ~= 2 then return false end
                    return (mq.TLO.Me.Buff(songSpell.Name()).Duration.TotalSeconds() or 0) <= 15
                end,
            },
            {
                name = "Selo's Sonata",
                type = "AA",
                targetId = function(self) return { mq.TLO.Me.ID(), } end,
                cond = function(self, aaName)
                    if Config:GetSetting('UseRunBuff') ~= 1 then return false end
                    --refreshes slightly before expiry for better uptime
                    return Casting.AAReady(aaName) and (mq.TLO.Me.Buff(mq.TLO.AltAbility(aaName).Spell.Trigger(1)).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "Rallying Solo", --Rallying Call theoretically possible but problematic, needs own rotation akin to Focused Paragon, etc
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and (mq.TLO.Me.PctEndurance() < 30 or mq.TLO.Me.PctMana() < 30)
                end,
            },
            {
                name = "BardDPSAura",
                type = "Song",
                pre_activate = function(self, songSpell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not Casting.AuraActiveByName(songSpell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, songSpell)
                    return not Casting.AuraActiveByName(songSpell.BaseName()) and Config:GetSetting('UseAura') == 1
                end,
            },
            {
                name = "BardRegenAura",
                type = "Song",
                pre_activate = function(self, songSpell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not Casting.AuraActiveByName(songSpell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, songSpell)
                    return not Casting.AuraActiveByName(songSpell.BaseName()) and Config:GetSetting('UseAura') == 2
                end,
            },
            {
                name = "SymphonyOfBattle",
                type = "Item",
                targetId = function(self) return { mq.TLO.Me.ID(), } end,
                cond = function(self, itemName)
                    if not Config:GetSetting('UseSoBItems') then return false end
                    return Casting.SelfBuffCheck("Symphony of Battle") and mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
            {
                name = "EndBreathSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not (Config:GetSetting('UseEndBreath') and (mq.TLO.Me.FeetWet() or mq.TLO.Zone.ShortName() == 'thegrey')) then return false end
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoVetAA') then return false end
                    return mq.TLO.Me.PctHPs() < 35 and Casting.AAReady(aaName)
                end,
            },
            {
                name = "Fading Memories",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('UseFading') then return false end
                    return Casting.AAReady(aaName) and self.ClassConfig.HelperFunctions.UnwantedAggroCheck(self)
                    --I wanted to use XTAggroCount here but it doesn't include your current target in the number it returns and I don't see a good workaround. For Loop it is.
                end,
            },
            {
                name = "Hymn of the Last Stand",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Casting.AAReady(aaName)
                end,
            },
            {
                name = "Shield of Notes",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Casting.AAReady(aaName)
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
        ['Mode']                = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 4,
            FAQ = "What do the different Modes do?",
            Answer = "There are four modes: General, Tank Caster and Healer.\n" ..
                "General will prioritize your gems for general use and is the default.\n" ..
                "Tank will prioritize some gems to support a tank group.\n" ..
                "Caster will prioritize some gems to support a caster group.\n" ..
                "Healer will prioritize some gems to support healers.",
        },
        --Mana/Endurance Sustainment
        ['SelfManaPct']         = {
            DisplayName = "Self Min Mana %",
            Category = "Mana/End Sustain",
            Index = 1,
            Tooltip = "Minimum Mana% to use Insult and Alliance outside of burns.",
            Default = 20,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why am I constantly low on mana?",
            Answer = "Insults take a lot of mana, but we can control that amount with the Self Min Mana %.\n" ..
                "Try adjusting this to the minimum amount of mana you want to keep in reserve. Note that burns will ignore this setting.",
        },
        ['SelfEndPct']          = {
            DisplayName = "Self Min End %",
            Category = "Mana/End Sustain",
            Index = 2,
            Tooltip = "Minimum End% to use Bellow or Dicho outside of burns.",
            Default = 20,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why am I constantly low on endurance?",
            Answer = "Bellow will quickly eat your endurance, and Dicho can help it along. By default your BRD will keep a reserve.\n" ..
                "You can adjust Self Mind End % to set the amount of endurance you want to keep in reserve. Note that burns will ignore this setting.",
        },
        ['GroupManaPct']        = {
            DisplayName = "Group Mana %",
            Category = "Mana/End Sustain",
            Index = 3,
            Tooltip = "Mana% to begin managing group mana (See FAQ)",
            Default = 80,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "What does the Group Mana % setting control exactly??",
            Answer = "Group Mana % controls when we begin using Crescendoes and Reflexive Strikes.\n" ..
                "If configured under the Regen Song options, it also governs when Regen Song will be sung.",
        },
        ['GroupManaCt']         = {
            DisplayName = "Group Mana Count",
            Category = "Mana/End Sustain",
            Index = 4,
            Tooltip = "The number of party members (including yourself) that need to be under the above mana percentage.",
            Default = 2,
            Min = 1,
            Max = 6,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my Crescendo or Reflexive Strike songs?",
            Answer = "You may not have enough party members under the Group Mana % setting in group mana.\n" ..
                "Try adjusting Group Mana Count to the number of party members that must be below that amount before using these abilities.",
        },
        --Debuffs
        ['DoSTSlow']            = {
            DisplayName = "Use Slow (ST)",
            Category = "Debuffs",
            Index = 1,
            Tooltip = Tooltips.SlowSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my single target Slow song?",
            Answer = "Simply enable the Use Slow (ST) option.",
        },
        ['DoAESlow']            = {
            DisplayName = "Use Slow (AE)",
            Category = "Debuffs",
            Index = 2,
            Tooltip = Tooltips.AESlowSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my AE Slow song?",
            Answer = "Simply enable the Use Slow (AE) option.",
        },
        ['DoDispel']            = {
            DisplayName = "Use Dispel",
            Category = "Debuffs",
            Index = 3,
            Tooltip = Tooltips.DispelSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Dispel song?",
            Answer = "You can enable Use Dispel to use your Dispel song when the target has beneficial effects.",
        },
        --Regen/Healing
        ['RegenSong']           = {
            DisplayName = "Regen Song Choice:",
            Category = "Regen/Healing",
            Index = 1,
            Tooltip = "Select the Regen Song to be used, if any. Always used out of combat if selected. Use in-combat is determined by sustain settings.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'None', 'Group', 'Area', },
            Default = 2,
            Min = 1,
            Max = 3,
            FAQ = "Why can't I choose between HP and Mana for my regen songs?",
            Answer = "At low level, the regen songs are spaced broadly, and wallow back and forth before settling on providing both resources.\n" ..
                "Endurance is eventually added as well.",
        },
        ['UseRegen']            = {
            DisplayName = "Regen Song Use:",
            Category = "Regen/Healing",
            Index = 2,
            Tooltip = "When to use the Regen Song selected above.",
            Type = "Combo",
            ComboOptions = { 'Under Group Mana % (Advanced Options Setting)', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
            FAQ = "Can I change when I sing my regen songs?",
            Answer = "You can change when you sing your regen songs by changing the [UseRegen] setting.\n" ..
                "Try changing this setting to determine when you want to use your regen songs.",
        },
        ['UseCrescendo']        = {
            DisplayName = "Crescendo Delayed Heal",
            Category = "Regen/Healing",
            Index = 3,
            Tooltip = Tooltips.CrescendoSong,
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why aren't my Crescendoes being used?",
            Answer = "Crescendo Delayed Heals aren't used until the thresholds set in the Mana sustain settings tab.",
        },
        ['UseCure']             = {
            DisplayName = "Cure Ailments",
            Category = "Regen/Healing",
            Index = 4,
            Tooltip = Tooltips.CureSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Cure song?",
            Answer = "Select the Cure Ailments setting in the Regen/Healing tab to use your Cure song when the group has detrimental effects.",
        },
        --DPS - Self
        ['UseBellow']           = {
            DisplayName = "Use Bellow:",
            Category = "DPS - Self",
            Index = 1,
            Tooltip = "Use Boastful Bellow",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my Boastful Bellow being recast early? My BRD is using it again before the conclusion nuke!",
            Answer = "Unfortunately, MQ currently reports the buff falling off early; we are examining possible fixes at this time.",
        },
        ['UseInsult']           = {
            DisplayName = "Insults to Use:",
            Category = "DPS - Self",
            Index = 2,
            Tooltip = Tooltips.InsultSong,
            Type = "Combo",
            ComboOptions = { 'None', 'Current Tier', 'Current + Old Tier', },
            Default = 3,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using the second insult when I selected Current + Old?",
            Answer = "Depending on how crowded your song selection is, you may not see this cast often.\n" ..
                "You may need to adjust your selections to accomodate this one.",
        },
        ['UseFireDots']         = {
            DisplayName = "Use Fire Dots",
            Category = "DPS - Self",
            Index = 3,
            Tooltip = Tooltips.FireDotSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Fire Dot song?",
            Answer = "You can enable [UseFireDots] to use your Fire Dot song when you are in combat.",
        },
        ['UseIceDots']          = {
            DisplayName = "Use Ice Dots",
            Category = "DPS - Self",
            Index = 4,
            Tooltip = Tooltips.IceDotSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Ice Dot song?",
            Answer = "You can enable [UseIceDots] to use your Ice Dot song when you are in combat.",
        },
        ['UsePoisonDots']       = {
            DisplayName = "Use Poison Dots",
            Category = "DPS - Self",
            Index = 5,
            Tooltip = Tooltips.PoisonDotSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Poison Dot song?",
            Answer = "You can enable [UsePoisonDots] to use your Poison Dot song when you are in combat.",
        },
        ['UseDiseaseDots']      = {
            DisplayName = "Use Disease Dots",
            Category = "DPS - Self",
            Index = 6,
            Tooltip = Tooltips.DiseaseDotSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Disease Dot song?",
            Answer = "You can enable [UseDiseaseDots] to use your Disease Dot song when you are in combat.",

        },
        ['UseJonthan']          = {
            DisplayName = "Use Jonthan",
            Category = "DPS - Self",
            Index = 7,
            Tooltip = Tooltips.Jonthan,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "How do I use my Jonthan song?",
            Answer = "You can enable [UseJonthan] to use your Jonthan song." ..
                "Options are (Never, In-Combat Only, Always, Out-of-Combat Only).",
        },
        --DPS - Group
        ['UseFierceEye']        = {
            DisplayName = "Fierce Eye Use:",
            Category = "DPS - Group",
            Index = 8,
            Tooltip = "When to use the Fierce Eye AA.",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is Fierce Eye being being used on trash?",
            Answer = "By default, Fierce Eye will fire any time it is available in combat, as holding it for Burns tends to be an overall DPS loss.\n" ..
                "Adjust to your personal taste.",
        },
        ['UseArcane']           = {
            DisplayName = "Use Arcane Line",
            Category = "DPS - Group",
            Index = 2,
            Tooltip = Tooltips.ArcaneSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "Why am I using the Arcane line all the time? It isn't that great...",
            Answer = "The Arcane line of songs was buffed on live in early 2024, and is now worthy of prioritizing over any other song but Aria and (possibly War March).",
        },
        ['UseDicho']            = {
            DisplayName = "Psalm (Dicho) Use:",
            Category = "DPS - Group",
            Index = 4,
            Tooltip = Tooltips.DichoSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'During QuickTime', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why is there no option to use Dicho in burns only?",
            Answer =
                "Since QuickTime is set to be used on burns and may last after the burns, aligning Dicho with it allows a smoother song rotation and allows some use even after a Burn was triggered.\n" ..
                "Dicho settings can be adjusted in the DPS - Group tab.",
        },
        ['UseSuffering']        = {
            DisplayName = "Use Suffering Line",
            Category = "DPS - Group",
            Index = 3,
            Tooltip = Tooltips.SufferingSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 4,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "Why am I singing Suffering line? It isn't great!",
            Answer = "By default we will sing this line during downtime in hopes that the proc can provide a slight aDPS boost when we next engage.",
        },
        ['AriaBeforeOverhaste'] = {
            DisplayName = "Aria Before Overhaste",
            Category = "DPS - Group",
            Index = 1,
            Tooltip = "Choose whether to use the Aria line solely to boost spell damage before the song adds overhaste at level 64.",
            Default = true,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why is my bard using a spell damage boost? I use a melee party.",
            Answer = "The Aria line of spells provides both spell damage and overhaste, but overhaste only kicks in at level 64.\n" ..
                "You can change its setting in the DPS - Group Tab if you would prefer not to use it until then.",
        },
        ['UseFireBuff']         = {
            DisplayName = "Use Fire Spell Buff",
            Category = "DPS - Group",
            Index = 5,
            Tooltip = Tooltips.FireBuffSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my bard using the spell/dot proc buffs?",
            Answer = "Outside of limited scenarios and limited level ranges, these procs underperform compared to any other song option.\n" ..
                "Nonetheless, the options can be found in the DPS - Group Tab if you find yourself in the above scenarios.",
        },
        ['UseColdBuff']         = {
            DisplayName = "Use Cold Spell Buff",
            Category = "DPS - Group",
            Index = 6,
            Tooltip = Tooltips.ColdBuffSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my bard using the spell/dot proc buffs?",
            Answer = "Outside of limited scenarios and limited level ranges, these procs underperform compared to any other song option.\n" ..
                "Nonetheless, the options can be found in the DPS - Group Tab if you find yourself in the above scenarios.",
        },
        ['UseDotBuff']          = {
            DisplayName = "Use Fire/Magic DoT Buff",
            Category = "DPS - Group",
            Index = 7,
            Tooltip = Tooltips.DotBuffSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my bard using the spell/dot proc buffs?",
            Answer = "Outside of limited scenarios and limited level ranges, these procs underperform compared to any other song option.\n" ..
                "Nonetheless, the options can be found in the DPS - Group Tab if you find yourself in the above scenarios.",
        },
        ['UseAlliance']         = {
            DisplayName = "Use Alliance",
            Category = "DPS - Group",
            Index = 9,
            Tooltip = Tooltips.AllianceSong,
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "How do I use my Alliance song?",
            Answer = "You can enable Use Alliance to use your Alliance song when you are in combat.",

        },
        --Why is this optional? I can't think of a situation that it should be false, keeping it here until I find out.Maybe a stacking thing?
        --['UseFuneralDirge']		= { DisplayName = "Funeral Dirge (Burn)", Category = "DPS - Group", Index = 2, Tooltip = "Use Funeral Dirge during Burns", Default = true, },
        --Buffs and Defenses
        ['UseAura']             = {
            DisplayName = "Use Bard Aura",
            Category = "Buffs and Defenses",
            Index = 1,
            Tooltip = "Select the Aura to be used, if any.",
            Type = "Combo",
            ComboOptions = { 'DPS Aura', 'Regen', 'None', },
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "Do bard auras and song stack when effects are similar?",
            Answer = "While certain parts of each will not stack, auras add some buffs not present in the song.\n" ..
                "This makes the auras and songs worth using together, and the answer is nearly always to use the DPS Aura.",
        },
        ['UseAmp']              = {
            DisplayName = "Use Amp",
            Category = "Buffs and Defenses",
            Index = 2,
            Tooltip = Tooltips.AmpSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "How do I use my Amplification song?",
            Answer = "You can enable the Use Amp option in Buffs and Defenses to use your Amplification song." ..
                "Options are (Never, In-Combat Only, Always, Out-of-Combat Only).",
        },
        ['UseSpiteful']         = {
            DisplayName = "Use Spiteful",
            Category = "Buffs and Defenses",
            Index = 3,
            Tooltip = Tooltips.SpitefulSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "How do I use my Spiteful song?",
            Answer = "You can enable Use Spiteful to use your Spiteful song." ..
                "Options are (Never, In-Combat Only, Always, Out-of-Combat Only).",
        },
        ['UseSpry']             = {
            DisplayName = "Use Spry",
            Category = "Buffs and Defenses",
            Index = 4,
            Tooltip = Tooltips.SprySonataSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "How do I use my Spry Sonata song?",
            Answer = "You can enable Use Spry to use your Spry Sonata song." ..
                "Options are (Never, In-Combat Only, Always, Out-of-Combat Only).",
        },
        ['UseResist']           = {
            DisplayName = "Use DS/Resist Psalm",
            Category = "Buffs and Defenses",
            Index = 5,
            Tooltip = Tooltips.ResistSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "How do I use my Damage Shield / Resist Psalm?",
            Answer = "You can enable the DS/Resist Psalm in the Buffs and Defenses tab." ..
                "Options are (Never, In-Combat Only, Always, Out-of-Combat Only).",
        },
        ['UseReckless']         = {
            DisplayName = "Use Reckless",
            Category = "Buffs and Defenses",
            Index = 6,
            Tooltip = Tooltips.RecklessSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 4,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "Why is my bard singing the Reckless line?",
            Answer = "Reckless is sung out of combat if all other songs are up as a partial filler that can potentially increase healing early in the fight." ..
                "You can adjust or disable this as desired in the Buffs and Defenses tab.",
        },
        ['UseAccelerando']      = {
            DisplayName = "Use Accelerando",
            Category = "Buffs and Defenses",
            Index = 7,
            Tooltip = Tooltips.AccelerandoSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "How do I use my Accelerando song?",
            Answer = "You can enable Use Accelerando to use your Accelerando song." ..
                "Options are (Never, In-Combat Only, Always, Out-of-Combat Only).",
        },
        --Utility/Items/Misc
        ['UseEpic']             = {
            DisplayName = "Epic Use:",
            Category = "Utility/Items/Misc",
            Index = 1,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my BRD using Epic on these trash mobs?",
            Answer = "By default, we use the Epic in any combat, as saving it for burns ends up being a DPS loss over a long frame of time.\n" ..
                "This can be adjusted in the Utility/Items/Misc tab.",
        },
        ['DoChestClick']        = {
            DisplayName = "Chest Click",
            Category = "Utility/Items/Misc",
            Index = 2,
            Tooltip = "Click your equipped chest item.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            ConfigType = "Advanced",
            FAQ = "What is a Chest Click?",
            Answer = "Most Chest slot items after level 75ish have a clickable effect.\n" ..
                "BRD is set to use theirs during burns, so long as the item equipped has a clicky effect.",
        },
        ['UseSoBItems']         = {
            DisplayName = "Symph. of Battle",
            Category = "Utility/Items/Misc",
            Index = 3,
            Tooltip = "Click your Symphony of Battle items.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "What is Symphony of Battle?",
            Answer = "Symphony of Battle is a clicky group haste effect found on Rapier of Somber Notes or Songblade of the Eternal.",
        },
        ['UseDreadstone']       = {
            DisplayName = "Dreadstone",
            Category = "Utility/Items/Misc",
            Index = 4,
            Tooltip = "Use your Dreadstone when able.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "What does the Dreadstone option control?",
            Answer = "Possessed Dreadstone Minstrel's Rapier is a clicky 55% slow item rewarded by the quest \"The Depths of Fear\".",
        },
        ['UseRunBuff']          = {
            DisplayName = "Runspeed Buff:",
            Category = "Utility/Items/Misc",
            Index = 5,
            Tooltip = "Select Runspeed Buff to use. NOTE: This setting may need user adjustment during the early level range!",
            Type = "Combo",
            ComboOptions = { 'AA', 'Song (Long Duration Only)', 'Song (Fastest Available)', 'Off', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using [x] run speed (Selo) buff?",
            Answer = "You can configure your run speed buff selection in the Utility tab, this may need to be adjusted as you level.",
        },
        ['UseEndBreath']        = {
            DisplayName = "Use Enduring Breath",
            Category = "Utility/Items/Misc",
            Index = 6,
            Tooltip = Tooltips.EndBreathSong,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "How do I use my Enduring Breath song?",
            Answer = "You can enable Use Enduring Breath to use your Enduring Breath song when you are in water.",
        },
        ['DoVetAA']             = {
            DisplayName = "Use Vet AA",
            Category = "Utility/Items/Misc",
            Index = 7,
            Tooltip = "Use Veteran AA's in emergencies or during Burn",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "What Vet AA's does BRD use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },
        ['EmergencyStart']      = {
            DisplayName = "Emergency HP%",
            Category = "Utility/Items/Misc",
            Index = 8,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my emergency abilities?",
            Answer = "You may not be below your Emergency HP % in the Utility tab.\n" ..
                "Try adjusting this to the minimum amount of HP you want to have before using these abilities.",
        },
        ['UseFading']           = {
            DisplayName = "Use Combat Escape",
            Category = "Utility/Items/Misc",
            Index = 9,
            Tooltip = "Use Fading Memories when you have aggro and you aren't the Main Assist.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why is my BRD regularly using Fading Memories",
            Answer = "When Use Combat Escape is enabled, Fading Memories will be used when the Bard has any unwanted aggro.\n" ..
                "This helps the common issue of bards gaining aggro from singing before a tank has the chance to secure it.",
        },
        ['RefreshDT']           = {
            DisplayName = "Downtime Threshold",
            Category = "Utility/Items/Misc",
            Index = 10,
            Tooltip =
            "The duration threshold for refreshing a buff song outside of combat. ***WARNING: Editing this value can drastically alter your ability to maintain buff songs!*** This needs to be carefully tailored towards your song line-up.",
            Default = 12,
            Min = 0,
            Max = 30,
            ConfigType = "Advanced",
            FAQ = "Why does my bard keep singing the same two songs?",
            Answer = "You may need to adjust your Downtime Threshold value downward at lower levels/song durations.\n" ..
                "This needs to be carefully tailored towards your song line-up.",
        },
        ['RefreshCombat']       = {
            DisplayName = "Combat Threshold",
            Category = "Utility/Items/Misc",
            Index = 11,
            Tooltip =
            "The duration threshold for refreshing a buff song in combat. ***WARNING: Editing this value can drastically alter your ability to maintain buff songs!*** This needs to be carefully tailored towards your song line-up.",
            Default = 6,
            Min = 0,
            Max = 30,
            ConfigType = "Advanced",
            FAQ = "Songs are dropping regularly, what can I do?",
            Answer = "You may need to stop using so many songs! Alternatively, try tuning your Threshold values as they determine when we will try to resing a song.\n" ..
                "This needs to be carefully tailored towards your song line-up.",
        },
        --Instruments--
        ['SwapInstruments']     = {
            DisplayName = "Auto Swap Instruments",
            Index = 1,
            Category = "Instruments",
            Tooltip = "Auto swap instruments for songs",
            Default = false,
            FAQ = "Does RGMercs BRD support instrument swapping?",
            Answer = "Auto Swap Instruments can be enabled and configured on the Instruments tab.",

        },
        ['BrassInst']           = {
            DisplayName = "Brass Instrument",
            Index = 3,
            Category = "Instruments",
            Tooltip = "Brass Instrument to Swap in as needed.",
            Type = "ClickyItem",
            Default = "",
            FAQ = "How do I use my Brass Instrument?",
            Answer = "Place the correct instrument on your cursor and select the proper text box on your Instrument tab.\n" ..
                "Also, make sure you have Auto Swap Instrument enabled.",
        },
        ['WindInst']            = {
            DisplayName = "Wind Instrument",
            Index = 4,
            Category = "Instruments",
            Tooltip = "Wind Instrument to Swap in as needed.",
            Type = "ClickyItem",
            Default = "",
            FAQ = "How do I use my Wind Instrument?",
            Answer = "Place the correct instrument on your cursor and select the proper text box on your Instrument tab.\n" ..
                "Also, make sure you have Auto Swap Instrument enabled.",
        },
        ['PercInst']            = {
            DisplayName = "Percussion Instrument",
            Index = 5,
            Category = "Instruments",
            Tooltip = "Percussion Instrument to Swap in as needed.",
            Type = "ClickyItem",
            Default = "",
            FAQ = "How do I use my Percussion Instrument?",
            Answer = "Place the correct instrument on your cursor and select the proper text box on your Instrument tab.\n" ..
                "Also, make sure you have Auto Swap Instrument enabled.",
        },
        ['StringedInst']        = {
            DisplayName = "Stringed Instrument",
            Index = 6,
            Category = "Instruments",
            Tooltip = "Stringed Instrument to Swap in as needed.",
            Type = "ClickyItem",
            Default = "",
            FAQ = "How do I use my Stringed Instrument?",
            Answer = "Place the correct instrument on your cursor and select the proper text box on your Instrument tab.\n" ..
                "Also, make sure you have Auto Swap Instrument enabled.",
        },
        ['Offhand']             = {
            DisplayName = "Offhand",
            Index = 2,
            Category = "Instruments",
            Tooltip = "Item to swap in when no instrument is available or needed.",
            Type = "ClickyItem",
            Default = "",
            FAQ = "How do I make sure we put back the correct item after using an instrument?",
            Answer = "Place your desired off-hand item on your cursor and select the proper text box on your Instrument tab.\n" ..
                "Also, make sure you have Auto Swap Instrument enabled.",
        },
    },
    ['Spells']          = { getSpellCallback = generateSongList, },
}
return _ClassConfig
