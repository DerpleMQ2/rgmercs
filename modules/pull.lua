-- Sample Pull Class Module
local mq                                 = require('mq')
local RGMercUtils                        = require("utils.rgmercs_utils")
local Set                                = require("mq.Set")
local ICONS                              = require('mq.Icons')

local Module                             = { _version = '0.1a', _name = "Pull", _author = 'Derple', }
Module.__index                           = Module
Module.settings                          = {}
Module.ModuleLoaded                      = false
Module.TempSettings                      = {}
Module.TempSettings.LastPull             = os.clock()
Module.TempSettings.TargetSpawnID        = 0
Module.TempSettings.CurrentWP            = 1
Module.TempSettings.PullTargets          = {}
Module.TempSettings.AbortPull            = false
Module.TempSettings.PullID               = 0
Module.TempSettings.LastPullAbilityCheck = 0


local PullStates              = {
    ['PULL_IDLE']               = 1,
    ['PULL_GROUPWATCH_WAIT']    = 2,
    ['PULL_NAV_INTERRUPT']      = 3,
    ['PULL_SCAN']               = 4,
    ['PULL_PULLING']            = 5,
    ['PULL_MOVING_TO_WP']       = 6,
    ['PULL_NAV_TO_TARGET']      = 7,
    ['PULL_RETURN_TO_CAMP']     = 8,
    ['PULL_WAITING_ON_MOB']     = 9,
    ['PULL_WAITING_SHOULDPULL'] = 10,
}

