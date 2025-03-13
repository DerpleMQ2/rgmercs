-- Sample Basic Class Module
local mq                           = require('mq')
local Config                       = require('utils.config')
local Math                         = require('utils.math')
local Combat                       = require('utils.combat')
local Core                         = require("utils.core")
local Targeting                    = require("utils.targeting")
local Casting                      = require("utils.casting")
local Ui                           = require("utils.ui")
local Comms                        = require("utils.comms")
local Strings                      = require("utils.strings")
local Files                        = require("utils.files")
local Logger                       = require("utils.logger")
local Set                          = require("mq.Set")
local Icons                        = require('mq.ICONS')

local Module                       = { _version = '0.1a', _name = "Movement", _author = 'Derple', }
Module.__index                     = Module
Module.ModuleLoaded                = false
Module.TempSettings                = {}
Module.TempSettings.CampZoneId     = 0
Module.TempSettings.LastCmd        = ""
Module.FAQ                         = {}
Module.ClassFAQ                    = {}

Module.Constants                   = {}
Module.Constants.GGHZones          = Set.new({ "poknowledge", "potranquility", "stratos", "guildlobby", "moors", "crescent", "guildhalllrg_int", "guildhall", })
Module.Constants.CampfireNameToKit = {
    ['Regular Fellowship']           = 1,
    ['Empowered Fellowship']         = 2,
    ['Empowered Barbarian']          = 3,
    ['Empowered Dark Elf']           = 4,
    ['Empowered Dwarf']              = 5,
    ['Empowered Erudite']            = 6,
    ['Empowered Gnome']              = 7,
    ['Empowered Half Elf']           = 8,
    ['Empowered Halfling']           = 9,
    ['Empowered High Elf']           = 10,
    ['Empowered Human']              = 11,
    ['Empowered Iksar']              = 12,
    ['Empowered Ogre']               = 13,
    ['Empowered Troll']              = 14,
    ['Empowered Vah Shir']           = 15,
    ['Empowered Woodelf']            = 16,
    ['Empowered Guktan']             = 17,
    ['Empowered Drakkin']            = 18,
    ['Empowered Earthen Elemental']  = 19,
    ['Empowered Aery Elemental']     = 20,
    ['Empowered Firey Elemental']    = 21,
    ['Empowered Aqueous Elemental']  = 22,
    ['Empowered Spirit Wolf']        = 23,
    ['Empowered Werewolf']           = 24,
    ['Empowered Evil Eye']           = 25,
    ['Empowered Imp']                = 26,
    ['Empowered Froglok']            = 27,
    ['Empowered Scarecrow']          = 28,
    ['Empowered Skeleton']           = 29,
    ['Empowered Drybone Skeleton']   = 30,
    ['Empowered Frostbone Skeleton'] = 31,
    ['Empowered Orc']                = 32,
    ['Empowered Goblin']             = 33,
    ['Empowered Sporali']            = 34,
    ['Empowered Fairy']              = 35,
    ['Scaled Wolf']                  = 36,
}


Module.Constants.CampfireTypes = { 'All Off', }
for t, _ in pairs(Module.Constants.CampfireNameToKit) do table.insert(Module.Constants.CampfireTypes, t) end
table.sort(Module.Constants.CampfireTypes)

