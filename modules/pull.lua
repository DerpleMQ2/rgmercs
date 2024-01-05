-- Sample Pull Class Module
local mq                          = require('mq')
local RGMercsLogger               = require("utils.rgmercs_logger")
local RGMercUtils                 = require("utils.rgmercs_utils")
local Set                         = require("mq.Set")
local ICONS                       = require('mq.Icons')

local Module                      = { _version = '0.1a', name = "Pull", author = 'Derple', }
Module.__index                    = Module
Module.settings                   = {}
Module.ModuleLoaded               = false
Module.TempSettings               = {}
Module.TempSettings.LastPull      = os.clock()
Module.TempSettings.TargetSpawnID = 0
Module.TempSettings.CurrentWP     = 1
Module.TempSettings.PullTargets   = 0
Module.TempSettings.AbortPull     = false


local PullStates              = {
    ['PULL_IDLE']            = 1,
    ['PULL_GROUPWATCH_WAIT'] = 2,
    ['PULL_NAV_INTERRUPT']   = 3,
    ['PULL_SCAN']            = 4,
    ['PULL_PULLING']         = 5,
    ['PULL_MOVING_TO_WP']    = 6,
    ['PULL_NAV_TO_TARGET']   = 7,
    ['PULL_RETURN_TO_CAMP']  = 8,
}

