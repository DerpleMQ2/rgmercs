local mq            = require('mq')
local Config        = require('utils.config')
local Modules       = require("utils.modules")
local Logger        = require("utils.logger")
local Core          = require("utils.core")
local Targeting     = require("utils.targeting")
local Icons         = require('mq.ICONS')

local animSpellGems = mq.FindTextureAnimation('A_SpellGems')
local ICON_SIZE     = 20

local Ui            = { _version = '1.0', _name = "Ui", _author = 'Derple', }

Ui.__index          = Ui
Ui.ConfigFilter     = ""
Ui.ShowDownNamed    = false


--- Renders the OA (Outside Assist) list.
--- This function is responsible for displaying the list of Outside Assist names
--- It does not take any parameters and does not return any values.
function Ui.RenderOAList()
    if mq.TLO.Target.ID() > 0 then
        ImGui.PushID("##_small_btn_create_oa")
        if ImGui.SmallButton("Add Target as OA") then
            Config:AddOA(mq.TLO.Target.DisplayName())
        end
        ImGui.PopID()
    end
    if ImGui.BeginTable("OAList Names", 5, ImGuiTableFlags.None + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)

        ImGui.TableSetupColumn('ID', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 140.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 40.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthStretch), 150.0)
        ImGui.TableSetupColumn('Controls', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, name in ipairs(Config:GetSetting('OutsideAssistList') or {}) do
            local spawn = mq.TLO.Spawn(string.format("PC =%s", name))
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            ImGui.TableNextColumn()
            local _, clicked = ImGui.Selectable(name, false)
            if clicked then
                if spawn and spawn() then
                    mq.TLO.Spawn(spawn.ID()).DoTarget()
                end
            end
            ImGui.TableNextColumn()
            if spawn() and spawn.ID() > 0 then
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 1.0)
                ImGui.Text(tostring(math.ceil(spawn.Distance())))
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                Ui.NavEnabledLoc(spawn.LocYXZ() or "0,0,0")
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                ImGui.Text("0")
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                ImGui.Text("0")
            end
            ImGui.TableNextColumn()
            ImGui.PushID("##_small_btn_delete_oa_" .. tostring(idx))
            if ImGui.SmallButton(Icons.FA_TRASH) then
                Config:DeleteOA(idx)
            end
            ImGui.PopID()
            ImGui.SameLine()
            ImGui.PushID("##_small_btn_up_oa_" .. tostring(idx))
            if idx == 1 then
                ImGui.InvisibleButton(Icons.FA_CHEVRON_UP, ImVec2(22, 1))
            else
                if ImGui.SmallButton(Icons.FA_CHEVRON_UP) then
                    Config:MoveOAUp(idx)
                end
            end
            ImGui.PopID()
            ImGui.SameLine()
            ImGui.PushID("##_small_btn_dn_oa_" .. tostring(idx))
            if idx == #Config:GetSetting('OutsideAssistList') then
                ImGui.InvisibleButton(Icons.FA_CHEVRON_DOWN, ImVec2(22, 1))
            else
                if ImGui.SmallButton(Icons.FA_CHEVRON_DOWN) then
                    Config:MoveOADown(idx)
                end
            end
            ImGui.PopID()
        end

        ImGui.EndTable()
    end
end

function Ui.GetClassConfigIDFromName(name)
    for idx, curName in ipairs(Config.Globals.ClassConfigDirs or {}) do
        if curName == name then return idx end
    end

    return 1
end

