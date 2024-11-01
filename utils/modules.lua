local mq            = require("mq")
local Logger        = require("utils.logger")

local Modules       = { _version = '0.1a', _author = 'Derple', }
Modules.__index     = Modules

Modules.ModuleOrder = {
    "Class",
    "Movement",
    "Pull",
    "Drag",
    "Charm",
    "Mez",
    "Travel",
    "Named",
    "Perf",
    "Contributors",
    "FAQ",
}

---@return any
function Modules:load()
    if (mq.TLO.MacroQuest.BuildName() or ""):lower() == "emu" then
        self.ModuleOrder = {
            "Class",
            "Movement",
            "Pull",
            "Drag",
            "Charm",
            "Mez",
            "Travel",
            "Named",
            "Perf",
            "Loot",
            "Contributors",
            "FAQ",
        }
    end
    self.ModuleList = {
        Movement     = require("modules.movement").New(),
        Travel       = require("modules.travel").New(),
        Class        = require("modules.class").New(),
        Pull         = require("modules.pull").New(),
        Drag         = require("modules.drag").New(),
        Mez          = require("modules.mez").New(),
        Charm        = require("modules.charm").New(),
        Loot         = (mq.TLO.MacroQuest.BuildName() or ""):lower() == "emu" and require("modules.loot").New() or nil,
        Named        = require("modules.named").New(),
        Perf         = require("modules.performance").New(),
        Contributors = require("modules.contributors").New(),
        FAQ          = require("modules.faq").New(),
    }
end

function Modules:GetModuleList()
    return self.ModuleList
end

function Modules:GetModuleOrderedNames()
    return self.ModuleOrder
end

---@param m string
---@return RGMercsModuleType|nil
function Modules:GetModule(m)
    for name, module in pairs(self.ModuleList) do
        if name == m then
            return module
        end
    end
    return nil
end

function Modules:ExecModule(m, fn, ...)
    for name, module in pairs(self.ModuleList) do
        if name:lower() == m:lower() then
            return module[fn](module, ...)
        end
    end
    Logger.log_error("\arModule: \at%s\ar not found!", m)
end

function Modules:ExecAll(fn, ...)
    local ret = {}
    for _, name in pairs(self.ModuleOrder) do
        local startTime = os.clock() * 1000
        local module = self.ModuleList[name]
        if module then
            ret[name] = module[fn](module, ...)

            if fn == "GiveTime" then
                if self.ModuleList.Perf then
                    self.ModuleList.Perf:OnFrameExec(name, (os.clock() * 1000) - startTime)
                end
            end
        end
    end

    return ret
end

return Modules
