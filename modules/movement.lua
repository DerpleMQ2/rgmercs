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
local Files                        = require("utils.files")
local Logger                       = require("utils.logger")
local Strings                      = require("utils.strings")
local Set                          = require("mq.Set")
local Icons                        = require('mq.ICONS')

local Module                       = { _version = '0.1a', _name = "Movement", _author = 'Derple', }
Module.__index                     = Module
Module.ModuleLoaded                = false
Module.TempSettings                = {}
Module.TempSettings.CampZoneId     = 0
Module.TempSettings.LastCmd        = ""
Module.SaveRequested               = nil

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

Module.FAQ             = {
    [1] = {
        Question = "How do I move my PCs or have them follow my driver?",
        Answer = "Enable \"Chase\" on the Movement tab (or via Command-Line) and adjust settings in the Following category (Movement Options) to your liking.\n" ..
            "  There are two commonly used forms of following in MQ currently: \"Nav\" and \"A(dvanced)Follow\".\n\n" ..
            "  Nav uses the MQ2Nav plugin to check zone geometry to move from point-to-point. This is the type of movement that RGMercs uses by default.\n\n" ..
            "  Afollow, which is a feature of MQ2AdvPath, uses recording and playback of player movement to mimic the PC being followed. This is the type of nav typically seen on \"Follow Me\" buttons in the group window.\n\n" ..
            "  There are times when Chase(Nav) and Afollow both have advantages, so situationally using both is common.",
        Settings_Used = "",
    },
    [2] = {
        Question = "What is a camp in RGMercs? How do I use one?",
        Answer = "Camping is setting a tether to a particular location.\n\n" ..
            "  Rather than chasing/following another PC, you will continually return to the vicinity of the camp location you've set.\n\n" ..
            "  This mode is mutually-exclusive with Chase, i.e, you cannot Chase and Camp at the same time. Enabling one disables the other." ..
            "Camp settings can be adjusted in the Following category (Movement Options).",
        Settings_Used = "",
    },
}

Module.DefaultConfig   = {
    --Custom
    ['ReturnToCamp']                           = {
        DisplayName = "Return To Camp",
        Type = "Custom",
        Default = false,
        FAQ = "How do I set a camp?",
        Answer = "You can set a camp using a button on the Movement tab, or by using the campon command (see command list) .",
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Default = false,
    },
    ['ChaseTarget']                            = {
        DisplayName = "Chase Target",
        Type = "Custom",
        Default = "",
        FAQ = "How do I set my chase target?",
        Answer = "You can set your chase target using a button on the Movement tab, or by using the chaseon command (see command list).",
    },
    -- Chase
    ['ChaseOn']                                = {
        DisplayName = "Chase On",
        Group = "Movement",
        Header = "Following",
        Category = "Chase",
        Index = 1,
        Tooltip = "Follow the Chase target using MQ2Nav. Requires navmeshes!",
        Default = false,
    },
    ['RunMovePaused']                          = {
        DisplayName = "Chase While Paused",
        Group = "Movement",
        Header = "Following",
        Category = "Chase",
        Index = 2,
        Tooltip = "Continue to follow your Chase target, even if RGMercs is paused.",
        Default = true,
    },
    ['ChaseDistance']                          = {
        DisplayName = "Chase Distance",
        Group = "Movement",
        Header = "Following",
        Category = "Chase",
        Index = 3,
        Tooltip = "The distance away from our chase target before we will begin to navigate to them. (This starts chase movement.)",
        Default = 25,
        Min = 5,
        Max = 100,
    },
    ['ChaseStopDistance']                      = {
        DisplayName = "Chase Stop Distance",
        Group = "Movement",
        Header = "Following",
        Category = "Chase",
        Index = 4,
        Tooltip = "The distance to our chase target to end navigation to them. (This ends chase movement.) High run speed may overshoot this value.",
        Default = 25,
        Min = 5,
        Max = 100,
    },
    ['RequireLoS']                             = {
        DisplayName = "Require LOS",
        Group = "Movement",
        Header = "Following",
        Category = "Chase",
        Index = 5,
        Tooltip = "Require Line-of-Sight to the chase target before navigation to them is ended.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['PriorityFollow']                         = {
        DisplayName = "Prioritize Follow",
        Group = "Movement",
        Header = "Following",
        Category = "Chase",
        Index = 6,
        Tooltip =
        "Prioritize staying in range of the Chase Target over any other actions. This will prevent any rotations (heals, buffs, etc) from being processed if we are out of range of the chase target.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['BreakOnDeath']                           = {
        DisplayName = "Break On Death",
        Group = "Movement",
        Header = "Following",
        Category = "Chase",
        Index = 7,
        Tooltip = "Stop chasing after when you die.",
        Default = false,
        ConfigType = "Advanced",
    },
    -- Camp
    ['AutoCampRadius']                         = {
        DisplayName = "Camp Radius",
        Group = "Movement",
        Header = "Following",
        Category = "Camp",
        Index = 1,
        Tooltip = "The distance to allow from camp before you return to it. During combat, we relax this distance slightly.",
        Default = (Config.Constants.RGMelee:contains(mq.TLO.Me.Class.ShortName()) and 30 or 60),
        Min = 10,
        Max = 300,
    },
    ['CampHard']                               = {
        DisplayName = "Camp Hard",
        Group = "Movement",
        Header = "Following",
        Category = "Camp",
        Index = 2,
        Tooltip = "Return to the exact camp location whenever possible, even if we are within the Camp Radius.",
        Default = false,
    },
    ['MaintainCampfire']                       = {
        DisplayName = "Maintain Campfire",
        Group = "Movement",
        Header = "Following",
        Category = "Camp",
        Index = 3,
        Tooltip = "Official Servers: Maintain the selected Fellowship Campfire.",
        Type = "Combo",
        ComboOptions = Module.Constants.CampfireTypes,
        Default = 1,
        Min = 1,
        Max = #Module.Constants.CampfireTypes,
    },
    ['DoFellow']                               = {
        DisplayName = "Enable Fellowship Insignia",
        Group = "Movement",
        Header = "Following",
        Category = "Camp",
        Index = 4,
        Tooltip = "Official Servers: Use your fellowship insignia to automatically return to the zone you were camped in after death.",
        Default = false,
        ConfigType = "Advanced",
    },
}

