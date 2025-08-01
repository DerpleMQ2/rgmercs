local mq        = require('mq')
local ImGui     = require('ImGui')
local Config    = require('utils.config')
local Ui        = require('utils.ui')
local Icons     = require('mq.ICONS')
local GitCommit = require('extras.version')
local Modules   = require('utils.modules')
local Set       = require("mq.Set")





-- Using the following terms:
-- Group: Broad category of options, found on the left panel
-- Header: Which collapsing header on the right panel the option should be listed under
-- Category: Will use dividers under each header to further organize options.

local OptionsUI             = { _version = '1.0', _name = "OptionsUI", _author = 'Derple', 'Algar', }
OptionsUI.__index           = OptionsUI
OptionsUI.selectedGroup     = "General"
OptionsUI.Groups            = {
    {
        Name = "Movement",
        Desciption = "Following, Medding, Pulling",
        Icon = Icons.FA_,
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
            ['Targeting'] = {},   -- Auto engage, med break, stay on target, etc
            ['Assisting'] = {},   -- this will include pet and merc percentages/commands
            ['Positioning'] = {}, -- stick, face, etc
            ['Burning'] = {},
            ['Tanking'] = {},
        },
    },
    {
        Name = "Abilities",
        Desciption = "Spells, Songs, Discs, AA",
        Icon = Icons.FA_HEART,
        Headers = {
            ['Buffs'] = { "Self", "Pet", "Group", },
            ['Debuffs'] = { "Resist", "Slow", "Dispel", "Snare", }, -- Resist i.e, Malo, Tash, druid
            ['Healing'] = { "General", "Thresholds", "Curing", "Rezzing", },
            ['Damage'] = { "Direct", "AE", "Over Time", "Taps", },
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
            ['Clickies(Pre-Defined)'] = { "Downtime", "Combat", "Recovery", }, -- should we combine pre/user-defined?
            ['Clickies(User-Defined)'] = { "Downtime", "Combat", "Recovery", },
            ['Bandolier'] = {},
            ['Instruments'] = {},
        },
    },
    {
        Name = "Miscellaneous",
        Desciption = "Loot, UI, Communication",
        Icon = Icons.FA_COGS,
        Headers = {
            ['Loot(Emu)'] = {},
            ['Announcing'] = {}, -- group announce stuff
            ['Interface'] = {},  -- ui stuff
            ['Other'] = {},      -- ??? profit
        },
    },
}
OptionsUI.Settings          = {}
OptionsUI.SettingNames      = {}
OptionsUI.SettingCategories = Set.new({})
OptionsUI.DefaultConfigs    = {}

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
    for _, c in ipairs(self.SettingCategories) do
        local shouldShow = false
        for _, k in ipairs(self.SettingNames) do
            -- stolen from elsewhere, examine/adapt once tables are properly set up
            -- if defaults[k].Category == c then
            --     if Config:GetSetting('ShowAdvancedOpts') or (defaults[k].ConfigType == nil or defaults[k].ConfigType:lower() == "normal") then
            --         shouldShow = true
            --         break
            --     end
            -- end
        end

        -- if shouldShow then
        --     if ImGui.BeginTabItem(c) then
        --         local cat_pressed = false

        --         settings, cat_pressed, new_loadout = Ui.RenderSettingsTable(settings, settingNames, defaults, c)
        --         any_pressed = any_pressed or cat_pressed
        --         ImGui.EndTabItem()
        --     end
        -- end
    end



    -- original plan:
    -- check headers in groups table against combined settings table
    -- if there is a setting with that header, draw a collapsing header
    -- if not, draw the alternate (non-collapsing) gray header (as soon as I figure out how the heck to do that)
    -- -- I think it would be nice, but it is much easier to only draw the headers that have entries
    -- render categories
end

function OptionsUI:RenderCategories()
    -- We have our header rendered, we clicked on it to expand it, this is the next step in iterating through the groups
    -- check group table above to see if the header keys have entries in the category table
    -- if there is a category in the table, check if a setting of that category exists in the combinedsettingstable
    -- if there is, draw the name with a divider
    -- render an option table with all options from that (category if present, header without category if not)
    -- entries should already be indexed in the combined settings table
end

function OptionsUI:GetCombinedSettings()
    --Custom module list to control the desired order of the settings within a category (basically this just ensures class-specific settings are last for consistency)
    local moduleList = { "Movement", "Pull", "Drag", "Mez", "Charm", "Clickies", "Class", "Travel", "Named", "Perf", "Contributors", "Debug", "FAQ", }

    for _, module in ipairs(moduleList) do
        -- get a combined settings list from all modules
        local moduleSettings = Modules:ExecModule(module, "GetSettings") --These are the actual setting values from the character specific files

        -- get default settings and category list from all modules
        local moduleDefaults = Modules:ExecModule(module, "GetDefaultSettings") --This is a list of all settings, with a default value


        -- Get the Default Configs from all modules + config lumped together.
        for k, _ in pairs(Config.DefaultConfig) do
            table.insert(self.DefaultConfigs, k)
        end
        -- is this moving everything?
        for k, _ in pairs(moduleDefaults) do
            table.insert(self.DefaultConfigs, k)
        end

        -- sort by indexes, if there are any, before they are added to the list (so there is no conflict between indexing from different modules in the same category).
        table.sort(self.DefaultConfigs,
            function(k1, k2)
                if (moduleDefaults[k1].Index ~= nil or moduleDefaults[k2].Index ~= nil) and (moduleDefaults[k1].Index ~= moduleDefaults[k2].Index) then
                    return (moduleDefaults[k1].Index or 999) < (moduleDefaults[k2].Index or 999)
                elseif moduleDefaults[k1].Category == moduleDefaults[k2].Category then
                    return (moduleDefaults[k1].DisplayName or "") < (moduleDefaults[k2].DisplayName or "")
                else
                    return (moduleDefaults[k1].Category or "") < (moduleDefaults[k2].Category or "")
                end
            end)
        -- break out names and categories for rendering later
        for k, v in pairs(self.DefaultConfigs) do
            table.insert(self.SettingNames, k)

            if v.Type ~= "Custom" then
                self.SettingCategories:add(v.Category)
            end
        end
    end
end

function OptionsUI:RenderCurrentTab()
    for _, group in ipairs(self.Groups) do
        if self.selectedGroup == group.Name then
            self:RenderOptionsPanel(group.Name)
            break
        end
    end
end

function OptionsUI:RenderMainWindow(imgui_style, curState, openGUI)
    local shouldDrawGUI = true

    if not Config.Globals.Minimized then
        local flags = ImGuiWindowFlags.None

        if Config.settings.MainWindowLocked then
            flags = bit32.bor(flags, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoResize)
        end

        openGUI, shouldDrawGUI = ImGui.Begin(('RGMercs%s###rgmercsOptionsUI'):format(Config.Globals.PauseMain and " [Paused]" or ""), openGUI, flags)

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
