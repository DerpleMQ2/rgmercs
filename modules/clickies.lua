-- Clicky Module
local mq                                = require('mq')
local Config                            = require('utils.config')
local Core                              = require('utils.core')
local Casting                           = require("utils.casting")
local Strings                           = require("utils.strings")
local Ui                                = require("utils.ui")
local Comms                             = require("utils.comms")
local Logger                            = require("utils.logger")
local Targeting                         = require("utils.targeting")
local Set                               = require("mq.Set")
local Icons                             = require('mq.ICONS')
local animItems                         = mq.FindTextureAnimation("A_DragItem")

local Module                            = { _version = '0.1a', _name = "Clickies", _author = 'Derple', }
Module.__index                          = Module
Module.FAQ                              = {}
Module.ClassFAQ                         = {}
Module.SaveRequested                    = nil
Module.ClickyRotationIndex              = 1

Module.TempSettings                     = {}
Module.TempSettings.ClickyState         = {}
Module.TempSettings.CombatClickiesTimer = 0

Module.DefaultConfig                    = {
    ['UseClickies']                            = {
        DisplayName = "Use Downtime Clickies",
        Category    = "Clickies",
        Index       = 0,
        Tooltip     = "Use items during Downtime.",
        Default     = false,
        ConfigType  = "Normal",
        FAQ         = "I have some clicky items that I want to use during downtime. How do I set them up?",
        Answer      = "You can set up to any number of clicky items in the Clickies section of the config.\n" ..
            "You can drag and drop them onto the ClickyItem# tags to add them.",
    },
    ['UseCombatClickies']                      = {
        DisplayName = "Use Combat Clickies",
        Category    = "Clickies",
        Index       = 2,
        Tooltip     = "Use detrimental clickies on your target during Combat.",
        Default     = false,
        ConfigType  = "Normal",
        FAQ         = "Why isn't my combat clicky being used?",
        Answer      = "Combat clickies only support detrimental items.\n" ..
            "Beneficial items should be used in Downtime or have a specific entry added to control proper use conditions.",
    },
    ['CombatClickiesDelay']                    = {
        DisplayName = "Clicky Check Delay",
        Category = "Clickies",
        Index = 3,
        Tooltip = "Seconds to wait between the check to use Combat Clickies.\n" ..
            "Please Note: Setting this value too low may interfere with other actions!",
        Default = 5,
        Min = 1,
        Max = 30,
        ConfigType = "Advanced",
        FAQ = "Why are my Combat Clickies being used so slowly?",
        Answer = "By default, Combat Clickies are only checked every 10 seconds to ensure we aren't interfering with other (more important) actions.\n" ..
            "You can adjust this with the C.Click Check Delay setting. ",
    },
    ['MaxClickiesPerFrame']                    = {
        DisplayName = "Max Clickies Per Frame",
        Category = "Clickies",
        Index = 4,
        Tooltip = "The max number of clickies to allow to successfully be used per frame, 0 for no limit.",
        Default = 0,
        Min = 0,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "My clickies are preventing other actions, what can I do?",
        Answer = "By default, there is no limit to the number of clickies that can be used per frame.\n" ..
            "If you are finding that your clickies are interfering with other actions, you can set a limit here.\n" ..
            "This will limit the number of clickies that can be used per frame, allowing other actions to occur.",
    },
    ['Clickies']                               = {
        DisplayName = "Item %d",
        Category    = "Clickies",
        Tooltip     = "Clicky Item to use",
        Type        = "Custom",
        Default     = {},
        ConfigType  = "Normal",
        Index       = 4,
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Category = "Custom",
        Tooltip = Module._name .. " Pop Out Into Window",
        Default = false,
        FAQ = "Can I pop out the " .. Module._name .. " module into its own window?",
        Answer =
        "You can set the click the popout button at the top of a tab or heading to pop it into its own window.\n Simply close the window and it will snap back to the main window.",
    },
}
Module.SettingCategories                = {}

