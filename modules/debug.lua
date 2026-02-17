local mq            = require('mq')
local Config        = require('utils.config')
local Globals       = require("utils.globals")
local Core          = require("utils.core")
local Ui            = require("utils.ui")
local Logger        = require("utils.logger")
local Icons         = require('mq.ICONS')
local Zep           = require('Zep')
local Base          = require("modules.base")
local CHANNEL_COLOR = IM_COL32(215, 154, 66)

local Module        = { _version = '0.1a', _name = "Debug", _author = 'Derple', }
Module.__index      = Module
setmetatable(Module, { __index = Base, })

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

function Module:New()
    return Base.New(self)
end

function Module:LoadSettings()
    Base.LoadSettings(self)

    self.luaBuffer:SetText(Config:GetSetting('script') or "")
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

    local locals        = setmetatable({}, { __index = _G, })
    locals.mq           = setmetatable({}, { __index = mq, })
    locals.Config       = setmetatable({}, { __index = Config, })
    locals.Core         = setmetatable({}, { __index = Core, })
    locals.Globals      = setmetatable({}, { __index = Globals, })
    locals.ImGui        = setmetatable({}, { __index = ImGui, })
    locals.Targeting    = setmetatable({}, { __index = require('utils.targeting'), })
    locals.Casting      = setmetatable({}, { __index = require('utils.casting'), })
    locals.Combat       = setmetatable({}, { __index = require('utils.combat'), })
    locals.Comms        = setmetatable({}, { __index = require('utils.comms'), })
    locals.ItemManager  = setmetatable({}, { __index = require('utils.item_manager'), })
    locals.Logger       = setmetatable({}, { __index = require('utils.logger'), })
    locals.Math         = setmetatable({}, { __index = require('utils.math'), })
    locals.Modules      = setmetatable({}, { __index = require('utils.modules'), })
    locals.Movement     = setmetatable({}, { __index = require('utils.movement'), })
    locals.NamedDefault = setmetatable({}, { __index = require('namedlist.named_default'), })
    locals.NamedEQMight = setmetatable({}, { __index = require('namedlist.named_eqmight'), })
    locals.Rotation     = setmetatable({}, { __index = require('utils.rotation'), })
    locals.Strings      = setmetatable({}, { __index = require('utils.strings'), })
    locals.Tables       = setmetatable({}, { __index = require('utils.tables'), })
    locals.ConfigShare  = setmetatable({}, { __index = require('utils.rg_config_share'), })
    locals.Set          = setmetatable({}, { __index = require('mq.set'), })
    locals.DanNet       = setmetatable({}, { __index = require('lib.dannet.helpers'), })


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
    Base.Render(self)
    ImGui.NewLine()
    if self.ModuleLoaded then
        self:RenderEditor()
        self:RenderToolbar()
        self:RenderConsole()
    end
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

function Module:GiveTime()
    self:DoEvents()

    if self.luaBuffer:HasFlag(Zep.BufferFlags.Dirty) then
        Config:SetSetting('script', self.luaBuffer:GetText())
        self.luaBuffer:ClearFlags(Zep.BufferFlags.Dirty)
    end
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    return self.status
end

return Module
