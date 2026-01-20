local mq                = require('mq')
local Config            = require('utils.config')
local Events            = require('utils.events')
local Logger            = require("utils.logger")
local Core              = require("utils.core")
local Modules           = require("utils.modules")

local Movement          = { _version = '1.0', _name = "Movement", _author = 'Derple', }
Movement.__index        = Movement
Movement.LastDoStick    = 0
Movement.LastDoStickCmd = ""
Movement.LastDoNav      = os.clock()
Movement.LastDoNavCmd   = "None"

--- Sticks the player to the specified target.
--- @param targetId number The ID of the target to stick to.
function Movement:DoStick(targetId)
    if Config:GetSetting('EnableManualMovement') then return end

    if os.clock() - self.LastDoStick < 1 then
        Logger.log_debug(
            "\ayIgnoring DoStick because we just stuck a second ago - let's give it some time.")
        return
    end

    if Config:GetSetting('StickHow'):len() > 0 then
        self:DoStickCmd("%s", Config:GetSetting('StickHow'))
    else
        if Core.IAmMA() then
            self:DoStickCmd("10 id %d %s uw", targetId, Config:GetSetting('MovebackWhenTank') and "moveback" or "")
        else
            local stickDist = (mq.TLO.Spawn(targetId).Height() or 5) > 15 and 20 or 10
            self:DoStickCmd("%d id %d behindonce moveback uw", stickDist, targetId)
        end
    end
end

function Movement:DoStickCmd(params, ...)
    local formatted = params
    if ... ~= nil then formatted = string.format(params, ...) end
    Core.DoCmd("/stick %s", formatted)
    self:SetLastStickTimer(os.clock())
    self.LastDoStickCmd = formatted
end

function Movement:DoNav(squelch, params, ...)
    local formatted = params
    if ... ~= nil then formatted = string.format(params, ...) end
    Core.DoCmd("%s/nav %s", squelch and "/squelch " or "", formatted)
    self.LastDoNav = os.clock()
    self.LastDoNavCmd = formatted
end

function Movement:GetLastNavCmd()
    return self.LastDoNavCmd
end

-- Gets the last stick timer.
--- @return string The last stick command.
function Movement:GetLastStickCmd()
    return self.LastDoStickCmd
end

-- Clears the last stick timer.
function Movement:ClearLastStickTimer()
    self.LastDoStick = 0
end

-- Gets the last stick timer.
--- @return number The last stick timer.
function Movement:GetLastStickTimer()
    return self.LastDoStick
end

-- Sets the last stick timer.
--- @param t number The time to set the last stick timer to.
function Movement:SetLastStickTimer(t)
    self.LastDoStick = t
end

-- Gets the time since last stick a stirng.
--- @return string Formatted time since last stick.
function Movement:GetTimeSinceLastStick()
    return string.format("%ds", os.clock() - self.LastDoStick)
end

function Movement:GetTimeSinceLastNav()
    return string.format("%ds", os.clock() - self.LastDoNav)
end

--- Navigates to a target during combat.
--- @param targetId number The ID of the target to navigate to.
--- @param distance number The distance to maintain from the target.
--- @param bDontStick boolean Whether to avoid sticking to the target.
function Movement:NavInCombat(targetId, distance, bDontStick)
    if not Config:GetSetting('DoAutoEngage') then return end
    if Config:GetSetting('EnableManualMovement') then return end

    if mq.TLO.Stick.Active() then
        self:DoStickCmd("off")
    end

    if mq.TLO.Navigation.PathExists("id " .. tostring(targetId) .. " distance " .. tostring(distance))() then
        Movement:DoNav(false, "id %d distance=%d log=off lineofsight=on", targetId, distance or 15)
        while mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 do
            mq.delay(100)
            mq.doevents()
            Events.DoEvents()
        end
    else
        Core.DoCmd("/moveto id %d uw mdist %d", targetId, distance)
        while mq.TLO.MoveTo.Moving() and not mq.TLO.MoveUtils.Stuck() do
            mq.delay(100)
            mq.doevents()
            Events.DoEvents()
        end
    end

    if not bDontStick then
        self:DoStick(targetId)
    end
