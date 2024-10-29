--- RGMerc Utils Functions.
local mq                       = require('mq')
local Set                      = require('mq.set')
local animSpellGems            = mq.FindTextureAnimation('A_SpellGems')
local ICON_SIZE                = 20

local RGMercUtils              = { _version = '0.2a', _name = "RGMercUtils", _author = 'Derple', }
RGMercUtils.__index            = RGMercUtils
RGMercUtils.Actors             = require('actors')
RGMercUtils.ScriptName         = "RGMercs"
RGMercUtils.LastZoneID         = 0
RGMercUtils.LastDoStick        = 0
RGMercUtils.NamedList          = {}
RGMercUtils.ForceCombat        = false
RGMercUtils.ForceNamed         = false
RGMercUtils.ShowDownNamed      = false
RGMercUtils.ShowAdvancedConfig = false
RGMercUtils.Memorizing         = false
RGMercUtils.ForceBurnTargetID  = 0
-- cached for UI display
RGMercUtils.LastBurnCheck      = false
RGMercUtils.UseGem             = mq.TLO.Me.NumGems()
RGMercUtils.ConfigFilter       = ""
RGMercUtils.SafeTargetCache    = {}

--- Checks if a file exists at the given path.
--- @param path string: The path to the file.
--- @return boolean: True if the file exists, false otherwise.
function RGMercUtils.file_exists(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

--- Copies a file from one path to another.
--- @param from_path string The source file path.
--- @param to_path string The destination file path.
--- @return boolean success True if the file was copied successfully, false otherwise.
function RGMercUtils.copy_file(from_path, to_path)
    if RGMercUtils.file_exists(from_path) then
        local file = io.open(from_path, "r")
        if file ~= nil then
            local content = file:read("*all")
            file:close()
            local fileNew = io.open(to_path, "w")
            if fileNew ~= nil then
                fileNew:write(content)
                fileNew:close()
                return true
            else
                RGMercsLogger.log_error("\arFailed to create new file: %s", to_path)
                return false
            end
        end
    end

    return false
end

--- Scans for updates in the class_configs folder.
function RGMercUtils.ScanConfigDirs()
    RGMercConfig.Globals.ClassConfigDirs = {}

    local classConfigDir = RGMercConfig.Globals.ScriptDir .. "/class_configs"

    for file in LuaFS.dir(classConfigDir) do
        if file ~= "." and file ~= ".." and LuaFS.attributes(classConfigDir .. "/" .. file).mode == "directory" then
            table.insert(RGMercConfig.Globals.ClassConfigDirs, file)
        end
    end

    table.insert(RGMercConfig.Globals.ClassConfigDirs, "Custom")
end

--- Broadcasts an update event to the specified module.
---
--- @param module string The name of the module to broadcast the update to.
--- @param event string The event type to broadcast.
--- @param data table? The data associated with the event.
function RGMercUtils.BroadcastUpdate(module, event, data)
    RGMercUtils.Actors.send({
        from = RGMercConfig.Globals.CurLoadedChar,
        script = RGMercUtils.ScriptName,
        module = module,
        event =
            event,
        data = data,
    })
end

--- Gets the size of a table.
--- @param t table The table whose size is to be determined.
--- @return number The size of the table.
function RGMercUtils.GetTableSize(t)
    local i = 0
    for _, _ in pairs(t) do i = i + 1 end
    return i
end

--- Checks if a table contains a specific value.
--- @param t table The table to search.
--- @param value any The value to search for in the table.
--- @return boolean True if the value is found in the table, false otherwise.
function RGMercUtils.TableContains(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

--- Formats a given time according to the specified format string.
---
--- @param time number The time value to format.
--- @param formatString string? The format string to use for formatting the time.
--- @return string The formatted time as a string.
function RGMercUtils.FormatTime(time, formatString)
    local days = math.floor(time / 86400)
    local hours = math.floor((time % 86400) / 3600)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = math.floor((time % 60))
    return string.format(formatString and formatString or "%d:%02d:%02d:%02d", days, hours, minutes, seconds)
end

function RGMercUtils.gsplit(text, pattern, plain)
    local splitStart, length = 1, #text
    return function()
        if splitStart > 0 then
            local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
            local ret
            if not sepStart then
                ret = string.sub(text, splitStart)
                splitStart = 0
            elseif sepEnd < sepStart then
                -- Empty separator!
                ret = string.sub(text, splitStart, sepStart)
                if sepStart < length then
                    splitStart = sepStart + 1
                else
                    splitStart = 0
                end
            else
                ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ''
                splitStart = sepEnd + 1
            end
            return ret
        end
    end
end

--- Splits a given text into a table of substrings based on a specified pattern.
---
--- @param text string: The text to be split.
--- @param pattern string: The pattern to split the text by.
--- @param plain boolean?: If true, the pattern is treated as a plain string.
--- @return table: A table containing the substrings.
function RGMercUtils.split(text, pattern, plain)
    local ret = {}
    if text ~= nil then
        for match in RGMercUtils.gsplit(text, pattern, plain) do
            table.insert(ret, match)
        end
    end
    return ret
end

--- Prints a group message with the given format and arguments.
--- @param msg string: The message format string.
--- @param ... any: Additional arguments to format the message.
function RGMercUtils.PrintGroupMessage(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    RGMercUtils.DoCmd("/dgt group_%s_%s %s", RGMercConfig.Globals.CurServer, mq.TLO.Group.Leader() or "None", output)
end

--- Resolves the default values for a given settings table.
--- This function takes a table of default values and a table of settings,
--- and ensures that any missing settings are filled in with the default values.
---
--- @param defaults table The table containing default values.
--- @param settings table The table containing user-defined settings.
--- @return table, boolean The settings table with defaults applied where necessary. A bool if the table changed and requires saving.
function RGMercUtils.ResolveDefaults(defaults, settings)
    -- Setup Defaults
    local changed = false
    for k, v in pairs(defaults) do
        if settings[k] == nil then settings[k] = v.Default end

        if type(settings[k]) ~= type(v.Default) then
            RGMercsLogger.log_info("\ayData type of setting [\am%s\ay] has been deprecated -- resetting to default.", k)
            settings[k] = v.Default
            changed = true
        end
    end

    -- Remove Deprecated options
    for k, _ in pairs(settings) do
        if not defaults[k] then
            settings[k] = nil
            RGMercsLogger.log_info("\aySetting [\am%s\ay] has been deprecated -- removing from your config.", k)
            changed = true
        end
    end

    return settings, changed
end

--- Displays a pop-up message with the given text.
--- @param msg string: The message to be displayed in the pop-up.
--- @param ... any: Additional arguments that may be used within the function.
function RGMercUtils.PopUp(msg, ...)
    local output = msg
    if (... ~= nil) then output = string.format(output, ...) end

    RGMercUtils.DoCmd("/popup %s", output)
end

--- Sets the target for the RGMercUtils.
--- @param targetId number The ID of the target to be set.
--- @param ignoreBuffPopulation boolean? Wait to return until buffs are populated Default: false
function RGMercUtils.SetTarget(targetId, ignoreBuffPopulation)
    if targetId == 0 then return end

    if targetId == mq.TLO.Target.ID() then return end
    RGMercsLogger.log_debug("Setting Target: %d", targetId)
    if RGMercUtils.GetSetting('DoAutoTarget') then
        if RGMercUtils.GetTargetID() ~= targetId then
            mq.TLO.Spawn(targetId).DoTarget()
            mq.delay(10, function() return mq.TLO.Target.ID() == targetId end)
            mq.delay(500, function() return ignoreBuffPopulation or mq.TLO.Target.BuffsPopulated() end)
        end
    end
end

--- Clears the current target.
---
--- This function is used to clear any selected target in the game.
function RGMercUtils.ClearTarget()
    RGMercsLogger.log_debug("Clearing Target")
    if RGMercUtils.GetSetting('DoAutoTarget') then
        RGMercConfig.Globals.AutoTargetID = 0
        RGMercConfig.Globals.ForceTargetID = 0
        if mq.TLO.Stick.Status():lower() == "on" then RGMercUtils.DoCmd("/stick off") end
        RGMercUtils.DoCmd("/target clear")
    end
end

--- Handles the death event for RGMercs.
--- This function is triggered when a death event occurs and performs necessary operations.
function RGMercUtils.HandleDeath()
    RGMercsLogger.log_warn("You are sleeping with the fishes.")

    RGMercUtils.ClearTarget()

    RGMercModules:ExecAll("OnDeath")

    while mq.TLO.Me.Hovering() do
        RGMercsLogger.log_debug("Trying to release...")
        if mq.TLO.Window("RespawnWnd").Open() and RGMercUtils.GetSetting('InstantRelease') then
            mq.TLO.Window("RespawnWnd").Child("RW_OptionsList").Select(1)
            mq.delay("1s")
            mq.TLO.Window("RespawnWnd").Child("RW_SelectButton").LeftMouseUp()
        else
            break
        end
    end

    mq.delay("2m", function() return not mq.TLO.Me.Hovering() or (mq.TLO.Zone.ID() ~= RGMercConfig.Globals.CurZoneId) end)

    RGMercsLogger.log_debug("Fishfood no more! Accepted rez or finished zoning post death.")

    -- if we want do do fellowship but we arent in the fellowship zone (rezed)
    if RGMercUtils.GetSetting('DoFellow') and not RGMercModules:ExecModule("Movement", "InCampZone") then
        RGMercsLogger.log_debug("Doing fellowship post death.")
        if mq.TLO.FindItem("Fellowship Registration Insignia").Timer.TotalSeconds() == 0 then
            mq.delay("30s", function() return (mq.TLO.Me.CombatState():lower() == "active") end)
            RGMercUtils.DoCmd("/useitem \"Fellowship Registration Insignia\"")
            mq.delay("2s",
                function() return (mq.TLO.FindItem("Fellowship Registration Insignia").Timer.TotalSeconds() ~= 0) end)
        else
            RGMercsLogger.log_error("\aw Bummer, Insignia on cooldown, you must really suck at this game...")
        end
    end
end

--- Checks the status of plugins.
---
--- This function iterates over the provided table of plugins and performs a check on each one.
---
--- @param t table A table containing plugin information to be checked.
function RGMercUtils.CheckPlugins(t)
    for _, p in pairs(t) do
        if not mq.TLO.Plugin(p)() then
            RGMercUtils.DoCmd("/squelch /plugin %s noauto", p)
            RGMercsLogger.log_info("\aw %s \ar not detected! \aw This macro requires it! Loading ...", p)
        end
    end
end

--- Unchecks the specified plugins.
---
--- This function iterates over the provided table `t` and unchecks each plugin listed.
---
--- @param t table A table containing the plugins to be unchecked.
function RGMercUtils.UnCheckPlugins(t)
    local r = {}
    for _, p in pairs(t) do
        if mq.TLO.Plugin(p)() then
            RGMercUtils.DoCmd("/squelch /plugin %s unload noauto", p)
            RGMercsLogger.log_info("\ar %s detected! \aw Unloading it due to known conflicts with RGMercs!", p)
            table.insert(r, p)
        end
    end

    return r
end

--- Displays a welcome message to the user.
--- This function does not take any parameters.
function RGMercUtils.WelcomeMsg()
    RGMercsLogger.log_info("\aw****************************")
    RGMercsLogger.log_info("\aw\awWelcome to \ag%s", RGMercConfig._name)
    RGMercsLogger.log_info("\aw\awVersion \ag%s \aw(\at%s\aw)", RGMercConfig._version, RGMercConfig._subVersion)
    RGMercsLogger.log_info("\aw\awBy \ag%s", RGMercConfig._author)
    RGMercsLogger.log_info("\aw****************************")
    RGMercsLogger.log_info("\aw use \ag /rg \aw for a list of commands")
    --RGMercsLogger.log_info("\ay*** PLEASE NOTE ***")
    --RGMercsLogger.log_info("\ay*** END NOTE ***")
end

--- Checks if a given Alternate Advancement (AA) ability can be used.
--- @param aaName string The name of the AA ability to check.
--- @return boolean Returns true if the AA ability can be used, false otherwise.
function RGMercUtils.CanUseAA(aaName)
    local haveAbility = mq.TLO.Me.AltAbility(aaName)()
    local levelCheck = haveAbility and mq.TLO.Me.AltAbility(aaName).MinLevel() <= mq.TLO.Me.Level()
    local rankCheck = haveAbility and mq.TLO.Me.AltAbility(aaName).Rank() > 0
    RGMercsLogger.log_super_verbose("CanUseAA(%s): haveAbility(%s) levelCheck(%s) rankCheck(%s)", aaName, RGMercUtils.BoolToColorString(haveAbility),
        RGMercUtils.BoolToColorString(levelCheck), RGMercUtils.BoolToColorString(rankCheck))
    return haveAbility and levelCheck and rankCheck
end

--- Determines if an alliance can be formed.
--- @return boolean True if an alliance can be formed, false otherwise.
function RGMercUtils.CanAlliance()
    return true
end

--- Checks if a specific Alternate Advancement (AA) ability is ready to use.
--- @param aaName string The name of the AA ability to check.
--- @return boolean Returns true if the AA ability is ready, false otherwise.
function RGMercUtils.AAReady(aaName)
    local canUse = RGMercUtils.CanUseAA(aaName)
    local ready = mq.TLO.Me.AltAbilityReady(aaName)()
    RGMercsLogger.log_super_verbose("AAReady(%s): ready(%s) canUse(%s)", aaName, RGMercUtils.BoolToColorString(ready), RGMercUtils.BoolToColorString(canUse))
    return ready and canUse
end

--- Checks if a given ability is ready to be used.
--- @param abilityName string The name of the ability to check.
--- @return boolean True if the ability is ready, false otherwise.
function RGMercUtils.AbilityReady(abilityName)
    return mq.TLO.Me.AbilityReady(abilityName)()
end

--- Retrieves the rank of a specified Alternate Advancement (AA) ability.
--- @param aaName string The name of the AA ability.
--- @return number The rank of the specified AA ability.
function RGMercUtils.AARank(aaName)
    return RGMercUtils.CanUseAA(aaName) and mq.TLO.Me.AltAbility(aaName).Rank() or 0
end

--- Checks if the given name corresponds to a discipline.
---
--- @param name string The name to check.
--- @return boolean True if the name is a discipline, false otherwise.
function RGMercUtils.IsDisc(name)
    local spell = mq.TLO.Spell(name)

    return (spell() and spell.IsSkill() and spell.Duration() and not spell.StacksWithDiscs() and spell.TargetType():lower() == "self") and
        true or false
end

--- Checks if a player character's spell is ready to be cast.
---
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell is ready, false otherwise.
function RGMercUtils.PCSpellReady(spell)
    if not spell or not spell() then return false end
    local me = mq.TLO.Me

    if me.Stunned() then return false end

    return me.CurrentMana() > spell.Mana() and (me.Casting.ID() or 0) == 0 and me.Book(spell.RankName.Name())() ~= nil and
        not (me.Moving() and (spell.MyCastTime() or -1) > 0)
end

--- Checks if a given discipline spell is ready to be used by the player character.
--- @param discSpell MQSpell The name of the discipline spell to check.
--- @return boolean Returns true if the discipline spell is ready, false otherwise.
function RGMercUtils.PCDiscReady(discSpell)
    if not discSpell or not discSpell() then return false end
    RGMercsLogger.log_super_verbose("PCDiscReady(%s) => CAR(%s)", discSpell.RankName.Name() or "None",
        RGMercUtils.BoolToColorString(mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())()))
    return mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())() and mq.TLO.Me.CurrentEndurance() > (discSpell.EnduranceCost() or 0)
end

--- Checks if a given PC discipline spell is ready to be used on the NPC Target.
---
--- @param discSpell MQSpell The name of the discipline spell to check.
--- @return boolean True if the discipline spell is ready, false otherwise.
function RGMercUtils.NPCDiscReady(discSpell)
    if not discSpell or not discSpell() then return false end
    local target = mq.TLO.Target
    if not target or not target() then return false end
    RGMercsLogger.log_super_verbose("NPCDiscReady(%s) => CAR(%s)", discSpell.RankName.Name() or "None",
        RGMercUtils.BoolToColorString(mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())()))
    return mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())() and
        mq.TLO.Me.CurrentEndurance() > (discSpell.EnduranceCost() or 0) and not RGMercUtils.TargetIsType("corpse", target) and
        target.LineOfSight() and not target.Hovering()
end

--- Checks if a particular Alternate Advancement (AA) ability is ready for use.
---
--- @param aaName string The name of the AA ability to check.
--- @return boolean Returns true if the AA ability is ready, false otherwise.
function RGMercUtils.PCAAReady(aaName)
    local spell = mq.TLO.Me.AltAbility(aaName).Spell
    return RGMercUtils.AAReady(aaName) and mq.TLO.Me.CurrentMana() >= (spell.Mana() or 0) or
        mq.TLO.Me.CurrentEndurance() >= (spell.EnduranceCost() or 0)
end

--- Checks if an PC spell is ready to be cast on the target NPC.
---
--- @param spellName string The name of the spell to check.
--- @param targetId number? The ID of the target NPC.
--- @param healingSpell boolean? Indicates if the spell is a healing spell.
--- @return boolean Returns true if the spell is ready, false otherwise.
function RGMercUtils.NPCSpellReady(spellName, targetId, healingSpell)
    local me = mq.TLO.Me
    local spell = mq.TLO.Spell(spellName)

    if (targetId == 0 or not targetId) then targetId = mq.TLO.Target.ID() end

    if not spell or not spell() then return false end

    if me.Stunned() then return false end

    local target = mq.TLO.Spawn(targetId)

    if not target or not target() then return false end

    if me.SpellReady(spell.RankName.Name())() and me.CurrentMana() >= spell.Mana() then
        if not me.Moving() and not me.Casting.ID() and not RGMercUtils.TargetIsType("corpse", target) then
            if target.LineOfSight() then
                return true
            elseif healingSpell then
                return true
            end
        end
    end

    return false
end

--- @param aaName string
--- @param targetId number?
--- @param healingSpell boolean?
--- @return boolean
function RGMercUtils.NPCAAReady(aaName, targetId, healingSpell)
    RGMercsLogger.log_verbose("NPCAAReady(%s)", aaName)
    local me = mq.TLO.Me
    local ability = mq.TLO.Me.AltAbility(aaName)

    if targetId == 0 or not targetId then targetId = mq.TLO.Target.ID() end

    if not ability or not ability() then
        RGMercsLogger.log_verbose("NPCAAReady(%s) - Don't have ability.", aaName)
        return false
    end

    if me.Stunned() then
        RGMercsLogger.log_verbose("NPCAAReady(%s) - Stunned", aaName)
        return false
    end

    local target = mq.TLO.Spawn(string.format("id %d", targetId))

    if not target or not target() or target.Dead() then
        RGMercsLogger.log_verbose("NPCAAReady(%s) - Target Dead", aaName)
        return false
    end

    if RGMercUtils.AAReady(aaName) and me.CurrentMana() >= ability.Spell.Mana() and me.CurrentEndurance() >= ability.Spell.EnduranceCost() then
        if RGMercUtils.MyClassIs("brd") or (not me.Moving() and not me.Casting.ID()) then
            RGMercsLogger.log_verbose("NPCAAReady(%s) - Check LOS", aaName)
            if target.LineOfSight() then
                RGMercsLogger.log_verbose("NPCAAReady(%s) - Success", aaName)
                return true
            elseif healingSpell == true then
                RGMercsLogger.log_verbose("NPCAAReady(%s) - Healing Success", aaName)
                return true
            end
        end
    else
        RGMercsLogger.log_verbose("NPCAAReady(%s) CurrentMana(%d) >= SpellMana(%d) CurrentEnd(%d) >= SpellEnd(%d)", aaName, me.CurrentMana(), ability.Spell.Mana(),
            me.CurrentEndurance(), ability.Spell.EnduranceCost())
    end

    RGMercsLogger.log_verbose("NPCAAReady(%s) - Failed", aaName)
    return false
end

--- Gives a specified item to a target.
--- @param toId number The ID of the target to give the item to.
--- @param itemName string The name of the item to give.
--- @param count number The number of items to give.
function RGMercUtils.GiveTo(toId, itemName, count)
    if toId ~= mq.TLO.Target.ID() then
        RGMercUtils.SetTarget(toId, true)
    end

    if not mq.TLO.Target() then
        RGMercsLogger.log_error("\arGiveTo but unable to target %d!", toId)
        return
    end

    if mq.TLO.Target.Distance() >= 25 then
        RGMercsLogger.log_debug("\arGiveTo but Target is too far away - moving closer!")
        RGMercUtils.DoCmd("/nav id %d |log=off dist=10")

        mq.delay("10s", function() return mq.TLO.Navigation.Active() end)
    end

    while not mq.TLO.Cursor.ID() do
        RGMercUtils.DoCmd("/shift /itemnotify \"%s\" leftmouseup", itemName)
        mq.delay(20, function() return mq.TLO.Cursor.ID() ~= nil end)
    end

    while mq.TLO.Cursor.ID() do
        RGMercUtils.DoCmd("/nomodkey /click left target")
        mq.delay(20, function() return mq.TLO.Cursor.ID() == nil end)
    end

    -- Click OK on trade window and wait for it to go away
    if RGMercUtils.TargetIsType("pc") then
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
    if RGMercUtils.TargetIsType("pet") then
        mq.delay("2s")
        if (mq.TLO.Cursor.ID() or 0) > 0 and mq.TLO.Cursor.NoRent() then
            RGMercsLogger.log_debug("\arGiveTo Pet return item - that ingreat!")
            RGMercUtils.DoCmd("/destroy")
            mq.delay("10s", function() return mq.TLO.Cursor.ID() == nil end)
        end
    end
end

--- Get the best item from a given table.
---
--- This function evaluates the items in the provided table and returns the best item based on predefined criteria.
---
--- @param t table The table containing items to evaluate.
--- @return any The best item from the table.
function RGMercUtils.GetBestItem(t)
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

--- Finds missing spells from a given spell list.
---
--- @param varName string: The name of the variable to check for missing spells.
--- @param spellList table: A table containing the list of spells to check.
--- @param alreadyMissingSpells table: A table to store spells that are already missing.
--- @param highestOnly boolean: A flag indicating whether to only consider the highest level spells.
--- @return table: A table containing the missing spells.
function RGMercUtils.FindMissingSpells(varName, spellList, alreadyMissingSpells, highestOnly)
    local tmpTable = {}
    for _, spellName in ipairs(spellList or {}) do
        local spell = mq.TLO.Spell(spellName)
        if spell() ~= nil then
            --RGMercsLogger.log_debug("Found %s level(%d) rank(%s)", s, spell.Level(), spell.RankName())
            if spell.Level() <= mq.TLO.Me.Level() then
                if not mq.TLO.Me.Book(spell.RankName.Name())() and not mq.TLO.Me.CombatAbility(spell.RankName.Name())() then
                    table.insert(tmpTable, { selectedSpellData = { name = varName, }, missing = true, spell = spell, })
                else
                    table.insert(tmpTable, { selectedSpellData = { name = varName, }, missing = false, spell = spell, })
                end
            end
        end -- end if spell nil check
    end

    if #tmpTable > 0 then
        if not highestOnly then
            for _, data in ipairs(tmpTable) do
                RGMercsLogger.log_debug("Set[%s] : Spell[%s (%d)] : Have[%s]", data.selectedSpellData.name, data.spell.RankName(), data.spell.Level(),
                    RGMercUtils.BoolToColorString(not data.missing))
                if data.missing then
                    table.insert(alreadyMissingSpells, data)
                end
            end
        else
            table.sort(tmpTable, function(a, b) return a.spell.Level() > b.spell.Level() end)
            for _, data in ipairs(tmpTable) do
                RGMercsLogger.log_debug("Set[%s] : Spell[%s (%d)]: Have[%s]", data.selectedSpellData.name, data.spell.RankName(), data.spell.Level(),
                    RGMercUtils.BoolToColorString(not data.missing))
            end
            if tmpTable[1].missing then
                table.insert(alreadyMissingSpells, tmpTable[1])
            end
        end
    end

    return alreadyMissingSpells
end

--- Get the best spell from a list of spells.
---
--- This function iterates through a list of spells and determines the best spell based on certain criteria.
---
--- @param spellList table A list of spells to evaluate.
--- @param alreadyResolvedMap table A map of spells that have already been resolved.
--- @return MQSpell|nil The best spell from the list.
function RGMercUtils.GetBestSpell(spellList, alreadyResolvedMap)
    local highestLevel = 0
    local selectedSpell = nil

    for _, spellName in ipairs(spellList or {}) do
        local spell = mq.TLO.Spell(spellName)
        if spell() ~= nil then
            --RGMercsLogger.log_debug("Found %s level(%d) rank(%s)", s, spell.Level(), spell.RankName())
            if spell.Level() <= mq.TLO.Me.Level() then
                if mq.TLO.Me.Book(spell.RankName.Name())() or mq.TLO.Me.CombatAbility(spell.RankName.Name())() then
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
                    -- else         --temporarily removed, extreme spam, can possibly readd with Highest Only support so did not refactor
                    --     RGMercUtils.PrintGroupMessage(string.format(
                    --         "%s \aw [%s] \ax \ar ! MISSING SPELL ! \ax -- \ag %s \ax -- \aw LVL: %d \ax",
                    --         mq.TLO.Me.CleanName(), spellName,
                    --         spell.RankName.Name(), spell.Level()))
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

--- Waits for the casting to finish on the specified target.
---
--- @param target MQSpawn The target to wait for the casting to finish.
--- @param bAllowDead boolean Whether to allow the target to be dead.
function RGMercUtils.WaitCastFinish(target, bAllowDead) --I am not vested in the math below, I simply converted the existing entry from sec to ms
    local maxWaitOrig = ((mq.TLO.Me.Casting.MyCastTime() or 0) + ((mq.TLO.EverQuest.Ping() * 20) + 1000))
    local maxWait = maxWaitOrig

    while mq.TLO.Me.Casting() do
        RGMercsLogger.log_verbose("Waiting to Finish Casting...")
        mq.delay(10)
        if target() and RGMercUtils.GetTargetPctHPs(target) <= 0 and not bAllowDead then
            mq.TLO.Me.StopCast()
            RGMercsLogger.log_debug("WaitCastFinish(): Canceled casting because spellTarget(%d) is dead with no HP(%d)", target.ID(),
                RGMercUtils.GetTargetPctHPs(target))
            return
        end

        if target() and RGMercUtils.GetTargetID() > 0 and target.ID() ~= RGMercUtils.GetTargetID() then
            mq.TLO.Me.StopCast()
            RGMercsLogger.log_debug("WaitCastFinish(): Canceled casting because spellTarget(%s/%d) is no longer myTarget(%s/%d)", target.CleanName() or "", target.ID(),
                RGMercUtils.GetTargetCleanName(), RGMercUtils.GetTargetID())
            return
        end

        if target() and target.ID() ~= RGMercUtils.GetTargetID() then
            RGMercsLogger.log_debug("WaitCastFinish(): Warning your spellTarget(%d) is no longer your currentTarget(%d)", target.ID(), RGMercUtils.GetTargetID())
        end

        maxWait = maxWait - 10

        if maxWait <= 0 then
            local msg = string.format("StuckGem Data::: %d - MaxWait - %d - Casting Window: %s - Assist Target ID: %d",
                (mq.TLO.Me.Casting.ID() or -1), maxWaitOrig,
                RGMercUtils.BoolToColorString(mq.TLO.Window("CastingWindow").Open()), RGMercConfig.Globals.AutoTargetID)

            RGMercsLogger.log_debug(msg)
            RGMercUtils.PrintGroupMessage(msg)

            --RGMercUtils.DoCmd("/alt act 511")
            mq.TLO.Me.StopCast()
            return
        end

        mq.doevents()
    end
