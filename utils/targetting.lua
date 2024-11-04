local mq                     = require('mq')
local Config                 = require('utils.config')
local Core                   = require('utils.core')
local Modules                = require("utils.modules")
local Logger                 = require("utils.logger")
local Strings                = require("utils.strings")
local Set                    = require('mq.set')

local Targetting             = { _version = '1.0', _name = "Targetting", _author = 'Derple', }
Targetting.__index           = Targetting
Targetting.ForceCombat       = false
Targetting.ForceNamed        = false
Targetting.ForceBurnTargetID = 0
Targetting.SafeTargetCache   = {}

function Targetting.IsNamed(spawn)
    return Modules:ExecModule("Named", "IsNamed", spawn)
end

--- Sets the target.
--- @param targetId number The ID of the target to be set.
--- @param ignoreBuffPopulation boolean? Wait to return until buffs are populated Default: false
function Targetting.SetTarget(targetId, ignoreBuffPopulation)
    if targetId == 0 then return end

    local maxWaitBuffs = ((mq.TLO.EverQuest.Ping() * 20) + 500)

    if targetId == mq.TLO.Target.ID() then return end
    Logger.log_debug("SetTarget(): Setting Target: %d (buffPopWait: %d)", targetId, ignoreBuffPopulation and 0 or maxWaitBuffs)
    if Config:GetSetting('DoAutoTarget') then
        if Targetting.GetTargetID() ~= targetId then
            mq.TLO.Spawn(targetId).DoTarget()
            mq.delay(10, function() return mq.TLO.Target.ID() == targetId end)
            mq.delay(maxWaitBuffs, function() return ignoreBuffPopulation or mq.TLO.Target.BuffsPopulated() end)
        end
    end
    Logger.log_debug("SetTarget(): Set Target to: %d (buffsPopulated: %s)", targetId, Strings.BoolToColorString(mq.TLO.Target.BuffsPopulated()))
end

--- Retrieves the current auto-target.
---
--- @return MQSpawn The current auto-target.
function Targetting.GetAutoTarget()
    return mq.TLO.Spawn(string.format("id %d", Config.Globals.AutoTargetID))
end

--- Clears the current target.
---
--- This function is used to clear any selected target in the game.
function Targetting.ClearTarget()
    Logger.log_debug("Clearing Target")
    if Config:GetSetting('DoAutoTarget') then
        Config.Globals.AutoTargetID = 0
        Config.Globals.ForceTargetID = 0
        if mq.TLO.Stick.Status():lower() == "on" then Core.DoCmd("/stick off") end
        Core.DoCmd("/target clear")
    end
end

--- Retrieves the ID of the given target.
--- @param target MQTarget? The target whose ID is to be retrieved.
--- @return number The ID of the target.
function Targetting.GetTargetID(target)
    return (target and target.ID() or (mq.TLO.Target.ID() or 0))
end

--- Checks if the target's body type matches the specified type.
--- @param target MQTarget The target whose body type is to be checked.
--- @param type string The body type to check against.
--- @return boolean True if the target's body type matches the specified type, false otherwise.
function Targetting.TargetBodyIs(target, type)
    if not target then target = mq.TLO.Target end
    if not target or not target() then return false end

    local targetBody = (target() and target.Body() and target.Body.Name()) or "none"
    return targetBody:lower() == type:lower()
end

--- Checks if the target's class is in the provided class table.
---
--- @param classTable string|table The string or table of strings containing class names to check against.
--- @param target MQTarget The class name of the target to check.
--- @return boolean True if the target's class is in the class table, false otherwise.
function Targetting.TargetClassIs(classTable, target)
    local classSet = type(classTable) == 'table' and Set.new(classTable) or Set.new({ classTable, })

    if not target then target = mq.TLO.Target end
    if not target or not target() or not target.Class() then return false end

    return classSet:contains(target.Class.ShortName() or "None")
end

--- Retrieves the level of the specified target.
---
--- @param target MQTarget? The target whose level is to be retrieved.
--- @return number The level of the target.
function Targetting.GetTargetLevel(target)
    return (target and target.Level() or (mq.TLO.Target.Level() or 0))
end

