-- SmartLoot Integration Module
local mq                 = require('mq')
local Config             = require('utils.config')
local Core               = require("utils.core")
local Casting            = require("utils.casting")
local Ui                 = require("utils.ui")
local Comms              = require("utils.comms")
local Strings            = require("utils.strings")
local Logger             = require("utils.logger")
local Targeting          = require("utils.targeting")
local Set                = require("mq.Set")
local Icons              = require('mq.ICONS')
local Module             = { _version = '1.0', _name = "SmartLoot", _author = 'andude2, Algar', }
Module.__index           = Module
Module.SettingCategories = {}
Module.SaveRequested     = nil

Module.ModuleLoaded      = false
Module.TempSettings      = {}

Module.FAQ               = {}
Module.ClassFAQ          = {}

Module.DefaultConfig     = {
	['UseSmartLoot']                           = {
		DisplayName = "Enable SmartLoot",
		Group = "General",
		Header = "Loot(Emu)",
		Category = "SmartLoot",
		Index = 1,
		Tooltip = "Enable SmartLoot integration for automated looting. SmartLoot must be running separately.",
		Default = false,
	},
	['SLMainLooter']                           = {
		DisplayName = "Set RG Main",
		Group = "General",
		Header = "Loot(Emu)",
		Category = "SmartLoot",
		Index = 1,
		Tooltip = "Set this toon as the main looter for smartloot.",
		Default = false,
	},
	['LootingTimeout']                         = {
		DisplayName = "Looting Timeout",
		Group = "General",
		Header = "Loot(Emu)",
		Category = "SmartLoot",
		Index = 4,
		Tooltip = "Maximum time in seconds to wait for SmartLoot to complete before continuing.",
		Default = 30,
		Min = 10,
		Max = 60,
	},
	['PullsYieldForLooting']                   = {
		DisplayName = "Hold Pulls for Looting",
		Group = "General",
		Header = "Loot(Emu)",
		Category = "SmartLoot",
		Index = 5,
		Tooltip = "Do not pull if this character currently has a pending loot decision, or if other peers are still currently looting via SmartLoot.",
		Default = false,
	},
	[string.format("%s_Popped", Module._name)] = {
		DisplayName = Module._name .. " Popped",
		Type = "Custom",
		Default = false,
	},
}

Module.FAQ               = {
}

