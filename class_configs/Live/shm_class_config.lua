local mq           = require('mq')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")
local Comms        = require("utils.comms")
local Logger       = require("utils.logger")

local _ClassConfig = {
    _version              = "2.1 - Live",
    _author               = "Algar, Derple",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return true end,
        IsRezing = function() return Config:GetSetting('DoBattleRez') or Targeting.GetXTHaterCount() == 0 end,
    },
    ['Modes']             = {
        'Heal',
        'Hybrid',
    },
    ['Cures']             = {
        CureNow = function(self, type, targetId)
            if Config:GetSetting('DoCureAA') then
                if Casting.AAReady("Radiant Cure") then
                    return Casting.UseAA("Radiant Cure", targetId)
                end
            end
            if Config:GetSetting('DoCureSpells') then
                local cureSpell
                --Ensure it is a type the spell can cure (we now check for more than just p/d/c), fallback to earlier spells if needed
                if type:lower() == "poison" then
                    cureSpell = Core.GetResolvedActionMapItem('CureSpell') or Core.GetResolvedActionMapItem('TLPCurePoison')
                elseif type:lower() == "disease" then
                    cureSpell = Core.GetResolvedActionMapItem('CureSpell') or Core.GetResolvedActionMapItem('TLPCureDisease')
                elseif type:lower() == "curse" then
                    cureSpell = Core.GetResolvedActionMapItem('CureSpell') or Core.GetResolvedActionMapItem('TLPRemoveCurse')
                end
                --todo: Add corruption cure

                if not cureSpell or not cureSpell() then return false end
                return Casting.UseSpell(cureSpell.RankName.Name(), targetId, true)
            end

            return false
        end,
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Crafted Talisman of Fates",
            "Blessed Spiritstaff of the Heyokah",
        },
    },
    ['AbilitySets']       = {
        ["GroupFocusSpell"] = {
            -- Focus Spell - Group Spells will be used on everyone
            "Khura's Focusing",           -- Level 60 - Group
            "Focus of the Seventh",       -- Level 65 - Group
            "Talisman of Wunshi",         -- Level 70 - Group
            "Talisman of the Dire",       -- Level 75 - Group
            "Talisman of the Bloodworg",  -- Level 80 - Group
            "Talisman of Unity",          -- Level 85 - Group
            "Talisman of Soul's Unity",   -- Level 90 - Group
            "Talisman of Kolos' Unity",   -- Level 95 - Group
            "Talisman of the Courageous", -- Level 100 - Group
            "Talisman of the Doomscale",  -- Level 105 - Group
            "Talisman of the Wulthan",    -- Level 110 - Group
            "Talisman of the Ry'Gorr",    -- Level 115 - Group
            "Talisman of the Usurper",    -- Level 120 - Group
            "Talisman of the Heroic",     -- Level 125 - Group
        },
        ["SingleFocusSpell"] = {
            -- Focus Spell - Single Spells will only be used on the Tank if they are better than the Group Version to cut incredibly long buff cycles.
            "Unity of the Doomscale", -- Level 101 - Single
            "Unity of the Wulthan",   -- Level 106 - Single
            "Unity of the Kromrif",   -- Level 111 - Single
            "Unity of the Vampyre",   -- Level 116 - Single
            "Celeritous Unity",       -- Level 121 - Single
        },
        ["RunSpeedBuff"] = {
            -- Run Speed Buff - 9 - 74
            "Spirit of Tala'Tak",
            "Spirit of Bih`Li",
            "Pack Shrew",
            "Spirit of Wolf",
        },
        ["HasteBuff"] = {
            -- Haste Buff - 26 - 64
            "Talisman of Celerity",
            "Swift Like the Wind",
            "Celerity",
            "Quickness",
        },
        ["TempHPBuff"] = {
            -- Growth Buff 111 -> 81
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
        ["LowLvlStaBuff"] = {
            -- Low Level Stamina Buff --- I guess this may be okay for tanks (but largely a raid thing). Need to scrub which levels. Not currently used.
            "Spirit of Bear",
            "Spirit of Ox",
            "Health",
            "Stamina",
            "Riotous Health",
            "Talisman of the Brute",
            "Endurance of the Boar",
            "Talisman of the Boar",
            "Spirit of Fortitude",
            "Talisman of Fortitude",
            "Talisman of Persistence",
            "Talisman of Vehemence",
            "Spirit of Vehemence",
        },
        ["LowLvlAtkBuff"] = {
            -- Low Level Attack Buff --- user under level 86. Including Harnessing of Spirit as they will have similar usecases and targets.
            "Harnessing of Spirit",
            "Primal Avatar",
            "Ferine Avatar",
            "Champion",
        },
        ["LowLvlHPBuff"] = {
            "Inner Fire",         -- Level 1 - Single
            "Talisman of Tnarg",  -- Level 32 - Single
            "Talisman of Altuna", -- Level 40 - Single
            "Talisman of Kragg",  -- Level 55 - Single
        },
        ["LowLvlStrBuff"] = {
            -- Low Level Strength Buff -- Below 68 these are only worthwhile on non-live, defiant stat caps too easily. Even then arguable.
            "Talisman of Might",  -- Level 70, Group
            "Spirit of Might",    -- Level 68, Single Target
            "Talisman of the Diaku",
            "Infusion of Spirit", -- Level 49, Str/Dex/Sta, can use HP buff
            "Tumultuous Strength",
            "Raging Strength",
            "Spirit Strength", -- Level 18, Can't see this as being very worth but keeping for now.
        },
        ["LowLvlDexBuff"] = {
            -- Low Level Dex Buff -- This has no real place outside of raids on select tanks. Waste of mana.
            "Talisman of the Raptor",
            "Mortal Deftness",
            "Dexterity",
            "Deftness",
            "Rising Dexterity",
            "Spirit of Monkey",
            "Dexterous Aura",
        },
        ["LowLvlAgiBuff"] = {
            --- Low Level AGI Buff -- This has no real place outside of raids on select tanks. Waste of mana.
            "Talisman of Foresight",
            "Preternatural Foresight",
            "Talisman of Sense",
            "Spirit of Sense",
            "Talisman of the Wrulan",
            "Agility of the Wrulan",
            "Talisman of the Cat",
            "Deliriously Nimble",
            "Agility",
            "Nimble",
            "Spirit of Cat",
            "Feet like Cat",
        },
        ["AEMaloSpell"] = {
            "Wind of Malisene",
            "Wind of Malis",
        },
        ["MaloSpell"] = {
            -- AA Starts at LVL 75
            "Malosinera",
            "Malosinetra",
            "Malosinise",
            "Malos",
            "Malosinia",
            "Malo",
            "Malosini",
            --Below this these spells are considered by many to be a waste of mana, but the user can elect to turn this off.
            "Malosi",
            "Malaisement",
            "Malaise",
        },
        ["AESlowSpell"] = { --Often considered a waste of mana in group situations, user option.
            "Tigir's Insects",
        },
        ["SlowSpell"] = {
            "Balance of Discord",
            "Balance of the Nihil",
            "Turgur's Insects", --Can save mana by continuing to use Togor's on group mobs, but this is problematic for automation. Not worth splitting the entry.
            "Togor's Insects",
            "Tagar's Insects",
            --"Walking Sleep", --Too much mana with little benefit at these levels
            --"Drowsy", --Too much mana with little benefit at these levels
        },
        ["DiseaseSlow"] = {
            "Cloud of Grummus",
            "Plague of Insects",
        },
        ["CrippleSpell"] = {   --not currently utilized for groups, gem slots are precious
            "Crippling Spasm", -- Level 66
            "Cripple",         -- Level 53, Starts to become worth it, depending on target
            "Incapacitate",    -- Level 41, Likely not worth
            "Listless Power",  -- Level 29, Definitely not worth
        },
        ["GroupHealProcBuff"] = {
            "Mindful Spirit",
            "Watchful Spirit",
            "Attentive Spirit",
            "Responsive Spirit",
        },
        ["WardBuff"] = {
            -- Self Heal Ward Spells
            "Ward of Heroic Deeds",
            "Ward of Recuperation",
            "Ward of Remediation",
            "Ward of Regeneration",
            "Ward of Rejuvenation",
            "Ward of Reconstruction",
            "Ward of Recovery",
            "Ward of Restoration",
            "Ward of Resurgence",
            "Ward of Rebirth",
        },
        ["DichoSpell"] = {
            "Reciprocal Roar",
            "Ecliptic Roar",
            "Composite Roar",
            "Dissident Roar",
            "Roar of the Lion",
        },
        ["MeleeProcBuff"] = {
            -- Melee Proc Buff - Level 50 - 111
            -- To be used when the Shaman does not have Dicho
            "Talisman of the Manul",
            "Talisman of the Kerran",
            "Talisman of the Lioness",
            "Talisman of the Sabretooth",
            "Talisman of the Leopard",
            "Talisman of the Snow Leopard",
            "Talisman of the Lion",
            "Talisman of the Tiger",
            "Talisman of the Lynx",
            "Talisman of the Cougar",
            "Talisman of the Panther",
            -- Below Level 71 This is a single target buff and will be keyed off of the MA
            "Spirit of the Panther",
            "Spirit of the Leopard",
            "Spirit of the Jaguar",
            "Spirit of the Puma",
        },
        ["SlowProcBuff"] = {
            -- Slow Proc Buff for MA - Level 68 - 122
            "Moroseness",
            "Melancholy",
            "Ennui",
            "Incapacity",
            "Sluggishness",
            "Fatigue",
            "Apathy",
            "Lethargy",
            "Listlessness",
            "Languor",
            "Lassitude",
            "Lingering Sloth",
        },
        ["PackSelfBuff"] = {
            -- Pack Self Buff - Level 90 - 115
            --- Ignoring the LVL 85 Call the Pack buff due to the decrease in mana per tick.
            "Pack of Ancestral Beasts",
            "Pack of Lunar Wolves",
            "Pack of The Black Fang",
            "Pack of Mirtuk",
            "Pack of Olesira",
            "Pack of Kriegas",
            "Pack of Hilnaah",
            "Pack of Wurt",
        },
        ["AllianceBuff"] = {
            "Ancient Alliance",
            "Ancient Coalition",
            "Ancient Covariance",
        },
        ['RezSpell'] = {
            'Incarnate Anew', -- Level 59
        },
        ["RecklessHeal1"] = {
            "Reckless Reinvigoration",
            "Reckless Resurgence",
            "Reckless Renewal",
            "Reckless Rejuvenation",
            "Reckless Regeneration",
            "Reckless Restoration",
            "Reckless Remedy",
            "Reckless Mending",
            "Qirik's Mending",
            "Dannal's Mending",
            "Gemmi's Mending",
            "Ahnkaul's Mending",
            "Ancient: Wilslik's Mending",
            "Yoppa's Mending",
            "Daluda's Mending",
            "Tnarg's Mending",
            "Chloroblast",
            "Kragg's Salve",
            "Superior Healing",
            "Spirit Salve",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
        },
        ["RecklessHeal2"] = {
            --worthless to mem two mendings because they don't have a recast time, keep Qirik's for when we don't have enough Reckless.
            "Reckless Reinvigoration",
            "Reckless Resurgence",
            "Reckless Renewal",
            "Reckless Rejuvenation",
            "Reckless Regeneration",
            "Reckless Restoration",
            "Reckless Remedy",
            "Reckless Mending",
            "Qirik's Mending",
        },
        ["RecklessHeal3"] = {
            --fallback just in case we have some other DPS stuff disabled, but 3 reckless is overkill for automation
            "Reckless Reinvigoration",
            "Reckless Resurgence",
            "Reckless Renewal",
            "Reckless Rejuvenation",
            "Reckless Regeneration",
            "Reckless Restoration",
            "Reckless Remedy",
            "Reckless Mending",
            "Qirik's Mending",
        },
        ["AESpiritualHeal"] = {
            -- Pulsing AE Heal, 100+
            "Spiritual Shower",
            "Spiritual Squall",
            "Spiritual Swell",
            "Spiritual Surge",
        },
        ["RecourseHeal"] = {
            --- RecourseHeal Level 87+
            "Grayleaf's Recourse",
            "Rowain's Recourse",
            "Zrelik's Recourse",
            "Eyrzekla's Recourse",
            "Krasir's Recourse",
            "Blezon's Recourse",
            "Gotikan's Recourse",
            "Qirik's Recourse",
        },
        ["InterventionHeal"] = {
            -- Intervention Heal 78+
            "Immortal Intervention",
            "Primordial Intervention",
            "Prehistoric Intervention",
            "Historian's Intervention",
            "Antecessor's Intervention",
            "Progenitor's Intervention",
            "Ascendant's Intervention",
            "Antecedent's Intervention",
            "Ancestral Intervention",
            "Antediluvian Intervention",
        },
        ["GroupRenewalHoT"] = {
            -- Prior to 70 Breath of Trushar, single HoTs will be used including the
            --- the Torpor/Stoicism line. LVL 44 is the lowest level.
            "Reverie of Renewal",
            "Spirit of Renewal",
            "Spectre of Renewal",
            "Cloud of Renewal",
            "Shear of Renewal",
            "Wisp of Renewal",
            "Phantom of Renewal",
            "Penumbra of Renewal",
            "Shadow of Renewal",
            "Shade of Renewal",
            "Specter of Renewal",
            "Ghost of Renewal",
            "Spiritual Serenity",
            "Breath of Trushar",
            "Quiescence",
            "Torpor",
            "Stoicism",
        },
        ["CanniSpell"] = {
            -- Convert Health to Mana - Level  23 - 113
            "Hoary Agreement",
            "Ancient Bargain",
            "Tribal Bargain",
            "Tribal Pact",
            "Ancestral Pact",
            "Ancestral Arrangement",
            "Ancestral Covenant",
            "Ancestral Obligation",
            "Ancestral Hearkening",
            "Ancestral Bargain",
            "Ancient: Ancestral Calling",
            "Pained Memory",
            "Ancient: Chaotic Pain",
            "Cannibalize IV",
            "Cannibalize III",
            "Cannibalize II",
            "Cannibalize",
        },
        ["CureSpell"] = {
            "Blood of Mayong",
            "Blood of Tevik",
            "Blood of Rivans",
            "Blood of Sanera",
            "Blood of Klar",
            "Blood of Corbeth",
            "Blood of Avoling",
            "Blood of Nadox",
        },
        ["TwinHealNuke"] = {
            -- Nuke the MA Not the assist target - Levels 85+
            "Gelid Gift",
            "Polar Gift",
            "Wintry Gift",
            "Frostbitten Gift",
            "Glacial Gift",
            "Frigid Gift",
            "Freezing Gift",
            "Frozen Gift",
            "Frost Gift",
        },
        ["PoisonNuke"] = {
            -- Poison Nuke LVL34 +
            "Red Eye's Spear of Venom",
            "Fleshrot's Spear of Venom",
            "Narandi's Spear of Venom",
            "Nexona's Spear of Venom",
            "Serisaria's Spear of Venom",
            "Slaunk's Spear of Venom",
            "Hiqork's Spear of Venom",
            "Spinechiller's Spear of Venom",
            "Severilous' Spear of Venom",
            "Vestax's Spear of Venom",
            "Ahnkaul's Spear of Venom",
            "Yoppa's Spear of Venom",
            "Spear of Torment",
            "Blast of Venom",
            "Shock of Venom",
            "Blast of Poison",
            "Shock of the Tainted",
        },
        ["FastPoisonNuke"] = {
            -- Fast Poison Nuke LVL73+
            "Oka's Bite",
            "Ander's Bite",
            "Direfang's Bite",
            "Mawmun's Bite",
            "Reefmaw's Bite",
            "Seedspitter's Bite",
            "Bite of the Grendlaen",
            "Bite of the Blightwolf",
            "Bite of the Ukun",
            "Bite of the Brownie",
            "Sting of the Queen",
        },
        ["IceNuke"] = {
            --- IceNuke - Level 4+
            "Ice Barrage",
            "Heavy Sleet",
            "Ice Salvo",
            "Ice Shards",
            "Ice Squall",
            "Ice Burst",
            "Ice Mass",
            "Ice Floe",
            "Ice Sheet",
            "Tundra Crumble",
            "Glacial Avalanche",
            "Ice Age",
            "Velium Strike",
            "Ice Strike",
            "Blizzard Blast",
            "Winter's Roar",
            "Frost Strike",
            "Spirit Strike",
            "Frost Rift",
        },
        ["ChaoticDot"] = {
            -- Long Dot(42s) LVL 104+
            -- Two resist types because it throws 2 dots
            -- Stacking: Nectar of Pain - Stacking: Blood of Saryrn
            "Chaotic Bloodcurse",
            "Chaotic Poison",
            "Chaotic Venom",
            "Chaotic Venin",
            "Chaotic Toxin",
        },
        ["PandemicDot"] = {
            -- Pandemic Dot Long Dot(84s) Level 103+
            -- Two resist types because it throws 2 dots
            -- Stacking: Kralbor's Pandemic  -    Stacking: Breath of Ultor
            "Hotarion Pandemic",
            "Tegi Pandemic",
            "Bledrek's Pandemic",
            "Elkikatar's Pandemic",
            "Hemocoraxius' Pandemic",
        },
        ["MaloDot"] = {
            -- Malo Dot Stacking: Yubai's Affliction - LongDot(96s) Level 99+
            "Svartmane's Malosinara",
            "Rirwech's Malosinata",
            "Livio's Malosenia",
            "Falhotep's Malosenia",
            "Txiki's Malosinara",
            "Krizad's Malosinera",
        },
        ["CurseDot1"] = {
            -- Curse Dot 1 Stacking: Curse - Long Dot(30s) - Level 34+
            "Malediction",
            "Obeah",
            "Evil Eye",
            "Jinx",
            "Garugaru",
            "Naganaga",
            "Hoodoo",
            "Hex",
            "Mojo",
            "Pocus",
            "Juju",
            "Curse of Sisslak",
            "Bane",
            "Anathema",
            "Odium",
            "Curse",
        },
        ["CurseDot2"] = {
            ---, Stacking: Enalam's Curse - Long Dot(54s) - 100+
            "Lenrel's Curse",
            "Marlek's Curse",
            "Erogo's Curse",
            "Sraskus' Curse",
            "Enalam's Curse",
            "Fandrel's Curse",
        },
        ["SaryrnDot"] = {
            -- Stacking: Blood of Saryrn - Long Dot(42s) - Level 8+
            "Caustic Blood",
            "Desperate Vampyre Blood",
            "Restless Blood",
            "Reef Crawler Blood",
            "Phase Spider Blood",
            "Naeya Blood",
            "Spinechiller Blood",
            "Blood of Jaled'Dar",
            "Blood of Kerafyrm",
            "Vengeance of Ahnkaul",
            "Blood of Yoppa",
            "Blood of Saryrn",
            "Ancient: Scourge of Nife",
            "Bane of Nife",
            "Envenomed Bolt",
            "Venom of the Snake",
            "Envenomed Breath",
            "Tainted Breath",
        },
        ["UltorDot"] = {
            ---, Stacking: Breath of Ultor - Long Dot(84s) - Level 4+
            "Breath of the Hotariton",
            "Breath of the Tegi",
            "Breath of Bledrek",
            "Breath of Hemocoraxius",
            "Breath of Natigo",
            "Breath of Silbar",
            "Breath of the Shiverback",
            "Breath of Queen Malarian",
            "Breath of Big Bynn",
            "Breath of Ternsmochin",
            "Breath of Wunshi",
            "Breath of Ultor",
            "Pox of Bertoxxulous",
            "Plague",
            "Scourge",
            "Affliction",
            "Sicken",
        },
        ["AfflictionDot"] = {
            ---, Stacking: Yubai's Affliction - Long Dot(96s) - Level 9+, used on named only for hybrid
            "Krizad's Affliction",
            "Brightfeld's Affliction",
            "Svartmane's Affliction",
            "Rirwech's Affliction",
            "Livio's Affliction",
            "Falhotep's Affliction",
            "Yubai's Affliction",
        },
        ["NectarDot"] = { --almost never worth casting in a group, not currently gemmed.
            --- Nectar Dot Line
            "Nectar of Obscurity",
            "Nectar of Pain",
            "Nectar of Agony",
            "Nectar of Rancor",
            "Nectar of the Slitheren",
            "Nectar of Torment",
            "Nectar of Sholoth",
            "Nectar of Anguish",
            "Nectar of Woe",
            "Nectar of Suffering",
            "Nectar of Misery",
            "Nectar of Destitution",
        },
        ["PetSpell"] = {
            -- Pet Spell - 32+
            "Suja's Faithful",
            "Diabo Sivuela's Faithful",
            "Grondo's Faithful",
            "Mirtuk's Faithful",
            "Olesira's Faithful",
            "Kriegas' Faithful",
            "Hilnaah's Faithful",
            "Wurt's Faithful",
            "Aina's Faithful",
            "Vegu's Faithful",
            "Kyrah's Faithful",
            "Farrel's Companion",
            "True Spirit",
            "Spirit of the Howler",
            "Frenzied Spirit",
            "Guardian spirit",
            "Vigilant Spirit",
            "Companion Spirit",
        },
        ["PetBuffSpell"] = {
            ---Pet Buff Spell - 50+
            "Spirit Augmentation",
            "Spirit Reinforcement",
            "Spirit Bracing",
            "Spirit Bolstering",
            "Spirit Quickening",
        },
        ["TLPCureDisease"] = {
            "Cure Disease",
            "Counteract Disease",
            "Eradicate Disease",
        },
        ["TLPCurePoison"] = {
            "Counteract Poison",
            "Abolish Poison",
            "Eradicate Poison",
        },
        ["TLPRemoveCurse"] = {
            -- "Eradicate Curse",      -- Level 54 , 30 counters, twice, 400 mana
            "Remove Greater Curse", -- Level 54 , 9 counters, 5 times, 100 mana
            "Remove Curse",         -- Level 38
            "Remove Lesser Curse",  -- Level 24
            "Remove Minor Curse",   -- Level 9
        },
        ["GroupRegenBuff"] = {      --Does not stack with Dicho Regen
            "Talisman of the Unforgettable",
            "Talisman of the Tenacious",
            "Talisman of the Enduring",
            "Talisman of the Unwavering",
            "Talisman of the Faithful",
            "Talisman of the Steadfast",
            "Talisman of the Indomitable",
            "Talisman of the Reletntless",
            "Talisman of the Resolute",
            "Talisman of the Stalwart",
            "Talisman of the Stoic One",
            "Talisman of Perseverance",
            "Regrowth of Dar Khura", -- Level 56
        },
        ["SingleRegenBuff"] = {
            "Regrowth",
            "Chloroplast",
            "Regeneration", -- Level 22
        },
        ["ShrinkSpell"] = {
            "Shrink",
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
    -- These are handled differently from normal rotations in that we try to make some intelligent desicions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        {
            name = 'LowLevelHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 65 end,
            cond = function(self, target)
                return Targeting.MainHealsNeeded(target)
            end,
        },
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 64 end,
            cond = function(self, target) return Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'BigHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 64 end,
            cond = function(self, target) return Targeting.BigHealsNeeded(target) end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 64 end,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ["LowLevelHealPoint"] = {
            {
                name = "Call of the Ancients",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.BigHealsNeeded(target)
                end,
            },
            {
                name = "RecklessHeal1",
                type = "Spell",
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHealOverTime') or not Targeting.GroupedWithTarget(target) or not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ["GroupHealPoint"] = {
            {
                name = "InterventionHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.BigHealsNeeded(target) -- if multiples hurt with at least one in big heal range
                end,
            },
            {
                name = "Soothsayer's Intervention",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.BigGroupHealsNeeded() -- if multiples hurt with multiples in big heal range
                end,
            },
            {
                name = "RecourseHeal",
                type = "Spell",
            },
            {
                name = "AESpiritualHeal",
                type = "Spell",
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
                name = "Call of the Ancients",
                type = "AA",
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHealOverTime') or not Targeting.GroupedWithTarget(target) or not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ["BigHealPoint"] = {
            {
                name = "Ancestral Guard",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "InterventionHeal",
                type = "Spell",
            },
            {
                name = "Soothsayer's Intervention",
                type = "AA",
            },
            {
                name = "Union of Spirits",
                type = "AA",
            },
            { --The stuff above is down, lets make mainhealpoint chonkier.
                name = "Spiritual Blessing",
                type = "AA",
            },
            {
                name = "Apothic Dragon Spine Hammer",
                type = "Item",
            },
            { --if we hit this we need intervention back ASAP
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ["MainHealPoint"] = {
            {
                name = "RecourseHeal",
                type = "Spell",
            },
            {
                name = "AESpiritualHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsMA(target)
                end,
            },
            {
                name = "RecklessHeal1",
                type = "Spell",
            },
            {
                name = "RecklessHeal2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SpellLoaded(spell)
                end,
            },
            {
                name = "RecklessHeal3",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SpellLoaded(spell)
                end,
            },
            {
                name = "Apothic Dragon Spine Hammer",
                type = "Item",
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.OkayToBuff() and
                    Casting.AmIBuffable()
            end,
        },
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and
                    Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 60,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        { --Downtime buffs that don't need constant checks
            name = 'SlowDowntime',
            timer = 30,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Spells that should be checked on group members
            name = 'GroupBuff',
            timer = 60,
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal()) and Casting.OkayToBuff()
            end,
        },
        {
            name = 'Malo',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSTMalo') or Config:GetSetting('DoAEMalo') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff() and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'Slow',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSTSlow') or Config:GetSetting('DoAESlow') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Casting.HaveManaToDebuff() and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and
                    (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'CombatBuff',
            timer = 10,
            state = 1,
            steps = 1,
            load_cond = function(self) return self:GetResolvedActionMapItem('MeleeProcBuff') end,
            targetId = function(self) return { Core.GetMainAssistId(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },
        {
            name = 'TwinHeal',
            state = 1,
            steps = 1,
            load_cond = function(self) return Config:GetSetting('DoTwinHeal') and self:GetResolvedActionMapItem('TwinHealNuke') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and (not Core.IsModeActive('Heal') or Core.OkayToNotHeal())
            end,
        },

    },
    ['Rotations']         = {
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
        ['CombatBuff'] = {
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "MeleeProcBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if Core.GetResolvedActionMapItem('DichoSpell') or not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Fleeting Spirit",
                type = "AA",
            },
            {
                name = "Ancestral Aid",
                type = "AA",
            },
            {
                name = "Spire of Ancestors",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target)
                end,
            },
            {
                name = "Spirit Call",
                type = "AA",
            },
            {
                name = "Rabid Bear",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoVetAA')
                end,
            },
        },
        ['Malo'] = {
            {
                name = "Wind of Malaise",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoAEMalo') then return false end
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AEMaloCount') and Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "AEMaloSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAEMalo') or Casting.CanUseAA("Wind of Malaise") then return false end
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AEMaloCount') and Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "Malaise",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoSTMalo') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "MaloSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSTMalo') or Casting.CanUseAA("Malaise") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Slow'] = {
            {
                name = "Turgur's Virulent Swarm",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoAESlow') then return false end
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AESlowCount') and Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "AESlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAESlow') or Casting.CanUseAA("Turgur's Virulent Swarm") then return false end
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AESlowCount') and Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "Turgur's Swarm",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoSTSlow') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSTSlow') or Casting.CanUseAA("Turgur's Swarm") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "DieaseSlow",
                type = "Spell",
                cond = function(self, spell, target)
                    if not (Config:GetSetting('DoDiseaseSlow') and Config:GetSetting('DoSTSlow')) or Casting.CanUseAA("Turgur's Swarm") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if Config:GetSetting('UseEpic') == 1 then return false end
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "ChaoticDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "CurseDot2",
                type = "Spell",
                cond = function(self, spell, target)
                    if Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "PandemicDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "CurseDot1",
                type = "Spell",
                cond = function(self, spell, target)
                    if (Core.IsModeActive("Heal") and (Core.GetResolvedActionMapItem('CurseDot2') or not Config:GetSetting('DoHealDPS'))) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "SaryrnDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if (Core.IsModeActive("Heal") and (Core.GetResolvedActionMapItem('ChaoticDot') or not Config:GetSetting('DoHealDPS'))) then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "AfflictionDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Core.IsModeActive("Hybrid") then return false end
                    return Targeting.IsNamed(target) and Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "UltorDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Core.IsModeActive("Hybrid") or Core.GetResolvedActionMapItem('AfflictionDot') then return false end
                    return Targeting.IsNamed(target) and Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "Cannibalization",
                type = "AA",
                allowDead = true,
                cond = function(self, aaName)
                    if not (Config:GetSetting('DoAACanni') and Config:GetSetting('DoCombatCanni')) then return false end
                    return mq.TLO.Me.PctMana() < Config:GetSetting('AACanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('AACanniMinHP')
                end,
            },
            {
                name = "CanniSpell",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell)
                    if not Casting.CastReady(spell) or not (Config:GetSetting('DoSpellCanni') and Config:GetSetting('DoCombatCanni')) then return false end
                    return mq.TLO.Me.PctMana() < Config:GetSetting('SpellCanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('SpellCanniMinHP')
                end,
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    if not Casting.CanUseAA("Luminary's Synergy") or not Config:GetSetting('DoHealOverTime') or not Casting.CastReady(spell) then return false end
                    return Targeting.MobHasLowHP and spell.RankName.Stacks() and (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "FastPoisonNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "PoisonNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if Core.IsModeActive("Heal") and Core.GetResolvedActionMapItem('FastPoisonNuke') then return false end
                    return Targeting.MobHasLowHP and Casting.HaveManaToNuke()
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if Core.GetResolvedActionMapItem('PoisonNuke') then return false end
                    return Targeting.MobHasLowHP and Casting.HaveManaToNuke()
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 end,
                cond = function(self, _) return Config:GetSetting('DoPet') and mq.TLO.Me.Pet.ID() == 0 end,
                post_activate = function(self, spell)
                    local pet = mq.TLO.Me.Pet
                    if pet.ID() > 0 then
                        Comms.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(),
                            pet.Class.Name(), pet.CleanName(), spell.RankName())
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "Cannibalization",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoAACanni') and mq.TLO.Me.PctMana() < Config:GetSetting('AACanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('AACanniMinHP')
                end,
            },
            {
                name = "CanniSpell",
                type = "Spell",
                cond = function(self, spell)
                    if not Config:GetSetting('DoSpellCanni') or not Casting.CastReady(spell) then return false end
                    return mq.TLO.Me.PctMana() < Config:GetSetting('SpellCanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('SpellCanniMinHP')
                end,
            },
            {
                name = "GroupHealProcBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                cond = function(self, spell)
                    if not Casting.CanUseAA("Luminary's Synergy") or not Config:GetSetting('DoHealOverTime') or not Casting.CastReady(spell) then return false end
                    return spell.RankName.Stacks() and (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "Preincarnation",
                type = "AA",
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName)
                        .Spell.Trigger(1).ID())
                end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetBuffSpell",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },
            {
                name = "Companion's Aegis",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
        },
        ['SlowDowntime'] = {
            {
                name = "Pact of the Wolf",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.Me.Aura(aaName)() ~= nil end,
                cond = function(self, aaName)
                    return Config:GetSetting('DoAura') and not Casting.IHaveBuff(aaName) and
                        mq.TLO.Me.Aura(aaName)() == nil
                end,
            },
            {
                name = "Visionary's Unity",
                type = "AA",
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName)
                        .Spell.Trigger(1).ID())
                end,
                cond = function(self, aaName) --Check ranks because we don't want the first pack buff (drains mana)
                    if (mq.TLO.Me.AltAbility(aaName).Rank() or 999) < 2 then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "PackSelfBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if (mq.TLO.Me.AltAbility("Visionary's Unity").Rank() or 999) > 1 then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "WardBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Config:GetSetting('DoSelfWard') then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Spirit Guardian",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.TargetIsMA(target) then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
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
                name = "SlowProcBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            { --Used on the entire group
                name = "GroupFocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            { --If our single target is better than the group spell above, we will use it on the Tank
                name = "SingleFocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            { --Only cast below 86 because past that our focus spells take over
                name = "LowLvlAtkBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return mq.TLO.Me.Level() < 86 and Targeting.TargetIsAMelee(target) and Casting.CastReady(spell) and
                        Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Talisman of Celerity",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.Me.Haste() end,
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoHaste') then return false end
                    return mq.TLO.Me.Level() < 111 and Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "HasteBuff",
                type = "Spell",
                active_cond = function(self, aaName) return mq.TLO.Me.Haste() end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHaste') or Casting.CanUseAA("Talisman of Celerity") then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SingleRegenBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if Core.GetResolvedActionMapItem('GroupRegenBuff') then return false end --We don't need this once we can use the group version
                    return (Targeting.TargetIsATank(target) or Targeting.TargetIsMyself(target)) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupRegenBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if Core.GetResolvedActionMapItem('DichoSpell') or not Config:GetSetting('DoGroupRegen') then return false end --Dicho regen overwrites this
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Lupine Spirit",
                type = "AA",
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())
                end,
                cond = function(self, aaName, target) --check ranks because this won't use Tala'Tak between 74 and 90
                    if not Config:GetSetting('DoRunSpeed') or (mq.TLO.Me.AltAbility(aaName).Rank() or 0) < 4 then return false end

                    local speedSpell = mq.TLO.Me.AltAbility(aaName).Spell
                    if not speedSpell or not speedSpell() then return false end

                    return Casting.GroupBuffCheck(speedSpell, target)
                end,
            },
            {
                name = "RunSpeedBuff",
                type = "Spell",
                cond = function(self, spell, target) --We get Tala'tak at 74, but don't get the AA version until 90
                    if not Config:GetSetting('DoRunSpeed') or (mq.TLO.Me.AltAbility("Lupine Spirit").Rank() or -1) > 3 then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            { --Shrink AA, will use first(best) available
                name_func = function(self)
                    return Casting.GetFirstAA({ "Group Shrink", "Shrink", })
                end,
                type = "AA",
                active_cond = function(self) return mq.TLO.Me.Height() < 2 end,
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoGroupShrink') then return false end
                    return target.Height() > 2.2
                end,
            },
            {
                name = "ShrinkSpell",
                type = "Spell",
                active_cond = function(self) return mq.TLO.Me.Height() < 2 end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupShrink') or Casting.CanUseAA("Group Shrink") or Casting.CanUseAA("Shrink") then return false end
                    return target.Height() > 2.2
                end,
            },
            {
                name = "LowLvlHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLHPBuff') then return false end
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "LowLvlAgiBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLAgiBuff') then return false end
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "LowLvlStaBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLStaBuff') then return false end
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "LowLvlStrBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoLLStrBuff') then return false end
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsAMelee(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "RecklessHeal1", }, -- 1-125
            },
        },
        {
            gem = 2,
            spells = {
                { name = "RecourseHeal", }, -- 87-125
                {
                    name = "AESlowSpell",
                    cond = function(self)
                        return not Casting.CanUseAA("Turgur's Virulent Swarm") and Config:GetSetting('DoAESlow')
                    end,
                }, -- 58-79
                {
                    name = "CanniSpell",
                    cond = function(self)
                        return Config:GetSetting('DoSpellCanni')
                    end,
                }, -- 23 - ???
            },
        },
        {
            gem = 3,
            spells = {
                { name = "InterventionHeal", }, -- 78-125
                {
                    name = "DiseaseSlow",
                    cond = function(self)
                        return not Casting.CanUseAA("Turgur's Swarm") and Config:GetSetting('DoSTSlow')
                            and Config:GetSetting('DoDiseaseSlow')
                    end,
                }, -- 54-77
                {
                    name = "SlowSpell",
                    cond = function(self)
                        return not Casting.CanUseAA("Turgur's Swarm") and Config:GetSetting('DoSTSlow')
                    end,
                }, -- 27-77
            },
        },
        {
            gem = 4,
            spells = {
                { name = "AESpiritualHeal", }, -- 100-125
                {
                    name = "AEMaloSpell",
                    cond = function(self)
                        return not Casting.CanUseAA("Wind of Malaise")
                            and Config:GetSetting('DoAEMalo')
                    end,
                }, -- 84-94
                {
                    name = "MaloSpell",
                    cond = function(self)
                        return not Casting.CanUseAA("Malaise") and Config:GetSetting('DoSTMalo')
                    end,
                }, -- 47-74
            },
        },
        {
            gem = 5,
            spells = {
                { name = "RecklessHeal2",  cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 90-125
                { name = "FastPoisonNuke", cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 73-125
                {
                    name = "PoisonNuke",
                    cond = function(self)
                        return mq.TLO.Me.Level() > 33 and mq.TLO.Me.Level() < 73 and not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS'))
                    end,
                }, -- 34-72
                {
                    name = "IceNuke",
                    cond = function(self)
                        return mq.TLO.Me.Level() < 34 and not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS'))
                    end,
                }, -- 4-33
            },
        },
        {
            gem = 6,
            spells = {
                { name = "DichoSpell", },                                                                                                             -- 101-125
                { name = "MeleeProcBuff", },                                                                                                          -- 50-101
                { name = "CurseDot1",     cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 34-??? Heal, 34-125 Hybrid
                { name = "SaryrnDot",     cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 8-?? Heal, 8-125 Hybrid
                { name = "UltorDot",      cond = function(self) return Core.IsModeActive("Hybrid") and mq.TLO.Me.Level() < 92 end, },                 -- 4-91 Hybrid (Boss Only)

            },
        },
        {
            gem = 7,
            spells = {
                { name = "GroupRenewalHoT", cond = function(self) return Core.IsModeActive("Heal") and Config:GetSetting('DoHealOverTime') end, },      -- 44-125 Heal
                { name = "SingleRegenBuff", cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 22-55 Convenience
                { name = "AfflictionDot",   cond = function(self) return Core.IsModeActive("Hybrid") end, },                                            -- 92-125 Hybrid (Boss Only)
                { name = "UltorDot",        cond = function(self) return Core.IsModeActive("Hybrid") and mq.TLO.Me.Level() < 92 end, },                 -- 4-91 Hybrid (Boss Only)
                { name = "FastPoisonNuke",  cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 73-125
                { name = "CurseDot1",       cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 34-??? Heal, 34-125 Hybrid
                { name = "SaryrnDot",       cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 8-?? Heal, 8-125 Hybrid
            },
        },
        { --We will leave this gem open for buffing until we have 9
            gem = 8,
            cond = function(self) return mq.TLO.Me.NumGems() >= 9 end,
            spells = {
                --Harnessing of Spirit won't be full-time memmed, but will still be used as needed.
                { name = "LowLvlAtkBuff",     cond = function(self) return mq.TLO.Me.Level() < 86 end, },                                                 -- 60-85
                { name = "TwinHealNuke",      cond = function(self) return Core.IsModeActive("Heal") and Config:GetSetting('DoTwinHeal') end, },          -- 85-125
                { name = "FastPoisonNuke",    cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 73-125
                { name = "TempHPBuff",        cond = function(self) return Config:GetSetting('DoTempHP') end, },                                          -- 81-125
                { name = "CureSpell",         cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 52-125 Heal
                { name = "CurseDot1",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 34-??? Heal, 34-125 Hybrid
                { name = "SaryrnDot",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 8-?? Heal, 8-125 Hybrid
                { name = "AfflictionDot",     cond = function(self) return Core.IsModeActive("Hybrid") end, },                                            -- 92-125 Hybrid (Boss Only)
                { name = "UltorDot",          cond = function(self) return Core.IsModeActive("Hybrid") and mq.TLO.Me.Level() < 92 end, },                 -- 4-91 Hybrid (Boss Only)
                { name = "GroupHealProcBuff", cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 101-125,
                { name = "RecklessHeal3",     cond = function(self) return Core.IsModeActive("Heal") end, },
                { name = "SlowProcBuff", },
            },
        },
        { --55, we will leave this gem open for buffing until we have 10
            gem = 9,
            cond = function(self) return mq.TLO.Me.NumGems() >= 10 end,
            spells = {
                { name = "FastPoisonNuke",    cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 73-125
                { name = "TwinHealNuke",      cond = function(self) return Core.IsModeActive("Heal") and Config:GetSetting('DoTwinHeal') end, },          -- 85-125
                { name = "TempHPBuff",        cond = function(self) return Config:GetSetting('DoTempHP') end, },                                          -- 81-125
                { name = "CureSpell",         cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 52-125 Heal
                { name = "CurseDot1",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 34-??? Heal, 34-125 Hybrid
                { name = "SaryrnDot",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 8-?? Heal, 8-125 Hybrid
                { name = "AfflictionDot",     cond = function(self) return Core.IsModeActive("Hybrid") end, },                                            -- 92-125 Hybrid (Boss Only)
                { name = "UltorDot",          cond = function(self) return Core.IsModeActive("Hybrid") and mq.TLO.Me.Level() < 92 end, },                 -- 4-91 Hybrid (Boss Only)
                { name = "GroupHealProcBuff", cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 101-125,
                { name = "RecklessHeal3",     cond = function(self) return Core.IsModeActive("Heal") end, },
                { name = "SlowProcBuff", },
            },
        },
        { --75, we will leave this gem open for buffing until we have 11
            gem = 10,
            cond = function(self) return mq.TLO.Me.NumGems() >= 11 end,
            spells = {
                { name = "CurseDot2",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 100-125
                { name = "TwinHealNuke",      cond = function(self) return Core.IsModeActive("Heal") and Config:GetSetting('DoTwinHeal') end, },          -- 85-125
                { name = "FastPoisonNuke",    cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 73-125
                { name = "TempHPBuff",        cond = function(self) return Config:GetSetting('DoTempHP') end, },                                          -- 81-125
                { name = "CureSpell",         cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 52-125 Heal
                { name = "CurseDot1",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 34-??? Heal, 34-125 Hybrid
                { name = "SaryrnDot",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 8-?? Heal, 8-125 Hybrid
                { name = "AfflictionDot",     cond = function(self) return Core.IsModeActive("Hybrid") end, },                                            -- 92-125 Hybrid (Boss Only)
                { name = "UltorDot",          cond = function(self) return Core.IsModeActive("Hybrid") and mq.TLO.Me.Level() < 92 end, },                 -- 4-91 Hybrid (Boss Only)
                { name = "GroupHealProcBuff", cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 101-125,
                { name = "RecklessHeal3",     cond = function(self) return Core.IsModeActive("Heal") end, },
                { name = "SlowProcBuff", },
            },
        },
        { --80, we will leave this gem open for buffing until we have 12
            gem = 11,
            cond = function(self) return mq.TLO.Me.NumGems() >= 12 end,
            spells = {
                { name = "PandemicDot",       cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 103-125
                { name = "TwinHealNuke",      cond = function(self) return Core.IsModeActive("Heal") and Config:GetSetting('DoTwinHeal') end, },          -- 85-125
                { name = "FastPoisonNuke",    cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 73-125
                { name = "TempHPBuff",        cond = function(self) return Config:GetSetting('DoTempHP') end, },                                          -- 81-125
                { name = "CureSpell",         cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 52-125 Heal
                { name = "CurseDot1",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 34-??? Heal, 34-125 Hybrid
                { name = "SaryrnDot",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 8-?? Heal, 8-125 Hybrid
                { name = "AfflictionDot",     cond = function(self) return Core.IsModeActive("Hybrid") end, },                                            -- 92-125 Hybrid (Boss Only)
                { name = "UltorDot",          cond = function(self) return Core.IsModeActive("Hybrid") and mq.TLO.Me.Level() < 92 end, },                 -- 4-91 Hybrid (Boss Only)
                { name = "GroupHealProcBuff", cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 101-125,
                { name = "RecklessHeal3",     cond = function(self) return Core.IsModeActive("Heal") end, },
                { name = "SlowProcBuff", },
            },
        },
        { --80, we will allow this gem to be filled for the convenience of buffing at the risk of having it overwritten due to a pause, etc.
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ChaoticDot",        cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 104-125
                { name = "TwinHealNuke",      cond = function(self) return Core.IsModeActive("Heal") and Config:GetSetting('DoTwinHeal') end, },          -- 85-125
                { name = "FastPoisonNuke",    cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 73-125
                { name = "TempHPBuff",        cond = function(self) return Config:GetSetting('DoTempHP') end, },                                          -- 81-125
                { name = "CureSpell",         cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 52-125 Heal
                { name = "CurseDot1",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 34-??? Heal, 34-125 Hybrid
                { name = "SaryrnDot",         cond = function(self) return not (Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS')) end, }, -- 8-?? Heal, 8-125 Hybrid
                { name = "AfflictionDot",     cond = function(self) return Core.IsModeActive("Hybrid") end, },                                            -- 92-125 Hybrid (Boss Only)
                { name = "UltorDot",          cond = function(self) return Core.IsModeActive("Hybrid") and mq.TLO.Me.Level() < 92 end, },                 -- 4-91 Hybrid (Boss Only)
                { name = "GroupHealProcBuff", cond = function(self) return Core.IsModeActive("Heal") end, },                                              -- 101-125,
                { name = "RecklessHeal3",     cond = function(self) return Core.IsModeActive("Heal") end, },
                { name = "SlowProcBuff", },
            },
        },
        { --105, we will allow this gem to be filled for the convenience of buffing (or an extra nuke) at the risk of having it overwritten due to a pause, etc.
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TempHPBuff",        cond = function(self) return Config:GetSetting('DoTempHP') end, }, -- 81-125
                { name = "CureSpell",         cond = function(self) return Core.IsModeActive("Heal") end, },     -- 52-125 Heal
                { name = "GroupHealProcBuff", cond = function(self) return Core.IsModeActive("Heal") end, },     -- 101-125
                { name = "PoisonNuke",        cond = function(self) return Core.IsModeActive("Hybrid") end, },   -- Hey, why not?
                { name = "SlowProcBuff", },                                                                      --fallback

            },
        },
    },
    ['PullAbilities']     = {
        {
            id = 'SlowSpell',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('SlowSpell')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('SlowSpell')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('SlowSpell')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'DDSpell',
            Type = "Spell",
            DisplayName = "Burst of Flame",
            AbilityName = "Burst of Flame",
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = mq.TLO.Spell("Burst of Flame")
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = {
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes do?",
            Answer =
            "Heal Mode: Primarily focuses on healing, cures, and maintaining HoTs. Secondary DPS focus with remaining spell gems. Hybrid: Prioritizes slightly more DPS at the expense of keeping a HoT, Cure Spell and second Reckless heal memorized.",
        },
        ['DoTwinHeal']        = {
            DisplayName = "Twin Heal Nuke",
            Category = "Heal Mode",
            Index = 3,
            Tooltip = "Heal Mode: Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I using the Twin Heal Nuke?",
            Answer =
            "Due to the nature of automation, we are likely to have the time to do so, and it helps hedge our bets against spike damage. Drivers that manually target switch may wish to disable this setting to allow for more cross-dotting. ",
        },
        ['DoHealDPS']         = {
            DisplayName = "Heal DPS",
            Category = "Heal Mode",
            Index = 1,
            Tooltip = "Heal Mode: Use DoTs and Nukes",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "I feel that my Shaman is too concerned with DPS, dots and nukes, what can be done?",
            Answer = "Disabling Use HealDPS will stop the use of these spells and may add extra buffs or heals to their gems.",
        },
        ['DoHealOverTime']    = {
            DisplayName = "Use HoTs",
            Category = "Heal Mode",
            Index = 2,
            Tooltip = "Heal Mode: Use Heal Over Time Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why does my Shaman randomly use HoTs in downtime?",
            Answer = "Maintaining HoTs prevents emergencies and hopefully allows for better DPS. It also grants Synergy Procs at high level.",
        },
        ['DoChestClick']      = {
            DisplayName = "Do Chest Click",
            Category = "Heal Mode",
            Index = 3,
            Tooltip = "Click your equipped chest.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "What the heck is a chest click?",
            Answer = "Most classes have useful abilities on their equipped chest after level 75 or so. The SHM's is generally a healing tool (emergency group heal).",
        },
        ['DoAACanni']         = {
            DisplayName = "Use AA Canni",
            Category = "Canni",
            Index = 4,
            Tooltip = "Use Canni AA",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I not using the Canni AA?",
            Answer = "Check your HP/Mana percent settings, and, for combat, ensure you have selected the combat option as well.",
        },
        ['AACanniManaPct']    = {
            DisplayName = "AA Canni Mana %",
            Category = "Canni",
            Index = 5,
            Tooltip = "Use Canni AA Under [X]% mana",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Can you explain Canni Mana Settings?",
            Answer = "Setting the Mana % setting will use that form of Canni when you are below that mana percent.",
        },
        ['AACanniMinHP']      = {
            DisplayName = "AA Canni HP %",
            Category = "Canni",
            Index = 6,
            Tooltip = "Dont Use Canni AA Under [X]% HP",
            Default = 90,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Can you explain Canni HP Settings?",
            Answer = "Setting the HP % setting will stop you from using the form of Canni if you are below that HP percent.",
        },
        ['DoSpellCanni']      = {
            DisplayName = "Use Spell Canni",
            Category = "Canni",
            Index = 1,
            Tooltip = "Mem and use Canni Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I still using a Canni spell, now that I have the AA?",
            Answer =
            "By default, the Canni spell will be used while the gems are still available to do so, as Canni AA may not be enough at earlier levels. Use Spell Canni can be turned off at any time.",
        },
        ['SpellCanniManaPct'] = {
            DisplayName = "Spell Canni Mana %",
            Category = "Canni",
            Index = 2,
            Tooltip = "Use Canni Spell Under [X]% mana",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why do I wait so long to use my canni spell?",
            Answer = "Your Spell Canni Mana % governs how low you mana gets before you start using the spell.",
        },
        ['SpellCanniMinHP']   = {
            DisplayName = "Spell Canni HP %",
            Category = "Canni",
            Index = 3,
            Tooltip = "Dont Use Canni Spell Under [X]% HP",
            Default = 85,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why are Canni HP % settings so high?",
            Answer = "Default thresholds are conservative to prevent knee-jerk healing and can configured as needed.",
        },
        ['DoCombatCanni']     = {
            DisplayName = "Canni in Combat",
            Category = "Canni",
            Index = 7,
            Tooltip = "Use Canni AA and Spells in combat",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "My shaman spends his time in combat doing canni while I prefer him to do xyz other thing, what gives?",
            Answer =
            "Canni in Combat can be disabled at your discretion; you could also tune HP or Mana settings for Canni Spell or AA.",
        },
        --Buffs
        ['UseEpic']           = {
            DisplayName = "Epic Use:",
            Category = "Buffs",
            Index = 1,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            FAQ = "Why is my SHM using Epic on these trash mobs?",
            Answer = "By default, we use the Epic in any combat, as saving it for burns ends up being a DPS loss over a long frame of time.\n" ..
                "This can be adjusted in the Buffs tab.",
        },
        ['DoRunSpeed']        = {
            DisplayName = "Do Run Speed",
            Category = "Buffs",
            Index = 2,
            Tooltip = "Do Run Speed Spells/AAs",
            Default = true,
            FAQ = "Why are my buffers in a run speed buff war?",
            Answer = "Many run speed spells freely stack and overwrite each other, you will need to disable Run Speed Buffs on some of the buffers.",
        },
        ['DoGroupShrink']     = {
            DisplayName = "Group Shrink",
            Category = "Buffs",
            Index = 3,
            Tooltip = "Use Group Shrink Buff",
            Default = true,
            FAQ = "Group Shrink is enabled, why are my dudes still big?",
            Answer =
            "For simplicity, the check to use it is keyed to the Shaman's height, rather than checking each group member. Also, the AA isn't available until level 80 (on official servers).",
        },
        ['DoTempHP']          = {
            DisplayName = "Temp HP Buff",
            Category = "Buffs",
            Index = 4,
            Tooltip = "Use Temp HP Buff on Warriors in the group.",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why is the Temp HP Buff only used on Warriors?",
            Answer = "Mana costs and recast time make this buff only feasible on a Tank; PAL and SHD have their own buff and they don't stack with this one.",
        },
        ['DoAura']            = {
            DisplayName = "Use Aura",
            Category = "Buffs",
            Index = 5,
            Tooltip = "Use Aura (Pact of Wolf)",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "How do I stop my Aura from turning everything into a Werewolf?",
            Answer = "You can use /blockspell to safely block the illusion without blocking the buff, instructions on its use are given when typed in-game.",
        },
        ['DoGroupRegen']      = {
            DisplayName = "Group Regen Buff",
            Category = "Buffs",
            Index = 6,
            Tooltip = "Use your Group Regen buff.",
            Default = true,
            FAQ = "Why am I spamming my Group Regen buff?",
            Answer = "Certain Shaman and Druid group regen buffs report cross-stacking. You should deselect the option on one of the PCs if they are grouped together.",
        },
        ['DoHaste']           = {
            DisplayName = "Use Haste",
            Category = "Buffs",
            Index = 7,
            Tooltip = "Do Haste Spells/AAs",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why aren't I casting Talisman of Celerity or other haste buffs?",
            Answer = "Even with Use Haste enabled, these buffs are part of your Focus spell (Unity) at very high levels, so they may not be needed.",
        },
        ['DoVetAA']           = {
            DisplayName = "Do Vet AA",
            Category = "Buffs",
            Index = 8,
            Tooltip = "Use Veteran AA during burns (See FAQ).",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "What Veteran AA's will be used with Do Vet AA set?",
            Answer = "Currently, Shaman will use Intensity of the Resolute during burns. More may be added in the future.",
        },
        --Debuffs
        ['DoSTMalo']          = {
            DisplayName = "Do ST Malo",
            Category = "Debuffs",
            Index = 1,
            Tooltip = "Do ST Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Cast Malo is selected, why am I not using it?",
            Answer = "Ensure that your Debuff settings in the RGMercs Main config are set properly, as there are options for con colors and named mobs there.",
        },
        ['DoAEMalo']          = {
            DisplayName = "Do AE Malo",
            Category = "Debuffs",
            Index = 2,
            Tooltip = "Do AE Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "I have Do AE Malo selected, why isn't it being used?",
            Answer = "The AE Malo Spell comes later in the levels for Shaman than AE Slows, and the AA later than that. Check your level. Also, ensure your count is set properly. ",
        },
        ['DoSTSlow']          = {
            DisplayName = "Do ST Slow",
            Category = "Debuffs",
            Index = 4,
            Tooltip = "Do ST Slow Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why am I not slowing mobs?",
            Answer =
            "Certain low level slow spells are omitted due to the defensive benefit not being worth the mana. Also, check your debuff settings on the RGMercs Main config tabs, as there are options such as the minimum con color to debuff.",
        },
        ['DoAESlow']          = {
            DisplayName = "Do AE Slow",
            Category = "Debuffs",
            Index = 5,
            Tooltip = "Do AE Slow Spells/AAs",
            RequiresLoadoutChange = true,
            Default = false,
            FAQ = "Why am I using a single-target slow after the AE Slow Spell?",
            Answer = "The AE Slow Spell is a lower slow percentage than the ST Version. AA, however, are identical other than number of targets.",
        },
        ['AESlowCount']       = {
            DisplayName = "AE Slow Count",
            Category = "Debuffs",
            Index = 6,
            Tooltip = "Number of XT Haters before we use AE Slow.",
            Min = 1,
            Default = 2,
            Max = 10,
            ConfigType = "Advanced",
            FAQ = "We are fighting more than one mob, why am I not using my AE Slow?",
            Answer = "AE Slow Count governs the minimum number of targets before the AE Slow is used.",
        },
        ['AEMaloCount']       = {
            DisplayName = "AE Malo Count",
            Category = "Debuffs",
            Index = 3,
            Tooltip = "Number of XT Haters before we use AE Malo.",
            Min = 1,
            Default = 2,
            Max = 10,
            ConfigType = "Advanced",
            FAQ = "We are fighting more than one mob, why am I not using my AE Malo?",
            Answer = "AE Malo Count governs the minimum number of targets before the AE Malo is used.",
        },
        ['DoDiseaseSlow']     = {
            DisplayName = "Disease Slow",
            Category = "Debuffs",
            Index = 7,
            Tooltip = "Use Disease Slow instead of normal ST Slow",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "What is a Disease Slow?",
            Answer =
            "During early eras of play, a slow that checked against disease resist was added to slow magic-resistant mobs. If selected, this will be used instead of a magic-based slow until the Turgur's AA becomes available.",
        },
        ['DoLLHPBuff']        = {
            DisplayName = "HP Buff (LowLvl)",
            Category = "Buffs (Low Level)",
            Index = 1,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using HP buffs at lower levels?",
            Answer =
                "They are not enabled by default as they can in many cases be a waste of mana or time to cast in automation.\n" ..
                "You can select the low level buffs you would like to use on the Buffs (Low Level) tab.",
        },
        ['DoLLAgiBuff']       = {
            DisplayName = "Agility Buff (LowLvl)",
            Category = "Buffs (Low Level)",
            Index = 2,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using stat buffs at lower levels?",
            Answer =
                "They are not enabled by default as they can in many cases be a waste of mana or time to cast in automation.\n" ..
                "You can select the low level buffs you would like to use on the Buffs (Low Level) tab.",
        },
        ['DoLLStaBuff']       = {
            DisplayName = "Stamina Buff (LowLvl)",
            Category = "Buffs (Low Level)",
            Index = 3,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using stat buffs at lower levels?",
            Answer =
                "They are not enabled by default as they can in many cases be a waste of mana or time to cast in automation.\n" ..
                "You can select the low level buffs you would like to use on the Buffs (Low Level) tab.",
        },
        ['DoLLStrBuff']       = {
            DisplayName = "Strength Buff (LowLvl)",
            Category = "Buffs (Low Level)",
            Index = 4,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why am I not using stat buffs at lower levels?",
            Answer =
                "They are not enabled by default as they can in many cases be a waste of mana or time to cast in automation.\n" ..
                "You can select the low level buffs you would like to use on the Buffs (Low Level) tab.",
        },
    },
}

return _ClassConfig
