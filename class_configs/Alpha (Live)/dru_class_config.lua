local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")

local _ClassConfig = {
    _version              = "Alpha 1.2 - Live (Heal Mode Only)",
    _author               = "Algar (based on default by Derple)",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return Core.IsModeActive("Heal") end,
        IsRezing = function() return Config:GetSetting('DoBattleRez') or Targeting.GetXTHaterCount() == 0 end,
    },
    ['Modes']             = {
        'Heal',
    },
    ['Cures']             = {
        CureNow = function(self, type, targetId)
            if Config:GetSetting('DoCureAA') then
                if Casting.AAReady("Radiant Cure") then
                    return Casting.UseAA("Radiant Cure", targetId)
                end
            end
            if Config:GetSetting('DoCureSpells') then
                local cureSpell = Core.GetResolvedActionMapItem('SingleTgtCure')
                if not cureSpell or not cureSpell() then return false end
                return Casting.UseSpell(cureSpell.RankName.Name(), targetId, true)
            end

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
            -- Spell Series >= 88LVL Minimum -- Only Heroic Aura that will be used
            "Icerend Aura",
            "Frostreave Aura",
            "Frostweave Aura",
            "Frostone Aura",
            "Frostcloak Aura",
            "Frostfell Aura",
            "Nightchill Aura",
        },
        ['HealingAura'] = {
            -- Healing Aura >= 55
            "Aura of Life",
            "Aura of the Grove",
        },
        ['SingleTgtCure'] = {
            -- Single Target Multi-Cure >= 84
            "Expurgated Blood",
            "Unblemished Blood",
            "Cleansed Blood",
            "Perfected Blood",
            "Purged Blood",
            "Purified Blood",
            "Sanctified Blood",
        },
        ['GroupCure'] = {
            -- Group Multi-Cure >=91
            "Wildtender's Breeze",
            "Copsetender's Breeze",
            "Bosquetender's Breeze",
            "Fawnwalker's Breeze",
            "Nightwhisper's Breeze",
        },
        ['QuickHealSurge'] = {
            -- Main Quick heal >=75
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
            -- Backup Quick heal >= LVL90
            "Rejuvenescence",
            "Revitalization",
            "Resurgence",
            "Vivification",
            "Invigoration",
            "Rejuvilation",
            "Sootheseance",
        },
        ['LongHeal1'] = {
            -- Long Heal >= 1 -- skipped 10s cast heals.
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
            -- Long Heal >= 1 -- skipped 10s cast heals.
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
            -- Quick Group heal >= LVL78
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
            -- Long Group heal >= LVL 70
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
            -- Promised Heals Line Druid
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
            -- Frost Debuff Series -- >= 74LVL -- On Bar
            "Restless Frost",
            "Glistening Frost",
            "Moonbright Frost",
            "Lustrous Frost",
            "Silver Frost",
            "Argent Frost",
            "Blanched Frost",
            "Gelid Frost",
            "Hoar Frost",
            "Primal Frost",
        },
        ['RoDebuff'] = {
            -- Ro Debuff Series -- >= 37LVL -- AA Starts at LVL (Single Target) -- On Bar Until AA
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
            "Cinch of Ro",
        },
        ['RoDebuffAE'] = {
            -- Ro AE Debuff Series -- >= 97LVL -- AA Starts at LVL
            "Glare of Ro",
            "Gaze of Ro",
            "Column of Ro",
            "Pillar of Ro",
            "Scrutiny of Ro",
        },
        ['IceBreathDebuff'] = {
            -- Ice Breath Series >= 63LVL -- On Bar
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
            "Twilight Breath",
        },
        ['SkinDebuff'] = {
            -- Skin Debuff Series >= 73LVL -- On Bar
            "Skin to Sumac",
            "Skin to Seedlings",
            "Skin to Foliage",
            "Skin to Leaves",
            "Skin to Flora",
            "Skin to Mulch",
            "Skin to Vines",
            "Skin to Lichen",
        },
        ['ReptileCombatInnate'] = {
            -- Reptile Combat Innate >= 68LVL -- On Bar
            "Defense of the Reptile",
            "Guard of the Reptile",
            "Pellicle of the Reptile",
            "Husk of the Reptile",
            "Hide of the Reptile",
            "Shell of the Reptile",
            "Carapace of the Reptile",
            "Scales of the Reptile",
            "Skin of the Reptile",
            "Bulwark of the Reptile",
        },
        ['NaturesWrathDot'] = {
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
        },
        ['HordeDot'] = {
            -- Horde Dots >= 10LVL -- On Bar
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
            -- SUN Dot Line >= 49LVL -- On Bar
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
            --, Line >= 1 LVL
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
            -- Sunray Line >= 1 LVL
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
            -- MoonBeam Dot
            "Gelid Moonbeam",
            "Algid Moonbeam",
            "Frigid Moonbeam",
            "Argent Moonbeam",
            "Pearlescent Moonbeam",
            "Opaline Moonbeam",
            "Onyx Moonbeam",
        },
        ['RemoteMoonDD'] = {
            -- Remote Moon DD >= 99LVL
            "Remote Moonchill",
            "Remote Moonrake",
            "Remote Moonflash",
            "Remote Moonflame",
            "Remote Moonfire",
        },
        ['RemoteSunDD'] = {
            -- Remote Sun DD >= 83LVL
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
            -- Roar DD >= 93LVL
            "Bloody Roar",
            "Typhonic Roar",
            "Cyclonic Roar",
            "Anabatic Roar",
            "Katabatic Roar",
            "Roar of Kolos",
        },
        ['StunDD'] = {
            -- Quick Cast Roar Series -- will be replaced by roar at lvl 93
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
            --"Dustdevil", --Does not Stun
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
            -- Winters Fire DD Line >= 73LVL -- Using for Low level Fire DD as well
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
            -- Chill DOT Line -- >= 95LVL -- Used for Burns
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
            "Hungry Vines",
            "Serpent Vines",
            "Entangle",
            "Mire Thorns",
            "Bonds of Tunare",
            "Ensnare",
            "Snare",
            "Tangling Weeds",
        },
        ['TwincastSpell'] = {
            "Twincast",
        },
        ['TwinHealNuke'] = {
            -- Druid Twincast
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
        },
        ['IceRainNuke'] = {
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
            -- Self Shield Buff
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
            -- Self mana Regen Buff
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
            -- Opaline Group Health
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
            -- Temp Health -- Focus on Tank
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
            -- Group Regen BuffAll Have Long Duration HP Regen Buffs. Not Short term Heal.
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
            -- Group Damage Shield -- Focus on the tank
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
            -- Group Damage Shield -- Combined all single and group dammage shields.
            "Legacy of Bloodspikes",
            "Legacy of Icebriars",
            "Icebriar Bulwark",
            "Legacy of Daggerspikes",
            "Daggerspike Bulwark",
            "Legacy of Daggerspurs",
            "Daggerspur Bulwark",
            "Legacy of Spikethistles",
            "Spikethistle Bulwark",
            "Legacy of Spineburrs",
            "Spineburr Bulwark",
            "Legacy of Bonebriar",
            "Bonebriar Bulwark",
            "Legacy of Brierbloom",
            "Brierbloom Bulwark",
            "Legacy of Viridithorns",
            "Viridifloral Bulwark",
            "Legacy of Viridiflora",
            "Viridifloral Shield",
            "Legacy of Nettles",
            "Legacy of Bracken",
            "Shield of Bracken",
            "Legacy of Thorn",
            "Shield of Blades",
            "Legacy of Spike",
            "Shield of Thorns",
            "Shield of Spikes",
            "Shield of Brambles",
            "Shield of Barbs",
            "Shield of Thistles",
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
            --Druid Mana Bear Growth Line
            "Nurturing Growth",
            "Nourishing Growth",
            "Sustaining Growth",
            "Bolstered Growth",
        },
        ['PetSpell'] = {
            "Nature Walker's Behest",
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
                name = "QuickGroupHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "Wildtender's Survival",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "Convergence of Spirits",
                type = "AA",
            },
            {
                name = "Blessing of Tunare",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "Apothic Dragon Spine Hammer",
                type = "Item",
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
                name = "QuickHealSurge",
                type = "Spell",
            },
            {
                name = "LongHeal1",
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
                return combat_state == "Downtime" and Core.OkayToNotHeal() and Casting.OkayToBuff() and Casting.AmIBuffable()
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
            timer = 60, -- only run every 60 seconds tops.
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Core.OkayToNotHeal() and Casting.OkayToBuff()
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 2,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal() and Casting.OkayToDebuff()
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal() and not Targeting.IsNamed(Targeting.GetAutoTarget()) and
                    Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        {
            name = 'HealBurn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck() and Core.OkayToNotHeal()
            end,
        },
        {
            name = 'TwinHeal',
            state = 1,
            steps = 1,
            load_cond = function(self) return Config:GetSetting('DoTwinHeal') and self:GetResolvedActionMapItem('TwinHealNuke') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal()
            end,
        },
        {
            name = 'HealDPS(71+)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 70 end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal()
            end,
        },
        {
            name = 'HealDPS(1-70)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 71 end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.OkayToNotHeal()
            end,
        },
    },
    ['Rotations']         = {
        ['HealDPS(71+)'] = {
            {
                name = "NaturesWrathDot",
                type = "Spell",
                cond = function(self)
                    return Casting.OkayToNuke(true)
                end,
            },
            {
                name = "SunDot",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "HordeDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and (Casting.GOMCheck() or Targeting.IsNamed(target))
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.OkayToNuke() and Targeting.LightHealsNeeded(mq.TLO.Me.TargetOfTarget)
                end,
            },
            {
                name = "RemoteSunDD",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.LightHealsNeeded(mq.TLO.Me.TargetOfTarget)
                end,
            },
            {
                name = "Nature's Frost",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.OkayToNuke(true)
                end,
            },
            {
                name = "Nature's Fire",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.OkayToNuke(true)
                end,
            },
            {
                name = "Nature's Bolt",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.OkayToNuke(true)
                end,
            },
        },
        ['HealDPS(1-70)'] = {
            {
                name = "StunDD",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke(true) and Targeting.TargetNotStunned() and not Targeting.IsNamed(target)
                end,
            },
            {
                name = "WinterFireDD",
                type = "Spell",
                cond = function(self)
                    return Casting.OkayToNuke(true)
                end,
            },
            {
                name = "Nature's Frost",
                type = "AA",
                cond = function(self)
                    return Casting.OkayToNuke(true)
                end,
            },
            {
                name = "Nature's Fire",
                type = "AA",
                cond = function(self)
                    return Casting.OkayToNuke(true)
                end,
            },
            {
                name = "Nature's Bolt",
                type = "AA",
                cond = function(self)
                    return Casting.OkayToNuke(true)
                end,
            },
        },
        ['HealBurn'] = {
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Distant Conflagration",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
            },
            {
                name = "Group Spirit of the Great Wolf",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
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
                name = "Spirit of the Wood",
                type = "AA",
            },
            {
                name = "Nature's Boon",
                type = "AA",
            },
            {
                name = "Nature's Guardian",
                type = "AA",
            },
            {
                name = "Spirit of Nature",
                type = "AA",
            },
            {
                name = "Spire of Nature",
                type = "AA",
            },
            {
                name = "TwincastSpell",
                type = "Spell",
                cond = function(self)
                    return not Casting.IHaveBuff("Twincast")
                end,
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
                name = "Blessing of Ro",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoRoDebuff') then return false end
                    local aaSpell = Casting.GetAASpell(aaName)
                    return Casting.DetAACheck(aaName) and Casting.ReagentCheck(aaSpell and aaSpell.Trigger(1) or aaName)
                end,
            },
            {
                name = "Season's Wrath",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "RoDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoRoDebuff') or Casting.CanUseAA("Blessing of Ro") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Snare'] = {
            {
                name = "Entrap",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target)
                end,
            },
            {
                name = "SnareSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Entrap") then return false end
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target)
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
                    if not Config:GetSetting('DoMoveBuffs') or (bookSpell and bookSpell.Level() or 999) > (aaSpell.Level() or 0) then return false end

                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "MoveSpells",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    local aaSpellLvl = mq.TLO.Me.AltAbility("Spirit of Eagles").Spell.Trigger(1).Level() or 0
                    if not Config:GetSetting("DoMoveBuffs") or aaSpellLvl >= (spell.Level() or 0) then return false end
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
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoTempHP') then return false end
                    return Targeting.TargetClassIs("WAR", target) and Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
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
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMA(target) and Casting.GroupBuffAACheck(aaName, target)
                end,
            },
        },
        ['Downtime'] = {
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
                    return Casting.SelfBuffAACheck(aaName) and mq.TLO.Me.AltAbility(aaName).Spell.RankName.Stacks()
                end,
            },
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
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
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
                { name = "LongHeal1", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "QuickHealSurge", cond = function(self) return mq.TLO.Me.Level() >= 75 end, },


            },
        },
        {
            gem = 3,
            spells = {
                -- [ HEAL MODE ] --
                { name = "QuickGroupHeal", cond = function(self) return mq.TLO.Me.Level() >= 90 end, },

            },
        },
        {
            gem = 4,
            spells = {

                { name = "QuickHeal", cond = function(self) return mq.TLO.Me.Level() >= 90 end, },
                { name = "StunDD", },

            },
        },
        {
            gem = 5,
            spells = {

                { name = "LongGroupHeal", cond = function(self) return mq.TLO.Me.Level() >= 70 end, },
                { name = "WinterFireDD", },

            },
        },
        {
            gem = 6,
            spells = {

                {
                    name = "RemoteSunDD",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 83 --and Config:GetSetting('DoFire')
                    end,
                },
                {
                    name = "SnareSpell",
                    cond = function(self)
                        return Config:GetSetting('DoSnare')
                    end,
                },
                -- {
                --     name = "RemoteMoonDD",
                --     cond = function(self)
                --         return mq.TLO.Me.Level() >= 83 and not Config:GetSetting('DoFire')
                --     end,
                -- },

            },
        },
        {
            gem = 7,
            spells = {

                --{ name = "FrostDebuff", cond = function(self) return mq.TLO.Me.Level() >= 74 and not Config:GetSetting('DoFire') end, },
                { name = "HordeDot", cond = function(self) return Casting.CanUseAA("Blessing of Ro") end, },
                { name = "RoDebuff", cond = function(self) return true end, },

            },
        },
        {
            gem = 8,
            spells = {

                { name = "TwinHealNuke",        cond = function(self) return Config:GetSetting("DoTwinHeal") end, },
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "TempHPBuff",          cond = function(self) return Config:GetSetting('DoTempHP') end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {

                { name = "SunDot", cond = function(self) return true end, }, --Config:GetSetting("DoFire") end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "NaturesWrathDot", cond = function(self) return true end, },

            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {

                { name = "DichoSpell",          cond = function(self) return mq.TLO.Me.Level() >= 101 end, },
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "TempHPBuff",          cond = function(self) return Config:GetSetting('DoTempHP') end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TwincastSpell",       cond = function(self) return true end, },
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "TempHPBuff",          cond = function(self) return Config:GetSetting('DoTempHP') end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TempHPBuff",          cond = function(self) return Config:GetSetting('DoTempHP') and mq.TLO.Me.NumGems() == 14 end, },
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "TempHPBuff",          cond = function(self) return Config:GetSetting('DoTempHP') end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
            },
        },
        {
            gem = 14,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "TempHPBuff",          cond = function(self) return Config:GetSetting('DoTempHP') end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
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
        ['Mode']         = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 3, },
        --TODO: This is confusing because it is actually a choice between fire and ice and should be rewritten (need time to update conditions above)
        ['DoFire']       = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = true,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoRain']       = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoMoveBuffs']  = {
            DisplayName = "Do Movement Buffs",
            Category = "Spells and Abilities",
            Tooltip = "Cast Movement Spells/AA.",
            Default = false,
            FAQ = "Why am I spamming movement buffs?",
            Answer = "Some move spells freely overwrite those of other classes, so if multiple movebuffs are being used, a buff loop may occur.\n" ..
                "Simply turn off movement buffs for the undesired class in their class options.",
        },
        ['DoNuke']       = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['NukePct']      = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
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
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = false,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
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
        ['DoRunSpeed']   = {
            DisplayName = "Orphaned",
            Type = "Custom",
            Category = "Orphaned",
            Tooltip = "Orphaned setting from live, no longer used in this config.",
            Default = true,
            FAQ = "Why do I see orphaned settings?",
            Answer = "To avoid deletion of settings when moving between configs, our beta or experimental configs keep placeholders for live settings\n" ..
                "These tabs or settings will be removed if and when the config is made the default.",
        },
        ['DoSnare']      = {
            DisplayName = "Use Snares",
            Category = "Buffs/Debuffs",
            Index = 1,
            Tooltip = "Use Snare(Snare Dot used until AA is available).",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not snaring?",
            Answer = "Make sure Use Snares is enabled in your class settings.",
        },
        ['SnareCount']   = {
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
        ['DoRoDebuff']   = {
            DisplayName = "Use Ro Debuff",
            Category = "Buffs/Debuffs",
            Index = 1,
            Tooltip = "Use Ro Debuff",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "Why is my Shadow Knight not snaring?",
            Answer = "Make sure Use Snares is enabled in your class settings.",
        },
    },
}

return _ClassConfig
