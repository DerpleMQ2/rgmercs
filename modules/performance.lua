-- Sample Performance Monitor Class Module
local mq                  = require('mq')
local RGMercsLogger       = require("utils.rgmercs_logger")
local RGMercUtils         = require("utils.rgmercs_utils")
local ImPlot              = require('ImPlot')
local Set                 = require('mq.Set')

local Module              = { _version = '0.1a', _name = "Performance", _author = 'Derple', }
Module.__index            = Module
Module.settings           = {}
Module.DefaultConfig      = {}
Module.DefaultCategories  = {}
Module.MaxFrame           = 50
Module.MaxFrameStep       = 5.0
Module.GoalMaxFrameTime   = 0
Module.CurMaxMaxFrameTime = 0
Module.xAxes              = {}
Module.SettingsLoaded     = false
Module.FrameTimes         = {}
Module.MaxFrameTime       = 0
Module.LastExtentsCheck   = os.clock()

Module.DefaultConfig      = {
    ['FramesToStore']        = { DisplayName = "Frame Storage #", Category = "Monitoring", Tooltip = "The number of frametimes to keep in history.", Default = 100, Min = 10, Max = 500, Step = 5, },
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

    self.SettingsLoaded = true
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

    if not self.SettingsLoaded then return end

    if os.clock() - self.LastExtentsCheck > 0.01 then
        self.GoalMaxFrameTime = 0
        self.LastExtentsCheck = os.clock()
        for _, times in pairs(self.FrameTimes) do
            for _, t in ipairs(times.frameTimes) do
                if t > self.GoalMaxFrameTime then
                    self.GoalMaxFrameTime = math.ceil(t / self.MaxFrameStep) * self.MaxFrameStep
                end
            end
        end
    end

    -- converge on new max recalc min and maxes
    if self.CurMaxMaxFrameTime < self.GoalMaxFrameTime then self.CurMaxMaxFrameTime = self.CurMaxMaxFrameTime + 1 end
    if self.CurMaxMaxFrameTime > self.GoalMaxFrameTime then self.CurMaxMaxFrameTime = self.CurMaxMaxFrameTime - 1 end

    if self.settings.FramesToStore ~= #self.xAxes then
        self.xAxes = {}
        for i = 1, self.settings.FramesToStore do table.insert(self.xAxes, i) end
    end

    if ImPlot.BeginPlot("Frame Times for RGMercs Modules") then
        ImPlot.SetupAxes("Frame #", "Frame Time (ms)")
        ImPlot.SetupAxesLimits(1, self.settings.FramesToStore, 0, self.CurMaxMaxFrameTime, ImPlotCond.Always)

        for _, module in pairs(RGMercModules:GetModuleOrderedNames()) do
            if self.FrameTimes[module] and not self.FrameTimes[module].mutexLock then
                local frameTimes = self.FrameTimes[module].frameTimes or {}
                ImPlot.PlotLine(module, self.xAxes, frameTimes, #frameTimes, self.settings.PlotFillLines and ImPlotLineFlags.Shaded or ImPlotLineFlags.None)
            end
        end

        ImPlot.EndPlot()
    end

    if ImGui.CollapsingHeader("Config Options") then
        self.settings, pressed, _ = RGMercUtils.RenderSettings(self.settings, self.DefaultConfig, self.DefaultCategories)
        if pressed then
            self:SaveSettings(true)
        end
    end
end

function Module:GiveTime(combat_state)
end

function Module:OnFrameExec(module, frameTime)
    if not self.settings.EnablePerfMonitoring then return end

    if not self.FrameTimes[module] then self.FrameTimes[module] = { mutexLock = false, frameTimes = {}, } end

    table.insert(self.FrameTimes[module].frameTimes, frameTime)

    if frameTime > self.MaxFrameTime then self.MaxFrameTime = frameTime end

    local totalFramesStore = #self.FrameTimes[module].frameTimes

    if totalFramesStore > self.settings.FramesToStore then
        -- let's clean up some memory
        local oldTimes = self.FrameTimes[module].frameTimes
        local startPoint = (#oldTimes - self.settings.FramesToStore) + 1
        self.FrameTimes[module].mutexLock = true
        self.FrameTimes[module].frameTimes = {}
        for i = startPoint, (#oldTimes) do
            self.FrameTimes[module].frameTimes[(i - startPoint) + 1] = oldTimes[i]
        end
        self.FrameTimes[module].mutexLock = false
    end
end

function Module:OnDeath()
    -- Death Handler
end

function Module:OnZone()
    -- Zone Handler
end

function Module:DoGetState()
    if not self.settings.EnablePerfMonitoring then return "Disabled" end

    return "Enabled"
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
