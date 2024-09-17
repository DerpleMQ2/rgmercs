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

Module.TempSettings      = {}
Module.BuyItemsTable     = {}
Module.GlobalItemsTable  = {}
Module.NormalItemsTable  = {}
Module.FAQ               = {}

Module.DefaultConfig     = {
	['DoLoot']          = { DisplayName = "DoLoot", Category = "Loot N Scoot", Tooltip = "Enables Loot Settings for Looting", Default = true, FAQ = "Why are my goobers not looting?", Answer = "You most likely have DoLoot turned off.", },

	--- Looted Settings
	['LootFile']        = { DisplayName = 'Loot File', Category = 'Loot Settings', Tooltip = "Where your loot.ini file lives", Default = LootnScoot.Settings.LootFile, FAQ = "Why is my loot Rules table empty?", Answer = "You most likely have your LootFile set to the wrong location or it is empty. You could also need to issue /rgl lootimport to import the items.", },
	['SettingsFile']    = { DisplayName = 'Loot Settings File', Category = 'Loot Settings', Tooltip = 'Location of LootnScoot settings file', Default = LootnScoot.Settings.SettingsFile, FAQ = "What file is used to create my initial settings?", Answer = "Your Default Settings File is located at " .. LootnScoot.Settings.SettingsFile, },
	['GlobalLootOn']    = { DisplayName = 'Do Global Loot', Category = 'Loot Settings', Tooltip = 'Enable Global Loot Items', Default = LootnScoot.Settings.GlobalLootOn, FAQ = "How do I set items to ALWAYS use a rule and never evaluate to something new??", Answer = "Turn on GlobalLootOn and Set the item as a GlobalItem with /rgl setglobalitem", },
	['CombatLooting']   = { DisplayName = "Loot In Combat", Category = 'Loot Settings', Tooltip = "Enables looting during combat. Not recommended on the MT", Default = LootnScoot.Settings.CombatLooting, FAQ = "Why are my goobers trying to Loot while fighting?", Answer = "You most likely have CombatLooting turned ON", },
	['CorpseRadius']    = { DisplayName = "Corpse Radius", Category = 'Loot Settings', Tooltip = "Radius to activly loot corpses", Default = LootnScoot.Settings.CorpseRadius, Min = 1, Max = 500, FAQ = "How do I keep my Goobers from running a mile away for a corpse?", Answer = "Adjust your CorpseRadius setting to a shorter range.", },
	['MobsTooClose']    = { DisplayName = "Mobs To Close", Category = 'Loot Settings', Tooltip = "Don't loot if mobs are in this range.", Default = LootnScoot.Settings.MobsTooClose, Min = 1, Max = 200, FAQ = "Why are my goobers not looting?", Answer = "You could have mobs to close to you, try setting MobsTooClose range lower.", },
	['SaveBagSlots']    = { DisplayName = "Save Bag Slots", Category = 'Loot Settings', Default = LootnScoot.Settings.SaveBagSlots, Min = 1, Max = 30, Tooltip = "Number of bag slots you would like to keep empty at all times. Stop looting if we hit this number", FAQ = "Why are my goobers not looting?", Answer = "You Might have run out of Free Bag Slots, SaveBagSlots setting will set the number of slots you always want to keep empty.", },
	['TributeKeep']     = { DisplayName = "Tribute Keep", Category = "Loot Settings", Default = LootnScoot.Settings.TributeKeep, Tooltip = "Keep items flagged Tribute", FAQ = "How do I Keep Items to Tribute?", Answer = "You need to turn on TributeKeep and set your MinTributeValue. If the item sells for less than our MinSellPrice and has a tribute value above our MinTributeValue we will mark it as Tribute and loot it.", },
	['MinTributeValue'] = { DisplayName = "Minimum Tribute Value", Category = "Loot Settings", Default = LootnScoot.Settings.MinTributeValue, Min = 1, Max = 99999, Tooltip = "Minimun Tribute points to keep item if TributeKeep is enabled.", FAQ = "Why are my goobers not Setting items to Tribute?", Answer = "You most likely have one of these: TributeKeep, or AddNewTributes turned off. Otherwise Check your MinTributeValue setting.", },
	['MinSellPrice']    = { DisplayName = "Minimum Sell Price", Category = "Loot Settings", Default = LootnScoot.Settings.MinSellPrice, Min = -1, Max = 999999, Tooltip = "Minimum Sell price to keep item. -1 = any", FAQ = "Why are my goobers not looting?", Answer = "The Items value might be lower than your MinSellPrice Setting.", },
	['StackPlatValue']  = { DisplayName = "Stack Plat Value", Default = LootnScoot.Settings.StackPlatValue, Min = -1, Max = 999999, Category = "Loot Settings", Tooltip = "Minimum sell value for full stack", FAQ = "Why are my goobers not looting stackable items?", Answer = "Check your StackPlatValue setting, this setting is the total value in Plat for a Full Stack Typically qyt(1000)", },
	['StackableOnly']   = { DisplayName = "Stackable Only", Default = LootnScoot.Settings.StackableOnly, Category = "Loot Settings", Tooltip = "Only loot stackable items", FAQ = "Why are my goobers Only Looting Stackingable Items?", Answer = "You most likely have StackableOnly turned On.", },
	['AlwaysEval']      = { DisplayName = "Always Evaluate", Default = LootnScoot.Settings.AlwaysEval, Category = "Loot Settings", Tooltip = "Re-Evaluate all *Non Quest* items. useful to update loot.ini after changing min sell values.", FAQ = "How do I make my Goobers automatically adjust the loot rules as I level up and things become less important?", Answer = "You Can turn on AlwaysEval. Then anytime you change your thresholds we will re-evaluate based on the new settings instead of the old saved ones.", },
	['BankTradeskills'] = { DisplayName = "Bank Tradeskil", Default = LootnScoot.Settings.BankTradeskills, Category = "Loot Settings", Tooltip = "Toggle flagging Tradeskill items as Bank or not.", FAQ = "Why am I looting all of this tradeskill stuff?", Answer = "You most likely have BankTradskills turned On", },
	['LootForage']      = { DisplayName = "Loot Forage", Default = LootnScoot.Settings.LootForage, Category = "Loot Settings", Tooltip = "Enable Looting of Foraged Items", FAQ = "How do I auto loot Foraged items?", Answer = "You can turn on LootForage to loot Foraged items.", },
	['LootNoDrop']      = { DisplayName = "Loot NoDrop", Default = LootnScoot.Settings.LootNoDrop, Category = "Loot Settings", Tooltip = "Enable Looting of NoDrop items", FAQ = "How do I make my Goobers loot NoDrop items?", Answer = "You can turn on LootNoDrop to enable looting of NODROP items and also LootNoDropNew will loot nodrop items you don't already have in the loot table.", },
	['LootNoDropNew']   = { DisplayName = "Loot NoDrop New", Default = LootnScoot.Settings.LootNoDropNew, Category = "Loot Settings", Tooltip = "Enable looting of new NoDrop items", FAQ = "How do I make my Goobers loot NoDrop items?", Answer = "You can turn on LootNoDrop to enable looting of NODROP items and also LootNoDropNew will loot nodrop items you don't already have in the loot table.", },
	['LootQuest']       = { DisplayName = "Loot Quest", Default = LootnScoot.Settings.LootQuest, Category = "Loot Settings", Tooltip = "Enable Looting of Items Marked 'Quest', requires LootNoDrop on to loot NoDrop quest items", FAQ = "How do I make my Goobers loot Quest items?", Answer = "If the Item is Marked as Quest or Quest|qty and you have LootQuest enabled you will loot Quest items up to their qty max or the default QuestKeep setting if not specified. If the Quest Item is NODROP you will also neeed LootNoDrop turned on.", },
	['DoDestroy']       = { DisplayName = "DoDestroy", Default = LootnScoot.Settings.DoDestroy, Category = "Loot Settings", Tooltip = "Enable Destroy functionality. Otherwise 'Destroy' acts as 'Ignore'", FAQ = "How do I make my Goobers delete items and clean their bags?", Answer = "If You enable DoDestroy, your Toons will destroy any items marked for Destroy in the loot Rules. You can enable AlwaysDestroy to make your toons also delete any item marked as IGNORE as well as DESTROY to clean the corpses.", },
	['AlwaysDestroy']   = { DisplayName = "Always Destroy", Default = LootnScoot.Settings.AlwaysDestroy, Category = "Loot Settings", Tooltip = "Always Destroy items to clean corpese Will Destroy Non-Quest items marked 'Ignore' items REQUIRES DoDestroy set to true", FAQ = "How can I make my Goobers Clean up after themselves?", Answer = "Enabling AlwaysDestroy and DoDestroy will make your toons try to destroy any items not deamed worthy of keeping.", },
	['QuestKeep']       = { DisplayName = "QuestKeep", Default = LootnScoot.Settings.QuestKeep, Min = 1, Max = 100, Category = "Loot Settings", Tooltip = "Default number to keep if item not set using Quest|# format.", FAQ = "I am on a mission and keep leaving behind Quest Items, how can I make sure to loot Quest Items?", Answer = " If you Enable LootQuest your toons will loot any items flagged as Quest up to the qty specified or the QuestKeep setting.", },
	['LootChannel']     = { DisplayName = "Loot Channel", Default = LootnScoot.Settings.LootChannel, Category = "Loot Settings", Tooltip = "Channel we report loot to.", FAQ = "I want to report to something other than DanNet how can I change this?", Answer = "Silly wabbit EQBC is for kids, but alas the LootChannel setting will change which channel you report back on if enabled.", },
	['GroupChannel']    = { DisplayName = "Group Channel", Default = LootnScoot.Settings.GroupChannel, Category = "Loot Settings", Tooltip = "Channel we use for Group Commands", FAQ = "I want to report to something other than DanNet how can I change this?", Answer = "Silly wabbit EQBC is for kids, but alas the GroupChannel setting will change which channel you report back to your group on if enabled.", },
	['ReportLoot']      = { DisplayName = "Report Loot", Default = LootnScoot.Settings.ReportLoot, Category = "Loot Settings", Tooltip = "Report loot items to group or not", FAQ = "I Can't see what the other Goobers are looting, how do I change that?", Answer = "Enable ReportLoot to report to the other characters what is looted.", },
	['SpamLootInfo']    = { DisplayName = "Spam LootInfo", Default = LootnScoot.Settings.SpamLootInfo, Category = "Loot Settings", Tooltip = "Echo Spam for Looting", FAQ = "Why is there so much loot spam?", Answer = "Disable SpamLootInfo to Disable your local echo when you loot.", },
	['LootForageSpam']  = { DisplayName = "Loot Forage Spam", Default = LootnScoot.Settings.LootForageSpam, Category = "Loot Settings", Tooltip = "Echo spam for Foraged Items", FAQ = "Why is there so much loot spam?", Answer = "Disable LootForageSpam to Disable your local echo when you loot Foraged Items.", },
	['AddNewSales']     = { DisplayName = "Add New Sales", Default = LootnScoot.Settings.AddNewSales, Category = "Loot Settings", Tooltip = "Adds 'Sell' Flag to items automatically if you sell them while the script is running", FAQ = "I don't want to go through and add each item to be sold or now, how do I automate this?", Answer = "Enable AddNewSales and your Goobers will set any item as Sell after seeing you sell one.", },
	['AddNewTributes']  = { DisplayName = "Add New Tributes", Default = LootnScoot.Settings.AddNewTributes, Category = "Loot Settings", Tooltip = "Adds 'Tribute' Flag to items automatically if you Tribute them while the script is running.", FAQ = "I don't want to go through and add each item to be Triobuted or now, how do I automate this?", Answer = "Enable AddNewTributes and your Goobers will set any item as Tribute after seeing you Tribute one.", },
	['ExcludeBag1']     = { DisplayName = "Exclude Bag1", Default = LootnScoot.Settings.ExcludeBag1, Category = "Loot Settings", Tooltip = "Name of Bag to ignore items in when selling", FAQ = "I want to not sell anything in a certain bag. How can I do that?", Answer = " You can set ExcludeBag# to ignore all items in that bag when selling / tributing.", },
	['HideNames']       = { DisplayName = "Hide Names", Default = LootnScoot.Settings.HideNames, Category = "Loot Settings", Tooltip = "Hides names and uses class shortname in looted window", },
	['RecordData']      = { DisplayName = "Record Data", Default = LootnScoot.Settings.RecordData, Category = "Loot Settings", Tooltip = "Enables recording data to report later", FAQ = "How do I see what has been looted for the session?", Answer = "If you enable RecordDate you can view the report via /rgl reportloot. This will display a Table of items Looted in this session and allow you can adjust their settings with a right click.", },
	['AutoTag']         = { DisplayName = "Auto Tag", Default = LootnScoot.Settings.AutoTag, Category = "Loot Settings", Tooltip = "Automatically tag items to sell if they meet the MinSellPrice", FAQ = "I am lazy and don't want to manually edit anything besides my thresholds. How can I automate setting the Item Rules?", Answer = "You can enable the AutoTag setting, this will set your item rules based on the evaulation. Normally we only record Keep and Ignore unless and let the user pick beyond that. With the exception of AddNewSales, and AddNewTribute", },
	['AutoRestock']     = { DisplayName = "Auto Restock", Default = LootnScoot.Settings.AutoRestock, Category = "Loot Settings", Tooltip = "Automatically restock items from the BuyItems list when selling", FAQ = "I keep forgetting to buy stuff, how can I make sure I have food, drink and reagents?", Answer = "Set the items you would like to buy all the time in the BuyItems section. You can do this through the GUI. Then Enable AutoRestock and your toons will purchase what they can after selling to the merchant.", },
	['LookupLinks']     = { DisplayName = "Lookup Links", Default = LootnScoot.Settings.LookupLinks, Category = "Loot Settings", Tooltip = "Enables Looking up Links for items not on that character. *recommend only running on one charcter that is monitoring.", },
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
	lootimport = {
		usage = "/rgl lootimport",
		about =
		"Imports from INI to LootRules DB. Incase you were running in standalone mode prior to running RGMercs Lua. This may cause a some lag. Only Run on ONE Character to populate / update the DB.",
		handler = function(self, _)
			self:LootUpdate()
		end,
	},
}

