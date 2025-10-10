-- Drag Module
local mq        = require('mq')
local Config    = require('utils.config')
local Core      = require("utils.core")
local Targeting = require("utils.targeting")
local Ui        = require("utils.ui")
local Comms     = require("utils.comms")
local Logger    = require("utils.logger")
local Strings   = require("utils.strings")
local Set       = require("mq.Set")


local Module         = { _version = '0.1a', _name = "Drag", _author = 'Derple', }
Module.__index       = Module
Module.FAQ           = {}
Module.SaveRequested = nil

Module.DefaultConfig = {
    ['DoDrag']                                 = {
        DisplayName = "Drag Corpses",
        Group = "Movement",
        Header = "Drag",
        Category = "Drag",
        Tooltip = "Enable dragging friendly corpses in your vacinity.",
        Index = 1,
        Default = false,
    },
    ['DoDanNetDrag']                           = {
        DisplayName = "Use DanNet Dragging",
        Group = "Movement",
        Header = "Drag",
        Category = "Drag",
        Tooltip = "Use DanNet peer checks to identify corpses that should be dragged within a 95 unit radius.",
        Index = 2,
        Default = true,
    },
    ['DoSearchDrag']                           = {
        DisplayName = "Use Spawn Search Dragging",
        Group = "Movement",
        Header = "Drag",
        Category = "Drag",
        Tooltip = "Use an MQ Spawn Search to identify corpses that should be dragged.",
        Index = 3,
        Default = false,
    },
    ['SearchDrag']                             = {
        DisplayName = "Spawn Search",
        Group = "Movement",
        Header = "Drag",
        Category = "Drag",
        Tooltip = "The MQ Spawn Search used when Spawn Search Dragging is enabled above. Note the max drag distance is 100 units.",
        Index = 4,
        Default = "pccorpse group radius 95",
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Default = false,
    },
}

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
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
    Logger.log_debug("Drag Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()
    local settings = {}
    local firstSaveRequired = false


    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Drag]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        firstSaveRequired = true
    else
        settings = config()
    end

    Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)
end

function Module.New()
    local newModule = setmetatable({}, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Drag Module Loaded.")
    self:LoadSettings()

    self.ModuleLoaded = true

    return { self = self, defaults = self.DefaultConfig, }
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    Ui.RenderPopAndSettings(self._name)

    if self.ModuleLoaded then
        if ImGui.Button(Config:GetSetting('DoDrag') and "Stop Dragging" or "Start Dragging", ImGui.GetWindowWidth() * .3, 25) then
            Config:SetSetting('DoDrag', not Config:GetSetting('DoDrag'))
        end
    end
end

function Module:Pop()
    Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Module:Drag(corpse)
    if corpse and corpse() and corpse.Distance() > 10 then
        Logger.log_debug("Dragging: %s (%d)", corpse.DisplayName(), corpse.ID())
        Targeting.SetTarget(corpse.ID())
        Core.DoCmd("/corpse")
    end
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.

    local corpseSearch = "pccorpse %s's radius 90"
    if Config:GetSetting('DoDrag') then
        local myCorpse = mq.TLO.Spawn(string.format(corpseSearch, mq.TLO.Me.DisplayName()))

        self:Drag(myCorpse)

        if Config:GetSetting('DoSearchDrag') then
            local numCorpses = mq.TLO.SpawnCount(Config:GetSetting('SearchDrag'))()

            for i = numCorpses, 1, -1 do
                local corpse = mq.TLO.NearestSpawn(i, Config:GetSetting('SearchDrag'))
                self:Drag(corpse)
            end
        end

        if Config:GetSetting('DoDanNetDrag') then
            local dannetPeers = mq.TLO.DanNet.PeerCount()
            for i = 1, dannetPeers do
                ---@diagnostic disable-next-line: redundant-parameter
                local peer = mq.TLO.DanNet.Peers(i)()
                if peer and peer:len() > 0 then
                    Logger.log_debug("Searching corpses for: %s", peer)
                    local currentSearch = string.format(corpseSearch, peer)
                    local numCorpses = mq.TLO.SpawnCount(currentSearch)()

                    for i = numCorpses, 1, -1 do
                        local corpse = mq.TLO.NearestSpawn(i, currentSearch)
                        self:Drag(corpse)
                    end
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
    -- Reture a reasonable state if queried
    return "Running..."
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
    Logger.log_debug("Drag Module Unloaded.")
end

return Module
