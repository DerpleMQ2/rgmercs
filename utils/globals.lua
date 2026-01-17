local mq                              = require("mq")
local Set                             = require("mq.set")

-- very simple table to hold our globals that includes nothing.

local Globals                         = {}
Globals.__index                       = Globals

Globals.MainAssist                    = ""
Globals.ScriptDir                     = ""
Globals.AutoTargetID                  = 0
Globals.ForceTargetID                 = 0
Globals.AutoTargetIsNamed             = false
Globals.ForceCombatID                 = 0
Globals.LastPulledID                  = 0
Globals.CurrentState                  = "None"
Globals.IgnoredTargetIDs              = Set.new({})
Globals.SubmodulesLoaded              = false
Globals.PauseMain                     = false
Globals.LastMove                      = nil
Globals.BackOffFlag                   = false
Globals.InMedState                    = false
Globals.LastPetCmd                    = 0
Globals.LastFaceTime                  = 0
Globals.CurZoneId                     = mq.TLO.Zone.ID()
Globals.CurInstance                   = mq.TLO.Me.Instance()
Globals.CurLoadedChar                 = mq.TLO.Me.DisplayName()
Globals.CurLoadedClass                = mq.TLO.Me.Class.ShortName()
Globals.CurServer                     = mq.TLO.EverQuest.Server()
Globals.CurServerNormalized           = mq.TLO.EverQuest.Server():gsub(" ", "")
Globals.CastResult                    = 0
Globals.BuildType                     = mq.TLO.MacroQuest.BuildName()
Globals.Minimized                     = false
Globals.LastUsedSpell                 = "None"
Globals.CorpseConned                  = false
Globals.RezzedCorpses                 = {}
Globals.SLPeerLooting                 = false
Globals.LastBurnCheck                 = false

Globals.Constants                     = {}

Globals.Constants.SupportedEmuServers = Set.new({ "Project Lazarus", "HiddenForest", "EQ Might", })
Globals.Constants.LootModuleTypes     = { 'None', 'LootNScoot', 'SmartLoot', }
Globals.Constants.RGCasters           = Set.new({ "BRD", "BST", "CLR", "DRU", "ENC", "MAG", "NEC", "PAL", "RNG", "SHD",
    "SHM", "WIZ", })
Globals.Constants.RGMelee             = Set.new({ "BRD", "SHD", "PAL", "WAR", "ROG", "BER", "MNK", "RNG", "BST", })
Globals.Constants.RGHybrid            = Set.new({ "SHD", "PAL", "RNG", "BST", "BRD", })
Globals.Constants.RGTank              = Set.new({ "WAR", "PAL", "SHD", })
Globals.Constants.RGPetClass          = Set.new({ "BST", "NEC", "MAG", "SHM", "ENC", "SHD", })
Globals.Constants.RGNotMezzedAnims    = Set.new({ 1, 5, 6, 27, 43, 44, 45, 80, 82, 112, 134, 135, })
Globals.Constants.ModRods             = { "Modulation Shard", "Transvergence", "Modulation", "Modulating", "Azure Mind Crystal", }
Globals.Constants.ModRodUse           = { "Never", "Combat", "Anytime", }
Globals.Constants.SpellBookSlots      = 1120
Globals.Constants.CastCompleted       = Set.new({ "CAST_SUCCESS", "CAST_IMMUNE", "CAST_TAKEHOLD", "CAST_RESISTED", "CAST_RECOVER", })