function Ui.RenderConfigSelector()
    if Config.Globals.ClassConfigDirs ~= nil then
        ImGui.Text("Config Type:")
        Ui.Tooltip(
            "Select your current server/environment.\nLive: Official EQ Servers (Live, Test, TLP).\nBeta: Configs in testing (see forums).\nExperimental: Configs restricted to specific modes or levels (see forums, often preferred over the base if available!).\nProject Lazurus: Laz-specific (Live may be better suited for other emu servers).\nCustom: Copies of the above configs that you have edited yourself.")
        ImGui.SameLine()
        ImGui.SetNextItemWidth(200)
        local newConfigDir, changed = ImGui.Combo("##config_type", Ui.GetClassConfigIDFromName(Config:GetSetting('ClassConfigDir')), Config.Globals.ClassConfigDirs,
            #Config.Globals.ClassConfigDirs)
        if changed then
            Config:SetSetting('ClassConfigDir', Config.Globals.ClassConfigDirs[newConfigDir])
            Config:SaveSettings()
            Config:LoadSettings()
            Modules:ExecAll("LoadSettings")
        end

        ImGui.SameLine()
        if ImGui.SmallButton(Icons.FA_REFRESH) then
            Core.ScanConfigDirs()
        end
        Ui.Tooltip("Refreshes the class config directory list.")

        ImGui.SameLine()
        if ImGui.SmallButton('Create Custom Config') then
            Modules:ExecModule("Class", "WriteCustomConfig")
        end
        Ui.Tooltip("Places a copy of the currently loaded class config in the MQ config directory for customization.\nWill back up the existing custom configuration.")
        ImGui.NewLine()
    end
end

function Ui.RenderForceTargetList(showPopout)
    if showPopout then
        if ImGui.SmallButton(Icons.MD_OPEN_IN_NEW) then
            Config:SetSetting('PopOutForceTarget', true)
        end
        Ui.Tooltip("Pop the Force Target list out into its own window.")
        ImGui.NewLine()
    end

    if ImGui.Button("Clear Forced Target", ImGui.GetWindowWidth() * .3, 18) then
        Config.Globals.ForceTargetID = 0
    end

    if ImGui.BeginTable("XTargs", 5, ImGuiTableFlags.None + ImGuiTableFlags.Borders + ImGuiTableFlags.Resizable) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('FT', (ImGuiTableColumnFlags.WidthFixed), 16.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), ImGui.GetWindowWidth() - 300)
        ImGui.TableSetupColumn('HP %', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.TableSetupColumn('Aggro %', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        local xtCount = mq.TLO.Me.XTarget() or 0

        for i = 1, xtCount do
            local xtarg = mq.TLO.Me.XTarget(i)
            if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater") or Targeting.ForceCombat) then
                ImGui.TableNextColumn()
                if Config.Globals.ForceTargetID > 0 and Config.Globals.ForceTargetID == xtarg.ID() then
                    ImGui.PushStyleColor(ImGuiCol.Text, IM_COL32(52, 200, math.floor(os.clock() % 2) == 1 and 52 or 200, 255))
                    ImGui.Text(Icons.MD_STAR)
                    ImGui.PopStyleColor(1)
                else
                    ImGui.Text("")
                end
                ImGui.TableNextColumn()
                ImGui.PushStyleColor(ImGuiCol.Text, Ui.GetConColorBySpawn(xtarg))
                ImGui.PushID(string.format("##select_forcetarget_%d", i))
                local _, clicked = ImGui.Selectable(xtarg.CleanName() or "None", false)
                if clicked then
                    Config.Globals.ForceTargetID = xtarg.ID()
                    Logger.log_debug("Forcing Target to: %s %d", xtarg.CleanName(), xtarg.ID())
                end
                ImGui.PopID()
                ImGui.PopStyleColor(1)
                ImGui.TableNextColumn()
                ImGui.Text(tostring(math.ceil(xtarg.PctHPs() or 0)))
                ImGui.TableNextColumn()
                ImGui.Text(tostring(math.ceil(xtarg.PctAggro() or 0)))
                ImGui.TableNextColumn()
                ImGui.Text(tostring(math.ceil(xtarg.Distance() or 0)))
            end
        end

        ImGui.EndTable()
    end
end

--- Renders a table of the named creatures of the current zone.
---
--- This function retrieves and displays the name of the current zone in the game.
---
function Ui.RenderZoneNamed()
    Ui.ShowDownNamed, _ = Ui.RenderOptionToggle("ShowDown", "Show Downed Named", Ui.ShowDownNamed)

    if ImGui.BeginTable("Zone Named", 4, ImGuiTableFlags.None + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 250.0)
        ImGui.TableSetupColumn('Up', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthFixed), 160.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        local namedList = Modules:ExecModule("Named", "GetNamedList")
        for _, named in ipairs(namedList) do
            if Ui.ShowDownNamed or (named.Spawn() and named.Spawn.ID() > 0) then
                ImGui.TableNextColumn()
                local _, clicked = ImGui.Selectable(named.Name, false)
                if clicked then
                    if named.Spawn() and named.Spawn.ID() then
                        mq.TLO.Spawn(named.Spawn.ID()).DoTarget()
                    end
                end
                ImGui.TableNextColumn()
                if named.Spawn() and named.Spawn.PctHPs() > 0 then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 1.0)
                    ImGui.Text(Icons.FA_SMILE_O)
                    ImGui.PopStyleColor()
                    ImGui.TableNextColumn()
                    ImGui.Text(tostring(math.ceil(named.Distance)))
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                    ImGui.Text(Icons.FA_FROWN_O)
                    ImGui.PopStyleColor()
                    ImGui.TableNextColumn()
                    ImGui.Text("0")
                end
                ImGui.TableNextColumn()
                Ui.NavEnabledLoc(named.Spawn.LocYXZ() or "0,0,0")
            end
        end

        ImGui.EndTable()
    end
end

--- Draws an inspectable spell icon.
---
--- @param iconID number The ID of the icon to be drawn.
--- @param spell MQSpell The spell data to be used for the icon.
function Ui.DrawInspectableSpellIcon(iconID, spell)
    local cursor_x, cursor_y = ImGui.GetCursorPos()

    animSpellGems:SetTextureCell(iconID or 0)

    ImGui.DrawTextureAnimation(animSpellGems, ICON_SIZE, ICON_SIZE)

    ImGui.SetCursorPos(cursor_x, cursor_y)

    ImGui.PushID(tostring(iconID) .. spell.Name() .. "_invis_btn")
    ImGui.InvisibleButton(spell.Name(), ImVec2(ICON_SIZE, ICON_SIZE),
        bit32.bor(ImGuiButtonFlags.MouseButtonLeft))
    if ImGui.IsItemHovered() and ImGui.IsMouseReleased(ImGuiMouseButton.Left) then
        spell.Inspect()
    end
    ImGui.PopID()
end

--- Renders the loadout table.
---
--- This function takes a loadout table and renders it in a specific format.
---
--- @param loadoutTable table The table containing loadout information to be rendered.
function Ui.RenderLoadoutTable(loadoutTable)
    if ImGui.BeginTable("Spells", 5, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Icon', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Gem', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Var Name', (ImGuiTableColumnFlags.WidthFixed), 150.0)
        ImGui.TableSetupColumn('Level', ImGuiTableColumnFlags.None)
        ImGui.TableSetupColumn('Rank Name', ImGuiTableColumnFlags.None)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for gem, loadoutData in pairs(loadoutTable) do
            ImGui.TableNextColumn()
            Ui.DrawInspectableSpellIcon(loadoutData.spell.SpellIcon(), loadoutData.spell)
            ImGui.TableNextColumn()
            ImGui.Text(tostring(gem))
            ImGui.TableNextColumn()
            ImGui.Text(loadoutData.selectedSpellData.name or "")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(loadoutData.spell.Level()))
            ImGui.TableNextColumn()
            local _, clicked = ImGui.Selectable(loadoutData.spell.RankName())
            if clicked then
                loadoutData.spell.Inspect()
            end
        end

        ImGui.EndTable()
    end
end

--- Renders the rotation table key.
--- This function is responsible for displaying the key for the rotation table.
--- It does not take any parameters and does not return any value.
function Ui.RenderRotationTableKey()
    if ImGui.BeginTable("Rotation_keys", 2, ImGuiTableFlags.Borders) then
        ImGui.TableNextColumn()
        ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
        ImGui.Text(Icons.FA_SMILE_O .. ": Active")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
        ImGui.Text(Icons.MD_CHECK .. ": Will Cast (Conditions Met)")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
        ImGui.Text(Icons.FA_EXCLAMATION .. ": Cannot Cast")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 1.0, 1.0)
        ImGui.Text(Icons.MD_CHECK .. ": Will Cast (No Conditions)")

        ImGui.PopStyleColor()
        ImGui.EndTable()
    end
