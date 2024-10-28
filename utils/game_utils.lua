local mq            = require('mq')
local RGMercsLogger = require("utils.rgmercs_logger")

local GameUtils     = { _version = '1.0', _name = "GameUtils", _author = 'Derple', }
GameUtils.__index   = GameUtils

--- Executes a given command with optional arguments.
--- @param cmd string: The command to execute.
--- @param ... any: Optional arguments for the command.
function GameUtils.DoCmd(cmd, ...)
    local formatted = cmd
    if ... ~= nil then formatted = string.format(cmd, ...) end
    RGMercsLogger.log_debug("\atRGMercs \awsent MQ \amCommand\aw: >> \ag%s\aw <<", formatted)
    mq.cmd(formatted)
end

--- Checks the status of plugins.
---
--- This function iterates over the provided table of plugins and performs a check on each one.
---
--- @param t table A table containing plugin information to be checked.
function GameUtils.CheckPlugins(t)
    for _, p in pairs(t) do
        if not mq.TLO.Plugin(p)() then
            GameUtils.DoCmd("/squelch /plugin %s noauto", p)
            RGMercsLogger.log_info("\aw %s \ar not detected! \aw This macro requires it! Loading ...", p)
        end
    end
end

--- Unchecks the specified plugins.
---
--- This function iterates over the provided table `t` and unchecks each plugin listed.
---
--- @param t table A table containing the plugins to be unchecked.
function GameUtils.UnCheckPlugins(t)
    local r = {}
    for _, p in pairs(t) do
        if mq.TLO.Plugin(p)() then
            GameUtils.DoCmd("/squelch /plugin %s unload noauto", p)
            RGMercsLogger.log_info("\ar %s detected! \aw Unloading it due to known conflicts with RGMercs!", p)
            table.insert(r, p)
        end
    end

    return r
end

return GameUtils
