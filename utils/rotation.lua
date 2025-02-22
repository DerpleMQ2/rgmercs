local mq         = require('mq')
local Config     = require("utils.config")
local Core       = require("utils.core")
local Logger     = require("utils.logger")
local Casting    = require("utils.casting")
local Strings    = require("utils.strings")
local Targeting  = require("utils.targeting")

local Rotation   = { _version = '1.0', _name = "Rotation", _author = 'Derple', }
Rotation.__index = Rotation

--- Get the best item from a given table.
---
--- This function evaluates the items in the provided table and returns the best item based on predefined criteria.
---
--- @param t table The table containing items to evaluate.
--- @return any The best item from the table.
function Rotation.GetBestItem(t)
    local selectedItem = nil

    for _, i in ipairs(t or {}) do
        if mq.TLO.FindItem("=" .. i)() then
            selectedItem = i
            break
        end
    end

    if selectedItem then
        Logger.log_debug("\agFound\ax %s!", selectedItem)
    else
        Logger.log_debug("\arNo items found for slot!")
    end

    return selectedItem
end

--- Get the best spell from a list of spells.
---
--- This function iterates through a list of spells and determines the best spell based on certain criteria.
---
--- @param spellList table A list of spells to evaluate.
--- @param alreadyResolvedMap table A map of spells that have already been resolved.
--- @return MQSpell|nil The best spell from the list.
function Rotation.GetBestSpell(spellList, alreadyResolvedMap)
    local highestLevel = 0
    local selectedSpell = nil

    for _, spellName in ipairs(spellList or {}) do
        local spell = mq.TLO.Spell(spellName)
        if spell() ~= nil then
            --Logger.log_debug("Found %s level(%d) rank(%s)", s, spell.Level(), spell.RankName())
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
                    --     Comms.PrintGroupMessage(string.format(
                    --         "%s \aw [%s] \ax \ar ! MISSING SPELL ! \ax -- \ag %s \ax -- \aw LVL: %d \ax",
                    --         mq.TLO.Me.CleanName(), spellName,
                    --         spell.RankName.Name(), spell.Level()))
                end
            end
        end -- end if spell nil check
    end

    if selectedSpell then
        Logger.log_debug("\agFound\ax %s level(%d) rank(%s)", selectedSpell.BaseName(), selectedSpell.Level(),
            selectedSpell.RankName())
    else
        Logger.log_debug("\arNo spell found for slot!")
    end

    return selectedSpell
end