-- each of these becomes a condition you can set per clickie
Module.LogicBlocks                      = {
    ['None'] = {
        cond = function(self, target) return true end,
        has_target = false,
        tooltip = "No condition, always true.",
        render_header_text = function(self, cond)
            return string.format("No Condition")
        end,
        args = {},
    },

    ['Server Type'] = {
        cond = function(self, target, onLive, onEmu, onLaz)
            Logger.log_super_verbose("\ayClicky: \a-yChecking Server Type is onLive(%s) onEmu(%s), onLaz(%s)", Strings.BoolToColorString(onLive),
                Strings.BoolToColorString(onEmu), Strings.BoolToColorString(onLaz))

            return (onLive and not Core.OnEMU()) or (onEmu and Core.OnEMU()) or (onLaz and Core.OnLaz())
        end,
        has_target = false,
        tooltip = "Only use if you are on one of these server types.",
        render_header_text = function(self, cond)
            local serverTypes = ""
            for k, v in pairs(cond.args) do
                if v == true then
                    serverTypes = serverTypes .. (serverTypes == "" and "" or " or ") .. self.LogicBlocks['Server Type'].args[k].name
                end
            end

            return string.format("Server type is %s", serverTypes == "" and "None" or serverTypes)
        end,
        args = {
            { name = "Live",            type = "boolean", default = true, },
            { name = "Emu",             type = "boolean", default = true, },
            { name = "Project Lazarus", type = "boolean", default = true, },
        },
    },

    ['In Zone'] = {
        cond = function(self, target, zoneName)
            Logger.log_super_verbose("\ayClicky: \a-yChecking if we are in Zone(s): \at%s\aw CurZone: \at%s\aw/\at%s", zoneName, mq.TLO.Zone.Name() or "None",
                mq.TLO.Zone.ShortName() or "None")
            local zoneChecks = Strings.split(zoneName or "", ",")
            for i, v in ipairs(zoneChecks) do
                v = v:gsub("^%s*(.-)%s*$", "%1") -- trim spaces
                if v == (mq.TLO.Zone.Name() or "") or v == (mq.TLO.Zone.ShortName() or "") then
                    return true
                end
            end

            return false
        end,
        has_target = false,
        tooltip = "Check if you are in any of these zones (full or short name, comma separated).",

        render_header_text = function(self, cond)
            local zoneList = ""
            local zoneChecks = Strings.split(cond.args[1] or "", ",")
            for _, v in pairs(zoneChecks) do
                zoneList = zoneList .. (zoneList == "" and "" or " or ") .. v
            end
            return string.format("In Zone(s) %s", zoneList == "" and "None" or zoneList)
        end,
        args = {
            { name = "Zone Name", type = "string", default = "ggh", },
        },
    },

    ['HP Theshold'] = {
        cond = function(self, target, aboveHP, belowHP)
            if not target or not target() then
                return false
            end

            local pctHPs = target.PctHPs() or 0

            Logger.log_super_verbose("\ayClicky: \ayClicky: \awHP Theshold condition check on \at%s\aw, aboveHP(\a-t%d\aw/%s) belowHP(\a-t%d\aw/%s) pctHPs(\a-t%d\aw)",
                target.CleanName() or "None", aboveHP, Strings.BoolToColorString((pctHPs >= aboveHP)), belowHP, Strings.BoolToColorString((pctHPs <= belowHP)),
                pctHPs)

            if not (pctHPs >= aboveHP) then
                return false
            end
            if not (pctHPs <= belowHP) then
                return false
            end

            return true
        end,
        has_target = true,
        tooltip = "Only use if [target] HP is above/below this percent.",
        render_header_text = function(self, cond)
            return string.format("HP of %s is between %d%% and %d%%", cond.target or "Self", cond.args[1] or 0, cond.args[2] or 100)
        end,
        args = {
            { name = ">= HP %", type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= HP %", type = "number", default = 100, min = 0, max = 100, },
        },
    },

    ['Mana Threshold'] = {
        cond = function(self, target, aboveMana, belowMana)
            local pctMana = target.PctMana() or 0
            Logger.log_super_verbose("\ayClicky: \ayClicky: \awMana Theshold condition check on \at%s\aw, aboveMana(\a-t%d\aw/%s) belowMana(\a-t%d\aw/%s) pctMana(\a-t%d\aw)",
                target.CleanName() or "None", aboveMana, Strings.BoolToColorString((pctMana >= aboveMana)), belowMana, Strings.BoolToColorString((pctMana <= belowMana)),
                pctMana)

            if not (pctMana >= aboveMana) then
                return false
            end
            if not (pctMana <= belowMana) then
                return false
            end
            return true
        end,
        has_target = false,
        tooltip = "Only use if your Mana is above/below this percent.",
        render_header_text = function(self, cond)
            return string.format("Your Mana is between %d%% and %d%%", cond.args[1] or 0, cond.args[2] or 100)
        end,
        args = {
            { name = ">= Mana %", type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= Mana %", type = "number", default = 100, min = 0, max = 100, },
        },
    },
}

Module.LogicBlockTypes                  = { 'None', 'Server Type', 'HP Theshold', 'Mana Threshold', 'In Zone', }
for k, v in pairs(Module.LogicBlockTypes) do
    Module.LogicBlocks[v].id = k
end

Module.CombatTargetTypes = { 'Self', 'Main Assist', 'Auto Target', }
Module.NonCombatTargetTypes = { 'Self', 'Main Assist', }
Module.CombatStates = { 'Downtime', 'Combat', 'Any', }

Module.CombatTargetTypeIDs = {}
for k, v in pairs(Module.CombatTargetTypes) do
    Module.CombatTargetTypeIDs[v] = k
end
Module.NonCombatTargetTypeIDs = {}
for k, v in pairs(Module.NonCombatTargetTypes) do
    Module.NonCombatTargetTypeIDs[v] = k
end
Module.CombatStateIDs = {}
for k, v in pairs(Module.CombatStates) do
    Module.CombatStateIDs[v] = k
end

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
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
    Logger.log_debug("Clickies Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()
    local settings = {}
    local firstSaveRequired = false

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Drag]: Unable to load clicky settings file(%s), creating a new one!",
            settings_pickle_path)
        firstSaveRequired = true
    else
        settings = config()
    end

    self.SettingCategories = Set.new({})
    for k, v in pairs(self.DefaultConfig or {}) do
        if v.Type ~= "Custom" then
            self.SettingCategories:add(v.Category)
        end
        self.FAQ[k] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', Settings_Used = k, }
    end

    local settingsChanged = false

    settings.Clickies = settings.Clickies or {}

    for _, clicky in ipairs(settings.DowntimeClickies or {}) do
        if type(clicky) == 'string' then
            -- convert old clickies
            table.insert(settings.Clickies,
                {
                    itemName = clicky,
                    target = 'Self',
                    combat_state = 'Downtime',
                    conditions = {},
                })
            settingsChanged = true
        end
    end

    for _, clicky in ipairs(settings.CombatClickies or {}) do
        if type(clicky) == 'string' then
            -- convert old clickies
            table.insert(settings.Clickies,
                {
                    itemName = clicky,
                    target = 'Self',
                    combat_state = 'Combat',
                    conditions = {},
                })
            settingsChanged = true
        end
    end

    settings.CombatClickies = nil
    settings.DowntimeClickies = nil

    if settingsChanged then
        self:SaveSettings(false)
    end

    Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.SettingCategories, firstSaveRequired)

    Logger.log_info("\awClicky Module: \atLoaded \ag%d\at Clickies", #settings.Clickies or 0)
end

function Module.New()
    local newModule = setmetatable({}, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Clicky Module Loaded.")
    self:LoadSettings()

    self.ModuleLoaded = true

    return { self = self, defaults = self.DefaultConfig, categories = self.SettingCategories, }
end

function Module:ShouldRender()
    return true
end

function Module:RenderClickyControls(clickies, clickyIdx, headerCursorPos, headerScreenPos, preRender)
    local startingPosVec = ImGui.GetCursorPosVec()
    local offset = 40

    self:RenderClickyHeaderIcon(clickies[clickyIdx], headerScreenPos)

    ImGui.SetCursorPos(ImGui.GetWindowWidth() - offset, headerCursorPos.y + 3)

    ImGui.PushID("##_small_btn_delete_clicky_" .. tostring(clickyIdx) .. (preRender and "_pre" or ""))

    if ImGui.SmallButton(Icons.FA_TRASH) then
        table.remove(clickies, clickyIdx)
        self:SaveSettings(false)
    end
    ImGui.PopID()

    ImGui.SetCursorPos(startingPosVec)
end

function Module:RenderConditionControls(clickyIdx, idx, conditionsTable, headerPos)
    local startingPosVec = ImGui.GetCursorPosVec()
    local offset = 110
    ImGui.SetCursorPos(ImGui.GetWindowWidth() - offset, headerPos.y)

    ImGui.PushID("##_small_btn_up_wp_" .. tostring(clickyIdx) .. "_" .. tostring(idx))
    if idx == 1 then
        ImGui.InvisibleButton(Icons.FA_CHEVRON_UP, ImVec2(22, 1))
    else
        if ImGui.SmallButton(Icons.FA_CHEVRON_UP) then
            conditionsTable[idx], conditionsTable[idx - 1] = conditionsTable[idx - 1], conditionsTable[idx]
            self:SaveSettings(false)
        end
    end
    ImGui.PopID()
    ImGui.SameLine()
    ImGui.PushID("##_small_btn_dn_cond_" .. tostring(clickyIdx) .. "_" .. tostring(idx))
    if idx == #conditionsTable then
        ImGui.InvisibleButton(Icons.FA_CHEVRON_DOWN, ImVec2(22, 1))
    else
        if ImGui.SmallButton(Icons.FA_CHEVRON_DOWN) then
            conditionsTable[idx], conditionsTable[idx + 1] = conditionsTable[idx + 1], conditionsTable[idx]
            self:SaveSettings(false)
        end
    end
    ImGui.PopID()
    ImGui.SameLine()
    ImGui.PushID("##_small_btn_delete_cond_" .. tostring(clickyIdx) .. "_" .. tostring(idx))
    if ImGui.SmallButton(Icons.FA_TRASH) then
        table.remove(conditionsTable, idx)
        self:SaveSettings(false)
    end
    ImGui.PopID()


    ImGui.SetCursorPos(startingPosVec)
end

function Module:RenderConditionTypesCombo(cond, condIdx)
    if ImGui.BeginTable("##clicky_cond_type_table_" .. condIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 50)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)
        ImGui.TableNextColumn()
        ImGui.Text("Type")
        ImGui.TableNextColumn()
        local selectedNum, changed = ImGui.Combo("##clicky_cond_type_" .. "_" .. condIdx, self.LogicBlocks[cond.type].id, self.LogicBlockTypes,
            #self.LogicBlockTypes)
        if changed then
            cond.type = self.LogicBlockTypes[selectedNum] or "None"
            cond.args = {}
            for argIdx, arg in ipairs(self:GetLogicBlockArgsByType(cond.type) or {}) do
                cond.args[argIdx] = arg.default
            end
            self:SaveSettings(false)
        end
        ImGui.EndTable()
    end
end

function Module:RenderConditionTargetCombo(cond, condIdx)
    if not self:GetLogicBlockByType(cond.type).has_target then
        return
    end
    if ImGui.BeginTable("##clicky_cond_target_table_" .. condIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 50)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)
        ImGui.TableNextColumn()
        ImGui.Text("Target")
        ImGui.TableNextColumn()
        local selectedNum, changed = ImGui.Combo("##clicky_cond_target_" .. "_" .. condIdx, tonumber(self.TargetTypeIDs[cond.target or "Self"]) or 1,
            self.TargetTypes,
            #self.TargetTypes)
        if changed then
            cond.target = self.TargetTypes[selectedNum] or "Self"
            self:SaveSettings(false)
        end
        ImGui.EndTable()
    end
end

function Module:RenderClickyTargetCombo(clicky, clickyIdx)
    if ImGui.BeginTable("##clicky_target_table_" .. clickyIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 100)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)
        ImGui.TableNextColumn()
        ImGui.Text("Target")
        ImGui.TableNextColumn()
        local targetTypeIDs = self.CombatTargetTypeIDs
        local targetTypes = self.CombatTargetTypes

        if clicky.combat_state == "Downtime" then
            targetTypeIDs = self.NonCombatTargetTypeIDs
            targetTypes = self.NonCombatTargetTypes
        end

        local selectedNum, changed = ImGui.Combo("##clicky_cond_target_" .. "_" .. clickyIdx, tonumber(targetTypeIDs[clicky.target or "Self"]) or 1,
            targetTypes,
            #targetTypes)
        if changed then
            clicky.target = targetTypes[selectedNum] or "Self"
            self:SaveSettings(false)
        end
        ImGui.EndTable()
    end
end

function Module:RenderClickyCombatStateCombo(clicky, clickyIdx)
    if ImGui.BeginTable("##clicky_combat_state_table_" .. clickyIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 100)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)
        ImGui.TableNextColumn()
        ImGui.Text("Combat State")
        ImGui.TableNextColumn()
        local selectedNum, changed = ImGui.Combo("##clicky_cond_combat_state_" .. "_" .. clickyIdx, tonumber(self.CombatStateIDs[clicky.combat_state or "Any"]) or 1,
            self.CombatStates,
            #self.CombatStates)
        if changed then
            clicky.combat_state = self.CombatStates[selectedNum] or "Any"
            self:SaveSettings(false)
        end
        ImGui.EndTable()
    end
end

function Module:RenderConditionArgs(cond, condIdx, clickyIdx)
    if ImGui.BeginTable("##clicky_cond_args_table_" .. condIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 80)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)
        for argIdx = 1, #cond.args do
            ImGui.TableNextColumn()
            ImGui.Text(self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).name or ("Arg " .. tostring(argIdx)))
            ImGui.TableNextColumn()
            if self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).type == "number" then
                local changed = false
                cond.args[argIdx], changed = Ui.RenderOptionNumber("##clicky_arg_" .. clickyIdx .. "_" .. condIdx .. "_" .. argIdx,
                    "", cond.args[argIdx], self.LogicBlocks[cond.type].args[argIdx].min, self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).max)

                if changed then
                    self:SaveSettings(false)
                end
            end
            if self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).type == "boolean" then
                local changed = false
                cond.args[argIdx], changed = Ui.RenderOptionToggle("##clicky_arg_" .. clickyIdx .. "_" .. condIdx .. "_" .. argIdx,
                    "",
                    cond.args[argIdx])

                if changed then
                    self:SaveSettings(false)
                end
            end
            if self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).type == "string" then
                local changed = false
                cond.args[argIdx], changed = ImGui.InputText("##clicky_arg_" .. clickyIdx .. "_" .. condIdx .. "_" .. argIdx,
                    cond.args[argIdx])

                if changed then
                    self:SaveSettings(false)
                end
            end
        end
        ImGui.EndTable()
    end
