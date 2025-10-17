local mq                        = require('mq')
local ImGui                     = require('ImGui')
local Config                    = require('utils.config')
local Logger                    = require('utils.logger')
local Ui                        = require('utils.ui')
local Icons                     = require('mq.ICONS')
local Modules                   = require('utils.modules')
local Comms                     = require('utils.comms')
local Set                       = require("mq.Set")

local OptionsUI                 = { _version = '1.0', _name = "OptionsUI", _author = 'Derple', 'Algar', }
OptionsUI.__index               = OptionsUI
OptionsUI.selectedGroup         = "General"
OptionsUI.HighlightedCategories = Set.new({})
OptionsUI.HighlightedSettings   = Set.new({})
OptionsUI.configFilter          = ""
OptionsUI.lastSortTime          = 0
OptionsUI.lastHighlightTime     = 0
OptionsUI.selectedCharacter     = ""
OptionsUI.lastPeerUpdate        = 0
OptionsUI.bgImg                 = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/options_bg.png")

function OptionsUI.LoadIcon(icon)
    return mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/" .. icon .. ".png")
end

OptionsUI.Groups                = { --- Add a default of the same name for any key that has nothing in its table once these are finished
    {
        Name = "General",
        Description = "General and Misc Settings",
        Icon = Icons.FA_COGS,
        IconImage = OptionsUI.LoadIcon("settingsicon"),
        Headers = {
            { Name = 'Announcements', Categories = { "Announcements", }, },                  -- group announce stuff
            { Name = 'Interface',     Categories = { "Interface", }, },                      -- ui stuff
            { Name = 'Loot(Emu)',     Categories = { "LNS", }, },
            { Name = 'Misc',          Categories = { "Misc", }, },                           -- ??? profit
            { Name = 'Uncategorized', Categories = { "Uncategorized", }, CatchAll = true, }, -- settings from custom configs that don't have proper group/header
        },
    },
    {
        Name = "Movement",
        Description = "Following, Medding, Pulling",
        Icon = Icons.MD_DIRECTIONS_RUN,
        IconImage = OptionsUI.LoadIcon("followicon"),
        Headers = {
            { Name = 'Following',  Categories = { "Chase", "Camp", }, },
            { Name = 'Meditation', Categories = { "Med Rules", "Med Thresholds", }, },
            { Name = 'Drag',       Categories = { "Drag", }, },
            { Name = 'Pulling',    Categories = { "Pull Rules", "Puller Vitals", "Group Vitals", "Distance", "Targets", }, },
        },
    },
    {
        Name = "Combat",
        Description = "Assisting, Positioning",
        Icon = Icons.FA_HEART,
        IconImage = OptionsUI.LoadIcon("swordicon"),
        Headers = {
            { Name = 'Targeting',   Categories = { "Targeting Behavior", "MA Target Selection", }, },          -- Auto engage, med break, stay on target, etc
            { Name = 'Assisting',   Categories = { "Assisting", }, },                                          -- this will include pet and merc percentages/commands
            { Name = 'Positioning', Categories = { "General Positioning", "Tank Positioning", "Archery", }, }, -- stick, face, etc
            { Name = 'Burning',     Categories = { "Burning", }, },
            { Name = 'Tanking',     Categories = { "Tanking", }, },
        },
    },
    {
        Name = "Abilities",
        Description = "Spells, Songs, Discs, AA",
        Icon = Icons.FA_HEART,
        IconImage = OptionsUI.LoadIcon("stafficon"),
        Headers = {
            { Name = 'Common',   Categories = { "Common Rules", "Under the Hood", }, },
            { Name = 'Pet',      Categories = { "Pet Summoning", "Pet Buffs", "Swarm Pets", }, },
            { Name = 'Buffs',    Categories = { "Buff Rules", "Self", "Group", }, },
            { Name = 'Debuffs',  Categories = { "Debuff Rules", "Slow", "Stun", "Resist", "Snare", "Dispel", "Misc Debuffs", }, }, -- Resist i.e, Malo, Tash, druid
            { Name = 'Recovery', Categories = { "General Healing", "Healing Thresholds", "Other Recovery", "Curing", "Rezzing", }, },
            { Name = 'Damage',   Categories = { "Direct", "AE", "Over Time", "Taps", }, },
            { Name = 'Tanking',  Categories = { "Hate Tools", "Defenses", }, },
            { Name = 'Utility',  Categories = { "Hate Reduction", "Emergency", }, },
            { Name = 'Mez',      Categories = { "Mez General", "Mez Targets", }, },
            { Name = 'Charm',    Categories = { "Charm General", "Charm Targets", }, },
        },
    },
    {
        Name = "Items",
        Description = "Clickies, Bandolier Swaps",
        Icon = Icons.MD_RESTAURANT_MENU,
        IconImage = OptionsUI.LoadIcon("itemicon"),
        Headers = {
            { Name = 'Item Summoning', Categories = { "Item Summoning", }, },
            { Name = 'Bandolier',      Categories = { "Bandolier", }, },
            { Name = 'Instruments',    Categories = { "Instruments", }, },
            { Name = 'Clickies',       Categories = { "General Clickies", "Class Config Clickies", "User Clickies", }, },
        },
    },
    {
        Name = "Commands/FAQ",
        Description = "Command List and Frequently Asked Questions",
        Icon = Icons.MD_RESTAURANT_MENU,
        IconImage = OptionsUI.LoadIcon("faqicon"),
        Headers = {
        },
        HiddenOnSearch = function(self)
            return not Modules:ExecModule("FAQ", "SearchMatches", self.configFilter)
        end,

        HeaderRender = function(self)
            return Modules:ExecModule("FAQ", "RenderConfig", self.configFilter)
        end,
    },
    {
        Name = "Contributors",
        Description = "Credits to those who helped",
        Icon = Icons.MD_RESTAURANT_MENU,
        IconImage = OptionsUI.LoadIcon("contribicon"),
        HiddenOnSearch = function(self) return false end,
        Headers = {
        },
        HeaderRender = function(self)
            return Modules:ExecModule("Contributors", "RenderConfig")
        end,
    },
}

