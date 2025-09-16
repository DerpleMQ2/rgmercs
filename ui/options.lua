local mq                  = require('mq')
local ImGui               = require('ImGui')
local Config              = require('utils.config')
local Ui                  = require('utils.ui')
local Icons               = require('mq.ICONS')
local Modules             = require('utils.modules')
local Set                 = require("mq.Set")

-- Using the following terms:
-- Group: Broad category of options, found on the left panel
-- Header: Which collapsing header on the right panel the option should be listed under
-- Category: Will use dividers under each header to further organize options.

local OptionsUI           = { _version = '1.0', _name = "OptionsUI", _author = 'Derple', 'Algar', }
OptionsUI.__index         = OptionsUI
OptionsUI.selectedGroup   = "General"
OptionsUI.Groups          = { --- Add a default of the same name for any key that has nothing in its table once these are finished
    {
        Name = "General",
        Desciption = "General Settings",
        Icon = Icons.FA_COGS,
        Headers = {
            ['General'] = { "General", },
            ['General2'] = { "General2", },
            ['General3'] = { "General3", },
        },
    },
    {
        Name = "Movement",
        Desciption = "Following, Medding, Pulling",
        Icon = Icons.MD_DIRECTIONS_RUN,
        Headers = {
            ['Following'] = { "Chase", "Camp", },
            ['Meditation'] = { "Behavior", "Thresholds", },
            ['Drag'] = {},
            ['Pulling'] = { "Behavior", "Puller", "Group", "Distance", "Targets", },
        },
    },
    {
        Name = "Combat",
        Desciption = "Assisting, Positioning",
        Icon = Icons.FA_HEART,
        Headers = {
            ['Targeting'] = { "General", },                        -- Auto engage, med break, stay on target, etc
            ['Assisting'] = { "General", },                        -- this will include pet and merc percentages/commands
            ['Positioning'] = { "General", "Tanking", "Events", }, -- stick, face, etc
            ['Burning'] = { "General", },
            ['Tanking'] = { "General", },
        },
    },
    {
        Name = "Abilities",
        Desciption = "Spells, Songs, Discs, AA",
        Icon = Icons.FA_HEART,
        Headers = {
            ['General'] = { "Behavior", "Under the Hood", },
            ['Buffs'] = { "General", "Self", "Pet", "Group", },
            ['Debuffs'] = { "General", "Slow", "Resist", "Snare", "Dispel", }, -- Resist i.e, Malo, Tash, druid
            ['Healing'] = { "General", "Thresholds", "Curing", "Rezzing", },
            ['Damage'] = { "General", "Direct", "AE", "Over Time", "Taps", },
            ['Tanking'] = { "Hate Tools", "Defenses", },
            ['Utility'] = { "Hate Reduction", "Emergency", "Unique", }, -- Unique Example: Canni, Paragon, etc.
            ['Mez'] = { "General", "Range", "Target", },
            ['Charm'] = { "General", "Range", "Target", },
        },
    },
    {
        Name = "Items",
        Desciption = "Clickies, Bandolier Swaps",
        Icon = Icons.MD_RESTAURANT_MENU,
        Headers = {
            ['Clickies(Pre-Configured)'] = { "Clickies", },
            ['Bandolier'] = { "Swaps", },
            ['Instruments'] = {},
        },
    },
    {
        Name = "Miscellaneous",
        Desciption = "Loot, UI, Communication",
        Icon = Icons.FA_COGS,
        Headers = {
            ['Loot(Emu)'] = {},
            ['Announcing'] = { "General", },          -- group announce stuff
            ['Interface'] = { "General", },           -- ui stuff
            ['Other'] = { "Other", },                 -- ??? profit
            ['Uncategorized'] = { "Uncategorized", }, -- settings from custom configs that don't have proper group/header
        },
    },
}

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


function OptionsUI:RenderGroupPanel(groupLabel, groupName)
    if ImGui.Selectable(groupLabel, self.selectedGroup == groupName) then
        self.selectedGroup = groupName
    end
end

