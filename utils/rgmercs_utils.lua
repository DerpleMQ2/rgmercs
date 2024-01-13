local mq                 = require('mq')
local Set                = require('mq.set')
local animSpellGems      = mq.FindTextureAnimation('A_SpellGems')
local ICONS              = require('mq.Icons')
local ICON_SIZE          = 20

-- Global

local Utils              = { _version = '0.2a', _name = "RGMercUtils", _author = 'Derple', }
Utils.__index            = Utils
Utils.Actors             = require('actors')
Utils.ScriptName         = "RGMercs"
Utils.LastZoneID         = 0
Utils.LastDoStick        = 0
Utils.NamedList          = {}
Utils.ShowDownNamed      = false
Utils.ShowAdvancedConfig = false
Utils.Memorizing         = false
Utils.UseGem             = mq.TLO.Me.NumGems()

---@param path string
---@return boolean
function Utils.file_exists(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

---@param module string
---@param event string
---@param data table|nil
function Utils.BroadcastUpdate(module, event, data)
    Utils.Actors.send({ from = RGMercConfig.Globals.CurLoadedChar, script = Utils.ScriptName, module = module, event = event, data = data, })
end

---@param time integer # in seconds
---@return string
function Utils.FormatTime(time)
    local days = math.floor(time / 86400)
    local hours = math.floor((time % 86400) / 3600)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = math.floor((time % 60))
    return string.format("%d:%02d:%02d:%02d", days, hours, minutes, seconds)
end

---@param msg string
---@param ... any
function Utils.PrintGroupMessage(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    Utils.DoCmd("/dgt group_%s_%s %s", RGMercConfig.Globals.CurServer, mq.TLO.Group.Leader() or "None", output)
end

---@param defaults table
---@param settings table
---@return table
function Utils.ResolveDefaults(defaults, settings)
    -- Setup Defaults
    for k, v in pairs(defaults) do
        if settings[k] == nil then settings[k] = v.Default end

        if type(settings[k]) ~= type(v.Default) then
            RGMercsLogger.log_info("\ayData type of setting [\am%s\ay] has been deprecated -- resetting to default.", k)
            settings[k] = v.Default
        end
    end

    -- Remove Deprecated options
    for k, _ in pairs(settings) do
        if not defaults[k] then
            settings[k] = nil
            RGMercsLogger.log_info("\aySetting [\am%s\ay] has been deprecated -- removing from your config.", k)
        end
    end

    return settings
end

---@param msg string
---@param ... any
function Utils.PopUp(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    Utils.DoCmd("/popup %s", output)
end

---@param targetId integer
function Utils.SetTarget(targetId)
    if targetId == mq.TLO.Target.ID() then return end
    RGMercsLogger.log_debug("Setting Target: %d", targetId)
    if RGMercConfig:GetSettings().DoAutoTarget then
        if Utils.GetTargetID() ~= targetId then
            Utils.DoCmd("/target id %d", targetId)
            mq.delay(10)
        end
    end
end

function Utils.ClearTarget()
    RGMercsLogger.log_debug("Clearing Target")
    if RGMercConfig:GetSettings().DoAutoTarget then
        RGMercConfig.Globals.AutoTargetID = 0
        RGMercConfig.Globals.BurnNow = false
        if mq.TLO.Stick.Status():lower() == "on" then Utils.DoCmd("/stick off") end
        Utils.DoCmd("/target clear")
    end
end

function Utils.HandleDeath()
    RGMercsLogger.log_warning("You are sleeping with the fishes.")

    Utils.ClearTarget()

    RGMercModules:ExecAll("OnDeath")

    while mq.TLO.Me.Hovering() do
        if mq.TLO.Window("RespawnWnd").Open() and RGMercConfig:GetSettings().InstantRelease then
            mq.TLO.Window("RespawnWnd").Child("RW_OptionsList").Select(1)
            mq.delay("1s")
            mq.TLO.Window("RespawnWnd").Child("RW_SelectButton").LeftMouseUp()
        else
            break
        end
    end

    mq.delay("1m", function() return (not mq.TLO.Me.Zoning()) end)

    if RGMercConfig:GetSettings().DoFellow then
        if mq.TLO.FindItem("Fellowship Registration Insignia").Timer.TotalSeconds() == 0 then
            mq.delay("30s", function() return (mq.TLO.Me.CombatState():lower() == "active") end)
            Utils.DoCmd("/useitem \"Fellowship Registration Insignia\"")
            mq.delay("2s", function() return (mq.TLO.FindItem("Fellowship Registration Insignia").Timer.TotalSeconds() ~= 0) end)
        else
            RGMercsLogger.log_error("\aw Bummer, Insignia on cooldown, you must really suck at this game...")
        end
    end
end

---@param t table
function Utils.CheckPlugins(t)
    for _, p in pairs(t) do
        if not mq.TLO.Plugin(p)() then
            Utils.DoCmd("/squelch /plugin %s noauto", p)
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
            Utils.DoCmd("/squelch /plugin %s unload noauto", p)
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

---@param aaName string
---@return boolean
function Utils.CanUseAA(aaName)
    return mq.TLO.Me.AltAbility(aaName)() and mq.TLO.Me.AltAbility(aaName).MinLevel() <= mq.TLO.Me.Level() and mq.TLO.Me.AltAbility(aaName).Rank() > 0
end

---@return boolean
function Utils.CanAlliance()
    return true
end

---@param aaName string
---@return boolean
function Utils.AAReady(aaName)
    return Utils.CanUseAA(aaName) and mq.TLO.Me.AltAbilityReady(aaName)()
end

---@param aaName string
---@return boolean
function Utils.AbilityReady(aaName)
    return mq.TLO.Me.AbilityReady(aaName)()
end

---@param aaName string
---@return number
function Utils.AARank(aaName)
    return Utils.CanUseAA(aaName) and mq.TLO.Me.AltAbility(aaName).Rank() or 0
end

---@param name string
---@return boolean
function Utils.IsDisc(name)
    local spell = mq.TLO.Spell(name)

    return (spell() and spell.IsSkill() and spell.Duration() and not spell.StacksWithDiscs() and spell.TargetType():lower() == "self") and true or false
end

---@param spell MQSpell
---@return boolean
function Utils.PCSpellReady(spell)
    if not spell or not spell() then return false end
    local me = mq.TLO.Me

    if me.Stunned() then return false end

    return me.CurrentMana() > spell.Mana() and (me.Casting.ID() or 0) == 0 and me.Book(spell.RankName())() ~= nil and not me.Moving()
end

---@param discSpell MQSpell
---@return boolean
function Utils.PCDiscReady(discSpell)
    if not discSpell or not discSpell() then return false end
    RGMercsLogger.log_verbose("PCDiscReady(%s)", discSpell.RankName() or "None")
    return mq.TLO.Me.CombatAbilityReady(discSpell.RankName()) and mq.TLO.Me.CurrentEndurance() > (discSpell.EnduranceCost() or 0)
end

---@param aaName string
---@return boolean
function Utils.PCAAReady(aaName)
    local spell = mq.TLO.Me.AltAbility(aaName).Spell
    return Utils.AAReady(aaName) and mq.TLO.Me.CurrentMana() >= (spell.Mana() or 0) or mq.TLO.Me.CurrentEndurance() >= (spell.EnduranceCost() or 0)
end

---@return boolean
function Utils.NPCSpellReady(spell, targetId, healingSpell)
    local me = mq.TLO.Me
    local spell = mq.TLO.Spell(spell)

    if targetId == 0 then targetId = mq.TLO.Target.ID() end

    if not spell or not spell() then return false end

    if me.Stunned() then return false end

    local target = mq.TLO.Spawn(targetId)

    if not target or not target() then return false end

    if me.SpellReady(spell.RankName()) and me.CurrentMana() >= spell.Mana() then
        if not me.Moving() and not me.Casting.ID() and target.Type():lower() ~= "corpse" then
            if target.LineOfSight() then
                return true
            elseif healingSpell then
                return true
            end
        end
    end

    return false
end

---@return boolean
function Utils.NPCAAReady(aaName, targetId, healingSpell)
    local me = mq.TLO.Me
    local ability = mq.TLO.Me.AltAbility(aaName)

    if targetId == 0 then targetId = mq.TLO.Target.ID() end

    if not ability or not ability() then return false end

    if me.Stunned() then return false end

    local target = mq.TLO.Spawn(targetId)

    if not target or not target() or target.Dead() then return false end

    if Utils.AAReady(aaName) and me.CurrentMana() >= ability.Spell.Mana() and me.CurrentEndurance() >= ability.Spell.EnduranceCost() then
        if Utils.MyClassIs("brd") or (not me.Moving() and not me.Casting.ID()) then
            if target.LineOfSight() then
                return true
            elseif healingSpell then
                return true
            end
        end
    end

    return false
end

function Utils.GiveTo(toId, itemName, count)
    if toId ~= mq.TLO.Target.ID() then
        Utils.SetTarget(toId)
    end

    if not mq.TLO.Target() then
        RGMercsLogger.log_error("\arGiveTo but unable to target %d!", toId)
        return
    end

    if mq.TLO.Target.Distance() >= 25 then
        RGMercsLogger.log_debug("\arGiveTo but Target is too far away - moving closer!")
        Utils.DoCmd("/nav id %d |log=off dist=10")

        mq.delay("10s", function() return mq.TLO.Navigation.Active() end)
    end

    while not mq.TLO.Cursor.ID() do
        Utils.DoCmd("/shift /itemnotify \"%s\" leftmouseup", itemName)
        mq.delay(20, function() return mq.TLO.Cursor.ID() ~= nil end)
    end

    while mq.TLO.Cursor.ID() do
        Utils.DoCmd("/nomodkey /click left target")
        mq.delay(20, function() return mq.TLO.Cursor.ID() == nil end)
    end

    -- Click OK on trade window and wait for it to go away
    if mq.TLO.Target.Type():lower() == "pc" then
        mq.delay("5s", function() return mq.TLO.Window("TradeWnd").Open() end)
        mq.TLO.Window("TradeWnd").Child("TRDW_Trade_Button").LeftMouseUp()
        mq.delay("5s", function() return not mq.TLO.Window("TradeWnd").Open() end)
    else
        mq.delay("5s", function() return mq.TLO.Window("GiveWnd").Open() end)
        mq.TLO.Window("GiveWnd").Child("GVW_Give_Button").LeftMouseUp()
        mq.delay("5s", function() return not mq.TLO.Window("GiveWnd").Open() end)
    end

    -- We're giving something to a pet. In this case if the pet gives it back,
    -- get rid of it.
    if mq.TLO.Target.Type():lower() == "pet" then
        mq.delay("2s")
        if (mq.TLO.Cursor.ID() or 0) > 0 and mq.TLO.Cursor.NoRent() then
            RGMercsLogger.log_debug("\arGiveTo Pet return item - that ingreat!")
            Utils.DoCmd("/destroy")
            mq.delay("10s", function() return mq.TLO.Cursor.ID() == nil end)
        end
    end
end

---@param t table
---@return string|nil
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

---@param spellList table
---@return MQSpell|nil
function Utils.GetBestSpell(spellList, alreadyResolvedMap)
    local highestLevel = 0
    local selectedSpell = nil

    for _, spellName in ipairs(spellList or {}) do
        local spell = mq.TLO.Spell(spellName)
        if spell() ~= nil then
            --RGMercsLogger.log_debug("Found %s level(%d) rank(%s)", s, spell.Level(), spell.RankName())
            if spell.Level() <= mq.TLO.Me.Level() then
                if mq.TLO.Me.Book(spell.RankName())() or mq.TLO.Me.CombatAbility(spell.RankName())() then
                    if spell.Level() > highestLevel then
                        -- make sure we havent already found this one.
                        local alreadyUsed = false
                        for _, resolvedSpell in pairs(alreadyResolvedMap) do
                            if type(resolvedSpell) ~= "string" and resolvedSpell.ID() == spell.ID() then
                                alreadyUsed = true
                            end
                        end

                        if not alreadyUsed then
                            highestLevel = spell.Level()
                            selectedSpell = spell
                        end
                    end
                else
                    Utils.PrintGroupMessage(string.format(
                        "%s \aw [%s] \ax \ar ! MISSING SPELL ! \ax -- \ag %s \ax -- \aw LVL: %d \ax", mq.TLO.Me.CleanName(), spellName,
                        spell.RankName(), spell.Level()))
                end
            end
        end -- end if spell nil check
    end

    if selectedSpell then
        RGMercsLogger.log_debug("\agFound\ax %s level(%d) rank(%s)", selectedSpell.BaseName(), selectedSpell.Level(),
            selectedSpell.RankName())
    else
        RGMercsLogger.log_debug("\arNo spell found for slot!")
    end

    return selectedSpell
end

---@param target MQSpawn
function Utils.WaitCastFinish(target)
    local maxWaitOrig = ((mq.TLO.Me.Casting.MyCastTime.TotalSeconds() or 0) + ((mq.TLO.EverQuest.Ping() * 2 / 100) + 1)) * 1000
    local maxWait = maxWaitOrig

    ---@diagnostic disable-next-line: undefined-field
    while mq.TLO.Me.Casting() and (not mq.TLO.Cast.Ready()) do
        RGMercsLogger.log_verbose("Waiting to Finish Casting...")
        mq.delay(100)
        if target() and Utils.GetTargetPctHPs() <= 0 or (Utils.GetTargetID() ~= target.ID()) then
            mq.TLO.Me.StopCast()
            return
        end

        maxWait = maxWait - 100

        if maxWait <= 0 then
            local msg = string.format("StuckGem Data::: %d - MaxWait - %d - Casting Window: %s - Assist Target ID: %d", (mq.TLO.Me.Casting.ID() or -1), maxWaitOrig,
                Utils.BoolToString(mq.TLO.Window("CastingWindow").Open()), RGMercConfig.Globals.AutoTargetID)

            RGMercsLogger.log_debug(msg)
            Utils.PrintGroupMessage(msg)

            --Utils.DoCmd("/alt act 511")
            mq.TLO.Me.StopCast()
            return
        end

        mq.doevents()
    end
end

---@return boolean
function Utils.ManaCheck()
    return mq.TLO.Me.PctMana() >= RGMercConfig:GetSettings().ManaToNuke
end

---@param gem integer
---@param spell string
---@param maxWait number # max wait in ms
function Utils.MemorizeSpell(gem, spell, maxWait)
    RGMercsLogger.log_info("\ag Meming \aw %s in \ag slot %d", spell, gem)
    Utils.DoCmd("/memspell %d \"%s\"", gem, spell)

    while mq.TLO.Me.Gem(gem)() ~= spell and maxWait > 0 do
        RGMercsLogger.log_verbose("\ayWaiting for '%s' to load in slot %d'...", spell, gem)
        mq.delay(100)
        maxWait = maxWait - 100
    end
end

---@param spell string
function Utils.CastReady(spell)
    return mq.TLO.Me.SpellReady(spell)()
end

---@param spell string
---@param maxWait number # how many ms to wait before giving up
function Utils.WaitCastReady(spell, maxWait)
    while not mq.TLO.Me.SpellReady(spell)() and maxWait > 0 do
        mq.delay(100)
        mq.doevents()
        if Utils.GetXTHaterCount() > 0 then
            RGMercsLogger.log_debug("I was interruped by combat while waiting to cast %s.", spell)
            return
        end

        maxWait = maxWait - 100
        RGMercsLogger.log_verbose("Waiting for spell '%s' to be ready...", spell)
    end

    -- account for lag
    mq.delay(500)
end

function Utils.WaitGlobalCoolDown()
    while mq.TLO.Me.SpellInCooldown() do
        mq.delay(100)
        mq.doevents()
        RGMercsLogger.log_verbose("Waiting for Global Cooldown to be ready...")
    end
end

function Utils.ActionPrep()
    if not mq.TLO.Me.Standing() then
        mq.TLO.Me.Stand()
        mq.delay(10, function() return mq.TLO.Me.Standing() end)

        RGMercConfig.Globals.InMedState = false
    end

    if mq.TLO.Window("SpellBookWnd").Open() then
        mq.TLO.Window("SpellBookWnd").DoClose()
    end
end

---@param aaName string
---@param targetId integer
---@return boolean
function Utils.UseAA(aaName, targetId)
    local me = mq.TLO.Me
    local oldTargetId = mq.TLO.Target.ID()

    local aaAbility = mq.TLO.Me.AltAbility(aaName)

    if not aaAbility() then
        RGMercsLogger.log_verbose("\arYou dont have the AA: %s!", aaName)
        return false
    end

    if not mq.TLO.Me.AltAbilityReady(aaName) then
        RGMercsLogger.log_verbose("\ayAbility %s is not ready!", aaName)
        return false
    end

    if mq.TLO.Window("CastingWindow").Open() or me.Casting.ID() then
        if Utils.MyClassIs("brd") then
            mq.delay("3s", function() return (not mq.TLO.Window("CastingWindow").Open()) end)
            mq.delay(10)
            Utils.DoCmd("/stopsong")
        else
            RGMercsLogger.log_debug("\ayCANT CAST AA - Casting Window Open")
            return false
        end
    end

    local target = mq.TLO.Spawn(targetId)

    -- If we're combat casting we need to both have the same swimming status
    if target() and target.FeetWet() ~= me.FeetWet() then
        return false
    end

    Utils.ActionPrep()

    if Utils.GetTargetID() ~= targetId and target() then
        if me.Combat() and target.Type():lower() == "pc" then
            RGMercsLogger.log_info("\awNOTICE:\ax Turning off autoattack to cast on a PC.")
            Utils.DoCmd("/attack off")
            mq.delay("2s", function() return not me.Combat() end)
        end

        Utils.SetTarget(targetId)
    end

    local cmd = string.format("/alt act %d", aaAbility.ID())

    RGMercsLogger.log_debug("\ayActivating AA: '%s' [t: %d]", cmd, aaAbility.Spell.MyCastTime.TotalSeconds())
    Utils.DoCmd(cmd)

    mq.delay(5)

    if aaAbility.Spell.MyCastTime.TotalSeconds() > 0 then
        mq.delay(string.format("%ds", aaAbility.Spell.MyCastTime.TotalSeconds()))
    end

    if oldTargetId > 0 then
        RGMercsLogger.log_debug("switching target back to old target after casting aa")
        Utils.SetTarget(oldTargetId)
    end

    return true
end

---@param itemName string
---@param targetId integer
function Utils.UseItem(itemName, targetId)
    local me = mq.TLO.Me

    if mq.TLO.Window("CastingWindow").Open() or me.Casting.ID() then
        if Utils.MyClassIs("brd") then
            mq.delay("3s", function() return not mq.TLO.Window("CastingWindow").Open() end)
            mq.delay(10)
            Utils.DoCmd("/stopsong")
        else
            RGMercsLogger.log_debug("\arCANT Use Item - Casting Window Open")
            return
        end
    end

    if not itemName then
        return
    end

    local item = mq.TLO.FindItem("=" .. itemName)

    if not item() then
        RGMercsLogger.log_debug("\arTried to use item '%s' - but it is not found!", itemName)
        return
    end

    if Utils.BuffActiveByID(item.Clicky.SpellID()) then
        return
    end

    if Utils.BuffActiveByID(item.Spell.ID()) then
        return
    end

    if Utils.SongActive(item.Spell.RankName()) then
        return
    end

    Utils.ActionPrep()

    if not me.ItemReady(itemName) then
        return
    end

    local oldTargetId = Utils.GetTargetID()
    if targetId > 0 then
        Utils.DoCmd("/target id %d", targetId)
        mq.delay("2s", function() return Utils.GetTargetID() == targetId end)
    end

    RGMercsLogger.log_debug("\aw Using Item \ag %s", itemName)

    local cmd = string.format("/useitem \"%s\"", itemName)
    Utils.DoCmd(cmd)
    RGMercsLogger.log_debug("Running: \at'%s' [%d]", cmd, item.CastTime())

    mq.delay(2)

    if not item.CastTime() or item.CastTime() == 0 then
        -- slight delay for instant casts
        mq.delay(4)
    else
        local maxWait = 1000
        while maxWait > 0 and not me.Casting.ID() do
            RGMercsLogger.log_verbose("Waiting for item to start casting...")
            mq.delay(100)
            mq.doevents()
            maxWait = maxWait - 100
        end
        mq.delay(item.CastTime(), function() return not me.Casting.ID() end)

        -- pick up any additonal server lag.
        while me.Casting.ID() do
            mq.delay(5)
            mq.doevents()
        end
    end

    if mq.TLO.Cursor.ID() then
        Utils.DoCmd("/autoinv")
    end

    if oldTargetId > 0 then
        Utils.DoCmd("/target id %d", oldTargetId)
        mq.delay("2s", function() return Utils.GetTargetID() == oldTargetId end)
    else
        Utils.DoCmd("/target clear")
    end
end

---@param spell MQSpell
---@param targetId number
---@param targetName string
function Utils.CheckPCNeedsBuff(spell, targetId, targetName)
    if targetId == mq.TLO.Me.ID() then
        return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() == nil
    elseif mq.TLO.DanNet(targetName)() == nil then
        -- Target.
        Utils.SetTarget(targetId)
        mq.delay("2s", function() return mq.TLO.Target.BuffsPopulated() end)
        return mq.TLO.Target.FindBuff("id " .. tostring(spell.ID()))() == nil
    else
        -- DanNet
        local ret = DanNet.query(targetName, string.format("Me.FindBuff[id %d]", spell.ID()), 1000)

        return (ret == "NULL") or not ret
    end
end

---@param abilityName string
function Utils.UseAbility(abilityName)
    local me = mq.TLO.Me
    Utils.DoCmd("/doability %s", abilityName)
    mq.delay(8, function() return not me.AbilityReady(abilityName) end)
    RGMercsLogger.log_debug("Using Ability \ao =>> \ag %s \ao <<=", abilityName)
end

---@param discSpell MQSpell
---@param targetId integer
---@return boolean
function Utils.UseDisc(discSpell, targetId)
    local me = mq.TLO.Me

    if not discSpell or not discSpell() then return false end

    if mq.TLO.Window("CastingWindow").Open() or me.Casting.ID() then
        RGMercsLogger.log_debug("CANT USE Disc - Casting Window Open")
        return false
    else
        if me.CurrentEndurance() < discSpell.EnduranceCost() then
            return false
        else
            RGMercsLogger.log_debug("Trying to use Disc: %s", discSpell.RankName())

            Utils.ActionPrep()

            if Utils.IsDisc(discSpell.RankName()) then
                if me.ActiveDisc.ID() then
                    RGMercsLogger.log_debug("Cancelling Disc for %s -- Active Disc: [%s]", discSpell.RankName(), me.ActiveDisc.Name())
                    Utils.DoCmd("/stopdisc")
                    mq.delay(20, function() return not me.ActiveDisc.ID() end)
                end
            end

            Utils.DoCmd("/squelch /doability \"%s\"", discSpell.RankName())

            mq.delay(discSpell.MyCastTime() / 100 or 100, function() return (not me.CombatAbilityReady(discSpell.RankName()) and not me.Casting.ID()) end)

            -- Is this even needed?
            if Utils.IsDisc(discSpell.RankName()) then
                mq.delay(20, function() return me.ActiveDisc.ID() end)
            end

            RGMercsLogger.log_debug("\aw Cast >>> \ag %s", discSpell.RankName())

            return true
        end
    end
end

---@param spellName string
---@param targetId integer
---@param bAllowMem boolean
---@return boolean
function Utils.UseSpell(spellName, targetId, bAllowMem)
    local me = mq.TLO.Me
    RGMercsLogger.log_debug("\ayUseSpell(%s, %d, %s)", spellName, targetId, Utils.BoolToString(bAllowMem))
    if spellName then
        local spell = mq.TLO.Spell(spellName)

        if not spell() then
            RGMercsLogger.log_error("\arCasting Failed: Somehow I tried to cast a spell That doesn't exist: %s", spellName)
            return false
        end
        -- Check we actually have the spell -- Me.Book always needs to use RankName
        if not me.Book(spellName)() then
            RGMercsLogger.log_error("\arCasting Failed: Somehow I tried to cast a spell I didn't know: %s", spellName)
            return false
        end

        local targetSpawn = mq.TLO.Spawn(targetId)

        if targetSpawn() and targetSpawn.Type():lower() == "pc" then
            -- check to see if this is too powerful a spell
            local targetLevel    = targetSpawn.Level()
            local spellLevel     = spell.Level()
            local levelCheckPass = true
            if targetLevel <= 45 and spellLevel > 50 then levelCheckPass = false end
            if targetLevel <= 60 and spellLevel > 65 then levelCheckPass = false end
            if targetLevel <= 65 and spellLevel > 95 then levelCheckPass = false end

            if not levelCheckPass then
                RGMercsLogger.log_error("\arCasting %s failed level check with target=%d and spell=%d", spellName, targetLevel, spellLevel)
                return false
            end
        end

        -- Check for Reagents
        if not Utils.ReagentCheck(spell) then
            RGMercsLogger.log_verbose("\arCasting Failed: I tried to cast a spell %s I don't have Reagents for.", spellName)
            return false
        end

        -- Check for enough mana -- just in case something has changed by this point...
        if me.CurrentMana() < spell.Mana() then
            RGMercsLogger.log_verbose("\arCasting Failed: I tried to cast a spell %s I don't have mana for it.", spellName)
            return false
        end

        local target = mq.TLO.Spawn(targetId)

        -- If we're combat casting we need to both have the same swimming status
        if targetId == 0 or (target() and target.FeetWet() ~= me.FeetWet()) then
            RGMercsLogger.log_verbose("\arCasting Failed: I tried to cast a spell %s I don't have a target (%d) for it.", spellName, targetId)
            return false
        end

        Utils.WaitGlobalCoolDown()

        if (Utils.GetXTHaterCount() > 0 or not bAllowMem) and (not Utils.CastReady(spellName) or not mq.TLO.Me.Gem(spellName)()) then
            RGMercsLogger.log_debug("\ayI tried to cast %s but it was not ready and we are in combat - moving on.", spellName)
            return false
        end

        local spellRequiredMem = false
        if not me.Gem(spellName)() then
            RGMercsLogger.log_debug("\ay%s is not memorized - meming!", spellName)
            Utils.MemorizeSpell(Utils.UseGem, spellName, 5000)
            spellRequiredMem = true
        end

        if not me.Gem(spellName)() then
            RGMercsLogger.log_debug("\arFailed to memorized %s - moving on...", spellName)
            return false
        end

        Utils.WaitCastReady(spellName, spellRequiredMem and (5 * 60 * 100) or 5000)

        -- wait another little bit.
        mq.delay(500)

        Utils.ActionPrep()

        local cmd = string.format("/casting \"%s\" -maxtries|5 -targetid|%d", spellName, targetId)
        Utils.DoCmd(cmd)
        RGMercsLogger.log_debug("Running: \at'%s'", cmd)

        Utils.WaitCastFinish(target)

        return true
    end

    RGMercsLogger.log_verbose("\arCasting Failed: Invalid Spell Name")
    return false
end

---@param caller self               # caller object to pass back into condition checks
---@param entry table               # entry to execute
---@param targetId integer          # target id for this entry
---@param resolvedActionMap table   # map of AbilitySet items to resolved spells and abilities
---@param bAllowMem boolean         # allow memorization of spells if needed.
---@return boolean
function Utils.ExecEntry(caller, entry, targetId, resolvedActionMap, bAllowMem)
    local me = mq.TLO.Me
    local ret = false

    if entry.type == nil then return false end -- bad data.

    -- Run pre-activates
    if entry.pre_activate then
        RGMercsLogger.log_debug("Running Pre-Activate for %s", entry.name)
        entry.pre_activate(caller, Utils.GetEntryConditionArg(resolvedActionMap, entry))
    end

    if entry.type:lower() == "item" then
        local itemName = resolvedActionMap[entry.name]

        if not itemName then itemName = entry.name end

        Utils.UseItem(itemName, targetId)
        ret = true
    end

    -- different from items in that they are configured by the user instead of the class.
    if entry.type:lower() == "clickyitem" then
        local itemName = caller.settings[entry.name]

        if not itemName or itemName:len() == 0 then
            ret = false
            RGMercsLogger.log_debug("Unable to find item: %s", itemName)
        else
            Utils.UseItem(itemName, targetId)
            ret = true
        end
    end

    if entry.type:lower() == "spell" then
        local spell = resolvedActionMap[entry.name]

        if not spell or not spell() then
            ret = false
        else
            ret = Utils.UseSpell(spell.RankName(), targetId, bAllowMem)

            RGMercsLogger.log_debug("Trying To Cast %s - %s :: %s", entry.name, spell.RankName(), ret and "\agSuccess" or "\arFailed!")
        end
    end

    if entry.type:lower() == "aa" then
        if Utils.AAReady(entry.name) then
            Utils.UseAA(entry.name, targetId)
            ret = true
        else
            ret = false
        end
    end

    if entry.type:lower() == "ability" then
        if Utils.AbilityReady(entry.name) then
            Utils.UseAbility(entry.name)
            ret = true
        else
            ret = false
        end
    end

    if entry.type:lower() == "customfunc" then
        if entry.custom_func then
            ret = entry.custom_func(caller)
        else
            ret = false
        end
        --RGMercsLogger.log_verbose("Calling command \ao =>> \ag %s \ao <<= Ret => %s", entry.name, Utils.BoolToString(ret))
    end

    if entry.type:lower() == "disc" then
        local discSpell = resolvedActionMap[entry.name]
        if not discSpell then
            RGMercsLogger.log_debug("Dont have a Disc for \ao =>> \ag %s \ao <<=", entry.name)
            ret = false
        else
            RGMercsLogger.log_debug("Using Disc \ao =>> \ag %s [%s] \ao <<=", entry.name, (discSpell() and discSpell.RankName() or "None"))
            ret = Utils.UseDisc(discSpell, targetId)
        end
    end

    if entry.post_activate then
        RGMercsLogger.log_debug("Running Post-Activate for %s", entry.name)
        entry.post_activate(caller, Utils.GetEntryConditionArg(resolvedActionMap, entry), ret)
    end

    return ret
end

function Utils.GetEntryConditionArg(map, entry)
    local condArg = map[entry.name] or mq.TLO.Spell(entry.name)
    if entry.type:lower() ~= "spell" and (condArg == nil or entry.type:lower() == "aa") then
        condArg = entry.name
    end

    return condArg
end

---@param caller self #caller's self object to pass back into class config conditions
---@param rotationTable table #rotation table to run through
---@param targetId integer # target to cast on
---@param resolvedActionMap table #mapping of the class AbilitySet names to what spell or ability they resolved to
---@param steps integer|nil # number of success steps before we yeild back control - if nil we will run the whole rotation
---@param start_step integer|nil # setp to start on
---@param bAllowMem boolean # allow memorization of spells
---@return integer
function Utils.RunRotation(caller, rotationTable, targetId, resolvedActionMap, steps, start_step, bAllowMem)
    local oldSpellInSlot = mq.TLO.Me.Gem(Utils.UseGem)
    local stepsThisTime  = 0
    local lastStepIdx    = 0

    for idx, entry in ipairs(rotationTable) do
        if idx >= start_step then
            RGMercsLogger.log_verbose("\aoDoing RunRotation(start(%d), step(%d), cur(%d))", start_step, steps, idx)
            lastStepIdx = idx
            if entry.cond then
                local condArg = Utils.GetEntryConditionArg(resolvedActionMap, entry)
                local condTarg = mq.TLO.Spawn(targetId)
                local pass = entry.cond(caller, condArg, condTarg)
                RGMercsLogger.log_verbose("\ay   :: Testing Codition for entry(%s) type(%s) cond(s, %s, %s) ==> \ao%s", entry.name, entry.type, condArg,
                    condTarg.CleanName() or "None", Utils.BoolToString(pass))
                if pass == true then
                    local res = Utils.ExecEntry(caller, entry, targetId, resolvedActionMap, bAllowMem)
                    if res == true then
                        stepsThisTime = stepsThisTime + 1

                        if steps > 0 and stepsThisTime >= steps then
                            break
                        end
                    end
                end
            else
                local res = Utils.ExecEntry(caller, entry, targetId, resolvedActionMap, bAllowMem)
                if res == true then
                    stepsThisTime = stepsThisTime + 1

                    if steps > 0 and stepsThisTime >= steps then
                        break
                    end
                end
            end
        end
    end

    if oldSpellInSlot() and mq.TLO.Me.Gem(Utils.UseGem)() ~= oldSpellInSlot.Name() then
        RGMercsLogger.log_debug("\ayRestoring %s in slot %d", oldSpellInSlot, Utils.UseGem)
        Utils.MemorizeSpell(Utils.UseGem, oldSpellInSlot.Name(), 10000)
    end

    -- Move to the next step
    lastStepIdx = lastStepIdx + 1

    if lastStepIdx > #rotationTable then
        lastStepIdx = 1
    end

    RGMercsLogger.log_verbose("Ended RunRotation(step(%d), start_step(%d), next(%d))", steps, (start_step or -1), lastStepIdx)

    return lastStepIdx
end

---@param spell MQSpell
---@return boolean
function Utils.SelfBuffPetCheck(spell)
    if not spell or not spell() then return false end
    return (not mq.TLO.Me.PetBuff(spell.RankName())()) and spell.StacksPet() and mq.TLO.Me.Pet.ID() > 0
end

---@param spell MQSpell
---@return boolean
function Utils.SelfBuffCheck(spell)
    if type(spell) == "string" then return Utils.BuffActiveByName(spell) end
    if not spell or not spell() then return false end
    local res = not Utils.BuffActiveByID(spell.ID()) and spell.Stacks()
    return res
end

---@param b boolean
---@return string
function Utils.BoolToString(b)
    return b and "TRUE" or "FALSE"
end

---@param aaName string
---@return boolean
function Utils.SelfBuffAACheck(aaName)
    local abilityReady = mq.TLO.Me.AltAbilityReady(aaName)()
    local buffNotActive = not Utils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.ID())
    local triggerNotActive = not Utils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())
    local auraNotActive = not mq.TLO.Me.Aura(tostring(mq.TLO.Spell(aaName).RankName())).ID()
    local stacks = mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName).Spell.RankName()).Stacks()
    local triggerStacks = (not mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID() or mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).Stacks())

    --RGMercsLogger.log_verbose("SelfBuffAACheck(%s) abilityReady(%s) buffNotActive(%s) triggerNotActive(%s) auraNotActive(%s) stacks(%s) triggerStacks(%s)", aaName,
    --    Utils.BoolToString(abilityReady),
    --    Utils.BoolToString(buffNotActive),
    --    Utils.BoolToString(triggerNotActive),
    --    Utils.BoolToString(auraNotActive),
    --    Utils.BoolToString(stacks), Utils.BoolToString(triggerStacks))

    return abilityReady and buffNotActive and triggerNotActive and auraNotActive and stacks and triggerStacks
