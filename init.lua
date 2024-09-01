local mq        = require('mq')
local ImGui     = require('ImGui')
local GitCommit = require('extras.version')
DanNet          = require('lib.dannet.helpers')

RGMercsBinds    = require('utils.rgmercs_binds')
RGMercsEvents   = require('utils.rgmercs_events')
RGMercsLogger   = require("utils.rgmercs_logger")
RGMercConfig    = require('utils.rgmercs_config')
RGMercConfig:LoadSettings()

RGMercsConsole = nil

RGMercsLogger.set_log_level(RGMercConfig:GetSettings().LogLevel)
RGMercsLogger.set_log_to_file(RGMercConfig:GetSettings().LogToFile)

local RGMercUtils = require("utils.rgmercs_utils")

RGMercNameds      = require("utils.rgmercs_named")

-- Initialize class-based moduldes
RGMercModules     = require("utils.rgmercs_modules").load()

require('utils.rgmercs_datatypes')

-- ImGui Variables
local openGUI       = true
local shouldDrawGUI = true
local notifyZoning  = true
local curState      = "Downtime"

-- Icon Rendering
local derpImg       = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/derpdog_60.png")

-- Constants

-- UI --
local function renderModulesTabs()
    if not RGMercConfig:SettingsLoaded() then return end

    for _, name in ipairs(RGMercModules:GetModuleOrderedNames()) do
        if RGMercModules:ExecModule(name, "ShouldRender") then
            if ImGui.BeginTabItem(name) then
                RGMercModules:ExecModule(name, "Render")
                ImGui.EndTabItem()
            end
        end
    end
end

local function Alive()
    return mq.TLO.NearestSpawn('pc')() ~= nil
end

local function GetTheme()
    return RGMercModules:ExecModule("Class", "GetTheme")
end

local function RenderTarget()
    ImGui.Text("Auto Target: ")
    ImGui.SameLine()
    if RGMercConfig.Globals.AutoTargetID == 0 then
        ImGui.Text("None")
        RGMercUtils.RenderProgressBar(0, -1, 25)
    else
        local assistSpawn = RGMercUtils.GetAutoTarget()
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
        RGMercUtils.RenderProgressBar(ratioHPs, -1, 25)
        ImGui.PopStyleColor(2)
    end
end

---@return number
local function GetMainOpacity()
    return tonumber(RGMercConfig:GetSettings().BgOpacity / 100) or 1.0
end