OptionsUI.FilteredGroups        = OptionsUI.Groups
OptionsUI.FilteredSettingsByCat = {}

OptionsUI.GroupsNameToIDs       = {}

for id, group in ipairs(OptionsUI.Groups) do
    OptionsUI.GroupsNameToIDs[group.Name] = id
end

OptionsUI.settings       = {}
OptionsUI.SettingNames   = {}
OptionsUI.DefaultConfigs = {}
OptionsUI.FirstRender    = true

local function shallow_copy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

function OptionsUI:ApplySearchFilter()
    self.FilteredGroups        = self.Groups
    self.FilteredSettingsByCat = {}

    self.HighlightedSettings   = Set.new({})
    self.HighlightedCategories = Set.new({})
    local knownCategories      = Set.new({})

    local filter               = self.configFilter:lower()
    local filtered             = {}
    local catchAllHeader       = nil

    -- precalc all known categories so we can add ones that as missing.
    for _, group in ipairs(self.Groups) do
        for _, header in ipairs(group.Headers) do
            for _, category in ipairs(header.Categories) do
                knownCategories:add(category)
                if header.CatchAll then
                    catchAllHeader = header
                end
            end
        end
    end

    local allModuleCategories = Set.new({})
    local allCategories = Config:PeerGetAllModuleSettingCategories(self.selectedCharacter)

    for _, categories in pairs(allCategories or {}) do -- module to categories
        local categoryList = categories:toList() or {}
        for _, category in ipairs(categoryList) do     -- all categories in module
            allModuleCategories:add(category)
        end
    end

    local allModuleCategoriesTable = allModuleCategories:toList()
    for _, category in ipairs(allModuleCategoriesTable) do
        if not knownCategories:contains(category) and catchAllHeader ~= nil then
            Logger.log_warn("\ayOptionsUI: \awAdding missing category '\at%s\aw' to catch-all header.", category)
            table.insert(catchAllHeader.Categories, category)
            knownCategories:add(category)
        end
    end

    for _, group in ipairs(self.Groups) do
        local newGroup = shallow_copy(group)
        newGroup.Headers = {} -- clear headers for rebuilding
        newGroup.Highlighted = false

        for _, header in ipairs(group.Headers) do
            local headerLower = header.Name:lower()
            local headerMatches = headerLower:find(filter, 1, true) ~= nil
            local highlightHeader = false
            local newCategories = {}

            for _, category in ipairs(header.Categories) do
                local categoryLower = category:lower()

                local categoryMatches = categoryLower:find(filter, 1, true) ~= nil

                local settingsForCategory = Config:PeerGetAllSettingsForCategory(self.selectedCharacter, category)

                for _, settingName in ipairs(settingsForCategory or {}) do
                    local settingDefaults         = Config:PeerGetSettingDefaults(self.selectedCharacter, settingName)
                    local settingDisplayNameLower = (settingDefaults.DisplayName or ""):lower()
                    local settingTooltipLower     = (type(settingDefaults.Tooltip) == 'function' and settingDefaults.Tooltip() or (settingDefaults.Tooltip or "")):lower()
                    local customSetting           = (settingDefaults.Type == "Custom")
                    local showAdv                 = Config:GetSetting('ShowAdvancedOpts') or (settingDefaults.ConfigType == nil or settingDefaults.ConfigType:lower() == "normal")

                    if showAdv and not customSetting and (headerMatches or categoryMatches or settingDisplayNameLower:find(filter, 1, true) ~= nil or
                            settingTooltipLower:find(filter, 1, true) ~= nil) then
                        self.FilteredSettingsByCat[category] = self.FilteredSettingsByCat[category] or {}
                        table.insert(self.FilteredSettingsByCat[category], settingName)

                        -- set highlighting
                        if Config:IsModuleHighlighted(Config:PeerGetModuleForSetting(self.selectedCharacter, settingName)) then
                            newGroup.Highlighted = true
                            self.HighlightedSettings:add(settingName)
                            self.HighlightedCategories:add(category)
                            highlightHeader = true
                        end
                    end
                end

                table.sort(self.FilteredSettingsByCat[category] or {}, function(k1, k2)
                    local k1Defaults = Config:PeerGetSettingDefaults(self.selectedCharacter, k1)
                    local k2Defaults = Config:PeerGetSettingDefaults(self.selectedCharacter, k2)
                    if (k1Defaults.Index ~= nil or k2Defaults.Index ~= nil) and (k1Defaults.Index ~= k2Defaults.Index) then
                        return (k1Defaults.Index or 999) < (k2Defaults.Index or 999)
                    end

                    if k1Defaults.Category == k2Defaults.Category then
                        return (k1Defaults.DisplayName or "") < (k2Defaults.DisplayName or "")
                    end

                    return (k1Defaults.Category or "") < (k2Defaults.Category or "")
                end)

                if #(self.FilteredSettingsByCat[category] or {}) > 0 then
                    table.insert(newCategories, category)
                end
            end

            if #newCategories > 0 then
                table.insert(newGroup.Headers, { Name = header.Name, Categories = newCategories, highlighted = highlightHeader, })
            end
        end

        if #(newGroup.Headers or {}) > 0 or (newGroup.HeaderRender and (filter:len() == 0 or not (newGroup.HiddenOnSearch and newGroup.HiddenOnSearch(self) or false))) then
            table.insert(filtered, newGroup)
        end
    end

    self.FilteredGroups = filtered

    OptionsUI.GroupsNameToIDs = {}

    for id, group in ipairs(OptionsUI.FilteredGroups) do
        OptionsUI.GroupsNameToIDs[group.Name] = id
    end

    self.lastSortTime = os.time()
    self.lastHighlightTime = os.time()
