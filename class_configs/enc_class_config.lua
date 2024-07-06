local mq           = require('mq')
local RGMercUtils  = require("utils.rgmercs_utils")

local _ClassConfig = {
    _version          = "1.0 Beta",
    _author           = "Derple",
    ['ModeChecks']    = {
        IsMezzing = function() return true end,
        IsCharming = function() return RGMercUtils.IsModeActive("Charm") end,
    },
    ['Modes']         = {
        'Mez',
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Staff of Eternal Eloquence",
            "Oculus of Persuasion",
        },
    },
    ['AbilitySets']   = {
        ['AuraBuff1'] = {
            "Twincast Aura",
        },
        ['AuraBuff2'] = {
            "Mana Ripple Aura",
            "Mana Radix Aura",
            "Mana Replication Aura",
            "Mana Repetition Aura",
            "Mana Reciprocation Aura",
            "Mana Reverberation Aura",
            "Mana Repercussion Aura",
            "Mana Reiteration Aura",
            "Mana Reiterate Aura",
            "Mana Resurgence Aura",
            "Mystifier's Aura",
            "Entrancer's Aura",
            "Illusionist's Aura",
            "Beguiler's Aura",
        },
        ['AuraBuff3'] = {
            "Learner's Aura",
        },
        ['HasteBuff'] = {
            "Hastening of Margator",
            "Hastening of Jharin",
            "Hastening of Cekenar",
            "Hastening of Milyex",
            "Hastening of Prokev",
            "Hastening of Sviir",
            "Hastening of Aransir",
            "Hastening of Novak",
            "Hastening of Erradien",
            "Hastening of Ellowind",
            "Hastening of Salik",
            "Vallon's Quickening",
            "Speed of the Brood",
            "Speed of Cekenar",
            "Speed of Milyex",
            "Speed of Prokev",
            "Speed of Sviir",
            "Speed of Aransir",
            "Speed of Novak",
            "Speed of Erradien",
            "Speed of Ellowind",
            "Speed of Salik",
            "Speed of Vallon",
            "Visions of Grandeur",
            "Wondrous Rapidity",
            "Aanya's Quickening",
            "Swift Like the Wind",
            "Celerity",
            "Augmentation",
            "Alacrity",
            "Quickness",
        },
        ['ManaRegen'] = {
            "Voice of Preordination",
            "Voice of Perception",
            "Voice of Sagacity",
            "Voice of Perspicacity",
            "Voice of Precognition",
            "Voice of Foresight",
            "Voice of Premeditation",
            "Voice of Forethought",
            "Voice of Prescience",
            "Voice of Cognizance",
            "Voice of Intuition",
            "Voice of Clairvoyance",
            "Voice of Quellious",
            "Tranquility",
            -- [] = ["Gift of Brilliance", -- Removed because the Map Defaults to it Instead of Koadics
            "Koadic's Endless Intellect",
            "Gift of Pure Thought",
            "Sagacity",
            "Perspicacity",
            "Precognition",
            "Foresight",
            "Premeditation",
            "Forethought",
            "Prescience",
            "Seer's Cognizance",
            "Seer's Intuition",
            "Clairvoyance",
            "Gift of Insight",
            "Clarity II",
            "Clarity",
            "Breeze",
        },
        ['MezBuff'] = {
            "Ward of the Stupefier",
            "Ward of the Beguiler",
            "Ward of the Deviser",
            "Ward of the Transfixer",
            "Ward of the Enticer",
            "Ward of the Mastermind",
            "Ward of Arctending",
            "Ward of Bafflement",
            "Ward of Befuddlement",
            "Ward of Mystifying",
            "Ward of Bewilderment",
            "Ward of Bedazzlement",
        },
        ['NdtBuff'] = {
            "Night's Perpetual Terror",
            "Night's Endless Terror",
            "Night's Dark Terror",
            "Boon of the Garou",
        },
        ['SelfHPBuff'] = {
            "Shield of Memories",
            "Shield of Shadow",
            "Shield of Restless Ice",
            "Shield of Scales",
            "Shield of the Pellarus",
            "Shield of the Dauntless",
            "Shield of Bronze",
            "Shield of Dreams",
            "Shield of the Void",
            "Spellbound Shield",
            "Sorcerous Shield",
            "Mystic Shield",
            "Shield of Maelin",
            "Shield of the Arcane",
            "Shield of the Magi",
            "Arch Shielding",
            "Greater Shielding",
            "Major Shielding",
            "Shielding",
            "Lesser Shielding",
            "Minor Shielding",
        },
        ['SelfRune1'] = {
            "Esoteric Rune",
            "Marvel's Rune",
            "Deviser's Rune",
            "Transfixer's Rune",
            "Enticer's Rune",
            "Mastermind's Rune",
            "Arcanaward's Rune",
            "Spectral Rune",
            "Pearlescent Rune",
            "Opalescent Rune",
            "Draconic Rune",
            "Ethereal Rune",
            "Arcane Rune",
        },
        ['SelfRune2'] = {
            "Polyradiant Rune",
            "Polyluminous Rune",
            "Polycascading Rune",
            "Polyfluorescent Rune",
            "Polyrefractive Rune",
            "Polyiridescent Rune",
            "Polyarcanic Rune",
            "Polyspectral Rune",
            "Polychaotic Rune",
            "Multichromatic Rune",
            "Polychromatic Rune",
        },
        ['UnityRune'] = {
            "Esoteric Unity",
            "Deviser's Unity",
            "Marvel's Unity",
        },
        ['SingleRune'] = {
            "Rune of Zoraxmen",
            "Rune of Tearc",
            "Rune of Kildrukaun",
            "Rune of Skrizix",
            "Rune of Lucem",
            "Rune of Xolok",
            "Rune of Tonmek",
            "Rune of Novak",
            "Rune of Yozan",
            "Rune of Erradien",
            "Rune of Ellowind",
            "Rune of Salik",
            "Rune of Zebuxoruk",
            "Rune V",
            "Rune IV",
            "Rune III",
            "Rune II",
            "Rune I",
        },
        ['GroupRune'] = {
            "Gloaming Rune",
            "Eclipsed Rune",
            "Crepuscular Rune",
            "Tenebrous Rune",
            "Darkened Rune",
            "Umbral Rune",
            "Shadowed Rune",
            "Twilight Rune",
            "Rune of the Void",
            "Rune of the Deep",
            "Rune of the Kedge",
            "Rune of Rikkukin",
            "Rune of the Scale",
        },
        ['AggroRune'] = {
            "Disquieting Rune",
            "Ghastly Rune",
            "Horrendous Rune",
            "Dreadful Rune",
            "Frightening Rune",
            "Terrifying Rune",
            "Horrifying Rune",
        },
        ['AggroBuff'] = {
            "Horrifying Visage",
            "Haunting Visage",
        },
        ['SingleSpellShield'] = {
            "Aegis of Elmara",
            "Aegis of Sefra",
            "Aegis of Omica",
            "Aegis of Nureya",
            "Aegis of Gordianus",
            "Aegis of Xorbb",
            "Aegis of Soliadal",
            "Aegis of Zykean",
            "Aegis of Xadrith",
            "Aegis of Qandieal",
            "Aegis of Alendar",
            "Wall of Alendar",
            "Bulwark of Alendar",
            "Protection of Alendar",
            "Guard of Alendar",
            "Ward of Alendar",
        },
        ['GroupSpellShield'] = {
            "Legion of Ogna",
            "Legion of Liako",
            "Legion of Kildrukaun",
            "Legion of Skrizix",
            "Legion of Lucem",
            "Legion of Xolok",
            "Legion of Tonmek",
            "Legion of Zykean",
            "Legion of Xadrith",
            "Legion of Qandieal",
            "Legion of Alendar",
            "Circle of Alendar",
        },
        ['SingleDoTShield'] = {
            "Aegis of Xetheg",
            "Aegis of Cekenar",
            "Aegis of Milyex",
            "Aegis of the Indagator",
            "Aegis of the Keeper",
        },
        ['GroupDoTShield'] = {
            "Legion of Dhakka",
            "Legion of Xetheg",
            "Legion of Cekenar",
            "Legion of Milyex",
            "Legion of the Indagator",
            "Legion of the Keeper",
        },
        ['SingleMeleeShield'] = {
            "Gloaming Auspice",
            "Eclipsed Auspice",
            "Crepuscular Auspice",
            "Tenebrous Auspice",
            "Darkened Auspice",
            "Umbral Auspice",
        },
        ['SelfGuardShield'] = {
            "Shield of Inescapability",
            "Shield of Shadow",
            "Shield of Destiny",
            "Shield of Order",
            "Shield of Consequence",
            "Shield of Fate",
        },
        ['GroupAuspiceBuff'] = {
            "Marvel's Auspice",
            "Deviser's Auspice",
            "Transfixer's Auspice",
            "Enticer's Auspice",
        },
        ['AllianceSpell'] = {
            "Chromatic Conjunction",
            "Chromatic Coalition",
            "Chromatic Covenant",
            "Chromatic Alliance",
        },
        ['TwinCast'] = {
            "Chaotic Deception",
            "Chaotic Delusion",
            "Chaotic Bewildering",
            "Chaotic Confounding",
            "Chaotic Confusion",
            "Chaotic Baffling",
            "Chaotic Befuddling",
            "Chaotic Puzzlement",
            "Chaotic Conundrum",
        },
        ['PBAEStunSpell'] = {
            "Color Calibration",
            "Color Conflagration",
            "Color Cascade",
            "Color Congruence",
            "Color Concourse",
            "Color Confluence",
            "Color Convergence",
            "Color Clash",
            "Color Conflux",
            "Color Cataclysm",
            "Color Collapse",
            "Color Snap",
            "Color Cloud",
            "Color Slant",
            "Color Skew",
            "Color Shift",
            "Color Flux",
        },
        ['TargetAEStun'] = {
            "Remote Color Calibration",
            "Remote Color Conflagration",
            "Remote Color Cascade",
            "Remote Color Congruence",
            "Remote Color Concourse",
            "Remote Color Confluence",
            "Remote Color Convergence",
        },
        ['SingleStunSpell1'] = {
            "Dizzying Spindle",
            "Dizzying Vortex",
            "Dizzying Coil",
            "Dizzying Wheel",
            "Dizzying Storm",
            "Dizzying Squall",
            "Dizzying Gyre",
            "Dizzying Helix",
            "The Downward Spiral",
            "Whirling into the Hollow",
            "Spinning into the Void",
            "Largarn's Lamentation",
            "Dyn's Dizzying Draught",
            "Whirl till you hurl",
        },
        ['CharmSpell'] = {
            "Esoteric Command",
            "Marvel's Demand",
            "Marvel's Command",
            "Inveigle",
            "Deviser's Demand",
            "Deviser's Command",
            "Transfixer's Command",
            "Spellbinding",
            "Enticer's Command",
            "Enticer's Demand",
            "Captivation",
            "Impose",
            "Temptation",
            "Enforce",
            "Compelling Edict",
            "Subjugate",
            "Deception",
            "Dominate",
            "Seduction",
            "Haunting Whispers",
            "Cajole",
            "Dyn`leth's Whispers",
            "Coax",
            -- [] = "Ancient Voice of Muram",
            "True Name",
            "Compel",
            "Command of Druzzil",
            "Beckon",
            "Dictate",
            "Boltran's Agacerie",
            "Ordinance",
            "Allure",
            "Cajoling Whispers",
            "Beguile",
            "Charm",
        },
        ['CrippleSpell'] = {
            "Splintered Consciousness",
            "Fragmented Consciousness",
            "Shattered Consciousness",
            "Fractured Consciousness",
            "Synapsis Spasm",
            "Cripple",
            "Incapacitate",
            "Listless Power",
            "Disempower",
            "Enfeeblement",
        },
        ['SlowSpell'] = {
            -- Slow - lvl88 and above this is also cripple spell Starting @ Level 88  Combines With Cripple.
            "Desolate Deeds",
            "Dreary Deeds",
            "Forlorn Deeds",
            "Shiftless Deeds",
            "Tepid Deeds",
            "Languid Pace",
        },
        ['StripBuffSpell'] = {
            "Eradicate Magic",
            "Recant Magic",
            "Pillage Enchantment",
            "Nullify Magic",
            "Strip Enchantment",
            "Cancel Magic",
            "Taper Enchantment",
        },
        ['TashSpell'] = {
            "Roar of Tashan",
            "Edict of Tashan",
            "Proclamation of Tashan",
            "Order of Tashan",
            "Decree of Tashan",
            "Enunciation of Tashan",
            "Declaration of Tashan",
            "Clamor of Tashan",
            "Bark of Tashan",
            "Din of Tashan",
            "Echo of Tashan",
            "Howl of Tashan",
            "Tashanian",
            "Tashania",
            "Tashani",
            "Tashina",
        },
        ['ManaDrainSpell'] = {
            "Tears of Kasha",
            "Tears of Xenacious",
            "Tears of Aaryonar",
            "Tears of Skrizix",
            "Tears of Visius",
            "Tears of Syrkl",
            "Tears of Wreliard",
            "Tears of Zykean",
            "Tears of Xadrith",
            "Tears of Qandieal",
            "Torment of Scio",
            "Torment of Argli",
            "Scryer's Trespass",
            "Wandering Mind",
            "Mana Sieve",
        },
        ['DichoSpell'] = {
            "Ecliptic Reinforcement",
            "Composite Reinforcement",
            "Dissident Reinforcement",
            "Dichotomic Reinforcement",
        },
        ['DoTSpell1'] = {
            ---DoT 1 -- >=LVL1
            "Asphyxiating Grasp",
            "Throttling Grip",
            "Pulmonary Grip",
            "Strangulate",
            "Drown",
            "Stifle",
            "Suffocation",
            "Constrict",
            "Smother",
            "Strangling Air",
            "Thin Air",
            "Arcane Noose",
            "Strangle",
            "Asphyxiate",
            "Gasping Embrace",
            "Suffocate",
            "Choke",
            "Suffocating Sphere",
            "Shallow Breath",
        },
        ['ManaDot'] = {
            -- DoT 2 --  >= LVL70
            "Mind Whirl",
            "Mind Vortex",
            "Mind Coil",
            "Mind Tempest",
            "Mind Storm",
            "Mind Squall",
            "Mind Spiral",
            "Mind Helix",
            "Mind Twist",
            "Mind Oscillate",
            "Mind Phobiate",
            "Mind Shatter",
        },
        ['DebuffDot'] = {
            ---DoT 3 -- >= LVL89
            "Dismaying Constriction",
            "Perplexing Constriction",
            "Deceiving Constriction",
            "Deluding Constriction",
            "Bewildering Constriction",
            "Confounding Constriction",
            "Confusing Constriction",
            "Baffling Constriction",
        },
        ['NukeSpell1'] = {
            --- Nuke 1 -- >= LVL7
            "Mindrend",
            "Mindreap",
            "Mindrift",
            "Mindslash",
            "Mindsunder",
            "Mindcleave",
            "Mindscythe",
            "Mindblade",
            "Spectral Assault",
            "Polychaotic Assault",
            "Multichromatic Assault",
            "Polychromatic Assault",
            "Colored Chaos",
            "Psychosis",
            "Madness of Ikkibi",
            "Insanity",
            "Dementing Visions",
            "Dementia",
            "Discordant Mind",
            "Anarchy",
            "Chaos Flux",
            "Sanity Warp",
            "Chaotic Feedback",
            "Chromarcana",
            "Ancient: Neurosis",
            "Ancient: Chaos Madness",
            "Ancient: Chaotic Visions",
        },
        ['NukeSpell2'] = {
            --- Nuke 1 -- >= LVL7
            "Mindrend",
            "Mindreap",
            "Mindrift",
            "Mindslash",
            "Mindsunder",
            "Mindcleave",
            "Mindscythe",
            "Mindblade",
            "Spectral Assault",
            "Polychaotic Assault",
            "Multichromatic Assault",
            "Polychromatic Assault",
            "Colored Chaos",
            "Psychosis",
            "Madness of Ikkibi",
            "Insanity",
            "Dementing Visions",
            "Dementia",
            "Discordant Mind",
            "Anarchy",
            "Chaos Flux",
            "Sanity Warp",
            "Chaotic Feedback",
            "Chromarcana",
            "Ancient: Neurosis",
            "Ancient: Chaos Madness",
            "Ancient: Chaotic Visions",
        },
        ['RuneNuke'] = {
            --- RUNE - Nuke Fast >=LVL86
            "Chromatic Spike",
            "Chromatic Flare",
            "Chromatic Stab",
            "Chromatic Flicker",
            "Chromatic Blink",
            "Chromatic Percussion",
            "Chromatic Flash",
            "Chromatic Jab",
        },
        ['ManaNuke'] = {
            --- Mana Drain Nuke - Fast -- >=LVL96
            "Psychological Appropriation",
            "Ideological Appropriation",
            "Psychic Appropriation",
            "Intellectual Appropriation",
            "Mental Appropriation",
            "Cognitive Appropriation",
        },
        ['ChromaNuke'] = {
            --- Chromatic Lowest Nuke - Normal -- >=LVL73
            "Polycascading Assault",
            "Polyfluorescent Assault",
            "Polyrefractive Assault",
            "Phantasmal Assault",
            "Arcane Assault",
            "Spectral Assault",
            "Polychaotic Assault",
            "Multichromatic Assault",
            "Polychromatic Assault",
        },
        ['CripSlowSpell'] = {
            --- Slow Cripple Combo Spell - Beginning @ Level 88
            "Constraining Coil",
            "Constraining Helix",
            "Undermining Helix",
            "Diminishing Helix",
            "Attenuating Helix",
            "Curtailing Helix",
            "Inhibiting Helix",
        },
        ['PetSpell'] = {
            "Flariton's Animation",
            "Constance's Animation",
            "Omica's Animation",
            "Nureya's Animation",
            "Gordianus' Animation",
            "Xorlex's Animation",
            "Seronvall's Animation",
            "Novak's Animation",
            "Yozan's Animation",
            "Erradien's Animation",
            "Ellowind's Animation",
            "Salik's Animation",
            "Aeldorb's Animation",
            "Zumaik's Animation",
            "Kintaz's Animation",
            "Yegoreff's Animation",
            "Aanya's Animation",
            "Boltran's Animation",
            "Uleen's Animation",
            "Sagar's Animation",
            "Sisna's Animation",
            "Shalee's Animation",
            "Kilan's Animation",
            "Mircyl's Animation",
            "Juli's Animation",
            "Pendril's Animation",
        },
        ['PetBuffSpell'] = {
            ---Pet Buff Spell * Var Name: PetBuffSpell string outer
            "Speed of Margator",
            "Speed of Vallon",
            "Visions of Grandeur",
            "Wondrous Rapidity",
            "Aanya's Quickening",
            "Swift Like the Wind",
            "Celerity",
            "Augmentation",
            "Alacrity",
            "Quickness",
            "Infused Minion",
            "Empowered Minion",
            "Invigorated Minion",
            --- Speed of the Brood won't take effect properly on pets. Unless u Purchase the AA
        },
        ['MezAESpell'] = {
            ---AE Mez * Var Name:,string outer
            "Neutralizing Wave",
            "Perplexing Wave",
            "Deadening Wave",
            "Slackening Wave",
            "Peaceful Wave",
            "Serene Wave",
            "Ensorcelling Wave",
            "Quelling Wave",
            "Wake of Subdual",
            "Wake of Felicity",
            "Bliss of the Nihil",
            "Fascination",
            "Mesmerization",
            "Bewildering Wave",
            "Stupefying Wave",
        },
        ['MezAESpellFast'] = {
            "Vexing Glance",
            "Confounding Glance",
            "Neutralizing Glance",
            "Perplexing Glance",
            "Slackening Glance",
        },
        ['MezPBAESpell'] = {
            "Neutralize",
            "Perplex",
            "Bafflement",
            "Disorientation",
            "Confusion",
            "Serenity",
            "Docility",
            "Visions of Kirathas",
            "Dreams of Veldyn",
            "Circle of Dreams",
            "Word of Morell",
            "Entrancing Lights",
            "Bewilderment",
            "Wonderment",
        },
        ['MezSpell'] = {
            "Flummox",
            "Addle",
            "Deceive",
            "Delude",
            "Bewilder",
            "Confound",
            "Mislead",
            "Baffle",
            "Befuddle",
            "Mystify",
            "Bewilderment",
            "Euphoria",
            "Felicity",
            "Bliss",
            "Sleep",
            "Apathy",
            "Glamour of Kintaz",
            "Enthrall",
            "Mesmerize",
        },
        ['MezSpellFast'] = {
            "Deceiving Flash",
            "Deluding Flash",
            "Bewildering Flash",
            "Confounding Flash",
            "Misleading Flash",
            "Baffling Flash",
            "Befuddling Flash",
            "Mystifying Flash",
            "Perplexing Flash",
            "Addling Flash",
            "Flummoxing Flash",
        },
        ['BlurSpell'] = {
            "Memory Flux",
            "Reoccurring Amnesia",
            "Memory Blur",
        },
        ['AEBlurSpell'] = {
            "Blanket of Forgetfulness",
            "Mind Wipe",
        },
        ['CalmSpell'] = {
            ---Calm Spell -- >= LVL1
            "Docile Mind",
            "Still Mind",
            "Serene Mind",
            "Mollified Mind",
            "Pacified Mind",
            "Quiescent Mind",
            "Halcyon Mind",
            "Bucolic Mind",
            "Hushed Mind",
            "Silent Mind",
            "Quiet Mind",
            "Placate",
            "Pacification",
            "Pacify",
            "Calm",
            "Soothe",
            "Lull",
        },
        ['FearSpell'] = {
            ---Fear Spell * Var Name:, string outer >= LVL3
            "Anxiety Attack",
            "Jitterskin",
            "Phobia",
            "Trepidation",
            "Invoke Fear",
            "Chase the Moon",
            "Fear",
        },
        ['RootSpell'] = {
            "Greater Fetter",
            "Fetter",
            "Paralyzing Earth",
            "Immobilize",
            "Instill",
            "Root",
        },
    },
    ['RotationOrder'] = {
        {
            name = 'SelfBuff',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state) return combat_state == "Downtime" and RGMercUtils.DoBuffCheck() end,

        },
        {
            name = 'Pet Management',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state) return combat_state == "Downtime" end,

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
            cond = function(self, combat_state) return combat_state == "Downtime" and RGMercUtils.DoBuffCheck() end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.BurnCheck() and not RGMercUtils.Feigning()
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
        ['Pet Management'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell) return mq.TLO.Me.Pet.ID() == 0 end,
            },
            {
                name = "PetBuffSpell",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.ID()).ID() end,
                cond = function(self, spell) return RGMercUtils.SelfBuffPetCheck(spell) end,
            },
        },
        ['SelfBuff'] = {
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "MezBuff",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune2",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "Veil of Mindshadow",
                type = "AA",
                active_cond = function(self, aaName) return RGMercUtils.BuffActiveByName(aaName) end,
                cond = function(self, aaName) return RGMercUtils.SelfBuffAACheck(aaName) end,
            },

            {
                name = "Azure Mind Crystal",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.FindItem(aaName)() ~= nil end,
                cond = function(self, aaName) return mq.TLO.Me.PctMana() > 90 and not mq.TLO.FindItem(aaName)() end,
            },
            {
                name = "Gather Mana",
                type = "AA",
                active_cond = function(self, aaName) return RGMercUtils.AAReady(aaName) end,
                cond = function(self, aaName) return mq.TLO.Me.PctMana() < 60 end,
            },
            {
                name = "AuraBuff1",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.AuraActiveByName(spell.Name()) end,
                cond = function(self, spell) return not RGMercUtils.AuraActiveByName(spell.Name()) and RGMercUtils.PCSpellReady(spell) end,
            },
            {
                name = "AuraBuff2",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.AuraActiveByName(spell.Name()) end,
                cond = function(self, spell) return RGMercUtils.CanUseAA('Auroria Mastery') and not RGMercUtils.GetSetting('DoLearners') and not RGMercUtils.AuraActiveByName(spell.Name()) and RGMercUtils.PCSpellReady(spell) end,
            },
            {
                name = "AuraBuff3",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.AuraActiveByName(spell.Name()) end,
                cond = function(self, spell) return RGMercUtils.CanUseAA('Auroria Mastery') and RGMercUtils.GetSetting('DoLearners') and not RGMercUtils.AuraActiveByName(spell.Name()) and RGMercUtils.PCSpellReady(spell) end,
            },

        },
        ['GroupBuff'] = {
            -- TODO : Macro group buff rotation never was hooked up ask Mori about this later.
            {
                name = "ManaRegen",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target, uiCheck)
                    if not target or not target() then return false end

                    if not RGMercConfig.Constants.RGCasters:contains(target.Class.ShortName()) then return false end

                    return RGMercUtils.CheckPCNeedsBuff(spell, target.ID(), target.CleanName(), uiCheck)
                end,
            },
            {
                name = "HasteBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target, uiCheck)
                    if not target or not target() then return false end

                    if not RGMercConfig.Constants.RGMelee:contains(target.Class.ShortName()) then return false end

                    return RGMercUtils.CheckPCNeedsBuff(spell, target.ID(), target.CleanName(), uiCheck)
                end,
            },
            {
                name = "GroupSpellShield",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target, uiCheck)
                    if not target or not target() then return false end

                    if mq.TLO.FindItemCount(spell.ReagentID(1)())() < 0 then return false end

                    return RGMercUtils.CheckPCNeedsBuff(spell, target.ID(), target.CleanName(), uiCheck)
                end,
            },
            {
                name = "GroupDoTShield",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target, uiCheck)
                    if not target or not target() then return false end

                    if mq.TLO.FindItemCount(spell.ReagentID(1)())() < 0 then return false end

                    return RGMercUtils.CheckPCNeedsBuff(spell, target.ID(), target.CleanName(), uiCheck)
                end,
            },
            {
                name = "GroupAuspiceBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target, uiCheck)
                    if not target or not target() then return false end

                    if mq.TLO.FindItemCount(spell.ReagentID(1)())() < 0 then return false end

                    return RGMercUtils.CheckPCNeedsBuff(spell, target.ID(), target.CleanName(), uiCheck)
                end,
            },
            {
                name = "NdtBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target, uiCheck)
                    if not RGMercUtils.GetSetting('DoNDTBuff') then return false end
                    if not target or not target() then return false end

                    if not RGMercConfig.Constants.RGMelee:contains(target.Class.ShortName()) then return false end

                    if not uiCheck then RGMercUtils.SetTarget(target.ID() or 0) end
                    return RGMercUtils.CheckPCNeedsBuff(spell, target.ID(), target.CleanName(), uiCheck) and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "SingleRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target, uiCheck)
                    if not target or not target() then return false end

                    if not RGMercConfig.Constants.RGTank:contains(target.Class.ShortName()) then return false end
                    if mq.TLO.FindItemCount(spell.ReagentID(1)())() < 0 then return false end

                    return RGMercUtils.CheckPCNeedsBuff(spell, target.ID(), target.CleanName(), uiCheck)
                end,
            },
            {
                name = "GroupRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target, uiCheck)
                    if not self.DoGroupAbsorb then return false end
                    if not target or not target() then return false end

                    if not RGMercConfig.Constants.RGCasters:contains(target.Class.ShortName()) then return false end
                    if mq.TLO.FindItemCount(spell.ReagentID(1)())() < 0 then return false end

                    return RGMercUtils.CheckPCNeedsBuff(spell, target.ID(), target.CleanName(), uiCheck)
                end,
            },
            {
                name = "AggroRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target, uiCheck)
                    if not RGMercUtils.GetSetting('DoAggroRune') then return false end
                    if not target or not target() then return false end

                    if not RGMercConfig.Constants.RGTank:contains(target.Class.ShortName()) then return false end

                    return RGMercUtils.CheckPCNeedsBuff(spell, target.ID(), target.CleanName(), uiCheck)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Glyph Spray",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return (RGMercUtils.IsNamed(mq.TLO.Target) and mq.TLO.Target.Level() > mq.TLO.Me.Level()) or
                        RGMercUtils.GetMainAssistPctHPs() < 45 and RGMercUtils.GetMainAssistPctHPs() > 5
                end,

            },
            {
                name = "Reactive Rune",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return (RGMercUtils.IsNamed(mq.TLO.Target) and mq.TLO.Target.Level() > mq.TLO.Me.Level()) or
                        RGMercUtils.GetMainAssistPctHPs() < 45 and RGMercUtils.GetMainAssistPctHPs() > 5
                end,

            },
            {
                name = "Self Stasis",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 30
                end,

            },
            {
                name = "Dimensional Instability",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 30
                end,

            },
            {
                name = "Beguiler's Directed Banishment",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 40
                end,

            },
            {
                name = "Beguiler's Banishment",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 50 and
                        mq.TLO.SpawnCount("npc radius 20")() > 2
                end,

            },
            {
                name = "Doppelganger",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 60
                end,

            },
            {
                name = "Phantasmal Opponent",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 60
                end,

            },
            {
                name = "Dimensional Shield",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 80
                end,

            },
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return mq.TLO.Me.PctAggro() >= 90
                end,

            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return mq.TLO.Me.PctAggro() >= 90
                end,

            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return true
                end,

            },
            {
                name = "Bite of Tashani",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return RGMercUtils.GetSetting('DoTash') and RGMercUtils.DetAACheck(mq.TLO.Me.AltAbility(aaName).ID()) and not mq.TLO.Target.Tashed()
                end,
            },
            {
                name = "TwinCast",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoTwincastDPS') and not RGMercUtils.BuffActiveByID(spell.ID()) and not RGMercUtils.BuffActiveByName("Improved Twincast") and
                        not RGMercModules:ExecModule("Mez", "IsMezImmune", mq.TLO.Target.ID())
                end,
            },
            {
                name = "DoTSpell1",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoDot') and RGMercUtils.DetSpellCheck(spell) and mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToNuke')
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoDicho') and RGMercUtils.DetSpellCheck(spell) and mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToNuke')
                end,
            },
            {
                name = "NukeSpell1",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToNuke')
                end,
            },
            {
                name = "NukeSpell2",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToNuke')
                end,
            },
            {
                name = "ManaDrainSpell",
                type = "Spell",
                cond = function(self, spell)
                    return (mq.TLO.Target.CurrentMana() or 0) > 10 and mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToNuke')
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Illusions of Grandeur",
                type = "AA",
                cond = function(self, aaName) return true end,

            },
            {
                name = "Spire of Enchantment",
                type = "AA",
                cond = function(self, aaName) return true end,

            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self, aaName) return true end,

            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName) return true end,

            },
            {
                name = "Calculated Insanity",
                type = "AA",
                cond = function(self, aaName) return true end,

            },
            {
                name = "Mental Contortion",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.IsNamed(mq.TLO.Target) end,

            },
            {
                name = "Chromatic Haze",
                type = "AA",
                cond = function(self, aaName) return true end,

            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return item() and mq.TLO.Me.Song(item.Spell.RankName.Name())() ~= nil
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.GetSetting('DoChestClick') and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
        },
        ['Debuff'] = {
            {
                name = "TashSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoTash') and RGMercUtils.DetSpellCheck(spell) and not mq.TLO.Target.Tashed() and
                        mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToDebuff')
                end,
            },
            {
                name = "Bite of Tashani",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return RGMercUtils.GetSetting('DoTash') and RGMercUtils.DetAACheck(mq.TLO.Me.AltAbility(aaName).ID()) and not mq.TLO.Target.Tashed()
                end,

            },
            {
                name = "StripBuffSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoStripBuff') and mq.TLO.Target.Beneficial() and mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToDebuff')
                end,
            },
            {
                name = "Enveloping Helix",
                type = "AA",
                cond = function(self, aaName)
                    if mq.TLO.Target.ID() <= 0 then return false end
                    return RGMercUtils.GetSetting('DoSlow') and RGMercUtils.DetAACheck(mq.TLO.Me.AltAbility(aaName).ID()) and
                        RGMercUtils.GetXTHaterCount() >= RGMercUtils.GetSetting('SlowCount') and
                        mq.TLO.Target.Slowed() == nil
                end,
            },
            {
                name = "Slowing Helix",
                type = "AA",
                cond = function(self, aaName, _, uiCheck)
                    if mq.TLO.Target.ID() <= 0 then return false end

                    local detAACheck = RGMercUtils.DetAACheck(mq.TLO.Me.AltAbility(aaName).ID())
                    local slowedCheck = mq.TLO.Target.Slowed() == nil or RGMercUtils.GetTargetSlowedPct() < 50

                    if not uiCheck then
                        RGMercsLogger.log_verbose("Enc: Slowing Helix: detAA(%s), slowed(%s), slowedPct(%d)", RGMercUtils.BoolToColorString(detAACheck),
                            RGMercUtils.BoolToColorString(slowedCheck), RGMercUtils.GetTargetSlowedPct())
                    end

                    return RGMercUtils.GetSetting('DoSlow') and detAACheck and slowedCheck
                end,
            },
            {
                name = "CripSlowSpell",
                type = "Spell",
                cond = function(self, spell)
                    return (RGMercUtils.GetSetting('DoSlow') or RGMercUtils.GetSetting('DoCripple')) and RGMercUtils.DetSpellCheck(spell) and
                        mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToDebuff')
                end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoSlow') and RGMercUtils.DetSpellCheck(spell) and mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToDebuff')
                end,
            },
            {
                name = "CrippleSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoSlow') and RGMercUtils.DetSpellCheck(spell) and mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToDebuff')
                end,
            },
            {
                name = "ManaDrainSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.DetSpellCheck(spell) and mq.TLO.Target.CurrentMana() > 10 and mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('ManaToNuke')
                end,
            },
        },
    },
    ['Spells']        = {
        {
            gem = 1,
            spells = {
                { name = "MezSpell", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "MezAESpell", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "TashSpell", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "SlowSpell",      cond = function(self) return not RGMercUtils.CanUseAA("Slowing Helix") and mq.TLO.Me.Level() < 88 end, },
                { name = "CripSlowSpell",  cond = function(self) return not RGMercUtils.CanUseAA("Slowing Helix") and mq.TLO.Me.Level() >= 88 end, },
                { name = "ManaDrainSpell", cond = function(self) return true end, },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "NdtBuff", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "NukeSpell1", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "DoTSpell1", },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "CrippleSpell",   cond = function(self) return RGMercUtils.GetSetting('DoCripple') and mq.TLO.Me.Level() < 88 end, },
                { name = "StripBuffSpell", cond = function(self) return RGMercUtils.GetSetting('DoStripBuff') end, },
                { name = "NukeSpell2",     cond = function(self) return true end, },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ManaDot", cond = function(self) return true end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "RuneNuke", cond = function(self) return true end, },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DebuffDot", cond = function(self) return true end, },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DichoSpell", cond = function(self) return true end, },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "AllianceSpell",  cond = function(self) return RGMercUtils.GetSetting('DoAlliance') end, },
                { name = "ManaDrainSpell", cond = function(self) return true end, },
            },
        },
    },
    ['DefaultConfig'] = {
        ['Mode']          = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 1, },
        ['DoLearners']    = { DisplayName = "Do Learners", Category = "Spells & Abilities", Tooltip = "Set to use the Learner's Aura instead of the Mana Regen Aura.", Default = false, },
        ['SlowCount']     = { DisplayName = "Slow Count", Category = "Spells & Abilities", Tooltip = "Number of XT Haters before we start slowing", Min = 1, Default = 3, Max = 10, },
        ['DoTash']        = { DisplayName = "Do Tash", Category = "Spells & Abilities", Tooltip = "Cast Tash Spells", Default = true, },
        ['DoTwincastDPS'] = { DisplayName = "Do Twincast DPS", Category = "Spells & Abilities", Tooltip = "Cast Twincast during DPS rotation", Default = true, },
        ['DoDot']         = { DisplayName = "Cast DOTs", Category = "Spells and Abilities", Tooltip = "Enable casting Damage Over Time spells.", Default = true, },
        ['DoSlow']        = { DisplayName = "Cast Slow", Category = "Spells and Abilities", Tooltip = "Enable casting Slow spells.", Default = true, },
        ['DoCripple']     = { DisplayName = "Cast Cripple", Category = "Spells and Abilities", Tooltip = "Enable casting Cripple spells.", Default = true, },
        ['DoDicho']       = { DisplayName = "Cast Dicho", Category = "Spells and Abilities", Tooltip = "Enable casting Dicho spells.", Default = true, },
        ['DoNDTBuff']     = { DisplayName = "Cast NDT", Category = "Spells and Abilities", Tooltip = "Enable casting use Melee Proc Buff (Night's Dark Terror Line).", Default = true, },
        ['DoGroupAbsorb'] = { DisplayName = "Do Group Absorb", Category = "Spells and Abilities", Tooltip = "Enable casting the Group Absorb line with -Hate Proc.", Default = true, },
        ['DoAggroRune']   = { DisplayName = "Do Aggro Rune", Category = "Spells and Abilities", Tooltip = "Enable casting the Tank Aggro Rune", Default = true, },
        ['DoStripBuff']   = { DisplayName = "Do Strip Buffs", Category = "Spells and Abilities", Tooltip = "Enable casting buff canceler spells.", Default = true, },
        ['DoChestClick']  = { DisplayName = "Do Chest Click", Category = "Utilities", Tooltip = "Click your chest item", Default = true, },
    },
}

return _ClassConfig
