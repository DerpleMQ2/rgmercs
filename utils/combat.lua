local mq        = require('mq')
local Config    = require('utils.config')
local Logger    = require("utils.logger")
local Modules   = require("utils.modules")
local Math      = require("utils.math")
local Comms     = require("utils.comms")
local Core      = require("utils.core")
local Targeting = require("utils.targeting")
local DanNet    = require("lib.dannet.helpers")
local Strings   = require("utils.strings")
local Movement  = require("utils.movement")

local Combat    = { _version = '1.0', _name = "Combat", _author = 'Derple', }
Combat.__index  = Combat

--- This function is responsible for designating the main assist.
---
function Combat.SetMainAssist()
    local inRaid = mq.TLO.Raid.Members() > 0
    local inGroup = mq.TLO.Raid.Members() == 0 and mq.TLO.Group()

    if Config:GetSetting('UseAssistList') then
        if #Config:GetSetting('AssistList') > 0 then
            Logger.log_verbose("SetMainAssist: Checking Assist List.")
            for _, name in ipairs(Config:GetSetting('AssistList')) do
                Logger.log_verbose("SetMainAssist: Checking Assist List: %s", name)
                local listAssistSpawn = mq.TLO.Spawn(string.format("PC =%s", name))
                if listAssistSpawn() and not listAssistSpawn.Dead() then
                    local assistName = listAssistSpawn.CleanName()
                    if listAssistSpawn.ID() ~= Core.GetMainAssistId() then
                        Logger.log_info("SetMainAssist: Setting new assist to %s [%d]", assistName, listAssistSpawn.ID())
                        Config.Globals.MainAssist = assistName
                    end
                    if assistName ~= mq.TLO.Me.CleanName() then
                        Targeting.AddXTByName(2, assistName)
                    end
                    return
                end
            end
        end
    elseif inRaid then
        local raidAssistSpawn = mq.TLO.Raid.MainAssist(Config:GetSetting('RaidAssistTarget'))
        if raidAssistSpawn() and raidAssistSpawn.ID() > 0 and not raidAssistSpawn.Dead() then
            if raidAssistSpawn.ID() ~= Core.GetMainAssistId() then
                Logger.log_info("SetMainAssist: Setting new assist to %s [%d]", raidAssistSpawn.CleanName(), raidAssistSpawn.ID())
                Config.Globals.MainAssist = raidAssistSpawn.CleanName()
            end
            return
        end
    elseif inGroup then
        local groupAssistSpawn = mq.TLO.Group.MainAssist
        if groupAssistSpawn() and groupAssistSpawn.ID() > 0 and not groupAssistSpawn.Dead() then
            if groupAssistSpawn.ID() ~= Core.GetMainAssistId() then
                Logger.log_info("SetMainAssist: Setting new assist to %s [%d]", groupAssistSpawn.CleanName(), groupAssistSpawn.ID())
                Config.Globals.MainAssist = groupAssistSpawn.CleanName()
            end
            return
        end
    else
        Combat.SetMAToSelf()
        return
    end

    -- Check to see if we should fall back to ourselves based on our current group/raid/fallback settings.
    -- If we shouldn't, clear the MA so we don't go rogue on our group/raid and mess something up.
    local fallBackCheck = { false, inGroup, inRaid, true, } -- see SelfAssistFallback setting entry
    local fallBack = Config:GetSetting('SelfAssistFallback')
    if fallBackCheck[fallBack] then
        Combat.SetMAToSelf()
    else
        Config.Globals.MainAssist = ""
    end
end

function Combat.SetMAToSelf()
    if not Core.IAmMA() then -- only give the log message if we weren't already the MA
        Logger.log_info("SetMainAssist: No valid assists! Falling back to ourselves.")
    end
    Config.Globals.MainAssist = mq.TLO.Me.CleanName()
end

