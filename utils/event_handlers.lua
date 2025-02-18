local mq          = require('mq')
local Config      = require('utils.config')
local Modules     = require("utils.modules")
local Core        = require("utils.core")
local Combat      = require("utils.combat")
local Casting     = require("utils.casting")
local Targeting   = require("utils.targeting")
local Comms       = require("utils.comms")
local Logger      = require("utils.logger")
local Movement    = require("utils.movement")
local ClassLoader = require('utils.classloader')

-- [ CANT SEE HANDLERS ] --

mq.event("CantSee", "You cannot see your target.", function()
    if Config.Globals.BackOffFlag then return end
    if Config.Globals.PauseMain then return end
    if not Config:GetSetting('HandleCantSeeTarget') then
        return
    end
    local target = mq.TLO.Target
    if mq.TLO.Stick.Active() then
        Core.DoCmd("/stick off")
    end

    if Modules:ExecModule("Pull", "IsPullState", "PULL_PULLING") then
        Logger.log_debug("\ayWe are in Pull_State PULLING and Cannot see our target!")
        Core.DoCmd("/nav id %d distance=%d lineofsight=on log=off", target.ID() or 0, (target.Distance3D() or 0) * 0.5)
        mq.delay("2s", function() return mq.TLO.Navigation.Active() end)
    else
        if mq.TLO.Me.Moving() then return end

        local classConfig = Modules:ExecModule("Class", "GetClassConfig")
        if classConfig and classConfig.HelperFunctions and classConfig.HelperFunctions.combatNav then
            Logger.log_debug("\ayWe are in COMBAT and Cannot see our target - using custom combatNav!")
            Core.SafeCallFunc("Ranger Custom Nav", classConfig.HelperFunctions.combatNav, true)
        else
            Logger.log_debug("\ayWe are in COMBAT and Cannot see our target - using generic combatNav!")
            if Config:GetSetting('DoAutoEngage') then
                if Combat.OkToEngage(target.ID() or 0) then
                    Core.DoCmd("/squelch /face fast")
                    if Targeting.GetTargetDistance() < 10 then
                        Logger.log_debug("Can't See target (%s [%d]). Moving back 10.", target.CleanName() or "", target.ID() or 0)
                        Core.DoCmd("/stick 10 moveback uw")
                    else
                        local desiredDistance = (target.MaxRangeTo() or 0) * 0.7
                        if not Config:GetSetting('DoMelee') then
                            desiredDistance = Targeting.GetTargetDistance() * .95
                        end

                        Logger.log_debug("Can't See target (%s [%d]). Naving to %d away.", target.CleanName() or "", target.ID(), desiredDistance)
                        Movement.NavInCombat(target.ID(), desiredDistance, false)
                    end
                end
            end
        end
    end
    mq.flushevents("CantSee")
end)

-- [ END CANT SEE HANDLERS ] --

-- [ TOO CLOSE HANDLERS] --

