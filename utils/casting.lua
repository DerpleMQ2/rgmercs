local mq              = require('mq')
local Config          = require('utils.config')
local Strings         = require("utils.strings")
local Core            = require("utils.core")
local Modules         = require("utils.modules")
local Comms           = require("utils.comms")
local Targeting       = require("utils.targeting")
local DanNet          = require('lib.dannet.helpers')
local Logger          = require("utils.logger")
local Combat          = require("utils.combat")
local Tables          = require("utils.tables")

local Casting         = { _version = '2.0', _name = "Casting", _author = 'Derple, Algar', }
Casting.__index       = Casting
Casting.Memorizing    = false

-- cached for UI display
Casting.LastBurnCheck = false
Casting.UseGem        = mq.TLO.Me.NumGems()

--- Simple (no trigger or stacking checks) check to see if the player has a buff. Can pass a spell(userdata), ID, or effect name(string).
--- @param effect MQSpell|string|integer|nil The effect to check for.
--- @return boolean Returns true if the player has the buff, false otherwise.
function Casting.IHaveBuff(effect)
    if not effect then return false end
    if type(effect) ~= "string" then effect = tostring(effect) end
    local spell = mq.TLO.Spell(effect)() or effect

    Logger.log_verbose("IHaveBuff - Searching Buff and Song windows for %s.", effect)

    if mq.TLO.Me.Buff(spell)() then
        Logger.log_verbose("IHaveBuff - %s found in Buff window!", effect)
        return true
    end
    if mq.TLO.Me.Song(spell)() then
        Logger.log_verbose("IHaveBuff - %s found in Song window!", effect)
        return true
    end
    return false
end

--- Simple (no trigger or stacking checks) check to see if the target has a buff. Can pass a spell(userdata), ID, or effect name(string).
--- @param effect MQSpell|string|integer The effect to check for.
--- @param target MQTarget|MQSpawn|MQCharacter? The target to check for the buff.
--- @param bAllowTargetChange boolean|nil Allows the function to set the target to check buffs if true.
--- @return boolean Returns true if the target has the buff, false otherwise.
function Casting.TargetHasBuff(effect, target, bAllowTargetChange)
    if not (target and target()) then return false end
    if not effect then return false end
    if type(effect) ~= "string" then effect = tostring(effect) end
    local spell = mq.TLO.Spell(effect)() or effect

    if target.ID() ~= mq.TLO.Target.ID() then
        if not bAllowTargetChange then
            Logger.log_verbose("TargetHasBuff: Passed target(ID:%d) isn't our current target(ID:%d), cannot check spell stacking, aborting.", target.ID(), mq.TLO.Target.ID())
            return false
        else
            Logger.log_verbose("TargetHasBuff: Passed target(ID:%d) isn't our current target(ID:%d), setting target to populate buffs.", target.ID(), mq.TLO.Target.ID())
            Targeting.SetTarget(target.ID())
        end
    end

    return mq.TLO.Target.Buff(spell)() ~= nil
end

--- Complex buff check that will check for presence and stacking of the buff (and any triggers) on the PC or the PC's pet.
--- @param spellId integer The ID of the spell to check.
--- @param checkPet boolean|nil Use the pet as the checked entity if true, use the PC otherwise.
--- @return boolean True if the PC checking should cast the buff, false otherwise.
function Casting.LocalBuffCheck(spellId, checkPet)
    if not spellId then return false end
    if checkPet and mq.TLO.Me.Pet.ID() == 0 then return false end

    local me = mq.TLO.Me
    local spellName = mq.TLO.Spell(spellId).Name()

    if (checkPet and me.BlockedPetBuff(spellName)() == spellName or me.BlockedBuff(spellName)() == spellName) then
        Logger.log_verbose("LocalBuffCheck: %s(ID:%d) is on the blocked spell list, aborting check.", spellName, spellId)
        return false
    end

    if not (checkPet and me.Pet.Buff(spellName)() or me.FindBuff("id " .. spellId)()) then
        Logger.log_verbose("LocalBuffCheck: %s(ID:%d) not found, let's check for triggers.", spellName, spellId)
        local numEffects = mq.TLO.Spell(spellId).NumEffects()
        local triggerCount = 0
        local triggerFound = 0
        for i = 1, numEffects do
            local triggerSpell = mq.TLO.Spell(spellId).Trigger(i)
            --Some Laz spells report trigger 1 as "Unknown Spell" with an ID of 0, which always reports false on stack checks
            if triggerSpell and triggerSpell() and triggerSpell.ID() > 0 then
                local triggerName = triggerSpell.Name()
                local triggerID = triggerSpell.ID()
                if not (checkPet and me.Pet.Buff(triggerName)() or me.FindBuff("id " .. triggerID)()) then
                    Logger.log_verbose("LocalBuffCheck: %s(ID:%d) not found, checking stacking.", triggerName, triggerID)
                    if triggerSpell.Stacks() then
                        Logger.log_verbose("LocalBuffCheck: %s(ID:%d) seems to stack, let's do it!", triggerName, triggerID)
                        return true
                    else
                        Logger.log_verbose("LocalBuffCheck: %s(ID:%d) does not stack, moving on.", triggerName, triggerID)
                        triggerFound = triggerFound + 1
                    end
                else
                    Logger.log_verbose("LocalBuffCheck: %s(ID:%d) found, moving on.", triggerName, triggerID)
                    triggerFound = triggerFound + 1
                end
                triggerCount = triggerCount + 1
            else
                Logger.log_verbose("LocalBuffCheck: We've checked every trigger for %s(ID:%d).", spellName, spellId)
                break
            end
        end
        if triggerCount > 0 and triggerFound >= triggerCount then
            Logger.log_verbose("LocalBuffCheck: Total triggers for %s(ID:%d): %d. Triggers found: %d. Ending Check.", spellName, spellId, triggerCount, triggerFound)
            return false
        end
    else
        Logger.log_verbose("LocalBuffCheck: %s(ID:%d) found, ending check.", spellName, spellId)
        return false
    end
    local spellStacks = checkPet and mq.TLO.Spell(spellId).StacksPet() or mq.TLO.Spell(spellId).Stacks()
    if spellStacks then
        Logger.log_verbose("LocalBuffCheck: %s(ID:%d) seems to stack, let's do it!", spellName, spellId)
        return true
    end
    Logger.log_verbose("LocalBuffCheck: %s(ID:%d) does not seem to stack, ending check.", spellName, spellId)
    return false
