-- Sample Named Class Module
local mq           = require('mq')
local Config       = require('utils.config')
local Globals      = require("utils.globals")
local Targeting    = require("utils.targeting")
local Ui           = require("utils.ui")
local Comms        = require("utils.comms")
local Logger       = require("utils.logger")
local Strings      = require("utils.strings")
local NamedDefault = require("namedlist.named_default")
local NamedEQMight = require("namedlist.named_eqmight")
local Base         = require("modules.base")

local Module       = { _version = '1.1', _name = "Named", _author = 'Derple, Algar, Grimmier', }
Module.__index     = Module
setmetatable(Module, { __index = Base, })

Module.CachedNamedList = {}

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

Module.FAQ             = {
    {
        Question = "Why am I not taking any special actions on a Named, boss, or mission mob?",
        Answer =
            "  RGMercs default class configs fully support burning, using defenses, or other special actions on Named mobs, however, your target must be indentified as such. There are three methods for doing so:\n\n" ..
            "  1) The Named List: RGMercs will consult the built-in Named List. If the mob is found on the list, it will be treated as a Named.\n\n" ..
            "  2) The SpawnMaster TLO: If the 'Check SM For Named' setting is enabled, and the MQ2SpawnMaster plugin is loaded (highly recommended), you can simply add a mob to the watch list (see '/spawnmaster help'). We will query SpawnMaster via built-in data reporting (TLO), and if the mob is present, treat it as a named.\n\n" ..
            "  3) The Alert Master TLO: If the 'Check AM For Named' setting is enabled, and the Alert Master script is loaded, you can simply add a mob to the alert list (see '/alertmaster help'). We will query Alert Master via built-in data reporting (TLO), and if the mob is present, treat it as a named.\n\n" ..
            "  Using these methods, it is very easy to treat mission bosses as named, even if they are not on the named list, whose source was typically aimed at typical PH/rare spawn style mobs.\n\n" ..
            "  Specific feedback on missing, incorrect, or otherwise erroneous entries on the RGMercs Named List is always welcome!\n\n",
        Settings_Used = "",
    },
}

function Module:New()
    return Base.New(self)
end

function Module:Render()
    Base.Render(self)

    ImGui.SameLine()
    ImGui.Text("Make any mob \"named\" for burns by adding it to your MQ2SpawnMaster or Alert Master list! See burn settings.")
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

    ---@diagnostic disable-next-line: undefined-field
    if Config:GetSetting('CheckSMForNamed') and mq.TLO.Plugin("MQ2SpawnMaster").IsLoaded() and mq.TLO.SpawnMaster.HasSpawn ~= nil and mq.TLO.SpawnMaster.HasSpawn(spawn.ID())() then return true end

    ---@diagnostic disable-next-line: undefined-field
    if Config:GetSetting('CheckAMForNamed') and mq.TLO.AlertMaster ~= nil and mq.TLO.AlertMaster.IsNamed(spawn.DisplayName())() then return true end

    return false
end

return Module
