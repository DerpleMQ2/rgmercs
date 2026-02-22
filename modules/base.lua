local mq           = require('mq')
local Config       = require('utils.config')
local Ui           = require("utils.ui")
local Comms        = require("utils.comms")
local Logger       = require("utils.logger")
local Strings      = require("utils.strings")
local Globals      = require("utils.globals")
local Tables       = require("utils.tables")
local Modules      = require("utils.modules")

local Base         = { _version = '1.0', _name = "RGMercsBaseBaseClass", _author = 'Derple', }
Base.__index       = Base
Base.SaveRequested = nil
Base.ModuleLoaded  = false
-- Tables must be defined in sub classes to avoid caching issues across modules

function Base:New()
    local newBase = setmetatable({}, self)
    return newBase
end

function Base:SaveSettings(doBroadcast)
    self.SaveRequested = { time = Globals.GetTimeSeconds(), broadcast = doBroadcast or false, }
end

function Base:IsSaveRequested()
    return self.SaveRequested ~= nil
end

function Base:WriteSettings()
    if not self.SaveRequested then return end

    local configFile = Config.GetConfigFileName(self._name)

    mq.pickle(configFile, Config:GetModuleSettings(self._name))

    if self.SaveRequested.doBroadcast == true then
        Comms.BroadcastMessage(self._name, "LoadSettings")
    end

    Logger.log_debug("\ag%s Base settings saved to %s, requested %s ago.", self._name, configFile,
        Strings.FormatTime(Globals.GetTimeSeconds() - self.SaveRequested.time))

    self.SaveRequested = nil
end

function Base:LoadSettings(preLoadFn, postLoadFn)
    local configFile = Config.GetConfigFileName(self._name)

    Logger.log_info("\aw[\atLoading Settings\aw] Character: \am%s \awModule: \ay%s \awFile: \at%s", Globals.CurLoadedChar, self._name, configFile)
    local settings = {}
    local firstSaveRequired = false

    if preLoadFn then
        preLoadFn()
    end

    local config, err = loadfile(configFile)
    if err or not config then
        Logger.log_error("\aw[\atLoading Settings\aw] \arUnable to load global settings file(%s), creating a new one!",
            configFile)
        firstSaveRequired = true
    else
        settings = config()
    end

    if postLoadFn then
        postLoadFn(settings)
    end

    Config:RegisterModuleSettings(self._name, settings, self.ClassConfig and self.ClassConfig.DefaultConfig or self.DefaultConfig, self.FAQ, firstSaveRequired)
end

function Base:Init()
    Logger.log_debug("\aw[\atInitiailize\aw] \am%s Module.", self._name)
    self:LoadSettings()

    self.ModuleLoaded = true
end

function Base:ShouldRender()
    return true
end

function Base:Render()
    return Ui.RenderPopAndSettings(self._name)
end

function Base:Pop()
    Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Base:GiveTime()
end

function Base:OnDeath()
    -- Death Handler
end

function Base:OnZone()
    -- Zone Handler
end

function Base:OnCombatModeChanged()
end

function Base:DoGetState()
    return "Running..."
end

function Base:GetCommandHandlers()
    return { Module = self._name, CommandHandlers = self.CommandHandlers, }
end

function Base:GetFAQ()
    return { Module = self._name, FAQ = self.FAQ or {}, }
end

---@param cmd string
---@param ... string
---@return boolean
function Base:HandleBind(cmd, ...)
    local params = ...

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

function Base:Shutdown()
    Logger.log_debug("\aw[\atShutdown\aw] \am%s Module Unloaded.", self._name)
end

return Base