end

--- "xBuffxCheck"s are helper functions that wrap buff spells and checks in an easy-to-understand system for simpler class configs

function Casting.SelfBuffCheck(spell)
    if not (spell and spell()) then return false end
    ---@diagnostic disable-next-line: undefined-field
    local spellId = mq.TLO.Me.Spell(spell).ID() or spell.RankName.ID() -- this checks the book first but allows us to still pass spells we don't know as variables to check
    return Casting.LocalBuffCheck(spellId, false)
end

function Casting.SelfBuffAACheck(aaName)
    if not Casting.CanUseAA(aaName) then return false end
    return Casting.LocalBuffCheck(mq.TLO.Me.AltAbility(aaName).Spell.ID())
end

function Casting.SelfBuffItemCheck(itemName)
    local clickySpell = Casting.GetClickySpell(itemName)
    if not (clickySpell and clickySpell()) then return false end
    return Casting.LocalBuffCheck(clickySpell.ID())
end

function Casting.PetBuffCheck(spell)
    if not (spell and spell()) then return false end
    ---@diagnostic disable-next-line: undefined-field
    local spellId = mq.TLO.Me.Spell.ID() or spell.RankName.ID() -- this checks the book first but allows us to still pass spells we don't know as variables to check
    return Casting.LocalBuffCheck(spellId, true)
end

function Casting.PetBuffAACheck(aaName)
    if not Casting.CanUseAA(aaName) then return false end
    return Casting.LocalBuffCheck(mq.TLO.Me.AltAbility(aaName).Spell.ID(), true)
end

function Casting.PetBuffItemCheck(itemName)
    local clickySpell = Casting.GetClickySpell(itemName)
    if not (clickySpell and clickySpell()) then return false end
    return Casting.LocalBuffCheck(clickySpell.ID(), true)
end

--- Helper that will perform complex checks for presence and stacking of buffs (and any triggers) using the best (determined) method available.
--- @param spell MQSpell The name of the spell to check.
--- @param target MQTarget|MQSpawn|MQCharacter? The target to check for the buff.
--- @param spellId integer|nil A directly passed ID to check, used to deconflict for AA or special situations.
--- @return boolean True if the PC checking should cast the buff, false otherwise.
function Casting.GroupBuffCheck(spell, target, spellId)
    if not (spell and spell()) then return false end
    if not (target and target()) then return false end

    ---@diagnostic disable-next-line: undefined-field
    if not spellId then spellId = mq.TLO.Me.Spell(spell).ID() or spell.RankName.ID() end -- this checks the book first but allows us to still pass spells we don't know as variables to check

    local ret = false

    if target.ID() == mq.TLO.Me.ID() then
        Logger.log_verbose("GroupBuffCheck: Target is myself, using LocalBuffCheck(self).")
        ret = Casting.LocalBuffCheck(spellId)
    else
        --Let's check spell range in case our group/OA starts moving while we are trying to buff (common in hunt/farm modes).
        local spellRange = spell.MyRange() > 0 and spell.MyRange() or (spell.AERange() > 0 and spell.AERange() or 250)
        if Targeting.GetTargetDistance(target) > spellRange then
            Logger.log_verbose("GroupBuffCheck: Aborting check because %s(Range:%d) is out of range(%d) for %s.", target.CleanName(), Targeting.GetTargetDistance(target), spellRange,
                spell.RankName.Name())
            return false
        end
        if mq.TLO.DanNet(mq.TLO.Spawn(target.ID()).CleanName())() then
            Logger.log_verbose("GroupBuffCheck: Target is a DanNet peer, using PeerBuffCheck.")
            ret = Casting.PeerBuffCheck(spellId, target)
        else
            Logger.log_verbose("GroupBuffCheck: Target is not myself or a DanNet peer, using TargetSpellCheck.")
            local allowTargetChange = not mq.TLO.Me.CombatState():lower() == "combat"
            ret = Casting.TargetBuffCheck(spellId, target, allowTargetChange)
        end
    end
    return ret
end

function Casting.GroupBuffAACheck(aaName, target)
    if not Casting.CanUseAA(aaName) then return false end
    local aaSpell = mq.TLO.Me.AltAbility(aaName).Spell
    if not aaSpell or not aaSpell() then return false end
    return Casting.GroupBuffCheck(aaSpell, target, aaSpell.ID())
end

