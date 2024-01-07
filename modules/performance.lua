-- Sample Performance Monitor Class Module
local mq                 = require('mq')
local RGMercsLogger      = require("utils.rgmercs_logger")
local RGMercUtils        = require("utils.rgmercs_utils")
local ImPlot             = require('ImPlot')

local Module             = { _version = '0.1a', _name = "Performance", _author = 'Derple', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultConfig     = {}
Module.DefaultCategories = {}

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast then
        RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    RGMercsLogger.log_info("Performance Monitor Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Performance Monitor]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self.settings.MyCheckbox = false
        self:SaveSettings(true)
    else
        self.settings = config()
    end

    -- Setup Defaults
    self.settings = RGMercUtils.ResolveDefaults(self.DefaultConfig, self.settings)
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    RGMercsLogger.log_info("Performance Monitor Module Loaded.")
    self:LoadSettings()

    return { settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:Render()
    ImGui.Text("Performance Monitor Modules")
    local pressed

    if ImPlot.BeginPlot("Frame Times for RGMercs Modules") then
        ImPlot.SetupAxes("FrameNum", "FrameSeconds")
        ImPlot.SetupAxesLimits(1, RGMercModules.FramesToStore, 0, 50, ImPlotCond.Always)
        local xAxis = {}

        for module, times in pairs(RGMercModules.FrameTimes) do
            if #xAxis == 0 then
                for i, _ in ipairs(times or { 1, }) do table.insert(xAxis, i) end
            end

            if times then
                ImPlot.PlotLine(module, xAxis, times, #times)
            end
        end

        ImPlot.EndPlot()
    end
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
end

function Module:OnDeath()
    -- Death Handler
end

function Module:OnZone()
    -- Zone Handler
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    local ret = ""

    for module, times in pairs(RGMercModules.FrameTimes) do
        ret = ret .. string.format("<%s>\n", module)
        for i, v in ipairs(times) do
            ret = ret .. string.format("[%d] :: %d\n", i, v)
        end
        ret = ret .. string.format("\n", module)
    end
    return ret
end

---@param cmd string
---@param ... string
---@return boolean
function Module:HandleBind(cmd, ...)
    local params = ...
    local handled = false
    -- /rglua cmd handler
    return handled
end

function Module:Shutdown()
    RGMercsLogger.log_info("Performance Monitor Module Unloaded.")
end

return Module