function OptionsUI:RenderOptionsPanel(groupName)
    for header, options in pairs(self.Groups[self.GroupsNameToIDs[groupName]].Headers) do
        if ImGui.CollapsingHeader(header) then
            for _, category in ipairs(options) do
                ImGui.PushStyleVar(ImGuiStyleVar.SeparatorTextPadding, ImVec2(15, 15))
                ImGui.PushStyleVar(ImGuiStyleVar.SeparatorTextAlign, ImVec2(0.5, 0.5))

                ImGui.SeparatorText(category)
                ImGui.PopStyleVar(2)

                --ImGui.Separator()
                -- Render options for this category
                ImGui.PushStyleVar(ImGuiStyleVar.ChildRounding, 5.0)
                ImGui.PushStyleVar(ImGuiStyleVar.ChildBorderSize, 1.0)
                ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImVec2(15, 15))
                ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, ImVec2(25, 25))
                ImGui.BeginChild("OptionsChild_" .. category, ImVec2(0, 0), bit32.bor(ImGuiChildFlags.Border, ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.AutoResizeY),
                    bit32.bor(ImGuiWindowFlags.None))
                ImGui.PopStyleVar(4)

                self:RenderCategorySettings(category)

                ImGui.EndChild()
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

    if ImGui.BeginTable("Options_" .. (category), 2 * numCols, ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        for _ = 1, numCols do
            ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthFixed), 150.0)
            ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
        end
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()
        ImGui.TableNextRow()

        for idx, settingName in ipairs(settingsForCategory or {}) do
            local settingDefaults = Config:GetSettingDefaults(settingName)
            local setting         = Config:GetSetting(settingName)
            local id              = "##" .. settingName
            if settingDefaults.Type ~= "Custom" then
                ImGui.TableNextColumn()
                ImGui.Text(string.format("%s", settingDefaults.DisplayName or (string.format("None %d", idx))))
                Ui.Tooltip(string.format("%s\n\n[Variable: %s]\n[Default: %s]",
                    type(settingDefaults.Tooltip) == 'function' and settingDefaults.Tooltip() or settingDefaults.Tooltip,
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
        ImGui.EndTable()
    end
end

-- TODO: Figure this out. We can load these at the start, but we will also need to update the self.Settings table when we change a setting
-- -- At start, we will be doing double work when we update settings (like we are doing double on everything else).
-- -- Even after that, to write to the file *and* update this table will require some fuckery.
-- -- This is just going to be one of those integration issues and a trade-off for bucking modularity for settings.
function OptionsUI:GetCombinedCurrentSettings()
    -- get the current setting value from the RGMercs config file
    for name, setting in pairs(Config.settings) do
        self.settings[name] = setting
    end
    -- get the current setting value from each module's config file
    for _, module in pairs(OptionsUI.CustomModuleOrder) do
        local moduleSettings = Modules:ExecModule(module, "GetSettings") --These are the actual setting values from the character specific files

        for name, setting in pairs(moduleSettings) do
            self.settings[name] = setting
        end
    end
end

function OptionsUI:GetCombinedDefaultSettings()
    -- Get the Default Configs from all modules + config lumped together.

    -- Get Config settings copied into the new table, pull the keys and sort first so we don't have index number conflicts with modules
    local sortedConfigKeys = {}
    for name, setting in pairs(Config.DefaultConfig) do
        self.DefaultConfigs[name] = setting
        table.insert(sortedConfigKeys, name)
    end

    table.sort(sortedConfigKeys, function(k1, k2)
        local s1, s2 = Config.DefaultConfig[k1], Config.DefaultConfig[k2]
        if (s1.Index ~= nil or s2.Index ~= nil) and (s1.Index ~= s2.Index) then
            return (s1.Index or 999) < (s2.Index or 999)
        elseif s1.Category == s2.Category then
            return (s1.DisplayName or "") < (s2.DisplayName or "")
        else
            return (s1.Category or "") < (s2.Category or "")
        end
    end)

    for _, key in ipairs(sortedConfigKeys) do
        local setting = self.DefaultConfigs[key]
        table.insert(self.SettingNames, key)
        if setting.Type ~= "Custom" then
            self.SettingCategories:add(setting.Category)
        end
    end

    -- now iterate over the module List, and do the same thing on a per-module basis

    for _, module in pairs(OptionsUI.CustomModuleOrder) do
        local moduleDefaults = Modules:ExecModule(module, "GetDefaultSettings") --This is a list of all settings, including their default value

        for name, setting in pairs(moduleDefaults) do
            self.DefaultConfigs[name] = setting
        end

        local sortedModuleKeys = {}
        for name, _ in pairs(moduleDefaults) do
            table.insert(sortedModuleKeys, name)
        end

        table.sort(sortedModuleKeys, function(k1, k2)
            local s1, s2 = moduleDefaults[k1], moduleDefaults[k2]
            if (s1.Index ~= nil or s2.Index ~= nil) and (s1.Index ~= s2.Index) then
                return (s1.Index or 999) < (s2.Index or 999)
            elseif s1.Category == s2.Category then
                return (s1.DisplayName or "") < (s2.DisplayName or "")
            else
                return (s1.Category or "") < (s2.Category or "")
            end
        end)

        for _, key in ipairs(sortedModuleKeys) do
            local setting = moduleDefaults[key]
            table.insert(self.SettingNames, key)
            if setting.Type ~= "Custom" then
                self.SettingCategories:add(setting.Category)
            end
        end
    end
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
                local flags = bit32.bor(ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter, ImGuiTableFlags.BordersV, ImGuiTableFlags.ScrollY)
                -- figure out icons once headings are finalized
                if ImGui.BeginTable('configmenu##RGmercsOptions', 1, flags, 0, 0, 0.0) then
                    ImGui.TableNextColumn()
                    for _, group in ipairs(self.Groups) do
                        self:RenderGroupPanel(string.format("%s %s", group.Icon, group.Name), group.Name)
                        ImGui.TableNextColumn()
                    end
                    ImGui.EndTable()
                end
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
