-- Sample Basic Class Module
local mq                           = require('mq')
local RGMercsLogger                = require("rgmercs.utils.rgmercs_logger")
local RGMercUtils                  = require("rgmercs.utils.rgmercs_utils")
local shdClassConfig               = require("rgmercs.class_configs.shd_class_config")

local Module                       = { _version = '0.1a', name = "ShadowKnight", author = 'Derple' }
Module.__index                     = Module
Module.LastPetCmd                  = 0
Module.SpellLoadOut                = {}
Module.ResolvedActionMap           = {}
Module.TempSettings                = {}

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
        RGMercUtils.BroadcastUpdate(self.name, "SaveSettings")
    end
end

function Module:LoadSettings()
    RGMercsLogger.log_info("Basic Combat Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Basic]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self.settings = {}
        self:SaveSettings(true)
    else
        self.settings = config()
    end

    -- Setup Defaults
    for k, v in pairs(shdClassConfig.DefaultConfig) do
        self.settings[k] = self.settings[k] or v.Default
    end

    for rot, rot_entry in pairs(shdClassConfig.DefaultRotations) do
        RGMercsLogger.log_debug("Appending new entry for rotation %s", rot)
        for _, entry in ipairs(rot_entry) do
            for rot_type, _ in pairs(shdClassConfig.Rotations) do
                table.insert(shdClassConfig.Rotations[rot_type].Rotation[rot], entry)
            end
        end
    end

    newCombatMode = true
end

function Module.New()
    -- Only load this module for SKs
    if RGMercConfig.Globals.CurLoadedClass ~= "SHD" then return nil end

    RGMercsLogger.log_info("ShadowKnight Combat Module Loaded.")
    local newModule = setmetatable({ settings = {}, CombatState = "None" }, Module)

    newModule:LoadSettings()

    return newModule
end

-- helper function for advanced logic to see if we want to use Dark Lord's Unity
function Module:castDLU()
    if not Module.ResolvedActionMap['Shroud'] then return false end

    local res = mq.TLO.Spell(Module.ResolvedActionMap['Shroud']).Level() <=
        (mq.TLO.Me.AltAbility("Dark Lord's Unity (Azia)").Spell.Level() or 0) and
        mq.TLO.Me.AltAbility("Dark Lord's Unity (Azia)").MinLevel() <= mq.TLO.Me.Level() and
        mq.TLO.Me.AltAbility("Dark Lord's Unity (Azia)").Rank() > 0

    return res
end

function Module:setCombatMode(mode)
    RGMercsLogger.log_debug("\aySettings Combat Mode to: \am%s", mode)
    if mode == "Tank" then
        RGMercConfig.Globals.IsTanking = true
        if self.settings.TLP then
            Module.ResolvedActionMap, Module.SpellLoadOut = RGMercUtils.SetLoadOut(self,
                shdClassConfig.Rotations.TLP_Tank.Spells, shdClassConfig.ItemSets, shdClassConfig.AbilitySets)
        else
            Module.ResolvedActionMap, Module.SpellLoadOut = RGMercUtils.SetLoadOut(self,
                shdClassConfig.Rotations.Tank.Spells,
                shdClassConfig.ItemSets, shdClassConfig.AbilitySets)
        end
    elseif mode == "DPS" then
        RGMercConfig.Globals.IsTanking = false
        if self.settings.TLP then
            Module.ResolvedActionMap, Module.SpellLoadOut = RGMercUtils.SetLoadOut(self,
                shdClassConfig.Rotations.TLP_DPS.Spells, shdClassConfig.ItemSets, shdClassConfig.AbilitySets)
        else
            Module.ResolvedActionMap, Module.SpellLoadOut = RGMercUtils.SetLoadOut(self,
                shdClassConfig.Rotations.DPS.Spells,
                shdClassConfig.ItemSets, shdClassConfig.AbilitySets)
        end
    end

    RGMercUtils.LoadSpellLoadOut(Module.SpellLoadOut)
end

function Module:Render()
    ImGui.Text("ShadowKnight Combat Modules")

    ---@type boolean|nil
    local pressed = false
    local loadoutChange = false

    ImGui.Text("Mode: ")
    ImGui.SameLine()
    RGMercUtils.Tooltip(shdClassConfig.DefaultConfig.Mode.Tooltip)
    self.settings.Mode, pressed = ImGui.Combo("##_select_ai_mode", self.settings.Mode, shdClassConfig.Modes,
        #shdClassConfig.Modes)
    if pressed then
        self:SaveSettings(true)
        newCombatMode = true
    end

    if ImGui.CollapsingHeader("Config Options") then
        self.settings, pressed, loadoutChange = RGMercUtils.RenderSettings(self.settings, shdClassConfig.DefaultConfig)
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
        ImGui.Indent()
        RGMercUtils.RenderRotationTableKey()

        local mode = shdClassConfig.Modes[self.settings.Mode]
        if self.settings.TLP then
            mode = "TLP_" .. mode
        end
        for k, v in pairs(shdClassConfig.Rotations[mode].Rotation) do
            if ImGui.CollapsingHeader(k) then
                ImGui.Indent()
                RGMercUtils.RenderRotationTable(self, k, shdClassConfig.Rotations[mode].Rotation[k],
                    Module.ResolvedActionMap, self.TempSettings.RotationStates[k])
                ImGui.Unindent()
            end
        end
        ImGui.Unindent()
    end
    ImGui.Text(string.format("Combat State: %s", self.CombatState))
end

function Module:GetRotationTable(mode)
    if RGMercConfig.Globals.IsTanking and self.settings.TLP then
        return shdClassConfig.Rotations.TLP_Tank.Rotation[mode]
    elseif not RGMercConfig.Globals.IsTanking and self.settings.TLP then
        return shdClassConfig.Rotations.TLP_DPS.Rotation[mode]
    elseif RGMercConfig.Globals.IsTanking then
        return shdClassConfig.Rotations.Tank.Rotation[mode]
    end

    return shdClassConfig.Rotations.DPS.Rotation[mode]
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
    if newCombatMode then
        RGMercsLogger.log_debug("New Combat Mode Requested: %s", shdClassConfig.Modes[self.settings.Mode])
        self:setCombatMode(shdClassConfig.Modes[self.settings.Mode])
        newCombatMode = false
    end

    self.CombatState = combat_state

    -- Downtime totaiton will just run a full rotation to completion
    if self.CombatState == "Downtime" then
        RGMercUtils.RunRotation(self, self:GetRotationTable("Downtime"), mq.TLO.Me.ID(), Module.ResolvedActionMap)

        if not self.settings.BurnAuto then self.settings.BurnSize = 0 end
    else
        if RGMercConfig.Globals.IsTanking and ((os.clock() - Module.LastPetCmd) > 2) then
            Module.LastPetCmd = os.clock()
            RGMercUtils.PetAttack(self.settings, mq.TLO.Target)
        end

        RGMercUtils.RunRotation(self, self:GetRotationTable("DPS"), RGMercConfig.Globals.AutoTargetID,
            Module.ResolvedActionMap, 1, self.TempSettings.RotationStates.DPS)

        if RGMercConfig.BurnCheck(self.settings) then
            RGMercUtils.RunRotation(self, self:GetRotationTable("Burn"), RGMercConfig.Globals.AutoTargetID,
                Module.ResolvedActionMap, 1, self.TempSettings.RotationStates.Burn)
        end
    end
end

function Module:Shutdown()
    RGMercsLogger.log_info("ShadowKnight Combat Module UnLoaded.")
end

return Module
