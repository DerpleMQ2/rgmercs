-- Sample Basic Class Module
local mq        = require('mq')
local Config    = require('utils.config')
local Core      = require("utils.core")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Ui        = require("utils.ui")
local Comms     = require("utils.comms")
local Tables    = require("utils.tables")
local Strings   = require("utils.strings")
local Files     = require("utils.files")
local Logger    = require("utils.logger")
local Modules   = require("utils.modules")
local Set       = require("mq.Set")
local Icons     = require('mq.ICONS')

require('utils.datatypes')

local Module                     = { _version = '0.1a', _name = "Charm", _author = 'Grimmier', }
Module.__index                   = Module
Module.ModuleLoaded              = false
Module.CombatState               = "None"
Module.SaveRequested             = nil

Module.TempSettings              = {}
Module.TempSettings.CharmImmune  = {}
Module.TempSettings.CharmTracker = {}
Module.FAQ                       = {}
Module.ImmuneTable               = {}

Module.DefaultConfig             = {
	-- General
	['CharmOn']                                = {
		DisplayName           = "Charm On",
		Group                 = "Abilities",
		Header                = "Charm",
		Category              = "Charm General",
		Index                 = 1,
		Default               = false,
		Tooltip               = "Set to use charm spells.",
		RequiresLoadoutChange = true,
		FAQ                   = "How do I make my [Bard, Enchanter, Druid, Necro] Charm pets?",
		Answer                = "Bards, Enchanters, Druids, and Necros all have the option to Enable [CharmOn] so they can Charm a pet.",
	},
	['DireCharm']                              = {
		DisplayName = "Dire Charm",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm General",
		Index       = 2,
		Default     = false,
		Tooltip     = "Use DireCharm AA",
		FAQ         = "How do I use Dire Charm AA?",
		Answer      = "Enable [DireCharm] setting and we will attempt to use [DireCharm] based upon the other settings.",
	},
	['PreferCharm']                            = {
		DisplayName = "Prefer Charmed Pet",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm General",
		Index       = 3,
		Default     = false,
		Tooltip     = "Prefer to use a charmed pet over a summoned pet.",
		FAQ         = "I want to only use Charm Pets and ignore summoning my own, can I do that?",
		Answer      =
		"The setting is currently there but not implimented yet [PreferCharm].\n\nIf you have [DoCharm] enabled you shouldn't try to summon a pet.",
	},
	['CharmStartCount']                        = {
		DisplayName = "Charm Start Count",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm General",
		Index       = 4,
		Default     = 2,
		Min         = 1,
		Max         = 20,
		Tooltip     = "Sets # of mobs needed to start using Charm spells. ( Default 2 )",
		FAQ         = "My Charmer doesn't Charm, why?",
		Answer      =
		"Make sure your [CharmStartCount] setting is at an appropriate level.\n\nThis setting is the minimum mobs on Xtarget before we start Trying to Charm.",
	},
	['CharmRadius']                            = {
		DisplayName = "Charm Radius",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm General",
		Index       = 5,
		Default     = 100,
		Min         = 1,
		Max         = 200,
		Tooltip     = "Radius for mobs to be in to start Charming, An area twice this size is monitored for aggro mobs",
		FAQ         = "Why won't I Charm pets?",
		Answer      = "Your [CharmRadius] may be set to low.\nIncrease this to charm mobs farther away from you.",
	},
	['CharmZRadius']                           = {
		DisplayName = "Charm ZRadius",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm General",
		Index       = 6,
		Default     = 15,
		Min         = 1,
		Max         = 200,
		Tooltip     =
		"Height radius (z-value) for mobs to be in to start charming. An area twice this size is monitored for aggro mobs. If you're enchanter is not charming on hills -- increase this value.",
		FAQ         = "Why won't I Charm pets?",
		Answer      = "Your [CharmZRadius] may be set to low.\n\nIncrease this to charm mobs farther above / below you.",
	},
	-- Targets
	['CharmStopHPs']                           = {
		DisplayName = "Charm Stop HPs",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm Targets",
		Index       = 1,
		Default     = 80,
		Min         = 1,
		Max         = 100,
		Tooltip     = "Mob HP% to stop trying to charm",
		FAQ         = "Why are all of my Charm Pets nearly Dead?",
		Answer      = "Raise the [CharmStopHPs] setting so you won't try to charm a mob below that health Percentage.",
	},
	['AutoLevelRangeCharm']                    = {
		DisplayName = "Auto Level Range",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm Targets",
		Index       = 2,
		Default     = true,
		Tooltip     = "Set to enable automatic charm level detection based on spells.",
		FAQ         = "I don't know what lvl my charm spell maxes at?",
		Answer      =
		"Enable [AutoLevelRangeCharm] to have the max level set for you based on the currently selected spell.",
	},
	['CharmMinLevel']                          = {
		DisplayName = "Charm Min Level",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm Targets",
		Index       = 3,
		Default     = 0,
		Min         = 1,
		Max         = 200,
		Tooltip     =
		"Minimum Level a mob must be to Charm - Below this lvl are ignored. 0 means no mobs ignored.\n\nNOTE: [AutoLevelRange] must be OFF!",
		FAQ         = "Why do I keep charming Grey Con mobs?",
		Answer      =
		"Adjust the [CharmMinLevel] to an appropriate level so you don't try to charm spawns lower level than you want.",
	},
	['CharmMaxLevel']                          = {
		DisplayName = "Charm Max Level",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm Targets",
		Index       = 4,
		Default     = 0,
		Min         = 1,
		Max         = 200,
		Tooltip     =
		"Maximum Level a mob must be to Charm - Above this lvl are ignored. 0 means no mobs ignored.\n\nNOTE: [AutoLevelRange] must be OFF!",
		FAQ         = "Why won't I Charm pets?",
		Answer      =
		"Your [CharmMaxLevel] may be set to High.\n\nSet this to the Max Level your charm spell can handle.\n\nYou can also enable [AutoLevelRangeCharm] and have it do this for you.",
	},
	['DireCharmMaxLvl']                        = {
		DisplayName = "DireCharm Max Level",
		Group       = "Abilities",
		Header      = "Charm",
		Category    = "Charm Targets",
		Index       = 5,
		Default     = 0,
		Min         = 1,
		Max         = 200,
		Tooltip     =
		"Maximum Level a mob must be to DireCharm - Above this lvl are ignored. 0 means no mobs ignored.\n\nNOTE: [AutoLevelRange] must be OFF!",
		FAQ         = "Why can't I land a Dire Charm?",
		Answer      =
			"Your [DireCharmMaxLvl] may be set to High.\n\nAdjust approptiatly or Enable [AutoLevelRangeCharm] and set the value really High, " ..
			"to have this automatically adjust down to find the appropriate level for you.",
	},
	[string.format("%s_Popped", Module._name)] = {
		DisplayName = Module._name .. " Popped",
		Type = "Custom",
		Default = false,
	},
}

