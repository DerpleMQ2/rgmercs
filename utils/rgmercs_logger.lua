--- @type Mq
local mq              = require('mq')

local actions         = {}

local logLeaderStart  = '\ar[\ax\agRGMercs'
local logLeaderEnd    = '\ar]\ax\aw >>>'

--- @type number
local currentLogLevel = 3
local logToFileAlways = false

function actions.get_log_level() return currentLogLevel end

function actions.set_log_level(level) currentLogLevel = level end

function actions.set_log_to_file(logToFile) logToFileAlways = logToFile end

local logLevels = {
	['super_verbose'] = { level = 6, header = "\atSUPER\aw-\apVERBOSE\ax", },
	['verbose']       = { level = 5, header = "\apVERBOSE\ax", },
	['debug']         = { level = 4, header = "\amDEBUG  \ax", },
	['info']          = { level = 3, header = "\aoINFO   \ax", },
	['warn']          = { level = 2, header = "\ayWARN   \ax", },
	['error']         = { level = 1, header = "\arERROR  \ax", },
}

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

	-- only log out warnings and errors
	if logLevels[logLevel].level <= 2 or logToFileAlways then
		local fileOutput = output:gsub("\a.", "")
		local fileHeader = logLevels[logLevel].header:gsub("\a.", "")
		local fileTracer = callerTracer:gsub("\a.", "")
		mq.cmd(string.format('/mqlog [%s:%s(%s)] %s', mq.TLO.Me.Name(), fileHeader, fileTracer, fileOutput))
	end

	if RGMercsConsole ~= nil then
		local consoleText = string.format('[%s] %s', logLevels[logLevel].header, output)
		RGMercsConsole:AppendText(consoleText)
	end

	printf('%s\aw:%s\aw(%s\aw)%s \ax%s', logLeaderStart, logLevels[logLevel].header, callerTracer, logLeaderEnd, output)
end


function actions.log_error(output, ...)
	log('error', output, ...)
end

function actions.log_warning(output, ...)
	log('warn', output, ...)
end

function actions.log_info(output, ...)
	log('info', output, ...)
end

function actions.log_debug(output, ...)
	log('debug', output, ...)
end

function actions.log_verbose(output, ...)
	log('verbose', output, ...)
end

function actions.log_super_verbose(output, ...)
	log('super_verbose', output, ...)
end

return actions