end

--- Renders a rotation table for a given name.
---
--- @param name string: The name associated with the rotation table.
--- @param rotationTable table: The table containing rotation data.
--- @param resolvedActionMap table: A map of resolved actions.
--- @param rotationState number|nil: The current state of the rotation.
--- @param showFailed boolean: Flag to indicate whether to show failed actions.
---
--- @return boolean returns showFailed input
function Ui.RenderRotationTable(name, rotationTable, resolvedActionMap, rotationState, showFailed)
    if ImGui.BeginTable("Rotation_" .. name, rotationState > 0 and 5 or 4, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('ID', ImGuiTableColumnFlags.WidthFixed, 20.0)
        if rotationState > 0 then
            ImGui.TableSetupColumn('Cur', ImGuiTableColumnFlags.WidthFixed, 20.0)
        end
        ImGui.TableSetupColumn('Condition Met', ImGuiTableColumnFlags.WidthFixed, 20.0)
        ImGui.TableSetupColumn('Action', ImGuiTableColumnFlags.WidthFixed, 250.0)
        ImGui.TableSetupColumn('Resolved Action', ImGuiTableColumnFlags.WidthStretch, 250.0)

        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, entry in ipairs(rotationTable or {}) do
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            if rotationState > 0 then
                ImGui.TableNextColumn()
                ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                if idx == rotationState then
                    ImGui.Text(Icons.FA_DOT_CIRCLE_O)
                else
                    ImGui.Text("")
                end
                ImGui.PopStyleColor()
            end
            ImGui.TableNextColumn()
            if entry.cond then
                local pass, active = false, false

                if entry.lastRun then
                    pass, active = entry.lastRun.pass, entry.lastRun.active
                end

                if active == true then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                    ImGui.Text(Icons.FA_SMILE_O)
                elseif pass == true then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                    ImGui.Text(Icons.MD_CHECK)
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                    ImGui.Text(Icons.FA_EXCLAMATION)
                end
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 1.0, 1.0)
                ImGui.Text(Icons.MD_CHECK)
            end
            ImGui.PopStyleColor()
            if entry.tooltip then
                Ui.Tooltip(entry.tooltip)
            end
            ImGui.TableNextColumn()
            local mappedAction = resolvedActionMap[entry.name]
            if mappedAction then
                if type(mappedAction) == "string" then
                    ImGui.Text(entry.name)
                    ImGui.TableNextColumn()
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.2, 0.6, 1.0, 1.0)
                    ImGui.Text(mappedAction)
                    ImGui.PopStyleColor()
                else
                    if entry.type:lower() == "spell" then
                        ImGui.Text(entry.name)
                        ImGui.TableNextColumn()
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.6, 0.2, 1.0, 1.0)
                        local _, clicked = ImGui.Selectable(mappedAction.RankName())
                        if clicked then
                            mappedAction.Inspect()
                        end
                        ImGui.PopStyleColor()
                    else
                        ImGui.Text(entry.name)
                        ImGui.TableNextColumn()
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.6, 0.2, 1.0, 1.0)
                        ImGui.Text(mappedAction.Name() or "None")
                        ImGui.PopStyleColor()
                    end
                end
            else
                ImGui.Text(entry.name)
                ImGui.TableNextColumn()
                if entry.type:lower() == "customfunc" then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.9, 0.9, .05, 1.0)
                    ImGui.Text("<<Custom Func>>")
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "spell" then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.9, 0.05, .05, 0.9)
                    ImGui.Text("<Missing Spell>")
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "song" then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.9, 0.05, .05, 0.9)
                    ImGui.Text("<Missing Spell>")
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "ability" then
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.65, .65, 1.0)
                    ImGui.Text(entry.name)
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "aa" then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.65, 0.65, 1.0, 1.0)
                    ImGui.Text(entry.name)
                    ImGui.PopStyleColor()
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.8, .8, 1.0)
                    ImGui.Text(entry.name)
                    ImGui.PopStyleColor()
                end
            end
        end

        ImGui.EndTable()
    end

    return showFailed