Module.FAQ                       = {
	[1] = {
		Question      = 'Why does my Charmer Not Charm ANYTHING?',
		Answer        =
			"Make sure you have [CharmOn] enabled.\nAlso Double check that your are in the Right lvl range between [CharmMinLevel] and [CharmMaxLevel].\n\n" ..
			"Alternately  you can enable [AutoLevelRangeCharm] so it will configure the MaxLevel for you.",
		Settings_Used = 'CharmOn, AutoLevelRangeCharm, CharmMinLevel, CharmMaxLevel',
	},
	[2] = {
		Question      = "Can I specify a pet to always recharm?",
		Answer        =
			"Not currently, but we can add this feature if it's needed.\n\nCurrently we will attempt to recharm if the spawn is still within our thresholds for health and number of spawns in came.\n" ..
			"You can also try setting [CharmStartCount] to 1 or 0 and see if that helps.",
		Settings_Used = "CharmOn, CharmStartCount",
	},
	[3] = {
		Question      = "Why is my Charmed Pet not engaging in combat?",
		Answer        = "You will want to turn on [DoPet] in your Main Config Options section, under the Pet/Merc tab.",
		Settings_Used = "DoPet",
	},
}

local function getConfigFileName()
	local oldFile = mq.configDir ..
		'/rgmercs/PCConfigs/' ..
		Module._name .. "_" .. Config.Globals.CurServer .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
	local newFile = mq.configDir ..
		'/rgmercs/PCConfigs/' ..
		Module._name .. "_" .. Config.Globals.CurServer .. "_" .. Config.Globals.CurLoadedChar .. "_" .. Config.Globals.CurLoadedClass:lower() .. '.lua'

	if Files.file_exists(newFile) then
		return newFile
	end

	Files.copy_file(oldFile, newFile)

	return newFile
