local mq                      = require('mq')
local RGMercUtils             = require("rgmercs.utils.rgmercs_utils")
local RGMercsLogger           = require("rgmercs.utils.rgmercs_logger")
local Set                     = require("mq.Set")

local Config                  = { _version = '0.1a', _subVersion = "2023 Larions Song!", _name = "RGMercs Lua Edition", _author = 'Derple, Morisato, Gortar' }
Config.__index                = Config
Config.settings               = {}

-- Global State
Config.Globals                = {}
Config.Globals.MainAssist     = ""
Config.Globals.AutoTargetID   = 0
Config.Globals.BurnNow        = false
Config.Globals.PauseMain      = false
Config.Globals.LastMove       = nil
Config.Globals.BackOffFlag    = false
Config.Globals.IsHealing      = false
Config.Globals.IsTanking      = false
Config.Globals.InMedState     = false
Config.Globals.IsMezzing      = false
Config.Globals.CurLoadedChar  = mq.TLO.Me.CleanName()
Config.Globals.CurLoadedClass = mq.TLO.Me.Class.ShortName()
Config.Globals.CurServer      = mq.TLO.EverQuest.Server():gsub(" ", "")

-- Constants
Config.Constants              = {}
Config.Constants.RGCasters    = Set.new({ "BRD", "BST", "CLR", "DRU", "ENC", "MAG", "NEC", "PAL", "RNG", "SHD", "SHM", "WIZ" })
Config.Constants.RGMelee      = Set.new({ "BRD", "SHD", "PAL", "WAR", "ROG", "BER", "MNK", "RNG", "BST" })
Config.Constants.RGHybrid     = Set.new({ "SHD", "PAL", "RNG", "BST", "BRD" })
Config.Constants.RGTank       = Set.new({ "WAR", "PAL", "SHD" })
Config.Constants.RGModRod     = Set.new({ "BST", "CLR", "DRU", "SHM", "MAG", "ENC", "WIZ", "NEC", "PAL", "RNG", "SHD" })
Config.Constants.RGPetClass   = Set.new({ "BST", "NEC", "MAG", "SHM", "ENC", "SHD" })
Config.Constants.RGMezAnims   = Set.new({ 1, 5, 6, 27, 43, 44, 45, 80, 82, 112, 134, 135 })
Config.Constants.ModRods      = { [1] = "Modulation Shard", [2] = "Transvergence", [3] = "Modulation", [4] = "Modulating" }

Config.ExpansionNameToID      = {
    ['EXPANSION_LEVEL_CLASSIC'] = 0, -- No Expansion
    ['EXPANSION_LEVEL_ROK'] = 1,     -- The Ruins of Kunark
    ['EXPANSION_LEVEL_SOV'] = 2,     -- The Scars of Velious
    ['EXPANSION_LEVEL_SOL'] = 3,     -- The Shadows of Luclin
    ['EXPANSION_LEVEL_POP'] = 4,     -- The Planes of Power
    ['EXPANSION_LEVEL_LOY'] = 5,     -- The Legacy of Ykesha
    ['EXPANSION_LEVEL_LDON'] = 6,    -- Lost Dungeons of Norrath
    ['EXPANSION_LEVEL_GOD'] = 7,     -- Gates of Discord
    ['EXPANSION_LEVEL_OOW'] = 8,     -- Omens of War
    ['EXPANSION_LEVEL_DON'] = 9,     -- Dragons of Norrath
    ['EXPANSION_LEVEL_DODH'] = 10,   -- Depths of Darkhollow
    ['EXPANSION_LEVEL_POR'] = 11,    -- Prophecy of Ro
    ['EXPANSION_LEVEL_TSS'] = 12,    -- The Serpent's Spine
    ['EXPANSION_LEVEL_TBS'] = 13,    -- The Buried Sea
    ['EXPANSION_LEVEL_SOF'] = 14,    -- Secrets of Faydwer
    ['EXPANSION_LEVEL_SOD'] = 15,    -- Seeds of Destruction
    ['EXPANSION_LEVEL_UF'] = 16,     -- Underfoot
    ['EXPANSION_LEVEL_HOT'] = 17,    -- House of Thule
    ['EXPANSION_LEVEL_VOA'] = 18,    -- Veil of Alaris
    ['EXPANSION_LEVEL_ROF'] = 19,    -- Rain of Fear
    ['EXPANSION_LEVEL_COTF'] = 20,   -- Call of the Forsaken
    ['EXPANSION_LEVEL_TDS'] = 21,    -- The Darkened Sea
    ['EXPANSION_LEVEL_TBM'] = 22,    -- The Broken Mirror
    ['EXPANSION_LEVEL_EOK'] = 23,    -- Empires of Kunark
    ['EXPANSION_LEVEL_ROS'] = 24,    -- Ring of Scale
    ['EXPANSION_LEVEL_TBL'] = 25,    -- The Burning Lands
    ['EXPANSION_LEVEL_TOV'] = 26,    -- Torment of Velious
    ['EXPANSION_LEVEL_COV'] = 27,    -- Claws of Veeshan
    ['EXPANSION_LEVEL_TOL'] = 28,    -- Terror of Luclin
    ['EXPANSION_LEVEL_NOS'] = 29,    -- Night of Shadows
    ['EXPANSION_LEVEL_LS'] = 30,     -- Laurion's Song
}

