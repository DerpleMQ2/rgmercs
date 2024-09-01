-- Sample Basic Class Module
local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")
local Set         = require("mq.Set")
require('utils.rgmercs_datatypes')

local Module                     = { _version = '0.1a', _name = "Charm", _author = 'Grimmier', }
Module.__index                   = Module

Module.ModuleLoaded              = false
Module.CombatState               = "None"

Module.TempSettings              = {}
Module.TempSettings.CharmImmune  = {}
Module.TempSettings.CharmTracker = {}

Module.DefaultConfig             = {
	-- [ CHARM ] --
	['CharmOn']             = { DisplayName = "Charm On", Category = "Charm Pet", Default = false, Tooltip = "Set to use charm spells.", },
	['CharmStartCount']     = { DisplayName = "Charm Start Count", Category = "Charm Pet", Default = 2, Min = 1, Max = 20, Tooltip = "Sets # of mobs needed to start using Charm spells. ( Default 2 )", },
	['CharmRadius']         = { DisplayName = "Charm Radius", Category = "Charm Range", Default = 100, Min = 1, Max = 200, Tooltip = "Radius for mobs to be in to start Charming, An area twice this size is monitored for aggro mobs", },
	['CharmZRadius']        = { DisplayName = "Charm ZRadius", Category = "Charm Range", Default = 15, Min = 1, Max = 200, Tooltip = "Height radius (z-value) for mobs to be in to start charming. An area twice this size is monitored for aggro mobs. If you're enchanter is not charming on hills -- increase this value.", },
	['AutoLevelRangeCharm'] = { DisplayName = "Auto Level Range", Category = "Charm Target", Default = true, Tooltip = "Set to enable automatic charm level detection based on spells.", },
	['CharmStopHPs']        = { DisplayName = "Charm Stop HPs", Category = "Charm Target", Default = 80, Min = 1, Max = 100, Tooltip = "Mob HP% to stop trying to charm", },
	['CharmMinLevel']       = { DisplayName = "Charm Min Level", Category = "Charm Target", Default = 0, Min = 1, Max = 200, Tooltip = "Minimum Level a mob must be to Charm - Below this lvl are ignored. 0 means no mobs ignored. NOTE: AutoLevelRange must be OFF!", },
	['CharmMaxLevel']       = { DisplayName = "Charm Max Level", Category = "Charm Target", Default = 0, Min = 1, Max = 200, Tooltip = "Maximum Level a mob must be to Charm - Above this lvl are ignored. 0 means no mobs ignored. NOTE: AutoLevelRange must be OFF!", },
	['DireCharmMaxLvl']     = { DisplayName = "DireCharm Max Level", Category = "Charm Target", Default = 0, Min = 1, Max = 200, Tooltip = "Maximum Level a mob must be to DireCharm - Above this lvl are ignored. 0 means no mobs ignored. NOTE: AutoLevelRange must be OFF!", },
	['DireCharm']           = { DisplayName = "Dire Charm", Category = "Charm Pet", Default = false, Tooltip = "Use DireCharm AA", },
}

Module.DefaultCategories         = Set.new({})
for _, v in pairs(Module.DefaultConfig) do
	if v.Type ~= "Custom" then
		Module.DefaultCategories:add(v.Category)
	end
end

local function getConfigFileName()
	return mq.configDir ..
		'/rgmercs/PCConfigs/' ..
		Module._name .. "_" .. RGMercConfig.Globals.CurServer .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
	mq.pickle(getConfigFileName(), self.settings)

	if doBroadcast == true then
		RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
	end
end