end

--- Renders a toggle option in the UI.
--- @param id string: The unique identifier for the toggle option.
--- @param text string: The display text for the toggle option.
--- @param on boolean: The current state of the toggle option (true for on, false for off).
--- @return boolean: state
--- @return boolean: changed
function Ui.RenderOptionToggle(id, text, on)
    local toggled = false
    local state   = on
    ImGui.PushID(id .. "_togg_btn")

    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1.0, 1.0, 1.0, 0)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 1.0, 1.0, 0)
    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 1.0, 1.0, 0)

    if on then
        ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 0.9)
        if ImGui.Button(Icons.FA_TOGGLE_ON) then
            toggled = true
            state   = false
        end
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 0.8)
        if ImGui.Button(Icons.FA_TOGGLE_OFF) then
            toggled = true
            state   = true
        end
    end
    ImGui.PopStyleColor(4)
    ImGui.PopID()
    ImGui.SameLine()
    ImGui.Text(text)

    return state, toggled
end

--- Renders a progress bar.
--- @param pct number The percentage to fill the progress bar (0-100).
--- @param width number The width of the progress bar.
--- @param height number The height of the progress bar.
function Ui.RenderProgressBar(pct, width, height)
    local style = ImGui.GetStyle()
    local start_x, start_y = ImGui.GetCursorPos()
    local text = string.format("%d%%", pct * 100)
    local label_x, _ = ImGui.CalcTextSize(text)
    ImGui.ProgressBar(pct, width, height, "")
    local end_x, end_y = ImGui.GetCursorPos()
    ImGui.SetCursorPos(start_x + ((ImGui.GetWindowWidth() / 2) - (style.ItemSpacing.x + math.floor(label_x / 2))),
        start_y + style.ItemSpacing.y)
    ImGui.Text(text)
    ImGui.SetCursorPos(end_x, end_y)