local function RGMercsGUI()
    local theme = GetTheme()
    local themeColorPop = 0
    local themeStylePop = 0

    if RGMercsConsole == nil then
        RGMercsConsole = ImGui.ConsoleWidget.new("##RGMercsConsole")
        RGMercsConsole.maxBufferLines = 100
        RGMercsConsole.autoScroll = true
        if RGMercsConsole.opacity then
            RGMercsConsole.opacity = GetMainOpacity()
        end
    end

    if mq.TLO.MacroQuest.GameState() == "CHARSELECT" then
        openGUI = false
        return
    end

    if openGUI and Alive() then
        if theme ~= nil then
            for _, t in pairs(theme) do
                if t.color then
                    ImGui.PushStyleColor(t.element, t.color.r, t.color.g, t.color.b, t.color.a)
                    themeColorPop = themeColorPop + 1
                elseif t.value then
                    ImGui.PushStyleVar(t.element, t.value)
                    themeStylePop = themeStylePop + 1
                end
            end
        end

        local imGuiStyle = ImGui.GetStyle()

        ImGui.PushStyleVar(ImGuiStyleVar.Alpha, GetMainOpacity()) -- Main window opacity.
        ImGui.PushStyleVar(ImGuiStyleVar.ScrollbarRounding, RGMercConfig:GetSettings().ScrollBarRounding)
        ImGui.PushStyleVar(ImGuiStyleVar.FrameRounding, RGMercConfig:GetSettings().FrameEdgeRounding)
        if not RGMercConfig.Globals.Minimized then
            openGUI, shouldDrawGUI = ImGui.Begin(('RGMercs%s###rgmercsui'):format(RGMercConfig.Globals.PauseMain and " [Paused]" or ""), openGUI)
        else
            openGUI, shouldDrawGUI = ImGui.Begin(('RGMercsMin###rgmercsuiMin'), openGUI,
                bit32.bor(ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoTitleBar))
        end
        ImGui.PushID("##RGMercsUI_" .. RGMercConfig.Globals.CurLoadedChar)

        if shouldDrawGUI and not RGMercConfig.Globals.Minimized then
            local pressed
            ImGui.Image(derpImg:GetTextureID(), ImVec2(60, 60))
            ImGui.SameLine()
            ImGui.Text(string.format("RGMercs [%s/%s] by: %s\nLoaded Char: %s\nClass Config: %s\nBuild: %s",
                RGMercConfig._version, RGMercConfig._subVersion, RGMercConfig._author,
                RGMercConfig.Globals.CurLoadedChar,
                RGMercModules:ExecModule("Class", "GetVersionString"),
                GitCommit.commitId or "None"))
            if ImGui.SmallButton('Create Custom Config') then
                RGMercModules:ExecModule("Class", "WriteCustomConfig")
            end
            ImGui.SameLine()
            if ImGui.SmallButton('Minimize') then
                RGMercConfig.Globals.Minimized = true
            end
            if not RGMercConfig.Globals.PauseMain then
                ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.7, 0.3, 1)
            else
                ImGui.PushStyleColor(ImGuiCol.Button, 0.7, 0.3, 0.3, 1)
            end

            local pauseLabel = RGMercConfig.Globals.PauseMain and "PAUSED" or "Running"
            if RGMercConfig.Globals.BackOffFlag then
                pauseLabel = pauseLabel .. " [Backoff]"
            end

            if ImGui.Button(pauseLabel, (ImGui.GetWindowWidth() - ImGui.GetCursorPosX() - (ImGui.GetScrollMaxY() == 0 and 0 or imGuiStyle.ScrollbarSize) - imGuiStyle.WindowPadding.x), 40) then
                RGMercConfig.Globals.PauseMain = not RGMercConfig.Globals.PauseMain
            end
            ImGui.PopStyleColor()

            RenderTarget()

            ImGui.NewLine()
            ImGui.Separator()

            if ImGui.BeginTabBar("RGMercsTabs", ImGuiTabBarFlags.Reorderable) then
                ImGui.SetItemDefaultFocus()
                if ImGui.BeginTabItem("RGMercsMain") then
                    ImGui.Text("Current State: " .. curState)
                    ImGui.Text("Hater Count: " .. tostring(RGMercUtils.GetXTHaterCount()))

                    -- .. tostring(RGMercConfig.Globals.AutoTargetID))
                    ImGui.Text(string.format("MA: %-25s", (RGMercUtils.GetMainAssistSpawn().CleanName() or "None")))
                    if mq.TLO.Target.ID() > 0 and RGMercUtils.TargetIsType("pc") and RGMercConfig.Globals.MainAssist ~= mq.TLO.Target.ID() then
                        ImGui.SameLine()
                        if ImGui.SmallButton(string.format("Set MA to %s", RGMercUtils.GetTargetCleanName())) then
                            RGMercConfig.Globals.MainAssist = mq.TLO.Target.CleanName()
                            DanNet.unobserve(RGMercConfig.Globals.MainAssist, "Target.ID")
                        end
                    end
                    ImGui.Text("Stuck To: " ..
                        (mq.TLO.Stick.Active() and (mq.TLO.Stick.StickTargetName() or "None") or "None"))
                    if ImGui.CollapsingHeader("Config Options") then
                        ImGui.Indent()
                        if ImGui.CollapsingHeader(string.format("%s: Config Options", "Main"), bit32.bor(ImGuiTreeNodeFlags.DefaultOpen, ImGuiTreeNodeFlags.Leaf)) then
                            local settingsRef = RGMercConfig:GetSettings()
                            settingsRef, pressed, _ = RGMercUtils.RenderSettings(settingsRef, RGMercConfig.DefaultConfig,
                                RGMercConfig.DefaultCategories)
                            if pressed then
                                RGMercConfig:SaveSettings(false)
                            end
                        end

                        if RGMercConfig.Globals.SubmodulesLoaded then
                            local submoduleSettings = RGMercModules:ExecAll("GetSettings")
                            local submoduleDefaults = RGMercModules:ExecAll("GetDefaultSettings")
                            local submoduleCategories = RGMercModules:ExecAll("GetSettingCategories")
                            for n, s in pairs(submoduleSettings) do
                                if RGMercModules:ExecModule(n, "ShouldRender") then
                                    ImGui.PushID(n .. "_config_hdr")
                                    if s and submoduleDefaults[n] and submoduleCategories[n] then
                                        if ImGui.CollapsingHeader(string.format("%s: Config Options", n), bit32.bor(ImGuiTreeNodeFlags.DefaultOpen, ImGuiTreeNodeFlags.Leaf)) then
                                            s, pressed, _ = RGMercUtils.RenderSettings(s, submoduleDefaults[n],
                                                submoduleCategories[n], true)
                                            if pressed then
                                                RGMercModules:ExecModule(n, "SaveSettings", true)
                                            end
                                        end
                                    end
                                    ImGui.PopID()
                                end
                            end
                        end
                        ImGui.Unindent()
                    end

                    if ImGui.CollapsingHeader("Outside Assist List") then
                        RGMercUtils.RenderOAList()
                    end
                    if ImGui.CollapsingHeader("Zone Named") then
                        RGMercUtils.RenderZoneNamed()
                    end

                    ImGui.EndTabItem()
                end

                renderModulesTabs()


                ImGui.EndTabBar();
            end

            ImGui.NewLine()
            ImGui.NewLine()
            ImGui.Separator()

            if RGMercsConsole then
                local changed
                RGMercConfig:GetSettings().LogLevel, changed = ImGui.Combo("Debug Level",
                    RGMercConfig:GetSettings().LogLevel, RGMercConfig.Constants.LogLevels,
                    #RGMercConfig.Constants.LogLevels)

                if changed then
                    RGMercConfig:SaveSettings(false)
                end

                ImGui.SameLine()
                RGMercConfig:GetSettings().LogToFile, changed = RGMercUtils.RenderOptionToggle("##log_to_file",
                    "Log to File", RGMercConfig:GetSettings().LogToFile)

                if changed then
                    RGMercConfig:SaveSettings(false)
                end

                if ImGui.CollapsingHeader("RGMercs Output", ImGuiTreeNodeFlags.DefaultOpen) then
                    local cur_x, cur_y = ImGui.GetCursorPos()
                    local contentSizeX, contentSizeY = ImGui.GetContentRegionAvail()
                    if not RGMercsConsole.opacity then
                        local scroll = ImGui.GetScrollY()
                        ImGui.Dummy(contentSizeX, 410)
                        ImGui.SetCursorPos(cur_x, cur_y)
                        RGMercsConsole:Render(ImVec2(contentSizeX, math.min(400, contentSizeY + scroll)))
                    else
                        RGMercsConsole:Render(ImVec2(contentSizeX, math.max(200, (contentSizeY - 10))))
                    end
                    ImGui.Separator()
                end
            end
        elseif shouldDrawGUI and RGMercConfig.Globals.Minimized then
            if RGMercConfig.Globals.PauseMain then
                if ImGui.ImageButton('RGMercsButton', derpImg:GetTextureID(), ImVec2(30, 30), ImVec2(0.0, 0.0), ImVec2(1, 1), ImVec4(0, 0, 0, 0), ImVec4(1, 0, 0, 1)) then
                    RGMercConfig.Globals.Minimized = false
                end
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip("RGMercs is Paused")
                end
            else
                if ImGui.ImageButton('RGMercsButton', derpImg:GetTextureID(), ImVec2(30, 30)) then
                    RGMercConfig.Globals.Minimized = false
                end
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip("RGMercs is Running")
                end
            end
            if ImGui.BeginPopupContextWindow() then
                local pauseLabel = RGMercConfig.Globals.PauseMain and "Resume" or "Pause"
                if ImGui.MenuItem(pauseLabel) then
                    RGMercConfig.Globals.PauseMain = not RGMercConfig.Globals.PauseMain
                end
                ImGui.EndPopup()
            end
        end

        ImGui.PopID()
        ImGui.PopStyleVar(3)
        if ImGui.IsWindowFocused(ImGuiFocusedFlags.RootAndChildWindows) then
            if ImGui.IsKeyPressed(ImGuiKey.Escape) and RGMercUtils.GetSetting("EscapeMinimizes") then
                RGMercConfig.Globals.Minimized = true
            end
        end
        if themeColorPop > 0 then
            ImGui.PopStyleColor(themeColorPop)
        end
        if themeStylePop > 0 then
            ImGui.PopStyleVar(themeStylePop)
        end
        ImGui.End()
    end
end

mq.imgui.init('RGMercsUI', RGMercsGUI)

-- End UI --
local unloadedPlugins = {}

local function RGInit(...)
    RGMercUtils.CheckPlugins({
        "MQ2Rez",
        "MQ2AdvPath",
        "MQ2MoveUtils",
        "MQ2Nav",
        "MQ2DanNet", })

    unloadedPlugins = RGMercUtils.UnCheckPlugins({ "MQ2Melee", "MQ2Twist", })

    local args = { ..., }
    -- check mini argument before loading other modules so it minimizes as soon as possible.
    if args and #args > 0 then
        RGMercsLogger.log_info("Arguments passed to RGMercs: %s", table.concat(args, ", "))
        for _, v in ipairs(args) do
            if v == "mini" then
                RGMercConfig.Globals.Minimized = true
                break
            end
        end
    end
    -- complex objects are passed by reference so we can just use these without having to pass them back in for saving.
    RGMercModules:ExecAll("Init")
    RGMercConfig.Globals.SubmodulesLoaded = true
    RGMercConfig:UpdateCommandHandlers()

    local mainAssist = mq.TLO.Target.CleanName() or ""

    if mainAssist:len() == 0 and mq.TLO.Group() then
        mainAssist = mq.TLO.Group.MainAssist() or ""
    end

    for k, v in ipairs(RGMercConfig.Constants.ExpansionIDToName) do
        RGMercsLogger.log_debug("\ayExpansion \at%-22s\ao[\am%02d\ao]: %s", v, k,
            RGMercUtils.HaveExpansion(v) and "\agEnabled" or "\arDisabled")
    end

    -- TODO: Can turn this into an options parser later.
    if args and #args > 0 then
        for _, v in ipairs(args) do
            if v ~= "mini" then
                mainAssist = v
                break
            end
        end
    end

    if (not mainAssist or mainAssist == "") and mq.TLO.Group.Members() > 0 then
        mainAssist = mq.TLO.Group.MainAssist.DisplayName()
    end

    if not mainAssist or mainAssist == "" then
        mainAssist = mq.TLO.Me.CleanName()
    end

    RGMercUtils.DoCmd("/squelch /rez accept on")
    RGMercUtils.DoCmd("/squelch /rez pct 90")

    if mq.TLO.Plugin("MQ2DanNet")() then
        RGMercUtils.DoCmd("/squelch /dnet commandecho off")
    end

    RGMercUtils.DoCmd("/stick set breakontarget on")

    -- TODO: Chat Begs

    if (mq.TLO.Macro.Name() or ""):find("RGMERC") then
        RGMercUtils.DoCmd("/macro end")
    end

    -- RGMercUtils.PrintGroupMessage("Pausing the CWTN Plugin on this host if it exists! (/%s pause on)",
    --     mq.TLO.Me.Class.ShortName())
    RGMercUtils.DoCmd("/squelch /docommand /%s pause on", mq.TLO.Me.Class.ShortName())

    if RGMercUtils.CanUseAA("Companion's Discipline") then
        RGMercUtils.DoCmd("/pet ghold on")
    else
        RGMercUtils.DoCmd("/pet hold on")
    end

    if mq.TLO.Cursor() and mq.TLO.Cursor.ID() > 0 then
        RGMercsLogger.log_info("Sending Item(%s) on Cursor to Bag", mq.TLO.Cursor())
        RGMercUtils.DoCmd("/autoinventory")
    end

    RGMercUtils.WelcomeMsg()

    if mainAssist:len() > 0 then
        RGMercConfig.Globals.MainAssist = mainAssist
        DanNet.unobserve(RGMercConfig.Globals.MainAssist, "Target.ID")
        RGMercUtils.PopUp("Targetting %s for Main Assist", RGMercConfig.Globals.MainAssist)
        RGMercUtils.SetTarget(RGMercUtils.GetMainAssistId())
        RGMercsLogger.log_info("\aw Assisting \ay >> \ag %s \ay << \aw at \ag %d%%", RGMercConfig.Globals.MainAssist,
            RGMercUtils.GetSetting('AutoAssistAt'))
    end

    if RGMercUtils.GetGroupMainAssistName() ~= mainAssist then
        RGMercUtils.PopUp(string.format(
            "Assisting: %s NOTICE: Group MainAssist [%s] != Your Assist Target [%s]. Is This On Purpose?", mainAssist,
            RGMercUtils.GetGroupMainAssistName(), mainAssist))
    end

    -- store initial positioning data.
    RGMercConfig:StoreLastMove()
end

local function Main()
    if mq.TLO.Zone.ID() ~= RGMercConfig.Globals.CurZoneId then
        if notifyZoning then
            RGMercModules:ExecAll("OnZone")
            notifyZoning = false
        end
        mq.delay(100)
        RGMercConfig.Globals.CurZoneId = mq.TLO.Zone.ID()
        return
    end

    notifyZoning = true

    if mq.TLO.Me.NumGems() ~= RGMercUtils.UseGem then
        -- sometimes this can get out of sync.
        RGMercUtils.UseGem = mq.TLO.Me.NumGems()
    end

    if RGMercConfig.Globals.PauseMain then
        mq.delay(100)
        mq.doevents()
        if RGMercUtils.GetSetting('RunMovePaused') then
            RGMercModules:ExecModule("Movement", "GiveTime", curState)
        end
        RGMercModules:ExecModule("Drag", "GiveTime", curState)
        --RGMercModules:ExecModule("Exp", "GiveTime", curState)
        return
    end

    -- sometimes nav gets interupted this will try to reset it.
    if RGMercConfig:GetTimeSinceLastMove() > 5 and mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() == 0 then
        RGMercUtils.DoCmd("/nav stop")
    end

    if RGMercUtils.GetXTHaterCount() > 0 then
        if curState == "Downtime" and mq.TLO.Me.Sitting() then
            -- if switching into combat state stand up.
            mq.TLO.Me.Stand()
        end

        curState = "Combat"
        --if os.clock() - RGMercConfig.Globals.LastFaceTime > 6 then
        if RGMercUtils.GetSetting('FaceTarget') and not RGMercUtils.FacingTarget() and mq.TLO.Target.ID() ~= mq.TLO.Me.ID() and not mq.TLO.Me.Moving() then
            --RGMercConfig.Globals.LastFaceTime = os.clock()
            RGMercUtils.DoCmd("/squelch /face")
        end

        if RGMercUtils.GetSetting('DoMed') == 3 then
            RGMercUtils.AutoMed()
        end
    else
        curState = "Downtime"

        if RGMercUtils.GetSetting('DoMed') == 2 then
            RGMercUtils.AutoMed()
        end
    end

    if mq.TLO.MacroQuest.GameState() ~= "INGAME" then return end

    if (RGMercConfig.Globals.CurLoadedChar ~= mq.TLO.Me.DisplayName() or
            RGMercConfig.Globals.CurLoadedClass ~= mq.TLO.Me.Class.ShortName()) then
        RGMercConfig:LoadSettings()
        RGMercModules:ExecAll("LoadSettings")
    end

    RGMercConfig:StoreLastMove()

    if mq.TLO.Me.Hovering() then RGMercUtils.HandleDeath() end

    RGMercUtils.SetControlToon()

    if RGMercUtils.FindTargetCheck() then
        -- This will find a valid target and set it to : RGMercConfig.Globals.AutoTargetID
        RGMercUtils.FindTarget(RGMercUtils.OkToEngagePreValidateId)
    end

    if RGMercUtils.OkToEngage(RGMercConfig.Globals.AutoTargetID) then
        RGMercUtils.EngageTarget(RGMercConfig.Globals.AutoTargetID)
    else
        if RGMercUtils.GetXTHaterCount(true) > 0 and RGMercUtils.GetTargetID() > 0 and not RGMercUtils.IsMezzing() and not RGMercUtils.IsCharming() then
            RGMercsLogger.log_debug("\ayClearing Target because we are not OkToEngage() and we are in combat!")
            RGMercUtils.ClearTarget()
        end
    end

    -- Handles state for when we're in combat
    if RGMercUtils.DoCombatActions() then
        -- IsHealing or IsMezzing should re-determine their target as this point because they may
        -- have switched off to mez or heal after the initial find target check and the target
        -- may have changed by this point.
        if not RGMercUtils.GetSetting('PriorityHealing') then
            if RGMercUtils.FindTargetCheck() and (not RGMercUtils.IsHealing() or not RGMercUtils.IsMezzing() or not RGMercUtils.IsCharming()) then
                RGMercUtils.FindTarget(RGMercUtils.OkToEngagePreValidateId)
            end
        end

        if ((os.clock() - RGMercConfig.Globals.LastPetCmd) > 2) then
            RGMercConfig.Globals.LastPetCmd = os.clock()
            if ((RGMercUtils.GetSetting('DoPet') or RGMercUtils.GetSetting('CharmOn')) and mq.TLO.Pet.ID() ~= 0) and (RGMercUtils.GetTargetPctHPs(RGMercUtils.GetAutoTarget()) <= RGMercUtils.GetSetting('PetEngagePct')) then
                RGMercUtils.PetAttack(RGMercConfig.Globals.AutoTargetID, true)
            end
        end

        if RGMercUtils.GetSetting('DoMercenary') then
            local merc = mq.TLO.Me.Mercenary

            if merc() and merc.ID() then
                if RGMercUtils.MercEngage() then
                    if merc.Class.ShortName():lower() == "war" and merc.Stance():lower() ~= "aggressive" then
                        RGMercUtils.DoCmd("/squelch /stance aggressive")
                    end

                    if merc.Class.ShortName():lower() ~= "war" and merc.Stance():lower() ~= "balanced" then
                        RGMercUtils.DoCmd("/squelch /stance balanced")
                    end

                    RGMercUtils.MercAssist()
                else
                    if merc.Class.ShortName():lower() ~= "clr" and merc.Stance():lower() ~= "passive" then
                        RGMercUtils.DoCmd("/squelch /stance passive")
                    end
                end
            end
        end
    end

    if RGMercUtils.DoCamp() then
        if RGMercUtils.GetSetting('DoMercenary') and mq.TLO.Me.Mercenary.ID() and (mq.TLO.Me.Mercenary.Class.ShortName() or "none"):lower() ~= "clr" and mq.TLO.Me.Mercenary.Stance():lower() ~= "passive" then
            RGMercUtils.DoCmd("/squelch /stance passive")
        end
    end

    if RGMercUtils.GetSetting('DoModRod') then
        RGMercUtils.ClickModRod()
    end

    if RGMercUtils.ShouldKillTargetReset() then
        RGMercConfig.Globals.AutoTargetID = 0
    end

    -- If target is not attackable then turn off attack
    local pcCheck = RGMercUtils.TargetIsType("pc") or
        (RGMercUtils.TargetIsType("pet") and RGMercUtils.TargetIsType("pc", mq.TLO.Target.Master))
    local mercCheck = RGMercUtils.TargetIsType("mercenary")
    if mq.TLO.Me.Combat() and (not mq.TLO.Target() or pcCheck or mercCheck) then
        RGMercsLogger.log_debug(
            "\ay[1] Target type check failed \aw[\atinCombat(%s) pcCheckFailed(%s) mercCheckFailed(%s)\aw]\ay - turning attack off!",
            RGMercUtils.BoolToColorString(mq.TLO.Me.Combat()), RGMercUtils.BoolToColorString(pcCheck),
            RGMercUtils.BoolToColorString(mercCheck))
        RGMercUtils.DoCmd("/attack off")
    end

    -- Revive our mercenary if they're dead and we're using a mercenary
    if RGMercUtils.GetSetting('DoMercenary') then
        if mq.TLO.Me.Mercenary.State():lower() == "dead" then
            if mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_SuspendButton").Text():lower() == "revive" then
                mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_SuspendButton").LeftMouseUp()
            end
        else
            if mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_AssistModeCheckbox").Checked() then
                mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_AssistModeCheckbox").LeftMouseUp()
            end
        end
    end

    RGMercModules:ExecAll("GiveTime", curState)

    mq.doevents()
    mq.delay(10)
end

-- Global Messaging callback
---@diagnostic disable-next-line: unused-local
local script_actor = RGMercUtils.Actors.register(function(message)
    local msg = message()
    if msg.from == RGMercConfig.Globals.CurLoadedChar then return end
    if msg.script ~= RGMercUtils.ScriptName then return end

    RGMercsLogger.log_verbose("\ayGot Event from(\am%s\ay) module(\at%s\ay) event(\at%s\ay)", msg.from,
        msg.module,
        msg.event)

    if msg.module then
        if msg.module == "main" then
            RGMercConfig:LoadSettings()
        else
            RGMercModules:ExecModule(msg.module, msg.event, msg.data)
        end
    end
end)

-- Binds

mq.bind("/rglua", RGMercsBinds.MainHandler)

RGInit(...)

while openGUI do
    Main()
    mq.doevents()
    mq.delay(10)
end

RGMercModules:ExecAll("Shutdown")
