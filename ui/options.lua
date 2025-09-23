local mq                = require('mq')
local ImGui             = require('ImGui')
local Config            = require('utils.config')
local Ui                = require('utils.ui')
local Icons             = require('mq.ICONS')
local Modules           = require('utils.modules')
local Strings           = require('utils.strings')
local Set               = require("mq.Set")

-- Using the following terms:
-- Group: Broad category of options, found on the left panel
-- Header: Which collapsing header on the right panel the option should be listed under
-- Category: Will use dividers under each header to further organize options.

local OptionsUI         = { _version = '1.0', _name = "OptionsUI", _author = 'Derple', 'Algar', }
OptionsUI.__index       = OptionsUI
OptionsUI.selectedGroup = "General"
OptionsUI.configFilter  = ""

function OptionsUI.LoadIcon(icon)
    return mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/" .. icon .. ".png")
end

OptionsUI.Groups          = { --- Add a default of the same name for any key that has nothing in its table once these are finished
    {
        Name = "General",
        Description = "General and Misc Settings",
        Icon = Icons.FA_COGS,
        IconImage = OptionsUI.LoadIcon("settingsicon"),
        Headers = {
            ['General'] = { "General Settings", },
            ['Announcements'] = { "Announcements", }, -- group announce stuff
            ['Interface'] = { "Interface", },         -- ui stuff
            ['Loot(Emu)'] = { "LNS", },
            ['Misc'] = { "Other", },                  -- ??? profit
            ['Uncategorized'] = { "Uncategorized", }, -- settings from custom configs that don't have proper group/header
        },
    },
    {
        Name = "Movement",
        Description = "Following, Medding, Pulling",
        Icon = Icons.MD_DIRECTIONS_RUN,
        IconImage = OptionsUI.LoadIcon("followicon"),
        Headers = {
            ['Following'] = { "Chase", "Camp", },
            ['Meditation'] = { "Med Rules", "Med Thresholds", },
            ['Drag'] = { "Drag", },
            ['Pulling'] = { "Pull Rules", "Puller Vitals", "Group Vitals", "Distance", "Targets", },
        },
    },
    {
        Name = "Combat",
        Description = "Assisting, Positioning",
        Icon = Icons.FA_HEART,
        IconImage = OptionsUI.LoadIcon("swordicon"),
        Headers = {
            ['Targeting'] = { "Targeting", },     -- Auto engage, med break, stay on target, etc
            ['Assisting'] = { "Assisting", },     -- this will include pet and merc percentages/commands
            ['Positioning'] = { "Positioning", }, -- stick, face, etc
            ['Burning'] = { "Burning", },
            ['Tanking'] = { "Tanking", },
        },
    },
    {
        Name = "Abilities",
        Description = "Spells, Songs, Discs, AA",
        Icon = Icons.FA_HEART,
        IconImage = OptionsUI.LoadIcon("stafficon"),
        Headers = {
            ['Common'] = { "Common Rules", "Under the Hood", },
            ['Pet'] = { "Summoning", "Buffs", "Swarm", },
            ['Buffs'] = { "Buff Rules", "Self", "Group", },
            ['Debuffs'] = { "Debuff Rules", "Slow", "Resist/Stat", "Snare", "Dispel", }, -- Resist i.e, Malo, Tash, druid
            ['Healing'] = { "Healing Rules", "Healing Thresholds", "Curing", "Rezzing", },
            ['Damage'] = { "Direct", "AE", "Over Time", "Taps", },
            ['Tanking'] = { "Hate Tools", "Defenses", },
            ['Utility'] = { "Hate Reduction", "Emergency", "Unique", }, -- Unique Example: Canni, Paragon, etc.
            ['Mez'] = { "Mez General", "Mez Targets", },
            ['Charm'] = { "Charm General", "Charm Targets", },
        },
    },
    {
        Name = "Items",
        Description = "Clickies, Bandolier Swaps",
        Icon = Icons.MD_RESTAURANT_MENU,
        IconImage = OptionsUI.LoadIcon("itemicon"),
        Headers = {
            ['Clickies(Pre-Configured)'] = { "Clickies", },
            ['Bandolier'] = { "Swaps", },
            ['Instruments'] = { "Instruments", },
        },
    },
}

