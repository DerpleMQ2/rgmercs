local RGMercsLogger = require("utils.rgmercs_logger")

local Modules       = { _version = '0.1a', author = 'Derple', }
Modules.__index     = Modules

---@return any
function Modules.load()
    local newModules = setmetatable({
        modules = {
            Movement = require("modules.movement").New(),
            Travel   = require("modules.travel").New(),
            Class    = require("modules.class").New(),
        },
    }, Modules)

    return newModules
end

function Modules:getModuleList()
    return self.modules
end

function Modules:execModule(m, fn, ...)
    for name, module in pairs(self.modules) do
        if name == m then
            return module[fn](module, ...)
        end
    end
    RGMercsLogger.log_error("\arModule: \at%s\ar not found!", m)
end

function Modules:execAll(fn, ...)
    local ret = {}
    for n, m in pairs(self.modules) do
        local r = m[fn](m, ...)
        ret[n] = r
    end

    return ret
end

return Modules
