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
    _version              = "1.3 - The Hidden Forest WIP", -- Updated for base level 70, some tier 1
    _author               = "Derple, Morisato, Algar",
    ['Modes']             = {
        'DPS',
        'PBAE',
    },
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
            -- "Ravening Servant",
            -- "Roiling Servant",
            -- "Riotous Servant",
            -- "Reckless Servant",
            -- "Remorseless Servant",
            -- "Relentless Servant",
            -- "Ruthless Servant",
            -- "Ruinous Servant",
            -- "Rumbling Servant",
            -- "Rancorous Servant",
            -- "Rampaging Servant",
            "Raging Servant",
            "Rage of Zomm",
        },
        -- ['ChaoticNuke'] = {
        --     -- Chaotic Nuke with Beneficial Effect >= LVL69
        --     -- "Fickle Inferno",
        --     "Fickle Fire",
        -- },
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
        --     "Star Strike", -- Changed to another spell on Lazarus
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
            "Felx's Burning Earth",
            "Felx's Burning Sand",
            "Felx's Scars of Sigil",
            "Felx's Lava Bolt",
            "Felx's Cinder Bolt",
            "Felx's Bolt of Flame",
            "Felx's Shock of Flame",
            "Felx's Flame Bolt",
            "Felx's Burn",
            "Erandi's Burst of Flame",
        },
        ['BigFireDD'] = { -- Longer cast time bolts we can use when mobs are at higher health.
            "Ancient: Nova Strike",
            "Star Strike",
            "Felx's Bolt of Jerikor",
            "Felx's Firebolt of Tallon",
            "Felx's Seeking Flame of Seukor",
        },
        ['MagicDD'] = { -- Magic does not have any faster casts like Fire, we have only these.
            "Blade Strike",
            "Rock of Taelosia",
            "Black Steel",
            "Shock of Steel",
            "Shock of Swords",
            "Shock of Spikes",
            "Felx's Shock of Blades",
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
            "Felx's Rain of Jerikor",
            "Felx's Sun Storm",
            "Felx's Sirocco",
            "Felx's Rain of Lava",
            "Felx's Rain of Fire",
        },
        ['MagicRainNuke'] = {
            -- Magic Rain
            "Rain of Kukris",
            "Rain of Falchions",
            "Felx's Rain of Blades",
            "Felx's Rain of Spikes",
            "Felx's Rain Of Swords",
            "Felx's ManaStorm",
            "Felx's Maelstrom of Electricity",
            "Felx's Maelstrom of Thunder",
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
            -- Preferring group buffs for ease. Included all Single target Now as well
            -- "Circle of Magmaskin",
            -- "Magmaskin",
            --"Circle of Fireskin", -- for some reason the single target version is 1800000000 times better
            "Felx's Fireskin",
            "Felx's Maelstrom of Ro",
            "Felx's FlameShield of Ro",
            "Felx's Aegis of Ro",
            "Felx's Cadeau of Flame",
            "Felx's Boon of Immolation",
            "Felx's Shield of Lava",
            "Felx's Barrier of Combustion",
            "Felx's Inferno Shield",
            "Felx's Shield of Flame",
            "Felx's  Shield of Fire",
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
            "Rathe's Strength",
            "Earthen Strength",
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
            "Ecliptic Companion",
            "Composite Companion",
            "Dissident Companion",
            "Dichotomic Companion",
        },
        ['PetHealSpell'] = {
            -- Pet Heal*
            "Dranik's Renewal",
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
            "Elemental Magnificence",
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
            -- "Summon Molten Komatiite Orb",
            -- "Summon Firebound Orb",
            -- "Summon Blazing Orb",
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
        ['ForceStaffSummon'] = {
            "Summon: Staff of Force I",
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
        ['SingleCotH'] = {
            "Call of the Hero",
        },
        ['GroupCotH'] = {
            "Call of the Heroes",
        },
        ['PBAE2'] = {
            "Felx's Scintillation",
        },
        ['PBAE1'] = {
            "Felx's Wind of the Desert",
        },
        ['FranticDS'] = {
            "Frantic Flames",
        },
    },
    ['HealRotationOrder'] = {

    },
    ['RotationOrder']     = { -- TODO: Add emergency rotation, shared health, etc
        {                     --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToPetBuff() and (mq.TLO.Me.Pet.ID() == 0 or Config:GetSetting('DoPocketPet'))
                    and Casting.AmIBuffable()
            end,
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
            timer = 10,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        {
            name = 'PetHealing',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, target) return (mq.TLO.Me.Pet.PctHPs() or 100) < Config:GetSetting('PetHealPct') end,
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
            name = 'Malo',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoMalo') or Config:GetSetting('DoAEMalo') end,
            doFullRotation = true,
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
            name = 'DPS(PBAE)',
            state = 1,
            steps = 1,
            load_cond = function(self) return Core.IsModeActive('PBAE') and self:GetResolvedActionMapItem('PBAE2') end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if not Config:GetSetting('DoAEDamage') then return false end
                return combat_state == "Combat" and Targeting.AggroCheckOkay() and self.ClassConfig.HelperFunctions.AETargetCheck(Config:GetSetting('PBAETargetCnt'), true)
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.AggroCheckOkay()
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
        {
            name = 'ArcanumWeave',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoArcanumWeave') and Casting.CanUseAA("Acute Focus of Arcanum") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not mq.TLO.Me.Buff("Focus of Arcanum")()
            end,
        },
    },
    -- Really the meat of this class.
    ['HelperFunctions']   = {
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
                return false
            end
        end,
        pet_management = function(self)
            if not Config:GetSetting('DoPet') or (Casting.CanUseAA("Suspended Minion") and not Casting.AAReady("Suspended Minion")) then
                return false
            end

            -- Low Level Check - In 2 cases You're too lowlevel to Know Suspend companion and have no pet or You've Turned off Usepocket pet.
            if mq.TLO.Me.Pet.ID() == 0 and (not Casting.CanUseAA("Suspended Minion") or not Config:GetSetting('DoPocketPet')) then
                if not self.ClassConfig.HelperFunctions.summon_pet(self) then
                    Logger.log_debug("\arPetManagement - Case 0 -> Summon Failed")
                    return false
                end
            end

            -- Pocket Pet Stuff Begins. -  Added Check for DoPocketPet to be Positive Rather than Assuming
            if Config:GetSetting('DoPocketPet') then
                if self.TempSettings.PocketPet and mq.TLO.Me.Pet.ID() == 0 and Targeting.GetXTHaterCount() > 0 then
                    Casting.UseAA("Suspended Minion", mq.TLO.Me.ID(), true)
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

                    if Casting.AARank("Suspended Minion") > 1 then --Need to buff
                        local resolvedPetHasteSpell = self.ResolvedActionMap["PetHaste"]
                        Casting.UseSpell(resolvedPetHasteSpell.RankName(), mq.TLO.Me.Pet.ID(), true)
                        local resolvedPetBuffSpell = self.ResolvedActionMap["PetIceFlame"]
                        Casting.UseSpell(resolvedPetBuffSpell.RankName(), mq.TLO.Me.Pet.ID(), true)
                        -- if mq.TLO.Me.Pet.ID() then
                        --     self.ClassConfig.HelperFunctions.handle_pet_toys(self)
                        -- end
                        Casting.UseAA("Suspended Minion", mq.TLO.Me.ID(), true)
                        self.TempSettings.PocketPet = true
                    end

                    return true
                end
            end
            -- Case 2 - No pocket pet and pet up
            if not self.TempSettings.PocketPet and (mq.TLO.Me.Pet.ID() or 0) > 0 and Targeting.GetXTHaterCount() == 0 then
                Logger.log_debug("\ayPetManagement - Case 2 no Pocket Pet But Pet is up - pocketing")
                Casting.UseAA("Suspended Minion", mq.TLO.Me.ID(), true)
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
        ['PetHealing'] = {
            {
                name = "Companion's Blessing",
                type = "AA",
                cond = function(self, aaName, target)
                    return (mq.TLO.Me.Pet.PctHPs() or 999) <= Config:GetSetting('BigHealPoint')
                end,
            },
            {
                name = "Minion's Memento",
                type = "Item",
            },
            {
                name_func = function() return Casting.CanUseAA("Replenish Companion") and "Replenish Companion" or "Mend Companion" end,
                type = "AA",
            },
            {
                name = "PetHealSpell",
                type = "Spell",
                load_cond = function(self) Config:GetSetting('DoPetHealSpell') end,
            },
        },
        ['PetBuff'] = {
            { --if the buff is removed from the pet, the invisible rathe aura object remains; if we don't check for it, a spam condition could ensue
                -- buff will be lost on zone
                name = "PetAura",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell) and mq.TLO.SpawnCount("untargetable _strength radius 200 zradius 50")() == 0
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
                    if not spell or not spell() then return false end
                    return Casting.SelfBuffCheck(spell)
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
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "Aegis of Kildrukaun",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "Fortify Companion",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
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
                    Casting.UseAA("Suspended Minion", mq.TLO.Me.ID(), true)
                    self.TempSettings.PocketPet = false

                    return true
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if mq.TLO.Me.Pet.ID() == 0 then return false end
                    return Casting.PetBuffItemCheck(itemName)
                end,
            },
            {
                name = "Frenzied Burnout",
                type = "AA",
            },
            {
                name = "Host of the Elements",
                type = "AA",
            },
            {
                name = "Fundament: Second Spire of the Elements",
                type = "AA",
            },
            {
                name = "Heart of Flames",
                type = "AA",
                load_cond = function() return not Casting.CanUseAA("Fire Core") end,
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName, target) return Targeting.IsNamed(target) end,
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not mq.TLO.Me.Buff("Twincast")()
                end,
            },
            {
                name = "Forsaken Conjurer's Shoes",
                type = "Item",
                load_cond = function(self) return mq.TLO.FindItem("=Forsaken Conjurer's Shoes")() end,
            },
            {
                name = "Servant of Ro",
                type = "AA",
            },
            {
                name = "FranticDS",
                type = "CustomFunc",
                load_cond = function(self) return Config:GetSetting('DoFranticDS') end,
                cond = function(self, spell, target)
                    local shieldSpell = Core.GetResolvedActionMapItem("FranticDS")
                    return Casting.CastReady(shieldSpell)
                end,
                custom_func = function(self)
                    local shieldSpell = Core.GetResolvedActionMapItem("FranticDS")
                    Casting.UseSpell(shieldSpell.RankName(), Core.GetMainAssistId(), false, false, 0)
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Summon Companion",
                type = "AA",
                cond = function(self, aaName, target)
                    if mq.TLO.Me.Pet.ID() == 0 then return false end
                    local pet = mq.TLO.Me.Pet
                    return not pet.Combat() and (pet.Distance3D() or 0) > 200
                end,
            },
            {
                name = "Force of Elements",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.AggroCheckOkay()
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
        ['DPS(PBAE)'] = {
            {
                name = "PBAE1",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "PBAE2",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.InSpellRange(spell, target)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "SwarmPet",
                type = "Spell",
                load_cond = function() return Config:GetSetting('DoSwarmPet') > 1 end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke() and not (Config:GetSetting('DoSwarmPet') == 2 and not Targeting.IsNamed(target))
                end,
            },
            {
                name = "BigFireDD",
                type = "Spell",
                load_cond = function() return Config:GetSetting('ElementChoice') == 1 end,
                cond = function(self, spell, target)
                    return Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "FireDD",
                type = "Spell",
                load_cond = function() return Config:GetSetting('ElementChoice') == 1 end,
                cond = function(self, spell, target)
                    return Targeting.MobHasLowHP(target)
                end,
            },
            {
                name = "MagicDD",
                type = "Spell",
                load_cond = function() return Config:GetSetting('ElementChoice') == 2 end,
            },
            {
                name = "Turn Summoned",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetBodyIs(target, "Undead Pet")
                end,
            },
            -- {
            --     name = "ChaoticNuke",
            --     type = "Spell",
            -- },
        },
        ['Malo'] = {
            {
                name = "Wind of Malosinete",
                type = "AA",
                load_cond = function() return Config:GetSetting('DoAEMalo') end,
                cond = function(self, aaName)
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AEMaloCount') and Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Malosinete",
                type = "AA",
                load_cond = function() return Casting.CanUseAA("Malosinete") end,
                cond = function(self, aaName)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "MaloDebuff",
                type = "Spell",
                load_cond = function() return not Casting.CanUseAA("Malosinete") end,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell)
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
                    if (spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsATank(target) then return false end
                    return Casting.GroupBuffCheck(spell, target) and not Casting.IHaveBuff("Circle of " .. spell.Name())
                end,
            },
            {
                name = "ForceStaffSummon",
                type = "Spell",
                cond = function(self, spell, target)
                    local forceStaff = spell.RankName.Base(1)()
                    return forceStaff and DanNet.query(target.CleanName(), string.format("FindItemCount[%d]", forceStaff), 1000) == "0" and
                        (mq.TLO.Cursor.ID() or 0) == 0
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.HandleItemSummon, self, spell, "group")
                    end
                end,
            },
            {
                name = "FireShroud",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Targeting.TargetIsMA(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                        -- workarounds for laz
                        and not Casting.PeerBuffCheck(19847, target, true) -- necrotic pustules
                        and not Casting.PeerBuffCheck(8484, target, true)  -- decrepit skin
                end,
                post_activate = function(self, spell, success)
                    local petName = mq.TLO.Me.Pet.CleanName() or "None"
                    mq.delay("3s", function() return not mq.TLO.Me.Casting() end)
                    if success and mq.TLO.Me.XTarget(petName)() then
                        Comms.PrintGroupMessage("It seems %s has triggered combat due to a server bug, calling the pet back.", spell)
                        Core.DoCmd('/pet back off')
                    end
                end,
            },
        },
        ['Downtime'] = {
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
                name = "Fire Core",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
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
                        Core.SafeCallFunc("Autoinventory", self.ClassConfig.HelperFunctions.HandleItemSummon, self, spell, "group")
                    end
                end,
            },
            {
                name = "Elemental Form: Fire",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['Summon ModRods'] = {
            { -- Mod Rod AA, will use the first(best) one found.
                name_func = function(self)
                    return Casting.GetFirstAA({ "Large Modulation Shard", "Medium Modulation Shard", "Small Modulation Shard", })
                end,
                type = "AA",
                load_cond = function() return Casting.CanUseAA("Small Modulation Shard") end,
                cond = function(self, aaName, target)
                    if not Targeting.TargetIsACaster(target) then return false end
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
                load_cond = function() return not Casting.CanUseAA("Small Modulation Shard") end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsACaster(target) then return false end
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
        },
        ['ArcanumWeave'] = {
            {
                name = "Empowered Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Enlightened Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Acute Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
    },
    ['SpellList']         = {
        {
            name = "Default", --This name is abitrary, it is simply what shows up in the UI when this spell list is loaded.
            spells = {        -- Spells will be loaded in order (if the conditions are met), until all gem slots are full.
                { name = "FireDD",           cond = function(self) return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "BigFireDD",        cond = function(self) return Config:GetSetting('ElementChoice') == 1 end, },
                { name = "MagicDD",          cond = function(self) return Config:GetSetting('ElementChoice') == 2 end, },
                { name = "SwarmPet", },
                { name = "PBAE1",            cond = function(self) return Core.IsModeActive("PBAE") end, },
                { name = "PBAE2",            cond = function(self) return Core.IsModeActive("PBAE") end, },
                { name = "MaloDebuff",       cond = function(self) return Config:GetSetting('DoMalo') and not Casting.CanUseAA("Malosinete") end, },
                { name = "PetHealSpell",     cond = function(self) return Config:GetSetting('DoPetHealSpell') end, },
                { name = "GroupCotH", },
                { name = "SingleCotH",       cond = function() return not Casting.CanUseAA('Call of the Hero') end, },
                { name = "ForceStaffSummon", },
                { name = "ManaRodSummon",    cond = function(self) return Config:GetSetting('SummonModRods') and not Casting.CanUseAA("Small Modulation Shard") end, },
                { name = "FireOrbSummon", },
                { name = "FireShroud", },
                { name = "LongDurDmgShield", },
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
            Answer = "DPS Mode performs exactly as described.\n" ..
                "PBAE Mode will use PBAE spells when configured, alongside the DPS rotation.",
        },
        ['DoPocketPet']    = {
            DisplayName = "Do Pocket Pet",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Summoning",
            Index = 102,
            Tooltip = "Use suspend minion to pocket your pet during downtime.",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['DoPetArmor']     = {
            DisplayName = "Do Pet Armor",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 101,
            Tooltip = "Summon Armor for Pets",
            Default = false,
        },
        ['DoPetWeapons']   = {
            DisplayName = "Do Pet Weapons",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 102,
            Tooltip = "Summon Weapons for Pets",
            Default = false,
        },
        ['PetType']        = {
            DisplayName = "Pet Type",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Summoning",
            Index = 101,
            Tooltip = "1 = Fire, 2 = Water, 3 = Earth, 4 = Air",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Water', 'Earth', 'Air', },
            Default = 2,
            Min = 1,
            Max = 4,
        },
        ['DoPetHeirlooms'] = {
            DisplayName = "Do Pet Heirlooms",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 103,
            Tooltip = "Summon Heirlooms for Pets",
            Default = false,
        },
        ['DoPetHealSpell'] = {
            DisplayName = "Pet Heal Spell",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Mem and cast your Pet Heal spell. AA Pet Heals are always used in emergencies.",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['PetHealPct']     = {
            DisplayName = "Pet Heal Spell HP%",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Healing Thresholds",
            Index = 101,
            Tooltip = "Use your pet heal spell when your pet is at or below this HP percentage.",

            Default = 60,
            Min = 1,
            Max = 99,
        },
        ['SummonModRods']  = {
            DisplayName = "Summon Mod Rods",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 103,
            Tooltip = "Summon Mod Rods",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['ElementChoice']  = {
            DisplayName = "Element Choice:",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 1,
            Tooltip = "Choose an element to focus on under level 71.",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Magic', },
            Default = 1,
            Min = 1,
            Max = 2,
            RequiresLoadoutChange = true,
        },
        ['DoSwarmPet']     = {
            DisplayName = "Swarm Pet Spell:",
            Group = "Abilities",
            Header = "Pet",
            Category = "Swarm Pets",
            Index = 101,
            Tooltip = "Choose the conditions to cast your Swarm Pet Spell.",
            Type = "Combo",
            ComboOptions = { 'Never', 'Named Only', 'Always', },
            Default = 2,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
        },
        ['DoFranticDS']    = {
            DisplayName = "Frantic Flames",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 102,
            Tooltip = "Use Frantic Flames during burns.",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = true,
        },
        ['AISelfDelay']    = {
            DisplayName = "Autoinv Delay (Self)",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 107,
            Tooltip = "Delay in ms before /autoinventory after summoning, adjust if you notice items left on cursors regularly.",
            Default = 50,
            Min = 1,
            Max = 250,
        },
        ['AIGroupDelay']   = {
            DisplayName = "Autoinv Delay (Group)",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 108,
            Tooltip = "Delay in ms before /autoinventory after summoning, adjust if you notice items left on cursors regularly.",
            Default = 150,
            Min = 1,
            Max = 500,
        },
        ['DoMalo']         = {
            DisplayName = "Cast Malo",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Index = 101,
            Tooltip = "Do Malo Spells/AAs",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = true,
        },
        ['DoAEMalo']       = {
            DisplayName = "Cast AE Malo",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Index = 102,
            Tooltip = "Do AE Malo Spells/AAs",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = false,
        },
        ['AEMaloCount']    = {
            DisplayName = "AE Malo Count",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Index = 103,
            Tooltip = "Number of XT Haters before we use AE Malo.",
            Min = 1,
            Default = 2,
            Max = 30,
            ConfigType = "Advanced",
        },
        ['CombatModRod']   = {
            DisplayName = "Combat Mod Rods",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 104,
            Tooltip = "Summon Mod Rods in combat if the criteria below are met.",
            Default = true,
            ConfigType = "Advanced",
        },
        ['GroupManaPct']   = {
            DisplayName = "Combat ModRod %",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 105,
            Tooltip = "Mana% to begin summoning Mod Rods in combat.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['GroupManaCt']    = {
            DisplayName = "Combat ModRod Count",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 106,
            Tooltip = "The number of party members (including yourself) that need to be under the above mana percentage.",
            Default = 3,
            Min = 1,
            Max = 6,
            ConfigType = "Advanced",
        },
        ['DoArcanumWeave'] = {
            DisplayName = "Weave Arcanums",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = "Weave Empowered/Enlighted/Acute Focus of Arcanum into your standard combat routine (Focus of Arcanum is saved for burns).",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = true,
        },

        --Damage (AE)
        ['DoAEDamage']     = {
            DisplayName = "Do AE Damage",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 101,
            Tooltip = "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" ..
                "This is a top-level setting that governs all AE damage, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },
        ['PBAETargetCnt']  = {
            DisplayName = "PBAE Tgt Cnt",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 105,
            Tooltip = "Minimum number of valid targets before using PBAE Spells.",
            Default = 4,
            Min = 1,
            Max = 10,
        },
        ['MaxAETargetCnt'] = {
            DisplayName = "Max AE Targets",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 106,
            Tooltip =
            "Maximum number of valid targets before using AE Spells, Disciplines or AA.\nUseful for setting up AE Mez at a higher threshold on another character in case you are overwhelmed.",
            Default = 6,
            Min = 2,
            Max = 30,
            FAQ = "How do I take advantage of the Max AE Targets setting?",
            Answer =
            "By limiting your max AE targets, you can set an AE Mez count that is slightly higher, to allow for the possiblity of mezzing if you are being overwhelmed.",
        },
        ['SafeAEDamage']   = {
            DisplayName = "AE Proximity Check",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 107,
            Tooltip = "Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives.",
            Default = false,
            FAQ = "Can you better explain the AE Proximity Check?",
            Answer = "If the option is enabled, the script will use various checks to determine if a non-hostile or not-aggroed NPC is present and avoid use of the AE action.\n" ..
                "Unfortunately, the script currently does not discern whether an NPC is (un)attackable, so at times this may lead to the action not being used when it is safe to do so.\n" ..
                "PLEASE NOTE THAT THIS OPTION HAS NOTHING TO DO WITH MEZ!",
        },
    },
    ['ClassFAQ']          = {
        [1] = {
            Question = "What is the current status of this class config?",
            Answer = "This class config is currently a Work-In-Progress that was originally based off of the Project Lazarus config.\n\n" ..
                "  Up until T1 progression, it should work quite well, but may need some clickies managed on the clickies tab.\n\n" ..
                "  After that, expect performance to degrade somewhat as not all THF custom spells or items are added, and some Laz-specific entries may remain.\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}

return _ClassConfig
