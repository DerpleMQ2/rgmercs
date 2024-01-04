-- Sample Pull Class Module
local mq                          = require('mq')
local RGMercsLogger               = require("utils.rgmercs_logger")
local RGMercUtils                 = require("utils.rgmercs_utils")
local Set                         = require("mq.Set")

local Module                      = { _version = '0.1a', name = "Pull", author = 'Derple', }
Module.__index                    = Module
Module.settings                   = {}
Module.ModuleLoaded               = false
Module.TempSettings               = {}
Module.TempSettings.LastPull      = os.clock()
Module.TempSettings.TargetSpawnID = 0
Module.TempSettings.PullTargets   = 0
Module.TempSettings.AbortPull     = false
Module.PullModes                  = {
    [1] = "Face Pull",
}

Module.Constants                  = {}
Module.Constants.PullModes        = {
    [1] = "Normal",
    [2] = "Chain",
    [3] = "Hunt",
    [4] = "Farm",
}

Module.DefaultConfig              = {
    ['DoPull']         = { DisplayName = "Enable Pulling", Category = "Pulling", Tooltip = "Enable pulling", Default = false, },
    ['PullMode']       = { DisplayName = "Pull Mode", Category = "Pulling", Tooltip = "1 = Normal, 2 = Chain, 3 = Hunt, 4 = Farm", Default = 1, Min = 1, Max = 4, },
    ['ChainCount']     = { DisplayName = "Chain Count", Category = "Pulling", Tooltip = "Number of mobs in chain pull mode on xtarg before we stop pulling", Default = 3, Min = 1, Max = 100, },
    ['PullDelay']      = { DisplayName = "Pull Delay", Category = "Pulling", Tooltip = "Seconds between pulls", Default = 5, Min = 1, Max = 300, },
    ['PullRadius']     = { DisplayName = "Pull Radius", Category = "Pulling", Tooltip = "Distnace to pull", Default = 90, Min = 1, Max = 10000, },
    ['PullZRadius']    = { DisplayName = "Pull Z Radius", Category = "Pulling", Tooltip = "Distnace to pull on Z axis", Default = 90, Min = 1, Max = 150, },
    ['PullRadiusFarm'] = { DisplayName = "Pull Radius Farm", Category = "Pulling", Tooltip = "Distnace to pull in Farm mode", Default = 90, Min = 1, Max = 10000, },
    ['PullMinLevel']   = { DisplayName = "Pull Min Level", Category = "Pulling", Tooltip = "Min Level Mobs to consider pulling", Default = mq.TLO.Me.Level() - 3, Min = 1, Max = 150, },
    ['PullMaxLevel']   = { DisplayName = "Pull Max Level", Category = "Pulling", Tooltip = "Max Level Mobs to consider pulling", Default = mq.TLO.Me.Level() + 3, Min = 1, Max = 150, },
    ['GroupWatch']     = { DisplayName = "Enable Group Watch", Category = "Pulling", Tooltip = "0 = Off, 1 = Healers, 2 = Everyone", Default = 1, Min = 1, Max = 2, },
    ['GroupWatchPct']  = { DisplayName = "Group Watch %", Category = "Pulling", Tooltip = "Make sure your group members have at least [X]% of their primary resource.", Default = 20, Min = 1, Max = 100, },
    ['PullHPPct']      = { DisplayName = "Pull HP %", Category = "Pulling", Tooltip = "Make sure you have at least this much HP %", Default = 20, Min = 1, Max = 100, },

}

Module.DefaultCategories          = Set.new({})
for _, v in pairs(Module.DefaultConfig) do
    if v.Type ~= "Custom" then
        Module.DefaultCategories:add(v.Category)
    end
end

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module.name .. "_" .. server .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast then
        RGMercUtils.BroadcastUpdate(self.name, "LoadSettings")
    end
end

