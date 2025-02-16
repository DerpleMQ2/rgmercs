local mq      = require('mq')
local Config  = require('utils.config')
local Modules = require("utils.modules")
local DanNet  = require('lib.dannet.helpers')
local Logger  = require("utils.logger")
local LuaFS   = require('lfs')

local Core    = { _version = '1.0', _name = "Core", _author = 'Derple', }
Core.__index  = Core

--- Scans for updates in the class_configs folder.
function Core.ScanConfigDirs()
    Config.Globals.ClassConfigDirs = {}

    local classConfigDir = Config.Globals.ScriptDir .. "/class_configs"

    for file in LuaFS.dir(classConfigDir) do
        if file ~= "." and file ~= ".." and LuaFS.attributes(classConfigDir .. "/" .. file).mode == "directory" then
            table.insert(Config.Globals.ClassConfigDirs, file)
        end
    end

    table.insert(Config.Globals.ClassConfigDirs, "Custom")
end

--- Safely calls a function and logs information.
---
--- @param logInfo string: Information to log before calling the function.
--- @param fn function: The function to be called safely.
--- @param ... any: Additional arguments to pass to the function.
--- @return any: Returns the result of the function call, or nil if an error occurs.
function Core.SafeCallFunc(logInfo, fn, ...)
    if not fn then return true end -- no condition func == pass

    local success, ret = pcall(fn, ...)
    if not success then
        Logger.log_error("\ay%s\n\ar\t%s", logInfo, ret)
        ret = false
    end
    return ret
end

--- Checks if the current environment is EMU (Emulator).
---
--- @return boolean True if the environment is EMU, false otherwise.
function Core.OnEMU()
    return (mq.TLO.MacroQuest.BuildName() or ""):lower() == "emu"
end

--- Checks if the current server is Project Lazarus.
---
--- @return boolean True if the server is Project Lazarus, false otherwise.
function Core.OnLaz()
    return (mq.TLO.EverQuest.Server() or ""):lower() == "project lazarus"
end

--- Executes a given command with optional arguments.
--- @param cmd string: The command to execute.
--- @param ... any: Optional arguments for the command.
function Core.DoCmd(cmd, ...)
    local formatted = cmd
    if ... ~= nil then formatted = string.format(cmd, ...) end
    Logger.log_debug("\atRGMercs \awsent MQ \amCommand\aw: >> \ag%s\aw <<", formatted)
    mq.cmd(formatted)
end

--- Executes a group command with the provided arguments.
--- @param cmd string The command to be executed.
--- @param ... any Additional arguments for the command.
function Core.DoGroupCmd(cmd, ...)
    local dgcmd = "/dga /if ($\\{Zone.ID} == ${Zone.ID} && $\\{Group.Leader.Name.Equal[${Group.Leader.Name}]}) "
    local formatted = cmd
    if ... ~= nil then formatted = string.format(cmd, ...) end
    formatted = dgcmd .. formatted
    Logger.log_debug("\atRGMercs \awsent MQ \amGroup Command\aw: >> \ag%s\aw <<", formatted)
    mq.cmd(formatted)
end

--- Checks the status of plugins.
---
--- This function iterates over the provided table of plugins and performs a check on each one.
---
--- @param t table A table containing plugin information to be checked.
function Core.CheckPlugins(t)
    for _, p in pairs(t) do
        if not mq.TLO.Plugin(p)() then
            Core.DoCmd("/squelch /plugin %s noauto", p)
            Logger.log_info("\aw %s \ar not detected! \aw This script requires it! Loading ...", p)
        end
    end
end

--- Unchecks the specified plugins.
---
--- This function iterates over the provided table `t` and unchecks each plugin listed.
---
--- @param t table A table containing the plugins to be unchecked.
function Core.UnCheckPlugins(t)
    local r = {}
    for _, p in pairs(t) do
        if mq.TLO.Plugin(p)() then
            Core.DoCmd("/squelch /plugin %s unload noauto", p)
            Logger.log_info("\ar %s detected! \aw Unloading it due to known conflicts with RGMercs!", p)
            table.insert(r, p)
        end
    end

    return r
end

--- Retrieves the ID of the main assist in the group.
--- @return number The ID of the main assist in the group.
function Core.GetGroupMainAssistID()
    return (mq.TLO.Group.MainAssist.ID() or 0)
end