--- Complex buff check that will check for presence and stacking of the buff (and any triggers) on a target.
--- @param spellId integer The ID of the spell to check.
--- @param target MQTarget|MQSpawn|MQCharacter? The target to check for the buff.
--- @param bAllowTargetChange boolean|nil Allows the function to set the target to check buffs if true.
--- @return boolean True if the PC checking should cast the buff, false otherwise.
function Casting.TargetBuffCheck(spellId, target, bAllowTargetChange)
    if not spellId then return false end
    if not target then target = mq.TLO.Target end
    if not (target and target()) then return false end

    if target.ID() ~= mq.TLO.Target.ID() then
        if not bAllowTargetChange then
            Logger.log_verbose("TargetBuffCheck: Passed target(ID:%d) isn't our current target(ID:%d), cannot check spell stacking, aborting.", target.ID(), mq.TLO.Target.ID())
            return false
        else
            Logger.log_verbose("TargetBuffCheck: Passed target(ID:%d) isn't our current target(ID:%d), setting target to populate buffs.", target.ID(), mq.TLO.Target.ID())
            Targeting.SetTarget(target.ID())
        end
    end

    local targetName = target.CleanName()
    local targetId = target.ID()
    local spellName = mq.TLO.Spell(spellId).Name()

    if not mq.TLO.Target.FindBuff("id " .. spellId)() then
        Logger.log_verbose("TargetBuffCheck: %s(ID:%d) not found on %s(ID:%d), let's check for triggers.", spellName, spellId, targetName, targetId)
        local numEffects = mq.TLO.Spell(spellId).NumEffects()
        local triggerCount = 0
        local triggerFound = 0
        for i = 1, numEffects do
            local triggerSpell = mq.TLO.Spell(spellId).Trigger(i)
            --Some Laz spells report trigger 1 as "Unknown Spell" with an ID of 0, which always reports false on stack checks
            if triggerSpell and triggerSpell() and triggerSpell.ID() > 0 then
                local triggerName = triggerSpell.Name()
                local triggerID = triggerSpell.ID()
                if not mq.TLO.Target.FindBuff("id " .. triggerID)() then
                    Logger.log_verbose("TargetBuffCheck: %s(ID:%d) not found on %s(ID:%d), checking stacking.", triggerName, triggerID, targetName, targetId)
                    if triggerSpell.StacksTarget() then
                        Logger.log_verbose("TargetBuffCheck: %s(ID:%d) seems to stack on %s(ID:%d), let's do it!", triggerName, triggerID, targetName, targetId)
                        return true
                    else
                        Logger.log_verbose("TargetBuffCheck: %s(ID:%d) does not stack on %s(ID:%d), moving on.", triggerName, triggerID, targetName, targetId)
                    end
                else
                    Logger.log_verbose("TargetBuffCheck: %s(ID:%d) found on %s(ID:%d), moving on.", triggerName, triggerID, targetName, targetId)
                    triggerFound = triggerFound + 1
                end
                triggerCount = triggerCount + 1
            else
                Logger.log_verbose("TargetBuffCheck: We've checked every trigger for %s(ID:%d).", spellName, spellId)
                break
            end
        end
        if triggerCount > 0 and triggerFound >= triggerCount then
            Logger.log_verbose("TargetBuffCheck: Total triggers for %s(ID:%d): %d. Triggers found: %d. Ending Check.", spellName, spellId, triggerCount, triggerFound)
            return false
        end
    else
        Logger.log_verbose("TargetBuffCheck: %s(ID:%d) found on %s(ID:%d), ending check.", spellName, spellId, targetName, targetId)
        return false
    end
    if mq.TLO.Spell(spellId).StacksTarget() then
        Logger.log_verbose("TargetBuffCheck: %s(ID:%d) seems to stack on %s(ID:%d), let's do it!", spellName, spellId, targetName, targetId)
        return true
    end
    Logger.log_verbose("TargetBuffCheck: %s(ID:%d) does not seem to stack, ending check.", spellName, spellId)
    return false
end

--- Complex buff check that will check for presence and stacking of the buff (and any triggers) on a DanNet peer.
--- @param spellId integer The name of the spell to check.
--- @param target MQTarget|MQSpawn|MQCharacter? The target to check for the buff.
--- @return boolean True if the PC checking should cast the buff, false otherwise.
function Casting.PeerBuffCheck(spellId, target)
    if not spellId then return false end
    if not (target and target()) then return false end

    local targetName = target.CleanName()
    local targetId = target.ID()
    local spellName = mq.TLO.Spell(spellId).Name()

    if not mq.TLO.DanNet(mq.TLO.Spawn(targetId).CleanName())() then
        Logger.log_error("PeerBuffCheck: Tried to check a peer's buff, but that peer isn't found! If this behavior continues, please report this. Spell:%s(ID:%d), Target:%s(ID:%d)",
            spellName, spellId, targetName, targetId)
        return false
    end

    if DanNet.query(targetName, string.format("Me.BlockedBuff[%s]", spellName), 1000):lower() == spellName:lower() then
        Logger.log_verbose("PeerBuffCheck: Tried to check a peer's buff, but that peer seems to have it blocked. Spell:%s(ID:%d), Target:%s(ID:%d)", spellName, spellId, targetName,
            targetId)
        return false
    end

    local spellResult = DanNet.query(targetName, string.format("Me.FindBuff[id %d]", spellId), 1000)
    if spellResult:lower() == "null" then
        Logger.log_verbose("PeerBuffCheck: %s(ID:%d) not found on %s(ID:%d), let's check for triggers.", spellName, spellId, targetName, targetId)
        local numEffects = mq.TLO.Spell(spellName).NumEffects()
        local triggerCount = 0
        local triggerFound = 0
        for i = 1, numEffects do
            local triggerSpell = mq.TLO.Spell(spellId).Trigger(i)
            --Some Laz spells report trigger 1 as "Unknown Spell" with an ID of 0, which always reports false on stack checks
            if triggerSpell and triggerSpell() and triggerSpell.ID() > 0 then
                local triggerName = triggerSpell.Name()
                local triggerID = triggerSpell.ID()
                local triggerResult = DanNet.query(targetName, string.format("Me.FindBuff[id %d]", triggerID), 1000)
                if triggerResult:lower() == "null" then
                    Logger.log_verbose("PeerBuffCheck: %s(ID:%d) not found on %s(ID:%d), checking stacking.", triggerName, triggerID, targetName, targetId)
                    local triggerStackResult = DanNet.query(targetName, string.format("Spell[%s].Stacks", triggerName), 1000)
                    if triggerStackResult:lower() == "true" then
                        Logger.log_verbose("PeerBuffCheck: %s(ID:%d) seems to stack on %s(ID:%d), let's do it!", triggerName, triggerID, targetName, targetId)
                        return true
                    else
                        Logger.log_verbose("PeerBuffCheck: %s(ID:%d) does not stack on %s(ID:%d), moving on.", triggerName, triggerID, targetName, targetId)
                        triggerFound = triggerFound + 1
                    end
                elseif triggerResult:lower() == triggerName:lower() then
                    Logger.log_verbose("PeerBuffCheck: %s(ID:%d) found on %s(ID:%d), moving on.", triggerName, triggerID, targetName, targetId)
                    triggerFound = triggerFound + 1
                end
                triggerCount = triggerCount + 1
            else
                Logger.log_verbose("PeerBuffCheck: We've checked every trigger for %s(ID:%d).", spellName, spellId)
                break
            end
        end
        if triggerCount > 0 and triggerFound >= triggerCount then
            Logger.log_verbose("PeerBuffCheck: Total triggers for %s(ID:%d): %d. Present or non-stacking triggers: %d. Ending Check.", spellName, spellId, triggerCount, triggerFound)
            return false
        end
    elseif spellResult:lower() == spellName:lower() then
        Logger.log_verbose("PeerBuffCheck: %s(ID:%d) found on %s(ID:%d), ending check.", spellName, spellId, targetName, targetId)
        return false
    else
        Logger.log_error("PeerBuffCheck: Tried to check buff presence for %s(ID:%d), but something seems to have gone wrong! Please report this.")
        return false
    end

    local stackResult = DanNet.query(targetName, string.format("Spell[%d].Stacks", spellId), 1000)
    if stackResult:lower() == "true" then
        Logger.log_verbose("PeerBuffCheck: %s(ID:%d) seems to stack on %s(ID:%d), let's do it!", spellName, spellId, targetName, targetId)
        return true
    end
    Logger.log_verbose("PeerBuffCheck: %s(ID:%d) does not seem to stack, ending check.", spellName, spellId)
    return false
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

