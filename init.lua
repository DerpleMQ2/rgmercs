local mq        = require('mq')
local ImGui     = require('ImGui')
local GitCommit = require('extras.version')

RGMercConfig    = require('utils.rgmercs_config')
RGMercConfig:LoadSettings()

RGMercsConsole = nil

local RGMercsLogger = require("utils.rgmercs_logger")
RGMercsLogger.set_log_level(RGMercConfig:GetSettings().LogLevel)

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
--local derpImg        = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/derp.png")

-- Constants
local ICON_WIDTH     = 40
local ICON_HEIGHT    = 40
local COUNT_X_OFFSET = 39
local COUNT_Y_OFFSET = 23
local EQ_ICON_OFFSET = 500

-- UI --
local function display_item_on_cursor()
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

    for _, name in ipairs(RGMercModules:getModuleOrderedNames()) do
        if ImGui.BeginTabItem(name) then
            RGMercModules:execModule(name, "Render")
            ImGui.EndTabItem()
        end
    end
end

local function renderDragDropForItem(label)
    ImGui.Text(label)
    ImGui.PushID(label .. "__btn")
    if ImGui.Button("HERE", ICON_WIDTH, ICON_HEIGHT) then
        if mq.TLO.Cursor() then
            return true, mq.TLO.Cursor.Name()
        end
        return false, ""
    end
    ImGui.PopID()
    return false, ""
end

local function Alive()
    return mq.TLO.NearestSpawn('pc')() ~= nil
end

local function GetTheme()
    return RGMercModules:execModule("Class", "GetTheme")
end

local function RenderTarget()
    ImGui.Text("Auto Target: ")
    ImGui.SameLine()
    if RGMercConfig.Globals.AutoTargetID == 0 then
        ImGui.Text("None")
        ImGui.ProgressBar(0, -1, 25)
    else
        local assistSpawn = RGMercConfig:GetAutoTarget()
        local pctHPs = assistSpawn.PctHPs() or 0
        if not pctHPs then pctHPs = 0 end
        local ratioHPs = pctHPs / 100
        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 1 - ratioHPs, ratioHPs, 0, 1)
        if math.floor(assistSpawn.Distance() or 0) >= 350 then
            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 0.0, 1)
        else
            ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
        end
        ImGui.Text(string.format("%s (%s) [%d %s] HP: %d%% Dist: %d", assistSpawn.CleanName() or "", assistSpawn.ID() or 0, assistSpawn.Level() or 0,
            assistSpawn.Class.ShortName() or "N/A", assistSpawn.PctHPs() or 0, assistSpawn.Distance() or 0))
        ImGui.ProgressBar(ratioHPs, -1, 25)

        ImGui.PopStyleColor(2)
    end
end

