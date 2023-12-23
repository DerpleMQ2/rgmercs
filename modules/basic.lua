-- Sample Basic Class Module
local mq            = require('mq')
local RGMercsLogger = require("rgmercs.utils.rgmercs_logger")
local RGMercUtils   = require("rgmercs.utils.rgmercs_utils")

local Module        = { _version = '0.1a', name = "Basic", author = 'Derple' }
Module.__index      = Module

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir .. '/rgmercs/PCConfigs/' .. 'basic_' .. server .. "_" .. RGMercConfig.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast then
        RGMercUtils.BroadcastUpdate(self.name, "SaveSettings")
    end
end

function Module:LoadSettings()
    RGMercsLogger.log("Basic Combat Module Loading Settings for: %s.", RGMercConfig.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Basic]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self.settings = {}
        self.settings.MyCheckbox = false
        self:SaveSettings(true)
    else
        self.settings = config()
    end
end

function Module.New()
    RGMercsLogger.log("Basic Combat Module Loaded.")
    local newModule = setmetatable({ settings = {} }, Module)

    newModule:LoadSettings()

    return newModule
end

function Module:Render()
    ImGui.Text("Basic Combat Modules")
    local pressed
    self.settings.MyCheckbox, pressed = ImGui.Checkbox("I am a Checkbox", self.settings.MyCheckbox)
    if pressed then
        self:SaveSettings()
    end
end

function Module:GiveTime()
    -- Main Module logic goes here.
end

function Module:Shutdown()
    RGMercsLogger.log("Basic Combat Module UnLoaded.")
end

return Module
