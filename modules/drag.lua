-- Sample Basic Class Module
local mq                 = require('mq')
local RGMercUtils        = require("utils.rgmercs_utils")
local Set                = require("mq.Set")

local Module             = { _version = '0.1a', _name = "Drag", _author = 'Derple', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultConfig     = {
    ['DoDrag']       = { DisplayName = "Drag Corpses", Category = "Drag", Tooltip = "Enable Dragging Corpses with you", Default = false, },
    ['DoSearchDrag'] = { DisplayName = "Use Spawn Search Dragging", Category = "Drag", Tooltip = "Use Search to find drag targets", Default = false, },
    ['SearchDrag']   = { DisplayName = "Spawn Search", Category = "Drag", Tooltip = "Enable Dragging Corpses with you", Default = "pccorpse group radius 60", },
    ['DoDanNetDrag'] = { DisplayName = "Use DanNet Dragging", Category = "Drag", Tooltip = "Use DanNet to find drag targets", Default = false, },
}
Module.DefaultCategories = {}

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
    RGMercsLogger.log_debug("Drag Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Drag]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self:SaveSettings(false)
    else
        self.settings = config()
    end

    Module.DefaultCategories = Set.new({})
    for _, v in pairs(self.DefaultConfig or {}) do
        if v.Type ~= "Custom" then
            Module.DefaultCategories:add(v.Category)
        end
    end

    -- Setup Defaults
    self.settings = RGMercUtils.ResolveDefaults(self.DefaultConfig, self.settings)
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
    RGMercsLogger.log_debug("Drag Module Loaded.")
    self:LoadSettings()

    self.ModuleLoaded = true

    return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    ImGui.Text("Drag Module")
    local pressed
    if self.ModuleLoaded then
        if ImGui.Button(RGMercUtils.GetSetting('DoDrag') and "Stop Dragging" or "Start Dragging", ImGui.GetWindowWidth() * .3, 25) then
            self.settings.DoDrag = not self.settings.DoDrag
            self:SaveSettings(false)
        end

        if ImGui.CollapsingHeader("Config Options") then
            self.settings, pressed, _ = RGMercUtils.RenderSettings(self.settings, self.DefaultConfig,
                self.DefaultCategories)
            if pressed then
                self:SaveSettings(false)
            end
        end
    end
end

function Module:Drag(corpse)
    if corpse and corpse() and corpse.Distance() > 10 then
        RGMercsLogger.log_debug("Dragging: %s (%d)", corpse.DisplayName(), corpse.ID())
        RGMercUtils.SetTarget(corpse.ID())
        RGMercUtils.DoCmd("/corpse")
    end
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.

    local corpseSearch = "pccorpse %s's radius 60"
    if RGMercUtils.GetSetting('DoDrag') then
        local myCorpse = mq.TLO.Spawn(string.format(corpseSearch, mq.TLO.Me.DisplayName()))

        self:Drag(myCorpse)

        if RGMercUtils.GetSetting('DoSearchDrag') then
            local numCorpses = mq.TLO.SpawnCount(RGMercUtils.GetSetting('SearchDrag'))()

            for i = numCorpses, 1, -1 do
                local corpse = mq.TLO.NearestSpawn(i, RGMercUtils.GetSetting('SearchDrag'))
                self:Drag(corpse)
            end
        end

        if RGMercUtils.GetSetting('DoDanNetDrag') then
            local dannetPeers = mq.TLO.DanNet.PeerCount()
            for i = 1, dannetPeers do
                ---@diagnostic disable-next-line: redundant-parameter
                local peer = mq.TLO.DanNet.Peers(i)()
                if peer and peer:len() > 0 then
                    RGMercsLogger.log_debug("Searching corpses for: %s", peer)
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
    RGMercsLogger.log_debug("Drag Module Unloaded.")
end

return Module