local PullStateDisplayStrings = {
    ['PULL_IDLE']            = { Display = ICONS.FA_CLOCK_O, Text = "Idle", Color = { r = 0.02, g = 0.8, b = 0.2, a = 1.0, }, },
    ['PULL_GROUPWATCH_WAIT'] = { Display = ICONS.MD_GROUP, Text = "Waiting on GroupWatch", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_NAV_INTERRUPT']   = { Display = ICONS.MD_PAUSE_CIRCLE_OUTLINE, Text = "Navigation interrupted", Color = { r = 0.8, g = 0.02, b = 0.02, a = 1.0, }, },
    ['PULL_SCAN']            = { Display = ICONS.FA_EYE, Text = "Scanning for Targest", Color = { r = 0.02, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_PULLING']         = { Display = ICONS.FA_BULLSEYE, Text = "Pulling", Color = { r = 0.8, g = 0.03, b = 0.02, a = 1.0, }, },
    ['PULL_MOVING_TO_WP']    = { Display = ICONS.MD_DIRECTIONS_RUN, Text = "Moving to Next WP", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_NAV_TO_TARGET']   = { Display = ICONS.MD_DIRECTIONS_RUN, Text = "Naving to Target", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_RETURN_TO_CAMP']  = { Display = ICONS.FA_FREE_CODE_CAMP, Text = "Returning to Camp", Color = { r = 0.08, g = 0.8, b = 0.02, a = 1.0, }, },
}

local PullStatesIDToName      = {}
for k, v in pairs(PullStates) do PullStatesIDToName[v] = k end

Module.TempSettings.PullState  = PullStates.PULL_IDLE

Module.Constants               = {}
Module.Constants.PullModes     = {
    [1] = "Normal",
    [2] = "Chain",
    [3] = "Hunt",
    [4] = "Farm",
}

Module.Constants.PullAbilities = {
    [1] = {
        id = "PetPull",
        Type = "Special",
        AbilityRange = 100,
        DisplayName = "Pet Pull",
        cond = function(self)
            return RGMercConfig.Constants.RGPetClass:contains(RGMercConfig.Globals.CurLoadedClass)
        end,
    },
    [2] = { id = "Taunt", Type = "Ability", DisplayName = "Taunt", AbilityRange = 30, cond = function(self) return mq.TLO.Me.Ability("Taunt")() ~= nil end, },
    [3] = { id = "Ranged", Type = "Special", DisplayName = "Ranged", cond = function(self) return mq.TLO.Me.Inventory("ranged")() ~= nil end, },
}

local PullAbilityIDToName      = {}
for k, v in ipairs(Module.Constants.PullAbilities) do PullAbilityIDToName[v.id] = k end

Module.TempSettings.ValidPullAbilities = {}

Module.DefaultConfig                   = {
    ['DoPull']             = { DisplayName = "Enable Pulling", Category = "Pulling", Tooltip = "Enable pulling", Default = false, },
    ['PullAbility']        = { DisplayName = "Pull Ability", Category = "Pulling", Tooltip = "What should we pull with?", Default = 1, Type = "Custom", },
    ['PullMode']           = { DisplayName = "Pull Mode", Category = "Pulling", Tooltip = "1 = Normal, 2 = Chain, 3 = Hunt, 4 = Farm", Type = "Custom", Default = 1, Min = 1, Max = 4, },
    ['ChainCount']         = { DisplayName = "Chain Count", Category = "Pulling", Tooltip = "Number of mobs in chain pull mode on xtarg before we stop pulling", Default = 3, Min = 1, Max = 100, },
    ['PullDelay']          = { DisplayName = "Pull Delay", Category = "Pulling", Tooltip = "Seconds between pulls", Default = 5, Min = 1, Max = 300, },
    ['PullRadius']         = { DisplayName = "Pull Radius", Category = "Pulling", Tooltip = "Distnace to pull", Default = 90, Min = 1, Max = 10000, },
    ['PullZRadius']        = { DisplayName = "Pull Z Radius", Category = "Pulling", Tooltip = "Distnace to pull on Z axis", Default = 90, Min = 1, Max = 150, },
    ['PullRadiusFarm']     = { DisplayName = "Pull Radius Farm", Category = "Pulling", Tooltip = "Distnace to pull in Farm mode", Default = 90, Min = 1, Max = 10000, },
    ['PullMinLevel']       = { DisplayName = "Pull Min Level", Category = "Pulling", Tooltip = "Min Level Mobs to consider pulling", Default = mq.TLO.Me.Level() - 3, Min = 1, Max = 150, },
    ['PullMaxLevel']       = { DisplayName = "Pull Max Level", Category = "Pulling", Tooltip = "Max Level Mobs to consider pulling", Default = mq.TLO.Me.Level() + 3, Min = 1, Max = 150, },
    ['GroupWatch']         = { DisplayName = "Enable Group Watch", Category = "Pulling", Tooltip = "0 = Off, 1 = Healers, 2 = Everyone", Default = 1, Min = 1, Max = 2, },
    ['GroupWatchStartPct'] = { DisplayName = "Group Watch %", Category = "Pulling", Tooltip = "If your group member is above [X]% resource, start pulls again.", Default = 80, Min = 1, Max = 100, },
    ['GroupWatchStopPct']  = { DisplayName = "Group Watch %", Category = "Pulling", Tooltip = "If your group member is below [X]% resource, stop pulls.", Default = 20, Min = 1, Max = 100, },
    ['PullHPPct']          = { DisplayName = "Pull HP %", Category = "Pulling", Tooltip = "Make sure you have at least this much HP %", Default = 20, Min = 1, Max = 100, },
    ['FarmWayPoints']      = { DisplayName = "Farming Waypoints", Category = "", Tooltip = "", Type = "Custom", Default = {}, },

}

Module.DefaultCategories               = Set.new({})
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

    for _, v in ipairs(Module.Constants.PullAbilities) do
        if not v.cond or v.cond(self) then
            table.insert(self.TempSettings.ValidPullAbilities, v.DisplayName)
        end
    end
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

    if self.ModuleLoaded then
        if self.settings.DoPull then
            ImGui.PushStyleColor(ImGuiCol.Button, 0.5, 0.02, 0.02, 1)
        else
            ImGui.PushStyleColor(ImGuiCol.Button, 0.02, 0.5, 0.0, 1)
        end

        if ImGui.Button(self.settings.DoPull and "Stop Pulls" or "Start Pulls", ImGui.GetWindowWidth() * .3, 25) then
            self.settings.DoPull = not self.settings.DoPull
            self:SaveSettings(true)
        end
        ImGui.PopStyleColor()

        self.settings.PullMode, pressed = ImGui.Combo("Pull Mode", self.settings.PullMode, self.Constants.PullModes, #self.Constants.PullModes)
        if pressed then
            self:SaveSettings(true)
        end
        if #self.TempSettings.ValidPullAbilities > 0 then
            self.settings.PullAbility, pressed = ImGui.Combo("Pull Ability", self.settings.PullAbility, self.TempSettings.ValidPullAbilities, #self.TempSettings.ValidPullAbilities)
            if pressed then
                self:SaveSettings(true)
            end
        end

        local nextPull = self.settings.PullDelay - (os.clock() - self.TempSettings.LastPull)
        if nextPull < 0 then nextPull = 0 end
        if ImGui.BeginTable("PullState", 2, bit32.bor(ImGuiTableFlags.Borders)) then
            ImGui.TableNextColumn()
            ImGui.Text("Pull State")
            ImGui.TableNextColumn()
            local stateData = PullStateDisplayStrings[PullStatesIDToName[self.TempSettings.PullState]]
            if not stateData then
                RGMercsLogger.log_error("StateData is nil for %d", self.TempSettings.PullState)
                print(self.TempSettings.PullState)
                ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
            else
                ImGui.PushStyleColor(ImGuiCol.Text, stateData.Color.r, stateData.Color.g, stateData.Color.b, stateData.Color.a)
            end
            ImGui.Text(stateData.Display .. " " .. stateData.Text)
            ImGui.PopStyleColor()
            ImGui.TableNextColumn()
            ImGui.Text("Should Pull")
            ImGui.TableNextColumn()
            ImGui.Text(self:ShouldPull() and "Yes" or "No")
            ImGui.TableNextColumn()
            ImGui.Text("Pull Delay")
            ImGui.TableNextColumn()
            ImGui.Text(RGMercUtils.FormatTime(self.settings.PullDelay))
            ImGui.TableNextColumn()
            ImGui.Text("Last Pull Attempt")
            ImGui.TableNextColumn()
            ImGui.Text(RGMercUtils.FormatTime((os.clock() - self.TempSettings.LastPull)))
            ImGui.TableNextColumn()
            ImGui.Text("Next Pull Attempt")
            ImGui.TableNextColumn()
            ImGui.Text(RGMercUtils.FormatTime(nextPull))
            ImGui.TableNextColumn()
            ImGui.Text("Pull Targets")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(self.TempSettings.PullTargets))
            ImGui.TableNextColumn()
            ImGui.Text("Current Farm WP ID")
            ImGui.TableNextColumn()
            local wpId = self:GetCurrentWpId()
            local wpData = self:GetWPById(wpId)
            ImGui.Text(wpId == 0 and "<None>" or string.format("%d [y: %0.2f, x: %0.2f, z: %0.2f]", wpId, wpData.y, wpData.x, wpData.z))
            ImGui.EndTable()
        end

        if mq.TLO.Target() and mq.TLO.Target.Type() == "NPC" then
            if ImGui.SmallButton("Pull Target") then
                self.TempSettings.TargetSpawnID = mq.TLO.Target.ID()
            end
        end

        if ImGui.CollapsingHeader("Farm Waypoints") then
            ImGui.PushID("##_small_btn_create_wp")
            if ImGui.SmallButton("Create Waypoint Here") then
                self:CreateWayPointHere()
            end
            ImGui.PopID()

            if ImGui.BeginTable("Waypoints", 3, bit32.bor(ImGuiTableFlags.Borders)) then
                ImGui.TableSetupColumn('Id', (ImGuiTableColumnFlags.WidthFixed), 40.0)
                ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthStretch), 150.0)
                ImGui.TableSetupColumn('Controls', (ImGuiTableColumnFlags.WidthFixed), 80.0)
                ImGui.TableHeadersRow()

                for idx, wpData in ipairs(self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] or {}) do
                    ImGui.TableNextColumn()
                    ImGui.Text(tostring(idx))
                    ImGui.TableNextColumn()
                    ImGui.Text(string.format("[y: %0.2f, x: %0.2f, z: %0.2f]", wpData.y, wpData.x, wpData.z))
                    ImGui.TableNextColumn()
                    ImGui.PushID("##_small_btn_delete_wp_" .. tostring(idx))
                    if ImGui.SmallButton(ICONS.FA_TRASH) then
                        self:DeleteWayPoint(idx)
                    end
                    ImGui.PopID()
                    ImGui.SameLine()
                    ImGui.PushID("##_small_btn_up_wp_" .. tostring(idx))
                    if ImGui.SmallButton(ICONS.FA_CHEVRON_UP) then
                        self:MoveWayPointUp(idx)
                    end
                    ImGui.PopID()
                    ImGui.SameLine()
                    ImGui.PushID("##_small_btn_dn_wp_" .. tostring(idx))
                    if ImGui.SmallButton(ICONS.FA_CHEVRON_DOWN) then
                        self:MoveWayPointDown(idx)
                    end
                    ImGui.PopID()
                end

                ImGui.EndTable()
            end
        end
    end

    if ImGui.CollapsingHeader("Config Options") then
        self.settings, pressed, _ = RGMercUtils.RenderSettings(self.settings, self.DefaultConfig, self.DefaultCategories)
        if pressed then
            self:SaveSettings(true)
        end
    end
end

---@return integer
function Module:GetCurrentWpId()
    if not self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then return 0 end
    return (self.TempSettings.CurrentWP <= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()]) and self.TempSettings.CurrentWP or 0
