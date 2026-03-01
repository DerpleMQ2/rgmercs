local mq        = require('mq')
local Config    = require('utils.config')
local Globals   = require("utils.globals")
local Core      = require("utils.core")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Logger    = require("utils.logger")

return {
    _version              = "1.0 - Live",
    _author               = "Derple",
    ['ModeChecks']        = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
        IsHealing = function() return true end,
        IsCuring = function() return Config:GetSetting('DoCureSpells') or Config:GetSetting("DoCureAA") end,
        IsRezing = function() return (Config:GetSetting('DoBattleRez') and not Core.IsTanking()) or Targeting.GetXTHaterCount() == 0 end,
        --Disabling tank battle rez is not optional to prevent settings in different areas and to avoid causing more potential deaths
    },
    ['Modes']             = {
        'Tank',
        'DPS',
    },
    ['Cures']             = {
        GetCureSpells = function(self)
            --(re)initialize the table for loadout changes
            self.TempSettings.CureSpells = {}

            -- Find the map for each cure spell we need
            local neededCures = {
                ['Poison'] = 'PurityCure',
                ['Disease'] = 'PurityCure',
                ['Curse'] = Casting.GetFirstMapItem({ "PurityCure", "CureCurse", }),
                ['Corruption'] = 'CureCorrupt',
            }

            -- iterate to actually resolve the selected map item, if it is valid, add it to the cure table
            for k, v in pairs(neededCures) do
                local cureSpell = Core.GetResolvedActionMapItem(v)
                if cureSpell then
                    self.TempSettings.CureSpells[k] = cureSpell
                end
            end
        end,
        CureNow = function(self, type, targetId)
            local targetSpawn = mq.TLO.Spawn(targetId)
            if not targetSpawn and targetSpawn then return false, false end

            if Config:GetSetting('DoCureAA') then
                local cureAA = Casting.AAReady("Radiant Cure") and "Radiant Cure"

                if not cureAA and targetId == mq.TLO.Me.ID() and Casting.AAReady("Purification") then
                    cureAA = "Purification"
                end

                if cureAA then
                    Logger.log_debug("CureNow: Using %s for %s on %s.", cureAA, type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
                    return Casting.UseAA(cureAA, targetId), true
                end
            end

            if Config:GetSetting('DoCureSpells') then
                for effectType, cureSpell in pairs(self.TempSettings.CureSpells) do
                    if type:lower() == effectType:lower() then
                        Logger.log_debug("CureNow: Using %s for %s on %s.", cureSpell.RankName(), type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
                        return Casting.UseSpell(cureSpell.RankName(), targetId, true), true
                    end
                end
            end

            Logger.log_debug("CureNow: No valid cure at this time for %s on %s.", type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
            return false, false
        end,
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
            "Crush of Eminence",     -- Level 129
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
            "Crush of the Crying Seas X", -- Level 127
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
            "Brilliant Expurgation",  -- Level 130
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
            "Unyielding Stance",
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
            "Preservation of Quellious",    -- Level 130
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
            "Denouncement IX",
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
            "Committal",    -- Level 126
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
            "Rejuvenating Steel VII",
            "Restoring Steel",
            "Regenerating Steel",
            "Rejuvenating Steel",
            "Reinvigorating Steel",
            "Revitalizating Steel",
            "Renewing Steel",
        },
        ["FuryProc"] = {
            "Eminent Fury",   -- Level 130
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
            "Aurora of Sunlight XI",
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
            "Force of Akera XV",          -- Level 130
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
            "Eminent Force",   -- Level 126
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
        ["Healstun"] = {
            --- Heal Stuns T3 12s recast
            "Force of Eminence",   -- Level 129
            "Force of the Avowed", --Level 124
            "Force of Generosity",
            "Force of Reverence",
            "Force of Ardency",
            "Force of Mercy",
            "Force of Sincerity",
        },
        ["Healward"] = {
            --- Healing ward Heals Target of target and wards self. Divination based heal/ward
            "Protective Confession X",
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
            "Hand of Austerity XVII",        -- Level 127 - Group
            "Courage",                       -- Level 8
            "Center",                        -- Level 20
            "Daring",                        -- Level 37
            "Valor",                         -- Level 47
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
            "Brell's Mountainous Barrior XVI",
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
            "Splash of Eminence",
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
            "Unquestioned Affirmation",
            "Unconditional Affirmation",
            "Unending Affirmation",
            "Unrelenting Affirmation",
            "Undivided Affirmation",
            "Unbroken Affirmation",
            "Unflinching Affirmation",
            "Unyielding Affirmation",
        },
        ["WaveHeal"] = {
            --- Group Wave heal 39-124
            "Wave of Inspiriation",
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
            "Wave of Inspiriation",
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
            "Penitence IX",
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
            "Mark of Sharash",
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
            "Burst of Sunlight XII",
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
            "Armor of Unyielding Faith",  -- Level 128
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
            "Armor of Heroic Faith",      -- Level 123
        },
        ["Righteousstrike"] = {
            "Righteous Indignation VIII",
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
            "Lesson of Penitence XV",         -- Level 127
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
            "Impassioned Audacity",
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
            "Eminent Light",   -- Level 127
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
        ["TouchHeal"] = {
            --- Touch Heal Line LVL61
            "Eminent Touch",
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
        ["PurityCure"] = {
            --- Purity Cure Poison/Diease Cure Half Power to curse
            "Mastery: Balanced Purity",
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
            "Duel for Honor",
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
        ["aurabuff1"] = {
            -- Aura Buffs
            "Blessed Aura",
            "Holy Aura",
        },
        ["AntiUndeadNuke"] = {
            -- Undead Nuke
            "Doctrine of Revocation",  -- Level 128
            "Doctrine of Repudiation", -- Level 121
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
        ["CureCurse"] = {
            -- Curse Cure Line
            "Remove Minor Curse",
            "Remove Lesser Curse",
            "Remove Curse",
            "Remove Greater Curse",
        },
        ['CureCorrupt'] = {
            "Mastery: Consecrate",
        },
        ["endregen"] = {
            -- Fast Endurance regen - Update to new Format Once tested
            "Hiatus V",
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
        ["meleemit"] = {
            -- Withstand Combat Line of Defense - Update to format once tested
            "Impede",
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
        ["Armordisc"] = {
            --- Armor Timer 11
            "Armor of Eminence",
            "Armor of Avowal",
            "Armor of the Forthright",
            "Armor of Sincerity",
            "Armor of Mercy",
            "Armor of Ardency",
            "Armor of Reverence",
            "Armor of Zeal",
        },
        ["Holyforge"] = {
            "Holyforge Discipline",
        },
        ["Pureforge"] = {
            "Pureforge Discipline",
        },
        ["Pentientarmor"] = {
            -- Pentient Armor Discipline
            "Avowed Penitence",
            "Fervent Penitence",
            "Reverent Penitence",
            "Devout Penitence",
            "Merciful Penitence",
            "Sincere Penitence",
        },
        ["Mantle"] = {
            ---Mantle Line of Discipline Timer 5 defensive burn
            "Mantle of Eminence",
            "Mantle of the Remembered",
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
            "Holy Guardian Discipline IV",
            "Revered Guardian Discipline",
            "Blessed Guardian Discipline",
            "Holy Guardian Discipline",
        },
        ["Spellblock"] = {
            "Sanctification Discipline",
        },
        ["Reflexstrike"] = {
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
        -- helper function for advanced logic to see if we want to use Divine Protector's Unity
        castDPU = function(self)
            if not mq.TLO.Me.AltAbility("Divine Protector's Unity")() then return false end
            local furyProcLevel = Core.GetResolvedActionMapItem('FuryProc') and Core.GetResolvedActionMapItem('FuryProc').Level() or 0
            local DPULevel = mq.TLO.Spell(mq.TLO.Me.AltAbility("Divine Protector's Unity").Spell.Trigger(1).BaseName()).Level() or 0

            return furyProcLevel <= DPULevel
        end,
        --Did not include Staff of Forbidden Rites, GoR refresh is very fast and rez is 96%
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
    },
    ['HealRotationOrder'] = {
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ["GroupHealPoint"] = {
            {
                name = "Gift of Life",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "Hand of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "WaveHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SpellLoaded(spell)
                end,
            },
            {
                name = "Aurora",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SpellLoaded(spell)
                end,
            },
            {
                name = "WaveHeal2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SpellLoaded(spell)
                end,
            },
        },
        ["MainHealPoint"] = {
            {
                name = "Lay on Hands",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.GetTargetPctHPs() < Config:GetSetting('LayHandsPct')
                end,
            },
            {
                name = "Hand of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.BigHealsNeeded(target) and Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "LightHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SpellLoaded(spell)
                end,
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
                    Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Casting.GetBuffableIDs() end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 2,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck()
            end,
        },
        {
            name = 'Tank DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.IsModeActive("Tank")
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.IsModeActive("DPS")
            end,
        },
    },
    ['Rotations']         = {
        ['Burn'] = {
            {
                name = "Spire of Chivalry",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.Level() < 80 and not Casting.IHaveBuff("Armor of the Inquisitor") and not Casting.IHaveBuff("Spire of Chivalry")
                end,
            },
            {
                name = "Valorous Rage",
                type = "AA",
            },
            {
                name = "Inquisitor's Judgment",
                type = "AA",
            },
            {
                name = "Thunder of Karana",
                type = "AA",
            },
            {
                name = "Group Armor of The Inquisitor",
                type = "AA",
            },
            {
                name = "Holyforge",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Casting.NoDiscActive() and Targeting.TargetBodyIs(target, "Undead")
                end,
            },
            {
                name = "Pureforge",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Righteousstrike",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Healproc",
                type = "Spell",
                cond = function(self, spell)
                    return not Core.IsTanking()
                end,
            },
        },
        ['Tank DPS'] = {
            {
                name = "ActivateShield",
                type = "CustomFunc",
                cond = function(self)
                    return Config:GetSetting('DoBandolier') and not mq.TLO.Me.Bandolier("Shield").Active() and
                        mq.TLO.Me.Bandolier("Shield").Index() and Core.IsTanking()
                end,
                custom_func = function(_)
                    Core.DoCmd("/bandolier activate Shield")
                    return true
                end,

            },
            {
                name = "Activate2HS",
                type = "CustomFunc",
                cond = function(self)
                    return Config:GetSetting('DoBandolier') and not mq.TLO.Me.Bandolier("2HS").Active() and
                        mq.TLO.Me.Bandolier("2HS").Index() and not Core.IsTanking()
                end,
                custom_func = function(_)
                    Core.DoCmd("/bandolier activate 2HS")
                    return true
                end,
            },
            {
                name = "Shield Flash",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() < Config:GetSetting('FlashHP')
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Core.IsModeActive('Tank') and
                        (mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2 or Globals.AutoTargetIsNamed) and Casting.NoDiscActive()
                end,
            },
            {
                name = "Holyguard",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Core.IsModeActive('Tank') and
                        (mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2 or Globals.AutoTargetIsNamed) and Casting.NoDiscActive()
                end,
            },
            {
                name = "Armordisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Core.IsModeActive('Tank') and
                        (mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2 or Globals.AutoTargetIsNamed) and Casting.NoDiscActive()
                end,
            },
            {
                name = "Pentientarmor",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Core.IsModeActive('Tank') and
                        (mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2 or Globals.AutoTargetIsNamed) and Casting.NoDiscActive()
                end,
            },
            {
                name = "meleemit",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return not ((discSpell.Level() or 0) < 108 and mq.TLO.Me.ActiveDisc.ID())
                end,
            },
            {
                name = "TotLightHeal",
                type = "Spell",
                cond = function(self, spell)
                    return (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < Config:GetSetting('TotHealPoint')
                end,
            },
            {
                name = "BurstHeal",
                type = "Spell",
                cond = function(self, spell)
                    return (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < Config:GetSetting('TotHealPoint')
                end,
            },
            {
                name = "Hallowed Lodestar",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.GetXTHaterCount() > 2
                end,
            },
            {
                name = "Beacon of the Righteous",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.GetXTHaterCount() > 2
                end,
            },
            {
                name = "Heroic Leap",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.GetXTHaterCount() > 2
                end,
            },
            {
                name = "Force of Disruption",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.AltAbility(aaName).Rank() or 0) > 7 and not Casting.IHaveBuff("Knight's Yaulp") and
                        Targeting.GetTargetDistance() < 30
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
                name = "Bash",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Core.ShieldEquipped() or Casting.CanUseAA("2 Hand Bash")
                end,
            },
            {
                name = "Disarm",
                type = "Ability",
            },
            {
                name = "Challengetaunt",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "StunTimer4",
                type = "Spell",
            },
            {
                name = "StunTimer5",
                type = "Spell",
            },
            {
                name = "LessonStun",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "CrushTimer5",
                type = "Spell",
            },
            {
                name = "CrushTimer6",
                type = "Spell",
            },
            {
                name = "Armor of the Inquisitor",
                type = "AA",
            },
            {
                name = "Healtaunt",
                type = "Spell",
            },
            {
                name = "HealNuke",
                type = "Spell",
            },
            {
                name = "Lowaggronuke",
                type = "Spell",
            },
            {
                name = "Dicho",
                type = "Spell",
            },
            {
                name = "AntiUndeadNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Targeting.TargetBodyIs(mq.TLO.Target, "Undead")
                end,
            },
            {
                name = "Vanquish The Fallen",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.TargetBodyIs(mq.TLO.Target, "Undead")
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
        },
        ['DPS'] = {
            {
                name = "Bash",
                type = "Ability",
            },
            {
                name = "Disarm",
                type = "Ability",
            },
            {
                name = "Marr's Gift",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() <= 60
                end,
            },
            {
                name = "Dicho",
                type = "Spell",
                cond = function(self, spell)
                    return (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) <= 35
                end,
            },
            {
                name = "TotLightHeal",
                type = "Spell",
                cond = function(self, spell)
                    return (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < Config:GetSetting('TotHealPoint')
                end,
            },
            {
                name = "BurstHeal",
                type = "Spell",
                cond = function(self, spell)
                    return (mq.TLO.Me.TargetOfTarget.PctHPs() or 0) < Config:GetSetting('TotHealPoint')
                end,
            },
            {
                name = "DebuffNuke",
                type = "Spell",
                cond = function(self, spell)
                    return ((Targeting.TargetBodyIs(mq.TLO.Target, "Undead") or mq.TLO.Me.Level() >= 96) and not Casting.TargetHasBuff(spell) and Config:GetSetting('DoNuke'))
                end,
            },
            {
                name = "AntiUndeadNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Targeting.TargetBodyIs(mq.TLO.Target, "Undead")
                end,
            },
            {
                name = "Reverseds",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.TargetHasBuff(spell) and Config:GetSetting('DoReverseDS')
                end,
            },
            {
                name = "Lowaggronuke",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoNuke')
                end,
            },
            {
                name = "CrushTimer6",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoNuke') and (mq.TLO.Me.SecondaryPctAggro() or 0) > 60
                end,
            },
            {
                name = "HealNuke",
                type = "Spell",
            },
            {
                name = "Vanquish The Fallen",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.TargetBodyIs(mq.TLO.Target, "Undead")
                end,
            },
            {
                name = "Disruptive Persecution",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.AltAbility(aaName).Rank() or 0) >= 3 and not Casting.IHaveBuff("Knight's Yaulp")
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
        },
        ['Downtime'] = {
            {
                name = "aurabuff1",
                type = "Spell",
                cond = function(self, spell)
                    return not Casting.AuraActiveByName(spell.RankName.Name()) and mq.TLO.Me.PctEndurance() > 10
                end,
            },
            {
                name = "Divine Protector's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName) and self.ClassConfig.HelperFunctions.castDPU(self)
                end,
            },
            {
                name = "ArmorSelfBuff",
                type = "Spell",
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDPU(self) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "FuryProc",
                type = "Spell",
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDPU(self) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "UndeadProc",
                type = "Spell",
                cond = function(self, spell) --use this always until we have a Fury proc, and optionally after that, up until the point that Fury is rolled into DPU
                    if (mq.TLO.Me.AltAbility("Divine Protector's Unity").Rank() or 0) > 1 or (self:GetResolvedActionMapItem("FuryProc") and not Config:GetSetting('DoUndeadProc')) then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Remorse",
                type = "Spell",
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDPU(self) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Piety",
                type = "Spell",
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDPU(self) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Preservation",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Core.IsModeActive("Tank")
                end,
            },
            {
                name = "TempHP",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Core.IsModeActive("Tank")
                end,
            },
            {
                name = "Incoming",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Core.IsModeActive("Tank")
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Brells",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) and Config:GetSetting('DoBrells') end,
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
                { name = "Lowaggronuke", cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "CrushTimer5", },
                { name = "StunTimer4", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "HealNuke",    cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "LessonStun",  cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "Healtaunt", },
                { name = "LessonStun", },
                { name = "CrushTimer5", },
                { name = "StunTimer5", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "AntiUndeadNuke", cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "Lowaggronuke", },
                { name = "CrushTimer6", },
                { name = "LessonStun", },
                { name = "WaveHeal", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "WaveHeal",       cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "HealNuke", },
                { name = "AntiUndeadNuke", },
                { name = "TotLightHeal", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "TotLightHeal", cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "WaveHeal2", },
                { name = "BurstHeal", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "BurstHeal",    cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "TotLightHeal", },
                { name = "Preservation", },
                { name = "LightHeal", },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "Reverseds", cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "BurstHeal", },
                { name = "TempHP", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DebuffNuke",     cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "Challengetaunt", },
                { name = "Healward", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Healproc", cond = function(self) return Core.IsModeActive('DPS') end, },
                { name = "TempHP", },
                { name = "HealNuke", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Aurora",         cond = function(self) return Core.IsModeActive('DPS') end, },
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
            id = 'Challengetaunt',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('Challengetaunt').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('Challengetaunt').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('Challengetaunt')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
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
            id = 'StunTimer5',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('StunTimer5')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('StunTimer5')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('StunTimer5')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = {
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
            Answer = "Tank Mode will focus on tanking and DPS Mode will focus on DPS.",
        },
        ['DoNuke']       = {
            DisplayName = "Cast Spells",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Tooltip = "Use Spells",
            Default = true,
        },
        ['DoUndeadProc'] = {
            DisplayName = "Use Undead Proc",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Use Undead proc over Fury proc until Fury is rolled into Divine Protector's Unity (Level 80).",
            Default = false,
        },
        ['FlashHP']      = {
            DisplayName = "Use Shield Flash",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Tooltip = "Your HP % before we use Shield Flash.",
            Default = 35,
            Min = 1,
            Max = 100,
        },
        ['TotHealPoint'] = {
            DisplayName = "ToT HealPoint",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Healing Thresholds",
            Tooltip = "HP % before we use Target of Target heals.",
            Default = 30,
            Min = 1,
            Max = 100,
        },
        ['LayHandsPct']  = {
            DisplayName = "Use Lay on Hands",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Healing Thresholds",
            Tooltip = "HP % before we use Lay on Hands.",
            Default = 35,
            Min = 1,
            Max = 100,
        },
        ['DoChestClick'] = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Tooltip = "Click your chest item",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
        },
        ['DoReverseDS']  = {
            DisplayName = "Do Reverse DS",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Cast Reverse DS",
            Default = true,
        },
        ['DoBrells']     = {
            DisplayName = "Do Brells",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Enable Casting Brells",
            Default = true,
        },
        ['AegoSymbol']   = {
            DisplayName = "Aego/Symbol Choice:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Choose whether to use the Aegolism or Symbol Line of HP Buffs.",
            Type = "Combo",
            ComboOptions = { 'Aegolism Line (Keeper)', 'Symbol Line', 'None', },
            Default = 1,
            Min = 1,
            Max = 3,
        },
        ['DoSalvation']  = {
            DisplayName = "Marr's Salvation",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Use your group hatred reduction buff AA.",
            Default = false,
        },
        ['DoBandolier']  = {
            DisplayName = "Use Bandolier",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Tooltip = "Enable Swapping of items using the bandolier.",
            Default = false,
        },
    },
    ['ClassFAQ']          = {
        {
            Question = "What is the current status of this class config?",
            Answer = "This class config is a current release aimed at official servers.\n\n" ..
                "  This config is largely a port from older code, and has seen only minor adjustments. It has been flagged for revamp when we have the chance!\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}
