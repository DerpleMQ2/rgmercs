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
local openGUI        = true
local shouldDrawGUI  = true
local notifyZoning   = true
local curState       = "Downtime"

-- Icon Rendering
local animItems      = mq.FindTextureAnimation("A_DragItem")
local animBox        = mq.FindTextureAnimation("A_RecessedBox")
local derpImg        = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/derpdog_60.png")

-- Constants
local ICON_WIDTH     = 40
local ICON_HEIGHT    = 40
local COUNT_X_OFFSET = 39
local COUNT_Y_OFFSET = 23
local EQ_ICON_OFFSET = 500

-- UI --
local function displayItemOnCursor()
    if mq.TLO.Cursor() then
        local cursor_item = mq.TLO.Cursor -- this will be an MQ item, so don't forget to use () on the members!

        local draw_list = ImGui.GetForegroundDrawList()
        local window_x, window_y = ImGui.GetWindowPos()
        local window_w, window_h = ImGui.GetWindowSize()
        local mouse_x, mouse_y = ImGui.GetMousePos()

        if mouse_x < window_x or mouse_x > window_x + window_w then return end
        if mouse_y < window_y or mouse_y > window_y + window_h then return end

        local icon_x = mouse_x + 10
        local icon_y = mouse_y + 10
        local stack_x = icon_x + COUNT_X_OFFSET + 10
        local stack_y = (icon_y + COUNT_Y_OFFSET)
        animItems:SetTextureCell(cursor_item.Icon() - EQ_ICON_OFFSET)
        draw_list:AddTextureAnimation(animItems, ImVec2(icon_x, icon_y), ImVec2(ICON_WIDTH, ICON_HEIGHT))
        if cursor_item.Stackable() then
            local text_size = ImGui.CalcTextSize(tostring(cursor_item.Stack()))
            draw_list:AddTextureAnimation(animBox, ImVec2(stack_x, stack_y), ImVec2(text_size, ImGui.GetTextLineHeight()))
            draw_list:AddText(ImVec2(stack_x, stack_y), IM_COL32(255, 255, 255, 255), tostring(cursor_item.Stack()))
        end
    end