end

local function getImmuneFileName()
	return mq.configDir ..
		'/rgmercs/PCConfigs/' ..
		Module._name .. "_Immune_" .. Config.Globals.CurServer .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
	self.SaveRequested = { time = os.time(), broadcast = doBroadcast or false, }
end

function Module:WriteSettings()
	if not self.SaveRequested then return end

	mq.pickle(getConfigFileName(), Config:GetModuleSettings(self._name))

	if self.SaveRequested.doBroadcast == true then
		Comms.BroadcastUpdate(self._name, "LoadSettings")
	end

	Logger.log_debug("\ag%s Module settings saved to %s, requested %s ago.", self._name, getConfigFileName(), Strings.FormatTime(os.time() - self.SaveRequested.time))

	self.SaveRequested = nil
end

function Module:LoadSettings()
	Logger.log_debug("\ar%s\ao Charm Module Loading Settings for: %s.", Config.Globals.CurLoadedClass,
		Config.Globals.CurLoadedChar)
	local settings_pickle_path = getConfigFileName()
	local settings = {}
	local firstSaveRequired = false

	local config, err = loadfile(settings_pickle_path)
	if err or not config then
		Logger.log_error("\ay[%s]: Unable to load module settings file(%s), creating a new one!",
			Config.Globals.CurLoadedClass, settings_pickle_path)
		firstSaveRequired = true
	else
		settings = config()
	end

	if not settings or not self.DefaultConfig then
		Logger.log_error("\arFailed to Load Charm Config for Classs: %s", Config.Globals.CurLoadedClass)
		return
	end

	local immune_pickle_path = getImmuneFileName()
	local immuneConfig, immuneErr = loadfile(immune_pickle_path)
	if immuneErr or not immuneConfig then
		Logger.log_error("\ay[%s]: Unable to load Immune settings file(%s), creating a new one!",
			Config.Globals.CurLoadedClass, immune_pickle_path)
		self.ImmuneTable = {}
		mq.pickle(immune_pickle_path, self.ImmuneTable)
	else
		self.ImmuneTable = immuneConfig()
	end

	Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)
end

function Module.New()
	local newModule = setmetatable({}, Module)
	return newModule
end

function Module:Init()
	Logger.log_debug("\agInitializing Charm Module...")
	-- bards don't have DireCharm so hide the settings.
	if Core.MyClassIs("BRD") then
		self.DefaultConfig['DireCharm'] = nil
		self.DefaultConfig['DireCharmMaxLvl'] = nil
	end
	self:LoadSettings()

	self.ModuleLoaded = true

	return { self = self, defaults = self.DefaultConfig, }
end

function Module:ShouldRender()
	return Modules:ExecModule("Class", "CanCharm")
end

