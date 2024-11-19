local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Logger       = require("utils.logger")

local _ClassConfig = {
    _version            = "1.0 - Live",
    _author             = "Derple",
    ['CommandHandlers'] = {
        defdisc = {
            usage = "/rgl defdisc",
            about = "Uses best warrior melee mitigation disc",
            handler = function(self, ...)
                local discSpell = Core.GetResolvedActionMapItem('meleemit')

                if discSpell and discSpell() and Casting.DiscReady(discSpell) then
                    if Casting.BuffActiveByName('Night\'s Endless Terror') then
                        Core.DoCmd('/docommand /removebuff "Night\'s Endless Terror"')
                        mq.delay(5)
                    end
                    Casting.UseDisc(discSpell, Targeting.GetTargetID())
                else
                    Logger.log_error("\ar COOL DOWN \ag >> \aw meleemit \ag << ")
                end
                return true
            end,
        },

        evadedisc = {
            usage = "/rgl evadedisc",
            about = "Uses best warrior evasion disc",
            handler = function(self, ...)
                local discSpell = Core.GetResolvedActionMapItem('missall')

                if discSpell and discSpell() and Casting.DiscReady(discSpell) then
                    Casting.UseDisc(discSpell, Targeting.GetTargetID())
                else
                    Logger.log_error("\ar COOL DOWN \ag >> \aw missall \ag << ")
                end
                return true
            end,
        },
    },
    ['ModeChecks']      = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
    },
    ['Modes']           = {
        'Tank',
        'DPS',
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Kreljnok's Sword of Eternal Power",
            "Champion's Sword of Eternal Power",
        },
    },
    ['AbilitySets']     = {
        ['meleemit'] = {
            "Climactic Stand",
            "Resolute Stand",
            "Ultimate Stand Discipline",
            "Culminating Stand Discipline",
            "Last Stand Discipline",
            "Final Stand Discipline",
            --[] = "Stonewall Discipline",
            "Defensive Discipline",
        },
        ['missall'] = {
            "Fortitude Discipline",
        },
        ['absorball'] = {
            "Finish the Fight",
            "Pain Doesn't Hurt",
            "No Time to Bleed",
        },
        ['parryall'] = {
            "Flash of Anger",
        },
        ['shieldhit'] = {
            "Shield Sunder",
            "Shield Break",
            "Shield Topple",
            "Shield Splinter",
            "Shield Rupture",
        },
        ['groupac'] = {
            "Field Bulwark",
            "Full Moon's Champion",
            "Paragon Champion",
            "Field Champion",
            "Field Protector",
            "Field Guardian",
            "Field Defender",
            "Field Outfitter",
            "Field Armorer",
        },
        ['groupdodge'] = {
            "Commanding Voice",
        },
        ['defenseac'] = {
            "Vigorous Defense",
            "Primal Defense",
            "Courageous Defense",
            "Resolute Defense",
            "Stout Defense",
            "Steadfast Defense",
            "Stalwart Defense",
            "Staunch Defense",
            "Bracing Defense",
        },
        ['bmdisc'] = {
            "Ecliptic Shield",
            "Composite Shield",
            "Dissident Shield",
            "Dichotomic Shield",
        },
        ['aeroar'] = {
            "Roar of Challenge",
            "Rallying Roar",
        },
        ['aeselfbuff'] = {
            "Wade into Battle",
            "Wade into Conflict",
        },
        ['aehealhate'] = {
            "Penumbral Expanse",
            "Confluent Expanse",
            "Concordant Expanse",
            "Harmonious Expanse",
        },
        ['singlehealhate'] = {
            "Penumbral Precision",
            "Confluent Precision",
            "Concordant Precision",
            "Harmonious Precision",
        },
        ['aehitall'] = {
            "Tempest Blades",
            "Dragonstrike Blades",
            "Stormstrike Blades",
            "Stormwheel Blades",
            "Cyclonic Blades",
            "Wheeling Blades",
            "Maelstrom Blade",
            "Whorl Blade",
            "Vortex Blade",
            "Cyclone Blade",
            "Whirlwind Blade",
            "Hurricane Blades",
            "Spiraling Blades",
        },
        ['AddHate1'] = {
            "Mortimus' Roar",
            "Namdrows' Roar",
            "Kragek's Roar",
            "Kluzen's Roar",
            "Cyclone Roar",
            "Krondal's Roar",
            "Grendlaen Roar",
            "Bazu Roar",
            "Ancient: Chaos Cry",
            "Bazu Bluster",
            "Bazu Bellow",
            "Bellow of the Mastruq",
            "Incite",
            "Berate",
            "Bellow",
            "Provoke",
        },
        ['AddHate2'] = {
            "Distressing Shout",
            "Twilight Shout",
            "Oppressing Shout",
            "Burning Shout",
            "Tormenting Shout",
            "Harassing Shout",
        },
        ['Taunt1'] = {
            "Infuriate",
            "Bristle",
            "Aggravate",
            "Slander",
            "Insult",
            "Ridicule",
            "Scorn",
            "Scoff",
            "Jeer",
            "Sneer",
            "Scowl",
            "Mock",
        },
        ['StrikeDisc'] = {
            "Decisive Strike",
            "Precision Strike",
            "Cunning Strike",
            "Calculated Strike",
            "Vital Strike",
            "Strategic Strike",
            "Opportunistic Strike",
            "Exploitive Strike",
        },
        ['endregen'] = {
            "Convalesce",
            "Night's Calming",
            "Hiatus",
            "Breather",
            "Rest",
            "Reprieve",
            "Respite",
            "Fourth Wind",
            "Third Wind",
            "Second Wind",
        },
        ['waraura'] = {
            "Champion's Aura",
            "Myrmidon's Aura",
        },
        ['AgroLock'] = {
            "Unending Attention",
            "Unyielding Attention",
            "Unflinching Attention",
            "Unbroken Attention",
            "Undivided Attention",
            "Unrelenting Attention",
            "Unconditional Attention",
        },
        ['AgroPet'] = {
            "Phantom Aggressor",
        },
        ['OnslaughtDisc'] = {
            "Savage Onslaught Discipline",
            "Brutal Onslaught Discipline",
            "Brightfeld's Onslaught Discipline",
        },
        ['RuneShield'] = {
            "Warrior's Resolve",
            "Warrior's Rampart",
            "Warrior's Aegis",
        },
    },
    ['RotationOrder']   = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    Casting.DoBuffCheck() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck() and not Casting.Feigning()
            end,
        },
        {
            name = 'Warrior Buffs',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.Feigning() and not Casting.BurnCheck()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.Feigning()
            end,
        },
    },
    ['Rotations']       = {
        ['Burn'] = {
            {
                name = "meleemit",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and string.find(mq.TLO.Me.ActiveDisc.Name() or "", "Defense") and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Spire of the Warlord",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "parryall",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and string.find(mq.TLO.Me.ActiveDisc.Name() or "", "Defense") and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "missall",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and string.find(mq.TLO.Me.ActiveDisc.Name() or "", "Defense") and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "bmdisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() > 20 and
                        not Casting.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "Brace for Impact",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Tank") and Casting.AAReady(aaName)
                end,
            },
            {
                name = "Imperator's Command",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Tank") and Casting.AAReady(aaName)
                end,
            },
            {
                name = "aehealhate",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() > 10 and
                        not Casting.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "aeselfbuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() > 10 and not Casting.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "Warlord's Bravery",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Warlord's Tenacity",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Warlord's Resurgence",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Warlord's Fury",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.TargetedAAReady(aaName)
                end,
            },
            {
                name = "War Sheol's Heroic Blade",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.TargetedAAReady(aaName)
                end,
            },

        },
        ['DPS'] = {
            {
                name = "aeroar",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and Targeting.GetXTHaterCount() >= Config:GetSetting('BurnMobCount') and
                        Config:GetSetting('DoAEAgro')
                end,
            },
            {
                name = "aehitall",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and Targeting.GetXTHaterCount() >= Config:GetSetting('BurnMobCount') and
                        Config:GetSetting('DoAEAgro')
                end,
            },
            {
                name = "Area Taunt",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Tank") and Casting.TargetedAAReady(aaName) and Targeting.GetXTHaterCount() >= Config:GetSetting('BurnMobCount') and
                        Config:GetSetting('DoAEAgro')
                end,
            },
            {
                name = "endregen",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() < 15 and
                        not Casting.SongActiveByName(discSpell.BaseName())
                end,
            },
            {
                name = "ActivateShield",
                type = "CustomFunc",
                cond = function(self)
                    return Core.IsModeActive("Tank") and Config:GetSetting('DoBandolier') and not mq.TLO.Me.Bandolier("Shield").Active() and
                        mq.TLO.Me.Bandolier("Shield").Index() and Casting.BurnCheck()
                end,
                custom_func = function(_)
                    Core.DoCmd("/bandolier activate Shield")
                    return true
                end,

            },
            {
                name = "ActivateAgro",
                type = "CustomFunc",
                cond = function(self)
                    return Core.IsModeActive("Tank") and Config:GetSetting('DoBandolier') and not mq.TLO.Me.Bandolier("Agro").Active() and
                        mq.TLO.Me.Bandolier("Agro").Index() and Targeting.GetXTHaterCount() < Config:GetSetting('BurnMobCount') and not Targeting.IsNamed(mq.TLO.Target)
                end,
                custom_func = function(_)
                    Core.DoCmd("/bandolier activate Agro")
                    return true
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                cond = function(self, abilityName)
                    return Core.IsModeActive("Tank") and mq.TLO.Me.AbilityReady(abilityName)() and
                        mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and Targeting.GetTargetDistance() < 30
                end,
            },
            {
                name = "AgroLock",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and
                        Targeting.GetTargetDistance() < 30
                end,
            },
            {
                name = "Taunt1",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and
                        Targeting.GetTargetDistance() < 30
                end,
            },
            {
                name = "Blast of Anger",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Tank") and Casting.TargetedAAReady(aaName) and mq.TLO.Me.SecondaryPctAggro() > 70 and Targeting.GetTargetDistance() < 80
                end,
            },
            {
                name = "AddHate1",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and Casting.DetSpellCheck(discSpell)
                end,
            },
            {
                name = "AddHate2",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and mq.TLO.Me.SecondaryPctAggro() > 70 and mq.TLO.Me.CurrentEndurance() > 500 and
                        Targeting.GetTargetDistance() < discSpell.Range()
                end,
            },
            {
                name = "aehealhate",
                type = "Disc",
                cond = function(self, discSpell)
                    local stHate = Core.GetResolvedActionMapItem('singlehealhate')
                    return Core.IsModeActive("Tank") and Config:GetSetting('DoAEHate') and Casting.DiscReady(discSpell) and
                        not Casting.BuffActiveByID(discSpell.ID()) and (stHate and not Casting.BuffActiveByID(stHate.ID()))
                end,
            },
            {
                name = "singlehealhate",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and
                        not Casting.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "parryall",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.PctHPs() < 30
                end,
            },
            {
                name = "absorball",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and mq.TLO.Me.PctHPs() < 30
                end,
            },
            {
                name = "defenseac",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return Core.IsModeActive("Tank") and Config:GetSetting('DoChestClick') and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
            {
                name = "Brace for Impact",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Tank") and Casting.AAReady(aaName) and not Casting.BuffActiveByName(aaName) and Config:GetSetting('DoBuffs') and
                        not Config:GetSetting('DoDefense')
                end,
            },
            {
                name = "Blade Guardian",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Tank") and Casting.AAReady(aaName) and not Casting.SongActiveByName(aaName) and Config:GetSetting('DoBuffs') and
                        not Config:GetSetting('DoDefense')
                end,
            },
            {
                name = "Battle Leap",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Tank") and Casting.TargetedAAReady(aaName) and not Casting.SongActiveByName(aaName)
                        and not Casting.SongActiveByName('Group Bestial Alignment') and Targeting.GetTargetMaxRangeTo() >= Targeting.GetTargetDistance() and
                        Config:GetSetting('DoBuffs') and
                        Config:GetSetting('DoBattleLeap')
                end,
            },
            {
                name = "Rampage",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoAEAgro') and Targeting.GetXTHaterCount() >= Config:GetSetting('BurnMobCount')
                end,
            },
            {
                name = "shieldhit",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and not Casting.TargetHasBuffByName('Sarnak Finesse')
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and
                        Targeting.GetTargetDistance() < Targeting.GetTargetMaxRangeTo() and mq.TLO.Me.Inventory("offhand").Type() == "Shield"
                end,
            },
            {
                name = "Kick",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and
                        Targeting.GetTargetDistance() < Targeting.GetTargetMaxRangeTo()
                end,
            },
            {
                name = "Knee Strike",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.TargetedAAReady(aaName) and
                        Targeting.GetTargetDistance() < Targeting.GetTargetMaxRangeTo()
                end,
            },
            {
                name = "Gut Punch",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.TargetedAAReady(aaName) and
                        Targeting.GetTargetDistance() < Targeting.GetTargetMaxRangeTo()
                end,
            },
            {
                name = "Call of Challenge",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoSnare') and
                        Casting.TargetedAAReady(aaName) and
                        Targeting.GetTargetDistance() < Targeting.GetTargetMaxRangeTo()
                end,
            },
            {
                name = "Disarm",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and
                        Targeting.GetTargetDistance() < 15
                end,
            },
            {
                name = "StrikeDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and
                        Targeting.GetTargetDistance() < Targeting.GetTargetMaxRangeTo() and
                        Targeting.GetTargetPctHPs() <= 20
                end,
            },
        },
        ['Warrior Buffs'] = {
            {
                name = "groupac",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.SongActive(discSpell)
                end,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and not Casting.SongActive(discSpell)
                end,
            },
            {
                name = "groupdodge",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.SongActive(discSpell)
                end,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and not Casting.SongActive(discSpell)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "defenseac",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return mq.TLO.Me.ActiveDisc.ID() == discSpell.ID()
                end,
                cond = function(self, discSpell)
                    return not mq.TLO.Me.ActiveDisc.ID() and Casting.DiscReady(discSpell)
                end,
            },
            {
                name = "waraura",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.AuraActiveByName(discSpell.RankName.Name())
                end,
                cond = function(self, discSpell)
                    return not mq.TLO.Me.Aura(1).ID() and mq.TLO.Me.CombatAbility(discSpell.RankName.Name())() and mq.TLO.Me.PctEndurance() > 10
                end,
            },
            {
                name = "endregen",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.SongActive(discSpell)
                end,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() < 15 and not Casting.SongActive(discSpell)
                end,
            },
            {
                name = "Huntsman's Ethereal Quiver",
                type = "Item",
                active_cond = function(self) return mq.TLO.FindItemCount("Ethereal Arrow")() > 100 end,
                cond = function(self)
                    return Config:GetSetting('SummonArrows') and mq.TLO.Me.Level() > 89 and mq.TLO.FindItemCount("Ethereal Arrow")() < 101 and
                        mq.TLO.Me.ItemReady("Huntsman's Ethereal Quiver")()
                end,
            },
        },
    },

    ['DefaultConfig']   = {
        ['Mode']         = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes Do?",
            Answer = "Tank Mode is for when you are the main tank. DPS Mode is for when you are not the main tank and want to focus on damage.",
        },
        ['SummonArrows'] = {
            DisplayName = "Use Huntsman's Quiver",
            Category = "Equipment",
            Tooltip = "Summon arrows with your Huntsman's Ethereal Quiver (Level 90+)",
            Default = false,
            FAQ = "How do I summon arrows?",
            Answer = "If you are at least level 90, keep a Huntsman's Ethereal Quiver in your inventory and enable its use in the options.",
        },
        ['DoAEAgro']     = {
            DisplayName = "Do AE Agro",
            Category = "Combat",
            Tooltip = "Enable AoE Agro (Tank Mode Only)",
            Default = true,
            FAQ = "How do use AOE Agro abilities?",
            Answer = "Enable [DoAEAgro] in the settings and you will use AOE Agro abilities when you have enough mobs TANK MODE ONLY.",
        },
        ['DoAEHate']     = {
            DisplayName = "Do AE Hate",
            Category = "Combat",
            Tooltip = "Enable AoE Hate (Tank Mode Only)",
            Default = true,
            FAQ = "How do use AOE Hate abilities?",
            Answer = "Enable [DoAEHate] in the settings and you will use AOE Hate abilities when you have enough mobs TANK MODE ONLY.",
        },
        ['DoBandolier']  = {
            DisplayName = "Use Bandolier",
            Category = "Equipment",
            Tooltip = "Enable Swapping of items using the bandolier.",
            Default = false,
            FAQ = "How do I use Bandolier?",
            Answer = "Enable [DoBandolier] in the settings and you will swap items using the bandolier.",
        },
        ['DoChestClick'] = {
            DisplayName = "Do Chest Click",
            Category = "Equipment",
            Tooltip = "Click your chest item",
            Default = true,
            FAQ = "How do I use my chest item?",
            Answer = "Enable [DoChestClick] in the settings and you will click your chest item.",
        },
        ['DoDefense']    = {
            DisplayName = "Do Defense",
            Category = "Combat",
            Tooltip = "Do Defense",
            Default = true,
            FAQ = "How do I use Defense abilities?",
            Answer = "Enable [DoDefense] in the settings and you will use Defense abilities.",
        },
        ['DoBattleLeap'] = {
            DisplayName = "Do Battle Leap",
            Category = "Combat",
            Tooltip = "Do Battle Leap",
            Default = true,
            FAQ = "How do I use Battle Leap?",
            Answer = "Enable [DoBattleLeap] in the settings and you will use Battle Leap.",
        },
        ['DoSnare']      = {
            DisplayName = "Use Snares",
            Category = "Combat",
            Tooltip = "Enable casting Snare abilities.",
            Default = true,
            FAQ = "How do I use Snares?",
            Answer = "Enable [DoSnare] in the settings and you will use Snares.",
        },
    },
}


return _ClassConfig