end

function OptionsUI:RenderGroupPanel(groupLabel, groupName)
    if ImGui.Selectable(" ##" .. groupLabel, self.selectedGroup == groupName) then
        self.selectedGroup = groupName
    end
    ImGui.SameLine()
    ImGui.Text(groupLabel)
end

function OptionsUI:RenderGroupPanelWithImage(group)
    local selectableHeight = 40
    local iconSize         = 30
    local cursorScreenPos  = ImGui.GetCursorScreenPosVec()
    local textColStyle     = ImGui.GetStyleColorVec4(ImGuiCol.Text)
    local currentStyle     = ImGui.GetStyle()

    local _, pressed       = ImGui.Selectable("##" .. group.Name, self.selectedGroup == group.Name, ImGuiSelectableFlags.None, ImVec2(0, selectableHeight))

    if group.Description and group.Description:len() > 0 then
        Ui.Tooltip(group.Description or "")
    end

    if pressed then
        self.selectedGroup = group.Name
    end

    local draw_list = ImGui.GetWindowDrawList()

    local _, label_y = ImGui.CalcTextSize(group.Name)
    local midLabelY = math.floor((selectableHeight - label_y) / 2) or 0
    local midIconY = math.floor((selectableHeight - iconSize) / 2) or 0

    -- set the text color from the theme
    local labelCol = group.Highlighted
        and IM_COL32(255, 128, 0, 255)

        or IM_COL32(math.floor(textColStyle.x * 255), math.floor(textColStyle.y * 255), math.floor(textColStyle.z * 255), math.floor(textColStyle.w * 255))

    local currentXPos = cursorScreenPos.x + currentStyle.ItemSpacing.x
    -- draw the icon png
    draw_list:AddImage(group.IconImage:GetTextureID(),
        ImVec2(currentXPos, cursorScreenPos.y + midIconY),
        ImVec2(currentXPos + iconSize, cursorScreenPos.y + midIconY + iconSize),
        ImVec2(0, 0), ImVec2(1, 1),
        IM_COL32(255, 255, 255, 255))

    -- move the cursor to the right of the icon
    currentXPos = currentXPos + iconSize + currentStyle.ItemSpacing.x

    -- render the label text
    draw_list:AddText(ImVec2(currentXPos, cursorScreenPos.y + midLabelY), labelCol, group.Name)
