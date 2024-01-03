--- @type Mq
local mq              = require('mq')

local actions         = {}

local logLeaderStart  = '\ar[\ax\agRGMercs'
local logLeaderEnd    = '\ar]\ax\aw >>>'

--- @type number
local currentLogLevel = 3

function actions.get_log_level() return currentLogLevel end

function actions.set_log_level(level) currentLogLevel = level end

local logLevels = {
	['verbose'] = { level = 5, header = "\apVERBOSE\ax", },
	['debug']   = { level = 4, header = "\amDEBUG  \ax", },
	['info']    = { level = 3, header = "\aoINFO   \ax", },
	['warn']    = { level = 2, header = "\ayWARN   \ax", },
	['error']   = { level = 1, header = "\arERROR  \ax", },
}

local function getCallStack()
	local info = debug.getinfo(4, "Snl")

	local callerTracer = string.format("\ao%s\aw::\ao%s()\aw:\ao%-04d\ax",
		info.short_src and info.short_src:match("[^\\^/]*.lua$") or "unknown_file", info.name or "unknown_func", info.currentline)

	return callerTracer
end

local function log(logLevel, output, ...)
	if currentLogLevel < logLevels[logLevel].level then return end

	local callerTracer = getCallStack()

	if (... ~= nil) then output = string.format(output, ...) end

	mq.cmd(string.format('/mqlog [%s:%s(%s)] %s', mq.TLO.Me.Name(), logLevels[logLevel].header, callerTracer, output))

	printf('%s\a:%s\aw(%s\aw)%s \ax%s', logLeaderStart, logLevels[logLevel].header, callerTracer, logLeaderEnd, output)
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

return actions
