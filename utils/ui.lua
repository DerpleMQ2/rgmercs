local mq          = require('mq')
local Config      = require('utils.config')
local Globals     = require('utils.globals')
local Modules     = require("utils.modules")
local Logger      = require("utils.logger")
local Core        = require("utils.core")
local Comms       = require("utils.comms")
local Targeting   = require("utils.targeting")
local Icons       = require('mq.ICONS')
local Strings     = require("utils.strings")
local Tables      = require("utils.tables")
local ClassLoader = require('utils.classloader')
local Math        = require('utils.math')
local Set         = require('mq.set')


local animSpellGems     = mq.FindTextureAnimation('A_SpellGems')
local ICON_SIZE         = 20

local Ui                = { _version = '1.0', _name = "Ui", _author = 'Derple', }

Ui.__index              = Ui
Ui.ConfigFilter         = ""
Ui.ShowDownNamed        = false

Ui.TempSettings         = {
    SortedXT = {},
    SortedXTIDToSlot = {},
    SortedXTIDs = Set.new({}),
}

Ui.ModalText            = ""
Ui.ModalTitle           = "##UI Modal"
Ui.ModalPrompt          = ""
Ui.ModalCallbackFn      = nil
Ui.ComboFilterText      = ""

-- Themze support.
Ui.Themez               = nil
Ui.ThemezNames          = {}
Ui.SelectedThemezImport = 1

Ui.LoadThemez           = function()
    local themez, err = loadfile(mq.configDir .. '/MyThemez.lua')
    if err or not themez then
        Logger.log_warn("\ayNo Themez Lua found.")
    else
        Ui.Themez = themez()

        local ThemezNames = {}

        for _, theme in ipairs(Ui.Themez.Theme or {}) do
            table.insert(ThemezNames, theme.Name or "Unnamed Theme")
        end

        Ui.ThemezNames = ThemezNames
    end
end

Ui.LoadThemez()

function Ui.ConvertFromThemez(themeName)
    local newUserTheme = {}
    local themeToImport = Ui.Themez.Theme[themeName]
    if themeToImport then
        for _, color in pairs(themeToImport.Color or {}) do
            table.insert(newUserTheme, {
                element = color.PropertyName,
                color = {
                    x = color.Color[1],
                    y = color.Color[2],
                    z = color.Color[3],
                    w = color.Color[4],
                },
            })
        end
        for _, style in pairs(themeToImport.Style or {}) do
            table.insert(newUserTheme, {
                element = style.PropertyName,
                value = style.Size and style.Size or
                    {
                        x = style.X,
                        y = style.Y,
                    },
            })
        end
    end

    return newUserTheme
end

function Ui.ConvertToThemez(userTheme)
    local newThemezTheme = { Name = string.format("RGMercs Export - %s", os.date("%Y-%m-%d %H:%M:%S")), Color = {}, Style = {}, }

    for _, setting in pairs(userTheme or {}) do
        if setting.color then
            table.insert(newThemezTheme.Color, {
                PropertyName = Ui.ImGuiColorVarNames[setting.element],
                Color = {
                    setting.color.x or 0,
                    setting.color.y or 0,
                    setting.color.z or 0,
                    setting.color.w or 0,
                },
            })
        elseif setting.value then
            if type(setting.value) == 'table' then
                table.insert(newThemezTheme.Style, {
                    PropertyName = Ui.ImGuiStyleVarNames[setting.element],
                    X = setting.value.x or 0,
                    Y = setting.value.y or 0,
                })
            else
                table.insert(newThemezTheme.Style, {
                    PropertyName = Ui.ImGuiStyleVarNames[setting.element],
                    Size = setting.value,
                })
            end
        end
    end

    return newThemezTheme
end

-- Now make a way to save / reload our themes
Ui.MercThemes              = {}
Ui.MercThemeNames          = {}
Ui.SelectedMercThemeImport = 1

Ui.LoadMercThemes          = function()
    local themes, err = loadfile(mq.configDir .. '/rgmercs/themes.lua')
    if err or not themes then
        Logger.log_warn("\ayNo Save RGMercs Themes Lua found.")
    else
        Ui.MercThemes = themes()

        local mercThemeNames = {}

        for name, _ in pairs(Ui.MercThemes or {}) do
            table.insert(mercThemeNames, name or "Unnamed Theme")
        end

        Ui.MercThemeNames = mercThemeNames
    end
end

Ui.LoadMercThemes()

function Ui.SaveThemes()
    mq.pickle(mq.configDir .. '/rgmercs/themes.lua', Ui.MercThemes)
end

-- The built-in ImGui color and style variable names and Ids seem to be out of sync so pulling these directly from C++ and caching them
Ui.ImGuiColorVars     = {}
Ui.ImGuiColorVarNames = {}
Ui.ImGuiColorVarIds   = {}
Ui.ImGuiStyleVars     = {}
Ui.ImGuiStyleVarNames = {}
Ui.ImGuiStyleVarIds   = {}

local preSortedColors = {}
local ImGuiColCount   = 57
for i = 0, ImGuiColCount do
    table.insert(preSortedColors, { Name = ImGui.GetStyleColorName(i), Value = i, })
end

table.sort(preSortedColors, function(a, b) return a.Value < b.Value end)

for _, v in ipairs(preSortedColors) do
    while #Ui.ImGuiColorVars < v.Value do
        table.insert(Ui.ImGuiColorVars, "<Unused>")
    end
    table.insert(Ui.ImGuiColorVars, v.Name)
    Ui.ImGuiColorVarNames[v.Value] = v.Name
    Ui.ImGuiColorVarIds[v.Name] = v.Value
end

local preSortedStyles = {}
for k, v in pairs(getmetatable(ImGuiStyleVar).__index) do
    if k ~= "COUNT" and k ~= 'Alpha' and k ~= 'DisabledAlpha' then
        table.insert(preSortedStyles, { Name = k, Value = v, })
    end
end

table.sort(preSortedStyles, function(a, b) return a.Value < b.Value end)

for _, v in ipairs(preSortedStyles) do
    while #Ui.ImGuiStyleVars < v.Value do
        table.insert(Ui.ImGuiStyleVars, "<Unused>")
    end
    table.insert(Ui.ImGuiStyleVars, v.Name)
    Ui.ImGuiStyleVarNames[v.Value] = v.Name
    Ui.ImGuiStyleVarIds[v.Name] = v.Value
end

function Ui.GetImGuiColorId(e)
    -- check c++ first then the ImGui Lua object
    return type(e) == 'string' and (Ui.ImGuiColorVarIds[e] or ImGuiCol[e] or 0) or e
end

function Ui.GetImGuiStyleId(e)
    return type(e) == 'string' and (Ui.ImGuiStyleVarIds[e] or ImGuiStyleVar[e] or 0) or e
end

--- Renders the assist list._
--- This function is responsible for displaying the list of assist names
--- It does not take any parameters and does not return any values.
function Ui.RenderAssistList()
    if Config:GetSetting('UseAssistList') then
        ImGui.PushStyleColor(ImGuiCol.Button, Globals.Constants.Colors.ConditionPassColor)
    else
        ImGui.PushStyleColor(ImGuiCol.Button, Globals.Constants.Colors.ConditionFailColor)
    end
    ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImVec2(20, 3))

    if ImGui.SmallButton(Config:GetSetting('UseAssistList') and "Use Assist List: Enabled" or "Use Assist List: Disabled") then
        Config:SetSetting('UseAssistList', not Config:GetSetting('UseAssistList'))
    end
    ImGui.PopStyleVar()
    ImGui.PopStyleColor()
    if mq.TLO.Target.ID() > 0 then
        ImGui.SameLine()
        ImGui.PushID("##_small_btn_create_oa")
        if ImGui.SmallButton("Add Target to Assist List") then
            Config:AssistAdd(mq.TLO.Target.DisplayName())
        end
        ImGui.PopID()
    end
    if ImGui.BeginTable("AssistList Names", 5, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.RowBg)) then
        ImGui.TableSetupColumn('ID', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 140.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 40.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthStretch), 150.0)
        ImGui.TableSetupColumn('Controls', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.TableHeadersRow()

        for idx, name in ipairs(Config:GetSetting('AssistList') or {}) do
            local spawn = mq.TLO.Spawn(string.format("PC =%s", name))
            ImGui.TableNextColumn()
            if name == Globals.MainAssist then
                ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, IM_COL32(255, 255, 0, 64))
            end
            ImGui.Text(tostring(idx))
            ImGui.TableNextColumn()
            local _, clicked = ImGui.Selectable(name, false)
            if clicked then
                if spawn and spawn() then
                    mq.TLO.Spawn(spawn.ID()).DoTarget()
                end
            end
            ImGui.TableNextColumn()
            if spawn() and spawn.ID() > 0 then
                ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionPassColor)
                ImGui.Text(tostring(math.ceil(spawn.Distance())))
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                Ui.NavEnabledLoc(spawn.LocYXZ() or "0,0,0")
            else
                ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionFailColor)
                ImGui.Text("0")
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                ImGui.Text("0")
            end
            ImGui.TableNextColumn()
            ImGui.PushID("##_small_btn_delete_oa_" .. tostring(idx))
            if ImGui.SmallButton(Icons.FA_TRASH) then
                Config:AssistDelete(idx)
            end
            ImGui.PopID()
            ImGui.SameLine()
            ImGui.PushID("##_small_btn_up_oa_" .. tostring(idx))
            if idx == 1 then
                ImGui.InvisibleButton(Icons.FA_CHEVRON_UP, ImVec2(22, 1))
            else
                if ImGui.SmallButton(Icons.FA_CHEVRON_UP) then
                    Config:AssistMoveUp(idx)
                end
            end
            ImGui.PopID()
            ImGui.SameLine()
            ImGui.PushID("##_small_btn_dn_oa_" .. tostring(idx))
            if idx == #Config:GetSetting('AssistList') then
                ImGui.InvisibleButton(Icons.FA_CHEVRON_DOWN, ImVec2(22, 1))
            else
                if ImGui.SmallButton(Icons.FA_CHEVRON_DOWN) then
                    Config:AssistMoveDown(idx)
                end
            end
            ImGui.PopID()
        end

        ImGui.EndTable()
    end
end

function Ui.GetClassConfigIDFromName(name)
    for idx, curName in ipairs(Globals.ClassConfigDirs or {}) do
        if curName == name then return idx end
    end

    return 1
end