end

--- Renders a numerical option with a specified range and step.
--- @param id string: The identifier for the option.
--- @param text string: The display text for the option.
--- @param cur number: The current value of the option.
--- @param min number: The minimum value of the option.
--- @param max number: The maximum value of the option.
--- @param step number?: The step value for incrementing/decrementing the option.
--- @return number   # input
--- @return boolean  # changed
function Ui.RenderOptionNumber(id, text, cur, min, max, step)
    ImGui.PushID("##num_spin_" .. id)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.5, 0.5, 0.5, 1.0)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.5, 0.5, 0.5, 0.8)
    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 1.0, 1.0, 0.2)
    ImGui.PushStyleColor(ImGuiCol.FrameBg, 1.0, 1.0, 1.0, 0)
    local input, changed = ImGui.InputInt(text, cur, step, 1, ImGuiInputTextFlags.None)
    ImGui.PopStyleColor(4)
    ImGui.PopID()

    input = tonumber(input) or 0
    if input > max then input = max end
    if input < min then input = min end

    changed = cur ~= input
    return input, changed
end

--- Renders a settings table.
---
--- @param settings table The settings table to render.
--- @param settingNames table A table containing the names of the settings.
--- @param defaults table A table containing the default values for the settings.
--- @param category string The category of the settings.
--- @return table   # settings
--- @return boolean # any_pressed
--- @return boolean # requires_new_loadout
function Ui.RenderSettingsTable(settings, settingNames, defaults, category)
    local any_pressed           = false
    local new_loadout           = false
    --- @type boolean|nil
    local pressed               = false
    local renderWidth           = 300
    local windowWidth           = ImGui.GetWindowWidth()
    local numCols               = math.max(1, math.floor(windowWidth / renderWidth))

    local settingToDrawIndicies = {}

    for idx, k in ipairs(settingNames) do
        if Config:GetSetting('ShowAdvancedOpts') or (defaults[k].ConfigType == nil or defaults[k].ConfigType:lower() == "normal") then
            if defaults[k].Category == category and (defaults[k].Type or "none"):lower() ~= "custom" then
                table.insert(settingToDrawIndicies, idx)
            end
        end
    end

    local settingsCount = #settingToDrawIndicies

    local itemsPerRow = math.ceil(settingsCount / numCols)

    if ImGui.BeginTable("Options_" .. (category), 2 * numCols, ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        for _ = 1, numCols do
            ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthFixed), 150.0)
            ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
        end
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()
        ImGui.TableNextRow()

        if #settingToDrawIndicies > 0 then
            for row = 1, itemsPerRow do
                for col = 1, numCols do
                    ImGui.TableNextColumn()
                    local itemIndex = row + ((col - 1) * itemsPerRow)
                    if itemIndex <= #settingToDrawIndicies then
                        local k = settingNames[settingToDrawIndicies[itemIndex]]
                        ImGui.Text(defaults[k].DisplayName or "None")
                        --ImGui.Text(string.format("%s %d %d + %d", defaults[k].DisplayName or "None", itemIndex, row, ImGui.TableGetColumnIndex() + 1))
                        Ui.Tooltip(string.format("%s\n\n[Variable: %s]\n[Default: %s]",
                            type(defaults[k].Tooltip) == 'function' and defaults[k].Tooltip() or defaults[k].Tooltip,
                            k,
                            tostring(defaults[k].Default)))
                        ImGui.TableNextColumn()

                        if defaults[k].Type == "Combo" then
                            -- build a combo box.
                            ImGui.PushID("##combo_setting_" .. k)
                            settings[k], pressed = ImGui.Combo("", settings[k], defaults[k].ComboOptions)
                            ImGui.PopID()
                            new_loadout = new_loadout or
                                ((pressed or false) and (defaults[k].RequiresLoadoutChange or false))
                            any_pressed = any_pressed or (pressed or false)
                        elseif defaults[k].Type == "ClickyItem" then
                            -- make a drag and drop target
                            ImGui.PushFont(ImGui.ConsoleFont)
                            local displayCharCount = 11
                            local nameLen = settings[k]:len()
                            local maxStart = (nameLen - displayCharCount) + 1
                            local startDisp = (os.clock() % maxStart) + 1

                            ImGui.PushID(k .. "__btn")
                            if ImGui.SmallButton(nameLen > 0 and settings[k]:sub(startDisp, (startDisp + displayCharCount - 1)) or "[Drop Here]") then
                                if mq.TLO.Cursor() then
                                    settings[k] = mq.TLO.Cursor.Name()
                                    pressed = true
                                end
                            end
                            ImGui.PopID()

                            ImGui.PopFont()
                            if nameLen > 0 then
                                Ui.Tooltip(settings[k])
                            end

                            ImGui.SameLine()
                            ImGui.PushID(k .. "__clear_btn")
                            if ImGui.SmallButton(Icons.MD_CLEAR) then
                                settings[k] = ""
                                pressed = true
                            end
                            ImGui.PopID()
                            Ui.Tooltip(string.format("Drop a new item here to replace\n%s", settings[k]))
                            new_loadout = new_loadout or
                                ((pressed or false) and (defaults[k].RequiresLoadoutChange or false))
                            any_pressed = any_pressed or (pressed or false)
                        elseif defaults[k].Type ~= "Custom" then
                            if type(settings[k]) == 'boolean' then
                                settings[k], pressed = Ui.RenderOptionToggle(k, "", settings[k])
                                new_loadout = new_loadout or (pressed and (defaults[k].RequiresLoadoutChange or false))
                                any_pressed = any_pressed or pressed
                            elseif type(settings[k]) == 'number' then
                                settings[k], pressed = Ui.RenderOptionNumber(k, "", settings[k], defaults[k].Min,
                                    defaults[k].Max, defaults[k].Step or 1)
                                new_loadout = new_loadout or (pressed and (defaults[k].RequiresLoadoutChange or false))
                                any_pressed = any_pressed or pressed
                            elseif type(settings[k]) == 'string' then -- display only
                                settings[k], pressed = ImGui.InputText("##" .. k, settings[k])
                                any_pressed = any_pressed or pressed
                                Ui.Tooltip(settings[k])
                            end
                        end
                    end
                end
                ImGui.TableNextRow()
            end
        end
        ImGui.EndTable()
    end

    return settings, any_pressed, new_loadout
