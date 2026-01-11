local mq                         = require('mq')
local Config                     = require('utils.config')
local Globals                    = require("utils.globals")
local Core                       = require("utils.core")
local Ui                         = require("utils.ui")
local Comms                      = require("utils.comms")
local Logger                     = require("utils.logger")
local Strings                    = require("utils.strings")
local Set                        = require("mq.Set")
local Icons                      = require('mq.ICONS')
local Zep                        = require('Zep')
local CHANNEL_COLOR              = IM_COL32(215, 154, 66)

local Module                     = { _version = '0.1a', _name = "Debug", _author = 'Derple', }
Module.__index                   = Module
Module.FAQ                       = {}
Module.SaveRequested             = nil

Module.DefaultConfig             = {
    ['script'] = {
        Default = "",
        DisplayName = "Script",
        Category = "Custom",
        Type = "Custom",
    },
    ['ShowTimestamps'] = {
        Default = true,
        DisplayName = "Show Time Stamps",
        Category = "Custom",
        Type = "Custom",
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Default = false,
    },
}
Module.luaConsole                = Zep.Console.new("##RGDebugConsole")
Module.luaConsole.maxBufferLines = 1000
Module.luaConsole.autoScroll     = true

Module.luaEditor                 = Zep.Editor.new('##RGDebugLuaEditor')
Module.luaBuffer                 = Module.luaEditor:CreateBuffer("[DebugConsole]")
Module.luaBuffer.syntax          = 'lua'
Module.execRequested             = false
Module.execCoroutine             = nil
Module.status                    = "Idle..."
Module.autoRun                   = false

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
    Logger.log_debug("Debug Module Loading Settings for: %s.", Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()
    local settings = {}
    local firstSaveRequired = false


    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Debug]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        firstSaveRequired = true
    else
        settings = config()
    end

    Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)

    self.luaBuffer:SetText(Config:GetSetting('script') or "")
end