--- Executes an entry action for a given caller.
---
--- @param caller any The entity or object that is calling the function.
--- @param entry any The entry action to be executed.
--- @param targetId any The ID of the target for the action.
--- @param resolvedActionMap table A table containing resolved actions.
--- @param bAllowMem boolean A flag indicating whether memory actions are allowed.
--- @return boolean True if exec of entry was successful, false otherwise.
function Rotation.ExecEntry(caller, entry, targetId, resolvedActionMap, bAllowMem)
    local ret = false

    if entry.type == nil then return false end -- bad data.

    local target = mq.TLO.Target

    if target and target() and target.ID() == targetId then
        if target.Mezzed() and target.Mezzed.ID() and not Config:GetSetting('AllowMezBreak') then
            Logger.log_debug("Target is mezzed and not AllowMezBreak --> Not Casting!")
            return false
        end
    end

    -- Run pre-activates
    if entry.pre_activate then
        Logger.log_verbose("Running pre-activate for %s.", entry.name)
        entry.pre_activate(caller, Rotation.GetEntryConditionArg(resolvedActionMap, entry))
    end

    if entry.type:lower() == "item" then
        --Allow us to pass entry names directly for items in addition to Action Map tables
        local itemName = resolvedActionMap[entry.name]
        if not itemName then itemName = entry.name end

        if Casting.ItemReady(itemName) then
            ret = Casting.UseItem(itemName, targetId)
        end
        Logger.log_verbose("Trying to use item %s :: %s", itemName, ret and "\agSuccess" or "\arFailed!")
    end

    -- different from items in that they are configured by the user instead of the class.
    if entry.type:lower() == "clickyitem" then
        local itemName = caller.settings[entry.name]

        if not itemName or itemName:len() == 0 then return false end

        if Casting.ItemReady(itemName) then
            ret = Casting.UseItem(itemName, targetId)
        end
        Logger.log_verbose("Trying to use clickyitem %s :: %s", itemName, ret and "\agSuccess" or "\arFailed!")
    end

    if entry.type:lower() == "spell" then
        local spell = resolvedActionMap[entry.name]

        if not spell or not spell() then return false end

        if Casting.SpellReady(spell, bAllowMem) then
            ret = Casting.UseSpell(spell.RankName(), targetId, bAllowMem, entry.allowDead, entry.overrideWaitForGlobalCooldown, entry.retries)
        end
        Logger.log_verbose("(Spell) Trying to use %s - %s :: %s", entry.name, spell.RankName(), ret and "\agSuccess" or "\arFailed!")
    end

    if entry.type:lower() == "song" then
        local songSpell = resolvedActionMap[entry.name]

        if not songSpell or not songSpell() then return false end

        if Casting.SongReady(songSpell, bAllowMem) then
            ret = Casting.UseSong(songSpell.RankName(), targetId, bAllowMem, entry.retries)
        end
        Logger.log_verbose("(Song) Trying to use %s - %s :: %s", entry.name, songSpell.RankName(), ret and "\agSuccess" or "\arFailed!")
    end

    if entry.type:lower() == "disc" then
        local discSpell = resolvedActionMap[entry.name]

        if not discSpell then return false end

        if Casting.DiscReady(discSpell) then
            ret = Casting.UseDisc(discSpell, targetId)
        end
        Logger.log_verbose("(Disc) Trying to use %s - %s :: %s", entry.name, discSpell.RankName(), ret and "\agSuccess" or "\arFailed!")
    end

    if entry.type:lower() == "aa" then
        if Casting.AAReady(entry.name) then
            ret = Casting.UseAA(entry.name, targetId, entry.allowDead, entry.retries)
        end
        Logger.log_verbose("(AA) Trying to use %s :: %s", entry.name, ret and "\agSuccess" or "\arFailed!")
    end

    if entry.type:lower() == "ability" then
        if Casting.AbilityReady(entry.name, mq.TLO.Spawn(targetId)) then
            ret = Casting.UseAbility(entry.name)
        end
        Logger.log_verbose("(Ability) Trying to use %s :: %s", entry.name, ret and "\agSuccess" or "\arFailed!")
    end

    if entry.type:lower() == "customfunc" then
        if entry.custom_func then
            ret = Core.SafeCallFunc(string.format("Custom Func Entry: %s", entry.name), entry.custom_func, caller, targetId)
        end
        Logger.log_verbose("(Custom Function) Calling %s", entry.name, ret and "\agSuccess" or "\arFailed!")
    end

    if entry.post_activate then
        Logger.log_verbose("Running post-activate for %s.", entry.name)
        entry.post_activate(caller, Rotation.GetEntryConditionArg(resolvedActionMap, entry), ret)
    end

    return ret
end

--- Retrieves the argument for the entry condition from the specified map.
---
--- @param map table The table containing the entry conditions.
--- @param entry table RotationEntry object from class config.
--- @return any The argument associated with the entry condition.
function Rotation.GetEntryConditionArg(map, entry)
    local condArg = map[entry.name] or mq.TLO.Spell(entry.name)
    local entryType = entry.type:lower()
    if (entryType ~= "spell" and entryType ~= "song") and (not condArg or entryType == "aa" or entryType == "ability") then
        condArg = entry.name
    end

    return condArg
end

