local mq         = require('mq')
local ImGui      = require('ImGui')
local GitCommit  = require('extras.version')
local Icons      = require('mq.ICONS')

-- Preload these incase any modules need them.
local PackageMan = require('mq/PackageMan')
PackageMan.Require('lsqlite3')
PackageMan.Require('luafilesystem', 'lfs')

local Config = require('utils.config')
Config:LoadSettings()

local Logger = require("utils.logger")
Logger.set_log_level(Config:GetSettings().LogLevel)
Logger.set_log_to_file(Config:GetSettings().LogToFile)

local Binds = require('utils.binds')
require('utils.event_handlers')

local Console     = require('utils.console')
local Core        = require("utils.core")
local ClassLoader = require('utils.classloader')
local Targeting   = require("utils.targeting")
local Combat      = require("utils.combat")
local Casting     = require("utils.casting")
local Events      = require("utils.events")
local Ui          = require("utils.ui")
local Comms       = require("utils.comms")
local Strings     = require("utils.strings")

-- Initialize class-based moduldes
local Modules     = require("utils.modules")
Modules:load()

require('utils.datatypes')

-- ImGui Variables
local openGUI         = true
local shouldDrawGUI   = true
local notifyZoning    = true
local curState        = "Downtime"
local logFilter       = ""
local logFilterLocked = true
local initPctComplete = 0
local initMsg         = "Initializing RGMercs..."

-- Icon Rendering
local derpImg         = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/derpdog_60.png")
--local burnImg2        = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/derpdog_burn.png") -- DerpDog Burning Ring of Fire
local burnImg         = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/algar2_60.png") -- Algar
local grimImg         = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/grim_60.png")   -- Grim
local imgDisplayed

