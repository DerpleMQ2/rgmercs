local mq           = require('mq')
local ImGui        = require('ImGui')
local Config       = require('utils.config')
local Ui           = require('utils.ui')
local Icons        = require('mq.ICONS')
local ImageUI      = require('ui.images')
local Core         = require('utils.core')
local Targeting    = require('utils.targeting')
local Casting      = require('utils.casting')
local Modules      = require('utils.modules')
local ConsoleUI    = require('ui.console')
local GitCommit    = require('extras.version')

local StandardUI   = { _version = '1.0', _name = "StandardUI", _author = 'Derple', }
StandardUI.__index = StandardUI

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
        ImGui.TextColored(IM_COL32(200, math.floor(os.clock() % 2) == 1 and 52 or 200, 52, 255), Config.TempSettings.AssistWarning)
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
            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 0.0, 1)
        else
            ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
        end
        ImGui.Text(string.format("%s (%s) [%d %s] HP: %d%% Dist: %d", assistSpawn.CleanName() or "",
            assistSpawn.ID() or 0, assistSpawn.Level() or 0,
            assistSpawn.Class.ShortName() or "N/A", assistSpawn.PctHPs() or 0, assistSpawn.Distance() or 0))
        if Targeting.IsNamed(assistSpawn) then
            ImGui.SameLine()
            ImGui.TextColored(IM_COL32(52, 200, 52, 255),
                string.format("**Named**"))
        end
        if assistSpawn.ID() == Config.Globals.ForceTargetID then
            ImGui.SameLine()
            ImGui.TextColored(IM_COL32(52, 200, 200, 255),
                string.format("**ForcedTarget**"))
        end
        if Casting.LastBurnCheck and assistSpawn.ID() > 0 then
            ImGui.SameLine()
            ImGui.TextColored(IM_COL32(200, math.floor(os.clock() % 2) == 1 and 52 or 200, 52, 255),
                string.format("**BURNING**"))
        end
        Ui.RenderProgressBar(ratioHPs, -1, 25)
        ImGui.PopStyleColor(2)
        ImGui.PushStyleColor(ImGuiCol.Button, 0.6, 0.2, 0.01, 0.8)
        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.3, 0.1, 0.01, 1.0)
        local burnLabel = (Targeting.ForceBurnTargetID > 0 and Targeting.ForceBurnTargetID == mq.TLO.Target.ID()) and " FORCE BURN ACTIVATED " or " FORCE BURN THIS TARGET! "
        if ImGui.SmallButton(Icons.FA_FIRE .. burnLabel .. Icons.FA_FIRE) then
            Core.DoCmd("/squelch /dgga /rgl burnnow %d", assistSpawn.ID())
        end
        ImGui.PopStyleColor(2)
    end
end

function StandardUI:RenderWindowControls()
    --local draw_list = ImGui.GetWindowDrawList()
    local position = ImGui.GetCursorPosVec()
    local smallButtonSize = 32

    local windowControlPos = ImVec2(ImGui.GetWindowWidth() - (smallButtonSize * 2), smallButtonSize)
    ImGui.SetCursorPos(windowControlPos)

    if ImGui.SmallButton((Config:GetSetting('MainWindowLocked') or false) and Icons.FA_LOCK or Icons.FA_UNLOCK) then
        Config:SetSetting('MainWindowLocked', not Config:GetSetting('MainWindowLocked'))
    end

    ImGui.SameLine()
    if ImGui.SmallButton(Icons.FA_WINDOW_MINIMIZE) then
        Config.Globals.Minimized = true
    end
    Ui.Tooltip("Minimize Main Window")

    ImGui.SetCursorPos(position)
end