OptionsUI.FilteredGroups  = OptionsUI.Groups

OptionsUI.GroupsNameToIDs = {}

for id, group in ipairs(OptionsUI.Groups) do
    OptionsUI.GroupsNameToIDs[group.Name] = id
end

OptionsUI.settings          = {}
OptionsUI.SettingNames      = {}
OptionsUI.SettingCategories = Set.new({})
OptionsUI.DefaultConfigs    = {}
--Custom module list to control the desired order of the settings within a category (basically this just ensures class-specific settings are last for consistency)
OptionsUI.CustomModuleOrder = { "Movement", "Pull", "Drag", "Mez", "Charm", "Clickies", "Class", "Travel", "Named", "Perf", "Contributors", "Debug", "FAQ", }

-- Premise:

-- Render groups and descriptions on the left panel.
-- -- Descriptions can be a tooltip, but it would be great to actually make them images at some point
-- -- That way, we could have larger lettering on the group Names with smaller description text underneath


-- Misc Thoughts
-- Abils seems to have a lot of headers, but I guess most won't be shown for most classes.
-- -- It still makes the most logical sense to me, breaking them up just to hit a target # of headers doesn't seem great.
-- Icons can be done later, etc. Going to have to pull up the list so I can see them visually. If we use image buttons, we don't need them.

-- Note... plan on moving functions to proper libraries as necessary later
local function shallow_copy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

function OptionsUI:ApplySearchFilter()
    self.FilteredGroups = self.Groups

    if self.configFilter:len() > 0 then
        local filter = self.configFilter:lower()
        local filtered = {}

        for _, group in ipairs(self.Groups) do
            local groupNameLower = group.Name:lower()
            local groupMatches = groupNameLower:find(filter, 1, true) ~= nil or (group.Description or ""):lower():find(filter, 1, true) ~= nil

            local newGroup = shallow_copy(group)
            newGroup.Headers = {} -- clear headers for rebuilding

            for header, categories in pairs(group.Headers) do
                local headerLower = header:lower()
                local headerMatches = headerLower:find(filter, 1, true) ~= nil

                local newCategories = {}

                for _, category in ipairs(categories) do
                    local categoryLower = category:lower()
                    local categoryMatches = categoryLower:find(filter, 1, true) ~= nil

                    local settingsForCategory = Config:GetAllSettingsForCategory(category)
                    local matchingSettings = {}

                    for _, settingName in ipairs(settingsForCategory or {}) do
                        local settingDefaults         = Config:GetSettingDefaults(settingName)
                        local settingDisplayNameLower = (settingDefaults.DisplayName or ""):lower()
                        local settingTooltipLower     = (type(settingDefaults.Tooltip) == 'function' and settingDefaults.Tooltip() or (settingDefaults.Tooltip or "")):lower()
                        local showAdv                 = Config:GetSetting('ShowAdvancedOpts') or
                            (settingDefaults.ConfigType == nil or settingDefaults.ConfigType:lower() == "normal")

                        if showAdv and (settingDisplayNameLower:find(filter, 1, true) ~= nil or
                                settingTooltipLower:find(filter, 1, true) ~= nil) then
                            table.insert(matchingSettings, settingName)
                        end
                    end

                    if categoryMatches or #matchingSettings > 0 then
                        table.insert(newCategories, category)
                    end
                end

                if headerMatches or #newCategories > 0 then
                    newGroup.Headers[header] = newCategories
                end
            end

            if groupMatches or next(newGroup.Headers) ~= nil then
                table.insert(filtered, newGroup)
            end
        end

        self.FilteredGroups = filtered

        OptionsUI.GroupsNameToIDs = {}

        for id, group in ipairs(OptionsUI.FilteredGroups) do
            OptionsUI.GroupsNameToIDs[group.Name] = id
        end
    end
