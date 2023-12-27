return {
    ['Modes'] = {
        [1] = 'Tank',
        [2] = 'DPS',
        [3] = 'Healer',
        [4] = 'Hybrid',
    },
    ['ItemSets'] = {
        ['Epic'] = {
            [1] = "Nightbane, Sword of the Valiant",
            [2] = "Redemption",
        },
    },
    ['AbilitySets'] = {
        ["CrushTimer6"] = {
            -- Timer 6 - Crush (with damage)
            [1] = "Crush of Compunction",    -- Level 85
            [2] = "Crush of Repentance",    -- Level 90
            [3] = "Crush of Tides",     -- Level 95
            [4] = "Crush of Tarew",     -- Level 100
            [5] = "Crush of Povar",     -- Level 105
            [6] = "Crush of E'Ci",     -- Level 110
            [7] = "Crush of Restless Ice",    -- Level 115
            [8] = "Crush of the Umbra",     -- Level 120
        },
        ["CrushTimer5"] = {
            -- Timer 5 - Crush
            [1] = "Crush of the Crying Seas",     -- Level 82
            [2] = "Crush of Marr",     -- Level 87
            [3] = "Crush of Oseka",     -- Level 92
            [4] = "Crush of the Iceclad",     -- Level 97
            [5] = "Crush of the Darkened Sea",     -- Level 102
            [6] = "Crush of the Timorous Deep",     -- Level 107
            [7] = "Crush of the Grotto",     -- Level 112
            [8] = "Crush of the Twilight Sea",     -- Level 117
        },
        ["HealNuke"] = {
            -- Timer 7 - HealNuke
            [1] = "Glorious Vindication",    -- Level 85
            [2] = "Glorious Exoneration",    -- Level 90
            [3] = "Glorious Exculpation",    -- Level 95
            [4] = "Glorious Expurgation",    -- Level 100
            [5] = "Brilliant Vindication",    -- Level 105
            [6] = "Brilliant Exoneration",    -- Level 110
            [7] = "Brilliant Exculpation",    -- Level 115
            [8] = "Brilliant Acquittal",    -- Level 120
        },
        ["TempHP"] =  {
            [1] = "Steely Stance",
            [2] = "Stubborn Stance",
            [3] = "Stoic Stance",
            [4] = "Staunch Stance",
            [5] = "Steadfast Stance",
            [6] = "Defiant Stance",
            [7] = "Stormwall Stance",
            [8] = "Adamant Stance",
        },
        ["Preservation"] = {
            -- Timer 12 - Preservation
            [1] = "Ward of Tunare",   -- Level 70
            [2] = "Sustenance of Tunare",   -- Level 80
            [3] = "Preservation of Tunare",   -- Level 85
            [4] = "Preservation of Marr",   -- Level 90
            [5] = "Preservation of Oseka",   -- Level 95
            [6] = "Preservation of the Iceclad",   -- Level 100
            [7] = "Preservation of Rodcet",   -- Level 110
            [8] = "Preservation of the Grotto",   -- Level 115
            [9] = "Preservation of the Basilica",   -- Level 120
        },
        ["Lowaggronuke"] = {
            --- Nuke Heal Target - Censure
            [1] = "Denouncement",
            [2] = "Reprimand",
            [3] = "Ostracize",
            [4] = "Admonish",
            [5] = "Censure",
            [6] = "Remonstrate",
            [7] = "Upbraid",
        },
        ["Incoming"] = {
            -- Harmonius Blessing - Empires of Kunark spell
            [1] = "Harmonious Blessing",
            [2] = "Concordant Blessing",
            [3] = "Confluent Blessing",
            [4] = "Penumbral Blessing",
        },
        ["DebuffNuke"] = {
            -- Undead DebuffNuke
            [1] = "Last Rites",  -- Level 68 - Timer 7
            [2] = "Burial Rites",  -- Level 71 - Timer 7
            [3] = "Benediction",  -- Level 76
            [4] = "Eulogy",  -- Level 81
            [5] = "Elegy",  -- Level 86
            [6] = "Paean",  -- Level 91
            [7] = "Laudation",  -- Level 96
            [8] = "Consecration",  -- Level 101
            [9] = "Remembrance",  -- Level 106
            [10] = "Requiem",  -- Level 111
            [11] = "Hymnal",  -- Level 116
        },
        ["Healproc"] = {
            --- Proc Buff Heal target of Target => LVL 97
            [1] = "Regenerating Steel",
            [2] = "Rejuvenating Steel",
            [3] = "Reinvigorating Steel",
            [4] = "Revitalizating Steel",
            [5] = "Renewing Steel",
        },
        ["FuryProc"] = {
            -- - Fury Proc Strike  67 - 115
            [1] = "Wrathful Fury",
            [2] = "Silvered Fury",
            [3] = "Pious Fury",
            [4] = "Righteous Fury",
            [5] = "Devout Fury",
            [6] = "Earnest Fury",
            [7] = "Zealous Fury",
            [8] = "Reverent Fury",
            [9] = "Ardent Fury",
            [10] = "Merciful Fury",
            [11] = "Sincere Fury",
        },
        ["Aurora"] = {
            [1] = "Aurora of Dawning",
            [2] = "Aurora of Dawnlight",
            [3] = "Aurora of Daybreak",
            [4] = "Aurora of Splendor",
            [5] = "Aurora of Sunrise",
            [6] = "Aurora of Dayspring",
            [7] = "Aurora of Morninglight",
            [8] = "Aurora of Wakening",
        },
        ["StunTimer5"] = {
            -- Timer 5 - Hate Stun
            [1] = "Desist",    -- Level 13 - Not Timer 5, use for TLP Low Level Stun
            [2] = "Stun" ,    -- Level 28
            [3] = "Force of Akera",    -- Level 53
            [4] = "Ancient: Force of Chaos",    -- Level 65
            [5] = "Ancient: Force of Jeron",    -- Level 70
            [6] = "Force of Prexus",    -- Level 75
            [7] = "Force of Timorous",    -- Level 80
            [8] = "Force of the Crying Seas",    -- Level 85
            [9] = "Force of Marr",    -- Level 90
            [10] = "Force of Oseka",    -- Level 95
            [11] = "Force of the Iceclad",    -- Level 100
            [12] = "Force of the Darkened Sea" ,    -- Level 105
            [13] = "Force of the Timorous Deep",    -- Level 110
            [14] = "Force of the Grotto",    -- Level 115
            [15] = "Force of the Umbra",    -- Level 120
        },
        ["StunTimer4"] = {
            -- Timer 4 - Hate Stun
            [1] = "Cease",  -- Level 7 - Not Timer 4, use for TLP Low Level Stun
            [2] = "Force of Akilae",   -- Level 62
            [3] = "Force of Piety",   -- Level 66
            [4] = "Sacred Force",  -- Level 71
            [5] = "Devout Force",  -- Level 81
            [6] = "Solemn Force",  -- Level 83
            [7] = "Earnest Force",   -- Level 86
            [8] = "Zealous Force",   -- Level 91
            [9] = "Reverent Force",   -- Level 96
            [0] = "Ardent Force",  -- Level 101
            [10] = "Merciful Force",   -- Level 106
            [11] = "Sincere Force",   -- Level 111
            [12] = "Pious Force",  -- Level 116
        },
        ["Healstun"] = {
            --- Heal Stuns T3 12s recast
            [1] = "Force of Generosity",
            [2] = "Force of Reverence",
            [3] = "Force of Ardency",
            [4] = "Force of Mercy",
            [5] = "Force of Sincerity",
        },
        ["Healward"] = {
            --- Healing ward Heals Target of target and wards self. Divination based heal/ward
            [1] = "Protective Revelation",
            [2] = "Protective Confession",
            [3] = "Protective Devotion",
            [4] = "Protective Dedication",
            [5] = "Protective Allegiance",
            [6] = "Protective Proclamation",
            [7] = "Protective Devotion",
            [8] = "Protective Consecration",
        },
        ["Aego"] = {
            --- Pally Aegolism
            [1] = "Austerity",   -- Level 55
            [2] = "Blessing of Austerity",   -- Level 58 - Group
            [3] = "Guidance",   -- Level 65
            [4] = "Affirmation",   -- Level 70
            [5] = "Sworn Protector",   -- Level 75
            [6] = "Oathbound Protector",   -- Level 80
            [7] = "Sworn Keeper",   -- Level 85
            [8] = "Oathbound Keeper",   -- Level 90
            [9] = "Avowed Keeper",   -- Level 92
            [10] = "Hand of the Avowed Keeper",   -- Level 95 - Group
            [11] = "Pledged Keeper",   -- Level 97
            [12] = "Hand of the Pledged Keeper",   -- Level 100 - Group
            [13] = "Stormbound Keeper",   -- Level 102
            [14] = "Hand of the Stormbound Keeper",    -- Level 105 - Group
            [15] = "Ashbound Keeper",   -- Level 107
            [16] = "Hand of the Ashbound Keeper",   -- Level 110 - Group
            [17] = "Stormwall Keeper",   -- Level 112
            [18] = "Hand of the Stormwall Keeper",    -- Level 115 - Group
            [19] = "Shadewell Keeper",   -- Level 117
            [20] = "Hand of the Dreaming Keeper",   -- Level 120 - Group
        },
        ["Brells"] = {
            [1] = "Brell's Tenacious Barrier",
            [2] = "Brell's Loamy Ward",
            [3] = "Brell's Tellurian Rampart",
            [4] = "Brell's Adamantine Armor",
            [5] = "Brell's Steadfast Bulwark",
            [6] = "Brell's Stalwart Bulwark",
            [7] = "Brell's Blessed Bastion",
            [8] = "Brell's Blessed Barrier",
            [9] = "Brell's Earthen Aegis",
            [10] = "Brell's Stony Guard",
            [11] = "Brell's Brawny Bulwark",
            [12] = "Brell's Stalwart Shield",
            [13] = "Brell's Mountainous Barrier",
            [14] = "Brell's Steadfast Aegis",
        },
        ["Splashcure"] = {
            ---, Spells
            [1] = "Splash of Repentance",
            [2] = "Splash of Sanctification",
            [3] = "Splash of Purification",
            [4] = "Splash of Cleansing",
            [5] = "Splash of Atonement",
            [6] = "Splash of Depuration",
            [7] = "Splash of Exaltation",
        },
        ["Healtaunt"] = {
            --- Valiant Taunt With Built in heal.
            [1] = "Valiant Disruption",
            [2] = "Valiant Deflection",
            [3] = "Valiant Defense",
            [4] = "Valiant Diversion",
            [5] = "Valiant Deterrence",
        },
        ["Affirmation"] = {
            --- Improved Super Taunt - Gets you Aggro for X seconds and reduces other Haters generation.
            [1] = "Unrelenting Affirmation",
            [2] = "Undivided Affirmation",
            [3] = "Unbroken Affirmation",
            [4] = "Unflinching Affirmation",
            [5] = "Unyielding Affirmation",
            [6] = "Unending Affirmation",
        },
        ["Doctrine"] = {
            --- Undead DD 
            [1] = "Doctrine of Abrogation",
            [2] = "Doctrine of Rescission",
            [3] = "Doctrine of Exculpation",
            [4] = "Doctrine of Abolishment",
        },
        ["WaveHeal"] = {
            --- Group Wave heal 39-115
            [1] = "Wave of Bereavement",
            [2] = "Wave of Propitiation",
            [3] = "Wave of Expiation",
            [4] = "Wave of Grief",
            [5] = "Wave of Sorrow",
            [6] = "Wave of Contrition",
            [7] = "Wave of Penitence",
            [8] = "Wave of Remitment",
            [9] = "Wave of Absolution",
            [10] = "Wave of Forgiveness",
            [11] = "Wave of Piety",
            [12] = "Wave of Marr",
            [13] = "Wave of Trushar",
            [14] = "Healing Wave of Prexus",
            [15] = "Wave of Healing",
            [16] = "Wave of Life",
        },
        ["Selfheal"] = {
            [1] = "Penitence",
            [2] = "Contrition",
            [3] = "Sorrow",
            [4] = "Grief",
            [5] = "Exaltation",
            [6] = "Propitiation",
            [7] = "Culpability",
        },
        ["Reverseds"] = {
            --- Reverse DS
            [1] = "Mark of the Saint",
            [2] = "Mark of the Crusader",
            [3] = "Mark of the Pious",
            [4] = "Mark of the Pure",
            [5] = "Mark of the Defender",
            [6] = "Mark of the Reverent",
            [7] = "Mark of the Exemplar",
            [8] = "Mark of the Commander",
            [9] = "Mark of the Jade Cohort",
            [10] = "Mark of the Eclipsed Cohort",
        },
        ["Cleansehot"] = {
            --- Pally Hot
            [1] = "Ethereal Cleansing",  -- Level 44
            [2] = "Celestial Cleansing",  -- Level 59
            [3] = "Supernal Cleansing",  -- Level 64
            [4] =  "Pious Cleansing",  -- Level 69
            [5] = "Sacred Cleansing",  -- Level 73
            [6] = "Solemn Cleansing",  -- Level 78
            [7] = "Devout Cleansing",  -- Level 93
            [8] = "Earnest Cleansing",  -- Level 88
            [9] = "Zealous Cleansing",  -- Level 93
            [0] = "Reverent Cleansing",  -- Level 98
            [10] = "Ardent Cleansing",  -- Level 103
            [11] = "Merciful Cleansing",  -- Level 108
            [12] = "Sincere Cleansing",  -- Level 113
            [13] = "Forthright Cleansing",  -- Level 118
        },
        ["BurstHeal"] = {
            --- Burst Heal - heals target or Target of target 73-115   
            [1] = "Burst of Sunlight",
            [2] = "Burst of Morrow",
            [3] = "Burst of Dawnlight",
            [4] = "Burst of Daybreak",
            [5] = "Burst of Splendor",
            [6] = "Burst of Sunrise",
            [7] = "Burst of Dayspring",
            [8] = "Burst of Morninglight",
            [9] = "Burst of Wakening",
            [10] = "Burst of Dawnbreak",
        },
        ["ArmorSelfBuff"] = {
            --- Self Buff Armor Line Ac/Hp/Mana regen
            [1] = "Aura of the Crusader",  -- Level 64
            [2] = "Armor of the Champion",  -- Level 69
            [3] = "Armor of Unrelenting Faith",  -- Level 73
            [4] = "Armor of Inexorable Faith",  -- Level 78
            [5] = "Armor of Unwavering Faith",  -- Level 83
            [6] = "Armor of Implacable Faith",  -- Level 88
            [7] = "Armor of Formidable Faith",  -- Level 93
            [8] = "Armor of Formidable Grace",  -- Level 98
            [9] = "Armor of Formidable Spirit",  -- Level 103
            [10] = "Armor of Steadfast Faith",  -- Level 108
            [11] = "Armor of Steadfast Grace",  -- Level 113
            [12] = "Armor of Unyielding Grace",  -- Level 118
        },
        ["Righteousstrike"] = {
            --- Righteous Strikes Line 
            [1] = "Righteous Antipathy",
            [2] = "Righteous Fury",
            [3] = "Righteous Indignation",
            [4] = "Righteous Vexation",
            [5] = "Righteous Umbrage",
            [6] = "Righteous Condemnation",
            [7] = "Righteous Antipathy",
        },
        ["Symbol"] = {
            [1] = "Symbol of Liako",
            [2] = "Symbol of Jeneca",
            [3] = "Symbol of Jyleel",
            [4] = "Symbol of Erillion",
            [5] = "Symbol of Burim",
            [6] = "Symbol of Niparson",
            [7] = "Symbol of Teralov",
            [8] = "Symbol of Sevalak",
            [9] = "Symbol of Bthur",
            [10] = "Symbol of Jeron",
            [11] = "Symbol of Marzin",
            [12] = "Symbol of Naltron",
            [13] = "Symbol of Pinzarn",
            [14] = "Symbol of Ryltan",
            [15] = "Symbol of Transal",
        },
        ["LessonStun"] = {
            --- Lesson Stun - Timer 6
            [1] = "Quellious' Word of Tranquility",  -- Level 54
            [2] = "Quellious' Word of Serenity",  -- Level 64
            [3] = "Serene Command",  -- Level 68
            [4] = "Lesson of Penitence",  -- Level 72
            [5] = "Lesson of Contrition",  -- Level 77
            [6] = "Lesson of Compunction",  -- Level 82
            [7] = "Lesson of Repentance",  -- Level 87
            [8] = "Lesson of Remorse",  -- Level 92
            [9] = "Lesson of Sorrow",  -- Level 97
            [10] = "Lesson of Grief",  -- Level 102
            [11] = "Lesson of Expiation",  -- Level 107
            [12] = "Lesson of Propitiation",  -- Level 112
            [13] = "Lesson of Guilt",  -- Level 117
        },
        ["Audacity"] = {
            -- Hate magic Debuff Over time
            [1] = "Ardent,",
            [2] = "Fervent,",
            [3] = "Sanctimonious,",
            [4] = "Devout,",
            [5] = "Righteous,",
        },
        ["LightHeal"] = {
            -- Target Light Heal
            [1] = "Salve",    -- Level 1
            [2] = "Minor Healing",    -- Level 6
            [3] = "Light Healing",    -- Level 12
            [4] = "Healing",    -- Level 27
            [5] = "Greater Healing",    -- Level 36
            [6] = "Superior Healing",    -- Level 48
        },
        ["TotLightHeal"] = {
            -- ToT Light Heal
            [1] = "Light of Life",    -- Level 52
            [2] = "Light of Nife",    -- Level 63
            [3] = "Light of Order",    -- Level 65
            [4] = "Light of Piety",    -- Level 68
            [5] = "Gleaming Light",    -- Level 72
            [6] = "Radiant Light",    -- Level 77
            [7] = "Shining Light",    -- Level 82
            [8] = "Joyous Light",    -- Level 87
            [9] = "Brilliant Light",    -- Level 92
            [10] = "Dazzling Light",    -- Level 97
            [11] = "Blessed Light",    -- Level 102
            [12] = "Merciful Light",    -- Level 107
            [13] = "Sincere Light",    -- Level 112
            [14] = "Raptured Light",    -- Level 117            
        },
        ["Pacify"] = {
            [1] = "Placating Words",
            [2] = "Tranquil Words",
            [3] = "Propitiate",
            [4] = "Mollify",
            [5] = "Reconcile",
            [6] = "Dulcify",
            [7] = "Soothe",
            [8] = "Pacify",
            [9] = "Calm",
            [10] = "Lull",
        },
        ["Toucheal"] = {
            --- Touch Heal Line LVL61 - LVL115
            [1] = "Touch of Nife",
            [2] = "Touch of Piety",
            [3] = "Sacred Touch",
            [4] = "Solemn Touch",
            [5] = "Devout Touch",
            [6] = "Earnest Touch",
            [7] = "Zealous Touch",
            [8] = "Reverent Touch",
            [9] = "Ardent Touch",
            [10] = "Merciful Touch",
            [11] = "Sincere Touch",
            [12] = "Soothing Touch",
        },
        ["Dicho"] = {
            --- Dissident Stun
            [1] = "Dichotomic Force",
            [2] = "Dissident Force",
            [3] = "Composite Force",
            [4] = "Ecliptic Force",
        },
        ["Puritycure"] = {
            --- Purity Cure Poison/Diease Cure Half Power to curse
            [1] = "Balanced Purity",
            [2] = "Devoted Purity",
            [3] = "Earnest Purity",
            [4] = "Zealous Purity",
            [5] = "Reverent Purity",
            [6] = "Ardent Purity",
            [7] = "Merciful Purity",
        },
        ["Challengetaunt"] = {
            --- Challenge Taunt Over time Debuff
            [1] = "Challenge for Honor",
            [2] = "Trial For Honor",
            [3] = "Charge for Honor",
            [4] = "Confrontation for Honor",
            [5] = "Provocation for Honor",
            [6] = "Demand for Honor",
            [7] = "Impose for Honor",
            [8] = "Refute for Honor",
            [9] = "Protest for Honor",
            [10] = "Parlay for Honor",
        },
        ["Piety"] = {
            -- One Off Buffs
            [1] = "Silent Piety",
        },
        ["Remorse"] = {
            -- Remorse
            [1] = "Remorse for the fallen",
            [2] = "Penitence for the Fallen",
        },
        ["aurabuff1"] = {
            -- Aura Buffs
            [1] = "Blessed Aura",
            [2] = "Holy Aura",
        },
        ["AntiUndeadNuke"] = {
            -- Undead Nuke
            [1] = "Ward Undead",  -- Level 14
            [2] = "Expulse Undead",  -- Level 30
            [3] = "Dismiss Undead",  -- Level 46
            [4] = "Expel Undead",  -- Level 54
            [5] = "Deny Undead",  -- Level 62 - Timer 7
            [6] = "Spurn Undead",  -- Level 67 - Timer 7            
            --[] = "Wraithguard's Vengeance",  -- Level 75 - Unobtainable?
            [7] = "Annihilate the Undead",  -- Level 86 - Res Debuff / Extra Damage
            [8] = "Abolish the Undead",  -- Level 91 - Res Debuff / Extra Damage
            [9] = "Doctrine of Abrogation",  -- Level 96
            [10] = "Abrogate the Undead",  -- Level 96 - Res Debuff / Extra Damage
            [11] = "Doctrine of Rescission",  -- Level 101
            [12] = "Doctrine of Exculpation",  -- Level 106
            [13] = "Doctrine of Abolishment",  -- Level 111
            [14] = "Doctrine of Annulment",  -- Level 116            
        },
        ["AllianceNuke"] = {
            -- Pally Alliance Spell
            [1] = "Holy Alliance",
            [2] = "Stormwall Coalition",
        },
        ["CurseCure"] = {
            -- Curse Cure Line
            [1] = "Remove Minor Curse",
            [2] = "Remove Lesser Curse",
            [3] = "Remove Curse",
            [4] = "Remove Greater Curse",
        },
        ["endregen"] = {
            -- Fast Endurance regen - Update to new Format Once tested
            [1] = "Second Wind",
            [2] = "Third Wind",
            [3] = "Fourth Wind",
            [4] = "Respite",
            [5] = "Reprieve",
            [6] = "Rest",
            [7] = "Breather",
            [8] = "Hiatus",
            [9] = "Relax",
            [10] = "Night's Calming",
        },
        ["meleemit"] = {
            -- Withstand Combat Line of Defense - Update to format once tested
            [1] = "Withstand",
            [2] = "Defy",
            [3] = "Renounce",
            [4] = "Reprove",
            [5] = "Repel",
            [6] = "Spurn",
            [7] = "Thwart",
            [8] = "Repudiate",
        },
        ["Armordisc"] = {
            --- Armor Timer 11 
            [1] = "Armor of the Forthright",
            [2] = "Armor of Sincerity",
            [3] = "Armor of Mercy",
            [4] = "Armor of Ardency",
            [5] = "Armor of Reverence",
            [6] = "Armor of Zeal",
        },
        ["Undeadburn"] = {
            [1] = "Holyforge Discipline",
        },
        ["Pentientarmor"] = {
            -- Pentient Armor Discipline
            [1] = "Fervent Penitence",
            [2] = "Reverent Penitence",
            [3] = "Devout Penitence",
            [4] = "Merciful Penitence",
            [5] = "Sincere Penitence",
        },
        ["Mantle"] = {
            ---Mantle Line of Discipline Timer 5 defensive burn
            [1] = "Supernal Mantle",
            [2] = "Mantle of the Sapphire Cohort",
            [3] = "Kar`Zok Mantle",
            [4] = "Skalber Mantle",
            [5] = "Brightwing Mantle",
            [6] = "Prominent Mantle",
            [7] = "Exalted Mantle",
            [8] = "Honorific Mantle",
            [9] = "Armor of Decorum",
            [10] = "Armor of Righteousness",
        },
        ["Holyguard"] = {
            -- Holy Guardian Discipline
            [1] = "Revered Guardian Discipline",
            [2] = "Blessed Guardian Discipline",
            [3] = "Holy Guardian Discipline",
    }   ,
        ["Spellblock"] = {
            [1] = "Sanctification Discipline",
        },
        ["Reflexstrike"] = {
            --- Reflexive Strike Heal
            [1] = "Reflexive Redemption",
            [2] = "Reflexive Righteousness",
            [3] = "Reflexive Reverence",
        },
    },
    ['Rotations'] = {
        ['Tank'] = {
            ["Available"] = 0,
            ['Combat'] = {},
            ['Downtime'] = {},
            ['Burn'] = {},
        },
        ['DPS'] = {
            ["Available"] = 1,
            ['Combat'] = {},
            ['Downtime'] = {},
            ['Burn'] = {},
        },
        ['Healer'] = { 
            ["Available"] = 0,
            ['Combat'] = {},
            ['Downtime'] = {},
            ['Burn'] = {},
        },
        ['Hybrid'] = { 
            ["Available"] = 0,
            ['Combat'] = {},
            ['Downtime'] = {},
            ['Burn'] = {},
        },
    },
    ['DefaultConfig'] = {
        ['Mode'] = '2',
    },
}



