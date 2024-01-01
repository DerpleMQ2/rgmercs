local mq            = require('mq')
local RGMercsLogger = require("rgmercs.utils.rgmercs_logger")
local animSpellGems = mq.FindTextureAnimation('A_SpellGems')
local ICONS         = require('mq.Icons')
local ICON_SIZE     = 20
local USEGEM        = mq.TLO.Me.NumGems()
-- Global
Memorizing          = false

local Utils         = { _version = '0.1a', author = 'Derple' }
Utils.__index       = Utils
Utils.Actors        = require('actors')
Utils.ScriptName    = "RGMercs"
Utils.LastZoneID    = 0
Utils.NamedList     = {}

function Utils.file_exists(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function Utils.BroadcastUpdate(module, event)
    Utils.Actors.send({ from = RGMercConfig.Globals.CurLoadedChar, script = Utils.ScriptName, module = module, event = event })
end

function Utils.PrintGroupMessage(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    mq.cmdf("/dgt group_%s_%s %s", RGMercConfig.Globals.CurServer, mq.TLO.Group.Leader() or "None", output)
end

function Utils.PopUp(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    mq.cmdf("/popup %s", output)
end

function Utils.SetTarget(targetId)
    RGMercsLogger.log_debug("Setting Target: %d", targetId)
    if RGMercConfig:GetSettings().DoAutoTarget then
        if Utils.GetTargetID() ~= targetId then
            mq.cmdf("/target id %d", targetId)
            mq.delay(10)
        end
    end
end

function Utils.ClearTarget()
    RGMercsLogger.log_debug("Clearing Target")
    if RGMercConfig:GetSettings().DoAutoTarget then
        RGMercConfig.Globals.AutoTargetID = 0
        RGMercConfig.Globals.BurnNow = false
        if mq.TLO.Stick.Status():lower() == "on" then mq.cmdf("/stick off") end
        mq.cmdf("/target clear")
    end
end

function Utils.HandleDeath()
    RGMercsLogger.log_warning("You are sleeping with the fishes.")

    Utils.ClearTarget()

    RGMercModules:execAll("OnDeath")

    -- TODO: Cancel pulling in OnDeath

    while mq.TLO.Me.Hovering() do
        if mq.TLO.Window("RespawnWnd").Open() and RGMercConfig:GetSettings().InstantRelease then
            mq.TLO.Window("RespawnWnd").Child("RW_OptionsList").Select(1)
            mq.delay("1s")
            mq.TLO.Window("RespawnWnd").Child("RW_SelectButton").LeftMouseUp()
        else
            break
        end
    end

    mq.delay("1m", (not mq.TLO.Me.Zoning()))

    if RGMercConfig:GetSettings().DoFellow then
        if mq.TLO.FindItem("Fellowship Registration Insignia").Timer() == 0 then
            mq.delay("30s", (mq.TLO.Me.CombatState():lower() == "active"))
            mq.cmdf("/useitem \"Fellowship Registration Insignia\"")
            mq.delay("2s", (mq.TLO.FindItem("Fellowship Registration Insignia").Timer() ~= 0))
        else
            RGMercsLogger.log_error("\aw Bummer, Insignia on cooldown, you must really suck at this game...")
        end
    end
end

---@param t table
function Utils.CheckPlugins(t)
    for _, p in pairs(t) do
        if not mq.TLO.Plugin(p)() then
            mq.cmdf("/squelch /plugin %s noauto", p)
            RGMercsLogger.log_info("\aw %s \ar not detected! \aw This macro requires it! Loading ...", p)
        end
    end
end

---@param t table
---@return table
function Utils.UnCheckPlugins(t)
    local r = {}
    for _, p in pairs(t) do
        if mq.TLO.Plugin(p)() then
            mq.cmdf("/squelch /plugin %s unload noauto", p)
            RGMercsLogger.log_info("\ar %s detected! \aw Unloading it due to known conflicts with RGMercs!", p)
            table.insert(r, p)
        end
    end

    return r
end

function Utils.WelcomeMsg()
    RGMercsLogger.log_info("\aw****************************")
    RGMercsLogger.log_info("\aw\awWelcome to \ag%s", RGMercConfig._name)
    RGMercsLogger.log_info("\aw\awVersion \ag%s \aw(\at%s\aw)", RGMercConfig._version, RGMercConfig._subVersion)
    RGMercsLogger.log_info("\aw\awBy \ag%s", RGMercConfig._author)
    RGMercsLogger.log_info("\aw****************************")
    RGMercsLogger.log_info("\aw use \ag /rg \aw for a list of commands")
end

function Utils.CanUseAA(aaName)
    return mq.TLO.Me.AltAbility(aaName)() and mq.TLO.Me.AltAbility(aaName).MinLevel() <= mq.TLO.Me.Level() and mq.TLO.Me.AltAbility(aaName).Rank() > 0
end

function Utils.AAReady(aaName)
    return Utils.CanUseAA(aaName) and mq.TLO.Me.AltAbilityReady(aaName)
end

function Utils.IsDisc(name)
    local spell = mq.TLO.Spell(name)

    return spell() and spell.IsSkill() and spell.Duration() and not spell.StacksWithDiscs() and spell.TargetType():lower() == "self"
end

function Utils.GetBestItem(t)
    local selectedItem = nil

    for _, i in ipairs(t or {}) do
        if mq.TLO.FindItem("=" .. i)() then
            selectedItem = i
            break
        end
    end

    if selectedItem then
        RGMercsLogger.log_debug("\agFound\ax %s!", selectedItem)
    else
        RGMercsLogger.log_debug("\arNo items found for slot!")
    end

    return selectedItem
end

function Utils.GetBestSpell(t)
    local highestLevel = 0
    local selectedSpell = nil

    for _, s in ipairs(t or {}) do
        local spell = mq.TLO.Spell(s)
        --RGMercsLogger.log_debug("Found %s level(%d) rank(%s)", s, spell.Level(), spell.RankName())
        if spell.Level() <= mq.TLO.Me.Level() then
            if mq.TLO.Me.Book(spell.RankName())() or mq.TLO.Me.CombatAbility(spell.RankName())() then
                if spell.Level() > highestLevel then
                    highestLevel = spell.Level()
                    selectedSpell = spell
                end
            else
                Utils.PrintGroupMessage(string.format(
                    "%s \aw [%s] \ax \ar MISSING SPELL \ax -- \ag %s \ax -- \aw LVL: %d \ax", mq.TLO.Me.CleanName(), s,
                    spell.RankName(), spell.Level()))
            end
        end
    end

    if selectedSpell then
        RGMercsLogger.log_debug("\agFound\ax %s level(%d) rank(%s)", selectedSpell.BaseName(), selectedSpell.Level(),
            selectedSpell.RankName())
    else
        RGMercsLogger.log_debug("\arNo spell found for slot!")
    end

    return selectedSpell
end

function Utils.WaitCastFinish(target)
    local maxWaitOrig = ((mq.TLO.Me.Casting.MyCastTime.TotalSeconds() or 0) + ((mq.TLO.EverQuest.Ping() * 2 / 100) + 1)) * 1000
    local maxWait = maxWaitOrig

    while mq.TLO.Me.Casting() and (not mq.TLO.Cast.Ready()) do
        mq.delay(100)
        if target() and Utils.GetTargetPctHPs() <= 0 or (Utils.GetTargetID() ~= target.ID()) then
            mq.TLO.Me.StopCast()
            return
        end

        maxWait = maxWait - 100

        if maxWait <= 0 then
            local msg = string.format("StuckGem Data::: %d - MaxWait - %d - Casting Window: %s - Assist Target ID: %d", mq.TLO.Me.Casting.ID(), maxWaitOrig,
                mq.TLO.Window("CastingWindow").Open() and "TRUE" or "FALSE", RGMercConfig.Globals.AutoTargetID)

            RGMercsLogger.log_debug(msg)
            Utils.PrintGroupMessage(msg)

            --mq.cmdf("/alt act 511")
            mq.TLO.Me.StopCast()
            return
        end

        mq.doevents()
    end
end

function Utils.ManaCheck(config)
    return mq.TLO.Me.PctMana() >= config.ManaToNuke
end

function Utils.MemorizeSpell(gem, spell)
    RGMercsLogger.log_info("\ag Meming \aw %s in \ag slot %d", spell, gem)
    mq.cmdf("/memspell %d \"%s\"", gem, spell)
    local maxWait = 5000

    while mq.TLO.Me.Gem(gem)() ~= spell and maxWait > 0 do
        RGMercsLogger.log_verbose("\ayWaiting for '%s' to load in slot %d'...", spell, gem)
        mq.delay(100)
        maxWait = maxWait - 100
    end
end

function Utils.CastReady(spell)
    return mq.TLO.Me.SpellReady(spell)()
end

function Utils.WaitCastReady(spell)
    while not mq.TLO.Me.SpellReady(spell)() do
        mq.delay(100)
        mq.doevents()
        if Utils.GetXTHaterCount() > 0 then
            RGMercsLogger.log_debug("I was interruped by combat while waiting to cast %s.", spell)
            return
        end
        --RGMercsLogger.log_debug("Waiting for spell '%s' to be ready...", spell)
    end
end

function Utils.WaitGlobalCoolDown()
    while mq.TLO.Me.SpellInCooldown() do
        mq.delay(100)
        mq.doevents()
        --RGMercsLogger.log_debug("Waiting for spell '%s' to be ready...", spell)
    end
end

function Utils.ActionPrep()
    if not mq.TLO.Me.Standing() then
        mq.TLO.Me.Stand()
        mq.delay(10, mq.TLO.Me.Standing())

        RGMercConfig.Globals.InMedState = false
    end

    if mq.TLO.Window("SpellBookWnd").Open() then
        mq.TLO.Window("SpellBookWnd").DoClose()
    end
end

function Utils.ExecEntry(e, targetId, map, bAllowMem)
    local cmd

    local me = mq.TLO.Me

    if e.type:lower() == "item" then
        if mq.TLO.Window("CastingWindow").Open() or me.Casting.ID() then
            if me.Class.ShortName():lower() == "brd" then
                mq.delay("3s", not mq.TLO.Window("CastingWindow").Open())
                mq.delay(10)
                mq.cmdf("/stopsong")
            else
                RGMercsLogger.log_debug("\arCANT Use Item - Casting Window Open")
                return
            end
        end

        local itemName = map[e.name]
        local item = mq.TLO.FindItem("=" .. itemName)

        if not item() then
            RGMercsLogger.log_error("\arTried to use item '%s' - but it is not found!", itemName)
            return
        end

        if me.FindBuff("id " .. tostring(item.Clicky.SpellID()))() then
            return
        end

        if me.FindBuff("id " .. tostring(item.Spell.ID()))() then
            return
        end

        if me.Song(tostring(item.Spell.ID()))() then
            return
        end

        Utils.ActionPrep()

        if not me.ItemReady(itemName) then
            return
        end

        RGMercsLogger.log_debug("\aw Using Item \ag %s", itemName)

        cmd = string.format("/useitem \"%s\"", itemName)
        mq.cmdf(cmd)
        RGMercsLogger.log_debug("Running: \at'%s'", cmd)

        mq.delay(2)

        if not item.CastTime() then
            -- slight delay for instant casts
            mq.delay(4)
        else
            mq.delay(item.CastTime(), not me.Casting.ID())

            -- pick up any additonal server lag.
            while me.Casting.ID() do
                mq.delay(5)
                mq.doevents()
            end
        end

        if mq.TLO.Cursor.ID() then
            mq.cmdf("/autoinv")
        end

        return
    end

    if e.type:lower() == "spell" then
        local s = map[e.name]
        RGMercsLogger.log_debug("%s - %s", e.name, s)
        if s then
            -- Check we actually have the spell -- Me.Book always needs to use RankName
            if not me.Book(s.RankName())() then
                RGMercsLogger.log_error("\arTRAGIC ERROR: Somehow I tried to cast a spell I didn't know: %s", s.Name())
                return
            end

            -- Check for enough mana -- just in case something has changed by this point...
            if me.CurrentMana() < s.Mana() then
                return
            end

            local target = mq.TLO.Spawn(targetId)

            -- If we're combat casting we need to both have the same swimming status
            if targetId == 0 or (target() and target.FeetWet() ~= me.FeetWet()) then
                return
            end

            Utils.WaitGlobalCoolDown()

            if (Utils.GetXTHaterCount() > 0 or not bAllowMem) and (not Utils.CastReady(s.RankName()) or not mq.TLO.Me.Gem(s.RankName())()) then
                RGMercsLogger.log_debug("\ayI tried to cast %s but it was not ready and we are in combat - moving on.", s.RankName())
                return
            end

            if not me.Gem(s.RankName())() then
                RGMercsLogger.log_debug("\ay%s is not memorized - meming!", s.RankName())
                Utils.MemorizeSpell(USEGEM, s.RankName())
            end

            Utils.WaitCastReady(s.RankName())

            Utils.ActionPrep()

            cmd = string.format("/casting \"%s\" -maxtries|5 -targetid|%d", s.RankName(), targetId)
            mq.cmdf(cmd)
            RGMercsLogger.log_debug("Running: \at'%s'", cmd)

            Utils.WaitCastFinish(target)
        else
            RGMercsLogger.log_error("Entry Key: %s not found in map!", e.name)
        end

        return
    end

    if e.type:lower() == "aa" then
        local oldTarget = Utils.GetTargetID()

        local s = mq.TLO.Me.AltAbility(e.name)

        if not s then
            RGMercsLogger.log_warning("\ayYou do not have the AA Ability: %s!", s.RankName())
            return
        end

        if mq.TLO.Window("CastingWindow").Open() or me.Casting.ID() then
            if me.Class.ShortName():lower() == "brd" then
                mq.delay("3s", not mq.TLO.Window("CastingWindow").Open())
                mq.delay(10)
                mq.cmdf("/stopsong")
            else
                RGMercsLogger.log_debug("CANT CAST AA - Casting Window Open")
                return
            end
        end

        if not mq.TLO.Me.AltAbilityReady(e.name)() then
            RGMercsLogger.log_debug("\ayAbility %s is not ready!", e.name)
            return
        end

        local target = mq.TLO.Spawn(targetId)

        -- If we're combat casting we need to both have the same swimming status
        if target() and target.FeetWet() ~= me.FeetWet() then
            return
        end

        Utils.ActionPrep()

        if Utils.GetTargetID() ~= targetId and target() then
            if me.Combat() and target.Type():lower() == "pc" then
                RGMercsLogger.log_info("\awNOTICE:\ax Turning off autoattack to cast on a PC.")
                mq.cmdf("/attack off")
                mq.delay("2s", not me.Combat())
            end

            Utils.SetTarget(targetId)
        end

        cmd = string.format("/alt act %d", s.ID())

        mq.cmdf(cmd)

        mq.delay(5, not Utils.AAReady(e.name))

        if me.AltAbility(e.name).Spell.MyCastTime.TotalSeconds() > 0 then
            Utils.WaitCastFinish(target)
        end

        RGMercsLogger.log_debug("switching target back to old target after casting aa")
        Utils.SetTarget(oldTarget)

        return
    end

    if e.type:lower() == "ability" then
        mq.cmdf("/doability %s", e.name)
        mq.delay(8, not me.AbilityReady(e.name))
        RGMercsLogger.log_debug("Using Ability \ao =>> \ag %s \ao <<=", e.name)

        return
    end

    if e.type:lower() == "cmd" then
        mq.cmdf("/docommand %s", e.name)
        RGMercsLogger.log_debug("Calling command \ao =>> \ag %s \ao <<=", e.name)
        return
    end

    if e.type:lower() == "disc" then
        local discSpell = map[e.name]

        if not discSpell then
            RGMercsLogger.log_debug("Dont have a DISC for \ao =>> \ag %s \ao <<=", e.name)
            return
        end

        RGMercsLogger.log_debug("Using DISC \ao =>> \ag %s [%s] \ao <<=", e.name, (discSpell() and discSpell.RankName() or "None"))

        if mq.TLO.Window("CastingWindow").Open() or me.Casting.ID() then
            RGMercsLogger.log_debug("CANT USE DISC - Casting Window Open")
            return
        end

        if me.CurrentEndurance() < discSpell.EnduranceCost() then
            return
        end

        RGMercsLogger.log_debug("Trying to use DISC: %s", discSpell.RankName())

        Utils.ActionPrep()

        if Utils.IsDisc(discSpell.RankName()) then
            if me.ActiveDisc.ID() then
                RGMercsLogger.log_debug("Cancelling Disc for %s -- Active Disc: [%s]", discSpell.RankName(), me.ActiveDisc.Name())
                mq.cmdf("/stopdisc")
                mq.delay(20, not me.ActiveDisc.ID())
            end
        end

        mq.cmdf("/squelch /doability \"%s\"", discSpell.RankName())

        mq.delay(discSpell.MyCastTime() / 100 or 100, (not me.CombatAbilityReady(discSpell.RankName()) and not me.Casting.ID()))

        -- Is this even needed?
        if Utils.IsDisc(discSpell.RankName()) then
            mq.delay(20, me.ActiveDisc.ID())
        end

        RGMercsLogger.log_debug("\aw Cast >>> \ag %s", discSpell.RankName())

        return
    end
end

function Utils.RunRotation(s, r, targetId, map, steps, start_step, bAllowMem)
    local oldSpellInSlot = mq.TLO.Me.Gem(USEGEM)
    local stepsThisTime  = 0
    local lastStepIdx    = 0

    for idx, entry in ipairs(r) do
        if not steps or (steps and start_step and idx >= start_step) then
            if steps then
                RGMercsLogger.log_verbose("Doing RunRotation(start(%d), step(%d), cur(%d))", start_step, steps, idx)
            end
            lastStepIdx = idx
            if entry.cond then
                local pass = entry.cond(s, map[entry.name] or mq.TLO.Spell(entry.name))
                if pass == true then
                    Utils.ExecEntry(entry, targetId, map, bAllowMem)
                    stepsThisTime = stepsThisTime + 1

                    if steps and stepsThisTime >= steps then
                        break
                    end
                end
            else
                Utils.ExecEntry(entry, targetId, map, bAllowMem)
                stepsThisTime = stepsThisTime + 1

                if steps and stepsThisTime >= steps then
                    break
                end
            end
        end
    end

    if oldSpellInSlot() and mq.TLO.Me.Gem(USEGEM)() ~= oldSpellInSlot.Name() then
        RGMercsLogger.log_debug("\ayRestoring %s in slot %d", oldSpellInSlot, USEGEM)
        Utils.MemorizeSpell(USEGEM, oldSpellInSlot.Name())
    end

    -- Move to the next step
    lastStepIdx = lastStepIdx + 1

    if lastStepIdx > #r then
        lastStepIdx = 1
    end

    if steps then
        RGMercsLogger.log_verbose("Ended RunRotation(step(%d), start_step(%d), next(%d))", steps, start_step, lastStepIdx)
    end

    return lastStepIdx
end

function Utils.SelfBuffPetCheck(spell)
    if not spell then return false end
    return not mq.TLO.Me.PetBuff(spell.RankName())() and spell.StacksPet() and mq.TLO.Me.Pet.ID() > 0
end

function Utils.SelfBuffCheck(spell)
    if not spell then return false end
    local res = not mq.TLO.Me.FindBuff("id " .. tostring(spell.ID())).ID() and spell.Stacks()
    return res
end

function Utils.SelfBuffAACheck(aaName)
    return not mq.TLO.Me.FindBuff("id " .. tostring(mq.TLO.Me.AltAbility(aaName).Spell.ID())).ID() and
        not mq.TLO.Me.FindBuff("id " .. tostring(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())).ID() and
        not mq.TLO.Me.Aura(tostring(mq.TLO.Spell(aaName).RankName())).ID() and
        mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName).Spell.RankName()).Stacks() and
        (not mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1))() or mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1)).Stacks())
