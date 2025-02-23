local mq              = require('mq')
local Config          = require('utils.config')
local Strings         = require("utils.strings")
local Core            = require("utils.core")
local Modules         = require("utils.modules")
local Comms           = require("utils.comms")
local Targeting       = require("utils.targeting")
local DanNet          = require('lib.dannet.helpers')
local Logger          = require("utils.logger")

local Casting         = { _version = '1.0', _name = "Casting", _author = 'Derple', }
Casting.__index       = Casting
Casting.Memorizing    = false

-- cached for UI display
Casting.LastBurnCheck = false
Casting.UseGem        = mq.TLO.Me.NumGems()

--- Checks if the target has a specific buff.
--- @param spell MQSpell The name of the spell to check for.
--- @param buffTarget MQTarget|MQSpawn|MQCharacter? The target to check for the buff.
--- @return boolean Returns true if the target has the buff, false otherwise.
function Casting.TargetHasBuff(spell, buffTarget)
    --- @type target|spawn|character|fun():string|nil
    local target = mq.TLO.Target

    if buffTarget ~= nil and buffTarget.ID() > 0 then
        target = mq.TLO.Me.ID() == buffTarget.ID() and mq.TLO.Me or buffTarget
    end

    if not spell or not spell() then
        Logger.log_verbose("TargetHasBuff(): spell is invalid!")
        return false
    end
    if not target or not target() then
        Logger.log_verbose("TargetHasBuff(): target is invalid!")
        return false
    end

    -- If target is me then don't eat the cost of checking against DanNet.
    if mq.TLO.Me.ID() ~= target.ID() then
        local peerCheck = Casting.PeerHasBuff(spell, target.CleanName())
        if peerCheck ~= nil then return peerCheck end
    end

    if mq.TLO.Me.ID() ~= target.ID() then
        Targeting.SetTarget(target.ID())
    end

    Logger.log_verbose("TargetHasBuff(): Target Buffs Populated: %s", Strings.BoolToColorString(target.BuffsPopulated()))

    local numEffects = spell.NumEffects()

    local ret = (target.FindBuff("id " .. tostring(spell.ID())).ID() or 0) > 0
    Logger.log_verbose("TargetHasBuff() Searching for spell(%s) ID: %d on %s :: %s", spell.Name(), spell.ID(), target.DisplayName(), Strings.BoolToColorString(ret))
    if ret then return true end

    ret = (target.FindBuff("id " .. tostring(spell.RankName.ID())).ID() or 0) > 0
    Logger.log_verbose("TargetHasBuff() Searching for rank spell(%s) ID: %d on %s :: %s", spell.RankName.Name(), spell.RankName.ID(), target.DisplayName(),
        Strings.BoolToColorString(ret))
    if ret then return true end

    for i = 1, numEffects do
        local triggerSpell = spell.Trigger(i)
        if triggerSpell and triggerSpell() then
            ret = (target.FindBuff("id " .. tostring(triggerSpell.ID())).ID() or 0) > 0 --
            Logger.log_verbose("TargetHasBuff() Searching for trigger spell ID: %d on %s :: %s", triggerSpell.ID(), target.DisplayName(), Strings.BoolToColorString(ret))
            if ret then return true end

            ret = (target.FindBuff("id " .. tostring(triggerSpell.RankName.ID())).ID() or 0) > 0
            Logger.log_verbose("TargetHasBuff() Searching for trigger rank spell ID: %d on %s :: %s", triggerSpell.ID(), target.DisplayName(),
                Strings.BoolToColorString(ret))
            if ret then return true end
        end
    end

    Logger.log_verbose("TargetHasBuff() Failed to find spell: %s on %s", spell.Name(), target.DisplayName())
    return false
end

--- @param buffName string The name of the buff to check for.
--- @param buffTarget MQTarget|MQSpawn|MQCharacter? The target to check for the buff.
--- @return boolean True if the target has the buff, false otherwise.
function Casting.TargetHasBuffByName(buffName, buffTarget)
    if buffName == nil then return false end
    return Casting.TargetHasBuff(mq.TLO.Spell(buffName), buffTarget)
end

--- Checks if a spell stacks on the target.
--- @param spell MQSpell The name of the spell to check.
--- @return boolean True if the spell stacks on the target, false otherwise.
function Casting.SpellStacksOnTarget(spell)
    local target = mq.TLO.Target

    if not spell or not spell() then return false end
    if not target or not target() then return false end

    local numEffects = spell.NumEffects()

    if not spell.StacksTarget() then return false end

    for i = 1, numEffects do
        local triggerSpell = spell.Trigger(i)
        --Some Laz spells report trigger 1 as "Unknown Spell" with an ID of 0, which always reports false on stack checks
        if triggerSpell and triggerSpell() and triggerSpell.ID() > 0 then
            if not triggerSpell.StacksTarget() then return false end
        end
    end

    return true
end

--- Checks if a given spell stacks on the player.
--- @param spell MQSpell The name of the spell to check.
--- @return boolean True if the spell stacks on the player, false otherwise.
function Casting.SpellStacksOnMe(spell)
    if not spell or not spell() then return false end

    local numEffects = spell.NumEffects()

    if not spell.Stacks() then return false end

    for i = 1, numEffects do
        local triggerSpell = spell.Trigger(i)
        --Some Laz spells report trigger 1 as "Unknown Spell" with an ID of 0, which always reports false on stack checks
        if triggerSpell and triggerSpell() and triggerSpell.ID() > 0 then
            if not triggerSpell.Stacks() then return false end
        end
    end

    return true
end

--- Searches for a specific buff on a peer using DanNet.
---
--- @param peerName string The name of the peer to search for the buff.
--- @param IDs table A table containing the IDs of the buffs to search for.
--- @return boolean Returns true if the buff is found, false otherwise.
function Casting.DanNetFindBuff(peerName, IDs)
    local text = ""
    for _, id in ipairs(IDs) do
        if text ~= "" then
            text = text .. " or "
        end
        text = text .. "ID " .. tostring(id)
    end

    local buffSearch = string.format("Me.FindBuff[%s].ID", text)
    Logger.log_verbose("DanNetFindBuff(%s, %s) : %s", text, peerName, buffSearch)
    return (DanNet.query(peerName, buffSearch, 1000) or "null"):lower() ~= "null"
end