function Ui.RenderConfigSelector()
    if Globals.ClassConfigDirs ~= nil then
        ImGui.Text("Config Type:")
        ImGui.SameLine()
        ImGui.SetNextItemWidth(200)
        local newConfigDir, changed = ImGui.Combo("##config_type", Ui.GetClassConfigIDFromName(Config:GetSetting('ClassConfigDir')), Globals.ClassConfigDirs,
            #Globals.ClassConfigDirs)
        if changed then
            Config:SetSetting('ClassConfigDir', Globals.ClassConfigDirs[newConfigDir])
            Config:SaveSettings()
            ClassLoader.reloadConfig()
        end
        Ui.Tooltip(
            "Select your current server/environment.\nLive: Official EQ Servers (Live, Test, TLP).\nProject Lazarus, EQ Might, Hidden Forest: Supported EMU servers.\nAlpha, Beta: Configs in testing. Often preferred, with some caveats (see forum sticky).\nCustom: Copies of the above configs that you have edited yourself.")

        ImGui.SameLine()
        if ImGui.SmallButton(Icons.FA_REFRESH .. " Refresh List") then
            Core.ScanConfigDirs()
        end
        Ui.Tooltip("Refreshes the class config directory list.")
    end
end

function Ui.RenderMercsStatus(showPopout)
    if showPopout then
        if ImGui.SmallButton(Icons.MD_OPEN_IN_NEW) then
            Config:SetSetting('PopOutMercsStatus', true)
        end
        Ui.Tooltip("Pop the Mercs Status Panel out into its own window.")
        ImGui.NewLine()
    end

    local Colors = Globals.Constants.Colors
    local ConColorsNameToVec4 = Globals.Constants.ConColorsNameToVec4

    if not Ui.TempSettings.SortedMercs then
        Ui.TempSettings.SortedMercs = {}
    end

    local tableColumns = {
        {
            name = string.format('Name (%d)', #Ui.TempSettings.SortedMercs),
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultSort),
            width = 60.0,
            sort = function(_, a, b)
                return a or "", b or ""
            end,
            render = function(peer, data)
                if data.Data.Zone ~= mq.TLO.Zone.Name() then
                    ImGui.PushStyleColor(ImGuiCol.Text, Colors.ConditionDisabledColor)
                end

                local name, _ = Comms.GetCharAndServerFromPeer(peer)

                ImGui.SmallButton(name or "Unknown")

                if name then
                    if ImGui.IsItemClicked(ImGuiMouseButton.Left) then
                        local peerSpawn = mq.TLO.Spawn("=" .. name)
                        if peerSpawn.ID() > 0 then
                            peerSpawn.DoTarget()
                            if (mq.TLO.Cursor.ID() or 0) > 0 and peerSpawn.Distance() <= 15 then
                                Core.DoCmd("/timed 1 /click left target")
                                Core.DoCmd('/timed 10 /lua parse mq.TLO.Window("TradeWnd").Child("TRDW_Trade_Button").LeftMouseUp()')
                                Comms.SendPeerDoCmd(peer, '/timed 10 /lua parse mq.TLO.Window("TradeWnd").Child("TRDW_Trade_Button").LeftMouseUp()')
                            end
                        end
                    elseif ImGui.IsItemClicked(ImGuiMouseButton.Right) then
                        Comms.SendPeerDoCmd(peer, "/foreground")
                    end
                end
                if data.Data.Zone ~= mq.TLO.Zone.Name() then
                    ImGui.PopStyleColor()
                end
            end,
        },
        {
            name = string.format('Sever'),
            flags = bit32.bor(ImGuiTableColumnFlags.WidthStretch, ImGuiTableColumnFlags.DefaultHide),
            width = 150.0,
            sort = function(_, a, b)
                return a.Data.Server or "", b.Data.Server or ""
            end,
            render = function(peer, data)
                if data.Data.Server ~= mq.TLO.EverQuest.Server() then
                    ImGui.PushStyleColor(ImGuiCol.Text, Colors.ConditionDisabledColor)
                end

                ImGui.Text(data.Data.Server or "Unknown")

                if data.Data.Server ~= mq.TLO.EverQuest.Server() then
                    ImGui.PopStyleColor()
                end
            end,
        },
        {
            name = 'Zone',
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 80.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.Zone or "", data_b.Data.Zone or ""
            end,
            render = function(peer, data)
                if data.Data.ZoneShortName == mq.TLO.Zone.ShortName() then
                    ImGui.PushStyleColor(ImGuiCol.Text, Colors.ConditionPassColor)
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, Colors.ConditionFailColor)
                end

                ImGui.Text(string.format("%s", data.Data.Zone or "None"))

                ImGui.PopStyleColor()
            end,
        },
        {
            name = 'Zone Short Name',
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 80.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.ZoneShortName or "", data_b.Data.ZoneShortName or ""
            end,
            render = function(peer, data)
                if data.Data.ZoneShortName == mq.TLO.Zone.ShortName() then
                    ImGui.PushStyleColor(ImGuiCol.Text, Colors.ConditionPassColor)
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, Colors.ConditionFailColor)
                end

                ImGui.Text(string.format("%s", data.Data.ZoneShortName or "None"))

                ImGui.PopStyleColor()
            end,
        },
        {
            name = 'State',
            flags = ImGuiTableColumnFlags.WidthFixed,
            width = 15.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.State or "", data_b.Data.State or ""
            end,
            render = function(peer, data)
                local stateColor =
                    (data.Data.Burning and (os.time() % 2 == 0 and Colors.BurnFlashColorOne or Colors.BurnFlashColorTwo)) or
                    (data.Data.State == "Paused" and Colors.MainButtonPausedColor) or
                    (data.Data.State == "Combat" and Colors.MainCombatColor) or
                    Colors.MainDowntimeColor

                local stateIcon = (data.Data.Burning and Icons.FA_FIRE) or
                    (data.Data.State == "Paused" and Icons.FA_PAUSE) or
                    (data.Data.State == "Combat" and Icons.MD_GAMEPAD) or Icons.FA_PLAY

                ImGui.PushStyleColor(ImGuiCol.Text, stateColor)
                local _, clicked = ImGui.Selectable(stateIcon, false)
                ImGui.PopStyleColor()
                if clicked then
                    Comms.SendPeerDoCmd(peer, "/rgl %s", data.Data.State == "Paused" and "unpause" or "pause")
                end

                Ui.MultilineTooltipWithColors({
                    { text = "State:",                                           color = Colors.White, },
                    {
                        text = data.Data.State or "None",
                        color = data.Data.State == "Paused" and Colors.MainButtonPausedColor or
                            data.Data.State == "Combat" and Colors.MainCombatColor or
                            Colors.MainDowntimeColor,
                        sameLine = true,
                    },
                    { text = "AutoTarget:",                                      color = Colors.White, },
                    { text = data.Data.AutoTarget or "None",                     color = Colors.LightRed,    sameLine = true, },
                    { text = "Assist:",                                          color = Colors.White, },
                    { text = data.Data.Assist or "None",                         color = Colors.Cyan,        sameLine = true, },
                    { text = "Chase:",                                           color = Colors.White, },
                    { text = data.Data.Chase or "None",                          color = Colors.Cyan,        sameLine = true, },
                    { text = "Level:",                                           color = Colors.White, },
                    { text = tostring(data.Data.Level) or "0",                   color = Colors.Yellow,      sameLine = true, },
                    { text = "Exp:",                                             color = Colors.White, },
                    { text = string.format("%0.2f%%", data.Data.PctExp) or "0%", color = Colors.LightYellow, sameLine = true, },
                    { text = "Unspent AA:",                                      color = Colors.White, },
                    { text = data.Data.UnSpentAA or "None",                      color = Colors.Orange,      sameLine = true, },
                })
            end,

        },

        {
            name = "Level",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 20.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.Level or 0, data_b.Data.Level or 0
            end,
            render = function(peer, data)
                ImGui.Text(string.format("%d", data.Data.Level or 0))
            end,
        },
        {
            name = 'Unspent AA',
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 40.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.UnSpentAA or 0, data_b.Data.UnSpentAA or 0
            end,
            render = function(peer, data)
                ImGui.Text(string.format("%d", data.Data.UnSpentAA or 0))
            end,
        },
        {
            name = 'Pct Exp',
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 40.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.PctExp or 0, data_b.Data.PctExp or 0
            end,
            render = function(peer, data)
                Ui.RenderColoredText(
                    Ui.GetPercentageColor(data.Data.PctExp or 0, { Colors.LightGreen, Colors.Orange, Colors.LightRed, }),
                    data.Data.HPs and "%6.2f%%" or "", data.Data.PctExp or 0)
            end,
        },
        {
            name = 'HP %',
            flags = ImGuiTableColumnFlags.WidthFixed,
            width = 20.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.HPs or 0, data_b.Data.HPs or 0
            end,
            render = function(peer, data)
                Ui.RenderColoredText(
                    Ui.GetPercentageColor(data.Data.HPs or 0, { Colors.LightGreen, Colors.Yellow, Colors.Red, }),
                    data.Data.HPs and "%d%%" or "", math.ceil(data.Data.HPs or 0) or "")
            end,

        },
        {
            name = 'Mana %',
            flags = ImGuiTableColumnFlags.WidthFixed,
            width = 20.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.Mana or 0, data_b.Data.Mana or 0
            end,
            render = function(peer, data)
                Ui.RenderColoredText(
                    Ui.GetPercentageColor(data.Data.Mana or 0, { Colors.Cyan, Colors.LightBlue, Colors.Red, }),
                    data.Data.Mana and "%d%%" or "", math.ceil(data.Data.Mana or 0) or "")
            end,

        },
        {
            name = 'End %',
            flags = ImGuiTableColumnFlags.WidthFixed,
            width = 20.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.Endurance or 0, data_b.Data.Endurance or 0
            end,
            render = function(peer, data)
                Ui.RenderColoredText(
                    Ui.GetPercentageColor(data.Data.Endurance or 0, { Colors.Yellow, Colors.Grey, Colors.Red, }),
                    data.Data.Endurance and "%d%%" or "", math.ceil(data.Data.Endurance or 0) or "")
            end,

        },
        {
            name = "Distance",
            flags = ImGuiTableColumnFlags.WidthFixed,
            width = 40.0,
            sort = function(mercs, a, b)
                local data_a = (mq.TLO.Zone.Name() == mercs[a].Data.Zone and (mq.TLO.Spawn(mercs[a].Data.ID).Distance() or 999) or 999)
                local data_b = (mq.TLO.Zone.Name() == mercs[b].Data.Zone and (mq.TLO.Spawn(mercs[b].Data.ID).Distance() or 999) or 999)

                if data_a == data_b then
                    return a, b
                end

                return data_a, data_b
            end,
            render = function(peer, data)
                local distance = mq.TLO.Zone.Name() == data.Data.Zone and mq.TLO.Spawn(data.Data.ID).Distance() or 999
                local distString = distance == 999 and "" or string.format("%6.2f", distance)
                ImGui.PushStyleColor(ImGuiCol.Text,
                    distance == 999 and Colors.ConditionDisabledColor or
                    distance > 75 and Colors.ConditionFailColor or
                    distance > 35 and Colors.ConditionMidColor or
                    Colors.ConditionPassColor

                )
                ImGui.Text(distString)
                ImGui.PopStyleColor()
            end,
        },
        {
            name = 'Chase',
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 60.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.Chase or "", data_b.Data.Chase or ""
            end,
            render = function(peer, data)
                ImGui.Text(string.format("%s", data.Data.Chase or "None"))
            end,
        },
        {
            name = 'Assist',
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 60.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.Assist or "", data_b.Data.Assist or ""
            end,
            render = function(peer, data)
                ImGui.Text(string.format("%s", data.Data.Assist or "None"))
            end,
        },
        {
            name = 'AutoTarget',
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 120.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.AutoTarget or "", data_b.Data.AutoTarget or ""
            end,
            render = function(peer, data)
                ImGui.Text(string.format("%s", data.Data.AutoTarget or "None"))
            end,
        },
        {
            name = 'Target',
            flags = ImGuiTableColumnFlags.WidthStretch,
            width = 120.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.Target or "", data_b.Data.Target or ""
            end,
            render = function(peer, data)
                ImGui.Text(string.format("%s", data.Data.Target or "None"))
            end,

        },
        {
            name = 'Casting',
            flags = ImGuiTableColumnFlags.WidthStretch,
            width = 120.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.Casting or "", data_b.Data.Casting or ""
            end,
            render = function(peer, data)
                ImGui.Text(string.format("%s", data.Data.Casting or "None"))
            end,

        },
        {
            name = 'Pet',
            flags = ImGuiTableColumnFlags.WidthFixed,
            width = 80.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.PetID or 0, data_b.Data.PetID or 0
            end,
            render = function(peer, data)
                if data.Data.PetID > 0 then
                    ImGui.PushStyleColor(ImGuiCol.Text, (ConColorsNameToVec4[data.Data.PetConColor] or Colors.White))

                    Ui.InvisibleWithButtonText("##pet_btn_" .. tostring(peer), Icons.MD_PETS, ImVec2(ICON_SIZE, ImGui.GetTextLineHeight()),
                        function() Core.DoCmd("/mqtarget id %d", data.Data.PetID) end)

                    ImGui.PopStyleColor()

                    Ui.MultilineTooltipWithColors(
                        {
                            { text = "Name:",                       color = Colors.White, },
                            { text = data.Data.PetName or "None",   color = Colors.LightGreen, sameLine = true, },
                            { text = "Level:",                      color = Colors.White, },
                            { text = data.Data.PetLevel or "None",  color = Colors.LightBlue,  sameLine = true, },
                            { text = "HPs:",                        color = Colors.White, },
                            { text = data.Data.PetHPs or "None",    color = Colors.Cyan,       sameLine = true, },
                            { text = "Target:",                     color = Colors.White, },
                            { text = data.Data.PetTarget or "None", color = Colors.LightRed,   sameLine = true, },
                        })
                end
            end,

        },
        {
            name = 'Pet ID',
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 40.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.PetID or 0, data_b.Data.PetID or 0
            end,
            render = function(peer, data)
                ImGui.Text(data.Data.PetID > 0 and string.format("%d", data.Data.PetID) or "")
            end,
        },
        {
            name = "Pet HPs",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 40.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.PetHPs or 0, data_b.Data.PetHPs or 0
            end,
            render = function(peer, data)
                ImGui.Text(data.Data.PetID > 0 and string.format("%s", data.Data.PetHPs) or "")
            end,
        },
        {
            name = "Pet Level",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 15.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.PetLevel or 0, data_b.Data.PetLevel or 0
            end,
            render = function(peer, data)
                ImGui.Text(data.Data.PetID > 0 and string.format("%d", data.Data.PetLevel) or "")
            end,
        },
        {
            name = "Pet Name",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthStretch, ImGuiTableColumnFlags.DefaultHide),
            width = 80.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.PetName or "", data_b.Data.PetName or ""
            end,
            render = function(peer, data)
                ImGui.Text(data.Data.PetID > 0 and string.format("%s", data.Data.PetName) or "None")
            end,
        },
        {
            name = "Pet Target",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthStretch, ImGuiTableColumnFlags.DefaultHide),
            width = 120.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.PetTarget or "", data_b.Data.PetTarget or ""
            end,
            render = function(peer, data)
                ImGui.Text(data.Data.PetID > 0 and string.format("%s", data.Data.PetTarget or "None") or "")
            end,
        },
        {
            name = 'Last Update',
            flags = ImGuiTableColumnFlags.WidthFixed,
            width = 15.0,
            sort = function(mercs, a, b)
                local data_a = mercs[a]
                local data_b = mercs[b]
                return data_a.Data.LastUpdate or 0, data_b.Data.LastUpdate or 0
            end,
            render = function(peer, data)
                ImGui.Text(string.format("%ds", os.time() - (data.LastHeartbeat or 0)))
            end,

        },
    }

    Ui.RenderTableData("MercStatusTable", tableColumns,
        bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable, ImGuiTableFlags.RowBg, ImGuiTableFlags.Sortable, ImGuiTableFlags.Hideable, ImGuiTableFlags.Reorderable),
        function(sort_specs)
            local mercs = Comms.GetAllPeerHeartbeats(true)

            if #Ui.TempSettings.SortedMercs ~= Tables.GetTableSize(mercs) then
                Ui.TempSettings.SortedMercs = {}
                for peer, _ in pairs(mercs) do table.insert(Ui.TempSettings.SortedMercs, peer) end
                if sort_specs then sort_specs.SpecsDirty = true end
            end

            local sortingByDistance = tableColumns[(sort_specs and sort_specs:Specs(1).ColumnIndex or 0) + 1].name == "Distance"
            if sort_specs and sort_specs.SpecsDirty or sortingByDistance then
                table.sort(Ui.TempSettings.SortedMercs, function(a, b)
                    local spec = sort_specs:Specs(1) -- single-column sort

                    local av, bv = tableColumns[spec.ColumnIndex + 1].sort(mercs, a, b)

                    if spec.SortDirection == ImGuiSortDirection.Ascending then
                        return (av or 0) < (bv or 0)
                    else
                        return (av or 0) > (bv or 0)
                    end
                end)

                sort_specs.SpecsDirty = false
            end
        end,
        function()
            local mercs = Comms.GetAllPeerHeartbeats(true)
            for _, peer in ipairs(Ui.TempSettings.SortedMercs) do
                local data = mercs[peer]
                if data and data.Data then
                    ImGui.PushID(string.format("##table_entry_%s", peer))
                    for _, colData in ipairs(tableColumns) do
                        ImGui.TableNextColumn()
                        colData.render(peer, data)
                    end
                    ImGui.PopID()
                end
            end
        end)