Globals.Constants.CastResults         = {
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

Globals.Constants.CastResultsIdToName = {}
for k, v in pairs(Globals.Constants.CastResults) do Globals.Constants.CastResultsIdToName[v] = k end

Globals.Constants.ExpansionNameToID = {
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

Globals.Constants.ExpansionIDToName = {}
for k, v in pairs(Globals.Constants.ExpansionNameToID) do Globals.Constants.ExpansionIDToName[v] = k end

Globals.Constants.LogLevels           = {
    "Errors",
    "Warnings",
    "Info",
    "Debug",
    "Verbose",
    "Super-Verbose",
}

Globals.Constants.BasicColors         = {
    Red         = ImVec4(0.8, 0.3, 0.3, 0.8),
    LightRed    = ImVec4(0.9, 0.5, 0.5, 0.8),
    Green       = ImVec4(0.3, 0.8, 0.3, 0.8),
    LightGreen  = ImVec4(0.6, 0.8, 0.4, 0.8),
    Blue        = ImVec4(0.3, 0.3, 0.8, 0.8),
    LightBlue   = ImVec4(0.4, 0.6, 0.8, 0.8),
    Yellow      = ImVec4(0.8, 0.8, 0.3, 0.8),
    LightYellow = ImVec4(0.9, 0.9, 0.4, 0.8),
    Purple      = ImVec4(0.8, 0.3, 0.8, 0.8),
    LightPurple = ImVec4(0.9, 0.4, 0.9, 0.8),
    Orange      = ImVec4(1.0, 0.5, 0.0, 0.8),
    LightOrange = ImVec4(1.0, 0.6, 0.2, 0.8),
    Grey        = ImVec4(0.7, 0.7, 0.7, 0.8),
    LightGrey   = ImVec4(0.9, 0.9, 0.9, 0.8),
    Cyan        = ImVec4(0.3, 0.8, 0.8, 0.8),
    White       = ImVec4(0.8, 0.8, 0.8, 0.8),
    Black       = ImVec4(0.0, 0.0, 0.0, 1.0),
}

Globals.Constants.DefaultColors       = {
    FTHighlight             = Globals.Constants.BasicColors.Orange,
    CharmReasonColor        = Globals.Constants.BasicColors.Yellow,
    ConditionPassColor      = Globals.Constants.BasicColors.Green,
    ConditionFailColor      = Globals.Constants.BasicColors.Red,
    ConditionMidColor       = Globals.Constants.BasicColors.Yellow,
    ConditionDisabledColor  = Globals.Constants.BasicColors.Grey,
    FAQCmdQuestionColor     = Globals.Constants.BasicColors.LightOrange,
    FAQUsageAnswerColor     = Globals.Constants.BasicColors.LightBlue,
    FAQDescColor            = Globals.Constants.BasicColors.LightGreen,
    FAQLinkColor            = Globals.Constants.BasicColors.LightYellow,
    SearchHighlightColor    = Globals.Constants.BasicColors.Orange,
    AssistSpawnCloseColor   = Globals.Constants.BasicColors.LightGrey,
    AssistSpawnFarColor     = Globals.Constants.BasicColors.LightRed,
    BurnFlashColorOne       = Globals.Constants.BasicColors.Orange,
    BurnFlashColorTwo       = Globals.Constants.BasicColors.LightOrange,
    MainButtonPausedColor   = Globals.Constants.BasicColors.Red,
    MainButtonUnpausedColor = Globals.Constants.BasicColors.Green,
    MainCombatColor         = Globals.Constants.BasicColors.Red,
    MainDowntimeColor       = Globals.Constants.BasicColors.Green,
}

Globals.Constants.Colors              = {}

Globals.Constants.ConColors           = {
    "Grey", "Green", "Light Blue", "Blue", "White", "Yellow", "Red",
}
Globals.Constants.ConColorsNameToVec4 = {}
Globals.Constants.ConColorsNameToId   = {}
for i, v in ipairs(Globals.Constants.ConColors) do Globals.Constants.ConColorsNameToId[v:upper()] = i end

Globals.Constants.SpireChoices      = { "First", "Second", "Third", "Disabled", }

Globals.Constants.LastGemRemem      = { "Do Nothing", "Mem Previous Spell", "Mem Loadout Spell", }
Globals.Constants.DebuffChoice      = { "Never", "Based on Con Color", "Always", }

Globals.Constants.ScanNamedPriority = { "Named", "No Preference", "Non-Named", }
Globals.Constants.ScanHPPriority    = { "Lowest HP%", "No Preference", "Highest HP%", }
return Globals
