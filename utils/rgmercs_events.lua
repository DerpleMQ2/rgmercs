local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")
local Set         = require("mq.Set")

-- [ CANT SEE HANDLERS ] --

mq.event("CantSee", "You cannot see your target.", function()
    if RGMercConfig.Globals.BackOffFlag then return end

    if mq.TLO.Stick.Active() then
        RGMercUtils.DoCmd("/stick off")
    end

    if RGMercModules:ExecModule("Pull", "IsPullState", "PULL_PULLING") then
        RGMercsLogger.log_info("\ayWe are in Pull_State PULLING and Cannot see our target!")
        RGMercUtils.DoCmd("/nav id %d distance=%d lineofsight=on log=off", mq.TLO.Target.ID() or 0, (mq.TLO.Target.Distance() or 0) * 0.5)
        mq.delay("2s", function() return mq.TLO.Navigation.Active() end)

        -- TODO: Do we need this?
        --while (${Navigation.Active} && ${XAssist.XTFullHaterCount} == 0) {
        --CALLTRACE In while loop :: Navigation.Active ${Navigation.Active} :: XAssist ${XAssist.XTFullHaterCount}
        --/doevents
        --/delay 1 ${XAssist.XTFullHaterCount} > 0
        --}
    else
        RGMercsLogger.log_info("\ayWe are in COMBAT and Cannot see our target!")
        if RGMercUtils.GetSetting('DoAutoEngage') then
            if RGMercUtils.OkToEngage(mq.TLO.Target.ID() or 0) then
                RGMercUtils.DoCmd("/squelch /face fast")
                if RGMercUtils.GetSetting('DoMelee') then
                    RGMercsLogger.log_debug("Can't See target (%s [%d]). Naving to %d away.", mq.TLO.Target.CleanName() or "", mq.TLO.Target.ID() or 0,
                        (mq.TLO.Target.MaxRangeTo() or 0) * 0.9)
                    RGMercUtils.NavInCombat(RGMercConfig:GetSettings(), mq.TLO.Target.ID(), (mq.TLO.Target.MaxRangeTo() or 0) * 0.9, false)
                end
            end
        end
    end
    mq.flushevents("CantSee")
end)

-- [ END CANT SEE HANDLERS ] --

-- [ TOO FAR HANDLERS ] --

local function tooFarHandler()
    RGMercsLogger.log_debug("tooFarHandler()")
    if RGMercConfig.Globals.BackOffFlag then return end
    if mq.TLO.Stick.Active() then
        RGMercUtils.DoCmd("/stick off")
    end

    if RGMercModules:ExecModule("Pull", "IsPullState", "PULL_PULLING") then
        RGMercsLogger.log_info("\ayWe are in Pull_State PULLING and too far from our target!")
        RGMercUtils.DoCmd("/nav id %d distance=%d lineofsight=on log=off", mq.TLO.Target.ID() or 0, (mq.TLO.Target.Distance() or 0) * 0.75)
        mq.delay("2s", function() return mq.TLO.Navigation.Active() end)
    else
        RGMercsLogger.log_info("\ayWe are in COMBAT and too far from our target!")
        if RGMercUtils.GetSetting('DoAutoEngage') then
            if RGMercUtils.OkToEngage(mq.TLO.Target.ID() or 0) then
                RGMercUtils.DoCmd("/squelch /face fast")
                if RGMercUtils.GetSetting('DoMelee') then
                    RGMercsLogger.log_debug("Too Far from Target (%s [%d]). Naving to %d away.", mq.TLO.Target.CleanName() or "", mq.TLO.Target.ID() or 0,
                        (mq.TLO.Target.MaxRangeTo() or 0) * 0.9)
                    RGMercUtils.NavInCombat(RGMercConfig:GetSettings(), mq.TLO.Target.ID(), (mq.TLO.Target.MaxRangeTo() or 0) * 0.9, false)
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
mq.event('Being Memo', "Beginning to memorize #1#...", function(spell)
    RGMercUtils.Memorizing = true
end)

mq.event('End Memo', "You have finished memorizing #1#", function(spell)
    RGMercUtils.Memorizing = false
end)

mq.event('Abort Memo', "Aborting memorization of spell.", function()
    RGMercUtils.Memorizing = false
end)

-- [ END MEM SPELL HANDLERS ] --

-- [ CAST RESULT HANDLERS ] --
mq.event('Success1', "You begin casting#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_SUCCESS)
end)