--- Engages the target specified by the given autoTargetId.
--- @param autoTargetId number The ID of the target to engage.
function Combat.EngageTarget(autoTargetId)
    if not Config:GetSetting('DoAutoEngage') then return end

    local target = mq.TLO.Target

    if mq.TLO.Me.State():lower() == "feign" and not Core.MyClassIs("mnk") and Config:GetSetting('AutoStandFD') then
        mq.TLO.Me.Stand()
    end

    Logger.log_verbose("\awNOTICE:\ax EngageTarget(%s) Checking for valid Target.", Targeting.GetTargetCleanName())

    if target() and (target.ID() or 0) == autoTargetId and Targeting.GetTargetDistance() <= Config:GetSetting('AssistRange') then
        if (Targeting.GetTargetPctHPs() <= Config:GetSetting('AutoAssistAt') or Core.IAmMA()) and not Targeting.GetTargetDead(target) then
            if not mq.TLO.Me.Combat() then
                local classConfig = Modules:ExecModule("Class", "GetClassConfig")
                if classConfig and classConfig.HelperFunctions and classConfig.HelperFunctions.PreEngage then
                    classConfig.HelperFunctions.PreEngage(target)
                end
            end

            if Config:GetSetting('DoMelee') then
                if mq.TLO.Me.Sitting() then
                    mq.TLO.Me.Stand()
                end

                if Targeting.GetTargetDistance(target) > Targeting.GetTargetMaxRangeTo(target) then
                    Logger.log_verbose("EngageTarget(): Target is too far! %d>%d attempting to nav to it.", target.Distance3D(),
                        target.MaxRangeTo())

                    Movement:NavInCombat(autoTargetId, Targeting.GetTargetMaxRangeTo(target), false)
                else
                    Logger.log_verbose("EngageTarget(): Target is in range moving to combat")
                    if mq.TLO.Navigation.Active() then
                        Core.DoCmd("/nav stop log=off")
                    end
                    if mq.TLO.Stick.Status():lower() == "off" then
                        Movement:DoStick(autoTargetId)
                    end
                end

                if not mq.TLO.Me.Combat() then
                    Logger.log_info("\awNOTICE:\ax Engaging %s in mortal combat.", Targeting.GetTargetCleanName())
                    if Core.IAmMA() then
                        Comms.HandleAnnounce(string.format('TANKING -> %s <-', Targeting.GetTargetCleanName()), Config:GetSetting('AnnounceTargetGroup'),
                            Config:GetSetting('AnnounceTarget'))
                    end
                    Logger.log_debug("EngageTarget(): Attacking target!")
                    if Core.MyClassIs("ROG") and mq.TLO.Me.AbilityReady("Backstab")() then
                        local maxWait = 2000
                        while maxWait > 0 do
                            if Targeting.GetTargetDistance(target) <= Targeting.GetTargetMaxRangeTo(target) then
                                break
                            end
                            mq.delay(100)
                            Logger.log_verbose("EngageTarget(): Rogue closing distance before opening with backstab.")
                            maxWait = maxWait - 100
                        end
                        if maxWait <= 0 then Logger.log_verbose("EngageTarget(): Rogue did not close distance within two seconds, moving on.") end
                        Core.DoCmd("/doability Backstab")
                    end
                    Core.DoCmd("/attack on")
                else
                    Logger.log_verbose("EngageTarget(): Target already engaged not re-engaging.")
                end
            else
                Logger.log_verbose("\awNOTICE:\ax EngageTarget(%s) DoMelee is false.", Targeting.GetTargetCleanName())

                if not Config:GetSetting('DoMelee') and Config:GetSetting("BellyCastStick") and Config.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and target.Body.Name() == "Dragon" and Targeting.IsNamed(target) then
                    Logger.log_verbose("\awNOTICE:\ax EngageTarget(%s) Dragon Named detected, sticking for belly cast.", Targeting.GetTargetCleanName())
                    Movement:DoStickCmd("pin 40")
                end

                if Core.MyClassIs("RNG") and not mq.TLO.Me.AutoFire() then
                    Logger.log_verbose("\awNOTICE:\ax EngageTarget(%s) turning autofire on.", Targeting.GetTargetCleanName())
                    Core.DoCmd('/squelch face fast')
                    Core.DoCmd('/autofire on')
                end
            end

            -- TODO: why are we doing this after turning stick on just now?
            --if mq.TLO.Stick.Status():lower() == "on" then Movement:DoStickCmd("off") end
        end
    else
        Logger.log_verbose("\awNOTICE:\ax EngageTarget(%s) Target is above Assist HP or Dead.",
            Targeting.GetTargetCleanName())
    end
end

--- MercAssist handles the assistance logic for mercenaries.
--- This function is responsible for coordinating the actions of mercenaries to assist in combat or other tasks.
---
function Combat.MercAssist()
    mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_CallForAssistButton").LeftMouseUp()
end

--- Engages the mercenaries in combat.
---
--- This function initiates the engagement process for mercenaries.
--- It is typically called when mercenaries need to start fighting.
---
function Combat.MercEngage()
    local merc = mq.TLO.Me.Mercenary

    if merc() and Targeting.GetTargetID() == Config.Globals.AutoTargetID and Targeting.GetTargetDistance() < Config:GetSetting('AssistRange') then
        if Targeting.GetTargetPctHPs() <= Config:GetSetting('AutoAssistAt') or                         -- Hit Assist HP
            merc.Class.ShortName():lower() == "clr" or                                                 -- Cleric can engage right away
            (merc.Class.ShortName():lower() == "war" and mq.TLO.Group.MainTank.ID() == merc.ID()) then -- Merc is our Main Tank
            return true
        end
    end

    return false
end

--- Kills the player's pet.
---
--- This function is used to terminate the player's pet in the game.
--- It performs necessary checks and actions to ensure the pet is properly removed.
function Combat.KillPCPet()
    Logger.log_warn("\arKilling your pet!")
    local problemPetOwner = mq.TLO.Spawn(string.format("id %d", mq.TLO.Me.XTarget(1).ID())).Master.CleanName()

    if problemPetOwner == mq.TLO.Me.DisplayName() then
        Core.DoCmd("/pet leave")
    else
        Core.DoCmd("/dex %s /pet leave", problemPetOwner)
    end
end

--- Checks if combat actions should happen
--- This function handles the combat logic for the Casting module.
---
--- @return boolean True if actions should happen.
function Combat.DoCombatActions()
    if not Config.Globals.LastMove then return false end
    if Config.Globals.AutoTargetID == 0 then return false end
    if Targeting.GetXTHaterCount() == 0 then return false end

    -- We can't assume our target is our autotargetid for where this sub is used.
    local autoSpawn = mq.TLO.Spawn(Config.Globals.AutoTargetID)
    if autoSpawn() and Targeting.GetTargetDistance(autoSpawn) > Config:GetSetting('AssistRange') then return false end

    return true
end