local PullStateDisplayStrings = {
    ['PULL_IDLE']               = { Display = ICONS.FA_CLOCK_O, Text = "Idle", Color = { r = 0.02, g = 0.8, b = 0.2, a = 1.0, }, },
    ['PULL_GROUPWATCH_WAIT']    = { Display = ICONS.MD_GROUP, Text = "Waiting on GroupWatch", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_NAV_INTERRUPT']      = { Display = ICONS.MD_PAUSE_CIRCLE_OUTLINE, Text = "Navigation interrupted", Color = { r = 0.8, g = 0.02, b = 0.02, a = 1.0, }, },
    ['PULL_SCAN']               = { Display = ICONS.FA_EYE, Text = "Scanning for Targest", Color = { r = 0.02, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_PULLING']            = { Display = ICONS.FA_BULLSEYE, Text = "Pulling", Color = { r = 0.8, g = 0.03, b = 0.02, a = 1.0, }, },
    ['PULL_MOVING_TO_WP']       = { Display = ICONS.MD_DIRECTIONS_RUN, Text = "Moving to Next WP", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_NAV_TO_TARGET']      = { Display = ICONS.MD_DIRECTIONS_RUN, Text = "Naving to Target", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_RETURN_TO_CAMP']     = { Display = ICONS.FA_FREE_CODE_CAMP, Text = "Returning to Camp", Color = { r = 0.08, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_WAITING_ON_MOB']     = { Display = ICONS.FA_CLOCK_O, Text = "Waiting on Mob", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_WAITING_SHOULDPULL'] = { Display = ICONS.FA_CLOCK_O, Text = "Waiting for Should Pull", Color = { r = 0.8, g = 0.04, b = 0.02, a = 1.0, }, },
}

local PullStatesIDToName      = {}
for k, v in pairs(PullStates) do PullStatesIDToName[v] = k end

Module.TempSettings.PullState          = PullStates.PULL_IDLE
Module.TempSettings.PullStateReason    = ""

Module.Constants                       = {}
Module.Constants.PullModes             = {
    "Normal",
    "Chain",
    "Hunt",
    "Farm",
}

Module.Constants.PullAbilities         = {
    {
        id = "Face",
        Type = "Special",
        AbilityRange = 5,
        DisplayName = "Face Pull",
        cond = function(self)
            return true
        end,
    },
    {
        id = "PetPull",
        Type = "Special",
        AbilityRange = 100,
        DisplayName = "Pet Pull",
        cond = function(self)
            return RGMercConfig.Constants.RGPetClass:contains(RGMercConfig.Globals.CurLoadedClass)
        end,
    },
    {
        id = "Taunt",
        Type = "Ability",
        DisplayName = "Taunt",
        AbilityName = "Taunt",
        AbilityRange = 10,
        cond = function(self)
            return mq.TLO.Me.Skill("Taunt")() > 0
        end,
    },
    {
        id = "Ranged",
        Type = "Special",
        DisplayName = "Ranged",
        AbilityRange = function() return mq.TLO.Me.Inventory("ranged").Range() end,
        cond = function(self)
            local rangedType = (mq.TLO.Me.Inventory("ranged").Type() or ""):lower()
            return rangedType == "archery" or rangedType == "bow" and mq.TLO.FindItemCount("Arrow")() > 1
        end,
    },
    {
        id = "Kick",
        Type = "Ability",
        DisplayName = "Kick",
        AbilityName = "Kick",
        AbilityRange = 10,
        cond = function(self)
            return mq.TLO.Me.Skill("Kick")() > 0
        end,
    },
}

local PullAbilityIDToName              = {}

Module.TempSettings.ValidPullAbilities = {}

Module.DefaultConfig                   = {
    ['DoPull']             = { DisplayName = "Enable Pulling", Category = "Pulling", Tooltip = "Enable pulling", Default = false, },
    ['PullAbility']        = { DisplayName = "Pull Ability", Category = "Pulling", Tooltip = "What should we pull with?", Default = 1, Type = "Custom", },
    ['PullMode']           = { DisplayName = "Pull Mode", Category = "Pulling", Tooltip = "1 = Normal, 2 = Chain, 3 = Hunt, 4 = Farm", Type = "Custom", Default = 1, Min = 1, Max = 4, },
    ['ChainCount']         = { DisplayName = "Chain Count", Category = "Pulling", Tooltip = "Number of mobs in chain pull mode on xtarg before we stop pulling", Default = 3, Min = 1, Max = 100, },
    ['PullDelay']          = { DisplayName = "Pull Delay", Category = "Pulling", Tooltip = "Seconds between pulls", Default = 5, Min = 1, Max = 300, },
    ['PullRadius']         = { DisplayName = "Pull Radius", Category = "Pull Distance", Tooltip = "Distnace to pull", Default = 90, Min = 1, Max = 10000, },
    ['PullZRadius']        = { DisplayName = "Pull Z Radius", Category = "Pull Distance", Tooltip = "Distnace to pull on Z axis", Default = 90, Min = 1, Max = 150, },
    ['PullRadiusFarm']     = { DisplayName = "Pull Radius Farm", Category = "Pull Distance", Tooltip = "Distnace to pull in Farm mode", Default = 90, Min = 1, Max = 10000, },
    ['PullMinCon']         = { DisplayName = "Pull Min Con", Category = "Pull Targets", Tooltip = "Min Con Mobs to consider pulling", Default = 2, Type = "Combo", ComboOptions = RGMercConfig.Constants.ConColors, },
    ['PullMaxCon']         = { DisplayName = "Pull Max Con", Category = "Pull Targets", Tooltip = "Max Con Mobs to consider pulling", Default = 5, Type = "Combo", ComboOptions = RGMercConfig.Constants.ConColors, },
    ['UsePullLevels']      = { DisplayName = "Use Pull Levels", Category = "Pull Targets", Tooltip = "Use Min and Max Levels Instead of Con.", Default = false, ConfigType = "Advanced", },
    ['PullMinLevel']       = { DisplayName = "Pull Min Level", Category = "Pull Targets", Tooltip = "Min Level Mobs to consider pulling", Default = mq.TLO.Me.Level() - 3, Min = 1, Max = 150, ConfigType = "Advanced", },
    ['PullMaxLevel']       = { DisplayName = "Pull Max Level", Category = "Pull Targets", Tooltip = "Max Level Mobs to consider pulling", Default = mq.TLO.Me.Level() + 3, Min = 1, Max = 150, ConfigType = "Advanced", },
    ['GroupWatch']         = { DisplayName = "Enable Group Watch", Category = "Group Watch", Tooltip = "1 = Off, 2 = Healers, 3 = Everyone", Type = "Combo", ComboOptions = { 'Off', 'Healers', 'Everyone', }, Default = 1, Min = 1, Max = 3, },
    ['GroupWatchStartPct'] = { DisplayName = "Group Watch Start %", Category = "Group Watch", Tooltip = "If your group member is above [X]% resource, start pulls again.", Default = 80, Min = 1, Max = 100, },
    ['GroupWatchStopPct']  = { DisplayName = "Group Watch Stop %", Category = "Group Watch", Tooltip = "If your group member is below [X]% resource, stop pulls.", Default = 20, Min = 1, Max = 100, },
    ['PullHPPct']          = { DisplayName = "Pull HP %", Category = "Group Watch", Tooltip = "Make sure you have at least this much HP %", Default = 20, Min = 1, Max = 100, },
    ['PullManaPct']        = { DisplayName = "Pull Mana %", Category = "Group Watch", Tooltip = "Make sure you have at least this much Mana %", Default = 20, Min = 1, Max = 100, },
    ['FarmWayPoints']      = { DisplayName = "Farming Waypoints", Category = "", Tooltip = "", Type = "Custom", Default = {}, },
    ['PullAllowList']      = { DisplayName = "Allow List", Category = "", Tooltip = "", Type = "Custom", Default = {}, },
    ['PullDenyList']       = { DisplayName = "Deny List", Category = "", Tooltip = "", Type = "Custom", Default = {}, },
    ['PullMobsInWater']    = { DisplayName = "Pull Mobs In Water", Category = "Pulling", Tooltip = "Pull Mobs that are in water bodies? If you are low level you might drown.", Default = false, },
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
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast == true then
        RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    RGMercsLogger.log_info("Pull Combat Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Pull]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self:SaveSettings(false)
    else
        self.settings = config()
    end

    -- turn off at startup for safety
    self.settings.DoPull = false

    -- Setup Defaults
    self.settings = RGMercUtils.ResolveDefaults(self.DefaultConfig, self.settings)
end

---@param id number
---@return string
function Module:getPullAbilityDisplayName(id)
    local displayName = self.TempSettings.ValidPullAbilities[id].DisplayName

    if type(displayName) == 'function' then displayName = displayName() end

    return displayName or "Error"
end

function Module:SetValidPullAbilities()
    if os.clock() - self.TempSettings.LastPullAbilityCheck < 10 then return end

    self.TempSettings.LastPullAbilityCheck = os.clock()
    local tmpValidPullAbilities = {}
    local tmpPullAbilityIDToName = {}

    for k, v in ipairs(Module.Constants.PullAbilities) do
        if RGMercUtils.SafeCallFunc("Checking Pull Ability Condition", v.cond, self) then
            table.insert(tmpValidPullAbilities, v)
            tmpPullAbilityIDToName[v.id] = k
        end
    end

    -- pull in class specific configs.
    for k, v in ipairs(RGMercModules:ExecModule("Class", "GetPullAbilities")) do
        if RGMercUtils.SafeCallFunc("Checking Pull Ability Condition", v.cond, self) then
            table.insert(tmpValidPullAbilities, v)
            tmpPullAbilityIDToName[v.id] = k
        end
    end

    self.TempSettings.ValidPullAbilities = tmpValidPullAbilities
    PullAbilityIDToName = tmpPullAbilityIDToName
end

function Module:OnCombatModeChanged()
    self:SetValidPullAbilities()
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    RGMercsLogger.log_info("Pull Module Loaded.")
    self:LoadSettings()
    self.ModuleLoaded = true
    return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:RenderMobList(displayName, settingName)
    if ImGui.CollapsingHeader(string.format("Pull %s", displayName)) then
        if mq.TLO.Target() and mq.TLO.Target.Type() == "NPC" then
            ImGui.PushID("##_small_btn_allow_target_" .. settingName)
            if ImGui.SmallButton(string.format("Add Target To %s", displayName)) then
                self:AddMobToList(settingName, mq.TLO.Target.CleanName())
            end
            ImGui.PopID()
        end

        if ImGui.BeginTable("settingName", 4, bit32.bor(ImGuiTableFlags.Borders)) then
            ImGui.TableSetupColumn('Id', (ImGuiTableColumnFlags.WidthFixed), 40.0)
            ImGui.TableSetupColumn('Count', (ImGuiTableColumnFlags.WidthFixed), 40.0)
            ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthStretch), 150.0)
            ImGui.TableSetupColumn('Controls', (ImGuiTableColumnFlags.WidthFixed), 80.0)
            ImGui.TableHeadersRow()

            for idx, mobName in ipairs(self.settings[settingName][mq.TLO.Zone.ShortName()] or {}) do
                ImGui.TableNextColumn()
                ImGui.Text(tostring(idx))
                ImGui.TableNextColumn()
                ImGui.Text(tostring(mq.TLO.SpawnCount(string.format("NPC %s", mobName))))
                ImGui.TableNextColumn()
                ImGui.Text(mobName)
                ImGui.TableNextColumn()
                ImGui.PushID("##_small_btn_delete_mob_" .. settingName .. tostring(idx))
                if ImGui.SmallButton(ICONS.FA_TRASH) then
                    self:DeleteMobFromList(settingName, idx)
                end
                ImGui.PopID()
            end

            ImGui.EndTable()
        end
    end
end

function Module:RenderPullTargets()
    if ImGui.BeginTable("Pull Targets", 5, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Index', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.None), 250.0)
        ImGui.TableSetupColumn('Level', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthFixed), 160.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, target in ipairs(self.TempSettings.PullTargets) do
            local spawn = target.spawn
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            ImGui.TableNextColumn()
            ImGui.Text(spawn.CleanName() or "Unknown")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(spawn.Level() or 0))
            ImGui.TableNextColumn()
            ImGui.Text(tostring(math.ceil(spawn.Distance() or 0)))
            ImGui.TableNextColumn()
            RGMercUtils.NavEnabledLoc(spawn.LocYXZ() or "0,0,0")
        end

        ImGui.EndTable()
    end
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    ImGui.Text("Pull")

    local pressed

    -- dead... whoops
    if mq.TLO.Me.Hovering() then return end

    if self.ModuleLoaded then
        if self.settings.DoPull then
            ImGui.PushStyleColor(ImGuiCol.Button, 0.5, 0.02, 0.02, 1)
        else
            ImGui.PushStyleColor(ImGuiCol.Button, 0.02, 0.5, 0.0, 1)
        end

        if ImGui.Button(self.settings.DoPull and "Stop Pulls" or "Start Pulls", ImGui.GetWindowWidth() * .3, 25) then
            self.settings.DoPull = not self.settings.DoPull
            self:SaveSettings(false)
        end
        ImGui.PopStyleColor()

        if mq.TLO.Target() and mq.TLO.Target.Type() == "NPC" then
            ImGui.SameLine()
            if ImGui.Button("Pull Target " .. ICONS.FA_BULLSEYE, ImGui.GetWindowWidth() * .3, 25) then
                self.TempSettings.TargetSpawnID = mq.TLO.Target.ID()
            end
        end

        local campData = RGMercModules:ExecModule("Movement", "GetCampData")

        if campData.returnToCamp then
            if ImGui.SmallButton("Break Camp") then
                RGMercUtils.DoCmd("/rgl campoff")
            end
        else
            if ImGui.SmallButton("Set New Camp Here") then
                RGMercUtils.DoCmd("/rgl campon")
            end
        end

        self.settings.PullMode, pressed = ImGui.Combo("Pull Mode", self.settings.PullMode, self.Constants.PullModes, #self.Constants.PullModes)
        if pressed then
            self:SaveSettings(false)
        end
        if #self.TempSettings.ValidPullAbilities > 0 then
            self.settings.PullAbility, pressed = ImGui.Combo("Pull Ability", self.settings.PullAbility, function(id) return self:getPullAbilityDisplayName(id) end,
                #self.TempSettings.ValidPullAbilities) --, self.TempSettings.ValidPullAbilities, #self.TempSettings.ValidPullAbilities)
            if pressed then
                self:SaveSettings(false)
            end
        end

        local nextPull = self.settings.PullDelay - (os.clock() - self.TempSettings.LastPull)
        if nextPull < 0 then nextPull = 0 end
        if ImGui.BeginTable("PullState", 2, bit32.bor(ImGuiTableFlags.Borders)) then
            ImGui.TableNextColumn()
            ImGui.Text("Pull State")
            ImGui.TableNextColumn()
            local stateData = PullStateDisplayStrings[PullStatesIDToName[self.TempSettings.PullState]]
            local stateColor = ImGui.GetColorU32(stateData.Color.r or 1.0, stateData.Color.g or 1.0, stateData.Color.b or 1.0, stateData.Color.a or 1.0)
            ImGui.PushStyleColor(ImGuiCol.Text, stateColor)
            if not stateData then
                ImGui.Text("Invalid State Data... This should auto resolve.")
            else
                ImGui.Text(stateData.Display .. " " .. stateData.Text)
            end
            ImGui.PopStyleColor()
            ImGui.TableNextColumn()
            ImGui.Text("Pull State Reason")
            ImGui.TableNextColumn()
            ImGui.PushStyleColor(ImGuiCol.Text, stateColor)
            ImGui.Text(self.TempSettings.PullStateReason:len() > 0 and self.TempSettings.PullStateReason or "N/A")
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
            ImGui.Text("Pull Range")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(self:GetPullAbilityRange()))
            ImGui.TableNextColumn()
            ImGui.Text("Pull ID")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(self.TempSettings.PullID))
            ImGui.TableNextColumn()
            ImGui.Text("Pull Target Count")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(#self.TempSettings.PullTargets))
            ImGui.TableNextColumn()
            ImGui.Text("Current Farm WP ID")
            ImGui.TableNextColumn()
            local wpId = self:GetCurrentWpId()
            local wpData = self:GetWPById(wpId)
            ImGui.Text(wpId == 0 and "<None>" or string.format("%d [y: %0.2f, x: %0.2f, z: %0.2f]", wpId, wpData.y, wpData.x, wpData.z))
            ImGui.EndTable()
        end

        ImGui.NewLine()
        ImGui.Separator()
        ImGui.Text("Note: Allow List will supersede Deny List")
        self:RenderMobList("Allow List", "PullAllowList")
        self:RenderMobList("Deny List", "PullDenyList")
        ImGui.NewLine()
        ImGui.Separator()

        if ImGui.CollapsingHeader("Pull Targets") then
            self:RenderPullTargets()
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

                local waypointList = self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] or {}
                for idx, wpData in ipairs(waypointList) do
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
                    if idx == 1 then
                        ImGui.InvisibleButton(ICONS.FA_CHEVRON_UP, ImVec2(22, 1))
                    else
                        if ImGui.SmallButton(ICONS.FA_CHEVRON_UP) then
                            self:MoveWayPointUp(idx)
                        end
                    end
                    ImGui.PopID()
                    ImGui.SameLine()
                    ImGui.PushID("##_small_btn_dn_wp_" .. tostring(idx))
                    if idx == #waypointList then
                        ImGui.InvisibleButton(ICONS.FA_CHEVRON_DOWN, ImVec2(22, 1))
                    else
                        if ImGui.SmallButton(ICONS.FA_CHEVRON_DOWN) then
                            self:MoveWayPointDown(idx)
                        end
                    end
                    ImGui.PopID()
                end

                ImGui.EndTable()
            end
        end
    end

    if ImGui.CollapsingHeader("Config Options") then
        if self.ModuleLoaded then
            self.settings, pressed, _ = RGMercUtils.RenderSettings(self.settings, self.DefaultConfig, self.DefaultCategories)
            if pressed then
                self:SaveSettings(false)
            end
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
    return (self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] and
            (id <= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()])) and
        self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id] or { x = 0, y = 0, z = 0, }
end

---@param listName string
---@return boolean
function Module:HaveList(listName)
    return self.settings[listName][mq.TLO.Zone.ShortName()] and #self.settings[listName][mq.TLO.Zone.ShortName()] > 0
end

---@param listName string
---@param mobName string
---@param defaultNoList boolean # Default to return if there is no list.
---@return boolean
function Module:IsMobInList(listName, mobName, defaultNoList)
    -- no list so everything is allowed.
    if not self:HaveList(listName) then return defaultNoList end

    for _, v in ipairs(self.settings[listName][mq.TLO.Zone.ShortName()]) do
        if v == mobName then return true end
    end

    return false
end

---@param list string
---@param mobName string
function Module:AddMobToList(list, mobName)
    self.settings[list][mq.TLO.Zone.ShortName()] = self.settings[list][mq.TLO.Zone.ShortName()] or {}
    table.insert(self.settings[list][mq.TLO.Zone.ShortName()], mobName)
    self:SaveSettings(false)
end

---@param list string
---@param idx number
function Module:DeleteMobFromList(list, idx)
    self.settings[list][mq.TLO.Zone.ShortName()] = self.settings[list][mq.TLO.Zone.ShortName()] or {}
    self.settings[list][mq.TLO.Zone.ShortName()][idx] = nil
    self:SaveSettings(false)
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

    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId], self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id] =
        self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id], self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId]
    self:SaveSettings(false)