end

---@return string
function Utils.GetLastCastResultName()
    return RGMercConfig.Constants.CastResultsIdToName[RGMercConfig.Globals.CastResult]
end

---@return number
function Utils.GetLastCastResultId()
    return RGMercConfig.Globals.CastResult
end

---@param result number
function Utils.SetLastCastResult(result)
    RGMercsLogger.log_debug("\awSet Last Cast Result => \ag%s", RGMercConfig.Constants.CastResultsIdToName[result])
    RGMercConfig.Globals.CastResult = result
end

---@param hpStopDots number # when to stop dots.
---@param spell MQSpell
---@return boolean
function Utils.DotSpellCheck(hpStopDots, spell)
    if not spell or not spell() then return false end
    return not Utils.TargetHasBuff(spell) and spell.StacksTarget() and Utils.GetTargetPctHPs() > hpStopDots
end

---@param spell MQSpell
---@return boolean
function Utils.DetSpellCheck(spell)
    if not spell or not spell() then return false end
    return not Utils.TargetHasBuff(spell) and spell.StacksTarget()
end

---@param spell MQSpell
---@return boolean
function Utils.TargetHasBuff(spell)
    if not spell or not spell() then return false end
    return (mq.TLO.Target() and (mq.TLO.Target.FindBuff("id " .. tostring(spell.ID())).ID() or 0) > 0) and true or false
