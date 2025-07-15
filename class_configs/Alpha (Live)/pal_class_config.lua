local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.Targeting")
local Ui           = require("utils.ui")
local Casting      = require("utils.casting")
local ItemManager  = require("utils.item_manager")
local Logger       = require("utils.logger")
local Set          = require('mq.set')

local _ClassConfig = {
    _version              = "Alpha 1.5 - Live (Modern Era Tank Only)",
    _author               = "Algar",
    ['ModeChecks']        = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
        IsHealing = function() return true end,
        IsCuring = function() return Config:GetSetting('DoCures') and Casting.AAReady("Radiant Cure") end,
        IsRezing = function() return (Config:GetSetting('DoBattleRez') and not Core.IsTanking()) or Targeting.GetXTHaterCount() == 0 end,
        --Disabling tank battle rez is not optional to prevent settings in different areas and to avoid causing more potential deaths
    },
    ['Modes']             = {
        'Tank',
        --'DPS',
    },
    ['Cures']             = {
        CureNow = function(self, type, targetId)
            if Config:GetSetting('DoCureAA') then
                if Casting.AAReady("Radiant Cure") then
                    return Casting.UseAA("Radiant Cure", targetId)
                end
            end

            return false
            --local cureSpell = Core.GetResolvedActionMapItem('Puritycure')

            -- if type:lower() == "poison" then
            -- cureSpell = Core.GetResolvedActionMapItem('Puritycure')
            -- elseif type:lower() == "curse" then
            -- cureSpell = Core.GetResolvedActionMapItem('Puritycure')
            --TODO: Add corruption AbilitySet
            -- elseif type:lower() == "corruption" then
            -- cureSpell = Core.GetResolvedActionMapItem('Puritycure')
            -- end

            -- if not cureSpell or not cureSpell() then return false end
            -- return Casting.UseSpell(cureSpell.RankName.Name(), targetId, true)
        end,
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Nightbane, Sword of the Valiant",
            "Redemption",
        },
        ['Coating'] = {
            "Spirit Drinker's Coating",
            "Blood Drinker's Coating",
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
            "Crush of the Heroic",   -- Level 124
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
            "Crush of the Wayunder",      -- Level 122
        },
        ["HealNuke"] = {
            -- Timer 7 - HealNuke
            "Glorious Vindication",   -- Level 85
            "Glorious Exoneration",   -- Level 90
            "Glorious Exculpation",   -- Level 95
            "Glorious Expurgation",   -- Level 100
            "Brilliant Vindication",  -- Level 105
            "Brilliant Exoneration",  -- Level 110
            "Brilliant Exculpation",  -- Level 115
            "Brilliant Acquittal",    -- Level 120
            "Brilliant Denouncement", -- Level 125
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
            "Unwavering Stance",
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
            "Preservation of the Fern",     -- Level 125
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
            "Chastise",
        },
        ["Incoming"] = {
            -- Harmonius Blessing - Empires of Kunark spell
            "Harmonious Blessing",
            "Concordant Blessing",
            "Confluent Blessing",
            "Penumbral Blessing",
            "Paradoxical Blessing",
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
            "Revelation",   -- Level 121
        },
        ["Healproc"] = {
            --- Proc Buff Heal target of Target => LVL 97
            "Restoring Steel",
            "Regenerating Steel",
            "Rejuvenating Steel",
            "Reinvigorating Steel",
            "Revitalizating Steel",
            "Renewing Steel",
        },
        ["FuryProc"] = {
            --- Fury Proc Strike
            "Divine Might",   -- Level 45, 65pt
            "Pious Might",    -- Level 63, 150pt
            "Holy Order",     -- Level 65, 180pt
            "Pious Fury",     -- Level 68, 190pt
            "Righteous Fury", -- Level 80, 268pt --For simplicity of coding and conflict prevention, once fury is rolled into DPU at 80, we will no longer use the undead proc.
            "Devout Fury",    -- Level 85
            "Earnest Fury",   -- Level 90
            "Zealous Fury",   -- Level 95
            "Reverent Fury",  -- Level 100
            "Ardent Fury",    -- Level 105
            "Merciful Fury",  -- Level 110
            "Sincere Fury",   -- Level 115
            "Wrathful Fury",  -- Level 120
            "Avowed Fury",    -- Level 125
        },
        ["UndeadProc"] = {
            --- Undead Proc Strike : does not stack with Fury Proc, will be used until Fury is available even if setting not enabled.
            "Instrument of Nife", -- Level 26, 243pt
            "Ward of Nife",       -- Level 62, 300pt
            "Silvered Fury",      -- Level 67, 390pt
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
            "Aurora of Realizing",
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
            "Force of the Wayunder",      -- Level 125
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
            "Avowed Force",    -- Level 121
        },
        ["HealStun"] = {
            --- Heal Stuns T3 12s recast
            "Force of the Avowed", --Level 124
            "Force of Generosity",
            "Force of Reverence",
            "Force of Ardency",
            "Force of Mercy",
            "Force of Sincerity",
        },
        ["HealWard"] = {
            --- Healing ward Heals Target of target and wards self. Divination based heal/ward
            "Protective Acceptance",
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
            "Fernshade Keeper",              -- Level 122
            "Hand of the Fernshade Keeper",  -- Level 125 - Group
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
            "Brell's Unbreakable Palisade",
        },
        ["Splashcure"] = {
            ---, Spells
            "Splash of Heroism",
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
            "Valiant Defiance",
            "Valiant Disruption",
            "Valiant Deflection",
            "Valiant Defense",
            "Valiant Diversion",
            "Valiant Deterrence",
        },
        ["Affirmation"] = {
            --- Improved Super Taunt - Gets you Aggro for X seconds and reduces other Haters generation.
            "Unconditional Affirmation",
            "Unending Affirmation",
            "Unrelenting Affirmation",
            "Undivided Affirmation",
            "Unbroken Affirmation",
            "Unflinching Affirmation",
            "Unyielding Affirmation",
        },
        ["Doctrine"] = {
            --- Undead DD
            "Doctrine of Abrogation",
            "Doctrine of Rescission",
            "Doctrine of Exculpation",
            "Doctrine of Abolishment",
            "Doctrine of Repudiation",
        },
        ["WaveHeal"] = {
            --- Group Wave heal 39-124
            "Wave of Regret",
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
        ["SelfHeal"] = {
            "Penitence",
            "Contrition",
            "Sorrow",
            "Grief",
            "Exaltation",
            "Propitiation",
            "Culpability",
            "Angst",
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
            "Mark of the Forgotten Hero",
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
            "Avowed Cleansing",     -- Level 123
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
            "Burst of Sunspring",
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
            "Armor of Heroic Faith",      -- Level 118
        },
        ["RighteousStrike"] = {
            --- Righteous Strikes Line
            "Righteous Antipathy",
            "Righteous Fury",
            "Righteous Indignation",
            "Righteous Vexation",
            "Righteous Umbrage",
            "Righteous Condemnation",
            "Righteous Antipathy",
            "Righteous Censure",
            "Righteous Disdain",
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
            "Symbol of Sevalak",
            "Symbol of Thormir",
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
            "Lesson of Remembrance",          -- Level 117
        },
        ["Audacity"] = {
            -- Hate magic Debuff Over time
            "Fanatical Audacity",
            "Ardent Audacity,",
            "Fervent Audacity,",
            "Sanctimonious Audacity,",
            "Devout Audacity,",
            "Righteous Audacity,",
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
            "Avowed Light",    -- Level 122
        },
        ["Pacify"] = {
            "Assuring Words",
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
            "Avowed Touch",
        },
        ["Dicho"] = {
            --- Dissident Stun
            "Dichotomic Force",
            "Dissident Force",
            "Composite Force",
            "Ecliptic Force",
            "Reciprocal Force",
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
        ["ForHonor"] = {
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
            "Petition for Honor",
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
        ["Aurabuff"] = {
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
            "Aureate Covariance",
        },
        ["CurseCure"] = {
            -- Curse Cure Line
            "Remove Minor Curse",
            "Remove Lesser Curse",
            "Remove Curse",
            "Remove Greater Curse",
        },
        ['EndRegen'] = {
            --Timer 13, can't be used in combat
            "Second Wind",
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
        ["MeleeMit"] = {
            -- Withstand Combat Line of Defense - Update to format once tested
            "Withstand",
            "Defy",
            "Renounce",
            "Reprove",
            "Repel",
            "Spurn",
            "Thwart",
            "Repudiate",
            "Gird",
        },
        ["ArmorDisc"] = {
            --- Armor Timer 11
            "Armor of Avowal",
            "Armor of the Forthright",
            "Armor of Sincerity",
            "Armor of Mercy",
            "Armor of Ardency",
            "Armor of Reverence",
            "Armor of Zeal",
            "Armor of Courage",
        },
        ["Undeadburn"] = {
            "Holyforge Discipline",
        },
        ["Penitent"] = {
            -- Penitent Armor Discipline Timer 11
            "Avowed Penitence",
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
            "Guard of Righteousness",
            "Guard of Humility",
            "Guard of Piety",
        },
        ["Guardian"] = {
            -- Holy Guardian Discipline
            "Revered Guardian Discipline",
            "Blessed Guardian Discipline",
            "Holy Guardian Discipline",
        },
        ["Spellblock"] = {
            "Sanctification Discipline",
        },
        ['Deflection'] = {
            'Deflection Discipline',
        },
        ["ReflexStrike"] = {
            --- Reflexive Strike Heal
            "Reflexive Resolution",
            "Reflexive Redemption",
            "Reflexive Righteousness",
            "Reflexive Reverence",
        },
        ['RezSpell'] = {
            'Resurrection',
            'Restoration',
            'Renewal',
            'Revive',
            'Reparation',
            'Reconstitution',
            'Reanimation',
        },
    },
    ['HelperFunctions']   = {
        DoRez = function(self, corpseId)
            local rezAction = false
            local rezSpell = Core.GetResolvedActionMapItem('RezSpell')
            local okayToRez = Casting.OkayToRez(corpseId)

            if (Config:GetSetting('DoBattleRez') or mq.TLO.Me.CombatState():lower() ~= "combat") and Casting.AAReady("Gift of Resurrection") then
                rezAction = okayToRez and Casting.UseAA("Gift of Resurrection", corpseId, true, 1)
            elseif not Casting.CanUseAA("Gift of Resurrection") and mq.TLO.Me.CombatState():lower() ~= "combat" and Casting.SpellReady(rezSpell, true) then
                rezAction = okayToRez and Casting.UseSpell(rezSpell, corpseId, true, true)
            end

            return rezAction
        end,
        --determine whether we should overwrite DPU buffs with better single buffs
        SingleBuffCheck = function(self)
            if Casting.CanUseAA("Divine Protector's Unity") and not Config:GetSetting('OverwriteDPUBuffs') then return false end
            return true
        end,
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
    },
    ['HealRotationOrder'] = {
        {
            name = 'EmergencyHealing', --Self-only combat healing
            state = 1,
            steps = 1,
            cond = function(self, target, combat_state)
                if target.ID() ~= mq.TLO.Me.ID() then return false end
                return combat_state == "Combat" and (target.PctHPs() or 999) < Config:GetSetting('EmergencyStart')
            end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ["MainHealPoint"] = {
            {
                name = "Gift of Life",
                type = "AA",
                cond = function(self, aaName, target)
                    if not mq.TLO.Group() then return false end
                    return self.CombatState == "Combat" and Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "Hand of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    if not mq.TLO.Group() then return false end
                    return self.CombatState == "Combat" and Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "Lay on Hands",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.GetTargetPctHPs() < Config:GetSetting('LayHandsPct')
                end,
            },
            {
                name = "WaveHeal",
                type = "Spell",
                cond = function(self, spell)
                    if not mq.TLO.Group() then return false end
                    return Casting.CastReady(spell) and Targeting.GroupHealsNeeded()
                end,
            },
            {
                name = "Aurora",
                type = "Spell",
                cond = function(self, spell)
                    if not mq.TLO.Group() then return false end
                    return Casting.CastReady(spell) and Targeting.GroupHealsNeeded()
                end,
            },
        },
        ['EmergencyHealing'] = {
            {
                name = "Lay on Hands",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() < 25
                end,
            },
            {
                name = "SelfHeal",
                type = "Spell",
            },
            {
                name = "Marr's Gift",
                type = "AA",
            },
            {
                name = "Hand of Piety",
                type = "AA",
            },
            {
                name = "Gift of Life",
                type = "AA",
            },
        },
    },
    ['RotationOrder']     = {
        { --Self Buffs
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
        { --Actions that establish or maintain hatred
            name = 'HateTools',
            state = 1,
            steps = 1,
            load_cond = function(self) return Core.IsTanking() end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.IsTanking() and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --Defensive actions triggered by low HP
            name = 'EmergencyDefenses',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
            end,
        },
        { --Prioritized in their own rotation to help keep HP topped to the desired level, includes emergency abilities
            name = 'ToTHeals',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        { --Dynamic weapon swapping if UseBandolier is toggled
            name = 'Weapon Management',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('UseBandolier') end,
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
                --need to look at rotation and decide if it should fire during emergencies. leaning towards no
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --Offensive actions to temporarily boost damage dealt
            name = 'Burn',
            state = 1,
            steps = 2,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --Non-spell actions that can be used during/between casts
            name = 'CombatWeave',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --DPS Spells, includes recourse/gift maintenance
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
    },
    ['Rotations']         = {
        ['Downtime'] = {
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
                name = "Divine Protector's Unity",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID() or 0) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "ArmorSelfBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "FuryProc",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "UndeadProc",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) --use this always until we have a Fury proc, and optionally after that, up until the point that Fury is rolled into DPU
                    if (mq.TLO.Me.AltAbility("Divine Protector's Unity").Rank() or 0) > 1 or (Core.GetResolvedActionMapItem("FuryProc") and not Config:GetSetting('DoUndeadProc')) then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Remorse",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Piety",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            --You'll notice my use of TotalSeconds, this is to keep as close to 100% uptime as possible on these buffs, rebuffing early to decrease the chance of them falling off in combat
            --I considered creating a function (helper or utils) to govern this as I use it on multiple classes but the difference between buff window/song window/aa/spell etc makes it unwieldy
            -- if using duration checks, dont use SelfBuffCheck() (as it could return false when the effect is still on)
            {
                name = "Preservation",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Core.IsModeActive("Tank") and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "TempHP",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Config:GetSetting('DoTempHP') then return false end
                    return spell.RankName.Stacks() and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 45
                end,
            },
            {
                name = "Incoming",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return spell.RankName.Stacks() and Core.IsModeActive("Tank") and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 15
                end,
            },
            {
                name = "HealWard",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return spell.RankName.Stacks() and Core.IsModeActive("Tank") and (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 15
                end,
            },
            { --Charm Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Charm").Name() or "CharmClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCharmClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Huntsman's Ethereal Quiver",
                type = "Item",
                active_cond = function(self) return mq.TLO.FindItemCount("Ethereal Arrow")() > 100 end,
                cond = function(self)
                    if not Config:GetSetting('SummonArrows') then return false end
                    return mq.TLO.FindItemCount("Ethereal Arrow")() < 101
                end,
            },
        },
        ['GroupBuff'] = {
            --These intentionally only check the tank so he isn't constantly switching targets to check stacking/pausing to rebuff others with single target spells. Considering removing or splitting single target versions of buffs.
            {
                name = "Brells",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Config:GetSetting('DoBrells') then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Aego",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if Config:GetSetting('AegoSymbol') ~= 1 then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Symbol",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if Config:GetSetting('AegoSymbol') ~= 2 then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Marr's Salvation",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoSalvation') then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
        },
        ['EmergencyDefenses'] = {
            --Note that in Tank Mode, defensive discs are preemptively cycled on named in the (non-emergency) Defenses rotation
            --Abilities should be placed in order of lowest to highest triggered HP thresholds
            --Side Note: I reserve Bargain for manual use while driving, the omission is intentional.
            --Some conditionals are commented out while I tweak percentages (or determine if they are necessary)
            {
                name = "Armor of Experience",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() < 25 and Config:GetSetting('DoVetAA')
                end,
            },
            --Note that on named we may already have a mantle/carapace running already, could make this remove other discs, but meh, Shield Flash still a thing.
            {
                name = "Deflection",
                type = "Disc",
                pre_activate = function(self)
                    if Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyLockout') and Casting.NoDiscActive() and
                        (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 0) < 234000
                end,
            },
            {
                name = "Shield Flash",
                type = "AA",
                pre_activate = function(self)
                    if Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline"
                end,
            },
            --Penitent vs Armor is something I will need to do more homework on
            {
                name = "Penitent",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive() and Core.IsTanking()
                end,
            },
            {
                name = "Group Armor of The Inquisitor",
                type = "AA",
                cond = function(self, aaName)
                    return not Casting.IHaveBuff("Armor of the Inquisitor")
                end,
            },
            {
                name = "Armor of the Inquisitor",
                type = "AA",
                cond = function(self, aaName)
                    return not Casting.IHaveBuff("Armor of the Inquisitor")
                end,
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
                name = "Mantle",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            --if we made it this far let's reset our dicho/dire and hope for the best!
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ['HateTools'] = {
            --used when we've lost hatred after it is initially established
            {
                name = "Ageless Enmity",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.GetAutoTargetPctHPs() < 90 and mq.TLO.Me.PctAggro() < 100
                end,
            },
            --used to jumpstart hatred on named from the outset and prevent early rips from burns
            {
                name = "Affirmation",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Targeting.IsNamed(target)
                end,
            },
            {
                name = "Heroic Leap",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('AETauntAA') then return false end
                    return self.ClassConfig.HelperFunctions.AETauntCheck(true)
                end,
            },
            {
                name = "Beacon of the Righteous",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('AETauntAA') then return false end
                    return self.ClassConfig.HelperFunctions.AETauntCheck(true)
                end,
            },
            {
                name = "Hallowed Lodestar",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('AETauntAA') then return false end
                    return self.ClassConfig.HelperFunctions.AETauntCheck(true)
                end,
            },
            {
                name = "Projection of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    ---@diagnostic disable-next-line: undefined-field
                    return Targeting.IsNamed(target) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 80
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and target.ID() > 0 and Targeting.GetTargetDistance(target) < 30
                end,
            },
            {
                name = "ForHonor",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Valorous Rage",
                type = "AA",
            },
            {
                name = "RighteousStrike",
                type = "Disc",
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVetAA')
                end,
            },
            {
                name = "Spire of Chivalry",
                type = "AA",
            },
            {
                name = "Thunder of Karana",
                type = "AA",
            },
            --add this back in with tanking Check
            -- {
            -- name = "Inquisitor's Judgment",
            -- type = "AA",
            -- },
        },
        ['Defenses'] = {
            {
                name = "MeleeMit",
                type = "Disc",
                cond = function(self, discSpell)
                    if not Core.IsTanking() then return false end
                    return not ((discSpell.Level() or 0) < 108 and not Casting.NoDiscActive)
                end,
            },
            {
                name = "ArmorDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    if not Core.IsTanking() then return false end
                    return Casting.NoDiscActive() and (Targeting.IsNamed(target) or self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true))
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                cond = function(self, discSpell, target)
                    if not Core.IsTanking() then return false end
                    return Casting.NoDiscActive() and (Targeting.IsNamed(target) or self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true))
                end,
            },
            {
                name = "Guardian",
                type = "Disc",
                cond = function(self, discSpell, target)
                    if not Core.IsTanking() then return false end
                    return Casting.NoDiscActive() and (Targeting.IsNamed(target) or self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true))
                end,
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
                name = "Purification",
                type = "AA",
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return mq.TLO.Me.TotalCounters() > 0
                end,
            },
        },
        ['ToTHeals'] = {
            {
                name = "Dicho",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDicho') then return false end
                    local myHP = mq.TLO.Me.PctHPs()
                    return (myHP <= Config:GetSetting('EmergencyStart') or (Casting.HaveManaToNuke() and myHP <= Config:GetSetting('StartDicho')))
                end,
            },
            {
                name = "BurstHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < Config:GetSetting('StartBurstToT')
                end,
            },
            {
                name = "TotLightHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < Config:GetSetting('TotHealPoint')
                end,
            },
            {
                name = "Lowaggronuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < Config:GetSetting('TotHealPoint')
                end,
            },
        },
        ['CombatWeave'] = {
            { --Used if the group could benefit from the heal
                name = "ReflexStrike",
                type = "Disc",
                cond = function(self, discSpell)
                    return Targeting.GroupHealsNeeded()
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
                name = "Vanquish the Fallen",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetBodyIs(target, "Undead")
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Core.ShieldEquipped() or Casting.CanUseAA("Improved Bash")
                end,
            },
            {
                name = "Slam",
                type = "Ability",
            },
        },
        ['Combat'] = {
            {
                name = "StunTimer4",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "HealStun",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and spell.RankName.Stacks() and (mq.TLO.Me.Song(spell.Trigger(1).Name).Duration.TotalSeconds() or 0) < 12
                end,
            },
            {
                name = "HealWard",
                type = "Spell",
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "CrushTimer6",
                type = "Spell",
            },
            {
                name = "HealNuke",
                type = "Spell",
            },
            {
                name = "Disruptive Persecution",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Force of Disruption",
                type = "AA",
            },
        },
        ['Weapon Management'] = {
            {
                name = "Equip Shield",
                type = "CustomFunc",
                active_cond = function()
                    return mq.TLO.Me.Bandolier("Shield").Active()
                end,
                cond = function(self, target)
                    if mq.TLO.Me.Bandolier("Shield").Active() then return false end
                    return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EquipShield')) or (Targeting.IsNamed(Targeting.GetAutoTarget()) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("Shield") end,
            },
            {
                name = "Equip 2Hand",
                type = "CustomFunc",
                active_cond = function(self, target)
                    return mq.TLO.Me.Bandolier("2Hand").Active()
                end,
                cond = function()
                    if mq.TLO.Me.Bandolier("2Hand").Active() then return false end
                    return mq.TLO.Me.PctHPs() >= Config:GetSetting('Equip2Hand') and mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline" and
                        (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 0) < 234000 and not (Targeting.IsNamed(Targeting.GetAutoTarget()) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("2Hand") end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "StunTimer4", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "HealStun", },
                { name = "TotLightHeal", },
            },
        },
        {
            gem = 3,
            spells = {
                --{ name = "LessonStun", },
                { name = "CrushTimer6", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "Lowaggronuke", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "HealNuke", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "SelfHeal", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "BurstHeal", },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "ForHonor", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Dicho", },
                { name = "Preservation", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Preservation", },
                { name = "TempHP", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TempHP", },
                { name = "HealWard", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HealWard", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Incoming", },
            },
        },
    },
    ['PullAbilities']     = {
        {
            id = 'StunTimer4',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('StunTimer4')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('StunTimer4')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('StunTimer4')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'ForHonor',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('ForHonor').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('ForHonor').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('ForHonor')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = {
        --Mode
        ['Mode']              = {
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
        ['DoTempHP']          = {
            DisplayName = "Use HP Buff",
            Category = "Buffs/Debuffs",
            Index = 3,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("TempHP") end,
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why do we have the Temp HP Buff always memorized?",
            Answer = "Temp HP buffs have a very long refresh time after scribing, making them infeasible to use if not gemmed.",
        },
        ['OverwriteDPUBuffs'] = {
            DisplayName = "Overwrite DPU Buffs",
            Category = "Buffs/Debuffs",
            Index = 5,
            Tooltip = "Overwrite DPU with single buffs when they are better than the DPU effect.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "I have new buffs but I am still using DPU, why?",
            Answer = "Toggle to Overwrite DPU with single buffs when appropriate from the Buffs/Debuffs tab. This is disabled by default to speed up buffing.",
        },
        ['DoVetAA']           = {
            DisplayName = "Use Vet AA",
            Category = "Buffs/Debuffs",
            Index = 8,
            Tooltip = "Use Veteran AA's in emergencies or during Burn. (See FAQ)",
            Default = true,
            FAQ = "What Vet AA's does SHD use?",
            Answer = "If Use Vet AA is enabled, Intensity of the Resolute will be used on burns and Armor of Experience will be used in emergencies.",
        },
        ['DoUndeadProc']      = {
            DisplayName = "Use Undead Proc",
            Category = "Buffs/Debuffs",
            Tooltip = "Use Undead proc over Fury proc until Fury is rolled into Divine Protector's Unity (Level 80).",
            Default = false,
            FAQ = "I was using an undead proc buff and it recently switched to the Fury line proc, how do I get it back?",
            Answer = "By default, we will use the undead proc from levels 26-44 as it is the only proc available.\n" ..
                "If you would like to continue to use the Undead proc after that, please enable it in the Spells and Abilities tab.",
        },
        ['DoBrells']          = {
            DisplayName = "Do Brells",
            Category = "Buffs/Debuffs",
            Tooltip = "Enable Casting Brells",
            Default = true,
            FAQ = "Why am I not casting Brells?",
            Answer = "Make sure you have the [DoBrells] setting enabled.",
        },
        ['AegoSymbol']        = {
            DisplayName = "Aego/Symbol Choice:",
            Category = "Buffs/Debuffs",
            Index = 1,
            Tooltip = "Choose whether to use the Aegolism or Symbol Line of HP Buffs.",
            Type = "Combo",
            ComboOptions = { 'Aegolism Line (Keeper)', 'Symbol Line', 'None', },
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "Why aren't I using Aego and/or Symbol buffs?",
            Answer = "Please set which buff you would like to use on the Buffs/Debuffs tab.",
        },
        ['DoSalvation']       = {
            DisplayName = "Marr's Salvation",
            Category = "Buffs/Debuffs",
            Tooltip = "Use your group hatred reduction buff AA.",
            Default = false,
            FAQ = "Why isn't Marr's Salvation being used?",
            Answer = "Select the option in the Spells and Abilities tab to use this buff, it is not enabled by default.",
        },
        --Healing
        ['TotHealPoint']      = {
            DisplayName = "ToT HealPoint",
            Category = "Healing",
            Tooltip = "HP % before we use Target of Target heals.",
            Default = 30,
            Min = 1,
            Max = 100,
            FAQ = "Why am I not healing the target of my target?",
            Answer = "You will want to adjust [TotHealPoint] to the % HP you have before using Target of Target heals.",
        },
        ['LayHandsPct']       = {
            DisplayName = "Use Lay on Hands",
            Category = "Healing",
            Tooltip = "HP % before we use Lay on Hands on others (Will be used on self in extreme emergencies).",
            Default = 35,
            Min = 1,
            Max = 100,
            FAQ = "Why am I not using Lay on Hands?",
            Answer = "You will want to adjust [LayHandsPct] to the % HP you have before using Lay on Hands.",
        },
        ['StartBurstToT']     = {
            DisplayName = "HP % for Burst ToT",
            Category = "Healing",
            Index = 3,
            Tooltip = "ToT HP % before we use Burst heal.",
            Default = 85,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using Dire Taps on cooldown for more DPS?",
            Answer = "The default HP% to begin using Dire Taps is set to only use them if the SHD could benefit from the healing and can be adjusted.",
        },
        ['DoDicho']           = {
            DisplayName = "Cast Dicho",
            Category = "Healing",
            Index = 4,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("Dicho") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why would someone want to disable Dicho Taps at all?",
            Answer = "Also a question that I am unsure of the answer to. Drop in to Discord and let me know!",
        },
        ['StartDicho']        = {
            DisplayName = "HP % for Dicho",
            Category = "Healing",
            Index = 5,
            Tooltip = "Your HP % before we use Dicho.",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using Dicho on cooldown for more DPS?",
            Answer = "The default HP% to begin using Dicho is set to only use them if the SHD could benefit from the healing and can be adjusted.",
        },
        ['DoCures']           = {
            DisplayName = "Do Cures",
            Category = "Healing",
            Tooltip = "Use cure spells and abilities",
            Default = true,
            FAQ = "Why am I not curing?",
            Answer = "Make sure you have the [DoCures] setting enabled.",
        },

        --Hate Tools
        ['AETauntAA']         = {
            DisplayName = "Use AE Taunt AA",
            Category = "Hate Tools",
            Index = 4,
            Tooltip = "Use AE Taunt AA.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Placeholder question aobout AE taunt",
            Answer = "Yes.",
        },
        ['AETauntCnt']        = {
            DisplayName = "AE Taunt Count",
            Category = "Hate Tools",
            Index = 6,
            Tooltip = "Minimum number of haters before using AE Taunt Spells or AA.",
            Default = 2,
            Min = 1,
            Max = 30,
            FAQ = "Why don't we use AE taunts on single targets?",
            Answer =
            "AE taunts are configured to only be used if a target has less than 100% hate on you, at whatever count you configure, so abilities with similar conditions may be used instead.",
        },
        ['SafeAETaunt']       = {
            DisplayName = "AE Taunt Safety Check",
            Category = "Hate Tools",
            Index = 7,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE taunts are used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Taunt Safety Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the taunt.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the taunt not being used when it is safe to do so.",
        },

        --Defenses
        ['DiscCount']         = {
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
        ['EmergencyStart']    = {
            DisplayName = "Emergency Start",
            Category = "Defenses",
            Index = 2,
            Tooltip = "Your HP % before we begin to use emergency abilities.",
            Default = 55,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "My SHD health spikes up and down a lot and abilities aren't being triggered, what gives?",
            Answer = "You may need to tailor the emergency thresholds to your current survivability and target choice.",
        },
        ['EmergencyLockout']  = {
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
        ['DoChestClick']      = {
            DisplayName = "Do Chest Click",
            Category = "Equipment",
            Index = 1,
            Tooltip = "Click your equipped chest.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "What the heck is a chest click?",
            Answer = "Most classes have useful abilities on their equipped chest after level 75 or so. The SHD's is generally a healing tool (a lifetapping pet).",
        },
        ['DoCharmClick']      = {
            DisplayName = "Do Charm Click",
            Category = "Equipment",
            Index = 2,
            Tooltip = "Click your charm for Geomantra.",
            Default = false,
            FAQ = "Why is my Shadow Knight not clicking his charm?",
            Answer = "Charm clicks won't happen if you are in combat.",
        },
        ['DoCoating']         = {
            DisplayName = "Use Coating",
            Category = "Equipment",
            Index = 3,
            Tooltip = "Click your Blood/Spirit Drinker's Coating when defenses are triggered.",
            Default = false,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },
        ['UseBandolier']      = {
            DisplayName = "Dynamic Weapon Swap",
            Category = "Equipment",
            Index = 4,
            Tooltip = "Enable 1H+S/2H swapping based off of current health. ***YOU MUST HAVE BANDOLIER ENTRIES NAMED \"Shield\" and \"2Hand\" TO USE THIS FUNCTION.***",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not using Dynamic Weapon Swapping?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"2Hand\" to use this function.",
        },
        ['EquipShield']       = {
            DisplayName = "Equip Shield",
            Category = "Equipment",
            Index = 5,
            Tooltip = "Under this HP%, you will swap to your \"Shield\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using a shield?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"2Hand\" to use this function.",
        },
        ['Equip2Hand']        = {
            DisplayName = "Equip 2Hand",
            Category = "Equipment",
            Index = 6,
            Tooltip = "Over this HP%, you will swap to your \"2Hand\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 75,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using a 2Hand?",
            Answer = "Make sure you have [UseBandolier] enabled in your class settings.\n" ..
                "You must also have Bandolier entries named \"Shield\" and \"2Hand\" to use this function.",
        },
        ['NamedShieldLock']   = {
            DisplayName = "Shield on Named",
            Category = "Equipment",
            Index = 7,
            Tooltip = "Keep Shield equipped for Named mobs(must be in SpawnMaster or named.lua)",
            Default = true,
            FAQ = "Why does my SHD switch to a Shield on puny gray named?",
            Answer = "The Shield on Named option doesn't check levels, so feel free to disable this setting (or Bandolier swapping entirely) if you are farming fodder.",
        },
        ['SummonArrows']      = {
            DisplayName = "Use Huntsman's Quiver",
            Category = "Equipment",
            Index = 8,
            Tooltip = "Summon arrows with your Huntsman's Ethereal Quiver (Level 90+)",
            Default = false,
            FAQ = "How do I summon arrows?",
            Answer = "If you are at least level 90, keep a Huntsman's Ethereal Quiver in your inventory and enable its use in the options.",
        },
        --ORPHANED PLACEHOLDERS
        ['DoNuke']            = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoReverseDS']       = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoBandolier']       = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['FlashHP']           = {
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

return _ClassConfig
