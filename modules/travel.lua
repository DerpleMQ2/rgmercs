-- Sample Basic Class Module
local mq                           = require('mq')
local Config                       = require('utils.config')
local Globals                      = require('utils.globals')
local Ui                           = require("utils.ui")
local Comms                        = require("utils.comms")
local Core                         = require("utils.core")
local Targeting                    = require("utils.targeting")
local Logger                       = require("utils.logger")
local Strings                      = require("utils.strings")
local Set                          = require("mq.Set")

local Module                       = { _version = '0.1a', _name = "Travel", _author = 'Derple', }
Module.__index                     = Module
Module.TransportSpells             = {}
Module.ButtonWidth                 = 150
Module.ButtonHeight                = 25
Module.SaveRequested               = nil

Module.TempSettings                = {}
Module.TempSettings.ShouldRequest  = true
Module.TempSettings.SelectedPorter = 1
Module.TempSettings.PorterList     = {}
Module.TempSettings.FilteredList   = {}
Module.TempSettings.FilterText     = ""
Module.FAQ                         = {}

local travelColors                 = {}
travelColors["Group v2"]           = {}
travelColors["Group v1"]           = {}
travelColors["Self"]               = {}
travelColors["Single"]             = {}

-- evac
travelColors["Group v2"]["r"]      = 220
travelColors["Group v2"]["g"]      = 80
travelColors["Group v2"]["b"]      = 80

-- group port
travelColors["Group v1"]["r"]      = 141
travelColors["Group v1"]["g"]      = 80
travelColors["Group v1"]["b"]      = 250

-- self gate
travelColors["Self"]["r"]          = 200
travelColors["Self"]["g"]          = 240
travelColors["Self"]["b"]          = 80

-- translocation
travelColors["Single"]["r"]        = 180
travelColors["Single"]["g"]        = 80
travelColors["Single"]["b"]        = 180

Module.DefaultConfig               = {
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Default = false,
    },
}

local function getConfigFileName()
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. Globals.CurServerNormalized .. "_" .. Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    self.SaveRequested = { time = os.time(), broadcast = doBroadcast or false, }
end

function Module:WriteSettings()
    if not self.SaveRequested then return end

    mq.pickle(getConfigFileName(), Config:GetModuleSettings(self._name))

    if self.SaveRequested.doBroadcast == true then
        Comms.BroadcastMessage(self._name, "LoadSettings")
    end

    Logger.log_debug("\ag%s Module settings saved to %s, requested %s ago.", self._name, getConfigFileName(), Strings.FormatTime(os.time() - self.SaveRequested.time))

    self.SaveRequested = nil
end

function Module:LoadSettings()
    Logger.log_debug("Travel Module Loading Settings for: %s.", Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()
    local settings = {}
    local firstSaveRequired = false

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Travel]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        firstSaveRequired = true
    else
        settings = config()
    end

    Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)
end

function Module:TravelerUpdate(newData)
    if newData then
        Logger.log_debug("\agGot new Traveler update from: \am%s", newData.Name)

        self.TransportSpells[newData.Name] = newData

        self:CreatePorterList()
        self:GenerateFilteredPortsList()
    end
end

function Module:CreatePorterList()
    self.TempSettings.PorterList = {}
    for k, v in pairs(self.TransportSpells) do
        table.insert(self.TempSettings.PorterList, k)
    end
end

function Module:SendPorterInfo()
    Logger.log_debug("\atBroadcasting TravelerUpdate")
    Comms.BroadcastMessage(self._name, "TravelerUpdate", self.TransportSpells[Globals.CurLoadedChar])
end

function Module:RequestPorterInfo()
    Comms.BroadcastMessage(self._name, "SendPorterInfo")
end

