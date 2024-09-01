-- Sample Performance Monitor Class Module
local mq                  = require('mq')
local RGMercUtils         = require("utils.rgmercs_utils")
local ImPlot              = require('ImPlot')
local Set                 = require('mq.Set')
local ScrollingPlotBuffer = require('utils.scrolling_plot_buffer')

local Module              = { _version = '0.1a', _name = "Experience", _author = 'Derple', }
Module.__index            = Module
Module.settings           = {}
Module.DefaultConfig      = {}
Module.DefaultCategories  = {}
Module.XPEvents           = {}
Module.MaxStep            = 50
Module.GoalMaxExpPerSec   = 0
Module.CurMaxExpPerSec    = 0
Module.LastExtentsCheck   = os.clock()
Module.XPPerSecond        = 0
Module.XPToNextLevel      = 0
Module.SecondsToLevel     = 0
Module.TimeToLevel        = "<Unknown>"

Module.TrackXP            = {
    PlayerLevel = mq.TLO.Me.Level(),
    PlayerAA = mq.TLO.Me.AAPointsTotal(),
    StartTime = os.clock(),

    XPTotalPerLevel = 100000,
    XPTotalDivider = 1000,

    Experience = {
        Base = mq.TLO.Me.Exp(),
        Total = 0,
        Gained = 0,
    },
    AAExperience = {
        Base = mq.TLO.Me.AAExp(),
        Total = 0,
        Gained = 0,
    },
}