end

---@param buffName string
---@return boolean
function Utils.TargetHasBuffByName(buffName)
    if buffName == nil then return false end
    return (mq.TLO.Target() and (mq.TLO.Target.FindBuff("name " .. buffName).ID() or 0) > 0) and true or false
end

---@return integer
function Utils.GetTargetLevel()
    return (mq.TLO.Target.Level() or 0)
end

---@return integer
function Utils.GetTargetDistance()
    return (mq.TLO.Target.Distance() or 9999)
end

---@return integer
function Utils.GetTargetPctHPs()
    return (mq.TLO.Target.PctHPs() or 0)
end

---@return string
function Utils.GetTargetName()
    return (mq.TLO.Target.Name() or "")
end

---@return integer
function Utils.GetTargetID()
    return (mq.TLO.Target.ID() or 0)
end

---@return integer
function Utils.GetTargetAggroPct()
    return (mq.TLO.Target.PctAggro() or 0)
end

---@return boolean
function Utils.GetTargetAggressive()
    return (mq.TLO.Target.Aggressive() or false)
end

---@return integer
function Utils.GetGroupMainAssistID()
    return (mq.TLO.Group.MainAssist.ID() or 0)
end

---@return string
function Utils.GetGroupMainAssistName()
    return (mq.TLO.Group.MainAssist.CleanName() or "")
