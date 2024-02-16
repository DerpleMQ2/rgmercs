local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

_ClassConfig      = {
    _version              = "0.1a",
    _author               = "Derple",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsTanking = function() return RGMercUtils.IsModeActive("PetTank") end,
    },
    ['Modes']             = {
        'Fire',
        'PetTank',
    },
    ['OnModeChange']      = function(self, mode)
        if mode == "PetTank" then
            RGMercUtils.DoCmd("/pet taunt on")
            RGMercUtils.DoCmd("/pet resume on")
            RGMercConfig:GetSettings().AutoAssistAt  = 100
            RGMercConfig:GetSettings().StayOnTarget  = false
            RGMercConfig:GetSettings().DoAutoEngage  = true
            RGMercConfig:GetSettings().DoAutoTarget  = true
            RGMercConfig:GetSettings().AllowMezBreak = true
        else
            RGMercUtils.DoCmd("/pet taunt off")
            RGMercConfig:GetSettings().AutoAssistAt = 98
            RGMercConfig:GetSettings().StayOnTarget = true
        end
    end,
    ['ItemSets']          = {
        ['Epic'] = {
            "Focus of Primal Elements",
            "Staff of Elemental Essence",
        },
    },
    ['AbilitySets']       = {
        --- Nukes
        ['SwarmPet'] = {
            -- Swarm Pet* >= LVL 70
            "Ravening Servant",
            "Roiling Servant",
            "Riotous Servant",
            "Reckless Servant",
            "Remorseless Servant",
            "Relentless Servant",
            "Ruthless Servant",
            "Ruinous Servant",
            "Rumbling Servant",
            "Rancorous Servant",
            "Rampaging Servant",
            "Raging Servant",
            "Rage of Zomm",
        },
        ['SpearNuke1'] = {
            -- Spear Nuke* >= LVL 70
            "Spear of Molten Dacite",
            "Spear of Molten Luclinite",
            "Spear of Molten Komatiite",
            "Spear of Molten Arcronite",
            "Spear of Molten Shieldstone",
            "Spear of Blistersteel",
            "Spear of Molten Steel",
            "Spear of Magma",
            "Spear of Ro",
        },
        ['SpearNuke2'] = {
            -- Spear Nuke* >= LVL 70
            "Spear of Molten Dacite",
            "Spear of Molten Luclinite",
            "Spear of Molten Komatiite",
            "Spear of Molten Arcronite",
            "Spear of Molten Shieldstone",
            "Spear of Blistersteel",
            "Spear of Molten Steel",
            "Spear of Magma",
            "Spear of Ro",
        },
        ['ChaoticNuke'] = {
            -- Chaotic Nuke with Beneficial Effect >= LVL69
            "Chaotic Magma",
            "Chaotic Calamity",
            "Chaotic Pyroclasm",
            "Chaotic Inferno",
            "Chaotic Fire",
            "Fickle Magma",
            "Fickle Flames",
            "Fickle Flare",
            "Fickle Blaze",
            "Fickle Pyroclasm",
            "Fickle Inferno",
            "Fickle Fire",
        },
        ['FireNuke1'] = {
            -- Fire Nuke 1 <= LVL <= 70
            "Cremating Sands",
            "Ravaging Sands",
            "Incinerating Sands",
            "Crash of Sand",
            "Blistering Sands",
            "Searing Sands",
            "Broiling Sands",
            "Blast of Sand",
            "Burning Sands",
            "Burst of Sand",
            "Strike of Sand",
            "Torrid Sands",
            "Scorching Sands",
            "Scalding Sands",
            "Sun Vortex",
            "Star Strike",
            "Ancient: Nova Strike",
            "Burning Sand",
            "Shock of Fiery Blades",
            "Char",
            "Blaze",
            "Shock of Flame",
            "Burn",
            "Burst of Flame",
        },
        ['FireNuke2'] = {
            -- Fire Nuke 1 <= LVL <= 70
            "Cremating Sands",
            "Ravaging Sands",
            "Incinerating Sands",
            "Crash of Sand",
            "Blistering Sands",
            "Searing Sands",
            "Broiling Sands",
            "Blast of Sand",
            "Burning Sands",
            "Burst of Sand",
            "Strike of Sand",
            "Torrid Sands",
            "Scorching Sands",
            "Scalding Sands",
            "Sun Vortex",
            "Star Strike",
            "Ancient: Nova Strike",
            "Burning Sand",
            "Shock of Fiery Blades",
            "Char",
            "Blaze",
            "Shock of Flame",
            "Burn",
            "Burst of Flame",
        },
        ['MagicNuke1'] = {
            -- Nuke 1 <= LVL <= 69
            "Shock of Memorial Steel",
            "Shock of Carbide Steel",
            "Shock of Burning Steel",
            "Shock of Arcronite Steel",
            "Shock of Darksteel",
            "Shock of Blistersteel",
            "Shock of Argathian Steel",
            "Shock of Ethereal Steel",
            "Shock of Discordant Steel",
            "Shock of Cineral Steel",
            "Shock of Silvered Steel",
            "Blade Strike",
            "Rock of Taelosia",
            "Black Steel",
            "Shock of Steel",
            "Shock of Swords",
            "Shock of Spikes",
            "Shock of Blades",
        },
        ['MagicNuke2'] = {
            -- Nuke 1 <= LVL <= 69
            "Shock of Memorial Steel",
            "Shock of Carbide Steel",
            "Shock of Burning Steel",
            "Shock of Arcronite Steel",
            "Shock of Darksteel",
            "Shock of Blistersteel",
            "Shock of Argathian Steel",
            "Shock of Ethereal Steel",
            "Shock of Discordant Steel",
            "Shock of Cineral Steel",
            "Shock of Silvered Steel",
            "Blade Strike",
            "Rock of Taelosia",
            "Black Steel",
            "Shock of Steel",
            "Shock of Swords",
            "Shock of Spikes",
            "Shock of Blades",
        },
        ['FireBoltNuke'] = {
            -- Fire Bolt Nukes
            "Bolt of Molten Dacite",
            "Bolt of Molten Olivine",
            "Bolt of Molten Komatiite",
            "Bolt of Skyfire",
            "Bolt of Molten Shieldstone",
            "Bolt of Molten Magma",
            "Bolt of Molten Steel",
            "Bolt of Rhyolite",
            "Bolt of Molten Scoria",
            "Bolt of Molten Dross",
            "Bolt of Molten Slag",
            "Bolt of Jerikor",
            "Firebolt of Tallon",
            "Seeking Flame of Seukor",
            "Scars of Sigil",
            "Lava Bolt",
            "Cinder Bolt",
            "Bolt of Flame",
            "Flame Bolt",
        },
        ['MagicBoltNuke1'] = {
            -- Magic Bolt Nukes
            "Luclinite Bolt",
            "Komatiite Bolt",
            "Korascian Bolt",
            "Meteoric Bolt",
            "Iron Bolt",
        },
        ['MagicBoltNuke2'] = {
            -- Magic Bolt Nukes
            "Luclinite Bolt",
            "Komatiite Bolt",
            "Korascian Bolt",
            "Meteoric Bolt",
            "Iron Bolt",
        },
        ['TwinCast'] = {
            "Twincast",
        },
        ['BeamNuke'] = {
            -- Beam Frontal AOE Spell*
            "Beam of Molten Dacite",
            "Beam of Molten Olivine",
            "Beam of Molten Komatiite",
            "Beam of Molten Rhyolite",
            "Beam of Molten Shieldstone",
            "Beam of Brimstone",
            "Beam of Molten Steel",
            "Beam of Rhyolite",
            "Beam of Molten Scoria",
            "Beam of Molten Dross",
            "Beam of Molten Slag",
        },
        ['RainNuke'] = {
            --- Rain AOE Spell*
            "Rain of Molten Dacite",
            "Rain of Molten Olivine",
            "Rain of Molten Komatiite",
            "Rain of Molten Rhyolite",
            "Coronal Rain",
            "Rain of Blistersteel",
            "Rain of Molten Steel",
            "Rain of Rhyolite",
            "Rain of Molten Scoria",
            "Rain of Molten Dross",
            "Rain of Molten Slag",
            "Rain of Jerikor",
            "Sun Storm",
            "Sirocco",
            "Rain of Lava",
            "Rain of Fire",
        },
        ['MagicRainNuke'] = {
            -- Magic Rain
            "rain of Kukris",
            "Rain of Falchions",
            "Rain of Blades",
            "Rain of Spikes",
            "Rain Of Swords",
            "ManaStorm",
            "Maelstrom of Electricity",
            "Maelstrom of Thunder",
        },
        ['VolleyNuke'] = {
            -- Volley Nuke - Pet buff*
            "Fusillade of Many",
            "Barrage of Many",
            "Shockwave of Many",
            "Volley of Many",
            "Storm of Many",
            "Salvo of Many",
            "Strike of Many",
            "Clash of Many",
            "Jolt of Many",
            "Shock of Many",
        },
        ['SummonedNuke'] = {
            -- Unnatural Nukes >70
            "Dismantle the Unnatural",
            "Unmend the Unnatural",
            "Obliterate the Unnatural",
            "Repudiate the Unnatural",
            "Eradicate the Unnatural",
            "Exterminate the Unnatural",
            "Abolish the Divergent",
            "Annihilate the Divergent",
            "Annihilate the Anomalous",
            "Annihilate the Aberrant",
            "Annihilate the Unnatural",
        },
        ['MaloNuke'] = {
            -- Shock/Malo Combo Line
            "Memorial Steel Malosinera",
            "Carbide Malosinetra",
            "Blistersteel Malosenia",
            "Darksteel Malosenete",
            "Arcronite Malosinata",
            "Burning Malosinara",
        },
        --- Buffs
        ['SelfShield'] = {
            "Shield of Memories",
            "Shield of Shadow",
            "Shield of Restless Ice",
            "Shield of Scales",
            "Shield of the Pellarus",
            "Shield of the Dauntless",
            "Shield of Bronze",
            "Shield of Dreams",
            "Shield of the Void",
            "Prime Guard",
            "Prime Shielding",
            "Elemental Aura",
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
        ['ShortDurDmgShield'] = {
            -- Use at the start of the DPS loop
            "Boiling Skin",
            "Scorching Skin",
            "Burning Skin",
            "Blistering Skin",
            "Coronal Skin",
            "Infernal Skin",
            "Molten Skin",
            "Blazing Skin",
            "Torrid Skin",
            "Brimstoneskin",
            "Searing Skin",
            "Scorching Skin",
            "Ancient: Veil of Pyrilonus",
            "Pyrilen Skin",
        },
        ['LongDurDmgShield'] = {
            -- Preferring group buffs for ease. Included all Single target Now as well.
            "Circle of Forgefire Coat",
            "Forgefire Coat",
            "Circle of Emberweave Coat",
            "Emberweave Coat",
            "Circle of Igneous Skin",
            "Igneous Coat",
            "Circle of the Inferno",
            "Inferno Coat",
            "Circle of Flameweaving",
            "Flameweave Coat",
            "Circle of Flameskin",
            "Flameskin",
            "Circle of Embers",
            "Embercoat",
            "Circle of Dreamfire",
            "Dreamfire Coat",
            "Circle of Brimstoneskin",
            "Brimstoneskin",
            "Circle of Lavaskin",
            "Lavaskin",
            "Circle of Magmaskin",
            "Magmaskin",
            "Circle of Fireskin",
            "Fireskin",
            "Maelstrom of Ro",
            "FlameShield of Ro",
            "Aegis of Ro",
            "Cadeau of Flame",
            "Boon of Immolation",
            "Shield of Lava",
            "Barrier of Combustion",
            "Inferno Shield",
            "Shield of Flame",
            "Shield of Fire",
        },
        ['ManaRegenBuff'] = {
            -- LVL58 (Transon's Phantasmal Protection) and up to avoid reagent usage
            "Courageous Guardian",
            "Relentless Guardian",
            "Restless Guardian",
            "Burning Guardian",
            "Praetorian Guardian",
            "Phantasmal Guardian",
            "Splendrous Guardian",
            "Cognitive Guardian",
            "Empyrean Guardian",
            "Eidolic Guardian",
            "Phantasmal Warden",
            "Phantom Shield",
            "Xegony's Phantasmal Guard",
            "Transon's Phantasmal Protection",
        },
        ['AllianceBuff'] = {
            "Firebound Conjunction",
            "Firebound Coalition",
            "Firebound Covenant",
            "Firebound Alliance",
        },
        ['SurgeDS1'] = {
            -- ShortDuration DS (Slot 4)
            "Surge of Shadow",
            "Surge of Arcanum",
            "Surge of Shadowflares",
            "Surge of Thaumacretion",
        },
        ['SurgeDS2'] = {
            -- ShortDuration DS (Slot 4)
            "Surge of Shadow",
            "Surge of Arcanum",
            "Surge of Shadowflares",
            "Surge of Thaumacretion",
        },
        ['PetAura'] = {
            -- Mage Pet Aura
            "Arcane Distillect",
        },
        ['SingleDS'] = {
            -- Single target Dmg Shields For Pets
            "Forgefire Coat",
            "Emberweave Coat",
            "Igneous Coat",
            "Inferno Coat",
            "Flameweave Coat",
            "Flameskin",
            "Embercoat",
            "Dreamfire Coat",
            "Brimstoneskin",
            "Lavaskin",
            "Magmaskin",
            "Fireskin",
            "FlameShield of Ro",
            "Cadeau of Flame",
            "Shield of Lava",
            "Barrier of Combustion",
            "Inferno Shield",
            "Shield of Flame",
            "Shield of Fire",
        },
        ['FireShroud'] = {
            -- Defensive Proc 3-6m Buff
            "Igneous Veil",
            "Volcanic Veil",
            "Exothermic Veil",
            "Skyfire Veil",
            "Magmatic Veil",
            "Molten Veil",
            "Burning Veil",
            "Burning Pyroshroud",
            "Burning Brimbody",
            "Burning Aura",
        },
        ['PetBodyGuard'] = {
            "ValorForged Bodyguard",
            "Ophiolite Bodyguard",
            "Pyroxenite Bodyguard",
            "Rhyolitic Bodyguard",
            "Shieldstone Bodyguard",
            "Groundswell Bodyguard",
            "Steelbound Bodyguard",
            "Tellurian Bodyguard",
            "Hulking Bodyguard",
        },
        ['GatherMana'] = {
            "Gather Zeal",
            "Gather Vigor",
            "Gather Potency",
            "Gather Capability",
            "Gather Magnitude",
            "Gather Capacity",
            "Gather Potential",
        },
        -- Pet Spells Pets & Spells Affecting them
        ['MeleeGuard  '] = {
            "Shield of Inescapability",
            "Shield of Inevitability",
            "Shield of Destiny",
            "Shield of Order",
            "Shield of Consequence",
            "Shield of Fate",
        },
        ['DichoSpell'] = {
            -- Dicho Spell*
            "Ecliptic Companion",
            "Composite Companion",
            "Dissident Companion",
            "Dichotomic Companion",
        },
        ['PetHealSpell'] = {
            -- Pet Heal*
            "Renewal of Shoru",
            "Renewal of Iilivina ",
            "Renewal of Evreth",
            "Renewal of Ioulin",
            "Renewal of Calix",
            "Renewal of Hererra",
            "Renewal of Sirqo",
            "Renewal of Volark",
            "Renewal of Cadwin",
            "Revival of Aenro",
            "Renewal of Aenda",
            "Renewal of Jerikor",
            "Planar Renewal",
            "Transon's Elemental Renewal",
            "Transon's Elemental Infusion",
            "Refresh Summoning",
            "Renew Summoning",
            "Renew Elements",
        },
        ['PetPromisedSpell'] = {
            ---Pet Promised*
            "Promised Reconstitution",
            "Promised Relief",
            "Promised Healing",
            "Promised Alleviation",
            "Promised Invigoration",
            "Promised Amelioration",
            "Promised Amendment",
            "Promised Wardmending",
            "Promised Rejuvenation",
            "Promised Recovery",
        },
        ['PetStanceSpell'] = {
            ---Pet Stance*
            "Omphacite Stance",
            "Kanoite Stance",
            "Pyroxene Stance",
            "Rhyolite Stance",
            "Shieldstone Stance",
            "Groundswell Stance",
            "Steelstance",
            "Tellurian Stance",
            "Earthen Stance",
            "Grounded Stance",
            "Granite Stance",
        },
        ['PetManaConv'] = {
            "Valiant Symbiosis",
            "Relentless Symbiosis",
            "Restless Symbiosis",
            "Burning Symbiosis",
            "Dark Symbiosis",
            "Phantasmal Symbiosis",
            "Arcane Symbiosis",
            "Spectral Symbiosis",
            "Ethereal Symbiosis",
            "Prime Symbiosis",
            "Elemental Symbiosis",
            "Elemental Simulacrum",
            "Elemental Siphon",
            "Elemental Draw",
        },
        ['PetHaste'] = {
            "Burnout XVI",
            "Burnout XV",
            "Burnout XIV",
            "Burnout XIII",
            "Burnout XII",
            "Burnout XI",
            "Burnout XI",
            "Burnout IX",
            "Burnout VIII",
            "Burnout VII",
            "Burnout VI",
            "Elemental Fury",
            "Burnout V",
            "Burnout IV",
            "Elemental Empathy",
            "Burnout III",
            "Burnout II",
            "Burnout",
        },
        ['PetIceFlame'] = {
            "IceFlame Palisade",
            "Iceflame Barricade ",
            "Iceflame Rampart",
            "Iceflame Keep",
            "Iceflame Armaments",
            "Iceflame Eminence",
            "Iceflame Armor",
            "Iceflame Ward",
            "Iceflame Efflux",
            "Iceflame Tenement",
            "Iceflame Body",
            "Iceflame Guard",
        },
        ['EarthPetSpell'] = {
            "Recruitment of Earth",
            "Conscription of Earth",
            "Manifestation of Earth",
            "Embodiment of Earth",
            "Convocation of Earth",
            "Shard of Earth",
            "Facet of Earth",
            "Construct of Earth",
            "Aspect of Earth",
            "Core of Earth",
            "Essence of Earth",
            "Child of Earth",
            "Greater Vocaration: Earth",
            "Vocarate: Earth",
            "Conjuration: Earth",
            "Lesser Conjuration: Earth",
            "Minor Conjuration: Earth",
            "Greater Summoning: Earth",
            "Summoning: Earth",
            "Lesser Summoning: Earth",
            "Minor Summoning: Earth",
            "Elemental: Earth",
            "Elementaling: Earth",
            "Elementalkin: Earth",
        },
        ['WaterPetSpell'] = {
            ----- Water Pet*
            "Recruitment of Water",
            "Conscription of Water",
            "Manifestation of Water",
            "Embodiment of Water",
            "Convocation of Water",
            "Shard of Water",
            "Facet of Water",
            "Construct of Water",
            "Aspect of Water",
            "Core of Water",
            "Essence of Water",
            "Child of Water",
            "Servant of Marr",
            "Greater Vocaration: Water",
            "Vocarate: Water",
            "Greater Conjuration: Water",
            "Conjuration: Water",
            "Lesser Conjuration: Water",
            "Minor Conjuration: Water",
            "Greater Summoning: Water",
            "Summoning: Water",
            "Lesser Summoning: Water",
            "Minor Summoning: Water",
            "Elemental: Water",
            "Elementaling: Water",
            "Elementalkin: Water",
        },
        ['AirPetSpell'] = {
            ----- Air Pet*
            "Recruitment of Air",
            "Conscription of Air",
            "Manifestation of Air",
            "Embodiment of Air",
            "Convocation of Air",
            "Shard of Air",
            "Facet of Air",
            "Construct of Air",
            "Aspect of Air",
            "Core of Air",
            "Essence of Air",
            "Child of Wind",
            "Ward of Xegony",
            "Greater Vocaration: Air",
            "Vocarate: Air",
            "Greater Conjuration: Air",
            "Conjuration: Air",
            "Lesser Conjuration: Air",
            "Minor Conjuration: Air",
            "Greater Summoning: Air",
            "Summoning: Air",
            "Lesser Summoning: Air",
            "Minor Summoning: Air",
            "Elemental: Air",
            "Elementaling: Air",
            "Elementalkin: Air",
        },
        ['FirePetSpell'] = {
            "Recruitment of Fire",
            "Conscription of Fire",
            "Manifestation of Fire",
            "Embodiment of Fire",
            "Convocation of Fire",
            "Shard of Fire",
            "Facet of Fire",
            "Construct of Fire",
            "Aspect of Fire",
            "Core of Fire",
            "Essence of Fire",
            "Child of Fire",
            "Child of Ro",
            "Greater Vocaration: Fire",
            "Vocarate: Fire",
            "Greater Conjuration: Fire",
            "Conjuration: Fire",
            "Lesser Conjuration: Fire",
            "Minor Conjuration: Fire",
            "Greater Summoning: Fire",
            "Summoning: Fire",
            "Lesser Summoning: Fire",
            "Minor Summoning: Fire",
            "Elemental: Fire",
            "Elementaling: Fire",
            "Elementalkin: Fire",
        },
        ['AegisBuff'] = {
            ---Pet Aegis Shield Buff (Short Duration)*
            "Aegis of Valorforged",
            "Auspice of Valia",
            "Aegis of Rumblecrush",
            "Auspice of Kildrukaun",
            "Aegis of Orfur",
            "Auspice of Esianti",
            "Aegis of Zeklor",
            "Aegis of Japac",
            "Auspice of Eternity",
            "Aegis of Nefori",
            "Auspice of Shadows",
            "Aegis of Kildrukaun",
            "Aegis of Calliav",
            "Bulwark of Calliav",
            "Protection of Calliav",
            "Guard of Calliav",
            "Ward of Calliav",
        },
        ['PetManaNuke'] = {
            --- PetManaNuke
            "Thaumatize Pet",
        },
        -- - Summoned item Spells
        ['PetArmorSummon'] = {
            -- >=LVL71
            "Grant The Alloy's Plate",
            "Grant the Centien's Plate",
            "Grant Ocoenydd's Plate",
            "Grant Wirn's Plate",
            "Grant Thassis' Plate",
            "Grant Frightforged Plate",
            "Grant Manaforged Plate",
            "Grant Spectral Plate",
            "Summon Plate of the Prime",
            "Summon Plate of the Elements",
        },
        ['PetWeaponSummon'] = {
            "Grant Goliath's Armaments",
            "Grant Shak Dathor's Armaments",
            "Grant Yalrek's Armaments",
            "Grant Wirn's Armaments",
            "Grant Thassis' Armaments",
            "Grant Frightforged Armaments",
            "Grant Manaforged Armaments",
            "Grant Spectral Armaments",
            "Summon Ethereal Armaments",
            "Summon Prime Armaments",
            "Summon Elemental Armaments",
        },
        ['PetHeirloomSummon'] = {
            "Grant Ankexfen's Heirlooms",
            "Grant the Diabo's Heirlooms",
            "Summon Nastel's Heirlooms",
            "Summon Zabella's Heirlooms",
            "Grant Enibik's Heirlooms",
            "Grant Atleris' Heirlooms",
            "Grant Nint's Heirlooms",
            "Grant Calix's Heirlooms",
            "Grant Ioulin's Heirlooms",
            "Grant Crystasia's Heirlooms",
        },
        ['IceOrbSummon'] = {
            "Grant Frostbound Paradox",
            "Grant Icebound Paradox",
            "Grant Frostrift Paradox",
            "Grant Glacial Paradox",
            "Summon Frigid Paradox",
            "Summon Gelid Paradox",
            "Summon Wintry Paradox",
        },
        ['FireOrbSummon'] = {
            "Summon Molten Komatiite Orb",
            "Summon Firebound Orb",
            "Summon Blazing Orb",
            "Summon: Molten Orb",
            "Summon: Lava Orb",
        },
        ['EarthPetItemSummon'] = {
            "Summon Valorous Servant",
            "Summon Forbearing Servant",
            "Summon Imperative Servant",
            "Summon Insurgent Servant",
            "Summon Mutinous Servant",
            "Summon Imperious Servant",
            "Summon Exigent Servant",
        },
        ['FirePetItemSummon'] = {
            "Summon Valorous Minion",
            "Summon Forbearing Minion",
            "Summon Imperative Minion",
            "Summon Insurgent Minion",
            "Summon Mutinous Minion",
            "Summon Imperious Minion",
            "Summon Exigent Minion",
        },
        ['ManaRodSummon'] = {
            --- ManaRodSummon - Focuses on group mana rod summon for ease. _
            --  - no TOL spell?
            "Mass Dark Transvergence",
            "Mass Dark Transvergence",
            "Mass Arcane Transvergence",
            "Mass Spectral Transvergence",
            "Mass Ethereal Transvergence",
            "Mass Prime Transvergence",
            "Mass Elemental Transvergence",
            "Mass Mystical Transvergence",
            "Modulating Rod",
        },
        ['SelfManaRodSummon'] = {
            ---, - Focuses on self mana rod summon separate from other timers. >95
            "Rod of Courageous Modulation",
            "Sickle of Umbral Modulation",
            "Wand of Frozen Modulation",
            "Wand of Burning Modulation",
            "Wand of Dark Modulation",
            "Wand of Phantasmal Modulation",
        },
        -- - Debuffs
        ['MaloDebuff'] = {
            -- line < LVL 75 @ LVL75 use the AA
            "Malosinera",
            "Malosinetra",
            "Malosinara",
            "Malosinata",
            "Malosenete",
            "Malosenia",
            "Maloseneta",
            "Malosene",
            "Malosenea",
            "Malosinatia",
            "Malosinise",
            "Malosinia",
            "Mala",
            "Malosini",
            "Malosi",
            "Malaisement",
            "Malaise",
        },
    },
    ['HealRotationOrder'] = {
        {
            name = 'PetHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, _) return (mq.TLO.Me.Pet.PctHPs() or 100) < RGMercUtils.GetSetting('PetHealPct') end,
        },
    },
    ['HealRotations']     = {
        ["PetHealPoint"] = {
            {
                name = "PetHealSpell",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.PCSpellReady(spell) end,
            },
        },
    },
    ['RotationOrder']     = {
        {
            name = 'Pet Management',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state) return true end,
        },
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.ID(), mq.TLO.Me.Pet.ID(), } or { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    RGMercUtils.DoBuffCheck()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    RGMercUtils.BurnCheck() and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
        {
            name = 'DPS PET',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning() and RGMercUtils.IsModeActive("PetTank")
            end,
        },
        {
            name = 'Weaves',
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    mq.TLO.Me.SpellInCooldown() == nil
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return { RGMercConfig.Globals.AutoTargetID, } end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not RGMercUtils.Feigning()
            end,
        },
    },
    -- Really the meat of this class.
    ['HelperFunctions']   = {
        user_tu_spell = function(self, aaName)
            local shroudSpell = self.ResolvedActionMap['ShroudSpell']
            local aaSpell = mq.TLO.Me.AltAbility(aaName).Spell
            if not shroudSpell or not shroudSpell() or not aaSpell or not aaSpell() or not RGMercUtils.CanUseAA(aaName) then return false end
            -- do we need to lookup the spell basename here? I dont think so but if this doesn't fire right take a look.
            if shroudSpell.Level() > aaSpell.Level() then return false end
            return true
        end,
        give_pet_toys = function(self, petId)
            self.ClassConfig.HelperFunctions.summon_pet_toy(self, "Weapon", petId)
            if RGMercUtils.GetSetting('DoPetArmor') then
                self.ClassConfig.HelperFunctions.summon_pet_toy(self, "Armor", petId)
            end
            if RGMercUtils.GetSetting('DoPetHeirlooms') then
                self.ClassConfig.HelperFunctions.summon_pet_toy(self, "Heirlooms", petId)
            end
        end,
        handle_pet_toys = function(self)
            if mq.TLO.Me.FreeInventory() < 2 or mq.TLO.Me.Level() < 73 then
                RGMercsLogger.log_debug("handle_pet_toys() ==> \arFailed your level is below 73 or you dont have inv slots open!")
                return false
            end
            if (mq.TLO.Me.Pet.Equipment("Primary")() or 0) ~= 0 then
                RGMercsLogger.log_verbose("handle_pet_toys() ==> \arFailed your pet already has weapons!")
                return false
            end

            if mq.TLO.Me.CombatState():lower() ~= "combat" then
                return self.ClassConfig.HelperFunctions.give_pet_toys(self, mq.TLO.Me.Pet.ID())
            end
            return false
        end,
        group_toys = function(self)
            -- first Things first see if i can even Make Pet toys. if i am To Low Level or have no Inventory Return
            if mq.TLO.Me.FreeInventory() < 2 or mq.TLO.Me.Level() < 73 then return false end


            -- Check if the Groups pet need toys by checking if the pet has weapons.
            -- If they Are Not a Mage - Also Give them Armor
            for i = 1, mq.TLO.Group.Members() do
                local member = mq.TLO.Group.Member(i)
                if member and member() and member.Pet.ID() > 0 and (member.Pet.Equipment("primary")() or 0) == 0 then
                    if mq.TLO.Me.CombatState():lower() ~= "combat" then
                        self.ClassConfig.HelperFunctions.give_pet_toys(self, member.Pet.ID())
                    end
                end
            end
        end,
        summon_pet_toy = function(self, type, targetId)
            local petToyResolvedSpell = self.ResolvedActionMap[string.format("Pet%sSummon", type)]

            if not petToyResolvedSpell or not petToyResolvedSpell() then
                RGMercsLogger.log_debug("summon_pet_toy() ==> \arFailed to resolve Pet%sSummon item type!", type)
                return false
            end

            if mq.TLO.Me.Level() < petToyResolvedSpell.Level() then
                RGMercsLogger.log_debug("summon_pet_toy() ==> \arFailed your level is below the pet toy spell(%s) level: %d!", petToyResolvedSpell.RankName(),
                    petToyResolvedSpell.Level())
                return false
            end

            if not RGMercUtils.PCSpellReady(petToyResolvedSpell) then
                RGMercsLogger.log_debug("summon_pet_toy() ==> \arFailed PCSpellReady() Check!", type)
                return false
            end

            -- find a slot for the item
            local openSlot = 0
            for i = 1, 10 do
                if mq.TLO.InvSlot("pack" .. tostring(i)).Item.Container() == nil and mq.TLO.InvSlot("pack" .. tostring(i)).Item.ID() == nil then
                    openSlot = i
                    break
                end
            end

            if openSlot == 0 then
                RGMercsLogger.log_debug("summon_pet_toy() ==> \arFailed to find open top level inv slot!", openSlot)
                return
            end

            RGMercsLogger.log_debug("summon_pet_toy() ==> \agUsing PackID=%d", openSlot)

            RGMercUtils.UseSpell(petToyResolvedSpell.RankName(), mq.TLO.Me.ID(), RGMercUtils.GetXTHaterCount() == 0)

            mq.delay("5s", function() return (mq.TLO.Cursor.ID() or 0) > 0 end)

            if (mq.TLO.Cursor.ID() or 0) == 0 then return false end

            local packName = string.format("pack%d", openSlot)

            while mq.TLO.Cursor.ID() do
                RGMercUtils.DoCmd("/shiftkey /itemnotify %s leftmouseup", packName)
                mq.delay("1s", function() return mq.TLO.Cursor.ID() == nil end)
            end

            -- What happens if the bag is a Folded Pack
            while string.find(mq.TLO.InvSlot(packName).Item.Name(), "Folded Pack") ~= nil do
                RGMercUtils.DoCmd("/nomodkey /itemnotify %s rightmouseup", packName)
                -- Folded backs end up on our cursor.
                mq.delay("5s", function() return (mq.TLO.Cursor.ID() or 0) > 0 end)
                -- Drop the unfolded pack back in our inventory
                while mq.TLO.Cursor.ID() do
                    RGMercUtils.DoCmd("/nomodkey /itemnotify %s leftmouseup", packName)
                    mq.delay("1s", function() return mq.TLO.Cursor.ID() == nil end)
                end
            end

            -- Hand Toy off to the Pet
            -- Open our pack
            RGMercUtils.DoCmd("/nomodkey /itemnotify %s rightmouseup", packName)

            -- TODO: Need a condition to check if the pack window has opened
            mq.delay("1s")

            if type == "Armor" or type == "Heirloom" then
                -- Loop through each item in our bag and give it to the pet
                for i = 1, mq.TLO.InvSlot(packName).Item.Container() do
                    if mq.TLO.InvSlot(packName).Item.Item(i).Name() ~= nil then
                        RGMercUtils.GiveTo(targetId, mq.TLO.InvSlot(packName).Item.Item(i).Name(), 1)
                    end
                end
            else
                -- Must be a weapon
                -- Hand Weapons off to the pet
                local itemsToGive = { 2, 4, }
                if RGMercUtils.IsModeActive("PetTank") then
                    -- If we're pet tanking, give the pet the hate swords in bag slots
                    -- 7 and 8. At higher levels this only ends up with one aggro swords
                    -- so perhaps there's a way of generalizing later.
                    itemsToGive = { 7, 8, }
                end

                for _, i in ipairs(itemsToGive) do
                    RGMercsLogger.log_debug("Item Name %s", mq.TLO.InvSlot(packName).Item.Item(i).Name())
                    RGMercUtils.GiveTo(targetId, mq.TLO.InvSlot(packName).Item.Item(i).Name(), 1)
                end
            end

            -- Delete the satchel if it's still there
            if mq.TLO.InvSlot(packName).Item.ID() ~= nil then
                RGMercUtils.DoCmd("/nomodkey /itemnotify %s leftmouseup", packName)
                mq.delay("5s", function() return mq.TLO.Cursor.ID() ~= nil end)

                -- Just double check and make sure it's a temporary
                if mq.TLO.Cursor.ID() and mq.TLO.Cursor.NoRent() then
                    RGMercUtils.DoCmd("/destroy")
                    mq.delay(30, function() return mq.TLO.Cursor.ID() == nil end)
                end
            end
        end,
        summon_pet = function(self)
            local petSpellVar = string.format("%sPetSpell", self.ClassConfig.DefaultConfig.PetType.ComboOptions[RGMercUtils.GetSetting('PetType')])
            local resolvedPetSpell = self.ResolvedActionMap[petSpellVar]

            if not resolvedPetSpell then
                RGMercsLogger.log_debug("No valid pet spell found for type: %s", petSpellVar)
                return false
            end

            if mq.TLO.FindItemCount("Malachite")() > 0 then
                return RGMercUtils.UseSpell(resolvedPetSpell.RankName(), mq.TLO.Me.ID(), self.CombatState == "Downtime")
            else
                RGMercsLogger.log_error("\ayYou don't have \agMalachite\ay. And you call yourself a mage?")
                RGMercConfig:GetSettings().DoPet = false
                return false
            end
        end,
        pet_management = function(self)
            if not RGMercConfig:GetSettings().DoPet or (RGMercUtils.CanUseAA("Companion's Suspension)") and not RGMercUtils.AAReady("Companion's Suspension")) then
                return false
            end

            -- Low Level Check - In 2 cases You're too lowlevel to Know Suspend companion and have no pet or You've Turned off Usepocket pet.
            if mq.TLO.Me.Pet.ID() == 0 and (not RGMercUtils.CanUseAA("Companion's Suspension") or not RGMercUtils.GetSetting('DoPocketPet')) then
                if not self.ClassConfig.HelperFunctions.summon_pet(self) then
                    RGMercsLogger.log_debug("\arPetManagement - Case 0 -> Summon Failed")
                    return false
                end
            end

            -- Pocket Pet Stuff Begins. -  Added Check for DoPocketPet to be Positive Rather than Assuming
            if RGMercUtils.GetSetting('DoPocketPet') then
                if self.TempSettings.PocketPet and mq.TLO.Me.Pet.ID() == 0 and RGMercUtils.GetXTHaterCount() > 0 then
                    RGMercUtils.UseAA("Companion's Suspension", 0)
                    self.TempSettings.PocketPet = false
                    return true
                end

                -- Case 1 - No pocket pet and no pet up
                if not self.TempSettings.PocketPet and mq.TLO.Me.Pet.ID() == 0 and RGMercUtils.GetXTHaterCount() == 0 then
                    RGMercsLogger.log_debug("\ayPetManagement - Case 1 no Pocket Pet and no Pet")
                    if not self.ClassConfig.HelperFunctions.summon_pet(self) then
                        RGMercsLogger.log_debug("\arPetManagement - Case 1 -> Summon Failed")
                        return false
                    end

                    if RGMercUtils.AARank("Companion's Suspension") > 2 then
                        -- Need to buff
                        local resolvedPetHasteSpell = self.ResolvedActionMap["PetHaste"]
                        RGMercUtils.UseSpell(resolvedPetHasteSpell.RankName(), mq.TLO.Me.Pet.ID(), true)
                        local resolvedPetBuffSpell = self.ResolvedActionMap["PetIceFlame"]
                        RGMercUtils.UseSpell(resolvedPetBuffSpell.RankName(), mq.TLO.Me.Pet.ID(), true)
                        if mq.TLO.Me.Pet.ID() then
                            self.ClassConfig.HelperFunctions.handle_pet_toys(self)
                        end
                        RGMercUtils.UseAA("Companion's Suspension", 0)
                        self.TempSettings.PocketPet = true
                    end

                    return true
                end
            end
            -- Case 2 - No pocket pet and pet up
            if not self.TempSettings.PocketPet and (mq.TLO.Me.Pet.ID() or 0) > 0 and RGMercUtils.GetXTHaterCount() == 0 then
                RGMercsLogger.log_debug("\ayPetManagement - Case 2 no Pocket Pet But Pet is up - pocketing")
                RGMercUtils.UseAA("Companion's Suspension", 0)
                if (mq.TLO.Me.Pet.ID() or 0) == 0 then
                    if not self.ClassConfig.HelperFunctions.summon_pet(self) then
                        RGMercsLogger.log_debug("\arPetManagement - Case 2 -> Summon Failed")
                        return false
                    end
                end
                self.TempSettings.PocketPet = true

                return true
            end

            -- Case 3 - Pocket Pet and no pet up
            if self.TempSettings.PocketPet and (mq.TLO.Me.Pet.ID() or 0) == 0 and RGMercUtils.GetXTHaterCount() == 0 then
                RGMercsLogger.log_debug("\ayPetManagement - Case 3 Pocket Pet But No Pet is up")
                if not self.ClassConfig.HelperFunctions.summon_pet(self) then
                    RGMercsLogger.log_debug("\arPetManagement - Case 3 -> Summon Failed")
                    return false
                end

                return true
            end

            return true
        end,
    },
    ['Rotations']         = {
        ['Pet Management'] = {
            {
                name = "Pet Management",
                type = "CustomFunc",
                active_cond = function(self)
                    return mq.TLO.Me.Pet.ID() > 0
                end,
                cond = function(self)
                    if self.TempSettings.PocketPet == nil then self.TempSettings.PocketPet = false end
                    return mq.TLO.Me.Pet.ID() == 0 and RGMercUtils.GetSetting('DoPet') and (self.TempSettings.PocketPet or RGMercUtils.GetXTHaterCount() == 0)
                end,
                custom_func = function(self) return self.ClassConfig.HelperFunctions.summon_pet(self) end,
            },
        },
        ['Burn'] = {
            {
                name = "EarthPetItemSummon",
                type = "CustomFunc",
                custom_func = function(self)
                    local baseItem = self.ResolvedActionMap['EarthPetItemSummon'].Base(1)
                    if mq.TLO.FindItemCount(baseItem)() == 1 then
                        local invItem = mq.TLO.FindItem(baseItem)
                        return RGMercUtils.UseItem(invItem.Name(), mq.TLO.Me.ID())
                    end

                    return false
                end,
            },
            {
                name = "FirePetItemSummon",
                type = "CustomFunc",
                custom_func = function(self)
                    local baseItem = self.ResolvedActionMap['FirePetItemSummon'].Base(1)
                    if mq.TLO.FindItemCount(baseItem)() == 1 then
                        local invItem = mq.TLO.FindItem(baseItem)
                        return RGMercUtils.UseItem(invItem.Name(), mq.TLO.Me.ID())
                    end

                    return false
                end,
            },
            {
                name = mq.TLO.Me.Inventory("Chest").Name(),
                type = "Item",
                active_cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return item() and mq.TLO.Me.Song(item.Spell.RankName.Name())() ~= nil
                end,
                cond = function(self)
                    local item = mq.TLO.Me.Inventory("Chest")
                    return RGMercUtils.GetSetting('DoChestClick') and item() and item.Spell.Stacks() and item.TimerReady() == 0
                end,
            },
            {
                name = "AllianceBuff",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsNamed(mq.TLO.Target) and not RGMercUtils.TargetHasBuffByName(self.ResolvedActionMap['AllianceBuff']) and
                        RGMercUtils.GetSetting('DoAlliance') and RGMercUtils.CanAlliance()
                end,
            },
            {
                name = "Companion's Fury",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.AAReady(aaName) end,
            },
            {
                name = "Host of the Elements",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.AAReady(aaName) end,
            },
            {
                name = "Spire of Elements",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.AAReady(aaName) end,
            },
            {
                name = "Heart of Skyfire",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.AAReady(aaName) end,
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.AAReady(aaName) end,
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.AAReady(aaName) end,
            },
            {
                name = "Servant of Ro",
                type = "AA",
                cond = function(self, aaName) return RGMercUtils.AAReady(aaName) end,
            },
        },
        ['DPS PET'] = {
            {
                name = "OowRobeName",
                type = "CustomFunc",
                custom_func = function(self)
                    if not RGMercUtils.IsModeActive("PetTank") then return end
                    local oowItems = { 'Glyphwielder\'s Tunic of the Summoner', 'Runemaster\'s Robe', }
                    for _, item in ipairs(oowItems) do
                        if mq.TLO.FindItemCount(item)() == 1 then
                            self.TempSettings.OowRobeBase = item
                            return RGMercUtils.UseItem(item, mq.TLO.Me.ID())
                        end
                    end

                    return false
                end,
            },
            {
                name = "PetStanceSpell",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("PetTank") and self.TempSettings.OowRobeBase ~= nil and RGMercUtils.IsModeActive("PetTank") and
                        RGMercUtils.SelfBuffPetCheck(spell) and mq.TLO.Me.Pet.PctHPs() <= 95 and
                        (mq.TLO.Me.PetBuff(mq.TLO.Spell(self.TempSettings.OowRobeBase).Base(1) or "").ID()) or 0 == 0
                end,
            },
            {
                name = "SurgeDS1",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("PetTank") and not RGMercUtils.SelfBuffCheck(spell) and (mq.TLO.Me.PetBuff(self.ResolvedActionMap['SurgeDS1'] or "")() == nil)
                end,
            },
            {
                name = "SurgeDS2",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("PetTank") and not RGMercUtils.SelfBuffCheck(spell) and (mq.TLO.Me.PetBuff(self.ResolvedActionMap['SurgeDS2'] or "")() == nil)
                end,
            },
            {
                name = "ShortDurDmgShield",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("PetTank") and not RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "FireShroud",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("PetTank") and (mq.TLO.Me.PetBuff(self.ResolvedActionMap['PetPromisedSpell'] or "").ID() or 0)
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Force of Elements",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "FireOrbItem",
                type = "CustomFunc",
                custom_func = function(self)
                    local baseItem = self.ResolvedActionMap['FireOrbSummon'].Base(1)
                    if mq.TLO.FindItemCount(baseItem)() == 1 then
                        local invItem = mq.TLO.FindItem(baseItem)
                        return RGMercUtils.UseItem(invItem.Name(), mq.TLO.Target.ID())
                    end
                    return false
                end,
            },
        },
        ['DPS'] = {
            {
                name = "SelfModRod",
                type = "Item",
                cond = function(self)
                    return mq.TLO.FindItemCount(RGMercUtils.GetSetting('SelfModRod'))() == 0 and mq.TLO.Me.PctMana() < RGMercUtils.GetSetting('ModRodManaPct') and
                        mq.TLO.Me.PctHPs() >= 60
                end,
            },
            {
                name = "<<None>>",
                name_func = function(self)
                    if not self.ModuleLoaded then return "" end
                    return string.format("%sPetSpell", self.ClassConfig.DefaultConfig.PetType.ComboOptions[RGMercUtils.GetSetting('PetType')])
                end,
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(RGMercUtils.GetSetting('SelfModRod'))() == 0 and mq.TLO.Me.PctMana() < RGMercUtils.GetSetting('ModRodManaPct') and
                        mq.TLO.Me.PctHPs() >= 60
                end,
            },
            {
                name = "SwarmPet",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Fire")
                end,
            },
            {
                name = "ChaoticNuke",
                type = "Spell",
                cond = function(self, _)
                    return RGMercUtils.IsModeActive("Fire")
                end,
            },
            {
                name = "SpearNuke1",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Fire")
                end,
            },
            {
                name = "VolleyNuke",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.IsModeActive("Fire")
                end,
            },
            {
                name = "FireNuke1",
                type = "Spell",
                cond = function(self) return mq.TLO.Me.Level() < 70 or RGMercUtils.IsModeActive("PetTank") end,
            },
            {
                name = "FireNuke2",
                type = "Spell",
                cond = function(self) return mq.TLO.Me.Level() < 70 or RGMercUtils.IsModeActive("PetTank") end,
            },
            {
                name = "FireBoltNuke",
                type = "Spell",
                cond = function(self) return mq.TLO.Me.Level() < 70 or RGMercUtils.IsModeActive("PetTank") end,
            },
            {
                name = "MagicNuke1",
                type = "Spell",
                cond = function(self) return mq.TLO.Me.Level() < 70 and RGMercUtils.IsModeActive("Fire") end,
            },
            {
                name = "MagicNuke2",
                type = "Spell",
                cond = function(self) return mq.TLO.Me.Level() < 70 and RGMercUtils.IsModeActive("Fire") end,
            },
            {
                name = "Turned Summoned",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Target.ID() > 0 and mq.TLO.Target.Body.Name():lower() == "undead pet" and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "TwinCast",
                type = "Spell",
                cond = function(self, spell) return RGMercUtils.SelfBuffCheck(spell) and not RGMercUtils.BuffActiveByName("Improved Twincast") end,
            },
            --   {
            --       name = "AllianceBuff",
            --       type = "Spell",
            --      cond = function(self, spell)
            --           return RGMercUtils.IsNamed(mq.TLO.Target) and not RGMercUtils.TargetHasBuffByName(spell.RankName()) and
            --               RGMercUtils.GetSetting('DoAlliance') and RGMercUtils.CanAlliance()
            --       end,
            --    },
        },
        ['Debuff'] = {
            {
                name = "Malaise",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoMalo') and RGMercUtils.DetAACheck(aaName) and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "MaloDebuff",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.GetSetting('DoMalo') and RGMercUtils.DetSpellCheck(spell)
                end,
            },
            {
                name = "Malaise",
                type = "Wind of Malaise",
                cond = function(self, aaName)
                    return RGMercUtils.GetSetting('DoMalo') and RGMercUtils.GetSetting('doAEMalo') and RGMercUtils.DetAACheck(aaName)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "HandlePetToys",
                type = "CustomFunc",
                custom_func = function(self)
                    return mq.TLO.Me.Pet.ID() > 0 and self.ClassConfig.HelperFunctions.handle_pet_toys and self.ClassConfig.HelperFunctions.handle_pet_toys(self) or false
                end,
            },
            {
                name = "HandleGroupToys",
                type = "CustomFunc",
                custom_func = function(self)
                    return self.ClassConfig.HelperFunctions.group_toys and self.ClassConfig.HelperFunctions.group_toys(self) or false
                end,
            },
            {
                name = "PetAura",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Pet.ID() > 0 and not RGMercUtils.AuraActiveByName(spell.BaseName())
                end,
            },
            {
                name = "Elemental Conversion",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() <= RGMercUtils.GetSetting('GatherManaPct') and RGMercUtils.AAReady(aaName) and mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() <= RGMercUtils.GetSetting('GatherManaPct') and not mq.TLO.Me.SpellReady(self.ResolvedActionMap['GatherMana'] or "")() and
                        RGMercUtils.AAReady(aaName) and mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "ManaRodSummon",
                type = "Spell",
                cond = function(self, spell)
                    local modRodSpell = self.ResolvedActionMap['ManaRodSummon']
                    if not modRodSpell or not modRodSpell() then return false end
                    self.TempSettings.GroupModRod = mq.TLO.FindItem(modRodSpell.Base(1)).Name()
                    return RGMercUtils.GetSetting('SummonModRods') and (mq.TLO.Me.AltAbility("Summon Modulation Shard").ID() or 0) == 0 and
                        mq.TLO.FindItemCount(self.TempSettings.GroupModRod) == 0 and
                        (mq.TLO.Cursor.ID() or 0) == 0
                end,
            },
            {
                name = "Summon Modulation Shard",
                type = "AA",
                cond = function(self, aaName)
                    local modRodSpell = mq.TLO.Spell(aaName)
                    if not modRodSpell or not modRodSpell() then return false end
                    self.TempSettings.GroupModRod = mq.TLO.FindItem(modRodSpell.Base(1)).Name()
                    return RGMercUtils.GetSetting('SummonModRods') and
                        mq.TLO.FindItemCount(self.TempSettings.GroupModRod) == 0 and
                        (mq.TLO.Cursor.ID() or 0) == 0 and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "SelfManaRodSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.Base(1) or "") == 0 and (mq.TLO.Cursor.ID() or 0) == 0
                end,
            },
            {
                name = "GatherMana",
                type = "Spell",
                cond = function(self, spell)
                    return spell and spell() and mq.TLO.Me.PctMana() <= RGMercUtils.GetSetting('GatherManaPct') and RGMercUtils.PCSpellReady(spell) and
                        mq.TLO.Me.SpellReady(spell.Name() or "")
                end,
            },
            {
                name = "ManaRegenBuff",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfShield",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Thaumaturge's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "FireOrbSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.Base(1) or "")() == 0
                end,
            },
            {
                name = "EarthPetItemSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.Base(1) or "")() == 0
                end,
            },
            {
                name = "FirePetItemSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.Base(1) or "")() == 0
                end,
            },
            {
                name = "LongDurDmgShield",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "PetManaConv",
                type = "Spell",
                cond = function(self, spell)
                    return spell and spell() and not RGMercUtils.BuffActiveByName(mq.TLO.Spell(spell.AutoCast() or "").Name() or "") and mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "Elemental Form",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    return not mq.TLO.Me.PetBuff("Primal Fusion")() and not mq.TLO.Me.PetBuff("Elemental Conjuction")() and mq.TLO.FindItem(itemName).TimerReady() == 0 and
                        mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "PetIceFlame",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetHaste",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "LongDurDmgShield",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell) and mq.TLO.Me.AltAbility("Companions Discipline")
                end,
            },
            {
                name = "Second Wind Ward",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffPetCheck(mq.TLO.Spell(aaName)) and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Host in the Shell",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffPetCheck(mq.TLO.Spell(aaName)) and RGMercUtils.IsModeActive("PetTank") and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Companion's Aegis",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffPetCheck(mq.TLO.Spell(aaName)) and RGMercUtils.IsModeActive("PetTank") and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Companion's Intervening Divine Aura",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffPetCheck(mq.TLO.Spell(aaName)) and RGMercUtils.IsModeActive("PetTank") and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Elemental Conversion",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() <= RGMercUtils.GetSetting('GatherManaPct') and RGMercUtils.AAReady(aaName) and mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() <= RGMercUtils.GetSetting('GatherManaPct') and not mq.TLO.Me.SpellReady(self.ResolvedActionMap['GatherMana'] or "")() and
                        RGMercUtils.AAReady(aaName) and mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "ManaRodSummon",
                type = "Spell",
                cond = function(self, spell)
                    local modRodSpell = self.ResolvedActionMap['ManaRodSummon']
                    if not modRodSpell or not modRodSpell() then return false end
                    self.TempSettings.GroupModRod = mq.TLO.FindItem(modRodSpell.Base(1)).Name()
                    return RGMercUtils.GetSetting('SummonModRods') and (mq.TLO.Me.AltAbility("Summon Modulation Shard").ID() or 0) == 0 and
                        mq.TLO.FindItemCount(self.TempSettings.GroupModRod) == 0 and
                        (mq.TLO.Cursor.ID() or 0) == 0
                end,
            },
            {
                name = "Summon Modulation Shard",
                type = "AA",
                cond = function(self, aaName)
                    local modRodSpell = mq.TLO.Spell(aaName)
                    if not modRodSpell or not modRodSpell() then return false end
                    self.TempSettings.GroupModRod = mq.TLO.FindItem(modRodSpell.Base(1)).Name()
                    return RGMercUtils.GetSetting('SummonModRods') and
                        mq.TLO.FindItemCount(self.TempSettings.GroupModRod) == 0 and
                        (mq.TLO.Cursor.ID() or 0) == 0 and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "SelfManaRodSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.Base(1) or "") == 0 and (mq.TLO.Cursor.ID() or 0) == 0
                end,
            },
            {
                name = "GatherMana",
                type = "Spell",
                cond = function(self, spell)
                    return spell and spell() and mq.TLO.Me.PctMana() <= RGMercUtils.GetSetting('GatherManaPct') and RGMercUtils.PCSpellReady(spell) and
                        mq.TLO.Me.SpellReady(spell.Name() or "")
                end,
            },
            {
                name = "ManaRegenBuff",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfShield",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Thaumaturge's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "FireOrbSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.Base(1) or "") == 0
                end,
            },
            {
                name = "EarthPetItemSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.Base(1) or "") == 0
                end,
            },
            {
                name = "FirePetItemSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.Base(1) or "") == 0
                end,
            },
            {
                name = "LongDurDmgShield",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffCheck(spell)
                end,
            },
            {
                name = "PetManaConv",
                type = "Spell",
                cond = function(self, spell)
                    return not RGMercUtils.BuffActiveByName(mq.TLO.Spell(spell.AutoCast() or "").Name() or "") and mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "Elemental Form",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffAACheck(aaName) and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    return not mq.TLO.Me.PetBuff("Primal Fusion")() and not mq.TLO.Me.PetBuff("Elemental Conjuction")() and mq.TLO.FindItem(itemName).TimerReady() and
                        mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "PetIceFlame",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "PetHaste",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell)
                end,
            },
            {
                name = "LongDurDmgShield",
                type = "Spell",
                cond = function(self, spell)
                    return RGMercUtils.SelfBuffPetCheck(spell) and mq.TLO.Me.AltAbility("Companions Discipline")
                end,
            },
            {
                name = "Second Wind Ward",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffPetCheck(mq.TLO.Spell(aaName)) and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Host in the Shell",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffPetCheck(mq.TLO.Spell(aaName)) and RGMercUtils.IsModeActive("PetTank") and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Companion's Aegis",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffPetCheck(mq.TLO.Spell(aaName)) and RGMercUtils.IsModeActive("PetTank") and RGMercUtils.AAReady(aaName)
                end,
            },
            {
                name = "Companion's Intervening Divine Aura",
                type = "AA",
                cond = function(self, aaName)
                    return RGMercUtils.SelfBuffPetCheck(mq.TLO.Spell(aaName)) and RGMercUtils.IsModeActive("PetTank") and RGMercUtils.AAReady(aaName)
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "SpearNuke1", cond = function(self) return mq.TLO.Me.Level() >= 70 end, },
                { name = "FireNuke1", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "ChaoticNuke", cond = function(self) return mq.TLO.Me.Level() >= 69 end, },
                { name = "FireNuke2", },
            },
        },
        {
            gem = 3,
            spells = {

                { name = "SwarmPet",  cond = function(self) return mq.TLO.Me.Level() >= 70 end, },
                { name = "FireNuke1", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "VolleyNuke", cond = function(self) return mq.TLO.Me.Level() >= 75 end, },
                { name = "MagicNuke1", cond = function(self) return true end, },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "FireOrbSummon", cond = function(self) return mq.TLO.Me.Level() >= 75 end, },
                { name = "MagicNuke2",    cond = function(self) return true end, },
            },
        },
        {
            gem = 6,
            spells = {
                {
                    name = "FireOrbSummon",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 75 and ((mq.TLO.Me.AltAbility("Malaise").ID() or 0) > 0 or not RGMercUtils.GetSetting('DoMalo'))
                    end,
                },
                { name = "MaloDebuff", cond = function(self) return true end, },
            },
        },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                {
                    name = "AllianceBuff",
                    cond = function(self)
                        return RGMercUtils.GetSetting('DoAlliance')
                    end,
                },
                { name = "SelfManaRodSummon", },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PetHealSpell", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DichoSpell", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TwinCast", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PetManaNuke", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "GatherMana", },
            },
        },
    },
    ['DefaultConfig']     = {
        ['Mode']           = { DisplayName = "Mode", Category = "Combat", Tooltip = "Select the Combat Mode for this Toon", Type = "Custom", RequiresLoadoutChange = true, Default = 1, Min = 1, Max = 1, },
        ['DoPocketPet']    = { DisplayName = "Do Pocket Pet", Category = "Pet", Tooltip = "Pocket your pet during downtime", Default = true, },
        ['DoPetArmor']     = { DisplayName = "Do Pet Armor", Category = "Pet", Tooltip = "Summon Armor for Pets", Default = true, },
        ['PetType']        = { DisplayName = "Pet Type", Category = "Pet", Tooltip = "1 = Fire, 2 = Water, 3 = Earth, 4 = Air", Type = "Combo", ComboOptions = { 'Fire', 'Water', 'Earth', 'Air', }, Default = 1, Min = 1, Max = 4, },
        ['DoPetHeirlooms'] = { DisplayName = "Do Pet Heirlooms", Category = "Pet", Tooltip = "Summon Heirlooms for Pets", Default = true, },
        ['PetHealPct']     = { DisplayName = "Pet Heal %", Category = "Pet", Tooltip = "Heal pet at [X]% HPs", Default = 80, Min = 1, Max = 99, },
        ['SelfModRod']     = { DisplayName = "Self Mod Rod Item", Category = "Mana", Tooltip = "Click the modrod clicky you want to use here", Type = "ClickyItem", Default = "", },
        ['SummonModRods']  = { DisplayName = "Summon Mod Rods", Category = "Mana", Tooltip = "Summon Mod Rods", Default = true, },
        ['GatherManaPct']  = { DisplayName = "Gather Mana %", Category = "Mana", Tooltip = "When to use Gather Mana", Default = 70, Min = 1, Max = 99, },
        ['DoForce']        = { DisplayName = "Do Force", Category = "Spells & Abilities", Tooltip = "Use Force of Elements AA", Default = true, },
        ['DoMagicNuke']    = { DisplayName = "Do Magic Nuke", Category = "Spells & Abilities", Tooltip = "Use Magic nukes instead of Fire", Default = false, },
        ['DoChestClick']   = { DisplayName = "Do Check Click", Category = "Utilities", Tooltip = "Click your chest item", Default = true, },
        ['DoMalo']         = { DisplayName = "Cast Malo", Category = "Debuffs", Tooltip = "Do Malo Spells/AAs", Default = true, },
        ['DoAEMalo']       = { DisplayName = "Cast AE Malo", Category = "Debuffs", Tooltip = "Do AE Malo Spells/AAs", Default = false, },
    },
}

return _ClassConfig