end

---@param id number
function Module:MoveWayPointDown(id)
    local newId = id + 1

    if id < 1 then return end
    if newId > #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then return end

    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId], self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id] =
        self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id], self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId]

    self:SaveSettings(false)
end

function Module:CreateWayPointHere()
    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] = self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] or {}
    table.insert(self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()], { x = mq.TLO.Me.X(), y = mq.TLO.Me.Y(), z = mq.TLO.Me.Z(), })
    self:SaveSettings(false)
    RGMercsLogger.log_info("\axNew waypoint \at%d\ax created at location \ag%02.f, %02.f, %02.f", #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()],
        mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z())
end

function Module:DeleteWayPoint(idx)
    if idx <= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then
        RGMercsLogger.log_info("\axWaypoint \at%d\ax at location \ag%s\ax - \arDeleted!\ax", idx, self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][idx].Loc)
        table.remove(self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()], idx)
        self:SaveSettings(false)
    else
        RGMercsLogger.log_error("\ar%d is not a valid waypoint ID!", idx)
    end
end

--- @return boolean, string
function Module:ShouldPull()
    local me = mq.TLO.Me

    if me.PctHPs() < self.settings.PullHPPct then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax PctHPs < %d", self.settings.PullHPPct)
        return false, string.format("PctHPs < %d", self.settings.PullHPPct)
    end

    if me.MaxMana() > 0 and me.PctMana() < self.settings.PullManaPct then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax PctMana < %d", self.settings.PullManaPct)
        return false, string.format("PctMana < %d", self.settings.PullManaPct)
    end

    if RGMercUtils.SongActive("Restless Ice") then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax I Have Restless Ice!")
        return false, string.format("Restless Ice")
    end

    if RGMercUtils.SongActive("Restless Ice Infection") then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax I Have Restless Ice Infection!")
        return false, string.format("Ice Infection")
    end

    if RGMercUtils.BuffActiveByName("Resurrection Sickness") then return false, string.format("Resurrection Sickness") end

    if (me.Snared.ID() or 0 > 0) then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am snared!")
        return false, string.format("Snared")
    end

    if (me.Rooted.ID() or 0 > 0) then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am rooted!")
        return false, string.format("Rooted")
    end

    if (me.Poisoned.ID() or 0 > 0) and not (me.Tashed.ID()) or 0 > 0 then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am poisoned!")
        return false, string.format("Poisoned")
    end

    if (me.Diseased.ID() or 0 > 0) then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am diseased!")
        return false, string.format("Diseased")
    end

    if (me.Cursed.ID() or 0 > 0) then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am cursed!")
        return false, string.format("Cursed")
    end

    if (me.Corrupted.ID() or 0 > 0) then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am corrupted!")
        return false, string.format("Corrupted")
    end

    if self:IsPullMode("Chain") and RGMercUtils.GetXTHaterCount() > self.settings.ChainCount then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax XTargetCount(%d) > ChainCount(%d)", RGMercUtils.GetXTHaterCount(), self.settings.ChainCount)
        return false, string.format("XTargetCount(%d) > ChainCount(%d)", RGMercUtils.GetXTHaterCount(), self.settings.ChainCount)
    end

    if not self:IsPullMode("Chain") and RGMercUtils.GetXTHaterCount() > 0 then
        RGMercsLogger.log_super_verbose("\ay::PULL:: \arAborted!\ax XTargetCount(%d) > 0", RGMercUtils.GetXTHaterCount())
        return false, string.format("XTargetCount(%d) > 0", RGMercUtils.GetXTHaterCount())
    end

    return true, ""
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
    RGMercUtils.DoCmd("/beep")
