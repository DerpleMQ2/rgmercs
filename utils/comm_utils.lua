local mq             = require('mq')
local Config         = require("rgmercs.config")
local GameUtils      = require("utils.game_utils")
local RGMercsLogger  = require("utils.rgmercs_logger")

local CommUtils      = { _version = '1.0', _name = "CommUtils", _author = 'Derple', }
CommUtils.__index    = CommUtils
CommUtils.Actors     = require('actors')
CommUtils.ScriptName = "RGMercs"

--- Broadcasts an update event to the specified module.
---
--- @param module string The name of the module to broadcast the update to.
--- @param event string The event type to broadcast.
--- @param data table? The data associated with the event.
function CommUtils.BroadcastUpdate(module, event, data)
    CommUtils.Actors.send({
        from = Config.Globals.CurLoadedChar,
        script = CommUtils.ScriptName,
        module = module,
        event =
            event,
        data = data,
    })
end

--- Prints a group message with the given format and arguments.
--- @param msg string: The message format string.
--- @param ... any: Additional arguments to format the message.
function CommUtils.PrintGroupMessage(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    GameUtils.DoCmd("/dgt group_%s_%s %s", Config.Globals.CurServer, mq.TLO.Group.Leader() or "None", output)
end

--- Displays a pop-up message with the given text.
--- @param msg string: The message to be displayed in the pop-up.
--- @param ... any: Additional arguments that may be used within the function.
function CommUtils.PopUp(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    GameUtils.DoCmd("/popup %s", output)
end

--- Handles the announcement message.
--- @param msg string: The message to be announced.
--- @param sendGroup boolean: Whether to send the message to the group.
--- @param sendDan boolean: Whether to send the message to DanNet.
function CommUtils.HandleAnnounce(msg, sendGroup, sendDan)
    if sendGroup then
        local cleanMsg = msg:gsub("\a.", "")
        GameUtils.DoCmd("/gsay %s", cleanMsg)
    end

    if sendDan then
        CommUtils.PrintGroupMessage(msg)
    end

    RGMercsLogger.log_debug(msg)
end

return CommUtils