end

--- Renders the settings UI for the Ui module.
---
--- @param settings table The current settings to be rendered.
--- @param defaults table The default settings to be used as a reference.
--- @param categories table The categories of settings to be displayed.
--- @param hideControls? boolean Whether to hide certain controls in the UI.
--- @param showMainOptions? boolean Whether to show the main options in the UI.
---
--- @return table: settings updated
--- @return boolean: any_pressed was anythign pressed?
--- @return boolean: requires_new_loadout do we require a new loadout?
function Ui.RenderSettings(settings, defaults, categories, hideControls, showMainOptions)
    ImGui.Indent()
    local any_pressed = false
    local new_loadout = false

    local settingNames = {}
    for k, _ in pairs(defaults) do
        table.insert(settingNames, k)
    end

    if not hideControls then
        local changed = false

        if showMainOptions then
            Config:GetSettings().ShowAllOptionsMain, changed = Ui.RenderOptionToggle("show_main_all_tog",
                "Show All Module Options", Config:GetSettings().ShowAllOptionsMain)
            if changed then
                Config:SaveSettings()
            end
            ImGui.SameLine()
        end

        changed = false
        Config:GetSettings().ShowAdvancedOpts, changed = Ui.RenderOptionToggle("show_adv_tog",
            "Show Advanced Options", Config:GetSettings().ShowAdvancedOpts)
        if changed then
            Config:SaveSettings()
        end

        Ui.ConfigFilter = ImGui.InputText("Search Configs", Ui.ConfigFilter)
    end

    local filteredSettings = {}

    if Ui.ConfigFilter:len() > 0 then
        for _, k in ipairs(settingNames) do
            local lowerFilter = Ui.ConfigFilter:lower()
            if k:lower():find(lowerFilter) ~= nil or defaults[k].DisplayName:lower():find(lowerFilter) ~= nil or defaults[k].Category:lower():find(lowerFilter) ~= nil then
                table.insert(filteredSettings, k)
            end
        end
        settingNames = filteredSettings
    end

    table.sort(settingNames,
        function(k1, k2)
            if (defaults[k1].Index ~= nil or defaults[k2].Index ~= nil) and (defaults[k1].Index ~= defaults[k2].Index) then
                return (defaults[k1].Index or 999) < (defaults[k2].Index or 999)
            elseif defaults[k1].Category == defaults[k2].Category then
                return defaults[k1].DisplayName < defaults[k2].DisplayName
            else
                return defaults[k1].Category < defaults[k2].Category
            end
        end)

    local catNames = categories and categories:toList() or { "", }
    table.sort(catNames)

    if ImGui.BeginTabBar("Settings_Categories") then
        for _, c in ipairs(catNames) do
            local shouldShow = false
            for _, k in ipairs(settingNames) do
                if defaults[k].Category == c then
                    if Config:GetSetting('ShowAdvancedOpts') or (defaults[k].ConfigType == nil or defaults[k].ConfigType:lower() == "normal") then
                        shouldShow = true
                        break
                    end
                end
            end

            if shouldShow then
                if ImGui.BeginTabItem(c) then
                    local cat_pressed = false

                    settings, cat_pressed, new_loadout = Ui.RenderSettingsTable(settings, settingNames, defaults, c)
                    any_pressed = any_pressed or cat_pressed
                    ImGui.EndTabItem()
                end
            end
        end
        ImGui.EndTabBar()
    end

    ImGui.Unindent()

    return settings, any_pressed, new_loadout
