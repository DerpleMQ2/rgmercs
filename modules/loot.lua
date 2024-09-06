-- Sample Basic Class Module
local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")
local Set         = require("mq.Set")

local LootnScoot  = require('lib.lootnscoot')


local Module             = { _version = '0.1a', _name = "Loot", _author = 'Derple, Grimmier', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultCategories = {}

Module.ModuleLoaded      = false
Module.CombatState       = "None"

Module.TempSettings      = {}

Module.DefaultConfig     = {
	['DoLoot'] = { DisplayName = "Use Loot N Scoot", Category = "Loot N Scoot", Tooltip = "Use Loot N Scoot", Default = true, },
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

	if doBroadcast == true then
		RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
	end
end

function Module:LoadSettings()
	RGMercsLogger.log_debug("Basic EMU Loot Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
	local settings_pickle_path = getConfigFileName()

	local config, err = loadfile(settings_pickle_path)
	if err or not config then
		RGMercsLogger.log_error("\ay[Basic]: Unable to load global settings file(%s), creating a new one!",
			settings_pickle_path)
		self.settings.MyCheckbox = false
		self:SaveSettings(false)
	else
		self.settings = config()
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
	local path = mq.luaDir
	RGMercsLogger.log_debug("Loot for EMU module Loaded.")
	self:LoadSettings()
	if not self.settings.DoLoot then LootnScoot = nil end


	return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
	return RGMercConfig.Globals.BuildType == "Emu"
end

function Module:Render()
	ImGui.Text("EMU Loot")
	local pressed
	self.settings, pressed, _ = RGMercUtils.RenderSettings(self.settings, self.DefaultConfig,
		self.DefaultCategories)
	if pressed then
		self:SaveSettings(false)
	end
end

function Module:GiveTime(combat_state)
	-- Main Module logic goes here.
	if self.CombatState ~= combat_state and combat_state == "Downtime" then
		if LootnScoot ~= nil and self.settings.DoLoot then
			LootnScoot.lootMobs()
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
	RGMercsLogger.log_debug("EMU Loot Module Unloaded.")
end

return Module
