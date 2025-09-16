-- Sample Basic Class Module
local mq                 = require('mq')
local Config             = require('utils.config')
local Core               = require("utils.core")
local Casting            = require("utils.casting")
local Ui                 = require("utils.ui")
local Comms              = require("utils.comms")
local Strings            = require("utils.strings")
local Logger             = require("utils.logger")
local Actors             = require("actors")
local Set                = require("mq.Set")
local Icons              = require('mq.ICONS')
-- Server name formatted for LNS to recognize
local serverLNSFormat    = mq.TLO.EverQuest.Server():gsub(" ", "_")
local warningMessageSent = false

local Module             = { _version = '1.1 for LNS', _name = "Loot", _author = 'Derple, Grimmier, Algar', }
Module.__index           = Module
Module.SettingCategories = {}
Module.SaveRequested     = nil

Module.ModuleLoaded      = false
Module.TempSettings      = {}

Module.FAQ               = {}
Module.ClassFAQ          = {}

Module.DefaultConfig     = {
	['DoLoot']                                 = {
		DisplayName = "Load LootNScoot",
		Category = "Loot N Scoot",
		Index = 1,
		Tooltip = "Load the integrated LootNScoot in directed mode. Turning this off will unload the looting script.",
		Default = false,
		FAQ = "What is this silver coin thing? How do I turn it off?",
		Answer = "The silver coin is our integration of LootNScoot, looting automation for Emu. It can be disabled as you choose.",
	},
	['CombatLooting']                          = {
		DisplayName = "Combat Looting",
		Category = "Loot N Scoot",
		Index = 2,
		Tooltip = "Enables looting during RGMercs-defined combat.",
		Default = false,
		FAQ = "How do i make sure my guys are looting during combat?, incase I die or something.",
		Answer = "You can enable [CombatLooting] to loot during combat, I recommend only having one or 2 characters do this and NOT THE MA!!.",
	},
	['LootRespectMedState']                    = {
		DisplayName = "Respect Med State",
		Category = "Loot N Scoot",
		Index = 3,
		Tooltip = "Hold looting if you are currently meditating.",
		Default = false,
		FAQ = "Why is the PC sitting there and not medding?",
		Answer =
		"If you turn on Respect Med State in the Group Watch options, your looter will remain medding until those thresholds are reached.\nIf Stand When Done is not enabled, the looter may continue to sit after those thresholds are reached.",
	},
	['LootingTimeout']                         = {
		DisplayName = "Looting Timeout",
		Category = "Loot N Scoot",
		Index = 4,
		Tooltip = "The length of time in seconds that RGMercs will allow LNS to process loot actions in a single check.",
		Default = 5,
		Min = 1,
		Max = 30,
		FAQ = "Why do my guys take too long to loot, or sometimes miss corpses?",
		Answer =
			"While RGMercs doesn't necessary control what LNS is doing, exactly, we do have a timeout setting that dictates how long we will allow it to do it before re-checking for other actions. \n" ..
			"You can adjust this advanced setting in the Loot options. Please note, if no other actions are required by mercs, we will simply allow LNS to continue.",
	},
	['MaxChaseTargetDistance']                 = {
		DisplayName = "Max Chase Targ Dist",
		Category = "Loot N Scoot",
		Index = 4,
		Tooltip = "If chase is on, we won't loot (and will abort looting) any corpses when the chase target is farther than this value away from us.",
		Default = 300,
		Min = 1,
		Max = 20000,
	},
	[string.format("%s_Popped", Module._name)] = {
		DisplayName = Module._name .. " Popped",
		Type = "Custom",
		Category = "Custom",
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

Module.SettingCategories = Set.new({})
for k, v in pairs(Module.DefaultConfig or {}) do
	if v.Type ~= "Custom" then
		Module.SettingCategories:add(v.Category)
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
	self.SaveRequested = { time = os.time(), broadcast = doBroadcast or false, }
end

function Module:WriteSettings()
	if not self.SaveRequested then return end
	mq.pickle(getConfigFileName(), Config:GetModuleSettings(self._name))

	if self.SettingsLoaded then
		if Config:GetSetting('DoLoot') == true then
			if mq.TLO.Lua.Script('lootnscoot').Status() ~= 'RUNNING' then
				Core.DoCmd("/lua run lootnscoot directed rgmercs")
				warningMessageSent = false
			end

			if not self.Actor then Module:LootMessageHandler() end

			self.Actor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', },
				{ who = Config.Globals.CurLoadedChar, server = serverLNSFormat, directions = 'combatlooting', CombatLooting = Config:GetSetting('CombatLooting'), })
		else
			Core.DoCmd("/lua stop lootnscoot")
		end
	end

	if self.SaveRequested.doBroadcast == true then
		Comms.BroadcastUpdate(self._name, "LoadSettings")
	end

	Logger.log_debug("\ag%s Module settings saved to %s, requested %s ago.", self._name, getConfigFileName(), Strings.FormatTime(os.time() - self.SaveRequested.time))

	self.SaveRequested = nil
end

function Module:LoadSettings()
	Logger.log_debug("\ay[LOOT]: \atLootnScoot EMU, Loot Module Loading Settings for: %s.",
		Config.Globals.CurLoadedChar)
	local settings_pickle_path = getConfigFileName()
	local settings = {}
	local firstSaveRequired = false


	local config, err = loadfile(settings_pickle_path)
	if err or not config then
		Logger.log_error("\ay[LOOT]: \aoUnable to load global settings file(%s), creating a new one!",
			settings_pickle_path)
		firstSaveRequired = true
	else
		settings = config()
	end

	Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.SettingCategories, firstSaveRequired)
end

function Module.New()
	local newModule = setmetatable({}, Module)
	return newModule