Module.CommandHandlers = {
    chaseon = {
        usage = "/rgl chaseon <name?>",
        about = "Chase <name> (uses your current target if no name is supplied). Clears your camp.",
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
        about = "Set a camp here. Disables Chase.",
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
    self.SaveRequested = { time = os.time(), broadcast = doBroadcast or false, }
end

function Module:WriteSettings()
    if not self.SaveRequested then return end

    mq.pickle(getConfigFileName(), Config:GetModuleSettings(self._name))

    if Config:GetSetting('ReturnToCamp') then
        Core.DoCmd("/squelch /mapfilter campradius %d", Config:GetSetting('AutoCampRadius'))
        Core.DoCmd("/squelch /mapfilter pullradius %d", Config:GetSetting('PullRadius'))
    else
        Core.DoCmd("/squelch /mapfilter campradius off")
        Core.DoCmd("/squelch /mapfilter pullradius off")
    end

    if self.SaveRequested.doBroadcast == true then
        Comms.BroadcastMessage(self._name, "LoadSettings")
    end

    Logger.log_debug("\ag%s Module settings saved to %s, requested %s ago.", self._name, getConfigFileName(), Strings.FormatTime(os.time() - self.SaveRequested.time))

    self.SaveRequested = nil
end

function Module:LoadSettings()
    Logger.log_debug("Chase Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()
    local settings = {}
    local firstSaveRequired = false

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Basic]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        firstSaveRequired = true
    else
        settings = config()
    end

    Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)
end

function Module.New()
    local newModule = setmetatable({}, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Chase Module Loaded.")
    self:LoadSettings()
    self.ModuleLoaded = true
    return { self = self, defaults = self.DefaultConfig, }
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
        Config:SetSetting('ChaseOn', true)
        Config:SetSetting('ChaseTarget', chaseTarget.CleanName())
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
    if Config:GetSetting('ChaseOn') == false then return end
    Logger.log_info("\ayNo longer chasing \at%s\ay.", Config:GetSetting('ChaseTarget') or "None")
    Config:SetSetting('ChaseOn', false)
    Config:SetSetting('ChaseTarget', "")
    self:SaveSettings(false)
end

function Module:CampOn()
    self:ChaseOff()
    Config:SetSetting('ReturnToCamp', true)
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
    return { returnToCamp = (Config:GetSetting('ReturnToCamp') and self.TempSettings.CampZoneId == mq.TLO.Zone.ID()), campSettings = self.TempSettings, }
end

---@return boolean
function Module:InCampZone()
    return self.TempSettings.CampZoneId == mq.TLO.Zone.ID()
end

function Module:CampOff()
    Config:SetSetting('ReturnToCamp', false)
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
    return self.DefaultConfig.MaintainCampfire.ComboOptions[Config:GetSetting('MaintainCampfire')]
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

    if Config:GetSetting('MaintainCampfire') > 2 then
        if mq.TLO.FindItemCount("Fellowship Campfire Materials") == 0 then
            Config:SetSetting('MaintainCampfire', 36) -- Regular Fellowship
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
        Config:SetSetting('MaintainCampfire', 1) -- off
    end
end

function Module:ValidChaseTarget()
    return (Config:GetSetting('ChaseTarget') and Config:GetSetting('ChaseTarget'):len() > 0)
end

function Module:GetChaseTarget()
    return Config:GetSetting('ChaseTarget'):len() > 0 and Config:GetSetting('ChaseTarget') or "<None>"
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    Ui.RenderPopAndSettings(self._name)

    if self.ModuleLoaded and Config.Globals.SubmodulesLoaded then
        ImGui.Text("Chase Distance: %d", Config:GetSetting('ChaseDistance'))
        ImGui.Text("Chase Stop Distance: %d", Config:GetSetting('ChaseStopDistance'))
        ImGui.Text("Chase LOS Required: %s", Config:GetSetting('RequireLoS') == true and "On" or "Off")
        ImGui.Text("Last Movement Command: %s", self.TempSettings.LastCmd)

        local chaseSpawn = mq.TLO.Spawn("pc =" .. self:GetChaseTarget())

        ImGui.Separator()

        if ImGui.Button(Config:GetSetting('ChaseOn') and "Chase Off" or "Chase On", ImGui.GetWindowWidth() * .3, 25) then
            self:RunCmd("/rgl chase%s", Config:GetSetting('ChaseOn') and "off" or "on")
        end
        Ui.Tooltip("Find more information about Chasing by checking the Command List or FAQs in the Options Window.")

        local haveChaseTarget = self:ValidChaseTarget() and chaseSpawn() and chaseSpawn.ID() > 0

        if ImGui.BeginTable("ChaseInfoTable", 2, bit32.bor(ImGuiTableFlags.Borders)) then
            ImGui.TableNextColumn()
            ImGui.Text("Chase Target")
            ImGui.TableNextColumn()
            ImGui.Text(self:GetChaseTarget())
            ImGui.TableNextColumn()
            ImGui.Text("Distance")
            ImGui.TableNextColumn()
            ImGui.Text("%d", haveChaseTarget and chaseSpawn.Distance() or 0)
            ImGui.TableNextColumn()
            ImGui.Text("ID")
            ImGui.TableNextColumn()
            ImGui.Text("%d", haveChaseTarget and chaseSpawn.ID() or 0)
            ImGui.TableNextColumn()
            ImGui.Text("Line of Sight")
            ImGui.TableNextColumn()
            if chaseSpawn.LineOfSight() then
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 0.8)
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 0.8)
            end
            ImGui.Text(haveChaseTarget and (chaseSpawn.LineOfSight() and Icons.FA_EYE or Icons.FA_EYE_SLASH) or "N/A")
            ImGui.PopStyleColor(1)
            ImGui.TableNextColumn()
            ImGui.Text("Loc")
            ImGui.TableNextColumn()
            Ui.NavEnabledLoc(haveChaseTarget and chaseSpawn.LocYXZ() or "0,0,0")
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
        Ui.Tooltip("Find more information about Camping by checking the Command List or FAQs in the Options Window.")

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
    end