--- Determines whether the the PC should be shrunk.
--- @return boolean True if the PC should be shrunk, false otherwise.
function Casting.ShouldShrink()
    return Config:GetSetting('DoShrink') and mq.TLO.Me.Height() > 2.2 and
        (Config:GetSetting('ShrinkItem'):len() > 0) and Casting.OkayToBuff()
end

--- Determines whether the pet should be shrunk.
--- @return boolean True if the pet should be shrunk, false otherwise.
function Casting.ShouldShrinkPet()
    return Config:GetSetting('DoShrinkPet') and mq.TLO.Me.Pet.ID() > 0 and mq.TLO.Me.Pet.Height() > 1.8 and
        (Config:GetSetting('ShrinkPetItem'):len() > 0) and Casting.OkayToPetBuff()
end

--- Checks if the burn condition is met for RGMercs.
--- This function evaluates certain criteria to determine if the burn phase should be initiated.
--- @return boolean True if the burn condition is met, false otherwise.
function Casting.BurnCheck()
    local settings = Config:GetSettings()
    local autoBurn = settings.BurnAuto and
        ((Targeting.GetXTHaterCount() >= settings.BurnMobCount) or (Targeting.IsNamed(Targeting.GetAutoTarget()) and settings.BurnNamed))
    local alwaysBurn = (settings.BurnAlways and settings.BurnAuto)
    local forcedBurn = Targeting.ForceBurnTargetID > 0 and Targeting.ForceBurnTargetID == mq.TLO.Target.ID()

    Casting.LastBurnCheck = autoBurn or alwaysBurn or forcedBurn
    return Casting.LastBurnCheck
end

--- GOMCheck performs a check if Gift of Mana is active.
--- This function does not take any parameters.
--- @return boolean
function Casting.GOMCheck()
    return Casting.IHaveBuff("Gift of Mana")
end

--- Checks if a gambit spell is active.
--- @return boolean Returns true if the gambit condition is met, false otherwise.
function Casting.GambitCheck() -- This should probably be moved to wizard as a helper --Algar
    local gambitSpell = Core.GetResolvedActionMapItem('GambitSpell')
    if not gambitSpell or not gambitSpell() then return false end

    return Casting.IHaveBuff(gambitSpell)
end

--- Stub seemingly intended for alliance spell use
--- @return boolean True if an alliance can be formed, false otherwise.
function Casting.CanAlliance()
    return true
end

-- Function to ensure that a corpse we've detected hasn't previously accepted a rez already (stops spam rez on emu).
function Casting.OkayToRez(corpseId)
    if Core.OnEMU() then
        Targeting.SetTarget(corpseId, true)
        Core.DoCmd("/consider")

        local maxWait = 1000
        while maxWait > 0 do
            mq.doevents('CorpseConned')
            mq.delay(50)
            if not mq.TLO.Spawn(corpseId)() then
                Logger.log_debug("\atEmuOkayToRez(): Corpse ID %d no longer exists, did someone else rez it? Aborting.", corpseId or 0)
                return false
            end
            if Config.Globals.CorpseConned then
                mq.doevents('AlreadyRezzed')
                if Tables.TableContains(Config.Globals.RezzedCorpses, corpseId) then
                    Logger.log_debug("\atEmuOkayToRez(): Checked corpse ID %d, and it appears to have been rezzed already. Aborting.", corpseId or 0)
                    return false
                else
                    Logger.log_debug("\atEmuOkayToRez(): Checked corpse ID %d, and it appears to be in need of a rez. Proceeding.", corpseId or 0)
                    break
                end
            end

            maxWait = maxWait - 50
            if maxWait <= 0 then
                Logger.log_info(
                    "\atEmuOkayToRez(): \arWarning! \atChecked corpse ID %d, but did not receive a con message. Allowing the check to proceed, but this may rez a corpse that has previously received one.",
                    corpseId or 0)
            end
        end
        Config.Globals.CorpseConned = false
    end

    if mq.TLO.Spawn(corpseId).Distance3D() > 25 then
        Targeting.SetTarget(corpseId, true)
        Core.DoCmd("/corpse")
    end

    return true
end

--- Determine if the time is opportune to cast buffs.
--- @return boolean
function Casting.OkayToBuff()
    if not Config:GetSetting('DoBuffs') then return false end
    return Casting.CheckOkayToBuff()
end

--- Determine if the time is opportune to summon or buff pets.
--- @return boolean Returns true if the pet check is successful, false otherwise.
function Casting.OkayToPetBuff()
    if not Config:GetSetting('DoPet') then return false end
    return Casting.CheckOkayToBuff()
end

