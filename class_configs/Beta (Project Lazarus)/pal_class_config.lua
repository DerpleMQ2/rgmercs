local mq          = require('mq')
local Config      = require('utils.config')
local Core        = require("utils.core")
local Targeting   = require("utils.targeting")
local Casting     = require("utils.casting")
local ItemManager = require("utils.item_manager")
local Logger      = require("utils.logger")
local Set         = require('mq.set')

return {
    _version              = "2.0 - Project Lazarus",
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
        CureNow = function(self, type, targetId)
            if Config:GetSetting('DoCureAA') then
                if Casting.AAReady("Radiant Cure") then
                    return Casting.UseAA("Radiant Cure", Targeting.GetAutoTarget().ID() or targetId, true)
                elseif targetId == mq.TLO.Me.ID() and Casting.AAReady("Purification") then
                    return Casting.UseAA("Purification", Targeting.GetAutoTarget().ID() or targetId, true)
                end
            end

            if Config:GetSetting('DoCureSpells') then
                local cureSpell --we need to make sure we only assign a spell for types that spell can effect

                if type:lower() == "disease" then
                    cureSpell = Core.GetResolvedActionMapItem('PurityCure')
                elseif type:lower() == "poison" then
                    cureSpell = Core.GetResolvedActionMapItem('PurityCure')
                elseif type:lower() == "curse" then
                    --if we selected to keep it memmed, prioritize it over purity, since RGC clears a LOT more counters
                    cureSpell = Core.GetResolvedActionMapItem((not Config:GetSetting('KeepCurseMemmed') and ('PurityCure' or 'CureCurse') or 'CureCurse'))
                end

                if not cureSpell or not cureSpell() then return false end
                return Casting.UseSpell(cureSpell.RankName.Name(), targetId, true)
            end

            return false
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
        ["DebuffNuke"] = {
            -- Undead DebuffNuke
            "Last Rites", -- Level 68 - Timer 7
        },
        ["DDProc"] = {
            --- Fury Proc Strike
            "Divine Might", -- Level 45, 65pt
            "Pious Might",  -- Level 63, 150pt
            "Holy Order",   -- Level 65, 180pt
            "Pious Fury",   -- Level 68, 250pt
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
            "Armor of the Crusader", -- Level 64
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
        },
        ["LightHeal"] = {
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
        ["Aura"] = {
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
        ['PBAEStun'] = {
            "The Silent Command", -- does damage
        },
        ['AEStun'] = {            --Targeted AE
            "Stun Command",       -- no damage
            "Sacred Word",        -- does damage
        },
        ['BlockDisc'] = {
            "Rampart Discipline",
            "Deflection Discipline",
        },
        ['SancDisc'] = {
            "Sanctification Discipline",
        },
        ['TwinHealNuke'] = {
            "Justice of Marr",
        },
        ['GuardDisc'] = {
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
    },
    ['SpellList']         = {
        {
            name = "Default",
            -- cond = function(self) return true end, --Kept here for illustration, this line could be removed in this instance since we aren't using conditions.
            spells = {
                { name = "TouchHeal",    cond = function(self) return Config:GetSetting('DoTouchHeal') < 3 end, },
                { name = "LightHeal", },
                { name = "WaveHeal",     cond = function(self) return Config:GetSetting('DoWaveHeal') < 3 end, },
                { name = "WaveHeal2",    cond = function(self) return Config:GetSetting('DoWaveHeal') == 2 end, },
                { name = "Cleansing",    cond = function(self) return Config:GetSetting('DoCleansing') end, },
                { name = "TwinHealNuke", cond = function(self) return Config:GetSetting('DoTwinHealNuke') end, },
                { name = "SereneStun", },
                { name = "StunTimer4",   cond = function(self) return Core.IsTanking() end, },
                { name = "StunTimer5",   cond = function(self) return Core.IsTanking() end, },
                { name = "PBAEStun",     cond = function(self) return Config:GetSetting('DoPBAEStun') end, },
                { name = "AEStun",       cond = function(self) return Config:GetSetting('DoAEStun') end, },
                { name = "CureCurse",    cond = function(self) return Config:GetSetting('KeepCurseMemmed') end, },
                { name = "PurityCure",   cond = function(self) return Config:GetSetting('KeepPurityMemmed') end, },
                { name = "UndeadNuke",   cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                { name = "DebuffNuke",   cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
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
                return Targeting.BigHealsNeeded(target)
            end,
        },
        {
            name = 'MainHeal',
            state = 1,
            steps = 1,
            load_cond = function(self) return Config:GetSetting('DoCleansing') or Config:GetSetting("DoTouchHeal") == 2 end,
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
                name = "Imbued Rune of Piety",
                type = "Item",
                load_cond = function(self) return mq.TLO.FindItem("=Imbued Rune of Piety")() end,
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
                name = "Hand of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and (Targeting.TargetIsMyself(target) or Targeting.GetTargetPctHPs() < Config:GetSetting('HPCritical'))
                end,
            },
            {
                name = "Imbued Rune of Piety",
                type = "Item",
                load_cond = function(self) return mq.TLO.FindItem("=Imbued Rune of Piety")() and Config:GetSetting('WaveHealUse') == 1 end,
            },
            {
                name = "WaveHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') < 3 and Config:GetSetting('WaveHealUse') == 1 end,
            },
            {
                name = "WaveHeal2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') == 2 and Config:GetSetting('WaveHealUse') == 1 end,
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
                load_cond = function() return Config:GetSetting('DoCleansing') end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Imbued Rune of Piety",
                type = "Item",
                load_cond = function(self) return mq.TLO.FindItem("=Imbued Rune of Piety")() and Config:GetSetting('WaveHealUse') == 2 end,
            },
            {
                name = "WaveHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') < 3 and Config:GetSetting('WaveHealUse') == 2 end,
            },
            {
                name = "WaveHeal2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') == 2 and Config:GetSetting('WaveHealUse') == 2 end,
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
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60,
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff()
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
                local hateSpell = Config:GetSetting('DoAEStun') and (Core.GetResolvedActionMapItem('AEStun') or Core.GetResolvedActionMapItem('PBAEStun'))
                local hateAA = Config:GetSetting('AETauntAA') and Casting.CanUseAA("Beacon of the Righteous")
                return Core.IsTanking() and (hateSpell or hateAA)
            end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and self.ClassConfig.HelperFunctions.AETauntCheck(true)
            end,
        },
        { --Stun enemies per your settings
            name = 'AEStun(DPS Mode)',
            state = 1,
            steps = 1,
            load_cond = function()
                local aeSpell = Config:GetSetting('DoAEStun') and Core.GetResolvedActionMapItem('AEStun')
                local pbaeSpell = Config:GetSetting('DoPBAEStun') and Core.GetResolvedActionMapItem('PBAEStun')
                return not Core.IsTanking() and (aeSpell or pbaeSpell)
            end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if (Config:GetSetting('AEStunUse') == 2 and Core.GetMainAssistPctHPs() > Config:GetSetting('EmergencyStart')) or Config:GetSetting('AEStunUse') == 1 then return false end
                return combat_state == "Combat" and self.ClassConfig.HelperFunctions.AETargetCheck(true)
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
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        { --DPS Spells, includes recourse/gift maintenance
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat"
            end,
        },
    },
    ['Rotations']         = {
        ['Downtime'] = {
            {
                name = "Yaulp",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.SelfBuffAACheck(aaName)
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
                        --laz specific deconflict
                        and not Casting.IHaveBuff("Necrotic Pustules")
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
                name = "ACBuff",
                type = "Spell",
                load_cond = function() return Config:GetSetting('DoACBuff') end,
                cond = function(self, spell, target)
                    if (spell.TargetType() or ""):lower() == "single" and target.ID() ~= Core.GetMainAssistId() then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Marr's Salvation",
                type = "AA",
                load_cond = function() return Config:GetSetting('DoSalvation') end,
                cond = function(self, aaName, target)
                    return not Targeting.TargetIsATank(target) and Casting.GroupBuffAACheck(aaName, target)
                end,
            },
        },
        ['EmergencyDefenses'] = {
            --Note that in Tank Mode, defensive discs are preemptively cycled on named in the (non-emergency) Defenses rotation
            --Abilities should be placed in order of lowest to highest triggered HP thresholds
            --Some conditionals are commented out while I tweak percentages (or determine if they are necessary)
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') and Config:GetSetting('DoVetAA')
                end,
            },
            {
                name = "Marr's Gift",
                type = "AA",
            },
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
                    return Casting.NoDiscActive() and not blockReady and not guardReady
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
            { --8min reuse, save for we still can't get a mob back after trying to taunt
                name = "Ageless Enmity",
                type = "AA",
                cond = function(self, aaName, target)
                    return (Targeting.IsNamed(target) or Targeting.GetAutoTargetPctHPs() < 90) and Targeting.LostAutoTargetAggro()
                end,
            },
            {
                name = "Force of Disruption",
                type = "AA",
            },
            {
                name = "Projection of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    ---@diagnostic disable-next-line: undefined-field
                    return Targeting.IsNamed(target) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 80
                end,
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
                name = "Beacon of the Righteous",
                type = "AA",
            },
            {
                name = "Forsaken Fayguard Bladecatcher",
                type = "Item",
                cond = function(self, itemName, target)
                    return Config:GetSetting('DoAEDamage')
                end,
            },
            {
                name = "PBAEStun",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Config:GetSetting('DoAEDamage')
                end,
            },
            {
                name = "AEStun",
                type = "Spell",
                cond = function(self, spell, target)
                    return Config:GetSetting('DoAEDamage') or spell.Name() ~= "The Sacred Word" -- Sacred Word does damage
                end,
            },
        },
        ['AEStun(DPS Mode)'] = {
            {
                name = "AEStun",
                type = "Spell",
                cond = function(self, spell, target)
                    return Config:GetSetting('DoAEDamage') or spell.Name() ~= "The Sacred Word" -- Sacred Word does damage
                end,

            },
            {
                name = "PBAEStun",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Config:GetSetting('DoAEDamage')
                end,
            },
        },
        ['Burn'] = {
            {
                name_func = function(self)
                    return string.format("Fundament: %s Spire of Holiness", Core.IsTanking() and "Third" or "Second")
                end,
                type = "AA",
            },
            {
                name = "Inquisitor's Judgment",
                type = "AA",
            },
            {
                name = "Valorous Rage",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoValorousRage') end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
            },
            {
                name = "WardProc",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWardProc') and Core.IsTanking() end,
                cond = function(self, spell, target)
                    if not Targeting.IsNamed(target) then return false end
                    return Casting.SelfBuffCheck(spell)
                        --laz specific deconflict
                        and not Casting.IHaveBuff("Necrotic Pustules")
                end,
            },
            { -- for DPS mode
                name = "ForgeDisc",
                type = "Disc",
                load_cond = function(self) return not Core.IsTanking() end,
                cond = function(self, discSpell, target)
                    if not Targeting.TargetBodyIs(target, "Undead") then return false end
                    return Targeting.IsNamed(target) and Casting.NoDiscActive() and not mq.TLO.Me.Song("Rampart")()
                end,
            },
        },
        ['Defenses'] = {
            {
                name = "GuardDisc",
                type = "Disc",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, discSpell, target)
                    return Casting.NoDiscActive() and not mq.TLO.Me.Song("Rampart")()
                end,
            },
            {
                name = "Coating",
                type = "Item",
                load_cond = function(self) return Config:GetSetting('DoCoating') end,
                cond = function(self, itemName, target)
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Armor of the Inquisitor",
                type = "AA",
            },
        },
        ['ToTHeals'] = {
            {
                name = "Gift of Life",
                type = "AA",
                cond = function(self, aaName, target)
                    return (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < Config:GetSetting('HPCritical')
                end,
            },
            {
                name = "LightHeal",
                type = "Spell",
            },
        },
        ['Combat'] = {
            {
                name = "StunTimer4",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetNotStunned()
                end,
            },
            {
                name = "TwinHealNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoTwinHealNuke') end,
            },
            {
                name = "Yaulp",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SereneStun",
                type = "Spell",
            },
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
                name = "StunTimer5",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetNotStunned()
                end,
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
                name = "DebuffNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoUndeadNuke') end,
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
                name = "Disruptive Persecution",
                type = "AA",
                cond = function(self, aaName, target)
                    return (mq.TLO.Target.SecondaryPctAggro() or 999 < 60) or not Core.IsTanking()
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
                    return mq.TLO.Me.PctHPs() >= Config:GetSetting('Equip2Hand') and mq.TLO.Me.ActiveDisc() ~= "Deflection Discipline" and not mq.TLO.Me.Song("Rampart")() and
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
        ['Mode']       = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes Do?",
            Answer = "Tank Mode will focus on tanking and DPS Mode will focus on DPS.",
        },

        --AE(All Modes)
        ['DoAEDamage'] = {
            DisplayName = "Do AE Damage",
            Category = "AE(All Modes)",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE stuns that cause damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['DoAEStun']   = {
            DisplayName = "Do AE Stun",
            Category = "AE(All Modes)",
            Index = 2,
            Tooltip = "Use your Targeted AE Stun (Stun Command or Sacred Word) as needed to maintain AE aggro (tank mode) or help with control (dps mode).",
            Default = true,
            FAQ = "Why am I not using my AE Stun?",
            Answer = "The AE stun is set to be used to reclaim aggro on AE targets when necessary.",
        },
        ['DoPBAEStun'] = {
            DisplayName = "Do PBAE Stun",
            Category = "AE(All Modes)",
            Index = 3,
            Tooltip = "Use your PBAE Stun (The Silent Command) as needed to maintain AE aggro (tank mode) or help with control (dps mode).",
            Default = true,
            FAQ = "Why am I memorizing an AE stun as a DPS?",
            Answer = "You can select which AE stuns you will keep memorized (if any) in your class options.",
        },


        --AE(DPS Mode)
        ['AEStunUse']        = {
            DisplayName = "AEStun Use:",
            Category = "AE(DPS Mode)",
            Index = 1,
            Tooltip = "When to use your AE Stun Lines in DPS Mode.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Never', 'At low MA health', 'Whenever Possible', },
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "Why am I stunning everything?!??",
            Answer = "You can choose the conditions under which you will use your PBAE Stun on the Combat tab.",
        },
        ['AETargetCnt']      = {
            DisplayName = "AE Target Count",
            Category = "AE(DPS Mode)",
            Index = 2,
            Tooltip = "Minimum number of valid targets before using AE Spells, Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['MaxAETargetCnt']   = {
            DisplayName = "Max AE Targets",
            Category = "AE(DPS Mode)",
            Index = 3,
            Tooltip =
            "Maximum number of valid targets before using AE Spells, Disciplines or AA.\nUseful for setting up AE Mez at a higher threshold on another character in case you are overwhelmed.",
            Default = 5,
            Min = 2,
            Max = 30,
            FAQ = "How do I take advantage of the Max AE Targets setting?",
            Answer =
            "By limiting your max AE targets, you can set an AE Mez count that is slightly higher, to allow for the possiblity of mezzing if you are being overwhelmed.",
        },
        ['SafeAEDamage']     = {
            DisplayName = "AE Proximity Check",
            Category = "AE(DPS Mode)",
            Index = 4,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },

        --AE(Tank Mode)
        ['AETauntAA']        = {
            DisplayName = "Use Beacon",
            Category = "AE(Tank Mode)",
            Index = 1,
            Tooltip = "Use Beacon of the Righteous to maintain AE aggro in Tank Mode.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why do we treat the Explosions the same? One is targeted, one is PBAE",
            Answer = "There are currently no scripted conditions where Hatred would be used at long range, thus, for ease of use, we can treat them similarly.",
        },
        ['AETauntCnt']       = {
            DisplayName = "AE Stun Count",
            Category = "AE(Tank Mode)",
            Index = 2,
            Tooltip = "Minimum number of haters before using AE Stun Spells or AA.",
            Default = 2,
            Min = 1,
            Max = 30,
            FAQ = "Why don't we use AE taunts on single targets?",
            Answer =
            "AE taunts are configured to only be used if a target has less than 100% hate on you, at whatever count you configure, so abilities with similar conditions may be used instead.",
        },
        ['SafeAETaunt']      = {
            DisplayName = "AE Stun Safety Check",
            Category = "AE(Tank Mode)",
            Index = 3,
            Tooltip = "Limit unintended pulls with AE Stun Spells or AA. May result in non-use due to false positives.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Can you better explain the AE Stun Safety Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the taunt.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the taunt not being used when it is safe to do so.",
        },

        --Defenses
        ['DiscCount']        = {
            DisplayName = "Def. Disc. Count",
            Category = "Defenses",
            Index = 1,
            Tooltip = "Number of mobs around you before you use preemptively use Defensive Discs.",
            Default = 4,
            Min = 1,
            Max = 10,
            ConfigType = "Advanced",
            FAQ = "What are the Defensive Discs and what order are they triggered in when the Disc Count is met?",
            Answer = "Carapace, Mantle, Guardian, Unholy Aura, in that order. Note some may also be used preemptively on named, or in emergencies.",
        },
        ['DefenseStart']     = {
            DisplayName = "Defense HP",
            Category = "Defenses",
            Index = 2,
            Tooltip = "The HP % where we will use defensive actions like discs, epics, etc.\nNote that fighting a named will also trigger these actions.",
            Default = 60,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "My SHD health spikes up and down a lot and abilities aren't being triggered, what gives?",
            Answer = "You may need to tailor the emergency thresholds to your current survivability and target choice.",
        },
        ['EmergencyStart']   = {
            DisplayName = "Emergency Start",
            Category = "Defenses",
            Index = 3,
            Tooltip = "The HP % before all but essential rotations are cut in favor of emergency or defensive abilities.",
            Default = 40,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "What rotations are cut during emergencies?",
            Answer = "Snare, Burn, Combat Weave and Combat rotations are disabled when your health is at emergency levels.\nAdditionally, we will only use non-spell hate tools.",
        },
        ['HPCritical']       = {
            DisplayName = "HP Critical",
            Category = "Defenses",
            Index = 4,
            Tooltip =
            "The HP % that we will use abilities like Leechcurse and Leech Touch.\nMost other rotations are cut to give our full focus to survival (See FAQ).",
            Default = 20,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "What rotations are cut when HP % is critical?",
            Answer =
            "Hate Tools (including AE) and Leech Effect rotations are cut when HP% is critical.\nAdditionally, reaching the emergency threshold would've also cut the Snare, Burn, Combat Weave and Combat Rotations.",
        },

        --Equipment
        ['UseEpic']          = {
            DisplayName = "Epic Use:",
            Category = "Equipment",
            Index = 1,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my PAL using Epic on these trash mobs?",
            Answer = "By default, we use the Epic in any combat, as saving it for burns ends up being a DPS loss over a long frame of time.\n" ..
                "This can be adjusted in the Buffs tab.",
        },
        ['DoCoating']        = {
            DisplayName = "Use Coating",
            Category = "Equipment",
            Index = 2,
            Tooltip = "Click your Blood/Spirit Drinker's Coating when defenses are triggered.",
            Default = false,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },
        ['UseBandolier']     = {
            DisplayName = "Dynamic Weapon Swap",
            Category = "Equipment",
            Index = 3,
            Tooltip = "Enable 1H+S/2H swapping based off of current health. ***YOU MUST HAVE BANDOLIER ENTRIES NAMED \"Shield\" and \"2Hand\" TO USE THIS FUNCTION.***",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not using Dynamic Weapon Swapping?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"2Hand\" to use this function.",
        },
        ['EquipShield']      = {
            DisplayName = "Equip Shield",
            Category = "Equipment",
            Index = 4,
            Tooltip = "Under this HP%, you will swap to your \"Shield\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using a shield?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"2Hand\" to use this function.",
        },
        ['Equip2Hand']       = {
            DisplayName = "Equip 2Hand",
            Category = "Equipment",
            Index = 5,
            Tooltip = "Over this HP%, you will swap to your \"2Hand\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 75,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using a 2Hand?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"2Hand\" to use this function.",
        },
        ['NamedShieldLock']  = {
            DisplayName = "Shield on Named",
            Category = "Equipment",
            Index = 6,
            Tooltip = "Keep Shield equipped for Named mobs(must be in SpawnMaster or named.lua)",
            Default = true,
            FAQ = "Why does my SHD switch to a Shield on puny gray named?",
            Answer = "The Shield on Named option doesn't check levels, so feel free to disable this setting (or Bandolier swapping entirely) if you are farming fodder.",
        },

        --Heals/Cures
        ['DoTouchHeal']      = {
            DisplayName = "Touch Heal Use:",
            Category = "Heals/Cures",
            Index = 1,
            Tooltip = "Choose when the Paladin will use the single-target Touch-line healing spell.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Emergency Use(BigHeal)', 'Standard Use(MainHeal)', 'Never', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my paladin changing targets to heal so often?",
            Answer = "You can control when a Paladin will use their single target heals on the Heals/Cures tab in Class options.",
        },
        ['DoWaveHeal']       = {
            DisplayName = "Wave Heal Use:",
            Category = "Heals/Cures",
            Index = 2,
            Tooltip = "Choose how many group heals to keep memorized, if any.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Current Tier', 'Current Tier + Last Tier', 'Never', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my paladin changing targets to heal so often?",
            Answer = "You can control when a Paladin will use their group heals on the Heals/Cures tab in Class options.",
        },
        ['WaveHealUse']      = {
            DisplayName = "Use Waves for ST:",
            Category = "Heals/Cures",
            Index = 3,
            Tooltip = "Use your Wave Heals as single-target heals as needed.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Emergency Use(BigHeal)', 'Standard Use(MainHeal)', 'Never', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my paladin changing targets to heal so often?",
            Answer = "You can control when a Paladin will use their heals on the Heals/Cures tab in Class options.",
        },
        ['DoCleansing']      = {
            DisplayName = "Do Cleansing HoT",
            Category = "Heals/Cures",
            Index = 4,
            Tooltip = "Use your single-target HoT line.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why isn't my Paladin using the his HoT?",
            Answer = "You can adjust this behavior in the class options tabs.",
        },
        ['KeepPurityMemmed'] = {
            DisplayName = "Mem Crusader's Cure",
            Category = "Heals/Cures",
            Index = 5,
            Tooltip = "Memorize your Crusader's xxx line (Cure poi/dis/curse) when possible (depending on other selected options). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if enabled.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why do I have to stop to memorize a cure every time someone gets an effect?",
            Answer =
            "You can choose to keep a cure memorized in the class options. If you have selected it, and it isn't being memmed, you may have chosen too many other optional spells to use/memorize.",
        },
        ['KeepCurseMemmed']  = {
            DisplayName = "Mem Remove Curse",
            Category = "Heals/Cures",
            Index = 6,
            Tooltip = "Memorize remove curse spell when possible (depending on other selected options). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if enabled.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why do I have to stop to memorize a cure every time someone gets an effect?",
            Answer =
            "You can choose to keep a cure memorized in the class options. If you have selected it, and it isn't being memmed, you may have chosen too many other optional spells to use/memorize.",
        },

        --Combat
        ['DoTwinHealNuke']   = {
            DisplayName = "Twin Heal Nuke",
            Category = "Combat",
            Index = 1,
            Tooltip = "Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I using the Twin Heal Nuke?",
            Answer =
            "You can turn off the Twin Heal Nuke in the Spells and Abilities tab.",
        },
        ['DoUndeadNuke']     = {
            DisplayName = "Do Undead Nuke",
            Category = "Combat",
            Index = 2,
            Tooltip = "Use the Undead nuke line (standard and timed w/debuff component).",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "How can I use my Undead Nuke?",
            Answer = "You can enable the undead nuke line in the Spells and Abilities tab.",
        },
        ['DoValorousRage']   = {
            DisplayName = "Valorous Rage",
            Category = "Combat",
            Index = 3,
            Tooltip = "Use the Valorous Rage AA during burns.",
            Default = false,
            FAQ = "What is Valorous Rage and how can I use it?",
            Answer = "Valorous Rage is an AA that increases your damage output while hurting your ability to heal and can be toggled in the Combat tab of the Class options.",
        },
        ['DoVetAA']          = {
            DisplayName = "Use Vet AA",
            Category = "Combat",
            Index = 4,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does PAL use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },

        --Buffs
        ['AegoSymbol']       = {
            DisplayName = "Aego/Symbol Choice:",
            Category = "Buffs",
            Index = 1,
            Tooltip =
            "Choose whether to use the Aegolism or Symbol Line of HP Buffs.\nPlease note using both is supported for party members who block buffs, but these buffs do not stack once we transition from using a HP Type-One buff in place of Aegolism.",
            Type = "Combo",
            ComboOptions = { 'Aegolism', 'Both (See Tooltip!)', 'Symbol', 'None', },
            Default = 1,
            Min = 1,
            Max = 4,
            FAQ = "Why aren't I using Aego and/or Symbol buffs?",
            Answer = "Please set which buff you would like to use on the Buffs/Debuffs tab.",
        },
        ['DoACBuff']         = {
            DisplayName = "Use AC Buff",
            Category = "Buffs",
            Index = 2,
            Tooltip =
                "Use your single-slot AC Buff on the Main Assist. USE CASES:\n" ..
                "You have Aegolism selected and are below level 40 (We are still using a HP Type One buff).\n" ..
                "You have Symbol selected and you are below level 95 (We don't have Unified Symbols yet).\n" ..
                "Leaving this on in other cases is not likely to cause issue, but may cause unnecessary buff checking.",
            Default = false,
            FAQ = "Why aren't I used my AC Buff Line?",
            Answer =
            "You may need to select the option in Buffs/Debuffs. Alternatively, this line does not stack with Aegolism, and it is automatically included in \"Unified\" Symbol buffs.",
        },
        ['DoBrells']         = {
            DisplayName = "Do Brells",
            Category = "Buffs",
            Index = 3,
            Tooltip = "Enable Casting Brells",
            Default = true,
            FAQ = "Why am I not casting Brells?",
            Answer = "Make sure you have the [DoBrells] setting enabled.",
        },
        ['DoWardProc']       = {
            DisplayName = "Do Ward Proc",
            Category = "Buffs",
            Index = 4,
            Tooltip = "Use your Ward of Tunare defensive proc buff.",
            Default = true,
            FAQ = "I'd rather use Reptile, how do I turn off my Ward of Tunare?",
            Answer = "Select the option in the Buffs tab to disable the ward proc buff, it is enabled by default.",
        },
        ['DoSalvation']      = {
            DisplayName = "Marr's Salvation",
            Category = "Buffs",
            Index = 5,
            Tooltip = "Use your group hatred reduction buff AA.",
            Default = true,
            FAQ = "Why is Marr's Salvation being used?",
            Answer = "Select the option in the Buffs tab to use this buff, it is enabled by default.",
        },
        ['ProcChoice']       = {
            DisplayName = "Proc Buff Choice:",
            Category = "Buffs",
            Index = 6,
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
                "Your desired proc can be adjusted on the Abilities tab.",
        },
    },
}
