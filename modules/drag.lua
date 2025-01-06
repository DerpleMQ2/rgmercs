-- Sample Basic Class Module
local mq                 = require('mq')
local Config             = require('utils.config')
local Core               = require("utils.core")
local Targeting          = require("utils.targeting")
local Ui                 = require("utils.ui")
local Comms              = require("utils.comms")
local Logger             = require("utils.logger")
local Set                = require("mq.Set")
local Icons              = require('mq.ICONS')

local Module             = { _version = '0.1a', _name = "Drag", _author = 'Derple', }
Module.__index           = Module
Module.settings          = {}
Module.FAQ               = {}
Module.ClassFAQ          = {}

Module.DefaultConfig     = {
    ['DoDrag']                                 = {
        DisplayName = "Drag Corpses",
        Category = "Drag",
        Tooltip = "Enable Dragging Corpses with you",
        Index = 1,
        Default = false,
        FAQ = "How do I make a character drag group member corpses to me?",
        Answer = "Enable [DoDrag] and you will drag corpses to you.",
    },
    ['DoSearchDrag']                           = {
        DisplayName = "Use Spawn Search Dragging",
        Category = "Drag",
        Tooltip = "Use Search to find drag targets",
        Index = 3,
        Default = false,
        FAQ = "I want to Find Corpses to Drag, how do I do that?",
        Answer = "Enable [DoSearchDrag] and you will Search for Party Member Corpses in your [SearchDrag] Radius and if found grab them.",
    },
    ['SearchDrag']                             = {
        DisplayName = "Spawn Search",
        Category = "Drag",
        Tooltip = "Enable Dragging Corpses with you",
        Index = 4,
        Default = "pccorpse group radius 60",
        FAQ = "Can I adjust the range of the Search? What about finding other corpses not in my group?",
        Answer = "With [DoDrag] and [DoSearchDrag] enabled you can adjust the search radius with [SearchDrag]." ..
            " You can also remove group from the string to find other player corpses.",
    },
    ['DoDanNetDrag']                           = {
        DisplayName = "Use DanNet Dragging",
        Category = "Drag",
        Tooltip = "Use DanNet to find drag targets",
        Index = 2,
        Default = true,
        FAQ = "My Guys are not dragging corpses with me, what do I do?",
        Answer = "Make sure if you are using DanNet that you have [DoDanNetDrag] enabled as well as [DoDrag].",
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Category = "Custom",
        Tooltip = Module._name .. " Pop Out Into Window",
        Default = false,
        FAQ = "Can I pop out the " .. Module._name .. " module into its own window?",
        Answer =
        "You can set the click the popout button at the top of a tab or heading to pop it into its own window.\n Simply close the window and it will snap back to the main window.",
    },
}
Module.DefaultCategories = {}

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast == true then
        Comms.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    Logger.log_debug("Drag Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Drag]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self:SaveSettings(false)
    else
        self.settings = config()
    end

    Module.DefaultCategories = Set.new({})
    for k, v in pairs(Module.DefaultConfig or {}) do
        if v.Type ~= "Custom" then
            Module.DefaultCategories:add(v.Category)
        end
        Module.FAQ[k] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', Settings_Used = k, }
    end

    local settingsChanged = false

    -- Setup Defaults
    self.settings, settingsChanged = Config.ResolveDefaults(self.DefaultConfig, self.settings)

    if settingsChanged then
        self:SaveSettings(false)
    end
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
    Logger.log_debug("Drag Module Loaded.")
    self:LoadSettings()

    self.ModuleLoaded = true

    return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    if not self.settings[self._name .. "_Popped"] then
        if ImGui.SmallButton(Icons.MD_OPEN_IN_NEW) then
            self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
            self:SaveSettings(false)
        end
        Ui.Tooltip(string.format("Pop the %s tab out into its own window.", self._name))
        ImGui.NewLine()
    end

    local pressed
    if self.ModuleLoaded then
        if ImGui.Button(Config:GetSetting('DoDrag') and "Stop Dragging" or "Start Dragging", ImGui.GetWindowWidth() * .3, 25) then
            self.settings.DoDrag = not self.settings.DoDrag
            self:SaveSettings(false)
        end

        ImGui.Separator()

        if ImGui.CollapsingHeader("Config Options") then
            self.settings, pressed, _ = Ui.RenderSettings(self.settings, self.DefaultConfig,
                self.DefaultCategories)
            if pressed then
                self:SaveSettings(false)
            end
        end
    end
end

function Module:Pop()
    self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
    self:SaveSettings(false)
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

    local corpseSearch = "pccorpse %s's radius 60"
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

function Module:GetClassFAQ()
    return { module = self._name, FAQ = self.ClassFAQ or {}, }
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