--- Checks if a peer has a specific buff.
--- @param spell MQSpell The name of the spell (buff) to check for.
--- @param peerName string The name of the peer to check.
--- @return boolean|nil True if the peer has the buff, false otherwise.
function Casting.PeerHasBuff(spell, peerName)
    peerName = (peerName or ""):lower()
    local peerFound = (mq.TLO.DanNet.Peers() or ""):lower():find(peerName:lower() .. "|") ~= nil

    if not peerFound then
        Logger.log_verbose("\ayPeerHasBuff() \ayPeer '%s' not found falling back.", peerName)
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
        --Some Laz spells report trigger 1 as "Unknown Spell" with an ID of 0
        if triggerSpell and triggerSpell() and triggerSpell.ID() > 0 and not checkedEffects[triggerSpell.ID()] then
            table.insert(effectsToCheck, triggerSpell.ID())
            if triggerSpell.ID() ~= triggerSpell.RankName.ID() then
                table.insert(effectsToCheck, triggerSpell.RankName.ID())
            end

            checkedEffects[triggerSpell.ID()] = true
        end
    end

    local ret = Casting.DanNetFindBuff(peerName, effectsToCheck)
    Logger.log_verbose("\ayPeerHasBuff() \atSearching for trigger rank spell ID Count: %d on %s :: %s", #effectsToCheck, peerName, Strings.BoolToColorString(ret))
    Logger.log_verbose("\ayPeerHasBuff() \awFinding spell: %s on %s :: %s", spell.Name(), peerName, Strings.BoolToColorString(ret))
    return ret
end

--- Checks if we should be casting buffs.
--- This function checks if we should be casting buffs - Enabled by user and not moving or trying to move or follow..
---
--- @return boolean
function Casting.DoBuffCheck()
    if not Config:GetSetting('DoBuffs') then return false end

    if mq.TLO.Me.Invis() or Config:GetSetting('BuffWaitMoveTimer') > Config:GetTimeSinceLastMove() then return false end

    if Targeting.GetXTHaterCount() > 0 or Config.Globals.AutoTargetID > 0 then return false end

    if (mq.TLO.MoveTo.Moving() or mq.TLO.Me.Moving() or mq.TLO.AdvPath.Following() or mq.TLO.Navigation.Active()) and not Core.MyClassIs("brd") then return false end

    if Config.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and mq.TLO.Me.PctMana() < 10 then return false end

    return true
end

--- Performs a check on the pet status.
--- This function checks various conditions related to the pet.
--- @return boolean Returns true if the pet check is successful, false otherwise.
function Casting.DoPetCheck()
    if not Config:GetSetting('DoPet') then return false end

    if mq.TLO.Me.Invis() or Config:GetSetting('BuffWaitMoveTimer') > Config:GetTimeSinceLastMove() then return false end

    if Targeting.GetXTHaterCount() > 0 or Config.Globals.AutoTargetID > 0 then return false end

    if mq.TLO.MoveTo.Moving() or mq.TLO.Me.Moving() or mq.TLO.AdvPath.Following() or mq.TLO.Navigation.Active() then return false end

    if Config.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and mq.TLO.Me.PctMana() < 10 then return false end

    return true
end

--- Checks if a group buff can be cast on the target.
--- @param spell MQSpell The name of the spell to check.
--- @param target MQSpawn The name of the target to receive the buff.
--- @return boolean Returns true if the buff can be cast, false otherwise.
function Casting.GroupBuffCheck(spell, target, spellID)
    if not spell or not spell() then return false end
    if not target or not target() then return false end
    if not spellID then spellID = spell.RankName.ID() end

    local targetName = target.CleanName() or "None"

    if mq.TLO.DanNet(targetName)() ~= nil then
        local spellName = spell.RankName.Name()
        local spellResult = DanNet.query(targetName, string.format("Me.FindBuff[id %d]", spellID), 1000)
        Logger.log_verbose("\ayGroupBuffCheck() Querying via DanNet for %s(ID:%d) on %s", spellName, spellID, targetName)
        if spellResult == spellName then
            Logger.log_verbose("\atGroupBuffCheck() DanNet detects that %s(ID:%d) is already present on %s, ending.", spellName, spellID, targetName)
            return false
        elseif spellResult == "NULL" then
            Logger.log_verbose("\atGroupBuffCheck() DanNet detects %s(ID:%d) is missing on %s, let's check for triggers.", spellName, spellID, targetName)
            local numEffects = mq.TLO.Spell(spellID).NumEffects()
            local triggerCt = 0
            for i = 1, numEffects do
                local triggerSpell = mq.TLO.Spell(spellID).RankName.Trigger(i)
                --Some Laz spells report trigger 1 as "Unknown Spell" with an ID of 0, which always reports false on stack checks
                if triggerSpell and triggerSpell() and triggerSpell.ID() > 0 then
                    local triggerRankResult = DanNet.query(targetName, string.format("Me.FindBuff[id %d]", triggerSpell.ID()), 1000)
                    --Logger.log_verbose("GroupBuffCheck() DanNet result for trigger %d of %d (%s, %s): %s", i, numEffects, triggerSpell.Name(), triggerSpell.ID(), triggerRankResult)
                    if triggerRankResult == "NULL" then
                        Logger.log_verbose("\ayGroupBuffCheck() DanNet found a missing trigger for %s(ID:%d) on %s, let's check stacking.", triggerSpell.Name(),
                            triggerSpell.ID(), targetName)
                        local triggerStackResult = DanNet.query(targetName, string.format("Spell[%s].Stacks", triggerSpell.Name()), 1000)
                        --Logger.log_verbose("GroupBuffCheck() DanNet result for stacking check of %s (ID:%d) on %s : %s", triggerSpell.Name(), triggerSpell.ID(), targetName, triggerStackResult)
                        if triggerStackResult == "TRUE" then
                            Logger.log_verbose("\ayGroupBuffCheck() %s (ID:%d) seems to stack on %s, let's do it!", triggerSpell.Name(), triggerSpell.ID(), targetName)
                            return true
                        end
                        Logger.log_verbose("\ayGroupBuffCheck() %s(ID:%d) does not stack on %s, moving on.", triggerSpell.Name(), triggerSpell.ID(), targetName)
                    end
                    triggerCt = triggerCt + 1
                else
                    Logger.log_verbose("\ayGroupBuffCheck() DanNet found no valid triggers for %s(ID:%d), let's check stacking.", spellName, spellID)
                end
            end
            if triggerCt >= numEffects then
                Logger.log_verbose("\arGroupBuffCheck() DanNet found %d of %d existing triggers for %s(ID:%d) on %s, ending.", triggerCt, numEffects, spellName, spellID,
                    targetName)
                return false
            end
            local stackResult = DanNet.query(targetName, string.format("Spell[%s].Stacks", spellName), 1000)
            --Logger.log_verbose("GroupBuffCheck() DanNet result for stacking check of %s (ID:%d) on %s : %s", spellName, spellID, targetName, stackResult)
            if stackResult == "TRUE" then
                Logger.log_verbose("\agGroupBuffCheck() %s (ID:%d) seems to stack on %s, let's do it!", spellName, spellID, targetName)
                return true
            end
            Logger.log_verbose("GroupBuffCheck() %s(ID:%d) does not stack on %s, moving on.", spellName, spellID, targetName)
        end
    else
        Targeting.SetTarget(target.ID())
        return not Casting.TargetHasBuff(spell) and Casting.SpellStacksOnTarget(spell)
    end

    return false
end

--- Checks if the given Damage Over Time (DoT) spell can fire.
---
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the DoT spell can fire, false otherwise.
function Casting.DotSpellCheck(spell)
    if not spell or not spell() then return false end
    local named = Targeting.IsNamed(mq.TLO.Target)
    local targethp = Targeting.GetTargetPctHPs()

    return not Casting.TargetHasBuff(spell) and Casting.SpellStacksOnTarget(spell) and
        ((named and (Config:GetSetting('NamedStopDOT') < targethp)) or (Config:GetSetting('HPStopDOT') < targethp))
end

--- DetSpellCheck checks if the detrimental spell can fire.
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell detrimental spell should fire, false otherwise.
function Casting.DetSpellCheck(spell)
    if not spell or not spell() then return false end
    return not Casting.TargetHasBuff(spell) and Casting.SpellStacksOnTarget(spell)
end

--- Checks if the specified AA (Alternate Advancement) ability is available for self-buffing.
--- @param aaName string The name of the AA ability to check.
--- @return boolean Returns true if the AA ability is available for self-buffing, false otherwise.
function Casting.SelfBuffAACheck(aaName)
    local abilityReady = mq.TLO.Me.AltAbilityReady(aaName)()
    local buffNotActive = not Casting.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.ID())
    local triggerNotActive = not Casting.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())
    local auraNotActive = not mq.TLO.Me.Aura(tostring(mq.TLO.Spell(aaName).RankName())).ID()
    local stacks = Casting.SpellStacksOnMe(mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName).Spell.RankName.Name()))
    --local triggerStacks = (not mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID() or mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID() == 0 or mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).Stacks())
    -- trigger is already checked in SpellStacksOnMe, testing.

    Logger.log_verbose("SelfBuffAACheck(%s) abilityReady(%s) buffNotActive(%s) triggerNotActive(%s) auraNotActive(%s) stacks(%s)", aaName, -- triggerStacks(%s)
        Strings.BoolToColorString(abilityReady),
        Strings.BoolToColorString(buffNotActive),
        Strings.BoolToColorString(triggerNotActive),
        Strings.BoolToColorString(auraNotActive),
        Strings.BoolToColorString(stacks))
    --Strings.BoolToColorString(triggerStacks))


    return abilityReady and buffNotActive and triggerNotActive and auraNotActive and stacks -- and triggerStacks
end

--- Checks if a song is active by its name.
---
--- @param songName string The name of the song to check.
--- @return boolean True if the song is active, false otherwise.
function Casting.SongActiveByName(songName)
    if not songName then return false end
    if type(songName) ~= "string" then
        Logger.log_error("\arCasting.SongActive was passed a non-string songname! %s", type(songName))
        return false
    end
    return ((mq.TLO.Me.Song(songName).ID() or 0) > 0)
end

--- Checks if a specific buff (spell) is currently active by its spell object
--- @param spell MQSpell spell object to check
--- @return boolean True if active, false otherwise.
function Casting.BuffActive(spell)
    if not spell or not spell() then return false end
    return Casting.TargetHasBuff(spell, mq.TLO.Me)
end

--- Checks if a specific buff (spell) is currently active by its name
--- @param buffName string name of the buff spell
--- @return boolean True if active, false otherwise.
function Casting.BuffActiveByName(buffName)
    if not buffName or buffName:len() == 0 then return false end
    if type(buffName) ~= "string" then
        Logger.log_error("\arCasting.BuffActiveByName was passed a non-string buffname! %s", type(buffName))
        return false
    end
    return Casting.BuffActive(mq.TLO.Spell(buffName))
end

--- Checks if a specific buff (spell) is currently active.
--- @param buffId number The id of the spell to check.
--- @return boolean True if the buff is active, false otherwise.
function Casting.BuffActiveByID(buffId)
    if not buffId then return false end
    return Casting.BuffActive(mq.TLO.Spell(buffId))
end

--- Checks if an aura is active by its name.
--- @param auraName string The name of the aura to check.
--- @return boolean True if the aura is active, false otherwise.
function Casting.AuraActiveByName(auraName)
    if not auraName then return false end
    local auraOne = string.find(mq.TLO.Me.Aura(1)() or "", auraName) ~= nil
    local auraTwo = string.find(mq.TLO.Me.Aura(2)() or "", auraName) ~= nil
    local stripName = string.gsub(auraName, "'", "")

    auraOne = auraOne or string.find(mq.TLO.Me.Aura(1)() or "", stripName) ~= nil
    auraTwo = auraTwo or string.find(mq.TLO.Me.Aura(2)() or "", stripName) ~= nil

    return auraOne or auraTwo
end

--- Checks if a given song is currently active.
---
--- @param song MQSpell|MQBuff The name of the song to check.
--- @return boolean Returns true if the song is active, false otherwise.
function Casting.SongActive(song)
    if not song or not song() then return false end

    if mq.TLO.Me.Song(song.Name())() then return true end
    if mq.TLO.Me.Song(song.RankName.Name())() then return true end

    return false
end

--- Checks the mana level of the character.
--- This function evaluates the current mana level and performs necessary actions based on the result.
--- @return boolean True if you have more mana than Mana To Nuke false otherwise
function Casting.HaveManaToNuke()
    return mq.TLO.Me.PctMana() >= Config:GetSetting('ManaToNuke')
end

