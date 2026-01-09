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

--- Converts an ImVec4 to a table.
--- @param vec ImVec4 The ImVec4 to convert.
--- @return table|nil The converted table with x, y, z, w keys.
function Tables.ImVec4ToTable(vec)
    if not vec then return nil end
    return { x = vec.x, y = vec.y, z = vec.z, w = vec.w, }
end

--- Converts an ImVec4 to a table.
--- @param t table The table to convert.
--- @return table|nil The converted table with x, y, z, w keys.
function Tables.TableRGBAToXYZW(t)
    if not t then return nil end
    return { x = t.r, y = t.g, z = t.b, w = t.a, }
end

--- Converts a table to an ImVec4.
--- @param t table The table to convert. Must have x, y, z, w keys.
--- @return ImVec4|nil The converted ImVec4.
function Tables.TableToImVec4(t)
    if not t then return nil end
    return ImVec4(t.x or t.r, t.y or t.g, t.z or t.b, t.w or t.a)
end

--- Converts an ImVec2 to a table.
--- @param vec ImVec2 The ImVec2 to convert.
--- @return table|nil The converted table with x, y keys.
function Tables.ImVec2ToTable(vec)
    if not vec then return nil end
    return { x = vec.x, y = vec.y, }
end

--- Converts a table to an ImVec2.
--- @param t table The table to convert. Must have x, y keys.
--- @return ImVec2 The converted ImVec2.
function Tables.TableToImVec2(t)
    if not t then return ImVec2(0, 0) end
    return ImVec2(t.x, t.y)
end

function Tables.DeepCopy(orig, copies)
    copies = copies or {} -- to handle cycles
    if type(orig) ~= "table" then
        return orig
    elseif copies[orig] then
        return copies[orig]
    end

    local copy = {}
    copies[orig] = copy
    for k, v in pairs(orig) do
        copy[Tables.DeepCopy(k, copies)] = Tables.DeepCopy(v, copies)
    end
    return setmetatable(copy, getmetatable(orig))
end

return Tables
