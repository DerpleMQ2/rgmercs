-- Sample Basic Class Module
local mq                 = require('mq')
local Config             = require('utils.config')
local Core               = require("utils.core")
local Casting            = require("utils.casting")
local Ui                 = require("utils.ui")
local Comms              = require("utils.comms")
local Strings            = require("utils.strings")
local Logger             = require("utils.logger")
local Files              = require("utils.files")
local Actors             = require("actors")
local Set                = require("mq.Set")
local Icons              = require('mq.ICONS')
local LootnScootPath     = string.format("%s/lootnscoot/init.lua", mq.luaDir)
local bundleScriptPath   = string.format("rgmercs/lib/lootnscoot")
local LootScript         = "lootnscoot"
local hasLootnScoot      = Files.file_exists(LootnScootPath)
local url                = "https://www.redguides.com/community/resources/lootnscoot-for-emu.2675/"

local Module             = { _version = '0.1a', _name = "Loot", _author = 'Derple, Grimmier, Aquietone (lootnscoot lua)', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultCategories = {}
Module.ModuleLoaded      = false
Module.TempSettings      = {}

Module.FAQ               = {}
Module.ClassFAQ          = {}

Module.DefaultConfig     = {
	['UseBundled']                             = {
		DisplayName = "Use Bundled LootNScoot",
		Category = "Loot N Scoot",
		Index = 1,
		Tooltip = "Use the bundled LootNScoot script instead of the one installed in your MQ Lua directory.",
		Default = not hasLootnScoot,
		FAQ = "What is this silver coin thing? How do I turn it off?",
		Answer = "The silver coin is our integration of LootNScoot, looting automation for Emu. It can be disabled as you choose.",
	},
	['DoLoot']                                 = {
		DisplayName = "Load LootNScoot",
		Category = "Loot N Scoot",
		Index = 2,
		Tooltip = "Load the integrated LootNScoot in directed mode. Turning this off will unload the looting script.",
		Default = true,
		FAQ = "What is this silver coin thing? How do I turn it off?",
		Answer = "The silver coin is our integration of LootNScoot, looting automation for Emu. It can be disabled as you choose.",
	},
	['LootCorpses']                            = {
		DisplayName = "Loot Corpses",
		Category = "Loot N Scoot",
		Index = 3,
		Tooltip = "Enable LootNScoot to loot corpses for you.",
		Default = true,
		FAQ = "I have LootNScoot loaded, why am I not looting?",
		Answer = "Ensure you have enabled Loot Corpses, and note that Combat Looting is the setting that controls looting while in combat.",
	},
	['CombatLooting']                          = {
		DisplayName = "Combat Looting",
		Category = "Loot N Scoot",
		Index = 4,
		Tooltip = "Enables looting during combat.",
		Default = false,
		FAQ = "How do i make sure my guys are looting during combat?, incase I die or something.",
		Answer = "You can enable [CombatLooting] to loot during combat, I recommend only having one or 2 characters do this and NOT THE MA!!.",
	},
	['LNSLootMyCorpse']                        = {
		DisplayName = "Loot My Corpse",
		Category = "Loot N Scoot",
		Index = 5,
		Tooltip = "Enable LootNScoot to loot your corpse.",
		Default = false,
		FAQ = "Why do my guys not loot my corpse?",
		Answer =
			"RGMercs will only loot your corpse if you have this setting enabled. If you have a corpse that is outside of the radius, it will not be looted.\n" ..
			"You can adjust this advanced setting in the Loot options.",
	},
	['IgnoreNearbyCorpses']                    = {
		DisplayName = "Ignore Nearby Corpses",
		Category = "Loot N Scoot",
		Index = 6,
		Tooltip = "Ignore My Corpses that are within the radius of your character.",
		Default = false,
		FAQ = "Why do my guys not loot corpses that are close to them?",
		Answer =
		"You probably have one of your own corpses nearby, enable [IgnoreNearbyCorpses] to ignore your own corpses that are within the radius of your character.",
	},
	['LootRespectMedState']                    = {
		DisplayName = "Respect Med State",
		Category = "Loot N Scoot",
		Index = 7,
		Tooltip = "Hold looting if you are currently meditating.",
		Default = false,
		FAQ = "Why is the PC sitting there and not medding?",
		Answer =
		"If you turn on Respect Med State in the Group Watch options, your looter will remain medding until those thresholds are reached.\nIf Stand When Done is not enabled, the looter may continue to sit after those thresholds are reached.",
	},
	['LootingTimeout']                         = {
		DisplayName = "Looting Timeout",
		Category = "Loot N Scoot",
		Index = 8,
		Tooltip = "The length of time in seconds that RGMercs will allow LNS to process loot actions in a single check.",
		Default = 5,
		Min = 1,
		Max = 60,
		FAQ = "Why do my guys take too long to loot, or sometimes miss corpses?",
		Answer =
			"While RGMercs doesn't necessary control what LNS is doing, exactly, we do have a timeout setting that dictates how long we will allow it to do it before re-checking for other actions. \n" ..
			"You can adjust this advanced setting in the Loot options. Please note, if no other actions are required by mercs, we will simply allow LNS to continue.",
	},
	['CorpseRadius']                           = {
		DisplayName = "Loot Corpse Radius",
		Category = "Loot N Scoot",
		Index = 9,
		Tooltip = "The radius we will check for corpses to loot in.",
		Default = 100,
		Min = 10,
		Max = 500,
		FAQ = "Why do my guys not loot corpses that are close to them?",
		Answer =
			"RGMercs will only loot corpses that are within the radius you set here. If you have a corpse that is outside of this radius, it will not be looted.\n" ..
			"You can adjust this advanced setting in the Loot options.",
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
		Answer =
		"Inside the Settings section of the LootNScoot GUI you can edit any other character loaded on that PC directly or even clone one set to other characters for faster copying.",
		Settings_Used = "DoLoot",
	},
	[2] = {
		Question = "What is the difference between Personal, Global, and Normal Rules?",
		Answer =
			"Personal Rules are settings that are only used for that character, and will not be used by any other character These Rules OVERRIDE all other rules!\n" ..
			"Global is a setting that will always be used for that item.\nNormal is a setting that will be used for that item unless it is set as a Global or Personal Rule.\n" ..
			"Normal settings are evaluated each time if you have [AlwaysEval] turned on, which can change your setting if the item no longer meets the criteria.\n" ..
			"Setting an items as a Global will prevent it from being re-evaluated and always use the Global setting.",
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
	if not hasLootnScoot then Config:SetSetting('UseBundled', true) end
	mq.pickle(getConfigFileName(), self.settings)
	if self.SettingsLoaded then
		local scriptName = Config:GetSetting('UseBundled') and bundleScriptPath or LootScript

		if self.settings.DoLoot == true then
			local LocalLNSRunning = false

			if not self.Actor then self:LootMessageHandler() end

			if self.TempSettings.LastScript ~= scriptName then
				Logger.log_debug("\ay[LOOT]: \arStopping previous LootNScoot script: %s", self.TempSettings.LastScript)
				Core.DoCmd("/lua stop %s", self.TempSettings.LastScript)

				self.TempSettings.LastScript = scriptName

				self.Actor:send({ mailbox = 'loot_module', script = 'rgmercs', },
					{ Who = Config.Globals.CurLoadedChar, Bundle = Config:GetSetting('UseBundled'), })
			end

			LocalLNSRunning = mq.TLO.Lua.Script(scriptName).Status() == 'RUNNING' or false

			if not LocalLNSRunning then
				Logger.log_debug("\ay[LOOT]: \agStarting LootNScoot script: %s", scriptName)
				Core.DoCmd("/lua run %s directed rgmercs %s", scriptName, scriptName)
			end

			if self.TempSettings.LastCombatSetting == nil then
				self.TempSettings.LastCombatSetting = Config:GetSetting('CombatLooting')
			end

			if self.TempSettings.LastRadiusSetting == nil then
				self.TempSettings.LastRadiusSetting = Config:GetSetting('CorpseRadius')
			end

			if self.TempSettings.LastLootMyCorpseSetting == nil then
				self.TempSettings.LastLootMyCorpseSetting = Config:GetSetting('LNSLootMyCorpse')
			end

			if self.TempSettings.LastIgnoreNearbyCorpsesSetting == nil then
				self.TempSettings.LastIgnoreNearbyCorpsesSetting = Config:GetSetting('IgnoreNearbyCorpses')
			end

			if (self.TempSettings.LastCombatSetting ~= Config:GetSetting('CombatLooting') or
					self.TempSettings.LastRadiusSetting ~= Config:GetSetting('CorpseRadius') or
					self.TempSettings.LastLootMyCorpseSetting ~= Config:GetSetting('LNSLootMyCorpse') or
					self.TempSettings.LastIgnoreNearbyCorpsesSetting ~= Config:GetSetting('IgnoreNearbyCorpses')) then
				self.TempSettings.LastCombatSetting = Config:GetSetting('CombatLooting')
				self.TempSettings.LastRadiusSetting = Config:GetSetting('CorpseRadius')
				self.TempSettings.LastLootMyCorpseSetting = Config:GetSetting('LNSLootMyCorpse')
				self.TempSettings.LastIgnoreNearbyCorpsesSetting = Config:GetSetting('IgnoreNearbyCorpses')

				if mq.gettime() - (self.TempSettings.LastSent or 0) > 500 then
					self.Actor:send({ mailbox = 'lootnscoot', script = scriptName, },
						{
							who = Config.Globals.CurLoadedChar,
							directions = 'setsetting_directed',
							CombatLooting = Config:GetSetting('CombatLooting'),
							CorpseRadius = Config:GetSetting('CorpseRadius'),
							LootMyCorpse = Config:GetSetting('LNSLootMyCorpse'),
							IgnoreNearby = Config:GetSetting('IgnoreNearbyCorpses'),
						})
					self.TempSettings.LastSent = mq.gettime()
				end
			end
		else
			Core.DoCmd("/lua stop %s", scriptName)
		end
	end
	if doBroadcast == true then
		Comms.BroadcastUpdate(self._name, "LoadSettings")
	end
end

function Module:LoadSettings()
	Logger.log_debug("\ay[LOOT]: \atLootnScoot EMU, Loot Module Loading Settings for: %s.",
		Config.Globals.CurLoadedChar)
	local settings_pickle_path = getConfigFileName()
	local needsSave = false
	local config, err = loadfile(settings_pickle_path)
	if err or not config then
		Logger.log_error("\ay[LOOT]: \aoUnable to load global settings file(%s), creating a new one!",
			settings_pickle_path)
		self.settings.MyCheckbox = false
		needsSave = true
	else
		self.settings = config()
	end

	self.settings, needsSave = Config.ResolveDefaults(Module.DefaultConfig, self.settings)

	if self.TempSettings.LastScript == nil then
		self.TempSettings.LastScript = self.settings.UseBundled and bundleScriptPath or LootScript
	end

	Logger.log_debug("Settings Changes = %s", Strings.BoolToColorString(needsSave))
	if needsSave then
		self:SaveSettings(false)
	end
	self.SettingsLoaded = true
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
	self:LootMessageHandler()

	self:LoadSettings()
	if not hasLootnScoot then
		Logger.log_error("\ay[LOOT]: \arLootNScoot is not installed, please install it to use this module.")
	end
	if not Core.OnEMU() then
		Logger.log_debug("\ay[LOOT]: \agWe are not on EMU unloading module. Build: %s",
			mq.TLO.MacroQuest.BuildName())
	else
		if self.settings.DoLoot then
			local lnsRunning = mq.TLO.Lua.Script('lootnscoot').Status() == 'RUNNING'
			if lnsRunning then
				Core.DoCmd("/lns quit")
				mq.delay(1) -- give it a moment to stop
				mq.delay(3000, function() return mq.TLO.Lua.Script('lootnscoot').Status() ~= 'RUNNING' end)
			end

			if not hasLootnScoot then
				Config:SetSetting('UseBundled', true)
			end

			local scriptName = Config:GetSetting('UseBundled') and bundleScriptPath or LootScript

			Core.DoCmd("/lua run %s directed rgmercs %s", scriptName, scriptName)
			mq.delay(1) -- give it a moment to start
			mq.delay(1000, function() return mq.TLO.Lua.Script(scriptName).Status() ~= 'RUNNING' end)

			self.Actor:send({ mailbox = 'lootnscoot', script = scriptName, },
				{ who = Config.Globals.CurLoadedChar, directions = 'getsettings_directed', })
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
			self.TempSettings.NeedSave = true
		end
		Ui.Tooltip(string.format("Pop the %s tab out into its own window.", self._name))
		ImGui.NewLine()
	end
	if hasLootnScoot then
		local pressed = false
		if ImGui.CollapsingHeader("Config Options") then
			self.settings, pressed, _ = Ui.RenderSettings(self.settings, self.DefaultConfig,
				self.DefaultCategories)
		end
		if pressed then
			self.TempSettings.NeedSave = true
		end
	else
		ImGui.Text("Please install LootNScoot to use this module.")
		if ImGui.Button("Copy Link to LootNScoot") then
			ImGui.SetClipboardText(url)
		end
	end
end

function Module:Pop()
	self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
	self.TempSettings.NeedSave = true
end

function Module:DoLooting(combat_state)
	if not self.TempSettings.Looting then return end

	local maxWait = Config:GetSetting('LootingTimeout') * 1000
	while self.TempSettings.Looting do
		if combat_state == "Combat" and not Config:GetSetting('CombatLooting') then
			Logger.log_debug("\ay[LOOT]: Aborting Actions due to combat!")
			if mq.TLO.Window('LootWnd').Open() then mq.TLO.Window('LootWnd').DoClose() end
			self.TempSettings.Looting = false
			break
		end

		mq.delay(20, function() return not self.TempSettings.Looting end)

		maxWait = maxWait - 20

		if maxWait <= 0 then
			Logger.log_debug("\ay[LOOT]: Aborting Actions due to timeout.")
			self.TempSettings.Looting = false
			break
		end
		mq.doevents()
	end
	Logger.log_verbose("\ay[LOOT]: \atFinished Looting: \agResuming")
end

function Module:LootMessageHandler()
	self.Actor = Actors.register('loot_module', function(message)
		local mail = message() or {}
		local subject = mail.Subject or ''
		local who = mail.Who or ''
		local CombatLooting = mail.CombatLooting
		local RadiusSetting = mail.CorpseRadius or 0
		local LootMyCorpse = mail.LootMyCorpse
		local IgnoreNearbyCorpses = mail.IgnoreNearby
		local currCombatSetting = Config:GetSetting('CombatLooting')
		local currRadiusSetting = Config:GetSetting('CorpseRadius')
		local currLootMyCorpse = Config:GetSetting('LNSLootMyCorpse')
		local currIgnoreNearbyCorpses = Config:GetSetting('IgnoreNearbyCorpses')
		local needSave = false

		if mail.Bundle ~= nil and who ~= Config.Globals.CurLoadedChar then
			if mail.Bundle ~= Config:GetSetting('UseBundled') then
				Logger.log_debug("\ay[LOOT]: \aoSetting UseBundled to %s", mail.Bundle and "\agOn" or "\arOff")
				Config:SetSetting('UseBundled', mail.Bundle)
				-- Core.DoCmd("/lns quit")
				needSave = true
			end
		end

		if who ~= Config.Globals.CurLoadedChar then return end

		if subject == 'done_looting' or subject == 'done_processing' then
			Logger.log_verbose("\ay[LOOT]: \atFinishing Looting: \agResuming")
			self.TempSettings.Looting = false
		elseif subject == 'processing' then
			Logger.log_verbose("\ay[LOOT]: \atProcessing Loot Actions")
			self.TempSettings.Looting = true
		else
			if CombatLooting ~= nil then
				if currCombatSetting ~= CombatLooting then
					Config:SetSetting('CombatLooting', CombatLooting)
					needSave = true
				end
			end
			if (RadiusSetting or 0) > 0 and currRadiusSetting ~= RadiusSetting then
				Config:SetSetting('CorpseRadius', RadiusSetting)
				needSave = true
			end
			if LootMyCorpse ~= nil then
				if currLootMyCorpse ~= LootMyCorpse then
					Config:SetSetting('LNSLootMyCorpse', LootMyCorpse)
					needSave = true
				end
			end
			if IgnoreNearbyCorpses ~= nil then
				if currIgnoreNearbyCorpses ~= IgnoreNearbyCorpses then
					Config:SetSetting('IgnoreNearbyCorpses', IgnoreNearbyCorpses)
					needSave = true
				end
			end
		end

		if needSave then
			Logger.log_debug("\ay[LOOT]: \agUpdating Loot Settings for %s", Config.Globals.CurLoadedChar)
			self.TempSettings.NeedSave = true
		end
	end)
end

function Module:GiveTime(combat_state)
	if self.TempSettings.NeedSave then
		self:SaveSettings(false)
		self.TempSettings.NeedSave = false
		Logger.log_debug("\ay[LOOT]: \agSettings Saved for %s", Config.Globals.CurLoadedChar)
	end

	if not Config:GetSetting('DoLoot') or not Config:GetSetting('LootCorpses') then return end
	if Config.Globals.PauseMain then return end

	if not Core.OkayToNotHeal() or mq.TLO.Me.Invis() or Casting.IAmFeigning() then return end

	if Config:GetSetting('LootRespectMedState') and Config.Globals.InMedState then
		Logger.log_super_verbose("\ay::LOOT:: \arAborted!\ax Meditating.")
		return
	end

	local deadCount = mq.TLO.SpawnCount(string.format("npccorpse radius %s zradius 50", Config:GetSetting('CorpseRadius') or 100))()
	local myCorpseCount = mq.TLO.SpawnCount(string.format("pccorpse \"%s\" radius %s zradius 50", (mq.TLO.Me.CleanName() .. "'s corpse"), Config:GetSetting('CorpseRadius') or 100))()
	if Config:GetSetting('LNSLootMyCorpse') and myCorpseCount > 0 then deadCount = deadCount + 1 end

	if self.Actor == nil then self:LootMessageHandler() end
	-- send actors message to loot
	if (combat_state ~= "Combat" or Config:GetSetting('CombatLooting')) and deadCount > 0 then
		if not self.TempSettings.Looting then
			local scriptName = Config:GetSetting('UseBundled') and bundleScriptPath or LootScript
			self.Actor:send({ mailbox = 'lootnscoot', script = scriptName, },
				{ who = Config.Globals.CurLoadedChar, directions = 'doloot', })
			self.TempSettings.Looting = true
		end
	end

	if self.TempSettings.Looting then
		Logger.log_verbose("\ay[LOOT]: \aoPausing for \atLoot Actions")
		self:DoLooting(combat_state)
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
	local scriptName = Config:GetSetting('UseBundled') and bundleScriptPath or LootScript
	Core.DoCmd("/lua stop %s", scriptName)
end

return Module
