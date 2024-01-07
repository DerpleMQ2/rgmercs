local RGMercsLogger  = require("utils.rgmercs_logger")

local Module         = { _version = '0.1a', _author = 'Derple', }
Module.__index       = Module
Module.FrameTimes    = {}
Module.FramesToStore = 100
Module.MaxFrameTime  = 0

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

function Module:GetModuleList()
    return self.modules
end

function Module:GetModuleOrderedNames()
    return self.module_order
end

---@return number
function Module:GetMaxFrameTime()
    return self.MaxFrameTime
end

---@param f number
function Module:SetMaxFrameTime(f)
    self.MaxFrameTime = f
end

---@return number
function Module:GetFramesToStore()
    return self.FramesToStore
end

---@param f number
function Module:SetFramesToStore(f)
    self.FramesToStore = f
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
    for n, m in pairs(self.modules) do
        local startTime = os.clock() * 1000
        local r = m[fn](m, ...)
        ret[n] = r

        if fn == "GiveTime" then
            local frameTime = (os.clock() * 1000) - startTime
            table.insert(self.FrameTimes[n], frameTime)
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
