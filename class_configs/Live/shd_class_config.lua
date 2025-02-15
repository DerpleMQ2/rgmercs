local mq           = require('mq')
local ItemManager  = require("utils.item_manager")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Ui           = require("utils.ui")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Logger       = require("utils.logger")

--todo: add a LOT of tooltips or scrap them entirely. Hopefully the former.
local Tooltips     = {
    Mantle              = "Spell Line: Melee Absorb Proc",
    Carapace            = "Spell Line: Melee Absorb Proc",
    CombatEndRegen      = "Discipline Line: Endurance Regen (In-Combat Useable)",
    EndRegen            = "Discipline Line: Endurance Regen (Out of Combat)",
    Blade               = "Ability Line: Double 2HS Attack w/ Accuracy Mod",
    Crimson             = "Disicpline Line: Triple Attack w/ Accuracy Mod",
    MeleeMit            = "Discipline Line: Absorb Incoming Dmg",
    Deflection          = "Discipline: Shield Block Chance 100%",
    LeechCurse          = "Discipline: Melee LifeTap w/ Increase Hit Chance",
    UnholyAura          = "Discipline: Increase LifeTap Spell Damage",
    Guardian            = "Discipline: Melee Mitigation w/ Defensive LifeTap & Lowered Melee DMG Output",
    PetSpell            = "Spell Line: Summons SK Pet",
    PetHaste            = "Spell Line: Haste Buff for SK Pet",
    Shroud              = "Spell Line: Add Melee LifeTap Proc",
    Horror              = "Spell Line: Proc HP Return",
    Mental              = "Spell Line: Proc Mana Return",
    Skin                = "Spell Line: Melee Absorb Proc",
    SelfDS              = "Spell Line: Self Damage Shield",
    Demeanor            = "Spell Line: Add LifeTap Proc Buff on Killshot",
    HealBurn            = "Spell Line: Add Hate Proc on Incoming Spell Damage",
    CloakHP             = "Spell Line: Increase HP and Stacking DS",
    Covenant            = "Spell Line: Increase Mana Regen + Ultravision / Decrease HP Per Tick",
    CallAtk             = "Spell Line: Increase Attack / Decrease HP Per Tick",
    AETaunt             = "Spell Line: PBAE Hate Increase + Taunt",
    PoisonDot           = "Spell Line: Poison Dot",
    SpearNuke           = "Spell Line: Instacast Disease Nuke",
    BondTap             = "Spell Line: LifeTap DOT",
    DireTap             = "Spell Line: LifeTap",
    LifeTap             = "Spell Line: LifeTap",
    BuffTap             = "Spell Line: Dmg + Max HP Buff + Hate Increase",
    BiteTap             = "Spell Line: LifeTap + ManaTap",
    ForPower            = "Spell Line: Hate Increase + Hate Increase DOT + AC Buff 'BY THE POWER OF GRAYSKULL, I HAVE THE POWER -- HE-MAN'",
    Terror              = "Spell Line: Hate Increase + Taunt",
    TempHP              = "Spell Line: Temporary Hitpoints (Decrease per Tick)",
    Dicho               = "Spell Line: Hate Increase + LifeTap",
    Torrent             = "Spell Line: Attack Tap",
    SnareDot            = "Spell Line: Snare + HP DOT",
    Acrimony            = "Spell Increase: Aggrolock + LifeTap DOT + Hate Generation",
    SpiteStrike         = "Spell Line: LifeTap + Caster 1H Blunt Increase + Target Armor Decrease",
    ReflexStrike        = "Ability: Triple 2HS Attack + HP Increase",
    DireDot             = "Spell Line: DOT + AC Decrease + Strength Decrease",
    AllianceNuke        = "Spell Line: Alliance (Requires Multiple of Same Class) - Increase Spell Damage Taken by Target + Large LifeTap",
    InfluenceDisc       = "Ability Line: Increase AC + Absorb Damage + Melee Proc (LifeTap + Max HP Increase)",
    DLUA                = "AA: Cast Highest Level of Scribed Buffs (Shroud, Horror, Drape, Demeanor, Skin, Covenant, CallATK)",
    DLUB                = "AA: Cast Highest Level of Scribed Buffs (Shroud, Mental, Drape, Demeanor, Skin, Covenant, CallATK)",
    HarmTouch           = "AA: Harms Target HP",
    ThoughtLeech        = "AA: Harms Target HP + Harms Target Mana",
    VisageOfDeath       = "Spell: Increases Melee Hit Dmg + Illusion",
    LeechTouch          = "AA: LifeTap Touch",
    Tvyls               = "Spell: Triple 2HS Attack + % Melee Damage Increase on Target",
    ActivateShield      = "Activate 'Shield' if set in Bandolier",
    Activate2HS         = "Activate '2HS' if set in Bandolier",
    ExplosionOfHatred   = "Spell: Targeted AE Hatred Increase",
    ExplosionOfSpite    = "Spell: Targeted PBAE Hatred Increase",
    Taunt               = "Ability: Increases Hatred to 100% + 1",
    EncroachingDarkness = "Ability: Snare + HP DOT",
    Epic                = 'Item: Casts Epic Weapon Ability',
    ViciousBiteOfChaos  = "Spell: Duration LifeTap + Mana Return",
    Bash                = "Use Bash Ability",
    Slam                = "Use Slam Ability",
}