mq.event('Success2', "You begin singing#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_SUCCESS)
end)

mq.event('Success3', "Your #1# begins to glow.#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_SUCCESS)
end)

mq.event('Overwritten1', "Your#*#has been overwritten#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_OVERWRITTEN)
end)

mq.event('Collapsed1', "Your gate is too unstable, and collapses#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_COLLAPSE)
end)

mq.event('Distracted1', "You need to play a#*#instrument for this song#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Distracted2', "You are too distracted to cast a spell now#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Distracted3', "You can't cast spells while invulnerable#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Distracted4', "You *CANNOT* cast spells, you have been silenced#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Distracted5', "You do not have sufficient focus to maintain that ability.", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_DISTRACTED)
end)

mq.event('Fizzle1', "Your spell fizzles#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_FIZZLE)
end)

mq.event('Fizzle2', "You miss a note, bringing your song to a close#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_FIZZLE)
end)

mq.event('Interrupted1', "Your spell is interrupted#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_INTERRUPTED)
end)

mq.event('Interrupted2', "Your casting has been interrupted#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_INTERRUPTED)
end)

mq.event('Interrupted3', "Your #1# spell is interrupted#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_INTERRUPTED)
end)

mq.event('NoTarget1', "You must first select a target for this spell#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_NOTARGET)
end)

mq.event('NoTarget2', "This spell only works on#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_NOTARGET)
end)

mq.event('NoTarget3', "You must first target a group member#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_NOTARGET)
end)

mq.event('NotReady1', "Spell recast time not yet met#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_NOTREADY)
end)

mq.event('OutOfMana1', "Insufficient Mana to cast this spell#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_OUTOFMANA)
end)

mq.event('OutOfRange1', "Your target is out of range, get closer#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_OUTOFRANGE)
end)

mq.event('OutDoors1', "This spell does not work here#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_OUTDOORS)
end)

mq.event('OutDoors2', "You can only cast this spell in the outdoors#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_OUTDOORS)
end)

mq.event('Recover1', "You haven't recovered yet#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_RECOVER)
end)

mq.event('Recover2', "Spell recovery time not yet met#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_RECOVER)
end)

mq.event('Resist1', "Your target resisted the #1# spell#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_RESISTED)
end)

mq.event('Resist2', "#2# resisted your #1#!", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_RESISTED)
end)

mq.event('Standing1', "You must be standing to cast a spell#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_STANDING)
end)

mq.event('Stunned1', "You can't cast spells while stunned#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_STUNNED)
end)

mq.event('Stunned2', "You are stunned#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_STUNNED)
end)

mq.event('TakeHold1', "Your #*# did not take hold on #*#. (Blocked by #*#.)", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_TAKEHOLD)
end)

mq.event('TakeHold2', "Your spell did not take hold#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_TAKEHOLD)
end)

mq.event('TakeHold3', "Your spell would not have taken hold#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_TAKEHOLD)
end)

mq.event('TakeHold4', "Your spell is too powerfull for your intended target#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_TAKEHOLD)
end)

mq.event('CanNotSee1', "You cannot see your target#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_CANNOTSEE)
end)

mq.event('Components1', "You are missing some required components#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_COMPONENTS)
end)

mq.event('Components2', "Your ability to use this item has been disabled because you do not have at least a gold membership#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_COMPONENTS)
end)

mq.event('FDFail1', "#1# has fallen to the ground.#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_FDFAIL)
end)

mq.event('Immune1', "Your target has no mana to affect#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune2', "Your target is immune to changes in its attack speed#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune3', "Your target is immune to changes in its run speed#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune4', "Your target is immune to snare spells#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune5', "Your target is immune to the stun portion of this effect#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('Immune6', "Your target looks unaffected#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_IMMUNE)
end)

mq.event('ImmuneMez', "Your target cannot be mesmerized#*#", function()
    RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_IMMUNE)
    RGMercModules:ExecModule("Mez", "AddImmuneTarget", mq.TLO.Target.ID(), { id = mq.TLO.Target.ID(), name = mq.TLO.Target.CleanName(), })
end)

-- [ END CAST RESULT HANDLERS ] --

mq.event('MezBroken', "#1# has been awakened by #2#.", function(_, mobName, breakerName)
    RGMercModules:ExecModule("Mez", "HandleMezBroke", mobName, breakerName)
end)