end

function OptionsUI:RenderCategorySeperator(category)
    ImGui.PushStyleVar(ImGuiStyleVar.SeparatorTextPadding, ImVec2(15, 15))
    ImGui.PushStyleVar(ImGuiStyleVar.SeparatorTextAlign, ImVec2(0.05, 0.5))

    if self.HighlightedCategories:contains(category) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.5, 0.0, 1.0)
    end

    ImGui.SeparatorText(category)

    if self.HighlightedCategories:contains(category) then
        ImGui.PopStyleColor(1)
    end

    ImGui.PopStyleVar(2)
end

function OptionsUI:RenderOptionsPanel(groupName)
    if self.FilteredGroups[self.GroupsNameToIDs[groupName]] then
        for _, header in ipairs(self.FilteredGroups[self.GroupsNameToIDs[groupName]].Headers or {}) do
            if header.highlighted then
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.5, 0.0, 1.0)
            end

            if ImGui.CollapsingHeader(header.Name) then
                if header.highlighted then
                    ImGui.PopStyleColor(1)
                end
                for _, category in ipairs(header.Categories) do
                    if #Config:PeerGetAllSettingsForCategory(self.selectedCharacter, category) > 0 then
                        -- only draw the seperator if the category name is different from the heading
                        if header.Name ~= category then
                            self:RenderCategorySeperator(category)
                        end
                        -- Render options for this category
                        self:RenderCategorySettings(category)
                    end
                end
            else
                if header.highlighted then
                    ImGui.PopStyleColor(1)
                end
            end
        end

        if self.FilteredGroups[self.GroupsNameToIDs[groupName]].HeaderRender then
            self.FilteredGroups[self.GroupsNameToIDs[groupName]].HeaderRender(self)
        end
    end