function Module:LoadSettings()
    RGMercsLogger.log_info("Pull Combat Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Pull]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self:SaveSettings(true)
    else
        self.settings = config()
    end

    -- turn off at startup for safety
    self.settings.DoPull = false

    -- Setup Defaults
    self.settings = RGMercUtils.ResolveDefaults(self.DefaultConfig, self.settings)
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    RGMercsLogger.log_info("Pull Module Loaded.")
    self:LoadSettings()
    self.ModuleLoaded = true
    return { settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:Render()
    ImGui.Text("Pull")

    local pressed

    if self.ModuleLoaded and self.settings.DoPull then
        ImGui.Text(string.format("Should Pull: %s", self:ShouldPull() and "Yes", "No"))
        ImGui.Text(string.format("Pull Delay: %s", RGMercUtils.FormatTime(self.settings.PullDelay)))
        ImGui.Text(string.format("Last Pull Attempt: %s", RGMercUtils.FormatTime((os.clock() - self.TempSettings.LastPull))))
        ImGui.Text(string.format("Next Pull Attempt: %s", RGMercUtils.FormatTime(self.settings.PullDelay - (os.clock() - self.TempSettings.LastPull))))
        ImGui.Text(string.format("Pull Targets: %d", self.TempSettings.PullTargets))
    end

    if ImGui.CollapsingHeader("Config Options") then
        self.settings, pressed, _ = RGMercUtils.RenderSettings(self.settings, self.DefaultConfig, self.DefaultCategories)
        if pressed then
            self:SaveSettings(true)
        end
    end
end

--- @return boolean
function Module:ShouldPull()
    local me = mq.TLO.Me

    if me.PctHPs() < self.settings.PullHPPct then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax PctHPs < %d", self.settings.PullHPPct)
        return false
    end

    if RGMercUtils.SongActive("Restless Ice") then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax I Have Restless Ice!")
        return false
    end

    if RGMercUtils.SongActive("Restless Ice Infection") then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax I Have Restless Ice Infection!")
        return false
    end

    if RGMercUtils.BuffActiveByName("Resurrection Sickness") then return false end

    if (me.Snared.ID() or 0 > 0) then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax I am snared!")
        return false
    end

    if (me.Rooted.ID() or 0 > 0) then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax I am rooted!")
        return false
    end

    if (me.Poisoned.ID() or 0 > 0) and not (me.Tashed.ID()) or 0 > 0 then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax I am poisoned!")
        return false
    end

    if (me.Diseased.ID() or 0 > 0) then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax I am diseased!")
        return false
    end

    if (me.Cursed.ID() or 0 > 0) then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax I am cursed!")
        return false
    end

    if (me.Corrupted.ID() or 0 > 0) then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax I am corrupted!")
        return false
    end

    if RGMercUtils.GetXTHaterCount() > self.settings.ChainCount then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax XTargetCount(%d) > ChainCount(%d)", RGMercUtils.GetXTHaterCount(), self.settings.ChainCount)
        return false
    end

    return true
end

---comment
---@param classes table|nil # mq.Set type
---@param resourcePct number
---@return boolean
function Module:CheckGroupForPull(classes, resourcePct, campData, returnToCamp)
    local groupCount = mq.TLO.Group.Members()

    if not groupCount or groupCount == 0 then return true end

    for i = 1, groupCount do
        local member = mq.TLO.Group.Member(i)

        if member and member.ID() > 0 then
            if not classes or classes:contains(member.Class.ShortName()) then
                if member.PctHPs() < resourcePct then
                    RGMercUtils.PrintGroupMessage("%s is low on hp - Holding pulls!", member.CleanName())
                    return false
                end
                if member.PctMana() < resourcePct then
                    RGMercUtils.PrintGroupMessage("%s is low on mana - Holding pulls!", member.CleanName())
                    return false
                end
                if member.PctEndurance() < resourcePct then
                    RGMercUtils.PrintGroupMessage("%s is low on endurance - Holding pulls!", member.CleanName())
                    return false
                end

                if member.Hovering() then
                    RGMercUtils.PrintGroupMessage("%s is dead - Holding pulls!", member.CleanName())
                    return false
                end

                if member.OtherZone() then
                    RGMercUtils.PrintGroupMessage("%s is in another zone - Holding pulls!", member.CleanName())
                    return false
                end

                if (member.Distance() or 0) >

                    RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius then
                    RGMercUtils.PrintGroupMessage("%s is too far away - Holding pulls!", member.CleanName())
                    return false
                end

                if self.Constants.PullModes[self.settings.PullMode] == "Chain" then
                    if member.ID() == RGMercConfig:GetAssistId() then
                        if returnToCamp and RGMercUtils.GetDistance(member.Y(), member.X(), campData.AutoCampX, campData.AutoCampY) > RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius then
                            RGMercUtils.PrintGroupMessage("%s (assist target) is beyond AutoCampRadius from %d, %d, %d : %d. Holding pulls.", member.CleanName(), campData.AutoCampY,
                                campData.AutoCampX, campData.AutoCampZ, RGMercConfig.SubModuleSettings.settings.Movement.settings.AutoCampRadius)
                            return false
                        end
                    else
                        if RGMercUtils.GetDistance(member.Y(), member.X(), mq.TLO.Me.X(), mq.TLO.Me.Y()) > RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius then
                            RGMercUtils.PrintGroupMessage("%s (assist target) is beyond AutoCampRadius from me : %d. Holding pulls.", member.CleanName(),
                                RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius)
                            return false
                        end
                    end
                end
            end
        end
    end

    return true
end

function Module:FindTarget()
    local pullRadius = self.Constants.PullModes[self.settings.PullMode] == "Farm" and self.settings.PullRadiusFarm or self.settings.PullRadius
    local pullSearchString = string.format("npc radius %d targetable zradius %d range %d %d playerstate 0",
        pullRadius, self.settings.PullZRadius,
        self.settings.PullMinLevel,
        self.settings.PullMaxLevel)

    if self:IsPullMode("Farm") then
        -- TODO: Waypoint handling here.
        RGMercsLogger.log_debug(
            "FindTarget :: Mode: Farm :: pullradius %d pullzradius %d lowlvl %d highlvl %d use_only_nav 1 arc 0 xyz ${GetWaypoint[${Pull_FarmWPNum}]}",
            self.settings.PullRadiusFarm, self.settings.PullZRadius, self.settings.PullMinLevel, self.settings.PullMaxLevel)

        pullSearchString = pullSearchString + string.format(" loc xyz")
    else
        RGMercsLogger.log_debug(
            "FindTarget :: Mode: %s :: pullradius %d pullzradius %d lowlvl %d highlvl %d use_only_nav 1 arc 0 xyz NA",
            self.Constants.PullModes[self.settings.PullMode], self.settings.PullRadius, self.settings.PullZRadius, self.settings.PullMinLevel, self.settings.PullMaxLevel)
    end

    local pullCount = mq.TLO.SpawnCount(pullSearchString)()
    RGMercsLogger.log_debug("\awSearch (\at%s\aw) Found :: \am%d\ax", pullSearchString, pullCount)

    Module.TempSettings.PullTargets = pullCount

    local pullTargets = {}

    for i = 1, pullCount do
        local spawn = mq.TLO.NearestSpawn(i, pullSearchString)
        local skipSpawn = false

        if spawn and (spawn.ID() or 0) > 0 then
            if self:IsPullMode("Chain") then
                if RGMercUtils.IsSpawnXHater(spawn.ID()) then
                    RGMercsLogger.log_debug("\awSpawn \am%s\aw (\at%d\aw) Already on XTarget -- Skipping", spawn.CleanName(), spawn.ID())
                    skipSpawn = true
                end
            end

            if skipSpawn == false then
                RGMercsLogger.log_debug("Checking Nav Pathing to %s (%d)", spawn.CleanName(), spawn.ID())
                if mq.TLO.Navigation.PathExists("id " .. spawn.ID())() then
                    local distance = mq.TLO.Navigation.PathLength("id " .. spawn.ID())()
                    RGMercsLogger.log_debug("Nav Path Exists - Distance :: %d Radius :: %d", distance, pullRadius)
                    if distance < pullRadius then
                        RGMercsLogger.log_debug("Potential Pull %s --> Distance %d", spawn.CleanName(), distance)

                        -- TODO check whitelist / blacklist
                        table.insert(pullTargets, { spawn = spawn, distance = distance, })
                    end
                end
            end
        end
    end

    table.sort(pullTargets, function(a, b) return a.distance < b.distance end)

    if #pullTargets > 0 then
        RGMercsLogger.log_debug("Pulling %s [%d] --> Distance %d", pullTargets[1].spawn.CleanName(), pullTargets[1].spawn.ID(), pullTargets[1].distance)
        return pullTargets[1].spawn.ID()
    end

    return 0
end

---@param pullID number
---@return boolean
function Module:CheckForAbort(pullID)
    if self.TempSettings.AbortPull then
        RGMercsLogger.log_debug("\ar ALERT: Aborting pull on user request. \ax")
        self.TempSettings.AbortPull = false
        return true
    end

    local spawn = mq.TLO.Spawn(pullID)

    if not spawn or spawn.Dead() then
        RGMercsLogger.log_debug("\ar ALERT: Aborting mob died or despawned \ax")
        return true
    end

    if not self:IsPullMode("Farm") and spawn.Distance() > self.settings.PullRadius then
        RGMercsLogger.log_debug("\ar ALERT: Aborting mob moved out of spawn distance \ax")
        return true
    end

    if self:IsPullMode("Farm") and spawn.Distance() > self.settings.PullRadiusFarm then
        RGMercsLogger.log_debug("\ar ALERT: Aborting mob moved out of spawn distance \ax")
        return true
    end

    if RGMercConfig:GetSettings().SafeTargeting and RGMercUtils.IsSpawnFightingStranger(spawn, 500) then
        RGMercsLogger.log_debug("\ar ALERT: Aborting mob is fighting a stranger and safe targetting is enabled! \ax")
        return true
    end

    return false
end

---@param mode string
---@return boolean
function Module:IsPullMode(mode)
    return self.Constants.PullModes[self.settings.PullMode] == mode
end

function Module:GiveTime(combat_stateModule)
    if not self.settings.DoPull then return end

    if not mq.TLO.Navigation.MeshLoaded() then
        RGMercsLogger.log_debug("\ar ERROR: There's no mesh for this zone. Can't pull. \ax")
        RGMercsLogger.log_debug("\ar Disabling Pulling. \ax")
        self.settings.DoPull = false
        return
    end

    local returnToCamp, campData = RGMercModules:execModule("Movement", "GetCampData")

    -- TODO: Verify pulltype pet and we have pet
    if not self:ShouldPull() then
        return
    end

    if (os.clock() - self.TempSettings.LastPull) < self.settings.PullDelay then return end

    self.TempSettings.LastPull = os.clock()

    if self.settings.GroupWatch == 1 then
        self:CheckGroupForPull(Set.new({ "CLR", "DRU", "SHM", }), self.settings.GroupWatchPct, campData, returnToCamp)
    elseif self.settings.GroupWatch == 2 then
        self:CheckGroupForPull(nil, self.settings.GroupWatchPct, campData, returnToCamp)
    end

    -- We're ready to pull, but first, check if we're in farm mode and if we were interrupted
    if self:IsPullMode("Farm") then
        -- TODO: Waypoint handling here.
    end

    local pullID = 0

    if self.TempSettings.TargetSpawnID > 0 then
        pullID = self.TempSettings.TargetSpawnID
    else
        RGMercsLogger.log_debug("Finding Pull Target")
        pullID = self:FindTarget()
    end

    if pullID == 0 and self:IsPullMode("Farm") then
        -- move to next WP
    elseif pullID == 0 then
        RGMercsLogger.log_debug("\ayNothing to pull - better luck next time")
        return
    end

    local start_x = mq.TLO.Me.X()
    local start_y = mq.TLO.Me.Y()
    local start_z = mq.TLO.Me.Z()

    if returnToCamp then
        start_x = campData.CampX
        start_y = campData.CampY
        start_z = campData.CampZ
    end

    -- if DoMed is set it will take care of standing us up
    if mq.TLO.Me.Sitting() and RGMercConfig:GetSettings().DoMed then
        return
    end

    mq.TLO.Me.Stand()

    -- TODO: Add pull ability
    mq.cmdf("/nav id %d distance=%d lineofsight=%s log=off", pullID, 15, "off")

    mq.delay(1000)

    while mq.TLO.Navigation.Active() do
        if self:IsPullMode("Chain") then
            if RGMercUtils.GetXTHaterCount() > self.settings.ChainCount then
                RGMercsLogger.log_info("\awNOTICE:\ax Gained aggro -- aborting chain pull!")
                return
            end
            -- TODO : Diff XTargetList - do we really need to do this?
        else
            if RGMercUtils.GetXTHaterCount() > 0 then
                RGMercsLogger.log_info("\awNOTICE:\ax Gained aggro -- aborting pull!")
                -- TODO: if pull aborts then go back to camp
                return
            end
        end

        if self:CheckForAbort(pullID) then
            mq.cmdf("/nav stop")
            return
        end

        mq.delay(100)
        mq.doevents()
    end

    mq.delay("2s", function() return not mq.TLO.Me.Moving() end)

    RGMercUtils.SetTarget(pullID)

    if self:CheckForAbort(pullID) then
        mq.cmdf("/nav stop")
        return
    end
end

function Module:OnDeath()
    -- Death Handler
    self.settings.DoPull = false
end

function Module:OnZone()
    -- Zone Handler
    self.settings.DoPull = false
end

---@param cmd string
---@param ... string
---@return boolean
function Module:HandleBind(cmd, ...)
    local params = ...
    local handled = false
    -- /rglua cmd handler
    return handled
end

function Module:Shutdown()
    RGMercsLogger.log_info("Pull Combat Module UnLoaded.")
end

return Module
