-- Sample Basic Class Module
local mq                       = require('mq')
local RGMercUtils              = require("utils.rgmercs_utils")
local ICONS                    = require('mq.Icons')
local Set                      = require("mq.Set")

local Module                   = { _version = '0.1a', _name = "Movement", _author = 'Derple', }
Module.__index                 = Module
Module.ModuleLoaded            = false
Module.TempSettings            = {}
Module.TempSettings.CampZoneId = 0
Module.TempSettings.Go2GGH     = 0
Module.TempSettings.LastCmd    = ""

Module.Constants               = {}
Module.Constants.GGHZones      = Set.new({ "poknowledge", "potranquility", "stratos", "guildlobby", "moors", "crescent", "guildhalllrg_int", "guildhall", })

Module.DefaultConfig           = {
    ['AutoCampRadius']   = { DisplayName = "Auto Camp Radius", Category = "Camp", Tooltip = "Return to camp after you get this far away", Default = 60, Min = 10, Max = 300, },
    ['ChaseOn']          = { DisplayName = "Chase On", Category = "Chase", Tooltip = "Chase your Chase Target.", Default = false, },
    ['ChaseDistance']    = { DisplayName = "Chase Distance", Category = "Chase", Tooltip = "How Far your Chase Target can get before you Chase.", Default = 25, Min = 5, Max = 100, },
    ['ChaseTarget']      = { DisplayName = "Chase Target", Category = "Chase", Tooltip = "Character you are Chasing", Type = "Custom", Default = "", },
    ['ReturnToCamp']     = { DisplayName = "Return To Camp", Category = "Camp", Tooltip = "Return to Camp After Combat (requires you to /rgl campon)", Default = (not RGMercConfig.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName())), },
    ['MaintainCampfire'] = { DisplayName = "Maintain Campfire", Category = "Camp", Tooltip = "0: Off; 1: Regular Fellowship; 2: Empowered Fellowship; 36: Scaled Wolf", Default = 1, Min = 0, Max = 36, },
    ['RequireLoS']       = { DisplayName = "Require LOS", Category = "Chase", Tooltip = "Require LOS when using /nav", Default = RGMercConfig.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()), },
}

Module.CommandHandlers         = {
    chaseon = {
        usage = "/rgl chaseon <name?>",
        about = "Chase your current target or <name>",
        handler = function(self, params)
            self:ChaseOn(params)
        end,
    },
    chaseoff = {
        usage = "/rgl chaseoff",
        about = "Turn Chasing Off",
        handler = function(self, _)
            self:ChaseOff()
        end,
    },
    campon = {
        usage = "/rgl campon",
        about = "Set a camp here",
        handler = function(self, _)
            self:CampOn()
        end,
    },
    campoff = {
        usage = "/rgl campoff",
        about = "Clear your camp",
        handler = function(self, _)
            self:CampOff()
        end,
    },
    go2ggh = {
        usage = "/rgl go2ggh",
        about = "Go to Guild Hall",
        handler = function(self, _)
            self:Go2GGH()
        end,
    },
}

Module.DefaultCategories       = Set.new({})
for _, v in pairs(Module.DefaultConfig) do
    if v.Type ~= "Custom" then
        Module.DefaultCategories:add(v.Category)
    end