--- Calculates the distance to the specified target.
--- @param target MQTarget|MQSpawn? The target entity whose distance is to be calculated.
--- @return number The distance to the target.
function Targetting.GetTargetDistance(target)
    return (target and target.Distance() or (mq.TLO.Target.Distance() or 9999))
end

--- Calculates the vertical distance (Z-axis) to the specified target.
--- @param target MQTarget|MQSpawn? The target entity to measure the distance to.
--- @return number The vertical distance to the target.
function Targetting.GetTargetDistanceZ(target)
    return (target and target.DistanceZ() or (mq.TLO.Target.DistanceZ() or 9999))
end

--- Gets the maximum range to the specified target.
--- @param target MQTarget? The target entity to measure the range to.
--- @return number The maximum range to the target.
function Targetting.GetTargetMaxRangeTo(target)
    return (target and target.MaxRangeTo() or (mq.TLO.Target.MaxRangeTo() or 15))
end

--- Retrieves the percentage of hit points (HP) remaining for the specified target.
--- @param target MQTarget|MQSpawn? The target entity whose HP percentage is to be retrieved.
--- @return number The percentage of HP remaining for the target.
function Targetting.GetTargetPctHPs(target)
    local useTarget = target
    if not useTarget then useTarget = mq.TLO.Target end
    if not useTarget or not useTarget() then return 0 end

    return useTarget.PctHPs() or 0
end

--- Retrieves the percentage of HPs for auto-targeting.
---
--- @return number The percentage of HPs for auto-targeting.
function Targetting.GetAutoTargetPctHPs()
    local autoTarget = Targetting.GetAutoTarget()
    if not autoTarget or not autoTarget() then return 0 end
    return autoTarget.PctHPs() or 0
end

--- Checks if the specified target is dead.
--- @param target MQTarget The name or identifier of the target to check.
--- @return boolean Returns true if the target is dead, false otherwise.
function Targetting.GetTargetDead(target)
    local useTarget = target
    if not useTarget then useTarget = mq.TLO.Target end
    if not useTarget or not useTarget() then return true end

    return useTarget.Dead()
end

--- Retrieves the name of the given target.
--- @param target MQTarget? The target whose name is to be retrieved.
--- @return string The name of the target.
function Targetting.GetTargetName(target)
    return (target and target.Name() or (mq.TLO.Target.Name() or ""))
end

--- Retrieves the clean name of the given target.
--- @param target MQTarget|MQSpawn? The target from which to extract the clean name.
--- @return string The clean name of the target.
function Targetting.GetTargetCleanName(target)
    return (target and target.Name() or (mq.TLO.Target.CleanName() or ""))
end

--- Retrieves the aggro percentage of the current target.
--- @return number The aggro percentage of the current target.
function Targetting.GetTargetAggroPct()
    return (mq.TLO.Target.PctAggro() or 0)
end

--- Determines the type of the given target.
--- @param target MQSpawn|MQTarget|groupmember? The target whose type is to be determined.
--- @return string The type of the target as a string.
function Targetting.GetTargetType(target)
    local useTarget = target
    if not useTarget then useTarget = mq.TLO.Target end
    if not useTarget or not useTarget() then return "" end

    return (useTarget.Type() or "")
end

--- Checks if the target is of the specified type.
--- @param type string The type to check against the target.
--- @param target MQSpawn|groupmember|MQTarget? The target to be checked.
--- @return boolean Returns true if the target is of the specified type, false otherwise.
function Targetting.TargetIsType(type, target)
    return Targetting.GetTargetType(target):lower() == type:lower()
end

--- @param target MQTarget|nil
--- @return boolean
function Targetting.GetTargetAggressive(target)
    return (target and target.Aggressive() or (mq.TLO.Target.Aggressive() or false))
end

--- Retrieves the percentage by which the target is slowed.
--- @return number The percentage by which the target is slowed.
function Targetting.GetTargetSlowedPct()
    -- no valid target
    if mq.TLO.Target and not mq.TLO.Target.Slowed() then return 0 end

    return (mq.TLO.Target.Slowed.SlowPct() or 0)
end

--- Determines if the player is facing the target.
--- @return boolean True if the player is facing the target, false otherwise.
function Targetting.FacingTarget()
    if mq.TLO.Target.ID() == 0 then return true end

    return math.abs(mq.TLO.Target.HeadingTo.DegreesCCW() - mq.TLO.Me.Heading.DegreesCCW()) <= 20
