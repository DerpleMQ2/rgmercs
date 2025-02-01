Write = { _version = '1.1', }

Write.usecolors = true
Write.loglevel = 'info'
Write.prefix = ''

Write.loglevels = {
    ['trace'] = { level = 1, color = '\27[36m', mqcolor = '\at', abbreviation = 'TRACE', },
    ['debug'] = { level = 2, color = '\27[95m', mqcolor = '\am', abbreviation = 'DEBUG', },
    ['info']  = { level = 3, color = '\27[92m', mqcolor = '\ag', abbreviation = 'INFO', },
    ['warn']  = { level = 4, color = '\27[93m', mqcolor = '\ay', abbreviation = 'WARN', },
    ['error'] = { level = 5, color = '\27[31m', mqcolor = '\ao', abbreviation = 'ERROR', },
    ['fatal'] = { level = 6, color = '\27[91m', mqcolor = '\ar', abbreviation = 'FATAL', },
    ['help']  = { level = 7, color = '\27[97m', mqcolor = '\aw', abbreviation = 'HELP', },
}

Write.callstringlevel = Write.loglevels['debug'].level

local function Terminate()
    if package.loaded['mq'] then mq.exit() end
    os.exit()
end

local function GetColorStart(paramLogLevel)
    if Write.usecolors then
        if package.loaded['mq'] then return Write.loglevels[paramLogLevel].mqcolor end
        return Write.loglevels[paramLogLevel].color
    end
    return ''
end

local function GetColorEnd()
    if Write.usecolors then
        if package.loaded['mq'] then
            return '\ax'
        end
        return '\27[0m'
    end
    return ''
end

local function GetCallerString()
    if Write.loglevels[Write.loglevel:lower()].level > Write.callstringlevel then
        return ''
    end

    local callString = 'unknown'
    local callerInfo = debug.getinfo(4, 'Sl')
    if callerInfo and callerInfo.short_src ~= nil and callerInfo.short_src ~= '=[C]' then
        callString = string.format('%s::%s', callerInfo.short_src:match("[^\\^/]*.lua$"), callerInfo.currentline)
    end

    return string.format('(%s) ', callString)
end

local function Output(paramLogLevel, message)
    if Write.loglevels[Write.loglevel:lower()].level <= Write.loglevels[paramLogLevel].level then
        print(string.format('%s%s%s[%s]%s :: %s', type(Write.prefix) == 'function' and Write.prefix() or Write.prefix, GetCallerString(), GetColorStart(paramLogLevel),
            Write.loglevels[paramLogLevel].abbreviation, GetColorEnd(), message))
    end
end

function Write.Debug(message, ...)
    if (... ~= nil) then message = string.format(message, ...) end

    Output('debug', message)
end

function Write.Info(message, ...)
    if (... ~= nil) then message = string.format(message, ...) end

    Output('info', message)
end

function Write.Warn(message, ...)
    if (... ~= nil) then message = string.format(message, ...) end

    Output('warn', message)
end

function Write.Error(message, ...)
    if (... ~= nil) then message = string.format(message, ...) end

    Output('error', message)
end

function Write.Fatal(message, ...)
    if (... ~= nil) then message = string.format(message, ...) end

    Output('fatal', message)
    Terminate()
end

return Write