end

---@param mode string
---@return boolean
function Utils.IsModeActive(mode)
    return RGMercModules:ExecModule("Class", "IsModeActive", mode)
end

---@return boolean
function Utils.IsTanking()
    return RGMercModules:ExecModule("Class", "IsTanking")
end

---@return boolean
function Utils.IsHealing()
    return RGMercModules:ExecModule("Class", "IsHealing")
end

---@return boolean
function Utils.IsCuring()
    return RGMercModules:ExecModule("Class", "IsCuring")
end

---@return boolean
function Utils.IsMezzing()
    return RGMercModules:ExecModule("Class", "IsMezzing")
end

---@return boolean
function Utils.BurnCheck()
    local settings = RGMercConfig:GetSettings()
    local autoBurn = settings.BurnAuto and ((Utils.GetXTHaterCount() >= settings.BurnMobCount) or (Utils.IsNamed(mq.TLO.Target) and settings.BurnNamed))
    local alwaysBurn = (settings.BurnAlways and settings.BurnAuto)

    return autoBurn or alwaysBurn
end

---@return boolean
function Utils.SmallBurn()
    return RGMercConfig:GetSettings().BurnSize >= 1
end

---@return boolean
function Utils.MedBurn()
    return RGMercConfig:GetSettings().BurnSize >= 2
end

---@return boolean
function Utils.BigBurn()
    return RGMercConfig:GetSettings().BurnSize >= 3
end

---@param config table
---@param targetId integer
function Utils.DoStick(config, targetId)
    if os.clock() - Utils.LastDoStick < 4 then
        RGMercsLogger.log_debug("\ayIgnoring DoStick because we just stuck less than 4 seconds ago - let's give it some time.")
        return
    end

    Utils.LastDoStick = os.clock()

    if config.StickHow:len() > 0 then
        Utils.DoCmd("/stick %s", config.StickHow)
    else
        if Utils.IAmMA() then
            Utils.DoCmd("/stick 20 id %d %s uw", targetId, RGMercConfig:GetSettings().MovebackWhenTank and "moveback" or "")
        else
            Utils.DoCmd("/stick 20 id %d behindonce moveback uw", targetId)
        end
    end
end

function Utils.DoCmd(cmd, ...)
    local formatted = cmd
    if ... ~= nil then formatted = string.format(cmd, ...) end
    RGMercsLogger.log_debug("\atRGMercs \awsent MQ \amCommand\aw: >> \ag%s\aw <<", formatted)
    mq.cmdf(formatted)
end

---@param config table
---@param targetId integer
---@param distance integer
---@param bDontStick boolean
function Utils.NavInCombat(config, targetId, distance, bDontStick)
    if not config.DoAutoEngage then return end

    if mq.TLO.Stick.Active() then
        Utils.DoCmd("/stick off")
    end

    if mq.TLO.Navigation.PathExists("id " .. tostring(targetId) .. " distance " .. tostring(distance))() then
        Utils.DoCmd("/nav id %d distance=%d log=off lineofsight=on", targetId, distance)
        while mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 do
            mq.delay(100)
        end
    else
        Utils.DoCmd("/moveto id %d uw mdist %d", targetId, distance)
        while mq.TLO.MoveTo.Moving() and not mq.TLO.MoveUtils.Stuck() do
            mq.delay(100)
        end
    end

    if not bDontStick then
        Utils.DoStick(config, targetId)
    end
end

function Utils.GetMainAssistId()
    return mq.TLO.Spawn(string.format("PC =%s", RGMercConfig.Globals.MainAssist)).ID() or 0
end

function Utils.GetMainAssistPctHPs()
    return mq.TLO.Spawn(string.format("PC =%s", RGMercConfig.Globals.MainAssist)).PctHPs() or 0
end

function Utils.GetMainAssistSpawn()
    return mq.TLO.Spawn(string.format("PC =%s", RGMercConfig.Globals.MainAssist))
end

function Utils.GetAutoTarget()
    return mq.TLO.Spawn(string.format("id %d", RGMercConfig.Globals.AutoTargetID))
end

---@return boolean
function Utils.ShouldShrink()
    return RGMercConfig:GetSettings().DoShrink and mq.TLO.Me.Height() > 2 and RGMercConfig:GetSettings().ShrinkItem:len() > 0
end

---@return boolean
function Utils.ShouldMount()
    if RGMercConfig:GetSettings().DoMount == 0 then return false end

    local passBasicChecks = not RGMercConfig:GetSettings().DoMelee and RGMercConfig:GetSettings().MountItem:len() > 0 and mq.TLO.Zone.Outdoor()

    local passCheckMountOne = ((RGMercConfig:GetSettings().DoMount == 1 and (mq.TLO.Me.Mount.ID() or 0) == 0))
    local passCheckMountTwo = ((RGMercConfig:GetSettings().DoMount == 2 and (mq.TLO.Me.Buff("Mount Blessing").ID() or 0) == 0))
    local passMountItemGivesBlessing = true

    if passCheckMountTwo then
        local mountItem = mq.TLO.FindItem(RGMercConfig:GetSettings().MountItem)
        if mountItem and mountItem() then
            passMountItemGivesBlessing = mountItem.Blessing() ~= nil
        end
    end

    return passBasicChecks and passCheckMountOne or (passCheckMountTwo and passMountItemGivesBlessing)
end

---@return boolean
function Utils.ShouldDismount()
    return RGMercConfig:GetSettings().DoMount ~= 1 and ((mq.TLO.Me.Mount.ID() or 0) > 0)
end

---@return boolean
function Utils.ShouldKillTargetReset()
    local killSpawn = mq.TLO.Spawn(string.format("targetable id %d", RGMercConfig.Globals.AutoTargetID))
    local killCorpse = mq.TLO.Spawn(string.format("corpse id %d", RGMercConfig.Globals.AutoTargetID))
    return (((not killSpawn() or killSpawn.Dead()) or killCorpse()) and RGMercConfig.Globals.AutoTargetID > 0) and true or false
end

function Utils.AutoMed()
    local me = mq.TLO.Me
    if RGMercConfig:GetSettings().DoMed == 1 then return end

    if me.Class.ShortName():lower() == "brd" and me.Level() > 5 then return end

    if me.Mount.ID() and not mq.TLO.Zone.Indoor() then
        RGMercsLogger.log_verbose("Sit check returning early due to mount.")
        return
    end

    RGMercConfig:StoreLastMove()

    --If we're moving/following/navigating/sticking, don't med.
    if me.Casting() or me.Moving() or mq.TLO.Stick.Active() or mq.TLO.Navigation.Active() or mq.TLO.MoveTo.Moving() or mq.TLO.AdvPath.Following() then
        RGMercsLogger.log_verbose("Sit check returning early due to movement.")
        return
    end

    local forcesit   = false
    local forcestand = false

    -- Allow sufficient time for the player to do something before char plunks down. Spreads out med sitting too.
    if RGMercConfig:GetTimeSinceLastMove() < math.random(7, 12) then return end

    if RGMercConfig.Constants.RGHybrid:contains(me.Class.ShortName()) then
        -- Handle the case where we're a Hybrid. We need to check mana and endurance. Needs to be done after
        -- the original stat checks.
        if me.PctHPs() >= RGMercConfig:GetSettings().HPMedPctStop and me.PctMana() >= RGMercConfig:GetSettings().ManaMedPctStop and me.PctEndurance() >= RGMercConfig:GetSettings().EndMedPctStop then
            RGMercConfig.Globals.InMedState = false
            forcestand = true
        end

        if me.PctHPs() < RGMercConfig:GetSettings().HPMedPct or me.PctMana() < RGMercConfig:GetSettings().ManaMedPct or me.PctEndurance() < RGMercConfig:GetSettings().EndMedPct then
            forcesit = true
        end
    elseif RGMercConfig.Constants.RGCasters:contains(me.Class.ShortName()) then
        if me.PctHPs() >= RGMercConfig:GetSettings().HPMedPctStop and me.PctMana() >= RGMercConfig:GetSettings().ManaMedPctStop then
            RGMercConfig.Globals.InMedState = false
            forcestand = true
        end

        if me.PctHPs() < RGMercConfig:GetSettings().HPMedPct or me.PctMana() < RGMercConfig:GetSettings().ManaMedPct then
            forcesit = true
        end
    elseif RGMercConfig.Constants.RGMelee:contains(me.Class.ShortName()) then
        if me.PctHPs() >= RGMercConfig:GetSettings().HPMedPctStop and me.PctEndurance() >= RGMercConfig:GetSettings().EndMedPctStop then
            RGMercConfig.Globals.InMedState = false
            forcestand = true
        end

        if me.PctHPs() < RGMercConfig:GetSettings().HPMedPct or me.PctEndurance() < RGMercConfig:GetSettings().EndMedPct then
            forcesit = true
        end
    else
        RGMercsLogger.log_error("\arYour character class is not in the type list(s): rghybrid, rgcasters, rgmelee. That's a problem for a dev.")
        RGMercConfig.Globals.InMedState = false
        return
    end

    RGMercsLogger.log_verbose(
        "MED MAIN STATS CHECK :: HP %d :: HPMedPct %d :: Mana %d :: ManaMedPct %d :: Endurance %d :: EndPct %d :: forceSit %s :: forceStand %s",
        me.PctHPs(), RGMercConfig:GetSettings().HPMedPct, me.PctMana(),
        RGMercConfig:GetSettings().ManaMedPct, me.PctEndurance(),
        RGMercConfig:GetSettings().EndMedPct, Utils.BoolToString(forcesit), Utils.BoolToString(forcestand))

    if Utils.GetXTHaterCount() > 0 then
        if RGMercConfig:GetSettings().DoMelee then
            forcesit = false
            forcestand = true
        end
        if RGMercConfig:GetSettings().DoMed ~= 3 then
            forcesit = false
            forcestand = true
        end
    end

    if me.Sitting() and forcestand and not Utils.Memorizing then
        RGMercConfig.Globals.InMedState = false
        RGMercsLogger.log_debug("Forcing stand - all conditions met.")
        me.Stand()
        return
    end

    if not me.Sitting() and forcesit then
        RGMercConfig.Globals.InMedState = true
        RGMercsLogger.log_debug("Forcing sit - all conditions met.")
        me.Sit()
    end
