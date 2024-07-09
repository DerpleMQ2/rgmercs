--- @type Mq
local mq              = require('mq')
local RGMercUtils     = require("utils.rgmercs_utils")

local actions         = {}

local logFileOpened	  = ""
local logLeaderStart  = '\ar[\ax\agRGMercs'
local logLeaderEnd    = '\ar]\ax\aw >>>'

--- @type number
local currentLogLevel = 3
local logToFileAlways = false
local filters         = {}

local logFileHandle   = nil

function actions.get_log_level() return currentLogLevel end

function actions.set_log_level(level) currentLogLevel = level end

function actions.set_log_to_file(logToFile) logToFileAlways = logToFile end

function actions.set_log_filter(filter)
	filters = RGMercUtils.split(filter:lower(), "|")
end

function actions.clear_log_filter() filters = {} end

local logLevels = {
	['super_verbose'] = { level = 6, header = "\atSUPER\aw-\apVERBOSE\ax", },
	['verbose']       = { level = 5, header = "\apVERBOSE\ax", },
	['debug']         = { level = 4, header = "\amDEBUG  \ax", },
	['info']          = { level = 3, header = "\aoINFO   \ax", },
	['warn']          = { level = 2, header = "\ayWARN   \ax", },
	['error']         = { level = 1, header = "\arERROR  \ax", },
}

local function openLogFile()
	local logDir = mq.TLO.MacroQuest.Path().."/Logs/"
	local newFileName = string.format("RGMercs_%s.log", mq.TLO.Me.Name())
	local newFilePath = string.format("%s%s", logDir, newFileName)

	if logFileHandle and logFileOpened ~= newFilePath then
		logFileHandle:close()
		logFileHandle = nil
		logFileOpened = ""
	end

	if not logFileHandle then
		logFileHandle = io.open(newFilePath, "a")
		logFileOpened = newFilePath
		if not logFileHandle then
			mq.cmd("/echo Could not open log file for writing.")
		end
	end
end

local function getCallStack()
	local info = debug.getinfo(4, "Snl")

	local callerTracer = string.format("\ao%s\aw::\ao%s()\aw:\ao%-04d\ax",
		info and info.short_src and info.short_src:match("[^\\^/]*.lua$") or "unknown_file", info and info.name or "unknown_func", info and info.currentline or 0)

	return callerTracer
end

local function log(logLevel, output, ...)
	if currentLogLevel < logLevels[logLevel].level then return end

	local callerTracer = getCallStack()

	if (... ~= nil) then output = string.format(output, ...) end

	local now = string.format("%.03f", mq.gettime() / 1000)

	-- only log out warnings and errors
	if logLevels[logLevel].level <= 2 or logToFileAlways then
		local fileOutput = output:gsub("\a.", "")
		local fileHeader = logLevels[logLevel].header:gsub("\a.", "")
		local fileTracer = callerTracer:gsub("\a.", "")

		openLogFile()
		if logFileHandle then
			logFileHandle:write(string.format("[%s:%s(%s)] <%s> %s\n", mq.TLO.Me.Name(), fileHeader, fileTracer, now, fileOutput))
		end
	end

	if #filters > 0 then
		local found = false
		local lowerOutput = output:lower()
		for _, logFilter in ipairs(filters) do
			if logFilter:len() > 0 and (callerTracer:find(logFilter) or lowerOutput:find(logFilter)) then found = true end
		end

		if not found then return end
	end

	if RGMercsConsole ~= nil then
		local consoleText = string.format('[%s] %s', logLevels[logLevel].header, output)
		RGMercsConsole:AppendText(consoleText)
	end

	printf('%s\aw:%s \aw<\at%s\aw> \aw(%s\aw)%s \ax%s', logLeaderStart, logLevels[logLevel].header, now, callerTracer, logLeaderEnd, output)
end

function actions.GenerateShortcuts()
	for level, _ in pairs(logLevels) do
		--- @diagnostic disable-next-line
		actions["log_" .. level:lower()] = function(output, ...)
			log(level, output, ...)
		end
	end
end

actions.GenerateShortcuts()

return actions