--- Checks the mana status for the character.
--- This function evaluates the current mana level and determines if it meets the required threshold.
--- @return boolean True if the mana level is sufficient, false otherwise.
function Casting.DotHaveManaToNuke()
    return mq.TLO.Me.PctMana() >= Config:GetSetting('ManaToDot')
end

--- Checks the mana status for the character.
--- This function evaluates the current mana level and determines if it meets the required threshold.
--- @return boolean True if the mana level is sufficient, false otherwise.
function Casting.HaveManaToDebuff()
    return mq.TLO.Me.PctMana() >= Config:GetSetting('ManaToDebuff')
end

--- DetGOMCheck performs a check if Gift of Mana is active
--- This function does not take any parameters.
---
--- @return boolean
function Casting.DetGOMCheck()
    local me = mq.TLO.Me
    return me.Song("Gift of Mana").ID() ~= nil
end

--- DetGambitCheck performs a check for a specific gambit condition.
--- @return boolean Returns true if the gambit condition is met, false otherwise.
function Casting.DetGambitCheck()
    local me = mq.TLO.Me
    local gambitSpell = Modules:ExecModule("Class", "GetResolvedActionMapItem", "GambitSpell")

    return (gambitSpell and gambitSpell() and ((me.Song(gambitSpell.RankName.Name()).ID() or 0) > 0)) and true or false
end

--- Checks if the detrimental Alternate Advancement (AA) ability should be used.
--- @param aaId number The ID of the AA ability to check.
--- @return boolean True if the AA ability should be used, false otherwise.
function Casting.DetAACheck(aaId)
    if Targeting.GetTargetID() == 0 then return false end
    local me = mq.TLO.Me

    return (not Casting.TargetHasBuff(me.AltAbility(aaId).Spell) and
        Casting.SpellStacksOnTarget(me.AltAbility(aaId).Spell))
end

--- Checks if the required reagents for a given spell are available.
--- @param spell MQSpell The name of the spell to check for reagents.
--- @return boolean True if the required reagents are available, false otherwise.
function Casting.ReagentCheck(spell)
    if not spell or not spell() then return false end

    if spell.ReagentID(1)() > 0 and mq.TLO.FindItemCount(spell.ReagentID(1)())() == 0 then
        Logger.log_verbose("Missing Reagent: (%d)", spell.ReagentID(1)())
        Comms.HandleAnnounce(
            string.format('I want to cast %s, but I am missing a reagent(%d)!', spell(), spell.ReagentID(1)()),
            Config:GetSetting('ReagentAnnounceGroup'),
            Config:GetSetting('ReagentAnnounce'))
        return false
    end

    if not Core.OnEMU() then
        if spell.NoExpendReagentID(1)() > 0 and mq.TLO.FindItemCount(spell.NoExpendReagentID(1)())() == 0 then
            Logger.log_verbose("Missing NoExpendReagent: (%d)", spell.NoExpendReagentID(1)())
            Comms.HandleAnnounce(
                string.format('I want to cast %s, but I am missing a non-expended reagent(%d)!', spell(), spell.NoExpendReagentID(1)()),
                Config:GetSetting('ReagentAnnounceGroup'),
                Config:GetSetting('ReagentAnnounce'))
            return false
        end
    end

    return true
end

--- Checks if a given Alternate Advancement (AA) ability can be used.
--- @param aaName string The name of the AA ability to check.
--- @return boolean Returns true if the AA ability can be used, false otherwise.
function Casting.CanUseAA(aaName)
    local haveAbility = mq.TLO.Me.AltAbility(aaName)()
    local levelCheck = haveAbility and mq.TLO.Me.AltAbility(aaName).MinLevel() <= mq.TLO.Me.Level()
    local rankCheck = haveAbility and mq.TLO.Me.AltAbility(aaName).Rank() > 0
    Logger.log_super_verbose("CanUseAA(%s): haveAbility(%s) levelCheck(%s) rankCheck(%s)", aaName, Strings.BoolToColorString(haveAbility),
        Strings.BoolToColorString(levelCheck), Strings.BoolToColorString(rankCheck))
    return haveAbility and levelCheck and rankCheck
end

--- Determines if an alliance can be formed.
--- @return boolean True if an alliance can be formed, false otherwise.
function Casting.CanAlliance()
    return true
end

--- Checks if a specific Alternate Advancement (AA) ability is ready to use.
--- @param aaName string The name of the AA ability to check.
--- @return boolean Returns true if the AA ability is ready, false otherwise.
function Casting.AAReady(aaName)
    local canUse = Casting.CanUseAA(aaName)
    local ready = mq.TLO.Me.AltAbilityReady(aaName)()
    local spell = mq.TLO.Me.AltAbility(aaName).Spell
    Logger.log_super_verbose("AAReady(%s): ready(%s) canUse(%s) haveMana(%s) haveEnd(%s)", aaName, Strings.BoolToColorString(ready), Strings.BoolToColorString(canUse),
        Strings.BoolToColorString(mq.TLO.Me.CurrentMana() >= (spell.Mana() or 0)), Strings.BoolToColorString(mq.TLO.Me.CurrentEndurance() >= (spell.EnduranceCost() or 0)))
    return ready and canUse and (mq.TLO.Me.CurrentMana() >= (spell.Mana() or 0) or mq.TLO.Me.CurrentEndurance() >= (spell.EnduranceCost() or 0))
end

--- Checks if a given ability is ready to be used.
--- @param abilityName string The name of the ability to check.
--- @return boolean True if the ability is ready, false otherwise.
function Casting.AbilityReady(abilityName)
    return mq.TLO.Me.AbilityReady(abilityName)()
end

--- Retrieves the rank of a specified Alternate Advancement (AA) ability.
--- @param aaName string The name of the AA ability.
--- @return number The rank of the specified AA ability.
function Casting.AARank(aaName)
    return Casting.CanUseAA(aaName) and mq.TLO.Me.AltAbility(aaName).Rank() or 0
end

--- Checks if the given name corresponds to a discipline.
---
--- @param name string The name to check.
--- @return boolean True if the name is a discipline, false otherwise.
function Casting.IsActiveDisc(name)
    local spell = mq.TLO.Spell(name)

    return (spell() and spell.IsSkill() and spell.Duration.TotalSeconds() > 0 and not spell.StacksWithDiscs() and spell.TargetType():lower() == "self") and
        true or false
end

--- Checks if a player character's spell is ready to be cast.
---
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell is ready, false otherwise.
function Casting.SpellReady(spell)
    if not spell or not spell() then return false end
    local me = mq.TLO.Me

    if me.Stunned() then return false end

    return me.CurrentMana() > spell.Mana() and not me.Casting() and me.Book(spell.RankName.Name())() ~= nil and
        not (me.Moving() and (spell.MyCastTime() or -1) > 0)
end

--- Checks if a given discipline spell is ready to be used by the player character.
--- @param discSpell MQSpell The name of the discipline spell to check.
--- @return boolean Returns true if the discipline spell is ready, false otherwise.
function Casting.DiscReady(discSpell)
    if not discSpell or not discSpell() then return false end
    Logger.log_super_verbose("DiscReady(%s) => CAR(%s)", discSpell.RankName.Name() or "None",
        Strings.BoolToColorString(mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())()))
    return mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())() and mq.TLO.Me.CurrentEndurance() > (discSpell.EnduranceCost() or 0)
end

--- Checks if a given PC discipline spell is ready to be used on the NPC Target.
---
--- @param discSpell MQSpell The name of the discipline spell to check.
--- @return boolean True if the discipline spell is ready, false otherwise.
function Casting.TargetedDiscReady(discSpell)
    if not discSpell or not discSpell() then return false end
    local target = mq.TLO.Target
    if not target or not target() then return false end
    Logger.log_super_verbose("TargetedDiscReady(%s) => CAR(%s)", discSpell.RankName.Name() or "None",
        Strings.BoolToColorString(mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())()))
    return mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())() and
        mq.TLO.Me.CurrentEndurance() > (discSpell.EnduranceCost() or 0) and not Targeting.TargetIsType("corpse", target) and
        target.LineOfSight() and not target.Hovering()
end

--- Checks if an PC spell is ready to be cast on the target NPC.
---
--- @param spellName string The name of the spell to check.
--- @param targetId number? The ID of the target NPC.
--- @param healingSpell boolean? Indicates if the spell is a healing spell.
--- @return boolean Returns true if the spell is ready, false otherwise.
function Casting.TargetedSpellReady(spellName, targetId, healingSpell)
    local me = mq.TLO.Me
    local spell = mq.TLO.Spell(spellName)

    if (targetId == 0 or not targetId) then targetId = mq.TLO.Target.ID() end

    if not spell or not spell() then return false end

    if me.Stunned() then return false end

    local target = mq.TLO.Spawn(targetId)

    if not target or not target() then return false end

    if me.SpellReady(spell.RankName.Name())() and me.CurrentMana() >= spell.Mana() then
        if not (me.Moving() and (spell.MyCastTime() or -1) > 0) and not me.Casting() and not Targeting.TargetIsType("corpse", target) then
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
function Casting.TargetedAAReady(aaName, targetId, healingSpell)
    Logger.log_verbose("TargetedAAReady(%s)", aaName)
    local me = mq.TLO.Me
    local ability = mq.TLO.Me.AltAbility(aaName)

    if targetId == 0 or not targetId then targetId = mq.TLO.Target.ID() end

    if not ability or not ability() then
        Logger.log_verbose("TargetedAAReady(%s) - Don't have ability.", aaName)
        return false
    end

    if me.Stunned() then
        Logger.log_verbose("TargetedAAReady(%s) - Stunned", aaName)
        return false
    end

    local target = mq.TLO.Spawn(string.format("id %d", targetId))

    if not target or not target() or target.Dead() then
        Logger.log_verbose("TargetedAAReady(%s) - Target Dead", aaName)
        return false
    end

    if Casting.AAReady(aaName) and me.CurrentMana() >= ability.Spell.Mana() and me.CurrentEndurance() >= ability.Spell.EnduranceCost() then
        if Core.MyClassIs("brd") or (not me.Moving() and not me.Casting()) then
            Logger.log_verbose("TargetedAAReady(%s) - Check LOS", aaName)
            if target.LineOfSight() then
                Logger.log_verbose("TargetedAAReady(%s) - Success", aaName)
                return true
            elseif healingSpell == true then
                Logger.log_verbose("TargetedAAReady(%s) - Healing Success", aaName)
                return true
            end
        end
    else
        Logger.log_verbose("TargetedAAReady(%s) CurrentMana(%d) >= SpellMana(%d) CurrentEnd(%d) >= SpellEnd(%d)", aaName, me.CurrentMana(), ability.Spell.Mana(),
            me.CurrentEndurance(), ability.Spell.EnduranceCost())
    end

    Logger.log_verbose("TargetedAAReady(%s) - Failed", aaName)
    return false
