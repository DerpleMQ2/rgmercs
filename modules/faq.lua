-- Sample FAQ Class Module
local mq                 = require('mq')
local RGMercUtils        = require("utils.rgmercs_utils")

local Module             = { _version = '0.1a', _name = "FAQ", _author = 'Grimmier', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultConfig     = {}
Module.DefaultCategories = {}
Module.FAQ               = {}
Module.TempSettings      = {}

local function getConfigFileName()
	local server = mq.TLO.EverQuest.Server()
	server = server:gsub(" ", "")
	return mq.configDir ..
		'/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. RGMercConfig.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
	mq.pickle(getConfigFileName(), self.settings)

	if doBroadcast == true then
		RGMercUtils.BroadcastUpdate(self._name, "LoadSettings")
	end
end

function Module:LoadSettings()
	RGMercsLogger.log_debug("FAQ Combat Module Loading Settings for: %s.", RGMercConfig.Globals.CurLoadedChar)
	local settings_pickle_path = getConfigFileName()

	local config, err = loadfile(settings_pickle_path)
	if err or not config then
		RGMercsLogger.log_error("\ay[FAQ]: Unable to load global settings file(%s), creating a new one!",
			settings_pickle_path)
		self.settings.MyCheckbox = false
		self:SaveSettings(false)
	else
		self.settings = config()
	end

	for _, v in pairs(Module.DefaultConfig or {}) do
		if v.Type ~= "Custom" then
			Module.DefaultCategories:add(v.Category)
		end
		Module.FAQ[_] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', settingName = _, }
	end

	local settingsChanged = false
	-- Setup Defaults
	self.settings, settingsChanged = RGMercUtils.ResolveDefaults(self.DefaultConfig, self.settings)

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
	RGMercsLogger.log_debug("FAQ Combat Module Loaded.")
	self:LoadSettings()

	return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:ShouldRender()
	return true
end

function Module:Render()
	ImGui.Text("FAQ Module")
	Module.TempSettings.Search, _ = ImGui.InputText("Search", Module.TempSettings.Search or "")

	if ImGui.CollapsingHeader("FAQ Commands") then
		if ImGui.BeginTable("CommandHelp", 3, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.ScrollY, ImGuiTableFlags.Resizable), ImVec2(0.0, 0.0)) then
			ImGui.TableSetupColumn("Command")
			ImGui.TableSetupColumn("Usage")
			ImGui.TableSetupColumn("Description")
			ImGui.TableSetupScrollFreeze(0, 1)
			ImGui.TableHeadersRow()
			for c, d in pairs(RGMercsBinds.Handlers) do
				if c ~= "help" then
					if (Module.TempSettings.Search ~= "" and (string.find(d.usage:lower(), Module.TempSettings.Search) or
							string.find(d.about:lower(), Module.TempSettings.Search or string.find(c:lower(), Module.TempSettings.Search)))) or Module.TempSettings.Search == "" then
						ImGui.TableNextColumn()
						ImGui.Text(c)
						ImGui.TableNextColumn()
						ImGui.Text(d.usage)
						ImGui.TableNextColumn()
						ImGui.PushTextWrapPos((ImGui.GetWindowContentRegionWidth() - 15) or 15)
						ImGui.Text(d.about)
					end
				end
			end

			local moduleCommands = RGMercModules:ExecAll("GetCommandHandlers")

			for _, info in pairs(moduleCommands) do
				if info.CommandHandlers then
					for c, d in pairs(info.CommandHandlers or {}) do
						if (Module.TempSettings.Search ~= "" and (string.find(d.usage:lower(), Module.TempSettings.Search) or
								string.find(d.about:lower(), Module.TempSettings.Search or string.find(c:lower(), Module.TempSettings.Search)))) or Module.TempSettings.Search == "" then
							ImGui.TableNextRow()
							ImGui.TableNextColumn()
							ImGui.Text(c)
							ImGui.TableNextColumn()
							ImGui.Text(d.usage)
							ImGui.TableNextColumn()
							ImGui.TextWrapped(d.about)
						end
					end
				end
			end
			ImGui.EndTable()
		end
	end

	if ImGui.CollapsingHeader("FAQ Questions") then
		local questions = RGMercModules:ExecAll("GetFAQ")
		if ImGui.BeginTable("FAQ", 3, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.ScrollY, ImGuiTableFlags.Resizable), ImVec2(0.0, 0.0)) then
			ImGui.TableSetupColumn("SettingName")
			ImGui.TableSetupColumn("Question")
			ImGui.TableSetupColumn("Answer")
			ImGui.TableSetupScrollFreeze(0, 1)
			ImGui.TableHeadersRow()
			if questions ~= nil then
				for _, info in pairs(questions or {}) do
					if info.FAQ then
						for c, d in pairs(info.FAQ or {}) do
							if (Module.TempSettings.Search ~= "" and (string.find(d.settingName:lower(), Module.TempSettings.Search) or
									string.find(d.Question:lower(), Module.TempSettings.Search or string.find(d.Answer:lower(), Module.TempSettings.Search)))) or Module.TempSettings.Search == "" then
								ImGui.TableNextRow()
								ImGui.TableNextColumn()
								ImGui.Text(d.settingName)
								ImGui.TableNextColumn()
								ImGui.TextWrapped(d.Question)
								ImGui.TableNextColumn()
								ImGui.TextWrapped(d.Answer)
							end
						end
					end
				end
			end
			ImGui.EndTable()
		end
	end
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
	return { module = self._name, FAQ = self.FAQ, }
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
	RGMercsLogger.log_debug("FAQ Combat Module Unloaded.")
end

return Module
