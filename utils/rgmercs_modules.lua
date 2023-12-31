local RGMercsLogger = require("rgmercs.utils.rgmercs_logger")

local Modules       = { _version = '0.1a', author = 'Derple' }
Modules.__index     = Modules

---@return any
function Modules.load()
    local newModules = setmetatable({
        modules = {
            --Basic          = require("modules.basic").New(),
            Movement     = require("modules.movement").New(),
            ShadowKnight = require("modules.shd").New(),
        }
    }, Modules)

    return newModules
end

function Modules:getModuleList()
    return self.modules
end

function Modules:execModule(m, fn, ...)
    for name, module in pairs(self.modules) do
        if name == m then
            module[fn](module, ...)
            return
        end
    end
    RGMercsLogger.log_error("\arModule: \at%s\ar not found!", m)
end

function Modules:execAll(fn, ...)
    for n, m in pairs(self.modules) do
        m[fn](m, ...)
    end
end

return Modules