end

function Utils.DotSpellCheck(config, spell)
    if not spell then return false end
    return not mq.TLO.Target.FindBuff("id " .. tostring(spell.ID())).ID() and spell.StacksTarget() and
        Utils.GetTargetPctHPs() > config.HPStopDOT
end

function Utils.DetSpellCheck(spell)
    if not spell then return false end
    return not mq.TLO.Target.FindBuff("id " .. tostring(spell.ID())).ID() and spell.StacksTarget()
end

function Utils.TargetHasBuff(spell)
    return mq.TLO.Target() and mq.TLO.Target.FindBuff("id " .. tostring(spell.ID())).ID() > 0
end

function Utils.GetTargetDistance()
    return (mq.TLO.Target.Distance() or 9999)
end

function Utils.GetTargetPctHPs()
    return (mq.TLO.Target.PctHPs() or 0)
end

function Utils.GetTargetID()
    return (mq.TLO.Target.ID() or 0)
end

function Utils.BurnCheck(config)
    return ((config.BurnAuto and (Utils.GetXTHaterCount() >= config.BurnMobCount or (mq.TLO.Target.Named() and config.BurnNamed) or (config.BurnAlways and config.BurnAuto))) or (not config.BurnAuto and config.BurnSize))
end

function Utils.SmallBurn(config)
    return config.BurnSize >= 1
