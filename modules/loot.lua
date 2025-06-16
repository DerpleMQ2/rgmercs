-- Sample Basic Class Module
local mq                               = require('mq')
local Config                           = require('utils.config')
local Core                             = require("utils.core")
local Casting                          = require("utils.casting")
local Ui                               = require("utils.ui")
local Comms                            = require("utils.comms")
local Strings                          = require("utils.strings")
local Logger                           = require("utils.logger")
local Files                            = require("utils.files")
local Actors                           = require("actors")
local Set                              = require("mq.Set")
local Icons                            = require('mq.ICONS')
local LootnScootPath                   = string.format("%s/lootnscoot/init.lua", mq.luaDir)
local LootScript                       = "lootnscoot"
local hasLootnScoot                    = Files.file_exists(LootnScootPath)
local url                              = "https://www.redguides.com/community/resources/lootnscoot-for-emu.2675/"

local Module                           = { _version = '1.1 for LNS', _name = "Loot", _author = 'Derple, Grimmier, Algar', }
Module.__index                         = Module
Module.settings                        = {}
Module.DefaultCategories               = {}
local Module                           = { _version = '0.1a', _name = "Loot", _author = 'Derple, Grimmier, Aquietone (lootnscoot lua)', }
Module.__index                         = Module
Module.settings                        = {}
Module.DefaultCategories               = {}
Module.ModuleLoaded                    = false
Module.TempSettings                    = {}
Module.TempSettings.CorpsesToIgnore    = {}
Module.TempSettings.FirstRun           = true
Module.LNSSettings                     = {}
-- initialize LNS settings with defaults these will update once lns sends a message back.
Module.LNSSettings.MaxCorpsesPerCycle  = 5
Module.LNSSettings.LootMyCorpse        = true  -- will force an update if its false on lns side
Module.LNSSettings.IgnoreMyNearCorpses = false -- will force an update if its true on lns side
Module.LNSSettings.CombatLooting       = true  -- will force an update if its false on lns side
Module.LNSSettings.CorpseRadius        = 100

Module.FAQ                             = {}
Module.ClassFAQ                        = {}

