local mq     = require('mq')
local ImGui  = require('ImGui')
RGMercConfig = require('rgmercs.utils.rgmercs_config')
RGMercConfig:LoadSettings()

local RGMercsLogger = require("rgmercs.utils.rgmercs_logger")
RGMercsLogger.set_log_level(RGMercConfig:GetSettings().LogLevel)

local RGMercUtils    = require("rgmercs.utils.rgmercs_utils")

RGMercNameds         = require("rgmercs.utils.rgmercs_named")

-- Initialize class-based moduldes
RGMercModules        = require("rgmercs.utils.rgmercs_modules").load()

-- ImGui Variables
local openGUI        = true
local shouldDrawGUI  = true
local BgOpacity      = tonumber(RGMercConfig:GetSettings().BgOpacity)

local curState       = "Downtime"

-- Icon Rendering
local animItems      = mq.FindTextureAnimation("A_DragItem")
local animBox        = mq.FindTextureAnimation("A_RecessedBox")

-- Constants
local ICON_WIDTH     = 40
local ICON_HEIGHT    = 40
local COUNT_X_OFFSET = 39
local COUNT_Y_OFFSET = 23
local EQ_ICON_OFFSET = 500

local terminate      = false

-- UI --
local function display_item_on_cursor()
    if mq.TLO.Cursor() then
        local cursor_item = mq.TLO.Cursor -- this will be an MQ item, so don't forget to use () on the members!
        local mouse_x, mouse_y = ImGui.GetMousePos()
        local window_x, window_y = ImGui.GetWindowPos()
        local icon_x = mouse_x - window_x + 10
        local icon_y = mouse_y - window_y + 10
        local stack_x = icon_x + COUNT_X_OFFSET
        local stack_y = icon_y + COUNT_Y_OFFSET
        local text_size = ImGui.CalcTextSize(tostring(cursor_item.Stack()))
        ImGui.SetCursorPos(icon_x, icon_y)
        animItems:SetTextureCell(cursor_item.Icon() - EQ_ICON_OFFSET)
        ImGui.DrawTextureAnimation(animItems, ICON_WIDTH, ICON_HEIGHT)
        if cursor_item.Stackable() then
            ImGui.SetCursorPos(stack_x, stack_y)
            ImGui.DrawTextureAnimation(animBox, text_size, ImGui.GetTextLineHeight())
            ImGui.SetCursorPos(stack_x - text_size, stack_y)
            ImGui.TextUnformatted(tostring(cursor_item.Stack()))
        end
    end
end

local function renderModulesTabs()
    if not RGMercConfig:SettingsLoaded() then return end

    local tabNames = {}
    for name, _ in pairs(RGMercModules:getModuleList()) do
        table.insert(tabNames, name)
    end

    table.sort(tabNames)

    for _, name in ipairs(tabNames) do
        ImGui.TableNextColumn()
        if ImGui.BeginTabItem(name) then
            RGMercModules:execModule(name, "Render")
            ImGui.EndTabItem()
        end
    end
end

local function RGMercsGUI()
    if openGUI then
        openGUI, shouldDrawGUI = ImGui.Begin('RGMercs', openGUI)
        if mq.TLO.MacroQuest.GameState() ~= "INGAME" then return end

        ImGui.SetNextWindowBgAlpha(BgOpacity)

        if shouldDrawGUI then
            local pressed
            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1)
            ImGui.Text(string.format("RGMercs running for %s (%s)", RGMercConfig.Globals.CurLoadedChar,
                RGMercConfig.Globals.CurLoadedClass))

            if RGMercConfig.Globals.PauseMain then
                ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.7, 0.3, 1)
            else
                ImGui.PushStyleColor(ImGuiCol.Button, 0.7, 0.3, 0.3, 1)
            end

            if ImGui.Button(RGMercConfig.Globals.PauseMain and "Unpause" or "Pause", 300, 40) then
                RGMercConfig.Globals.PauseMain = not RGMercConfig.Globals.PauseMain
            end
            ImGui.PopStyleColor()

            if ImGui.BeginTabBar("RGMercsTabs") then
                ImGui.SetItemDefaultFocus()
                if ImGui.BeginTabItem("RGMercsMain") then
                    ImGui.Text("Current State: " .. curState)
                    ImGui.Text("Hater Count: " .. tostring(RGMercUtils.GetXTHaterCount()))
                    ImGui.Text("AutoTargetID: " .. tostring(RGMercConfig.Globals.AutoTargetID))
                    ImGui.Text("MA: " .. (RGMercConfig:GetAssistSpawn().CleanName() or "None"))
                    if ImGui.CollapsingHeader("Config Options") then
                        local newSettings = RGMercConfig:GetSettings()
                        newSettings, pressed, _ = RGMercUtils.RenderSettings(newSettings, RGMercConfig.DefaultConfig)
                        if pressed then
                            RGMercConfig:SetSettings(newSettings)
                            RGMercConfig:SaveSettings(true)
                        end
                    end
                    if ImGui.CollapsingHeader("Zone Named") then
                        RGMercUtils.RenderZoneNamed()
                    end

                    ImGui.EndTabItem()
                end

                renderModulesTabs()


                ImGui.EndTabBar();
            end
            ImGui.PopStyleColor(1)

            ImGui.NewLine()
            ImGui.NewLine()
            ImGui.Separator()

            BgOpacity, pressed = ImGui.SliderFloat("BG Opacity", BgOpacity, 0, 1.0, "%.1f", 0.1)
            if pressed then
                RGMercConfig:GetSettings().BgOpacity = tostring(BgOpacity)
                RGMercConfig:SaveSettings(true)
            end

            display_item_on_cursor()
        end

        ImGui.End()
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
        "MQ2DanNet",
        "MQ2SpawnMaster" })

    unloadedPlugins = RGMercUtils.UnCheckPlugins({ "MQ2Melee" })

    if not RGMercConfig:GetSettings().DoTwist then
        local unloaded = RGMercUtils.UnCheckPlugins({ "MQ2Twist" })
        if #unloaded == 1 then table.insert(unloadedPlugins, unloaded[1]) end
    end

    local mainAssist = mq.TLO.Me.Name()

    -- TODO: Can turn this into an options parser later.
    if ... then
        mainAssist = ...
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

    if mq.TLO.Group.MainAssist.CleanName() ~= mainAssist then
        RGMercUtils.PopUp(string.format("Assisting %s NOTICE: Group MainAssist != Your Target. Is This On Purpose?", mainAssist))
    end
