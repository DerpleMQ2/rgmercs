local mq                                 = require('mq')
local Modules                            = require("utils.modules")
local Tables                             = require("utils.tables")
local Strings                            = require("utils.strings")
local Files                              = require("utils.files")
local Logger                             = require("utils.logger")
local Set                                = require("mq.Set")

local Config                             = {
    _version = '1.2',
    _subVersion = "The Outer Brood",
    _name =
    "RGMercs Lua Edition",
    _author = 'Lead Devs: Derple, Algar',
}
Config.__index                           = Config
Config.settings                          = {}
Config.FAQ                               = {}

Config.TempSettings                      = {}
Config.TempSettings.SettingToModuleCache = {}

-- Global State
Config.Globals                           = {}
Config.Globals.MainAssist                = ""
Config.Globals.ScriptDir                 = ""
Config.Globals.AutoTargetID              = 0
Config.Globals.ForceTargetID             = 0
Config.Globals.LastPulledID              = 0
Config.Globals.SubmodulesLoaded          = false
Config.Globals.PauseMain                 = false
Config.Globals.LastMove                  = nil
Config.Globals.BackOffFlag               = false
Config.Globals.InMedState                = false
Config.Globals.LastPetCmd                = 0
Config.Globals.LastFaceTime              = 0
Config.Globals.CurZoneId                 = mq.TLO.Zone.ID()
Config.Globals.CurInstance               = mq.TLO.Me.Instance()
Config.Globals.CurLoadedChar             = mq.TLO.Me.DisplayName()
Config.Globals.CurLoadedClass            = mq.TLO.Me.Class.ShortName()
Config.Globals.CurServer                 = mq.TLO.EverQuest.Server():gsub(" ", "")
Config.Globals.CastResult                = 0
Config.Globals.BuildType                 = mq.TLO.MacroQuest.BuildName()
Config.Globals.Minimized                 = false
Config.Globals.LastUsedSpell             = "None"
Config.Globals.CorpseConned              = false
Config.Globals.RezzedCorpses             = {}

-- Constants
Config.Constants                         = {}
Config.Constants.RGCasters               = Set.new({ "BRD", "BST", "CLR", "DRU", "ENC", "MAG", "NEC", "PAL", "RNG", "SHD",
    "SHM", "WIZ", })
Config.Constants.RGMelee                 = Set.new({ "BRD", "SHD", "PAL", "WAR", "ROG", "BER", "MNK", "RNG", "BST", })
Config.Constants.RGHybrid                = Set.new({ "SHD", "PAL", "RNG", "BST", "BRD", })
Config.Constants.RGTank                  = Set.new({ "WAR", "PAL", "SHD", })
Config.Constants.RGPetClass              = Set.new({ "BST", "NEC", "MAG", "SHM", "ENC", "SHD", })
Config.Constants.RGMezAnims              = Set.new({ 1, 5, 6, 27, 43, 44, 45, 80, 82, 112, 134, 135, })
Config.Constants.ModRods                 = { "Modulation Shard", "Transvergence", "Modulation", "Modulating", "Azure Mind Crystal", }
Config.Constants.SpellBookSlots          = 1120
Config.Constants.CastCompleted           = Set.new({ "CAST_SUCCESS", "CAST_IMMUNE", "CAST_TAKEHOLD", "CAST_RESISTED", "CAST_RECOVER", })

Config.Constants.CastResults             = {
    ['CAST_RESULT_NONE'] = 0,
    ['CAST_SUCCESS']     = 1,
    ['CAST_BLOCKED']     = 2,
    ['CAST_IMMUNE']      = 3,
    ['CAST_FDFAIL']      = 4,
    ['CAST_COMPONENTS']  = 5,
    ['CAST_CANNOTSEE']   = 6,
    ['CAST_TAKEHOLD']    = 7,
    ['CAST_STUNNED']     = 8,
    ['CAST_STANDING']    = 9,
    ['CAST_RESISTED']    = 10,
    ['CAST_RECOVER']     = 11,
    ['CAST_PENDING']     = 12,
    ['CAST_OUTDOORS']    = 13,
    ['CAST_OUTOFRANGE']  = 14,
    ['CAST_OUTOFMANA']   = 15,
    ['CAST_NOTREADY']    = 16,
    ['CAST_NOTARGET']    = 17,
    ['CAST_INTERRUPTED'] = 18,
    ['CAST_FIZZLE']      = 19,
    ['CAST_DISTRACTED']  = 20,
    ['CAST_COLLAPSE']    = 21,
    ['CAST_OVERWRITTEN'] = 22,
}

Config.Constants.CastResultsIdToName     = {}
for k, v in pairs(Config.Constants.CastResults) do Config.Constants.CastResultsIdToName[v] = k end

Config.Constants.ExpansionNameToID = {
    ['EXPANSION_LEVEL_CLASSIC'] = 0,  -- No Expansion
    ['EXPANSION_LEVEL_ROK']     = 1,  -- The Ruins of Kunark
    ['EXPANSION_LEVEL_SOV']     = 2,  -- The Scars of Velious
    ['EXPANSION_LEVEL_SOL']     = 3,  -- The Shadows of Luclin
    ['EXPANSION_LEVEL_POP']     = 4,  -- The Planes of Power
    ['EXPANSION_LEVEL_LOY']     = 5,  -- The Legacy of Ykesha
    ['EXPANSION_LEVEL_LDON']    = 6,  -- Lost Dungeons of Norrath
    ['EXPANSION_LEVEL_GOD']     = 7,  -- Gates of Discord
    ['EXPANSION_LEVEL_OOW']     = 8,  -- Omens of War
    ['EXPANSION_LEVEL_DON']     = 9,  -- Dragons of Norrath
    ['EXPANSION_LEVEL_DODH']    = 10, -- Depths of Darkhollow
    ['EXPANSION_LEVEL_POR']     = 11, -- Prophecy of Ro
    ['EXPANSION_LEVEL_TSS']     = 12, -- The Serpent's Spine
    ['EXPANSION_LEVEL_TBS']     = 13, -- The Buried Sea
    ['EXPANSION_LEVEL_SOF']     = 14, -- Secrets of Faydwer
    ['EXPANSION_LEVEL_SOD']     = 15, -- Seeds of Destruction
    ['EXPANSION_LEVEL_UF']      = 16, -- Underfoot
    ['EXPANSION_LEVEL_HOT']     = 17, -- House of Thule
    ['EXPANSION_LEVEL_VOA']     = 18, -- Veil of Alaris
    ['EXPANSION_LEVEL_ROF']     = 19, -- Rain of Fear
    ['EXPANSION_LEVEL_COTF']    = 20, -- Call of the Forsaken
    ['EXPANSION_LEVEL_TDS']     = 21, -- The Darkened Sea
    ['EXPANSION_LEVEL_TBM']     = 22, -- The Broken Mirror
    ['EXPANSION_LEVEL_EOK']     = 23, -- Empires of Kunark
    ['EXPANSION_LEVEL_ROS']     = 24, -- Ring of Scale
    ['EXPANSION_LEVEL_TBL']     = 25, -- The Burning Lands
    ['EXPANSION_LEVEL_TOV']     = 26, -- Torment of Velious
    ['EXPANSION_LEVEL_COV']     = 27, -- Claws of Veeshan
    ['EXPANSION_LEVEL_TOL']     = 28, -- Terror of Luclin
    ['EXPANSION_LEVEL_NOS']     = 29, -- Night of Shadows
    ['EXPANSION_LEVEL_LS']      = 30, -- Laurion's Song
    ['EXPANSION_LEVEL_TOB']     = 31, -- The Outer Brood
}

Config.Constants.ExpansionIDToName = {}
for k, v in pairs(Config.Constants.ExpansionNameToID) do Config.Constants.ExpansionIDToName[v] = k end

Config.Constants.LogLevels         = {
    "Errors",
    "Warnings",
    "Info",
    "Debug",
    "Verbose",
    "Super-Verbose",
}

Config.Constants.ConColors         = {
    "Grey", "Green", "Light Blue", "Blue", "White", "Yellow", "Red",
}
Config.Constants.ConColorsNameToId = {}
for i, v in ipairs(Config.Constants.ConColors) do Config.Constants.ConColorsNameToId[v:upper()] = i end

Config.Constants.SpireChoices = { "First", "Second", "Third", "Disabled", }

Config.Constants.LastGemRemem = { "Do Nothing", "Mem Previous Spell", "Mem Loadout Spell", }
Config.Constants.DebuffChoice = { "Never", "Based on Con Color", "Always", }

