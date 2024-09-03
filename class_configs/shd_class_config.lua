local mq           = require('mq')
local RGMercUtils  = require("utils.rgmercs_utils")

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
    Horror              = "Spell Line: Proc Mana Return",
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
    _version            = "1.3 beta",
    _author             = "Algar, Derple",
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
        ['OoW_Chest'] = {
            "Heartstiller's Mail Chestguard",
            "Duskbringer's Plate Chestguard of the Hateful",
        },
    },
    ['AbilitySets']     = {
        ['Mantle'] = {
            "Malarian Mantle", -- Level 83, Timer 5
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
            "Soul Carapace", -- Level 73, Timer 5
            "Umbral Carapace",
            "Malarian Carapace",
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
            "Touch of the Wailing Three", -- Level 75
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
        ['SnareDOT'] = {
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
        },
        ['InfluenceDisc'] = {
            "Insolent Influence",
            "Impudent Influence",
            "Impenitent Influence",
            "Impertinent Influence",
            "Ignominious Influence",
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
        -- helper function for advanced logic to see if we want to use Dark Lord's Unity
        -- TODO: Consider making a toggle for Azia vs Beza
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
        --Handles all AE taunt checks rather than repetetive hardcoded conditions in the UI loop
        AETauntCheck = function(self)
            --check to see if we are the tank in the first place just in case something CRAAAAAZY happens
            if not RGMercUtils.IsTanking() then return false end

            -- check that there are sufficient targets to AE taunt and that it is (optionally) safe to do so
            local mobs = mq.TLO.SpawnCount("NPC radius 50 zradius 50")()
            if (RGMercUtils.GetSetting('SafeAETaunt') and mobs > RGMercUtils.GetXTHaterCount()) or RGMercUtils.GetXTHaterCount() < RGMercUtils.GetSetting('AETauntCnt') then return false end

            --check to make sure the above targets need to be tanked
            local xtCount = mq.TLO.Me.XTarget()
            for i = 1, xtCount do
                local xtSpawn = mq.TLO.Me.XTarget(i)
                --ensure we only check hostiles, the hostile is in range, that we aren't already tanking it, and that the other xtargets aren't out of range of an AE taunt
                if xtSpawn() and (xtSpawn.ID() or 0) > 0 and (xtSpawn.TargetType() or ""):lower() == "auto hater"
                    and (xtSpawn.Distance() or 999) <= 50 and xtSpawn.PctAggro() < 100 and mobs > 1 then
                    return true
                end
            end

            return false
        end,
        --function to space out Epic and Omens Chest with Mortal Coil old-school swarm style. Epic has an override condition to fire anyway on named.
        LeechCheck = function(self)
            local LeechEffects = { "Leechcurse Discipline", "Mortal Coil", "Lich Sting Recourse", "Leeching Embrace", "Reaper Strike Recourse", }
            for _, buffName in ipairs(LeechEffects) do
                if RGMercUtils.BuffActiveByName(buffName) then return false end
            end
            return true
        end,
    },
    ['RotationOrder']   = {
        { --Self Buffs
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and RGMercUtils.DoBuffCheck()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'Pet Downtime',
            timer = 60,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and RGMercUtils.DoBuffCheck()
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'HateTools',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.IsTanking() and mq.TLO.Me.PctHPs() > RGMercUtils.GetSetting('EmergencyLockout')
            end,
        },
        { --Defensive actions triggered by low HP
            name = 'EmergencyDefenses',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('EmergencyStart')
            end,
        },
        { --Prioritized in their own rotation to help keep HP topped to the desired level, includes emergency abilities
            name = 'LifeTaps',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        { --Dynamic weapon swapping if UseBandolier is toggled
            name = 'Weapon Management',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.GetSetting('UseBandolier')
            end,
        },
        { --Defensive actions used proactively to prevent emergencies
            name = 'Defenses',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                --need to look at rotation and decide if it should fire during emergencies. leaning towards no
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > RGMercUtils.GetSetting('EmergencyLockout') and RGMercUtils.IsTanking()
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.GetSetting('DoSnare') and mq.TLO.Me.PctHPs() > RGMercUtils.GetSetting('EmergencyLockout')
            end,
        },
        { --Offensive actions to temporarily boost damage dealt
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.BurnCheck() and mq.TLO.Me.PctHPs() > RGMercUtils.GetSetting('EmergencyLockout')
            end,
        },
        { --Non-spell actions that can be used during/between casts
            name = 'CombatWeave',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > RGMercUtils.GetSetting('EmergencyLockout')
            end,
        },
        { --DPS Spells, includes recourse/gift maintenance
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() > RGMercUtils.GetSetting('EmergencyLockout')
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
                    return RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.Level() < 106 and mq.TLO.Me.PctEndurance() < 15
                end,
            },
            --If these tables were combined, errors could occur... there is no other good way I can think of to ensure a timer 13 ability that can be used in combat is scribed.
            {
                name = "CombatEndRegen",
                type = "Disc",
                tooltip = Tooltips.CombatEndRegen,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.Level() > 105 and mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Dark Lord's Unity (Azia)",
                type = "AA",
                tooltip = Tooltips.DLUA,
                active_cond = function(self, aaName) return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID() or 0) end,
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and self.ClassConfig.HelperFunctions.castDLU(self) and not RGMercUtils.BuffActive(mq.TLO.Me.AltAbility(aaName).Spell)
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
            --You'll notice my use of TotalSeconds, this is to keep as close to 100% uptime as possible on these buffs, rebuffing early to decrease the chance of them falling off in combat
            --I considered creating a function (helper or utils) to govern this as I use it on multiple classes but the difference between buff window/song window/aa/spell etc makes it unwieldy
            -- if using duration checks, dont use SelfBuffCheck() (as it could return false when the effect is still on)
            {
                name = "Skin",
                type = "Spell",
                tooltip = Tooltips.Skin,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.SpellStacksOnMe(spell) and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 60
                end,
            },
            {
                name = "TempHP",
                type = "Spell",
                tooltip = Tooltips.TempHP,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    if not RGMercUtils.GetSetting('DoTempHP') then return false end
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.SpellStacksOnMe(spell) and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 45
                end,
            },
            {
                name = "HealBurn",
                type = "Spell",
                tooltip = Tooltips.HealBurn,
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.SpellStacksOnMe(spell) and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "Voice of Thule",
                type = "AA",
                tooltip = Tooltips.VOT,
                active_cond = function(self, aaName) return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    if not RGMercUtils.GetSetting('UseVoT') then return false end
                    return RGMercUtils.SelfBuffAACheck(aaName)
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
                    return RGMercUtils.GetSetting('DoCharmClick') and item() and RGMercUtils.SelfBuffCheck(item.Spell) and item.TimerReady() == 0
                end,
            },
            {
                name = "PetSpell",
                type = "Spell",
                tooltip = Tooltips.PetSpell,
                active_cond = function(self, spell) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell)
                    if mq.TLO.Me.Pet.ID() ~= 0 or not RGMercUtils.GetSetting('DoPet') then return false end
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.ReagentCheck(spell)
                end,
            },
            {
                name = "Scourge Skin",
                type = "AA",
                --tooltip = Tooltips.ScourgeSkin,
                active_cond = function(self, aaName) return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    if not RGMercUtils.IsTanking() then return false end
                    return RGMercUtils.SelfBuffAACheck(aaName)
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
                    return RGMercUtils.PCSpellReady(spell) and RGMercUtils.SelfBuffPetCheck(spell)
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
                    return RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctHPs() < 25 and RGMercUtils.GetSetting('DoVetAA')
                end,
            },
            --Note that on named we may already have a mantle/carapace running already, could make this remove other discs, but meh, Shield Flash still a thing.
            {
                name = "Deflection",
                type = "Disc",
                tooltip = Tooltips.Deflection,
                pre_activate = function(self)
                    if RGMercUtils.GetSetting('UseBandolier') then
                        RGMercUtils.SafeCallFunc("Equip Shield", RGMercUtils.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('EmergencyLockout') and not mq.TLO.Me.ActiveDisc.ID() and RGMercUtils.PCDiscReady(discSpell) and
                        (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 999999) < 234000
                end,
            },
            {
                name = "Shield Flash",
                type = "AA",
                tooltip = Tooltips.ShieldFlash,
                pre_activate = function(self)
                    if RGMercUtils.GetSetting('UseBandolier') then
                        RGMercUtils.SafeCallFunc("Equip Shield", RGMercUtils.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, aaName)
                    return RGMercUtils.PCAAReady(aaName) and mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline"
                end,
            },
            {
                name = "LeechCurse",
                type = "Disc",
                tooltip = Tooltips.LeechCurse,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('EmergencyLockout') and not mq.TLO.Me.ActiveDisc.ID() and RGMercUtils.PCDiscReady(discSpell)
                end,
            },
            --Influence is in an odd place with Carapace. Usage is very subjective and may be more nuanced than automation can support. Placed here as an alternative to Carapace in low health situations to get you topped back off again for tanks. Should be used in burn for non-tanks (adding non-tank stuff is TODO)
            {
                name = "InfluenceDisc",
                type = "Disc",
                tooltip = Tooltips.InfluenceDisc,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID() and RGMercUtils.IsTanking()
                end,
            },
            {
                name = "Carapace",
                type = "Disc",
                tooltip = Tooltips.Carapace,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID() and mq.TLO.Me.Level() > 87 --Shares timer with mantle before 88
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    if not RGMercUtils.GetSetting('DoChestClick') then return false end
                    local item = mq.TLO.Me.Inventory("Chest")
                    return item() and item.TimerReady() == 0 and RGMercUtils.SpellStacksOnMe(item.Spell)
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                tooltip = Tooltips.Mantle,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            --if we made it this far let's reset our dicho/dire and hope for the best!
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                tooltip = Tooltips.ForcefulRejuv,
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
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
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and RGMercUtils.GetTargetPctHPs() < 90 and mq.TLO.Me.PctAggro() < 100
                end,
            },
            --used to jumpstart hatred on named from the outset and prevent early rips from burns
            {
                name = "Acrimony",
                type = "Disc",
                tooltip = Tooltips.Acrimony,
                cond = function(self, discSpell)
                    return RGMercUtils.NPCDiscReady(discSpell) and RGMercUtils.IsNamed(mq.TLO.Target)
                end,
            },
            --used to reinforce hatred on named
            {
                name = "Veil of Darkness",
                type = "AA",
                tooltip = Tooltips.VeilofDarkness,
                cond = function(self, aaName, target)
                    ---@diagnostic disable-next-line: undefined-field
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and RGMercUtils.IsNamed(mq.TLO.Target) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 70
                end,
            },
            {
                name = "AETaunt",
                type = "Spell",
                tooltip = Tooltips.AETaunt,
                cond = function(self, spell)
                    if RGMercUtils.GetSetting('AETauntSpell') == 1 then return false end
                    return RGMercUtils.PCSpellReady(spell) and self.ClassConfig.HelperFunctions.AETauntCheck(self)
                end,
            },
            {
                name = "Explosion of Hatred",
                type = "AA",
                tooltip = Tooltips.ExplosionOfHatred,
                cond = function(self, aaName, target)
                    if not RGMercUtils.GetSetting('AETauntAA') then return false end
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and self.ClassConfig.HelperFunctions.AETauntCheck(self)
                end,
            },
            {
                name = "Explosion of Spite",
                type = "AA",
                tooltip = Tooltips.ExplosionOfSpite,
                cond = function(self, aaName)
                    if not RGMercUtils.GetSetting('AETauntAA') then return false end
                    return RGMercUtils.AAReady(aaName) and self.ClassConfig.HelperFunctions.AETauntCheck(self)
                end,
            },
            {
                name = "Projection of Doom",
                type = "AA",
                tooltip = Tooltips.ProjectionofDoom,
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.IsNamed(mq.TLO.Target) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 80
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                tooltip = Tooltips.Taunt,
                cond = function(self, abilityName)
                    return mq.TLO.Me.AbilityReady(abilityName)() and mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and RGMercUtils.GetTargetID() > 0 and
                        RGMercUtils.GetTargetDistance() < 30
                end,
            },
            {
                name = "Terror",
                type = "Spell",
                tooltip = Tooltips.Terror,
                cond = function(self, spell, target)
                    if RGMercUtils.GetSetting('DoTerror') == 1 then return false end
                    ---@diagnostic disable-next-line: undefined-field
                    return RGMercUtils.NPCSpellReady(spell, target.ID()) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
            {
                name = "Terror2",
                type = "Spell",
                tooltip = Tooltips.Terror,
                cond = function(self, spell, target)
                    if RGMercUtils.GetSetting('DoTerror') == 1 then return false end
                    ---@diagnostic disable-next-line: undefined-field
                    return RGMercUtils.SpellLoaded(spell) and RGMercUtils.NPCSpellReady(spell, target.ID()) and (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
            {
                name = "ForPower",
                type = "Spell",
                tooltip = Tooltips.ForPower,
                cond = function(self, spell, target)
                    if not RGMercUtils.GetSetting('DoForPower') then return false end
                    return RGMercUtils.NPCSpellReady(spell, target.ID()) and RGMercUtils.DetSpellCheck(spell)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Visage of Death",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.MedBurn()
                end,
            },
            {
                name = "Crimson",
                type = "Disc",
                tooltip = Tooltips.Crimson,
                cond = function(self, discSpell)
                    return RGMercUtils.NPCDiscReady(discSpell) and RGMercUtils.MedBurn()
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    if not RGMercUtils.GetSetting('DoVetAA') then return false end
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.BigBurn()
                end,
            },
            {
                name = "Harm Touch",
                type = "AA",
                tooltip = Tooltips.HarmTouch,
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and RGMercUtils.MedBurn()
                end,
            },
            {
                name = "Thought Leech",
                type = "AA",
                tooltip = Tooltips.ThoughtLeech,
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and RGMercUtils.MedBurn()
                end,
            },
            {
                name = "Spire of the Reavers",
                type = "AA",
                tooltip = Tooltips.SpireoftheReavers,
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and RGMercUtils.SmallBurn()
                end,
            },
            {
                name = "Chattering Bones",
                type = "AA",
                tooltip = Tooltips.ChatteringBones,
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and RGMercUtils.SmallBurn()
                end,
            },
            {
                name = "T`Vyl's Resolve",
                type = "AA",
                tooltip = Tooltips.Tvyls,
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and RGMercUtils.SmallBurn()
                end,
            },
            {
                name = "SpiteStrike",
                type = "Disc",
                tooltip = Tooltips.SpikeStrike,
                cond = function(self, discSpell)
                    return not RGMercUtils.IsTanking() and RGMercUtils.PCDiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "UnholyAura",
                type = "Disc",
                tooltip = Tooltips.UnholyAura,
                cond = function(self, discSpell)
                    return not RGMercUtils.IsTanking() and RGMercUtils.PCDiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "InfluenceDisc",
                type = "Disc",
                tooltip = Tooltips.InfluenceDisc,
                cond = function(self, discSpell)
                    return not RGMercUtils.IsTanking() and RGMercUtils.PCDiscReady(discSpell) and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
        },
        ['Snare'] = {
            {
                name = "Encroaching Darkness",
                tooltip = Tooltips.EncroachingDarkness,
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and RGMercUtils.DetAACheck(aaName)
                end,
            },
            {
                name = "SnareDOT",
                type = "Spell",
                tooltip = Tooltips.SnareDOT,
                cond = function(self, spell, target)
                    if RGMercUtils.CanUseAA("Encroaching Darkness") then return false end
                    return RGMercUtils.NPCSpellReady(spell, target.ID()) and RGMercUtils.DetSpellCheck(spell)
                end,
            },
        },
        ['Defenses'] = {
            {
                name = "MeleeMit",
                type = "Disc",
                tooltip = Tooltips.MeleeMit,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and RGMercUtils.IsTanking()
                end,
            },
            {
                name = "Epic",
                type = "Item",
                tooltip = Tooltips.Epic,
                cond = function(self, itemName)
                    return mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0 and
                        (self.ClassConfig.HelperFunctions.LeechCheck(self) or RGMercUtils.IsNamed(mq.TLO.Target))
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
                    return RGMercUtils.PCDiscReady(discSpell) and RGMercUtils.IsTanking() and
                        (RGMercUtils.IsNamed(mq.TLO.Target) or mq.TLO.SpawnCount("NPC radius 30 zradius 50")() >= RGMercUtils.GetSetting('DiscCount')) and
                        not mq.TLO.Me.ActiveDisc.ID() and mq.TLO.Me.Level() > 87 --shares timer with mantle before 88
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                tooltip = Tooltips.Mantle,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and RGMercUtils.IsTanking() and
                        (RGMercUtils.IsNamed(mq.TLO.Target) or mq.TLO.SpawnCount("NPC radius 30 zradius 50")() >= RGMercUtils.GetSetting('DiscCount')) and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Guardian",
                type = "Disc",
                tooltip = Tooltips.Guardian,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and RGMercUtils.IsTanking() and
                        (RGMercUtils.IsNamed(mq.TLO.Target) or mq.TLO.SpawnCount("NPC radius 30 zradius 50")() > RGMercUtils.GetSetting('DiscCount')) and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "UnholyAura",
                type = "Disc",
                tooltip = Tooltips.UnholyAura,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and RGMercUtils.IsTanking() and
                        (RGMercUtils.IsNamed(mq.TLO.Target) or mq.TLO.SpawnCount("NPC radius 30 zradius 50")() >= RGMercUtils.GetSetting('DiscCount')) and
                        not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Purity of Death",
                type = "AA",
                tooltip = Tooltips.PurityofDeath,
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return mq.TLO.Me.TotalCounters() > 0 and RGMercUtils.AAReady(aaName)
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
                    return RGMercUtils.NPCAAReady(aaName, target.ID()) and mq.TLO.Me.PctHPs() < 25
                end,
            },
            --the trick with the next two is to find a sweet spot between using discs and long term CD abilities (we want these to trigger so those don't need to) and using them needlessly (which isn't much of a damage increase). Trying to get it dialed in for a good default value.
            {
                name = "Dicho",
                type = "Spell",
                tooltip = Tooltips.Dicho,
                cond = function(self, spell, target)
                    if not RGMercUtils.GetSetting('DoDicho') then return false end
                    return RGMercUtils.NPCSpellReady(spell, target.ID()) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartDicho')
                end,
            },
            {
                name = "DireTap",
                type = "Spell",
                tooltip = Tooltips.DireTap,
                cond = function(self, spell, target)
                    if not RGMercUtils.GetSetting('DoDireTap') then return false end
                    return RGMercUtils.NPCSpellReady(spell, target.ID()) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartDireTap')
                end,
            },
            {
                name = "LifeTap",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell, target)
                    return RGMercUtils.NPCSpellReady(spell, target.ID()) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartLifeTap')
                end,
            },
            { --This entry solely for emergencies on SK as a fallback, group has a different entry.
                name = "ReflexStrike",
                type = "Disc",
                tooltip = Tooltips.ReflexStrike,
                cond = function(self, discSpell)
                    return RGMercUtils.NPCDiscReady(discSpell) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('EmergencyStart')
                end,
            },
            {
                name = "LifeTap2",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell, target)
                    return RGMercUtils.SpellLoaded(spell) and RGMercUtils.NPCSpellReady(spell, target.ID()) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartLifeTap')
                end,
            },
        },
        ['CombatWeave'] = {
            { --Used if the group could benefit from the heal
                name = "ReflexStrike",
                type = "Disc",
                tooltip = Tooltips.ReflexStrike,
                cond = function(self, discSpell)
                    return RGMercUtils.NPCDiscReady(discSpell) and (mq.TLO.Group.Injured(80)() or 0) > 2
                end,
            },
            {
                name = "CombatEndRegen",
                type = "Disc",
                tooltip = Tooltips.CombatEndRegen,
                cond = function(self, discSpell)
                    return RGMercUtils.PCDiscReady(discSpell) and mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Vicious Bite of Chaos",
                type = "AA",
                tooltip = Tooltips.ViciousBiteOfChaos,
                cond = function(self, aaName, target)
                    return RGMercUtils.NPCAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Blade",
                type = "Disc",
                tooltip = Tooltips.Blade,
                cond = function(self, discSpell)
                    return RGMercUtils.NPCDiscReady(discSpell)
                end,
            },
            {
                name = "Gift of the Quick Spear",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                -- tooltip = Tooltips.Bash,
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.AbilityReady(abilityName)() and RGMercUtils.GetTargetDistance() <= (target.MaxRangeTo() or 0) and RGMercUtils.ShieldEquipped()
                end,
            },
            {
                name = "Slam",
                type = "Ability",
                tooltip = Tooltips.Slam,
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.AbilityReady(abilityName)() and RGMercUtils.GetTargetDistance() <= (target.MaxRangeTo() or 0)
                end,
            },
        },
        ['Combat'] = {
            {
                name = "BondTap",
                type = "Spell",
                tooltip = Tooltips.BondTap,
                cond = function(self, spell, target)
                    if not RGMercUtils.GetSetting('DoBondTap') then return false end
                    return (RGMercUtils.DotManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.DotSpellCheck(spell) and RGMercUtils.NPCSpellReady(spell, target.ID())
                end,
            },
            {
                name = "SpearNuke",
                type = "Spell",
                tooltip = Tooltips.SpearNuke,
                cond = function(self, spell, target)
                    return RGMercUtils.NPCSpellReady(spell, target.ID()) and (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck())
                end,
            },
            {
                name = "PoisonDot",
                type = "Spell",
                tooltip = Tooltips.PoisonDot,
                cond = function(self, spell, target)
                    if not RGMercUtils.GetSetting('DoPoisonDot') then return false end
                    return (RGMercUtils.DotManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.DotSpellCheck(spell) and RGMercUtils.NPCSpellReady(spell, target.ID())
                end,
            },
            {
                name = "CorruptionDot",
                type = "Spell",
                tooltip = Tooltips.PoisonDot,
                cond = function(self, spell, target)
                    if not RGMercUtils.GetSetting('DoCorruptionDot') then return false end
                    return (RGMercUtils.DotManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.DotSpellCheck(spell) and RGMercUtils.NPCSpellReady(spell, target.ID())
                end,
            },
            {
                name = "DireDot",
                type = "Spell",
                tooltip = Tooltips.DireDot,
                cond = function(self, spell, target)
                    if not RGMercUtils.GetSetting('DoDireDot') then return false end
                    return (RGMercUtils.DotManaCheck() or RGMercUtils.BurnCheck()) and RGMercUtils.DotSpellCheck(spell) and RGMercUtils.NPCSpellReady(spell, target.ID())
                end,
            },
            {
                name = "BiteTap",
                type = "Spell",
                tooltip = Tooltips.BiteTap,
                cond = function(self, spell, target)
                    return RGMercUtils.NPCSpellReady(spell, target.ID()) and mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StartLifeTap')
                end,
            },
            {
                name = "Torrent",
                type = "Spell",
                tooltip = Tooltips.Torrent,
                cond = function(self, spell, target)
                    if not RGMercUtils.GetSetting('DoTorrent') then return false end
                    return not RGMercUtils.BuffActiveByName(spell.Name() .. " Recourse") and RGMercUtils.NPCSpellReady(spell, target.ID())
                end,
            },
            {
                name = "BuffTap",
                type = "Spell",
                tooltip = Tooltips.BuffTap,
                cond = function(self, spell, target)
                    if not RGMercUtils.GetSetting('DoBuffTap') then return false end
                    return not RGMercUtils.BuffActive(spell.RankName.Name.Trigger(1)()) and RGMercUtils.SpellStacksOnMe(spell.RankName.Name.Trigger(1)()) and
                        RGMercUtils.NPCSpellReady(spell, target.ID())
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
                    return (mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('EquipShield')) or (RGMercUtils.IsNamed(mq.TLO.Target) and RGMercUtils.GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return RGMercUtils.BandolierSwap("Shield") end,
            },
            {
                name = "Equip 2Hand",
                type = "CustomFunc",
                active_cond = function(self, target)
                    return mq.TLO.Me.Bandolier("2Hand").Active()
                end,
                cond = function(self)
                    if mq.TLO.Me.Bandolier("2Hand").Active() then return false end
                    return mq.TLO.Me.PctHPs() >= RGMercUtils.GetSetting('Equip2Hand') and mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline" and
                        (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 0) < 234000 and not (RGMercUtils.IsNamed(mq.TLO.Target) and RGMercUtils.GetSetting('NamedShieldLock'))
                end,
                custom_func = function(self) return RGMercUtils.BandolierSwap("2Hand") end,
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
                { name = "SnareDOT", cond = function(self) return RGMercUtils.GetSetting('DoSnare') and not RGMercUtils.CanUseAA("Encroaching Darkness") end, },
                { name = "DireTap",  cond = function(self) return RGMercUtils.GetSetting('DoDireTap') end, },
                { name = "Dicho",    cond = function(self) return RGMercUtils.GetSetting('DoDicho') end, },
                { name = "ForPower", cond = function(self) return RGMercUtils.GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not RGMercUtils.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "DireTap",  cond = function(self) return RGMercUtils.GetSetting('DoDireTap') end, },
                { name = "Dicho",    cond = function(self) return RGMercUtils.GetSetting('DoDicho') end, },
                { name = "ForPower", cond = function(self) return RGMercUtils.GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not RGMercUtils.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return RGMercUtils.GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return RGMercUtils.GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return RGMercUtils.GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return RGMercUtils.GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return RGMercUtils.GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return RGMercUtils.GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return RGMercUtils.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "Dicho",    cond = function(self) return RGMercUtils.GetSetting('DoDicho') end, },
                { name = "ForPower", cond = function(self) return RGMercUtils.GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not RGMercUtils.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return RGMercUtils.GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return RGMercUtils.GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return RGMercUtils.GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return RGMercUtils.GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return RGMercUtils.GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return RGMercUtils.GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return RGMercUtils.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "ForPower",      cond = function(self) return RGMercUtils.GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not RGMercUtils.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return RGMercUtils.GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return RGMercUtils.GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return RGMercUtils.GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return RGMercUtils.GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return RGMercUtils.GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return RGMercUtils.GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return RGMercUtils.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
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
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not RGMercUtils.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return RGMercUtils.GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return RGMercUtils.GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return RGMercUtils.GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return RGMercUtils.GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return RGMercUtils.GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return RGMercUtils.GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return RGMercUtils.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
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
                        local setting = RGMercUtils.GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not RGMercUtils.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return RGMercUtils.GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return RGMercUtils.GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return RGMercUtils.GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return RGMercUtils.GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return RGMercUtils.GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return RGMercUtils.GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return RGMercUtils.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
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
                { name = "BondTap",       cond = function(self) return RGMercUtils.GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return RGMercUtils.GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return RGMercUtils.GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return RGMercUtils.GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return RGMercUtils.GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return RGMercUtils.GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return RGMercUtils.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 75
            gem = 10,
            cond = function(self) return mq.TLO.Me.NumGems() >= 11 end,
            spells = {
                { name = "BondTap",       cond = function(self) return RGMercUtils.GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return RGMercUtils.GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return RGMercUtils.GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return RGMercUtils.GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return RGMercUtils.GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return RGMercUtils.GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return RGMercUtils.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 80
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TempHP",        cond = function(self) return RGMercUtils.GetSetting('DoTempHP') end, }, --level 84, this spell starts in a long recast so I prefer to keep it on the bar.
                { name = "PoisonDot",     cond = function(self) return RGMercUtils.GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return RGMercUtils.GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return RGMercUtils.GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return RGMercUtils.GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return RGMercUtils.GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return RGMercUtils.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 80
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Skin",          cond = function(self) return RGMercUtils.IsTanking() end, }, -- level 70, while not as bad as the TempHP line, also starts in a recast. Placed higher before level 106.
                { name = "CorruptionDot", cond = function(self) return RGMercUtils.GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return RGMercUtils.GetSetting('DoDireDot') end, },
                {
                    name = "Torrent",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return RGMercUtils.GetSetting('DoTorrent') and (level <= 65 or level >= 100)
                    end,
                },
                { name = "BuffTap",  cond = function(self) return RGMercUtils.GetSetting('DoBuffTap') end, },
                { name = "Skin",     cond = function(self) return RGMercUtils.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = RGMercUtils.GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 106
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HealBurn", cond = function(self) return RGMercUtils.IsTanking() end, }, --level 103, this may be overwritten by pauses but it is fine, it has a low refresh time. At least it will be there on start.
            },
        },
    },
    ['PullAbilities']   = {
        {
            id = 'SpearNuke',
            Type = "Spell",
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('SpearNuke').RankName.Name() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('SpearNuke').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('SpearNuke')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'Terror',
            Type = "Spell",
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('Terror')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'ForPower',
            Type = "Spell",
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('ForPower').RankName.Name() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('ForPower').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('ForPower')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'Lifetap',
            Type = "Spell",
            DisplayName = function() return RGMercUtils.GetResolvedActionMapItem('Lifetap').RankName.Name() or "" end,
            AbilityName = function() return RGMercUtils.GetResolvedActionMapItem('Lifetap').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = RGMercUtils.GetResolvedActionMapItem('Lifetap')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']   = {
        --Mode
        ['Mode']             = { DisplayName = "Mode", Category = "Mode", Tooltip = "Select the active Combat Mode for this PC.", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 2, },

        --Buffs and Debuffs
        ['DoSnare']          = { DisplayName = "Use Snares", Category = "Buffs/Debuffs", Index = 1, Tooltip = "Use Snare(Snare Dot used until AA is available).", Default = false, RequiresLoadoutChange = true, },
        ['DoTempHP']         = { DisplayName = "Use HP Buff", Category = "Buffs/Debuffs", Index = 2, Tooltip = function() return RGMercUtils.GetDynamicTooltipForSpell("TempHP") end, Default = true, RequiresLoadoutChange = true, },
        ['DoTorrent']        = { DisplayName = "Use Torrents", Category = "Buffs/Debuffs", Index = 3, Tooltip = function() return RGMercUtils.GetDynamicTooltipForSpell("Torrent") end, RequiresLoadoutChange = true, Default = true, ConfigType = "Advanced", },
        ['DoBuffTap']        = { DisplayName = "Use Buff Tap", Category = "Buffs/Debuffs", Index = 4, Tooltip = function() return RGMercUtils.GetDynamicTooltipForSpell("BuffTap") end, Default = false, RequiresLoadoutChange = true, ConfigType = "Advanced", },
        ['DoVetAA']          = { DisplayName = "Use Vet AA", Category = "Buffs/Debuffs", Index = 5, Tooltip = "Use Veteran AA's in emergencies or during BigBurn.", Default = true, },

        --LifeTaps
        ['StartLifeTap']     = { DisplayName = "HP % for LifeTaps", Category = "LifeTaps", Index = 1, Tooltip = "Your HP % before we use Life Taps.", Default = 99, Min = 1, Max = 100, },
        ['DoDireTap']        = { DisplayName = "Cast Dire Taps", Category = "LifeTaps", Index = 2, Tooltip = function() return RGMercUtils.GetDynamicTooltipForSpell("DireTap") end, RequiresLoadoutChange = true, Default = true, ConfigType = "Advanced", },
        ['StartDireTap']     = { DisplayName = "HP % for Dire", Category = "LifeTaps", Index = 3, Tooltip = "Your HP % before we use Dire taps.", Default = 85, Min = 1, Max = 100, ConfigType = "Advanced", },
        ['DoDicho']          = { DisplayName = "Cast Dicho Taps", Category = "LifeTaps", Index = 4, Tooltip = function() return RGMercUtils.GetDynamicTooltipForSpell("Dicho") end, RequiresLoadoutChange = true, Default = true, ConfigType = "Advanced", },
        ['StartDicho']       = { DisplayName = "HP % for Dicho", Category = "LifeTaps", Index = 5, Tooltip = "Your HP % before we use Dicho taps.", Default = 70, Min = 1, Max = 100, ConfigType = "Advanced", },

        --DoTs
        ['DoBondTap']        = { DisplayName = "Use Bond Dot", Category = "DoT Spells", Index = 1, function() return RGMercUtils.GetDynamicTooltipForSpell("BondTap") end, RequiresLoadoutChange = true, Default = true, },
        ['DoPoisonDot']      = { DisplayName = "Use Poison Dot", Category = "DoT Spells", Index = 2, function() return RGMercUtils.GetDynamicTooltipForSpell("PoisonDot") end, RequiresLoadoutChange = true, Default = true, },
        ['DoCorruptionDot']  = { DisplayName = "Use Corrupt Dot", Category = "DoT Spells", Index = 3, function() return RGMercUtils.GetDynamicTooltipForSpell("CorruptDot") end, RequiresLoadoutChange = true, Default = true, },
        ['DoDireDot']        = { DisplayName = "Use Dire Dot", Category = "DoT Spells", Index = 4, function() return RGMercUtils.GetDynamicTooltipForSpell("Dicho") end, RequiresLoadoutChange = true, Default = false, },
        ['HPStopDOT']        = { DisplayName = "HP Stop DoTs", Category = "Spells and Abilities", Index = 5, Tooltip = "Stop casting DOTs when the mob hits [x] HP %.", Default = 50, Min = 1, Max = 100, ConfigType = "Advanced", },
        ['NamedStopDOT']     = { DisplayName = "Named HP Stop DOTs", Category = "Spells and Abilities", Index = 6, Tooltip = "Stop casting DOTs when a named mob hits [x] HP %.", Default = 25, Min = 1, Max = 100, ConfigType = "Advanced", },

        --Hate Tools
        ['UseVoT']           = { DisplayName = "Use VoT AA", Category = "Hate Tools", Index = 1, Tooltip = "Use Hate Buff AA. Spells currently not used because of low values and long refresh times.", Default = true, ConfigType = "Advanced", },
        ['DoTerror']         = { DisplayName = "Terror Taunts:", Category = "Hate Tools", Index = 2, Tooltip = "Choose the level range (if any) to memorize Terror Spells.", RequiresLoadoutChange = true, Type = "Combo", ComboOptions = { 'Never', 'Until "For Power" spells are available', 'Always', }, Default = 2, Min = 1, Max = 3, },
        ['DoForPower']       = { DisplayName = "Use \"For Power\"", Category = "Hate Tools", Index = 3, Tooltip = function() return RGMercUtils.GetDynamicTooltipForSpell("ForPower") end, RequiresLoadoutChange = true, Default = true, ConfigType = "Advanced", },
        ['AETauntAA']        = { DisplayName = "Use AE Taunt AA", Category = "Hate Tools", Index = 4, Tooltip = "Use Explosions of Hatred and Spite.", Default = true, ConfigType = "Advanced", },
        ['AETauntSpell']     = { DisplayName = "AE Taunt Spell Choice:", Category = "Hate Tools", Index = 5, Tooltip = "Choose the level range (if any) to memorize AE Taunt Spells.", RequiresLoadoutChange = true, Type = "Combo", ComboOptions = { 'Never', 'Until Explosions (AA Taunts) are available', 'Always', }, Default = 2, Min = 1, Max = 3, ConfigType = "Advanced", },
        ['AETauntCnt']       = { DisplayName = "AE Taunt Count", Category = "Hate Tools", Index = 6, Tooltip = "Minimum number of haters before using AE Taunt Spells or AA.", Default = 2, Min = 1, Max = 10, },
        ['SafeAETaunt']      = { DisplayName = "AE Taunt Safety Check", Category = "Hate Tools", Index = 7, Tooltip = "Limit unintended pulls with AE Taunt Spells or AA. May result in non-use due to false positives.", Default = false, },

        --Defenses
        ['DiscCount']        = { DisplayName = "Def. Disc. Count", Category = "Defenses", Index = 1, Tooltip = "Number of mobs around you before you use preemptively use Defensive Discs.", Default = 4, Min = 1, Max = 10, ConfigType = "Advanced", },
        ['EmergencyStart']   = { DisplayName = "Emergency Start", Category = "Defenses", Index = 2, Tooltip = "Your HP % before we begin to use emergency abilities.", Default = 55, Min = 1, Max = 100, ConfigType = "Advanced", },
        ['EmergencyLockout'] = { DisplayName = "Emergency Only", Category = "Defenses", Index = 3, Tooltip = "Your HP % before standard DPS rotations are cut in favor of emergency abilities.", Default = 35, Min = 1, Max = 100, ConfigType = "Advanced", },

        --Equipment
        ['DoChestClick']     = { DisplayName = "Do Chest Click", Category = "Equipment", Index = 1, Tooltip = "Click your equipped chest.", Default = true, },
        ['DoCharmClick']     = { DisplayName = "Do Charm Click", Category = "Equipment", Index = 2, Tooltip = "Click your charm for Geomantra.", Default = true, },
        ['UseBandolier']     = { DisplayName = "Dynamic Weapon Swap", Category = "Equipment", Index = 3, Tooltip = "Enable 1H+S/2H swapping based off of current health. ***YOU MUST HAVE BANDOLIER ENTRIES NAMED \"Shield\" and \"2Hand\" TO USE THIS FUNCTION.***", Default = false, },
        ['EquipShield']      = { DisplayName = "Equip Shield", Category = "Equipment", Index = 4, Tooltip = "Under this HP%, you will swap to your \"Shield\" bandolier entry. (Dynamic Bandolier Enabled Only)", Default = 50, Min = 1, Max = 100, ConfigType = "Advanced", },
        ['Equip2Hand']       = { DisplayName = "Equip 2Hand", Category = "Equipment", Index = 5, Tooltip = "Over this HP%, you will swap to your \"2Hand\" bandolier entry. (Dynamic Bandolier Enabled Only)", Default = 75, Min = 1, Max = 100, ConfigType = "Advanced", },
        ['NamedShieldLock']  = { DisplayName = "Shield on Named", Category = "Equipment", Index = 6, Tooltip = "Keep Shield equipped for Named mobs(must be in SpawnMaster or named.lua)", Default = true, },
    },
}

return _ClassConfig
