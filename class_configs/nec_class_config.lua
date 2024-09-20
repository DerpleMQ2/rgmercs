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

local _ClassConfig = {
    _version            = "0.2a",
    _author             = "Derple, Grimmier",
    ['Modes']           = {
        'DPS',
    },
    ['ModeChecks']      = {
        -- necro can AA Rez
        IsRezing   = function() return RGMercUtils.GetSetting('BattleRez') or RGMercUtils.GetXTHaterCount() == 0 end,
        CanCharm   = function() return true end,
        IsCharming = function() return (RGMercUtils.GetSetting('CharmOn') and mq.TLO.Pet.ID() == 0) end,
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
            about = "Start your Lich Spell [Note: This will enabled DoLich if it is not already]",
            handler =
                function(self)
                    RGMercUtils.SetSetting('DoLich', true)
                    RGMercUtils.SafeCallFunc("Start Necro Lich", self.ClassConfig.HelperFunctions.StartLich, self)

                    return true
                end,
        },
        stoplich = {
            usage = "/rgl stoplich",
            about = "Stop your Lich Spell [Note: This will NOT disable DoLich]",
            handler =
                function(self)
                    RGMercUtils.SafeCallFunc("Stop Necro Lich", self.ClassConfig.HelperFunctions.CancelLich, self)

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
        ['CharmSpell'] = {
            -- Charm Spells >= 20
            "Enslave Death",
            "Thrall of Bones",
            "Cajole Undead",
            "Beguile Undead",
            "Dominate Undead",
        },
        ---DPS
        ['AllianceSpell'] = {
            -- Alliance Spells
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
            "Soullash",
            "Extort Essence",
            "Soulflay",
            "Maraud Essence",
            "Soulgouge",
            "Draw Essence",
            "Soulsiphon",
            "Consume Essence",
            "Soulrend",
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
            "Provocation for Blood",
            "Compel for Blood",
            "Exigency for Blood",
            "Supplication of Blood",
            "Demand for Blood",
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
            "Fleshrot's Grip of Decay",
            "Grip of Quietus",
            "Danvid's Grip of Decay",
            "Grip of Zorglim",
            "Grip of Kraz",
            "Grip of Jabaum",
            "Grip of Zalikor",
            "Grip of Zargo",
            "Grip of Mori",
            "Plague",
            "Asystole",
            "Scourge",
            "Infectious Cloud",
            "Heart Flutter",
            "Disease Cloud",
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
        ['SnareDOT'] = {
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
            --The below spells deal PBAE damage on fade and should not be casually used (later spells drop this effect)
            --"Sanction Ally",
            --"Empower Ally",
            --"Energize Ally",
            --"Necrotize Ally",
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
    },
    ['RotationOrder']   = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    RGMercUtils.DoBuffCheck() and RGMercUtils.AmIBuffable()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and RGMercUtils.DoPetCheck() and not RGMercUtils.IsCharming()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 30,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and RGMercUtils.DoPetCheck()
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
        {
            -- this will always run first in combat to check for things like FD or stand up
            -- if you add to it make sure it remains pretty short because everythign will be
            -- evalutated before we move to combat.
            name = 'Safety',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and (RGMercUtils.IHaveAggro(RGMercUtils.GetSetting('StartFDPct')) or RGMercUtils.Feigning())
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.BurnCheck() and not RGMercUtils.Feigning()
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
    ['Rotations']       = {
        ['Lich Management'] = {
            {
                name = "LichSpell",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoLich') and RGMercUtils.SelfBuffCheck(spell) and
                        (not RGMercUtils.GetSetting('DoUnity') or not RGMercUtils.AAReady("Mortifier's Unity")) and
                        mq.TLO.Me.PctHPs() > RGMercUtils.GetSetting('StopLichHP') and mq.TLO.Me.PctMana() < RGMercUtils.GetSetting('StopLichMana')
                end,
            },
            {
                name = "LichControl",
                type = "CustomFunc",
                active_cond = function(self, spell) return true end,
                cond = function(self, _)
                    local lichSpell = RGMercUtils.GetResolvedActionMapItem('LichSpell')

                    return lichSpell and lichSpell() and RGMercUtils.BuffActive(lichSpell) and
                        (mq.TLO.Me.PctHPs() <= RGMercUtils.GetSetting('StopLichHP') or mq.TLO.Me.PctMana() >= RGMercUtils.GetSetting('StopLichMana'))
                end,
                custom_func = function(self)
                    RGMercUtils.SafeCallFunc("Stop Necro Lich", self.ClassConfig.HelperFunctions.CancelLich, self)
                end,
            },
        },
        ['Safety'] = {
            {
                name = "Death Peace",
                type = "AA",
                cond = function(self, aaName)
                    return not RGMercUtils.Feigning() and RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctHPs() < 75
                end,
            },
            {
                name = "Harm Shield",
                type = "AA",
                cond = function(self, aaName)
                    return not RGMercUtils.Feigning() and RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctHPs() >= 75
                end,
            },
            {
                name = "Stand Back Up",
                type = "CustomFunc",
                cond = function(self)
                    return RGMercUtils.Feigning() and RGMercUtils.GetHighestAggroPct() <= RGMercUtils.GetSetting('StopFDPct')
                end,
                custom_func = function(_)
                    RGMercUtils.DoCmd("/stand")
                    return true
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Wake the Dead",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and mq.TLO.SpawnCount("corpse radius 100")() >= RGMercUtils.GetSetting('WakeDeadCorpseCnt')
                end,
            },
            {
                name = "Death Bloom",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and mq.TLO.Me.PctMana() < RGMercUtils.GetSetting('DeathBloomPercent') and mq.TLO.Me.PctHPs() > 50
                end,
            },
            {
                name = "Scent of Thule",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and RGMercUtils.GetXTHaterCount() > 1
                end,
            },
            {
                name = "Encroaching Darkness",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and RGMercUtils.GetTargetPctHPs() < 50
                end,
            },
            {
                name = "Dying Grasp",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and mq.TLO.Me.PctAggro() <= 50
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and RGMercUtils.GetXTHaterCount() > 1
                end,
            },
            {
                name = "Life Burn",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoLifeBurn') and RGMercUtils.SelfBuffAACheck(aaName) and mq.TLO.Me.PctAggro() <= 25
                end,
            },
            {
                name = "ScentDebuff",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "ChaoticDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return not RGMercUtils.TargetHasBuff(spell) and spell.Trigger(2).StacksTarget()
                end,
            },
            {
                name = "CripplingTap",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, _) return true end,
            },
            {
                name = "SwarmPet",
                type = "Spell",
                cond = function(self, _) return true end,
            },
            {
                name = "SnareDOT",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) and RGMercUtils.GetSetting('DoSnare') end,
            },
            {
                name = "Disease3",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Magic3",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "FireDot3",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Disease2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Poison1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Poison2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Poison2_2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Disease1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Magic2_2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Poison3",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Magic1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "PoisonNuke2",
                type = "Spell",
                cond = function(self, _) return RGMercUtils.GetTargetPctHPs() > 50 and RGMercUtils.ManaCheck() end,
            },
            {
                name = "PoisonNuke1",
                type = "Spell",
                cond = function(self, _) return RGMercUtils.ManaCheck() end,
            },
            {
                name = "HealthTaps",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "DurationTap",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "FireDot1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "FireDot2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "FireDot2_2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "FireDot4",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "GroupLeech",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "Corruption1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
            {
                name = "DurationTap",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(spell) end,
            },
        },
        ['Burn'] = {
            {
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, itemName)
                    return mq.TLO.FindItemCount(itemName)() ~= 0
                end,
            },
            {
                name = "Funeral Pyre",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Hand of Death",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Mercurial Torment",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Heretic's Twincast",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and not RGMercUtils.TargetHasBuffByName(aaName)
                end,
            },
            {
                name = "Gathering Dusk",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Swarm of Decay",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Companion's Fury",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Rise of Bones",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Spire of Necromancy",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            --{
            --    name = "BestowBuff",
            --    type = "Spell",
            --    active_cond = function(self, spell) return RGMercUtils.SongActiveByName(spell.RankName()) end,
            --    cond = function(self, spell) return not RGMercUtils.SongActiveByName(spell.RankName()) end,
            --},
        },
        ['Downtime'] = {
            {
                name = "Stand Back Up",
                type = "CustomFunc",
                cond = function(self)
                    return mq.TLO.Me.State():lower() == "feign" and (mq.TLO.Me.PctAggro() < 90 or mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID())
                end,
                custom_func = function(_)
                    RGMercUtils.DoCmd("/stand")
                    return true
                end,
            },
            {
                name = "Mortifier's Unity",
                type = "AA",
                active_cond = function(self) return RGMercUtils.BuffActiveByName("Shield of Darkness") and RGMercUtils.BuffActiveByName("Otherside") end,
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoUnity') and RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfSpellShield1",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "Death Bloom",
                type = "AA",
                active_cond = function(self, aaName) return RGMercUtils.SongActiveByName(mq.TLO.AltAbility(aaName).Spell.RankName()) end,
                cond = function(self, aaName) return RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctMana() < RGMercUtils.GetSetting('DeathBloomPercent') end,
            },
        },
        ['PetSummon'] = { --TODO: Double check these lists to ensure someone leveling doesn't have to change options to keep pets current at lower levels
            {
                name = "PetSpellWar",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 and mq.TLO.Me.Pet.Class.ShortName():lower() == ("war" or "mnk") end,
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('PetType') == 1 and mq.TLO.Me.Pet.ID() == 0 and RGMercUtils.ReagentCheck(spell)
                end,
                post_activate = function(self, spell, success)
                    local pet = mq.TLO.Me.Pet
                    if success and pet.ID() > 0 then
                        RGMercUtils.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(), pet.Class.Name(), pet.CleanName(), spell.RankName())
                    end
                end,
            },
            {
                name = "PetSpellRog",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 and mq.TLO.Me.Pet.Class.ShortName():lower() == "rog" end,
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('PetType') == 2 and mq.TLO.Me.Pet.ID() == 0 and RGMercUtils.ReagentCheck(spell)
                end,
                post_activate = function(self, spell, success)
                    local pet = mq.TLO.Me.Pet
                    if success and pet.ID() > 0 then
                        RGMercUtils.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(), pet.Class.Name(), pet.CleanName(), spell.RankName())
                    end
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetHaste",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell) return RGMercUtils.SelfBuffPetCheck(spell) end,
            },
            {
                name = "PetBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell) return RGMercUtils.SelfBuffPetCheck(spell) end,
            },
        },
    },
    ['HelperFunctions'] = {
        -- helper function for advanced logic to see if we want to use Dark Lord's Unity
        CancelLich = function(self)
            -- detspa means detremental spell affect
            -- spa is positive spell affect
            local lichName = mq.TLO.Me.FindBuff("detspa hp and spa mana")()
            RGMercUtils.DoCmd("/removebuff %s", lichName)
        end,

        StartLich = function(self)
            local lichSpell = RGMercUtils.GetResolvedActionMapItem('LichSpell')

            if lichSpell and lichSpell() then
                RGMercUtils.UseSpell(lichSpell.RankName.Name(), mq.TLO.Me.ID(), false)
            end
        end,

        DoRez = function(self, corpseId)
            if RGMercUtils.GetSetting('DoBattleRez') or RGMercUtils.DoBuffCheck() then
                RGMercUtils.SetTarget(corpseId)

                local target = mq.TLO.Target

                if not target or not target() then return false end

                if mq.TLO.Target.Distance() > 25 then
                    RGMercUtils.DoCmd("/corpse")
                end

                if RGMercUtils.AAReady("Convergence") and mq.TLO.FindItemCount(mq.TLO.AltAbility("Convergence").Spell.ReagentID(1)())() > 0 then
                    return RGMercUtils.UseAA("Convergence", corpseId)
                end
            end
        end,
    },
    ['Spells']          = {
        {
            gem = 1,
            spells = {
                { name = "Disease2", },
                { name = "Poison3", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "Poison2",  cond = function(self) return mq.TLO.Me.Level() < 86 end, },
                { name = "Poison1", },
                { name = "FireDot2", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "FireDot2",   cond = function(self) return mq.TLO.Me.Level() < 51 end, },
                { name = "Magic1", },
                { name = "FireDot2_2", },
                { name = "GroupLeech", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "PoisonNuke1", cond = function(self) return mq.TLO.Me.Level() < 75 end, },
                { name = "PoisonNuke2", },
                { name = "Poison2_2", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "HealthTaps", },
                { name = "Poison2", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "DurationTap", },
                { name = "Magic2", },
                { name = "LichSpell", },
            },
        },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "CharmSpell",  cond = function(self) return RGMercUtils.GetSetting('CharmOn') end, },
                { name = "ScentDebuff", cond = function(self) return mq.TLO.Me.Level() < 89 end, },
                { name = "Disease3", },
                { name = "Disease1", },
                { name = "Disease2", },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SnareDOT",   cond = function(self) return RGMercUtils.GetSetting('DoSnare') end, },
                { name = "Magic1",     cond = function(self) return mq.TLO.Me.Level() > 70 and mq.TLO.Me.Level() < 87 end, },
                { name = "Magic3", },
                { name = "HealthTaps", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "FireDot2", cond = function(self) return mq.TLO.Me.Level() < 89 end, },
                { name = "FireDot3", },
                { name = "FDSpell", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Poison3",  cond = function(self) return mq.TLO.Me.Level() < 85 end, },
                { name = "SwarmPet", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Poison3",       cond = function(self) return mq.TLO.Me.Level() < 93 end, },
                { name = "ChaoticDebuff", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DichoSpell", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "AllianceSpell", cond = function(self) return RGMercUtils.GetSetting('DoAlliance') end, },
            },
        },
    },
    ['DefaultConfig']   = {
        ['Mode']              = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 1, },
        ['PetType']           = { DisplayName = "Pet Class", Category = "Combat", Tooltip = "1 = War, 2 = Rog", Type = "Combo", ComboOptions = { 'War', 'Rog', }, Default = 1, Min = 1, Max = 2, },
        ['BattleRez']         = { DisplayName = "Battle Rez", Category = "Spells and Abilities", Tooltip = "Do Rezes during combat.", RequiresLoadoutChange = true, Default = true, },
        ['DoLifeBurn']        = { DisplayName = "Use Life Burn", Category = "Spells and Abilities", Tooltip = "Use Life Burn AA if your aggro is below 25%.", Default = true, Index = 2, },
        ['DoUnity']           = { DisplayName = "Cast Unity", Category = "Spells and Abilities", Tooltip = "Enable casting Mortifiers Unity.", Default = true, Index = 1, },
        ['DeathBloomPercent'] = { DisplayName = "Death Bloom %", Category = "Spells and Abilities", Tooltip = "Mana % at which to cast Death Bloom", Default = 40, Min = 1, Max = 100, },
        ['DoSnare']           = { DisplayName = "Cast Snares", Category = "Spells and Abilities", Tooltip = "Enable casting Snare spells.", Default = true, },
        ['StartFDPct']        = { DisplayName = "FD Aggro Pct", Category = "Aggro Management", Tooltip = "Aggro % at which to FD", Default = 90, Min = 1, Max = 99, },
        ['StopFDPct']         = { DisplayName = "Stand Aggro Pct", Category = "Aggro Management", Tooltip = "Aggro % at which to Stand up from FD", Default = 80, Min = 1, Max = 99, },
        ['WakeDeadCorpseCnt'] = { DisplayName = "WtD Corpse Count", Category = "Spells and Abilities", Tooltip = "Number of Corpses before we cast Wake the Dead", Default = 5, Min = 1, Max = 20, },
        ['DoLich']            = { DisplayName = "Cast Lich", Category = "Lich", Tooltip = "Enable casting Lich spells.", RequiresLoadoutChange = true, Default = true, },
        ['StopLichHP']        = { DisplayName = "Stop Lich HP", Category = "Lich", Tooltip = "Cancel Lich at HP Pct [x]", RequiresLoadoutChange = false, Default = 25, Min = 1, Max = 99, },
        ['StopLichMana']      = { DisplayName = "Stop Lich Mana", Category = "Lich", Tooltip = "Cancel Lich at Mana Pct [x]", RequiresLoadoutChange = false, Default = 100, Min = 1, Max = 100, },
    },

}

return _ClassConfig