mq.event("TooClose", "Your target is too close to use a ranged weapon!", function()
    if not Config:GetSetting('HandleTooClose') then
        Logger.log_debug("TooCloseHandler: Event Detected, but HandleTooClose is not enabled.")
        return
    end
    Logger.log_debug("TooCloseHandler: Event Detected.")
    -- Check if we're in the middle of a pull and use a backup.
    if Config:GetSetting('DoPull') and Modules:ExecModule("Pull", "IsPullState", "PULL_PULLING") then
        Logger.log_debug("TooCloseHandler: Pull Mode Detected.")
        local discSpell = mq.TLO.Spell("Throw Stone")
        if Casting.TargetedDiscReady(discSpell) then
            Logger.log_debug("TooCloseHandler: Attempting to Throw Stone.")
            Casting.UseDisc(discSpell, mq.TLO.Target.ID())
        else
            if Casting.AbilityReady("Taunt") then
                Logger.log_debug("TooCloseHandler: Naving to target to use Taunt.")
                Core.DoCmd("/nav id %d distance=%d lineofsite=on log=off", Targeting.GetTargetID(), (Targeting.GetTargetMaxRangeTo() * .8))
                mq.delay("2s", function() return mq.TLO.Navigation.Active() end)
                Casting.UseAbility("Taunt")
                Logger.log_debug("TooCloseHandler: Attempting to Taunt.")
            end
            if Casting.AbilityReady("Kick") then
                Logger.log_debug("TooCloseHandler: Naving to target to use Kick.")
                Core.DoCmd("/nav id %d distance=%d lineofsite=on log=off", Targeting.GetTargetID(), (Targeting.GetTargetMaxRangeTo() * .8))
                mq.delay("2s", function() return mq.TLO.Navigation.Active() end)
                Casting.UseAbility("Kick")
                Logger.log_debug("TooCloseHandler: Attempting to Kick.")
            end
        end
    end

    -- Only do non-pull code if autoengage is on
    if Config:GetSetting('DoAutoEngage') and not mq.TLO.Me.Moving() then
        if not Modules:ExecModule("Pull", "IsPullState", "PULL_PULLING") then
            Logger.log_debug("TooCloseHandler: Pull State not detected, using Combat Nav.")
            local classConfig = Modules:ExecModule("Class", "GetClassConfig")
            if classConfig and classConfig.HelperFunctions and classConfig.HelperFunctions.combatNav then
                Core.SafeCallFunc("Ranger Custom Nav", classConfig.HelperFunctions.combatNav, true)
            end
        end
    end

    mq.flushevents("TooClose")
end)

-- [ END TOO CLOSE HANDLERS] --

-- [ TOO FAR HANDLERS ] --

local function tooFarHandler()
    if not Config:GetSetting('HandleTooFar') then
        return
    end
    Logger.log_debug("tooFarHandler()")
    if Config.Globals.BackOffFlag then return end
    if Config.Globals.PauseMain then return end
    if mq.TLO.Stick.Active() then
        Core.DoCmd("/stick off")
    end
    local target = mq.TLO.Target

    if Modules:ExecModule("Pull", "IsPullState", "PULL_PULLING") then
        Logger.log_debug("\ayWe are in Pull_State PULLING and too far from our target! target(%s) targetDistance(%d)",
            Targeting.GetTargetCleanName(),
            Targeting.GetTargetDistance())
        Core.DoCmd("/nav id %d distance=%d lineofsight=on log=off", target.ID() or 0, (target.Distance3D() or 0) * 0.7)
        mq.delay("2s", function() return mq.TLO.Navigation.Active() end)
    else
        local classConfig = Modules:ExecModule("Class", "GetClassConfig")
        if mq.TLO.Me.Moving() then return end

        if classConfig and classConfig.HelperFunctions and classConfig.HelperFunctions.combatNav then
            Core.SafeCallFunc("Custom Nav", classConfig.HelperFunctions.combatNav)
        elseif Config:GetSetting('DoMelee') then
            Logger.log_debug("\ayWe are in COMBAT and too far from our target!")
            if Config:GetSetting('DoAutoEngage') then
                if Combat.OkToEngage(target.ID() or 0) then
                    Core.DoCmd("/squelch /face fast")

                    if Targeting.GetTargetDistance() < (10 and target.MaxRangeTo()) then --not sure if this is necessary or still happening since we changed distance to use 3D.
                        Logger.log_debug("Too Far from Target (%s [%d]). Possible flyer detected. Moving back 10.", target.CleanName() or "", target.ID() or 0)
                        Core.DoCmd("/stick 10 moveback uw")
                    else
                        Logger.log_debug("Too Far from Target (%s [%d]). Naving to %d away.", target.CleanName() or "", target.ID() or 0,
                            (target.MaxRangeTo() or 0) * 0.7)
                        Movement.NavInCombat(target.ID(), (target.MaxRangeTo() or 0) * 0.7, false)
                    end
                end
            end
        end
    end
end

mq.event("TooFar1", "#*#Your target is too far away, get closer!", function()
    tooFarHandler()
    mq.flushevents("TooFar1")
end)
mq.event("TooFar2", "#*#You can't hit them from here.", function()
    tooFarHandler()
    mq.flushevents("TooFar2")
end)
mq.event("TooFar3", "#*#You are too far away#*#", function()
    tooFarHandler()
    mq.flushevents("TooFar3")
end)

-- [ END TOO FAR HANDLERS ] --