--- Perform ancillary checks to facilitate OkaytoBuff checks.
function Casting.CheckOkayToBuff()
    local visible = not mq.TLO.Me.Invis()
    local safe = Targeting.GetXTHaterCount() == 0 and Config.Globals.AutoTargetID == 0
    local stationary = not (Config:GetSetting('BuffWaitMoveTimer') > Config:GetTimeSinceLastMove() or mq.TLO.MoveTo.Moving() or mq.TLO.Me.Moving() or mq.TLO.AdvPath.Following() or mq.TLO.Navigation.Active())
    local able = not (Config.Constants.RGCasters:contains(mq.TLO.Me.Class.ShortName()) and mq.TLO.Me.PctMana() < 10)

    return visible and safe and stationary and able
end

--- Checks if the PC should use debuffs based off of con color or named settings.
--- @return boolean True if the target matches the Con requirements for debuffing.
function Casting.OkayToDebuff()
    local named = Targeting.IsNamed(Targeting.GetAutoTarget())
    local debuffChoice = Config.Constants.DebuffChoice[Config:GetSetting(named and 'NamedDebuff' or 'MobDebuff')]
    local conLevel = (Config.Constants.ConColorsNameToId[mq.TLO.Target.ConColor() or "Grey"] or 0)

    return debuffChoice == "Always" or (debuffChoice == "Based on Con Color" and conLevel >= Config:GetSetting('DebuffMinCon'))
end

--- Determines if the PC can/should use buffs if their corpse is nearby.
--- @return boolean True if the entity can be buffed, false otherwise.
function Casting.AmIBuffable()
    local myCorpseCount = Config:GetSetting('BuffRezables') and 0 or mq.TLO.SpawnCount(string.format('pccorpse %s radius 100 zradius 50', mq.TLO.Me.CleanName()))()
    if myCorpseCount > 0 then Logger.log_debug("Corpse detected (%s), aborting rotation.", mq.TLO.Me.CleanName()) end
    return myCorpseCount == 0
end

--- Retrieves the list of group IDs that should be buffed.
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

--- Checks if the character is currently feigning death.
--- @return boolean True if the character is feigning death, false otherwise.
function Casting.IAmFeigning()
    return mq.TLO.Me.State():lower() == "feign"
end

--- Checks if a spell is loaded on the spellbar.
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell is loaded, false otherwise.
function Casting.SpellLoaded(spell)
    if not spell or not spell() then return false end

    return mq.TLO.Me.Gem(spell.RankName.Name())() ~= nil
end

--- Checks if the spell is ready to cast (not in refresh, no gem timer)
function Casting.CastReady(spell)
    if not spell or not spell() then return false end
    return mq.TLO.Me.SpellReady(spell.RankName.Name())()
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

    while (mq.TLO.Me.Gem(gem)() ~= mq.TLO.Spell(spell).Name() or (waitSpellReady and not mq.TLO.Me.SpellReady(gem)())) and maxWait > 0 do
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

--- Retrieves the rank of a specified Alternate Advancement (AA) ability.
--- @param aaName string The name of the AA ability.
--- @return number The rank of the specified AA ability.
function Casting.AARank(aaName)
    return Casting.CanUseAA(aaName) and mq.TLO.Me.AltAbility(aaName).Rank() or 0
end

--- Helper to retrive an AA spell to be used in other checks.
function Casting.GetAASpell(aaName)
    return mq.TLO.Me.AltAbility(aaName).Spell
end

--- Checks if the disc in question is an active disc (not a buff; displayed in the disc window)
--- @param name string The name to check.
--- @return boolean True if the name is a discipline, false otherwise.
function Casting.IsActiveDisc(name)
    local spell = mq.TLO.Spell(name)

    return (spell() and spell.IsSkill() and spell.Duration.TotalSeconds() > 0 and not spell.StacksWithDiscs() and spell.TargetType():lower() == "self") and
        true or false
end

-- helper to check if a disc is currently active in the disc window
function Casting.NoDiscActive()
    return not mq.TLO.Me.ActiveDisc.ID()
end

-- Check if an item has a clicky effect.
function Casting.ItemHasClicky(itemName)
    local item = mq.TLO.FindItem(string.format("=%s", itemName or "None"))
    if not (item and item()) then return false end

    return item.Clicky() ~= nil
end

-- Helper to retrieve a Clicky spell to be used in other checks.
function Casting.GetClickySpell(itemName)
    local item = mq.TLO.FindItem(string.format("=%s", itemName or "None"))
    if not (item and item()) then return false end

    return item.Clicky and item.Clicky.Spell or "None"
end

--- Retrieves the ID of the item summoned by a given spell.
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

--- This function evaluates the current mana level and allows actions based on the result.
--- @param bRestrictBurns boolean|nil True if this function should ignore burn status, false otherwise.
--- @return boolean True if you have more mana than Mana To Nuke or are burning, false otherwise
function Casting.HaveManaToNuke(bRestrictBurns)
    return mq.TLO.Me.PctMana() >= Config:GetSetting('ManaToNuke') or (not bRestrictBurns and Casting.BurnCheck())
end

--- This function evaluates the current mana level and allows actions based on the result.
--- @param bRestrictBurns boolean|nil True if this function should ignore burn status, false otherwise.
--- @return boolean True if you have more mana than Mana To Dot or are burning, false otherwise
function Casting.HaveManaToDot(bRestrictBurns)
    return mq.TLO.Me.PctMana() >= Config:GetSetting('ManaToDot') or (not bRestrictBurns and Casting.BurnCheck())
end

--- This function evaluates the current mana level and allows actions based on the result.
--- @param bRestrictBurns boolean|nil True if this function should ignore burn status, false otherwise.
--- @return boolean True if you have more mana than Mana To Debuff or are burning, false otherwise
function Casting.HaveManaToDebuff(bRestrictBurns)
    return mq.TLO.Me.PctMana() >= Config:GetSetting('ManaToDebuff') or (not bRestrictBurns and Casting.BurnCheck())
end

---- "DetXChecks"s are helper functions that wrap debuff spells and checks in an easy-to-understand system for simpler class configs

