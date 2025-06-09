local Console             = require('utils.console')
local Config              = require('utils.config')
local Ui                  = require('utils.ui')
local Icons               = require('mq.ICONS')
local Logger              = require("utils.logger")

local ConsoleUI           = { _version = '1.0', _name = "ConsoleUI", _author = 'Derple', }
ConsoleUI.__index         = ConsoleUI
ConsoleUI.logFilter       = Config:GetSetting('LastFilter') or ""
ConsoleUI.logFilterLocked = true
ConsoleUI.logToConsole    = Config:GetSetting('LogToMQConsole')
ConsoleUI.logToFile       = Config:GetSetting('LogToFile')

Logger.set_log_to_mq_console(ConsoleUI.logToConsole)

if ConsoleUI.logFilter:len() == 0 then
    Logger.clear_log_filter()
else
    Logger.set_log_filter(ConsoleUI.logFilter)
end

function ConsoleUI:DrawConsole(showPopout)
    local RGMercsConsole = Console:GetConsole("##RGMercs", Config:GetMainOpacity())

    if RGMercsConsole then
        if showPopout then
            if ImGui.SmallButton(Icons.MD_OPEN_IN_NEW) then
                Config:SetSetting('PopOutConsole', true)
            end
            Ui.Tooltip("Pop the Console out into its own window.")
            ImGui.NewLine()
        end

        local changed
        if ImGui.CollapsingHeader("Console Options", ImGuiTreeNodeFlags.DefaultOpen) then
            if ImGui.BeginTable("##debugoptions", 2, ImGuiTableFlags.None) then
                ImGui.TableSetupColumn("Opt Name", bit32.bor(ImGuiTableColumnFlags.WidthFixed, ImGuiTableColumnFlags.NoResize), 100)
                ImGui.TableSetupColumn("Opt Value", ImGuiTableColumnFlags.WidthStretch)
                ImGui.TableNextColumn()
                Config:GetSettings().LogToFile, changed = Ui.RenderOptionToggle("##log_to_file",
                    "", Config:GetSettings().LogToFile)
                if changed then
                    Config:SaveSettings()
                end
                ImGui.TableNextColumn()
                ImGui.Text("Log to File")
                ImGui.TableNextColumn()

                Config:GetSettings().LogToMQConsole, changed = Ui.RenderOptionToggle("##log_to_mq_console",
                    "", Config:GetSettings().LogToMQConsole)
                if changed then
                    Config:SaveSettings()
                end
                ImGui.TableNextColumn()
                ImGui.Text("Log to Console")
                ImGui.TableNextColumn()
                ImGui.Text("Debug Level")
                ImGui.TableNextColumn()
                Config:GetSettings().LogLevel, changed = ImGui.Combo("##Debug Level",
                    Config:GetSettings().LogLevel, Config.Constants.LogLevels,
                    #Config.Constants.LogLevels)

                if changed then
                    Config:SaveSettings()
                end
                ImGui.TableNextColumn()
                ImGui.Text("Log Filter")
                ImGui.SameLine()
                if ImGui.Button(self.logFilterLocked and Icons.FA_LOCK or Icons.FA_UNLOCK, 22, 22) then
                    self.logFilterLocked = not self.logFilterLocked
                    if self.logFilterLocked then
                        Config:SetSetting('LastFilter', self.logFilter)
                        Config:SetSetting('LogToMQConsole', self.logToConsole)
                        Config:SetSetting('LogToFile', self.logToFile)
                    end
                end
                ImGui.TableNextColumn()
                ImGui.BeginDisabled(self.logFilterLocked)

                self.logFilter, changed = ImGui.InputText("##logfilter", self.logFilter)

                ImGui.EndDisabled()

                if changed then
                    if self.logFilter:len() == 0 then
                        Logger.clear_log_filter()
                    else
                        Logger.set_log_filter(self.logFilter)
                    end
                    Config:SetSetting('LastFilter', self.logFilter)
                end
                ImGui.EndTable()
            end
        end
        if ImGui.CollapsingHeader("RGMercs Output", ImGuiTreeNodeFlags.DefaultOpen) then
            local cur_x, cur_y = ImGui.GetCursorPos()
            local contentSizeX, contentSizeY = ImGui.GetContentRegionAvail()
            if not RGMercsConsole.opacity then
                local scroll = ImGui.GetScrollY()
                ImGui.Dummy(contentSizeX, 410)
                ImGui.SetCursorPos(cur_x, cur_y)
                RGMercsConsole:Render(ImVec2(contentSizeX, contentSizeY - 5))
            else
                RGMercsConsole:Render(ImVec2(contentSizeX, (contentSizeY - 5)))
            end
            ImGui.Separator()
        end
    end
end

return ConsoleUI
