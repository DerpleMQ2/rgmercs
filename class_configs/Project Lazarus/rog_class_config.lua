local mq        = require('mq')
local Config    = require('utils.config')
local Core      = require("utils.core")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Strings   = require("utils.strings")
local Logger    = require("utils.logger")

return {
    _version            = "2.0 - Project Lazarus",
    _author             = "Derple, Algar, mackal",
    ['Modes']           = {
        'DPS',
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Fatestealer",
            "Nightshade, Blade of Entropy",
        },
        ['Coating'] = {
            "Spirit Drinker's Coating",
            "Blood Drinker's Coating",
        },
    },
    ['AbilitySets']     = {
        ["ConditionedReflexes"] = {
            "Conditioned Reflexes",
            "Practiced Reflexes",
        },
        ["PracticedReflexes"] = {
            "Practiced Reflexes",
        },
        ["ThiefBuff"] = {
            "Thief's Sight",  -- Level 117
            "Thief's Vision", -- Level 96
            "Thief's Eyes",   -- Level 68
        },
        ["DaggerThrow"] = {
            "Queseris' Dagger",       -- Level 122
            "Shadow-Hunter's Dagger", -- Level 102
        },
        ["Slice"] = {                 --Timer 1
            "Carve",                  -- Level 123
            "Lance",                  -- Level 118
            "Slash",                  -- Level 113
            "Slice",                  -- Level 108
            "Hack",                   -- Level 103
            "Gash",                   -- Level 98
            "Lacerate",               -- Level 93
            "Wound",                  -- Level 88
            "Bleed",                  -- Level 83
        },
        ["Executioner"] = {
            "Executioner Discipline",  -- Level 100
            "Eradicator's Discipline", -- Level 95
            "Assassin Discipline",     -- Level 75
            "Duelist Discipline",      -- Level 59
            "Kinesthetics Discipline", -- Level 57
        },
        ["Twisted"] = {
            "Twisted Chance Discipline", -- Level 65
            "Deadeye Discipline",        -- Level 54
        },
        ["ProcBuff"] = {
            "Weapon Covenant",    -- Level 97
            "Weapon Bond",        -- Level 92
            "Weapon Affiliation", -- Level 87
        },
        ["Frenzied"] = {
            "Frenzied Stabbing Discipline", -- Level 70
        },
        ["Ambush"] = {
            "Bamboozle",       -- Level 121
            "Ambuscade",       -- Level 116
            "Bushwhack",       -- Level 111
            "Lie in Wait",     -- Level 106
            "Surprise Attack", -- Level 101
            "Beset",           -- Level 96
            "Accost",          -- Level 91
            "Assail",          -- Level 86
            "Ambush",          -- Level 81
            "Waylay",          -- Level 76
        },
        ["SneakAttack"] = {
            "Daggerslash",           -- Level 115
            "Daggerslice",           -- Level 110
            "Daggergash",            -- Level 105
            "Daggerthrust",          -- Level 100
            "Daggerstrike",          -- Level 95
            "Daggerswipe",           -- Level 90
            "Daggerlunge",           -- Level 85
            "Swiftblade",            -- Level 80
            "Razorarc",              -- Level 70
            "Daggerfall",            -- Level 69
            "Ancient: Chaos Strike", -- Level 65
            "Kyv Strike",            -- Level 65
            "Assassin's Strike",     -- Level 63
            "Thief's Vengeance",     -- Level 52
            "Sneak Attack",          -- Level 20
        },
        ["PoisonBlade"] = {
            "Venomous Blade",    -- Level 123
            "Netherbian Blade",  -- Level 118
            "Drachnid Blade",    -- Level 113
            "Skorpikis Blade",   -- Level 108
            "Reefcrawler Blade", -- Level 103
            "Asp Blade",         -- Level 98
            "Toxic Blade",       -- Level 93
        },
        ["FellStrike"] = {
            "Mayhem",       -- Level 125
            "Shadowstrike", -- Level 120
            "Blitzstrike",  -- Level 115
            "Fellstrike",   -- Level 110
            "Barrage",      -- Level 105
            "Incursion",    -- Level 100
            "Onslaught",    -- Level 95
            "Battery",      -- Level 90
            "Assault",      -- Level 85
        },
        ["Pinpoint"] = {
            "Pinpoint Fault",         -- Level 124
            "Pinpoint Defects",       -- Level 114
            "Pinpoint Shortcomings",  -- Level 109
            "Pinpoint Deficiencies",  -- Level 99
            "Pinpoint Liabilities",   -- Level 94
            "Pinpoint Flaws",         -- Level 89
            "Pinpoint Vitals",        -- Level 84
            "Pinpoint Weaknesses",    -- Level 79
            "Pinpoint Vulnerability", -- Level 74
        },
        ["Puncture"] = {
            "Invidious Puncture",      -- Level 124
            "Disorienting Puncture",   -- Level 119
            "Vindictive Puncture",     -- Level 114
            "Vexatious Puncture",      -- Level 109
            "Disassociative Puncture", -- Level 104
        },
        ['EndRegen'] = {
            --Timer 13, can't be used in combat
            "Second Wind", -- Level 72
            "Third Wind",
            "Fourth Wind",
            "Respite",
            "Reprieve",
            "Rest",
            "Breather", --Level 101
        },
        ['CombatEndRegen'] = {
            --Timer 13, can be used in combat.
            "Hiatus", --Level 106
            "Relax",
            "Night's Calming",
            "Convalesce",
        },
        ["CADisc"] = {
            "Counterattack Discipline",
        },
        ["EdgeDisc"] = {
            "Reckless Edge Discipline", -- Level 121
            "Ragged Edge Discipline",   -- Level 107
            "Razor's Edge Discipline",  -- Level 92
        },
        ["AspDisc"] = {
            "Crinotoxin Discipline", -- Level 124
            "Exotoxin Discipline",   -- Level 119
            "Chelicerae Discipline", -- Level 114
            "Aculeus Discipline",    -- Level 109
            "Arcwork Discipline",    -- Level 104
            "Aspbleeder Discipline", -- Level 99
        },
        ["AimDisc"] = {
            "Baleful Aim Discipline", --  Level 116
            "Lethal Aim Discipline",  --  Level 108
            "Fatal Aim Discipline",   --  Level 98
            "Deadly Aim Discipline",  --  Level 68
        },
        ["MarkDisc"] = {
            "Unsuspecting Mark", -- Level 121
            "Foolish Mark",      -- Level 116
            "Naive Mark",        -- Level 111
            "Dim-Witted Mark",   -- Level 106
            "Wide-Eyed Mark",    -- Level 101
            "Gullible Mark",     -- Level 96
            "Gullible Mark",     -- Level 91
            "Easy Mark",         -- Level 86
        },
        ["Jugular"] = {
            "Jugular Slash",    -- Level 77
            "Jugular Slice",    -- Level 82
            "Jugular Sever",    -- Level 87
            "Jugular Gash",     -- Level 92
            "Jugular Lacerate", -- Level 97
            "Jugular Hack",     -- Level 102
            "Jugular Strike",   -- Level 107
            "Jugular Cut",      -- Level 112
            "Jugular Rend",     -- Level 117
            "Jugular Hew",      -- Level 122
        },
        ["Phantom"] = {
            "Phantom Assassin", -- Level 100
        },
        ["SecretBlade"] = {
            "Veiled Blade",     -- Level 124
            "Obfuscated Blade", -- Level 119
            "Cloaked Blade",    -- Level 114
            "Secret Blade",     -- Level 109
            "Hidden Blade",     -- Level 104
            "Holdout Blade",    -- Level 99
        },
        ["DichoSpell"] = {
            "Reciprocal Weapons", -- Level 121
            "Ecliptic Weapons",   -- Level 116
            "Composite Weapons",  -- Level 111
            "Dissident Weapons",  -- Level 106
            "Dichotomic Weapons", -- Level 101
        },
        ["Alliance"] = {
            "Poisonous Covariance",  -- Level 123
            "Poisonous Covenant",    -- Level 118
            "Poisonous Alliance",    -- Level 113
            "Poisonous Coalition",   -- Level 108
            "Poisonous Conjunction", -- Level 103
        },
        ["Knifeplay"] = {
            "Knifeplay Discipline", -- Level 98, Timer 16
        },
        ["HateDebuff"] = {          --Timer 11, Aggro reduction and Aggro modifier for current target
            "Trickery",             -- Level 124
            "Beguile",              -- Level 119
            "Cozen",                -- Level 114
            "Diversion",            -- Level 109
            "Disorientation",       -- Level 104
            "Deceit",               -- Level 99
            "Delusion",             -- Level 94
            "Misdirection",         -- Level 89
        },

    },
    ['RotationOrder']   = {
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Aggro Management',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctAggro() > (Config:GetSetting('HideAggro') or 90)
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
            name = 'CombatBuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['Rotations']       = {
        ['Burn'] = {
            {
                name = "Frenzied",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            {
                name = "Twisted",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            {
                name = "Executioner",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            {
                name = "EdgeDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            {
                name = "Rogue's Fury",
                type = "AA",
            },
            {
                name = "Pinpoint",
                type = "Disc",
            },
            {
                name = "MarkDisc",
                type = "Disc",
            },
            {
                name = "Spire of the Rake",
                type = "AA",
            },
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "PoisonBlade",
                type = "Disc",
            },
            {
                name = "Dicho",
                type = "Disc",
            },
            {
                name = "Shadow's Flanking",
                type = "AA",
            },
            {
                name = "Rake's Rampage",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting("DoAEDamage") then return false end
                    return self.ClassConfig.HelperFunctions.AETargetCheck(self)
                end,
            },
            {
                name = "Focused Rake's Rampage",
                type = "AA",
                cond = function(self, aaName)
                    return not Config:GetSetting("DoAEDamage")
                end,
            },
            {
                name = "Phantom",
                type = "Disc",
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVetAA')
                end,
            },
        },
        ["Aggro Management"] = {
            {
                name = "Escape",
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Hide",
                type = "Ability",
                pre_activate = function(self, abilityName)
                    if Core.OnEMU() then
                        Core.DoCmd("/attack off")
                        mq.delay(100, function() return not mq.TLO.Me.Combat() end)
                    end
                end,
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > Config:GetSetting('HideAggro')
                end,
                post_activate = function(self, abilityName, success)
                    if not mq.TLO.Me.Combat() then
                        Core.DoCmd("/attack on")
                    end
                end,
            },
        },
        ['CombatBuff'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if Config:GetSetting('UseEpic') == 1 then return false end
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "Knifeplay",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "AspDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "ProcBuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "CombatEndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Alliance",
                type = "Disc",
                cond = function(self, discSpell)
                    if not Config:GetSetting('DoAlliance') then return false end
                    return not Casting.TargetHasBuff(discSpell.Trigger(1))
                end,
            },
            {
                name = "PoisonName",
                type = "ClickyItem",
                cond = function(self)
                    return Casting.SelfBuffItemCheck(Config:GetSetting('PoisonName'))
                end,
            },
            {
                name = "Assassin's Premonition",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.BurnCheck()
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Backstab",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Casting.CanUseAA("Chaotic Stab") or mq.TLO.Stick.Behind()
                end,
            },
            {
                name = "Carve",
                type = "Disc",
            },
            {
                name = "SecretBlade",
                type = "Disc",
            },
            {
                name = "FellStrike",
                type = "Disc",
            },
            {
                name = "Jugular",
                type = "Disc",
            },
            {
                name = "Twisted Shank",
                type = "AA",
            },
            {
                name = "Puncture",
                type = "Disc",
            },
            {
                name = "DaggerThrow",
                type = "Disc",
            },
            { --Check ToT to ensure we are not boosting the hate generation of someone we shouldn't be
                name = "HateDebuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.TargetOfTarget.ID() == (mq.TLO.Group.MainTank.ID() or Core.GetMainAssistId())
                end,
            },
            {
                name = "Intimidation",
                type = "Ability",
                cond = function(self, abilityName)
                    return Casting.AARank("Intimidation") > 1
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoVetAA') then return false end
                    return mq.TLO.Me.PctHPs() < 35
                end,
            },
            {
                name = "Tumble",
                type = "AA",
            },
            {
                name = "Coating",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCoating') then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "CADisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Targeting.IHaveAggro(100)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "ThiefBuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    if self:GetResolvedActionMapItem("CombatEndRegen") then return false end
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "CombatEndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "PoisonClicky",
                type = "ClickyItem",
                active_cond = function(self, _)
                    return (mq.TLO.FindItemCount(Config:GetSetting('PoisonName'))() or 0) >= Config:GetSetting('PoisonItemCount')
                end,
                cond = function(self, _)
                    return (mq.TLO.FindItemCount(Config:GetSetting('PoisonName'))() or 0) < Config:GetSetting('PoisonItemCount') and
                        mq.TLO.Me.ItemReady(Config:GetSetting('PoisonClicky'))()
                end,
            },
            {
                name = "PoisonName",
                type = "ClickyItem",
                active_cond = function(self, _)
                    local poisonItem = mq.TLO.FindItem(Config:GetSetting('PoisonName'))
                    return poisonItem and poisonItem() and Casting.IHaveBuff(poisonItem.Spell.ID() or 0)
                end,
                cond = function(self)
                    return Casting.SelfBuffItemCheck(Config:GetSetting('PoisonName'))
                end,
            },
            {
                name = "Envenomed Blades",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Hide & Sneak",
                type = "CustomFunc",
                active_cond = function(self)
                    return mq.TLO.Me.Invis() and mq.TLO.Me.Sneaking()
                end,
                cond = function(self)
                    return Config:GetSetting('DoHideSneak')
                end,
                custom_func = function(_)
                    if Config:GetSetting('ChaseOn') then
                        if not mq.TLO.Me.Sneaking() then
                            Core.DoCmd("/doability sneak")
                        end
                    else
                        if mq.TLO.Me.AbilityReady("hide")() then Core.DoCmd("/doability hide") end
                        if mq.TLO.Me.AbilityReady("sneak")() then Core.DoCmd("/doability sneak") end
                    end
                    return true
                end,
            },
        },
    },
    ['HelperFunctions'] = {
        PreEngage = function(target)
            local openerAbility = Core.GetResolvedActionMapItem('SneakAttack')

            if not Config:GetSetting("DoOpener") or not openerAbility then return end

            Logger.log_debug("\ayPreEngage(): Testing Opener ability = %s", openerAbility or "None")

            if mq.TLO.Me.CombatAbilityReady(openerAbility)() and not mq.TLO.Me.AbilityReady("Hide")() and mq.TLO.Me.AbilityTimer("Hide")() <= math.max(0, mq.TLO.Me.AbilityTimerTotal("Hide")() - 4000) and mq.TLO.Me.Invis() then
                Casting.UseDisc(openerAbility, target)
                Logger.log_debug("\agPreEngage(): Using Opener ability = %s", openerAbility or "None")
            else
                Logger.log_debug("\arPreEngage(): NOT using Opener ability = %s, DoOpener = %s, Hide Ready = %s, Hide Timer = %d, Invis = %s", openerAbility or "None",
                    Strings.BoolToColorString(Config:GetSetting("DoOpener")), Strings.BoolToColorString(mq.TLO.Me.AbilityReady("Hide")()),
                    mq.TLO.Me.AbilityTimer("Hide")(), Strings.BoolToColorString(mq.TLO.Me.Invis()))
            end
        end,
        BurnDiscCheck = function(self)
            if mq.TLO.Me.ActiveDisc.Name() == "Counterattack Discipline" or mq.TLO.Me.PctHPs() < Config:GetSetting('EmergencyStart') then return false end
            local burnDisc = { "Frenzied", "Twisted", "Executioner", "EdgeDisc", }
            for _, buffName in ipairs(burnDisc) do
                local resolvedDisc = self:GetResolvedActionMapItem(buffName)
                if resolvedDisc and resolvedDisc.RankName() == mq.TLO.Me.ActiveDisc.Name() then return false end
            end
            return true
        end,
        --function to make sure we don't have non-hostiles in range before we use AE damage
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
        UnwantedAggroCheck = function(self) --Self-Explanatory. Add isTanking to this if you ever make a mode for roguetanks!
            if Targeting.GetXTHaterCount() == 0 or Core.IAmMA() or mq.TLO.Group.Puller.ID() == mq.TLO.Me.ID() then return false end
            return Targeting.IHaveAggro(100)
        end,
    },
    ['DefaultConfig']   = {
        ['Mode']            = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes do?",
            Answer = "Currently Rogues only have DPS mode, this may change in the future",
        },
        -- Poison
        ['PoisonName']      = {
            DisplayName = "Poison Item",
            Category = "Poison",
            Tooltip = "Click the poison you want to use here",
            Type = "ClickyItem",
            Default = "",
            FAQ = "Can I specify the poison I want to use?",
            Answer = "Yes you set your poison item by placing its name into the [PoisonName] field.\n" ..
                "You can drag and drop the poison item from your inventory into the field.",
        },
        ['PoisonClicky']    = {
            DisplayName = "Poison Clicky",
            Category = "Poison",
            Tooltip = "Click the poison summoner you want to use here",
            Type = "ClickyItem",
            Default = "",
            FAQ = "I want to use a clicky item to summon my poisons, how do I do that?",
            Answer = "You can set your poison summoner by placing its name into the [PoisonClicky] field.\n" ..
                "You can drag and drop the poison summoner item from your inventory into the field.",
        },
        ['PoisonItemCount'] = {
            DisplayName = "Poison Item Count",
            Category = "Poison",
            Tooltip = "Min number of poison before we start summoning more",
            Default = 3,
            Min = 1,
            Max = 50,
            FAQ = "I am always summoning more poison, how can I make sure to summon enough the first time?",
            Answer = "You can set the minimum number of poisons you want to have before summoning more by setting the [PoisonItemCount] field.",
        },
        -- Abilities
        ['DoHideSneak']     = {
            DisplayName = "Do Hide/Sneak Click",
            Category = "Abilities",
            Index = 1,
            Tooltip = "Use Hide/Sneak during Downtime",
            Default = true,
            FAQ = "How can I make sure to always be sneaking / hiding for maximum DPS?",
            Answer = "Enable [DoHideSneak] if you want to use Hide/Sneak during Downtime.\n" ..
                "This will keep you ready to ambush or backstab at a moments notice.",
        },
        ['DoOpener']        = {
            DisplayName = "Use Openers",
            Category = "Abilities",
            Index = 2,
            Tooltip = "Use Sneak Attack line to start combat (e.g, Daggerslash).",
            Default = true,
            FAQ = "Why would I not want to use Openers?",
            Answer = "Enable [DoOpener] if you want to use the opener ability.",
        },
        ['DoAEDamage']      = {
            DisplayName = "Do AE Damage",
            Category = "Abilities",
            Index = 3,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Discs and AA. **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['AETargetCnt']     = {
            DisplayName = "AE Target Count",
            Category = "Abilities",
            Index = 4,
            Tooltip = "Minimum number of valid targets before using AE Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['MaxAETargetCnt']  = {
            DisplayName = "Max AE Targets",
            Category = "Abilities",
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
            Category = "Abilities",
            Index = 6,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },
        ['EmergencyStart']  = {
            DisplayName = "Emergency HP%",
            Category = "Abilities",
            Index = 7,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "How do I use my Emergency Mitigation Abilities?",
            Answer = "Make sure you have [EmergencyStart] set to the HP % before we begin to use emergency mitigation abilities.",
        },
        ['HideAggro']       = {
            DisplayName = "Hide Aggro%",
            Category = "Abilities",
            Index = 8,
            Tooltip = "Your Aggro % before we will attempt to Hide from our current target.",
            Default = 90,
            Min = 1,
            Max = 100,
            FAQ = "Can I customize when to use Hide?",
            Answer = "Yes, you can set the aggro % at which to use Hide with the [HideAggro] setting.",
        },
        ['DoVetAA']         = {
            DisplayName = "Use Vet AA",
            Category = "Abilities",
            Index = 9,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does MNK use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },
        --Equipment
        ['UseEpic']         = {
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
            FAQ = "Why is my BRD using Epic on these trash mobs?",
            Answer = "By default, we use the Epic in any combat, as saving it for burns ends up being a DPS loss over a long frame of time.\n" ..
                "This can be adjusted in the Utility/Items/Misc tab.",
        },
        ['DoChestClick']    = {
            DisplayName = "Do Chest Click",
            Category = "Equipment",
            Index = 2,
            Tooltip = "Click your chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            ConfigType = "Advanced",
            FAQ = "What is a Chest Click?",
            Answer = "Most Chest slot items after level 75ish have a clickable effect.\n" ..
                "ROG is set to use theirs during burns, so long as the item equipped has a clicky effect.",
        },
        ['DoCoating']       = {
            DisplayName = "Use Coating",
            Category = "Equipment",
            Index = 3,
            Tooltip = "Click your Blood/Spirit Drinker's Coating in an emergency.",
            Default = false,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },
        --Orphaned (remove when config goes default)
        ['DoEpic']          = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
    },
}
