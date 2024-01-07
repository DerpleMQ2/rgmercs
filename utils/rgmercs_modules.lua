local RGMercsLogger  = require("utils.rgmercs_logger")

local Module         = { _version = '0.1a', _author = 'Derple', }
Module.__index       = Module
Module.FrameTimes    = {}
Module.FramesToStore = 5

---@return any
function Module.load()
    local newModule = setmetatable({
        modules = {
            Movement     = require("modules.movement").New(),
            Travel       = require("modules.travel").New(),
            Class        = require("modules.class").New(),
            Pull         = require("modules.pull").New(),
            Performance  = require("modules.performance").New(),
            Contributors = require("modules.contributors").New(),
        },
        module_order = {
            "Class",
            "Movement",
            "Pull",
            "Travel",
            "Performance",
            "Contributors",
        },
    }, Module)

    for name, _ in pairs(newModule.modules) do
        newModule.FrameTimes[name] = {}
    end

    return newModule
end

function Module:getModuleList()
    return self.modules
end

function Module:getModuleOrderedNames()
    return self.module_order
end

---@param m string
---@return RGMercsModuleType|nil
function Module:getModule(m)
    for name, module in pairs(self.modules) do
        if name == m then
            return module
        end
    end
    return nil
end

function Module:execModule(m, fn, ...)
    for name, module in pairs(self.modules) do
        if name == m then
            return module[fn](module, ...)
        end
    end
    RGMercsLogger.log_error("\arModule: \at%s\ar not found!", m)
end

function Module:execAll(fn, ...)
    local ret = {}
    for n, m in pairs(self.modules) do
        local startTime = os.clock() * 1000
        local r = m[fn](m, ...)
        ret[n] = r

        if fn == "GiveTime" then
            local endTime = os.clock() * 1000
            table.insert(self.FrameTimes[n], endTime - startTime)
            if #self.FrameTimes[n] > self.FramesToStore then
                local oldTimes = { unpack(self.FrameTimes[n]), }
                self.FrameTimes[n] = {}
                local startPoint = (#oldTimes - self.FramesToStore) + 1
                for i = startPoint, (#oldTimes) do
                    self.FrameTimes[n][(i - startPoint) + 1] = oldTimes[i]
                end
            end
        end
    end

    return ret
end

return Module