local function RGMercsGUI()
    local theme = GetTheme()
    local themeStylePop = 0

    if RGMercsConsole == nil then
        RGMercsConsole = ImGui.ConsoleWidget.new("##RGMercsConsole")
        RGMercsConsole.maxBufferLines = 100
        RGMercsConsole.autoScroll = true
    end

    if mq.TLO.MacroQuest.GameState() == "CHARSELECT" then
        openGUI = false
        return
    end

    if openGUI and Alive() then
        if theme ~= nil then
            for _, t in pairs(theme) do
                ImGui.PushStyleColor(t.element, t.color.r, t.color.g, t.color.b, t.color.a)
                themeStylePop = themeStylePop + 1
            end
        end

        ImGui.PushStyleVar(ImGuiStyleVar.Alpha, tonumber(RGMercConfig:GetSettings().BgOpacity) or 1.0) -- Main window opacity.

        openGUI, shouldDrawGUI = ImGui.Begin('RGMercs', openGUI)

        --ImGui.Image(derpImg:GetTextureID(), ImVec2(ImGui.GetWindowWidth(), ImGui.GetWindowHeight()))

        --ImGui.SetCursorPos(0, 0)

        if shouldDrawGUI then
            local pressed

            ImGui.Text(string.format("RGMercs [%s/%s] by: %s running for %s (%s)", RGMercConfig._version, RGMercConfig._subVersion, RGMercConfig._author,
                RGMercConfig.Globals.CurLoadedChar,
                RGMercConfig.Globals.CurLoadedClass))
            ImGui.Text(string.format("Build: %s", GitCommit.commitId or "None"))

            if RGMercConfig.Globals.PauseMain then
                ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.7, 0.3, 1)
            else
                ImGui.PushStyleColor(ImGuiCol.Button, 0.7, 0.3, 0.3, 1)
            end

            if ImGui.Button(RGMercConfig.Globals.PauseMain and "Unpause" or "Pause", ImGui.GetWindowWidth(), 40) then
                RGMercConfig.Globals.PauseMain = not RGMercConfig.Globals.PauseMain
            end
            ImGui.PopStyleColor()

            RenderTarget()

            ImGui.NewLine()
            ImGui.Separator()

            local newOpacity, changed = ImGui.SliderFloat("Opacity", tonumber(RGMercConfig:GetSettings().BgOpacity) or 1.0, 0.1, 1.0)

            if changed then
                RGMercConfig:GetSettings().BgOpacity = tostring(newOpacity)
                RGMercConfig:SaveSettings(true)
            end

            if ImGui.BeginTabBar("RGMercsTabs", ImGuiTabBarFlags.None) then
                ImGui.SetItemDefaultFocus()
                if ImGui.BeginTabItem("RGMercsMain") then
                    ImGui.Text("Current State: " .. curState)
                    ImGui.Text("Hater Count: " .. tostring(RGMercUtils.GetXTHaterCount()))

                    -- .. tostring(RGMercConfig.Globals.AutoTargetID))
                    ImGui.Text("MA: " .. (RGMercConfig:GetAssistSpawn().CleanName() or "None"))
                    ImGui.Text("Stuck To: " .. (mq.TLO.Stick.Active() and (mq.TLO.Stick.StickTargetName() or "None") or "None"))
                    if ImGui.CollapsingHeader("Config Options") then
                        local settingsRef = RGMercConfig:GetSettings()
                        settingsRef, pressed, _ = RGMercUtils.RenderSettings(settingsRef, RGMercConfig.DefaultConfig, RGMercConfig.DefaultCategories)
                        if pressed then
                            RGMercConfig:SaveSettings(true)
                        end
                    end

                    for n, s in pairs(RGMercConfig.SubModuleSettings) do
                        ImGui.PushID(n .. "_config_hdr")
                        if s and s.settings and s.defaults and s.categories then
                            if ImGui.CollapsingHeader(string.format("%s: Config Options", n)) then
                                s.settings, pressed, _ = RGMercUtils.RenderSettings(s.settings, s.defaults, s.categories)
                                if pressed then
                                    RGMercModules:execModule(n, "SaveSettings", true)
                                end
                            end
                        end
                        ImGui.PopID()
                    end

                    if ImGui.CollapsingHeader("Zone Named") then
                        RGMercUtils.RenderZoneNamed()
                    end

                    if ImGui.CollapsingHeader("Custom Items") then
                        local dropped, newItem = renderDragDropForItem("Drop Mount Item")
                        if dropped then
                            RGMercsLogger.log_debug("New item dropped: %s", newItem)
                            RGMercConfig:GetSettings().MountItem = newItem
                            RGMercConfig:SaveSettings(true)
                        end

                        dropped, newItem = renderDragDropForItem("Drop Shrink Item")
                        if dropped then
                            RGMercsLogger.log_debug("New item dropped: %s", newItem)
                            RGMercConfig:GetSettings().ShrinkItem = newItem
                            RGMercConfig:SaveSettings(true)
                        end
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
                    RGMercConfig:SaveSettings(true)
                end

                if ImGui.CollapsingHeader("Debug Output", ImGuiTreeNodeFlags.DefaultOpen) then
                    local cur_x, cur_y = ImGui.GetCursorPos()
                    local contentSizeX, contentSizeY = ImGui.GetContentRegionAvail()
                    local scroll = ImGui.GetScrollY()
                    ImGui.Dummy(contentSizeX, 410)
                    ImGui.SetCursorPos(cur_x, cur_y)
                    RGMercsConsole:Render(ImVec2(contentSizeX, math.min(400, contentSizeY + scroll)))
                    ImGui.Separator()
                end
            end

            display_item_on_cursor()
        end

        ImGui.End()
        if themeStylePop > 0 then
            ImGui.PopStyleColor(themeStylePop)
        end
        ImGui.PopStyleVar(1)
    end