end

function Utils.MedBurn(config)
    return config.BurnSize >= 2
end

function Utils.BigBurn(config)
    return config.BurnSize >= 3
end

function Utils.DoStick(config, assistId, targetId)
    if config.StickHow:len() > 0 then
        mq.cmdf("/stick %s", config.StickHow)
    else
        if mq.TLO.Me.ID() == assistId then
            mq.cmdf("/stick 20 id %d moveback uw", targetId)
        else
            mq.cmdf("/stick 20 id %d behindonce moveback uw", targetId)
        end
    end
end

function Utils.NavInCombat(config, assistId, targetId, distance, bDontStick)
    if not config.DoAutoEngage then return end

    if mq.TLO.Stick.Active() then
        mq.cmdf("/stick off")
    end

    if mq.TLO.Nav.PathExists("id " .. tostring(targetId) .. " distance " .. tostring(distance))() then
        mq.cmdf("/nav id %d distance=%d log=off lineofsight=on", targetId, distance)
        while mq.TLO.Nav.Active() and mq.TLO.Nav.Velocity() > 0 do
            mq.delay(100)
        end
    else
        mq.cmdf("/moveto id %d uw mdist %d", targetId, distance)
        while mq.TLO.MoveTo.Moving() and not mq.TLO.MoveUtils.Stuck() do
            mq.delay(100)
        end
    end

    if not bDontStick then
        Utils.DoStick(config, assistId, targetId)
    end
end

function Utils.ShouldKillTargetReset()
    local killSpawn = mq.TLO.Spawn(string.format("targetable id %d", RGMercConfig.Globals.AutoTargetID))
    local killCorpse = mq.TLO.Spawn(string.format("corpse id %d", RGMercConfig.Globals.AutoTargetID))
    return ((not killSpawn() or killSpawn.Dead()) or killCorpse()) and RGMercConfig.Globals.AutoTargetID > 0