end

--- Checks the mana level of the character.
--- This function evaluates the current mana level and performs necessary actions based on the result.
--- @return boolean True if you have more mana than Mana To Nuke false otherwise
function RGMercUtils.ManaCheck()
    return mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToNuke')
end

--- Checks the mana status for the character.
--- This function evaluates the current mana level and determines if it meets the required threshold.
--- @return boolean True if the mana level is sufficient, false otherwise.
function RGMercUtils.DotManaCheck()
    return mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToDot')
end

--- Memorizes a spell in the specified gem slot.
--- @param gem number The gem slot number where the spell should be memorized.
--- @param spell string The name of the spell to memorize.
--- @param waitSpellReady boolean Whether to wait until the spell is ready to be memorized.
--- @param maxWait number The maximum time to wait for the spell to be ready, in seconds.
function RGMercUtils.MemorizeSpell(gem, spell, waitSpellReady, maxWait)
    RGMercsLogger.log_info("\ag Meming \aw %s in \ag slot %d", spell, gem)
    RGMercUtils.DoCmd("/memspell %d \"%s\"", gem, spell)

    RGMercUtils.Memorizing = true

    while (mq.TLO.Me.Gem(gem)() ~= spell or (waitSpellReady and not mq.TLO.Me.SpellReady(gem)())) and maxWait > 0 do
        RGMercsLogger.log_debug("\ayWaiting for '%s' to load in slot %d'...", spell, gem)
        if mq.TLO.Me.CombatState():lower() == "combat" then
            RGMercsLogger.log_verbose("MemorizeSpell() I was interrupted by combat while waiting for spell '%s' to load in slot %d'! Aborting.", spell, gem)
            break
        end
        mq.delay(100)
        maxWait = maxWait - 100
    end

    RGMercUtils.Memorizing = false
end

--- Checks if a spell is ready to be cast.
---
--- @param spell string The name of the spell to check.
--- @return boolean Returns true if the spell is ready to be cast, false otherwise.
function RGMercUtils.CastReady(spell)
    return mq.TLO.Me.SpellReady(spell)()
end

--- Waits until the specified spell is ready to be cast or the maximum wait time is reached.
--- @param spell string The name of the spell to wait for.
--- @param maxWait number The maximum amount of time (in seconds) to wait for the spell to be ready.
function RGMercUtils.WaitCastReady(spell, maxWait)
    while not mq.TLO.Me.SpellReady(spell)() and maxWait > 0 do
        mq.delay(1)
        mq.doevents()
        if RGMercUtils.GetXTHaterCount() > 0 then
            RGMercsLogger.log_debug("I was interruped by combat while waiting to cast %s.", spell)
            return
        end

        maxWait = maxWait - 1

        if (maxWait % 100) == 0 then
            RGMercsLogger.log_verbose("Waiting for spell '%s' to be ready...", spell)
        end
    end

    -- account for lag
    local pingDelay = mq.TLO.EverQuest.Ping() * RGMercUtils.GetSetting('CastReadyDelayFact')
    mq.delay(pingDelay)
end

--- Checks if a spell is loaded.
---
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell is loaded, false otherwise.
function RGMercUtils.SpellLoaded(spell)
    if not spell or not spell() then return false end

    return (mq.TLO.Me.Gem(spell.RankName.Name())() ~= nil)
end

--- Waits for the global cooldown to complete.
---
--- This function pauses execution until the global cooldown period has elapsed.
---
--- @param logPrefix string|nil: An optional prefix to be used in log messages.
function RGMercUtils.WaitGlobalCoolDown(logPrefix)
    while mq.TLO.Me.SpellInCooldown() do
        mq.delay(100)
        mq.doevents()
        RGMercsLogger.log_verbose(logPrefix and logPrefix or "" .. "Waiting for Global Cooldown to be ready...")
    end
end

--- Prepares the necessary actions for the RGMercUtils module.
--- This function is responsible for setting up any prerequisites or initial configurations
--- required before executing the main functionalities of the RGMercUtils module.
--- It ensures that all necessary conditions are met and resources are allocated properly.
function RGMercUtils.ActionPrep()
    if not mq.TLO.Me.Standing() then
        mq.TLO.Me.Stand()
        mq.delay(10, function() return mq.TLO.Me.Standing() end)

        RGMercConfig.Globals.InMedState = false
    end

    if mq.TLO.Window("SpellBookWnd").Open() then
        mq.TLO.Window("SpellBookWnd").DoClose()
    end
end

--- Uses the specified Alternate Advancement (AA) ability on a given target.
--- @param aaName string The name of the AA ability to use.
--- @param targetId number The ID of the target on which to use the AA ability.
--- @return boolean True if the AA ability was successfully used, false otherwise.
function RGMercUtils.UseAA(aaName, targetId)
    local me = mq.TLO.Me
    local oldTargetId = mq.TLO.Target.ID()

    local aaAbility = mq.TLO.Me.AltAbility(aaName)

    if not aaAbility() then
        RGMercsLogger.log_verbose("\arUseAA(): You dont have the AA: %s!", aaName)
        return false
    end

    if not mq.TLO.Me.AltAbilityReady(aaName) then
        RGMercsLogger.log_verbose("\ayUseAA(): Ability %s is not ready!", aaName)
        return false
    end

    if mq.TLO.Window("CastingWindow").Open() or me.Casting.ID() then
        if RGMercUtils.MyClassIs("brd") then
            mq.delay("3s", function() return (not mq.TLO.Window("CastingWindow").Open()) end)
            mq.delay(10)
            RGMercUtils.DoCmd("/stopsong")
        else
            RGMercsLogger.log_debug("\ayUseAA(): CANT CAST AA - Casting Window Open")
            return false
        end
    end

    local target = mq.TLO.Spawn(targetId)

    -- If we're combat casting we need to both have the same swimming status
    if target() and target.FeetWet() ~= me.FeetWet() then
        RGMercsLogger.log_debug("\ayUseAA(): Can't use AA feet wet mismatch!")
        return false
    end

    RGMercUtils.ActionPrep()

    if RGMercUtils.GetTargetID() ~= targetId and target() then
        if me.Combat() and RGMercUtils.TargetIsType("pc", target) then
            RGMercsLogger.log_info("\awUseAA():NOTICE:\ax Turning off autoattack to cast on a PC.")
            RGMercUtils.DoCmd("/attack off")
            mq.delay("2s", function() return not me.Combat() end)
        end

        RGMercsLogger.log_debug("\awUseAA():NOTICE:\ax Swapping target to %s [%d] to use %s", target.DisplayName(), targetId, aaName)
        RGMercUtils.SetTarget(targetId, true)
    end

    local cmd = string.format("/alt act %d", aaAbility.ID())

    RGMercsLogger.log_debug("\ayUseAA():Activating AA: '%s' [t: %dms]", cmd, aaAbility.Spell.MyCastTime())
    RGMercUtils.DoCmd(cmd)

    mq.delay(5)

    if (aaAbility.Spell.MyCastTime() or 0) > 0 then           --Not having the fudge additional delay was causing the same clipping up until around + 3-400ms for me.
        local totaldelay = aaAbility.Spell.MyCastTime() + 600 --Magic Number for now until we can do more solid testing and solicit feedback (this may also be rewritten anyways)
        mq.delay(string.format("%dms", totaldelay))
    end

    if oldTargetId > 0 then
        RGMercsLogger.log_debug("UseAA():switching target back to old target after casting aa")
        RGMercUtils.SetTarget(oldTargetId, true)
    end

    return true
end

--- Uses an item on a specified target.
--- @param itemName string The name of the item to be used.
--- @param targetId number The ID of the target on which the item will be used.
--- @return boolean
function RGMercUtils.UseItem(itemName, targetId)
    local me = mq.TLO.Me

    if mq.TLO.Window("CastingWindow").Open() or me.Casting.ID() then
        if RGMercUtils.MyClassIs("brd") then
            mq.delay("3s", function() return not mq.TLO.Window("CastingWindow").Open() end)
            mq.delay(10)
            RGMercUtils.DoCmd("/stopsong")
        else
            RGMercsLogger.log_debug("\awUseItem(\ag%s\aw): \arCANT Use Item - Casting Window Open", itemName or "None")
            return false
        end
    end

    if not itemName then
        RGMercsLogger.log_debug("\awUseItem(\ag%s\aw): \arGiven item name is nil!")
        return false
    end

    local item = mq.TLO.FindItem("=" .. itemName)

    if not item() then
        RGMercsLogger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but it is not found!", itemName)
        return false
    end

    if RGMercUtils.BuffActiveByID(item.Clicky.SpellID()) then
        RGMercsLogger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but the clicky buff is already active!", itemName)
        return false
    end

    if RGMercUtils.BuffActiveByID(item.Spell.ID()) then
        RGMercsLogger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but the buff is already active!", itemName)
        return false
    end

    if RGMercUtils.SongActive(item.Spell) then
        RGMercsLogger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but the song buff is already active: %s!", itemName, item.Spell.Name())
        return false
    end

    -- validate this wont kill us.
    if item.Spell() and item.Spell.HasSPA(0)() then
        for i = 1, item.Spell.NumEffects() do
            if item.Spell.Attrib(i)() == 0 then
                if mq.TLO.Me.CurrentHPs() + item.Spell.Base(i)() <= 0 then
                    RGMercsLogger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but it would kill me!: %s! HPs: %d SpaHP: %d", itemName, item.Spell.Name(),
                        mq.TLO.Me.CurrentHPs(), item.Spell.Base(i)())
                    return false
                end
            end
        end
    end

    RGMercUtils.ActionPrep()

    if not me.ItemReady(itemName) then
        RGMercsLogger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but it is not ready!", itemName)
        return false
    end

    local oldTargetId = RGMercUtils.GetTargetID()
    RGMercUtils.SetTarget(targetId, true)

    RGMercsLogger.log_debug("\awUseItem(\ag%s\aw): Using Item!", itemName)

    local cmd = string.format("/useitem \"%s\"", itemName)
    RGMercUtils.DoCmd(cmd)
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
        RGMercUtils.DoCmd("/autoinv")
    end

    if oldTargetId > 0 then
        RGMercUtils.SetTarget(oldTargetId, true)
    else
        RGMercUtils.ClearTarget()
    end

    return true
end

--- Retrieves the ID of the item summoned by a given spell.
---
--- @param spell MQSpell The name or identifier of the spell.
--- @return number The ID of the summoned item.
function RGMercUtils.GetSummonedItemIDFromSpell(spell)
    if not spell or not spell() then return 0 end

    for i = 1, spell.NumEffects() do
        -- 32 means SPA_CREATE_ITEM
        if spell.Attrib(i)() == 32 then
            return tonumber(spell.Base(i)()) or 0
        end
    end

    return 0
end

--- Swaps the specified item to the given slot.
---
--- @param slot string The slot number where the item should be placed.
--- @param item string The item to be swapped into the slot.
function RGMercUtils.SwapItemToSlot(slot, item)
    RGMercsLogger.log_verbose("\aySwapping item %s to %s", item, slot)

    local swapItem = mq.TLO.FindItem(item)
    if not swapItem or not swapItem() then return end

    if mq.TLO.InvSlot(slot).Item.Name() == swapItem.Name() then return end

    RGMercsLogger.log_verbose("\ag Found Item! Swapping item %s to %s", item, slot)

    RGMercUtils.DoCmd("/itemnotify \"%s\" leftmouseup", item)
    mq.delay(100, function() return mq.TLO.Cursor.Name() == item end)
    RGMercUtils.DoCmd("/itemnotify %s leftmouseup", slot)
    mq.delay(100, function() return mq.TLO.Cursor.Name() ~= item end)

    while mq.TLO.Cursor.ID() do
        mq.delay(1)
        RGMercUtils.DoCmd("/autoinv")
    end
end

--- Uses the specified ability.
---
--- @param abilityName string The name of the ability to use.
function RGMercUtils.UseAbility(abilityName)
    local me = mq.TLO.Me
    RGMercUtils.DoCmd("/doability %s", abilityName)
    mq.delay(8, function() return not me.AbilityReady(abilityName) end)
    RGMercsLogger.log_debug("Using Ability \ao =>> \ag %s \ao <<=", abilityName)
end

--- Uses a discipline spell on a specified target.
---
--- @param discSpell MQSpell The name of the discipline spell to use.
--- @param targetId number The ID of the target on which to use the discipline spell.
--- @return boolean True if we were able to fire the Disc false otherwise.
function RGMercUtils.UseDisc(discSpell, targetId)
    local me = mq.TLO.Me

    if not discSpell or not discSpell() then return false end

    if mq.TLO.Window("CastingWindow").Open() or me.Casting.ID() then
        RGMercsLogger.log_debug("CANT USE Disc - Casting Window Open")
        return false
    else
        if me.CurrentEndurance() < discSpell.EnduranceCost() then
            return false
        else
            RGMercsLogger.log_debug("Trying to use Disc: %s", discSpell.RankName.Name())

            RGMercUtils.ActionPrep()

            if RGMercUtils.IsDisc(discSpell.RankName.Name()) then
                if me.ActiveDisc.ID() then
                    RGMercsLogger.log_debug("Cancelling Disc for %s -- Active Disc: [%s]", discSpell.RankName.Name(),
                        me.ActiveDisc.Name())
                    RGMercUtils.DoCmd("/stopdisc")
                    mq.delay(20, function() return not me.ActiveDisc.ID() end)
                end
            end

            RGMercUtils.DoCmd("/squelch /doability \"%s\"", discSpell.RankName.Name())

            mq.delay(discSpell.MyCastTime() or 1000,
                function() return (not me.CombatAbilityReady(discSpell.RankName.Name())() and not me.Casting.ID()) end)

            -- Is this even needed?
            if RGMercUtils.IsDisc(discSpell.RankName.Name()) then
                mq.delay(20, function() return me.ActiveDisc.ID() end)
            end

            RGMercsLogger.log_debug("\aw Cast >>> \ag %s", discSpell.RankName.Name())

            return true
        end
    end
end

--- Uses a specified song on a target.
---
--- @param songName string The name of the song to be used.
--- @param targetId number The ID of the target on which the song will be used.
--- @param bAllowMem boolean A flag indicating whether memorization is allowed.
--- @param retryCount number? The number of times to retry using the song if it fails.
--- @return boolean True if we were able to sing the song, false otherwise
function RGMercUtils.UseSong(songName, targetId, bAllowMem, retryCount)
    if not songName then return false end
    local me = mq.TLO.Me
    RGMercsLogger.log_debug("\ayUseSong(%s, %d, %s)", songName, targetId, RGMercUtils.BoolToColorString(bAllowMem))

    if songName then
        local spell = mq.TLO.Spell(songName)

        if not spell() then
            RGMercsLogger.log_error("\arSinging Failed: Somehow I tried to cast a spell That doesn't exist: %s",
                songName)
            return false
        end

        -- Check we actually have the song -- Me.Book always needs to use RankName
        if not me.Book(songName)() then
            RGMercsLogger.log_error("\arSinging Failed: Somehow I tried to cast a spell I didn't know: %s", songName)
            return false
        end

        if me.CurrentMana() < spell.Mana() then
            RGMercsLogger.log_verbose("\arSinging Failed: I tried to cast a spell %s I don't have mana for it.",
                songName)
            return false
        end

        if mq.TLO.Cursor.ID() then
            RGMercUtils.DoCmd("/autoinv")
        end

        local targetSpawn = mq.TLO.Spawn(targetId)

        if (RGMercUtils.GetXTHaterCount() > 0 or not bAllowMem) and (not RGMercUtils.CastReady(songName) or not mq.TLO.Me.Gem(songName)()) then
            RGMercsLogger.log_debug("\ayI tried to singing %s but it was not ready and we are in combat - moving on.",
                songName)
            return false
        end

        local spellRequiredMem = false
        if not me.Gem(songName)() then
            RGMercsLogger.log_debug("\ay%s is not memorized - meming!", songName)
            RGMercUtils.MemorizeSpell(RGMercUtils.UseGem, songName, true, 5000)
            spellRequiredMem = true
        end

        if not me.Gem(songName)() then
            RGMercsLogger.log_debug("\arFailed to memorized %s - moving on...", songName)
            return false
        end

        if targetId > 0 and targetId ~= mq.TLO.Me.ID() then
            RGMercUtils.SetTarget(targetId, true)
        end

        RGMercUtils.WaitCastReady(songName, spellRequiredMem and (5 * 60 * 100) or 5000)
        --mq.delay(500)

        RGMercUtils.ActionPrep()

        RGMercsLogger.log_verbose("\ag %s \ar =>> \ay %s \ar <<=", songName, targetSpawn.CleanName() or "None")

        -- Swap Instruments
        local classConfig = RGMercModules:ExecModule("Class", "GetClassConfig")
        if classConfig and classConfig.HelperFunctions and classConfig.HelperFunctions.SwapInst then
            classConfig.HelperFunctions.SwapInst(spell.Skill())
        end

        retryCount = retryCount or 0

        repeat
            if RGMercUtils.OnEMU() then
                -- EMU doesn't seem to tell us we begin singing.
                RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_SUCCESS)
            end
            RGMercUtils.DoCmd("/cast \"%s\"", songName)

            mq.delay("3s", function() return mq.TLO.Window("CastingWindow").Open() end)

            -- while the casting window is open, still do movement if not paused or if movement enabled during pause.
            while mq.TLO.Window("CastingWindow").Open() do
                if not RGMercConfig.Globals.PauseMain or RGMercUtils.GetSetting('RunMovePaused') then
                    RGMercModules:ExecModule("Movement", "GiveTime", "Combat")
                end

                if targetId > 0 and targetId ~= mq.TLO.Me.ID() then
                    if targetSpawn() and RGMercUtils.GetTargetPctHPs(targetSpawn) <= 0 then
                        mq.TLO.Me.StopCast()
                        RGMercsLogger.log_debug("UseSong::WaitSingFinish(): Canceled casting because spellTarget(%d) is dead with no HP(%d)", targetSpawn.ID(),
                            RGMercUtils.GetTargetPctHPs(targetSpawn))
                        break
                    end

                    if targetSpawn() and RGMercUtils.GetTargetID() > 0 and targetSpawn.ID() ~= RGMercUtils.GetTargetID() then
                        mq.TLO.Me.StopCast()
                        RGMercsLogger.log_debug("UseSong::WaitSingFinish(): Canceled casting because spellTarget(%d) is no longer myTarget(%d)", targetSpawn.ID(),
                            RGMercUtils.GetTargetID())
                        break
                    end

                    if targetSpawn() and targetSpawn.ID() ~= RGMercUtils.GetTargetID() then
                        RGMercsLogger.log_debug("UseSong::WaitSingFinish(): Warning your spellTarget(%d) is no longar your currentTarget(%d)", targetSpawn.ID(),
                            RGMercUtils.GetTargetID())
                    end
                end
                mq.doevents()
                mq.delay(1)
            end

            retryCount = retryCount - 1
        until RGMercUtils.GetLastCastResultId() == RGMercConfig.Constants.CastResults.CAST_SUCCESS or
            RGMercUtils.GetLastCastResultId() == RGMercConfig.Constants.CastResults.CAST_TAKEHOLD or
            RGMercUtils.GetLastCastResultId() == RGMercConfig.Constants.CastResults.CAST_RECOVER or
            retryCount < 0

        -- bard songs take a bit to refresh after casting window closes, otherwise we'll clip our song
        local clipDelay = mq.TLO.EverQuest.Ping() * RGMercUtils.GetSetting('SongClipDelayFact')
        mq.delay(clipDelay)

        RGMercUtils.DoCmd("/stopsong")

        if classConfig and classConfig.HelperFunctions and classConfig.HelperFunctions.SwapInst then
            classConfig.HelperFunctions.SwapInst("Weapon")
        end

        return RGMercUtils.GetLastCastResultId() == RGMercConfig.Constants.CastResults.CAST_SUCCESS
    end

    return false
end

--- Uses a specified spell on a target.
---
--- @param spellName string The name of the spell to be used.
--- @param targetId number The ID of the target on which the spell will be cast.
--- @param bAllowMem boolean Whether to allow the spell to be memorized if not already.
--- @param bAllowDead boolean? Whether to allow casting the spell on a dead target.
--- @param overrideWaitForGlobalCooldown boolean? Whether to override the wait for the global cooldown.
--- @param retryCount number? The number of times to retry casting the spell if it fails.
--- @return boolean Returns true if the spell was successfully cast, false otherwise.
function RGMercUtils.UseSpell(spellName, targetId, bAllowMem, bAllowDead, overrideWaitForGlobalCooldown, retryCount)
    local me = mq.TLO.Me
    -- Immediately send bards to the song handler.
    if me.Class.ShortName():lower() == "brd" then
        return RGMercUtils.UseSong(spellName, targetId, bAllowMem)
    end

    RGMercsLogger.log_debug("\ayUseSpell(%s, %d, %s)", spellName, targetId, RGMercUtils.BoolToColorString(bAllowMem))

    if me.Moving() then
        RGMercsLogger.log_debug("\ayUseSpell(%s, %d, %s) -- Failed because I am moving", spellName, targetId,
            RGMercUtils.BoolToColorString(bAllowMem))
        return false
    end

    if mq.TLO.Cursor.ID() then
        RGMercUtils.DoCmd("/autoinv")
    end

    if spellName then
        local spell = mq.TLO.Spell(spellName)

        if not spell() then
            RGMercsLogger.log_error("\ayUseSpell(): \arCasting Failed: Somehow I tried to cast a spell That doesn't exist: %s",
                spellName)
            return false
        end
        -- Check we actually have the spell -- Me.Book always needs to use RankName
        if not me.Book(spellName)() then
            RGMercsLogger.log_error("\ayUseSpell(): \arCasting Failed: Somehow I tried to cast a spell I didn't know: %s", spellName)
            return false
        end

        local targetSpawn = mq.TLO.Spawn(targetId)

        if targetSpawn() and RGMercUtils.TargetIsType("pc", targetSpawn) then
            -- check to see if this is too powerful a spell
            local targetLevel    = targetSpawn.Level()
            local spellLevel     = spell.Level()
            local levelCheckPass = true
            if targetLevel <= 45 and spellLevel > 50 then levelCheckPass = false end
            if targetLevel <= 60 and spellLevel > 65 then levelCheckPass = false end
            if targetLevel <= 65 and spellLevel > 95 then levelCheckPass = false end

            if not levelCheckPass then
                RGMercsLogger.log_error("\ayUseSpell(): \arCasting %s failed level check with target=%d and spell=%d", spellName,
                    targetLevel, spellLevel)
                return false
            end
        end

        -- Check for Reagents
        if not RGMercUtils.ReagentCheck(spell) then
            RGMercsLogger.log_debug("\ayUseSpell(): \arCasting Failed: I tried to cast a spell %s I don't have Reagents for.",
                spellName)
            return false
        end

        -- Check for enough mana -- just in case something has changed by this point...
        if me.CurrentMana() < spell.Mana() then
            RGMercsLogger.log_verbose("\ayUseSpell(): \arCasting Failed: I tried to cast a spell %s I don't have mana for it.",
                spellName)
            return false
        end

        -- If we're combat casting we need to both have the same swimming status
        if targetId == 0 or (targetSpawn() and targetSpawn.FeetWet() ~= me.FeetWet()) then
            RGMercsLogger.log_debug("\ayUseSpell(): \arCasting Failed: I tried to cast a spell %s I don't have a target (%d) for it.",
                spellName, targetId)
            return false
        end

        if not bAllowDead and targetSpawn() and targetSpawn.Dead() then
            RGMercsLogger.log_verbose("\ayUseSpell(): \arCasting Failed: I tried to cast a spell %s but my target (%d) is dead.",
                spellName, targetId)
            return false
        end

        if (RGMercUtils.GetXTHaterCount() > 0 or not bAllowMem) and (not RGMercUtils.CastReady(spellName) or not mq.TLO.Me.Gem(spellName)()) then
            RGMercsLogger.log_debug("\ayUseSpell(): \ayI tried to cast %s but it was not ready and we are in combat - moving on.",
                spellName)
            return false
        end

        local spellRequiredMem = false
        if not me.Gem(spellName)() then
            RGMercsLogger.log_debug("\ayUseSpell(): \ay%s is not memorized - meming!", spellName)
            RGMercUtils.MemorizeSpell(RGMercUtils.UseGem, spellName, true, 25000)
            spellRequiredMem = true
        end

        if not me.Gem(spellName)() then
            RGMercsLogger.log_debug("\ayUseSpell(): \arFailed to memorized %s - moving on...", spellName)
            return false
        end

        RGMercUtils.WaitCastReady(spellName, spellRequiredMem and (5 * 60 * 100) or 5000)

        RGMercUtils.WaitGlobalCoolDown()

        RGMercUtils.ActionPrep()

        retryCount = retryCount or 5

        if targetId > 0 then
            RGMercUtils.SetTarget(targetId, true)
        end

        --if not RGMercUtils.SpellStacksOnTarget(spell) then
        --    RGMercsLogger.log_debug("\ayUseSpell(): \arStacking checked failed - Someone tell Derple or Algar to add a Stacking Check to the condition of '%s'!", spellName)
        --    return false
        --end

        local cmd = string.format("/cast \"%s\"", spellName)
        RGMercUtils.SetLastCastResult(RGMercConfig.Constants.CastResults.CAST_RESULT_NONE)

        repeat
            RGMercsLogger.log_verbose("\ayUseSpell(): Attempting to cast: %s", spellName)
            RGMercUtils.DoCmd(cmd)
            RGMercsLogger.log_verbose("\ayUseSpell(): Waiting to start cast: %s", spellName)
            mq.delay("1s", function() return mq.TLO.Me.Casting.ID() > 0 end)
            RGMercsLogger.log_verbose("\ayUseSpell(): Started to cast: %s - waiting to finish", spellName)
            RGMercUtils.WaitCastFinish(targetSpawn, bAllowDead or false)
            mq.doevents()
            mq.delay(1)
            RGMercsLogger.log_verbose("\atUseSpell(): Finished waiting on cast: %s result = %s retries left = %d", spellName, RGMercUtils.GetLastCastResultName(), retryCount)
            retryCount = retryCount - 1
        until RGMercUtils.GetLastCastResultId() == RGMercConfig.Constants.CastResults.CAST_SUCCESS or retryCount < 0

        -- don't return control until we are done.
        if RGMercUtils.GetSetting('WaitOnGlobalCooldown') and not overrideWaitForGlobalCooldown then
            RGMercsLogger.log_verbose("\ayUseSpell(): Waiting on Global Cooldown After Casting: %s", spellName)
            RGMercUtils.WaitGlobalCoolDown()
            RGMercsLogger.log_verbose("\agUseSpell(): Done Waiting on Global Cooldown After Casting: %s", spellName)
        end

        RGMercConfig.Globals.LastUsedSpell = spellName
        return true
    end

    RGMercsLogger.log_verbose("\arCasting Failed: Invalid Spell Name")
    return false