end

mq.imgui.init('RGMercsUI', RGMercsGUI)
mq.bind('/rgmercsui', function()
    openGUI = not openGUI
end)

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
    RGMercConfig.SubModuleSettings = RGMercModules:execAll("Init")

    if not RGMercConfig:GetSettings().DoTwist then
        local unloaded = RGMercUtils.UnCheckPlugins({ "MQ2Twist", })
        if #unloaded == 1 then table.insert(unloadedPlugins, unloaded[1]) end
    end

    local mainAssist = RGMercUtils.GetTargetName()

    if mainAssist:len() == 0 and mq.TLO.Group() then
        mainAssist = mq.TLO.Group.MainAssist() or ""
    end

    for k, v in ipairs(RGMercConfig.ExpansionIDToName) do
        RGMercsLogger.log_debug("\ayExpanions \at%s\ao[\am%d\ao]: %s", v, k, RGMercUtils.HaveExpansion(v) and "\agEnabled" or "\arDisabled")
    end

    -- TODO: Can turn this into an options parser later.
    if ... then
        mainAssist = ...
    end

    if not mainAssist or mainAssist == "" then
        mainAssist = mq.TLO.Me.CleanName()
    end

    mq.cmdf("/squelch /rez accept on")
    mq.cmdf("/squelch /rez pct 90")

    if mq.TLO.Plugin("MQ2DanNet")() then
        mq.cmdf("/squelch /dnet commandecho off")
    end

    mq.cmdf("/stick set breakontarget on")

    -- TODO: Chat Begs

    RGMercUtils.PrintGroupMessage("Pausing the CWTN Plugin on this host If it exists! (/%s pause on)", mq.TLO.Me.Class.ShortName())
    mq.cmdf("/squelch /docommand /%s pause on", mq.TLO.Me.Class.ShortName())

    if RGMercUtils.CanUseAA("Companion's Discipline") then
        mq.cmdf("/pet ghold on")
    else
        mq.cmdf("/pet hold on")
    end

    if mq.TLO.Cursor() and mq.TLO.Cursor.ID() > 0 then
        RGMercsLogger.log_info("Sending Item(%s) on Cursor to Bag", mq.TLO.Cursor())
        mq.cmdf("/autoinventory")
    end

    RGMercUtils.WelcomeMsg()

    if mainAssist:len() > 0 then
        RGMercConfig.Globals.MainAssist = mainAssist
        RGMercUtils.PopUp("Targetting %s for Main Assist", RGMercConfig.Globals.MainAssist)
        RGMercUtils.SetTarget(RGMercConfig:GetAssistId())
        RGMercsLogger.log_info("\aw Assisting \ay >> \ag %s \ay << \aw at \ag %d%%", RGMercConfig.Globals.MainAssist, RGMercConfig:GetSettings().AutoAssistAt)
    end

    if RGMercUtils.GetGroupMainAssistName() ~= mainAssist then
        RGMercUtils.PopUp(string.format("Assisting: %s NOTICE: Group MainAssist [%s] != Your Assist Target [%s]. Is This On Purpose?", mainAssist,
            RGMercUtils.GetGroupMainAssistName(), mainAssist))
    end
end