--- Scans for targets within a specified radius.
---
--- @param radius number The horizontal radius to scan for targets.
--- @param zradius number The vertical radius to scan for targets.
--- @return number spawn id of the new target.
function Combat.MATargetScan(radius, zradius)
    local aggroSearch    = string.format("npc radius %d zradius %d targetable playerstate 4", radius, zradius)
    local aggroSearchPet = string.format("npcpet radius %d zradius %d targetable playerstate 4", radius, zradius)

    local lowestHP       = Targeting.GetAutoTargetPctHPs() > 0 and Targeting.GetAutoTargetPctHPs() or 101
    local killId         = Config.Globals.AutoTargetID or 0

    -- Maybe spawn search is failing us -- look through the xtarget list
    local xtCount        = mq.TLO.Me.XTarget()

    for i = 1, xtCount do
        local xtSpawn = mq.TLO.Me.XTarget(i)

        if xtSpawn and xtSpawn() and (xtSpawn.ID() or 0) > 0 and not xtSpawn.Dead() and (xtSpawn.TargetType():lower() == "auto hater" or Targeting.ForceCombat) then
            if not Config:GetSetting('SafeTargeting') or not Targeting.IsSpawnFightingStranger(xtSpawn, radius) then
                Logger.log_verbose("Found %s [%d] Distance: %d", xtSpawn.CleanName() or "None", xtSpawn.ID() or 0,
                    xtSpawn.Distance() or 0)
                if (xtSpawn.Distance() or 999) <= radius then
                    -- Check for lack of aggro and make sure we get the ones we haven't aggro'd. We can't
                    -- get aggro data from the spawn data type.
                    if mq.TLO.Me.Level() >= 20 then
                        -- Added move check to prevent false positives on the pull from things like bard song aggro. Testing. Algar 3/5/25
                        if xtSpawn.PctAggro() < 100 and not xtSpawn.Moving() and Core.IsTanking() then
                            -- Coarse check to determine if a mob is _not_ mezzed. No point in waking a mezzed mob if we don't need to.
                            if Config.Constants.RGMezAnims:contains(xtSpawn.Animation()) then
                                Logger.log_verbose("\agHave not fully aggro'd %s -- returning %s [%d]",
                                    xtSpawn.CleanName(), xtSpawn.CleanName(), xtSpawn.ID())
                                return xtSpawn.ID() or 0
                            end
                        end
                    end

                    -- If a name has take priority.
                    if Targeting.IsNamed(xtSpawn) then
                        Logger.log_verbose("\agFound Named: %s -- returning %d", xtSpawn.CleanName(), xtSpawn.ID())
                        return xtSpawn.ID() or 0
                    end

                    if (xtSpawn.Body.Name() or "none"):lower() == "Giant" then
                        return xtSpawn.ID() or 0
                    end

                    if (xtSpawn.PctHPs() or 101) < lowestHP then
                        Logger.log_verbose("\atFound Possible Target: %s :: %d --  Storing for Lowest HP Check", xtSpawn.CleanName(), xtSpawn.ID())
                        lowestHP = xtSpawn.PctHPs() or 0
                        killId = xtSpawn.ID() or 0
                    end
                else
                    Logger.log_verbose("\ar%s distance[%d] is out of radius: %d", xtSpawn.CleanName(), xtSpawn.Distance() or 0, radius)
                end
            else
                Logger.log_verbose("XTarget %s [%d] Distance: %d - is fighting someone else - ignoring it.",
                    xtSpawn.CleanName(), xtSpawn.ID(), xtSpawn.Distance())
            end
        end
    end

    if not Config:GetSetting('OnlyScanXT') then
        Logger.log_verbose("We apparently didn't find anything on xtargets, doing a search for mezzed targets")

        -- We didn't find anything to kill yet so spawn search
        if killId == 0 then
            Logger.log_verbose("Falling back on Spawn Searching")
            local aggroMobCount = mq.TLO.SpawnCount(aggroSearch)()
            local aggroMobPetCount = mq.TLO.SpawnCount(aggroSearchPet)()
            Logger.log_verbose("NPC Target Scan: %s ===> %d", aggroSearch, aggroMobCount)
            Logger.log_verbose("NPCPET Target Scan: %s ===> %d", aggroSearchPet, aggroMobPetCount)

            for i = 1, aggroMobCount do
                local spawn = mq.TLO.NearestSpawn(i, aggroSearch)

                if spawn and spawn() and (spawn.CleanName() or "None"):find("Guard") == nil then
                    -- If the spawn is already in combat with someone else, we should skip them.
                    if not Config:GetSetting('SafeTargeting') or not Targeting.IsSpawnFightingStranger(spawn, radius) then
                        -- If a name has pulled in we target the name first and return. Named always
                        -- take priority. Note: More mobs as of ToL are "named" even though they really aren't.

                        if Targeting.IsNamed(spawn) then
                            Logger.log_verbose("DEBUG Found Named: %s -- returning %d", spawn.CleanName(), spawn.ID())
                            return spawn.ID()
                        end

                        -- Unmezzables
                        if (spawn.Body.Name() or "none"):lower() == "Giant" then
                            return spawn.ID()
                        end

                        -- Lowest HP
                        if (spawn.PctHPs() or 101) < lowestHP then
                            lowestHP = spawn.PctHPs()
                            killId = spawn.ID()
                        end
                    end
                end
            end

            for i = 1, aggroMobPetCount do
                local spawn = mq.TLO.NearestSpawn(i, aggroSearchPet)

                if not Config:GetSetting('SafeTargeting') or not Targeting.IsSpawnFightingStranger(spawn, radius) then
                    -- Lowest HP
                    if (spawn.PctHPs() or 101) < lowestHP then
                        lowestHP = spawn.PctHPs()
                        killId = spawn.ID()
                    end
                end
            end
        end
    end

    Logger.log_verbose("\agMATargetScan Returning: \at%d", killId)
    return killId
end

--- Sets the AutoTarget to that of your group or raid MA.
function Combat.SetAutoTargetToGroupOrRaidTarget()
    if mq.TLO.Raid.Members() > 0 then
        local assistTarg = Config:GetSetting('RaidAssistTarget')
        Config.Globals.AutoTargetID = ((mq.TLO.Me.RaidAssistTarget(assistTarg) and mq.TLO.Me.RaidAssistTarget(assistTarg).ID()) or 0)
    elseif mq.TLO.Group.Members() > 0 then
        --- @diagnostic disable-next-line: undefined-field
        Config.Globals.AutoTargetID = ((mq.TLO.Me.GroupAssistTarget() and mq.TLO.Me.GroupAssistTarget.ID()) or 0)
    end
end