Module.DefaultConfig      = {
    ['ExpSecondsToStore'] = { DisplayName = "Seconds to Store", Category = "Monitoring", Tooltip = "The number of Seconds to keep in history.", Type = "Custom", Default = 30, Min = 10, Max = 120, Step = 5, },
    ['EnabledExpTracker'] = { DisplayName = "Enable Exp Tracker", Category = "Monitoring", Tooltip = "Enable Tracking Experience", Default = true, },
    ['ExpPlotFillLines']  = { DisplayName = "Enable Fill Lines", Category = "Graph", Tooltip = "Fill in the Plot Lines", Default = true, },
    ['GraphMultiplier']   = { DisplayName = "Graph Multiplier", Category = "Graph", Tooltip = "What to multiply the graph numbers by to make it more readable.", Type = "Combo", ComboOptions = { '1', '10', '100', '1000', }, Default = 3, Min = 1, Max = 4, },
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

function Module:ClearStats()
    self.TrackXP = {
        PlayerLevel = mq.TLO.Me.Level(),
        PlayerAA = mq.TLO.Me.AAPointsTotal(),
        StartTime = os.clock(),

        XPTotalPerLevel = 100000,
        XPTotalDivider = 1000,

        Experience = {
            Base = mq.TLO.Me.Exp(),
            Total = 0,
            Gained = 0,
        },
        AAExperience = {
            Base = mq.TLO.Me.AAExp(),
            Total = 0,
            Gained = 0,
        },
    }

    self.XPEvents = {}
end

function Module:ShouldRender()
    return true
end

function Module:RenderShaded(type, currentData, otherData, multiplier)
    if currentData then
        local offset = currentData.expEvents.Offset - 1
        local count = #currentData.expEvents.DataY

        if RGMercUtils.GetSetting('ExpPlotFillLines') then
            ImPlot.PlotShaded(type,
                function(n)
                    local pos = ((offset + n) % count) + 1
                    return ImPlotPoint(currentData.expEvents.DataX[pos], currentData.expEvents.DataY[pos] * multiplier)
                end,
                function(n)
                    local pos = ((offset + n) % count) + 1
                    local lowerBound = 0
                    if otherData and otherData.expEvents and otherData.expEvents.DataY[pos] and otherData.expEvents.DataY[pos] < currentData.expEvents.DataY[pos] then
                        lowerBound = otherData.expEvents.DataY[pos]
                    end
                    return ImPlotPoint(currentData.expEvents.DataX[pos], lowerBound)
                end,
                count,
                ImPlotShadedFlags.None)
        end
        ImPlot.PlotLine(type,
            ---@diagnostic disable-next-line: param-type-mismatch
            function(n)
                local pos = ((offset + n) % count) + 1

                if currentData.expEvents.DataY[pos] == nil then
                    RGMercsLogger.log_error("Exp Plotter requested a plot point that doesn't exist! This should never happen! (o:%d n:%d c:%d p:%d)", offset, n, count, pos)
                    return ImPlotPoint(0, 0)
                end

                return ImPlotPoint(currentData.expEvents.DataX[pos], currentData.expEvents.DataY[pos] * multiplier)
            end,
            count,
            ImPlotLineFlags.None)
    end
end

function Module:Render()
    ImGui.Text("Experience Monitor Modules")
    local pressed
    if not self.SettingsLoaded then return end

    if ImGui.Button("Reset Stats", ImGui.GetWindowWidth() * .3, 25) then
        self:ClearStats()
    end

    if ImGui.BeginTable("ExpStats", 2, bit32.bor(ImGuiTableFlags.Borders)) then
        ImGui.TableNextColumn()
        ImGui.Text("Exp Session Time")
        ImGui.TableNextColumn()
        ImGui.Text(RGMercUtils.FormatTime(os.clock() - self.TrackXP.StartTime))
        ImGui.TableNextColumn()
        ImGui.Text("Exp Gained")
        ImGui.TableNextColumn()
        ImGui.Text(string.format("%2.3f%%", self.TrackXP.Experience.Total / self.TrackXP.XPTotalDivider))
        ImGui.TableNextColumn()
        ImGui.Text("AA Gained")
        ImGui.TableNextColumn()
        ImGui.Text(string.format("%2.3f%%", self.TrackXP.AAExperience.Total / self.TrackXP.XPTotalDivider))
        ImGui.TableNextColumn()
        ImGui.Text("Exp / Min")
        ImGui.TableNextColumn()
        ImGui.Text(string.format("%2.3f%%", self.XPPerSecond * 60))
        ImGui.TableNextColumn()
        ImGui.Text("Exp / Hr")
        ImGui.TableNextColumn()
        ImGui.Text(string.format("%2.3f%%", self.XPPerSecond * 3600))
        ImGui.TableNextColumn()
        ImGui.Text("Time To Level")
        ImGui.TableNextColumn()
        ImGui.Text(string.format("%s", self.TimeToLevel))
        ImGui.TableNextColumn()
        ImGui.Text("AA / Min")
        ImGui.TableNextColumn()
        ImGui.Text(string.format("%2.3f%%", ((self.TrackXP.AAExperience.Total / self.TrackXP.XPTotalDivider) / (os.clock() - self.TrackXP.StartTime)) * 60))
        ImGui.EndTable()
    end

    local multiplier = tonumber(self.DefaultConfig.GraphMultiplier.ComboOptions[self.settings.GraphMultiplier])

    -- converge on new max recalc min and maxes
    if self.CurMaxExpPerSec < self.GoalMaxExpPerSec then self.CurMaxExpPerSec = self.CurMaxExpPerSec + 1 end
    if self.CurMaxExpPerSec > self.GoalMaxExpPerSec then self.CurMaxExpPerSec = self.CurMaxExpPerSec - 1 end


    if ImPlot.BeginPlot("Experience Tracker") then
        if self.settings.GraphMultiplier == 1 then
            ImPlot.SetupAxes("Time (s)", "Exp %")
        else
            ImPlot.SetupAxes("Time (s)", string.format("Exp %% %sths", self.DefaultConfig.GraphMultiplier.ComboOptions[self.settings.GraphMultiplier]))
        end
        ImPlot.SetupAxisLimits(ImAxis.X1, os.clock() - self.settings.ExpSecondsToStore, os.clock(), ImGuiCond.Always)
        ImPlot.SetupAxisLimits(ImAxis.Y1, 1, self.CurMaxExpPerSec, ImGuiCond.Always)

        ImPlot.PushStyleVar(ImPlotStyleVar.FillAlpha, 0.35)
        self:RenderShaded("Exp", self.XPEvents.Exp, self.XPEvents.AA, multiplier)
        self:RenderShaded("AA", self.XPEvents.AA, self.XPEvents.Exp, multiplier)
        ImPlot.PopStyleVar()

        ImPlot.EndPlot()
    end

    if ImGui.CollapsingHeader("Config Options") then
        self.settings.ExpSecondsToStore, pressed = ImGui.SliderInt(self.DefaultConfig.ExpSecondsToStore.DisplayName,
            self.settings.ExpSecondsToStore, self.DefaultConfig.ExpSecondsToStore.Min,
            self.DefaultConfig.ExpSecondsToStore
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

function Module:CheckExpChanged()
    local me = mq.TLO.Me
    local currentExp = me.Exp()
    if currentExp ~= self.TrackXP.Experience.Base then
        if me.Level() == self.TrackXP.PlayerLevel then
            self.TrackXP.Experience.Gained = currentExp - self.TrackXP.Experience.Base
        elseif me.Level() > self.TrackXP.PlayerLevel then
            self.TrackXP.Experience.Gained = self.TrackXP.XPTotalPerLevel - self.TrackXP.Experience.Base + currentExp
        else
            self.TrackXP.Experience.Gained = self.TrackXP.Experience.Base - self.TrackXP.XPTotalPerLevel + currentExp
        end

        self.TrackXP.Experience.Total = self.TrackXP.Experience.Total + self.TrackXP.Experience.Gained
        self.TrackXP.Experience.Base = currentExp
        self.TrackXP.PlayerLevel = me.Level()

        return true
    end

    self.TrackXP.Experience.Gained = 0
    return false
end

function Module:CheckAAExpChanged()
    local me = mq.TLO.Me
    local currentExp = me.AAExp()
    if currentExp ~= self.TrackXP.AAExperience.Base then
        if me.AAPointsTotal() == self.TrackXP.PlayerAA then
            self.TrackXP.AAExperience.Gained = currentExp - self.TrackXP.AAExperience.Base
        else
            self.TrackXP.AAExperience.Gained = currentExp - self.TrackXP.AAExperience.Base + ((me.AAPointsTotal() - self.TrackXP.PlayerAA) * self.TrackXP.XPTotalPerLevel)
        end

        self.TrackXP.AAExperience.Total = self.TrackXP.AAExperience.Total + self.TrackXP.AAExperience.Gained
        self.TrackXP.AAExperience.Base = currentExp
        self.TrackXP.PlayerAA = me.AAPointsTotal()

        return true
    end

    self.TrackXP.AAExperience.Gained = 0
    return false
end

function Module:GiveTime(combat_state)
    if mq.TLO.EverQuest.GameState() == "INGAME" then
        if self:CheckExpChanged() then
            RGMercsLogger.log_debug("\ayXP Gained: \ag%02.3f%% \aw|| \ayXP Total: \ag%02.3f%% \aw|| \ayStart: \am%d \ayCur: \am%d \ayExp/Sec: \ag%2.3f%%",
                self.TrackXP.Experience.Gained / self.TrackXP.XPTotalDivider,
                self.TrackXP.Experience.Total / self.TrackXP.XPTotalDivider,
                self.TrackXP.StartTime,
                os.clock(),
                self.TrackXP.Experience.Total / self.TrackXP.XPTotalDivider / ((os.clock()) - self.TrackXP.StartTime))
        end

        if not self.XPEvents.Exp then
            self.XPEvents.Exp = {
                lastFrame = os.clock(),
                expEvents =
                    ScrollingPlotBuffer:new(),
            }
        end

        self.XPEvents.Exp.lastFrame = os.clock()
        ---@diagnostic disable-next-line: undefined-field
        self.XPEvents.Exp.expEvents:AddPoint(os.clock(), (self.TrackXP.Experience.Total / ((os.clock()) - self.TrackXP.StartTime)) * 10)

        self.XPPerSecond    = (self.TrackXP.Experience.Total / self.TrackXP.XPTotalDivider) / (os.clock() - self.TrackXP.StartTime)
        self.XPToNextLevel  = self.TrackXP.XPTotalPerLevel - mq.TLO.Me.Exp()
        self.SecondsToLevel = self.XPToNextLevel / (self.XPPerSecond * self.TrackXP.XPTotalDivider)
        self.TimeToLevel    = self.XPPerSecond <= 0 and "<Unknown>" or RGMercUtils.FormatTime(self.SecondsToLevel, "%d Days %d Hours %d Mins")

        if mq.TLO.Me.PctAAExp() > 0 and self:CheckAAExpChanged() then
            RGMercsLogger.log_debug("\ayAA Gained: \ag%2.2f%% \aw|| \ayAA Total: \ag%2.2f%%", self.TrackXP.AAExperience.Gained / self.TrackXP.XPTotalDivider,
                self.TrackXP.AAExperience.Total / self.TrackXP.XPTotalDivider)
        end

        if not self.XPEvents.AA then
            self.XPEvents.AA = {
                lastFrame = os.clock(),
                expEvents =
                    ScrollingPlotBuffer:new(),
            }
        end

        self.XPEvents.AA.lastFrame = os.clock()
        ---@diagnostic disable-next-line: undefined-field
        self.XPEvents.AA.expEvents:AddPoint(os.clock(), (self.TrackXP.AAExperience.Total / ((os.clock()) - self.TrackXP.StartTime)))
    end

    local multiplier = tonumber(self.DefaultConfig.GraphMultiplier.ComboOptions[self.settings.GraphMultiplier])
    if os.clock() - self.LastExtentsCheck > 0.01 then
        self.GoalMaxExpPerSec = 0
        self.LastExtentsCheck = os.clock()
        for _, expData in pairs(self.XPEvents) do
            for idx, exp in ipairs(expData.expEvents.DataY) do
                exp = exp * multiplier
                -- is this entry visible?
                local visible = expData.expEvents.DataX[idx] > os.clock() - self.settings.ExpSecondsToStore and
                    expData.expEvents.DataX[idx] < os.clock()
                if visible and exp > self.GoalMaxExpPerSec then
                    self.GoalMaxExpPerSec = (math.ceil(exp / self.MaxStep) * self.MaxStep) * 1.25
                end
            end
        end
    end
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
    RGMercsLogger.log_debug("Experience Monitor Module Unloaded.")
end

return Module
