local Tables   = { _version = '1.0', _name = "Tables", _author = 'Derple', }
Tables.__index = Tables

--- Gets the size of a table.
--- @param t table The table whose size is to be determined.
--- @return number The size of the table.
function Tables.GetTableSize(t)
    local i = 0
    for _, _ in pairs(t) do i = i + 1 end
    return i
end

--- Checks if a table contains a specific value.
--- @param t table The table to search.
--- @param value any The value to search for in the table.
--- @return boolean True if the value is found in the table, false otherwise.
function Tables.TableContains(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

return Tables
