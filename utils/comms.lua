local mq         = require('mq')
local Core       = require("utils.core")
local Logger     = require("utils.logger")

local Comms      = { _version = '1.0', _name = "Comms", _author = 'Derple', }
Comms.__index    = Comms
Comms.Actors     = require('actors')
Comms.ScriptName = "RGMercs"

--- Broadcasts an update event to the specified module.
---
--- @param module string The name of the module to broadcast the update to.
--- @param event string The event type to broadcast.
--- @param data table? The data associated with the event.
function Comms.BroadcastUpdate(module, event, data)
    Comms.Actors.send({
        from = mq.TLO.Me.DisplayName(),
        script = Comms.ScriptName,
        module = module,
        event =
            event,
        data = data,
    })
end

--- Prints a group message with the given format and arguments.
--- @param msg string: The message format string.
--- @param ... any: Additional arguments to format the message.
function Comms.PrintGroupMessage(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    Core.DoCmd("/dgt group_%s_%s %s", mq.TLO.EverQuest.Server():gsub(" ", ""), mq.TLO.Group.Leader() or "None", output)
end

--- Displays a pop-up message with the given text.
--- @param msg string: The message to be displayed in the pop-up.
--- @param ... any: Additional arguments that may be used within the function.
function Comms.PopUp(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    Core.DoCmd("/popup %s", output)
end

--- Handles the announcement message.
--- @param msg string: The message to be announced.
--- @param sendGroup boolean: Whether to send the message to the group.
--- @param sendDan boolean: Whether to send the message to DanNet.
function Comms.HandleAnnounce(msg, sendGroup, sendDan)
    if sendGroup then
        local cleanMsg = msg:gsub("\a.", "")
        Core.DoCmd("/gsay %s", cleanMsg)
    end

    if sendDan then
        Comms.PrintGroupMessage(msg)
    end

    Logger.log_debug(msg)
end

return Comms
