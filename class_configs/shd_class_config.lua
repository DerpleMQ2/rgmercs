local mq           = require('mq')
local RGMercUtils  = require("rgmercs.utils.rgmercs_utils")

local Tooltips     = {
    Mantle = "Spell Line: Melee Absorb Proc",
    Carapace = "Spell Line: Melee Absorb Proc",
    EndRegen = "Discipline Line: Endurance Regen",
    Blade = "Ability Line: Double 2HS Attack w/ Accuracy Mod",
    Crimson = "Disicpline Line: Triple Attack w/ Accuracy Mod",
    MeleeMit = "Discipline Line: Absorb Incoming Dmg",
    Deflection = "Discipline: Shield Block Chance 100%",
    LeechCurse = "Discipline: Melee Lifetap w/ Increase Hit Chance",
    UnholyAura = "Discipline: Increase Lifetap Spell Damage",
    CurseGuard = "Discipline: Melee Mtigation w/ Defensive Lifetap & Lowered Melee DMG Output",
    PetSpell = "Spell Line: Summons SK Pet",
    PetHaste = "Spell Line: Haste Buff for SK Pet",
    Shroud = "Spell Line: Add Melee Lifetap Proc",
    Horror = "Spell Line: Proc Mana Return",
    Skin = "Spell Line: Melee Absorb Proc",
    SelfDS = "Spell Line: Self Damage Shield",
    Demeanor = "Spell Line: Add Lifetap Proc Buff on Killshot",
    HealBurn = "Spell Line: Add Hate Proc on Incoming Spell Damage",
    CloakHP = "Spell Line: Increase HP and Stacking DS",
    Covenant = "Spell Line: Increase Mana Regen + Ultravision / Decrease HP Per Tick",
    CallAtk = "Spell Line: Increase Attack / Decrease HP Per Tick",
    AeTaunt = "Spell Line: PBAE Hate Increase + Taunt",
    PoisonDot = "Spell Line: Poison Dot",
    Spearnuke = "Spell Line: Instacast Disease Nuke",
    BondTap = "Spell Line: Lifetap DOT",
    Diretap = "Spell Line: Lifetap",
    Lifetap = "Spell Line: Lifetap",
    Bufftap = "Spell Line: Lifetap + Hate Increase + HP Regen",
    Bitetap = "Spell Line: Lifetap + Manatap",
    ForPower =
    "Spell Line: Hate Increase + Hate Increase DOT + AC Buff 'BY THE POWER OF GRAYSKULL, I HAVE THE POWER -- HE-MAN'",
    Terror = "Spell Line: Hate Increase + Taunt",
    TempHP = "Spell Line: Temporary Hitpoints (Decrease per Tick)",
    Dicho = "Spell Line: Hate Increase + Lifetap",
    Torrent = "Spell Line: Attack Tap",
    SnareDOT = "Spell Line: Snare + HP DOT",
    Acrimony = "Spell Increase: Aggrolock + Lifetap DOT + Hate Generation",
    SpiteStrike = "Spell Line: Lifetap + Caster 1H Blunt Increase + Target Armor Decrease",
    ReflexStrike = "Ability: Triple 2HS Attack + HP Increase",
    DireDot = "Spell Line: DOT + AC Decrease + Strength Decrease",
    AllianceNuke =
    "Spell Line: Alliance (Requires Multiple of Same Class) - Increase Spell Damage Taken by Target + Large Lifetap",
    InfluenceDisc = "Ability Line: Increase AC + Absorb Damage + Melee Proc (Lifetap + Max HP Increase)",
    DLUA = "AA: Cast Highest Level of Scribed Buffs (Shroud, Horror, Drape, Demeanor, Skin, Covenant, CallATK)",
    HarmTouch = "AA: Harms Target HP",
    ThoughtLeech = "AA: Harms Target HP + Harms Target Mana",
    VisageOfDeath = "Spell: Increases Melee Hit Dmg + Illusion",
    LeechTouch = "AA: Lifetap Touch",
    Tyvls = "Spell: Triple 2HS Attack + % Melee Damage Increase on Target",
    ActivateSHield = "Activate 'Shield' if set in Bandolier",
    Activate2HS = "Activate '2HS' if set in Bandolier",
    ExplosionOfHatred = "Spell: Targeted AE Hatred Increase",
    ExplosionOfSpite = "Spell: Targeted PBAE Hatred Increase",
    Taunt = "Ability: Increases Hatred to 100% + 1",
    EncroachingDarkness = "Ability: Snare + HP DOT",
    Epic = 'Item: Casts Epic Weapon Ability',
    ViciousBiteOfChaos = "Spell: Duration Lifetap + Mana Return",
}

