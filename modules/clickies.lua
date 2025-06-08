-- Clickie Module
local mq                                = require('mq')
local Config                            = require('utils.config')
local Core                              = require('utils.core')
local Casting                           = require("utils.casting")
local Strings                           = require("utils.strings")
local Ui                                = require("utils.ui")
local Comms                             = require("utils.comms")
local Logger                            = require("utils.logger")
local Set                               = require("mq.Set")
local Icons                             = require('mq.ICONS')

local Module                            = { _version = '0.1a', _name = "Clickies", _author = 'Derple', }
Module.__index                          = Module
Module.settings                         = {}
Module.FAQ                              = {}
Module.ClassFAQ                         = {}

Module.TempSettings                     = {}
Module.TempSettings.ClickyState         = {}
Module.TempSettings.CombatClickiesTimer = 0

Module.DefaultConfig                    = {
    ['UseClickies']                            = {
        DisplayName = "Use Downtime Clickies",
        Category    = "Clickies",
        Index       = 0,
        Tooltip     = "Use items during Downtime.",
        Default     = false,
        ConfigType  = "Normal",
        FAQ         = "I have some clickie items that I want to use during downtime. How do I set them up?",
        Answer      = "You can set up to 12 clickie items in the Clickies section of the config.\n" ..
            "You can drag and drop them onto the ClickyItem# tags to add them.",
    },
    ['DowntimeClickies']                       = {
        DisplayName = "Downtime Item %d",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Array|ClickyItem",
        Default = {},
        ConfigType = "Normal",
        Index = 1,
        FAQ = "I have some clickie items that I want to use during downtime. How do I set them up?",
        Answer = "You can set up clickie items in the Clickies tab.\n" ..
            "You can drag and drop them onto the ClickyItem# tags to add them.",
    },
    ['UseCombatClickies']                      = {
        DisplayName = "Use Combat Clickies",
        Category    = "Clickies",
        Index       = 2,
        Tooltip     = "Use detrimental clickies on your target during Combat.",
        Default     = false,
        ConfigType  = "Normal",
        FAQ         = "Why isn't my combat clicky being used?",
        Answer      = "Combat clickies only support detrimental items.\n" ..
            "Beneficial items should be used in Downtime or have a specific entry added to control proper use conditions.",
    },
    ['CombatClickiesDelay']                    = {
        DisplayName = "Clicky Check Delay",
        Category = "Clickies",
        Index = 3,
        Tooltip = "Seconds to wait between the check to use Combat Clickies.\n" ..
            "Please Note: Setting this value too low may interfere with other actions!",
        Default = 5,
        Min = 1,
        Max = 30,
        ConfigType = "Advanced",
        FAQ = "Why are my Combat Clickies being used so slowly?",
        Answer = "By default, Combat Clickies are only checked every 10 seconds to ensure we aren't interfering with other (more important) actions.\n" ..
            "You can adjust this with the C.Click Check Delay setting. ",
    },
    ['CombatClickies']                         = {
        DisplayName = "Combat Item %d",
        Category    = "Clickies",
        Tooltip     = "Clicky Item to use During Downtime",
        Type        = "Array|ClickyItem",
        Default     = {},
        ConfigType  = "Normal",
        Index       = 4,
        FAQ         = "Why isn't my combat clicky being used?",
        Answer      = "Combat clickies only support detrimental items.\n" ..
            "Beneficial items should be used in Downtime or have a specific entry added to control proper use conditions.",
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
Module.DefaultCategories                = {}

local function getConfigFileName()
    local server = mq.TLO.EverQuest.Server()
    server = server:gsub(" ", "")
    return mq.configDir ..
        '/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast == true then
        Comms.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    Logger.log_debug("Clickies Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Drag]: Unable to load clickie settings file(%s), creating a new one!",
            settings_pickle_path)
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

    Logger.log_info("\awClickie Module: \atLoaded \ag%d\at Downtime Clickies and \ag%d\at Combat Clickies", #self.settings.DowntimeClickies, #self.settings.CombatClickies)

    if #self.settings.CombatClickies == 0 then
        local legacyClickes = {
            'CombatClicky1',
            'CombatClicky2',
            'CombatClicky3',
            'CombatClicky4',
            'CombatClicky5',
            'CombatClicky6',
        }

        for _, clicky in ipairs(legacyClickes) do
            local cur = Config:GetSetting(clicky)
            if cur:len() > 0 then
                table.insert(self.settings.CombatClickies, cur)
                Config:SetSetting(clicky, '')
                Logger.log_info("\awClickie Module: \atFound Legacy Combat Clicky \am\'\ag%s\am\'\aw, moving to new format.", cur)
                settingsChanged = true
            end
        end
    end

    if #self.settings.DowntimeClickies == 0 then
        local legacyClickes = {
            'ClickyItem1',
            'ClickyItem2',
            'ClickyItem3',
            'ClickyItem4',
            'ClickyItem5',
            'ClickyItem6',
            'ClickyItem7',
            'ClickyItem8',
            'ClickyItem9',
            'ClickyItem10',
            'ClickyItem11',
            'ClickyItem12',
        }

        for _, clicky in ipairs(legacyClickes) do
            local cur = Config:GetSetting(clicky)
            if cur:len() > 0 then
                table.insert(self.settings.DowntimeClickies, cur)
                Config:SetSetting(clicky, '')
                Logger.log_info("\awClickie Module: \atFound Legacy Downtime Clicky \am\'\ag%s\am\'\aw, moving to new format.", cur)

                settingsChanged = true
            end
        end
    end

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
    Logger.log_debug("Clickie Module Loaded.")
    self:LoadSettings()

    self.ModuleLoaded = true

    return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
    return true
end

function Module:RenderClickies(type, clickies)
    if ImGui.CollapsingHeader(type) then
        ImGui.Indent()

        if #clickies > 0 then
            if ImGui.BeginTable("##clickies_table_" .. type, 3, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
                ImGui.TableSetupColumn('Last Used', (ImGuiTableColumnFlags.WidthFixed), 100.0)
                ImGui.TableSetupColumn('Item', (ImGuiTableColumnFlags.WidthFixed), 150.0)
                ImGui.TableSetupColumn('Effect', (ImGuiTableColumnFlags.WidthStretch), 200.0)
                ImGui.PopStyleColor()
                ImGui.TableHeadersRow()

                for _, clicky in pairs(clickies) do
                    local lastUsed = self.TempSettings.ClickyState[clicky] and (self.TempSettings.ClickyState[clicky].lastUsed or 0) or 0
                    local item = self.TempSettings.ClickyState[clicky] and
                        (self.TempSettings.ClickyState[clicky].item and self.TempSettings.ClickyState[clicky].item.Clicky.Spell.RankName.Name() or "None")
                        or "None"
                    ImGui.TableNextColumn()
                    ImGui.Text(lastUsed > 0 and Strings.FormatTime((os.clock() - lastUsed)) or "Never")
                    ImGui.TableNextColumn()
                    ImGui.Text(clicky)
                    ImGui.TableNextColumn()
                    ImGui.Text(item)
                end

                ImGui.EndTable()
            end
        end
        ImGui.Unindent()
        ImGui.Separator()
    end
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

    self:RenderClickies("Downtime Clickies", self.settings.DowntimeClickies)

    self:RenderClickies("Combat Clickies", self.settings.CombatClickies)

    local pressed

    if ImGui.CollapsingHeader("Config Options") then
        self.settings, pressed, _ = Ui.RenderSettings(self.settings, self.DefaultConfig,
            self.DefaultCategories)
        if pressed then
            self:SaveSettings(false)
        end
    end
end

function Module:Pop()
    self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
    self:SaveSettings(false)
end

function Module:ValidateClickies(type)
    local numClickes = #self.settings[type]
    if numClickes == 0 or self.settings[type][numClickes] ~= "" then
        table.insert(self.settings[type], '')
        self:SaveSettings(false)
    end
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
    self:ValidateClickies('CombatClickies')
    self:ValidateClickies('DowntimeClickies')

    -- don't use clickies when we are trying to med, feigning, or invisible.
    if combat_state == 'Downtime' and Config:GetSetting('UseClickies') and not (mq.TLO.Me.Sitting() or Casting.IAmFeigning() or mq.TLO.Me.Invis()) then
        -- don't use clickies when we are trying to med, feigning, or invisible.

        for _, clicky in ipairs(self.settings.DowntimeClickies) do
            if clicky:len() > 0 then
                self.TempSettings.ClickyState[clicky] = self.TempSettings.ClickyState[clicky] or {}

                local item = mq.TLO.FindItem(clicky)
                Logger.log_verbose("Looking for clicky item: %s found: %s", clicky, Strings.BoolToColorString(item() ~= nil))

                if item then
                    self.TempSettings.ClickyState[clicky].item = item
                    if Casting.ItemReady(item()) then
                        if Casting.SelfBuffItemCheck(item) then
                            Logger.log_verbose("\aaClickies: Casting Item \at%s\ag Clicky: \at%s\ag!", item.Name(), item.Clicky.Spell.RankName.Name())
                            Casting.UseItem(item.Name(), mq.TLO.Me.ID())
                            self.TempSettings.ClickyState[clicky].lastUsed = os.clock()
                        else
                            Logger.log_verbose("\ayClickies: Item \at%s\ay Clicky: \at%s\ay already active or would not stack!", item.Name(), item.Clicky.Spell.RankName.Name())
                        end
                    else
                        Logger.log_verbose("\ayClickies: Item \at%s\ay Clicky: \at%s\ay Clicky not ready!", item.Name(), item.Clicky.Spell.RankName.Name())
                    end
                end
            end
        end
    end

    if combat_state == 'Combat' then
        -- I plan on breaking clickies out further to allow things like horn, other healing clickies to be used, that the user will select... this is "interim" implementation.
        if Core.OnLaz() and mq.TLO.Me.PctHPs() <= (Config:GetSetting('EmergencyStart', true) and Config:GetSetting('EmergencyStart') or 45) then
            local healingItems = { "Sanguine Mind Crystal", "Orb of Shadows", } -- "Draught of Opulent Healing", keeping this one manual for now
            for _, itemName in ipairs(healingItems) do
                local item = mq.TLO.FindItem(itemName)
                if item() and item.TimerReady() == 0 then
                    Logger.log_verbose("Low Health Detected, using a heal clicky!")
                    Casting.UseItem(item.Name(), mq.TLO.Me.ID())
                    return
                end
            end
        end

        -- Combat Clickies
        if os.clock() - self.TempSettings.CombatClickiesTimer < Config:GetSetting('CombatClickiesDelay') then
            Logger.log_super_verbose("\ayClickies: \arToo soon since last Combat Clickies check, aborting.")
            return
        end

        if Config:GetSetting('UseCombatClickies') and
            not (mq.TLO.Me.Sitting() or Casting.IAmFeigning() or
                not Core.OkayToNotHeal() or mq.TLO.Me.PctHPs() < (Config:GetSetting('EmergencyStart', true) and
                    Config:GetSetting('EmergencyStart') or 45)) then
            -- don't use clickies when we are trying to med, feigning, or invisible.

            for _, clicky in ipairs(self.settings.CombatClickies) do
                if clicky:len() > 0 then
                    self.TempSettings.ClickyState[clicky] = self.TempSettings.ClickyState[clicky] or {}

                    local item = mq.TLO.FindItem(clicky)
                    Logger.log_verbose("Looking for clicky item: %s found: %s", clicky, Strings.BoolToColorString(item() ~= nil))

                    if item then
                        self.TempSettings.ClickyState[clicky].item = item
                        if Casting.ItemReady(item()) then
                            if Casting.DetItemCheck(item) then
                                Logger.log_verbose("\aaClicky: Item \at%s\ag Clicky: \at%s\ag!", item.Name(), item.Clicky.Spell.RankName.Name())
                                Casting.UseItem(item.Name(), Config.Globals.AutoTargetID)
                                self.TempSettings.ClickyState[clicky].lastUsed = os.clock()
                                break --ensure we stop after we process a single clicky to allow rotations to continue
                            else
                                Logger.log_verbose("\ayClicky: Item \at%s\ay Clicky: \at%s\ay already active or would not stack!", item.Name(), item.Clicky.Spell.RankName.Name())
                            end
                        else
                            Logger.log_verbose("\ayClicky: Item \at%s\ay Clicky: \at%s\ay Clicky timer not ready!", item.Name(), item.Clicky.Spell.RankName.Name())
                        end
                    end
                end
            end
        end

        self.TempSettings.CombatClickiesTimer = os.clock()
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
    local result = string.format("\awLoaded \ag%d\at Downtime Clickies and \ag%d\at Combat Clickies\n\n", #self.settings.DowntimeClickies, #self.settings.CombatClickies)
    result = result .. "-=-=-=-=-=\n"

    for i, v in ipairs(self.settings.DowntimeClickies) do
        result = result .. string.format("\atDowntime Clicky %d: \ay%s\at\n", i, v)
    end

    result = result .. "\n"

    for i, v in ipairs(self.settings.CombatClickies) do
        result = result .. string.format("\atCombat Clicky %d: \ay%s\at\n", i, v)
    end

    return result
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = {}, }
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
    -- /rglua cmd handler
    return handled
end

function Module:Shutdown()
    Logger.log_debug("Clickie Module Unloaded.")
end

return Module