Module.DefaultConfig   = {
    ['AutoCampRadius']                         = {
        DisplayName = "Auto Camp Radius",
        Category = "Camp",
        Tooltip = "Return to camp after you get this far away",
        Default = (Config.Constants.RGMelee:contains(mq.TLO.Me.Class.ShortName()) and 30 or 60),
        Min = 10,
        Max = 300,
        FAQ = "I want to keep all of my characters within the same range for the camp, how do I do that?",
        Answer = "Enabling [AutoCampRadius] will make all of your characters return to camp when they are this far away from their camp location.",
    },
    ['ChaseOn']                                = {
        DisplayName = "Chase On",
        Category = "Chase",
        Tooltip = "Chase your Chase Target.",
        Default = false,
        FAQ = "How do I make my follow my driver?",
        Answer = "Set the Driver to [ChaseTarget] and Turn on [ChaseOn] and you will follow your Chase Target.",
    },
    ['BreakOnDeath']                           = {
        DisplayName = "Break On Death",
        Category = "Chase",
        Tooltip = "Stop chasing when you die.",
        Default = false,
        FAQ = "I died and my character started running back to my driver, how do I stop that?",
        Answer = "Enable [BreakOnDeath] and your character will stop chasing when you die.",
    },
    ['ChaseDistance']                          = {
        DisplayName = "Chase Distance",
        Category = "Chase",
        Tooltip = "How Far your Chase Target can get before you Chase.",
        Default = 25,
        Min = 5,
        Max = 100,
        FAQ = "How can I adjust when my characters all start following me?",
        Answer = "Set [ChaseDistance] the distance you want them to start chasing, when you are outside of this range they will start to come your way.",
    },
    ['ChaseStopDistance']                      = {
        DisplayName = "Chase Stop Distance",
        Category = "Chase",
        Tooltip = "How close to get to your chase target before you stop.",
        Default = 25,
        Min = 5,
        Max = 100,
        FAQ = "How do I make my goobers not try and stand on top of me?",
        Answer = "Set [ChaseStopDistance] to a higher number stop chasing you further away.",
    },
    ['ChaseTarget']                            = {
        DisplayName = "Chase Target",
        Category = "Chase",
        Tooltip = "Character you are Chasing",
        Type = "Custom",
        Default = "",
        FAQ = "How do I tell my group who to follow?",
        Answer = "Set the person to follow as the [ChaseTarget] and Turn on [ChaseOn] and you will follow your Chase Target.",
    },
    ['ReturnToCamp']                           = {
        DisplayName = "Return To Camp",
        Category = "Camp",
        Tooltip = "Return to Camp After Combat (requires you to /rgl campon)",
        Default = (not Config.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName())),
        FAQ = "How do I make my characters return to camp after combat?",
        Answer = "Enable [ReturnToCamp] and your characters will return to camp after combat.",
    },
    ['CampHard']                               = {
        DisplayName = "Camp Hard",
        Category = "Camp",
        Tooltip = "Return to Camp Loc Everytime",
        Default = false,
        FAQ = "I want to make sure my characters always return to camp, and always stay in the same positions within camp. How do I do that?",
        Answer = "Enable [CampHard] and your characters will always return to camp after combat and in the same positions (loc) within camp.",
    },
    ['MaintainCampfire']                       = {
        DisplayName = "Maintain Campfire",
        Category = "Camp",
        Tooltip = "1: Off; 2: Regular Fellowship; [X]: Empowered Fellowship X;",
        Type = "Combo",
        ComboOptions = Module.Constants.CampfireTypes,
        Default = 1,
        Min = 1,
        Max = #Module.Constants.CampfireTypes,
        FAQ = "I want to make sure my characters always have a campfire, how do I do that?",
        Answer = "Enable [MaintainCampfire] and your characters will always have a campfire." ..
            "You can select the type of campfire you want to use from the drop down.",
    },
    ['RequireLoS']                             = {
        DisplayName = "Require LOS",
        Category = "Chase",
        Tooltip = "Require LOS when using /nav",
        Default = Config.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()),
        FAQ = "I want to make sure my characters always have line of sight to their target, how do I do that?",
        Answer = "Enable [RequireLoS] and your characters will try and maintain line of sight to their target when using NAV.",
    },
    ['PriorityFollow']                         = {
        DisplayName = "Prioritize Follow",
        Category = "Chase",
        Tooltip = "If enabled (and you are not the Chase Target), you will prioritize staying in range of the Chase Target over any other actions.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "I want to make sure my characters always follow me, we can rebuff when we arrive. How do I do that?",
        Answer = "Enable [PriorityFollow] and your characters will prioritize staying in range of the Chase Target over any other actions.",
    },
    ['DoFellow']                               = {
        DisplayName = "Enable Fellowship Insignia",
        Category = "Camp",
        Tooltip = "Use fellowship insignia automatically.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "I have my Fellowship Insignia and want to use it, how do I do that?",
        Answer = "Enable [DoFellow] and your characters will use the fellowship insignia automatically.",
    },
    ['RunMovePaused']                          = {
        DisplayName = "Run Movement on Pause",
        Category = "Chase",
        Tooltip = "Runs the Movement/Chase module even if the Main loop is paused",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "I want to make sure my characters always follow me, even if I pause the main loop. How do I do that?",
        Answer = "Enable [RunMovePaused] and your characters will follow you even if the main loop is paused.",
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Category = "Custom",
        Tooltip = Module._name .. " Pop Out Into Window",
        Default = false,
        FAQ = "Can I pop out the " .. Module._name .. " module into its own window?",
        Answer =
        "You can set the click the popout button at the top of a tab or heading to pop it into its own window.\n Simply close the window and it will snap back to the main window.",
    },
}