end

--- Retrieves the last used spell.
---
--- @return string The name of the last used spell.
function RGMercUtils.GetLastUsedSpell()
    return RGMercConfig.Globals.LastUsedSpell
end

--- Executes an entry action for a given caller.
---
--- @param caller any The entity or object that is calling the function.
--- @param entry any The entry action to be executed.
--- @param targetId any The ID of the target for the action.
--- @param resolvedActionMap table A table containing resolved actions.
--- @param bAllowMem boolean A flag indicating whether memory actions are allowed.
--- @return boolean True if exec of entry was successful, false otherwise.
function RGMercUtils.ExecEntry(caller, entry, targetId, resolvedActionMap, bAllowMem)
    local ret = false

    if entry.type == nil then return false end -- bad data.

    local target = mq.TLO.Target

    if target and target() and target.ID() == targetId then
        if target.Mezzed() and target.Mezzed.ID() and not RGMercUtils.GetSetting('AllowMezBreak') then
            RGMercsLogger.log_debug("  OkayToEngage() Target is mezzed and not AllowMezBreak --> Not Casting!")
            return false
        end
    end

    -- Run pre-activates
    if entry.pre_activate then
        RGMercsLogger.log_super_verbose("Running Pre-Activate for %s", entry.name)
        entry.pre_activate(caller, RGMercUtils.GetEntryConditionArg(resolvedActionMap, entry))
    end

    if entry.type:lower() == "item" then
        local itemName = resolvedActionMap[entry.name]

        if not itemName then itemName = entry.name end

        ret = RGMercUtils.UseItem(itemName, targetId)
    end

    -- different from items in that they are configured by the user instead of the class.
    if entry.type:lower() == "clickyitem" then
        local itemName = caller.settings[entry.name]

        if not itemName or itemName:len() == 0 then
            ret = false
            RGMercsLogger.log_debug("Unable to find item: %s", itemName)
        else
            RGMercUtils.UseItem(itemName, targetId)
            ret = true
        end
    end

    if entry.type:lower() == "spell" then
        local spell = resolvedActionMap[entry.name]

        if not spell or not spell() then
            ret = false
        else
            ret = RGMercUtils.UseSpell(spell.RankName(), targetId, bAllowMem, entry.allowDead, entry.overrideWaitForGlobalCooldown, entry.retries)

            RGMercsLogger.log_debug("Trying To Cast %s - %s :: %s", entry.name, spell.RankName(),
                ret and "\agSuccess" or "\arFailed!")
        end
    end

    if entry.type:lower() == "song" then
        local spell = resolvedActionMap[entry.name]

        if not spell or not spell() then
            ret = false
        else
            ret = RGMercUtils.UseSong(spell.RankName(), targetId, bAllowMem, entry.retries)

            RGMercsLogger.log_debug("Trying To Cast %s - %s :: %s", entry.name, spell.RankName(),
                ret and "\agSuccess" or "\arFailed!")
        end
    end

    if entry.type:lower() == "aa" then
        if RGMercUtils.AAReady(entry.name) then
            RGMercUtils.UseAA(entry.name, targetId)
            ret = true
        else
            ret = false
        end
    end

    if entry.type:lower() == "ability" then
        if RGMercUtils.AbilityReady(entry.name) then
            RGMercUtils.UseAbility(entry.name)
            ret = true
        else
            ret = false
        end
    end

    if entry.type:lower() == "customfunc" then
        if entry.custom_func then
            ret = RGMercUtils.SafeCallFunc(string.format("Custom Func Entry: %s", entry.name), entry.custom_func, caller, targetId)
        else
            ret = false
        end
        --RGMercsLogger.log_verbose("Calling command \ao =>> \ag %s \ao <<= Ret => %s", entry.name, RGMercUtils.BoolToColorString(ret))
    end

    if entry.type:lower() == "disc" then
        local discSpell = resolvedActionMap[entry.name]
        if not discSpell then
            ret = false
        else
            RGMercsLogger.log_debug("Using Disc \ao =>> \ag %s [%s] \ao <<=", entry.name,
                (discSpell() and discSpell.RankName() or "None"))
            ret = RGMercUtils.UseDisc(discSpell, targetId)
        end
    end

    if entry.post_activate then
        entry.post_activate(caller, RGMercUtils.GetEntryConditionArg(resolvedActionMap, entry), ret)
    end

    return ret
end

--- Retrieves the argument for the entry condition from the specified map.
---
--- @param map table The table containing the entry conditions.
--- @param entry table RotationEntry object from class config.
--- @return any The argument associated with the entry condition.
function RGMercUtils.GetEntryConditionArg(map, entry)
    local condArg = map[entry.name] or mq.TLO.Spell(entry.name)
    local entryType = entry.type:lower()
    if (entryType ~= "spell" and entryType ~= "song") and (not condArg or entryType == "aa" or entryType == "ability") then
        condArg = entry.name
    end

    return condArg
end

--- Safely calls a function and logs information.
---
--- @param logInfo string: Information to log before calling the function.
--- @param fn function: The function to be called safely.
--- @param ... any: Additional arguments to pass to the function.
--- @return any: Returns the result of the function call, or nil if an error occurs.
function RGMercUtils.SafeCallFunc(logInfo, fn, ...)
    if not fn then return true end -- no condition func == pass

    local success, ret = pcall(fn, ...)
    if not success then
        RGMercsLogger.log_error("\ay%s\n\ar\t%s", logInfo, ret)
        ret = false
    end
    return ret
end

--- Tests a condition for a given entry.
---
--- @param caller any The entity calling this function.
--- @param resolvedActionMap table The map of resolved actions.
--- @param entry table The RotationEntry to test the condition for.
--- @param targetId any The ID of the target.
--- @return boolean, boolean Returns bool for both check pass and active pass
function RGMercUtils.TestConditionForEntry(caller, resolvedActionMap, entry, targetId)
    local condArg = RGMercUtils.GetEntryConditionArg(resolvedActionMap, entry)
    local condTarg = mq.TLO.Spawn(targetId)
    local pass = false
    local active = false

    if condArg ~= nil then
        local logInfo = string.format(
            "check failed - Entry(\at%s\ay), condArg(\at%s\ay), condTarg(\at%s\ay)", entry.name or "NoName",
            (type(condArg) == 'userdata' and condArg() or condArg) or "None", condTarg.CleanName() or "None")
        pass = RGMercUtils.SafeCallFunc("Condition " .. logInfo, entry.cond, caller, condArg, condTarg)

        if entry.active_cond then
            active = RGMercUtils.SafeCallFunc("Active " .. logInfo, entry.active_cond, caller, condArg)
        end
    end

    RGMercsLogger.log_verbose("\ay   :: Testing Condition for entry(%s) type(%s) cond(%s, %s) ==> \ao%s",
        entry.name, entry.type, condArg or "None", condTarg.CleanName() or "None", RGMercUtils.BoolToColorString(pass))

    entry.lastRun = { pass = pass, active = active, }

    return pass, active
end

--- Executes a rotation of actions based on the provided parameters.
---
--- @param caller any The entity calling this function.
--- @param rotationTable table The table containing the rotation actions.
--- @param targetId number The ID of the target for the rotation actions.
--- @param resolvedActionMap table A map of resolved actions.
--- @param steps number The number of steps in the rotation.
--- @param start_step number The step to start the rotation from.
--- @param bAllowMem boolean Flag to allow memory usage.
--- @param bDoFullRotation boolean? Flag to perform a full rotation.
--- @param fnRotationCond function? A function to determine rotation conditions.
--- @return number, boolean
function RGMercUtils.RunRotation(caller, rotationTable, targetId, resolvedActionMap, steps, start_step, bAllowMem, bDoFullRotation, fnRotationCond)
    local oldSpellInSlot = mq.TLO.Me.Gem(RGMercUtils.UseGem)
    local stepsThisTime  = 0
    local lastStepIdx    = 0
    local anySuccess     = false

    -- This is useful when class config wants to re-check every rotation condition every run
    -- For example, if gem1 meets all condition criteria, it WILL cast repeatedly on every cast
    -- Used for bards to dynamically weave properly
    if bDoFullRotation then start_step = 1 end
    for idx, entry in ipairs(rotationTable) do
        if idx >= start_step then
            caller:SetCurrentRotationState(idx)

            if RGMercConfig.Globals.PauseMain then
                break
            end

            if fnRotationCond then
                local curState = RGMercUtils.GetXTHaterCount() > 0 and "Combat" or "Downtime"

                if not RGMercUtils.SafeCallFunc("\tRotation Condition Loop Re-Check", fnRotationCond, caller, curState) then
                    RGMercsLogger.log_verbose("\arStopping Rotation Due to condition check failure!")
                    break
                end
            end

            if RGMercUtils.ShouldPriorityFollow() then
                break
            end

            RGMercsLogger.log_verbose("\aoDoing RunRotation(start(%d), step(%d), cur(%d))", start_step, steps, idx)
            lastStepIdx = idx
            if entry.cond then
                local pass = RGMercUtils.TestConditionForEntry(caller, resolvedActionMap, entry, targetId)
                RGMercsLogger.log_verbose("\aoDoing RunRotation(start(%d), step(%d), cur(%d)) :: TestConditionsForEntry() => %s", start_step, steps,
                    idx, RGMercUtils.BoolToColorString(pass))
                if pass == true then
                    local res = RGMercUtils.ExecEntry(caller, entry, targetId, resolvedActionMap, bAllowMem)
                    RGMercsLogger.log_verbose("\aoDoing RunRotation(start(%d), step(%d), cur(%d)) :: ExecEntry() => %s", start_step, steps,
                        idx, RGMercUtils.BoolToColorString(res))
                    if res == true then
                        anySuccess = true
                        stepsThisTime = stepsThisTime + 1

                        if steps > 0 and stepsThisTime >= steps then
                            break
                        end

                        if RGMercConfig.Globals.PauseMain then
                            break
                        end
                    end
                else
                    RGMercsLogger.log_verbose("\aoFailed Condition RunRotation(start(%d), step(%d), cur(%d))", start_step, steps, idx)
                end
            else
                local res = RGMercUtils.ExecEntry(caller, entry, targetId, resolvedActionMap, bAllowMem)
                if res == true then
                    stepsThisTime = stepsThisTime + 1

                    if steps > 0 and stepsThisTime >= steps then
                        break
                    end
                end
            end
        end
    end

    if RGMercUtils.GetXTHaterCount() == 0 and oldSpellInSlot() and mq.TLO.Me.Gem(RGMercUtils.UseGem)() ~= oldSpellInSlot.Name() then
        RGMercsLogger.log_debug("\ayRestoring %s in slot %d", oldSpellInSlot, RGMercUtils.UseGem)
        RGMercUtils.MemorizeSpell(RGMercUtils.UseGem, oldSpellInSlot.Name(), false, 15000)
    end

    -- Move to the next step
    lastStepIdx = lastStepIdx + 1

    if lastStepIdx > #rotationTable then
        lastStepIdx = 1
    end

    RGMercsLogger.log_verbose("Ended RunRotation(step(%d), start_step(%d), next(%d))", steps, (start_step or -1),
        lastStepIdx)

    return lastStepIdx, anySuccess
end

--- Checks if a self-buff spell can be cast on a pet.
---
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell can be cast on a pet, false otherwise.
function RGMercUtils.SelfBuffPetCheck(spell)
    if not spell or not spell() then return false end

    -- Skip if the spell is set as a blocked pet buff, otherwise the bot loops forever
    if mq.TLO.Me.BlockedPetBuff(spell.ID())() then
        return false
    end
    RGMercsLogger.log_verbose("\atSelfBuffPetCheck(%s) RankPetBuff(%s) PetBuff(%s) Stacks(%s)",
        spell.RankName.Name(),
        RGMercUtils.BoolToColorString(not mq.TLO.Me.PetBuff(spell.RankName.Name())()),
        RGMercUtils.BoolToColorString(not mq.TLO.Me.PetBuff(spell.Name())()),
        RGMercUtils.BoolToColorString(spell.StacksPet()))

    return (not mq.TLO.Me.PetBuff(spell.RankName.Name())()) and (not mq.TLO.Me.PetBuff(spell.Name())()) and spell.StacksPet() and mq.TLO.Me.Pet.ID() > 0
end

--- Checks if the self-buff spell is active.
---
--- @param spell MQSpell|string The name of the spell to check.
--- @return boolean Returns true if the spell is active, false otherwise.
function RGMercUtils.SelfBuffCheck(spell)
    if type(spell) == "string" then
        RGMercsLogger.log_verbose("\agSelfBuffCheck(%s) string", spell)
        return RGMercUtils.BuffActiveByName(spell)
    end
    if not spell or not spell() then
        --RGMercsLogger.log_verbose("\arSelfBuffCheck() Spell Invalid")
        return false
    end

    local res = not RGMercUtils.BuffActiveByID(spell.RankName.ID()) and spell.Stacks()

    RGMercsLogger.log_verbose("\aySelfBuffCheck(\at%s\ay/\am%d\ay) Spell Obj => %s", spell.RankName(),
        spell.RankName.ID(),
        RGMercUtils.BoolToColorString(res))

    return res
end

--- Pads a string to a specified length with a given character.
---
--- @param string string The original string to be padded.
--- @param len number The desired length of the resulting string.
--- @param padFront boolean If true, padding is added to the front of the string; otherwise, it is added to the back.
--- @param padChar string? The character to use for padding. Defaults to a space if not provided.
--- @return string The padded string.
function RGMercUtils.PadString(string, len, padFront, padChar)
    if not padChar then padChar = " " end
    local cleanText = string:gsub("\a[-]?.", "")

    local paddingNeeded = len - cleanText:len()

    for _ = 1, paddingNeeded do
        if padFront then
            string = padChar .. string
        else
            string = string .. padChar
        end
    end

    return string
end

--- Converts a boolean value to its string representation.
--- @param b boolean: The boolean value to convert.
--- @return string: "true" if the boolean is true, "false" otherwise.
function RGMercUtils.BoolToString(b)
    return b and "true" or "false"
end

--- Converts a boolean value to a color string.
--- If the boolean is true, it returns "green", otherwise "red".
--- @param b boolean: The boolean value to convert.
--- @return string: The color string corresponding to the boolean value.
function RGMercUtils.BoolToColorString(b)
    return b and "\agtrue\ax" or "\arfalse\ax"
end

--- Retrieves a specified setting.
--- @param setting string The name of the setting to retrieve.
--- @param failOk boolean? If true, the function will not raise an error if the setting is not found.
--- @return any The value of the setting, or nil if the setting is not found and failOk is true.
function RGMercUtils.GetSetting(setting, failOk)
    local ret = { module = "Base", value = RGMercConfig:GetSettings()[setting], }

    -- if we found it in the Global table we should alert if it is duplicated anywhere
    -- else as that could get confusing.
    if RGMercModules then -- this could be run before we are fully done loading.
        local submoduleSettings = RGMercModules:ExecAll("GetSettings")
        for name, settings in pairs(submoduleSettings) do
            if settings[setting] ~= nil then
                if not ret.value then
                    ret = { module = name, value = settings[setting], }
                else
                    RGMercsLogger.log_error(
                        "\ay[Setting] \arError: Key %s exists in multiple settings tables: \aw%s \arand \aw%s! Returning first but this should be fixed!",
                        setting,
                        ret.module, name)
                end
            end
        end
    end


    if ret.value ~= nil then
        RGMercsLogger.log_super_verbose("\ag[Setting] \at'%s' \agfound in module \am%s", setting, ret.module)
    else
        if not failOk then
            RGMercsLogger.log_error("\ag[Setting] \at'%s' \aywas requested but not found in any module!", setting)
        end
    end

    return ret.value
end

--- Validates and sets a configuration setting for a specified module.
--- @param module string: The name of the module for which the setting is being configured.
--- @param setting string: The name of the setting to be validated and set.
--- @param value any: The value to be assigned to the setting.
--- @return boolean|string|number|nil: Returns a valid value for the setting.
function RGMercUtils.MakeValidSetting(module, setting, value)
    local defaultConfig = RGMercConfig.DefaultConfig

    if module ~= "Core" then
        defaultConfig = RGMercModules:ExecModule(module, "GetDefaultSettings")
    end

    if type(defaultConfig[setting].Default) == 'number' then
        value = tonumber(value)
        if value == nil then
            RGMercsLogger.log_info("\arError: \ayValue given was not of type number.")
            return nil
        end

        if value > (defaultConfig[setting].Max or 999) or value < (defaultConfig[setting].Min or 0) then
            RGMercsLogger.log_info("\arError: \ay%s is not a valid setting for %s.", value, setting)
            local _, update = RGMercConfig:GetUsageText(setting, true, defaultConfig[setting])
            RGMercsLogger.log_info(update)
            return nil
        end

        return value
    elseif type(defaultConfig[setting].Default) == 'boolean' then
        local boolValue = false
        if value == true or value == "true" or value == "on" or (tonumber(value) or 0) >= 1 then
            boolValue = true
        end

        return boolValue
    elseif type(defaultConfig[setting].Default) == 'string' then
        return value
    end

    return nil
end

--- Converts a given setting name into a valid format and module name
--- This function ensures that the setting name adheres to the required format for further processing.
--- @param setting string The original setting name that needs to be validated and formatted.
--- @return string, string The module of the setting and The validated and formatted setting name.
function RGMercUtils.MakeValidSettingName(setting)
    for s, _ in pairs(RGMercConfig:GetSettings()) do
        if s:lower() == setting:lower() then return "Core", s end
    end

    local submoduleSettings = RGMercModules:ExecAll("GetSettings")
    for moduleName, settings in pairs(submoduleSettings) do
        for s, _ in pairs(settings) do
            if s:lower() == setting:lower() then return moduleName, s end
        end
    end
    return "None", "None"
end

---Sets a setting from either in global or a module setting table.
--- @param setting string: The name of the setting to be updated.
--- @param value any: The new value to assign to the setting.
function RGMercUtils.SetSetting(setting, value)
    local defaultConfig = RGMercConfig.DefaultConfig
    local settingModuleName = "Core"
    local beforeUpdate = ""

    settingModuleName, setting = RGMercUtils.MakeValidSettingName(setting)

    if settingModuleName == "Core" then
        local cleanValue = RGMercUtils.MakeValidSetting("Core", setting, value)
        if not cleanValue then return end
        _, beforeUpdate = RGMercConfig:GetUsageText(setting, false, defaultConfig)
        if cleanValue ~= nil then
            RGMercConfig:GetSettings()[setting] = cleanValue
            RGMercConfig:SaveSettings(false)
        end
    elseif settingModuleName ~= "None" then
        local settings = RGMercModules:ExecModule(settingModuleName, "GetSettings")
        if settings[setting] ~= nil then
            defaultConfig = RGMercModules:ExecModule(settingModuleName, "GetDefaultSettings")
            _, beforeUpdate = RGMercConfig:GetUsageText(setting, false, defaultConfig)
            local cleanValue = RGMercUtils.MakeValidSetting(settingModuleName, setting, value)
            if not cleanValue then return end
            if cleanValue ~= nil then
                settings[setting] = cleanValue
                RGMercModules:ExecModule(settingModuleName, "SaveSettings", false)
            end
        end
    else
        RGMercsLogger.log_error("Setting %s was not found!", setting)
        return
    end

    local _, afterUpdate = RGMercConfig:GetUsageText(setting, false, defaultConfig)
    RGMercsLogger.log_info("[%s] \ag%s :: Before :: %-5s", settingModuleName, setting, beforeUpdate)
    RGMercsLogger.log_info("[%s] \ag%s :: After  :: %-5s", settingModuleName, setting, afterUpdate)
end

--- Checks if the specified AA (Alternate Advancement) ability is available for self-buffing.
--- @param aaName string The name of the AA ability to check.
--- @return boolean Returns true if the AA ability is available for self-buffing, false otherwise.
function RGMercUtils.SelfBuffAACheck(aaName)
    local abilityReady = mq.TLO.Me.AltAbilityReady(aaName)()
    local buffNotActive = not RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.ID())
    local triggerNotActive = not RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())
    local auraNotActive = not mq.TLO.Me.Aura(tostring(mq.TLO.Spell(aaName).RankName())).ID()
    local stacks = RGMercUtils.SpellStacksOnMe(mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName).Spell.RankName.Name()))
    local triggerStacks = (not mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID() or mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).Stacks())

    --RGMercsLogger.log_verbose("SelfBuffAACheck(%s) abilityReady(%s) buffNotActive(%s) triggerNotActive(%s) auraNotActive(%s) stacks(%s) triggerStacks(%s)", aaName,
    --    RGMercUtils.BoolToColorString(abilityReady),
    --    RGMercUtils.BoolToColorString(buffNotActive),
    --    RGMercUtils.BoolToColorString(triggerNotActive),
    --    RGMercUtils.BoolToColorString(auraNotActive),
    --    RGMercUtils.BoolToColorString(stacks),
    --    RGMercUtils.BoolToColorString(triggerStacks))

    return abilityReady and buffNotActive and triggerNotActive and auraNotActive and stacks and triggerStacks
end

--- Retrieves the name of the last cast result.
---
--- @return string The name of the last cast result.
function RGMercUtils.GetLastCastResultName()
    return RGMercConfig.Constants.CastResultsIdToName[RGMercConfig.Globals.CastResult]
end

--- Retrieves the ID of the last cast result.
---
--- @return number The ID of the last cast result.
function RGMercUtils.GetLastCastResultId()
    return RGMercConfig.Globals.CastResult
end

--- Sets the result of the last cast operation.
--- @param result number The result to be set for the last cast operation.
function RGMercUtils.SetLastCastResult(result)
    RGMercsLogger.log_debug("\awSet Last Cast Result => \ag%s", RGMercConfig.Constants.CastResultsIdToName[result])
    RGMercConfig.Globals.CastResult = result
end

--- Checks if the given Damage Over Time (DoT) spell can fire.
---
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the DoT spell can fire, false otherwise.
function RGMercUtils.DotSpellCheck(spell)
    if not spell or not spell() then return false end
    local named = RGMercUtils.IsNamed(mq.TLO.Target)
    local targethp = RGMercUtils.GetTargetPctHPs()

    return not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.SpellStacksOnTarget(spell) and
        ((named and (RGMercUtils.GetSetting('NamedStopDOT') < targethp)) or (RGMercUtils.GetSetting('HPStopDOT') < targethp))
end

--- DetSpellCheck checks if the detrimental spell can fire.
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell detrimental spell should fire, false otherwise.
function RGMercUtils.DetSpellCheck(spell)
    if not spell or not spell() then return false end
    return not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.SpellStacksOnTarget(spell)
end

--- Searches for a specific buff on a peer using DanNet.
---
--- @param peerName string The name of the peer to search for the buff.
--- @param IDs table A table containing the IDs of the buffs to search for.
--- @return boolean Returns true if the buff is found, false otherwise.
function RGMercUtils.DanNetFindBuff(peerName, IDs)
    local text = ""
    for _, id in ipairs(IDs) do
        if text ~= "" then
            text = text .. " or "
        end
        text = text .. "ID " .. tostring(id)
    end

    local buffSearch = string.format("Me.FindBuff[%s].ID", text)
    RGMercsLogger.log_verbose("DanNetFindBuff(%s, %s) : %s", text, peerName, buffSearch)
    return (DanNet.query(peerName, buffSearch, 1000) or "null"):lower() ~= "null"
end