end

--- Generates a dynamic tooltip for a given spell action.
--- @param action string The action identifier for the spell.
--- @return string The generated tooltip for the spell.
function Ui.GetDynamicTooltipForSpell(action)
    local resolvedItem = Modules:ExecModule("Class", "GetResolvedActionMapItem", action)

    if not resolvedItem or not resolvedItem() then
        return string.format("Use %s Spell : %s\n\nThis Spell:\n%s", action, "None", "None")
    end

    return string.format("Use %s Spell : %s\n\nThis Spell:\n%s", action, resolvedItem() or "None",
        resolvedItem.Description() or "None")
end

--- Generates a dynamic tooltip for a given action.
--- @param action string The action for which the tooltip is generated.
--- @return string The generated tooltip for the specified action.
function Ui.GetDynamicTooltipForAA(action)
    local resolvedItem = mq.TLO.Spell(action)

    return string.format("Use %s Spell : %s\n\nThis Spell:\n%s", action, resolvedItem() or "None",
        resolvedItem.Description() or "None")
end

--- Get the con color based on the provided color value.
--- @param color string The color value to determine the con color.
--- @return number, number, number, number The corresponding con color in RGBA format
function Ui.GetConColor(color)
    if color then
        if color:lower() == "dead" then
            return 0.4, 0.4, 0.4, 0.8
        end

        if color:lower() == "grey" then
            return 0.6, 0.6, 0.6, 0.8
        end

        if color:lower() == "green" then
            return 0.02, 0.8, 0.2, 0.8
        end

        if color:lower() == "light blue" then
            return 0.02, 0.8, 1.0, 0.8
        end

        if color:lower() == "blue" then
            return 0.02, 0.4, 1.0, 1.0
        end

        if color:lower() == "yellow" then
            return 0.8, 0.8, 0.02, 0.8
        end

        if color:lower() == "red" then
            return 0.8, 0.2, 0.2, 0.8
        end
    end

    return 1.0, 1.0, 1.0, 1.0