end

---comment
---@param id number
---@return table
function Module:GetWPById(id)
    return (id <= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()]) and self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id] or { x = 0, y = 0, z = 0, }
end

function Module:IncrementWpId()
    if not self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then return end

    if (self.TempSettings.CurrentWP + 1) <= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then
        self.TempSettings.CurrentWP = self.TempSettings.CurrentWP + 1
    else
        self.TempSettings.CurrentWP = 1
    end
end

---@param id number
function Module:MoveWayPointUp(id)
    local newId = id - 1

    if newId < 1 then return end
    if id > #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then return end

    local oldEntry = self:GetWPById(newId)
    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId] = self:GetWPById(id)
    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id] = oldEntry
    self:SaveSettings(true)
end

---@param id number
function Module:MoveWayPointDown(id)
    local newId = id + 1

    if id < 1 then return end
    if newId > #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then return end

    local oldEntry = self:GetWPById(newId)
    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId] = self:GetWPById(id)
    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id] = oldEntry
    self:SaveSettings(true)
end

function Module:CreateWayPointHere()
    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] = self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] or {}
    table.insert(self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()], { x = mq.TLO.Me.X(), y = mq.TLO.Me.Y(), z = mq.TLO.Me.Z(), })
    self:SaveSettings(true)
    RGMercsLogger.log_info("\axNew waypoint \at%d\ax created at location \ag%02.f, %02.f, %02.f", #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()],
        mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z())
