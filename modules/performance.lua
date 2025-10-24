-- Sample Performance Monitor Class Module
local mq                  = require('mq')
local Config              = require('utils.config')
local Ui                  = require("utils.ui")
local Comms               = require("utils.comms")
local Modules             = require("utils.modules")
local Logger              = require("utils.logger")
local Strings             = require("utils.strings")
local ImPlot              = require('ImPlot')
local Set                 = require('mq.Set')
local ScrollingPlotBuffer = require('utils.scrolling_plot_buffer')

local Module              = { _version = '0.1a', _name = "Perf", _author = 'Derple', }
Module.__index            = Module
Module.DefaultConfig      = {}
Module.MaxFrameStep       = 5.0
Module.GoalMaxFrameTime   = 0
Module.CurMaxMaxFrameTime = 0
Module.xAxes              = {}
Module.SettingsLoaded     = false
Module.FrameTimingData    = {}
Module.MaxFrameTime       = 0
Module.LastExtentsCheck   = os.clock()
Module.FAQ                = {}
Module.SaveRequested      = nil

Module.DefaultConfig      = {
    ['SecondsToStore']                         = {
        DisplayName = "Seconds to Store",
        Group = "General",
        Header = "Misc",
        Category = "Misc",
        Tooltip = "The number of Seconds to keep in history.",
        Default = 30,
        Min = 10,
        Max = 120,
        Step = 5,
    },
    ['EnablePerfMonitoring']                   = {
        DisplayName = "Enable Performance Monitoring",
        Group       = "General",
        Header      = "Misc",
        Category    = "Misc",
        Tooltip     = "Enable the Performance Module for advanced testing.",
        Default     = false,
    },
    ['PlotFillLines']                          = {
        DisplayName = "Enable Fill Lines",
        Group = "General",
        Header = "Misc",
        Category = "Misc",
        Tooltip = "Fill in the Plot Lines",
        Default = true,
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Default = false,
    },
}

local function getConfigFileName()
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. Config.Globals.CurServerNormalized .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    self.SaveRequested = { time = os.time(), broadcast = doBroadcast or false, }
end

function Module:WriteSettings()
    if not self.SaveRequested then return end

    mq.pickle(getConfigFileName(), Config:GetModuleSettings(self._name))

    if self.SaveRequested.doBroadcast == true then
        Comms.BroadcastMessage(self._name, "LoadSettings")
    end

    Logger.log_debug("\ag%s Module settings saved to %s, requested %s ago.", self._name, getConfigFileName(), Strings.FormatTime(os.time() - self.SaveRequested.time))

    self.SaveRequested = nil
end

function Module:LoadSettings()
    Logger.log_debug("Performance Monitor Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()
    local settings = {}
    local firstSaveRequired = false

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Performance Monitor]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        firstSaveRequired = true
    else
        settings = config()
    end

    Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)

    self.SettingsLoaded = true
end

function Module.New()
    local newModule = setmetatable({}, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Performance Monitor Module Loaded.")
    self:LoadSettings()

    return { self = self, defaults = self.DefaultConfig, }
end

function Module:ShouldRender()
    return Config:GetSetting('EnablePerfMonitoring')
end

function Module:Render()
    Ui.RenderPopAndSettings(self._name)

    local pressed
    if not self.SettingsLoaded then return end

    if os.clock() - self.LastExtentsCheck > 0.01 then
        self.GoalMaxFrameTime = 0
        self.LastExtentsCheck = os.clock()
        for _, data in pairs(self.FrameTimingData) do
            for idx, time in ipairs(data.frameTimes.DataY) do
                -- is this entry visible?
                local visible = data.frameTimes.DataX[idx] > os.clock() - Config:GetSetting('SecondsToStore') and
                    data.frameTimes.DataX[idx] < os.clock()
                if visible and time > self.GoalMaxFrameTime then
                    self.GoalMaxFrameTime = math.ceil(time / self.MaxFrameStep) * self.MaxFrameStep
                end
            end
        end
    end

    -- converge on new max recalc min and maxes
    if self.CurMaxMaxFrameTime < self.GoalMaxFrameTime then self.CurMaxMaxFrameTime = self.CurMaxMaxFrameTime + 1 end
    if self.CurMaxMaxFrameTime > self.GoalMaxFrameTime then self.CurMaxMaxFrameTime = self.CurMaxMaxFrameTime - 1 end

    if ImPlot.BeginPlot("Frame Times for RGMercs Modules") then
        ImPlot.SetupAxes("Time (s)", "Frame Time (ms)")
        ImPlot.SetupAxisLimits(ImAxis.X1, os.clock() - Config:GetSetting('SecondsToStore'), os.clock(), ImGuiCond.Always)
        ImPlot.SetupAxisLimits(ImAxis.Y1, 1, self.CurMaxMaxFrameTime, ImGuiCond.Always)

        for _, module in pairs(Modules:GetModuleOrderedNames()) do
            if self.FrameTimingData[module] and not self.FrameTimingData[module].mutexLock then
                local framData = self.FrameTimingData[module]

                if framData then
                    ImPlot.PlotLine(module, framData.frameTimes.DataX, framData.frameTimes.DataY,
                        #framData.frameTimes.DataX,
                        Config:GetSetting('PlotFillLines') and ImPlotLineFlags.Shaded or ImPlotLineFlags.None,
                        framData.frameTimes.Offset - 1)
                end
            end
        end

        ImPlot.EndPlot()
    end
end

function Module:Pop()
    Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Module:GiveTime(combat_state)
end

function Module:OnFrameExec(module, frameTime)
    if not Config:GetSetting('EnablePerfMonitoring') then return end

    if not self.FrameTimingData[module] then
        self.FrameTimingData[module] = {
            mutexLock = false,
            lastFrame = os.clock(),
            frameTimes =
                ScrollingPlotBuffer:new(),
        }
    end

    self.FrameTimingData[module].lastFrame = os.clock()
    self.FrameTimingData[module].frameTimes:AddPoint(os.clock(), frameTime)
end

function Module:OnDeath()
    -- Death Handler
end

function Module:OnZone()
    -- Zone Handler
end

function Module:OnCombatModeChanged()
end

function Module:DoGetState()
    if not Config:GetSetting('EnablePerfMonitoring') then return "Disabled" end

    return "Enabled"
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = {}, }
end

function Module:GetFAQ()
    return { module = self._name, FAQ = self.FAQ or {}, }
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
    Logger.log_debug("Performance Monitor Module Unloaded.")
end

return Module