end

--- @param spawn MQSpawn The spawn object for which to determine the con color.
--- @return number, number, number, number The con color associated with the given spawn in RGBA format.
function Ui.GetConColorBySpawn(spawn)
    if not spawn or not spawn or spawn.Dead() then return Ui.GetConColor("Dead") end

    return Ui.GetConColor(spawn.ConColor())
end

--- Checks if navigation is enabled for a given location.
--- @param loc string The location to check, represented as a string with coordinates.
function Ui.NavEnabledLoc(loc)
    ImGui.PushStyleColor(ImGuiCol.Text, 0.690, 0.553, 0.259, 1)
    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.33, 0.33, 0.33, 0.5)
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.0, 0.66, 0.33, 0.5)
    local navLoc = ImGui.Selectable(loc, false, ImGuiSelectableFlags.AllowDoubleClick)
    ImGui.PopStyleColor(3)
    if loc ~= "0,0,0" then
        if navLoc and ImGui.IsMouseDoubleClicked(0) then
            Core.DoCmd('/nav locYXZ %s', loc)
        end

        Ui.Tooltip("Double click to Nav")
    end
end

--- Generates a tooltip with the given description.
--- @param desc string: The description to be displayed in the tooltip.
function Ui.Tooltip(desc)
    ImGui.SameLine()
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 25.0)
        if type(desc) == "function" then
            ImGui.Text(desc())
        else
            ImGui.Text(desc)
        end
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

return Ui
