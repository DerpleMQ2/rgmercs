-- rgmercs
-- Copyright (C) 2025 Derple (derple@ntsj.com)
-- SPDX-License-Identifier: GPL-3.0-or-later
-- This file is part of rgmercs. See the `LICENSE` file in the repository root for license terms.
-- For the full license text, see https://www.gnu.org/licenses/gpl-3.0.txt

local mq         = require('mq')
local ImGui      = require('ImGui')

-- Preload these incase any modules need them.
local PackageMan = require('mq.PackageMan')
PackageMan.Require('lsqlite3')
PackageMan.Require('luafilesystem', 'lfs')

local Config = require('utils.config')
Config:LoadSettings()

local Logger = require("utils.logger")
Logger.set_log_level(Config:GetSetting('LogLevel'))
Logger.set_log_to_file(Config:GetSetting('LogToFile'))

local Binds = require('utils.binds')
require('utils.event_handlers')

local Core        = require("utils.core")
local ClassLoader = require('utils.classloader')
local Targeting   = require("utils.targeting")
local Combat      = require("utils.combat")
local Casting     = require("utils.casting")
local Events      = require("utils.events")
local Ui          = require("utils.ui")
local Comms       = require("utils.comms")
local Strings     = require("utils.strings")
local Movement    = require("utils.movement")
local Set         = require('mq.set')

-- Initialize class-based moduldes
local Modules     = require("utils.modules")
Modules:load(Config.Constants.LootModuleTypes[Config:GetSetting('LootModuleType')])

require('utils.datatypes')

-- ImGui Variables
local openGUI            = true
local notifyZoning       = true
local curState           = "Downtime"
local heartbeatCoroutine = nil


local initPctComplete = 0
local initMsg         = "Initializing RGMercs..."

-- UI --
local SimpleUI        = require("ui.simple")
local StandardUI      = require("ui.standard")
local OptionsUI       = require("ui.options")
local ConsoleUI       = require("ui.console")
local LoaderUI        = require("ui.loader")
local HudUI           = require("ui.hud")

local function renderModulesPopped()
    if not Config:SettingsLoaded() then return end

    for _, name in ipairs(Modules:GetModuleOrderedNames()) do
        if Config:GetSetting(name .. "_Popped", true) then
            if Modules:ExecModule(name, "ShouldRender") then
                local open, show = ImGui.Begin(name, true)
                if show then
                    Modules:ExecModule(name, "Render")
                end
                ImGui.End()
                if not open then
                    Config:SetSetting(name .. "_Popped", false)
                end
            end
        end
    end
end

local function Alive()
    return mq.TLO.NearestSpawn('pc')() ~= nil
end

local function GetTheme()
    return Modules:ExecModule("Class", "GetTheme")
end