--- Checks if a peer has a specific buff.
--- @param spell MQSpell The name of the spell (buff) to check for.
--- @param peerName string The name of the peer to check.
--- @return boolean|nil True if the peer has the buff, false otherwise.
function RGMercUtils.PeerHasBuff(spell, peerName)
    peerName = (peerName or ""):lower()
    local peerFound = (mq.TLO.DanNet.Peers() or ""):lower():find(peerName:lower() .. "|") ~= nil

    if not peerFound then
        RGMercsLogger.log_verbose("\ayPeerHasBuff() \ayPeer '%s' not found falling back.", peerName)
        return nil
    end

    if not spell or not spell() then return false end

    local numEffects = spell.NumEffects()
    local effectsToCheck = { spell.ID(), spell.RankName.ID(), }

    -- lots of items like the SK epic fire the same effect 11+ times and we keep checking so this is
    -- meant to cache things we've already checked to reduce expensive calls to peer checks.
    local checkedEffects = {}

    for i = 1, numEffects do
        local triggerSpell = spell.Trigger(i)
        if triggerSpell and triggerSpell() and not checkedEffects[triggerSpell.ID()] then
            table.insert(effectsToCheck, triggerSpell.ID())
            if triggerSpell.ID() ~= triggerSpell.RankName.ID() then
                table.insert(effectsToCheck, triggerSpell.RankName.ID())
            end

            checkedEffects[triggerSpell.ID()] = true
        end
    end

    local ret = RGMercUtils.DanNetFindBuff(peerName, effectsToCheck)
    RGMercsLogger.log_verbose("\ayPeerHasBuff() \atSearching for trigger rank spell ID Count: %d on %s :: %s", #effectsToCheck, peerName, RGMercUtils.BoolToColorString(ret))
    RGMercsLogger.log_verbose("\ayPeerHasBuff() \awFinding spell: %s on %s :: %s", spell.Name(), peerName, RGMercUtils.BoolToColorString(ret))
    return ret
end

--- Checks if a group buff can be cast on the target.
--- @param spell MQSpell The name of the spell to check.
--- @param target MQSpawn The name of the target to receive the buff.
--- @return boolean Returns true if the buff can be cast, false otherwise.
function RGMercUtils.GroupBuffCheck(spell, target)
    if not spell or not spell() then return false end
    if not target or not target() then return false end

    local targetName = target.CleanName() or "None"

    if mq.TLO.DanNet(targetName)() ~= nil then
        local spellName = spell.RankName.Name()
        local spellID = spell.RankName.ID()
        local spellResult = DanNet.query(targetName, string.format("Me.FindBuff[id %d]", spellID), 1000)
        RGMercsLogger.log_verbose("\ayGroupBuffCheck() Querying via DanNet for %s(ID:%d) on %s", spellName, spellID, targetName)
        --RGMercsLogger.log_verbose("AlgarInclude.GroupBuffCheckNeedsBuff() DanNet result for %s: %s", spellName, spellResult)
        if spellResult == spellName then
            RGMercsLogger.log_verbose("\atGroupBuffCheck() DanNet detects that %s(ID:%d) is already present on %s, ending.", spellName, spellID, targetName)
            return false
        elseif spellResult == "NULL" then
            RGMercsLogger.log_verbose("\atGroupBuffCheck() DanNet detects %s(ID:%d) is missing on %s, let's check for triggers.", spellName, spellID, targetName)
            local numEffects = spell.NumEffects()
            local triggerCt = 0
            for i = 1, numEffects do
                local triggerSpell = spell.RankName.Trigger(i)
                if triggerSpell and triggerSpell() then
                    local triggerRankResult = DanNet.query(targetName, string.format("Me.FindBuff[id %d]", triggerSpell.ID()), 1000)
                    --RGMercsLogger.log_verbose("GroupBuffCheck() DanNet result for trigger %d of %d (%s, %s): %s", i, numEffects, triggerSpell.Name(), triggerSpell.ID(), triggerRankResult)
                    if triggerRankResult == "NULL" then
                        RGMercsLogger.log_verbose("\ayGroupBuffCheck() DanNet found a missing trigger for %s(ID:%d) on %s, let's check stacking.", triggerSpell.Name(),
                            triggerSpell.ID(), targetName)
                        local triggerStackResult = DanNet.query(targetName, string.format("Spell[%s].Stacks", triggerSpell.Name()), 1000)
                        --RGMercsLogger.log_verbose("GroupBuffCheck() DanNet result for stacking check of %s (ID:%d) on %s : %s", triggerSpell.Name(), triggerSpell.ID(), targetName, triggerStackResult)
                        if triggerStackResult == "TRUE" then
                            RGMercsLogger.log_verbose("\ayGroupBuffCheck() %s (ID:%d) seems to stack on %s, let's do it!", triggerSpell.Name(), triggerSpell.ID(), targetName)
                            return true
                        end
                        RGMercsLogger.log_verbose("\ayGroupBuffCheck() %s(ID:%d) does not stack on %s, moving on.", triggerSpell.Name(), triggerSpell.ID(), targetName)
                    end
                    triggerCt = triggerCt + 1
                else
                    RGMercsLogger.log_verbose("\ayGroupBuffCheck() DanNet found no triggers for %s(ID:%d), let's check stacking.", spellName, spellID)
                end
            end
            if triggerCt >= numEffects then
                RGMercsLogger.log_verbose("\arGroupBuffCheck() DanNet found %d of %d existing triggers for %s(ID:%d) on %s, ending.", triggerCt, numEffects, spellName, spellID,
                    targetName)
                return false
            end
            local stackResult = DanNet.query(targetName, string.format("Spell[%s].Stacks", spellName), 1000)
            --RGMercsLogger.log_verbose("GroupBuffCheck() DanNet result for stacking check of %s (ID:%d) on %s : %s", spellName, spellID, targetName, stackResult)
            if stackResult == "TRUE" then
                RGMercsLogger.log_verbose("\agGroupBuffCheck() %s (ID:%d) seems to stack on %s, let's do it!", spellName, spellID, targetName)
                return true
            end
            RGMercsLogger.log_verbose("GroupBuffCheck() %s(ID:%d) does not stack on %s, moving on.", spellName, spellID, targetName)
        end
    else
        RGMercUtils.SetTarget(target.ID())
        return not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.SpellStacksOnTarget(spell)
    end

    return false
end

--- Checks if the target has a specific buff.
--- @param spell MQSpell The name of the spell to check for.
--- @param buffTarget MQTarget|MQSpawn|MQCharacter? The target to check for the buff.
--- @return boolean Returns true if the target has the buff, false otherwise.
function RGMercUtils.TargetHasBuff(spell, buffTarget)
    --- @type target|spawn|character|fun():string|nil
    local target = mq.TLO.Target

    if buffTarget ~= nil and buffTarget.ID() > 0 then
        target = mq.TLO.Me.ID() == buffTarget.ID() and mq.TLO.Me or buffTarget
    end

    if not spell or not spell() then
        RGMercsLogger.log_verbose("TargetHasBuff(): spell is invalid!")
        return false
    end
    if not target or not target() then
        RGMercsLogger.log_verbose("TargetHasBuff(): target is invalid!")
        return false
    end

    -- If target is me then don't eat the cost of checking against DanNet.
    if mq.TLO.Me.ID() ~= target.ID() then
        local peerCheck = RGMercUtils.PeerHasBuff(spell, target.CleanName())
        if peerCheck ~= nil then return peerCheck end
    end

    if mq.TLO.Me.ID() ~= target.ID() then
        RGMercUtils.SetTarget(target.ID())
    end

    RGMercsLogger.log_verbose("TargetHasBuff(): Target Buffs Populated: %s", RGMercUtils.BoolToColorString(target.BuffsPopulated()))

    local numEffects = spell.NumEffects()

    local ret = (target.FindBuff("id " .. tostring(spell.ID())).ID() or 0) > 0
    RGMercsLogger.log_verbose("TargetHasBuff() Searching for spell(%s) ID: %d on %s :: %s", spell.Name(), spell.ID(), target.DisplayName(), RGMercUtils.BoolToColorString(ret))
    if ret then return true end

    ret = (target.FindBuff("id " .. tostring(spell.RankName.ID())).ID() or 0) > 0
    RGMercsLogger.log_verbose("TargetHasBuff() Searching for rank spell(%s) ID: %d on %s :: %s", spell.RankName.Name(), spell.RankName.ID(), target.DisplayName(),
        RGMercUtils.BoolToColorString(ret))
    if ret then return true end

    for i = 1, numEffects do
        local triggerSpell = spell.Trigger(i)
        if triggerSpell and triggerSpell() then
            ret = (target.FindBuff("id " .. tostring(triggerSpell.ID())).ID() or 0) > 0
            RGMercsLogger.log_verbose("TargetHasBuff() Searching for trigger spell ID: %d on %s :: %s", triggerSpell.ID(), target.DisplayName(), RGMercUtils.BoolToColorString(ret))
            if ret then return true end

            ret = (target.FindBuff("id " .. tostring(triggerSpell.RankName.ID())).ID() or 0) > 0
            RGMercsLogger.log_verbose("TargetHasBuff() Searching for trigger rank spell ID: %d on %s :: %s", triggerSpell.ID(), target.DisplayName(),
                RGMercUtils.BoolToColorString(ret))
            if ret then return true end
        end
    end

    RGMercsLogger.log_verbose("TargetHasBuff() Failed to find spell: %s on %s", spell.Name(), target.DisplayName())
    return false
end

--- Checks if a spell stacks on the target.
--- @param spell MQSpell The name of the spell to check.
--- @return boolean True if the spell stacks on the target, false otherwise.
function RGMercUtils.SpellStacksOnTarget(spell)
    local target = mq.TLO.Target

    if not spell or not spell() then return false end
    if not target or not target() then return false end

    local numEffects = spell.NumEffects()

    if not spell.StacksTarget() then return false end

    for i = 1, numEffects do
        local triggerSpell = spell.Trigger(i)
        if triggerSpell and triggerSpell() then
            if not triggerSpell.StacksTarget() then return false end
        end
    end

    return true
end

--- Checks if a given spell stacks on the player.
--- @param spell MQSpell The name of the spell to check.
--- @return boolean True if the spell stacks on the player, false otherwise.
function RGMercUtils.SpellStacksOnMe(spell)
    if not spell or not spell() then return false end

    local numEffects = spell.NumEffects()

    if not spell.Stacks() then return false end

    for i = 1, numEffects do
        local triggerSpell = spell.Trigger(i)
        if triggerSpell and triggerSpell() then
            if not triggerSpell.Stacks() then return false end
        end
    end

    return true
end

--- Checks if the target has a specific buff by name.
--- @param buffName string The name of the buff to check for.
--- @param buffTarget MQTarget|MQSpawn|MQCharacter? The target to check for the buff.
--- @return boolean True if the target has the buff, false otherwise.
function RGMercUtils.TargetHasBuffByName(buffName, buffTarget)
    if buffName == nil then return false end
    return RGMercUtils.TargetHasBuff(mq.TLO.Spell(buffName), buffTarget)
end

--- Checks if the target's body type matches the specified type.
--- @param target MQTarget The target whose body type is to be checked.
--- @param type string The body type to check against.
--- @return boolean True if the target's body type matches the specified type, false otherwise.
function RGMercUtils.TargetBodyIs(target, type)
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
function RGMercUtils.TargetClassIs(classTable, target)
    local classSet = type(classTable) == 'table' and Set.new(classTable) or Set.new({ classTable, })

    if not target then target = mq.TLO.Target end
    if not target or not target() or not target.Class() then return false end

    return classSet:contains(target.Class.ShortName() or "None")
end

--- Retrieves the level of the specified target.
---
--- @param target MQTarget? The target whose level is to be retrieved.
--- @return number The level of the target.
function RGMercUtils.GetTargetLevel(target)
    return (target and target.Level() or (mq.TLO.Target.Level() or 0))
end

--- Calculates the distance to the specified target.
--- @param target MQTarget|MQSpawn? The target entity whose distance is to be calculated.
--- @return number The distance to the target.
function RGMercUtils.GetTargetDistance(target)
    return (target and target.Distance() or (mq.TLO.Target.Distance() or 9999))
end

--- Calculates the vertical distance (Z-axis) to the specified target.
--- @param target MQTarget|MQSpawn? The target entity to measure the distance to.
--- @return number The vertical distance to the target.
function RGMercUtils.GetTargetDistanceZ(target)
    return (target and target.DistanceZ() or (mq.TLO.Target.DistanceZ() or 9999))
end

--- Gets the maximum range to the specified target.
--- @param target MQTarget? The target entity to measure the range to.
--- @return number The maximum range to the target.
function RGMercUtils.GetTargetMaxRangeTo(target)
    return (target and target.MaxRangeTo() or (mq.TLO.Target.MaxRangeTo() or 15))
end

--- Retrieves the percentage of hit points (HP) remaining for the specified target.
--- @param target MQTarget|MQSpawn? The target entity whose HP percentage is to be retrieved.
--- @return number The percentage of HP remaining for the target.
function RGMercUtils.GetTargetPctHPs(target)
    local useTarget = target
    if not useTarget then useTarget = mq.TLO.Target end
    if not useTarget or not useTarget() then return 0 end

    return useTarget.PctHPs() or 0
end

--- Checks if the specified target is dead.
--- @param target MQTarget The name or identifier of the target to check.
--- @return boolean Returns true if the target is dead, false otherwise.
function RGMercUtils.GetTargetDead(target)
    local useTarget = target
    if not useTarget then useTarget = mq.TLO.Target end
    if not useTarget or not useTarget() then return true end

    return useTarget.Dead()
end

--- Retrieves the name of the given target.
--- @param target MQTarget? The target whose name is to be retrieved.
--- @return string The name of the target.
function RGMercUtils.GetTargetName(target)
    return (target and target.Name() or (mq.TLO.Target.Name() or ""))
end

--- Retrieves the clean name of the given target.
--- @param target MQTarget|MQSpawn? The target from which to extract the clean name.
--- @return string The clean name of the target.
function RGMercUtils.GetTargetCleanName(target)
    return (target and target.Name() or (mq.TLO.Target.CleanName() or ""))
end

--- Retrieves the ID of the given target.
--- @param target MQTarget? The target whose ID is to be retrieved.
--- @return number The ID of the target.
function RGMercUtils.GetTargetID(target)
    return (target and target.ID() or (mq.TLO.Target.ID() or 0))
end

--- Retrieves the aggro percentage of the current target.
--- @return number The aggro percentage of the current target.
function RGMercUtils.GetTargetAggroPct()
    return (mq.TLO.Target.PctAggro() or 0)
end

--- Determines the type of the given target.
--- @param target MQSpawn|MQTarget|groupmember? The target whose type is to be determined.
--- @return string The type of the target as a string.
function RGMercUtils.GetTargetType(target)
    local useTarget = target
    if not useTarget then useTarget = mq.TLO.Target end
    if not useTarget or not useTarget() then return "" end

    return (useTarget.Type() or "")
end

--- Checks if the target is of the specified type.
--- @param type string The type to check against the target.
--- @param target MQSpawn|groupmember|MQTarget? The target to be checked.
--- @return boolean Returns true if the target is of the specified type, false otherwise.
function RGMercUtils.TargetIsType(type, target)
    return RGMercUtils.GetTargetType(target):lower() == type:lower()
end

--- @param target MQTarget|nil
--- @return boolean
function RGMercUtils.GetTargetAggressive(target)
    return (target and target.Aggressive() or (mq.TLO.Target.Aggressive() or false))
end

--- Retrieves the percentage by which the target is slowed.
--- @return number The percentage by which the target is slowed.
function RGMercUtils.GetTargetSlowedPct()
    -- no valid target
    if mq.TLO.Target and not mq.TLO.Target.Slowed() then return 0 end

    return (mq.TLO.Target.Slowed.SlowPct() or 0)
end

--- Retrieves the ID of the main assist in the group.
--- @return number The ID of the main assist in the group.
function RGMercUtils.GetGroupMainAssistID()
    return (mq.TLO.Group.MainAssist.ID() or 0)
end

--- Retrieves the name of the main assist in the group.
--- @return string The name of the main assist in the group.
function RGMercUtils.GetGroupMainAssistName()
    return (mq.TLO.Group.MainAssist.CleanName() or "")
end

--- Checks if a given mode is active.
--- @param mode string The mode to check.
--- @return boolean Returns true if the mode is active, false otherwise.
function RGMercUtils.IsModeActive(mode)
    return RGMercModules:ExecModule("Class", "IsModeActive", mode)
end

--- Checks if the character is currently tanking.
--- @return boolean True if the character is tanking, false otherwise.
function RGMercUtils.IsTanking()
    return RGMercModules:ExecModule("Class", "IsTanking")
end

--- Checks if the current character is performing a healing action.
--- @return boolean True if the character is healing, false otherwise.
function RGMercUtils.IsHealing()
    return RGMercModules:ExecModule("Class", "IsHealing")
end

--- Checks if the curing process is active.
--- @return boolean True if curing is active, false otherwise.
function RGMercUtils.IsCuring()
    return RGMercModules:ExecModule("Class", "IsCuring")
end

--- Checks if the character is currently mezzing.
--- @return boolean True if the character is mezzing, false otherwise.
function RGMercUtils.IsMezzing()
    return RGMercModules:ExecModule("Class", "IsMezzing") and RGMercUtils.GetSetting('MezOn')
end

--- Checks if the character is currently charming.
--- @return boolean True if the character is charming, false otherwise.
function RGMercUtils.IsCharming()
    return RGMercModules:ExecModule("Class", "IsCharming")
end

--- Determines if the character can perform a mez (mesmerize) action.
--- @return boolean True if the character can mez, false otherwise.
function RGMercUtils.CanMez()
    return RGMercModules:ExecModule("Class", "CanMez")
end

--- Checks if the character can charm.
--- @return boolean True if the character can charm, false otherwise.
function RGMercUtils.CanCharm()
    return RGMercModules:ExecModule("Class", "CanCharm")
end

--- Checks if the burn condition is met for RGMercs.
--- This function evaluates certain criteria to determine if the burn phase should be initiated.
--- @return boolean True if the burn condition is met, false otherwise.
function RGMercUtils.BurnCheck()
    local settings = RGMercConfig:GetSettings()
    local autoBurn = settings.BurnAuto and
        ((RGMercUtils.GetXTHaterCount() >= settings.BurnMobCount) or (RGMercUtils.IsNamed(mq.TLO.Target) and settings.BurnNamed))
    local alwaysBurn = (settings.BurnAlways and settings.BurnAuto)
    local forcedBurn = RGMercUtils.ForceBurnTargetID > 0 and RGMercUtils.ForceBurnTargetID == mq.TLO.Target.ID()

    RGMercUtils.LastBurnCheck = autoBurn or alwaysBurn or forcedBurn
    return RGMercUtils.LastBurnCheck
end

--- Determines if the current entity can receive buffs.
--- @return boolean True if the entity can be buffed, false otherwise.
function RGMercUtils.AmIBuffable()
    local myCorpseCount = RGMercUtils.GetSetting('BuffRezables') and 0 or mq.TLO.SpawnCount(string.format('pccorpse %s radius 100 zradius 50', mq.TLO.Me.CleanName()))()
    return myCorpseCount == 0
end

--- Retrieves the list of group IDs that can be buffed.
---
--- @return table A table containing the IDs of the groups that can receive buffs.
function RGMercUtils.GetBuffableGroupIDs()
    local groupIds = RGMercUtils.AmIBuffable() and { mq.TLO.Me.ID(), } or {}
    local count = mq.TLO.Group.Members()
    for i = 1, count do
        local rezSearch = string.format("pccorpse %s radius 100 zradius 50", mq.TLO.Group.Member(i).DisplayName())
        if RGMercUtils.GetSetting('BuffRezables') or mq.TLO.SpawnCount(rezSearch)() == 0 then
            table.insert(groupIds, mq.TLO.Group.Member(i).ID())
        end
    end

    -- check OA list
    for _, n in ipairs(RGMercUtils.GetSetting('OutsideAssistList')) do
        -- dont double up OAs who are in our group
        if not mq.TLO.Group.Member(n)() then
            local oaSpawn = mq.TLO.Spawn(("pc =%s"):format(n))
            if oaSpawn and oaSpawn() and oaSpawn.Distance() <= 90 then
                table.insert(groupIds, oaSpawn.ID())
            end
        end
    end
    return groupIds
end

--- Sticks the player to the specified target.
--- @param targetId number The ID of the target to stick to.
function RGMercUtils.DoStick(targetId)
    if os.clock() - RGMercUtils.LastDoStick < 4 then
        RGMercsLogger.log_debug(
            "\ayIgnoring DoStick because we just stuck less than 4 seconds ago - let's give it some time.")
        return
    end

    RGMercUtils.LastDoStick = os.clock()

    if RGMercUtils.GetSetting('StickHow'):len() > 0 then
        RGMercUtils.DoCmd("/stick %s", RGMercUtils.GetSetting('StickHow'))
    else
        if RGMercUtils.IAmMA() then
            RGMercUtils.DoCmd("/stick 20 id %d %s uw", targetId, RGMercUtils.GetSetting('MovebackWhenTank') and "moveback" or "")
        else
            RGMercUtils.DoCmd("/stick 20 id %d behindonce moveback uw", targetId)
        end
    end
end

--- Executes a group command with the provided arguments.
--- @param cmd string The command to be executed.
--- @param ... any Additional arguments for the command.
function RGMercUtils.DoGroupCmd(cmd, ...)
    local dgcmd = "/dga /if ($\\{Zone.ID} == ${Zone.ID} && $\\{Group.Leader.Name.Equal[${Group.Leader.Name}]}) "
    local formatted = cmd
    if ... ~= nil then formatted = string.format(cmd, ...) end
    formatted = dgcmd .. formatted
    RGMercsLogger.log_debug("\atRGMercs \awsent MQ \amGroup Command\aw: >> \ag%s\aw <<", formatted)
    mq.cmd(formatted)
end

--- Executes a given command with optional arguments.
--- @param cmd string: The command to execute.
--- @param ... any: Optional arguments for the command.
function RGMercUtils.DoCmd(cmd, ...)
    local formatted = cmd
    if ... ~= nil then formatted = string.format(cmd, ...) end
    RGMercsLogger.log_debug("\atRGMercs \awsent MQ \amCommand\aw: >> \ag%s\aw <<", formatted)
    mq.cmd(formatted)
end

--- Navigates around a circle centered on the target with a specified radius.
--- @param target MQTarget The central point around which to navigate.
--- @param radius number The radius of the circle to navigate around.
--- @return boolean True if we were able to successfully navigate around
function RGMercUtils.NavAroundCircle(target, radius)
    if not RGMercUtils.GetSetting('DoAutoEngage') then return false end
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

        RGMercsLogger.log_debug("\aw%d\ax tmp_degrees \aw%d\ax tgt_x \aw%0.2f\ax tgt_y \aw%02.f\ax", steps, tmp_degrees,
            tgt_x, tgt_y)
        -- First check that we can navigate to our new target
        if mq.TLO.Navigation.PathExists(string.format("locyxz %0.2f %0.2f %0.2f", tgt_y, tgt_x, spawn_z))() then
            -- Then check if our new spots has line of sight to our target.
            if mq.TLO.LineOfSight(string.format("%0.2f,%0.2f,%0.2f:%0.2f,%0.2f,%0.2f", tgt_y, tgt_x, spawn_z, spawn_y, spawn_x, spawn_z))() then
                -- Make sure it's a valid loc...
                if mq.TLO.EverQuest.ValidLoc(string.format("%0.2f %0.2f %0.2f", tgt_x, tgt_y, spawn_z))() then
                    RGMercsLogger.log_debug(" \ag--> Found Valid Circling Loc: %0.2f %0.2f %0.2f", tgt_x, tgt_y, spawn_z)
                    RGMercUtils.DoCmd("/nav locyxz %0.2f %0.2f %0.2f facing=backward", tgt_y, tgt_x, spawn_z)
                    mq.delay("2s", function() return mq.TLO.Navigation.Active() end)
                    mq.delay("10s", function() return not mq.TLO.Navigation.Active() end)
                    RGMercUtils.DoCmd("/squelch /face fast")
                    return true
                else
                    RGMercsLogger.log_debug(" \ar--> Invalid Loc: %0.2f %0.2f %0.2f", tgt_x, tgt_y, spawn_z)
                end
            end
        end
    end

    return false
end

--- Navigates to a target during combat.
--- @param targetId number The ID of the target to navigate to.
--- @param distance number The distance to maintain from the target.
--- @param bDontStick boolean Whether to avoid sticking to the target.
function RGMercUtils.NavInCombat(targetId, distance, bDontStick)
    if not RGMercUtils.GetSetting('DoAutoEngage') then return end

    if mq.TLO.Stick.Active() then
        RGMercUtils.DoCmd("/stick off")
    end

    if mq.TLO.Navigation.PathExists("id " .. tostring(targetId) .. " distance " .. tostring(distance))() then
        RGMercUtils.DoCmd("/nav id %d distance=%d log=off lineofsight=on", targetId, distance or 15)
        while mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 do
            mq.delay(100)
        end
    else
        RGMercUtils.DoCmd("/moveto id %d uw mdist %d", targetId, distance)
        while mq.TLO.MoveTo.Moving() and not mq.TLO.MoveUtils.Stuck() do
            mq.delay(100)
        end
    end

    if not bDontStick then
        RGMercUtils.DoStick(targetId)
    end
end

--- Retrieves the ID of the main assist.
---
--- @return number The ID of the main assist.
function RGMercUtils.GetMainAssistId()
    return mq.TLO.Spawn(string.format("PC =%s", RGMercConfig.Globals.MainAssist)).ID() or 0
end

--- Retrieves the percentage of hit points (HP) of the main assist.
---
--- @return number The percentage of HP of the main assist.
function RGMercUtils.GetMainAssistPctHPs()
    local groupMember = mq.TLO.Group.Member(RGMercConfig.Globals.MainAssist)
    if groupMember and groupMember() then
        return groupMember.PctHPs() or 0
    end

    local ret = tonumber(DanNet.query(RGMercConfig.Globals.MainAssist, "Me.PctHPs", 1000))

    if ret and type(ret) == 'number' then return ret end

    return mq.TLO.Spawn(string.format("PC =%s", RGMercConfig.Globals.MainAssist)).PctHPs() or 0
end

--- Retrieves the main assist spawn.
--- @return MQSpawn The main assist spawn data.
function RGMercUtils.GetMainAssistSpawn()
    return mq.TLO.Spawn(string.format("PC =%s", RGMercConfig.Globals.MainAssist))
end

--- Retrieves the current auto-target.
---
--- @return MQSpawn The current auto-target.
function RGMercUtils.GetAutoTarget()
    return mq.TLO.Spawn(string.format("id %d", RGMercConfig.Globals.AutoTargetID))
end

--- Retrieves the percentage of HPs for auto-targeting.
---
--- @return number The percentage of HPs for auto-targeting.
function RGMercUtils.GetAutoTargetPctHPs()
    local autoTarget = RGMercUtils.GetAutoTarget()
    if not autoTarget or not autoTarget() then return 0 end
    return autoTarget.PctHPs() or 0
end

--- Determines whether the utility should shrink.
--- @return boolean True if the utility should shrink, false otherwise.
function RGMercUtils.ShouldShrink()
    return (RGMercUtils.GetSetting('DoShrink') and true or false) and mq.TLO.Me.Height() > 2.2 and
        (RGMercUtils.GetSetting('ShrinkItem'):len() > 0) and RGMercUtils.DoBuffCheck()
end

--- Determines whether the pet should be shrunk.
--- @return boolean True if the pet should be shrunk, false otherwise.
function RGMercUtils.ShouldShrinkPet()
    return (RGMercUtils.GetSetting('DoShrinkPet') and true or false) and mq.TLO.Me.Pet.ID() > 0 and mq.TLO.Me.Pet.Height() > 1.8 and
        (RGMercUtils.GetSetting('ShrinkPetItem'):len() > 0) and RGMercUtils.DoPetCheck()
end

--- Determines if the character should mount.
--- @return boolean True if the character should mount, false otherwise.
function RGMercUtils.ShouldMount()
    if RGMercUtils.GetSetting('DoMount') == 1 then return false end

    local passBasicChecks = RGMercUtils.GetSetting('MountItem'):len() > 0 and mq.TLO.Zone.Outdoor()

    local passCheckMountOne = (not RGMercUtils.GetSetting('DoMelee') and (RGMercUtils.GetSetting('DoMount') == 2 and (mq.TLO.Me.Mount.ID() or 0) == 0))
    local passCheckMountTwo = ((RGMercUtils.GetSetting('DoMount') == 3 and (mq.TLO.Me.Buff("Mount Blessing").ID() or 0) == 0))
    local passMountItemGivesBlessing = false

    if passCheckMountTwo then
        local mountItem = mq.TLO.FindItem(RGMercUtils.GetSetting('MountItem'))
        if mountItem and mountItem() then
            passMountItemGivesBlessing = mountItem.Blessing() ~= nil
        end
    end

    return passBasicChecks and (passCheckMountOne or (passCheckMountTwo and passMountItemGivesBlessing))
end

--- Determines whether the character should dismount.
--- This function checks certain conditions to decide if the character should dismount.
--- @return boolean True if the character should dismount, false otherwise.
function RGMercUtils.ShouldDismount()
    return RGMercUtils.GetSetting('DoMount') ~= 2 and ((mq.TLO.Me.Mount.ID() or 0) > 0)
end

--- Determines whether the target should be reset for killing.
---
--- @return boolean True if the target should be reset, false otherwise.
function RGMercUtils.ShouldKillTargetReset()
    local killSpawn = mq.TLO.Spawn(string.format("targetable id %d", RGMercConfig.Globals.AutoTargetID))
    local killCorpse = mq.TLO.Spawn(string.format("corpse id %d", RGMercConfig.Globals.AutoTargetID))
    return (((not killSpawn() or killSpawn.Dead()) or killCorpse()) and RGMercConfig.Globals.AutoTargetID > 0) and true or
        false
end

--- Automatically manages the medication process for the character.
--- This function handles the logic for ensuring the character takes the necessary medication at the appropriate times.
---
function RGMercUtils.AutoMed()
    local me = mq.TLO.Me
    if RGMercUtils.GetSetting('DoMed') == 1 then return end

    if me.Class.ShortName():lower() == "brd" and me.Level() > 5 then return end

    if me.Mount.ID() and not mq.TLO.Zone.Indoor() then
        RGMercsLogger.log_verbose("Sit check returning early due to mount.")
        return
    end

    RGMercConfig:StoreLastMove()

    --If we're moving/following/navigating/sticking, don't med.
    if me.Casting() or me.Moving() or mq.TLO.Stick.Active() or mq.TLO.Navigation.Active() or mq.TLO.MoveTo.Moving() or mq.TLO.AdvPath.Following() then
        RGMercsLogger.log_verbose(
            "Sit check returning early due to movement. Casting(%s) Moving(%s) Stick(%s) Nav(%s) MoveTo(%s) Following(%s)",
            me.Casting() or "None", RGMercUtils.BoolToColorString(me.Moving()), RGMercUtils.BoolToColorString(mq.TLO.Stick.Active()),
            RGMercUtils.BoolToColorString(mq.TLO.Navigation.Active()), RGMercUtils.BoolToColorString(mq.TLO.MoveTo.Moving()),
            RGMercUtils.BoolToColorString(mq.TLO.AdvPath.Following()))
        return
    end

    local forcesit   = false
    local forcestand = false

    -- Allow sufficient time for the player to do something before char plunks down. Spreads out med sitting too.
    if RGMercConfig:GetTimeSinceLastMove() < math.random(RGMercUtils.GetSetting('AfterMedCombatDelay')) and RGMercUtils.GetSetting('DoMed') ~= 2 then return end

    if RGMercConfig.Constants.RGHybrid:contains(me.Class.ShortName()) or RGMercConfig.Constants.RGCasters:contains(me.Class.ShortName()) then
        -- Handle the case where we're a Hybrid. We need to check mana and endurance. Needs to be done after
        -- the original stat checks.
        if me.PctHPs() >= RGMercUtils.GetSetting('HPMedPctStop') and me.PctMana() >= RGMercUtils.GetSetting('ManaMedPctStop') and me.PctEndurance() >= RGMercUtils.GetSetting('EndMedPctStop') then
            RGMercConfig.Globals.InMedState = false
            forcestand = true
        end

        if me.PctHPs() < RGMercUtils.GetSetting('HPMedPct') or me.PctMana() < RGMercUtils.GetSetting('ManaMedPct') or me.PctEndurance() < RGMercUtils.GetSetting('EndMedPct') then
            forcesit = true
        end
    elseif RGMercConfig.Constants.RGMelee:contains(me.Class.ShortName()) then
        if me.PctHPs() >= RGMercUtils.GetSetting('HPMedPctStop') and me.PctEndurance() >= RGMercUtils.GetSetting('EndMedPctStop') then
            RGMercConfig.Globals.InMedState = false
            forcestand = true
        end

        if me.PctHPs() < RGMercUtils.GetSetting('HPMedPct') or me.PctEndurance() < RGMercUtils.GetSetting('EndMedPct') then
            forcesit = true
        end
    else
        RGMercsLogger.log_error(
            "\arYour character class is not in the type list(s): rghybrid, rgcasters, rgmelee. That's a problem for a dev.")
        RGMercConfig.Globals.InMedState = false
        return
    end

    RGMercsLogger.log_verbose(
        "MED MAIN STATS CHECK :: HP %d :: HPMedPct %d :: Mana %d :: ManaMedPct %d :: Endurance %d :: EndPct %d :: forceSit %s :: forceStand %s",
        me.PctHPs(), RGMercUtils.GetSetting('HPMedPct'), me.PctMana(),
        RGMercUtils.GetSetting('ManaMedPct'), me.PctEndurance(),
        RGMercUtils.GetSetting('EndMedPct'), RGMercUtils.BoolToColorString(forcesit), RGMercUtils.BoolToColorString(forcestand))

    if RGMercUtils.GetXTHaterCount() > 0 and RGMercUtils.GetSetting('DoMed') ~= 2 then
        if RGMercUtils.GetSetting('DoMelee') then
            forcesit = false
            forcestand = true
        end
        if RGMercUtils.GetSetting('DoMed') ~= 3 then
            forcesit = false
            forcestand = true
        end
    end

    if RGMercUtils.GetSetting('StandWhenDone') and me.Sitting() and forcestand and not RGMercUtils.Memorizing then
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

function RGMercUtils.ClickModRod()
    local me = mq.TLO.Me
    if me.PctMana() > RGMercUtils.GetSetting('ModRodManaPct') or me.PctHPs() < 60 or RGMercUtils.Feigning() or mq.TLO.Me.Invis() then
        return
    end

    for _, itemName in ipairs(RGMercConfig.Constants.ModRods) do
        while mq.TLO.Cursor.Name() == itemName do
            RGMercUtils.DoCmd("/squelch /autoinv")
            mq.delay(10)
        end

        local item = mq.TLO.FindItem(itemName)
        if item() and item.TimerReady() == 0 then
            RGMercUtils.UseItem(item.Name(), mq.TLO.Me.ID())
            return
        end
    end
end

--- Checks if a song spell is memorized.
---
--- @param songSpell MQSpell The name of the song spell to check.
--- @return boolean True if the song spell is memorized, false otherwise.
function RGMercUtils.SongMemed(songSpell)
    if not songSpell or not songSpell() then return false end
    local me = mq.TLO.Me

    return me.Gem(songSpell.RankName.Name())() ~= nil
end

--- Returns if a Buff Song is in need of recast
--- @param songSpell MQSpell The name of the song spell to be used for buffing.
--- @return boolean Returns true if the buff is needed, false otherwise.
function RGMercUtils.BuffSong(songSpell)
    if not songSpell or not songSpell() then return false end
    local me = mq.TLO.Me

    local res = RGMercUtils.SongMemed(songSpell) and
        (me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) <= (songSpell.MyCastTime.Seconds() + 6)
    RGMercsLogger.log_verbose("\ayBuffSong(%s) => memed(%s), duration(%0.2f) < casttime(%0.2f) --> result(%s)",
        songSpell.Name(),
        RGMercUtils.BoolToColorString(me.Gem(songSpell.Name())() ~= nil),
        me.Song(songSpell.Name()).Duration.TotalSeconds() or 0, songSpell.MyCastTime.Seconds() + 6,
        RGMercUtils.BoolToColorString(res))
    return res
end

--- Returns if a Debuff Song is in need of recast
--- @param songSpell MQSpell The name of the song spell to be used for debuffing.
--- @return boolean Returns true if the debuff was successfully applied, false otherwise.
function RGMercUtils.DebuffSong(songSpell)
    if not songSpell or not songSpell() then return false end
    local me = mq.TLO.Me
    local res = me.Gem(songSpell.Name()) and not RGMercUtils.TargetHasBuff(songSpell)
    RGMercsLogger.log_verbose("\ayBuffSong(%s) => memed(%s), targetHas(%s) --> result(%s)", songSpell.Name(),
        RGMercUtils.BoolToColorString(me.Gem(songSpell.Name())() ~= nil),
        RGMercUtils.BoolToColorString(RGMercUtils.TargetHasBuff(songSpell)), RGMercUtils.BoolToColorString(res))
    return res
end

--- Checks the debuff condition for the Target
--- This function evaluates the current debuff status and performs necessary actions.
---
--- @return boolean True if the target matches the Con requirements for debuffing.
function RGMercUtils.DebuffConCheck()
    local conLevel = (RGMercConfig.Constants.ConColorsNameToId[mq.TLO.Target.ConColor() or "Grey"] or 0)
    return conLevel >= RGMercUtils.GetSetting('DebuffMinCon') or (RGMercUtils.IsNamed(mq.TLO.Target) and RGMercUtils.GetSetting('DebuffNamedAlways'))
end

--- Checks if we should be casting buffs.
--- This function checks if we should be casting buffs - Enabled by user and not moving or trying to move or follow..
---
--- @return boolean
function RGMercUtils.DoBuffCheck()
    if not RGMercUtils.GetSetting('DoBuffs') then return false end

    if mq.TLO.Me.Invis() or RGMercUtils.GetSetting('BuffWaitMoveTimer') > RGMercConfig:GetTimeSinceLastMove() then return false end

    if RGMercUtils.GetXTHaterCount() > 0 or RGMercConfig.Globals.AutoTargetID > 0 then return false end

    if (mq.TLO.MoveTo.Moving() or mq.TLO.Me.Moving() or mq.TLO.AdvPath.Following() or mq.TLO.Navigation.Active()) and not RGMercUtils.MyClassIs("brd") then return false end

    if RGMercConfig.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and mq.TLO.Me.PctMana() < 10 then return false end

    return true
end

--- Performs a check on the pet status.
--- This function checks various conditions related to the pet.
--- @return boolean Returns true if the pet check is successful, false otherwise.
function RGMercUtils.DoPetCheck()
    if not RGMercUtils.GetSetting('DoPet') then return false end

    if mq.TLO.Me.Invis() or RGMercUtils.GetSetting('BuffWaitMoveTimer') > RGMercConfig:GetTimeSinceLastMove() then return false end

    if RGMercUtils.GetXTHaterCount() > 0 or RGMercConfig.Globals.AutoTargetID > 0 then return false end

    if mq.TLO.MoveTo.Moving() or mq.TLO.Me.Moving() or mq.TLO.AdvPath.Following() or mq.TLO.Navigation.Active() then return false end

    if RGMercConfig.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and mq.TLO.Me.PctMana() < 10 then return false end

    return true
end

--- Determines if the priority follow condition is met.
--- @return boolean True if the priority follow condition is met, false otherwise.
function RGMercUtils.ShouldPriorityFollow()
    local chaseTarget = RGMercUtils.GetSetting('ChaseTarget', true) or "NoOne"

    if chaseTarget == mq.TLO.Me.CleanName() then return false end

    if RGMercUtils.GetSetting('PriorityFollow') and RGMercUtils.GetSetting('ChaseOn') then
        local chaseSpawn = mq.TLO.Spawn("pc =" .. chaseTarget)

        if (mq.TLO.Me.Moving() or (chaseSpawn() and (chaseSpawn.Distance() or 0) > RGMercUtils.GetSetting('ChaseDistance'))) then
            return true
        end
    end

    return false
end

--- Uses the Origin ability for the character.
--- This function triggers the Origin ability, which typically teleports the character to their bind point.
--- Ensure that the character has the Origin ability available before calling this function.
---
--- @return boolean True if successful
function RGMercUtils.UseOrigin()
    if mq.TLO.FindItem("=Drunkard's Stein").ID() or 0 > 0 and mq.TLO.Me.ItemReady("=Drunkard's Stein") then
        RGMercsLogger.log_debug("\ag--\atFound a Drunkard's Stein, using that to get to PoK\ag--")
        RGMercUtils.UseItem("Drunkard's Stein", mq.TLO.Me.ID())
        return true
    end

    if RGMercUtils.AAReady("Throne of Heroes") then
        RGMercsLogger.log_debug("\ag--\atUsing Throne of Heroes to get to Guild Lobby\ag--")
        RGMercsLogger.log_debug("\ag--\atAs you not within a zone we know\ag--")

        RGMercUtils.UseAA("Throne of Heroes", mq.TLO.Me.ID())
        return true
    end

    if RGMercUtils.AAReady("Origin") then
        RGMercsLogger.log_debug("\ag--\atUsing Origin to get to Guild Lobby\ag--")
        RGMercsLogger.log_debug("\ag--\atAs you not within a zone we know\ag--")

        RGMercUtils.UseAA("Origin", mq.TLO.Me.ID())
        return true
    end

    return false
end

--- Calculates the distance between two points (x1, y1) and (x2, y2).
--- @param x1 number The x-coordinate of the first point.
--- @param y1 number The y-coordinate of the first point.
--- @param x2 number The x-coordinate of the second point.
--- @param y2 number The y-coordinate of the second point.
--- @return number The distance between the two points.
function RGMercUtils.GetDistance(x1, y1, x2, y2)
    --return mq.TLO.Math.Distance(string.format("%d,%d:%d,%d", y1 or 0, x1 or 0, y2 or 0, x2 or 0))()
    return math.sqrt(RGMercUtils.GetDistanceSquared(x1, y1, x2, y2))
end

--- Calculates the squared distance between two points (x1, y1) and (x2, y2).
--- This is useful for distance comparisons without the computational cost of a square root.
--- @param x1 number The x-coordinate of the first point.
--- @param y1 number The y-coordinate of the first point.
--- @param x2 number The x-coordinate of the second point.
--- @param y2 number The y-coordinate of the second point.
--- @return number The squared distance between the two points.
function RGMercUtils.GetDistanceSquared(x1, y1, x2, y2)
    return ((x2 or 0) - (x1 or 0)) ^ 2 + ((y2 or 0) - (y1 or 0)) ^ 2
end

--- Checks if we should be doing our camping functionality
--- This function handles the logic required to return to camp.
---
--- @return boolean
function RGMercUtils.DoCamp()
    return
        (RGMercUtils.GetXTHaterCount() == 0 and RGMercConfig.Globals.AutoTargetID == 0) or
        (not RGMercUtils.IsTanking() and RGMercUtils.GetAutoTargetPctHPs() > RGMercUtils.GetSetting('AutoAssistAt'))
end

--- Checks if the auto camp feature should be activated based on the provided temporary configuration.
--- @param tempConfig table: A table containing temporary configuration settings for the auto camp feature.
function RGMercUtils.AutoCampCheck(tempConfig)
    if not RGMercUtils.GetSetting('ReturnToCamp') then return end

    if mq.TLO.Me.Casting.ID() and not RGMercUtils.MyClassIs("brd") then return end

    -- chasing a toon dont use camnp.
    if RGMercUtils.GetSetting('ChaseOn') then return end

    -- camped in a different zone.
    if tempConfig.CampZoneId ~= mq.TLO.Zone.ID() then return end

    -- let pulling module handle camp decisions while it is enabled.
    if RGMercUtils.GetSetting('DoPull') then
        local pullState = RGMercModules:ExecModule("Pull", "GetPullState")

        -- if we are idle or in groupwatch waiting its possible we wandered out of camp to loot and need to come back.
        if pullState > 2 then
            return
        end
    end

    local me = mq.TLO.Me

    local distanceToCamp = RGMercUtils.GetDistance(me.Y(), me.X(), tempConfig.AutoCampY, tempConfig.AutoCampX)

    if distanceToCamp >= 400 then
        RGMercUtils.PrintGroupMessage("I'm over 400 units from camp, not returning!")
        RGMercUtils.DoCmd("/rgl campoff")
        return
    end

    if not RGMercUtils.GetSetting('CampHard') then
        if distanceToCamp < RGMercUtils.GetSetting('AutoCampRadius') then return end
    end

    if distanceToCamp > 5 then
        local navTo = string.format("locyxz %d %d %d", tempConfig.AutoCampY, tempConfig.AutoCampX, tempConfig.AutoCampZ)
        if mq.TLO.Navigation.PathExists(navTo)() then
            RGMercUtils.DoCmd("/nav %s", navTo)
            mq.delay("2s", function() return mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 end)
            while mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 do
                mq.delay(10)
                mq.doevents()
            end
        else
            RGMercUtils.DoCmd("/moveto loc %d %d|on", tempConfig.AutoCampY, tempConfig.AutoCampX)
            while mq.TLO.MoveTo.Moving() and not mq.TLO.MoveTo.Stopped() do
                mq.delay(10)
                mq.doevents()
            end
        end
    end

    if mq.TLO.Navigation.Active() then
        RGMercUtils.DoCmd("/nav stop")
    end
end

--- Checks the combat camp configuration.
--- @param tempConfig table: A table containing temporary configuration settings.
function RGMercUtils.CombatCampCheck(tempConfig)
    if not RGMercUtils.GetSetting('ReturnToCamp') then return end

    if mq.TLO.Me.Casting.ID() and not RGMercUtils.MyClassIs("brd") then return end

    -- chasing a toon dont use camnp.
    if RGMercUtils.GetSetting('ChaseOn') then return end

    -- camped in a different zone.
    if tempConfig.CampZoneId ~= mq.TLO.Zone.ID() then return end

    local me = mq.TLO.Me

    local distanceToCampSq = RGMercUtils.GetDistanceSquared(me.Y(), me.X(), tempConfig.AutoCampY, tempConfig.AutoCampX)

    if not RGMercUtils.GetSetting('CampHard') then
        if distanceToCampSq < RGMercUtils.GetSetting('AutoCampRadius') ^ 2 then return end
    end

    if distanceToCampSq > 25 then
        local navTo = string.format("locyxz %d %d %d", tempConfig.AutoCampY, tempConfig.AutoCampX, tempConfig.AutoCampZ)
        if mq.TLO.Navigation.PathExists(navTo)() then
            RGMercUtils.DoCmd("/nav %s", navTo)
            mq.delay("2s", function() return mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 end)
            while mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 do
                mq.delay(10)
                mq.doevents()
            end
        else
            RGMercUtils.DoCmd("/moveto loc %d %d|on", tempConfig.AutoCampY, tempConfig.AutoCampX)
            while mq.TLO.MoveTo.Moving() and not mq.TLO.MoveTo.Stopped() do
                mq.delay(10)
                mq.doevents()
            end
        end
    end

    if mq.TLO.Navigation.Active() then
        RGMercUtils.DoCmd("/nav stop")
    end
end

--- Engages the target specified by the given autoTargetId.
--- @param autoTargetId number The ID of the target to engage.
function RGMercUtils.EngageTarget(autoTargetId)
    if not RGMercUtils.GetSetting('DoAutoEngage') then return end

    local target = mq.TLO.Target

    if mq.TLO.Me.State():lower() == "feign" and not RGMercUtils.MyClassIs("mnk") and RGMercUtils.GetSetting('AutoStandFD') then
        mq.TLO.Me.Stand()
    end

    RGMercsLogger.log_verbose("\awNOTICE:\ax EngageTarget(%s) Checking for valid Target.", RGMercUtils.GetTargetCleanName())

    if target() and (target.ID() or 0) == autoTargetId and RGMercUtils.GetTargetDistance() <= RGMercUtils.GetSetting('AssistRange') then
        if RGMercUtils.GetSetting('DoMelee') then
            if mq.TLO.Me.Sitting() then
                mq.TLO.Me.Stand()
            end

            if (RGMercUtils.GetTargetPctHPs() <= RGMercUtils.GetSetting('AutoAssistAt') or RGMercUtils.IAmMA()) and not RGMercUtils.GetTargetDead(target) then
                if RGMercUtils.GetTargetDistance(target) > RGMercUtils.GetTargetMaxRangeTo(target) then
                    RGMercsLogger.log_debug("EngageTarget(): Target is too far! %d>%d attempting to nav to it.", target.Distance(),
                        target.MaxRangeTo())

                    local classConfig = RGMercModules:ExecModule("Class", "GetClassConfig")
                    if classConfig and classConfig.HelperFunctions and classConfig.HelperFunctions.PreEngage then
                        classConfig.HelperFunctions.PreEngage(target)
                    end

                    RGMercUtils.NavInCombat(autoTargetId, RGMercUtils.GetTargetMaxRangeTo(target), false)
                else
                    RGMercsLogger.log_debug("EngageTarget(): Target is in range moving to combat")
                    if mq.TLO.Navigation.Active() then
                        RGMercUtils.DoCmd("/nav stop log=off")
                    end
                    if mq.TLO.Stick.Status():lower() == "off" then
                        RGMercUtils.DoStick(autoTargetId)
                    end
                end

                if not mq.TLO.Me.Combat() then
                    RGMercsLogger.log_info("\awNOTICE:\ax Engaging %s in mortal combat.", RGMercUtils.GetTargetCleanName())
                    if RGMercUtils.IAmMA() then
                        RGMercUtils.HandleAnnounce(string.format('TANKING -> %s <-', RGMercUtils.GetTargetCleanName()), RGMercUtils.GetSetting('AnnounceTargetGroup'),
                            RGMercUtils.GetSetting('AnnounceTarget'))
                    end
                    RGMercsLogger.log_debug("EngageTarget(): Attacking target!")
                    RGMercUtils.DoCmd("/attack on")
                else
                    RGMercsLogger.log_verbose("EngageTarget(): Target already engaged not re-engaging.")
                end
            else
                RGMercsLogger.log_verbose("\awNOTICE:\ax EngageTarget(%s) Target is above Assist HP or Dead.",
                    RGMercUtils.GetTargetCleanName())
            end
        else
            RGMercsLogger.log_verbose("\awNOTICE:\ax EngageTarget(%s) DoMelee is false.", RGMercUtils.GetTargetCleanName())
        end
    else
        if not RGMercUtils.GetSetting('DoMelee') and RGMercConfig.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and target.Named() and target.Body.Name() == "Dragon" then
            RGMercUtils.DoCmd("/stick pin 40")
        end

        -- TODO: why are we doing this after turning stick on just now?
        --if mq.TLO.Stick.Status():lower() == "on" then RGMercUtils.DoCmd("/stick off") end
    end
end

--- MercAssist handles the assistance logic for mercenaries.
--- This function is responsible for coordinating the actions of mercenaries to assist in combat or other tasks.
---
function RGMercUtils.MercAssist()
    mq.TLO.Window("MMGW_ManageWnd").Child("MMGW_CallForAssistButton").LeftMouseUp()
end

--- Engages the mercenaries in combat.
---
--- This function initiates the engagement process for mercenaries.
--- It is typically called when mercenaries need to start fighting.
---
function RGMercUtils.MercEngage()
    local merc = mq.TLO.Me.Mercenary

    if merc() and RGMercUtils.GetTargetID() == RGMercConfig.Globals.AutoTargetID and RGMercUtils.GetTargetDistance() < RGMercUtils.GetSetting('AssistRange') then
        if RGMercUtils.GetTargetPctHPs() <= RGMercUtils.GetSetting('AutoAssistAt') or                  -- Hit Assist HP
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
function RGMercUtils.KillPCPet()
    RGMercsLogger.log_warn("\arKilling your pet!")
    local problemPetOwner = mq.TLO.Spawn(string.format("id %d", mq.TLO.Me.XTarget(1).ID())).Master.CleanName()

    if problemPetOwner == mq.TLO.Me.DisplayName() then
        RGMercUtils.DoCmd("/pet leave", problemPetOwner)
    else
        RGMercUtils.DoCmd("/dex %s /pet leave", problemPetOwner)
    end
end

--- Checks if the specified expansion is available.
--- @param name string The name of the expansion to check.
--- @return boolean True if the expansion is available, false otherwise.
function RGMercUtils.HaveExpansion(name)
    return mq.TLO.Me.HaveExpansion(RGMercConfig.Constants.ExpansionNameToID[name])
end

--- Checks if the player's class matches the specified class.
--- @param class string The class to check against the player's class.
--- @return boolean True if the player's class matches the specified class, false otherwise.
function RGMercUtils.MyClassIs(class)
    return mq.TLO.Me.Class.ShortName():lower() == class:lower()
end

--- Checks if the given spawn is a named entity.
--- @param spawn MQSpawn The spawn object to check.
--- @return boolean True if the spawn is named, false otherwise.
function RGMercUtils.IsNamed(spawn)
    if not spawn() then return false end
    RGMercUtils.RefreshNamedCache()

    if RGMercUtils.NamedList[spawn.Name()] or RGMercUtils.NamedList[spawn.CleanName()] then return true end

    --- @diagnostic disable-next-line: undefined-field
    if mq.TLO.Plugin("MQ2SpawnMaster").IsLoaded() and mq.TLO.SpawnMaster.HasSpawn ~= nil then
        --- @diagnostic disable-next-line: undefined-field
        return mq.TLO.SpawnMaster.HasSpawn(spawn.ID())()
    end

    return RGMercUtils.ForceNamed
end

--- Checks if the given name is considered safe within the provided table.
--- @param spawnType string Type of spawn pc/pcpet/merc/etc.
--- @param name string The name to check for safety.
--- @return boolean Returns true if the name is safe, false otherwise.
function RGMercUtils.IsSafeName(spawnType, name)
    RGMercsLogger.log_verbose("IsSafeName(%s)", name)
    if mq.TLO.DanNet(name)() then
        RGMercsLogger.log_verbose("IsSafeName(%s): Dannet Safe", name)
        return true
    end

    for _, n in ipairs(RGMercUtils.GetSetting('OutsideAssistList')) do
        if name == n then
            RGMercsLogger.log_verbose("IsSafeName(%s): OA Safe", name)
            return true
        end
    end

    if mq.TLO.Group.Member(name)() then
        RGMercsLogger.log_verbose("IsSafeName(%s): Group Safe", name)
        return true
    end
    if mq.TLO.Raid.Member(name)() then
        RGMercsLogger.log_verbose("IsSafeName(%s): Raid Safe", name)
        return true
    end

    if mq.TLO.Me.Guild() ~= nil then
        if mq.TLO.Spawn(string.format("%s =%s", spawnType, name)).Guild() == mq.TLO.Me.Guild() then
            RGMercsLogger.log_verbose("IsSafeName(%s): Guild Safe", name)
            return true
        end
    end

    RGMercsLogger.log_verbose("IsSafeName(%s): false", name)
    return false
end

--- Clears the Safe Target Cache after combat.
function RGMercUtils.ClearSafeTargetCache()
    RGMercUtils.SafeTargetCache = {}
end

--- Checks if a given spawn is fighting a stranger within a specified radius.
---
--- @param spawn MQSpawn The spawn object to check.
--- @param radius number The radius within which to check for strangers.
--- @return boolean Returns true if the spawn is fighting a stranger within the specified radius, false otherwise.
function RGMercUtils.IsSpawnFightingStranger(spawn, radius)
    local searchTypes = { "PC", "PCPET", "MERCENARY", }

    for _, t in ipairs(searchTypes) do
        local count = mq.TLO.SpawnCount(string.format("%s radius %d zradius %d", t, radius, radius))()

        for i = 1, count do
            local cur_spawn = mq.TLO.NearestSpawn(i, string.format("%s radius %d zradius %d", t, radius, radius))

            if cur_spawn() and not RGMercUtils.SafeTargetCache[cur_spawn.ID()] then
                if (cur_spawn.AssistName() or ""):len() > 0 then
                    RGMercsLogger.log_verbose("My Interest: %s =? Their Interest: %s", spawn.Name(),
                        cur_spawn.AssistName())
                    if cur_spawn.AssistName() == spawn.Name() then
                        RGMercsLogger.log_verbose("[%s] Fighting same mob as: %s Theirs: %s Ours: %s", t,
                            cur_spawn.CleanName(), cur_spawn.AssistName(), spawn.Name())
                        local checkName = cur_spawn and cur_spawn() or cur_spawn.CleanName() or "None"

                        if RGMercUtils.TargetIsType("mercenary", cur_spawn) and cur_spawn.Owner() then checkName = cur_spawn.Owner.CleanName() end
                        if RGMercUtils.TargetIsType("pet", cur_spawn) then checkName = cur_spawn.Master.CleanName() end

                        if not RGMercUtils.IsSafeName("pc", checkName) then
                            RGMercsLogger.log_verbose(
                                "\ar WARNING: \ax Almost attacked other PCs [%s] mob. Not attacking \aw%s\ax",
                                checkName, cur_spawn.AssistName())
                            return true
                        end
                    end
                end

                -- this is pretty expensive to calculate so lets cache it.
                RGMercUtils.SafeTargetCache[cur_spawn.ID()] = true
            end
        end
    end

    return false
end

--- Checks if combat actions should happen
--- This function handles the combat logic for the RGMercUtils module.
---
--- @return boolean True if actions should happen.
function RGMercUtils.DoCombatActions()
    if not RGMercConfig.Globals.LastMove then return false end
    if RGMercConfig.Globals.AutoTargetID == 0 then return false end
    if RGMercUtils.GetXTHaterCount() == 0 then return false end

    -- We can't assume our target is our autotargetid for where this sub is used.
    local autoSpawn = mq.TLO.Spawn(RGMercConfig.Globals.AutoTargetID)
    if autoSpawn() and RGMercUtils.GetTargetDistance(autoSpawn) > RGMercUtils.GetSetting('AssistRange') then return false end

    return true
end

--- Scans for targets within a specified radius.
---
--- @param radius number The horizontal radius to scan for targets.
--- @param zradius number The vertical radius to scan for targets.
--- @return number spawn id of the new target.
function RGMercUtils.MATargetScan(radius, zradius)
    local aggroSearch    = string.format("npc radius %d zradius %d targetable playerstate 4", radius, zradius)
    local aggroSearchPet = string.format("npcpet radius %d zradius %d targetable playerstate 4", radius, zradius)

    local lowestHP       = 101
    local killId         = 0

    -- Maybe spawn search is failing us -- look through the xtarget list
    local xtCount        = mq.TLO.Me.XTarget()

    for i = 1, xtCount do
        local xtSpawn = mq.TLO.Me.XTarget(i)

        if xtSpawn() and (xtSpawn.ID() or 0) > 0 and (xtSpawn.TargetType():lower() == "auto hater" or RGMercUtils.ForceCombat) then
            if not RGMercUtils.GetSetting('SafeTargeting') or not RGMercUtils.IsSpawnFightingStranger(xtSpawn, radius) then
                RGMercsLogger.log_verbose("Found %s [%d] Distance: %d", xtSpawn.CleanName(), xtSpawn.ID(),
                    xtSpawn.Distance())
                if (xtSpawn.Distance() or 999) <= radius then
                    -- Check for lack of aggro and make sure we get the ones we haven't aggro'd. We can't
                    -- get aggro data from the spawn data type.
                    if mq.TLO.Me.Level() >= 20 then
                        if xtSpawn.PctAggro() < 100 and RGMercUtils.IsTanking() then
                            -- Coarse check to determine if a mob is _not_ mezzed. No point in waking a mezzed mob if we don't need to.
                            if RGMercConfig.Constants.RGMezAnims:contains(xtSpawn.Animation()) then
                                RGMercsLogger.log_verbose("\agHave not fully aggro'd %s -- returning %s [%d]",
                                    xtSpawn.CleanName(), xtSpawn.CleanName(), xtSpawn.ID())
                                return xtSpawn.ID() or 0
                            end
                        end
                    end

                    -- If a name has take priority.
                    if RGMercUtils.IsNamed(xtSpawn) then
                        RGMercsLogger.log_verbose("\agFound Named: %s -- returning %d", xtSpawn.CleanName(), xtSpawn.ID())
                        return xtSpawn.ID() or 0
                    end

                    if (xtSpawn.Body.Name() or "none"):lower() == "Giant" then
                        return xtSpawn.ID() or 0
                    end

                    if (xtSpawn.PctHPs() or 100) < lowestHP then
                        RGMercsLogger.log_verbose("\atFound Possible Target: %s :: %d --  Storing for Lowest HP Check", xtSpawn.CleanName(), xtSpawn.ID())
                        lowestHP = xtSpawn.PctHPs() or 0
                        killId = xtSpawn.ID() or 0
                    end
                else
                    RGMercsLogger.log_verbose("\ar%s distance[%d] is out of radius: %d", xtSpawn.CleanName(), xtSpawn.Distance() or 0, radius)
                end
            else
                RGMercsLogger.log_verbose("XTarget %s [%d] Distance: %d - is fighting someone else - ignoring it.",
                    xtSpawn.CleanName(), xtSpawn.ID(), xtSpawn.Distance())
            end
        end
    end

    if not RGMercUtils.GetSetting('OnlyScanXT') then
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

                if spawn() and (spawn.CleanName() or "None"):find("Guard") == nil then
                    -- If the spawn is already in combat with someone else, we should skip them.
                    if not RGMercUtils.GetSetting('SafeTargeting') or not RGMercUtils.IsSpawnFightingStranger(spawn, radius) then
                        -- If a name has pulled in we target the name first and return. Named always
                        -- take priority. Note: More mobs as of ToL are "named" even though they really aren't.

                        if RGMercUtils.IsNamed(spawn) then
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

                if not RGMercUtils.GetSetting('SafeTargeting') or not RGMercUtils.IsSpawnFightingStranger(spawn, radius) then
                    -- Lowest HP
                    if spawn.PctHPs() < lowestHP then
                        lowestHP = spawn.PctHPs()
                        killId = spawn.ID()
                    end
                end
            end
        end
    end

    RGMercsLogger.log_verbose("\agMATargetScan Returning: \at%d", killId)
    return killId
end

--- Sets the AutoTarget to that of your group or raid MA.
function RGMercUtils.SetAutoTargetToGroupOrRaidTarget()
    if mq.TLO.Raid.Members() > 0 then
        RGMercConfig.Globals.AutoTargetID = ((mq.TLO.Me.RaidAssistTarget(1) and mq.TLO.Me.RaidAssistTarget(1).ID()) or 0)
    elseif mq.TLO.Group.Members() > 0 then
        --- @diagnostic disable-next-line: undefined-field
        RGMercConfig.Globals.AutoTargetID = ((mq.TLO.Me.GroupAssistTarget() and mq.TLO.Me.GroupAssistTarget.ID()) or 0)
    end
end

--- This will find a valid target and set it to : RGMercConfig.Globals.AutoTargetID
--- @param validateFn function? A function used to validate potential targets. Should return true for valid targets and false otherwise.
function RGMercUtils.FindTarget(validateFn)
    RGMercsLogger.log_verbose("FindTarget()")
    if mq.TLO.Spawn(string.format("id %d pcpet xtarhater", mq.TLO.Me.XTarget(1).ID())).ID() > 0 and RGMercUtils.GetSetting('ForceKillPet') then
        RGMercsLogger.log_verbose("FindTarget() Determined that xtarget(1)=%s is a pcpet xtarhater",
            mq.TLO.Me.XTarget(1).CleanName())
        RGMercUtils.KillPCPet()
    end

    -- Handle cases where our autotarget is no longer valid because it isn't a valid spawn or is dead.
    if RGMercConfig.Globals.AutoTargetID ~= 0 then
        local autoSpawn = mq.TLO.Spawn(string.format("id %d", RGMercConfig.Globals.AutoTargetID))
        if not autoSpawn or not autoSpawn() or RGMercUtils.TargetIsType("corpse", autoSpawn) then
            RGMercsLogger.log_debug("\ayFindTarget() : Clearing Target (%d/%s) because it is a corpse or no longer valid.", RGMercConfig.Globals.AutoTargetID,
                autoSpawn and (autoSpawn.CleanName() or "Unknown") or "None")
            RGMercUtils.ClearTarget()
        end
    end

    -- FollowMarkTarget causes RG to have allow RG toons focus on who the group has marked. We'll exit early if this is the case.
    if RGMercUtils.GetSetting('FollowMarkTarget') then
        if mq.TLO.Me.GroupMarkNPC(1).ID() and RGMercConfig.Globals.AutoTargetID ~= mq.TLO.Me.GroupMarkNPC(1).ID() then
            RGMercConfig.Globals.AutoTargetID = mq.TLO.Me.GroupMarkNPC(1).ID()
            return
        end
    end

    local target = mq.TLO.Target

    -- Now handle normal situations where we need to choose a target because we don't have one.
    if RGMercUtils.IAmMA() then
        RGMercsLogger.log_verbose("FindTarget() ==> I am MA!")
        if RGMercConfig.Globals.ForceTargetID ~= 0 then
            local forceSpawn = mq.TLO.Spawn(RGMercConfig.Globals.ForceTargetID)
            if forceSpawn and forceSpawn() and not forceSpawn.Dead() then
                RGMercConfig.Globals.AutoTargetID = RGMercConfig.Globals.ForceTargetID
                RGMercsLogger.log_info("FindTarget(): Forced Targeting: \ag%s\ax [ID: \ag%d\ax]", forceSpawn.CleanName() or "None", forceSpawn.ID())
            else
                RGMercConfig.Globals.ForceTargetID = 0
            end
        else
            -- We need to handle manual targeting and autotargeting seperately
            if not RGMercUtils.GetSetting('DoAutoTarget') then
                -- Manual targetting let the manual user target any npc or npcpet.
                if RGMercConfig.Globals.AutoTargetID ~= target.ID() and
                    (RGMercUtils.TargetIsType("npc", target) or RGMercUtils.TargetIsType("npcpet", target)) and
                    RGMercUtils.GetTargetDistance(target) < RGMercUtils.GetSetting('AssistRange') and
                    RGMercUtils.GetTargetDistanceZ(target) < 20 and
                    RGMercUtils.GetTargetAggressive(target) and
                    target.Mezzed.ID() == nil and target.Charmed.ID() == nil then
                    RGMercsLogger.log_info("FindTarget(): Targeting: \ag%s\ax [ID: \ag%d\ax]", target.CleanName() or "None", target.ID())
                    RGMercConfig.Globals.AutoTargetID = target.ID()
                end
            else
                -- If we're the main assist, we need to scan our nearby area and choose a target based on our built in algorithm. We
                -- only need to do this if we don't already have a target. Assume if any mob runs into camp, we shouldn't reprioritize
                -- unless specifically told.

                if RGMercConfig.Globals.AutoTargetID == 0 then
                    -- If we currently don't have a target, we should see if there's anything nearby we should go after.
                    RGMercConfig.Globals.AutoTargetID = RGMercUtils.MATargetScan(RGMercUtils.GetSetting('AssistRange'),
                        RGMercUtils.GetSetting('MAScanZRange'))
                    RGMercsLogger.log_verbose("MATargetScan returned %d -- Current Target: %s [%d]",
                        RGMercConfig.Globals.AutoTargetID, target.CleanName(), target.ID())
                else
                    -- If StayOnTarget is off, we're going to scan if we don't have full aggro. As this is a dev applied setting that defaults to on, it should
                    -- Only be turned off by tank modes.
                    if not RGMercUtils.GetSetting('StayOnTarget') then
                        RGMercConfig.Globals.AutoTargetID = RGMercUtils.MATargetScan(RGMercUtils.GetSetting('AssistRange'),
                            RGMercUtils.GetSetting('MAScanZRange'))
                        local autoTarget = mq.TLO.Spawn(RGMercConfig.Globals.AutoTargetID)
                        RGMercsLogger.log_verbose(
                            "Re-Targeting: MATargetScan says we need to target %s [%d] -- Current Target: %s [%d]",
                            autoTarget.CleanName() or "None", RGMercConfig.Globals.AutoTargetID or 0,
                            target() and target.CleanName() or "None", target() and target.ID() or 0)
                    end
                end
            end
        end
    else
        -- We're not the main assist so we need to choose our target based on our main assist.
        -- Only change if the group main assist target is an NPC ID that doesn't match the current autotargetid. This prevents us from
        -- swapping to non-NPCs if the  MA is trying to heal/buff a friendly or themselves.
        if RGMercUtils.GetSetting('AssistOutside') then
            --- @diagnostic disable-next-line: redundant-parameter
            local peer = mq.TLO.DanNet.Peers(RGMercConfig.Globals.MainAssist)()
            local assistTarget = nil

            if peer:len() then
                local queryResult = DanNet.query(RGMercConfig.Globals.MainAssist, "Target.ID", 0)
                assistTarget = mq.TLO.Spawn(queryResult)
                if queryResult then
                    RGMercsLogger.log_verbose("\ayFindTargetCheck Assist's Target via DanNet :: %s (%s)",
                        assistTarget.CleanName() or "None", queryResult)
                end
            else
                local assistSpawn = RGMercConfig.Globals.GetMainAssistSpawn()
                if assistSpawn and assistSpawn() then
                    RGMercUtils.SetTarget(assistSpawn.ID(), true)
                    assistTarget = mq.TLO.Me.TargetOfTarget
                    RGMercsLogger.log_verbose("\ayFindTargetCheck Assist's Target via TargetOfTarget :: %s ",
                        assistTarget.CleanName() or "None")
                end
            end

            RGMercsLogger.log_verbose("FindTarget Assisting %s -- Target Agressive: %s", RGMercConfig.Globals.MainAssist,
                RGMercUtils.BoolToColorString(assistTarget and assistTarget.Aggressive() or false))

            if assistTarget and assistTarget() and (RGMercUtils.TargetIsType("npc", assistTarget) or RGMercUtils.TargetIsType("npcpet", assistTarget)) then
                RGMercsLogger.log_verbose(" FindTarget Setting Target To %s [%d]", assistTarget.CleanName(),
                    assistTarget.ID())
                RGMercConfig.Globals.AutoTargetID = assistTarget.ID()
                RGMercUtils.AddXTByName(1, assistTarget.Name())
            end
        else
            RGMercUtils.SetAutoTargetToGroupOrRaidTarget()
        end
    end

    RGMercsLogger.log_verbose("FindTarget(): FoundTargetID(%d), myTargetId(%d)", RGMercConfig.Globals.AutoTargetID or 0,
        mq.TLO.Target.ID())

    if RGMercConfig.Globals.AutoTargetID > 0 and mq.TLO.Target.ID() ~= RGMercConfig.Globals.AutoTargetID then
        if not validateFn or validateFn(RGMercConfig.Globals.AutoTargetID) then
            RGMercUtils.SetTarget(RGMercConfig.Globals.AutoTargetID, true)
        end
    end
end

--- Handles the announcement message.
--- @param msg string: The message to be announced.
--- @param sendGroup boolean: Whether to send the message to the group.
--- @param sendDan boolean: Whether to send the message to DanNet.
function RGMercUtils.HandleAnnounce(msg, sendGroup, sendDan)
    if sendGroup then
        local cleanMsg = msg:gsub("\a.", "")
        RGMercUtils.DoCmd("/gsay %s", cleanMsg)
    end

    if sendDan then
        RGMercUtils.PrintGroupMessage(msg)
    end

    RGMercsLogger.log_debug(msg)
end

--- Retrieves the IDs of the top haters.
--- @param printDebug boolean?: If true, debug information will be printed.
--- @return table: A table containing the IDs of the top haters.
function RGMercUtils.GetXTHaterIDs(printDebug)
    local xtCount = mq.TLO.Me.XTarget() or 0
    local haters = {}

    for i = 1, xtCount do
        local xtarg = mq.TLO.Me.XTarget(i)
        if xtarg and xtarg.ID() > 0 and not xtarg.Dead() and (math.ceil(xtarg.PctHPs() or 0)) > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater") or RGMercUtils.ForceCombat) then
            if printDebug then
                RGMercsLogger.log_verbose("GetXTHaters(): XT(%d) Counting %s(%d) as a hater.", i, xtarg.CleanName() or "None", xtarg.ID())
            end

            table.insert(haters, xtarg.ID())
        end
    end

    return haters
end

--- Gets the count of XTHaters.
--- @param printDebug boolean?: If true, debug information will be printed.
--- @return number: The count of XTHaters.
function RGMercUtils.GetXTHaterCount(printDebug)
    return #RGMercUtils.GetXTHaterIDs(printDebug)
end

--- Computes the difference in Hater IDs.
---
--- @param t table The table containing Hater IDs.
--- @param printDebug boolean? Whether to print debug information.
--- @return boolean True if there is a difference, false otherwise
function RGMercUtils.DiffXTHaterIDs(t, printDebug)
    local oldHaterSet = Set.new(t)
    local curHaters   = RGMercUtils.GetXTHaterIDs(printDebug)

    for _, xtargID in ipairs(curHaters) do
        if not oldHaterSet:contains(xtargID) then return true end
    end

    return false
end

--- Finds the group member with the lowest mana percentage.
--- @param minMana number The minimum mana percentage to consider.
--- @return number The group member with the lowest mana percentage, or nil if no member meets the criteria.
function RGMercUtils.FindWorstHurtManaGroupMember(minMana)
    local groupSize = mq.TLO.Group.Members()
    local worstId = mq.TLO.Me.ID() --initializes with the BST's ID/Mana because it isn't checked below
    local worstPct = mq.TLO.Me.PctMana()

    RGMercsLogger.log_verbose("\ayChecking for worst HurtMana Group Members. Group Count: %d", groupSize)

    for i = 1, groupSize do
        local healTarget = mq.TLO.Group.Member(i)

        if healTarget and healTarget() and not healTarget.OtherZone() and not healTarget.Offline() then
            if RGMercConfig.Constants.RGCasters:contains(healTarget.Class.ShortName()) then
                if not healTarget.Dead() and healTarget.PctMana() < worstPct then
                    RGMercsLogger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                    worstPct = healTarget.PctMana()
                    worstId = healTarget.ID()
                end
            end
        end
    end

    --Still possibly carrying the BST ID, but only reports BST if under 100%, which is when they will self-Paragon
    if worstId > 0 and worstPct < 100 then
        RGMercsLogger.log_verbose("\agWorst HurtMana group member id is %d", worstId)
    else
        RGMercsLogger.log_verbose("\agNo one is HurtMana!")
    end

    return (worstPct < minMana and worstId or 0)
end

--- Finds the group member with the lowest health percentage.
--- @param minHPs number The minimum health percentage to consider.
--- @return number The group member with the lowest health percentage, or nil if no member meets the criteria.
function RGMercUtils.FindWorstHurtGroupMember(minHPs)
    local groupSize = mq.TLO.Group.Members()
    local worstId = mq.TLO.Me.ID()
    local worstPct = mq.TLO.Me.PctHPs() < minHPs and mq.TLO.Me.PctHPs() or minHPs

    RGMercsLogger.log_verbose("\ayChecking for worst Hurt Group Members. Group Count: %d", groupSize)

    for i = 1, groupSize do
        local healTarget = mq.TLO.Group.Member(i)

        if healTarget and healTarget() and not healTarget.OtherZone() and not healTarget.Offline() then
            if not healTarget.Dead() and (healTarget.PctHPs() or 101) < worstPct then
                RGMercsLogger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                worstPct = healTarget.PctHPs()
                worstId = healTarget.ID()
            end

            if RGMercUtils.GetSetting('DoPetHeals') then
                if (healTarget.Pet.ID() or 0) > 0 and (healTarget.Pet.PctHPs() or 101) < (worstPct or 0) then
                    RGMercsLogger.log_verbose("\aySo far %s's pet %s is the worst off.", healTarget.DisplayName(),
                        healTarget.Pet.DisplayName())
                    worstPct = healTarget.Pet.PctHPs()
                    worstId = healTarget.Pet.ID()
                end
            end
        end
    end

    if worstId > 0 then
        RGMercsLogger.log_verbose("\agWorst hurt group member id is %d", worstId)
    else
        RGMercsLogger.log_verbose("\agNo one is hurt!")
    end

    return (worstPct < 100 and worstId or 0)
end

--- Finds the entity with the worst hurt mana exceeding a minimum threshold.
--- @param minMana number The minimum mana threshold to consider.
--- @return number The spawn id with the worst hurt mana above the specified threshold.
function RGMercUtils.FindWorstHurtManaXT(minMana)
    local xtSize = mq.TLO.Me.XTargetSlots()
    local worstId = 0
    local worstPct = minMana

    RGMercsLogger.log_verbose("\ayChecking for worst HurtMana XTargs. XT Slot Count: %d", xtSize)

    for i = 1, xtSize do
        local healTarget = mq.TLO.Me.XTarget(i)

        if healTarget and healTarget() and RGMercUtils.TargetIsType("pc", healTarget) then
            if RGMercConfig.Constants.RGCasters:contains(healTarget.Class.ShortName()) then -- berzerkers have special handing
                if not healTarget.Dead() and healTarget.PctMana() < worstPct then
                    RGMercsLogger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                    worstPct = healTarget.PctMana()
                    worstId = healTarget.ID()
                end
            end
        end
    end

    if worstId > 0 then
        RGMercsLogger.log_verbose("\agWorst HurtMana xtarget id is %d", worstId)
    else
        RGMercsLogger.log_verbose("\agNo one is HurtMana!")
    end

    return worstId
end

--- Finds the entity with the worst health condition that meets the minimum HP requirement.
--- @param minHPs number The minimum HP threshold to consider.
--- @return number The spawn id with the worst health condition that meets the criteria.
function RGMercUtils.FindWorstHurtXT(minHPs)
    local xtSize = mq.TLO.Me.XTargetSlots()
    local worstId = 0
    local worstPct = minHPs

    RGMercsLogger.log_verbose("\ayChecking for worst Hurt XTargs. XT Slot Count: %d", xtSize)

    for i = 1, xtSize do
        local healTarget = mq.TLO.Me.XTarget(i)

        if healTarget and healTarget() and RGMercUtils.TargetIsType("pc", healTarget) then
            if not healTarget.Dead() and healTarget.PctHPs() < worstPct then
                RGMercsLogger.log_verbose("\aySo far %s is the worst off.", healTarget.DisplayName())
                worstPct = healTarget.PctHPs()
                worstId = healTarget.ID()
            end

            if RGMercUtils.GetSetting('DoPetHeals') then
                if healTarget.Pet.ID() > 0 and healTarget.Pet.PctHPs() < worstPct then
                    RGMercsLogger.log_verbose("\aySo far %s's pet %s is the worst off.", healTarget.DisplayName(),
                        healTarget.Pet.DisplayName())
                    worstPct = healTarget.Pet.PctHPs()
                    worstId = healTarget.Pet.ID()
                end
            end
        end
    end

    if worstId > 0 then
        RGMercsLogger.log_verbose("\agWorst hurt xtarget id is %d", worstId)
    else
        RGMercsLogger.log_verbose("\agNo one is hurt!")
    end

    return worstId
end

--- Checks if the given spawn is an XTHater.
--- @param spawnId number The ID of the spawn to check.
--- @return boolean True if the spawn is an XTHater, false otherwise.
function RGMercUtils.IsSpawnXTHater(spawnId)
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
function RGMercUtils.AddXTByName(slot, name)
    local spawnToAdd = mq.TLO.Spawn(name)
    if spawnToAdd and spawnToAdd() and mq.TLO.Me.XTarget(slot).ID() ~= spawnToAdd.ID() then
        RGMercUtils.DoCmd("/xtarget set %d \"%s\"", slot, name)
    end
end

--- Adds an item to a slot by its ID.
--- @param slot number The slot number where the item should be added.
--- @param id number The ID of the item to be added.
function RGMercUtils.AddXTByID(slot, id)
    local spawnToAdd = mq.TLO.Spawn(id)
    if spawnToAdd and spawnToAdd() and mq.TLO.Me.XTarget(slot).ID() ~= spawnToAdd.ID() then
        RGMercUtils.DoCmd("/xtarget set %d \"%s\"", slot, spawnToAdd.CleanName())
    end
end

--- Resets the specified XT slot.
--- @param slot number The slot number to reset.
function RGMercUtils.ResetXTSlot(slot)
    RGMercUtils.DoCmd("/xtarget set %d autohater", slot)
end

--- Sets the control (Assist) toon for RGMercs
--- This function is responsible for designating a specific toon as the control toon.
---
function RGMercUtils.SetControlToon()
    RGMercsLogger.log_verbose("Checking for best Control Toon")
    if RGMercUtils.GetSetting('AssistOutside') then
        if #RGMercUtils.GetSetting('OutsideAssistList') > 0 then
            local maSpawn = RGMercUtils.GetMainAssistSpawn()

            if maSpawn.ID() > 0 and not maSpawn.Dead() then
                -- make sure they are still in our XT.
                RGMercUtils.AddXTByName(2, maSpawn.DisplayName())
                return
            end

            for _, name in ipairs(RGMercUtils.GetSetting('OutsideAssistList')) do
                RGMercsLogger.log_verbose("Testing %s for control", name)
                local assistSpawn = mq.TLO.Spawn(string.format("PC =%s", name))

                if assistSpawn() and assistSpawn.ID() ~= RGMercUtils.GetMainAssistId() and not assistSpawn.Dead() then
                    RGMercsLogger.log_info("Setting new assist to %s [%d]", assistSpawn.CleanName(), assistSpawn.ID())
                    RGMercConfig.Globals.MainAssist = assistSpawn.CleanName()

                    RGMercUtils.AddXTByName(2, assistSpawn.DisplayName())

                    return
                elseif assistSpawn() and assistSpawn.ID() == RGMercUtils.GetMainAssistId() and not assistSpawn.Dead() then
                    RGMercUtils.AddXTByName(2, assistSpawn.DisplayName())
                    return
                end
            end
        else
            if not RGMercConfig.Globals.MainAssist or RGMercConfig.Globals.MainAssist:len() == 0 then
                -- Use our Target hope for the best!
                --TODO: NOT A VALID BASE CMD RGMercUtils.DoCmd("/squelch /xtarget assist %d", mq.TLO.Target.ID())
                RGMercConfig.Globals.MainAssist = mq.TLO.Target.CleanName()
            end
        end
    else
        if RGMercUtils.GetMainAssistId() ~= RGMercUtils.GetGroupMainAssistID() and RGMercUtils.GetGroupMainAssistID() > 0 then
            RGMercConfig.Globals.MainAssist = RGMercUtils.GetGroupMainAssistName()
        end
    end
end

--- Checks if the current character is a Main Assistant (MA).
--- @return boolean True if the character is the Main Assistant, false otherwise.
function RGMercUtils.IAmMA()
    return RGMercUtils.GetMainAssistId() == mq.TLO.Me.ID()
end

--- Checks if the character is currently feigning death.
--- @return boolean True if the character is feigning death, false otherwise.
function RGMercUtils.Feigning()
    return mq.TLO.Me.State():lower() == "feign"
end

--- Retrieves the highest aggro percentage among all players.
---
--- @return number The highest aggro percentage.
function RGMercUtils.GetHighestAggroPct()
    local target     = mq.TLO.Target
    local me         = mq.TLO.Me

    local highestPct = target.PctAggro() or 0

    local xtCount    = mq.TLO.Me.XTarget()

    for i = 1, xtCount do
        local xtSpawn = mq.TLO.Me.XTarget(i)

        if xtSpawn() and (xtSpawn.ID() or 0) > 0 and (xtSpawn.TargetType():lower() == "auto hater" or RGMercUtils.ForceCombat) then
            if xtSpawn.PctAggro() > highestPct then highestPct = xtSpawn.PctAggro() end
        end
    end

    return highestPct
end

--- Checks if the player has aggro based on a given percentage.
--- @param pct number The percentage threshold to determine if the player has aggro.
--- @return boolean Returns true if the player has aggro above the given percentage, false otherwise.
function RGMercUtils.IHaveAggro(pct)
    local target = mq.TLO.Target
    local me     = mq.TLO.Me

    if (target() and (target.PctAggro() or 0) >= pct) then return true end

    local xtCount = mq.TLO.Me.XTarget()

    for i = 1, xtCount do
        local xtSpawn = mq.TLO.Me.XTarget(i)

        if xtSpawn() and (xtSpawn.ID() or 0) > 0 and (xtSpawn.TargetType():lower() == "auto hater" or RGMercUtils.ForceCombat) then
            if xtSpawn.PctAggro() >= pct then return true end
        end
    end

    return false
end

--- Finds and checks the target.
---
--- This function performs a check on the current target to determine if it meets certain criteria.
---
--- @return boolean True if the target meets the criteria, false otherwise.
function RGMercUtils.FindTargetCheck()
    local config = RGMercConfig:GetSettings()

    RGMercsLogger.log_verbose("FindTargetCheck(%d, %s, %s, %s)", RGMercUtils.GetXTHaterCount(),
        RGMercUtils.BoolToColorString(RGMercUtils.IAmMA()), RGMercUtils.BoolToColorString(config.FollowMarkTarget),
        RGMercUtils.BoolToColorString(RGMercConfig.Globals.BackOffFlag))

    local OATarget = false

    -- our MA out of group has a valid target for us.
    if RGMercUtils.GetSetting('AssistOutside') then
        local queryResult = DanNet.query(RGMercConfig.Globals.MainAssist, "Target.ID", 0)

        local assistTarget = mq.TLO.Spawn(queryResult)
        if queryResult then
            RGMercsLogger.log_verbose("\ayFindTargetCheck Assist's Target via DanNet :: %s",
                assistTarget.CleanName() or "None")
        end

        if assistTarget and assistTarget() then
            OATarget = true
        end
    end

    return (RGMercUtils.GetXTHaterCount() > 0 or RGMercUtils.IAmMA() or config.FollowMarkTarget or OATarget) and
        not RGMercConfig.Globals.BackOffFlag
end

--- Validates if it is acceptable to engage with a target based on its ID.
--- This function performs pre-validation checks to determine if engagement is permissible.
---
--- @param targetId number The ID of the target to be validated.
--- @return boolean Returns true if it is acceptable to engage with the target, false otherwise.
function RGMercUtils.OkToEngagePreValidateId(targetId)
    if not RGMercUtils.GetSetting('DoAutoEngage') then return false end
    local target = mq.TLO.Spawn(targetId)
    local assistId = RGMercUtils.GetMainAssistId()

    if not target() or target.Dead() then return false end

    local pcCheck = RGMercUtils.TargetIsType("pc", target) or
        (RGMercUtils.TargetIsType("pet", target) and RGMercUtils.TargetIsType("pc", target.Master))
    local mercCheck = RGMercUtils.TargetIsType("mercenary", target)
    if pcCheck or mercCheck then
        if not mq.TLO.Me.Combat() then
            RGMercsLogger.log_verbose(
                "\ay[2] Target type check failed \aw[\atpcCheckFailed(%s) mercCheckFailed(%s)\aw]\ay",
                RGMercUtils.BoolToColorString(pcCheck), RGMercUtils.BoolToColorString(mercCheck))
        end
        return false
    end

    if RGMercUtils.GetSetting('SafeTargeting') and RGMercUtils.IsSpawnFightingStranger(target, 100) then
        RGMercsLogger.log_verbose("\ay  OkToEngageId(%s) is fighting Stranger --> Not Engaging",
            RGMercUtils.GetTargetCleanName())
        return false
    end

    if not RGMercConfig.Globals.BackOffFlag then --RGMercUtils.GetXTHaterCount() > 0 and not RGMercConfig.Globals.BackOffFlag then
        local distanceCheck = RGMercUtils.GetTargetDistance(target) < RGMercUtils.GetSetting('AssistRange')
        local assistCheck = (RGMercUtils.GetTargetPctHPs(target) <= RGMercUtils.GetSetting('AutoAssistAt') or RGMercUtils.IsTanking() or RGMercUtils.IAmMA())
        if distanceCheck and assistCheck then
            if not mq.TLO.Me.Combat() then
                RGMercsLogger.log_verbose(
                    "\ag  OkToEngageId(%s) %d < %d and %d < %d or Tanking or %d == %d --> \agOK To Engage!",
                    RGMercUtils.GetTargetCleanName(target),
                    RGMercUtils.GetTargetDistance(target), RGMercUtils.GetSetting('AssistRange'), RGMercUtils.GetTargetPctHPs(target),
                    RGMercUtils.GetSetting('AutoAssistAt'), assistId,
                    mq.TLO.Me.ID())
            end
            return true
        else
            RGMercsLogger.log_verbose(
                "\ay  OkToEngageId(%s) AssistCheck failed for: %s / %d distanceCheck(%s/%d), assistCheck(%s)",
                RGMercUtils.GetTargetCleanName(target),
                target.CleanName(), target.ID(), RGMercUtils.BoolToColorString(distanceCheck), RGMercUtils.GetTargetDistance(target),
                RGMercUtils.BoolToColorString(assistCheck))
            return false
        end
    end

    RGMercsLogger.log_verbose("\ay  OkToEngageId(%s) Okay to Engage Failed with Fall Through!",
        RGMercUtils.GetTargetCleanName(target),
        RGMercUtils.BoolToColorString(pcCheck), RGMercUtils.BoolToColorString(mercCheck))
    return false
end

--- Determines if it is acceptable to engage a target.
--- @param autoTargetId number The ID of the target to check.
--- @return boolean Returns true if it is okay to engage the target, false otherwise.
function RGMercUtils.OkToEngage(autoTargetId)
    if not RGMercUtils.GetSetting('DoAutoEngage') then return false end
    local target = mq.TLO.Target
    local assistId = RGMercUtils.GetMainAssistId()

    if not target() or target.Dead() then return false end

    local pcCheck = RGMercUtils.TargetIsType("pc", target) or
        (RGMercUtils.TargetIsType("pet", target) and RGMercUtils.TargetIsType("pc", target.Master))
    local mercCheck = RGMercUtils.TargetIsType("mercenary", target)
    if pcCheck or mercCheck then
        if not mq.TLO.Me.Combat() then
            RGMercsLogger.log_verbose(
                "\ay[2] Target type check failed \aw[\atpcCheckFailed(%s) mercCheckFailed(%s)\aw]\ay",
                RGMercUtils.BoolToColorString(pcCheck), RGMercUtils.BoolToColorString(mercCheck))
        end
        return false
    end

    if RGMercUtils.GetSetting('SafeTargeting') and RGMercUtils.IsSpawnFightingStranger(target, 100) then
        RGMercsLogger.log_verbose("\ay  OkayToEngage() %s is fighting Stranger --> Not Engaging",
            RGMercUtils.GetTargetCleanName())
        return false
    end

    if RGMercUtils.GetTargetID() ~= autoTargetId then
        RGMercsLogger.log_verbose("  OkayToEngage() %d != %d --> Not Engaging", target.ID() or 0, autoTargetId)
        return false
    end

    -- if this target is from a target ID then it wont have .Mezzed
    if target.Mezzed() and target.Mezzed.ID() and not RGMercUtils.GetSetting('AllowMezBreak') then
        RGMercsLogger.log_debug("  OkayToEngage() Target is mezzed and not AllowMezBreak --> Not Engaging")
        return false
    end

    if not RGMercConfig.Globals.BackOffFlag then --RGMercUtils.GetXTHaterCount() > 0 and not RGMercConfig.Globals.BackOffFlag then
        local distanceCheck = RGMercUtils.GetTargetDistance() < RGMercUtils.GetSetting('AssistRange')
        local assistCheck = (RGMercUtils.GetTargetPctHPs() <= RGMercUtils.GetSetting('AutoAssistAt') or RGMercUtils.IsTanking() or RGMercUtils.IAmMA())
        if distanceCheck and assistCheck then
            if not mq.TLO.Me.Combat() then
                RGMercsLogger.log_verbose(
                    "\ag  OkayToEngage(%s) %d < %d and %d < %d or Tanking or %d == %d --> \agOK To Engage!",
                    RGMercUtils.GetTargetCleanName(),
                    RGMercUtils.GetTargetDistance(), RGMercUtils.GetSetting('AssistRange'), RGMercUtils.GetTargetPctHPs(), RGMercUtils.GetSetting('AutoAssistAt'), assistId,
                    mq.TLO.Me.ID())
            end
            return true
        else
            RGMercsLogger.log_verbose(
                "\ay  OkayToEngage() AssistCheck failed for: %s / %d distanceCheck(%s/%d), assistCheck(%s)",
                target.CleanName(), target.ID(), RGMercUtils.BoolToColorString(distanceCheck), RGMercUtils.GetTargetDistance(),
                RGMercUtils.BoolToColorString(assistCheck))
            return false
        end
    end

    RGMercsLogger.log_verbose("\ay  OkayToEngage() Okay to Engage Failed with Fall Through!",
        RGMercUtils.BoolToColorString(pcCheck), RGMercUtils.BoolToColorString(mercCheck))
    return false
end

--- Sends your pet in to attack.
--- @param targetId number The ID of the target to attack.
--- @param sendSwarm boolean Whether to send a swarm attack or not.
function RGMercUtils.PetAttack(targetId, sendSwarm)
    local pet = mq.TLO.Me.Pet

    local target = mq.TLO.Spawn(targetId)

    if not target() then return end
    if pet.ID() == 0 then return end

    if (not pet.Combat() or pet.Target.ID() ~= target.ID()) and RGMercUtils.TargetIsType("NPC", target) then
        RGMercUtils.DoCmd("/squelch /pet attack %d", targetId)
        if sendSwarm then
            RGMercUtils.DoCmd("/squelch /pet swarm")
        end
        RGMercsLogger.log_debug("Pet sent to attack target: %s!", target.Name())
    end
end

--- Checks if the required reagents for a given spell are available.
--- @param spell MQSpell The name of the spell to check for reagents.
--- @return boolean True if the required reagents are available, false otherwise.
function RGMercUtils.ReagentCheck(spell)
    if not spell or not spell() then return false end

    if spell.ReagentID(1)() > 0 and mq.TLO.FindItemCount(spell.ReagentID(1)())() == 0 then
        RGMercsLogger.log_verbose("Missing Reagent: (%d)", spell.ReagentID(1)())
        return false
    end

    if not RGMercUtils.OnEMU() then
        if spell.NoExpendReagentID(1)() > 0 and mq.TLO.FindItemCount(spell.NoExpendReagentID(1)())() == 0 then
            RGMercsLogger.log_verbose("Missing NoExpendReagent: (%d)", spell.NoExpendReagentID(1)())
            return false
        end
    end

    return true
end

--- Checks if the current environment is EMU (Emulator).
---
--- @return boolean True if the environment is EMU, false otherwise.
function RGMercUtils.OnEMU()
    return (mq.TLO.MacroQuest.BuildName() or ""):lower() == "emu"
end

--- Checks if a given song is currently active.
---
--- @param song MQSpell|MQBuff The name of the song to check.
--- @return boolean Returns true if the song is active, false otherwise.
function RGMercUtils.SongActive(song)
    if not song or not song() then return false end

    if mq.TLO.Me.Song(song.Name())() then return true end
    if mq.TLO.Me.Song(song.RankName.Name())() then return true end

    return false
end

--- Checks if a song is active by its name.
---
--- @param songName string The name of the song to check.
--- @return boolean True if the song is active, false otherwise.
function RGMercUtils.SongActiveByName(songName)
    if not songName then return false end
    if type(songName) ~= "string" then
        RGMercsLogger.log_error("\arRGMercUtils.SongActive was passed a non-string songname! %s", type(songName))
        return false
    end
    return ((mq.TLO.Me.Song(songName).ID() or 0) > 0)
end

--- Checks if a specific buff (spell) is currently active by its spell object
--- @param spell MQSpell spell object to check
--- @return boolean True if active, false otherwise.
function RGMercUtils.BuffActive(spell)
    if not spell or not spell() then return false end
    return RGMercUtils.TargetHasBuff(spell, mq.TLO.Me)
end

--- Checks if a specific buff (spell) is currently active by its name
--- @param buffName string name of the buff spell
--- @return boolean True if active, false otherwise.
function RGMercUtils.BuffActiveByName(buffName)
    if not buffName or buffName:len() == 0 then return false end
    if type(buffName) ~= "string" then
        RGMercsLogger.log_error("\arRGMercUtils.BuffActiveByName was passed a non-string buffname! %s", type(buffName))
        return false
    end
    return RGMercUtils.BuffActive(mq.TLO.Spell(buffName))
end

--- Checks if a specific buff (spell) is currently active.
--- @param buffId number The id of the spell to check.
--- @return boolean True if the buff is active, false otherwise.
function RGMercUtils.BuffActiveByID(buffId)
    if not buffId then return false end
    return RGMercUtils.BuffActive(mq.TLO.Spell(buffId))
end

--- Checks if an aura is active by its name.
--- @param auraName string The name of the aura to check.
--- @return boolean True if the aura is active, false otherwise.
function RGMercUtils.AuraActiveByName(auraName)
    if not auraName then return false end
    local auraOne = string.find(mq.TLO.Me.Aura(1)() or "", auraName) ~= nil
    local auraTwo = string.find(mq.TLO.Me.Aura(2)() or "", auraName) ~= nil
    local stripName = string.gsub(auraName, "'", "")

    auraOne = auraOne or string.find(mq.TLO.Me.Aura(1)() or "", stripName) ~= nil
    auraTwo = auraTwo or string.find(mq.TLO.Me.Aura(2)() or "", stripName) ~= nil

    return auraOne or auraTwo
end

--- DetGOMCheck performs a check if Gift of Mana is active
--- This function does not take any parameters.
---
--- @return boolean
function RGMercUtils.DetGOMCheck()
    local me = mq.TLO.Me
    return me.Song("Gift of Mana").ID() ~= nil
end

--- DetGambitCheck performs a check for a specific gambit condition.
--- This function is part of the RGMercUtils module.
--- @return boolean Returns true if the gambit condition is met, false otherwise.
function RGMercUtils.DetGambitCheck()
    local me = mq.TLO.Me
    local gambitSpell = RGMercModules:ExecModule("Class", "GetResolvedActionMapItem", "GambitSpell")

    return (gambitSpell and gambitSpell() and ((me.Song(gambitSpell.RankName.Name()).ID() or 0) > 0)) and true or false
end

--- Determines if the player is facing the target.
--- @return boolean True if the player is facing the target, false otherwise.
function RGMercUtils.FacingTarget()
    if mq.TLO.Target.ID() == 0 then return true end

    return math.abs(mq.TLO.Target.HeadingTo.DegreesCCW() - mq.TLO.Me.Heading.DegreesCCW()) <= 20
end

--- Checks if the detrimental Alternate Advancement (AA) ability should be used.
--- @param aaId number The ID of the AA ability to check.
--- @return boolean True if the AA ability should be used, false otherwise.
function RGMercUtils.DetAACheck(aaId)
    if RGMercUtils.GetTargetID() == 0 then return false end
    local me = mq.TLO.Me

    return (not RGMercUtils.TargetHasBuff(me.AltAbility(aaId).Spell) and
        RGMercUtils.SpellStacksOnTarget(me.AltAbility(aaId).Spell))
end

--- Finds all missing spells from the given ability sets.
---
--- @param abilitySets table A table containing sets of abilities to check.
--- @param highestOnly boolean If true, only the highest level missing spells will be returned.
--- @return table A table containing the missing spells.
function RGMercUtils.FindAllMissingSpells(abilitySets, highestOnly)
    local missingSpellList = {}

    for varName, spellTable in pairs(abilitySets) do
        missingSpellList = RGMercUtils.FindMissingSpells(varName, spellTable, missingSpellList, highestOnly)
    end

    return missingSpellList
end

--- Sets the loadout for a caller, including spell gems, item sets, and ability sets.
--- @param caller any The entity that is calling the function.
--- @param spellGemList table A list of spell gems to be set.
--- @param itemSets table A list of item sets to be equipped.
--- @param abilitySets table A list of ability sets to be configured.
function RGMercUtils.SetLoadOut(caller, spellGemList, itemSets, abilitySets)
    local spellLoadOut = {}
    local resolvedActionMap = {}
    local spellsToLoad = {}

    RGMercUtils.UseGem = mq.TLO.Me.NumGems()

    -- Map AbilitySet Items and Load Them
    for unresolvedName, itemTable in pairs(itemSets) do
        RGMercsLogger.log_debug("Finding best item for Set: %s", unresolvedName)
        resolvedActionMap[unresolvedName] = RGMercUtils.GetBestItem(itemTable)
    end

    local sortedAbilitySets = {}
    for unresolvedName, _ in pairs(abilitySets) do
        table.insert(sortedAbilitySets, unresolvedName)
    end
    table.sort(sortedAbilitySets)

    for _, unresolvedName in pairs(sortedAbilitySets) do
        local spellTable = abilitySets[unresolvedName]
        RGMercsLogger.log_debug("\ayFinding best spell for Set: \am%s", unresolvedName)
        resolvedActionMap[unresolvedName] = RGMercUtils.GetBestSpell(spellTable, resolvedActionMap)
    end

    -- Allow a callback fn for generating spell loadouts rather than a static list
    -- Can be used by bards to prioritize loadouts based on user choices
    if spellGemList and spellGemList.getSpellCallback and type(spellGemList.getSpellCallback) == "function" then
        spellGemList = spellGemList.getSpellCallback()
    end

    local curGem = 1

    for _, g in ipairs(spellGemList or {}) do
        local gem = g.gem
        if spellGemList.CollapseGems then
            gem = curGem
        end

        if RGMercUtils.SafeCallFunc(string.format("Gem Condition Check %d", gem), g.cond, caller, gem) then
            RGMercsLogger.log_debug("\ayGem \am%d\ay will be loaded.", gem)

            if g ~= nil and g.spells ~= nil then
                for _, s in ipairs(g.spells) do
                    if s.name_func then
                        s.name = RGMercUtils.SafeCallFunc("Spell Name Func", s.name_func, caller) or
                            "Error in name_func!"
                    end
                    local spellName = s.name
                    RGMercsLogger.log_debug("\aw  ==> Testing \at%s\aw for Gem \am%d", spellName, gem)
                    if abilitySets[spellName] == nil then
                        -- this means we put a varname into our spell table that we didn't define in the ability list.
                        RGMercsLogger.log_error(
                            "\ar ***!!!*** \awLoadout Var [\at%s\aw] has no entry in the AbilitySet list! \arThis is a bug in the class config please report this!",
                            spellName)
                    end
                    local bestSpell = resolvedActionMap[spellName]
                    if bestSpell then
                        local bookSpell = mq.TLO.Me.Book(bestSpell.RankName())()
                        local pass = RGMercUtils.SafeCallFunc(
                            string.format("Spell Condition Check: %s", bestSpell() or "None"), s.cond, caller, bestSpell)
                        local loadedSpell = spellsToLoad[bestSpell.RankName()] or false

                        if pass and bestSpell and bookSpell and not loadedSpell then
                            RGMercsLogger.log_debug("    ==> \ayGem \am%d\ay will load \at%s\ax ==> \ag%s", gem, s
                                .name, bestSpell.RankName())
                            spellLoadOut[gem] = { selectedSpellData = s, spell = bestSpell, }
                            spellsToLoad[bestSpell.RankName()] = true
                            curGem = curGem + 1
                            break
                        else
                            RGMercsLogger.log_debug(
                                "    ==> \ayGem \am%d will \arNOT\ay load \at%s (pass=%s, bestSpell=%s, bookSpell=%d, loadedSpell=%s)",
                                gem, s.name,
                                RGMercUtils.BoolToColorString(pass), bestSpell and bestSpell.RankName() or "", bookSpell or -1,
                                RGMercUtils.BoolToColorString(loadedSpell))
                        end
                    else
                        RGMercsLogger.log_debug(
                            "    ==> \ayGem \am%d\ay will \arNOT\ay load \at%s\ax ==> \arNo Resolved Spell!", gem,
                            s.name)
                    end
                end
            else
                RGMercsLogger.log_debug("    ==> No Resolved Spell! class file not configured properly")
            end
        else
            RGMercsLogger.log_debug("\agGem %d will not be loaded.", gem)
        end
    end

    --if #spellLoadOut >= mq.TLO.Me.NumGems() then
    --    RGMercsLogger.log_error(
    --        "\aoYour spell loadout count is the same as your number of gems.")
    --end

    return resolvedActionMap, spellLoadOut
end

--- Retrieves the resolved action map item for a given action.
--- @param action string The action for which to retrieve the resolved map item.
--- @return any The resolved action map item corresponding to the given action.
function RGMercUtils.GetResolvedActionMapItem(action)
    return RGMercModules:ExecModule("Class", "GetResolvedActionMapItem", action)
end

--- Generates a dynamic tooltip for a given spell action.
--- @param action string The action identifier for the spell.
--- @return string The generated tooltip for the spell.
function RGMercUtils.GetDynamicTooltipForSpell(action)
    local resolvedItem = RGMercModules:ExecModule("Class", "GetResolvedActionMapItem", action)

    if not resolvedItem or not resolvedItem() then
        return string.format("Use %s Spell : %s\n\nThis Spell:\n%s", action, "None", "None")
    end

    return string.format("Use %s Spell : %s\n\nThis Spell:\n%s", action, resolvedItem() or "None",
        resolvedItem.Description() or "None")
end

--- Generates a dynamic tooltip for a given action.
--- @param action string The action for which the tooltip is generated.
--- @return string The generated tooltip for the specified action.
function RGMercUtils.GetDynamicTooltipForAA(action)
    local resolvedItem = mq.TLO.Spell(action)

    return string.format("Use %s Spell : %s\n\nThis Spell:\n%s", action, resolvedItem() or "None",
        resolvedItem.Description() or "None")
end

--- Get the con color based on the provided color value.
--- @param color string The color value to determine the con color.
--- @return number, number, number, number The corresponding con color in RGBA format
function RGMercUtils.GetConColor(color)
    if color then
        if color:lower() == "dead" then
            return 0.4, 0.4, 0.4, 0.8
        end

        if color:lower() == "grey" then
            return 0.6, 0.6, 0.6, 0.8
        end

        if color:lower() == "green" then
            return 0.02, 0.8, 0.2, 0.8
        end

        if color:lower() == "light blue" then
            return 0.02, 0.8, 1.0, 0.8
        end

        if color:lower() == "blue" then
            return 0.02, 0.4, 1.0, 1.0
        end

        if color:lower() == "yellow" then
            return 0.8, 0.8, 0.02, 0.8
        end

        if color:lower() == "red" then
            return 0.8, 0.2, 0.2, 0.8
        end
    end

    return 1.0, 1.0, 1.0, 1.0
end

--- @param spawn MQSpawn The spawn object for which to determine the con color.
--- @return number, number, number, number The con color associated with the given spawn in RGBA format.
function RGMercUtils.GetConColorBySpawn(spawn)
    if not spawn or not spawn or spawn.Dead() then return RGMercUtils.GetConColor("Dead") end

    return RGMercUtils.GetConColor(spawn.ConColor())
end

--- Checks if navigation is enabled for a given location.
--- @param loc string The location to check, represented as a string with coordinates.
function RGMercUtils.NavEnabledLoc(loc)
    ImGui.PushStyleColor(ImGuiCol.Text, 0.690, 0.553, 0.259, 1)
    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.33, 0.33, 0.33, 0.5)
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.0, 0.66, 0.33, 0.5)
    local navLoc = ImGui.Selectable(loc, false, ImGuiSelectableFlags.AllowDoubleClick)
    ImGui.PopStyleColor(3)
    if loc ~= "0,0,0" then
        if navLoc and ImGui.IsMouseDoubleClicked(0) then
            RGMercUtils.DoCmd('/nav locYXZ %s', loc)
        end

        RGMercUtils.Tooltip("Double click to Nav")
    end
