local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Logger       = require("utils.logger")

local _ClassConfig = {
    _version              = "1.1 - Live",
    _author               = "Derple, Grimmier",
    ['ModeChecks']        = {
        IsHealing  = function() return true end,
        IsCuring   = function() return Core.IsModeActive("Heal") end,
        IsRezing   = function() return Config:GetSetting('DoBattleRez') or Targeting.GetXTHaterCount() == 0 end,
        CanCharm   = function() return true end,
        IsCharming = function() return (Config:GetSetting('CharmOn') and mq.TLO.Pet.ID() == 0) end,
    },
    ['Modes']             = {
        'Heal',
        'Mana',
    },
    ['Cures']             = {
        -- this code is slightly ineffecient since we only have SingleTgtCure here, but adding more options would have us change it back to this
        -- -- since it is only run at startup, i'm fine with it. - Algar 8/29/25
        GetCureSpells = function(self)
            --(re)initialize the table for loadout changes
            self.TempSettings.CureSpells = {}

            -- Find the map for each cure spell we need
            local neededCures = {
                ['Poison'] = Casting.GetFirstMapItem({ "GroupCure", "SingleTgtCure", }),
                ['Disease'] = Casting.GetFirstMapItem({ "GroupCure", "SingleTgtCure", }),
                ['Curse'] = Casting.GetFirstMapItem({ "GroupCure", "SingleTgtCure", }),
                ['Corruption'] = Casting.GetFirstMapItem({ "CureCorrupt", "SingleTgtCure", }),
            }

            -- iterate to actually resolve the selected map item, if it is valid, add it to the cure table
            for k, v in pairs(neededCures) do
                local cureSpell = Core.GetResolvedActionMapItem(v)
                if cureSpell then
                    self.TempSettings.CureSpells[k] = cureSpell
                end
            end
        end,
        CureNow = function(self, type, targetId)
            local targetSpawn = mq.TLO.Spawn(targetId)
            if not targetSpawn and targetSpawn then return false end

            if Config:GetSetting('DoCureAA') then
                local cureAA = Casting.AAReady("Radiant Cure") and "Radiant Cure"

                -- I am finding self-cures to be less than helpful when most effects on a healer are group-wide
                -- if not cureAA and targetId == mq.TLO.Me.ID() and Casting.AAReady("Purified Spirits") then
                --     cureAA = "Purified Spirits"
                -- end

                if cureAA then
                    Logger.log_debug("CureNow: Using %s for %s on %s.", cureAA, type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
                    return Casting.UseAA(cureAA, targetId)
                end
            end

            if Config:GetSetting('DoCureSpells') then
                for effectType, cureSpell in pairs(self.TempSettings.CureSpells) do
                    if type:lower() == effectType:lower() then
                        Logger.log_debug("CureNow: Using %s for %s on %s.", cureSpell.RankName(), type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
                        return Casting.UseSpell(cureSpell.RankName(), targetId, true)
                    end
                end
            end

            Logger.log_debug("CureNow: No valid cure at this time for %s on %s.", type:lower() or "unknown", targetSpawn.CleanName() or "Unknown")
            return false
        end,
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Staff of Living Brambles",
            "Staff of Everliving Brambles",
        },
    },
    ['AbilitySets']       = {
        ['Alliance'] = {
            --, Buff >= LVL102
            "Bosquetender's Alliance,",
            "Arbor Tender's Coalition",
            "Arboreal Atonement",
            "Ferntender's Covariance",
        },
        ['FireAura'] = {
            -- Spell Series >= 87LVL Minimum
            "Wildspark Aura",
            "Wildblaze Aura",
            "Wildfire Aura",
        },
        ['IceAura'] = {
            -- Updated to 125
            -- Spell Series >= 88LVL Minimum -- Only Heroic Aura that will be used
            "Coldburst Aura",
            "Nightchill Aura",
            "Icerend Aura",
            "Frostreave Aura",
            "Frostweave Aura",
            "Frostone Aura",
            "Frostcloak Aura",
            "Frostfell Aura",
        },
        ['HealingAura'] = {
            -- Healing Aura >= 55
            "Aura of Life",
            "Aura of the Grove",
        },
        ['SingleTgtCure'] = {
            -- Single Target Multi-Cure >= 84
            "Sanctified Blood",
            "Expurgated Blood",
            "Unblemished Blood",
            "Cleansed Blood",
            "Perfected Blood",
            "Purged Blood",
            "Purified Blood",
        },
        ['CureCorrupt'] = {
            "Chant of the Zelniak",
            "Chant of the Wulthan",
            "Chant of the Kromtus",
            "Chant of Jaerol",
            "Chant of the Izon",
            "Chant of the Tae Ew",
            "Chant of the Burynai",
            "Chant of the Darkvine",
            "Chant of the Napaea",
            "Cure Corruption",
        },
        ['GroupCure'] = {
            -- Group Multi-Cure >=91
            "Nightwhisper's Breeze",
            "Wildtender's Breeze",
            "Copsetender's Breeze",
            "Bosquetender's Breeze",
            "Fawnwalker's Breeze",
        },
        ['CharmSpell'] = {
            -- Updated to 125
            -- Charm Spells >= 14
            "Beast's Bestowing",
            "Beast's Bellowing",
            "Beast's Beckoning",
            "Beast's Beseeching",
            "Beast's Bidding",
            "Beast's Bespelling",
            "Beast's Behest",
            "Beast's Beguiling",
            "Beast's Befriending",
            "Beast's Bewitching",
            "Beast's Beckoning",
            "Nature's Beckon",
            "Command of Tunare",
            "Tunare's Request",
            "Call of Karana",
            "Allure of the Wild",
            "Beguile Animals",
            "Charm Animals",
            "Befriend Animal",
        },
        ['QuickHealSurge'] = {
            -- Updated to 125
            -- Main Quick heal >=75
            "Adrenaline Fury",
            "Adrenaline Spate",
            "Adrenaline Deluge",
            "Adrenaline Barrage",
            "Adrenaline Torrent",
            "Adrenaline Rush",
            "Adrenaline Flood",
            "Adrenaline Blast",
            "Adrenaline Burst",
            "Adrenaline Swell",
            "Adrenaline Surge",
            "Adrenaline Spate",
        },
        ['QuickHeal'] = {
            -- Updated to 125
            -- Backup Quick heal >= LVL90
            "Resuscitation",
            "Sootheseance",
            "Rejuvenescence",
            "Revitalization",
            "Resurgence",
            "Vivification",
            "Invigoration",
            "Rejuvilation",
            "Sootheseance",
        },
        ['LongHeal1'] = {
            -- Updated to 125
            -- Long Heal >= 1 -- skipped 10s cast heals.
            "Vivavida",
            "Clotavida",
            "Viridavida",
            "Curavida",
            "Panavida",
            "Sterivida",
            "Sanavida",
            "Benevida",
            "Granvida",
            "Puravida",
            "Pure Life",
            "Chlorotrope",
            "Sylvan Infusion",
            "Nature's Infusion",
            "Nature's Touch",
            "Chloroblast",
            "Forest's Renewal",
            "Superior Healing",
            "Nature's Renewal",
            "Healing Water",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
        },
        ['LongHeal2'] = {
            -- Updated to 125
            -- Long Heal >= 1 -- skipped 10s cast heals.
            "Vivavida",
            "Clotavida",
            "Viridavida",
            "Curavida",
            "Panavida",
            "Sterivida",
            "Sanavida",
            "Benevida",
            "Granvida",
            "Puravida",
            "Pure Life",
            "Chlorotrope",
            "Sylvan Infusion",
            "Nature's Infusion",
            "Nature's Touch",
            "Chloroblast",
            "Forest's Renewal",
            "Superior Healing",
            "Nature's Renewal",
            "Healing Water",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
        },
        ['QuickGroupHeal'] = {
            -- Updated to 125
            -- Quick Group heal >= LVL78
            "Survival of the Heroic",
            "Survival of the Unrelenting",
            "Survival of the Favored",
            "Survival of the Auspicious",
            "Survival of the Serendipitous",
            "Survival of the Fortuitous",
            "Survival of the Prosperous",
            "Survival of the Propitious",
            "Survival of the Felicitous",
            "Survival of the Fittest",
            "Survival of the Unrelenting",
        },
        ['LongGroupHeal'] = {
            -- Updated to 125
            -- Long Group heal >= LVL 70
            "Lunacea",
            "Lunarush",
            "Lunalesce",
            "Lunasalve",
            "Lunasoothe",
            "Lunassuage",
            "Lunalleviation",
            "Lunamelioration",
            "Lunulation",
            "Crescentbloom",
            "Lunarlight",
            "Moonshadow",
            "Lunarush",
        },
        ['PromHeal'] = {
            -- Updated to 125
            -- Promised Heals Line Druid
            "Promised Regrowth",
            "Promised Reknit",
            "Promised Replenishment",
            "Promised Revitalization",
            "Promised Recovery",
            "Promised Regeneration",
            "Promised Rebirth",
            "Promised Refreshment",
            "Promised Revivification",
        },
        ['FrostDebuff'] = {
            -- Updated to 125
            -- Frost Debuff Series -- >= 74LVL -- On Bar
            "Mythic Frost",
            "Primal Frost",
            "Restless Frost",
            "Glistening Frost",
            "Moonbright Frost",
            "Lustrous Frost",
            "Silver Frost",
            "Argent Frost",
            "Blanched Frost",
            "Gelid Frost",
            "Hoar Frost",
        },
        ['RoDebuff'] = {
            -- Updated to 125
            -- Ro Debuff Series -- >= 37LVL -- AA Starts at LVL (Single Target) -- On Bar Until AA
            "Clench of Ro",
            "Cinch of Ro",
            "Clasp of Ro",
            "Cowl of Ro",
            "Crush of Ro",
            "Cowl of Ro",
            "Clutch of Ro",
            "Grip of Ro",
            "Grasp of Ro",
            "Sun's Corona",
            "Ro's Illumination",
            "Ro's Smoldering Disjunction",
            "Fixation of Ro",
            "Ro's Fiery Sundering",
        },
        ['RoDebuffAE'] = {
            -- Updated to 125
            -- Ro AE Debuff Series -- >= 97LVL -- AA Starts at LVL
            "Visage of Ro",
            "Scrutiny of Ro",
            "Glare of Ro",
            "Gaze of Ro",
            "Column of Ro",
            "Pillar of Ro",
        },
        ['IceBreathDebuff'] = {
            -- Updated to 125
            -- Ice Breath Series >= 63LVL -- On Bar
            "Algid Breath",
            "Twilight Breath",
            "Icerend Breath",
            "Frostreave Breath",
            "Blizzard Breath",
            "Frosthowl Breath",
            "Encompassing Breath",
            "Bracing Breath",
            "Coldwhisper Breath",
            "Chillvapor Breath",
            "Icefall Breath",
            "Glacier Breath",
            "E`ci's Frosty Breath",
        },
        ['SkinDebuff'] = {
            -- Updated to 125
            -- Skin Debuff Series >= 73LVL -- On Bar
            "Skin to Lichen",
            "Skin to Sumac",
            "Skin to Seedlings",
            "Skin to Foliage",
            "Skin to Leaves",
            "Skin to Flora",
            "Skin to Mulch",
            "Skin to Vines",
        },
        ['ReptileCombatInnate'] = {
            -- Updated to 125
            -- Reptile Combat Innate >= 68LVL -- On Bar
            "Chitin of the Reptile",
            "Bulwark of the Reptile",
            "Defense of the Reptile",
            "Guard of the Reptile",
            "Pellicle of the Reptile",
            "Husk of the Reptile",
            "Hide of the Reptile",
            "Shell of the Reptile",
            "Carapace of the Reptile",
            "Scales of the Reptile",
            "Skin of the Reptile",
        },
        ['NaturesWrathDot'] = {
            -- Updated to 125
            -- Natures Wrath DOT Line >= 75LVL -- On Bar
            "Nature's Fervid Wrath",
            "Nature's Blistering Wrath",
            "Nature's Fiery Wrath",
            "Nature's Withering Wrath",
            "Nature's Scorching Wrath",
            "Nature's Incinerating Wrath",
            "Nature's Searing Wrath",
            "Nature's Burning Wrath",
            "Nature's Blazing Wrath",
            "Nature's Sweltering Wrath",
            "Nature's Boiling Wrath",
        },
        ['HordeDot'] = {
            -- Updated to 125
            -- Horde Dots >= 10LVL -- On Bar
            "Horde of Hotaria",
            "Horde of Duskwigs",
            "Horde of Hyperboreads",
            "Horde of Polybiads",
            "Horde of Aculeids",
            "Horde of Mutillids",
            "Horde of Vespids",
            "Horde of Scoriae",
            "Horde of the Hive",
            "Horde of Fireants",
            "Swarm of Fireants",
            "Wasp Swarm",
            "Swarming Death",
            "Winged Death",
            "Drifting Death",
            "Drones of Doom",
            "Creeping Crud",
            "Stinging Swarm",
        },
        ['SunDot'] = {
            -- Updated to 125
            -- SUN Dot Line >= 49LVL -- On Bar
            "Sunscald",
            "Sunpyre",
            "Sunshock",
            "Sunflame",
            "Sunflash",
            "Sunblaze",
            "Sunscorch",
            "Sunbrand",
            "Sunsinge",
            "Sunsear",
            "Sunscorch",
            "Vengeance of the Sun",
            "Vengeance of Tunare",
            "Vengeance of Nature",
            "Vengeance of the Wild",
        },
        ['SunMoonDot'] = {
            -- Updated to 125
            --, Line >= 1 LVL
            "Mythical Moonbeam",
            "Searing Sunray",
            "Onyx Moonbeam",
            "Tenebrous Sunray",
            "Opaline Moonbeam",
            "Erupting Sunray",
            "Pearlescent Moonbeam",
            "Overwhelming Sunray",
            "Argent Moonbeam",
            "Consuming Sunray",
            "Frigid Moonbeam",
            "Incinerating Sunray",
            "Algid Moonbeam",
            "Blazing Sunray",
            "Gelid Moonbeam",
            "Scorching Sunray",
            "Withering Sunray",
            "Torrid Sunray",
            "Blistering Sunray",
            "Immolation of the Sun",
            "Sylvan Embers",
            "Immolation of Ro",
            "Breath of Ro",
            "Immolate",
            "Flame Lick",
        },
        ['SunrayDot'] = {
            -- Updated to 125
            -- Sunray Line >= 1 LVL
            "Searing Sunray",
            "Tenebrous Sunray",
            "Erupting Sunray",
            "Overwhelming Sunray",
            "Consuming Sunray",
            "Incinerating Sunray",
            "Blazing Sunray",
            "Scorching Sunray",
            "Withering Sunray",
            "Torrid Sunray",
            "Blistering Sunray",
            "Immolation of the Sun",
            "Sylvan Embers",
            "Immolation of Ro",
            "Breath of Ro",
            "Immolate",
            "Flame Lick",
        },
        ['MoonBeamDot'] = {
            -- Updated to 125
            -- MoonBeam Dot
            "Gelid Moonbeam",
            "Algid Moonbeam",
            "Frigid Moonbeam",
            "Argent Moonbeam",
            "Pearlescent Moonbeam",
            "Opaline Moonbeam",
            "Onyx Moonbeam",
            "Mythical Moonbeam",
        },
        ['RemoteMoonDD'] = {
            -- Updated to 125
            -- Remote Moon DD >= 99LVL
            "Remote Moonshiver",
            "Remote Moonchill",
            "Remote Moonrake",
            "Remote Moonflash",
            "Remote Moonflame",
            "Remote Moonfire",
        },
        ['RemoteSunDD'] = {
            -- Updated to 125
            -- Remote Sun DD >= 83LVL
            "Remote Sunscorch",
            "Remote Sunbolt",
            "Remote Sunshock",
            "Remote Sunblaze",
            "Remote Sunflash",
            "Remote Sunfire",
            "Remote Sunburst",
            "Remote Sunflare",
            "Remote Manaflux",
        },
        ['RoarDD'] = {
            -- Updated to 125
            -- Roar DD >= 93LVL
            "Tempest Roar",
            "Bloody Roar",
            "Typhonic Roar",
            "Cyclonic Roar",
            "Anabatic Roar",
            "Katabatic Roar",
            "Roar of Kolos",
        },
        ['QuickRoarDD'] = {
            -- Updated to 125
            -- Quick Cast Roar Series -- will be replaced by roar at lvl 93
            "Revelry of the Stormborn",
            "Bedlam of the Sotrmborn",
            "Maelstrom of the Stormborn",
            "Thunderbolt of the Stormborn",
            "Typhoon of the Stormborn",
            "Whirlwind of the Stormborn",
            "Cyclone of the Stormborn",
            "Shear of the Stormborn",
            "Squall of the Stormborn",
            "Tempest of the Stormborn",
            "Gale of the Stormborn",
            "Stormwatch",
            "Storm's Fury",
            "Dustdevil",
            "Fury of Air",
        },
        ['DichoSpell'] = {
            -- Dicho Spell >= 101LVL
            "Ecliptic Winds",
            "Composite Winds",
            "Dissident Winds",
            "Dichotomic Winds",
            "Reciprocal Winds",
        },
        ['WinterFireDD'] = {
            -- Updated to 125
            -- Winters Fire DD Line >= 73LVL -- Using for Low level Fire DD as well
            "Winder's Wildgale",
            "Winter's Wildbrume",
            "Winter's Wildshock",
            "Winter's Wildblaze",
            "Winter's Wildflame",
            "Winter's Wildfire",
            "Winter's Sear",
            "Winter's Pyre",
            "Winter's Flare",
            "Winter's Blaze",
            "Winter's Flame",
            "Solstice Strike",
            "Sylvan Fire",
            "Summer's Flame",
            "Wildfire",
            "Scoriae",
            "Starfire",
            "Firestrike",
            "Combust",
            "Ignite",
            "Burst of Fire",
            "Burst of Flame",
        },
        ['ChillDot'] = {
            -- Updated to 125
            -- Chill DOT Line -- >= 95LVL -- Used for Burns
            "Chill of the Ferntender",
            "Chill of the Dusksage Tender",
            "Chill of the Arbor Tender",
            "Chill of the Wildtender",
            "Chill of the Copsetender",
            "Chill of the Visionary",
            "Chill of the Natureward",
        },
        ['RootSpells'] = {
            -- Root Spells
            "Vinelash Assault",
            "Vinelash Cascade",
            "Spore Spiral",
            "Savage Roots",
            "Earthen Roots",
            "Entrapping Roots",
            "Engorging Roots",
            "Engulfing Roots",
            "Enveloping Roots",
            "Ensnaring Roots",
            "Grasping Roots",
        },
        ['SnareSpell'] = {
            -- Snare Spells
            "Thornmaw Vines",
            "Serpent Vines",
            "Entangle",
            "Mire Thorns",
            "Bonds of Tunare",
            "Ensnare",
            "Snare",
            "Tangling Weeds",
        },
        ['TwinHealNuke'] = {
            -- Updated to 125
            -- Druid Twincast
            "Sunbliss Blessing",
            "Sundew Blessing",
            "Sunrise Blessing",
            "Sunbreeze Blessing",
            "Sunbeam Blessing",
            "Sunfire Blessing",
            "Sunflash Blessing",
            "Sunrake Blessing",
            "Sunwarmth Blessing",
        },
        ['IceNuke'] = {
            -- Updated to 125
            --Ice Nuke
            "Ice",
            "Frost",
            "Moonfire",
            "Winter's Frost",
            "Glitterfrost",
            "Rime Crystals",
            "Hoar Crystals",
            "Glaciating Crystals",
            "Argent Crystals",
            "Sterlingfrost Crystals",
            "Gelid Crystals",
            "Frostweave Crystals",
            "Frostreave Crystals",
            "Icerend Crystals",
            "Moonwhisper Crystals",
            "Coldbite Crystals",
        },
        ['IceRainNuke'] = {
            -- Updated to 125
            "Cascade of Hail",
            "Pogonip",
            "Avalanche",
            "Blizzard",
            "Winter's Storm",
            "Tempest Wind",
            "Cloudburst Hail",
            "Torrential Hail",
            "Cascading Hail",
            "Cyclonic Hail",
            "Crashing Hail",
            "Hailstorm",
            "Plummeting Hail",
            "Plunging Hail",
            "Tempestuous Hail",
            "Howling Hail",
            "Unrelenting Hail",
        },
        ['ShroomPet'] = {
            --Druid Mushroom DOT Pet Line >= 84LVL --used for mana savings
            "Mycelid Assault",
            "Saprophyte Assault",
            "Chytrid Assault",
            "Fungusoid Assault",
            "Sporali Storm",
            "Sporali Assault",
            "Myconid Assault",
            "Polyporous Assault",
            "Blast of Hypergrowth",
        },
        ['IceDD'] = {
            -- Ice Nuke DD --Gap Filler
            "Moonfire",
            "Frost",
        },
        ['SelfShield'] = {
            -- Updated to 125
            -- Self Shield Buff
            "Bramblespike Coat",
            "Shadespine Coat",
            "Icebriar Coat",
            "Daggerspike Coat",
            "Daggerspur Coat",
            "Spikethistle Coat",
            "Spineburr Coat",
            "Bonebriar Coat",
            "Brierbloom Coat",
            "Viridithorn Coat",
            "Viridicoat",
            "Nettlecoat",
            "Brackencoat",
            "Bladecoat",
            "Thorncoat",
            "Spikecoat",
            "Bramblecoat",
            "Barbcoat",
            "Thistlecoat",
        },
        ['SelfManaRegen'] = {
            -- Updated to 125
            -- Self mana Regen Buff
            "Mask of the Ferntender",
            "Mask of the Dusksage Tender",
            "Mask of the Arbor Tender",
            "Mask of the Wildtender",
            "Mask of the Copsetender",
            "Mask of the Bosquetender",
            "Mask of the Thicket Dweller",
            "Mask of the Arboreal",
            "Mask of the Raptor",
            "Mask of the Shadowcat",
            "Mask of the Wild",
            "Mask of the Forest",
            "Mask of the Stalker",
            "Mask of the Hunter",
        },
        ['HPTypeOneGroup'] = {
            -- Updated to 125
            -- Opaline Group Health
            "Emberquartz Blessing",
            "Luclinite Blessing",
            "Opaline Blessing",
            "Arcronite Blessing",
            "Shieldstone Blessing",
            "Granitebark Blessing",
            "Stonebark Blessing",
            "Blessing of the Timbercore",
            "Blessing of the Heartwood",
            "Blessing of the Ironwood",
            "Blessing of the Direwild",
            "Blessing of Steeloak",
            "Blessing of the Nine",
            "Protection of the Glades",
            "Protection of Nature",
            "Protection of Diamond",
            "Protection of Steel",
            "Protection of Rock",
            "Protection of Wood",
            'Skin like Wood',
        },
        ['TempHPBuff'] = {
            -- Updated to 125
            -- Temp Health -- Focus on Tank
            "Overwhelming Growth",
            "Fervent Growth",
            "Frenzied Growth",
            "Savage Growth",
            "Ferocious Growth",
            "Rampant Growth",
            "Unfettered Growth",
            "Untamed Growth",
            "Wild Growth",
        },
        ['GroupRegenBuff'] = {
            -- Updated to 125
            -- Group Regen BuffAll Have Long Duration HP Regen Buffs. Not Short term Heal.
            "Talisman of the Unforgettable",
            "Talisman of the Tenacious",
            "Talisman of the Enduring",
            "Talisman of the Unwavering",
            "Talisman of the Faithful",
            "Talisman of the Steadfast",
            "Talisman of the Indomitable",
            "Talisman of the Relentless",
            "Talisman of the Resolute",
            "Talisman of the Stalwart",
            "Pack Regeneration",
            "Pack Chloroplast",
            "Regrowth of the Grove",
            "Blessing of Oak",
            "Blessing of Replenishment",
        },
        ['AtkBuff'] = {
            -- Single Target Attack Buff for MeleeGuard
            "Mammoth's Force",
            "Mammoth's Strength",
            "Lion's Strength",
            "Nature's Might",
            "Girdle of Karana",
            "Storm Strength",
            "Strength of Stone",
            "Strength of Earth",
        },
        ['GroupDmgShield'] = {
            -- Updated to 125
            -- Group Damage Shield -- Focus on the tank
            "Legacy of Bramblespikes",
            "Legacy of Bloodspikes",
            "Legacy of Icebriars",
            "Legacy of Daggerspikes",
            "Legacy of Daggerspurs",
            "Legacy of Spikethistles",
            "Legacy of Spineburrs",
            "Legacy of Bonebriar",
            "Legacy of Brierbloom",
            "Legacy of Viridithorns",
            "Legacy of Viridiflora",
            "Legacy of Nettles",
            "Legacy of Bracken",
            "Legacy of Thorn",
            "Legacy of Spike",
        },
        ['MoveSpells'] = {
            "Spirit of Wolf",
            "Pack Spirit",
            "Spirit of Eagle",
            "Flight of Eagles",
            "Spirit of Falcons",
            "Flight of Falcons",
        },
        ['ManaBear'] = {
            -- Updated to 125
            --Druid Mana Bear Growth Line
            "Nurturing Growth",
            "Nourishing Growth",
            "Sustaining Growth",
            "Bolstered Growth",
            "Emboldened Growth",
        },
        ['PetSpell'] = {
            "Nature Walker's Behest",
        },
        ['SingleDS'] = {
            -- Updated to 125
            --Single Target Damage Shield
            "Shield of Thistles",
            "Shield of Barbs",
            "Shield of Brambles",
            "Shield of Spikes",
            "Shield of Thorns",
            "Shield of Blades",
            "Shield of Bracken",
            "Nettle Shield",
            "Viridifloral Shield",
            "Viridifloral Bulwark",
            "Brierbloom Bulwark",
            "Bonebriar Bulwark",
            "Spineburr Bulwark",
            "Spikethistle Bulwark",
            "Daggerspur Bulwark",
            "Daggerspike Bulwark",
            "Icebriar Bulwark",
            "Nightspire Bulwark",
            "Bramblespike Bulwark",
        },
    },
    ['HealRotationOrder'] = {
        {
            name  = 'BigHealPoint',
            state = 1,
            steps = 1,
            cond  = function(self, target) return Targeting.BigHealsNeeded(target) end,
        },
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ['BigHealPoint'] = {
            {
                name = "QuickHealSurge",
                type = "Spell",
            },
            {
                name = "QuickGroupHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "Blessing of Tunare",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "Wildtender's Survival",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "Swarm of Fireflies",
                type = "AA",
            },
            {
                name = "Convergence of Spirits",
                type = "AA",
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ['GroupHealPoint'] = {
            {
                name = "Blessing of Tunare",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "QuickGroupHeal",
                type = "Spell",
            },
            {
                name = "Wildtender's Survival",
                type = "AA",
            },
            {
                name = "LongGroupHeal",
                type = "Spell",
            },

        },
        ['MainHealPoint'] = {
            {
                name = "QuickHeal",
                type = "Spell",
            },
            {
                name = "LongHeal1",
                type = "Spell",
            },
            {
                name = "LongHeal2",
                type = "Spell",
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            load_cond = function(self) return Core.OnEMU() end,
            cond = function(self, combat_state)
                if not Config:GetSetting('DoPet') or mq.TLO.Me.Pet.ID() ~= 0 then return false end
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.OkayToPetBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff()
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        {
            name = 'TwinHeal',
            state = 1,
            steps = 1,
            load_cond = function(self) return Config:GetSetting('DoTwinHeal') and self:GetResolvedActionMapItem('TwinHealNuke') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Config:GetSetting('DoTwinHeal') and Core.IsHealing() and
                    Targeting.GetTargetPctHPs() <= Config:GetSetting('AutoAssistAt')
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },

    },
    ['Rotations']         = {
        ['DPS'] = {
            {
                name = "SunrayDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Heal") and Config:GetSetting('DoFire') and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot') and
                        Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "ChillDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Heal") and not Config:GetSetting('DoFire') and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
            },
            {
                name = "Season's Wrath",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Mana") and Casting.DetAACheck(aaName) and Targeting.GetTargetPctHPs() > 75
                end,
            },
            {
                name = "SunDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") or
                        (Core.IsModeActive("Heal") and Config:GetSetting('DoFire')) and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "HordeDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return (Core.IsModeActive("Mana") or Config:GetSetting('DoNuke')) and Casting.DetSpellCheck(spell) and Targeting.GetTargetPctHPs() > 60 and
                        mq.TLO.Me.PctMana() > 50
                end,
            },
            {
                name = "RemoteSunDD",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoFire') and Casting.DetSpellCheck(spell) and Config:GetSetting('DoNuke') and
                        Targeting.GetTargetPctHPs() < Config:GetSetting('NukePct')
                end,
            },
            {
                name = "RemoteMoonDD",
                type = "Spell",
                cond = function(self, spell)
                    return not Config:GetSetting('DoFire') and Casting.DetSpellCheck(spell) and Config:GetSetting('DoNuke') and
                        Targeting.GetTargetPctHPs() < Config:GetSetting('NukePct')
                end,
            },
            {
                name = "SunMoonDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot') and
                        Targeting.GetTargetLevel() >= mq.TLO.Me.Level()
                end,
            },
            {
                name = "NaturesWrathDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "ShroomPet",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana")
                        and Casting.DetSpellCheck(spell) and mq.TLO.Me.PctMana() < 60
                end,
            },
            {
                name = "WinterFireDD",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DetSpellCheck(spell) and Config:GetSetting('DoFire') and Casting.OkayToNuke()
                end,
            },
            {
                name = "IceRainNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DetSpellCheck(spell) and not Config:GetSetting('DoFire') and Config:GetSetting('DoRain') and
                        Casting.OkayToNuke()
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DetSpellCheck(spell) and not Config:GetSetting('DoFire') and
                        Casting.OkayToNuke()
                end,
            },
            {
                name = "Nature's Frost",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Mana") and mq.TLO.Me.PctMana() > 50 and
                        (not Core.IsModeActive("Heal") or (Core.IsModeActive("Heal") and not Config:GetSetting('DoFire') and Casting.OkayToNuke()))
                end,
            },
            {
                name = "Nature's Fire",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() > 50 and Config:GetSetting('DoNuke') and
                        (not Core.IsModeActive("Heal") or (Core.IsModeActive("Heal") and Config:GetSetting('DoFire') and Casting.OkayToNuke()))
                end,
            },
            {
                name = "Nature's Bolt",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Mana") and mq.TLO.Me.PctMana() > 50
                end,
            },
        },
        ['Burn'] = {
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Nature's Boon",
                type = "AA",
            },
            {
                name = "Spirit of the Wood",
                type = "AA",
            },
            {
                name = "Swarm of the Fireflies",
                type = "AA",
            },
            {
                name = "Distant Conflagration",
                type = "AA",
            },
            {
                name = "Nature's Guardian",
                type = "AA",
            },
            {
                name = "Spirits of Nature",
                type = "AA",
            },
            {
                name = "Destructive Vortex",
                type = "AA",
            },
            {
                name = "Nature's Fury",
                type = "AA",
            },
            {
                name = "Spire of Nature",
                type = "AA",
            },
        },
        ['TwinHeal'] = {
            {
                name = "TwinHealNuke",
                type = "CustomFunc",
                cond = function(self, spell, target)
                    if Casting.IHaveBuff("Healing Twincast") then return false end
                    return Casting.CastReady(spell)
                end,
                custom_func = function(self)
                    local twinHeal = Core.GetResolvedActionMapItem("TwinHealNuke")
                    Casting.UseSpell(twinHeal.RankName(), Core.GetMainAssistId(), false, false, false, 0)
                end,
            },
        },
        ['Debuff'] = {
            {
                name = "RoDebuff",
                type = "Spell",
                cond = function(self, spell) return Casting.DetSpellCheck(spell) end,
            },
            {
                name = "Blessing of Ro",
                type = "AA",
                cond = function(self, aaName, target)
                    local aaSpell = Casting.GetAASpell(aaName)
                    return Casting.DetAACheck(aaName) and Casting.ReagentCheck(aaSpell and aaSpell.Trigger(1) or aaName)
                end,
            },
            {
                name = "SkinDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and not Targeting.TargetBodyIs(target, "Undead") and
                        not Targeting.TargetBodyIs(target, "Undead Pet")
                end,
            },
            {
                name = "IceBreathDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return not Config:GetSetting('DoFire') and Casting.DetSpellCheck(spell) and Targeting.GetAutoTargetPctHPs() < Config:GetSetting('NukePct') and
                        Config:GetSetting('DoNuke')
                end,
            },
            {
                name = "FrostDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return not Config:GetSetting('DoFire') and Casting.DetSpellCheck(spell) and Targeting.GetAutoTargetPctHPs() < Config:GetSetting('NukePct') and
                        Config:GetSetting('DoNuke')
                end,
            },
            {
                name = "Entrap",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoSnare') and Casting.DetAACheck(aaName) and Targeting.GetAutoTargetPctHPs() < 50
                end,
            },
            {
                name = "SnareSpell",
                type = "Spell",
                cond = function(self, spell)
                    if Casting.CanUseAA("Entrap") then return false end
                    return Config:GetSetting('DoSnare') and Casting.DetSpellCheck(spell) and Targeting.GetAutoTargetPctHPs() < 50
                end,
            },
            {
                name = "Season's Wrath",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Swarm of Fireflies",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMA(target) and Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "GroupDmgShield",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Spirit of Eagles",
                type = "AA",
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())
                end,
                cond = function(self, aaName, target)
                    local bookSpell = self:GetResolvedActionMapItem('MoveSpells')
                    local aaSpell = Casting.GetAASpell(aaName)
                    if not Config:GetSetting('DoRunSpeed') or (bookSpell and bookSpell.Level() or 999) > (aaSpell.Level() or 0) then return false end

                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "MoveSpells",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    local aaSpellLvl = mq.TLO.Me.AltAbility("Spirit of Eagles").Spell.Trigger(1).Level() or 0
                    if not Config:GetSetting("DoRunSpeed") or aaSpellLvl >= (spell.Level() or 0) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Targeting.TargetIsAMelee(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "TempHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return true end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoTempHP') then return false end
                    return Targeting.TargetClassIs("WAR", target) and Casting.GroupBuffCheck(spell, target) --PAL/SHD have their own temp hp buff
                end,
            },
            {
                name = "HPTypeOneGroup",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHPBuff') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ReptileCombatInnate",
                type = "Spell",
                active_cond = function(self, spell) return true end,
                cond = function(self, spell, target)
                    return Targeting.TargetClassIs({ "WAR", "SHD", }, target) and Casting.GroupBuffCheck(spell, target) --does not stack with PAL innate buff
                end,
            },
            {
                name = "GroupRegenBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupRegen') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Wrath of the Wild",
                type = "AA",
                active_cond = function(self, aaName) return true end,
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMA(target) and Casting.GroupBuffAACheck(aaName, target)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "SelfShield",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfManaRegen",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) and not (spell.Name() == "Mask of the Hunter" and mq.TLO.Zone.Indoor()) end,
            },
            {
                name = "IceAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.BaseName()) end,
                cond = function(self, spell) return (spell and spell() and not Casting.AuraActiveByName(spell.BaseName())) end,
            },
            {
                name = "HealingAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.BaseName()) end,
                cond = function(self, spell)
                    if self:GetResolvedActionMapItem('IceAura') then return false end
                    return (spell and spell() and not Casting.AuraActiveByName(spell.BaseName()))
                end,
            },
            {
                name = "ManaBear",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return (spell and spell() and spell.MyCastTime() or 999999) < 30000 end,
            },
            {
                name = "Group Spirit of the Great Wolf",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Spirit of the Great Wolf",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Preincarnation",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function() return mq.TLO.Me.Pet.ID() ~= 0 end,
                post_activate = function(self, spell, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                {
                    name = "DichoSpell",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 101 and
                            Core.IsModeActive("Mana")
                    end,
                },
                { name = "LongHeal1", },
            },
        },
        {
            gem = 2,
            spells = {
                -- [ MANA MODE ] --
                {
                    name = "QuickHeal",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 75 and
                            Core.IsModeActive("Mana")
                    end,
                },
                {
                    name = "SnareSpell",
                    cond = function(self)
                        return Config:GetSetting('DoSnare')
                            and Core.IsModeActive("Mana")
                    end,
                },
                -- [ HEAL MODE ] --
                { name = "QuickHealSurge", cond = function(self) return mq.TLO.Me.Level() >= 75 end, },
                { name = "LongHeal2",      cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "WinterFireDD",   cond = function(self) return Config:GetSetting("DoFire") end, },
                { name = "IceNuke",        cond = function(self) return true end, },

            },
        },
        {
            gem = 3,
            spells = {
                -- [ MANA MODE ] --
                { name = "WinterFireDD",   cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "QuickGroupHeal", cond = function(self) return mq.TLO.Me.Level() >= 90 end, },
                { name = "CharmSpell",     cond = function(self) return Config:GetSetting('CharmOn') end, },
                { name = "QuickRoarDD",    cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "IceRainNuke",    cond = function(self) return true end, },
            },
        },
        {
            gem = 4,
            spells = {
                -- [ BOTH MODES ] --
                { name = "QuickHeal",       cond = function(self) return mq.TLO.Me.Level() >= 90 end, },
                -- [ MANA MODE ] --
                { name = "QuickRoarDD",     cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "HordeDot",        cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "RoDebuff",        cond = function(self) return Config:GetSetting("DoFire") end, },
                { name = "IceBreathDebuff", cond = function(self) return true end, },
            },
        },
        {
            gem = 5,
            spells = {
                -- [ MANA MODE ] --
                { name = "HordeDot",      cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "LongGroupHeal", cond = function(self) return mq.TLO.Me.Level() >= 70 end, },
                { name = "SunDot",        cond = function(self) return true end, },
                { name = "SunrayDot",     cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "SunrayDot",     cond = function(self) return true end, },
            },
        },
        {
            gem = 6,
            spells = {
                -- [ BOTH MODES ] --
                {
                    name = "RemoteSunDD",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 83 and Config:GetSetting('DoFire')
                    end,
                },
                {
                    name = "RemoteMoonDD",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 83 and not Config:GetSetting('DoFire')
                    end,
                },
                -- [ MANA MODE ] --
                { name = "RoDebuff",            cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "SunrayDot",           cond = function(self) return mq.TLO.Me.Level() >= 73 end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
                { name = "SnareSpell",          cond = function(self) return Config:GetSetting('DoSnare') end, },
                -- [ Fall Back ]--
                { name = "HordeDot",            cond = function(self) return true end, },
            },
        },
        {
            gem = 7,
            spells = {
                -- [ MANA MODE ] --
                { name = "SunMoonDot",          cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "FrostDebuff",         cond = function(self) return mq.TLO.Me.Level() >= 74 and not Config:GetSetting('DoFire') end, },
                { name = "ReptileCombatInnate", cond = function(self) return Casting.CanUseAA("Blessing of Ro") end, },
                { name = "RoDebuff",            cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "HordeDot",            cond = function(self) return true end, },
                { name = "SnareSpell",          cond = function(self) return Config:GetSetting('DoSnare') end, },
            },
        },
        {
            gem = 8,
            spells = {
                -- [ MANA MODE ] --
                {
                    name = "SunDot",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 49 and
                            Core.IsModeActive("Mana")
                    end,
                },
                { name = "RootSpells",   cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "TwinHealNuke", cond = function(self) return Config:GetSetting("DoTwinHeal") end, },
                { name = "GroupCure",    cond = function(self) return true end, },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                {
                    name = "IceBreathDebuff",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 63 and
                            Core.IsModeActive("Mana")
                    end,
                },
                { name = "IceDD",           cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "SunDot",          cond = function(self) return Config:GetSetting("DoFire") end, },
                { name = "IceBreathDebuff", cond = function(self) return true end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                { name = "NaturesWrathDot", cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "TempHPBuff",      cond = function(self) return true end, },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                { name = "TempHPBuff",          cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "DichoSpell",          cond = function(self) return mq.TLO.Me.Level() >= 101 end, },
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                {
                    name = "LongHeal1",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 99 and
                            Core.IsModeActive("Mana")
                    end,
                },
                { name = "ChillDot",            cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Alliance", cond = function(self) return Config:GetSetting("DoAlliance") end, },
            },
        },
    },
    ['HelperFunctions']   = {
        DoRez = function(self, corpseId, ownerName)
            local rezAction = false
            local okayToRez = Casting.OkayToRez(corpseId)
            local combatState = mq.TLO.Me.CombatState():lower() or "unknown"

            if combatState == "combat" and Config:GetSetting('DoBattleRez') and Core.OkayToNotHeal() then
                if mq.TLO.FindItem("Staff of Forbidden Rites")() and mq.TLO.Me.ItemReady("Staff of Forbidden Rites")() then
                    rezAction = okayToRez and Casting.UseItem("Staff of Forbidden Rites", corpseId)
                elseif Casting.AAReady("Call of the Wild") and not mq.TLO.Spawn(string.format("PC =%s", ownerName))() then
                    rezAction = okayToRez and Casting.UseAA("Call of the Wild", corpseId, true, 1)
                end
            elseif combatState == "active" or combatState == "resting" then
                if Casting.AAReady("Rejuvenation of Spirit") then
                    rezAction = okayToRez and Casting.UseAA("Rejuvenation of Spirit", corpseId, true, 1)
                elseif not Casting.CanUseAA("Rejuvenation of Spirit") and Casting.SpellReady(mq.TLO.Spell("Incarnate Anew"), true) then
                    rezAction = okayToRez and Casting.UseSpell("Incarnate Anew", corpseId, true, true)
                end
            end

            return rezAction
        end,
    },
    --TODO: These are nearly all in need of Display and Tooltip updates.
    ['DefaultConfig']     = {
        ['Mode']         = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "What do the different Modes Do?",
            Answer = "Heal Mode will focus on healing and buffing.\nMana Mode will focus on DPS and Mana Management.",
        },
        --TODO: This is confusing because it is actually a choice between fire and ice and should be rewritten (need time to update conditions above)
        ['DoFire']       = {
            DisplayName = "Cast Fire Spells",
            Category = "Spells and Abilities",
            Tooltip = "if Enabled Use Fire Spells, Disabled Use Ice Spells",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Can I choose between Fire or Ice based Nukes?",
            Answer = "Yes, you can choose between Fire and Ice based Nukes by toggling [DoFire].\n" ..
                "When [DoFire] is enabled, we will use Fire based Nukes.\n" ..
                "When [DoFire] is disabled, we will use Ice based Nukes.",
        },
        ['DoRain']       = {
            DisplayName = "Cast Rain Spells",
            Category = "Spells and Abilities",
            Tooltip = "Use Rain Spells",
            Default = true,
            FAQ = "I like Rain spells, can I use them?",
            Answer = "Yes, you can enable [DoRain] to use Rain spells.",
        },
        ['DoRunSpeed']   = {
            DisplayName = "Use Movement Buffs",
            Category = "Spells and Abilities",
            Tooltip = "Use Run/Lev buffs.",
            Default = true,
            FAQ = "Sometimes I group with a bard and don't need to worry about Run Speed, can I disable it?",
            Answer = "Yes, you can disable [DoRunSpeed] to prevent casting Run Speed spells.",
        },
        ['DoNuke']       = {
            DisplayName = "Cast Spells",
            Category = "Spells and Abilities",
            Tooltip = "Use Spells",
            Default = true,
            FAQ = "Why am I not Nuking?",
            Answer = "Make sure [DoNuke] is enabled. If you are in Heal Mode, you may not be nuking.\n" ..
                "Also double check [NukePct] to ensure you are nuking at the correct health percentage.",
        },
        ['NukePct']      = {
            DisplayName = "Cast Spells",
            Category = "Spells and Abilities",
            Tooltip = "Use Spells",
            Default = 90,
            Min = 1,
            Max = 100,
            FAQ = "Why am I nuking at 10% health?",
            Answer = "Make sure [NukePct] is set to the correct health percentage you want to start nuking at.",
        },
        ['DoSnare']      = {
            DisplayName = "Cast Snares",
            Category = "Spells and Abilities",
            Tooltip = "Enable casting Snare spells.",
            Default = true,
            FAQ = "Why am I not Snaring?",
            Answer = "Make sure [DoSnare] is enabled. If you are in Heal Mode, you may not be snaring.",
        },
        ['DoChestClick'] = {
            DisplayName = "Do Chest Click",
            Category = "Utilities",
            Tooltip = "Click your chest item",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "Why am I not clicking my chest item?",
            Answer = "Make sure [DoChestClick] is enabled. If you are in Heal Mode, you may not be clicking your chest item.",
        },
        ['DoDot']        = {
            DisplayName = "Cast DOTs",
            Category = "Spells and Abilities",
            Tooltip = "Enable casting Damage Over Time spells.",
            Default = true,
            FAQ = "Why am I not DOTing?",
            Answer = "Make sure [DoDot] is enabled. If you are in Heal Mode, you may not be DOTing.",
        },
        ['DoTwinHeal']   = {
            DisplayName = "Cast Twin Heal Nuke",
            Category = "Spells and Abilities",
            Tooltip = "Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "I have Twincastig AA, can I use it?",
            Answer = "Yes, you can enable [DoTwinHeal] to use Twin Heal Nuke spells.",
        },
        ['DoHPBuff']     = {
            DisplayName = "Group HP Buff",
            Category = "Spells and Abilities",
            Tooltip = "Use your group HP Buff. Disable as desired to prevent conflicts with CLR or PAL buffs.",
            Default = true,
            FAQ = "Why am I in a buff war with my Paladin or Druid? We are constantly overwriting each other's buffs.",
            Answer = "Disable [DoHPBuff] to prevent issues with Aego/Symbol lines overwriting. Alternatively, you can adjust the settings for the other class instead.",
        },
        ['DoTempHP']     = {
            DisplayName = "Temp HP Buff",
            Category = "Spells and Abilities",
            Tooltip = "Use Temp HP Buff (Only for WAR, other tanks have their own)",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why isn't my Temp HP Buff being used?",
            Answer = "You either have [DoTempHP] disabled, or you don't have a Warrior in your group (Other tanks have their own Temp HP Buff).",
        },
        ['DoGroupRegen'] = {
            DisplayName = "Group Regen Buff",
            Category = "Spells and Abilities",
            Tooltip = "Use your Group Regen buff.",
            Default = true,
            FAQ = "Why am I spamming my Group Regen buff?",
            Answer = "Certain Shaman and Druid group regen buffs report cross-stacking. You should deselect the option on one of the PCs if they are grouped together.",
        },
    },
}

return _ClassConfig