end

function Ui.RenderForceTargetList(showPopout)
    if showPopout then
        if ImGui.SmallButton(Icons.MD_OPEN_IN_NEW) then
            Config:SetSetting('PopOutForceTarget', true)
        end
        Ui.Tooltip("Pop the Force Target list out into its own window.")
        ImGui.NewLine()
    end

    if Config:GetSetting('ShowFTControls') then
        if ImGui.Button("Clear Forced Target", ImGui.GetWindowWidth() * .4, 18) then
            Globals.ForceTargetID = 0
        end
        ImGui.SameLine()

        if ImGui.Button("Clear Ignored Targets", ImGui.GetWindowWidth() * .4, 18) then
            Globals.IgnoredTargetIDs = Set.new({})
        end
    end

    local tableColumns = {
        {
            name = "FT",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed),
            width = 16.0,
            sort = function(a, b)
                return
                    (Globals.ForceTargetID > 0 and (Globals.ForceTargetID == a.ID() and 1 or 0) or 0),
                    (Globals.ForceTargetID > 0 and (Globals.ForceTargetID == b.ID() and 1 or 0) or 0)
            end,
            render = function(xtarg, i)
                local checked = Globals.ForceTargetID > 0 and Globals.ForceTargetID == xtarg.ID()

                if (Targeting.GetAutoTarget().ID() or 0) == xtarg.ID() then
                    ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, Ui.GetConHighlightBySpawn(xtarg))
                end

                ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, ImVec2(0, 0))

                ImGui.Text("[")

                ImGui.SameLine()

                if not checked then
                    ImGui.PushStyleColor(ImGuiCol.Text, IM_COL32(52, 52, 52, 0))
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, IM_COL32(52, 200, math.floor(os.clock() % 2) == 1 and 52 or 200, 255))
                end

                Ui.InvisibleWithButtonText("##ft_btn_" .. tostring(i), Icons.FA_ARROW_RIGHT, ImVec2(ICON_SIZE, ImGui.GetTextLineHeight()),
                    function() if checked then Globals.ForceTargetID = 0 else Globals.ForceTargetID = xtarg.ID() end end)

                ImGui.PopStyleColor(1)

                ImGui.SameLine()
                ImGui.Text("]")
                ImGui.PopStyleVar(1)
            end,
        },
        {
            name = "Ig",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed),
            width = 16.0,
            sort = function(a, b)
                return Globals.IgnoredTargetIDs:contains(a.ID()) and 1 or 0, Globals.IgnoredTargetIDs:contains(b.ID()) and 1 or 0
            end,
            render = function(xtarg, i)
                local checked = Globals.IgnoredTargetIDs:contains(xtarg.ID())
                ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, ImVec2(0, 0))

                ImGui.Text("[")
                if not checked then
                    ImGui.PushStyleColor(ImGuiCol.Text, IM_COL32(52, 52, 52, 0))
                end
                ImGui.SameLine()

                Ui.InvisibleWithButtonText("##ig_btn_" .. tostring(i), Icons.MD_CHECK, ImVec2(ICON_SIZE, ImGui.GetTextLineHeight()),
                    function()
                        if checked then
                            Globals.IgnoredTargetIDs:remove(xtarg.ID())
                        else
                            Globals.IgnoredTargetIDs:add(xtarg.ID())
                        end
                    end)


                if not checked then
                    ImGui.PopStyleColor()
                end
                ImGui.SameLine()
                ImGui.Text("]")
                ImGui.PopStyleVar(1)
            end,
        },
        {
            name = "XT",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 16.0,
            sort = function(a, b)
                return a.Name() and (Ui.TempSettings.SortedXTIDToSlot[a.ID()].Slot or 0) or 0, b.Name() and (Ui.TempSettings.SortedXTIDToSlot[b.ID()].Slot or 0) or 0
            end,
            render = function(xtarg, i)
                ImGui.Text(xtarg.Name() and (Ui.TempSettings.SortedXTIDToSlot[xtarg.ID()].Slot or "") or "")
            end,
        },
        {
            name = "Name",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultSort),
            width = ImGui.GetWindowWidth() - 300,
            sort = function(a, b)
                return a.CleanName() or "None", b.CleanName() or "None"
            end,
            render = function(xtarg, i)
                ImGui.PushStyleColor(ImGuiCol.Text, Ui.GetConColorBySpawn(xtarg))
                ImGui.PushID(string.format("##select_forcetarget_%d", i))
                local _, clicked = ImGui.Selectable(xtarg.CleanName() or "None", false)
                if clicked then
                    local newId = Globals.ForceTargetID == xtarg.ID() and 0 or xtarg.ID()
                    Globals.ForceTargetID = newId
                    Logger.log_debug("Forcing Target to: %s %d", newId == 0 and "None" or xtarg.CleanName(), newId)
                end
                ImGui.PopID()
                ImGui.PopStyleColor(1)
            end,
        },
        {
            name = "HP %",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed),
            width = 80.0,
            sort = function(a, b)
                return math.ceil(a.PctHPs() or 0), math.ceil(b.PctHPs() or 0)
            end,
            render = function(xtarg, _)
                Ui.RenderText(tostring(math.ceil(xtarg.PctHPs() or 0)))
            end,
        },
        {
            name = "Aggro %",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed),
            width = 80.0,
            sort = function(a, b)
                return math.ceil(a.ID() or 0), math.ceil(b.ID() or 0)
            end,
            render = function(xtarg, _)
                Ui.RenderText(tostring(math.ceil(xtarg.ID() or 0)))
            end,
        },
        {
            name = "Distance",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed),
            width = 80.0,
            sort = function(a, b)
                return math.ceil(a.Distance() or 0), math.ceil(b.Distance() or 0)
            end,
            render = function(xtarg, _)
                ImGui.Text(tostring(math.ceil(xtarg.Distance() or 0)))
            end,
        },
        {
            name = "SpawnID",
            flags = bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.DefaultHide),
            width = 80.0,
            sort = function(a, b)
                return a.ID(), b.ID()
            end,
            render = function(xtarg, _)
                ImGui.Text(tostring(math.ceil(xtarg.ID() or 0)))
            end,

        },
    }

    Ui.RenderTableData("XTargs", tableColumns,
        bit32.bor(ImGuiTableFlags.NoBordersInBodyUntilResize, ImGuiTableFlags.Resizable, ImGuiTableFlags.RowBg, ImGuiTableFlags.Sortable, ImGuiTableFlags.Hideable,
            ImGuiTableFlags.Reorderable),
        function(sort_specs)
            if Targeting.CrossDiffXTHaterIDs(Ui.TempSettings.SortedXTIDs:toList(), true) or true then
                Ui.TempSettings.SortedXT = {}
                Ui.TempSettings.SortedXTIDToSlot = {}
                Ui.TempSettings.SortedXTIDs = Targeting.GetXTHaterIDsSet(true)
                local xtCount = mq.TLO.Me.XTarget() or 0
                for i = 1, xtCount do
                    local xtarg = mq.TLO.Me.XTarget(i)
                    if xtarg and xtarg.ID() > 0 and (xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater" or xtarg.ID() == Globals.ForceTargetID) then
                        table.insert(Ui.TempSettings.SortedXT, xtarg)
                        Ui.TempSettings.SortedXTIDToSlot[xtarg.ID()] = { Name = xtarg.CleanName() or "None", Slot = i, ID = xtarg.ID(), }
                    end
                end
                --[[ TEST DATA REMOVE LATER
                table.insert(Ui.TempSettings.SortedXT, mq.TLO.Me)
                table.insert(Ui.TempSettings.SortedXT, mq.TLO.NearestSpawn(2))
                table.insert(Ui.TempSettings.SortedXT, mq.TLO.NearestSpawn(1))
                table.insert(Ui.TempSettings.SortedXT, mq.TLO.NearestSpawn(3))
                Ui.TempSettings.SortedXTIDToSlot[mq.TLO.Me.ID()] = { Name = mq.TLO.Me.CleanName() or "None", Slot = #Ui.TempSettings.SortedXT + 1, ID = mq.TLO.Me.ID(), }
                Ui.TempSettings.SortedXTIDToSlot[mq.TLO.NearestSpawn(2).ID()] = {
                    Name = mq.TLO.NearestSpawn(2).CleanName() or "None",
                    Slot = #Ui.TempSettings.SortedXT + 1,
                    ID =
                        mq.TLO.NearestSpawn(2).ID(),
                }
                Ui.TempSettings.SortedXTIDToSlot[mq.TLO.NearestSpawn(1).ID()] = {
                    Name = mq.TLO.NearestSpawn(1).CleanName() or "None",
                    Slot = #Ui.TempSettings.SortedXT + 1,
                    ID =
                        mq.TLO.NearestSpawn(1).ID(),
                }
                Ui.TempSettings.SortedXTIDToSlot[mq.TLO.NearestSpawn(3).ID()] = {
                    Name = mq.TLO.NearestSpawn(3).CleanName() or "None",
                    Slot = #Ui.TempSettings.SortedXT + 1,
                    ID =
                        mq.TLO.NearestSpawn(3).ID(),
                }
                ]] --
                if sort_specs then sort_specs.SpecsDirty = true end
            end

            if sort_specs and sort_specs.SpecsDirty then
                table.sort(Ui.TempSettings.SortedXT, function(a, b)
                    local spec = sort_specs:Specs(1) -- single-column sort

                    local col = spec.ColumnIndex

                    local av, bv = tableColumns[col + 1].sort(a, b)

                    if spec.SortDirection == ImGuiSortDirection.Ascending then
                        return (av or 0) < (bv or 0)
                    else
                        return (av or 0) > (bv or 0)
                    end
                end)
            end

            sort_specs.SpecsDirty = false
        end,
        function()
            local cellPadding = ImGui.GetStyle().CellPadding
            local windowPadding = ImGui.GetStyle().WindowPadding
            if ImGui.TableSetColumnIndex(0) then
                ImGui.SameLine()
                ImGui.Text("     ")
                Ui.Tooltip("Click here to set forced target.")
            end

            if ImGui.TableSetColumnIndex(1) then
                ImGui.SameLine()
                ImGui.Text("     ")
                Ui.Tooltip("Click here to ignore this target.")
                ImGui.TableNextRow()
            end

            local style = ImGui.GetStyle()
            local scrollbarW = style.ScrollbarSize + style.ItemSpacing.x
            local win_pos = ImGui.GetWindowPosVec()
            local win_min = win_pos
            local win_max = win_pos + ImGui.GetWindowSizeVec()
            local hasScrollbar = ImGui.GetScrollMaxY() > 0
            local effectiveWidth = win_max.x - (hasScrollbar and scrollbarW or 0)

            for i, xtarg in ipairs(Ui.TempSettings.SortedXT) do
                ImGui.PushID(string.format("##xtarg_%d", i))
                if xtarg.ID() > 0 then
                    local checked = Globals.ForceTargetID > 0 and Globals.ForceTargetID == xtarg.ID()
                    ImGui.TableNextRow()

                    local rowStartX, rowStartY
                    for colIdx, colData in ipairs(tableColumns) do
                        ImGui.TableNextColumn()
                        if colIdx == 1 then
                            local screenPosVec = ImGui.GetCursorScreenPosVec()
                            rowStartX = screenPosVec.x
                            rowStartY = screenPosVec.y - cellPadding.y
                        end

                        colData.render(xtarg, i)
                    end

                    if checked and rowStartX then
                        local draw_list = ImGui.GetForegroundDrawList()

                        local min = ImVec2(rowStartX, rowStartY)
                        local max = ImVec2(
                            rowStartX + (ImGui.GetWindowWidth() - ((windowPadding.x * 2))),
                            rowStartY + ImGui.GetTextLineHeight() + (cellPadding.y * 2)

                        )

                        win_max.x = effectiveWidth
                        draw_list:PushClipRect(win_min, win_max, true)
                        draw_list:AddRect(min, max, ImGui.GetColorU32(Globals.Constants.Colors.FTHighlight), 0.0, 0, 1.5)
                        draw_list:PopClipRect()
                    end
                end
                ImGui.PopID()
            end
        end)
end

function Ui.RenderTableData(tableName, tableColumns, tableFlags, sortFn, rowFn)
    if ImGui.BeginTable(tableName, #tableColumns, tableFlags) then
        for id, data in ipairs(tableColumns) do
            ImGui.TableSetupColumn(data.name, data.flags, data.width, id - 1)
        end

        ImGui.TableHeadersRow()

        local sort_specs = ImGui.TableGetSortSpecs()

        sortFn(sort_specs)

        rowFn()

        ImGui.EndTable()
    end
end

--- Renders a table of the named creatures of the current zone.
---
--- This function retrieves and displays the name of the current zone in the game.
---
function Ui.RenderZoneNamed()
    Ui.ShowDownNamed, _ = Ui.RenderOptionToggle("ShowDown", "Show Downed Named", Ui.ShowDownNamed)

    if ImGui.BeginTable("Zone Named", 4, ImGuiTableFlags.None + ImGuiTableFlags.Borders) then
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 250.0)
        ImGui.TableSetupColumn('Up', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthFixed), 160.0)
        ImGui.TableHeadersRow()

        local namedList = Modules:ExecModule("Named", "GetNamedList")
        for _, named in ipairs(namedList) do
            if Ui.ShowDownNamed or (named.Spawn() and named.Spawn.ID() > 0) then
                ImGui.TableNextColumn()
                local _, clicked = ImGui.Selectable(named.Name, false)
                if clicked then
                    if named.Spawn() and named.Spawn.ID() then
                        mq.TLO.Spawn(named.Spawn.ID()).DoTarget()
                    end
                end
                ImGui.TableNextColumn()
                if named.Spawn() and named.Spawn.PctHPs() > 0 then
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionPassColor)
                    ImGui.Text(Icons.FA_SMILE_O)
                    ImGui.PopStyleColor()
                    ImGui.TableNextColumn()
                    ImGui.Text(tostring(math.ceil(named.Distance)))
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionFailColor)
                    ImGui.Text(Icons.FA_FROWN_O)
                    ImGui.PopStyleColor()
                    ImGui.TableNextColumn()
                    ImGui.Text("0")
                end
                ImGui.TableNextColumn()
                Ui.NavEnabledLoc(named.Spawn.LocYXZ() or "0,0,0")
            end
        end

        ImGui.EndTable()
    end
