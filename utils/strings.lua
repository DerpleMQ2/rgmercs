local Strings   = { _version = '1.0', _name = "Strings", _author = 'Derple', }
Strings.__index = Strings

function Strings.gsplit(text, pattern, plain)
    local splitStart, length = 1, #text
    return function()
        if splitStart > 0 then
            local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
            local ret
            if not sepStart then
                ret = string.sub(text, splitStart)
                splitStart = 0
            elseif sepEnd < sepStart then
                -- Empty separator!
                ret = string.sub(text, splitStart, sepStart)
                if sepStart < length then
                    splitStart = sepStart + 1
                else
                    splitStart = 0
                end
            else
                ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ''
                splitStart = sepEnd + 1
            end
            return ret
        end
    end
end

--- Splits a given text into a table of substrings based on a specified pattern.
---
--- @param text string: The text to be split.
--- @param pattern string: The pattern to split the text by.
--- @param plain boolean?: If true, the pattern is treated as a plain string.
--- @return table: A table containing the substrings.
function Strings.split(text, pattern, plain)
    local ret = {}
    if text ~= nil then
        for match in Strings.gsplit(text, pattern, plain) do
            table.insert(ret, match)
        end
    end
    return ret
end

--- Formats a given time
---
--- @param time number The time value to format.
--- @return string The formatted time as a string.
function Strings.FormatTime(time)
    local timeTable = Strings.GetTimeAsTable(time)

    return string.format("%d:%02d:%02d:%02d", timeTable.Days, timeTable.Hours, timeTable.Mins, timeTable.Secs)
end

--- Returns the current time as a table.
---
--- @param time number The time value to format.
--- @return table The time as a table with days, hours, minutes, and seconds.
function Strings.GetTimeAsTable(time)
    local days = math.floor(time / 86400)
    local hours = math.floor((time % 86400) / 3600)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = math.floor((time % 60))
    return { Days = days, Hours = hours, Mins = minutes, Secs = seconds, }
end

--- Formats a given time according to the specified format string.
---
--- @param time number The time value to format.
--- @param formatString string? The format string to use for formatting the time.
--- @return string The formatted time as a string.
function Strings.FormatTimeMS(time, formatString)
    -- Convert milliseconds to seconds6
    local milliseconds = time % 1000
    return string.format(formatString and formatString or "%-3dms", milliseconds)
end

--- Converts a boolean value to its string representation.
--- @param b boolean: The boolean value to convert.
--- @return string: "true" if the boolean is true, "false" otherwise.
function Strings.BoolToString(b)
    if type(b) ~= "boolean" then
        return "\ayNOT A BOOL\ax"
    end

    return b and "true" or "false"
end

--- Converts a boolean value to a color string.
--- If the boolean is true, it returns "green", otherwise "red".
--- @param b boolean: The boolean value to convert.
--- @return string: The color string corresponding to the boolean value.
function Strings.BoolToColorString(b)
    if type(b) ~= "boolean" then
        return "\ayNOT A BOOL\ax"
    end

    return b and "\agtrue\ax" or "\arfalse\ax"
end

local function dumpTable(o, depth, accLen)
    accLen = accLen or 0
    if not depth then depth = 0 end
    if type(o) == 'table' then
        local s = '{'
        accLen = accLen + #s
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            local entry = string.rep(" ", depth) .. ' [' .. k .. '] = '
            local valueStr = dumpTable(v, depth + 1, accLen + #entry)
            entry = entry .. valueStr .. ', '
            s = s .. entry
            accLen = accLen + #entry
            if accLen >= 40 then
                return s .. '...}'
            end
        end
        return s .. string.rep(" ", depth) .. '}'
    else
        local str = tostring(o)
        accLen = accLen + #str
        if accLen >= 40 then
            return str:sub(1, 40 - (accLen - #str)) .. '...'
        end
        return str
    end
end

--- Converts a table value to its string representation.
--- @param t table: The boolean value to convert.
--- @return string: "true" if the boolean is true, "false" otherwise.
function Strings.TableToString(t)
    if type(t) ~= "table" then
        return "{}"
    end

    return dumpTable(t)
end

--- Pads a string to a specified length with a given character.
---
--- @param string string The original string to be padded.
--- @param len number The desired length of the resulting string.
--- @param padFront boolean If true, padding is added to the front of the string; otherwise, it is added to the back.
--- @param padChar string? The character to use for padding. Defaults to a space if not provided.
--- @return string The padded string.
function Strings.PadString(string, len, padFront, padChar)
    if not padChar then padChar = " " end
    local cleanText = string:gsub("\a[-]?.", "")

    local paddingNeeded = len - cleanText:len()

    for _ = 1, paddingNeeded do
        if padFront then
            string = padChar .. string
        else
            string = string .. padChar
        end
    end

    return string
end

return Strings