local _ClassConfig = {
    ['Modes'] = {
        [1] = 'Tank',
        [2] = 'DPS',
    },
    ['ItemSets'] = {
        ['Epic'] = {
            [1] = "Innoruuk's Dark Blessing",
            [2] = "Innoruuk's Voice",
        },
    },
    ['AbilitySets'] = {
        ['Mantle'] = {
            [1] = "Malarian Mantle",
            [2] = "Gorgon Mantle",
            [3] = "Recondite Mantle",
            [4] = "Bonebrood Mantle",
            [5] = "Doomscale Mantle",
            [6] = "Krellnakor Mantle",
            [7] = "Restless Mantle",
            [8] = "Fyrthek Mantle",
            [9] = "Geomimus Mantle",
        },
        ['Carapace'] = {
            [1] = "Soul Carapace",
            [2] = "Umbral Carapace",
            [3] = "Malarian Carapace",
            [4] = "Gorgon Carapace",
            [5] = "Sholothian Carapace",
            [6] = "Grelleth's Carapace",
            [7] = "Vizat's Carapace",
            [8] = "Tylix's Carapace",
            [9] = "Cadcane's Carapace",
            [10] = "Xetheg's Carapace",
            [11] = "Kanghammer's Carapace",
        },
        ['EndRegen'] = {
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
            [11] = "Convalesce",
        },
        ['Blade'] = {
            [1] = "Incapacitating Blade",
            [2] = "Grisly Blade",
            [3] = "Gouging Blade",
            [4] = "Gashing Blade",
            [5] = "Lacerating Blade",
            [6] = "Wounding Blade",
            [7] = "Rending Blade",
        },
        ['Crimson'] = {
            [1] = "Crimson Blade",
            [2] = "Scarlet Blade",
            [3] = "Carmine Blade",
            [4] = "Claret Blade",
            [5] = "Cerise Blade",
            [6] = "Sanguine Blade",
            [7] = "Incarnadine Blade",
        },
        ['MeleeMit'] = {
            [1] = "Withstand",
            [2] = "Defy",
            [3] = "Renounce",
            [4] = "Reprove",
            [5] = "Repel",
            [6] = "Spurn",
            [7] = "Thwart",
            [8] = "Repudiate",
            [9] = "Gird",
        },
        ['Deflection'] = { [1] = 'Deflection Discipline' },
        ['LeechCurse'] = { [1] = 'Leechcurse Discipline' },
        ['UnholyAura'] = { [1] = 'Unholy Aura Discipline' },
        ['CurseGuard'] = { [1] = 'Cursed Guardian Discipline' },
        ['PetSpell'] = {
            [1] = "Leering Corpse",
            [2] = "Bone Walk",
            [3] = "Convoke Shadow",
            [4] = "Restless Bones",
            [5] = "Animate Dead",
            [6] = "Summon Dead",
            [7] = "Malignant Dead",
            [8] = "Cackling Bones",
            [9] = "Invoke Death",
            [10] = "Son of Decay",
            [11] = "Maladroit Minion",
            [12] = "Minion of Sebilis",
            [13] = "Minion of Fear",
            [14] = "Minion of Sholoth",
            [15] = "Minion of Grelleth",
            [16] = "Minion of Vizat",
            [17] = "Minion of T`Vem",
            [18] = "Minion of Drendar",
            [19] = "Minion of Itzal",
            [20] = "Minion of Fandrel",
        },
        ['PetHaste'] = {
            [1] = "Gift of Fandrel",
            [2] = "Gift of Itzal",
            [3] = "Gift of Drendar",
            [4] = "Gift of T`Vem",
            [5] = "Gift of Lutzen",
            [6] = "Gift of Urash",
            [7] = "Gift of Dyalgem",
            [8] = "Expatiate Death",
            [9] = "Amplify Death",
            [10] = "Rune of Decay",
            [11] = "Augment Death",
            [12] = "Strengthen Death",
        },
        ['Shroud'] = {
            [1] = "Shroud of Death",
            [2] = "Shroud of Chaos",
            [3] = "Black Shroud",
            [4] = "Shroud of Discord",
            [5] = "Shroud of the Gloomborn",
            [6] = "Shroud of the Blightborn",
            [7] = "Shroud of the Plagueborne",
            [8] = "Shroud of the Shadeborne",
            [9] = "Shroud of the Darksworn",
            [10] = "Shroud of the Doomscale",
            [11] = "Shroud of the Krellnakor",
            [12] = "Shroud of the Restless",
            [13] = "Shroud of Zelinstein",
            [14] = "Shroud of Rimeclaw",
        },
        ['Horror'] = {
            [1] = "Mental Horror",
            [2] = "Marrowthirst Horror",
            [3] = "Soulthirst Horror",
            [4] = "Mindshear Horror",
            [5] = "Amygdalan Horror",
            [6] = "Sholothian Horror",
            [7] = "Grelleth's Horror",
            [8] = "Vizat's Horror",
            [9] = "Tylix's Horror",
            [10] = "Cadcane's Horror",
            [11] = "Brightfeld's Horror",
            [12] = "Mortimus' Horror",
        },
        ['Skin'] = {
            [1] = "Decrepit Skin",
            [2] = "Umbral Skin",
            [3] = "Malarian Skin",
            [4] = "Gorgon Skin",
            [5] = "Sholothian Skin",
            [6] = "Grelleth's Skin",
            [7] = "Vizat's Skin",
            [8] = "Tylix's Skin",
            [9] = "Cadcane's Skin",
            [10] = "Xenacious' Skin",
            [11] = "Krizad's Skin",
        },
        ['SelfDS'] = {
            [1] = "Banshee Aura",
            [2] = "Banshee Skin",
            [3] = "Ghoul Skin",
            [4] = "Zombie Skin",
            [5] = "Helot Skin",
            [6] = "Specter Skin",
            [7] = "Tekuel Skin",
            [8] = "Goblin Skin",
        },
        ['Demeanor'] = {
            [1] = "Remorseless Demeanor",
            [2] = "Impenitent Demeanor",
        },
        ['HealBurn'] = {
            [1] = "Harmonious Disruption",
            [2] = "Concordant Disruption",
            [3] = "Confluent Disruption",
            [4] = "Penumbral Disruption",
        },
        ['CloakHP'] = {
            [1] = "Cloak of the Akheva",
            [2] = "Cloak of Luclin",
            [3] = "Cloak of Discord",
            [4] = "Cloak of Corruption",
            [5] = "Drape of Corruption",
            [6] = "Drape of Korafax",
            [7] = "Drape of Fear",
            [8] = "Drape of the Sepulcher",
            [9] = "Drape of the Fallen",
            [10] = "Drape of the Wrathforged",
            [11] = "Drape of the Magmaforged",
            [12] = "Drape of the Iceforged",
            [13] = "Drape of the Akheva",
            [14] = "Drape of the Ankexfen",
        },
        ['Covenant'] = {
            [1] = "Grim Covenant",
            [2] = "Venril's Covenant",
            [3] = "Gixblat's Covenant",
            [4] = "Worag's Covenant",
            [5] = "Falhotep's Covenant",
            [6] = "Livio's Covenant",
            [7] = "Helot Covenant",
            [8] = "Syl`Tor Covenant",
            [9] = "Aten Ha Ra's Covenant",
            [10] = "Kar's Covenant",
        },
        ['CallAtk'] = {
            [1] = "Call of Blight",
            [2] = "Call of Darkness",
            [3] = "Call of Dusk",
            [4] = "Call of Shadow",
            [5] = "Call of Gloomhaze",
            [6] = "Call of Nightfall",
            [7] = "Call of Twilight",
            [8] = "Penumbral Call",
        },
        ['AeTaunt'] = {
            [1] = "Dread Gaze",
            [2] = "Vilify",
            [3] = "Revile",
            [4] = "Burst of Spite",
            [5] = "Loathing",
            [6] = "Abhorrence",
            [7] = "Antipathy",
            [8] = "Animus",
        },
        ['PoisonDot'] = {
            [1] = "Blood of Pain",
            [2] = "Blood of Hate",
            [3] = "Blood of Discord",
            [4] = "Blood of Inruku",
            [5] = "Blood of the Blacktalon",
            [6] = "Blood of the Blackwater",
            [7] = "Blood of Laarthik",
            [8] = "Blood of Malthiasiss",
            [9] = "Blood of Korum",
            [10] = "Blood of Ralstok",
            [11] = "Blood of Bonemaw",
            [12] = "Blood of Drakus",
            [13] = "Blood of Ikatiar",
            [14] = "Blood of Tearc",
            [15] = "Blood of Shoru",
        },
        ['Spearnuke'] = {
            [1] = "Spike of Disease",
            [2] = "Spear of Disease",
            [3] = "Spear of Pain",
            [4] = "Spear of Plague",
            [5] = "Spear of Decay",
            [6] = "Miasmic Spear",
            [7] = "Spear of Muram",
            [8] = "Rotroot Spear",
            [9] = "Rotmarrow Spear",
            [10] = "Malarian Spear",
            [11] = "Gorgon Spear",
            [12] = "Spear of Sholoth",
            [13] = "Spear of Grelleth",
            [14] = "Spear of Vizat",
            [15] = "Spear of Tylix",
            [16] = "Spear of Cadcane",
            [17] = "Spear of Bloodwretch",
            [18] = "Spear of Lazam",
        },
        ['BondTap'] = {
            [1] = "Bond of Tatalros",
            [2] = "Bond of Bynn",
            [3] = "Bond of Vulak",
            [4] = "Bond of Xalgoz",
            [5] = "Bond of Bonemaw",
            [6] = "Bond of Ralstok",
            [7] = "Bond of Korum",
            [8] = "Bond of Malthiasiss",
            [9] = "Bond of Laarthik",
            [10] = "Bond of the Blackwater",
            [11] = "Bond of the Blacktalon",
            [12] = "Bond of Inruku",
            [13] = "Bond of Death",
            [14] = "Vampiric Curse",
        },
        ['Diretap'] = {
            [1] = "Dire Implication",
            [2] = "Dire Accusation",
            [3] = "Dire Allegation",
            [4] = "Dire Insinuation",
            [5] = "Dire Declaration",
            [6] = "Dire Testimony",
            [7] = "Dire Indictment",
            [8] = "Dire Censure",
            [9] = "Dire Rebuke",
        },
        ['Lifetap'] = {
            [1] = "Touch of Flariton",
            [2] = "Touch of Txiki",
            [3] = "Touch of the Wailing Three",
            [4] = "Touch of the Soulbleeder",
            [5] = "Touch of Lanys",
            [6] = "Touch of Dyalgem",
            [7] = "Touch of Urash",
            [8] = "Touch of Falsin",
            [9] = "Touch of Lutzen",
            [10] = "Touch of T`Vem",
            [11] = "Touch of Drendar",
            [12] = "Touch of Severan",
            [13] = "Touch of the Devourer",
            [14] = "Touch of Draygun",
            [15] = "Touch of Innoruuk",
            [16] = "Touch of Volatis",
            [17] = "Drain Soul",
            [18] = "Drain Spirit",
            [19] = "Spirit Tap",
            [20] = "Siphon Life",
            [21] = "Life Leech",
            [22] = "Lifedraw",
            [23] = "Lifespike",
            [24] = "Lifetap",
        },
        ['Bufftap'] = {
            [1] = "Touch of Mortimus",
            [2] = "Touch of Namdrows",
            [3] = "Touch of Zlandicar",
            [4] = "Touch of the Wailing Three",
            [5] = "Touch of Kildrukaun",
            [6] = "Touch of Tharoff",
            [7] = "Touch of Iglum",
            [8] = "Touch of Piqiorn",
            [9] = "Touch of Klonda",
            [10] = "Touch of Holmein",
            [11] = "Touch of Hemofax",
            [12] = "Siphon Strength",
            [13] = "Despair",
            [14] = "Scream of Hate",
            [15] = "Scream of Pain",
            [16] = "Shroud of Hate",
            [17] = "Shroud of Pain",
            [18] = "Abduction of Strength",
            [19] = "Torrent of Hate",
            [20] = "Torrent of Pain",
            [21] = "Torrent of Fatigue",
            [22] = "Aura of Pain",
            [23] = "Aura of Hate",
            [24] = "Theft of Pain",
            [25] = "Theft of Hate",
            [26] = "Theft of Agony",
        },
        ['Bitetap'] = {
            [1] = "Zevfeer's Bite",
            [2] = "Inruku's Bite",
            [3] = "Ancient: Bite of Muram",
            [4] = "Blacktalon Bite",
            [5] = "Blackwater Bite",
            [6] = "Laarthik's Bite",
            [7] = "Malthiasiss's Bite",
            [8] = "Korum's Bite",
            [9] = "Ralstok's Bite",
            [10] = "Bonemaw's Bite",
            [11] = "Xalgoz's Bite",
            [12] = "Vulak's Bite",
            [13] = "Cruor's Bite",
        },
        ['ForPower'] = {
            [1] = "Challenge for Power",
            [2] = "Trial for Power",
            [3] = "Charge for Power",
            [4] = "Confrontation for Power",
            [5] = "Provocation for Power",
            [6] = "Demand for Power",
            [7] = "Impose for Power",
            [8] = "Refute for Power",    -- TBL - 107
            [9] = "Protest for Power",   -- TOV - 112
            [10] = "Parlay for Power",   -- TOL - 117
            [11] = "Petition for Power", -- LS - 122
        },
        ['Terror'] = {
            [1] = "Terror of Darkness",
            [2] = "Terror of Shadows",
            [3] = "Terror of Death",
            [4] = "Terror of Terris",
            [5] = "Terror of Thule",
            [6] = "Terror of Discord",
            [7] = "Terror of Vergalid",
            [8] = "Terror of the Soulbleeder",
            [9] = "Terror of Jelvalak",
            [10] = "Terror of Rerekalen",
            [11] = "Terror of Desalin",
            [12] = "Terror of Poira",
            [13] = "Terror of Narus",
            [14] = "Terror of Kra`Du",
            [15] = "Terror of Mirenilla",
            [16] = "Terror of Ander",
            [17] = "Terror of Tarantis",
        },
        ['TempHP'] = {
            [1] = "Stormwall Stance",
            [2] = "Defiant Stance",
            [3] = "Staunch Stance",
            [4] = "Steadfast Stance",
            [5] = "Stoic Stance",
            [6] = "Stubborn Stance",
            [7] = "Steely Stance",
            [8] = "Adamant Stance",
            [9] = "Unwavering Stance",
        },
        ['Dicho'] = {
            [1] = "Dichotomic Fang",
            [2] = "Dissident Fang",
            [3] = "Composite Fang",
            [4] = "Ecliptic Fang",
        },
        ['Torrent'] = {
            [1] = "Torrent of Hate",
            [2] = "Torrent of Pain",
            [3] = "Torrent of Agony",
            [4] = "Torrent of Misery",
            [5] = "Torrent of Suffering",
            [6] = "Torrent of Anguish",
            [7] = "Torrent of Melancholy",
            [8] = "Torrent of Desolation"
        },
        ['SnareDOT'] = {
            [1] = "Clinging Darkness",
            [2] = "Engulfing Darkness",
            [3] = "Dooming Darkness",
            [4] = "Cascading Darkness",
            [5] = "Festering Darkness",
            [6] = "Despairing Darkness",
            [7] = "Suppurating Darkness",
            [8] = "Smoldering Darkness",
            [9] = "Spreading Darkness",
            [10] = "Putrefying Darkness",
            [11] = "Pestilent Darkness",
            [12] = "Virulent Darkness",
            [13] = "Vitriolic Darkness",
        },
        ['Acrimony'] = {
            [1] = "Undivided Acrimony",
            [2] = "Unbroken Acrimony",
            [3] = "Unflinching Acrimony",
            [4] = "Unyielding Acrimony",
            [5] = "Unending Acrimony",
            [6] = "Unrelenting Acrimony",
            [7] = "Unconditional Acrimony",
        },
        ['SpiteStrike'] = {
            [1] = "Spite of Ronak",
            [2] = "Spite of Kra`Du",
            [3] = "Spite of Mirenilla",
        },
        ['ReflexStrike'] = {
            [1] = "Reflexive Resentment",
            [2] = "Reflexive Rancor",
            [3] = "Reflexive Revulsion",
        },
        ['DireDot'] = {
            [1] = "Dire Constriction",
            [2] = "Dire Restriction",
            [3] = "Dire Stenosis",
            [4] = "Dire Stricture",
            [5] = "Dire Strangulation",
            [6] = "Dire Coarctation",
            [7] = "Dire Convulsion",
            [8] = "Dire Seizure",
            [9] = "Dire Squelch",
        },
        ['AllianceNuke'] = {
            [1] = "Bloodletting Coalition",
            [2] = "Bloodletting Alliance",
            [3] = "Bloodletting Covenant",
            [4] = "Bloodletting Conjunction",
        },
        ['InfluenceDisc'] = {
            [1] = "Insolent Influence",
            [2] = "Impudent Influence",
            [3] = "Impenitent Influence",
            [4] = "Impertinent Influence",
            [5] = "Ignominious Influence",
        },
    },
    ['DefaultRotations'] = {
        ['Downtime'] = {
            [1] = {
                name = "Dark Lord's Unity (Azia)",
                type = "AA",
                tooltip = Tooltips.DLUA,
                cond = function(
                    self)
                    return self:castDLU() and
                        not mq.TLO.Me.FindBuff("name " ..
                            tostring(mq.TLO.Me.AltAbility("Dark Lord's Unity (Azia)").Spell.Trigger(1).BaseName()))()
                end
            },
            [2] = {
                name = "Skin",
                type = "Spell",
                tooltip = Tooltips.Skin,
                cond = function(
                    self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [3] = {
                name = "Horror",
                type = "Spell",
                tooltip = Tooltips.Horror,
                cond = function(
                    self, spell)
                    return not self:castDLU() and RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [4] = {
                name = "Demeanor",
                type = "Spell",
                tooltip = Tooltips.Demeanor,
                cond = function(
                    self, spell)
                    return not self:castDLU() and RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [5] = {
                name = "CloakHP",
                type = "Spell",
                tooltip = Tooltips.CloakHP,
                cond = function(
                    self, spell)
                    return not self:castDLU() and RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [6] = {
                name = "SelfDS",
                type = "Spell",
                tooltip = Tooltips.SelfDS,
                cond = function(
                    self, spell)
                    return not self:castDLU() and mq.TLO.FindItemCount(spell.NoExpendReagentID(1))() > 0 and
                        RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [7] = {
                name = "Shroud",
                type = "Spell",
                tooltip = Tooltips.Shroud,
                cond = function(
                    self, spell)
                    return not self:castDLU() and RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [8] = {
                name = "Covenant",
                type = "Spell",
                tooltip = Tooltips.Covenant,
                cond = function(
                    self, spell)
                    return not self:castDLU() and RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [9] = {
                name = "CallAtk",
                type = "Spell",
                tooltip = Tooltips.CallAtk,
                cond = function(
                    self, spell)
                    return not self:castDLU() and RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [10] = {
                name = "TempHP",
                type = "Spell",
                tooltip = Tooltips.TempHP,
                cond = function(
                    self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [11] = {
                name = "HealBurn",
                type = "Spell",
                tooltip = Tooltips.HealBurn,
                cond = function(
                    self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end
            },
            [12] = {
                name = "Voice of Thule",
                type = "AA",
                tooltip = Tooltips.VOT,
                cond = function(
                    self)
                    return RGMercUtils.SelfBuffAACheck("Voice of Thule")
                end
            },
            [13] = {
                name = "PetSpell",
                type = "Spell",
                tooltip = Tooltips.PetSpell,
                active_cond = function(self, spell) return mq.TLO.Me.Pet.ID() ~= nil end,
                cond = function(
                    self, spell)
                    return not mq.TLO.Me.Pet.ID() and self.settings.DoPet and
                        mq.TLO.FindItemCount(spell.ReagentID(1))() > 0
                end
            },
            [14] = {
                name = "PetHaste",
                type = "Spell",
                tooltip = Tooltips.PetHaste,
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName) ~= nil end,
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell)
                end
            },
        },
    },
    ['Rotations'] = {
        ['Tank'] = {
            ['Rotation'] = {
                ['Downtime'] = {},
                ['Burn'] = {
                    [1] = {
                        name = "Acrimony",
                        type = "DISC",
                        tooltip = Tooltips.Acrimony,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [2] = {
                        name = "SpiteStrike",
                        type = "DISC",
                        tooltip = Tooltips.SpikeStrike,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [3] = {
                        name = "ReflexStrike",
                        type = "DISC",
                        tooltip = Tooltips.ReflexStrike,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [4] = {
                        name = "Harm Touch",
                        type = "AA",
                        tooltip = Tooltips.HarmTouch,
                        cond = function(
                            self)
                            return (self.settings.BurnAuto and mq.TLO.Target.Named() == true) or
                                RGMercUtils.BigBurn(self.settings)
                        end
                    },
                    [5] = { name = "Thought Leech", type = "AA", tooltip = Tooltips.ThoughtLeech, },
                    [6] = { name = "Visage of Death", type = "AA", tooltip = Tooltips.VisageOfDeath, },
                    [7] = { name = "Leech Touch", type = "AA", tooltip = Tooltips.LeechTouch, },
                    [8] = { name = "T`Vyl's Resolve", type = "AA", tooltip = Tooltips.Tyvls, },
                },
                ['Debuff'] = {},
                ['Heal'] = {},
                ['DPS'] = {
                    [1] = {
                        name = "ActivateShield",
                        type = "cmd",
                        tooltip = Tooltips.ActivateShield,
                        cond = function(
                            self)
                            return self.settings.DoBandolier and not mq.TLO.Me.Bandolier("Shield").Active() and
                                mq.TLO.Me.Bandolier("Shield").Index() and self.settings.DoBurn
                        end,
                        cmd = "/bandolier activate Shield"
                    },
                    [2] = {
                        name = "Activate2HS",
                        type = "cmd",
                        tooltip = Tooltips.Activate2HS,
                        cond = function(
                            self)
                            return self.settings.DoBandolier and not mq.TLO.Me.Bandolier("2HS").Active() and
                                mq.TLO.Me.Bandolier("2HS").Index() and not self.settings.DoBurn
                        end,
                        cmd = "/bandolier activate 2HS"
                    },
                    [3] = {
                        name = "EndRegen",
                        type = "DISC",
                        tooltip = Tooltips.EndRegen,
                        cond = function(
                            self)
                            return mq.TLO.Me.PctEndurance() < 15
                        end
                    },
                    [4] = {
                        name = "Explosion of Hatred",
                        type = "AA",
                        tooltip = Tooltips.ExplosionOfHatred,
                        cond = function(
                            self)
                            return mq.TLO.SpawnCount("NPC radius 50 zradius 50")() >= self.settings.AeTauntCnt and
                                mq.TLO.XAssist.XTFullHaterCount() >= self.settings.AeTauntCnt
                        end
                    },
                    [5] = {
                        name = "Explosion of Spite",
                        type = "AA",
                        tooltip = Tooltips.ExplosionOfSpite,
                        cond = function(
                            self)
                            return mq.TLO.SpawnCount("NPC radius 50 zradius 50")() >= self.settings.AeTauntCnt and
                                mq.TLO.XAssist.XTFullHaterCount() >= self.settings.AeTauntCnt
                        end
                    },
                    [6] = {
                        name = "Taunt",
                        type = "Ability",
                        tooltip = Tooltips.Taunt,
                        cond = function(
                            self)
                            return mq.TLO.Me.AbilityReady("Taunt")() and
                                mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and mq.TLO.Target() and
                                RGMercUtils.GetTargetDistance() < 30
                        end
                    },
                    [7] = {
                        name = "Terror",
                        type = "Spell",
                        tooltip = Tooltips.Terror,
                        cond = function(
                            self)
                            return mq.TLO.Me.SecondaryPctAggro() > 60
                        end
                    },
                    [8] = { name = "MeleeMit", type = "DISC", tooltip = Tooltips.MeleeMit, },
                    [9] = {
                        name = "ForPower",
                        type = "Spell",
                        tooltip = Tooltips.ForPower,
                        cond = function(
                            self, spell)
                            return RGMercUtils.DotSpellCheck(self.settings, spell)
                        end
                    },
                    [10] = {
                        name = "Encroaching Darknesss",
                        tooltip = Tooltips.EncroachingDarkness,
                        type = "AA",
                        cond = function(
                            self)
                            return self.settings.DoSnare and RGMercUtils.DetAACheck(826)
                        end
                    },
                    [11] = {
                        name = "SnareDOT",
                        type = "Spell",
                        tooltip = Tooltips.SnareDOT,
                        cond = function(
                            self, spell)
                            return self.settings.DoSnare and RGMercUtils.DetSpellCheck(self.settings, spell)
                        end
                    },
                    [12] = {
                        name = "Epic",
                        type = "Item",
                        tooltip = Tooltips.Epic,
                        cond = function(
                            self)
                            return mq.TLO.Me.ActiveDisc.Name() ~= "Leechcurse Discipline"
                        end
                    },
                    [13] = {
                        name = "LeechCurse",
                        type = "DISC",
                        tooltip = Tooltips.LeechCurse,
                        cond = function(
                            self)
                            return mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline"
                        end
                    },
                    [14] = {
                        name = "Deflection",
                        type = "DISC",
                        tooltip = Tooltips.Deflection,
                        cond = function(
                            self)
                            return mq.TLO.Me.ActiveDisc.Name() ~= "Leechcurse Discipline"
                        end
                    },
                    [15] = {
                        name = "Mantle",
                        type = "DISC",
                        tooltip = Tooltips.Mantle,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [16] = {
                        name = "Carapace",
                        type = "DISC",
                        tooltip = Tooltips.Carapace,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [17] = {
                        name = "CurseGuard",
                        type = "DISC",
                        tooltip = Tooltips.CurseGuard,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [18] = {
                        name = "UnholyAura",
                        type = "DISC",
                        tooltip = Tooltips.UnholyAura,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [19] = {
                        name = "PoisonDot",
                        type = "Spell",
                        tooltip = Tooltips.PoisonDot,
                        cond = function(
                            self, spell)
                            return RGMercUtils.DotSpellCheck(self.settings, spell)
                        end
                    },
                    [20] = {
                        name = "DireDot",
                        type = "Spell",
                        tooltip = Tooltips.DireDot,
                        cond = function(
                            self, spell)
                            return RGMercUtils.DotSpellCheck(self.settings, spell)
                        end
                    },
                    [21] = {
                        name = "Torrent",
                        type = "Spell",
                        tooltip = Tooltips.Torrent,
                        cond = function(
                            self, spell)
                            return self.settings.DoTorrent and
                                not mq.TLO.Me.FindBuff("id " .. tostring(spell.ID())).ID()
                        end
                    },
                    [22] = {
                        name = "SpearNuke",
                        type = "Spell",
                        tooltip = Tooltips.SpearNuke,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctMana() > self.settings.ManaToNuke
                        end
                    },
                    [23] = {
                        name = "BondTap",
                        type = "Spell",
                        tooltip = Tooltips.BondTap,
                        cond = function(
                            self, spell)
                            return not self.settings.DoTorrent and
                                not mq.TLO.Me.FindBuff("name " .. spell.Name() .. " Recourse").ID()
                        end
                    },
                    -- TODO: Verify this logic, it seems wrong
                    [24] = {
                        name = "Vicious Bite of Chaos",
                        type = "AA",
                        tooltip = Tooltips.ViciousBiteOfChaos,
                        cond = function(
                            self)
                            return mq.TLO.Target() and RGMercUtils.GetTragetPctHPs() > 5 and
                                RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [25] = {
                        name = "Blade",
                        type = "Disc",
                        tooltip = Tooltips.Blade,
                        cond = function(
                            self)
                            return mq.TLO.Target() and RGMercUtils.GetTragetPctHPs() > 5 and
                                RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [26] = {
                        name = "Crimson",
                        type = "Disc",
                        tooltip = Tooltips.Crimson,
                        cond = function(
                            self)
                            return mq.TLO.Target() and RGMercUtils.GetTragetPctHPs() > 5 and
                                RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [27] = {
                        name = "Dicho",
                        type = "Spell",
                        tooltip = Tooltips.Dicho,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartBigTap
                        end
                    },
                    [28] = {
                        name = "DireTap",
                        type = "Spell",
                        tooltip = Tooltips.DireTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartBigTap
                        end
                    },
                    [29] = {
                        name = "BuffTap",
                        type = "Spell",
                        tooltip = Tooltips.BuffTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap and
                                RGMercUtils.DetSpellCheck(self.settings, spell)
                        end
                    },
                    [30] = {
                        name = "BiteTap",
                        type = "Spell",
                        tooltip = Tooltips.BiteTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap
                        end
                    },
                    [31] = {
                        name = "LifeTap",
                        type = "Spell",
                        tooltip = Tooltips.LifeTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap
                        end
                    },
                },
            },
            ['Spells'] = {
                [1] = { name = "DireDot", gem = 1 },
                [2] = { name = "Spearnuke", gem = 2 },
                [3] = { name = "Torrent", gem = 3, cond = function(self) return self.settings.DoTorrent end, other = "BondTap" },
                [4] = { name = "Diretap", gem = 4, cond = function(self) return self.settings.DoDiretap end, other = "SnareDOT" },
                [5] = { name = "Lifetap", gem = 5 },
                [6] = { name = "Bufftap", gem = 6 },
                [7] = { name = "Bitetap", gem = 7 },
                [8] = { name = "ForPower", gem = 8 },
                [9] = { name = "Terror", gem = 9 },
                [10] = { name = "TempHP", gem = 10 },
                [11] = { name = "Skin", gem = 11 },
                [12] = { name = "Dicho", gem = 12 },
            },
        },
        ['DPS'] = {
            ['Rotation'] = {
                ['Downtime'] = {},
                ['Debuff'] = {},
                ['Heal'] = {},
                ['DPS'] = {
                    [1] = {
                        name = "Torrent",
                        type = "Spell",
                        tooltip = Tooltips.Torrent,
                        cond = function(
                            self, spell)
                            return self.settings.DoTorrent and not TargetHasBuff(spell)
                        end
                    },
                    [2] = {
                        name = "SpearNuke",
                        type = "Spell",
                        tooltip = Tooltips.SpearNuke,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctMana() > self.settings.ManaToNuke or
                                RGMercConfig.BurnCheck(self.settings)
                        end
                    },
                    [3] = {
                        name = "BondTap",
                        type = "Spell",
                        tooltip = Tooltips.BondTap,
                        cond = function(
                            self, spell)
                            return not mq.TLO.Me.FindBuff("name " .. spell.Name() .. " Recourse").ID()
                        end
                    },
                    [4] = {
                        name = "Vicious Bite of Chaos",
                        type = "AA",
                        tooltip = Tooltips.ViciousBiteOfChaos,
                        cond = function(
                            self)
                            return RGMercUtils.GetTragetPctHPs() > 5 and RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [5] = {
                        name = "Blade",
                        type = "DISC",
                        tooltip = Tooltips.Blade,
                        cond = function(
                            self)
                            return RGMercUtils.GetTragetPctHPs() > 5 and RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [6] = {
                        name = "Crimson",
                        type = "DISC",
                        tooltip = Tooltips.Crimson,
                        cond = function(
                            self)
                            return RGMercUtils.GetTragetPctHPs() > 5 and RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [7] = {
                        name = "PoisonDot",
                        type = "Spell",
                        tooltip = Tooltips.PoisonDot,
                        cond = function(
                            self, spell)
                            return self.settings.DoDot and not TargetHasBuff(spell)
                        end
                    },
                    [8] = {
                        name = "DireTap",
                        type = "Spell",
                        tooltip = Tooltips.DireTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap
                        end
                    },
                    [9] = {
                        name = "BuffTap",
                        type = "Spell",
                        tooltip = Tooltips.BuffTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap and
                                RGMercUtils.DetSpellCheck(self.settings, spell)
                        end
                    },
                    [10] = {
                        name = "BiteTap",
                        type = "Spell",
                        tooltip = Tooltips.BiteTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap
                        end
                    },
                    [11] = {
                        name = "Dicho",
                        type = "Spell",
                        tooltip = Tooltips.Dicho,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartBigTap
                        end
                    },
                    [12] = {
                        name = "LifeTap",
                        type = "Spell",
                        tooltip = Tooltips.LifeTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap
                        end
                    },
                },
                ['Burn'] = {
                    [1] = {
                        name = "ReflexStrike",
                        type = "DISC",
                        tooltip = Tooltips.ReflexStrike,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [2] = {
                        name = "Harm Touch",
                        type = "AA",
                        tooltip = Tooltips.HarmTouch,
                        cond = function(
                            self)
                            return (self.settings.BurnAuto and mq.TLO.Target.Named() == true) or
                                RGMercUtils.BigBurn(self.settings)
                        end
                    },
                    [3] = { name = "Thought Leech", type = "AA", tooltip = Tooltips.ThoughtLeech, },
                    [4] = { name = "Visage of Death", type = "AA", tooltip = Tooltips.VisageOfDeath, },
                    [5] = { name = "Leech Touch", type = "AA", tooltip = Tooltips.LeechTouch, },
                    [6] = { name = "T`Vyl's Resolve", type = "AA", tooltip = Tooltips.Tyvls, },
                },
            },
            ['Spells'] = {
                [1] = { name = "PoisonDot", gem = 1 },
                [2] = { name = "Spearnuke", gem = 2 },
                [3] = { name = "Torrent", gem = 3, cond = function(self) return self.settings.DoTorrent end, other = "BondTap" },
                [4] = { name = "Diretap", gem = 4 },
                [5] = { name = "Lifetap", gem = 5 },
                [6] = { name = "Bufftap", gem = 6 },
                [7] = { name = "Bitetap", gem = 7 },
                [8] = { name = "ForPower", gem = 8 },
                [9] = { name = "Terror", gem = 9 },
                [10] = { name = "TempHP", gem = 10 },
                [11] = { name = "Skin", gem = 11 },
                [12] = { name = "Dicho", gem = 12 },
            },
        },
        ['TLP_Tank'] = {
            ['Rotation'] = {
                ['Debuff'] = {},
                ['Heal'] = {},
                ['DPS'] = {
                    [1] = {
                        name = "ActivateShield",
                        type = "cmd",
                        tooltip = Tooltips.ActivateShield,
                        cond = function(
                            self)
                            return self.settings.DoBandolier and not mq.TLO.Me.Bandolier("Shield").Active() and
                                mq.TLO.Me.Bandolier("Shield").Index() and self.settings.DoBurn
                        end,
                        cmd = "/bandolier activate Shield"
                    },
                    [2] = {
                        name = "Activate2HS",
                        type = "cmd",
                        tooltip = Tooltips.Activate2HS,
                        cond = function(
                            self)
                            return self.settings.DoBandolier and not mq.TLO.Me.Bandolier("2HS").Active() and
                                mq.TLO.Me.Bandolier("2HS").Index() and
                                mq.TLO.XAssist.XTFullHaterCount() < self.settings.BurnMobCount and
                                not mq.TLO.Target.Named()
                        end,
                        cmd = "/bandolier activate 2HS"
                    },
                    [3] = {
                        name = "EndRegen",
                        type = "DISC",
                        tooltip = Tooltips.EndRegen,
                        cond = function(
                            self)
                            return mq.TLO.Me.PctEndurance() < 15
                        end
                    },
                    [4] = {
                        name = "Epic",
                        type = "Item",
                        tooltip = Tooltips.Epic,
                        cond = function(
                            self)
                            return self.settings.BurnAuto or
                                RGMercUtils.SmallBurn(self.settings) and mq.TLO.Me.PctHPs() < self.settings.FlashHP
                        end
                    },
                    [5] = {
                        name = "Taunt",
                        type = "Ability",
                        tooltip = Tooltips.Taunt,
                        cond = function(
                            self)
                            return mq.TLO.Me.AbilityReady("Taunt")() and
                                mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and RGMercUtils.GetTargetDistance() < 30
                        end
                    },
                    [6] = {
                        name = "Terror",
                        type = "Spell",
                        tooltip = Tooltips.Terror,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and
                                RGMercUtils.GetTargetDistance() < 30
                        end
                    },
                    [7] = {
                        name = "AeTaunt",
                        type = "Spell",
                        tooltip = Tooltips.AETaunt,
                        cond = function(
                            self, spell)
                            return self.settings.DoAE and
                                mq.TLO.SpawnCount("NPC radius 60 zradius 50")() >= self.settings.AeTauntCnt and
                                mq.TLO.XAssist.XTFullHaterCount() >= self.settings.AeTauntCnt
                        end
                    },
                    [8] = {
                        name = "SnareDOT",
                        type = "Spell",
                        tooltip = Tooltips.SnareDOT,
                        cond = function(
                            self, spell)
                            return self.settings.DoSnare and RGMercUtils.DetSpellCheck(self.settings, spell)
                        end
                    },
                    [9] = {
                        name = "LeechCurse",
                        type = "DISC",
                        tooltip = Tooltips.LeechCurse,
                        cond = function(
                            self)
                            return mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline"
                        end
                    },
                    [10] = {
                        name = "Deflection",
                        type = "DISC",
                        tooltip = Tooltips.Deflection,
                        cond = function(
                            self)
                            return mq.TLO.Me.ActiveDisc.Name() ~= "Leechcurse Discipline"
                        end
                    },
                    [11] = {
                        name = "Mantle",
                        type = "DISC",
                        tooltip = Tooltips.Mantle,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [12] = {
                        name = "Carapace",
                        type = "DISC",
                        tooltip = Tooltips.Carapace,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [13] = {
                        name = "CurseGuard",
                        type = "DISC",
                        tooltip = Tooltips.CurseGuard,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [14] = {
                        name = "UnholyAura",
                        type = "DISC",
                        tooltip = Tooltips.UnholyAura,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [15] = {
                        name = "PoisonDot",
                        type = "Spell",
                        tooltip = Tooltips.PoisonDot,
                        cond = function(
                            self, spell)
                            return (self.settings.BurnAuto or RGMercUtils.SmallBurn(self.settings)) and
                                RGMercUtils.DotSpellCheck(self.settings, spell) and RGMercUtils.ManaCheck(self.settings)
                        end
                    },
                    [16] = {
                        name = "Torrent",
                        type = "Spell",
                        tooltip = Tooltips.Torrent,
                        cond = function(
                            self, spell)
                            return self.settings.DoTorrent and
                                not mq.TLO.Me.FindBuff("id " .. tostring(spell.ID())).ID()
                        end
                    },
                    [17] = {
                        name = "SpearNuke",
                        type = "Spell",
                        tooltip = Tooltips.SpearNuke,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctMana() > self.settings.ManaToNuke
                        end
                    },
                    [18] = {
                        name = "BondTap",
                        type = "Spell",
                        tooltip = Tooltips.BondTap,
                        cond = function(
                            self, spell)
                            return not self.settings.DoTorrent and
                                not mq.TLO.Me.FindBuff("name " .. spell.Name() .. " Recourse").ID()
                        end
                    },
                    -- TODO: Verify this logic, it seems wrong
                    [19] = {
                        name = "Vicious Bite of Chaos",
                        type = "AA",
                        tooltip = Tooltips.ViciousBiteOfChaos,
                        cond = function(
                            self)
                            return mq.TLO.Target() and RGMercUtils.GetTragetPctHPs() > 5 and
                                RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [20] = {
                        name = "Blade",
                        type = "Disc",
                        tooltip = Tooltips.Blade,
                        cond = function(
                            self)
                            return mq.TLO.Target() and RGMercUtils.GetTragetPctHPs() > 5 and
                                RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [21] = {
                        name = "Crimson",
                        type = "Disc",
                        tooltip = Tooltips.Crimson,
                        cond = function(
                            self)
                            return mq.TLO.Target() and RGMercUtils.GetTragetPctHPs() > 5 and
                                RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [22] = {
                        name = "Dicho",
                        type = "Spell",
                        tooltip = Tooltips.Dicho,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartBigTap
                        end
                    },
                    [23] = {
                        name = "DireTap",
                        type = "Spell",
                        tooltip = Tooltips.DireTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartBigTap
                        end
                    },
                    [24] = {
                        name = "BuffTap",
                        type = "Spell",
                        tooltip = Tooltips.BuffTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap and
                                RGMercUtils.DetSpellCheck(self.settings, spell)
                        end
                    },
                    [25] = {
                        name = "BiteTap",
                        type = "Spell",
                        tooltip = Tooltips.BiteTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap
                        end
                    },
                    [26] = {
                        name = "LifeTap",
                        type = "Spell",
                        tooltip = Tooltips.LifeTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap
                        end
                    },
                },
                ['Burn'] = {
                    [1] = {
                        name = "Acrimony",
                        type = "DISC",
                        tooltip = Tooltips.Acrimony,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [2] = {
                        name = "SpiteStrike",
                        type = "DISC",
                        tooltip = Tooltips.SpikeStrike,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [3] = {
                        name = "ReflexStrike",
                        type = "DISC",
                        tooltip = Tooltips.ReflexStrike,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [4] = {
                        name = "Harm Touch",
                        type = "AA",
                        tooltip = Tooltips.HarmTouch,
                        cond = function(
                            self)
                            return (self.settings.BurnAuto and mq.TLO.Target.Named() == true) or
                                RGMercUtils.BigBurn(self.settings)
                        end
                    },
                    [5] = { name = "Thought Leech", type = "AA", tooltip = Tooltips.ThoughtLeech, },
                    [6] = { name = "Visage of Death", type = "AA", tooltip = Tooltips.VisageOfDeath, },
                    [7] = { name = "Leech Touch", type = "AA", tooltip = Tooltips.LeechTouch, },
                    [8] = { name = "T`Vyl's Resolve", type = "AA", tooltip = Tooltips.Tyvls, },
                },
                ['Downtime'] = {},
            },
            ['Spells'] = {
                [1] = { name = "Terror", gem = 1 },
                [2] = { name = "Spearnuke", gem = 2 },
                [3] = { name = "Lifetap", gem = 3 },
                [4] = { name = "Bitetap", gem = 4 },
                [5] = { name = "Bufftap", gem = 5 },
                [6] = { name = "PoisonDot", gem = 6 },
                [7] = { name = "SnareDOT", gem = 7 },
                [8] = { name = "AeTaunt", gem = 8, cond = function(self) return mq.TLO.Me.NumGems() > 8 end },
                --[9] = { name="Terror", gem=9 },
                --[10] = { name="TempHP", gem=10 },
                --[11] = { name="Skin", gem=11 },
                --[12] = { name="Dicho", gem=12 },
            },
        },
        ['TLP_DPS'] = {
            ['Rotation'] = {
                ['Debuff'] = {},
                ['Heal'] = {},
                ['DPS'] = {
                    [1] = {
                        name = "ActivateShield",
                        type = "cmd",
                        tooltip = Tooltips.ActivateShield,
                        cond = function(
                            self)
                            return self.settings.DoBandolier and not mq.TLO.Me.Bandolier("Shield").Active() and
                                mq.TLO.Me.Bandolier("Shield").Index() and self.settings.DoBurn
                        end,
                        cmd = "/bandolier activate Shield"
                    },
                    [2] = {
                        name = "Activate2HS",
                        type = "cmd",
                        tooltip = Tooltips.Activate2HS,
                        cond = function(
                            self)
                            return self.settings.DoBandolier and not mq.TLO.Me.Bandolier("2HS").Active() and
                                mq.TLO.Me.Bandolier("2HS").Index() and
                                mq.TLO.XAssist.XTFullHaterCount() < self.settings.BurnMobCount and
                                not mq.TLO.Target.Named()
                        end,
                        cmd = "/bandolier activate 2HS"
                    },
                    [3] = {
                        name = "EndRegen",
                        type = "DISC",
                        tooltip = Tooltips.EndRgen,
                        cond = function(
                            self)
                            return mq.TLO.Me.PctEndurance() < 15
                        end
                    },
                    [4] = {
                        name = "Epic",
                        type = "Item",
                        tooltip = Tooltips.Epic,
                        cond = function(
                            self)
                            return self.settings.BurnAuto or
                                RGMercUtils.SmallBurn(self.settings) and mq.TLO.Me.PctHPs() < self.settings.FlashHP
                        end
                    },
                    [5] = {
                        name = "SnareDOT",
                        type = "Spell",
                        tooltip = Tooltips.SnareDOT,
                        cond = function(
                            self, spell)
                            return self.settings.DoSnare and RGMercUtils.DetSpellCheck(self.settings, spell)
                        end
                    },
                    [6] = {
                        name = "LeechCurse",
                        type = "DISC",
                        tooltip = Tooltips.LeechCurse,
                        cond = function(
                            self)
                            return mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline"
                        end
                    },
                    [7] = {
                        name = "Deflection",
                        type = "DISC",
                        tooltip = Tooltips.Deflection,
                        cond = function(
                            self)
                            return mq.TLO.Me.ActiveDisc.Name() ~= "Leechcurse Discipline"
                        end
                    },
                    [8] = {
                        name = "Mantle",
                        type = "DISC",
                        tooltip = Tooltips.Mantle,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [9] = {
                        name = "Carapace",
                        type = "DISC",
                        tooltip = Tooltips.Carapace,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [10] = {
                        name = "CurseGuard",
                        type = "DISC",
                        tooltip = Tooltips.CurseGuard,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [11] = {
                        name = "UnholyAura",
                        type = "DISC",
                        tooltip = Tooltips.UnholyAura,
                        cond = function(
                            self)
                            return (mq.TLO.Target.Named() or mq.TLO.SpawnCount("NPC radius 60 zradius 50")() > 2) and
                                not mq.TLO.Me.ActiveDisc.ID()
                        end
                    },
                    [12] = {
                        name = "PoisonDot",
                        type = "Spell",
                        tooltip = Tooltips.PoisonDot,
                        cond = function(
                            self, spell)
                            return (self.settings.BurnAuto or RGMercUtils.SmallBurn(self.settings)) and
                                RGMercUtils.DotSpellCheck(self.settings, spell) and RGMercUtils.ManaCheck(self.settings)
                        end
                    },
                    [13] = {
                        name = "Torrent",
                        type = "Spell",
                        tooltip = Tooltips.Torrent,
                        cond = function(
                            self, spell)
                            return self.settings.DoTorrent and
                                not mq.TLO.Me.FindBuff("id " .. tostring(spell.ID())).ID()
                        end
                    },
                    [14] = {
                        name = "SpearNuke",
                        type = "Spell",
                        tooltip = Tooltips.SpearNuke,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctMana() > self.settings.ManaToNuke
                        end
                    },
                    [15] = {
                        name = "BondTap",
                        type = "Spell",
                        tooltip = Tooltips.BondTap,
                        cond = function(
                            self, spell)
                            return not self.settings.DoTorrent and
                                not mq.TLO.Me.FindBuff("name " .. spell.Name() .. " Recourse").ID()
                        end
                    },
                    -- TODO: Verify this logic, it seems wrong
                    [16] = {
                        name = "Vicious Bite of Chaos",
                        type = "AA",
                        tooltip = Tooltips.ViciousBiteOfChaos,
                        cond = function(
                            self)
                            return mq.TLO.Target() and RGMercUtils.GetTragetPctHPs() > 5 and
                                RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [17] = {
                        name = "Blade",
                        type = "Disc",
                        tooltip = Tooltips.Blade,
                        cond = function(
                            self)
                            return mq.TLO.Target() and RGMercUtils.GetTragetPctHPs() > 5 and
                                RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [18] = {
                        name = "Crimson",
                        type = "Disc",
                        tooltip = Tooltips.Crimson,
                        cond = function(
                            self)
                            return mq.TLO.Target() and RGMercUtils.GetTragetPctHPs() > 5 and
                                RGMercUtils.GetTargetDistance() < 35
                        end
                    },
                    [19] = {
                        name = "Dicho",
                        type = "Spell",
                        tooltip = Tooltips.Dicho,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartBigTap
                        end
                    },
                    [20] = {
                        name = "DireTap",
                        type = "Spell",
                        tooltip = Tooltips.DireTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartBigTap
                        end
                    },
                    [21] = {
                        name = "BuffTap",
                        type = "Spell",
                        tooltip = Tooltips.BuffTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap and
                                RGMercUtils.DetSpellCheck(self.settings, spell)
                        end
                    },
                    [22] = {
                        name = "BiteTap",
                        type = "Spell",
                        tooltip = Tooltips.BiteTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap
                        end
                    },
                    [23] = {
                        name = "LifeTap",
                        type = "Spell",
                        tooltip = Tooltips.LifeTap,
                        cond = function(
                            self, spell)
                            return mq.TLO.Me.PctHPs() <= self.settings.StartLifeTap
                        end
                    },
                },
                ['Burn'] = {
                    [1] = {
                        name = "Acrimony",
                        type = "DISC",
                        tooltip = Tooltips.Acrimony,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [2] = {
                        name = "SpiteStrike",
                        type = "DISC",
                        tooltip = Tooltips.SpikeStrike,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [3] = {
                        name = "ReflexStrike",
                        type = "DISC",
                        tooltip = Tooltips.ReflexStrike,
                        cond = function(
                            self)
                            return mq.TLO.Target.Named() == true
                        end
                    },
                    [4] = {
                        name = "Harm Touch",
                        type = "AA",
                        tooltip = Tooltips.HarmTouch,
                        cond = function(
                            self)
                            return (self.settings.BurnAuto and mq.TLO.Target.Named() == true) or
                                RGMercUtils.BigBurn(self.settings)
                        end
                    },
                    [5] = { name = "Thought Leech", type = "AA", tooltip = Tooltips.ThoughtLeech, },
                    [6] = { name = "Visage of Death", type = "AA", tooltip = Tooltips.VisageOfDeath, },
                    [7] = { name = "Leech Touch", type = "AA", tooltip = Tooltips.LeechTouch, },
                    [8] = { name = "T`Vyl's Resolve", type = "AA", tooltip = Tooltips.Tyvls, },
                },
                ['Downtime'] = {},
            },
            ['Spells'] = {
                [1] = { name = "Terror", gem = 1 },
                [2] = { name = "Spearnuke", gem = 2 },
                [3] = { name = "Lifetap", gem = 3 },
                [4] = { name = "Bitetap", gem = 4 },
                [5] = { name = "Bufftap", gem = 5 },
                [6] = { name = "PoisonDot", gem = 6 },
                [7] = { name = "SnareDOT", gem = 7 },
                [8] = { name = "AeTaunt", gem = 8, cond = function(self) return mq.TLO.Me.NumGems() > 8 end },
                --[9] = { name="Terror", gem=9 },
                --[10] = { name="TempHP", gem=10 },
                --[11] = { name="Skin", gem=11 },
                --[12] = { name="Dicho", gem=12 },
            },
        },
    },
    ['DefaultConfig'] = {
        ['Mode'] = { DisplayName = "Mode", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 3 },
        ['DoTorrent'] = { DisplayName = "Cast Torrents", Tooltip = "Enable casting Torrent spells.", RequiresLoadoutChange = true, Default = true },
        ['DoDiretap'] = { DisplayName = "Cast Dire Taps", Tooltip = "Enable casting Dire Tap spells.", RequiresLoadoutChange = true, Default = true },
        ['DoBandolier'] = { DisplayName = "Use Bandolier", Tooltip = "Enable Swapping of items using the bandolier.", Default = false },
        ['DoBurn'] = { DisplayName = "Enable Burning", Tooltip = "Put character in 'burn' mode", Default = false },
        ['DoSnare'] = { DisplayName = "Cast Snares", Tooltip = "Enable casting Snare spells.", Default = true },
        ['DoDot'] = { DisplayName = "Cast DOTs", Tooltip = "Enable casting Damage Over Time spells.", Default = true },
        ['DoAE'] = { DisplayName = "Use AE Taunts", Tooltip = "Enable casting AE Taunt spells.", Default = true },
        ['AeTauntCnt'] = { DisplayName = "AE Taunt Count", Tooltip = "Minimum number of haters before using AE Taunt.", Default = 2, Min = 1, Max = 10 },
        ['HPStopDOT'] = { DisplayName = "HP Stop DOTs", Tooltip = "Stop casting DOTs when the mob hits [x] HP %.", Default = 30, Min = 1, Max = 100 },
        ['TLP'] = { DisplayName = "Enable TLP Mode", Tooltip = "Adjust for older mechanics on TLPs.", RequiresLoadoutChange = true, Default = false },
        ['ManaToNuke'] = { DisplayName = "Mana to Nuke", Tooltip = "Minimum % Mana in order to continue to cast nukes.", Default = 30, Min = 1, Max = 100 },
        ['FlashHP'] = { DisplayName = "Flash HP", Tooltip = "TODO: No Idea", Default = 35, Min = 1, Max = 100 },
        ['StartBigTap'] = { DisplayName = "Use Big Taps", Tooltip = "Your HP % before we use Big Taps.", Default = 80, Min = 1, Max = 100 },
        ['StartLifeTap'] = { DisplayName = "Use Life Taps", Tooltip = "Your HP % before we use Life Taps.", Default = 100, Min = 1, Max = 100 },
        ['BurnSize'] = { DisplayName = "Burn Size", Tooltip = "1=Small, 2=Medium, 3=Large", Default = 1, Min = 1, Max = 3 },
        ['BurnAuto'] = { DisplayName = "Auto Burn", Tooltip = "Automatically burn", Default = false },
        ['DoPet'] = { DisplayName = "Cast Pet", Tooltip = "Enable casting Pet spells.", Default = true },
        ['BurnMobCount'] = { DisplayName = "Burn Mob Count", Tooltip = "Number of haters before we start burning.", Default = 3, Min = 1, Max = 10 },
        ['BurnNamed'] = { DisplayName = "Burn Named", Tooltip = "Automatically burn named mobs.", Default = false },
    },
}

return _ClassConfig
