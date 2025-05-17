local mq        = require('mq')
local ImGui     = require('ImGui')
local Config    = require('utils.config')
local Ui        = require('utils.ui')
local Icons     = require('mq.ICONS')
local GitCommit = require('extras.version')
local Modules   = require('utils.modules')


-- Using the following terms:
-- Group: Broad category of options, found on the left panel
-- Header: Which collapsing header on the right panel the option should be listed under
-- Category: Will use dividers under each header to further organize options.

local OptionsUI         = { _version = '1.0', _name = "OptionsUI", _author = 'Derple', 'Algar', }
OptionsUI.__index       = OptionsUI
OptionsUI.selectedGroup = "General"
OptionsUI.Groups        = {
    {
        Name = "Movement",
        Desciption = "Following, Medding, Pulling",
        Icon = Icons.FA_HEART,
        Headers = { "Chase", "Camp", "Meditation", "Mounts", "Drag", "Pulling", },
    },
    {
        Name = "Combat",
        Desciption = "Assisting, Positioning",
        Icon = Icons.FA_HEART,
        Headers = { "Engage", "Positioning", "Tanking", },
    },
    { -- i have nfc what i'm doing, but it seems like we need to specify the order for consistency.
        -- -- hardcoded seems easier than multiple indexes on each setting
        Name = "Abilities",
        Desciption = "Spells, Songs, Discs, AA",
        Icon = Icons.FA_HEART,
        Headers = {
            ['Buffs'] = { "Self", "Group", },
            ['Debuffs'] = { "Resist", "Slow", "Dispel", "Snare", }, -- Resist i.e, Malo, Tash, druid
            ['Healing'] = { "General", "Thresholds", "Curing", "Rezzing", },
            ['Damage'] = { "Direct", "AE", "Over Time", "Taps", },
            ['Tanking'] = { "Hate Tools", "Defenses", },
            ['Utility'] = { "Hate Reduction", "Emergency", "Unique", }, -- Unique Example: Canni, Paragon, etc.
            ['Mez'] = { "General", "Range", "Target", },
            ['Charm'] = { "General", "Range", "Target", },
        }, -- this is still a WIP
    },
    {
        Name = "Items",
        Desciption = "Clickies, Bandolier Swaps",
        Icon = Icons.MD_RESTAURANT_MENU,
        Headers = { "Bandolier", "Clickies(Mercs-Defined)", "Clickies(User-Entered)", "Instruments", },
    },
    {
        Name = "Miscellaneous",
        Desciption = "Loot, UI, Communication",
        Icon = Icons.FA_COGS,
        Headers = { "Loot(Emu)", "Action Announcing", "UI", "Other", },
    },
}

-- Premise:

-- Render groups and descriptions on the left panel.
-- -- Descriptions can be a tooltip, but it would be great to actually make them images at some point
-- -- That way, we could have larger lettering on the group Names with smaller description text underneath


-- Misc Thoughts
-- Abils seems to have a lot of headers, but I guess most won't be shown for most classes.
-- -- It still makes the most logical sense to me, breaking them up just to hit a target # of headers doesn't seem great.
-- Icons can be done later, etc. Going to have to pull up the list so I can see them visually. If we use image buttons, we don't need them.

-- Note... plan on moving functions to proper libraries as necessary later

function OptionsUI:RenderGroupHeaders()
    -- check config util for any header listed in a setting, insert into table
    -- check all other module settings for headers, insert into table
    -- iterate through headers in group array above
    -- if header exists in our "current header" table, draw a collapsing header
    -- if not, draw the alternate (non-collapsing) gray header (as soon as I figure out how the heck to do that)
end

function OptionsUI:RenderCategories()
    -- We have our header rendered, we clicked on it to expand it, this is the next step in iterating through the groups
    -- check config util for any settings with categories matching the header variable passed to this function
    -- sort the options by indexes if they exist
    -- check all other modules for the above
    -- -- load each module to an intermediary table to sort options by index before we insert them into the table we just made above
    -- procedurally draw divider and table for each category in order set by the array above (no indexing for categories, only entries)
    -- each category will list its name and use a divider for the rest of the line.
    -- -- if this isn't possible, we just list the name and use a new line
    -- -- this idea may be adjusted once we see it
end

function OptionsUI:RenderGroupPanel(groupLabel, groupName)
    if ImGui.Selectable(groupLabel, self.selectedGroup == groupName) then
        self.selectedGroup = groupName
    end
end

function OptionsUI:RenderOptionsPanel(groupName)

end

function OptionsUI:GetCombinedSettingNames()
    --Custom module list to control the desired order of the settings within a category (basically this just ensures class-specific settings are last for consistency)
    local modules = { "Movement", "Pull", "Drag", "Mez", "Charm", "Class", "Travel", "Named", "Perf", "Contributors", "Debug", "FAQ", }

    local combinedSettingNames = {}

    for _, module in ipairs(modules) do
        local defaults = Modules:ExecModule(module, "GetDefaultSettings")
        local settingNames = {}

        --get defaults for this module
        for k, _ in pairs(defaults) do
            table.insert(settingNames, k)
        end

        -- sort by indexes, if there are any, before they are added to the list (so there is no conflict between indexing from different modules in the same category).
        table.sort(settingNames,
            function(k1, k2)
                if (defaults[k1].Index ~= nil or defaults[k2].Index ~= nil) and (defaults[k1].Index ~= defaults[k2].Index) then
                    return (defaults[k1].Index or 999) < (defaults[k2].Index or 999)
                elseif defaults[k1].Category == defaults[k2].Category then
                    return (defaults[k1].DisplayName or "") < (defaults[k2].DisplayName or "")
                else
                    return (defaults[k1].Category or "") < (defaults[k2].Category or "")
                end
            end)
        -- insert them into the master list
        for k, _ in pairs(settingNames) do
            table.insert(combinedSettingNames, k)
        end
    end

    return combinedSettingNames
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