end

function OptionsUI:RenderGroupPanel(groupLabel, groupName)
    if ImGui.Selectable(" ##" .. groupLabel, self.selectedGroup == groupName) then
        self.selectedGroup = groupName
    end
    ImGui.SameLine()
    ImGui.Text(groupLabel)
end

function OptionsUI:RenderGroupPanelWithImage(group)
    local selectableHeight = 40
    local iconSize         = 30
    local cursorScreenPos  = ImGui.GetCursorScreenPosVec()
    local textColStyle     = ImGui.GetStyleColorVec4(ImGuiCol.Text)
    local currentStyle     = ImGui.GetStyle()

    local _, pressed       = ImGui.Selectable("##" .. group.Name, self.selectedGroup == group.Name, ImGuiSelectableFlags.None, ImVec2(0, selectableHeight))

    if group.Description and group.Description:len() > 0 then
        Ui.Tooltip(group.Description or "")
    end

    if pressed then
        self.selectedGroup = group.Name
    end

    local draw_list = ImGui.GetWindowDrawList()

    local _, label_y = ImGui.CalcTextSize(group.Name)
    local midLabelY = math.floor((selectableHeight - label_y) / 2) or 0
    local midIconY = math.floor((selectableHeight - iconSize) / 2) or 0

    -- set the text color from the theme
    local labelCol = IM_COL32(math.floor(textColStyle.x * 255), math.floor(textColStyle.y * 255), math.floor(textColStyle.z * 255), math.floor(textColStyle.w * 255))

    local currentXPos = cursorScreenPos.x + currentStyle.ItemSpacing.x
    -- draw the icon png
    draw_list:AddImage(group.IconImage:GetTextureID(),
        ImVec2(currentXPos, cursorScreenPos.y + midIconY),
        ImVec2(currentXPos + iconSize, cursorScreenPos.y + midIconY + iconSize),
        ImVec2(0, 0), ImVec2(1, 1),
        IM_COL32(255, 255, 255, 255))

    -- move the cursor to the right of the icon
    currentXPos = currentXPos + iconSize + currentStyle.ItemSpacing.x

    -- render the label text
    draw_list:AddText(ImVec2(currentXPos, cursorScreenPos.y + midLabelY), labelCol, group.Name)
end

function OptionsUI:RenderCategorySeperator(category)
    ImGui.PushStyleVar(ImGuiStyleVar.SeparatorTextPadding, ImVec2(15, 15))
    ImGui.PushStyleVar(ImGuiStyleVar.SeparatorTextAlign, ImVec2(0.05, 0.5))
    ImGui.SeparatorText(category)
    ImGui.PopStyleVar(2)
end

function OptionsUI:RenderOptionsPanel(groupName)
    for header, options in pairs(self.FilteredGroups[self.GroupsNameToIDs[groupName]] and (self.FilteredGroups[self.GroupsNameToIDs[groupName]].Headers or {}) or {}) do
        local any_options_in_header = false
        for _, category in ipairs(options) do
            if #Config:GetAllSettingsForCategory(category) > 0 then
                any_options_in_header = true
                break
            end
        end

        if any_options_in_header and ImGui.CollapsingHeader(header) then
            for _, category in ipairs(options) do
                if #Config:GetAllSettingsForCategory(category) > 0 then
                    -- only draw the seperator if the category name is different from the heading
                    if header ~= category then
                        self:RenderCategorySeperator(category)
                    end
                    -- Render options for this category
                    self:RenderCategorySettings(category)
                end
            end
            -- Render options for this header
        end
    end

    -- original plan:
    -- check headers in groups table against combined settings table
    -- if there is a setting with that header, draw a collapsing header
    -- if not, draw the alternate (non-collapsing) gray header (as soon as I figure out how the heck to do that)
    -- -- I think it would be nice, but it is much easier to only draw the headers that have entries
    -- render categories
end

