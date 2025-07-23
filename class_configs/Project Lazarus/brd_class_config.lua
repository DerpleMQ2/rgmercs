local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Strings      = require("utils.strings")
local Logger       = require("utils.logger")
local ItemManager  = require('utils.item_manager')

local Tooltips     = {
    Epic           = 'Item: Casts Epic Weapon Ability',
    BardRunBuff    = "Song Line: Movement Speed Modifier",
    AriaSong       = "Song Line: Spell Damage Focus / Haste v3 Modifier",
    WarMarchSong   = "Song Line: Melee Haste / DS / STR/ATK Increase",
    ArcaneSong     = "Song Line: Group Melee and Spell Proc",
    DPSAura        = "Aura Line: OverHaste / Melee and Caster DPS",
    AreaRegenSong  = "Song Line: AE HP/Mana Regen",
    GroupRegenSong = "Song Line: Group HP/Mana Regen",
    SlowSong       = "Song Line: ST Melee Attack Slow",
    AESlowSong     = "Song Line: PBAE Melee Attack Slow",
    FireDotSong    = "Song Line: Fire DoT and minor resist debuff",
    DiseaseDotSong = "Song Line: Disease DoT and minor resist debuff",
    PoisonDotSong  = "Song Line: Poison DoT and minor resist debuff",
    IceDotSong     = "Song Line: Ice DoT and minor resist debuff",
    EndBreathSong  = "Song Line: Enduring Breath",
    CureSong       = "Song Line: Single Target Cure: Poison/Disease",
    CharmSong      = "Song Line: Charm Mob",
    LowAriaSong    = "Song Line: Warsong and BattleCry prior to combination of effects into Aria",
    AmpSong        = "Song Line: Increase Singing Skill",
    DispelSong     = "Song Line: Dispel a Benefical Effect",
    ResistSong     = "Song Line: Damage Shield / Group Resist Increase",
    MezSong        = "Song Line: Single Target Mez",
    MezAESong      = "Song Line: PBAE Mez",
    Bellow         = "AA: DD + Resist Debuff that leads to a much larger DD upon expiry",
    FuneralDirge   = "AA: DD / Increases Melee Damage Taken on Target",
    FierceEye      = "AA: Increases Base and Crit Melee Damage / Increase Proc Rate / Increase Spell Crit Chance",
    QuickTime      = "AA: Hundred Hands Effect / Increase Melee Hit / Increase Atk",
    Jonthan        = "Song Line: (Self-only) Haste / Melee Damage Modifier / Melee Min Damage Modifier / Proc Modifier",
}