end

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast == true then
        RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    RGMercsLogger.log_info("Chase Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Basic]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self.settings = {}
    else
        self.settings = config()
    end

    -- Setup Defaults
    self.settings = RGMercUtils.ResolveDefaults(self.DefaultConfig, self.settings)
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    RGMercsLogger.log_info("Chase Module Loaded.")
    self:LoadSettings()
    self.ModuleLoaded = true
    return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ChaseOn(target)
    local chaseTarget = RGMercUtils.GetMainAssistSpawn() or mq.TLO.Target

    if target then
        chaseTarget = mq.TLO.Spawn("pc =" .. target)
    end

    if chaseTarget() and chaseTarget.ID() > 0 and chaseTarget.Type() == "PC" then
        self.settings.ChaseOn = true
        self.settings.ChaseTarget = chaseTarget.CleanName()
        self:SaveSettings(false)

        RGMercsLogger.log_info("\ao Now Chasing \ag %s", chaseTarget.CleanName())
    else
        RGMercsLogger.log_warning("\ayWarning:\ax Not a valid chase target!")
    end
end

function Module:RunCmd(cmd, ...)
    local formattedCmd = cmd

    if ... ~= nil then
        formattedCmd = string.format(cmd, ...)
    end

    self.TempSettings.LastCmd = formattedCmd
    RGMercUtils.DoCmd(formattedCmd)
end

function Module:ChaseOff()
    self.settings.ChaseOn = false
    self.settings.ChaseTarget = nil
    self:SaveSettings(false)
    RGMercsLogger.log_warning("\ayNo longer chasing \at%s\ay.", self.settings.ChaseTarget or "None")
end

function Module:CampOn()
    self.settings.ReturnToCamp   = true
    self.TempSettings.AutoCampX  = mq.TLO.Me.X()
    self.TempSettings.AutoCampY  = mq.TLO.Me.Y()
    self.TempSettings.AutoCampZ  = mq.TLO.Me.Z()
    self.TempSettings.CampZoneId = mq.TLO.Zone.ID()
    RGMercUtils.DoCmd("/mapfilter campradius %d", RGMercUtils.GetSetting('AutoCampRadius'))
    RGMercsLogger.log_info("\ayCamping On: (X: \at%d\ay ; Y: \at%d\ay)", self.TempSettings.AutoCampX, self.TempSettings.AutoCampY)
end

---@return table # camp settings table
function Module:GetCampData()
    return { returnToCamp = (self.settings.ReturnToCamp and self.TempSettings.CampZoneId == mq.TLO.Zone.ID()), campSettings = self.TempSettings, }
end

function Module:CampOff()
    self.settings.ReturnToCamp = false
    self:SaveSettings(false)
    RGMercUtils.DoCmd("/mapfilter campradius off")
end

function Module:DestoryCampfire()
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
    mq.TLO.Window("FellowshipWnd").DoClose()
end

function Module:Campfire(camptype)
    if camptype == -1 then
        self:DestoryCampfire()
        return
    end

    if mq.TLO.Zone.ID() == 33506 then return end

    if not mq.TLO.Me.Fellowship() or mq.TLO.Me.Fellowship.Campfire() then
        RGMercsLogger.log_info("\arNot in a fellowship or already have a campfire -- not putting one down.")
        return
    end

    if self.settings.MaintainCampfire then
        if mq.TLO.FindItemCount("Fellowship Campfire Materials") == 0 then
            self.settings.MaintainCampfire = 1
            self:SaveSettings(false)
            RGMercsLogger.log_info("Fellowship Campfire Materials Not Found. Setting to Regular Fellowship.")
        end
    end

    local spawnCount  = mq.TLO.SpawnCount("PC radius 50")()
    local fellowCount = 0

    for i = 1, spawnCount do
        local spawn = mq.TLO.NearestSpawn(i, "PC radius 50")

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

        mq.TLO.Window("FellowshipWnd").Child("FP_RefreshList").LeftMouseUp()
        mq.delay("1s")
        mq.TLO.Window("FellowshipWnd").Child("FP_CampsiteKitList").Select(self.settings.MaintainCampfire or camptype)
        mq.delay("1s")
        mq.TLO.Window("FellowshipWnd").Child("FP_CreateCampsite").LeftMouseUp()
        mq.delay("5s", function() return mq.TLO.Me.Fellowship.Campfire() ~= nil end)
        mq.TLO.Window("FellowshipWnd").DoClose()

        RGMercsLogger.log_info("\agCampfire Dropped")
    else
        RGMercsLogger.log_info("\ayCan't create campfire. Only %d nearby. Setting MaintainCampfire to 0.", fellowCount)
        self.settings.MaintainCampfire = 0
    end
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    ImGui.Text("Chase Module")

    if self.settings and self.ModuleLoaded then
        ImGui.Text(string.format("Chase Distance: %d", self.settings.ChaseDistance))
        ImGui.Text(string.format("Chase LOS Required: %s", self.settings.LineOfSight and "On" or "Off"))

        local pressed
        local chaseSpawn = mq.TLO.Spawn("pc =" .. (self.settings.ChaseTarget or "NoOne"))

        if ImGui.CollapsingHeader("Config Options") then
            self.settings, pressed, _ = RGMercUtils.RenderSettings(self.settings, self.DefaultConfig, self.DefaultCategories)
            if pressed then
                self:SaveSettings(false)
            end
        end

        ImGui.Separator()

        if chaseSpawn and chaseSpawn.ID() > 0 then
            ImGui.Text(string.format("Chase Target: %s", self.settings.ChaseTarget))
            ImGui.Indent()
            ImGui.Text(string.format("Distance: %d", chaseSpawn.Distance()))
            ImGui.Text(string.format("ID: %d", chaseSpawn.ID()))
            ImGui.Text(string.format("LOS: "))
            if chaseSpawn.LineOfSight() then
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 0.8)
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 0.8)
            end
            ImGui.SameLine()
            ImGui.Text(string.format("%s", chaseSpawn.LineOfSight() and ICONS.FA_EYE or ICONS.FA_EYE_SLASH))
            ImGui.PopStyleColor(1)
            ImGui.Unindent()
        else
            ImGui.Indent()
            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 0.8)
            ImGui.Text(string.format("Chase Target Invalid!"))
            ImGui.PopStyleColor(1)
            ImGui.Unindent()
        end

        ImGui.Separator()

        if RGMercUtils.GetSetting('ReturnToCamp') then
            local me = mq.TLO.Me
            local distanceToCamp = RGMercUtils.GetDistance(me.Y(), me.X(), self.TempSettings.AutoCampY or 0, self.TempSettings.AutoCampX or 0)
            ImGui.Text("Camp Location")
            ImGui.Indent()
            ImGui.Text(string.format("X: %d, Y: %d, Z: %d", self.TempSettings.AutoCampX or 0, self.TempSettings.AutoCampY or 0, self.TempSettings.AutoCampZ or 0))
            if self.TempSettings.CampZoneId > 0 then
                ImGui.Text(string.format("Distance to Camp: %d", distanceToCamp))
            end
            ImGui.Unindent()
        end

        if ImGui.SmallButton("Set New Camp Here") then
            self.settings.ReturnToCamp = true
            self:CampOn()
        end

        local state, pressed = RGMercUtils.RenderOptionToggle("##chase_om", "Chase On", self.settings.ChaseOn)
        if pressed then
            self:RunCmd("/rgl chase%s", state and "on" or "off")
        end

        ImGui.Separator()
        ImGui.Text("Last Movement Command: %s", self.TempSettings.LastCmd)
    end
