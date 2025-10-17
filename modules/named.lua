-- Sample Named Class Module
local mq               = require('mq')
local Config           = require('utils.config')
local Targeting        = require("utils.targeting")
local Ui               = require("utils.ui")
local Comms            = require("utils.comms")
local Files            = require("utils.files")
local Logger           = require("utils.logger")
local Strings          = require("utils.strings")
local Set              = require("mq.Set")
local Nameds           = require("utils.nameds")

local Module           = { _version = '0.1a', _name = "Named", _author = 'Grimmier', }
Module.__index         = Module
Module.DefaultConfig   = {}
Module.CachedNamedList = {}
Module.SaveRequested   = nil

Module.NamedList       = {}
Module.NamedAM         = {}
Module.NamedSM         = {}
Module.CurSelection    = 1
Module.namesLoaded     = false
Module.LastNamedCheck  = 0

Module.DefNamed        = Nameds or {}

Module.DefaultConfig   = {
    ['NamedTable'] = {
        DisplayName = "Named Table",
        Tooltip = "Enables loading a different Named List",
        Type = "Custom",
        Default = 1,
        Min = 1,
        Max = 3,
        FAQ = "Why do we have different options for the named list?",
        Answer =
            "RGMercs has a built-in named list that is suitable for official EQ servers. However, other servers may change or add named mobs. In that case, you can replace the default list by loading your Alert Master or MQ2SpawnMaster list instead.\n" ..
            "Please note that regardless of which list you choose, we will use the MQ2SpawnMaster TLO (if loaded) to check that list for the purposes of when to burn or use certain abilities.",
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Default = false,
    },
}

Module.CommandHandlers = {

}

Module.FAQ             = {
    [1] = {
        Question = "Why am I not taking any special actions on a Named, boss, or mission mob?",
        Answer =
            "  RGMercs default class configs fully support burning, using defenses, or other special actions on Named mobs, however, your target must be indentified as such. There are two methods for doing so:\n\n" ..
            "  1) The Spawn Master TLO: If the MQ2SpawnMaster plugin is loeaded (highly recommended), you can simply add a mob to its watch list (see '/spawnmaster help'). We will query SpawnMaster via built-in data reporting (TLO), and if the mob is present, treat it as a named.\n\n" ..
            "  Using this method, it is very easy to treat mission bosses as named, without adding them to the Named List, which is typically aimed at typical PH/rare spawn style mobs.\n\n" ..
            "  2) The Named List: RGMercs will consult the built-in Named List. If the mob is found on the list, it will be treated as a Named. It is also possible to use an external Named List, such as the Alert Master or MQ2SpawnMaster list (see other FAQs).\n\n" ..
            "  Specific feedback on missing, incorrect, or otherwise erroneous entries on the RGMercs Named List is always welcome!\n\n",
        Settings_Used = "",
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
    self.NamedList = {}
    Logger.log_debug("Named Combat Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()
    local settings = {}
    local firstSaveRequired = false

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Named]: Unable to load Named settings file(%s), creating a new one!",
            settings_pickle_path)
        firstSaveRequired = true
    else
        settings = config()
    end

    Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)

    self.CurSelection = Config:GetSetting('NamedTable')

    self.NamedAM = self:LoadNamed("AlertMaster.ini")
    self.NamedSM = self:LoadNamed("MQ2SpawnMaster.ini")

    self:RefreshNamedTable()
end