function Module:LoadSettings()
	RGMercsLogger.log_debug("\ar%s\ao Charm Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedClass,
		RGMercConfig.Globals.CurLoadedChar)
	local settings_pickle_path = getConfigFileName()

	local config, err = loadfile(settings_pickle_path)
	if err or not config then
		RGMercsLogger.log_error("\ay[%s]: Unable to load module settings file(%s), creating a new one!",
			RGMercConfig.Globals.CurLoadedClass, settings_pickle_path)
		self.settings = {}
		self:SaveSettings(false)
	else
		self.settings = config()
	end

	if not self.settings or not self.DefaultCategories or not self.DefaultConfig then
		RGMercsLogger.log_error("\arFailed to Load Charm Config for Classs: %s", RGMercConfig.Globals.CurLoadedClass)
		return
	end

	-- Setup Defaults
	local needSave = false
	self.settings, needSave = RGMercUtils.ResolveDefaults(self.DefaultConfig, self.settings)
	if needSave then self:SaveSettings(false) end
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
	RGMercsLogger.log_debug("\agInitializing Charm Module...")
	-- bards don't have DireCharm so hide the settings.
	if RGMercUtils.MyClassIs("BRD") then
		self.DefaultConfig['DireCharm'] = nil
		self.DefaultConfig['DireCharmMaxLvl'] = nil
	end
	self:LoadSettings()

	self.ModuleLoaded = true

	return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
	return RGMercModules:ExecModule("Class", "CanCharm")
end

function Module:Render()
	ImGui.Text("Charm Module")

	---@type boolean|nil
	local pressed = false

	if self.ModuleLoaded then
		if ImGui.CollapsingHeader("Config Options") then
			self.settings, pressed, _ = RGMercUtils.RenderSettings(self.settings, self.DefaultConfig,
				self.DefaultCategories)
			if pressed then
				self:SaveSettings(false)
			end
		end

		ImGui.Separator()
		-- CCEd targets
		if ImGui.CollapsingHeader("Charm Target List") then
			if ImGui.BeginTable("CharmedList", 4, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
				ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
				ImGui.TableSetupColumn('Id', (ImGuiTableColumnFlags.WidthFixed), 70.0)
				ImGui.TableSetupColumn('Duration', (ImGuiTableColumnFlags.WidthFixed), 150.0)
				ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 250.0)
				ImGui.TableSetupColumn('Spell', (ImGuiTableColumnFlags.WidthStretch), 150.0)
				ImGui.PopStyleColor()
				ImGui.TableHeadersRow()
				for id, data in pairs(self.TempSettings.CharmTracker) do
					ImGui.TableNextColumn()
					ImGui.Text(tostring(id))
					ImGui.TableNextColumn()
					if data.duration > 30000 then
						ImGui.PushStyleColor(ImGuiCol.Text, 0.02, 0.8, 0.02, 1)
					elseif data.duration > 15000 then
						ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.8, 0.02, 1)
					else
						ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.02, 0.02, 1)
					end
					ImGui.Text(string.format("%s", RGMercUtils.FormatTime(math.max(0, data.duration / 1000))))
					ImGui.PopStyleColor()
					ImGui.TableNextColumn()
					ImGui.Text(string.format("%s", data.name))
					ImGui.TableNextColumn()
					ImGui.Text(string.format("%s", data.charm_spell))
				end
				ImGui.EndTable()
			end
		end

		ImGui.Separator()
		-- Immune targets
		if ImGui.CollapsingHeader("Invalid Charm Targets") then
			if ImGui.BeginTable("Immune", 3, bit32.bor(ImGuiTableFlags.None, ImGuiTableFlags.Borders)) then
				ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
				ImGui.TableSetupColumn('Id', (ImGuiTableColumnFlags.WidthFixed), 70.0)
				ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthStretch), 250.0)
				ImGui.TableSetupColumn('Body', (ImGuiTableColumnFlags.WidthFixed), 90.0)
				ImGui.PopStyleColor()
				ImGui.TableHeadersRow()
				for id, data in pairs(self.TempSettings.CharmImmune) do
					ImGui.TableNextColumn()
					ImGui.Text(tostring(id))
					ImGui.TableNextColumn()
					ImGui.Text(string.format("%s", data.name))
					ImGui.TableNextColumn()
					ImGui.Text(string.format("%s", data.body))
				end
				ImGui.EndTable()
			end
		end

		ImGui.Separator()
	end
end

function Module:HandleCharmBroke(mobName, breakerName)
	RGMercsLogger.log_debug("%s broke charm on ==> %s", breakerName, mobName)
	RGMercUtils.HandleCharmAnnounce(string.format("\ar CHARM Broken: %s woke up \ag -> \ay %s \ag <- \ax", breakerName, mobName))
