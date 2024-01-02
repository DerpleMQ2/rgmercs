local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

return {
    _version          = "0.1a",
    _author           = "Derple",
    ['Modes']         = {
        [1] = 'Combo',
        [2] = 'Fire',
        [3] = 'Ice',
        [4] = 'Magic',
    },
    ['ItemSets']      = {
        ['Epic'] = {
            [1] = "Staff of Phenomenal Power",
            [2] = "Staff of Prismatic Power",
        },
    },
    ['AbilitySets']   = {
        ['AllianceSpell'] = {
            [1] = "Malarian Mantle",
            [2] = "Frostbound Conjunction",
            [3] = "Frostbound Coalition",
            [4] = "Frostbound Covenant",
            [5] = "Frostbound Alliance",
        },
        ['DichoSpell'] = {
            [1] = "Ecliptic Fire",
            [2] = "Composite Fire",
            [3] = "Dissident Fire",
            [4] = "Dichotomic Fire",
        },
        ['IceClaw'] = {
            [1] = "Claw of the Void",
            [2] = "Claw of Gozzrem",
            [3] = "Claw of Travenro",
            [4] = "Claw of the Oceanlord",
            [5] = "Claw of the Icewing",
            [6] = "Claw of the Abyss",
            [7] = "Glacial Claw",
            [8] = "Claw of Selig",
            [9] = "Claw of Selay",
            [10] = "Claw of Vox",
            [11] = "Claw of Frost",
            [12] = "Claw of Ankexfen",
        },
        ['FireClaw'] = {
            [1] = "Claw of the Duskflame",
            [2] = "Claw of Sontalak",
            [3] = "Claw of Qunard",
            [4] = "Claw of the Flameweaver",
            [5] = "Claw of the Flamewing",
            [6] = "Claw of Ingot",
        },
        ['MagicClaw'] = {
            [1] = "Claw of Itzal",
            [2] = "Claw of Feshlak",
            [3] = "Claw of Ellarr",
            [4] = "Claw of the Indagatori",
            [5] = "Claw of the Ashwing",
            [6] = "Claw of the Battleforged",
        },
        ['CloudburstNuke'] = {
            [1] = "Cloudburst Lightningstrike",
            [2] = "Cloudburst Joltstrike",
            [3] = "Cloudburst Stormbolt",
            [4] = "Cloudburst Thunderbolt",
            [5] = "Cloudburst Stormstrike",
            [6] = "Cloudburst Thunderbolt",
            [7] = "Cloudburst Tempest",
            [8] = "Cloudburst Storm",
            [9] = "Cloudburst Levin",
            [10] = "Cloudburst Bolts",
            [11] = "Cloudburst Strike",
        },
        ['FuseNuke'] = {
            [1] = "Ethereal Twist",
            [2] = "Ethereal Confluence",
            [3] = "Ethereal Braid",
            [4] = "Ethereal Fuse",
            [5] = "Ethereal Weave",
            [6] = "Ethereal Plait",
        },
        ['FireEtherealNuke'] = {
            [1] = "Ethereal Immolation",
            [2] = "Ethereal Ignition",
            [3] = "Ethereal Brand",
            [4] = "Ethereal Skyfire",
            [5] = "Ethereal Skyblaze",
            [6] = "Ethereal Incandescence",
            [7] = "Ethereal Blaze",
            [8] = "Ethereal Inferno",
            [9] = "Ethereal Combustion",
            [10] = "Ethereal Incineration",
            [11] = "Ethereal Conflagration",
            [12] = "Ether Flame",
        },
        ['IceEtherealNuke'] = {
            [1] = "Lunar Ice Comet",
            [2] = "Restless Ice Comet",
            [3] = "Ethereal Icefloe",
            [4] = "Ethereal Rimeblast",
            [5] = "Ethereal Hoarfrost",
            [6] = "Ethereal Frost",
            [7] = "Ethereal Glaciation",
            [8] = "Ethereal Iceblight",
            [9] = "Ethereal Rime",
            [10] = "Ethereal Freeze",
        },
        ['MagicEtherealNuke'] = {
            [1] = "Ethereal Mortar",
            [2] = "Ethereal Blast",
            [3] = "Ethereal Volley",
            [4] = "Ethereal Flash",
            [5] = "Ethereal Salvo",
            [6] = "Ethereal Barrage",
            [7] = "Ethereal Blitz",
        },
        ['ChaosNuke'] = {
            [1] = "Chaos Flame",
            [2] = "Chaos Inferno",
            [3] = "Chaos Burn",
            [4] = "Chaos Scintillation",
            [5] = "Chaos Incandescence",
            [6] = "Chaos Blaze",
            [7] = "Chaos Char",
            [8] = "Chaos Conflagration",
            [9] = "Chaos Immolation",
            [10] = "Chaos Flame",
        },
        ['VortexNuke'] = {
            -- NOTE: ${Spell[${VortexNuke}].ResistType} can be used to determine which resist type is getting debuffed
            [1] = "Shadebright Vortex",
            [2] = "Thaumaturgic Vortex",
            [3] = "Stormjolt Vortex",
            [4] = "Shocking Vortex",
            -- Hoarfrost Vortex has a Fire Debuff
            [5] = "Hoarfrost Vortex",
            -- Ether Vortex has a Cold Debuff
            [6] = "Ether Vortex",
            -- Incandescent Vortex has a Magic Debuff
            [7] = "Incandescent Vortex",
            -- Frost Vortex has a Fire Debuff
            [8] = "Frost Vortex",
            -- Power Vortex has a Cold Debuff
            [9] = "Power Vortex",
            -- Flame Vortex has a Magic Debuff
            [10] = "Flame Vortex",
            -- Ice Vortex has a Fire Debuff
            [11] = "Ice Vortex",
            -- Mana Vortex has a Cold Debuff
            [12] = "Mana Vortex",
            -- Fire Vortex has a Magic Debuff
            [13] = "Fire Vortex",
        },
        ['WildNuke'] = {
            [1] = "Wildspell Strike",
            [2] = "Wildflame Strike",
            [3] = "Wildscorch Strike",
            [4] = "Wildflash Strike",
            [5] = "Wildflash Barrage",
            [6] = "Wildether Barrage",
            [7] = "Wildspark Barrage",
            [8] = "Wildmana Barrage",
            [9] = "Wildmagic Blast",
            [10] = "Wildmagic Burst",
            [11] = "Wildmagic Strike",
        },
        ['FireNuke'] = {
            [1] = "Kindleheart's Fire",
            [2] = "The Diabo's Fire",
            [3] = "Dagarn's Fire",
            [4] = "Dragoflux's Fire",
            [5] = "Narendi's Fire",
            [6] = "Gosik's Fire",
            [78] = "Daevan's Fire",
            [8] = "Lithara's Fire",
            [9] = "Klixcxyk's Fire",
            [10] = "Inizen's Fire",
            [11] = "Sothgar's Flame",
            [12] = "Corona Flare",
            [13] = "White Fire",
            [14] = "Garrison's Superior Sundering",
            [15] = "Conflagration",
            [16] = "Inferno Shock",
            [17] = "Flame Shock",
            [18] = "Fire Bolt",
            [19] = "Shock of Fire",
        },
        ['IceNuke'] = {
            [1] = "Glacial Ice Cascade",
            [2] = "Tundra Ice Cascade",
            [3] = "Restless Ice Cascade",
            [4] = "Icefloe Cascade",
            [5] = "Rimeblast Cascade",
            [6] = "Hoarfrost Cascade",
            [7] = "Rime Cascade",
            [8] = "Glacial Cascade",
            [9] = "Icesheet Cascade",
            [10] = "Glacial Collapse",
            [11] = "Icefall Avalanche",
            [12] = "Gelidin Comet",
            [13] = "Ice Meteor",
            [14] = "Ice Spear of Solist",
            [15] = "Frozen Harpoon",
            [16] = "Ice Comet",
            [17] = "Ice Shock",
            [18] = "Frost Shock",
            [19] = "Shock of Ice",
            [20] = "Frost Bolt",
            [21] = "Blast of Cold",
        },
        ['MagicNuke'] = {
            [1] = "Lightning Cyclone",
            [2] = "Lightning Maelstrom",
            [3] = "Lightning Roar",
            [4] = "Lightning Tempest",
            [5] = "Lightning Storm",
            [6] = "Lightning Squall",
            [7] = "Lightning Swarm",
            [8] = "Lightning Helix",
            [9] = "Ribbon Lightning",
            [10] = "Rolling Lightning",
            [11] = "Ball Lightning",
            [12] = "Spark of Lightning",
            [13] = "Draught of Lightning",
            [14] = "Elnerick's Electrical Rending",
            [15] = "Draught of Jiva",
            [16] = "Voltaic Draught",
            [17] = "Rend",
            [18] = "Lightning Shock",
            [19] = "Thunder Strike",
            [20] = "Garrison's Mighty Mana Shock",
            [21] = "Lightning Bolt",
            [22] = "Shock of Lightning",
        },
        ['StunSpell'] = {
            [1] = "Teladaka",
            [2] = "Teladaja",
            [3] = "Telajaga",
            [4] = "Telanata",
            [5] = "Telanara",
            [6] = "Telanaga",
            [7] = "Telanama",
            [8] = "Telakama",
            [9] = "Telajara",
            [10] = "Telajasz",
            [11] = "Telakisz",
            [12] = "Telekara",
            [13] = "Telaka",
            [14] = "Telekin",
            [15] = "Markar's Discord",
            [16] = "Markar's Clash",
            [17] = "Tishan's Clash",
        },
        ['SelfHPBuff'] = {
            [1] = "Shield of Memories",
            [2] = "Shield of Shadow",
            [3] = "Shield of Restless Ice",
            [4] = "Shield of Scales",
            [5] = "Shield of the Pellarus",
            [6] = "Shield of the Dauntless",
            [7] = "Shield of Bronze",
            [8] = "Shield of Dreams",
            [9] = "Shield of the Void",
            [10] = "Bulwark of the Crystalwing",
            [11] = "Shield of the Crystalwing",
            [12] = "Ether Shield",
            [13] = "Shield of Maelin",
            [14] = "Shield of the Arcane",
            [15] = "Shield of the Magi",
            [16] = "Arch Shielding",
            [17] = "Greater Shielding",
            [18] = "Major Shielding",
            [19] = "Shielding",
            [20] = "Lesser Shielding",
            [21] = "Minor Shielding",
        },
        ['FamiliarBuff'] = {
            [1] = "Greater Familiar",
            [2] = "Familiar",
            [3] = "Lesser Familiar",
            [4] = "Minor Familiar",
        },
        ['SelfRune1'] = {
            [1] = "Aegis of Remembrance",
            [2] = "Aegis of the Umbra",
            [3] = "Aegis of the Crystalwing",
            [4] = "Armor of Wirn",
            [5] = "Armor of the Codex",
            [6] = "Armor of the Stonescale",
            [7] = "Armor of the Crystalwing",
            [8] = "Dermis of the Crystalwing",
            [9] = "Squamae of the Crystalwing",
            [10] = "Laminae of the Crystalwing",
            [11] = "Scales of the Crystalwing",
            [12] = "Ether Skin",
            [13] = "Force Shield",
        },
        ['StripBuffSpell'] = {
            [1] = "Annul Magic",
            [2] = "Nullify Magic",
            [3] = "Cancel Magic",
        },
        ['TwincastSpell'] = {
            [1] = "Twincast",
        },
        ['GambitSpell'] = {
            [1] = "Anodyne Gambit",
            [2] = "Idyllic Gambit",
            [3] = "Musing Gambit",
            [4] = "Quiescent Gambit",
            [5] = "Bucolic Gambit",
        },
        ['PetSpell'] = {
            [1] = "Kindleheart's Pyroblade",
            [2] = "Diabo Xi Fer's Pyroblade",
            [3] = "Ricartine's Pyroblade",
            [4] = "Virnax's Pyroblade",
            [5] = "Yulin's Pyroblade",
            [6] = "Mul's Pyroblade",
            [7] = "Burnmaster's Pyroblade",
            [8] = "Lithara's Pyroblade",
            [9] = "Daveron's Pyroblade",
            [10] = "Euthanos' Flameblade",
            [11] = "Ethantis's Burning Blade",
            [12] = "Solist's Frozen Sword",
            [13] = "Flaming Sword of Xuzl",
        },
        ['RootSpell'] = {
            [1] = "Greater Fetter",
            [2] = "Fetter",
            [3] = "Paralyzing Earth",
            [4] = "Immobilize",
            [5] = "Instill",
            [6] = "Root",
        },
        ['SnareSpell'] = {
            [1] = "Atol's Concussive Shackles",
            [2] = "Atol's Spectral Shackles",
            [3] = "Bonds of Force",
        },
        ['EvacSpell'] = {
            [1] = "Evacuate",
            [2] = "Lesser Evacuate",
        },
        ['HarvestSpell'] = {
            [1] = "Contemplative Harvest",
            [2] = "Shadow Harvest",
            [3] = "Quiet Harvest",
            [4] = "Musing Harvest",
            [5] = "Quiescent Harvest",
            [6] = "Bucolic Harvest",
            [7] = "Placid Harvest",
            [8] = "Soothing Harvest",
            [9] = "Serene Harvest",
            [10] = "Tranquil Harvest",
            [11] = "Patient Harvest",
            [12] = "Harvest",
        },
        ['JoltSpell'] = {
            [1] = "Spinalfreeze",
            [2] = "Cerebrumfreeze",
            [3] = "Neurofreeze",
            [4] = "Cortexfreeze",
            [5] = "Synapsefreeze",
            [6] = "Flashfreeze",
            [7] = "Skullfreeze",
            [8] = "Thoughtfreeze",
            [9] = "Brainfreeze",
            [10] = "Mindfreeze",
            [11] = "Concussive Flash",
            [12] = "Concussive Burst",
            [13] = "Concussive Blast",
            [14] = "Ancient: Greater Concussion",
            [15] = "Concussion",
        },
        -- Lure Spells
        ['IceLureNuke'] = {
            [1] = "Lure of Frost",
            [2] = "Lure of Ice",
            [3] = "Icebane",
            [4] = "Rimelure",
            [5] = "Voidfrost Lure",
            [6] = "Glacial Lure",
            [7] = "Frigid Lure",
            [8] = "Lure of Isaz",
            [9] = "Lure of the Wastes",
            [10] = "Lure of the Depths",
            [11] = "Lure of Travenro",
            [12] = "Lure of Restless Ice",
            [13] = "Lure of the Cold Moon",
            [14] = "Lure of Winter Memories",
        },
        ['FireLureNuke'] = {
            [1] = "Enticement of Flame",
            [2] = "Lure of Flame",
            [3] = "Lure of Ro",
            [4] = "Firebane",
            [5] = "Lavalure",
            [6] = "Pyrolure",
            [7] = "Flarelure",
            [8] = "Flamelure",
            [9] = "Blazelure",
            [10] = "MagmaLure",
            [11] = "PlasmaLure",
            [12] = "Lure of Qunard",
            [13] = "Lure of Sontalak",
            [14] = "Lure of Fyrthek",
            [15] = "Lure of the Arcanaforged",
        },
        ['MagicLureNuke'] = {
            [1] = "Lure of Lightning",
            [2] = "Lure of Thunder",
            [3] = "Lightningbane",
            [4] = "Permeating Ether",
        },
        -- Fast Nukes
        ['FastIceNuke'] = {
            [1] = "Draught of Ice",
            [2] = "Frost Shock",
            [3] = "Shock of Ice",
            [4] = "Draught of E`ci",
            [5] = "Black Ice",
            [7] = "Spark of Ice",
        },
        ['FastFireNuke'] = {
            [1] = "Shock of Fire",
            [2] = "Flame Shock",
            [3] = "Inferno Shock",
            [4] = "Draught of Fire",
            [5] = "Draught of Ro",
            [6] = "Chaos Flame",
            [7] = "Spark of Fire",
        },
        ['FastMagicNuke'] = {
            [1] = "Voltaic Draught",
            [2] = "Draught of Lightning",
            [3] = "Spark of Lightning",
            [4] = "Leap of Stormjolts",
            [5] = "Leap of Stormbolts",
            [6] = "Leap of Static Sparks",
            [7] = "Leap of Plasma",
            [8] = "Leap of Corposantum",
            [9] = "Leap of Static Jolts",
            [10] = "Leap of Static Bolts",
            [11] = "Leap of Sparks",
            [12] = "Leap of Levinsparks",
        },
        -- Rain Spells Listed here are used Primarily for TLP Mode.
        -- Magic Rain - Only have 3 of them so Not Sustainable.
        ['IceRainNuke'] = {
            [1] = "Icestrike",
            [2] = "Frost Storm",
            [3] = "Tears of Prexus",
            [4] = "Tears of Marr",
            [5] = "Gelid Rains",
            [6] = "Icicle Deluge",
            [7] = "Icicle Storm",
            [8] = "Icicle Torrent",
            [9] = "Hail Torrent",
            [10] = "Frost Torrent",
            [11] = "Tamagrist Torrent",
            [12] = "Darkwater Torrent",
            [13] = "Frostbite Torrent",
            [14] = "Coldburst Torrent",
            [15] = "Hypothermic Torrent",
            [16] = "Rimeclaw Torrent",
        },
        ['FireRainNuke'] = {
            [1] = "Firestorm",
            [2] = "Lava Storm",
            [3] = "Tears of Solusek",
            [4] = "Tears of Ro",
            [5] = "Tears of the Sun",
            [6] = "Tears of the Betrayed",
            [7] = "Tears of the Forsaken",
            [8] = "Tears of the Pyrilen",
            [9] = "Tears of Flame",
            [10] = "Tears of Daevan",
            [11] = "Tears of Gosik",
            [12] = "Tears of Narendi",
            [13] = "Tears of Dragoflux",
            [14] = "Tears of Wildfire",
            [15] = "Tears of Night Fire",
            [16] = "Tears of the Rescued",
        },
        ['FireRainLureNuke'] = {
            [1] = "Volcanic Burst",
            [2] = "Tears of Arlyxir",
            [3] = "Meteor Storm",
            [4] = "Volcanic Eruption",
            [5] = "Pyroclastic Eruption",
            [6] = "Magmatic Eruption",
            [7] = "Magmatic Downpour",
            [8] = "Magmatic Outburst",
            [9] = "Magmatic Vent",
            [10] = "Magmatic Burst",
            [11] = "Magmatic Explosion",
            [12] = "Volcanic Downpour",
            [13] = "Volcanic Barrage",
        },
        -- Large 8 Second Cast Nukes
        ['BigIceNuke'] = {
            -- Big Ice Nukes  50-69
            [1] = "Ice Comet",
            [2] = "Ice Spear of Solist",
            [3] = "Ancient: Destruction of Ice",
            [4] = "Ice Meteor",
            [5] = "Gelidin Comet",
        },
        ['BigFireNuke'] = {
            -- Big Fire Nukes
            [1] = "Conflagration",
            [2] = "Sunstrike",
            [3] = "Garrison's Superior Sundering",
            [4] = "Strike of Solusek",
            [5] = "White Fire",
            [6] = "Ether Flame",
            [7] = "Corona Flare",
        },
        ['BigMagicNuke'] = {
            -- Big Magic Nukes
            [1] = "Rend",
            [2] = "Elnerick's Electrical Rending",
            [3] = "Agnarr's Thunder",
            [4] = "Shock of Magic",
            [5] = "Thundaka",
            [6] = "Mana Weave",
        },
    },

    ['ChatBegList']   = {
        ['WizBegs'] = {
            ['bindme'] = {
                ['spell'] = "Bind Affinity",
                ['sender'] = true,
            },
            ['gatenorth'] = {
                ['spell'] = "North Gate",
                ['sender'] = true,
            },
            ['gatefay'] = {
                ['spell'] = "Fay Gate",
                ['sender'] = true,
            },
            ['portalnorth'] = {
                ['spell'] = "North Portal",
                ['sender'] = true,
            },
            ['portalfay'] = {
                ['spell'] = "Fay Portal",
                ['sender'] = true,
            },
            ['portallcea'] = {
                ['spell'] = {
                    "Lceanium Portal",
                    ['sender'] = true,
                },
            },
        },
    },
    ['Rotations']     = {
        ['Burn'] = {},

        --        |- AA Burn Section
        --/call AddToRotation "${rotation_name}" "Arcane Whisper" AA            ${Parse[0,"( BURNCHECK && ${Target.PctHPs}>10 )"]}
        --/call AddToRotation "${rotation_name}" "Silent Casting" AA            ${Parse[0,"( BURNCHECK )"]}
        --/call AddToRotation "${rotation_name}" "Arcane Destruction" AA        ${Parse[0,"( !${Me.Song[Frenzied Devastation].ID} && BURNCHECK )"]}
        --/call AddToRotation "${rotation_name}" "Arcane Fury" AA               ${Parse[0,"( (BURNCHECK && !${Me.Song[Chromatic Haze].ID} && !${Me.Song[Gift of Chromatic Haze].ID} && (${Me.Song[Arcane Destruction].ID} || ${Me.Song[Frenzied Devastation].ID})))"]}
        --/call AddToRotation "${rotation_name}" "Improved Twincast" AA         ${Parse[0,"( (BURNCHECK && !${Me.Buff[Twincast].ID}) )"]}
        --/call AddToRotation "${rotation_name}" "Mana Burn" AA                 ${Parse[0,"( (BURNCHECK && ${Target.BuffsPopulated} && !${Target.Buff[Mana Burn].ID}) && ${DoManaBurn[SETTINGVAL]} )"]}

        ['Debuff'] = {},
        ['Heal'] = {},
        ['DPS'] = {
            [1] = {
                name = "Etherealist's Unity",
                type = "AA",
                active_cond = function(self) return mq.TLO.Me.FindBuff("id " .. tostring(mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).ID()))() ~= nil end,
                cond = function(self)
                    local selfHPBuff = RGMercModules:execModule("Class", "GetResolvedActionMapItem", "SelfHPBuff")
                    return not selfHPBuff() or
                        (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) > selfHPBuff.Level() and RGMercUtils.SelfBuffAACheck("Etherealist's Unity")
                end,
            },
            [2] = {
                name = "A Hole in Space",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > 99 and RGMercUtils.IHaveAggro()
                end,
            },
            [3] = {
                name = "Mind Crash",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > 85
                end,
            },
            [4] = {
                name = "Concussion",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > self.settings.JoltAggro
                end,
            },
            [5] = {
                name = "JoltSpell",
                type = "Spell",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > self.settings.JoltAggro
                end,
            },
            [6] = {
                name = "SelfRune1",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            [7] = {
                name = "GambitSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() < RGMercConfig:GetSettings().ModRodManaPct
                end,
            },
            [8] = {
                name = "FuseNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.DetGOMCheck(spell)
                end,
            },
            [9] = {
                name = "FireEtherealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.DetGOMCheck(spell)
                end,
            },
            [10] = {
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.DetGOMCheck(spell)
                end,
            },
            [11] = {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.DetGOMCheck(spell)
                end,
            },
            [12] = {
                name = "CloudburstNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.DetGambitCheck() or ((mq.TLO.Me.Song("Evoker's Synergy I").ID() or 0) > 0)
                end,
            },
            [13] = {
                name = "WildNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.DetGambitCheck()
                end,
            },
            [14] = {
                name = "ChaosNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.DetGambitCheck()
                end,
            },
            [15] = {
                name = "TwincastSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Buff("Twincast").ID() == 0
                end,
            },
            [16] = {
                name = "VortexNuke",
                type = "Spell",
                cond = function(self, spell)
                    return not RGMercUtils.TargetHasBuff(spell)
                end,
            },
            [17] = {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return not RGMercUtils.DetGambitCheck() and mq.TLO.Me.Buff("Twincast").ID() == 0 and not mq.TLO.Me.FindBuff("name Improved Twincast")
                end,
            },
            [18] = {
                name = "FireClaw",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.ManaCheck()
                end,
            },
            [19] = {
                name = "FuseNuke",
                type = "Spell",
                cond = function(self, spell)
                    local fireClaw = RGMercModules:execModule("Class", "GetResolvedActionMapItem", "FireClaw")
                    return not RGMercUtils.DetGambitCheck() and (not fireClaw or not fireClaw() or not mq.TLO.Me.SpellReady(fireClaw.RankName()))
                end,
            },
            [20] = {
                name = "FireNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.ManaCheck() and not RGMercUtils.DetGambitCheck()
                end,
            },
            [21] = {
                name = "IceNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.ManaCheck() and not RGMercUtils.DetGambitCheck()
                end,
            },
            [22] = {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.ManaCheck() and not RGMercUtils.DetGambitCheck()
                end,
            },
            [23] = {
                name = "FastMagicNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.ManaCheck()
                end,
            },
            [24] = {
                name = "Force of Flame",
                type = "AA",
                cond = function(self)
                    return self.settings.WeaveAANukes and not mq.TLO.Me.SpellInCooldown() and not RGMercUtils.AAReady("Force of Ice") and not RGMercUtils.AAReady("Force of Will")
                end,
            },
            [25] = {
                name = "Force of Ice",
                type = "AA",
                cond = function(self)
                    return self.settings.WeaveAANukes and not mq.TLO.Me.SpellInCooldown() and RGMercUtils.AAReady("Force of Flame")
                end,
            },
            [26] = {
                name = "Force of Will",
                type = "AA",
                cond = function(self)
                    return self.settings.WeaveAANukes and not mq.TLO.Me.SpellInCooldown() and not RGMercUtils.AAReady("Force of Ice") and not RGMercUtils.AAReady("Force of Flame")
                end,
            },
        },
        ['Downtime'] = {
            [1] = {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.RankName.ID()))() ~= nil end,
                cond = function(self, spell)
                    return (spell.Level() or 0) > (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) and RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            [2] = {
                name = "Etherealist's Unity",
                type = "AA",
                active_cond = function(self) return mq.TLO.Me.FindBuff("id " .. tostring(mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).ID()))() ~= nil end,
                cond = function(self)
                    local selfHPBuff = RGMercModules:execModule("Class", "GetResolvedActionMapItem", "SelfHPBuff")
                    return not selfHPBuff() or
                        (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) > selfHPBuff.Level() and RGMercUtils.SelfBuffAACheck("Etherealist's Unity")
                end,
            },
            [3] = {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.RankName.ID()))() ~= nil end,
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            [4] = {
                name = "FamiliarBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.RankName.ID()))() ~= nil end,
                cond = function(self, spell)
                    return spell.Stacks() and spell.Level() > (mq.TLO.Me.AltAbility("Improved Familiar").Spell.Level() or 0) and
                        mq.TLO.Me.FindBuff("id " .. tostring(spell.RankName.ID()))() == nil
                end,
            },
            [5] = {
                name = "Improved Familiar",
                type = "AA",
                active_cond = function(self) return mq.TLO.Me.FindBuff("id " .. tostring(mq.TLO.Me.AltAbility("Improved Familiar").Spell.ID()))() ~= nil end,
                cond = function(self)
                    local familiarBuff = RGMercModules:execModule("Class", "GetResolvedActionMapItem", "FamiliarBuff")
                    return not familiarBuff() or
                        (mq.TLO.Me.AltAbility("Improved Familiar").Spell.Level() or 0) > familiarBuff.Level() and RGMercUtils.SelfBuffAACheck("Improved Familiar")
                end,
            },
            [6] = {
                name = "Harvest of Druzzil",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctMana() < RGMercConfig:GetSettings().ModRodManaPct and RGMercUtils.AAReady("Harvest of Druzzil")
                end,
            },
            [7] = {
                name = "HarvestSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() < RGMercConfig:GetSettings().ModRodManaPct and mq.TLO.Me.SpellReady(spell.RankName())
                end,
            },
            [8] = {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return item() and mq.TLO.Me.Song(item.Spell.RankName())() ~= nil
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return self.settings.DoChestClick and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
            [9] = {
                name = RGMercConfig:GetSettings().ClarityPotion,
                type = "Item",
                cond = function(self)
                    local item = mq.TLO.FindItem(RGMercConfig:GetSettings().ClarityPotion)
                    return item() and item.Spell.Stacks() and item.TimerReady()
                end,
            },
        },
    },
    ['Spells']        = {
        [1] = {
            gem = 1,
            spells = {
                [1] = { name = string.format("%sClaw", RGMercModules:execModule("Class", "GetClassModeName")), },
                [2] = { name = "StunSpell", },
            },
        },
        [2] = {
            gem = 2,
            spells = {
                [1] = { name = string.format("%sEtherealNuke", RGMercModules:execModule("Class", "GetClassModeName")), },
                [2] = { name = string.format("%sNuke", RGMercModules:execModule("Class", "GetClassModeName")), },
                [3] = { name = "FireEtherealNuke", },
                [4] = { name = "FireNuke", },
            },
        },
        [3] = {
            gem = 3,
            spells = {
                [1] = { name = "DichoSpell", },
                [2] = {
                    name = "MagicNuke",
                    cond = function(self)
                        return RGMercModules:execModule("Class", "GetClassModeName") ~= "Magic" -- Magic mode will put this elsewhere so load an ice nuke.
                    end,
                },
                [3] = { name = "IceNuke", },
            },
        },
        [4] = {
            gem = 4,
            spells = {
                [1] = { name = "FuseNuke", },
                [2] = {
                    name = "IceNuke",
                    cond = function(self)
                        return RGMercModules:execModule("Class", "GetClassModeName") == "Fire" or RGMercModules:execModule("Class", "GetClassModeName") == "Combo"
                    end,
                },
                [3] = {
                    name = "FireNuke",
                    cond = function(self)
                        return RGMercModules:execModule("Class", "GetClassModeName") == "Ice" or RGMercModules:execModule("Class", "GetClassModeName") == "Magic"
                    end,
                },
            },
        },
        [5] = { gem = 5, spells = { [1] = { name = "TwincastSpell", }, [2] = { name = "StunSpell", }, [3] = { name = "SnareSpell", }, [4] = { name = "RootSpell", }, }, },
        [6] = { gem = 6, spells = { [1] = { name = "GambitSpell", }, [2] = { name = "HarvestSpell", }, }, },
        [7] = { gem = 7, cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end, spells = { [1] = { name = "VortexNuke", }, [2] = { name = "FastMagicNuke", }, }, },
        [8] = { gem = 8, cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end, spells = { [1] = { name = "JoltSpell", }, }, },
        [9] = {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                [1] = {
                    name = "PetSpell",
                    cond = function(self) return mq.TLO.Me.Level() < 79 end,
                },
                [2] = {
                    name = "IceEtherealNuke",
                    cond = function(self)
                        return RGMercModules:execModule("Class", "GetClassModeName") ~= "Ice" -- Ice will load this elsewhere.
                    end,
                },
                [3] = {
                    name = "MagicEtherealNuke",
                },
            },
        },
        [10] = { gem = 10, cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end, spells = { [1] = { name = "FireRainLureNuke", }, }, },
        [11] = { gem = 11, cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end, spells = { [1] = { name = "ChaosNuke", }, }, },
        [12] = { gem = 12, cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end, spells = { [1] = { name = "CloudburstNuke", }, [2] = { name = "FireNuke", }, }, },
        [13] = { gem = 13, cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end, spells = { [1] = { name = "FireNuke", }, [2] = { name = "IceNuke", }, [3] = { name = "MagicNuke", }, [4] = { name = "RootSpell", }, }, },
    },
    ['DefaultConfig'] = {
        ['Mode']         = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 4, },
        ['DoChestClick'] = { DisplayName = "Do Check Click", Category = "Utilities", Tooltip = "Click your chest item", Default = true, },
        ['JoltAggro']    = { DisplayName = "Jolt Aggro Pct", Category = "Combat", Tooltip = "Aggro at which to use Jolt", Default = 65, Min = 1, Max = 100, },
        ['WeaveAANukes'] = { DisplayName = "Weave AA Nukes", Category = "Combat", Tooltip = "Weave in AA Nukes", Default = true, },
    },
}