end

--- Memorizes a spell in the specified gem slot.
--- @param gem number The gem slot number where the spell should be memorized.
--- @param spell string The name of the spell to memorize.
--- @param waitSpellReady boolean Whether to wait until the spell is ready to be memorized.
--- @param maxWait number The maximum time to wait for the spell to be ready, in seconds.
function Casting.MemorizeSpell(gem, spell, waitSpellReady, maxWait)
    Logger.log_info("\ag Meming \aw %s in \ag slot %d", spell, gem)
    Core.DoCmd("/memspell %d \"%s\"", gem, spell)

    Casting.Memorizing = true

    while (mq.TLO.Me.Gem(gem)() ~= spell or (waitSpellReady and not mq.TLO.Me.SpellReady(gem)())) and maxWait > 0 do
        local me = mq.TLO.Me
        Logger.log_debug("\ayWaiting for '%s' to load in slot %d'...", spell, gem)
        if me.CombatState():lower() == "combat" or me.Casting() or me.Moving() or mq.TLO.Stick.Active() or mq.TLO.Navigation.Active() or mq.TLO.MoveTo.Moving() or mq.TLO.AdvPath.Following() then
            Logger.log_debug(
                "I was interrupted while waiting for spell '%s' to load in slot %d'! Aborting. CombatState(%s) Casting(%s) Moving(%s) Stick(%s) Nav(%s) MoveTo(%s) Following(%s))",
                spell, gem, me.CombatState(), me.Casting() or "None", Strings.BoolToColorString(me.Moving()), Strings.BoolToColorString(mq.TLO.Stick.Active()),
                Strings.BoolToColorString(mq.TLO.Navigation.Active()), Strings.BoolToColorString(mq.TLO.MoveTo.Moving()),
                Strings.BoolToColorString(mq.TLO.AdvPath.Following()))
            break
        end
        if not mq.TLO.Me.Book(spell)() then
            Logger.log_debug("I was trying to memorize %s as my persona was changed, aborting.", spell)
            break
        end
        mq.delay(100)
        mq.doevents()
        maxWait = maxWait - 100
    end

    Casting.Memorizing = false
end

--- Checks if a spell is ready to be cast.
---
--- @param spell string The name of the spell to check.
--- @return boolean Returns true if the spell is ready to be cast, false otherwise.
function Casting.CastReady(spell)
    return mq.TLO.Me.SpellReady(spell)()
end

--- Waits for the casting to finish on the specified target.
---
--- @param target MQSpawn The target to wait for the casting to finish.
--- @param bAllowDead boolean Whether to allow the target to be dead.
function Casting.WaitCastFinish(target, bAllowDead, spellRange) --I am not vested in the math below, I simply converted the existing entry from sec to ms
    local maxWaitOrig = ((mq.TLO.Me.Casting.MyCastTime() or 0) + ((mq.TLO.EverQuest.Ping() * 20) + 1000))
    local maxWait = maxWaitOrig

    while mq.TLO.Me.Casting() do
        local currentCast = mq.TLO.Me.Casting()
        Logger.log_super_verbose("WaitCastFinish(): Waiting to Finish Casting...")
        mq.delay(20)
        if target() and Targeting.GetTargetPctHPs(target) <= 0 and not bAllowDead then
            mq.TLO.Me.StopCast()
            Logger.log_debug("WaitCastFinish(): Canceled casting %s because spellTarget(%d) is dead with no HP(%d)", currentCast, target.ID(),
                Targeting.GetTargetPctHPs(target))
            return
        elseif target() and Targeting.GetTargetID() > 0 and target.ID() ~= Targeting.GetTargetID() then
            mq.TLO.Me.StopCast()
            Logger.log_debug("WaitCastFinish(): Canceled casting %s because spellTarget(%s/%d) is no longer myTarget(%s/%d)", currentCast, target.CleanName() or "",
                target.ID(), Targeting.GetTargetCleanName(), Targeting.GetTargetID())
            return
        elseif target() and Targeting.GetTargetDistance(target) > (spellRange * 1.1) then --allow for slight movement in and out of range, if the target runs off, this is still easily triggered
            mq.TLO.Me.StopCast()
            Logger.log_debug("WaitCastFinish(): Canceled casting %s because spellTarget(%d, range %d) is out of spell range(%d)", currentCast, target.ID(),
                Targeting.GetTargetDistance(),
                spellRange)
            return
            --elseif target() and target.ID() ~= Targeting.GetTargetID() then
            --Logger.log_debug("WaitCastFinish(): Warning your spellTarget(%d) for %s is no longer your currentTarget(%d)", target.ID(), currentCast, Targeting.GetTargetID())
        end

        maxWait = maxWait - 20

        if maxWait <= 0 then
            local msg = string.format("StuckGem Data::: %d - MaxWait - %d - Casting Window: %s - Assist Target ID: %d",
                (mq.TLO.Me.Casting.ID() or -1), maxWaitOrig,
                Strings.BoolToColorString(mq.TLO.Window("CastingWindow").Open()), Config.Globals.AutoTargetID)

            Logger.log_debug(msg)
            Comms.PrintGroupMessage(msg)

            --Core.DoCmd("/alt act 511")
            mq.TLO.Me.StopCast()
            return
        end

        mq.doevents()
    end
end

--- Waits until the specified spell is ready to be cast or the maximum wait time is reached.
--- @param spell string The name of the spell to wait for.
--- @param maxWait number The maximum amount of time (in seconds) to wait for the spell to be ready.
function Casting.WaitCastReady(spell, maxWait)
    while not mq.TLO.Me.SpellReady(spell)() and maxWait > 0 do
        mq.delay(1)
        mq.doevents()
        if Targeting.GetXTHaterCount() > 0 then
            Logger.log_debug("I was interruped by combat while waiting to cast %s.", spell)
            return
        end
        if not mq.TLO.Me.Book(spell)() then
            Logger.log_debug("I was trying to cast %s as my persona was changed, aborting.", spell)
            return
        end

        maxWait = maxWait - 1

        if (maxWait % 100) == 0 then
            Logger.log_verbose("Waiting for spell '%s' to be ready...", spell)
        end
    end

    -- account for lag
    local pingDelay = mq.TLO.EverQuest.Ping() * Config:GetSetting('CastReadyDelayFact')
    mq.delay(pingDelay)
end

--- Checks if a spell is loaded.
---
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell is loaded, false otherwise.
function Casting.SpellLoaded(spell)
    if not spell or not spell() then return false end

    return (mq.TLO.Me.Gem(spell.RankName.Name())() ~= nil)
end

--- Waits for the global cooldown to complete.
---
--- This function pauses execution until the global cooldown period has elapsed.
---
--- @param logPrefix string|nil: An optional prefix to be used in log messages.
function Casting.WaitGlobalCoolDown(logPrefix)
    while mq.TLO.Me.SpellInCooldown() do
        mq.delay(100)
        mq.doevents()
        Logger.log_verbose(logPrefix and logPrefix or "" .. "Waiting for Global Cooldown to be ready...")
    end
end

--- Uses the Origin ability for the character.
--- This function triggers the Origin ability, which typically teleports the character to their bind point.
--- Ensure that the character has the Origin ability available before calling this function.
---
--- @return boolean True if successful
function Casting.UseOrigin()
    if mq.TLO.FindItem("=Drunkard's Stein").ID() or 0 > 0 and mq.TLO.Me.ItemReady("=Drunkard's Stein") then
        Logger.log_debug("\ag--\atFound a Drunkard's Stein, using that to get to PoK\ag--")
        Casting.UseItem("Drunkard's Stein", mq.TLO.Me.ID())
        return true
    end

    if Casting.AAReady("Throne of Heroes") then
        Logger.log_debug("\ag--\atUsing Throne of Heroes to get to Guild Lobby\ag--")
        Logger.log_debug("\ag--\atAs you not within a zone we know\ag--")

        Casting.UseAA("Throne of Heroes", mq.TLO.Me.ID())
        return true
    end

    if Casting.AAReady("Origin") then
        Logger.log_debug("\ag--\atUsing Origin to get to Guild Lobby\ag--")
        Logger.log_debug("\ag--\atAs you not within a zone we know\ag--")

        Casting.UseAA("Origin", mq.TLO.Me.ID())
        return true
    end

    return false
