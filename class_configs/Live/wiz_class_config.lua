-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

local mq        = require('mq')
local Config    = require('utils.config')
local Modules   = require("utils.modules")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")
local Core      = require("utils.core")
local Logger    = require("utils.logger")

return {
    _version            = "2.0 - Live",
    _author             = "Derple, Algar",
    ['Modes']           = {
        'DPS',
        'PBAE(LowLevel)',
    },
    ['OnModeChange']    = function(self, mode)
        -- if this is enabled weaves will break.
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
            "Claw of Ingot",
            "Claw of the Duskflame",
            "Claw of Sontalak",
            "Claw of Qunard",
            "Claw of the Flameweaver",
            "Claw of the Flamewing",
            "Villification of Havoc", --54s recast but same timer and purpose.
            "Denunciation of Havoc",
            "Malediction of Havoc",
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
            --Not used above this
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
            "Contemplative Gambit",
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
        ['IceRain'] = {
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
        ['FireRain'] = {
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
        ['FireLureRain'] = {
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
            --"Circle of Fire", -- Level 67 Used in PBAE Mode, wouldn't be used in Modern PBAE
        },
        ['PBTimer4'] = {
            "Circle of Thunder", -- Level 70, Magic
            "Circle of Fire",    -- Level 67, Fire
            "Winds of Gelid",    -- Level 60, Ice
            "Supernova",         -- Level 45, Fire
            "Thunderclap",       -- Level 30, Magic
        },
        ['FireJyll'] = {
            "Jyll's Wave of Heat", -- Level 59
        },
        ['IceJyll'] = {
            "Jyll's Zephyr of Iced", -- Level 56
        },
        ['MagicJyll'] = {
            "Jyll's Static Pulse", -- Level 53
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
        RainCheck = function(target) -- I made a funny
            if not (Config:GetSetting('DoRain') and Config:GetSetting('DoAEDamage')) then return false end
            return Targeting.GetTargetDistance() >= Config:GetSetting('RainDistance') and Targeting.MobNotLowHP(target)
        end,
    },
    ['RotationOrder']   = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Aggro Management',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctAggro() > (Config:GetSetting('JoltAggro') or 90)
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Targeting.IsNamed(Targeting.GetAutoTarget()) and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        { --Keep things from doing
            name = 'Stun',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoStun') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS(100+)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 99 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS(71-99)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 100 and mq.TLO.Me.Level() > 70 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'FireDPS(1-70)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 71 and Config:GetSetting('ElementChoice') == 1 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE(LowLevel)') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'IceDPS(1-70)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 71 and Config:GetSetting('ElementChoice') == 2 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE(LowLevel)') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'MagicDPS(1-70)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 71 and Config:GetSetting('ElementChoice') == 3 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE(LowLevel)') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'DPS(PBAELowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 71 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true)
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'CombatBuff',
            state = 1,
            steps = 1,
            timer = 30, -- only run every 30 seconds at most.
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['Rotations']       = {
        ['Burn'] = {
            {
                name = "Focus of Arcanum",
                type = "AA",
            },
            {
                name = "Arcane Fury",
                type = "AA",
            },
            {
                name = "Fury of the Gods",
                type = "AA",
            },
            {
                name = "Spire of Arcanum",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            {
                name = "Arcane Destruction",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Spire of Arcanum")
                end,
            },
            {
                name = "Frenzied Devastation",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Spire of Arcanum")
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
            },
            {
                name = "Mana Burn",
                type = "AA",
                cond = function(self)
                    if not Config:GetSetting('DoManaBurn') then return false end
                    return not Casting.TargetHasBuff("Mana Burn") and Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Call of Xuzl",
                type = "AA",
            },
        },
        ['Aggro Management'] =
        {
            {
                name = "Mind Crash",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 90
                end,
            },
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 90
                end,
            },
            {
                name = "A Hole in Space",
                type = "AA",
                cond = function(self)
                    return Targeting.IHaveAggro(100)
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
        ['Snare'] = {
            {
                name = "Atol's Shackles",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target)
                end,
            },
            {
                name = "SnareSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target)
                end,
            },
        },
        ['Stun'] = {
            {
                name = "StunSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.HaveManaToDebuff() and Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['CombatBuff'] =
        {
            {
                name = "TwincastSpell",
                type = "Spell",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            {
                name = "GambitSpell",
                type = "Spell",
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('GambitManaPct')
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                allowDead = true,
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('CombatHarvestManaPct')
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                allowDead = true,
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('CombatHarvestManaPct')
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Lower Element",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Force of Ice",
                type = "AA",
            },
            {
                name = "Force of Will",
                type = "AA",
            },
            {
                name = "Force of Flame",
                type = "AA",
            },
        },
        ['DPS(100+)'] = {
            {
                name = "VortexNuke",
                type = "Spell",
                cond = function(self, spell) --using DotSpellCheck to leverage MobLowHP settings to ensure we aren't casting just before trash dies (default: stop at 25% on named, 50% on trash)
                    return Casting.GambitCheck() or Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "CloudburstNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.GambitCheck() or Casting.IHaveBuff("Evoker's Synergy")
                end,
            },
            {
                name = "FuseNuke",
                type = "Spell",
            },
            {
                name = "AEBeam",
                type = "Spell",
                allowDead = true,
                cond = function(self)
                    if not (Config:GetSetting('DoAEBeam') and Config:GetSetting('DoAEDamage')) then return false end
                    return self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('BeamTargetCnt'), true)
                end,
            },
            {
                name = "FireClaw",
                type = "Spell",
                cond = function(self)
                    return not Casting.IHaveBuff("Improved Twincast")
                end,
            },
            {
                name = "PBFlame",
                type = "Spell",
                allowDead = true,
                cond = function(self)
                    if not (Config:GetSetting('DoPBAE') and Config:GetSetting('DoAEDamage')) then return false end
                    return self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true)
                end,
            },
            {
                name = "FireEtherealNuke",
                type = "Spell",
            },
            {
                name = "WildNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.GambitCheck()
                end,
            },
            {
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self)
                    return mq.TLO.Me.Level() > 110 or Casting.IHaveBuff("Improved Twincast")
                end,
            },
        },
        ['DPS(71-99)'] = {
            {
                name = "FireClaw",
                type = "Spell",
                cond = function(self)
                    return not Casting.IHaveBuff("Improved Twincast")
                end,
            },
            {
                name = "SnapNuke",
                type = "Spell",
            },
            { --use if GOM procs or if we have extra mana while burning
                name = "FireEtherealNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.GOMCheck() or (Casting.BurnCheck() and Casting.HaveManaToNuke())
                end,
            },
            { --use if GOM procs or if we have extra mana while burning
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.GOMCheck() or (Casting.BurnCheck() and Casting.HaveManaToNuke())
                end,
            },
            {
                name = "WildNuke",
                type = "Spell",
            },
            {
                name = "WildNuke2",
                type = "Spell",
            },
            {
                name = "ChaosNuke",
                type = "Spell",
                cond = function(self)
                    return not Core.GetResolvedActionMapItem("WildNuke2")
                end,
            },
        },
        ['FireDPS(1-70)'] = {
            {
                name = "FireRain",
                type = "Spell",
                cond = function(self, spell, target)
                    if not self.ClassConfig.HelperFunctions.RainCheck(target) then return false end
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "BigFireNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "FireNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.HaveManaToNuke()
                end,
            },
        },
        ['IceDPS(1-70)'] = {
            {
                name = "IceRain",
                type = "Spell",
                cond = function(self, spell, target)
                    if not self.ClassConfig.HelperFunctions.RainCheck(target) then return false end
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "BigIceNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.HaveManaToNuke()
                end,
            },
        },
        ['MagicDPS(1-70)'] = {
            {
                name = "BigMagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.HaveManaToNuke()
                end,
            },
        },
        ['DPS(PBAELowLevel)'] = {
            {
                name = "PBTimer4",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "FireJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "IceJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "MagicJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and Targeting.InSpellRange(spell, target)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return (spell.Level() or 0) > (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Etherealist's Unity",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID()) end,
                cond = function(self, aaName)
                    local selfHPBuff = Modules:ExecModule("Class", "GetResolvedActionMapItem", "SelfHPBuff")
                    local selfHPBuffLevel = selfHPBuff and selfHPBuff() and selfHPBuff.Level() or 0
                    return (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) >= selfHPBuffLevel and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SelfSpellShield1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "FamiliarBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return (spell.Level() or 0) > (mq.TLO.Me.AltAbility("Improved Familiar").Spell.Level() or 0) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Improved Familiar",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    local familiarBuff = Modules:ExecModule("Class", "GetResolvedActionMapItem", "FamiliarBuff")
                    local familiarBuffLevel = familiarBuff and familiarBuff() and familiarBuff.Level() or 0
                    return (mq.TLO.Me.AltAbility(aaName).Spell.Level() or 0) >= familiarBuffLevel and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct')
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.CastReady(spell) and mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct')
                end,
            },
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and Casting.SelfBuffItemCheck(itemName)
                end,
            },
        },
    },
    ['Spells']          = {
        {
            gem = 1,
            spells = {
                { name = "VortexNuke", cond = function() return mq.TLO.Me.Level() > 102 end, },
                { name = "SnapNuke", },
                --1-70
                { name = "FireNuke",   cond = function() return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "IceNuke",    cond = function() return Config:GetSetting('ElementChoice') == 2 end, },
                { name = "MagicNuke",  cond = function() return Config:GetSetting('ElementChoice') == 3 end, },

            },
        },
        {
            gem = 2,
            spells = {
                { name = "FireEtherealNuke", },
                --1-70
                { name = "BigFireNuke",      cond = function() return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "BigIceNuke",       cond = function() return Config:GetSetting('ElementChoice') == 2 end, },
                { name = "BigMagicNuke",     cond = function() return Config:GetSetting('ElementChoice') == 3 end, },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "IceEtherealNuke", },
                -- 1-70
                { name = "PBTimer4",        cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 71 end, },
                { name = "StunSpell",       cond = function() return Config:GetSetting('DoStun') end, },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "FuseNuke", },
                -- 1
                { name = "FireJyll",  cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 71 end, },
                { name = "FireRain",  cond = function() return Config:GetSetting('DoRain') and Config:GetSetting('ElementChoice') == 1 end, },
                { name = "IceRain",   cond = function() return Config:GetSetting('DoRain') and Config:GetSetting('ElementChoice') == 2 end, },
                { name = "EvacSpell", },

            },
        },
        {
            gem = 5,
            spells = {
                { name = "FireClaw", },
                -- 1-70
                { name = "IceJyll",   cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 71 end, },
                { name = "JoltSpell", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "WildNuke", },
                -- 1-70
                { name = "MagicJyll",  cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 71 end, },
                { name = "SnareSpell", cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "CloudburstNuke", cond = function() return mq.TLO.Me.Level() > 99 end, },
                { name = "WildNuke2", },
                { name = "ChaosNuke", },
                -- 1-70
                { name = "HarvestSpell", },

            },
        },
        {
            gem = 8,
            spells = {
                { name = "GambitSpell", },
                { name = "HarvestSpell", },
                { name = "SelfHPBuff", },

            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TwincastSpell", },
                { name = "SnareSpell",    cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "AEBeam",           cond = function() return Config:GetSetting('DoAEBeam') end, },
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
            Max = 2,
            FAQ = "What do the different Modes Do?",
            Answer = "Wizard only has a single mode, but the spells used will adjust based on your level range.",
        },

        -- Low Level
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
        ['DoRain']               = {
            DisplayName = "Do Rain",
            Category = "DPS Low Level",
            Index = 2,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            Tooltip = "**WILL BREAK MEZ** Use your selected element's Rain Spell as a single-target nuke. **WILL BREAK MEZ***",
            Default = false,
            FAQ = "Why is Rain being used a single target nuke?",
            Answer = "In some situations, using a Rain can be an efficient single target nuke at low levels.\n" ..
                "Note that PBAE spells tend to be superior for AE dps at those levels.",
        },
        ['RainDistance']         = {
            DisplayName = "Min Rain Distance",
            Category = "DPS Low Level",
            Index = 3,
            ConfigType = "Advanced",
            Tooltip = "The minimum distance a target must be to use a Rain (Rain AE Range: 25').",
            Default = 30,
            Min = 0,
            Max = 100,
            FAQ = "Why does minimum rain distance matter?",
            Answer = "Rain spells, if cast close enough, can damage the caster. The AE range of a Rain is 25'.",
        },
        ['DoStun']               = {
            DisplayName = "Do Stun",
            Category = "DPS Low Level",
            Index = 4,
            Tooltip = "Use your Stun Nukes (Stun with DD, not mana efficient).",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "WIP?",
            Answer =
            "WIP.",
        },

        --AE Damage
        ['DoAEDamage']           = {
            DisplayName = "Do AE Damage",
            Category = "AE Damage",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['DoAEBeam']             = {
            DisplayName = "Use Beam Spells",
            Category = "AE Damage",
            Index = 2,
            RequiresLoadoutChange = true,
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
            RequiresLoadoutChange = true,
            Tooltip =
            "**WILL BREAK MEZ** Use your PB AE Spells (of Flame Line). **WILL BREAK MEZ**\nPlease note, that by necessity, the PBAELowLevel mode will NOT respect this setting.",
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

        -- Spells and Abilities
        ['JoltAggro']            = {
            DisplayName = "Jolt Aggro %",
            Category = "Spells and Abilities",
            Index = 1,
            Tooltip = "Aggro at which to use Jolt",
            Default = 90,
            Min = 1,
            Max = 100,
            FAQ = "Can I customize when to use Jolt?",
            Answer = "Yes, you can set the aggro % at which to use Jolt with the [JoltAggro] setting.",
        },
        ['DoManaBurn']           = {
            DisplayName = "Use Mana Burn AA",
            Category = "Spells and Abilities",
            Index = 2,
            Tooltip = "Enable usage of Mana Burn",
            Default = true,
            FAQ = "Can I use Mana Burn?",
            Answer = "Yes, you can enable [DoManaBurn] to use Mana Burn when it is available.",
        },
        ['DoSnare']              = {
            DisplayName = "Use Snares",
            Category = "Spells and Abilities",
            Index = 3,
            Tooltip = "Use Snare Spells.",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not snaring?",
            Answer = "Make sure Use Snares is enabled in your class settings.",
        },
        ['SnareCount']           = {
            DisplayName = "Snare Max Mob Count",
            Category = "Spells and Abilities",
            Index = 4,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
            Min = 1,
            Max = 99,
            FAQ = "Why is my Shadow Knight Not snaring?",
            Answer = "Make sure you have [DoSnare] enabled in your class settings.\n" ..
                "Double check the Snare Max Mob Count setting, it will prevent snare from being used if there are more than [x] mobs on aggro.",
        },
        ['DoChestClick']         = {
            DisplayName = "Do Chest Click",
            Category = "Spells and Abilities",
            Index = 5,
            Tooltip = "Click your chest item",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "How do I use my chest item Clicky?",
            Answer = "Enable [DoChestClick] to use your chest item clicky.",
        },
        ['GambitManaPct']        = {
            DisplayName = "Gambit Mana %",
            Category = "Spells and Abilities",
            Index = 6,
            ConfigType = "Advanced",
            Tooltip = "What Mana % to hit before using your Gambit line.",
            Default = 80,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
        ['HarvestManaPct']       = {
            DisplayName = "Harvest Mana %",
            Category = "Spells and Abilities",
            Index = 7,
            ConfigType = "Advanced",
            Tooltip = "What Mana % to hit before using a harvest spell or aa.",
            Default = 85,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
        ['CombatHarvestManaPct'] = {
            DisplayName = "Combat Harvest %",
            Category = "Spells and Abilities",
            Index = 8,
            ConfigType = "Advanced",
            Tooltip = "What Mana % to hit before using a harvest spell or aa in Combat.",
            Default = 60,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
        --Orphaned
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
    },
}
