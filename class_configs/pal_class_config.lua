local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    _version              = "1.0 Beta",
    _author               = "Derple",
    ['ModeChecks']        = {
        IsTanking = function() return RGMercUtils.IsModeActive("Tank") end,
        IsHealing = function() return true end,
    },
    ['Modes']             = {
        'Tank',
        'DPS',
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Nightbane, Sword of the Valiant",
            "Redemption",
        },
    },
    ['AbilitySets']       = {
        ["CrushTimer6"] = {
            -- Timer 6 - Crush (with damage)
            "Crush of Compunction",  -- Level 85
            "Crush of Repentance",   -- Level 90
            "Crush of Tides",        -- Level 95
            "Crush of Tarew",        -- Level 100
            "Crush of Povar",        -- Level 105
            "Crush of E'Ci",         -- Level 110
            "Crush of Restless Ice", -- Level 115
            "Crush of the Umbra",    -- Level 120
        },
        ["CrushTimer5"] = {
            -- Timer 5 - Crush
            "Crush of the Crying Seas",   -- Level 82
            "Crush of Marr",              -- Level 87
            "Crush of Oseka",             -- Level 92
            "Crush of the Iceclad",       -- Level 97
            "Crush of the Darkened Sea",  -- Level 102
            "Crush of the Timorous Deep", -- Level 107
            "Crush of the Grotto",        -- Level 112
            "Crush of the Twilight Sea",  -- Level 117
        },
        ["HealNuke"] = {
            -- Timer 7 - HealNuke
            "Glorious Vindication",  -- Level 85
            "Glorious Exoneration",  -- Level 90
            "Glorious Exculpation",  -- Level 95
            "Glorious Expurgation",  -- Level 100
            "Brilliant Vindication", -- Level 105
            "Brilliant Exoneration", -- Level 110
            "Brilliant Exculpation", -- Level 115
            "Brilliant Acquittal",   -- Level 120
        },
        ["TempHP"] = {
            "Steely Stance",
            "Stubborn Stance",
            "Stoic Stance",
            "Staunch Stance",
            "Steadfast Stance",
            "Defiant Stance",
            "Stormwall Stance",
            "Adamant Stance",
        },
        ["Preservation"] = {
            -- Timer 12 - Preservation
            "Ward of Tunare",               -- Level 70
            "Sustenance of Tunare",         -- Level 80
            "Preservation of Tunare",       -- Level 85
            "Preservation of Marr",         -- Level 90
            "Preservation of Oseka",        -- Level 95
            "Preservation of the Iceclad",  -- Level 100
            "Preservation of Rodcet",       -- Level 110
            "Preservation of the Grotto",   -- Level 115
            "Preservation of the Basilica", -- Level 120
        },
        ["Lowaggronuke"] = {
            --- Nuke Heal Target - Censure
            "Denouncement",
            "Reprimand",
            "Ostracize",
            "Admonish",
            "Censure",
            "Remonstrate",
            "Upbraid",
        },
        ["Incoming"] = {
            -- Harmonius Blessing - Empires of Kunark spell
            "Harmonious Blessing",
            "Concordant Blessing",
            "Confluent Blessing",
            "Penumbral Blessing",
        },
        ["DebuffNuke"] = {
            -- Undead DebuffNuke
            "Last Rites",   -- Level 68 - Timer 7
            "Burial Rites", -- Level 71 - Timer 7
            "Benediction",  -- Level 76
            "Eulogy",       -- Level 81
            "Elegy",        -- Level 86
            "Paean",        -- Level 91
            "Laudation",    -- Level 96
            "Consecration", -- Level 101
            "Remembrance",  -- Level 106
            "Requiem",      -- Level 111
            "Hymnal",       -- Level 116
        },
        ["Healproc"] = {
            --- Proc Buff Heal target of Target => LVL 97
            "Regenerating Steel",
            "Rejuvenating Steel",
            "Reinvigorating Steel",
            "Revitalizating Steel",
            "Renewing Steel",
        },
        ["FuryProc"] = {
            -- - Fury Proc Strike  67 - 115
            "Wrathful Fury",
            "Silvered Fury",
            "Pious Fury",
            "Righteous Fury",
            "Devout Fury",
            "Earnest Fury",
            "Zealous Fury",
            "Reverent Fury",
            "Ardent Fury",
            "Merciful Fury",
            "Sincere Fury",
        },
        ["Aurora"] = {
            "Aurora of Dawning",
            "Aurora of Dawnlight",
            "Aurora of Daybreak",
            "Aurora of Splendor",
            "Aurora of Sunrise",
            "Aurora of Dayspring",
            "Aurora of Morninglight",
            "Aurora of Wakening",
        },
        ["StunTimer5"] = {
            -- Timer 5 - Hate Stun
            "Desist",                     -- Level 13 - Not Timer 5, use for TLP Low Level Stun
            "Stun",                       -- Level 28
            "Force of Akera",             -- Level 53
            "Ancient: Force of Chaos",    -- Level 65
            "Ancient: Force of Jeron",    -- Level 70
            "Force of Prexus",            -- Level 75
            "Force of Timorous",          -- Level 80
            "Force of the Crying Seas",   -- Level 85
            "Force of Marr",              -- Level 90
            "Force of Oseka",             -- Level 95
            "Force of the Iceclad",       -- Level 100
            "Force of the Darkened Sea",  -- Level 105
            "Force of the Timorous Deep", -- Level 110
            "Force of the Grotto",        -- Level 115
            "Force of the Umbra",         -- Level 120
        },
        ["StunTimer4"] = {
            -- Timer 4 - Hate Stun
            "Cease",           -- Level 7 - Not Timer 4, use for TLP Low Level Stun
            "Force of Akilae", -- Level 62
            "Force of Piety",  -- Level 66
            "Sacred Force",    -- Level 71
            "Devout Force",    -- Level 81
            "Solemn Force",    -- Level 83
            "Earnest Force",   -- Level 86
            "Zealous Force",   -- Level 91
            "Reverent Force",  -- Level 96
            "Ardent Force",    -- Level 101
            "Merciful Force",  -- Level 106
            "Sincere Force",   -- Level 111
            "Pious Force",     -- Level 116
        },
        ["Healstun"] = {
            --- Heal Stuns T3 12s recast
            "Force of Generosity",
            "Force of Reverence",
            "Force of Ardency",
            "Force of Mercy",
            "Force of Sincerity",
        },
        ["Healward"] = {
            --- Healing ward Heals Target of target and wards self. Divination based heal/ward
            "Protective Revelation",
            "Protective Confession",
            "Protective Devotion",
            "Protective Dedication",
            "Protective Allegiance",
            "Protective Proclamation",
            "Protective Devotion",
            "Protective Consecration",
        },
        ["Aego"] = {
            --- Pally Aegolism
            "Austerity",                     -- Level 55
            "Blessing of Austerity",         -- Level 58 - Group
            "Guidance",                      -- Level 65
            "Affirmation",                   -- Level 70
            "Sworn Protector",               -- Level 75
            "Oathbound Protector",           -- Level 80
            "Sworn Keeper",                  -- Level 85
            "Oathbound Keeper",              -- Level 90
            "Avowed Keeper",                 -- Level 92
            "Hand of the Avowed Keeper",     -- Level 95 - Group
            "Pledged Keeper",                -- Level 97
            "Hand of the Pledged Keeper",    -- Level 100 - Group
            "Stormbound Keeper",             -- Level 102
            "Hand of the Stormbound Keeper", -- Level 105 - Group
            "Ashbound Keeper",               -- Level 107
            "Hand of the Ashbound Keeper",   -- Level 110 - Group
            "Stormwall Keeper",              -- Level 112
            "Hand of the Stormwall Keeper",  -- Level 115 - Group
            "Shadewell Keeper",              -- Level 117
            "Hand of the Dreaming Keeper",   -- Level 120 - Group
        },
        ["Brells"] = {
            "Brell's Tenacious Barrier",
            "Brell's Loamy Ward",
            "Brell's Tellurian Rampart",
            "Brell's Adamantine Armor",
            "Brell's Steadfast Bulwark",
            "Brell's Stalwart Bulwark",
            "Brell's Blessed Bastion",
            "Brell's Blessed Barrier",
            "Brell's Earthen Aegis",
            "Brell's Stony Guard",
            "Brell's Brawny Bulwark",
            "Brell's Stalwart Shield",
            "Brell's Mountainous Barrier",
            "Brell's Steadfast Aegis",
        },
        ["Splashcure"] = {
            ---, Spells
            "Splash of Repentance",
            "Splash of Sanctification",
            "Splash of Purification",
            "Splash of Cleansing",
            "Splash of Atonement",
            "Splash of Depuration",
            "Splash of Exaltation",
        },
        ["Healtaunt"] = {
            --- Valiant Taunt With Built in heal.
            "Valiant Disruption",
            "Valiant Deflection",
            "Valiant Defense",
            "Valiant Diversion",
            "Valiant Deterrence",
        },
        ["Affirmation"] = {
            --- Improved Super Taunt - Gets you Aggro for X seconds and reduces other Haters generation.
            "Unrelenting Affirmation",
            "Undivided Affirmation",
            "Unbroken Affirmation",
            "Unflinching Affirmation",
            "Unyielding Affirmation",
            "Unending Affirmation",
        },
        ["Doctrine"] = {
            --- Undead DD
            "Doctrine of Abrogation",
            "Doctrine of Rescission",
            "Doctrine of Exculpation",
            "Doctrine of Abolishment",
        },
        ["WaveHeal"] = {
            --- Group Wave heal 39-115
            "Wave of Bereavement",
            "Wave of Propitiation",
            "Wave of Expiation",
            "Wave of Grief",
            "Wave of Sorrow",
            "Wave of Contrition",
            "Wave of Penitence",
            "Wave of Remitment",
            "Wave of Absolution",
            "Wave of Forgiveness",
            "Wave of Piety",
            "Wave of Marr",
            "Wave of Trushar",
            "Healing Wave of Prexus",
            "Wave of Healing",
            "Wave of Life",
        },
        ["WaveHeal2"] = {
            --- Group Wave heal 39-115
            "Wave of Bereavement",
            "Wave of Propitiation",
            "Wave of Expiation",
            "Wave of Grief",
            "Wave of Sorrow",
            "Wave of Contrition",
            "Wave of Penitence",
            "Wave of Remitment",
            "Wave of Absolution",
            "Wave of Forgiveness",
            "Wave of Piety",
            "Wave of Marr",
            "Wave of Trushar",
            "Healing Wave of Prexus",
            "Wave of Healing",
            "Wave of Life",
        },
        ["Selfheal"] = {
            "Penitence",
            "Contrition",
            "Sorrow",
            "Grief",
            "Exaltation",
            "Propitiation",
            "Culpability",
        },
        ["Reverseds"] = {
            --- Reverse DS
            "Mark of the Saint",
            "Mark of the Crusader",
            "Mark of the Pious",
            "Mark of the Pure",
            "Mark of the Defender",
            "Mark of the Reverent",
            "Mark of the Exemplar",
            "Mark of the Commander",
            "Mark of the Jade Cohort",
            "Mark of the Eclipsed Cohort",
        },
        ["Cleansehot"] = {
            --- Pally Hot
            "Ethereal Cleansing",   -- Level 44
            "Celestial Cleansing",  -- Level 59
            "Supernal Cleansing",   -- Level 64
            "Pious Cleansing",      -- Level 69
            "Sacred Cleansing",     -- Level 73
            "Solemn Cleansing",     -- Level 78
            "Devout Cleansing",     -- Level 93
            "Earnest Cleansing",    -- Level 88
            "Zealous Cleansing",    -- Level 93
            "Reverent Cleansing",   -- Level 98
            "Ardent Cleansing",     -- Level 103
            "Merciful Cleansing",   -- Level 108
            "Sincere Cleansing",    -- Level 113
            "Forthright Cleansing", -- Level 118
        },
        ["BurstHeal"] = {
            --- Burst Heal - heals target or Target of target 73-115
            "Burst of Sunlight",
            "Burst of Morrow",
            "Burst of Dawnlight",
            "Burst of Daybreak",
            "Burst of Splendor",
            "Burst of Sunrise",
            "Burst of Dayspring",
            "Burst of Morninglight",
            "Burst of Wakening",
            "Burst of Dawnbreak",
        },
        ["ArmorSelfBuff"] = {
            --- Self Buff Armor Line Ac/Hp/Mana regen
            "Aura of the Crusader",       -- Level 64
            "Armor of the Champion",      -- Level 69
            "Armor of Unrelenting Faith", -- Level 73
            "Armor of Inexorable Faith",  -- Level 78
            "Armor of Unwavering Faith",  -- Level 83
            "Armor of Implacable Faith",  -- Level 88
            "Armor of Formidable Faith",  -- Level 93
            "Armor of Formidable Grace",  -- Level 98
            "Armor of Formidable Spirit", -- Level 103
            "Armor of Steadfast Faith",   -- Level 108
            "Armor of Steadfast Grace",   -- Level 113
            "Armor of Unyielding Grace",  -- Level 118
        },
        ["Righteousstrike"] = {
            --- Righteous Strikes Line
            "Righteous Antipathy",
            "Righteous Fury",
            "Righteous Indignation",
            "Righteous Vexation",
            "Righteous Umbrage",
            "Righteous Condemnation",
            "Righteous Antipathy",
        },
        ["Symbol"] = {
            "Symbol of Liako",
            "Symbol of Jeneca",
            "Symbol of Jyleel",
            "Symbol of Erillion",
            "Symbol of Burim",
            "Symbol of Niparson",
            "Symbol of Teralov",
            "Symbol of Sevalak",
            "Symbol of Bthur",
            "Symbol of Jeron",
            "Symbol of Marzin",
            "Symbol of Naltron",
            "Symbol of Pinzarn",
            "Symbol of Ryltan",
            "Symbol of Transal",
        },
        ["LessonStun"] = {
            --- Lesson Stun - Timer 6
            "Quellious' Word of Tranquility", -- Level 54
            "Quellious' Word of Serenity",    -- Level 64
            "Serene Command",                 -- Level 68
            "Lesson of Penitence",            -- Level 72
            "Lesson of Contrition",           -- Level 77
            "Lesson of Compunction",          -- Level 82
            "Lesson of Repentance",           -- Level 87
            "Lesson of Remorse",              -- Level 92
            "Lesson of Sorrow",               -- Level 97
            "Lesson of Grief",                -- Level 102
            "Lesson of Expiation",            -- Level 107
            "Lesson of Propitiation",         -- Level 112
            "Lesson of Guilt",                -- Level 117
        },
        ["Audacity"] = {
            -- Hate magic Debuff Over time
            "Ardent,",
            "Fervent,",
            "Sanctimonious,",
            "Devout,",
            "Righteous,",
        },
        ["LightHeal"] = {
            -- Target Light Heal
            "Salve",            -- Level 1
            "Minor Healing",    -- Level 6
            "Light Healing",    -- Level 12
            "Healing",          -- Level 27
            "Greater Healing",  -- Level 36
            "Superior Healing", -- Level 48
        },
        ["TotLightHeal"] = {
            -- ToT Light Heal
            "Light of Life",   -- Level 52
            "Light of Nife",   -- Level 63
            "Light of Order",  -- Level 65
            "Light of Piety",  -- Level 68
            "Gleaming Light",  -- Level 72
            "Radiant Light",   -- Level 77
            "Shining Light",   -- Level 82
            "Joyous Light",    -- Level 87
            "Brilliant Light", -- Level 92
            "Dazzling Light",  -- Level 97
            "Blessed Light",   -- Level 102
            "Merciful Light",  -- Level 107
            "Sincere Light",   -- Level 112
            "Raptured Light",  -- Level 117
        },
        ["Pacify"] = {
            "Placating Words",
            "Tranquil Words",
            "Propitiate",
            "Mollify",
            "Reconcile",
            "Dulcify",
            "Soothe",
            "Pacify",
            "Calm",
            "Lull",
        },
        ["Toucheal"] = {
            --- Touch Heal Line LVL61 - LVL115
            "Touch of Nife",
            "Touch of Piety",
            "Sacred Touch",
            "Solemn Touch",
            "Devout Touch",
            "Earnest Touch",
            "Zealous Touch",
            "Reverent Touch",
            "Ardent Touch",
            "Merciful Touch",
            "Sincere Touch",
            "Soothing Touch",
        },
        ["Dicho"] = {
            --- Dissident Stun
            "Dichotomic Force",
            "Dissident Force",
            "Composite Force",
            "Ecliptic Force",
        },
        ["Puritycure"] = {
            --- Purity Cure Poison/Diease Cure Half Power to curse
            "Balanced Purity",
            "Devoted Purity",
            "Earnest Purity",
            "Zealous Purity",
            "Reverent Purity",
            "Ardent Purity",
            "Merciful Purity",
        },
        ["Challengetaunt"] = {
            --- Challenge Taunt Over time Debuff
            "Challenge for Honor",
            "Trial For Honor",
            "Charge for Honor",
            "Confrontation for Honor",
            "Provocation for Honor",
            "Demand for Honor",
            "Impose for Honor",
            "Refute for Honor",
            "Protest for Honor",
            "Parlay for Honor",
        },
        ["Piety"] = {
            -- One Off Buffs
            "Silent Piety",
        },
        ["Remorse"] = {
            -- Remorse
            "Remorse for the fallen",
            "Penitence for the Fallen",
        },
        ["aurabuff1"] = {
            -- Aura Buffs
            "Blessed Aura",
            "Holy Aura",
        },
        ["AntiUndeadNuke"] = {
            -- Undead Nuke
            "Ward Undead",             -- Level 14
            "Expulse Undead",          -- Level 30
            "Dismiss Undead",          -- Level 46
            "Expel Undead",            -- Level 54
            "Deny Undead",             -- Level 62 - Timer 7
            "Spurn Undead",            -- Level 67 - Timer 7
            --[] = "Wraithguard's Vengeance",  -- Level 75 - Unobtainable?
            "Annihilate the Undead",   -- Level 86 - Res Debuff / Extra Damage
            "Abolish the Undead",      -- Level 91 - Res Debuff / Extra Damage
            "Doctrine of Abrogation",  -- Level 96
            "Abrogate the Undead",     -- Level 96 - Res Debuff / Extra Damage
            "Doctrine of Rescission",  -- Level 101
            "Doctrine of Exculpation", -- Level 106
            "Doctrine of Abolishment", -- Level 111
            "Doctrine of Annulment",   -- Level 116
        },
        ["AllianceNuke"] = {
            -- Pally Alliance Spell
            "Holy Alliance",
            "Stormwall Coalition",
        },
        ["CurseCure"] = {
            -- Curse Cure Line
            "Remove Minor Curse",
            "Remove Lesser Curse",
            "Remove Curse",
            "Remove Greater Curse",
        },
        ["endregen"] = {
            -- Fast Endurance regen - Update to new Format Once tested
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
        },
        ["meleemit"] = {
            -- Withstand Combat Line of Defense - Update to format once tested
            "Withstand",
            "Defy",
            "Renounce",
            "Reprove",
            "Repel",
            "Spurn",
            "Thwart",
            "Repudiate",
        },
        ["Armordisc"] = {
            --- Armor Timer 11
            "Armor of the Forthright",
            "Armor of Sincerity",
            "Armor of Mercy",
            "Armor of Ardency",
            "Armor of Reverence",
            "Armor of Zeal",
        },
        ["Undeadburn"] = {
            "Holyforge Discipline",
        },
        ["Pentientarmor"] = {
            -- Pentient Armor Discipline
            "Fervent Penitence",
            "Reverent Penitence",
            "Devout Penitence",
            "Merciful Penitence",
            "Sincere Penitence",
        },
        ["Mantle"] = {
            ---Mantle Line of Discipline Timer 5 defensive burn
            "Supernal Mantle",
            "Mantle of the Sapphire Cohort",
            "Kar`Zok Mantle",
            "Skalber Mantle",
            "Brightwing Mantle",
            "Prominent Mantle",
            "Exalted Mantle",
            "Honorific Mantle",
            "Armor of Decorum",
            "Armor of Righteousness",
        },
        ["Holyguard"] = {
            -- Holy Guardian Discipline
            "Revered Guardian Discipline",
            "Blessed Guardian Discipline",
            "Holy Guardian Discipline",
        },
        ["Spellblock"] = {
            "Sanctification Discipline",
        },
        ["Reflexstrike"] = {
            --- Reflexive Strike Heal
            "Reflexive Redemption",
            "Reflexive Righteousness",
            "Reflexive Reverence",
        },
    },
    ['HelperFunctions']   = {
        -- helper function for advanced logic to see if we want to use Dark Lord's Unity
        castDPU = function(self)
            if not mq.TLO.Me.AltAbility("Divine Protector's Unity")() then return false end
            local furyProcLevel = self:GetResolvedActionMapItem('FuryProc') and self:GetResolvedActionMapItem('FuryProc').Level() or 0
            local DPULevel = mq.TLO.Spell(mq.TLO.Me.AltAbility("Divine Protector's Unity").Spell.Trigger(1).BaseName()).Level() or 0

            return furyProcLevel <= DPULevel
        end,
    },
    ['HealRotationOrder'] = {
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return (target.PctHPs() or 999) < RGMercUtils.GetSetting('MainHealPoint') end,
        },
        {
            name = 'LightHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return (target.PctHPs() or 999) < RGMercUtils.GetSetting('LightHealPoint') end,
        },
    },
    ['HealRotations']     = {
        ["LightHealPoint"] = {
            {
                name = "LightHeal",
                type = "Spell",
                cond = function(self, _) return true end,
            },
        },
        ["MainHealPoint"] = {
            {
                name = "WaveHeal",
                type = "Spell",
                cond = function(self, _)
                    if not mq.TLO.Group() then return false end
                    return mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() > RGMercUtils.GetSetting('GroupInjureCnt')
                end,
            },
            {
                name = "WaveHeal2",
                type = "Spell",
                cond = function(self, _)
                    if not mq.TLO.Group() then return false end
                    return mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() > RGMercUtils.GetSetting('GroupInjureCnt')
                end,
            },
            {
                name = "Aurora",
                type = "Spell",
                cond = function(self, _)
                    if not mq.TLO.Group() then return false end
                    return mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() > RGMercUtils.GetSetting('GroupInjureCnt')
                end,
            },
            {
                name = "Gift of Life",
                type = "AA",
                cond = function(self, aaName)
                    if not mq.TLO.Group() then return false end
                    return mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() > RGMercUtils.GetSetting('GroupInjureCnt') and
                        RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Hand of Piety",
                type = "AA",
                cond = function(self, aaName)
                    if not mq.TLO.Group() then return false end
                    return mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() > RGMercUtils.GetSetting('GroupInjureCnt') and
                        RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Lay on Hands",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.PCAAReady(aaName) and RGMercUtils.GetTargetPctHPs() < RGMercUtils.GetSetting('LayHandsPct')
                end,
                ['HealRotationOrder'] = {
                    {
                        name = 'LowLevelHealPoint',
                        state = 1,
                        steps = 1,
                        cond = function(self, target) return mq.TLO.Me.Level() < 85 and (target.PctHPs() or 999) < RGMercUtils.GetSetting('LightHealPoint') end,
                    },
                },
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    RGMercUtils.DoBuffCheck() and RGMercConfig:GetTimeSinceLastMove() > RGMercUtils.GetSetting('BuffWaitMoveTimer')
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                local groupIds = { mq.TLO.Me.ID(), }
                local count = mq.TLO.Group.Members()
                for i = 1, count do
                    local rezSearch = string.format("pccorpse %s radius 100 zradius 50", mq.TLO.Group.Member(i).DisplayName())
                    if RGMercUtils.GetSetting('BuffRezables') or mq.TLO.SpawnCount(rezSearch)() == 0 then
                        table.insert(groupIds, mq.TLO.Group.Member(i).ID())
                    end
                end
                return groupIds
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and RGMercUtils.DoBuffCheck() and
                    RGMercConfig:GetTimeSinceLastMove() > RGMercUtils.GetSetting('BuffWaitMoveTimer')
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
            name = 'Tank DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.IsModeActive("Tank")
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.IsModeActive("DPS")
            end,
        },
    },
    ['Rotations']         = {
        ['Burn'] = {
            {
                name = "Spire of ChivalryValorous Rage",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.Level() < 80 and RGMercUtils.AAReady(aaName) and not RGMercUtils.SongActiveByName('Group Armor of the Inquisitor') and
                        not RGMercUtils.SongActiveByName('Armor of the Inquisitor') and not RGMercUtils.BuffActiveByName('Spire of Chivalry')
                end,
            },
            {
                name = "Valorous Rage",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Inquisitor's Judgment",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Thunder of Karana",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetSetting('DoNuke')
                end,
            },
            {
                name = "Group Armor of The Inquisitor",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Undeadburn",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.ActiveDisc.ID() and RGMercUtils.NPCDiscReady(discSpell)
                end,
            },
            {
                name = "Righteousstrike",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.ActiveDisc.ID() and RGMercUtils.NPCDiscReady(discSpell)
                end,
            },
            {
                name = "Healproc",
                type = "Spell",
                cond = function(self, spell)
                    return not RGMercUtils.IsTanking() and RGMercUtils.PCSpellReady(spell)
                end,
            },
        },
        ['Tank DPS'] = {
            {
                name = "ActivateShield",
                type = "CustomFunc",
                cond = function(self)
                    return RGMercUtils.GetSetting('DoBandolier') and not mq.TLO.Me.Bandolier("Shield").Active() and
                        mq.TLO.Me.Bandolier("Shield").Index() and RGMercUtils.IsTanking()
                end,
                custom_func = function(_)
                    RGMercUtils.DoCmd("/bandolier activate Shield")
                    return true
                end,

            },
            {
                name = "Activate2HS",
                type = "CustomFunc",
                cond = function(self)
                    return RGMercUtils.GetSetting('DoBandolier') and not mq.TLO.Me.Bandolier("2HS").Active() and
                        mq.TLO.Me.Bandolier("2HS").Index() and not RGMercUtils.IsTanking()
                end,
                custom_func = function(_)
                    RGMercUtils.DoCmd("/bandolier activate 2HS")
                    return true
                end,
            },
            {
                name = "Shield Flash",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctHPs() < RGMercUtils.GetSetting('FlashHP')
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercUtils.IsModeActive('Tank') and
                        (mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2 or RGMercUtils.IsNamed(target)) and
                        mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Holyguard",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercUtils.IsModeActive('Tank') and
                        (mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2 or RGMercUtils.IsNamed(target)) and
                        mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Armordisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercUtils.IsModeActive('Tank') and
                        (mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2 or RGMercUtils.IsNamed(target)) and
                        mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Pentientarmor",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercUtils.IsModeActive('Tank') and
                        (mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2 or RGMercUtils.IsNamed(target)) and
                        mq.TLO.Me.CombatAbilityReady(discSpell.RankName.Name())() and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "meleemit",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            {
                name = "TotLightHeal",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and
                        (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < RGMercUtils.GetSetting('TotHealPoint')
                end,
            },
            {
                name = "BurstHeal",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and
                        (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < RGMercUtils.GetSetting('TotHealPoint')
                end,
            },
            {
                name = "Hallowed Lodestar",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetXTHaterCount() > 2
                end,
            },
            {
                name = "Beacon of the Righteous",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetXTHaterCount() > 2
                end,
            },
            {
                name = "Heroic Leap",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.GetXTHaterCount() > 2
                end,
            },
            {
                name = "Force of Disruption",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.AltAbility(aaName).Rank() or 0) > 7 and not RGMercUtils.BuffActiveByName("Knight's Yaulp") and
                        RGMercUtils.GetTargetDistance() < 30 and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and
                        mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and
                        RGMercUtils.GetTargetDistance() < 30
                end,
            },
            {
                name = "Challengetaunt",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and not RGMercUtils.TargetHasBuff(spell)
                end,
            },
            {
                name = "StunTimer4",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.DetSpellCheck(spell)
                end,
            },
            {
                name = "StunTimer5",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.DetSpellCheck(spell)
                end,
            },
            {
                name = "LessonStun",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.DetSpellCheck(spell)
                end,
            },
            {
                name = "CrushTimer5",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "CrushTimer6",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "Armor of the Inquisitor",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Healtaunt",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "HealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "Lowaggronuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "Dicho",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "AntiUndeadNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.TargetBodyIs(mq.TLO.Target, "Undead")
                end,
            },
            {
                name = "Vanquish The Fallen",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.TargetBodyIs(mq.TLO.Target, "Undead")
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.GetSetting('DoChestClick') and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Marr's Gift",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctMana() <= 60
                end,
            },
            {
                name = "Dicho",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) <= 35
                end,
            },
            {
                name = "TotLightHeal",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and
                        (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < RGMercUtils.GetSetting('TotHealPoint')
                end,
            },
            {
                name = "BurstHeal",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and
                        (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < RGMercUtils.GetSetting('TotHealPoint')
                end,
            },
            {
                name = "DebuffNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and
                        ((RGMercUtils.TargetBodyIs(mq.TLO.Target, "Undead") or mq.TLO.Me.Level() >= 96) and not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.GetSetting('DoNuke'))
                end,
            },
            {
                name = "AntiUndeadNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.TargetBodyIs(mq.TLO.Target, "Undead")
                end,
            },
            {
                name = "Reverseds",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.TargetHasBuff(spell) and RGMercUtils.GetSetting('DoReverseDS')
                end,
            },
            {
                name = "Lowaggronuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.GetSetting('DoNuke')
                end,
            },
            {
                name = "CrushTimer6",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.GetSetting('DoNuke') and (mq.TLO.Me.SecondaryPctAggro() or 0) > 60
                end,
            },
            {
                name = "HealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "Vanquish The Fallen",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.TargetBodyIs(mq.TLO.Target, "Undead")
                end,
            },
            {
                name = "Disruptive Persecution",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and mq.TLO.Me.AltAbility(aaName).Rank() >= 3 and not RGMercUtils.BuffActiveByName("Knight's Yaulp")
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.GetSetting('DoChestClick') and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "aurabuff1",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and not RGMercUtils.AuraActiveByName(spell.RankName.Name()) and mq.TLO.Me.PctEndurance() > 10
                end,
            },
            {
                name = "Divine Protector's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and self.ClassConfig.HelperFunctions.castDPU(self)
                end,
            },
            {
                name = "ArmorSelfBuff",
                type = "Spell",
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDPU(self) and RGMercUtils.PCSpellReady(spell) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "FuryProc",
                type = "Spell",
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDPU(self) and RGMercUtils.PCSpellReady(spell) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Remorse",
                type = "Spell",
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDPU(self) and RGMercUtils.PCSpellReady(spell) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Piety",
                type = "Spell",
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDPU(self) and RGMercUtils.PCSpellReady(spell) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Preservation",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.SelfBuffCheck(spell) and RGMercUtils.IsModeActive("Tank")
                end,
            },
            {
                name = "TempHP",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.SelfBuffCheck(spell) and RGMercUtils.IsModeActive("Tank")
                end,
            },
            {
                name = "Incoming",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.SelfBuffCheck(spell) and RGMercUtils.IsModeActive("Tank")
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
        ['GroupBuff'] = {
            {
                name = "Brells",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) and RGMercUtils.GetSetting('DoBrells') end,
            },
            {
                name = "Aego",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) and not RGMercUtils.GetSetting('DoDruid') end,
            },
            {
                name = "Symbol",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) and RGMercUtils.GetSetting('DoDruid') end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "CrushTimer6", },
                { name = "StunTimer5", },
                { name = "Challengetaunt", },
                { name = "LightHeal", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "Lowaggronuke", cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "CrushTimer5", },
                { name = "StunTimer4", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "HealNuke",    cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "LessonStun",  cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "Healtaunt", },
                { name = "LessonStun", },
                { name = "CrushTimer5", },
                { name = "StunTimer5", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "AntiUndeadNuke", cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "Lowaggronuke", },
                { name = "CrushTimer6", },
                { name = "LessonStun", },
                { name = "WaveHeal", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "WaveHeal",       cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "HealNuke", },
                { name = "AntiUndeadNuke", },
                { name = "TotLightHeal", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "TotLightHeal", cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "WaveHeal2", },
                { name = "BurstHeal", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "BurstHeal",    cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "TotLightHeal", },
                { name = "Preservation", },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "Reverseds", cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "BurstHeal", },
                { name = "TempHP", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DebuffNuke",     cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "Challengetaunt", },
                { name = "Healward", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Healproc", cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "TempHP", },
                { name = "HealNuke", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Aurora",         cond = function(self) return RGMercUtils.IsModeActive('DPS') end, },
                { name = "Preservation", },
                { name = "DebuffNuke", },
                { name = "AntiUndeadNuke", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Dicho", },
                { name = "Challengetaunt", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
            },
        },
    },
    ['PullAbilities']     = {
        {
            id = 'StunTimer4',
            Type = "Spell",
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('StunTimer4')() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('StunTimer4')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('StunTimer4')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'StunTimer5',
            Type = "Spell",
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('StunTimer5')() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('StunTimer5')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('StunTimer5')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = {
        ['Mode']         = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 2, },
        ['DoNuke']       = { DisplayName = "Cast Spells", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = true, },
        ['FlashHP']      = { DisplayName = "Use Shield Flash", Category = "Combat", Tooltip = "Your HP % before we use Shield Flash.", Default = 35, Min = 1, Max = 100, },
        ['TotHealPoint'] = { DisplayName = "ToT HealPoint", Category = "Combat", Tooltip = "HP % before we use Target of Target heals.", Default = 30, Min = 1, Max = 100, },
        ['LayHandsPct']  = { DisplayName = "Use Lay on Hands", Category = "Combat", Tooltip = "HP % before we use Lay on Hands.", Default = 35, Min = 1, Max = 100, },
        ['DoChestClick'] = { DisplayName = "Do Chest Click", Category = "Utilities", Tooltip = "Click your chest item", Default = true, },
        ['DoReverseDS']  = { DisplayName = "Do Reverse DS", Category = "Utilities", Tooltip = "Cast Reverse DS", Default = true, },
        ['SummonArrows'] = { DisplayName = "Summon Arrows", Category = "Utilities", Tooltip = "Enable Summon Arrows", Default = true, },
        ['DoBrells']     = { DisplayName = "Do Brells", Category = "Group Buffs", Tooltip = "Enable Casting Brells", Default = true, },
        ['DoDruid']      = { DisplayName = "Do Druid", Category = "Group Buffs", Tooltip = "Enable SCasting Symbol instead of Aego", Default = true, },
        ['DoBandolier']  = { DisplayName = "Use Bandolier", Category = "Equipment", Tooltip = "Enable Swapping of items using the bandolier.", Default = false, },
    },
}