function OptionsUI:RenderCategorySettings(category)
    -- We have our header rendered, we clicked on it to expand it, this is the next step in iterating through the groups
    -- check group table above to see if the header keys have entries in the category table
    -- if there is a category in the table, check if a setting of that category exists in the combinedsettingstable
    -- if there is, draw the name with a divider
    -- render an option table with all options from that (category if present, header without category if not)
    -- entries should already be indexed in the combined settings table
    local any_pressed         = false
    local new_loadout         = false
    local pressed             = false
    local loadout_change      = false
    local renderWidth         = 300
    local windowWidth         = ImGui.GetWindowWidth()
    local numCols             = math.max(1, math.floor(windowWidth / renderWidth))
    local settingsForCategory = Config:GetAllSettingsForCategory(category)

    -- ImGui.PushStyleVar(ImGuiStyleVar.ChildRounding, 5.0)
    -- ImGui.PushStyleVar(ImGuiStyleVar.ChildBorderSize, 1.0)
    -- ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImVec2(15, 15))
    -- ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, ImVec2(25, 25))
    -- ImGui.BeginChild("OptionsChild_" .. category, ImVec2(0, 0),
    --     bit32.bor(ImGuiChildFlags.Border, ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.AutoResizeY),
    --     bit32.bor(ImGuiWindowFlags.None))
    -- ImGui.PopStyleVar(4)

    if ImGui.BeginTable("Options_" .. (category), 2 * numCols, ImGuiTableFlags.Borders) then
        -- ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        for _ = 1, numCols do
            ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthFixed), 180.0)
            ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
        end
        -- ImGui.PopStyleColor()
        -- ImGui.TableHeadersRow()
        -- ImGui.TableNextRow()

        for idx, settingName in ipairs(settingsForCategory or {}) do
            local settingDefaults = Config:GetSettingDefaults(settingName)
            local setting         = Config:GetSetting(settingName)
            local id              = "##" .. settingName
            local settingTooltip  = (type(settingDefaults.Tooltip) == 'function' and settingDefaults.Tooltip() or settingDefaults.Tooltip) or ""
            local showAdv         = Config:GetSetting('ShowAdvancedOpts') or
                (settingDefaults.ConfigType == nil or settingDefaults.ConfigType:lower() == "normal")
            local matchedFilter   = (self.configFilter == "") and showAdv

            if showAdv and (settingDefaults.DisplayName:lower():find(self.configFilter, 1, true) ~= nil or
                    settingTooltip:lower():find(self.configFilter, 1, true) ~= nil) then
                matchedFilter = true
            end

            if matchedFilter then
                if settingDefaults.Type ~= "Custom" then
                    ImGui.TableNextColumn()
                    ImGui.Text(string.format("%s", settingDefaults.DisplayName or (string.format("None %d", idx))))
                    Ui.Tooltip(string.format("%s\n\n[Variable: %s]\n[Default: %s]",
                        settingTooltip,
                        setting,
                        tostring(settingDefaults.Default)))
                    ImGui.TableNextColumn()
                    local typeOfSetting = type(settingDefaults.Type) == 'string' and settingDefaults.Type or type(setting)
                    if (settingDefaults.Type or ""):find("Array") then
                        typeOfSetting = settingDefaults.Type:sub(7)
                    end

                    if settingDefaults ~= nil then
                        setting, loadout_change, pressed = Ui.RenderOption(
                            typeOfSetting,
                            setting,
                            id,
                            settingDefaults.RequiresLoadoutChange or false,
                            settingDefaults.ComboOptions or settingDefaults.Min, settingDefaults.Max, settingDefaults.Step or 1)
                        new_loadout = new_loadout or loadout_change
                        any_pressed = any_pressed or pressed

                        --  need to update setting here and notify module
                        if pressed then
                            Config:SetSetting(settingName, setting)

                            if new_loadout then
                                Modules:ExecModule("Class", "RescanLoadout")
                                new_loadout = false
                            end
                        end
                    else
                        ImGui.TextColored(1.0, 0.0, 0.0, 1.0, "Error: Setting not found - " .. settingName)
                    end
                end
            end
        end
        ImGui.EndTable()
    end

    --ImGui.EndChild()
