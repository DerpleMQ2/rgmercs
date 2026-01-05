local mq                                                 = require('mq')
local Modules                                            = require("utils.modules")
local Tables                                             = require("utils.tables")
local Strings                                            = require("utils.strings")
local Files                                              = require("utils.files")
local Logger                                             = require("utils.logger")
local Comms                                              = require("utils.comms")
local Set                                                = require("mq.Set")

local Config                                             = {
    _version = '1.4',
    _subVersion = "Shattering of Ro",
    _name = "Config",
    _AppName = "RGMercs Lua Edition",
    _author = 'Lead Devs: Derple, Algar',
}
Config.__index                                           = Config
Config.moduleSettings                                    = {}
Config.moduleDefaultSettings                             = {}
Config.moduleTempSettings                                = {}
Config.moduleSettingCategories                           = {}
Config.currentPeer                                       = ""
Config.peerModuleSettings                                = {}
Config.peerModuleDefaultSettings                         = {}
Config.peerModuleSettingCategories                       = {}
Config.FAQ                                               = {}
Config.SettingsLoadComplete                              = false

Config.TempSettings                                      = {}
Config.TempSettings.lastModuleRegisteredTime             = 0
Config.TempSettings.lastHighlightTime                    = os.time()
Config.TempSettings.SettingToModuleCache                 = {}
Config.TempSettings.SettingsLowerToNameCache             = {}
Config.TempSettings.SettingsCategoryToSettingMapping     = {}
Config.TempSettings.PeerModuleSettingsLowerToNameCache   = {}
Config.TempSettings.PeerSettingToModuleCache             = {}
Config.TempSettings.PeerSettingsCategoryToSettingMapping = {}
Config.TempSettings.Peers                                = Set.new({})
Config.TempSettings.PeersHeartbeats                      = {}
Config.TempSettings.LastPeerConfigReceivedTime           = 0
Config.TempSettings.ResetOptionsUIPosition               = false

Config.TempSettings.HighlightedModules                   = Set.new({})

-- Global State
Config.Globals                                           = {}
Config.Globals.MainAssist                                = ""
Config.Globals.ScriptDir                                 = ""
Config.Globals.AutoTargetID                              = 0
Config.Globals.ForceTargetID                             = 0
Config.Globals.ForceCombatID                             = 0
Config.Globals.LastPulledID                              = 0
Config.Globals.IgnoredTargetIDs                          = Set.new({})
Config.Globals.SubmodulesLoaded                          = false
Config.Globals.PauseMain                                 = false
Config.Globals.LastMove                                  = nil
Config.Globals.BackOffFlag                               = false
Config.Globals.InMedState                                = false
Config.Globals.LastPetCmd                                = 0
Config.Globals.LastFaceTime                              = 0
Config.Globals.CurZoneId                                 = mq.TLO.Zone.ID()
Config.Globals.CurInstance                               = mq.TLO.Me.Instance()
Config.Globals.CurLoadedChar                             = mq.TLO.Me.DisplayName()
Config.Globals.CurLoadedClass                            = mq.TLO.Me.Class.ShortName()
Config.Globals.CurServer                                 = mq.TLO.EverQuest.Server()
Config.Globals.CurServerNormalized                       = mq.TLO.EverQuest.Server():gsub(" ", "")
Config.Globals.CastResult                                = 0
Config.Globals.BuildType                                 = mq.TLO.MacroQuest.BuildName()
Config.Globals.Minimized                                 = false
Config.Globals.LastUsedSpell                             = "None"
Config.Globals.CorpseConned                              = false
Config.Globals.RezzedCorpses                             = {}
Config.Globals.SLPeerLooting                             = false

-- Constants
Config.Constants                                         = {}
Config.Constants.SupportedEmuServers                     = Set.new({ "Project Lazarus", "HiddenForest", "EQ Might", })
Config.Constants.LootModuleTypes                         = { 'None', 'LootNScoot', 'SmartLoot', }
Config.Constants.RGCasters                               = Set.new({ "BRD", "BST", "CLR", "DRU", "ENC", "MAG", "NEC", "PAL", "RNG", "SHD",
    "SHM", "WIZ", })
Config.Constants.RGMelee                                 = Set.new({ "BRD", "SHD", "PAL", "WAR", "ROG", "BER", "MNK", "RNG", "BST", })
Config.Constants.RGHybrid                                = Set.new({ "SHD", "PAL", "RNG", "BST", "BRD", })
Config.Constants.RGTank                                  = Set.new({ "WAR", "PAL", "SHD", })
Config.Constants.RGPetClass                              = Set.new({ "BST", "NEC", "MAG", "SHM", "ENC", "SHD", })
Config.Constants.RGNotMezzedAnims                        = Set.new({ 1, 5, 6, 27, 43, 44, 45, 80, 82, 112, 134, 135, })
Config.Constants.ModRods                                 = { "Modulation Shard", "Transvergence", "Modulation", "Modulating", "Azure Mind Crystal", }
Config.Constants.ModRodUse                               = { "Never", "Combat", "Anytime", }
Config.Constants.SpellBookSlots                          = 1120
Config.Constants.CastCompleted                           = Set.new({ "CAST_SUCCESS", "CAST_IMMUNE", "CAST_TAKEHOLD", "CAST_RESISTED", "CAST_RECOVER", })

