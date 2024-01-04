-- Sample Basic Class Module
local mq                           = require('mq')
local RGMercsLogger                = require("utils.rgmercs_logger")
local RGMercUtils                  = require("utils.rgmercs_utils")

local Module                       = { _version = '0.1a', name = "Travel", author = 'Derple', }
Module.__index                     = Module
Module.TransportSpells             = {}
Module.ButtonWidth                 = 150
Module.ButtonHeight                = 25

Module.TempSettings                = {}
Module.TempSettings.ShouldRequest  = true
Module.TempSettings.SelectedPorter = 1
Module.TempSettings.PorterList     = {}
Module.TempSettings.FilteredList   = {}
Module.TempSettings.FilterText     = ""

local travelColors                 = {}
travelColors["Group v2"]           = {}
travelColors["Group v1"]           = {}
travelColors["Self"]               = {}
travelColors["Single"]             = {}

-- evac
travelColors["Group v2"]["r"]      = 220
travelColors["Group v2"]["g"]      = 0
travelColors["Group v2"]["b"]      = 0

-- group port
travelColors["Group v1"]["r"]      = 141
travelColors["Group v1"]["g"]      = 0
travelColors["Group v1"]["b"]      = 250

-- self gate
travelColors["Self"]["r"]          = 200
travelColors["Self"]["g"]          = 240
travelColors["Self"]["b"]          = 0

-- translocation
travelColors["Single"]["r"]        = 180
travelColors["Single"]["g"]        = 0
travelColors["Single"]["b"]        = 180

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
    RGMercsLogger.log_info("Travel Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        RGMercsLogger.log_error("\ay[Travel]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self.settings = {}
        self:SaveSettings(true)
    else
        self.settings = config()
    end
end

function Module:TravelerUpdate(newData)
    if newData then
        RGMercsLogger.log_debug("\agGot new Traveler update from: \am%s", newData.Name)

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
    RGMercsLogger.log_debug("\atBroadcasting TravelerUpdate")
    RGMercUtils.BroadcastUpdate(self.name, "TravelerUpdate", self.TransportSpells[RGMercConfig.Globals.CurLoadedChar])
end

function Module:RequestPorterInfo()
    RGMercUtils.BroadcastUpdate(self.name, "SendPorterInfo")
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    RGMercsLogger.log_info("Travel Module Loaded.")

    local className = mq.TLO.Me.Class.ShortName():lower()
    self:LoadSettings()

    if className == "wiz" or className == "dru" then
        self.TransportSpells                                                    = {}
        self.TransportSpells[RGMercConfig.Globals.CurLoadedChar]                = {}
        self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].Class          = className
        self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].Name           = RGMercConfig.Globals.CurLoadedChar
        self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].Tabs           = {}
        self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].SortedTabNames = {}

        for i = 1, RGMercConfig.Constants.SpellBookSlots do
            local spell = mq.TLO.Me.Book(i)
            if spell.Category() == "Transport" then
                RGMercsLogger.log_debug("\ayFound Transport Spell: <\ay%s\ay> => \at'%s'\ay \ao(%d) \ay[\am%s\ay]", spell.Subcategory(), spell.RankName(), spell.ID(),
                    spell.TargetType())
                local subCat = spell.Subcategory()
                self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].Tabs[subCat] = self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].Tabs[subCat] or {}
                table.insert(self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].Tabs[subCat],
                    {
                        Name = spell.RankName(),
                        Type = spell.TargetType(),
                        SearchFields = string.format("%s,%s,%s,%s", spell.RankName(), spell.TargetType(), subCat, spell.Extra()):lower(),
                    })
            end
        end

        for k in pairs(self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].Tabs) do
            table.insert(
                self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].SortedTabNames, k)
        end
        table.sort(self.TransportSpells[RGMercConfig.Globals.CurLoadedChar].SortedTabNames)

        -- notify everyone else of my state...
        self:SendPorterInfo()
    end

    self:CreatePorterList()
    self:GenerateFilteredPortsList()

    return { settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
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
    for porter, data in pairs(self.TransportSpells) do
        if porter == self.TempSettings.PorterList[self.TempSettings.SelectedPorter] then
            for subCat, spellList in pairs(data.Tabs) do
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

function Module:Render()
    local width = ImGui.GetWindowWidth()
    local buttonsPerRow = math.max(1, math.floor(width / self.ButtonWidth))
    local changed

    ImGui.Text("Travel")
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
            ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 1.0)
        else
            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
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
                        ImGui.PushStyleColor(ImGuiCol.Text, 0, 0, 0, 1)
                        ImGui.PushStyleColor(ImGuiCol.Button, self:GetColorForType(sv.Type))
                        if ImGui.Button(sv.Name, self.ButtonWidth, self.ButtonHeight) then
                            if sv.Type == "Single" then
                                mq.cmdf("/dex " ..
                                    selectedPorter .. " /casting \"" ..
                                    sv.Name .. "\" -maxtries|10 -targetid|" .. RGMercUtils.GetTargetID())
                            else
                                mq.cmdf("/dex " .. selectedPorter .. " /casting \"" .. sv.Name .. "\" -maxtries|10")
                            end
                        end
                        ImGui.PopStyleColor(2)
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
    RGMercsLogger.log_info("Travel Module Unloaded.")
end

return Module