Module.CommandHandlers = {
    chaseon = {
        usage = "/rgl chaseon <name?>",
        about = "Chase <name> (uses your current target if no name is supplied).",
        handler = function(self, params)
            self:ChaseOn(params)
        end,
    },
    chaseoff = {
        usage = "/rgl chaseoff",
        about = "Stop chasing your current chase target.",
        handler = function(self, _)
            self:ChaseOff()
        end,
    },
    campon = {
        usage = "/rgl campon",
        about = "Set a camp here.",
        handler = function(self, _)
            self:CampOn()
        end,
    },
    campoff = {
        usage = "/rgl campoff",
        about = "Clear your current camp.",
        handler = function(self, _)
            self:CampOff()
        end,
    },
}

local function getConfigFileName()
    local oldFile = mq.configDir ..
        '/rgmercs/PCConfigs/' ..
        Module._name .. "_" .. Config.Globals.CurServer .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
    local newFile = mq.configDir ..
        '/rgmercs/PCConfigs/' ..
        Module._name .. "_" .. Config.Globals.CurServer .. "_" .. Config.Globals.CurLoadedChar .. "_" .. Config.Globals.CurLoadedClass:lower() .. '.lua'

    if Files.file_exists(newFile) then
        return newFile
    end

    Files.copy_file(oldFile, newFile)

    return newFile
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if Config:GetSetting('ReturnToCamp') then
        Core.DoCmd("/squelch /mapfilter campradius %d", Config:GetSetting('AutoCampRadius'))
        Core.DoCmd("/squelch /mapfilter pullradius %d", Config:GetSetting('PullRadius'))
    else
        Core.DoCmd("/squelch /mapfilter campradius off")
        Core.DoCmd("/squelch /mapfilter pullradius off")
    end

    if doBroadcast == true then
        Comms.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    Logger.log_debug("Chase Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Basic]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self.settings = {}
        self:SaveSettings(false)
    else
        self.settings = config()
    end

    Module.DefaultCategories = Set.new({})
    for k, v in pairs(Module.DefaultConfig or {}) do
        if v.Type ~= "Custom" then
            Module.DefaultCategories:add(v.Category)
        end
        Module.FAQ[k] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', Settings_Used = k, }
    end

    local settingsChanged = false

    -- Setup Defaults
    self.settings, settingsChanged = Config.ResolveDefaults(self.DefaultConfig, self.settings)

    if settingsChanged then
        self:SaveSettings(false)
    end
end

function Module:GetSettings()
    return self.settings
end

function Module:GetDefaultSettings()
    return self.DefaultConfig
end

function Module:GetSettingCategories()
    return self.DefaultCategories
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Chase Module Loaded.")
    self:LoadSettings()
    self.ModuleLoaded = true
    return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ChaseOn(target)
    local chaseTarget = Core.GetMainAssistSpawn()

    if not chaseTarget or not chaseTarget() then
        chaseTarget = mq.TLO.Target
    end

    if target then
        chaseTarget = mq.TLO.Spawn("pc =" .. target)
    end

    if chaseTarget() and chaseTarget.ID() > 0 and Targeting.TargetIsType("PC", chaseTarget) then
        self:CampOff()
        self.settings.ChaseOn = true
        self.settings.ChaseTarget = chaseTarget.CleanName()
        self:SaveSettings(false)

        Logger.log_info("\aoNow Chasing \ag%s", chaseTarget.CleanName())
    else
        Logger.log_warn("\ayWarning:\ax Not a valid chase target!")
    end
end

function Module:RunCmd(cmd, ...)
    local formattedCmd = cmd

    if ... ~= nil then
        formattedCmd = string.format(cmd, ...)
    end

    self.TempSettings.LastCmd = formattedCmd
    Core.DoCmd(formattedCmd)
end

function Module:ChaseOff()
    if self.settings.ChaseOn == false then return end
    Logger.log_info("\ayNo longer chasing \at%s\ay.", self.settings.ChaseTarget or "None")
    self.settings.ChaseOn = false
    self.settings.ChaseTarget = ""
    self:SaveSettings(false)
end

function Module:CampOn()
    self:ChaseOff()
    self.settings.ReturnToCamp   = true
    self.TempSettings.AutoCampX  = mq.TLO.Me.X()
    self.TempSettings.AutoCampY  = mq.TLO.Me.Y()
    self.TempSettings.AutoCampZ  = mq.TLO.Me.Z()
    self.TempSettings.CampZoneId = mq.TLO.Zone.ID()
    Core.DoCmd("/squelch /mapfilter campradius %d", Config:GetSetting('AutoCampRadius'))
    Core.DoCmd("/squelch /mapfilter pullradius %d", Config:GetSetting('PullRadius'))
    Logger.log_info("\ayCamping On: (X: \at%d\ay ; Y: \at%d\ay)", self.TempSettings.AutoCampX, self.TempSettings.AutoCampY)
end

---@return table # camp settings table
function Module:GetCampData()
    return { returnToCamp = (self.settings.ReturnToCamp and self.TempSettings.CampZoneId == mq.TLO.Zone.ID()), campSettings = self.TempSettings, }
end

---@return boolean
function Module:InCampZone()
    return self.TempSettings.CampZoneId == mq.TLO.Zone.ID()
end

function Module:CampOff()
    self.settings.ReturnToCamp = false
    self:SaveSettings(false)
    Core.DoCmd("/squelch /mapfilter campradius off")
    Core.DoCmd("/squelch /mapfilter pullradius off")
end

function Module:DestoryCampfire()
    if mq.TLO.Me.Fellowship.Campfire() == nil then return end
    Logger.log_debug("DestoryCampfire()")

    mq.TLO.Window("FellowshipWnd").DoOpen()
    mq.delay("3s", function() return mq.TLO.Window("FellowshipWnd").Open() end)
    mq.TLO.Window("FellowshipWnd").Child("FP_Subwindows").SetCurrentTab(2)

    if mq.TLO.Me.Fellowship.Campfire() then
        mq.TLO.Window("FellowshipWnd").Child("FP_DestroyCampsite").LeftMouseUp()
        mq.delay("5s", function() return mq.TLO.Window("ConfirmationDialogBox").Open() end)

        if mq.TLO.Window("ConfirmationDialogBox").Open() then
            mq.TLO.Window("ConfirmationDialogBox").Child("Yes_Button").LeftMouseUp()
        end

        mq.delay("5s", function() return mq.TLO.Me.Fellowship.Campfire() == nil end)
    end
    mq.TLO.Window("FellowshipWnd").DoClose()
end

function Module:GetCampfireTypeName()
    return self.DefaultConfig.MaintainCampfire.ComboOptions[self.settings.MaintainCampfire]
end

function Module:GetCampfireTypeID()
    return self.Constants.CampfireNameToKit[self:GetCampfireTypeName()] or 0
end

function Module:Campfire(camptype)
    if camptype == -1 then
        self:DestoryCampfire()
        return
    end

    if mq.TLO.Zone.ID() == 33506 then return end

    if mq.TLO.Me.Fellowship.ID() == 0 or mq.TLO.Me.Fellowship.Campfire() then
        Logger.log_super_verbose("\arNot in a fellowship or already have a campfire -- not putting one down.")
        return
    end

    if self.settings.MaintainCampfire > 2 then
        if mq.TLO.FindItemCount("Fellowship Campfire Materials") == 0 then
            self.settings.MaintainCampfire = 36 -- Regular Fellowship
            self:SaveSettings(false)
            Logger.log_info("Fellowship Campfire Materials Not Found. Setting to Regular Fellowship.")
        end
    end

    local spawnCount  = mq.TLO.SpawnCount("PC radius 100")()
    local fellowCount = 0

    for i = 1, spawnCount do
        local spawn = mq.TLO.NearestSpawn(i, "PC radius 100")

        if spawn() and mq.TLO.Me.Fellowship.Member(spawn.CleanName()) then
            fellowCount = fellowCount + 1
        end
    end

    if fellowCount >= 3 then
        mq.TLO.Window("FellowshipWnd").DoOpen()
        mq.delay("3s", function() return mq.TLO.Window("FellowshipWnd").Open() end)
        mq.TLO.Window("FellowshipWnd").Child("FP_Subwindows").SetCurrentTab(2)

        if mq.TLO.Me.Fellowship.Campfire() then
            if mq.TLO.Zone.ID() ~= mq.TLO.Me.Fellowship.CampfireZone.ID() then
                mq.TLO.Window("FellowshipWnd").Child("FP_DestroyCampsite").LeftMouseUp()
                mq.delay("5s", function() return mq.TLO.Window("ConfirmationDialogBox").Open() end)

                if mq.TLO.Window("ConfirmationDialogBox").Open() then
                    mq.TLO.Window("ConfirmationDialogBox").Child("Yes_Button").LeftMouseUp()
                end

                mq.delay("5s", function() return mq.TLO.Me.Fellowship.Campfire() == nil end)
            end
        end

        Logger.log_debug("\atFellowship Campfire Type Selected: %s (%d)", camptype and "Override" or self:GetCampfireTypeName(), camptype or self:GetCampfireTypeID())
        mq.TLO.Window("FellowshipWnd").Child("FP_RefreshList").LeftMouseUp()
        mq.delay("1s")
        mq.TLO.Window("FellowshipWnd").Child("FP_CampsiteKitList").Select(camptype or self:GetCampfireTypeID())
        mq.delay("1s")
        mq.TLO.Window("FellowshipWnd").Child("FP_CreateCampsite").LeftMouseUp()
        mq.delay("5s", function() return mq.TLO.Me.Fellowship.Campfire() ~= nil end)
        mq.TLO.Window("FellowshipWnd").DoClose()
        mq.delay("2s", function() return (mq.TLO.Me.Fellowship.CampfireZone.ID() or 0) == mq.TLO.Zone.ID() end)

        Logger.log_info("\agCampfire Dropped")
    else
        Logger.log_info("\ayCan't create campfire. Only %d nearby. Setting MaintainCampfire to 0.", fellowCount)
        self.settings.MaintainCampfire = 1 -- off
    end
end

function Module:ValidChaseTarget()
    return (self.settings.ChaseTarget and self.settings.ChaseTarget:len() > 0)
end

function Module:GetChaseTarget()
    return self.settings.ChaseTarget:len() > 0 and self.settings.ChaseTarget or "<None>"
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    if not self.settings[self._name .. "_Popped"] then
        if ImGui.SmallButton(Icons.MD_OPEN_IN_NEW) then
            self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
            self:SaveSettings(false)
        end
        Ui.Tooltip(string.format("Pop the %s tab out into its own window.", self._name))
        ImGui.NewLine()
    end

    if self.settings and self.ModuleLoaded and Config.Globals.SubmodulesLoaded then
        ImGui.Text("Chase Distance: %d", self.settings.ChaseDistance)
        ImGui.Text("Chase Stop Distance: %d", self.settings.ChaseStopDistance)
        ImGui.Text("Chase LOS Required: %s", self.settings.RequireLoS == true and "On" or "Off")
        ImGui.Text("Last Movement Command: %s", self.TempSettings.LastCmd)

        local pressed
        local chaseSpawn = mq.TLO.Spawn("pc =" .. self:GetChaseTarget())

        ImGui.Separator()

        if ImGui.Button(Config:GetSetting('ChaseOn') and "Chase Off" or "Chase On", ImGui.GetWindowWidth() * .3, 25) then
            self:RunCmd("/rgl chase%s", Config:GetSetting('ChaseOn') and "off" or "on")
        end

        if ImGui.BeginTable("ChaseInfoTable", 2, bit32.bor(ImGuiTableFlags.Borders)) then
            ImGui.TableNextColumn()
            ImGui.Text("Chase Target")
            ImGui.TableNextColumn()
            ImGui.Text(self:GetChaseTarget())
            ImGui.TableNextColumn()
            ImGui.Text("Distance")
            ImGui.TableNextColumn()
            ImGui.Text("%d", self.settings.ChaseTarget:len() > 0 and chaseSpawn.Distance() or 0)
            ImGui.TableNextColumn()
            ImGui.Text("ID")
            ImGui.TableNextColumn()
            ImGui.Text("%d", self.settings.ChaseTarget:len() > 0 and chaseSpawn.ID() or 0)
            ImGui.TableNextColumn()
            ImGui.Text("Line of Sight")
            ImGui.TableNextColumn()
            if chaseSpawn.LineOfSight() then
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 0.8)
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 0.8)
            end
            ImGui.Text(self.settings.ChaseTarget:len() > 0 and (chaseSpawn.LineOfSight() and Icons.FA_EYE or Icons.FA_EYE_SLASH) or "N/A")
            ImGui.PopStyleColor(1)
            ImGui.TableNextColumn()
            ImGui.Text("Loc")
            ImGui.TableNextColumn()
            Ui.NavEnabledLoc(self.settings.ChaseTarget:len() > 0 and chaseSpawn.LocYXZ() or "0,0,0")
            ImGui.EndTable()
        end

        ImGui.Separator()

        if Config:GetSetting('ReturnToCamp') then
            ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImGui.GetStyle().FramePadding.x, 0)
            if ImGui.Button("Break Camp", ImGui.GetWindowWidth() * .3, 25) then
                self:CampOff()
            end
            ImGui.PopStyleVar(1)
        else
            ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImGui.GetStyle().FramePadding.x, 0)
            if ImGui.Button("Set New Camp Here", ImGui.GetWindowWidth() * .3, 25) then
                self:CampOn()
            end
            ImGui.PopStyleVar(1)
        end

        local me = mq.TLO.Me
        local distanceToCamp = Math.GetDistance(me.Y(), me.X(), self.TempSettings.AutoCampY or 0, self.TempSettings.AutoCampX or 0)
        if ImGui.BeginTable("CampInfoTable", 2, bit32.bor(ImGuiTableFlags.Borders)) then
            ImGui.TableNextColumn()
            ImGui.Text("Camp Set")

            ImGui.TableNextColumn()
            if Config:GetSetting('ReturnToCamp') then
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 0.8)
                ImGui.Text(Icons.FA_FREE_CODE_CAMP)
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 0.8)
                ImGui.Text(Icons.MD_NOT_INTERESTED)
            end
            ImGui.PopStyleColor(1)

            ImGui.TableNextColumn()
            ImGui.Text("Camp Location")
            ImGui.TableNextColumn()
            Ui.NavEnabledLoc(string.format("%d,%d,%d", self.TempSettings.AutoCampY or 0, self.TempSettings.AutoCampX or 0, self.TempSettings.AutoCampZ or 0))
            ImGui.TableNextColumn()
            ImGui.Text("Distance to Camp")
            ImGui.TableNextColumn()
            ImGui.Text("%d", self.TempSettings.CampZoneId == mq.TLO.Zone.ID() and distanceToCamp or 0)
            ImGui.TableNextColumn()
            ImGui.Text("Camp Radius")
            ImGui.TableNextColumn()
            ImGui.Text("%d", self.TempSettings.CampZoneId == mq.TLO.Zone.ID() and Config:GetSetting("AutoCampRadius") or 0)
            ImGui.EndTable()
        end

        ImGui.Separator()

        if ImGui.CollapsingHeader("Config Options") then
            self.settings, pressed, _ = Ui.RenderSettings(self.settings, self.DefaultConfig, self.DefaultCategories)
            if pressed then
                self:SaveSettings(false)
            end
        end
    end