-- Defaults
Config.DefaultConfig = {

    -- Custom: These use custom UI elements and do not display in normal settings windows.
    ['ClassConfigDir']       = {
        DisplayName = "Class Config Dir",
        Category = "Main",
        Tooltip = "Which version of class configs to Load",
        Type = "Custom",
        Default = mq.TLO.EverQuest.Server() == "Project Lazarus" and "Project Lazarus" or "Live",
        FAQ = "How do I load configuration file for different servers types?",
        Answer = "You can change the config type by selecting a different Server Type from the main panel.",
    },
    ['AssistOutside']        = {
        DisplayName = "Assist Outside of Group",
        Tooltip = "Allow assisting characters outside of your group.",
        Type = "Custom",
        Default = false,
        FAQ = "How do I use the Outside Assist List?",
        Answer = "You can add characters to the list on the main tab, and enable the assist outside option to allow you to assist them.",
    },
    ['OutsideAssistList']    = {
        DisplayName = "List of Outsiders to Assist",
        Tooltip = "List of Outsiders to Assist",
        Type = "Custom",
        Default = {},
        FAQ = "How do I Setup who to assist from outside of my group?",
        Answer = "You can add characters to the [OutsideAssistList] to allow you to assist them.",
    },

    -- [ CLICKIES ] --
    ['ClickyItem1']          = {
        DisplayName = "Downtime Item 1",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 1,
    },
    ['ClickyItem2']          = {
        DisplayName = "Downtime Item 2",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 2,
    },
    ['ClickyItem3']          = {
        DisplayName = "Downtime Item 3",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 3,
    },
    ['ClickyItem4']          = {
        DisplayName = "Downtime Item 4",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 4,
    },
    ['ClickyItem5']          = {
        DisplayName = "Downtime Item 5",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 5,
    },
    ['ClickyItem6']          = {
        DisplayName = "Downtime Item 6",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 6,
    },
    ['ClickyItem7']          = {
        DisplayName = "Downtime Item 7",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 7,
    },
    ['ClickyItem8']          = {
        DisplayName = "Downtime Item 8",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 8,
    },
    ['ClickyItem9']          = {
        DisplayName = "Downtime Item 9",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 9,
    },
    ['ClickyItem10']         = {
        DisplayName = "Downtime Item 10",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 10,
    },
    ['ClickyItem11']         = {
        DisplayName = "Downtime Item 11",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 11,
    },
    ['ClickyItem12']         = {
        DisplayName = "Downtime Item 12",
        Category = "Clickies",
        Tooltip = "Clicky Item to use During Downtime",
        Type = "Custom",
        Default = "",
        ConfigType = "Advanced",
        Index = 12,
    },

    ['CombatClicky1']        = {
        DisplayName = "Combat Item 1",
        Category    = "Clickies",
        Tooltip     = "Clicky Item to use During Downtime",
        Type        = "Custom",
        Default     = "",
        ConfigType  = "Advanced",
        Index       = 15,
    },
    ['CombatClicky2']        = {
        DisplayName = "Combat Item 2",
        Category    = "Clickies",
        Tooltip     = "Clicky Item to use During Downtime",
        Type        = "Custom",
        Default     = "",
        ConfigType  = "Advanced",
        Index       = 16,
    },
    ['CombatClicky3']        = {
        DisplayName = "Combat Item 3",
        Category    = "Clickies",
        Tooltip     = "Clicky Item to use During Downtime",
        Type        = "Custom",
        Default     = "",
        ConfigType  = "Advanced",
        Index       = 17,
    },
    ['CombatClicky4']        = {
        DisplayName = "Combat Item 4",
        Category    = "Clickies",
        Tooltip     = "Clicky Item to use During Downtime",
        Type        = "Custom",
        Default     = "",
        ConfigType  = "Advanced",
        Index       = 18,
    },
    ['CombatClicky5']        = {
        DisplayName = "Combat Item 5",
        Category    = "Clickies",
        Tooltip     = "Clicky Item to use During Downtime",
        Type        = "Custom",
        Default     = "",
        ConfigType  = "Advanced",
        Index       = 19,
    },
    ['CombatClicky6']        = {
        DisplayName = "Combat Item 6",
        Category    = "Clickies",
        Tooltip     = "Clicky Item to use During Downtime",
        Type        = "Custom",
        Default     = "",
        ConfigType  = "Advanced",
        Index       = 20,
    },

    -- [ MED/MANA ] --
    ['DoMed']                = {
        DisplayName = "Do Meditate",
        Category = "Med/Mana",
        Index = 1,
        Tooltip = "Choose if/when to meditate.",
        Type = "Combo",
        ComboOptions = { 'Off', 'Out of Combat', 'In and Out of Combat', },
        Default = 2,
        Min = 1,
        Max = 3,
        ConfigType = "Normal",
        FAQ = "How do I change when I maditate?",
        Answer = "You can set the [DoMed] option to the desired Meditation Setting." ..
            "'Out of Combat' Will only Meditate Outside of Combat." ..
            "'In Combat' Will Meditate in and out of Combat." ..
            "'Off' Will not Meditate.",
    },
    ['HPMedPct']             = {
        DisplayName = "Med HP %",
        Category = "Med/Mana",
        Index = 2,
        Tooltip = "What HP % to hit before medding.",
        Default = 60,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "I want to Regen health when I am low what do I need to do?",
        Answer = "You can set the [HPMedPct] option to the percent health you would like to sit and start to regenerate at.",
    },
    ['ManaMedPct']           = {
        DisplayName = "Med Mana %",
        Category = "Med/Mana",
        Index = 4,
        Tooltip = "What Mana % to hit before medding.",
        Default = 60,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "Why am I not meditating?",
        Answer = "Make sure [DoMed] is not set to 'Off'." ..
            "You can set the [ManaMedPct] option to the percent mana you would like to start meditating at.",
    },
    ['EndMedPct']            = {
        DisplayName = "Med Endurance %",
        Category = "Med/Mana",
        Index = 6,
        Tooltip = "What Endurance % to hit before medding.",
        Default = 60,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "Why am I always out of endurance?",
        Answer = "Make sure [DoMed] is not set to 'Off'." ..
            "You can set the [EndMedPct] option to the percent endurance you would like to start regenerating at.",
    },
    ['ManaMedPctStop']       = {
        DisplayName = "Med Mana % Stop",
        Category = "Med/Mana",
        Index = 5,
        Tooltip = "What Mana % to hit before stopping medding.",
        Default = 90,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "Why am I only Meditating to 60% Mana?",
        Answer = "You can set the [ManaMedPctStop] option to the percent mana you would like to stop meditating at.",

    },
    ['EndMedPctStop']        = {
        DisplayName = "Med Endurance % Stop",
        Category = "Med/Mana",
        Index = 7,
        Tooltip = "What Endurance % to hit before stopping medding.",
        Default = 90,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "Why am I only Recovering to 60% Endurance?",
        Answer = "You can set the [EndMedPctStop] option to the percent endurance you would like to stop meditating at.",
    },
    ['HPMedPctStop']         = {
        DisplayName = "Med HP % Stop",
        Category = "Med/Mana",
        Index = 3,
        Tooltip = "What HP % to hit before stopping medding.",
        Default = 90,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "Why am I only Regenerating to 60% Health?",
        Answer = "You can set the [HPMedPctStop] option to the percent health you would like to stop meditating at.",
    },
    ['MedAggroCheck']        = {
        DisplayName = "Med Aggro Check",
        Category = "Med/Mana",
        Index = 8,
        Tooltip = "Force a stand we have aggro higher than the below setting from an xtarget.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I trying to meditate when I am being hit or targeted in combat?",
        Answer = "You can enable the Med Aggro Check on the Med/Mana tab to stop meditation in these conditions.",
    },
    ['MedAggroPct']          = {
        DisplayName = "Med Aggro Pct",
        Category = "Med/Mana",
        Index = 9,
        Tooltip = "Aggro percent value for the Med Aggro Check.",
        Default = 65,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I trying to meditate when I am being hit or targeted in combat?",
        Answer = "You can adjust the Med Aggro Percent on the Med/Mana tab to stop meditation in these conditions. Ensure the Med Aggro Check is enabled.",
    },
    ['StandWhenDone']        = {
        DisplayName = "Stand When Done Medding",
        Category = "Med/Mana",
        Index = 10,
        Tooltip = "Force a stand when medding thresholds are reached.",
        Default = false,
        FAQ = "I don't want to stand up after medding, I prefer to stay seated until combat starts or I take another action, how do I change this?",
        Answer = "You can set the [StandWhenDone] option to false to stay seated until something else requires you to stand.",
    },
    ['AfterCombatMedDelay']  = {
        DisplayName = "After Combat Med Delay",
        Category = "Med/Mana",
        Index = 11,
        Tooltip = "How long to delay after combat in seconds before sitting.",
        Default = 6,
        Min = 0,
        Max = 60,
        ConfigType = "Advanced",
        FAQ = "I keep sitting after combat to med and getting attacked within seconds, how do I fix this?",
        Answer = "You can set the [AfterCombatMedDelay] option to the number of seconds you would like to wait after combat before sitting to med.",
    },
    ['DoModRod']             = {
        DisplayName = "Do Mod Rod",
        Category = "Med/Mana",
        Index = 12,
        Tooltip = "Auto use Mod Rods if we have them",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "How do I automate using Mod Rods?",
        Answer = "You can set the [DoModRod] option to true to automatically use Mod Rods when your mana drops below the [ModRodManaPct] setting.",
    },
    ['ModRodManaPct']        = {
        DisplayName = "Mod Rod Mana %",
        Category = "Med/Mana",
        Index = 13,
        Tooltip = "What Mana % to hit before using a rod.",
        Default = 60,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "How do I automate using Mod Rods?",
        Answer = "You can set the [ModRodManaPct] option to the percent mana you would like to start using Mod Rods at.",
    },

    -- [ PET / MERC] --
    ['DoPet']                = {
        DisplayName = "Summon Pet",
        Category = "Pet/Merc",
        Index = 1,
        Tooltip = "Enable the summoning and buffing of pets.",
        Default = true,
        ConfigType = "Normal",
        FAQ = "How do I turn off pet summoning and/or pet buffing?",
        Answer = "You can set the Summon Pet option on the Pet/Merc tab to enable or disable pet summoning.\nNote that swarm pets may still be summoned.",
    },
    ['DoPetCommands']        = {
        DisplayName = "Pet Control",
        Category = "Pet/Merc",
        Index = 2,
        Tooltip = "Allow RGMercs to issue pet commands.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why isn't my pet doing anything?",
        Answer =
        "Ensure that the Pet Control option is checked on the Pet/Merc tab.\nNote that this also affects the /pet swarm command for swarm pets.",
    },
    ['PetEngagePct']         = {
        DisplayName = "Pet Engage HPs",
        Category = "Pet/Merc",
        Index = 3,
        Tooltip = "Send in pet when target hits [x] HP %.",
        Default = 96,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "How do I change when my pet engages?",
        Answer = "You can set the [PetEngagePct] option to the percent health you would like your pet to engage at.",
    },
    ['DoShrinkPet']          = {
        DisplayName = "Do Pet Shrink",
        Category = "Pet/Merc",
        Index = 4,
        Tooltip = "Enable auto shrinking your pet",
        Default = false,
        ConfigType = "Normal",
        FAQ = "How do I automatically shrink my pets?",
        Answer = "You can set the [DoShrinkPet] option to true to automatically shrink your pet.",
    },
    ['ShrinkPetItem']        = {
        DisplayName = "Shrink Pet Item",
        Category = "Pet/Merc",
        Index = 5,
        Tooltip = "Item to use to shrink your pet",
        Type = "ClickyItem",
        Default = "",
        ConfigType = "Normal",
        FAQ = "How do I shrink my pet? I have a clicky item that does it.",
        Answer = "You can set the [ShrinkPetItem] option to the name of the item you would like to use to shrink your pet.",
    },
    ['DoMercenary']          = {
        DisplayName = "Merc Control",
        Category = "Pet/Merc",
        Index = 6,
        Tooltip = "Allow RGMercs to issue mercenary commands.",
        Default = (Config.Globals.BuildType ~= 'Emu'),
        ConfigType = "Normal",
        FAQ = "How do I use Mercenaries in my group?",
        Answer = "You can set the [DoMercenary] option to true to allow RGMercs to issue mercenary commands.",
    },

    -- [ ENGAGE ] --
    ['SafeTargeting']        = {
        DisplayName = "Use Safe Targeting",
        Category = "Engage",
        Index = 8,
        Tooltip = "Do not target mobs that are fighting others.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why do I keep targeting mobs that are fighting other players?",
        Answer = "You can set the [SafeTargeting] option to true to avoid targeting mobs that are fighting other players.",

    },
    ['AssistRange']          = {
        DisplayName = "Assist Range",
        Category = "Engage",
        Index = 3,
        Tooltip = "Distance to the target before you engage.",
        Default = Config.Constants.RGCasters:contains(Config.Globals.CurLoadedClass) and 90 or 45,
        Min = 0,
        Max = 200,
        ConfigType = "Advanced",
        FAQ = "Why am I running to engage mobs that are not in camp?",
        Answer = "You can set the [AssistRange] option to the distance you would like to engage mobs at.",
    },
    ['AutoAssistAt']         = {
        DisplayName = "Auto Assist At",
        Category = "Engage",
        Index = 2,
        Tooltip = "Melee attack when target hits [x] HP %.",
        Default = 98,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I not attacking the mob?",
        Answer = "You can set the [AutoAssistAt] option to the percent health you would like to start attacking at.",
    },
    ['StickHow']             = {
        DisplayName = "Stick How",
        Category = "Engage",
        Index = 6,
        Tooltip = "Custom /stick command",
        Default = "",
        ConfigType = "Advanced",
        FAQ = "How do I change the /stick command?",
        Answer = "You can set the [StickHow] option to the custom /stick command you would like to use.\n" ..
            "See the MQ2Stick documentation for more information.",
    },
    ['AllowMezBreak']        = {
        DisplayName = "Allow Mez Break",
        Category = "Engage",
        Index = 10,
        Tooltip = "Allow Mez Breaking.",
        Default = (Config.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName())),
        ConfigType = "Advanced",
        FAQ = "Why is my Tank not breaking Mez?\nWhy is X Char Breaking Mez all the time?",
        Answer = "Check the [AllowMezBreak] option, true will allow Mez Breaking.",
    },
    ['DoAutoTarget']         = {
        DisplayName = "Auto Target",
        Category = "Engage",
        Index = 7,
        Tooltip = "Automatically change targets.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I Always changing targets?",
        Answer = "You can set the [DoAutoTarget] option to false to stop automatically changing targets.",
    },
    ['StayOnTarget']         = {
        DisplayName = "Stay On Target",
        Category = "Engage",
        Index = 9,
        Tooltip = "Stick to your target. Default: true; Tank Mode Defaults: false. false allows intelligent target swapping based on aggro/named/ etc.",
        Default = (not Config.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName())),
        ConfigType = "Advanced",
        FAQ = "Why am I not changing targets when I am in Tank Mode?",
        Answer = "You can set the [StayOnTarget] option to false to allow intelligent target swapping based on aggro/named/ etc.",
    },
    ['DoAutoEngage']         = {
        DisplayName = "Auto Engage",
        Category = "Engage",
        Index = 1,
        Tooltip = "Automatically engage targets.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I not attacking the mob?",
        Answer = "You can set the [DoAutoEngage] option to true to automatically engage targets.",
    },
    ['DoMelee']              = {
        DisplayName = "Enable Melee Combat",
        Category = "Engage",
        Index = 4,
        Tooltip = "Melee targets.",
        Default = Config.Globals.CurLoadedClass ~= "RNG" and Config.Constants.RGMelee:contains(Config.Globals.CurLoadedClass),
        ConfigType = "Normal",
        FAQ = "Why am I not attacking the mob?",
        Answer = "You can set the [DoMelee] option to true to enable melee combat.",
    },
    ['AutoStandFD']          = {
        DisplayName = "Stand from FD in Combat",
        Category = "Engage",
        Index = 12,
        Tooltip = "Auto stands you up from FD if combat starts.",
        Default = true,
        ConfigType = "Normal",
        FAQ = "Why am I not standing up from Feign Death?",
        Answer = "You can set the [AutoStandFD] option to true to automatically stand up from Feign Death if combat starts.",
    },
    ['FaceTarget']           = {
        DisplayName = "Face Target in Combat",
        Category = "Engage",
        Index = 5,
        Tooltip = "Periodically /face your target while in combat.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I getting warnings about not facing my target?",
        Answer = "You can set the [FaceTarget] option to true to periodically /face your target while in combat.",
    },
    ['RaidAssistTarget']     = {
        DisplayName = "Raid Assist Target",
        Category = "Engage",
        Index = 15,
        Tooltip = "Which Raid Assist target to follow. Please note that we will not fallback if this is not set properly.",
        Type = "Combo",
        ComboOptions = { 'First', 'Second', 'Third', },
        Default = 1,
        Min = 1,
        Max = 3,
        ConfigType = "Normal",
        FAQ = "Why am I not following the Raid Assist target I want?",
        Answer = "You can set the preferred Raid Assist Target on the Engage tab of the main options.",
    },
    ['FollowMarkTarget']     = {
        DisplayName = "Follow Mark Target",
        Category = "Engage",
        Index = 16,
        Tooltip = "Auto target MA target Marks.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why am I not following the Marked target?",
        Answer = "You can set the [FollowMarkTarget] option to true to automatically target the MA's Marked target.",
    },

    -- [SPELLS/ABILS] --
    ['ManaToNuke']           = {
        DisplayName = "Mana to Nuke",
        Category = "Spells/Abils",
        Index = 1,
        Tooltip = "Minimum % Mana in order to continue to cast nukes. Please note that some default configs (MAG, WIZ) only check this setting for particular spells.",
        Default = 30,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I not casting Nukes?",
        Answer = "You can set the [ManaToNuke] option to the minimum mana to casting nukes at.",
    },
    ['ManaToDot']            = {
        DisplayName = "Mana to Dot",
        Category = "Spells/Abils",
        Index = 2,
        Tooltip = "Minimum % Mana in order to continue to cast dots.",
        Default = 30,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I not casting Dots?",
        Answer = "You can set the [ManaToDot] option to the minimum mana to casting dots at.",
    },
    ['ManaToDebuff']         = {
        DisplayName = "Mana to Debuff",
        Category = "Spells/Abils",
        Index = 3,
        Tooltip = "Minimum % Mana in order to continue to cast debuffs.",
        Default = 10,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I not casting Debuffs?",
        Answer = "You can set the [ManaToDebuff] option to the minimum mana to casting debuffs at.",
    },
    ['AggroThrottling']      = {
        DisplayName = "Use Aggro Throttling",
        Category = "Spells/Abils",
        Index = 4,
        Tooltip = "Don't use nukes and similar spells when your aggro percent is above the Aggro To Cast value below.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I not casting some spells when I have aggro?",
        Answer = "You can disable the setting to use nukes and similar spells regardless of your aggro on the current target.",
    },
    ['MobMaxAggro']          = {
        DisplayName = "Max Aggro:",
        Category = "Spells/Abils",
        Index = 5,
        Tooltip = "Maximum % Aggro on the current target in order for a PC not in Tank mode to continue to take most offensive options.",
        Default = 90,
        Min = 1,
        Max = 999,
        ConfigType = "Advanced",
        FAQ = "Why am I not casting or acting on my target at high aggro?",
        Answer = "You can set the Max Aggro option to the maximum aggro to cast or use most offensive actions at.",
    },
    ['MobLowHP']             = {
        DisplayName = "Mob Low HP:",
        Category = "Spells/Abils",
        Index = 6,
        Tooltip = "A mob is considered to be low HP (for the sake of Dots and other abilities) under x HP%.",
        Default = 50,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I not casting Dots?",
        Answer = "We will check the health of a mob with Mob Low HP or Named Low HP to determine whether to do things like cast Dots, or long nukes.",
    },
    ['NamedLowHP']           = {
        DisplayName = "Named Low HP:",
        Category = "Spells/Abils",
        Index = 7,
        Tooltip = "A named mob is considered to be low HP (for the sake of Dots and other abilities) under x HP%.",
        Default = 25,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why do I keep dotting the named when it is below the Mob Low HP threshold?",
        Answer = "Named Targets have their own setting for low HP, Adjust the Named Low HP option instead.",
    },
    ['MobDebuff']            = {
        DisplayName = "Mob Debuffing:",
        Category = "Spells/Abils",
        Index = 8,
        Tooltip = "The circumstances in which we will debuff a (non-named) mob.",
        Default = 2,
        Min = 1,
        Max = #Config.Constants.DebuffChoice,
        Type = "Combo",
        ComboOptions = Config.Constants.DebuffChoice,
        ConfigType = "Advanced",
        FAQ = "Why am I not debuffing a normal trash mob?",
        Answer = "Ensure that you have selected your preferred options on the Main Spells/Abils tab. Double-check your min con color if debuffing based on that.",
    },
    ['NamedDebuff']          = {
        DisplayName = "Named Debuffing:",
        Category = "Spells/Abils",
        Index = 9,
        Tooltip = "The circumstances in which we will debuff a (named) mob.",
        Default = 2,
        Min = 1,
        Max = #Config.Constants.DebuffChoice,
        Type = "Combo",
        ComboOptions = Config.Constants.DebuffChoice,
        ConfigType = "Advanced",
        FAQ = "Why am I not debuffing a named mob?",
        Answer = "Ensure that you have selected your preferred options on the Main Spells/Abils tab. Double-check your min con color if debuffing based on that.\n" ..
            "Also, ensure that the mob is properly being tracked by mercs as a named mob (see the named tab for more information.)",
    },
    ['DebuffMinCon']         = {
        DisplayName = "Debuff Min Con",
        Category = "Spells/Abils",
        Index = 10,
        Tooltip = "Min Con to use debuffs on",
        Default = 4,
        Min = 1,
        Max = #Config.Constants.ConColors,
        Type = "Combo",
        ComboOptions = Config.Constants.ConColors,
        ConfigType = "Advanced",
        FAQ = "Why am I not debuffing the mob?",
        Answer = "You can set the [DebuffMinCon] option to the minimum con color to debuff.",
    },
    ['DoAlliance']           = {
        DisplayName = "Do Alliance",
        Category = "Spells/Abils",
        Index = 11,
        Tooltip = "Automatically cast Alliance spells.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why am I not casting Alliance spells?",
        Answer = "You can set the [DoAlliance] option to true to automatically cast Alliance spells.",
    },
    ['StandFailedFD']        = {
        DisplayName = "Stand on Failed FD",
        Category = "Spells/Abils",
        Index = 12,
        Tooltip = "Auto stands you up if you fall to the ground.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I not standing up from Feign Death when it fails?",
        Answer = "You can set the [StandFailedFD] option to true to automatically stand up if you fail to Feign Death.",
    },
    ['LastGemRemem']         = {
        DisplayName = "Remem After Buff:",
        Category = "Spells/Abils",
        Index = 13,
        Tooltip = "Choose what do with the last gem slot after we use it to buff:\n" ..
            "Do Nothing: Use the slot as needed for buffs, but don't rememorize anything.\n" ..
            "Remem Previous Spell: Rememorize the spell that was in the slot before buffing, if there was one.\n" ..
            "Remem Loadout Spell: Rememorize the spell from the current loadout, if there is one.",
        Default = 3,
        Min = 1,
        Max = #Config.Constants.LastGemRemem,
        Type = "Combo",
        ComboOptions = Config.Constants.LastGemRemem,
        ConfigType = "Advanced",
        FAQ = "Why am I constantly rememorizing buffs in the last slot?",
        Answer = "You can control how and what we will remem in the last gem after buffing on the Spells/Abils options tab.",
    },
    ['IgnoreLevelCheck']     = {
        DisplayName = "Ignore Spell Level Checks",
        Category = "Spells/Abils",
        Index = 14,
        Tooltip = "If your server allows for higher level spells to land on lower level characters check this.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['WaitOnGlobalCooldown'] = {
        DisplayName = "Wait on Global Cooldown",
        Category = "Spells/Abils",
        Index = 15,
        Tooltip = "Wait on Global Cooldown before trying to cast more spells (Should NOT be used by classes that have Weave rotations!)",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why am I not casting spells?",
        Answer = "You can set the [WaitOnGlobalCooldown] option to true to wait on the Global Cooldown before trying to cast more spells.",
    },
    ['CastReadyDelayFact']   = {
        DisplayName = "Cast Ready Delay Factor",
        Category = "Spells/Abils",
        Index = 16,
        Tooltip = "Wait Ping * [n] ms before saying we are ready to cast.",
        Default = 0,
        Min = 0,
        Max = 10,
        ConfigType = "Advanced",
        FAQ = "Why am I getting spell not ready spam?",
        Answer = "Your spell may not be ready set the [CastReadyDelayFact] option to the number of milliseconds to wait before checking again.",
    },
    ['SongClipDelayFact']    = {
        DisplayName = "Song Clip Delay Factor",
        Category = "Spells/Abils",
        Index = 17,
        Tooltip = "Wait Ping * [n] ms to allow songs to take effect before singing the next.",
        Default = 2,
        Min = 1,
        Max = 10,
        ConfigType = "Advanced",
        FAQ = "Why are my songs not landing before casting a new one?",
        Answer = "You can set the [SongClipDelayFact] option to the number of milliseconds to wait before casting a new song.",
    },
    ['UseExactSpellNames']   = {
        DisplayName = "Use Exact Spell Names",
        Category = "Spells/Abils",
        Index = 18,
        Tooltip = "This will cause RGMercs to use '/cast =<Spell>' which , must be supported by your MQ version but will avoid things like 'Bane' casting 'Bane of Nife' instead.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why is the wrong spell being cast/a spell not being cast when it says it is?",
        Answer = "If the spell name is not unique, you can set the [UseExactSpellNames] option to true to use the exact spell name when casting.",
    },

    -- [ Tank/MA ] --
    ['MovebackWhenTank']     = {
        DisplayName = "Moveback as Tank",
        Category = "Tank/MA",
        Index = 1,
        Tooltip = "Adds 'moveback' to stick command when tanking. Helpful to keep mobs from getting behind you.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "I keep getting You can not see your target, messages while tanking. How do I fix this?",
        Answer = "You can set the [MovebackWhenTank] option to true to add 'moveback' to the stick command when tanking.",
    },
    ['MovebackWhenBehind']   = {
        DisplayName = "Moveback if Mob Behind",
        Category = "Tank/MA",
        Index = 2,
        Tooltip = "Causes you to move back if we detect an XTarget is behind you when tanking.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "I keep getting Backstabbed, how do I fix this?",
        Answer = "You can set the [MovebackWhenBehind] option to true to move back if we detect an XTarget is behind you when tanking.",
    },
    ['MovebackDistance']     = {
        DisplayName = "Units to Moveback",
        Category = "Tank/MA",
        Index = 3,
        Tooltip = "Default: 20. May require adjustment based on runspeed.",
        Default = 20,
        Min = 1,
        Max = 40,
        ConfigType = "Advanced",
        FAQ = "I backed up off the ledge, how do I fix this?",
        Answer = "You can set the [MovebackDistance] option to the number of units to move back when tanking.",
    },
    ['ForceKillPet']         = {
        DisplayName = "Force Kill Pet",
        Category = "Tank/MA",
        Index = 4,
        Tooltip = "Force kill pcpet if on xtarget.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Someones pet is causing issues, how do I fix this?",
        Answer = "You can set the [ForceKillPet] option to true to force kill pcpet if on xtarget.",
    },
    ['OnlyScanXT']           = {
        DisplayName = "Only Scan XTargets",
        Category = "Tank/MA",
        Index = 5,
        Tooltip = "When MA looks for a target use only XTargets instead of doing an area scan, area scan can cause aggro to unintentional mobs use wih caution.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I targeting mobs that are not in camp?",
        Answer = "You can set the [OnlyScanXT] option to true to only use XTargets when looking for a target.",
    },
    ['MAScanZRange']         = {
        DisplayName = "Main Assist Scan ZRange",
        Category = "Tank/MA",
        Index = 6,
        Tooltip = "Distance in Z direction to look for targets.",
        Default = 45,
        Min = 15,
        Max = 200,
        ConfigType = "Advanced",
        FAQ = "I have trouble pulling targets on hills and ledges, how do I fix this?",
        Answer = "You can set the [MAScanZRange] option to the distance in the Z direction to look for targets.",
    },

    -- [ BUFFS ] --
    ['DoBuffs']              = {
        DisplayName = "Do Buffs",
        Category = "Buffs",
        Index = 1,
        Tooltip = "Do Non-Class Specific Buffs.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I not buffing?",
        Answer = "You can set the [DoBuffs] option to true to do non-class specific buffs.",
    },
    ['BuffWaitMoveTimer']    = {
        DisplayName = "Buff Wait Timer",
        Category = "Buffs",
        Index = 2,
        Tooltip = "Seconds to wait after stoping movement before doing buffs.",
        Default = 5,
        Min = 0,
        Max = 60,
        ConfigType = "Advanced",
        FAQ = "Why am I trying to buff every time we stop moving?",
        Answer = "You can set the [BuffWaitMoveTimer] option to the number of seconds to wait after stopping movement before doing buffs.",
    },
    ['MountItem']            = {
        DisplayName = "Mount Item",
        Category = "Buffs",
        Index = 6,
        Tooltip = "Item to use to cast mount",
        Type = "ClickyItem",
        Default = "",
        ConfigType = "Normal",
        FAQ = "How do I automate using mounts?",
        Answer = "You can set the [MountItem] option to the name of the item you would like to use to cast mount.\n" ..
            "Also set the [DoMount] option to 'For use as mount' to enable using mounts.",
    },
    ['DoMount']              = {
        DisplayName = "Summon Mount:",
        Category = "Buffs",
        Index = 5,
        Tooltip = "Choose how/when to use mounts.",
        Type = "Combo",
        ComboOptions = { 'Never', 'For use as mount', 'For buff only', },
        Default = 1,
        Min = 1,
        Max = 3,
        ConfigType = "Normal",
        FAQ = "How do I automate using mounts?",
        Answer = "You can set the [MountItem] option to the name of the item you would like to use to cast mount.\n" ..
            "Also set the [DoMount] option to 'For use as mount' to enable using mounts.",
    },
    ['ShrinkItem']           = {
        DisplayName = "Shrink Item",
        Category = "Buffs",
        Index = 8,
        Tooltip = "Item to use to Shrink yourself",
        Type = "ClickyItem",
        Default = "",
        ConfigType = "Normal",
        FAQ = "How do I automate using Shrink Items?",
        Answer = "You can set the [ShrinkItem] option to the name of the item you would like to use to shrink yourself.",
    },
    ['DoShrink']             = {
        DisplayName = "Do Shrink",
        Category = "Buffs",
        Index = 7,
        Tooltip = "Enable auto shrinking",
        Default = false,
        ConfigType = "Normal",
        FAQ = "How do I automatically shrink myself?",
        Answer = "You can set the [DoShrink] option to true to automatically shrink yourself." ..
            "You can also set the [ShrinkItem] option to the name of the item you would like to use to shrink yourself.",
    },
    ['BuffRezables']         = {
        DisplayName = "Buff Rezables",
        Category = "Buffs",
        Index = 3,
        Tooltip =
        "If a PC has a corpse near us, buff them even though they are likely to get rezed. (Note: If disabled, they may still be receiving group buffs aimed at those without corpses.)",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why am I buffing the people before they are rezzed?",
        Answer =
        "You can set the [BuffRezables] option to false to skip buffing the people who have corpses nearby, but note they may receive group buffs aimed at those without corpses.",
    },
    ['UseCounterActions']    = {
        DisplayName = "Use Aureate's Bane", --this can be freely changed later if another system is added. Avoiding confusion for now.
        Category = "Buffs",
        Index = 4,
        Tooltip =
        "Automatically use counter actions (such as the Aureate's Bane AA to counter Curse of Subjugation in TOB zones.",
        Default = (mq.TLO.MacroQuest.BuildName() or ""):lower() ~= "emu",
        FAQ = "How do I get rid of the TOB Debuff, Curse of Subjugation?",
        Answer =
        "If you select to Use Aureate's Bane on the Buff Tab of the main config options, you will attempt to clear Curse of Subjugation automatically.",
    },
    ['BreakInvisForSay']     = {
        DisplayName = "Break Invis for Say Commands",
        Category = "Buffs",
        Index = 9,
        Tooltip = "Break Invis as part of /rgl say, qsay or rsay commands.",
        Default = false,
    },

    -- [ HEAL/REZ] --
    ['MaxHealPoint']         = {
        DisplayName = "Healing Threshold",
        Category = "Heal/Rez",
        Index = 1,
        Tooltip = "Minimum PctHPs to check if a target needs healing.",
        Default = 90,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "Why am I not healing?",
        Answer = "You can set the [MaxHealPoint] option to the percent health you would like to start healing at.",
    },
    ['LightHealPoint']       = {
        DisplayName = "Light Heal Point",
        Category = "Heal/Rez",
        Index = 2,
        Tooltip = "Minimum PctHPs to use the Light Heal Rotation.",
        Default = mq.TLO.Me.Class.ShortName() == "CLR" and 95 or 90,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
        FAQ = "Why am I not healing with my LIGHT HEAL?",
        Answer = "You can set the [LightHealPoint] option to the percent health you would like to start using the Light Heal Rotation at.",
    },
    ['MainHealPoint']        = {
        DisplayName = "Main Heal Point",
        Category = "Heal/Rez",
        Index = 3,
        Tooltip = "Minimum PctHPs to use the Main Heal Rotation.",
        Default = 80,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I not healing?",
        Answer = "You can set the [MainHealPoint] option to the percent health you would like to start healing at.",
    },
    ['BigHealPoint']         = {
        DisplayName = "Big Heal Point",
        Category = "Heal/Rez",
        Index = 4,
        Tooltip = "Minimum PctHPs to use the Big Heal Rotation.",
        Default = 50,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I not healing with my BIG HEAL?",
        Answer = "You can set the [BigHealPoint] option to the percent health you would like to start using the Big Heal Rotation at.",
    },
    ['GroupHealPoint']       = {
        DisplayName = "Group Heal Point",
        Category = "Heal/Rez",
        Index = 5,
        Tooltip = "Minimum PctHPs to use the Group Heal Rotation.",
        Default = 75,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I not using my Group heals?",
        Answer = "You can set the [GroupHealPoint] option to the percent health you would like to start using the Group Heal Rotation at.\n" ..
            "You can also set the [GroupInjureCnt] option to the number of group members that must be under the above threshold.",
    },
    ['GroupInjureCnt']       = {
        DisplayName = "Group Injured Count",
        Category = "Heal/Rez",
        Index = 6,
        Tooltip = "Number of group members that must be under the above threshold.",
        Default = 3,
        Min = 1,
        Max = 5,
        ConfigType = "Advanced",
        FAQ = "Why am I not using my Group heals?",
        Answer = "You can set the [GroupInjureCnt] option to the number of group members that must be under the [GroupHealPoint] threshold.",
    },
    ['DoPetHeals']           = {
        DisplayName = "Heal Pets as PCs",
        Category = "Heal/Rez",
        Index = 7,
        Tooltip = "Treat pets as valid targets for PC healing rotations. Please note that many pet classes may use their pet heal abilities even with this off.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why am I not healing pets?",
        Answer = "You can set the [DoPetHeals] option to true to heal pets in your group.",
    },
    ['PetHealPoint']         = {
        DisplayName = "Pet Heal Point",
        Category = "Heal/Rez",
        Index = 8,
        Tooltip = "The min HP to consider pets as valid targets for PC healing rotations.",
        Default = 50,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
        FAQ = "Why am I not healing pets?",
        Answer = "You can set the [PetHealPoint] option to the percent health you would like to start using the Pet Heal Rotation at.\n" ..
            "You also need to set the [DoPetHeals] option to true to heal pets in your group.",
    },
    ['BreakInvisForHealing'] = {
        DisplayName = "Break Invis",
        Category = "Heal/Rez",
        Index = 9,
        Tooltip = "Break invis to heal, cure and rez when out of combat (Does not affect combat actions).",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why aren't I being healed outside of combat?",
        Answer = "Outside of combat, healers won't break invis to heal unless the \"Break Invis\" option is toggled in the Heal/Rez settings.",
    },
    ['PriorityHealing']      = {
        DisplayName = "Priority Healing",
        Category = "Heal/Rez",
        Index = 10,
        Tooltip = "Standby for healing over engaging in combat actions.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why are my healers attacking the mob and not healing?",
        Answer = "You can set the [PriorityHealing] option to true to enforce healing over engaging in combat actions.",
    },
    ['HealOutside']          = {
        DisplayName = "Heal Outside",
        Category = "Heal/Rez",
        Index = 11,
        Tooltip =
        "If enabled this setting will heal friendly xtargets (even if not in group) and attempt to rez dannet peers, raid/guildmates, and anyone in the outside assist list.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why are my healers attacking the mob and not healing?",
        Answer = "You can set the [PriorityHealing] option to true to enforce healing over engaging in combat actions.",
    },
    ['DoCureSpells']         = {
        DisplayName = "Do Cure Spells",
        Category = "Heal/Rez",
        Index = 12,
        Tooltip = "Use Cure spells to clear detrimental effects from your group or yourself.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "I want to control cures manually or with an outside script or LEM. Can I do that??",
        Answer = "Yes, you can turn off Cure Spell or Cure AA use (individually) on the Main Heal/Rez tab (Advanced Option).",
    },
    ['DoCureAA']             = {
        DisplayName = "Do Cure AA",
        Category = "Heal/Rez",
        Index = 13,
        Tooltip = "Use Cure AA to clear detrimental effects from your group or yourself.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I wasting Radiant Cure?",
        Answer = "You can adjust whether we will attempt to cure effects with AA or spells on the Main Heal/Rez tab (Advanced Option).",
    },
    ['CureInterval']         = {
        DisplayName = "Cure Check Interval",
        Category = "Heal/Rez",
        Index = 14,
        Tooltip = "Perform check to see if cures are needed every X seconds. ***WARNING: RESOURCE INTENSIVE*** Default: 5",
        Default = 5,
        Min = 1,
        Max = 30,
        ConfigType = "Advanced",
        FAQ = "Why am I not curing fast or often enough?",
        Answer = "You can set the [CureInterval] option to the number of seconds to wait between checking for cures." ..
            "Lowering this number will increase the frequency of cure checks.",
    },
    ['DoRez']                = {
        DisplayName = "Do Rez",
        Category = "Heal/Rez",
        Index = 15,
        Tooltip = "Use Rezes. If disabled, no rez spells will be used at any time.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I not rezzing?",
        Answer = "You can set the [DoRez] option to true to use Rez while in combat.",
    },
    ['DoBattleRez']          = {
        DisplayName = "Do Battle Rez",
        Category = "Heal/Rez",
        Index = 16,
        Tooltip = "Use Rez while in combat",
        Default = mq.TLO.Me.Class.ShortName():lower() == "clr",
        ConfigType = "Advanced",
        FAQ = "Why am I not rezzing in combat?",
        Answer = "You can set the [DoBattleRez] option to true to use Rez while in combat.",
    },
    ['ConCorpseForRez']      = {
        DisplayName = "Check for Previous Rez",
        Category = "Heal/Rez",
        Index = 17,
        Tooltip = "If this setting is enabled, we will attempt to con a corpse and rez only if that corpse has not yet taken one.",
        Default = (mq.TLO.MacroQuest.BuildName() or ""):lower() == "emu",
        ConfigType = "Advanced",
        FAQ = "Why am I conning corpses? I play on a server with no exp penalty, or where we don't need to loot corpses.",
        Answer = "The Check for Previous Rez setting is enabled by default on emu, this can be adjusted on the Heal/Rez options tab.",
    },
    ['RezInZonePC']          = {
        DisplayName = "Rez In-Zone PCs",
        Category = "Heal/Rez",
        Index = 18,
        Tooltip = "Rez corpses of live PCs in the zone (If disabled, we will only rez corpses of PCs not in our current zone).",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why would I want (or not want) to rez corpses of PCs that are in-zone with us already?",
        Answer = "Emu servers have various rules, such as no xp loss on death, or not dropping items to your corpse\n" ..
            "Depending in the server, various combinations of rez settings may be required for the best play experience.",
    },
    ['RetryRezDelay']        = {
        DisplayName = "Retry Rez Delay",
        Category = "Heal/Rez",
        Index = 19,
        Tooltip = "Attempt to rez a corpse every X seconds.",
        Default = 6,
        Min = 1,
        Max = 60,
        ConfigType = "Advanced",
        FAQ = "Why am I trying to rez the same corpse over and over?",
        Answer = "You can set the [RetryRezDelay] option to the number of seconds to wait between attempting to rez a corpse.",
    },
    ['InstantRelease']       = {
        DisplayName = "Instant Release",
        Category = "Heal/Rez",
        Index = 20,
        Tooltip = "Instantly release when you die.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why am I not releasing instantly after death?",
        Answer = "You can set the [InstantRelease] option to true to instantly release when you die.",
    },

    -- [ BURNS ] --
    ['BurnAuto']             = {
        DisplayName = "Use Auto Burn",
        Category = "Burns",
        Index = 1,
        Tooltip = "Use Burn rotations when the conditions below are met.",
        Default = true,
        ConfigType = "Normal",
        FAQ = "Why am I not burning?",
        Answer = "You can set the [BurnAuto] option to true to automatically burn when the conditions are met.",
    },
    ['BurnAlways']           = {
        DisplayName = "Auto Burn: Always",
        Category = "Burns",
        Index = 2,
        Tooltip = "Automatically use Burn rotations on any/every target.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "How do I force Burns on every target?",
        Answer = "You can set the [BurnAlways] option to true to burn on any/every target.",
    },
    ['BurnMobCount']         = {
        DisplayName = "Auto Burn: Mob Threshold",
        Category = "Burns",
        Index = 4,
        Tooltip = "Automatically use Burn rotations when we are fighting x number of haters.",
        Default = 3,
        Min = 1,
        Max = 10,
        ConfigType = "Advanced",
        FAQ = "I only want to burn when there are a lot of mobs, how do I do this?",
        Answer = "You can set the [BurnMobCount] option to the number of haters before we start burning.",
    },
    ['BurnNamed']            = {
        DisplayName = "Auto Burn: Named",
        Category = "Burns",
        Index = 5,
        Tooltip = "Automatically use Burn rotations when we are fighting a named mob(must be present in RGMerc Named List or SpawnMaster ini).",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why am I not burning the named?",
        Answer = "You can set the [BurnNamed] option to true to automatically burn named mobs.",
    },
    ['NamedMinLevel']        = {
        DisplayName = "Named Min Level",
        Category = "Burns",
        Index = 5,
        Tooltip = "The minimum level we will treat a Named as a threat (if below this level, we will treat them as trash mobs).",
        Default = 1,
        Min = 1,
        Max = 150,
        ConfigType = "Advanced",
        FAQ = "Why am I using burns on weak, low-level named?",
        Answer = "Adjust the min level to treat a named as such on the Burns Tab.",
    },

    --[ EVENTS ] --
    ['HandleCantSeeTarget']  = {
        DisplayName = "Handle Cannot See Target",
        Category = "Events",
        Tooltip = "If you get a cannot see your target message this will try to correct for it.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "When I cannot see my target my characters [do or do not] move to try to fix it.",
        Answer = "You can enabled or disable [HandleCantSeeTarget] to tell rgmercs if it should try to handle cannot see target messages.",
    },
    ['HandleTooClose']       = {
        DisplayName = "Handle Too Close",
        Category = "Events",
        Tooltip = "If you get a target too close message this will try to correct for it.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "When my target is too close, my characters [do or do not] move to try to fix it.",
        Answer = "You can enabled or disable [HandleTooClose] to tell rgmercs if it should try to handle target too close messages.",
    },
    ['HandleTooFar']         = {
        DisplayName = "Handle Too Far",
        Category = "Events",
        Tooltip = "If you get a target too far message this will try to correct for it.",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "When my target is too far, my characters [do or do not] move to try to fix it.",
        Answer = "You can enabled or disable [HandleTooFar] to tell rgmercs if it should try to handle target too far messages.",
    },

    -- [ UI ] --
    ['DisplayManualTarget']  = {
        DisplayName = "Display Manual Target",
        Category = "UI",
        Tooltip = "If you have no auto target, enabling this will show information about your current manual target in the UI.",
        Default = false,
        FAQ = "When my auto target is empty how can I see information about my current manually set target?",
        Answer = "You can enabled [DisplayManualTarget] and it will show your manual target in the UI if there is no auto target.",
    },
    ['BgOpacity']            = {
        DisplayName = "Background Opacity",
        Category = "UI",
        Tooltip = "Opacity for the RGMercs UI",
        Default = 100,
        Min = 20,
        Max = 100,
        FAQ = "How do I change the background opacity?",
        Answer = "You can set the [BgOpacity] option to the opacity for the RGMercs UI.",
    },
    ['ShowAllOptionsMain']   = {
        DisplayName = "Show All Options on Main",
        Category = "UI",
        Tooltip = "Show all options on the main panel",
        Default = true,
        FAQ = "There are a lot of options on the main panel, how do I hide some of them?",
        Answer = "You can set the [ShowAllOptionsMain] option to false to hide some of the options on the main panel.",
    },
    ['FrameEdgeRounding']    = {
        DisplayName = "Frame Edge Rounding",
        Category = "UI",
        Tooltip = "Frame Edge Rounding for the RGMercs UI",
        Default = 6,
        Min = 0,
        Max = 50,
        FAQ = "I like round corners on my UI, how do I change this?",
        Answer = "You can set the [FrameEdgeRounding] option to the frame edge rounding for the RGMercs UI.",
    },
    ['ScrollBarRounding']    = {
        DisplayName = "Scroll Bar Rounding",
        Category = "UI",
        Tooltip = "Frame Edge Rounding for the RGMercs UI",
        Default = 10,
        Min = 0,
        Max = 50,
        FAQ = "I like round ScrollBars on my UI, how do I change this?",
        Answer = "You can set the [ScrollBarRounding] option to the Scroll Bar rounding for the RGMercs UI.",
    },
    ['ShowAdvancedOpts']     = {
        DisplayName = "Show Advanced Options",
        Category = "UI",
        Tooltip = "Show Advanced Options",
        Type = "Custom",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "How do I see the Advanced Options?",
        Answer = "You can set the [ShowAdvancedOpts] option to true to show the Advanced Options.",
    },
    ['EscapeMinimizes']      = {
        DisplayName = "Minimize on Escape",
        Category = "UI",
        Tooltip = "Minimizes the window if focused and Escape is pressed",
        Default = false,
        ConfigType = "Normal",
        FAQ = "How do I minimize the window?",
        Answer = "You can set the [EscapeMinimizes] option to true to minimize the window if focused and Escape is pressed.\n" ..
            "You can also click the minimize button on the window to minimize it.",
    },
    ['AlwaysShowMiniButton'] = {
        DisplayName = "Always show Mini Button",
        Category = "UI",
        Tooltip = "Always show the Mini button.",
        Default = false,
        ConfigType = "Normal",
        FAQ = "How do I keep the mini button on the screen as a toggle?",
        Answer = "You can set the [AlwaysShowMiniButton] option to true and the button will stay on screen at all times.",
    },
    ['PopOutForceTarget']    = {
        DisplayName = "Pop Out Force Target",
        Type = "Custom",
        Category = "Custom",
        Tooltip = "Pop out the Force Target into it's own Window",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "How do I pop out the Force Target?",
        Answer =
        "You can set the click the popout button at the top of a tab or heading to pop it into its own window.\n Simply close the window and it will snap back to the main window.",
    },
    ['PopOutConsole']        = {
        DisplayName = "Pop Out Console",
        Type = "Custom",
        Category = "Custom",
        Tooltip = "Pop out the Console into it's own Window",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "How do I pop out the Console?",
        Answer =
        "You can set the click the popout button at the top of a tab or heading to pop it into its own window.\n Simply close the window and it will snap back to the main window.",
    },
    ['MainWindowLocked']     = {
        DisplayName = "Main Window Locked",
        Category = "UI",
        Tooltip = "Lock UI",
        Default = false,
        Type = "Custom",
        FAQ = "How do I lock the Main UI Window in place?",
        Answer = "You can click the Lock Icon on the main UI panel or toggle the [MainWindowLocked] option to true.",
    },
    ['FullUI']               = {
        DisplayName = "Use Full UI",
        Category = "UI",
        Tooltip = "Toggle between Full UI and a Simple UI [Experimental]",
        Default = true,
        FAQ = "The UI is overwhelming how can I make it simpler?",
        Answer = "You can click off the Use Full UI option under UI settings for a simpler version of the UI.",
    },
    ['ShowDebugTiming']      = {
        DisplayName = "Show Roation Debug Timing",
        Category = "UI",
        ConfigType = "Advanced",
        Tooltip = "Enable displaying the timing of each rotation step.",
        Default = false,
    },

    -- [ Debug ] --
    ['LogLevel']             = {
        DisplayName = "Log Level",
        Category = "Debug",
        Tooltip = "1 = Errors, 2 = Warnings, 3 = Info, 4 = Debug, 5 = Verbose",
        Type = "Custom",
        Default = 3,
        Min = 1,
        Max = 5,
        ConfigType = "Advanced",
        FAQ = "Why am I not seeing any logs?",
        Answer = "You can set the [LogLevel] option to the level of logs you would like to see.\n" ..
            "Each level shows more information than the previous.",
    },
    ['LogToFile']            = {
        DisplayName = "Log To File",
        Category = "Debug",
        Tooltip = "Write all logs to the mqlog file.",
        Type = "Custom",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "How do I log to a file?",
        Answer = "You can set the [LogToFile] option to true to write all logs to the mqlog file.",
    },

    -- [ ANNOUNCEMENTS ] --
    ['AnnounceTarget']       = {
        DisplayName = "Announce Target",
        Category = "Announcements",
        Tooltip = "Announces Target over DanNet in kissassist format, incase you are running a mixed set on your group.Config",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing the target?",
        Answer = "You can set the [AnnounceTarget] option to true to announce the target over DanNet in kissassist format.",
    },
    ['AnnounceTargetGroup']  = {
        DisplayName = "Announce Target to Group",
        Category = "Announcements",
        Tooltip = "Announces Target over /gsay",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing the target to the group?",
        Answer = "You can set the [AnnounceTargetGroup] option to true to announce the target over /gsay.",
    },
    ['MezAnnounce']          = {
        DisplayName = "Mez Announce",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce mez casts.",
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing mez casts and breaks?",
        Answer = "You can set the [MezAnnounce] option to true to announce mez information.",
    },
    ['MezAnnounceGroup']     = {
        DisplayName = "Mez Announce to Group",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce mez casts In group.",
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing mez casts and breaks to the group?",
        Answer = "You can set the [MezAnnounceGroup] option to true to announce mez information in group.",
    },
    ['CharmAnnounce']        = {
        DisplayName = "Charm Announce",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce Charm casts.",
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing Charm casts?",
        Answer = "You can set the [CharmAnnounce] option to true to announce Charm casts.",
    },
    ['CharmAnnounceGroup']   = {
        DisplayName = "Charm Announce to Group",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce Charm casts In group.",
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing Charm casts to the group?",
        Answer = "You can set the [CharmAnnounceGroup] option to true to announce Charm casts in group.",
    },
    ['HealAnnounce']         = {
        DisplayName = "Heal Announce",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce Heal casts.",
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing Heal casts?",
        Answer = "You can set the [HealAnnounce] option to true to announce Heal casts.",
    },
    ['HealAnnounceGroup']    = {
        DisplayName = "Heal Announce to Group",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce Heal casts In group.",
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing Heal casts to the group?",
        Answer = "You can set the [HealAnnounceGroup] option to true to announce Heal casts in group.",
    },
    ['CureAnnounce']         = {
        DisplayName = "Cure Announce",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce Cure casts.",
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing Cure casts?",
        Answer = "You can set the [CureAnnounce] option to true to announce Cure casts.",
    },
    ['CureAnnounceGroup']    = {
        DisplayName = "Cure Announce to Group",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce Cure casts In group.",
        ConfigType = "Advanced",
        FAQ = "Why am I not announcing Cure casts to the group?",
        Answer = "You can set the [CureAnnounceGroup] option to true to announce Cure casts in group.",
    },
    ['ReagentAnnounce']      = {
        DisplayName = "Reagent Announce",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce a failed Reagent check in dannet.",
        ConfigType = "Advanced",
        FAQ = "What is a Reagent check?",
        Answer = "A reagent is a required material spell component (bone chips, peridots, etc).\n" ..
            "We check to ensure we have reagents before we will cast spells requiring them.",
    },
    ['ReagentAnnounceGroup'] = {
        DisplayName = "Reagent Announce to Group",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce a failed Reagent check in group. (Warning: Not recommended due to message spam!)",
        ConfigType = "Advanced",
        FAQ = "What is a Reagent Announce?",
        Answer = "When a PC attempts to cast a spell he doesn't have a reagent for, he will announce this if the setting is enabled.",
    },
    ['PullAnnounce']         = {
        DisplayName = "Pull Announce",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce pull-related messages in dannet.",
        ConfigType = "Advanced",
        FAQ = "How can I display a little more information about pulling module status?",
        Answer = "You can enable Pull Announce in the Announcements tabs to be give verbose messages via DanNet.",
    },
    ['PullAnnounceGroup']    = {
        DisplayName = "Pull Announce to Group",
        Category = "Announcements",
        Default = false,
        Tooltip = "Set to announce pull-related messages in group. (Warning: Not recommended due to message spam!)",
        ConfigType = "Advanced",
        FAQ = "Why are these messages spamming my group or dannet channel?",
        Answer = "You should check the Announcements tab to ensure that those settings are to your taste.",
    },
}