Module.CommandHandlers   = {
	['slreset'] = {
		handler = function(self, params)
			Logger.log_info("\\ay[LOOT]: \\agManually resetting loot state")
			self.TempSettings.Looting = false
			self.TempSettings.LootStartTime = nil
			Logger.log_info("\\ay[LOOT]: \\agLoot state reset - RGMercs should resume normal operations")
		end,
		help = "Reset loot state if stuck waiting.",
	},
	-- ['slstatus'] = {
	-- 	handler = function(self, params)
	-- 		Logger.log_info("\\ay[LOOT]: \\ag=== Loot Module Status ===")
	-- 		Logger.log_info("\\ay[LOOT]: \\agLooting: %s", tostring(self.TempSettings.Looting))
	-- 		Logger.log_info("\\ay[LOOT]: \\agSmartLoot Ready: %s", tostring(self:IsSmartLootReady()))
	-- 		if self.TempSettings.LootStartTime then
	-- 			local elapsed = (mq.gettime() - self.TempSettings.LootStartTime) / 1000
	-- 			Logger.log_info("\\ay[LOOT]: \\agElapsed Time: %.1fs", elapsed)
	-- 		end

	-- 		-- Check SmartLoot status
	-- 		local success, slState, slMode = pcall(function()
	-- 			if smartLoot then
	-- 				return smartLoot.State() or "Unknown", smartLoot.Mode() or "Unknown"
	-- 			end
	-- 			return "Unknown", "Unknown"
	-- 		end)

	-- 		if success then
	-- 			Logger.log_info("\\ay[LOOT]: \\agSmartLoot State: %s (%s)", slState, slMode)
	-- 		else
	-- 			Logger.log_info("\\ay[LOOT]: \\arError reading SmartLoot status")
	-- 		end
	-- 	end,
	-- 	help = "Show current loot module status",
	-- },
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
		-- Initialize SmartLoot integration if enabled
		if Config:GetSetting('UseSmartLoot') then
			self:InitializeSmartLoot()
		end
	end

	if self.SaveRequested.doBroadcast == true then
		Comms.BroadcastUpdate(self._name, "LoadSettings")
	end

	Logger.log_debug("\ag%s Module settings saved to %s, requested %s ago.", self._name, getConfigFileName(), Strings.FormatTime(os.time() - self.SaveRequested.time))

	self.SaveRequested = nil
end

function Module:LoadSettings()
	Logger.log_debug("\ay[LOOT]: \atSmartLoot Integration Module Loading Settings for: %s.",
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

	Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)
end

function Module.New()
	local newModule = setmetatable({ settings = {}, }, Module)
	return newModule
end

function Module:Init()
	self:LoadSettings()
	if not Core.OnEMU() then
		Logger.log_debug("\ay[LOOT]: \agWe are not on EMU, unloading module. Build: %s",
			mq.TLO.MacroQuest.BuildName())
	else
		self:InitializeSmartLoot()
		Logger.log_debug("\ay[LOOT]: \agSmartLoot integration module loaded.")
	end

	return { self = self, defaults = self.DefaultConfig, categories = self.SettingCategories, }
end

function Module:ShouldRender()
	return Core.OnEMU()
end

function Module:GetSLState()
	---@diagnostic disable-next-line: undefined-field
	if not mq.TLO.SmartLoot then
		return "Unknown"
	end

	---@diagnostic disable-next-line: undefined-field
	return mq.TLO.SmartLoot.State()
end

function Module:GetSLMode()
	---@diagnostic disable-next-line: undefined-field
	if not mq.TLO.SmartLoot then
		return "Unknown"
	end

	---@diagnostic disable-next-line: undefined-field
	return mq.TLO.SmartLoot.Mode()
end

function Module:GetSLTLO()
	---@diagnostic disable-next-line: undefined-field
	if not mq.TLO.SmartLoot then
		return nil
	end

	---@diagnostic disable-next-line: undefined-field
	return mq.TLO.SmartLoot
end

function Module:IsLSLoaded()
	return mq.TLO.Lua.Script('smartloot').Status() == 'RUNNING'
end

function Module:Render()
	Ui.RenderPopAndSettings(self._name)
	-- SmartLoot status display
	local smartLootStatus = "Not Running"
	local statusColor = { 1.0, 0.3, 0.3, 1.0, } -- Red

	if self:IsSmartLootReady() then
		if self:IsLSLoaded() then
			smartLootStatus = string.format("%s (%s)", self:GetSLState(), self:GetSLMode())
			statusColor = { 0.3, 1.0, 0.3, 1.0, } -- Green
		else
			smartLootStatus = "SmartLoot Not Running"
			statusColor = { 1.0, 1.0, 0.3, 1.0, } -- Yellow
		end
	end

	ImGui.TextColored(statusColor[1], statusColor[2], statusColor[3], statusColor[4], "SmartLoot Status: " .. smartLootStatus)
	ImGui.NewLine()

	ImGui.Text("This module integrates with SmartLoot for automated looting.")
	ImGui.Text("SmartLoot must be running separately: /lua run smartloot")
end

function Module:Pop()
	Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

-- Initialize SmartLoot integration
function Module:InitializeSmartLoot()
	if not Config:GetSetting('UseSmartLoot') then
		self.useSmartLoot = false
		return
	end

	-- Check for SmartLoot availability
	local smartLootScript = mq.TLO.Lua.Script('smartloot')
	if smartLootScript and smartLootScript.Status() == 'RUNNING' then
		self.useSmartLoot = true
		Logger.log_info("\ay[LOOT]: \agSmartLoot integration enabled, please ensure you have a Main Looter set!")
		if Config:GetSetting('SLMainLooter') then
			Core.DoCmd('/sl_mode rgmain')
			Logger.log_info("Loot: Setting this character as the main looter for SmartLoot.")
		end
		self.smartLootInitialized = true
	else
		self.useSmartLoot = false
		self.smartLootInitialized = false
	end
end

-- Check if SmartLoot is available and ready
function Module:IsSmartLootReady()
	if not self.useSmartLoot then
		-- Try to re-initialize if settings allow it
		if Config:GetSetting('UseSmartLoot') then
			self:InitializeSmartLoot()
		end
		return self.useSmartLoot
	end

	-- -- Verify SmartLoot is still running (commented cuz mercs gets closed if it isnt)
	-- local smartLootStatus = mq.TLO.Lua.Script('smartloot')
	-- if not smartLootStatus or smartLootStatus.Status() ~= 'RUNNING' then
	-- 	self.useSmartLoot = false
	-- 	self.smartLootInitialized = false
	-- 	return false
	-- end

	-- Ensure SmartLoot mode is set correctly if not already done
	if not self.smartLootInitialized then
		self:InitializeSmartLoot()
		self.smartLootInitialized = true
	end

	return true
end

-- Trigger SmartLoot to process corpses
function Module:DoLoot()
	-- Trigger SmartLoot RGMain processing
	if Config:GetSetting('SLMainLooter') then
		Logger.log_debug("\ay[LOOT]: \agTriggering SmartLoot RGMain processing")
		mq.cmd('/sl_rg_trigger')
	end

	-- Mark that we've initiated looting
	self.TempSettings.LootStartTime = mq.gettime()
	self.TempSettings.Looting = true

	return true
end

-- Wait for SmartLoot to complete with proper focus holding
function Module:ProcessLooting(combat_state)
	if not self.TempSettings.Looting then
		return
	end

	local timeoutMs = Config:GetSetting('LootingTimeout') * 1000
	local startTime = self.TempSettings.LootStartTime or mq.gettime()

	-- Hold focus in loot module while SmartLoot is working
	while self.TempSettings.Looting do
		local elapsed = mq.gettime() - startTime

		-- Check for timeout
		if elapsed > timeoutMs then
			Logger.log_warn("\ay[LOOT]: \arLooting timeout reached (%d seconds) - continuing", Config:GetSetting('LootingTimeout'))
			self.TempSettings.Looting = false
			break
		end

		-- Check for combat and abort if needed
		if combat_state == 'Combat' or self:GetSLState() == "Combat Detected" then
			Logger.log_debug("\ay[LOOT]: \arCombat detected - aborting looting")
			if mq.TLO.Window("LootWnd").Open() then
				mq.TLO.Window("LootWnd").DoClose()
			end
			self.TempSettings.Looting = false
			break
		end

		if self:GetSLState() == "Idle" or self:GetSLState() == "WaitingForInventorySpace" then -- we dont need to check for the TLO because it will close mercs if it isn't there
			Logger.log_verbose("\ay[LOOT]: \agSmartLoot processing complete (%.1fs elapsed)", elapsed / 1000)
			self.TempSettings.Looting = false
			break
		end

		-- Small delay to not hammer the CPU
		mq.delay(50)
		mq.doevents()
	end

	Logger.log_verbose("\ay[LOOT]: \agFinished Processing Loot.")
end

function Module:GiveTime(combat_state)
	if not Config:GetSetting('UseSmartLoot') then return end
	if not self:GetSLTLO() or not self:GetSLTLO().IsEnabled() then return end
	if Config.Globals.PauseMain then return end

	if not Core.OkayToNotHeal() or mq.TLO.Me.Invis() or Casting.IAmFeigning() then return end

	-- Check if we should initiate looting
	if not self:IsSmartLootReady() then
		return
	end

	-- Check for corpses using SmartLoot
	if self.TempSettings.Looting or (self:GetSLTLO() and (self:GetSLTLO().HasNewCorpses() and self:GetSLTLO().SafeToLoot())) then
		if self:DoLoot() then
			Logger.log_verbose("\ay[LOOT]: \agInitiated SmartLoot processing")
			-- Process looting immediately
			self:ProcessLooting(combat_state)
		end
	end

	Config.Globals.SLPeerLooting = self:GetSLTLO().AnyPeerLooting()
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
	Logger.log_debug("\ay[LOOT]: \axSmartLoot Integration Module Unloaded.")
	-- Clear any pending loot state
	self.TempSettings.Looting = false
	self.TempSettings.LootStartTime = nil
end

-- for algar reference, ignore for now

-- Module.SmartLootEngineLootState = {
-- 	Idle = 1,
-- 	FindingCorpse = 2,
-- 	NavigatingToCorpse = 3,
-- 	OpeningLootWindow = 4,
-- 	ProcessingItems = 5,
-- 	WaitingForPendingDecision = 6,
-- 	ExecutingLootAction = 7,
-- 	CleaningUpCorpse = 8,
-- 	ProcessingPeers = 9,
-- 	OnceModeCompletion = 10,
-- 	CombatDetected = 11,
-- 	EmergencyStop = 12,
-- 	WaitingForWaterfallCompletion = 13,
-- 	WaitingForInventorySpace = 14,
-- }

return Module