end

function Utils.ClickModRod()
    local me = mq.TLO.Me
    if me.PctMana() > RGMercConfig:GetSettings().ModRodManaPct or me.PctHPs() < 60 then return end

    for _, itemName in ipairs(RGMercConfig.Constants.ModRods) do
        local item = mq.TLO.FindItem(itemName)
        if item() and item.Timer() == 0 then
            Utils.DoCmd("/useitem \"%s\"", itemName)
            return
        end
    end
end

---@return boolean
function Utils.DoBuffCheck()
    if not RGMercConfig:GetSettings().DoBuffs then return false end

    if mq.TLO.Me.Invis() then return false end

    if Utils.GetXTHaterCount() > 0 or RGMercConfig.Globals.AutoTargetID > 0 then return false end

    if (mq.TLO.MoveTo.Moving() or mq.TLO.Me.Moving() or mq.TLO.AdvPath.Following() or mq.TLO.Navigation.Active()) and not Utils.MyClassIs("brd") then return false end

    if RGMercConfig.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and mq.TLO.Me.PctMana() < 10 then return false end

    return true
end

---@return boolean
function Utils.UseOrigin()
    if mq.TLO.FindItem("=Drunkard's Stein").ID() or 0 > 0 and mq.TLO.Me.ItemReady("=Drunkard's Stein") then
        RGMercsLogger.log_debug("\ag--\atFound a Drunkard's Stein, using that to get to PoK\ag--")
        Utils.UseItem("Drunkard's Stein", mq.TLO.Me.ID())
        return true
    end

    if Utils.AAReady("Throne of Heroes") then
        RGMercsLogger.log_debug("\ag--\atUsing Throne of Heroes to get to Guild Lobby\ag--")
        RGMercsLogger.log_debug("\ag--\atAs you not within a zone we know\ag--")

        Utils.UseAA("Throne of Heroes", mq.TLO.Me.ID())
        return true
    end

    if Utils.AAReady("Origin") then
        RGMercsLogger.log_debug("\ag--\atUsing Origin to get to Guild Lobby\ag--")
        RGMercsLogger.log_debug("\ag--\atAs you not within a zone we know\ag--")

        Utils.UseAA("Origin", mq.TLO.Me.ID())
        return true
    end

    return false
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function Utils.GetDistance(x1, y1, x2, y2)
    return mq.TLO.Math.Distance(string.format("%d,%d:%d,%d", y1, x1, y2, x2))()
end

---@return boolean
function Utils.DoCamp()
    return Utils.GetXTHaterCount() == 0 and RGMercConfig.Globals.AutoTargetID == 0
end

---@param config table
---@param tempConfig table
function Utils.AutoCampCheck(config, tempConfig)
    if not config.ReturnToCamp then return end

    if mq.TLO.Me.Casting.ID() and not Utils.MyClassIs("brd") then return end

    -- chasing a toon dont use camnp.
    if config.ChaseOn then return end

    -- camped in a different zone.
    if tempConfig.CampZoneId ~= mq.TLO.Zone.ID() then return end

    -- let pulling module handle camp decisions while it is enabled.
    if RGMercConfig.SubModuleSettings.Pull.settings.DoPull then return end

    local me = mq.TLO.Me

    local distanceToCamp = Utils.GetDistance(me.Y(), me.X(), tempConfig.AutoCampY, tempConfig.AutoCampX)

    if distanceToCamp >= 400 then
        Utils.PrintGroupMessage("I'm over 400 units from camp, not returning!")
        Utils.DoCmd("/rgl campoff")
        return
    end

    if distanceToCamp < config.AutoCampRadius then return end

    if distanceToCamp > 5 then
        local navTo = string.format("locyxz %d %d %d", tempConfig.AutoCampY, tempConfig.AutoCampX, tempConfig.AutoCampZ)
        if mq.TLO.Navigation.PathExists(navTo)() then
            Utils.DoCmd("/nav %s", navTo)
            while mq.TLO.Navigation.Active() do
                mq.delay(10)
                mq.doevents()
            end
        else
            Utils.DoCmd("/moveto loc %d %d|on", tempConfig.AutoCampY, tempConfig.AutoCampX)
            while mq.TLO.MoveTo.Moving() do
                mq.delay(10)
                mq.doevents()
            end
        end
    end
end

---@param autoTargetId integer
---@param preEngageRoutine fun()|nil
function Utils.EngageTarget(autoTargetId, preEngageRoutine)
    local config = RGMercConfig:GetSettings()

    if not config.DoAutoEngage then return end

    local target = mq.TLO.Target

    if mq.TLO.Me.State():lower() == "feign" and not Utils.MyClassIs("mnk") then
        mq.TLO.Me.Stand()
    end

    if target() and (target.ID() or 0) == autoTargetId and (mq.TLO.Target.Distance() or 0) <= config.AssistRange then
        if config.DoMelee then
            if mq.TLO.Me.Sitting() then
                mq.TLO.Me.Stand()
            end

            if (Utils.GetTargetPctHPs() <= config.AutoAssistAt or Utils.IAmMA()) and Utils.GetTargetPctHPs() > 0 then
                if target.Distance() > target.MaxRangeTo() then
                    RGMercsLogger.log_debug("Target is too far! %d>%d attempting to nav to it.", target.Distance(), target.MaxRangeTo())
                    if preEngageRoutine then
                        preEngageRoutine()
                    end

                    Utils.NavInCombat(config, autoTargetId, target.MaxRangeTo(), false)
                else
                    Utils.DoCmd("/nav stop log=off")
                    if mq.TLO.Stick.Status():lower() == "off" then
                        Utils.DoStick(config, autoTargetId)
                    end

                    if not mq.TLO.Me.Combat() then
                        RGMercsLogger.log_info("\awNOTICE:\ax Engaging %s in mortal combat.", target.CleanName())
                        Utils.DoCmd("/keypress AUTOPRIM")
                    end
                end
            end
        end
    else
        if not config.DoMelee and RGMercConfig.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and target.Named() and target.Body.Name() == "Dragon" then
            Utils.DoCmd("/stick pin 40")
        end

        -- TODO: why are we doing this after turning stick on just now?
        if mq.TLO.Stick.Status():lower() == "on" then Utils.DoCmd("/stick off") end
    end
end

function Utils.MercAssist()
    mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_CallForAssistButton").LeftMouseUp()
end

---@return boolean
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

    Utils.DoCmd("/dexecute %s /pet leave", problemPetOwner)
end

---@param name string
---@return boolean
function Utils.HaveExpansion(name)
    return mq.TLO.Me.HaveExpansion(RGMercConfig.ExpansionNameToID[name])
end

---@param class string
---@return boolean
function Utils.MyClassIs(class)
    return mq.TLO.Me.Class.ShortName():lower() == class:lower()
end

---@param spawn MQSpawn
---@return boolean
function Utils.IsNamed(spawn)
    if not spawn() then return false end

    ---@diagnostic disable-next-line: undefined-field
    if mq.TLO.Plugin("MQ2SpawnMaster").IsLoaded() and mq.TLO.SpawnMaster.HasSpawn ~= nil then
        ---@diagnostic disable-next-line: undefined-field
        return mq.TLO.SpawnMaster.HasSpawn(spawn.ID() or 0)
    end

    for _, n in ipairs(Utils.NamedList) do
        if spawn.Name() == n or spawn.CleanName() == n then return true end
    end

    return false
end

--- Replaces IsPCSafe
---@param t string: character type
---@param name string
---@return boolean
function Utils.IsSafeName(t, name)
    if mq.TLO.DanNet(name)() then return true end

    for _, n in ipairs(RGMercConfig:GetSettings().OutsideAssistList) do
        if name == n then return true end
    end

    if mq.TLO.Group.Member(name)() then return true end
    if mq.TLO.Raid.Member(name)() then return true end

    if mq.TLO.Spawn(string.format("%s =%s", t, name)).Guild() == mq.TLO.Me.Guild() then return true end

    return false
end

---@param spawn MQSpawn
---@param radius number
---@return boolean
function Utils.IsSpawnFightingStranger(spawn, radius)
    local searchTypes = { "PC", "PCPET", "MERCENARY", }

    for _, t in ipairs(searchTypes) do
        local count = mq.TLO.SpawnCount(string.format("%s radius %d zradius %d", t, radius, radius))()

        for i = 1, count do
            local cur_spawn = mq.TLO.NearestSpawn(i, string.format("%s radius %d zradius %d", t, radius, radius))

            if cur_spawn() then
                if cur_spawn.AssistName():len() > 0 then
                    RGMercsLogger.log_verbose("My Interest: %s =? Their Interest: %s", spawn.Name(), cur_spawn.AssistName())
                    if cur_spawn.AssistName() == spawn.Name() then
                        RGMercsLogger.log_verbose("[%s] Fighting same mob as: %s Theirs: %s Ours: %s", t, cur_spawn.CleanName(), cur_spawn.AssistName(), spawn.Name())
                        local checkName = cur_spawn.CleanName()

                        if cur_spawn.Type():lower() == "mercenary" then checkName = cur_spawn.Owner.CleanName() end
                        if cur_spawn.Type():lower() == "pet" then checkName = cur_spawn.Master.CleanName() end

                        if not Utils.IsSafeName(t, checkName) then
                            RGMercsLogger.log_verbose("\ar WARNING: \ax Almost attacked other PCs [%s] mob. Not attacking \aw%s\ax", cur_spawn.CleanName(), cur_spawn.AssistName())
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

---@return boolean
function Utils.DoCombatActions()
    if not RGMercConfig.Globals.LastMove then return false end
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

        if xtSpawn() and (xtSpawn.ID() or 0) > 0 and xtSpawn.TargetType():lower() == "auto hater" then
            RGMercsLogger.log_verbose("Found %s [%d] Distance: %d", xtSpawn.CleanName(), xtSpawn.ID(), xtSpawn.Distance())
            if (xtSpawn.Distance() or 999) <= radius then
                -- Check for lack of aggro and make sure we get the ones we haven't aggro'd. We can't
                -- get aggro data from the spawn data type.
                if Utils.HaveExpansion("EXPANSION_LEVEL_ROF") then
                    if xtSpawn.PctAggro() < 100 and Utils.IsTanking() then
                        -- Coarse check to determine if a mob is _not_ mezzed. No point in waking a mezzed mob if we don't need to.
                        if RGMercConfig.Constants.RGMezAnims:contains(xtSpawn.Animation()) then
                            RGMercsLogger.log_verbose("Have not fully aggro'd %s -- returning %s [%d]", xtSpawn.CleanName(), xtSpawn.CleanName(), xtSpawn.ID())
                            return xtSpawn.ID() or 0
                        end
                    end
                end

                -- If a name has take priority.
                if Utils.IsNamed(xtSpawn) then
                    RGMercsLogger.log_verbose("Found Named: %s -- returning %d", xtSpawn.CleanName(), xtSpawn.ID())
                    return xtSpawn.ID() or 0
                end

                if (xtSpawn.Body.Name() or "none"):lower() == "Giant" then
                    return xtSpawn.ID() or 0
                end

                if (xtSpawn.PctHPs() or 100) < lowestHP then
                    lowestHP = xtSpawn.PctHPs() or 0
                    killId = xtSpawn.ID() or 0
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