end

function Module:Init()
	self:LoadSettings()
	self:LootMessageHandler()
	if not Core.OnEMU() then
		Logger.log_debug("\ay[LOOT]: \agWe are not on EMU unloading module. Build: %s",
			mq.TLO.MacroQuest.BuildName())
	else
		if Config:GetSetting('DoLoot') then
			if mq.TLO.Lua.Script('lootnscoot').Status() == 'RUNNING' then
				Core.DoCmd("/lua stop lootnscoot")
				mq.delay(1000, function() return mq.TLO.Lua.Script('lootnscoot').Status() ~= 'RUNNING' end)
			end
			Core.DoCmd("/lua run lootnscoot directed rgmercs")
			self.Actor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', },
				{ who = Config.Globals.CurLoadedChar, server = serverLNSFormat, directions = 'getcombatsetting', })
		end
		self.TempSettings.Looting = false
		--pass settings to lootnscoot lib
		Logger.log_debug("\ay[LOOT]: \agLoot for EMU module Loaded.")
	end

	return { self = self, defaults = self.DefaultConfig, categories = self.SettingCategories, }
end

function Module:ShouldRender()
	return Core.OnEMU()
end

function Module:Render()
	Ui.RenderPopSetting(self._name)

	if ImGui.CollapsingHeader("Config Options") then
		Ui.RenderModuleSettings(self._name, self.DefaultConfig, self.SettingCategories)
	end
end

function Module:Pop()
	Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Module.DoLooting(combat_state)
	if not Module.TempSettings.Looting then return end

	local maxWait = Config:GetSetting('LootingTimeout') * 1000
	while Module.TempSettings.Looting do
		if combat_state == "Combat" and not Config:GetSetting('CombatLooting') then
			Logger.log_debug("\ay[LOOT]: Aborting Actions due to combat!")
			if mq.TLO.Window('LootWnd').Open() then mq.TLO.Window('LootWnd').DoClose() end
			Module.TempSettings.Looting = false
			break
		end

		if not Module:CheckChaseTargetInRange() then
			Logger.log_debug("\ay[LOOT]: Aborting Actions due to chase target distance!")
			Module.TempSettings.Looting = false
			break
		end

		mq.delay(20, function() return not Module.TempSettings.Looting end)

		maxWait = maxWait - 20

		if maxWait <= 0 then
			Logger.log_debug("\ay[LOOT]: Aborting Actions due to timeout.")
			Module.TempSettings.Looting = false
			break
		end
		mq.doevents()
	end
	Logger.log_verbose("\ay[LOOT]: \atFinished or Aborted Looting: \agResuming")
end

function Module:LootMessageHandler()
	self.Actor = Actors.register('loot_module', function(message)
		local mail = message()
		local subject = mail.Subject or ''
		local who = mail.Who or ''
		local CombatLooting = mail.CombatLooting or false
		local currSetting = Config:GetSetting('CombatLooting')

		if who ~= Config.Globals.CurLoadedChar then return end

		if currSetting ~= CombatLooting then
			Config:SetSetting('CombatLooting', CombatLooting)
		end

		if subject == ('done_looting' or 'done_processing') then
			Module.TempSettings.Looting = false
		elseif subject == 'processing' then
			Module.TempSettings.Looting = true
		end
	end)
end

function Module:CheckChaseTargetInRange()
	if Config:GetSetting('ChaseOn') then
		local chaseSpawn = mq.TLO.Spawn("pc =" .. Core.GetChaseTarget())
		if chaseSpawn() and (chaseSpawn.Distance3D() or 0) > Config:GetSetting('MaxChaseTargetDistance') then
			return false
		end
	end
	return true
end

function Module:GiveTime(combat_state)
	if not Config:GetSetting('DoLoot') then return end
	if Config.Globals.PauseMain then return end
	if mq.TLO.Lua.Script('lootnscoot').Status() ~= 'RUNNING' then
		if not warningMessageSent then
			Logger.log_error("\ar[LOOT]: Looting is enabled, but LNS does not appear to be running!")
			Comms.PrintGroupMessage("%s has looting enabled, but LNS does not appear to be running!", mq.TLO.Me.CleanName())
			warningMessageSent = true
		end
		return
	end

	if not Core.OkayToNotHeal() or mq.TLO.Me.Invis() or Casting.IAmFeigning() then return end

	if not self:CheckChaseTargetInRange() then
		Logger.log_super_verbose("\ay::LOOT:: \arAborted!\ax Chase Target too far away.")
		return
	end

	if Config:GetSetting('LootRespectMedState') and Config.Globals.InMedState then
		Logger.log_super_verbose("\ay::LOOT:: \arAborted!\ax Meditating.")
		return
	end

	local deadCount = mq.TLO.SpawnCount("npccorpse radius 100 zradius 50")()
	local myCorpseCount = mq.TLO.SpawnCount(string.format("pccorpse %s radius 100 zradius 50", mq.TLO.Me.CleanName()))()
	if myCorpseCount > 0 then deadCount = deadCount + 1 end

	if self.Actor == nil then self:LootMessageHandler() end
	-- send actors message to loot
	if (combat_state ~= "Combat" or Config:GetSetting('CombatLooting')) and deadCount > 0 then
		if not self.TempSettings.Looting then
			self.Actor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', },
				{ who = Config.Globals.CurLoadedChar, server = serverLNSFormat, directions = 'doloot', })
			self.TempSettings.Looting = true
		end
	end

	if self.TempSettings.Looting then
		Logger.log_verbose("\ay[LOOT]: \aoPausing for \atLoot Actions")
		Module.DoLooting(combat_state)
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
	Core.DoCmd("/lua stop lootnscoot")
end

return Module
