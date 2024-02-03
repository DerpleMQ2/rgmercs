local mq           = require('mq')
local RGMercUtils  = require("utils.rgmercs_utils")

local _ClassConfig = {
    _version            = "0.1a",
    _author             = "Derple",
    ['CommandHandlers'] = {
        defdisc = {
            usage = "/rgl defdisc",
            about = "Uses best warrior melee mitigation disc",
            handler = function(self, ...)
                local discSpell = self:GetResolvedActionMapItem('meleemit')

                if discSpell and discSpell() and RGMercUtils.PCDiscReady(discSpell) then
                    if RGMercUtils.BuffActiveByName('Night\'s Endless Terror') then
                        RGMercUtils.DoCmd('/docommand /removebuff "Night\'s Endless Terror"')
                        mq.delay(5)
                    end
                    RGMercUtils.UseDisc(discSpell, RGMercUtils.GetTargetID())
                else
                    RGMercsLogger.log_error("\ar COOL DOWN \ag >> \aw meleemit \ag << ")
                end
                return true
            end,
        },

        evadedisc = {
            usage = "/rgl evadedisc",
            about = "Uses best warrior evasion disc",
            handler = function(self, ...)
                local discSpell = self:GetResolvedActionMapItem('missall')

                if discSpell and discSpell() and RGMercUtils.PCDiscReady(discSpell) then
                    RGMercUtils.UseDisc(discSpell, RGMercUtils.GetTargetID())
                else
                    RGMercsLogger.log_error("\ar COOL DOWN \ag >> \aw missall \ag << ")
                end
                return true
            end,
        },
    },
    ['ModeChecks']      = {
        IsTanking = function() return RGMercUtils.IsModeActive("Tank") end,
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
                    RGMercUtils.DoBuffCheck()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.BurnCheck() and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
    },
    ['Rotations']       = {
        ['Burn'] = {
            {
                name = "meleemit",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and string.find(mq.TLO.Me.ActiveDisc.Name() or "", "Defense") and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "parryall",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and string.find(mq.TLO.Me.ActiveDisc.Name() or "", "Defense") and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "missall",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and string.find(mq.TLO.Me.ActiveDisc.Name() or "", "Defense") and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "bmdisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.PctEndurance() > 20 and
                        not RGMercUtils.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "Brace for Impact",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCAAReady(aaName)
                end,
            },
            {
                name = "Imperator's Command",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCAAReady(aaName)
                end,
            },
            {
                name = "aehealhate",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.PctEndurance() > 10 and
                        not RGMercUtils.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "aeselfbuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.PctEndurance() > 10 and not RGMercUtils.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "Warlord's Bravery",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.PCAAReady(aaName)
                end,
            },
            {
                name = "Warlord's Tenacity",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.PCAAReady(aaName)
                end,
            },
            {
                name = "Warlord's Resurgence",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.PCAAReady(aaName)
                end,
            },
            {
                name = "Warlord's Fury",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.NPCAAReady(aaName)
                end,
            },
            {
                name = "War Sheol's Heroic Blade",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.NPCAAReady(aaName)
                end,
            },

        },
        ['DPS'] = {
            {
                name = "aeroar",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and RGMercUtils.GetXTHaterCount() >= RGMercUtils.GetSetting('BurnMobCount') and
                        RGMercUtils.GetSetting('DoAEAgro')
                end,
            },
            {
                name = "aehitall",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and RGMercUtils.GetXTHaterCount() >= RGMercUtils.GetSetting('BurnMobCount') and
                        RGMercUtils.GetSetting('DoAEAgro')
                end,
            },
            {
                name = "Area Taunt",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.NPCAAReady(aaName) and RGMercUtils.GetXTHaterCount() >= RGMercUtils.GetSetting('BurnMobCount') and
                        RGMercUtils.GetSetting('DoAEAgro')
                end,
            },
            {
                name = "endregen",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.PctEndurance() < 15 and
                        not RGMercUtils.SongActive(discSpell.BaseName())
                end,
            },
            {
                name = "ActivateShield",
                type = "CustomFunc",
                cond = function(self)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.GetSetting('DoBandolier') and not mq.TLO.Me.Bandolier("Shield").Active() and
                        mq.TLO.Me.Bandolier("Shield").Index() and RGMercUtils.BurnCheck()
                end,
                custom_func = function(_)
                    RGMercUtils.DoCmd("/bandolier activate Shield")
                    return true
                end,

            },
            {
                name = "ActivateAgro",
                type = "CustomFunc",
                cond = function(self)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.GetSetting('DoBandolier') and not mq.TLO.Me.Bandolier("Agro").Active() and
                        mq.TLO.Me.Bandolier("Agro").Index() and RGMercUtils.GetXTHaterCount() < RGMercUtils.GetSetting('BurnMobCount') and not RGMercUtils.IsNamed(mq.TLO.Target)
                end,
                custom_func = function(_)
                    RGMercUtils.DoCmd("/bandolier activate Agro")
                    return true
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                cond = function(self, abilityName)
                    return RGMercUtils.IsModeActive("Tank") and mq.TLO.Me.AbilityReady(abilityName)() and
                        mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and RGMercUtils.GetTargetDistance() < 30
                end,
            },
            {
                name = "AgroLock",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and
                        RGMercUtils.GetTargetDistance() < 30
                end,
            },
            {
                name = "Taunt1",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and
                        RGMercUtils.GetTargetDistance() < 30
                end,
            },
            {
                name = "Blast of Anger",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.NPCAAReady(aaName) and mq.TLO.Me.SecondaryPctAggro() > 70 and RGMercUtils.GetTargetDistance() < 80
                end,
            },
            {
                name = "AddHate1",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and RGMercUtils.DetSpellCheck(discSpell)
                end,
            },
            {
                name = "AddHate2",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.SecondaryPctAggro() > 70 and mq.TLO.Me.CurrentEndurance() > 500 and
                        RGMercUtils.GetTargetDistance() < discSpell.Range()
                end,
            },
            {
                name = "aehealhate",
                type = "Disc",
                cond = function(self, discSpell)
                    local stHate = self:GetResolvedActionMapItem('singlehealhate')
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.GetSetting('DoAEHate') and RGMercUtils.PCDiscReady(discSpell) and
                        not RGMercUtils.BuffActiveByID(discSpell.ID()) and (stHate and not RGMercUtils.BuffActiveByID(stHate.ID()))
                end,
            },
            {
                name = "singlehealhate",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and
                        not RGMercUtils.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "absorball",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.PctHPs() < 30
                end,
            },
            {
                name = "defenseac",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCDiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.GetSetting('DoChestClick') and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
            {
                name = "Brace for Impact",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCAAReady(aaName) and not RGMercUtils.BuffActiveByName(aaName) and RGMercUtils.GetSetting('DoBuffs') and
                        not RGMercUtils.GetSetting('DoDefense')
                end,
            },
            {
                name = "Blade Guardian",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.PCAAReady(aaName) and not RGMercUtils.SongActive(aaName) and RGMercUtils.GetSetting('DoBuffs') and
                        not RGMercUtils.GetSetting('DoDefense')
                end,
            },
            {
                name = "Battle Leap",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Tank") and RGMercUtils.NPCAAReady(aaName) and not RGMercUtils.SongActive(aaName)
                        and not RGMercUtils.SongActive('Group Bestial Alignment') and RGMercUtils.GetTargetMaxRangeTo() >= RGMercUtils.GetTargetDistance() and
                        RGMercUtils.GetSetting('DoBuffs') and
                        RGMercUtils.GetSetting('DoBattleLeap')
                end,
            },
            {
                name = "Rampage",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoAEAgro') and RGMercUtils.GetXTHaterCount() >= RGMercUtils.GetSetting('BurnMobCount')
                end,
            },
            {
                name = "shieldhit",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and not RGMercUtils.TargetHasBuffByName('Sarnak Finesse')
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and
                        RGMercUtils.GetTargetDistance() < RGMercUtils.GetTargetMaxRangeTo() and mq.TLO.Me.Inventory("offhand").Type() == "Shield"
                end,
            },
            {
                name = "Kick",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and
                        RGMercUtils.GetTargetDistance() < RGMercUtils.GetTargetMaxRangeTo()
                end,
            },
            {
                name = "Knee Strike",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.NPCAAReady(aaName) and
                        RGMercUtils.GetTargetDistance() < RGMercUtils.GetTargetMaxRangeTo()
                end,
            },
            {
                name = "Gut Punch",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.NPCAAReady(aaName) and
                        RGMercUtils.GetTargetDistance() < RGMercUtils.GetTargetMaxRangeTo()
                end,
            },
            {
                name = "Call of Challenge",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoSnare') and
                        RGMercUtils.NPCAAReady(aaName) and
                        RGMercUtils.GetTargetDistance() < RGMercUtils.GetTargetMaxRangeTo()
                end,
            },
            {
                name = "Disarm",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and
                        RGMercUtils.GetTargetDistance() < RGMercUtils.GetTargetMaxRangeTo()
                end,
            },
            {
                name = "StrikeDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and
                        RGMercUtils.GetTargetDistance() < RGMercUtils.GetTargetMaxRangeTo() and
                        RGMercUtils.GetTargetPctHPs() <= 20
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
                    return not mq.TLO.Me.ActiveDisc.ID() and RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "waraura",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return RGMercUtils.AuraActiveByName(discSpell.RankName.Name())
                end,
                cond = function(self, discSpell)
                    return not mq.TLO.Me.Aura(1).ID() and mq.TLO.Me.CombatAbility(discSpell.RankName.Name())() and mq.TLO.Me.PctEndurance() > 10
                end,
            },
            {
                name = "groupac",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return RGMercUtils.SongActive(discSpell.BaseName())
                end,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and not RGMercUtils.SongActive(discSpell.BaseName())
                end,
            },
            {
                name = "groupdodge",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return RGMercUtils.SongActive(discSpell.BaseName())
                end,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and not RGMercUtils.SongActive(discSpell.BaseName())
                end,
            },
            {
                name = "endregen",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return RGMercUtils.SongActive(discSpell.BaseName())
                end,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.PctEndurance() < 15 and not RGMercUtils.SongActive(discSpell.BaseName())
                end,
            },
            {
                name = "Huntsman's Ethereal Quiver",
                type = "Item",
                active_cond = function(self) return mq.TLO.FindItemCount("Ethereal Arrow")() > 1 end,
                cond = function(self)
                    return RGMercUtils.GetSetting('SummonArrows') and mq.TLO.FindItemCount("Ethereal Arrow")() < 1 and mq.TLO.Me.ItemReady("Huntsman's Ethereal Quiver")()
                end,
            },
        },
    },

    ['DefaultConfig']   = {
        ['Mode']         = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 2, },
        ['SummonArrows'] = { DisplayName = "Summon Arrows", Category = "Utilities", Tooltip = "Enable Summon Arrows", Default = true, },
        ['DoAEAgro']     = { DisplayName = "Do AE Agro", Category = "Combat", Tooltip = "Enable AoE Agro (Tank Mode Only)", Default = true, },
        ['DoAEHate']     = { DisplayName = "Do AE Hate", Category = "Combat", Tooltip = "Enable AoE Hate (Tank Mode Only)", Default = true, },
        ['DoBandolier']  = { DisplayName = "Use Bandolier", Category = "Equipment", Tooltip = "Enable Swapping of items using the bandolier.", Default = false, },
        ['DoChestClick'] = { DisplayName = "Do Check Click", Category = "Utilities", Tooltip = "Click your chest item", Default = true, },
        ['DoDefense']    = { DisplayName = "Do Defense", Category = "Combat", Tooltip = "Do Defense", Default = true, },
        ['DoBattleLeap'] = { DisplayName = "Do Battle Leap", Category = "Combat", Tooltip = "Do Battle Leap", Default = true, },
        ['DoSnare']      = { DisplayName = "Use Snares", Category = "Combat", Tooltip = "Enable casting Snare abilities.", Default = true, },
    },
}


return _ClassConfig