function Module.New()
    local newModule = setmetatable({}, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Travel Module Loaded.")

    local className = mq.TLO.Me.Class.ShortName():lower()
    self:LoadSettings()

    if Core.MyClassIs("wiz") or Core.MyClassIs("dru") then
        self.TransportSpells                                       = {}
        self.TransportSpells[Globals.CurLoadedChar]                = {}
        self.TransportSpells[Globals.CurLoadedChar].Class          = className
        self.TransportSpells[Globals.CurLoadedChar].Name           = Globals.CurLoadedChar
        self.TransportSpells[Globals.CurLoadedChar].Tabs           = {}
        self.TransportSpells[Globals.CurLoadedChar].SortedTabNames = {}

        for i = 1, Globals.Constants.SpellBookSlots do
            local spell = mq.TLO.Me.Book(i)
            if spell.Category() == "Transport" then
                Logger.log_debug("\ayFound Transport Spell: <\ay%-15s\ay> => \at'%s'\ay \ao(%d) \ay[\am%s\ay]", spell.Subcategory(), spell.RankName(), spell.ID(),
                    spell.TargetType())
                local subCat = spell.Subcategory()
                self.TransportSpells[Globals.CurLoadedChar].Tabs[subCat] = self.TransportSpells[Globals.CurLoadedChar].Tabs[subCat] or {}
                table.insert(self.TransportSpells[Globals.CurLoadedChar].Tabs[subCat],
                    {
                        Name = spell.RankName(),
                        Type = spell.TargetType(),
                        SearchFields = string.format("%s,%s,%s,%s", spell.RankName(), spell.TargetType(), subCat, spell.Extra()):lower(),
                    })
            end
        end

        for k in pairs(self.TransportSpells[Globals.CurLoadedChar].Tabs) do
            table.insert(
                self.TransportSpells[Globals.CurLoadedChar].SortedTabNames, k)
        end
        table.sort(self.TransportSpells[Globals.CurLoadedChar].SortedTabNames)

        -- notify everyone else of my state...
        self:SendPorterInfo()
    end

    self:CreatePorterList()
    self:GenerateFilteredPortsList()

    return { self = self, defaults = self.DefaultConfig, }
end

function Module:GetColorForType(type)
    return
        ((travelColors[type] and (travelColors[type]["r"] or 100) or 100) / 255),
        ((travelColors[type] and (travelColors[type]["g"] or 100) or 100) / 255),
        ((travelColors[type] and (travelColors[type]["b"] or 100) or 100) / 255), 1.0
end

function Module:GenerateFilteredPortsList()
    self.TempSettings.FilteredList = {}
    self.TempSettings.FilteredList.Tabs = {}
    self.TempSettings.FilteredList.SortedTabNames = {}

    if #self.TempSettings.PorterList == 0 or not self.TempSettings.PorterList[self.TempSettings.SelectedPorter] then
        return
    end

    for porter, data in pairs(self.TransportSpells or {}) do
        if porter == self.TempSettings.PorterList[self.TempSettings.SelectedPorter] then
            for subCat, spellList in pairs(data.Tabs or {}) do
                for _, spellData in ipairs(spellList) do
                    local s, _ = string.find(spellData.SearchFields, self.TempSettings.FilterText:lower())
                    if self.TempSettings.FilterText:len() >= 1 and (s ~= nil) then
                        self.TempSettings.FilteredList.Tabs[subCat] = self.TempSettings.FilteredList.Tabs[subCat] or {}
                        table.insert(self.TempSettings.FilteredList.Tabs[subCat], spellData)
                    elseif self.TempSettings.FilterText:len() < 1 then
                        self.TempSettings.FilteredList.Tabs[subCat] = self.TempSettings.FilteredList.Tabs[subCat] or {}
                        table.insert(self.TempSettings.FilteredList.Tabs[subCat], spellData)
                    end
                end
            end
        end
    end

    for k, _ in pairs(self.TempSettings.FilteredList.Tabs) do
        table.insert(self.TempSettings.FilteredList.SortedTabNames, k)
    end
    table.sort(self.TempSettings.FilteredList.SortedTabNames)
end

function Module:ShouldRender()
    return #self.TempSettings.PorterList > 0
end

function Module:Render()
    Ui.RenderPopAndSettings(self._name)

    local width = ImGui.GetWindowWidth()
    local buttonsPerRow = math.max(1, math.floor(width / self.ButtonWidth))
    local changed

    if #self.TempSettings.PorterList > 0 then
        self.TempSettings.SelectedPorter, changed = ImGui.Combo("Select Character", self.TempSettings.SelectedPorter, self.TempSettings.PorterList)
        if changed then
            self:GenerateFilteredPortsList()
        end

        local selectedPorter = self.TempSettings.PorterList[self.TempSettings.SelectedPorter]
        local groupedWithPorter = mq.TLO.Group.Member(selectedPorter)() and true or false

        ImGui.Text("Grouped with %s: ", selectedPorter)
        ImGui.SameLine()

        if groupedWithPorter then
            ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionPassColor)
        else
            ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.ConditionFailColor)
        end
        ImGui.Text(groupedWithPorter and "Yes" or "No")
        ImGui.PopStyleColor()

        ImGui.Separator()
        ImGui.Text("Filter Ports: ")
        ImGui.SameLine()
        self.TempSettings.FilterText, changed = ImGui.InputText("##text_filter", self.TempSettings.FilterText)
        if changed then
            self:GenerateFilteredPortsList()
        end

        if ImGui.BeginTabBar("Tabs", ImGuiTabBarFlags.FittingPolicyScroll) then
            for _, k in ipairs(self.TempSettings.FilteredList.SortedTabNames) do
                -- why is this here? ImGui.TableNextColumn()
                if ImGui.BeginTabItem(k) then
                    ImGui.BeginTable("Buttons", buttonsPerRow)
                    for _, sv in ipairs(self.TempSettings.FilteredList.Tabs[k]) do
                        ImGui.TableNextColumn()
                        ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.BasicColors.Black)
                        ImGui.PushStyleColor(ImGuiCol.Button, self:GetColorForType(sv.Type))
                        if ImGui.Button(sv.Name, self.ButtonWidth, self.ButtonHeight) then
                            local cmd = string.format("/rgl cast \"%s\"", sv.Name)
                            if sv.Type == "Single" then
                                cmd = cmd .. string.format(" %d", Targeting.GetTargetID())
                            end

                            if selectedPorter ~= mq.TLO.Me.DisplayName() then
                                cmd = string.format("/dex %s %s", selectedPorter, cmd)
                            end

                            Core.DoCmd(cmd)
                        end
                        ImGui.PopStyleColor(2)
                        Ui.Tooltip(sv.Name)
                    end
                    ImGui.EndTable()
                    ImGui.EndTabItem()
                end
            end

            ImGui.EndTabBar();
        end
    else
        ImGui.Text("No Porters Loaded...")
    end
end

function Module:Pop()
    Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
    if self.TempSettings.ShouldRequest then
        self.TempSettings.ShouldRequest = false
        self:RequestPorterInfo()
    end
end

function Module:OnDeath()
    -- Death Handler
end

function Module:OnZone()
    -- Zone Handler
end

function Module:OnCombatModeChanged()
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    return "Running..."
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = {}, }
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
    -- /rglua cmd handler
    return handled
end

function Module:Shutdown()
    Logger.log_debug("Travel Module Unloaded.")
end

return Module