Config.DefaultCategories = Set.new({})
for k, v in pairs(Config.DefaultConfig) do
    if v.Type ~= "Custom" then
        Config.DefaultCategories:add(v.Category)
    end
    Config.FAQ[k] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', Settings_Used = k, }
end

Config.CommandHandlers = {}

function Config:GetConfigFileName()
    local oldFile = mq.configDir ..
        '/rgmercs/PCConfigs/RGMerc_' .. self.Globals.CurServer .. "_" .. self.Globals.CurLoadedChar .. '.lua'
    local newFile = mq.configDir ..
        '/rgmercs/PCConfigs/RGMerc_' .. self.Globals.CurServer .. "_" .. self.Globals.CurLoadedChar .. "_" .. self.Globals.CurLoadedClass:lower() .. '.lua'

    if Files.file_exists(newFile) then
        return newFile
    end

    Files.copy_file(oldFile, newFile)

    return newFile
end

function Config:SaveSettings()
    mq.pickle(self:GetConfigFileName(), self.settings)
    Logger.set_log_level(Config:GetSetting('LogLevel'))
    Logger.set_log_to_file(Config:GetSetting('LogToFile'))
end

function Config:LoadSettings()
    self.Globals.CurLoadedChar  = mq.TLO.Me.DisplayName()
    self.Globals.CurLoadedClass = mq.TLO.Me.Class.ShortName()
    self.Globals.CurServer      = mq.TLO.EverQuest.Server():gsub(" ", "")
    Logger.log_info(
        "\ayLoading Main Settings for %s!",
        self.Globals.CurLoadedChar)

    local needSave = false

    local config, err = loadfile(self:GetConfigFileName())
    if err or not config then
        Logger.log_error("\ayUnable to load global settings file(%s), creating a new one!",
            self:GetConfigFileName())
        self.settings = {}
        needSave = true
    else
        self.settings = config()
    end

    local settingsChanged = false

    -- Setup Defaults
    self.settings, settingsChanged = Config.ResolveDefaults(Config.DefaultConfig, self.settings)

    if needSave or settingsChanged then
        self:SaveSettings()
    end

    -- setup our script path for later usage since getting it kind of sucks, but only on the first run (personas)
    if Config.Globals.ScriptDir == "" then
        local info = debug.getinfo(2, "S")
        local scriptDir = info.short_src:sub(info.short_src:find("lua") + 4):sub(0, -10)
        Config.Globals.ScriptDir = string.format("%s/%s", mq.TLO.Lua.Dir(), scriptDir)
    end

    return true