end

--- Prepares the necessary actions for the Casting module.
--- This function is responsible for setting up any prerequisites or initial configurations
--- required before executing the main functionalities of the Casting module.
--- It ensures that all necessary conditions are met and resources are allocated properly.
function Casting.ActionPrep()
    if not mq.TLO.Me.Standing() then
        mq.TLO.Me.Stand()
        mq.delay(10, function() return mq.TLO.Me.Standing() end)

        Config.Globals.InMedState = false
    end

    if mq.TLO.Window("SpellBookWnd").Open() then
        mq.TLO.Window("SpellBookWnd").DoClose()
    end
end

--- Uses the specified Alternate Advancement (AA) ability on a given target.
--- @param aaName string The name of the AA ability to use.
--- @param targetId number The ID of the target on which to use the AA ability.
--- @return boolean True if the AA ability was successfully used, false otherwise.
function Casting.UseAA(aaName, targetId, bAllowDead, retryCount)
    local me = mq.TLO.Me
    local oldTargetId = mq.TLO.Target.ID()

    local aaAbility = mq.TLO.Me.AltAbility(aaName)

    if not aaAbility() then
        Logger.log_verbose("\arUseAA(): You dont have the AA: %s!", aaName)
        return false
    end

    if not mq.TLO.Me.AltAbilityReady(aaName) then
        Logger.log_verbose("\ayUseAA(): Ability %s is not ready!", aaName)
        return false
    end

    if mq.TLO.Window("CastingWindow").Open() or me.Casting() then
        if Core.MyClassIs("brd") then
            mq.delay("3s", function() return (not mq.TLO.Window("CastingWindow").Open()) end)
            mq.delay(10)
            Core.DoCmd("/stopsong")
        else
            Logger.log_verbose("\ayUseAA(): CANT CAST AA - Casting Window Open")
            return false
        end
    end

    local targetSpawn = mq.TLO.Spawn(targetId)

    -- If we're combat casting we need to both have the same swimming status
    if targetSpawn() and targetSpawn.FeetWet() ~= me.FeetWet() then
        Logger.log_verbose("\ayUseAA(): Can't use AA feet wet mismatch!")
        return false
    end

    if not bAllowDead and targetSpawn() and targetSpawn.Dead() then
        Logger.log_verbose("\ayUseAA(): \arAbility Failed!: I tried to use %s but my target (%d) is dead.",
            aaName, targetId)
        return false
    end

    Casting.ActionPrep()

    if Targeting.GetTargetID() ~= targetId and targetSpawn() then
        if me.Combat() and Targeting.TargetIsType("pc", targetSpawn) then
            Logger.log_info("\awUseAA():NOTICE:\ax Turning off autoattack to cast on a PC.")
            Core.DoCmd("/attack off")
            mq.delay("2s", function() return not me.Combat() end)
        end

        Logger.log_debug("\awUseAA():NOTICE:\ax Swapping target to %s [%d] to use %s", targetSpawn.DisplayName(), targetId, aaName)
        Targeting.SetTarget(targetId, true)
    end

    retryCount = retryCount or 3
    local cmd = string.format("/alt act %d", aaAbility.ID())

    Logger.log_debug("\ayUseAA():Activating AA: '%s' [t: %dms]", cmd, aaAbility.Spell.MyCastTime())

    if aaAbility.Spell.MyCastTime() > 0 then
        Casting.SetLastCastResult(Config.Constants.CastResults.CAST_RESULT_NONE)

        local spellRange = aaAbility.Spell.MyRange() > 0 and aaAbility.Spell.MyRange() or (aaAbility.Spell.AERange() > 0 and aaAbility.Spell.AERange() or 250)

        repeat
            Logger.log_verbose("\ayUseAA(): Attempting to cast: %s", aaName)
            Core.DoCmd(cmd)
            Logger.log_verbose("\ayUseAA(): Waiting to start cast: %s", aaName)
            mq.delay("1s", function() return mq.TLO.Me.Casting() end)
            Logger.log_verbose("\ayUseAA(): Started to cast: %s - waiting to finish", aaName)
            Casting.WaitCastFinish(targetSpawn, bAllowDead or false, spellRange)
            mq.doevents()
            mq.delay(1)
            Logger.log_verbose("\atUseAA(): Finished waiting on cast: %s result = %s retries left = %d", aaName, Casting.GetLastCastResultName(), retryCount)
            retryCount = retryCount - 1
        until Config.Constants.CastCompleted:contains(Casting.GetLastCastResultName()) or retryCount < 0
    else
        Core.DoCmd(cmd)
        mq.delay(5)
        if oldTargetId > 0 then
            Logger.log_debug("UseAA():switching target back to old target after casting aa")
            Targeting.SetTarget(oldTargetId, true)
        end
    end

    return true
end

--- Uses an item on a specified target.
--- @param itemName string The name of the item to be used.
--- @param targetId number The ID of the target on which the item will be used.
--- @return boolean
function Casting.UseItem(itemName, targetId)
    local me = mq.TLO.Me

    if mq.TLO.Window("CastingWindow").Open() or me.Casting() then
        if Core.MyClassIs("brd") then
            mq.delay("3s", function() return not mq.TLO.Window("CastingWindow").Open() end)
            mq.delay(10)
            Core.DoCmd("/stopsong")
        else
            Logger.log_debug("\awUseItem(\ag%s\aw): \arCANT Use Item - Casting Window Open", itemName or "None")
            return false
        end
    end

    if not itemName then
        Logger.log_debug("\awUseItem(\ag%s\aw): \arGiven item name is nil!")
        return false
    end

    local item = mq.TLO.FindItem("=" .. itemName)

    if not item() then
        Logger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but it is not found!", itemName)
        return false
    end

    if targetId == mq.TLO.Me.ID() then
        if Casting.BuffActiveByID(item.Clicky.SpellID()) then
            Logger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but the clicky buff is already active!", itemName)
            return false
        end

        if Casting.BuffActiveByID(item.Spell.ID()) then
            Logger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but the buff is already active!", itemName)
            return false
        end

        if Casting.SongActive(item.Spell) then
            Logger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but the song buff is already active: %s!", itemName, item.Spell.Name())
            return false
        end

        -- validate this wont kill us.
        if item.Spell() and item.Spell.HasSPA(0)() then
            for i = 1, item.Spell.NumEffects() do
                if item.Spell.Attrib(i)() == 0 then
                    if mq.TLO.Me.CurrentHPs() + item.Spell.Base(i)() <= 0 then
                        Logger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but it would kill me!: %s! HPs: %d SpaHP: %d", itemName, item.Spell.Name(),
                            mq.TLO.Me.CurrentHPs(), item.Spell.Base(i)())
                        return false
                    end
                end
            end
        end
    end

    Casting.ActionPrep()

    if not me.ItemReady(itemName) then
        Logger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but it is not ready!", itemName)
        return false
    end

    local oldTargetId = Targeting.GetTargetID()
    Targeting.SetTarget(targetId, true)

    Logger.log_debug("\awUseItem(\ag%s\aw): Using Item!", itemName)

    local cmd = string.format("/useitem \"%s\"", itemName)
    Core.DoCmd(cmd)
    Logger.log_debug("Running: \at'%s' [%d]", cmd, item.CastTime())

    mq.delay(2)

    if not item.CastTime() or item.CastTime() == 0 then
        -- slight delay for instant casts
        mq.delay(4)
    else
        local maxWait = 1000
        while maxWait > 0 and not me.Casting() do
            Logger.log_verbose("Waiting for item to start casting...")
            mq.delay(100)
            mq.doevents()
            maxWait = maxWait - 100
        end
        mq.delay(item.CastTime(), function() return not me.Casting() end)

        -- pick up any additonal server lag.
        while me.Casting() do
            mq.delay(5)
            mq.doevents()
        end
    end

    if mq.TLO.Cursor.ID() then
        Core.DoCmd("/autoinv")
    end

    if oldTargetId > 0 then
        Targeting.SetTarget(oldTargetId, true)
    else
        Targeting.ClearTarget()
    end

    return true
end

--- Uses the specified ability.
---
--- @param abilityName string The name of the ability to use.
function Casting.UseAbility(abilityName)
    local me = mq.TLO.Me
    Core.DoCmd("/doability %s", abilityName)
    mq.delay(8, function() return not me.AbilityReady(abilityName) end)
    Logger.log_debug("Using Ability \ao =>> \ag %s \ao <<=", abilityName)
end