function Module:Render()
	Ui.RenderPopAndSettings(self._name)

	if self.ModuleLoaded then
		-- CCEd targets
		if ImGui.CollapsingHeader("Charm Target List") then
			ImGui.Indent()
			if ImGui.BeginTable("CharmedList", 4, bit32.bor(ImGuiTableFlags.None, ImGuiTableFlags.Borders, ImGuiTableFlags.Reorderable, ImGuiTableFlags.Resizable, ImGuiTableFlags.Hideable)) then
				ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
				ImGui.TableSetupColumn('Id', (ImGuiTableColumnFlags.WidthFixed), 70.0)
				ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 250.0)
				ImGui.TableSetupColumn('Level', (ImGuiTableColumnFlags.WidthFixed), 150.0)
				ImGui.TableSetupColumn('Body', (ImGuiTableColumnFlags.WidthStretch), 150.0)
				ImGui.PopStyleColor()
				ImGui.TableHeadersRow()
				for id, data in pairs(self.TempSettings.CharmTracker) do
					ImGui.TableNextColumn()
					ImGui.Text(id)
					ImGui.TableNextColumn()
					ImGui.Text(data.name)
					ImGui.TableNextColumn()
					ImGui.Text(data.level)
					ImGui.TableNextColumn()
					ImGui.Text(data.body)
				end
				ImGui.EndTable()
			end
			ImGui.Unindent()
		end

		ImGui.Separator()
		-- Immune targets
		if ImGui.CollapsingHeader("Invalid Charm Targets") then
			ImGui.Indent()
			if ImGui.BeginTable("Immune", 5, bit32.bor(ImGuiTableFlags.None, ImGuiTableFlags.Borders, ImGuiTableFlags.Reorderable, ImGuiTableFlags.Resizable, ImGuiTableFlags.Hideable)) then
				ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
				ImGui.TableSetupColumn('Id', (ImGuiTableColumnFlags.WidthFixed), 70.0)
				ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthStretch), 250.0)
				ImGui.TableSetupColumn('Lvl', ImGuiTableColumnFlags.WidthFixed, 70.0)
				ImGui.TableSetupColumn('Body', (ImGuiTableColumnFlags.WidthFixed), 90.0)
				ImGui.TableSetupColumn('Reason', (ImGuiTableColumnFlags.WidthFixed), 90.0)
				ImGui.PopStyleColor()
				ImGui.TableHeadersRow()
				for id, data in pairs(self.TempSettings.CharmImmune) do
					ImGui.TableNextColumn()
					ImGui.Text(id)
					ImGui.TableNextColumn()
					ImGui.Text(data.name)
					ImGui.TableNextColumn()
					ImGui.Text(data.lvl)
					ImGui.TableNextColumn()
					ImGui.Text(data.body)
					ImGui.TableNextColumn()
					ImGui.TextColored(ImVec4(0.983, 0.729, 0.290, 1.000), "%s", data.reason)
				end
				for name, data in pairs(self.ImmuneTable[mq.TLO.Zone.ShortName()] or {}) do
					for lvl, body in pairs(data) do
						for bodyType, reason in pairs(body) do
							ImGui.TableNextColumn()
							if ImGui.SmallButton(Icons.MD_DELETE .. '##' .. name .. lvl .. bodyType) then
								self.ImmuneTable[mq.TLO.Zone.ShortName()][name][lvl][bodyType] = nil
								Logger.log_debug(
									"\ayUpdateCharmList: Removing Spawn from our Immune List, \aw(\aoZone \at%s \aoMob \at%s \aoLvl \at%s \ao Body \at%s\aw.)",
									mq.TLO.Zone.ShortName(), name, lvl, bodyType)
								mq.pickle(getImmuneFileName(), self.ImmuneTable)
							end
							ImGui.TableNextColumn()
							ImGui.Text(name)
							ImGui.TableNextColumn()
							ImGui.Text(lvl)
							ImGui.TableNextColumn()
							ImGui.Text(bodyType)
							ImGui.TableNextColumn()
							ImGui.TextColored(ImVec4(0.983, 0.729, 0.290, 1.000), "%s", reason)
						end
					end
				end
				ImGui.EndTable()
			end
			ImGui.Unindent()
		end
	end
end

function Module:Pop()
	Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Module:HandleCharmBroke(mobName, breakerName)
	Logger.log_debug("%s broke charm on ==> %s", breakerName, mobName)
	Comms.HandleAnnounce(
		string.format("\ar CHARM Broken: %s woke up \ag -> \ay %s \ag <- \ax", breakerName, mobName),
		Config:GetSetting('CharmAnnounceGroup'), Config:GetSetting('CharmAnnounce'))
end