end

---comment
---@param classes table|nil # mq.Set type
---@param resourceStartPct number
---@param resourceStopPct number
---@return boolean, string
function Module:CheckGroupForPull(classes, resourceStartPct, resourceStopPct, campData, returnToCamp)
    local groupCount = mq.TLO.Group.Members()

    if not groupCount or groupCount == 0 then return true, "" end

    for i = 1, groupCount do
        local member = mq.TLO.Group.Member(i)

        if member and member.ID() > 0 then
            if not classes or classes:contains(member.Class.ShortName()) then
                local resourcePct = self.TempSettings.PullState == PullStates.PULL_GROUPWATCH_WAIT and resourceStopPct or resourceStartPct
                if member.PctHPs() < resourcePct then
                    RGMercUtils.PrintGroupMessage("%s is low on hp - Holding pulls!", member.CleanName())
                    return false, string.format("%s Low HP", member.CleanName())
                end
                if member.Class.CanCast() and member.PctMana() < resourcePct then
                    RGMercUtils.PrintGroupMessage("%s is low on mana - Holding pulls!", member.CleanName())
                    return false, string.format("%s Low Mana", member.CleanName())
                end
                if member.PctEndurance() < resourcePct then
                    RGMercUtils.PrintGroupMessage("%s is low on endurance - Holding pulls!", member.CleanName())
                    return false, string.format("%s Low End", member.CleanName())
                end

                if member.Hovering() then
                    RGMercUtils.PrintGroupMessage("%s is dead - Holding pulls!", member.CleanName())
                    return false, string.format("%s Dead", member.CleanName())
                end

                if member.OtherZone() then
                    RGMercUtils.PrintGroupMessage("%s is in another zone - Holding pulls!", member.CleanName())
                    return false, string.format("%s Out of Zone", member.CleanName())
                end

                if (member.Distance() or 0) >

                    RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius then
                    RGMercUtils.PrintGroupMessage("%s is too far away - Holding pulls!", member.CleanName())
                    return false, string.format("%s Too Far", member.CleanName())
                end

                if self.Constants.PullModes[self.settings.PullMode] == "Chain" then
                    if member.ID() == RGMercUtils.GetMainAssistId() then
                        if returnToCamp and RGMercUtils.GetDistance(member.Y(), member.X(), campData.AutoCampX, campData.AutoCampY) > RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius then
                            RGMercUtils.PrintGroupMessage("%s (assist target) is beyond AutoCampRadius from %d, %d, %d : %d. Holding pulls.", member.CleanName(), campData.AutoCampY,
                                campData.AutoCampX, campData.AutoCampZ, RGMercConfig.SubModuleSettings.settings.Movement.settings.AutoCampRadius)
                            return false, string.format("%s Beyond AutoCampRadius", member.CleanName())
                        end
                    else
                        if RGMercUtils.GetDistance(member.Y(), member.X(), mq.TLO.Me.X(), mq.TLO.Me.Y()) > RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius then
                            RGMercUtils.PrintGroupMessage("%s (assist target) is beyond AutoCampRadius from me : %d. Holding pulls.", member.CleanName(),
                                RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius)
                            return false, string.format("%s Beyond AutoCampRadius", member.CleanName())
                        end
                    end
                end
            end
        end
    end

    return true, ""