end

--- Navigates around a circle centered on the target with a specified radius.
--- @param target MQTarget The central point around which to navigate.
--- @param radius number The radius of the circle to navigate around.
--- @return boolean True if we were able to successfully navigate around
function Movement:NavAroundCircle(target, radius)
    if not Config:GetSetting('DoAutoEngage') then return false end
    if not target or not target() and not target.Dead() then return false end
    if not mq.TLO.Navigation.MeshLoaded() then return false end

    local spawn_x = target.X()
    local spawn_y = target.Y()
    local spawn_z = target.Z()

    local tgt_x = 0
    local tgt_y = 0
    -- We need to get the spawn's heading to _us_ based on our heading to the spawn
    -- to nav a circle around it. This is done by inverting the coordinates. E.g.,
    -- If our heading to the mob is 90 degrees CCW, their heading to us is 270 degrees CCW.

    local tmp_degrees = target.HeadingTo.DegreesCCW() - 180
    if tmp_degrees < 0 then tmp_degrees = 360 + tmp_degrees end

    -- Loop until we find an x,y loc ${radius} away from the mob,
    -- that we can navigate to, and is in LoS

    for steps = 1, 36 do
        -- EQ's x coordinates have an opposite number line. Positive x values are to the left of 0,
        -- negative values are to the right of 0, so we need to - our radius.
        -- EQ's unit circle starts 0 degrees at the top of the unit circle instead of the right, so
        -- the below still finds coordinates rotated counter-clockwise 90 degrees.

        tgt_x = spawn_x + (-1 * radius * math.cos(tmp_degrees))
        tgt_y = spawn_y + (radius * math.sin(tmp_degrees))

        Logger.log_debug("\aw%d\ax tmp_degrees \aw%d\ax tgt_x \aw%0.2f\ax tgt_y \aw%02.f\ax", steps, tmp_degrees,
            tgt_x, tgt_y)
        -- First check that we can navigate to our new target
        if mq.TLO.Navigation.PathExists(string.format("locyxz %0.2f %0.2f %0.2f", tgt_y, tgt_x, spawn_z))() then
            -- Then check if our new spots has line of sight to our target.
            if mq.TLO.LineOfSight(string.format("%0.2f,%0.2f,%0.2f:%0.2f,%0.2f,%0.2f", tgt_y, tgt_x, spawn_z, spawn_y, spawn_x, spawn_z))() then
                -- Make sure it's a valid loc...
                if mq.TLO.EverQuest.ValidLoc(string.format("%0.2f %0.2f %0.2f", tgt_x, tgt_y, spawn_z))() then
                    Logger.log_debug(" \ag--> Found Valid Circling Loc: %0.2f %0.2f %0.2f", tgt_x, tgt_y, spawn_z)
                    Movement:DoNav(false, "locyxz %0.2f %0.2f %0.2f facing=backward", tgt_y, tgt_x, spawn_z)
                    mq.delay("2s", function() return mq.TLO.Navigation.Active() end)
                    mq.delay("10s", function() return not mq.TLO.Navigation.Active() end)
                    Core.DoCmd("/squelch /face fast")
                    return true
                else
                    Logger.log_debug(" \ar--> Invalid Loc: %0.2f %0.2f %0.2f", tgt_x, tgt_y, spawn_z)
                end
            end
        end
    end

    return false
end

function Movement.UpdateMapRadii()
    if Config:GetSetting('DoPull') or Config:GetSetting('ReturnToCamp') then
        if Modules:ExecModule("Pull", "IsPullMode", "Hunt") then
            Core.DoCmd("/squelch /mapfilter pullradius %d", Config:GetSetting('PullRadiusHunt'))
        elseif Config:GetSetting('ReturnToCamp') then
            Core.DoCmd("/squelch /mapfilter pullradius %d", Config:GetSetting('PullRadius'))
        end
        Core.DoCmd("/squelch /mapfilter campradius %d", Config:GetSetting('AutoCampRadius'))
    else
        Core.DoCmd("/squelch /mapfilter campradius off")
        Core.DoCmd("/squelch /mapfilter pullradius off")
    end
end

return Movement