function Module:AddImmuneTarget(mobId, mobData)
	if self.TempSettings.CharmImmune[mobId] ~= nil then return end
	local zone = mq.TLO.Zone.ShortName()
	self.TempSettings.CharmImmune[mobId] = mobData

	if mobData.reason ~= 'HIGH_LVL' then
		if self.ImmuneTable[zone] == nil then
			self.ImmuneTable[zone] = {}
		end
		if self.ImmuneTable[zone][mobData.name] == nil then
			self.ImmuneTable[zone][mobData.name] = {}
		end
		if self.ImmuneTable[zone][mobData.name][mobData.lvl] == nil then
			self.ImmuneTable[zone][mobData.name][mobData.lvl] = {}
		end
		if self.ImmuneTable[zone][mobData.name][mobData.lvl][mobData.body] == nil then
			self.ImmuneTable[zone][mobData.name][mobData.lvl][mobData.body] = mobData.reason
			Logger.log_debug(
				"\ayUpdateCharmList: Adding Spawn to our Immune List, \aw(\aoZone \at%s \aoMob \at%s \aoLvl \at%s \ao Body \at%s\aw.)",
				zone, mobData.name, mobData.lvl, mobData.body)
			mq.pickle(getImmuneFileName(), self.ImmuneTable)
			self:RemoveCCTarget(mobId)
		end
	end
end

function Module:CharmLvlToHigh(mobLvl)
	if Core.MyClassIs("BRD") then return false end
	if Config:GetSetting("DireCharm", true) and Config:GetSetting("AutoLevelRangeCharm") then
		Config:SetSetting('DireCharmMaxLvl', mobLvl - 1)
		Logger.log_debug("\awNOTICE:\ax \aoTarget LVL to High,\ayLowering Max Level for Dire Charm!")
		return true
	end
	return false
end

function Module:IsCharmImmune(mobId)
	local tmpSpawn = mq.TLO.Spawn(mobId)
	local isNamed = Targeting.IsNamed(tmpSpawn)

	local mobName = tmpSpawn.CleanName() or "Unknown"
	local mobType = tmpSpawn.Body() or "Unknown"
	local zoneShort = mq.TLO.Zone.ShortName()
	local mobLvl = tmpSpawn.Level() or 0
	if self.ImmuneTable[zoneShort] == nil then
		self.ImmuneTable[zoneShort] = {}
	end
	if self.ImmuneTable[zoneShort][mobName] ~= nil then
		if self.ImmuneTable[zoneShort][mobName][mobLvl] ~= nil then
			if self.ImmuneTable[zoneShort][mobName][mobLvl][mobType] ~= nil then
				return true
			end
		end
	end
	if self.TempSettings.CharmImmune[mobId] ~= nil then
		return true
	end
	if isNamed then
		self:AddImmuneTarget(mobId, { id = tmpSpawn.ID(), name = tmpSpawn.CleanName(), lvl = tmpSpawn.Level(), body = tmpSpawn.Body(), reason = "Named", })
		return true
	end
	return false
end

function Module:ResetCharmStates()
	self.TempSettings.CharmImmune = {}
	self.TempSettings.CharmTracker = {}
end

function Module:GetCharmSpell()
	if Core.MyClassIs("BRD") then
		return Modules:ExecModule("Class", "GetResolvedActionMapItem", "CharmSong")
	end

	return Modules:ExecModule("Class", "GetResolvedActionMapItem", "CharmSpell")
end