end

function Module:DeleteWayPoint(idx)
    if idx >= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then
        RGMercsLogger.log_info("\axWaypoint \at%d\ax at location \ag%s\ax - \arDeleted!\ax", idx, self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][idx])
        self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][idx] = nil
        self:SaveSettings(true)
    else
        RGMercsLogger.log_error("\ar%d is not a valid waypoint ID!", idx)
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

    if self:IsPullMode("Chain") and RGMercUtils.GetXTHaterCount() > self.settings.ChainCount then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax XTargetCount(%d) > ChainCount(%d)", RGMercUtils.GetXTHaterCount(), self.settings.ChainCount)
        return false
    end

    if not self:IsPullMode("Chain") and RGMercUtils.GetXTHaterCount() > 0 then
        RGMercsLogger.log_verbose("\ay::PULL:: \arAborted!\ax XTargetCount(%d) > 1", RGMercUtils.GetXTHaterCount(), self.settings.ChainCount)
        return false
    end

    return true
end

function Module:FarmFullInvActions()
    -- Bags are full. We now try and do the following...
    -- 1. Call a specifical sub defined in rgcustom.inc if it exists
    -- 2. Call origin if we have it and its ready so we can go home and sell
    -- 3. Stop farming
    --/if (${SubDefined[Farm_${Zone.ShortName}_FullInventory]}) {
    --    -/call Farm_${Zone.ShortName}_FullInventory
    -- } else /if (${RG_AAReady[Origin]}) {
    --    /call AANow ${Me.AltAbility[Origin].ID} ${Me.ID}
    -- } else {
    --    /echo Bags are full, can't origin back home. Stopping and beeping.
    --    /rg DoPull 0
    --    /beep
    -- }

    RGMercsLogger.log_error("\arStopping Pulls - Bags are full!")
    self.settings.DoPull = 0
    mq.cmdf("/beep")