end

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
        ImGui.Text(string.format("%s (%s) [%d %s] HP: %d%% Dist: %d", assistSpawn.CleanName() or "", assistSpawn.ID() or 0, assistSpawn.Level() or 0,
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
        openGUI, shouldDrawGUI = ImGui.Begin(string.format('RGMercs'), openGUI)
        ImGui.PushID("##RGMercsUI_" .. RGMercConfig.Globals.CurLoadedChar)

        if shouldDrawGUI then
            local pressed
            ImGui.Image(derpImg:GetTextureID(), ImVec2(60, 60))
            ImGui.SameLine()
            ImGui.Text(string.format("RGMercs [%s/%s] by: %s\nLoaded Char: %s\nClass Config: %s\nBuild: %s", RGMercConfig._version, RGMercConfig._subVersion, RGMercConfig._author,
                RGMercConfig.Globals.CurLoadedChar,
                RGMercModules:ExecModule("Class", "GetVersionString"),
                GitCommit.commitId or "None"))


            if not RGMercConfig.Globals.PauseMain then
                ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.7, 0.3, 1)
            else
                ImGui.PushStyleColor(ImGuiCol.Button, 0.7, 0.3, 0.3, 1)
            end

            if ImGui.Button(RGMercConfig.Globals.PauseMain and "PAUSED" or "Running", (ImGui.GetWindowWidth() - ImGui.GetCursorPosX() - (ImGui.GetScrollMaxY() == 0 and 0 or imGuiStyle.ScrollbarSize) - imGuiStyle.WindowPadding.x), 40) then
                RGMercConfig.Globals.PauseMain = not RGMercConfig.Globals.PauseMain
            end
            ImGui.PopStyleColor()

            RenderTarget()

            ImGui.NewLine()
            ImGui.Separator()

            if ImGui.BeginTabBar("RGMercsTabs", ImGuiTabBarFlags.None) then
                ImGui.SetItemDefaultFocus()
                if ImGui.BeginTabItem("RGMercsMain") then
                    ImGui.Text("Current State: " .. curState)
                    ImGui.Text("Hater Count: " .. tostring(RGMercUtils.GetXTHaterCount()))

                    -- .. tostring(RGMercConfig.Globals.AutoTargetID))
                    ImGui.Text("MA: " .. (RGMercUtils.GetMainAssistSpawn().CleanName() or "None"))
                    if mq.TLO.Target.ID() > 0 and mq.TLO.Target.Type():lower() == "pc" and RGMercConfig.Globals.MainAssist ~= mq.TLO.Target.ID() then
                        if ImGui.SmallButton("Set MA to Current Target") then
                            RGMercConfig.Globals.MainAssist = mq.TLO.Target.CleanName()
                        end
                    end
                    ImGui.Text("Stuck To: " .. (mq.TLO.Stick.Active() and (mq.TLO.Stick.StickTargetName() or "None") or "None"))
                    if ImGui.CollapsingHeader("Config Options") then
                        ImGui.Indent()
                        if ImGui.CollapsingHeader(string.format("%s: Config Options", "Main"), bit32.bor(ImGuiTreeNodeFlags.DefaultOpen, ImGuiTreeNodeFlags.Leaf)) then
                            local settingsRef = RGMercConfig:GetSettings()
                            settingsRef, pressed, _ = RGMercUtils.RenderSettings(settingsRef, RGMercConfig.DefaultConfig, RGMercConfig.DefaultCategories)
                            if pressed then
                                RGMercConfig:SaveSettings(false)
                            end
                        end

                        for n, s in pairs(RGMercConfig.SubModuleSettings) do
                            if RGMercModules:ExecModule(n, "ShouldRender") then
                                ImGui.PushID(n .. "_config_hdr")
                                if s and s.settings and s.defaults and s.categories then
                                    if ImGui.CollapsingHeader(string.format("%s: Config Options", n), bit32.bor(ImGuiTreeNodeFlags.DefaultOpen, ImGuiTreeNodeFlags.Leaf)) then
                                        s.settings, pressed, _ = RGMercUtils.RenderSettings(s.settings, s.defaults, s.categories, true)
                                        if pressed then
                                            RGMercModules:ExecModule(n, "SaveSettings", true)
                                        end
                                    end
                                end
                                ImGui.PopID()
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
                RGMercConfig:GetSettings().LogLevel, changed = ImGui.Combo("Debug Level", RGMercConfig:GetSettings().LogLevel, RGMercConfig.Constants.LogLevels,
                    #RGMercConfig.Constants.LogLevels)

                if changed then
                    RGMercConfig:SaveSettings(false)
                end

                ImGui.SameLine()
                RGMercConfig:GetSettings().LogToFile, changed = RGMercUtils.RenderOptionToggle("##log_to_file", "Log to File", RGMercConfig:GetSettings().LogToFile)

                if changed then
                    RGMercConfig:SaveSettings(false)
                end

                if ImGui.CollapsingHeader("Debug Output", ImGuiTreeNodeFlags.DefaultOpen) then
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

            displayItemOnCursor()
        end

        ImGui.PopID()
        ImGui.PopStyleVar(3)
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
        "MQ2Cast",
        "MQ2Rez",
        "MQ2AdvPath",
        "MQ2MoveUtils",
        "MQ2Nav",
        "MQ2DanNet", })

    unloadedPlugins = RGMercUtils.UnCheckPlugins({ "MQ2Melee", })

    -- complex objects are passed by reference so we can just use these without having to pass them back in for saving.
    RGMercConfig.SubModuleSettings = RGMercModules:ExecAll("Init")

    if not RGMercUtils.GetSetting('DoTwist') then
        local unloaded = RGMercUtils.UnCheckPlugins({ "MQ2Twist", })
        if #unloaded == 1 then table.insert(unloadedPlugins, unloaded[1]) end
    end

    local mainAssist = mq.TLO.Target.CleanName() or ""

    if mainAssist:len() == 0 and mq.TLO.Group() then
        mainAssist = mq.TLO.Group.MainAssist() or ""
    end

    for k, v in ipairs(RGMercConfig.Constants.ExpansionIDToName) do
        RGMercsLogger.log_debug("\ayExpansion \at%-22s\ao[\am%02d\ao]: %s", v, k, RGMercUtils.HaveExpansion(v) and "\agEnabled" or "\arDisabled")
    end

    -- TODO: Can turn this into an options parser later.
    if ... then
        mainAssist = ...
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

    RGMercUtils.PrintGroupMessage("Pausing the CWTN Plugin on this host If it exists! (/%s pause on)", mq.TLO.Me.Class.ShortName())
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
        RGMercUtils.PopUp("Targetting %s for Main Assist", RGMercConfig.Globals.MainAssist)
        RGMercUtils.SetTarget(RGMercUtils.GetMainAssistId())
        RGMercsLogger.log_info("\aw Assisting \ay >> \ag %s \ay << \aw at \ag %d%%", RGMercConfig.Globals.MainAssist, RGMercUtils.GetSetting('AutoAssistAt'))
    end

    if RGMercUtils.GetGroupMainAssistName() ~= mainAssist then
        RGMercUtils.PopUp(string.format("Assisting: %s NOTICE: Group MainAssist [%s] != Your Assist Target [%s]. Is This On Purpose?", mainAssist,
            RGMercUtils.GetGroupMainAssistName(), mainAssist))
    end

    -- store initial positioning data.
    RGMercConfig:StoreLastMove()
end

