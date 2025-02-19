Write = { _version = '1.1', }

Write.usecolors = true
Write.loglevel = 'info'
Write.prefix = ''

Write.loglevels = {
    ['debug'] = { level = 1, color = '\27[95m', mqcolor = '\am', abbreviation = 'DEBUG', },
    ['info']  = { level = 2, color = '\27[92m', mqcolor = '\ag', abbreviation = 'INFO', },
    ['warn']  = { level = 3, color = '\27[93m', mqcolor = '\ay', abbreviation = 'WARN', },
    ['trace'] = { level = 4, color = '\27[36m', mqcolor = '\at', abbreviation = 'TRACE', },
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

local function Output(paramLogLevel, console, message)
    if Write.loglevels[Write.loglevel:lower()].level <= Write.loglevels[paramLogLevel].level then
        local tStamp = string.format("\at[\ax\ay%s\ax\at]\ax ", os.date('%H:%M:%S'))
        if console ~= nil then
            console:AppendText(string.format('%s%s%s%s[%s]%s :: %s', type(Write.prefix) == 'function' and Write.prefix() or Write.prefix, tStamp, GetCallerString(),
                GetColorStart(paramLogLevel),
                Write.loglevels[paramLogLevel].abbreviation, GetColorEnd(), message))
            if Write.loglevels[paramLogLevel].level == 1 then
                print(string.format('%s%s%s%s[%s]%s :: %s', type(Write.prefix) == 'function' and Write.prefix() or Write.prefix, tStamp, GetCallerString(),
                    GetColorStart(paramLogLevel),
                    Write.loglevels[paramLogLevel].abbreviation, GetColorEnd(), message))
            end
        else
            print(string.format('%s%s%s%s[%s]%s :: %s', type(Write.prefix) == 'function' and Write.prefix() or Write.prefix, tStamp, GetCallerString(), GetColorStart(paramLogLevel),
                Write.loglevels[paramLogLevel].abbreviation, GetColorEnd(), message))
        end
    end
end

---comment
---@param console any @The console to write to, if nil then we will default to mq main console
---@param message string|table @The message to write to the console, if you send a table we will output key: value pairs
---@param ... any @Any additional parameters to format the message used for string messages for formating
function Write.Debug(console, message, ...)
    if type(message) == 'string' then
        if (... ~= nil) then message = string.format(message, ...) end

        Output('debug', console, message)
    end
    if type(message) == 'table' then
        local dbgMessage = ''
        for k, v in pairs(message) do
            dbgMessage = string.format("%s \ao%s\ax: \at%s\ax", dbgMessage, k, tostring(v))
        end
        Output('debug', console, dbgMessage)
    end
end

---@param console any @The console to write to, if nil then we will default to mq main console
---@param message string|table @The message to write to the console, if you send a table we will output key: value pairs
---@param ... any @Any additional parameters to format the message used for string messages for formating
function Write.Info(console, message, ...)
    if type(message) == 'string' then
        if (... ~= nil) then message = string.format(message, ...) end

        Output('info', console, message)
    end
    if type(message) == 'table' then
        local dbgMessage = ''
        for k, v in pairs(message) do
            dbgMessage = string.format("%s \ao%s\ax: \at%s\ax", dbgMessage, k, tostring(v))
        end
        Output('info', console, dbgMessage)
    end
end

---@param console any @The console to write to, if nil then we will default to mq main console
---@param message string|table @The message to write to the console, if you send a table we will output key: value pairs
---@param ... any @Any additional parameters to format the message used for string messages for formating
function Write.Warn(console, message, ...)
    if type(message) == 'string' then
        if (... ~= nil) then message = string.format(message, ...) end

        Output('warn', console, message)
    end
    if type(message) == 'table' then
        local dbgMessage = ''
        for k, v in pairs(message) do
            dbgMessage = string.format("%s \ao%s\ax: \at%s\ax", dbgMessage, k, tostring(v))
        end
        Output('warn', console, dbgMessage)
    end
end

---@param console any @The console to write to, if nil then we will default to mq main console
---@param message string|table @The message to write to the console, if you send a table we will output key: value pairs
---@param ... any @Any additional parameters to format the message used for string messages for formating
function Write.Error(console, message, ...)
    if type(message) == 'string' then
        if (... ~= nil) then message = string.format(message, ...) end

        Output('error', console, message)
    end
    if type(message) == 'table' then
        local dbgMessage = ''
        for k, v in pairs(message) do
            dbgMessage = string.format("%s \ao%s\ax: \at%s\ax", dbgMessage, k, tostring(v))
        end
        Output('error', console, dbgMessage)
    end
end

---@param console any @The console to write to, if nil then we will default to mq main console
---@param message string|table @The message to write to the console, if you send a table we will output key: value pairs
---@param ... any @Any additional parameters to format the message used for string messages for formating
function Write.Fatal(console, message, ...)
    if type(message) == 'string' then
        if (... ~= nil) then message = string.format(message, ...) end

        Output('error', console, message)
    end
    if type(message) == 'table' then
        local dbgMessage = ''
        for k, v in pairs(message) do
            dbgMessage = string.format("%s \ao%s\ax: \at%s\ax", dbgMessage, k, tostring(v))
        end
        Output('error', console, dbgMessage)
    end
    Terminate()
end

return Write