end

function Module:AddImmuneTarget(mobId, mobData)
	if self.TempSettings.CharmImmune[mobId] ~= nil then return end

	self.TempSettings.CharmImmune[mobId] = mobData
end

function Module:IsCharmImmune(mobId)
	return self.TempSettings.CharmImmune[mobId] ~= nil
end

function Module:ResetCharmStates()
	self.TempSettings.CharmImmune = {}
	self.TempSettings.CharmTracker = {}
end

function Module:GetCharmSpell()
	if RGMercUtils.MyClassIs("BRD") then
		return RGMercModules:ExecModule("Class", "GetResolvedActionMapItem", "CharmSong")
	end

	return RGMercModules:ExecModule("Class", "GetResolvedActionMapItem", "CharmSpell")
end

function Module:CharmNow(charmId, useAA)
	-- First thing we target the mob if we haven't already targeted them.
	RGMercUtils.DoCmd("/attack off")
	local currentTargetID = mq.TLO.Target.ID()
	if charmId == RGMercConfig.Globals.AutoTargetID then return end
	RGMercUtils.SetTarget(charmId)

	local charmSpell = self:GetCharmSpell()

	if not charmSpell or not charmSpell() then return end
	local dCharm = not RGMercUtils.MyClassIs("BRD") and RGMercUtils.GetSetting("DireCharm") or false
	if dCharm and mq.TLO.Me.AltAbilityReady('Dire Charm') and (mq.TLO.Spawn(charmId).Level() or 0) <= RGMercUtils.GetSetting('DireCharmMaxLvl') then
		RGMercsLogger.log_debug("Performing DIRE CHARM --> %d", charmId)
		RGMercUtils.HandleCharmAnnounce(string.format("Performing DIRE CHARM --> %d", charmId))
		RGMercUtils.UseAA("Dire Charm", charmId)
	else
		if RGMercUtils.MyClassIs("brd") then
			RGMercsLogger.log_debug("Performing Bard CHARM --> %d", charmId)
			-- TODO SongNow CharmSpell
			RGMercUtils.UseSong(charmSpell.RankName(), charmId, false, 5)
		else
			-- This may not work for Bards but will work for DRU/NEC/ENCs
			RGMercUtils.UseSpell(charmSpell.RankName(), charmId, false)
			RGMercsLogger.log_debug("Performing CHARM --> %d", charmId)
		end
	end

	mq.doevents()

	if RGMercUtils.GetLastCastResultId() == RGMercConfig.Constants.CastResults.CAST_SUCCESS or mq.TLO.Pet.ID() > 0 then
		RGMercUtils.HandleCharmAnnounce(string.format("\ag JUST CHARMED:\aw -> \ay %s \aw : \ar %d",
			mq.TLO.Spawn(charmId).CleanName(), charmId))
	else
		RGMercUtils.HandleCharmAnnounce(string.format("\ar CHARM Failed: %s \ag -> \ay %s \ag <- \ar ID:%d",
			RGMercUtils.GetLastCastResultName(), mq.TLO.Spawn(charmId).CleanName(),
			charmId))
	end

	mq.doevents()

	RGMercUtils.SetTarget(currentTargetID)
end

function Module:RemoveCCTarget(mobId)
	if mobId == 0 then return end
	self.TempSettings.CharmTracker[mobId] = nil
end

function Module:AddCCTarget(mobId)
	if mobId == 0 then return end

	if self:IsCharmImmune(mobId) then
		RGMercsLogger.log_debug("\awNOTICE:\ax Unable to charm %d - it is immune", mobId)
		return false
	end

	RGMercUtils.SetTarget(mobId)

	self.TempSettings.CharmTracker[mobId] = {
		name = mq.TLO.Target.CleanName(),
		duration = mq.TLO.Target.Charmed.Duration() or 0,
		last_check = os.clock() * 1000,
		charm_spell = mq.TLO
			.Target.Charmed() or "None",
	}