end

function Utils.AutoMed()
    local me = mq.TLO.Me
    if not RGMercConfig:GetSettings().DoMed then return end

    if me.Class.ShortName():lower() == "brd" and me.Level() > 5 then return end

    -- TODO: Add DoMount Check
    if me.Mount.ID() and not mq.TLO.Zone.Indoor() then
        return
    end

    RGMercConfig:StoreLastMove()

    --If we're moving/following/navigating/sticking, don't med.
    if me.Casting() or me.Moving() or mq.TLO.Stick.Active() or mq.TLO.Nav.Active() or mq.TLO.MoveTo.Moving() or mq.TLO.AdvPath.Following() then
        return
    end

    local enablesit = false

    -- Allow sufficient time for the player to do something before char plunks down. Spreads out med sitting too.
    if RGMercConfig.Globals.LastMove.TimeSinceMove < math.random(7, 12) then return end

    if RGMercConfig.Constants.RGHybrid:contains(me.Class.ShortName()) then
        -- Handle the case where we're a Hybrid. We need to check mana and endurance. Needs to be done after
        -- the original stat checks.
        if me.PctHPs() >= RGMercConfig:GetSettings().HPMedPctStop and me.PctMana() >= RGMercConfig:GetSettings().ManaMedPctStop and me.PctEndurance() >= RGMercConfig:GetSettings().EndMedPctStop then
            RGMercConfig.Globals.InMedState = false
            return
        end

        if me.PctHPs() < RGMercConfig:GetSettings().HPMedPct or me.PctMana() < RGMercConfig:GetSettings().ManaMedPct or me.PctEndurance() < RGMercConfig:GetSettings().EndMedPct then
            enablesit = true
        end
    elseif RGMercConfig.Constants.RGCasters:contains(me.Class.ShortName()) then
        if me.PctHPs() >= RGMercConfig:GetSettings().HPMedPctStop and me.PctMana() >= RGMercConfig:GetSettings().ManaMedPctStop then
            RGMercConfig.Globals.InMedState = false
            return
        end

        if me.PctHPs() < RGMercConfig:GetSettings().HPMedPct or me.PctMana() < RGMercConfig:GetSettings().ManaMedPct then
            enablesit = true
        end
    elseif RGMercConfig.Constants.RGMelee:contains(me.Class.ShortName()) then
        if me.PctHPs() >= RGMercConfig:GetSettings().HPMedPctStop and me.PctEndurance() >= RGMercConfig:GetSettings().EndMedPctStop then
            RGMercConfig.Globals.InMedState = false
            return
        end

        if me.PctHPs() < RGMercConfig:GetSettings().HPMedPct or me.PctEndurance() < RGMercConfig:GetSettings().EndMedPct then
            enablesit = true
        end
    else
        RGMercsLogger.log_error("\arYour character class is not in the type list(s): rghybrid, rgcasters, rgmelee. That's a problem for a dev.")
        RGMercConfig.Globals.InMedState = false
        return
    end

    --RGMercsLogger.log_debug(
    --    "MED MAIN STATS CHECK :: Mana %d :: ManaMedPct %d :: Endurance %d :: EndPct %d", me.PctMana(), RGMercConfig:GetSettings().ManaMedPct, me.PctEndurance(),
    --    RGMercConfig:GetSettings().EndMedPct)

    if Utils.GetXTHaterCount() > 0 then
        if RGMercConfig:GetSettings().DoMelee then enablesit = false end
        if RGMercConfig:GetSettings().DoMed ~= 2 then enablesit = false end
    end

    if me.Sitting() and not enablesit then
        RGMercConfig.Globals.InMedState = false
        me.Stand()
        return
    end

    if not me.Sitting() and enablesit then
        RGMercConfig.Globals.InMedState = true
        RGMercsLogger.log_debug("Forcing a sit - all conditions met.")
        me.Sit()
    end
end

function Utils.ClickModRod()
    local me = mq.TLO.Me
    if me.PctMana() > RGMercConfig:GetSettings().ModRodManaPct or me.PctHPs() < 60 then return end

    for _, itemName in ipairs(RGMercConfig.Constants.ModRods) do
        local item = mq.TLO.FindItem(itemName)
        if item() and item.Timer() == 0 then
            mq.cmdf("/useitem \"%s\"", itemName)
            return
        end
    end
end

function Utils.DoBuffCheck()
    if not RGMercConfig:GetSettings().DoBuffs then return false end

    if mq.TLO.Me.Invis() then return false end

    if Utils.GetXTHaterCount() > 0 or RGMercConfig.Globals.AutoTargetID > 0 then return false end

    if (mq.TLO.MoveTo.Moving() or mq.TLO.Me.Moving() or mq.TLO.AdvPath.Following() or mq.TLO.Nav.Active()) and mq.TLO.Me.Class.ShortName():lower() ~= "brd" then return false end

    if RGMercConfig.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and mq.TLO.Me.PctMana() < 10 then return false end

    return true
end

function Utils.DoCamp()
    return Utils.GetXTHaterCount() == 0 and RGMercConfig.Globals.AutoTargetID == 0
end

function Utils.AutoCampCheck(config, tempConfig)
    if not config.ReturnToCamp then return end

    if mq.TLO.Me.Casting.ID() and mq.TLO.Me.Class.ShortName():lower() ~= "brd" then return end

    -- chasing a toon dont use camnp.
    if config.ChaseOn then return end

    -- camped in a different zone.
    if tempConfig.CampZoneId ~= mq.TLO.Zone.ID() then return end

    local me = mq.TLO.Me

    local distanceToCamp = mq.TLO.Math.Distance(string.format("%d,%d:%d,%d", me.Y(), me.X(), tempConfig.AutoCampY, tempConfig.AutoCampX))()

    if distanceToCamp >= 400 then
        Utils.PrintGroupMessage("I'm over 400 units from camp, not returning!")
        mq.cmdf("/rgl campoff")
        return
    end

    if distanceToCamp < config.AutoCampRadius then return end

    if distanceToCamp > 5 then
        local navTo = string.format("locyxz %d %d %d", tempConfig.AutoCampY, tempConfig.AutoCampX, tempConfig.AutoCampZ)
        if mq.TLO.Nav.PathExists(navTo)() then
            mq.cmdf("/nav %s", navTo)
            while mq.TLO.Nav.Active() do
                mq.delay(10)
                mq.doevents()
            end
        else
            mq.cmdf("/moveto loc %d %d|on", tempConfig.AutoCampY, tempConfig.AutoCampX)
            while mq.TLO.MoveTo.Moving() do
                mq.delay(10)
                mq.doevents()
            end
        end
    end
end

function Utils.EngageTarget(autoTargetId, preEngageRoutine)
    local config = RGMercConfig:GetSettings()

    if not config.DoAutoEngage then return end

    local target = mq.TLO.Target
    local assistId = RGMercConfig:GetAssistId()

    if mq.TLO.Me.State():lower() == "feign" and mq.TLO.Me.Class.ShortName():lower() ~= "mnk" then
        mq.TLO.Me.Stand()
    end

    if target() and target.ID() == autoTargetId and mq.TLO.Target.Distance() <= config.AssistRange then
        if config.DoMelee then
            if mq.TLO.Me.Sitting() then
                mq.TLO.Me.Stand()
            end

            if (Utils.GetTargetPctHPs() <= config.AutoAssistAt or assistId == mq.TLO.Me.ID()) and Utils.GetTargetPctHPs() > 0 then
                if target.Distance() > target.MaxRangeTo() then
                    RGMercsLogger.log_debug("Target is too far! %d>%d attempting to nav to it.", target.Distance(), target.MaxRangeTo())
                    if preEngageRoutine then
                        preEngageRoutine()
                    end

                    Utils.NavInCombat(config, assistId, autoTargetId, target.MaxRangeTo(), false)
                else
                    mq.cmdf("/nav stop log=off")
                    if mq.TLO.Stick.Status():lower() == "off" then
                        Utils.DoStick(config, assistId, autoTargetId)
                    end

                    if not mq.TLO.Me.Combat() then
                        RGMercsLogger.log_info("\awNOTICE:\ax Engaging %s in mortal combat.", target.CleanName())
                        mq.cmdf("/keypress AUTOPRIM")
                    end
                end
            end
        end
    else
        if not config.DoMelee and RGMercConfig.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and target.Named() and target.Body.Name() == "Dragon" then
            mq.cmdf("/stick pin 40")
        end

        -- TODO: why are we doing this after turning stick on just now?
        if mq.TLO.Stick.Status():lower() == "on" then mq.cmdf("/stick off") end
    end
