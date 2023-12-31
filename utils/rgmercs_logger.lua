--- @type Mq
local mq             = require('mq')

local actions        = {}

local logLeaderStart = '\ar[\agRGMercs'
local logLeaderEnd   = '\ar]\aw >>>'

--- @type number
local logLevel       = 3

function actions.get_log_level() return logLevel end

function actions.set_log_level(level) logLevel = level end

function actions.log_error(output, ...)
	if (logLevel < 0) then
		return
	end

	if (... ~= nil) then output = string.format(output, ...) end
	mq.parse(string.format('/mqlog [%s] %s', mq.TLO.Me.Name(), output))
	printf('%s:\arERROR\ax%s \aw%s', logLeaderStart, logLeaderEnd, output)
end

function actions.log_warning(output, ...)
	if (logLevel < 1) then
		return
	end

	if (... ~= nil) then output = string.format(output, ...) end
	mq.parse(string.format('/mqlog [%s] %s', mq.TLO.Me.Name(), output))
	printf('%s:\ayWARN\ax%s \aw%s', logLeaderStart, logLeaderEnd, output)
end

function actions.log_info(output, ...)
	if (logLevel < 2) then
		return
	end

	if (... ~= nil) then output = string.format(output, ...) end
	mq.parse(string.format('/mqlog [%s] %s', mq.TLO.Me.Name(), output))
	printf('%s:\agINFO\ax%s \aw%s', logLeaderStart, logLeaderEnd, output)
end

function actions.log_debug(output, ...)
	if (logLevel < 3) then
		return
	end

	local info = debug.getinfo(2, "nl")

	local callerTracer = string.format("\aw<\ay%s()\aw:\ay%d\aw>\ax", info.name, info.currentline)

	if (... ~= nil) then output = string.format(output, ...) end
	mq.cmd(string.format('/mqlog [%s] %s', mq.TLO.Me.Name(), output))
	printf('%s:\amDEBUG::%s\ax%s \aw%s', logLeaderStart, callerTracer, logLeaderEnd, output)
end

function actions.log_verbose(output, ...)
	if (logLevel < 4) then
		return
	end

	local info = debug.getinfo(2, "nl")

	local callerTracer = string.format("\aw<\ay%s()\aw:\ay%d\aw>\ax", info.name, info.currentline)

	if (... ~= nil) then output = string.format(output, ...) end
	mq.cmd(string.format('/mqlog [%s] %s', mq.TLO.Me.Name(), output))
	printf('%s:\apVERBOSE::%s\ax%s \aw%s', logLeaderStart, callerTracer, logLeaderEnd, output)
end

return actions
