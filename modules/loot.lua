-- Sample Basic Class Module
local mq                 = require('mq')
local Config             = require('utils.config')
local Core               = require("utils.core")
local Targeting          = require("utils.targeting")
local Ui                 = require("utils.ui")
local Comms              = require("utils.comms")
local Strings            = require("utils.strings")
local Logger             = require("utils.logger")
local Actors             = require("actors")
local Set                = require("mq.Set")
local Icons              = require('mq.ICONS')
local LootnScootDir      = string.format("\"%s/rgmercs/lib/lootnscoot\"", mq.luaDir)

local sNameStripped      = string.gsub(mq.TLO.EverQuest.Server(), ' ', '_')

local Module             = { _version = '0.1a', _name = "Loot", _author = 'Derple, Grimmier, Aquietone (lootnscoot lua)', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultCategories = {}

Module.ModuleLoaded      = false
Module.TempSettings      = {}

Module.FAQ               = {}
Module.ClassFAQ          = {}

Module.DefaultConfig     = {
	['DoLoot']                                 = {
		DisplayName = "DoLoot",
		Category = "Loot N Scoot",
		Tooltip = "Enables Loot Settings for Looting",
		Default = true,
		FAQ = "Why are my goobers not looting?",
		Answer = "You most likely have [DoLoot] turned off.",
	},
	[string.format("%s_Popped", Module._name)] = {
		DisplayName = Module._name .. " Popped",
		Category = "Loot N Scoot",
		Tooltip = Module._name .. " Pop Out Into Window",
		Default = false,
		FAQ = "Can I pop out the " .. Module._name .. " module into its own window?",
		Answer = "You can pop out the " .. Module._name .. " module into its own window by toggeling loot_Popped",
	},
}

Module.FAQ               = {
	[1] = {
		Questions = "How can I set the same settings on all of my characters?",
		Answer = "You can copy your Loot_Server_Name_CharName_CLASS.lua and rename them for the other characters.\n\n" ..
			"Example: Loot_Project_Lazarus_Grimmier_CLR.lua\n\n" ..
			"We may add an option at a later date to copy settings from one character to another directly.",
		Settings_Used = "DoLoot",
	},
	[2] = {
		Question = "What is the difference between GlobalItem and NormalItem?",
		Answer =
			"GlobalItem is a setting that will always be used for that item.\nNormalItem is a setting that will be used for that item unless it is set as a GlobalItem.\n" ..
			"NormalItem settings are evaluated each time if you have [AlwaysEval] turned on, which can change your setting if the item no longer meets the criteria.\n" ..
			"Setting an items as a GlobalItem will prevent it from being re-evaluated and always use the GlobalItem setting.",
		Settings_Used = "GlobalLootOn",
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
		'/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. Config.Globals.CurLoadedChar ..
		"_" .. Config.Globals.CurLoadedClass .. '.lua'
end

function Module:SaveSettings(doBroadcast)
	mq.pickle(getConfigFileName(), self.settings)
	if self.settings.DoLoot == true then
		local lnsRunning = mq.TLO.Lua.Script('lootnscoot').Status() == 'RUNNING' or false
		if lnsRunning then
			Core.DoCmd("/lua stop lootnscoot")
		end
		Core.DoCmd("/lua run %s directed", LootnScootDir)
	else
		Core.DoCmd("/lua stop %s", LootnScootDir)
	end
	if doBroadcast == true then
		Comms.BroadcastUpdate(self._name, "LoadSettings")
	end
end

function Module:LoadSettings()
	Logger.log_debug("\ay[LOOT]: \atLootnScoot EMU, Loot Module Loading Settings for: %s.",
		Config.Globals.CurLoadedChar)
	local settings_pickle_path = getConfigFileName()

	local config, err = loadfile(settings_pickle_path)
	if err or not config then
		Logger.log_error("\ay[LOOT]: \aoUnable to load global settings file(%s), creating a new one!",
			settings_pickle_path)
		self.settings.MyCheckbox = false
		self:SaveSettings(false)
	else
		self.settings = config()
	end

	local needsSave = false
	self.settings, needsSave = Config.ResolveDefaults(Module.DefaultConfig, self.settings)

	Logger.log_debug("Settings Changes = %s", Strings.BoolToColorString(needsSave))
	if needsSave then
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
	self:LoadSettings()
	if not Core.OnEMU() then
		Logger.log_debug("\ay[LOOT]: \agWe are not on EMU unloading module. Build: %s",
			mq.TLO.MacroQuest.BuildName())
	else
		if self.settings.DoLoot then
			local lnsRunning = mq.TLO.Lua.Script('lootnscoot').Status() == 'RUNNING' or false
			if lnsRunning then
				Core.DoCmd("/lua stop lootnscoot")
			end
			Core.DoCmd("/lua run %s directed", LootnScootDir)
			self:LootMessageHandler()
		end
		self.TempSettings.Looting = false
		--pass settings to lootnscoot lib
		Logger.log_debug("\ay[LOOT]: \agLoot for EMU module Loaded.")
	end

	return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
	return Core.OnEMU()
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
	local pressed = false
	if ImGui.CollapsingHeader("Config Options") then
		self.settings, pressed, _ = Ui.RenderSettings(self.settings, self.DefaultConfig,
			self.DefaultCategories)
		if pressed then
			self:SaveSettings(false)
		end
	end
end

function Module:Pop()
	self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
	self:SaveSettings(false)
end

function Module.DoLooting()
	while (Module.TempSettings.Looting) do
		mq.delay(100, function() return not Module.TempSettings.Looting end)
	end
	Logger.log_debug("\ay[LOOT]: \agLoot Finishing Resuming:")
end

function Module.LootMessageHandler()
	Module.Actor = Actors.register('loot_module', function(message)
		local mail = message()
		local subject = mail.Subject or ''
		local who = mail.Who or ''
		if subject == "done_looting" and who == Config.Globals.CurLoadedChar then
			Module.TempSettings.Looting = false
			Module.DoLooting()
		end
	end)
end

function Module:GiveTime()
	if not Config:GetSetting('DoLoot') then return end
	if Module.Actor == nil then self:LootMessageHandler() end
	-- send actors message to loot
	if not self.TempSettings.Looting then
		Module.Actor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', },
			{ who = Config.Globals.CurLoadedChar, directions = 'doloot', })
		self.TempSettings.Looting = true
		Logger.log_debug("\ay[LOOT]: \agLoot Paused for Looting:")
	end
	Module.DoLooting()
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
	return { module = self._name, CommandHandlers = self.CommandHandlers, }
end

function Module:GetFAQ()
	return {
		module = self._name,
		FAQ = self.FAQ or {},
	}
end

function Module:GetClassFAQ()
	return {
		module = self._name,
		FAQ = self.ClassFAQ or {},
	}
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
	Logger.log_debug("\ay[LOOT]: \axEMU Loot Module Unloaded.")
	Core.DoCmd("/lua stop %s", LootnScootDir)
end

return Module