end

function Utils.MercAssist()
    mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_CallForAssistButton").LeftMouseUp()
end

function Utils.MercEngage()
    local target = mq.TLO.Target
    local merc   = mq.TLO.Me.Mercenary

    if merc() and target() and target.ID() == RGMercConfig.Globals.AutoTargetID and target.Distance() < RGMercConfig:GetSettings().AssistRange then
        if Utils.GetTargetPctHPs() <= RGMercConfig:GetSettings().AutoAssistAt or                       -- Hit Assist HP
            merc.Class.ShortName():lower() == "clr" or                                                 -- Cleric can engage right away
            (merc.Class.ShortName():lower() == "war" and mq.TLO.Group.MainTank.ID() == merc.ID()) then -- Merc is our Main Tank
            return true
        end
    end

    return false
end

function Utils.KillPCPet()
    RGMercsLogger.log_warning("\arKilling your pet!")
    local problemPetOwner = mq.TLO.Spawn(string.format("id %d", mq.TLO.Me.XTarget(1).ID())).Master.CleanName()

    mq.cmdf("/dexecute %s /pet leave", problemPetOwner)
end

function Utils.HaveExpansion(name)
    return mq.TLO.Me.HaveExpansion(RGMercConfig.ExpansionNameToID[name])
end

function Utils.IsNamed(spawn)
    if not spawn() then return false end

    for _, n in ipairs(Utils.NamedList) do
        if spawn.Name() == n or spawn.CleanName() == n then return true end
    end

    return false
end

function Utils.IsPCSafe(t, name)
    if mq.TLO.DanNet(name)() then return true end

    for _, n in ipairs(RGMercConfig:GetSettings().OutsideAssistList) do
        if name == n then return true end
    end

    if mq.TLO.Group.Member(name)() then return true end
    if mq.TLO.Raid.Member(name)() then return true end

    if mq.TLO.Spawn(string.format("%s =%s", t, name)).Guild() == mq.TLO.Me.Guild() then return true end

    return false
end

---@param spawn any
---@param radius number
---@return boolean
function Utils.IsSpawnFightingStranger(spawn, radius)
    local searchTypes = { "PC", "PCPET", "MERCENARY" }

    for _, t in ipairs(searchTypes) do
        local count = mq.TLO.SpawnCount(string.format("%s radius %d zradius %d", t, radius, radius))()

        for i = 1, count do
            local cur_spawn = mq.TLO.NearestSpawn(i, string.format("%s radius %d zradius %d", t, radius, radius))

            if cur_spawn() then
                if cur_spawn.AssistName():len() > 0 then
                    RGMercsLogger.log_debug("My Interest: %s =? Their Interest: %s", spawn.Name(), cur_spawn.AssistName())
                    if cur_spawn.AssistName() == spawn.Name() then
                        RGMercsLogger.log_debug("[%s] Fighting same mob as: %s Theirs: %s Ours: %s", t, cur_spawn.CleanName(), cur_spawn.AssistName(), spawn.Name())
                        if not Utils.IsPCSafe(t, cur_spawn.CleanName()) then
                            RGMercsLogger.log_info("\ar WARNING: \ax Almost attacked other PCs [%s] mob. Not attacking \aw%s\ax", cur_spawn.CleanName(), cur_spawn.AssistName())
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

function Utils.DoCombatActions()
    if RGMercConfig.Globals.LastMove then return false end
    if RGMercConfig.Globals.AutoTargetID == 0 then return false end
    if Utils.GetXTHaterCount() == 0 then return false end

    -- We can't assume our target is our autotargetid for where this sub is used.
    local autoSpawn = mq.TLO.Spawn(RGMercConfig.Globals.AutoTargetID)
    if autoSpawn() and autoSpawn.Distance() > RGMercConfig:GetSettings().AssistRange then return false end

    return true
end

---@param radius number
---@param zradius number
---@return number
function Utils.MATargetScan(radius, zradius)
    local aggroSearch    = string.format("npc radius %d zradius %d targetable playerstate 4", radius, zradius)
    local aggroSearchPet = string.format("npcpet radius %d zradius %d targetable playerstate 4", radius, zradius)

    local lowestHP       = 101
    local killId         = 0

    -- Maybe spawn search is failing us -- look through the xtarget list
    local xtCount        = mq.TLO.Me.XTarget()

    for i = 1, xtCount do
        local xtSpawn = mq.TLO.Me.XTarget(i)

        if xtSpawn() and xtSpawn.Type():lower() == "auto hater" and xtSpawn.ID() > 0 then
            RGMercsLogger.log_verbose("Found %s [%d] Distance: %d", xtSpawn.CleanName(), xtSpawn.ID(), xtSpawn.Distance())
            if xtSpawn.Distance() <= radius then
                -- Check for lack of aggro and make sure we get the ones we haven't aggro'd. We can't
                -- get aggro data from the spawn data type.
                if Utils.HaveExpansion("EXPANSION_LEVEL_ROF") then
                    if xtSpawn.PctAggro() < 100 and RGMercConfig.Globals.IsTanking then
                        -- Coarse check to determine if a mob is _not_ mezzed. No point in waking a mezzed mob if we don't need to.
                        if RGMercConfig.Constants.RGMezAnims:contains(xtSpawn.Animation()) then
                            RGMercsLogger.log_verbose("Have not fully aggro'd %s -- returning %s [%d]", xtSpawn.CleanName(), xtSpawn.CleanName(), xtSpawn.ID())
                            return xtSpawn.ID()
                        end
                    end
                end

                -- If a name has take priority.
                if Utils.IsNamed(xtSpawn) then
                    RGMercsLogger.log_verbose("Found Named: %s -- returning %d", xtSpawn.CleanName(), xtSpawn.ID())
                    return xtSpawn.ID()
                end

                if xtSpawn.Body.Name():lower() == "Giant" then
                    return xtSpawn.ID()
                end

                if xtSpawn.PctHPs() < lowestHP then
                    lowestHP = xtSpawn.PctHPs()
                    killId = xtSpawn.ID()
                end
            end
        end
    end

    RGMercsLogger.log_verbose("We apparently didn't find anything on xtargets, doing a search for mezzed targets")

    -- We didn't find anything to kill yet so spawn search
    if killId == 0 then
        RGMercsLogger.log_verbose("Falling back on Spawn Searching")
        local aggroMobCount = mq.TLO.SpawnCount(aggroSearch)()
        local aggroMobPetCount = mq.TLO.SpawnCount(aggroSearchPet)()
        RGMercsLogger.log_verbose("NPC Target Scan: %s ===> %d", aggroSearch, aggroMobCount)
        RGMercsLogger.log_verbose("NPCPET Target Scan: %s ===> %d", aggroSearchPet, aggroMobPetCount)

        for i = 1, aggroMobCount do
            local spawn = mq.TLO.NearestSpawn(i, aggroSearch)

            if spawn() then
                -- If the spawn is already in combat with someone else, we should skip them.
                if not RGMercConfig:GetSettings().SafeTargeting or not Utils.IsSpawnFightingStranger(spawn, radius) then
                    -- If a name has pulled in we target the name first and return. Named always
                    -- take priority. Note: More mobs as of ToL are "named" even though they really aren't.

                    if Utils.IsNamed(spawn) then
                        RGMercsLogger.log_verbose("DEBUG Found Named: %s -- returning %d", spawn.CleanName(), spawn.ID())
                        return spawn.ID()
                    end

                    -- Unmezzables
                    if (spawn.Body.Name() or "none"):lower() == "Giant" then
                        return spawn.ID()
                    end

                    -- Lowest HP
                    if spawn.PctHPs() < lowestHP then
                        lowestHP = spawn.PctHPs()
                        killId = spawn.ID()
                    end
                end
            end
        end

        for i = 1, aggroMobPetCount do
            local spawn = mq.TLO.NearestSpawn(i, aggroSearchPet)

            if not RGMercConfig:GetSettings().SafeTargeting or not Utils.IsSpawnFightingStranger(spawn, radius) then
                -- Lowest HP
                if spawn.PctHPs() < lowestHP then
                    lowestHP = spawn.PctHPs()
                    killId = spawn.ID()
                end
            end
        end
    end

    RGMercsLogger.log_verbose("\agMATargetScan Returning: \at%d", killId)
    return killId