end

--- Retrieves the highest aggro percentage among all players.
---
--- @return number The highest aggro percentage.
function Targetting.GetHighestAggroPct()
    local target     = mq.TLO.Target
    local me         = mq.TLO.Me

    local highestPct = target.PctAggro() or 0

    local xtCount    = mq.TLO.Me.XTarget()

    for i = 1, xtCount do
        local xtSpawn = mq.TLO.Me.XTarget(i)

        if xtSpawn() and (xtSpawn.ID() or 0) > 0 and (xtSpawn.TargetType():lower() == "auto hater" or Targetting.ForceCombat) then
            if xtSpawn.PctAggro() > highestPct then highestPct = xtSpawn.PctAggro() end
        end
    end

    return highestPct
end

--- Checks if the player has aggro based on a given percentage.
--- @param pct number The percentage threshold to determine if the player has aggro.
--- @return boolean Returns true if the player has aggro above the given percentage, false otherwise.
function Targetting.IHaveAggro(pct)
    local target = mq.TLO.Target
    local me     = mq.TLO.Me

    if (target() and (target.PctAggro() or 0) >= pct) then return true end

    local xtCount = mq.TLO.Me.XTarget()

    for i = 1, xtCount do
        local xtSpawn = mq.TLO.Me.XTarget(i)

        if xtSpawn() and (xtSpawn.ID() or 0) > 0 and (xtSpawn.TargetType():lower() == "auto hater" or Targetting.ForceCombat) then
            if xtSpawn.PctAggro() >= pct then return true end
        end
    end

    return false
end

--- Retrieves the IDs of the top haters.
--- @param printDebug boolean?: If true, debug information will be printed.
--- @return table: A table containing the IDs of the top haters.
function Targetting.GetXTHaterIDs(printDebug)
    local xtCount = mq.TLO.Me.XTarget() or 0
    local haters = {}

    for i = 1, xtCount do
        local xtarg = mq.TLO.Me.XTarget(i)
        if xtarg and xtarg.ID() > 0 and not xtarg.Dead() and (math.ceil(xtarg.PctHPs() or 0)) > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater") or Targetting.ForceCombat) then
            if printDebug then
                Logger.log_verbose("GetXTHaters(): XT(%d) Counting %s(%d) as a hater.", i, xtarg.CleanName() or "None", xtarg.ID())
            end

            table.insert(haters, xtarg.ID())
        end
    end

    return haters
end

--- Gets the count of XTHaters.
--- @param printDebug boolean?: If true, debug information will be printed.
--- @return number: The count of XTHaters.
function Targetting.GetXTHaterCount(printDebug)
    return #Targetting.GetXTHaterIDs(printDebug)
end

--- Computes the difference in Hater IDs.
---
--- @param t table The table containing Hater IDs.
--- @param printDebug boolean? Whether to print debug information.
--- @return boolean True if there is a difference, false otherwise
function Targetting.DiffXTHaterIDs(t, printDebug)
    local oldHaterSet = Set.new(t)
    local curHaters   = Targetting.GetXTHaterIDs(printDebug)

    for _, xtargID in ipairs(curHaters) do
        if not oldHaterSet:contains(xtargID) then return true end
    end

    return false
end

--- Checks if the given spawn is an XTHater.
--- @param spawnId number The ID of the spawn to check.
--- @return boolean True if the spawn is an XTHater, false otherwise.
function Targetting.IsSpawnXTHater(spawnId)
    local xtCount = mq.TLO.Me.XTarget() or 0

    for i = 1, xtCount do
        local xtarg = mq.TLO.Me.XTarget(i)
        if xtarg and xtarg.ID() == spawnId then return true end
    end

    return false
end

--- Adds an XT by its name to the specified slot.
--- @param slot number The slot number where the XT should be added.
--- @param name string The name of the XT to be added.
function Targetting.AddXTByName(slot, name)
    local spawnToAdd = mq.TLO.Spawn(name)
    if spawnToAdd and spawnToAdd() and mq.TLO.Me.XTarget(slot).ID() ~= spawnToAdd.ID() then
        Core.DoCmd("/xtarget set %d \"%s\"", slot, name)
    end
end

