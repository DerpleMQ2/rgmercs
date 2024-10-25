local StringUtils   = { _version = '1.0', _name = "StringUtils", _author = 'Derple', }
StringUtils.__index = StringUtils

function StringUtils.gsplit(text, pattern, plain)
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
function StringUtils.split(text, pattern, plain)
    local ret = {}
    if text ~= nil then
        for match in StringUtils.gsplit(text, pattern, plain) do
            table.insert(ret, match)
        end
    end
    return ret
end

--- Formats a given time according to the specified format string.
---
--- @param time number The time value to format.
--- @param formatString string? The format string to use for formatting the time.
--- @return string The formatted time as a string.
function StringUtils.FormatTime(time, formatString)
    local days = math.floor(time / 86400)
    local hours = math.floor((time % 86400) / 3600)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = math.floor((time % 60))
    return string.format(formatString and formatString or "%d:%02d:%02d:%02d", days, hours, minutes, seconds)
end

return StringUtils
