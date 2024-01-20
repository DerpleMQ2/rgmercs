-- Sample Basic Class Module
local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")
local Set         = require("mq.Set")
require('utils.rgmercs_datatypes')

local Module                              = { _version = '0.1a', _name = "Class", _author = 'Derple', }
Module.__index                            = Module

Module.ModuleLoaded                       = false
Module.SpellLoadOut                       = {}
Module.ResolvedActionMap                  = {}
Module.TempSettings                       = {}
Module.CombatState                        = "None"
Module.CurrentRotation                    = { name = "None", state = 0, }
Module.ClassConfig                        = nil
Module.DefaultCategories                  = nil

Module.Constants                          = {}
Module.Constants.RezSearchGroup           = "pccorpse group radius 100 zradius 50"
Module.Constants.RezSearchOutOfGroup      = "pccorpse radius 100 zradius 50"

-- Track the state of rotations between frames
Module.TempSettings.RotationStates        = {}
Module.TempSettings.HealingRotationStates = {}
Module.TempSettings.RotationTimers        = {}
Module.TempSettings.RezTimers             = {}
Module.TempSettings.CureCheckTimer        = 0
Module.TempSettings.ShowFailedSpells      = false
Module.TempSettings.ReloadingLoadouts     = true
Module.TempSettings.NewCombatMode         = false

local function getConfigFileName()
    return mq.configDir ..
        '/rgmercs/PCConfigs/' ..
        Module._name .. "_" .. RGMercConfig.Globals.CurServer .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    -- set dynamic names.
    self:SetDynamicNames()

    if doBroadcast == true then
        RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    local custom_config_file = string.format("%s/rgmercs/class_configs/%s_class_config.lua", mq.configDir,
        RGMercConfig.Globals.CurLoadedClass:lower())

    if RGMercUtils.file_exists(custom_config_file) then
        RGMercsLogger.log_info("Loading Custom Core Class Config: %s", custom_config_file)
        local config, err = loadfile(custom_config_file)
        if not config or err then
            RGMercsLogger.log_error("Failed to Load Custom Core Class Config: %s", custom_config_file)
        else
            self.ClassConfig = config()
        end
    end

    if not self.ClassConfig then
        self.ClassConfig = require(string.format("class_configs.%s_class_config",
            RGMercConfig.Globals.CurLoadedClass:lower()))
    end

    Module.DefaultCategories = Set.new({})
    for _, v in pairs(self.ClassConfig.DefaultConfig or {}) do
        if v.Type ~= "Custom" then
            Module.DefaultCategories:add(v.Category)
        end
    end

    Module.TempSettings.RotationStates = {}
    for i, m in ipairs(self.ClassConfig.RotationOrder or {}) do Module.TempSettings.RotationStates[i] = m end

    -- these are different since they arent strickly ordered but based on conditions of the target.
    Module.TempSettings.HealingRotationStates = {}
    for i, m in pairs(self.ClassConfig.HealRotationOrder or {}) do Module.TempSettings.HealingRotationStates[i] = m end

    RGMercsLogger.log_info("\ar%s\ao Core Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedClass,
        RGMercConfig.Globals.CurLoadedChar)
    RGMercsLogger.log_info("\ayUsing Class Config by: \at%s\ay (\am%s\ay)", self.ClassConfig._author,
        self.ClassConfig._version)
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

    if not self.settings or not self.DefaultCategories or not self.ClassConfig.DefaultConfig then
        RGMercsLogger.log_error("\arFailed to Load Core Class Config for Classs: %s", RGMercConfig.Globals
            .CurLoadedClass)
        return
    end

    -- Setup Defaults
    self.settings = RGMercUtils.ResolveDefaults(self.ClassConfig.DefaultConfig, self.settings)

    self.TempSettings.NewCombatMode = true
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    RGMercsLogger.log_info("\agInitializing Core Class Module...")
    self:LoadSettings()

    self.ModuleLoaded = true

    -- set dynamic names.
    self:SetDynamicNames()

    return {
        self = self,
        settings = self.settings,
        defaults = self.ClassConfig.DefaultConfig,
        categories = self
            .DefaultCategories,
    }
end

function Module:SetDynamicNames()
    for _, data in pairs(self.ClassConfig.Rotations) do
        for _, r in ipairs(data) do
            if r.name_func then
                r.name = r.name_func(self)
            end
        end
    end
end

function Module:GetResolvedActionMapItem(item)
    if self.TempSettings.ReloadingLoadouts then return nil end
    return self.ResolvedActionMap[item]