--- This will find a valid target and set it to : RGMercConfig.Globals.AutoTargetID
function Utils.FindTarget()
    RGMercsLogger.log_verbose("FindTarget()")
    if mq.TLO.Spawn(string.format("id %d pcpet xtarhater", mq.TLO.Me.XTarget(1).ID())).ID() > 0 then
        RGMercsLogger.log_verbose("FindTarget() Determined that xtarget(1)=%s is a pcpet xtarhater", mq.TLO.Me.XTarget(1).CleanName())
        Utils.KillPCPet()
    end

    -- Handle cases where our autotarget is no longer valid because it isn't a valid spawn or is dead.
    if RGMercConfig.Globals.AutoTargetID ~= 0 then
        local autoSpawn = mq.TLO.Spawn(string.format("id %d", RGMercConfig.Globals.AutoTargetID))
        if not autoSpawn() or autoSpawn.Type():lower() == "corpse" then
            RGMercsLogger.log_debug("\ayFindTarget() : Clearing Target because it is a corpse or no longer valid.")
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
            local queryCmd = string.format("/dquery %s -q Target.ID", RGMercConfig.Globals.MainAssist)
            mq.cmdf(queryCmd)
            local queryResult = tostring(mq.TLO.DanNet.Q())

            local assistTarget = mq.TLO.Spawn(queryResult)
            if queryResult then
                RGMercsLogger.log_verbose("\ayFindTargetCheck Assist's Target via DanNet :: %s", assistTarget.CleanName() or "None")
            end

            RGMercsLogger.log_verbose("FindTarget Assisting %s -- Target Agressive: %s", RGMercConfig.Globals.MainAssist, Utils.BoolToString(assistTarget.Aggressive()))

            if assistTarget() and assistTarget.Aggressive() and (assistTarget.Type():lower() == "npc" or assistTarget.Type():lower() == "npcpet") then
                RGMercsLogger.log_verbose(" FindTarget Setting Target To %s [%d]", assistTarget.CleanName(), assistTarget.ID())
                RGMercConfig.Globals.AutoTargetID = assistTarget.ID()
            end
        else
            ---@diagnostic disable-next-line: undefined-field
            RGMercConfig.Globals.AutoTargetID = ((mq.TLO.Me.GroupAssistTarget() and mq.TLO.Me.GroupAssistTarget.ID()) or 0)
        end
    end

    if RGMercConfig.Globals.AutoTargetID > 0 and mq.TLO.Target.ID() ~= RGMercConfig.Globals.AutoTargetID then
        Utils.SetTarget(RGMercConfig.Globals.AutoTargetID)
    end
end

function Utils.HandleMezAnnounce(msg)
    if RGMercConfig:GetSettings().MezAnnounce then
        Utils.PrintGroupMessage(msg)
    else
        RGMercsLogger.log_debug(msg)
    end
end

---@return integer
function Utils.GetXTHaterCount()
    local xtCount = mq.TLO.Me.XTarget() or 0
    local haterCount = (Utils.GetTargetAggroPct() > 0 or Utils.GetTargetAggressive()) and 1 or 0

    for i = 1, xtCount do
        local xtarg = mq.TLO.Me.XTarget(i)
        if xtarg and xtarg.Aggressive() and xtarg.ID() ~= Utils.GetTargetID() then
            haterCount = haterCount + 1
        end
    end

    return haterCount
end

---@return table # list of haters.
function Utils.GetXTHaterIDs()
    local xtCount = mq.TLO.Me.XTarget() or 0
    local haters = {}

    for i = 1, xtCount do
        local xtarg = mq.TLO.Me.XTarget(i)
        if xtarg and xtarg.Aggressive() and xtarg.ID() ~= Utils.GetTargetID() then
            table.insert(haters, xtarg.ID())
        end
    end

    return haters
end

---@param t table # Set of haters.
---@return boolean
function Utils.DiffXTHaterIDs(t)
    local xtCount = mq.TLO.Me.XTarget() or 0

    -- count is different things changed.
    if #t ~= xtCount then return true end

    local oldHaterSet = Set.new(t)

    for i = 1, xtCount do
        local xtarg = mq.TLO.Me.XTarget(i)
        if xtarg and xtarg.Aggressive() and xtarg.ID() ~= Utils.GetTargetID() then
            -- this target isn't in the old set.
            if not oldHaterSet:contains(xtarg.ID()) then return true end
        end
    end

    return false
end

---@param spawnId number
---@return boolean
function Utils.IsSpawnXHater(spawnId)
    local xtCount = mq.TLO.Me.XTarget() or 0

    for i = 1, xtCount do
        local xtarg = mq.TLO.Me.XTarget(i)
        if xtarg and xtarg.ID() == spawnId then return true end
    end

    return false
end

function Utils.SetControlToon()
    if RGMercConfig:GetSettings().AssistOutside then
        if #RGMercConfig:GetSettings().OutsideAssistList > 0 then
            for _, name in ipairs(RGMercConfig:GetSettings().OutsideAssistList) do
                local assistSpawn = mq.TLO.Spawn(string.format("PC =%s", name))

                if assistSpawn() and assistSpawn.ID() ~= Utils.GetMainAssistId() then
                    RGMercsLogger.log_info("Setting new assist to %s [%d]", assistSpawn.CleanName(), assistSpawn.ID())
                    --TODO: NOT A VALID BASE CMD Utils.DoCmd("/squelch /xtarget assist %d", assistSpawn.ID())
                    RGMercConfig.Globals.MainAssist = assistSpawn.CleanName()
                end
            end
        else
            if not RGMercConfig.Globals.MainAssist or RGMercConfig.Globals.MainAssist:len() == 0 then
                -- Use our Target hope for the best!
                --TODO: NOT A VALID BASE CMD Utils.DoCmd("/squelch /xtarget assist %d", mq.TLO.Target.ID())
                RGMercConfig.Globals.MainAssist = mq.TLO.Target.CleanName()
            end
        end
    end

    if Utils.GetMainAssistId() ~= Utils.GetGroupMainAssistID() and Utils.GetGroupMainAssistID() > 0 then
        RGMercConfig.Globals.MainAssist = Utils.GetGroupMainAssistName()
    end
end

---@return boolean
function Utils.IAmMA()
    return Utils.GetMainAssistId() == mq.TLO.Me.ID()
end

---@return boolean
function Utils.Feigning()
    return mq.TLO.Me.State():lower() == "feign"
end

---@return boolean
function Utils.IHaveAggro()
    local target = mq.TLO.Target
    local me     = mq.TLO.Me
    return (target() and target.AggroHolder() == me.CleanName()) and true or false
end

---@return boolean
function Utils.FindTargetCheck()
    local config = RGMercConfig:GetSettings()

    RGMercsLogger.log_verbose("FindTargetCheck(%d, %s, %s, %s)", Utils.GetXTHaterCount(), Utils.BoolToString(Utils.IAmMA()), Utils.BoolToString(config.FollowMarkTarget),
        Utils.BoolToString(RGMercConfig.Globals.BackOffFlag))

    local OATarget = false

    -- our MA out of group has a valid target for us.
    if RGMercConfig:GetSettings().AssistOutside then
        local queryCmd = string.format("/dquery %s -q Target.ID", RGMercConfig.Globals.MainAssist)
        mq.cmdf(queryCmd)
        local queryResult = tostring(mq.TLO.DanNet.Q())

        local assistTarget = mq.TLO.Spawn(queryResult)
        if queryResult then
            RGMercsLogger.log_verbose("\ayFindTargetCheck Assist's Target via DanNet :: %s", assistTarget.CleanName() or "None")
        end

        if assistTarget and assistTarget() then
            OATarget = true
        end
    end

    return (Utils.GetXTHaterCount() > 0 or Utils.IAmMA() or config.FollowMarkTarget or OATarget) and not RGMercConfig.Globals.BackOffFlag
end

---@param autoTargetId integer
---@return boolean
function Utils.OkToEngage(autoTargetId)
    local config = RGMercConfig:GetSettings()

    if not config.DoAutoEngage then return false end
    local target = mq.TLO.Target
    local assistId = Utils.GetMainAssistId()

    if not target() then return false end

    local pcCheck = (target.Type() or "none"):lower() == "pc" or
        ((target.Type() or "none"):lower() == "pet" and (target.Master.Type() or "none"):lower() == "pc")
    local mercCheck = target.Type() == "mercenary"
    if pcCheck or mercCheck then
        if not mq.TLO.Me.Combat() then
            RGMercsLogger.log_verbose("\ay[2] Target type check failed \aw[\atpcCheckFailed(%s) mercCheckFailed(%s)\aw]\ay",
                Utils.BoolToString(pcCheck), Utils.BoolToString(mercCheck))
        end
        return false
    end

    if Utils.GetTargetID() ~= autoTargetId then
        RGMercsLogger.log_verbose("%d != %d --> Not Engaging", target.ID() or 0, autoTargetId)
        return false
    end

    if target.Mezzed.ID() and not config.AllowMezBreak then
        RGMercsLogger.log_debug("Target is mezzed and not AllowMezBreak --> Not Engaging")
        return false
    end

    if not RGMercConfig.Globals.BackOffFlag then --Utils.GetXTHaterCount() > 0 and not RGMercConfig.Globals.BackOffFlag then
        local distanceCheck = Utils.GetTargetDistance() < config.AssistRange
        local assistCheck = (Utils.GetTargetPctHPs() <= config.AutoAssistAt or Utils.IsTanking() or Utils.IAmMA())
        if distanceCheck and assistCheck then
            if not mq.TLO.Me.Combat() then
                RGMercsLogger.log_verbose("\ay%d < %d and %d < %d or Tanking or %d == %d --> \agOK To Engage!",
                    target.Distance(), config.AssistRange, Utils.GetTargetPctHPs(), config.AutoAssistAt, assistId, mq.TLO.Me.ID())
            end
            return true
        else
            RGMercsLogger.log_verbose("\ayAssistCheck failed for: %s / %d distanceCheck(%s/%d), assistCheck(%s)",
                target.CleanName(), target.ID(), Utils.BoolToString(distanceCheck), Utils.GetTargetDistance(), Utils.BoolToString(assistCheck))
            return false
        end
    end

    RGMercsLogger.log_verbose("\ayOkay to Engage Failed with Fall Through!",
        Utils.BoolToString(pcCheck), Utils.BoolToString(mercCheck))
    return false
end

function Utils.PetAttack(targetId)
    local pet = mq.TLO.Me.Pet

    local target = mq.TLO.Spawn(targetId)

    if not target() then return end
    if not pet() then return end

    if (not pet.Combat() or pet.Target.ID() ~= target.ID()) and target.Type() == "NPC" then
        Utils.DoCmd("/squelch /pet attack")
        Utils.DoCmd("/squelch /pet swarm")
        RGMercsLogger.log_debug("Pet sent to attack target: %s!", target.Name())
    end
end

---@param spell MQSpell
---@return boolean
function Utils.ReagentCheck(spell)
    if not spell or not spell() then return false end

    if spell.ReagentID(1)() > 0 and mq.TLO.FindItemCount(spell.ReagentID(1)())() == 0 then
        RGMercsLogger.log_verbose("Missing Reagent: (%d)", spell.ReagentID(1)())
        return false
    end

    if spell.NoExpendReagentID(1)() > 0 and mq.TLO.FindItemCount(spell.NoExpendReagentID(1)())() == 0 then
        RGMercsLogger.log_verbose("Missing NoExpendReagent: (%d)", spell.NoExpendReagentID(1)())
        return false
    end

    return true