local function RGMercsGUI()
    local theme = GetTheme()
    local themeColorPop = 0
    local themeStylePop = 0

    if mq.TLO.MacroQuest.GameState() == "CHARSELECT" then
        openGUI = false
        return
    end

    ImGui.SetNextWindowSize(ImVec2(500, 600), ImGuiCond.FirstUseEver)

    if openGUI and Alive() and Config:SettingsLoaded() then
        if initPctComplete < 100 then
            LoaderUI:RenderLoader(initPctComplete, initMsg)
        else
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

            ImGui.PushStyleVar(ImGuiStyleVar.Alpha, Config:GetMainOpacity()) -- Main window opacity.
            ImGui.PushStyleVar(ImGuiStyleVar.ScrollbarRounding, Config:GetSetting('ScrollBarRounding'))
            ImGui.PushStyleVar(ImGuiStyleVar.FrameRounding, Config:GetSetting('FrameEdgeRounding'))
            if Config:GetSetting('PopOutForceTarget') then
                local openFT, showFT = ImGui.Begin("Force Target", Config:GetSetting('PopOutForceTarget'))
                if showFT then
                    Ui.RenderForceTargetList()
                end
                ImGui.End()
                if not openFT then
                    Config:SetSetting('PopOutForceTarget', false)
                    showFT = false
                end
            end
            if Config:GetSetting('PopOutMercsStatus') then
                local openFT, showFT = ImGui.Begin("Mercs Status", Config:GetSetting('PopOutMercsStatus'))
                if showFT then
                    Ui.RenderMercsStatus()
                end
                ImGui.End()
                if not openFT then
                    Config:SetSetting('PopOutMercsStatus', false)
                    showFT = false
                end
            end
            if Config:GetSetting('PopOutConsole') then
                local openConsole, showConsole = ImGui.Begin("Debug Console##RGMercs", Config:GetSetting('PopOutConsole'))
                if showConsole then
                    ConsoleUI:DrawConsole()
                end
                ImGui.End()
                if not openConsole then
                    Config:SetSetting('PopOutConsole', false)
                    showConsole = false
                end
            end

            renderModulesPopped()

            if Config:GetSetting("AlwaysShowMiniButton") or Config.Globals.Minimized then
                HudUI:RenderToggleHud()
            end

            if Config:GetSetting('FullUI') then
                openGUI = StandardUI:RenderMainWindow(imGuiStyle, curState, openGUI)
            else
                openGUI = SimpleUI:RenderMainWindow(imGuiStyle, curState, openGUI)
            end

            if Config:GetSetting('EnableOptionsUI') then
                local openOptionsUI = OptionsUI:RenderMainWindow(imGuiStyle, curState, true)
                if not openOptionsUI then
                    Config:SetSetting('EnableOptionsUI', false)
                end
            end


            ImGui.PopStyleVar(3)

            if themeColorPop > 0 then
                ImGui.PopStyleColor(themeColorPop)
            end
            if themeStylePop > 0 then
                ImGui.PopStyleVar(themeStylePop)
            end
        end
    end
end

mq.imgui.init('RGMercsUI', RGMercsGUI)

-- End UI --
local unloadedPlugins = {}

local function CreateHeartBeat()
    heartbeatCoroutine = coroutine.create(function()
        while (1) do
            Comms.SendHeartbeat(Core.GetMainAssistSpawn().DisplayName(), Config.Globals.PauseMain and "Paused" or curState,
                Targeting.GetAutoTarget() and Targeting.GetAutoTarget().DisplayName() or "None", Config.Globals.ForceCombatID,
                Config:GetSetting('ChaseOn') and Config:GetSetting('ChaseTarget') or "Chase Off")
            coroutine.yield()
        end
    end)
end