function StandardUI:RenderMainWindow(imgui_style, curState, openGUI)
    local shouldDrawGUI = true

    if not Config.Globals.Minimized then
        local flags = ImGuiWindowFlags.None

        if Config:GetSetting('MainWindowLocked') then
            flags = bit32.bor(flags, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoResize)
        end

        openGUI, shouldDrawGUI = ImGui.Begin(('RGMercs%s###rgmercsui'):format(Config.Globals.PauseMain and " [Paused]" or ""), openGUI, flags)

        ImGui.PushID("##RGMercsUI_" .. Config.Globals.CurLoadedChar)

        if shouldDrawGUI then
            local pressed
            local imgDisplayed = Casting.LastBurnCheck and ImageUI.burnImg or ImageUI.derpImg
            ImGui.Image(imgDisplayed:GetTextureID(), ImVec2(60, 60))
            ImGui.SameLine()
            ImGui.Text(string.format("RGMercs %s [%s]\nClass Config: %s\nAuthor(s): %s",
                Config._version,
                GitCommit.commitId or "None",
                Modules:ExecModule("Class", "GetVersionString"),
                Modules:ExecModule("Class", "GetAuthorString"))
            )

            self:RenderWindowControls()

            if not Config.Globals.PauseMain then
                ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.7, 0.3, 1)
            else
                ImGui.PushStyleColor(ImGuiCol.Button, 0.7, 0.3, 0.3, 1)
            end

            local pauseLabel = Config.Globals.PauseMain and "PAUSED" or "Running"
            if Config.Globals.BackOffFlag then
                pauseLabel = pauseLabel .. " [Backoff]"
            end

            if ImGui.Button(pauseLabel, (ImGui.GetWindowWidth() - ImGui.GetCursorPosX() - (ImGui.GetScrollMaxY() == 0 and 0 or imgui_style.ScrollbarSize) - imgui_style.WindowPadding.x), 40) then
                Config.Globals.PauseMain = not Config.Globals.PauseMain
            end
            ImGui.PopStyleColor()

            self:RenderTarget()

            ImGui.NewLine()
            ImGui.Separator()

            if ImGui.BeginTabBar("RGMercsTabs", ImGuiTabBarFlags.Reorderable) then
                ImGui.SetItemDefaultFocus()
                if ImGui.BeginTabItem("RGMercsMain") then
                    ImGui.Text("Current State: " .. curState)
                    ImGui.Text("Hater Count: " .. tostring(Targeting.GetXTHaterCount()))
                    if Config.TempSettings.AssistWarning and Core.IAmMA() then
                        ImGui.Text("MA: %s (Fallback Mode)", (Core.GetMainAssistSpawn().CleanName() or "None"))
                    else
                        ImGui.Text("MA: %s", (Core.GetMainAssistSpawn().CleanName() or "None"))
                    end
                    ImGui.Text("Stuck To: " ..
                        (mq.TLO.Stick.Active() and (mq.TLO.Stick.StickTargetName() or "None") or "None"))
                    if ImGui.CollapsingHeader("Assist List") then
                        ImGui.Indent()
                        Ui.RenderAssistList()
                        ImGui.Unindent()
                    end

                    if Core.IAmMA() and not Config:GetSetting('PopOutForceTarget') then
                        if ImGui.CollapsingHeader("Force Target") then
                            ImGui.Indent()
                            Ui.RenderForceTargetList(true)
                            ImGui.Unindent()
                        end
                    end

                    ImGui.Separator()

                    if ImGui.CollapsingHeader("Config Options") then
                        ImGui.Indent()

                        if ImGui.CollapsingHeader(string.format("%s: Config Options", "Main"), bit32.bor(ImGuiTreeNodeFlags.DefaultOpen, ImGuiTreeNodeFlags.Leaf)) then
                            _, _ = Ui.RenderModuleSettings("Core", Config.DefaultConfig, Config.SettingCategories, false, true)
                        end
                        if Config:GetSetting('ShowAllOptionsMain') then
                            if Config.Globals.SubmodulesLoaded then
                                local submoduleSettings = Config:GetAllModuleSettings()
                                local submoduleDefaults = Config:GetAllModuleDefaultSettings()
                                local submoduleCategories = Config:GetAllModuleSettingCategories()

                                for n, s in pairs(submoduleSettings) do
                                    if n ~= "Debug" and n ~= "Core" and Modules:ExecModule(n, "ShouldRender") then
                                        ImGui.PushID(n .. "_config_hdr")
                                        if s and submoduleDefaults[n] and submoduleCategories[n] then
                                            if ImGui.CollapsingHeader(string.format("%s: Config Options", n), bit32.bor(ImGuiTreeNodeFlags.DefaultOpen, ImGuiTreeNodeFlags.Leaf)) then
                                                _, _ = Ui.RenderModuleSettings(n, submoduleDefaults[n], submoduleCategories[n], true)
                                            end
                                        end
                                        ImGui.PopID()
                                    end
                                end
                            end
                        end
                        ImGui.Unindent()
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