--- Retrieves the name of the main assist in the group.
--- @return string The name of the main assist in the group.
function Core.GetGroupMainAssistName()
    return (mq.TLO.Group.MainAssist.CleanName() or "")
end

--- Checks if the specified expansion is available.
--- @param name string The name of the expansion to check.
--- @return boolean True if the expansion is available, false otherwise.
function Core.HaveExpansion(name)
    return mq.TLO.Me.HaveExpansion(Config.Constants.ExpansionNameToID[name])
end

--- Checks if the player's class matches the specified class.
--- @param class string The class to check against the player's class.
--- @return boolean True if the player's class matches the specified class, false otherwise.
function Core.MyClassIs(class)
    return mq.TLO.Me.Class.ShortName():lower() == class:lower()
end

--- Checks if the current character is a Main Assistant (MA).
--- @return boolean True if the character is the Main Assistant, false otherwise.
function Core.IAmMA()
    return Core.GetMainAssistId() == mq.TLO.Me.ID()
end

--- Retrieves the ID of the main assist.
---
--- @return number The ID of the main assist.
function Core.GetMainAssistId()
    return mq.TLO.Spawn(string.format("PC =%s", Config.Globals.MainAssist)).ID() or 0
end

--- Retrieves the main assist spawn.
--- @return MQSpawn The main assist spawn data.
function Core.GetMainAssistSpawn()
    return mq.TLO.Spawn(string.format("PC =%s", Config.Globals.MainAssist))
end

--- Retrieves the percentage of hit points (HP) of the main assist.
---
--- @return number The percentage of HP of the main assist.
function Core.GetMainAssistPctHPs()
    local groupMember = mq.TLO.Group.Member(Config.Globals.MainAssist)
    if groupMember and groupMember() then
        return groupMember.PctHPs() or 0
    end

    local ret = tonumber(DanNet.query(Config.Globals.MainAssist, "Me.PctHPs", 1000))

    if ret and type(ret) == 'number' then return ret end

    return mq.TLO.Spawn(string.format("PC =%s", Config.Globals.MainAssist)).PctHPs() or 0
end

--- Checks if a given mode is active.
--- @param mode string The mode to check.
--- @return boolean Returns true if the mode is active, false otherwise.
function Core.IsModeActive(mode)
    return Modules:ExecModule("Class", "IsModeActive", mode)
end

--- Checks if the character is currently tanking.
--- @return boolean True if the character is tanking, false otherwise.
function Core.IsTanking()
    return Modules:ExecModule("Class", "IsTanking")
end

--- Checks if the current character is performing a healing action.
--- @return boolean True if the character is healing, false otherwise.
function Core.IsHealing()
    return Modules:ExecModule("Class", "IsHealing")
end

--- Checks if the curing process is active.
--- @return boolean True if curing is active, false otherwise.
function Core.IsCuring()
    return Modules:ExecModule("Class", "IsCuring")
end

--- Checks if the character is currently mezzing.
--- @return boolean True if the character is mezzing, false otherwise.
function Core.IsMezzing()
    return Modules:ExecModule("Class", "IsMezzing") and Config:GetSetting('MezOn')
end

--- Checks if the character is currently charming.
--- @return boolean True if the character is charming, false otherwise.
function Core.IsCharming()
    return Modules:ExecModule("Class", "IsCharming")
end

--- Determines if the character can perform a mez (mesmerize) action.
--- @return boolean True if the character can mez, false otherwise.
function Core.CanMez()
    return Modules:ExecModule("Class", "CanMez")
end

--- Checks if the character can charm.
--- @return boolean True if the character can charm, false otherwise.
function Core.CanCharm()
    return Modules:ExecModule("Class", "CanCharm")
end

--- Checks if the shield is equipped.
--- @return boolean True if the shield is equipped, false otherwise.
function Core.ShieldEquipped()
    return mq.TLO.InvSlot("Offhand").Item.Type() and mq.TLO.InvSlot("Offhand").Item.Type() == "Shield"
end

--- Checks if a health is not critically low before a healer performs other actions.
function Core.OkayToNotHeal()
    if not Core.IsHealing() then return true end

    return Core.GetMainAssistPctHPs() > Config:GetSetting('BigHealPoint')
end

--- Retrieves the resolved action map item for a given action.
--- @param action string The action for which to retrieve the resolved map item.
--- @return any The resolved action map item corresponding to the given action.
function Core.GetResolvedActionMapItem(action)
    return Modules:ExecModule("Class", "GetResolvedActionMapItem", action)
end

return Core