local _ClassConfig = {
    _version            = "3.1 - Project Lazarus",
    _author             = "Algar, Derple, Grimmier, Tiddliestix, SonicZentropy",
    ['Modes']           = { --other modes to reorder spell priorities may be added back in at a later date.
        'General',
    },

    ['ModeChecks']      = {
        CanMez     = function() return true end,
        CanCharm   = function() return true end,
        IsMezzing  = function() return Config:GetSetting('MezOn') end,
        IsCuring   = function() return Config:GetSetting('UseCure') end,
        IsCharming = function() return Config:GetSetting('CharmOn') and mq.TLO.Pet.ID() == 0 end,
    },
    ['Cures']           = {
        CureNow = function(self, type, targetId)
            local cureSong = Core.GetResolvedActionMapItem('CureSong')
            local downtime = mq.TLO.Me.CombatState():lower() ~= "combat"
            if type:lower() == ("disease" or "poison") and Casting.SongReady(cureSong, downtime) then
                return Casting.UseSong(cureSong.RankName.Name(), targetId, downtime)
            end
        end,
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Blade of Vesagran",
            "Prismatic Dragon Blade",
        },
    },
    ['AbilitySets']     = {
        -- TO DO: Added Dirgle of Metala/Snare line
        -- bellow of chaos 66 dd nuke??
        -- one bard band --- this spell does not exist
        -- vulka's chant of lightning - not available as a spell, fuku glyph only
        ['RunBuff'] = {
            "Selo's Accelerating Chorus",
            "Selo's Accelerando",
        },
        ['EndBreathSong'] = {
            "Tarew's Aquatic Ayre", --Level 16
        },
        ['AriaSong'] = {
            "Ancient: Call of Power",
            "Eriki's Psalm of Power",
            "Yelhun's Mystic Call",
            "Echo of the Trusik",
            "Rizlona's Call of Flame",   -- overhaste/spell damage
            "Battlecry of the Vah Shir", -- overhaste only
            "Warsong of the Vah Shir",   -- overhaste only
            -- "Rizlona's Fire",   -- spell damage only
            -- "Rizlona's Embers", -- spell damage only
        },
        ['ArcaneSong'] = {
            "Arcane Aria",
        },
        ['DPSAura'] = {
            "Aura of the Muse",
            "Aura of Insight",
        },
        ['GroupRegenSong'] = {
            "Cantata of Life",               -- 67
            "Wind of Marr",                  -- 62
            "Cantata of Replenishment",      -- 55
            "Cantata of Soothing",           -- 34 start hp/mana. Slightly less mana. They can custom if it they want the 2 mana/tick
            "Cassindra's Chorus of Clarity", -- 32, mana only
            "Cassindra's Chant of Clarity",  -- 20, mana only
            "Hymn of Restoration",           -- 7, hp only
        },
        ['AreaRegenSong'] = {
            "Chorus of Life",          -- 69
            "Chorus of Marr",          -- 64
            "Ancient: Lcea's Lament",  -- 60
            "Chorus of Replenishment", -- 58
        },
        ['WarMarchSong'] = {
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
        ['SlowSong'] = {
            "Requiem of Time",
            "Angstlich's Assonance",    --snare/slow
            "Largo's Assonant Binding", --snare/slow
            "Selo's Consonant Chain",   --snare/slow
        },
        ['AESlowSong'] = {
            "Zuriki's Song of Shenanigans",
            "Largo's Melodic Binding",
        },
        ['FireDotSong'] = {
            "Vulka's Chant of Flame",
            "Tuyen's Chant of Fire",
            "Tuyen's Chant of Flame",
        },
        ['IceDotSong'] = {
            "Vulka's Chant of Frost",
            "Tuyen's Chant of Ice",
            "Tuyen's Chant of Frost",
        },
        ['PoisonDotSong'] = {
            "Vulka's Chant of Poison",
            "Tuyen's Chant of Venom",
            "Tuyen's Chant of Poison",
        },
        ['DiseaseDotSong'] = {
            "Vulka's Chant of Disease",
            "Tuyen's Chant of the Plague",
            "Tuyen's Chant of Disease",
        },
        ['CureSong'] = {
            --"Aria of Innocence", --curse only, and only 2 x 2 counters
            "Aria of Asceticism", --poison/disease Only
        },
        ['CharmSong'] = {
            "Voice of the Vampire",
            "Call of the Banshee",        -- 65
            "Solon's Bewitching Bravura", -- 39
            "Solon's Song of the Sirens", -- 27
        },
        -- ['ChordsAE'] = {
        --     "Chords of Dissonance",
        -- },

        ['AmpSong'] = {
            "Amplification",
        },
        ['DispelSong'] = {
            -- Dispel Song - For pulling to avoid Summons
            "Syvelian's Anti-Magic Aria",
            "Druzzil's Disillusionment",
        },
        ['ResistSong'] = {
            "Verse of Veeshan",
            "Psalm of Veeshan",
        },
        ['MezSong'] = {
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
        ['Jonthan'] = {
            "Jonthan's Inspiration",
            "Jonthan's Provocation",
            "Jonthan's Whistling Warsong",
        },
        ['CalmSong'] = {
            -- CalmSong - Level Range 8+ --Included for manual use with /rgl usemap
            "Luvwen's Aria of Serenity", -- Level 66
            "Silent Song of Quellious",  -- Level 61
            "Kelin's Lugubrious Lament", -- Level 8 (Max Mob Level of 60)
        },
        ['ThousandBlades'] = {
            "Thousand Blades",
        },
        ['ProcSong'] = {
            "Storm Blade",
            "Song of the Storm",
        },
        ['SpellAbsorbSong'] = {
            "Echoes of the Past",
        },
        ['ResistDebuff'] = {
            "Harmony of Sound",
        },
    },
    ['HelperFunctions'] = {
        SwapInst = function(type)
            if not Config:GetSetting('SwapInstruments') then return end
            Logger.log_verbose("\ayBard SwapInst(): Swapping to Instrument Type: %s", type)
            if type == "Percussion Instruments" then
                if mq.TLO.Me.Bandolier('drum')() and Config:GetSetting('UseBandolier') then
                    Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atDrum Bandolier")
                    ItemManager.BandolierSwap('drum')
                    return
                else
                    Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atPercussion Instrument")
                    ItemManager.SwapItemToSlot("offhand", Config:GetSetting('PercInst'))
                    return
                end
            elseif type == "Wind Instruments" then
                if mq.TLO.Me.Bandolier('wind')() and Config:GetSetting('UseBandolier') then
                    Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atWind Bandolier")
                    ItemManager.BandolierSwap('wind')
                    return
                else
                    Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atWind Instrument")
                    ItemManager.SwapItemToSlot("offhand", Config:GetSetting('WindInst'))
                    return
                end
            elseif type == "Brass Instruments" then
                printf("\ayBard SwapInst()\ax:\ao Swapping to Instrument Type: %s", type)
                if mq.TLO.Me.Bandolier('brass')() and Config:GetSetting('UseBandolier') then
                    Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atBrass Bandolier")
                    ItemManager.BandolierSwap('brass')
                    return
                else
                    Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atBrass Instrument")
                    ItemManager.SwapItemToSlot("offhand", Config:GetSetting('BrassInst'))
                    return
                end
            elseif type == "Stringed Instruments" then
                if mq.TLO.Me.Bandolier('string')() and Config:GetSetting('UseBandolier') then
                    Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atStringed Bandolier")
                    ItemManager.BandolierSwap('string')
                else
                    Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atStringed Instrument")
                    ItemManager.SwapItemToSlot("offhand", Config:GetSetting('StringedInst'))
                end
                return
            end
            if mq.TLO.Me.Bandolier('main')() and Config:GetSetting('UseBandolier') then
                ItemManager.BandolierSwap('main')
                Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atMain Bandolier")
            else
                Logger.log_debug("\ayBard SwapInst()\ax:\ao Swapping to \atOffhand Weapon")
                ItemManager.SwapItemToSlot("offhand", Config:GetSetting('Offhand'))
            end
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
            local threshold = Targeting.GetXTHaterCount() == 0 and Config:GetSetting('RefreshDT') or Config:GetSetting('RefreshCombat')
            local duration = songSpell.DurationWindow() == 1 and (me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) or (me.Buff(songSpell.Name()).Duration.TotalSeconds() or 0)
            local ret = duration <= threshold
            Logger.log_verbose("\ayRefreshBuffSong(%s) => memed(%s), duration(%d), threshold(%d), should refresh:(%s)", songSpell,
                Strings.BoolToColorString(me.Gem(songSpell.RankName.Name())() ~= nil), duration, threshold, Strings.BoolToColorString(ret))
            return ret
        end,
        UnwantedAggroCheck = function(self) --Self-Explanatory. Add isTanking to this if you ever make a mode for bardtanks!
            if Targeting.GetXTHaterCount() == 0 or Core.IAmMA() or mq.TLO.Group.Puller.ID() == mq.TLO.Me.ID() then return false end
            return Targeting.IHaveAggro(100)
        end,
        DotSongCheck = function(songSpell) --Check dot stacking, stop dotting when HP threshold is reached based on mob type, can't use utils function because we try to refresh just as the dot is ending
            if not songSpell or not songSpell() then return false end
            return songSpell.StacksTarget() and Targeting.MobNotLowHP(Targeting.GetAutoTarget())
        end,
        GetDetSongDuration = function(songSpell) -- Checks target for duration remaining on dot songs
            local duration = mq.TLO.Target.FindBuff("name " .. "\"" .. songSpell.Name() .. "\"").Duration.TotalSeconds() or 0
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
                return not (combat_state == "Downtime" and mq.TLO.Me.Invis()) and not (Config:GetSetting('BardRespectMedState') and Config.Globals.InMedState)
            end,
        },
        {
            name = 'Downtime',
            state = 1,
            steps = 1,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and not mq.TLO.Me.Invis() and not (Config:GetSetting('BardRespectMedState') and Config.Globals.InMedState)
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or self.ClassConfig.HelperFunctions.UnwantedAggroCheck(self))
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting("DoSTSlow") or Config:GetSetting("DoAESlow") or Config:GetSetting("DoResistDebuff") or Config:GetSetting("DoDispel") end,
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
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'CombatSongs',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['Rotations']       = {
        ['Burn'] = { --Order is heavy WIP
            {
                name = "Quick Time",
                type = "AA",
            },
            {
                name = "Funeral Dirge",
                type = "AA",
            },
            { -- Spire, the SpireChoice setting will determine which ability is displayed/used.
                name_func = function(self)
                    local spireAbil = string.format("Fundament: %s Spire of Nature", Config.Constants.SpireChoices[Config:GetSetting('SpireChoice') or 4])
                    return Casting.CanUseAA(spireAbil) and spireAbil or "Spire Not Purchased/Selected"
                end,
                type = "AA",
            },
            {
                name = "Bladed Song",
                type = "AA",
            },
            {
                name = "Song of Stone",
                type = "AA",
            },
            {
                name = "ThousandBlades",
                type = "Disc",
            },
            {
                name = "Dance of Blades",
                type = "AA",
            },
            {
                name = "Cacophony",
                type = "AA",
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVetAA')
                end,
            },
            {
                name = "A Tune Stuck In Your Head",
                type = "AA",
            },
            {
                name = "SpellAbsorbSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Casting.CastReady(songSpell) then return false end
                    return Config:GetSetting('UseSpellAbsorb')
                end,
            },
        },
        ['Debuff'] = {
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
                name = "ResistDebuff",
                type = "Song",
                cond = function(self, songSpell)
                    return Config:GetSetting('DoResistDebuff') and Casting.DetSpellCheck(songSpell)
                end,
            },
            {
                name = "DispelSong",
                type = "Song",
                cond = function(self, songSpell)
                    return Config:GetSetting('DoDispel') and mq.TLO.Target.Beneficial() ~= nil
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
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "Boastful Bellow",
                type = "AA",
            },
            {
                name = "Vainglorious Shout",
                type = "AA",
                cond = function(self, aaName, target)
                    return Config:GetSetting("UseShout")
                end,
            },
            {
                name = "Kick",
                type = "Ability",
            },
        },
        ['CombatSongs'] = {
            {
                name = "FireDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseFireDots') then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "IceDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseIceDots') then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "PoisonDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UsePoisonDots') then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            {
                name = "DiseaseDotSong",
                type = "Song",
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseDiseaseDots') then return false end
                    return self.ClassConfig.HelperFunctions.DotSongCheck(songSpell) and
                        -- If dot is about to wear off, recast
                        self.ClassConfig.HelperFunctions.GetDetSongDuration(songSpell) <= 3
                end,
            },
            --failsafe/fallback to fill dead space and/or refresh charges, may adjust after more testing
            {
                name = "AriaSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting("UseAria") == 1 then return false end
                    return (mq.TLO.Me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) <= 9
                end,
            },
            {
                name = "ArcaneSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting("UseArcane") == 1 then return false end
                    return (mq.TLO.Me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) <= 9
                end,
            },
            {
                name = "ProcSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting("UseProcSong") == 1 then return false end
                    return (mq.TLO.Me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) <= 9
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
                name = "AriaSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseAria') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseAria") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "WarMarchSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseMarch') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseMarch") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
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
                name = "ProcSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseProcSong') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseProcSong") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
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
                name = "ArcaneSong",
                type = "Song",
                cond = function(self, songSpell)
                    if Config:GetSetting('UseArcane') == 1 then return false end
                    return self.ClassConfig.HelperFunctions.CheckSongStateUse(self, "UseArcane") and self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
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
        },
        ['Downtime'] = {
            {
                name = "Selo's Sonata",
                type = "AA",
                targetId = function(self) return { mq.TLO.Me.ID(), } end,
                cond = function(self, aaName)
                    if not Config:GetSetting('UseRunBuff') then return false end
                    --refresh slightly before expiry for better uptime
                    return (mq.TLO.Me.Buff(aaName).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "RunBuff",
                type = "Song",
                targetId = function(self) return { mq.TLO.Me.ID(), } end,
                cond = function(self, songSpell)
                    if Casting.CanUseAA("Selo's Sonata") or not Config:GetSetting('UseRunBuff') then return false end
                    return self.ClassConfig.HelperFunctions.RefreshBuffSong(songSpell)
                end,
            },
            {
                name = "DPSAura",
                type = "Song",
                pre_activate = function(self, songSpell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not Casting.AuraActiveByName(songSpell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, songSpell)
                    if not Config:GetSetting('UseAura') then return false end
                    return not Casting.AuraActiveByName(songSpell.BaseName())
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
                    return mq.TLO.Me.PctHPs() < 35
                end,
            },
            {
                name = "Fading Memories",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('UseFading') then return false end
                    return self.ClassConfig.HelperFunctions.UnwantedAggroCheck(self)
                    --I wanted to use XTAggroCount here but it doesn't include your current target in the number it returns and I don't see a good workaround. For Loop it is.
                end,
            },
            {
                name = "Hymn of the Last Stand",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "Shield of Notes",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "Blood Drinker's Coating",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCoating') then return false end
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Casting.SelfBuffItemCheck(itemName)
                end,
            },
        },
    },
    ['SpellList']       = { -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
        {
            name = "Default Mode",
            -- cond = function(self) return true end, --Code kept here for illustration, if there is no condition to check, this line is not required
            spells = {
                --role and critical functions
                { name = "MezSong",         cond = function(self) return Config:GetSetting('DoSTMez') end, },
                { name = "CharmSong",       cond = function(self) return Config:GetSetting('CharmOn') end, },
                { name = "SlowSong",        cond = function(self) return Config:GetSetting('DoSTSlow') end, },
                { name = "AESlowSong",      cond = function(self) return Config:GetSetting('DoAESlow') end, },
                { name = "DispelSong",      cond = function(self) return Config:GetSetting('DoDispel') end, },
                { name = "ResistDebuff",    cond = function(self) return Config:GetSetting('DoResistDebuff') end, },
                { name = "CureSong",        cond = function(self) return Config:GetSetting('UseCure') end, },
                { name = "RunBuff",         cond = function(self) return Config:GetSetting('UseRunBuff') and not Casting.CanUseAA("Selo's Sonata") end, },
                { name = "EndBreathSong",   cond = function(self) return Config:GetSetting('UseEndBreath') end, },
                -- major group buffs
                { name = "AriaSong",        cond = function(self) return Config:GetSetting('UseAria') > 1 end, },
                { name = "WarMarchSong",    cond = function(self) return Config:GetSetting('UseMarch') > 1 end, },
                { name = "ProcSong",        cond = function(self) return Config:GetSetting('UseProcSong') > 1 end, },
                { name = "ArcaneSong",      cond = function(self) return Config:GetSetting('UseArcane') > 1 end, },
                { name = "ResistSong",      cond = function(self) return Config:GetSetting('UseResist') > 1 end, },
                { name = "SpellAbsorbSong", cond = function(self) return Config:GetSetting('UseSpellAbsorb') end, },
                { name = "GroupRegenSong",  cond = function(self) return Config:GetSetting('RegenSong') == 2 end, },
                { name = "AreaRegenSong",   cond = function(self) return Config:GetSetting('RegenSong') == 3 end, },
                -- personal dps
                { name = "AmpSong",         cond = function(self) return Config:GetSetting('UseAmp') > 1 end, },
                { name = "Jonthan",         cond = function(self) return Config:GetSetting('UseJonthan') > 1 end, },
                { name = "FireDotSong",     cond = function(self) return Config:GetSetting('UseFireDots') end, },
                { name = "IceDotSong",      cond = function(self) return Config:GetSetting('UseIceDots') end, },
                { name = "PoisonDotSong",   cond = function(self) return Config:GetSetting('UsePoisonDots') end, },
                { name = "DiseaseDotSong",  cond = function(self) return Config:GetSetting('UseDiseaseDots') end, },
                -- filler
                { name = "CalmSong",        cond = function(self) return true end, }, -- condition not needed, for uniformity
            },
        },
    },
    ['PullAbilities']   = {
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
            Max = 1,
            FAQ = "What do the different Modes do?",
            Answer = "There are four modes: General, Tank Caster and Healer.\n" ..
                "General will prioritize your gems for general use and is the default.\n" ..
                "Tank will prioritize some gems to support a tank group.\n" ..
                "Caster will prioritize some gems to support a caster group.\n" ..
                "Healer will prioritize some gems to support healers.",
        },
        -- Buffs
        ['UseRunBuff']          = {
            DisplayName = "Use RunSpeed Buff",
            Category = "Buffs",
            Index = 1,
            Tooltip = "Use your run speed buff song or AA.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why am I slowing down in combat?",
            Answer = "Runspeed songs, if selected, are only sung in the downtime rotation. Higher level bards will have longer durations.",
        },
        ['UseEndBreath']        = {
            DisplayName = "Use Enduring Breath",
            Category = "Buffs",
            Index = 2,
            Tooltip = Tooltips.EndBreathSong,
            Default = false,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "How do I use my Enduring Breath song?",
            Answer = "You can enable Use Enduring Breath to use your Enduring Breath song when you are in water.",
        },
        ['UseAura']             = {
            DisplayName = "Use Aura",
            Category = "Buffs",
            Index = 3,
            Tooltip = "Use Bard Aura.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "My bard is spam casting aura, what do I do?",
            Answer = "We have code to prevent this, but if it has slipped the cracks, check what aura you have active in your window (Shift+A by default). You may need to clear it.",
        },
        ['UseAmp']              = {
            DisplayName = "Use Amp",
            Category = "Buffs",
            Index = 4,
            Tooltip = Tooltips.AmpSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "How do I use my Amplification song?",
            Answer = "You can enable the Use Amp option in Buffs and Defenses to use your Amplification song." ..
                "Options are (Never, In-Combat Only, Always, Out-of-Combat Only).",
        },
        ['SpireChoice']         = {
            DisplayName = "Spire Choice:",
            Category = "Buffs",
            Index = 5,
            Tooltip = "Choose which Fundament you would like to use during burns:\n" ..
                "First Spire: Spell Crit Buff to Self.\n" ..
                "Second Spire: Healing Power Buff to Self.\n" ..
                "Third Spire: Large Group HP Buff.",
            Type = "Combo",
            ComboOptions = Config.Constants.SpireChoices,
            Default = 3,
            Min = 1,
            Max = #Config.Constants.SpireChoices,
            FAQ = "Why am I using the wrong spire?",
            Answer = "You can choose which spire you prefer in the Class Options.",
        },
        ['DoVetAA']             = {
            DisplayName = "Use Vet AA",
            Category = "Buffs",
            Index = 6,
            Tooltip = "Use Veteran AA's in emergencies or during Burn",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "What Vet AA's does BRD use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },

        -- Debuffs
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
        ['DoResistDebuff']      = {
            DisplayName = "Use Resist Debuff",
            Category = "Debuffs",
            Index = 3,
            Tooltip = "Use the Harmony of Sound Resist Debuff.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my the Harmony of Sound resist debuff?",
            Answer = "You can enable this on the Debuff tab of the class options.",
        },
        ['DoDispel']            = {
            DisplayName = "Use Dispel",
            Category = "Debuffs",
            Index = 4,
            Tooltip = Tooltips.DispelSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Dispel song?",
            Answer = "You can enable Use Dispel to use your Dispel song when the target has beneficial effects.",
        },

        -- Defensive
        ['UseResist']           = {
            DisplayName = "Use Resist Buff",
            Category = "Defensive",
            Index = 1,
            Tooltip = Tooltips.ResistSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "How do I use my Resist Buff?",
            Answer = "You can enable the Resist Buff in the Buffs and Defenses tab." ..
                "Options are (Never, In-Combat Only, Always, Out-of-Combat Only).",
        },
        ['UseSpellAbsorb']      = {
            DisplayName = "Use Spell Absorb",
            Category = "Defensive",
            Index = 2,
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "When is the Spell Damage Absorb/Shield used?",
            Answer = "This song is used during burns.",
        },
        ['UseFading']           = {
            DisplayName = "Use Combat Escape",
            Category = "Defensive",
            Index = 3,
            Tooltip = "Use Fading Memories when you have aggro and you aren't the Main Assist.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why is my BRD regularly using Fading Memories",
            Answer = "When Use Combat Escape is enabled, Fading Memories will be used when the Bard has any unwanted aggro.\n" ..
                "This helps the common issue of bards gaining aggro from singing before a tank has the chance to secure it.",
        },
        ['DoCoating']           = {
            DisplayName = "Use Coating",
            Category = "Defensive",
            Index = 4,
            Tooltip = "Click your Blood Drinker's Coating in an emergency.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect available on Project Lazarus.",
        },
        ['EmergencyStart']      = {
            DisplayName = "Emergency HP%",
            Category = "Defensive",
            Index = 5,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my emergency abilities?",
            Answer = "You may not be below your Emergency HP % in the Utility tab.\n" ..
                "Try adjusting this to the minimum amount of HP you want to have before using these abilities.",
        },

        -- Healing
        ['RegenSong']           = {
            DisplayName = "Regen Song Choice:",
            Category = "Healing",
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
            Category = "Healing",
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
        ['GroupManaPct']        = {
            DisplayName = "Group Mana %",
            Category = "Healing",
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
            Category = "Healing",
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
        ['UseCure']             = {
            DisplayName = "Cure Ailments",
            Category = "Healing",
            Index = 5,
            Tooltip = Tooltips.CureSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Cure song?",
            Answer = "Select the Cure Ailments setting in the Mana tab to use your Cure song when the group has detrimental effects.",
        },
        ['BardRespectMedState'] = {
            DisplayName = "Respect Med Settings",
            Category = "Healing",
            Index = 6,
            Tooltip = "Allows the bard to meditate.\nPlease note that this comes at the cost of disabling all normal downtime actions while meditating.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why isn't my bard meditating?",
            Answer =
            "If your bard is medding, you can enable the Respect Med Settings setting on the Mana tab. Please note that the bard will not take any downtime actions while medding!",
        },

        -- Instruments
        ['SwapInstruments']     = {
            DisplayName = "Auto Swap Instruments",
            Index = 1,
            Category = "Instruments",
            Tooltip = "Auto swap instruments for songs",
            Default = false,
            FAQ = "Does RGMercs BRD support instrument swapping?",
            Answer = "Auto Swap Instruments can be enabled and configured on the Instruments tab.",

        },
        ['UseBandolier']        = {
            DisplayName = "Use Bandolier",
            Index = 2,
            Category = "Instruments",
            Tooltip = "Auto swap instruments using bandolier if avail, valid names (wind, drum, brass, string or main), if a bandolier is missing we will direct swap instead.",
            Default = true,
            FAQ = "Does RGMercs BRD support instrument swapping?",
            Answer = "Auto Swap Instruments via Bandolier if they exist otherwise default to direct swapping.",
        },
        ['Offhand']             = {
            DisplayName = "Offhand",
            Index = 3,
            Category = "Instruments",
            Tooltip = "Item to swap in when no instrument is available or needed.",
            Type = "ClickyItem",

            Default = "",
            FAQ = "How do I make sure we put back the correct item after using an instrument?",
            Answer = "Place your desired off-hand item on your cursor and select the proper text box on your Instrument tab.\n" ..
                "Also, make sure you have Auto Swap Instrument enabled.",
        },
        ['BrassInst']           = {
            DisplayName = "Brass Instrument",
            Index = 4,
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
            Index = 5,
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
            Index = 6,
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
            Index = 7,
            Category = "Instruments",
            Tooltip = "Stringed Instrument to Swap in as needed.",
            Type = "ClickyItem",
            Default = "",
            FAQ = "How do I use my Stringed Instrument?",
            Answer = "Place the correct instrument on your cursor and select the proper text box on your Instrument tab.\n" ..
                "Also, make sure you have Auto Swap Instrument enabled.",
        },

        -- Offensive
        ['UseAria']             = {
            DisplayName = "Use Aria",
            Category = "Offensive",
            Index = 1,
            Tooltip = Tooltips.AriaSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my Rizlona's spell damage song?",
            Answer = "Before the effects are combined, the default config prioritizes overhaste. Those supporting a caster group may wish to copy and customize this config.",
        },
        ['UseMarch']            = {
            DisplayName = "Use War March",
            Category = "Offensive",
            Index = 2,
            Tooltip = Tooltips.WarMarchSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "Why am I using the War March line? I have enchanter haste.",
            Answer = "The War March line of songs can be enabled or disabled on the Offesive tab in the class options.",
        },
        ['UseProcSong']         = {
            DisplayName = "Use Group Proc",
            Category = "Offensive",
            Index = 3,
            Tooltip = Tooltips.ProcSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "Why am I not singing my proc song?",
            Answer = "You can change the settings for which songs you will and won't sing in your class config options.",
        },
        ['UseArcane']           = {
            DisplayName = "Use Arcane Line",
            Category = "Offensive",
            Index = 4,
            Tooltip = Tooltips.ArcaneSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            FAQ = "Why am I using the Arcane line all the time? It isn't that great...",
            Answer = "You can change the settings for which songs you will and won't sing in your class config options.",
        },
        ['UseEpic']             = {
            DisplayName = "Epic Use:",
            Category = "Offensive",
            Index = 5,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            FAQ = "Why is my BRD using Epic on these trash mobs?",
            Answer = "By default, we use the Epic in any combat, as saving it for burns ends up being a DPS loss over a long frame of time outside of raids.\n" ..
                "This can be adjusted on the Offensive tab in the class options.",
        },
        ['UseFireDots']         = {
            DisplayName = "Use Fire Dots",
            Category = "Offensive",
            Index = 6,
            Tooltip = Tooltips.FireDotSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Fire Dot song?",
            Answer = "You can enable [UseFireDots] to use your Fire Dot song when you are in combat.",
        },
        ['UseIceDots']          = {
            DisplayName = "Use Ice Dots",
            Category = "Offensive",
            Index = 7,
            Tooltip = Tooltips.IceDotSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Ice Dot song?",
            Answer = "You can enable [UseIceDots] to use your Ice Dot song when you are in combat.",
        },
        ['UsePoisonDots']       = {
            DisplayName = "Use Poison Dots",
            Category = "Offensive",
            Index = 8,
            Tooltip = Tooltips.PoisonDotSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Poison Dot song?",
            Answer = "You can enable [UsePoisonDots] to use your Poison Dot song when you are in combat.",
        },
        ['UseDiseaseDots']      = {
            DisplayName = "Use Disease Dots",
            Category = "Offensive",
            Index = 9,
            Tooltip = Tooltips.DiseaseDotSong,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "How do I use my Disease Dot song?",
            Answer = "You can enable [UseDiseaseDots] to use your Disease Dot song when you are in combat.",

        },
        ['UseJonthan']          = {
            DisplayName = "Use Jonthan",
            Category = "Offensive",
            Index = 10,
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
        ['UseShout']            = {
            DisplayName = "Use Vain. Shout",
            Category = "Offensive",
            Index = 11,
            Tooltip = "Use Vainglorious Shout (Conal DD/Resist Debuff) ***WILL BREAK MEZ***",
            Default = false,
            FAQ = "Where are my AE checks for Vainglorious Shout?",
            Answer = "The use of Vainglorious Shout is simply covered by a toggle option at this time, there are no target counts, etc.",
        },

        -- Song Duration Adjustment
        ['RefreshDT']           = {
            DisplayName = "Downtime Threshold",
            Category = "Song Duration",
            Index = 1,
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
            Category = "Song Duration",
            Index = 2,
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
    },
}
return _ClassConfig