--- Tests a condition for a given entry.
---
--- @param caller any The entity calling this function.
--- @param resolvedActionMap table The map of resolved actions.
--- @param entry table The RotationEntry to test the condition for.
--- @param targetId any The ID of the target.
--- @return boolean, boolean Returns bool for both check pass and active pass
function Rotation.TestConditionForEntry(caller, resolvedActionMap, entry, targetId)
    local condArg = Rotation.GetEntryConditionArg(resolvedActionMap, entry)
    local condTarg = mq.TLO.Spawn(targetId)
    local pass = false
    local active = false

    if condArg ~= nil then
        local logInfo = string.format(
            "check failed - Entry(\at%s\ay), condArg(\at%s\ay), condTarg(\at%s\ay)", entry.name or "NoName",
            (type(condArg) == 'userdata' and condArg() or condArg) or "None", condTarg.CleanName() or "None")
        pass = Core.SafeCallFunc("Condition " .. logInfo, entry.cond, caller, condArg, condTarg)

        if entry.active_cond then
            active = Core.SafeCallFunc("Active " .. logInfo, entry.active_cond, caller, condArg)
        end
    end

    Logger.log_verbose("\ay   :: Testing Condition for entry(%s) type(%s) cond(%s, %s) ==> \ao%s",
        entry.name, entry.type, condArg or "None", condTarg.CleanName() or "None", Strings.BoolToColorString(pass))

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
function Rotation.Run(caller, rotationTable, targetId, resolvedActionMap, steps, start_step, bAllowMem, bDoFullRotation, fnRotationCond)
    local oldSpellInSlot = mq.TLO.Me.Gem(Casting.UseGem)
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

            if Config.Globals.PauseMain then
                break
            end

            if fnRotationCond then
                local curState = Targeting.GetXTHaterCount() > 0 and "Combat" or "Downtime"

                if not Core.SafeCallFunc("\tRotation Condition Loop Re-Check", fnRotationCond, caller, curState) then
                    Logger.log_verbose("\arStopping Rotation Due to condition check failure!")
                    break
                end
            end

            if Config.ShouldPriorityFollow() then
                break
            end

            Logger.log_verbose("\aoDoing RunRotation(start(%d), step(%d), cur(%d))", start_step, steps, idx)
            lastStepIdx = idx
            if entry.cond then
                local pass = Rotation.TestConditionForEntry(caller, resolvedActionMap, entry, targetId)
                Logger.log_verbose("\aoDoing RunRotation(start(%d), step(%d), cur(%d)) :: TestConditionsForEntry() => %s", start_step, steps,
                    idx, Strings.BoolToColorString(pass))
                if pass == true then
                    local res = Rotation.ExecEntry(caller, entry, targetId, resolvedActionMap, bAllowMem)
                    Logger.log_verbose("\aoDoing RunRotation(start(%d), step(%d), cur(%d)) :: ExecEntry() => %s", start_step, steps,
                        idx, Strings.BoolToColorString(res))
                    if res == true then
                        anySuccess = true
                        stepsThisTime = stepsThisTime + 1

                        if steps > 0 and stepsThisTime >= steps then
                            break
                        end

                        if Config.Globals.PauseMain then
                            break
                        end
                    end
                else
                    Logger.log_verbose("\aoFailed Condition RunRotation(start(%d), step(%d), cur(%d))", start_step, steps, idx)
                end
            else
                local res = Rotation.ExecEntry(caller, entry, targetId, resolvedActionMap, bAllowMem)
                if res == true then
                    stepsThisTime = stepsThisTime + 1

                    if steps > 0 and stepsThisTime >= steps then
                        break
                    end
                end
            end
        end
    end

    if Config:GetSetting('RememLastSlot') and Targeting.GetXTHaterCount() == 0 and oldSpellInSlot() and mq.TLO.Me.Gem(Casting.UseGem)() ~= oldSpellInSlot.Name() then
        Logger.log_debug("\ayRestoring %s in slot %d", oldSpellInSlot, Casting.UseGem)
        Casting.MemorizeSpell(Casting.UseGem, oldSpellInSlot.Name(), false, 15000)
    end

    -- Move to the next step
    lastStepIdx = lastStepIdx + 1

    if lastStepIdx > #rotationTable then
        lastStepIdx = 1
    end

    Logger.log_verbose("Ended RunRotation(step(%d), start_step(%d), next(%d))", steps, (start_step or -1),
        lastStepIdx)

    return lastStepIdx, anySuccess
end

--- Sets the loadout for a caller, including spell gems, item sets, and ability sets.
--- @param caller any The entity that is calling the function.
--- @param spellGemList table A list of spell gems to be set.
--- @param itemSets table A list of item sets to be equipped.
--- @param abilitySets table A list of ability sets to be configured.
function Rotation.SetLoadOut(caller, spellGemList, itemSets, abilitySets)
    local spellLoadOut = {}
    local resolvedActionMap = {}
    local spellsToLoad = {}

    Casting.UseGem = mq.TLO.Me.NumGems()

    -- Map AbilitySet Items and Load Them
    for unresolvedName, itemTable in pairs(itemSets) do
        Logger.log_debug("Finding best item for Set: %s", unresolvedName)
        resolvedActionMap[unresolvedName] = Rotation.GetBestItem(itemTable)
    end

    local sortedAbilitySets = {}
    for unresolvedName, _ in pairs(abilitySets) do
        table.insert(sortedAbilitySets, unresolvedName)
    end
    table.sort(sortedAbilitySets)

    for _, unresolvedName in pairs(sortedAbilitySets) do
        local spellTable = abilitySets[unresolvedName]
        Logger.log_debug("\ayFinding best spell for Set: \am%s", unresolvedName)
        resolvedActionMap[unresolvedName] = Rotation.GetBestSpell(spellTable, resolvedActionMap)
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

        if Core.SafeCallFunc(string.format("Gem Condition Check %d", gem), g.cond, caller, gem) then
            Logger.log_debug("\ayGem \am%d\ay will be loaded.", gem)

            if g ~= nil and g.spells ~= nil then
                for _, s in ipairs(g.spells) do
                    if s.name_func then
                        s.name = Core.SafeCallFunc("Spell Name Func", s.name_func, caller) or
                            "Error in name_func!"
                    end
                    local spellName = s.name
                    Logger.log_debug("\aw  ==> Testing \at%s\aw for Gem \am%d", spellName, gem)
                    if abilitySets[spellName] == nil then
                        -- this means we put a varname into our spell table that we didn't define in the ability list.
                        Logger.log_error(
                            "\ar ***!!!*** \awLoadout Var [\at%s\aw] has no entry in the AbilitySet list! \arThis is a bug in the class config please report this!",
                            spellName)
                    end
                    local bestSpell = resolvedActionMap[spellName]
                    if bestSpell then
                        local bookSpell = mq.TLO.Me.Book(bestSpell.RankName())()
                        local pass = Core.SafeCallFunc(
                            string.format("Spell Condition Check: %s", bestSpell() or "None"), s.cond, caller, bestSpell)
                        local loadedSpell = spellsToLoad[bestSpell.RankName()] or false

                        if pass and bestSpell and bookSpell and not loadedSpell then
                            Logger.log_debug("    ==> \ayGem \am%d\ay will load \at%s\ax ==> \ag%s", gem, s
                                .name, bestSpell.RankName())
                            spellLoadOut[gem] = { selectedSpellData = s, spell = bestSpell, }
                            spellsToLoad[bestSpell.RankName()] = true
                            curGem = curGem + 1
                            break
                        else
                            Logger.log_debug(
                                "    ==> \ayGem \am%d will \arNOT\ay load \at%s (pass=%s, bestSpell=%s, bookSpell=%d, loadedSpell=%s)",
                                gem, s.name,
                                Strings.BoolToColorString(pass), bestSpell and bestSpell.RankName() or "", bookSpell or -1,
                                Strings.BoolToColorString(loadedSpell))
                        end
                    else
                        Logger.log_debug(
                            "    ==> \ayGem \am%d\ay will \arNOT\ay load \at%s\ax ==> \arNo Resolved Spell!", gem,
                            s.name)
                    end
                end
            else
                Logger.log_debug("    ==> No Resolved Spell! class file not configured properly")
            end
        else
            Logger.log_debug("\agGem %d will not be loaded.", gem)
        end
    end

    return resolvedActionMap, spellLoadOut
