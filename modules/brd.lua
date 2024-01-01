-- Sample Basic Class Module
local mq                 = require('mq')
local RGMercsLogger      = require("utils.rgmercs_logger")
local RGMercUtils        = require("utils.rgmercs_utils")
local Set                = require("mq.Set")

local custom_config_file = mq.configDir .. "/rgmercs/class_configs/brd_class_config.lua"

local brdClassConfig     = nil
if RGMercUtils.file_exists(custom_config_file) then
    RGMercsLogger.log_info("Loading Custom Bard Config: %s", custom_config_file)
    local config, err = loadfile(custom_config_file)
    if not config or err then
        RGMercsLogger.log_error("Failed to Load Custom Bard Config: %s", custom_config_file)
    else
        brdClassConfig = config()
    end
end

if not brdClassConfig then
    brdClassConfig = require("class_configs.brd_class_config")
end


local Module             = { _version = '0.1a', name = "Bard", author = 'Derple, Tiddliestix', }
Module.__index           = Module
Module.SpellLoadOut      = {}
Module.ResolvedActionMap = {}
Module.TempSettings      = {}

Module.DefaultCategories = Set.new({})
for _, v in pairs(brdClassConfig.DefaultConfig) do
    if v.Type ~= "Custom" then
        Module.DefaultCategories:add(v.Category)
    end
end

-- Track the state of rotations between frames
Module.TempSettings.RotationStates = {
    ['DPS'] = 1,
    ['Burn'] = 1,
}

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
    RGMercsLogger.log_info("\arBard\ao Combat Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    RGMercsLogger.log_info("\ayUsing Class Config by: \at%s\ay (\am%s\ay)", brdClassConfig._author, brdClassConfig._version)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Bard]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self.settings = {}
        self:SaveSettings(true)
    else
        self.settings = config()
    end

    -- Setup Defaults
    for k, v in pairs(brdClassConfig.DefaultConfig) do
        self.settings[k] = self.settings[k] or v.Default
    end

    -- Remove Deprecated options
    for k, _ in pairs(self.settings) do
        if not brdClassConfig.DefaultConfig[k] then
            self.settings[k] = nil
            RGMercsLogger.log_info("\aySettings [\am%s\ay] has been deprecated -- removing from your config.", k)
        end
    end
    newCombatMode = true
end

function Module.New()
    -- Only load this module for SKs
    if RGMercConfig.Globals.CurLoadedClass ~= "brd" then return nil end

    RGMercsLogger.log_info("Bard Combat Module Loaded.")
    local newModule = setmetatable({ settings = {}, CombatState = "None", }, Module)

    newModule:LoadSettings()

    return newModule
end

function Module:setCombatMode(mode)
    RGMercsLogger.log_debug("\aySettings Combat Mode to: \am%s", mode)
    if mode == "Tank" then
        RGMercConfig.Globals.IsTanking = true
        Module.ResolvedActionMap, Module.SpellLoadOut = RGMercUtils.SetLoadOut(self,
            brdClassConfig.Spells,
            brdClassConfig.ItemSets, brdClassConfig.AbilitySets)
    elseif mode == "DPS" then
        RGMercConfig.Globals.IsTanking = false
        Module.ResolvedActionMap, Module.SpellLoadOut = RGMercUtils.SetLoadOut(self,
            brdClassConfig.Spells,
            brdClassConfig.ItemSets, brdClassConfig.AbilitySets)
    end

    RGMercUtils.LoadSpellLoadOut(Module.SpellLoadOut)
end

function Module:Render()
    ImGui.Text("Bard Combat Modules")

    ---@type boolean|nil
    local pressed = false
    local loadoutChange = false

    ImGui.Text("Mode: ")
    ImGui.SameLine()
    RGMercUtils.Tooltip(brdClassConfig.DefaultConfig.Mode.Tooltip)
    self.settings.Mode, pressed = ImGui.Combo("##_select_ai_mode", self.settings.Mode, brdClassConfig.Modes,
        #brdClassConfig.Modes)
    if pressed then
        self:SaveSettings(true)
        newCombatMode = true
    end

    if ImGui.CollapsingHeader("Config Options") then
        self.settings, pressed, loadoutChange = RGMercUtils.RenderSettings(self.settings, brdClassConfig.DefaultConfig, self.DefaultCategories)
        if pressed then
            self:SaveSettings(true)
            newCombatMode = newCombatMode or loadoutChange
        end
    end

    ImGui.Separator()

    if ImGui.CollapsingHeader("Spell Loadout") then
        ImGui.Indent()
        RGMercUtils.RenderLoadoutTable(Module.SpellLoadOut)
        ImGui.Unindent()
    end

    ImGui.Separator()

    if ImGui.CollapsingHeader("Rotations") then
        local rotationNames = {}
        for k, _ in pairs(brdClassConfig.Rotations) do
            table.insert(rotationNames, k)
        end
        table.sort(rotationNames)

        ImGui.Indent()
        RGMercUtils.RenderRotationTableKey()

        for _, k in pairs(rotationNames) do
            if ImGui.CollapsingHeader(k) then
                ImGui.Indent()
                RGMercUtils.RenderRotationTable(self, k, brdClassConfig.Rotations[k],
                    Module.ResolvedActionMap, self.TempSettings.RotationStates[k])
                ImGui.Unindent()
            end
        end
        ImGui.Unindent()
    end
    ImGui.Text(string.format("Combat State: %s", self.CombatState))
end

function Module:ResetRotation()
    for k, _ in pairs(self.TempSettings.RotationStates) do
        self.TempSettings.RotationStates[k] = 1
    end
end

function Module:GetRotationTable(mode)
    if RGMercConfig.Globals.IsTanking then
        return brdClassConfig.Rotations[mode]
    end

    return brdClassConfig.Rotations[mode]
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
    if newCombatMode then
        RGMercsLogger.log_debug("New Combat Mode Requested: %s", brdClassConfig.Modes[self.settings.Mode])
        self:setCombatMode(brdClassConfig.Modes[self.settings.Mode])
        newCombatMode = false
    end

    if self.CombatState ~= combat_state and combat_state == "Downtime" then
        self:ResetRotation()
    end

    self.CombatState = combat_state

    -- Downtime totaiton will just run a full rotation to completion
    if self.CombatState == "Downtime" then
        RGMercUtils.RunRotation(self, self:GetRotationTable("Downtime"), mq.TLO.Me.ID(), Module.ResolvedActionMap, nil, nil, true)

        if not self.settings.BurnAuto then self.settings.BurnSize = 0 end
    else
        if RGMercUtils.BurnCheck(self.settings) then
            self.TempSettings.RotationStates.Burn = RGMercUtils.RunRotation(self, self:GetRotationTable("Burn"), RGMercConfig.Globals.AutoTargetID,
                Module.ResolvedActionMap, 1, self.TempSettings.RotationStates.Burn, false)
        end

        self.TempSettings.RotationStates.DPS = RGMercUtils.RunRotation(self, self:GetRotationTable("DPS"), RGMercConfig.Globals.AutoTargetID,
            Module.ResolvedActionMap, 1, self.TempSettings.RotationStates.DPS, false)
    end
end

function Module:Shutdown()
    RGMercsLogger.log_info("Bard Combat Module UnLoaded.")
end

function Module:OnDeath()
end

return Module
