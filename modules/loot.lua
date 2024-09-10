-- Sample Basic Class Module
local mq                 = require('mq')
local RGMercUtils        = require("utils.rgmercs_utils")
local Set                = require("mq.Set")

local LootnScoot         = require('lib.lootnscoot.loot_lib')
local sNameStripped      = string.gsub(mq.TLO.EverQuest.Server(), ' ', '_')

local Module             = { _version = '0.1a', _name = "Loot", _author = 'Derple, Grimmier, Aquietone (lootnscoot lua)', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultCategories = {}

Module.ModuleLoaded      = false
Module.CombatState       = "None"

Module.TempSettings      = {}
Module.BuyItemsTable     = {}
Module.GlobalItemsTable  = {}

Module.DefaultConfig     = {
	['DoLoot']          = { DisplayName = "DoLoot", Category = "Loot N Scoot", Tooltip = "Enables Loot Settings for Looting", Default = true, },
	['AutoLoot']        = { DisplayName = "Auto Loot", Category = "Loot N Scoot", Tooltip = "Auto Loot During Downtime.", Default = true, },

	--- Looted Settings
	['LootFile']        = { DisplayName = 'Loot File', Category = 'Loot Settings', Tooltip = "Where your loot.ini file lives", Default = LootnScoot.Settings.LootFile, },
	['SettingsFile']    = { DisplayName = 'Loot Settings File', Category = 'Loot Settings', Tooltip = 'Location of LootnScoot settings file', Default = LootnScoot.Settings.SettingsFile, },
	['GlobalLootOn']    = { DisplayName = 'Do Global Loot', Category = 'Loot Settings', Tooltip = 'Enable Global Loot Items', Default = LootnScoot.Settings.GlobalLootOn, },
	['CombatLooting']   = { DisplayName = "Loot In Combat", Category = 'Loot Settings', Tooltip = "Enables looting during combat. Not recommended on the MT", Default = LootnScoot.Settings.CombatLooting, },
	['CorpseRadius']    = { DisplayName = "Corpse Radius", Category = 'Loot Settings', Tooltip = "Radius to activly loot corpses", Default = LootnScoot.Settings.CorpseRadius, Min = 1, Max = 500, },
	['MobsTooClose']    = { DisplayName = "Mobs To Close", Category = 'Loot Settings', Tooltip = "Don't loot if mobs are in this range.", Default = LootnScoot.Settings.MobsTooClose, Min = 1, Max = 200, },
	['SaveBagSlots']    = { DisplayName = "Save Bag Slots", Category = 'Loot Settings', Default = LootnScoot.Settings.SaveBagSlots, Min = 1, Max = 30, Tooltip = "Number of bag slots you would like to keep empty at all times. Stop looting if we hit this number", },
	['TributeKeep']     = { DisplayName = "Tribute Keep", Category = "Loot Settings", Default = LootnScoot.Settings.TributeKeep, Tooltip = "Keep items flagged Tribute", },
	['MinTributeValue'] = { DisplayName = "Minimum Tribute Value", Category = "Loot Settings", Default = LootnScoot.Settings.MinTributeValue, Min = 1, Max = 99999, Tooltip = "Minimun Tribute points to keep item if TributeKeep is enabled.", },
	['MinSellPrice']    = { DisplayName = "Minimum Sell Price", Category = "Loot Settings", Default = LootnScoot.Settings.MinSellPrice, Min = -1, Max = 999999, Tooltip = "Minimum Sell price to keep item. -1 = any", },
	['StackPlatValue']  = { DisplayName = "Stack Plat Value", Default = LootnScoot.Settings.StackPlatValue, Min = -1, Max = 999999, Category = "Loot Settings", Tooltip = "Minimum sell value for full stack", },
	['StackableOnly']   = { DisplayName = "Stackable Only", Default = LootnScoot.Settings.StackableOnly, Category = "Loot Settings", Tooltip = "Only loot stackable items", },
	['AlwaysEval']      = { DisplayName = "Always Evaluate", Default = LootnScoot.Settings.AlwaysEval, Category = "Loot Settings", Tooltip = "Re-Evaluate all *Non Quest* items. useful to update loot.ini after changing min sell values.", },
	['BankTradeskills'] = { DisplayName = "Bank Tradeskil", Default = LootnScoot.Settings.BankTradeskills, Category = "Loot Settings", Tooltip = "Toggle flagging Tradeskill items as Bank or not.", },
	['LootForage']      = { DisplayName = "Loot Forage", Default = LootnScoot.Settings.LootForage, Category = "Loot Settings", Tooltip = "Enable Looting of Foraged Items", },
	['LootNoDrop']      = { DisplayName = "Loot NoDrop", Default = LootnScoot.Settings.LootNoDrop, Category = "Loot Settings", Tooltip = "Enable Looting of NoDrop items", },
	['LootNoDropNew']   = { DisplayName = "Loot NoDrop New", Default = LootnScoot.Settings.LootNoDropNew, Category = "Loot Settings", Tooltip = "Enable looting of new NoDrop items", },
	['LootQuest']       = { DisplayName = "Loot Quest", Default = LootnScoot.Settings.LootQuest, Category = "Loot Settings", Tooltip = "Enable Looting of Items Marked 'Quest', requires LootNoDrop on to loot NoDrop quest items", },
	['DoDestroy']       = { DisplayName = "DoDestroy", Default = LootnScoot.Settings.DoDestroy, Category = "Loot Settings", Tooltip = "Enable Destroy functionality. Otherwise 'Destroy' acts as 'Ignore'", },
	['AlwaysDestroy']   = { DisplayName = "Always Destroy", Default = LootnScoot.Settings.AlwaysDestroy, Category = "Loot Settings", Tooltip = "Always Destroy items to clean corpese Will Destroy Non-Quest items marked 'Ignore' items REQUIRES DoDestroy set to true", },
	['QuestKeep']       = { DisplayName = "QuestKeep", Default = LootnScoot.Settings.QuestKeep, Min = 1, Max = 100, Category = "Loot Settings", Tooltip = "Default number to keep if item not set using Quest|# format.", },
	['LootChannel']     = { DisplayName = "Loot Channel", Default = LootnScoot.Settings.LootChannel, Category = "Loot Settings", Tooltip = "Channel we report loot to.", },
	['GroupChannel']    = { DisplayName = "Group Channel", Default = LootnScoot.Settings.GroupChannel, Category = "Loot Settings", Tooltip = "Channel we use for Group Commands", },
	['ReportLoot']      = { DisplayName = "Report Loot", Default = LootnScoot.Settings.ReportLoot, Category = "Loot Settings", Tooltip = "Report loot items to group or not", },
	['SpamLootInfo']    = { DisplayName = "Spam LootInfo", Default = LootnScoot.Settings.SpamLootInfo, Category = "Loot Settings", Tooltip = "Echo Spam for Looting", },
	['LootForageSpam']  = { DisplayName = "Loot Forage Spam", Default = LootnScoot.Settings.LootForageSpam, Category = "Loot Settings", Tooltip = "Echo spam for Foraged Items", },
	['AddNewSales']     = { DisplayName = "Add New Sales", Default = LootnScoot.Settings.AddNewSales, Category = "Loot Settings", Tooltip = "Adds 'Sell' Flag to items automatically if you sell them while the script is running", },
	['AddNewTributes']  = { DisplayName = "Add New Tributes", Default = LootnScoot.Settings.AddNewTributes, Category = "Loot Settings", Tooltip = "Adds 'Tribute' Flag to items automatically if you Tribute them while the script is running.", },
	['ExcludeBag1']     = { DisplayName = "Exclude Bag1", Default = LootnScoot.Settings.ExcludeBag1, Category = "Loot Settings", Tooltip = "Name of Bag to ignore items in when selling", },
	['HideNames']       = { DisplayName = "Hide Names", Default = LootnScoot.Settings.HideNames, Category = "Loot Settings", Tooltip = "Hides names and uses class shortname in looted window", },
	['RecordData']      = { DisplayName = "Record Data", Default = LootnScoot.Settings.RecordData, Category = "Loot Settings", Tooltip = "Enables recording data to report later", },
	['AutoTag']         = { DisplayName = "Auto Tag", Default = LootnScoot.Settings.AutoTag, Category = "Loot Settings", Tooltip = "Automatically tag items to sell if they meet the MinSellPrice", },
	['AutoRestock']     = { DisplayName = "Auto Restock", Default = LootnScoot.Settings.AutoRestock, Category = "Loot Settings", Tooltip = "Automatically restock items from the BuyItems list when selling", },
	['LookupLinks']     = { DisplayName = "Lookup Links", Default = LootnScoot.Settings.LookupLinks, Category = "Loot Settings", Tooltip = "Enables Looking up Links for items not on that character. *recommend only running on one charcter that is monitoring.", },
	['AlwaysCoin']      = { DisplayName = "Always Loot Coin", Default = LootnScoot.Settings.AlwaysCoin, Category = "Loot Settings", Tooltip = "Always Loot Coin even when bags are FULL!", },
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

local function getLootItemsConfigFileName(type)
	local server = mq.TLO.EverQuest.Server()
	server = server:gsub(" ", "")
	return mq.configDir ..
		'/rgmercs/PCConfigs/' .. type .. "_ItemsTable_" .. server .. "_" .. RGMercConfig.Globals.CurLoadedChar ..
		"_" .. RGMercConfig.Globals.CurLoadedClass .. '.lua'
end

function Module:SaveSettings(doBroadcast)
	mq.pickle(getConfigFileName(), self.settings)
	mq.pickle(getLootItemsConfigFileName('buy'), self.BuyItemsTable)
	mq.pickle(getLootItemsConfigFileName('global'), self.GlobalItemsTable)
	self:SortItemTables()
	if doBroadcast == true then
		RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
	end
end

function Module:ModifyLootSettings()
	if LootnScoot.GlobalItems ~= nil then
		for k, v in pairs(LootnScoot.GlobalItems) do
			self.GlobalItemsTable[k] = v
		end
	end
	if LootnScoot.BuyItems ~= nil then
		for k, v in pairs(LootnScoot.BuyItems) do
			self.BuyItemsTable[k] = v
		end
	end
	self:SaveSettings(false)
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

	if LootnScoot.GlobalItems ~= nil then
		for k, v in pairs(LootnScoot.GlobalItems) do
			self.GlobalItemsTable[k] = v
		end
	end
	if LootnScoot.BuyItems ~= nil then
		for k, v in pairs(LootnScoot.BuyItems) do
			self.BuyItemsTable[k] = v
		end
	end

	-- lootnscoot tables
	local buyItems_pickle_path = getLootItemsConfigFileName('buy')
	local buyItemsLoad, err = loadfile(buyItems_pickle_path)
	if err or not buyItemsLoad then
		RGMercsLogger.log_error("\ay[LOOT]: \aoUnable to load buy items file(%s), creating a new one!",
			buyItems_pickle_path)
		self:SaveSettings(false)
	else
		self.BuyItemsTable = buyItemsLoad()
	end

	local globalItems_pickle_path = getLootItemsConfigFileName('global')
	local globalItemsLoad, err = loadfile(globalItems_pickle_path)
	if err or not globalItemsLoad then
		RGMercsLogger.log_error("\ay[LOOT]: \aoUnable to load global items file(%s), creating a new one!",
			globalItems_pickle_path)
		self:SaveSettings(false)
	else
		self.GlobalItemsTable = globalItemsLoad()
	end

	--pass settings to lootnscoot lib
	LootnScoot.Settings = self.settings

	for k, v in pairs(self.BuyItemsTable) do
		LootnScoot.BuyItems[k] = v
	end
	for k, v in pairs(self.GlobalItemsTable) do
		LootnScoot.GlobalItems[k] = v
	end

	self:SortItemTables()
end

function Module:SortItemTables()
	self.TempSettings.SortedGlobalItemKeys = {}
	for k in pairs(self.GlobalItemsTable) do
		table.insert(self.TempSettings.SortedGlobalItemKeys, k)
	end
	table.sort(self.TempSettings.SortedGlobalItemKeys, function(a, b) return a < b end)

	self.TempSettings.SortedBuyItemKeys = {}
	for k in pairs(self.BuyItemsTable) do
		table.insert(self.TempSettings.SortedBuyItemKeys, k)
	end
	table.sort(self.TempSettings.SortedBuyItemKeys, function(a, b) return a < b end)
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
	if ImGui.CollapsingHeader("Items Tables") then
		if ImGui.BeginTabBar("Items") then
			-- Determine the number of columns based on available space
			local col = math.max(2, math.floor(ImGui.GetContentRegionAvail() / 150))
			col = col + (col % 2)

			-- Buy Items
			if ImGui.BeginTabItem("Buy Items") then
				if self.TempSettings.BuyItems == nil then
					self.TempSettings.BuyItems = {}
				end
				ImGui.Text("Delete the Item Name to remove it from the table")

				-- Display Save Changes button
				if ImGui.Button("Save Changes##BuyItems") then
					-- Apply updates to BuyItemsTable
					for k, v in pairs(self.TempSettings.UpdatedBuyItems) do
						self.BuyItemsTable[k] = v
					end
					-- Remove deleted items
					for k in pairs(self.TempSettings.DeletedBuyKeys) do
						self.BuyItemsTable[k] = nil
					end
					self.TempSettings.NeedSave = true
				end

				if ImGui.BeginTable("Buy Items", col, ImGuiTableFlags.Borders) then
					for i = 1, col / 2 do
						ImGui.TableSetupColumn("Item")
						ImGui.TableSetupColumn("Qty")
					end
					ImGui.TableHeadersRow()

					local numDisplayColumns = col / 2

					if self.BuyItemsTable ~= nil and self.TempSettings.SortedBuyItemKeys ~= nil then
						self.TempSettings.UpdatedBuyItems = {} -- Temporary storage for updated items
						self.TempSettings.DeletedBuyKeys = {} -- Temporary storage for deleted keys

						local numItems = #self.TempSettings.SortedBuyItemKeys
						local numRows = math.ceil(numItems / numDisplayColumns)

						for row = 1, numRows do
							for column = 0, numDisplayColumns - 1 do
								local index = row + column * numRows
								local k = self.TempSettings.SortedBuyItemKeys[index]
								if k then
									local v = self.BuyItemsTable[k]

									self.TempSettings.BuyItems[k] = self.TempSettings.BuyItems[k] or { Key = k, Value = v, }

									ImGui.TableNextColumn()
									local newKey = ImGui.InputText("##Key" .. k, self.TempSettings.BuyItems[k].Key)

									ImGui.TableNextColumn()
									local newValue = ImGui.InputText("##Value" .. k, self.TempSettings.BuyItems[k].Value)

									if newKey ~= k or newKey == "" then
										self.TempSettings.UpdatedBuyItems[newKey] = newValue
										self.TempSettings.DeletedBuyKeys[k] = true
									else
										self.TempSettings.UpdatedBuyItems[k] = newValue
									end

									self.TempSettings.BuyItems[k].Key = newKey
									self.TempSettings.BuyItems[k].Value = newValue
								end
							end
						end
					end

					ImGui.EndTable()
				end
				ImGui.EndTabItem()
			end

			-- Global Items
			if ImGui.BeginTabItem("Global Items") then
				if self.TempSettings.GlobalItems == nil then
					self.TempSettings.GlobalItems = {}
				end
				ImGui.Text("Delete the Item Name to remove it from the table")

				-- Display Save Changes button
				if ImGui.Button("Save Changes##GlobalItems") then
					-- Apply updates to GlobalItemsTable
					for k, v in pairs(self.TempSettings.UpdatedGlobalItems) do
						self.GlobalItemsTable[k] = v
					end
					-- Remove deleted items
					for k in pairs(self.TempSettings.DeletedGlobalKeys) do
						self.GlobalItemsTable[k] = nil
					end
					self.TempSettings.NeedSave = true
				end

				if ImGui.BeginTable("GlobalItems", col, ImGuiTableFlags.Borders) then
					for i = 1, col / 2 do
						ImGui.TableSetupColumn("Item")
						ImGui.TableSetupColumn("Setting")
					end
					ImGui.TableHeadersRow()

					local numDisplayColumns = col / 2

					if self.GlobalItemsTable ~= nil and self.TempSettings.SortedGlobalItemKeys ~= nil then
						self.TempSettings.UpdatedGlobalItems = {} -- Temporary storage for updated items
						self.TempSettings.DeletedGlobalKeys = {} -- Temporary storage for deleted keys

						local numItems = #self.TempSettings.SortedGlobalItemKeys
						local numRows = math.ceil(numItems / numDisplayColumns)

						for row = 1, numRows do
							for column = 0, numDisplayColumns - 1 do
								local index = row + column * numRows
								local k = self.TempSettings.SortedGlobalItemKeys[index]
								if k then
									local v = self.GlobalItemsTable[k]

									self.TempSettings.GlobalItems[k] = self.TempSettings.GlobalItems[k] or { Key = k, Value = v, }

									ImGui.TableNextColumn()
									ImGui.SetNextItemWidth(140)
									local newKey = ImGui.InputText("##Key" .. k, self.TempSettings.GlobalItems[k].Key)

									ImGui.TableNextColumn()
									local newValue = ImGui.InputText("##Value" .. k, self.TempSettings.GlobalItems[k].Value)

									if newKey ~= k or newKey == "" then
										self.TempSettings.UpdatedGlobalItems[newKey] = newValue
										self.TempSettings.DeletedGlobalKeys[k] = true
									else
										self.TempSettings.UpdatedGlobalItems[k] = newValue
									end

									self.TempSettings.GlobalItems[k].Key = newKey
									self.TempSettings.GlobalItems[k].Value = newValue
								end
							end
						end
					end

					ImGui.EndTable()
				end
				ImGui.EndTabItem()
			end


			-- All Items
			-- if ImGui.BeginTabItem("All Items") then
			-- 	if self.TempSettings.BuyItems == nil then
			-- 		self.TempSettings.BuyItems = {}
			-- 	end
			-- 	ImGui.Text("Delete the Item Name to remove it from the table")

			-- 	if ImGui.BeginTable("Buy Items", col, ImGuiTableFlags.Borders) then
			-- 		for i = 1, col / 2 do
			-- 			ImGui.TableSetupColumn("Item")
			-- 			ImGui.TableSetupColumn("Qty")
			-- 		end
			-- 		ImGui.TableHeadersRow()

			-- 		local numDisplayColumns = col / 2

			-- 		if self.BuyItemsTable ~= nil and self.TempSettings.SortedBuyItemKeys ~= nil then
			-- 			local updatedItems = {}
			-- 			local deletedKeys = {}

			-- 			local numItems = #self.TempSettings.SortedBuyItemKeys
			-- 			local numRows = math.ceil(numItems / numDisplayColumns)

			-- 			for row = 1, numRows do
			-- 				for column = 0, numDisplayColumns - 1 do
			-- 					local index = row + column * numRows
			-- 					local k = self.TempSettings.SortedBuyItemKeys[index]
			-- 					if k then
			-- 						local v = self.BuyItemsTable[k]

			-- 						self.TempSettings.BuyItems[k] = self.TempSettings.BuyItems[k] or { Key = k, Value = v, }

			-- 						ImGui.TableNextColumn()
			-- 						local newKey = ImGui.InputText("##Key" .. k, self.TempSettings.BuyItems[k].Key)

			-- 						ImGui.TableNextColumn()
			-- 						local newValue = ImGui.InputText("##Value" .. k, self.TempSettings.BuyItems[k].Value)

			-- 						if newKey ~= k or newKey == "" then
			-- 							updatedItems[newKey] = newValue
			-- 							deletedKeys[k] = true
			-- 							self.TempSettings.NeedSave = true
			-- 						else
			-- 							updatedItems[k] = newValue
			-- 						end

			-- 						if newValue ~= v then
			-- 							self.TempSettings.NeedSave = true
			-- 						end

			-- 						self.TempSettings.BuyItems[k].Key = newKey
			-- 						self.TempSettings.BuyItems[k].Value = newValue
			-- 					end
			-- 				end
			-- 			end

			-- 			for k, v in pairs(updatedItems) do
			-- 				self.BuyItemsTable[k] = v
			-- 			end

			-- 			for k in pairs(deletedKeys) do
			-- 				self.BuyItemsTable[k] = nil
			-- 			end
			-- 		end

			-- 		ImGui.EndTable()
			-- 	end
			-- 	ImGui.EndTabItem()
			-- end
			ImGui.EndTabBar()
		end
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
		if params == "destroy" then
			RGMercUtils.DoCmd("/destroy")
		else
			RGMercUtils.DoCmd("/autoinv")
		end
	end
end

function Module:SetGlobalItem(params)
	if LootnScoot ~= nil then
		LootnScoot.commandHandler(params)
		if params == "destroy" then
			RGMercUtils.DoCmd("/destroy")
		else
			RGMercUtils.DoCmd("/autoinv")
		end
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
		self:LoadSettings()
	end
end

function Module:GiveTime(combat_state)
	if self.TempSettings.NeedSave then
		self:SaveSettings(false)
		self.TempSettings.NeedSave = false
		LootnScoot.Settings = {}
		LootnScoot.BuyItems = {}
		LootnScoot.GlobalItems = {}
		LootnScoot.Settings = self.settings
		LootnScoot.BuyItems = self.BuyItemsTable
		LootnScoot.GlobalItems = self.GlobalItemsTable
		LootnScoot.writeSettings()
		self:SortItemTables()
	end
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