--- This will find a valid target and set it to : Config.Globals.AutoTargetID
--- @param validateFn function? A function used to validate potential targets. Should return true for valid targets and false otherwise.
function Combat.FindBestAutoTarget(validateFn)
    Logger.log_verbose("FindTarget()")
    if mq.TLO.Spawn(string.format("id %d pcpet xtarhater", mq.TLO.Me.XTarget(1).ID())).ID() > 0 and Config:GetSetting('ForceKillPet') then
        Logger.log_verbose("FindTarget() Determined that xtarget(1)=%s is a pcpet xtarhater",
            mq.TLO.Me.XTarget(1).CleanName())
        Combat.KillPCPet()
    end

    -- Handle cases where our autotarget is no longer valid because it isn't a valid spawn or is dead.
    if Config.Globals.AutoTargetID ~= 0 then
        local autoSpawn = mq.TLO.Spawn(string.format("id %d", Config.Globals.AutoTargetID))
        if not autoSpawn or not autoSpawn() or Targeting.TargetIsType("corpse", autoSpawn) then
            Logger.log_debug("\ayFindTarget() : Clearing Target (%d/%s) because it is a corpse or no longer valid.", Config.Globals.AutoTargetID,
                autoSpawn and (autoSpawn.CleanName() or "Unknown") or "None")
            Targeting.ClearTarget()
        end
    end

    -- FollowMarkTarget causes RG to have allow RG toons focus on who the group has marked. We'll exit early if this is the case.
    if Config:GetSetting('FollowMarkTarget') then
        if mq.TLO.Me.GroupMarkNPC(1).ID() and Config.Globals.AutoTargetID ~= mq.TLO.Me.GroupMarkNPC(1).ID() then
            Config.Globals.AutoTargetID = mq.TLO.Me.GroupMarkNPC(1).ID()
            return
        end
    end

    local target = mq.TLO.Target

    -- Now handle normal situations where we need to choose a target because we don't have one.
    if Core.IAmMA() then
        Logger.log_verbose("FindTarget() ==> I am MA!")
        if Config.Globals.ForceTargetID ~= 0 then
            local forceSpawn = mq.TLO.Spawn(Config.Globals.ForceTargetID)
            if forceSpawn and forceSpawn() and not forceSpawn.Dead() then
                if Config.Globals.AutoTargetID ~= Config.Globals.ForceTargetID then
                    Config.Globals.AutoTargetID = Config.Globals.ForceTargetID
                    Logger.log_info("FindTarget(): Forced Targeting: \ag%s\ax [ID: \ag%d\ax]", forceSpawn.CleanName() or "None", forceSpawn.ID())
                end
            else
                Config.Globals.ForceTargetID = 0
            end
        else
            local targetValid = (Targeting.TargetIsType("npc", target) or Targeting.TargetIsType("npcpet", target))
                and target.Mezzed.ID() == nil and target.Charmed.ID() == nil
                and Targeting.GetTargetDistance(target) < Config:GetSetting('AssistRange')
                and Targeting.GetTargetDistanceZ(target) < 20
                and Targeting.GetTargetAggressive(target)

            -- We need to handle manual targeting and autotargeting seperately
            if not Config:GetSetting('DoAutoTarget') then
                -- Manual targeting (or pull targeting) let the manual user target any npc or npcpet.
                if Config.Globals.AutoTargetID ~= target.ID() and targetValid then
                    Logger.log_info("FindTarget(): Targeting: \ag%s\ax [ID: \ag%d\ax]", target.CleanName() or "None", target.ID())
                    Config.Globals.AutoTargetID = target.ID()
                end
            else
                -- If we don't have an AutoTarget and we are using the AutoTarget System:
                -- If we already have a target, we should check to see if we automatically pulled it, or if it is likely that we manually pulled it.)
                -- If not, we need to scan our nearby area and choose a target based on our built in algorithm. We
                -- only need to do this if we don't already have a target. Assume if any mob runs into camp, we shouldn't reprioritize
                -- unless specifically told.

                if Config.Globals.AutoTargetID == 0 then
                    if Config.Globals.LastPulledID > 0 and Targeting.IsSpawnXTHater(Config.Globals.LastPulledID) then
                        Logger.log_verbose("It seems that we pulled %s(ID: %d), setting it as the initial AutoTarget.",
                            mq.TLO.Spawn(Config.Globals.LastPulledID).CleanName() or "None", Config.Globals.LastPulledID)
                        Config.Globals.AutoTargetID = Config.Globals.LastPulledID
                    elseif target.ID() > 0 and (target and target.Distance3D() or 0) > Targeting.GetTargetMaxRangeTo(target) and targetValid then
                        Logger.log_verbose("It seems that we manually pulled %s(ID: %d), setting it as the initial AutoTarget.", target.CleanName(), target.ID())
                        Config.Globals.AutoTargetID = target.ID()
                    else
                        -- Set our autotarget to the target MATargetScan chooses.
                        Config.Globals.AutoTargetID = Combat.MATargetScan(Config:GetSetting('AssistRange'),
                            Config:GetSetting('MAScanZRange'))
                        Logger.log_verbose("MATargetScan returned %d -- Setting initial AutoTarget: %s",
                            Config.Globals.AutoTargetID, mq.TLO.Spawn(Config.Globals.AutoTargetID).CleanName() or "None")
                    end
                end
                -- If StayOnTarget is off, we're going to scan if we don't have full aggro. As this is a dev applied setting that defaults to on, it should
                -- Only be turned off by tank modes. -- Jokes on you, guy who wrote this... I have this off on all of my characters and have for months. - Algar
                if not Config:GetSetting('StayOnTarget') then
                    Config.Globals.AutoTargetID = Combat.MATargetScan(Config:GetSetting('AssistRange'),
                        Config:GetSetting('MAScanZRange'))
                    local autoTarget = mq.TLO.Spawn(Config.Globals.AutoTargetID)
                    Logger.log_verbose(
                        "Re-Targeting: MATargetScan says we need to autotarget %s [%d] -- Current Target: %s [%d]",
                        autoTarget.CleanName() or "None", Config.Globals.AutoTargetID or 0,
                        target() and target.CleanName() or "None", target() and target.ID() or 0)
                end
            end
        end
    else
        -- We're not the main assist so we need to choose our target based on our main assist.
        -- Only change if the group main assist target is an NPC ID that doesn't match the current autotargetid. This prevents us from
        -- swapping to non-NPCs if the  MA is trying to heal/buff a friendly or themselves.
        if Config:GetSetting('UseAssistList') and Config.Globals.MainAssist:len() > 0 then
            --- @diagnostic disable-next-line: redundant-parameter
            local peer = mq.TLO.DanNet(Config.Globals.MainAssist)()
            local assistTarget = nil

            if peer then
                local queryResult = DanNet.query(Config.Globals.MainAssist, "Target.ID", 1000)
                if queryResult then
                    assistTarget = mq.TLO.Spawn(queryResult)
                    Logger.log_verbose("\ayFindTargetCheck Assist's Target via DanNet :: %s (%s)",
                        assistTarget.CleanName() or "None", queryResult)
                end
            else
                local assistSpawn = Core.GetMainAssistSpawn()
                if assistSpawn and assistSpawn() then
                    Targeting.SetTarget(assistSpawn.ID(), true)
                    assistTarget = mq.TLO.Me.TargetOfTarget
                    Logger.log_verbose("\ayFindTargetCheck Assist's Target via TargetOfTarget :: %s ",
                        assistTarget.CleanName() or "None")
                end
            end

            Logger.log_verbose("FindTarget Assisting %s -- Target Agressive: %s", Config.Globals.MainAssist,
                Strings.BoolToColorString(assistTarget and assistTarget.Aggressive() or false))

            if assistTarget and assistTarget() and (Targeting.TargetIsType("npc", assistTarget) or Targeting.TargetIsType("npcpet", assistTarget)) then
                Logger.log_verbose(" FindTarget Setting Target To %s [%d]", assistTarget.CleanName(),
                    assistTarget.ID())
                Config.Globals.AutoTargetID = assistTarget.ID()
            end
        else
            Combat.SetAutoTargetToGroupOrRaidTarget()
        end
    end

    Logger.log_verbose("FindTarget(): FoundTargetID(%d), myTargetId(%d)", Config.Globals.AutoTargetID or 0,
        mq.TLO.Target.ID())

    local autoTargetId = Config.Globals.AutoTargetID
    if autoTargetId > 0 and (validateFn and validateFn(autoTargetId)) then
        if mq.TLO.Target.ID() ~= autoTargetId then
            Targeting.SetTarget(autoTargetId)
        end

        -- For Assist Lists, this ensures we correctly and quickly receive health percent to assist in a timely manner
        -- For Emu, this helps correct for emu xtarget bugs
        -- Second dead check because targets were ocasionally dying between the validateFn and this check
        if Config:GetSetting('UseAssistList') or Core.OnEMU() then
            if mq.TLO.Spawn(autoTargetId)() and not mq.TLO.Spawn(autoTargetId).Dead() and not Targeting.IsSpawnXTHater(autoTargetId) then
                Targeting.AddXTByID(1, Config.Globals.AutoTargetID)
                Logger.log_verbose("FindTarget(): FoundTargetID(%d) not on xt list, adding.", autoTargetId or 0)
            end
        end
    end
