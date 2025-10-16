local mq            = require('mq')
local Logger        = require("utils.logger")
local Strings       = require("utils.strings")

local Comms         = { _version = '1.0', _name = "Comms", _author = 'Derple', }
Comms.__index       = Comms
Comms.Actors        = require('actors')
Comms.ScriptName    = "RGMercs"
Comms.LastHeartbeat = 0


-- Putting this here for lack of a beter spot.
function Comms.GetPeerName()
    local server = mq.TLO.EverQuest.Server()
    --upper first letter if it isnt (Live)
    if server:len() > 0 then
        server = server:sub(1, 1):upper() .. server:sub(2)
    end

    return string.format("%s (%s)", mq.TLO.Me.DisplayName(), server)
end

function Comms.GetCharAndServerFromPeer(peer)
    --return peer:match("^(.-)%.(.-)$")
    return peer:match("^(.-) %((.-)%)$")
end

--- Broadcasts an update event to the specified module.
---
--- @param module string The name of the module to broadcast the update to.
--- @param event string The event type to broadcast.
--- @param data table? The data associated with the event.
function Comms.BroadcastMessage(module, event, data)
    Comms.Actors.send({
        From = Comms.GetPeerName(),
        Script = Comms.ScriptName,
        Module = module,
        Event = event,
        Data = data,
    })
    Logger.log_debug("Broadcasted: %s event: %s", event, Strings.TableToString(data or {}, 512))
end

--- @param module string The name of the module to broadcast the update to.
--- @param event string The event type to broadcast.
--- @param data table? The data associated with the event.
function Comms.SendMessage(peer, module, event, data)
    local char, server = Comms.GetCharAndServerFromPeer(peer)
    Comms.Actors.send({ server = server, character = char, }, {
        From = Comms.GetPeerName(),
        Script = Comms.ScriptName,
        Module = module,
        Event = event,
        Data = data,
    })
    Logger.log_debug("Sent Message: %s to:  %s event: %s", event, peer, Strings.TableToString(data or {}, 512))
end

function Comms.SendHeartbeat(assist, curState, curAutoTarget, chase)
    if os.time() - Comms.LastHeartbeat < 1 then return end
    Comms.LastHeartbeat = os.time()
    Comms.BroadcastMessage("RGMercs", "Heartbeat", {
        From = Comms.GetPeerName(),
        Zone = mq.TLO.Zone.Name(),
        X = mq.TLO.Me.X(),
        Y = mq.TLO.Me.Y(),
        Z = mq.TLO.Me.Z(),
        HPs = mq.TLO.Me.PctHPs(),
        Mana = mq.TLO.Me.PctMana(),
        Endurance = mq.TLO.Me.PctEndurance(),
        Target = mq.TLO.Target.DisplayName(),
        AutoTarget = curAutoTarget,
        Assist = assist,
        State = curState,
        Chase = chase,
    })
end

--- Prints a group message with the given format and arguments.
--- @param msg string: The message format string.
--- @param ... any: Additional arguments to format the message.
function Comms.PrintGroupMessage(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    mq.cmdf("/dgt group_%s_%s %s", mq.TLO.EverQuest.Server():gsub(" ", ""), mq.TLO.Group.Leader() or "None", output)
end

--- Displays a pop-up message with the given text.
--- @param msg string: The message to be displayed in the pop-up.
--- @param ... any: Additional arguments that may be used within the function.
function Comms.PopUp(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    mq.cmdf("/popupecho 15 5 %s", output)
end

--- Handles the announcement message.
--- @param msg string: The message to be announced.
--- @param sendGroup boolean: Whether to send the message to the group.
--- @param sendDan boolean: Whether to send the message to DanNet.
function Comms.HandleAnnounce(msg, sendGroup, sendDan)
    if sendGroup then
        local cleanMsg = msg:gsub("\a.", "")
        mq.cmdf("/gsay %s", cleanMsg)
    end

    if sendDan then
        Comms.PrintGroupMessage(msg)
    end

    Logger.log_debug(msg)
end

return Comms
