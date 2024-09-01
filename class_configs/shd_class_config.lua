-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

-- [ NOTE ON ORDERING ] --
-- Order matters! Lua will implicitly iterate everything in an array
-- in order by default so always put the first thing you want checked
-- towards the top of the list.

local mq           = require('mq')
local RGMercUtils  = require("utils.rgmercs_utils")

local Tooltips     = {
    Mantle              = "Spell Line: Melee Absorb Proc",
    Carapace            = "Spell Line: Melee Absorb Proc",
    EndRegen            = "Discipline Line: Endurance Regen",
    Blade               = "Ability Line: Double 2HS Attack w/ Accuracy Mod",
    Crimson             = "Disicpline Line: Triple Attack w/ Accuracy Mod",
    MeleeMit            = "Discipline Line: Absorb Incoming Dmg",
    Deflection          = "Discipline: Shield Block Chance 100%",
    LeechCurse          = "Discipline: Melee LifeTap w/ Increase Hit Chance",
    UnholyAura          = "Discipline: Increase LifeTap Spell Damage",
    CurseGuard          = "Discipline: Melee Mtigation w/ Defensive LifeTap & Lowered Melee DMG Output",
    PetSpell            = "Spell Line: Summons SK Pet",
    PetHaste            = "Spell Line: Haste Buff for SK Pet",
    Shroud              = "Spell Line: Add Melee LifeTap Proc",
    Horror              = "Spell Line: Proc Mana Return",
    Skin                = "Spell Line: Melee Absorb Proc",
    SelfDS              = "Spell Line: Self Damage Shield",
    Demeanor            = "Spell Line: Add LifeTap Proc Buff on Killshot",
    HealBurn            = "Spell Line: Add Hate Proc on Incoming Spell Damage",
    CloakHP             = "Spell Line: Increase HP and Stacking DS",
    Covenant            = "Spell Line: Increase Mana Regen + Ultravision / Decrease HP Per Tick",
    CallAtk             = "Spell Line: Increase Attack / Decrease HP Per Tick",
    AeTaunt             = "Spell Line: PBAE Hate Increase + Taunt",
    PoisonDot           = "Spell Line: Poison Dot",
    SpearNuke           = "Spell Line: Instacast Disease Nuke",
    BondTap             = "Spell Line: LifeTap DOT",
    DireTap             = "Spell Line: LifeTap",
    LifeTap             = "Spell Line: LifeTap",
    BuffTap             = "Spell Line: LifeTap + Hate Increase + HP Regen",
    BiteTap             = "Spell Line: LifeTap + ManaTap",
    ForPower            = "Spell Line: Hate Increase + Hate Increase DOT + AC Buff 'BY THE POWER OF GRAYSKULL, I HAVE THE POWER -- HE-MAN'",
    Terror              = "Spell Line: Hate Increase + Taunt",
    TempHP              = "Spell Line: Temporary Hitpoints (Decrease per Tick)",
    Dicho               = "Spell Line: Hate Increase + LifeTap",
    Torrent             = "Spell Line: Attack Tap",
    SnareDOT            = "Spell Line: Snare + HP DOT",
    Acrimony            = "Spell Increase: Aggrolock + LifeTap DOT + Hate Generation",
    SpiteStrike         = "Spell Line: LifeTap + Caster 1H Blunt Increase + Target Armor Decrease",
    ReflexStrike        = "Ability: Triple 2HS Attack + HP Increase",
    DireDot             = "Spell Line: DOT + AC Decrease + Strength Decrease",
    AllianceNuke        = "Spell Line: Alliance (Requires Multiple of Same Class) - Increase Spell Damage Taken by Target + Large LifeTap",
    InfluenceDisc       = "Ability Line: Increase AC + Absorb Damage + Melee Proc (LifeTap + Max HP Increase)",
    DLUA                = "AA: Cast Highest Level of Scribed Buffs (Shroud, Horror, Drape, Demeanor, Skin, Covenant, CallATK)",
    HarmTouch           = "AA: Harms Target HP",
    ThoughtLeech        = "AA: Harms Target HP + Harms Target Mana",
    VisageOfDeath       = "Spell: Increases Melee Hit Dmg + Illusion",
    LeechTouch          = "AA: LifeTap Touch",
    Tyvls               = "Spell: Triple 2HS Attack + % Melee Damage Increase on Target",
    ActivateSHield      = "Activate 'Shield' if set in Bandolier",
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
    _version            = "1.0 Beta",
    _author             = "Derple",
    ['ModeChecks']      = {
        IsTanking = function() return RGMercUtils.IsModeActive("Tank") end,
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
    },
    ['AbilitySets']     = {
        ['Mantle'] = {
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
            "Soul Carapace",
            "Umbral Carapace",
            "Malarian Carapace",
            "Gorgon Carapace",
            "Sholothian Carapace",
            "Grelleth's Carapace",
            "Vizat's Carapace",
            "Tylix's Carapace",
            "Cadcane's Carapace",
            "Xetheg's Carapace",
            "Kanghammer's Carapace",
        },
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
        ['Deflection'] = { 'Deflection Discipline', },
        ['LeechCurse'] = { 'Leechcurse Discipline', },
        ['UnholyAura'] = { 'Unholy Aura Discipline', },
        ['CurseGuard'] = { 'Cursed Guardian Discipline', },
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
        ['Shroud'] = {
            "Shroud of Death",
            "Shroud of Chaos",
            "Black Shroud",
            "Shroud of Discord",
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
        ['Horror'] = {
            "Mental Horror",
            "Marrowthirst Horror",
            "Soulthirst Horror",
            "Mindshear Horror",
            "Amygdalan Horror",
            "Sholothian Horror",
            "Grelleth's Horror",
            "Vizat's Horror",
            "Tylix's Horror",
            "Cadcane's Horror",
            "Brightfeld's Horror",
            "Mortimus' Horror",
        },
        ['Skin'] = {
            "Decrepit Skin",
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
            "Harmonious Disruption",
            "Concordant Disruption",
            "Confluent Disruption",
            "Penumbral Disruption",
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
            "Call of Blight",
            "Call of Darkness",
            "Call of Dusk",
            "Call of Shadow",
            "Call of Gloomhaze",
            "Call of Nightfall",
            "Call of Twilight",
            "Penumbral Call",
        },
        ['AeTaunt'] = {
            "Dread Gaze",
            "Vilify",
            "Revile",
            "Burst of Spite",
            "Loathing",
            "Abhorrence",
            "Antipathy",
            "Animus",
        },
        ['PoisonDot'] = {
            "Blood of Pain",
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
        ['Spearnuke'] = {
            "Spike of Disease",
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
            "Vampiric Curse",
        },
        ['DireTap'] = {
            "Dire Implication",
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
            "Touch of the Wailing Three",
            "Touch of the Soulbleeder",
            "Touch of Lanys",
            "Touch of Dyalgem",
            "Touch of Urash",
            "Touch of Falsin",
            "Touch of Lutzen",
            "Touch of T`Vem",
            "Touch of Drendar",
            "Touch of Severan",
            "Touch of the Devourer",
            "Touch of Draygun",
            "Touch of Innoruuk",
            "Touch of Volatis",
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Life Leech",
            "Lifedraw",
            "Lifespike",
            "LifeTap",
        },
        ['LifeTap2'] = {
            "Touch of Flariton",
            "Touch of Txiki",
            "Touch of the Wailing Three",
            "Touch of the Soulbleeder",
            "Touch of Lanys",
            "Touch of Dyalgem",
            "Touch of Urash",
            "Touch of Falsin",
            "Touch of Lutzen",
            "Touch of T`Vem",
            "Touch of Drendar",
            "Touch of Severan",
            "Touch of the Devourer",
            "Touch of Draygun",
            "Touch of Innoruuk",
            "Touch of Volatis",
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Life Leech",
            "Lifedraw",
            "Lifespike",
            "LifeTap",
        },
        ['BuffTap'] = {
            "Touch of Mortimus",
            "Touch of Namdrows",
            "Touch of Zlandicar",
            "Touch of the Wailing Three",
            "Touch of Kildrukaun",
            "Touch of Tharoff",
            "Touch of Iglum",
            "Touch of Piqiorn",
            "Touch of Klonda",
            "Touch of Holmein",
            "Touch of Hemofax",
            "Siphon Strength",
            "Despair",
            "Scream of Hate",
            "Scream of Pain",
            "Shroud of Hate",
            "Shroud of Pain",
            "Abduction of Strength",
            "Torrent of Hate",
            "Torrent of Pain",
            "Torrent of Fatigue",
            "Aura of Pain",
            "Aura of Hate",
            "Theft of Pain",
            "Theft of Hate",
            "Theft of Agony",
        },
        ['BiteTap'] = {
            "Zevfeer's Bite",
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
        },
        ['ForPower'] = {
            "Challenge for Power",
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
            "Stormwall Stance",
            "Defiant Stance",
            "Staunch Stance",
            "Steadfast Stance",
            "Stoic Stance",
            "Stubborn Stance",
            "Steely Stance",
            "Adamant Stance",
            "Unwavering Stance",
        },
        ['Dicho'] = {
            "Dichotomic Fang",
            "Dissident Fang",
            "Composite Fang",
            "Ecliptic Fang",
        },
        ['Torrent'] = {
            "Torrent of Hate",
            "Torrent of Pain",
            "Torrent of Agony",
            "Torrent of Misery",
            "Torrent of Suffering",
            "Torrent of Anguish",
            "Torrent of Melancholy",
            "Torrent of Desolation",
        },
        ['SnareDOT'] = {
            "Clinging Darkness",
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
        },
        ['DireDot'] = {
            "Dire Constriction",
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
        },
        ['InfluenceDisc'] = {
            "Insolent Influence",
            "Impudent Influence",
            "Impenitent Influence",
            "Impertinent Influence",
            "Ignominious Influence",
        },
    },
    ['HelperFunctions'] = {
        -- helper function for advanced logic to see if we want to use Dark Lord's Unity
        castDLU = function(self)
            local shroudAction = RGMercModules:ExecModule("Class", "GetResolvedActionMapItem", "Shroud")
            if not shroudAction then return false end
            local shroudAA = mq.TLO.Me.AltAbility("Dark Lord's Unity (Azia)")
            local numEffects = shroudAA.Spell.NumEffects() or 0

            local res = shroudAction.Level() <=
                (shroudAA.Spell.Level() or 0) and
                shroudAA.MinLevel() <= mq.TLO.Me.Level() and
                shroudAA.Rank() > 0

            for i = 1, numEffects do
                if not shroudAA.Spell.Trigger(i)() then return false end
            end

            return res
        end,
    },
    ['RotationOrder']   = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    RGMercUtils.DoBuffCheck()
            end,
        },
        {
            name = 'Pet Downtime',
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and
                    RGMercUtils.DoBuffCheck()
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() < 70
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
            name = 'Combat Maintenance',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Tanking',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.IsTanking()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not mq.TLO.Me.SpellInCooldown()
            end,
        },
    },
    ['Rotations']       = {
        ['Downtime'] = {
            {
                name = "PetSpell",
                type = "Spell",
                tooltip = Tooltips.PetSpell,
                active_cond = function(self, spell) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(
                    self, spell)
                    return mq.TLO.Me.Pet.ID() == 0 and RGMercUtils.GetSetting('DoPet') and RGMercUtils.ReagentCheck(spell)
                end,
            },
            {
                name = "Dark Lord's Unity (Azia)",
                type = "AA",
                tooltip = Tooltips.DLUA,
                active_cond = function(self, aaName) return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID() or 0) end,
                cond = function(self, aaName)
                    return self.ClassConfig.HelperFunctions.castDLU(self) and not RGMercUtils.BuffActive(mq.TLO.Me.AltAbility(aaName).Spell)
                end,
            },
            {
                name = "Skin",
                type = "Spell",
                tooltip = Tooltips.Skin,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Horror",
                type = "Spell",
                tooltip = Tooltips.Horror,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDLU(self) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Demeanor",
                type = "Spell",
                tooltip = Tooltips.Demeanor,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDLU(self) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "CloakHP",
                type = "Spell",
                tooltip = Tooltips.CloakHP,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDLU(self) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfDS",
                type = "Spell",
                tooltip = Tooltips.SelfDS,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDLU(self) and mq.TLO.Me.Level() <= 60 and RGMercUtils.ReagentCheck(spell) and
                        RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Shroud",
                type = "Spell",
                tooltip = Tooltips.Shroud,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDLU(self) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Covenant",
                type = "Spell",
                tooltip = Tooltips.Covenant,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDLU(self) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "CallAtk",
                type = "Spell",
                tooltip = Tooltips.CallAtk,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not self.ClassConfig.HelperFunctions.castDLU(self) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "TempHP",
                type = "Spell",
                tooltip = Tooltips.TempHP,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "HealBurn",
                type = "Spell",
                tooltip = Tooltips.HealBurn,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(
                    self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Voice of Thule",
                type = "AA",
                tooltip = Tooltips.VOT,
                active_cond = function(self, aaName) return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('UseVoT') and RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['Pet Downtime'] = {
            {
                name = "PetHaste",
                type = "Spell",
                tooltip = Tooltips.PetHaste,
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName) ~= nil end,
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Acrimony",
                type = "Disc",
                tooltip = Tooltips.Acrimony,
                cond = function(self)
                    return RGMercUtils.IsNamed(mq.TLO.Target)
                end,
            },
            {
                name = "Spire of the Reavers",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "SpiteStrike",
                type = "Disc",
                tooltip = Tooltips.SpikeStrike,
                cond = function(self)
                    return RGMercUtils.IsNamed(mq.TLO.Target)
                end,
            },
            {
                name = "ReflexStrike",
                type = "Disc",
                tooltip = Tooltips.ReflexStrike,
                cond = function(self)
                    return RGMercUtils.IsNamed(mq.TLO.Target)
                end,
            },
            {
                name = "Harm Touch",
                type = "AA",
                tooltip = Tooltips.HarmTouch,
                cond = function(self, _)
                    return (RGMercUtils.GetSetting('BurnAuto') and RGMercUtils.IsNamed(mq.TLO.Target)) or
                        RGMercUtils.BigBurn()
                end,
            },
            { name = "Thought Leech",   type = "AA", tooltip = Tooltips.ThoughtLeech, },
            { name = "Visage of Death", type = "AA", tooltip = Tooltips.VisageOfDeath, },
            {
                name = "Leech Touch",
                cond = function(self)
                    return mq.TLO.Me.PctHPs() < 50
                end,
                type = "AA",
                tooltip = Tooltips.LeechTouch,
            },
            { name = "T`Vyl's Resolve", type = "AA", tooltip = Tooltips.Tyvls, },
        },
        ['Debuff'] = {},
        ['Emergency'] = {
            {
                name = "Shield Flash",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctHPs() < RGMercUtils.GetSetting('FlashHP')
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return item() and RGMercUtils.TargetHasBuff(item.Spell, mq.TLO.Me)
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.GetSetting('DoChestClick') and item() and RGMercUtils.SpellStacksOnMe(item.Spell) and item.TimerReady() == 0
                end,
            },
        },
        ['Combat Maintenance'] = {
            {
                name = "ActivateShield",
                type = "CustomFunc",
                tooltip = Tooltips.ActivateShield,
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
                tooltip = Tooltips.Activate2HS,
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
                name = mq.TLO.Me.Inventory("Charm").Name(),
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Charm")
                    return item() and RGMercUtils.TargetHasBuff(item.Spell, mq.TLO.Me)
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Charm")
                    return RGMercUtils.GetSetting('DoCharmClick') and item() and RGMercUtils.SpellStacksOnMe(item.Spell) and item.TimerReady() == 0
                end,
            },
            {
                name = "EndRegen",
                type = "Disc",
                tooltip = Tooltips.EndRegen,
                cond = function(self)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "MeleeMit",
                type = "Disc",
                tooltip = Tooltips.MeleeMit,
                cond = function(self, _)
                    return RGMercUtils.IsTanking()
                end,
            },
            {
                name = "Epic",
                type = "Item",
                tooltip = Tooltips.Epic,
                cond = function(self, itemName)
                    return mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.Me.ActiveDisc.Name() ~= "Leechcurse Discipline"
                end,
            },
            {
                name = "LeechCurse",
                type = "Disc",
                tooltip = Tooltips.LeechCurse,
                cond = function(self)
                    return mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline" and mq.TLO.Me.PctHPs() < 50
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                tooltip = Tooltips.Mantle,
                cond = function(self)
                    return RGMercUtils.IsTanking() and
                        (RGMercUtils.IsNamed(mq.TLO.Target) or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() >= RGMercUtils.GetSetting('MantleCount')) and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Carapace",
                type = "Disc",
                tooltip = Tooltips.Carapace,
                cond = function(self)
                    return RGMercUtils.IsTanking() and
                        (RGMercUtils.IsNamed(mq.TLO.Target) or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() >= RGMercUtils.GetSetting('CarapaceCount')) and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "CurseGuard",
                type = "Disc",
                tooltip = Tooltips.CurseGuard,
                cond = function(self)
                    return RGMercUtils.IsTanking() and
                        (RGMercUtils.IsNamed(mq.TLO.Target) or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > RGMercUtils.GetSetting('CurseGuardCount')) and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "UnholyAura",
                type = "Disc",
                tooltip = Tooltips.UnholyAura,
                cond = function(self)
                    return (RGMercUtils.IsNamed(mq.TLO.Target) or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() >= RGMercUtils.GetSetting('UnholyCount')) and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Blade",
                type = "Disc",
                tooltip = Tooltips.Blade,
                cond = function(self)
                    return RGMercUtils.GetTargetID() > 0 and RGMercUtils.GetTargetPctHPs() > 5 and
                        RGMercUtils.GetTargetDistance() < 35
                end,
            },
            {
                name = "Crimson",
                type = "Disc",
                tooltip = Tooltips.Crimson,
                cond = function(self)
                    return RGMercUtils.GetTargetID() > 0 and RGMercUtils.GetTargetPctHPs() > 5 and
                        RGMercUtils.GetTargetDistance() < 35 and ((mq.TLO.Me.Inventory("mainhand").Type() or ""):find("2H"))
                end,
            },
        },
        ['Tanking'] = {
            {
                name = "AeTaunt",
                type = "Spell",
                tooltip = Tooltips.AeTaunt,
                cond = function(self, spell)
                    return mq.TLO.SpawnCount("NPC radius 50 zradius 50")() >= RGMercUtils.GetSetting('AeTauntCnt') and
                        RGMercUtils.GetXTHaterCount() >= RGMercUtils.GetSetting('AeTauntCnt')
                end,
            },
            {
                name = "Explosion of Hatred",
                type = "AA",
                tooltip = Tooltips.ExplosionOfHatred,
                cond = function(self, _)
                    return mq.TLO.SpawnCount("NPC radius 50 zradius 50")() >= RGMercUtils.GetSetting('AeTauntCnt') and
                        RGMercUtils.GetXTHaterCount() >= RGMercUtils.GetSetting('AeTauntCnt')
                end,
            },
            {
                name = "Explosion of Spite",
                type = "AA",
                tooltip = Tooltips.ExplosionOfSpite,
                cond = function(self, _)
                    return mq.TLO.SpawnCount("NPC radius 50 zradius 50")() >= RGMercUtils.GetSetting('AeTauntCnt') and
                        RGMercUtils.GetXTHaterCount() >= RGMercUtils.GetSetting('AeTauntCnt')
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                tooltip = Tooltips.Taunt,
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and
                        mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and RGMercUtils.GetTargetID() > 0 and
                        RGMercUtils.GetTargetDistance() < 30
                end,
            },
            {
                name = "Terror",
                type = "Spell",
                tooltip = Tooltips.Terror,
                cond = function(self)
                    return mq.TLO.Me.SecondaryPctAggro() > 60
                end,
            },
            {
                name = "Terror2",
                type = "Spell",
                tooltip = Tooltips.Terror,
                cond = function(self)
                    return mq.TLO.Me.SecondaryPctAggro() > 60
                end,
            },
            {
                name = "ForPower",
                type = "Spell",
                tooltip = Tooltips.ForPower,
                cond = function(self, spell)
                    return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell)
                end,
            },
            {
                name = "Deflection",
                type = "Disc",
                tooltip = Tooltips.Deflection,
                cond = function(self)
                    return mq.TLO.Me.ActiveDisc.Name() ~= "Leechcurse Discipline" and mq.TLO.Me.PctHPs() < 50
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Encroaching Darkness",
                tooltip = Tooltips.EncroachingDarkness,
                type = "AA",
                cond = function(self)
                    return RGMercUtils.GetSetting('DoSnare') and RGMercUtils.DetAACheck(826)
                end,
            },
            {
                name = "SnareDOT",
                type = "Spell",
                tooltip = Tooltips.SnareDOT,
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoSnare') and RGMercUtils.SpellLoaded(spell) and RGMercUtils.DetSpellCheck(spell) and not mq.TLO.Me.AltAbility(826)()
                end,
            },

            {
                name = "PoisonDot",
                type = "Spell",
                tooltip = Tooltips.PoisonDot,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell)
                end,
            },
            {
                name = "DireDot",
                type = "Spell",
                tooltip = Tooltips.DireDot,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell)
                end,
            },
            {
                name = "Torrent",
                type = "Spell",
                tooltip = Tooltips.Torrent,
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoTorrent') and RGMercUtils.SpellLoaded(spell) and not RGMercUtils.TargetHasBuff(spell)
                end,
            },
            {
                name = "SpearNuke",
                type = "Spell",
                tooltip = Tooltips.SpearNuke,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and RGMercUtils.ManaCheck()
                end,
            },
            {
                name = "BondTap",
                type = "Spell",
                tooltip = Tooltips.BondTap,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and not RGMercUtils.GetSetting('DoTorrent') and
                        not RGMercUtils.BuffActiveByName(spell.Name() .. " Recourse")
                end,
            },
            {
                name = "Vicious Bite of Chaos",
                type = "AA",
                tooltip = Tooltips.ViciousBiteOfChaos,
                cond = function(self)
                    return RGMercUtils.GetTargetPctHPs() > 5 and RGMercUtils.GetTargetDistance() < 35
                end,
            },

            {
                name = "Dicho",
                type = "Spell",
                tooltip = Tooltips.Dicho,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartBigTap')
                end,
            },
            {
                name = "DireTap",
                type = "Spell",
                tooltip = Tooltips.DireTap,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartBigTap')
                end,
            },
            {
                name = "BuffTap",
                type = "Spell",
                tooltip = Tooltips.BuffTap,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartLifeTap') and
                        RGMercUtils.DetSpellCheck(spell)
                end,
            },
            {
                name = "BiteTap",
                type = "Spell",
                tooltip = Tooltips.BiteTap,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartLifeTap')
                end,
            },
            {
                name = "LifeTap",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartLifeTap')
                end,
            },
            {
                name = "LifeTap2",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell)
                    return RGMercUtils.SpellLoaded(spell) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartLifeTap')
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                tooltip = Tooltips.Bash,
                cond = function(self)
                    return mq.TLO.Me.AbilityReady("Bash")() and RGMercUtils.GetTargetDistance() < 30
                end,
            },
            {
                name = "Slam",
                type = "Ability",
                tooltip = Tooltips.Slam,
                cond = function(self)
                    return mq.TLO.Me.AbilityReady("Slam")() and RGMercUtils.GetTargetDistance() < 30
                end,
            },
        },
    },
    ['Spells']          = {
        {
            gem = 1,
            spells = {
                { name = "DireDot", },
                { name = "LifeTap2", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "Spearnuke", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "Torrent", cond = function(self) return RGMercUtils.GetSetting('DoTorrent') end, },
                { name = "BondTap", },
                { name = "Terror2", },
            },
        },
        {
            gem = 4,
            spells = {
                {
                    name = "SnareDOT",
                    cond = function(self) return mq.TLO.Me.AltAbility("Encroaching Darkness")() == nil end,
                },
                { name = "DireTap", },
                { name = "AeTaunt", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "LifeTap", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "BuffTap", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "BiteTap", },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "AeTaunt",  cond = function(self) return RGMercUtils.GetSetting('DoAE') and mq.TLO.Me.AltAbility("Explosion of Hatred")() == nil end, },
                { name = "ForPower", },
                { name = "Terror", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Terror", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TempHP", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Skin", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Dicho", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {

            },
        },
    },
    ['PullAbilities']   = {
        {
            id = 'Terror',
            Type = "Spell",
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('Terror')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'SnareDOT',
            Type = "Spell",
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('SnareDOT').RankName.Name() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('SnareDOT').RankName.Name() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('SnareDOT')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'ForPower',
            Type = "Spell",
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('ForPower').RankName.Name() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('ForPower').RankName.Name() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('ForPower')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']   = {
        ['Mode']            = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 2, },
        ['DoTorrent']       = {
            DisplayName = "Cast Torrents",
            Category = "Spells and Abilities",
            Tooltip = function() return RGMercUtils.GetDynamicTooltipForSpell("Torrent") end,
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoDireTap']       = { DisplayName = "Cast Dire Taps", Category = "Spells and Abilities", Tooltip = "Enable casting Dire Tap spells.", RequiresLoadoutChange = true, Default = true, },
        ['DoBandolier']     = { DisplayName = "Use Bandolier", Category = "Equipment", Tooltip = "Enable Swapping of items using the bandolier.", Default = false, },
        ['DoSnare']         = { DisplayName = "Cast Snares", Category = "Spells and Abilities", Tooltip = "Enable casting Snare spells.", Default = true, },
        ['DoDot']           = { DisplayName = "Cast DOTs", Category = "Spells and Abilities", Tooltip = "Enable casting Damage Over Time spells.", Default = true, },
        ['DoAE']            = { DisplayName = "Use AE Taunts", Category = "Spells and Abilities", Tooltip = "Enable casting AE Taunt spells.", Default = true, },
        ['AeTauntCnt']      = { DisplayName = "AE Taunt Count", Category = "Spells and Abilities", Tooltip = "Minimum number of haters before using AE Taunt.", Default = 2, Min = 1, Max = 10, },
        ['HPStopDOT']       = { DisplayName = "HP Stop DOTs", Category = "Spells and Abilities", Tooltip = "Stop casting DOTs when the mob hits [x] HP %.", Default = 30, Min = 1, Max = 100, },
        ['UseVoT']          = { DisplayName = "Use Voice of Thule", Category = "Spells and Abilities", Tooltip = "Cast Voice of Thule", Default = true, },
        ['FlashHP']         = { DisplayName = "Use Shield Flash", Category = "Combat", Tooltip = "Your HP % before we use Shield Flash.", Default = 35, Min = 1, Max = 100, },
        ['DoChestClick']    = { DisplayName = "Do Chest Click", Category = "Equipment", Tooltip = "Click your chest item", Default = true, },
        ['DoCharmClick']    = { DisplayName = "Do Charm Click", Category = "Equipment", Tooltip = "Click your charm item", Default = true, },
        ['StartBigTap']     = { DisplayName = "Use Big Taps", Category = "Spells and Abilities", Tooltip = "Your HP % before we use Big Taps.", Default = 80, Min = 1, Max = 100, },
        ['StartLifeTap']    = { DisplayName = "Use Life Taps", Category = "Spells and Abilities", Tooltip = "Your HP % before we use Life Taps.", Default = 100, Min = 1, Max = 100, },
        ['MantleCount']     = { DisplayName = "Mantle Count", Category = "Disciplines", Tooltip = "Number of mobs around you before you use Mantle Disc.", Default = 3, Min = 1, Max = 10, },
        ['CarapaceCount']   = { DisplayName = "Carapace Count", Category = "Disciplines", Tooltip = "Number of mobs around you before you use Carapace Disc.", Default = 3, Min = 1, Max = 10, },
        ['CurseGuardCount'] = { DisplayName = "Curse Guard Count", Category = "Disciplines", Tooltip = "Number of mobs around you before you use Curse Guard Disc.", Default = 3, Min = 1, Max = 10, },
        ['UnholyCount']     = { DisplayName = "Unholy Count", Category = "Disciplines", Tooltip = "Number of mobs around you before you use Unholy Disc.", Default = 3, Min = 1, Max = 10, },
    },
}

return _ClassConfig