end

--- Finds and checks the target.
---
--- This function performs a check on the current target to determine if it meets certain criteria.
---
--- @return boolean True if the target meets the criteria, false otherwise.
function Combat.FindBestAutoTargetCheck()
    Logger.log_verbose("FindTargetCheck(%d, %s, %s, %s)", Targeting.GetXTHaterCount(),
        Strings.BoolToColorString(Core.IAmMA()), Strings.BoolToColorString(Config:GetSetting('FollowMarkTarget')),
        Strings.BoolToColorString(Config.Globals.BackOffFlag))

    local assistTarg = false

    -- check if our MA has a valid target for us. Check Assist List if on, or check everyone on emu to get around emu xtarget bugs
    if (Config:GetSetting('UseAssistList') or Core.OnEMU()) and not Core.IAmMA() and Config.Globals.MainAssist:len() > 0 then
        --- @diagnostic disable-next-line: redundant-parameter
        local peer = mq.TLO.DanNet(Config.Globals.MainAssist)()
        if peer then
            local queryResult = DanNet.query(Config.Globals.MainAssist, "Target.ID", 1000)
            if queryResult then
                local assistTarget = mq.TLO.Spawn(queryResult)
                Logger.log_verbose("\ayFindTargetCheck Assist's Target via DanNet :: %s",
                    assistTarget.CleanName() or "None")
                if assistTarget and assistTarget() then
                    assistTarg = true
                end
            end
        end
    end

    return (Targeting.GetXTHaterCount() > 0 or Core.IAmMA() or Config:GetSetting('FollowMarkTarget') or assistTarg) and
        not Config.Globals.BackOffFlag
end