end

function OptionsUI:RenderCategorySettings(category)
    local any_pressed         = false
    local new_loadout         = false
    local pressed             = false
    local loadout_change      = false
    local renderWidth         = 300
    local windowWidth         = ImGui.GetWindowWidth()
    local numCols             = math.max(1, math.floor(windowWidth / renderWidth))
    local settingsForCategory = self.FilteredSettingsByCat[category] or {}

    if ImGui.BeginChild("catchild_" .. category, ImVec2(0, 0), bit32.bor(ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.AutoResizeY), ImGuiWindowFlags.None) then
        if ImGui.BeginTable("Options_" .. (category), 2 * numCols, ImGuiTableFlags.Borders) then
            for _ = 1, numCols do
                ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthFixed), 180.0)
                ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
            end

            --ImGui.TableNextRow(ImGuiTableRowFlags.None, 40.0)
            for idx, settingName in ipairs(settingsForCategory or {}) do
                local settingDefaults = Config:PeerGetSettingDefaults(self.selectedCharacter, settingName)

                -- defaults can go away when a different class config is loaded in.
                if settingDefaults then
                    local setting        = Config:PeerGetSetting(self.selectedCharacter, settingName)
                    local id             = "##" .. settingName
                    local settingTooltip = (type(settingDefaults.Tooltip) == 'function' and settingDefaults.Tooltip() or settingDefaults.Tooltip) or ""

                    if settingDefaults.Type ~= "Custom" then
                        --
                        if idx % numCols == 1 then
                            ImGui.TableNextRow(ImGuiTableRowFlags.None, ImGui.GetFrameHeightWithSpacing())
                        end

                        ImGui.TableNextColumn()
                        if self.HighlightedSettings:contains(settingName) then
                            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.5, 0.0, 1.0)
                        end
                        ImGui.Text(string.format("%s", settingDefaults.DisplayName or (string.format("None %d", idx))))
                        if self.HighlightedSettings:contains(settingName) then
                            ImGui.PopStyleColor(1)
                        end
                        local defaultValue = tostring(settingDefaults.Default)
                        if settingDefaults.Type == "Combo" then
                            defaultValue = string.format("%s - %s", settingDefaults.Default, settingDefaults.ComboOptions[settingDefaults.Default])
                        end
                        Ui.Tooltip(string.format("%s\n\n[Variable: %s]\n[Default: %s]",
                            settingTooltip,
                            settingName,
                            tostring(defaultValue)))
                        ImGui.TableNextColumn()
                        local typeOfSetting = type(settingDefaults.Type) == 'string' and settingDefaults.Type or type(setting)
                        if (settingDefaults.Type or ""):find("Array") then
                            typeOfSetting = settingDefaults.Type:sub(7)
                        end

                        if settingDefaults ~= nil then
                            setting, loadout_change, pressed = Ui.RenderOption(
                                typeOfSetting,
                                setting,
                                id,
                                settingDefaults.RequiresLoadoutChange or false,
                                settingDefaults.ComboOptions or settingDefaults.Min, settingDefaults.Max, settingDefaults.Step or 1)
                            new_loadout = new_loadout or loadout_change
                            any_pressed = any_pressed or pressed

                            --  need to update setting here and notify module
                            if pressed then
                                Config:PeerSetSetting(self.selectedCharacter, settingName, setting)

                                if new_loadout and self.selectedCharacter == Comms.GetPeerName() then
                                    Modules:ExecModule("Class", "RescanLoadout")
                                    new_loadout = false
                                end
                            end
                        else
                            ImGui.TextColored(1.0, 0.0, 0.0, 1.0, "Error: Setting not found - " .. settingName)
                        end
                    end
                else
                    ImGui.TableNextColumn()
                    ImGui.Text(string.format("\arError: Setting not found - %s\ax", settingName))
                    ImGui.TableNextColumn()
                    ImGui.Text(string.format("\arError: Setting not found - %s\ax", settingName))
                end
            end
            ImGui.EndTable()
        end
    end
    ImGui.EndChild()