end

--- Draws an inspectable spell icon.
---
--- @param iconID number The ID of the icon to be drawn.
--- @param spell MQSpell The spell data to be used for the icon.
function Ui.DrawInspectableSpellIcon(iconID, spell)
    local cursor_x, cursor_y = ImGui.GetCursorPos()

    animSpellGems:SetTextureCell(iconID or 0)

    ImGui.DrawTextureAnimation(animSpellGems, ICON_SIZE, ICON_SIZE)

    ImGui.SetCursorPos(cursor_x, cursor_y)

    ImGui.PushID(tostring(iconID) .. spell.Name() .. "_invis_btn")
    ImGui.InvisibleButton(spell.Name(), ImVec2(ICON_SIZE, ICON_SIZE),
        bit32.bor(ImGuiButtonFlags.MouseButtonLeft))
    if ImGui.IsItemHovered() and ImGui.IsMouseReleased(ImGuiMouseButton.Left) then
        spell.Inspect()
    end
    ImGui.PopID()
end

--- Renders the loadout table.
---
--- This function takes a loadout table and renders it in a specific format.
---
--- @param loadoutTable table The table containing loadout information to be rendered.
function Ui.RenderLoadoutTable(loadoutTable)
    if ImGui.BeginTable("Spells", 5, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.TableSetupColumn('Icon', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Gem', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Var Name', (ImGuiTableColumnFlags.WidthFixed), 150.0)
        ImGui.TableSetupColumn('Level', ImGuiTableColumnFlags.None)
        ImGui.TableSetupColumn('Rank Name', ImGuiTableColumnFlags.None)
        ImGui.TableHeadersRow()

        for gem, loadoutData in pairs(loadoutTable) do
            ImGui.TableNextColumn()
            Ui.DrawInspectableSpellIcon(loadoutData.spell.SpellIcon(), loadoutData.spell)
            ImGui.TableNextColumn()
            ImGui.Text(tostring(gem))
            ImGui.TableNextColumn()
            ImGui.Text(loadoutData.selectedSpellData.name or "")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(loadoutData.spell.Level()))
            ImGui.TableNextColumn()
            local _, clicked = ImGui.Selectable(loadoutData.spell.RankName())
            if clicked then
                loadoutData.spell.Inspect()
            end
        end

        ImGui.EndTable()
    end
end

--- Renders the rotation table key.
--- This function is responsible for displaying the key for the rotation table.
--- It does not take any parameters and does not return any value.
function Ui.RenderRotationTableKey()
    ImGui.Text("On the previous check, the...")
    if ImGui.BeginTable("Rotation_table_key", 2, ImGuiTableFlags.Borders) then
        ImGui.TableNextColumn()
        ImGui.Text(Icons.MD_CHECK .. ": Rotation Processed (Conditions Met)")

        ImGui.TableNextColumn()
        ImGui.Text(Icons.MD_CLOSE .. ": Rotation was Skipped (Conditions Not Met)")

        ImGui.TableNextColumn()
        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionPassColor)
        ImGui.Text(Icons.FA_SMILE_O .. ": Entry Effect was Active")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionPassColor)
        ImGui.Text(Icons.MD_CHECK .. ": Entry Conditions Passed")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionFailColor)
        ImGui.Text(Icons.FA_EXCLAMATION .. ": Entry Conditions Failed")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.Text(Icons.MD_INFO_OUTLINE .. " Special Note on Conditions " .. Icons.MD_INFO_OUTLINE)
        Ui.Tooltip("The icons above are only updated when the checks are made, and will display the previous results until they are checked again.\n" ..
            "Note that in addition to special entry conditions, some other checks occur that could prevent an action from being used, such as movement, control effects, mana costs, etc.")

        ImGui.EndTable()
    end
end

