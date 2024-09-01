-- Sample Performance Monitor Class Module
local mq                  = require('mq')
local RGMercUtils         = require("utils.rgmercs_utils")
local ImPlot              = require('ImPlot')
local Set                 = require('mq.Set')
local ScrollingPlotBuffer = require('utils.scrolling_plot_buffer')

local Module              = { _version = '0.1a', _name = "Performance", _author = 'Derple', }
Module.__index            = Module
Module.settings           = {}
Module.DefaultConfig      = {}
Module.DefaultCategories  = {}
Module.MaxFrameStep       = 5.0
Module.GoalMaxFrameTime   = 0
Module.CurMaxMaxFrameTime = 0
Module.xAxes              = {}
Module.SettingsLoaded     = false
Module.FrameTimingData    = {}
Module.MaxFrameTime       = 0
Module.LastExtentsCheck   = os.clock()

Module.DefaultConfig      = {
    ['SecondsToStore']       = { DisplayName = "Seconds to Store", Category = "Monitoring", Tooltip = "The number of Seconds to keep in history.", Type = "Custom", Default = 30, Min = 10, Max = 120, Step = 5, },
    ['EnablePerfMonitoring'] = { DisplayName = "Enable Performance Monitoring", Category = "Monitoring", Tooltip = "Might cause some lag so only use if you want it", Default = false, },
    ['PlotFillLines']        = { DisplayName = "Enable Fill Lines", Category = "Graph", Tooltip = "Fill in the Plot Lines", Default = true, },
}

Module.DefaultCategories  = Set.new({})
for _, v in pairs(Module.DefaultConfig) do
    if v.Type ~= "Custom" then
        Module.DefaultCategories:add(v.Category)
    end
end

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast == true then
        RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    RGMercsLogger.log_debug("Performance Monitor Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Performance Monitor]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self:SaveSettings(false)
    else
        self.settings = config()
    end

    -- Setup Defaults
    self.settings = RGMercUtils.ResolveDefaults(self.DefaultConfig, self.settings)

    self.SettingsLoaded = true
end

function Module:GetSettings()
    return self.settings
end

function Module:GetDefaultSettings()
    return self.DefaultConfig
end

function Module:GetSettingCategories()
    return self.DefaultCategories
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    RGMercsLogger.log_debug("Performance Monitor Module Loaded.")
    self:LoadSettings()

    return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    ImGui.Text("Performance Monitor Modules")
    local pressed
    if not self.SettingsLoaded then return end

    if os.clock() - self.LastExtentsCheck > 0.01 then
        self.GoalMaxFrameTime = 0
        self.LastExtentsCheck = os.clock()
        for _, data in pairs(self.FrameTimingData) do
            for idx, time in ipairs(data.frameTimes.DataY) do
                -- is this entry visible?
                local visible = data.frameTimes.DataX[idx] > os.clock() - self.settings.SecondsToStore and
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
        ImPlot.SetupAxisLimits(ImAxis.X1, os.clock() - self.settings.SecondsToStore, os.clock(), ImGuiCond.Always)
        ImPlot.SetupAxisLimits(ImAxis.Y1, 1, self.CurMaxMaxFrameTime, ImGuiCond.Always)

        for _, module in pairs(RGMercModules:GetModuleOrderedNames()) do
            if self.FrameTimingData[module] and not self.FrameTimingData[module].mutexLock then
                local framData = self.FrameTimingData[module]

                if framData then
                    ImPlot.PlotLine(module, framData.frameTimes.DataX, framData.frameTimes.DataY,
                        #framData.frameTimes.DataX,
                        self.settings.PlotFillLines and ImPlotLineFlags.Shaded or ImPlotLineFlags.None,
                        framData.frameTimes.Offset - 1)
                end
            end
        end

        ImPlot.EndPlot()
    end

    if ImGui.CollapsingHeader("Config Options") then
        self.settings.SecondsToStore, pressed = ImGui.SliderInt(self.DefaultConfig.SecondsToStore.DisplayName,
            self.settings.SecondsToStore, self.DefaultConfig.SecondsToStore.Min,
            self.DefaultConfig.SecondsToStore
            .Max,
            "%d s")
        if pressed then
            self:SaveSettings(false)
        end

        self.settings, pressed, _ = RGMercUtils.RenderSettings(self.settings, self.DefaultConfig, self.DefaultCategories)
        if pressed then
            self:SaveSettings(false)
        end
    end
end

function Module:GiveTime(combat_state)
end

function Module:OnFrameExec(module, frameTime)
    if not self.settings.EnablePerfMonitoring then return end

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
    if not self.settings.EnablePerfMonitoring then return "Disabled" end

    return "Enabled"
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = {}, }
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
    RGMercsLogger.log_debug("Performance Monitor Module Unloaded.")
end

return Module
