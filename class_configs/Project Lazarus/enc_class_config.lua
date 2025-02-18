local mq           = require('mq')
local Config       = require('utils.config')
local Modules      = require("utils.modules")
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Logger       = require("utils.logger")

local _ClassConfig = {
    _version            = "1.2 - Project Lazarus",
    _author             = "Derple, Grimmier, Algar, Robban",
    ['ModeChecks']      = {
        CanMez     = function() return true end,
        CanCharm   = function() return true end,
        IsCharming = function() return Config:GetSetting('CharmOn') end,
        IsMezzing  = function() return true end,
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
            "Illusionist's Aura",
            "Beguiler's Aura",
        },
        ['VisageAura'] = {
            "Aura of Endless Glamour",
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
            "Boon of the Legion",
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
        -- ['AggroRune'] = {
        --     "Disquieting Rune",
        --     "Ghastly Rune",
        --     "Horrendous Rune",
        --     "Dreadful Rune",
        --     "Frightening Rune",
        --     "Terrifying Rune",
        --     "Horrifying Rune",
        -- },
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
        -- ['SingleDotShield'] = {
        --     "Aegis of Xetheg",
        --     "Aegis of Cekenar",
        --     "Aegis of Milyex",
        --     "Aegis of the Indagator",
        --     "Aegis of the Keeper",
        -- },
        -- ['GroupDotShield'] = {
        --     "Legion of Dhakka",
        --     "Legion of Xetheg",
        --     "Legion of Cekenar",
        --     "Legion of Milyex",
        --     "Legion of the Indagator",
        --     "Legion of the Keeper",
        -- },
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
            "Mana Recursion",
            "Mana Flare",
        },
        ['AllianceSpell'] = {
            "Chromatic Conjunction",
            "Chromatic Coalition",
            "Chromatic Covenant",
            "Chromatic Alliance",
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
            "Synaptic Seizure",
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
            "Abashi's Disempowerment",
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
        ['DotSpell1'] = {
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
        ['NukeSpell'] = {
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
        --Unused table, temporarily removed - was causing conflicts while resolving NukeSpell action maps (will revisit nukes later)
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
        ['HasteManaCombo'] = {
            "Unified Alacrity",
        },
    },
    ['RotationOrder']   = {
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.DoBuffCheck() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.DoBuffCheck()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.DoPetCheck() and not Core.IsCharming() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 60,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.DoPetCheck()
            end,
        },
        { --Slow and Tash separated so we use both before we start DPS
            name = 'Tash',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoTash') end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state, targetId)
                return combat_state == "Combat" and Casting.DebuffConCheck() and not Casting.IAmFeigning() and
                    (Casting.HaveManaToDebuff() or Targeting.IsNamed(mq.TLO.Spawn(targetId)))
            end,
        },
        { --Slow and Tash separated so we use both before we start DPS
            name = 'Slow',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSlow') end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state, targetId)
                return combat_state == "Combat" and Casting.DebuffConCheck() and not Casting.IAmFeigning() and
                    (Casting.HaveManaToDebuff() or Targeting.IsNamed(mq.TLO.Spawn(targetId)))
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and not Casting.IAmFeigning()
            end,
        },
        { --AA Stuns, Runes, etc, moved from previous home in DPS
            name = 'CombatSupport',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS(Default)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive("Default") end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS(ModernEra)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive("ModernEra") end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'ArcanumWeave',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoArcanumWeave') and Casting.CanUseAA("Acute Focus of Arcanum") end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and not mq.TLO.Me.Buff("Focus of Arcanum")()
            end,
        },
    },
    ['HelperFunctions'] = { --used to autoinventory our azure crystal after summon
        StashCrystal = function()
            mq.delay("2s", function() return mq.TLO.Cursor() and mq.TLO.Cursor.ID() == mq.TLO.Spell("Azure Mind Crystal").Base(1)() end)

            if not mq.TLO.Cursor() then
                Logger.log_debug("No valid item found on cursor, item handling aborted.")
                return false
            end

            Logger.log_info("Sending the %s to our bags.", mq.TLO.Cursor())
            mq.delay(150)
            Core.DoCmd("/autoinventory")
        end,
    },
    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "Orator's Unity",
                type = "AA",
                active_cond = function(self, aaName) return Casting.BuffActiveByName(aaName) end,
                cond = function(self, aaName) return Casting.SelfBuffAACheck(aaName) and Casting.AAReady(aaName) end,
            },
            {
                name = "SelfGuardShield",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "MezBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune2",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "Veil of Mindshadow",
                type = "AA",
                active_cond = function(self, aaName) return Casting.BuffActiveByName(aaName) end,
                cond = function(self, aaName) return Casting.SelfBuffAACheck(aaName) and Casting.AAReady(aaName) end,
            },
            {
                name = "Azure Mind Crystal",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.FindItem(aaName)() ~= nil end,
                cond = function(self, aaName) return mq.TLO.Me.PctMana() > 90 and not mq.TLO.FindItem(aaName)() and Casting.AAReady(aaName) end,
                post_activate = function(self, aaName, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.StashCrystal)
                    end
                end,
            },
            {
                name = "Gather Mana",
                type = "AA",
                active_cond = function(self, aaName) return Casting.AAReady(aaName) end,
                cond = function(self, aaName) return mq.TLO.Me.PctMana() < 60 and Casting.AAReady(aaName) end,
            },
            {
                name = "Auroria Mastery",
                type = "AA",
                active_cond = function(self) return Casting.AuraActiveByName("Aura of Bedazzlement") end,
                pre_activate = function(self) -- remove the old aura if we leveled up, otherwise we will be spammed because of no focus.
                    if not Casting.AuraActiveByName("Aura of Bedazzlement") then
                        ---@diagnostic disable-next-line: undefined-field
                        mq.TLO.Me.Aura(1).Remove()
                    end
                end,
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and not Casting.AuraActiveByName("Aura of Bedazzlement")
                end,
            },
            {
                name = "SpellProcAura",
                type = "Spell",
                active_cond = function(self, spell)
                    local aura = string.sub(spell.Name() or "", 1, 8)
                    return Casting.AuraActiveByName(aura) or Casting.AuraActiveByName("Aura of Bedazzlement")
                end,
                pre_activate = function(self, spell)                  -- remove the old aura if we leveled up or changed options, otherwise we will be spammed because of no focus.
                    local aura = string.sub(spell.Name() or "", 1, 8) -- we use a string sub because aura name doesn't have the apostrophe the spell name does
                    if not Casting.AuraActiveByName(aura) then
                        ---@diagnostic disable-next-line: undefined-field
                        mq.TLO.Me.Aura(1).Remove()
                    end
                end,
                cond = function(self, spell)
                    if Casting.CanUseAA('Auroria Mastery') or Config:GetSetting('UseAura') ~= 1 then return false end
                    local aura = string.sub(spell.Name() or "", 1, 8)
                    return Casting.SpellReady(spell) and not Casting.AuraActiveByName(aura)
                end,
            },
            {
                name = "TwincastAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.Name()) end,
                pre_activate = function(self, spell) -- remove the old aura if we changed options, otherwise we will be spammed because of no focus.
                    if not Casting.AuraActiveByName(spell.Name()) then
                        ---@diagnostic disable-next-line: undefined-field
                        mq.TLO.Me.Aura(1).Remove()
                    end
                end,
                cond = function(self, spell)
                    if Casting.CanUseAA('Auroria Mastery') or Config:GetSetting('UseAura') ~= 2 then return false end
                    return Casting.SpellReady(spell) and not Casting.AuraActiveByName(spell.Name())
                end,
            },
            {
                name = "VisageAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.Name()) end,
                pre_activate = function(self, spell) -- remove the old aura if we changed options, otherwise we will be spammed because of no focus.
                    if not Casting.AuraActiveByName(spell.Name()) then
                        ---@diagnostic disable-next-line: undefined-field
                        mq.TLO.Me.Aura(1).Remove()
                    end
                end,
                cond = function(self, spell)
                    if Casting.CanUseAA('Auroria Mastery') or Config:GetSetting('UseAura') ~= 3 then return false end
                    return Casting.SpellReady(spell) and not Casting.AuraActiveByName(spell.Name())
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell) return Casting.ReagentCheck(spell) end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetBuffSpell",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.ID()).ID() end,
                cond = function(self, spell) return Casting.SelfBuffPetCheck(spell) end,
            },
            {
                name = "Fortify Companion",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffPetCheck(mq.TLO.Me.AltAbility(aaName).Spell) and Casting.AAReady(aaName)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "HasteManaCombo",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ManaRegen",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if self:GetResolvedActionMapItem('HasteManaCombo') or not Config.Constants.RGCasters:contains(target.Class.ShortName()) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HasteBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if self:GetResolvedActionMapItem('HasteManaCombo') or not Config.Constants.RGMelee:contains(target.Class.ShortName()) then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.GroupBuffCheck(mq.TLO.Spell("Unified Alacrity"), target, 42932) -- Fixes bad stacking check
                end,
            },
            {
                name = "GroupSpellShield",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            -- {
            --     name = "GroupDotShield",
            --     type = "Spell",
            --     active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
            --     cond = function(self, spell, target)
            --         if not Config:GetSetting('DoGroupDotShield') then return false end
            --         return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
            --     end,
            -- },
            {
                name = "GroupAuspiceBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "NdtBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    --NDT will not be cast or memorized if it isn't already on the bar due to a very long refresh time
                    if not Config:GetSetting('DoNDTBuff') or not Casting.CastReady(spell.RankName) then return false end
                    --Single target versions of the spell will only be used on Melee, group versions will be cast if they are missing from any groupmember
                    if (spell and spell() and ((spell.TargetType() or ""):lower() ~= "group v2"))
                        and not Config.Constants.RGMelee:contains(target.Class.ShortName()) then
                        return false
                    end

                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SpellProcBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoProcBuff') or not Config.Constants.RGCasters:contains(target.Class.ShortName()) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if Config:GetSetting('RuneChoice') ~= 2 then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            -- {
            --     name = "AggroRune",
            --     type = "Spell",
            --     active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
            --     cond = function(self, spell, target)
            --         if not Config:GetSetting('DoAggroRune') or not Config.Constants.RGTank:contains(target.Class.ShortName()) then return false end
            --         return Casting.GroupBuffCheck(spell, target)
            --     end,
            -- },
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
        ['CombatSupport'] = {
            {
                name = "Glyph Spray",
                type = "AA",
                cond = function(self, aaName)
                    return ((Targeting.IsNamed(mq.TLO.Target) and mq.TLO.Target.Level() > mq.TLO.Me.Level()) or
                        Core.GetMainAssistPctHPs() < 40) and Casting.AAReady(aaName)
                end,
            },
            {
                name = "Reactive Rune",
                type = "AA",
                cond = function(self, aaName)
                    return ((Targeting.IsNamed(mq.TLO.Target) and mq.TLO.Target.Level() > mq.TLO.Me.Level()) or
                        Core.GetMainAssistPctHPs() < 40) and Casting.AAReady(aaName)
                end,
            },
            -- { --this can be readded once we creat a post_activate to cancel the debuff you receive after
            --     name = "Self Stasis",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Config.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 30 and
            --             Casting.AAReady(aaName)
            --     end,
            -- },
            -- { --This can interrupt spellcasting which can just make something worse. Let us trust healers and tanks.
            --     name = "Dimensional Instability",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Config.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 30 and
            --             Casting.AAReady(aaName)
            --     end,
            -- },
            {
                name = "Beguiler's Directed Banishment",
                type = "AA",
                cond = function(self, aaName, target)
                    if not mq.TLO.Target.ID() == Config.Globals.AutoTargetID then return false end
                    return mq.TLO.Me.PctAggro() > 99 and mq.TLO.Me.PctHPs() <= 40 and Casting.TargetedAAReady(aaName, target.ID())
                end,

            },
            {
                name = "Beguiler's Banishment",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= 50 and mq.TLO.SpawnCount("npc radius 20")() > 2 and Casting.AAReady(aaName)
                end,

            },
            {
                name = "Doppelganger",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= 60 and Casting.AAReady(aaName)
                end,

            },
            -- { --This can interrupt spellcasting which can just make something worse. Let us trust healers and tanks.
            --     name = "Dimensional Shield",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Config.Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 80 and
            --             Casting.AAReady(aaName)
            --     end,

            -- },
            {
                name = "Eldritch Rune",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= 80 and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(mq.TLO.Target) and mq.TLO.Me.PctAggro() >= 90 and Casting.TargetedAAReady(aaName, target.ID())
                end,

            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IsNamed(mq.TLO.Target) and mq.TLO.Me.PctAggro() >= 90 and Casting.AAReady(aaName)
                end,

            },
            {
                name = "Color Shock",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctAggro() >= 90 and Casting.AAReady(aaName)
                end,

            },
            {
                name = "UseAzureMindCrystal",
                type = "CustomFunc",
                cond = function(self)
                    if not Casting.CanUseAA("Azure Mind Crystal") then return false end
                    local crystal = mq.TLO.FindItem("Azure Mind Crystal")
                    if not crystal or crystal() then return false end
                    return crystal.TimerReady() == 0 and mq.TLO.Me.PctMana() <= Config:GetSetting('ModRodManaPct')
                end,
                custom_func = function(self)
                    local crystal = mq.TLO.FindItem("Azure Mind Crystal")
                    return Casting.UseItem(crystal.Name(), mq.TLO.Me.ID())
                end,
            },
        },
        ['DPS(Default)'] = {
            {
                name = "StripBuffSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStripBuff') then return false end
                    return mq.TLO.Target.Beneficial() and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "DotSpell1",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') then return false end
                    return Casting.DotSpellCheck(spell) and (Casting.DotHaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "ManaDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') and Targeting.IsNamed(mq.TLO.Target) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDicho') then return false end
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "NukeSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "ManaDrainSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return (mq.TLO.Target.CurrentMana() or 0) > 10 and (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
        },
        ['DPS(ModernEra)'] = {
            {
                name = "StripBuffSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStripBuff') then return false end
                    return mq.TLO.Target.Beneficial() and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "ManaDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and (Casting.DotHaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "NukeSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            { --Mana check used instead of dot mana check because this is spammed like a nuke
                name = "DotSpell1",
                type = "Spell",
                cond = function(self, spell, target)
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            { --this is not an error, we want the spell twice in a row as part of the rotation.
                name = "DotSpell1",
                type = "Spell",
                cond = function(self, spell, target)
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            { --used when the chanter or group members are low mana
                name = "ManaNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return (mq.TLO.Group.LowMana(80)() or -1) > 1 or not Casting.HaveManaToNuke() and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Illusions of Grandeur",
                type = "AA",
                cond = function(self, aaName) return Casting.AAReady(aaName) end,
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self, aaName) return Casting.AAReady(aaName) end,
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName) return Casting.AAReady(aaName) and Targeting.IsNamed(mq.TLO.Target) end,
            },
            {
                name = "Calculated Insanity",
                type = "AA",
                cond = function(self, aaName) return Casting.AAReady(aaName) end,
            },
            {
                name = "Mental Contortion",
                type = "AA",
                cond = function(self, aaName) return Casting.AAReady(aaName) and Targeting.IsNamed(mq.TLO.Target) end,
            },
            {
                name = "Chromatic Haze",
                type = "AA",
                cond = function(self, aaName) return Casting.AAReady(aaName) end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return Casting.SongActive(item.Spell)
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    if not Config:GetSetting('DoChestClick') or not item or not item() then return false end
                    return not Casting.SongActive(item.Spell) and Casting.SpellStacksOnMe(item.Spell) and item.TimerReady() == 0
                end,
            },
            {
                name = "Spire of Enchantment",
                type = "AA",
                cond = function(self, aaName) return not Casting.SongActiveByName("Illusions of Grandeur") and Casting.AAReady(aaName) end,
            },
            {
                name = "Crippling Aurora",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoCripple') then return false end
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "CrippleSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoCripple') then return false end
                    return Targeting.IsNamed(mq.TLO.Target) and Casting.DetSpellCheck(spell) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "Phantasmal Opponent",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName) return Casting.AAReady(aaName) end,
            },
        },
        ['Tash'] = {
            {
                name = "TashSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Config:GetSetting('DoTash') and Casting.DetSpellCheck(spell) and not mq.TLO.Target.Tashed()
                        and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "Bite of Tashani",
                type = "AA",
                cond = function(self, aaName, target)
                    return Config:GetSetting('DoTash') and Casting.DetSpellCheck(mq.TLO.Me.AltAbility(aaName).Spell) and not mq.TLO.Target.Tashed() and
                        Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
        },
        ['Slow'] = {
            {
                name = "Enveloping Helix",
                type = "AA",
                cond = function(self, aaName, target)
                    if Targeting.GetXTHaterCount() < Config:GetSetting('AESlowCount') then return false end
                    return Casting.DetSpellCheck(mq.TLO.Me.AltAbility(aaName).Spell) and Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Dreary Deeds",
                type = "AA",
                cond = function(self, aaName, target)
                    local aaSpell = mq.TLO.Me.AltAbility(aaName).Spell
                    return Casting.DetSpellCheck(aaSpell) and (aaSpell.SlowPct() or 0) > Targeting.GetTargetSlowedPct() and
                        Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Dreary Deeds") then return false end
                    return Casting.DetSpellCheck(spell) and (spell.RankName.SlowPct() or 0) > (Targeting.GetTargetSlowedPct()) and
                        Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
        },
        ['ArcanumWeave'] = {
            {
                name = "Empowered Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Enlightened Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Acute Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
    },
    ['Spells']          = {
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
                { name = "CharmSpell",     cond = function(self) return Config:GetSetting('CharmOn') and Core.IsModeActive("ModernEra") end, },
                { name = "StripBuffSpell", cond = function(self) return Config:GetSetting('DoStripBuff') and Core.IsModeActive("ModernEra") end, },
                { name = "TashSpell",      cond = function(self) return not Casting.CanUseAA("Bite of Tashani") end, },
                { name = "SpellProcBuff",  cond = function(self) return Config:GetSetting('DoProcBuff') end, },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "SlowSpell",      cond = function(self) return not Casting.CanUseAA("Dreary Deeds") end, },
                { name = "ManaDrainSpell", cond = function(self) return true end, },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "ManaDot",    cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "CharmSpell", cond = function(self) return Config:GetSetting('CharmOn') end, },
                { name = "NdtBuff", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "NukeSpell", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "DotSpell1", },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "ManaNuke",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "CrippleSpell",   cond = function(self) return Config:GetSetting('DoCripple') end, },
                { name = "StripBuffSpell", cond = function(self) return Config:GetSetting('DoStripBuff') end, },
                { name = "ManaDrainSpell", cond = function(self) return true end, },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "NdtBuff",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDot",       cond = function(self) return true end, },
                { name = "SpellProcBuff", cond = function(self) return Config:GetSetting('DoProcBuff') end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SingleRune",    cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",     cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "SpellProcBuff", cond = function(self) return Config:GetSetting('DoProcBuff') end, },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "GroupSpellShield", cond = function(self) return true end, },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SpellProcBuff", cond = function(self) return Config:GetSetting('DoProcBuff') and Core.IsModeActive("ModernEra") end, },
                { name = "DichoSpell",    cond = function(self) return true end, },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainSpell",   cond = function(self) return Core.IsModeActive("Default") end, },
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
        ['Mode']           = {
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
        ['UseAura']        = {
            DisplayName = "Aura Selection:",
            Category = "Buffs",
            Index = 1,
            Tooltip = "Select the Aura to be used, if any, prior to purchasing the Auroria Mastery AA.",
            Type = "Combo",
            ComboOptions = { 'Spell Proc', 'Twincast', 'Visage', 'None', },
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 4,
            FAQ = "Why am I using the wrong aura?",
            Answer = "Aura choice can be made on the buff tab.\n" ..
                "Once the PC has purchased Auroria Mastery, this setting is ignored in favor of using the AA.",
        },
        ['DoArcanumWeave'] = {
            DisplayName = "Weave Arcanums",
            Category = "Buffs",
            Tooltip = "Weave Empowered/Enlighted/Acute Focus of Arcanum into your standard combat routine (Focus of Arcanum is saved for burns).",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = true,
            FAQ = "What is an Arcanum and why would I want to weave them?",
            Answer =
            "The Focus of Arcanum series of AA decreases your spell resist rates.\nIf you have purchased all four, you can likely easily weave them to keep 100% uptime on one.",
        },
        ['AESlowCount']    = {
            DisplayName = "Slow Count",
            Category = "Debuffs",
            Tooltip = "Number of XT Haters before we start AE slowing",
            Min = 1,
            Default = 2,
            Max = 10,
            FAQ = "Why am I not AE slowing?",
            Answer = "The [AESlowCount] setting determines the number of XT Haters before we start AE slowing.\n" ..
                "If you are not AE slowing, you may need to adjust the [AESlowCount] setting.",
        },
        ['DoTash']         = {
            DisplayName = "Do Tash",
            Category = "Debuffs",
            Tooltip = "Cast Tash Spells",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not Tashing?",
            Answer = "The [DoTash] setting determines whether or not your PC will cast Tash Spells.\n" ..
                "If you are not Tashing, you may need to Enable the [DoTash] setting.",
        },
        ['DoDot']          = {
            DisplayName = "Cast DOTs",
            Category = "Combat",
            Tooltip = "Enable casting Damage Over Time spells. (Dots always used for ModernEra Mode)",
            Default = true,
            FAQ = "I turned Cast DOTS off, why am I still using them?",
            Answer = "The Modern Era mode does not respect this setting, as DoTs are integral to the DPS rotation.",
        },
        ['DoSlow']         = {
            DisplayName = "Cast Slow",
            Category = "Debuffs",
            Tooltip = "Enable casting Slow spells.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not Slowing?",
            Answer = "The [DoSlow] setting determines whether or not your PC will cast Slow spells.\n" ..
                "If you are not Slowing, you may need to Enable the [DoSlow] setting.",
        },
        ['DoCripple']      = {
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
        ['DoDicho']        = {
            DisplayName = "Cast Dicho",
            Category = "Combat",
            Tooltip = "Enable casting Dicho spells.(Dicho always used for ModernEra Mode)",
            Default = true,
            FAQ = "Why am I not using Dicho spells?",
            Answer = "The Cast Dicho setting determines whether or not your PC will cast Dicho spells.\n" ..
                "Modern Era mode will always use the Dicho spell as a core part of its function.",
        },
        ['DoNDTBuff']      = {
            DisplayName = "Cast NDT",
            Category = "Buffs",
            Tooltip = "Enable casting use Melee Proc Buff (Night's Dark Terror Line).",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not using NDT?",
            Answer = "The [DoNDTBuff] setting determines whether or not your PC will cast the Night's Dark Terror Line.\n" ..
                "Please note that the single target versions are only set to be used on melee.",
        },
        ['RuneChoice']     = {
            DisplayName = "Rune Selection:",
            Category = "Buffs",
            Index = 1,
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
        -- ['DoAggroRune']      = {
        --     DisplayName = "Do Aggro Rune",
        --     Category = "Buffs",
        --     Index = 2,
        --     Tooltip = "Enable casting the Tank Aggro Rune",
        --     Default = true,
        --     FAQ = "Why am I not using the Aggro Rune?",
        --     Answer = "The [DoAggroRune] setting determines whether or not your PC will cast the Tank Aggro Rune.\n" ..
        --         "If you are not using the Aggro Rune, you may need to Enable the [DoAggroRune] setting.",
        -- },
        -- ['DoGroupDotShield'] = {
        --     DisplayName = "Do Group DoT Shield",
        --     Category = "Buffs",
        --     Index = 3,
        --     Tooltip = "Enable casting the Group DoT Shield Line.",
        --     Default = true,
        --     FAQ = "Why am I not using Group DoT Shield?",
        --     Answer = "The [DoGroupDotShield] setting determines whether or not your PC will cast the Group DoT Shield Line.\n" ..
        --         "If you are not using Group DoT Shield, you may need to Enable the [DoGroupDotShield] setting.",
        -- },
        ['DoProcBuff']     = {
            DisplayName = "Do Spellproc Buff",
            Category = "Buffs",
            Index = 4,
            Tooltip = "Enable casting the spell proc (Mana ... ) line.",
            Default = true,
            FAQ = "Why am I using a spell proc buff on ... class?",
            Answer = "By default, the spell proc buff will be used on any casters (including tanks/hybrids). You can change this option on the Buffs tab.",
        },
        ['DoStripBuff']    = {
            DisplayName = "Do Strip Buffs",
            Category = "Debuffs",
            Tooltip = "Enable removing beneficial enemy effects.",
            Default = true,
            FAQ = "Why am I not stripping buffs?",
            Answer = "The [DoStripBuff] setting determines whether or not your PC will remove beneficial enemy effects.\n" ..
                "If you are not stripping buffs, you may need to Enable the [DoStripBuff] setting.",
        },
        ['DoChestClick']   = {
            DisplayName = "Do Chest Click",
            Category = "Combat",
            Tooltip = "Click your equipped chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "Why am I not clicking my chest item?",
            Answer = "Most Chest slot items after level 75ish have a clickable effect.\n" ..
                "ENC is set to use theirs during burns, so long as the item equipped has a clicky effect.",
        },
    },
}

return _ClassConfig