Module.DefaultCategories = Set.new({})
for _, v in pairs(Module.DefaultConfig or {}) do
	if v.Type ~= "Custom" then
		Module.DefaultCategories:add(v.Category)
	end
	Module.FAQ[_] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', settingName = _, }
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
	if not LootnScoot then return end
	mq.pickle(getConfigFileName(), self.settings)
	mq.pickle(getLootItemsConfigFileName('buy'), self.BuyItemsTable)
	self:SortItemTables()
	if doBroadcast == true then
		RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
	end
	LootnScoot.BuyItems = {}
	LootnScoot.Settings = {}
	LootnScoot.Settings = self.settings
	LootnScoot.BuyItems = self.BuyItemsTable
end

function Module:ModifyLootSettings()
	if not LootnScoot then return end
	if LootnScoot.Settings ~= nil then
		self.settings = LootnScoot.Settings
	end
	if LootnScoot.GlobalItems ~= nil then
		self.GlobalItemsTable = LootnScoot.GlobalItems
	end
	if LootnScoot.BuyItems ~= nil then
		self.BuyItemsTable = LootnScoot.BuyItems
	end
	if LootnScoot.NormalItems ~= nil then
		self.NormalItemsTable = LootnScoot.NormalItems
	end
	self:SaveSettings(false)
