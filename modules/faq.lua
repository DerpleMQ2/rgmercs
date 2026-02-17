-- Sample FAQ Class Module
local mq            = require('mq')
local Config        = require('utils.config')
local Globals       = require('utils.globals')
local Ui            = require('utils.ui')
local Comms         = require("utils.comms")
local Logger        = require("utils.logger")
local Binds         = require("utils.binds")
local Modules       = require("utils.modules")
local Strings       = require("utils.strings")
local Base          = require("modules.base")

local Module        = { _version = '0.1a', _name = "FAQ", _author = 'Grimmier', }
Module.__index      = Module
Module.TempSettings = {}
setmetatable(Module, { __index = Base, })

Module.DefaultConfig   = {
	[string.format("%s_Popped", Module._name)] = {
		DisplayName = Module._name .. " Popped",
		Type = "Custom",
		Default = false,
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

Module.FAQ             = {
	{
		Question = "How do I broadcast commands to other PCs on my network?",
		Answer = "  In short, however you would prefer to.\n\n" ..
			"  While it is typical to use MQ2DanNet (or \"DanNet\" for short, a networking plugin included with MQ), other broadcasting solutions (such as EQBCS or E3BCA) should function without issue.\n\n" ..
			"  RGMercs defaults to using DanNet for some PC-to-PC functions (such as buff or vital checking) to avoid undesired targeting.\n\n" ..
			"  Note that certain commands such as \"pauseall\" or the \"say\" style commands will broadcast to multiple PCs, but they explicitly state so in tooltips or descriptions.\n\n" ..
			"  This feature is used sparingly, to allow users agency over what is broadcasted to their PCs.",
		Settings_Used = "",
	},
	{
		Question = "How do I assign a Main Assist in RGMercs?",
		Answer = "There are multiple ways to choose an assist in RGMercs:\n\n" ..
			"  If you are in a group, and have set the Main Assist role in the EQ group window, no further action is required.\n\n" ..
			"  If you are in a raid, and your raid leader has set one or more Raid Assists, use the Raid Assist Target setting (Options > Combat > Assisting) to select one to assist.\n\n" ..
			"  In all other situations (whether you are in a group, raid or not), you will use the Assist List found on the Main tab to set up who you are assisting. See the Assist List FAQ for more details.\n\n" ..
			"  Additionally, depending on the current Self-Assist Fallback setting (Options > Combat > Assisting), the PC may assign themsleves as MA if there is no valid (in-zone, alive, etc) MA." ..
			"As soon as a valid MA is identified, the PC will seamlessly change to assisting them again.",
		Settings_Used = "",
	},
	{
		Question = "How do I use the Assist List?",
		Answer = "First, find the Assist List UI on the Main tab, or familiarize yourself with related commands in the command list above.\n\n" ..
			"  Add characters as you see fit to this list. RGMercs will check the list in order and use the first valid PC it finds as the Main Assist. \n\n" ..
			"  The list can be reordered, cleared, or otherwise adjusted from this UI (or command-line), during downtime or combat, to change MAs on the fly.\n\n" ..
			"  To assign an MA using the Assist List, it must be enabled. If no assist is found, we will fallback to using ourselves as MA," ..
			"if we are configured to use Self-Assist Fallback (Options > Combat > Assisting).\n\n" ..
			"  In addition to being used as a list of potential assists, we will process group buff checks on valid members of the assist list, even if the list is not currently enabled.",
		Settings_Used = "",
	},
}

function Module:New()
	return Base.New(self)
end

function Module:ShouldRender()
	return false
end

function Module:SearchMatches(search)
	self.TempSettings.Search = search
	for cmd, data in pairs(Binds.Handlers) do
		if cmd ~= "help" then
			if self:MatchSearch(data.usage, data.about, cmd) then
				return true
			end
		end
	end

	local moduleCommands = Modules:ExecAll("GetCommandHandlers")

	for module, info in pairs(moduleCommands) do
		if info.CommandHandlers then
			for cmd, data in pairs(info.CommandHandlers or {}) do
				if self:MatchSearch(data.usage, data.about, cmd, module) then
					return true
				end
			end
		end
	end

	local questions = Modules:ExecAll("GetFAQ")
	local configFaq = {}

	if questions ~= nil then
		for _, info in pairs(questions or {}) do
			if info.FAQ then
				for _, data in pairs(info.FAQ or {}) do
					if self:MatchSearch(data.Question, data.Answer) then
						return true
					end
				end
			end
		end
	end

	configFaq.Config = Config:GetFAQ()
	if configFaq ~= nil then
		for _, v in pairs(configFaq.Config or {}) do
			if self:MatchSearch(v.Question, v.Answer) then
				return true
			end
		end
	end

	local classFaq = Modules:ExecModule("Class", "GetClassFAQ")
	if classFaq ~= nil then
		for _, v in pairs(classFaq.FAQ) do
			if self:MatchSearch(v.Question, v.Answer) then
				return true
			end
		end
	end

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
					fileContent = fileContent .. "* Answer:\n  " .. ((data.Answer or "TODO"):gsub("\n", " ") or "TODO") .. "\n\n"
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
			fileContent = fileContent .. "* Answer:\n  " .. ((v.Answer or "TODO"):gsub("\n", " ") or "TODO") .. "\n\n"
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
				local title = "RGMercs Lua Edition: FAQ - " .. (Globals.CurLoadedClass) .. " Class"
				local fileContent = "[[" .. title .. "]]\n\n"
				fileContent = fileContent .. "__FORCETOC__\n\n"
				fileContent = fileContent .. "== " .. title .. " ==\n\n"

				for _, data in pairs(info.FAQ) do
					if data.Question == 'None' then data.Question = data.Settings_Used or 'TODO' end
					fileContent = fileContent .. "=== " .. (data.Question or 'TODO') .. " ===\n"
					fileContent = fileContent .. "* Answer:\n  " .. ((data.Answer or "TODO"):gsub("\n", " ") or "TODO") .. "\n\n"
					fileContent = fileContent .. "* Settings Used:\n  " .. (data.Settings_Used or "None") .. "\n\n"
				end

				local classFileName = mq.configDir .. "/WIKI/" .. Globals.CurLoadedClass .. "_Class_FAQ.txt"
				local classFile = io.open(classFileName, "w")
				if classFile then
					classFile:write(fileContent)
					classFile:close()
				else
					print("Failed to open file for " .. Globals.CurLoadedClass)
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

	local classFaq = Modules:ExecModule("Class", "GetClassFAQ")
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

function Module:RenderCmdRow(cmd, usage, desc)
	ImGui.TableNextColumn()
	ImGui.TextColored(Globals.Constants.Colors.FAQCmdQuestionColor, cmd)
	ImGui.TableNextColumn()
	ImGui.TextColored(Globals.Constants.Colors.FAQUsageAnswerColor, usage)
	ImGui.TableNextColumn()
	ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.FAQDescColor)
	ImGui.TextWrapped(desc)
	ImGui.PopStyleColor()
	ImGui.Spacing()
end

function Module:RenderFAQRow(q, a)
	ImGui.TableNextRow()
	ImGui.TableNextColumn()
	ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.FAQCmdQuestionColor)
	ImGui.TextWrapped(q or "")
	ImGui.PopStyleColor()
	ImGui.TableNextColumn()
	ImGui.PushStyleColor(ImGuiCol.Text, Globals.Constants.Colors.FAQUsageAnswerColor)
	ImGui.TextWrapped(a or "")
	ImGui.PopStyleColor()
	ImGui.Spacing()