end

---comment
---@param classes table|nil # mq.Set type
---@param resourceStartPct number
---@param resourceStopPct number
---@return boolean
function Module:CheckGroupForPull(classes, resourceStartPct, resourceStopPct, campData, returnToCamp)
    local groupCount = mq.TLO.Group.Members()

    if not groupCount or groupCount == 0 then return true end

    for i = 1, groupCount do
        local member = mq.TLO.Group.Member(i)

        if member and member.ID() > 0 then
            if not classes or classes:contains(member.Class.ShortName()) then
                local resourcePct = self.TempSettings.PullState == PullStates.PULL_GROUPWATCH_WAIT and resourceStopPct or resourceStartPct
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
        local wpId = self:GetCurrentWpId()
        local wpData = self:GetWPById(wpId)
        RGMercsLogger.log_debug(
            "FindTarget :: Mode: Farm :: pullradius %d pullzradius %d lowlvl %d highlvl %d use_only_nav 1 arc 0 xyz %0.2f, %0.2f, %0.2f",
            self.settings.PullRadiusFarm, self.settings.PullZRadius, self.settings.PullMinLevel, self.settings.PullMaxLevel, wpData.x, wpData.y, wpData.z)

        pullSearchString = pullSearchString .. string.format(" loc  %0.2f, %0.2f, %0.2f", wpData.x, wpData.y, wpData.z)
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
                RGMercsLogger.log_debug("\aoChecking Nav Pathing to %s (%d)", spawn.CleanName(), spawn.ID())
                if mq.TLO.Navigation.PathExists("id " .. spawn.ID())() then
                    local distance = mq.TLO.Navigation.PathLength("id " .. spawn.ID())()
                    RGMercsLogger.log_debug("\agNav Path Exists - Distance :: %d Radius :: %d", distance, pullRadius)
                    if distance < pullRadius then
                        RGMercsLogger.log_debug("\agPotential Pull %s --> Distance %d", spawn.CleanName(), distance)

                        -- TODO check whitelist / blacklist
                        table.insert(pullTargets, { spawn = spawn, distance = distance, })
                    else
                        RGMercsLogger.log_debug("\ayPotential Pull %s is OOR --> Distance %d", spawn.CleanName(), distance)
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

    if pullID == 0 then return true end

    RGMercsLogger.log_verbose("Checking for abort on spawn id: %d", pullID)
    local spawn = mq.TLO.Spawn(pullID)

    if not spawn or spawn.Dead() or not spawn.ID() or spawn.ID() == 0 then
        RGMercsLogger.log_debug("\ar ALERT: Aborting mob died or despawned \ax")
        return true
    end

    -- ignore distance if this is a manually requested pull
    if pullID ~= self.TempSettings.TargetSpawnID then
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
    end
    return false
end

---@param mode string
---@return boolean
function Module:IsPullMode(mode)
    return self.Constants.PullModes[self.settings.PullMode] == mode
end

---@return integer
function Module:GetPullState()
    return self.TempSettings.PullState
end

---@param state string
---@return boolean
function Module:IsPullState(state)
    return self.TempSettings.PullState == PullStates[state]
end