--- Uses a discipline spell on a specified target.
---
--- @param discSpell MQSpell The name of the discipline spell to use.
--- @param targetId number The ID of the target on which to use the discipline spell.
--- @return boolean True if we were able to fire the Disc false otherwise.
function Casting.UseDisc(discSpell, targetId)
    local me = mq.TLO.Me

    if not discSpell or not discSpell() then return false end

    if mq.TLO.Window("CastingWindow").Open() or me.Casting() then
        Logger.log_debug("CANT USE Disc - Casting Window Open")
        return false
    else
        if me.CurrentEndurance() < discSpell.EnduranceCost() then
            return false
        else
            Logger.log_debug("Trying to use Disc: %s", discSpell.RankName.Name())

            Casting.ActionPrep()

            if Casting.IsActiveDisc(discSpell.RankName.Name()) then
                if me.ActiveDisc.ID() then
                    Logger.log_debug("Cancelling Disc for %s -- Active Disc: [%s]", discSpell.RankName.Name(),
                        me.ActiveDisc.Name())
                    Core.DoCmd("/stopdisc")
                    mq.delay(20, function() return not me.ActiveDisc() end)
                end
            end

            Core.DoCmd("/squelch /doability \"%s\"", discSpell.RankName.Name())

            mq.delay(discSpell.MyCastTime() or 1000,
                function() return (not me.CombatAbilityReady(discSpell.RankName.Name())() and not me.Casting()) end)

            -- Is this even needed?
            if Casting.IsActiveDisc(discSpell.RankName.Name()) then
                mq.delay(20, function() return me.ActiveDisc() end)
            end

            Logger.log_debug("\aw Cast >>> \ag %s", discSpell.RankName.Name())

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
function Casting.UseSong(songName, targetId, bAllowMem, retryCount)
    if not songName then return false end
    local me = mq.TLO.Me
    Logger.log_debug("\ayUseSong(%s, %d, %s)", songName, targetId, Strings.BoolToColorString(bAllowMem))

    if songName then
        local spell = mq.TLO.Spell(songName)

        if not spell() then
            Logger.log_error("\arSinging Failed: Somehow I tried to cast a spell That doesn't exist: %s",
                songName)
            return false
        end

        -- Check we actually have the song -- Me.Book always needs to use RankName
        if not me.Book(songName)() then
            Logger.log_error("\arSinging Failed: Somehow I tried to cast a spell I didn't know: %s", songName)
            return false
        end

        if me.CurrentMana() < spell.Mana() then
            Logger.log_verbose("\arSinging Failed: I tried to cast a spell %s I don't have mana for it.",
                songName)
            return false
        end

        if mq.TLO.Cursor.ID() then
            Core.DoCmd("/autoinv")
        end

        local targetSpawn = mq.TLO.Spawn(targetId)

        if (Targeting.GetXTHaterCount() > 0 or not bAllowMem) and (not Casting.CastReady(songName) or not mq.TLO.Me.Gem(songName)()) then
            Logger.log_debug("\ayI tried to singing %s but it was not ready and we are in combat - moving on.",
                songName)
            return false
        end

        local spellRequiredMem = false
        if not me.Gem(songName)() then
            Logger.log_debug("\ay%s is not memorized - meming!", songName)
            Casting.MemorizeSpell(Casting.UseGem, songName, true, 5000)
            spellRequiredMem = true
        end

        if not me.Gem(songName)() then
            Logger.log_debug("\arFailed to memorized %s - moving on...", songName)
            return false
        end

        if targetId > 0 and targetId ~= mq.TLO.Me.ID() then
            Targeting.SetTarget(targetId, true)
        end

        Casting.WaitCastReady(songName, spellRequiredMem and (5 * 60 * 100) or 5000)
        --mq.delay(500)

        Casting.ActionPrep()

        Logger.log_verbose("\ag %s \ar =>> \ay %s \ar <<=", songName, targetSpawn.CleanName() or "None")

        -- Swap Instruments
        local classConfig = Modules:ExecModule("Class", "GetClassConfig")
        if classConfig and classConfig.HelperFunctions and classConfig.HelperFunctions.SwapInst then
            classConfig.HelperFunctions.SwapInst(spell.Skill())
        end

        retryCount = retryCount or 0

        repeat
            if Core.OnEMU() then
                -- EMU doesn't seem to tell us we begin singing.
                Casting.SetLastCastResult(Config.Constants.CastResults.CAST_SUCCESS)
            end
            Core.DoCmd("/cast \"%s\"", songName)

            mq.delay("3s", function() return mq.TLO.Window("CastingWindow").Open() end)

            -- while the casting window is open, still do movement if not paused or if movement enabled during pause.
            while mq.TLO.Window("CastingWindow").Open() do
                if not Config.Globals.PauseMain or Config:GetSetting('RunMovePaused') then
                    Modules:ExecModule("Movement", "GiveTime", "Combat")
                end

                if targetId > 0 and targetId ~= mq.TLO.Me.ID() then
                    if targetSpawn() and Targeting.GetTargetPctHPs(targetSpawn) <= 0 and spell.SpellType() == "Detrimental" then -- Almost all bard casts should be allowed to continue
                        mq.TLO.Me.StopCast()
                        Logger.log_debug("UseSong::WaitSingFinish(): Canceled casting because spellTarget(%d) is dead with no HP(%d)", targetSpawn.ID(),
                            Targeting.GetTargetPctHPs(targetSpawn))
                        break
                    elseif targetSpawn() and Targeting.GetTargetID() > 0 and targetSpawn.ID() ~= Targeting.GetTargetID() and spell.SpellType() == "Detrimental" then -- Almost all bard casts should be allowed to continue
                        mq.TLO.Me.StopCast()
                        Logger.log_debug("UseSong::WaitSingFinish(): Canceled casting because spellTarget(%d) is no longer myTarget(%d)", targetSpawn.ID(),
                            Targeting.GetTargetID())
                        break
                    elseif targetSpawn() and targetSpawn.ID() ~= Targeting.GetTargetID() then
                        Logger.log_debug("UseSong::WaitSingFinish(): Warning your spellTarget(%d) is no longar your currentTarget(%d)", targetSpawn.ID(),
                            Targeting.GetTargetID())
                    end
                end
                mq.doevents()
                mq.delay(20)
            end

            retryCount = retryCount - 1
        until Config.Constants.CastCompleted:contains(Casting.GetLastCastResultName()) or retryCount < 0

        -- bard songs take a bit to refresh after casting window closes, otherwise we'll clip our song
        local clipDelay = mq.TLO.EverQuest.Ping() * Config:GetSetting('SongClipDelayFact')
        mq.delay(clipDelay)

        Core.DoCmd("/stopsong")

        if classConfig and classConfig.HelperFunctions and classConfig.HelperFunctions.SwapInst then
            classConfig.HelperFunctions.SwapInst("Weapon")
        end

        return Casting.GetLastCastResultId() == Config.Constants.CastResults.CAST_SUCCESS
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
function Casting.UseSpell(spellName, targetId, bAllowMem, bAllowDead, overrideWaitForGlobalCooldown, retryCount)
    local me = mq.TLO.Me
    -- Immediately send bards to the song handler.
    if me.Class.ShortName():lower() == "brd" then
        return Casting.UseSong(spellName, targetId, bAllowMem)
    end

    Logger.log_debug("\ayUseSpell(%s, %d, %s)", spellName, targetId, Strings.BoolToColorString(bAllowMem))

    if me.Moving() then
        Logger.log_debug("\ayUseSpell(%s, %d, %s) -- Failed because I am moving", spellName, targetId,
            Strings.BoolToColorString(bAllowMem))
        return false
    end

    if mq.TLO.Cursor.ID() then
        Core.DoCmd("/autoinv")
    end

    if spellName then
        local spell = mq.TLO.Spell(spellName)

        if not spell() then
            Logger.log_error("\ayUseSpell(): \arCasting Failed: Somehow I tried to cast a spell That doesn't exist: %s",
                spellName)
            return false
        end
        -- Check we actually have the spell -- Me.Book always needs to use RankName
        if not me.Book(spellName)() then
            Logger.log_error("\ayUseSpell(): \arCasting Failed: Somehow I tried to cast a spell I didn't know: %s", spellName)
            return false
        end

        local targetSpawn = mq.TLO.Spawn(targetId)

        if targetSpawn() and Targeting.TargetIsType("pc", targetSpawn) then
            -- check to see if this is too powerful a spell
            local targetLevel    = targetSpawn.Level()
            local spellLevel     = spell.Level()
            local levelCheckPass = true
            if targetLevel <= 45 and spellLevel > 50 then levelCheckPass = false end
            if targetLevel <= 60 and spellLevel > 65 then levelCheckPass = false end
            if targetLevel <= 65 and spellLevel > 95 then levelCheckPass = false end

            if not levelCheckPass then
                Logger.log_error("\ayUseSpell(): \arCasting %s failed level check with target=%d and spell=%d", spellName,
                    targetLevel, spellLevel)
                return false
            end
        end

        -- Check for Reagents
        if not Casting.ReagentCheck(spell) then
            Logger.log_debug("\ayUseSpell(): \arCasting Failed: I tried to cast a spell %s I don't have Reagents for.",
                spellName)
            return false
        end

        -- Check for enough mana -- just in case something has changed by this point...
        if me.CurrentMana() < spell.Mana() then
            Logger.log_verbose("\ayUseSpell(): \arCasting Failed: I tried to cast a spell %s I don't have mana for it.",
                spellName)
            return false
        end

        -- If we're combat casting we need to both have the same swimming status
        if targetId == 0 or (targetSpawn() and targetSpawn.FeetWet() ~= me.FeetWet()) then
            Logger.log_debug("\ayUseSpell(): \arCasting Failed: I tried to cast a spell %s I don't have a target (%d) for it.",
                spellName, targetId)
            return false
        end

        if not bAllowDead and targetSpawn() and targetSpawn.Dead() then
            Logger.log_verbose("\ayUseSpell(): \arCasting Failed: I tried to cast a spell %s but my target (%d) is dead.",
                spellName, targetId)
            return false
        end

        if (Targeting.GetXTHaterCount() > 0 or not bAllowMem) and (not Casting.CastReady(spellName) or not mq.TLO.Me.Gem(spellName)()) then
            Logger.log_debug("\ayUseSpell(): \ayI tried to cast %s but it was not ready and we are in combat - moving on.",
                spellName)
            return false
        end

        local spellRequiredMem = false
        if not me.Gem(spellName)() then
            Logger.log_debug("\ayUseSpell(): \ay%s is not memorized - meming!", spellName)
            Casting.MemorizeSpell(Casting.UseGem, spellName, true, 25000)
            spellRequiredMem = true
        end

        if not me.Gem(spellName)() then
            Logger.log_debug("\ayUseSpell(): \arFailed to memorized %s - moving on...", spellName)
            return false
        end

        Casting.WaitCastReady(spellName, spellRequiredMem and (5 * 60 * 100) or 5000)

        Casting.WaitGlobalCoolDown()

        Casting.ActionPrep()

        retryCount = retryCount or 3

        if targetId > 0 then
            Targeting.SetTarget(targetId, true)
        end

        --if not Casting.SpellStacksOnTarget(spell) then
        --    Logger.log_debug("\ayUseSpell(): \arStacking checked failed - Someone tell Derple or Algar to add a Stacking Check to the condition of '%s'!", spellName)
        --    return false
        --end

        local cmd = string.format("/cast \"%s\"", spellName)
        Casting.SetLastCastResult(Config.Constants.CastResults.CAST_RESULT_NONE)

        local spellRange = spell.MyRange() > 0 and spell.MyRange() or (spell.AERange() > 0 and spell.AERange() or 250)

        repeat
            Logger.log_verbose("\ayUseSpell(): Attempting to cast: %s", spellName)
            Core.DoCmd(cmd)
            Logger.log_verbose("\ayUseSpell(): Waiting to start cast: %s", spellName)
            mq.delay("1s", function() return mq.TLO.Me.Casting() end)
            Logger.log_verbose("\ayUseSpell(): Started to cast: %s - waiting to finish", spellName)
            Casting.WaitCastFinish(targetSpawn, bAllowDead or false, spellRange)
            mq.doevents()
            mq.delay(1)
            Logger.log_verbose("\atUseSpell(): Finished waiting on cast: %s result = %s retries left = %d", spellName, Casting.GetLastCastResultName(), retryCount)
            retryCount = retryCount - 1
        until Config.Constants.CastCompleted:contains(Casting.GetLastCastResultName()) or retryCount < 0

        -- don't return control until we are done.
        if Config:GetSetting('WaitOnGlobalCooldown') and not overrideWaitForGlobalCooldown then
            Logger.log_verbose("\ayUseSpell(): Waiting on Global Cooldown After Casting: %s", spellName)
            Casting.WaitGlobalCoolDown()
            Logger.log_verbose("\agUseSpell(): Done Waiting on Global Cooldown After Casting: %s", spellName)
        end

        Config.Globals.LastUsedSpell = spellName
        return true
    end

    Logger.log_verbose("\arCasting Failed: Invalid Spell Name")
    return false