end

function Utils.FindTarget()
    RGMercsLogger.log_verbose("FindTarget()")
    if mq.TLO.Spawn(string.format("id %d pcpet xtarhater", mq.TLO.Me.XTarget(1).ID())).ID() > 0 then
        RGMercsLogger.log_verbose("FindTarget() Determined that xtarget(1)=%s is a pcpet xtarhater", mq.TLO.Me.XTarget(1).CleanName())
        Utils.KillPCPet()
    end

    -- Handle cases where our autotarget is no longer valid because it isn't a valid spawn or is dead.

    -- TODO: Add pulling code here.

    if RGMercConfig.Globals.AutoTargetID ~= 0 then
        local autoSpawn = mq.TLO.Spawn(string.format("id %d", RGMercConfig.Globals.AutoTargetID))
        if not autoSpawn() or autoSpawn.Type():lower() == "corpse" then
            Utils.ClearTarget()
        end
    end

    -- FollowMarkTarget causes RG to have allow RG toons focus on who the group has marked. We'll exit early if this is the case.
    if RGMercConfig:GetSettings().FollowMarkTarget then
        if mq.TLO.Me.GroupMarkNPC(1).ID() and RGMercConfig.Globals.AutoTargetID ~= mq.TLO.Me.GroupMarkNPC(1).ID() then
            RGMercConfig.Globals.AutoTargetID = mq.TLO.Me.GroupMarkNPC(1).ID()
            return
        end
    end

    local target = mq.TLO.Target

    -- Now handle normal situations where we need to choose a target because we don't have one.
    if Utils.IAmMA() then
        RGMercsLogger.log_verbose("FindTarget() ==> I am MA!")
        -- We need to handle manual targeting and autotargeting seperately
        if not RGMercConfig:GetSettings().DoAutoTarget then
            -- Manual targetting let the manual user target any npc or npcpet.
            if RGMercConfig.Globals.AutoTargetID ~= target.ID() and
                (target.Type():lower() == "npc" or target.Type():lower() == "npcpet") and
                target.Distance() < RGMercConfig:GetSettings().AssistRange and
                target.DistanceZ() < 20 and
                target.Aggressive() then
                RGMercsLogger.log_info("Targeting: \ag%s\ax [ID: \ag%d\ax]", target.CleanName(), target.ID())
                RGMercConfig.Globals.AutoTargetID = target.ID()
            end
        else
            -- If we're the main assist, we need to scan our nearby area and choose a target based on our built in algorithm. We
            -- only need to do this if we don't already have a target. Assume if any mob runs into camp, we shouldn't reprioritize
            -- unless specifically told.

            if RGMercConfig.Globals.AutoTargetID == 0 then
                -- If we currently don't have a target, we should see if there's anything nearby we should go after.
                RGMercConfig.Globals.AutoTargetID = Utils.MATargetScan(RGMercConfig:GetSettings().AssistRange, RGMercConfig:GetSettings().MAScanZRange)
                RGMercsLogger.log_verbose("MATargetScan returned %d -- Current Target: %s [%d]", RGMercConfig.Globals.AutoTargetID, target.CleanName(), target.ID())
            else
                -- If StayOnTarget is off, we're going to scan if we don't have full aggro. As this is a dev applied setting that defaults to on, it should
                -- Only be turned off by tank modes.
                if not RGMercConfig:GetSettings().StayOnTarget then
                    RGMercConfig.Globals.AutoTargetID = Utils.MATargetScan(RGMercConfig:GetSettings().AssistRange, RGMercConfig:GetSettings().MAScanZRange)
                    local autoTarget = mq.TLO.Spawn(RGMercConfig.Globals.AutoTargetID)
                    RGMercsLogger.log_verbose("Re-Targeting: MATargetScan says we need to target %s [%d] -- Current Target: %s [%d]",
                        autoTarget.CleanName() or "None", RGMercConfig.AutoTargetID or 0, target() and target.CleanName() or "None", target() and target.ID() or 0)
                end
            end
        end
    else
        -- We're not the main assist so we need to choose our target based on our main assist.
        -- Only change if the group main assist target is an NPC ID that doesn't match the current autotargetid. This prevents us from
        -- swapping to non-NPCs if the  MA is trying to heal/buff a friendly or themselves.
        if RGMercConfig:GetSettings().AssistOutside then
            local assist = mq.TLO.Spawn(RGMercConfig:GetAssistId())
            local assistTarget = mq.TLO.Spawn(assist.AssistName())

            RGMercsLogger.log_verbose("FindTarget Assisting %s [%d] -- Target Agressive: %s", RGMercConfig.Globals.MainAssist, assist.ID(),
                assistTarget.Aggressive() and "True" or "False")

            if assistTarget() and assistTarget.Aggressive() and (assistTarget.Type():lower() == "npc" or assistTarget.Type():lower() == "npcpet") then
                RGMercsLogger.log_verbose(" FindTarget Setting Target To %s [%d]", assistTarget.CleanName(), assistTarget.ID())
                RGMercConfig.Globals.AutoTargetID = assistTarget.ID()
            end
        else
            RGMercConfig.Globals.AutoTargetID = mq.TLO.Me.GroupAssistTarget() and mq.TLO.Me.GroupAssistTarget.ID() or 0
        end
    end
    --Target the new target we'll do another spawn check just in case. Given we just did our spawn checks,
    -- Assume the target is still valid so we don't do two more spawn checks.
    if RGMercConfig.Globals.AutoTargetID > 0 and Utils.GetTargetID() ~= RGMercConfig.Globals.AutoTargetID then
        Utils.SetTarget(RGMercConfig.Globals.AutoTargetID)
    end
end

function Utils.GetXTHaterCount()
    local xtCount = mq.TLO.Me.XTarget() or 0
    local haterCount = 0

    for i = 1, xtCount do
        local xtarg = mq.TLO.Me.XTarget(i)
        if xtarg and xtarg.PctAggro() > 1 then
            haterCount = haterCount + 1
        end
    end

    return haterCount
end