end

function Module:FindTarget()
    local pullRadius = self.Constants.PullModes[self.settings.PullMode] == "Farm" and self.settings.PullRadiusFarm or self.settings.PullRadius
    local pullSearchString = string.format("npc radius %d targetable zradius %d range %d %d playerstate 0",
        pullRadius, self.settings.PullZRadius,
        (self.settings.UsePullLevels and self.settings.PullMinLevel or 1),
        (self.settings.UsePullLevels and self.settings.PullMaxLevel or 999))

    if self:IsPullMode("Farm") then
        local wpId = self:GetCurrentWpId()
        local wpData = self:GetWPById(wpId)
        pullSearchString = pullSearchString .. string.format(" loc  %0.2f, %0.2f, %0.2f", wpData.x, wpData.y, wpData.z)
        RGMercsLogger.log_debug("FindTarget :: Mode: Farm :: %s", pullSearchString)
    else
        RGMercsLogger.log_debug("FindTarget :: Mode: %s :: %s", self.Constants.PullModes[self.settings.PullMode], pullSearchString)
    end

    local pullCount = mq.TLO.SpawnCount(pullSearchString)()
    RGMercsLogger.log_debug("\awSearch (\at%s\aw) Found :: \am%d\ax", pullSearchString, pullCount)

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
                    RGMercsLogger.log_verbose("\agNav Path Exists - Distance :: %d Radius :: %d", distance, pullRadius)
                    if distance < pullRadius then
                        RGMercsLogger.log_debug("\agPotential Pull %s --> Distance %d", spawn.CleanName(), distance)
                        local doInsert = true

                        if not self.settings.UsePullLevels then
                            -- check cons.
                            local conLevel = RGMercConfig.Constants.ConColorsNameToId[spawn.ConColor()]
                            if conLevel > self.settings.PullMaxCon or conLevel < self.settings.PullMinCon then
                                doInsert = false
                                RGMercsLogger.log_debug("\ay  - Ignoring mob '%s' due to con color. Min = %d, Max = %d, Mob = %d (%s)", spawn.CleanName(),
                                    self.settings.PullMinCon,
                                    self.settings.PullMaxCon, conLevel, spawn.ConColor())
                            end
                        end

                        if self:HaveList("PullAllowList") then
                            RGMercsLogger.log_debug("\ayHave Allow List to Check!")
                            if self:IsMobInList("PullAllowList", spawn.CleanName(), true) == false then
                                doInsert = false
                            end
                        elseif self:HaveList("PullDenyList") then
                            RGMercsLogger.log_debug("\ayHave Deny List to Check!")
                            if self:IsMobInList("PullDenyList", spawn.CleanName(), false) == true then
                                doInsert = false
                            end
                        else
                            RGMercsLogger.log_debug("\ayNo Allow/Deny List to Check!")
                        end

                        if RGMercUtils.GetSetting('PullMobsInWater') and spawn.FeetWet() then
                            RGMercsLogger.log_debug("\agIgnoring mob in water water: %s", spawn.CleanName())
                            doInsert = false
                        end
                        RGMercsLogger.log_debug("\ayInsert Allowed: %s", doInsert and "\agYes", "\arNo")

                        if doInsert then
                            table.insert(pullTargets, { spawn = spawn, distance = distance, })
                        end
                    else
                        RGMercsLogger.log_debug("\ayPotential Pull %s is OOR --> Distance %d", spawn.CleanName(), distance)
                    end
                end
            end
        end
    end

    table.sort(pullTargets, function(a, b) return a.distance < b.distance end)

    self.TempSettings.PullTargets = pullTargets

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

    if (not self.settings.DoPull and self.TempSettings.TargetSpawnID == 0) or RGMercConfig.Globals.PauseMain then
        RGMercsLogger.log_debug("\ar ALERT: Pulling Disabled at user request. \ax")
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

        if RGMercUtils.GetSetting('SafeTargeting') and RGMercUtils.IsSpawnFightingStranger(spawn, 500) then
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