end

--- Checks if the character is currently feigning death.
--- @return boolean True if the character is feigning death, false otherwise.
function Casting.IAmFeigning()
    return mq.TLO.Me.State():lower() == "feign"
end

--- Retrieves the name of the last cast result.
---
--- @return string The name of the last cast result.
function Casting.GetLastCastResultName()
    return Config.Constants.CastResultsIdToName[Config.Globals.CastResult]
end

--- Retrieves the ID of the last cast result.
---
--- @return number The ID of the last cast result.
function Casting.GetLastCastResultId()
    return Config.Globals.CastResult
end

--- Sets the result of the last cast operation.
--- @param result number The result to be set for the last cast operation.
function Casting.SetLastCastResult(result)
    Logger.log_debug("\awSet Last Cast Result => \ag%s", Config.Constants.CastResultsIdToName[result])
    Config.Globals.CastResult = result
end

--- Checks if a self-buff spell can be cast on a pet.
---
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell can be cast on a pet, false otherwise.
function Casting.SelfBuffPetCheck(spell)
    if not spell or not spell() then return false end

    -- Skip if the spell is set as a blocked pet buff, otherwise the bot loops forever
    if mq.TLO.Me.BlockedPetBuff(spell.ID())() then
        return false
    end
    Logger.log_verbose("\atSelfBuffPetCheck(%s) RankPetBuff(%s) PetBuff(%s) Stacks(%s)",
        spell.RankName.Name(),
        Strings.BoolToColorString(not mq.TLO.Me.PetBuff(spell.RankName.Name())()),
        Strings.BoolToColorString(not mq.TLO.Me.PetBuff(spell.Name())()),
        Strings.BoolToColorString(spell.StacksPet()))

    return (not mq.TLO.Me.PetBuff(spell.RankName.Name())()) and (not mq.TLO.Me.PetBuff(spell.Name())()) and spell.StacksPet() and mq.TLO.Me.Pet.ID() > 0
end

--- Checks if the self-buff spell is active.
---
--- @param spell MQSpell|string The name of the spell to check.
--- @return boolean Returns true if the spell is active, false otherwise.
function Casting.SelfBuffCheck(spell)
    if type(spell) == "string" then
        Logger.log_verbose("\agSelfBuffCheck(%s) string", spell)
        return Casting.BuffActiveByName(spell)
    end
    if not spell or not spell() then
        --Logger.log_verbose("\arSelfBuffCheck() Spell Invalid")
        return false
    end

    local res = not Casting.BuffActiveByID(spell.RankName.ID()) and spell.Stacks()

    Logger.log_verbose("\aySelfBuffCheck(\at%s\ay/\am%d\ay) Spell Obj => %s", spell.RankName(),
        spell.RankName.ID(),
        Strings.BoolToColorString(res))

    return res
end

--- Checks if the burn condition is met for RGMercs.
--- This function evaluates certain criteria to determine if the burn phase should be initiated.
--- @return boolean True if the burn condition is met, false otherwise.
function Casting.BurnCheck()
    local settings = Config:GetSettings()
    local autoBurn = settings.BurnAuto and
        ((Targeting.GetXTHaterCount() >= settings.BurnMobCount) or (Targeting.IsNamed(mq.TLO.Target) and settings.BurnNamed))
    local alwaysBurn = (settings.BurnAlways and settings.BurnAuto)
    local forcedBurn = Targeting.ForceBurnTargetID > 0 and Targeting.ForceBurnTargetID == mq.TLO.Target.ID()

    Casting.LastBurnCheck = autoBurn or alwaysBurn or forcedBurn
    return Casting.LastBurnCheck
end

--- Determines if the current entity can receive buffs.
--- @return boolean True if the entity can be buffed, false otherwise.
function Casting.AmIBuffable()
    local myCorpseCount = Config:GetSetting('BuffRezables') and 0 or mq.TLO.SpawnCount(string.format('pccorpse %s radius 100 zradius 50', mq.TLO.Me.CleanName()))()
    if myCorpseCount > 0 then Logger.log_debug("Corpse detected (%s), aborting rotation.", mq.TLO.Me.CleanName()) end
    return myCorpseCount == 0
end

--- Retrieves the list of group IDs that can be buffed.
---
--- @return table A table containing the IDs of the groups that can receive buffs.
function Casting.GetBuffableGroupIDs()
    local groupIds = {}

    if Casting.AmIBuffable() then
        table.insert(groupIds, mq.TLO.Me.ID())

        local count = mq.TLO.Group.Members()
        for i = 1, count do
            local rezSearch = string.format("pccorpse %s radius 100 zradius 50", mq.TLO.Group.Member(i).DisplayName())
            if mq.TLO.SpawnCount(rezSearch)() > 0 and not Config:GetSetting('BuffRezables') then
                groupIds = {}
                Logger.log_debug("Groupmember corpse detected (%s), aborting group buff rotation.", mq.TLO.Group.Member(i).DisplayName())
                break
            else
                table.insert(groupIds, mq.TLO.Group.Member(i).ID())
            end
        end

        -- check OA list
        for _, n in ipairs(Config:GetSetting('OutsideAssistList')) do
            -- dont double up OAs who are in our group
            if not mq.TLO.Group.Member(n)() then
                local oaSpawn = mq.TLO.Spawn(("pc =%s"):format(n))
                if oaSpawn and oaSpawn() and oaSpawn.Distance() <= 90 then
                    table.insert(groupIds, oaSpawn.ID())
                end
            end
        end
    else
        Logger.log_debug("Groupmember corpse detected (%s), aborting group buff rotation.", mq.TLO.Me.DisplayName())
    end

    return groupIds
end

--- Retrieves the ID of the item summoned by a given spell.
---
--- @param spell MQSpell The name or identifier of the spell.
--- @return number The ID of the summoned item.
function Casting.GetSummonedItemIDFromSpell(spell)
    if not spell or not spell() then return 0 end

    for i = 1, spell.NumEffects() do
        -- 32 means SPA_CREATE_ITEM
        if spell.Attrib(i)() == 32 then
            return tonumber(spell.Base(i)()) or 0
        end
    end

    return 0
end

--- Retrieves the last used spell.
---
--- @return string The name of the last used spell.
function Casting.GetLastUsedSpell()
    return Config.Globals.LastUsedSpell
end

