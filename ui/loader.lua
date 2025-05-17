local mq         = require('mq')
local ImGui      = require('ImGui')
local ImagesUI   = require('ui.images')
local Config     = require('utils.config')

local LoaderUI   = { _version = '1.0', _name = "LoaderUI", _author = 'Derple', }
LoaderUI.__index = LoaderUI

function LoaderUI:RenderLoader(initPctComplete, initMsg)
    ImagesUI:InitLoader()

    ImGui.SetNextWindowSize(ImVec2(400, 80), ImGuiCond.Always)
    ImGui.SetNextWindowPos(ImVec2(ImGui.GetIO().DisplaySize.x / 2 - 200, ImGui.GetIO().DisplaySize.y / 3 - 75), ImGuiCond.Always)

    ImGui.Begin("RGMercs Loader", nil, bit32.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoScrollbar))

    -- Display the selected image (picked only once)
    ImGui.Image(ImagesUI.imgDisplayed:GetTextureID(), ImVec2(60, 60))
    ImGui.SameLine()
    ImGui.Text("RGMercs %s: Loading...", Config._version)
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 35)
    ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 70)
    ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0.2, 0.7, 1 - (initPctComplete / 100), initPctComplete / 100)
    ImGui.ProgressBar(initPctComplete / 100, ImVec2(310, 0), initMsg)
    ImGui.PopStyleColor()
    ImGui.End()
end

return LoaderUI