function Utils.SetControlTool()
    if RGMercConfig:GetSettings().AssistOutside then
        if #RGMercConfig:GetSettings().OutsideAssistList > 0 then
            for _, name in ipairs(RGMercConfig:GetSettings().OutsideAssistList) do
                local assistSpawn = mq.TLO.Spawn(string.format("PC =%s", name))

                if assistSpawn() then
                    RGMercsLogger.log_info("Setting new assist to %s [%d]", assistSpawn.CleanName(), assistSpawn.ID())
                    mq.cmdf("/squelch /xtarget assist %d", assistSpawn.ID())
                    RGMercConfig.Globals.MainAssist = assistSpawn.CleanName()
                end
            end
        else
            if not RGMercConfig.Globals.MainAssist or RGMercConfig.Globals.MainAssist:len() == 0 then
                -- Use our Target hope for the best!
                mq.cmdf("/squelch /xtarget assist %d", mq.TLO.Target.ID())
                RGMercConfig.Globals.MainAssist = mq.TLO.Target.CleanName()
            end
        end
    end
end

function Utils.IAmMA()
    return RGMercConfig:GetAssistId() == mq.TLO.Me.ID()
end

function Utils.FindTargetCheck()
    local config = RGMercConfig:GetSettings()

    RGMercsLogger.log_verbose("FindTargetCheck(%d, %s, %s, %s)", Utils.GetXTHaterCount(), Utils.IAmMA() and "TRUE" or "FALSE", config.FollowMarkTarget and "TRUE" or "FALSE",
        RGMercConfig.Globals.BackOffFlag and "FALSE" or "TRUE")
    -- TODO: Add Do Pull logic
    return (Utils.GetXTHaterCount() > 0 or Utils.IAmMA() or config.FollowMarkTarget) and not RGMercConfig.Globals.BackOffFlag
end

function Utils.OkToEngage(autoTargetId)
    local config = RGMercConfig:GetSettings()

    if not config.DoAutoEngage then return false end
    local target = mq.TLO.Target
    local assistId = RGMercConfig:GetAssistId()

    if not target() then return false end

    if target.ID() ~= autoTargetId then
        RGMercsLogger.log_debug("%d != %d --> Not Engageing", target.ID() or 0, autoTargetId)
        return false
    end

    if target.Mezzed.ID() and not config.AllowMezBreak then
        RGMercsLogger.log_debug("Target is mezzed and not AllowMezBreak --> Not Engaging")
        return false
    end

    if Utils.GetXTHaterCount() > 0 then -- TODO: or AutoTargetID and !BackOffFlag
        if target.Distance() < config.AssistRange and (Utils.GetTargetPctHPs() < config.AutoAssistAt or RGMercConfig.Globals.IsTanking or assistId == mq.TLO.Me.ID()) then
            if not mq.TLO.Me.Combat() then
                RGMercsLogger.log_debug("\ay%d < %d and %d < %d or Tanking or %d == %d --> \agOK To Engage!",
                    target.Distance(), config.AssistRange, Utils.GetTargetPctHPs(), config.AutoAssistAt, assistId, mq.TLO.Me.ID())
            end
            return true
        end
    end

    return false
end

function Utils.PetAttack(config, target)
    if not config.DoPet then return end

    local pet = mq.TLO.Me.Pet

    if not target() then return end
    if not pet() then return end

    if (not pet.Combat() or pet.Target.ID() ~= target.ID()) and target.Type() == "NPC" and (Utils.GetTargetPctHPs() <= config.PetEngagePct) then
        mq.cmdf("/squelch /pet attack")
        mq.cmdf("/squelch /pet swarm")
        RGMercsLogger.log_debug("Pet sent to attack target: %s!", target.Name())
    end
end

function Utils.DetAACheck(aaId)
    if Utils.GetTargetID() == 0 then return false end
    local Target = mq.TLO.Target
    local Me     = mq.TLO.Me

    return (not Target.FindBuff("id " .. tostring(Me.AltAbility(aaId).Spell.ID())).ID() and
            not Target.FindBuff("id " .. tostring(Me.AltAbility(aaId).Spell.Trigger(1).ID()))) and
        (Me.AltAbility(aaId).Spell.StacksTarget() or Me.AltAbility(aaId).Spell.Trigger(1).StacksTarget())
end

function Utils.SetLoadOut(caller, t, itemSets, abilitySets)
    local spellLoadOut = {}
    local resolvedActionMap = {}
    local spellsToLoad = {}

    -- Map AbilitySet Items and Load Them
    for k, t in pairs(itemSets) do
        RGMercsLogger.log_debug("Finding best item for Set: %s", k)
        resolvedActionMap[k] = Utils.GetBestItem(t)
    end
    for k, t in pairs(abilitySets) do
        RGMercsLogger.log_debug("\ayFinding best spell for Set: \am%s", k)
        resolvedActionMap[k] = Utils.GetBestSpell(t)
    end

    for _, g in ipairs(t) do
        if not g.cond or g.cond(caller, g.gem) then
            RGMercsLogger.log_debug("\ayGem \am%d\ay will be loaded.", g.gem)

            for _, s in ipairs(g.spells) do
                local spellName = s.name
                RGMercsLogger.log_debug("\aw  ==> Testing \at%s\aw for Gem \am%d", spellName, g.gem)
                local bestSpell = resolvedActionMap[spellName]
                if bestSpell then
                    local bookSpell = mq.TLO.Me.Book(bestSpell.RankName())()
                    local pass = not s.cond or s.cond(caller)
                    local loadedSpell = spellsToLoad[bestSpell.RankName()] or false

                    if pass and bestSpell and bookSpell and not loadedSpell then
                        RGMercsLogger.log_debug("    ==> \ayGem \am%d\ay will load \at%s\ax ==> \ag%s", g.gem, s.name, bestSpell.RankName())
                        spellLoadOut[g.gem] = bestSpell
                        spellsToLoad[bestSpell.RankName()] = true
                        break
                    else
                        RGMercsLogger.log_debug("    ==> \ayGem \am%d will \arNOT\ay load \at%s (pass=%s, bestSpell=%s, bookSpell=%d, loadedSpell=%s)", g.gem, s.name,
                            pass and "TRUE" or "FALSE", bestSpell and bestSpell.RankName() or "", bookSpell or -1, loadedSpell and "TRUE" or "FALSE")
                    end
                else
                    RGMercsLogger.log_debug("    ==> \ayGem \am%d\ay will \arNOT\ay load \at%s\ax ==> \arNo Resolved Spell!", g.gem, s.name)
                end
            end
        else
            RGMercsLogger.log_debug("\arGem %d will not be loaded.", g.gem)
        end
    end

    return resolvedActionMap, spellLoadOut
end

function Utils.Tooltip(desc)
    ImGui.SameLine()
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 25.0)
        ImGui.Text(desc)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