--- Validates if it is acceptable to engage with a target based on its ID.
--- This function performs pre-validation checks to determine if engagement is permissible.
---
--- @param targetId number The ID of the target to be validated.
--- @return boolean Returns true if it is acceptable to engage with the target, false otherwise.
function Combat.OkToEngagePreValidateId(targetId)
    if not Config:GetSetting('DoAutoEngage') then return false end
    local target = mq.TLO.Spawn(targetId)
    local assistId = Core.GetMainAssistId()

    if not target() or target.Dead() then return false end

    local pcCheck = Targeting.TargetIsType("pc", target) or
        (Targeting.TargetIsType("pet", target) and Targeting.TargetIsType("pc", target.Master))
    local mercCheck = Targeting.TargetIsType("mercenary", target)
    if pcCheck or mercCheck then
        if not mq.TLO.Me.Combat() then
            Logger.log_verbose(
                "\ay[2] Target type check failed \aw[\atpcCheckFailed(%s) mercCheckFailed(%s)\aw]\ay",
                Strings.BoolToColorString(pcCheck), Strings.BoolToColorString(mercCheck))
        end
        return false
    end

    if Config:GetSetting('SafeTargeting') and Targeting.IsSpawnFightingStranger(target, 100) then
        Logger.log_verbose("\ay  OkToEngageId(%s) is fighting Stranger --> Not Engaging",
            Targeting.GetTargetCleanName())
        return false
    end

    if not Config.Globals.BackOffFlag then --Targeting.GetXTHaterCount() > 0 and not Config.Globals.BackOffFlag then
        local distanceCheck = Targeting.GetTargetDistance(target) < Config:GetSetting('AssistRange')
        local assistCheck = (Targeting.GetTargetPctHPs(target) <= Config:GetSetting('AutoAssistAt') or Core.IsTanking() or Core.IAmMA())
        if distanceCheck and assistCheck then
            if not mq.TLO.Me.Combat() then
                Logger.log_verbose(
                    "\ag  OkToEngageId(%s) %d < %d and %d < %d or Tanking or %d == %d --> \agOK To Engage!",
                    Targeting.GetTargetCleanName(target),
                    Targeting.GetTargetDistance(target), Config:GetSetting('AssistRange'), Targeting.GetTargetPctHPs(target),
                    Config:GetSetting('AutoAssistAt'), assistId,
                    mq.TLO.Me.ID())
            end
            return true
        else
            Logger.log_verbose(
                "\ay  OkToEngageId(%s) AssistCheck failed for: %s / %d distanceCheck(%s/%d), assistCheck(%s)",
                Targeting.GetTargetCleanName(target),
                target.CleanName(), target.ID(), Strings.BoolToColorString(distanceCheck), Targeting.GetTargetDistance(target),
                Strings.BoolToColorString(assistCheck))
            return false
        end
    end

    Logger.log_verbose("\ay  OkToEngageId(%s) Okay to Engage Failed with Fall Through!",
        Targeting.GetTargetCleanName(target),
        Strings.BoolToColorString(pcCheck), Strings.BoolToColorString(mercCheck))
    return false
end

--- Determines if it is acceptable to engage a target.
--- @param autoTargetId number The ID of the target to check.
--- @return boolean Returns true if it is okay to engage the target, false otherwise.
function Combat.OkToEngage(autoTargetId)
    if not Config:GetSetting('DoAutoEngage') then return false end
    local target = mq.TLO.Target
    local assistId = Core.GetMainAssistId()

    if not target() or target.Dead() then return false end

    local pcCheck = Targeting.TargetIsType("pc", target) or
        (Targeting.TargetIsType("pet", target) and Targeting.TargetIsType("pc", target.Master))
    local mercCheck = Targeting.TargetIsType("mercenary", target)
    if pcCheck or mercCheck then
        if not mq.TLO.Me.Combat() then
            Logger.log_verbose(
                "\ay[2] Target type check failed \aw[\atpcCheckFailed(%s) mercCheckFailed(%s)\aw]\ay",
                Strings.BoolToColorString(pcCheck), Strings.BoolToColorString(mercCheck))
        end
        return false
    end

    if Config:GetSetting('SafeTargeting') and Targeting.IsSpawnFightingStranger(target, 100) then
        Logger.log_verbose("\ay  OkayToEngage() %s is fighting Stranger --> Not Engaging",
            Targeting.GetTargetCleanName())
        return false
    end

    if Targeting.GetTargetID() ~= autoTargetId then
        Logger.log_verbose("  OkayToEngage() %d != %d --> Not Engaging", target.ID() or 0, autoTargetId)
        return false
    end

    -- if this target is from a target ID then it wont have .Mezzed
    if target.Mezzed() and target.Mezzed.ID() and not Config:GetSetting('AllowMezBreak') then
        Logger.log_debug("  OkayToEngage() Target is mezzed and not AllowMezBreak --> Not Engaging")
        return false
    end

    if not Config.Globals.BackOffFlag then --Targeting.GetXTHaterCount() > 0 and not Config.Globals.BackOffFlag then
        local distanceCheck = Targeting.GetTargetDistance() < Config:GetSetting('AssistRange')
        local assistCheck = (Targeting.GetTargetPctHPs() <= Config:GetSetting('AutoAssistAt') or Core.IsTanking() or Core.IAmMA())
        if distanceCheck and assistCheck then
            if not mq.TLO.Me.Combat() then
                Logger.log_verbose(
                    "\ag  OkayToEngage(%s) %d < %d and %d < %d or Tanking or %d == %d --> \agOK To Engage!",
                    Targeting.GetTargetCleanName(),
                    Targeting.GetTargetDistance(), Config:GetSetting('AssistRange'), Targeting.GetTargetPctHPs(), Config:GetSetting('AutoAssistAt'), assistId,
                    mq.TLO.Me.ID())
            end
            return true
        else
            Logger.log_verbose(
                "\ay  OkayToEngage() AssistCheck failed for: %s / %d distanceCheck(%s/%d), assistCheck(%s)",
                target.CleanName(), target.ID(), Strings.BoolToColorString(distanceCheck), Targeting.GetTargetDistance(),
                Strings.BoolToColorString(assistCheck))
            return false
        end
    end

    Logger.log_verbose("\ay  OkayToEngage() Okay to Engage Failed with Fall Through!",
        Strings.BoolToColorString(pcCheck), Strings.BoolToColorString(mercCheck))
    return false
end

