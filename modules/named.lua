-- Sample Named Class Module
local mq                 = require('mq')
local RGMercUtils        = require("utils.rgmercs_utils")
local Set                = require("mq.Set")

local Module             = { _version = '0.1a', _name = "Named", _author = 'Grimmier', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultConfig     = {}
Module.DefaultCategories = {}
Module.FAQ               = {}
Module.ClassFAQ          = {}

Module.NamedList         = {}
Module.NamedAM           = {}
Module.NamedSM           = {}
Module.CurSelection      = 1
Module.namesLoaded       = false

Module.DefNamed          = RGMercNameds or {}

Module.DefaultConfig     = {
    ['NamedTable'] = {
        DisplayName = "Named Table",
        Category = "Named Spawns",
        Tooltip = "Enables loading a different Named List",
        Type = "Combo",
        ComboOptions = { 'RGMercs', 'Alert Master', 'Spawn Master', },
        Default = 1,
        Min = 1,
        Max = 3,
        FAQ = "Why am I not seeing anything in the Named list?",
        Answer = "You must pick either Use RGMercs, Spawn Master or Alert Master List.",
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Category = "Named Table",
        Tooltip = Module._name .. " Pop Out Into Window",
        Default = false,
        FAQ = "Can I pop out the " .. Module._name .. " module into its own window?",
        Answer = "You can pop out the " .. Module._name .. " module into its own window by toggeling " .. Module._name .. "_Popped",
    },
}

Module.CommandHandlers   = {

}

Module.DefaultCategories = Set.new({})
for k, v in pairs(Module.DefaultConfig or {}) do
    if v.Type ~= "Custom" then
        Module.DefaultCategories:add(v.Category)
    end

    Module.FAQ[k] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', Settings_Used = k, }
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
    self.NamedList = {}
    RGMercsLogger.log_debug("Named Combat Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Named]: Unable to load Named settings file(%s), creating a new one!",
            settings_pickle_path)
        self.settings.MyCheckbox = false
        self:SaveSettings(false)
    else
        self.settings = config()
    end

    local settingsChanged = false
    -- Setup Defaults
    self.settings, settingsChanged = RGMercUtils.ResolveDefaults(self.DefaultConfig, self.settings)

    if settingsChanged then
        self:SaveSettings(false)
    end

    self.CurSelection = self.settings['NamedTable']

    self.NamedAM = self:LoadNamed("AlertMaster.ini")
    self.NamedSM = self:LoadNamed("MQ2SpawnMaster.ini")

    self:RefreshNamedTable()
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
    RGMercsLogger.log_debug("Named Combat Module Loaded.")
    self:LoadSettings()

    return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    if ImGui.SmallButton(RGMercIcons.MD_OPEN_IN_NEW) then
        self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
        self:SaveSettings(false)
    end
    ImGui.SameLine()
    ImGui.Text("Named Spawns")

    ---@type boolean|nil
    local pressed

    ImGui.SetNextItemWidth(150)
    self.settings['NamedTable'], pressed = ImGui.Combo("Named Table", self.settings['NamedTable'], { 'RGMercs', 'Alert Master', 'Spawn Master', })
    if pressed then
        if self.settings['NamedTable'] ~= self.CurSelection then
            self:SaveSettings(false)
            self:RefreshNamedTable()
            self.CurSelection = self.settings['NamedTable']
        end
    end
    ImGui.SameLine()
    if ImGui.SmallButton("Reload from INI") then
        if self.settings['NamedTable'] == 2 then
            self.NamedAM = self:LoadNamed("AlertMaster.ini", true)
        elseif self.settings['NamedTable'] == 3 then
            self.NamedSM = self:LoadNamed("MQ2SpawnMaster.ini", true)
        end
        self:RefreshNamedTable()
    end

    ImGui.Separator()
    RGMercUtils.RenderZoneNamed()
end

---comment
---@param fileName any @ The file name to load mq.configDir/ is appended to the front of the file name
---@param forced boolean|nil @ Should re reload the ini if already loaded?
---@return table
function Module:LoadNamed(fileName, forced)
    forced = forced ~= nil and forced or false
    if self.namesLoaded and not forced then
        if fileName == "AlertMaster.ini" then
            return self.NamedAM
        elseif fileName == "MQ2SpawnMaster.ini" then
            return self.NamedSM
        end
    end

    fileName = mq.configDir .. "/" .. fileName
    if not RGMercUtils.file_exists(fileName) then
        return {}
    end

    local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
    local data = {};
    local section;
    for line in file:lines() do
        local tempSection = line:match('^%[([^%[%]]+)%]');
        if (tempSection) then
            section = tempSection:lower();
            data[section] = data[section] or {};
        end
        local param, value = line:match("^([%w|_'.%s-]+)=%s-(.+)$");
        if (param ~= 'OnSpawnCommand' and param ~= 'Enabled' and param ~= nil and value ~= nil) then
            data[section][param] = value;
        end
    end
    file:close();
    self.namesLoaded = true;

    return data;
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
end

function Module:OnDeath()
    -- Death Handler
end

function Module:RefreshNamedTable()
    RGMercNameds = {}
    if self.settings['NamedTable'] > 1 then
        if self.settings['NamedTable'] == 2 then
            self.NamedList = self.NamedAM
        elseif self.settings['NamedTable'] == 3 then
            self.NamedList = self.NamedSM
        end
        local zoneName = mq.TLO.Zone.Name():lower()
        local shortZone = mq.TLO.Zone.ShortName():lower()
        for zone, data in pairs(self.NamedList) do
            if zone:lower() == zoneName or zone:lower() == shortZone then
                RGMercNameds[shortZone] = {}
                for _, spawnName in pairs(data) do
                    table.insert(RGMercNameds[shortZone], spawnName)
                end
            end
        end
    else
        RGMercNameds = self.DefNamed
    end
    -- Force a refresh of the named cache so the UI updates
    RGMercUtils.LastZoneID = -1
    RGMercUtils.RefreshNamedCache()
end

function Module:OnZone()
    self:RefreshNamedTable()
end

function Module:OnCombatModeChanged()
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    return "Running..."
end

function Module:Pop()
    self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
    self:SaveSettings(false)
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

    if self.CommandHandlers[cmd:lower()] ~= nil then
        self.CommandHandlers[cmd:lower()].handler(self, params)
        handled = true
    end

    return handled
end

function Module:Shutdown()
    RGMercsLogger.log_debug("Named Combat Module Unloaded.")
end

return Module
