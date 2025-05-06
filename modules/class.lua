-- Sample Basic Class Module
local mq          = require('mq')
local Combat      = require('utils.combat')
local Config      = require('utils.config')
local Core        = require("utils.core")
local Modules     = require("utils.modules")
local Movement    = require("utils.movement")
local Targeting   = require("utils.targeting")
local Rotation    = require("utils.rotation")
local Casting     = require("utils.casting")
local Ui          = require("utils.ui")
local Comms       = require("utils.comms")
local Strings     = require("utils.strings")
local Tables      = require("utils.tables")
local Files       = require("utils.files")
local Logger      = require("utils.logger")
local Set         = require("mq.Set")
local ClassLoader = require('utils.classloader')
local DanNet      = require('lib.dannet.helpers')
local Icons       = require('mq.ICONS')

require('utils.datatypes')

local Module                                 = { _version = '0.1a', _name = "Class", _author = 'Derple', }
Module.__index                               = Module

Module.ModuleLoaded                          = false
Module.SpellLoadOut                          = {}
Module.LoadOutName                           = "Loading..."
Module.ResolvedActionMap                     = {}
Module.TempSettings                          = {}
Module.CombatState                           = "None"
Module.CurrentRotation                       = { name = "None", state = 0, }
Module.ClassConfig                           = nil
Module.DefaultCategories                     = nil
Module.FAQ                                   = {}
Module.ClassFAQ                              = {}

Module.Constants                             = {}
Module.Constants.RezSearchGroup              = "pccorpse group radius 100 zradius 50"
Module.Constants.RezSearchOutOfGroup         = "pccorpse radius 100 zradius 50"

-- Track the state of rotations between frames
Module.TempSettings.CurrentRotationStateId   = 0
Module.TempSettings.CurrentRotationStateType = 0 -- 0 : Invalid, 1 : Combat, 2 : Healing
Module.TempSettings.RotationStates           = {}
Module.TempSettings.HealRotationStates       = {}
Module.TempSettings.RotationTimers           = {}
Module.TempSettings.RezTimers                = {}
Module.TempSettings.CureCheckTimer           = 0
Module.TempSettings.ShowFailedSpells         = false
Module.TempSettings.ResolvingActions         = true
Module.TempSettings.NewCombatMode            = false
Module.TempSettings.MissingSpells            = {}
Module.TempSettings.MissingSpellsHighestOnly = true
Module.TempSettings.CorpsesAlreadyRezzed     = {}

