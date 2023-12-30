local mq                    = require('mq')
local RGMercUtils           = require("rgmercs.utils.rgmercs_utils")
local RGMercsLogger         = require("rgmercs.utils.rgmercs_logger")
local Set                   = require("mq.Set")

local Config                = { _version = '0.1a', author = 'Derple' }
Config.__index              = Config
Config.settings_pickle_path = mq.configDir .. '/rgmercs/' .. 'rgmercs.lua'
Config.settings             = {}
Config.CurLoadedChar        = mq.TLO.Me.CleanName()
Config.CurLoadedClass       = mq.TLO.Me.Class.ShortName()
Config.CurServer            = mq.TLO.EverQuest.Server():gsub(" ", "")

-- Constants
Config.RGCasters            = Set.new({ "BRD", "BST", "CLR", "DRU", "ENC", "MAG", "NEC", "PAL", "RNG", "SHD", "SHM", "WIZ" })
Config.RGMelee              = Set.new({ "BRD", "SHD", "PAL", "WAR", "ROG", "BER", "MNK", "RNG", "BST" })
Config.RGHybrid             = Set.new({ "SHD", "PAL", "RNG", "BST", "BRD" })
Config.RGTank               = Set.new({ "WAR", "PAL", "SHD" })
Config.RGModRod             = Set.new({ "BST", "CLR", "DRU", "SHM", "MAG", "ENC", "WIZ", "NEC", "PAL", "RNG", "SHD" })
Config.RGPetClass           = Set.new({ "BST", "NEC", "MAG", "SHM", "ENC", "SHD" })

-- Defaults
Config.DefaultConfig        = {
    ['DoAutoEngage']  = { DisplayName = "Auto Engage", Tooltip = "Automatically engage targets.", Default = true },
    ['DoMelee']       = { DisplayName = "Enable Melee Combat", Tooltip = "Melee targets.", Default = true },
    ['AssistRange']   = { DisplayName = "Assist Range", Tooltip = "Distance to the target before you engage.", Default = 45, Min = 15, Max = 200 },
    ['AutoAssistAt']  = { DisplayName = "Auto Assist At", Tooltip = "Melee attack when target hits [x] HP %.", Default = 98, Min = 1, Max = 100 },
    ['StickHow']      = { DisplayName = "Stick How", Tooltip = "Custom /stick command", Type = "Custom", Default = "" },
    ['AllowMezBreak'] = { DisplayName = "Allow Mez Break", Tooltip = "Allow Mez Breaking.", Default = false },
    ['BgOpacity']     = { DisplayName = "Background Opacity", Tooltip = "Opacity for the RGMercs UI", Type = "Custom", Default = 1.0 },
}

function Config:SaveSettings(doBroadcast)
    mq.pickle(self.settings_pickle_path, self.settings)

    if doBroadcast then
        RGMercUtils.BroadcastUpdate("main", "SaveSettings")
    end
end

function Config:LoadSettings()
    Config.CurLoadedChar  = mq.TLO.Me.CleanName()
    Config.CurLoadedClass = mq.TLO.Me.Class.ShortName()
    Config.CurServer      = mq.TLO.EverQuest.Server():gsub(" ", "")

    RGMercsLogger.log_info("\ayLoading Main Settings for %s!", self.CurLoadedChar)

    local config, err = loadfile(self.settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ayUnable to load global settings file(%s), creating a new one!",
            self.settings_pickle_path)
        self.settings = {}

        self:SaveSettings(true)
    else
        self.settings = config()
    end

    self.settings = self.settings or {}

    if not self.settings[self.CurLoadedChar] then
        self.settings[self.CurLoadedChar] = self.settings[self.CurLoadedChar] or {}
        self:SaveSettings(true)
    end

    -- Setup Defaults
    for k, v in pairs(Config.DefaultConfig) do
        self.settings[self.CurLoadedChar][k] = self.settings[self.CurLoadedChar][k] or v.Default
    end

    return true
end

function Config:setSettings(newSettings)
    self.settings[self.CurLoadedChar] = newSettings
end

function Config:getSettings()
    return self.settings[self.CurLoadedChar]
end

function Config:settingsLoaded()
    return self.settings and self.settings[self.CurLoadedChar]
end

return Config