--- Renders a rotation table for a given name.
---
--- @param name string: The name associated with the rotation table.
--- @param rotationTable table: The table containing rotation data.
--- @param resolvedActionMap table: A map of resolved actions.
--- @param rotationState number|nil: The current state of the rotation.
--- @param showFailed boolean: Flag to indicate whether to show failed actions.
--- @param enabledRotationEntries table: The table containing configuration about this rotation enablement
---
--- @return boolean, table, boolean returns showFailed input and current enablement config table and bool if the enablement changed
function Ui.RenderRotationTable(name, rotationTable, resolvedActionMap, rotationState, showFailed, enabledRotationEntries)
    local enabledRotationEntriesChanged = false
    local showDebugTiming = Config:GetSetting('ShowDebugTiming')

    if ImGui.BeginTable("Rotation_" .. name, showDebugTiming and 7 or 6, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.TableSetupColumn('ID', ImGuiTableColumnFlags.WidthFixed, 20.0)
        ImGui.TableSetupColumn(rotationState > 0 and 'Cur' or '-', ImGuiTableColumnFlags.WidthFixed, 20.0)
        ImGui.TableSetupColumn('Enable', ImGuiTableColumnFlags.WidthFixed, 30.0)
        ImGui.TableSetupColumn('Condition Met', ImGuiTableColumnFlags.WidthFixed, 20.0)
        ImGui.TableSetupColumn('Action', ImGuiTableColumnFlags.WidthFixed, 250.0)
        --- Column 3: header will be manually drawn
        ImGui.TableSetupColumn("", ImGuiTableColumnFlags.None, 250.0);

        if showDebugTiming then
            ImGui.TableSetupColumn('Timing', ImGuiTableColumnFlags.WidthStretch, 250.0)
        end

        ImGui.TableHeadersRow()

        -- Manually draw header cell content for Resolved Action Column
        if ImGui.TableSetColumnIndex(5) then
            ImGui.SameLine()
            ImGui.Text("Resolved Action ")
            ImGui.SameLine()
            ImGui.Text(Icons.MD_INFO_OUTLINE)
            Ui.Tooltip("Click a resolved action to inspect the spell/item/AA effect.")
        end

        for idx, entry in ipairs(rotationTable or {}) do
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            if rotationState > 0 then
                ImGui.TableNextColumn()
                ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionPassColor)
                if idx == rotationState then
                    ImGui.Text(Icons.FA_DOT_CIRCLE_O)
                end
                ImGui.PopStyleColor()
            else
                ImGui.TableNextColumn()
            end
            ImGui.TableNextColumn()
            local changed = false
            enabledRotationEntries[entry.name], changed = Ui.RenderOptionToggle(string.format("tggl_%d", idx), "",
                enabledRotationEntries[entry.name] == nil and true or enabledRotationEntries[entry.name])
            if changed then enabledRotationEntriesChanged = true end
            ImGui.TableNextColumn()
            local pass, active = false, false

            if entry.lastRun then
                pass, active = entry.lastRun.pass, entry.lastRun.active
            end

            if active == true then
                ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionPassColor)
                ImGui.Text(Icons.FA_SMILE_O)
            elseif pass == true then
                ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionPassColor)
                ImGui.Text(Icons.MD_CHECK)
            else
                ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionFailColor)
                ImGui.Text(Icons.FA_EXCLAMATION)
            end
            ImGui.PopStyleColor()
            if entry.tooltip then
                Ui.Tooltip(entry.tooltip)
            end

            ImGui.TableNextColumn()
            if enabledRotationEntries[entry.name] == false then Ui.StrikeThroughText(entry.name) else ImGui.Text(entry.name) end
            ImGui.TableNextColumn()
            local mappedAction = resolvedActionMap[entry.name]
            if mappedAction then
                if entry.type:lower() == "spell" then
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Purple)
                    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, Globals.Constants.Colors.Grey)
                    local rankSpell = mappedAction.RankName
                    local _, clicked = ImGui.Selectable(rankSpell())
                    if clicked then
                        rankSpell.Inspect()
                    end
                    ImGui.PopStyleColor(2)
                    Ui.Tooltip(string.format("Spell: %s (click to inspect)", rankSpell() or "Unknown"))
                elseif entry.type:lower() == "song" then
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Purple)
                    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, Globals.Constants.Colors.Grey)
                    local rankSpell = mappedAction.RankName
                    local _, clicked = ImGui.Selectable(rankSpell())
                    if clicked then
                        rankSpell.Inspect()
                    end
                    ImGui.PopStyleColor(2)
                    Ui.Tooltip(string.format("Song: %s (click to inspect)", rankSpell() or "Unknown"))
                elseif entry.type:lower() == "disc" then
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Purple)
                    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, Globals.Constants.Colors.Grey)
                    local rankSpell = mappedAction.RankName
                    local _, clicked = ImGui.Selectable(rankSpell())
                    if clicked then
                        rankSpell.Inspect()
                    end
                    ImGui.PopStyleColor(2)
                    Ui.Tooltip(string.format("Disc: %s (click to inspect)", rankSpell() or "Unknown"))
                elseif type(mappedAction) == "string" and entry.type:lower() == "item" then
                    local item = mq.TLO.FindItem("=" .. mappedAction)
                    if item() and item.Clicky() then
                        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.LightOrange)
                        ImGui.PushStyleColor(ImGuiCol.HeaderHovered, Globals.Constants.Colors.Grey)
                        local _, clicked = ImGui.Selectable(mappedAction)
                        local clickySpell = item.Clicky.Spell
                        if clickySpell() and clicked then
                            clickySpell.Inspect()
                        end
                        ImGui.PopStyleColor(2)
                        Ui.Tooltip(string.format("Clicky Spell: %s (click to inspect)", clickySpell.Name() or "Unknown"))
                    else
                        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Grey)
                        ImGui.Text(mappedAction)
                        ImGui.PopStyleColor()
                    end
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Grey)
                    ImGui.Text(mappedAction.Name() or mappedAction)
                    ImGui.PopStyleColor()
                end
            else
                if entry.type:lower() == "customfunc" then
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Yellow)
                    ImGui.Text(entry.desc or "Custom Function")
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "spell" then
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Red)
                    ImGui.Text("No Spell Detected")
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "song" then
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Red)
                    ImGui.Text("No Song Detected")
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "disc" then
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Red)
                    ImGui.Text("No Disc Detected")
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "ability" then
                    local abilTrained = mq.TLO.Me.Ability(entry.name)()
                    if abilTrained then
                        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.LightRed)
                        ImGui.Text(entry.name)
                        ImGui.PopStyleColor()
                    else
                        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Red)
                        ImGui.Text("No Ability Detected")
                        ImGui.PopStyleColor()
                    end
                elseif entry.type:lower() == "aa" then
                    local aaPurchased = mq.TLO.Me.AltAbility(entry.name)() ~= nil
                    if aaPurchased then
                        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.LightBlue)
                        ImGui.PushStyleColor(ImGuiCol.HeaderHovered, Globals.Constants.Colors.Grey)
                        local _, clicked = ImGui.Selectable(entry.name)
                        local aaSpell = mq.TLO.Me.AltAbility(entry.name).Spell
                        if aaSpell() and clicked then
                            aaSpell.Inspect()
                        end
                        ImGui.PopStyleColor(2)
                        Ui.Tooltip(string.format("AA Spell: %s (click to inspect)", aaSpell.Name() or "Unknown"))
                    else
                        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Red)
                        ImGui.Text("No AA Detected")
                        ImGui.PopStyleColor()
                    end
                elseif entry.type:lower() == "item" then
                    local item = mq.TLO.FindItem("=" .. entry.name)
                    if item() and item.Clicky() then
                        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Yellow)
                        ImGui.PushStyleColor(ImGuiCol.HeaderHovered, Globals.Constants.Colors.Grey)
                        local _, clicked = ImGui.Selectable(entry.name)
                        local clickySpell = item.Clicky.Spell
                        if clickySpell() and clicked then
                            clickySpell.Inspect()
                        end
                        ImGui.PopStyleColor(2)
                        Ui.Tooltip(string.format("Clicky Spell: %s (click to inspect)", clickySpell.Name() or "Unknown"))
                    else
                        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Red)
                        ImGui.Text("No Item Detected")
                        ImGui.PopStyleColor()
                    end
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Grey)
                    ImGui.Text(entry.name)
                    ImGui.PopStyleColor()
                end
            end

            if Config:GetSetting('ShowDebugTiming') then
                ImGui.TableNextColumn()

                ImGui.Text(string.format("C: %s RC: %s E: %s PF: %s T: %s",
                    Strings.FormatTimeMS((entry.lastCondTimeSpent or 0) * 1000),
                    Strings.FormatTimeMS((entry.lastRotationCondTimeSpent or 0) * 1000),
                    Strings.FormatTimeMS((entry.lastExecTimeSpent or 0) * 1000),
                    Strings.FormatTimeMS((entry.lastFollowTimeSpent or 0) * 1000),
                    Strings.FormatTimeMS((entry.lastTotalTimeSpent or 0) * 1000)))
            end
        end

        ImGui.EndTable()
    end

    return showFailed, enabledRotationEntries, enabledRotationEntriesChanged
end

--[[
    * RenderFancyToggle
    * A toggle button that can be used to switch between two states (on/off) (true/false).
    * It can also display a star or moon shape as the knob.
    * The function takes various parameters to customize its appearance and behavior.
    * The function returns the updated value of the toggle and whether it was clicked.
    * some Flags you can pass in are ImGuiToggleFlags.StarKnob, ImGuiToggleFlags.RightLabel, ImGuiToggleFlags.AnimateKnob
    * The function also supports custom colors for the toggle button and knob.
    * The function can also animate the knob (roatating stars or a rocking moon).
    * The function can also display a label on the right side of the toggle button.
    * The function can also set the size of the toggle button (width, height) or just height and width will be defaulted to height * 2.0
    * The function can also set the number of points for the star knob (default 5).
    ]]
---@param id string Label and Id for the toggle button)
---@param value boolean Current value of the toggle button
---@param size? ImVec2|integer -- ImVec2 Size of the toggle button (width, height) or height value if single number and width will default to height * 2.0
---@param on_color? ImVec4 Color for ON state, or number
---@param off_color? ImVec4 ImVec4 Color for the Toggle when Off
---@param knob_color? ImVec4 ImVec4 Color for the Knob
---@param right_label? boolean if true the label will be on the right side of the toggle instead of the left
---@param pulse_on_hover? boolean if true the knob will pulse when hovered
---@param knob_border? boolean if true the knob will have a black border
---@param center_vertically? boolean if true the toggle will be centered vertically in the frame
---@return boolean value
---@return boolean clicked
function Ui.RenderFancyToggle(id, label, value, size, on_color, off_color, knob_color, right_label, pulse_on_hover, knob_border, center_vertically)
    if not id or value == nil then return false, false end
    -- setup any defaults for mising params
    size = type(size) == 'number' and ImVec2(size * 2, size) or size or ImVec2(32, 16)
    local height = size.y or 16
    local width = size.x or height * 2
    local clicked = false
    local draw_list = ImGui.GetWindowDrawList()
    local pos = ImGui.GetCursorScreenPosVec()

    -- center it in the frame
    if center_vertically then
        pos.y = pos.y + (ImGui.GetFrameHeight() * 0.5) - (height * 0.5)
    end

    on_color = on_color or ImGui.GetStyleColorVec4(ImGuiCol.FrameBgActive)
    off_color = off_color or ImGui.GetStyleColorVec4(ImGuiCol.FrameBg)
    knob_color = knob_color or Globals.Constants.Colors.White -- default white

    if not right_label and label and label:len() > 0 then
        ImGui.Text(label)
        if ImGui.IsItemClicked() then
            value = not value
            clicked = true
        end
        ImGui.SameLine()
        local text_len, _ = ImGui.CalcTextSize(label)
        pos.x = pos.x + text_len + ImGui.GetStyle().ItemSpacing.x
    end

    local radius = height * 0.5

    -- clickable area
    ImGui.InvisibleButton(id, width, height)
    if ImGui.IsItemClicked() then
        value = not value
        clicked = true
    end

    -- detect hovering for applying hover effects
    local is_hovered = ImGui.IsItemHovered()
    local final_knob_col = ImGui.GetColorU32(knob_color)

    if pulse_on_hover and is_hovered then
        local pulse_strength = 0.5 + 0.5 * math.sin(os.clock() * 4)
        if knob_color.x == 1 and knob_color.y == 1 and knob_color.z == 1 then
            -- Special case: white glows warm yellow
            local new_color = ImVec4(
                1,
                math.min(1, 1 - 0.2 * pulse_strength),
                math.min(1, 1 - 0.4 * pulse_strength),
                knob_color.w
            )
            final_knob_col = ImGui.GetColorU32(new_color)
        else
            local new_color = ImVec4(
                math.min(1, knob_color.x + pulse_strength * 0.4),
                math.min(1, knob_color.y + pulse_strength * 0.4),
                math.min(1, knob_color.z + pulse_strength * 0.4),
                knob_color.w
            )
            final_knob_col = ImGui.GetColorU32(new_color)
        end
    end

    local t = value and 1.0 or 0.0
    local knob_x = pos.x + radius + t * (width - height)
    local center = ImVec2(knob_x, pos.y + radius)
    local fill_radius = radius * 0.8

    -- Background
    draw_list:AddRectFilled(
        ImVec2(pos.x, pos.y),
        ImVec2(pos.x + width, pos.y + height),
        ImGui.GetColorU32(value and on_color or off_color),
        height * 0.5
    )

    draw_list:AddCircleFilled(
        center,
        fill_radius,
        final_knob_col,
        0
    )
    -- Draw outline
    if knob_border then
        draw_list:AddCircle(center, fill_radius, ImGui.GetColorU32(0, 0, 0, 1), 32, 2)
    end

    -- Label on the right side of the toggle
    if right_label and label and label ~= "" then
        ImGui.SameLine()
        ImGui.Text(string.format("%s", label))
        if ImGui.IsItemClicked() then
            value = not value
            clicked = true
        end
    end

    return value, clicked
