local mq        = require('mq')
local Config    = require('utils.config')
local Core      = require("utils.core")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Logger    = require("utils.logger")
local Movement  = require("utils.movement")
local Strings   = require("utils.strings")

return {
    _version              = "2.0 - The Hidden Forest WIP",
    _author               = "Algar",
    ['ModeChecks']        = {
        IsHealing = function() return Config:GetSetting('DoHeals') end,
    },
    ['Modes']             = {
        'DPS',
    },
    ['Themes']            = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.05, g = 0.2, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabActive,        color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.05, g = 0.5, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.05, g = 0.2, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.05, g = 0.5, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.05, g = 0.5, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.05, g = 0.3, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.05, g = 0.5, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.05, g = 0.2, b = 0.05, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.05, g = 0.2, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.05, g = 1.0, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.05, g = 1.0, b = 0.05, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.05, g = 0.5, b = 0.05, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Aurora, the Heartwood Blade",
            "Heartwood Blade",
        },
        ['OoW_Chest'] = {
            "Sunrider's Vest",
            "Bladewhipser Chain Vest of Journeys",
        },
    },
    ['AbilitySets']       = {
        ['PredatorBuff'] = { -- Groupv2 Atk Buff
            "Howl of the Predator",
            "Spirit of the Predator",
            "Call of the Predator",
            "Mark of the Predator",
        },
        ['StrengthHPBuff'] = { -- Groupv2 HP Type 2, Atk
            "Strength of the Hunter",
            "Strength of Tunare",
            "Strength of Nature", -- Single Target
        },
        ['SkinBuff'] = {          -- ST HP Type 1, small regen
            "Onyx Skin",
            "Natureskin",
            "Skin like Nature",
            "Skin like Diamond",
            "Skin like Steel",
            "Skin like Rock",
            "Skin like Wood",
        },
        ['EyeBuff'] = { -- Self Archery Buff
            "Eyes of the Hawk",
            "Eyes of the Owl",
            "Eyes of the Eagle",
            "Eagle Eye",
            "Falcon Eye",
            "Hawk Eye",
        },
        ['FireNukeT1'] = { -- ST Fire DD, Timer 1, 30s Recast
            "Reenex's Embers",
            "Reenex's Sylvan Burn",
            "Reenex's Call of Flame",
            "Flaming Arrow",
        },
        ['ColdNukeT2'] = { -- ST Cold DD, Timer 2, 30s Recast
            "Reenex's Frost Wind",
            "Reenex's Icewind",
        },
        ['ColdNukeT3'] = { -- ST Cold DD, Timer 3, 30s Recast
            "Ancient: North Wind",
            "Reenex's Frozen Wind",
        },
        ['FireNukeT4'] = { -- ST Fire DD, Timer 4, 30s Recast
            "Scorched Earth",
            "Reenex's Ancient: Burning Chaos",
            "Reenex's Bushfire",
            "Burning Arrow",
        },
        ["DDProc"] = {
            "Call of Lightning", --Double damage against humanoids on Laz
            "Cry of Thunder",
            "Call of Ice",
            "Call of Fire",
            "Call of Sky",
        },
        -- ["SummonedProc"] = {
        --     "Nature's Denial",
        --     "Nature's Rebuke",
        -- },
        ['SelfBuff'] = {
            "Ward of the Hunter",
            "Protection of the Wild",
            "Warder's Protection",
            "Nature's Precision", --Self ATK Buff, filler
            "Firefist",           --Self ATK Buff, filler
        },
        ['ArrowHail'] = {         -- DirAE multihit archery attack
            "Hail of Arrows",
        },
        ['FocusedHail'] = { -- ST multihit archery attack
            "Focused Hail of Arrows",
        },
        ['Dispel'] = {
            "Nature's Balance",
            "Annul Magic",
            "Nullify Magic",
            "Cancel Magic",
        },
        ['Heartshot'] = {
            "Heartslit",
            "Heartshot",
        },
        ['RegenBuff'] = {
            "Reenex's Vigor",
            "Murg's Regrowth",
            "Murg's Chloroplast",
        },
        ['CoatBuff'] = { -- Self DS
            "Briarcoat",
            "Bladecoat",
            "Thorncoat",
            "Spikecoat",
            "Bramblecoat",
            "Barbcoat",
            "Thistlecoat",
        },
        ['GuardBuff'] = { -- ST AC DS Buff
            "Guard of the Earth",
            "Call of the Rathe",
            "Call of Earth",
            "Riftwind's Protection",
        },
        ['HealSpell'] = {
            "Reenex's Sylvan Water",
            "Sylvan Light",
            "Murg's Chloroblast",
            "Staar's Greater Healing",
            "Staar's Healing",
            "Staar's Light Healing",
            "Staar's Minor Healing",
            "Murg's Salve",
        },
        ['SwarmDot'] = {
            "Reenex's Locust Swarm",
            "Erandi's Drifting Death",
            "Reenex's Fire Swarm",
            "Erandi's Drones of Doom",
            "Reenex's Swarm of Pain",
            "Erandi's Stinging Swarm",
        },
        ['Snapkick'] = { -- 2-hit kick attack
            "Jolting Snapkicks",
        },
        ['Bullseye'] = {
            "Bullseye Discipline",
            "Trueshot Discipline",
        },
        ['ShieldDS'] = { -- ST Slot 1 DS
            "Reenex's Shield of Briar",
            "Erandi's Shield of Thorns",
            "Erandi's Shield of Spikes",
            "Erandi's Shield of Brambles",
            "Erandi's Shield of Thistles",
        },
        ['FlameSnap'] = {
            "Flame Snap",
        },
        ['NatureProc'] = { -- ST Hade reduction defensive proc buff
            "Nature Veil",
        },
        -- ['DDStunProcBuff'] = {
        --     "Sylvan Call",
        -- },
        -- ['MaskBuff'] = { -- no stack with eyes of the hawk
        --     "Mask of the Stalker",
        -- },
        ['MoveBuff'] = {
            "Spirit of Eagle",
        },
        -- ['SelfWolfBuff'] = {
        --     "Feral Form",
        --     "Greater Wolf Form",
        --     "Wolf Form",
        -- },
        ['ColdResistBuff'] = {
            "Circle of Summer",
        },
        ['FireResistBuff'] = {
            "Circle of Winter",
        },
        ['SnareSpell'] = {
            "Earthen Shackles",
            "Earthen Embrace",
            "Ensnare",
            "Tangle",
            "Snare",
            "Tangling Weeds",
        },
        ['WeaponShield'] = {
            "Weapon Shield Discipline",
        },
        ['JoltSpell'] = {
            "Cinder Jolt",
            "Jolt",
        },
        -- ['JoltProcBuff'] = {
        --     "Jolting Blades",
        -- },
        -- ['ResistDisc'] = {
        --     "Resistant Discipline",
        -- },
        ['MinDmgBuff'] = {
            "Empowering Water I",
        },
    },
    ['HealRotationOrder'] = {
        { -- configured as a backup healer, will not cast in the mainpoint
            name = 'BigHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoHeals') end,
            cond = function(self, target) return Targeting.BigHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ['BigHealPoint'] = {
            {
                name = "HealSpell",
                type = "Spell",
            },
        },
    },
    ['RotationOrder']     = {
        {
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
        {
            name = 'Circle Nav',
            state = 1,
            steps = 1,
            load_cond = function(self) return Config:GetSetting('NavCircle') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Config:GetSetting('DoMelee')
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or (Targeting.IsNamed(Targeting.GetAutoTarget()) and mq.TLO.Me.PctAggro() > 99))
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal() and not Targeting.IsNamed(Targeting.GetAutoTarget()) and
                    Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        {
            name = 'Combat',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and (Config:GetSetting('DoHeals') and Casting.OkayToNuke() or Targeting.AggroCheckOkay())
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.AggroCheckOkay()
            end,
        },
    },
    ['HelperFunctions']   = {
        combatNav = function(forceMove)
            if not Config:GetSetting('DoMelee') then
                if not mq.TLO.Me.AutoFire() then
                    Core.DoCmd('/squelch face fast')
                    Core.DoCmd('/autofire on')
                end

                local targetDistance = Targeting.GetTargetDistance()
                local chaseDistance = Config:GetSetting('ChaseDistance')
                local useChaseDistance = chaseDistance > 75 and chaseDistance < 200
                local tooClose = targetDistance < 30
                --- the distance of 200 could be further refined by checking actual distances based off range + ammo distance if desired.
                local tooFar = useChaseDistance and targetDistance > chaseDistance or targetDistance > 75

                Logger.log_verbose("Custom Ranger combatNav engaged. TargetDistance: %d, LOS:%s, ChaseDistance: %d, forceMove: %s, tooClose: %s, tooFar: %s", targetDistance,
                    mq.TLO.Target.LineOfSight(), chaseDistance, Strings.BoolToColorString(forceMove), Strings.BoolToColorString(tooClose), Strings.BoolToColorString(tooFar))
                if Config:GetSetting('NavCircle') then
                    if tooClose or tooFar or forceMove then
                        Movement:NavAroundCircle(mq.TLO.Target, Config:GetSetting('BowNavDistance'))
                    end
                elseif tooClose then
                    if chaseDistance < 30 then
                        Logger.log_warn(
                            "Custom Ranger combatNav: \arWarning! \awChase distance is %d. \ayThis may interfere with ranged combat, depending on chase target movement!",
                            chaseDistance)
                    end
                    Core.DoCmd('/squelch face fast')
                    Movement:DoStickCmd("10 moveback")
                elseif tooFar or forceMove then
                    Core.DoCmd("/squelch /nav id %d distance=%d lineofsight=on", Config.Globals.AutoTargetID, Config:GetSetting('BowNavDistance'))
                    Core.DoCmd('/squelch face fast')
                end
            end
        end,
        --function to make sure we don't have non-hostiles in range before we use AE damage or non-taunt AE hate abilities
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
    ['Rotations']         = {
        ['Circle Nav'] = {
            {
                name = "Ranged Mode",
                type = "CustomFunc",
                custom_func = function(self)
                    Core.SafeCallFunc("Ranger Custom Nav", self.ClassConfig.HelperFunctions.combatNav, false)
                end,
            },
        },
        ['Burn']       = {
            {
                name = "Auspice of the Hunter",
                type = "AA",
            },
            {
                name = "Fundament: Third Spire of the Pathfinder",
                type = "AA",
            },
            {
                name = "Group Guardian of the Forest",
                type = "AA",
                cond = function(self, aaName, target)
                    return not mq.TLO.Me.Buff("Guardian of the Forest")()
                end,
            },
            {
                name = "Guardian of the Forest",
                type = "AA",
                cond = function(self, aaName, target)
                    return not mq.TLO.Me.Buff("Guardian of the Forest")()
                end,
            },
            { -- tuned on laz to be ranged exclusive
                name = "Outrider's Accuracy",
                type = "AA",
                cond = function(self, aaName, target)
                    return not Config:GetSetting('DoMelee')
                end,
            },
            {
                name = "Outrider's Attack",
                type = "AA",
            },
            { -- increases melee proc chance, but hate reduction applies to all spells
                name = "Imbued Ferocity",
                type = "AA",
                cond = function(self, aaName, target)
                    return Config:GetSetting('DoMelee') or mq.TLO.Me.PctAggro() >= 60
                end,
            },

            {
                name = "OoW_Chest",
                type = "Item",
            },
            {
                name = "Poison Arrows",
                type = "AA",
            },
            {
                name = "Bullseye",
                type = "Disc",
            },
            {
                name_func = function(self) return Config:GetSetting('ArrowBuffChoice') == 1 and "Scout's Mastery of Fire" or "Scout's Mastery of Ice" end,
                type = "AA",
            },
            {
                name_func = function(self) return Config:GetSetting('ArrowBuffChoice') == 1 and "Flaming Arrows" or "Frost Arrows" end,
                type = "AA",
                cond = function(self, aaName, target)
                    if mq.TLO.Me.Buff("Poison Arrows")() then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "JoltSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoJoltSpell') end,
                cond = function(self, spell, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 80
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ['Snare']      = {
            {
                name = "Entrap",
                type = "AA",
                load_cond = function() return Casting.CanUseAA("Entrap") end,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
            {
                name = "SnareSpell",
                type = "Spell",
                load_cond = function() return not Casting.CanUseAA("Entrap") end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
        },
        ['Emergency']  = {
            {
                name = "Protection of the Spirit Wolf",
                type = "AA",
            },
            {
                name = "Outrider's Evasion",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IHaveAggro(100) and not mq.TLO.Me.ActiveDisc() == "Weapon Shield Discipline"
                end,
            },
            {
                name = "WeaponShield",
                type = "Discipline",
                cond = function(self, discName, target)
                    return Targeting.IHaveAggro(100) and not mq.TLO.Me.Song("Outrider's Evasion")
                end,
            },
        },
        ['Combat']     = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if not Config:GetSetting('DoMelee') or Config:GetSetting('UseEpic') == 1 then return false end
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "SwarmDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSwarmDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "Cold Snap",
                type = "AA",
            },
            {
                name = "FireNukeT4",
                type = "Spell",
            },
            {
                name = "FireNukeT1",
                type = "Spell",
            },
            {
                name = "FlameSnap",
                type = "Spell",
            },
            {
                name = "ColdNukeT3",
                type = "Spell",
            },
            {
                name = "ColdNukeT2",
                type = "Spell",
            },
            {
                name = "ArrowHail",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            {
                name = "FocusedHail",
                type = "Spell",
            },
            {
                name = "Heartshot",
                type = "Spell",
            },
        },
        ['Weaves']     = {
            {
                name = "Kick",
                type = "Ability",
            },
            {
                name = "Snapkick",
                type = "Disc",
                cond = function(self, discName, target)
                    return mq.TLO.Me.PctEndurance() >= Config:GetSetting("ManaToNuke")
                end,
            },
        },
        ['GroupBuff']  = {
            {
                name = "PredatorBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target) and not (Targeting.TargetIsMyself(target) and mq.TLO.Me.Buff("Ward of the Hunter")())
                end,
            },
            {
                name = "StrengthHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStrengthBuff') then return false end
                    return Casting.GroupBuffCheck(spell, target) and not (Targeting.TargetIsMyself(target) and mq.TLO.Me.Buff("Ward of the Hunter")())
                end,
            },
            {
                name = "GuardBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target) and not (Targeting.TargetIsMyself(target) and mq.TLO.Me.Buff("Ward of the Hunter")())
                end,
            },
            {
                name = "RegenBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoRegenBuff') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ShieldDS",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoShieldDS') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Spirit of Eagle",
                type = "AA",
                load_cond = function() return Config:GetSetting('DoMoveBuffs') and Casting.CanUseAA("Spirit of Eagle") end,
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(Casting.GetAASpell(aaName))
                end,
                cond = function(self, aaName, target)
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "MoveBuff",
                type = "Spell",
                load_cond = function() return Config:GetSetting('DoMoveBuffs') and not Casting.CanUseAA("Spirit of Eagle") end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "MinDmgBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ColdResistBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoColdResist') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "FireResistBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoFireResist') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['Downtime']   = {
            {
                name = "SelfBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "EyeBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SkinBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "CoatBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "DDProc",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "NatureProc",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name_func = function(self) return Config:GetSetting('ArrowBuffChoice') == 1 and "Flaming Arrows" or "Frost Arrows" end,
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
    },
    ['SpellList']         = { -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
        {
            name = "Default Mode",
            -- cond = function(self) return true end, --Code kept here for illustration, if there is no condition to check, this line is not required
            spells = {
                { name = "HealSpell",   cond = function(self) return Config:GetSetting('DoHeals') end, },
                { name = "SnareSpell",  cond = function(self) return Config:GetSetting('DoSnare') and not Casting.CanUseAA('Entrap') end, },
                { name = "SwarmDot",    cond = function(self) return Config:GetSetting('DoSwarmDot') end, },
                { name = "FireNukeT1", },
                { name = "FireNukeT4", },
                { name = "ColdNukeT2", },
                { name = "ColdNukeT3", },
                { name = "FlameSnap", },
                { name = "Heartshot", },
                { name = "ArrowHail", },
                { name = "FocusedHail", },
                { name = "JoltSpell",   cond = function(self) return Config:GetSetting('DoJoltSpell') end, },
                { name = "MinDmgBuff", },
                { name = "MoveBuff",    cond = function(self) return Config:GetSetting('DoMoveBuffs') end, },
            },
        },
    },
    ['DefaultConfig']     = { --TODO: Condense pet proc options into a combo box and update entry conditions appropriately
        ['Mode']            = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What is the difference between the modes?",
            Answer = "Rangers currently only have one Mode. This may change in the future.",
        },

        --AEDamage
        ['DoAEDamage']      = {
            DisplayName = "Do AE Damage",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 101,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['AETargetCnt']     = {
            DisplayName = "AE Target Count",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 102,
            Tooltip = "Minimum number of valid targets before using AE Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
        },
        ['MaxAETargetCnt']  = {
            DisplayName = "Max AE Targets",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 103,
            Tooltip =
            "Maximum number of valid targets before using AE Spells, Disciplines or AA.\nUseful for setting up AE Mez at a higher threshold on another character in case you are overwhelmed.",
            Default = 5,
            Min = 2,
            Max = 30,
            FAQ = "How do I take advantage of the Max AE Targets setting?",
            Answer =
            "By limiting your max AE targets, you can set an AE Mez count that is slightly higher, to allow for the possiblity of mezzing if you are being overwhelmed.",
        },
        ['SafeAEDamage']    = {
            DisplayName = "AE Proximity Check",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 104,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },

        --Archery
        ['BowNavDistance']  = {
            DisplayName = "Bow Nav Distance",
            Group = "Combat",
            Header = "Positioning",
            Category = "Archery",
            Index = 101,
            Tooltip = "The distance from your target you should nav to for ranged attacks when necessary.\n" ..
                "If Nav Circle is enabled, the distance to circle at.",
            Default = 45,
            Min = 30,
            Max = 200,
            FAQ = "Why is my ranger rubber-banding, charging back and forth or changing heading constantly?",
            Answer = "Some terrain blocks line of sight while MQ reports that the ranger has line of sight.\n" ..
                "Reducing Bow Nav Distance to a value near the minimum or maximum may solve for some of these (not RG-Mercs) issues, as a workaround.",
        },
        ['NavCircle']       = {
            DisplayName = "Nav Circle",
            Group = "Combat",
            Header = "Positioning",
            Category = "Archery",
            Index = 102,
            Tooltip = "Use Nav to Circle your target while autofiring.",
            Default = false,
            RequiresLoadoutChange = true, -- this is a load condition
        },

        --Buffs
        ['ArrowBuffChoice'] = {
            DisplayName = "Arrow Element:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = "Choose which element you would like to focus on with Arrow buffs and Scout's Mastery\n" ..
                "We will use Poison Arrows during burns and switch back to this element (as able) afterwards.",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Cold', },
            Default = 1,
            Min = 1,
            Max = 2,
        },
        ['DoMoveBuffs']     = {
            DisplayName = "Do Spirit of Eagle",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip = "Cast Movement Spells/AA.",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why am I spamming movement buffs?",
            Answer = "Some move spells freely overwrite those of other classes, so if multiple movebuffs are being used, a buff loop may occur.\n" ..
                "Simply turn off movement buffs for the undesired class in their class options.",
        },
        ['DoRegenBuff']     = {
            DisplayName = "Do Regen Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 102,
            Tooltip = "Use your ST Regen Buff Line.",
            Default = false,
        },
        ['DoStrengthBuff']  = {
            DisplayName = " Do Strength HP Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 103,
            Tooltip = "Use your Strength of ... HP buff line.",
            Default = true,
        },
        ['DoShieldDS']      = {
            DisplayName = "Do Shield DS",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 104,
            Tooltip = "Use your Shield DS line of spells.",
            Default = true,
        },
        ['DoColdResist']    = {
            DisplayName = "Do Cold Resist",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 105,
            Tooltip = "Use your group cold resist buff.",
            Default = false,
            FAQ = "Why am I not using my single-target resist buff?",
            Answer = "By default, we will use the group versions you select. Config customization is required if you wish to use the single-target version.",
        },
        ['DoFireResist']    = {
            DisplayName = "Do Fire Resist",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 106,
            Tooltip = "Use your group cold resist buff.",
            Default = false,
        },


        --Combat
        ['DoSwarmDot']     = {
            DisplayName = "Swarm Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 101,
            Tooltip = "Use your Swarm line of dots (magic damage, 54s duration).",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['DotNamedOnly']   = {
            DisplayName = "Only Dot Named",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 102,
            Tooltip = "Any selected dot above will only be used on a named mob.",
            Default = true,
        },
        ['UseEpic']        = {
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
        },
        ['EmergencyStart'] = {
            DisplayName = "Emergency HP%",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 101,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },


        --Utility
        ['DoHeals']     = {
            DisplayName = "Do Heals",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Mem and cast your Salve spell.",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['DoJoltSpell'] = {
            DisplayName = "Do Jolt Spell",
            Group = "Abilities",
            Header = "Utility",
            Category = "Hate Reduction",
            Index = 101,
            Tooltip = "Use your Jolt spell when your aggro is high.",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['DoSnare']     = {
            DisplayName = "Use Snares",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Index = 101,
            Tooltip = "Use Snare(Snare Dot used until AA is available).",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['SnareCount']  = {
            DisplayName = "Snare Max Mob Count",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Index = 102,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
            Min = 1,
            Max = 99,
        },
    },
    ['ClassFAQ']          = {
        [1] = {
            Question = "What is the current status of this class config?",
            Answer = "This class config is currently a Work-In-Progress that was originally based off of the Project Lazarus config.\n\n" ..
                "  Up until T1 progression, it should work quite well, but may need some clickies managed on the clickies tab.\n\n" ..
                "  After that, expect performance to degrade somewhat as not all THF custom spells or items are added, and some Laz-specific entries may remain.\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}
