local mq           = require('mq')
local RGMercUtils  = require("utils.rgmercs_utils")
local Set          = require('mq.Set')

local _ClassConfig = {
    _version              = "1.1 Beta",
    _author               = "Derple, Grimmier",
    ['ModeChecks']        = {
        IsHealing  = function() return true end,
        IsCuring   = function() return RGMercUtils.IsModeActive("Heal") end,
        IsRezing   = function() return RGMercUtils.GetSetting('DoBattleRez') or RGMercUtils.GetXTHaterCount() == 0 end,
        CanCharm   = function() return true end,
        IsCharming = function() return (RGMercUtils.GetSetting('CharmOn') and mq.TLO.Pet.ID() == 0) end,
    },
    ['Modes']             = {
        'Heal',
        'Mana',
    },
    ['Cures']             = {
        CureNow = function(self, type, targetId)
            if RGMercUtils.AAReady("Radiant Cure") then
                return RGMercUtils.UseAA("Radiant Cure", targetId)
            end
            local cureSpell = RGMercUtils.GetResolvedActionMapItem('SingleTgtCure')
            if not cureSpell or not cureSpell() then return false end
            return RGMercUtils.UseSpell(cureSpell.RankName.Name(), targetId, true)
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
            "Arboreal Atonement",
            "Arbor Tender's Coalition",
            "Bosquetender's Alliance",
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
        ['NaturesWrathDOT'] = {
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
        ['HordeDOT'] = {
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
        ['SunDOT'] = {
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
        ['SunrayDOT'] = {
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
        ['MoonBeamDOT'] = {
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
        ['ChillDOT'] = {
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
        ['SnareSpells'] = {
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
            "Mask of the Hunter",
            "Mask of the Stalker",
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
            -- Group Movement Series Spells -- Mix of group target and single target but will require the same dannet checks
            "Flight of Falcons",
            "Flight of Eagles",
            -- [] = "Spirit of Scale",
            "Feral Pack",
            "Share Form of the Great Wolf",
            "Pack Shrew",
            "Pack Spirit",
            "Share Wolf Form",
            "Spirit of Falcons",
            "Spirit of Eagle",
            "Spirit of the Shrew",
            -- [] = "Scale of Wolf",
            "Spirit of Wolf",
        },
        ['ManaBear'] = {
            -- Updated to 125
            --Druid Mana Bear Growth Line
            -- [] = "Nature Walker's Behest",
            "Nurturing Growth",
            "Nourishing Growth",
            "Sustaining Growth",
            "Bolstered Growth",
            "Emboldened Growth",
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
            cond  = function(self, target) return (target.PctHPs() or 999) < RGMercUtils.GetSetting('BigHealPoint') end,
        },
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target)
                return (mq.TLO.Group.Injured(RGMercUtils.GetSetting('GroupHealPoint'))() or 0) >
                    RGMercUtils.GetSetting('GroupInjureCnt')
            end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return (target.PctHPs() or 999) < RGMercUtils.GetSetting('MainHealPoint') end,
        },
    },
    ['HealRotations']     = {
        ["BigHealPoint"] = {
            {
                name = "QuickHealSurge",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "QuickGroupHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.PCSpellReady(spell) and (target.ID() or 0) == RGMercUtils.GetMainAssistId()
                end,
            },
            {
                name = "Blessing of Tunare",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName) and (target.ID() or 0) == RGMercUtils.GetMainAssistId()
                end,
            },
            {
                name = "Wildtender's Survival",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName) and (target.ID() or 0) == RGMercUtils.GetMainAssistId()
                end,
            },
            {
                name = "Swarm of Fireflies",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Convergence of Spirits",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
        },
        ["GroupHealPoint"] = {
            {
                name = "Blessing of Tunare",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.AAReady(aaName) and (target.PctHPs() or 999) < RGMercUtils.GetSetting('BigHealPoint')
                end,
            },
            {
                name = "QuickGroupHeal",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "Wildtender's Survival",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "LongGroupHeal",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },

        },
        ["MainHealPoint"] = {
            {
                name = "QuickHeal",
                type = "Spell",
                cond = function(self, _) return true end,
            },
            {
                name = "LongHeal1",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
            {
                name = "LongHeal2",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.PCSpellReady(spell)
                end,
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and RGMercUtils.DoBuffCheck()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                local groupIds = { mq.TLO.Me.ID(), }
                local count = mq.TLO.Group.Members()
                for i = 1, count do
                    local rezSearch = string.format("pccorpse %s radius 100 zradius 50", mq.TLO.Group.Member(i).DisplayName())
                    if RGMercUtils.GetSetting('BuffRezables') or mq.TLO.SpawnCount(rezSearch)() == 0 then
                        table.insert(groupIds, mq.TLO.Group.Member(i).ID())
                    end
                end
                return groupIds
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and RGMercUtils.DoBuffCheck()
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == RGMercConfig.Globals.AutoTargetID and { RGMercConfig.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
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
            name = 'Twin Heal',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercUtils.GetMainAssistId(), } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and RGMercUtils.GetSetting('DoTwinHeal') and RGMercUtils.IsHealing() and
                    RGMercUtils.GetTargetPctHPs() <= RGMercUtils.GetSetting('AutoAssistAt') and not RGMercUtils.Feigning()
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
    ['Rotations']         = {
        ['DPS'] = {
            {
                name = "SunrayDOT",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Heal")
                        and RGMercUtils.GetSetting('DoFire')
                        and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) and
                        RGMercUtils.GetSetting('DoDot') and
                        mq.TLO.FindItemCount(spell.NoExpendReagentID(1)())() >= 1
                end,
            },
            {
                name = "ChillDOT",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Heal")
                        and not RGMercUtils.GetSetting('DoFire')
                        and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) and
                        RGMercUtils.GetSetting('DoDot')
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Season's Wrath",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Mana") and RGMercUtils.DetAACheck(mq.TLO.Me.AltAbility(aaName).ID()) and
                        RGMercUtils.GetTargetPctHPs() > 75
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.IsModeActive("Mana") and RGMercUtils.GetSetting('DoChestClick') and item() and
                        item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
            {
                name = "SunDOT",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Mana") or (RGMercUtils.IsModeActive("Heal")
                            and RGMercUtils.GetSetting('DoFire')) and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell)
                        and RGMercUtils.GetSetting('DoDot')
                end,
            },
            {
                name = "HordeDOT",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Mana")
                        and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) and
                        RGMercUtils.GetSetting('DoDot')
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return (RGMercUtils.IsModeActive("Mana") or RGMercUtils.GetSetting('DoNuke'))
                        and RGMercUtils.DetSpellCheck(spell) and RGMercUtils.GetTargetPctHPs() > 60 and
                        mq.TLO.Me.PctMana() > 50
                end,
            },
            {
                name = "RemoteSunDD",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoFire')
                        and RGMercUtils.DetSpellCheck(spell) and RGMercUtils.GetSetting('DoNuke') and
                        RGMercUtils.GetTargetPctHPs() < RGMercUtils.GetSetting('NukePct')
                end,
            },
            {
                name = "RemoteMoonDD",
                type = "Spell",
                cond = function(self, spell)
                    return not RGMercUtils.GetSetting('DoFire')
                        and RGMercUtils.DetSpellCheck(spell) and RGMercUtils.GetSetting('DoNuke') and
                        RGMercUtils.GetTargetPctHPs() < RGMercUtils.GetSetting('NukePct')
                end,
            },
            {
                name = "SunMoonDot",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Mana")
                        and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) and
                        RGMercUtils.GetSetting('DoDot') and
                        RGMercUtils.GetTargetLevel() >= mq.TLO.Me.Level()
                end,
            },
            {
                name = "NaturesWrathDOT",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Mana")
                        and RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) and
                        RGMercUtils.GetSetting('DoDot')
                end,
            },
            {
                name = "ShroomPet",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Mana")
                        and RGMercUtils.DetSpellCheck(spell) and mq.TLO.Me.PctMana() < 60
                end,
            },
            {
                name = "WinterFireDD",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Mana")
                        and RGMercUtils.DetSpellCheck(spell) and RGMercUtils.GetSetting('DoFire') and
                        (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck())
                end,
            },
            {
                name = "IceRainNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Mana")
                        and RGMercUtils.DetSpellCheck(spell) and not RGMercUtils.GetSetting('DoFire') and
                        RGMercUtils.GetSetting('DoRain') and
                        (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck())
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Mana")
                        and RGMercUtils.DetSpellCheck(spell) and not RGMercUtils.GetSetting('DoFire') and
                        (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck())
                end,
            },
            {
                name = "Nature's Frost",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Mana") and RGMercUtils.DetAACheck(mq.TLO.Me.AltAbility(aaName).ID()) and
                        mq.TLO.Me.PctMana() > 50 and
                        (not RGMercUtils.IsModeActive("Heal") or (RGMercUtils.IsModeActive("Heal") and not RGMercUtils.GetSetting('DoFire') and (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck())))
                end,
            },
            {
                name = "Nature's Fire",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.DetAACheck(mq.TLO.Me.AltAbility(aaName).ID()) and mq.TLO.Me.PctMana() > 50 and
                        RGMercUtils.GetSetting('DoNuke') and
                        (not RGMercUtils.IsModeActive("Heal") or (RGMercUtils.IsModeActive("Heal") and RGMercUtils.GetSetting('DoFire') and (RGMercUtils.ManaCheck() or RGMercUtils.BurnCheck())))
                end,
            },
            {
                name = "Nature's Bolt",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.IsModeActive("Mana") and RGMercUtils.DetAACheck(mq.TLO.Me.AltAbility(aaName).ID()) and
                        mq.TLO.Me.PctMana() > 50
                end,
            },
        },
        ['Burn'] = {
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.GetSetting('DoChestClick') and item() and item.Spell.Stacks() and
                        item.TimerReady() == 0
                end,
            },
            {
                name = "Nature's Boon",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Spirit of the Wood",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Swarm of the Fireflies",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Distant Conflagration",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Nature's Guardian",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Spirits of Nature",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Destructive Vortex",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Nature's Fury",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
            {
                name = "Spire of Nature",
                type = "AA",
                cond = function(self, aaName)
                    return true
                end,
            },
        },
        ['Twin Heal'] = {
            {
                name = "TwinHealNuke",
                type = "Spell",
                retries = 0,
                cond = function(self, spell) return RGMercUtils.PCSpellReady(spell) and not RGMercUtils.SongActiveByName("Healing Twincast") end,
            },
        },
        ['Debuff'] = {
            {
                name = "RoDebuff",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.DotSpellCheck(RGMercUtils.GetSetting('HPStopDOT'), spell) end,
            },
            {
                name = "Blessing of Ro",
                type = "AA",
                cond = function(self, aaName, target)
                    return not RGMercUtils.TargetHasBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1)) and
                        mq.TLO.FindItemCount(mq.TLO.Me.AltAbility("Blessing of Ro").Spell.Trigger(1).NoExpendReagentID(1)())() >
                        0
                end,
            },
            {
                name = "SkinDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.DetSpellCheck(spell) and not RGMercUtils.TargetBodyIs(target, "Undead") and
                        not RGMercUtils.TargetBodyIs(target, "Undead Pet")
                end,
            },
            {
                name = "IceBreathDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return not RGMercUtils.GetSetting('DoFire') and RGMercUtils.DetSpellCheck(spell) and
                        RGMercUtils.GetTargetPctHPs(target) < RGMercUtils.GetSetting('NukePct') and
                        RGMercUtils.GetSetting('DoNuke')
                end,
            },
            {
                name = "FrostDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return not RGMercUtils.GetSetting('DoFire') and RGMercUtils.DetSpellCheck(spell) and
                        RGMercUtils.GetTargetPctHPs(target) < RGMercUtils.GetSetting('NukePct') and
                        RGMercUtils.GetSetting('DoNuke')
                end,
            },
            {
                name = "Entrap",
                tooltip = "AA: Snare",
                type = "AA",
                cond = function(self)
                    return RGMercUtils.GetSetting('DoSnare') and RGMercUtils.DetAACheck(219)
                end,
            },
            {
                name = "SnareSpells",
                type = "Spell",
                cond = function(self, spell, target)
                    return RGMercUtils.GetSetting('DoSnare') and RGMercUtils.DetSpellCheck(spell) and RGMercUtils.GetTargetPctHPs(target) < 50
                end,
            },
            {
                name = "Season's Wrath",
                type = "AA",
                cond = function(self, aaName, target)
                    return RGMercUtils.DetAACheck(mq.TLO.Me.AltAbility(aaName).ID())
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "GroupDmgShield",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "MoveSpells",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell)
                    return RGMercUtils.GetSetting("DoRunSpeed") and
                        RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "AtkBuff",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell, target)
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return not RGMercUtils.TargetHasBuff(spell) and RGMercUtils.SpellStacksOnTarget(spell) and
                        Set.new({ "BRD", "SHD", "PAL", "WAR", "ROG", "BER", "MNK", "RNG", }):contains((target.Class.ShortName() or ""))
                end,
            },
            {
                name = "TempHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return true end,
                cond = function(self, spell, target)
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return RGMercConfig.Constants.RGTank:contains(target.Class.ShortName()) and not RGMercUtils.TargetHasBuff(spell)
                        and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "HPTypeOneGroup",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell, target)
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return not RGMercUtils.TargetHasBuff(spell, target) and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "ReptileCombatInnate",
                type = "Spell",
                active_cond = function(self, spell) return true end,
                cond = function(self, spell, target)
                    return not RGMercUtils.TargetHasBuff(spell) and target and target and
                        Set.new({ "SHD", "WAR", }):contains(target.Class.ShortName())
                end,
            },
            {
                name = "GroupRegenBuff",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell, target)
                    -- force the target for StacksTarget to work.
                    RGMercUtils.SetTarget(target.ID() or 0)
                    return not RGMercUtils.TargetHasBuff(spell, target) and RGMercUtils.SpellStacksOnTarget(spell)
                end,
            },
            {
                name = "Wrath of the Wild",
                type = "AA",
                active_cond = function(self, aaName) return true end,
                cond = function(self, aaName, target)
                    return not RGMercUtils.TargetHasBuff(mq.TLO.Me.AltAbility(aaName).Spell) and
                        target.ID() == RGMercUtils.GetMainAssistId()
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "SelfShield",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfManaRegen",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) and mq.TLO.Zone.Outdoor() end,
            },
            {
                name = "IceAura",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.AuraActiveByName(spell.BaseName()) end,
                cond = function(self, spell) return (spell and spell() and not RGMercUtils.AuraActiveByName(spell.BaseName())) end,
            },
            {
                name = "ManaBear",
                type = "Spell",
                active_cond = function(self, spell) return RGMercUtils.BuffActiveByID(spell.ID()) end,
                cond = function(self, spell) return (spell and spell() and spell.MyCastTime() or 999999) < 30000 end,
            },
            {
                name = "Group Spirit of the Great Wolf",
                type = "AA",
                active_cond = function(self, aaName)
                    return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName)
                        .Spell.ID())
                end,
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Spirit of the Great Wolf",
                type = "AA",
                active_cond = function(self, aaName)
                    return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName)
                        .Spell.ID())
                end,
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and mq.TLO.Me.AltAbility(aaName).Spell.RankName.Stacks()
                end,
            },
            {
                name = "Preincarnation",
                type = "AA",
                active_cond = function(self, aaName)
                    return RGMercUtils.BuffActiveByID(mq.TLO.Me.AltAbility(aaName)
                        .Spell.ID())
                end,
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName)
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
                            RGMercUtils.IsModeActive("Mana")
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
                            RGMercUtils.IsModeActive("Mana")
                    end,
                },
                {
                    name = "SnareSpells",
                    cond = function(self)
                        return RGMercUtils.GetSetting('DoSnare')
                            and RGMercUtils.IsModeActive("Mana")
                    end,
                },
                -- [ HEAL MODE ] --
                { name = "QuickHealSurge", cond = function(self) return mq.TLO.Me.Level() >= 75 end, },
                { name = "LongHeal2",      cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "WinterFireDD",   cond = function(self) return RGMercUtils.GetSetting("DoFire") end, },
                { name = "IceNuke",        cond = function(self) return true end, },

            },
        },
        {
            gem = 3,
            spells = {
                -- [ MANA MODE ] --
                { name = "WinterFireDD",   cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "QuickGroupHeal", cond = function(self) return mq.TLO.Me.Level() >= 90 end, },
                { name = "CharmSpell",     cond = function(self) return RGMercUtils.GetSetting('CharmOn') end, },
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
                { name = "QuickRoarDD",     cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "HordeDOT",        cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "RoDebuff",        cond = function(self) return RGMercUtils.GetSetting("DoFire") end, },
                { name = "IceBreathDebuff", cond = function(self) return true end, },
            },
        },
        {
            gem = 5,
            spells = {
                -- [ MANA MODE ] --
                { name = "HordeDOT",      cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "LongGroupHeal", cond = function(self) return mq.TLO.Me.Level() >= 70 end, },
                { name = "SunDOT",        cond = function(self) return true end, },
                { name = "SunrayDOT",     cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "SunrayDOT",     cond = function(self) return true end, },
            },
        },
        {
            gem = 6,
            spells = {
                -- [ BOTH MODES ] --
                {
                    name = "RemoteSunDD",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 83 and RGMercUtils.GetSetting('DoFire')
                    end,
                },
                {
                    name = "RemoteMoonDD",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 83 and not RGMercUtils.GetSetting('DoFire')
                    end,
                },
                -- [ MANA MODE ] --
                { name = "RoDebuff",            cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "SunrayDOT",           cond = function(self) return mq.TLO.Me.Level() >= 73 end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
                { name = "SnareSpells",         cond = function(self) return RGMercUtils.GetSetting('DoSnare') end, },
                -- [ Fall Back ]--
                { name = "HordeDOT",            cond = function(self) return true end, },
            },
        },
        {
            gem = 7,
            spells = {
                -- [ MANA MODE ] --
                { name = "SunMoonDot",          cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "FrostDebuff",         cond = function(self) return mq.TLO.Me.Level() >= 74 and not RGMercUtils.GetSetting('DoFire') end, },
                { name = "ReptileCombatInnate", cond = function(self) return RGMercUtils.CanUseAA("Blessing of Ro") end, },
                { name = "RoDebuff",            cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "HordeDOT",            cond = function(self) return true end, },
                { name = "SnareSpells",         cond = function(self) return RGMercUtils.GetSetting('DoSnare') end, },
            },
        },
        {
            gem = 8,
            spells = {
                -- [ MANA MODE ] --
                {
                    name = "SunDOT",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 49 and
                            RGMercUtils.IsModeActive("Mana")
                    end,
                },
                { name = "RootSpells",   cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "TwinHealNuke", cond = function(self) return RGMercUtils.GetSetting("DoTwinHeal") end, },
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
                            RGMercUtils.IsModeActive("Mana")
                    end,
                },
                { name = "IceDD",           cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "SunDOT",          cond = function(self) return RGMercUtils.GetSetting("DoFire") end, },
                { name = "IceBreathDebuff", cond = function(self) return true end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                { name = "NaturesWrathDOT", cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "TempHPBuff",      cond = function(self) return true end, },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                { name = "TempHPBuff",          cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
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
                            RGMercUtils.IsModeActive("Mana")
                    end,
                },
                { name = "ChillDOT",            cond = function(self) return RGMercUtils.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Alliance", cond = function(self) return RGMercUtils.GetSetting("DoAlliance") end, },
            },
        },
    },
    ['HelperFunctions']   = {
        DoRez = function(self, corpseId)
            if not RGMercUtils.PCSpellReady(mq.TLO.Spell("Incarnate Anew")) and
                not mq.TLO.FindItem("Staff of Forbidden Rites")() and
                not RGMercUtils.CanUseAA("Rejuvenation of Spirit") and
                not RGMercUtils.CanUseAA("Call of the Wild") then
                return false
            end

            RGMercUtils.SetTarget(corpseId)

            local target = mq.TLO.Target

            if not target or not target() then return false end

            if mq.TLO.Target.Distance() > 25 then
                RGMercUtils.DoCmd("/corpse")
            end

            local targetClass = target.Class.ShortName()

            if mq.TLO.Me.CombatState():lower() == "combat" and (targetClass == "dru" or targetClass == "clr" or RGMercUtils.GetSetting('DoBattleRez')) then
                if mq.TLO.FindItem("Staff of Forbidden Rites")() and mq.TLO.Me.ItemReady("=Staff of Forbidden Rites")() then
                    return RGMercUtils.UseItem("Staff of Forbidden Rites", corpseId)
                end

                if RGMercUtils.AAReady("Call of the Wild") then
                    return RGMercUtils.UseAA("Call of the Wild", corpseId)
                end
            else
                if RGMercUtils.CanUseAA("Rejuvenation of Spirit") then
                    return RGMercUtils.UseAA("Rejuvenation of Spirit", corpseId)
                end

                if RGMercUtils.PCSpellReady(mq.TLO.Spell("Incarnate Anew")) then
                    return RGMercUtils.UseSpell("Incarnate Anew", corpseId, true, true)
                end
            end

            return false
        end,
    },
    --TODO: These are nearly all in need of Display and Tooltip updates.
    ['DefaultConfig']     = {
        ['Mode']         = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 3, },
        --TODO: This is confusing because it is actually a choice between fire and ice and should be rewritten (need time to update conditions above)
        ['DoFire']       = { DisplayName = "Cast Fire Spells", Category = "Spells and Abilities", Tooltip = "Use Fire Spells", RequiresLoadoutChange = true, Default = true, },
        ['DoRain']       = { DisplayName = "Cast Rain Spells", Category = "Spells and Abilities", Tooltip = "Use Rain Spells", Default = true, },
        ['DoRunSpeed']   = { DisplayName = "Cast Run Speed", Category = "Spells and Abilities", Tooltip = "Cast Run Speed Spells", Default = true, },
        ['DoNuke']       = { DisplayName = "Cast Spells", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = true, },
        ['NukePct']      = { DisplayName = "Cast Spells", Category = "Spells and Abilities", Tooltip = "Use Spells", Default = 90, Min = 1, Max = 100, },
        ['DoSnare']      = { DisplayName = "Cast Snares", Category = "Spells and Abilities", Tooltip = "Enable casting Snare spells.", Default = true, },
        ['HPStopDOT']    = { DisplayName = "HP Stop DOTs", Category = "Spells and Abilities", Tooltip = "Stop casting DOTs when the mob hits [x] HP %.", Default = 30, Min = 1, Max = 100, },
        ['DoChestClick'] = { DisplayName = "Do Chest Click", Category = "Utilities", Tooltip = "Click your chest item", Default = true, },
        ['DoDot']        = { DisplayName = "Cast DOTs", Category = "Spells and Abilities", Tooltip = "Enable casting Damage Over Time spells.", Default = true, },
        ['DoTwinHeal']   = { DisplayName = "Cast Twin Heal Nuke", Category = "Spells and Abilities", Tooltip = "Use Twin Heal Nuke Spells", RequiresLoadoutChange = true, Default = true, },
    },
}

return _ClassConfig