end

---@param songName string
---@return boolean
function Utils.SongActive(songName)
    if type(songName) ~= "string" then
        RGMercsLogger.log_error("\arUtils.SongActive was passed a non-string songname! %s", type(songName))
        return false
    end
    return ((mq.TLO.Me.Song(songName).ID() or 0) > 0)
end

---@param buffName string
---@return boolean
function Utils.BuffActiveByName(buffName)
    if type(buffName) ~= "string" then
        RGMercsLogger.log_error("\arUtils.BuffActiveByName was passed a non-string buffname! %s", type(buffName))
        return false
    end
    return ((mq.TLO.Me.FindBuff("name " .. buffName).ID() or 0) > 0)
end

---@param buffId integer
---@return boolean
function Utils.BuffActiveByID(buffId)
    return ((mq.TLO.Me.FindBuff("id " .. tostring(buffId)).ID() or 0) > 0)
end

---@param auraName string
---@return boolean
function Utils.AuraActiveByName(auraName)
    local auraOne = string.find(mq.TLO.Me.Aura(1)() or "", auraName) ~= nil
    local auraTwo = string.find(mq.TLO.Me.Aura(2)() or "", auraName) ~= nil

    return auraOne or auraTwo
end

---@param spell MQSpell
---@return boolean
function Utils.DetGOMCheck(spell)
    local me = mq.TLO.Me
    return me.Song("Gift of Mana").ID() and me.Song("Gift of Mana").Base(3)() >= (spell.Level() or 0)
end

---@return boolean
function Utils.DetGambitCheck()
    local me = mq.TLO.Me
    ---@type MQSpell
    local gambitSpell = RGMercModules:ExecModule("Class", "GetResolvedActionMapItem", "GambitSpell")

    return (gambitSpell and gambitSpell() and ((me.Song(gambitSpell.RankName()).ID() or 0) > 0)) and true or false
end

---@param aaId integer
---@return boolean
function Utils.DetAACheck(aaId)
    if Utils.GetTargetID() == 0 then return false end
    local target = mq.TLO.Target
    local me     = mq.TLO.Me

    return (not Utils.TargetHasBuff(me.AltAbility(aaId).Spell) and
            not Utils.TargetHasBuff(me.AltAbility(aaId).Spell.Trigger(1))) and
        (me.AltAbility(aaId).Spell.StacksTarget() or me.AltAbility(aaId).Spell.Trigger(1).StacksTarget())
end

---@param caller self
---@param spellGemList table
---@param itemSets table
---@param abilitySets table
function Utils.SetLoadOut(caller, spellGemList, itemSets, abilitySets)
    local spellLoadOut = {}
    local resolvedActionMap = {}
    local spellsToLoad = {}

    Utils.UseGem = mq.TLO.Me.NumGems()

    -- Map AbilitySet Items and Load Them
    for unresolvedName, itemTable in pairs(itemSets) do
        RGMercsLogger.log_debug("Finding best item for Set: %s", unresolvedName)
        resolvedActionMap[unresolvedName] = Utils.GetBestItem(itemTable)
    end
    for unresolvedName, spellTable in pairs(abilitySets) do
        RGMercsLogger.log_debug("\ayFinding best spell for Set: \am%s", unresolvedName)
        resolvedActionMap[unresolvedName] = Utils.GetBestSpell(spellTable, resolvedActionMap)
    end

    for _, g in ipairs(spellGemList or {}) do
        if not g.cond or g.cond(caller, g.gem) then
            RGMercsLogger.log_debug("\ayGem \am%d\ay will be loaded.", g.gem)

            if g ~= nil and g.spells ~= nil then
                for _, s in ipairs(g.spells) do
                    if s.name_func then s.name = s.name_func(caller) end
                    local spellName = s.name
                    RGMercsLogger.log_debug("\aw  ==> Testing \at%s\aw for Gem \am%d", spellName, g.gem)
                    if abilitySets[spellName] == nil then
                        -- this means we put a varname into our spell table that we didn't define in the ability list.
                        RGMercsLogger.log_error(
                            "\ar ***!!!*** \awLoadout Var [\at%s\aw] has no entry in the AbilitySet list! \arThis is a bug in the class config please report this!",
                            spellName)
                    end
                    local bestSpell = resolvedActionMap[spellName]
                    if bestSpell then
                        local bookSpell = mq.TLO.Me.Book(bestSpell.RankName())()
                        local pass = not s.cond or s.cond(caller, bestSpell)
                        local loadedSpell = spellsToLoad[bestSpell.RankName()] or false

                        if pass and bestSpell and bookSpell and not loadedSpell then
                            RGMercsLogger.log_debug("    ==> \ayGem \am%d\ay will load \at%s\ax ==> \ag%s", g.gem, s.name, bestSpell.RankName())
                            spellLoadOut[g.gem] = { selectedSpellData = s, spell = bestSpell, }
                            spellsToLoad[bestSpell.RankName()] = true
                            break
                        else
                            RGMercsLogger.log_debug("    ==> \ayGem \am%d will \arNOT\ay load \at%s (pass=%s, bestSpell=%s, bookSpell=%d, loadedSpell=%s)", g.gem, s.name,
                                Utils.BoolToString(pass), bestSpell and bestSpell.RankName() or "", bookSpell or -1, Utils.BoolToString(loadedSpell))
                        end
                    else
                        RGMercsLogger.log_debug("    ==> \ayGem \am%d\ay will \arNOT\ay load \at%s\ax ==> \arNo Resolved Spell!", g.gem, s.name)
                    end
                end
            else
                RGMercsLogger.log_debug("    ==> No Resolved Spell! class file not configured properly")
            end
        else
            RGMercsLogger.log_debug("\agGem %d will not be loaded.", g.gem)
        end
    end

    if #spellLoadOut >= mq.TLO.Me.NumGems() then
        RGMercsLogger.log_error("\arYour spell loadout count is the same as your number of gems. This might cause your character to sit and remem often! Consider fixing this!")
    end

    return resolvedActionMap, spellLoadOut
end

---@param loc string
function Utils.NavEnabledLoc(loc)
    ImGui.PushStyleColor(ImGuiCol.Text, 0.690, 0.553, 0.259, 1)
    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.33, 0.33, 0.33, 0.5)
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.0, 0.66, 0.33, 0.5)
    local navLoc = ImGui.Selectable(loc, false, ImGuiSelectableFlags.AllowDoubleClick)
    ImGui.PopStyleColor(3)
    if loc ~= "0,0,0" then
        if navLoc and ImGui.IsMouseDoubleClicked(0) then
            Utils.DoCmd('/nav locYXZ %s', loc)
            printf('\ayNavigating to \ag%s', loc)
        end

        Utils.Tooltip("Double click to Nav")
    end
end

---@param desc string
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

---@param name string
function Utils.AddOA(name)
    table.insert(RGMercConfig:GetSettings().OutsideAssistList, name)
    RGMercConfig:SaveSettings(false)
end

function Utils.DeleteOA(idx)
    if idx <= #RGMercConfig:GetSettings().OutsideAssistList then
        RGMercsLogger.log_info("\axOutside Assist \at%s\ax \ag%s\ax - \arDeleted!\ax", idx, RGMercConfig:GetSettings().OutsideAssistList[idx])
        table.remove(RGMercConfig:GetSettings().OutsideAssistList, idx)
        --RGMercConfig:GetSettings().OutsideAssistList[idx] = nil
        RGMercConfig:SaveSettings(false)
    else
        RGMercsLogger.log_error("\ar%d is not a valid OA ID!", idx)
    end
end

---@param id number
function Utils.MoveOAUp(id)
    local newId = id - 1

    if newId < 1 then return end
    if id > #RGMercConfig:GetSettings().OutsideAssistList then return end

    local oldEntry                                      = RGMercConfig:GetSettings().OutsideAssistList[newId]
    RGMercConfig:GetSettings().OutsideAssistList[newId] = RGMercConfig:GetSettings().OutsideAssistList[id]
    RGMercConfig:GetSettings().OutsideAssistList[id]    = oldEntry
    RGMercConfig:SaveSettings(false)
end

---@param id number
function Utils.MoveOADown(id)
    local newId = id + 1

    if id < 1 then return end
    if newId > #RGMercConfig:GetSettings().OutsideAssistList then return end

    local oldEntry                                      = RGMercConfig:GetSettings().OutsideAssistList[newId]
    RGMercConfig:GetSettings().OutsideAssistList[newId] = RGMercConfig:GetSettings().OutsideAssistList[id]
    RGMercConfig:GetSettings().OutsideAssistList[id]    = oldEntry
    RGMercConfig:SaveSettings(false)
end