local function Main()
    if mq.TLO.Me.Zoning() then
        if notifyZoning then
            RGMercModules:ExecAll("OnZone")
            notifyZoning = false
        end
        mq.delay(1000)
        return
    end

    notifyZoning = true

    if mq.TLO.Me.NumGems() ~= RGMercUtils.UseGem then
        -- sometimes this can get out of sync.
        RGMercUtils.UseGem = mq.TLO.Me.NumGems()
    end

    if RGMercConfig.Globals.PauseMain then
        mq.delay(1000)
        mq.doevents()
        if RGMercUtils.GetSetting('RunMovePaused') then
            RGMercModules:ExecModule("Movement", "GiveTime", curState)
        end
        return
    end

    if RGMercUtils.GetXTHaterCount() > 0 then
        curState = "Combat"
        --if os.clock() - RGMercConfig.Globals.LastFaceTime > 6 then
        if not RGMercUtils.FacingTarget() then
            --RGMercConfig.Globals.LastFaceTime = os.clock()
            RGMercUtils.DoCmd("/squelch /face")
        end
    else
        curState = "Downtime"
    end

    if mq.TLO.MacroQuest.GameState() ~= "INGAME" then return end

    if RGMercConfig.Globals.CurLoadedChar ~= mq.TLO.Me.DisplayName() then
        RGMercConfig:LoadSettings()
        RGMercModules:ExecAll("LoadSettings")
    end

    RGMercConfig:StoreLastMove()

    if mq.TLO.Me.Hovering() then RGMercUtils.HandleDeath() end

    RGMercUtils.SetControlToon()

    if RGMercUtils.FindTargetCheck() then
        -- This will find a valid target and set it to : RGMercConfig.Globals.AutoTargetID
        RGMercUtils.FindTarget(function(targetId)
            if RGMercUtils.OkToEngagePreValidateId(targetId) then return true end
            return false
        end)
    end

    if RGMercUtils.OkToEngage(RGMercConfig.Globals.AutoTargetID) then
        RGMercUtils.EngageTarget(RGMercConfig.Globals.AutoTargetID)
    else
        if RGMercUtils.GetXTHaterCount() > 0 and RGMercUtils.GetTargetID() > 0 and not RGMercUtils.IsMezzing() then
            RGMercsLogger.log_debug("\ayClearing Target because we are not OkToEngage() and we are in combat!")
            RGMercUtils.ClearTarget()
        end
    end

    -- Handles state for when we're in combat
    if RGMercUtils.DoCombatActions() and not RGMercUtils.GetSetting('PriorityHealing') then
        -- IsHealing or IsMezzing should re-determine their target as this point because they may
        -- have switched off to mez or heal after the initial find target check and the target
        -- may have changed by this point.
        if RGMercUtils.FindTargetCheck() and (not RGMercUtils.IsHealing() or not RGMercUtils.IsMezzing()) then
            RGMercUtils.FindTarget()
        end

        if ((os.clock() - RGMercConfig.Globals.LastPetCmd) > 2) then
            RGMercConfig.Globals.LastPetCmd = os.clock()
            if RGMercUtils.GetSetting('DoPet') and (RGMercUtils.GetTargetPctHPs() <= RGMercUtils.GetSetting('PetEngagePct')) then
                RGMercUtils.PetAttack(RGMercConfig.Globals.AutoTargetID)
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

    if RGMercUtils.GetSetting('DoMed') >= 2 then
        RGMercUtils.AutoMed()
    end

    if RGMercUtils.ShouldKillTargetReset() then
        RGMercConfig.Globals.AutoTargetID = 0
    end

    -- If target is not attackable then turn off attack
    local pcCheck = (mq.TLO.Target.Type() or "none"):lower() == "pc" or
        ((mq.TLO.Target.Type() or "none"):lower() == "pet" and (mq.TLO.Target.Master.Type() or "none"):lower() == "pc")
    local mercCheck = (mq.TLO.Target.Type() or "none"):lower() == "mercenary"
    if mq.TLO.Me.Combat() and (not mq.TLO.Target() or pcCheck or mercCheck) then
        RGMercsLogger.log_debug("\ay[1] Target type check failed \aw[\atinCombat(%s) pcCheckFailed(%s) mercCheckFailed(%s)\aw]\ay - turning attack off!",
            RGMercUtils.BoolToColorString(mq.TLO.Me.Combat()), RGMercUtils.BoolToColorString(pcCheck), RGMercUtils.BoolToColorString(mercCheck))
        RGMercUtils.DoCmd("/attack off")
    end

    -- TODO: Fix Curing

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
    mq.delay(100)
end

-- Global Messaging callback
---@diagnostic disable-next-line: unused-local
local script_actor = RGMercUtils.Actors.register(function(message)
    local msg = message()
    if msg.from == RGMercConfig.Globals.CurLoadedChar then return end
    if msg.script ~= RGMercUtils.ScriptName then return end

    RGMercsLogger.log_info("\ayGot Event from(\am%s\ay) module(\at%s\ay) event(\at%s\ay)", msg.from,
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