Config.Constants.CastResults                             = {
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

Config.Constants.CastResultsIdToName                     = {}
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

Config.Constants.SpireChoices      = { "First", "Second", "Third", "Disabled", }

Config.Constants.LastGemRemem      = { "Do Nothing", "Mem Previous Spell", "Mem Loadout Spell", }
Config.Constants.DebuffChoice      = { "Never", "Based on Con Color", "Always", }

Config.Constants.ScanNamedPriority = { "Named", "No Preference", "Non-Named", }
Config.Constants.ScanHPPriority    = { "Lowest HP%", "No Preference", "Highest HP%", }

Config.FAQ                         = {
    [1] = {
        Question = "What do Announcements do?",
        Answer = "  Announcments are used to broadcast the selected options to the DanNet channel. The Group Announce optios will output the announcement to /gsay.",
        Settings_Used = "",
    },
    [2] = {
        Question = "I want to manually control my driver and choose my own targets. What do I need to adjust?",
        Answer = "The following settings may require adjustment to drive yourself:\n\n" ..
            "Targeting:\nAuto Target (controls scanning for combat targets and changing targets to them).\n\n" ..
            "Assisting:\nAuto Engage (controls navigating to targets, sticking, and using melee if enabled).\n\n" ..
            "Positioning:\nFace Target In Combat (Mercs will still assume you are facing properly for abilities that require it!)\n\n" ..
            "Mercs will still manage the action, and we should return to the target you had if needed after a heal, buff, item use, etc. You can pause mercs to take full control." ..
            "These settings and interactions have been recently adjusted, and feedback is requested if you see something not quite right!",
        Settings_Used = "",
    },
    [3] = {
        Question = "How do I force auto combat on a target that isn't aggressive or isn't hostile?",
        Answer = "This is accomplished with the /rgl forcecombat <id?> command:\n\n" ..
            "The command accepts a target ID, and will fall back to your current target's ID if one is not supplied.\n\n" ..
            "When commanded, the MA will add the target to the first XT slot and immediately force target.\n\n" ..
            "The force combat state will be broadcasted to peers via actors, and will allow the target to check as valid even when the 'Target Non-Aggressives' setting is disabled." ..
            " Actors may need to be configured in MQ if all peers are not on the same PC. As an alternative, the setting above can be enabled temporarily.\n\n" ..
            "Only one Force Combat target can be directed at a time, and the state will be cleared automatically. It can be cleared manually with the /rgl forcecombatclear command.",
        Settings_Used = "",
    },
}
-- Defaults
Config.DefaultConfig               = {

    -- Custom: These use custom UI elements and do not display in normal settings windows.
    ['ClassConfigDir']       = {
        DisplayName = "Class Config Dir",
        Type = "Custom",
        Default = (Config.Globals.BuildType:lower() == "emu" and Config.Constants.SupportedEmuServers:contains(Config.Globals.CurServer)) and Config.Globals.CurServer or "Live",
    },
    ['UseAssistList']        = {
        DisplayName = "Assist Outside of Group",
        Type = "Custom",
        Default = false,
    },
    ['AssistList']           = {
        DisplayName = "List of User-Defined Assists",
        Type = "Custom",
        Default = {},
    },
    ['ShowAdvancedOpts']     = {
        DisplayName = "Show Advanced Options",
        Type = "Custom",
        Default = false,
    },
    ['PopOutForceTarget']    = {
        DisplayName = "Pop Out Force Target",
        Type = "Custom",
        Default = false,
    },
    ['PopOutMercsStatus']    = {
        DisplayName = "Pop Out Mercs Status",
        Type = "Custom",
        Default = false,
    },
    ['PopOutConsole']        = {
        DisplayName = "Pop Out Console",
        Type = "Custom",
        Default = false,
    },
    ['MainWindowLocked']     = {
        DisplayName = "Main Window Locked",
        Default = false,
        Type = "Custom",
    },

    ['LogLevel']             = {
        DisplayName = "Log Level",
        Category = "Debug",
        Type = "Custom",
        Default = 3,
        Min = 1,
        Max = 6,
    },
    ['LogToFile']            = {
        DisplayName = "Log To File",
        Category = "Debug",
        Type = "Custom",
        Default = false,
    },
    ['EnableDebugging']      = {
        DisplayName = "Enable Debugging",
        Category = "Misc",
        Tooltip = "Enable the Debug Panel",
        Default = false,
        ConfigType = "Advanced",
    },

    -- Announcements
    ['AnnounceTarget']       = {
        DisplayName = "Announce Target",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 1,
        Tooltip = "Announces the current combat target. Uses KissAssist format.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['AnnounceTargetGroup']  = {
        DisplayName = "Announce Target to Group",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 2,
        Tooltip = "Announces Target over /gsay.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['MezAnnounce']          = {
        DisplayName = "Mez Announce",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 3,
        Default = false,
        Tooltip = "Announces mez use.",
        ConfigType = "Advanced",
    },
    ['MezAnnounceGroup']     = {
        DisplayName = "Mez Announce to Group",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 4,
        Default = false,
        Tooltip = "Announces mez use to /gsay.",
        ConfigType = "Advanced",
    },
    ['CharmAnnounce']        = {
        DisplayName = "Charm Announce",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 5,
        Default = false,
        Tooltip = "Announces charm use.",
        ConfigType = "Advanced",
    },
    ['CharmAnnounceGroup']   = {
        DisplayName = "Charm Announce to Group",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 6,
        Default = false,
        Tooltip = "Announces charm use to /gsay.",
        ConfigType = "Advanced",
    },
    ['HealAnnounce']         = {
        DisplayName = "Heal Announce",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 7,
        Default = false,
        Tooltip = "Announces heal spell use.",
        ConfigType = "Advanced",
    },
    ['HealAnnounceGroup']    = {
        DisplayName = "Heal Announce to Group",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 8,
        Default = false,
        Tooltip = "Announces heal spell use to /gsay.",
        ConfigType = "Advanced",
    },
    ['CureAnnounce']         = {
        DisplayName = "Cure Announce",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 9,
        Default = false,
        Tooltip = "Announces cure use.",
        ConfigType = "Advanced",
    },
    ['CureAnnounceGroup']    = {
        DisplayName = "Cure Announce to Group",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 10,
        Default = false,
        Tooltip = "Announces cure use to /gsay.",
        ConfigType = "Advanced",
    },
    ['ReagentAnnounce']      = {
        DisplayName = "Reagent Announce",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 11,
        Default = false,
        Tooltip = "Announces an aborted cast due to missing spell reagent.",
        ConfigType = "Advanced",
    },
    ['ReagentAnnounceGroup'] = {
        DisplayName = "Reagent Announce to Group",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 12,
        Default = false,
        Tooltip = "Announces an aborted cast due to missing spell reagent to /gsay. (Warning: Often spammy.)",
        ConfigType = "Advanced",
    },
    ['PullAnnounce']         = {
        DisplayName = "Pull Announce",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 13,
        Default = false,
        Tooltip = "Announce pull-related messages.",
        ConfigType = "Advanced",
    },
    ['PullAnnounceGroup']    = {
        DisplayName = "Pull Announce to Group",
        Group = "General",
        Header = "Announcements",
        Category = "Announcements",
        Index = 14,
        Default = false,
        Tooltip = "Announce pull-related messages in /gsay. (Warning: Often spammy.)",
        ConfigType = "Advanced",
    },

    --Misc
    ['InstantRelease']       = { --Algarnote: Wondering who uses this? I can't imagine a usecase that doesn't involve scripts or afk and this could be handled in those scripts
        DisplayName = "Instant Release",
        Group = "General",
        Header = "Misc",
        Category = "Misc",
        Index = 1,
        Tooltip = "Instantly release to spawn point when you die.",
        Default = false,
        ConfigType = "Advanced",
    },

    -- Meditation/Med Rules
    ['DoMed']                = {
        DisplayName = "Do Meditate",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Rules",
        Index = 1,
        Tooltip = "Choose if/when to meditate.\nMay interfere with bard songs (refer to FAQ for 'Bard Meditation').",
        Type = "Combo",
        ComboOptions = { 'Off', 'Out of Combat', 'In and Out of Combat', },
        Default = Config.Globals.CurLoadedClass == "BRD" and 1 or 2,
        Min = 1,
        Max = 3,
        ConfigType = "Normal",
    },
    ['StandWhenDone']        = {
        DisplayName = "Stand When Done Medding",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Rules",
        Index = 2,
        Tooltip = "Force a stand to end meditation when thresholds are reached.",
        Default = Config.Globals.CurLoadedClass == "BRD",
    },
    ['AfterCombatMedDelay']  = {
        DisplayName = "After Combat Med Delay",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Rules",
        Index = 3,
        Tooltip = "How may seconds to delay after combat before sitting to meditate.",
        Default = 6,
        Min = 0,
        Max = 60,
        ConfigType = "Advanced",
    },
    ['MedAggroCheck']        = {
        DisplayName = "Med Aggro Check",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Rules",
        Index = 4,
        Tooltip = "Force a stand when we have aggro higher than the Med Aggro Percent setting from an xtarget.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['MedAggroPct']          = {
        DisplayName = "Med Aggro Percent",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Rules",
        Index = 5,
        Tooltip = "Aggro percent value for the Med Aggro Check.",
        Default = 65,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },

    -- Meditation/Med Thresholds
    ['HPMedPct']             = {
        DisplayName = "Med Start HP%",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Thresholds",
        Index = 1,
        Tooltip = "Attempt to meditate when at or under this HP percentage.",
        Default = 60,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
    },
    ['HPMedPctStop']         = {
        DisplayName = "Med Stop HP%",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Thresholds",
        Index = 2,
        Tooltip = "Cease attempts to meditate when at or under this HP percentage.",
        Default = 90,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['ManaMedPct']           = {
        DisplayName = "Med Start Mana%",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Thresholds",
        Index = 3,
        Tooltip = "Attempt to meditate when at or under this Mana percentage.",
        Default = 60,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
    },
    ['ManaMedPctStop']       = {
        DisplayName = "Med Stop Mana%",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Thresholds",
        Index = 4,
        Tooltip = "Cease attempts to meditate when at or under this Mana percentage.",
        Default = 90,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['EndMedPct']            = {
        DisplayName = "Med Start End%",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Thresholds",
        Index = 5,
        Tooltip = "Attempt to meditate when at or under this Endurance percentage.",
        Default = 60,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
    },
    ['EndMedPctStop']        = {
        DisplayName = "Med Stop End%",
        Group = "Movement",
        Header = "Meditation",
        Category = "Med Thresholds",
        Index = 6,
        Tooltip = "Cease attempts to meditate when at or under this HP percentage.",
        Default = 90,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },

    -- Clickies(Pre-Configured)
    ['ModRodUse']            = {
        DisplayName = "Mod Rod Use:",
        Group = "Items",
        Header = "Clickies",
        Category = "General Clickies",
        Index = 1,
        Tooltip = "Use available Mod Rods or Azure Crystals when we have less that the Mod Rod Mana % setting.",
        Type = "Combo",
        ComboOptions = Config.Constants.ModRodUse,
        Default = 2,
        Min = 1,
        Max = 3,
    },
    ['ModRodManaPct']        = {
        DisplayName = "Mod Rod Mana %",
        Group = "Items",
        Header = "Clickies",
        Category = "General Clickies",
        Index = 2,
        Tooltip = "Use the first available Mod Rod when at or under this mana percentage, as long as it won't kill us.",
        Default = 60,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
    },
    ['DoMount']              = {
        DisplayName = "Summon Mount:",
        Group = "Items",
        Header = "Clickies",
        Category = "General Clickies",
        Index = 3,
        Tooltip = "Choose how/when to use mounts.",
        Type = "Combo",
        ComboOptions = { 'Never', 'For use as mount', 'For buff only', },
        Default = 2,
        Min = 1,
        Max = 3,
        ConfigType = "Normal",
    },
    ['MountItem']            = {
        DisplayName = "Mount Item",
        Group = "Items",
        Header = "Clickies",
        Category = "General Clickies",
        Index = 4,
        Tooltip = "Mount Clicky item to use.",
        Type = "ClickyItem",
        Default = "",
        ConfigType = "Normal",
    },
    ['DoShrink']             = {
        DisplayName = "Do Shrink",
        Group = "Items",
        Header = "Clickies",
        Category = "General Clickies",
        Index = 5,
        Tooltip = "Use Shrink items.",
        Default = false,
        ConfigType = "Normal",
    },
    ['ShrinkItem']           = {
        DisplayName = "Shrink Item",
        Group = "Items",
        Header = "Clickies",
        Category = "General Clickies",
        Index = 6,
        Tooltip = "Item to use to Shrink yourself.",
        Type = "ClickyItem",
        Default = "",
        ConfigType = "Normal",
    },

    -- Pet/Pet Summoning
    ['DoPet']                = {
        DisplayName = "Summon Pet",
        Group = "Abilities",
        Header = "Pet",
        Category = "Pet Summoning",
        Index = 1,
        Tooltip = "Enable the summoning and buffing of pets.",
        Default = true,
        ConfigType = "Normal",
    },

    -- Pet/Pet Buffs
    ['DoShrinkPet']          = {
        DisplayName = "Do Pet Shrink",
        Group = "Abilities",
        Header = "Pet",
        Category = "Pet Buffs",
        Index = 1,
        Tooltip = "Use a Shrink Clicky on your pet.",
        Default = false,
        ConfigType = "Normal",
    },
    ['ShrinkPetItem']        = {
        DisplayName = "Shrink Pet Item",
        Group = "Abilities",
        Header = "Pet",
        Category = "Pet Buffs",
        Index = 2,
        Tooltip = "Item to use to shrink your pet.",
        Type = "ClickyItem",
        Default = "",
        ConfigType = "Normal",
    },

    -- Targeting
    ['DoAutoTarget']         = {
        DisplayName = "Auto Target",
        Group = "Combat",
        Header = "Targeting",
        Category = "Targeting Behavior",
        Index = 1,
        Tooltip =
        "MA: Allow RGMercs to scan for and assign targets in combat.\nNon-MA: Allow RGMercs to adjust your target to the MA-provided autotarget.\nTarget changes to use spells/songs/AA/items will occur, but you will return to your original target after doing so.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['StayOnTarget']         = {
        DisplayName = "Stay On Target",
        Group = "Combat",
        Header = "Targeting",
        Category = "Targeting Behavior",
        Index = 2,
        Tooltip = "Don't change combat targets when the MA changes its Mercs autotarget. Stay on the original enemy.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['SafeTargeting']        = {
        DisplayName = "Use Safe Targeting",
        Group = "Combat",
        Header = "Targeting",
        Category = "Targeting Behavior",
        Index = 3,
        Tooltip = "Do not target mobs that are fighting others (except if those others pass safety checks, such as if they are DanNet peers.).",
        Default = true,
        ConfigType = "Advanced",
    },
    ['TargetNonAggressives'] = {
        DisplayName = "Target Non-Aggressives",
        Group = "Combat",
        Header = "Targeting",
        Category = "Targeting Behavior",
        Index = 4,
        Tooltip =
        "Allow targeting of NPCs that are not aggressive (hostile) if they are targeted by our MA.\nNote: If combat has been forced on the target (by the MA via the forcecombat command), the target will also be allowed.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['StopAttackForPCs']     = {
        DisplayName = "Stop Attack for PCs",
        Group = "Combat",
        Header = "Targeting",
        Category = "Targeting Behavior",
        Index = 5,
        Tooltip = "Ensure that auto attack is turned off before targeting a PC to use a spell, song, AA, or item. May be required if PvP is enabled by flag, zone, or server.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['AutoAttackSafety']     = {
        DisplayName = "Auto Attack Safety Check",
        Group = "Combat",
        Header = "Targeting",
        Category = "Targeting Behavior",
        Index = 6,
        Tooltip = "Turn auto-attack off if we are not cleared to engage the current target.",
        Default = true,
        ConfigType = "Advanced",
    },

    ['ScanNamedPriority']    = {
        DisplayName = "Scan Priority:",
        Group = "Combat",
        Header = "Targeting",
        Category = "MA Target Selection",
        Index = 1,
        Tooltip = "Choose whether this PC will prioritize Named or Non-Named mobs if set as MA.",
        Type = "Combo",
        ComboOptions = Config.Constants.ScanNamedPriority,
        Default = 1,
        Min = 1,
        Max = #Config.Constants.ScanNamedPriority,
        ConfigType = "Advanced",
    },
    ['ScanHPPriority']       = {
        DisplayName = "Scan HP% Priority:",
        Group = "Combat",
        Header = "Targeting",
        Category = "MA Target Selection",
        Index = 2,
        Tooltip = "Choose whether this PC will prioritize low or high HP% mobs if set as MA.\n" ..
            "If no preference is selected, we will simply choose the lowest mob ID.",
        Type = "Combo",
        ComboOptions = Config.Constants.ScanHPPriority,
        Default = 1,
        Min = 1,
        Max = #Config.Constants.ScanHPPriority,
        ConfigType = "Advanced",
    },
    ['AreaScanFallback']     = {
        DisplayName = "Area Scan Fallback",
        Group = "Combat",
        Header = "Targeting",
        Category = "MA Target Selection",
        Index = 3,
        Tooltip = "Scan for targets via spawnsearch in the abscence of XTargets. Use with caution, can aggro mobs unintentionally.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['MAScanZRange']         = {
        DisplayName = "Main Assist Scan ZRange",
        Group = "Combat",
        Header = "Targeting",
        Category = "MA Target Selection",
        Index = 4,
        Tooltip = "Allowable height difference between mobs and the MA when scanning for targets.",
        Default = 45,
        Min = 15,
        Max = 200,
        ConfigType = "Advanced",
    },
    ['MAScanAggro']          = {
        DisplayName = "Scan for Aggro",
        Group = "Combat",
        Header = "Targeting",
        Category = "MA Target Selection",
        Index = 5,
        Tooltip = "Scan hate levels of XT haters and prioritize those who aren't aggroed on this PC.",
        Default = true,
        ConfigType = "Advanced",
    },

    -- Assisting
    ['DoAutoEngage']         = {
        DisplayName = "Auto Engage",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 1,
        Tooltip = "Automatically engage targets.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['AutoAssistAt']         = {
        DisplayName = "Auto Assist Percent",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 2,
        Tooltip = "Begin combat actions against the auto target when its reaches this health percentage.",
        Default = 98,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['AssistRange']          = {
        DisplayName = "Assist Range",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 3,
        Tooltip = "Engage the combat target when it is within this distance.",
        Default = 100,
        Min = 0,
        Max = 300,
        ConfigType = "Advanced",
    },
    ['DoMelee']              = {
        DisplayName = "Enable Melee Combat",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 4,
        Tooltip = "Auto attack the combat target.",
        Default = Config.Globals.CurLoadedClass ~= "RNG" and Config.Constants.RGMelee:contains(Config.Globals.CurLoadedClass),
        ConfigType = "Normal",
    },
    ['AllowMezBreak']        = {
        DisplayName = "Allow Mez Break",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 5,
        Tooltip = "Allow combat actions if the target is mezzed.",
        Default = (Config.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName())),
        ConfigType = "Advanced",
    },
    ['DoPetCommands']        = {
        DisplayName = "Pet Control",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 6,
        Tooltip = "Allow RGMercs to issue pet commands.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['PetEngagePct']         = {
        DisplayName = "Pet Assist Percent",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 7,
        Tooltip = "Send pets to attack the combat target when it reaches this health percentage.",
        Default = 96,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['DoMercenary']          = {
        DisplayName = "Merc Control",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 8,
        Tooltip = "Allow RGMercs to issue mercenary commands. We plan to add selectable stances in a future update.",
        Default = (Config.Globals.BuildType ~= 'Emu'),
        ConfigType = "Normal",
    },
    ['FollowMarkTarget']     = {
        DisplayName = "Follow Mark Target",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 9,
        Tooltip = "Prioritize the Marked target as the combat target.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['RaidAssistTarget']     = {
        DisplayName = "Raid Assist Target",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 10,
        Tooltip = "Which Raid Assist target to follow. Please note that we will not fallback if this is not set properly.",
        Type = "Combo",
        ComboOptions = { 'First', 'Second', 'Third', },
        Default = 1,
        Min = 1,
        Max = 3,
        ConfigType = "Normal",
    },
    ['SelfAssistFallback']   = {
        DisplayName = "Self-Assist Fallback",
        Group = "Combat",
        Header = "Assisting",
        Category = "Assisting",
        Index = 11,
        Tooltip = "If no other valid MA is found, fallback to ourselves.\nPlease note that when solo (and not using the Assist List), we are always our own MA.",
        Type = "Combo",
        ComboOptions = { 'Never', 'Only in Groups', 'Only in Raids', 'Always', },
        Default = 2,
        Min = 1,
        Max = 4,
        ConfigType = "Normal",
    },

    -- Positioning/General
    ['FaceTarget']           = {
        DisplayName = "Face Target in Combat",
        Group = "Combat",
        Header = "Positioning",
        Category = "General Positioning",
        Index = 1,
        Tooltip = "Periodically /face your target while in combat.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['StickHow']             = {
        DisplayName = "Stick How",
        Group = "Combat",
        Header = "Positioning",
        Category = "General Positioning",
        Index = 2,
        Tooltip = "Custom arguments for /stick command. Leave blank for default (varies on class).",
        Default = "",
        ConfigType = "Advanced",
        FAQ = "What are the default stick settings?",
        Answer = "   If the Stick How entry is left blank, we will use default stick settings as follows:\n" ..
            "If MA: < 10 moveback* uw >\n" ..
            "Others: < 10** behindonce moveback uw >\n\n" ..
            "* - Optional moveback flag (if 'Moveback As Tank' is enabled).\n" ..
            "** - On larger targets this value becomes 20.",
    },
    ['BellyCastStick']       = {
        DisplayName = "Stick for Belly Cast",
        Group = "Combat",
        Header = "Positioning",
        Category = "General Positioning",
        Index = 3,
        Tooltip = "If Melee Combat is disabled, pin at 40 units on named with a dragon bodytype in case of possible bellycaster.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['AutoStandFD']          = {
        DisplayName = "Stand from FD in Combat",
        Group = "Combat",
        Header = "Positioning",
        Category = "General Positioning",
        Index = 4,
        Tooltip = "Stand up if feigning at the start of combat.",
        Default = true,
        ConfigType = "Normal",
    },
    ['HandleCantSeeTarget']  = {
        DisplayName = "Handle Cannot See Target",
        Group = "Combat",
        Header = "Positioning",
        Category = "General Positioning",
        Index = 5,
        Tooltip = "Attempt to adjust positioning if you receive a 'cannot see your target' message.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['HandleTooClose']       = {
        DisplayName = "Handle Too Close",
        Group = "Combat",
        Header = "Positioning",
        Category = "General Positioning",
        Index = 6,
        Tooltip = "Attempt to adjust positioning if you receive a 'too close to use a ranged weapon' message.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['HandleTooFar']         = {
        DisplayName = "Handle Too Far",
        Group = "Combat",
        Header = "Positioning",
        Category = "General Positioning",
        Index = 7,
        Tooltip = "Attempt to adjust positioning if you receive a 'too far away' or 'cant hit them from here' message.",
        Default = true,
        ConfigType = "Advanced",
    },
    -- Positioning/Tank
    ['MovebackWhenTank']     = {
        DisplayName = "Moveback as Tank",
        Group = "Combat",
        Header = "Positioning",
        Category = "Tank Positioning",
        Index = 1,
        Tooltip = "Adds 'moveback' to the default stick command when tanking. Helpful to keep mobs from getting behind you.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['MovebackWhenBehind']   = {
        DisplayName = "Moveback if Mob Behind",
        Group = "Combat",
        Header = "Positioning",
        Category = "Tank Positioning",
        Index = 2,
        Tooltip = "Initiates a stick moveback if we detect an XTarget is behind you when tanking.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['MovebackDistance']     = {
        DisplayName = "Units to Moveback",
        Group = "Combat",
        Header = "Positioning",
        Category = "Tank Positioning",
        Index = 3,
        Tooltip = "Distance from mob to moveback to. May require adjustment for larger targets or due to overshooting from high move speed.",
        Default = 20,
        Min = 1,
        Max = 40,
        ConfigType = "Advanced",
    },

    --Common/Rules
    ['MobLowHP']             = {
        DisplayName = "Mob Low HP%",
        Group = "Abilities",
        Header = "Common",
        Category = "Common Rules",
        Index = 1,
        Tooltip = "A mob is considered to be low HP (for the sake of snares, dots and other abilities) under x HP%.",
        Default = 50,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['NamedLowHP']           = {
        DisplayName = "Named Low HP%",
        Group = "Abilities",
        Header = "Common",
        Category = "Common Rules",
        Index = 2,
        Tooltip = "A named mob is considered to be low HP (for the sake of snares, dots and other abilities) under x HP%.",
        Default = 25,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['AggroThrottling']      = {
        DisplayName = "Use Aggro Throttling",
        Group = "Abilities",
        Header = "Common",
        Category = "Common Rules",
        Index = 3,
        Tooltip = "(Non-Tank Modes): Don't use nukes and similar spells when your aggro percent is above the Aggro To Cast value below.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['MobMaxAggro']          = {
        DisplayName = "Start Aggro Throttle:",
        Group = "Abilities",
        Header = "Common",
        Category = "Common Rules",
        Index = 4,
        Tooltip = "(Non-Tank Modes) Maximum % Aggro for most offensive actions if Aggro Throttling is enabled.",
        Default = 90,
        Min = 1,
        Max = 999,
        ConfigType = "Advanced",
    },
    ['LastGemRemem']         = {
        DisplayName = "Remem After Buff:",
        Group = "Abilities",
        Header = "Common",
        Category = "Common Rules",
        Index = 5,
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
    },
    ['IgnoreLevelCheck']     = {
        DisplayName = "Ignore Spell Level Checks",
        Group = "Abilities",
        Header = "Common",
        Category = "Common Rules",
        Index = 6,
        Tooltip = "Ignore checks for minimum level on spells. Used on servers that allow heals, buffs and other spells to land on PCs regardless of level.",
        Default = false,
        ConfigType = "Advanced",
    },
    -- Common/Under the Hood
    ['UseExactSpellNames']   = {
        DisplayName = "Use Exact Spell Names",
        Group = "Abilities",
        Header = "Common",
        Category = "Under the Hood",
        Index = 1,
        Tooltip = "This will cause RGMercs to use '/cast =<Spell>' which , must be supported by your MQ version but will avoid things like 'Bane' casting 'Bane of Nife' instead.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['CastReadyDelayFact']   = {
        DisplayName = "Cast Ready Delay Factor",
        Group = "Abilities",
        Header = "Common",
        Category = "Under the Hood",
        Index = 2,
        Tooltip = "Wait Ping * [n] ms before saying we are ready to cast.",
        Default = 0,
        Min = 0,
        Max = 10,
        ConfigType = "Advanced",
    },
    ['SongClipDelayFact']    = {
        DisplayName = "Song Clip Delay Factor",
        Group = "Abilities",
        Header = "Common",
        Category = "Under the Hood",
        Index = 3,
        Tooltip = "Wait Ping * [n] ms to allow songs to take effect before singing the next.",
        Default = 2,
        Min = 1,
        Max = 10,
        ConfigType = "Advanced",
    },

    -- Damage/Direct
    ['ManaToNuke']           = {
        DisplayName = "Mana to Nuke",
        Group = "Abilities",
        Header = "Damage",
        Category = "Direct",
        Index = 1,
        Tooltip =
        "Minimum % Mana in order to continue to cast nukes.\n\nThis setting is largely aimed at hybrids or healers maintaining a mana reserve. Some default configs (MAG, WIZ) may not always respect this setting.",
        Default = 30,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    --Damage/Over Time
    ['ManaToDot']            = {
        DisplayName = "Mana to Dot",
        Group = "Abilities",
        Header = "Damage",
        Category = "Over Time",
        Index = 1,
        Tooltip =
        "Minimum % Mana in order to continue to cast dots.\n\nThis setting is largely aimed at hybrids or healers maintaining a mana reserve. Some default configs (NEC) may not always respect this setting.",
        Default = 30,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },

    -- Debuffs
    ['ManaToDebuff']         = {
        DisplayName = "Mana to Debuff",
        Group = "Abilities",
        Header = "Debuffs",
        Category = "Debuff Rules",
        Index = 1,
        Tooltip = "Minimum % Mana in order to continue to cast debuffs.",
        Default = 10,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['DebuffMinCon']         = {
        DisplayName = "Debuff Min Con",
        Group = "Abilities",
        Header = "Debuffs",
        Category = "Debuff Rules",
        Index = 2,
        Tooltip = "Min Con to use debuffs on when con-color debuffing is enabled for enemies.",
        Default = 4,
        Min = 1,
        Max = #Config.Constants.ConColors,
        Type = "Combo",
        ComboOptions = Config.Constants.ConColors,
        ConfigType = "Advanced",
    },
    ['MobDebuff']            = {
        DisplayName = "Mob Debuffing:",
        Group = "Abilities",
        Header = "Debuffs",
        Category = "Debuff Rules",
        Index = 3,
        Tooltip = "The circumstances in which we will debuff a (non-named) mob.",
        Default = 2,
        Min = 1,
        Max = #Config.Constants.DebuffChoice,
        Type = "Combo",
        ComboOptions = Config.Constants.DebuffChoice,
        ConfigType = "Advanced",
    },
    ['NamedDebuff']          = {
        DisplayName = "Named Debuffing:",
        Group = "Abilities",
        Header = "Debuffs",
        Category = "Debuff Rules",
        Index = 4,
        Tooltip = "The circumstances in which we will debuff a (named) mob.",
        Default = 2,
        Min = 1,
        Max = #Config.Constants.DebuffChoice,
        Type = "Combo",
        ComboOptions = Config.Constants.DebuffChoice,
        ConfigType = "Advanced",
    },

    -- Emergency
    ['StandFailedFD']        = {
        DisplayName = "Stand on Failed FD",
        Group = "Abilities",
        Header = "Utility",
        Category = "Emergency",
        Index = 1,
        Tooltip = "Stand up if a failed feign is detected ('fall to the ground').",
        Default = true,
        ConfigType = "Advanced",
    },

    -- Buffs/Rules
    ['DoBuffs']              = {
        DisplayName = "Do Downtime/Group Buffs",
        Group = "Abilities",
        Header = "Buffs",
        Category = "Buff Rules",
        Index = 1,
        Tooltip = "Process Downtime and Group Buff Rotations (see your rotations on the class tab).",
        Default = true,
        ConfigType = "Advanced",
    },
    ['BuffWaitMoveTimer']    = {
        DisplayName = "After-Move Buff Delay",
        Group = "Abilities",
        Header = "Buffs",
        Category = "Buff Rules",
        Index = 2,
        Tooltip = "Seconds to wait after stoping movement before doing buffs.",
        Default = 5,
        Min = 0,
        Max = 60,
        ConfigType = "Advanced",
    },
    ['BuffRezables']         = {
        DisplayName = "Buff Rezables",
        Group = "Abilities",
        Header = "Buffs",
        Category = "Buff Rules",
        Index = 3,
        Tooltip =
        "If a PC has a corpse near us, buff them even though they are likely to get rezed. (Note: If disabled, they may still be receiving group buffs aimed at those without corpses.)",
        Default = false,
        ConfigType = "Advanced",
    },
    ['UseCounterActions']    = {
        DisplayName = "Use Aureate's Bane", --this can be freely changed later if another system is added. Avoiding confusion for now.
        Group = "Abilities",
        Header = "Buffs",
        Category = "Buff Rules",
        Index = 4,
        Tooltip =
        "Automatically use counter actions (such as the Aureate's Bane AA to counter Curse of Subjugation in TOB zones.",
        Default = (mq.TLO.MacroQuest.BuildName() or ""):lower() ~= "emu",
    },
    ['BreakInvisForSay']     = {
        DisplayName = "Break Invis for Say Commands",
        Group = "Abilities",
        Header = "Buffs",
        Category = "Buff Rules",
        Index = 5,
        Tooltip = "Break Invis as part of /rgl say, qsay or rsay commands.",
        Default = false,
    },
    -- Buffs/Self
    ['DoAlliance']           = {
        DisplayName = "Do Alliance",
        Group = "Abilities",
        Header = "Buffs",
        Category = "Self",
        Index = 99,
        Tooltip = "Enable the use of Alliance spells.",
        Default = false,
        ConfigType = "Advanced",
    },

    --Recovery/General
    ['DoPetHeals']           = {
        DisplayName = "Heal Pets as PCs",
        Group = "Abilities",
        Header = "Recovery",
        Category = "General Healing",
        Index = 1,
        Tooltip = "Allow pets to be targeted in PC healing rotations.\n" ..
            "Note that CLR/DRU/PAL/SHM will reserve \"Big Heal\" rotations for PCs.\n" ..
            "Further note that many abilities that heal the PC's own pet do not check this setting and are handled seperately.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['BreakInvisForHealing'] = {
        DisplayName = "Break Invis",
        Group = "Abilities",
        Header = "Recovery",
        Category = "General Healing",
        Index = 2,
        Tooltip = "Break invis to heal, cure and rez when out of combat (Does not affect combat actions).",
        Default = false,
        ConfigType = "Advanced",
    },
    ['HealOutside']          = {
        DisplayName = "Heal Outside",
        Group = "Abilities",
        Header = "Recovery",
        Category = "General Healing",
        Index = 3,
        Tooltip = "Heal PCs that have been added to your xtarget list (and their pets, if pet healing is enabled).",
        Default = true,
        ConfigType = "Advanced",
    },
    -- Recovery/Thresholds
    ['MaxHealPoint']         = {
        DisplayName = "Healing Threshold",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Healing Thresholds",
        Index = 1,
        Tooltip = "Minimum PctHPs of any valid target to process healing rotations.",
        Default = 90,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
    },
    ['LightHealPoint']       = {
        DisplayName = "Light Heal Point",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Healing Thresholds",
        Index = 2,
        Tooltip = "Minimum PctHPs to use the Light Heal Rotation or actions that check whether Light Heals are needed.",
        Default = mq.TLO.Me.Class.ShortName() == "CLR" and 95 or 90,
        Min = 1,
        Max = 99,
        ConfigType = "Advanced",
    },
    ['MainHealPoint']        = {
        DisplayName = "Main Heal Point",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Healing Thresholds",
        Index = 3,
        Tooltip = "Minimum PctHPs to use the Main Heal Rotation or actions that check whether Main Heals are needed.",
        Default = 80,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['BigHealPoint']         = {
        DisplayName = "Big Heal Point",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Healing Thresholds",
        Index = 4,
        Tooltip = "Minimum PctHPs to use the Big Heal Rotation or actions that check whether BigHeals are needed.",
        Default = 50,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['GroupHealPoint']       = {
        DisplayName = "Group Heal Point",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Healing Thresholds",
        Index = 5,
        Tooltip = "Minimum PctHPs to use the Group Heal Rotation or actions that check whether Group Heals are needed.",
        Default = 75,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    ['GroupInjureCnt']       = {
        DisplayName = "Group Injured Count",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Healing Thresholds",
        Index = 6,
        Tooltip = "Number of group members that must be under the Group Heal Point percentage threshold.",
        Default = 3,
        Min = 1,
        Max = 5,
        ConfigType = "Advanced",
    },
    ['PetHealPoint']         = {
        DisplayName = "Pet Heal Point",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Healing Thresholds",
        Index = 7,
        Tooltip = "Minimum PctHPs to process standard PC Healing Rotations on pets (if enabled). See 'Heal Pets as PCs' setting.",
        Default = 50,
        Min = 1,
        Max = 100,
        ConfigType = "Advanced",
    },
    --Recovery/Curing
    ['DoCureSpells']         = {
        DisplayName = "Do Cure Spells",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Curing",
        Index = 1,
        Tooltip = "Use Cure spells to clear detrimental effects from your group or yourself.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['DoCureAA']             = {
        DisplayName = "Do Cure AA",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Curing",
        Index = 2,
        Tooltip = "Use Cure AA to clear detrimental effects from your group or yourself.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['CureInterval']         = {
        DisplayName = "Downtime Cure Check Interval",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Curing",
        Index = 3,
        Tooltip = "The delay in seconds between making cure checks during downtime (to prevent unnecessary queries).",
        Default = 5,
        Min = 1,
        Max = 30,
        ConfigType = "Advanced",
    },
    --Recovery/Rezzing
    ['DoRez']                = {
        DisplayName = "Do Rez",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Rezzing",
        Index = 1,
        Tooltip = "Use Rezes. If disabled, no rez spells will be used at any time.",
        Default = true,
        ConfigType = "Advanced",
    },
    ['DoBattleRez']          = {
        DisplayName = "Do Battle Rez",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Rezzing",
        Index = 2,
        Tooltip = "Enable rezzing while in combat",
        Default = mq.TLO.Me.Class.ShortName():lower() == "clr",
        ConfigType = "Advanced",
    },
    ['RezOutside']           = {
        DisplayName = "Rez Outside",
        Group = "Abilities",
        Header = "Recovery",
        Category = "General Healing",
        Index = 3,
        Tooltip = "Rez dannet peers, raid/guildmates, and anyone in the Assist List (and not simply your own group).",
        Default = true,
        ConfigType = "Advanced",
    },
    ['RetryRezDelay']        = {
        DisplayName = "Retry Rez Delay",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Rezzing",
        Index = 4,
        Tooltip = "Delay in seconds between rez attempts.",
        Default = 6,
        Min = 1,
        Max = 60,
        ConfigType = "Advanced",
    },
    ['RezInZonePC']          = {
        DisplayName = "Rez In-Zone PCs",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Rezzing",
        Index = 5,
        Tooltip = "Rez corpses of live PCs in the zone (If disabled, we will only rez corpses of PCs not in our current zone).",
        Default = true,
        ConfigType = "Advanced",
        FAQ = "Why would I want (or not want) to rez corpses of PCs that are in-zone with us already?",
        Answer = "Emu servers have various rules, such as no xp loss on death, or not dropping items to your corpse\n" ..
            "Depending in the server, various combinations of rez settings may be required for the best play experience.",
    },
    ['ConCorpseForRez']      = {
        DisplayName = "Check for Previous Rez",
        Group = "Abilities",
        Header = "Recovery",
        Category = "Rezzing",
        Index = 6,
        Tooltip = "If this setting is enabled, we will attempt to con a corpse and rez only if that corpse has not yet taken one.",
        Default = (mq.TLO.MacroQuest.BuildName() or ""):lower() == "emu",
        ConfigType = "Advanced",
        FAQ = "Why am I conning corpses? I play on a server with no exp penalty, or where we don't need to loot corpses.",
        Answer = "The Check for Previous Rez setting is enabled by default on emu, this can be adjusted on the Heal/Rez options tab.",
    },

    -- Burning
    ['BurnAuto']             = {
        DisplayName = "Use Auto Burn",
        Group = "Combat",
        Header = "Burning",
        Category = "Burning",
        Index = 1,
        Tooltip = "Use Burn rotations when the conditions below are met.",
        Default = true,
        ConfigType = "Normal",
    },
    ['BurnAlways']           = {
        DisplayName = "Auto Burn: Always",
        Group = "Combat",
        Header = "Burning",
        Category = "Burning",
        Index = 2,
        Tooltip = "Automatically use Burn rotations on any/every target.",
        Default = false,
        ConfigType = "Advanced",
    },
    ['BurnMobCount']         = {
        DisplayName = "Auto Burn: Mob Threshold",
        Group = "Combat",
        Header = "Burning",
        Category = "Burning",
        Index = 4,
        Tooltip = "Automatically use Burn rotations when we are fighting x number of haters.",
        Default = 3,
        Min = 1,
        Max = 10,
        ConfigType = "Advanced",
    },
    ['BurnNamed']            = {
        DisplayName = "Auto Burn: Named",
        Group = "Combat",
        Header = "Burning",
        Category = "Burning",
        Index = 5,
        Tooltip = "Automatically use Burn rotations when we are fighting a named mob(must be present in RGMerc Named List or SpawnMaster ini).",
        Default = true,
        ConfigType = "Advanced",
    },
    ['NamedMinLevel']        = {
        DisplayName = "Named Min Level",
        Group = "Combat",
        Header = "Burning",
        Category = "Burning",
        Index = 6,
        Tooltip = "The minimum level we will treat a Named as a threat (if below this level, we will treat them as trash mobs).",
        Default = 1,
        Min = 1,
        Max = 150,
        ConfigType = "Advanced",
    },


    -- [ UI ] --
    ['DisplayManualTarget']  = {
        DisplayName = "Display Manual Target",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Index = 1,
        Tooltip = "If you have no auto target, enabling this will show information about your current manual target in the UI.",
        Default = false,
    },
    ['ExtendedFTInfo']       = {
        DisplayName = "Extended ForceTarget Info",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Index = 2,
        Tooltip = "Show extended information in the Force Target window.",
        Default = false,
    },
    ['AlwaysShowMiniButton'] = {
        DisplayName = "Always Show Mini Button",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Index = 3,
        Tooltip = "Always show the RGMercs Mini Mode button, even when the main window is displayed.",
        Default = false,
        ConfigType = "Normal",
    },
    ['EscapeMinimizes']      = {
        DisplayName = "Escape Closes Main Window",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Index = 4,
        Tooltip = "In always-show mini button mode, closes the main window with escape if enabled.",
        Default = false,
        ConfigType = "Normal",
    },
    ['ShowDebugTiming']      = {
        DisplayName = "Show Rotation Debug Timing",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Index = 5,
        ConfigType = "Advanced",
        Tooltip = "Enable displaying the timing of each rotation step.",
        Default = false,
    },
    ['BgOpacity']            = {
        DisplayName = "Background Opacity",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Index = 6,
        Tooltip = "Opacity for the RGMercs UI",
        Default = 100,
        Min = 20,
        Max = 100,
    },
    ['FrameEdgeRounding']    = {
        DisplayName = "Frame Edge Rounding",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Index = 7,
        Tooltip = "Frame Edge Rounding for the RGMercs UI",
        Default = 6,
        Min = 0,
        Max = 50,
    },
    ['ScrollBarRounding']    = {
        DisplayName = "Scroll Bar Rounding",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Index = 8,
        Tooltip = "Frame Edge Rounding for the RGMercs UI",
        Default = 10,
        Min = 0,
        Max = 50,
    },
    -- Cross client comms
    ['ActorPeerTimeout']     = {
        DisplayName = "Actor Peer Timeout",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Index = 9,
        Tooltip = "Time in seconds to wait before considering a peer disconnected.",
        Default = 45,
        Min = 10,
        Max = 120,
    },

    ['LootModuleType']       = {
        DisplayName = "Loot Module Type",
        Group = "General",
        Header = "Loot(Emu)",
        Category = "Looting Script",
        Index = 10,
        Tooltip = "Choose which loot module to use.",
        Default = 1,
        Min = 1,
        Max = #Config.Constants.LootModuleTypes,
        Type = "Combo",
        ComboOptions = Config.Constants.LootModuleTypes,
        OnChange = function(oldValue, newValue)
            if Config.Globals.BuildType:lower() ~= "emu" and newValue > 1 then
                Logger.log_error("\ayLoot Modules are not used on offical servers.")
                Config:SetSetting("LootModuleType", 1, false)
                return
            end
            local oldLootModule = Config.Constants.LootModuleTypes[oldValue]
            local newLootModule = Config.Constants.LootModuleTypes[newValue]
            Logger.log_info("\ayLoot Module changed from %s to: \ag%s", oldLootModule or "Unknown", newLootModule or "Unknown")
            Modules:unloadModule(oldLootModule)
            Config:ClearModuleSettings(oldLootModule)
            if newValue > 1 then
                local path = string.format("modules." .. newLootModule:lower())
                Logger.log_info("\ayLoot Module: \ag%s", newLootModule:lower() or "Unknown")
                Modules:loadModule(newLootModule, path)
                Config:UpdateCommandHandlers()
            end
        end,
    },

    --Deprecated/Need Adjusted to Custom/Etc
    ['FullUI']               = {
        DisplayName = "Use Full UI",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Tooltip = "Toggle between Full UI and a Simple UI [Experimental]",
        Default = true,
    },
    ['EnableOptionsUI']      = {
        DisplayName = "Enable Options UI",
        Type = "Custom",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Tooltip = "Show the experimental Options UI window",
        Default = false,
    },
    ['EnableAFUI']           = {
        DisplayName = "Enable Very Special UI",
        Type = "Custom",
        Group = "General",
        Header = "Interface",
        Category = "Interface",
        Tooltip = "???",
        Default = false,
    },
}

Config.CommandHandlers             = {}

local function deep_copy(orig, copies)
    copies = copies or {} -- to handle cycles
    if type(orig) ~= "table" then
        return orig
    elseif copies[orig] then
        return copies[orig]
    end

    local copy = {}
    copies[orig] = copy
    for k, v in pairs(orig) do
        copy[deep_copy(k, copies)] = deep_copy(v, copies)
    end
    return setmetatable(copy, getmetatable(orig))
end

function Config:GetConfigFileName()
    local oldFile = mq.configDir ..
        '/rgmercs/PCConfigs/RGMerc_' .. self.Globals.CurServerNormalized .. "_" .. self.Globals.CurLoadedChar .. '.lua'
    local newFile = mq.configDir ..
        '/rgmercs/PCConfigs/RGMerc_' .. self.Globals.CurServerNormalized .. "_" .. self.Globals.CurLoadedChar .. "_" .. self.Globals.CurLoadedClass:lower() .. '.lua'

    if Files.file_exists(newFile) then
        return newFile
    end

    Files.copy_file(oldFile, newFile)

    return newFile
end

function Config:SaveSettings()
    mq.pickle(self:GetConfigFileName(), self:GetModuleSettings("Core"))
    Logger.log_debug("\ag%s Module settings saved to %s.", self._name, self:GetConfigFileName())
    Logger.set_log_level(Config:GetSetting('LogLevel'))
    Logger.set_log_to_file(Config:GetSetting('LogToFile'))
end

function Config:LoadSettings()
    self.Globals.CurLoadedChar       = mq.TLO.Me.DisplayName()
    self.Globals.CurLoadedClass      = mq.TLO.Me.Class.ShortName()
    self.Globals.CurServer           = mq.TLO.EverQuest.Server()
    self.Globals.CurServerNormalized = mq.TLO.EverQuest.Server():gsub(" ", "")
    Logger.log_info(
        "\ayLoading Main Settings for %s!",
        self.Globals.CurLoadedChar)

    local settings = {}
    local firstSaveRequired = false

    local config, err = loadfile(self:GetConfigFileName())
    if err or not config then
        Logger.log_error("\ayUnable to load global settings file(%s), creating a new one!",
            self:GetConfigFileName())
        firstSaveRequired = true
    else
        settings = config()
    end

    Config:RegisterModuleSettings("Core", settings, Config.DefaultConfig, Config.FAQ, firstSaveRequired)

    -- setup our script path for later usage since getting it kind of sucks, but only on the first run (personas)
    if Config.Globals.ScriptDir == "" then
        local info = debug.getinfo(2, "S")
        local scriptDir = info.short_src:sub(info.short_src:find("lua") + 4):sub(0, -10)
        Config.Globals.ScriptDir = string.format("%s/%s", mq.TLO.Lua.Dir(), scriptDir)
    end

    self.SettingsLoadComplete = true

    return true
end

function Config:UpdateCommandHandlers()
    self.CommandHandlers = {}
    local startTime = mq.gettime()
    local submoduleDefaults = self:GetAllModuleDefaultSettings()

    for moduleName, moduleSettings in pairs(Config.moduleSettings) do
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
        Logger.log_debug("\ag[Config] \ayGeting all Settings took %.3f seconds to process module %s.", (modendTime - modstartTime) / 1000, moduleName)
    end

    local endTime = mq.gettime()

    Logger.log_debug("\ag[Config] \ayUpdateCommandHandlers() took %.3f seconds to execute for %d modules.", (endTime - startTime) / 1000, #Config.moduleSettings)
end

---@param config string
---@param showUsageText boolean
---@param defaults table
---@return boolean
---@return string
function Config:GetUsageText(config, showUsageText, defaults, valueOnly)
    local handledType = false
    local usageString = showUsageText and string.format("/rgl set %s | ", Strings.PadString(config, 30, false)) or ""
    local configData = defaults[config]

    local rangeText = ""
    local defaultText = ""
    local currentText = ""

    if type(configData.Default) == 'number' then
        rangeText = string.format("\aw[%s\ax]", Strings.PadString(string.format("\a-yRange: \a-y%d\aw-\a-y%d", configData.Min or 0, configData.Max or 999), 15, false))
        defaultText = string.format("[\a-tDefault: %s\ax]", Strings.PadString(tostring(configData.Default), 8, false))
        currentText = string.format("%d", Config:GetSetting(config))
        handledType = true
    elseif type(configData.Default) == 'boolean' then
        rangeText = string.format("\aw[%s\ax]", Strings.PadString(string.format("\a-yType : \a-yon\aw|\a-yoff"), 15, false))
        ---@diagnostic disable-next-line: param-type-mismatch
        defaultText = string.format("[\a-tDefault: %s\ax]", Strings.PadString(Strings.BoolToString(configData.Default), 8, false))
        currentText = (string.format("%s", Strings.BoolToString(Config:GetSetting(config))))
        handledType = true
    elseif type(configData.Default) == 'string' then
        rangeText = string.format("\aw[%s\ax]", Strings.PadString(string.format("\a-y<\"str\">"), 15, false))
        defaultText = string.format("[\a-tDefault: %s\ax]", Strings.PadString("\"" .. configData.Default .. "\"", 8, false))
        currentText = string.format("%s", Config:GetSetting(config))
        handledType = true
    elseif type(configData.Default) == 'table' then
        rangeText = string.format("\aw[%s\ax]", Strings.PadString(string.format("\a-y<\"table\">"), 15, false))
        defaultText = string.format("[\a-tDefault: %s\ax]", Strings.PadString(Strings.TableToString(configData.Default), 8, false))
        currentText = string.format("%s", Strings.TableToString(Config:GetSetting(config)))
        if #currentText > 120 then
            currentText = currentText:sub(1, 120) .. "..."
        end

        handledType = true
    end

    if valueOnly then
        usageString = usageString ..
            string.format("%s",
                Strings.PadString(currentText, 5, false)
            )
    else
        usageString = usageString ..
            string.format("  %s | %s | %s", Strings.PadString(currentText, 25, false), Strings.PadString(rangeText, 15, false), Strings.PadString(defaultText, 5, false)
            )
    end

    return handledType, usageString
end

function Config:GetModuleSettings(module)
    return self.moduleTempSettings[module] or {}
end

function Config:PeerGetModuleSettings(peer, module)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:GetModuleSettings(module)
    end

    if self.currentPeer ~= peer then
        Logger.log_error("PeerGetModuleSettings called for %s but current peer is %s", peer, self.currentPeer or "nil")
        return {}
    end

    return self.peerModuleSettings[module] or {}
end

function Config:GetModuleDefaultSettings(module)
    return self.moduleDefaultSettings[module] or {}
end

function Config:PeerGetModuleDefaultSettings(peer, module)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:GetModuleDefaultSettings(module)
    end

    if self.currentPeer ~= peer then
        Logger.log_error("PeerGetModuleDefaultSettings called for %s but current peer is %s", peer, self.currentPeer or "nil")
        return {}
    end

    return self.peerModuleDefaultSettings[module] or {}
end

function Config:GetModuleSettingCategories(module)
    return self.moduleSettingCategories[module] or {}
end

function Config:PeerGetModuleSettingCategories(peer, module)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:GetModuleSettingCategories(module)
    end

    if self.currentPeer ~= peer then
        Logger.log_error("PeerGetModuleSettingCategories called for %s but current peer is %s", peer, self.currentPeer or "nil")
        return {}
    end

    return self.peerModuleSettingCategories[module] or {}
end

function Config:GetAllModuleSettings()
    return self.moduleTempSettings or {}
end

function Config:GetAllModuleDefaultSettings()
    return self.moduleDefaultSettings or {}
end

function Config:PeerGetAllModuleDefaultSettings(peer)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:GetAllModuleDefaultSettings()
    end

    if self.currentPeer ~= peer then
        Logger.log_error("PeerGetAllModuleDefaultSettings called for %s but current peer is %s", peer, self.currentPeer or "nil")
        return {}
    end

    return self.peerModuleDefaultSettings or {}
end

function Config:GetAllModuleSettingCategories()
    return self.moduleSettingCategories or {}
end

function Config:PeerGetAllModuleSettingCategories(peer)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:GetAllModuleSettingCategories()
    end

    if self.currentPeer ~= peer then
        Logger.log_error("PeerGetAllModuleSettingCategories called for %s but current peer is %s", peer, self.currentPeer or "nil")
        return {}
    end

    return self.peerModuleSettingCategories or {}
end

function Config:GetAllSettingsForCategory(category)
    return Config.TempSettings.SettingsCategoryToSettingMapping[category] or {}
end

function Config:PeerGetAllSettingsForCategory(peer, category)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:GetAllSettingsForCategory(category)
    end

    if self.currentPeer ~= peer then
        Logger.log_error("PeerGetAllSettingsForCategory called for %s but current peer is %s", peer, self.currentPeer or "nil")
        return {}
    end

    return Config.TempSettings.PeerSettingsCategoryToSettingMapping[category] or {}
end

function Config:GetModuleForSetting(setting)
    return Config.TempSettings.SettingToModuleCache[setting] or "None"
end

function Config:PeerGetModuleForSetting(peer, setting)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:GetModuleForSetting(setting)
    end

    if self.currentPeer ~= peer then
        Logger.log_error("PeerGetModuleForSetting called for %s but current peer is %s", peer, self.currentPeer or "nil")
        return {}
    end

    return Config.TempSettings.PeerSettingToModuleCache[setting] or "None"
end

function Config:SettingsLoaded()
    return self.SettingsLoadComplete
end

--- Retrieves if a specified setting exists.
--- @param setting string The name of the setting to retrieve.
--- @return boolean true if this setting exists.
function Config:HaveSetting(setting)
    return Config.TempSettings.SettingToModuleCache[setting] ~= nil
end

--- Retrieves a specified setting.
--- @param peer string The name of the peer to retrieve the setting for.
--- @param setting string The name of the setting to retrieve.
--- @param failOk boolean? If true, the function will not raise an error if the setting is not found.
--- @return any The value of the setting, or nil if the setting is not found and failOk is true.
function Config:PeerGetSetting(peer, setting, failOk)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:GetSetting(setting, failOk)
    end

    if self.currentPeer ~= peer then
        Logger.log_error("PeerGetSetting called for %s but current peer is %s", peer, self.currentPeer or "nil")
        return nil
    end

    if not Config.TempSettings.PeerSettingToModuleCache[setting] then
        if not failOk then
            Logger.log_error("Setting %s was not found in the module cache for: %s!", setting, peer)
        end
        return nil
    end

    return self:PeerGetModuleSettings(peer, Config.TempSettings.PeerSettingToModuleCache[setting])[setting]
end

--- Retrieves a specified setting.
--- @param setting string The name of the setting to retrieve.
--- @param failOk boolean? If true, the function will not raise an error if the setting is not found.
--- @return any The value of the setting, or nil if the setting is not found and failOk is true.
function Config:GetSetting(setting, failOk)
    if not Config.TempSettings.SettingToModuleCache[setting] then
        if not failOk then
            Logger.log_error("Setting %s was not found in the module cache!", setting)
        end
        return nil
    end
    return self:GetModuleSettings(Config.TempSettings.SettingToModuleCache[setting])[setting]
end

--- Retrieves a specified setting default info.
--- @param setting string The name of the setting to retrieve.
--- @return any The value of the setting, or nil if the setting is not found and failOk is true.
function Config:GetSettingDefaults(setting)
    if not Config.TempSettings.SettingToModuleCache[setting] then
        Logger.log_error("Setting %s was not found in the module cache!", setting)
        return nil
    end
    return self:GetModuleDefaultSettings(Config.TempSettings.SettingToModuleCache[setting])[setting]
end

--- Retrieves a specified setting default info for a peer.
--- @param peer string The name of the peer to retrieve the setting for.
--- @param setting string The name of the setting to retrieve.
--- @return any The value of the setting, or nil if the setting is not found and failOk is true.
function Config:PeerGetSettingDefaults(peer, setting)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:GetSettingDefaults(setting)
    end

    if self.currentPeer ~= peer then
        Logger.log_error("PeerGetSettingDefaults called for %s but current peer is %s", peer, self.currentPeer or "nil")
        return nil
    end

    if not Config.TempSettings.PeerSettingToModuleCache[setting] then
        Logger.log_error("Setting %s was not found in the module cache!", setting)
        return nil
    end

    return self:PeerGetModuleDefaultSettings(peer, Config.TempSettings.PeerSettingToModuleCache[setting])[setting]
end

--- Validates and sets a configuration setting for a specified module.
--- @param module string: The name of the module for which the setting is being configured.
--- @param setting string: The name of the setting to be validated and set.
--- @param value any: The value to be assigned to the setting.
--- @return boolean|string|number|nil: Returns a valid value for the setting.
function Config:MakeValidSetting(module, setting, value)
    local defaultConfig = self:GetModuleDefaultSettings(module)

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
    elseif type(defaultConfig[setting].Default) == 'table' then
        return value
    end

    return nil
end

--- Converts a given setting name into a valid format and module name
--- This function ensures that the setting name adheres to the required format for further processing.
--- @param setting string The original setting name that needs to be validated and formatted.
--- @return string, string The module of the setting and The validated and formatted setting name.
function Config:MakeValidSettingName(setting)
    local validSetting = self.TempSettings.SettingsLowerToNameCache[setting:lower()] or "None"

    return Config.TempSettings.SettingToModuleCache[validSetting] or "None", validSetting
end

---Sets a setting from either in global or a module setting table.
--- @param peer string: The name of the peer to set the setting for.
--- @param setting string: The name of the setting to be updated.
--- @param value any: The new value to assign to the setting.
--- @param tempOnly boolean?: The new value to assign to the setting.
function Config:PeerSetSetting(peer, setting, value, tempOnly)
    if peer == nil or peer == Comms.GetPeerName() then
        return self:SetSetting(setting, value, tempOnly)
    end

    Logger.log_info("\aw[\ar%s\aw] Sending => \ag%s = \a-y%s", peer, setting, tostring(value))
    Comms.SendMessage(peer, self._name, "RemoteSetSetting", { Setting = setting, Value = value, })
end

function Config:RemoteSetSetting(data)
    if data and data.Setting and data.Value ~= nil then
        Logger.log_debug("Received SetSetting for module \awSetSetting :: \at%s \awto \ag%s", data.Setting, tostring(data.Value))
        self:HandleBind(data.Setting, data.Value)
    end
end

---Sets a setting from either in global or a module setting table.
--- @param setting string: The name of the setting to be updated.
--- @param value any: The new value to assign to the setting.
--- @param tempOnly boolean?: The new value to assign to the setting.
function Config:SetSetting(setting, value, tempOnly)
    local settingModuleName = "Core"
    local beforeUpdate = ""

    settingModuleName, setting = self:MakeValidSettingName(setting)

    if settingModuleName == "None" then
        Logger.log_error("Setting %s was not found!", setting)
        return
    end

    local oldValue = Config:GetSetting(setting)
    local defaultConfig = self:GetModuleDefaultSettings(settingModuleName)

    local cleanValue = self:MakeValidSetting(settingModuleName, setting, value)
    _, beforeUpdate = Config:GetUsageText(setting, false, defaultConfig, true)
    if cleanValue ~= nil then
        if tempOnly then
            self.moduleTempSettings[settingModuleName][setting] = cleanValue
        else
            self.moduleSettings[settingModuleName][setting] = deep_copy(cleanValue)
            self.moduleTempSettings[settingModuleName][setting] = cleanValue
            self:SaveModuleSettings(settingModuleName, self.moduleSettings[settingModuleName])
        end
    end

    if defaultConfig[setting].RequiresLoadoutChange then
        Modules:ExecModule("Class", "RescanLoadout")
    end

    local _, afterUpdate = Config:GetUsageText(setting, false, defaultConfig)
    Logger.log_debug("(%s) \ag%s\aw is now:\ax %-5s \ay[Previous:\ax %s\ay]", settingModuleName, setting, afterUpdate, beforeUpdate)


    if defaultConfig[setting].OnChange and oldValue ~= cleanValue then
        defaultConfig[setting].OnChange(oldValue, cleanValue)
    end
end

--- Temporarily sets a setting
--- @param setting string: The name of the setting to be updated.
--- @param value any: The new value to assign to the setting.
function Config:SetTempSetting(setting, value)
    self:SetSetting(setting, value, true)
end

--- Clears a Temporarily sets a setting
--- @param setting string: The name of the setting to be updated.
function Config:ClearTempSetting(setting)
    local settingModuleName = "Core"

    settingModuleName, setting = self:MakeValidSettingName(setting)

    if settingModuleName == "None" then
        Logger.log_error("Setting %s was not found!", setting)
        return
    end

    self:SetSetting(setting, self.moduleSettings[settingModuleName][setting], true)
end

--- Clears Temporarily set settings
function Config:ClearAllTempSettings()
    self.moduleTempSettings = deep_copy(self.moduleSettings) -- make sure nothing is a reference.
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
    if settings == nil then
        settings = {}
        changed = true
        Logger.log_error("\arSettings file was empty or corrupt -- creating a new one with default values.")
    end

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

function Config:UnRegisterCategoryToSettingMapping(setting)
    local category = Config:GetSettingDefaults(setting).Category
    if self.TempSettings.SettingsCategoryToSettingMapping[category] then
        for i, v in ipairs(self.TempSettings.SettingsCategoryToSettingMapping[category]) do
            if v == setting then
                table.remove(self.TempSettings.SettingsCategoryToSettingMapping[category], i)
                break
            end
        end
    end
end

function Config:RegisterCategoryToSettingMapping(setting)
    local category = Config:GetSettingDefaults(setting).Category
    self.TempSettings.SettingsCategoryToSettingMapping[category] = self.TempSettings.SettingsCategoryToSettingMapping[category] or {}
    table.insert(self.TempSettings.SettingsCategoryToSettingMapping[category], setting)
end

function Config:PeerRegisterCategoryToSettingMapping(peer, setting)
    local category = Config:PeerGetSettingDefaults(peer, setting).Category
    self.TempSettings.PeerSettingsCategoryToSettingMapping[category] = self.TempSettings.PeerSettingsCategoryToSettingMapping[category] or {}
    table.insert(self.TempSettings.PeerSettingsCategoryToSettingMapping[category], setting)
end

function Config:RegisterModuleSettings(module, settings, defaultSettings, faq, firstSaveRequired)
    if self.moduleSettings[module] then
        Logger.log_error("\arModule %s has already registered settings!", module)
        return
    end

    local settingsChanged = false

    --Centralize category creation and setup the FAQs
    local settingCategories = Set.new({})
    for k, v in pairs(defaultSettings or {}) do
        if v.Type ~= "Custom" then
            settingCategories:add(v.Category)
        end
        faq[k] = { Question = v.FAQ, Answer = v.Answer, Settings_Used = k, }
    end

    -- Setup Defaults
    settings, settingsChanged = Config.ResolveDefaults(defaultSettings, settings)
    self.moduleSettings[module] = deep_copy(settings) -- make sure nothing is a reference.
    self.moduleTempSettings[module] = settings
    self.moduleDefaultSettings[module] = defaultSettings
    self.moduleSettingCategories[module] = settingCategories

    for setting, _ in pairs(settings) do
        if not self.moduleDefaultSettings[module][setting].Category or self.moduleDefaultSettings[module][setting].Category:len() == 0 then
            self.moduleDefaultSettings[module][setting].Category = "Uncategorized"
            self.moduleSettingCategories[module]:add("Uncategorized")
        end

        if Config.TempSettings.SettingToModuleCache[setting] ~= nil then
            Logger.log_error(
                "\ay[Setting] \arError: Key %s exists in multiple settings tables: \aw%s \arand \aw%s! Keeping first but this should be fixed!",
                setting,
                Config.TempSettings.SettingToModuleCache[setting], module)
            self:RegisterCategoryToSettingMapping(setting)
        else
            Config.TempSettings.SettingToModuleCache[setting] = module
            Config.TempSettings.SettingsLowerToNameCache[setting:lower()] = setting
            self:RegisterCategoryToSettingMapping(setting)
        end
    end

    if firstSaveRequired or settingsChanged then
        self:SaveModuleSettings(module, settings)
    end

    self.TempSettings.lastModuleRegisteredTime = os.time()

    Logger.log_debug("\agModule %s - registered settings!", module)
end

function Config:ClearModuleSettings(module)
    if not self.moduleSettings[module] then
        Logger.log_error("\arModule %s is not registered!", module)
        return
    end

    local settings = self.moduleSettings[module]
    for setting, _ in pairs(settings) do
        self:UnRegisterCategoryToSettingMapping(setting)
        Config.TempSettings.SettingsLowerToNameCache[setting:lower()] = nil
        Config.TempSettings.SettingToModuleCache[setting] = nil
    end

    self.moduleSettings[module] = nil
    self.moduleTempSettings[module] = nil
    self.moduleDefaultSettings[module] = nil
    self.moduleSettingCategories[module] = nil

    Logger.log_debug("\agModule %s - removed all settings!", module)
end

function Config:RequestPeerConfigs(peer)
    Comms.SendMessage(peer, self._name, "SendConfigs", { from = Comms.GetPeerName(), })
end

function Config:PackageConfig(module)
    return {
        peer = Comms.GetPeerName(),
        module = module,
        settings = Config:GetAllModuleSettings()[module],
        settingCategories = Config:GetAllModuleSettingCategories()[module],
        defaultSettings = Config:GetAllModuleDefaultSettings()[module],
    }
end

function Config:SendConfigs(data)
    Logger.log_debug("Received SendConfigs from %s - sending our configs.", data.from)
    local modules = { "Core", }

    for _, name in ipairs(Modules:GetModuleOrderedNames()) do
        table.insert(modules, name)
    end

    for _, name in ipairs(modules) do
        if Config.moduleSettings[name] ~= nil then
            Comms.SendMessage(data.from, self._name, "UpdatePeerSettings", self:PackageConfig(name))
        end
    end
end

function Config:BroadcastConfigs()
    local modules = { "Core", }

    for _, name in ipairs(Modules:GetModuleOrderedNames()) do
        table.insert(modules, name)
    end

    for _, name in ipairs(modules) do
        if Config.moduleSettings[name] ~= nil then
            Comms.BroadcastMessage(self._name, "UpdatePeerSettings", self:PackageConfig(name))
        end
    end
end

function Config:GetCurrentPeer()
    return self.currentPeer
end

function Config:GetLastModuleRegisteredTime()
    return self.TempSettings.lastModuleRegisteredTime
end

function Config:ClearAllModuleSettings()
    self.moduleSettings = {}
    self.moduleTempSettings = {}
    self.moduleDefaultSettings = {}
    self.moduleSettingCategories = {}
    self.TempSettings.SettingToModuleCache = {}
    self.TempSettings.SettingsLowerToNameCache = {}
    self.TempSettings.SettingsCategoryToSettingMapping = {}
    self.SettingsLoadComplete = false
end

function Config:SaveModuleSettings(module, settings)
    self.moduleSettings[module] = settings
    local defaultSettings = self:GetModuleDefaultSettings(module)
    local settingsCategories = self:GetModuleSettingCategories(module):toList() or {}

    if module == "Core" then
        self:SaveSettings()
    else
        Modules:ExecModule(module, "SaveSettings", false)
    end
    Logger.log_debug("\agModule %s - save settings requested!", module)

    -- broadcast the change to any listeners.
    Comms.BroadcastMessage(self._name, "UpdatePeerSettings",
        { peer = Comms.GetPeerName(), module = module, settings = settings, settingCategories = settingsCategories, defaultSettings = defaultSettings, })
end

function Config:GetAllPeerHeartbeats()
    return self.TempSettings.PeersHeartbeats or {}
end

function Config:GetPeerHeartbeatByName(peerName)
    return self.TempSettings.PeersHeartbeats[Comms.GetPeerName(peerName)] or {}
end

function Config:GetPeerHeartbeat(peer)
    return self.TempSettings.PeersHeartbeats[peer] or {}
end

function Config:UpdatePeerHeartbeat(peer, data)
    self.TempSettings.Peers:add(peer)
    Config.TempSettings.PeersHeartbeats[peer] = Config.TempSettings.PeersHeartbeats[peer] or {}
    Config.TempSettings.PeersHeartbeats[peer].LastHeartbeat = os.time()
    Config.TempSettings.PeersHeartbeats[peer].Data = data or {}
end

function Config:ValidatePeers()
    for peer, heartbeat in pairs(Config.TempSettings.PeersHeartbeats) do
        if os.time() - heartbeat.LastHeartbeat > Config:GetSetting("ActorPeerTimeout") then
            Logger.log_debug("\ayPeer \ag%s\ay has timed out, removing from active peer list.", peer)
            Config.TempSettings.Peers:remove(peer)
            Config.TempSettings.PeersHeartbeats[peer] = nil
            if self.currentPeer == peer then
                self.peerModuleSettings                                = {}
                self.peerModuleDefaultSettings                         = {}
                self.peerModuleSettingCategories                       = {}
                self.TempSettings.PeerModuleSettingsLowerToNameCache   = {}
                self.TempSettings.PeerSettingToModuleCache             = {}
                self.TempSettings.PeerSettingsCategoryToSettingMapping = {}
                self.currentPeer                                       = nil
            end
        end
    end
end

function Config:SetRemotePeer(peer)
    if self.currentPeer ~= peer then
        self.peerModuleSettings                                = {}
        self.peerModuleDefaultSettings                         = {}
        self.peerModuleSettingCategories                       = {}
        self.TempSettings.PeerModuleSettingsLowerToNameCache   = {}
        self.TempSettings.PeerSettingToModuleCache             = {}
        self.TempSettings.PeerSettingsCategoryToSettingMapping = {}
        self.currentPeer                                       = peer
        self.TempSettings.LastPeerConfigReceivedTime           = 0

        self:RequestPeerConfigs(peer)
    end
end

function Config:UpdatePeerSettings(data)
    local peer   = data.peer
    local module = data.module

    if self.currentPeer ~= peer then
        return
    end

    local settings, settingsCategories, defaultSettings = data.settings or {}, data.settingsCategories or {}, data.defaultSettings or {}

    self.peerModuleDefaultSettings[module] = defaultSettings

    -- remove old settings from caches
    for setting, _ in pairs(self.peerModuleSettings[module] or {}) do
        if self.TempSettings.PeerSettingsCategoryToSettingMapping and Config:PeerGetSettingDefaults(peer, setting) then
            local categoryListLen = #self.TempSettings.PeerSettingsCategoryToSettingMapping[Config:PeerGetSettingDefaults(peer, setting).Category] or 0
            for i = categoryListLen, 1, -1 do
                if self.TempSettings.PeerSettingsCategoryToSettingMapping[Config:PeerGetSettingDefaults(peer, setting).Category][i] == setting then
                    table.remove(self.TempSettings.PeerSettingsCategoryToSettingMapping[Config:PeerGetSettingDefaults(peer, setting).Category], i)
                    break
                end
            end
        end
        self.TempSettings.PeerSettingToModuleCache[setting] = nil
        self.TempSettings.PeerModuleSettingsLowerToNameCache[setting:lower()] = nil
    end

    self.peerModuleSettings[module] = deep_copy(settings or {})
    self.peerModuleSettingCategories[module] = Set.new(settingsCategories or {})

    for setting, _ in pairs(settings) do
        self.TempSettings.PeerSettingToModuleCache[setting] = module
        self.TempSettings.PeerModuleSettingsLowerToNameCache[setting:lower()] = setting
        self:PeerRegisterCategoryToSettingMapping(peer, setting)
    end

    self.TempSettings.LastPeerConfigReceivedTime = os.time()
end

function Config:GetPeerLastConfigReceivedTime(peer)
    if peer ~= self.currentPeer then
        return 0
    end

    return self.TempSettings.LastPeerConfigReceivedTime or 0
end

function Config:GetPeers()
    return self.TempSettings.Peers:toList() or {}
end

--- Adds the given name to the Assist List.
--- @param name string: The name of the assist to be added.
function Config:AssistAdd(name)
    local assistList = self:GetSetting('AssistList')

    for _, cur_name in ipairs(assistList or {}) do
        if cur_name == name then
            return
        end
    end

    table.insert(assistList, name)
    self:SetSetting('AssistList', assistList)
    Logger.log_info("\axAssist List: \ag%s\ax has been\ag added\ax to the list at position \at%d\ax!", name,
        #self:GetSetting('AssistList'))
end

function Config:AssistDelete(arg1)
    if not arg1 then
        Logger.log_error("\arAssist Delete: this command requires a valid argument!")
        return
    end

    local assistList = self:GetSetting('AssistList')

    if type(arg1) == 'string' then
        arg1 = self:ConvertAssistNameToID(arg1)
    end

    if type(arg1) == 'number' and arg1 > 0 then
        if arg1 <= #assistList then
            Logger.log_info("\axAssist List: \ag%s\ax has been \ardeleted\ax from the list!", assistList[arg1])
            table.remove(assistList, arg1)
            self:SetSetting('AssistList', assistList)
        else
            Logger.log_error("\arAssist Delete: %d is not a valid assist list ID!", arg1)
        end
        return
    end
    Logger.log_error("\arAssist Delete: %s was not on the list or is not a valid argument!", arg1)
end

function Config:AssistClear()
    Logger.log_info("Assist List: \ayThe Assist List has been cleared!")
    Config:SetSetting('AssistList', {})
end

--- Moves the OA with the given ID up.
--- @param id number The ID of the OA to move up.
function Config:AssistMoveUp(id)
    if type(id) == 'string' then
        id = self:ConvertAssistNameToID(id)
    end

    local newId = id - 1

    if newId < 1 then return end
    local assistList = self:GetSetting('AssistList')

    if id > #assistList then return end

    assistList[newId], assistList[id] = assistList[id], assistList[newId]
    Logger.log_info("\axAssist List: \ag%s\ax has been\ag moved up\ax to position \at%d", self:GetSetting('AssistList')[newId], newId)
    self:SetSetting('AssistList', assistList)
end

function Config:AssistMoveDown(id)
    if not id then
        Logger.log_error("\arAssist Move Down: this command requires a valid argument!")
        return
    end

    if type(id) == 'string' then
        id = self:ConvertAssistNameToID(id)
    end

    if id < 1 then return end
    local newId = id + 1
    local assistList = self:GetSetting('AssistList')

    if newId > #assistList then return end

    assistList[newId], assistList[id] = assistList[id], assistList[newId]

    Logger.log_info("\axAssist List: \ag%s\ax has been\ar moved down\ax to position \at%d", self:GetSetting('AssistList')[newId], newId)

    self:SetSetting('AssistList', assistList)
end

function Config:ConvertAssistNameToID(arg1)
    if arg1:match("^%d$") then
        arg1 = tonumber(arg1)
        return arg1
    else
        for idx, cur_name in ipairs(Config:GetSetting('AssistList') or {}) do
            if cur_name:lower() == arg1:lower() then
                arg1 = tonumber(idx)
                return arg1
            end
        end
    end
    return 0
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

function Config:GetLastHighlightChangeTime()
    return self.lastHighlightTime or 0
end

function Config:IsModuleHighlighted(module)
    self.TempSettings.HighlightedModules = self.TempSettings.HighlightedModules or Set.new({})
    return self.TempSettings.HighlightedModules:contains(module)
end

function Config:ClearAllHighlightedModules()
    self.TempSettings.HighlightedModules = Set.new({})
    self.lastHighlightTime = os.time()
end

function Config:OpenOptionsUIAndHighlightModule(module)
    self:SetSetting("EnableOptionsUI", true)
    self:HighlightModule(module)
end

function Config:HighlightModule(module)
    -- only allow for 1 at a time for now but later we might enhance this.
    self.TempSettings.HighlightedModules = Set.new({})
    self.TempSettings.HighlightedModules:add(module)
    self.lastHighlightTime = os.time()
end

function Config:UnhighlightModule(module)
    self.TempSettings.HighlightedModules = self.TempSettings.HighlightedModules or Set.new({})
    self.TempSettings.HighlightedModules:remove(module)
    self.lastHighlightTime = os.time()
end

---@param config string
---@param value any
---@return boolean
function Config:HandleBind(config, value)
    local handled = false

    if not config or config:lower() == "show" or config:len() == 0 then
        self:UpdateCommandHandlers()

        local allModules = {}
        local submoduleSettings = self.moduleSettings or {}

        for name, _ in pairs(submoduleSettings) do
            if name ~= "Core" then
                table.insert(allModules, name)
            end
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

---@param config string
---@param value any
---@return boolean
function Config:HandleTempSet(config, value)
    local handled = false

    if not config or config:lower() == "show" or config:len() == 0 then
        self:HandleBind("show", value)
        return true
    end

    if self.CommandHandlers[config:lower()] ~= nil then
        Config:SetTempSetting(config, value)
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
    return tonumber((self:GetSetting('BgOpacity') or 100) / 100) or 1.0
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
    -- if mount item is empty and we are on a mount then the user probably wants mount on.
    return (Config:GetSetting('MountItem') or ""):len() > 0 and Config:GetSetting('DoMount') ~= 2 and ((mq.TLO.Me.Mount.ID() or 0) > 0)
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