-- Defaults
Config.DefaultConfig          = {
    ['DoAutoTarget']      = { DisplayName = "Auto Target", Tooltip = "Automatically change targets.", Default = true },
    ['DoMercenary']       = { DisplayName = "Use Mercenary", Tooltip = "Use Merc during combat.", Default = true },
    ['PriorityHealing']   = { DisplayName = "Priority Healing", Tooltip = "Prioritize Healing over Combat", Default = false },
    ['DoModRod']          = { DisplayName = "Do Mod Rod", Tooltip = "Auto use Mod Rods if we have them", Default = true },
    ['ModRodManaPct']     = { DisplayName = "Mod Rod Mana Pct", Tooltip = "What Mana Pct to hit before using a rod.", Default = 30, Min = 1, Max = 99 },
    ['DoMed']             = { DisplayName = "Do Meditate", Tooltip = "0 = No Auto Med, 1 = Auto Med Out of Combat, 2 = Auto Med In Combat", Default = 1, Min = 0, Max = 2 },
    ['HPMedPct']          = { DisplayName = "Med HP Pct", Tooltip = "What HP Pct to hit before medding.", Default = 60, Min = 1, Max = 99 },
    ['ManaMedPct']        = { DisplayName = "Med Mana Pct", Tooltip = "What Mana Pct to hit before medding.", Default = 30, Min = 1, Max = 99 },
    ['EndMedPct']         = { DisplayName = "Med Endurance Pct", Tooltip = "What Endurance Pct to hit before medding.", Default = 30, Min = 1, Max = 99 },
    ['ManaMedPctStop']    = { DisplayName = "Med Mana Pct Stop", Tooltip = "What Mana Pct to hit before stopping medding.", Default = 90, Min = 1, Max = 99 },
    ['EndMedPctStop']     = { DisplayName = "Med Endurance Pct Stop", Tooltip = "What Endurance Pct to hit before stopping medding.", Default = 90, Min = 1, Max = 99 },
    ['HPMedPctStop']      = { DisplayName = "Med HP Pct Stop", Tooltip = "What HP Pct to hit before stopping medding.", Default = 90, Min = 1, Max = 99 },
    ['StayOnTarget']      = { DisplayName = "Stay On Target", Tooltip = "Stick to your target. Default: true; Tank Mode Defaults: false. false allows intelligent target swapping based on aggro/named/ etc.", Default = (not Config.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName())) },
    ['DoAutoEngage']      = { DisplayName = "Auto Engage", Tooltip = "Automatically engage targets.", Default = true },
    ['DoMelee']           = { DisplayName = "Enable Melee Combat", Tooltip = "Melee targets.", Default = false },
    ['DoBuffs']           = { DisplayName = "Do Buffs", Tooltip = "Do Non-Class Specific Buffs.", Default = true },
    ['SafeTargeting']     = { DisplayName = "Use Safe Targeting", Tooltip = "Do not target mobs that are fighting others.", Default = true },
    ['DoTanking']         = { DisplayName = "Enable Tank Mode", Tooltip = "I am a tank!", Default = Config.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName()) },
    ['DoTwist']           = { DisplayName = "Enable Bard Twisting", Tooltip = "Use MQ2Twist", Default = true },
    ['DoFellow']          = { DisplayName = "Enable Fellowship Insignia", Tooltip = "Use fellowship insignia automatically.", Default = true },
    ['AssistOutside']     = { DisplayName = "Assist Outside of Group", Tooltip = "Allow assisting characters outside of your group.", Default = false },
    ['AssistRange']       = { DisplayName = "Assist Range", Tooltip = "Distance to the target before you engage.", Default = 45, Min = 15, Max = 200 },
    ['MAScanZRange']      = { DisplayName = "Main Assist Scan ZRange", Tooltip = "Distance in Z direction to look for targets.", Default = 45, Min = 15, Max = 200 },
    ['AutoAssistAt']      = { DisplayName = "Auto Assist At", Tooltip = "Melee attack when target hits [x] HP %.", Default = 98, Min = 1, Max = 100 },
    ['StickHow']          = { DisplayName = "Stick How", Tooltip = "Custom /stick command", Type = "Custom", Default = "" },
    ['AllowMezBreak']     = { DisplayName = "Allow Mez Break", Tooltip = "Allow Mez Breaking.", Default = false },
    ['InstantRelease']    = { DisplayName = "Instant Release", Tooltip = "Instantly release when you die.", Default = false },
    ['FollowMarkTarget']  = { DisplayName = "Follow Mark Target", Tooltip = "Auto target MA target Marks.", Default = false },
    ['LogLevel']          = { DisplayName = "Log Level", Tooltip = "0 = Errors, 1 = Warnings, 2 = Info, 3 = Debug, 4 = Verbose", Default = 2, Min = 0, Max = 4 },
    ['OutsideAssistList'] = { DisplayName = "List of Outsiders to Assist", Tooltip = "List of Outsiders to Assist", Type = "Custom", Default = {} },
    ['BgOpacity']         = { DisplayName = "Background Opacity", Tooltip = "Opacity for the RGMercs UI", Type = "Custom", Default = 1.0 },
}