-- Function to randomly pick the image only once
local function InitLoader()
    if not imgDisplayed then
        math.randomseed(os.time())
        local images = { derpImg, burnImg, grimImg, }

        imgDisplayed = images[math.floor(math.random(1000, ((#images + 1) * 1000) - 1) / 1000)]
    end
end

-- Constants

-- UI --
local function renderModulesTabs()
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

local function RenderLoader()
    InitLoader()

    ImGui.SetNextWindowSize(ImVec2(400, 80), ImGuiCond.Always)
    ImGui.SetNextWindowPos(ImVec2(ImGui.GetIO().DisplaySize.x / 2 - 200, ImGui.GetIO().DisplaySize.y / 3 - 75), ImGuiCond.Always)

    ImGui.Begin("RGMercs Loader", nil, bit32.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoScrollbar))

    -- Display the selected image (picked only once)
    ImGui.Image(imgDisplayed:GetTextureID(), ImVec2(60, 60))
    ImGui.SameLine()
    ImGui.Text("RGMercs %s: Loading...", Config._version)
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 35)
    ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 70)
    ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0.2, 0.7, 1 - (initPctComplete / 100), initPctComplete / 100)
    ImGui.ProgressBar(initPctComplete / 100, ImVec2(310, 0), initMsg)
    ImGui.PopStyleColor()
    ImGui.End()
end

local function RenderTarget()
    if (mq.TLO.Raid() and not mq.TLO.Raid.MainAssist(1)()) or (mq.TLO.Group() and not mq.TLO.Group.MainAssist()) then
        ImGui.TextColored(IM_COL32(200, math.floor(os.clock() % 2) == 1 and 52 or 200, 52, 255),
            string.format("Warning: NO GROUP MA - PLEASE SET ONE!"))
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

local function RenderWindowControls()
    --local draw_list = ImGui.GetWindowDrawList()
    local position = ImGui.GetCursorPosVec()
    local smallButtonSize = 32

    local windowControlPos = ImVec2(ImGui.GetWindowWidth() - (smallButtonSize * 2), smallButtonSize)
    ImGui.SetCursorPos(windowControlPos)

    if ImGui.SmallButton((Config.settings.MainWindowLocked or false) and Icons.FA_LOCK or Icons.FA_UNLOCK) then
        Config.settings.MainWindowLocked = not Config.settings.MainWindowLocked
        Config:SaveSettings()
    end

    ImGui.SameLine()
    if ImGui.SmallButton(Icons.FA_WINDOW_MINIMIZE) then
        Config.Globals.Minimized = true
    end
    Ui.Tooltip("Minimize Main Window")

    ImGui.SetCursorPos(position)
end

local function DrawConsole(showPopout)
    local RGMercsConsole = Console:GetConsole("##RGMercs", Config:GetMainOpacity())

    if RGMercsConsole then
        if showPopout then
            if ImGui.SmallButton(Icons.MD_OPEN_IN_NEW) then
                Config:SetSetting('PopOutConsole', true)
            end
            Ui.Tooltip("Pop the Console out into its own window.")
            ImGui.NewLine()
        end

        local changed
        if ImGui.BeginTable("##debugoptions", 2, ImGuiTableFlags.None) then
            ImGui.TableSetupColumn("Opt Name", bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.NoResize), 100)
            ImGui.TableSetupColumn("Opt Value", ImGuiTableColumnFlags.WidthStretch)
            ImGui.TableNextColumn()
            Config:GetSettings().LogToFile, changed = Ui.RenderOptionToggle("##log_to_file",
                "", Config:GetSettings().LogToFile)
            if changed then
                Config:SaveSettings()
            end
            ImGui.TableNextColumn()
            ImGui.Text("Log to File")
            ImGui.TableNextColumn()
            ImGui.Text("Debug Level")
            ImGui.TableNextColumn()
            Config:GetSettings().LogLevel, changed = ImGui.Combo("##Debug Level",
                Config:GetSettings().LogLevel, Config.Constants.LogLevels,
                #Config.Constants.LogLevels)

            if changed then
                Config:SaveSettings()
            end
            ImGui.TableNextColumn()
            ImGui.Text("Log Filter")
            ImGui.SameLine()
            if ImGui.Button(logFilterLocked and Icons.FA_LOCK or Icons.FA_UNLOCK, 22, 22) then
                logFilterLocked = not logFilterLocked
            end
            ImGui.TableNextColumn()
            ImGui.BeginDisabled(logFilterLocked)

            logFilter, changed = ImGui.InputText("##logfilter", logFilter)

            ImGui.EndDisabled()

            if changed then
                if logFilter:len() == 0 then
                    Logger.clear_log_filter()
                else
                    Logger.set_log_filter(logFilter)
                end
            end
            ImGui.EndTable()
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
            RenderLoader()
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
            ImGui.PushStyleVar(ImGuiStyleVar.ScrollbarRounding, Config:GetSettings().ScrollBarRounding)
            ImGui.PushStyleVar(ImGuiStyleVar.FrameRounding, Config:GetSettings().FrameEdgeRounding)
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
                    DrawConsole()
                end
                ImGui.End()
                if not openConsole then
                    Config:SetSetting('PopOutConsole', false)
                    showConsole = false
                end
            end
            renderModulesPopped()
            if not Config.Globals.Minimized then
                local flags = ImGuiWindowFlags.None

                if Config.settings.MainWindowLocked then
                    flags = bit32.bor(flags, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoResize)
                end

                openGUI, shouldDrawGUI = ImGui.Begin(('RGMercs%s###rgmercsui'):format(Config.Globals.PauseMain and " [Paused]" or ""), openGUI, flags)
            else
                local flags = bit32.bor(ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoTitleBar)
                openGUI, shouldDrawGUI = ImGui.Begin(('RGMercsMin###rgmercsuiMin'), openGUI, flags)
            end
            ImGui.PushID("##RGMercsUI_" .. Config.Globals.CurLoadedChar)

            if shouldDrawGUI and not Config.Globals.Minimized then
                local pressed
                local imgDisplayed = Casting.LastBurnCheck and burnImg or derpImg
                ImGui.Image(imgDisplayed:GetTextureID(), ImVec2(60, 60))
                ImGui.SameLine()
                ImGui.Text(string.format("RGMercs %s [%s]\nClass Config: %s\nAuthor(s): %s",
                    Config._version,
                    GitCommit.commitId or "None",
                    Modules:ExecModule("Class", "GetVersionString"),
                    Modules:ExecModule("Class", "GetAuthorString"))
                )

                RenderWindowControls()

                if not Config.Globals.PauseMain then
                    ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.7, 0.3, 1)
                else
                    ImGui.PushStyleColor(ImGuiCol.Button, 0.7, 0.3, 0.3, 1)
                end

                local pauseLabel = Config.Globals.PauseMain and "PAUSED" or "Running"
                if Config.Globals.BackOffFlag then
                    pauseLabel = pauseLabel .. " [Backoff]"
                end

                if ImGui.Button(pauseLabel, (ImGui.GetWindowWidth() - ImGui.GetCursorPosX() - (ImGui.GetScrollMaxY() == 0 and 0 or imGuiStyle.ScrollbarSize) - imGuiStyle.WindowPadding.x), 40) then
                    Config.Globals.PauseMain = not Config.Globals.PauseMain
                end
                ImGui.PopStyleColor()

                RenderTarget()

                ImGui.NewLine()
                ImGui.Separator()

                if ImGui.BeginTabBar("RGMercsTabs", ImGuiTabBarFlags.Reorderable) then
                    ImGui.SetItemDefaultFocus()
                    if ImGui.BeginTabItem("RGMercsMain") then
                        ImGui.Text("Current State: " .. curState)
                        ImGui.Text("Hater Count: " .. tostring(Targeting.GetXTHaterCount()))

                        -- .. tostring(Config.Globals.AutoTargetID))
                        ImGui.Text("MA: %-25s", (Core.GetMainAssistSpawn().CleanName() or "None"))
                        if mq.TLO.Target.ID() > 0 and Targeting.TargetIsType("pc") and Config.Globals.MainAssist ~= mq.TLO.Target.ID() then
                            ImGui.SameLine()
                            if ImGui.SmallButton(string.format("Set MA to %s", Targeting.GetTargetCleanName())) then
                                Config.Globals.MainAssist = mq.TLO.Target.CleanName()
                            end
                        end
                        ImGui.Text("Stuck To: " ..
                            (mq.TLO.Stick.Active() and (mq.TLO.Stick.StickTargetName() or "None") or "None"))
                        if ImGui.CollapsingHeader("Outside Assist List") then
                            ImGui.Indent()
                            Ui.RenderOAList()
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
                                local settingsRef = Config:GetSettings()
                                settingsRef, pressed, _ = Ui.RenderSettings(settingsRef, Config.DefaultConfig,
                                    Config.DefaultCategories, false, true)
                                if pressed then
                                    Config:SaveSettings()
                                end
                            end
                            if Config:GetSetting('ShowAllOptionsMain') then
                                if Config.Globals.SubmodulesLoaded then
                                    local submoduleSettings = Modules:ExecAll("GetSettings")
                                    local submoduleDefaults = Modules:ExecAll("GetDefaultSettings")
                                    local submoduleCategories = Modules:ExecAll("GetSettingCategories")
                                    for n, s in pairs(submoduleSettings) do
                                        if Modules:ExecModule(n, "ShouldRender") then
                                            ImGui.PushID(n .. "_config_hdr")
                                            if s and submoduleDefaults[n] and submoduleCategories[n] then
                                                if ImGui.CollapsingHeader(string.format("%s: Config Options", n), bit32.bor(ImGuiTreeNodeFlags.DefaultOpen, ImGuiTreeNodeFlags.Leaf)) then
                                                    s, pressed, _ = Ui.RenderSettings(s, submoduleDefaults[n],
                                                        submoduleCategories[n], true)
                                                    if pressed then
                                                        Modules:ExecModule(n, "SaveSettings", true)
                                                    end
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

                    renderModulesTabs()


                    ImGui.EndTabBar();
                end

                ImGui.Separator()
                if not Config:GetSetting('PopOutConsole') then
                    if ImGui.CollapsingHeader("Console") then
                        DrawConsole(true)
                    end
                end
            elseif shouldDrawGUI and Config.Globals.Minimized then
                local btnImg = Casting.LastBurnCheck and burnImg or derpImg
                if Config.Globals.PauseMain then
                    if ImGui.ImageButton('RGMercsButton', btnImg:GetTextureID(), ImVec2(30, 30), ImVec2(0.0, 0.0), ImVec2(1, 1), ImVec4(0, 0, 0, 0), ImVec4(1, 0, 0, 1)) then
                        Config.Globals.Minimized = false
                    end
                    if ImGui.IsItemHovered() then
                        ImGui.SetTooltip("RGMercs is Paused.")
                    end
                else
                    if ImGui.ImageButton('RGMercsButton', btnImg:GetTextureID(), ImVec2(30, 30)) then
                        Config.Globals.Minimized = false
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
            end

            ImGui.PopID()
            ImGui.PopStyleVar(3)
            if ImGui.IsWindowFocused(ImGuiFocusedFlags.RootAndChildWindows) then
                if ImGui.IsKeyPressed(ImGuiKey.Escape) and Config:GetSetting("EscapeMinimizes") then
                    Config.Globals.Minimized = true
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
    local mainAssist = mq.TLO.Me.CleanName()

    if mq.TLO.Group() and mq.TLO.Group.MainAssist() then
        mainAssist = mq.TLO.Group.MainAssist() or ""
    end

    for k, v in ipairs(Config.Constants.ExpansionIDToName) do
        Logger.log_debug("\ayExpansion \at%-22s\ao[\am%02d\ao]: %s", v, k,
            Core.HaveExpansion(v) and "\agEnabled" or "\arDisabled")
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

    if mainAssist:len() > 0 then
        Config.Globals.MainAssist = mainAssist
        Comms.PopUp("Targeting %s for Main Assist", Config.Globals.MainAssist)
        Targeting.SetTarget(Core.GetMainAssistId(), true)
        Logger.log_info("\aw Assisting \ay >> \ag %s \ay << \aw at \ag %d%%", Config.Globals.MainAssist,
            Config:GetSetting('AutoAssistAt'))
    end

    if Core.GetGroupMainAssistName() ~= mainAssist then
        Comms.PopUp(string.format(
            "Assisting: %s NOTICE: Group MainAssist [%s] != Your Assist Target [%s]. Is This On Purpose?", mainAssist,
            Core.GetGroupMainAssistName(), mainAssist))
    end

    initPctComplete = 50
    initMsg = "Setting up Environment..."
    Core.DoCmd("/squelch /rez accept on")
    Core.DoCmd("/squelch /rez pct 90")

    initPctComplete = 60
    initMsg = "Setting up MQ2DanNet..."
    if mq.TLO.Plugin("MQ2DanNet")() then
        Core.DoCmd("/squelch /dnet commandecho off")
    end

    Core.DoCmd("/stick set breakontarget on")

    -- TODO: Chat Begs
    initPctComplete = 70
    initMsg = "Closing down Macro..."
    if (mq.TLO.Macro.Name() or ""):find("RGMERC") then
        Core.DoCmd("/macro end")
    end

    -- Comms.PrintGroupMessage("Pausing the CWTN Plugin on this host if it exists! (/%s pause on)",
    --     mq.TLO.Me.Class.ShortName())
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
    printf("\agDefault Configs have been updated on 2/19/2025:")
    printf("\agROG, MNK, CLR 2.0 have now been released!")
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
    if mq.TLO.Zone.ID() ~= Config.Globals.CurZoneId then
        if notifyZoning then
            Modules:ExecAll("OnZone")
            notifyZoning = false
            Config.Globals.ForceTargetID = 0
        end
        mq.delay(100)
        Config.Globals.CurZoneId = mq.TLO.Zone.ID()
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
        --Modules:ExecModule("Exp", "GiveTime", curState)
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
            Core.DoCmd("/squelch /face")
        end

        if Config:GetSetting('DoMed') == 3 then
            Casting.AutoMed()
        end
    else
        if curState ~= "Downtime" then
            -- clear the cache during state transition.
            Targeting.ClearSafeTargetCache()
            Targeting.ForceBurnTargetID = 0
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

    Combat.SetControlToon()

    if Combat.FindBestAutoTargetCheck() then
        -- This will find a valid target and set it to : Config.Globals.AutoTargetID
        Combat.FindBestAutoTarget(Combat.OkToEngagePreValidateId)
    end
    if Combat.OkToEngage(Config.Globals.AutoTargetID) then
        Combat.EngageTarget(Config.Globals.AutoTargetID)
    else
        if Targeting.GetXTHaterCount(true) > 0 and Targeting.GetTargetID() > 0 and not Core.IsMezzing() and not Core.IsCharming() then
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