function Module:NavToWaypoint(loc, ignoreAggro)
    -- if DoMed is set it will take care of standing us up
    if mq.TLO.Me.Sitting() and RGMercConfig:GetSettings().DoMed then
        return
    end

    mq.TLO.Me.Stand()

    mq.cmdf("/nav locyxz %s, log=off", loc)
    mq.delay("2s")

    while mq.TLO.Navigation.Active() do
        RGMercsLogger.log_verbose("NavToWaypoint Aggro Count: %d", RGMercUtils.GetXTHaterCount())

        if RGMercUtils.GetXTHaterCount() > 0 and not ignoreAggro then
            mq.cmdf("/nav stop log=off")
            return false
        end

        if mq.TLO.Navigation.Velocity() == 0 then
            RGMercsLogger.log_warning("NavToWaypoint Velocity is 0 - Are we stuck?")
            if mq.TLO.Navigation.Paused() then
                mq.cmdf("/nav pause log=off")
            end
        end

        mq.delay(10)
    end

    return true
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

    if self.settings.PullAbility == PullAbilityIDToName.PetPull and (mq.TLO.Me.Pet.ID() or 0) == 0 then
        RGMercUtils.PrintGroupMessage("Need to create a new pet to throw as mob fodder.")
        return
    end

    if not self:ShouldPull() then
        return
    end

    if (os.clock() - self.TempSettings.LastPull) < self.settings.PullDelay then return end

    -- GROUPWATCH and NAVINTERRUPT are the two states we can't reset. In the future it may be best to
    -- limit this to only the states we know should be transitionable to the IDLE state.
    if self.TempSettings.PullState ~= PullStates.PULL_GROUPWATCH_WAIT and self.TempSettings.PullState ~= PullStates.PULL_NAV_INTERRUPT then
        self.TempSettings.PullState = PullStates.PULL_IDLE
    end

    self.TempSettings.LastPull = os.clock()

    if self.settings.GroupWatch == 1 then
        if not self:CheckGroupForPull(Set.new({ "CLR", "DRU", "SHM", }), self.settings.GroupWatchStartPct, self.settings.GroupWatchStopPct, campData, returnToCamp) then
            self.TempSettings.PullState = PullStates.PULL_GROUPWATCH_WAIT
            return
        end
    elseif self.settings.GroupWatch == 2 then
        if not self:CheckGroupForPull(nil, self.settings.GroupWatchStartPct, self.settings.GroupWatchStopPct, campData, returnToCamp) then
            self.TempSettings.PullState = PullStates.PULL_GROUPWATCH_WAIT
            return
        end
    end

    self.TempSettings.PullState = PullStates.PULL_IDLE

    -- We're ready to pull, but first, check if we're in farm mode and if we were interrupted
    if self:IsPullMode("Farm") then
        local currentWpId = self:GetCurrentWpId()
        if currentWpId == 0 then
            RGMercsLogger.log_error("\arYou do not have a valid WP ID(%d) for this zone(%s::%s) - Aborting!", self.TempSettings.CurrentWP, mq.TLO.Zone.Name(),
                mq.TLO.Zone.ShortName())
            self.TempSettings.PullState = PullStates.PULL_IDLE
            self.settings.DoPull = 0
            return
        end

        if self.TempSettings.PullState == PullStates.PULL_NAV_INTERRUPT then
            -- if we still have haters let combat handle it first.
            if RGMercUtils.GetXTHaterCount() > 0 then
                return
            end

            -- We're not ready to pull yet as we haven't made it to our waypoint. Keep navigating if we don't have a full inventory
            if mq.TLO.Me.FreeInventory() == 0 then self:FarmFullInvActions() end

            self.TempSettings.PullState = PullStates.PULL_MOVING_TO_WP
            -- TODO: PreNav Actions
            if not self:NavToWaypoint(self:GetWPById(currentWpId)) then
                self.TempSettings.PullState = PullStates.PULL_NAV_INTERRUPT
                return
            else
                self.TempSettings.PullState = PullStates.PULL_IDLE
            end
            self.TempSettings.PullState = PullStates.PULL_IDLE
        end

        -- We're not in an interrupted state if we make it this far -- so
        -- now make sure we have free inventory or not.
        if mq.TLO.Me.FreeInventory() == 0 then self:FarmFullInvActions() end
    end

    self.TempSettings.PullState = PullStates.PULL_SCAN

    local pullID = 0

    if self.TempSettings.TargetSpawnID > 0 then
        local targetSpawn = mq.TLO.Spawn(self.TempSettings.TargetSpawnID)
        if not targetSpawn() or targetSpawn.Dead() or targetSpawn.PctHPs() == 0 then
            RGMercsLogger.log_debug("\arDropping Manual target id %d - it is dead.", self.TempSettings.TargetSpawnID)
            self.TempSettings.TargetSpawnID = 0
        end
    end

    if self.TempSettings.TargetSpawnID > 0 then
        pullID = self.TempSettings.TargetSpawnID
    else
        RGMercsLogger.log_debug("Finding Pull Target")
        pullID = self:FindTarget()
    end

    if pullID == 0 and self:IsPullMode("Farm") then
        -- move to next WP
        self:IncrementWpId()
        -- Here we want to nav to our current waypoint. If we engage an enemy while
        -- we are currently traveling to our waypoint, we need to set our state to
        -- PULL_NAVINTERRUPT so that when Pulling re-engages after combat, we continue
        -- to travel to our next waypoint.

        -- TODO: PreNav()
        --/if (${SubDefined[${Zone.ShortName}_PreNav_${Pull_FarmWPNum}]}) /call ${Zone.ShortName}_PreNav_${Pull_FarmWPNum}

        self.TempSettings.PullState = PullStates.PULL_MOVING_TO_WP

        local wpData = self:GetWPById(self:GetCurrentWpId())
        if not self:NavToWaypoint(string.format("%0.2f, %0.2f, %0.2f", wpData.y, wpData.x, wpData.z)) then
            self.TempSettings.PullState = PullStates.PULL_NAVINTERRUPT
            return
        else
            -- TODO: AtWP()
            --/if (${SubDefined[${Zone.ShortName}_AtWaypoint_${Pull_FarmWPNum}]}) /call ${Zone.ShortName}_AtWaypoint_${Pull_FarmWPNum}
        end

        self.TempSettings.PullState = PullStates.PULL_IDLE
        return
    end

    self.TempSettings.PullState = PullStates.PULL_IDLE

    if pullID == 0 then
        RGMercsLogger.log_debug("\ayNothing to pull - better luck next time")
        return
    end

    local start_x = mq.TLO.Me.X()
    local start_y = mq.TLO.Me.Y()
    local start_z = mq.TLO.Me.Z()

    if returnToCamp then
        RGMercsLogger.log_debug("\ayStoring Camp info to return to")
        start_x = campData.CampX
        start_y = campData.CampY
        start_z = campData.CampZ
    end

    RGMercsLogger.log_debug("\ayRTB Location: %d %d %d", start_y, start_x, start_z)

    -- if DoMed is set it will take care of standing us up
    if mq.TLO.Me.Sitting() and RGMercConfig:GetSettings().DoMed then
        return
    end

    mq.TLO.Me.Stand()

    self.TempSettings.PullState = PullStates.PULL_NAV_TO_TARGET
    RGMercsLogger.log_debug("\ayFound Target: %d - Attempting to Nav", pullID)

    local pullAbility = self.Constants.PullAbilities[self.settings.PullAbility]
    local startingXTargs = RGMercUtils.GetXTHaterIDs()

    mq.cmdf("/nav id %d distance=%d lineofsight=%s log=off", pullID, pullAbility.AbilityRange, "off")

    mq.delay(1000)

    local abortPull = false

    while mq.TLO.Navigation.Active() do
        if self:IsPullMode("Chain") then
            if RGMercUtils.GetXTHaterCount() > self.settings.ChainCount then
                RGMercsLogger.log_info("\awNOTICE:\ax Gained aggro -- aborting chain pull!")
                abortPull = true
                break
            end
            if RGMercUtils.DiffXTHaterIDs(startingXTargs) then
                RGMercsLogger.log_info("\awNOTICE:\ax XTarget List Changed -- aborting chain pull!")
                abortPull = true
                break
            end
            startingXTargs = RGMercUtils.GetXTHaterIDs()
        else
            if RGMercUtils.GetXTHaterCount() > 0 then
                RGMercsLogger.log_info("\awNOTICE:\ax Gained aggro -- aborting pull!")
                abortPull = true
                break
            end
        end

        if self:CheckForAbort(pullID) then
            abortPull = true
            break
        end

        mq.delay(100)
        mq.doevents()
    end

    mq.delay("2s", function() return not mq.TLO.Me.Moving() end)

    -- TODO: PrePullTarget()

    RGMercUtils.SetTarget(pullID)

    if RGMercConfig:GetSettings().SafeTargeting then
        -- Hard coding 500 units as our radius as it's probably twice our effective spell range.
        if RGMercUtils.IsSpawnFightingStranger(mq.TLO.Spawn(pullID), 500) then
            abortPull = true
        end
    end

    if abortPull == false then
        local target = mq.TLO.Target
        self.TempSettings.PullState = PullStates.PULL_PULLING

        if target and target.ID() > 0 then
            RGMercsLogger.log_info("\agPulling %s [%d]", target.CleanName(), target.ID())

            local successFn = function(self) return RGMercUtils.GetXTHaterCount() > 0 end

            if self:IsPullMode("Chain") then
                successFn = function(self) return RGMercUtils.GetXTHaterCount() > self.settings.ChainCount end
            end

            if self.settings.PullAbility == PullAbilityIDToName.PetPull then -- PetPull
                RGMercUtils.PetAttack(pullID)
                while not successFn(self) do
                    startingXTargs = RGMercUtils.GetXTHaterIDs()
                    RGMercUtils.PetAttack(pullID)
                    mq.doevents()
                    if self:IsPullMode("Chain") and RGMercUtils.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(pullID) then
                        break
                    end
                    mq.delay(10)
                end

                if RGMercUtils.CanUseAA("Companion's Discipline") then
                    mq.cmdf("/squelch /pet ghold on")
                end
                mq.cmdf("/squelch /pet back off")
                mq.delay("1s", function() return (mq.TLO.Pet.PlayerState() or 0) == 0 end)
                mq.cmdf("/squelch /pet follow")
            elseif self.settings.PullAbility == PullAbilityIDToName.Ranged then -- Ranged pull
                -- Make sure we're looking straight ahead at our mob and delay
                -- until we're facing them.
                mq.cmdf("/look 0")

                mq.delay("3s", function() return mq.TLO.Me.Heading.ShortName() == target.HeadingTo.ShortName() end)

                -- We will continue to fire arrows until we aggro our target
                while not successFn(self) do
                    startingXTargs = RGMercUtils.GetXTHaterIDs()
                    mq.cmdf("/ranged %d", pullID)
                    mq.doevents()
                    if self:IsPullMode("Chain") and RGMercUtils.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(pullID) then
                        break
                    end
                    mq.delay(10)
                end
            else -- AA/Spell/Ability pull
                mq.delay(5)
                while not successFn(self) do
                    startingXTargs = RGMercUtils.GetXTHaterIDs()
                    mq.cmdf("/target ID %d", pullID)
                    mq.doevents()

                    if pullAbility.Type:lower() == "ability" then
                        if mq.TLO.Me.AbilityReady(pullAbility.id) then
                            RGMercUtils.UseAbility(pullAbility.id)
                        end
                    elseif pullAbility.Type():lower() == "spell" then
                        RGMercUtils.UseSpell(pullAbility.id, pullID, true)
                    end

                    if self:IsPullMode("Chain") and RGMercUtils.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(pullID) then
                        break
                    end
                    mq.delay(10)
                end
            end
        end
    else
        RGMercsLogger.log_debug("\arNOTICE:\ax Pull Aborted!")
        mq.cmdf("/nav stop log=off")
        mq.delay("2s", function() return not mq.TLO.Navigation.Active() end)
    end

    if self:IsPullMode("Normal") or self:IsPullMode("Chain") then
        -- Nav back to camp.
        self.TempSettings.PullState = PullStates.PULL_RETURN_TO_CAMP

        mq.cmdf("/nav locyxz %0.2f %0.2f %0.2f log=off", start_y, start_x, start_z)
        mq.delay("5s", function() return mq.TLO.Navigation.Active() end)

        while mq.TLO.Navigation.Active() do
            if mq.TLO.Me.State():lower() == "feign" or mq.TLO.Me.Sitting() then
                RGMercsLogger.log_debug("Standing up to Engage Target")
                mq.TLO.Me.Stand()
                mq.cmdf("/nav locyxz %0.2f %0.2f %0.2f log=off", start_y, start_x, start_z)
                mq.delay("5s", function() return mq.TLO.Navigation.Active() end)
            end

            mq.doevents()
            mq.delay(10)
        end

        mq.cmdf("/face id %d", pullID)

        -- TODO PostPullCampFunc()
    end

    self.TempSettings.TargetSpawnID = 0
    self.TempSettings.PullState = PullStates.PULL_IDLE
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
    RGMercsLogger.log_info("Pull Combat Module Unloaded.")
end

return Module
