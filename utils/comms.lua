local mq                 = require('mq')
local Set                = require("mq.set")
local Logger             = require("utils.logger")
local Strings            = require("utils.strings")
local Globals            = require("utils.globals")

local Comms              = { _version = '1.0', _name = "Comms", _author = 'Derple', }
Comms.__index            = Comms
Comms.Actors             = require('actors')
Comms.ScriptName         = "RGMercs"
Comms.LastHeartbeat      = 0
Comms.Peers              = Set.new({})
Comms.PeersHeartbeats    = {}
Comms.HeartbeatCoroutine = nil

-- Putting this here for lack of a beter spot.
--- @param peerName string? The character name string if not supplied then we use Me.DisplayName()
function Comms.GetPeerName(peerName)
    local server = mq.TLO.EverQuest.Server()
    --upper first letter if it isnt (Live)
    if server:len() > 0 then
        server = server:sub(1, 1):upper() .. server:sub(2)
    end

    return string.format("%s (%s)", peerName and peerName or mq.TLO.Me.DisplayName(), server)
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
    Logger.log_verbose("Broadcasted: %s event: %s", event, Strings.TableToString(data or {}, 512))
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

function Comms.SendPeerDoCmd(peer, cmd, ...)
    cmd = string.format(cmd, ...)

    if peer == Comms.GetPeerName() then
        mq.cmd(cmd)
        return
    end

    Comms.SendMessage(peer, "Core", "DoCmd", {
        cmd = cmd, })
end

function Comms.SendAllPeersDoCmd(inZoneOnly, includeSelf, cmd, ...)
    cmd = string.format(cmd, ...)

    if includeSelf then
        mq.cmd(cmd)
    end

    for peer, data in pairs(Comms.PeersHeartbeats) do
        printf("Peer: %s Zome: %s", peer, data.Data.Zone)
        if data.Data.Zone == mq.TLO.Zone.Name() or not inZoneOnly then
            Comms.SendMessage(peer, "Core", "DoCmd", {
                cmd = cmd, })
        end
    end
end

function Comms.SendHeartbeat(assist, curAutoTarget, chase)
    --if os.time() - Comms.LastHeartbeat < 1 then return end
    local useMana = Globals.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName())
    local useEnd = Globals.Constants.RGMelee:contains(mq.TLO.Me.Class.ShortName())

    Comms.LastHeartbeat = os.time()
    local heartBeat = {
        From          = Comms.GetPeerName(),
        Zone          = mq.TLO.Zone.Name(),
        X             = mq.TLO.Me.X(),
        Y             = mq.TLO.Me.Y(),
        Z             = mq.TLO.Me.Z(),
        Poison        = tostring(mq.TLO.Me.Poisoned.ID()),
        Disease       = tostring(mq.TLO.Me.Diseased.ID()),
        Curse         = tostring(mq.TLO.Me.Cursed.ID()),
        ---@diagnostic disable-next-line: undefined-field
        Mezzed        = tostring(mq.TLO.Me.Mezzed.ID()),
        Corruption    = tostring(mq.TLO.Me.Diseased.ID()),
        Stunned       = mq.TLO.Me.Stunned(),
        HPs           = mq.TLO.Me.Dead() and 0 or mq.TLO.Me.PctHPs(),
        Mana          = useMana and mq.TLO.Me.PctMana() or nil,
        Endurance     = useEnd and mq.TLO.Me.PctEndurance() or nil,
        Target        = mq.TLO.Target.DisplayName() or "None",
        TargetID      = mq.TLO.Target.ID() or 0,
        Casting       = mq.TLO.Me.Casting.ID() ~= 0 and mq.TLO.Me.Casting.RankName() or "None",
        Burning       = Globals.LastBurnCheck,
        ForceCombatID = Globals.ForceCombatID,
        AutoTarget    = curAutoTarget,
        Assist        = assist,
        State         = Globals.PauseMain and "Paused" or Globals.CurrentState,
        Chase         = chase,
    }
    Comms.BroadcastMessage("RGMercs", "Heartbeat", heartBeat)
    -- update our own heartbeat too
    Comms.UpdatePeerHeartbeat(Comms.GetPeerName(), heartBeat)
end

function Comms.GetAllPeerHeartbeats(includeSelf)
    if not includeSelf then
        local heartbeats = {}
        for peer, heartbeat in pairs(Comms.PeersHeartbeats) do
            if peer ~= Comms.GetPeerName() then
                heartbeats[peer] = heartbeat
            end
        end
        return heartbeats
    end

    return Comms.PeersHeartbeats or {}
end

function Comms.GetPeerHeartbeatByName(name)
    return Comms.PeersHeartbeats[Comms.GetPeerName(name)] or {}
end

function Comms.GetPeerHeartbeat(peer)
    return Comms.PeersHeartbeats[peer] or {}
end

function Comms.IsValidPeer(peer)
    return Comms.Peers:contains(peer)
end

function Comms.GetPeers(includeSelf)
    if not includeSelf then
        local peers = Set.new(Comms.Peers:toList() or {})
        peers:remove(Comms.GetPeerName())
        return peers:toList() or {}
    end

    return Comms.Peers:toList() or {}
end

function Comms.UpdatePeerHeartbeat(peer, data)
    Comms.Peers:add(peer)
    Comms.PeersHeartbeats[peer] = Comms.PeersHeartbeats[peer] or {}
    Comms.PeersHeartbeats[peer].LastHeartbeat = os.time()
    Comms.PeersHeartbeats[peer].Data = data or {}
end

function Comms.ValidatePeers(timeout)
    Logger.log_verbose("\ayValidating peers heartbeats for timeouts: \n  :: %s\n  :: %s", Strings.TableToString(Comms.PeersHeartbeats, 512),
        Strings.TableToString(Comms.Peers:toList(), 512))
    for peer, heartbeat in pairs(Comms.PeersHeartbeats) do
        if os.time() - (heartbeat.LastHeartbeat or 0) > timeout then
            Logger.log_debug("\ayPeer \ag%s\ay has timed out, removing from active peer list.", peer)
            Comms.Peers:remove(peer)
            Comms.PeersHeartbeats[peer] = nil
        end
    end
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
function Comms.HandleAnnounce(msg, sendGroup, sendDan, AnnounceToRaidIfInRaid)
    if sendGroup then
        local cleanMsg = msg:gsub("\a.", "")

        if mq.TLO.Raid.Members() > 0 and AnnounceToRaidIfInRaid then
            mq.cmdf("/rsay %s", cleanMsg)
        else
            mq.cmdf("/gsay %s", cleanMsg)
        end
    end

    if sendDan then
        Comms.PrintGroupMessage(msg)
    end

    Logger.log_debug(msg)
end

function Comms.FormatChatEvent(event, target, source)
    return string.format("[%s] => %s <= {%s}", event or "Unknown", target or "None", source or "???")
end

return Comms