function Module:CharmNow(charmId, useAA)
	-- First thing we target the mob if we haven't already targeted them.
	Core.DoCmd("/attack off")
	local currentTargetID = mq.TLO.Target.ID()
	if charmId == Config.Globals.AutoTargetID then return end
	Targeting.SetTarget(charmId)

	local charmSpell = self:GetCharmSpell()

	if not charmSpell or not charmSpell() then return end
	if not Core.MyClassIs("BRD") then
		local dCharm = Config:GetSetting("DireCharm", true) == true
		if dCharm and mq.TLO.Me.AltAbilityReady('Dire Charm') and (mq.TLO.Spawn(charmId).Level() or 0) <= Config:GetSetting('DireCharmMaxLvl') then
			Comms.HandleAnnounce(
				string.format("Performing DIRE CHARM --> %s", mq.TLO.Spawn(charmId).CleanName() or "Unknown"),
				Config:GetSetting('CharmAnnounceGroup'),
				Config:GetSetting('CharmAnnounce'))
			Casting.UseAA("Dire Charm", charmId)
		else
			-- This may not work for Bards but will work for DRU/NEC/ENCs
			Casting.UseSpell(charmSpell.RankName(), charmId, false)
			Logger.log_debug("Performing CHARM --> %d", charmId)
		end
	else
		Logger.log_debug("Performing Bard CHARM --> %d", charmId)
		-- TODO SongNow CharmSpell
		Casting.UseSong(charmSpell.RankName(), charmId, false, 5)
	end

	mq.doevents()

	if Casting.GetLastCastResultId() == Config.Constants.CastResults.CAST_SUCCESS and mq.TLO.Pet.ID() > 0 then
		Comms.HandleAnnounce(string.format("\ag JUST CHARMED:\aw -> \ay %s <-",
				mq.TLO.Spawn(charmId).CleanName(), charmId), Config:GetSetting('CharmAnnounceGroup'),
			Config:GetSetting('CharmAnnounce'))
	else
		Comms.HandleAnnounce(string.format("\ar CHARM Failed: \ag -> \ay %s \ag <-",
			mq.TLO.Spawn(charmId).CleanName(),
			charmId), Config:GetSetting('CharmAnnounceGroup'), Config:GetSetting('CharmAnnounce'))
	end

	mq.doevents()

	Targeting.SetTarget(currentTargetID)
end

function Module:RemoveCCTarget(mobId)
	if mobId == 0 then return end
	self.TempSettings.CharmTracker[mobId] = nil
end

function Module:AddCCTarget(mobId)
	if mobId == 0 then return end
	local spawn = mq.TLO.Spawn(mobId)
	if self:IsCharmImmune(mobId) then
		Logger.log_debug("\awNOTICE:\ax Unable to charm %d - it is immune", mobId)
		return false
	end

	Targeting.SetTarget(mobId)

	self.TempSettings.CharmTracker[mobId] = {
		name = spawn.CleanName(),
		duration = mq.TLO.Target.Charmed.Duration() or 0,
		level = spawn.Level() or 0,
		body = spawn.Body() or "Unknown",
		last_check = os.clock() * 1000,
		charm_spell = mq.TLO
			.Target.Charmed() or "None",
	}
end

function Module:IsValidCharmTarget(mobId)
	local spawn = mq.TLO.Spawn(mobId)

	-- Is the mob ID in our charm immune list? If so, skip.
	if self:IsCharmImmune(mobId) then
		Logger.log_debug(
			"\ayUpdateCharmList: Skipping \aoMob ID: \at%d \aoName: \at%s \aoLevel: \at%d \ayas it is in our immune list.",
			spawn.ID(), spawn.CleanName(), spawn.Level())
		return false
	end
	-- Here's where we can add a necro check to see if the spawn is undead or not. If it's not
	-- undead it gets added to the charm immune list.
	if Core.MyClassIs('DRU') then
		if spawn.Body.Name() ~= "Animal" then
			Logger.log_debug(
				"\ayUpdateCharmList: Adding ID: %d Name: %s Level: %d to our immune list as it is not an animal.",
				spawn.ID(),
				spawn.CleanName(), spawn.Level())
			return false
		end
	elseif Core.MyClassIs('NEC') then
		if spawn.Body.Name() ~= "Undead" then
			Logger.log_debug(
				"\ayUpdateCharmList: Adding ID: %d Name: %s Level: %d to our immune list as it is not undead.",
				spawn.ID(),
				spawn.CleanName(), spawn.Level())
			return false
		end
	end
	if not spawn.LineOfSight() then
		Logger.log_debug("\ayUpdateCharmList: Skipping Mob ID: %d Name: %s Level: %d - No LOS.", spawn.ID(),
			spawn.CleanName(), spawn.Level())
		return false
	end

	if (spawn.PctHPs() or 0) < Config:GetSetting('CharmStopHPs') then
		Logger.log_debug("\ayUpdateCharmList: Skipping Mob ID: %d Name: %s Level: %d - HPs too low.", spawn.ID(),
			spawn.CleanName(), spawn.Level())
		return false
	end

	if (spawn.Distance() or 999) > Config:GetSetting('CharmRadius') then
		Logger.log_debug("\ayUpdateCharmList: Skipping Mob ID: %d Name: %s Level: %d - Out of Charm Radius",
			spawn.ID(), spawn.CleanName(), spawn.Level())
		return false
	end

	return true
