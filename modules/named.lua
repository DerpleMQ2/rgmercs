-- Sample Named Class Module
local mq               = require('mq')
local Config           = require('utils.config')
local Globals          = require("utils.globals")
local Targeting        = require("utils.targeting")
local Ui               = require("utils.ui")
local Comms            = require("utils.comms")
local Logger           = require("utils.logger")
local Strings          = require("utils.strings")
local NamedDefault     = require("namedlist.named_default")
local NamedEQMight     = require("namedlist.named_eqmight")

local Module           = { _version = '1.1', _name = "Named", _author = 'Derple, Algar, Grimmier', }
Module.__index         = Module
Module.DefaultConfig   = {}
Module.CachedNamedList = {}
Module.SaveRequested   = nil

Module.NamedList       = {}
Module.LastNamedCheck  = 0

Module.DefNamed        = Globals.CurServer == "EQ Might" and (NamedEQMight or {}) or (NamedDefault or {})


Module.DefaultConfig   = {
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Default = false,
    },
}

Module.CommandHandlers = {

}

Module.FAQ             = {
    {
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
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. Globals.CurServerNormalized .. "_" .. Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    self.SaveRequested = { time = Globals.GetTimeSeconds(), broadcast = doBroadcast or false, }
end

function Module:WriteSettings()
    if not self.SaveRequested then return end

    mq.pickle(getConfigFileName(), Config:GetModuleSettings(self._name))

    if self.SaveRequested.doBroadcast == true then
        Comms.BroadcastMessage(self._name, "LoadSettings")
    end

    Logger.log_debug("\ag%s Module settings saved to %s, requested %s ago.", self._name, getConfigFileName(), Strings.FormatTime(Globals.GetTimeSeconds() - self.SaveRequested.time))

    self.SaveRequested = nil
end

function Module:LoadSettings()
    self.NamedList = {}
    Logger.log_debug("Named Module Loading Settings for: %s.", Globals.CurLoadedChar)
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
end

function Module:GiveTime()
    -- Main Module logic goes here.
    if Globals.GetTimeSeconds() - self.LastNamedCheck > 1 then
        self.LastNamedCheck = Globals.GetTimeSeconds()
        self:CheckZoneNamed()
    end
end

function Module:OnDeath()
    -- Death Handler
end

--- Caches the named list in the zone
function Module:RefreshNamedCache()
    if self.LastZoneID ~= mq.TLO.Zone.ID() then
        self.LastZoneID = mq.TLO.Zone.ID()
        self.NamedList = {}
        local zoneName = mq.TLO.Zone.Name():lower()

        for _, n in ipairs(self.DefNamed[zoneName] or {}) do
            self.NamedList[n] = true
        end

        zoneName = mq.TLO.Zone.ShortName():lower()

        for _, n in ipairs(self.DefNamed[zoneName] or {}) do
            self.NamedList[n] = true
        end
    end
end

function Module:CheckZoneNamed()
    self:RefreshNamedCache()

    local tmpTbl = {}
    for name, _ in pairs(self.NamedList) do
        local spawnList = mq.getFilteredSpawns(function(spawn) return spawn.CleanName() == name and spawn.Type() == "NPC" end)
        local spawn = spawnList[1]
        table.insert(tmpTbl, { Name = name, Spawn = spawn, Distance = spawn and spawn.Distance() or 9999, Loc = spawn and spawn.LocYXZ() or "0,0,0", })
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
    if not spawn or not spawn() then return false end

    if Targeting.ForceNamed then return true end

    self:RefreshNamedCache()

    if self.NamedList[spawn.Name()] or self.NamedList[spawn.CleanName()] then return true end

    if mq.TLO.Plugin("MQ2SpawnMaster").IsLoaded() then
        ---@diagnostic disable-next-line: undefined-field
        return mq.TLO.SpawnMaster.HasSpawn(spawn.ID())() or false
    end

    return false
end

function Module:OnZone()
    self:RefreshNamedCache()
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
        return true
    end

    -- try to process as a substring
    for bindCmd, bindData in pairs(self.CommandHandlers or {}) do
        if Strings.StartsWith(bindCmd, cmd) then
            bindData.handler(self, params)
            return true
        end
    end

    return false
end

function Module:Shutdown()
    Logger.log_debug("Named Combat Module Unloaded.")
end

return Module