function Module.New()
    local newModule = setmetatable({}, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Debug Module Loaded.")
    self:LoadSettings()

    self.ModuleLoaded = true

    return { self = self, defaults = self.DefaultConfig, }
end

function Module:LogTimestamp()
    if Config:GetSetting('ShowTimestamps') then
        local now = os.date('%H:%M:%S')
        self.luaConsole:AppendTextUnformatted(string.format('\aw[\at%s\aw] ', now))
    end
end

function Module:LogToConsole(...)
    self:LogTimestamp()
    self.luaConsole:AppendText(CHANNEL_COLOR, ...)
end

function Module:Exec(scriptText)
    local func, err = load(scriptText, "LuaConsoleScript", "t")
    if not func then
        return false, err
    end

    local locals       = setmetatable({}, { __index = _G, })
    locals.mq          = setmetatable({}, { __index = mq, })
    locals.Config      = setmetatable({}, { __index = Config, })
    locals.Core        = setmetatable({}, { __index = Core, })
    locals.Targeting   = setmetatable({}, { __index = require('utils.targeting'), })
    locals.Casting     = setmetatable({}, { __index = require('utils.casting'), })
    locals.Combat      = setmetatable({}, { __index = require('utils.combat'), })
    locals.Comms       = setmetatable({}, { __index = require('utils.comms'), })
    locals.ItemManager = setmetatable({}, { __index = require('utils.item_manager'), })
    locals.Logger      = setmetatable({}, { __index = require('utils.logger'), })
    locals.Math        = setmetatable({}, { __index = require('utils.math'), })
    locals.Modules     = setmetatable({}, { __index = require('utils.modules'), })
    locals.Movement    = setmetatable({}, { __index = require('utils.movement'), })
    locals.Nameds      = setmetatable({}, { __index = require('utils.nameds'), })
    locals.Rotation    = setmetatable({}, { __index = require('utils.rotation'), })
    locals.Strings     = setmetatable({}, { __index = require('utils.strings'), })
    locals.Tables      = setmetatable({}, { __index = require('utils.tables'), })
    locals.ConfigShare = setmetatable({}, { __index = require('utils.rg_config_share'), })
    locals.Set         = setmetatable({}, { __index = require('mq.set'), })


    locals.print   = function(...)
        self:LogTimestamp()
        self.luaConsole:PushStyleColor(Zep.ConsoleCol.Text, CHANNEL_COLOR)
        for _, arg in ipairs({ ..., }) do
            self.luaConsole:AppendTextUnformatted(tostring(arg))
        end
        self.luaConsole:AppendTextUnformatted('\n')
        self.luaConsole:PopStyleColor()
    end

    locals.printf  = function(text, ...)
        self:LogTimestamp()
        self.luaConsole:AppendText(CHANNEL_COLOR, text, ...)
    end

    locals.mq.exit = function()
        self.execCoroutine = nil
    end

    locals.hi      = 3

    ---@diagnostic disable-next-line: deprecated
    setfenv(func, locals)

    local success, msg = pcall(func)
    return success, msg or ""
end

function Module:ExecCoroutine()
    local scriptText = self.luaBuffer:GetText()

    return coroutine.create(function()
        local success, msg = self:Exec(scriptText)
        if not success then
            self:LogToConsole("\ar" .. msg)
        end
    end)
end

function Module:RenderConsole()
    local contentSizeX, contentSizeY = ImGui.GetContentRegionAvail()
    self.luaConsole:Render(ImVec2(contentSizeX, math.max(200, (contentSizeY - 10))))
end

function Module:RenderEditor()
    local yPos = ImGui.GetCursorPosY()
    local footerHeight = 35
    local editHeight = (ImGui.GetWindowHeight() * .5) - yPos - footerHeight

    self.luaEditor:Render(ImVec2(ImGui.GetWindowWidth() * 0.98, editHeight))
end

local function RenderTooltip(text)
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip(text)
    end
end

function Module:CenteredButton(label)
    local style = ImGui.GetStyle()

    local framePaddingX = style.FramePadding.x * 2
    local framePaddingY = style.FramePadding.y * 2

    local availableWidth = ImGui.GetContentRegionAvailVec().x
    local availableHeight = 30

    local textSizeVec = ImGui.CalcTextSizeVec(label)
    local textWidth = textSizeVec.x
    local textHeight = textSizeVec.y

    local paddingX = (availableWidth - textWidth - framePaddingX) / 2
    local paddingY = (availableHeight - textHeight - framePaddingY) / 2

    if paddingX > 0 then
        ImGui.SetCursorPosX(ImGui.GetCursorPosX() + paddingX)
    end
    if paddingY > 0 then
        ImGui.SetCursorPosY(ImGui.GetCursorPosY() + paddingY)
    end
    return ImGui.SmallButton(string.format("%s", label))
end

function Module:RenderToolbar()
    if ImGui.BeginTable("##LuaConsoleToolbar", 6, ImGuiTableFlags.Borders) then
        ImGui.TableSetupColumn("##LuaConsoleToolbarCol1", ImGuiTableColumnFlags.WidthFixed, 30)
        ImGui.TableSetupColumn("##LuaConsoleToolbarCol2", ImGuiTableColumnFlags.WidthFixed, 30)
        ImGui.TableSetupColumn("##LuaConsoleToolbarCol3", ImGuiTableColumnFlags.WidthFixed, 30)
        ImGui.TableSetupColumn("##LuaConsoleToolbarCol4", ImGuiTableColumnFlags.WidthFixed, 30)
        ImGui.TableSetupColumn("##LuaConsoleToolbarCol5", ImGuiTableColumnFlags.WidthFixed, 180)
        ImGui.TableSetupColumn("##LuaConsoleToolbarCol6", ImGuiTableColumnFlags.WidthStretch, 200)
        ImGui.TableNextColumn()

        if self.execCoroutine and coroutine.status(self.execCoroutine) ~= 'dead' then
            if self:CenteredButton(Icons.MD_STOP) then
                self.execCoroutine = nil
            end
            RenderTooltip("Stop Script")
        else
            if self:CenteredButton(Icons.MD_PLAY_ARROW) then
                self.execRequested = true
            end
            RenderTooltip("Execute Script (Ctrl+Enter)")
        end

        ImGui.TableNextColumn()

        if not self.autoRun then
            if self:CenteredButton(Icons.MD_FAST_FORWARD) then
                self.autoRun = true
            end
            RenderTooltip("Run on Loop")
        else
            if self:CenteredButton(Icons.MD_STOP) then
                self.autoRun = false
            end
            RenderTooltip("Stop Running")
        end

        ImGui.TableNextColumn()
        if self:CenteredButton(Icons.MD_CLEAR) then
            self.luaBuffer:Clear()
        end
        RenderTooltip("Clear Script")

        ImGui.TableNextColumn()
        if self:CenteredButton(Icons.MD_PHONELINK_ERASE) then
            self.luaConsole:Clear()
        end
        RenderTooltip("Clear Console")

        ImGui.TableNextColumn()
        local showTimestamps, pressed = ImGui.Checkbox("Print Time Stamps", Config:GetSetting('ShowTimestamps'))
        if pressed then
            Config:SetSetting('ShowTimestamps', showTimestamps)
        end
        ImGui.TableNextColumn()
        ImGui.Text("Status: " .. self.status)
        ImGui.EndTable()
    end
end

function Module:ShouldRender()
    return Config:GetSetting('EnableDebugging')
end

function Module:Render()
    Ui.RenderPopAndSettings(self._name)

    if self.ModuleLoaded then
        self:RenderEditor()
        self:RenderToolbar()
        self:RenderConsole()
    end
end

function Module:Pop()
    Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Module:DoEvents()
    -- Process Events if needed
    if self.execRequested or (self.autoRun and self.execCoroutine == nil) then
        self.execRequested = false
        self.execCoroutine = self:ExecCoroutine()
        coroutine.resume(self.execCoroutine)
        self.status = "Running..."
    end

    if self.execCoroutine and coroutine.status(self.execCoroutine) ~= 'dead' then
        coroutine.resume(self.execCoroutine)
    else
        self.execCoroutine = nil
        self.status = "Idle..."
    end
end

function Module:GiveTime(combat_state)
    self:DoEvents()

    if self.luaBuffer:HasFlag(Zep.BufferFlags.Dirty) then
        Config:SetSetting('script', self.luaBuffer:GetText())
        self.luaBuffer:ClearFlags(Zep.BufferFlags.Dirty)
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
    return self.status
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
    Logger.log_debug("Drag Module Unloaded.")
end

return Module