end

function Module:Pop()
    Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Module:OnDeath()
    if not Config:GetSetting('BreakOnDeath') then return end
    if Config:GetSetting('ChaseTarget') then
        Logger.log_info("\awNOTICE:\ax You're dead. I'm not chasing %s anymore.", Config:GetSetting('ChaseTarget'))
    end
    Config:SetSetting('ChaseOn', false)
    Config:SetSetting('ChaseTarget', "")
end

function Module:ShouldFollow()
    local me = mq.TLO.Me
    local assistSpawn = Core.GetMainAssistSpawn()

    return not mq.TLO.MoveTo.Moving() and
        (not me.Casting() or Core.MyClassIs("brd")) and
        (Targeting.GetXTHaterCount() == 0 or (assistSpawn() and (assistSpawn.Distance() or 0) > Config:GetSetting('ChaseDistance')))
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
    if mq.TLO.Me.Hovering() and Config:GetSetting('ChaseOn') then
        if Config:GetSetting('BreakOnDeath') then
            Logger.log_warn("\awNOTICE:\ax You're dead. I'm not chasing \am%s\ax anymore.",
                Config:GetSetting('ChaseTarget'))
            Config:SetSetting('ChaseOn', false)
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
    end

    if Combat.ShouldDoCamp() then
        self:DoAutoCampCheck()
    end

    if (Core.IsTanking() and Config:GetSetting('MovebackWhenBehind')) and Targeting.IHaveAggro(100) then
        self:DoCombatCampCheck()
    end

    if Casting.OkayToBuff() and not Config:GetSetting('PriorityHealing') then
        if not mq.TLO.Me.Fellowship.CampfireZone() and mq.TLO.Zone.ID() == self.TempSettings.CampZoneId and Config:GetSetting('MaintainCampfire') > 1 then
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

    if Config:GetSetting('ChaseOn') and not self:ValidChaseTarget() then
        Config:SetSetting('ChaseOn', false)
        Logger.log_warn("\awNOTICE:\ax \ayChase Target is invalid. Turning Chase Off!")
    end

    if Config:GetSetting('ChaseOn') and Config:GetSetting('ChaseTarget') then
        local chaseSpawn = mq.TLO.Spawn("pc =" .. Config:GetSetting('ChaseTarget'))

        if not chaseSpawn or chaseSpawn.Dead() or not chaseSpawn.ID() then
            Logger.log_warn("\awNOTICE:\ax Chase Target \am%s\ax is dead or not found in zone - Pausing...",
                Config:GetSetting('ChaseTarget'))
            return
        end

        if mq.TLO.Me.Dead() then return end
        if not chaseSpawn or not chaseSpawn() or (chaseSpawn.Distance() or 0) < Config:GetSetting('ChaseDistance') then return end

        local Nav = mq.TLO.Navigation

        -- Use MQ2Nav with moveto as a failover if we have a mesh. We'll use a nav
        -- command if the mesh is loaded and we have a path. If we don't have a path
        -- we'll use a moveto. This will hopefully get us over spots of the mesh that
        -- are missing with minimal issues.
        if Nav.MeshLoaded() then
            if not Nav.Active() then
                if Nav.PathExists("id " .. chaseSpawn.ID())() then
                    local navCmd = string.format("/squelch /nav id %d log=critical dist=%d lineofsight=%s", chaseSpawn.ID(),
                        Config:GetSetting('ChaseStopDistance'), Config:GetSetting('RequireLoS') and "on" or "off")
                    Logger.log_verbose("\awNOTICE:\ax Chase Target %s is out of range - navin :: %s", Config:GetSetting('ChaseTarget'), navCmd)
                    self:RunCmd(navCmd)

                    mq.delay("3s", function() return mq.TLO.Navigation.Active() end)

                    if not Nav.Active() and (chaseSpawn.Distance() or 0) > Config:GetSetting('ChaseDistance') then
                        Logger.log_verbose("\awNOTICE:\ax Nav might have failed.")
                        --self:RunCmd("/squelch /moveto id %d uw mdist %d", chaseSpawn.ID(), Config:GetSetting('ChaseDistance'))
                    end
                else
                    -- Assuming no line of site problems.
                    -- Moveto underwater style until 20 units away
                    Logger.log_verbose("\awNOTICE:\ax Chase Target %s Has no nav path, trying /moveto", Config:GetSetting('ChaseTarget'))
                    self:RunCmd("/squelch /moveto id %d uw mdist %d", chaseSpawn.ID(), Config:GetSetting('ChaseDistance'))
                end
            end
        elseif chaseSpawn.Distance() > Config:GetSetting('ChaseDistance') and chaseSpawn.Distance() < 400 then
            -- If we don't have a mesh we're using afollow as legacy RG behavior.
            Logger.log_debug("\awNOTICE:\ax Chase Target %s but no nav mesh - using afollow instead", Config:GetSetting('ChaseTarget'))
            self:RunCmd("/squelch /afollow spawn %d", chaseSpawn.ID())
            self:RunCmd("/squelch /afollow %d", Config:GetSetting('ChaseDistance'))

            mq.delay("2s")

            if chaseSpawn.Distance() < Config:GetSetting('ChaseDistance') then
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
