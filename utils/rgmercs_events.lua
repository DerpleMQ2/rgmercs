local mq            = require('mq')
local RGMercUtils   = require("utils.rgmercs_utils")
local RGMercsLogger = require("utils.rgmercs_logger")
local Set           = require("mq.Set")

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
        if RGMercConfig:GetSettings().DoAutoEngage then
            if RGMercUtils.OkToEngage(mq.TLO.Target.ID() or 0) then
                RGMercUtils.DoCmd("/squelch /face fast")
                if RGMercConfig:GetSettings().DoMelee then
                    RGMercsLogger.log_debug("Can't See target (%s [%d]). Naving to %d away.", mq.TLO.Target.CleanName() or "", mq.TLO.Target.ID() or 0,
                        (mq.TLO.Target.MaxRangeTo() or 0) * 0.9)
                    RGMercUtils.NavInCombat(RGMercConfig:GetSettings(), mq.TLO.Target.ID(), (mq.TLO.Target.MaxRangeTo() or 0) * 0.9, false)
                end
            end
        end
    end
    mq.flushevents("CantSee")
end)

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
        if RGMercConfig:GetSettings().DoAutoEngage then
            if RGMercUtils.OkToEngage(mq.TLO.Target.ID() or 0) then
                RGMercUtils.DoCmd("/squelch /face fast")
                if RGMercConfig:GetSettings().DoMelee then
                    RGMercsLogger.log_debug("Too Far from Target (%s [%d]). Naving to %d away.", mq.TLO.Target.CleanName() or "", mq.TLO.Target.ID() or 0,
                        (mq.TLO.Target.MaxRangeTo() or 0) * 0.9)
                    RGMercUtils.NavInCombat(RGMercConfig:GetSettings(), mq.TLO.Target.ID(), (mq.TLO.Target.MaxRangeTo() or 0) * 0.9, false)
                end
            end
        end
    end
end

mq.event('Being Memo', "Beginning to memorize #1#...", function(spell)
    RGMercUtils.Memorizing = true
end)

mq.event('End Memo', "You have finished memorizing #1#", function(spell)
    RGMercUtils.Memorizing = false
end)

mq.event('Abort Memo', "Aborting memorization of spell.", function()
    RGMercUtils.Memorizing = false
end)

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