end

function OptionsUI:RenderCurrentTab()
    self:RenderOptionsPanel(self.selectedGroup)
end

function OptionsUI:RenderMainWindow(imgui_style, curState, openGUI)
    local shouldDrawGUI = true

    if self.FirstRender or self.lastSortTime < Config:GetLastModuleRegisteredTime() or self.lastHighlightTime < Config:GetLastHighlightChangeTime() then
        self.selectedCharacter = Comms.GetPeerName()
        self:ApplySearchFilter()
        Logger.log_debug("\ayOptionsUI: \awSettings re-sorted due to new module settings being registered.")
        self.FirstRender = false
    end

    local flags = ImGuiWindowFlags.None

    if Config:GetSetting('MainWindowLocked') then
        flags = bit32.bor(flags, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoResize)
    end

    if Config.TempSettings.ResetOptionsUIPosition then
        ImGui.SetNextWindowPos(ImVec2(100, 100), ImGuiCond.Always)
        Config.TempSettings.ResetOptionsUIPosition = false
    end

    ImGui.SetNextWindowSize(ImVec2(700, 500), ImGuiCond.FirstUseEver)
    ImGui.SetNextWindowSizeConstraints(ImVec2(400, 300), ImVec2(2000, 2000))

    openGUI, shouldDrawGUI = ImGui.Begin(('RGMercs Options%s###rgmercsOptionsUI'):format(Config.Globals.PauseMain and " [Paused]" or ""), openGUI, flags)

    if shouldDrawGUI then
        ImGui.PushID("##RGMercsUI_" .. Config.Globals.CurLoadedChar)
        local _, y = ImGui.GetContentRegionAvail()

        if ImGui.BeginChild("left##RGmercsOptions", math.min(ImGui.GetWindowContentRegionWidth() * .3, 205), y - 1, ImGuiChildFlags.Border) then
            local flags = bit32.bor(ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter, ImGuiTableFlags.ScrollY)
            local textChanged = false
            local inputBoxPosX = ImGui.GetCursorPosX()
            local style = ImGui.GetStyle()
            local searchBarUsableWidth = ImGui.GetWindowContentRegionWidth() - (ImGui.GetFontSize() + style.FramePadding.y + style.WindowPadding.x * 2)

            ImGui.SetNextItemWidth(ImGui.GetWindowContentRegionWidth())
            -- character selecter
            local peerList = Config:GetPeers()
            table.insert(peerList, 1, Comms.GetPeerName())
            local peerListIdx = 1
            for idx, name in ipairs(peerList) do
                if name == self.selectedCharacter then
                    peerListIdx = idx
                    break
                end
            end
            local newPeerIdx, peerChanged = ImGui.Combo("##OptionsUICharSelect", peerListIdx, peerList, #peerList)
            if peerChanged and newPeerIdx >= 1 and newPeerIdx <= #peerList then
                self.selectedCharacter = peerList[newPeerIdx]
                Config:SetRemotePeer(self.selectedCharacter)
                self.lastPeerUpdate = 0
            end

            if Config:GetPeerLastConfigReceivedTime(self.selectedCharacter) > 0 and self.lastPeerUpdate < Config:GetPeerLastConfigReceivedTime(self.selectedCharacter) then
                self:ApplySearchFilter()
                self.lastPeerUpdate = Config:GetPeerLastConfigReceivedTime(self.selectedCharacter)
            end

            ImGui.SetNextItemWidth(searchBarUsableWidth)
            self.configFilter, textChanged = ImGui.InputText("###OptionsUISearchText", self.configFilter)
            if textChanged then
                self:ApplySearchFilter()
            end

            if not ImGui.IsItemActive() and self.configFilter:len() == 0 then
                ImGui.SameLine()
                local curPosX = ImGui.GetCursorPosX()
                ImGui.SetCursorPosX(inputBoxPosX + (style.WindowPadding.x / 2))
                ImGui.TextColored(0.8, 0.8, 0.8, 0.75, "Search All...")
                ImGui.SameLine()
                ImGui.SetCursorPosX(curPosX)
            else
                ImGui.SameLine()
            end

            if ImGui.SmallButton(Icons.MD_CLEAR) then
                self.configFilter = ""
                self:ApplySearchFilter()
            end
            Ui.Tooltip("Clear Search Text")
            local ShowAdvancedOpts = Config:GetSetting('ShowAdvancedOpts')
            local changed = false
            ShowAdvancedOpts, changed = Ui.RenderOptionToggle("show_adv_tog###OptionsUI", "Show Advanced Options", ShowAdvancedOpts)
            if changed then
                Config:SetSetting('ShowAdvancedOpts', ShowAdvancedOpts)
                self:ApplySearchFilter()
            end

            if ImGui.BeginTable('configmenu##RGmercsOptions', 1, flags, 0, 0, 0.0) then
                ImGui.TableNextColumn()
                for _, group in ipairs(self.FilteredGroups) do
                    if group.IconImage then
                        self:RenderGroupPanelWithImage(group)
                    else
                        self:RenderGroupPanel(string.format("%s %s", group.Icon, group.Name), group.Name)
                    end
                    ImGui.TableNextColumn()
                end
                ImGui.EndTable()
            end
        end
        ImGui.EndChild()
        ImGui.SameLine()

        local x, _ = ImGui.GetContentRegionAvail()

        local right_start = ImGui.GetCursorPosVec()
        if ImGui.BeginChild("right##RGmercsOptionsBG", x, y - 1, ImGuiChildFlags.Border) then
            local cr_min       = ImGui.GetWindowContentRegionMinVec()
            local cr_max       = ImGui.GetWindowContentRegionMaxVec()
            local wp           = ImGui.GetCursorScreenPosVec()
            local top_left     = ImVec2(wp.x + cr_min.x, wp.y + cr_min.y)
            local bottom_right = ImVec2(wp.x + cr_max.x, (wp.y + cr_max.y) * 1.25)

            top_left.x         = top_left.x + ImGui.GetScrollX()
            bottom_right.x     = bottom_right.x + ImGui.GetScrollX()
            top_left.y         = top_left.y + ImGui.GetScrollY()
            bottom_right.y     = bottom_right.y + ImGui.GetScrollY()

            local draw_list    = ImGui.GetWindowDrawList()
            draw_list:PushClipRect(top_left, bottom_right, true)
            draw_list:AddImage(self.bgImg:GetTextureID(),
                top_left,
                bottom_right,
                ImVec2(0, 0), ImVec2(1, 1),
                IM_COL32(255, 255, 255, 30))
            draw_list:PopClipRect()
        end
        ImGui.EndChild()

        ImGui.SetCursorPos(right_start)
        if ImGui.BeginChild("right##RGmercsOptions", x, y - 1, ImGuiChildFlags.Border) then
            flags = bit32.bor(ImGuiTableFlags.None, ImGuiTableFlags.None)
            if self.selectedCharacter ~= Comms:GetPeerName() and Config:GetPeerLastConfigReceivedTime(self.selectedCharacter) == 0 then
                ImGui.TextColored(0.2, 0.2, 0.8, 1.0, "Waiting for configuration from " .. self.selectedCharacter .. "...")
            else
                if ImGui.BeginTable('rightpanelTable##RGmercsOptions', 1, flags, 0, 0, 0.0) then
                    ImGui.TableNextColumn()
                    self:RenderCurrentTab()
                    ImGui.EndTable()
                end
            end
        end
        ImGui.EndChild()
        ImGui.PopID()
    end

    ImGui.End()

    return openGUI
end

return OptionsUI