function Utils.RenderOAList()
    if mq.TLO.Target.ID() > 0 then
        ImGui.PushID("##_small_btn_create_oa")
        if ImGui.SmallButton("Add Target as OA") then
            Utils.AddOA(mq.TLO.Target.DisplayName())
        end
        ImGui.PopID()
    end
    if ImGui.BeginTable("OAList Nameds", 5, ImGuiTableFlags.None + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)

        ImGui.TableSetupColumn('ID', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 250.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthStretch), 150.0)
        ImGui.TableSetupColumn('Controls', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, name in ipairs(RGMercConfig:GetSettings().OutsideAssistList or {}) do
            local spawn = mq.TLO.Spawn(string.format("PC =%s", name))
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            ImGui.TableNextColumn()
            local _, clicked = ImGui.Selectable(name, false)
            if clicked then
                Utils.DoCmd("/target id %d", spawn() and spawn.ID() or 0)
            end
            ImGui.TableNextColumn()
            if spawn() and spawn.ID() > 0 then
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 1.0)
                ImGui.Text(tostring(math.ceil(spawn.Distance())))
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                Utils.NavEnabledLoc(spawn.LocYXZ() or "0,0,0")
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                ImGui.Text("0")
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                ImGui.Text("0")
            end
            ImGui.TableNextColumn()
            ImGui.PushID("##_small_btn_delete_oa_" .. tostring(idx))
            if ImGui.SmallButton(ICONS.FA_TRASH) then
                Utils.DeleteOA(idx)
            end
            ImGui.PopID()
            ImGui.SameLine()
            ImGui.PushID("##_small_btn_up_oa_" .. tostring(idx))
            if idx == 1 then
                ImGui.InvisibleButton(ICONS.FA_CHEVRON_UP, ImVec2(22, 1))
            else
                if ImGui.SmallButton(ICONS.FA_CHEVRON_UP) then
                    Utils.MoveOAUp(idx)
                end
            end
            ImGui.PopID()
            ImGui.SameLine()
            ImGui.PushID("##_small_btn_dn_oa_" .. tostring(idx))
            if idx == #RGMercConfig:GetSettings().OutsideAssistList then
                ImGui.InvisibleButton(ICONS.FA_CHEVRON_DOWN, ImVec2(22, 1))
            else
                if ImGui.SmallButton(ICONS.FA_CHEVRON_DOWN) then
                    Utils.MoveOADown(idx)
                end
            end
            ImGui.PopID()
        end

        ImGui.EndTable()
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

    Utils.ShowDownNamed, _ = Utils.RenderOptionToggle("ShowDown", "Show Down Nameds", Utils.ShowDownNamed)

    if ImGui.BeginTable("Zone Nameds", 5, ImGuiTableFlags.None + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Index', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 250.0)
        ImGui.TableSetupColumn('Up', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthFixed), 160.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, name in ipairs(Utils.NamedList) do
            local spawn = mq.TLO.Spawn(string.format("NPC =%s", name))
            if Utils.ShowDownNamed or (spawn() and spawn.ID() > 0) then
                ImGui.TableNextColumn()
                ImGui.Text(tostring(idx))
                ImGui.TableNextColumn()
                local _, clicked = ImGui.Selectable(name, false)
                if clicked then
                    Utils.DoCmd("/target id %d", spawn() and spawn.ID() or 0)
                end
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
                ImGui.TableNextColumn()
                Utils.NavEnabledLoc(spawn.LocYXZ() or "0,0,0")
            end
        end

        ImGui.EndTable()
    end
end

---@param iconID integer
---@param spell MQSpell
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

---@param loadoutTable table
function Utils.RenderLoadoutTable(loadoutTable)
    if ImGui.BeginTable("Spells", 5, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Icon', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Gem', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Var Name', (ImGuiTableColumnFlags.WidthFixed), 150.0)
        ImGui.TableSetupColumn('Level', ImGuiTableColumnFlags.None, 20.0)
        ImGui.TableSetupColumn('Rank Name', ImGuiTableColumnFlags.None, 150.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for gem, loadoutData in pairs(loadoutTable) do
            ImGui.TableNextColumn()
            Utils.DrawInspectableSpellIcon(loadoutData.spell.SpellIcon(), loadoutData.spell)
            ImGui.TableNextColumn()
            ImGui.Text(tostring(gem))
            ImGui.TableNextColumn()
            ImGui.Text(loadoutData.selectedSpellData.name or "")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(loadoutData.spell.Level()))
            ImGui.TableNextColumn()
            ImGui.Text(loadoutData.spell.RankName())
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

---@param caller self               # self object of the caller to pass back into coditions
---@param name string               # name of the rotation table
---@param rotationTable table       # rotation Table to render
---@param resolvedActionMap table   # map of AbilitySet items to resolved spells and abilities
---@param rotationState integer     # current state
---@param showFailed boolean        # show items that fail their conitionals
---@return boolean
function Utils.RenderRotationTable(caller, name, rotationTable, resolvedActionMap, rotationState, showFailed)
    if ImGui.BeginTable("Rotation_" .. name, rotationState > 0 and 5 or 4, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('ID', ImGuiTableColumnFlags.WidthFixed, 20.0)
        if rotationState > 0 then
            ImGui.TableSetupColumn('Cur', ImGuiTableColumnFlags.WidthFixed, 20.0)
        end
        ImGui.TableSetupColumn('Condition Met', ImGuiTableColumnFlags.WidthFixed, 20.0)
        ImGui.TableSetupColumn('Action', ImGuiTableColumnFlags.WidthFixed, 250.0)
        ImGui.TableSetupColumn('Resolved Action', ImGuiTableColumnFlags.WidthStretch, 250.0)

        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, entry in ipairs(rotationTable) do
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            if rotationState > 0 then
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
                local condArg  = Utils.GetEntryConditionArg(resolvedActionMap, entry)
                local condTarg = mq.TLO.Target
                local pass     = entry.cond(caller, condArg, condTarg)
                local active   = entry.active_cond and entry.active_cond(caller, condArg) or false

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
            local mappedAction = resolvedActionMap[entry.name]
            if mappedAction then
                if type(mappedAction) == "string" then
                    ImGui.Text(entry.name)
                    ImGui.TableNextColumn()
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.2, 0.6, 1.0, 1.0)
                    ImGui.Text(mappedAction)
                    ImGui.PopStyleColor()
                else
                    ImGui.Text(entry.name)
                    ImGui.TableNextColumn()
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.6, 0.2, 1.0, 1.0)
                    ImGui.Text(mappedAction.RankName() or mappedAction.Name() or "None")
                    ImGui.PopStyleColor()
                end
            else
                ImGui.Text(entry.name)
                ImGui.TableNextColumn()
                if entry.type:lower() == "customfunc" then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.9, 0.9, .05, 1.0)
                    ImGui.Text("<<Custom Func>>")
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "spell" then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.9, 0.05, .05, 0.9)
                    ImGui.Text("<Missing Spell>")
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "ability" then
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.65, .65, 1.0)
                    ImGui.Text(entry.name)
                    ImGui.PopStyleColor()
                elseif entry.type:lower() == "aa" then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.65, 0.65, 1.0, 1.0)
                    ImGui.Text(entry.name)
                    ImGui.PopStyleColor()
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.8, .8, 1.0)
                    ImGui.Text(entry.name)
                    ImGui.PopStyleColor()
                end
            end
        end

        ImGui.EndTable()
    end

    return showFailed
end

---@param id string
---@param text string
---@param on boolean
---@return boolean: state
---@return boolean: changed
function Utils.RenderOptionToggle(id, text, on)
    local toggled = false
    local state   = on
    ImGui.PushID(id .. "_togg_btn")

    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1.0, 1.0, 1.0, 0)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 1.0, 1.0, 0)
    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 1.0, 1.0, 0)

    if on then
        ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 0.9)
        if ImGui.Button(ICONS.FA_TOGGLE_ON) then
            toggled = true
            state   = false
        end
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 0.8)
        if ImGui.Button(ICONS.FA_TOGGLE_OFF) then
            toggled = true
            state   = true
        end
    end
    ImGui.PopStyleColor(4)
    ImGui.PopID()
    ImGui.SameLine()
    ImGui.Text(text)

    return state, toggled
end

---@param id string
---@param text string
---@param cur number
---@param min number
---@param max number
---@param step number?
---@return number   # input
---@return boolean  # changed
function Utils.RenderOptionNumber(id, text, cur, min, max, step)
    ImGui.PushID("##num_spin_" .. id)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.5, 0.5, 0.5, 1.0)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.5, 0.5, 0.5, 0.8)
    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 1.0, 1.0, 0.2)
    ImGui.PushStyleColor(ImGuiCol.FrameBg, 1.0, 1.0, 1.0, 0)
    local input, changed = ImGui.InputInt(text, cur, step)
    ImGui.PopStyleColor(4)
    ImGui.PopID()

    if input > max then input = max end
    if input < min then input = min end


    changed = cur ~= input
    return input, changed
end

---@param settings table
---@param settingNames table
---@param defaults table
---@param category string
---@return table   # settings
---@return boolean # any_pressed
---@return boolean # requires_new_loadout
function Utils.RenderSettingsTable(settings, settingNames, defaults, category)
    local any_pressed = false
    local new_loadout = false
    ---@type boolean|nil
    local pressed = false
    local renderWidth = 300
    local windowWidth = ImGui.GetWindowWidth()
    local numCols = math.max(1, math.floor(windowWidth / renderWidth))

    if ImGui.BeginTable("Options_" .. (category), 2 * numCols, ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        for i = 1, numCols do
            ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthFixed), 150.0)
            ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
        end
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for _, k in ipairs(settingNames) do
            if Utils.ShowAdvancedConfig or (defaults[k].ConfigType == nil or defaults[k].ConfigType:lower() == "normal") then
                if defaults[k].Category == category then
                    if defaults[k].Type == "Combo" then
                        -- build a combo box.
                        ImGui.TableNextColumn()
                        ImGui.Text((defaults[k].DisplayName or "None"))
                        Utils.Tooltip(defaults[k].Tooltip)
                        ImGui.TableNextColumn()
                        ImGui.PushID("##combo_setting_" .. k)
                        settings[k], pressed = ImGui.Combo("", settings[k], defaults[k].ComboOptions)
                        ImGui.PopID()
                        new_loadout = new_loadout or ((pressed or false) and (defaults[k].RequiresLoadoutChange or false))
                        any_pressed = any_pressed or (pressed or false)
                    elseif defaults[k].Type == "ClickyItem" then
                        -- make a drag and drop target
                        ImGui.TableNextColumn()
                        ImGui.Text((defaults[k].DisplayName or "None"))
                        ImGui.TableNextColumn()
                        ImGui.PushID(k .. "__btn")
                        if ImGui.SmallButton(settings[k]:len() > 0 and settings[k] or "[Drop Here]") then
                            if mq.TLO.Cursor() then
                                settings[k] = mq.TLO.Cursor.Name()
                                pressed = true
                            end
                        end
                        ImGui.SameLine()
                        if ImGui.SmallButton(ICONS.MD_CLEAR) then
                            if mq.TLO.Cursor() then
                                settings[k] = ""
                                pressed = true
                            end
                        end
                        Utils.Tooltip(string.format("Drop a new item here to replace\n%s", settings[k]))
                        new_loadout = new_loadout or ((pressed or false) and (defaults[k].RequiresLoadoutChange or false))
                        any_pressed = any_pressed or (pressed or false)
                        ImGui.PopID()
                    elseif defaults[k].Type ~= "Custom" then
                        ImGui.TableNextColumn()
                        ImGui.Text((defaults[k].DisplayName or "None"))
                        Utils.Tooltip(defaults[k].Tooltip)
                        ImGui.TableNextColumn()
                        if type(settings[k]) == 'boolean' then
                            settings[k], pressed = Utils.RenderOptionToggle(k, "", settings[k])
                            new_loadout = new_loadout or (pressed and (defaults[k].RequiresLoadoutChange or false))
                            any_pressed = any_pressed or pressed
                        elseif type(settings[k]) == 'number' then
                            settings[k], pressed = Utils.RenderOptionNumber(k, "", settings[k], defaults[k].Min,
                                defaults[k].Max, defaults[k].Step or 1)
                            new_loadout = new_loadout or (pressed and (defaults[k].RequiresLoadoutChange or false))
                            any_pressed = any_pressed or pressed
                        elseif type(settings[k]) == 'string' then -- display only
                            ImGui.Text(settings[k])
                            Utils.Tooltip(settings[k])
                        end
                    end
                end
            end
        end
        ImGui.EndTable()
    end

    return settings, any_pressed, new_loadout
end

---@param settings table
---@param defaults table
---@param categories table
---@return table: settings
---@return boolean: any_pressed
---@return boolean: requires_new_loadout
function Utils.RenderSettings(settings, defaults, categories)
    local any_pressed = false
    local new_loadout = false

    local settingNames = {}
    for k, _ in pairs(defaults) do
        table.insert(settingNames, k)
    end

    table.sort(settingNames,
        function(k1, k2)
            if defaults[k1].Category == defaults[k2].Category then
                return defaults[k1].DisplayName < defaults[k2].DisplayName
            else
                return defaults[k1].Category <
                    defaults[k2].Category
            end
        end)

    local catNames = categories and categories:toList() or { "", }
    table.sort(catNames)

    Utils.ShowAdvancedConfig, _ = Utils.RenderOptionToggle("show_adv_tog", "Show Advanced Options", Utils.ShowAdvancedConfig)

    if ImGui.BeginTabBar("Settings_Categories") then
        for _, c in ipairs(catNames) do
            local shouldShow = false
            for _, k in ipairs(settingNames) do
                if defaults[k].Category == c then
                    if Utils.ShowAdvancedConfig or (defaults[k].ConfigType == nil or defaults[k].ConfigType:lower() == "normal") then
                        shouldShow = true
                        break
                    end
                end
            end

            if shouldShow then
                if ImGui.BeginTabItem(c) then
                    local cat_pressed = false

                    settings, cat_pressed, new_loadout = Utils.RenderSettingsTable(settings, settingNames, defaults, c)
                    any_pressed = any_pressed or cat_pressed
                    ImGui.EndTabItem()
                end
            end
        end
        ImGui.EndTabBar()
    end

    return settings, any_pressed, new_loadout
end

---@param spellLoadOut table
function Utils.LoadSpellLoadOut(spellLoadOut)
    local selectedRank = ""

    for gem, loadoutData in pairs(spellLoadOut) do
        if mq.TLO.Me.SpellRankCap() > 1 then
            selectedRank = loadoutData.spell.RankName()
        else
            selectedRank = loadoutData.spell.BaseName()
        end

        if mq.TLO.Me.Gem(gem)() ~= selectedRank then
            Utils.MemorizeSpell(gem, selectedRank, 7000)
        end
    end
end

return Utils
