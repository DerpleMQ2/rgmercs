--- @type Mq
local mq = require('mq')

local actions = {}

local logLeader = '\ar[\agRGMercs\ar]\aw >>>'

--- @type number
local logLevel = 2

function actions.get_log_level() return logLevel end

function actions.set_log_level(level) logLevel = level end

function actions.log_error(output, ...)
	if (logLevel < 0) then
		return
	end

	if (... ~= nil) then output = string.format(output, ...) end
	mq.parse(string.format('/mqlog [%s] %s', mq.TLO.Me.Name(), output))
	printf('%s \ar %s', logLeader, output)
end

function actions.log(output, ...)
	if (logLevel < 1) then
		return
	end

	if (... ~= nil) then output = string.format(output, ...) end
	mq.parse(string.format('/mqlog [%s] %s', mq.TLO.Me.Name(), output))
	printf('%s \aw %s', logLeader, output)
end

function actions.log2(output, ...)
	if (logLevel < 2) then
		return
	end

	if (... ~= nil) then output = string.format(output, ...) end
	mq.parse(string.format('/mqlog [%s] %s', mq.TLO.Me.Name(), output))
	printf('%s \ao %s', logLeader, output)
end

function actions.debug_log(output, ...)
	if (logLevel < 3) then
		return
	end

	if (... ~= nil) then output = string.format(output, ...) end
	mq.cmd(string.format('/mqlog [%s] %s', mq.TLO.Me.Name(), output))
	printf('%s \ag %s', logLeader, output)
end

function actions.output_test_logs()
	actions.log_error("Test Error")
	actions.log("Test Warning")
	actions.log2("Test Normal")
	actions.debug_log("Test Debug")
end

return actions