end

function Module:Pop()
    self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
    self:SaveSettings(false)
end

function Module:DoClickies()
    if not Config:GetSetting('UseClickies') then return end

    -- don't use clickies when we are trying to med, feigning, or invisible.
    if mq.TLO.Me.Sitting() or Casting.IAmFeigning() or mq.TLO.Me.Invis() then return end

    for i = 1, 12 do
        local setting = Config:GetSetting(string.format("ClickyItem%d", i))
        if setting and setting:len() > 0 then
            local item = mq.TLO.FindItem(setting)
            Logger.log_verbose("Looking for clicky item: %s found: %s", setting, Strings.BoolToColorString(item() ~= nil))

            if item then
                if item.Timer.TotalSeconds() == 0 then
                    if (item.RequiredLevel() or 0) <= mq.TLO.Me.Level() then
                        if Casting.SelfBuffItemCheck(item) then
                            Logger.log_verbose("\aaCasting Item: \at%s\ag Clicky: \at%s\ag!", item.Name(), item.Clicky.Spell.RankName.Name())
                            Casting.UseItem(item.Name(), mq.TLO.Me.ID())
                        else
                            Logger.log_verbose("\ayItem: \at%s\ay Clicky: \at%s\ay Already Active!", item.Name(), item.Clicky.Spell.RankName.Name())
                        end
                    else
                        Logger.log_verbose("\ayItem: \at%s\ay Clicky: \at%s\ay I am too low level to use this clicky!", item.Name(), item.Clicky.Spell.RankName.Name())
                    end
                else
                    Logger.log_verbose("\ayItem: \at%s\ay Clicky: \at%s\ay Clicky timer not ready!", item.Name(), item.Clicky.Spell.RankName.Name())
                end
            end
        end
    end