--- Adds an item to a slot by its ID.
--- @param slot number The slot number where the item should be added.
--- @param id number The ID of the item to be added.
function Targetting.AddXTByID(slot, id)
    local spawnToAdd = mq.TLO.Spawn(id)
    if spawnToAdd and spawnToAdd() and mq.TLO.Me.XTarget(slot).ID() ~= spawnToAdd.ID() then
        Core.DoCmd("/xtarget set %d \"%s\"", slot, spawnToAdd.CleanName())
    end
end

--- Resets the specified XT slot.
--- @param slot number The slot number to reset.
function Targetting.ResetXTSlot(slot)
    Core.DoCmd("/xtarget set %d autohater", slot)
end

--- Checks if a given spawn is fighting a stranger within a specified radius.
---
--- @param spawn MQSpawn The spawn object to check.
--- @param radius number The radius within which to check for strangers.
--- @return boolean Returns true if the spawn is fighting a stranger within the specified radius, false otherwise.
function Targetting.IsSpawnFightingStranger(spawn, radius)
    local searchTypes = { "PC", "PCPET", "MERCENARY", }

    for _, t in ipairs(searchTypes) do
        local count = mq.TLO.SpawnCount(string.format("%s radius %d zradius %d", t, radius, radius))()

        for i = 1, count do
            local cur_spawn = mq.TLO.NearestSpawn(i, string.format("%s radius %d zradius %d", t, radius, radius))

            if cur_spawn() and not Targetting.SafeTargetCache[cur_spawn.ID()] then
                if (cur_spawn.AssistName() or ""):len() > 0 then
                    Logger.log_verbose("My Interest: %s =? Their Interest: %s", spawn.Name(),
                        cur_spawn.AssistName())
                    if cur_spawn.AssistName() == spawn.Name() then
                        Logger.log_verbose("[%s] Fighting same mob as: %s Theirs: %s Ours: %s", t,
                            cur_spawn.CleanName(), cur_spawn.AssistName(), spawn.Name())
                        local checkName = cur_spawn and cur_spawn() or cur_spawn.CleanName() or "None"

                        if Targetting.TargetIsType("mercenary", cur_spawn) and cur_spawn.Owner() then checkName = cur_spawn.Owner.CleanName() end
                        if Targetting.TargetIsType("pet", cur_spawn) then checkName = cur_spawn.Master.CleanName() end

                        if not Targetting.IsSafeName("pc", checkName) then
                            Logger.log_verbose(
                                "\ar WARNING: \ax Almost attacked other PCs [%s] mob. Not attacking \aw%s\ax",
                                checkName, cur_spawn.AssistName())
                            return true
                        end
                    end
                end

                -- this is pretty expensive to calculate so lets cache it.
                Targetting.SafeTargetCache[cur_spawn.ID()] = true
            end
        end
    end

    return false
end

--- Checks if the given name is considered safe within the provided table.
--- @param spawnType string Type of spawn pc/pcpet/merc/etc.
--- @param name string The name to check for safety.
--- @return boolean Returns true if the name is safe, false otherwise.
function Targetting.IsSafeName(spawnType, name)
    Logger.log_verbose("IsSafeName(%s)", name)
    if mq.TLO.DanNet(name)() then
        Logger.log_verbose("IsSafeName(%s): Dannet Safe", name)
        return true
    end

    for _, n in ipairs(Config:GetSetting('OutsideAssistList')) do
        if name == n then
            Logger.log_verbose("IsSafeName(%s): OA Safe", name)
            return true
        end
    end

    if mq.TLO.Group.Member(name)() then
        Logger.log_verbose("IsSafeName(%s): Group Safe", name)
        return true
    end
    if mq.TLO.Raid.Member(name)() then
        Logger.log_verbose("IsSafeName(%s): Raid Safe", name)
        return true
    end

    if mq.TLO.Me.Guild() ~= nil then
        if mq.TLO.Spawn(string.format("%s =%s", spawnType, name)).Guild() == mq.TLO.Me.Guild() then
            Logger.log_verbose("IsSafeName(%s): Guild Safe", name)
            return true
        end
    end

    Logger.log_verbose("IsSafeName(%s): false", name)
    return false
end

--- Clears the Safe Target Cache after combat.
function Targetting.ClearSafeTargetCache()
    Targetting.SafeTargetCache = {}
end

return Targetting
