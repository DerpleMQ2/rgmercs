local Config           = require('utils.config')
local Set              = require("mq.Set")
local Ui               = require("utils.ui")
local Logger           = require("utils.logger")

local Module           = { _version = '0.1a', _name = "Contributors", _author = 'Derple', }
Module.__index         = Module
Module.DefaultConfig   = {}
Module.Credits         = require("extras.credits")
Module.ColorWheel      = {}
Module.ColorWheelTimer = {}
Module.FAQ             = {}
Module.SaveRequested   = nil

function Module:SaveSettings(doBroadcast)
    self.SaveRequested = { time = os.time(), broadcast = doBroadcast or false, }
end

function Module:WriteSettings()
    if not self.SaveRequested then return end

    Logger.log_error("\ar%s Module requested to save settings bug this module has no settings!", self._name)

    self.SaveRequested = nil
end

function Module:LoadSettings()
    local settings = {}

    Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, false)
end

function Module.New()
    local newModule = setmetatable({}, Module)
    return newModule
end

function Module:Init()
end

function Module:RenderName(name)
    local length = name:len()

    self.ColorWheel[name] = self.ColorWheel[name] or math.random(10000)
    self.ColorWheelTimer[name] = self.ColorWheelTimer[name] or os.time()

    if os.time() - self.ColorWheelTimer[name] > 0.25 then
        self.ColorWheel[name] = self.ColorWheel[name] + 1 --math.random(500)
        self.ColorWheelTimer[name] = os.time()
    end

    for i = 1, length do
        local color = IM_COL32(
            math.floor(math.sin(0.3 * (self.ColorWheel[name] + i) + 0) * 127 + 128),
            math.floor(math.sin(0.3 * (self.ColorWheel[name] + i) + 2) * 127 + 128),
            math.floor(math.sin(0.3 * (self.ColorWheel[name] + i) + 4) * 127 + 128)
        )

        if i > 1 then
            ImGui.SameLine()
        end

        ImGui.PushStyleColor(ImGuiCol.Text, color)
        ImGui.Text(name:sub(i, i))
        ImGui.PopStyleColor()
    end
end

function Module:RenderConfig()
    if ImGui.CollapsingHeader("Developers", ImGuiTreeNodeFlags.DefaultOpen) then
        for _, c in ipairs(self.Credits.Devs) do
            self:RenderName(c)
        end
    end

    ImGui.NewLine()

    if ImGui.CollapsingHeader("Contributors - Thank You!") then
        for _, c in ipairs(self.Credits.Contributors) do
            self:RenderName(c)
        end
    end
end

function Module:ShouldRender()
    return false
end

function Module:Render()

end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
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
end

return Module