local _ClassConfig = {
    _version            = "1.5 - Live",
    _author             = "Algar, Derple",
    ['ModeChecks']      = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
    },
    ['Modes']           = {
        'Tank',
        'DPS',
    },
    ['Themes']          = {
        ['Tank'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabActive,        color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.5, g = 0.05, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.3, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.2, g = 0.05, b = 0.05, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.0, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.0, g = 0.05, b = 0.05, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
        },
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Innoruuk's Dark Blessing",
            "Innoruuk's Voice",
        },
        ['OoW_Chest'] = {
            "Heartstiller's Mail Chestguard",
            "Duskbringer's Plate Chestguard of the Hateful",
        },
        ['Coating'] = {
            "Spirit Drinker's Coating",
            "Blood Drinker's Coating",
        },
    },
    ['AbilitySets']     = {
        ['Mantle'] = {
            "Ichor Guard", -- Level 56, Timer 5
            "Soul Guard",
            "Soul Shield",
            "Soul Carapace",
            "Umbral Carapace",
            "Malarian Mantle",
            "Gorgon Mantle",
            "Recondite Mantle",
            "Bonebrood Mantle",
            "Doomscale Mantle",
            "Krellnakor Mantle",
            "Restless Mantle",
            "Fyrthek Mantle",
            "Geomimus Mantle",
        },
        ['Carapace'] = {
            -- Added to mantle because we won't use carapace until it becomes Timer 11
            -- "Soul Carapace", -- Level 73, Timer 5
            -- "Umbral Carapace",
            -- "Malarian Carapace", -- much worse than Malarian Mantle and shares a timer
            "Gorgon Carapace", -- Level 88, Timer 11 from here on
            "Sholothian Carapace",
            "Grelleth's Carapace",
            "Vizat's Carapace",
            "Tylix's Carapace",
            "Cadcane's Carapace",
            "Xetheg's Carapace",
            "Kanghammer's Carapace",
        },
        ['EndRegen'] = {
            --Timer 13, can't be used in combat
            "Respite", --Level 86
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
        ['Blade'] = {
            "Incapacitating Blade",
            "Grisly Blade",
            "Gouging Blade",
            "Gashing Blade",
            "Lacerating Blade",
            "Wounding Blade",
            "Rending Blade",
        },
        ['Crimson'] = {
            "Crimson Blade",
            "Scarlet Blade",
            "Carmine Blade",
            "Claret Blade",
            "Cerise Blade",
            "Sanguine Blade",
            "Incarnadine Blade",
        },
        ['MeleeMit'] = {
            -- "Withstand", -- Level 83, extreme endurance problems until 86 when we have Respite and Bard Regen Song gives endurance
            "Defy",
            "Renounce",
            "Reprove",
            "Repel",
            "Spurn",
            "Thwart",
            "Repudiate",
            "Gird",
        },
        ['Deflection'] = { 'Deflection Discipline', },
        ['LeechCurse'] = { 'Leechcurse Discipline', },
        ['UnholyAura'] = { 'Unholy Aura Discipline', },

        ['Guardian'] = {
            "Corrupted Guardian Discipline",
            "Cursed Guardian Discipline",
            "Unholy Guardian Discipline",
        },

        ['PetSpell'] = {
            "Leering Corpse",
            "Bone Walk",
            "Convoke Shadow",
            "Restless Bones",
            "Animate Dead",
            "Summon Dead",
            "Malignant Dead",
            "Cackling Bones",
            "Invoke Death",
            "Son of Decay",
            "Maladroit Minion",
            "Minion of Sebilis",
            "Minion of Fear",
            "Minion of Sholoth",
            "Minion of Grelleth",
            "Minion of Vizat",
            "Minion of T`Vem",
            "Minion of Drendar",
            "Minion of Itzal",
            "Minion of Fandrel",
        },
        ['PetHaste'] = {
            "Gift of Fandrel",
            "Gift of Itzal",
            "Gift of Drendar",
            "Gift of T`Vem",
            "Gift of Lutzen",
            "Gift of Urash",
            "Gift of Dyalgem",
            "Expatiate Death",
            "Amplify Death",
            "Rune of Decay",
            "Augment Death",
            "Strengthen Death",
        },
        ['Shroud'] = { --Some Shrouds listed under the Horror Line as HP/Mana Proc Choice was shroud vs. mental in buff slot 1 at lower levels.
            "Shroud of the Nightborn",
            "Shroud of the Gloomborn",
            "Shroud of the Blightborn",
            "Shroud of the Plagueborne",
            "Shroud of the Shadeborne",
            "Shroud of the Darksworn",
            "Shroud of the Doomscale",
            "Shroud of the Krellnakor",
            "Shroud of the Restless",
            "Shroud of Zelinstein",
            "Shroud of Rimeclaw",
        },
        ['Horror'] = {             -- HP Tap Proc
            "Shroud of Death",     -- Level 55
            "Shroud of Chaos",     -- Level 63
            "Black Shroud",        -- Level 65
            "Shroud of Discord",   -- Level 67 -- Buff Slot 1 <
            "Marrowthirst Horror", -- Level 71 -- Buff Slot 2 >
            "Soulthirst Horror",   -- Level 76
            "Mindshear Horror",    -- Level 81
            "Amygdalan Horror",    -- Level 86
            "Sholothian Horror",   -- Level 91
            "Grelleth's Horror",   -- Level 96
            "Vizat's Horror",      -- Level 101
            "Tylix's Horror",      -- Level 106
            "Cadcane's Horror",    -- Level 111
            "Brightfeld's Horror", -- Level 116
            "Mortimus' Horror",    -- Level 121
        },
        ['Mental'] = {             -- Mana Tap Proc
            "Mental Retchedness",  -- Level 121
            "Mental Anguish",      -- Level 116
            "Mental Torment",      -- Level 111
            "Mental Fright",       -- Level 106
            "Mental Dread",        -- Level 101
            "Mental Terror",       -- Level 96 --Buff Slot 2 <
            "Mental Horror",       -- Level 65 --Buff Slot 1 >
            "Mental Corruption",   -- Level 52
        },
        ['Skin'] = {
            "Decrepit Skin", -- Level 70
            "Umbral Skin",
            "Malarian Skin",
            "Gorgon Skin",
            "Sholothian Skin",
            "Grelleth's Skin",
            "Vizat's Skin",
            "Tylix's Skin",
            "Cadcane's Skin",
            "Xenacious' Skin",
            "Krizad's Skin",
        },
        ['SelfDS'] = {
            "Banshee Aura",
            "Banshee Skin",
            "Ghoul Skin",
            "Zombie Skin",
            "Helot Skin",
            "Specter Skin",
            "Tekuel Skin",
            "Goblin Skin",
        },
        ['Demeanor'] = {
            "Remorseless Demeanor",
            "Impenitent Demeanor",
        },
        ['HealBurn'] = {
            "Harmonious Disruption", -- Level 103
            "Concordant Disruption",
            "Confluent Disruption",
            "Penumbral Disruption",
            "Paradoxical Disruption",
        },
        ['CloakHP'] = {
            "Cloak of the Akheva",
            "Cloak of Luclin",
            "Cloak of Discord",
            "Cloak of Corruption",
            "Drape of Corruption",
            "Drape of Korafax",
            "Drape of Fear",
            "Drape of the Sepulcher",
            "Drape of the Fallen",
            "Drape of the Wrathforged",
            "Drape of the Magmaforged",
            "Drape of the Iceforged",
            "Drape of the Akheva",
            "Drape of the Ankexfen",
        },
        ['Covenant'] = {
            "Grim Covenant",
            "Venril's Covenant",
            "Gixblat's Covenant",
            "Worag's Covenant",
            "Falhotep's Covenant",
            "Livio's Covenant",
            "Helot Covenant",
            "Syl`Tor Covenant",
            "Aten Ha Ra's Covenant",
            "Kar's Covenant",
        },
        ['CallAtk'] = {
            "Call of Darkness",
            "Call of Dusk",
            "Call of Shadow",
            "Call of Gloomhaze",
            "Call of Nightfall",
            "Call of Twilight",
            "Penumbral Call",
            "Call of Blight",
        },
        ['AETaunt'] = {
            "Dread Gaze", -- Level 69
            "Vilify",
            "Revile",
            "Burst of Spite",
            "Loathing",
            "Abhorrence",
            "Disgust",
            "Revulsion",
            "Contempt",
            "Antipathy",
            "Animus",
        },
        ['PoisonDot'] = {
            "Blood of Pain", -- Level 41
            "Blood of Hate",
            "Blood of Discord",
            "Blood of Inruku",
            "Blood of the Blacktalon",
            "Blood of the Blackwater",
            "Blood of Laarthik",
            "Blood of Malthiasiss",
            "Blood of Korum",
            "Blood of Ralstok",
            "Blood of Bonemaw",
            "Blood of Drakus",
            "Blood of Ikatiar",
            "Blood of Tearc",
            "Blood of Shoru",
        },
        ['CorruptionDot'] = {
            "Vitriolic Blight",
            "Unscrupulous Blight",
            "Nefarious Blight",
            "Duplicitous Blight",
            "Deceitful Blight",
            "Surreptitious Blight",
            "Perfidious Blight",
            "Insidious Blight", -- Level 89
        },
        ['SpearNuke'] = {
            "Spike of Disease", -- Level 1
            "Spear of Disease",
            "Spear of Pain",
            "Spear of Plague",
            "Spear of Decay",
            "Miasmic Spear",
            "Spear of Muram",
            "Rotroot Spear",
            "Rotmarrow Spear",
            "Malarian Spear",
            "Gorgon Spear",
            "Spear of Sholoth",
            "Spear of Grelleth",
            "Spear of Vizat",
            "Spear of Tylix",
            "Spear of Cadcane",
            "Spear of Bloodwretch",
            "Spear of Lazam",
        },
        ['BondTap'] = {
            "Bond of Tatalros",
            "Bond of Bynn",
            "Bond of Vulak",
            "Bond of Xalgoz",
            "Bond of Bonemaw",
            "Bond of Ralstok",
            "Bond of Korum",
            "Bond of Malthiasiss",
            "Bond of Laarthik",
            "Bond of the Blackwater",
            "Bond of the Blacktalon",
            "Bond of Inruku",
            "Bond of Death",
            "Vampiric Curse", -- Level 57
        },
        ['DireTap'] = {
            "Dire Implication", -- Level 85
            "Dire Accusation",
            "Dire Allegation",
            "Dire Insinuation",
            "Dire Declaration",
            "Dire Testimony",
            "Dire Indictment",
            "Dire Censure",
            "Dire Rebuke",
        },
        ['LifeTap'] = {
            "Touch of Flariton",
            "Touch of Txiki",
            "Touch of Drendar",
            "Touch of T`Vem",
            "Touch of Lutzen",
            "Touch of Falsin",
            "Touch of Urash",
            "Touch of Falsin",
            "Touch of Dyalgem",
            "Touch of Tharoff",
            "Touch of Kildrukaun",
            "Touch of Severan",
            "Touch of the Devourer",
            "Touch of Inruku",
            "Touch of Innoruuk",
            "Touch of Volatis",
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Life Leech",
            "Lifedraw",
            "Lifespike", -- Level 15
            "Lifetap",   -- Level 8
        },
        ['LifeTap2'] = {
            "Touch of Flariton",
            "Touch of Txiki",
            "Touch of Drendar",
            "Touch of T`Vem",
            "Touch of Lutzen",
            "Touch of Falsin",
            "Touch of Urash",
            "Touch of Falsin",
            "Touch of Dyalgem",
            "Touch of Tharoff",
            "Touch of Kildrukaun",
            "Touch of Severan",
            "Touch of the Devourer",
            "Touch of Inruku",
            "Touch of Innoruuk",
            "Touch of Volatis",
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Life Leech",
            "Lifedraw",
            "Lifespike",
            "Lifetap", -- Level 8
        },
        ['AETap'] = {  --Lifetap/Hate up to 30 targets, level 98+
            "Insidious Repudiation",
            "Insidious Renunciation",
            "Insidious Rejection",
            "Insidious Denial",
            "Deceitful Deflection",
            "Insidious Deflection",
        },
        ['BuffTap'] = {
            "Touch of Mortimus",
            "Touch of Namdrows",
            "Touch of Zlandicar",
            "Touch of Hemofax",
            "Touch of Holmein",
            "Touch of Klonda",
            "Touch of Piqiorn",
            "Touch of Iglum",
            "Touch of Lanys",
            "Touch of the Soulbleeder",
            "Touch of the Wailing Three",
            "Touch of Draygun", -- Level 69
        },
        ['BiteTap'] = {
            "Zevfeer's Bite", -- Level 62
            "Inruku's Bite",
            "Ancient: Bite of Muram",
            "Blacktalon Bite",
            "Blackwater Bite",
            "Laarthik's Bite",
            "Malthiasiss's Bite",
            "Korum's Bite",
            "Ralstok's Bite",
            "Bonemaw's Bite",
            "Xalgoz's Bite",
            "Vulak's Bite",
            "Cruor's Bite",
            "Charka's Bite",
        },
        ['ForPower'] = {
            "Challenge for Power", -- Level 72
            "Trial for Power",
            "Charge for Power",
            "Confrontation for Power",
            "Provocation for Power",
            "Demand for Power",
            "Impose for Power",
            "Refute for Power",   -- TBL - 107
            "Protest for Power",  -- TOV - 112
            "Parlay for Power",   -- TOL - 117
            "Petition for Power", -- LS - 122
        },
        ['Terror'] = {
            "Terror of Darkness", -- Level 33
            "Terror of Shadows",  -- Level 42
            "Terror of Death",
            "Terror of Terris",
            "Terror of Thule",
            "Terror of Discord",
            "Terror of Vergalid",
            "Terror of the Soulbleeder",
            "Terror of Jelvalak",
            "Terror of Rerekalen",
            "Terror of Desalin",
            "Terror of Poira",
            "Terror of Narus",
            "Terror of Kra`Du",
            "Terror of Mirenilla",
            "Terror of Ander",
            "Terror of Tarantis",
        },
        ['Terror2'] = {
            "Terror of Darkness",
            "Terror of Shadows",
            "Terror of Death",
            "Terror of Terris",
            "Terror of Thule",
            "Terror of Discord",
            "Terror of Vergalid",
            "Terror of the Soulbleeder",
            "Terror of Jelvalak",
            "Terror of Rerekalen",
            "Terror of Desalin",
            "Terror of Poira",
            "Terror of Narus",
            "Terror of Kra`Du",
            "Terror of Mirenilla",
            "Terror of Ander",
            "Terror of Tarantis",
        },
        ['TempHP'] = {
            "Unwavering Stance",
            "Adamant Stance",
            "Stormwall Stance",
            "Defiant Stance",
            "Staunch Stance",
            "Steadfast Stance",
            "Stoic Stance",
            "Stubborn Stance",
            "Steely Stance", -- Level 84
        },
        ['Dicho'] = {
            "Dichotomic Fang", -- Level 101
            "Dissident Fang",
            "Composite Fang",
            "Ecliptic Fang",
            "Reciprocal Fang",
        },
        ['Torrent'] = {
            "Torrent of Hate",  -- Level 54
            "Torrent of Pain",  -- Level 56
            "Torrent of Agony", -- Level 100
            "Torrent of Misery",
            "Torrent of Suffering",
            "Torrent of Anguish",
            "Torrent of Melancholy",
            "Torrent of Desolation",
        },
        ['SnareDot'] = {
            "Clinging Darkness", -- Level 11
            "Engulfing Darkness",
            "Dooming Darkness",
            "Cascading Darkness",
            "Festering Darkness",
            "Despairing Darkness",
            "Suppurating Darkness",
            "Smoldering Darkness",
            "Spreading Darkness",
            "Putrefying Darkness",
            "Pestilent Darkness",
            "Virulent Darkness",
            "Vitriolic Darkness",
        },
        ['Acrimony'] = {
            "Undivided Acrimony",
            "Unbroken Acrimony",
            "Unflinching Acrimony",
            "Unyielding Acrimony",
            "Unending Acrimony",
            "Unrelenting Acrimony",
            "Unconditional Acrimony",
        },
        ['SpiteStrike'] = {
            "Spite of Ronak",
            "Spite of Kra`Du",
            "Spite of Mirenilla",
        },
        ['ReflexStrike'] = {
            "Reflexive Resentment",
            "Reflexive Rancor",
            "Reflexive Revulsion",
            "Reflexive Retribution",
        },
        ['DireDot'] = {
            "Dire Constriction", -- Level 85
            "Dire Restriction",
            "Dire Stenosis",
            "Dire Stricture",
            "Dire Strangulation",
            "Dire Coarctation",
            "Dire Convulsion",
            "Dire Seizure",
            "Dire Squelch",
        },
        ['AllianceNuke'] = {
            "Bloodletting Coalition",
            "Bloodletting Alliance",
            "Bloodletting Covenant",
            "Bloodletting Conjunction",
            "Bloodletting Covariance",
        },
        ['InfluenceDisc'] = {
            "Insolent Influence",
            "Impudent Influence",
            "Impenitent Influence",
            "Impertinent Influence",
            "Ignominious Influence",
            "Incensive Influence",
        },
        ['VisageBuff'] = {       --9 minute reuse makes these somewhat ridiculous to gem on the fly.
            "Voice of Thule",    -- level 60, 12% hate
            "Voice of Terris",   -- level 55, 10% hate
            "Voice of Death",    -- level 50, 6% hate
            "Voice of Shadows",  -- level 46, 4% hate
            "Voice of Darkness", -- level 39, 2% hate
        },
    },
    ['HelperFunctions'] = {
        --determine whether we should overwrite DLU buffs with better single buffs
        SingleBuffCheck = function(self)
            if Casting.CanUseAA("Dark Lord's Unity (Azia)") and not Config:GetSetting('OverwriteDLUBuffs') then return false end
            return true
        end,
        --function to determine if we should AE taunt and optionally, if it is safe to do so
        AETauntCheck = function(printDebug)
            local mobs = mq.TLO.SpawnCount("NPC radius 50 zradius 50")()
            local xtCount = mq.TLO.Me.XTarget() or 0

            if (mobs or xtCount) < Config:GetSetting('AETauntCnt') then return false end

            local tauntme = {}
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater")) and xtarg.PctAggro() < 100 and (xtarg.Distance() or 999) <= 50 then
                    if printDebug then
                        Logger.log_verbose("AETauntCheck(): XT(%d) Counting %s(%d) as a hater eligible to AE Taunt.", i, xtarg.CleanName() or "None",
                            xtarg.ID())
                    end
                    table.insert(tauntme, xtarg.ID())
                end
            end
            return #tauntme > 0 and not (Config:GetSetting('SafeAETaunt') and #tauntme < mobs)
        end,
        --function to determine if we have enough mobs in range to use a defensive disc
        DefensiveDiscCheck = function(printDebug)
            local xtCount = mq.TLO.Me.XTarget() or 0
            if xtCount < Config:GetSetting('DiscCount') then return false end
            local haters = {}
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or xtarg.TargetType():lower() == "auto hater")) and (xtarg.Distance() or 999) <= 30 then
                    if printDebug then
                        Logger.log_verbose("DefensiveDiscCheck(): XT(%d) Counting %s(%d) as a hater in range.", i, xtarg.CleanName() or "None", xtarg.ID())
                    end
                    table.insert(haters, xtarg.ID())
                end
            end
            return #haters >= Config:GetSetting('DiscCount')
        end,
        --function to space out Epic and Omens Chest with Mortal Coil old-school swarm style. Epic has an override condition to fire anyway on named.
        LeechCheck = function(self)
            local LeechEffects = { "Leechcurse Discipline", "Mortal Coil", "Lich Sting Recourse", "Leeching Embrace", "Reaper Strike Recourse", "Leeching Touch", }
            for _, buffName in ipairs(LeechEffects) do
                if mq.TLO.Me.Buff(buffName)() or mq.TLO.Me.Song(buffName)() then return false end
            end
            return true
        end,
        --function to make sure we don't have non-hostiles in range before we use AE damage or non-taunt AE hate abilities
        AETargetCheck = function(printDebug)
            local haters = mq.TLO.SpawnCount("NPC xtarhater radius 80 zradius 50")()
            local haterPets = mq.TLO.SpawnCount("NPCpet xtarhater radius 80 zradius 50")()
            local totalHaters = haters + haterPets
            if totalHaters < Config:GetSetting('AETargetCnt') or totalHaters > Config:GetSetting('MaxAETargetCnt') then return false end

            if Config:GetSetting('SafeAEDamage') then
                local npcs = mq.TLO.SpawnCount("NPC radius 80 zradius 50")()
                local npcPets = mq.TLO.SpawnCount("NPCpet radius 80 zradius 50")()
                if totalHaters < (npcs + npcPets) then
                    if printDebug then
                        Logger.log_verbose("AETargetCheck(): %d mobs in range but only %d xtarget haters, blocking AE damage actions.", npcs + npcPets, haters + haterPets)
                    end
                    return false
                end
            end

            return true
        end,
    },
    ['RotationOrder']   = {
        { --Self Buffs
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.DoBuffCheck() and Casting.AmIBuffable()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.DoPetCheck() and Casting.AmIBuffable()
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
        { --Actions that establish or maintain hatred
            name = 'HateTools',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsTanking() end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --Defensive actions triggered by low HP
            name = 'EmergencyDefenses',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
            end,
        },
        { --Prioritized in their own rotation to help keep HP topped to the desired level, includes emergency abilities
            name = 'LifeTaps',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
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
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        { --Defensive actions used proactively to prevent emergencies
            name = 'Defenses',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                --need to look at rotation and decide if it should fire during emergencies. leaning towards no
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout') and
                    Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        { --Offensive actions to temporarily boost damage dealt
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --Non-spell actions that can be used during/between casts
            name = 'CombatWeave',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
        { --DPS Spells, includes recourse/gift maintenance
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyLockout')
            end,
        },
    },
    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "EndRegen",
                type = "Disc",
                tooltip = Tooltips.EndRegen,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.Level() < 106 and mq.TLO.Me.PctEndurance() < 15
                end,
            },
            --If these tables were combined, errors could occur... there is no other good way I can think of to ensure a timer 13 ability that can be used in combat is scribed.
            {
                name = "CombatEndRegen",
                type = "Disc",
                tooltip = Tooltips.CombatEndRegen,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.Level() > 105 and mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Dark Lord's Unity (Azia)",
                type = "AA",
                tooltip = Tooltips.DLUA,
                active_cond = function(self, aaName) return Casting.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(2).ID() or 0) end,
                cond = function(self, aaName, target)
                    if Config:GetSetting('ProcChoice') ~= 1 then return false end
                    --SelfBuffAACheck does not work for this specific AA, it returns a strange spell in the stacking check
                    return Casting.AAReady(aaName) and Casting.GroupBuffCheck(mq.TLO.Me.AltAbility(aaName).Spell, target)
                end,
            },
            {
                name = "Dark Lord's Unity (Beza)",
                type = "AA",
                tooltip = Tooltips.DLUB,
                active_cond = function(self, aaName) return Casting.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(2).ID() or 0) end,
                cond = function(self, aaName, target)
                    if Config:GetSetting('ProcChoice') ~= 2 then return false end
                    --SelfBuffAACheck does not work for this specific AA, it returns a strange spell in the stacking check
                    return Casting.AAReady(aaName) and Casting.GroupBuffCheck(mq.TLO.Me.AltAbility(aaName).Spell, target)
                end,
            },
            {
                name = "Shroud",
                type = "Spell",
                tooltip = Tooltips.Shroud,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Horror",
                type = "Spell",
                tooltip = Tooltips.Horror,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    if Config:GetSetting('ProcChoice') ~= 1 then return false end
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Mental",
                type = "Spell",
                tooltip = Tooltips.Horror,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    if Config:GetSetting('ProcChoice') ~= 2 then return false end
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Demeanor",
                type = "Spell",
                tooltip = Tooltips.Demeanor,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "CloakHP",
                type = "Spell",
                tooltip = Tooltips.CloakHP,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfDS",
                type = "Spell",
                tooltip = Tooltips.SelfDS,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "Covenant",
                type = "Spell",
                tooltip = Tooltips.Covenant,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "CallAtk",
                type = "Spell",
                tooltip = Tooltips.CallAtk,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return self.ClassConfig.HelperFunctions.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            --You'll notice my use of TotalSeconds, this is to keep as close to 100% uptime as possible on these buffs, rebuffing early to decrease the chance of them falling off in combat
            --I considered creating a function (helper or utils) to govern this as I use it on multiple classes but the difference between buff window/song window/aa/spell etc makes it unwieldy
            -- if using duration checks, dont use SelfBuffCheck() (as it could return false when the effect is still on)
            {
                name = "Skin",
                type = "Spell",
                tooltip = Tooltips.Skin,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SpellReady(spell) and Casting.SpellStacksOnMe(spell.RankName) and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 60
                end,
            },
            {
                name = "TempHP",
                type = "Spell",
                tooltip = Tooltips.TempHP,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    if not Config:GetSetting('DoTempHP') or not Casting.CastReady(spell.RankName) then return false end
                    return Casting.SpellReady(spell) and Casting.SpellStacksOnMe(spell.RankName) and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 45
                end,
            },
            {
                name = "HealBurn",
                type = "Spell",
                tooltip = Tooltips.HealBurn,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SpellReady(spell) and Casting.SpellStacksOnMe(spell.RankName) and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "Voice of Thule",
                type = "AA",
                tooltip = Tooltips.VOT,
                active_cond = function(self, aaName) return Casting.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    if not Config:GetSetting('UseVoT') then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name_func = function() return mq.TLO.Me.Inventory("Charm").Name() or "None" end,
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Charm")
                    return item() and Casting.TargetHasBuff(item.Spell, mq.TLO.Me)
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Charm")
                    return Config:GetSetting('DoCharmClick') and item() and Casting.SelfBuffCheck(item.Spell) and item.TimerReady() == 0
                end,
            },
            {
                name = "Scourge Skin",
                type = "AA",
                --tooltip = Tooltips.ScourgeSkin,
                active_cond = function(self, aaName) return Casting.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    if not Core.IsTanking() then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Huntsman's Ethereal Quiver",
                type = "Item",
                active_cond = function(self) return mq.TLO.FindItemCount("Ethereal Arrow")() > 100 end,
                cond = function(self)
                    return Config:GetSetting('SummonArrows') and mq.TLO.Me.Level() > 89 and mq.TLO.FindItemCount("Ethereal Arrow")() < 101 and
                        mq.TLO.Me.ItemReady("Huntsman's Ethereal Quiver")()
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                tooltip = Tooltips.PetSpell,
                active_cond = function(self, spell) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell)
                    if mq.TLO.Me.Pet.ID() ~= 0 or not Config:GetSetting('DoPet') then return false end
                    return Casting.SpellReady(spell) and Casting.ReagentCheck(spell)
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetHaste",
                type = "Spell",
                tooltip = Tooltips.PetHaste,
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName) ~= nil end,
                cond = function(self, spell)
                    return Casting.SpellReady(spell) and Casting.SelfBuffPetCheck(spell)
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
                tooltip = Tooltips.ArmorofExperience,
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and mq.TLO.Me.PctHPs() < 25 and Config:GetSetting('DoVetAA')
                end,
            },
            --Note that on named we may already have a mantle/carapace running already, could make this remove other discs, but meh, Shield Flash still a thing.
            {
                name = "Deflection",
                type = "Disc",
                tooltip = Tooltips.Deflection,
                pre_activate = function(self)
                    if Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyLockout') and not mq.TLO.Me.ActiveDisc.ID() and Casting.DiscReady(discSpell) and
                        (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 0) < 234000
                end,
            },
            {
                name = "Shield Flash",
                type = "AA",
                tooltip = Tooltips.ShieldFlash,
                pre_activate = function(self)
                    if Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline"
                end,
            },
            {
                name = "LeechCurse",
                type = "Disc",
                tooltip = Tooltips.LeechCurse,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyLockout') and not mq.TLO.Me.ActiveDisc.ID() and Casting.DiscReady(discSpell)
                end,
            },
            --Influence is in an odd place with Carapace. Usage is very subjective and may be more nuanced than automation can support. Placed here as an alternative to Carapace in low health situations to get you topped back off again for tanks. Should be used in burn for non-tanks (adding non-tank stuff is TODO)
            {
                name = "InfluenceDisc",
                type = "Disc",
                tooltip = Tooltips.InfluenceDisc,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID() and Core.IsTanking()
                end,
            },
            {
                name = "Carapace",
                type = "Disc",
                tooltip = Tooltips.Carapace,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    if not Config:GetSetting('DoChestClick') then return false end
                    local item = mq.TLO.Me.Inventory("Chest")
                    return item() and item.TimerReady() == 0 and Casting.SpellStacksOnMe(item.Spell)
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                tooltip = Tooltips.Mantle,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            --if we made it this far let's reset our dicho/dire and hope for the best!
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                tooltip = Tooltips.ForcefulRejuv,
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
        },
        ['HateTools'] = {
            --used when we've lost hatred after it is initially established
            {
                name = "Ageless Enmity",
                type = "AA",
                tooltip = Tooltips.AgelessEnmity,
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID()) and Targeting.GetTargetPctHPs() < 90 and mq.TLO.Me.PctAggro() < 100
                end,
            },
            --used to jumpstart hatred on named from the outset and prevent early rips from burns
            {
                name = "Acrimony",
                type = "Disc",
                tooltip = Tooltips.Acrimony,
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell) and Targeting.IsNamed(mq.TLO.Target)
                end,
            },
            --used to reinforce hatred on named
            {
                name = "Veil of Darkness",
                type = "AA",
                tooltip = Tooltips.VeilofDarkness,
                cond = function(self, aaName, target)
                    ---@diagnostic disable-next-line: undefined-field
                    return Casting.TargetedAAReady(aaName, target.ID()) and Targeting.IsNamed(mq.TLO.Target) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 70
                end,
            },
            {
                name = "AETaunt",
                type = "Spell",
                tooltip = Tooltips.AETaunt,
                cond = function(self, spell)
                    if Config:GetSetting('AETauntSpell') == 1 then return false end
                    return Casting.SpellReady(spell) and self.ClassConfig.HelperFunctions.AETauntCheck(true)
                end,
            },
            {
                name = "Explosion of Hatred",
                type = "AA",
                tooltip = Tooltips.ExplosionOfHatred,
                cond = function(self, aaName, target)
                    if not Config:GetSetting('AETauntAA') then return false end
                    return Casting.TargetedAAReady(aaName, target.ID()) and self.ClassConfig.HelperFunctions.AETauntCheck(true)
                end,
            },
            {
                name = "Explosion of Spite",
                type = "AA",
                tooltip = Tooltips.ExplosionOfSpite,
                cond = function(self, aaName)
                    if not Config:GetSetting('AETauntAA') then return false end
                    return Casting.AAReady(aaName) and self.ClassConfig.HelperFunctions.AETauntCheck(true)
                end,
            },
            {
                name = "AETap",
                type = "Spell",
                cond = function(self, spell)
                    if not (Config:GetSetting('DoAETap') and Config:GetSetting('DoAEDamage')) then return false end
                    return Casting.SpellReady(spell) and self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            {
                name = "Projection of Doom",
                type = "AA",
                tooltip = Tooltips.ProjectionofDoom,
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return Casting.AAReady(aaName) and Targeting.IsNamed(mq.TLO.Target) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 80
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                tooltip = Tooltips.Taunt,
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and Targeting.GetTargetID() > 0 and
                        Targeting.GetTargetDistance() < 30
                end,
            },
            {
                name = "Terror",
                type = "Spell",
                tooltip = Tooltips.Terror,
                cond = function(self, spell, target)
                    if Config:GetSetting('DoTerror') == 1 then return false end
                    ---@diagnostic disable-next-line: undefined-field
                    return Casting.TargetedSpellReady(spell, target.ID()) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
            {
                name = "Terror2",
                type = "Spell",
                tooltip = Tooltips.Terror,
                cond = function(self, spell, target)
                    if Config:GetSetting('DoTerror') == 1 then return false end
                    ---@diagnostic disable-next-line: undefined-field
                    return Casting.SpellLoaded(spell) and Casting.TargetedSpellReady(spell, target.ID()) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
            {
                name = "ForPower",
                type = "Spell",
                tooltip = Tooltips.ForPower,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoForPower') then return false end
                    return Casting.TargetedSpellReady(spell, target.ID()) and Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Visage of Death",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Crimson",
                type = "Disc",
                tooltip = Tooltips.Crimson,
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell)
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('DoVetAA') then return false end
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Harm Touch",
                type = "AA",
                tooltip = Tooltips.HarmTouch,
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Thought Leech",
                type = "AA",
                tooltip = Tooltips.ThoughtLeech,
                cond = function(self, aaName, target)
                    if Config:GetSetting('DoThoughtLeech') == 1 then return false end
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Leech Touch",
                type = "AA",
                tooltip = Tooltips.ThoughtLeech,
                cond = function(self, aaName, target)
                    if Config:GetSetting('DoLeechTouch') == 1 then return false end
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Spire of the Reavers",
                type = "AA",
                tooltip = Tooltips.SpireoftheReavers,
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Chattering Bones",
                type = "AA",
                tooltip = Tooltips.ChatteringBones,
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "T`Vyl's Resolve",
                type = "AA",
                tooltip = Tooltips.Tvyls,
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "SpiteStrike",
                type = "Disc",
                tooltip = Tooltips.SpikeStrike,
                cond = function(self, discSpell)
                    return not Core.IsTanking() and Casting.DiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "UnholyAura",
                type = "Disc",
                tooltip = Tooltips.UnholyAura,
                cond = function(self, discSpell)
                    return not Core.IsTanking() and Casting.DiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "InfluenceDisc",
                type = "Disc",
                tooltip = Tooltips.InfluenceDisc,
                cond = function(self, discSpell)
                    return not Core.IsTanking() and Casting.DiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
        },
        ['Snare'] = {
            {
                name = "Encroaching Darkness",
                tooltip = Tooltips.EncroachingDarkness,
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID()) and Casting.DetSpellCheck(mq.TLO.Me.AltAbility(aaName).Spell)
                end,
            },
            {
                name = "SnareDot",
                type = "Spell",
                tooltip = Tooltips.SnareDot,
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Encroaching Darkness") then return false end
                    return Casting.TargetedSpellReady(spell, target.ID()) and Casting.DetSpellCheck(spell) and Targeting.GetTargetPctHPs(target) < 50
                end,
            },
        },
        ['Defenses'] = {
            {
                name = "MeleeMit",
                type = "Disc",
                tooltip = Tooltips.MeleeMit,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and Core.IsTanking() and not (discSpell.Level() < 108 and mq.TLO.Me.ActiveDisc.ID())
                end,
            },
            {
                name = "Epic",
                type = "Item",
                tooltip = Tooltips.Epic,
                cond = function(self, itemName)
                    return mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0 and
                        (self.ClassConfig.HelperFunctions.LeechCheck(self) or Targeting.IsNamed(mq.TLO.Target))
                end,
            },
            {
                name = "OoW_Chest",
                type = "Item",
                tooltip = Tooltips.OoW_BP,
                cond = function(self, itemName)
                    return mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0 and self.ClassConfig.HelperFunctions.LeechCheck(self)
                end,
            },
            {
                name = "Carapace",
                type = "Disc",
                tooltip = Tooltips.Carapace,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and Core.IsTanking() and not mq.TLO.Me.ActiveDisc.ID() and
                        (Targeting.IsNamed(mq.TLO.Target) or self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true))
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                tooltip = Tooltips.Mantle,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and Core.IsTanking() and not mq.TLO.Me.ActiveDisc.ID() and
                        (Targeting.IsNamed(mq.TLO.Target) or self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true))
                end,
            },
            {
                name = "Guardian",
                type = "Disc",
                tooltip = Tooltips.Guardian,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and Core.IsTanking() and not mq.TLO.Me.ActiveDisc.ID() and
                        (Targeting.IsNamed(mq.TLO.Target) or self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true))
                end,
            },
            {
                name = "Coating",
                type = "Item",
                cond = function(self, itemName)
                    if not Config:GetSetting('DoCoating') then return false end
                    local item = mq.TLO.FindItem(itemName)
                    return item() and item.TimerReady() == 0 and Casting.SelfBuffCheck(item.Spell) and self.ClassConfig.HelperFunctions.LeechCheck(self)
                end,
            },
            {
                name = "UnholyAura",
                type = "Disc",
                tooltip = Tooltips.UnholyAura,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and Core.IsTanking() and not mq.TLO.Me.ActiveDisc.ID() and
                        (Targeting.IsNamed(mq.TLO.Target) or self.ClassConfig.HelperFunctions.DefensiveDiscCheck(true))
                end,
            },
            {
                name = "Purity of Death",
                type = "AA",
                tooltip = Tooltips.PurityofDeath,
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return mq.TLO.Me.TotalCounters() > 0 and Casting.AAReady(aaName)
                end,
            },
        },
        ['LifeTaps'] = {
            --Full rotation to make sure we use these in priority for emergencies
            {
                name = "Leech Touch",
                type = "AA",
                tooltip = Tooltips.LeechTouch,
                cond = function(self, aaName, target)
                    if Config:GetSetting('DoLeechTouch') == 2 then return false end
                    return Casting.TargetedAAReady(aaName, target.ID()) and mq.TLO.Me.PctHPs() < 25
                end,
            },
            --the trick with the next two is to find a sweet spot between using discs and long term CD abilities (we want these to trigger so those don't need to) and using them needlessly (which isn't much of a damage increase). Trying to get it dialed in for a good default value.
            {
                name = "Dicho",
                type = "Spell",
                tooltip = Tooltips.Dicho,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDicho') then return false end
                    local myHP = mq.TLO.Me.PctHPs()
                    return Casting.TargetedSpellReady(spell, target.ID()) and
                        (myHP <= Config:GetSetting('EmergencyStart') or ((Casting.HaveManaToNuke() or Casting.BurnCheck()) and myHP <= Config:GetSetting('StartDicho')))
                end,
            },
            {
                name = "DireTap",
                type = "Spell",
                tooltip = Tooltips.DireTap,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDireTap') then return false end
                    local myHP = mq.TLO.Me.PctHPs()
                    return Casting.TargetedSpellReady(spell, target.ID()) and
                        (myHP <= Config:GetSetting('EmergencyStart') or ((Casting.HaveManaToNuke() or Casting.BurnCheck()) and myHP <= Config:GetSetting('StartDireTap')))
                end,
            },
            {
                name = "LifeTap",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell, target)
                    local myHP = mq.TLO.Me.PctHPs()
                    return Casting.TargetedSpellReady(spell, target.ID()) and
                        (myHP <= Config:GetSetting('EmergencyStart') or ((Casting.HaveManaToNuke() or Casting.BurnCheck()) and myHP <= Config:GetSetting('StartLifeTap')))
                end,
            },
            {
                name = "AETap",
                type = "Spell",
                cond = function(self, spell, target)
                    if not (Config:GetSetting('DoAETap') and Config:GetSetting('DoAEDamage')) then return false end
                    local myHP = mq.TLO.Me.PctHPs()
                    return Casting.TargetedSpellReady(spell, target.ID()) and
                        (myHP <= Config:GetSetting('EmergencyStart') or ((Casting.HaveManaToNuke() or Casting.BurnCheck()) and myHP <= Config:GetSetting('StartLifeTap'))) and
                        self.ClassConfig.HelperFunctions.AETargetCheck(true)
                end,
            },
            { --This entry solely for emergencies on SK as a fallback, group has a different entry.
                name = "ReflexStrike",
                type = "Disc",
                tooltip = Tooltips.ReflexStrike,
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell) and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "LifeTap2",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell, target)
                    local myHP = mq.TLO.Me.PctHPs()
                    return Casting.TargetedSpellReady(spell, target.ID()) and
                        (myHP <= Config:GetSetting('EmergencyStart') or ((Casting.HaveManaToNuke() or Casting.BurnCheck()) and myHP <= Config:GetSetting('StartLifeTap')))
                end,
            },
        },
        ['CombatWeave'] = {
            { --Used if the group could benefit from the heal
                name = "ReflexStrike",
                type = "Disc",
                tooltip = Tooltips.ReflexStrike,
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell) and (mq.TLO.Group.Injured(80)() or 0) > 2
                end,
            },
            {
                name = "CombatEndRegen",
                type = "Disc",
                tooltip = Tooltips.CombatEndRegen,
                cond = function(self, discSpell)
                    return Casting.DiscReady(discSpell) and mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Vicious Bite of Chaos",
                type = "AA",
                tooltip = Tooltips.ViciousBiteOfChaos,
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Blade",
                type = "Disc",
                tooltip = Tooltips.Blade,
                cond = function(self, discSpell)
                    return Casting.TargetedDiscReady(discSpell)
                end,
            },
            {
                name = "Gift of the Quick Spear",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Thought Leech",
                type = "AA",
                tooltip = Tooltips.ThoughtLeech,
                cond = function(self, aaName, target)
                    if Config:GetSetting('DoThoughtLeech') == 2 then return false end
                    return mq.TLO.Me.PctMana() < 10 and Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                -- tooltip = Tooltips.Bash,
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.AbilityReady(abilityName)() and Casting.AbilityRangeCheck(target) and
                        (Core.ShieldEquipped() or Casting.CanUseAA("Improved Bash"))
                end,
            },
            {
                name = "Slam",
                type = "Ability",
                tooltip = Tooltips.Slam,
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.AbilityReady(abilityName)() and Casting.AbilityRangeCheck(target)
                end,
            },
        },
        ['Combat'] = {
            {
                name = "BondTap",
                type = "Spell",
                tooltip = Tooltips.BondTap,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoBondTap') then return false end
                    return (Casting.DotHaveManaToNuke() or Casting.BurnCheck()) and Casting.DotSpellCheck(spell) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "SpearNuke",
                type = "Spell",
                tooltip = Tooltips.SpearNuke,
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID()) and (Casting.HaveManaToNuke() or Casting.BurnCheck())
                end,
            },
            {
                name = "PoisonDot",
                type = "Spell",
                tooltip = Tooltips.PoisonDot,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoPoisonDot') then return false end
                    return (Casting.DotHaveManaToNuke() or Casting.BurnCheck()) and Casting.DotSpellCheck(spell) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "CorruptionDot",
                type = "Spell",
                tooltip = Tooltips.PoisonDot,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoCorruptionDot') then return false end
                    return (Casting.DotHaveManaToNuke() or Casting.BurnCheck()) and Casting.DotSpellCheck(spell) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "DireDot",
                type = "Spell",
                tooltip = Tooltips.DireDot,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDireDot') then return false end
                    return (Casting.DotHaveManaToNuke() or Casting.BurnCheck()) and Casting.DotSpellCheck(spell) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "BiteTap",
                type = "Spell",
                tooltip = Tooltips.BiteTap,
                cond = function(self, spell, target) --no mana check here because this returns half the mana cost to the entire group. can adjust later as needed.
                    return Casting.TargetedSpellReady(spell, target.ID()) and mq.TLO.Me.PctHPs() <= Config:GetSetting('StartLifeTap')
                end,
            },
            {
                name = "Torrent",
                type = "Spell",
                tooltip = Tooltips.Torrent,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoTorrent') or not spell or not spell() then return false end
                    return not mq.TLO.Me.Buff(spell.Name() .. " Recourse")() and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "BuffTap",
                type = "Spell",
                tooltip = Tooltips.BuffTap,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoBuffTap') then return false end
                    return not mq.TLO.Me.Buff(spell.Trigger())() and Casting.SpellStacksOnMe(spell.Trigger) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
        },
        ['Weapon Management'] = {
            {
                name = "Equip Shield",
                type = "CustomFunc",
                active_cond = function(self, target)
                    return mq.TLO.Me.Bandolier("Shield").Active()
                end,
                cond = function(self)
                    if mq.TLO.Me.Bandolier("Shield").Active() then return false end
                    return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EquipShield')) or (Targeting.IsNamed(mq.TLO.Target) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("Shield") end,
            },
            {
                name = "Equip 2Hand",
                type = "CustomFunc",
                active_cond = function(self, target)
                    return mq.TLO.Me.Bandolier("2Hand").Active()
                end,
                cond = function(self)
                    if mq.TLO.Me.Bandolier("2Hand").Active() then return false end
                    return mq.TLO.Me.PctHPs() >= Config:GetSetting('Equip2Hand') and mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline" and
                        (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 0) < 234000 and not (Targeting.IsNamed(mq.TLO.Target) and Config:GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return ItemManager.BandolierSwap("2Hand") end,
            },
        },
    },
    ['Spells']          = { --I am not trying to find a combination that works when we have 20 options that change based on level, so I've just made a repeating priority list. May adjust this later.
        {
            gem = 1,
            spells = {
                { name = "SpearNuke", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "LifeTap", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "SnareDot", cond = function(self) return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Encroaching Darkness") end, },
                { name = "DireTap",  cond = function(self) return Config:GetSetting('DoDireTap') end, },
                { name = "Dicho",    cond = function(self) return Config:GetSetting('DoDicho') end, },
                { name = "ForPower", cond = function(self) return Config:GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "DireTap",  cond = function(self) return Config:GetSetting('DoDireTap') end, },
                { name = "Dicho",    cond = function(self) return Config:GetSetting('DoDicho') end, },
                { name = "ForPower", cond = function(self) return Config:GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return Config:GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "LifeTap2", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "Dicho",    cond = function(self) return Config:GetSetting('DoDicho') end, },
                { name = "ForPower", cond = function(self) return Config:GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return Config:GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "ForPower",      cond = function(self) return Config:GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return Config:GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        {
            gem = 7,
            spells = {
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return Config:GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        {
            gem = 8,
            cond = function(self) return mq.TLO.Me.NumGems() >= 9 end,
            spells = {
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return Config:GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },

            },
        },
        { -- Level 55
            gem = 9,
            cond = function(self) return mq.TLO.Me.NumGems() >= 10 end,
            spells = {
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return Config:GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 75
            gem = 10,
            cond = function(self) return mq.TLO.Me.NumGems() >= 11 end,
            spells = {
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return Config:GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 80
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TempHP",        cond = function(self) return Config:GetSetting('DoTempHP') end, }, --level 84, this spell starts in a long recast so I prefer to keep it on the bar.
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return Config:GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 80
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Skin",          cond = function(self) return Core.IsTanking() end, }, -- level 70, while not as bad as the TempHP line, also starts in a recast. Placed higher before level 106.
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return Config:GetSetting('DoBuffTap') end, },
                { name = "HealBurn", cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 106
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "HealBurn", cond = function(self) return Core.IsTanking() end, }, --level 103, this may be overwritten by pauses but it is fine, it has a low refresh time. At least it will be there on start.
            },
        },
        { -- Level 125
            gem = 14,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "AETap",    cond = function(self) return Config:GetSetting('DoAETap') end, },
                { name = "HealBurn", cond = function(self) return Core.IsTanking() end, }, --level 103, this may be overwritten by pauses but it is fine, it has a low refresh time. At least it will be there on start.
                { name = "LifeTap2", },
            },
        },
    },
    ['PullAbilities']   = {
        {
            id = 'SpearNuke',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('SpearNuke').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('SpearNuke').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('SpearNuke')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'Terror',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('Terror')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'ForPower',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('ForPower').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('ForPower').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('ForPower')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'LifeTap',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('LifeTap').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('LifeTap').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('LifeTap')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'LifeTap2',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('LifeTap2').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('LifeTap2').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('LifeTap2')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']   = {
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
        ['DoSnare']           = {
            DisplayName = "Use Snares",
            Category = "Buffs/Debuffs",
            Index = 1,
            Tooltip = "Use Snare(Snare Dot used until AA is available).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not snaring?",
            Answer = "Make sure Use Snares is enabled in your class settings.",
        },
        ['SnareCount']        = {
            DisplayName = "Snare Max Mob Count",
            Category = "Buffs/Debuffs",
            Index = 2,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
            Min = 1,
            Max = 99,
            FAQ = "Why is my Shadow Knight Not snaring?",
            Answer = "Make sure you have [DoSnare] enabled in your class settings.\n" ..
                "Double check the Snare Max Mob Count setting, it will prevent snare from being used if there are more than [x] mobs on aggro.",
        },
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
        ['ProcChoice']        = {
            DisplayName = "HP/Mana Proc:",
            Category = "Buffs/Debuffs",
            Index = 4,
            Tooltip = "Prefer HP Proc and DLU(Azia) or Mana Proc and DLU(Beza)",
            Type = "Combo",
            ComboOptions = { 'HP Proc: Terror Line, DLU(Azia)', 'Mana Proc: Mental Line, DLU(Beza)', 'Disabled', },
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "I am constantly running out of mana, what can I do to help?",
            Answer = "During certain level ranges, it may be helpful to use the Mana Proc (Mental) line over the HP proc (Terror) line.\n" ..
                "This can be adjusted on the Buffs/Debuffs tab.",
        },
        ['OverwriteDLUBuffs'] = {
            DisplayName = "Overwrite DLU Buffs",
            Category = "Buffs/Debuffs",
            Index = 5,
            Tooltip = "Overwrite DLU with single buffs when they are better than the DLU effect.",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "I have new buffs but I am still using DLU, why?",
            Answer = "Toggle to Overwrite DLU with single buffs when appropriate from the Buffs/Debuffs tab. This is disabled by default to speed up buffing.",
        },
        ['DoTorrent']         = {
            DisplayName = "Use Torrents",
            Category = "Buffs/Debuffs",
            Index = 6,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("Torrent") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "When should I be using Torrents?",
            Answer = "Generally, this is only advised at 100+ when you can benefit from the increased AC. Some early level ranges may find their use appropriate.",
        },
        ['DoBuffTap']         = {
            DisplayName = "Use Buff Tap",
            Category = "Buffs/Debuffs",
            Index = 7,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("BuffTap") end,
            Default = false,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight Not using Buff Tap?",
            Answer = "The term is a misnomer; contrary to common belief, these spells are not Life Taps. The HP buff is negligible in most situations.",
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

        --Taps
        ['StartLifeTap']      = {
            DisplayName = "HP % for LifeTaps",
            Category = "Taps",
            Index = 1,
            Tooltip = "Your HP % before we use Life Taps.",
            Default = 99,
            Min = 1,
            Max = 100,
            FAQ = "Why is my Shadow Knight not using Life Taps?",
            Answer = "Make sure you have [DoLifeTap] enabled in your class settings.\n" ..
                "Double check [StartLifeTap] seetting, this setting will prevent Life Taps from being used if your HP is above [x]%",
        },
        ['DoDireTap']         = {
            DisplayName = "Cast Dire Taps",
            Category = "Taps",
            Index = 2,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("DireTap") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why would someone want to disable Dire Taps at all?",
            Answer = "Now that I think about it... I'm not quite sure.",
        },
        ['StartDireTap']      = {
            DisplayName = "HP % for Dire",
            Category = "Taps",
            Index = 3,
            Tooltip = "Your HP % before we use Dire taps.",
            Default = 85,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using Dire Taps on cooldown for more DPS?",
            Answer = "The default HP% to begin using Dire Taps is set to only use them if the SHD could benefit from the healing and can be adjusted.",
        },
        ['DoDicho']           = {
            DisplayName = "Cast Dicho Taps",
            Category = "Taps",
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
            Category = "Taps",
            Index = 5,
            Tooltip = "Your HP % before we use Dicho taps.",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using Dicho on cooldown for more DPS?",
            Answer = "The default HP% to begin using Dicho is set to only use them if the SHD could benefit from the healing and can be adjusted.",
        },
        ['DoLeechTouch']      = {
            DisplayName = "Leech Touch Use:",
            Category = "Taps",
            Index = 6,
            Tooltip = "When to use Leech Touch",
            Type = "Combo",
            ComboOptions = { 'On critically low HP', 'As DD during burns', 'For HP or DD', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using Leech Touch?",
            Answer = "You can choose the conditions under which you will use Leech Touch on the Taps tab.",
        },
        ['DoThoughtLeech']    = {
            DisplayName = "Thought Leech Use:",
            Category = "Taps",
            Index = 7,
            Tooltip = "When to use Thought Leech",
            Type = "Combo",
            ComboOptions = { 'On critically low mana', 'As DD during burns', 'For Mana or DD', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using Thought Leech?",
            Answer = "You can choose the conditions under which you will use Thought Leech on the Taps tab.",
        },

        --Damage Spells
        ['DoBondTap']         = {
            DisplayName = "Use Bond Dot",
            Category = "Damage Spells",
            Index = 1,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("BondTap") end,
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why do I spend so much mana using these DoTs?",
            Answer = "Dots have additional settings in the RGMercs Main config, such as the min mana% to use them.",
        },
        ['DoPoisonDot']       = {
            DisplayName = "Use Poison Dot",
            Category = "Damage Spells",
            Index = 2,
            ToolTip = function() return Ui.GetDynamicTooltipForSpell("PoisonDot") end,
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why do I use a DoT just before a mob dies?",
            Answer = "Dots have additional settings in the RGMercs Main config, such as the HP% to stop using them (for both trash and named).",
        },
        ['DoCorruptionDot']   = {
            DisplayName = "Use Corrupt Dot",
            Category = "Damage Spells",
            Index = 3,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("CorruptDot") end,
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "I heard SHD dots suck, why are we using them?",
            Answer = "On live, SHD dot damage has been buffed more than once in the last few years, and is likely worthwhile. For other servers or eras, consult your class experts!",
        },
        ['DoDireDot']         = {
            DisplayName = "Use Dire Dot",
            Category = "Damage Spells",
            Index = 4,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("Dicho") end,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why is my Shadow Knight not using Dire Dot?",
            Answer = "Dire Dot is not enabled by default, you may need to select it.",
        },
        ['DoAEDamage']        = {
            DisplayName = "Do AE Damage",
            Category = "Damage Spells",
            Index = 5,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells, Discs and AA. **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['AETargetCnt']       = {
            DisplayName = "AE Target Count",
            Category = "Damage Spells",
            Index = 6,
            Tooltip = "Minimum number of valid targets before using AE Spells, Disciplines or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['MaxAETargetCnt']    = {
            DisplayName = "Max AE Targets",
            Category = "Damage Spells",
            Index = 7,
            Tooltip =
            "Maximum number of valid targets before using AE Spells, Disciplines or AA.\nUseful for setting up AE Mez at a higher threshold on another character in case you are overwhelmed.",
            Default = 5,
            Min = 2,
            Max = 30,
            FAQ = "How do I take advantage of the Max AE Targets setting?",
            Answer =
            "By limiting your max AE targets, you can set an AE Mez count that is slightly higher, to allow for the possiblity of mezzing if you are being overwhelmed.",
        },
        ['SafeAEDamage']      = {
            DisplayName = "AE Proximity Check",
            Category = "Damage Spells",
            Index = 8,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },
        ['DoAETap']           = {
            DisplayName = "Use AE Hate/LifeTap",
            Category = "Damage Spells",
            Index = 9,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("AETap") end,
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why is my Shadow Knight not using the AE Tap (Insidious) Line?",
            Answer = "The Insidious AE Hate Life Tap is not enabled by default, you may need to select it.",
        },

        --Hate Tools
        ['UseVoT']            = {
            DisplayName = "Use VoT AA",
            Category = "Hate Tools",
            Index = 1,
            Tooltip = "Use Hate Buff AA. Spells currently not used because of low values and long refresh times.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why do we only use Voice of Thule, and not the aggro spells?",
            Answer = "Very high refresh times paired with low gem slots and low aggro increase %'s are why we wait for the AA. They can be manually cast, if desired.",
        },
        ['DoTerror']          = {
            DisplayName = "Terror Taunts:",
            Category = "Hate Tools",
            Index = 2,
            Tooltip = "Choose the level range (if any) to memorize Terror Spells.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Never', 'Until "For Power" spells are available', 'Always', },
            Default = 2,
            Min = 1,
            Max = 3,
            FAQ = "Why is my Shadow Knight Not using Terror Taunts?",
            Answer = "By default, terrors won't be used once the \"For Power\" line is available. This can be adjusted on the Hate Tool tab.",
        },
        ['DoForPower']        = {
            DisplayName = "Use \"For Power\"",
            Category = "Hate Tools",
            Index = 3,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("ForPower") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "I've set the option to always use Terrors, why is For Power still being memorized?",
            Answer = "You must also disable its use in the Hate Tools Tab (Use For Power)",
        },
        ['AETauntAA']         = {
            DisplayName = "Use AE Taunt AA",
            Category = "Hate Tools",
            Index = 4,
            Tooltip = "Use Explosions of Hatred and Spite.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why do we treat the Explosions the same? One is targeted, one is PBAE",
            Answer = "There are currently no scripted conditions where Hatred would be used at long range, thus, for ease of use, we can treat them similarly.",
        },
        ['AETauntSpell']      = {
            DisplayName = "AE Taunt Spell Choice:",
            Category = "Hate Tools",
            Index = 5,
            Tooltip = "Choose the level range (if any) to memorize AE Taunt Spells.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Never', 'Until Explosions (AA Taunts) are available', 'Always', },
            Default = 2,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my Shadow Knight not using AE Taunt Spells?",
            Answer = "Make sure you have [AETauntSpell] enabled in your class settings.\n" ..
                "You will also want to adjust your [AETauntAA] options (Never, Until Explosions (AA Taunts) are available, Always)\n" ..
                "And set [AETauntCnt] settings to match your current needs.",
        },
        ['AETauntCnt']        = {
            DisplayName = "AE Taunt Count",
            Category = "Hate Tools",
            Index = 6,
            Tooltip = "Minimum number of haters before using AE Taunt Spells or AA.",
            Default = 2,
            Min = 1,
            Max = 10,
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
    },
}

return _ClassConfig