end

--- Generates a tooltip with the given description.
--- @param desc string: The description to be displayed in the tooltip.
function RGMercUtils.Tooltip(desc)
    ImGui.SameLine()
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 25.0)
        if type(desc) == "function" then
            ImGui.Text(desc())
        else
            ImGui.Text(desc)
        end
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

--- Adds an OA (Outside Assist) with the given name.
--- @param name string: The name of the OA to be added.
function RGMercUtils.AddOA(name)
    for _, cur_name in ipairs(RGMercUtils.GetSetting('OutsideAssistList') or {}) do
        if cur_name == name then
            return
        end
    end

    table.insert(RGMercUtils.GetSetting('OutsideAssistList'), name)
    RGMercConfig:SaveSettings(false)
end

--- Deletes the OA with the given ID
--- @param name string The name of the OA to delete
function RGMercUtils.DeleteOAByName(name)
    for idx, cur_name in ipairs(RGMercUtils.GetSetting('OutsideAssistList') or {}) do
        if cur_name == name then
            RGMercUtils.DeleteOA(idx)
            return
        end
    end
end

--- Deletes the OA with the given ID
--- @param idx number The ID of the OA to delete
function RGMercUtils.DeleteOA(idx)
    if idx <= #RGMercUtils.GetSetting('OutsideAssistList') then
        RGMercsLogger.log_info("\axOutside Assist \at%d\ax \ag%s\ax - \arDeleted!\ax", idx,
            RGMercUtils.GetSetting('OutsideAssistList')[idx])
        table.remove(RGMercUtils.GetSetting('OutsideAssistList'), idx)
        RGMercConfig:SaveSettings(false)
    else
        RGMercsLogger.log_error("\ar%d is not a valid OA ID!", idx)
    end
