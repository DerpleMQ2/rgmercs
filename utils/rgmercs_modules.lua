local Module   = { _version = '0.1a', _author = 'Derple', }
Module.__index = Module

---@return any
function Module.load()
    local newModule = setmetatable({
        modules = {
            Movement     = require("modules.movement").New(),
            Travel       = require("modules.travel").New(),
            Class        = require("modules.class").New(),
            Pull         = require("modules.pull").New(),
            Mez          = require("modules.mez").New(),
            Performance  = require("modules.performance").New(),
            Contributors = require("modules.contributors").New(),
        },
        module_order = {
            "Class",
            "Movement",
            "Pull",
            "Mez",
            "Travel",
            "Performance",
            "Contributors",
        },
    }, Module)

    return newModule
end

function Module:GetModuleList()
    return self.modules
end

function Module:GetModuleOrderedNames()
    return self.module_order
end

---@param m string
---@return RGMercsModuleType|nil
function Module:GetModule(m)
    for name, module in pairs(self.modules) do
        if name == m then
            return module
        end
    end
    return nil
end

function Module:ExecModule(m, fn, ...)
    for name, module in pairs(self.modules) do
        if name == m then
            return module[fn](module, ...)
        end
    end
    RGMercsLogger.log_error("\arModule: \at%s\ar not found!", m)
end

function Module:ExecAll(fn, ...)
    local ret = {}
    for _, name in pairs(self.module_order) do
        local startTime = os.clock() * 1000
        local module = self.modules[name]
        ret[name] = module[fn](module, ...)

        if fn == "GiveTime" then
            if self.modules.Performance then
                self.modules.Performance:OnFrameExec(name, (os.clock() * 1000) - startTime)
            end
        end
    end

    return ret
end

return Module
