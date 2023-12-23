-- Sample Basic Class Module
local mq             = require('mq')
local RGMercsLogger  = require("rgmercs.utils.rgmercs_logger")
local RGMercUtils    = require("rgmercs.utils.rgmercs_utils")
local shdClassConfig = require("rgmercs.class_configs.shd_class_config")
local Module         = { _version = '0.1a', name = "ShadowKnight", author = 'Derple' }
Module.__index       = Module

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module.name .. "_" .. server .. "_" .. RGMercConfig.CurLoadedChar .. '.lua'
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
        self.settings = shdClassConfig.DefaultConfig
        self:SaveSettings(true)
    else
        self.settings = config()
    end
end

function Module.New()
    -- Only load this module for SKs
    if RGMercConfig.CurLoadedClass ~= "SHD" then return nil end

    RGMercsLogger.log("ShadowKnight Combat Module Loaded.")
    local newModule = setmetatable({ settings = {}, CombatState = "None" }, Module)

    newModule:LoadSettings()

    return newModule
end

local function renderSetting(k, v)
    if type(v) == "table" then
        ImGui.Text(k)
        ImGui.Indent()
        for ki, kv in pairs(v) do
            renderSetting(ki, kv)
        end
        ImGui.Unindent()
    else
        ImGui.Text("%s => %s", k, v)
    end
end

function Module:Render()
    ImGui.Text("ShadowKnight Combat Modules")

    if ImGui.CollapsingHeader("Current Settings") then
        for k, v in pairs(self.settings) do
            renderSetting(k, v)
        end
    end

    ImGui.Text(string.format("Combat State: %s", self.CombatState))
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
    self.CombatState = combat_state
end

function Module:Shutdown()
    RGMercsLogger.log("ShadowKnight Combat Module UnLoaded.")
end

return Module