end

--- Moves the OA with the given ID up.
--- @param id number The ID of the OA to move up.
function RGMercUtils.MoveOAUp(id)
    local newId = id - 1

    if newId < 1 then return end
    if id > #RGMercUtils.GetSetting('OutsideAssistList') then return end

    RGMercUtils.GetSetting('OutsideAssistList')[newId], RGMercUtils.GetSetting('OutsideAssistList')[id] =
        RGMercUtils.GetSetting('OutsideAssistList')[id], RGMercUtils.GetSetting('OutsideAssistList')[newId]

    RGMercConfig:SaveSettings(false)
end

function RGMercUtils.MoveOADown(id)
    local newId = id + 1

    if id < 1 then return end
    if newId > #RGMercUtils.GetSetting('OutsideAssistList') then return end

    RGMercUtils.GetSetting('OutsideAssistList')[newId], RGMercUtils.GetSetting('OutsideAssistList')[id] =
        RGMercUtils.GetSetting('OutsideAssistList')[id], RGMercUtils.GetSetting('OutsideAssistList')[newId]

    RGMercConfig:SaveSettings(false)
end

--- Renders the OA (Outside Assist) list.
--- This function is responsible for displaying the list of Outside Assist names
--- It does not take any parameters and does not return any values.
function RGMercUtils.RenderOAList()
    if mq.TLO.Target.ID() > 0 then
        ImGui.PushID("##_small_btn_create_oa")
        if ImGui.SmallButton("Add Target as OA") then
            RGMercUtils.AddOA(mq.TLO.Target.DisplayName())
        end
        ImGui.PopID()
    end
    if ImGui.BeginTable("OAList Nameds", 5, ImGuiTableFlags.None + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)

        ImGui.TableSetupColumn('ID', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 140.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 40.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthStretch), 150.0)
        ImGui.TableSetupColumn('Controls', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, name in ipairs(RGMercUtils.GetSetting('OutsideAssistList') or {}) do
            local spawn = mq.TLO.Spawn(string.format("PC =%s", name))
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            ImGui.TableNextColumn()
            local _, clicked = ImGui.Selectable(name, false)
            if clicked then
                RGMercUtils.SetTarget(spawn.ID() or 0, false)
            end
            ImGui.TableNextColumn()
            if spawn() and spawn.ID() > 0 then
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 1.0)
                ImGui.Text(tostring(math.ceil(spawn.Distance())))
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                RGMercUtils.NavEnabledLoc(spawn.LocYXZ() or "0,0,0")
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                ImGui.Text("0")
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                ImGui.Text("0")
            end
            ImGui.TableNextColumn()
            ImGui.PushID("##_small_btn_delete_oa_" .. tostring(idx))
            if ImGui.SmallButton(RGMercIcons.FA_TRASH) then
                RGMercUtils.DeleteOA(idx)
            end
            ImGui.PopID()
            ImGui.SameLine()
            ImGui.PushID("##_small_btn_up_oa_" .. tostring(idx))
            if idx == 1 then
                ImGui.InvisibleButton(RGMercIcons.FA_CHEVRON_UP, ImVec2(22, 1))
            else
                if ImGui.SmallButton(RGMercIcons.FA_CHEVRON_UP) then
                    RGMercUtils.MoveOAUp(idx)
                end
            end
            ImGui.PopID()
            ImGui.SameLine()
            ImGui.PushID("##_small_btn_dn_oa_" .. tostring(idx))
            if idx == #RGMercUtils.GetSetting('OutsideAssistList') then
                ImGui.InvisibleButton(RGMercIcons.FA_CHEVRON_DOWN, ImVec2(22, 1))
            else
                if ImGui.SmallButton(RGMercIcons.FA_CHEVRON_DOWN) then
                    RGMercUtils.MoveOADown(idx)
                end
            end
            ImGui.PopID()
        end

        ImGui.EndTable()
    end
