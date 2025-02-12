-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

local mq        = require('mq')
local Config    = require('utils.config')
local Modules   = require("utils.modules")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Logger    = require("utils.logger")

return {
    _version            = "Experimental 1.3 (1-70 or 100+, others WIP)",
    _author             = "Algar",
    ['Modes']           = {
        'DPS',
    },
    ['OnModeChange']    = function(self, mode)
        -- if this is enabled the weaves will break.
        Config:GetSettings().WaitOnGlobalCooldown = false
    end,
    ['ItemSets']        = {
        ['Epic'] = {
            "Staff of Phenomenal Power",
            "Staff of Prismatic Power",
        },
    },
    ['AbilitySets']     = {
        ['AllianceSpell'] = {
            "Frostbound Covariance",
            "Frostbound Conjunction",
            "Frostbound Coalition",
            "Frostbound Covenant",
            "Frostbound Alliance",
        },
        ['DichoSpell'] = {
            "Reciprocal Fire",
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
            "Chaos Combustion",
            "Chaos Conflagration",
            "Chaos Immolation",
            "Chaos Flame",
        },
        ['VortexNuke'] = {
            -- NOTE: ${Spell[${VortexNuke}].ResistType} can be used to determine which resist type is getting debuffed
            "Chromospheric Vortex",
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
        ['WildNuke2'] = {
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
            "Ether Flame",
            "Chaos Flame",
            "Spark of Fire",
            "Draught of Ro",
            "Draught of Fire",
            "Conflagration",
            "Inferno Shock",
            "Flame Shock",
            "Fire Bolt",
            "Shock of Fire",
        },
        ['BigFireNuke'] = { -- Level 51-70, Long Cast, Heavy Damage
            "Ancient: Core Fire",
            "Corona Flare",
            "Ancient: Strike of Chaos",
            "White Fire",
            "Strike of Solusek",
            "Garrison's Superior Sundering",
            "Sunstrike",
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
            "Spark of Ice",
            "Black Ice",
            "Draught of E`ci",
            "Draught of Ice",
            "Ice Comet",
            "Ice Shock",
            "Frost Shock",
            "Shock of Ice",
            "Blast of Cold",
        },
        ['BigIceNuke'] = { -- Level 60-70, Timed with great Ratio or High Cast Time/Damage
            "Gelidin Comet",
            "Ice Meteor",
            "Ancient: Destruction of Ice", --13s T1
            "Ice Spear of Solist",         --13s T2
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
            "Voltaic Draught",
            "Rend",
            "Lightning Shock",
            "Garrison's Mighty Mana Shock",
            "Shock of Lightning",
        },
        ['BigMagicNuke'] = { -- Level 60-68, High Cast Time/Damage
            "Thundaka",
            "Shock of Magic",
            "Agnarr's Thunder",
            "Elnerick's Electrical Rending",
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
        ['SelfSpellShield1'] = {
            "Shield of Inescapability",
            "Shield of Inevitability",
            "Shield of Destiny",
            "Shield of Order",
            "Shield of Consequence",
            "Shield of Fate",
        },
        ['FamiliarBuff'] = {
            "Greater Familiar",
            "Familiar",
            "Lesser Familiar",
            "Minor Familiar",
        },
        ['SelfRune1'] = {
            "Aegis of Remembrance",
            "Aegis of the Umbra",
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
            "Contemplative Gambit",
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
        ['StunMagicNuke'] = {
            "Leap of Stormjolts",
            "Leap of Stormbolts",
            "Leap of Static Sparks",
            "Leap of Plasma",
            "Leap of Corposantum",
            "Leap of Static Jolts",
            "Leap of Static Bolts",
            "Leap of Sparks",
            "Leap of Levinsparks",
            "Leap of Shocking Bolts",
            "Spark of Thunder",
            "Draught of Thunder",
            "Draught of Jiva",
            "Force Strike",
            "Thunder Strike",
            "Force Snap",
            "Lightning Bolt",
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
        ['SnapNuke'] = {  -- T2 Ice ~8.5s recast (shared with Cloudburst)
            "Frostblast", -- Level 123
            "Chillblast",
            "Coldburst",
            "Flashfrost",
            "Flashrime",
            "Flashfreeze",
            "Frost Snap",
            "Freezing Snap",
            "Gelid Snap",
            "Rime Snap",
            "Cold Snap",      -- Level 73
        },
        ['AEBeam'] = {        -- T2 Frontal Fire AE
            "Cremating Beam", -- Level 121
            "Vaporizing Beam",
            "Scorching Beam",
            "Burning Beam",
            "Combusting Beam",
            "Incinerating Beam",
            "Blazing Beam",
            "Corona Beam",      -- Level 86
            "Beam of Solteris", -- Level 72
        },
        ['PBFlame'] = {         -- T4 PB Fire AE
            "Gyre of Flame",    -- Level 122
            "Coil of Flame",
            "Loop of Flame",
            "Wheel of Flame",
            "Corona of Flame",
            "Circle of Flame",
            "Ring of Flame",
            "Ring of Fire",
            "Talendor's Presence",
            "Vsorgu's Presence",
            "Magmaraug's Presence",
            "Circle of Fire", -- Level 67
        },
    },
    ['HelperFunctions'] = {
        --function to make sure we don't have non-hostiles in range before we use AE damage or non-taunt AE hate abilities
        AETargetCheck = function(minCount, printDebug)
            local haters = mq.TLO.SpawnCount("NPC xtarhater radius 80 zradius 50")()
            local haterPets = mq.TLO.SpawnCount("NPCpet xtarhater radius 80 zradius 50")()
            local totalHaters = haters + haterPets
            if totalHaters < minCount or totalHaters > Config:GetSetting('MaxAETargetCnt') then return false end

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
            name = 'Aggro Management',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and mq.TLO.Me.PctAggro() > (Config:GetSetting('JoltAggro') or 90)
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
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        {
            name = 'DPS(HighLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 100 end,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS(MidLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 101 and mq.TLO.Me.Level() > 70 end,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS(FireLowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 71 and Config:GetSetting('ElementChoice') == 1 end,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS(IceLowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 71 and Config:GetSetting('ElementChoice') == 2 end,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS(MagicLowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 71 and Config:GetSetting('ElementChoice') == 3 end,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'CombatBuff',
            state = 1,
            steps = 1,
            timer = 30, -- only run every 30 seconds at most.
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
    },
    ['Rotations']       = {
        ['Burn'] = {
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Arcane Fury",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Fury of the Gods",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Spire of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and not Casting.BuffActiveByName("Twincast")
                end,
            },
            {
                name = "Arcane Destruction",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and not mq.TLO.Me.Buff("Spire of Arcanum")
                end,
            },
            {
                name = "Frenzied Devastation",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and not mq.TLO.Me.Buff("Spire of Arcanum")
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
            {
                name = "Mana Burn",
                type = "AA",
                cond = function(self, aaName, target)
                    --TODO: make this not fire until it gets good at a certain rank
                    return Casting.TargetedAAReady(aaName, target.ID()) and not Casting.TargetHasBuffByName("Mana Burn") and Config:GetSetting('DoManaBurn') and
                        Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Call of Xuzl",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName)
                end,
            },
        },
        ['Aggro Management'] =
        {
            {
                name = "Mind Crash",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID()) and Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 90
                end,
            },
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID()) and Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 90
                end,
            },
            {
                name = "A Hole in Space",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Concussion",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID()) and mq.TLO.Me.PctAggro() > Config:GetSetting('JoltAggro')
                end,
            },
            {
                name = "JoltSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID()) and mq.TLO.Me.PctAggro() > Config:GetSetting('JoltAggro')
                end,
            },
        },
        ['Snare'] = {
            {
                name = "SnareSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID()) and Casting.DetSpellCheck(spell) and Targeting.GetTargetPctHPs(target) < 50
                end,
            },
        },
        ['CombatBuff'] =
        {
            {
                name = "TwincastSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SpellReady(spell) and not mq.TLO.Me.Buff("Improved Twincast")()
                end,
            },
            {
                name = "GambitSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SpellReady(spell) and mq.TLO.Me.PctMana() < Config:GetSetting('GambitManaPct')
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                allowDead = true,
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and mq.TLO.Me.PctMana() < Config:GetSetting('CombatHarvestManaPct')
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell)
                    return Casting.SpellReady(spell) and mq.TLO.Me.PctMana() < Config:GetSetting('CombatHarvestManaPct')
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Lower Element",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetSpellCheck(mq.TLO.Me.AltAbility(aaName).Spell) and Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Force of Ice",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Force of Will",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
            {
                name = "Force of Flame",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.TargetedAAReady(aaName, target.ID())
                end,
            },
        },
        ['DPS(HighLevel)'] = {
            {
                name = "VortexNuke",
                type = "Spell",
                cond = function(self, spell, target) --using DotSpellCheck to leverage HPStopDot settings to ensure we aren't casting just before trash dies (default: stop at 25% on named, 50% on trash)
                    return (Casting.DetGambitCheck() or Casting.DotSpellCheck(spell)) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "CloudburstNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return (Casting.DetGambitCheck() or mq.TLO.Me.Song("Evoker's Synergy")()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "FuseNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "AEBeam",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return Casting.TargetedSpellReady(spell, target.ID()) and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('BeamTargetCnt'), true)
                end,
            },
            {
                name = "FireClaw",
                type = "Spell",
                cond = function(self, spell, target)
                    return not Casting.BuffActiveByID(mq.TLO.Me.AltAbility("Improved Twincast").Spell.ID()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "PBFlame",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return Casting.TargetedSpellReady(spell, target.ID()) and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true)
                end,
            },
            {
                name = "FireEtherealNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "WildNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetGambitCheck() and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
        },
        ['DPS(MidLevel)'] = {
            {
                name = "SnapNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "FireEtherealNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID()) and (Casting.DetGOMCheck() or (Casting.BurnCheck() and Casting.HaveManaToNuke))
                end,
            },
            {
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID()) and (Casting.DetGOMCheck() or (Casting.BurnCheck() and Casting.HaveManaToNuke))
                end,
            },
            {
                name = "WildNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "WildNuke2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "ChaosNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
        },
        ['DPS(FireLowLevel)'] = {
            {
                name = "StunSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStun') then return false end
                    return (Casting.HaveManaToDebuff() or Casting.BurnCheck()) and Casting.DetSpellCheck(spell) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "BigFireNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if (Targeting.GetTargetPctHPs(target) < Config:GetSetting('HPStopBigNuke') and not Targeting.IsNamed(target)) then return false end
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "FireNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
        },
        ['DPS(IceLowLevel)'] = {
            {
                name = "StunSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStun') then return false end
                    return (Casting.HaveManaToDebuff() or Casting.BurnCheck()) and Casting.DetSpellCheck(spell) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "BigIceNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if (Targeting.GetTargetPctHPs(target) < Config:GetSetting('BigNukeMinHealth') and not Targeting.IsNamed(target)) then return false end
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
        },
        ['DPS(MagicLowLevel)'] = {
            {
                name = "StunSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStun') then return false end
                    return (Casting.HaveManaToDebuff() or Casting.BurnCheck()) and Casting.DetSpellCheck(spell) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "BigMagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if (Targeting.GetTargetPctHPs(target) < Config:GetSetting('BigNukeMinHealth') and not Targeting.IsNamed(target)) then return false end
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return (Casting.HaveManaToNuke() or Casting.BurnCheck()) and Casting.TargetedSpellReady(spell, target.ID())
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
                    return (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) >= selfHPBuffLevel and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SelfSpellShield1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
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
                    return (mq.TLO.Me.AltAbility(aaName).Spell.Level() or 0) >= familiarBuffLevel and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and Casting.AAReady(aaName)
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and Casting.SpellReady(spell)
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
    ['Spells']          = {
        {
            gem = 1,
            spells = {
                { name = "VortexNuke", },
                { name = "FireNuke",   cond = function() return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "IceNuke",    cond = function() return Config:GetSetting('ElementChoice') == 2 end, },
                { name = "MagicNuke",  cond = function() return Config:GetSetting('ElementChoice') == 3 end, },

            },
        },
        {
            gem = 2,
            spells = {
                { name = "FuseNuke", },
                { name = "BigFireNuke",  cond = function() return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "BigIceNuke",   cond = function() return Config:GetSetting('ElementChoice') == 2 end, },
                { name = "BigMagicNuke", cond = function() return Config:GetSetting('ElementChoice') == 3 end, },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "FireClaw", },
                { name = "StunSpell", function() return Config:GetSetting('DoStun') end, },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "FireEtherealNuke", },
                { name = "HarvestSpell", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "IceEtherealNuke", },
                { name = "JoltSpell", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "CloudburstNuke", },
                { name = "SnareSpell",     function() return Config:GetSetting('DoSnare') end, },
            },
        },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "WildNuke", },
                { name = "EvacSpell", },

            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "GambitSpell", },
                { name = "SelfHPBuff", },

            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TwincastSpell", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "AEBeam",           function() return Config:GetSetting('DoAEBeam') end, },
                { name = "PBFlame",          cond = function() return Config:GetSetting('DoPBAE') end, },
                { name = "SelfRune1", },
                { name = "SelfSpellShield1", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PBFlame",          cond = function() return Config:GetSetting('DoPBAE') end, },
                { name = "SelfRune1", },
                { name = "SelfSpellShield1", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SelfRune1", },
                { name = "SelfSpellShield1", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SelfSpellShield1", },
            },
        },
    },
    ['DefaultConfig']   = {
        ['Mode']                 = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes Do?",
            Answer = "Wizard only has a single mode, but the spells used will adjust based on your level range.",
        },
        ['DoChestClick']         = {
            DisplayName = "Do Chest Click",
            Category = "Utilities",
            Tooltip = "Click your chest item",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "How do I use my chest item Clicky?",
            Answer = "Enable [DoChestClick] to use your chest item clicky.",
        },
        ['JoltAggro']            = {
            DisplayName = "Jolt Aggro %",
            Category = "Combat",
            Tooltip = "Aggro at which to use Jolt",
            Default = 85,
            Min = 1,
            Max = 100,
            FAQ = "Can I customize when to use Jolt?",
            Answer = "Yes, you can set the aggro % at which to use Jolt with the [JoltAggro] setting.",
        },
        ['ElementChoice']        = {
            DisplayName = "Element Choice:",
            Category = "DPS Low Level",
            Index = 1,
            Tooltip = "Choose an element to focus on under level 71.",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Ice', 'Magic', },
            Default = 1,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            FAQ = "WIP?",
            Answer = "WIP.",
        },
        ['HPStopBigNuke']        = {
            DisplayName = "Stop Big Nuke",
            Category = "DPS Low Level",
            Tooltip = "Don't use our Big Nuke below this health percentage.",
            Default = 50,
            Min = 1,
            Max = 100,
            FAQ = "WIP?",
            Answer = "WIP.",
        },
        ['DoStun']               = {
            DisplayName = "Do Stun",
            Category = "DPS Low Level",
            Tooltip = "Use your Stun Nukes (Stun with DD, not mana efficient).",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "WIP?",
            Answer =
            "WIP.",
        },
        ['DoManaBurn']           = {
            DisplayName = "Use Mana Burn AA",
            Category = "Combat",
            Tooltip = "Enable usage of Mana Burn",
            Default = true,
            FAQ = "Can I use Mana Burn?",
            Answer = "Yes, you can enable [DoManaBurn] to use Mana Burn when it is available.",
        },
        ['DoAEDamage']           = {
            DisplayName = "Do AE Damage",
            Category = "AE Damage",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['DoAEBeam']             = {
            DisplayName = "Use Beam Spells",
            Category = "AE Damage",
            Index = 2,
            Tooltip = "**WILL BREAK MEZ** Use your Frontal AE Spells (Beam Line). **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['BeamTargetCnt']        = {
            DisplayName = "Beam Tgt Cnt",
            Category = "AE Damage",
            Index = 3,
            Tooltip = "Minimum number of valid targets before using AE Spells like Beams.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['DoPBAE']               = {
            DisplayName = "Use PBAE Spells",
            Category = "AE Damage",
            Index = 4,
            Tooltip = "**WILL BREAK MEZ** Use your PB AE Spells (of Flame Line). **WILL BREAK MEZ**",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['PBAETargetCnt']        = {
            DisplayName = "PBAE Tgt Cnt",
            Category = "AE Damage",
            Index = 5,
            Tooltip = "Minimum number of valid targets before using PB Spells like the of Flame line.",
            Default = 4,
            Min = 1,
            Max = 10,
            FAQ = "Why am I not using my PBAE spells?",
            Answer =
            "You can adjust the PB Target Count to control when you will use actions PBAE Spells such as the of Flame line.",
        },
        ['MaxAETargetCnt']       = {
            DisplayName = "Max AE Targets",
            Category = "AE Damage",
            Index = 6,
            Tooltip =
            "Maximum number of valid targets before using AE Spells, Disciplines or AA.\nUseful for setting up AE Mez at a higher threshold on another character in case you are overwhelmed.",
            Default = 6,
            Min = 2,
            Max = 30,
            FAQ = "How do I take advantage of the Max AE Targets setting?",
            Answer =
            "By limiting your max AE targets, you can set an AE Mez count that is slightly higher, to allow for the possiblity of mezzing if you are being overwhelmed.",
        },
        ['SafeAEDamage']         = {
            DisplayName = "AE Proximity Check",
            Category = "AE Damage",
            Index = 7,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },
        ['DoSnare']              = {
            DisplayName = "Use Snares",
            Category = "Buffs/Debuffs",
            Index = 1,
            Tooltip = "Use Snare Spells.",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not snaring?",
            Answer = "Make sure Use Snares is enabled in your class settings.",
        },
        ['SnareCount']           = {
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
        ['WeaveAANukes']         = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoRain']               = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['RainDist']             = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['RainMinHaters']        = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['RainMinTargetHP']      = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoGOMCheck']           = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['GambitManaPct']        = {
            DisplayName = "Gambit Mana %",
            Category = "Utilities",
            Tooltip = "What Mana % to hit before using your Gambit line.",
            Default = 80,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
        ['HarvestManaPct']       = {
            DisplayName = "Harvest Mana %",
            Category = "Utilities",
            Tooltip = "What Mana % to hit before using a harvest spell or aa.",
            Default = 85,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
        ['CombatHarvestManaPct'] = {
            DisplayName = "Combat Harvest %",
            Category = "Utilities",
            Tooltip = "What Mana % to hit before using a harvest spell or aa in Combat.",
            Default = 60,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
    },
}
