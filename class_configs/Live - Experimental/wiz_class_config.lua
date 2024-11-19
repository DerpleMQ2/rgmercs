-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

local mq        = require('mq')
local Config    = require('utils.config')
local Modules   = require("utils.modules")
local Targeting = require("utils.targeting")
local Casting   = require("utils.casting")

return {
    _version          = "Experimental - Modern Era DPS (110+) 1.1",
    _author           = "Algar",
    ['Modes']         = {
        'ModernEra',
    },
    ['OnModeChange']  = function(self, mode)
        -- if this is enabled the weaves will break.
        Config:GetSettings().WaitOnGlobalCooldown = false
    end,
    ['ItemSets']      = {
        ['Epic'] = {
            "Staff of Phenomenal Power",
            "Staff of Prismatic Power",
        },
    },
    ['AbilitySets']   = {
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
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        {
            name = 'Aggro Management',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        -- {
        -- name = 'Gift of Mana',
        -- state = 1,
        -- steps = 1,
        -- targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
        -- cond = function(self, combat_state)
        -- return combat_state == "Combat" and (not Config:GetSetting('DoGOMCheck') or Casting.DetGOMCheck())
        -- end,
        -- },
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
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Combat Buffs',
            state = 1,
            steps = 1,
            timer = 30, -- only run every 30 seconds at most.
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
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
                cond = function(self, aaName)
                    return Casting.AAReady(aaName) and not Casting.BuffActivebyName("Twincast")
                end,
            },
            {
                name = "Mana Burn",
                type = "AA",
                cond = function(self)
                    return not Casting.TargetHasBuffByName("Mana Burn") and Config:GetSetting('DoManaBurn') and Casting.HaveManaToNuke()
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
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and mq.TLO.Me.SpellReady(spell.RankName())
                end,
            },
        },
        ['Aggro Management'] =
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
                    return Casting.SelfBuffCheck(spell) and mq.TLO.FindItemCount('Peridot')() > 0
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
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and mq.TLO.Me.SpellReady(spell.RankName())
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

        },
        ['DPS'] = {
            {
                name = "CloudburstNuke",
                type = "Spell",
                cond = function(self, spell)
                    return (Casting.DetGambitCheck() or ((mq.TLO.Me.Song("Evoker's Synergy I").ID() or 0) > 0)) and Casting.TargetedSpellReady(spell)
                end,
            },
            {
                name = "VortexNuke",
                type = "Spell",
                cond = function(self, spell)
                    return not Casting.TargetHasBuff(spell) and Casting.TargetedSpellReady(spell)
                end,
            },
            {
                name = "FuseNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.TargetedSpellReady(spell)
                end,
            },
            {
                name = "FireClaw",
                type = "Spell",
                cond = function(self, spell)
                    return not Casting.BuffActiveByID(mq.TLO.Me.AltAbility("Improved Twincast").Spell.ID()) and Casting.TargetedSpellReady(spell)
                end,
            },
            {
                name = "FireEtherealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.TargetedSpellReady(spell)
                end,
            },
            {
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.TargetedSpellReady(spell)
                end,
            },
            {
                name = "TwincastSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SpellReady(spell) and not Casting.BuffActiveByID(mq.TLO.Me.AltAbility("Improved Twincast").Spell.ID())
                end,
            },
            {
                name = "FireClaw",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.BuffActiveByID(mq.TLO.Spell("Twincast").RankName.ID()) and Casting.TargetedSpellReady(spell)
                end,
            },
            {
                name = "WildNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.DetGambitCheck() and Casting.TargetedSpellReady(spell)
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.TargetedSpellReady(spell)
                end,
            },


            -- {
            -- name = "WildNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.DetGambitCheck()
            -- end,
            -- },
            -- {
            -- name = "DichoSpell",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return not Casting.DetGambitCheck() and mq.TLO.Me.Buff("Twincast").ID() == 0 and not Casting.BuffActiveByName("Improved Twincast")
            -- end,
            -- },
            -- {
            -- name = "FuseNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- local fireClaw = Modules:ExecModule("Class", "GetResolvedActionMapItem", "FireClaw")
            -- return not Casting.DetGambitCheck() and ((not fireClaw or not fireClaw()) or not mq.TLO.Me.SpellReady(fireClaw.RankName()))
            -- end,
            -- },
            -- {
            -- name = "FireNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke() and not Casting.DetGambitCheck()
            -- end,
            -- },
            -- {
            -- name = "IceNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke() and not Casting.DetGambitCheck()
            -- end,
            -- },
            -- {
            -- name = "MagicNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke() and not Casting.DetGambitCheck()
            -- end,
            -- },
            -- {
            -- name = "FireRainNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke() and not Casting.DetGambitCheck() and Targeting.GetXTHaterCount() > 2 and Targeting.GetTargetDistance() > 30
            -- end,
            -- },
            -- {
            -- name = "IceRainNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke() and not Casting.DetGambitCheck() and Targeting.GetXTHaterCount() > 2 and Targeting.GetTargetDistance() > 30
            -- end,
            -- },
            -- {
            -- name = "SnareSpell",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke() and Targeting.GetTargetDistance() > 30 and self.settings.DoSnare
            -- end,
            -- },
            -- {
            -- name = "FastMagicNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke()
            -- end,
            -- },
            -- {
            -- name = "FuseNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke()
            -- end,
            -- },
            -- {
            -- name = "FireEtherealNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke()
            -- end,
            -- },
            -- {
            -- name = "IceEtherealNuke",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke()
            -- end,
            -- },
            -- {
            -- name = "DichoSpell",
            -- type = "Spell",
            -- cond = function(self, spell)
            -- return Casting.HaveManaToNuke()
            -- end,
            -- },
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
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and mq.TLO.Me.SpellReady(spell.RankName())
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
            {
                name = Config:GetSetting('ClarityPotion'),
                type = "Item",
                cond = function(self)
                    local item = mq.TLO.FindItem(Config:GetSetting('ClarityPotion'))
                    return item() and item.Spell.Stacks() and item.TimerReady()
                end,
            },
        },
    },
    ['Spells']        = {
        {
            gem = 1,
            spells = {
                { name = "VortexNuke", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "FuseNuke", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "FireClaw", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "FireEtherealNuke", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "IceEtherealNuke", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "CloudburstNuke", },
            },
        },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "WildNuke", },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DichoSpell", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "JoltSpell", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TwincastSpell", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "GambitSpell", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SelfRune1", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                --{ name = "", },
            },
        },
    },
    ['DefaultConfig'] = {
        ['Mode']            = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes Do?",
            Answer = "This is an experimental Modern DPS mode for 110+",
        },
        ['DoChestClick']    = {
            DisplayName = "Do Chest Click",
            Category = "Utilities",
            Tooltip = "Click your chest item",
            Default = false,
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
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
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
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoRain']          = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['RainDist']        = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['RainMinHaters']   = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['RainMinTargetHP'] = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoGOMCheck']      = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
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