Module.DefaultConfig                   = {
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

Module.FAQ                             = {
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

Module.CommandHandlers                 = {

}

Module.DefaultCategories               = Set.new({})
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
	if self.SettingsLoaded then
		if self.settings.DoLoot == true then
			local lnsRunning = mq.TLO.Lua.Script(LootScript).Status() == 'RUNNING' or false
			if not lnsRunning then
				Core.DoCmd("/lua run lootnscoot directed rgmercs")

				if not self.Actor then self:LootMessageHandler() end

				mq.delay(3000, function() return mq.TLO.Lua.Script(LootScript).Status() ~= 'RUNNING' end)

				self.Actor:send({ mailbox = LootScript, script = LootScript, },
					{ who = Config.Globals.CurLoadedChar, directions = 'getsettings_directed', })
			end
		else
			Core.DoCmd("/lua stop lootnscoot")
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
		if self.settings.DoLoot and hasLootnScoot then
			local lnsRunning = mq.TLO.Lua.Script(LootScript).Status() == 'RUNNING'
			if lnsRunning then
				Core.DoCmd("/lua stop %s", LootScript)
				mq.delay(3000, function() return mq.TLO.Lua.Script(LootScript).Status() ~= 'RUNNING' end)
			end
			printf("LNS Status Check1: %s", mq.TLO.Lua.Script(LootScript).Status())

			Core.DoCmd("/lua run %s directed rgmercs %s", LootScript, LootScript)
			mq.delay(3000, function() return mq.TLO.Lua.Script(LootScript).Status() == 'RUNNING' end)
			printf("LNS Status Check2: %s", mq.TLO.Lua.Script(LootScript).Status())
			self.Actor:send({ mailbox = LootScript, script = LootScript, },
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
		ImGui.Text(
			"PLEASE NOTE: The LootNScoot script is no longer bundled with RGMercs.\nThis module has been adjusted to work with the standalone version!\nPlease see the RG forums for details. ")
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
	if ImGui.CollapsingHeader("LNS Settings") then
		ImGui.TextWrapped([[
These settings are from LootNScoot, and are not controlled by RGMercs.
They are loaded from the LootNScoot script and can be changed in the LootNScoot GUI.
Adjusting these will change how often RGMercs will call for looting actions, and how they are handled.
You can also change these settings in the LootNScoot GUI, which is loaded when you load the LootNScoot script.]])

		ImGui.Spacing()

		if ImGui.BeginTable("LNSSettings", 2, ImGuiTableFlags.Borders) then
			ImGui.TableSetupColumn("Setting", ImGuiTableColumnFlags.WidthFixed, 150)
			ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch)
			ImGui.TableHeadersRow()
			ImGui.TableNextRow()
			ImGui.TableNextColumn()

			ImGui.Text("LootMyCorpse:")

			ImGui.TableNextColumn()
			ImGui.TextColored(self.LNSSettings.LootMyCorpse and ImVec4(0, 1, 0, 1) or ImVec4(1, 0, 0, 1),
				tostring(self.LNSSettings.LootMyCorpse))

			ImGui.TableNextColumn()
			ImGui.Text("IgnoreMyNearCorpses:")

			ImGui.TableNextColumn()
			ImGui.TextColored(self.LNSSettings.IgnoreMyNearCorpses and ImVec4(0, 1, 0, 1) or ImVec4(1, 0, 0, 1),
				tostring(self.LNSSettings.IgnoreMyNearCorpses))

			ImGui.TableNextColumn()
			ImGui.Text("CombatLooting:")

			ImGui.TableNextColumn()
			ImGui.TextColored(self.LNSSettings.CombatLooting and ImVec4(0, 1, 0, 1) or ImVec4(1, 0, 0, 1),
				tostring(self.LNSSettings.CombatLooting))

			ImGui.TableNextColumn()
			ImGui.Text("CorpseRadius:")

			ImGui.TableNextColumn()
			ImGui.TextColored(ImVec4(1, 1, 0, 1), "%s", self.LNSSettings.CorpseRadius or 100)

			ImGui.EndTable()
		end
	end
end

function Module:Pop()
	self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
	self.TempSettings.NeedSave = true
end

function Module:DoLooting(combat_state)
	if not self.TempSettings.Looting then return end

	local maxWait = Config:GetSetting('LootingTimeout')
	while self.TempSettings.Looting do
		if combat_state == "Combat" and not Config:GetSetting('CombatLooting') then
			Logger.log_warn("\ay[LOOT]: Aborting Actions due to \arCombat!")
			mq.TLO.Window('LootWnd').DoClose()
			mq.delay(1)
			self.TempSettings.Looting = false
			break
		end

		-- changed time check and shotend the delay so event checks can happen more frequently
		mq.delay(1)

		if os.clock() - (self.TempSettings.LootCalledAt or 0) > maxWait then
			Logger.log_warn("\ay[LOOT]: \awLoot Actions\ar Timeout: \ay%s\aw seconds", maxWait)
			mq.TLO.Window('LootWnd').DoClose()
			mq.delay(1)
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
		local NewSettings = mail.LNSSettings or nil
		local needSave = false

		if who ~= Config.Globals.CurLoadedChar then return end

		self.TempSettings.CorpsesToIgnore = mail.CorpsesToIgnore ~= nil and mail.CorpsesToIgnore or {}

		if NewSettings ~= nil then
			self.LNSSettings = NewSettings
			self.TempSettings.FirstRun = false
		end

		if subject == 'done_looting' or subject == 'done_processing' then
			self.TempSettings.Looting = false
		elseif subject == 'processing' then
			Logger.log_verbose("\ay[LOOT]: \atProcessing Loot Actions")
			self.TempSettings.Looting = true
		end

		if needSave then
			Logger.log_verbose("\ay[LOOT]: \agUpdating Loot Settings for %s", Config.Globals.CurLoadedChar)
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

	if self.TempSettings.FirstRun then
		self.Actor:send({ mailbox = LootScript, script = LootScript, },
			{ who = Config.Globals.CurLoadedChar, directions = 'getsettings_directed', })
	end

	if not hasLootnScoot then return end

	if not Config:GetSetting('DoLoot') or not Config:GetSetting('LootCorpses') then return end

	if Config.Globals.PauseMain then return end

	if not Core.OkayToNotHeal() or mq.TLO.Me.Invis() or Casting.IAmFeigning() then return end

	if combat_state == "Combat" and not self.LNSSettings.CombatLooting then return end

	if Config:GetSetting('LootRespectMedState') and Config.Globals.InMedState then
		Logger.log_super_verbose("\ay::LOOT:: \arAborted!\ax Meditating.")
		return
	end

	local searchString = string.format("npccorpse radius %s zradius 50", self.LNSSettings.CorpseRadius or 100)
	local deadCount = mq.TLO.SpawnCount(searchString)()

	searchString = string.format("pccorpse %s's corpse radius %s zradius 50", mq.TLO.Me.DisplayName(), self.LNSSettings.CorpseRadius or 100)
	local myCorpseCount = mq.TLO.SpawnCount(searchString)()
	local foundMyCorpse = myCorpseCount > 0

	-- check the already looted corpses list and if all corpses have been looted, skip the loot actions

	if deadCount > 0 then
		local found = true
		for i = 1, deadCount do
			local corpse = mq.TLO.NearestSpawn(string.format("%d, npccorpse radius %d zradius 50", i, self.LNSSettings.CorpseRadius or 100))
			if corpse() then
				if not self.TempSettings.CorpsesToIgnore[corpse.ID()] then
					Logger.log_verbose("[\at%s\ax]\ay[LOOT]: \ax\at%s\ax Corpse has Not been Looted Yet, \ayPreparing to check corpse.", mq.TLO.Time.Time24(), corpse.CleanName())
					found = false
					break
				end
			end
		end
		if found and not foundMyCorpse then
			Logger.log_verbose("[\at%s\ax]\ay[LOOT]: \ax\atAll Corpses\ax have been \agChecked\ax, \aoSkipping Loot Actions.", mq.TLO.Time.Time24())
			return
		end
	end

	if self.LNSSettings.LootMyCorpse and foundMyCorpse then deadCount = deadCount + myCorpseCount end

	if foundMyCorpse and not self.LNSSettings.LootMyCorpse and not self.LNSSettings.IgnoreMyNearCorpses then
		Logger.log_debug("\ay[LOOT]: \arYou have a corpse\ax, \aoSkipping Loot Actions.")
		return
	end

	if self.Actor == nil then self:LootMessageHandler() end

	-- send actors message to loot
	if (combat_state ~= "Combat" or self.LNSSettings.CombatLooting) and (deadCount > 0) then
		if not self.TempSettings.Looting then
			self.Actor:send({ mailbox = LootScript, script = LootScript, },
				{ who = Config.Globals.CurLoadedChar, directions = 'doloot', }) -- optioal add a limit `limit = value`
			self.TempSettings.Looting = true
			self.TempSettings.LootCalledAt = os.clock()
		end
	end

	if self.TempSettings.Looting then
		Logger.log_verbose("[\at%s\ax]\ay[LOOT]: \aoPausing for \atLoot Actions\aw, \aoCombat State\ax: [\at%s\ax]\aw, \aoLimit: \ax[\ay%s\ax]", mq.TLO.Time.Time24(), combat_state,
			self.LNSSettings.MaxCorpsesPerCycle or '?')
		self:DoLooting(combat_state)
	end
	mq.doevents()
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
	Core.DoCmd("/lua stop %s", LootScript)
end

return Module