end

--- Caches the named list in the zone
function RGMercUtils.RefreshNamedCache()
    if RGMercUtils.LastZoneID ~= mq.TLO.Zone.ID() then
        RGMercUtils.LastZoneID = mq.TLO.Zone.ID()
        RGMercUtils.NamedList = {}
        local zoneName = mq.TLO.Zone.Name():lower()

        for _, n in ipairs(RGMercNameds[zoneName] or {}) do
            RGMercUtils.NamedList[n] = true
        end

        zoneName = mq.TLO.Zone.ShortName():lower()

        for _, n in ipairs(RGMercNameds[zoneName] or {}) do
            RGMercUtils.NamedList[n] = true
        end
    end
end

function RGMercUtils.RenderForceTargetList(showPopout)
    if showPopout then
        if ImGui.Button(RGMercIcons.MD_OPEN_IN_NEW, 0, 18) then
            RGMercUtils.SetSetting('PopOutForceTarget', true)
        end
    end

    if ImGui.Button("Clear Forced Target", ImGui.GetWindowWidth() * .3, 18) then
        RGMercConfig.Globals.ForceTargetID = 0
    end

    if ImGui.BeginTable("XTargs", 5, ImGuiTableFlags.None + ImGuiTableFlags.Borders + ImGuiTableFlags.Resizable) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('FT', (ImGuiTableColumnFlags.WidthFixed), 16.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), ImGui.GetWindowWidth() - 300)
        ImGui.TableSetupColumn('HP %', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.TableSetupColumn('Aggro %', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 80.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        local xtCount = mq.TLO.Me.XTarget() or 0

        for i = 1, xtCount do
            local xtarg = mq.TLO.Me.XTarget(i)
            if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater") or RGMercUtils.ForceCombat) then
                ImGui.TableNextColumn()
                if RGMercConfig.Globals.ForceTargetID > 0 and RGMercConfig.Globals.ForceTargetID == xtarg.ID() then
                    ImGui.PushStyleColor(ImGuiCol.Text, IM_COL32(52, 200, math.floor(os.clock() % 2) == 1 and 52 or 200, 255))
                    ImGui.Text(RGMercIcons.MD_STAR)
                    ImGui.PopStyleColor(1)
                else
                    ImGui.Text("")
                end
                ImGui.TableNextColumn()
                ImGui.PushStyleColor(ImGuiCol.Text, RGMercUtils.GetConColorBySpawn(xtarg))
                ImGui.PushID(string.format("##select_forcetarget_%d", i))
                local _, clicked = ImGui.Selectable(xtarg.CleanName() or "None", false)
                if clicked then
                    RGMercConfig.Globals.ForceTargetID = xtarg.ID()
                    RGMercsLogger.log_debug("Forcing Target to: %s %d", xtarg.CleanName(), xtarg.ID())
                end
                ImGui.PopID()
                ImGui.PopStyleColor(1)
                ImGui.TableNextColumn()
                ImGui.Text(tostring(math.ceil(xtarg.PctHPs() or 0)))
                ImGui.TableNextColumn()
                ImGui.Text(tostring(math.ceil(xtarg.PctAggro() or 0)))
                ImGui.TableNextColumn()
                ImGui.Text(tostring(math.ceil(xtarg.Distance() or 0)))
            end
        end

        ImGui.EndTable()
    end
end

function RGMercUtils.CheckNamed()
    RGMercUtils.RefreshNamedCache()

    local tmpTbl = {}
    for name, _ in pairs(RGMercUtils.NamedList) do
        local spawn = mq.TLO.Spawn(string.format("NPC %s", name))
        if RGMercUtils.ShowDownNamed or (spawn() and spawn.ID() > 0) then
            table.insert(tmpTbl, { Name = name, Distance = spawn.Distance() or 9999, Spawn = spawn, })
        end
    end

    table.sort(tmpTbl, function(a, b)
        return a.Distance < b.Distance
    end)
    return tmpTbl
end

--- Renders a table of the named creatures of the current zone.
---
--- This function retrieves and displays the name of the current zone in the game.
---
function RGMercUtils.RenderZoneNamed()
    RGMercUtils.RefreshNamedCache()

    RGMercUtils.ShowDownNamed, _ = RGMercUtils.RenderOptionToggle("ShowDown", "Show Down Nameds", RGMercUtils.ShowDownNamed)

    if ImGui.BeginTable("Zone Nameds", 4, ImGuiTableFlags.None + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthFixed), 250.0)
        ImGui.TableSetupColumn('Up', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthFixed), 160.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        local namedList = RGMercUtils.CheckNamed()
        for _, named in ipairs(namedList) do
            if RGMercUtils.ShowDownNamed or (named.Spawn() and named.Spawn.ID() > 0) then
                ImGui.TableNextColumn()
                local _, clicked = ImGui.Selectable(named.Name, false)
                if clicked then
                    RGMercUtils.SetTarget(named.Spawn() and named.Spawn.ID() or 0)
                end
                ImGui.TableNextColumn()
                if named.Spawn() and named.Spawn.PctHPs() > 0 then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 1.0)
                    ImGui.Text(RGMercIcons.FA_SMILE_O)
                    ImGui.PopStyleColor()
                    ImGui.TableNextColumn()
                    ImGui.Text(tostring(math.ceil(named.Distance)))
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                    ImGui.Text(RGMercIcons.FA_FROWN_O)
                    ImGui.PopStyleColor()
                    ImGui.TableNextColumn()
                    ImGui.Text("0")
                end
                ImGui.TableNextColumn()
                RGMercUtils.NavEnabledLoc(named.Spawn.LocYXZ() or "0,0,0")
            end
        end

        ImGui.EndTable()
    end