end

function Module:GetLogicBlockByType(type)
    return self.LogicBlocks[type]
end

function Module:GetLogicBlockArgsByType(type)
    return self.LogicBlocks[type].args or {}
end

function Module:GetLogicBlockArgByTypeAndIndex(type, idx)
    return self.LogicBlocks[type].args[idx] or "None"
end

function Module:GetLogicBlockArgCountByType(type)
    return #self.LogicBlocks[type].args or 0
end

function Module:RenderClickyHeaderIcon(clicky, headerPos)
    local offset = 30

    if not clicky then return end

    if clicky.iconId == nil then
        local item = mq.TLO.FindItem(clicky.itemName)
        clicky.iconId = item() and tonumber((item.Icon() or 500) - 500) or 0
    end

    local draw_list = ImGui.GetWindowDrawList()
    animItems:SetTextureCell(tonumber(clicky.iconId) or 0)
    draw_list:AddTextureAnimation(animItems, ImVec2(headerPos.x + offset, headerPos.y), ImVec2(20, 20))
end

function Module:RenderClickiesWithConditions(type, clickies)
    if ImGui.CollapsingHeader(type) then
        ImGui.Indent()
        if not mq.TLO.Cursor() then
            ImGui.BeginDisabled(true)
        end
        if ImGui.SmallButton(mq.TLO.Cursor.Name() and string.format("%s Add %s to %s", Icons.FA_PLUS, mq.TLO.Cursor.Name() or "N/A", type) or "Pickup an Item To Add") then
            if mq.TLO.Cursor() then
                table.insert(clickies, {
                    itemName = mq.TLO.Cursor.Name(),
                    target = 'Self',
                    combat_state = 'Any',
                    conditions = {},
                })
                self:SaveSettings(false)
            end
        end
        if not mq.TLO.Cursor() then
            ImGui.EndDisabled()
        end
        if #clickies > 0 then
            for clickyIdx, clicky in ipairs(clickies) do
                if clicky.itemName:len() > 0 then
                    local headerScreenPos = ImGui.GetCursorScreenPosVec()
                    local headerCursorPos = ImGui.GetCursorPosVec()
                    self:RenderClickyControls(clickies, clickyIdx, headerCursorPos, headerScreenPos, true)
                    if ImGui.CollapsingHeader("             " .. clicky.itemName) then
                        ImGui.Indent()
                        self:RenderClickyCombatStateCombo(clicky, clickyIdx)
                        self:RenderClickyTargetCombo(clicky, clickyIdx)
                        ImGui.SeparatorText("Usage Info")
                        self:RenderClickyData(clicky, clickyIdx)
                        ImGui.SeparatorText("Conditions");
                        ImGui.PushID("##clicky_conditions_btn_" .. clickyIdx)
                        if ImGui.SmallButton(Icons.FA_PLUS .. " Add Condition") then
                            table.insert(clicky.conditions, { type = 'None', args = {}, target = 'Self', })
                            self:SaveSettings(false)
                        end
                        ImGui.PopID()
                        for condIdx, cond in ipairs(clicky.conditions or {}) do
                            if self:GetLogicBlockByType(cond.type) then
                                local headerPos = ImGui.GetCursorPosVec()
                                if ImGui.TreeNode(self:GetLogicBlockByType(cond.type).render_header_text(self, cond) .. "###clicky_cond_tree_" .. clickyIdx .. "_" .. condIdx) then
                                    Ui.Tooltip(self:GetLogicBlockByType(cond.type).tooltip or "No Tooltip Available.")
                                    ImGui.NewLine()

                                    self:RenderConditionTypesCombo(cond, condIdx)
                                    self:RenderConditionTargetCombo(cond, condIdx)
                                    self:RenderConditionArgs(cond, condIdx, clickyIdx)
                                    ImGui.TreePop()
                                else
                                    Ui.Tooltip(self:GetLogicBlockByType(cond.type).tooltip or "No Tooltip Available.")
                                    ImGui.NewLine()
                                end

                                self:RenderConditionControls(clickyIdx, condIdx, clicky.conditions, headerPos)
                            end
                        end
                        ImGui.Unindent()
                    end
                    self:RenderClickyControls(clickies, clickyIdx, headerCursorPos, headerScreenPos, false)
                end
            end
        end

        ImGui.Unindent()
        ImGui.Separator()
    end
