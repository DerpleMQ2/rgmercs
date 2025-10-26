local mq          = require('mq')
local Config      = require('utils.config')
local Core        = require("utils.core")
local Targeting   = require("utils.targeting")
local Casting     = require("utils.casting")
local ItemManager = require("utils.item_manager")
local Logger      = require("utils.logger")
local Set         = require('mq.set')

return {
    _version              = "2.0 - EQ Might (WIP)",
    _author               = "Derple, Algar",
    ['ModeChecks']        = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
        IsHealing = function() return true end,
        IsCuring = function() return Config:GetSetting('DoCureAA') or Config:GetSetting('DoCureSpells') end,
        IsRezing = function() return (Config:GetSetting('DoBattleRez') and not Core.IsTanking()) or Targeting.GetXTHaterCount() == 0 end,
        --Disabling tank battle rez is not optional to prevent settings in different areas and to avoid causing more potential deaths
    },
    ['Modes']             = {
        'Tank',
        'DPS',
    },
    ['Cures']             = {
        GetCureSpells = function(self)
            --(re)initialize the table for loadout changes
            self.TempSettings.CureSpells = {}

            -- Find the map for each cure spell we need
            -- Curse is convoluted: If Keepmemmed, always use cure, if not, use groupheal if available and fallback to cure
            local neededCures = {
                ['Poison'] = 'PurityCure',
                ['Disease'] = 'PurityCure',
                ['Curse'] = not Config:GetSetting('KeepCurseMemmed') and ('PurityCure' or 'CureCurse') or 'CureCurse',
                -- ['Corruption'] = -- Project Lazarus does not currently have any Corruption Cures.
            }

            -- iterate to actually resolve the selected map item, if it is valid, add it to the cure table
            for k, v in pairs(neededCures) do
                local cureSpell = Core.GetResolvedActionMapItem(v)
                if cureSpell then
                    self.TempSettings.CureSpells[k] = cureSpell
                end
            end
        end,
        CureNow = function(self, type, targetId)
            local targetSpawn = mq.TLO.Spawn(targetId)
            if not targetSpawn and targetSpawn then return false, false end

            if Config:GetSetting('DoCureAA') then
                local cureAA = Casting.AAReady("Radiant Cure") and "Radiant Cure"

                if not cureAA and targetId == mq.TLO.Me.ID() and Casting.AAReady("Purification") then
                    cureAA = "Purification"
                end

                if cureAA then
                    Logger.log_debug("CureNow: Using %s for %s on %s.", cureAA, type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
                    return Casting.UseAA(cureAA, targetId), true
                end
            end

            if Config:GetSetting('DoCureSpells') then
                for effectType, cureSpell in pairs(self.TempSettings.CureSpells) do
                    if type:lower() == effectType:lower() then
                        Logger.log_debug("CureNow: Using %s for %s on %s.", cureSpell.RankName(), type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
                        return Casting.UseSpell(cureSpell.RankName(), targetId, true), true
                    end
                end
            end

            Logger.log_debug("CureNow: No valid cure at this time for %s on %s.", type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
            return false, false
        end,
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Nightbane, Sword of the Valiant",
            "Redemption",
        },
        ['OoW_Chest'] = {
            "Dawnseeker's Chestpiece of the Defender",
            "Oathbound Breastplate",
        },
    },
    ['AbilitySets']       = {
        ["WardProc"] = {
            -- Timer 12 - Preservation
            "Ward of Tunare", -- Level 70
        },
        ["QuickUndeadNuke"] = {
            -- Undead Quick Nuke with chance to snare and reduce AC
            "Burial Rites", -- EQ Custom
            "Last Rites",   -- Level 68 - Timer 7
        },
        ["DDProc"] = {
            --- Fury Proc Strike
            "Divine Might", -- Level 45, 65pt
            "Pious Might",  -- Level 63, 150pt
            "Holy Order",   -- Level 65, 180pt
            "Pious Fury",   -- Level 68, 250pt, + 250pt if undead
        },
        ["UndeadProc"] = {
            --- Undead Proc Strike : does not stack with Fury Proc, will be used until Fury is available even if setting not enabled.
            "Instrument of Nife",      -- Level 26, 243pt
            "Ward of Nife",            -- Level 62, 500pt
            "Silvered Fury",           -- Level 67, 750pt
        },
        ["StunTimer5"] = {             -- mq.TLO.Target.ID() == target and not mq.TLO.Spawn(target).Stunned()
            "Desist",                  -- Level 13 - Not Timer 5, use for TLP Low Level Stun
            "Stun",                    -- Level 28
            "Force of Akera",          -- Level 53
            "Ancient: Force of Chaos", -- Level 65
            "Ancient: Force of Jeron", -- Level 70
        },
        ["StunTimer4"] = {
            "Cease",           -- Level 7 - Not Timer 4, use for TLP Low Level Stun
            "Force",           -- Level 52 - Not Timer 4, use for TLP Low Level Stun
            "Force of Akilae", -- Level 62
            "Force of Piety",  -- Level 66
            "Sacred Force",    -- EQM Custom
        },
        ["AegoBuff"] = {
            --- Pally Aegolism
            "Courage",               -- Level 8
            "Center",                -- Level 20
            "Daring",                -- Level 37
            "Valor",                 -- Level 47
            "Austerity",             -- Level 55 --First actual Aego
            "Blessing of Austerity", -- Level 58 - Group
            "Guidance",              -- Level 65
            "Affirmation",           -- Level 70
        },
        -- ['HPTypeOne'] = {
        --     "Hand of Direction", --GV1
        --     "Direction",         --ST
        --     "Heroic Bond",       --ST
        --     "Heroism",           --ST
        --     "Resolution",
        -- },
        ["Brells"] = {
            "Ancient: Brell's Brawny Bulwark",
            "Brell's Vibrant Barricade",
            "Brell's Brawny Bulwark",
            "Brell's Stalwart Shield",
            "Brell's Mountainous Barrier",
            "Brell's Steadfast Aegis",
        },
        ["WaveHeal"] = {
            "Wave of Piety",
            "Wave of Trushar",
            "Wave of Marr",
            "Healing Wave of Prexus",
            "Wave of Healing",
            "Wave of Life",
        },
        ["WaveHeal2"] = {
            "Wave of Piety",
            "Wave of Trushar",
            "Wave of Marr",
            "Healing Wave of Prexus",
            "Wave of Healing",
            "Wave of Life",
        },
        ["Cleansing"] = {
            "Pious Cleansing",     -- Level 69
            "Supernal Cleansing",  -- Level 64
            "Celestial Cleansing", -- Level 59
            "Ethereal Cleansing",  -- Level 44
        },
        ["ArmorSelfBuff"] = {
            --- Self Buff Armor Line Ac/Hp/Mana regen
            "Armor of the Divine",   -- Level 60
            "Aura of the Crusader",  -- Level 64
            "Armor of the Champion", -- Level 69
        },
        ["SymbolBuff"] = {
            "Jeron's Mark",
            "Symbol of Jeron",
            "Symbol of Marzin",
            "Symbol of Naltron",
            "Symbol of Pinzarn",
            "Symbol of Ryltan",
            "Symbol of Transal",
        },
        ["SereneStun"] = {
            --- Lesson Stun - Timer 6
            "Quellious' Word of Tranquility", -- Level 54
            "Quellious' Word of Serenity",    -- Level 64
            "Serene Command",                 -- Level 68
        },
        ["TouchHeal"] = {
            -- Target Light Heal
            "Salve",            -- Level 1
            "Minor Healing",    -- Level 6
            "Light Healing",    -- Level 12
            "Healing",          -- Level 27
            "Greater Healing",  -- Level 36
            "Superior Healing", -- Level 57
            "Touch of Nife",
            "Touch of Piety",
            "Sacred Touch", -- EQM Custom
        },
        ["LightHeal"] = {
            -- ToT Light Heal
            "Light of Life",  -- Level 52
            "Light of Nife",  -- Level 63
            "Light of Order", -- Level 65
            "Light of Piety", -- Level 68
        },
        ["LightHeal2"] = {
            -- ToT Light Heal
            "Light of Life",  -- Level 52
            "Light of Nife",  -- Level 63
            "Light of Order", -- Level 65
            "Light of Piety", -- Level 68
        },
        -- ["Pacify"] = {
        --     "Pacify",
        --     "Calm",
        --     "Soothe",
        --     "Lull",
        -- },
        ["PurityCure"] = {
            --- Purity Cure Poison/Diease Cure Half Power to curse
            "Crusader's Purity",
            "Crusader's Touch",
        },
        ["HealReceivedAura"] = {
            -- Aura Buffs
            "Blessed Aura",
            "Holy Aura",
        },
        ["UndeadNuke"] = {
            -- Undead Nuke
            "Ward Undead",    -- Level 14
            "Expulse Undead", -- Level 30
            "Dismiss Undead", -- Level 46
            "Expel Undead",   -- Level 54
            "Deny Undead",    -- Level 62 - Timer 7
            "Spurn Undead",   -- Level 67 - Timer 7
        },
        ["CureCurse"] = {
            -- Curse Cure Line
            "Remove Minor Curse",
            "Remove Lesser Curse",
            "Remove Curse",
            "Remove Greater Curse",
            "Eradicate Cures",
        },
        ["ForgeDisc"] = {
            "Hallowforge Discipline",
            "Holyforge Discipline",
        },
        ['RezSpell'] = {
            'Resurrection',
            'Restoration',
            'Renewal',
            'Revive',
            'Reparation',
            'Reconstitution',
            'Reanimation',
        },
        ['PBAEStun'] = {                -- does damage
            "Ancient Command of Might", -- EQM Custom
            "Ancient: Force of Might",  -- EQM Custom
        },
        -- ['AEStun'] = {                  --Targeted AE
        --     "Stun Command",             -- no damage
        --     "Sacred Word",              -- does damage
        -- },
        ['BlockDisc'] = {
            "Deflection Discipline",
        },
        ['SancDisc'] = {
            "Sanctification Discipline",
        },
        -- ['TwinHealNuke'] = {
        --     "Justice of Marr",
        -- },
        ['GuardDisc'] = {
            "Ancient: Guard of Chivalry",
            "Guard of Righteousness",
            "Guard of Humility",
            "Guard of Piety",
        },
        ['ACBuff'] = {
            "Bulwark of Piety",
            "Bulwark of Faith",
            "Shield of Words",
            "Armor of Faith",
        },
        ['AEBlades'] = {
            "Whirlwind Blade",
            "Mayhem Blade",
        },
        ['Protective'] = {
            "Protective Discipline",
        },
        ['SelfHeal'] = { -- EQM Custom Zero-Casttime Self-heal
            "Blessed Mantle Heal",
        },
        ['SpellResistBuff'] = {
            "Silent Piety",
        },
    },
    ['SpellList']         = {
        {
            name = "Default",
            -- cond = function(self) return true end, --Kept here for illustration, this line could be removed in this instance since we aren't using conditions.
            spells = {
                { name = "TouchHeal",       cond = function(self) return Config:GetSetting('DoTouchHeal') < 3 end, },
                { name = "LightHeal",       cond = function(self) return Config:GetSetting('DoLightHeal') < 3 end, },
                { name = "LightHeal2",      cond = function(self) return Config:GetSetting('DoLightHeal') == 2 end, },
                { name = "WaveHeal",        cond = function(self) return Config:GetSetting('DoWaveHeal') < 3 end, },
                { name = "WaveHeal2",       cond = function(self) return Config:GetSetting('DoWaveHeal') == 2 end, },
                { name = "SelfHeal", },
                { name = "Cleansing",       cond = function(self) return Config:GetSetting('DoCleansing') < 3 end, },
                -- { name = "TwinHealNuke",    cond = function(self) return Config:GetSetting('DoTwinHealNuke') end, },
                { name = "SereneStun",      cond = function(self) return Config:GetSetting('DoSereneStun') end, },
                { name = "StunTimer4",      cond = function(self) return Core.IsTanking() end, },
                { name = "StunTimer5",      cond = function(self) return Core.IsTanking() end, },
                { name = "PBAEStun",        cond = function(self) return Config:GetSetting('DoPBAEStun') end, },
                -- { name = "AEStun",          cond = function(self) return Config:GetSetting('DoAEStun') end, },
                { name = "CureCurse",       cond = function(self) return Config:GetSetting('KeepCurseMemmed') end, },
                { name = "PurityCure",      cond = function(self) return Config:GetSetting('KeepPurityMemmed') end, },
                { name = "UndeadNuke",      cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "QuickUndeadNuke", cond = function(self) return Config:GetSetting('DoQuickUndeadNuke') end, },
                { name = "WardProc", },
            },
        },
    },
    ['HelperFunctions']   = {
        --Did not include Staff of Forbidden Rites, GoR refresh is very fast and rez is 96%
        DoRez = function(self, corpseId)
            local rezAction = false
            local rezSpell = Core.GetResolvedActionMapItem('RezSpell')
            local okayToRez = Casting.OkayToRez(corpseId)

            if (Config:GetSetting('DoBattleRez') or mq.TLO.Me.CombatState():lower() ~= "combat") and Casting.AAReady("Gift of Resurrection") then
                rezAction = okayToRez and Casting.UseAA("Gift of Resurrection", corpseId, true, 1)
            elseif not Casting.CanUseAA("Gift of Resurrection") and mq.TLO.Me.CombatState():lower() ~= "combat" and Casting.SpellReady(rezSpell, true) then
                rezAction = okayToRez and Casting.UseSpell(rezSpell, corpseId, true, true)
            end

            return rezAction
        end,
        --function to determine if we should AE taunt and optionally, if it is safe to do so
        AETauntCheck = function(printDebug)
            local mobs = mq.TLO.SpawnCount("NPC radius 50 zradius 50")()
            local xtCount = mq.TLO.Me.XTarget() or 0

            if (mobs or xtCount) < Config:GetSetting('AETauntCnt') then return false end

            local tauntme = Set.new({})
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater")) and xtarg.PctAggro() < 100 and (xtarg.Distance() or 999) <= 50 then
                    if printDebug then
                        Logger.log_verbose("AETauntCheck(): XT(%d) Counting %s(%d) as a hater eligible to AE Taunt.", i, xtarg.CleanName() or "None",
                            xtarg.ID())
                    end
                    tauntme:add(xtarg.ID())
                end
                if not Config:GetSetting('SafeAETaunt') and #tauntme:toList() > 0 then return true end --no need to find more than one if we don't care about safe taunt
            end
            return #tauntme:toList() > 0 and not (Config:GetSetting('SafeAETaunt') and #tauntme:toList() < mobs)
        end,
        --function to determine if we have enough mobs in range to use a defensive disc
        DefensiveDiscCheck = function(printDebug)
            local xtCount = mq.TLO.Me.XTarget() or 0
            if xtCount < Config:GetSetting('DiscCount') then return false end
            local haters = Set.new({})
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater")) and (xtarg.Distance() or 999) <= 30 then
                    if printDebug then
                        Logger.log_verbose("DefensiveDiscCheck(): XT(%d) Counting %s(%d) as a hater in range.", i, xtarg.CleanName() or "None", xtarg.ID())
                    end
                    haters:add(xtarg.ID())
                end
                if #haters:toList() >= Config:GetSetting('DiscCount') then return true end -- no need to keep counting once this threshold has been reached
            end
            return false
        end,
        AETargetCheck = function(printDebug)
            local haters = mq.TLO.SpawnCount("NPC xtarhater radius 80 zradius 50")()
            local haterPets = mq.TLO.SpawnCount("NPCpet xtarhater radius 80 zradius 50")()
            local totalHaters = haters + haterPets
            if totalHaters < Config:GetSetting('AETargetCnt') or totalHaters > Config:GetSetting('MaxAETargetCnt') then return false end

            if Config:GetSetting('SafeAEDamage') then
                local npcs = mq.TLO.SpawnCount("NPC radius 80 zradius 50")()
                local npcPets = mq.TLO.SpawnCount("NPCpet radius 80 zradius 50")()
                if totalHaters < (npcs + npcPets) then
                    if printDebug then
                        Logger.log_verbose("AETargetCheck(): %d mobs in range but only %d xtarget haters, blocking AE damage actions.", npcs + npcPets, haters + haterPets)
                    end
                    return false
                end
            end

            return true
        end,
    },
    ['HealRotationOrder'] = {
        {
            name = 'GroupHeal',
            state = 1,
            steps = 1,
            cond = function(self, target) Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'BigHeal',
            state = 1,
            steps = 1,
            cond = function(self, target)
                return Targeting.BigHealsNeeded(target) and not Targeting.TargetIsType("pet", target)
            end,
        },
        {
            name = 'MainHeal',
            state = 1,
            steps = 1,
            load_cond = function(self) return Config:GetSetting('DoCleansing') == 1 or Config:GetSetting("DoTouchHeal") == 2 or Config:GetSetting('WaveHealUse') == 2 end,
            cond = function(self, target)
                return Targeting.MainHealsNeeded(target)
            end,
        },
    },
    ['HealRotations']     = {
        ["GroupHeal"] = {
            {
                name = "Hand of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "Fabled Blue Band of the Oak",
                type = "Item",
            },
            {
                name = "WaveHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') < 3 end,
            },
            {
                name = "WaveHeal2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') == 2 end,
            },
        },
        ["BigHeal"] = {
            {
                name = "Lay on Hands",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.GetTargetPctHPs() < Config:GetSetting('HPCritical')
                end,
            },
            {
                name = "Marr's Gift",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "Hand of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return self.CombatState == "Combat" and (Targeting.TargetIsMyself(target) or Targeting.GetTargetPctHPs() < Config:GetSetting('HPCritical'))
                end,
            },
            {
                name = "WaveHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') < 3 and Config:GetSetting('WaveHealUse') == 1 end,
                cond = function(self, spell, target)
                    return Targeting.GroupedWithTarget(target)
                end,
            },
            {
                name = "WaveHeal2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') == 2 and Config:GetSetting('WaveHealUse') == 1 end,
                cond = function(self, spell, target)
                    return Targeting.GroupedWithTarget(target)
                end,
            },
            {
                name = "TouchHeal",
                type = "Spell",
                load_cond = function() return Config:GetSetting("DoTouchHeal") == 1 end,
            },
        },
        ["MainHeal"] = {
            {
                name = "Cleansing",
                type = "Spell",
                load_cond = function() return Config:GetSetting('DoCleansing') == 1 end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Imbued Rune of Piety",
                type = "Item",
                load_cond = function(self) return mq.TLO.FindItem("=Imbued Rune of Piety")() and Config:GetSetting('WaveHealUse') == 2 end,
                cond = function(self, spell, target)
                    return Targeting.GroupedWithTarget(target)
                end,
            },
            {
                name = "WaveHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') < 3 and Config:GetSetting('WaveHealUse') == 2 end,
                cond = function(self, spell, target)
                    return Targeting.GroupedWithTarget(target)
                end,
            },
            {
                name = "WaveHeal2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') == 2 and Config:GetSetting('WaveHealUse') == 2 end,
                cond = function(self, spell, target)
                    return Targeting.GroupedWithTarget(target)
                end,
            },
            {
                name = "TouchHeal",
                type = "Spell",
                load_cond = function() return Config:GetSetting("DoTouchHeal") == 2 end,
            },
        },
    },
    ['RotationOrder']     = {
        { --Self Buffs
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Core.OkayToNotHeal() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60,
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Core.OkayToNotHeal()
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'HateTools',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function() return Core.IsTanking() end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and Targeting.HateToolsNeeded()
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'AEHateTools',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function()
                local hateSpell = Config:GetSetting('DoPBAEStun') and Core.GetResolvedActionMapItem('PBAEStun')
                local hateAA = Config:GetSetting('AETauntAA') and Casting.CanUseAA("Beacon of the Righteous")
                return Core.IsTanking() and (Core.GetResolvedActionMapItem('AEBlades') or hateSpell or hateAA)
            end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and self.ClassConfig.HelperFunctions.AETauntCheck(true)
            end,
        },
        { --Dynamic weapon swapping if UseBandolier is toggled
            name = 'Weapon Management',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('UseBandolier') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        { --Defensive actions triggered by low HP
            name = 'EmergencyDefenses',
            state = 1,
            steps = 2, -- help ensure that we cancel visage when needed
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
            end,
        },
        { --Prioritized in their own rotation to help keep HP topped to the desired level, includes emergency abilities
            name = 'ToTHeals',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < Config:GetSetting('LightHealPoint')
            end,
        },
        { --Defensive actions used proactively to prevent emergencies
            name = 'Defenses',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= Config:GetSetting('DefenseStart') or Targeting.IsNamed(Targeting.GetAutoTarget()) or
                    self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true)
            end,
        },
        { --Offensive actions to temporarily boost damage dealt
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Casting.BurnCheck() and Core.OkayToNotHeal()
            end,
        },
        { --Stun and damage enemies per your settings
            name = 'AECombat',
            state = 1,
            steps = 1,
            load_cond = function()
                -- local aeSpell = Config:GetSetting('DoAEStun') and Core.GetResolvedActionMapItem('AEStun')
                local pbaeSpell = Config:GetSetting('DoPBAEStun') and Core.GetResolvedActionMapItem('PBAEStun')
                return (Core.IsTanking() or Config:GetSetting('AEStunUse') > 1) and pbaeSpell
            end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if not Config:GetSetting('DoAEDamage') or (Core.IsTanking() and mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical')) then return false end
                return combat_state == "Combat" and self.ClassConfig.HelperFunctions.AETargetCheck(true)
            end,
        },
        { --DPS Spells, includes recourse/gift maintenance
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Core.OkayToNotHeal()
            end,
        },
    },
    ['Rotations']         = {
        ['Downtime'] = {
            {
                name = "Blessing of Life",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SpellResistBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "ArmorSelfBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            --You'll notice my use of TotalSeconds, this is to keep as close to 100% uptime as possible on these buffs, rebuffing early to decrease the chance of them falling off in combat
            --I considered creating a function (helper or utils) to govern this as I use it on multiple classes but the difference between buff window/song window/aa/spell etc makes it unwieldy
            -- if using duration checks, dont use SelfBuffCheck() (as it could return false when the effect is still on)
            {
                name = "WardProc",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWardProc') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return spell.RankName.Stacks() and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 60
                end,
            },
            {
                name_func = function(self)
                    local proc = "Proc Buff Disabled"
                    local procChoice = Config:GetSetting('ProcChoice')
                    if procChoice < 3 then
                        if not Core.GetResolvedActionMapItem("DDProc") or procChoice == 2 then
                            proc = "UndeadProc"
                        else
                            proc = "DDProc"
                        end
                        return proc
                    end
                end,
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "AegoBuff",
                type = "Spell",
                load_cond = function() return Config:GetSetting('AegoSymbol') < 3 end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SymbolBuff",
                type = "Spell",
                load_cond = function() return Config:GetSetting('AegoSymbol') == 3 or Config:GetSetting('AegoSymbol') == 3 end,
                cond = function(self, spell, target)
                    if (spell.TargetType() or ""):lower() == "single" and target.ID() ~= Core.GetMainAssistId() then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Brells",
                type = "Spell",
                load_cond = function() return Config:GetSetting('DoBrells') end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HealReceivedAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.BaseName()) end,
                cond = function(self, spell)
                    return (spell and spell() and not Casting.AuraActiveByName(spell.BaseName()))
                end,
            },
            {
                name = "ACBuff",
                type = "Spell",
                load_cond = function() return Config:GetSetting('DoACBuff') end,
                cond = function(self, spell, target)
                    if (spell.TargetType() or ""):lower() == "single" and target.ID() ~= Core.GetMainAssistId() then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['EmergencyDefenses'] = {
            --Note that in Tank Mode, defensive discs are preemptively cycled on named in the (non-emergency) Defenses rotation
            --Abilities should be placed in order of lowest to highest triggered HP thresholds
            --Some conditionals are commented out while I tweak percentages (or determine if they are necessary)
            {
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, itemName, target)
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            { --Note that on named we may already have a defensive disc running already, could make this remove other discs, but we have other options.
                name = "BlockDisc",
                type = "Disc",
                pre_activate = function(self)
                    if Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            { -- use this only when we have no better active disc to use
                name = "SancDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local blockReady = mq.TLO.Me.CombatAbilityReady(Core.GetResolvedActionMapItem('BlockDisc') or "")()
                    local guardReady = mq.TLO.Me.CombatAbilityReady(Core.GetResolvedActionMapItem('GuardDisc') or "")()
                    local protReady = mq.TLO.Me.CombatAbilityReady(Core.GetResolvedActionMapItem('Protective') or "")()
                    return Casting.NoDiscActive() and not blockReady and not guardReady and not protReady
                end,
            },
        },
        ['HateTools'] = {
            { --more valuable on laz because we have less hate tools and no other hatelist + 1 abilities
                name = "Taunt",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Targeting.LostAutoTargetAggro() and Targeting.GetTargetDistance(target) < 30
                end,
            },
            {
                name = "Force of Disruption",
                type = "AA",
            },
            {
                name = "StunTimer5",
                type = "Spell",
            },
            {
                name = "StunTimer4",
                type = "Spell",
            },
        },
        ['AEHateTools'] = {
            {
                name = "AEBlades",
                type = "Disc",
                cond = function(self, discSpell)
                    return Config:GetSetting('DoAEDamage')
                end,
            },
            {
                name = "Beacon of the Righteous",
                type = "AA",
            },
            {
                name = "PBAEStun",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Config:GetSetting('DoAEDamage')
                end,
            },
            -- {
            --     name = "AEStun",
            --     type = "Spell",
            --     cond = function(self, spell, target)
            --         return Config:GetSetting('DoAEDamage') or spell.Name() ~= "The Sacred Word" -- Sacred Word does damage
            --     end,
            -- },
        },
        ['AECombat'] = {
            -- {
            --     name = "AEStun",
            --     type = "Spell",
            --     cond = function(self, spell, target)
            --         return Core.IsTanking() or Config:GetSetting('AEStunUse') == 3 or Core.GetMainAssistPctHPs() < Config:GetSetting('EmergencyStart')
            --     end,

            -- },
            {
                name = "PBAEStun",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Core.IsTanking() or Config:GetSetting('AEStunUse') == 3 or Core.GetMainAssistPctHPs() < Config:GetSetting('EmergencyStart')
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Valorous Rage",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoValorousRage') end,
            },
            {
                name = "WardProc",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWardProc') and Core.IsTanking() end,
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            { -- for DPS mode
                name = "ForgeDisc",
                type = "Disc",
                load_cond = function(self) return not Core.IsTanking() end,
                cond = function(self, discSpell, target)
                    if not Targeting.TargetBodyIs(target, "Undead") then return false end
                    return Targeting.IsNamed(target) and Casting.NoDiscActive()
                end,
            },
        },
        ['Defenses'] = {
            {
                name = "Protective",
                type = "Disc",
                cond = function(self, discSpell, target)
                    if not Core.IsTanking() then return false end
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "GuardDisc",
                type = "Disc",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, discSpell, target)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Armor of the Inquisitor",
                type = "AA",
            },
        },
        ['ToTHeals'] = {
            {
                name = "LightHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLightHeal') < 3 end,
            },
            {
                name = "LightHeal2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLightHeal') == 2 end,
            },
        },
        ['Combat'] = {
            {
                name = "PBAEStun",
                type = "Spell",
                load_cond = function(self) return Core.IsTanking() end,
                allowDead = true,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            {
                name = "StunTimer4",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetNotStunned() and (Core.IsTanking() or not Casting.StunImmuneTarget(target))
                end,
            },
            -- {
            --     name = "TwinHealNuke",
            --     type = "Spell",
            --     load_cond = function(self) return Config:GetSetting('DoTwinHealNuke') end,
            -- },
            {
                name = "StunTimer5",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetNotStunned() and (Core.IsTanking() or not Casting.StunImmuneTarget(target))
                end,
            },
            {
                name = "SereneStun",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSereneStun') end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if Config:GetSetting('UseEpic') == 1 then return false end
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck())) and Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "QuickUndeadNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoQuickUndeadNuke') end,
                cond = function(self, aaName, target)
                    return Targeting.TargetBodyIs(target, "Undead")
                end,
            },
            {
                name = "UndeadNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoUndeadNuke') end,
                cond = function(self, aaName, target)
                    return Targeting.TargetBodyIs(target, "Undead")
                end,
            },
            {
                namefunc = function(self) return Casting.GetFirstAA({ "Hand of Disruption", "Divine Stun", }) end,
                type = "AA",
                cond = function(self, aaName, target)
                    return not Core.IsTanking() or not Casting.CanUseAA("Force of Disruption")
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                cond = function(self)
                    return Core.ShieldEquipped() or Casting.CanUseAA("2 Hand Bash")
                end,
            },
            {
                name = "Slam",
                type = "Ability",
                load_cond = function(self) return mq.TLO.Me.Ability("Slam")() end,
            },
        },
        ['Weapon Management'] = {
            {
                name = "Equip Shield",
                type = "CustomFunc",
                cond = function(self, target)
                    if mq.TLO.Me.Bandolier("Shield").Active() then return false end
                    return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EquipShield')) or (Targeting.IsNamed(Targeting.GetAutoTarget()) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("Shield") end,
            },
            {
                name = "Equip 2Hand",
                type = "CustomFunc",
                cond = function()
                    if mq.TLO.Me.Bandolier("2Hand").Active() then return false end
                    return mq.TLO.Me.PctHPs() >= Config:GetSetting('Equip2Hand') and mq.TLO.Me.ActiveDisc() ~= "Deflection Discipline" and
                        not (Targeting.IsNamed(Targeting.GetAutoTarget()) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("2Hand") end,
            },
        },
    },
    ['PullAbilities']     = {
        {
            id = 'StunTimer4',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('StunTimer4')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('StunTimer4')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('StunTimer4')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'StunTimer5',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('StunTimer5')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('StunTimer5')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('StunTimer5')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'Force of Disruption',
            Type = "AA",
            DisplayName = function() return Casting.CanUseAA("Force of Disruption") and "Force of Disruption" or "" end,
            AbilityName = function() return Casting.CanUseAA("Force of Disruption") and "Force of Disruption" or "" end,
            AbilityRange = 150,
            cond = function(self)
                return Casting.CanUseAA("Force of Disruption") and "Force of Disruption"
            end,
        },
    },
    ['DefaultConfig']     = {
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What Modes does the Paladin have?",
            Answer = "Paladins have a mode for Tanking and a mode for DPS.",
        },

        --AE(All Modes)
        ['DoAEDamage']        = {
            DisplayName = "Do AE Damage",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 101,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE stuns that cause damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        -- ['DoAEStun']          = {
        --     DisplayName = "Do AE Stun",
        --     Group = "Abilities",
        --     Header = "Debuff",
        --     Category = "Stun",
        --     Index = 102,
        --     Tooltip = "Use your Targeted AE Stun (Stun Command or Sacred Word) as needed to maintain AE aggro (tank mode) or help with control (dps mode).",
        --     Default = true,
        -- },
        ['DoPBAEStun']        = {
            DisplayName = "Do PBAE Stun",
            Group = "Abilities",
            Header = "Debuff",
            Category = "Stun",
            Index = 103,
            Tooltip = "Use your PBAE Stun (The Silent Command) as needed to maintain AE aggro (tank mode) or help with control (dps mode).",
            Default = true,
        },
        ['AEStunUse']         = {
            DisplayName = "AEStun Use(DPS Mode):",
            Group = "Abilities",
            Header = "Debuff",
            Category = "Stun",
            Index = 104,
            Tooltip = "When to use your AE Stun Lines in DPS Mode.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Never', 'At low MA health', 'Whenever Possible', },
            Default = 1,
            Min = 1,
            Max = 3,
        },
        ['AETargetCnt']       = {
            DisplayName = "AE Target Count",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 102,
            Tooltip = "Minimum number of valid targets before using AE Spells, Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
        },
        ['MaxAETargetCnt']    = {
            DisplayName = "Max AE Targets",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 103,
            Tooltip =
            "Maximum number of valid targets to use AE Spells, Disciplines or AA.\nUseful for setting up AE Mez at a higher threshold on another character in case you are overwhelmed.",
            Default = 5,
            Min = 2,
            Max = 30,
            FAQ = "How do I take advantage of the Max AE Targets setting?",
            Answer =
            "By limiting your max AE targets, you can set an AE Mez count that is slightly higher, to allow for the possiblity of mezzing if you are being overwhelmed.",
        },
        ['SafeAEDamage']      = {
            DisplayName = "AE Proximity Check",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 104,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },

        --Hate Tools
        ['AETauntAA']         = {
            DisplayName = "Use Beacon",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 101,
            Tooltip = "Use Beacon of the Righteous to regain AE aggro in Tank Mode.",
            Default = true,
            ConfigType = "Advanced",
        },
        ['AETauntCnt']        = {
            DisplayName = "AE Taunt Count",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 102,
            Tooltip = "Minimum number of haters before using AE Taunt AA or Stuns(when used as taunts).",
            Default = 2,
            Min = 1,
            Max = 30,
            FAQ = "Why don't we use AE taunts on single targets?",
            Answer =
            "AE taunts are configured to only be used if a target has less than 100% hate on you, at whatever count you configure, so abilities with similar conditions may be used instead.",
        },
        ['SafeAETaunt']       = {
            DisplayName = "AE Taunt Safety Check",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 103,
            Tooltip = "Limit unintended pulls with AE Taunts or Stuns(when used as taunts). May result in non-use due to false positives.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Can you better explain the AE Stun Safety Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the taunt.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the taunt not being used when it is safe to do so.",
        },

        --Defenses
        ['DiscCount']         = {
            DisplayName = "Def. Disc. Count",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 101,
            Tooltip = "Number of mobs around you before you use preemptively use Defensive Discs.",
            Default = 4,
            Min = 1,
            Max = 10,
            ConfigType = "Advanced",
        },
        ['DefenseStart']      = {
            DisplayName = "Defense HP",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 102,
            Tooltip = "The HP % where we will use defensive actions like discs, epics, etc.\nNote that fighting a named will also trigger these actions.",
            Default = 60,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['EmergencyStart']    = {
            DisplayName = "Emergency Start",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 103,
            Tooltip = "The HP % before all but essential rotations are cut in favor of emergency or defensive abilities.",
            Default = 40,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['HPCritical']        = {
            DisplayName = "HP Critical",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 104,
            Tooltip =
            "The HP % that we will use abilities like Lay on Hands or Gift of Life.\nMost other rotations are cut to give our full focus to survival.",
            Default = 20,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },

        --Equipment
        ['UseEpic']           = {
            DisplayName = "Epic Use:",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['UseBandolier']      = {
            DisplayName = "Dynamic Weapon Swap",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 101,
            Tooltip = "Enable 1H+S/2H swapping based off of current health. ***YOU MUST HAVE BANDOLIER ENTRIES NAMED \"Shield\" and \"2Hand\" TO USE THIS FUNCTION.***",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['EquipShield']       = {
            DisplayName = "Equip Shield",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 102,
            Tooltip = "Under this HP%, you will swap to your \"Shield\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['Equip2Hand']        = {
            DisplayName = "Equip 2Hand",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 103,
            Tooltip = "Over this HP%, you will swap to your \"2Hand\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 75,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['NamedShieldLock']   = {
            DisplayName = "Shield on Named",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 104,
            Tooltip = "Keep Shield equipped for Named mobs(must be in SpawnMaster or named.lua)",
            Default = true,
        },

        --Heals/Cures
        ['DoTouchHeal']       = {
            DisplayName = "Touch Heal Use:",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Choose when the Paladin will use the single-target Touch-line healing spell.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Emergency Use(BigHeal)', 'Standard Use(MainHeal)', 'Never', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['DoLightHeal']       = {
            DisplayName = "Light Heal Use:",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 102,
            Tooltip = "Choose how many ToT heals (\"Light of\" line) to keep memorized, if any.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Current Tier', 'Current Tier + Last Tier', 'Never', },
            Default = 2,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['DoWaveHeal']        = {
            DisplayName = "Wave Heal Use:",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 103,
            Tooltip = "Choose how many group heals to keep memorized, if any.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Current Tier', 'Current Tier + Last Tier', 'Never', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['WaveHealUse']       = {
            DisplayName = "Use Waves for ST:",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 104,
            Tooltip = "Use your Wave Heals as single-target heals as needed.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Emergency Use(BigHeal)', 'Standard Use(MainHeal)', 'Never', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['DoCleansing']       = {
            DisplayName = "Cleansing HoT:",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 105,
            Tooltip = "Select your preference for Cleansing HoT use:",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Automatic', 'Memorize-Only (Manual Use)', 'Never', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['KeepPurityMemmed']  = {
            DisplayName = "Mem Crusader's Cure",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Curing",
            Index = 101,
            Tooltip = "Memorize your Crusader's xxx line (Cure poi/dis/curse) when possible (depending on other selected options). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if enabled.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['KeepCurseMemmed']   = {
            DisplayName = "Mem Remove Curse",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Curing",
            Index = 102,
            Tooltip = "Memorize remove curse spell when possible (depending on other selected options). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if enabled.",
            RequiresLoadoutChange = true,
            Default = false,
        },

        --Combat
        -- ['DoTwinHealNuke']    = {
        --     DisplayName = "Twin Heal Nuke",
        --     Group = "Abilities",
        --     Header = "Damage",
        --     Category = "Direct",
        --     Index = 101,
        --     Tooltip = "Use Twin Heal Nuke Spells",
        --     RequiresLoadoutChange = true,
        --     Default = true,
        --     ConfigType = "Advanced",
        -- },
        ['DoSereneStun']      = {
            DisplayName = "Do Serene Stun",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Stun",
            Index = 101,
            Tooltip = "Use the Quellious/Serene stun line (long duration stun with DD component).",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoUndeadNuke']      = {
            DisplayName = "Do Undead Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 102,
            Tooltip = "Use the standard Undead nuke line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoQuickUndeadNuke'] = {
            DisplayName = "Do Undead Quick Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 103,
            Tooltip = "Use the quick undead nuke line (which includes a potential snare and ac debuff trigger).",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoValorousRage']    = {
            DisplayName = "Valorous Rage",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = "Use the Valorous Rage AA during burns.",
            Default = false,
        },

        --Buffs
        ['AegoSymbol']        = {
            DisplayName = "Aego/Symbol Choice:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip =
            "Choose whether to use the Aegolism or Symbol Line of HP Buffs.\nPlease note using both is supported for party members who block buffs, but these buffs do not stack once we transition from using a HP Type-One buff in place of Aegolism.",
            Type = "Combo",
            ComboOptions = { 'Aegolism', 'Both (See Tooltip!)', 'Symbol', 'None', },
            Default = 1,
            Min = 1,
            Max = 4,
        },
        ['DoACBuff']          = {
            DisplayName = "Use AC Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 102,
            Tooltip =
                "Use your single-slot AC Buff on the Main Assist. USE CASES:\n" ..
                "You have Aegolism selected and are below level 40 (We are still using a HP Type One buff).\n" ..
                "You have Symbol selected and don't have another Type One Buff.\n" ..
                "Leaving this on in other cases is not likely to cause issue, but may cause unnecessary buff checking.",
            Default = false,
        },
        ['DoBrells']          = {
            DisplayName = "Do Brells",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 103,
            Tooltip = "Enable Casting Brells",
            Default = true,
        },
        ['DoWardProc']        = {
            DisplayName = "Do Ward Proc",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 103,
            Tooltip = "Use your Ward of Tunare defensive proc buff.",
            Default = true,
        },
        ['DoSalvation']       = {
            DisplayName = "Marr's Salvation",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 104,
            Tooltip = "Use your group hatred reduction buff AA.",
            Default = true,
        },
        ['ProcChoice']        = {
            DisplayName = "Proc Buff Choice:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 104,
            Tooltip =
                "Choose which DD proc buff you prefer. The Undead proc does higher damage but is restricted to that target type.\n" ..
                "Please note that we will use the undead proc at low levels if you select Standard and it is not yet available.",
            Type = "Combo",
            ComboOptions = { 'All Enemies', 'Undead', 'Disabled', },
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "Why am I using and Undead proc, I'm not fighting any undead?",
            Answer = "If you have elected to use the Standard DD proc (default) and it is not yet available, we will use the Undead proc still.\n" ..
                "Your desired proc can be adjusted with the Proc Buff Choice setting in Self Buff category.",
        },
    },
    ['ClassFAQ']          = {
        [1] = {
            Question = "What is the current status of this class config?",
            Answer = "This class config is currently a Work-In-Progress that was originally based off of the Project Lazarus config.\n\n" ..
                "  Up until level 66, it should work quite well, but may need some clickies managed on the clickies tab.\n\n" ..
                "  After level 66, expect performance to degrade somewhat as not all EQMight custom spells or items are added, and some Laz-specific entries may remain.\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}
