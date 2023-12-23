local mq                    = require('mq')
local RGMercUtils           = require("rgmercs.utils.rgmercs_utils")
local RGMercsLogger         = require("rgmercs.utils.rgmercs_logger")

local Config                = { _version = '0.1a', author = 'Derple' }
Config.__index              = Config
Config.settings_pickle_path = mq.configDir .. '/rgmercs/' .. 'rgmercs.lua'
Config.settings             = {}
Config.CurLoadedChar        = mq.TLO.Me.CleanName()
Config.CurLoadedClass       = mq.TLO.Me.Class.ShortName()

function Config:SaveSettings(doBroadcast)
    mq.pickle(self.settings_pickle_path, self.settings)

    if doBroadcast then
        RGMercUtils.BroadcastUpdate("main", "SaveSettings")
    end
end

function Config:LoadSettings()
    Config.CurLoadedChar  = mq.TLO.Me.CleanName()
    Config.CurLoadedClass = mq.TLO.Me.Class.ShortName()

    RGMercsLogger.log("\ayLoading Main Settings for %s!", self.CurLoadedChar)

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
        self.settings[self.CurLoadedChar].BgOpacity = 1.0
        self:SaveSettings(true)
    end

    return true
end

function Config:getSettings()
    return self.settings[self.CurLoadedChar]
end

function Config:settingsLoaded()
    return self.settings and self.settings[self.CurLoadedChar]
end

return Config