function Module.New()
    local newModule = setmetatable({}, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Named Combat Module Loaded.")
    self:LoadSettings()

    return { self = self, defaults = self.DefaultConfig, }
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    Ui.RenderPopAndSettings(self._name)

    ImGui.SameLine()
    ImGui.Text("Make any mob \"named\" for burns by adding it to your MQ2SpawnMaster list!")
    ImGui.NewLine()
    Ui.RenderZoneNamed()

    ---@type boolean|nil
    local pressed

    ImGui.SetNextItemWidth(150)
    local namedTable = Config:GetSetting('NamedTable')

    namedTable, pressed = ImGui.Combo("Named Table", namedTable, { 'RGMercs', 'Alert Master', 'MQ2SpawnMaster', })
    if pressed then
        if namedTable ~= self.CurSelection then
            Config:SetSetting('NamedTable', namedTable)
            self:RefreshNamedTable()
            self.CurSelection = namedTable
        end
    end
    Ui.Tooltip(
        "RGMercs has a built-in named list that is suitable for official EQ servers. However, other servers may change or add named mobs. In that case, you can replace the default list by loading your Alert Master or MQ2SpawnMaster list instead.\n" ..
        "Please note that regardless of which list you choose, we will use the MQ2SpawnMaster TLO (if loaded) to check that list for the purposes of when to burn or use certain abilities.")
    ImGui.SameLine()
    if ImGui.SmallButton("Reload from INI") then
        if Config:GetSetting('NamedTable') == 2 then
            self.NamedAM = self:LoadNamed("AlertMaster.ini", true)
        elseif Config:GetSetting('NamedTable') == 3 then
            self.NamedSM = self:LoadNamed("MQ2SpawnMaster.ini", true)
        end
        self:RefreshNamedTable()
    end
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
    if not Files.file_exists(fileName) then
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
        if (section ~= nil and param ~= 'OnSpawnCommand' and param ~= 'Enabled' and param ~= nil and value ~= nil) then
            data[section][param] = value;
        end
    end
    file:close();
    self.namesLoaded = true;

    return data;
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
    if os.clock() - self.LastNamedCheck > 1 then
        self.LastNamedCheck = os.clock()
        self:CheckZoneNamed()
    end
end

function Module:OnDeath()
    -- Death Handler
end

function Module:RefreshNamedTable()
    Nameds = {}
    if Config:GetSetting('NamedTable') > 1 then
        if Config:GetSetting('NamedTable') == 2 then
            self.NamedList = self.NamedAM
        elseif Config:GetSetting('NamedTable') == 3 then
            self.NamedList = self.NamedSM
        end
        local zoneName = mq.TLO.Zone.Name():lower()
        local shortZone = mq.TLO.Zone.ShortName():lower()
        for zone, data in pairs(self.NamedList) do
            if zone:lower() == zoneName or zone:lower() == shortZone then
                Nameds[shortZone] = {}
                for _, spawnName in pairs(data) do
                    table.insert(Nameds[shortZone], spawnName)
                end
            end
        end
    else
        Nameds = self.DefNamed
    end
    -- Force a refresh of the named cache so the UI updates
    self.LastZoneID = -1
    self:RefreshNamedCache()
end

--- Caches the named list in the zone
function Module:RefreshNamedCache()
    if self.LastZoneID ~= mq.TLO.Zone.ID() then
        self.LastZoneID = mq.TLO.Zone.ID()
        self.NamedList = {}
        local zoneName = mq.TLO.Zone.Name():lower()

        for _, n in ipairs(Nameds[zoneName] or {}) do
            self.NamedList[n] = true
        end

        zoneName = mq.TLO.Zone.ShortName():lower()

        for _, n in ipairs(Nameds[zoneName] or {}) do
            self.NamedList[n] = true
        end
    end
end

function Module:CheckZoneNamed()
    self:RefreshNamedCache()

    local tmpTbl = {}
    for name, _ in pairs(self.NamedList) do
        local spawn = mq.TLO.Spawn(string.format("NPC %s", name))
        table.insert(tmpTbl, { Name = name, Distance = spawn.Distance() or 9999, Spawn = spawn, })
    end

    table.sort(tmpTbl, function(a, b)
        return a.Distance < b.Distance
    end)

    self.CachedNamedList = tmpTbl
end

function Module:GetNamedList()
    return self.CachedNamedList
end

--- Checks if the given spawn is a named entity.
--- @param spawn MQSpawn The spawn object to check.
--- @return boolean True if the spawn is named, false otherwise.
function Module:IsNamed(spawn)
    if not spawn() then return false end
    self:RefreshNamedCache()

    if self.NamedList[spawn.Name()] or self.NamedList[spawn.CleanName()] then return true end

    --- @diagnostic disable-next-line: undefined-field
    if mq.TLO.Plugin("MQ2SpawnMaster").IsLoaded() and mq.TLO.SpawnMaster.HasSpawn ~= nil then
        --- @diagnostic disable-next-line: undefined-field
        return mq.TLO.SpawnMaster.HasSpawn(spawn.ID())()
    end

    return Targeting.ForceNamed
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
    Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
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

    if self.CommandHandlers[cmd:lower()] ~= nil then
        self.CommandHandlers[cmd:lower()].handler(self, params)
        handled = true
    end

    return handled
end

function Module:Shutdown()
    Logger.log_debug("Named Combat Module Unloaded.")
end

return Module
