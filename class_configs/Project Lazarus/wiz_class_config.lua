-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

local mq        = require('mq')
local Config    = require('utils.config')
local Modules   = require("utils.modules")
local Comms     = require("utils.comms")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")

return {
    _version         = "1.0 - Project Lazarus",
    _author          = "Derple",
    ['Modes']        = {
        'Combo',
        'Fire',
        'Ice',
        'Magic',
    },
    ['OnModeChange'] = function(self, mode)
        -- if this is enabled the weaves will break.
        Config:GetSettings().WaitOnGlobalCooldown = false
    end,
    ['ItemSets']     = {
        ['Epic'] = {
            "Staff of Phenomenal Power",
            "Staff of Prismatic Power",
        },
    },
    ['AbilitySets']  = {
        ['AllianceSpell'] = {
            "Malarian Mantle",
            "Frostbound Conjunction",
            "Frostbound Coalition",
            "Frostbound Covenant",
            "Frostbound Alliance",
        },
        ['DichoSpell'] = {
            "Ecliptic Fire",
            "Composite Fire",
            "Dissident Fire",
            "Dichotomic Fire",
        },
        ['ComboClaw'] = {
            -- only here so that the loader does not complain
        },
        ['ComboNuke'] = {
            -- only here so that the loader does not complain
        },
        ['ComboEtherealNuke'] = {
            -- only here so that the loader does not complain
        },
        ['IceClaw'] = {
            "Claw of the Void",
            "Claw of Gozzrem",
            "Claw of Travenro",
            "Claw of the Oceanlord",
            "Claw of the Icewing",
            "Claw of the Abyss",
            "Glacial Claw",
            "Claw of Selig",
            "Claw of Selay",
            "Claw of Vox",
            "Claw of Frost",
            "Claw of Ankexfen",
        },
        ['FireClaw'] = {
            "Claw of the Duskflame",
            "Claw of Sontalak",
            "Claw of Qunard",
            "Claw of the Flameweaver",
            "Claw of the Flamewing",
            "Claw of Ingot",
        },
        ['MagicClaw'] = {
            "Claw of Itzal",
            "Claw of Feshlak",
            "Claw of Ellarr",
            "Claw of the Indagatori",
            "Claw of the Ashwing",
            "Claw of the Battleforged",
        },
        ['CloudburstNuke'] = {
            "Cloudburst Lightningstrike",
            "Cloudburst Joltstrike",
            "Cloudburst Stormbolt",
            "Cloudburst Thunderbolt",
            "Cloudburst Stormstrike",
            "Cloudburst Thunderbolt",
            "Cloudburst Tempest",
            "Cloudburst Storm",
            "Cloudburst Levin",
            "Cloudburst Bolts",
            "Cloudburst Strike",
        },
        ['FuseNuke'] = {
            "Ethereal Twist",
            "Ethereal Confluence",
            "Ethereal Braid",
            "Ethereal Fuse",
            "Ethereal Weave",
            "Ethereal Plait",
        },
        ['FireEtherealNuke'] = {
            "Ethereal Immolation",
            "Ethereal Ignition",
            "Ethereal Brand",
            "Ethereal Skyfire",
            "Ethereal Skyblaze",
            "Ethereal Incandescence",
            "Ethereal Blaze",
            "Ethereal Inferno",
            "Ethereal Combustion",
            "Ethereal Incineration",
            "Ethereal Conflagration",
            "Ether Flame",
        },
        ['IceEtherealNuke'] = {
            "Lunar Ice Comet",
            "Restless Ice Comet",
            "Ethereal Icefloe",
            "Ethereal Rimeblast",
            "Ethereal Hoarfrost",
            "Ethereal Frost",
            "Ethereal Glaciation",
            "Ethereal Iceblight",
            "Ethereal Rime",
            "Ethereal Freeze",
        },
        ['MagicEtherealNuke'] = {
            "Ethereal Mortar",
            "Ethereal Blast",
            "Ethereal Volley",
            "Ethereal Flash",
            "Ethereal Salvo",
            "Ethereal Barrage",
            "Ethereal Blitz",
        },
        ['ChaosNuke'] = {
            "Chaos Flame",
            "Chaos Inferno",
            "Chaos Burn",
            "Chaos Scintillation",
            "Chaos Incandescence",
            "Chaos Blaze",
            "Chaos Char",
            "Chaos Conflagration",
            "Chaos Immolation",
            "Chaos Flame",
        },
        ['VortexNuke'] = {
            -- NOTE: ${Spell[${VortexNuke}].ResistType} can be used to determine which resist type is getting debuffed
            "Shadebright Vortex",
            "Thaumaturgic Vortex",
            "Stormjolt Vortex",
            "Shocking Vortex",
            -- Hoarfrost Vortex has a Fire Debuff
            "Hoarfrost Vortex",
            -- Ether Vortex has a Cold Debuff
            "Ether Vortex",
            -- Incandescent Vortex has a Magic Debuff
            "Incandescent Vortex",
            -- Frost Vortex has a Fire Debuff
            "Frost Vortex",
            -- Power Vortex has a Cold Debuff
            "Power Vortex",
            -- Flame Vortex has a Magic Debuff
            "Flame Vortex",
            -- Ice Vortex has a Fire Debuff
            "Ice Vortex",
            -- Mana Vortex has a Cold Debuff
            "Mana Vortex",
            -- Fire Vortex has a Magic Debuff
            "Fire Vortex",
        },
        ['WildNuke'] = {
            "Wildspell Strike",
            "Wildflame Strike",
            "Wildscorch Strike",
            "Wildflash Strike",
            "Wildflash Barrage",
            "Wildether Barrage",
            "Wildspark Barrage",
            "Wildmana Barrage",
            "Wildmagic Blast",
            "Wildmagic Burst",
            "Wildmagic Strike",
        },
        ['FireNuke'] = {
            "Kindleheart's Fire",
            "The Diabo's Fire",
            "Dagarn's Fire",
            "Dragoflux's Fire",
            "Narendi's Fire",
            "Gosik's Fire",
            "Daevan's Fire",
            "Lithara's Fire",
            "Klixcxyk's Fire",
            "Inizen's Fire",
            "Sothgar's Flame",
            "Corona Flare",
            "White Fire",
            "Garrison's Superior Sundering",
            "Conflagration",
            "Inferno Shock",
            "Flame Shock",
            "Fire Bolt",
            "Shock of Fire",
        },
        ['IceNuke'] = {
            "Glacial Ice Cascade",
            "Tundra Ice Cascade",
            "Restless Ice Cascade",
            "Icefloe Cascade",
            "Rimeblast Cascade",
            "Hoarfrost Cascade",
            "Rime Cascade",
            "Glacial Cascade",
            "Icesheet Cascade",
            "Glacial Collapse",
            "Icefall Avalanche",
            "Gelidin Comet",
            "Ice Meteor",
            "Ice Spear of Solist",
            "Frozen Harpoon",
            "Ice Comet",
            "Ice Shock",
            "Frost Shock",
            "Shock of Ice",
            "Frost Bolt",
            "Blast of Cold",
        },
        ['MagicNuke'] = {
            "Lightning Cyclone",
            "Lightning Maelstrom",
            "Lightning Roar",
            "Lightning Tempest",
            "Lightning Storm",
            "Lightning Squall",
            "Lightning Swarm",
            "Lightning Helix",
            "Ribbon Lightning",
            "Rolling Lightning",
            "Ball Lightning",
            "Spark of Lightning",
            "Draught of Lightning",
            "Elnerick's Electrical Rending",
            "Draught of Jiva",
            "Voltaic Draught",
            "Rend",
            "Lightning Shock",
            "Thunder Strike",
            "Garrison's Mighty Mana Shock",
            "Lightning Bolt",
            "Shock of Lightning",
        },
        ['StunSpell'] = {
            "Teladaka",
            "Teladaja",
            "Telajaga",
            "Telanata",
            "Telanara",
            "Telanaga",
            "Telanama",
            "Telakama",
            "Telajara",
            "Telajasz",
            "Telakisz",
            "Telekara",
            "Telaka",
            "Telekin",
            "Markar's Discord",
            "Markar's Clash",
            "Tishan's Clash",
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
            "Minor Shielding",
        },
        ['FamiliarBuff'] = {
            "Greater Familiar",
            "Familiar",
            "Lesser Familiar",
            "Minor Familiar",
        },
        ['MeleeGuard'] = {
            "Shield of Inescapability",
            "Shield of Inevitability",
            "Shield of Destiny",
            "Shield of Order",
            "Shield of Consequence",
            "Shield of Fate",
        },
        ['SelfRune1'] = {
            "Mail of the Crystalwing",
            "Scales of the Crystalwing",
            "Aegis of the Crystalwing",
            "Armor of Wirn",
            "Armor of the Codex",
            "Armor of the Stonescale",
            "Armor of the Crystalwing",
            "Dermis of the Crystalwing",
            "Squamae of the Crystalwing",
            "Laminae of the Crystalwing",
            "Scales of the Crystalwing",
            "Ether Skin",
            "Force Shield",
        },
        ['StripBuffSpell'] = {
            "Annul Magic",
            "Nullify Magic",
            "Cancel Magic",
        },
        ['TwincastSpell'] = {
            "Twincast",
        },
        ['GambitSpell'] = {
            "Anodyne Gambit",
            "Idyllic Gambit",
            "Musing Gambit",
            "Quiescent Gambit",
            "Bucolic Gambit",
        },
        ['PetSpell'] = {
            "Kindleheart's Pyroblade",
            "Diabo Xi Fer's Pyroblade",
            "Ricartine's Pyroblade",
            "Virnax's Pyroblade",
            "Yulin's Pyroblade",
            "Mul's Pyroblade",
            "Burnmaster's Pyroblade",
            "Lithara's Pyroblade",
            "Daveron's Pyroblade",
            "Euthanos' Flameblade",
            "Ethantis's Burning Blade",
            "Solist's Frozen Sword",
            "Flaming Sword of Xuzl",
        },
        ['RootSpell'] = {
            "Greater Fetter",
            "Fetter",
            "Paralyzing Earth",
            "Immobilize",
            "Instill",
            "Root",
        },
        ['SnareSpell'] = {
            "Atol's Concussive Shackles",
            "Atol's Spectral Shackles",
            "Bonds of Force",
        },
        ['EvacSpell'] = {
            "Evacuate",
            "Lesser Evacuate",
        },
        ['HarvestSpell'] = {
            "Contemplative Harvest",
            "Shadow Harvest",
            "Quiet Harvest",
            "Musing Harvest",
            "Quiescent Harvest",
            "Bucolic Harvest",
            "Placid Harvest",
            "Soothing Harvest",
            "Serene Harvest",
            "Tranquil Harvest",
            "Patient Harvest",
            "Harvest",
        },
        ['JoltSpell'] = {
            "Spinalfreeze",
            "Cerebrumfreeze",
            "Neurofreeze",
            "Cortexfreeze",
            "Synapsefreeze",
            --"Flashfreeze", This is not a jolt, it is an instant nuke that we don't use/have a table for.
            "Skullfreeze",
            "Thoughtfreeze",
            "Brainfreeze",
            "Mindfreeze",
            "Concussive Flash",
            "Concussive Burst",
            "Concussive Blast",
            "Ancient: Greater Concussion",
            "Concussion",
        },
        -- Lure Spells
        ['IceLureNuke'] = {
            "Lure of Frost",
            "Lure of Ice",
            "Icebane",
            "Rimelure",
            "Voidfrost Lure",
            "Glacial Lure",
            "Frigid Lure",
            "Lure of Isaz",
            "Lure of the Wastes",
            "Lure of the Depths",
            "Lure of Travenro",
            "Lure of Restless Ice",
            "Lure of the Cold Moon",
            "Lure of Winter Memories",
        },
        ['FireLureNuke'] = {
            "Enticement of Flame",
            "Lure of Flame",
            "Lure of Ro",
            "Firebane",
            "Lavalure",
            "Pyrolure",
            "Flarelure",
            "Flamelure",
            "Blazelure",
            "MagmaLure",
            "PlasmaLure",
            "Lure of Qunard",
            "Lure of Sontalak",
            "Lure of Fyrthek",
            "Lure of the Arcanaforged",
        },
        ['MagicLureNuke'] = {
            "Lure of Lightning",
            "Lure of Thunder",
            "Lightningbane",
            "Permeating Ether",
        },
        -- Fast Nukes
        ['FastIceNuke'] = {
            "Draught of Ice",
            "Frost Shock",
            "Shock of Ice",
            "Draught of E`ci",
            "Black Ice",
            "Spark of Ice",
        },
        ['FastFireNuke'] = {
            "Shock of Fire",
            "Flame Shock",
            "Inferno Shock",
            "Draught of Fire",
            "Draught of Ro",
            "Chaos Flame",
            "Spark of Fire",
        },
        ['FastMagicNuke'] = {
            "Voltaic Draught",
            "Draught of Lightning",
            "Spark of Lightning",
            "Leap of Stormjolts",
            "Leap of Stormbolts",
            "Leap of Static Sparks",
            "Leap of Plasma",
            "Leap of Corposantum",
            "Leap of Static Jolts",
            "Leap of Static Bolts",
            "Leap of Sparks",
            "Leap of Levinsparks",
        },
        -- Rain Spells Listed here are used Primarily for TLP Mode.
        -- Magic Rain - Only have 3 of them so Not Sustainable.
        ['IceRainNuke'] = {
            "Icestrike",
            "Frost Storm",
            "Tears of Prexus",
            "Tears of Marr",
            "Gelid Rains",
            "Icicle Deluge",
            "Icicle Storm",
            "Icicle Torrent",
            "Hail Torrent",
            "Frost Torrent",
            "Tamagrist Torrent",
            "Darkwater Torrent",
            "Frostbite Torrent",
            "Coldburst Torrent",
            "Hypothermic Torrent",
            "Rimeclaw Torrent",
        },
        ['FireRainNuke'] = {
            "Firestorm",
            "Lava Storm",
            "Tears of Solusek",
            "Tears of Ro",
            "Tears of the Sun",
            "Tears of the Betrayed",
            "Tears of the Forsaken",
            "Tears of the Pyrilen",
            "Tears of Flame",
            "Tears of Daevan",
            "Tears of Gosik",
            "Tears of Narendi",
            "Tears of Dragoflux",
            "Tears of Wildfire",
            "Tears of Night Fire",
            "Tears of the Rescued",
        },
        ['FireRainLureNuke'] = {
            "Volcanic Burst",
            "Tears of Arlyxir",
            "Meteor Storm",
            "Volcanic Eruption",
            "Pyroclastic Eruption",
            "Magmatic Eruption",
            "Magmatic Downpour",
            "Magmatic Outburst",
            "Magmatic Vent",
            "Magmatic Burst",
            "Magmatic Explosion",
            "Volcanic Downpour",
            "Volcanic Barrage",
        },
        -- Large 8 Second Cast Nukes
        ['BigIceNuke'] = {
            -- Big Ice Nukes  50-69
            "Ice Comet",
            "Ice Spear of Solist",
            "Ancient: Destruction of Ice",
            "Ice Meteor",
            "Gelidin Comet",
        },
        ['BigFireNuke'] = {
            -- Big Fire Nukes
            "Conflagration",
            "Sunstrike",
            "Garrison's Superior Sundering",
            "Strike of Solusek",
            "White Fire",
            "Ether Flame",
            "Corona Flare",
        },
        ['BigMagicNuke'] = {
            -- Big Magic Nukes
            "Rend",
            "Elnerick's Electrical Rending",
            "Agnarr's Thunder",
            "Shock of Magic",
            "Thundaka",
            "Mana Weave",
        },
    },
    ['ChatBegList']  = {
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
    --[[['CommandHandlers']   = {
        wizevac = {
            usage = "/rgl wizevac",
            about = "Cause wizard to cast an evac AA or spell",
            handler =
                function(self)
                    local evacSpells = {'Exodus', 'Evacuate', 'Lesser Evacuate'}
                    local portName = ''
                    local me = mq.TLO.Me


                    for _, port in ipairs(evacSpells) do
                        if me.Class.Name() == 'Wizard' and me.Level()>= 57 and port == 'Evacuate' then
                            portName = port
                            break
                        elseif me.Class.Name() == 'Wizard' and me.Level() >= 18 and port == 'Lesser Evacuate' then
                            portName = port
                            break
                        end
                    end

                    -- Cast the spell. Will report if need to memorize or don't have the spell
                    Core.DoCmd('/if (${Cast.Ready[exodus]}) /cast "exodus" alt')
                    Core.DoCmd('/timed 1 /if (${Me.Book["%s"]}>0) /cast "%s"', portName, portName)
                    Core.DoCmd('/timed 2 /if (!${Me.Book["%s"]}>0) /dgt all Spell not known!', portName)

                    -- Have to memorize
                    Core.DoCmd('/timed 5 /if (${Cast.Status.Equal[CM]}) /timed 5 /dgt all Memorizing "%s"! Ready in 1.5 seconds', portName)
                    Core.DoCmd('/timed 50 /if (${Cast.Timing}>6000) /dgt all Casting -> %s <- in ${Math.Calc[${Cast.Timing}/1000]} seconds!', portName)
                    Core.DoCmd('/timed 90 /if (${Cast.Timing}>4000) /dgt all ${Math.Calc[${Cast.Timing}/1000]} seconds remaining!', portName)

                    -- Already memorized
                    Core.DoCmd('/timed 5 /if (${Cast.Timing}>8000) /dgt all Casting -> %s <- in ${Math.Calc[${Cast.Timing}/1000]} seconds!', portName)
                    Core.DoCmd('/timed 40 /if (${Cast.Timing}>5000) /dgt all ${Math.Calc[${Cast.Timing}/1000]} seconds remaining!', portName)

                    -- Out of mana
                    Core.DoCmd('/timed 5 /if (${Cast.Status.Equal[CAST_OUTOFMANA]}) /dgt all Out of mana! Can\'t Evac!')
                end
        }
    },]]
    ['RotationOrder'] = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    Casting.DoBuffCheck() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck()
            end,
        },
        {
            name = 'Combat Buffs',
            state = 1,
            steps = 1,
            timer = 30, -- only run every 30 seconds at most.
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state ==
                    "Combat"
            end,
        },
        {
            name = 'Aggro Management',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state ==
                    "Combat"
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Config:GetSetting('WeaveAANukes') and mq.TLO.Me.SpellInCooldown()
            end,
        },
        {
            name = 'Gift of Mana',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and (not Config:GetSetting('DoGOMCheck') or Casting.DetGOMCheck())
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'AoE Rain DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.GetAutoTargetPctHPs() <= Config:GetSetting('RainMinTargetHP') and
                    Targeting.GetXTHaterCount() >= Config:GetSetting('RainMinHaters')
            end,
        },
    },
    ['Rotations']     = {
        ['Burn'] = {
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self)
                    return Targeting.GetTargetPctHPs() > 10
                end,
            },
            {
                name = "Spire of Arcanum",
                type = "AA",
                cond = function(self)
                    return true
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self)
                    return true
                end,
            },
            {
                name = "Arcane Destruction",
                type = "AA",
                cond = function(self)
                    return not Casting.SongActiveByName("Frenzied Devastation")
                end,
            },
            {
                name = "Arcane Fury",
                type = "AA",
                cond = function(self)
                    return (not Casting.SongActiveByName("Chromatic Haze")) and (not Casting.SongActiveByName("Gift of Chromatic Haze")) and
                        ((Casting.SongActiveByName("Arcane Destruction")) or (Casting.SongActiveByName("Frenzied Devastation")))
                end,
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not Casting.BuffActiveByName("Twincast")
                end,
            },
            {
                name = "Mana Burn",
                type = "AA",
                cond = function(self)
                    return not Casting.TargetHasBuffByName("Mana Burn") and Config:GetSetting('DoManaBurn')
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and Casting.AAReady("Harvest of Druzzil")
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and (mq.TLO.Me.GemTimer(spell.RankName.Name())() or -1) == 0
                end,
            },
        },
        ['Agro Management'] =
        {
            {
                name = "A Hole in Space",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > 99 and Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Mind Crash",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > 85
                end,
            },
            {
                name = "Concussion",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > Config:GetSetting('JoltAggro')
                end,
            },
            {
                name = "JoltSpell",
                type = "Spell",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > Config:GetSetting('JoltAggro')
                end,
            },

        },
        ['Combat Buffs'] =
        {
            {
                name = "Etherealist's Unity",
                type = "AA",
                active_cond = function(self, aaName) return Casting.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID()) end,
                cond = function(self, aaName)
                    local selfHPBuff = Modules:ExecModule("Class", "GetResolvedActionMapItem", "SelfHPBuff")
                    local selfHPBuffLevel = selfHPBuff and selfHPBuff() and selfHPBuff.Level() or 0
                    return (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) > selfHPBuffLevel and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "MeleeGuard",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "GambitSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('ModRodManaPct')
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and Casting.AAReady("Harvest of Druzzil")
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and (mq.TLO.Me.GemTimer(spell.RankName.Name())() or -1) == 0
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Force of Ice",
                type = "AA",
                cond = function(self)
                    return Casting.AAReady("Force of Ice")
                end,
            },
            {
                name = "Force of Will",
                type = "AA",
                cond = function(self)
                    return Casting.AAReady("Force of Will")
                end,
            },
            {
                name = "Force of Flame",
                type = "AA",
                cond = function(self)
                    return Casting.AAReady("Force of Flame")
                end,
            },
        },
        ['Gift of Mana'] = {
            {
                name = "FuseNuke",
                type = "Spell",
                cond = function(self, spell)
                    return true
                end,
            },
            {
                name = "FireEtherealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return true
                end,
            },
            {
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return true
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return true
                end,
            },
        },
        ['DPS'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 end,
                cond = function(self, _) return Config:GetSetting('DoPet') and mq.TLO.Me.Pet.ID() == 0 end,
                post_activate = function(self, spell)
                    local pet = mq.TLO.Me.Pet
                    if pet.ID() > 0 then
                        Comms.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(),
                            pet.Class.Name(), pet.CleanName(), spell.RankName())
                    end
                end,
            },
            {
                name = "CloudburstNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.DetGambitCheck() or ((mq.TLO.Me.Song("Evoker's Synergy I").ID() or 0) > 0)
                end,
            },
            {
                name = "WildNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.DetGambitCheck()
                end,
            },
            {
                name = "ChaosNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.DetGambitCheck()
                end,
            },
            {
                name = "TwincastSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Buff("Twincast").ID() == 0
                end,
            },
            {
                name = "VortexNuke",
                type = "Spell",
                cond = function(self, spell)
                    return not Casting.TargetHasBuff(spell)
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return not Casting.DetGambitCheck() and mq.TLO.Me.Buff("Twincast").ID() == 0 and not Casting.BuffActiveByName("Improved Twincast")
                end,
            },
            {
                name = "FireClaw",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "FuseNuke",
                type = "Spell",
                cond = function(self, spell)
                    local fireClaw = Modules:ExecModule("Class", "GetResolvedActionMapItem", "FireClaw")
                    return not Casting.DetGambitCheck() and ((not fireClaw or not fireClaw()) or not mq.TLO.Me.SpellReady(fireClaw.RankName()))
                end,
            },
            {
                name = "FireNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke() and not Casting.DetGambitCheck()
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke() and not Casting.DetGambitCheck()
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke() and not Casting.DetGambitCheck()
                end,
            },
            {
                name = "SnareSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke() and Targeting.GetTargetDistance() > 30 and self.settings.DoSnare
                end,
            },
            {
                name = "FastMagicNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "FuseNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "FireEtherealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
        },
        ['AoE Rain DPS'] = {
            {
                name = "FireRainNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke() and not Casting.DetGambitCheck() and
                        Targeting.GetTargetDistance() >= Config:GetSetting('RainDist')
                end,
            },
            {
                name = "IceRainNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToNuke() and not Casting.DetGambitCheck() and
                        Targeting.GetTargetDistance() >= Config:GetSetting('RainDist')
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return (spell.Level() or 0) > (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Etherealist's Unity",
                type = "AA",
                active_cond = function(self, aaName) return Casting.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID()) end,
                cond = function(self, aaName)
                    local selfHPBuff = Modules:ExecModule("Class", "GetResolvedActionMapItem", "SelfHPBuff")
                    local selfHPBuffLevel = selfHPBuff and selfHPBuff() and selfHPBuff.Level() or 0
                    return (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) > selfHPBuffLevel and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "MeleeGuard",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "FamiliarBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return spell.Stacks() and spell.Level() > (mq.TLO.Me.AltAbility("Improved Familiar").Spell.Level() or 0) and not Casting.BuffActiveByID(spell.RankName.ID())
                end,
            },
            {
                name = "Improved Familiar",
                type = "AA",
                active_cond = function(self, aaName) return Casting.BuffActiveByID(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    local familiarBuff = Modules:ExecModule("Class", "GetResolvedActionMapItem", "FamiliarBuff")
                    local familiarBuffLevel = familiarBuff and familiarBuff() and familiarBuff.Level() or 0
                    return (mq.TLO.Me.AltAbility(aaName).Spell.Level() or 0) > familiarBuffLevel and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and Casting.AAReady("Harvest of Druzzil")
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and (mq.TLO.Me.GemTimer(spell.RankName.Name())() or -1) == 0
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return Casting.BuffActive(item.Spell)
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    if not Config:GetSetting('DoChestClick') or not item or not item() then return false end
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and item.TimerReady() == 0 and Casting.SelfBuffCheck(item.Spell)
                end,
            },
        },
    },
    ['Spells']        = {
        {
            gem = 1,
            spells = {
                { name_func = function(self) return string.format("%sClaw", self:GetClassModeName()) end, },
                { name = "IceClaw", },
                { name = "FireClaw", },
                { name = "MagicClaw", },
                { name = "StunSpell", },
            },
        },
        {
            gem = 2,
            spells = {
                { name_func = function(self) return string.format("%sEtherealNuke", self:GetClassModeName()) end, },
                { name_func = function(self) return string.format("%sNuke", self:GetClassModeName()) end, },
                { name = "FireEtherealNuke", },
                { name = "FireNuke", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "DichoSpell", },
                {
                    name = "MagicNuke",
                    cond = function(self)
                        return Modules:ExecModule("Class", "GetClassModeName") ~= "Magic" -- Magic mode will put this elsewhere so load an ice nuke.
                    end,
                },
                { name = "IceNuke", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "FuseNuke", },
                {
                    name = "FireRainNuke",
                    active_cond = function(self) return self.settings.DoRain end,
                    cond = function(self)
                        return Modules:ExecModule("Class", "GetClassModeName") == "Fire" or Modules:ExecModule("Class", "GetClassModeName") == "Combo"
                    end,
                },
                {
                    name = "IceRainNuke",
                    active_cond = function(self) return self.settings.DoRain end,
                    cond = function(self)
                        return Modules:ExecModule("Class", "GetClassModeName") == "Ice" or Modules:ExecModule("Class", "GetClassModeName") == "Magic"
                    end,
                },
                {
                    name = "IceNuke",
                    cond = function(self)
                        return Modules:ExecModule("Class", "GetClassModeName") == "Fire" or Modules:ExecModule("Class", "GetClassModeName") == "Combo"
                    end,
                },
                {
                    name = "FireNuke",
                    cond = function(self)
                        return Modules:ExecModule("Class", "GetClassModeName") == "Ice" or Modules:ExecModule("Class", "GetClassModeName") == "Magic"
                    end,
                },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "TwincastSpell", },
                { name = "SnareSpell",    cond = function(self) return self.settings.DoSnare end, },
                { name = "StunSpell", },
                { name = "RootSpell", }, },
        },
        { gem = 6, spells = { { name = "GambitSpell", }, { name = "HarvestSpell", }, }, },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = { { name = "VortexNuke", }, { name = "FastMagicNuke", }, },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = { { name = "JoltSpell", }, },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                {
                    name = "PetSpell",
                    cond = function(self) return mq.TLO.Me.Level() < 79 end,
                },
                {
                    name = "IceEtherealNuke",
                    cond = function(self)
                        return Modules:ExecModule("Class", "GetClassModeName") ~= "Ice" -- Ice will load this elsewhere.
                    end,
                },
                {
                    name = "MagicEtherealNuke",
                },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = { { name = "FireRainLureNuke", }, },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = { { name = "ChaosNuke", }, },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = { { name = "CloudburstNuke", }, { name = "FireNuke", }, },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = { { name = "FireNuke", }, { name = "IceNuke", }, { name = "MagicNuke", }, { name = "RootSpell", }, },
        },
    },
    ['DefaultConfig'] = {
        ['Mode']            = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 3,
            Min = 1,
            Max = 4,
            FAQ = "What do the different Modes Do?",
            Answer = "Combo mode is a mix of all 3 types of Nukes,\n" ..
                "Fire mode will focus only on Fire Nukes,\n" ..
                "Ice mode will focus only on Ice Nukes,\n" ..
                "Magic mode will focus only on Magic Nukes.",
        },
        ['DoChestClick']    = {
            DisplayName = "Do Chest Click",
            Category = "Utilities",
            Tooltip = "Click your chest item",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "How do I use my chest item Clicky?",
            Answer = "Enable [DoChestClick] to use your chest item clicky.",
        },
        ['JoltAggro']       = {
            DisplayName = "Jolt Aggro %",
            Category = "Combat",
            Tooltip = "Aggro at which to use Jolt",
            Default = 65,
            Min = 1,
            Max = 100,
            FAQ = "Can I customize when to use Jolt?",
            Answer = "Yes, you can set the aggro % at which to use Jolt with the [JoltAggro] setting.",
        },
        ['WeaveAANukes']    = {
            DisplayName = "Weave AA Nukes",
            Category    = "Combat",
            Tooltip     = "Weave in AA Nukes",
            Default     = true,
            FAQ         = "I want to be able to weave in AA nukes when they are available, is this possible?",
            Answer      = "Yes, you can enable [WeaveAANukes] to weave in AA Nukes when they are available.",
        },
        ['DoManaBurn']      = {
            DisplayName = "Use Mana Burn AA",
            Category = "Combat",
            Tooltip = "Enable usage of Mana Burn",
            Default = true,
            FAQ = "Can I use Mana Burn?",
            Answer = "Yes, you can enable [DoManaBurn] to use Mana Burn when it is available.",
        },
        ['DoSnare']         = {
            DisplayName = "Use Snare Spells",
            Category = "Combat",
            Tooltip = "Enable usage of Snares",
            Default = true,
            FAQ = "How do I use Snare Spells?",
            Answer = "Enable [DoSnare] to use Snare Spells when they are available.",
        },
        ['DoRain']          = {
            DisplayName = "Use Rain Spells",
            Category = "Combat",
            Tooltip = "Enable usage of Rain Spells",
            Default = true,
            FAQ = "How do I use Rain Spells?",
            Answer = "Enable [DoRain] to use Rain Spells when they are available.",
        },
        ['RainDist']        = {
            DisplayName = "Min Dist for Rains",
            Category = "Combat",
            Tooltip = "If you are closer you will not use Rain spells",
            Default = 30,
            Min = 0,
            Max = 100,
            FAQ = "How do I use Rain Spells?",
            Answer = "Set the [RainDist] to the minimum distance you want to be from the target to use Rain Spells.\n" ..
                "And make sure you have [DoRain] enabled.",
        },
        ['RainMinHaters']   = {
            DisplayName = "Min XTHaters for Rains",
            Category = "Combat",
            Tooltip = "If There are less than x Mobs on XT you will not use Rain spells",
            Default = 3,
            Min = 1,
            Max = 100,
            FAQ = "How do I use Rain Spells?",
            Answer = "Set the [RainMinHaters] to the minimum number of haters you want to be near the target to use Rain Spells.\n" ..
                "And make sure you have [DoRain] enabled.",
        },
        ['RainMinTargetHP'] = {
            DisplayName = "Min Target HP for Rains",
            Category = "Combat",
            Tooltip = "Wait until the group target is at [x] HP before firing Rains",
            Default = 90,
            Min = 1,
            Max = 100,
            FAQ = "How do I use Rain Spells?",
            Answer = "Set the [RainMinTargetHP] to the minimum HP % you want the target to be at before using Rain Spells.\n" ..
                "And make sure you have [DoRain] enabled.",
        },
        ['DoGOMCheck']      = {
            DisplayName = "Do GOM Check",
            Category = "Combat",
            Tooltip = "Check if you have Gift of Mana before casting big nukes.",
            Default = false,
            FAQ = "How do I use Gift of Mana?",
            Answer = "Enable [DoGOMCheck] to check if you have Gift of Mana before casting big nukes.",
        },
        ['HarvestManaPct']  = {
            DisplayName = "Harvest Mana %",
            Category = "Utilities",
            Tooltip = "What Mana % to hit before using a harvest spell or aa.",
            Default = 85,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
    },
}
