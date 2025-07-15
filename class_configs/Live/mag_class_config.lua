local mq          = require('mq')
local Config      = require('utils.config')
local Core        = require("utils.core")
local Targeting   = require("utils.targeting")
local Casting     = require("utils.casting")
local Comms       = require("utils.comms")
local ItemManager = require("utils.item_manager")
local DanNet      = require('lib.dannet.helpers')
local Logger      = require("utils.logger")

_ClassConfig      = {
    _version              = "1.1 - Live",
    _author               = "Derple, Morisato, Algar",
    ['ModeChecks']        = {
        IsTanking = function() return Core.IsModeActive("PetTank") end,
    },
    ['Modes']             = {
        'DPS',
        'PetTank',
    },
    ['OnModeChange']      = function(self, mode)
        if mode == "PetTank" then
            Core.DoCmd("/pet taunt on")
            Core.DoCmd("/pet resume on")
            Config:GetSettings().DoPetCommands        = true
            Config:GetSettings().AutoAssistAt         = 100
            Config:GetSettings().StayOnTarget         = false
            Config:GetSettings().DoAutoEngage         = true
            Config:GetSettings().DoAutoTarget         = true
            Config:GetSettings().AllowMezBreak        = true
            Config:GetSettings().WaitOnGlobalCooldown = false
        else
            Core.DoCmd("/pet taunt off")
            if Config:GetSetting('AutoAssistAt') == 100 then
                Config:GetSettings().AutoAssistAt = 98
            end
            Config:GetSettings().WaitOnGlobalCooldown = false
            Config:GetSettings().StayOnTarget = true
        end
    end,
    ['ItemSets']          = {
        ['Epic'] = {
            "Focus of Primal Elements",
            "Staff of Elemental Essence",
        },
    },
    ['AbilitySets']       = { --TODO: Look into new TOB item summons (Boiling Orb?)
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
        ['SpearNuke'] = {
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
        -- ['FireNuke'] = {
        --     -- Fire Nuke 1 <= LVL <= 70
        --     "Cremating Sands",
        --     "Ravaging Sands",
        --     "Incinerating Sands",
        --     "Crash of Sand",
        --     "Blistering Sands",
        --     "Searing Sands",
        --     "Broiling Sands",
        --     "Blast of Sand",
        --     "Burning Sands",
        --     "Burst of Sand",
        --     "Strike of Sand",
        --     "Torrid Sands",
        --     "Scorching Sands",
        --     "Scalding Sands",
        --     "Sun Vortex",
        --     "Star Strike",
        --     "Ancient: Nova Strike",
        --     "Burning Sand",
        --     "Shock of Fiery Blades",
        --     "Char",
        --     "Blaze",
        --     "Shock of Flame",
        --     "Burn",
        --     "Burst of Flame",
        -- },
        -- ['FireBoltNuke'] = {
        --     -- Fire Bolt Nukes
        --     "Bolt of Molten Dacite",
        --     "Bolt of Molten Olivine",
        --     "Bolt of Molten Komatiite",
        --     "Bolt of Skyfire",
        --     "Bolt of Molten Shieldstone",
        --     "Bolt of Molten Magma",
        --     "Bolt of Molten Steel",
        --     "Bolt of Rhyolite",
        --     "Bolt of Molten Scoria",
        --     "Bolt of Molten Dross",
        --     "Bolt of Molten Slag",
        --     "Bolt of Jerikor",
        --     "Firebolt of Tallon",
        --     "Seeking Flame of Seukor",
        --     "Scars of Sigil",
        --     "Lava Bolt",
        --     "Cinder Bolt",
        --     "Bolt of Flame",
        --     "Flame Bolt",
        -- },
        -- ['MagicNuke'] = {
        --     -- Nuke 1 <= LVL <= 69
        --     "Shock of Memorial Steel",
        --     "Shock of Carbide Steel",
        --     "Shock of Burning Steel",
        --     "Shock of Arcronite Steel",
        --     "Shock of Darksteel",
        --     "Shock of Blistersteel",
        --     "Shock of Argathian Steel",
        --     "Shock of Ethereal Steel",
        --     "Shock of Discordant Steel",
        --     "Shock of Cineral Steel",
        --     "Shock of Silvered Steel",
        --     "Blade Strike",
        --     "Rock of Taelosia",
        --     "Black Steel",
        --     "Shock of Steel",
        --     "Shock of Swords",
        --     "Shock of Spikes",
        --     "Shock of Blades",
        -- },
        -- ['MagicBolt'] = {
        --     -- Magic Bolt Nukes
        --     "Voidstone Bolt",
        --     "Luclinite Bolt",
        --     "Komatiite Bolt",
        --     "Korascian Bolt",
        --     "Meteoric Bolt",
        --     "Iron Bolt",
        -- },
        ['FireDD'] = { --Mix of Fire Nukes and Bolts appropriate for use at lower levels.
            "Burning Sand",
            "Scars of Sigil",
            "Lava Bolt",
            "Cinder Bolt",
            "Bolt of Flame",
            "Shock of Flame",
            "Flame Bolt",
            "Burn",
            "Burst of Flame",
        },
        ['BigFireDD'] = { -- Longer cast time bolts we can use when mobs are at higher health.
            "Bolt of Jerikor",
            "Firebolt of Tallon",
            "Seeking Flame of Seukor",
        },
        ['MagicDD'] = { -- Magic does not have any faster casts like Fire, we have only these.
            "Blade Strike",
            "Rock of Taelosia",
            "Black Steel",
            "Shock of Steel",
            "Shock of Swords",
            "Shock of Spikes",
            "Shock of Blades",
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
            "Firebound Covariance",
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
        --not used
        --[[ ['SingleDS'] = {
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
        },]] --
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
            "Reciprocal Companion",
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
            "Greater Conjuration: Earth",
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
            "Auspice of Usira",
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
            "Summon Molten Dacite Orb",
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
        ['ManaRodSummon'] = { -- Level 44 - 105
            --- ManaRodSummon - Focuses on group mana rod summon for ease.
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
        ['SingleCotH'] = {
            "Call of the Hero",
        },
        ['GroupCotH'] = {
            "Call of the Heroes",
        },
    },
    ['HealRotationOrder'] = {

    },
    ['RotationOrder']     = {
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToPetBuff() and (mq.TLO.Me.Pet.ID() == 0 or Config:GetSetting('DoPocketPet')) and Casting.AmIBuffable()
            end,
        },
        {
            name = 'PetHealPoint',
            state = 1,
            steps = 1,
            targetId = function(self) return { mq.TLO.Me.Pet.ID(), } end,
            cond = function(self, _) return mq.TLO.Me.Pet.ID() > 0 and (mq.TLO.Me.Pet.PctHPs() or 100) < Config:GetSetting('PetHealPct') end,
        },
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this. Timer lowered for mage due to high volume of actions
            name = 'PetBuff',
            timer = 30,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
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
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        {
            name = 'Malo',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoMalo') or Config:GetSetting('DoAEMalo') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff()
            end,
        },
        {
            name = 'Combat Pocket Pet',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoPocketPet') end,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS PET',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive("PetTank") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.SpellInCooldown()
            end,
        },
        {
            name = 'DPS(LowLevel)',
            state = 1,
            steps = 1,
            load_cond = function(self) return not self:GetResolvedActionMapItem('ChaoticNuke') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            load_cond = function(self) return self:GetResolvedActionMapItem('ChaoticNuke') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Summon ModRods',
            timer = 120, --this will only be checked once every 2 minutes
            state = 1,
            steps = 2,
            load_cond = function() return Config:GetSetting('SummonModRods') and Core.GetResolvedActionMapItem("ManaRodSummon") end,
            targetId = function(self)
                local groupIds = {}
                if not Core.OnEMU() or mq.TLO.Me.Inventory("MainHand")() then
                    table.insert(groupIds, mq.TLO.Me.ID())
                end
                local count = mq.TLO.Group.Members()
                for i = 1, count do
                    local mainHand = DanNet.query(mq.TLO.Group.Member(i).DisplayName(), "Me.Inventory[MainHand]", 1000)
                    if Core.OnEMU() and (mainHand and mainHand:lower() == "null") then
                        groupIds = {}
                        Logger.log_debug("%s has no weapon equipped, aborting ModRod summon to avoid corpse-looting conflicts.", mq.TLO.Group.Member(i).DisplayName())
                        break
                    else
                        table.insert(groupIds, mq.TLO.Group.Member(i).ID())
                    end
                end
                return groupIds
            end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and Casting.OkayToBuff()
                local pct = Config:GetSetting('GroupManaPct')
                local combat = combat_state == "Combat" and Config:GetSetting('CombatModRod') and (mq.TLO.Group.LowMana(pct)() or -1) >= Config:GetSetting('GroupManaCt')
                return downtime or combat
            end,
        },
    },
    -- Really the meat of this class.
    ['HelperFunctions']   = {
        user_tu_spell = function(self, aaName)
            local shroudSpell = self.ResolvedActionMap['ShroudSpell']
            local aaSpell = Casting.GetAASpell(aaName)
            if not shroudSpell or not shroudSpell() or not aaSpell or not aaSpell() or not Casting.CanUseAA(aaName) then return false end
            -- do we need to lookup the spell basename here? I dont think so but if this doesn't fire right take a look.
            if shroudSpell.Level() > aaSpell.Level() then return false end
            return true
        end,
        give_pet_toys = function(self, petId)
            if Config:GetSetting('DoPetWeapons') then
                self.ClassConfig.HelperFunctions.summon_pet_toy(self, "Weapon", petId)
            end
            if Config:GetSetting('DoPetArmor') then
                self.ClassConfig.HelperFunctions.summon_pet_toy(self, "Armor", petId)
            end
            if Config:GetSetting('DoPetHeirlooms') then
                self.ClassConfig.HelperFunctions.summon_pet_toy(self, "Heirlooms", petId)
            end
        end,
        handle_pet_toys = function(self)
            if mq.TLO.Me.FreeInventory() < 2 or mq.TLO.Me.Level() < 73 then
                Logger.log_debug("handle_pet_toys() ==> \arFailed your level is below 73 or you dont have inv slots open!")
                return false
            end
            if (mq.TLO.Me.Pet.Equipment("Primary")() or 0) ~= 0 then
                Logger.log_verbose("handle_pet_toys() ==> \arFailed your pet already has weapons!")
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
                if member and member() and (member.Pet.ID() or 0) > 0 and (member.Pet.Equipment("primary")() or 0) == 0 then
                    if mq.TLO.Me.CombatState():lower() ~= "combat" then
                        self.ClassConfig.HelperFunctions.give_pet_toys(self, member.Pet.ID())
                    end
                end
            end
        end,
        summon_pet_toy = function(self, type, targetId)
            local petToyResolvedSpell = self.ResolvedActionMap[string.format("Pet%sSummon", type)]

            if not petToyResolvedSpell or not petToyResolvedSpell() then
                Logger.log_super_verbose("summon_pet_toy() ==> \arFailed to resolve Pet%sSummon item type!", type)
                return false
            end

            if mq.TLO.Me.Level() < petToyResolvedSpell.Level() then
                Logger.log_super_verbose("summon_pet_toy() ==> \arFailed your level is below the pet toy spell(%s) level: %d!", petToyResolvedSpell.RankName(),
                    petToyResolvedSpell.Level())
                return false
            end

            if not Casting.SpellReady(petToyResolvedSpell) then
                Logger.log_super_verbose("summon_pet_toy() ==> \arFailed SpellReady() Check!", type)
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
                Logger.log_super_verbose("summon_pet_toy() ==> \arFailed to find open top level inv slot!", openSlot)
                return
            end

            Logger.log_super_verbose("summon_pet_toy() ==> \agUsing PackID=%d", openSlot)

            Casting.UseSpell(petToyResolvedSpell.RankName(), mq.TLO.Me.ID(), Targeting.GetXTHaterCount() == 0)

            mq.delay("5s", function() return (mq.TLO.Cursor.ID() or 0) > 0 end)

            if (mq.TLO.Cursor.ID() or 0) == 0 then return false end

            local packName = string.format("pack%d", openSlot)

            while mq.TLO.Cursor.ID() do
                Core.DoCmd("/shiftkey /itemnotify %s leftmouseup", packName)
                mq.delay("1s", function() return mq.TLO.Cursor.ID() == nil end)
            end

            -- What happens if the bag is a Folded Pack
            while string.find(mq.TLO.InvSlot(packName).Item.Name(), "Folded Pack") ~= nil do
                Core.DoCmd("/nomodkey /itemnotify %s rightmouseup", packName)
                -- Folded backs end up on our cursor.
                mq.delay("5s", function() return (mq.TLO.Cursor.ID() or 0) > 0 end)
                -- Drop the unfolded pack back in our inventory
                while mq.TLO.Cursor.ID() do
                    Core.DoCmd("/nomodkey /itemnotify %s leftmouseup", packName)
                    mq.delay("1s", function() return mq.TLO.Cursor.ID() == nil end)
                end
            end

            -- Hand Toy off to the Pet
            -- Open our pack
            Core.DoCmd("/nomodkey /itemnotify %s rightmouseup", packName)

            -- TODO: Need a condition to check if the pack window has opened
            mq.delay("1s")

            if type == "Armor" or type == "Heirloom" then
                -- Loop through each item in our bag and give it to the pet
                for i = 1, mq.TLO.InvSlot(packName).Item.Container() do
                    if mq.TLO.InvSlot(packName).Item.Item(i).Name() ~= nil then
                        ItemManager.GiveTo(targetId, mq.TLO.InvSlot(packName).Item.Item(i).Name(), 1)
                    end
                end
            else
                -- Must be a weapon
                -- Hand Weapons off to the pet
                local itemsToGive = { 2, 4, }
                if Core.IsModeActive("PetTank") then
                    -- If we're pet tanking, give the pet the hate swords in bag slots
                    -- 7 and 8. At higher levels this only ends up with one aggro swords
                    -- so perhaps there's a way of generalizing later.
                    itemsToGive = { 7, 8, }
                end

                for _, i in ipairs(itemsToGive) do
                    Logger.log_debug("Item Name %s", mq.TLO.InvSlot(packName).Item.Item(i).Name())
                    ItemManager.GiveTo(targetId, mq.TLO.InvSlot(packName).Item.Item(i).Name(), 1)
                end
            end

            -- Delete the satchel if it's still there
            if mq.TLO.InvSlot(packName).Item.ID() ~= nil then
                Core.DoCmd("/nomodkey /itemnotify %s leftmouseup", packName)
                mq.delay("5s", function() return mq.TLO.Cursor.ID() ~= nil end)

                -- Just double check and make sure it's a temporary
                if mq.TLO.Cursor.ID() and mq.TLO.Cursor.NoRent() then
                    Core.DoCmd("/destroy")
                    mq.delay(30, function() return mq.TLO.Cursor.ID() == nil end)
                end
            end
        end,
        summon_pet = function(self)
            local petSpellVar = string.format("%sPetSpell", self.ClassConfig.DefaultConfig.PetType.ComboOptions[Config:GetSetting('PetType')])
            local resolvedPetSpell = self.ResolvedActionMap[petSpellVar]

            if not resolvedPetSpell then
                Logger.log_debug("No valid pet spell found for type: %s", petSpellVar)
                return false
            end

            if mq.TLO.FindItemCount("Malachite")() > 0 then
                return Casting.UseSpell(resolvedPetSpell.RankName(), mq.TLO.Me.ID(), self.CombatState == "Downtime")
            else
                Logger.log_error("\ayYou don't have \agMalachite\ay. And you call yourself a mage?")
                --Config:GetSettings().DoPet = false
                return false
            end
        end,
        pet_management = function(self)
            if not Config:GetSettings().DoPet or (Casting.CanUseAA("Companion's Suspension") and not Casting.AAReady("Companion's Suspension")) then
                return false
            end

            -- Low Level Check - In 2 cases You're too lowlevel to Know Suspend companion and have no pet or You've Turned off Usepocket pet.
            if mq.TLO.Me.Pet.ID() == 0 and (not Casting.CanUseAA("Companion's Suspension") or not Config:GetSetting('DoPocketPet')) then
                if not self.ClassConfig.HelperFunctions.summon_pet(self) then
                    Logger.log_debug("\arPetManagement - Case 0 -> Summon Failed")
                    return false
                end
            end

            -- Pocket Pet Stuff Begins. -  Added Check for DoPocketPet to be Positive Rather than Assuming
            if Config:GetSetting('DoPocketPet') then
                if self.TempSettings.PocketPet and mq.TLO.Me.Pet.ID() == 0 and Targeting.GetXTHaterCount() > 0 then
                    Casting.UseAA("Companion's Suspension", 0)
                    self.TempSettings.PocketPet = false
                    return true
                end

                -- Case 1 - No pocket pet and no pet up
                if not self.TempSettings.PocketPet and mq.TLO.Me.Pet.ID() == 0 and Targeting.GetXTHaterCount() == 0 then
                    Logger.log_debug("\ayPetManagement - Case 1 no Pocket Pet and no Pet")
                    if not self.ClassConfig.HelperFunctions.summon_pet(self) then
                        Logger.log_debug("\arPetManagement - Case 1 -> Summon Failed")
                        return false
                    end

                    if Casting.AARank("Companion's Suspension") > 2 then
                        -- Need to buff
                        local resolvedPetHasteSpell = self.ResolvedActionMap["PetHaste"]
                        Casting.UseSpell(resolvedPetHasteSpell.RankName(), mq.TLO.Me.Pet.ID(), true)
                        local resolvedPetBuffSpell = self.ResolvedActionMap["PetIceFlame"]
                        Casting.UseSpell(resolvedPetBuffSpell.RankName(), mq.TLO.Me.Pet.ID(), true)
                        if mq.TLO.Me.Pet.ID() then
                            self.ClassConfig.HelperFunctions.handle_pet_toys(self)
                        end
                        Casting.UseAA("Companion's Suspension", 0)
                        self.TempSettings.PocketPet = true
                    end

                    return true
                end
            end
            -- Case 2 - No pocket pet and pet up
            if not self.TempSettings.PocketPet and (mq.TLO.Me.Pet.ID() or 0) > 0 and Targeting.GetXTHaterCount() == 0 then
                Logger.log_debug("\ayPetManagement - Case 2 no Pocket Pet But Pet is up - pocketing")
                Casting.UseAA("Companion's Suspension", 0)
                if (mq.TLO.Me.Pet.ID() or 0) == 0 then
                    if not self.ClassConfig.HelperFunctions.summon_pet(self) then
                        Logger.log_debug("\arPetManagement - Case 2 -> Summon Failed")
                        return false
                    end
                end
                self.TempSettings.PocketPet = true

                return true
            end

            -- Case 3 - Pocket Pet and no pet up
            if self.TempSettings.PocketPet and (mq.TLO.Me.Pet.ID() or 0) == 0 and Targeting.GetXTHaterCount() == 0 then
                Logger.log_debug("\ayPetManagement - Case 3 Pocket Pet But No Pet is up")
                if not self.ClassConfig.HelperFunctions.summon_pet(self) then
                    Logger.log_debug("\arPetManagement - Case 3 -> Summon Failed")
                    return false
                end

                return true
            end

            return true
        end,
        HandleItemSummon = function(self, itemSource, scope) --scope: "personal" or "group" summons
            if not itemSource and itemSource() then return false end
            if not scope then return false end

            mq.delay("2s", function() return mq.TLO.Cursor() and mq.TLO.Cursor.ID() == mq.TLO.Spell(itemSource).RankName.Base(1)() end)

            if not mq.TLO.Cursor() then
                Logger.log_debug("No valid item found on cursor, item handling aborted.")
                return false
            end

            Logger.log_info("Sending the %s to our bags.", mq.TLO.Cursor())

            if scope == "group" then
                local delay = Config:GetSetting('AIGroupDelay')
                Comms.PrintGroupMessage("%s summoned, issuing autoinventory command momentarily.", mq.TLO.Cursor())
                mq.delay(delay)
                Core.DoGroupCmd("/autoinventory")
            elseif scope == "personal" then
                local delay = Config:GetSetting('AISelfDelay')
                mq.delay(delay)
                Core.DoCmd("/autoinventory")
            else
                Logger.log_debug("Invalid scope sent: (%s). Item handling aborted.", scope)
                return false
            end
        end,
    },
    ['Rotations']         = {
        ['PetSummon'] = {
            {
                name = "Pet Summon",
                type = "CustomFunc",
                active_cond = function(self)
                    return mq.TLO.Me.Pet.ID() > 0
                end,
                cond = function(self)
                    if self.TempSettings.PocketPet == nil then self.TempSettings.PocketPet = false end
                    return mq.TLO.Me.Pet.ID() == 0 and Config:GetSetting('DoPet')
                end,
                custom_func = function(self) return self.ClassConfig.HelperFunctions.summon_pet(self) end,
                post_activate = function(self, _, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
            {
                name = "Store Pocket Pet",
                type = "CustomFunc",
                active_cond = function(self)
                    return self.TempSettings.PocketPet == true
                end,
                cond = function(self)
                    if self.TempSettings.PocketPet == nil then self.TempSettings.PocketPet = false end
                    return not self.TempSettings.PocketPet and Config:GetSetting('DoPocketPet')
                end,
                custom_func = function(self) return self.ClassConfig.HelperFunctions.pet_management(self) end,
            },
        },
        ['PetHealPoint'] = {
            {
                name = "PetHealSpell",
                type = "Spell",
            },
        },
        ['PetBuff'] = {
            {
                name = "HandlePetToys",
                type = "CustomFunc",
                custom_func = function(self)
                    if not Config:GetSetting("DoPetWeapons") and not Config:GetSetting("DoPetArmor") and not Config:GetSetting("DoPetHeirlooms") then return false end
                    return self.ClassConfig.HelperFunctions.handle_pet_toys and self.ClassConfig.HelperFunctions.handle_pet_toys(self) or false
                end,
            },
            {
                name = "PetIceFlame",
                type = "Spell",
                active_cond = function(self, spell)
                    return mq.TLO.Me.PetBuff(spell.RankName.Name())() ~= nil or mq.TLO.Me.PetBuff(spell.Name())() ~= nil
                end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetHaste",
                type = "Spell",
                active_cond = function(self, spell)
                    return mq.TLO.Me.PetBuff(spell.RankName.Name())() ~= nil or mq.TLO.Me.PetBuff(spell.Name())() ~= nil
                end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetManaConv",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if mq.TLO.Me.Pet.ID() == 0 then return false end
                    return Casting.PetBuffItemCheck(itemName)
                end,
            },
            {
                name = "Second Wind Ward",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "Host in the Shell",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName) and Core.IsModeActive("PetTank")
                end,
            },
            {
                name = "Companion's Aegis",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName) and Core.IsModeActive("PetTank")
                end,
            },
            {
                name = "Companion's Intervening Divine Aura",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName) and Core.IsModeActive("PetTank")
                end,
            },
        },
        ['Combat Pocket Pet'] = {
            {
                name = "Engage Pocket Pet",
                type = "CustomFunc",
                active_cond = function(self)
                    return self.TempSettings.PocketPet == true and mq.TLO.Me.Pet.ID() == 0
                end,
                cond = function(self)
                    if self.TempSettings.PocketPet == nil then self.TempSettings.PocketPet = false end
                    return self.TempSettings.PocketPet and mq.TLO.Me.Pet.ID() == 0 and Targeting.GetXTHaterCount() > 0
                end,
                custom_func = function(self)
                    Logger.log_info("\atPocketPet: \arNo pet while in combat! \agPulling out pocket pet")
                    Targeting.SetTarget(mq.TLO.Me.ID())
                    Casting.UseAA("Companion's Suspension", mq.TLO.Me.ID())
                    self.TempSettings.PocketPet = false

                    return true
                end,
            },
        },
        ['Burn'] = {
            {
                name = "EarthPetItemUse",
                type = "CustomFunc",
                cond = function(self)
                    if not self.ResolvedActionMap['EarthPetItemSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['EarthPetItemSummon'].RankName.Base(1)()
                    return mq.TLO.FindItemCount(baseItem)() >= 1
                end,
                custom_func = function(self)
                    if not self.ResolvedActionMap['EarthPetItemSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['EarthPetItemSummon'].RankName.Base(1)()
                    if mq.TLO.FindItemCount(baseItem)() >= 1 then
                        local invItem = mq.TLO.FindItem(baseItem)
                        return Casting.UseItem(invItem.Name(), Config.Globals.AutoTargetID)
                    end

                    return false
                end,
            },
            {
                name = "FirePetItemUse",
                type = "CustomFunc",
                cond = function(self)
                    if not self.ResolvedActionMap['FirePetItemSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['FirePetItemSummon'].RankName.Base(1)()
                    return mq.TLO.FindItemCount(baseItem)() >= 1
                end,
                custom_func = function(self)
                    if not self.ResolvedActionMap['FirePetItemSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['FirePetItemSummon'].RankName.Base(1)()
                    if mq.TLO.FindItemCount(baseItem)() >= 1 then
                        local invItem = mq.TLO.FindItem(baseItem)
                        return Casting.UseItem(invItem.Name(), Config.Globals.AutoTargetID)
                    end

                    return false
                end,
            },
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "AllianceBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.IsNamed(target) and not Casting.TargetHasBuff(spell) and
                        Config:GetSetting('DoAlliance') and Casting.CanAlliance()
                end,
            },
            {
                name = "Companion's Fury",
                type = "AA",
            },
            {
                name = "Host of the Elements",
                type = "AA",
            },
            {
                name = "Spire of Elements",
                type = "AA",
            },
            {
                name = "Heart of Skyfire",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
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
                name = "Servant of Ro",
                type = "AA",
            },
        },
        ['DPS PET'] = {
            {
                name = "OowRobeName",
                type = "CustomFunc",
                custom_func = function(self)
                    if not Core.IsModeActive("PetTank") then return end
                    local oowItems = { 'Glyphwielder\'s Tunic of the Summoner', 'Runemaster\'s Robe', }
                    for _, item in ipairs(oowItems) do
                        if mq.TLO.FindItemCount(item)() == 1 then
                            self.TempSettings.OowRobeBase = item
                            return Casting.UseItem(item, mq.TLO.Me.ID())
                        end
                    end

                    return false
                end,
            },
            {
                name = "PetStanceSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("PetTank") and self.TempSettings.OowRobeBase ~= nil and Core.IsModeActive("PetTank") and
                        Casting.PetBuffCheck(spell) and mq.TLO.Me.Pet.PctHPs() <= 95 and
                        (mq.TLO.Me.PetBuff(mq.TLO.Spell(self.TempSettings.OowRobeBase).RankName.Base(1)() or "").ID()) or 0 == 0
                end,
            },
            {
                name = "SurgeDS1",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "SurgeDS2",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "ShortDurDmgShield",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "FireShroud",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Force of Elements",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoForce')
                end,
            },
            {
                name = "FireOrbItem",
                type = "CustomFunc",
                custom_func = function(self)
                    if not self.ResolvedActionMap['FireOrbSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['FireOrbSummon'].RankName.Base(1)() or "None"
                    if mq.TLO.FindItemCount(baseItem)() == 1 then
                        local invItem = mq.TLO.FindItem(baseItem)
                        return Casting.UseItem(invItem.Name(), Config.Globals.AutoTargetID)
                    end
                    return false
                end,
            },
        },
        ['DPS'] = {
            {
                name = "SwarmPet",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "ChaoticNuke",
                type = "Spell",
                cond = function(self, _)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "SpearNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "VolleyNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Turn Summoned",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetBodyIs(target, "Undead Pet") and Targeting.AggroCheckOkay()
                end,
            },
            {
                name = "TwinCast",
                type = "Spell",
                cond = function(self, spell) return not Casting.IHaveBuff("Twincast") end,
            },
            --   {
            --       name = "AllianceBuff",
            --       type = "Spell",
            --      cond = function(self, spell, target)
            --           return Targeting.IsNamed(target) and not Casting.TargetHasBuff(spell) and
            --               Config:GetSetting('DoAlliance') and Casting.CanAlliance()
            --       end,
            --    },
        },
        ['DPS(LowLevel)'] = {
            {
                name = "BigFireDD",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('ElementChoice') ~= 1 then return false end
                    return Casting.OkayToNuke() and Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "FireDD",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('ElementChoice') ~= 1 then return false end
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "MagicDD",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('ElementChoice') ~= 2 then return false end
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Turn Summoned",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetBodyIs(target, "Undead Pet") and Targeting.AggroCheckOkay()
                end,
            },
        },
        ['Malo'] = {
            {
                name = "Malaise",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "MaloDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Malaise") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "Wind of Malaise",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoAEMalo') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "LongDurDmgShield",
                type = "Spell",
                active_cond = function(self, spell)
                    return Casting.IHaveBuff(spell)
                end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HandleGroupToys",
                type = "CustomFunc",
                custom_func = function(self)
                    return self.ClassConfig.HelperFunctions.group_toys and self.ClassConfig.HelperFunctions.group_toys(self) or false
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "Elemental Conversion",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() <= Config:GetSetting('GatherManaPct') and mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() <= Config:GetSetting('GatherManaPct') and not mq.TLO.Me.SpellReady(self.ResolvedActionMap['GatherMana'] or "")() and
                        mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "GatherMana",
                type = "Spell",
                cond = function(self, spell)
                    return spell and spell() and mq.TLO.Me.PctMana() <= Config:GetSetting('GatherManaPct') and Casting.CastReady(spell)
                end,
            },
            {
                name = "ManaRegenBuff",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfShield",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Thaumaturge's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "PetAura",
                type = "Spell",
                active_cond = function(self, spell)
                    return Casting.AuraActiveByName(spell.BaseName()) ~= nil
                end,
                cond = function(self, spell)
                    return not Casting.AuraActiveByName(spell.BaseName())
                end,
            },
            {
                name = "FireOrbSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.RankName.Base(1)() or "")() == 0
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.HandleItemSummon, self, spell, "personal")
                    end
                end,
            },
            {
                name = "EarthPetItemSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.RankName.Base(1)() or "")() == 0
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.HandleItemSummon, self, spell, "personal")
                    end
                end,
            },
            {
                name = "FirePetItemSummon",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.FindItemCount(spell.RankName.Base(1)() or "")() == 0
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.HandleItemSummon, self, spell, "personal")
                    end
                end,
            },
            {
                name = "Elemental Form",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Fire Core",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },

        },
        ['Summon ModRods'] = {
            {
                name = "Summon Modulation Shard",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('SummonModRods') or not Casting.CanUseAA(aaName) or not Targeting.TargetIsACaster(target) then return false end
                    local modRodItem = mq.TLO.Spell(aaName).RankName.Base(1)()
                    return modRodItem and DanNet.query(target.CleanName(), string.format("FindItemCount[%d]", modRodItem), 1000) == "0" and
                        (mq.TLO.Cursor.ID() or 0) == 0
                end,
                post_activate = function(self, aaName, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.HandleItemSummon, self, aaName, "group")
                    end
                end,
            },
            {
                name = "ManaRodSummon",
                type = "Spell",
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Summon Modulation Shard") or not Config:GetSetting('SummonModRods') or not Targeting.TargetIsACaster(target) then return false end
                    local modRodItem = spell.RankName.Base(1)()
                    return modRodItem and DanNet.query(target.CleanName(), string.format("FindItemCount[%d]", modRodItem), 1000) == "0" and
                        (mq.TLO.Cursor.ID() or 0) == 0
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.HandleItemSummon, self, spell, "group")
                    end
                end,
            },
            {
                name = "SelfManaRodSummon",
                type = "Spell",
                cond = function(self, spell, target, combat_state)
                    if target.ID() ~= mq.TLO.Me.ID() then return false end
                    return mq.TLO.FindItemCount(spell.RankName.Base(1)() or "")() == 0 and (mq.TLO.Cursor.ID() or 0) == 0 and
                        not (combat_state == "Combat" and mq.TLO.Me.PctMana() > Config:GetSetting('GroupManaPct'))
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.HandleItemSummon, self, spell, "personal")
                    end
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "SpearNuke", },
                { name = "FireDD", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "ChaoticNuke", },
                { name = "BigFireDD", },
            },
        },
        {
            gem = 3,
            spells = {

                { name = "SwarmPet", cond = function(self) return mq.TLO.Me.Level() >= 70 end, },
                { name = "MagicDD", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "VolleyNuke", },
                { name = "PetHealSpell", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "TwinCast", },
                { name = "MaloDebuff",       cond = function(self) return Config:GetSetting('DoMalo') and not Casting.CanUseAA("Malaise") end, },
                { name = "PetHealSpell", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "GroupCotH", },
                { name = "ManaRodSummon", },
                { name = "PetHealSpell", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "FireOrbSummon", },
                { name = "PetHealSpell", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PetManaNuke", },
                { name = "PetHealSpell", },
                { name = "SingleCotH",       cond = function() return not Casting.CanUseAA('Call of the Hero') end, },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "GatherMana", },
                { name = "PetHealSpell", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "EarthPetItemSummon", },
                { name = "PetHealSpell", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "FirePetItemSummon", },
                { name = "PetHealSpell", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SelfManaRodSummon", },
                { name = "PetHealSpell", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PetHealSpell", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 14,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PetHealSpell", },
            },
        },
    },
    ['DefaultConfig']     = {
        ['Mode']           = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What is the difference between the modes?",
            Answer = "Fire Mode will use Fire Nukes and strive for DPS.\n" ..
                "PetTank mode will Focus on keeping the Pet alive as the main tank.",
        },
        ['DoPocketPet']    = {
            DisplayName = "Do Pocket Pet",
            Category = "Pet",
            Tooltip = "Pocket your pet during downtime",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "I have suspend Minion AA, how do I keep a spare pet suspended?",
            Answer = "You can use the [DoPocketPet] feature to keep a spare pet suspended.",
        },
        ['DoPetArmor']     = {
            DisplayName = "Do Pet Armor",
            Category = "Pet",
            Tooltip = "Summon Armor for Pets",
            Default = false,
            FAQ = "I want to make sure my pet is always armored, how do I do that?",
            Answer = "You can use the [DoPetArmor] feature to summon pet armor.",
        },
        ['DoPetWeapons']   = {
            DisplayName = "Do Pet Weapons",
            Category = "Pet",
            Tooltip = "Summon Weapons for Pets",
            Default = false,
            FAQ = "I want to make sure my pet is always armed, how do I do that?",
            Answer = "You can use the [DoPetWeapons] feature to summon pet weapons.",
        },
        ['PetType']        = {
            DisplayName = "Pet Type",
            Category = "Pet",
            Tooltip = "1 = Fire, 2 = Water, 3 = Earth, 4 = Air",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Water', 'Earth', 'Air', },
            Default = 2,
            Min = 1,
            Max = 4,
            FAQ = "Can I specify the type of pet I want to use?",
            Answer = "Yes, you can select the type of pet you want to summon using the [PetType] setting.",
        },
        ['DoPetHeirlooms'] = {
            DisplayName = "Do Pet Heirlooms",
            Category = "Pet",
            Tooltip = "Summon Heirlooms for Pets",
            Default = false,
            FAQ = "I want to make sure my pet is always Heirloomed, how do I do that?",
            Answer = "You can use the [DoPetHeirlooms] feature to summon pet Heirlooms.",
        },
        ['PetHealPct']     = {
            DisplayName = "Pet Heal %",
            Category = "Pet",
            Tooltip = "Heal pet at [X]% HPs",
            Default = 80,
            Min = 1,
            Max = 99,
            FAQ = "My pet keeps dying, how do I keep it alive?",
            Answer = "You can set the [PetHealPct] to a lower value to heal your pet sooner.\n" ..
                "Also make sure that [DoPetHeals] is enabled.",
        },
        ['SelfModRod']     = {
            DisplayName = "Self Mod Rod Item",
            Category = "Mana",
            Tooltip = "Click the modrod clicky you want to use here",
            Type = "ClickyItem",
            Default = "",
            FAQ = "Can I specify the mod rod item I want to use?",
            Answer = "Yes, you can specify the mod rod item you want to use by setting the [SelfModRod] setting.",
        },
        ['SummonModRods']  = {
            DisplayName = "Summon Mod Rods",
            Category = "Mana",
            Index = 1,
            Tooltip = "Summon Mod Rods",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Can I summon mod rods for my group?",
            Answer = "Yes, you can summon mod rods for your group by setting the [SummonModRods] setting.",
        },
        ['GatherManaPct']  = {
            DisplayName = "Gather Mana %",
            Category = "Mana",
            Tooltip = "When to use Gather Mana",
            Default = 70,
            Min = 1,
            Max = 99,
            FAQ = "How do I adjust when to use Gather Mana?",
            Answer = "You can adjust when to use Gather Mana by setting the [GatherManaPct] setting.",
        },
        ['DoForce']        = {
            DisplayName = "Do Force",
            Category = "Spells and Abilities",
            Tooltip = "Use Force of Elements AA",
            Default = true,
            FAQ = "I want to use Force of Elements AA in my rotation, how do I do that?",
            Answer = "You can use the [DoForce] feature to use the Force of Elements AA in your rotation.",
        },
        ['ElementChoice']  = {
            DisplayName = "Element Choice:",
            Category = "DPS Low Level",
            Index = 1,
            Tooltip = "Choose an element to focus on under level 71.",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Magic', },
            Default = 1,
            Min = 1,
            Max = 2,
            RequiresLoadoutChange = true,
            FAQ = "I'm fighting fire-resistant mobs, how can I use my magic nukes?",
            Answer = "If you are under level 70, you can swap to magic nukes on the DPS Low Level tab.",
        },
        ['DoChestClick']   = {
            DisplayName = "Do Chest Click",
            Category = "Utilities",
            Tooltip = "Click your chest item",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "How do I use my chest clicky?",
            Answer = "You can use the [DoChestClick] feature to click your chest item.",
        },
        ['AISelfDelay']    = {
            DisplayName = "Autoinv Delay (Self)",
            Category = "Utilities",
            Tooltip = "Delay in ms before /autoinventory after summoning, adjust if you notice items left on cursors regularly.",
            Default = 50,
            Min = 1,
            Max = 250,
            FAQ = "Why do I always have items stuck on the cursor?",
            Answer = "You can adjust the delay before autoinventory by setting the [AISelfDelay] setting.\n" ..
                "Increase the delay if you notice items left on cursors regularly.",

        },
        ['AIGroupDelay']   = {
            DisplayName = "Autoinv Delay (Group)",
            Category = "Utilities",
            Tooltip = "Delay in ms before /autoinventory after summoning, adjust if you notice items left on cursors regularly.",
            Default = 150,
            Min = 1,
            Max = 500,
            FAQ = "Why do I always have items stuck on the cursor?",
            Answer = "You can adjust the delay before autoinventory by setting the [AIGroupDelay] setting.\n" ..
                "Increase the delay if you notice items left on cursors regularly.",
        },
        ['DoMalo']         = {
            DisplayName = "Cast Malo",
            Category = "Debuffs",
            Tooltip = "Do Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "I want to use Malo in my rotation, how do I do that?",
            Answer = "You can use the [DoMalo] feature to use Malo in your rotation.",
        },
        ['DoAEMalo']       = {
            DisplayName = "Cast AE Malo",
            Category = "Debuffs",
            Tooltip = "Do AE Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "I want to use AE Malo in my rotation, how do I do that?",
            Answer = "You can use the [DoAEMalo] feature to use AE Malo in your rotation.",
        },
        ['CombatModRod']   = {
            DisplayName = "Combat Mod Rods",
            Category = "Mana",
            Index = 2,
            Tooltip = "Summon Mod Rods in combat if the criteria below are met.",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Can i summon mod rods in combat?",
            Answer = "Yes, you can summon mod rods in combat by setting the [CombatModRod] setting.\n" ..
                "Otherwise we will only summon them during Downtime.",
        },
        ['GroupManaPct']   = {
            DisplayName = "Combat ModRod %",
            Category = "Mana",
            Index = 3,
            Tooltip = "Mana% to begin summoning Mod Rods in combat.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why am I Not summoning Mod Rods?",
            Answer = "You can adjust the mana percentage to begin summoning Mod Rods in combat by setting the [GroupManaPct] setting.\n" ..
                "Also Make sure you have the [CombatModRod] setting enabled if you want to resummon them during combat.\n" ..
                "Finally make sure you have the [SummonModRods] setting enabled.",
        },
        ['GroupManaCt']    = {
            DisplayName = "Combat ModRod Count",
            Category = "Mana",
            Index = 4,
            Tooltip = "The number of party members (including yourself) that need to be under the above mana percentage.",
            Default = 3,
            Min = 1,
            Max = 6,
            ConfigType = "Advanced",
            FAQ = "Why am I not summoning Mod Rods?",
            Answer =
                "You can adjust the number of party members that need to be under the above mana percentage to summon Mod Rods in combat by setting the [GroupManaCt] setting.\n" ..
                "Also Make sure you have the [CombatModRod] setting enabled if you want to resummon them during combat.\n" ..
                "Finally make sure you have the [SummonModRods] setting enabled.",
        },
    },
}

return _ClassConfig