--- Automatically manages the medication process for the character.
--- This function handles the logic for ensuring the character takes the necessary medication at the appropriate times.
---
function Casting.AutoMed()
    local me = mq.TLO.Me
    if Config:GetSetting('DoMed') == 1 then return end

    if me.Class.ShortName():lower() == "brd" and me.Level() > 5 then return end

    if me.Mount.ID() and not mq.TLO.Zone.Indoor() then
        Logger.log_verbose("Sit check returning early due to mount.")
        return
    end

    if Config:GetSetting('MedAggroCheck') and Targeting.IHaveAggro(90) then
        Logger.log_verbose("Sit check returning early due to aggro.")
        return
    end

    -- Allow sufficient time for the player to do something before char plunks down. Spreads out med sitting too.
    if Targeting.GetXTHaterCount() == 0 and Config:GetTimeSinceLastMove() < math.random(Config:GetSetting('AfterCombatMedDelay')) then return end

    Config:StoreLastMove()

    --If we're moving/following/navigating/sticking, don't med.
    if me.Casting() or me.Moving() or mq.TLO.Stick.Active() or mq.TLO.Navigation.Active() or mq.TLO.MoveTo.Moving() or mq.TLO.AdvPath.Following() then
        Logger.log_verbose(
            "Sit check returning early due to movement. Casting(%s) Moving(%s) Stick(%s) Nav(%s) MoveTo(%s) Following(%s)",
            me.Casting() or "None", Strings.BoolToColorString(me.Moving()), Strings.BoolToColorString(mq.TLO.Stick.Active()),
            Strings.BoolToColorString(mq.TLO.Navigation.Active()), Strings.BoolToColorString(mq.TLO.MoveTo.Moving()),
            Strings.BoolToColorString(mq.TLO.AdvPath.Following()))
        return
    end

    local forcesit   = false
    local forcestand = false

    if Config.Constants.RGHybrid:contains(me.Class.ShortName()) or Config.Constants.RGCasters:contains(me.Class.ShortName()) then
        -- Handle the case where we're a Hybrid. We need to check mana and endurance. Needs to be done after
        -- the original stat checks.
        if me.PctHPs() >= Config:GetSetting('HPMedPctStop') and me.PctMana() >= Config:GetSetting('ManaMedPctStop') and me.PctEndurance() >= Config:GetSetting('EndMedPctStop') then
            Config.Globals.InMedState = false
            forcestand = true
        end

        if me.PctHPs() < Config:GetSetting('HPMedPct') or me.PctMana() < Config:GetSetting('ManaMedPct') or me.PctEndurance() < Config:GetSetting('EndMedPct') then
            forcesit = true
        end
    elseif Config.Constants.RGMelee:contains(me.Class.ShortName()) then
        if me.PctHPs() >= Config:GetSetting('HPMedPctStop') and me.PctEndurance() >= Config:GetSetting('EndMedPctStop') then
            Config.Globals.InMedState = false
            forcestand = true
        end

        if me.PctHPs() < Config:GetSetting('HPMedPct') or me.PctEndurance() < Config:GetSetting('EndMedPct') then
            forcesit = true
        end
    else
        Logger.log_error(
            "\arYour character class is not in the type list(s): rghybrid, rgcasters, rgmelee. That's a problem for a dev.")
        Config.Globals.InMedState = false
        return
    end

    Logger.log_verbose(
        "MED MAIN STATS CHECK :: HP %d :: HPMedPct %d :: Mana %d :: ManaMedPct %d :: Endurance %d :: EndPct %d :: forceSit %s :: forceStand %s :: Memorizing %s",
        me.PctHPs(), Config:GetSetting('HPMedPct'), me.PctMana(),
        Config:GetSetting('ManaMedPct'), me.PctEndurance(),
        Config:GetSetting('EndMedPct'), Strings.BoolToColorString(forcesit), Strings.BoolToColorString(forcestand), Strings.BoolToColorString(Casting.Memorizing))

    -- This could likely be refactored
    if me.Sitting() and not Casting.Memorizing then
        if Targeting.GetXTHaterCount() > 0 and (Config:GetSetting('DoMed') ~= 3 or Config:GetSetting('DoMelee') or ((Config:GetSetting('MedAggroCheck') and Targeting.IHaveAggro(90)))) then
            Config.Globals.InMedState = false
            Logger.log_debug("Forcing stand - Combat or aggro threshold reached.")
            me.Stand()
            return
        end

        if Modules:ExecModule("Class", "IsRezing") and mq.TLO.Me.PctMana() > 10 then
            local group = mq.TLO.Group.Members()
            for i = 1, group do
                local rezSearch = string.format("pccorpse %s radius 100 zradius 50", mq.TLO.Group.Member(i).DisplayName())
                if mq.TLO.SpawnCount(rezSearch)() > 0 then
                    Config.Globals.InMedState = false
                    Logger.log_debug("Forcing stand - we should have enough mana to rez and there is a corpse nearby.")
                    me.Stand()
                    return
                end
            end
        end

        if (Config:GetSetting('StandWhenDone') or Config:GetSetting('DoPull')) and forcestand then
            Config.Globals.InMedState = false
            Logger.log_debug("Forcing stand - all conditions met.")
            me.Stand()
            return
        end
    end

    if not me.Sitting() and forcesit then
        Config.Globals.InMedState = true
        Logger.log_debug("Forcing sit - all conditions met.")
        me.Sit()
    end
end

function Casting.ClickModRod()
    local me = mq.TLO.Me
    if not Config.Constants.RGCasters:contains(me.Class.ShortName()) or me.PctMana() > Config:GetSetting('ModRodManaPct') or me.PctHPs() < 60 or Casting.IAmFeigning() or mq.TLO.Me.Invis() then
        return
    end

    for _, itemName in ipairs(Config.Constants.ModRods) do
        while mq.TLO.Cursor.Name() == itemName do
            Core.DoCmd("/squelch /autoinv")
            mq.delay(10)
        end

        local item = mq.TLO.FindItem(itemName)
        if item() and item.TimerReady() == 0 then
            Casting.UseItem(item.Name(), mq.TLO.Me.ID())
            return
        end
    end
end

--- Checks if a song spell is memorized.
---
--- @param songSpell MQSpell The name of the song spell to check.
--- @return boolean True if the song spell is memorized, false otherwise.
function Casting.SongMemed(songSpell)
    if not songSpell or not songSpell() then return false end
    local me = mq.TLO.Me

    return me.Gem(songSpell.RankName.Name())() ~= nil
end

--- Returns if a Buff Song is in need of recast
--- @param songSpell MQSpell The name of the song spell to be used for buffing.
--- @return boolean Returns true if the buff is needed, false otherwise.
function Casting.BuffSong(songSpell)
    if not songSpell or not songSpell() then return false end
    local me = mq.TLO.Me

    local res = Casting.SongMemed(songSpell) and
        (me.Song(songSpell.Name()).Duration.TotalSeconds() or 0) <= (songSpell.MyCastTime.Seconds() + 6)
    Logger.log_verbose("\ayBuffSong(%s) => memed(%s), duration(%0.2f) < casttime(%0.2f) --> result(%s)",
        songSpell.Name(),
        Strings.BoolToColorString(me.Gem(songSpell.Name())() ~= nil),
        me.Song(songSpell.Name()).Duration.TotalSeconds() or 0, songSpell.MyCastTime.Seconds() + 6,
        Strings.BoolToColorString(res))
    return res
end

--- Returns if a Debuff Song is in need of recast
--- @param songSpell MQSpell The name of the song spell to be used for debuffing.
--- @return boolean Returns true if the debuff was successfully applied, false otherwise.
function Casting.DebuffSong(songSpell)
    if not songSpell or not songSpell() then return false end
    local me = mq.TLO.Me
    local res = me.Gem(songSpell.Name()) and not Casting.TargetHasBuff(songSpell)
    Logger.log_verbose("\ayBuffSong(%s) => memed(%s), targetHas(%s) --> result(%s)", songSpell.Name(),
        Strings.BoolToColorString(me.Gem(songSpell.Name())() ~= nil),
        Strings.BoolToColorString(Casting.TargetHasBuff(songSpell)), Strings.BoolToColorString(res))
    return res
end

--- Checks the debuff condition for the Target
--- This function evaluates the current debuff status and performs necessary actions.
---
--- @return boolean True if the target matches the Con requirements for debuffing.
function Casting.DebuffConCheck()
    local conLevel = (Config.Constants.ConColorsNameToId[mq.TLO.Target.ConColor() or "Grey"] or 0)
    return conLevel >= Config:GetSetting('DebuffMinCon') or (Targeting.IsNamed(mq.TLO.Target) and Config:GetSetting('DebuffNamedAlways'))
end

--- Determines whether the utility should shrink.
--- @return boolean True if the utility should shrink, false otherwise.
function Casting.ShouldShrink()
    return (Config:GetSetting('DoShrink') and true or false) and mq.TLO.Me.Height() > 2.2 and
        (Config:GetSetting('ShrinkItem'):len() > 0) and Casting.DoBuffCheck()
end

--- Determines whether the pet should be shrunk.
--- @return boolean True if the pet should be shrunk, false otherwise.
function Casting.ShouldShrinkPet()
    return (Config:GetSetting('DoShrinkPet') and true or false) and mq.TLO.Me.Pet.ID() > 0 and mq.TLO.Me.Pet.Height() > 1.8 and
        (Config:GetSetting('ShrinkPetItem'):len() > 0) and Casting.DoPetCheck()
end

--- Checks if the target is in range for an ability.
--- @param target MQTarget? The target entity to measure the range to.
function Casting.AbilityRangeCheck(target)
    return Targeting.GetTargetDistance(target) <= Targeting.GetTargetMaxRangeTo(target)
end

function Casting.GemReady(spell) -- split from CastReady so we don't have to pass RankName in class configs. If we change SpellReady, we break custom configs
    if not spell or not spell() then return false end
    return mq.TLO.Me.SpellReady(spell.RankName.Name())()
end

return Casting
