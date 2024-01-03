-- Sample Basic Class Module
local mq                           = require('mq')
local RGMercsLogger                = require("utils.rgmercs_logger")
local RGMercUtils                  = require("utils.rgmercs_utils")
local Set                          = require("mq.Set")

local Module                       = { _version = '0.1a', name = "Class", author = 'Derple', }
Module.__index                     = Module
Module.LastPetCmd                  = 0
Module.ModuleLoaded                = false
Module.ShowFailedSpells            = false
Module.ReloadingLoadouts           = true
Module.SpellLoadOut                = {}
Module.ResolvedActionMap           = {}
Module.TempSettings                = {}
Module.CombatState                 = "None"
Module.ClassConfig                 = nil
Module.DefaultCategories           = nil

-- Track the state of rotations between frames
Module.TempSettings.RotationStates = {}

local newCombatMode                = false

local function getConfigFileName()
    return mq.configDir ..
        '/rgmercs/PCConfigs/' ..
        Module.name .. "_" .. RGMercConfig.Globals.CurServer .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast then
        RGMercUtils.BroadcastUpdate(self.name, "LoadSettings")
    end
end

function Module:LoadSettings()
    local custom_config_file = string.format("%s/rgmercs/class_configs/%s_class_config.lua", mq.configDir, RGMercConfig.Globals.CurLoadedClass:lower())

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
        self.ClassConfig = require(string.format("class_configs.%s_class_config", RGMercConfig.Globals.CurLoadedClass:lower()))
    end

    Module.DefaultCategories = Set.new({})
    for _, v in pairs(self.ClassConfig.DefaultConfig or {}) do
        if v.Type ~= "Custom" then
            Module.DefaultCategories:add(v.Category)
        end
    end

    Module.TempSettings.RotationStates = {}
    for _, m in ipairs(self.ClassConfig.Modes) do table.insert(Module.TempSettings.RotationStates, m) end

    RGMercsLogger.log_info("\ar%s\ao Core Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedClass, RGMercConfig.Globals.CurLoadedChar)
    RGMercsLogger.log_info("\ayUsing Class Config by: \at%s\ay (\am%s\ay)", self.ClassConfig._author, self.ClassConfig._version)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[%s]: Unable to load module settings file(%s), creating a new one!", RGMercConfig.Globals.CurLoadedClass, settings_pickle_path)
        self.settings = {}
        self:SaveSettings(true)
    else
        self.settings = config()
    end

    if not self.settings or not self.DefaultCategories or not self.DefaultConfig then
        RGMercsLogger.log_error("Failed to Load Core Class Config for Classs: %s", RGMercConfig.Globals.CurLoadedClass)
        return
    end

    -- Setup Defaults
    self.settings = RGMercUtils.ResolveDefaults(self.ClassConfig.DefaultConfig, self.settings)

    newCombatMode = true
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    RGMercsLogger.log_info("\agInitializing Core Class Module...")
    self:LoadSettings()

    self.ModuleLoaded = true

    return { settings = self.settings, defaults = self.ClassConfig.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:GetResolvedActionMapItem(item)
    if self.ReloadingLoadouts then return nil end
    return self.ResolvedActionMap[item]
end

function Module:SetCombatMode(mode)
    RGMercsLogger.log_debug("\aySettings Combat Mode to: \am%s", mode)
    if mode == "Tank" then
        RGMercConfig.Globals.IsTanking = true
    else
        RGMercConfig.Globals.IsTanking = false
    end

    self.ReloadingLoadouts = true

    if self.ClassConfig then
        self.ResolvedActionMap, self.SpellLoadOut = RGMercUtils.SetLoadOut(self,
            self.ClassConfig.Spells, self.ClassConfig.ItemSets, self.ClassConfig.AbilitySets)
    end

    self.ReloadingLoadouts = false
    RGMercUtils.LoadSpellLoadOut(self.SpellLoadOut)
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
        self.settings.Mode, pressed = ImGui.Combo("##_select_ai_mode", self.settings.Mode, self.ClassConfig.Modes, #self.ClassConfig.Modes)
        if pressed then
            self:SaveSettings(true)
            newCombatMode = true
        end

        if ImGui.CollapsingHeader("Config Options") then
            self.settings, pressed, loadoutChange = RGMercUtils.RenderSettings(self.settings, self.ClassConfig.DefaultConfig, self.DefaultCategories)
            if pressed then
                self:SaveSettings(true)
                newCombatMode = newCombatMode or loadoutChange
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

        if not self.ReloadingLoadouts then
            if ImGui.CollapsingHeader("Rotations") then
                local rotationNames = {}
                for k, _ in pairs(self.ClassConfig.Rotations) do
                    table.insert(rotationNames, k)
                end
                table.sort(rotationNames)

                ImGui.Indent()
                RGMercUtils.RenderRotationTableKey()

                for _, k in pairs(rotationNames) do
                    if ImGui.CollapsingHeader(k) then
                        ImGui.Indent()
                        Module.ShowFailedSpells = RGMercUtils.RenderRotationTable(self, k, self.ClassConfig.Rotations[k],
                            self.ResolvedActionMap, self.TempSettings.RotationStates[k], Module.ShowFailedSpells)
                        ImGui.Unindent()
                    end
                end
                ImGui.Unindent()
            end
        end

        ImGui.Text(string.format("Combat State: %s", self.CombatState))
    end
end

function Module:ResetRotation()
    for k, _ in pairs(self.TempSettings.RotationStates) do
        self.TempSettings.RotationStates[k] = 1
    end
end

function Module:GetRotationTable(mode)
    if RGMercConfig.Globals.IsTanking and self.ClassConfig then
        return self.ClassConfig.Rotations[mode]
    end

    return self.ClassConfig and self.ClassConfig.Rotations[mode] or {}
end

function Module:GetClassModeId()
    return self.settings.Mode
end

function Module:GetClassModeName()
    return self.ClassConfig and self.ClassConfig.Modes[self.settings.Mode] or "None"
end

function Module:GetTheme()
    if self.ClassConfig and self.ClassConfig.Themes then
        return self.ClassConfig.Themes[self:GetClassModeName()]
    end
end

function Module:GiveTime(combat_state)
    if not self.ClassConfig then return end

    -- Main Module logic goes here.
    if newCombatMode then
        RGMercsLogger.log_debug("New Combat Mode Requested: %s", self.ClassConfig.Modes[self.settings.Mode])
        self:SetCombatMode(self.ClassConfig.Modes[self.settings.Mode])
        newCombatMode = false
    end

    if self.CombatState ~= combat_state and combat_state == "Downtime" then
        self:ResetRotation()
    end

    self.CombatState = combat_state

    -- Downtime totaiton will just run a full rotation to completion
    if self.CombatState == "Downtime" then
        RGMercUtils.RunRotation(self, self:GetRotationTable("Downtime"), mq.TLO.Me.ID(), self.ResolvedActionMap, nil, nil, true)

        if not self.settings.BurnAuto then self.settings.BurnSize = 0 end
    else
        if RGMercUtils.BurnCheck(self.settings) then
            self.TempSettings.RotationStates.Burn = RGMercUtils.RunRotation(self, self:GetRotationTable("Burn"), RGMercConfig.Globals.AutoTargetID,
                self.ResolvedActionMap, 1, self.TempSettings.RotationStates.Burn, false)
        end

        self.TempSettings.RotationStates.DPS = RGMercUtils.RunRotation(self, self:GetRotationTable("DPS"), RGMercConfig.Globals.AutoTargetID,
            self.ResolvedActionMap, 1, self.TempSettings.RotationStates.DPS, false)
    end
end

function Module:OnDeath()
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
    RGMercsLogger.log_info("Core Class Module UnLoaded.")
end

return Module