-- [ MEM SPELL HANDLERS ] --
mq.event('Begin Memo', "Beginning to memorize#*#", function()
    Casting.Memorizing = true
end)

mq.event('End Memo', "You have finished memorizing#*#", function()
    Casting.Memorizing = false
end)

mq.event('Abort Memo', "Aborting memorization of spell.", function()
    Casting.Memorizing = false
end)

-- [ END MEM SPELL HANDLERS ] --

-- [ SCRIBE SPELL HANDLERS ] --
mq.event('Begin Scribe', "Beginning to scribe#*#.", function()
    Casting.Memorizing = true
end)

mq.event('End Scribe', "You have finished scribing#*#", function()
    Casting.Memorizing = false
    -- Rescan spell list
    Modules:ExecModule("Class", "RescanLoadout")
end)

mq.event('Abort Scribe', "Aborting scribing of spell.", function()
    Casting.Memorizing = false
end)

-- [ END SCRIBE SPELL HANDLERS ] --

-- [ CAST RESULT HANDLERS ] --
mq.event('Success1', "You begin casting#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_SUCCESS)
end)

mq.event('Success2', "You begin singing#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_SUCCESS)
end)

mq.event('Success3', "Your #1# begins to glow.#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_SUCCESS)
end)

mq.event('Overwritten1', "Your#*#has been overwritten#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_OVERWRITTEN)
end)

mq.event('Collapsed1', "Your gate is too unstable, and collapses#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_COLLAPSE)
end)

mq.event('Distracted1', "You need to play a#*#instrument for this song#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Distracted2', "You are too distracted to cast a spell now#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Distracted3', "You can't cast spells while invulnerable#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Distracted4', "You *CANNOT* cast spells, you have been silenced#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Distracted5', "You do not have sufficient focus to maintain that ability.", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Fizzle1', "Your spell fizzles#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_FIZZLE)
end)

mq.event('Fizzle2', "You miss a note, bringing your song to a close#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_FIZZLE)
end)

mq.event('Fizzle3', "You miss a note, bringing your #*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_FIZZLE)
end)

mq.event('Interrupted1', "Your spell is interrupted#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_INTERRUPTED)
end)

mq.event('Interrupted2', "Your casting has been interrupted#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_INTERRUPTED)
end)

mq.event('Interrupted3', "Your #1# spell is interrupted#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_INTERRUPTED)
end)

mq.event('NoTarget1', "You must first select a target for this spell#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_NOTARGET)
end)

mq.event('NoTarget2', "This spell only works on#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_NOTARGET)
end)

mq.event('NoTarget3', "You must first target a group member#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_NOTARGET)
end)

mq.event('NotReady1', "Spell recast time not yet met#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_NOTREADY)
end)

mq.event('OutOfMana1', "Insufficient Mana to cast this spell#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_OUTOFMANA)
end)

mq.event('OutOfRange1', "Your target is out of range, get closer#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_OUTOFRANGE)
end)

mq.event('OutDoors1', "This spell does not work here#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_OUTDOORS)
end)

mq.event('OutDoors2', "You can only cast this spell in the outdoors#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_OUTDOORS)
end)

mq.event('Recover1', "You haven't recovered yet#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_RECOVER)
end)

mq.event('Recover2', "Spell recovery time not yet met#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_RECOVER)
end)

mq.event('Resist1', "Your target resisted the #1# spell#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_RESISTED)
end)

mq.event('Resist2', "#2# resisted your #1#!", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_RESISTED)
end)

mq.event('Standing1', "You must be standing to cast a spell#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_STANDING)
end)

mq.event('Stunned1', "You can't cast spells while stunned#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_STUNNED)
end)

mq.event('Stunned2', "You are stunned#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_STUNNED)
end)

mq.event('TakeHold1', "Your #*# did not take hold on #*#. (Blocked by #*#.)", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_TAKEHOLD)
end)

mq.event('TakeHold2', "Your spell did not take hold#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_TAKEHOLD)
end)

mq.event('TakeHold3', "Your spell would not have taken hold#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_TAKEHOLD)
end)

mq.event('TakeHold4', "Your spell is too powerfull for your intended target#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_TAKEHOLD)
end)

