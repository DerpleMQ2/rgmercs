-- Sample Basic Class Module
local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")
local Set         = require("mq.Set")

local LootnScoot  = require('lib.lootnscoot.loot_lib')


local Module             = { _version = '0.1a', _name = "Loot", _author = 'Derple, Grimmier, Aquietone (lootnscoot lua)', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultCategories = {}

Module.ModuleLoaded      = false
Module.CombatState       = "None"

Module.TempSettings      = {}

Module.DefaultConfig     = {
	['DoLoot'] = { DisplayName = "DoLoot", Category = "Loot N Scoot", Tooltip = "Enables Loot N Scoot for Looting", Default = true, },
	['AutoLoot'] = { DisplayName = "Auto Loot", Category = "Loot N Scoot", Tooltip = "Auto Loot During Downtime.", Default = true, },
}

Module.CommandHandlers   = {
	sell = {
		usage = "/rgl sell",
		about = "Use lootnscoot to sell stuff to your Target.",
		handler = function(self, _)
			self:DoSell()
		end,
	},
	loot = {
		usage = "/rgl loot",
		about = "Loot the Mobs around you.",
		handler = function(self, _)
			self:LootMobs()
		end,
	},
	buy = {
		usage = "/rgl buy",
		about = "Restock Buy Items from your Target.",
		handler = function(self, _)
			self:DoBuy()
		end,
	},
	tribute = {
		usage = "/rgl tribute",
		about = "Tribute gear to targeted Tribute Master.",
		handler = function(self, _)
			self:DoTribute()
		end,
	},
	bank = {
		usage = "/rgl bank",
		about = "Stash stuff in the bank",
		handler = function(self, _)
			self:DoBank()
		end,
	},
	setitem = {
		usage = "/rgl setitem <setting>",
		about = "Set the Item on your Cursor's Normal loot setting (sell, keep, destroy, ignore, quest, tribute, bank).",
		handler = function(self, params)
			self:SetItem(params)
		end,
	},
	setglobalitem = {
		usage = "/rgl setglobalitem <setting>",
		about = "Set the Item on your Cursor's GlobalItem loot setting (sell, keep, destroy, ignore, quest, tribute, bank).",
		handler = function(self, params)
			self:SetGlobalItem(params)
		end,
	},
	cleanbags = {
		usage = "/rgl cleanbags",
		about = "Destroy the Trash marked as Destroy in your Bags.",
		handler = function(self, _)
			self:CleanUp()
		end,
	},
	lootui = {
		usage = "/rgl lootui",
		about = "Toggle the LootnScoot console UI.",
		handler = function(self, _)
			self:ShowLootUI()
		end,
	},
	reportloot = {
		usage = "/rgl reportloot",
		about = "Open the LootnScoot Loot History Table.",
		handler = function(self, _)
			self:ReportLoot()
		end,
	},
	lootreload = {
		usage = "/rgl lootreload",
		about = "Reloads your loot settings.",
		handler = function(self, _)
			self:LootReload()
		end,
	},
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
		'/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. RGMercConfig.Globals.CurLoadedChar ..
		"_" .. RGMercConfig.Globals.CurLoadedClass .. '.lua'
end

function Module:SaveSettings(doBroadcast)
	mq.pickle(getConfigFileName(), self.settings)

	if doBroadcast == true then
		RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
	end
end

function Module:LoadSettings()
	RGMercsLogger.log_debug("\ay[LOOT]: \atLootnScoot EMU, Loot Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
	local settings_pickle_path = getConfigFileName()

	local config, err = loadfile(settings_pickle_path)
	if err or not config then
		RGMercsLogger.log_error("\ay[LOOT]: \aoUnable to load global settings file(%s), creating a new one!",
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
	RGMercsLogger.log_debug("\ay[LOOT]: \agLoot for EMU module Loaded.")
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

function Module:DoSell()
	if LootnScoot ~= nil then
		LootnScoot.processItems('Sell')
	end
end

function Module:LootMobs()
	if LootnScoot ~= nil then
		LootnScoot.lootMobs()
	end
end

function Module:DoBuy()
	if LootnScoot ~= nil then
		LootnScoot.processItems('Buy')
	end
end

function Module:DoBank()
	if LootnScoot ~= nil then
		LootnScoot.processItems('Bank')
	end
end

function Module:DoTribute()
	if LootnScoot ~= nil then
		LootnScoot.processItems('Tribute')
	end
end

function Module:SetItem(params)
	if LootnScoot ~= nil then
		LootnScoot.commandHandler(params)
	end
end

function Module:SetGlobalItem(params)
	if LootnScoot ~= nil then
		LootnScoot.commandHandler(params)
	end
end

function Module:CleanUp()
	if LootnScoot ~= nil then
		LootnScoot.processItems('Cleanup')
	end
end

function Module:ReportLoot()
	if LootnScoot ~= nil then
		LootnScoot.guiLoot.ReportLoot()
	end
end

function Module:ShowLootUI()
	if LootnScoot ~= nil then
		LootnScoot.guiLoot.openGUI = not LootnScoot.guiLoot.openGUI
	end
end

function Module:LootReload()
	if LootnScoot ~= nil then
		LootnScoot.commandHandler('reload')
	end
end

function Module:GiveTime(combat_state)
	-- Main Module logic goes here.
	if self.CombatState ~= combat_state and combat_state == "Downtime" then
		if LootnScoot ~= nil and self.settings.DoLoot and self.settings.AutoLoot then
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
	return { module = self._name, CommandHandlers = self.CommandHandlers, }
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
	RGMercsLogger.log_debug("\ay[LOOT]: \axEMU Loot Module Unloaded.")
end

return Module