end

function Module:RenderClickies(type, clickies)
    if ImGui.CollapsingHeader(type) then
        ImGui.Indent()

        if #clickies > 0 then
            if ImGui.BeginTable("##clickies_table_" .. type, 3, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
                ImGui.TableSetupColumn('Last Used', (ImGuiTableColumnFlags.WidthFixed), 100.0)
                ImGui.TableSetupColumn('Item', (ImGuiTableColumnFlags.WidthFixed), 150.0)
                ImGui.TableSetupColumn('Effect', (ImGuiTableColumnFlags.WidthStretch), 200.0)
                ImGui.PopStyleColor()
                ImGui.TableHeadersRow()

                for _, clicky in pairs(clickies) do
                    if clicky.itemName:len() > 0 then
                        local lastUsed = self.TempSettings.ClickyState[clicky.itemName] and (self.TempSettings.ClickyState[clicky.itemName].lastUsed or 0) or 0
                        local item = self.TempSettings.ClickyState[clicky.itemName] and
                            (self.TempSettings.ClickyState[clicky.itemName].item and self.TempSettings.ClickyState[clicky.itemName].item.Clicky.Spell.RankName.Name() or "None")
                            or "None"
                        ImGui.TableNextColumn()
                        ImGui.Text(lastUsed > 0 and Strings.FormatTime((os.clock() - lastUsed)) or "Never")
                        ImGui.TableNextColumn()
                        ImGui.Text(clicky.itemName)
                        ImGui.TableNextColumn()
                        ImGui.Text(item)
                    end
                end

                ImGui.EndTable()
            end
        end
        ImGui.Unindent()
        ImGui.Separator()
    end
end

function Module:RenderClickyData(clicky, clickyIdx)
    if ImGui.BeginTable("##clickies_table_" .. clicky.itemName .. tostring(clickyIdx), 3, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Last Used', (ImGuiTableColumnFlags.WidthFixed), 100.0)
        ImGui.TableSetupColumn('Item', (ImGuiTableColumnFlags.WidthFixed), 150.0)
        ImGui.TableSetupColumn('Effect', (ImGuiTableColumnFlags.WidthStretch), 200.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        if clicky.itemName:len() > 0 then
            local lastUsed = self.TempSettings.ClickyState[clicky.itemName] and (self.TempSettings.ClickyState[clicky.itemName].lastUsed or 0) or 0
            local item = self.TempSettings.ClickyState[clicky.itemName] and
                (self.TempSettings.ClickyState[clicky.itemName].item and self.TempSettings.ClickyState[clicky.itemName].item.Clicky.Spell.RankName.Name() or "None")
                or "None"
            ImGui.TableNextColumn()
            ImGui.Text(lastUsed > 0 and Strings.FormatTime((os.clock() - lastUsed)) or "Never")
            ImGui.TableNextColumn()
            ImGui.Text(clicky.itemName)
            ImGui.TableNextColumn()
            ImGui.Text(item)
        end

        ImGui.EndTable()
    end
    ImGui.Separator()
end

function Module:Render()
    Ui.RenderPopSetting(self._name)

    self:RenderClickiesWithConditions("Clickies", Config:GetSetting('Clickies'))

    if ImGui.CollapsingHeader("Config Options") then
        _, _ = Ui.RenderModuleSettings(self._name, self.DefaultConfig, self.SettingCategories)
    end
end

function Module:Pop()
    Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
    if combat_state == 'Combat' then
        -- TODO: Should these just be rmemoved now?
        -- I plan on breaking clickies out further to allow things like horn, other healing clickies to be used, that the user will select... this is "interim" implementation.
        if Core.OnLaz() and mq.TLO.Me.PctHPs() <= (Config:HaveSetting('EmergencyStart') and Config:GetSetting('EmergencyStart') or 45) then
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
    end

    local maxClickiesPerFrame = Config:GetSetting('MaxClickiesPerFrame') or 0
    local clickiesUsedThisFrame = 0
    local startingClickyIdx = maxClickiesPerFrame > 0 and self.ClickyRotationIndex or 1
    local clickies = Config:GetSetting('Clickies') or {}
    local numClickies = #clickies
    for clickyIdx = startingClickyIdx, numClickies do
        local clicky = clickies[clickyIdx]
        if clicky.itemName:len() > 0 then
            self.ClickyRotationIndex = (clickyIdx % numClickies) + 1
            Logger.log_super_verbose("\ayClicky: \awChecking clicky entry: \ay%s\aw[\at%d\aw]", clicky.itemName, clickyIdx)

            if clicky.combat_state == "Any" or clicky.combat_state == combat_state then
                local target = mq.TLO.Me
                local allConditionsMet = true
                for _, cond in ipairs(clicky.conditions or {}) do
                    if self:GetLogicBlockByType(cond.type).has_target then
                        if cond.target == "Main Assist" then
                            ---@diagnostic disable-next-line: cast-local-type
                            target = Core.GetMainAssistSpawn()
                        elseif cond.target == "Auto Target" then
                            ---@diagnostic disable-next-line: cast-local-type
                            target = Targeting.GetAutoTarget()
                        end
                    end
                    Logger.log_super_verbose("\ayClicky: \awTesting Condition: \at%s\aw on target: \at%s", cond.type, target and (target.CleanName() or "None") or "None")

                    if not Core.SafeCallFunc("Test clicky Condition", self:GetLogicBlockByType(cond.type).cond, self, target, unpack(cond.args or {})) then
                        Logger.log_super_verbose("\ayClicky: \aw\t|->\aw \arFailed!")
                        allConditionsMet = false
                        break
                    else
                        Logger.log_super_verbose("\ayClicky: \aw\t|->\aw \agSuccess!")
                    end
                end

                if allConditionsMet then
                    self.TempSettings.ClickyState[clicky.itemName] = self.TempSettings.ClickyState[clicky.itemName] or {}

                    local item = mq.TLO.FindItem(clicky.itemName)
                    Logger.log_verbose("\ayClicky: \awLooking for clicky item: \am%s \awfound: %s", clicky.itemName, Strings.BoolToColorString(item() ~= nil))

                    if item then
                        target = mq.TLO.Me
                        local buffCheckPassed = true
                        if clicky.target == "Self" then
                            target = mq.TLO.Me
                            buffCheckPassed = Casting.SelfBuffItemCheck(clicky.itemName)
                        elseif clicky.target == "Main Assist" then
                            ---@diagnostic disable-next-line: cast-local-type
                            target = Core.GetMainAssistSpawn()
                            buffCheckPassed = Casting.PeerBuffCheck(item.Clicky.Spell.ID(), target, false)
                        elseif clicky.target == "Auto Target" then
                            ---@diagnostic disable-next-line: cast-local-type
                            target = Targeting.GetAutoTarget()
                            buffCheckPassed = Casting.DetItemCheck(clicky.itemName)
                        end

                        self.TempSettings.ClickyState[clicky.itemName].item = item
                        if Casting.ItemReady(item()) then
                            if buffCheckPassed then
                                Logger.log_verbose("\ayClicky: \awItem \am%s\aw Clicky Spell: \at%s\ag!", item.Name(), item.Clicky.Spell.RankName.Name())
                                Casting.UseItem(item.Name(), target.ID())
                                clickiesUsedThisFrame = clickiesUsedThisFrame + 1
                                if maxClickiesPerFrame > 0 and clickiesUsedThisFrame >= maxClickiesPerFrame then
                                    Logger.log_debug("\ayClicky: \a-tMax Clickies Per Frame of \am%d\a-t reached, stopping for this frame and picking up with %d next frame.",
                                        maxClickiesPerFrame, self.ClickyRotationIndex)
                                    break
                                end
                                self.TempSettings.ClickyState[clicky.itemName].lastUsed = os.clock()
                                break --ensure we stop after we process a single clicky to allow rotations to continue
                            else
                                Logger.log_verbose("\ayClicky: \awItem \am%s\aw Clicky Spell: \at%s\ar already active or would not stack!", item.Name(),
                                    item.Clicky.Spell.RankName.Name())
                            end
                        else
                            Logger.log_verbose("\ayClicky: \awItem \am%s\aw Clicky: \at%s\ar Clicky timer not ready!", item.Name(), item.Clicky.Spell.RankName.Name())
                        end
                    end
                end
            else
                Logger.log_super_verbose("\ayClicky: \arSkipping clicky entry: \am%s\ar due to Combat State mismatch (Clicky State: \at%s \arCurrent State: \at%s\ar)",
                    clicky.itemName,
                    clicky.combat_state, combat_state)
            end
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
    local result = string.format("\awLoaded \ag%d\at Downtime Clickies and \ag%d\at Combat Clickies\n\n", #Config:GetSetting('DowntimeClickies'),
        #Config:GetSetting('CombatClickies'))
    result = result .. "-=-=-=-=-=\n"

    for i, v in ipairs(Config:GetSetting('Clickies')) do
        result = result .. string.format("\atClicky %d: \ay%s\at\n", i, v.itemName)
    end

    return result
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = {}, }
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
    local params = ...
    local handled = false
    -- /rglua cmd handler
    return handled
end

function Module:Shutdown()
    Logger.log_debug("clicky Module Unloaded.")
end

return Module