mq.event('CanNotSee1', "You cannot see your target#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_CANNOTSEE)
end)

mq.event('Components1', "You are missing some required components#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_COMPONENTS)
end)

mq.event('Components2', "Your ability to use this item has been disabled because you do not have at least a gold membership#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_COMPONENTS)
end)

mq.event('FDFail1', "#1# has fallen to the ground.#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_FDFAIL)
end)

mq.event('Immune1', "Your target has no mana to affect#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune2', "Your target is immune to changes in its attack speed#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune3', "Your target is immune to changes in its run speed#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune4', "Your target is immune to snare spells#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune5', "Your target is immune to the stun portion of this effect#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune6', "Your target looks unaffected#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('ImmuneMez', "Your target cannot be mesmerized#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
    local target = mq.TLO.Target
    Modules:ExecModule("Mez", "AddImmuneTarget", target.ID(),
        { id = target.ID(), name = target.CleanName(), lvl = target.Level(), body = target.Body(), reason = "IMMUNE", })
end)

mq.event('ImmuneCharm', "Your target cannot be charmed#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
    local target = mq.TLO.Target
    Modules:ExecModule("Charm", "AddImmuneTarget", target.ID(),
        { id = target.ID(), name = target.CleanName(), lvl = target.Level(), body = target.Body(), reason = "IMMUNE", })
end)

mq.event('ImmuneCharm2', "This NPC cannot be charmed#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
    local target = mq.TLO.Target
    Modules:ExecModule("Charm", "AddImmuneTarget", target.ID(),
        { id = target.ID(), name = target.CleanName(), lvl = target.Level(), body = target.Body(), reason = "IMMUNE", })
end)

mq.event('LvlHighCharm', "Your target is too high of a level for your charm spell.#*#", function()
    Casting.SetLastCastResult(Config.Constants.CastResults.CAST_IMMUNE)
    Logger.log_debug("\awNOTICE:\ax Target is to \aoHigh Level\ax to Charm with this spell!")
    local target = mq.TLO.Target

    Modules:ExecModule("Charm", "CharmLvlToHigh", target.Level())
    Modules:ExecModule("Charm", "AddImmuneTarget", target.ID(),
        { id = target.ID(), name = target.CleanName(), lvl = target.Level(), body = target.Body(), reason = "HIGH_LVL", })
end)
-- [ END CAST RESULT HANDLERS ] --

-- [ MEZ HANDLERS ] --

mq.event('MezBroken', "#1# has been awakened by #2#.", function(_, mobName, breakerName)
    Modules:ExecModule("Mez", "HandleMezBroke", mobName, breakerName)
end)

-- [ END MEZ HANDLERS ] --

-- [ SUMMONED HANDLERS ] --

mq.event('Summoned', "You have been summoned!", function(_)
    if Config:GetSetting('DoAutoEngage') and not Config:GetSetting('DoMelee') and not Core.IAmMA() and Config:GetSetting('ReturnToCamp') then
        Comms.PrintGroupMessage("%s was just summoned -- returning to camp!", Config.Globals.CurLoadedChar)
        Modules:ExecModule("Movement", "DoAutoCampCheck")
    end
end)

-- [ END SUMMONED HANDLERS ] --

-- [ GAME EVENT HANDLERS ] --

mq.event('Camping', "It will take you about #1# seconds to prepare your camp.", function(_, seconds)
    Config.Globals.PauseMain = true
end)

-- [ END GAME EVENT HANDLERS ] --

-- [ FD EVENT HANDLERS ] --

mq.event('FallToGround', "#1# has fallen to the ground#*#", function(_, who)
    if who == mq.TLO.Me.DisplayName() and Config:GetSetting('StandFailedFD') then
        Core.DoCmd("/stand")
    end
end)

-- [ END FD EVENT HANDLERS ] --

-- [ CLASS CHANGE EVENT HANDLERS ] --
mq.event('PersonaEquipLoad', "You successfully loaded your #*# equipment set.", function()
    if Config.Globals.CurLoadedClass ~= mq.TLO.Me.Class.ShortName() then
        ClassLoader.changeLoadedClass()
    end
end)
-- [ END CLASS CHANGE EVENT HANDLERS ] --
