-- Sample FAQ Class Module
local mq               = require('mq')
local Config           = require('utils.config')
local Ui               = require("utils.ui")
local Comms            = require("utils.comms")
local Logger           = require("utils.logger")
local Binds            = require("utils.binds")
local Modules          = require("utils.modules")
local Set              = require("mq.Set")
local Strings          = require("utils.strings")

local Module           = { _version = '0.1a', _name = "FAQ", _author = 'Grimmier', }
Module.__index         = Module
Module.DefaultConfig   = {}
Module.FAQ             = {}
Module.ClassFAQ        = {}
Module.TempSettings    = {}
Module.SaveRequested   = nil

Module.DefaultConfig   = {
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

Module.CommandHandlers = {
	exportwiki = {
		usage = "/rgl exportwiki",
		about = "Export the FAQ to Wiki Files by Module.",
		handler = function(self, _)
			self:ExportFAQToWiki()
		end,
	},
}

local function getConfigFileName()
	local server = mq.TLO.EverQuest.Server()
	server = server:gsub(" ", "")
	return mq.configDir ..
		'/rgmercs/PCConfigs/' .. Module._name .. "_" .. server .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
end

function Module:SaveSettings(doBroadcast)
	self.SaveRequested = { time = os.time(), broadcast = doBroadcast or false, }
end

function Module:WriteSettings()
	if not self.SaveRequested then return end

	mq.pickle(getConfigFileName(), Config:GetModuleSettings(self._name))

	if self.SaveRequested.doBroadcast == true then
		Comms.BroadcastUpdate(self._name, "LoadSettings")
	end

	Logger.log_debug("\ag%s Module settings saved to %s, requested %s ago.", self._name, getConfigFileName(), Strings.FormatTime(os.time() - self.SaveRequested.time))

	self.SaveRequested = nil
end

function Module:LoadSettings()
	Logger.log_debug("FAQ Combat Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
	local settings_pickle_path = getConfigFileName()
	local settings = {}
	local firstSaveRequired = false

	local config, err = loadfile(settings_pickle_path)
	if err or not config then
		Logger.log_error("\ay[FAQ]: Unable to load global settings file(%s), creating a new one!",
			settings_pickle_path)
		firstSaveRequired = true
	else
		settings = config()
	end

	Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)
end

function Module.New()
	local newModule = setmetatable({}, Module)
	return newModule
end

function Module:Init()
	Logger.log_debug("FAQ Combat Module Loaded.")
	self:LoadSettings()

	return { self = self, defaults = self.DefaultConfig, }
end

function Module:ShouldRender()
	return false
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

function Module:ExportFAQToWiki()
	-- Fetch the FAQs for modules, commands, and class configurations
	local questions = Modules:ExecAll("GetFAQ")
	local commandFaq = Modules:ExecAll("GetCommandHandlers")
	local classFaq = Modules:ExecModule("Class", "GetClassFAQ")
	local configFaq = {}
	configFaq.Config = Config:GetFAQ()

	if not questions and not commandFaq then
		print("No FAQ data found.")
		return
	end

	-- Create a touch file to ensure the WIKI directory exists
	mq.pickle(mq.configDir .. "/WIKI/touch.lua", { 'NONE', })

	-- Export Module FAQs
	if questions then
		for module, info in pairs(questions) do
			if info.FAQ then
				local title = "RGMercs Lua Edition: FAQ - " .. module .. " Module"
				local fileContent = "[[" .. title .. "]]\n\n"
				fileContent = fileContent .. "__FORCETOC__\n\n"
				fileContent = fileContent .. "== " .. title .. " ==\n\n"

				for _, data in pairs(info.FAQ) do
					if data.Question == 'None' then data.Question = data.Settings_Used or 'TODO' end
					fileContent = fileContent .. "=== " .. (data.Question or 'TODO') .. " ===\n"
					fileContent = fileContent .. "* Answer:\n  " .. (data.Answer:gsub("\n", " ") or "TODO") .. "\n\n"
					fileContent = fileContent .. "* Settings Used:\n  " .. (data.Settings_Used or "None") .. "\n\n"
				end

				local fileName = mq.configDir .. "/WIKI/" .. module .. "_FAQ.txt"
				local file = io.open(fileName, "w")
				if file then
					file:write(fileContent)
					file:close()
				else
					print("Failed to open file for " .. module)
				end
			end
		end
	end

	if commandFaq then
		local commandFileContent = "== RGMercs Lua Edition: Commands FAQ ==\n\n"
		commandFileContent = commandFileContent .. "{| class=\"wikitable\"\n|-\n! Command !! Usage !! Description\n"

		for module, info in pairs(commandFaq) do
			if info.CommandHandlers then
				for cmd, data in pairs(info.CommandHandlers) do
					commandFileContent = commandFileContent .. "|-\n| " .. cmd .. " || " .. (data.usage or "TODO") .. " || " .. (data.about or "TODO") .. "\n"
				end
			end
		end

		commandFileContent = commandFileContent .. "|}\n"

		local commandFileName = mq.configDir .. "/WIKI/Commands_FAQ.txt"
		local commandFile = io.open(commandFileName, "w")
		if commandFile then
			commandFile:write(commandFileContent)
			commandFile:close()
		else
			print("Failed to open file for Commands FAQ")
		end
	end

	-- Export Default Config FAQs
	if configFaq then
		local title = "RGMercs Lua Edition: FAQ - Default Configurations"
		local fileContent = "[[" .. title .. "]]\n\n"
		fileContent = fileContent .. "__FORCETOC__\n\n"
		fileContent = fileContent .. "== " .. title .. " ==\n\n"
		for k, v in pairs(configFaq.Config) do
			if v.Question == 'None' then v.Question = v.Settings_Used or 'TODO' end
			fileContent = fileContent .. "=== " .. (v.Question or 'TODO') .. " ===\n"
			fileContent = fileContent .. "* Answer:\n  " .. (v.Answer:gsub("\n", " ") or "TODO") .. "\n\n"
			fileContent = fileContent .. "* Settings Used:\n  " .. (v.Settings_Used or "None") .. "\n\n"
		end
		local configFileName = mq.configDir .. "/WIKI/Default_Config_FAQ.txt"
		local configFile = io.open(configFileName, "w")
		if configFile then
			configFile:write(fileContent)
			configFile:close()
		else
			print("Failed to open file for Default Configurations")
		end
	end

	-- Export Class FAQs
	if classFaq then
		for module, info in pairs(classFaq) do
			if module:lower() == 'class' and info.FAQ then
				local title = "RGMercs Lua Edition: FAQ - " .. (Config.Globals.CurLoadedClass) .. " Class"
				local fileContent = "[[" .. title .. "]]\n\n"
				fileContent = fileContent .. "__FORCETOC__\n\n"
				fileContent = fileContent .. "== " .. title .. " ==\n\n"

				for _, data in pairs(info.FAQ) do
					if data.Question == 'None' then data.Question = data.Settings_Used or 'TODO' end
					fileContent = fileContent .. "=== " .. (data.Question or 'TODO') .. " ===\n"
					fileContent = fileContent .. "* Answer:\n  " .. (data.Answer:gsub("\n", " ") or "TODO") .. "\n\n"
					fileContent = fileContent .. "* Settings Used:\n  " .. (data.Settings_Used or "None") .. "\n\n"
				end

				local classFileName = mq.configDir .. "/WIKI/" .. Config.Globals.CurLoadedClass .. "_Class_FAQ.txt"
				local classFile = io.open(classFileName, "w")
				if classFile then
					classFile:write(fileContent)
					classFile:close()
				else
					print("Failed to open file for " .. Config.Globals.CurLoadedClass)
				end
			end
		end
	end
end

function Module:FaqFind(question)
	self.TempSettings.Search = question
	for cmd, data in pairs(Binds.Handlers) do
		if cmd ~= "help" then
			if self:MatchSearch(data.usage, data.about, cmd) then
				Logger.log_info("\ayCommand: \ax%s \aoUsage:\ax %s\nDescription: \at%s", cmd, data.usage, data.about)
				mq.delay(5) -- Delay to prevent spamming
			end
		end
	end

	local questions = Modules:ExecAll("GetFAQ")
	if questions ~= nil then
		for module, info in pairs(questions or {}) do
			if info.FAQ then
				for _, data in pairs(info.FAQ or {}) do
					if self:MatchSearch(data.Question, data.Answer, data.Settings_Used, module) then
						Logger.log_info("\ayModule:\ax %s \aoQuestion: \ax%s\nAnswer: \at%s", module, data.Question, data.Answer)
						mq.delay(5)
					end
				end
			end
		end
	end

	local classFaq = Modules:ExecMOdule("Class", "GetClassFAQ")
	if classFaq ~= nil then
		for module, info in pairs(classFaq or {}) do
			if info.FAQ then
				for _, data in pairs(info.FAQ or {}) do
					if self:MatchSearch(data.Question, data.Answer, data.Settings_Used, module) then
						Logger.log_info("\ayClass:\ax %s \aoQuestion:\ax %s\nAnswer:\at %s", module, data.Question, data.Answer)
						mq.delay(5)
					end
				end
			end
		end
	end
	self.TempSettings.Search = ''
end

function Module:RenderConfig()
	ImGui.Spacing()
	ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(1, 1, 0, 1))
	ImGui.Text("Local FAQ Browser Link")
	ImGui.PopStyleColor()
	local url = "file:///" .. mq.luaDir .. "/rgmercs/doc/index.html"
	url = url:gsub("\\", "/")
	if ImGui.IsItemHovered() then
		if ImGui.IsMouseClicked(ImGuiMouseButton.Left) then
			os.execute(('start "" "%s"'):format(url))
		end
		ImGui.BeginTooltip()
		ImGui.Text('%s', url)
		ImGui.EndTooltip()
	end

	if not Config.Globals.SubmodulesLoaded then
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
				for cmd, data in pairs(Binds.Handlers) do
					if cmd ~= "help" then
						if self:MatchSearch(data.usage, data.about, cmd) then
							ImGui.TableNextColumn()
							ImGui.Text(cmd)
							ImGui.TableNextColumn()
							ImGui.Text(data.usage)
							ImGui.TableNextColumn()
							ImGui.TextWrapped(data.about)
							ImGui.Spacing()
						end
					end
				end

				local moduleCommands = Modules:ExecAll("GetCommandHandlers")

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
								ImGui.Spacing()
							end
						end
					end
				end
				ImGui.EndTable()
			end
		end

		if ImGui.CollapsingHeader("FAQ General") then
			local questions = Modules:ExecAll("GetFAQ")
			local configFaq = {}

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
									ImGui.TextWrapped(data.Settings_Used)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Question)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Answer)
									ImGui.Spacing()
								end
							end
						end
					end
				end
				configFaq.Config = Config:GetFAQ()
				if configFaq ~= nil then
					for k, v in pairs(configFaq.Config or {}) do
						if self:MatchSearch(v.Question, v.Answer, v.Settings_Used, "Config") then
							ImGui.TableNextRow()
							ImGui.TableNextColumn()
							ImGui.TextWrapped(v.Settings_Used)
							ImGui.TableNextColumn()
							ImGui.TextWrapped(v.Question)
							ImGui.TableNextColumn()
							ImGui.TextWrapped(v.Answer)
							ImGui.Spacing()
						end
					end
				end
				ImGui.EndTable()
			end
		end

		if ImGui.CollapsingHeader("FAQ Class Config") then
			local classFaq = Modules:ExecModule("Class", "GetClassFAQ")
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
									ImGui.TextWrapped(data.Settings_Used)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Question)
									ImGui.TableNextColumn()
									ImGui.TextWrapped(data.Answer)
									ImGui.Spacing()
								end
							end
						end
					end
				end
				ImGui.EndTable()
			end
		end
	end
	ImGui.EndChild()
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
	return { module = self._name, CommandHandlers = self.CommandHandlers, }
end

function Module:Pop()
	Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
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

	if self.CommandHandlers[cmd:lower()] ~= nil then
		self.CommandHandlers[cmd:lower()].handler(self, params)
		handled = true
	end

	return handled
end

function Module:Shutdown()
	Logger.log_debug("FAQ Combat Module Unloaded.")
end

return Module
