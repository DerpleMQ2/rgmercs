local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    _version          = "1.0 Beta",
    _author           = "Derple",
    ['Modes']         = {
        'DPS',
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Fatestealer",
            "Nightshade, Blade of Entropy",
        },
    },
    ['AbilitySets']   = {
        ["ConditionedReflexes"] = {
            "Conditioned Reflexes",
            "Practiced Reflexes",
        },
        ["PracticedReflexes"] = {
            "Practiced Reflexes",
        },
        ["Vision"] = {
            "Thief's Sight",  -- Level 117
            "Thief's Vision", -- Level 96
            "Thief's Eyes",   -- Level 68
        },
        ["Shadowhunter"] = {
            "Shadow-Hunter's Dagger", -- Level 102
        },
        ["Slice"] = {
            "Carve",    -- Level 123
            "Lance",    -- Level 118
            "Slash",    -- Level 113
            "Slice",    -- Level 108
            "Hack",     -- Level 103
            "Gash",     -- Level 98
            "Lacerate", -- Level 93
            "Wound",    -- Level 88
            "Bleed",    -- Level 83
        },
        ["Executioner"] = {
            "Executioner Discipline",  -- Level 100
            "Eradicator's Discipline", -- Level 95
            "Assassin Discipline",     -- Level 75
            "Duelist Discipline",      -- Level 59
            "Kinesthetics Discipline", -- Level 57
        },
        ["Executioner2"] = {
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
            "Disorienting Puncture",   -- Level 119
            "Vindictive Puncture",     -- Level 114
            "Vexatious Puncture",      -- Level 109
            "Disassociative Puncture", -- Level 104
        },
        ["EndRegen"] = {
            "Breather",    -- Level 101
            -- [] = "Seventh Wind",    -- Level 97 - Sac Endurance for Regen
            "Rest",        -- Level 96
            -- [] = "Sixth Wind",    -- Level 92 - Sac Endurance for Regen
            "Reprieve",    -- Level 91
            -- [] = "Fifth Wind",    -- Level 87 - Sac Endurance for Regen
            "Respite",     -- Level 86
            -- [] = "Fourth Wind",    -- Level 82 - Sac Endurance for Regen
            "Third Wind",  -- Level 77
            "Second Wind", -- Level 72
        },
        ["CounterattackDiscipline"] = {
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
            "Jugular,",         -- Level 82
            "Jugular Sever",    -- Level 87
            "Jugular Gash",     -- Level 92
            "Jugular Lacerate", -- Level 97
            "Jugular Hack",     -- Level 102
            "Jugular Strike",   -- Level 107
            "Jugular Cut",      -- Level 112
            "Jugular Rend",     -- Level 117
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
            "Ecliptic Weapons",   -- Level 116
            "Composite Weapons",  -- Level 111
            "Dissident Weapons",  -- Level 106
            "Dichotomic Weapons", -- Level 101
        },
        ["Alliance"] = {
            "Poisonous Covenant",    -- Level 118
            "Poisonous Alliance",    -- Level 113
            "Poisonous Coalition",   -- Level 108
            "Poisonous Conjunction", -- Level 103
        },
    },
    ['RotationOrder'] = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime"
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.BurnCheck()
            end,
        },
        {
            name = 'Evasion',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.IAmMA() and RGMercUtils.GetMainAssistPctHPs() > 0 and mq.TLO.Me.PctAggro() > 90
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['Rotations']     = {
        ['Burn'] = {
            {
                name = "Shadow's Flanking",
                type = "AA",
            },
            {
                name = "Focused Rake's Rampage",
                type = "AA",
            },
            {
                name = "Rogue's Fury",
                type = "AA",
            },
            {
                name = "Spire of the Rake",
                type = "AA",
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return item() and mq.TLO.Me.Song(item.Spell.RankName.Name())() ~= nil
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.GetSetting('DoChestClick') and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    local item = mq.TLO.FindItem(itemName)
                    return item and item() and RGMercUtils.GetSetting('DoEpic') and item.Spell.Stacks() and item.TimerReady()
                end,
            },
            {
                name = "Pinpoint",
                type = "Disc",
            },
            {
                name = "Frenzied",
                type = "Disc",
                cond = function(self, discSpell)
                    return (RGMercUtils.GetSetting('BurnAuto') or RGMercUtils:BigBurn()) and not mq.TLO.Me.ActiveDisc.ID() and
                        mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())()
                end,
            },
            {
                name = "Twisted",
                type = "Disc",
                cond = function(self, discSpell)
                    return (RGMercUtils.GetSetting('BurnAuto') or RGMercUtils:BigBurn()) and not mq.TLO.Me.ActiveDisc.ID() and
                        mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())()
                end,
            },
            {
                name = "AimDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return (RGMercUtils.GetSetting('BurnAuto') or RGMercUtils:BigBurn()) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Executioner",
                type = "Disc",
                cond = function(self, discSpell)
                    return (RGMercUtils.GetSetting('BurnAuto') or RGMercUtils:BigBurn()) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Executioner2",
                type = "Disc",
                cond = function(self, discSpell)
                    return (RGMercUtils.GetSetting('BurnAuto') or RGMercUtils:BigBurn()) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "EdgeDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "AspDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Backstab",
                type = "Ability",
                cond = function(self, _)
                    return RGMercUtils.CanUseAA("Chaotic Stab")
                end,
            },
            -- if we dont have CS then make sure we are behind.
            {
                name = "Backstab",
                type = "Ability",
                cond = function(self, _)
                    return not RGMercUtils.CanUseAA("Chaotic Stab") and mq.TLO.Stick.Behind()
                end,
            },
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.ActiveDisc.ID() and not RGMercUtils.SongActive(discSpell.RankName.Name() or "") and mq.TLO.Me.PctEndurance() < 21
                end,
            },
            {
                name = "Ambush",
                type = "Disc",
                cond = function(self, discSpell)
                    local discSpell = mq.TLO.Spell(discSpell)
                    return mq.TLO.Me.PctEndurance() >= 5 and
                        RGMercUtils.GetTargetPctHPs() >= 90 and
                        RGMercUtils.GetTargetDistance() < 50 and
                        (discSpell() and RGMercUtils.GetTargetLevel() <= discSpell.Level()) and
                        mq.TLO.Me.CombatState():lower() ~= "combat"
                end,
            },
            {
                name = "AimDisc",
                type = "Disc",
                cond = function(self, _)
                    return mq.TLO.Me.ActiveDisc.ID() == nil
                end,
            },
            {
                name = "Vision",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.SongActive(discSpell.Name())
                end,
            },
            {
                name = "Pinpoint",
                type = "Disc",
            },
            {
                name = "Jugular",
                type = "Disc",
                cond = function(self, discSpell)
                    local discSpell = mq.TLO.Spell(discSpell)
                    return (discSpell() and discSpell.Level() <= 82) and mq.TLO.Me.CombatState():lower() ~= "combat"
                end,
            },
            {
                name = "FellStrike",
                type = "Disc",
                cond = function(self, _)
                    return mq.TLO.Me.Level() <= 20
                end,
            },
            {
                name = "Slice",
                type = "Disc",
            },
            {
                name = "Twisted Shank",
                type = "AA",
            },
            {
                name = "Ligament Slice",
                type = "AA",
            },
            {
                name = "PoisonName",
                type = "ClickyItem",
                cond = function(self, _)
                    local poisonItem = mq.TLO.FindItem(RGMercUtils.GetSetting('PoisonName'))
                    return poisonItem and poisonItem() and poisonItem.Timer.TotalSeconds() == 0 and
                        not RGMercUtils.BuffActiveByID(poisonItem.Spell.ID())
                end,
            },
        },
        ['Evasion'] = {
            {
                name = "Escape",
                type = "AA",
            },
            {
                name = "CounterattackDiscipline",
                type = "Disc",
            },
            {
                name = "Tumble",
                type = "AA",
            },
            {
                name = "Phantom",
                type = "Disc",
            },
        },
        ['Downtime'] = {
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, _)
                    return mq.TLO.Me.PctEndurance() < 21
                end,
            },
            {
                name = "PoisonClicky",
                type = "ClickyItem",
                active_cond = function(self, _)
                    return (mq.TLO.FindItemCount(RGMercUtils.GetSetting('PoisonName'))() or 0) >= RGMercUtils.GetSetting('PoisonItemCount')
                end,
                cond = function(self, _)
                    return (mq.TLO.FindItemCount(RGMercUtils.GetSetting('PoisonName'))() or 0) < RGMercUtils.GetSetting('PoisonItemCount') and
                        mq.TLO.FindItem(RGMercUtils.GetSetting('PoisonClicky'))() and
                        mq.TLO.FindItem(RGMercUtils.GetSetting('PoisonClicky')).Timer() == 0
                end,
            },
            {
                name = "PoisonName",
                type = "ClickyItem",
                active_cond = function(self, _)
                    local poisonItem = mq.TLO.FindItem(RGMercUtils.GetSetting('PoisonName'))
                    return poisonItem and poisonItem() and RGMercUtils.BuffActiveByID(poisonItem.Spell.ID() or 0)
                end,
                cond = function(self, _)
                    local poisonItem = mq.TLO.FindItem(RGMercUtils.GetSetting('PoisonName'))
                    return poisonItem and poisonItem() and poisonItem.Timer.TotalSeconds() == 0 and
                        not RGMercUtils.BuffActiveByID(poisonItem.Spell.ID())
                end,
            },
            {
                name = "Hide & Sneak",
                type = "CustomFunc",
                active_cond = function(self)
                    return mq.TLO.Me.Invis() and mq.TLO.Me.Sneaking()
                end,
                cond = function(self)
                    return RGMercUtils.GetSetting('DoHideSneak')
                end,
                custom_func = function(_)
                    if RGMercUtils.GetSetting('ChaseOn') then
                        if mq.TLO.Me.Sneaking() then
                            RGMercUtils.DoCmd("/doability sneak")
                        end
                    else
                        if mq.TLO.Me.AbilityReady("hide")() then RGMercUtils.DoCmd("/doability hide") end
                        if mq.TLO.Me.AbilityReady("sneak")() then RGMercUtils.DoCmd("/doability sneak") end
                    end
                    return true
                end,
            },
        },
    },
    ['Spells']        = {
        { name = "", gem = 1, },
        { name = "", gem = 2, },
        { name = "", gem = 3, },
        { name = "", gem = 4, },
        { name = "", gem = 5, },
        { name = "", gem = 6, },
        { name = "", gem = 7, },
        { name = "", gem = 8, },
        { name = "", gem = 9, },
        { name = "", gem = 10, },
        { name = "", gem = 11, },
        { name = "", gem = 12, },
    },
    ['DefaultConfig'] = {
        ['Mode']            = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 1, },
        ['PoisonName']      = { DisplayName = "Poison Item", Category = "Poison", Tooltip = "Click the poison you want to use here", Type = "ClickyItem", Default = "", },
        ['PoisonClicky']    = { DisplayName = "Poison Clicky", Category = "Poison", Tooltip = "Click the poison summoner you want to use here", Type = "ClickyItem", Default = "", },
        ['PoisonItemCount'] = { DisplayName = "Poison Item Count", Category = "Poison", Tooltip = "Min number of poison before we start summoning more", Default = 3, Min = 1, Max = 50, },
        ['DoChestClick']    = { DisplayName = "Do Check Click", Category = "Utilities", Tooltip = "Click your chest item", Default = true, },
        ['DoEpic']          = { DisplayName = "Do Epic Click", Category = "Utilities", Tooltip = "Click your epic item", Default = true, },
        ['DoHideSneak']     = { DisplayName = "Do Hide/Sneak Click", Category = "Utilities", Tooltip = "Use Hide/Sneak during Downtime", Default = true, },
    },
}
