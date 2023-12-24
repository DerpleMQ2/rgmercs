return {
    ['Modes'] = {
        ['Heal'] = 0,
        ['Battle'] = 1,
        ['TLP'] = 2,
    },
    ['ItemSets'] = {
        ['Epic'] = {
            [1] = "Harmony of the Soul",
            [2] = "Aegis of Superior Divinity",
            [3] = "Water Sprinkler of Nem Ankh",
        },
    },
    ['AbilitySets'] = {
        ['wardspell'] = {
            -----Ward Spell Slot 1 or Heal over time for low level 
            [1] = "Celestial Remedy",
            [2] = "Celestial Health",
            [3] = "Celestial Healing",
            [4] = "Celestial Elixir",
            [5] = "Supernal Elixir",
            [6] = "Holy Elixir",
            [7] = "Pious Elixir",
            [8] = "Sacred Elixir",
            [9] = "Solemn Elixir",
            [10] = "Devout Elixir",
            [11] = "Earnest Elixir",
            [12] = "Zealous Elixir",
            [13] = "Ward of Certitude",
            [14] = "Ward of Surety",
            [15] = "Ward of Assurance",
            [16] = "Ward of Righteousness",
            [17] = "Ward of Persistence",
            [18] = "Ward of Commitment",
        },
        ['remedyheal'] = {
            [1] = "]Minor Healing",
            [2] = "Light Healing",
            [3] = "Healing",
            [4] = "Greater Healing",
            [5] = "Celestial Health",
            [6] = "Superior Healing",
            [7] = "Remedy",
            [8] = "Ethereal Remedy",
            [9] = "Supernal Remedy",
            [10] = "Pious Remedy",
            [11] = "Sacred Remedy",
            [12] = "Solemn Remedy",
            [13] = "Devout Remedy",
            [14] = "Earnest Remedy",
            [15] = "Faithful Remedy",
            [16] = "Graceful Remedy",
            [17] = "Spiritual Remedy",
            [18] = "Merciful Remedy",
            [19] = "Sincere Remedy",
            [20] = "Guileless Remedy",
            [21] = "Avowed Remedy",
        },
        ['patchheal'] = {
            -----Patch Heals Slot 4 Dissident Blessing
            [1] = "Healing Light",
            [2] = "Divine Light",
            [3] = "Ethereal Light",
            [4] = "Supernal Light",
            [5] = "Holy Light",
            [6] = "Pious Light",
            [7] = "Ancient: Hallowed Light",
            [8] = "Sacred Light",
            [9] = "Solemn Light",
            [10] = "Devout Light",
            [11] = "Earnest Light",
            [12] = "Zealous Light",
            [13] = "Reverent Light",
            [14] = "Ardent Light",
            -- [] = "Merciful Light",
            -- [] = "Sincere Light",
            [15] = "Fervent Light",
            [16] = "Undying Life",
            [17] = "Dissident Blessing",
            [18] = "Composite Blessing",
            [19] = "Ecliptic Blessing",
        },
        ['groupfastheal'] = {
            -----Group Fast Heal 103+ Only
            [1] = "Syllable of Acceptance",
            [2] = "Syllable of Convalescence",
            [3] = "Syllable of Mending",
            [4] = "Syllable of Soothing",
            [5] = "Syllable of Invigoration",
        },
        ['groupheal'] = {
            -----Group Heals Slot 5 
            [1] = "Word of Health",
            [2] = "Word of Healing",
            [3] = "Word of Vigor",
            [4] = "Word of Restoration",
            -- 12 second Cast makes this Spell Unfeasible
            -- [] = "Word of Redemption",
            [5] = "Word of Replenishment",
            [6] = "Word of Vivification",
            [7] = "Word of Vivacity",
            [8] = "Word of Recovery",
            [9] = "Word of Resurgence",
            [10] = "Word of Rehabilitation",
            [11] = "Word of Reformation",
            [12] = "Word of Greater Reformation",
            [13] = "Word of Greater Restoration",
            [14] = "Word of Greater Replenishment",
            [15] = "Word of Greater Rejuvenation",
            [16] = "Word of Greater Vivification",
        },
        ['grouphealnocure'] = {
            -----Group Heals No Cure Slot 5
            [1] = "Word of Health",
            [2] = "Word of Healing",
            [3] = "Word of Vigor",
            [4] = "Word of Redemption",
            [5] = "Word of Awakening",
            [6] = "Word of Recuperation",
            [7] = "Word of Renewal",
            [8] = "Word of Convalescence",
            [9] = "Word of Mending",
            [10] = "Word of Soothing",
            [11] = "Word of Redress",
            [12] = "Word of Acceptance",
        },
        ['promheal'] = {
            -----Promised Heals
            [1] = "Promised Renewal",
            [2] = "Promised Restoration",
            [3] = "Promised Recuperation",
            [4] = "Promised Resurgence",
            [5] = "Promised Restitution",
            [6] = "Promised Reformation",
            [7] = "Promised Rehabilitation",
            [8] = "Promised Remedy",
            [9] = "Promised Redemption",
            [10] = "Promised Reclamation",
            [11] = "Promised Remediation",
        },
        ['bigheal'] = {
            -----Renewal Big Heal Lines
            [1] = "Desperate Renewal",
            [2] = "Frantic Renewal",
            [3] = "Frenetic Renewal",
            [4] = "Frenzied Renewal",
            [5] = "Fervent Renewal",
            [6] = "Fraught Renewal",
            [7] = "Furial Renewal",
            [8] = "Dire Renewal",
            [9] = "Determined Renewal",
            [10] = "Heroic Renewal",
        },  
        ['yaulpspell'] = {
            -----Yaulp Setup Pre-91 AA
            [1] = "Yaulp V",
            [2] = "Yaulp VI",
            [3] = "Yaulp VII",
            [4] = "Yaulp VIII",
            [5] = "Yaulp IX",
            [6] = "Yaulp X",
            [7] = "Yaulp XI",
        },
        ['stunnuke'] = {
            -----Stun Nukes - DISABLED Auto mem
            [1] = "Aweshake",
            [2] = "Awecrash",
            [3] = "Aweburst",
            [4] = "Aweclash",
            [5] = "Awecrush",
            [6] = "Awestrike",
            [7] = "Aweflash",
            [8] = "Aweblast",
            [9] = "Awebolt",
        },
        ['healnuke'] = {
            -- Heal Tank and Nuke Tanks Target -- Intervention Lines
            [1] = "Holy Intervention",
            [2] = "Celestial Intervention",
            [3] = "Elysian Intervention",
            [4] = "Virtuous Intervention",
            [5] = "Mystical Intervention",
            [6] = "Merciful Intervention",
            [7] = "Sincere Intervention",
            [8] = "Atoned Intervention",
            [9] = "Avowed Intervention",
        },
        ['nukeheal'] = {
            -- Nuke Target and Heal Tank -  Dps Heals
            [1] = "Holy Contravention",
            [2] = "Celestial Contravention",
            [3] = "Elysian Contravention",
            [4] = "Virtuous Contravention",
            [5] = "Ardent Contravention",
            [6] = "Merciful Contravention",
            [7] = "Sincere Contravention",
            [8] = "Divine Contravention",
            [9] = "Avowed Contravention",
        },
        ['ReverseDS'] = {
            -- Reverse Damage Shield Proc (LVL >=85) -- Ignoring the Mark Line
            [1] = "Erud's Retort",
            [2] = "Fintar's Retort",
            [3] = "Galvos' Retort",
            [4] = "Olsif's Retort",
            [5] = "Vicarum's Retort",
            [6] = "Curate's Retort",
            [7] = "Jorlleag's Retort",
            [8] = "Axoeviq's Retort",
        },
        ['SelfBuffhp'] = {
            ----Self Buff for Mana Regen and armor
            [1] = "Armor of Protection",
            [2] = "Blessed Armor of the Risen",
            [3] = "Ancient: High Priest's Bulwark",
            [4] = "Armor of the Zealot",
            [5] = "Armor of the Pious",
            [6] = "Armor of the Sacred",
            [7] = "Armor of the Solemn",
            [8] = "Armor of the Devout",
            [9] = "Armor of the Earnest",
            [10] = "Armor of the Zealous",
            [11] = "Armor of the Reverent",
            [12] = "Armor of the Ardent",
            [13] = "Armor of the Merciful",
            [14] = "Armor of Sincerity",
            [15] = "Armor of Penance",
            [16] = "Armor of the Avowed",
        },
        ['GroupHealProcBuff'] = {
            ----Self buff casts group heal on AE spell damage
            [1] = "Divine Consequence",
            [2] = "Divine Reaction",
            [3] = "Divine Response",
            [4] = "Divine Contingency",
        },
        ['AegoBuff'] = {
            ----Group Buff All Levels starts at 45 - Group Aego Buff
            [1] = "Courage",
            [2] = "Center",
            [3] = "Daring",
            [4] = "Bravery",
            [5] = "Valor",
            -- [] = "Resolution",
            [6] = "Temperance",
            [7] = "]Blessing of Temperance",
            -- [] = "Heroic Bond",
            [8] = "Blessing of Aegolism",
            [9] = "Hand of Virtue",
            [10] = "Hand of Conviction",
            [11] = "Hand of Tenacity",
            [12] = "Hand Of Temerity",
            [13] = "Hand of Gallantry",
            [14] = "Hand of Reliance",
            [15] = "Unified Hand of Credence",
            [16] = "Unified Hand of Certitude",
            [17] = "Unified Hand of Surety",
            [18] = "Unified Hand of Assurance",
            [19] = "Unified Hand of Righteousness",
            [20] = "Unified Hand of Persistence",
            [21] = "Unified Hand of Helmsbane",
        },
        ['TankBuff'] = {
            ----Tank Buff Traditionally Shining Series of Buffs
            [1] = "Holy Armor",
            [2] = "Spirit Armor",
            [3] = "Armor of Faith",
            [4] = "Shining Rampart",
            [5] = "Shining Armor",
            [6] = "Shining Bastion",
            [7] = "Shining Bulwark",
            [8] = "Shining Fortress",
            [9] = "Shining Aegis",
            [10] = "Shining Fortitude",
            [11] = "Shining Steel",
        },
        ['GroupVieBuff'] = {
            ----Group Vie Buff
            [1] = "Rallied Aegis of Vie",
            [2] = "Rallied Shield of Vie",
            [3] = "Rallied Palladium of Vie",
            [4] = "Rallied Rampart of Vie",
            [5] = "Rallied Armor of Vie",
            [6] = "Rallied Bastion of Vie",
            [7] = "Rallied Greater Ward of Vie",
            [8] = "Rallied Greater Guard of Vie",
            [9] = "Rallied Greater Protection of Vie",
            [10] = "Rallied Greater Aegis of Vie",
        },
        ['SingleSymbolBuff'] = {
            ----Symbols
            [1] = "Symbol of Transal",
            [2] = "Symbol of Ryltan",
            [3] = "Symbol of Pinzarn",
            [4] = "Symbol of Naltron",
            [5] = "Symbol of Marzin",	
            [6] = "Symbol of Kazad",
            [7] = "Symbol of Balikor",
            [8] = "Symbol of Elushar",
            [9] = "Symbol of Kaerra",
            [10] = "Symbol of Darianna",
            [11] = "Symbol of Ealdun",
            [12] = "Unity of the Triumvirate",
            [13] = "Unity of Gezat",
            [14] = "Unity of Nonia",
            [15] = "Unity of Emra",
            [16] = "Unity of Jorlleag",
            [17] = "Unity of Helmsbane",
        },
        ['SymbolBuff'] = {
            ----Group Symbols
            [1] = "Symbol of Transal",
            [2] = "Symbol of Ryltan",
            [3] = "Symbol of Pinzarn",
            [4] = "Symbol of Naltron",
            [5] = "Symbol of Marzin",
            [6] = "Naltron's Mark",
            [7] = "Kazad's Mark",
            [8] = "Balikor's Mark",
            [9] = "Elushar's Mark",
            [10] = "Kaerra's Mark",
            [11] = "Darianna's Mark",
            [12] = "Ealdun's Mark",
            [13] = "Unified Hand of the Triumvirate",
            [14] = "Unified Hand of Gezat",
            [15] = "Unified Hand of Nonia",
            [16] = "Unified Hand of Emra",
            [17] = "Unified Hand of Jorlleag",
            [18] = "Unified Hand of Assurance",
            [19] = "Unified Hand of the Diabo",
            [20] = "Unified Hand of Infallibility",
        },
        ['HPBuff'] = {
            ----Single Target HP Buffs
            [1] = "Courage",
            [2] = "Center",
            [3] = "Daring",
            [4] = "Bravery",
            [5] = "Valor",
            [6] = "Heroism",
            [7] = "Temperance",
            [8] = "Aegolism",
            [9] = "Virtue",
            [10] = "Conviction",
            [11] = "Tenacity",
            [12] = "Temerity",
            [13] = "Gallantry",
            [14] = "Reliance",
            [15] = "Unified Credence",
            [16] = "Unified Certitude",
            [17] = "Unified Surety",
            [18] = "Unified Assurance",
            [19] = "Unified Righteousness",
            [20] = "Unified Persistence",
            [21] = "Unified Commitment",
        },
        ['aurabuff1'] = {
            ----Aura Buffs - Aura Name is seperate than the buff name
            [1] = "Aura of the Pious",
            [2] = "Aura of the Zealot",
            [3] = "Aura of the Reverent",
            [4] = "Aura of the Persistent",
        },
        ['aurabuff2'] = {
            ---- Aura Buff 2 - Aura Name is the same as the buff name
            [1] = "Bastion of Divinity",
            [2] = "Circle of Divinity",
            [3] = "Aura of Divinity",
        },
        ['DivineBuff'] = {
            ----Divine Buffs REQUIRES extra spell slot because of the 90s recast
            [1] = "Death Pact",
            [2] = "Divine Intervention",
            [3] = "Divine Intercession",
            [4] = "Divine Invocation",
            [5] = "Divine Interposition",
            [6] = "Divine Indemnification",
            [7] = "Divine Imposition",
            [8] = "Divine Intermediation",
            [9] = "Divine Interference",
        },
        ['Icespellcure'] = {
            ----- Spell Cure--------
            [1] = "Expurgated Blood",
            [2] = "Unblemished Blood",
            [3] = "Cleansed Blood",
            [4] = "Perfected Blood",
            [5] = "Purged Blood",
            [6] = "Sanctified Blood",
        },
        ['AllianceBuff'] = {
            ----AllianceBuff
            [1] = "Sincere Coalition",
            [2] = "Divine Alliance",
        },
        ['Hammerpet'] = {
            [1] = "Unswerving Hammer of Faith",
            [2] = "Unswerving Hammer of Retribution",
            [3] = "Unflinching Hammer of Zeal",
            [4] = "Indomitable Hammer of Zeal",
            [5] = "Unwavering Hammer of Zeal",
            [6] = "Devout Hammer of Zeal",
            [7] = "Infallible Hammer of Zeal",
            [8] = "Infallible Hammer of Reverence",
            [9] = "Ardent Hammer of Zeal",
            [10] = "Unyielding Hammer of Zeal",
            [11] = "Unyielding Hammer of Obliteration",
            [12] = "Incorruptible Hammer of Obliteration",
            [13] = "Unrelenting Hammer of Zeal",
        },
        ['SingleHot'] = {
            [1] = "Celestial Remedy",
            [2] = "Celestial Health",
            [3] = "Celestial Healing",
            [4] = "Celestial Elixir",
            [5] = "Supernal Elixir",
            [6] = "Holy Elixir",
            [7] = "Pious Elixir",
            [8] = "Sacred Elixir",
            [9] = "Solemn Elixir",
            [10] = "Devout Elixir",
            [11] = "Earnest Elixir",
            [12] = "Zealous Elixir",
            [13] = "Reverent Elixir",
            [14] = "Ardent Elixir",
            [15] = "Merciful Elixir",
            [16] = "Sincere Elixir",
            [17] = "Hallowed Elixir",
            [18] = "Avowed Elixir",
        },
        ['twincastnuke'] = {
            [1] = "Glorious Denunciation",
            [2] = "Glorious Censure",
            [3] = "Glorious Admonition",
            [4] = "Glorious Rebuke",
            [5] = "Glorious Judgment",
            [6] = "Unyielding Judgment",
            [7] = "Unyielding Censure",
            [8] = "Unyielding Rebuke",
            [9] = "Unyielding Admonition",
        },
        ['CurePoison'] = {
            [1] = "Cure Poison",
            [2] = "Counteract Poison",
            [3] = "Abolish Poison",
            [4] = "Eradicate Poison",
            [5] = "Antidote",
            [6] = "Purged Blood",
            [7] = "Perfected Blood",
            [8] = "Cleansed Blood",
            [9] = "Unblemished Blood",
            [10] = "Expurgated Blood",
            [11] = "Sanctified Blood",
        },
        ['CureDisease'] = {
            [1] = "Cure Disease",
            [2] = "Counteract Disease",
            [3] = "Pure Blood",
            [4] = "Eradicate Disease",
            [5] = "Purified Blood",
            [6] = "Purged Blood",
            [7] = "Perfected Blood",
            [8] = "Cleansed Blood",
            [9] = "Unblemished Blood",
            [10] = "Expurgated Blood",
            [11] = "Sanctified Blood",
        },
        ['CureCurse'] = {
            [1] = "Remove Minor Curse",
            [2] = "Remove Lesser Curse",
            [3] = "Remove Curse",
            [4] = "Remove Greater Curse",
            [5] = "Eradicate Curse",
            [6] = "Purged Blood",
            [7] = "Perfected Blood",
            [8] = "Cleansed Blood",
            [9] = "Unblemished Blood",
            [10] = "Expurgated Blood",
            [11] = "Sanctified Blood",
        },
        ['CureCorrupt'] = {
            [1] = "Expunge Corruption",
            [2] = "Vitiate Corruption",
            [3] = "Abolish Corruption",
            [4] = "Pristine Blood",
            [5] = "Dissolve Corruption",
            [6] = "Perfected Blood",
            [7] = "Cleansed Blood",
            [8] = "Unblemished Blood",
            [9] = "Expurgated Blood",
            [10] = "Purged Blood",
            [11] = "Sanctified Blood",
        },
        ['RezSpell'] = {
            [1] = "Reviviscence",
            [2] = "Resurrection",
            [3] = "Restoration",
            [4] = "Resuscitate",
            [5] = "Renewal",
            [6] = "Revive",
            [7] = "Reparation",
            [8] = "Reconstitution",
            [9] = "Reanimation",
        },
        ['AERezSpell'] = {
            [1] = "Superior Reviviscence",
            [2] = "Eminent Reviviscence",
            [3] = "Greater Reviviscence",
            [4] = "Larger Reviviscence",
        },
        ['ClutchHeal'] = {
            -- 11th-17th Rejuv Spell Line Clutch Heals Require Life below 35-45% to cast
            [1] = "Eleventh-Hour",
            [2] = "Twelfth Night",
            [3] = "Thirteenth Salve",
            [4] = "Fourteenth Catalyst",
            [5] = "Fifteenth Emblem",
            [6] = "Sixteenth Serenity",
            [7] = "Seventeenth Rejuvenation",
            [8] = "Eighteenth Rejuvenation",
            [9] = "Nineteenth Commandment",
        },
        ['InfusionHand'] = {
            -- Hand of Infusion Line
            [1] = "Hand of Faithful Infusion",
            [2] = "Hand of Graceful Infusion",
            [3] = "Hand of Merciful Infusion",
            [4] = "Hand of Sincere Infusion",
            [5] = "Hand of Unyielding Infusion",
            [6] = "Hand of Avowed Infusion",
        },
        ['MagicNuke'] = {
            -- Basic Nuke
            [1] = "Strike",
            [2] = "Furor",
            [3] = "Smite",
            [4] = "Wrath",
            [5] = "Retribution",
            [6] = "Judgment",
            [7] = "Condemnation",
            [8] = "Order",
            [9] = "Reproach",
            [10] = "Reproval",
            [11] = "Reprehend",
            [12] = "Rebuke",
            [13] = "Remonstrance",
            [14] = "Castigation",
            [15] = "Justice",
            [16] = "Sanction",
            [17] = "Injunction",
            [18] = "Divine Writ",
            [19] = "Decree",
        },
        ['AnticipatedHeal'] = {
            -- Anticipated Heal Line
            [1] = "Anticipated Interposition",
            [2] = "Anticipated Intercession",
            [3] = "Anticipated Intervention",
            [4] = "Anticipated Intercalation",
            [5] = "Anticipated Interdiction",
        },
        ['GroupHot'] = {
            -- Group Hot Line - Elixirs No Cure
            [1] = "Elixir of Expiation",
            [2] = "Elixir of the Ardent",
            [3] = "Elixir of the Beneficent",
            [4] = "Elixir of the Acquittal",
            [5] = "Elixir of the Seas",
            [6] = "Elixir of Wulthan",
            [7] = "Elixir of Transcendence",
            [8] = "Elixir of Benevolence",
            [9] = "Elixir of Realization",
        },
        ['GroupHotCure'] = {        
            -- Group Hot Line Cure + Hot 99+
            [1] = "Cleansing Acquittal",
            [2] = "Ardent Acquittal",
            [3] = "Merciful Acquittal",
            [4] = "Sincere Acquittal",
            [5] = "Devout Acquittal",
            [6] = "Avowed Acquittal",
        },
        ['SpellBlessing'] = {
            -- Spell Speed Blessings 15-92(112)Becomes Defunct due to Unifieds.)
            -- [] = "Benediction of Resplendence",
            [1] = "Blessing of Piety",
            [2] = "Blessing of Faith",
            [3] = "Blessing of Reverence",
            [4] = "Aura of Reverence",
            [5] = "Blessing of Devotion",
            [6] = "Aura of Devotion",
            [7] = "Blessing of Purpose",
            [8] = "Aura of Purpose",
            [9] = "Blessing of Resolve",
            [10] = "Aura of Resolve",
            [11] = "Blessing of Loyalty",
            [12] = "Aura of Loyalty",
            [13] = "Blessing of Will",
            [14] = "Hand of Will",
            [15] = "Blessing of Fervor",
            [16] = "Hand of Fervor",
            [17] = "Benediction of Piety",
            [18] = "Hand of Zeal",

        },
        ['CompHeal'] = {
            -- - Complete Heal
            [1] = "Complete Heal",
        },

    },
    ['Rotations'] = {
        ['Tank'] = {
            ['Active'] = 1,
            ['Downtime'] = 1,
            ['Burn'] = 1,
        },
        ['DPS'] = {
            ['Ative'] = 1,
            ['Downtime'] = 1,
            ['Burn'] = 1,
        },
        ['TLP'] = {
            ['TLPTank'] = 1,
            ['TLPDPSHeal'] = 1,
            ['TLPDowntime'] = 1,
            ['TLPBurn'] = 1,
        },
    },

    ['DefaultConfig'] = {
        ['Mode'] = 'Tank',
    },
}














