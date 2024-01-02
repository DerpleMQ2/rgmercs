-- Sample Basic Class Module
local mq            = require('mq')
local RGMercsLogger = require("utils.rgmercs_logger")
local RGMercUtils   = require("utils.rgmercs_utils")

local Module        = { _version = '0.1a', name = "Basic", author = 'Derple', }
Module.__index      = Module

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module.name .. "_" .. server .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast then
        RGMercUtils.BroadcastUpdate(self.name, "LoadSettings")
    end
end

function Module:LoadSettings()
    RGMercsLogger.log_info("Basic Combat Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
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
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    RGMercsLogger.log_info("Basic Combat Module Loaded.")
    self:LoadSettings()
end

function Module:Render()
    ImGui.Text("Basic Combat Modules")
    local pressed
    self.settings.MyCheckbox, pressed = ImGui.Checkbox("I am a Checkbox", self.settings.MyCheckbox)
    if pressed then
        self:SaveSettings()
    end
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
end

function Module:OnDeath()
    -- Death Handler
end

function Module:Shutdown()
    RGMercsLogger.log_info("Basic Combat Module UnLoaded.")
end

return Module