function Utils.RenderZoneNamed()
    if Utils.LastZoneID ~= mq.TLO.Zone.ID() then
        Utils.LastZoneID = mq.TLO.Zone.ID()
        Utils.NamedList = {}
        local zoneName = mq.TLO.Zone.Name():lower()

        for _, n in ipairs(RGMercNameds[zoneName] or {}) do
            table.insert(Utils.NamedList, n)
        end

        zoneName = mq.TLO.Zone.ShortName():lower()

        for _, n in ipairs(RGMercNameds[zoneName] or {}) do
            table.insert(Utils.NamedList, n)
        end
    end

    if ImGui.BeginTable("Zone Nameds", 4, ImGuiTableFlags.None + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Index', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 250.0)
        ImGui.TableSetupColumn('Up', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, name in ipairs(Utils.NamedList) do
            local spawn = mq.TLO.Spawn(string.format("NPC =%s", name))
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            ImGui.TableNextColumn()
            ImGui.Text(name)
            ImGui.TableNextColumn()
            if spawn() and spawn.PctHPs() > 0 then
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 1.0)
                ImGui.Text(ICONS.FA_SMILE_O)
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                ImGui.Text(tostring(math.ceil(spawn.Distance())))
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                ImGui.Text(ICONS.FA_FROWN_O)
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                ImGui.Text("0")
            end
        end

        ImGui.EndTable()
    end
end

function Utils.DrawInspectableSpellIcon(iconID, spell)
    local cursor_x, cursor_y = ImGui.GetCursorPos()

    animSpellGems:SetTextureCell(iconID or 0)

    ImGui.DrawTextureAnimation(animSpellGems, ICON_SIZE, ICON_SIZE)

    ImGui.SetCursorPos(cursor_x, cursor_y)

    ImGui.PushID(tostring(iconID) .. spell.Name() .. "_invis_btn")
    ImGui.InvisibleButton(spell.Name(), ImVec2(ICON_SIZE, ICON_SIZE),
        bit32.bor(ImGuiButtonFlags.MouseButtonLeft))
    if ImGui.IsItemHovered() and ImGui.IsMouseReleased(ImGuiMouseButton.Left) then
        spell.Inspect()
    end
    ImGui.PopID()
end

function Utils.RenderLoadoutTable(t)
    if ImGui.BeginTable("Spells", 5, ImGuiTableFlags.Resizable + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Icon', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Gem', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Base Name', (ImGuiTableColumnFlags.WidthFixed), 150.0)
        ImGui.TableSetupColumn('Level', ImGuiTableColumnFlags.None, 20.0)
        ImGui.TableSetupColumn('Rank Name', ImGuiTableColumnFlags.None, 150.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for gem, spell in pairs(t) do
            ImGui.TableNextColumn()
            Utils.DrawInspectableSpellIcon(spell.SpellIcon(), spell)
            ImGui.TableNextColumn()
            ImGui.Text(tostring(gem))
            ImGui.TableNextColumn()
            ImGui.Text(spell.BaseName())
            ImGui.TableNextColumn()
            ImGui.Text(tostring(spell.Level()))
            ImGui.TableNextColumn()
            ImGui.Text(spell.RankName())
        end

        ImGui.EndTable()
    end
end

function Utils.RenderRotationTableKey()
    if ImGui.BeginTable("Rotation_keys", 2, ImGuiTableFlags.Borders) then
        ImGui.TableNextColumn()
        ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
        ImGui.Text(ICONS.FA_SMILE_O .. ": Active")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
        ImGui.Text(ICONS.MD_CHECK .. ": Will Cast (Coditions Met)")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
        ImGui.Text(ICONS.FA_EXCLAMATION .. ": Cannot Cast")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 1.0, 1.0)
        ImGui.Text(ICONS.MD_CHECK .. ": Will Cast (No Conditions)")

        ImGui.PopStyleColor()
        ImGui.EndTable()
    end
end

function Utils.RenderRotationTable(s, n, t, map, rotationState)
    if ImGui.BeginTable("Rotation_" .. n, rotationState and 4 or 3, ImGuiTableFlags.Resizable + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('ID', ImGuiTableColumnFlags.WidthFixed, 20.0)
        if rotationState then
            ImGui.TableSetupColumn('Cur', ImGuiTableColumnFlags.WidthFixed, 20.0)
        end
        ImGui.TableSetupColumn('Condition Met', ImGuiTableColumnFlags.WidthFixed, 20.0)
        ImGui.TableSetupColumn('Action', ImGuiTableColumnFlags.WidthStretch, 250.0)

        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, entry in ipairs(t) do
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            if rotationState then
                ImGui.TableNextColumn()
                ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                if idx == rotationState then
                    ImGui.Text(ICONS.FA_DOT_CIRCLE_O)
                else
                    ImGui.Text("")
                end
                ImGui.PopStyleColor()
            end
            ImGui.TableNextColumn()
            if entry.cond then
                local pass = entry.cond(s, map[entry.name] or mq.TLO.Spell(entry.name))
                local active = entry.active_cond and entry.active_cond(s, map[entry.name] or mq.TLO.Spell(entry.name)) or false

                if active == true then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                    ImGui.Text(ICONS.FA_SMILE_O)
                elseif pass == true then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                    ImGui.Text(ICONS.MD_CHECK)
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                    ImGui.Text(ICONS.FA_EXCLAMATION)
                end
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 1.0, 1.0)
                ImGui.Text(ICONS.MD_CHECK)
            end
            ImGui.PopStyleColor()
            if entry.tooltip then
                Utils.Tooltip(entry.tooltip)
            end
            ImGui.TableNextColumn()
            local mappedAction = map[entry.name]
            if mappedAction then
                if type(mappedAction) == "userdata" then
                    ImGui.Text(entry.name .. " ==> " .. mappedAction.RankName() or mappedAction.Name())
                else
                    ImGui.Text(entry.name .. " ==> " .. mappedAction)
                end
            else
                ImGui.Text(entry.name)
            end
        end

        ImGui.EndTable()
    end
end

function Utils.RenderOptionToggle(id, text, on)
    local toggled = false
    local state   = on
    ImGui.PushID(id .. "_togg_btn")
    if on then
        if ImGui.SmallButton(ICONS.FA_TOGGLE_ON) then
            toggled = true
            state   = false
        end
    else
        if ImGui.SmallButton(ICONS.FA_TOGGLE_OFF) then
            toggled = true
            state   = true
        end
    end
    ImGui.PopID()
    ImGui.SameLine()
    ImGui.Text(text)

    return state, toggled
end

function Utils.RenderOptionNumber(id, text, cur, min, max)
    ImGui.PushID("##num_spin_" .. id)
    local input, changed = ImGui.InputInt(text, cur)
    ImGui.PopID()

    if input > max then input = max end
    if input < min then input = min end


    changed = cur ~= input
    return input, changed
end

function Utils.RenderSettings(settings, defaults)
    local any_pressed = false
    local new_loadout = false
    local pressed = false

    local settingNames = {}
    for k, _ in pairs(defaults) do
        table.insert(settingNames, k)
    end

    local renderWidth = 300
    local windowWidth = ImGui.GetWindowWidth()
    local numCols = math.max(1, math.floor(windowWidth / renderWidth))

    table.sort(settingNames, function(k1, k2) return defaults[k1].DisplayName < defaults[k2].DisplayName end)

    if ImGui.BeginTable("Options", 2 * numCols, ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        for i = 1, numCols do
            ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
            ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthFixed), 150.0)
        end
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for _, k in ipairs(settingNames) do
            if defaults[k].Type ~= "Custom" then
                ImGui.TableNextColumn()
                if type(settings[k]) == 'boolean' then
                    settings[k], pressed = Utils.RenderOptionToggle(k, "", settings[k])
                    new_loadout = (pressed and (defaults[k].RequiresLoadoutChange or false))
                    any_pressed = any_pressed or pressed
                elseif type(settings[k]) == 'number' then
                    settings[k], pressed = Utils.RenderOptionNumber(k, "", settings[k], defaults[k].Min,
                        defaults[k].Max)
                    new_loadout = (pressed and (defaults[k].RequiresLoadoutChange or false))
                    any_pressed = any_pressed or pressed
                end
                ImGui.TableNextColumn()
                ImGui.Text((defaults[k].DisplayName or "None"))
                Utils.Tooltip(defaults[k].Tooltip)
            end
        end
        ImGui.EndTable()
    end

    return settings, any_pressed, new_loadout
end

function Utils.LoadSpellLoadOut(t)
    local selectedRank = ""

    for gem, spell in pairs(t) do
        if mq.TLO.Me.SpellRankCap() > 1 then
            selectedRank = spell.RankName()
        else
            selectedRank = spell.BaseName()
        end

        if mq.TLO.Me.Gem(gem)() ~= selectedRank then
            Utils.MemorizeSpell(gem, selectedRank)
        end
    end
end

mq.event('Being Memo', "Beginning to memorize #1#...", function(spell)
    Memorizing = true
end)

mq.event('End Memo', "You have finished memorizing #1#", function(spell)
    Memorizing = false
end)

mq.event('Abort Memo', "Aborting memorization of spell.", function()
    Memorizing = false
end)

return Utils
