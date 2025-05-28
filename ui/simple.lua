local mq                     = require('mq')
local ImGui                  = require('ImGui')
local Config                 = require('utils.config')
local Ui                     = require('utils.ui')
local Icons                  = require('mq.ICONS')
local GitCommit              = require('extras.version')

local SimpleUI               = { _version = '1.0', _name = "SimpleUI", _author = 'Derple', }
SimpleUI.__index             = SimpleUI
SimpleUI.selectedSimplePanel = "General"

function SimpleUI:RenderSimplePanelOption(optionLabel, optionName)
    if ImGui.Selectable(optionLabel, self.selectedSimplePanel == optionName) then
        self.selectedSimplePanel = optionName
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
                if ImGui.BeginTable('configmenu##RGmercsSimplePanel', 1, flags, 0, 0, 0.0) then
                    ImGui.TableNextColumn()
                    self:RenderSimplePanelOption(Icons.FA_COGS .. " General", "General")
                    ImGui.TableNextColumn()
                    self:RenderSimplePanelOption(Icons.FA_HEART .. " Healing", "Healing")
                    ImGui.TableNextColumn()
                    self:RenderSimplePanelOption(Icons.MD_RESTAURANT_MENU .. "Combat", "Combat")
                    ImGui.TableNextColumn()
                    self:RenderSimplePanelOption(Icons.FA_REBEL .. " Spells", "Spells")
                    ImGui.TableNextColumn()
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
                    ImGui.Text("Simple Panel: " .. self.selectedSimplePanel) -- Instead of this code this should now call to function which render each panel self:RenderGeneralPanel(), etc...
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

return SimpleUI