end

function Module:OnDeath()
    if not Config:GetSetting('BreakOnDeath') then return end
    if self.settings.ChaseTarget then
        Logger.log_info("\awNOTICE:\ax You're dead. I'm not chasing %s anymore.", self.settings.ChaseTarget)
    end
    self.settings.ChaseOn = false
    self.settings.ChaseTarget = ""
end

function Module:ShouldFollow()
    local me = mq.TLO.Me
    local assistSpawn = Core.GetMainAssistSpawn()

    return not mq.TLO.MoveTo.Moving() and
        (not me.Casting() or Core.MyClassIs("brd")) and
        (Targeting.GetXTHaterCount() == 0 or (assistSpawn() and (assistSpawn.Distance() or 0) > self.settings.ChaseDistance))
end

function Module:OnZone()
    self:CampOff()
end

function Module:DoAutoCampCheck()
    Combat.AutoCampCheck(self.TempSettings)
end

function Module:DoCombatCampCheck()
    Combat.CombatCampCheck(self.TempSettings)
end

function Module:GiveTime(combat_state)
    if mq.TLO.Me.Hovering() and self.settings.ChaseOn then
        if Config:GetSetting('BreakOnDeath') then
            Logger.log_warn("\awNOTICE:\ax You're dead. I'm not chasing \am%s\ax anymore.",
                self.settings.ChaseTarget)
            self.settings.ChaseOn = false
            self:SaveSettings()
        end
        return
    end

    if combat_state == "Downtime" then
        if Casting.ShouldShrink() then
            Casting.UseItem(Config:GetSetting('ShrinkItem'), mq.TLO.Me.ID())
        end

        if Casting.ShouldShrinkPet() then
            Casting.UseItem(Config:GetSetting('ShrinkPetItem'), mq.TLO.Me.Pet.ID())
        end

        if Config.ShouldMount() then
            Logger.log_debug("\ayMounting...")
            Casting.UseItem(Config:GetSetting('MountItem'), mq.TLO.Me.ID())
        end

        if Config.ShouldDismount() then
            Logger.log_debug("\ayDismounting...")
            self:RunCmd("/dismount")
        end

        self:DoClickies()
    end

    if Combat.ShouldDoCamp() then
        self:DoAutoCampCheck()
    end

    if (Core.IsTanking() and Config:GetSetting('MovebackWhenBehind')) and Targeting.IHaveAggro(100) then
        self:DoCombatCampCheck()
    end

    if Casting.OkayToBuff() and not Config:GetSetting('PriorityHealing') then
        if not mq.TLO.Me.Fellowship.CampfireZone() and mq.TLO.Zone.ID() == self.TempSettings.CampZoneId and self.settings.MaintainCampfire > 1 then
            --Logger.log_debug("Doing campfire maintainance")
            self:Campfire()
        end
    else
        --Logger.log_debug("Skipping Campfire Checks")
    end

    if not self:ShouldFollow() then
        Logger.log_super_verbose("ShouldFollow() check failed.")
        return
    end

    if self.settings.ChaseOn and not self:ValidChaseTarget() then
        self.settings.ChaseOn = false
        Logger.log_warn("\awNOTICE:\ax \ayChase Target is invalid. Turning Chase Off!")
    end

    if self.settings.ChaseOn and self.settings.ChaseTarget then
        local chaseSpawn = mq.TLO.Spawn("pc =" .. self.settings.ChaseTarget)

        if not chaseSpawn or chaseSpawn.Dead() or not chaseSpawn.ID() then
            Logger.log_warn("\awNOTICE:\ax Chase Target \am%s\ax is dead or not found in zone - Pausing...",
                self.settings.ChaseTarget)
            return
        end

        if mq.TLO.Me.Dead() then return end
        if not chaseSpawn or not chaseSpawn() or (chaseSpawn.Distance() or 0) < self.settings.ChaseDistance then return end

        local Nav = mq.TLO.Navigation

        -- Use MQ2Nav with moveto as a failover if we have a mesh. We'll use a nav
        -- command if the mesh is loaded and we have a path. If we don't have a path
        -- we'll use a moveto. This will hopefully get us over spots of the mesh that
        -- are missing with minimal issues.
        if Nav.MeshLoaded() then
            if not Nav.Active() then
                if Nav.PathExists("id " .. chaseSpawn.ID())() then
                    local navCmd = string.format("/squelch /nav id %d log=critical dist=%d lineofsight=%s", chaseSpawn.ID(),
                        self.settings.ChaseStopDistance, self.settings.RequireLoS and "on" or "off")
                    Logger.log_verbose("\awNOTICE:\ax Chase Target %s is out of range - navin :: %s", self.settings.ChaseTarget, navCmd)
                    self:RunCmd(navCmd)

                    mq.delay("3s", function() return mq.TLO.Navigation.Active() end)

                    if not Nav.Active() and (chaseSpawn.Distance() or 0) > self.settings.ChaseDistance then
                        Logger.log_verbose("\awNOTICE:\ax Nav might have failed.")
                        --self:RunCmd("/squelch /moveto id %d uw mdist %d", chaseSpawn.ID(), self.settings.ChaseDistance)
                    end
                else
                    -- Assuming no line of site problems.
                    -- Moveto underwater style until 20 units away
                    Logger.log_verbose("\awNOTICE:\ax Chase Target %s Has no nav path, trying /moveto", self.settings.ChaseTarget)
                    self:RunCmd("/squelch /moveto id %d uw mdist %d", chaseSpawn.ID(), self.settings.ChaseDistance)
                end
            end
        elseif chaseSpawn.Distance() > self.settings.ChaseDistance and chaseSpawn.Distance() < 400 then
            -- If we don't have a mesh we're using afollow as legacy RG behavior.
            Logger.log_debug("\awNOTICE:\ax Chase Target %s but no nav mesh - using afollow instead", self.settings.ChaseTarget)
            self:RunCmd("/squelch /afollow spawn %d", chaseSpawn.ID())
            self:RunCmd("/squelch /afollow %d", self.settings.ChaseDistance)

            mq.delay("2s")

            if chaseSpawn.Distance() < self.settings.ChaseDistance then
                self:RunCmd("/squelch /afollow off")
            end
        end
    end
end

function Module:OnCombatModeChanged()
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    return "Running..."
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = self.CommandHandlers, }
end

function Module:GetFAQ()
    return { module = self._name, FAQ = self.FAQ or {}, }
end

function Module:GetClassFAQ()
    return { module = self._name, FAQ = self.ClassFAQ or {}, }
end

---@param cmd string
---@param ... string
---@return boolean
function Module:HandleBind(cmd, ...)
    local params = ...
    local handled = false

    if self.CommandHandlers[cmd:lower()] ~= nil then
        self.CommandHandlers[cmd:lower()].handler(self, params)
        handled = true
    end

    return handled
end

function Module:Shutdown()
    Logger.log_debug("Chase Module Unloaded.")
end

return Module
