local mq                  = require('mq')
local Config              = require('utils.config')
local Globals             = require('utils.globals')
local Core                = require("utils.core")
local Modules             = require("utils.modules")
local Logger              = require("utils.logger")
local Comms               = require("utils.comms")

local Events              = { _version = '1.0', _name = "Events", _author = 'Derple', }

Events.__index            = Events
Events.HeartbeatCoroutine = nil

--- Handles the death event for RGMercs.
--- This function is triggered when a death event occurs and performs necessary operations.
function Events.HandleDeath()
    Logger.log_warn("You are sleeping with the fishes.")

    Modules:ExecAll("OnDeath")

    while mq.TLO.Me.Hovering() do
        Logger.log_debug("Trying to release...")
        if mq.TLO.Window("RespawnWnd").Open() and Config:GetSetting('InstantRelease') then
            mq.TLO.Window("RespawnWnd").Child("RW_OptionsList").Select(1)
            mq.delay("1s")
            mq.TLO.Window("RespawnWnd").Child("RW_SelectButton").LeftMouseUp()
        else
            break
        end
    end

    mq.delay("2m", function() return not mq.TLO.Me.Hovering() or (mq.TLO.Zone.ID() ~= Globals.CurZoneId) end)

    Logger.log_debug("Fishfood no more! Accepted rez or finished zoning post death.")

    -- if we want do do fellowship but we arent in the fellowship zone (rezed)
    if Config:GetSetting('DoFellow') and not Modules:ExecModule("Movement", "InCampZone") then
        Logger.log_debug("Doing fellowship post death.")
        if mq.TLO.FindItem("Fellowship Registration Insignia").Timer.TotalSeconds() == 0 then
            mq.delay("30s", function() return (mq.TLO.Me.CombatState():lower() == "active") end)
            Core.DoCmd("/useitem \"Fellowship Registration Insignia\"")
            mq.delay("2s",
                function() return (mq.TLO.FindItem("Fellowship Registration Insignia").Timer.TotalSeconds() ~= 0) end)
        else
            Logger.log_error("\aw Bummer, Insignia on cooldown, you must really suck at this game...")
        end
    end
end

function Events.CreateHeartBeat()
    Events.HeartbeatCoroutine = coroutine.create(function()
        while (1) do
            Comms.SendHeartbeat(Core.GetMainAssistSpawn().DisplayName(),
                Config:GetSetting('ChaseOn') and Config:GetSetting('ChaseTarget') or "Chase Off")
            coroutine.yield()
        end
    end)
end

function Events.DoEvents(force)
    if not force and not Config:GetSetting('RunCoroutinesDuringLoops') then
        return
    end

    if Events.HeartbeatCoroutine then
        if coroutine.status(Events.HeartbeatCoroutine) ~= 'dead' then
            local success, err = coroutine.resume(Events.HeartbeatCoroutine)
            if not success then
                Logger.log_error("\arError in Heartbeat Coroutine: %s", err)
            end
        else
            Events.CreateHeartBeat()
        end
    else
        Events.CreateHeartBeat()
    end

    Modules:ExecAll("DoEvents")
end

return Events
