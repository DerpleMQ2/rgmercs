local mq                     = require('mq')
local ImGui                  = require('ImGui')
local Config                 = require('utils.config')
local Ui                     = require('utils.ui')
local Icons                  = require('mq.ICONS')
local GitCommit              = require('extras.version')

local SimpleUI               = { _version = '1.0', _name = "SimpleUI", _author = 'Derple', }
SimpleUI.__index             = SimpleUI
SimpleUI.selectedSimplePanel = "General"
SimpleUI.Categories          = {
    { Name = "General", Icon = Icons.FA_COGS,            Render = function() return SimpleUI:RenderGeneralTab() end, },
    { Name = "Healing", Icon = Icons.FA_HEART,           Render = function() return SimpleUI:RenderHealingTab() end, },
    { Name = "Combat",  Icon = Icons.MD_RESTAURANT_MENU, Render = function() return SimpleUI:RenderCombatTab() end, },
    { Name = "Spells",  Icon = Icons.FA_REBEL,           Render = function() return SimpleUI:RenderSpellsTab() end, },
}

function SimpleUI:RenderSimplePanelOption(optionLabel, optionName)
    if ImGui.Selectable(optionLabel, self.selectedSimplePanel == optionName) then
        self.selectedSimplePanel = optionName
    end
end

function SimpleUI:RenderGeneralTab()
    -- Render the General tab content here
    ImGui.Text("General Settings")
end

function SimpleUI:RenderHealingTab()
    -- Render the Healing tab content here
    ImGui.Text("Healing Settings")
end

function SimpleUI:RenderCombatTab()
    -- Render the Combat tab content here
    ImGui.Text("Combat Settings")
end

function SimpleUI:RenderSpellsTab()
    -- Render the Spells tab content here
    ImGui.Text("Spells Settings")
end

function SimpleUI:RenderCurrentTab()
    for _, category in ipairs(self.Categories) do
        if self.selectedSimplePanel == category.Name then
            category.Render()
            break
        end
    end
end

function SimpleUI:RenderMainWindow(imgui_style, curState, openGUI)
    local shouldDrawGUI = true

    if not Config.Globals.Minimized then
        local flags = ImGuiWindowFlags.None

        if Config.settings.MainWindowLocked then
            flags = bit32.bor(flags, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoResize)
        end

        openGUI, shouldDrawGUI = ImGui.Begin(('RGMercs%s###rgmercssimpleui'):format(Config.Globals.PauseMain and " [Paused]" or ""), openGUI, flags)

        ImGui.PushID("##RGMercsUI_" .. Config.Globals.CurLoadedChar)

        if shouldDrawGUI then
            local _, y = ImGui.GetContentRegionAvail()
            if ImGui.BeginChild("left##RGmercsSimplePanel", ImGui.GetWindowContentRegionWidth() * .3, y - 1, ImGuiChildFlags.Border) then
                local flags = bit32.bor(ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter, ImGuiTableFlags.BordersV, ImGuiTableFlags.ScrollY)
                -- figure out icons once headings are finalized
                if ImGui.BeginTable('configmenu##RGmercsSimplePanel', 1, flags, 0, 0, 0.0) then
                    ImGui.TableNextColumn()
                    for _, category in ipairs(self.Categories) do
                        self:RenderSimplePanelOption(string.format("%s %s", category.Icon, category.Name), category.Name)
                        ImGui.TableNextColumn()
                    end
                    ImGui.EndTable()
                end
            end
            ImGui.EndChild()
            ImGui.SameLine()
            local x, _ = ImGui.GetContentRegionAvail()
            if ImGui.BeginChild("right##RGmercsSimplePanel", x, y - 1, ImGuiChildFlags.Border) then
                local flags = bit32.bor(ImGuiTableFlags.BordersOuter, ImGuiTableFlags.BordersInner)
                if ImGui.BeginTable('rightpanelTable##RGmercsSimplePanel', 1, flags, 0, 0, 0.0) then
                    ImGui.TableNextColumn()

                    local tmp, changed = Ui.RenderOptionToggle("ToggleFullUI", "Toggle Full UI", Config:GetSetting('FullUI'))
                    if changed then
                        Config:SetSetting('FullUI', tmp)
                    end

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

function SimpleUI:RenderCategoryPanel() --panel
    -- make a table of existing categories for that panel
    -- render collapsing header with existing category names for the heading we are on, using something similar to render settings
    -- render subcategory names with dividers under each collapsing header
    -- render settings tables for each subcategory
    -- keep the last two grouped together when iterating so we end up with ----SubcatName---- with options underneath for each subcat
end

function SimpleUI:GetCategories() -- panel
    -- this might end up in the UI utils
    -- i am unsure if we should:
    -- iterate through all modules and dump all settings into a new table. iterate through new table to return all categories for this panel
    -- or
    -- iterate through all modules, iterate through each settings table to return all categories for this panel
end

return SimpleUI