---@param state number
---@param reason string
function Module:SetPullState(state, reason)
    self.TempSettings.PullState = state
    self.TempSettings.PullStateReason = reason
end

function Module:NavToWaypoint(loc, ignoreAggro)
    -- if DoMed is set it will take care of standing us up
    if mq.TLO.Me.Sitting() then
        RGMercConfig.Globals.InMedState = false
    end

    mq.TLO.Me.Stand()

    RGMercUtils.DoCmd("/nav locyxz %s, log=off", loc)
    mq.delay("2s")

    while mq.TLO.Navigation.Active() do
        RGMercsLogger.log_verbose("NavToWaypoint Aggro Count: %d", RGMercUtils.GetXTHaterCount())

        if RGMercUtils.GetXTHaterCount() > 0 and not ignoreAggro then
            if mq.TLO.Navigation.Active() then
                RGMercUtils.DoCmd("/nav stop log=off")
            end
            return false
        end

        if mq.TLO.Navigation.Velocity() == 0 then
            RGMercsLogger.log_warning("NavToWaypoint Velocity is 0 - Are we stuck?")
            if mq.TLO.Navigation.Paused() then
                RGMercUtils.DoCmd("/nav pause log=off")
            end
        end

        mq.delay(10)
    end

    return true
end

function Module:GetPullAbilityRange()
    if not self.ModuleLoaded then return 0 end
    local pullAbility = self.TempSettings.ValidPullAbilities[self.settings.PullAbility]
    if not pullAbility then return 0 end

    local ret = pullAbility.AbilityRange
    if type(ret) == 'function' then ret = ret() end
    return ret
end

function Module:GetPullStateTargetInfo()
    return string.format("%s(%d) Dist(%d)", RGMercUtils.GetTargetCleanName(), RGMercUtils.GetTargetID(), RGMercUtils.GetTargetDistance())
end

