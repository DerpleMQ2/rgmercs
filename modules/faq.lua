-- Sample FAQ Class Module
local mq                 = require('mq')
local RGMercUtils        = require("utils.rgmercs_utils")
local Set                = require("mq.Set")

local Module             = { _version = '0.1a', _name = "FAQ", _author = 'Grimmier', }
Module.__index           = Module
Module.settings          = {}
Module.DefaultConfig     = {}
Module.DefaultCategories = {}
Module.FAQ               = {}
Module.ClassFAQ          = {}
Module.TempSettings      = {}
Module.DefaultCategories = Set.new({})
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

	for k, v in pairs(Module.DefaultConfig or {}) do
		if v.Type ~= "Custom" then
			Module.DefaultCategories:add(v.Category)
		end
		Module.FAQ[k] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', Settings_Used = k, }
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

function Module:MatchSearch(...)
	local allText = { ..., }
	for _, t in ipairs(allText) do
		if self.TempSettings.Search == "" or (t or ""):lower():find(self.TempSettings.Search) then
			return true
		end
	end
	return false
end

function Module:Render()
	ImGui.Text("FAQ Module")
	if not RGMercConfig.Globals.SubmodulesLoaded then
		return
	end

	ImGui.Text("Search")
	ImGui.SameLine()
	self.TempSettings.Search, _ = ImGui.InputText("##Search", self.TempSettings.Search or "")

	ImGui.SetNextWindowSizeConstraints(0, 0, ImGui.GetWindowWidth(), 600)
	if ImGui.BeginChild("##FAQCommandContainer", ImVec2(0, 0), ImGuiChildFlags.Border, ImGuiWindowFlags.AlwaysAutoResize) then
		if ImGui.CollapsingHeader("FAQ Commands") then
			if ImGui.BeginTable("##CommandHelper", 3, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable), ImVec2(ImGui.GetWindowWidth() - 30, 0)) then
				ImGui.TableSetupColumn("Command", ImGuiTableColumnFlags.WidthFixed, 100)
				ImGui.TableSetupColumn("Usage", ImGuiTableColumnFlags.WidthFixed, 200)
				ImGui.TableSetupColumn("Description", ImGuiTableColumnFlags.WidthStretch)
				ImGui.TableSetupScrollFreeze(0, 1)
				ImGui.TableHeadersRow()
				for cmd, data in pairs(RGMercsBinds.Handlers) do
					if cmd ~= "help" then
						if self:MatchSearch(data.usage, data.about, cmd) then
							ImGui.TableNextColumn()
							ImGui.Text(cmd)
							ImGui.TableNextColumn()
							ImGui.Text(data.usage)
							ImGui.TableNextColumn()
							ImGui.TextWrapped(data.about)
						end
					end
				end

				local moduleCommands = RGMercModules:ExecAll("GetCommandHandlers")

				for module, info in pairs(moduleCommands) do
					if info.CommandHandlers then
						for cmd, data in pairs(info.CommandHandlers or {}) do
							if self:MatchSearch(data.usage, data.about, cmd, module) then
								ImGui.TableNextColumn()
								ImGui.Text(cmd)
								ImGui.TableNextColumn()
								ImGui.Text(data.usage)
								ImGui.TableNextColumn()
								ImGui.TextWrapped(data.about)
							end
						end
					end
				end
				ImGui.EndTable()
			end
		end

		if ImGui.CollapsingHeader("FAQ Questions") then
			local questions = RGMercModules:ExecAll("GetFAQ")
			if ImGui.BeginTable("FAQ", 3, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable), ImVec2(ImGui.GetWindowWidth() - 30, 0)) then
				ImGui.TableSetupColumn("SettingName", ImGuiTableColumnFlags.WidthFixed, 100)
				ImGui.TableSetupColumn("Question", ImGuiTableColumnFlags.WidthFixed, 200)
				ImGui.TableSetupColumn("Answer", ImGuiTableColumnFlags.WidthStretch)
				ImGui.TableSetupScrollFreeze(0, 1)
				ImGui.TableHeadersRow()
				if questions ~= nil then
					for module, info in pairs(questions or {}) do
						if info.FAQ then
							for _, data in pairs(info.FAQ or {}) do
								if self:MatchSearch(data.Question, data.Answer, data.Settings_Used, module) then
									ImGui.TableNextRow()
									ImGui.TableNextColumn()
									ImGui.Text(data.Settings_Used)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Question)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Answer)
								end
							end
						end
					end
				end
				ImGui.EndTable()
			end
		end

		if ImGui.CollapsingHeader("FAQ Class Config") then
			local classFaq = RGMercModules:ExecAll("GetClassFAQ")
			if ImGui.BeginTable("FAQClass", 3, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable), ImVec2(ImGui.GetWindowWidth() - 30, 0)) then
				ImGui.TableSetupColumn("SettingName", ImGuiTableColumnFlags.WidthFixed, 100)
				ImGui.TableSetupColumn("Question", ImGuiTableColumnFlags.WidthFixed, 200)
				ImGui.TableSetupColumn("Answer", ImGuiTableColumnFlags.WidthStretch)
				ImGui.TableSetupScrollFreeze(0, 1)
				ImGui.TableHeadersRow()
				if classFaq ~= nil then
					for module, info in pairs(classFaq or {}) do
						if info.FAQ then
							for _, data in pairs(info.FAQ or {}) do
								if self:MatchSearch(data.Question, data.Answer, data.Settings_Used, module) then
									ImGui.TableNextRow()
									ImGui.TableNextColumn()
									ImGui.Text(data.Settings_Used)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Question)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Answer)
								end
							end
						end
					end
				end
				ImGui.EndTable()
			end
		end

		if ImGui.CollapsingHeader("FAQ Class Config") then
			local classFaq = RGMercModules:ExecAll("GetClassFAQ")
			if ImGui.BeginTable("FAQClass", 3, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable), ImVec2(ImGui.GetWindowWidth() - 30, 0)) then
				ImGui.TableSetupColumn("SettingName", ImGuiTableColumnFlags.WidthFixed, 100)
				ImGui.TableSetupColumn("Question", ImGuiTableColumnFlags.WidthFixed, 200)
				ImGui.TableSetupColumn("Answer", ImGuiTableColumnFlags.WidthStretch)
				ImGui.TableSetupScrollFreeze(0, 1)
				ImGui.TableHeadersRow()
				if classFaq ~= nil then
					for module, info in pairs(classFaq or {}) do
						if info.FAQ then
							for _, data in pairs(info.FAQ or {}) do
								if self:MatchSearch(data.Question, data.Answer, data.settingName, module) then
									ImGui.TableNextRow()
									ImGui.TableNextColumn()
									ImGui.Text(data.settingName)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Question)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Answer)
								end
							end
						end
					end
				end
				ImGui.EndTable()
			end
		end
		ImGui.EndChild()
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
	RGMercsLogger.log_debug("FAQ Combat Module Unloaded.")
end

return Module