Module.CommandHandlers                       = {
    setmode = {
        usage = "/rgl setmode <mode>",
        about = "Change the active class mode to <mode>.",
        handler =
            function(self, mode)
                local newMode = nil
                local newModeIdx = 0

                for i, m in ipairs(self.ClassConfig.Modes) do
                    if m:lower() == mode:lower() then
                        newMode = m
                        newModeIdx = i
                        break
                    end
                end

                if not newMode then
                    Logger.log_error("\arInvalid Mode: \am%s", mode)
                    return true
                end

                if not self:IsModeActive(newMode) then
                    self.settings.Mode = newModeIdx
                    self:SetCombatMode(newMode)
                    return true
                end

                Logger.log_info("\awMode successfully set to: \am%s", newMode)

                return true
            end,
    },
    spellreload = {
        usage = "/rgl spellreload",
        about = "Rescans and (if necessary) reloads your default spell gems.",
        handler = function(self)
            self:RescanLoadout()

            Logger.log_info("\awManual loadout scan initiated.")

            return true
        end,
    },
    rebuff = {
        usage = "/rgl rebuff",
        about = "Resets the delay timer on buff rotations. Does not force the cast of any buff.",
        handler = function(self)
            self:ResetRotationTimer("SlowDowntime")
            self:ResetRotationTimer("GroupBuff")
            self:ResetRotationTimer("PetBuff")

            Logger.log_info("\awResetting buff rotation timers.")

            return true
        end,
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

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    -- set dynamic names.
    self:SetDynamicNames()

    if doBroadcast == true then
        Comms.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    -- load base configurations
    self.ClassConfig = ClassLoader.load(Config.Globals.CurLoadedClass)

    self.DefaultCategories = Set.new({})
    for k, v in pairs(self.ClassConfig.DefaultConfig or {}) do
        if v.Type ~= "Custom" then
            self.DefaultCategories:add(v.Category)
        end
        self.ClassFAQ[k] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', Settings_Used = k, }
    end

    Logger.log_info("\ar%s\ao Core Module Loading Settings for: %s.", Config.Globals.CurLoadedClass,
        Config.Globals.CurLoadedChar)
    Logger.log_info("\ayUsing Class Config by: \at%s\ay (\am%s\ay)", self.ClassConfig._author,
        self.ClassConfig._version)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[%s]: Unable to load module settings file(%s), creating a new one!",
            Config.Globals.CurLoadedClass, settings_pickle_path)
        self.settings = {}
        self:SaveSettings(false)
    else
        self.settings = config()
    end

    if not self.settings or not self.DefaultCategories or not self.ClassConfig.DefaultConfig then
        Logger.log_error("\arFailed to Load Core Class Config for Classs: %s", Config.Globals
            .CurLoadedClass)
        return
    end

    local settingsChanged = false

    -- Setup Defaults
    self.settings, settingsChanged = Config.ResolveDefaults(self.ClassConfig.DefaultConfig, self.settings)

    if settingsChanged then
        self:SaveSettings(false)
    end

    self:RescanLoadout()
end

function Module:WriteCustomConfig()
    ClassLoader.writeCustomConfig(Config.Globals.CurLoadedClass)
end

function Module:GetSettings()
    return self.settings
end

function Module:GetDefaultSettings()
    return self.ClassConfig.DefaultConfig
end

function Module:GetSettingCategories()
    return self.DefaultCategories
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    self.ModuleLoaded = false --reinitialize to stop class module UI render during persona switch (avoid crash conditions)
    Logger.log_debug("\agInitializing Core Class Module...")
    self:LoadSettings()

    -- set dynamic names.
    self:SetDynamicNames()

    self.ModuleLoaded = true

    if Config:GetSetting('DoPetCommands') and (Casting.CanUseAA("Companion's Discipline") or Casting.CanUseAA("Pet Discipline")) then
        Core.DoCmd("/pet ghold on")
    else
        Core.DoCmd("/pet hold on")
    end

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
                r.name = Core.SafeCallFunc("SetDynamicName", r.name_func, self) or "Error in name_func!"
            end
        end
    end
end

function Module:GetResolvedActionMapItem(item)
    if self.TempSettings.ResolvingActions then return nil end
    return self.ResolvedActionMap[item]
end

function Module:RescanLoadout()
    self.TempSettings.NewCombatMode = true
end

function Module:SetCombatMode(mode)
    if not Tables.TableContains(self.ClassConfig.Modes, mode) then
        Logger.log_error("\ayInvalid Mode: \am%s", mode)
        return false
    end
    Logger.log_debug("\aySettings Combat Mode to: \am%s", mode)
    self.TempSettings.ResolvingActions = true

    if self.ClassConfig then
        self.ResolvedActionMap = Rotation.ResolveActions(self.ClassConfig.ItemSets, self.ClassConfig.AbilitySets)
        self.TempSettings.ResolvingActions = false

        if self.ClassConfig.SpellList then
            self.SpellLoadOut, self.LoadOutName = Rotation.SetSpellLoadOutByPriority(self, self.ClassConfig.SpellList)
        else
            self.SpellLoadOut = Rotation.SetSpellLoadOutByGem(self, self.ClassConfig.Spells)
            self.LoadOutName = "Default"
        end
    end

    Rotation.LoadSpellLoadOut(self.SpellLoadOut)

    if self.ClassConfig.OnModeChange then
        self.ClassConfig.OnModeChange(self, mode)
    end

    self.TempSettings.MissingSpells = Rotation.FindAllMissingSpells(self.ClassConfig.AbilitySets, self.TempSettings.MissingSpellsHighestOnly)

    Modules:ExecAll("OnCombatModeChanged")
end

function Module:OnCombatModeChanged()
    -- set dynamic names.
    self:SetDynamicNames()
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    ImGui.Text("Combat State: %s", self.CombatState)
    ImGui.Text("Current Rotation: %s [%d]", self.CurrentRotation.name, self.CurrentRotation.state)

    ---@type boolean|nil
    local pressed = false
    local loadoutChange = false

    if self.ClassConfig and self.ModuleLoaded then
        ImGui.Text("Active Mode:")
        ImGui.SameLine()
        ImGui.SetNextItemWidth(150)
        Ui.Tooltip(self.ClassConfig.DefaultConfig.Mode.Tooltip)
        self.settings.Mode, pressed = ImGui.Combo("##_select_ai_mode", self.settings.Mode, self.ClassConfig.Modes,
            #self.ClassConfig.Modes)
        if pressed then
            self:SaveSettings(false)
            self:RescanLoadout()
        end
        ImGui.SameLine()
        if ImGui.SmallButton("Rescan Loadout") then
            self:RescanLoadout()
            Logger.log_info("\awManual loadout scan initiated.")
        end

        Ui.RenderConfigSelector()

        ImGui.Separator()

        if ImGui.CollapsingHeader(string.format("Spell Loadout (%s)", self.LoadOutName)) then
            ImGui.Indent()
            if ImGui.SmallButton("Reload Spells") then
                self:RescanLoadout()
                Logger.log_info("\awManual loadout scan initiated.")
            end

            if Tables.GetTableSize(self.SpellLoadOut) > 0 then
                Ui.RenderLoadoutTable(self.SpellLoadOut)
            end
            ImGui.Unindent()
            ImGui.Separator()
        end
        if ImGui.CollapsingHeader("Missing Spells") then
            ImGui.Indent()
            local pressed, anyPressed
            pressed = ImGui.SmallButton("Reload Missing Spells")
            anyPressed = pressed
            ImGui.SameLine()
            self.TempSettings.MissingSpellsHighestOnly, pressed = Ui.RenderOptionToggle("HighestOnly", "Highest Only", self.TempSettings.MissingSpellsHighestOnly)
            anyPressed = anyPressed or pressed
            if anyPressed then
                self.TempSettings.MissingSpells = Rotation.FindAllMissingSpells(self.ClassConfig.AbilitySets, self.TempSettings.MissingSpellsHighestOnly)
            end

            if #self.TempSettings.MissingSpells > 0 then
                Ui.RenderLoadoutTable(self.TempSettings.MissingSpells)
            end
            ImGui.Unindent()
            ImGui.Separator()
        end
        if not self.TempSettings.ResolvingActions then
            if ImGui.CollapsingHeader("Rotations") then
                ImGui.Indent()
                ImGui.Text("Combat State: %s", self.CombatState)
                ImGui.Text("Current Rotation: %s [%d]", self.CurrentRotation.name, self.CurrentRotation.state)
                Ui.RenderRotationTableKey()

                for _, r in ipairs(self.TempSettings.RotationStates) do
                    local rotationName = r.name
                    if ImGui.CollapsingHeader("[" .. (r.lastCondCheck and Icons.MD_CHECK or Icons.MD_CLOSE) .. "] " .. rotationName) then
                        ImGui.Indent()
                        self.TempSettings.ShowFailedSpells = Ui.RenderRotationTable(r.name,
                            self.ClassConfig.Rotations[r.name],
                            self.ResolvedActionMap, r.state or 0, self.TempSettings.ShowFailedSpells)
                        ImGui.Unindent()
                    end
                end
                ImGui.Unindent()
            end
        end

        if not self.TempSettings.ResolvingActions and #self.TempSettings.HealRotationStates > 0 then
            if ImGui.CollapsingHeader("Healing Rotations") then
                ImGui.Indent()
                Ui.RenderRotationTableKey()

                for _, r in pairs(self.TempSettings.HealRotationStates) do
                    local rotationName = r.name
                    if ImGui.CollapsingHeader("[" .. (r.lastCondCheck and Icons.MD_CHECK or Icons.MD_CLOSE) .. "] " .. rotationName) then
                        ImGui.Indent()
                        self.TempSettings.ShowFailedSpells = Ui.RenderRotationTable(r.name,
                            self.ClassConfig.HealRotations[r.name],
                            self.ResolvedActionMap, r.state or 0, self.TempSettings.ShowFailedSpells)
                        ImGui.Unindent()
                    end
                end
                ImGui.Unindent()
            end
        end

        ImGui.Separator()

        if ImGui.CollapsingHeader("Class Options") then
            self.settings, pressed, loadoutChange = Ui.RenderSettings(self.settings,
                self.ClassConfig.DefaultConfig, self.DefaultCategories)
            if pressed then
                self:SaveSettings(false)
                self.TempSettings.NewCombatMode = self.TempSettings.NewCombatMode or loadoutChange
            end
        end
    end
end

function Module:ResetRotation()
    for _, v in ipairs(self.TempSettings.RotationStates) do
        if v.state then
            v.state = 1
        end
    end
    for _, v in ipairs(self.TempSettings.HealRotationStates) do
        Logger.log_verbose("HealRotationsState(%s) reset from %d to 1", v.name, v.state)
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

---@return table
function Module:GetPullAbilities()
    if not self.ClassConfig then return {} end
    return self.ClassConfig.PullAbilities or {}
end

---@param mode string
---@return boolean
function Module:IsModeActive(mode)
    local modeSet = Set.new(self.ClassConfig.Modes)
    if not modeSet:contains(mode) then
        Logger.log_error("\arIsModeActive(%s) ==> Invalid Mode Type!", mode)
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
function Module:IsRezing()
    -- If we are healing then we are also rezing.
    if not self.ClassConfig or not self.ClassConfig.ModeChecks or not self.ClassConfig.ModeChecks.IsRezing then
        return self:IsHealing()
    end

    return self.ClassConfig.ModeChecks.IsRezing()
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

---@return boolean
function Module:IsCharming()
    if not self.ClassConfig or not self.ClassConfig.ModeChecks or not self.ClassConfig.ModeChecks.IsCharming then
        return false
    end
    return self.ClassConfig.ModeChecks.IsCharming()
end

---@return boolean
function Module:CanMez()
    if not self.ClassConfig or not self.ClassConfig.ModeChecks or not self.ClassConfig.ModeChecks.CanMez then
        return false
    end
    return self.ClassConfig.ModeChecks.CanMez()
end

---@return boolean
function Module:CanCharm()
    if not self.ClassConfig or not self.ClassConfig.ModeChecks or not self.ClassConfig.ModeChecks.CanCharm then
        return false
    end
    return self.ClassConfig.ModeChecks.CanCharm()
end

function Module:GetTheme()
    if self.ClassConfig and self.ClassConfig.Themes then
        return self.ClassConfig.Themes[self:GetClassModeName()]
    end
end

function Module:GetClassConfig()
    return self.ClassConfig
end

function Module:GetRotations()
    --check rotation load conditions
    self.TempSettings.ValidRotations = {}
    for _, m in pairs(self.ClassConfig.RotationOrder or {}) do
        if m.load_cond then
            local valid = Core.SafeCallFunc("CheckLoadConditions", m.load_cond, self)
            if valid then
                table.insert(self.TempSettings.ValidRotations, m)
            end
        else
            table.insert(self.TempSettings.ValidRotations, m)
        end
    end
    -- move the valid rotations to a useable table
    self.TempSettings.RotationStates = {}
    for i, m in ipairs(self.TempSettings.ValidRotations) do
        self.TempSettings.RotationStates[i] = m
    end

    --check heal rotation conditions
    self.TempSettings.ValidHealRotations = {}
    for _, m in pairs(self.ClassConfig.HealRotationOrder or {}) do
        if m.load_cond then
            local valid = Core.SafeCallFunc("CheckLoadConditions", m.load_cond, self)
            if valid then
                table.insert(self.TempSettings.ValidHealRotations, m)
            end
        else
            table.insert(self.TempSettings.ValidHealRotations, m)
        end
    end
    -- move the valid heal rotations to a useable table
    self.TempSettings.HealRotationStates = {}
    for i, m in ipairs(self.TempSettings.ValidHealRotations) do
        self.TempSettings.HealRotationStates[i] = m
    end
end

function Module:SelfCheckAndRez()
    local rezSearch = string.format("pccorpse %s' radius 100 zradius 50", mq.TLO.Me.DisplayName()) -- use ' to prevent partial name matches (foo's corpse vs foobar's corpse)
    local rezCount = mq.TLO.SpawnCount(rezSearch)()

    for i = 1, rezCount do
        Logger.log_debug("\atSelfCheckAndRez(): Looking for corpse #%d", i)
        local rezSpawn = mq.TLO.NearestSpawn(i, rezSearch)

        if rezSpawn() then
            Logger.log_debug("\atSelfCheckAndRez(): Found corpse of %s :: %s", rezSpawn.CleanName() or "Unknown", rezSpawn.Name() or "Unknown")
            if self.ClassConfig.HelperFunctions and self.ClassConfig.HelperFunctions.DoRez then
                if Tables.TableContains(Config.Globals.RezzedCorpses, rezSpawn.ID()) then
                    Logger.log_debug("\atSelfCheckAndRez(): Found corpse of %s(ID:%d), but it appears to have been rezzed already.", rezSpawn.CleanName() or "Unknown",
                        rezSpawn.ID() or 0)
                elseif (os.clock() - (self.TempSettings.RezTimers[rezSpawn.ID()] or 0)) >= Config:GetSetting('RetryRezDelay') then
                    Core.SafeCallFunc("SelfCheckAndRez", self.ClassConfig.HelperFunctions.DoRez, self, rezSpawn.ID())
                    self.TempSettings.RezTimers[rezSpawn.ID()] = os.clock()
                    self:ResetRotationTimer("GroupBuff")
                end
            end
        end
    end
end

function Module:IGCheckAndRez()
    local rezCount = mq.TLO.SpawnCount(self.Constants.RezSearchGroup)()

    for i = 1, rezCount do
        Logger.log_debug("\atIGCheckAndRez(): Looking for corpse #%d", i)
        local rezSpawn = mq.TLO.NearestSpawn(i, self.Constants.RezSearchGroup)

        if rezSpawn() then
            if self.ClassConfig.HelperFunctions.DoRez then
                Logger.log_debug("\atIGCheckAndRez(): Found corpse of %s :: %s", rezSpawn.CleanName() or "Unknown", rezSpawn.Name() or "Unknown")
                if Tables.TableContains(Config.Globals.RezzedCorpses, rezSpawn.ID()) then
                    Logger.log_debug("\atIGCheckAndRez(): Found corpse of %s(ID:%d), but it appears to have been rezzed already.", rezSpawn.CleanName() or "Unknown",
                        rezSpawn.ID() or 0)
                elseif (os.clock() - (self.TempSettings.RezTimers[rezSpawn.ID()] or 0)) >= Config:GetSetting('RetryRezDelay') then
                    Logger.log_debug("\atIGCheckAndRez(): Attempting to Res: %s", rezSpawn.CleanName())
                    Core.SafeCallFunc("IGCheckAndRez", self.ClassConfig.HelperFunctions.DoRez, self, rezSpawn.ID())
                    self.TempSettings.RezTimers[rezSpawn.ID()] = os.clock()
                    self:ResetRotationTimer("GroupBuff")
                end
            end
        end
    end
end

function Module:OOGCheckAndRez()
    local rezCount = mq.TLO.SpawnCount(self.Constants.RezSearchOutOfGroup)()

    for i = 1, rezCount do
        local rezSpawn = mq.TLO.NearestSpawn(i, self.Constants.RezSearchOutOfGroup)

        if rezSpawn() and (Targeting.IsSafeName("pc", rezSpawn.DisplayName())) then
            if self.ClassConfig.HelperFunctions.DoRez then
                if Tables.TableContains(Config.Globals.RezzedCorpses, rezSpawn.ID()) then
                    Logger.log_debug("\atOOGCheckAndRez(): Found corpse of %s(ID:%d), but it appears to have been rezzed already.", rezSpawn.CleanName() or "Unknown",
                        rezSpawn.ID() or 0)
                elseif (os.clock() - (self.TempSettings.RezTimers[rezSpawn.ID()] or 0)) >= Config:GetSetting('RetryRezDelay') then
                    Core.SafeCallFunc("OOGCheckAndRez", self.ClassConfig.HelperFunctions.DoRez, self, rezSpawn.ID())
                    self.TempSettings.RezTimers[rezSpawn.ID()] = os.clock()
                    self:ResetRotationTimer("GroupBuff")
                end
            end
        end
    end
end

function Module:HealById(id)
    if id == 0 then return end
    if not self.TempSettings.HealRotationStates then return end

    Logger.log_verbose("\awHealById(%d)", id)

    local healTarget = mq.TLO.Spawn(id)

    if not healTarget or not healTarget() or healTarget.PctHPs() <= 0 or healTarget.PctHPs() == 100 then
        Logger.log_verbose("\ayHealById(%d):: Target is dead fully healed or in another zone bailing!", id)
        return
    end

    if Targeting.TargetIsType("npc", healTarget) then
        Logger.log_verbose("\ayHealById(%d):: Target is an NPC bailing", id)
        return
    end

    Logger.log_verbose("\awHealById(%d):: Finding best heal to use", id)

    local selectedRotation = nil

    for idx, rotation in ipairs(self.TempSettings.HealRotationStates or {}) do
        self.TempSettings.CurrentRotationStateType = 2
        self.TempSettings.CurrentRotationStateId = idx

        Logger.log_verbose("\awHealById(%d):: Checking if Heal Rotation: \at%s\aw is appropriate to use.", id,
            rotation.name)
        if Core.SafeCallFunc(string.format("Heal Rotation Condition Check for %s", rotation.name), rotation.cond, self, healTarget) then
            rotation.lastCondCheck = true
            Logger.log_verbose("\awHealById(%d):: Heal Rotation: \at%s\aw \agis\aw appropriate to use.", id,
                rotation.name)
            -- since these are ordered by prioirty we can assume we are the best option.
            selectedRotation = rotation

            self.CurrentRotation = { name = selectedRotation.name, state = selectedRotation.state or 0, }

            -- If we need to heal others we should wait on the cooldown.
            Casting.WaitGlobalCoolDown("Healing: ")

            local newState, wasRun = Rotation.Run(self, self:GetHealRotationTable(selectedRotation.name), id,
                self.ResolvedActionMap, selectedRotation.steps or 0, selectedRotation.state or 0,
                self.CombatState == "Downtime", selectedRotation.doFullRotation or false, nil)

            if selectedRotation.state then selectedRotation.state = newState end

            if wasRun and Casting.GetLastCastResultName() == "CAST_SUCCESS" then
                Logger.log_verbose(
                    "\awHealById(%d):: Heal Rotation: \at%s\aw \agis\aw was \agSuccessful\aw!", id,
                    rotation.name)
                Comms.HandleAnnounce(string.format('Healed %s :: %s', healTarget.CleanName() or "Target", Casting.GetLastUsedSpell()),
                    Config:GetSetting('HealAnnounceGroup'),
                    Config:GetSetting('HealAnnounce'))
                break
            else
                Logger.log_verbose(
                    "\awHealById(%d):: Heal Rotation: \at%s\aw \agis\aw was \arNOT \awSuccessful! Conditions: wasRun(%s) castResult(%s) \ayGoing to keep trying!",
                    id,
                    rotation.name, Strings.BoolToColorString(wasRun), Casting.GetLastCastResultName())
            end
        else
            Logger.log_verbose("\awHealById(%d):: Heal Rotation: \at%s\aw \aris NOT\aw appropriate to use.", id,
                rotation.name)
            rotation.lastCondCheck = false
        end
    end

    self.TempSettings.CurrentRotationStateType = 0

    if selectedRotation == nil then
        Logger.log_verbose("\ayHealById(%d):: No appropriate heal rotation found. Bailling.", id)
        return
    end
end

function Module:RunHealRotation()
    Logger.log_verbose("\ao[Heals] Checking MA (HPs = %d)...", Core.GetMainAssistPctHPs())
    if Core.GetMainAssistPctHPs() < Config:GetSetting('MaxHealPoint') then
        self:HealById(Core.GetMainAssistId())
        Logger.log_verbose("\ao[Heals] Checked MA...")
    end

    Logger.log_verbose("\ao[Heals] Checking for injured friends...")
    self:HealById(Combat.FindWorstHurtGroupMember(Config:GetSetting('MaxHealPoint')))

    if Config:GetSetting('AssistOutside') then
        self:HealById(Combat.FindWorstHurtXT(Config:GetSetting('MaxHealPoint')))
    end

    if mq.TLO.Me.PctHPs() < Config:GetSetting('MaxHealPoint') then
        self:HealById(mq.TLO.Me.ID())
    end

    if Config:GetSetting('DoPetHeals') and mq.TLO.Me.Pet.ID() > 0 and mq.TLO.Me.Pet.PctHPs() < Config:GetSetting('PetHealPoint') then
        self:HealById(mq.TLO.Me.Pet.ID())
    end
end

function Module:RunCureRotation()
    if (os.clock() - self.TempSettings.CureCheckTimer) < Config:GetSetting('CureInterval') then return end

    self.TempSettings.CureCheckTimer = os.clock()

    local dannetPeers = mq.TLO.DanNet.PeerCount()
    local checks = {
        { type = "Poison",     check = "Me.Poisoned.ID", },
        { type = "Disease",    check = "Me.Diseased.ID", },
        { type = "Curse",      check = "Me.Cursed.ID", },
        { type = "Corruption", check = "Me.Corrupted.ID", },
        { type = "Mezzed",     check = "Me.Mezzed.ID", },
    }

    -- Me.TotalCounters does not work on emu we need to check everything.

    for i = 1, dannetPeers do
        ---@diagnostic disable-next-line: redundant-parameter
        local peer = mq.TLO.DanNet.Peers(i)()
        if peer and peer:len() > 0 then
            if mq.TLO.SpawnCount(string.format("pc =%s radius 150", peer))() == 1 then
                Logger.log_verbose("\ag[Cures] %s is in range - checking for curables", peer)
                for _, data in ipairs(checks) do
                    local effectId = DanNet.query(peer, data.check, 1000) or "null"
                    Logger.log_verbose("\ay[Cures] %s :: %s [%s] => %s", peer, data.check, data.type, effectId)

                    if effectId:lower() ~= "null" and effectId ~= "0" then
                        local cureTarget = mq.TLO.Spawn(string.format("pc =%s", peer))
                        if cureTarget and cureTarget() then
                            -- Cure it!
                            if self.ClassConfig.Cures and self.ClassConfig.Cures.CureNow then
                                Comms.HandleAnnounce(
                                    string.format('Attempting to cure %s of %s', cureTarget.CleanName() or "Target", data.type),
                                    Config:GetSetting('CureAnnounceGroup'),
                                    Config:GetSetting('CureAnnounce'))
                                Core.SafeCallFunc("CureNow", self.ClassConfig.Cures.CureNow, self, data.type, cureTarget.ID())
                            end
                        end
                    end
                end
            end
        else
            Logger.log_verbose("\ao[Cures] %d::%s is in \arNOT\ao range", i, peer or "Unknown")
        end
    end
end

function Module:RunCounterRotation()
    --can make this a modular table if more "features" are added. recommend adding a timer akin to cures if so.
    if mq.TLO.Me.Song("Curse of Subjugation")() and not mq.TLO.Me.Song("Aureate's Bane")() then
        if Casting.AAReady("Aureate's Bane") then
            return Casting.UseAA("Aureate's Bane", mq.TLO.Me.ID())
        else
            Logger.log_verbose("\ao[CounterActions] \ar***WARNING!***\ay Curse of Subjugation\aw detected, but Aureate's Bane \arNOT\aw available!")
        end
    end
end

function Module:DoCombatClickies() --TODO: Find out why normal clickies are in movement module. Split clickies into bene/detr/self-heals or something.
    -- I plan on breaking clickies out further to allow things like horn, other healing clickies to be used, that the user will select... this is "interim" implementation.
    if Core.OnLaz() and mq.TLO.Me.PctHPs() <= (Config:GetSetting('EmergencyStart', true) and Config:GetSetting('EmergencyStart') or 45) then
        local healingItems = { "Sanguine Mind Crystal", "Orb of Shadows", } -- "Draught of Opulent Healing", keeping this one manual for now
        for _, itemName in ipairs(healingItems) do
            local item = mq.TLO.FindItem(itemName)
            if item() and item.TimerReady() == 0 then
                Logger.log_verbose("Low Health Detected, using a heal clicky!")
                Casting.UseItem(item.Name(), mq.TLO.Me.ID())
                return
            end
        end
    end

    if not Config:GetSetting('UseCombatClickies') then return end

    -- make sure we are safe to use clickies
    if mq.TLO.Me.Sitting() or Casting.IAmFeigning() or not Core.OkayToNotHeal() or mq.TLO.Me.PctHPs() < (Config:GetSetting('EmergencyStart', true) and Config:GetSetting('EmergencyStart') or 45) then return end

    -- Control the frequency of checks to prioritize rotations
    self.TempSettings.CombatClickiesTimer = self.TempSettings.CombatClickiesTimer or 0
    if os.clock() - self.TempSettings.CombatClickiesTimer < Config:GetSetting('CombatClickiesDelay') then
        Logger.log_super_verbose("Too soon since last Combat Clickies check, aborting.")
        return
    end

    for i = 1, 6 do
        local setting = Config:GetSetting(string.format("CombatClicky%d", i))
        if setting and setting:len() > 0 then
            local item = mq.TLO.FindItem(setting)
            Logger.log_verbose("Looking for clicky item: %s found: %s", setting, Strings.BoolToColorString(item() ~= nil))

            if item then
                if item.Timer.TotalSeconds() == 0 then
                    if (item.RequiredLevel() or 0) <= mq.TLO.Me.Level() then
                        if Casting.DetSpellCheck(item.Clicky.Spell.RankName) then
                            Logger.log_verbose("\aaCasting Item: \at%s\ag Clicky: \at%s\ag!", item.Name(), item.Clicky.Spell.RankName.Name())
                            Casting.UseItem(item.Name(), Config.Globals.AutoTargetID)
                            break --ensure we stop after we process a single clicky to allow rotations to continue
                        else
                            Logger.log_verbose("\ayItem: \at%s\ay Clicky: \at%s\ay already active or would not stack!", item.Name(), item.Clicky.Spell.RankName.Name())
                        end
                    else
                        Logger.log_verbose("\ayItem: \at%s\ay Clicky: \at%s\ay I am too low level to use this clicky!", item.Name(), item.Clicky.Spell.RankName.Name())
                    end
                else
                    Logger.log_verbose("\ayItem: \at%s\ay Clicky: \at%s\ay Clicky timer not ready!", item.Name(), item.Clicky.Spell.RankName.Name())
                end
            end
        end
    end
    self.TempSettings.CombatClickiesTimer = os.clock()
end

function Module:GiveTime(combat_state)
    if not self.ClassConfig then return end

    local me = mq.TLO.Me
    ---@diagnostic disable-next-line: undefined-field
    if me.Hovering() or me.Stunned() or me.Charmed() or me.Mezzed() or me.Feared() then
        Logger.log_super_verbose("Class GiveTime aborted, we aren't in control of ourselves. Hovering(%s) Stunned(%s) Charmed(%s) Feared(%s) Mezzed(%s)",
            Strings.BoolToColorString(me.Hovering()), Strings.BoolToColorString(me.Stunned()), Strings.BoolToColorString(me.Charmed() ~= nil),
            ---@diagnostic disable-next-line: undefined-field
            Strings.BoolToColorString(me.Mezzed() ~= nil), Strings.BoolToColorString(me.Feared() ~= nil))
        return
    end

    if Config.ShouldPriorityFollow() then
        Logger.log_verbose("\arSkipping Class GiveTime because we are moving and follow is the priority.")
        return
    end

    -- Main Module logic goes here.
    if self.TempSettings.NewCombatMode then
        Logger.log_debug("New Combat Mode Requested: %s", self.ClassConfig.Modes[self.settings.Mode])
        self:SetCombatMode(self.ClassConfig.Modes[self.settings.Mode])
        self:GetRotations()
        self.TempSettings.NewCombatMode = false
    end

    if self.CombatState ~= combat_state and combat_state == "Downtime" then
        self:ResetRotation()
    end

    self.CombatState = combat_state

    -- Healing happens first and anytime we aren't in downtime while invis and set not to break it.
    if self:IsHealing() then
        if not (combat_state == "Downtime" and mq.TLO.Me.Invis() and not Config:GetSetting('BreakInvis')) then
            self:RunHealRotation()
        end
    end

    if self:IsRezing() then
        -- Check Rezes
        if not (combat_state == "Downtime" and mq.TLO.Me.Invis() and not Config:GetSetting('BreakInvis')) then
            self:IGCheckAndRez()

            self:SelfCheckAndRez()

            if Config:GetSetting('AssistOutside') then
                self:OOGCheckAndRez()
            end

            --clear the table of corpses we've already rezzed if there are no PC corpses nearby
            if Core.OnEMU() then
                local rezCount = mq.TLO.SpawnCount("pccorpse radius 150 zradius 50")()
                if rezCount == 0 then
                    Config.Globals.RezzedCorpses = {}
                    Config.Globals.CorpseConned  = false
                end
            end
        end
    end

    if self:IsCuring() then
        if not (combat_state == "Downtime" and mq.TLO.Me.Invis() and not Config:GetSetting('BreakInvis')) then
            Logger.log_verbose("\ao[Cures] Checking for curables...")
            self:RunCureRotation()
        end
    end

    --Counter TOB Debuff with AA Buff, this can be refactored/expanded if they add other similar systems
    if Config:GetSetting('UseCounterActions') then
        Logger.log_verbose("\ao[CounterActions] Checking for debuffs to counter...")
        self:RunCounterRotation()
    end

    if self:IsTanking() and Config:GetSetting('MovebackWhenBehind') then
        -- make sure nothing is behind us when tanking.
        -- Maybe spawn search is failing us -- look through the xtarget list
        local xtCount = mq.TLO.Me.XTarget()

        for i = 1, xtCount do
            local xtSpawn = mq.TLO.Me.XTarget(i)
            if xtSpawn and xtSpawn.ID() > 0 and not xtSpawn.Dead() and (math.ceil(xtSpawn.PctHPs() or 0)) > 0 and ((xtSpawn.Aggressive() or xtSpawn.TargetType():lower() == "auto hater") or Targeting.ForceCombat) and not Config.Constants.RGMezAnims:contains(xtSpawn.Animation()) and math.abs((mq.TLO.Me.Heading.Degrees() - (xtSpawn.Heading.Degrees() or 0))) < 100 then
                Logger.log_debug("\arXT(%s) is behind us! \atTaking evasive maneuvers! \awMyHeader(\am%d\aw) ThierHeading(\am%d\aw)", xtSpawn.DisplayName() or "",
                    mq.TLO.Me.Heading.Degrees(), (xtSpawn.Heading.Degrees() or 0))
                if os.clock() - Movement.LastDoStick < 0.5 then
                    Logger.log_debug("\ayIgnoring moveback because we just stuck a second ago - let's give it some time.")
                else
                    Core.DoCmd("/stick moveback %d", Config:GetSetting('MovebackDistance'))
                    Movement.LastDoStick = os.clock()
                end
            end
        end
    end

    -- Downtime rotation will just run a full rotation to completion
    for idx, r in ipairs(self.TempSettings.RotationStates) do
        Logger.log_verbose("\ay:::TEST ROTATION::: => \at%s", r.name)
        self.TempSettings.CurrentRotationStateType = 1
        self.TempSettings.CurrentRotationStateId = idx
        local timeCheckPassed = true

        self.TempSettings.RotationTimers[r.name] = self.TempSettings.RotationTimers[r.name] or 0
        if r.timer then -- see if we've waited the rotation timer out.
            timeCheckPassed = ((os.clock() - self.TempSettings.RotationTimers[r.name]) >= r.timer)
        else            -- default to only processing Downtime rotations once per second if no timer is specified.
            timeCheckPassed = self.CombatState ~= "Downtime" and true or ((os.clock() - self.TempSettings.RotationTimers[r.name]) >= 1)
        end
        if timeCheckPassed then
            local targetTable = Core.SafeCallFunc("Rotation Target Table", r.targetId)
            if targetTable ~= false then
                for _, targetId in ipairs(targetTable) do
                    -- only do combat with a target.
                    if targetId and targetId > 0 then
                        if Core.SafeCallFunc(string.format("Rotation Condition Check for %s", r.name), r.cond, self, combat_state) then
                            r.lastCondCheck = true
                            Logger.log_verbose("\aw:::RUN ROTATION::: \at%d\aw => \am%s", targetId, r.name)
                            self.CurrentRotation = { name = r.name, state = r.state or 0, }
                            local newState = Rotation.Run(self, self:GetRotationTable(r.name), targetId,
                                self.ResolvedActionMap, r.steps or 0, r.state or 0, self.CombatState == "Downtime", r.doFullRotation or false, r.cond)

                            if r.state then r.state = newState end
                            self.TempSettings.RotationTimers[r.name] = os.clock()
                        else
                            r.lastCondCheck = false
                        end
                    end
                end
            end
        else
            Logger.log_verbose(
                "\ay:::TEST ROTATION::: => \at%s :: Skipped due to timer! Last Run: %s Next Run %s", r.name,
                Strings.FormatTime(os.clock() - self.TempSettings.RotationTimers[r.name]),
                Strings.FormatTime((r.timer or 1) - (os.clock() - self.TempSettings.RotationTimers[r.name])))
        end
    end

    self.TempSettings.CurrentRotationStateType = 0

    if combat_state == "Combat" then
        self:DoCombatClickies()
    end
end

function Module:SetCurrentRotationState(state)
    if self.TempSettings.CurrentRotationStateType == 0 then return end

    if self.TempSettings.CurrentRotationStateType == 1 then
        if not self.TempSettings.RotationStates[self.TempSettings.CurrentRotationStateId] then return end
        self.TempSettings.RotationStates[self.TempSettings.CurrentRotationStateId].state = state
    end

    if self.TempSettings.CurrentRotationStateType == 2 then
        if not self.TempSettings.HealRotationStates[self.TempSettings.CurrentRotationStateId] then return end
        self.TempSettings.HealRotationStates[self.TempSettings.CurrentRotationStateId].state = state
    end
end

function Module:OnDeath()
    Core.DoCmd("/nav stop")
    Core.DoCmd("/stick off")
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

    return string.format("Class(%s)\n%s\n%s\n%s\n%s", Config.Globals.CurLoadedClass, actionMap, spellLoadout,
        rotationStates, state)
end

function Module:GetVersionString()
    if not self.ClassConfig then return "Unknown" end
    return string.format("%s %s", Config.Globals.CurLoadedClass, self.ClassConfig._version)
end

function Module:GetAuthorString()
    if not self.ClassConfig then return "Unknown" end
    return string.format("%s", self.ClassConfig._author)
end

function Module:GetCommandHandlers()
    local cmdHandlers = self.CommandHandlers or {}

    for cmd, data in pairs(self.ClassConfig.CommandHandlers or {}) do
        cmdHandlers[cmd] = data
    end

    return { module = self._name, CommandHandlers = cmdHandlers, }
end

function Module:GetFAQ()
    return { module = self._name, FAQ = self.FAQ or {}, }
end

function Module:GetClassFAQ()
    return { module = self._name, FAQ = self.ClassFAQ or {}, }
end

---@param cmd string
---@param ... string
---@return boolean
function Module:HandleBind(cmd, ...)
    local handled = false
    -- /rglua cmd handler
    if self.ClassConfig.CommandHandlers and self.ClassConfig.CommandHandlers[cmd] then
        return Core.SafeCallFunc(string.format("Command Handler: %s", cmd), self.ClassConfig.CommandHandlers[cmd].handler, self, ...)
    end

    if self.CommandHandlers and self.CommandHandlers[cmd] then
        return Core.SafeCallFunc(string.format("Command Handler: %s", cmd), self.CommandHandlers[cmd].handler, self, ...)
    end
    return handled
end

function Module:ResetRotationTimer(rotation)
    if self.TempSettings.RotationTimers[rotation] then
        Logger.log_verbose("\ayResetting Class:TempSettings.RotationTimers[\ag%s\ay].", rotation)
        self.TempSettings.RotationTimers[rotation] = 0
    end
end

function Module:Shutdown()
    Logger.log_debug("Core Class Module Unloaded.")
end

return Module
