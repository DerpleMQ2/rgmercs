local mq      = require('mq')
local Logger  = require("utils.logger")

local Files   = { _version = '1.0', _name = "Files", _author = 'Derple', }
Files.__index = Files

--- Checks if a file exists at the given path.
--- @param path string: The path to the file.
--- @return boolean: True if the file exists, false otherwise.
function Files.file_exists(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

--- Copies a file from one path to another.
--- @param from_path string The source file path.
--- @param to_path string The destination file path.
--- @return boolean success True if the file was copied successfully, false otherwise.
function Files.copy_file(from_path, to_path)
    if Files.file_exists(from_path) then
        local file = io.open(from_path, "r")
        if file ~= nil then
            local content = file:read("*all")
            file:close()
            local fileNew = io.open(to_path, "w")
            if fileNew ~= nil then
                fileNew:write(content)
                fileNew:close()
                return true
            else
                Logger.log_error("\arFailed to create new file: %s", to_path)
                return false
            end
        end
    end

    return false
end

return Files