end

function Module:UpdateCharmList()
	local searchTypes = { "npc", }

	local charmSpell = self:GetCharmSpell()

	if not charmSpell or not charmSpell() then
		Logger.log_verbose("\ayayUpdateCharmList: No charm spell - bailing!")
		return
	end

	for _, t in ipairs(searchTypes) do
		local minLevel = Config:GetSetting('CharmMinLevel')
		local maxLevel = Config:GetSetting('CharmMaxLevel')
		if Config:GetSetting('AutoLevelRangeCharm') and charmSpell and charmSpell() then
			minLevel = 0
			maxLevel = charmSpell.MaxLevel()
			Config:SetSetting('CharmMaxLevel', maxLevel)
		end
		-- streamline search by body type for druids/necros this saves work when checking invalid.
		local npcType = ''
		if Core.MyClassIs("dru") then
			npcType = ' body Animal'
		elseif Core.MyClassIs("nec") then
			npcType = ' body Undead'
		end
		local searchString = string.format("%s radius %d zradius %d range %d %d targetable playerstate 4%s", t,
			Config:GetSetting('CharmRadius') * 2, Config:GetSetting('CharmZRadius') * 2, minLevel, maxLevel, npcType)

		local mobCount = mq.TLO.SpawnCount(searchString)()
		Logger.log_debug("\ayUpdateCharmList: Search String: '\at%s\ay' -- Count :: \am%d", searchString, mobCount)
		for i = 1, mobCount do
			local spawn = mq.TLO.NearestSpawn(i, searchString)

			if spawn and spawn() and spawn.ID() > 0 then
				Logger.log_debug(
					"\ayUpdateCharmList: Processing MobCount %d -- ID: %d Name: %s Level: %d BodyType: %s", i, spawn.ID(),
					spawn.CleanName(), spawn.Level(),
					spawn.Body.Name())

				if self:IsValidCharmTarget(spawn.ID()) then
					Logger.log_debug("\agAdding to Charm List: %d -- ID: %d Name: %s Level: %d BodyType: %s", i,
						spawn.ID(), spawn.CleanName(), spawn.Level(), spawn.Body.Name())
					self:AddCCTarget(spawn.ID())
				end
			end
		end
	end

	mq.doevents()
end

function Module:ProcessCharmList()
	-- Assume by default we never need to block for charm. We'll set this if-and-only-if
	-- we need to charm but our ability is on cooldown.
	if mq.TLO.Me.Pet.ID() ~= 0 then return end
	Core.DoCmd("/attack off")
	Logger.log_debug("\ayProcessCharmList() :: Loop")
	local charmSpell = self:GetCharmSpell()

	if not charmSpell or not charmSpell() then return end

	if not Config:GetSetting('CharmOn') then
		Logger.log_debug("\ayProcessCharmList(%d) :: Charming is off...")
		return
	end

	local removeList = {}
	for id, data in pairs(self.TempSettings.CharmTracker) do
		if mq.TLO.Pet.ID() > 0 then break end
		local spawn = mq.TLO.Spawn(id)
		Logger.log_debug("\ayProcessCharmList(%d) :: Checking...", id)

		if not spawn or not spawn() or spawn.Dead() or Targeting.TargetIsType("corpse", spawn) then
			table.insert(removeList, id)
			Logger.log_debug("\ayProcessCharmList(%d) :: Can't find mob removing...", id)
		else
			if self:IsCharmImmune(id) then
				-- somehow added an immune mod to our tracker...
				Logger.log_debug("\ayProcessCharmList(%d) :: Mob id is in immune list - removing...", id)
				table.insert(removeList, id)
			else
				if spawn.Distance() > Config:GetSetting('CharmRadius') or not spawn.LineOfSight() then
					Logger.log_debug("\ayProcessCharmList(%d) :: Distance(%d) LOS(%s)", id,
						spawn.Distance(), Strings.BoolToColorString(spawn.LineOfSight()))
				else
					if id == Config.Globals.AutoTargetID then
						Logger.log_debug("\ayProcessCharmList(%d) :: Mob is MA's target skipping", id)
						table.insert(removeList, id)
					else
						Logger.log_debug("\ayProcessCharmList(%d) :: Mob needs charmed.", id)
						if mq.TLO.Me.Combat() or mq.TLO.Me.Casting() then
							Logger.log_debug(
								" \awNOTICE:\ax Stopping Melee/Singing -- must retarget to start charm.")
							Core.DoCmd("/attack off")
							mq.delay("3s", function() return not mq.TLO.Me.Combat() end)
							Core.DoCmd("/stopcast")
							Core.DoCmd("/stopsong")
							mq.delay("3s", function() return not mq.TLO.Window("CastingWindow").Open() end)
						end

						Targeting.SetTarget(id)

						local maxWait = 5000
						while not Casting.SpellReady(charmSpell) and maxWait > 0 do
							mq.delay(100)
							maxWait = maxWait - 100
						end

						self:CharmNow(id, false)
					end
				end
			end
		end
	end

	for _, id in ipairs(removeList) do
		self:RemoveCCTarget(id)
	end

	mq.doevents()
