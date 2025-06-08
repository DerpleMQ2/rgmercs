local mq           = require('mq')
local Config       = require('utils.config')
local Logger       = require("utils.logger")
local Core         = require("utils.core")
local Modules      = require("utils.modules")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")

local _ClassConfig = {
    _version            = "1.4 - Live",
    _author             = "Derple, Grimmier, Algar",
    ['ModeChecks']      = {
        CanMez     = function() return true end,
        CanCharm   = function() return true end,
        IsCharming = function() return Config:GetSetting('CharmOn') end,
        IsMezzing  = function() return Config:GetSetting('MezOn') end,
    },
    ['Modes']           = {
        'Default',
        'ModernEra', --Different DPS rotation, meant for ~90+ (and may not come fully online until 105ish)
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Staff of Eternal Eloquence",
            "Oculus of Persuasion",
        },
    },
    ['AbilitySets']     = {
        ['TwincastAura'] = {
            "Twincast Aura",
        },
        ['SpellProcAura'] = {
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
        ['LearnersAura'] = {
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
            "Night's Eternal Terror",
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
        ['SingleDotShield'] = {
            "Aegis of Xetheg",
            "Aegis of Cekenar",
            "Aegis of Milyex",
            "Aegis of the Indagator",
            "Aegis of the Keeper",
        },
        ['GroupDotShield'] = {
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
            "Shield of Inevitability",
            "Shield of Inescapability",
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
            "Stupefier's Auspice",
        },
        ['SpellProcBuff'] = {
            "Mana Reproduction",
            "Mana Rebirth",
            "Mana Replication",
            "Mana Repetition",
            "Mana Reciprocation",
            "Mana Reverberation",
            "Mana Repercussion",
            "Mana Reiteration",
            "Mana Reiterate",
            "Mana Resurgence",
            "Mana Recursion",
            "Mana Flare",
        },
        ['AllianceSpell'] = {
            "Chromatic Covariance",
            "Chromatic Conjunction",
            "Chromatic Coalition",
            "Chromatic Covenant",
            "Chromatic Alliance",
        },
        ['TwinCastMez'] = {
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
            "Stupefier's Demand",
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
        ['ManaDrainNuke'] = {
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
            "Reciprocal Reinforcement",
        },
        ['StrangleDot'] = {
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
        ['MindDot'] = {
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
        ['ConstrictionDot'] = {
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
        ['MagicNuke'] = {
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
        ['ManaTapNuke'] = {
            --- Mana Drain Nuke - Fast -- >=LVL96
            "Psychological Appropriation",
            "Ideological Appropriation",
            "Psychic Appropriation",
            "Intellectual Appropriation",
            "Mental Appropriation",
            "Cognitive Appropriation",
        },
        --Unused table, temporarily removed - was causing conflicts while resolving MagicNuke action maps (will revisit nukes later)
        -- ['ChromaNuke'] = {
        --- Chromatic Lowest Nuke - Normal -- >=LVL73
        -- "Polycascading Assault",
        -- "Polyfluorescent Assault",
        -- "Polyrefractive Assault",
        -- "Phantasmal Assault",
        -- "Arcane Assault",
        -- "Spectral Assault",
        -- "Polychaotic Assault",
        -- "Multichromatic Assault",
        -- "Polychromatic Assault",
        -- },
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
            "Ancient: Eternal Rapture",
            "Rapture",
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
    ['RotationOrder']   = {
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and not Core.IsCharming() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 60,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        { --Slow and Tash separated so we use both before we start DPS
            name = 'Tash',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoTash') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff()
            end,
        },
        { --Slow and Tash separated so we use both before we start DPS
            name = 'CripSlow',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSlow') or Config:GetSetting('DoCripple') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff()
            end,
        },
        {
            name = 'StripBuff',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoStripBuff') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        { --AA Stuns, Runes, etc, moved from previous home in DPS
            name = 'CombatSupport',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS(Default)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive("Default") end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS(ModernEra)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive("ModernEra") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['HelperFunctions'] = { --used to autoinventory our azure crystal after summon
        StashCrystal = function()
            mq.delay("2s", function() return mq.TLO.Cursor() and mq.TLO.Cursor.ID() == mq.TLO.Me.AltAbility("Azure Mind Crystal").Spell.Base(1)() end)

            if not mq.TLO.Cursor() then
                Logger.log_debug("No valid item found on cursor, item handling aborted.")
                return false
            end

            Logger.log_info("Sending the %s to our bags.", mq.TLO.Cursor())
            mq.delay(150)
            Core.DoCmd("/autoinventory")
        end,
        AuraCheck = function() -- remove undesired auras to stop spam conditions... this will only be triggered if we have already identified we are missing a desired aura
            if Casting.CanUseAA("Auroria Mastery") then
                -- If we can use two auras we will keep twincast and get rid of the other (including old versions of the spellproc aura line)
                -- Make sure we don't get rid of the first aura if the second aura is already free for whatever reason (fallback)
                ---@diagnostic disable-next-line: undefined-field
                if (mq.TLO.Me.Aura(1).Name() or "Twincast Aura") ~= "Twincast Aura" and mq.TLO.Me.Aura(2)() then mq.TLO.Me.Aura(1).Remove() end
                ---@diagnostic disable-next-line: undefined-field
                if (mq.TLO.Me.Aura(2).Name() or "Twincast Aura") ~= "Twincast Aura" then mq.TLO.Me.Aura(2).Remove() end
            else --if we can only use one aura, we will get rid of the current one since we are missing the one we want.
                ---@diagnostic disable-next-line: undefined-field
                mq.TLO.Me.Aura(1).Remove()
            end
        end,
    },
    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "Orator's Unity",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName) return Casting.SelfBuffAACheck(aaName) end,
            },
            {
                name = "SelfGuardShield",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "MezBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune2",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "Eldritch Rune",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Veil of Mindshadow",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName) return Casting.SelfBuffAACheck(aaName) end,
            },

            {
                name = "Azure Mind Crystal",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.FindItem(aaName)() ~= nil end,
                cond = function(self, aaName) return mq.TLO.Me.PctMana() > 90 and not mq.TLO.FindItem(aaName)() end,
                post_activate = function(self, aaName, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.StashCrystal)
                    end
                end,
            },
            {
                name = "Gather Mana",
                type = "AA",
                cond = function(self, aaName) return mq.TLO.Me.PctMana() < 60 end,
            },
            {
                name = "LearnersAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.Name()) end,
                pre_activate = function(self) self.ClassConfig.HelperFunctions.AuraCheck() end,
                cond = function(self, spell)
                    return Config:GetSetting('DoLearners') and not Casting.AuraActiveByName(spell.Name())
                end,
            },
            {
                name = "TwincastAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.Name()) end,
                pre_activate = function(self) self.ClassConfig.HelperFunctions.AuraCheck() end,
                cond = function(self, spell)
                    if Config:GetSetting('DoLearners') and not Casting.CanUseAA('Auroria Mastery') then return false end
                    return not Casting.AuraActiveByName(spell.Name())
                end,
            },
            {
                name = "SpellProcAura",
                type = "Spell",
                active_cond = function(self, spell)
                    local aura = string.sub(spell.Name() or "", 1, 8)
                    return Casting.AuraActiveByName(aura)
                end,
                pre_activate = function(self) self.ClassConfig.HelperFunctions.AuraCheck() end,
                cond = function(self, spell)
                    if (Config:GetSetting('DoLearners') and self:GetResolvedActionMapItem('LearnersAura')) or (self:GetResolvedActionMapItem('TwincastAura') and not Casting.CanUseAA('Auroria Mastery')) then return false end
                    local aura = string.sub(spell.Name() or "", 1, 8)
                    return not Casting.AuraActiveByName(aura)
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell) return Casting.ReagentCheck(spell) end,
                post_activate = function(self, spell, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetBuffSpell",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.ID()).ID() end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "ManaRegen",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsACaster(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HasteBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupSpellShield",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupSpellShield') then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "GroupDotShield",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupDotShield') then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "GroupAuspiceBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupAuspice') then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "NdtBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    --Single target versions of the spell will only be used on Melee, group versions will be cast if they are missing from any groupmember
                    if not Config:GetSetting('DoNDTBuff') or ((spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target)) then return false end

                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SpellProcBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoProcBuff') or not Targeting.TargetIsACaster(target) then return false end
                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if Config:GetSetting('RuneChoice') ~= 2 or ((spell.Level() or 0) > 73 and Targeting.TargetIsATank(target)) then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "AggroRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAggroRune') or not Targeting.TargetIsATank(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SingleRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if Config:GetSetting('RuneChoice') ~= 1 then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
        },
        ['StripBuff'] = {
            {
                name = "StripBuffSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStripBuff') or mq.TLO.Target.ID() == 0 then return false end
                    return mq.TLO.Target.Beneficial() ~= nil
                end,
            },
        },
        ['CombatSupport'] = {
            {
                name = "Glyph Spray",
                type = "AA",
                cond = function(self, aaName, target)
                    return ((Targeting.IsNamed(target) and target.Level() > mq.TLO.Me.Level()) or Core.GetMainAssistPctHPs() <= Config:GetSetting('EmergencyStart'))
                end,
            },
            {
                name = "Reactive Rune",
                type = "AA",
                cond = function(self, aaName, target)
                    return ((Targeting.IsNamed(target) and target.Level() > mq.TLO.Me.Level()) or Core.GetMainAssistPctHPs() <= Config:GetSetting('EmergencyStart'))
                end,
            },
            {
                name = "PBAEStunSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if (Config:GetSetting('DoAEStun') == 2 and Core.GetMainAssistPctHPs() > Config:GetSetting('EmergencyStart')) or Config:GetSetting('DoAEStun') == 1 then return false end
                    return Casting.DetSpellCheck(spell) and Targeting.GetXTHaterCount() >= Config:GetSetting('AECount')
                end,
            },

            -- { --this can be readded once we creat a post_activate to cancel the debuff you receive after
            --     name = "Self Stasis",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Config.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 30
            --     end,
            -- },
            -- { --This can interrupt spellcasting which can just make something worse. Let us trust healers and tanks.
            --     name = "Dimensional Instability",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Config.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 30
            --     end,
            -- },
            {
                name = "Beguiler's Directed Banishment",
                type = "AA",
                cond = function(self, aaName, target)
                    if target.ID() == Config.Globals.AutoTargetID then return false end
                    return mq.TLO.Me.PctAggro() > 99 and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,

            },
            {
                name = "Beguiler's Banishment",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and mq.TLO.SpawnCount("npc radius 20")() > 2
                end,

            },
            {
                name = "Doppelganger",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            -- { --This can interrupt spellcasting which can just make something worse. Let us trust healers and tanks.
            --     name = "Dimensional Shield",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Config.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 80            --     end,

            -- },
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() >= 90
                end,

            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() >= 60
                end,

            },
        },
        ['DPS(Default)'] = {
            {
                name = "TwinCastMez",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('TwincastMez') ~= 3 or Modules:ExecModule("Mez", "IsMezImmune", target.ID()) then return false end
                    return not Casting.IHaveBuff(spell) and not Casting.IHaveBuff("Twincast")
                end,
            },
            {
                name = "MindDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoMindDot') then return false end
                    return Casting.DotSpellCheck(spell) and (Targeting.IsNamed(target) or not Casting.IHaveBuff(spell and spell.Trigger()))
                end,
            },
            {
                name = "StrangleDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStrangleDot') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoNuke') then return false end
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "ManaDrainNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoManaDrain') then return false end
                    return (target.CurrentMana() or 0) > 10 and Casting.HaveManaToNuke()
                end,
            },
        },
        ['DPS(ModernEra)'] = {
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and Casting.HaveManaToNuke()
                end,
            },
            {
                name = "MindDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            { --Mana check used instead of dot mana check because this is spammed like a nuke
                name = "StrangleDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            { --this is not an error, we want the spell twice in a row as part of the rotation.
                name = "StrangleDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "TwinCastMez",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('TwincastMez') ~= 3 or Modules:ExecModule("Mez", "IsMezImmune", target.ID()) then return false end
                    return not Casting.IHaveBuff(spell) and not mq.TLO.Me.Buff("Improved Twincast")()
                end,
            },
            { --used when the chanter or group members are low mana
                name = "ManaTapNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return (mq.TLO.Group.LowMana(80)() or -1) > 1 or not Casting.HaveManaToNuke()
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Illusions of Grandeur",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
            {
                name = "Calculated Insanity",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
            },
            {
                name = "Mental Contortion",
                type = "AA",
                cond = function(self, aaName, target) return Targeting.IsNamed(target) end,
            },
            {
                name = "Chromatic Haze",
                type = "AA",
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
                name = "Spire of Enchantment",
                type = "AA",
                cond = function(self, aaName) return not Casting.IHaveBuff("Illusions of Grandeur") end,
            },
            {
                name = "Phantasmal Opponent",
                type = "AA",
            },
        },
        ['Tash'] = {
            {
                name = "Bite of Tashani",
                type = "AA",
                cond = function(self, aaName)
                    if Targeting.GetXTHaterCount() < Config:GetSetting('AECount') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "TashSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and (not Casting.TargetHasBuff("Bite of Tashani") or Targeting.IsNamed(target))
                end,
            },
        },
        ['CripSlow'] = {
            {
                name = "Enveloping Helix",
                type = "AA",
                cond = function(self, aaName, target)
                    if Targeting.GetXTHaterCount() < Config:GetSetting('AECount') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Slowing Helix",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoSlow') then return false end
                    local aaSpell = Casting.GetAASpell(aaName)
                    return Casting.DetAACheck(aaName) and (aaSpell.SlowPct() or 0) > (Targeting.GetTargetSlowedPct())
                end,
            },
            {
                name = "CripSlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSlow') or not Casting.CanUseAA("Slowing Helix") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSlow') or Casting.CanUseAA("Slowing Helix") or Core.GetResolvedActionMapItem('CripSlowSpell') then return false end
                    return Casting.DetSpellCheck(spell) and (spell.RankName.SlowPct() or 0) > (Targeting.GetTargetSlowedPct())
                end,
            },
            {
                name = "CrippleSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoCripple') or Casting.CanUseAA("Slowing Helix") or Core.GetResolvedActionMapItem('CripSlowSpell') then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
    },
    ['Spells']          = {
        {
            gem = 1,
            spells = {
                { name = "TwinCastMez",      cond = function(self) return Config:GetSetting('DoSTMez') and Config:GetSetting('TwincastMez') > 1 end, },
                { name = "MezSpell",         cond = function(self) return Config:GetSetting('DoSTMez') and Config:GetSetting('TwincastMez') == 1 end, },
                { name = "MezAESpell",       cond = function(self) return Config:GetSetting('DoAEMez') end, },
                { name = "CharmSpell",       cond = function(self) return Config:GetSetting('CharmOn') end, },
                { name = "TashSpell",        cond = function(self) return Config:GetSetting('DoTash') end, },
                { name = "CripSlowSpell",    cond = function(self) return (Config:GetSetting('DoSlow') or Config:GetSetting('DoCripple')) and not Casting.CanUseAA("Slowing Helix") end, },
                { name = "SlowSpell",        cond = function(self) return Config:GetSetting('DoSlow') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "CrippleSpell",     cond = function(self) return Config:GetSetting('DoCripple') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "MezAESpell",       cond = function(self) return Config:GetSetting('DoAEMez') end, },
                { name = "CharmSpell",       cond = function(self) return Config:GetSetting('CharmOn') end, },
                { name = "TashSpell",        cond = function(self) return Config:GetSetting('DoTash') end, },
                { name = "CripSlowSpell",    cond = function(self) return (Config:GetSetting('DoSlow') or Config:GetSetting('DoCripple')) and not Casting.CanUseAA("Slowing Helix") end, },
                { name = "SlowSpell",        cond = function(self) return Config:GetSetting('DoSlow') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "CrippleSpell",     cond = function(self) return Config:GetSetting('DoCripple') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "CharmSpell",       cond = function(self) return Config:GetSetting('CharmOn') end, },
                { name = "TashSpell",        cond = function(self) return Config:GetSetting('DoTash') end, },
                { name = "CripSlowSpell",    cond = function(self) return (Config:GetSetting('DoSlow') or Config:GetSetting('DoCripple')) and not Casting.CanUseAA("Slowing Helix") end, },
                { name = "SlowSpell",        cond = function(self) return Config:GetSetting('DoSlow') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "CrippleSpell",     cond = function(self) return Config:GetSetting('DoCripple') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "TashSpell",        cond = function(self) return Config:GetSetting('DoTash') end, },
                { name = "CripSlowSpell",    cond = function(self) return (Config:GetSetting('DoSlow') or Config:GetSetting('DoCripple')) and not Casting.CanUseAA("Slowing Helix") end, },
                { name = "SlowSpell",        cond = function(self) return Config:GetSetting('DoSlow') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "CrippleSpell",     cond = function(self) return Config:GetSetting('DoCripple') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "CripSlowSpell",    cond = function(self) return (Config:GetSetting('DoSlow') or Config:GetSetting('DoCripple')) and not Casting.CanUseAA("Slowing Helix") end, },
                { name = "SlowSpell",        cond = function(self) return Config:GetSetting('DoSlow') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "CrippleSpell",     cond = function(self) return Config:GetSetting('DoCripple') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "SlowSpell",        cond = function(self) return Config:GetSetting('DoSlow') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "CrippleSpell",     cond = function(self) return Config:GetSetting('DoCripple') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "CrippleSpell",     cond = function(self) return Config:GetSetting('DoCripple') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "StripBuffSpell",   cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
        {
            gem = 14,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
    },
    ['PullAbilities']   = {
        {
            id = 'TashSpell',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('TashSpell').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('TashSpell').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('TashSpell')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'StripBuffSpell',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('StripBuffSpell').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('StripBuffSpell').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('StripBuffSpell')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']   = {
        ['Mode']               = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this PC. Default: The original RGMercs Config. ModernEra: DPS rotation and spellset aimed at modern live play (~90+)",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What are the different Modes about?",
            Answer = "The Default Mode is the original RGMercs configuration designed for levels 1 - 90.\n" ..
                "ModernEra Mode is a DPS rotation and spellset aimed at modern live play (~90+).\n" ..
                "The ModernEra Mode is designed to be used with the ModernEra DPS rotation and spellset.\n" ..
                "It should function well starting around level 90, but may not fully come into its own for a few levels after.",
        },

        --Buffs
        ['DoLearners']         = {
            DisplayName = "Do Learners",
            Category = "Buffs",
            Index = 1,
            Tooltip = "Set to use the Learner's Aura instead of the Mana Regen Aura.",
            Default = false,
            FAQ = "How do I use my Learner's Aura?",
            Answer = "To use your Learner's Aura, set [DoLearners] to true in your PC's configuration.\n" ..
                "This will cause your PC to use the Learner's Aura instead of the Mana Regen Aura.",
        },
        ['RuneChoice']         = {
            DisplayName = "Rune Selection:",
            Category = "Buffs",
            Index = 2,
            Tooltip = "Select which line of Rune spells you prefer to use.\nPlease note that after level 73, the group rune has a built-in hate reduction when struck.",
            Type = "Combo",
            ComboOptions = { 'Single Target', 'Group', 'Off', },
            Default = 2,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            FAQ = "Why am I putting an aggro-reducing buff on the tank?",
            Answer =
            "You can configure your rune selections to use a single-target hate increasing rune on the tank, while using group (hate reducing) or single target runes on others.",
        },
        ['DoAggroRune']        = {
            DisplayName = "Do Aggro Rune",
            Category = "Buffs",
            Index = 3,
            Tooltip = "Enable casting the Tank Aggro Rune",
            Default = true,
            FAQ = "Why am I not using the Aggro Rune?",
            Answer = "The [DoAggroRune] setting determines whether or not your PC will cast the Tank Aggro Rune.\n" ..
                "If you are not using the Aggro Rune, you may need to Enable the [DoAggroRune] setting.",
        },
        ['DoGroupSpellShield'] = {
            DisplayName = "Do Group Spellshield",
            Category = "Buffs",
            Index = 4,
            Tooltip = "Enable casting the Group Spell Shield Line.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not using Group Spell Shield?",
            Answer = "The Do Group Spellshield setting determines whether or not your PC will cast the Group Spell Shield Line.\n" ..
                "If you are not using Group DoT Shield, you may need to Enable the Do Group Spellshield setting.",
        },
        ['DoGroupDotShield']   = {
            DisplayName = "Do Group DoT Shield",
            Category = "Buffs",
            Index = 5,
            Tooltip = "Enable casting the Group DoT Shield Line.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not using Group DoT Shield?",
            Answer = "The [DoGroupDotShield] setting determines whether or not your PC will cast the Group DoT Shield Line.\n" ..
                "If you are not using Group DoT Shield, you may need to Enable the [DoGroupDotShield] setting.",
        },
        ['DoGroupAuspice']     = {
            DisplayName = "Do Group Auspice",
            Category = "Buffs",
            Index = 6,
            Tooltip = "Enable casting the Group Auspice Buff Line.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not using Group Auspice Buff?",
            Answer = "The [DoGroupAuspice] setting determines whether or not your PC will cast the Group Auspice Buff.\n" ..
                "If you are not using Group Auspice Buff, you may need to Enable the setting.",
        },
        ['DoProcBuff']         = {
            DisplayName = "Do Spellproc Buff",
            Category = "Buffs",
            Index = 7,
            Tooltip = "Enable casting the spell proc (Mana ... ) line.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I using a spell proc buff on ... class?",
            Answer = "By default, the spell proc buff will be used on any casters (including tanks/hybrids). You can change this option on the Buffs tab.",
        },
        ['DoNDTBuff']          = {
            DisplayName = "Cast NDT",
            Category = "Buffs",
            Index = 8,
            Tooltip = "Enable casting use Melee Proc Buff (Night's Dark Terror Line).",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not using NDT?",
            Answer = "The [DoNDTBuff] setting determines whether or not your PC will cast the Night's Dark Terror Line.\n" ..
                "Please note that the single target versions are only set to be used on melee.",
        },

        --Debuffs
        ['DoTash']             = {
            DisplayName = "Do Tash",
            Category = "Debuffs",
            Tooltip = "Cast Tash Spells",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not Tashing?",
            Answer = "The [DoTash] setting determines whether or not your PC will cast Tash Spells.\n" ..
                "If you are not Tashing, you may need to Enable the [DoTash] setting.",
        },
        ['DoSlow']             = {
            DisplayName = "Cast Slow",
            Category = "Debuffs",
            Tooltip = "Enable casting Slow spells.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not Slowing?",
            Answer = "The [DoSlow] setting determines whether or not your PC will cast Slow spells.\n" ..
                "If you are not Slowing, you may need to Enable the [DoSlow] setting.",
        },
        ['DoCripple']          = {
            DisplayName = "Cast Cripple",
            Category = "Debuffs",
            Tooltip = "Enable casting Cripple spells.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not Crippling?",
            Answer = "The [DoCripple] setting determines whether or not your PC will cast Cripple spells.\n" ..
                "If you are not Crippling, you may need to Enable the [DoCripple] setting.\n" ..
                "Please note that eventually, Cripple and Slow lines are merged together in the Helix line.",
        },
        ['DoStripBuff']        = {
            DisplayName = "Do Strip Buffs",
            Category = "Debuffs",
            Tooltip = "Enable removing beneficial enemy effects.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not stripping buffs?",
            Answer = "The [DoStripBuff] setting determines whether or not your PC will remove beneficial enemy effects.\n" ..
                "If you are not stripping buffs, you may need to Enable the [DoStripBuff] setting.",
        },

        --Combat
        ['AECount']            = {
            DisplayName = "AE Count",
            Category = "Combat",
            Index = 1,
            Tooltip = "Number of XT Haters before we will use AE Slow, Tash, or Stun.",
            Min = 1,
            Default = 3,
            Max = 15,
            FAQ = "Why am I not using AE Abilities?",
            Answer = "Adjust your AE Count on the Combat Tab.",
        },
        ['DoAEStun']           = {
            DisplayName = "PBAE Stun use:",
            Category = "Combat",
            Index = 2,
            Tooltip = "When to use your PBAE Stun Line.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Never', 'At low MA health', 'Whenever Possible', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why am I stunning everything?!??",
            Answer = "You can choose the conditions under which you will use your PBAE Stun on the Combat tab.",
        },
        ['TwincastMez']        = {
            DisplayName = "TwinCast Mez Usage:",
            Category = "Combat",
            Index = 3,
            Tooltip = "If selected, will replace the standard ST Mez with an option that gives a DD twincast effect.",
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Disabled', 'As ST Mez', 'As Mez and to Trigger Twincast', },
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "Can you explain TwinCast Mez usage in more detail?",
            Answer =
                "Disabled: We will use our standard ST Mez in Gem 1.\n" ..
                "As ST Mez: We will use the Twincast Mez as our ST Mez in Gem 1.\n" ..
                "As Mez and to Trigger Twincast: As above and we will also use this spell in combat to trigger the twincast effect.",
        },
        ['EmergencyStart']     = {
            DisplayName = "Emergency Start",
            Category = "Combat",
            Index = 4,
            Tooltip = "The HP % emergency abilities will be used (Abilities used depend on whose health is low, the ENC or the MA).",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why am I not using my emergency abilities?",
            Answer = "You may need to tailor the emergency thresholds to your current survivability and target choice.",
        },
        ['DoChestClick']       = {
            DisplayName = "Do Chest Click",
            Category = "Combat",
            Index = 5,
            Tooltip = "Click your equipped chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "Why am I not clicking my chest item?",
            Answer = "Most Chest slot items after level 75ish have a clickable effect.\n" ..
                "ENC is set to use theirs during burns, so long as the item equipped has a clicky effect.",
        },

        --DPS Low Level
        ['DoNuke']             = {
            DisplayName = "Magic Nuke",
            Category = "DPS Low Level",
            Index = 1,
            Tooltip = "Use your magic nuke in the Default early/midgame DPS rotation.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "How can I use my magic Nuke?",
            Answer = "You can enable the magic nuke line in the Spells and Abilities tab.",
        },
        ['DoManaDrain']        = {
            DisplayName = "Mana Drain Nuke",
            Category = "DPS Low Level",
            Index = 2,
            Tooltip = "Use your mana drain nuke in the Default early/midgame DPS rotation.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "How can I use my mana drain nuke?",
            Answer = "You can enable the mana drain nuke line in the Spells and Abilities tab.",
        },
        ['DoStrangleDot']      = {
            DisplayName = "Strangle Dot",
            Category = "DPS Low Level",
            Index = 3,
            Tooltip = "Use your magic damage (Strangle Line) Dot in the Default early/midgame DPS rotation.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "I turned Cast DOTS off, why am I still using them?",
            Answer = "The Modern Era mode does not respect this setting, as DoTs are integral to the DPS rotation.",
        },
        ['DoMindDot']          = {
            DisplayName = "Mind Dot",
            Category = "DPS Low Level",
            Index = 4,
            Tooltip = "Use your mana drain/magic damage (Mind Line) Dot on Named in the Default early/midgame DPS rotation.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not using my Mind Dot when I have it selected?",
            Answer = "This Dot is set to be used on named or when you don't already have the recourse active.",
        },
    },
}

return _ClassConfig
