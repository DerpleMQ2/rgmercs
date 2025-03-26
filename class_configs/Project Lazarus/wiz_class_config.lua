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
    _version            = "2.0 - Project Lazarus",
    _author             = "Derple, Algar",
    ['Modes']           = {
        'DPS',
        'PBAE',
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

        ['OoW_Chest'] = {
            "Academic's Robe of the Arcanists",
            "Spelldeviser's Cloth Robe",
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
        ['FireEtherealNuke'] = {
            -- "Ethereal Immolation",
            -- "Ethereal Ignition",
            -- "Ethereal Brand",
            -- "Ethereal Skyfire",
            -- "Ethereal Skyblaze",
            -- "Ethereal Incandescence",
            -- "Ethereal Blaze",
            -- "Ethereal Inferno",
            -- "Ethereal Combustion",
            -- "Ethereal Incineration",
            -- "Ethereal Conflagration",
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
            -- "Chaos Flame",
            -- "Chaos Inferno",
            -- "Chaos Burn",
            -- "Chaos Scintillation",
            -- "Chaos Incandescence",
            -- "Chaos Blaze",
            -- "Chaos Char",
            -- "Chaos Combustion",
            -- "Chaos Conflagration",
            -- "Chaos Immolation",
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
            -- "Wildspell Strike",
            -- "Wildflame Strike",
            -- "Wildscorch Strike",
            -- "Wildflash Strike",
            -- "Wildflash Barrage",
            -- "Wildether Barrage",
            -- "Wildspark Barrage",
            -- "Wildmana Barrage",
            -- "Wildmagic Blast",
            "Wildmagic Burst",
            -- "Wildmagic Strike",
        },
        -- ['WildNuke2'] = {
        --     "Wildspell Strike",
        --     "Wildflame Strike",
        --     "Wildscorch Strike",
        --     "Wildflash Strike",
        --     "Wildflash Barrage",
        --     "Wildether Barrage",
        --     "Wildspark Barrage",
        --     "Wildmana Barrage",
        --     "Wildmagic Blast",
        --     "Wildmagic Burst",
        --     "Wildmagic Strike",
        -- },
        ['FireNuke'] = {
            -- "Kindleheart's Fire",
            -- "The Diabo's Fire",
            -- "Dagarn's Fire",
            -- "Dragoflux's Fire",
            -- "Narendi's Fire",
            -- "Gosik's Fire",
            -- "Daevan's Fire",
            -- "Lithara's Fire",
            -- "Klixcxyk's Fire",
            -- "Inizen's Fire",
            -- "Sothgar's Flame",
            "Spark of Fire",
            "Draught of Ro",
            "Draught of Fire",
            "Conflagration",
            "Inferno Shock",
            "Flame Shock",
            "Fire Bolt",
            "Shock of Fire",
        },
        ['BigFireNuke'] = {       -- Level 51-70, Long Cast, Heavy Damage
            "Ancient: Core Fire", --Ether Flame beats this soundly at the same level
            "Corona Flare",       --Ether Flame beats this soundly at the same level
            "Ancient: Strike of Chaos",
            "White Fire",
            "Strike of Solusek",
            "Garrison's Superior Sundering",
            "Sunstrike",
        },
        ['IceNuke'] = {
            -- "Glacial Ice Cascade",
            -- "Tundra Ice Cascade",
            -- "Restless Ice Cascade",
            -- "Icefloe Cascade",
            -- "Rimeblast Cascade",
            -- "Hoarfrost Cascade",
            -- "Rime Cascade",
            -- "Glacial Cascade",
            -- "Icesheet Cascade",
            -- "Glacial Collapse",
            -- "Icefall Avalanche",
            -- "Ancient: Spear of Gelaqua" -- ON LAZ, BUT NOT SURE WHETHER TO INCLUDE THIS OR NOT
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
            -- "Teladaka",
            -- "Teladaja",
            -- "Telajaga",
            -- "Telanata",
            -- "Telanara",
            -- "Telanaga",
            -- "Telanama",
            -- "Telakama",
            -- "Telajara",
            -- "Telajasz",
            -- "Telakisz",
            "Telakemara",
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
        -- ['SelfSpellShield1'] = {
        --     "Shield of Inescapability",
        --     "Shield of Inevitability",
        --     "Shield of Destiny",
        --     "Shield of Order",
        --     "Shield of Consequence",
        --     "Shield of Fate",
        -- },
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
        -- ['GambitSpell'] = {
        --     "Contemplative Gambit",
        --     "Anodyne Gambit",
        --     "Idyllic Gambit",
        --     "Musing Gambit",
        --     "Quiescent Gambit",
        --     "Bucolic Gambit",
        -- },
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
        -- ['FireLureNuke'] = {
        --     "Enticement of Flame",
        --     "Lure of Flame",
        --     "Lure of Ro",
        --     "Firebane",
        --     "Lavalure",
        --     "Pyrolure",
        --     "Flarelure",
        --     "Flamelure",
        --     "Blazelure",
        --     "MagmaLure",
        --     "PlasmaLure",
        --     "Lure of Qunard",
        --     "Lure of Sontalak",
        --     "Lure of Fyrthek",
        --     "Lure of the Arcanaforged",
        -- },
        -- ['MagicLureNuke'] = {
        --     "Lure of Lightning",
        --     "Lure of Thunder",
        --     "Lightningbane",
        --     "Permeating Ether",
        -- },
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
        -- ['FireLureRain'] = {
        --     "Volcanic Burst",
        --     "Tears of Arlyxir",
        --     "Meteor Storm",
        --     "Volcanic Eruption",
        --     "Pyroclastic Eruption",
        --     "Magmatic Eruption",
        --     "Magmatic Downpour",
        --     "Magmatic Outburst",
        --     "Magmatic Vent",
        --     "Magmatic Burst",
        --     "Magmatic Explosion",
        --     "Volcanic Downpour",
        --     "Volcanic Barrage",
        -- },
        -- ['SnapNuke'] = {  -- T2 Ice ~8.5s recast (shared with Cloudburst)
        --     "Frostblast", -- Level 123
        --     "Chillblast",
        --     "Coldburst",
        --     "Flashfrost",
        --     "Flashrime",
        --     "Flashfreeze",
        --     "Frost Snap",
        --     "Freezing Snap",
        --     "Gelid Snap",
        --     "Rime Snap",
        --     "Cold Snap",      -- Level 73
        -- },
        -- ['AEBeam'] = {        -- T2 Frontal Fire AE
        --     "Cremating Beam", -- Level 121
        --     "Vaporizing Beam",
        --     "Scorching Beam",
        --     "Burning Beam",
        --     "Combusting Beam",
        --     "Incinerating Beam",
        --     "Blazing Beam",
        --     "Corona Beam",      -- Level 86
        --     "Beam of Solteris", -- Level 72
        -- },
        ['PBFlame'] = {      -- T4 PB Fire AE
            "Gyre of Flame", -- Level 122
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
            "Jyll's Zephyr of Ice", -- Level 56
        },
        ['MagicJyll'] = {
            "Jyll's Static Pulse", -- Level 53
        },
        ['ManaWeave'] = {
            "Mana Weave",
        },
        ['SwarmPet'] = {
            "Flaming Sword of Xuzl", --homework
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
            steps = 1,
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
                return combat_state == "Combat" and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
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
            name = 'DPS(Level70)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 101 and mq.TLO.Me.Level() > 69 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'DPS(FireLowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 70 and Config:GetSetting('ElementChoice') == 1 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'DPS(IceLowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 70 and Config:GetSetting('ElementChoice') == 2 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'DPS(MagicLowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 70 and Config:GetSetting('ElementChoice') == 3 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    not (Core.IsModeActive('PBAE') and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true))
            end,
        },
        {
            name = 'DPS(PBAE)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive('PBAE') end,
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
                name = "Epic",
                type = "Item",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            {
                name = "OoW_Chest",
                type = "Item",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
            },
            {
                name = "Fundament: Second Spire of Arcanum",
                type = "AA",
            },
            {
                name = "Fury of Ro",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            { --Crit Chance AA, will use the first(best) one found
                name_func = function(self)
                    return Casting.GetBestAA({ "Prolonged Destruction", "Frenzied Devastation", })
                end,
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
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
                name = "Concussive Intuition",
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
                name = "Force of Will",
                type = "AA",
            },
        },
        ['DPS(Level70)'] = {
            {
                name = "ManaWeave",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and not Casting.IHaveBuff("Weave of Power")
                end,
            },
            {
                name = "WildNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.HaveManaToNuke() and Casting.IHaveBuff("Weave of Power")
                end,
            },
            {
                name = "FireEtherealNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "ChaosNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and Targeting.MobHasLowHP(target)
                end,
            },
            {
                name = "Scepter of Incantations",
                type = "Item",
            },
        },
        ['DPS(FireLowLevel)'] = {
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
        ['DPS(IceLowLevel)'] = {
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
        ['DPS(MagicLowLevel)'] = {
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
        ['DPS(PBAE)'] = {
            {
                name = "PBTimer4",
                type = "Spell",
                allowDead = true,
                cond = function(self)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "FireJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "IceJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "MagicJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self)
                    return Casting.HaveManaToNuke()
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
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            { --Familiar AA, will use the first(best) one found
                name_func = function(self)
                    return Casting.GetBestAA({ "Kerafyrm's Prismatic Familiar", "Ro's Flaming Familiar", "Improved Familiar", })
                end,
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "FamiliarBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if Casting.CanUseAA("Improved Familiar") then return false end
                    return Casting.SelfBuffCheck(spell)
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
        },
    },
    ['Spells']          = {
        {
            gem = 1,
            spells = {
                { name = "ManaWeave", },
                { name = "FireNuke",  cond = function() return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "IceNuke",   cond = function() return Config:GetSetting('ElementChoice') == 2 end, },
                { name = "MagicNuke", cond = function() return Config:GetSetting('ElementChoice') == 3 end, },

            },
        },
        {
            gem = 2,
            spells = {
                { name = "FireEtherealNuke", },
                { name = "BigFireNuke",      cond = function() return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "BigIceNuke",       cond = function() return Config:GetSetting('ElementChoice') == 2 end, },
                { name = "BigMagicNuke",     cond = function() return Config:GetSetting('ElementChoice') == 3 end, },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "WildNuke", },
                { name = "FireRain",     cond = function() return Config:GetSetting('DoRain') and Config:GetSetting('ElementChoice') == 1 end, },
                { name = "IceRain",      cond = function() return Config:GetSetting('DoRain') and Config:GetSetting('ElementChoice') == 2 end, },
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "ChaosNuke", },
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "PBTimer4",     cond = function() return Core.IsModeActive('PBAE') end, },
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "FireJyll",     cond = function() return Core.IsModeActive('PBAE') end, },
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "IceJyll",      cond = function() return Core.IsModeActive('PBAE') end, },
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", },


            },
        },
        {
            gem = 8,
            spells = {
                { name = "MagicJyll",    cond = function() return Core.IsModeActive('PBAE') end, },
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", }, },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", },

            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "HarvestSpell", },
                { name = "SnareSpell",   cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
                { name = "StunSpell",    cond = function() return Config:GetSetting('DoStun') end, },
                { name = "JoltSpell", },
                { name = "SelfRune1", },
                { name = "EvacSpell", },
                { name = "SelfHPBuff", },
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

        -- Damage (ST)
        ['ElementChoice']        = {
            DisplayName = "Element Choice:",
            Category = "Damage",
            Index = 1,
            Tooltip = "Choose an element to focus on.",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Ice', 'Magic', },
            Default = 1,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            FAQ = "WIP?",
            Answer = "WIP.",
        },
        ['DoManaBurn']           = {
            DisplayName = "Use Mana Burn AA",
            Category = "Damage",
            Index = 2,
            Tooltip = "Enable usage of Mana Burn",
            Default = true,
            FAQ = "Can I use Mana Burn?",
            Answer = "Yes, you can enable [DoManaBurn] to use Mana Burn when it is available.",
        },
        ['DoRain']               = {
            DisplayName = "Do Rain",
            Category = "Damage",
            Index = 3,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            Tooltip = "**WILL BREAK MEZ** Use your selected element's Rain Spell as a single-target nuke. **WILL BREAK MEZ***",
            Default = false,
            FAQ = "Why is Rain being used a single target nuke?",
            Answer = "In some situations, using a Rain can be an efficient single target nuke at low levels.\n" ..
                "Note that PBAE spells tend to be superior for AE dps at those levels.",
        },
        ['RainDist']             = {
            DisplayName = "Min Rain Distance",
            Category = "Damage",
            Index = 4,
            ConfigType = "Advanced",
            Tooltip = "The minimum distance a target must be to use a Rain (Rain AE Range: 25').",
            Default = 30,
            Min = 0,
            Max = 100,
            FAQ = "Why does minimum rain distance matter?",
            Answer = "Rain spells, if cast close enough, can damage the caster. The AE range of a Rain is 25'.",
        },

        --Damage (AE)
        ['DoAEDamage']           = {
            DisplayName = "Do AE Damage",
            Category = "Damage (PBAE)",
            Index = 1,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['PBAETargetCnt']        = {
            DisplayName = "PBAE Tgt Cnt",
            Category = "Damage (PBAE)",
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
            Category = "Damage (PBAE)",
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
            Category = "Damage (PBAE)",
            Index = 7,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },

        -- Utility
        ['JoltAggro']            = {
            DisplayName = "Jolt Aggro %",
            Category = "Utility",
            Index = 1,
            Tooltip = "Aggro at which to use Jolt",
            Default = 90,
            Min = 1,
            Max = 100,
            FAQ = "Can I customize when to use Jolt?",
            Answer = "Yes, you can set the aggro % at which to use Jolt with the [JoltAggro] setting.",
        },
        ['DoSnare']              = {
            DisplayName = "Use Snares",
            Category = "Utility",
            Index = 3,
            Tooltip = "Use Snare Spells.",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not snaring?",
            Answer = "Make sure Use Snares is enabled in your class settings.",
        },
        ['SnareCount']           = {
            DisplayName = "Snare Max Mob Count",
            Category = "Utility",
            Index = 4,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
            Min = 1,
            Max = 99,
            FAQ = "Why is my Shadow Knight Not snaring?",
            Answer = "Make sure you have [DoSnare] enabled in your class settings.\n" ..
                "Double check the Snare Max Mob Count setting, it will prevent snare from being used if there are more than [x] mobs on aggro.",
        },
        ['DoStun']               = {
            DisplayName = "Do Stun",
            Category = "Utility",
            Index = 5,
            Tooltip = "Use your Stun Nukes (Stun with DD, not mana efficient).",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "WIP?",
            Answer =
            "WIP.",
        },
        ['HarvestManaPct']       = {
            DisplayName = "Harvest Mana %",
            Category = "Utility",
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
            Category = "Utility",
            Index = 8,
            ConfigType = "Advanced",
            Tooltip = "What Mana % to hit before using a harvest spell or aa in Combat.",
            Default = 60,
            Min = 1,
            Max = 99,
            FAQ = "How do I use Harvest Spells?",
            Answer = "Set the [HarvestManaPct] to the minimum mana % you want to be at before using a harvest spell or aa.",
        },
    },
}
