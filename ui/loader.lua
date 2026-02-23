local mq             = require('mq')
local ImGui          = require('ImGui')
local ImagesUI       = require('ui.images')
local Config         = require('utils.config')
local Globals        = require('utils.globals')
local Ui             = require("utils.ui")

local LoaderUI       = { _version = '1.0', _name = "LoaderUI", _author = 'Derple', }
LoaderUI.__index     = LoaderUI
LoaderUI.Initialized = false

function LoaderUI:RenderLoader(initPctComplete, initMsg)
    if not self.Initialized then
        ImagesUI:InitLoader()
        self.Initialized = true
    end

    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 15)
    ImGui.PushStyleVar(ImGuiStyleVar.FrameRounding, 15)
    ImGui.PushStyleVar(ImGuiStyleVar.Alpha, 100)
    ImGui.SetNextWindowSize(ImVec2(400, 80), ImGuiCond.Always)
    ImGui.SetNextWindowPos(ImVec2(ImGui.GetIO().DisplaySize.x / 2 - 200, ImGui.GetIO().DisplaySize.y / 3 - 75), ImGuiCond.Always)

    ImGui.Begin("RGMercs Loader", nil,
        bit32.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoScrollbar, ImGuiWindowFlags.NoFocusOnAppearing))

    -- Display the selected image (picked only once)
    ImGui.Image(ImagesUI.imgDisplayed:GetTextureID(), ImVec2(60, 60))
    ImGui.SameLine()
    ImGui.Text("RGMercs %s: Loading...", Config._version)
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 35)
    ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 70)
    Ui.RenderAnimatedPercentage("RGMercsLoadProgressBar", initPctComplete, 16, Globals.Constants.Colors.LightBlue, Globals.Constants.Colors.LightGreen,
        Globals.Constants.Colors.Green, initMsg)
    ImGui.PopStyleVar(3)
    ImGui.End()
end

return LoaderUI