end

--- Renders a toggle option in the UI.
--- @param id string: The unique identifier for the toggle option.
--- @param text string: The display text for the toggle option.
--- @param on boolean: The current state of the toggle option (true for on, false for off).
--- @param center_vertically boolean?: If true, centers the toggle vertically within its frame.
--- @return boolean: state
--- @return boolean: changed
function Ui.RenderOptionToggle(id, text, on, center_vertically)
    return Ui.RenderFancyToggle(id, text, on, ImVec2(26, 14), Globals.Constants.Colors.Green, Globals.Constants.Colors.Red, nil, true, true, true, center_vertically)
end

--- Renders a progress bar.
--- @param pct number The percentage to fill the progress bar (0-100).
--- @param width number The width of the progress bar.
--- @param height number The height of the progress bar.
function Ui.RenderProgressBar(pct, width, height)
    local style = ImGui.GetStyle()
    local start_x, start_y = ImGui.GetCursorPos()
    local text = string.format("%d%%", pct * 100)
    local label_x, _ = ImGui.CalcTextSize(text)
    ImGui.ProgressBar(pct, width, height, "")
    local end_x, end_y = ImGui.GetCursorPos()
    ImGui.SetCursorPos(start_x + ((ImGui.GetWindowWidth() / 2) - (style.ItemSpacing.x + math.floor(label_x / 2))),
        start_y + style.ItemSpacing.y)
    ImGui.Text(text)
    ImGui.SetCursorPos(end_x, end_y)
end

--- Renders a numerical option with a specified range and step.
--- @param id string: The identifier for the option.
--- @param text string: The display text for the option.
--- @param cur number: The current value of the option.
--- @param min number: The minimum value of the option.
--- @param max number: The maximum value of the option.
--- @param step number?: The step value for incrementing/decrementing the option.
--- @return number   # input
--- @return boolean  # changed
function Ui.RenderOptionNumber(id, text, cur, min, max, step)
    ImGui.PushID("##num_spin_" .. id)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, Globals.Constants.Colors.LightGrey)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, Globals.Constants.Colors.Grey)
    ImGui.PushStyleColor(ImGuiCol.Button, Globals.Constants.Colors.Grey)
    ImGui.PushStyleColor(ImGuiCol.FrameBg, Globals.Constants.Colors.Black)
    local input, changed = ImGui.InputInt(text, cur, step, 1, ImGuiInputTextFlags.None)
    ImGui.PopStyleColor(4)
    ImGui.PopID()

    min = min or 0
    max = max or 100

    input = tonumber(input) or 0
    if input > max then input = max end
    if input < min then input = min end

    changed = cur ~= input
    return input, changed
end

function Ui.SearchableCombo(id, curIdx, options, hideText)
    local pressed = false

    if ImGui.BeginCombo("##combo_box" .. id, curIdx .. " : " .. (options[curIdx] or "None")) then
        -- Search box
        if ImGui.IsWindowAppearing() then
            ImGui.SetKeyboardFocusHere()
        end

        Ui.ComboFilterText = ImGui.InputText("##combo_search", Ui.ComboFilterText)

        ImGui.Separator()

        -- List
        for i, item in ipairs(options) do
            if hideText == nil or (item:find(hideText) == nil and (Ui.ComboFilterText == "" or item:lower():find(Ui.ComboFilterText:lower(), 1, true))) then
                if ImGui.Selectable(i .. ": " .. item, i == curIdx) then
                    if curIdx ~= i then
                        curIdx = i
                        pressed = true
                        Ui.ComboFilterText = ""
                        ImGui.CloseCurrentPopup()
                    end
                end
            end
        end
        ImGui.EndCombo()
    end

    return curIdx, pressed
end

function Ui.RenderOption(type, setting, id, requiresLoadoutChange, ...)
    local args = { ..., }
    local new_loadout, any_pressed, pressed = false, false, false
    if type == "Combo" then
        -- build a combo box.
        ImGui.PushID("##combo_setting_" .. id)
        ---@type string[]
        local comboOptions = args[1]
        local hideText = args[2]
        ImGui.SetNextItemWidth(-1)
        --setting, pressed = ImGui.Combo("", setting, comboOptions)
        setting, pressed = Ui.SearchableCombo(id, setting, comboOptions, hideText)
        ImGui.PopID()
        new_loadout = ((pressed or false) and (requiresLoadoutChange))
        any_pressed = any_pressed or (pressed or false)
    elseif type == "ClickyItem" or type == "ClickyItemWithConditions" then
        -- make a drag and drop target
        ImGui.PushFont(ImGui.ConsoleFont)
        local displayCharCount = 11
        local itemName = type == "ClickyItemWithConditions" and setting.itemName or setting
        local nameLen = itemName:len()
        local maxStart = (nameLen - displayCharCount) + 1
        local startDisp = maxStart > 0 and (os.clock() % maxStart) + 1 or 0

        ImGui.PushID(id .. "__btn")
        if ImGui.SmallButton(nameLen > 0 and itemName:sub(startDisp, (startDisp + displayCharCount - 1)) or "[Drop Here]") then
            if mq.TLO.Cursor() then
                if type == "ClickyItemWithConditions" then
                    setting.itemName = mq.TLO.Cursor.Name()
                else
                    setting = mq.TLO.Cursor.Name()
                end

                pressed = true
            end
        end
        ImGui.PopID()

        ImGui.PopFont()
        if nameLen > 0 then
            Ui.Tooltip(itemName)
        end

        ImGui.SameLine()
        ImGui.PushID(id .. "__clear_btn")
        if ImGui.SmallButton(Icons.MD_CLEAR) then
            if type == "ClickyItemWithConditions" then
                setting.itemName = ""
            else
                setting = ""
            end
            pressed = true
        end
        ImGui.PopID()
        Ui.Tooltip(string.format("Drop a new item here to replace\n%s", itemName))

        new_loadout = new_loadout or
            ((pressed or false) and (requiresLoadoutChange))
        any_pressed = any_pressed or (pressed or false)
    elseif type == 'Color' then
        local skipDefaultButton = args[1] or false
        ImGui.PushID("##color_setting_" .. id)
        ImGui.SetNextItemWidth(-1)
        local newSetting
        newSetting, pressed = ImGui.ColorEdit4("", Tables.TableToImVec4(setting) or ImVec4(0, 0, 0, 0), ImGuiColorEditFlags.NoInputs + ImGuiColorEditFlags.NoLabel)
        setting = newSetting and Tables.ImVec4ToTable(newSetting) or setting
        if not skipDefaultButton then
            ImGui.SameLine()
            if ImGui.SmallButton("Default##reset_color_" .. id) then
                setting = Tables.ImVec4ToTable(Globals.Constants.DefaultColors[id])
                pressed = true
            end
        else

        end
        ImGui.PopID()
        new_loadout = new_loadout or (pressed and (requiresLoadoutChange))
        any_pressed = any_pressed or pressed
    elseif type == 'ImVec2' then
        ImGui.PushID("##vec2_setting_" .. id)
        local intArray = { setting.x or 0, setting.y or 0, }
        local newSetting
        newSetting, pressed = ImGui.InputInt2("", intArray)
        setting = newSetting and { x = newSetting[1], y = newSetting[2], } or setting
        ImGui.PopID()
        new_loadout = new_loadout or (pressed and (requiresLoadoutChange))
        any_pressed = any_pressed or pressed
    elseif type == 'boolean' then
        setting, pressed = Ui.RenderOptionToggle(id, "", setting, true)
        new_loadout = new_loadout or (pressed and (requiresLoadoutChange))
        any_pressed = any_pressed or pressed
    elseif type == 'number' then
        setting, pressed = Ui.RenderOptionNumber(id, "", setting, args[1], args[2], args[3])
        new_loadout = new_loadout or (pressed and (requiresLoadoutChange))
        any_pressed = any_pressed or pressed
    elseif type == 'string' then -- display only
        ImGui.SetNextItemWidth(-1)
        setting, pressed = ImGui.InputText("##" .. id, setting)
        any_pressed = any_pressed or pressed
        Ui.Tooltip(setting)
    end

    return setting, new_loadout, any_pressed
end

function Ui.RenderSettingsButton(moduleName)
    if ImGui.SmallButton(Icons.MD_SETTINGS) then
        Config:OpenOptionsUIAndHighlightModule(moduleName)
    end
    Ui.Tooltip(string.format("Open the RGMercs Options with %s settings highlighted.", moduleName))
end

function Ui.RenderPopAndSettings(moduleName)
    -- The size wont change so I don't want to use CalcTextSize every frame
    local style = ImGui.GetStyle()
    local paddingNeeded = 35 + style.FramePadding.x
    local cursorPos = ImGui.GetCursorPosVec()
    if Config:HaveSetting(moduleName .. "_Popped") then
        if not Config:GetSetting(moduleName .. "_Popped") then
            paddingNeeded = paddingNeeded + style.ItemSpacing.x + 35
            ImGui.SetCursorPos(ImVec2(cursorPos.x + (ImGui.GetWindowWidth() - paddingNeeded), cursorPos.y))
            Ui.RenderSettingsButton(moduleName)
            ImGui.SameLine()
            if ImGui.SmallButton(Icons.MD_OPEN_IN_NEW) then
                Config:SetSetting(moduleName .. "_Popped", not Config:GetSetting(moduleName .. "_Popped"))
                Config:GetSetting('EnableOptionsUI')
            end
            Ui.Tooltip(string.format("Pop the %s tab out into its own window.", moduleName))
            ImGui.NewLine()
        else
            ImGui.SetCursorPos(ImVec2(cursorPos.x + (ImGui.GetWindowWidth() - paddingNeeded), cursorPos.y))

            Ui.RenderSettingsButton(moduleName)
        end
        ImGui.SetCursorPos(cursorPos)
    else
        ImGui.SetCursorPos(ImVec2(cursorPos.x + (ImGui.GetWindowWidth() - paddingNeeded), cursorPos.y))
        Ui.RenderSettingsButton(moduleName)
    end

    return paddingNeeded
end

function Ui.RenderThemeConfigElement(id, themeElement)
    local setting = themeElement.element
    local any_pressed, delete_pressed = false, false

    if themeElement.color ~= nil then
        ---@diagnostic disable-next-line: cast-local-type
        local settingNum, _, pressed = Ui.RenderOption("Combo", Ui.GetImGuiColorId(setting) + 1, id, false, Ui.ImGuiColorVars, "<Unused>")
        any_pressed = any_pressed or (pressed or false)

        ImGui.TableNextColumn()

        local settingColor, _, pressed = Ui.RenderOption("Color", themeElement.color, id .. "_color", false, true)
        any_pressed = any_pressed or (pressed or false)

        if any_pressed then
            local userConfig = Config:GetSetting('UserTheme')
            userConfig[id].element = ImGui.GetStyleColorName((tonumber(settingNum) or 1) - 1)
            userConfig[id].color = settingColor
            Config:SetSetting('UserTheme', userConfig)
        end
    else
        ---@diagnostic disable-next-line: cast-local-type
        local settingNum, _, pressed = Ui.RenderOption("Combo", Ui.GetImGuiStyleId(setting) + 1, id, false, Ui.ImGuiStyleVars, "<Unused>")
        any_pressed = any_pressed or (pressed or false)

        ImGui.TableNextColumn()

        -- if we changed the style var, we need to reset the value to default
        if pressed then
            local currentValue = ImGui.GetStyle()[Ui.ImGuiStyleVarNames[(tonumber(settingNum) or 1) - 1]]
            themeElement.value = type(currentValue) == 'number' and currentValue or Tables.ImVec2ToTable(currentValue)
        end

        local settingStyle, _, pressed = Ui.RenderOption(type(themeElement.value) == 'number' and 'number' or 'ImVec2', themeElement.value, id .. "_style")
        any_pressed = any_pressed or (pressed or false)
        if any_pressed then
            local userConfig = Config:GetSetting('UserTheme')
            userConfig[id].element = Ui.ImGuiStyleVarNames[(tonumber(settingNum) or 1) - 1]
            userConfig[id].value = settingStyle
            Config:SetSetting('UserTheme', userConfig)
        end
    end

    ImGui.SameLine()
    if ImGui.SmallButton(Icons.MD_DELETE .. "##delete_" .. id) then
        local userConfig = Config:GetSetting('UserTheme')
        table.remove(userConfig, id)
        Config:SetSetting('UserTheme', userConfig)
    end

    return any_pressed, delete_pressed