function Casting.DetSpellCheck(spell, target)
    if not (spell and spell()) then return false end
    if not target then target = Targeting.GetAutoTarget() or mq.TLO.Target end
    ---@diagnostic disable-next-line: undefined-field
    local spellId = mq.TLO.Me.Spell(spell).ID() or spell.RankName.ID()
    return Casting.TargetBuffCheck(spellId, target)
end

function Casting.DetAACheck(aaName, target)
    if not Casting.CanUseAA(aaName) then return false end
    if not target then target = Targeting.GetAutoTarget() or mq.TLO.Target end

    return Casting.TargetBuffCheck(mq.TLO.Me.AltAbility(aaName).Spell.ID(), target)
end

function Casting.DetItemCheck(itemName, target)
    local clickySpell = Casting.GetClickySpell(itemName)
    if not (clickySpell and clickySpell()) then return false end
    if not target then target = Targeting.GetAutoTarget() or mq.TLO.Target end

    return Casting.TargetBuffCheck(clickySpell.ID(), target)
end

-- Checks HP thresholds and presence/stacking for Dots.
function Casting.DotSpellCheck(spell, target)
    if not (spell and spell()) then return false end
    if not target then target = Targeting.GetAutoTarget() or mq.TLO.Target end

    if Targeting.MobHasLowHP(target) then return false end
    ---@diagnostic disable-next-line: undefined-field
    local spellId = mq.TLO.Me.Spell(spell).ID() or spell.RankName.ID()

    return Casting.TargetBuffCheck(spellId, target)
end

--- Checks if a player character's spell is ready to be cast.
--- @param spell MQSpell The name of the spell to check.
--- @return boolean Returns true if the spell is ready, false otherwise.
function Casting.SpellReady(spell, skipGemTimer)
    if not spell or not spell() then return false end

    local ready = mq.TLO.Me.SpellReady(spell.RankName.Name())()
    local bookCheck = mq.TLO.Me.Book(spell.RankName.Name())()
    local silenced = mq.TLO.Me.Silenced() ~= nil

    Logger.log_verbose("SpellReady for %s(%d): Silenced (%s), BookCheck(%s), ReadyCheck(%s), Memorization Allowed (%s).", spell.RankName(), spell.ID(),
        Strings.BoolToColorString(silenced), Strings.BoolToColorString(bookCheck), Strings.BoolToColorString(ready), Strings.BoolToColorString(skipGemTimer))

    if silenced or not bookCheck or (not ready and not skipGemTimer) then return false end

    return Casting.CastCheck(spell)
end

--- Checks if a given discipline spell is ready to be used by the player character.
--- @param songSpell MQSpell The name of the song spell to check.
--- @return boolean Returns true if the song is ready, false otherwise.
function Casting.SongReady(songSpell, skipGemTimer)
    if not songSpell or not songSpell() then return false end

    local ready = mq.TLO.Me.SpellReady(songSpell.RankName.Name())()
    local bookCheck = mq.TLO.Me.Book(songSpell.RankName.Name())()
    local silenced = mq.TLO.Me.Silenced() ~= nil

    Logger.log_verbose("SongReady for %s(%d): Silenced (%s), BookCheck(%s), ReadyCheck(%s), Memorization Allowed (%s).", songSpell.RankName(), songSpell.ID(),
        Strings.BoolToColorString(silenced), Strings.BoolToColorString(bookCheck), Strings.BoolToColorString(ready), Strings.BoolToColorString(skipGemTimer))

    if silenced or not bookCheck or (not ready and not skipGemTimer) then return false end

    return Casting.CastCheck(songSpell)
end

--- Checks if a given discipline spell is ready to be used by the player character.
--- @param discSpell MQSpell The name of the discipline spell to check.
--- @return boolean Returns true if the discipline is ready, false otherwise.
function Casting.DiscReady(discSpell)
    if not discSpell or not discSpell() then return false end

    local ready = mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())()

    Logger.log_verbose("DiscReady for %s(%d): Ready(%s)", discSpell.RankName.Name(), discSpell.ID(), Strings.BoolToColorString(ready))

    if not ready then return false end

    return Casting.CastCheck(discSpell, true)
end

--- Checks if a specific Alternate Advancement (AA) ability is ready to use.
--- @param aaName string The name of the AA ability to check.
--- @return boolean Returns true if the AA ability is ready, false otherwise.
function Casting.AAReady(aaName)
    local me = mq.TLO.Me
    if not me.AltAbility(aaName) then return false end

    local ready = me.AltAbilityReady(aaName)()
    local aaSpell = me.AltAbility(aaName).Spell

    Logger.log_verbose("AAReady for AA %s (aaSpell: %s, %d): Ready(%s).", aaName, (aaSpell.Name() or "None"), (aaSpell.ID() or 0), Strings.BoolToColorString(ready))

    if not ready then return false end

    return Casting.CastCheck(aaSpell)
end

--- Checks if a given ability is ready to be used.
--- @param abilityName string The name of the ability to check.
--- @param target MQSpawn|nil The intended target of the ability.
--- @return boolean True if the ability is ready, false otherwise.
function Casting.AbilityReady(abilityName, target)
    if not target then target = mq.TLO.Target end
    if not target or not target() then return false end

    local ready = mq.TLO.Me.AbilityReady(abilityName)()

    Logger.log_verbose("AbilityReady for  %s: Ready(%s)", abilityName, Strings.BoolToColorString(ready))

    if not ready then return false end

    return Targeting.GetTargetDistance(target) <= Targeting.GetTargetMaxRangeTo(target) or abilityName:lower() == "taunt"
end

--- Checks if a given item is ready to be used.
function Casting.ItemReady(itemName)
    if not Casting.ItemHasClicky(itemName) then return false end

    local ready = mq.TLO.Me.ItemReady(itemName)()
    local levelCheck = mq.TLO.Me.Level() >= mq.TLO.FindItem("=" .. itemName).Clicky.RequiredLevel()

    Logger.log_verbose("ItemReady for  %s: Ready(%s) LevelCheck(%s)", itemName, Strings.BoolToColorString(ready), Strings.BoolToColorString(levelCheck))

    if not ready then return false end

    return levelCheck
end

