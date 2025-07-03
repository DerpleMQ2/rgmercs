-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

-- [ NOTE ON ORDERING ] --
-- Order matters! Lua will implicitly iterate everything in an array
-- in order by default so always put the first thing you want checked
-- towards the top of the list.

local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Comms        = require("utils.comms")

local _ClassConfig = {
    _version            = "Alpha 1.1 - Live (Modern Era DPS Only)",
    _author             = "Algar",
    ['Modes']           = {
        'ModernEra',
    },
    ['ModeChecks']      = {
        -- necro can AA Rez
        IsRezing = function() return Config:GetSetting('BattleRez') or Targeting.GetXTHaterCount() == 0 end,
    },
    ['Themes']          = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.5, g = 0.05, b = 1.0, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.4, g = 0.05, b = 0.8, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.TabActive,        color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.1, g = 0.05, b = 0.5, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.2, g = 0.05, b = 0.6, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.1, g = 0.05, b = 0.5, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.1, g = 0.05, b = 0.5, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.1, g = 0.05, b = 0.5, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.5, g = 0.05, b = 1.0, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.5, g = 0.05, b = 1.0, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
        },
    },
    ['CommandHandlers'] = {
        startlich = {
            usage = "/rgl startlich",
            about = "Start your Lich Spell [Note: This will enabled DoLich if it is not already].",
            handler =
                function(self)
                    Config:SetSetting('DoLich', true)
                    Core.SafeCallFunc("Start Necro Lich", self.ClassConfig.HelperFunctions.StartLich, self)

                    return true
                end,
        },
        stoplich = {
            usage = "/rgl stoplich",
            about = "Stop your Lich and Flesh Spell [Note: This will NOT disable DoLich].",
            handler =
                function(self)
                    Core.SafeCallFunc("Stop Lich Spell", self.ClassConfig.HelperFunctions.CancelLich, self)
                    Core.SafeCallFunc("Stop Flesh Buff", self.ClassConfig.HelperFunctions.CancelFlesh, self)
                    return true
                end,
        },
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Deathwhisper",
            "Soulwhisper",
        },
        ['OoW_Chest'] = {
            "Blightbringer's Tunic of the Grave",
            "Deathcaller's Robe",
        },
    },
    ['AbilitySets']     = {
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
            "Bulwark of the Crystalwing",
            "Shield of the Crystalwing",
            "Ether Shield",
            "Shield of Maelin",
            "Shield of the Arcane",
            "Shield of the Magi",
            "Arch Shielding",
            "Greater Shielding",
            "Major Shielding",
            "Shielding",
            "Lesser Shielding",
        },
        ['SelfRune1'] = {
            "Golemskin",
            "Carrion Skin",
            "Frozen Skin",
            "Ashen Skin",
            "Deadskin",
            "Zombieskin",
            "Ghoulskin",
            "Grimskin",
            "Corpseskin",
            "Shadowskin",
            "Wraithskin",
        },
        ['SelfSpellShield1'] = {
            "Shield of Inescapability",
            "Shield of Inevitability",
            "Shield of Destiny",
            "Shield of Order",
            "Shield of Consequence",
            "Shield of Fate",
        },
        ['FDSpell'] = {
            -- Fd Spell
            "Death Peace",
        },
        ---DPS
        ['AllianceSpell'] = {
            -- Alliance Spells
            "Malevolent Covariance",
            "Malevolent Conjunction",
            "Malevolent Coalition",
            "Malevolent Covenant",
            "Malevolent Alliance",
        },
        ['DichoSpell'] = {
            ---DichoSpell >= LVL101
            "Ecliptic Paroxysm",
            "Composite Paroxysm",
            "Dissident Paroxysm",
            "Dichotomic Paroxysm",
            "Reciprocal Paroxysm",
        },
        ['SwarmPet'] = {
            ---SwarmPet >= LVL85
            "Call Ravening Skeleton",
            "Call Roiling Skeleton",
            "Call Riotous Skeleton",
            "Call Reckless Skeleton",
            "Call Remorseless Skeleton",
            "Call Relentless Skeleton",
            "Call Ruthless Skeleton",
            "Call Ruinous Skeleton",
            "Call Rumbling Skeleton",
            "Call Skeleton Thrall",
            "Call Skeleton Mass",
            "Call Skeleton Horde",
            "Call Skeleton Army",
            "Call Skeleton Mob",
            "Call Skeleton Throng",
            "Call Skeleton Host",
            "Call Skeleton Crush",
            "Call Skeleton Swarm",
        },
        ['HealthTaps'] = {
            ---HealthTaps >= LVL1

            "Extort Essence",

            "Maraud Essence",

            "Draw Essence",

            "Consume Essence",

            "Hemorrhage Essence",
            "Plunder Essence",
            "Bleed Essence",
            "Divert Essence",
            "Drain Essence",
            "Siphon Essence",
            "Drain Life",
            -- [] =["Ancient: Touch of Orshilak",
            "Soulspike",
            "Touch of Mujaki",
            "Touch of Night",
            "Deflux",
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Lifedraw",
            "Lifespike",
            "Lifetap",
        },
        ['SoulTaps'] = {
            ---HealthTaps >= LVL1
            "Soullash",

            "Soulflay",

            "Soulgouge",

            "Soulsiphon",

            "Soulrend",

        },
        ['DurationTap'] = {
            ---DurationTap >= LVL29
            "Helmsbane's Grasp",
            "The Protector's Grasp",
            "Tserrina's Grasp",
            "Bomoda's Grasp",
            "Plexipharia's Grasp",
            "Halstor's Grasp",
            "Ivrikdal's Grasp",
            "Arachne's Grasp",
            "Fellid's Grasp",
            "Visziaj's Grasp",
            "Dyn`leth's Grasp",
            "Fang of Death",
            "Night's Beckon",
            "Saryrn's Kiss",
            "Vexing Mordinia",
            "Bond of Death",
            "Vampiric Curse",
        },
        ['GroupLeech'] = {
            ---GroupLeech >= LVL9
            "Ghastly Leech",
            "Twilight Leech",
            "Frozen Leech",
            "Ashen Leech",
            "Dark Leech",
            "Leech",
        },
        ['ManaDrain'] = {
            --Mana Drain with Group Mana Recourse
            "Mind Disintegrate",
            "Mind Atrophy",
            "Mind Erosion",
            "Mind Exorciation",
            "Mind Extraction",
            "Mind Strip",
            "Mind Abrasion",
            "Thought Flay",
            "Mind Decomposition",
            "Mental Vivisection",
            "Mind Dissection",
            "Mind Flay",
            "Mind Wrack",
        },
        ['PoisonNuke1'] = {
            ---PoisonNuke >=LVL21
            "Necrotizing Venin",
            "Embalming Venin",
            "Searing Venin",
            "Effluvial Venin",
            "Liquefying Venin",
            "Dissolving Venin",
            "Blighted Venin",
            "Withering Venin",
            "Ruinous Venin",
            "Venin",
            "Acikin",
            "Neurotoxin",
            "Torbas' Venom Blast",
            "Torbas' Poison Blast",
            "Torbas' Acid Blast",
            "Shock of Poison",
        },
        ['PoisonNuke2'] = {
            ---PoisonNuke2  >=LVL 75 (DD Increase chance)
            "Decree for Blood",
            "Proclamation for Blood",
            "Assert for Blood",
            "Refute for Blood",
            "Impose for Blood",
            "Impel for Blood",
            --"Provocation for Blood",
            "Compel for Blood",
            "Exigency for Blood",
            "Supplication of Blood",
            "Demand for Blood",
        },
        ['FireNuke'] = {
            ---Fire Nuke, undead conversion and short stun, 90+
            "Immolate Bones",    -- Level 125
            "Cremate Bones",     -- Level 120
            "Char Bones",        -- Level 115
            "Burn Bones",        -- Level 110
            "Combust Bones",     -- Level 105
            "Scintillate Bones", -- Level 100
            "Coruscate Bones",   -- Level 95
            "Scorch Bones",      -- Level 90
        },
        ['FireDot1'] = {
            ---FireDot1 >= LVL80
            "Raging Shadow",
            "Scalding Shadow",
            "Broiling Shadow",
            "Burning Shadow",
            "Smouldering Shadow",
            "Coruscating Shadow",
            "Blazing Shadow",
            "Blistering Shadow",
            "Scorching Shadow",
            "Searing Shadow",
        },
        ['FireDot2'] = {
            ---FireDot2 >= LVL10
            "Pyre of Illandrin",
            "Pyre of Va Xakra",
            "Pyre of Klraggek",
            "Pyre of the Shadewarden",
            "Pyre of Jorobb",
            "Pyre of Marnek",
            "Pyre of Hazarak",
            "Pyre of Nos",
            "Soul Reaper's Pyre",
            "Reaver's Pyre",
            "Ashengate Pyre",
            "Dread Pyre",
            "Night Fire",
            "Funeral Pyre of Kelador",
            "Pyrocruor",
            "Ignite Blood",
            "Boil Blood",
            "Heat Blood",
        },
        ['FireDot2_2'] = {
            ---FireDot2 >= LVL10
            "Pyre of Illandrin",
            "Pyre of Va Xakra",
            "Pyre of Klraggek",
            "Pyre of the Shadewarden",
            "Pyre of Jorobb",
            "Pyre of Marnek",
            "Pyre of Hazarak",
            "Pyre of Nos",
            "Soul Reaper's Pyre",
            "Reaver's Pyre",
            "Ashengate Pyre",
            "Dread Pyre",
            "Night Fire",
            "Funeral Pyre of Kelador",
            "Pyrocruor",
            "Ignite Blood",
            "Boil Blood",
            "Heat Blood",
        },
        ['FireDot3'] = {
            ---FireDot3 >= LVL88 (QuickDOT)
            "Arcanaforged's Flashblaze",
            "Thall Va Kelun's Flashblaze",
            "Otatomik's Flashblaze",
            "Azeron's Flashblaze",
            "Mazub's Flashblaze",
            "Osalur's Flashblaze",
            "Brimtav's Flashblaze",
            "Tenak's Flashblaze",
        },
        ['FireDot4'] = {
            ---FireDot4 >= LVL73 DOT
            "Pyre of the Abandoned",
            "Pyre of the Neglected",
            "Pyre of the Wretched",
            "Pyre of the Fereth",
            "Pyre of the Lost",
            "Pyre of the Forsaken",
            "Pyre of the Piq'a",
            "Pyre of the Bereft",
            "Pyre of the Forgotten",
            "Pyre of the Lifeless",
            "Pyre of the Fallen",
        },
        ['Magic1'] = {
            ---Magic1 >= LVL51 SlowDot
            "Putrefying Wounds",
            "Infected Wounds",
            "Septic Wounds",
            "Cytotoxic Wounds",
            "Mortiferous Wounds",
            "Pernicious Wounds",
            "Necrotizing Wounds",
            "Splirt",
            "Splart",
            "Splort",
            "Splurt",
        },
        ['Magic2'] = {
            ---Magic2 >=LVL67 DOT
            "Extermination",
            "Extinction",
            "Oblivion",
            "Inevitable End",
            "Annihilation",
            "Termination",
            "Doom",
            "Demise",
            "Mortal Coil",
            "Anathema of Life",
            "Curse of Mortality",
            "Ancient: Curse of Mori",
            "Dark Nightmare",
            "Horror",
        },
        ['Magic2_2'] = {
            ---Magic2 >=LVL67 DOT
            "Extermination",
            "Extinction",
            "Oblivion",
            "Inevitable End",
            "Annihilation",
            "Termination",
            "Doom",
            "Demise",
            "Mortal Coil",
            "Anathema of Life",
            "Curse of Mortality",
            "Ancient: Curse of Mori",
            "Dark Nightmare",
            "Horror",
        },
        ['Magic3'] = {
            ---Magic3 >=LVL87 QuickDot
            "Blevak's Swift Deconstruction",
            "Xetheg's Swift Deconstruction",
            "Lexelan's Swift Deconstruction",
            "Adalora's Swift Deconstruction",
            "Marmat's Swift Deconstruction",
            "Itkari's Swift Deconstruction",
            "Hral's Swift Deconstruction",
            "Ninavero's Swift Deconstruction",
        },
        ['Magic4'] = {
            ---Magic4 >=LVL 97 DOT
            "Scourge of Eternity", -- Level 123 TOB
            "Scourge of Destiny",
            "Scourge of Fates",
        },
        ['Disease1'] = {
            ---Decay Line of Disease Spells >=LVL56 Slow DOT
            "Goremand's Decay",
            "Fleshrot's Decay",
            "Danvid's Decay",
            "Mourgis' Decay",
            "Livianus' Decay",
            "Wuran's Decay",
            "Ulork's Decay",
            "Folasar's Decay",
            "Megrima's Decay",
            "Eranon's Decay",
            "Severan's Rot",
            "Chaos Plague",
            "Dark Plague",
            "Cessation of Cor",
        },
        ['Disease2'] = {
            ---Grip Line of Disease Spells =LVL1 HAS DEBUFF

            "Grip of Quietus",

            "Grip of Zorglim",
            "Grip of Kraz",
            "Grip of Jabaum",
            "Grip of Zalikor",
            "Grip of Zargo",
            "Grip of Mori",
            "Plague",
            "Asystole",
            "Scourge",
            -- "Infectious Cloud", -- Target AE Spell
            "Heart Flutter",
            "Disease Cloud",
        },
        ['Combo'] = {
            ---Combines Disease1 and Disease2
            "Goremand's Grip of Decay",
            "Fleshrot's Grip of Decay",
            "Danvid's Grip of Decay",
            "Mourgis' Grip of Decay",
            "Livianus' Grip of Decay",

        },
        ['Disease3'] = {
            ---Sickness Life of Disease Spells >=LVL89 QuickDOT
            "Ogna's Swift Sickness",
            "Diabo Tatrua's Swift Sickness",
            "Lairsaf's Swift Sickness",
            "Hoshkar's Swift Sickness",
            "Ilsaria's Swift Sickness",
            "Bora's Swift Sickness",
            "Prox's Swift Sickness",
            "Rilfed's Swift Sickness",
        },
        ['Poison1'] = {
            ---Poison1 >= LVL86 (QuickDOT)
            "Dotal's Swift Venom",
            "Xenacious' Swift Venom",
            "Vilefang's Swift Venom",
            "Nexona's Swift Venom",
            "Serisaria's Swift Venom",
            "Slaunk's Swift Venom",
            "Hyboram's Swift Venom",
            "Burlabis' Swift Venom",
        },
        ['Poison2'] = {
            ---Poison2 >=LVL1 (DOT)
            "Luggald Venom",
            "Hemorrhagic Venom",
            "Crystal Crawler Venom",
            "Polybiad Venom",
            "Glistenwing Venom",
            "Binaesa Venom",
            "Naeya Venom",
            "Argendev's Venom",
            "Slitheren Venom",
            "Venonscale Venom",
            "Vakk`dra's Sickly Mists",
            "Blood of Thule",
            "Envenomed Bolt",
            "Chilling Embrace",
            "Venom of the Snake",
            "Poison Bolt",
        },
        ['Poison2_2'] = {
            ---Poison2 >=LVL1 (DOT)
            "Luggald Venom",
            "Hemorrhagic Venom",
            "Crystal Crawler Venom",
            "Polybiad Venom",
            "Glistenwing Venom",
            "Binaesa Venom",
            "Naeya Venom",
            "Argendev's Venom",
            "Slitheren Venom",
            "Venonscale Venom",
            "Vakk`dra's Sickly Mists",
            "Blood of Thule",
            "Envenomed Bolt",
            "Chilling Embrace",
            "Venom of the Snake",
            "Poison Bolt",
        },
        ['Poison3'] = {
            ---Poison3 >= LVL79 DOT
            "Uncia's Pallid Haze",
            "Zelnithak's Pallid Haze",
            "Dracnia's Pallid Haze",
            "Bomoda's Pallid Haze",
            "Plexipharia's Pallid Haze",
            "Halstor's Pallid Haze",
            "Ivrikdal's Pallid Haze",
            "Arachne's Pallid Haze",
            "Fellid's Pallid Haze",
            "Visziaj's Pallid Haze",
            "Chaos Venom",
        },
        ['Corruption1'] = {
            ---Corruption1 >= LVL77
            "Deterioration",
            "Decomposition",
            "Miasma",
            "Effluvium",
            "Liquefaction",
            "Dissolution",
            "Mortification",
            "Fetidity",
            "Putrescence",
            "Putrefaction",
        },
        ['CripplingTap'] = {
            -- >= LVL56 Crippling Claudication
            "Crippling Paraplegia",
            "Crippling Incapacity",
            "Crippling Claudication",
        },
        ['ChaoticDebuff'] = {
            -- >= LVL93
            -- Chaotic Contgion
            "Chaotic Fetor",
            "Chaotic Acridness",
            "Chaotic Miasma",
            "Chaotic Effluvium",
            "Chaotic Liquefaction",
            "Chaotic Corruption",
            "Chaotic Contagion",
        },
        ['SnareDot'] = {
            -- LVL4 -> <= LVL70
            "Afflicted Darkness",
            "Harrowing Darkness",
            "Tormenting Darkness",
            "Gnawing Darkness",
            "Grasping Darkness",
            "Clutching Darkness",
            "Viscous Darkness",
            "Tenuous Darkness",
            "Clawing Darkness",
            "Auroral Darkness",
            "Coruscating Darkness",
            "Desecrating Darkness",
            "Embracing Darkness",
            "Devouring Darkness",
            "Cascading Darkness",
            "Scent of Darkness",
            "Dooming Darkness",
            "Engulfing Darkness",
            "Clinging Darkness",
        },
        ['ScentDebuff'] = {
            -- line needed till >= LVL10 <= LVL85
            "Scent of The Realm",
            "Scent of The Grave",
            "Scent of Mortality",
            "Scent of Extinction",
            "Scent of Dread",
            "Scent of Nightfall",
            "Scent of Doom",
            "Scent of Gloom",
            "Scent of Afterlight",
            "Scent of Twilight",
            "Scent of Midnight",
            "Scent of Terris",
            "Scent of Darkness",
            "Scent of Shadow",
            "Scent of Dusk",
        },
        ['LichSpell'] = {
            -- LichForm Spell
            "Realmside",
            "Lunaside",
            "Gloomside",
            "Contraside",
            "Forgottenside",
            "Forsakenside",
            "Shadowside",
            "Darkside",
            "Netherside",
            "Spectralside",
            "Otherside",
            "Dark Possession",
            "Grave Pact",
            "Seduction of Saryrn",
            "Arch Lich",
            "Demi Lich",
            "Lich",
            "Call of Bones",
            "Allure of Death",
            "Dark Pact",
        },
        ['BestowBuff'] = {
            -- Bestow Line
            "Bestow Ruin",
            "Bestow Rot",
            "Bestow Dread",
            "Bestow Relife",
            "Bestow Doom",
            "Bestow Mortality",
            "Bestow Decay",
            "Bestow Unlife",
            "Bestow Undeath",
        },
        ['PetSpellRog'] = {
            ---Pet Spells Rogue * Var Name:, string outer
            "Merciless Assassin",
            "Unrelenting Assassin",
            "Restless Assassin",
            "Reliving Assassin",
            "Restless Assassin",
            "Revived Assassin",
            "Unearthed Assassin",
            "Reborn Assassin",
            "Raised Assassin",
            "Unliving Murderer",
            "Noxious Servant",
            "Putrescent Servant",
            "Dark Assassin",
            "Child of Bertoxxulous",
            "Saryrn's Companion",
            "Minion of Shadows",
        },
        ['PetSpellWar'] = {
            ---Pet Spells Warrior
            "Margator's Shade",
            "Luclin's Conqueror",
            "Tserrina's Shade",
            "Adalora's Shade",
            "Miktokla's Shade",
            "Zalifur's Shade",
            "Vak`Ridel's Shade",
            "Aziad's Shade",
            "Bloodreaper's Shade",
            "Relamar's Shade",
            "Riza`farr's Shadow",
            "Lost Soul",
            "Emissary of Thule",
            "Servant of Bones",
            "Invoke Death",
            "Cackling Bones",
            "Malignant Dead",
            "Invoke Shadow",
            "Summon Dead",
            "Haunting Corpse",
            "Animate Dead",
            "Restless Bones",
            "Convoke Shadow",
            "Bone Walk",
            "Leering Corpse",
            "Cavorting Bones",
        },
        ['PetBuff'] = {
            ---Pet Buff Spell * Var Name:, string outer
            "Instill Ally",
            "Inspire Ally",
            "Incite Ally",
            "Infuse Ally",
            "Imbue Ally",
            -- "Sanction Ally",
            -- "Empower Ally",
            -- "Energize Ally",
            -- "Necrotize Ally",
        },
        ['PetHaste'] = {
            ---Pet Haste Spell * Var Name:, string outer
            "Sigil of Putrefaction",
            "Sigil of Undeath",
            "Sigil of Decay",
            "Sigil of the Arcron",
            "Sigil of the Doomscale",
            "Sigil of the Sundered",
            "Sigil of the Preternatural",
            "Sigil of the Moribund",
            "Sigil of the Aberrant",
            "Sigil of the Unnatural",
            "Glyph of Darkness",
            "Rune of Death",
            "Augmentation of Death",
            "Augment Death",
            "Intensify Death",
            "Focus Death",
        },
        ['FleshBuff'] = {
            "Flesh to Toxin",  -- Level 119
            "Flesh to Venom",  -- Level 109
            "Flesh to Poison", -- Level 99
        },
    },
    ['RotationOrder']   = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Lich Management',
            timer = 10,
            state = 1,
            steps = 1,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return true
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToPetBuff() and mq.TLO.Me.Pet.ID() == 0 and not Core.IsCharming() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 30,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and not Casting.IAmFeigning() and
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or (Targeting.IsNamed(Targeting.GetAutoTarget())) and mq.TLO.Me.PctAggro() > 99)
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
    },
    ['Rotations']       = {
        ['Lich Management'] = {
            {
                name = "LichSpell",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Config:GetSetting('DoLich') and Casting.SelfBuffCheck(spell) and
                        (not Config:GetSetting('DoUnity') or not Casting.AAReady("Mortifier's Unity")) and
                        mq.TLO.Me.PctHPs() > Config:GetSetting('StopLichHP') and mq.TLO.Me.PctMana() < Config:GetSetting('StartLichMana')
                end,
            },
            {
                name = "LichControl",
                type = "CustomFunc",
                cond = function(self, _)
                    local lichSpell = self:GetResolvedActionMapItem('LichSpell')

                    return lichSpell and lichSpell() and Casting.IHaveBuff(lichSpell) and
                        (mq.TLO.Me.PctHPs() <= Config:GetSetting('StopLichHP') or mq.TLO.Me.PctMana() >= Config:GetSetting('StopLichMana'))
                end,
                custom_func = function(self)
                    Core.SafeCallFunc("Stop Lich Spell", self.ClassConfig.HelperFunctions.CancelLich, self)
                end,
            },
            {
                name = "FleshControl",
                type = "CustomFunc",
                cond = function(self, _)
                    local fleshSpell = self:GetResolvedActionMapItem('FleshBuff')

                    return fleshSpell and fleshSpell() and Casting.IHaveBuff(fleshSpell) and mq.TLO.Me.PctHPs() <= Config:GetSetting('StopLichHP')
                end,
                custom_func = function(self)
                    Core.SafeCallFunc("Stop Flesh Buff", self.ClassConfig.HelperFunctions.CancelFlesh, self)
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Death's Effigy",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('AggroFeign') then return false end
                    return (mq.TLO.Me.PctHPs() <= 40 and Targeting.IHaveAggro(100)) or (Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 99)
                end,
            },
            {
                name = "Dying Grasp",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "Embalmer's Carapace",
                type = "AA",
            },
            {
                name = "Harm Shield",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Targeting.IHaveAggro(100))
                end,
            },
        },
        ['DPS'] = {
            {
                name_func = function(self)
                    return Config:GetSetting('PetType') == 1 and "PetSpellWar" or "PetSpellRog"
                end,
                type = "Spell",
                cond = function(self, spell)
                    return Casting.ReagentCheck(spell)
                end,
                post_activate = function(self, spell, success)
                    local pet = mq.TLO.Me.Pet
                    if success and pet.ID() > 0 then
                        Comms.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(), pet.Class.Name(), pet.CleanName(), spell.RankName())
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
            {
                name = "Wake the Dead",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.SpawnCount("corpse radius 100")() >= Config:GetSetting('WakeDeadCorpseCnt')
                end,
            },
            {
                name = "FireDot2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "ManaDrain",
                type = "Spell",
                cond = function(self, spell, target)
                    return not Casting.IHaveBuff(spell.Name() .. " Recourse") and
                        (mq.TLO.Target.PctMana() or -1) > 0 and mq.TLO.Group.LowMana(40)() > 2
                end,
            },
            {
                name = "Combo",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "Poison2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "Magic2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "GroupLeech",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "SwarmPet",
                type = "Spell",
                cond = function(self, spell, target)
                    return (Targeting.MobHasLowHP or Targeting.IsNamed(target)) and Casting.HaveManaToNuke()
                end,
            },
            {
                name = "PoisonNuke2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "FireNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MobHasLowHP and Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Death Bloom",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName) and mq.TLO.Me.PctMana() < Config:GetSetting('DeathBloomPercent') and mq.TLO.Me.PctHPs() > 50
                end,
            },
            {
                name = "Embrace the Decay",
                type = "AA",
                cond = function(self, aaName)
                    ---@diagnostic disable-next-line: undefined-field
                    return mq.TLO.Me.TotalCounters() > 0
                end,
            },
        },
        ['Burn'] = { -- TODO: Needs optimization. For now its all just kinda thrown in. --Algar
            {
                name = "Scent of Thule",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target)
                end,
            },
            {
                name = "OoW_Chest",
                type = "Item",
            },
            {
                name = "Funeral Pyre",
                type = "AA",
            },
            {
                name = "Hand of Death",
                type = "AA",
            },
            {
                name = "Mercurial Torment",
                type = "AA",
            },
            {
                name = "Heretic's Twincast",
                type = "AA",
            },
            {
                name = "Gathering Dusk",
                type = "AA",
                cond = function(self, aaName, target) return Targeting.IsNamed(target) end,
            },
            {
                name = "Swarm of Decay",
                type = "AA",
            },
            {
                name = "Companion's Fury",
                type = "AA",
            },
            {
                name = "Rise of Bones",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName, target) return Targeting.IsNamed(target) end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
            {
                name = "Spire of Necromancy",
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
                name = "BestowBuff",
                type = "Spell",
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 60
                end,
            },
            {
                name = "Dying Grasp",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() <= 50
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "SelfHPBuff",
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
                name = "SelfSpellShield1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "Death Bloom",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName) return mq.TLO.Me.PctMana() < Config:GetSetting('DeathBloomPercent') end,
            },
            {
                name = "BestowBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "FleshBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyStart') and Casting.SelfBuffCheck(spell)
                end,
            },
        },
        ['PetSummon'] = { --TODO: Double check these lists to ensure someone leveling doesn't have to change options to keep pets current at lower levels
            {
                name_func = function(self)
                    return Config:GetSetting('PetType') == 1 and "PetSpellWar" or "PetSpellRog"
                end,
                type = "Spell",
                cond = function(self, spell)
                    return Casting.ReagentCheck(spell)
                end,
                post_activate = function(self, spell, success)
                    local pet = mq.TLO.Me.Pet
                    if success and pet.ID() > 0 then
                        Comms.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(), pet.Class.Name(), pet.CleanName(), spell.RankName())
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetHaste",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },
            {
                name = "PetBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },
            {
                name = "Companion's Aegis",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
        },
    },
    ['HelperFunctions'] = {
        CancelLich = function(self)
            -- detspa means detremental spell affect and 0 mean HPs
            -- spa is positive spell affect and 15 means mana
            local lichName = mq.TLO.Me.FindBuff("detspa 0 and spa 15")()
            Core.DoCmd("/removebuff %s", lichName)
        end,
        CancelFlesh = function(self)
            local fleshName = self:GetResolvedActionMapItem('FleshBuff')
            Core.DoCmd("/removebuff %s", fleshName)
        end,

        StartLich = function(self)
            local lichSpell = self:GetResolvedActionMapItem('LichSpell')

            if lichSpell and lichSpell() then
                Casting.UseSpell(lichSpell.RankName.Name(), mq.TLO.Me.ID(), false)
            end
        end,

        DoRez = function(self, corpseId)
            if Config:GetSetting('DoBattleRez') or mq.TLO.Me.CombatState():lower() ~= "combat" then
                if Casting.AAReady("Convergence") and Casting.ReagentCheck(mq.TLO.Me.AltAbility("Convergence").Spell) then
                    return Casting.OkayToRez(corpseId) and Casting.UseAA("Convergence", corpseId, true, 1)
                end
            end
        end,
    },
    -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
    -- The list name ("Default" in the list below) is abitrary, it is simply what shows up in the UI when this spell list is loaded.
    -- Virtually any helper function or TLO can be used as a condition. Example: Mode or level-based lists.
    -- The first list without conditions or whose conditions returns true will be loaded, all subsequent lists will be ignored.
    -- Spells will be loaded in order (if the conditions are met), until all gem slots are full.
    -- Loadout checks (such as scribing a spell or using the "Rescan Loadout" or "Reload Spells" buttons) will re-check these lists and may load a different set if things have changed.
    ['SpellList']       = {
        {
            name = "Default",
            -- cond = function(self) return true end, --Kept here for illustration, this line could be removed in this instance since we aren't using conditions.
            spells = {
                { name = "FireNuke", },
                { name = "PoisonNuke2", },
                { name = "SwarmPet", },
                { name = "FireDot2", },
                { name = "Combo", },
                { name = "Poison2", },
                { name = "Magic2", },
                { name = "GroupLeech", },
                { name = "ManaDrain", },
                { name = "FleshBuff", },
                { name = "BestowBuff", },
                { name = "PetBuff", },
                {
                    name_func = function(self)
                        return Config:GetSetting('PetType') == 1 and "PetSpellWar" or "PetSpellRog"
                    end,
                    cond = function(self) return Config:GetSetting('KeepPetMemmed') end,
                },
                { name = "LichSpell", },
            },
        },
    },
    ['DefaultConfig']   = {
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes Do?",
            Answer = "Currently Necros only have one mode, which is DPS. This mode will focus on DPS and some utility.",
        },
        ['PetType']           = {
            DisplayName = "Pet Class",
            Category = "Pet",
            Index = 1,
            Tooltip = "1 = War, 2 = Rog",
            Type = "Combo",
            ComboOptions = { 'War', 'Rog', },
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "I want to only use a Rogue Pet for the Backstabs, how do I do that?",
            Answer = "Set the [PetType] setting to Rog and the Necro will only summon Rogue pets.",
        },
        ['KeepPetMemmed']     = {
            DisplayName = "Always Mem Pet",
            Category = "Pet",
            Index = 2,
            Tooltip = "Keep your pet spell memorized (allows combat resummoning).",
            Default = false,
            FAQ = "Why won't I resummon my pet on combat?",
            Answer = "Enable the setting to Always Mem your Pet on the Pet Management tab in the class options.",
        },
        ['BattleRez']         = {
            DisplayName = "Battle Rez",
            Category = "Spells and Abilities",
            Tooltip = "Do Rezes during combat.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "I want to use my Battle Rez, how do I do that?",
            Answer = "Set the [BattleRez] setting to true and the Necro will use their Battle Rez during combat.",
        },
        ['DeathBloomPercent'] = {
            DisplayName = "Death Bloom %",
            Category = "Spells and Abilities",
            Tooltip = "Mana % at which to cast Death Bloom",
            Default = 40,
            Min = 1,
            Max = 100,
            FAQ = "I am using Death Bloom to early or late, how do I adjust it?",
            Answer = "Set the [DeathBloomPercent] setting to the desired % of mana you want to cast Death Bloom at.",
        },
        ['WakeDeadCorpseCnt'] = {
            DisplayName = "WtD Corpse Count",
            Category = "Spells and Abilities",
            Tooltip = "Number of Corpses before we cast Wake the Dead",
            Default = 5,
            Min = 1,
            Max = 20,
            FAQ = "I want to use Wake the Dead when I have X corpses nearby, how do I do that?",
            Answer = "Set the [WakeDeadCorpseCnt] setting to the desired number of corpses you want to cast Wake the Dead at.",
        },
        ['DoLich']            = {
            DisplayName = "Cast Lich",
            Category = "Lich",
            Tooltip = "Enable casting Lich spells.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "I want to use my Lich spells, how do I do that?",
            Answer = "Set the [DoLich] setting to true and the Necro will use Lich spells.\n" ..
                "You will also want to set your [StopLichHP] and [StopLichMana] settings to the desired values so you do not Lich to Death.",
        },
        ['StopLichHP']        = {
            DisplayName = "Stop Lich HP",
            Category = "Lich",
            Tooltip = "Cancel Lich and Flesh Buff at [x] Pct HPs. Please note that Flesh Buff will recast if we are above the Emergency Start HP%",
            RequiresLoadoutChange = false,
            Default = 25,
            Min = 1,
            Max = 99,
            FAQ = "I want to stop Liching at a certain HP %, how do I do that?",
            Answer = "Set the [StopLichHP] setting to the desired % of HP you want to stop Liching at.",
        },
        ['StopLichMana']      = {
            DisplayName = "Stop Lich Mana",
            Category = "Lich",
            Tooltip = "Cancel Lich at Mana Pct [x]",
            RequiresLoadoutChange = false,
            Default = 100,
            Min = 1,
            Max = 100,
            FAQ = "I want to stop Liching at a certain Mana %, how do I do that?",
            Answer = "Set the [StopLichMana] setting to the desired % of Mana you want to stop Liching at.",
        },
        ['StartLichMana']     = { DisplayName = "Start Lich Mana", Category = "Lich", Tooltip = "Start Lich at Mana Pct [x]", RequiresLoadoutChange = false, Default = 70, Min = 1, Max = 100, },
        ['DoChestClick']      = { DisplayName = "Do Chest Click", Category = "Utilities", Tooltip = "Click your chest item", Default = mq.TLO.MacroQuest.BuildName() ~= "Emu", },
        ['EmergencyStart']    = {
            DisplayName = "Emergency HP%",
            Category = "Spells and Abilities",
            Index = 9,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities. Also, the minimum HP we need to use the Flesh Buff.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "How do I use my Emergency Mitigation Abilities?",
            Answer = "Make sure you have [EmergencyStart] set to the HP % before we begin to use emergency mitigation abilities.",
        },
        ['AggroFeign']        = {
            DisplayName = "Emergency Feign",
            Category = "Spells and Abilities",
            Index = 8,
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
            Default = true,
            FAQ = "How do I use my Feign Death?",
            Answer = "Make sure you have [AggroFeign] enabled.\n" ..
                "This will use your Feign Death AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
        },
        ['DoLifeBurn']        = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoUnity']           = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['StopFDPct']         = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['StartFDPct']        = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoSnare']           = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
    },

}

return _ClassConfig