end

function Module:DoCharm()
	local charmSpell = self:GetCharmSpell()
	self:UpdateTimings()

	if Targeting.GetXTHaterCount() >= Config:GetSetting('CharmStartCount') then
		self:UpdateCharmList()
	end
	if not Core.MyClassIs("BRD") then
		if ((charmSpell and charmSpell() and mq.TLO.Me.SpellReady(charmSpell.RankName.Name())()) or (Config:GetSetting("DireCharm", true) == true)) and
			Tables.GetTableSize(self.TempSettings.CharmTracker) >= 1 then
			self:ProcessCharmList()
		else
			Logger.log_verbose("DoCharm() : Skipping Charm list processing: Spell(%s) Ready(%s) TableSize(%d)",
				charmSpell and charmSpell() or "None",
				charmSpell and charmSpell() and
				Strings.BoolToColorString(mq.TLO.Me.SpellReady(charmSpell.RankName.Name())()) or "NoSpell",
				Tables.GetTableSize(self.TempSettings.CharmTracker))
		end
	else
		if (charmSpell and charmSpell() and mq.TLO.Me.SpellReady(charmSpell.RankName.Name())()) and
			Tables.GetTableSize(self.TempSettings.CharmTracker) >= 1 then
			self:ProcessCharmList()
		else
			Logger.log_verbose("DoCharm() : Skipping Charm list processing: Spell(%s) Ready(%s) TableSize(%d)",
				charmSpell and charmSpell() or "None",
				charmSpell and charmSpell() and
				Strings.BoolToColorString(mq.TLO.Me.SpellReady(charmSpell.RankName.Name())()) or "NoSpell",
				Tables.GetTableSize(self.TempSettings.CharmTracker))
		end
	end
end

function Module:UpdateTimings()
	for _, data in pairs(self.TempSettings.CharmTracker) do
		local timeDelta = (os.clock() * 1000) - data.last_check

		data.duration = data.duration - timeDelta

		data.last_check = os.clock() * 1000
	end
end

function Module:GiveTime(combat_state)
	if not Core.IsCharming() then return end

	-- dead... whoops
	if mq.TLO.Me.Hovering() then return end

	if self.CombatState ~= combat_state and combat_state == "Downtime" then
		self:ResetCharmStates()
	end

	self.CombatState = combat_state

	self:DoCharm()
end

function Module:OnDeath()
end

function Module:OnZone()
	self:ResetCharmStates()
	-- Zone Handler
end

function Module:OnCombatModeChanged()
end

function Module:DoGetState()
	-- Reture a reasonable state if queried
	return "TODO"
end

function Module:GetCommandHandlers()
	return { module = self._name, CommandHandlers = {}, }
end

function Module:GetFAQ()
	return { module = self._name, FAQ = self.FAQ or {}, }
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
	Logger.log_debug("Charm Module Unloaded.")
end

mq.bind("/rgupcharm", function()
	Modules:ExecModule("Charm", "UpdateCharmList")
end)

return Module