end

function Module:RenderConfig(search)
	if not Globals.SubmodulesLoaded then
		return
	end

	self.TempSettings.Search = search

	if ImGui.BeginChild("##FAQCommandContainer", ImVec2(0, 0), bit32.bor(ImGuiChildFlags.Borders, ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.AutoResizeY)) then
		if ImGui.CollapsingHeader("Command List") then
			if ImGui.BeginTable("##CommandHelper", 3, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable), ImVec2(ImGui.GetWindowWidth() - 30, 0)) then
				ImGui.TableSetupColumn("Command", ImGuiTableColumnFlags.WidthFixed, 100)
				ImGui.TableSetupColumn("Usage", ImGuiTableColumnFlags.WidthFixed, 200)
				ImGui.TableSetupColumn("Description", ImGuiTableColumnFlags.WidthStretch)
				ImGui.TableSetupScrollFreeze(0, 1)
				ImGui.TableHeadersRow()
				for cmd, data in pairs(Binds.Handlers) do
					if cmd ~= "help" then
						if self:MatchSearch(data.usage, data.about, cmd) then
							self:RenderCmdRow(cmd, data.usage, data.about)
						end
					end
				end

				local moduleCommands = Modules:ExecAll("GetCommandHandlers")

				for module, info in pairs(moduleCommands) do
					if info.CommandHandlers then
						for cmd, data in pairs(info.CommandHandlers or {}) do
							if self:MatchSearch(data.usage, data.about, cmd, module) then
								self:RenderCmdRow(cmd, data.usage, data.about)
							end
						end
					end
				end
				ImGui.EndTable()
			end
		end

		ImGui.NewLine()

		if Ui.NonCollapsingHeader("Frequently Asked Questions") then
			local questions = Modules:ExecAll("GetFAQ")
			local configFaq = {}

			if ImGui.BeginTable("FAQ", 2, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable), ImVec2(ImGui.GetWindowWidth() - 30, 0)) then
				ImGui.TableSetupColumn("Question", ImGuiTableColumnFlags.WidthFixed, 250)
				ImGui.TableSetupColumn("Answer", ImGuiTableColumnFlags.WidthStretch)
				ImGui.TableSetupScrollFreeze(0, 1)
				ImGui.TableHeadersRow()
				if questions ~= nil then
					for _, info in pairs(questions or {}) do
						if info.FAQ then
							for _, data in pairs(info.FAQ or {}) do
								if self:MatchSearch(data.Question, data.Answer) then
									self:RenderFAQRow(data.Question, data.Answer)
								end
							end
						end
					end
				end
				configFaq.Config = Config:GetFAQ()
				if configFaq ~= nil then
					for _, v in pairs(configFaq.Config or {}) do
						if self:MatchSearch(v.Question, v.Answer) then
							self:RenderFAQRow(v.Question, v.Answer)
						end
					end
				end
				local classFaq = Modules:ExecModule("Class", "GetClassFAQ")
				if classFaq ~= nil then
					for _, v in pairs(classFaq.FAQ) do
						if self:MatchSearch(v.Question, v.Answer) then
							self:RenderFAQRow(v.Question, v.Answer)
						end
					end
				end
				ImGui.EndTable()
			end
		end
	end
	ImGui.EndChild()
end

return Module
