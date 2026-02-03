local mq            = require('mq')
local CommitVersion = require('extras.version')
local OptionsUI     = require("ui.options")
local ImGui         = require('ImGui')
local Config        = require('utils.config')
local Globals       = require('utils.globals')
local Comms         = require('utils.comms')
local Ui            = require('utils.ui')
local Icons         = require('mq.ICONS')
local ImageUI       = require('ui.images')
local Core          = require('utils.core')
local Targeting     = require('utils.targeting')
local Casting       = require('utils.casting')
local Modules       = require('utils.modules')
local Movement      = require('utils.movement')
local ConsoleUI     = require('ui.console')

local StandardUI    = { _version = '1.0', _name = "StandardUI", _author = 'Derple', }
StandardUI.__index  = StandardUI

function StandardUI:renderModulesTabs()
    if not Config:SettingsLoaded() then return end

    for _, name in ipairs(Modules:GetModuleOrderedNames()) do
        if Modules:ExecModule(name, "ShouldRender") and not Config:GetSetting(name .. "_Popped", true) then
            if ImGui.BeginTabItem(name) then
                Modules:ExecModule(name, "Render")
                ImGui.EndTabItem()
            end
        end
    end
end

function StandardUI:RenderTarget()
    if Config.TempSettings.AssistWarning then
        ImGui.TextColored(IM_COL32(200, math.floor(Globals.GetTimeSeconds() % 2) == 1 and 52 or 200, 52, 255), Config.TempSettings.AssistWarning)
    end

    local assistSpawn = Targeting.GetAutoTarget()

    if Config:GetSetting('DisplayManualTarget') and (not assistSpawn or not assistSpawn() or assistSpawn.ID() == 0) then
        assistSpawn = mq.TLO.Target
    end

    ImGui.Text("Auto Target: ")
    ImGui.SameLine()
    if not assistSpawn or assistSpawn.ID() == 0 then
        ImGui.Text("None")
        Ui.RenderProgressBar(0, -1, 25)
        ImGui.Dummy(32, 16)
    else
        local pctHPs = assistSpawn.PctHPs() or 0
        if not pctHPs then pctHPs = 0 end
        local ratioHPs = pctHPs / 100
        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 1 - ratioHPs, ratioHPs, 0.2, 0.7)
        if math.floor(assistSpawn.Distance() or 0) >= 350 then
            ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.AssistSpawnFarColor)
        else
            ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.AssistSpawnCloseColor)
        end
        ImGui.Text(string.format("%s (%s) [%d %s] HP: %d%% Dist: %d", assistSpawn.CleanName() or "",
            assistSpawn.ID() or 0, assistSpawn.Level() or 0,
            assistSpawn.Class.ShortName() or "N/A", assistSpawn.PctHPs() or 0, assistSpawn.Distance() or 0))
        if Globals.AutoTargetIsNamed then
            ImGui.SameLine()
            ImGui.TextColored(IM_COL32(52, 200, 52, 255),
                string.format("**Named**"))
        end
        if assistSpawn.ID() == Globals.ForceTargetID then
            ImGui.SameLine()
            ImGui.TextColored(IM_COL32(52, 200, 200, 255),
                string.format("**ForcedTarget**"))
        end
        if Globals.LastBurnCheck and assistSpawn.ID() > 0 then
            ImGui.SameLine()
            ImGui.TextColored(IM_COL32(200, math.floor(Globals.GetTimeSeconds() % 2) == 1 and 52 or 200, 52, 255),
                string.format("**BURNING**"))
        end
        Ui.RenderProgressBar(ratioHPs, -1, 25)
        ImGui.PopStyleColor(2)
        ImGui.PushStyleColor(ImGuiCol.Button, Globals.Constants.Colors.BurnFlashColorOne)
        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, Globals.Constants.Colors.BurnFlashColorTwo)
        local burnLabel = (Targeting.ForceBurnTargetID > 0 and Targeting.ForceBurnTargetID == mq.TLO.Target.ID()) and " FORCE BURN ACTIVATED " or " FORCE BURN THIS TARGET! "
        if ImGui.SmallButton(Icons.FA_FIRE .. burnLabel .. Icons.FA_FIRE) then
            Comms.SendAllPeersDoCmd(true, true, "/squelch /rgl burnnow %d", assistSpawn.ID())
        end
        ImGui.PopStyleColor(2)
    end
end