--- Sends your pet in to attack.
--- @param targetId number The ID of the target to attack.
--- @param sendSwarm boolean Whether to send a swarm attack or not.
function Combat.PetAttack(targetId, sendSwarm)
    local pet = mq.TLO.Me.Pet

    local target = mq.TLO.Spawn(targetId)

    if not target() then return end
    if pet.ID() == 0 then return end

    if Config:GetSetting('DoPetCommands') and (not pet.Combat() or pet.Target.ID() ~= target.ID()) and Targeting.TargetIsType("NPC", target) then
        Core.DoCmd("/squelch /pet attack %d", targetId)
        if sendSwarm then
            Core.DoCmd("/squelch /pet swarm")
        end
        Logger.log_debug("Pet sent to attack target: %s!", target.Name())
    end
end

--- Determines whether the target should be reset for killing.
---
--- @return boolean True if the target should be reset, false otherwise.
function Combat.ShouldKillTargetReset()
    local killSpawn = mq.TLO.Spawn(string.format("targetable id %d", Config.Globals.AutoTargetID))
    local killCorpse = mq.TLO.Spawn(string.format("corpse id %d", Config.Globals.AutoTargetID))
    return (((not killSpawn() or killSpawn.Dead()) or killCorpse()) and Config.Globals.AutoTargetID > 0) and true or
        false
end

--- Checks if we should be doing our camping functionality
--- This function handles the logic required to return to camp.
---
--- @return boolean
function Combat.ShouldDoCamp()
    return
        (Targeting.GetXTHaterCount() == 0 and Config.Globals.AutoTargetID == 0) or
        (not Core.IsTanking() and Targeting.GetAutoTargetPctHPs() > Config:GetSetting('AutoAssistAt'))
end

--- Checks if the auto camp feature should be activated based on the provided temporary configuration.
--- @param tempConfig table: A table containing temporary configuration settings for the auto camp feature.
function Combat.AutoCampCheck(tempConfig)
    if not Config:GetSetting('ReturnToCamp') then return end

    if mq.TLO.Me.Casting() and not Core.MyClassIs("brd") then return end

    -- chasing a toon dont use camnp.
    if Config:GetSetting('ChaseOn') then return end

    -- camped in a different zone.
    if tempConfig.CampZoneId ~= mq.TLO.Zone.ID() then return end

    -- let pulling module handle camp decisions while it is enabled.
    if Config:GetSetting('DoPull') then
        local pullState = Modules:ExecModule("Pull", "GetPullState")

        -- if we are idle or in groupwatch waiting its possible we wandered out of camp to loot and need to come back.
        if pullState > 2 then
            return
        end
    end

    local me = mq.TLO.Me

    local distanceToCamp = Math.GetDistance(me.Y(), me.X(), tempConfig.AutoCampY, tempConfig.AutoCampX)

    if distanceToCamp >= 400 then
        Comms.PrintGroupMessage("I'm over 400 units from camp, not returning!")
        Core.DoCmd("/rgl campoff")
        return
    end

    if not Config:GetSetting('CampHard') then
        if distanceToCamp < Config:GetSetting('AutoCampRadius') then return end
    end

    if distanceToCamp > 5 then
        local navTo = string.format("locyxz %d %d %d", tempConfig.AutoCampY, tempConfig.AutoCampX, tempConfig.AutoCampZ)
        if mq.TLO.Navigation.PathExists(navTo)() then
            Core.DoCmd("/nav %s", navTo)
            mq.delay("2s", function() return mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 end)
            while mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 do
                mq.delay(10)
                mq.doevents()
            end
        else
            Core.DoCmd("/moveto loc %d %d|on", tempConfig.AutoCampY, tempConfig.AutoCampX)
            while mq.TLO.MoveTo.Moving() and not mq.TLO.MoveTo.Stopped() do
                mq.delay(10)
                mq.doevents()
            end
        end
    end

    if mq.TLO.Navigation.Active() then
        Core.DoCmd("/nav stop")
    end
end

--- Checks the combat camp configuration.
--- @param tempConfig table: A table containing temporary configuration settings.
function Combat.CombatCampCheck(tempConfig)
    if not Config:GetSetting('ReturnToCamp') then return end

    if mq.TLO.Me.Casting() and not Core.MyClassIs("brd") then return end

    -- chasing a toon dont use camnp.
    if Config:GetSetting('ChaseOn') then return end

    -- camped in a different zone.
    if tempConfig.CampZoneId ~= mq.TLO.Zone.ID() then return end

    local me = mq.TLO.Me

    local distanceToCampSq = Math.GetDistanceSquared(me.Y(), me.X(), tempConfig.AutoCampY, tempConfig.AutoCampX)

    if not Config:GetSetting('CampHard') then
        if distanceToCampSq < Config:GetSetting('AutoCampRadius') ^ 2 then return end
    end

    if distanceToCampSq > 25 then
        local navTo = string.format("locyxz %d %d %d", tempConfig.AutoCampY, tempConfig.AutoCampX, tempConfig.AutoCampZ)
        if mq.TLO.Navigation.PathExists(navTo)() then
            Core.DoCmd("/nav %s", navTo)
            mq.delay("2s", function() return mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 end)
            while mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 do
                mq.delay(10)
                mq.doevents()
            end
        else
            Core.DoCmd("/moveto loc %d %d|on", tempConfig.AutoCampY, tempConfig.AutoCampX)
            while mq.TLO.MoveTo.Moving() and not mq.TLO.MoveTo.Stopped() do
                mq.delay(10)
                mq.doevents()
            end
        end
    end

    if mq.TLO.Navigation.Active() then
        Core.DoCmd("/nav stop")
    end
end