-- Helper function for use in determining whether we are ready to perform other actions.
function Casting.CastCheck(spell, bAllowMove)
    if not spell or not spell() then return false end

    local me = mq.TLO.Me
    local castingCheck = not (me.Casting() or mq.TLO.Window("CastingWindow").Open())
    local movingCheck = bAllowMove or Core.MyClassIs("brd") or not (me.Moving() and (spell.MyCastTime() or -1) > 0)

    local currentMana = me.CurrentMana()
    local currentEnd = me.CurrentEndurance()
    if Config.Globals.InMedState then --ensure false mana/end ticks don't make us stand early if we are medding by removing 2 ticks of resting for cost checks.
        currentMana = math.max(0, me.CurrentMana() - (2 * me.ManaRegen()))
        currentEnd = math.max(0, me.CurrentEndurance() - (2 * me.EnduranceRegen()))
    end
    local manaCheck = spell.Mana() == 0 or currentMana >= spell.Mana()
    local endCheck = spell.EnduranceCost() == 0 or currentEnd >= spell.EnduranceCost()

    ---@diagnostic disable-next-line: undefined-field -- Feared is a valid data member
    local controlCheck = not (me.Stunned() or me.Feared() or me.Charmed() or me.Mezzed())

    Logger.log_verbose("CastCheck for %s (%d): CastingCheck(%s), MovingCheck(%s), ManaCheck(%s), EndCheck(%s), ControlCheck(%s)", spell.Name(), spell.ID(),
        Strings.BoolToColorString(castingCheck), Strings.BoolToColorString(movingCheck), Strings.BoolToColorString(manaCheck), Strings.BoolToColorString(endCheck),
        Strings.BoolToColorString(controlCheck))

    return castingCheck and movingCheck and manaCheck and endCheck and controlCheck
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

        if (not Config:GetSetting('IgnoreLevelCheck')) and targetSpawn() and Targeting.TargetIsType("pc", targetSpawn) then
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

        if (Targeting.GetXTHaterCount() > 0 or not bAllowMem) and (not Casting.CastReady(spell) or not mq.TLO.Me.Gem(spellName)()) then
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

        --if not spell.StacksTarget() then
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

        if (Targeting.GetXTHaterCount() > 0 or not bAllowMem) and (not Casting.CastReady(spell) or not mq.TLO.Me.Gem(songName)()) then
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

        local spellRange = spell.MyRange() > 0 and spell.MyRange() or (spell.AERange() > 0 and spell.AERange() or 250)

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

                if (not targetSpawn or not targetSpawn() or Targeting.TargetIsType("corpse", targetSpawn)) and spell.SpellType() == "Detrimental" then
                    mq.TLO.Me.StopCast()
                    Logger.log_debug("UseSong(): Canceled singing %s because target is dead or no longer exists.", songName)
                    break
                elseif targetSpawn() and Targeting.GetTargetID() > 0 and targetSpawn.ID() ~= Targeting.GetTargetID() and spell.SpellType() == "Detrimental" then
                    mq.TLO.Me.StopCast()
                    Logger.log_debug("UseSong(): Canceled singing %s because spellTarget(%s/%d) is no longer myTarget(%s/%d)", songName, targetSpawn.CleanName() or "",
                        targetSpawn.ID(), Targeting.GetTargetCleanName(), Targeting.GetTargetID())
                    break
                elseif targetSpawn() and Targeting.GetTargetDistance(targetSpawn) > (spellRange * 1.1) then --allow for slight movement in and out of range, if the target runs off, this is still easily triggered
                    mq.TLO.Me.StopCast()
                    Logger.log_debug("UseSong(): Canceled singing %s because spellTarget(%d, range %d) is out of spell range(%d)", songName, targetSpawn.ID(),
                        Targeting.GetTargetDistance(), spellRange)
                    break
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

--- Uses a discipline spell on a specified target.
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

--- Uses the specified ability.
--- @param abilityName string The name of the ability to use.
function Casting.UseAbility(abilityName)
    local me = mq.TLO.Me
    Core.DoCmd("/doability %s", abilityName)
    mq.delay(8, function() return not me.AbilityReady(abilityName) end)
    Logger.log_debug("Using Ability \ao =>> \ag %s \ao <<=", abilityName)
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
        if Casting.IHaveBuff(item.Clicky.Spell.ID()) then
            Logger.log_debug("\awUseItem(\ag%s\aw): \arTried to use item - but the clicky buff is already active!", itemName)
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

    -- Not satisifed with below, I intend to refactor to use waitcastfinish(); I'll adjust waiting to start at that time.
    if not item.CastTime() or item.CastTime() < 101 then
        -- slight delay for instant casts, bypass checking for cast window on faster casts, as the client may never see the cast at all.
        local delay = item.CastTime() or 20
        mq.delay(delay)
    else
        local maxWait = 1000
        while maxWait > 0 and not me.Casting() do
            Logger.log_verbose("Waiting for item to start casting...")
            mq.delay(50)
            mq.doevents()
            -- in case very fast casts serverside don't make it to the client
            -- this was originall added for 100ms clickies on laz that don't ever show casting (which has now been addressed above), but left as a fallback
            if not me.ItemReady(itemName) then
                Logger.log_debug("No start cast noted, but item now reports on cooldown, moving on.")
                break
            end
            maxWait = maxWait - 50
        end
        mq.delay(item.CastTime(), function() return not me.Casting() end)

        -- pick up any additonal server lag.
        while me.Casting() do
            mq.delay(10)
            mq.doevents()
        end
    end

    if mq.TLO.Cursor.ID() then
        Core.DoCmd("/autoinv")
    end

    if oldTargetId > 0 then
        Logger.log_debug("UseItem():switching target back to old target after item use.")
        Targeting.SetTarget(oldTargetId, true)
    end

    return true
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