end

function OptionsUI:RenderCurrentTab()
    self:RenderOptionsPanel(self.selectedGroup)
end

function OptionsUI:RenderMainWindow(imgui_style, curState, openGUI)
    local shouldDrawGUI = true

    if not Config.Globals.Minimized then
        local flags = ImGuiWindowFlags.None

        if Config:GetSetting('MainWindowLocked') then
            flags = bit32.bor(flags, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoResize)
        end

        openGUI, shouldDrawGUI = ImGui.Begin(('RGMercs Options%s###rgmercsOptionsUI'):format(Config.Globals.PauseMain and " [Paused]" or ""), openGUI, flags)

        ImGui.PushID("##RGMercsUI_" .. Config.Globals.CurLoadedChar)

        if shouldDrawGUI then
            local _, y = ImGui.GetContentRegionAvail()
            if ImGui.BeginChild("left##RGmercsOptions", ImGui.GetWindowContentRegionWidth() * .3, y - 1, ImGuiChildFlags.Border) then
                local flags = bit32.bor(ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter, ImGuiTableFlags.ScrollY)
                -- figure out icons once headings are finalized
                local textChanged = false
                local inputBoxPosX = ImGui.GetCursorPosX()
                self.configFilter, textChanged = ImGui.InputText("Search Configs###OptionsUISearchText", self.configFilter)
                if textChanged then
                    self:ApplySearchFilter()
                end

                if not ImGui.IsItemActive() and self.configFilter:len() == 0 then
                    ImGui.SameLine()
                    local curPosX = ImGui.GetCursorPosX()
                    ImGui.SetCursorPosX(inputBoxPosX)
                    ImGui.TextColored(0.8, 0.8, 0.8, 0.75, "Search Configs...")
                    ImGui.SameLine()
                    ImGui.SetCursorPosX(curPosX)
                else
                    ImGui.SameLine()
                end

                if ImGui.SmallButton(Icons.MD_CLEAR) then
                    self.configFilter = ""
                    self:ApplySearchFilter()
                end
                Ui.Tooltip("Clear Search Text")
                local ShowAdvancedOpts = Config:GetSetting('ShowAdvancedOpts')
                local changed = false
                ShowAdvancedOpts, changed = Ui.RenderOptionToggle("show_adv_tog###OptionsUI", "Show Advanced Options", ShowAdvancedOpts)
                if changed then
                    Config:SetSetting('ShowAdvancedOpts', ShowAdvancedOpts)
                    self:ApplySearchFilter()
                end
                ImGui.PushStyleVar(ImGuiStyleVar.ChildRounding, 5)

                if ImGui.BeginTable('configmenu##RGmercsOptions', 1, flags, 0, 0, 0.0) then
                    ImGui.TableNextColumn()
                    for _, group in ipairs(self.FilteredGroups) do
                        if group.IconImage then
                            self:RenderGroupPanelWithImage(group)
                        else
                            self:RenderGroupPanel(string.format("%s %s", group.Icon, group.Name), group.Name)
                        end
                        ImGui.TableNextColumn()
                    end
                    ImGui.EndTable()
                end

                ImGui.PopStyleVar()
            end
            ImGui.EndChild()
            ImGui.SameLine()
            local x, _ = ImGui.GetContentRegionAvail()
            if ImGui.BeginChild("right##RGmercsOptions", x, y - 1, ImGuiChildFlags.Border) then
                local flags = bit32.bor(ImGuiTableFlags.BordersOuter, ImGuiTableFlags.BordersInner)
                if ImGui.BeginTable('rightpanelTable##RGmercsOptions', 1, flags, 0, 0, 0.0) then
                    ImGui.TableNextColumn()
                    self:RenderCurrentTab()
                    ImGui.EndTable()
                end
            end
            ImGui.EndChild()
        end

        ImGui.PopID()

        ImGui.End()
    end

    return openGUI
end

return OptionsUI