--- Finds the group member with the lowest mana percentage.
--- @param minMana number The minimum mana percentage to consider.
--- @return number The group member with the lowest mana percentage, or nil if no member meets the criteria.
function Combat.FindWorstHurtManaGroupMember(minMana)
    local groupSize = mq.TLO.Group.Members()
    local worstId = mq.TLO.Me.ID() --initializes with the BST's ID/Mana because it isn't checked below
    local worstPct = mq.TLO.Me.PctMana()

    Logger.log_verbose("\ayChecking for worst HurtMana Group Members. Group Count: %d", groupSize)

    for i = 1, groupSize do
        local healTarget = mq.TLO.Group.Member(i)

        if healTarget and healTarget() and not healTarget.OtherZone() and not healTarget.Offline() then
            if Config.Constants.RGCasters:contains(healTarget.Class.ShortName()) then
                if not healTarget.Dead() and healTarget.PctMana() < worstPct then
                    Logger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                    worstPct = healTarget.PctMana()
                    worstId = healTarget.ID()
                end
            end
        end
    end

    --Still possibly carrying the BST ID, but only reports BST if under 100%, which is when they will self-Paragon
    if worstId > 0 and worstPct < 100 then
        Logger.log_verbose("\agWorst HurtMana group member id is %d", worstId)
    else
        Logger.log_verbose("\agNo one is HurtMana!")
    end

    return (worstPct < minMana and worstId or 0)
end

--- Finds the group member with the lowest health percentage.
--- @param minHPs number The minimum health percentage to consider.
--- @return number The group member with the lowest health percentage, or nil if no member meets the criteria.
function Combat.FindWorstHurtGroupMember(minHPs)
    local groupSize = mq.TLO.Group.Members()
    local worstId = mq.TLO.Me.PctHPs() < minHPs and mq.TLO.Me.ID() or 0
    local worstPct = mq.TLO.Me.PctHPs() < minHPs and mq.TLO.Me.PctHPs() or minHPs

    Logger.log_verbose("\ayChecking for worst Hurt Group Members. Group Count: %d", groupSize)

    for i = 1, groupSize do
        local healTarget = mq.TLO.Group.Member(i)

        if healTarget and healTarget() and not healTarget.OtherZone() and not healTarget.Offline() then
            if not healTarget.Dead() and (healTarget.PctHPs() or 101) < worstPct then
                Logger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                worstPct = healTarget.PctHPs()
                worstId = healTarget.ID()
            end

            if Config:GetSetting('DoPetHeals') and (healTarget.Pet.ID() or 0) > 0 then
                local petHP = healTarget.Pet.PctHPs() or 101
                if petHP < worstPct and petHP < Config:GetSetting('PetHealPoint') then
                    Logger.log_verbose("\aySo far %s's pet %s is the worst off.", healTarget.DisplayName(),
                        healTarget.Pet.DisplayName())
                    worstPct = healTarget.Pet.PctHPs()
                    worstId = healTarget.Pet.ID()
                end
            end
        end
    end

    if worstId > 0 then
        Logger.log_verbose("\agWorst hurt group member id is %d", worstId)
    else
        Logger.log_verbose("\agNo one is hurt!")
    end

    return (worstPct < minHPs and worstId or 0)
end

--- Finds the entity with the worst hurt mana exceeding a minimum threshold.
--- @param minMana number The minimum mana threshold to consider.
--- @return number The spawn id with the worst hurt mana above the specified threshold.
function Combat.FindWorstHurtManaXT(minMana)
    local xtSize = mq.TLO.Me.XTargetSlots()
    local worstId = 0
    local worstPct = minMana

    Logger.log_verbose("\ayChecking for worst HurtMana XTargs. XT Slot Count: %d", xtSize)

    for i = 1, xtSize do
        local healTarget = mq.TLO.Me.XTarget(i)

        if healTarget and healTarget() and Targeting.TargetIsType("pc", healTarget) then
            if Config.Constants.RGCasters:contains(healTarget.Class.ShortName()) then -- berzerkers have special handing
                if not healTarget.Dead() and healTarget.PctMana() < worstPct then
                    Logger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                    worstPct = healTarget.PctMana()
                    worstId = healTarget.ID()
                end
            end
        end
    end

    if worstId > 0 then
        Logger.log_verbose("\agWorst HurtMana xtarget id is %d", worstId)
    else
        Logger.log_verbose("\agNo one is HurtMana!")
    end

    return worstId
end

--- Finds the entity with the worst health condition that meets the minimum HP requirement.
--- @param minHPs number The minimum HP threshold to consider.
--- @return number The spawn id with the worst health condition that meets the criteria.
function Combat.FindWorstHurtXT(minHPs)
    local xtSize = mq.TLO.Me.XTargetSlots()
    local worstId = 0
    local worstPct = minHPs

    Logger.log_verbose("\ayChecking for worst Hurt XTargs. XT Slot Count: %d", xtSize)

    for i = 1, xtSize do
        local healTarget = mq.TLO.Me.XTarget(i)

        if healTarget and healTarget() and Targeting.TargetIsType("pc", healTarget) then
            if not healTarget.Dead() and (healTarget.PctHPs() or 101) < worstPct then
                Logger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                worstPct = healTarget.PctHPs()
                worstId = healTarget.ID()
            end

            if Config:GetSetting('DoPetHeals') and healTarget.Pet.ID() > 0 then
                local petHP = healTarget.Pet.PctHPs() or 101
                if petHP < worstPct and petHP < Config:GetSetting('PetHealPoint') then
                    Logger.log_verbose("\aySo far %s's pet %s is the worst off.", healTarget.DisplayName(),
                        healTarget.Pet.DisplayName())
                    worstPct = healTarget.Pet.PctHPs()
                    worstId = healTarget.Pet.ID()
                end
            end
        end
    end

    if worstId > 0 then
        Logger.log_verbose("\agWorst hurt xtarget id is %d", worstId)
    else
        Logger.log_verbose("\agNo one is hurt!")
    end

    return worstId
end

return Combat
