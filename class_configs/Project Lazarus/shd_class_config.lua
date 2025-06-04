local mq           = require('mq')
local ItemManager  = require("utils.item_manager")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Ui           = require("utils.ui")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Logger       = require("utils.logger")
local Set          = require('mq.set')

--todo: add a LOT of tooltips or scrap them entirely. Hopefully the former.
local Tooltips     = {
    Mantle              = "Spell Line: Melee Absorb Proc",
    Carapace            = "Spell Line: Melee Absorb Proc",
    CombatEndRegen      = "Discipline Line: Endurance Regen (In-Combat Useable)",
    EndRegen            = "Discipline Line: Endurance Regen (Out of Combat)",
    Blade               = "Ability Line: Double 2HS Attack w/ Accuracy Mod",
    Crimson             = "Disicpline Line: Triple Attack w/ Accuracy Mod",
    MeleeMit            = "Discipline Line: Absorb Incoming Dmg",
    Deflection          = "Discipline: Shield Block Chance 100%",
    LeechCurse          = "Discipline: Melee LifeTap w/ Increase Hit Chance",
    UnholyAura          = "Discipline: Increase LifeTap Spell Damage",
    Guardian            = "Discipline: Melee Mitigation w/ Defensive LifeTap & Lowered Melee DMG Output",
    PetSpell            = "Spell Line: Summons SK Pet",
    PetHaste            = "Spell Line: Haste Buff for SK Pet",
    Shroud              = "Spell Line: Add Melee LifeTap Proc",
    Horror              = "Spell Line: Proc HP Return",
    Mental              = "Spell Line: Proc Mana Return",
    Skin                = "Spell Line: Melee Absorb Proc",
    SelfDS              = "Spell Line: Self Damage Shield",
    Demeanor            = "Spell Line: Add LifeTap Proc Buff on Killshot",
    HealBurn            = "Spell Line: Add Hate Proc on Incoming Spell Damage",
    CloakHP             = "Spell Line: Increase HP and Stacking DS",
    Covenant            = "Spell Line: Increase Mana Regen + Ultravision / Decrease HP Per Tick",
    CallAtk             = "Spell Line: Increase Attack / Decrease HP Per Tick",
    AETaunt             = "Spell Line: PBAE Hate Increase + Taunt",
    PoisonDot           = "Spell Line: Poison Dot",
    SpearNuke           = "Spell Line: Instacast Disease Nuke",
    AESpearNuke         = "Spell Line: Instacast Directional Disease Nuke",
    BondTap             = "Spell Line: LifeTap DOT",
    DireTap             = "Spell Line: LifeTap",
    LifeTap             = "Spell Line: LifeTap",
    AELifeTap           = "Spell Line: AE Dmg + Max HP Buff",
    BiteTap             = "Spell Line: LifeTap + ManaTap",
    ForPower            = "Spell Line: Hate Increase + Hate Increase DOT + AC Buff 'BY THE POWER OF GRAYSKULL, I HAVE THE POWER -- HE-MAN'",
    Terror              = "Spell Line: Hate Increase + Taunt",
    TempHP              = "Spell Line: Temporary Hitpoints (Decrease per Tick)",
    Dicho               = "Spell Line: Hate Increase + LifeTap",
    PowerTapAC          = "Spell Line: AC Tap",
    PowerTapAtk         = "Spell Line: Attack Tap",
    SnareDot            = "Spell Line: Snare + HP DOT",
    Acrimony            = "Spell Increase: Aggrolock + LifeTap DOT + Hate Generation",
    SpiteStrike         = "Spell Line: LifeTap + Caster 1H Blunt Increase + Target Armor Decrease",
    ReflexStrike        = "Ability: Triple 2HS Attack + HP Increase",
    DireDot             = "Spell Line: DOT + AC Decrease + Strength Decrease",
    AllianceNuke        = "Spell Line: Alliance (Requires Multiple of Same Class) - Increase Spell Damage Taken by Target + Large LifeTap",
    InfluenceDisc       = "Ability Line: Increase AC + Absorb Damage + Melee Proc (LifeTap + Max HP Increase)",
    DLUA                = "AA: Cast Highest Level of Scribed Buffs (Shroud, Horror, Drape, Demeanor, Skin, Covenant, CallATK)",
    DLUB                = "AA: Cast Highest Level of Scribed Buffs (Shroud, Mental, Drape, Demeanor, Skin, Covenant, CallATK)",
    HarmTouch           = "AA: Harms Target HP",
    ThoughtLeech        = "AA: Harms Target HP + Harms Target Mana",
    VisageOfDeath       = "Spell: Increases Melee Hit Dmg + Illusion",
    LeechTouch          = "AA: LifeTap Touch",
    Tvyls               = "Spell: Triple 2HS Attack + % Melee Damage Increase on Target",
    ActivateShield      = "Activate 'Shield' if set in Bandolier",
    Activate2HS         = "Activate '2HS' if set in Bandolier",
    ExplosionOfHatred   = "Spell: Targeted AE Hatred Increase",
    ExplosionOfSpite    = "Spell: Targeted PBAE Hatred Increase",
    Taunt               = "Ability: Increases Hatred to 100% + 1",
    EncroachingDarkness = "Ability: Snare + HP DOT",
    Epic                = 'Item: Casts Epic Weapon Ability',
    ViciousBiteOfChaos  = "Spell: Duration LifeTap + Mana Return",
    Bash                = "Use Bash Ability",
    Slam                = "Use Slam Ability",
    HateBuff            = "Spell/AA: Increase Hate Generation",
}