end

local function Main()
    curState = "Downtime"
    if mq.TLO.Me.Zoning() then
        mq.delay(1000)
        return
    end

    if RGMercConfig.Globals.PauseMain then
        mq.delay(1000)
        return
    end

    if mq.TLO.MacroQuest.GameState() ~= "INGAME" then return end

    if RGMercConfig.Globals.CurLoadedChar ~= mq.TLO.Me.CleanName() then
        RGMercConfig:LoadSettings()
    end

    RGMercConfig:StoreLastMove()

    if mq.TLO.Me.Hovering() then RGMercUtils.HandleDeath() end

    RGMercUtils.SetControlTool()

    if RGMercUtils.FindTargetCheck() then
        RGMercUtils.FindTarget()
    end

    if RGMercUtils.OkToEngage(mq.TLO.Target.ID()) then
        RGMercUtils.EngageTarget(mq.TLO.Target.ID())
    end

    if RGMercUtils.GetXTHaterCount() > 0 then
        curState = "Combat"
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

        if RGMercConfig:GetSettings().DoMercenary then
            local merc = mq.TLO.Me.Mercenary

            if merc() then
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
        if mq.TLO.Me.Mercenary() and mq.TLO.Me.Mercenary.Class.ShortName():lower() ~= "clr" and mq.TLO.Me.Mercenary.Stance():lower() ~= "passive" then
            mq.cmdf("/squelch /stance passive")
        end
    end

    if RGMercUtils.DoBuffCheck() and not RGMercConfig:GetSettings().PriorityHealing then
        -- TODO: Shrink Check
        -- TODO: Group Buffs
        -- TODO: Pull Delay Handling
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

    mq.delay(100)
end

-- Global Messaging callback
---@diagnostic disable-next-line: unused-local
local script_actor = RGMercUtils.Actors.register(function(message)
    if message()["from"] == RGMercConfig.Globals.CurLoadedChar then return end
    if message()["script"] ~= RGMercUtils.ScriptName then return end

    RGMercsLogger.log_error("\ayGot Event from(\am%s\ay) module(\at%s\ay) event(\at%s\ay)", message()["from"],
        message()["module"],
        message()["event"])

    if message()["module"] then
        if message()["module"] == "main" then
            RGMercConfig:LoadSettings()
        else
            RGMercModules:getModuleList()[message()["module"]]:LoadSettings()
        end
    end
end)

-- Binds
local function bindHandler(cmd, ...)
    if cmd:lower() == "chaseon" then
        RGMercModules:execModule("Chase", "ChaseOn", ...)
    elseif cmd:lower() == "chaseoff" then
        RGMercModules:execModule("Chase", "ChaseOff", ...)
    elseif cmd:lower() == "campon" then
        RGMercModules:execModule("Chase", "CampOn", ...)
    elseif cmd:lower() == "campoff" then
        RGMercModules:execModule("Chase", "CampOff", ...)
    else
        RGMercsLogger.log_warning("\ayWarning:\ay '\at%s\ay' is not a valid command", cmd)
    end
end

mq.bind("/rglua", bindHandler)

RGInit(...)

while not terminate do
    Main()
    mq.doevents()
    mq.delay(10)
end

RGMercModules:execAll("Shutdown")