end

function Module:IsValidCharmTarget(mobId)
	local spawn = mq.TLO.Spawn(mobId)

	-- Is the mob ID in our charm immune list? If so, skip.
	if self:IsCharmImmune(mobId) then
		RGMercsLogger.log_debug("\ayUpdateCharmList: Skipping Mob ID: %d Name: %s Level: %d as it is in our immune list.",
			spawn.ID(), spawn.CleanName(), spawn.Level())
		return false
	end
	-- Here's where we can add a necro check to see if the spawn is undead or not. If it's not
	-- undead it gets added to the charm immune list.
	if RGMercUtils.MyClassIs('DRU') then
		if spawn.Body.Name() ~= "Animal" then
			RGMercsLogger.log_debug(
				"\ayUpdateCharmList: Adding ID: %d Name: %s Level: %d to our immune list as it is not an animal.", spawn.ID(),
				spawn.CleanName(), spawn.Level())
			return false
		end
	elseif RGMercUtils.MyClassIs('NEC') then
		if spawn.Body.Name() ~= "Undead" then
			RGMercsLogger.log_debug(
				"\ayUpdateCharmList: Adding ID: %d Name: %s Level: %d to our immune list as it is not undead.", spawn.ID(),
				spawn.CleanName(), spawn.Level())
			return false
		end
	end
	if not spawn.LineOfSight() then
		RGMercsLogger.log_debug("\ayUpdateCharmList: Skipping Mob ID: %d Name: %s Level: %d - No LOS.", spawn.ID(),
			spawn.CleanName(), spawn.Level())
		return false
	end

	if (spawn.PctHPs() or 0) < self.settings.CharmStopHPs then
		RGMercsLogger.log_debug("\ayUpdateCharmList: Skipping Mob ID: %d Name: %s Level: %d - HPs too low.", spawn.ID(),
			spawn.CleanName(), spawn.Level())
		return false
	end

	if (spawn.Distance() or 999) > self.settings.CharmRadius then
		RGMercsLogger.log_debug("\ayUpdateCharmList: Skipping Mob ID: %d Name: %s Level: %d - Out of Charm Radius",
			spawn.ID(), spawn.CleanName(), spawn.Level())
		return false
	end

	return true
end