end

function Ui.RenderImportThemez()
    if Ui.Themez == nil then
        return
    end

    ImGui.BeginChild("##themez_importer_child", ImVec2(0, 0), bit32.bor(ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.AutoResizeY, ImGuiChildFlags.Border),
        ImGuiWindowFlags.None)
    ImGui.Text("Import from Themez: ")
    ImGui.SameLine()
    Ui.SelectedThemezImport, _ = Ui.SearchableCombo("import_themez", Ui.SelectedThemezImport, Ui.ThemezNames)
    ImGui.SameLine()
    if ImGui.SmallButton("Import") then
        local newUserTheme = Ui.ConvertFromThemez(Ui.SelectedThemezImport or "Default")

        Config:SetSetting('UserTheme', newUserTheme)
    end

    ImGui.SameLine()
    if ImGui.SmallButton(Icons.FA_REFRESH) then
        Ui.LoadThemez()
    end
    Ui.Tooltip("Reload MyThemeZ.lua")

    ImGui.EndChild()
end

function Ui.OpenModal(title, prompt, initText, callbackFn)
    Ui.ModalCallbackFn = callbackFn
    Ui.ModalText       = initText
    Ui.ModalPrompt     = prompt or ""
    Ui.ModalTitle      = title or Ui.ModalTitle
    ImGui.OpenPopup(Ui.ModalTitle)
end

function Ui.RenderPopupModal()
    ImGui.SetNextWindowSize(320, 0, ImGuiCond.Appearing)
    if ImGui.BeginPopupModal(Ui.ModalTitle, nil, bit32.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.AlwaysAutoResize)) then
        ImGui.Text("Theme Name:")
        ImGui.Spacing()

        -- Auto-focus input on open
        if ImGui.IsWindowAppearing() then
            ImGui.SetKeyboardFocusHere()
        end

        -- Input field
        local pressed = false
        Ui.ModalText, pressed = ImGui.InputText("##UiPopupModalInput", Ui.ModalText, bit32.bor(ImGuiInputTextFlags.EnterReturnsTrue))

        ImGui.Separator()

        -- Buttons
        if ImGui.Button("Ok") or pressed then
            if Ui.ModalCallbackFn then
                Ui.ModalCallbackFn(Ui.ModalText)
            end
            Ui.ModalCallbackFn = nil
            ImGui.CloseCurrentPopup()
        end

        ImGui.SameLine()

        if ImGui.Button("Cancel") then
            ImGui.CloseCurrentPopup()
            Ui.ModalCallbackFn = nil
            Ui.ModalText = ""
        end

        ImGui.EndPopup()
    end
end

function Ui.RenderImportMercThemes()
    ImGui.BeginChild("##mercs_themes_importer_child", ImVec2(0, 0), bit32.bor(ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.AutoResizeY, ImGuiChildFlags.Border),
        ImGuiWindowFlags.None)
    ImGui.Text("Import from File: ")
    ImGui.SameLine()
    Ui.SelectedMercThemeImport, _ = Ui.SearchableCombo("import_merc_themes", Ui.SelectedMercThemeImport, Ui.MercThemeNames)
    ImGui.SameLine()
    if ImGui.SmallButton("Load") then
        local newUserTheme = Ui.MercThemes[Ui.MercThemeNames[Ui.SelectedMercThemeImport] or "Default"]

        Config:SetSetting('UserTheme', newUserTheme)
    end

    ImGui.SameLine()
    if ImGui.SmallButton("Save") then
        Ui.OpenModal("Save Theme", "Theme Name:", string.format("Exported Theme: %s", os.date("%Y-%m-%d %H:%M:%S")), function(themeName)
            local userTheme = Config:GetSetting('UserTheme')
            if userTheme then
                --local themeName = string.format("Saved %s", os.date("%Y-%m-%d %H:%M:%S"))
                Ui.MercThemes[themeName] = userTheme
                Logger.log_debug("Saved current UserTheme to Themez as '%s'", themeName)
                Ui.SaveThemes()
                Ui.LoadMercThemes()
            else
                Logger.log_error("Failed to save current UserTheme to Themez.")
            end
        end)
    end
    Ui.Tooltip("Save current theme")

    Ui.RenderPopupModal()

    ImGui.SameLine()
    if ImGui.SmallButton(Icons.FA_REFRESH) then
        Ui.LoadMercThemes()
    end
    Ui.Tooltip("Reload themes file")

    ImGui.EndChild()
end

function Ui.RenderThemeConfig(searchFilter)
    local renderWidth = 325
    local windowWidth = ImGui.GetWindowWidth()
    local numCols     = math.max(1, math.floor(windowWidth / renderWidth))
    local category    = "UserTheme"

    if not Ui.ThemeConfigMatchesFilter(searchFilter) then
        return
    end

    local overrideClass, changed = Ui.RenderOptionToggle("OverrideClassTheme", "Override Class Theme Colors", Config:GetSetting('UserThemeOverrideClassTheme'), true)

    if changed then
        Config:SetSetting('UserThemeOverrideClassTheme', overrideClass)
    end

    ImGui.NewLine()

    ImGui.SeparatorText("Importers & Generators")

    if ImGui.SmallButton("Reset Theme to Default") then
        Config:SetSetting('UserTheme', {})
    end
    ImGui.SameLine()
    if ImGui.SmallButton("Import Current Class Theme") then
        local userTheme = Tables.DeepCopy(Modules:ExecModule("Class", "GetTheme") or {})
        for _, element in ipairs(userTheme) do
            if element.element ~= nil then
                local newElementName = element.color ~= nil and Ui.GetImGuiColorId(element.element) or Ui.GetImGuiStyleId(element.element)
                if newElementName ~= nil then
                    element.element = newElementName
                end
                if element.color and element.color.r ~= nil then
                    element.color = Tables.TableRGBAToXYZW(element.color)
                end
            end
        end
        Config:SetSetting('UserTheme', userTheme)
    end
    ImGui.SameLine()
    if ImGui.SmallButton("Randomize Theme") then
        local randomTheme = {}
        for _, v in ipairs(Ui.ImGuiColorVars) do
            if v:len() > 0 then
                table.insert(randomTheme, { element = v, color = { x = math.random(), y = math.random(), z = math.random(), w = 1.0, }, })
            end
        end
        Logger.log_debug("Generated a random theme with %d colors", #randomTheme)
        Config:SetSetting('UserTheme', randomTheme)
    end
    Ui.Tooltip("Randomizes all colors in the theme. Warning: May be hard to read!")

    ImGui.NewLine()

    Ui.RenderImportMercThemes()

    ImGui.NewLine()

    Ui.RenderImportThemez()

    ImGui.NewLine()

    ImGui.SeparatorText("Theme Customization")

    if ImGui.SmallButton("Add New Color") then
        Config:SetSetting('UserTheme', table.insert(Config:GetSetting('UserTheme') or {}, {
            element = "Text",
            color = { x = 1, y = 1, z = 1, w = 1, },
        }))
    end

    ImGui.SameLine()

    if ImGui.SmallButton("Add New Style") then
        Config:SetSetting('UserTheme', table.insert(Config:GetSetting('UserTheme') or {}, {
            element = 'WindowPadding',
            value = Tables.ImVec2ToTable(ImGui.GetStyle().WindowPadding),
        }))
    end

    local userTheme = Tables.DeepCopy(Config:GetSetting('UserTheme') or {})

    ImGui.SeparatorText("Colors")
    if ImGui.BeginChild("themechild_colors_" .. category, ImVec2(0, 0), bit32.bor(ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.AutoResizeY), ImGuiWindowFlags.None) then
        if ImGui.BeginTable("themelements_" .. (category), 2 * numCols, ImGuiTableFlags.Borders) then
            for _ = 1, numCols do
                ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthFixed), 180.0)
                ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
            end

            for idx, themeElement in ipairs(userTheme) do
                if themeElement.color ~= nil then
                    ImGui.TableNextColumn()
                    Ui.RenderThemeConfigElement(idx, themeElement)
                end
            end

            ImGui.EndTable()
        end
        ImGui.EndChild()
    end

    ImGui.SeparatorText("Styles")
    if ImGui.BeginChild("themechild_styles_" .. category, ImVec2(0, 0), bit32.bor(ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.AutoResizeY), ImGuiWindowFlags.None) then
        if ImGui.BeginTable("themelements_" .. (category), 2 * numCols, ImGuiTableFlags.Borders) then
            for _ = 1, numCols do
                ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthFixed), 180.0)
                ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
            end

            for idx, themeElement in ipairs(userTheme) do
                if themeElement.color == nil then
                    ImGui.TableNextColumn()
                    Ui.RenderThemeConfigElement(idx, themeElement)
                end
            end

            ImGui.EndTable()
        end
        ImGui.EndChild()
    end
end

function Ui.ThemeConfigMatchesFilter(searchFilter)
    return (searchFilter or ""):len() == 0 or string.find("theme", searchFilter, 1, true) ~= nil
end

function Ui.RenderLogo(textureId)
    local afConfig = Config:GetSetting('EnableAFUI')
    local draw = ImGui.GetWindowDrawList()

    local mx, my = ImGui.GetMousePos()
    local cx, cy = ImGui.GetCursorScreenPos()
    local w, h = 60, 60

    local x1, y1 = 0, 0
    local x2, y2 = w, 0
    local x3, y3 = w, h
    local x4, y4 = 0, h

    ImGui.Dummy(ImVec2(60, 60))

    if afConfig then
        local t = Ui.TempSettings.LogoMOTime and (mq.gettime() / 100 - Ui.TempSettings.LogoMOTime) or 0
        t = t % 120
        local delta
        if t <= 59 then
            delta = -t
        else
            delta = -(119 - t)
        end
        cx, cy = cx + w * 0.5, cy + h * 0.5
        local angle = math.atan2(my - cy, mx - cx)

        w, h = math.max(1, w + delta), math.max(1, h + delta)
        local hw, hh = w * 0.5, h * 0.5

        x1, y1 = Math.Rotate(angle, -hw, -hh)
        x2, y2 = Math.Rotate(angle, hw, -hh)
        x3, y3 = Math.Rotate(angle, hw, hh)
        x4, y4 = Math.Rotate(angle, -hw, hh)

        if ImGui.IsItemHovered() then
            if not Ui.TempSettings.LogoMOTime then
                Ui.TempSettings.LogoMOTime = mq.gettime() / 100
            end
        else
            Ui.TempSettings.LogoMOTime = nil
        end
    end

    draw:AddImageQuad(
        textureId,
        ImVec2(cx + x1, cy + y1),
        ImVec2(cx + x2, cy + y2),
        ImVec2(cx + x3, cy + y3),
        ImVec2(cx + x4, cy + y4),
        ImVec2(0, 0),
        ImVec2(1, 0),
        ImVec2(1, 1),
        ImVec2(0, 1)
    )
end

function Ui.RenderText(text, ...)
    local formattedText = string.format(text, ...)
    local afConfig = Config:GetSetting('EnableAFUI')
    local textSizeX, textSizeY = ImGui.CalcTextSize(formattedText)
    local startPos = ImGui.GetCursorPosVec()
    ImGui.Dummy(ImVec2(textSizeX, textSizeY))
    if afConfig and not ImGui.IsItemHovered() then
        formattedText = formattedText:reverse()
    end
    ImGui.SetCursorPos(startPos)
    ImGui.Text(formattedText)