end

--- Loads a spell loadout for the Character.
--- @param spellLoadOut table The spell loadout to be loaded.
function Rotation.LoadSpellLoadOut(spellLoadOut)
    local selectedRank = ""

    for gem, loadoutData in pairs(spellLoadOut) do
        -- Removing this because using basename doesnt seem to work at all.
        --if mq.TLO.Me.SpellRankCap() > 1 then
        selectedRank = loadoutData.spell.RankName()
        --else
        --    selectedRank = loadoutData.spell.BaseName()
        --end

        if mq.TLO.Me.Gem(gem)() ~= selectedRank then
            Casting.MemorizeSpell(gem, selectedRank, false, 15000)
        end
    end
end

--- Finds missing spells from a given spell list.
---
--- @param varName string: The name of the variable to check for missing spells.
--- @param spellList table: A table containing the list of spells to check.
--- @param alreadyMissingSpells table: A table to store spells that are already missing.
--- @param highestOnly boolean: A flag indicating whether to only consider the highest level spells.
--- @return table: A table containing the missing spells.
function Rotation.FindMissingSpells(varName, spellList, alreadyMissingSpells, highestOnly)
    local tmpTable = {}
    for _, spellName in ipairs(spellList or {}) do
        local spell = mq.TLO.Spell(spellName)
        if spell() ~= nil then
            --Logger.log_debug("Found %s level(%d) rank(%s)", s, spell.Level(), spell.RankName())
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
                Logger.log_debug("Set[%s] : Spell[%s (%d)] : Have[%s]", data.selectedSpellData.name, data.spell.RankName(), data.spell.Level(),
                    Strings.BoolToColorString(not data.missing))
                if data.missing then
                    table.insert(alreadyMissingSpells, data)
                end
            end
        else
            table.sort(tmpTable, function(a, b) return a.spell.Level() > b.spell.Level() end)
            for _, data in ipairs(tmpTable) do
                Logger.log_debug("Set[%s] : Spell[%s (%d)]: Have[%s]", data.selectedSpellData.name, data.spell.RankName(), data.spell.Level(),
                    Strings.BoolToColorString(not data.missing))
            end
            if tmpTable[1].missing then
                table.insert(alreadyMissingSpells, tmpTable[1])
            end
        end
    end

    return alreadyMissingSpells
end

--- Finds all missing spells from the given ability sets.
---
--- @param abilitySets table A table containing sets of abilities to check.
--- @param highestOnly boolean If true, only the highest level missing spells will be returned.
--- @return table A table containing the missing spells.
function Rotation.FindAllMissingSpells(abilitySets, highestOnly)
    local missingSpellList = {}

    for varName, spellTable in pairs(abilitySets) do
        missingSpellList = Rotation.FindMissingSpells(varName, spellTable, missingSpellList, highestOnly)
    end

    return missingSpellList
end

return Rotation
