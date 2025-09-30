local mq       = require('mq')
local ImGui    = require('ImGui')
local ImagesUI = require('ui.images')
local Config   = require('utils.config')
local Casting  = require('utils.casting')
local Core     = require('utils.core')
local Ui       = require('utils.ui')
local Strings  = require('utils.strings')
local Icons    = require('mq.ICONS')

local HudUI    = { _version = '1.0', _name = "HudUI", _author = 'Derple', }
HudUI.__index  = HudUI

function HudUI:RenderToggleHud()
    local miniWidth = 210
    local miniHeight = 56
    ImGui.SetNextWindowSize(ImVec2(miniWidth, miniHeight), ImGuiCond.Always)

    local open, show = ImGui.Begin("RGMercsHUD", true, bit32.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoResize))
    if not open then show = false end
    if show then
        local btnImg = Casting.LastBurnCheck and ImagesUI.burnImg or ImagesUI.derpImg
        if Config.Globals.PauseMain then
            if ImGui.ImageButton('RGMercsButton', btnImg:GetTextureID(), ImVec2(30, 30), ImVec2(0.0, 0.0), ImVec2(1, 1), ImVec4(0, 0, 0, 0), ImVec4(1, 0, 0, 1)) then
                Config.Globals.Minimized = not Config.Globals.Minimized
            end
            if ImGui.IsItemHovered() then
                ImGui.SetTooltip("RGMercs is Paused.")
            end
        else
            if ImGui.ImageButton('RGMercsButton', btnImg:GetTextureID(), ImVec2(30, 30)) then
                Config.Globals.Minimized = not Config.Globals.Minimized
            end
            if ImGui.IsItemHovered() then
                ImGui.BeginTooltip()
                if Casting.LastBurnCheck then
                    ImGui.TextColored(IM_COL32(200, math.floor(os.clock() % 2) == 1 and 52 or 200, 52, 255),
                        string.format("RGMercs is BURNING!!"))
                else
                    ImGui.Text("RGMercs is Running")
                end
                ImGui.EndTooltip()
            end
        end
        if ImGui.BeginPopupContextWindow() then
            local pauseLabel = Config.Globals.PauseMain and "Resume" or "Pause"
            if ImGui.MenuItem(pauseLabel) then
                Config.Globals.PauseMain = not Config.Globals.PauseMain
            end
            ImGui.EndPopup()
        end
        ImGui.SameLine()

        local lbl = Config.Globals.PauseMain and "Paused" or "Running"
        local cursorPos = ImGui.GetCursorPosVec()
        local toggleHeight = 16

        local pause_main, pause_main_pushed = Ui.RenderFancyToggle("##rgmercs_hud_toggle_pause", lbl, not Config.Globals.PauseMain, ImVec2(32, toggleHeight),
            ImVec4(0.3, 0.8, 0.3, 0.8), ImVec4(0.8, 0.3, 0.3, 0.8), nil, true)

        ImGui.SameLine()
        ImGui.SetCursorPosX(miniWidth - 20 - ImGui.GetStyle().WindowPadding.x)

        if ImGui.SmallButton(Icons.MD_SETTINGS) then
            Config:ClearAllHighlightedModules()
            Config:SetSetting('EnableOptionsUI', not Config:GetSetting('EnableOptionsUI'))
        end

        local cursorPosAfter = ImGui.GetCursorPosVec()

        if pause_main_pushed then
            Config.Globals.PauseMain = not pause_main
        end

        lbl = Config:GetSetting('DoPull') and Strings.PadString("Pulling", 10, false) or "Not Pulling"

        cursorPos.y = cursorPos.y + toggleHeight + ImGui.GetStyle().ItemSpacing.y
        ImGui.SetCursorPos(cursorPos)
        local pull_toggle, pull_toggle_changed = Ui.RenderFancyToggle("##rgmercs_hud_toggle_pulls", lbl, Config:GetSetting('DoPull'), nil,
            ImVec4(0.3, 0.8, 0.3, 0.8), ImVec4(0.8, 0.3, 0.3, 0.8), nil, true)
        ImGui.SetCursorPos(cursorPosAfter)

        if pull_toggle_changed then
            Config:SetSetting('DoPull', not pull_toggle)
            local cmd = Config:GetSetting('DoPull') and "pullstop" or "pullstart"
            Core.DoCmd("/rgl %s", cmd)
        end

        if ImGui.IsKeyPressed(ImGuiKey.Escape) and Config:GetSetting("EscapeMinimizes") and not Config.Globals.Minimized then
            Config.Globals.Minimized = true
        end
    end
    ImGui.End()
end

return HudUI
