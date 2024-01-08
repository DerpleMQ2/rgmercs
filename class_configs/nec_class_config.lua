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
    _version          = "0.1a",
    _author           = "Derple",
    ['Modes']         = {
        'DPS',
    },
    ['Themes']        = {
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
    ['ItemSets']      = {
        ['Epic'] = {
            "Deathwhisper",
            "Soulwhisper",
        },
    },
    ['AbilitySets']   = {
        ['SelfHPBuff'] = {
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
            "Malevolent Alliance",
            "Malevolent Covenant",
            "Malevolent Coalition",
            "Malevolent Conjunction",
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
            "Soulflay",
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
            "Twilight Leech",
            "Frozen Leech",
            "Ashen Leech",
            "Dark Leech",
            "Leech",
        },
        ['PoisonNuke'] = {
            ---PoisonNuke >=LVL21
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
            "Chaotic Acridness",
            "Chaotic Miasma",
            "Chaotic Effluvium",
            "Chaotic Liquefaction",
            "Chaotic Corruption",
            "Chaotic Contagion",
        },
        ['SnareDOT'] = {
            -- LVL4 -> <= LVL70
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
            "Inspire Ally",
            "Incite Ally",
            "Infuse Ally",
            "Imbue Ally",
            "Sanction Ally",
            "Empower Ally",
            "Energize Ally",
            "Necrotize Ally",
        },
        ['PetHaste'] = {
            ---Pet Haste Spell * Var Name:, string outer
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
    ['RotationOrder'] = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        { name = 'Downtime', targetId = function(self) return mq.TLO.Me.ID() end, cond = function(self, combat_state) return combat_state == "Downtime" and RGMercUtils.DoBuffCheck() end, },
        {
            -- this will always run first in combat to check for things like FD or stand up
            -- if you add to it make sure it remains pretty short because everythign will be
            -- evalutated before we move to combat.
            name = 'Safety',
            targetId = function(self) return RGMercConfig.Globals.AutoTargetID end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return RGMercConfig.Globals.AutoTargetID end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.BurnCheck() and mq.TLO.Me.State():lower() ~= "feign"
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return RGMercConfig.Globals.AutoTargetID end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.State():lower() ~= "feign"
            end,
        },
    },
    ['Rotations']     = {
        ['Safety'] = {
            {
                name = "Death Peace",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctHPs() < 75 --and (mq.TLO.Me.PctAggro() > 80 or mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID())
                end,
            },
            {
                name = "Harm Shield",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.State():lower() ~= "feign" and RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctHPs() > 75 and
                        (mq.TLO.Me.PctAggro() > 80 or mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID())
                end,
            },
            {
                name = "Stand Back Up",
                type = "cmd",
                cond = function(self)
                    return mq.TLO.Me.State():lower() == "feign" and (mq.TLO.Me.PctAggro() < 90 or mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID())
                end,
                cmd = "/stand",
            },
        },
        ['DPS'] = {
            {
                name = "Wake the Dead",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and mq.TLO.SpawnCount("corpse radius 100")() > 5
                end,
            },
            {
                name = "Death Bloom",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and mq.TLO.Me.PctMana() < self.settings.DeathBloomPercent and mq.TLO.Me.PctHPs() > 50
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
                    return RGMercUtils.SelfBuffAACheck(aaName) and mq.TLO.Me.PctAggro() <= 25
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
                cond = function(self, spell) return not RGMercUtils.TargetHasBuff(spell) and spell.Trigger(2).StacksTarget() end,
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
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) and self.settings.DoSnare end,
            },
            {
                name = "Disease3",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Magic3",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "FireDot3",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Disease2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Poison1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Poison2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Poison2_2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Disease1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Magic2_2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Poison3",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Magic1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "PoisonNuke2",
                type = "Spell",
                cond = function(self, _) return RGMercUtils.GetTargetPctHPs() > 50 and mq.TLO.Me.PctMana() > RGMercConfig:GetSettings().ManaToNuke end,
            },
            {
                name = "PoisonNuke",
                type = "Spell",
                cond = function(self, _) return mq.TLO.Me.PctMana() > RGMercConfig:GetSettings().ManaToNuke end,
            },
            {
                name = "HealthTaps",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "DurationTap",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "FireDot1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "FireDot2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "FireDot2_2",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "FireDot4",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "GroupLeech",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "Corruption1",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
            {
                name = "DurationTap",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DetSpellCheck(spell) end,
            },
        },
        ['Burn'] = {
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
            --    active_cond = function(self, spell) return RGMercUtils.SongActive(spell.RankName()) end,
            --    cond = function(self, spell) return not RGMercUtils.SongActive(spell.RankName()) end,
            --},
        },
        ['Downtime'] = {
            {
                name = "Stand Back Up",
                type = "cmd",
                cond = function(self)
                    return mq.TLO.Me.State():lower() == "feign" and (mq.TLO.Me.PctAggro() < 90 or mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID())
                end,
                cmd = "/stand",
            },
            {
                name = "Mortifier's Unity",
                type = "AA",
                active_cond = function(self) return RGMercUtils.BuffActiveByName("Shield of Darkness") and RGMercUtils.BuffActiveByName("Otherise") end,
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
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
                name = "LichSpell",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return self.settings.DoLich and RGMercUtils.SelfBuffCheck(spell) and not RGMercUtils.AAReady("Mortifier's Unity") and
                        mq.TLO.Me.PctHPs() > 30
                end,
            },
            {
                name = "Death Bloom",
                type = "AA",
                active_cond = function(self, aaName) return RGMercUtils.SongActive(mq.TLO.AltAbility(aaName).Spell.RankName()) end,
                cond = function(self, aaName) return RGMercUtils.AAReady(aaName) and mq.TLO.Me.PctMana() < self.settings.DeathBloomPercent end,
            },
            -- Leaving this out because it mems every 60s and thats wonky.
            --{
            --    name = "BestowBuff",
            --    type = "Spell",
            --    active_cond = function(self, spell) return RGMercUtils.SongActive(spell.RankName()) end,
            --    cond = function(self, spell) return not RGMercUtils.SongActive(spell.RankName()) end,
            --},
            {
                name = "PetSpellWar",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 and mq.TLO.Me.Pet.Class.ShortName():lower() == "war" end,
                pre_activate = function(self, spell)
                    if mq.TLO.Me.Pet.ID() > 0 then
                        mq.cmdf("/pet leave")
                    end
                end,
                cond = function(self, spell) return self.settings.PetType == 1 and (mq.TLO.Me.Pet.ID() == 0 or mq.TLO.Me.Pet.Class.ShortName():lower() ~= "war") end,
                post_activate = function(self, spell)
                    local pet = mq.TLO.Me.Pet
                    if pet.ID() > 0 then
                        RGMercUtils.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(), pet.Class.Name(), pet.CleanName(), spell.RankName())
                    end
                end,
            },
            {
                name = "PetSpellRog",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 and mq.TLO.Me.Pet.Class.ShortName():lower() == "rog" end,
                pre_activate = function(self, spell)
                    if mq.TLO.Me.Pet.ID() > 0 then
                        mq.cmdf("/pet leave")
                    end
                end,
                cond = function(self, _) return self.settings.PetType == 2 and (mq.TLO.Me.Pet.ID() == 0 or mq.TLO.Me.Pet.Class.ShortName():lower() ~= "rog") end,
                post_activate = function(self, spell)
                    local pet = mq.TLO.Me.Pet
                    if pet.ID() > 0 then
                        RGMercUtils.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(), pet.Class.Name(), pet.CleanName(), spell.RankName())
                    end
                end,
            },
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
    ['Spells']        = {
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
            },
        },
        {
            gem = 4,
            spells = {
                { name = "PoisonNuke",  cond = function(self) return mq.TLO.Me.Level() < 75 end, },
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
            },
        },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ScentDebuff", cond = function(self) return mq.TLO.Me.Level() < 89 end, },
                { name = "Disease3", },
                { name = "Disease1", },
                { name = "Disease", },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SnareDOT",   cond = function(self) return self.settings.DoSnare end, },
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
                { name = "AllianceSpell", },
            },
        },
    },
    ['DefaultConfig'] = {
        ['Mode']              = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 1, },
        ['PetType']           = { DisplayName = "Mode", Category = "Combat", Tooltip = "1 = War, 2 = Rog", Type = "Combo", ComboOptions = { 'War', 'Rog', }, Default = 1, Min = 1, Max = 2, },
        ['DoLich']            = { DisplayName = "Cast Lich", Category = "Spells and Abilities", Tooltip = "Enable casting Lich spells.", RequiresLoadoutChange = true, Default = true, },
        ['DeathBloomPercent'] = { DisplayName = "Death Bloom %", Category = "Spells and Abilities", Tooltip = "Mana % at which to cast Death Bloom", Default = 40, Min = 1, Max = 100, },
        ['DoSnare']           = { DisplayName = "Cast Snares", Category = "Spells and Abilities", Tooltip = "Enable casting Snare spells.", Default = true, },
    },

}

return _ClassConfig