function StandardUI:RenderWindowControls()
    --local draw_list = ImGui.GetWindowDrawList()
    local position = ImGui.GetCursorPosVec()
    local smallButtonSize = 32

    local windowControlPos = ImVec2(ImGui.GetWindowWidth() - (smallButtonSize * 3), smallButtonSize)
    ImGui.SetCursorPos(windowControlPos)

    if ImGui.SmallButton(Icons.MD_SETTINGS) then
        Config:ClearAllHighlightedModules()
        Config:SetSetting('EnableOptionsUI', not Config:GetSetting('EnableOptionsUI'))
    end
    Ui.Tooltip("Open the RGMercs Options Window")
    ImGui.SameLine()

    if ImGui.SmallButton((Config:GetSetting('MainWindowLocked') or false) and Icons.FA_LOCK or Icons.FA_UNLOCK) then
        Config:SetSetting('MainWindowLocked', not Config:GetSetting('MainWindowLocked'))
    end
    Ui.Tooltip("Lock the Main Window")
    ImGui.SameLine()

    if ImGui.SmallButton(Icons.FA_WINDOW_MINIMIZE) then
        Globals.Minimized = true
    end
    Ui.Tooltip("Activate Mini Mode")

    ImGui.SetCursorPos(position)
end

function StandardUI:RenderMainWindow(imgui_style, openGUI)
    local shouldDrawGUI = true

    if not Globals.Minimized then
        local flags = ImGuiWindowFlags.None

        if Config:GetSetting('MainWindowLocked') then
            flags = bit32.bor(flags, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoResize)
        end

        openGUI, shouldDrawGUI = ImGui.Begin(('RGMercs%s###rgmercsui'):format(Globals.PauseMain and " [Paused]" or ""), openGUI, flags)

        ImGui.PushID("##RGMercsUI_" .. Globals.CurLoadedChar)

        if shouldDrawGUI then
            local imgDisplayed = Globals.LastBurnCheck and ImageUI.burnImg or ImageUI.derpImg
            Ui.RenderLogo(imgDisplayed:GetTextureID())
            ImGui.SameLine()
            local titlePos = ImGui.GetCursorPosVec()
            Ui.RenderText("RGMercs %s [Build: %s]",
                Config._version,
                CommitVersion.version or "None"
            )
            titlePos = ImVec2(titlePos.x, titlePos.y + ImGui.GetTextLineHeightWithSpacing())
            ImGui.SetCursorPos(titlePos)

            Ui.RenderText("Class Config: ")
            ImGui.SameLine()

            local version = Modules:ExecModule("Class", "GetVersionString")
            Ui.RenderHyperText(version, IM_COL32(255, 255, 255, 255), IM_COL32(52, 52, 255, 255),
                function()
                    OptionsUI:OpenAndSetSearchFilter("what is the current status of this class config", "Commands/FAQ")
                end)
            Ui.Tooltip("Click to display notes about the status of this class config.")
            ImGui.SameLine()
            if ImGui.SmallButton(Icons.MD_INFO_OUTLINE) then
                OptionsUI:OpenAndSetSearchFilter("what is the current status of this class config", "Commands/FAQ")
            end
            Ui.Tooltip("Click to display notes about the status of this class config.")

            titlePos = ImVec2(titlePos.x, titlePos.y + ImGui.GetTextLineHeightWithSpacing())
            ImGui.SetCursorPos(titlePos)

            Ui.RenderText("Author(s): %s", Modules:ExecModule("Class", "GetAuthorString"))

            ImGui.NewLine()

            self:RenderWindowControls()

            if not Globals.PauseMain then
                ImGui.PushStyleColor(ImGuiCol.Button, Globals.Constants.Colors.MainButtonUnpausedColor)
            else
                ImGui.PushStyleColor(ImGuiCol.Button, Globals.Constants.Colors.MainButtonPausedColor)
            end

            local pauseLabel = Globals.PauseMain and "PAUSED" or "Running"
            if Globals.BackOffFlag then
                pauseLabel = pauseLabel .. " [Backoff]"
            end

            if ImGui.Button(pauseLabel, (ImGui.GetWindowWidth() - ImGui.GetCursorPosX() - (ImGui.GetScrollMaxY() == 0 and 0 or imgui_style.ScrollbarSize) - imgui_style.WindowPadding.x), 40) then
                Globals.PauseMain = not Globals.PauseMain
            end
            ImGui.PopStyleColor()

            self:RenderTarget()

            ImGui.NewLine()
            ImGui.Separator()

            if ImGui.BeginTabBar("RGMercsTabs", ImGuiTabBarFlags.Reorderable) then
                ImGui.SetItemDefaultFocus()
                if ImGui.BeginTabItem("RGMercsMain") then
                    ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, ImVec2(0, 0))

                    ImGui.Text("Current State: ")
                    ImGui.SameLine()
                    Ui.RenderColoredText(Globals.CurrentState == "Combat" and Globals.Constants.Colors.MainCombatColor or Globals.Constants.Colors.MainDowntimeColor,
                        "%s", Globals.CurrentState or "N/A")
                    ImGui.Text("Hater Count: ")
                    ImGui.SameLine()
                    Ui.RenderColoredText((Targeting.GetXTHaterCount() or 0) > 0 and Globals.Constants.Colors.ConditionMidColor or Globals.Constants.Colors.ConditionPassColor, "%d",
                        Targeting.GetXTHaterCount() or 0)
                    ImGui.Text("MA: ")
                    ImGui.SameLine()

                    if Config.TempSettings.AssistWarning and Core.IAmMA() then
                        Ui.RenderColoredText(Globals.Constants.Colors.ConditionMidColor, "%s (Fallback Mode)", (Core.GetMainAssistSpawn().CleanName() or "None"))
                    else
                        Ui.RenderColoredText(Globals.Constants.Colors.ConditionPassColor, "%s", (Core.GetMainAssistSpawn().CleanName() or "None"))
                    end

                    ImGui.Text("Stuck To: ")
                    ImGui.SameLine()
                    Ui.RenderColoredText(mq.TLO.Stick.Active() and ImVec4(Ui.GetConColorBySpawn(mq.TLO.Spawn(mq.TLO.Stick.StickTarget()))) or ImVec4(1, 1, 1, 1),
                        "%s ", (mq.TLO.Stick.Active() and (mq.TLO.Stick.StickTargetName() or "None") or "None"))
                    ImGui.SameLine()
                    ImGui.Text("[")
                    ImGui.SameLine()
                    Ui.RenderColoredText(mq.TLO.Stick.Active() and Globals.Constants.Colors.ConditionPassColor or Globals.Constants.Colors.ConditionDisabledColor,
                        "%s", (mq.TLO.Stick.Active() and Movement:GetLastStickCmd() or "N/A"))
                    ImGui.SameLine()
                    ImGui.Text("] ")
                    ImGui.SameLine()
                    ImGui.Text("<")
                    ImGui.SameLine()
                    Ui.RenderColoredText(Globals.Constants.Colors.LightBlue, "%s", Movement:GetTimeSinceLastStick() or "0s")
                    ImGui.SameLine()
                    ImGui.Text(">")

                    ImGui.Text("Last Nav: ")
                    ImGui.SameLine()
                    Ui.RenderColoredText(Globals.Constants.Colors.ConditionPassColor, "%s ", Movement:GetLastNavCmd() or "N/A")
                    ImGui.SameLine()
                    ImGui.Text("<")
                    ImGui.SameLine()
                    Ui.RenderColoredText(Globals.Constants.Colors.LightBlue, "%s", Movement:GetTimeSinceLastNav() or "0s")
                    ImGui.SameLine()
                    ImGui.Text(">")
                    ImGui.PopStyleVar(1)

                    if ImGui.CollapsingHeader("Assist List") then
                        ImGui.Indent()
                        Ui.RenderAssistList()
                        ImGui.Unindent()
                    end

                    if not Config:GetSetting('PopOutForceTarget') then
                        if ImGui.CollapsingHeader("Force Target") then
                            ImGui.Indent()
                            Ui.RenderForceTargetList(true)
                            ImGui.Unindent()
                        end
                    end

                    if not Config:GetSetting('PopOutMercsStatus') then
                        if ImGui.CollapsingHeader("Mercs Status") then
                            ImGui.Indent()
                            Ui.RenderMercsStatus(true)
                            ImGui.Unindent()
                        end
                    end
                    ImGui.EndTabItem()
                end

                self:renderModulesTabs()

                ImGui.EndTabBar();
            end

            ImGui.Separator()
            if not Config:GetSetting('PopOutConsole') then
                if ImGui.CollapsingHeader("Console") then
                    ConsoleUI:DrawConsole(true)
                end
            end
        end

        ImGui.PopID()

        ImGui.End()
    end

    return openGUI
end

return StandardUI
