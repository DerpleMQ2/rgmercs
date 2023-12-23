local mq     = require('mq')
local ImGui  = require('ImGui')
RGMercConfig = require('rgmercs.utils.rgmercs_config')
RGMercConfig:LoadSettings()

local RGMercsLogger  = require("rgmercs.utils.rgmercs_logger")
local RGMercUtils    = require("rgmercs.utils.rgmercs_utils")

-- Initialize class-based moduldes
local RGMercModules  = require("rgmercs.utils.rgmercs_modules").load()

-- ImGui Variables
local openGUI        = true
local shouldDrawGUI  = true
local BgOpacity      = tonumber(RGMercConfig:getSettings().BgOpacity)

local curState       = "Idle..."

-- Icon Rendering
local animItems      = mq.FindTextureAnimation("A_DragItem")
local animBox        = mq.FindTextureAnimation("A_RecessedBox")

-- Constants
local ICON_WIDTH     = 40
local ICON_HEIGHT    = 40
local COUNT_X_OFFSET = 39
local COUNT_Y_OFFSET = 23
local EQ_ICON_OFFSET = 500

local terminate      = false

local function display_item_on_cursor()
    if mq.TLO.Cursor() then
        local cursor_item = mq.TLO.Cursor -- this will be an MQ item, so don't forget to use () on the members!
        local mouse_x, mouse_y = ImGui.GetMousePos()
        local window_x, window_y = ImGui.GetWindowPos()
        local icon_x = mouse_x - window_x + 10
        local icon_y = mouse_y - window_y + 10
        local stack_x = icon_x + COUNT_X_OFFSET
        local stack_y = icon_y + COUNT_Y_OFFSET
        local text_size = ImGui.CalcTextSize(tostring(cursor_item.Stack()))
        ImGui.SetCursorPos(icon_x, icon_y)
        animItems:SetTextureCell(cursor_item.Icon() - EQ_ICON_OFFSET)
        ImGui.DrawTextureAnimation(animItems, ICON_WIDTH, ICON_HEIGHT)
        if cursor_item.Stackable() then
            ImGui.SetCursorPos(stack_x, stack_y)
            ImGui.DrawTextureAnimation(animBox, text_size, ImGui.GetTextLineHeight())
            ImGui.SetCursorPos(stack_x - text_size, stack_y)
            ImGui.TextUnformatted(tostring(cursor_item.Stack()))
        end
    end
end

local function renderModulesTabs()
    if not RGMercConfig:settingsLoaded() then return end
    for name, _ in pairs(RGMercModules:getModuleList()) do
        ImGui.TableNextColumn()
        if ImGui.BeginTabItem(name) then
            RGMercModules:execModule(name, "Render")
            ImGui.EndTabItem()
        end
    end
end

local function RGMercsGUI()
    if openGUI then
        openGUI, shouldDrawGUI = ImGui.Begin('RGMercs', openGUI)
        if mq.TLO.MacroQuest.GameState() ~= "INGAME" then return end

        ImGui.SetNextWindowBgAlpha(BgOpacity)

        if shouldDrawGUI then
            local pressed
            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1)
            ImGui.Text("RGMercs running for " .. RGMercConfig.CurLoadedChar)

            if ImGui.BeginTabBar("RGMercsTabs") then
                ImGui.SetItemDefaultFocus()
                if ImGui.BeginTabItem("RGMercsMain") then
                    ImGui.Text(curState)
                    ImGui.EndTabItem()
                end

                renderModulesTabs()

                ImGui.EndTabBar();
            end
            ImGui.PopStyleColor(1)

            ImGui.NewLine()
            ImGui.NewLine()
            ImGui.Separator()

            BgOpacity, pressed = ImGui.SliderFloat("BG Opacity", BgOpacity, 0, 1.0, "%.1f", 0.1)
            if pressed then
                RGMercConfig:getSettings().BgOpacity = tostring(BgOpacity)
                RGMercConfig:SaveSettings(true)
            end

            display_item_on_cursor()
        end

        ImGui.End()
    end
end

mq.imgui.init('RGMercsUI', RGMercsGUI)
mq.bind('/rgmercsui', function()
    openGUI = not openGUI
end)

local function Main()
    curState = "Idle..."

    if mq.TLO.MacroQuest.GameState() ~= "INGAME" then return end

    if RGMercConfig.CurLoadedChar ~= mq.TLO.Me.CleanName() then
        RGMercConfig:LoadSettings()
    end

    RGMercModules:execAll("GiveTime")
end

-- Global Messaging callback
---@diagnostic disable-next-line: unused-local
local script_actor = RGMercUtils.Actors.register(function(message)
    if message()["from"] == RGMercConfig.CurLoadedChar then return end
    if message()["script"] ~= RGMercUtils.ScriptName then return end

    RGMercsLogger.log_error("\ayGot Event from(\am%s\ay) module(\at%s\ay) event(\at%s\ay)", message()["from"],
        message()["module"],
        message()["event"])

    if message()["module"] then
        if message()["module"] == "main" then
            RGMercConfig:LoadSettings()
        else
            RGMercModules:getModuleList()[message()["module"]]:LoadSettings()
        end
    end
end)

while not terminate do
    Main()
    mq.doevents()
    mq.delay(10)
end

RGMercModules:execAll("Shutdown")