end

function Config:UpdateCommandHandlers()
    self.CommandHandlers = {}
    local startTime = mq.gettime()
    local submoduleSettings = Modules:ExecAll("GetSettings")
    local submoduleDefaults = Modules:ExecAll("GetDefaultSettings")


    submoduleSettings["Core"] = self.settings
    submoduleDefaults["Core"] = Config.DefaultConfig

    for moduleName, moduleSettings in pairs(submoduleSettings) do
        local modstartTime = mq.gettime()
        for setting, _ in pairs(moduleSettings or {}) do
            local setstartTime = mq.gettime()
            local handled, usageString = self:GetUsageText(setting or "", true, submoduleDefaults[moduleName] or {})
            local setendTime = mq.gettime()
            Logger.log_super_verbose("\ag[Config] \ayGetUsageText() took %.3f seconds for %s.%s", (setendTime - setstartTime) / 1000, moduleName, setting)

            if handled then
                self.CommandHandlers[setting:lower()] = {
                    name = setting,
                    usage = usageString,
                    subModule = moduleName,
                    category = submoduleDefaults[moduleName][setting].Category,
                    about = submoduleDefaults[moduleName][setting].Tooltip,
                }
            end
        end
        local modendTime = mq.gettime()
        Logger.log_debug("\ag[Config] \ayGetSettings() took %.3f seconds to process module %s.", (modendTime - modstartTime) / 1000, moduleName)
    end

    local endTime = mq.gettime()

    Logger.log_debug("\ag[Config] \ayUpdateCommandHandlers() took %.3f seconds to execute for %d modules.", (endTime - startTime) / 1000, #submoduleSettings)
end

---@param config string
---@param showUsageText boolean
---@param defaults table
---@return boolean
---@return string
function Config:GetUsageText(config, showUsageText, defaults, valueOnly)
    local handledType = false
    local usageString = showUsageText and string.format("/rgl set %s ", Strings.PadString(config, 5, false)) or ""
    local configData = defaults[config]

    local rangeText = ""
    local defaultText = ""
    local currentText = ""

    if type(configData.Default) == 'number' then
        rangeText = string.format("\aw[\a-yRange:\a-y%d\aw-\a-y%d\ax]", configData.Min or 0, configData.Max or 999)
        defaultText = string.format("[\a-tDefault: %d\ax]", configData.Default)
        currentText = string.format("%d", Config:GetSetting(config))
        handledType = true
    elseif type(configData.Default) == 'boolean' then
        rangeText = string.format("\aw[\a-yType:\a-yon\aw|\a-yoff\ax]")
        ---@diagnostic disable-next-line: param-type-mismatch
        defaultText = string.format("[\a-tDefault: %s\ax]", Strings.BoolToString(configData.Default))
        currentText = (string.format("%s", Strings.BoolToString(Config:GetSetting(config))))
        handledType = true
    elseif type(configData.Default) == 'string' then
        rangeText = string.format("\aw<\"str\">")
        defaultText = string.format("[\a-tDefault: \"%s\"\ax]", configData.Default)
        currentText = string.format("%s", Config:GetSetting(config))
        handledType = true
    end

    if valueOnly then
        usageString = usageString ..
            string.format("%s",
                Strings.PadString(currentText, 5, false)
            )
    else
        usageString = usageString ..
            string.format("  %s   %s %s", Strings.PadString(currentText, 5, false), Strings.PadString(rangeText, 5, false), Strings.PadString(defaultText, 5, false)
            )
    end

    return handledType, usageString
end

function Config:GetSettings()
    return self.settings
end

function Config:SettingsLoaded()
    return self.settings ~= nil
end

--- Retrieves a specified setting.
--- @param setting string The name of the setting to retrieve.
--- @param failOk boolean? If true, the function will not raise an error if the setting is not found.
--- @return any The value of the setting, or nil if the setting is not found and failOk is true.
function Config:GetSetting(setting, failOk)
    local ret = { module = "Base", value = self:GetSettings()[setting], }

    -- Speed up lookups because they happen often and we do not need to spam about multiple keys every frame, just the one time.
    if Config.TempSettings.SettingToModuleCache[setting] ~= nil then
        if Config.TempSettings.SettingToModuleCache[setting] == "Base" then
            return self:GetSettings()[setting]
        end

        local settings = Modules:ExecModule(Config.TempSettings.SettingToModuleCache[setting], "GetSettings")
        return settings[setting]
    end

    if ret.value ~= nil then Config.TempSettings.SettingToModuleCache[setting] = "Base" end

    -- if we found it in the Global table we should alert if it is duplicated anywhere
    -- else as that could get confusing.
    if Modules then -- this could be run before we are fully done loading.
        local submoduleSettings = Modules:ExecAll("GetSettings")
        for name, settings in pairs(submoduleSettings) do
            if settings[setting] ~= nil then
                if not ret.value then
                    ret = { module = name, value = settings[setting], }
                    Config.TempSettings.SettingToModuleCache[setting] = name
                else
                    Logger.log_error(
                        "\ay[Setting] \arError: Key %s exists in multiple settings tables: \aw%s \arand \aw%s! Returning first but this should be fixed!",
                        setting,
                        ret.module, name)
                end
            end
        end
    end


    if ret.value ~= nil then
        Logger.log_super_verbose("\ag[Setting] \at'%s' \agfound in module \am%s", setting, ret.module)
    else
        if not failOk then
            Logger.log_error("\ag[Setting] \at'%s' \aywas requested but not found in any module!", setting)
        end
    end

    return ret.value
end

--- Validates and sets a configuration setting for a specified module.
--- @param module string: The name of the module for which the setting is being configured.
--- @param setting string: The name of the setting to be validated and set.
--- @param value any: The value to be assigned to the setting.
--- @return boolean|string|number|nil: Returns a valid value for the setting.
function Config.MakeValidSetting(module, setting, value)
    local defaultConfig = Config.DefaultConfig

    if module ~= "Core" then
        defaultConfig = Modules:ExecModule(module, "GetDefaultSettings")
    end

    if type(defaultConfig[setting].Default) == 'number' then
        value = tonumber(value)
        if not value or value > (defaultConfig[setting].Max or 999) or value < (defaultConfig[setting].Min or 0) then
            Logger.log_info("\ayError: Invalid or out-of-range value supplied for %s, falling back to previous value.", setting)
            local _, update = Config:GetUsageText(setting, true, defaultConfig)
            Logger.log_info(update)
            return nil
        end

        return value
    elseif type(defaultConfig[setting].Default) == 'boolean' then
        local boolValue = false
        if value == true or value == "true" or value == "on" or (tonumber(value) or 0) >= 1 then
            boolValue = true
        end

        return boolValue
    elseif type(defaultConfig[setting].Default) == 'string' then
        return value
    end

    return nil
end

--- Converts a given setting name into a valid format and module name
--- This function ensures that the setting name adheres to the required format for further processing.
--- @param setting string The original setting name that needs to be validated and formatted.
--- @return string, string The module of the setting and The validated and formatted setting name.
function Config:MakeValidSettingName(setting)
    for s, _ in pairs(self:GetSettings()) do
        if s:lower() == setting:lower() then return "Core", s end
    end

    local submoduleSettings = Modules:ExecAll("GetSettings")
    for moduleName, settings in pairs(submoduleSettings) do
        for s, _ in pairs(settings) do
            if s:lower() == setting:lower() then return moduleName, s end
        end
    end
    return "None", "None"
end

---Sets a setting from either in global or a module setting table.
--- @param setting string: The name of the setting to be updated.
--- @param value any: The new value to assign to the setting.
function Config:SetSetting(setting, value)
    local defaultConfig = Config.DefaultConfig
    local settingModuleName = "Core"
    local beforeUpdate = ""

    settingModuleName, setting = self:MakeValidSettingName(setting)

    if settingModuleName == "Core" then
        local cleanValue = Config.MakeValidSetting("Core", setting, value)
        _, beforeUpdate = Config:GetUsageText(setting, false, defaultConfig, true)
        if cleanValue ~= nil then
            self:GetSettings()[setting] = cleanValue
            self:SaveSettings()
        end
    elseif settingModuleName ~= "None" then
        local settings = Modules:ExecModule(settingModuleName, "GetSettings")
        if settings[setting] ~= nil then
            defaultConfig = Modules:ExecModule(settingModuleName, "GetDefaultSettings")
            _, beforeUpdate = Config:GetUsageText(setting, false, defaultConfig, true)
            local cleanValue = Config.MakeValidSetting(settingModuleName, setting, value)
            if cleanValue ~= nil then
                settings[setting] = cleanValue
                Modules:ExecModule(settingModuleName, "SaveSettings", false)
            end
        end
    else
        Logger.log_error("Setting %s was not found!", setting)
        return
    end

    local _, afterUpdate = Config:GetUsageText(setting, false, defaultConfig)
    Logger.log_info("(%s) \ag%s\aw is now:\ax %-5s \ay[Previous:\ax %s\ay]", settingModuleName, setting, afterUpdate, beforeUpdate)
end

--- Resolves the default values for a given settings table.
--- This function takes a table of default values and a table of settings,
--- and ensures that any missing settings are filled in with the default values.
---
--- @param defaults table The table containing default values.
--- @param settings table The table containing user-defined settings.
--- @return table, boolean The settings table with defaults applied where necessary. A bool if the table changed and requires saving.
function Config.ResolveDefaults(defaults, settings)
    -- Setup Defaults
    local changed = false
    for k, v in pairs(defaults) do
        if settings[k] == nil then settings[k] = v.Default end

        if type(settings[k]) ~= type(v.Default) then
            Logger.log_info("\ayData type of setting [\am%s\ay] has been deprecated -- resetting to default.", k)
            settings[k] = v.Default
            changed = true
        end
    end

    -- Remove Deprecated options
    for k, _ in pairs(settings) do
        if not defaults[k] then
            settings[k] = nil
            Logger.log_info("\aySetting [\am%s\ay] has been deprecated -- removing from your config.", k)
            changed = true
        end
    end

    return settings, changed
end

--- Adds an OA (Outside Assist) with the given name.
--- @param name string: The name of the OA to be added.
function Config:AddOA(name)
    for _, cur_name in ipairs(self:GetSetting('OutsideAssistList') or {}) do
        if cur_name == name then
            return
        end
    end

    table.insert(self:GetSetting('OutsideAssistList'), name)
    self:SaveSettings()
end

--- Deletes the OA with the given ID
--- @param name string The name of the OA to delete
function Config:DeleteOAByName(name)
    for idx, cur_name in ipairs(Config:GetSetting('OutsideAssistList') or {}) do
        if cur_name:lower() == name:lower() then
            self:DeleteOA(idx)
            return
        end
    end
end

--- Deletes the OA with the given ID
--- @param idx number The ID of the OA to delete
function Config:DeleteOA(idx)
    if idx <= #self:GetSetting('OutsideAssistList') then
        Logger.log_info("\axOutside Assist \at%d\ax \ag%s\ax - \arDeleted!\ax", idx,
            self:GetSetting('OutsideAssistList')[idx])
        table.remove(self:GetSetting('OutsideAssistList'), idx)
        self:SaveSettings()
    else
        Logger.log_error("\ar%d is not a valid OA ID!", idx)
    end
end

--- Moves the OA with the given ID up.
--- @param id number The ID of the OA to move up.
function Config:MoveOAUp(id)
    local newId = id - 1

    if newId < 1 then return end
    if id > #self:GetSetting('OutsideAssistList') then return end

    self:GetSetting('OutsideAssistList')[newId], self:GetSetting('OutsideAssistList')[id] =
        self:GetSetting('OutsideAssistList')[id], self:GetSetting('OutsideAssistList')[newId]

    self:SaveSettings()
end

function Config:MoveOADown(id)
    local newId = id + 1

    if id < 1 then return end
    if newId > #self:GetSetting('OutsideAssistList') then return end

    self:GetSetting('OutsideAssistList')[newId], self:GetSetting('OutsideAssistList')[id] =
        self:GetSetting('OutsideAssistList')[id], self:GetSetting('OutsideAssistList')[newId]

    self:SaveSettings()
end

function Config:GetTimeSinceLastMove()
    return os.clock() - self.Globals.LastMove.TimeAtMove
end

function Config:GetCommandHandlers()
    return { module = "Config", CommandHandlers = self.CommandHandlers, }
end

function Config:GetFAQ()
    return
        self.FAQ or {}
end

---@param config string
---@param value any
---@return boolean
function Config:HandleBind(config, value)
    local handled = false

    if not config or config:lower() == "show" or config:len() == 0 then
        self:UpdateCommandHandlers()

        local allModules = {}
        local submoduleSettings = Modules:ExecAll("GetSettings")
        for name, _ in pairs(submoduleSettings) do
            table.insert(allModules, name)
        end
        table.sort(allModules)
        table.insert(allModules, 1, "Core")

        local sortedKeys = {}
        for c, _ in pairs(self.CommandHandlers or {}) do
            table.insert(sortedKeys, c)
        end
        table.sort(sortedKeys)

        local sortedCategories = {}
        for c, d in pairs(self.CommandHandlers or {}) do
            sortedCategories[d.subModule] = sortedCategories[d.subModule] or {}
            if not Tables.TableContains(sortedCategories[d.subModule], d.category) then
                table.insert(sortedCategories[d.subModule], d.category)
            end
        end
        for _, subModuleTable in pairs(sortedCategories) do
            table.sort(subModuleTable)
        end

        for _, subModuleName in ipairs(allModules) do
            local printHeader = true
            for _, c in ipairs(sortedCategories[subModuleName] or {}) do
                local printCategory = true
                for _, k in ipairs(sortedKeys) do
                    local d = self.CommandHandlers[k]
                    if d.subModule == subModuleName and d.category == c then
                        if printHeader then
                            printf("\n\ag%s\aw Settings\n------------", subModuleName)
                            printHeader = false
                        end
                        if printCategory then
                            printf("\n\aoCategory: %s\aw", c)
                            printCategory = false
                        end
                        printf("\am%-20s\aw - \atUsage: \ay%s\aw | %s", d.name,
                            Strings.PadString(d.usage, 100, false), d.about)
                    end
                end
            end
        end
        return true
    end

    if self.CommandHandlers[config:lower()] ~= nil then
        Config:SetSetting(config, value)
        handled = true
    else
        Logger.log_error("\at%s\aw - \arNot a valid config setting!\ax", config)
    end

    return handled
end

function Config:StoreLastMove()
    local me = mq.TLO.Me

    if not self.Globals.LastMove or
        math.abs(self.Globals.LastMove.X - me.X()) > 1 or
        math.abs(self.Globals.LastMove.Y - me.Y()) > 1 or
        math.abs(self.Globals.LastMove.Z - me.Z()) > 1 or
        math.abs(self.Globals.LastMove.Heading - me.Heading.Degrees()) > 1 or
        me.Combat() or
        me.CombatState():lower() == "combat" or
        me.Sitting() ~= self.Globals.LastMove.Sitting then
        self.Globals.LastMove = self.Globals.LastMove or {}
        self.Globals.LastMove.X = me.X()
        self.Globals.LastMove.Y = me.Y()
        self.Globals.LastMove.Z = me.Z()
        self.Globals.LastMove.Heading = me.Heading.Degrees()
        self.Globals.LastMove.Sitting = me.Sitting()
        self.Globals.LastMove.TimeAtMove = os.clock()
    end
end

---@return number
function Config:GetMainOpacity()
    return tonumber((self:GetSettings().BgOpacity or 100) / 100) or 1.0
end

--- Determines if the character should mount.
--- @return boolean True if the character should mount, false otherwise.
function Config.ShouldMount()
    if Config:GetSetting('DoMount') == 1 then return false end

    local passBasicChecks = Config:GetSetting('MountItem'):len() > 0 and mq.TLO.Zone.Outdoor()

    local passCheckMountOne = (not Config:GetSetting('DoMelee') and (Config:GetSetting('DoMount') == 2 and (mq.TLO.Me.Mount.ID() or 0) == 0))
    local passCheckMountTwo = ((Config:GetSetting('DoMount') == 3 and (mq.TLO.Me.Buff("Mount Blessing").ID() or 0) == 0))
    local passMountItemGivesBlessing = false

    if passCheckMountTwo then
        local mountItem = mq.TLO.FindItem(Config:GetSetting('MountItem'))
        if mountItem and mountItem() then
            passMountItemGivesBlessing = mountItem.Blessing() ~= nil
        end
    end

    return passBasicChecks and (passCheckMountOne or (passCheckMountTwo and passMountItemGivesBlessing))
end

--- Determines whether the character should dismount.
--- This function checks certain conditions to decide if the character should dismount.
--- @return boolean True if the character should dismount, false otherwise.
function Config.ShouldDismount()
    return Config:GetSetting('DoMount') ~= 2 and ((mq.TLO.Me.Mount.ID() or 0) > 0)
end

--- Determines if the priority follow condition is met.
--- @return boolean True if the priority follow condition is met, false otherwise.
function Config.ShouldPriorityFollow()
    local chaseTarget = Config:GetSetting('ChaseTarget', true) or "NoOne"

    if chaseTarget == mq.TLO.Me.CleanName() then return false end

    if Config:GetSetting('PriorityFollow') and Config:GetSetting('ChaseOn') then
        local chaseSpawn = mq.TLO.Spawn("pc =" .. chaseTarget)

        if (mq.TLO.Me.Moving() or (chaseSpawn() and (chaseSpawn.Distance() or 0) > Config:GetSetting('ChaseDistance'))) then
            return true
        end
    end

    return false
end

return Config