end

function Module:LoadSettings()
	if not LootnScoot then return end
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

	local needsSave = false
	-- Setup Defaults
	self.settings, needsSave = RGMercUtils.ResolveDefaults(Module.DefaultConfig, self.settings)

	RGMercsLogger.log_debug("Settings Changes = %s", RGMercUtils.BoolToColorString(needsSave))
	if needsSave then
		self:SaveSettings(false)
	end

	if LootnScoot.GlobalItems ~= nil then
		self.GlobalItemsTable = LootnScoot.GlobalItems
	end
	if LootnScoot.BuyItems ~= nil then
		self.BuyItemsTable = LootnScoot.BuyItems
	end
	if LootnScoot.NormalItems ~= nil then
		self.NormalItemsTable = LootnScoot.NormalItems
	end

	-- lootnscoot tables
	local buyItems_pickle_path = getLootItemsConfigFileName('buy')
	local buyItemsLoad, err = loadfile(buyItems_pickle_path)
	if err or not buyItemsLoad then
		RGMercsLogger.log_error("\ay[LOOT]: \aoUnable to load BUY ITEMS file(%s), creating a new one!",
			buyItems_pickle_path)
		self:SaveSettings(false)
	else
		self.TempSettings.BuyItemsTableLoad = buyItemsLoad()
		--- make sure the saved table isn't empty
		for k, v in pairs(self.TempSettings.BuyItemsTableLoad) do
			if k == nil then
				self.BuyItemsTable = LootnScoot.BuyItems
				self:SaveSettings(false)
				break
			else
				self.BuyItemsTable = {}
				self.BuyItemsTable = buyItemsLoad()
				break
			end
		end
	end

	--pass settings to lootnscoot lib
	LootnScoot.Settings = {}
	LootnScoot.BuyItems = {}
	LootnScoot.Settings = self.settings
	LootnScoot.BuyItems = self.BuyItemsTable

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

	self.TempSettings.SortedNormalItemKeys = {}
	for k in pairs(self.NormalItemsTable) do
		table.insert(self.TempSettings.SortedNormalItemKeys, k)
	end
	table.sort(self.TempSettings.SortedNormalItemKeys, function(a, b) return a < b end)
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
	self.TempSettings.NeedSave = LootnScoot.init()

	self:LoadSettings()
	if not RGMercUtils.OnEMU() then
		RGMercsLogger.log_debug("\ay[LOOT]: \agWe are not on EMU unloading module. Build: %s", mq.TLO.MacroQuest.BuildName())
		LootnScoot = nil
	else
		RGMercsLogger.log_debug("\ay[LOOT]: \agLoot for EMU module Loaded.")
	end

	return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
	return RGMercUtils.OnEMU()
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
			local col = math.max(2, math.floor(ImGui.GetContentRegionAvail() / 150))
			col = col + (col % 2)

			-- Buy Items
			if ImGui.BeginTabItem("Buy Items##LootModule") then
				if self.TempSettings.BuyItems == nil then
					self.TempSettings.BuyItems = {}
				end
				ImGui.Text("Delete the Item Name to remove it from the table")

				if ImGui.SmallButton("Save Changes##BuyItems") then
					for k, v in pairs(self.TempSettings.UpdatedBuyItems) do
						if k ~= "" then
							self.BuyItemsTable[k] = v
						end
					end

					for k in pairs(self.TempSettings.DeletedBuyKeys) do
						self.BuyItemsTable[k] = nil
					end

					self.TempSettings.UpdatedBuyItems = {}
					self.TempSettings.DeletedBuyKeys = {}

					self.TempSettings.NeedSave = true
				end

				self.TempSettings.SearchBuyItems = ImGui.InputText("Search Items##NormalItems", self.TempSettings.SearchBuyItems) or nil
				ImGui.SeparatorText("Add New Item")
				if ImGui.BeginTable("AddItem", 3, ImGuiTableFlags.Borders) then
					ImGui.TableSetupColumn("Item")
					ImGui.TableSetupColumn("Qty")
					ImGui.TableSetupColumn("Add")
					ImGui.TableHeadersRow()
					ImGui.TableNextColumn()

					ImGui.SetNextItemWidth(150)
					self.TempSettings.NewBuyItem = ImGui.InputText("New Item##BuyItems", self.TempSettings.NewBuyItem)

					ImGui.TableNextColumn()
					ImGui.SetNextItemWidth(120)

					self.TempSettings.NewBuyQty = ImGui.InputInt("New Qty##BuyItems", (self.TempSettings.NewBuyQty or 1), 1, 50)
					if self.TempSettings.NewBuyQty > 1000 then self.TempSettings.NewBuyQty = 1000 end

					ImGui.TableNextColumn()

					if ImGui.Button("Add Item##BuyItems") then
						self.BuyItemsTable[self.TempSettings.NewBuyItem] = self.TempSettings.NewBuyQty
						LootnScoot.setBuyItem(self.TempSettings.NewBuyItem, self.TempSettings.NewBuyQty)
						self.TempSettings.NeedSave = true
						self.TempSettings.NewBuyItem = ""
						self.TempSettings.NewBuyQty = 1
					end
					ImGui.EndTable()
				end
				ImGui.SeparatorText("Buy Items Table")
				if ImGui.BeginTable("Buy Items", col, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.ScrollY), ImVec2(0.0, 0.0)) then
					ImGui.TableSetupScrollFreeze(col, 1)
					for i = 1, col / 2 do
						ImGui.TableSetupColumn("Item")
						ImGui.TableSetupColumn("Qty")
					end
					ImGui.TableHeadersRow()

					local numDisplayColumns = col / 2

					if self.BuyItemsTable ~= nil and self.TempSettings.SortedBuyItemKeys ~= nil then
						self.TempSettings.UpdatedBuyItems = {}
						self.TempSettings.DeletedBuyKeys = {}

						local numItems = #self.TempSettings.SortedBuyItemKeys
						local numRows = math.ceil(numItems / numDisplayColumns)

						for row = 1, numRows do
							for column = 0, numDisplayColumns - 1 do
								local index = row + column * numRows
								local k = self.TempSettings.SortedBuyItemKeys[index]
								if k then
									local v = self.BuyItemsTable[k]
									if (self.TempSettings.SearchBuyItems == nil or self.TempSettings.SearchBuyItems == "") or k:lower():find(self.TempSettings.SearchBuyItems:lower()) then
										self.TempSettings.BuyItems[k] = self.TempSettings.BuyItems[k] or { Key = k, Value = v, }

										ImGui.TableNextColumn()
										local newKey = ImGui.InputText("##Key" .. k, self.TempSettings.BuyItems[k].Key)

										ImGui.TableNextColumn()
										local newValue = ImGui.InputText("##Value" .. k, self.TempSettings.BuyItems[k].Value)

										if newValue ~= v and newKey == k then
											if newValue == "" then newValue = "NULL" end
											self.TempSettings.UpdatedBuyItems[newKey] = newValue
										elseif newKey ~= "" and newKey ~= k then
											self.TempSettings.DeletedBuyKeys[k] = true
											if newValue == "" then newValue = "NULL" end
											self.TempSettings.UpdatedBuyItems[newKey] = newValue
										elseif newKey ~= k and newKey == "" then
											self.TempSettings.DeletedBuyKeys[k] = true
										end

										self.TempSettings.BuyItems[k].Key = newKey
										self.TempSettings.BuyItems[k].Value = newValue
									end
								end
							end
						end
					end

					ImGui.EndTable()
				end
				ImGui.EndTabItem()
			end

			-- Global Items
			if ImGui.BeginTabItem("Global Items##LootModule") then
				if self.TempSettings.GlobalItems == nil then
					self.TempSettings.GlobalItems = {}
				end
				ImGui.Text("Delete the Item Name to remove it from the table")

				if ImGui.SmallButton("Save Changes##GlobalItems") then
					for k, v in pairs(self.TempSettings.UpdatedGlobalItems) do
						if k ~= "" then
							self.GlobalItemsTable[k] = v
							LootnScoot.setGlobalItem(k, v)
							LootnScoot.lootActor:send({ mailbox = 'lootnscoot', },
								{ who = RGMercConfig.Globals.CurLoadedChar, action = 'modifyitem', section = "GlobalItems", item = k, rule = v, })
						end
					end

					for k in pairs(self.TempSettings.DeletedGlobalKeys) do
						self.GlobalItemsTable[k] = nil
						LootnScoot.setGlobalItem(k, 'delete')
						LootnScoot.lootActor:send({ mailbox = 'lootnscoot', },
							{ who = RGMercConfig.Globals.CurLoadedChar, section = "GlobalItems", action = 'deleteitem', item = k, })
					end
					self.TempSettings.UpdatedGlobalItems = {}
					self.TempSettings.DeletedGlobalKeys = {}

					self:SortItemTables()
				end

				self.TempSettings.SearchGlobalItems = ImGui.InputText("Search Items##NormalItems", self.TempSettings.SearchGlobalItems) or nil
				ImGui.SeparatorText("Add New Item##GlobalItems")
				if ImGui.BeginTable("AddItem##GlobalItems", 3, ImGuiTableFlags.Borders) then
					ImGui.TableSetupColumn("Item")
					ImGui.TableSetupColumn("Value")
					ImGui.TableSetupColumn("Add")
					ImGui.TableHeadersRow()
					ImGui.TableNextColumn()

					ImGui.SetNextItemWidth(150)
					self.TempSettings.NewGlobalItem = ImGui.InputText("New Item##GlobalItems", self.TempSettings.NewGlobalItem) or nil

					ImGui.TableNextColumn()
					ImGui.SetNextItemWidth(120)

					self.TempSettings.NewGlobalValue = ImGui.InputTextWithHint("New Value##GlobalItems", "Quest, Keep, Sell, Tribute, Bank, Ignore, Destroy",
						self.TempSettings.NewGlobalValue) or nil

					ImGui.TableNextColumn()

					if ImGui.Button("Add Item##GlobalItems") then
						if self.TempSettings.NewGlobalValue ~= "" and self.TempSettings.NewGlobalValue ~= "" then
							self.GlobalItemsTable[self.TempSettings.NewGlobalItem] = self.TempSettings.NewGlobalValue
							LootnScoot.setGlobalItem(self.TempSettings.NewGlobalItem, self.TempSettings.NewGlobalValue)
							LootnScoot.lootActor:send({ mailbox = 'lootnscoot', },
								{
									who = RGMercConfig.Globals.CurLoadedChar,
									action = 'addrule',
									section = "GlobalItems",
									item = self.TempSettings.NewGlobalItem,
									rule = self.TempSettings.NewGlobalValue,
								})

							self.TempSettings.NewGlobalItem = ""
							self.TempSettings.NewGlobalValue = ""
						end
					end
					ImGui.EndTable()
				end
				ImGui.SeparatorText("Global Items Table")
				if ImGui.BeginTable("GlobalItems", col, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.ScrollY), ImVec2(0.0, 0.0)) then
					ImGui.TableSetupScrollFreeze(col, 1)
					for i = 1, col / 2 do
						ImGui.TableSetupColumn("Item")
						ImGui.TableSetupColumn("Setting")
					end
					ImGui.TableHeadersRow()

					local numDisplayColumns = col / 2

					if self.GlobalItemsTable ~= nil and self.TempSettings.SortedGlobalItemKeys ~= nil then
						self.TempSettings.UpdatedGlobalItems = {}
						self.TempSettings.DeletedGlobalKeys = {}

						local numItems = #self.TempSettings.SortedGlobalItemKeys
						local numRows = math.ceil(numItems / numDisplayColumns)

						for row = 1, numRows do
							for column = 0, numDisplayColumns - 1 do
								local index = row + column * numRows
								local k = self.TempSettings.SortedGlobalItemKeys[index]
								if k then
									local v = self.GlobalItemsTable[k]
									if (self.TempSettings.SearchGlobalItems == nil or self.TempSettings.SearchGlobalItems == "") or k:lower():find(self.TempSettings.SearchGlobalItems:lower()) then
										self.TempSettings.GlobalItems[k] = self.TempSettings.GlobalItems[k] or { Key = k, Value = v, }

										ImGui.TableNextColumn()
										ImGui.SetNextItemWidth(140)
										local newKey = ImGui.InputText("##Key" .. k, self.TempSettings.GlobalItems[k].Key)

										ImGui.TableNextColumn()
										local newValue = ImGui.InputText("##Value" .. k, self.TempSettings.GlobalItems[k].Value)

										if newValue ~= v and newKey == k then
											if newValue == "" then newValue = "NULL" end
											self.TempSettings.UpdatedGlobalItems[newKey] = newValue
										elseif newKey ~= "" and newKey ~= k then
											self.TempSettings.DeletedGlobalKeys[k] = true
											if newValue == "" then newValue = "NULL" end
											self.TempSettings.UpdatedGlobalItems[newKey] = newValue
										elseif newKey ~= k and newKey == "" then
											self.TempSettings.DeletedGlobalKeys[k] = true
										end

										self.TempSettings.GlobalItems[k].Key = newKey
										self.TempSettings.GlobalItems[k].Value = newValue
									end
								end
							end
						end
					end

					ImGui.EndTable()
				end

				ImGui.EndTabItem()
			end

			-- Normal Items
			if ImGui.BeginTabItem("Normal Items##LootModule") then
				if self.TempSettings.NormalItems == nil then
					self.TempSettings.NormalItems = {}
				end
				ImGui.Text("Delete the Item Name to remove it from the table")

				if ImGui.SmallButton("Save Changes##NormalItems") then
					for k, v in pairs(self.TempSettings.UpdatedNormalItems) do
						self.NormalItemsTable[k] = v
						LootnScoot.setNormalItem(k, v)
						LootnScoot.lootActor:send({ mailbox = 'lootnscoot', },
							{ who = RGMercConfig.Globals.CurLoadedChar, action = 'modifyitem', section = "NormalItems", item = k, rule = v, })
					end
					self.TempSettings.UpdatedNormalItems = {}

					for k in pairs(self.TempSettings.DeletedNormalKeys) do
						self.NormalItemsTable[k] = nil
						LootnScoot.setNormalItem(k, 'delete')
						LootnScoot.lootActor:send({ mailbox = 'lootnscoot', },
							{ who = RGMercConfig.Globals.CurLoadedChar, action = 'deleteitem', section = "NormalItems", item = k, })
					end
					self.TempSettings.DeletedNormalKeys = {}
					self:SortItemTables()
				end

				self.TempSettings.SearchItems = ImGui.InputText("Search Items##NormalItems", self.TempSettings.SearchItems) or nil

				if ImGui.BeginTable("NormalItems", col, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.ScrollY), ImVec2(0.0, 0.0)) then
					ImGui.TableSetupScrollFreeze(col, 1)
					for i = 1, col / 2 do
						ImGui.TableSetupColumn("Item")
						ImGui.TableSetupColumn("Setting")
					end
					ImGui.TableHeadersRow()

					local numDisplayColumns = col / 2

					if self.NormalItemsTable ~= nil and self.TempSettings.SortedNormalItemKeys ~= nil then
						self.TempSettings.UpdatedNormalItems = {}
						self.TempSettings.DeletedNormalKeys = {}

						local numItems = #self.TempSettings.SortedNormalItemKeys
						local numRows = math.ceil(numItems / numDisplayColumns)

						for row = 1, numRows do
							for column = 0, numDisplayColumns - 1 do
								local index = row + column * numRows
								local k = self.TempSettings.SortedNormalItemKeys[index]
								if k then
									local v = self.NormalItemsTable[k]
									if (self.TempSettings.SearchItems == nil or self.TempSettings.SearchItems == "") or k:lower():find(self.TempSettings.SearchItems:lower()) then
										self.TempSettings.NormalItems[k] = self.TempSettings.NormalItems[k] or { Key = k, Value = v, }

										ImGui.TableNextColumn()
										ImGui.SetNextItemWidth(140)
										local newKey = ImGui.InputText("##Key" .. k, self.TempSettings.NormalItems[k].Key)

										ImGui.TableNextColumn()
										local newValue = ImGui.InputText("##Value" .. k, self.TempSettings.NormalItems[k].Value)

										if newValue ~= v and newKey == k then
											if newValue == "" then newValue = "NULL" end
											self.TempSettings.UpdatedNormalItems[newKey] = newValue
										elseif newKey ~= "" and newKey ~= k then
											self.TempSettings.DeletedNormalKeys[k] = true
											if newValue == "" then newValue = "NULL" end
											self.TempSettings.UpdatedNormalItems[newKey] = newValue
										elseif newKey ~= k and newKey == "" then
											self.TempSettings.DeletedNormalKeys[k] = true
										end

										self.TempSettings.NormalItems[k].Key = newKey
										self.TempSettings.NormalItems[k].Value = newValue
									end
								end
							end
						end
					end

					ImGui.EndTable()
				end
				ImGui.EndTabItem()
			end

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
		-- LootnScoot.commandHandler('reload')
		LootnScoot.lootActor:send({ mailbox = 'lootnscoot', }, { who = RGMercConfig.Globals.CurLoadedChar, action = 'lootreload', })
		self:LoadSettings()
	end
end

function Module:LootUpdate()
	if LootnScoot ~= nil then
		LootnScoot.commandHandler('update')
		self:LoadSettings()
	end
end

function Module:GiveTime(combat_state)
	if not LootnScoot then return end
	if not RGMercUtils.GetSetting('DoLoot') then return end

	if self.TempSettings.NeedSave then
		self:SaveSettings(false)
		self.TempSettings.NeedSave = false
		self:SortItemTables()
	end
	-- Main Module logic goes here.
	if RGMercUtils.GetXTHaterCount() == 0 or RGMercUtils.GetSetting('CombatLooting') then
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
	return { module = self._name, CommandHandlers = self.CommandHandlers, }
end

function Module:GetFAQ()
	return { module = self._name, FAQ = self.FAQ, }
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