end

function Module:SetCombatMode(mode)
    RGMercsLogger.log_debug("\aySettings Combat Mode to: \am%s", mode)
    self.TempSettings.ReloadingLoadouts = true

    if self.ClassConfig then
        self.ResolvedActionMap, self.SpellLoadOut = RGMercUtils.SetLoadOut(self,
            self.ClassConfig.Spells, self.ClassConfig.ItemSets, self.ClassConfig.AbilitySets)
    end

    self.TempSettings.ReloadingLoadouts = false
    RGMercUtils.LoadSpellLoadOut(self.SpellLoadOut)

    if self.ClassConfig.OnModeChange then
        self.ClassConfig.OnModeChange(self, mode)
    end
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    ImGui.Text("Core Class Modules")

    ---@type boolean|nil
    local pressed = false
    local loadoutChange = false

    if self.ClassConfig and self.ModuleLoaded then
        ImGui.Text("Mode: ")
        ImGui.SameLine()
        RGMercUtils.Tooltip(self.ClassConfig.DefaultConfig.Mode.Tooltip)
        self.settings.Mode, pressed = ImGui.Combo("##_select_ai_mode", self.settings.Mode, self.ClassConfig.Modes,
            #self.ClassConfig.Modes)
        if pressed then
            self:SaveSettings(false)
            self.TempSettings.NewCombatMode = true
        end

        if ImGui.CollapsingHeader("Config Options") then
            self.settings, pressed, loadoutChange = RGMercUtils.RenderSettings(self.settings,
                self.ClassConfig.DefaultConfig, self.DefaultCategories)
            if pressed then
                self:SaveSettings(false)
                self.TempSettings.NewCombatMode = self.TempSettings.NewCombatMode or loadoutChange
            end
        end

        ImGui.Separator()

        if #self.SpellLoadOut > 0 then
            if ImGui.CollapsingHeader("Spell Loadout") then
                ImGui.Indent()
                RGMercUtils.RenderLoadoutTable(self.SpellLoadOut)
                ImGui.Unindent()
            end

            ImGui.Separator()
        end

        if not self.TempSettings.ReloadingLoadouts then
            if ImGui.CollapsingHeader("Rotations") then
                ImGui.Indent()
                RGMercUtils.RenderRotationTableKey()

                for _, r in ipairs(self.TempSettings.RotationStates) do
                    local rotationName = r.name
                    --if r.timer then
                    --    rotationName = string.format("%s [%s]", r.name, RGMercUtils.FormatTime(math.max(0, r.timer - (os.clock() - (self.TempSettings.RotationTimers[r.name] or 0)))))
                    --end
                    if ImGui.CollapsingHeader(rotationName) then
                        ImGui.Indent()
                        self.TempSettings.ShowFailedSpells = RGMercUtils.RenderRotationTable(self, r.name,
                            self.ClassConfig.Rotations[r.name],
                            self.ResolvedActionMap, r.state or 0, self.TempSettings.ShowFailedSpells)
                        ImGui.Unindent()
                    end
                end
                ImGui.Unindent()
            end
        end

        if not self.TempSettings.ReloadingLoadouts and #self.TempSettings.HealingRotationStates > 0 then
            if ImGui.CollapsingHeader("Healing Rotations") then
                ImGui.Indent()
                RGMercUtils.RenderRotationTableKey()

                for _, r in pairs(self.TempSettings.HealingRotationStates) do
                    if ImGui.CollapsingHeader(r.name) then
                        ImGui.Indent()
                        self.TempSettings.ShowFailedSpells = RGMercUtils.RenderRotationTable(self, r.name,
                            self.ClassConfig.HealRotations[r.name],
                            self.ResolvedActionMap, r.state or 0, self.TempSettings.ShowFailedSpells)
                        ImGui.Unindent()
                    end
                end
                ImGui.Unindent()
            end
        end

        ImGui.Text(string.format("Combat State: %s", self.CombatState))
        ImGui.Text(string.format("Current Rotation: %s [%d]", self.CurrentRotation.name, self.CurrentRotation.state))
    end
end

function Module:ResetRotation()
    for _, v in ipairs(self.TempSettings.RotationStates) do
        if v.state then
            v.state = 1
        end
    end
end

function Module:GetRotationTable(mode)
    return self.ClassConfig and self.ClassConfig.Rotations[mode] or {}
end

function Module:GetHealRotationTable(mode)
    return self.ClassConfig and self.ClassConfig.HealRotations[mode] or {}
end

function Module:GetSetting(setting)
    return self.ModuleLoaded and self.settings[setting] or ""
end

function Module:GetDefaultConfig(config)
    return self.ModuleLoaded and self.ClassConfig[config] or nil
end

---@return number
function Module:GetClassModeId()
    if not self.settings then return 0 end
    return self.settings.Mode
end

---@return string
function Module:GetClassModeName()
    if not self.settings or not self.ClassConfig then return "None" end
    return self.ClassConfig.Modes[self.settings.Mode] or "None"
end

---@param mode string
---@return boolean
function Module:IsModeActive(mode)
    local modeSet = Set.new(self.ClassConfig.Modes)
    if not modeSet:contains(mode) then
        RGMercsLogger.log_error("\arIsModeActive(%s) ==> Invalid Mode Type!", mode)
        return false
    end
    return self:GetClassModeName():lower() == mode:lower()
end

---@return boolean
function Module:IsTanking()
    if not self.ClassConfig or not self.ClassConfig.ModeChecks or not self.ClassConfig.ModeChecks.IsTanking then
        return false
    end
    return self.ClassConfig.ModeChecks.IsTanking()
end

---@return boolean
function Module:IsHealing()
    if not self.ClassConfig or not self.ClassConfig.ModeChecks or not self.ClassConfig.ModeChecks.IsHealing then
        return false
    end
    return self.ClassConfig.ModeChecks.IsHealing()
end

---@return boolean
function Module:IsCuring()
    if not self.ClassConfig or not self.ClassConfig.ModeChecks or not self.ClassConfig.ModeChecks.IsCuring then
        return false
    end
    return self.ClassConfig.ModeChecks.IsCuring()
end

---@return boolean
function Module:IsMezzing()
    if not self.ClassConfig or not self.ClassConfig.ModeChecks or not self.ClassConfig.ModeChecks.IsMezzing then
        return false
    end
    return self.ClassConfig.ModeChecks.IsMezzing()
end

function Module:GetTheme()
    if self.ClassConfig and self.ClassConfig.Themes then
        return self.ClassConfig.Themes[self:GetClassModeName()]
    end
end

function Module:GetClassConfig()
    return self.ClassConfig
end

function Module:SelfCheckAndRez()
    local rezSearch = string.format("pccorpse %d radius 100 zradius 50", mq.TLO.Me.ID())
    local rezCount = mq.TLO.SpawnCount(rezSearch)()

    for i = 1, rezCount do
        local rezSpawn = mq.TLO.NearestSpawn(i, rezSearch)

        if rezSpawn() then
            if self.ClassConfig.HelperFunctions.DoRez then
                if (os.clock() - (self.TempSettings.RezTimers[rezSpawn.ID()] or 0)) >= RGMercUtils.GetSetting('RetryRezDelay') then
                    self.ClassConfig.HelperFunctions.DoRez(self, rezSpawn.ID())
                    self.TempSettings.RezTimers[rezSpawn.ID()] = os.clock()
                end
            end
        end
    end
end

function Module:IGCheckAndRez()
    local rezCount = mq.TLO.SpawnCount(self.Constants.RezSearchGroup)()

    for i = 1, rezCount do
        local rezSpawn = mq.TLO.NearestSpawn(i, self.Constants.RezSearchGroup)

        if rezSpawn() then
            if self.ClassConfig.HelperFunctions.DoRez then
                if (os.clock() - (self.TempSettings.RezTimers[rezSpawn.ID()] or 0)) >= RGMercUtils.GetSetting('RetryRezDelay') then
                    self.ClassConfig.HelperFunctions.DoRez(self, rezSpawn.ID())
                    self.TempSettings.RezTimers[rezSpawn.ID()] = os.clock()
                end
            end
        end
    end
end

function Module:OOGCheckAndRez()
    local rezCount = mq.TLO.SpawnCount(self.Constants.RezSearchOutOfGroup)()

    for i = 1, rezCount do
        local rezSpawn = mq.TLO.NearestSpawn(i, self.Constants.RezSearchOutOfGroup)

        if rezSpawn() and (RGMercUtils.IsSafeName("pc", rezSpawn.DisplayName())) then
            if self.ClassConfig.HelperFunctions.DoRez then
                if (os.clock() - (self.TempSettings.RezTimers[rezSpawn.ID()] or 0)) >= RGMercUtils.GetSetting('RetryRezDelay') then
                    self.ClassConfig.HelperFunctions.DoRez(self, rezSpawn.ID())
                    self.TempSettings.RezTimers[rezSpawn.ID()] = os.clock()
                end
            end
        end
    end
end

function Module:FindWorstHurtGroupMember(minHPs)
    local groupSize = mq.TLO.Group.Members()
    local worstId = 0
    local worstPct = minHPs

    RGMercsLogger.log_verbose("\ayChecking for worst Hurt Group Members. Group Count: %d", groupSize)

    for i = 1, groupSize do
        local healTarget = mq.TLO.Group.Member(i)

        if healTarget and healTarget() and not healTarget.OtherZone() and not healTarget.Offline() then
            if healTarget.Class.ShortName():lower() ~= "ber" then -- berzerkers have special handing
                if healTarget.PctHPs() < worstPct then
                    RGMercsLogger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                    worstPct = healTarget.PctHPs()
                    worstId = healTarget.ID()
                end

                if RGMercUtils.GetSetting('DoPetHeals') then
                    if healTarget.Pet.ID() > 0 and healTarget.Pet.PctHPs() < worstPct then
                        RGMercsLogger.log_verbose("\aySo far %s's pet %s is the worst off.", healTarget.DisplayName(),
                            healTarget.Pet.DisplayName())
                        worstPct = healTarget.Pet.PctHPs()
                        worstId = healTarget.Pet.ID()
                    end
                end
            else
                RGMercsLogger.log_verbose("\aySkipping %s because they are a zerker", healTarget.DisplayName())
            end
        end
    end

    if worstId > 0 then
        RGMercsLogger.log_verbose("\agWorst hurt group member id is %d", worstId)
    else
        RGMercsLogger.log_verbose("\agNo one is hurt!")
    end

    return worstId
end

function Module:FindWorstHurtXT(minHPs)
    local xtSize = mq.TLO.Me.XTargetSlots()
    local worstId = 0
    local worstPct = minHPs

    RGMercsLogger.log_verbose("\ayChecking for worst Hurt XTargs. XT Slot Count: %d", xtSize)

    for i = 1, xtSize do
        local healTarget = mq.TLO.Me.XTarget(i)

        if healTarget and healTarget() and healTarget.Type():lower() == "pc" then
            if healTarget.Class.ShortName():lower() ~= "ber" then -- berzerkers have special handing
                if healTarget.PctHPs() < worstPct then
                    RGMercsLogger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                    worstPct = healTarget.PctHPs()
                    worstId = healTarget.ID()
                end

                if RGMercUtils.GetSetting('DoPetHeals') then
                    if healTarget.Pet.ID() > 0 and healTarget.Pet.PctHPs() < worstPct then
                        RGMercsLogger.log_verbose("\aySo far %s's pet %s is the worst off.", healTarget.DisplayName(),
                            healTarget.Pet.DisplayName())
                        worstPct = healTarget.Pet.PctHPs()
                        worstId = healTarget.Pet.ID()
                    end
                end
            else
                RGMercsLogger.log_verbose("\aySkipping %s because they are a zerker", healTarget.DisplayName())
            end
        end
    end

    if worstId > 0 then
        RGMercsLogger.log_verbose("\agWorst hurt xtarget id is %d", worstId)
    else
        RGMercsLogger.log_verbose("\agNo one is hurt!")
    end

    return worstId
end

function Module:HealById(id)
    if id == 0 then return end
    if not self.ClassConfig.HealRotationOrder then return end

    RGMercsLogger.log_verbose("\awHealById(%d)", id)

    local healTarget = mq.TLO.Spawn(id)

    if not healTarget or not healTarget() or healTarget.PctHPs() <= 0 then
        RGMercsLogger.log_verbose("\ayHealById(%d):: Target is dead or in another zone bailing", id)
        return
    end

    if healTarget.Type():lower() == "npc" then
        RGMercsLogger.log_verbose("\ayHealById(%d):: Target is an NPC bailing", id)
        return
    end

    RGMercsLogger.log_verbose("\awHealById(%d):: Finding best heal to use", id)

    local selectedRotation = nil

    for _, rotation in pairs(self.ClassConfig.HealRotationOrder or {}) do
        RGMercsLogger.log_verbose("\awHealById(%d):: Checking if Heal Rotation: \at%s\aw is appropriate to use.", id,
            rotation.name)
        if not rotation.cond or rotation.cond(self, healTarget) then
            RGMercsLogger.log_verbose("\awHealById(%d):: Heal Rotation: \at%s\aw \agis\aw appropriate to use.", id,
                rotation.name)
            -- since these are ordered by prioirty we can assume we are the best option.
            selectedRotation = rotation
            break
        else
            RGMercsLogger.log_verbose("\awHealById(%d):: Heal Rotation: \at%s\aw \aris NOT\aw appropriate to use.", id,
                rotation.name)
        end
    end

    if selectedRotation == nil then
        RGMercsLogger.log_verbose("\ayHealById(%d):: No appropriate heal rotation found. Bailling.", id)
        return
    end

    self.CurrentRotation = { name = selectedRotation.name, state = selectedRotation.state or 0, }

    local newState = RGMercUtils.RunRotation(self, self:GetHealRotationTable(selectedRotation.name), id,
        self.ResolvedActionMap, selectedRotation.steps or 0, selectedRotation.state or 0, false)

    if selectedRotation.state then selectedRotation.state = newState end
end

function Module:RunHealRotation()
    self:HealById(self:FindWorstHurtGroupMember(RGMercUtils.GetSetting('MaxHealPoint')))

    if RGMercUtils.GetSetting('AssistOutside') then
        self:HealById(self:FindWorstHurtXT(RGMercUtils.GetSetting('MaxHealPoint')))
    end

    if mq.TLO.Me.PctHPs() < RGMercUtils.GetSetting('MaxHealPoint') then
        self:HealById(mq.TLO.Me.ID())
    end
end

function Module:RunCureRotation()
    if (os.clock() - self.TempSettings.CureCheckTimer) < 15 then return end

    self.TempSettings.CureCheckTimer = os.clock()

    local dannetPeers = mq.TLO.DanNet.PeerCount()
    local checks = { { type = "Poison", check = "Me.Poisoned.ID", },
        { type = "Disease",    check = "Me.Diseased.ID", },
        { type = "Curse",      check = "Me.Cursed.ID", },
        { type = "Corruption", check = "Me.Corrupted.ID", }, }

    for i = 1, dannetPeers do
        ---@diagnostic disable-next-line: redundant-parameter
        local peer = mq.TLO.DanNet.Peers(i)()
        if mq.TLO.SpawnCount(string.format("pc =%s radius 150", peer))() == 1 then
            RGMercsLogger.log_verbose("\ag[Cures] %s is in range - checking for curables", peer)
            local effectCount = DanNet.query(peer, "Me.TotalCounters", 1000) or "null"
            RGMercsLogger.log_verbose("\ay[Cures] %s :: Effect Count: %s", peer, effectCount)
            if effectCount:lower() ~= "null" and effectCount ~= "0" then
                for _, data in ipairs(checks) do
                    local effectId = DanNet.query(peer, data.check, 1000) or "null"
                    RGMercsLogger.log_verbose("\ay[Cures] %s :: %s [%s] => %s", peer, data.check, data.type, effectId)

                    if effectId:lower() ~= "null" then
                        local cureTarget = mq.TLO.Spawn(string.format("pc =%s"))
                        if cureTarget and cureTarget() then
                            -- Cure it!
                            if self.ClassConfig.Cures and self.ClassConfig.Cures.CurNow then
                                self.ClassConfig.Cures.CurNow(self, data.type, cureTarget.ID())
                            end
                        end
                    end
                end
            end
        else
            RGMercsLogger.log_verbose("\ao[Cures] %s is in \arNOT\ao range", peer)
        end
    end
end

function Module:GiveTime(combat_state)
    if not self.ClassConfig then return end

    -- dead... whoops
    if mq.TLO.Me.Hovering() then return end

    -- Main Module logic goes here.
    if self.TempSettings.NewCombatMode then
        RGMercsLogger.log_debug("New Combat Mode Requested: %s", self.ClassConfig.Modes[self.settings.Mode])
        self:SetCombatMode(self.ClassConfig.Modes[self.settings.Mode])
        self.TempSettings.NewCombatMode = false
    end

    if self.CombatState ~= combat_state and combat_state == "Downtime" then
        self:ResetRotation()
    end

    self.CombatState = combat_state

    -- Healing Happens reguardless of combat_state and happens first.
    if self:IsHealing() then
        -- TODO Check Rezes
        if self.CombatState ~= "Downtime" or (not mq.TLO.Me.Invis() or RGMercUtils.GetSetting('BreakInvis')) then
            self:IGCheckAndRez()

            self:SelfCheckAndRez()

            if RGMercUtils.GetSetting('AssistOutside') then
                self:OOGCheckAndRez()
            end
        end

        self:RunHealRotation()
    end

    if self:IsCuring() or true then
        RGMercsLogger.log_verbose("\ao[Cures] Checking for curables...")
        self:RunCureRotation()
    end

    -- Downtime rotaiton will just run a full rotation to completion
    for _, r in ipairs(self.TempSettings.RotationStates) do
        RGMercsLogger.log_verbose("\ay:::TEST ROTATION::: => \at%s", r.name)
        local timeCheck = true
        if r.timer then
            self.TempSettings.RotationTimers[r.name] = self.TempSettings.RotationTimers[r.name] or 0
            if os.clock() - self.TempSettings.RotationTimers[r.name] < r.timer then
                timeCheck = false
            end
        end
        if timeCheck then
            for _, targetId in ipairs(r.targetId()) do
                if r.cond and r.cond(self, combat_state) then
                    RGMercsLogger.log_verbose("\aw:::RUN ROTATION::: \at%d\aw => \am%s", targetId, r.name)
                    self.CurrentRotation = { name = r.name, state = r.state or 0, }
                    local newState = RGMercUtils.RunRotation(self, self:GetRotationTable(r.name), targetId,
                        self.ResolvedActionMap, r.steps or 0, r.state or 0, self.CombatState == "Downtime")

                    if r.state then r.state = newState end
                    self.TempSettings.RotationTimers[r.name] = os.clock()
                end
            end
        else
            RGMercsLogger.log_verbose(
                "\ay:::TEST ROTATION::: => \at%s :: Skipped due to timer! Last Run: %s Next Run %s", r.name,
                RGMercUtils.FormatTime(os.clock() - self.TempSettings.RotationTimers[r.name]),
                RGMercUtils.FormatTime(r.timer - (os.clock() - self.TempSettings.RotationTimers[r.name])))
        end
    end

    if self.CombatState == "Downtime" then
        if not RGMercUtils.GetSetting('BurnAuto') then RGMercConfig:GetSettings().BurnSize = 0 end
    end
end

function Module:OnDeath()
end

function Module:OnZone()
    -- Zone Handler
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    local actionMap = "Action Map\n"
    actionMap = actionMap .. "-=-=-=-=-=\n"
    for k, entry in pairs(self.ResolvedActionMap) do
        local mappedAction = entry

        if mappedAction then
            if type(mappedAction) ~= "string" then
                mappedAction = mappedAction.RankName()
            end
        else
            if entry.type:lower() == "customfunc" then
                mappedAction = "cmd function"
            elseif entry.type:lower() == "spell" then
                mappedAction = "<Missing Spell>"
            elseif entry.type:lower() == "song" then
                mappedAction = "<Missing Song>"
            elseif entry.type:lower() == "ability" then
                mappedAction = entry.name
            elseif entry.type:lower() == "aa" then
                mappedAction = entry.name
            else
                mappedAction = entry.name
            end
        end

        actionMap = actionMap .. string.format("%-20s ==> %s\n", k, mappedAction)
    end
    local spellLoadout = "Spell Loadout\n-=-=-=-=-=-=-\n"

    for g, s in pairs(self.SpellLoadOut) do
        spellLoadout = spellLoadout .. string.format("[%-2d] :: %s\n", g, (s.spell.RankName.Name() or "None"))
    end

    local rotationStates = "Current Rotation States\n-=-=-=-=-=-=-=-\n"
    for idx, r in ipairs(self.TempSettings.RotationStates) do
        local actionEntry = self.ClassConfig.Rotations[r.name][r.state or 1]
        rotationStates = rotationStates ..
            string.format("[%d] %s :: %d :: Type: %s Action: %s\n", idx, r.name, r.state or 0, actionEntry.type,
                self.ResolvedActionMap[actionEntry.name] and self.ResolvedActionMap[actionEntry.name] or actionEntry
                .name)
    end

    local state = string.format("Combat State: %s", self.CombatState)

    return string.format("Class(%s)\n%s\n%s\n%s\n%s", RGMercConfig.Globals.CurLoadedClass, actionMap, spellLoadout,
        rotationStates, state)
end

---@param cmd string
---@param ... string
---@return boolean
function Module:HandleBind(cmd, ...)
    local handled = false
    -- /rglua cmd handler
    if self.ClassConfig.CommandHandlers and self.ClassConfig.CommandHandlers[cmd] then
        return self.ClassConfig.CommandHandlers[cmd].handler(self, ...)
    end
    return handled
end

function Module:Shutdown()
    RGMercsLogger.log_info("Core Class Module Unloaded.")
end

return Module
