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

-- Initialize class-based moduldes
local Modules     = require("utils.modules")
Modules:load()

require('utils.datatypes')

-- ImGui Variables
local openGUI         = true
local notifyZoning    = true
local curState        = "Downtime"

local initPctComplete = 0
local initMsg         = "Initializing RGMercs..."

-- UI --
local SimpleUI        = require("ui.simple")
local StandardUI      = require("ui.standard")
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

    if openGUI and Alive() then
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
    printf("\aw\awWelcome to \ag%s", Config._name)
    printf("\aw\awVersion \ag%s \aw(\at%s\aw)", Config._version, Config._subVersion)
    printf("\aw\awBy \ag%s", Config._author)
    printf("\aw****************************")
    -- keep these for easy editing/additon later
    printf("\agOur Assist System has been revamped! See our recent forum post or commit messages.")
    printf("\awPlease visit us on the RG forums for the most recent news and updates.")
    printf("\aw use \ag /rg \aw for a list of commands")

    -- store initial positioning data.
    initPctComplete = 90
    initMsg = "Storing Initial Positioning Data..."
    Config:StoreLastMove()

    initMsg = "Done!"
    initPctComplete = 100
end

local function Main()
    if mq.TLO.Zone.ID() ~= Config.Globals.CurZoneId or mq.TLO.Me.Instance() ~= Config.Globals.CurInstance then
        if notifyZoning then
            Modules:ExecAll("OnZone")
            notifyZoning = false
            Config.Globals.ForceTargetID = 0
            Config.Globals.AutoTargetID = 0
        end
        mq.delay(100)
        Config.Globals.CurZoneId = mq.TLO.Zone.ID()
        Config.Globals.CurInstance = mq.TLO.Me.Instance()
        return
    end

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
        Modules:ExecAll("WriteSettings") -- this needs to happen even when paused.
        return
    end

    -- sometimes nav gets interupted this will try to reset it.
    if Config:GetTimeSinceLastMove() > 5 and mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() == 0 then
        Core.DoCmd("/nav stop")
    end

    if Targeting.GetXTHaterCount() > 0 then
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
            -- clear the cache during state transition.
            Targeting.ClearSafeTargetCache()
            Targeting.ForceBurnTargetID = 0
            Config.Globals.LastPulledID = 0
            Config.Globals.AutoTargetID = 0
            Casting.LastBurnCheck = false
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
        if Targeting.GetXTHaterCount(true) > 0 and Targeting.GetTargetID() ~= (Config:GetSetting('DoPull') and Config.Globals.LastPulledID or 0) and not Core.IsMezzing() and not Core.IsCharming() and not (Core.IAmMA() and Targeting.IsSpawnXTHater(mq.TLO.Target.ID())) then
            Logger.log_debug("\ayClearing Target because we are not OkToEngage() and we are in combat!")
            Targeting.ClearTarget()
        end
    end
    -- Handles state for when we're in combat
    if Combat.DoCombatActions() then
        -- IsHealing or IsMezzing should re-determine their target as this point because they may
        -- have switched off to mez or heal after the initial find target check and the target
        -- may have changed by this point.
        if not Config:GetSetting('PriorityHealing') then
            if Combat.FindBestAutoTargetCheck() and (not Core.IsHealing() or not Core.IsMezzing() or not Core.IsCharming()) then
                Combat.FindBestAutoTarget(Combat.OkToEngagePreValidateId)
            end
        end

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

    if Config:GetSetting('DoModRod') then
        Casting.ClickModRod()
    end

    if Combat.ShouldKillTargetReset() then
        Config.Globals.AutoTargetID = 0
    end

    -- If target is not attackable then turn off attack
    local pcCheck = Targeting.TargetIsType("pc") or
        (Targeting.TargetIsType("pet") and Targeting.TargetIsType("pc", mq.TLO.Target.Master))
    local mercCheck = Targeting.TargetIsType("mercenary")
    if mq.TLO.Me.Combat() and (not mq.TLO.Target() or pcCheck or mercCheck) then
        Logger.log_debug(
            "\ay[1] Target type check failed \aw[\atinCombat(%s) pcCheckFailed(%s) mercCheckFailed(%s)\aw]\ay - turning attack off!",
            Strings.BoolToColorString(mq.TLO.Me.Combat()), Strings.BoolToColorString(pcCheck),
            Strings.BoolToColorString(mercCheck))
        Core.DoCmd("/attack off")
    end

    -- Revive our mercenary if they're dead and we're using a mercenary
    if Config:GetSetting('DoMercenary') then
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

    Modules:ExecAll("GiveTime", curState)
    Modules:ExecAll("WriteSettings")

    mq.doevents()
    mq.delay(10)
end

-- Global Messaging callback
---@diagnostic disable-next-line: unused-local
local script_actor = Comms.Actors.register(function(message)
    local msg = message()
    if msg.from == Config.Globals.CurLoadedChar then return end
    if msg.script ~= Comms.ScriptName then return end

    Logger.log_verbose("\ayGot Event from(\am%s\ay) module(\at%s\ay) event(\at%s\ay)", msg.from,
        msg.module,
        msg.event)

    if msg.module then
        if msg.module == "main" then
            Config:LoadSettings()
        else
            Modules:ExecModule(msg.module, msg.event, msg.data)
        end
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

Core.CheckPlugins(unloadedPlugins)

Modules:ExecAll("Shutdown")