local function Main()
    if mq.TLO.Me.Zoning() then
        if notifyZoning then
            RGMercModules:execAll("OnZone")
            notifyZoning = false
        end
        mq.delay(1000)
        return
    end

    notifyZoning = true

    if RGMercConfig.Globals.PauseMain then
        mq.delay(1000)
        return
    end

    if RGMercUtils.GetXTHaterCount() > 0 then
        curState = "Combat"
        if os.clock() - RGMercConfig.Globals.LastFaceTime > 6 then
            RGMercConfig.Globals.LastFaceTime = os.clock()
            mq.cmdf("/squelch /face")
        end
    else
        curState = "Downtime"
    end

    if mq.TLO.MacroQuest.GameState() ~= "INGAME" then return end

    if RGMercConfig.Globals.CurLoadedChar ~= mq.TLO.Me.CleanName() then
        RGMercConfig:LoadSettings()
    end

    RGMercConfig:StoreLastMove()

    if mq.TLO.Me.Hovering() then RGMercUtils.HandleDeath() end

    RGMercUtils.SetControlToon()

    if RGMercUtils.FindTargetCheck() then
        RGMercUtils.FindTarget()
    end

    if RGMercUtils.OkToEngage(RGMercUtils.GetTargetID()) then
        RGMercUtils.EngageTarget(RGMercUtils.GetTargetID())
    else
        if RGMercUtils.GetTargetID() > 0 then
            RGMercUtils.ClearTarget()
        end
    end

    -- TODO: Write Healing Module

    -- Handles state for when we're in combat
    if RGMercUtils.DoCombatActions() and not RGMercConfig:GetSettings().PriorityHealing then
        -- IsHealing or IsMezzing should re-determine their target as this point because they may
        -- have switched off to mez or heal after the initial find target check and the target
        -- may have changed by this point.
        if RGMercUtils.FindTargetCheck() and (not RGMercConfig.Globals.IsHealing or not RGMercConfig.Globals.IsMezzing) then
            RGMercUtils.FindTarget()
        end

        if ((os.clock() - RGMercConfig.Globals.LastPetCmd) > 2) then
            RGMercConfig.Globals.LastPetCmd = os.clock()
            if RGMercConfig:GetSettings().DoPet and (RGMercUtils.GetTargetPctHPs() <= RGMercConfig:GetSettings().PetEngagePct) then
                RGMercUtils.PetAttack(RGMercConfig.Globals.AutoTargetID)
            end
        end

        if RGMercConfig:GetSettings().DoMercenary then
            local merc = mq.TLO.Me.Mercenary

            if merc() and merc.ID() then
                if RGMercUtils.MercEngage() then
                    if merc.Class.ShortName():lower() == "war" and merc.Stance():lower() ~= "aggressive" then
                        mq.cmdf("/squelch /stance aggressive")
                    end

                    if merc.Class.ShortName():lower() ~= "war" and merc.Stance():lower() ~= "balanced" then
                        mq.cmdf("/squelch /stance balanced")
                    end

                    RGMercUtils.MercAssist()
                else
                    if merc.Class.ShortName():lower() ~= "clr" and merc.Stance():lower() ~= "passive" then
                        mq.cmdf("/squelch /stance passive")
                    end
                end
            end
        end
    end

    if RGMercUtils.DoCamp() then
        if RGMercConfig:GetSettings().DoMercenary and mq.TLO.Me.Mercenary.ID() and (mq.TLO.Me.Mercenary.Class.ShortName() or "none"):lower() ~= "clr" and mq.TLO.Me.Mercenary.Stance():lower() ~= "passive" then
            mq.cmdf("/squelch /stance passive")
        end
    end

    if RGMercUtils.DoBuffCheck() and not RGMercConfig:GetSettings().PriorityHealing then
        -- TODO: Group Buffs
    end

    if RGMercConfig:GetSettings().DoModRod then
        RGMercUtils.ClickModRod()
    end

    if RGMercConfig:GetSettings().DoMed then
        RGMercUtils.AutoMed()
    end

    if RGMercUtils.ShouldKillTargetReset() then
        RGMercConfig.Globals.AutoTargetID = 0
    end

    -- If target is not attackable then turn off attack
    local aggroCheck = not mq.TLO.Target.Aggressive()
    local pcCheck = (mq.TLO.Target.Type() or "none"):lower() == "pc" or
        ((mq.TLO.Target.Type() or "none"):lower() == "pet" and (mq.TLO.Target.Master.Type() or "none"):lower() == "pc")
    local mercCheck = mq.TLO.Target.Type() == "mercenary"
    if mq.TLO.Me.Combat() and (not mq.TLO.Target() or aggroCheck or pcCheck or mercCheck) then
        RGMercsLogger.log_debug("\ayTarget type check failed \aw[\atinCombat(%s) taggroCheckFailed(%s) pcCheckFailed(%s) mercCheckFailed(%s)\aw]\ay - turning attack off!",
            mq.TLO.Me.Combat() and "True" or "False", aggroCheck and "True" or "False", pcCheck and "True" or "False", mercCheck and "True" or "False")
        mq.cmdf("/attack off")
    end

    -- TODO: Fix Curing

    -- Revive our mercenary if they're dead and we're using a mercenary
    if RGMercConfig:GetSettings().DoMercenary then
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

    RGMercModules:execAll("GiveTime", curState)

    mq.doevents()
    mq.delay(100)