function Module:UpdateCharmList()
	local searchTypes = { "npc", }

	local charmSpell = self:GetCharmSpell()

	if not charmSpell or not charmSpell() then
		RGMercsLogger.log_verbose("\ayayUpdateCharmList: No charm spell - bailing!")
		return
	end

	for _, t in ipairs(searchTypes) do
		local minLevel = self.settings.CharmMinLevel
		local maxLevel = self.settings.CharmMaxLevel
		if self.settings.AutoLevelRangeCharm and charmSpell and charmSpell() then
			minLevel = 0
			maxLevel = charmSpell.MaxLevel()
			self.settings.CharmMaxLevel = maxLevel
		end
		-- streamline search by body type for druids/necros this saves work when checking invalid.
		local npcType = ''
		if RGMercUtils.MyClassIs("dru") then
			npcType = ' body Animal'
		elseif RGMercUtils.MyClassIs("nec") then
			npcType = ' body Undead'
		end
		local searchString = string.format("%s radius %d zradius %d range %d %d targetable playerstate 4%s", t,
			self.settings.CharmRadius * 2, self.settings.CharmZRadius * 2, minLevel, maxLevel, npcType)

		local mobCount = mq.TLO.SpawnCount(searchString)()
		RGMercsLogger.log_debug("\ayUpdateCharmList: Search String: '\at%s\ay' -- Count :: \am%d", searchString, mobCount)
		for i = 1, mobCount do
			local spawn = mq.TLO.NearestSpawn(i, searchString)

			if spawn and spawn() and spawn.ID() > 0 then
				RGMercsLogger.log_debug(
					"\ayUpdateCharmList: Processing MobCount %d -- ID: %d Name: %s Level: %d BodyType: %s", i, spawn.ID(),
					spawn.CleanName(), spawn.Level(),
					spawn.Body.Name())

				if self:IsValidCharmTarget(spawn.ID()) then
					RGMercsLogger.log_debug("\agAdding to Charm List: %d -- ID: %d Name: %s Level: %d BodyType: %s", i,
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
	RGMercUtils.DoCmd("/attack off")
	RGMercsLogger.log_debug("\ayProcessCharmList() :: Loop")
	local charmSpell = self:GetCharmSpell()

	if not charmSpell or not charmSpell() then return end

	if not self.settings.CharmOn then
		RGMercsLogger.log_debug("\ayProcessCharmList(%d) :: Charming is off...")
		return
	end

	local removeList = {}
	for id, data in pairs(self.TempSettings.CharmTracker) do
		if mq.TLO.Pet.ID() > 0 then break end
		local spawn = mq.TLO.Spawn(id)
		RGMercsLogger.log_debug("\ayProcessCharmList(%d) :: Checking...", id)

		if not spawn or not spawn() or spawn.Dead() or RGMercUtils.TargetIsType("corpse", spawn) then
			table.insert(removeList, id)
			RGMercsLogger.log_debug("\ayProcessCharmList(%d) :: Can't find mob removing...", id)
		else
			if self:IsCharmImmune(id) then
				-- somehow added an immune mod to our tracker...
				RGMercsLogger.log_debug("\ayProcessCharmList(%d) :: Mob id is in immune list - removing...", id)
				table.insert(removeList, id)
			else
				if spawn.Distance() > self.settings.CharmRadius or not spawn.LineOfSight() then
					RGMercsLogger.log_debug("\ayProcessCharmList(%d) :: Distance(%d) LOS(%s)", id,
						spawn.Distance(), RGMercUtils.BoolToColorString(spawn.LineOfSight()))
				else
					if id == RGMercConfig.Globals.AutoTargetID then
						RGMercsLogger.log_debug("\ayProcessCharmList(%d) :: Mob is MA's target skipping", id)
						table.insert(removeList, id)
					else
						RGMercsLogger.log_debug("\ayProcessCharmList(%d) :: Mob needs charmed.", id)
						if mq.TLO.Me.Combat() or mq.TLO.Me.Casting.ID() then
							RGMercsLogger.log_debug(
								" \awNOTICE:\ax Stopping Melee/Singing -- must retarget to start charm.")
							RGMercUtils.DoCmd("/attack off")
							mq.delay("3s", function() return not mq.TLO.Me.Combat() end)
							RGMercUtils.DoCmd("/stopcast")
							RGMercUtils.DoCmd("/stopsong")
							mq.delay("3s", function() return not mq.TLO.Window("CastingWindow").Open() end)
						end

						RGMercUtils.SetTarget(id)

						mq.delay(500, function() return mq.TLO.Target.BuffsPopulated() end)

						local maxWait = 5000
						while not RGMercUtils.NPCSpellReady(charmSpell.RankName.Name()) and maxWait > 0 do
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

	if RGMercUtils.GetXTHaterCount() >= self.settings.CharmStartCount then
		self:UpdateCharmList()
	end

	if ((charmSpell and charmSpell() and mq.TLO.Me.SpellReady(charmSpell.RankName.Name())()) or RGMercUtils.GetSetting("DireCharm")) and
		RGMercUtils.GetTableSize(self.TempSettings.CharmTracker) >= 1 then
		self:ProcessCharmList()
	else
		RGMercsLogger.log_verbose("DoCharm() : Skipping Charm list processing: Spell(%s) Ready(%s) TableSize(%d)", charmSpell and charmSpell() or "None",
			charmSpell and charmSpell() and RGMercUtils.BoolToColorString(mq.TLO.Me.SpellReady(charmSpell.RankName.Name())()) or "NoSpell",
			RGMercUtils.GetTableSize(self.TempSettings.CharmTracker))
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
	if not RGMercUtils.IsCharming() then return end

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
	RGMercsLogger.log_debug("Charm Module Unloaded.")
end

mq.bind("/rgupcharm", function()
	RGMercModules:ExecModule("Charm", "UpdateCharmList")
end)

return Module
