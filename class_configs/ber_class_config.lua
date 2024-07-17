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
            "Vengeful Taelosian Blood Axe",
            "Raging Taelosian Alloy Axe",
        },
        ['Coat'] = {
            "Cohort's Warmonger Coat",
        },
    },
    ['AbilitySets']   = {
        ['EndRegen'] = {
            "Second Wind",
            "Third Wind",
            "Fourth Wind",
            "Respite",
            "Reprieve",
            "Rest",
            "Breather",
            "Hiatus",
            "Relax",
            "Night's Calming",
            "Convalesce",
        },
        ['BerAura'] = {
            "Aura of Rage",
            "Bloodlust Aura",
        },
        ['Dicho'] = {
            "Dichotomic Rage",
            "Dissident Rage",
            "Composite Rage",
            "Ecliptic Rage",

        },
        ['Dfrenzy'] = {
            "Eviscerating Frenzy",
            "Heightened Frenzy",
            "Oppressing Frenzy",
            "Overpowering Frenzy",
            "Overwhelming Frenzy",
            "Conquering Frenzy",
            "Vanquishing Frenzy",
            "Demolishing Frenzy",
            "Mangling Frenzy",
            "Vindicating Frenzy",
        },
        ['Dvolley'] = {
            "Rage Volley",
            "Destroyer's Volley",
            "Annihilator's Volley",
            "Decimator's Volley",
            "Eradicator's Volley",
            "Savage Volley",
            "Sundering Volley",
            "Brutal Volley",
            "Demolishing Volley",
            "Mangling Volley",
            "Vindicating Volley",
            "Pulverizing Volley",
            "Eviscerating Volley",
        },
        ['Daxethrow'] = {
            "Maiming Axe Throw",
            "Vigorous Axe Throw",
            "Energetic Axe Throw",
            "Spirited Axe Throw",
            "Brutal Axe Throw",
            "Demolishing Axe Throw",
            "Mangling Axe Throw",
            "Vindicating Axe Throw",
            "Rending Axe Throw",
        },
        ['Daxeof'] = {
            "Axe of Rallos",
            "Axe of Graster",
            "Axe of Illdaera",
            "Axe of Zurel",
            "Axe of the Aeons",
            "Axe of Empyr",
            "Axe of Derakor",
            "Axe of Xin Diabo",
            "Axe of Orrak",
        },
        ['Phantom'] = {
            "Phantom Assailant",
        },
        ['Alliance'] = {
            "Demolisher's,",
            "Mangler's Covenant",
            "Vindicator's Coalition",
            "Conqueror's Conjunction",

        },
        ['CheapShot'] = {
            "Slap in the Face",
            "Kick in the Teeth",
            "Punch in The Throat",
            "Kick in the Shins",
            "Sucker Punch",
            "Rabbit Punch",
            "Swift Punch",
        },
        ['AESlice'] = {
            "Arcblade",
            "Arcslice",
            "Arcsteel",
            "Arcslash",
            "Arcshear",
        },
        ['AEVicious'] = {
            "Vicious Spiral",
            "Vicious Cyclone",
            "Vicious Cycle",
            "Vicious Revolution",
            "Vicious Whirl",
        },
        ['FrenzyBoost'] = {
            "Augmented Frenzy",
            "Amplified Frenzy",
            "Bolstered Frenzy",
            "Magnified Frenzy",
            "Buttressed Frenzy",
            "Heightened Frenzy",
        },
        ['RageStrike'] = {
            "Roiling Rage",
            "Festering Rage",
            "Bubbling Rage",
            "Smoldering Rage",
            "Seething Rage",
            "Frothing Rage",
        },
        ['SharedBuff'] = {
            "Shared Barbarism",
            "Shared Bloodlust",
            "Shared Brutality",
            "Shared Savagery",
            "Shared Viciousness",
            "Shared Cruelty",
            "Shared Ruthlessness",
            "Shared Atavism",
            "Shared Violence",
        },
        ['PrimaryBurnDisc'] = {
            "Berserking Discipline",
            "Sundering Discipline",
            "Brutal Discipline",
        },
        ['CleavingDisc'] = {
            "Cleaving Rage Discipline",
            "Cleaving Anger Discipline",
            "Cleaving Acrimony Discipline",
        },
        ['FlurryDisc'] = {
            "Vengeful Flurry Discipline",
            "Avenging Flurry Discipline",
        },
        ['DisconDisc'] = {
            "Disconcerting Discipline",
        },
        ['ResolveDisc'] = {
            "Frenzied Resolve Discipline",
        },
        ['HHEBuff'] = {
            "Battle Cry",
            "War Cry",
            "Battle Cry of Dravel",
            "War Cry of Dravel",
            "Battle Cry of the Mastruq",
            "Ancient: Cry of Chaos",
        },
        ['CryDmg'] = {
            "Cry Havoc",
            "Cry Carnage",
        },
        ['AutoAxe1'] = {
            "Corroded Axe",
            "Blunt Axe",
            "Steel Axe",
            "Bearded Axe",
            "Mithril Axe",
            "Balanced War Axe",
            "Bonesplicer Axe",
            "Fleshtear Axe",
            "Cold Steel Cleaving Axe",
            "Mithril Bloodaxe",
            "Rage Axe",
            "Bloodseeker's Axe",
            "Battlerage Axe",
            "Deathfury Axe",
            "Tainted Axe of Hatred",
            "Axe of The Destroyer",
            "Axe of The Annihilator",
            "Axe of The Decimator",
            "Axe of The Eradicator",
            "Axe of The Savage",
            "Axe of the Sunderer",
            "Axe of The Brute",
            "Axe of The Demolisher",
            "Axe of The Mangler",
            "Axe of The Vindicator",
            "Axe of the Conqueror",
            "Axe of the Eviscerator",
        },
        ['AutoAxe2'] = {
            "Corroded Axe",
            "Blunt Axe",
            "Steel Axe",
            "Bearded Axe",
            "Mithril Axe",
            "Balanced War Axe",
            "Bonesplicer Axe",
            "Fleshtear Axe",
            "Cold Steel Cleaving Axe",
            "Mithril Bloodaxe",
            "Rage Axe",
            "Bloodseeker's Axe",
            "Battlerage Axe",
            "Deathfury Axe",
            "Tainted Axe of Hatred",
            "Axe of The Destroyer",
            "Axe of The Annihilator",
            "Axe of The Decimator",
            "Axe of The Eradicator",
            "Axe of The Savage",
            "Axe of the Sunderer",
            "Axe of The Brute",
            "Axe of The Demolisher",
            "Axe of The Mangler",
            "Axe of The Vindicator",
            "Axe of the Conqueror",
            "Axe of the Eviscerator",
        },
        ['DichoAxe'] = {
            "Axe of The Demolisher",
            "Axe of The Mangler",
            "Axe of the Conqueror",
        },
        ['Tendon'] = {
            "Tendon Slice",
            "Tendon Shred",
            "Tendon Cleave",
            "Tendon Sever",
            "Tendon Shear",
            "Tendon Lacerate",
            "Tendon Slash",
            "Tendon Gash",
            "Tendon Tear",
            "Tendon Rupture",
            "Tendon Rip",
        },
        ['SappingStrike'] = {
            "Sapping Strikes",
            "Shriveling Strikes",
        },
        ['ReflexDisc'] = {
            "Reflexive Retaliation",
            "Instinctive Retaliation",
        },
        ['RestFrenzy'] = {
            "Desperate Frenzy",
            "Blinding Frenzy",
            "Restless Frenzy",

        },
        ['RetaliationDodge'] = {
            "Preemptive Retaliation",
            "Primed Retaliation",
            "Premature Retaltion",
            "Proactive Retaliation",
            "Prior Retaliation",
            "Advanced Retaliation",
            "Early Retaliation",
        },
        ['TempleStun'] = {
            "Temple Shatter",
            "Temple Bash",
            "Temple Blow",
            "Temple Chop",
            "Temple Crack",
            "Temple Crush",
            "Temple Demolish",
            "Temple Shatter",
            "Temple Slam",
            "Temple Smash",
            "Temple Strike",
        },
        ['JarringStrike'] = {
            "Jarring Crash",
            "Jarring Strike",
            "Jarring Smash",
            "Jarring Clash",
            "Jarring Slam",
            "Jarring Blow",
            "Jarring Crush",
            "Jarring Smite",
            "Jarring Jolt",
            "Jarring Shock",
            "Jarring Impact",
        },
    },
    ['RotationOrder'] = {
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
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.BurnCheck() and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
    },
    ['Rotations']     = {
        ['Downtime'] = {
            {
                name = "SummonAxes",
                type = "CustomFunc",
                custom_func = function(self)
                    if not RGMercUtils.GetSetting('SummonAxes') then return false end
                    if mq.TLO.Cursor.ID() ~= 0 then RGMercUtils.DoCmd("/autoinv") end
                    if not RGMercUtils.PCDiscReady((self.ResolvedActionMap['AutoAxe1'])) then return false end
                    if mq.TLO.FindItemCount(self.ResolvedActionMap['AutoAxe1'].Name())() > RGMercUtils.GetSetting('AutoAxeCount') then return false end
                    if RGMercUtils.GetSetting('AutoAxeCount') == 0 then return false end
                    local spell = mq.TLO.Spell(self.ResolvedActionMap['AutoAxe1'].Name())
                    if not spell or not spell() then return false end
                    if mq.TLO.FindItemCount(spell.ReagentID(1)())() == 0 then return false end

                    local ret = RGMercUtils.UseDisc(self.ResolvedActionMap['AutoAxe1'], mq.TLO.Me.ID())
                    RGMercUtils.DoCmd("/autoinv")
                    return ret
                end,
            },
            {
                name = "SummonAxes2",
                type = "CustomFunc",
                custom_func = function(self)
                    if not RGMercUtils.GetSetting('SummonAxes2') then return false end
                    if mq.TLO.Cursor.ID() ~= 0 then RGMercUtils.DoCmd("/autoinv") end
                    if not RGMercUtils.PCDiscReady((self.ResolvedActionMap['AutoAxe2'])) then return false end
                    if mq.TLO.FindItemCount(self.ResolvedActionMap['AutoAxe2'].Name())() > RGMercUtils.GetSetting('AutoAxe2Count') then return false end
                    if RGMercUtils.GetSetting('AutoAxe2Count') == 0 then return false end
                    local spell = mq.TLO.Spell(self.ResolvedActionMap['AutoAxe2'].Name())
                    if not spell or not spell() then return false end
                    if mq.TLO.FindItemCount(spell.ReagentID(1)())() == 0 then return false end

                    local ret = RGMercUtils.UseDisc(self.ResolvedActionMap['AutoAxe2'], mq.TLO.Me.ID())
                    RGMercUtils.DoCmd("/autoinv")
                    return ret
                end,
            },
            {
                name = "SummonDichoAxe",
                type = "CustomFunc",
                custom_func = function(self)
                    if not RGMercUtils.GetSetting('SummonDichoAxes') then return false end
                    if not RGMercUtils.PCDiscReady((self.ResolvedActionMap['DichoAxe'])) then return false end
                    if mq.TLO.Cursor.ID() ~= 0 then RGMercUtils.DoCmd("/autoinv") end
                    if mq.TLO.FindItemCount(self.ResolvedActionMap['DichoAxe'].Name())() > RGMercUtils.GetSetting('DichoAxeCount') then return false end
                    if RGMercUtils.GetSetting('DichoAxeCount') == 0 then return false end
                    local spell = mq.TLO.Spell(self.ResolvedActionMap['DichoAxe'].Name())
                    if not spell or not spell() then return false end
                    if mq.TLO.FindItemCount(spell.ReagentID(1)())() == 0 then return false end

                    local ret = RGMercUtils.UseDisc(self.ResolvedActionMap['DichoAxe'], mq.TLO.Me.ID())
                    RGMercUtils.DoCmd("/autoinv")
                    return ret
                end,
            },
            {
                name = "Communion of Blood",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctEndurance() <= 75
                end,
            },
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.PctEndurance() <= 21 and
                        not mq.TLO.Me.Invis()
                end,
            },
            {
                name = "BerAura",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.Aura(1).ID() and mq.TLO.Me.CombatAbilityReady(discSpell.RankName())() and
                        mq.TLO.Me.PctEndurance() > 10
                end,
            },
        },
        ['Burn'] = {
            {
                name = "PrimaryBurnDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and
                        (not mq.TLO.Me.ActiveDisc.ID() or mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['DiscondDisc'] or "None"))
                end,
            },
            {
                name = "Savage Spirit",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Juggernaut Surge",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Blood Pact",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Blinding Fury",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Silent Strikes",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Spire of the Juggernaut",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Desperation",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Focused Furious Rampage",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Untamed Rage",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Coat",
                type = "Item",
                cond = function(self, itemName)
                    return not mq.TLO.Me.PetBuff("Primal Fusion")() and mq.TLO.FindItem(itemName).TimerReady() == 0
                end,
            },
            {
                name = "CleavingDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None") and
                        RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Reckless Abandon",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "Vehement Rage",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['PrimaryBurnDisc'] or "None")
                end,
            },
            {
                name = "ResolveDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return (not mq.TLO.Me.ActiveDisc.ID() or mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['DiscondDisc'] or "None")) and
                        not RGMercUtils.PCDiscReady(self.ResolvedActionMap['PrimaryBurnDisc']) and
                        not RGMercUtils.PCDiscReady(self.ResolvedActionMap['CleavingDisc'])
                end,
            },
            {
                name = "FlurryDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return (not mq.TLO.Me.ActiveDisc.ID() or mq.TLO.Me.ActiveDisc() == (self.ResolvedActionMap['DiscondDisc'] or "None")) and
                        not RGMercUtils.PCDiscReady(self.ResolvedActionMap['PrimaryBurnDisc']) and
                        not RGMercUtils.PCDiscReady(self.ResolvedActionMap['CleavingDisc']) and
                        not RGMercUtils.PCDiscReady(self.ResolvedActionMap['ResolveDisc'])
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    local epicItem = mq.TLO.FindItem(itemName)
                    return RGMercUtils.GetSetting('DoEpic') and epicItem() and epicItem.Spell.Stacks() and
                        epicItem.TimerReady() == 0
                end,
            },
            {
                name = "Battle Leap",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoBattleLeap') and not RGMercUtils.SongActiveByName("Battle Leap Warcry") and
                        not RGMercUtils.SongActiveByName("Group Bestial Alignment")
                end,
            },
            {
                name = "Frenzy",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)()
                end,
            },
            {
                name = "Dfrenzy",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Dvolley",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Spell(discSpell).NoExpendReagentID(1)() == -1 or
                        (mq.TLO.FindItemCount(mq.TLO.Spell(discSpell).NoExpendReagentID(1)())() or 0) > 0 and
                        RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Daxeof",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Daxethrow",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "SharedBuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and not RGMercUtils.SongActiveByName(discSpell.RankName())
                end,
            },
            {
                name = "RageStrike",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Phantom",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and RGMercUtils.GetSetting('DoPet')
                end,
            },
            {
                name = "SappingStrike",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Binding Axe",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Intimidation",
                type = "Ability",
                cond = function(self, abilityName)
                    return RGMercUtils.GetSetting('DoIntimidate') and mq.TLO.Me.AbilityReady(abilityName)()
                end,
            },
            {
                name = "AESlice",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.GetSetting('DoAoe') and RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Alliance",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoAlliance') and RGMercUtils.CanAlliance() and
                        not RGMercUtils.TargetHasBuff(mq.TLO.AltAbility(aaName).Spell)
                end,
            },
            {
                name = "BraxiChain",
                type = "CustomFunc",
                custom_func = function(self)
                    if not RGMercUtils.PCAAReady("Braxi's Howl") then return false end
                    local ret = false
                    ret = ret or RGMercUtils.UseAA("Braxi's Howl", RGMercConfig.Globals.AutoTargetID)
                    ret = ret or RGMercUtils.UseDisc(self.ResolvedActionMap['Discho'], RGMercConfig.Globals.AutoTargetID)

                    return ret
                end,
            },
            {
                name = "DisconDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.ActiveDisc() == nil
                end,
            },
            {
                name = "Bloodfury",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.PCDiscReady(self.ResolvedActionMap['FrenzyBoost']) and mq.TLO.Me.PctHPs() >= 90
                end,
            },
            {
                name = "FrenzyBoost",
                type = "Disc",
                cond = function(self, discSpell)
                    return not RGMercUtils.BuffActive(discSpell)
                end,
            },
            {
                name = "CryDmg",
                type = "Disc",
                cond = function(self, discSpell)
                    return not RGMercUtils.SongActiveByName(discSpell.Name() or "None")
                end,
            },
            {
                name = "Drawn to Blood",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetTargetDistance() > 15
                end,
            },
            {
                name = "Communion of Blood",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctEndurance() <= 75
                end,
            },
            {
                name = "<<None>>",
                name_func = function(self)
                    if not self.ModuleLoaded then return "" end
                    return mq.TLO.Spell("Reflexive Retaliation").RankName()
                end,
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Intimidation",
                type = "Ability",
                cond = function(self, abilityName)
                    return RGMercUtils.GetSetting('DoIntimidate') and mq.TLO.Me.AbilityReady(abilityName)()
                end,
            },
        },
    },
    ['DefaultConfig'] = {
        ['Mode']            = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 1, },
        ['DoEpic']          = { DisplayName = "Do Epic", Category = "Abilities", Tooltip = "Enable using your epic clicky", Default = true, },
        ['DoBattleLeap']    = { DisplayName = "Do Battle Leap", Category = "Abilities", Tooltip = "Enable using Battle Leap", Default = true, },
        ['DoIntimidate']    = { DisplayName = "Do Intimidate", Category = "Abilities", Tooltip = "Enable using Intimidate", Default = true, },
        ['DoAoe']           = { DisplayName = "Do AoE", Category = "Abilities", Tooltip = "Enable using AoE Abilities", Default = true, },
        ['SummonAxes']      = { DisplayName = "Summon Axes", Category = "Abilities", Tooltip = "Enable Summon Axes", Default = true, },
        ['AutoAxeCount']    = { DisplayName = "Auto 1st Axe Count", Category = "Abilities", Tooltip = "Enable [X] Primary Summon Axes", Default = 300, Min = 100, Max = 600, },
        ['AutoAxe2Count']   = { DisplayName = "Auto 2nd Axe Count", Category = "Abilities", Tooltip = "Enable [X] Secondary Summon Axes", Default = 300, Min = 100, Max = 600, },
        ['DichoAxeCount']   = { DisplayName = "Auto Dicho Axe Count", Category = "Abilities", Tooltip = "Enable [X] Dico Summon Axes", Default = 300, Min = 100, Max = 600, },
        ['SummonAxes2']     = { DisplayName = "Summon Axes 2", Category = "Abilities", Tooltip = "Enable Summon Axes 2", Default = true, },
        ['SummonDichoAxes'] = { DisplayName = "Summon Dicho Axes", Category = "Abilities", Tooltip = "Enable Summon Dicho Axes", Default = true, },
    },
}