end

-- Global Messaging callback
---@diagnostic disable-next-line: unused-local
local script_actor = RGMercUtils.Actors.register(function(message)
    if message()["from"] == RGMercConfig.Globals.CurLoadedChar then return end
    if message()["script"] ~= RGMercUtils.ScriptName then return end

    RGMercsLogger.log_info("\ayGot Event from(\am%s\ay) module(\at%s\ay) event(\at%s\ay)", message()["from"],
        message()["module"],
        message()["event"])

    if message()["module"] then
        if message()["module"] == "main" then
            RGMercConfig:LoadSettings()
        else
            RGMercModules:execModule(message()["module"], message()["event"], message()["data"])
        end
    end
end)

-- Binds
local function bindHandler(cmd, ...)
    if cmd == "pause" then
        RGMercConfig.Globals.PauseMain = true
        return
    end

    if cmd == "unpause" then
        RGMercConfig.Globals.PauseMain = false
        return
    end

    local results = RGMercModules:execAll("HandleBind", cmd, ...)

    local processed = false

    for _, r in pairs(results) do processed = processed or r end

    if not processed then
        RGMercsLogger.log_warning("\ayWarning:\ay '\at%s\ay' is not a valid command", cmd)
    end
end

mq.bind("/rglua", bindHandler)

-- [ EVENTS ] --
mq.event("CantSee", "You cannot see your target.", function()
    if RGMercConfig.Globals.BackOffFlag then return end

    if mq.TLO.Stick.Active() then
        mq.cmdf("/stick off")
    end

    if RGMercModules:execModule("Pull", "IsPullState", "PULL_PULLING") then
        RGMercsLogger.log_info("\ayWe are in Pull_State PULLING and Cannot see our target!")
        mq.cmdf("/nav id %d distance=%d lineofsight=on log=off", mq.TLO.Target.ID() or 0, (mq.TLO.Target.Distance() or 0) * 0.5)
        mq.delay("2s", function() return mq.TLO.Navigation.Active() end)

        -- TODO: Do we need this?
        --while (${Navigation.Active} && ${XAssist.XTFullHaterCount} == 0) {
        --CALLTRACE In while loop :: Navigation.Active ${Navigation.Active} :: XAssist ${XAssist.XTFullHaterCount}
        --/doevents
        --/delay 1 ${XAssist.XTFullHaterCount} > 0
        --}
    else
        RGMercsLogger.log_info("\ayWe are in COMBAT and Cannot see our target!")
        if RGMercConfig:GetSettings().DoAutoEngage then
            if RGMercUtils.OkToEngage(mq.TLO.Target.ID() or 0) then
                mq.cmdf("/squelch /face fast")
                if RGMercConfig:GetSettings().DoMelee then
                    RGMercsLogger.log_debug("Can't See target (%s [%d]). Naving to %d away.", mq.TLO.Target.CleanName() or "", mq.TLO.Target.ID() or 0,
                        (mq.TLO.Target.MaxRangeTo() or 0) * 0.9)
                    RGMercUtils.NavInCombat(RGMercConfig:GetSettings(), mq.TLO.Target.ID(), (mq.TLO.Target.MaxRangeTo() or 0) * 0.9, false)
                end
            end
        end
    end
    mq.flushevents("CantSee")
end)

mq.event("TooFar1", "#*#Your target is too far away, get closer!", function()
    RGMercUtils.TooFarHandler()
    mq.flushevents("TooFar1")
end)
mq.event("TooFar2", "#*#You can't hit them from here.", function()
    RGMercUtils.TooFarHandler()
    mq.flushevents("TooFar2")
end)
mq.event("TooFar3", "#*#You are too far away#*#", function()
    RGMercUtils.TooFarHandler()
    mq.flushevents("TooFar3")
end)

-- [ END EVENTS ] --

RGInit(...)

while openGUI do
    Main()
    mq.doevents()
    mq.delay(10)
end

RGMercModules:execAll("Shutdown")
