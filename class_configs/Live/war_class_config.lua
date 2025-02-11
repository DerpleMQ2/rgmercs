local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.Targeting")
local Casting      = require("utils.casting")
local ItemManager  = require("utils.item_manager")
local Logger       = require("utils.logger")

local _ClassConfig = {
    _version            = "1.3 - Live",
    _author             = "Algar, Derple",
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
        ['OoW_Chest'] = {
            "Armsmaster's Breastplate",
            "Gladiator's Plate Chestguard of War",
        },
        ['Coating'] = {
            "Spirit Drinker's Coating",
            "Blood Drinker's Coating",
        },
    },
    ['AbilitySets']     = {
        ['StandDisc'] = {
            "Climactic Stand",
            "Resolute Stand",
            "Ultimate Stand Discipline",
            "Culminating Stand Discipline",
            "Last Stand Discipline",
            "Final Stand Discipline",
            --[] = "Stonewall Discipline",
            "Defensive Discipline",
        },
        ['Fortitude'] = {
            "Fortitude Discipline",
        },
        ['AbsorbDisc'] = {
            "Finish the Fight",
            "Pain Doesn't Hurt",
            "No Time to Bleed",
        },
        ['Flash'] = {
            "Flash of Anger",
        },
        ['ShieldHit'] = {
            "Shield Sunder",
            "Shield Break",
            "Shield Topple",
            "Shield Splinter",
            "Shield Rupture",
            "Shield Split",
        },
        ['GroupACBuff'] = {
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
        ['GroupDodgeBuff'] = {
            "Commanding Voice",
        },
        ['DefenseACBuff'] = {
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
        ['DichoShield'] = {
            "Reciprocal Shield",
            "Ecliptic Shield",
            "Composite Shield",
            "Dissident Shield",
            "Dichotomic Shield",
        },
        ['AERoar'] = { --does not appear to be worthwhile, very limited level range and low hate value
            "Roar of Challenge",
            "Rallying Roar",
        },
        ['SelfBuffAE'] = {
            "Wade into Battle",
            "Wade into Conflict",
        },
        ['SelfBuffSingle'] = {
            "Determined Reprisal",
        },
        ['HealHateAE'] = {
            "Paradoxical Expanse",
            "Penumbral Expanse",
            "Confluent Expanse",
            "Concordant Expanse",
            "Harmonious Expanse",
        },
        ['HealHateSingle'] = {
            "Paradoxical Precision",
            "Penumbral Precision",
            "Confluent Precision",
            "Concordant Precision",
            "Harmonious Precision",
        },
        ['AEBlades'] = {
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
        ['AbsorbTaunt'] = {
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
        ['EndRegen'] = {
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
        ['AuraBuff'] = {
            "Champion's Aura",
            "Myrmidon's Aura",
        },
        ['Attention'] = {
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
        ['Onslaught'] = {
            "Savage Onslaught Discipline",
            "Brutal Onslaught Discipline",
            "Brightfeld's Onslaught Discipline",
        },
        ['RuneShield'] = {
            "Warrior's Auspice",
            "Warrior's Bulwark",
            "Warrior's Bastion",
            "Warrior's Rampart",
            "Warrior's Aegis",
            "Warrior's Resolve",
        },
        ['TongueDisc'] = {
            "Razor Tongue Discipline",
            "Biting Tongue Discipline",
            "Barbed Tongue Discipline",
        },
        ['ChargeDisc'] = {
            "Charge Discipline",
        },
        ['OffensiveDisc'] = {
            "Offensive Discipline",
        },
        ['MightyStrike'] = {
            "Mighty Strike Discipline",
        },
    },
    ['HelperFunctions'] = {
        --function to determine if we should AE taunt and optionally, if it is safe to do so
        AETauntCheck = function(printDebug)
            local mobs = mq.TLO.SpawnCount("NPC radius 50 zradius 50")()
            local xtCount = mq.TLO.Me.XTarget() or 0

            if (mobs or xtCount) < Config:GetSetting('AETauntCnt') then return false end

            local tauntme = {}
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater")) and xtarg.PctAggro() < 100 and (xtarg.Distance() or 999) <= 50 then
                    if printDebug then
                        Logger.log_verbose("AETauntCheck(): XT(%d) Counting %s(%d) as a hater eligible to AE Taunt.", i, xtarg.CleanName() or "None",
                            xtarg.ID())
                    end
                    table.insert(tauntme, xtarg.ID())
                end
            end
            return #tauntme > 0 and not (Config:GetSetting('SafeAETaunt') and #tauntme < mobs)
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
        --function to determine if we have enough mobs in range to use a defensive disc
        DefensiveDiscCheck = function(printDebug)
            local xtCount = mq.TLO.Me.XTarget() or 0
            if xtCount < Config:GetSetting('DiscCount') then return false end
            local haters = {}
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater")) and (xtarg.Distance() or 999) <= 30 then
                    if printDebug then
                        Logger.log_verbose("DefensiveDiscCheck(): XT(%d) Counting %s(%d) as a hater in range.", i, xtarg.CleanName() or "None", xtarg.ID())
                    end
                    table.insert(haters, xtarg.ID())
                end
            end
            return #haters >= Config:GetSetting('DiscCount')
        end,
        DiscOverwriteCheck = function(self)
            local defenseBuff = Core.GetResolvedActionMapItem('DefenseACBuff')
            if mq.TLO.Me.ActiveDisc.ID() and mq.TLO.Me.ActiveDisc.Name() ~= defenseBuff.RankName() then return false end
            return true
        end,
        BurnDiscCheck = function(self)
            if mq.TLO.Me.ActiveDisc.Name() == "Fortitude Discipline" or mq.TLO.Me.PctHPs() < Config:GetSetting('EmergencyStart') then return false end
            local burnDisc = { "Onslaught", "MightyStrike", "ChargeDisc", "OffensiveDisc", }
            for _, buffName in ipairs(burnDisc) do
                local resolvedDisc = self:GetResolvedActionMapItem(buffName)
                if resolvedDisc and resolvedDisc.RankName() == mq.TLO.Me.ActiveDisc.Name() then return false end
            end
            return true
        end,
    },
    ['RotationOrder']   = {
        { --Self Buffs
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.DoBuffCheck() and Casting.AmIBuffable()
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'HateTools',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsTanking() end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --Defensive actions triggered by low HP
            name = 'EmergencyDefenses',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
            end,
        },
        { --Dynamic weapon swapping if UseBandolier is toggled
            name = 'Weapon Management',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('UseBandolier') end,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        { --Defensive actions used proactively to prevent emergencies
            name = 'Defenses',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                --need to look at rotation and decide if it should fire during emergencies. leaning towards no
                return combat_state == "Combat" and Core.IsTanking() and (mq.TLO.Me.PctHPs() < Config:GetSetting('EmergencyStart') or
                    Targeting.IsNamed(mq.TLO.Target) or self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true))
            end,
        },
        { --Offensive actions to temporarily boost damage dealt
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --DPS and Utility discs
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
    },
    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "AuraBuff",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.AuraActiveByName(discSpell.RankName.Name())
                end,
                cond = function(self, discSpell)
                    return not mq.TLO.Me.Aura(1).ID() and Casting.DiscReady(discSpell)
                end,
            },
            {
                name = "GroupACBuff",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.SongActive(discSpell)
                end,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and not Casting.SongActive(discSpell)
                end,
            },
            {
                name = "GroupDodgeBuff",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.SongActive(discSpell)
                end,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and not Casting.SongActive(discSpell)
                end,
            },
            {
                name = "DefenseACBuff",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return mq.TLO.Me.ActiveDisc.ID() == discSpell.ID()
                end,
                cond = function(self, discSpell)
                    return Core.IsTanking() and not mq.TLO.Me.ActiveDisc.ID() and Casting.DiscReady(discSpell)
                end,
            },
            {
                name = "Brace for Impact",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "HealHateAE",
                type = "Disc",
                cond = function(self, discSpell)
                    if not Config:GetSetting('DoAETaunt') or Config:GetSetting('SafeAETaunt') then return false end
                    return Core.IsTanking() and Casting.DiscReady(discSpell) and not Casting.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "HealHateSingle",
                type = "Disc",
                cond = function(self, discSpell)
                    if Config:GetSetting('DoAETaunt') and not Config:GetSetting('SafeAETaunt') then return false end
                    return Core.IsTanking() and Casting.DiscReady(discSpell) and not Casting.BuffActiveByID(discSpell.ID())
                end,
            },
            {
                name = "Blade Guardian",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName) and not Casting.SongActiveByName(aaName)
                end,
            },
            {
                name_func = function() return mq.TLO.Me.Inventory("Charm").Name() or "None" end,
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Charm")
                    return item() and Casting.TargetHasBuff(item.Spell, mq.TLO.Me)
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Charm")
                    return Config:GetSetting('DoCharmClick') and item() and Casting.SelfBuffCheck(item.Spell) and item.TimerReady() == 0
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
        ['HateTools'] = {
            --used when we've lost hatred after it is initially established
            {
                name = "Ageless Enmity",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID()) and Targeting.GetTargetPctHPs() < 90 and mq.TLO.Me.PctAggro() < 100
                end,
            },
            --used to jumpstart hatred on named from the outset and prevent early rips from burns
            {
                name = "Attention",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell) and Targeting.IsNamed(mq.TLO.Target)
                end,
            },
            --used to reinforce hatred after it is initially established
            {
                name = "Blast of Anger",
                type = "AA",
                cond = function(self, aaName, target)
                    ---@diagnostic disable-next-line: undefined-field
                    return Casting.TargetedAAReady(aaName, target.ID()) and Targeting.GetTargetPctHPs() < 90 and (mq.TLO.Target.SecondaryPctAggro() or 0) > 70
                end,
            },
            {
                name = "Area Taunt",
                type = "AA",
                cond = function(self, aaName, target)
                    --if not Config:GetSetting('AETauntAA') then return false end
                    return Casting.TargetedAAReady(aaName, target.ID()) and self.ClassConfig.HelperFunctions.AETauntCheck(true)
                end,
            },
            {
                name = "Projection of Fury",
                type = "AA",
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return Casting.AAReady(aaName) and Targeting.IsNamed(mq.TLO.Target) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 80
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and Targeting.GetTargetID() > 0 and
                        Targeting.GetTargetDistance() < 30
                end,
            },
            {
                name = "AbsorbTaunt",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell)
                end,
            },
            {
                name = "AEBlades",
                type = "Disc",
                cond = function(self, discSpell)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return Casting.TargetedDiscReady(discSpell) and self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            {
                name = "AddHate1",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell) and Casting.DetSpellCheck(discSpell)
                end,
            },
            {
                name = "AddHate2",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell)
                end,
            },
            {
                name = "AgroPet",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell) and Targeting.IsNamed(mq.TLO.Target)
                end,
            },
            -- { --this appears to have incredibly limited usage and the line was discontinued
            --     name = "AERoar",
            --     type = "Disc",
            --     cond = function(self, discSpell)
            --         return Core.IsModeActive("Tank") and Casting.DiscReady(discSpell) and Targeting.GetXTHaterCount() >= Config:GetSetting('BurnMobCount') and
            --             Config:GetSetting('DoAEAgro')
            --     end,
            -- },
        },
        ['EmergencyDefenses'] = {
            --Note that in Tank Mode, defensive discs are preemptively cycled on named in the (non-emergency) Defenses rotation
            --Abilities should be placed in order of lowest to highest triggered HP thresholds
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and mq.TLO.Me.PctHPs() < 25 and Config:GetSetting('DoVetAA')
                end,
            },
            {
                name = "Fortitude",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyLockout') and Casting.DiscReady(discSpell) and
                        not Casting.SongActiveByName("Flash of Anger") and not Casting.BuffActiveByID(mq.TLO.AltAbility("Blade Guardian").Spell.Base(1)())
                end,
            },
            {
                name = "Flash",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.Name() ~= "Fortitude Discipline" and
                        not Casting.BuffActiveByID(mq.TLO.AltAbility("Blade Guardian").Spell.Base(1)())
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
                name = "RuneShield",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell)
                end,
            },
            {
                name = "Mark of the Mage Hunter",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            { --here for use in emergencies regarldless of ability staggering below
                name = "StandDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsTanking() and Casting.DiscReady(discSpell) and self.ClassConfig.HelperFunctions.DiscOverwriteCheck(self)
                end,
            },
        },
        ['Weapon Management'] = {
            {
                name = "Equip Shield",
                type = "CustomFunc",
                active_cond = function(self, target)
                    return mq.TLO.Me.Bandolier("Shield").Active()
                end,
                cond = function(self)
                    if mq.TLO.Me.Bandolier("Shield").Active() then return false end
                    return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EquipShield')) or (Targeting.IsNamed(mq.TLO.Target) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("Shield") end,
            },
            {
                name = "Equip DW",
                type = "CustomFunc",
                active_cond = function(self, target)
                    return mq.TLO.Me.Bandolier("DW").Active()
                end,
                cond = function(self)
                    if mq.TLO.Me.Bandolier("DW").Active() then return false end
                    return mq.TLO.Me.PctHPs() >= Config:GetSetting('EquipDW') and not (Targeting.IsNamed(mq.TLO.Target) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("DW") end,
            },
        },
        ['Defenses'] = {
            --helper function(s) for ability stacking checks may reduce code, but this is functional.
            { --shares effect with modern chest click
                name = "DichoShield",
                type = "Disc",
                cond = function(self, discSpell)
                    local itemSpell = mq.TLO.Me.Inventory("Chest").Spell()
                    return Casting.DiscReady(discSpell) and not (itemSpell and mq.TLO.Me.Buff(itemSpell)())
                end,
            },
            { --shares effect with Dicho Shield
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    if not Config:GetSetting('DoChestClick') then return false end
                    local item = mq.TLO.Me.Inventory("Chest")
                    local dichoShield = Core.GetResolvedActionMapItem('DichoShield')
                    return item() and item.TimerReady() == 0 and Casting.SpellStacksOnMe(item.Spell) and not mq.TLO.Me.Buff(dichoShield)
                end,
            },
            { --shares effect with OoW Chest and Warlord's Bravery, offset from AbsorbDisc for automation flow/coverage
                name = "StandDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local absorbDisc = Core.GetResolvedActionMapItem('AbsorbDisc')
                    return Casting.DiscReady(discSpell) and not mq.TLO.Me.Song(absorbDisc)() and self.ClassConfig.HelperFunctions.DiscOverwriteCheck(self)
                end,
            },
            { --offset from StandDisc for automation flow/coverage
                name = "AbsorbDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local standDisc = self:GetResolvedActionMapItem('StandDisc')
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.ActiveDisc.Name() ~= standDisc.RankName()
                end,
            },
            { --shares effect with StandDisc and Warlord's Bravery, offset from AbsorbDisc for automation flow/coverage
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, itemName)
                    local absorbDisc = Core.GetResolvedActionMapItem('AbsorbDisc')
                    local standDisc = Core.GetResolvedActionMapItem('StandDisc')
                    return mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0 and mq.TLO.Me.ActiveDisc.Name() ~= standDisc.RankName() and
                        not mq.TLO.Me.Song(absorbDisc)()
                end,
            },
            { --See above entries for notes
                name = "Warlord's Bravery",
                type = "AA",
                cond = function(self, aaName)
                    local absorbDisc = Core.GetResolvedActionMapItem('AbsorbDisc')
                    local standDisc = Core.GetResolvedActionMapItem('StandDisc')
                    return Casting.AAReady(aaName) and mq.TLO.Me.ActiveDisc.Name() ~= standDisc.RankName() and
                        mq.TLO.Me.Song(absorbDisc)() and not Casting.BuffActiveByName("Guardian's Boon") and
                        not Casting.BuffActiveByName("Guardian's Bravery")
                end,
            },
            {
                name = "Coating",
                type = "Item",
                cond = function(self, itemName)
                    if not Config:GetSetting('DoCoating') then return false end
                    local item = mq.TLO.FindItem(itemName)
                    return item() and item.TimerReady() == 0 and Casting.SelfBuffCheck(item.Spell)
                end,
            },
            { --incredibly weak at high level, but low opportunity cost for use and optional
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if not Config:GetSetting('DoEpic') then return false end
                    return mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Spire of the Warlord",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Imperator's Command",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Onslaught",
                type = "Disc",
                cond = function(self, discSpell)
                    return not Core.IsTanking() and Casting.DiscReady(discSpell) and self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            {
                name = "MightyStrike",
                type = "Disc",
                cond = function(self, discSpell)
                    return not Core.IsTanking() and Casting.DiscReady(discSpell) and self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            {
                name = "OffensiveDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return not Core.IsTanking() and Casting.DiscReady(discSpell) and self.ClassConfig.HelperFunctions.BurnDiscCheck(self)
                end,
            },
            {
                name = "Vehement Rage",
                type = "AA",
                cond = function(self, aaName)
                    return not Core.IsTanking() and Casting.AAReady(aaName)
                end,
            },
            {
                name = "Rage of Rallos Zek",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Warlord's Fury",
                type = "AA",
                cond = function(self, aaName, target)
                    local dichoShield = Core.GetResolvedActionMapItem('DichoShield')
                    return Core.IsTanking() and Casting.TargetedAAReady(aaName, target.ID()) and not mq.TLO.Me.Buff(dichoShield)
                end,
            },
            {
                name = "War Sheol's Heroic Blade",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "SelfBuffAE",
                type = "Disc",
                cond = function(self, discSpell)
                    if not Config:GetSetting('DoAETaunt') or Config:GetSetting('SafeAETaunt') then return false end
                    return Core.IsTanking() and Casting.DiscReady(discSpell)
                end,
            },
            {
                name = "SelfBuffSingle",
                type = "Disc",
                cond = function(self, discSpell)
                    if Config:GetSetting('DoAETaunt') and not Config:GetSetting('SafeAETaunt') then return false end
                    return Core.IsTanking() and Casting.DiscReady(discSpell)
                end,
            },
            {
                name = "TongueDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Core.IsTanking() and Casting.DiscReady(discSpell)
                end,
            },
            {
                name = "Resplendent Glory",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsTanking() and Casting.AAReady(aaName)
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoVetAA') then return false end
                    return Casting.AAReady(aaName)
                end,
            },
        },
        ['Combat'] = {
            {
                name = "ShieldHit",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell)
                end,
            },
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Battle Leap",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoBattleLeap') then return false end
                    return Casting.TargetedAAReady(aaName, target.ID())
                        ---@diagnostic disable-next-line: undefined-field --Defs are not updated with HeadWet
                        and not mq.TLO.Me.HeadWet() --Stops Leap from launching us above the water's surface
                end,
            },
            {
                name = "Gut Punch",
                type = "AA",
                cond = function(self, aaName, target)
                    return Core.IsTanking() and Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Knee Strike",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Rampage",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting("DoAEDamage") then return false end
                    return Casting.TargetedAAReady(aaName, target.ID()) and self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            {
                name = "Call of Challenge",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoSnare') then return false end
                    return Casting.TargetedAAReady(aaName, target.ID()) and Casting.DetSpellCheck(mq.TLO.Me.AltAbility(aaName).Spell)
                end,
            },
            {
                name = "Press the Attack",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting("DoPress") then return false end
                    return Core.IsTanking() and Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.AbilityReady(abilityName)() and Casting.AbilityRangeCheck(target) and Core.ShieldEquipped()
                end,
            },
            {
                name = "Slam",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.AbilityReady(abilityName)() and Casting.AbilityRangeCheck(target)
                end,
            },
            {
                name = "Kick",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.AbilityReady(abilityName)() and Casting.AbilityRangeCheck(target)
                end,
            },
            -- { --todo:homework
            --     name = "Disarm",
            --     type = "Ability",
            --     cond = function(self, abilityName)
            --         return mq.TLO.Me.AbilityReady(abilityName)() and
            --             Targeting.GetTargetDistance() < 15
            --     end,
            -- },
            {
                name = "StrikeDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell) and
                        Targeting.GetTargetDistance() < Targeting.GetTargetMaxRangeTo() and
                        Targeting.GetTargetPctHPs() <= 20
                end,
            },
            {
                name = "DefenseACBuff",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return mq.TLO.Me.ActiveDisc.ID() == discSpell.ID()
                end,
                cond = function(self, discSpell)
                    return Core.IsTanking() and not mq.TLO.Me.ActiveDisc.ID() and Casting.DiscReady(discSpell)
                end,
            },
        },
    },
    ['DefaultConfig']   = {
        ['Mode']             = {
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
        ['DoBattleLeap']     = {
            DisplayName = "Do Battle Leap",
            Category = "Abilities",
            Tooltip = "Do Battle Leap",
            Default = true,
            FAQ = "How do I use Battle Leap?",
            Answer = "Enable [DoBattleLeap] in the settings and you will use Battle Leap.",
        },
        ['DoPress']          = {
            DisplayName = "Do Press the Attack",
            Category = "Abilities",
            Tooltip = "Use the Press to Attack stun/push AA.",
            Default = false,
            FAQ = "Why isn't Press the Attack working?",
            Answer = "This ability must be turned on in the Abilities tab.",
        },
        ['DoSnare']          = {
            DisplayName = "Use Snares",
            Category = "Abilities",
            Tooltip = "Enable casting Snare abilities.",
            Default = true,
            FAQ = "How do I use Snares?",
            Answer = "Enable [DoSnare] in the settings and you will use Snares.",
        },
        ['DoVetAA']          = {
            DisplayName = "Use Vet AA",
            Category = "Abilities",
            Index = 8,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does WAR use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },
        ['DoAEDamage']       = {
            DisplayName = "Do AE Damage",
            Category = "Abilities",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Discs and AA. **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['AETargetCnt']      = {
            DisplayName = "AE Target Count",
            Category = "Abilities",
            Index = 2,
            Tooltip = "Minimum number of valid targets before using AE Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['MaxAETargetCnt']   = {
            DisplayName = "Max AE Targets",
            Category = "Damage Spells",
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
            Category = "Abilities",
            Index = 4,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },
        ['DoAETaunt']        = {
            DisplayName = "Do AE Taunts",
            Category = "Hate Tools",
            Index = 1,
            Tooltip = "Use AE hatred Discs and AA.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['AETauntCnt']       = {
            DisplayName = "AE Taunt Count",
            Category = "Hate Tools",
            Index = 2,
            Tooltip = "Minimum number of haters before using AE Taunt Discs or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why don't we use AE taunts on single targets?",
            Answer =
            "AE taunts are configured to only be used if a target has less than 100% hate on you, at whatever count you configure, so abilities with similar conditions may be used instead.",
        },
        ['SafeAETaunt']      = {
            DisplayName = "AE Taunt Safety Check",
            Category = "Hate Tools",
            Index = 3,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE taunts are used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Taunt Safety Check?",
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
        ['EmergencyStart']   = {
            DisplayName = "Emergency Start",
            Category = "Defenses",
            Index = 2,
            Tooltip = "Your HP % before we begin to use emergency abilities.",
            Default = 55,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "My WAR health spikes up and down a lot and abilities aren't being triggered, what gives?",
            Answer = "You may need to tailor the emergency thresholds to your current survivability and target choice.",
        },
        ['EmergencyLockout'] = {
            DisplayName = "Emergency Only",
            Category = "Defenses",
            Index = 3,
            Tooltip = "Your HP % before standard DPS rotations are cut in favor of emergency abilities.",
            Default = 35,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "What rotations are cut during Emergency Lockout?",
            Answer = "Hate Tools - death will cause a bigger issue with aggro. Defenses - we stop using preemptives and go for the oh*#$#.\n" ..
                "Debuffs, Weaves and other (non-LifeTap) DPS will also be cut.",
        },

        --Equipment
        ['DoChestClick']     = {
            DisplayName = "Do Chest Click",
            Category = "Equipment",
            Index = 1,
            Tooltip = "Click your equipped chest.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "What the heck is a chest click?",
            Answer = "Most classes have useful abilities on their equipped chest after level 75 or so. The WAR's is generally an absorbe rune for large hits.",
        },
        ['DoCharmClick']     = {
            DisplayName = "Do Charm Click",
            Category = "Equipment",
            Index = 2,
            Tooltip = "Click your charm for Geomantra.",
            Default = false,
            FAQ = "Why is my Warrior not clicking his charm?",
            Answer = "Charm clicks won't happen if you are in combat.",
        },
        ['DoCoating']        = {
            DisplayName = "Use Coating",
            Category = "Equipment",
            Index = 3,
            Tooltip = "Click your Blood/Spirit Drinker's Coating when defenses are triggered.",
            Default = false,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },
        ['UseBandolier']     = {
            DisplayName = "Dynamic Weapon Swap",
            Category = "Equipment",
            Index = 4,
            Tooltip = "Enable 1H+S/2H swapping based off of current health. ***YOU MUST HAVE BANDOLIER ENTRIES NAMED \"Shield\" and \"DW\" TO USE THIS FUNCTION.***",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Warrior not using Dynamic Weapon Swapping?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"DW\" to use this function.",
        },
        ['EquipShield']      = {
            DisplayName = "Equip Shield",
            Category = "Equipment",
            Index = 5,
            Tooltip = "Under this HP%, you will swap to your \"Shield\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Warrior not using a shield?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"DW\" to use this function.",
        },
        ['EquipDW']          = {
            DisplayName = "Equip DW",
            Category = "Equipment",
            Index = 6,
            Tooltip = "Over this HP%, you will swap to your \"DW\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 75,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Warrior not using DW?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"DW\" to use this function.",
        },
        ['NamedShieldLock']  = {
            DisplayName = "Shield on Named",
            Category = "Equipment",
            Index = 7,
            Tooltip = "Keep Shield equipped for Named mobs(must be in SpawnMaster or named.lua)",
            Default = true,
            FAQ = "Why does my WAR switch to a Shield on puny gray named?",
            Answer = "The Shield on Named option doesn't check levels, so feel free to disable this setting (or Bandolier swapping entirely) if you are farming fodder.",
        },
        ['DoEpic']           = {
            DisplayName = "Do Epic",
            Category = "Equipment",
            Index = 8,
            Tooltip = "Click your Epic Weapon when defenses are triggered.",
            Default = false,
            FAQ = "How do I use my Epic Weapon?",
            Answer = "Enable Do Epic to click your Epic Weapon.",
        },
        ['SummonArrows']     = {
            DisplayName = "Use Huntsman's Quiver",
            Category = "Equipment",
            Index = 9,
            Tooltip = "Summon arrows with your Huntsman's Ethereal Quiver (Level 90+)",
            Default = false,
            FAQ = "How do I summon arrows?",
            Answer = "If you are at least level 90, keep a Huntsman's Ethereal Quiver in your inventory and enable its use in the options.",
        },
    },
}


return _ClassConfig
