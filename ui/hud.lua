local mq       = require('mq')
local ImGui    = require('ImGui')
local ImagesUI = require('ui.images')
local Config   = require('utils.config')
local Casting  = require('utils.casting')
local Core     = require('utils.core')

local HudUI    = { _version = '1.0', _name = "HudUI", _author = 'Derple', }
HudUI.__index  = HudUI

function HudUI:RenderToggleHud()
    local open, show = ImGui.Begin("RGMercsHUD", true, bit32.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.AlwaysAutoResize))
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


        local red = ImVec4(1.0, 0.4, 0.4, 0.4)
        local green = ImVec4(0.4, 1.0, 0.4, 0.4)
        local lbl = Config.Globals.PauseMain and "Paused" or "Running"
        local color = Config.Globals.PauseMain and red or green
        ImGui.PushStyleColor(ImGuiCol.Button, color)
        if ImGui.Button(lbl) then
            Config.Globals.PauseMain = not Config.Globals.PauseMain
        end
        ImGui.PopStyleColor()

        ImGui.SameLine()

        color = Config:GetSetting('DoPull') and red or green
        lbl = Config:GetSetting('DoPull') and "Stop Pulls" or "Start Pulls"
        ImGui.PushStyleColor(ImGuiCol.Button, color)
        if ImGui.Button(lbl) then
            local cmd = Config:GetSetting('DoPull') and "pullstop" or "pullstart"
            Core.DoCmd("/rgl %s", cmd)
        end
        ImGui.PopStyleColor()
        if ImGui.IsKeyPressed(ImGuiKey.Escape) and Config:GetSetting("EscapeMinimizes") and not Config.Globals.Minimized then
            Config.Globals.Minimized = true
        end
    end
    ImGui.End()
end

return HudUI