end

function Ui.RenderColoredText(color, text, ...)
    local formattedText = string.format(text, ...)
    local afConfig = Config:GetSetting('EnableAFUI')
    local textSizeX, textSizeY = ImGui.CalcTextSize(formattedText)
    local startPos = ImGui.GetCursorPosVec()
    ImGui.Dummy(ImVec2(textSizeX, textSizeY))
    if afConfig and not ImGui.IsItemHovered() then
        formattedText = formattedText:reverse()
    end
    ImGui.SetCursorPos(startPos)
    ImGui.TextColored(color, formattedText)
end

function Ui.RenderHyperText(text, normalColor, highlightColor, callback)
    local startingPos = ImGui.GetCursorPosVec()
    local version = Modules:ExecModule("Class", "GetVersionString")
    if ImGui.InvisibleButton("###" .. text .. "__invisbutton", ImGui.CalcTextSize(version), ImGui.GetTextLineHeight()) then
        if callback then
            callback()
        end
    end
    local afConfig = Config:GetSetting('EnableAFUI')
    if afConfig and not ImGui.IsItemHovered() then
        text = text:reverse()
    end
    ImGui.SetCursorPos(startingPos)
    ImGui.TextColored(ImGui.IsItemHovered() and highlightColor or normalColor, text)
end

--- Generates a dynamic tooltip for a given spell action.
--- @param action string The action identifier for the spell.
--- @return string The generated tooltip for the spell.
function Ui.GetDynamicTooltipForSpell(action)
    local resolvedItem = Modules:ExecModule("Class", "GetResolvedActionMapItem", action)

    if not resolvedItem or not resolvedItem() then
        return string.format("Use %s Spell : %s\n\nThis Spell:\n%s", action, "None", "None")
    end

    return string.format("Use %s Spell : %s\n\nThis Spell:\n%s", action, resolvedItem() or "None",
        resolvedItem.Description() or "None")
end

--- Generates a dynamic tooltip for a given action.
--- @param action string The action for which the tooltip is generated.
--- @return string The generated tooltip for the specified action.
function Ui.GetDynamicTooltipForAA(action)
    local resolvedItem = mq.TLO.Spell(action)

    return string.format("Use %s Spell : %s\n\nThis Spell:\n%s", action, resolvedItem() or "None",
        resolvedItem.Description() or "None")
end

---@return ImVec4 The color corresponding to the given percentage.
function Ui.GetPercentageColor(pct, scale)
    local t = 1 - math.max(0, math.min(1, pct / 100.0))
    local n = #scale
    if n == 1 then return scale[1] end

    local scaled = t * (n - 1)
    local i = math.floor(scaled) + 1
    local f = scaled - (i - 1)

    local c1 = scale[i]
    local c2 = scale[math.min(i + 1, n)]

    return ImVec4(
        c1.x + (c2.x - c1.x) * f,
        c1.y + (c2.y - c1.y) * f,
        c1.z + (c2.z - c1.z) * f,
        1.0)
end

--- Get the con color based on the provided color value.
--- @param color string The color value to determine the con color.
--- @return number, number, number, number The corresponding con color in RGBA format
function Ui.GetConColor(color)
    if color then
        if color:lower() == "dead" then
            return 0.4, 0.4, 0.4, 0.8
        end

        if color:lower() == "grey" then
            return 0.6, 0.6, 0.6, 0.8
        end

        if color:lower() == "green" then
            return 0.02, 0.8, 0.2, 0.8
        end

        if color:lower() == "light blue" then
            return 0.02, 0.8, 1.0, 0.8
        end

        if color:lower() == "blue" then
            return 0.02, 0.4, 1.0, 1.0
        end

        if color:lower() == "yellow" then
            return 0.8, 0.8, 0.02, 0.8
        end

        if color:lower() == "red" then
            return 0.8, 0.2, 0.2, 0.8
        end
    end

    return 1.0, 1.0, 1.0, 1.0
end

--- @param spawn MQSpawn The spawn object for which to determine the con color.
--- @return number, number, number, number The con color associated with the given spawn in RGBA format.
function Ui.GetConColorBySpawn(spawn)
    if not spawn or not spawn or spawn.Dead() then return Ui.GetConColor("Dead") end

    return Ui.GetConColor(spawn.ConColor())
end

--- @param spawn MQSpawn The spawn object for which to determine the con color.
--- @return number, number, number, number The con color associated with the given spawn in RGBA format.
function Ui.GetConHighlightBySpawn(spawn)
    if not spawn or not spawn or spawn.Dead() then return Ui.GetConColor("Dead") end

    return Ui.GetConHighlight(spawn.ConColor())
end

--- Get the con color based on the provided color value.
--- @param color string The color value to determine the con color.
--- @return number, number, number, number The corresponding con color in RGBA format
function Ui.GetConHighlight(color)
    if color then
        if color:lower() == "dead" then
            return 0.4, 0.4, 0.4, 0.1
        end

        if color:lower() == "grey" then
            return 0.6, 0.6, 0.6, 0.3
        end

        if color:lower() == "green" then
            return 0.02, 0.8, 0.2, 0.3
        end

        if color:lower() == "light blue" then
            return 0.02, 0.8, 1.0, 0.3
        end

        if color:lower() == "blue" then
            return 0.02, 0.4, 1.0, 0.3
        end

        if color:lower() == "yellow" then
            return 0.8, 0.8, 0.02, 0.3
        end

        if color:lower() == "red" then
            return 0.8, 0.2, 0.2, 0.3
        end
    end

    return 1.0, 1.0, 1.0, 0.3
end

--- Checks if navigation is enabled for a given location.
--- @param loc string The location to check, represented as a string with coordinates.
function Ui.NavEnabledLoc(loc)
    ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.Yellow)
    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, Globals.Constants.Colors.Grey)
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, Globals.Constants.Colors.Green)
    local navLoc = ImGui.Selectable(loc, false, ImGuiSelectableFlags.AllowDoubleClick)
    ImGui.PopStyleColor(3)
    if loc ~= "0,0,0" then
        if navLoc and ImGui.IsMouseDoubleClicked(0) then
            Core.DoCmd('/nav locYXZ %s', loc)
        end

        Ui.Tooltip("Double click to Nav")
    end
end

--- Generates a tooltip with the given description.
--- @param desc string: The description to be displayed in the tooltip.
function Ui.Tooltip(desc)
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 25.0)
        if type(desc) == "function" then
            ImGui.Text(desc())
        else
            ImGui.Text(desc)
        end
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

--- Generates a tooltip with the given description.
--- @param lines table: { text = "", color = ImVec4, sameLine = bool }
function Ui.MultilineTooltipWithColors(lines)
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 25.0)
        for _, line in ipairs(lines) do
            if line.sameLine then
                ImGui.SameLine()
            end
            if line.color then
                ImGui.PushStyleColor(ImGuiCol.Text, line.color)
            end
            ImGui.Text(line.text)
            if line.color then
                ImGui.PopStyleColor()
            end
        end

        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

--- Generates a tooltip with the given description.
--- @param lines table: { text = "", color = ImVec4, sameLine = bool }
function Ui.MultiColorSmallButton(lines, addSpaces)
    local fullText = ""
    for _, line in ipairs(lines) do fullText = fullText .. line.text .. (addSpaces and " " or "") end
    local size = ImGui.CalcTextSizeVec(fullText)
    local style = ImGui.GetStyle()
    ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImVec2(style.FramePadding.x, 0))
    ImGui.InvisibleButton(fullText, size)

    local hovered = ImGui.IsItemHovered()
    local active  = ImGui.IsItemActive()

    local buttonCol
    if active then
        buttonCol = ImGui.GetStyleColorVec4(ImGuiCol.ButtonActive)
    elseif hovered then
        buttonCol = ImGui.GetStyleColorVec4(ImGuiCol.ButtonHovered)
    else
        buttonCol = ImGui.GetStyleColorVec4(ImGuiCol.Button)
    end

    local min_x, min_y = ImGui.GetItemRectMin()
    local max_x, max_y = ImGui.GetItemRectMax()
    local draw_list    = ImGui.GetWindowDrawList()

    ---@diagnostic disable-next-line: param-type-mismatch
    local defaultColor = ImGui.GetStyleColorVec4(ImGuiCol.Text)

    -- Background
    draw_list:AddRectFilled(
        ImVec2(min_x, min_y),
        ImVec2(max_x, max_y),
        buttonCol:ToImU32(),
        style.FrameRounding
    )

    fullText = ""
    for _, line in ipairs(lines) do
        if not line.color then line.color = defaultColor end
        local offset = ImGui.CalcTextSizeVec(fullText)

        draw_list:AddText(ImVec2(style.FramePadding.x + min_x + offset.x, min_y), IM_COL32(line.color.x * 255, line.color.y * 255, line.color.z * 255, line.color.w * 255), line
            .text)
        fullText = fullText .. line.text .. (addSpaces and " " or "")
    end

    ImGui.PopStyleVar(1)

    return ImGui.IsItemClicked()
end

function Ui.NonCollapsingHeader(label)
    ImGui.TreeNodeEx(label, bit32.bor(ImGuiTreeNodeFlags.DefaultOpen,
        ImGuiTreeNodeFlags.Framed,
        ImGuiTreeNodeFlags.SpanAvailWidth,
        ImGuiTreeNodeFlags.NoTreePushOnOpen,
        ImGuiTreeNodeFlags.Leaf,
        ImGuiTreeNodeFlags.NoTreePushOnOpen))

    return true
end

--- Renders text as strikethrough
--- @param text string The text to be displayed with strikethrough.
function Ui.StrikeThroughText(text)
    local textSizeVec = ImGui.CalcTextSizeVec(text)
    local cursorScreenPos = ImGui.GetCursorScreenPosVec()
    ImGui.PushStyleColor(ImGuiCol.Text, 0.6, 0.6, 0.6, 0.9)
    cursorScreenPos.y = cursorScreenPos.y + ((ImGui.GetTextLineHeightWithSpacing() - (ImGui.GetStyle().FramePadding.y)) / 2)
    ImGui.GetWindowDrawList():AddLine(cursorScreenPos, ImVec2(cursorScreenPos.x + textSizeVec.x, cursorScreenPos.y), IM_COL32(255, 255, 255, 255), 1.0)
    ImGui.Text(text)
    ImGui.PopStyleColor()
end

function Ui.GetAssistWarningString()
    local warningString
    if not Config:GetSetting('UseAssistList') then
        if mq.TLO.Raid.Members() == 0 and mq.TLO.Group() then
            if not mq.TLO.Group.MainAssist() then
                warningString = "Warning: NO GROUP MA ASSIGNED - PLEASE SET ONE!"
            elseif mq.TLO.Group.MainAssist.ID() == 0 then
                warningString = "Warning: GROUP MA NOT IN ZONE!"
            end
        elseif mq.TLO.Raid.Members() > 0 then
            if not mq.TLO.Raid.MainAssist(Config:GetSetting('RaidAssistTarget'))() then
                warningString = "Warning: NO RAID MA ASSIGNED - PLEASE SET ONE!"
            elseif mq.TLO.Raid.MainAssist(Config:GetSetting('RaidAssistTarget')).ID() == 0 then
                warningString = "Warning: SELECTED RAID MA NOT IN ZONE!"
            end
        end
    elseif #Config:GetSetting('AssistList') == 0 then
        warningString = "Warning: THE ASSIST LIST IS ENABLED, BUT THE LIST IS EMPTY!"
    end

    Config.TempSettings.AssistWarning = warningString
end

function Ui.InvisibleWithButtonText(id, text, size, callbackFn)
    local buttonPos = ImGui.GetCursorPosVec()
    if ImGui.InvisibleButton(id, size or ImVec2(0, 0)) then
        if callbackFn then
            callbackFn()
        end
    end

    ImGui.SetCursorPos(buttonPos)

    ImGui.Text(text)
end

return Ui