function Config:GetConfigFileName()
    return mq.configDir ..
        '/rgmercs/PCConfigs/RGMerc_' .. self.Globals.CurServer .. "_" .. self.Globals.CurLoadedChar .. '.lua'
end

function Config:SaveSettings(doBroadcast)
    mq.pickle(self:GetConfigFileName(), self.settings)

    RGMercsLogger.set_log_level(self.settings.LogLevel)

    if doBroadcast then
        RGMercUtils.BroadcastUpdate("main", "SaveSettings")
    end
end

function Config:LoadSettings()
    self.Globals.CurLoadedChar  = mq.TLO.Me.CleanName()
    self.Globals.CurLoadedClass = mq.TLO.Me.Class.ShortName()
    self.Globals.CurServer      = mq.TLO.EverQuest.Server():gsub(" ", "")

    RGMercsLogger.log_info("\ayLoading Main Settings for %s!", self.Globals.CurLoadedChar)

    local needSave = false

    local config, err = loadfile(self:GetConfigFileName())
    if err or not config then
        RGMercsLogger.log_error("\ayUnable to load global settings file(%s), creating a new one!",
            self:GetConfigFileName())
        self.settings = {}
        needSave = true
    else
        self.settings = config()
    end

    -- Setup Defaults
    for k, v in pairs(Config.DefaultConfig) do
        self.settings[k] = self.settings[k] or v.Default
    end

    if needSave then
        self:SaveSettings(true)
    end

    return true
end

function Config:GetAssistId()
    return mq.TLO.Spawn(string.format("PC =%s", self.Globals.MainAssist)).ID() or 0
end

function Config:GetAssistSpawn()
    return mq.TLO.Spawn(string.format("PC =%s", self.Globals.MainAssist))
end

function Config:SetSettings(newSettings)
    self.settings = newSettings
end

function Config:GetSettings()
    return self.settings
end

function Config:SettingsLoaded()
    return self.settings ~= nil
end

function Config:StoreLastMove()
    local me = mq.TLO.Me

    if not self.Globals.LastMove or
        math.abs(self.Globals.LastMove.X - me.X()) > 1 or
        math.abs(self.Globals.LastMove.Y - me.Y()) > 1 or
        math.abs(self.Globals.LastMove.Z - me.Z()) > 1 or
        math.abs(self.Globals.LastMove.Heading - me.Heading.Degrees()) > 1 or
        me.Combat() or
        me.CombatState():lower() == "combat" or
        me.Sitting() ~= self.Globals.LastMove.Sitting then
        self.Globals.LastMove = self.Globals.LastMove or {}
        self.Globals.LastMove.X = me.X()
        self.Globals.LastMove.Y = me.Y()
        self.Globals.LastMove.Z = me.Z()
        self.Globals.LastMove.Heading = me.Heading.Degrees()
        self.Globals.LastMove.Sitting = me.Sitting()
        self.Globals.LastMove.TimeSinceMove = 0
    else
        self.Globals.LastMove.TimeSinceMove = (mq.TLO.EverQuest.Running() - self.Globals.LastMove.TimeSinceMove) / 1000
    end
end

return Config