function Module:GiveTime(combat_state)
    self:SetValidPullAbilities()

    if not self.settings.DoPull and self.TempSettings.TargetSpawnID == 0 then return end

    if not mq.TLO.Navigation.MeshLoaded() then
        RGMercsLogger.log_debug("\ar ERROR: There's no mesh for this zone. Can't pull. \ax")
        RGMercsLogger.log_debug("\ar Disabling Pulling. \ax")
        self.settings.DoPull = false
        return
    end

    local campData = RGMercModules:ExecModule("Movement", "GetCampData")

    if self.settings.PullAbility == PullAbilityIDToName.PetPull and (mq.TLO.Me.Pet.ID() or 0) == 0 then
        RGMercUtils.PrintGroupMessage("Need to create a new pet to throw as mob fodder.")
        return
    end

    local shouldPull, reason = self:ShouldPull()
    if not shouldPull then
        if not mq.TLO.Navigation.Active() and combat_state == "Downtime" then
            -- go back to camp.
            self:SetPullState(PullStates.PULL_WAITING_SHOULDPULL, reason)
            if campData.returnToCamp and RGMercUtils.GetDistance(mq.TLO.Me.Y(), mq.TLO.Me.X(), campData.campSettings.AutoCampX, campData.campSettings.AutoCampY) > RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius then
                RGMercUtils.DoCmd("/nav locyxz %0.2f %0.2f %0.2f log=off", campData.campSettings.AutoCampY, campData.campSettings.AutoCampX, campData.campSettings.AutoCampZ)
            end
        end
        return
    end

    if (os.clock() - self.TempSettings.LastPull) < self.settings.PullDelay then return end

    -- GROUPWATCH and NAVINTERRUPT are the two states we can't reset. In the future it may be best to
    -- limit this to only the states we know should be transitionable to the IDLE state.
    if self.TempSettings.PullState ~= PullStates.PULL_GROUPWATCH_WAIT and self.TempSettings.PullState ~= PullStates.PULL_NAV_INTERRUPT then
        self:SetPullState(PullStates.PULL_IDLE, "")
    end

    self.TempSettings.LastPull = os.clock()

    if self.settings.GroupWatch == 2 then
        local groupReady, groupReason = self:CheckGroupForPull(Set.new({ "CLR", "DRU", "SHM", }), self.settings.GroupWatchStartPct, self.settings.GroupWatchStopPct,
            campData.campSettings, campData.returnToCamp)
        if not groupReady then
            self:SetPullState(PullStates.PULL_GROUPWATCH_WAIT, groupReason)
            return
        end
    elseif self.settings.GroupWatch == 3 then
        local groupReady, groupReason = self:CheckGroupForPull(nil, self.settings.GroupWatchStartPct, self.settings.GroupWatchStopPct, campData.campSettings, campData.returnToCamp)
        if not groupReady then
            self:SetPullState(PullStates.PULL_GROUPWATCH_WAIT, groupReason)
            return
        end
    end

    self:SetPullState(PullStates.PULL_IDLE, "")

    -- We're ready to pull, but first, check if we're in farm mode and if we were interrupted
    if self:IsPullMode("Farm") then
        local currentWpId = self:GetCurrentWpId()
        if currentWpId == 0 then
            RGMercsLogger.log_error("\arYou do not have a valid WP ID(%d) for this zone(%s::%s) - Aborting!", self.TempSettings.CurrentWP, mq.TLO.Zone.Name(),
                mq.TLO.Zone.ShortName())
            self:SetPullState(PullStates.PULL_IDLE, "")
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

            self:SetPullState(PullStates.PULL_MOVING_TO_WP, string.format("WP Id: %d", currentWpId))
            -- TODO: PreNav Actions
            if not self:NavToWaypoint(self:GetWPById(currentWpId)) then
                self:SetPullState(PullStates.PULL_NAVINTERRUPT, "")
                return
            else
                self:SetPullState(PullStates.PULL_IDLE, "")
            end
            self:SetPullState(PullStates.PULL_IDLE, "")
        end

        -- We're not in an interrupted state if we make it this far -- so
        -- now make sure we have free inventory or not.
        if mq.TLO.Me.FreeInventory() == 0 then self:FarmFullInvActions() end
    end

    self:SetPullState(PullStates.PULL_SCAN, "")

    self.TempSettings.PullID = 0

    if self.TempSettings.TargetSpawnID > 0 then
        local targetSpawn = mq.TLO.Spawn(self.TempSettings.TargetSpawnID)
        if not targetSpawn() or targetSpawn.Dead() or targetSpawn.PctHPs() == 0 then
            RGMercsLogger.log_debug("\arDropping Manual target id %d - it is dead.", self.TempSettings.TargetSpawnID)
            self.TempSettings.TargetSpawnID = 0
        end
    end

    if self.TempSettings.TargetSpawnID > 0 then
        self.TempSettings.PullID = self.TempSettings.TargetSpawnID
    else
        RGMercsLogger.log_debug("Finding Pull Target")
        self.TempSettings.PullID = self:FindTarget()
    end

    if self.TempSettings.PullID == 0 and self:IsPullMode("Farm") then
        -- move to next WP
        self:IncrementWpId()
        -- Here we want to nav to our current waypoint. If we engage an enemy while
        -- we are currently traveling to our waypoint, we need to set our state to
        -- PULL_NAVINTERRUPT so that when Pulling re-engages after combat, we continue
        -- to travel to our next waypoint.

        -- TODO: PreNav()
        --/if (${SubDefined[${Zone.ShortName}_PreNav_${Pull_FarmWPNum}]}) /call ${Zone.ShortName}_PreNav_${Pull_FarmWPNum}

        local wpData = self:GetWPById(self:GetCurrentWpId())
        self:SetPullState(PullStates.PULL_MOVING_TO_WP, string.format("%0.2f, %0.2f, %0.2f", wpData.y, wpData.x, wpData.z))
        if not self:NavToWaypoint(string.format("%0.2f, %0.2f, %0.2f", wpData.y, wpData.x, wpData.z)) then
            self:SetPullState(PullStates.PULL_NAVINTERRUPT, "")
            return
        else
            -- TODO: AtWP()
            --/if (${SubDefined[${Zone.ShortName}_AtWaypoint_${Pull_FarmWPNum}]}) /call ${Zone.ShortName}_AtWaypoint_${Pull_FarmWPNum}
        end

        self:SetPullState(PullStates.PULL_IDLE, "")
        return
    end

    self:SetPullState(PullStates.PULL_IDLE, "")

    if self.TempSettings.PullID == 0 then
        RGMercsLogger.log_debug("\ayNothing to pull - better luck next time")
        return
    end

    local start_x = mq.TLO.Me.X()
    local start_y = mq.TLO.Me.Y()
    local start_z = mq.TLO.Me.Z()

    if campData.returnToCamp then
        RGMercsLogger.log_debug("\ayRTB: Storing Camp info to return to")
        start_x = campData.campSettings.AutoCampX
        start_y = campData.campSettings.AutoCampY
        start_z = campData.campSettings.AutoCampZ
    end

    RGMercsLogger.log_debug("\ayRTB Location: %d %d %d", start_y, start_x, start_z)

    -- if DoMed is set it will take care of standing us up
    if mq.TLO.Me.Sitting() then
        RGMercConfig.Globals.InMedState = false
    end

    mq.TLO.Me.Stand()

    self:SetPullState(PullStates.PULL_NAV_TO_TARGET, string.format("Id: %d", self.TempSettings.PullID))
    RGMercsLogger.log_debug("\ayFound Target: %d - Attempting to Nav", self.TempSettings.PullID)

    local pullAbility = self.TempSettings.ValidPullAbilities[self.settings.PullAbility]
    local startingXTargs = RGMercUtils.GetXTHaterIDs()

    RGMercUtils.DoCmd("/nav id %d distance=%d lineofsight=%s log=off", self.TempSettings.PullID, self:GetPullAbilityRange(), "on")

    mq.delay(1000)

    local abortPull = false

    while mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 do
        RGMercsLogger.log_super_verbose("Pathing to pull id...")
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

        if self:CheckForAbort(self.TempSettings.PullID) then
            abortPull = true
            break
        end

        mq.delay(100)
        mq.doevents()
    end

    mq.delay("2s", function() return not mq.TLO.Me.Moving() end)

    -- TODO: PrePullTarget()

    RGMercUtils.SetTarget(self.TempSettings.PullID)

    if RGMercUtils.GetSetting('SafeTargeting') then
        -- Hard coding 500 units as our radius as it's probably twice our effective spell range.
        if RGMercUtils.IsSpawnFightingStranger(mq.TLO.Spawn(self.TempSettings.PullID), 500) then
            abortPull = true
        end
    end

    if abortPull == false then
        local target = mq.TLO.Target
        self:SetPullState(PullStates.PULL_PULLING, self:GetPullStateTargetInfo())


        if target and target.ID() > 0 then
            RGMercsLogger.log_info("\agPulling %s [%d]", target.CleanName(), target.ID())

            local successFn = function() return RGMercUtils.GetXTHaterCount() > 0 end

            if self:IsPullMode("Chain") then
                successFn = function() return RGMercUtils.GetXTHaterCount() > self.settings.ChainCount end
            end

            if self.settings.PullAbility == PullAbilityIDToName.PetPull then -- PetPull
                RGMercUtils.PetAttack(self.TempSettings.PullID)
                while not successFn() do
                    RGMercsLogger.log_super_verbose("Waiting on pet pull to finish...")
                    startingXTargs = RGMercUtils.GetXTHaterIDs()
                    RGMercUtils.PetAttack(self.TempSettings.PullID)
                    mq.doevents()
                    if self:IsPullMode("Chain") and RGMercUtils.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(self.TempSettings.PullID) then
                        break
                    end
                    mq.delay(10)
                end

                if RGMercUtils.CanUseAA("Companion's Discipline") then
                    RGMercUtils.DoCmd("/squelch /pet ghold on")
                end
                RGMercUtils.DoCmd("/squelch /pet back off")
                mq.delay("1s", function() return (mq.TLO.Pet.PlayerState() or 0) == 0 end)
                RGMercUtils.DoCmd("/squelch /pet follow")
            elseif self.settings.PullAbility == PullAbilityIDToName.Face then -- Face pull
                -- Make sure we're looking straight ahead at our mob and delay
                -- until we're facing them.
                RGMercUtils.DoCmd("/look 0")

                mq.delay("3s", function() return mq.TLO.Me.Heading.ShortName() == target.HeadingTo.ShortName() end)

                -- We will continue to fire arrows until we aggro our target
                while not successFn() do
                    RGMercsLogger.log_super_verbose("Waiting on face pull to finish...")
                    startingXTargs = RGMercUtils.GetXTHaterIDs()
                    mq.doevents()

                    RGMercUtils.DoCmd("/nav id %d distance=%d lineofsight=%s log=off", self.TempSettings.PullID, self:GetPullAbilityRange(), "on")

                    if self:IsPullMode("Chain") and RGMercUtils.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(self.TempSettings.PullID) then
                        break
                    end
                    mq.delay(10)
                end
            elseif self.settings.PullAbility == PullAbilityIDToName.Ranged then -- Ranged pull
                -- Make sure we're looking straight ahead at our mob and delay
                -- until we're facing them.
                RGMercUtils.DoCmd("/look 0")

                mq.delay("3s", function() return mq.TLO.Me.Heading.ShortName() == target.HeadingTo.ShortName() end)

                -- We will continue to fire arrows until we aggro our target
                while not successFn() do
                    RGMercsLogger.log_super_verbose("Waiting on ranged pull to finish... %s", RGMercUtils.BoolToColorString(successFn()))
                    startingXTargs = RGMercUtils.GetXTHaterIDs()
                    RGMercUtils.DoCmd("/ranged %d", self.TempSettings.PullID)
                    mq.doevents()
                    if self:IsPullMode("Chain") and RGMercUtils.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(self.TempSettings.PullID) then
                        break
                    end
                    mq.delay(10)
                end
            else -- AA/Spell/Ability pull
                mq.delay(5)
                while not successFn() do
                    RGMercsLogger.log_super_verbose("Waiting on ability pull to finish...%s", RGMercUtils.BoolToColorString(successFn()))
                    startingXTargs = RGMercUtils.GetXTHaterIDs()
                    RGMercUtils.DoCmd("/target ID %d", self.TempSettings.PullID)
                    mq.doevents()

                    if pullAbility.Type:lower() == "ability" then
                        if mq.TLO.Me.AbilityReady(pullAbility.id)() then
                            local abilityName = pullAbility.AbilityName
                            if type(abilityName) == 'function' then abilityName = abilityName() end
                            RGMercUtils.UseAbility(abilityName)
                        end
                    elseif pullAbility.Type:lower() == "spell" then
                        local abilityName = pullAbility.AbilityName
                        if type(abilityName) == 'function' then abilityName = abilityName() end
                        RGMercUtils.UseSpell(abilityName, self.TempSettings.PullID, false)
                    else
                        RGMercsLogger.log_error("\arInvalid PullAbilityType: %s :: %s", pullAbility.Type, pullAbility.id)
                    end

                    if self:IsPullMode("Chain") and RGMercUtils.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(self.TempSettings.PullID) then
                        break
                    end
                    mq.delay(10)
                end
            end
        end
    else
        RGMercsLogger.log_debug("\arNOTICE:\ax Pull Aborted!")
        RGMercUtils.DoCmd("/nav stop log=off")
        mq.delay("2s", function() return not mq.TLO.Navigation.Active() end)
    end

    if self:IsPullMode("Normal") or self:IsPullMode("Chain") then
        -- Nav back to camp.
        self:SetPullState(PullStates.PULL_RETURN_TO_CAMP, string.format("Camp Loc: %0.2f %0.2f %0.2f", start_y, start_x, start_z))

        RGMercUtils.DoCmd("/nav locyxz %0.2f %0.2f %0.2f log=off", start_y, start_x, start_z)
        mq.delay("5s", function() return mq.TLO.Navigation.Active() end)

        while mq.TLO.Navigation.Active() and (combat_state == "Downtime" or RGMercUtils.GetXTHaterCount() > 0) do
            RGMercsLogger.log_super_verbose("Pathing to camp...")
            if mq.TLO.Me.State():lower() == "feign" or mq.TLO.Me.Sitting() then
                RGMercsLogger.log_debug("Standing up to Engage Target")
                mq.TLO.Me.Stand()
                RGMercUtils.DoCmd("/nav locyxz %0.2f %0.2f %0.2f log=off", start_y, start_x, start_z)
                mq.delay("5s", function() return mq.TLO.Navigation.Active() end)
            end

            if mq.TLO.Navigation.Paused() then
                RGMercUtils.DoCmd("/nav pause")
            end
            mq.doevents()
            mq.delay(10)
        end

        RGMercUtils.DoCmd("/face id %d", self.TempSettings.PullID)

        self:SetPullState(PullStates.PULL_WAITING_ON_MOB, self:GetPullStateTargetInfo())

        -- give the mob 2 mins to get to us.
        local maxPullWait = 1000 * 120 -- 2 mins
        -- wait for the mob to reach us.
        while mq.TLO.Target.ID() == self.TempSettings.PullID and RGMercUtils.GetTargetDistance() > RGMercConfig.SubModuleSettings.Movement.settings.AutoCampRadius and maxPullWait > 0 do
            self:SetPullState(PullStates.PULL_WAITING_ON_MOB, self:GetPullStateTargetInfo())
            mq.delay(100)
            if mq.TLO.Me.Pet.Combat() then
                RGMercUtils.DoCmd("/squelch /pet back off")
                mq.delay("1s", function() return (mq.TLO.Pet.PlayerState() or 0) == 0 end)
                RGMercUtils.DoCmd("/squelch /pet follow")
            end
            maxPullWait = maxPullWait - 100

            if self:CheckForAbort(self.TempSettings.PullID) then
                break
            end
        end
        -- TODO PostPullCampFunc()
    end

    self.TempSettings.TargetSpawnID = 0
    self:SetPullState(PullStates.PULL_IDLE, "")
end

function Module:OnDeath()
    -- Death Handler
    self.settings.DoPull = false
end

function Module:OnZone()
    -- Zone Handler
    self.settings.DoPull = false
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    return PullStatesIDToName[self.TempSettings.PullState]
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = {}, }
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