end

function Module:OnDeath()
    if self.settings.ChaseTarget then
        RGMercsLogger.log_info("\awNOTICE:\ax You're dead. I'm not chasing %s anymore.", self.settings.ChaseTarget)
    end
    self.settings.ChaseOn = false
    self.settings.ChaseTarget = nil
end

function Module:ShouldFollow()
    local me = mq.TLO.Me
    local assistSpawn = RGMercUtils.GetMainAssistSpawn()

    return not mq.TLO.MoveTo.Moving() and
        (not me.Casting.ID() or RGMercUtils.MyClassIs("brd")) and
        (RGMercUtils.GetXTHaterCount() == 0 or (assistSpawn() and assistSpawn.Distance() > self.settings.ChaseDistance))
end

function Module:Go2GGH()
    if not mq.TLO.Me.GuildID() or mq.TLO.Me.GuildID() == 0 then
        RGMercsLogger.log_warning("\awNOTICE:\ax You're not in a guild!")
        return
    end
    self.TempSettings.Go2GGH = 1
end

function Module:OnZone()
    self:CampOff()
end

function Module:GiveTime(combat_state)
    if mq.TLO.Me.Hovering() and self.settings.ChaseOn then
        RGMercsLogger.log_warning("\awNOTICE:\ax You're dead. I'm not chasing \am%s\ax anymore.",
            self.settings.ChaseTarget)
        self.settings.ChaseOn = false
        self:SaveSettings()
        return
    end

    if self.TempSettings.Go2GGH >= 1 then
        if self.TempSettings.Go2GGH == 1 then
            if not self.Constants.GGHZones:contains(mq.TLO.Zone.ShortName():lower()) then
                if not RGMercUtils.UseOrigin() then
                    RGMercsLogger.log_warning("\awNOTICE:\ax Go2GGH Failed.")
                    self.TempSettings.Go2GGH = 0
                else
                    self.TempSettings.Go2GGH = 2
                end
            else
                -- in a known zone.
                self.TempSettings.Go2GGH = 2
            end
        end

        if self.TempSettings.Go2GGH == 2 then
            if mq.TLO.Zone.ShortName():lower() == "guildhalllrg_int" or mq.TLO.Zone.ShortName():lower() == "guildhall" then
                RGMercsLogger.log_debug("\a\ag--\atGoing to Pool \ag--")
                self:RunCmd("/squelch /moveto loc 1 1 3")
                RGMercsLogger.log_debug("\ag --> \atYou made it \ag<--")
                self.TempSettings.Go2GGH = 0
            elseif mq.TLO.Zone.ShortName():lower() ~= "guildlobby" and not mq.TLO.Navigation.Active() then
                self:RunCmd("/squelch /travelto guildlobby")
            elseif mq.TLO.Zone.ShortName():lower() == "guildlobby" and not mq.TLO.Navigation.Active() then
                self:RunCmd("/squelch /nav door id 1 click")
            end
        end
    end

    if combat_state == "Downtime" then
        if RGMercUtils.ShouldShrink() then
            RGMercUtils.UseItem(RGMercUtils.GetSetting('ShrinkItem'), mq.TLO.Me.ID())
        end

        if RGMercUtils.ShouldMount() then
            RGMercsLogger.log_debug("\ayMounting...")
            RGMercUtils.UseItem(RGMercUtils.GetSetting('MountItem'), mq.TLO.Me.ID())
        end

        if RGMercUtils.ShouldDismount() then
            RGMercsLogger.log_debug("\ayDismounting...")
            self:RunCmd("/dismount")
        end
    end

    if RGMercUtils.DoCamp() then
        RGMercUtils.AutoCampCheck(self.settings, self.TempSettings)
    end

    if not self:ShouldFollow() then
        RGMercsLogger.log_verbose("ShouldFollow() check failed.")
        return
    end

    if self.settings.ChaseOn and not self.settings.ChaseTarget then
        self.settings.ChaseOn = false
        RGMercsLogger.log_warning("\awNOTICE:\ax \ayChase Target is invalid. Turning Chase Off!")
    end

    if self.settings.ChaseOn and self.settings.ChaseTarget then
        local chaseSpawn = mq.TLO.Spawn("pc =" .. self.settings.ChaseTarget)

        if not chaseSpawn or chaseSpawn.Dead() or not chaseSpawn.ID() then
            RGMercsLogger.log_warning("\awNOTICE:\ax Chase Target \am%s\ax is dead or not found in zone - Pausing...",
                self.settings.ChaseTarget)
            return
        end

        if mq.TLO.Me.Dead() then return end
        if not chaseSpawn() or chaseSpawn.Distance() < self.settings.ChaseDistance then return end

        local Nav = mq.TLO.Navigation

        -- Use MQ2Nav with moveto as a failover if we have a mesh. We'll use a nav
        -- command if the mesh is loaded and we have a path. If we don't have a path
        -- we'll use a moveto. This will hopefully get us over spots of the mesh that
        -- are missing with minimal issues.
        if Nav.MeshLoaded() then
            if not Nav.Active() then
                if Nav.PathExists("id " .. chaseSpawn.ID())() then
                    local navCmd = string.format("/squelch /nav id %d log=critical distance %d lineofsight=%s", chaseSpawn.ID(),
                        self.settings.ChaseDistance, self.settings.RequireLoS and "on" or "off")
                    RGMercsLogger.log_verbose("\awNOTICE:\ax Chase Target %s is out of range - navin :: %s", self.settings.ChaseTarget, navCmd)
                    self:RunCmd(navCmd)

                    mq.delay("3s", function() return mq.TLO.Navigation.Active() end)

                    if not Nav.Active() and chaseSpawn.Distance() > self.settings.ChaseDistance then
                        RGMercsLogger.log_verbose("\awNOTICE:\ax Nav might have failed.")
                        --self:RunCmd("/squelch /moveto id %d uw mdist %d", chaseSpawn.ID(), self.settings.ChaseDistance)
                    end
                else
                    -- Assuming no line of site problems.
                    -- Moveto underwater style until 20 units away
                    RGMercsLogger.log_verbose("\awNOTICE:\ax Chase Target %s Has no nav path, trying /moveto", self.settings.ChaseTarget)
                    self:RunCmd("/squelch /moveto id %d uw mdist %d", chaseSpawn.ID(), self.settings.ChaseDistance)
                end
            end
        elseif chaseSpawn.Distance() > self.settings.ChaseDistance and chaseSpawn.Distance() < 400 then
            -- If we don't have a mesh we're using afollow as legacy RG behavior.
            RGMercsLogger.log_debug("\awNOTICE:\ax Chase Target %s but no nav mesh - using afollow instead", self.settings.ChaseTarget)
            self:RunCmd("/squelch /afollow spawn %d", chaseSpawn.ID())
            self:RunCmd("/squelch /afollow %d", self.settings.ChaseDistance)

            mq.delay("2s")

            if chaseSpawn.Distance() < self.settings.ChaseDistance then
                self:RunCmd("/squelch /afollow off")
            end
        end
    end

    if RGMercUtils.DoBuffCheck() and not RGMercUtils.GetSetting('PriorityHealing') then
        if mq.TLO.Me.Fellowship.CampfireZone() and mq.TLO.Zone.ID() == self.TempSettings.CampZoneId and self.settings.MaintainCampfire then
            self:Campfire()
        end
    end
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    return "Running..."
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = self.CommandHandlers, }
end

---@param cmd string
---@param ... string
---@return boolean
function Module:HandleBind(cmd, ...)
    local params = ...
    local handled = false

    if self.CommandHandlers[cmd:lower()] ~= nil then
        self.CommandHandlers[cmd:lower()].hander(self, params)
        handled = true
    end

    return handled
end

function Module:Shutdown()
    RGMercsLogger.log_info("Chase Module Unloaded.")
end

return Module