local function RGInit(...)
    Core.CheckPlugins({
        "MQ2Rez",
        "MQ2AdvPath",
        "MQ2MoveUtils",
        "MQ2Nav",
        "MQ2DanNet", })

    unloadedPlugins = Core.UnCheckPlugins({ "MQ2Melee", "MQ2Twist", })

    initPctComplete = 0
    initMsg = "Initializing RGMercs..."
    local args = { ..., }
    -- check mini argument before loading other modules so it minimizes as soon as possible.
    if args and #args > 0 then
        Logger.log_info("Arguments passed to RGMercs: %s", table.concat(args, ", "))
        for _, v in ipairs(args) do
            if v == "mini" then
                Config.Globals.Minimized = true
                break
            end
        end
    end

    -- send heartbeat to peers.
    CreateHeartBeat()

    initPctComplete = 10
    initMsg = "Scanning for Configurations..."
    Core.ScanConfigDirs()

    initPctComplete = 20
    initMsg = "Initializing Modules..."
    -- complex objects are passed by reference so we can just use these without having to pass them back in for saving.
    Modules:ExecAll("Init")
    Config.Globals.SubmodulesLoaded = true

    initPctComplete = 30
    initMsg = "Updating Command Handlers..."
    Config:UpdateCommandHandlers()

    initPctComplete = 40
    initMsg = "Setting Assist..."

    Combat.SetMainAssist()

    Ui.GetAssistWarningString()

    local assistString = Config.Globals.MainAssist:len() > 0 and string.format("set to %s.", Config.Globals.MainAssist) or string.format("unset!")

    if Config.TempSettings.AssistWarning then
        Comms.PopUp("RGMercs " .. Config.TempSettings.AssistWarning .. "\nYour assist is currently " .. assistString)
    else
        Comms.PopUp("Welcome to RGMercs!\nYour assist is currently set to %s.", Config.Globals.MainAssist)
    end

    if Core.IAmMA() then
        Logger.log_warn("This PC has assigned itself as the MA! If this is not intentional, please check your assist setup.")
    end

    initPctComplete = 50
    initMsg = "We deleted the thing that used to be here..."

    initPctComplete = 60
    initMsg = "Setting up MQ2DanNet..."
    if mq.TLO.Plugin("MQ2DanNet")() then
        Core.DoCmd("/squelch /dnet commandecho off")
    end

    Movement:DoStickCmd("set breakontarget on")

    initPctComplete = 70
    initMsg = "Closing down Macro..."
    if (mq.TLO.Macro.Name() or ""):find("RGMERC") then
        Core.DoCmd("/macro end")
    end

    initMsg = "Pausing the CWTN Plugin..."
    Core.DoCmd("/squelch /docommand /%s pause on", mq.TLO.Me.Class.ShortName())

    initPctComplete = 80
    initMsg = "Clearing Cursor..."

    if mq.TLO.Cursor() and mq.TLO.Cursor.ID() > 0 then
        Logger.log_info("Sending Item(%s) on Cursor to Bag", mq.TLO.Cursor())
        Core.DoCmd("/autoinventory")
    end

    printf("\aw****************************")
    printf("\aw\awWelcome to \ag%s", Config._AppName)
    printf("\aw\awVersion \ag%s \aw(\at%s\aw)", Config._version, Config._subVersion)
    printf("\aw\awBy \ag%s", Config._author)
    printf("\aw****************************")
    -- keep these for easy editing/addition later
    --  printf("\agThe new options panel is live! See our recent forum post or commit messages.")
    printf("\awPlease visit us on the RG forums for the most recent news and updates.")
    printf("\aw Use \ag /rgl \aw or check our options panel for a list of commands.")

    -- store initial positioning data.
    initPctComplete = 90
    initMsg = "Storing Initial Positioning Data..."
    Config:StoreLastMove()

    initMsg = "Done!"
    initPctComplete = 100

    HudUI:LoadAllOptions()
end