local _ClassConfig = {
    _version            = "2.5 - Project Lazarus",
    _author             = "Algar, Derple",
    ['ModeChecks']      = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
    },
    ['Modes']           = {
        'Tank',
        'DPS',
    },
    ['Themes']          = {
        ['Tank'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabActive,        color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.5, g = 0.05, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.3, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.2, g = 0.05, b = 0.05, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.0, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.0, g = 0.05, b = 0.05, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
        },
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Innoruuk's Dark Blessing",
            "Innoruuk's Voice",
        },
        ['OoW_Chest'] = {
            "Heartstiller's Mail Chestguard",
            "Duskbringer's Plate Chestguard of the Hateful",
        },
        ['Coating'] = {
            "Spirit Drinker's Coating",
            "Blood Drinker's Coating",
        },
    },
    ['AbilitySets']     = {
        --Laz spells to look into: Fickle Shadows
        ['Mantle'] = {
            "Soul Shield",
            "Soul Guard",
            "Ichor Guard", -- Level 56, Timer 5
        },
        ['Deflection'] = {
            "Rampart Discipline",
            "Deflection Discipline",
        },

        ['LeechCurse'] = { 'Leechcurse Discipline', },

        ['UnholyAura'] = { 'Unholy Aura Discipline', },

        ['PetSpell'] = {
            "Son of Decay",
            "Invoke Death",
            "Cackling Bones",
            "Leering Corpse",
            "Malignant Dead",
            "Summon Dead",
            "Animate Dead",
            "Restless Bones",
            "Bone Walk",
            "Convoke Shadow",
            "Leering Corpse,",
        },
        ['PetHaste'] = {
            "Rune of Decay",
            "Augmentation of Death",
            "Augment Death",
            "Strengthen Death",
        },
        ['Horror'] = {           -- HP Tap Proc
            "Shroud of Discord", -- Level 67 -- Buff Slot 1 <
            "Shroud of Chaos",   -- Level 63
            "Shroud of Death",   -- Level 55
        },
        ['Mental'] = {           -- Mana Tap Proc
            "Mental Horror",     -- Level 65 --Buff Slot 1 >
            "Mental Corruption", -- Level 52
        },
        ['Skin'] = {
            "Decrepit Skin", -- Level 70
        },
        ['SelfDS'] = {
            "Banshee Aura",
        },
        ['CloakHP'] = {
            "Cloak of the Akheva",
            "Cloak of Luclin",
            "Cloak of Discord",
        },
        ['CallAtk'] = {
            "Call of Darkness",
        },
        ['AETaunt'] = {
            "Dread Gaze", -- Level 69
        },
        ['PoisonDot'] = {
            "Blood of Pain", -- Level 41
            "Blood of Hate",
            "Blood of Discord",
            "Blood of Inruku",
        },
        ['SpearNuke'] = {
            "Spike of Disease", -- Level 1
            "Spear of Disease",
            "Spear of Pain",
            "Spear of Plague",
        },
        ['AESpearNuke'] = {
            "Spear of Decay",
            "Miasmic Spear",
            "Spear of Muram",
        },
        ['BondTap'] = {
            "Bond of Inruku",
            "Bond of Death",
            "Vampiric Curse", -- Level 57
        },
        ['LifeTap'] = {
            "Touch of the Devourer",
            "Touch of Inruku",
            "Touch of Innoruuk",
            --"Touch of Volatis", -- Drain Soul buffed on Lazarus and is superior to this.
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Life Leech",
            "Lifedraw",
            "Lifespike", -- Level 15
            "Lifetap",   -- Level 8
        },
        ['LifeTap2'] = {
            "Touch of the Devourer",
            "Touch of Inruku",
            "Touch of Innoruuk",
            --"Touch of Volatis", -- Drain Soul buffed on Lazarus and is superior to this.
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Life Leech",
            "Lifedraw",
            "Lifespike",
            "Lifetap", -- Level 8
        },
        ['AELifeTap'] = {
            "Grasp of Lhranc",
        },
        ['BiteTap'] = {
            "Zevfeer's Bite", -- Level 62
            "Inruku's Bite",
            "Ancient: Bite of Muram",
        },
        ['Terror'] = {
            "Terror of Darkness", -- Level 33
            "Terror of Shadows",  -- Level 42
            "Terror of Death",
            "Terror of Terris",
            "Terror of Thule",
            "Terror of Discord",
        },
        ['Terror2'] = {
            "Terror of Darkness",
            "Terror of Shadows",
            "Terror of Death",
            "Terror of Terris",
            "Terror of Thule",
            "Terror of Discord",
        },
        ['PowerTapAC'] = {
            "Theft of Agony",
            "Theft of Pain",
            "Aura of Pain",
            "Torrent of Pain",
            "Shroud of Pain",
            "Scream of Pain",
        },
        ['PowerTapAtk'] = {
            "Theft of Hate",
            "Aura of Hate",
            "Torrent of Hate",
            "Shroud of Hate",
            "Scream of Hate",
        },
        ['SnareDot'] = {
            "Festering Darkness",
            "Cascading Darkness",
            "Dooming Darkness",
            "Engulfing Darkness",
            "Clinging Darkness", -- Level 11
        },
        ['DireDot'] = {
            "Dark Constriction",
            "Asystole",
            "Heart Flutter",
            "Disease Cloud",
        },
        ['HateBuff'] = {         --9 minute reuse makes these somewhat ridiculous to gem on the fly.
            "Voice of Innoruuk", -- Level 70, 15% hate, 150pt DS (slot 9), 15% decrease DS Mit (VoT AA is still better for tanking at 24%, but they stack. DS smexy)
            "Voice of Thule",    -- level 60, 12% hate
            "Voice of Terris",   -- level 55, 10% hate
            "Voice of Death",    -- level 50, 6% hate
            "Voice of Shadows",  -- level 46, 4% hate
            "Voice of Darkness", -- level 39, 2% hate
        },
    },
    ['HelperFunctions'] = {
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
        --function to space out Epic and Omens Chest with Mortal Coil old-school swarm style. Epic has an override condition to fire anyway on named.
        LeechCheck = function(self)
            local LeechEffects = { "Leechcurse Discipline", "Mortal Coil", "Lich Sting Recourse", "Reaper Strike Recourse", "Vampiric Aura", }
            for _, buffName in ipairs(LeechEffects) do
                if Casting.IHaveBuff(buffName) then return false end
            end
            return true
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
    ['RotationOrder']   = {
        { --Self Buffs
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 60,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
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
                ---@diagnostic disable-next-line: undefined-field -- doesn't like secondarypct
                return combat_state == "Combat" and (mq.TLO.Me.PctAggro() < 100 or (mq.TLO.Target.SecondaryPctAggro() or 0) > 60 or Targeting.IsNamed(Targeting.GetAutoTarget()))
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'AEHateTools',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function()
                return Core.IsTanking() and
                    ((Config:GetSetting('AETauntSpell') and Core.GetResolvedActionMapItem('AETauntSpell')) or (Config:GetSetting('AETauntAA') and (Casting.CanUseAA("Explosion of Spite") or Casting.CanUseAA("Explosion of Hatred"))))
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
            name = 'LifeTaps',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
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
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and not Targeting.IsNamed(Targeting.GetAutoTarget()) and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
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
    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "Horror",
                type = "Spell",
                tooltip = Tooltips.Horror,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if Config:GetSetting('ProcChoice') ~= 1 then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Mental",
                type = "Spell",
                tooltip = Tooltips.Horror,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if Config:GetSetting('ProcChoice') ~= 2 then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "CloakHP",
                type = "Spell",
                tooltip = Tooltips.CloakHP,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfDS",
                type = "Spell",
                tooltip = Tooltips.SelfDS,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "CallAtk",
                type = "Spell",
                tooltip = Tooltips.CallAtk,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and not Casting.IHaveBuff("Howl of the Predator") --fix for bad stacking check
                end,
            },
            --You'll notice my use of TotalSeconds, this is to keep as close to 100% uptime as possible on these buffs, rebuffing early to decrease the chance of them falling off in combat
            --I considered creating a function (helper or utils) to govern this as I use it on multiple classes but the difference between buff window/song window/aa/spell etc makes it unwieldy
            -- if using duration checks, dont use SelfBuffCheck() (as it could return false when the effect is still on)
            {
                name = "Skin",
                type = "Spell",
                tooltip = Tooltips.Skin,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return spell.RankName.Stacks() and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 60
                        --laz specific deconflict
                        and not Casting.IHaveBuff("Necrotic Pustules")
                end,
            },
            {
                name = "Voice of Thule",
                type = "AA",
                tooltip = Tooltips.HateBuff,
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    if not Config:GetSetting('DoHateBuff') then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            { -- Leve 70 buff less hate mod than Voice of Thule but has a 150pt damage shield; we can use them together.
                name = "HateBuff",
                type = "Spell",
                tooltip = Tooltips.HateBuff,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Config:GetSetting('DoHateBuff') or not Casting.CastReady(spell) then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Emergency Visage Cancel",
                type = "CustomFunc",
                custom_func = function(self)
                    if Config:GetSetting('HPCritical') and mq.TLO.Me.Buff("Visage of Death")() then
                        Core.DoCmd("/removebuff \"Visage of Death\"")
                    end
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                tooltip = Tooltips.PetSpell,
                active_cond = function(self, spell) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell)
                    if mq.TLO.Me.Pet.ID() ~= 0 or not Config:GetSetting('DoPet') then return false end
                    return Casting.ReagentCheck(spell)
                end,
                post_activate = function(self, spell, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetHaste",
                type = "Spell",
                tooltip = Tooltips.PetHaste,
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "Fortify Companion",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "Crystalized Soul Gem", -- This isn't a typo
                type = "Item",
                cond = function(self, itemName)
                    return Casting.PetBuffItemCheck(itemName)
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
                tooltip = Tooltips.ArmorofExperience,
                cond = function(self)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') and Config:GetSetting('DoVetAA')
                end,
            },
            {
                name = "OoW_Chest",
                type = "Item",
                tooltip = Tooltips.OoW_BP,
            },
            { --Note that on named we may already have a defensive disc running already, could make this remove other discs, but we have other options.
                name = "Deflection",
                type = "Disc",
                tooltip = Tooltips.Deflection,
                pre_activate = function(self)
                    if Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "LeechCurse",
                type = "Disc",
                tooltip = Tooltips.LeechCurse,
                cond = function(self)
                    return Casting.NoDiscActive() and not mq.TLO.Me.Song("Rampart")()
                end,
            },
            {
                name = "UnholyAura",
                type = "Disc",
                tooltip = Tooltips.UnholyAura,
                cond = function(self, discSpell, target)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Emergency Visage Cancel",
                type = "CustomFunc",
                custom_func = function(self)
                    if Config:GetSetting('HPCritical') and mq.TLO.Me.Buff("Visage of Death")() then
                        Core.DoCmd("/removebuff \"Visage of Death\"")
                    end
                end,
            },
        },
        ['HateTools'] = {
            { --more valuable on laz because we have less hate tools and no other hatelist + 1 abilities
                name = "Taunt",
                type = "Ability",
                tooltip = Tooltips.Taunt,
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and target.ID() > 0 and Targeting.GetTargetDistance(target) < 30
                end,
            },
            { --pull does not work on Laz, it is just a hate tool
                name = "Hate's Attraction",
                type = "AA",
                tooltip = Tooltips.AgelessEnmity,
                cond = function(self, aaName, target)
                    return (Targeting.GetAutoTargetPctHPs() < 90 and mq.TLO.Me.PctAggro() < 100) or Targeting.IsNamed(target)
                end,
            },

            { --8min reuse, save for named or if we still can't get a mob back on us
                name = "Ageless Enmity",
                type = "AA",
                tooltip = Tooltips.AgelessEnmity,
                cond = function(self, aaName, target)
                    return Targeting.GetAutoTargetPctHPs() < 90 and (mq.TLO.Me.PctAggro() < 100 or Targeting.IsNamed(target))
                end,
            },
            {
                name = "Projection of Doom",
                type = "AA",
                tooltip = Tooltips.ProjectionofDoom,
                cond = function(self, aaName, target)
                    ---@diagnostic disable-next-line: undefined-field
                    return Targeting.IsNamed(target) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 80
                end,
            },
            {
                name = "Terror",
                type = "Spell",
                tooltip = Tooltips.Terror,
                cond = function(self, spell, target)
                    if Config:GetSetting('DoTerror') == 1 or mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                    ---@diagnostic disable-next-line: undefined-field
                    return (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
            {
                name = "Terror2",
                type = "Spell",
                tooltip = Tooltips.Terror,
                cond = function(self, spell, target)
                    if Config:GetSetting('DoTerror') == 1 or mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                    ---@diagnostic disable-next-line: undefined-field
                    return (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
        },
        ['AEHateTools'] = {
            {
                name = "Explosion of Hatred",
                type = "AA",
                tooltip = Tooltips.ExplosionOfHatred,
            },
            {
                name = "Explosion of Spite",
                type = "AA",
                tooltip = Tooltips.ExplosionOfSpite,
            },
            {
                name = "AETaunt",
                type = "Spell",
                tooltip = Tooltips.AETaunt,
                cond = function(self, spell, target)
                    return mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyStart')
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Visage of Death",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVisage')
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVetAA')
                end,
            },
            {
                name = "Fundament: Third Spire of the Reavers",
                type = "AA",
                cond = function(self, aaName, target)
                    return Core.IsTanking()
                end,
            },
            { -- for DPS mode
                name = "UnholyAura",
                type = "Disc",
                tooltip = Tooltips.UnholyAura,
                cond = function(self)
                    return not Core.IsTanking() and Casting.NoDiscActive() and not mq.TLO.Me.Song("Rampart")()
                end,
            },
            {
                name = "Harm Touch",
                type = "AA",
                tooltip = Tooltips.HarmTouch,
            },
            {
                name = "Leech Touch",
                type = "AA",
                tooltip = Tooltips.ThoughtLeech,
                cond = function(self, aaName, target)
                    return Config:GetSetting('DoLeechTouch') ~= 1
                end,
            },
            {
                name = "Chattering Bones",
                type = "AA",
                tooltip = Tooltips.ChatteringBones,
            },
            {
                name = "Scourge Skin",
                type = "AA",
                --tooltip = Tooltips.ScourgeSkin,
                cond = function(self, aaName)
                    if not Core.IsTanking() then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Terror",
                type = "Spell",
                tooltip = Tooltips.Terror,
                cond = function(self, spell, target)
                    if not Core.IsTanking() or not Config:GetSetting('DoTerror') then return false end
                    return Targeting.IsNamed(target) and (Casting.CanUseAA("Cascading Theft of Defense") and not Casting.IHaveBuff("Cascading Theft of Defense"))
                end,
            },
            {
                name = "Skin",
                type = "Spell",
                tooltip = Tooltips.Skin,
                cond = function(self, spell, target)
                    if not Core.IsTanking() or not Targeting.IsNamed(target) then return false end
                    return Casting.SelfBuffCheck(spell)
                        --laz specific deconflict
                        and not Casting.IHaveBuff("Necrotic Pustules")
                end,
            },
        },
        ['Snare'] = {
            {
                name = "Encroaching Darkness",
                tooltip = Tooltips.EncroachingDarkness,
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target)
                end,
            },
            {
                name = "SnareDot",
                type = "Spell",
                tooltip = Tooltips.SnareDot,
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Encroaching Darkness") then return false end
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target)
                end,
            },
        },
        ['Defenses'] = {
            {
                name = "Mantle",
                type = "Disc",
                tooltip = Tooltips.Mantle,
                cond = function(self, discSpell, target)
                    if not Core.IsTanking() then return false end
                    return Casting.NoDiscActive() and not mq.TLO.Me.Song("Rampart")()
                end,
            },
            {
                name = "Epic",
                type = "Item",
                tooltip = Tooltips.Epic,
                cond = function(self, itemName, target)
                    return self.ClassConfig.HelperFunctions.LeechCheck(self) or Targeting.IsNamed(target)
                end,
            },
            {
                name = "Coating",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCoating') then return false end
                    return Casting.SelfBuffItemCheck(itemName) and self.ClassConfig.HelperFunctions.LeechCheck(self)
                end,
            },
            {
                name = "Purity of Death",
                type = "AA",
                tooltip = Tooltips.PurityofDeath,
                cond = function(self)
                    ---@diagnostic disable-next-line: undefined-field
                    return mq.TLO.Me.TotalCounters() > 0
                end,
            },
        },
        ['LifeTaps'] = {
            --Full rotation to make sure we use these in priority for emergencies
            {
                name = "Leech Touch",
                type = "AA",
                tooltip = Tooltips.LeechTouch,
                cond = function(self, aaName, target)
                    if Config:GetSetting('DoLeechTouch') == 2 then return false end
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical')
                end,
            },
            {
                name = "LifeTap",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell)
                    local myHP = mq.TLO.Me.PctHPs()
                    return Casting.HaveManaToNuke() and myHP <= Config:GetSetting('StartLifeTap') or myHP <= Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "AELifeTap", --conditions on this may require further tuning, right now it does not respect the start tap settings
                type = "Spell",
                tooltip = Tooltips.AELifeTap,
                cond = function(self, spell)
                    if not (Config:GetSetting('DoAELifeTap') and Config:GetSetting('DoAEDamage')) or not spell or not spell() then return false end
                    return Casting.SelfBuffCheck(spell) and self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            {
                name = "LifeTap2",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell)
                    local myHP = mq.TLO.Me.PctHPs()
                    return Casting.HaveManaToNuke() and myHP <= Config:GetSetting('StartLifeTap') or myHP <= Config:GetSetting('EmergencyStart')
                end,
            },
        },
        ['Combat'] = {
            {
                name = "BondTap",
                type = "Spell",
                tooltip = Tooltips.BondTap,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoBondTap') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "AESpearNuke",
                type = "Spell",
                tooltip = Tooltips.AESpearNuke,
                cond = function(self, spell, target)
                    if not (Config:GetSetting('DoAESpearNuke') and Config:GetSetting('DoAEDamage')) then return false end
                    return Casting.HaveManaToNuke() and Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "SpearNuke",
                type = "Spell",
                tooltip = Tooltips.SpearNuke,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "PoisonDot",
                type = "Spell",
                tooltip = Tooltips.PoisonDot,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoPoisonDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "DireDot",
                type = "Spell",
                tooltip = Tooltips.DireDot,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDireDot') or (Config:GetSetting('DotNamedOnly') and not Targeting.IsNamed(target)) then return false end
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "BiteTap",
                type = "Spell",
                tooltip = Tooltips.BiteTap,
            },
            {
                name = "Vicious Bite of Chaos",
                type = "AA",
                tooltip = Tooltips.ViciousBiteOfChaos,
            },
            {
                name = "Unbridled Strike of Fear",
                type = "AA",
            },
            {
                name = "PowerTapAC",
                type = "Spell",
                tooltip = Tooltips.PowerTapAC,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoACTap') or not spell or not spell() then return false end
                    return not Casting.IHaveBuff(spell.Trigger())
                end,
            },
            {
                name = "PowerTapAtk",
                type = "Spell",
                tooltip = Tooltips.PowerTapAtk,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAtkTap') or not spell or not spell() then return false end
                    return not Casting.IHaveBuff(spell.Trigger())
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                tooltip = Tooltips.Bash,
                cond = function(self)
                    return (Core.ShieldEquipped() or Casting.CanUseAA("2 Hand Bash"))
                end,
            },
            {
                name = "Slam",
                type = "Ability",
                tooltip = Tooltips.Slam,
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
    -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
    -- The list name ("Default" in the list below) is abitrary, it is simply what shows up in the UI when this spell list is loaded.
    -- Virtually any helper function or TLO can be used as a condition. Example: Mode or level-based lists.
    -- The first list without conditions or whose conditions returns true will be loaded, all subsequent lists will be ignored.
    -- Spells will be loaded in order (if the conditions are met), until all gem slots are full.
    -- Loadout checks (such as scribing a spell or using the "Rescan Loadout" or "Reload Spells" buttons) will re-check these lists and may load a different set if things have changed.
    ['SpellList']       = {
        {
            name = "Default",
            -- cond = function(self) return true end, --Kept here for illustration, this line could be removed in this instance since we aren't using conditions.
            spells = {
                { -- We can use name functions to choose between two spells based on whether the listed conditions are true or false (so that we don't memorize both).
                    name_func = function(self)
                        return (Config:GetSetting('DoAESpearNuke') and Core.GetResolvedActionMapItem('AESpearNuke')) and "AESpearNuke" or "SpearNuke"
                    end, -- This will set the spell name to "AESpearNuke" if the setting is enabled and we have a valid spell in our book.
                },
                { name = "LifeTap", },
                { name = "SnareDot",    cond = function(self) return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Encroaching Darkness") end, },
                { name = "Terror",      cond = function(self) return Config:GetSetting('DoTerror') end, },
                { name = "AETaunt",     cond = function(self) return Config:GetSetting('AETauntSpell') end, },
                { name = "BiteTap", },
                { name = "BondTap",     cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",   cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "DireDot",     cond = function(self) return Config:GetSetting('DoDireDot') end, },
                { name = "PowerTapAC",  cond = function(self) return Config:GetSetting('DoACTap') end, },
                { name = "PowerTapAtk", cond = function(self) return Config:GetSetting('DoAtkTap') end, },
                { name = "AELifeTap",   cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "Skin", },
                { name = "HateBuff",    cond = function(self) return Config:GetSetting('DoHateBuff') end, },
                { name = "LifeTap2", },
                { name = "Terror2",     cond = function(self) return Config:GetSetting('DoTerror') end, },
            },
        },
    },
    ['PullAbilities']   = {
        {
            id = 'SpearNuke',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('SpearNuke').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('SpearNuke').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('SpearNuke')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'Terror',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('Terror')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'LifeTap',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('LifeTap').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('LifeTap').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('LifeTap')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'LifeTap2',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('LifeTap2').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('LifeTap2').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('LifeTap2')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']   = {
        --Mode
        ['Mode']            = {
            DisplayName = "Mode",
            Category = "Mode",
            Tooltip = "Select the active Combat Mode for this PC.",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes do?",
            Answer = "Tank Mode will focus on tanking and aggro, while DPS mode will focus on DPS.",
        },

        --Buffs and Debuffs
        ['DoSnare']         = {
            DisplayName = "Use Snares",
            Category = "Buffs/Debuffs",
            Index = 1,
            Tooltip = "Use Snare(Snare Dot used until AA is available).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not snaring?",
            Answer = "Make sure Use Snares is enabled in your class settings.",
        },
        ['SnareCount']      = {
            DisplayName = "Snare Max Mob Count",
            Category = "Buffs/Debuffs",
            Index = 2,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
            Min = 1,
            Max = 99,
            FAQ = "Why is my Shadow Knight Not snaring?",
            Answer = "Make sure you have [DoSnare] enabled in your class settings.\n" ..
                "Double check the Snare Max Mob Count setting, it will prevent snare from being used if there are more than [x] mobs on aggro.",
        },
        ['ProcChoice']      = {
            DisplayName = "HP/Mana Proc:",
            Category = "Buffs/Debuffs",
            Index = 4,
            Tooltip = "Prefer HP Proc and DLU(Azia) or Mana Proc and DLU(Beza)",
            Type = "Combo",
            ComboOptions = { 'HP Proc: Terror Line, DLU(Azia)', 'Mana Proc: Mental Line, DLU(Beza)', 'Disabled', },
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "I am constantly running out of mana, what can I do to help?",
            Answer = "During certain level ranges, it may be helpful to use the Mana Proc (Mental) line over the HP proc (Terror) line.\n" ..
                "This can be adjusted on the Buffs/Debuffs tab.",
        },
        ['DoVisage']        = {
            DisplayName = "Use Visage of Death",
            Category = "Buffs/Debuffs",
            Index = 5,
            Tooltip = "Use the Visage of Death AA.",
            Default = true,
            FAQ = "Why is my health draining so quickly out of combat?",
            Answer =
            "You may have Visage of Death enabled, which has a sizable self-damage component. While we will attempt to autocancel this at low health in downtime, you can disable VoD use in the Class options.",
        },
        ['DoVetAA']         = {
            DisplayName = "Use Vet AA",
            Category = "Buffs/Debuffs",
            Index = 6,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does SHD use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },

        --Taps
        ['StartLifeTap']    = {
            DisplayName = "HP % for LifeTaps",
            Category = "Taps",
            Index = 1,
            Tooltip = "Your HP % before we use Life Taps.",
            Default = 99,
            Min = 1,
            Max = 100,
            FAQ = "Why is my Shadow Knight not using Life Taps?",
            Answer = "Make sure you have [DoLifeTap] enabled in your class settings.\n" ..
                "Double check [StartLifeTap] seetting, this setting will prevent Life Taps from being used if your HP is above [x]%",
        },
        ['DoACTap']         = {
            DisplayName = "Use AC Tap",
            Category = "Taps",
            Index = 2,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("PowerTapAC") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my AC Tap?",
            Answer = "AC Taps have a large period of receiving no updates (between 71 and 99). We will avoid using them after Level 75 until they are updated again.",
        },
        ['DoAtkTap']        = {
            DisplayName = "Use Attack Tap",
            Category = "Taps",
            Index = 3,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("PowerTapAtk") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my Attack Tap?",
            Answer = "Attack Taps don't receive an update after level 70; by default we will not use them after level 75.",
        },
        ['DoLeechTouch']    = {
            DisplayName = "Leech Touch Use:",
            Category = "Taps",
            Index = 4,
            Tooltip = "When to use Leech Touch",
            Type = "Combo",
            ComboOptions = { 'On critically low HP', 'As DD during burns', 'For HP or DD', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using Leech Touch?",
            Answer = "You can choose the conditions under which you will use Leech Touch on the Taps tab.",
        },
        -- ['DoThoughtLeech']   = { --commented because on aa list but inactive
        --     DisplayName = "Thought Leech Use:",
        --     Category = "Taps",
        --     Index = 5,
        --     Tooltip = "When to use Thought Leech",
        --     Type = "Combo",
        --     ComboOptions = { 'On critically low mana', 'As DD during burns', 'For Mana or DD', },
        --     Default = 3,
        --     Min = 1,
        --     Max = 3,
        --     ConfigType = "Advanced",
        --     FAQ = "Why is my Shadow Knight not using Thought Leech?",
        --     Answer = "You can choose the conditions under which you will use Thought Leech on the Taps tab.",
        -- },

        --DoT Spells
        ['DoBondTap']       = {
            DisplayName = "Use Bond Dot",
            Category = "DoT Spells",
            Index = 1,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("BondTap") end,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why do I spend so much mana using these DoTs?",
            Answer = "Dots have additional settings in the RGMercs Main config, such as the min mana% to use them.",
        },
        ['DoPoisonDot']     = {
            DisplayName = "Use Poison Dot",
            Category = "DoT Spells",
            Index = 2,
            ToolTip = function() return Ui.GetDynamicTooltipForSpell("PoisonDot") end,
            RequiresLoadoutChange = false,
            Default = true,
            FAQ = "Why do I use a DoT just before a mob dies?",
            Answer = "Dots have additional settings in the RGMercs Main config, such as the HP% to stop using them (for both trash and named).",
        },
        ['DoDireDot']       = {
            DisplayName = "Use Dire Dot",
            Category = "DoT Spells",
            Index = 3,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("DireDot") end,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why is my Shadow Knight not using Dire Dot?",
            Answer = "Dire Dot is not enabled by default, you may need to select it.",
        },
        ['DotNamedOnly']    = {
            DisplayName = "Only Dot Named",
            Category = "DoT Spells",
            Index = 4,
            Tooltip = "Any selected dot above will only be used on a named mob.",
            Default = true,
            FAQ = "Why am I not using my dots?",
            Answer = "Make sure the dot is enabled in your class settings and make sure that the mob is named if that option is selected.\n" ..
                "You can read more about named mobs on the RGMercs named tab (and learn how to add one on your own!)",
        },

        --AE Damage
        -- AE Damage
        ['DoAEDamage']      = {
            DisplayName = "Do AE Damage",
            Category = "AE Damage",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['DoAESpearNuke']   = {
            DisplayName = "Use AE Spear",
            Category = "AE Damage",
            Index = 2,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("AESpearNuke") end,
            Default = false,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why am I still using a lower-level spear spell?",
            Answer =
            "Recently, the three best Spears on Laz were converted to AE spells. Enable Use AE Spear for these spells to be memorized.\nAE Damage must also be enabled for them to be used.",
        },
        ['DoAELifeTap']     = {
            DisplayName = "Use AE Hate/LifeTap",
            Category = "AE Damage",
            Index = 3,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("AELifeTap") end,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why is my Shadow Knight not using the AE Tap (Insidious) Line?",
            Answer = "The Insidious AE Hate Life Tap is not enabled by default, you may need to select it.",
        },
        ['AETargetCnt']     = {
            DisplayName = "AE Target Count",
            Category = "AE Damage",
            Index = 4,
            Tooltip = "Minimum number of valid targets before using AE Spells, Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['MaxAETargetCnt']  = {
            DisplayName = "Max AE Targets",
            Category = "AE Damage",
            Index = 5,
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
            Category = "AE Damage",
            Index = 6,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },

        --Hate Tools
        ['DoHateBuff']      = {
            DisplayName = "Use Hate Buff",
            Category = "Hate Tools",
            Index = 1,
            Tooltip = "Use your Visage buff (Voice of ... line). If the AA is not available, we will use/memorize the spell if we have enough open slots.",
            Default = true,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my Visage Buff, Voice of ...?",
            Answer = "If you have the option selected in Buffs/Debuffs, you may not have enough spell gems to keep the spell on your bar with other options.\n" ..
                "Do to the incredibly long recast time (around 9 minutes), we will not memorize these to use them on the fly.",
        },
        ['DoTerror']        = {
            DisplayName = "Use Terror Taunts",
            Category = "Hate Tools",
            Index = 3,
            Tooltip = "Use Terror line taunts (the number memorized is based on your other selected options).",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight Not using Terror Taunts?",
            Answer = "You can elect to use Terrors on the Hate Tool tab. Bear in mind we won't use them until Secondary Aggro is above 60%.",
        },
        ['AETauntAA']       = {
            DisplayName = "Use AE Taunt AA",
            Category = "Hate Tools",
            Index = 3,
            Tooltip = "Use Explosions of Hatred and Spite.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why do we treat the Explosions the same? One is targeted, one is PBAE",
            Answer = "There are currently no scripted conditions where Hatred would be used at long range, thus, for ease of use, we can treat them similarly.",
        },
        ['AETauntSpell']    = {
            DisplayName = "Use AE Taunt Spell",
            Category = "Hate Tools",
            Index = 3,
            Tooltip = "Use your AE Taunt spell line.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using AE Taunt Spells?",
            Answer = "Make sure you have [AETauntSpell] enabled in your class settings and ensure you set [AETauntCnt] settings to match your current needs.",
        },
        ['AETauntCnt']      = {
            DisplayName = "AE Taunt Count",
            Category = "Hate Tools",
            Index = 6,
            Tooltip = "Minimum number of haters before using AE Taunt Spells or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why don't we use AE taunts on single targets?",
            Answer =
            "AE taunts are configured to only be used if a target has less than 100% hate on you, at whatever count you configure, so abilities with similar conditions may be used instead.",
        },
        ['SafeAETaunt']     = {
            DisplayName = "AE Taunt Safety Check",
            Category = "Hate Tools",
            Index = 7,
            Tooltip = "Limit unintended pulls with AE Taunt Spells or AA. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Taunt Safety Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the taunt.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the taunt not being used when it is safe to do so.",
        },

        --Defenses
        ['DiscCount']       = {
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
        ['DefenseStart']    = {
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
        ['EmergencyStart']  = {
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
        ['HPCritical']      = {
            DisplayName = "HP Critical",
            Category = "Defenses",
            Index = 4,
            Tooltip =
            "The HP % that we will use disciplines like Deflection, Leechcurse, and Leech Touch.\nMost other rotations are cut to give our full focus to survival (See FAQ).",
            Default = 20,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "What rotations are cut when HP % is critical?",
            Answer =
            "Hate Tools (including AE) and Leech Effect rotations are cut when HP% is critical.\nAdditionally, reaching the emergency threshold would've also cut the Snare, Burn, Combat Weave and Combat Rotations.",
        },

        --Equipment
        ['DoCoating']       = {
            DisplayName = "Use Coating",
            Category = "Equipment",
            Index = 2,
            Tooltip = "Click your Blood/Spirit Drinker's Coating when defenses are triggered.",
            Default = false,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },
        ['UseBandolier']    = {
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
        ['EquipShield']     = {
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
        ['Equip2Hand']      = {
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
        ['NamedShieldLock'] = {
            DisplayName = "Shield on Named",
            Category = "Equipment",
            Index = 6,
            Tooltip = "Keep Shield equipped for Named mobs(must be in SpawnMaster or named.lua)",
            Default = true,
            FAQ = "Why does my SHD switch to a Shield on puny gray named?",
            Answer = "The Shield on Named option doesn't check levels, so feel free to disable this setting (or Bandolier swapping entirely) if you are farming fodder.",
        },
    },
}

return _ClassConfig
