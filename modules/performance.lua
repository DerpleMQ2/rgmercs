-- Sample Performance Monitor Class Module
local mq                 = require('mq')
local RGMercsLogger      = require("utils.rgmercs_logger")
local RGMercUtils        = require("utils.rgmercs_utils")
local ImPlot             = require('ImPlot')
local Set                = require('mq.Set')

local Module             = { _version = '0.1a', _name = "Performance", _author = 'Derple', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultConfig     = {}
Module.DefaultCategories = {}
Module.MaxFrame          = 50
Module.MaxFrameStep      = 5.0
Module.GoalMax           = 0
Module.xAxes             = {}
Module.SettingsLoaded    = false
Module.LastExtentsCheck  = os.clock()

Module.DefaultConfig     = {
    ['FramesToStore'] = { DisplayName = "Frame Storage #", Category = "Monitoring", Tooltip = "The number of frametimes to keep in history.", Default = 100, Min = 10, Max = 500, Step = 5, },
}

Module.DefaultCategories = Set.new({})
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
        self.GoalMax = 0
        self.LastExtentsCheck = os.clock()
        for _, times in pairs(RGMercModules.FrameTimes) do
            for _, t in ipairs(times) do
                if t > self.GoalMax then
                    self.GoalMax = math.ceil(t / self.MaxFrameStep) * self.MaxFrameStep
                end
            end
        end
    end

    -- converge on new max recalc min and maxes
    if RGMercModules:GetMaxFrameTime() < self.GoalMax then RGMercModules:SetMaxFrameTime(RGMercModules:GetMaxFrameTime() + 1) end
    if RGMercModules:GetMaxFrameTime() > self.GoalMax then RGMercModules:SetMaxFrameTime(RGMercModules:GetMaxFrameTime() - 1) end

    if self.settings.FramesToStore ~= #self.xAxes then
        self.xAxes = {}
        for i = 1, self.settings.FramesToStore do table.insert(self.xAxes, i) end
    end

    if ImPlot.BeginPlot("Frame Times for RGMercs Modules") then
        ImPlot.SetupAxes("Frame #", "Frame Time (ms)")
        ImPlot.SetupAxesLimits(1, self.settings.FramesToStore, 0, RGMercModules:GetMaxFrameTime(), ImPlotCond.Always)

        for module, times in pairs(RGMercModules.FrameTimes) do
            if times then
                ImPlot.PlotLine(module, self.xAxes, times, #times)
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
    if RGMercModules:GetFramesToStore() ~= self.settings.FramesToStore then
        RGMercModules:SetFramesToStore(self.settings.FramesToStore)
    end

    local newHigh = 0 --RGMercModules:GetMaxFrameTime()
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