--- Waits for the casting to finish on the specified target.
--- @param target MQSpawn The target to wait for the casting to finish.
--- @param bAllowDead boolean Whether to allow the target to be dead.
function Casting.WaitCastFinish(target, bAllowDead, spellRange) --I am not vested in the math below, I simply converted the existing entry from sec to ms
    local maxWaitOrig = ((mq.TLO.Me.Casting.MyCastTime() or 0) + ((mq.TLO.EverQuest.Ping() * 20) + 1000))
    local maxWait = maxWaitOrig

    while mq.TLO.Me.Casting() do
        local currentCast = mq.TLO.Me.Casting()
        Logger.log_super_verbose("WaitCastFinish(): Waiting to Finish Casting...")
        mq.delay(20)
        if (not target or not target() or Targeting.TargetIsType("corpse", target)) and not bAllowDead then
            mq.TLO.Me.StopCast()
            Logger.log_debug("WaitCastFinish(): Canceled casting %s because target is dead or no longer exists.", currentCast)
            return
        elseif target() and Targeting.GetTargetID() > 0 and target.ID() ~= Targeting.GetTargetID() then
            mq.TLO.Me.StopCast()
            Logger.log_debug("WaitCastFinish(): Canceled casting %s because spellTarget(%s/%d) is no longer myTarget(%s/%d)", currentCast, target.CleanName() or "",
                target.ID(), Targeting.GetTargetCleanName(), Targeting.GetTargetID())
            return
        elseif target() and Targeting.GetTargetDistance(target) > (spellRange * 1.1) then --allow for slight movement in and out of range, if the target runs off, this is still easily triggered
            mq.TLO.Me.StopCast()
            Logger.log_debug("WaitCastFinish(): Canceled casting %s because spellTarget(%d, range %d) is out of spell range(%d)", currentCast, target.ID(),
                Targeting.GetTargetDistance(), spellRange)
            return
        elseif target() and target.ID() ~= Targeting.GetTargetID() then
            Logger.log_debug("WaitCastFinish(): Warning your spellTarget(%d) for %s is no longer your currentTarget(%d)", target.ID(), currentCast, Targeting.GetTargetID())
        end

        if (maxWaitOrig - maxWait) % 200 == 0 and Combat.DoCombatActions() and not mq.TLO.Me.Pet.Combat() then --alleviate pets standing around at early levels where mob HPs are low and cast times are long
            if ((Config:GetSetting('DoPet') or Config:GetSetting('CharmOn')) and mq.TLO.Pet.ID() ~= 0) and (Targeting.GetTargetPctHPs(Targeting.GetAutoTarget()) <= Config:GetSetting('PetEngagePct')) then
                Combat.PetAttack(Config.Globals.AutoTargetID, true)
            end
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

--- Waits for the global cooldown to complete.
--- This function pauses execution until the global cooldown period has elapsed.
--- @param logPrefix string|nil: An optional prefix to be used in log messages.
function Casting.WaitGlobalCoolDown(logPrefix)
    while mq.TLO.Me.SpellInCooldown() do
        mq.delay(100)
        mq.doevents()
        Logger.log_verbose(logPrefix and logPrefix or "" .. "Waiting for Global Cooldown to be ready...")
    end
end

--- Retrieves the name of the last cast result.
--- @return string The name of the last cast result.
function Casting.GetLastCastResultName()
    return Config.Constants.CastResultsIdToName[Config.Globals.CastResult]
end

--- Retrieves the ID of the last cast result.
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

--- Retrieves the last used spell.
--- @return string The name of the last used spell.
function Casting.GetLastUsedSpell()
    return Config.Globals.LastUsedSpell
end

--- Automatically manages the medication process for the character.
--- This function handles the logic for ensuring the character takes the necessary medication at the appropriate times.
function Casting.AutoMed()
    local me = mq.TLO.Me
    if Config:GetSetting('DoMed') == 1 then return end

    if Core.MyClassIs("BRD") and me.Level() > 5 and not Config:GetSetting('BardRespectMedState', true) then return end

    if me.Mount.ID() and not mq.TLO.Zone.Indoor() then
        Logger.log_verbose("Sit check returning early due to mount.")
        return
    end

    if Config:GetSetting('MedAggroCheck') and Targeting.IHaveAggro(Config:GetSetting("MedAggroPct")) then
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
        if Targeting.GetXTHaterCount() > 0 and (Config:GetSetting('DoMed') ~= 3 or Config:GetSetting('DoMelee') or ((Config:GetSetting('MedAggroCheck') and Targeting.IHaveAggro(Config:GetSetting('MedAggroPct'))))) then
            Config.Globals.InMedState = false
            Logger.log_debug("Forcing stand - Combat or aggro threshold reached.")
            me.Stand()
            return
        end

        if (Config:GetSetting('StandWhenDone') or Config:GetSetting('DoPull')) and forcestand then
            Config.Globals.InMedState = false
            Logger.log_debug("Forcing stand - all conditions met.")
            me.Stand()
            return
        end
    end

    -- if we aren't sitting, see if we were already medding and we got interrupted, or if our checks above say we should start medding
    if not me.Sitting() and (Config.Globals.InMedState or forcesit) then
        Config.Globals.InMedState = true
        Logger.log_debug("Forcing sit - all conditions met.")
        me.Sit()
    end
end

--renamed function due to misleading name, deprecated.
function Casting.GetBestAA(aaList)
    return Casting.GetFirstAA(aaList)
end

--- Retrieves the first available purchased AA in a list.
--- @param aaList table The list of AA to check.
--- @return string The name of the selected AA (or "None" if no ability was found).
function Casting.GetFirstAA(aaList)
    if not aaList or type(aaList) ~= "table" then return "None" end

    local ret = "None"
    for _, abil in ipairs(aaList) do
        if Casting.CanUseAA(abil) then
            ret = abil
            break
        end
    end
    return ret
end

--- Retrieves the first available resolved map item in a list.
--- @param mapList table The list of mapped actions to check.
--- @return string The name of the selected map (or "None" if no ability was found).
function Casting.GetFirstMapItem(mapList)
    if not mapList or type(mapList) ~= "table" then return "None" end

    local ret = "None"
    for _, abil in ipairs(mapList) do
        if Core.GetResolvedActionMapItem(abil) then
            ret = abil
            break
        end
    end
    return ret
end

--- Function to execute use of modrods.
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

return Casting