local function Main()
    if mq.TLO.Zone.ID() ~= Config.Globals.CurZoneId or mq.TLO.Me.Instance() ~= Config.Globals.CurInstance then
        if notifyZoning then
            Modules:ExecAll("OnZone")
            notifyZoning = false
            Config.Globals.ForceTargetID = 0
            Config.Globals.IgnoredTargetIDs = Set.new({})
            Config.Globals.AutoTargetID = 0
            Config.Globals.ForceCombatID = 0
        end
        mq.delay(100)
        Config.Globals.CurZoneId = mq.TLO.Zone.ID()
        Config.Globals.CurInstance = mq.TLO.Me.Instance()
        return
    end

    if heartbeatCoroutine then
        if coroutine.status(heartbeatCoroutine) ~= 'dead' then
            local success, err = coroutine.resume(heartbeatCoroutine)
            if not success then
                Logger.log_error("\arError in Heartbeat Coroutine: %s", err)
            end
        else
            CreateHeartBeat()
        end
    end

    Config:ValidatePeers()

    notifyZoning = true

    if mq.TLO.Me.NumGems() ~= Casting.UseGem then
        -- sometimes this can get out of sync.
        Casting.UseGem = mq.TLO.Me.NumGems()
    end

    if Config.Globals.PauseMain then
        mq.delay(100)
        mq.doevents()
        if Config:GetSetting('RunMovePaused') then
            Modules:ExecModule("Movement", "GiveTime", curState)
        end
        Modules:ExecModule("Drag", "GiveTime", curState)
        Modules:ExecModule("Debug", "GiveTime", curState)
        Modules:ExecModule("Clickies", "ValidateClickies")
        Modules:ExecAll("WriteSettings") -- this needs to happen even when paused.
        return
    end

    -- sometimes nav gets interupted this will try to reset it.
    if Config:GetTimeSinceLastMove() > 5 and mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() == 0 then
        Core.DoCmd("/nav stop")
    end

    if Targeting.GetXTHaterCount(true) > 0 then
        if curState == "Downtime" and mq.TLO.Me.Sitting() then
            -- if switching into combat state stand up.
            mq.TLO.Me.Stand()
        end

        curState = "Combat"
        --if os.clock() - Config.Globals.LastFaceTime > 6 then
        if Config:GetSetting('FaceTarget') and not Targeting.FacingTarget() and mq.TLO.Target.ID() ~= mq.TLO.Me.ID() and not mq.TLO.Me.Moving() then
            --Config.Globals.LastFaceTime = os.clock()
            Core.DoCmd("/squelch /face fast")
        end

        if Config:GetSetting('DoMed') == 3 then
            Casting.AutoMed()
        end
    else
        if curState ~= "Downtime" then
            Logger.log_debug("Switching to Downtime state.")

            -- clear the cache during state transition.
            Targeting.ClearSafeTargetCache()
            Targeting.ForceBurnTargetID     = 0
            Config.Globals.LastPulledID     = 0
            Config.Globals.AutoTargetID     = 0
            Config.Globals.IgnoredTargetIDs = Set.new({})
            Casting.LastBurnCheck           = false
            Modules:ExecModule("Pull", "SetLastPullOrCombatEndedTimer")
        end

        curState = "Downtime"

        if Config:GetSetting('DoMed') ~= 1 then
            Casting.AutoMed()
        end
    end

    if mq.TLO.MacroQuest.GameState() ~= "INGAME" then return end

    if Config.Globals.CurLoadedChar ~= mq.TLO.Me.DisplayName() then
        Config:LoadSettings()
        Modules:ExecAll("LoadSettings")
    end

    if Config.Globals.CurLoadedClass ~= mq.TLO.Me.Class.ShortName() then
        ClassLoader.changeLoadedClass()
    end

    Config:StoreLastMove()

    if mq.TLO.Me.Hovering() then Events.HandleDeath() end

    Combat.SetMainAssist()
    Ui.GetAssistWarningString()

    if Combat.FindBestAutoTargetCheck() then
        -- This will find a valid target and set it to : Config.Globals.AutoTargetID
        Combat.FindBestAutoTarget(Combat.OkToEngagePreValidateId)
    end

    if Combat.OkToEngage(Config.Globals.AutoTargetID) then
        Combat.EngageTarget(Config.Globals.AutoTargetID)
    else
        if curState == "Combat" then
            local targetId = Targeting.GetTargetID()
            local ignored = Config.Globals.IgnoredTargetIDs:contains(targetId)                         -- don't target something in our ignore list
            local pullTarget = Config:GetSetting('DoPull') and targetId == Config.Globals.LastPulledID -- don't clear your pull target while its traveling to you
            local assistHater = Core.IAmMA() and Targeting.IsSpawnXTHater(targetId)                    -- don't clear a targeted hater as MA unless it is ignored

            if ignored or (not pullTarget and not assistHater) then
                Logger.log_debug("\ayClearing Target because we are not OkToEngage() and we are in combat!")
                Targeting.ClearTarget()
            end
        elseif mq.TLO.Me.Combat() and (Config:GetSetting('AutoAttackSafety') or not mq.TLO.Target()) then
            Logger.log_debug("\ayTurning off attack because we don't have a target or we are not OkToEngage!")
            Core.DoCmd("/attack off")
        end
    end

    -- Handles state for when we're in combat
    if curState == "Combat" then
        if ((os.clock() - Config.Globals.LastPetCmd) > 2) then
            Config.Globals.LastPetCmd = os.clock()
            if ((Config:GetSetting('DoPet') or Config:GetSetting('CharmOn')) and mq.TLO.Pet.ID() ~= 0) and (Targeting.GetTargetPctHPs(Targeting.GetAutoTarget()) <= Config:GetSetting('PetEngagePct')) then
                Combat.PetAttack(Config.Globals.AutoTargetID, true)
            end
        end

        if Config:GetSetting('DoMercenary') then
            local merc = mq.TLO.Me.Mercenary

            if merc() and merc.ID() then
                if Combat.MercEngage() then
                    if merc.Class.ShortName():lower() == "war" and merc.Stance():lower() ~= "aggressive" then
                        Core.DoCmd("/squelch /stance aggressive")
                    end

                    if merc.Class.ShortName():lower() ~= "war" and merc.Stance():lower() ~= "balanced" then
                        Core.DoCmd("/squelch /stance balanced")
                    end

                    Combat.MercAssist()
                else
                    if merc.Class.ShortName():lower() ~= "clr" and merc.Stance():lower() ~= "passive" then
                        Core.DoCmd("/squelch /stance passive")
                    end
                end
            end
        end
    end

    if Combat.ShouldDoCamp() then
        if Config:GetSetting('DoMercenary') and mq.TLO.Me.Mercenary.ID() and (mq.TLO.Me.Mercenary.Class.ShortName() or "none"):lower() ~= "clr" and mq.TLO.Me.Mercenary.Stance():lower() ~= "passive" then
            Core.DoCmd("/squelch /stance passive")
        end
    end

    if Config.Constants.ModRodUse[Config:GetSetting('ModRodUse')] == "Anytime" or (Config.Constants.ModRodUse[Config:GetSetting('ModRodUse')] == "Combat" and curState == "Combat") then
        Casting.ClickModRod()
    end

    if Combat.ShouldKillTargetReset() then
        Config.Globals.AutoTargetID = 0
    end

    -- Revive our mercenary if they're dead and we're using a mercenary
    if Config:GetSetting('DoMercenary') then
        if mq.TLO.Me.Mercenary.State():lower() == "dead" then
            if mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_SuspendButton").Text():lower() == "revive" then
                mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_SuspendButton").LeftMouseUp()
                mq.delay(1000, function() return (mq.TLO.Me.Mercenary.State() or "dead"):lower() ~= "dead" end)
            end
        else
            if mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_AssistModeCheckbox").Checked() then
                mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_AssistModeCheckbox").LeftMouseUp()
            end
        end
    end

    Modules:ExecAll("GiveTime", curState)
    Modules:ExecAll("WriteSettings")

    mq.doevents()
    mq.delay(10)