end

--- Draws an inspectable spell icon.
---
--- @param iconID number The ID of the icon to be drawn.
--- @param spell MQSpell The spell data to be used for the icon.
function RGMercUtils.DrawInspectableSpellIcon(iconID, spell)
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

--- Renders the loadout table.
---
--- This function takes a loadout table and renders it in a specific format.
---
--- @param loadoutTable table The table containing loadout information to be rendered.
function RGMercUtils.RenderLoadoutTable(loadoutTable)
    if ImGui.BeginTable("Spells", 5, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Icon', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Gem', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Var Name', (ImGuiTableColumnFlags.WidthFixed), 150.0)
        ImGui.TableSetupColumn('Level', ImGuiTableColumnFlags.None)
        ImGui.TableSetupColumn('Rank Name', ImGuiTableColumnFlags.None)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for gem, loadoutData in pairs(loadoutTable) do
            ImGui.TableNextColumn()
            RGMercUtils.DrawInspectableSpellIcon(loadoutData.spell.SpellIcon(), loadoutData.spell)
            ImGui.TableNextColumn()
            ImGui.Text(tostring(gem))
            ImGui.TableNextColumn()
            ImGui.Text(loadoutData.selectedSpellData.name or "")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(loadoutData.spell.Level()))
            ImGui.TableNextColumn()
            local _, clicked = ImGui.Selectable(loadoutData.spell.RankName())
            if clicked then
                loadoutData.spell.Inspect()
            end
        end

        ImGui.EndTable()
    end
end

--- Renders the rotation table key.
--- This function is responsible for displaying the key for the rotation table.
--- It does not take any parameters and does not return any value.
function RGMercUtils.RenderRotationTableKey()
    if ImGui.BeginTable("Rotation_keys", 2, ImGuiTableFlags.Borders) then
        ImGui.TableNextColumn()
        ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
        ImGui.Text(RGMercIcons.FA_SMILE_O .. ": Active")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
        ImGui.Text(RGMercIcons.MD_CHECK .. ": Will Cast (Coditions Met)")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
        ImGui.Text(RGMercIcons.FA_EXCLAMATION .. ": Cannot Cast")

        ImGui.PopStyleColor()
        ImGui.TableNextColumn()

        ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 1.0, 1.0)
        ImGui.Text(RGMercIcons.MD_CHECK .. ": Will Cast (No Conditions)")

        ImGui.PopStyleColor()
        ImGui.EndTable()
    end
end

--- Renders a rotation table for a given name.
---
--- @param name string: The name associated with the rotation table.
--- @param rotationTable table: The table containing rotation data.
--- @param resolvedActionMap table: A map of resolved actions.
--- @param rotationState number|nil: The current state of the rotation.
--- @param showFailed boolean: Flag to indicate whether to show failed actions.
---
--- @return boolean returns showFailed input
function RGMercUtils.RenderRotationTable(name, rotationTable, resolvedActionMap, rotationState, showFailed)
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

        for idx, entry in ipairs(rotationTable or {}) do
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            if rotationState > 0 then
                ImGui.TableNextColumn()
                ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                if idx == rotationState then
                    ImGui.Text(RGMercIcons.FA_DOT_CIRCLE_O)
                else
                    ImGui.Text("")
                end
                ImGui.PopStyleColor()
            end
            ImGui.TableNextColumn()
            if entry.cond then
                local pass, active = false, false

                if entry.lastRun then
                    pass, active = entry.lastRun.pass, entry.lastRun.active
                end

                if active == true then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                    ImGui.Text(RGMercIcons.FA_SMILE_O)
                elseif pass == true then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                    ImGui.Text(RGMercIcons.MD_CHECK)
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                    ImGui.Text(RGMercIcons.FA_EXCLAMATION)
                end
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 1.0, 1.0)
                ImGui.Text(RGMercIcons.MD_CHECK)
            end
            ImGui.PopStyleColor()
            if entry.tooltip then
                RGMercUtils.Tooltip(entry.tooltip)
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
                    if entry.type:lower() == "spell" then
                        ImGui.Text(entry.name)
                        ImGui.TableNextColumn()
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.6, 0.2, 1.0, 1.0)
                        local _, clicked = ImGui.Selectable(mappedAction.RankName())
                        if clicked then
                            mappedAction.Inspect()
                        end
                        ImGui.PopStyleColor()
                    else
                        ImGui.Text(entry.name)
                        ImGui.TableNextColumn()
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.6, 0.2, 1.0, 1.0)
                        ImGui.Text(mappedAction.Name() or "None")
                        ImGui.PopStyleColor()
                    end
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
                elseif entry.type:lower() == "song" then
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

--- Renders a toggle option in the UI.
--- @param id string: The unique identifier for the toggle option.
--- @param text string: The display text for the toggle option.
--- @param on boolean: The current state of the toggle option (true for on, false for off).
--- @return boolean: state
--- @return boolean: changed
function RGMercUtils.RenderOptionToggle(id, text, on)
    local toggled = false
    local state   = on
    ImGui.PushID(id .. "_togg_btn")

    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1.0, 1.0, 1.0, 0)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 1.0, 1.0, 0)
    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 1.0, 1.0, 0)

    if on then
        ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 0.3, 0.9)
        if ImGui.Button(RGMercIcons.FA_TOGGLE_ON) then
            toggled = true
            state   = false
        end
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 0.8)
        if ImGui.Button(RGMercIcons.FA_TOGGLE_OFF) then
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

--- Renders a progress bar.
--- @param pct number The percentage to fill the progress bar (0-100).
--- @param width number The width of the progress bar.
--- @param height number The height of the progress bar.
function RGMercUtils.RenderProgressBar(pct, width, height)
    local style = ImGui.GetStyle()
    local start_x, start_y = ImGui.GetCursorPos()
    local text = string.format("%d%%", pct * 100)
    local label_x, _ = ImGui.CalcTextSize(text)
    ImGui.ProgressBar(pct, width, height, "")
    local end_x, end_y = ImGui.GetCursorPos()
    ImGui.SetCursorPos(start_x + ((ImGui.GetWindowWidth() / 2) - (style.ItemSpacing.x + math.floor(label_x / 2))),
        start_y + style.ItemSpacing.y)
    ImGui.Text(text)
    ImGui.SetCursorPos(end_x, end_y)
end

--- Renders a numerical option with a specified range and step.
--- @param id string: The identifier for the option.
--- @param text string: The display text for the option.
--- @param cur number: The current value of the option.
--- @param min number: The minimum value of the option.
--- @param max number: The maximum value of the option.
--- @param step number?: The step value for incrementing/decrementing the option.
--- @return number   # input
--- @return boolean  # changed
function RGMercUtils.RenderOptionNumber(id, text, cur, min, max, step)
    ImGui.PushID("##num_spin_" .. id)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.5, 0.5, 0.5, 1.0)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.5, 0.5, 0.5, 0.8)
    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 1.0, 1.0, 0.2)
    ImGui.PushStyleColor(ImGuiCol.FrameBg, 1.0, 1.0, 1.0, 0)
    local input, changed = ImGui.InputInt(text, cur, step, 1, ImGuiInputTextFlags.None)
    ImGui.PopStyleColor(4)
    ImGui.PopID()

    input = tonumber(input) or 0
    if input > max then input = max end
    if input < min then input = min end

    changed = cur ~= input
    return input, changed
end

--- Renders a settings table.
---
--- @param settings table The settings table to render.
--- @param settingNames table A table containing the names of the settings.
--- @param defaults table A table containing the default values for the settings.
--- @param category string The category of the settings.
--- @return table   # settings
--- @return boolean # any_pressed
--- @return boolean # requires_new_loadout
function RGMercUtils.RenderSettingsTable(settings, settingNames, defaults, category)
    local any_pressed           = false
    local new_loadout           = false
    --- @type boolean|nil
    local pressed               = false
    local renderWidth           = 300
    local windowWidth           = ImGui.GetWindowWidth()
    local numCols               = math.max(1, math.floor(windowWidth / renderWidth))

    local settingToDrawIndicies = {}

    for idx, k in ipairs(settingNames) do
        if RGMercUtils.GetSetting('ShowAdvancedOpts') or (defaults[k].ConfigType == nil or defaults[k].ConfigType:lower() == "normal") then
            if defaults[k].Category == category and (defaults[k].Type or "none"):lower() ~= "custom" then
                table.insert(settingToDrawIndicies, idx)
            end
        end
    end

    local settingsCount = #settingToDrawIndicies

    local itemsPerRow = math.ceil(settingsCount / numCols)

    if ImGui.BeginTable("Options_" .. (category), 2 * numCols, ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        for _ = 1, numCols do
            ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthFixed), 150.0)
            ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
        end
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()
        ImGui.TableNextRow()

        if #settingToDrawIndicies > 0 then
            for row = 1, itemsPerRow do
                for col = 1, numCols do
                    ImGui.TableNextColumn()
                    local itemIndex = row + ((col - 1) * itemsPerRow)
                    if itemIndex <= #settingToDrawIndicies then
                        local k = settingNames[settingToDrawIndicies[itemIndex]]
                        ImGui.Text(defaults[k].DisplayName or "None")
                        --ImGui.Text(string.format("%s %d %d + %d", defaults[k].DisplayName or "None", itemIndex, row, ImGui.TableGetColumnIndex() + 1))
                        RGMercUtils.Tooltip(string.format("%s\n\n[Variable: %s]\n[Default: %s]",
                            type(defaults[k].Tooltip) == 'function' and defaults[k].Tooltip() or defaults[k].Tooltip,
                            k,
                            tostring(defaults[k].Default)))
                        ImGui.TableNextColumn()

                        if defaults[k].Type == "Combo" then
                            -- build a combo box.
                            ImGui.PushID("##combo_setting_" .. k)
                            settings[k], pressed = ImGui.Combo("", settings[k], defaults[k].ComboOptions)
                            ImGui.PopID()
                            new_loadout = new_loadout or
                                ((pressed or false) and (defaults[k].RequiresLoadoutChange or false))
                            any_pressed = any_pressed or (pressed or false)
                        elseif defaults[k].Type == "ClickyItem" then
                            -- make a drag and drop target
                            ImGui.PushFont(ImGui.ConsoleFont)
                            local displayCharCount = 11
                            local nameLen = settings[k]:len()
                            local maxStart = (nameLen - displayCharCount) + 1
                            local startDisp = (os.clock() % maxStart) + 1

                            ImGui.PushID(k .. "__btn")
                            if ImGui.SmallButton(nameLen > 0 and settings[k]:sub(startDisp, (startDisp + displayCharCount - 1)) or "[Drop Here]") then
                                if mq.TLO.Cursor() then
                                    settings[k] = mq.TLO.Cursor.Name()
                                    pressed = true
                                end
                            end
                            ImGui.PopID()

                            ImGui.PopFont()
                            if nameLen > 0 then
                                RGMercUtils.Tooltip(settings[k])
                            end

                            ImGui.SameLine()
                            ImGui.PushID(k .. "__clear_btn")
                            if ImGui.SmallButton(RGMercIcons.MD_CLEAR) then
                                settings[k] = ""
                                pressed = true
                            end
                            ImGui.PopID()
                            RGMercUtils.Tooltip(string.format("Drop a new item here to replace\n%s", settings[k]))
                            new_loadout = new_loadout or
                                ((pressed or false) and (defaults[k].RequiresLoadoutChange or false))
                            any_pressed = any_pressed or (pressed or false)
                        elseif defaults[k].Type ~= "Custom" then
                            if type(settings[k]) == 'boolean' then
                                settings[k], pressed = RGMercUtils.RenderOptionToggle(k, "", settings[k])
                                new_loadout = new_loadout or (pressed and (defaults[k].RequiresLoadoutChange or false))
                                any_pressed = any_pressed or pressed
                            elseif type(settings[k]) == 'number' then
                                settings[k], pressed = RGMercUtils.RenderOptionNumber(k, "", settings[k], defaults[k].Min,
                                    defaults[k].Max, defaults[k].Step or 1)
                                new_loadout = new_loadout or (pressed and (defaults[k].RequiresLoadoutChange or false))
                                any_pressed = any_pressed or pressed
                            elseif type(settings[k]) == 'string' then -- display only
                                settings[k], pressed = ImGui.InputText("##" .. k, settings[k])
                                any_pressed = any_pressed or pressed
                                RGMercUtils.Tooltip(settings[k])
                            end
                        end
                    end
                end
                ImGui.TableNextRow()
            end
        end
        ImGui.EndTable()
    end

    return settings, any_pressed, new_loadout
end

--- Renders the settings UI for the RGMercUtils module.
---
--- @param settings table The current settings to be rendered.
--- @param defaults table The default settings to be used as a reference.
--- @param categories table The categories of settings to be displayed.
--- @param hideControls? boolean Whether to hide certain controls in the UI.
--- @param showMainOptions? boolean Whether to show the main options in the UI.
---
--- @return table: settings updated
--- @return boolean: any_pressed was anythign pressed?
--- @return boolean: requires_new_loadout do we require a new loadout?
function RGMercUtils.RenderSettings(settings, defaults, categories, hideControls, showMainOptions)
    local any_pressed = false
    local new_loadout = false

    local settingNames = {}
    for k, _ in pairs(defaults) do
        table.insert(settingNames, k)
    end

    if not hideControls then
        local changed = false

        if showMainOptions then
            RGMercConfig:GetSettings().ShowAllOptionsMain, changed = RGMercUtils.RenderOptionToggle("show_main_all_tog",
                "Show All Module Options", RGMercConfig:GetSettings().ShowAllOptionsMain)
            if changed then
                RGMercConfig:SaveSettings(true)
            end
            ImGui.SameLine()
        end

        changed = false
        RGMercConfig:GetSettings().ShowAdvancedOpts, changed = RGMercUtils.RenderOptionToggle("show_adv_tog",
            "Show Advanced Options", RGMercConfig:GetSettings().ShowAdvancedOpts)
        if changed then
            RGMercConfig:SaveSettings(true)
        end

        RGMercUtils.ConfigFilter = ImGui.InputText("Search Configs", RGMercUtils.ConfigFilter)
    end

    local filteredSettings = {}

    if RGMercUtils.ConfigFilter:len() > 0 then
        for _, k in ipairs(settingNames) do
            local lowerFilter = RGMercUtils.ConfigFilter:lower()
            if k:lower():find(lowerFilter) ~= nil or defaults[k].DisplayName:lower():find(lowerFilter) ~= nil or defaults[k].Category:lower():find(lowerFilter) ~= nil then
                table.insert(filteredSettings, k)
            end
        end
        settingNames = filteredSettings
    end

    table.sort(settingNames,
        function(k1, k2)
            if (defaults[k1].Index ~= nil or defaults[k2].Index ~= nil) and (defaults[k1].Index ~= defaults[k2].Index) then
                return (defaults[k1].Index or 999) < (defaults[k2].Index or 999)
            elseif defaults[k1].Category == defaults[k2].Category then
                return defaults[k1].DisplayName < defaults[k2].DisplayName
            else
                return defaults[k1].Category < defaults[k2].Category
            end
        end)

    local catNames = categories and categories:toList() or { "", }
    table.sort(catNames)

    if ImGui.BeginTabBar("Settings_Categories") then
        for _, c in ipairs(catNames) do
            local shouldShow = false
            for _, k in ipairs(settingNames) do
                if defaults[k].Category == c then
                    if RGMercUtils.GetSetting('ShowAdvancedOpts') or (defaults[k].ConfigType == nil or defaults[k].ConfigType:lower() == "normal") then
                        shouldShow = true
                        break
                    end
                end
            end

            if shouldShow then
                if ImGui.BeginTabItem(c) then
                    local cat_pressed = false

                    settings, cat_pressed, new_loadout = RGMercUtils.RenderSettingsTable(settings, settingNames, defaults, c)
                    any_pressed = any_pressed or cat_pressed
                    ImGui.EndTabItem()
                end
            end
        end
        ImGui.EndTabBar()
    end

    return settings, any_pressed, new_loadout
end

--- Loads a spell loadout for the Character.
--- @param spellLoadOut table The spell loadout to be loaded.
function RGMercUtils.LoadSpellLoadOut(spellLoadOut)
    local selectedRank = ""

    for gem, loadoutData in pairs(spellLoadOut) do
        -- Removing this because using basename doesnt seem to work at all.
        --if mq.TLO.Me.SpellRankCap() > 1 then
        selectedRank = loadoutData.spell.RankName()
        --else
        --    selectedRank = loadoutData.spell.BaseName()
        --end

        if mq.TLO.Me.Gem(gem)() ~= selectedRank then
            RGMercUtils.MemorizeSpell(gem, selectedRank, false, 15000)
        end
    end
end

--- Swaps the current bandolier set to the one specified by the index name.
--- @param indexName string The name of the bandolier set to swap to.
function RGMercUtils.BandolierSwap(indexName)
    if RGMercUtils.GetSetting('UseBandolier') and mq.TLO.Me.Bandolier(indexName).Index() and not mq.TLO.Me.Bandolier(indexName).Active() then
        RGMercUtils.DoCmd("/bandolier activate %s", indexName)
        RGMercsLogger.log_debug("BandolierSwap() Swapping to %s. Current Health: %d", indexName, mq.TLO.Me.PctHPs())
    end
end

--- Checks if the shield is equipped.
--- @return boolean True if the shield is equipped, false otherwise.
function RGMercUtils.ShieldEquipped()
    return mq.TLO.InvSlot("Offhand").Item.Type() and mq.TLO.InvSlot("Offhand").Item.Type() == "Shield"
end

--- Checks if a health is not critically low before a healer performs other actions.
function RGMercUtils.OkayToNotHeal()
    if not RGMercUtils.IsHealing() then return true end

    return RGMercUtils.GetMainAssistPctHPs() > RGMercUtils.GetSetting('BigHealPoint')
end

return RGMercUtils
