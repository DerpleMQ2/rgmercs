local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    _version            = "1.4",
    -- 1.1 added Dicho to rotation -SCVOne
    -- 1.2 added Bfrenzy  timer 11 -SCVOne
    -- 1.3 seperated DPS into 3 sections to increase freq of attacks -SCVOne
    -- 1.4 Added toggle for Disconcering Disc, Fixed errors in burn phase with minor refactors --Algar

    _author             = "Derple, SCVOne, Algar",
    ['Modes']           = {
        'DPS',
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Vengeful Taelosian Blood Axe",
            "Raging Taelosian Alloy Axe",
        },
        ['Coat'] = {
            "Cohort's Warmonger Coat",
        },
    },
    ['AbilitySets']     = {
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
            "Oppressing Frenzy",
            "Overpowering Frenzy",
            "Overwhelming Frenzy",
            "Conquering Frenzy",
            "Vanquishing Frenzy",
            "Demolishing Frenzy",
            "Mangling Frenzy",
            "Vindicating Frenzy",
        },
        ['Bfrenzy'] = {
            "Torrid Frenzy",
            "Steel Frenzy",
            "Augmented Frenzy",
            "Stormwild Frenzy",
            "Fighting Frenzy",
            "Combat Frenzy",
            "Restless Frenzy",
            "Battle Frenzy",
            "Amplified Frenzy",
            "Fearless Frenzy",
            "Buttressed Frenzy",
            "Blinding Frenzy",
            "Heightened Frenzy",
            -- "Desperate Frenzy",
            "Magnified Frenzy",
            "Bolstered Frenzy",
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
    ['RotationOrder']   = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    RGMercUtils.DoBuffCheck() and RGMercUtils.AmIBuffable()
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
        {
            name = 'DPS2',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'DPS3',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
    },

    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "Summon Axes",
                type = "CustomFunc",
                custom_func = function(self)
                    if not RGMercUtils.GetSetting('SummonAxes') then return false end

                    local AxeSkills = {
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
                    }

                    if not self.TempSettings.CachedAxeMap then
                        RGMercsLogger.log_debug("\atCaching Axe Skill to Item Mapping...")
                        self.TempSettings.CachedAxeMap = {}
                        for _, axeSkill in ipairs(AxeSkills) do
                            local itemID = RGMercUtils.GetSummonedItemIDFromSpell(mq.TLO.Spell(axeSkill))
                            if itemID > 0 then
                                RGMercsLogger.log_debug("\ayCached: \at%s\aw summons \am%d", axeSkill, itemID)
                                self.TempSettings.CachedAxeMap[itemID] = axeSkill
                            end
                        end
                    end

                    local abilitiesThatNeedAxes = {
                        { name = 'Dvolley',   count_name = 'AutoAxeCount', },
                        { name = 'Daxethrow', count_name = 'AutoAxeCount', },
                        { name = 'Daxeof',    count_name = 'AutoAxeCount', },
                        { name = 'Dicho',     count_name = 'DichoAxeCount', },
                    }

                    local summonNeededItem = function(summonSkill, itemId, count)
                        local maxLoops = 10
                        while mq.TLO.FindItemCount(itemId)() < count do
                            RGMercsLogger.log_debug("\ayWe need more %d because we dont have %d - using %s", itemId, count, summonSkill)
                            self.ClassConfig.HelperFunctions.SummonAxe(mq.TLO.Spell(summonSkill))
                            maxLoops = maxLoops - 1
                            if maxLoops <= 0 then return end
                        end
                    end

                    for _, ability in ipairs(abilitiesThatNeedAxes) do
                        local spell = self:GetResolvedActionMapItem(ability.name)
                        if spell and spell() then
                            for i = 1, 4 do
                                local requiredItemID = spell.ReagentID(i)()
                                if requiredItemID > 0 and mq.TLO.FindItemCount(requiredItemID)() == 0 then
                                    local summonSkill = self.TempSettings.CachedAxeMap[requiredItemID]
                                    if summonSkill then
                                        RGMercsLogger.log_verbose("\ayReagent(%d) for: \at%s\aw needs to use \am%s", i, ability.name, summonSkill)
                                        summonNeededItem(summonSkill, requiredItemID, RGMercUtils.GetSetting(ability.count_name))
                                    end
                                end
                            end
                            for i = 1, 4 do
                                local requiredItemID = spell.NoExpendReagentID(i)()
                                if requiredItemID > 0 then
                                    local summonSkill = self.TempSettings.CachedAxeMap[requiredItemID]
                                    if summonSkill then
                                        RGMercsLogger.log_verbose("\ayNoExpendReagent(%d) for: \at%s\aw needs to use \am%s", i, ability.name, summonSkill)
                                        summonNeededItem(summonSkill, requiredItemID, RGMercUtils.GetSetting(ability.count_name))
                                    end
                                end
                            end
                        end
                    end
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
        ['Burn'] = { --If this burn rotation is optimal, we may wish to refactor with a helper function, a lot of duplicate code near the end. Fixing broken functionality first. - Algar
            {
                name = "PrimaryBurnDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local discondisc = self:GetResolvedActionMapItem('DisconDisc')
                    return not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(discondisc).RankName()
                end,
            },
            {
                name = "Savage Spirit",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Juggernaut Surge",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Blood Pact",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Blinding Fury",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Silent Strikes",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Spire of the Juggernaut",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Desperation",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Focused Furious Rampage",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Untamed Rage",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
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
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.PCDiscReady(discSpell) and not mq.TLO.Me.ActiveDisc() and not RGMercUtils.PCDiscReady(burndisc)
                end,
            },
            {
                name = "Reckless Abandon",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Vehement Rage",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return RGMercUtils.AAReady(aaName) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "ResolveDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    local cleavingdisc = self:GetResolvedActionMapItem('CleavingDisc')
                    local discondisc = self:GetResolvedActionMapItem('DisconDisc')
                    return RGMercUtils.PCDiscReady(discSpell) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(discondisc).RankName())
                        and not (RGMercUtils.PCDiscReady(burndisc) or RGMercUtils.PCDiscReady(cleavingdisc))
                end,
            },
            {
                name = "FlurryDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    local cleavingdisc = self:GetResolvedActionMapItem('CleavingDisc')
                    local discondisc = self:GetResolvedActionMapItem('DisconDisc')
                    local resolvedisc = self:GetResolvedActionMapItem('ResolveDisc')
                    return RGMercUtils.PCDiscReady(discSpell) and (not mq.TLO.Me.ActiveDisc() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(discondisc).RankName())
                        and not (RGMercUtils.PCDiscReady(burndisc) or RGMercUtils.PCDiscReady(cleavingdisc) or RGMercUtils.PCDiscReady(resolvedisc))
                end,
            },
            {
                name = "War Cry of the Braxi",
                type = "Disc",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.SpellStacksOnMe(mq.TLO.Spell(aaName))
                end,
            },
            {
                name = "HHEBuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return not RGMercUtils.AAReady("War Cry of the Braxi") and (not mq.TLO.Me.ActiveDisc.ID()) and RGMercUtils.SpellStacksOnMe(discSpell)
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
                    return RGMercUtils.PCDiscReady(discSpell)
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
                name = "Decapitation",
                type = "AA",
                cond = function(self, aaName)
                    -- on emu this is activated on live it is passive.
                    return RGMercUtils.OnEMU() and RGMercUtils.AAReady(aaName) and not RGMercUtils.SongActive(mq.TLO.Me.AltAbility(aaName).Spell)
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
                    if not RGMercUtils.GetSetting('DoDisconDisc') then return false end
                    return RGMercUtils.PCDiscReady(discSpell) and not mq.TLO.Me.ActiveDisc()
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
        ['DPS2'] = {
            {
                name = "Battle Leap",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoBattleLeap') and not RGMercUtils.SongActiveByName("Battle Leap Warcry") and
                        not RGMercUtils.SongActiveByName("Group Bestial Alignment")
                end,
            },
        },
        ['DPS3'] = {
            {
                name = "Dicho",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "Bfrenzy",
                type = "Disc",
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
        },
    },
    ['HelperFunctions'] = {
        SummonAxe = function(axeDisc)
            if not axeDisc or not axeDisc() then return false end
            RGMercsLogger.log_verbose("\aySummonAxe(): Checking if %s is ready.", axeDisc.Name())
            if not RGMercUtils.PCDiscReady(axeDisc) then return false end
            RGMercsLogger.log_verbose("\aySummonAxe(): Checking AutoAxeAcount")
            if RGMercUtils.GetSetting('AutoAxeCount') == 0 then return false end
            if mq.TLO.FindItemCount(axeDisc)() > RGMercUtils.GetSetting('AutoAxeCount') then return false end

            RGMercsLogger.log_verbose("\aySummonAxe(): Checking For Reagents")
            if mq.TLO.FindItemCount(axeDisc.ReagentID(1)())() == 0 then return false end

            if mq.TLO.Cursor.ID() ~= nil then RGMercUtils.DoCmd("/autoinv") end
            local ret = RGMercUtils.UseDisc(axeDisc, mq.TLO.Me.ID())
            RGMercsLogger.log_verbose("\aySummonAxe(): Waiting for Summon to Finish")
            RGMercUtils.WaitCastFinish(mq.TLO.Me, false)
            RGMercsLogger.log_verbose("\agSummonAxe(): Done!")
            mq.delay(500, function() return mq.TLO.Cursor.ID() ~= nil end)
            while mq.TLO.Cursor.ID() ~= nil do RGMercUtils.DoCmd("/autoinv") end
            return ret
        end,
        PreEngage = function(target)
            local openerAbility = RGMercUtils.GetResolvedActionMapItem('CheapShot')

            if not openerAbility then return end

            RGMercsLogger.log_debug("\ayPreEngage(): Testing Opener ability = %s", openerAbility or "None")

            if openerAbility and mq.TLO.Me.CombatAbilityReady(openerAbility)() and mq.TLO.Me.PctEndurance() >= 5 and RGMercUtils.GetSetting("DoOpener") and RGMercUtils.GetTargetDistance() < 50 then
                RGMercUtils.UseDisc(openerAbility, target)
                RGMercsLogger.log_debug("\agPreEngage(): Using Opener ability = %s", openerAbility or "None")
            else
                RGMercsLogger.log_debug("\arPreEngage(): NOT using Opener ability = %s, DoOpener = %s, Distance to Target = %d, Endurance = %d", openerAbility or "None",
                    RGMercUtils.BoolToColorString(RGMercUtils.GetSetting("DoOpener")), RGMercUtils.GetTargetDistance(), mq.TLO.Me.PctEndurance() or 0)
            end
        end,
    },
    ['DefaultConfig']   = {
        ['Mode']            = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 1, },
        ['DoEpic']          = { DisplayName = "Do Epic", Category = "Abilities", Tooltip = "Enable using your epic clicky", Default = true, },
        ['DoOpener']        = { DisplayName = "Use Openers", Category = "Abilities", Tooltip = "Use Opening Arrow Shot Silent Shot Line.", Default = true, },
        ['DoBattleLeap']    = { DisplayName = "Do Battle Leap", Category = "Abilities", Tooltip = "Enable using Battle Leap", Default = true, },
        ['DoIntimidate']    = { DisplayName = "Do Intimidate", Category = "Abilities", Tooltip = "Enable using Intimidate", Default = true, },
        ['DoAoe']           = { DisplayName = "Do AoE", Category = "Abilities", Tooltip = "Enable using AoE Abilities", Default = true, },
        ['SummonAxes']      = { DisplayName = "Summon Axes", Category = "Abilities", Tooltip = "Enable Summon Axes", Default = true, },
        ['AutoAxeCount']    = { DisplayName = "Auto Axe Count", Category = "Abilities", Tooltip = "Summon more Primary Axes when you hit [x] left.", Default = 100, Min = 0, Max = 600, },
        ['DichoAxeCount']   = { DisplayName = "Auto Dicho Axe Count", Category = "Abilities", Tooltip = "Summon more Dicho Axes when you hit [x] left.", Default = 100, Min = 0, Max = 600, },
        ['SummonDichoAxes'] = { DisplayName = "Summon Dicho Axes", Category = "Abilities", Tooltip = "Enable Summon Dicho Axes", Default = true, },
        ['DoDisconDisc']    = { DisplayName = "Do Discon Disc", Category = "Abilities", Tooltip = "Enable using Disconcerting Discipline", Default = true, },
    },
}