end

-- Global Messaging callback
---@diagnostic disable-next-line: unused-local
local script_actor = Comms.Actors.register(function(message)
    local msg = message()
    if msg.From == Comms.GetPeerName() then return end
    if msg.Script ~= Comms.ScriptName then return end

    Logger.log_verbose("\ayGot Event from(\am%s\ay) module(\at%s\ay) event(\at%s\ay)", msg.From,
        msg.Module,
        msg.Event)

    -- This is a core event so handle it here.
    if msg.Event == "Heartbeat" then
        --Logger.log_debug("Received Heartbeat from \am%s\aw: \ag%s", msg.From, Strings.TableToString(msg.Data))
        Config:UpdatePeerHeartbeat(msg.From, msg.Data)
        return
    end

    if msg.Event == "DoCmd" then
        --Logger.log_debug("Received Heartbeat from \am%s\aw: \ag%s", msg.From, Strings.TableToString(msg.Data))
        Logger.log_debug("Received Command from \am%s\aw: \ag%s", msg.From, msg.Data.cmd or "nil")
        Core.DoCmd(msg.Data.cmd)
        return
    end

    if msg.Module == "Config" then
        if msg.Event and Config[msg.Event] then
            Config[msg.Event](Config, msg.Data)
        end
        return
    end

    -- all other handlers
    if Modules:GetModule(msg.Module) then
        Modules:ExecModule(msg.Module, msg.Event, msg.Data)
        return
    end
end)

-- Binds

mq.bind("/rglua", Binds.MainHandler)

RGInit(...)

while openGUI do
    Main()
    mq.doevents()
    mq.delay(10)
end

Core.CheckPlugins(unloadedPlugins, true)

Modules:ExecAll("Shutdown")
