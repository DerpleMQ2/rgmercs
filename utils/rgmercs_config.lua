local mq                             = require('mq')
local RGMercUtils                    = require("utils.rgmercs_utils")
local Set                            = require("mq.Set")

local Config                         = {
    _version = '1.0 Beta',
    _subVersion = "2023 Laurion\'s Song!",
    _name =
    "RGMercs Lua Edition",
    _author = 'Derple, Morisato, Greyn, Algar, Grimmier',
}
Config.__index                       = Config
Config.settings                      = {}

-- Global State
Config.Globals                       = {}
Config.Globals.MainAssist            = ""
Config.Globals.AutoTargetID          = 0
Config.Globals.BurnNow               = false
Config.Globals.SubmodulesLoaded      = false
Config.Globals.PauseMain             = false
Config.Globals.LastMove              = nil
Config.Globals.BackOffFlag           = false
Config.Globals.InMedState            = false
Config.Globals.LastPetCmd            = 0
Config.Globals.LastFaceTime          = 0
Config.Globals.CurZoneId             = mq.TLO.Zone.ID()
Config.Globals.CurLoadedChar         = mq.TLO.Me.DisplayName()
Config.Globals.CurLoadedClass        = mq.TLO.Me.Class.ShortName()
Config.Globals.CurServer             = mq.TLO.EverQuest.Server():gsub(" ", "")
Config.Globals.CastResult            = 0
Config.Globals.BuildType             = mq.TLO.MacroQuest.BuildName()
Config.Globals.Minimized             = false
Config.Globals.LastUsedSpell         = "None"

-- Constants
Config.Constants                     = {}
Config.Constants.RGCasters           = Set.new({ "BRD", "BST", "CLR", "DRU", "ENC", "MAG", "NEC", "PAL", "RNG", "SHD",
    "SHM", "WIZ", })
Config.Constants.RGMelee             = Set.new({ "BRD", "SHD", "PAL", "WAR", "ROG", "BER", "MNK", "RNG", "BST", })
Config.Constants.RGHybrid            = Set.new({ "SHD", "PAL", "RNG", "BST", "BRD", })
Config.Constants.RGTank              = Set.new({ "WAR", "PAL", "SHD", })
Config.Constants.RGModRod            = Set.new({ "BST", "CLR", "DRU", "SHM", "MAG", "ENC", "WIZ", "NEC", "PAL", "RNG",
    "SHD", })
Config.Constants.RGPetClass          = Set.new({ "BST", "NEC", "MAG", "SHM", "ENC", "SHD", })
Config.Constants.RGMezAnims          = Set.new({ 1, 5, 6, 27, 43, 44, 45, 80, 82, 112, 134, 135, })
Config.Constants.ModRods             = { "Modulation Shard", "Transvergence", "Modulation", "Modulating", }
Config.Constants.SpellBookSlots      = 1120

Config.Constants.CastResults         = {
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

Config.Constants.CastResultsIdToName = {}
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

-- Defaults
Config.DefaultConfig = {

    -- [ CLICKIES ] --
    ['UseClickies']          = { DisplayName = "Use Clickies", Category = "Clickies", Index = 0, Tooltip = "Use items during Downtime.", Default = true, ConfigType = "Normal", },
    ['ClickyItem1']          = { DisplayName = "Clicky Item 1", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 1, },
    ['ClickyItem2']          = { DisplayName = "Clicky Item 2", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 2, },
    ['ClickyItem3']          = { DisplayName = "Clicky Item 3", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 3, },
    ['ClickyItem4']          = { DisplayName = "Clicky Item 4", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 4, },
    ['ClickyItem5']          = { DisplayName = "Clicky Item 5", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 5, },
    ['ClickyItem6']          = { DisplayName = "Clicky Item 6", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 6, },
    ['ClickyItem7']          = { DisplayName = "Clicky Item 7", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 7, },
    ['ClickyItem8']          = { DisplayName = "Clicky Item 8", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 8, },
    ['ClickyItem9']          = { DisplayName = "Clicky Item 9", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 9, },
    ['ClickyItem10']         = { DisplayName = "Clicky Item 10", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 10, },
    ['ClickyItem11']         = { DisplayName = "Clicky Item 11", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 11, },
    ['ClickyItem12']         = { DisplayName = "Clicky Item 12", Category = "Clickies", Tooltip = "Clicky Item to use During Downtime", Type = "ClickyItem", Default = "", ConfigType = "Normal", Index = 12, },

    -- [ MED/MANA ] --
    ['DoMed']                = { DisplayName = "Do Meditate", Category = "Med/Mana", Index = 1, Tooltip = "Choose if/when to meditate.", Type = "Combo", ComboOptions = { 'Off', 'Out of Combat', 'In Combat', }, Default = 2, Min = 1, Max = 3, ConfigType = "Normal", },
    ['HPMedPct']             = { DisplayName = "Med HP %", Category = "Med/Mana", Index = 2, Tooltip = "What HP % to hit before medding.", Default = 60, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['ManaMedPct']           = { DisplayName = "Med Mana %", Category = "Med/Mana", Index = 4, Tooltip = "What Mana % to hit before medding.", Default = 60, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['EndMedPct']            = { DisplayName = "Med Endurance %", Category = "Med/Mana", Index = 6, Tooltip = "What Endurance % to hit before medding.", Default = 60, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['ManaMedPctStop']       = { DisplayName = "Med Mana % Stop", Category = "Med/Mana", Index = 5, Tooltip = "What Mana % to hit before stopping medding.", Default = 90, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['EndMedPctStop']        = { DisplayName = "Med Endurance % Stop", Category = "Med/Mana", Index = 7, Tooltip = "What Endurance % to hit before stopping medding.", Default = 90, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['HPMedPctStop']         = { DisplayName = "Med HP % Stop", Category = "Med/Mana", Index = 3, Tooltip = "What HP % to hit before stopping medding.", Default = 90, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['AfterMedCombatDelay']  = { DisplayName = "After Combat Med Delay", Category = "Med/Mana", Index = 9, Tooltip = "How long to delay after combat in seconds before sitting.", Default = 6, Min = 0, Max = 60, ConfigType = "Advanced", },
    ['StandWhenDone']        = { DisplayName = "Stand When Done Medding", Category = "Med/Mana", Index = 8, Tooltip = "Stand when done medding or wait until combat.", Default = true, },
    ['DoModRod']             = { DisplayName = "Do Mod Rod", Category = "Med/Mana", Index = 10, Tooltip = "Auto use Mod Rods if we have them", Default = true, ConfigType = "Advanced", },
    ['ModRodManaPct']        = { DisplayName = "Mod Rod Mana %", Category = "Med/Mana", Index = 11, Tooltip = "What Mana % to hit before using a rod.", Default = 30, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['ClarityPotion']        = { DisplayName = "Clarity Potion", Category = "Med/Mana", Index = 12, Tooltip = "Name of your Clarity Pot", Default = "Distillate of Clarity", ConfigType = "Advanced", },

    -- [ PET / MERC] --
    ['DoPet']                = { DisplayName = "Do Pet", Category = "Pet/Merc", Index = 1, Tooltip = "Enable using Pets.", Default = true, ConfigType = "Normal", },
    ['PetEngagePct']         = { DisplayName = "Pet Engage HPs", Category = "Pet/Merc", Index = 2, Tooltip = "Send in pet when target hits [x] HP %.", Default = 90, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['ShrinkPetItem']        = { DisplayName = "Shrink Pet Item", Category = "Pet/Merc", Index = 4, Tooltip = "Item to use to shrink your pet", Type = "ClickyItem", Default = "", ConfigType = "Normal", },
    ['DoShrinkPet']          = { DisplayName = "Do Pet Shrink", Category = "Pet/Merc", Index = 3, Tooltip = "Enable auto shrinking your pet", Default = false, ConfigType = "Normal", },
    ['DoMercenary']          = { DisplayName = "Merc Control", Category = "Pet/Merc", Index = 5, Tooltip = "Allow RGMercs to issue mercenary commands.", Default = true, ConfigType = "Normal", },

    -- [ ENGAGE ] --
    ['SafeTargeting']        = { DisplayName = "Use Safe Targeting", Category = "Engage", Index = 8, Tooltip = "Do not target mobs that are fighting others.", Default = true, ConfigType = "Advanced", },
    ['AssistOutside']        = { DisplayName = "Assist Outside of Group", Category = "Engage", Index = 13, Tooltip = "Allow assisting characters outside of your group.", Default = false, ConfigType = "Advanced", },
    ['AssistRange']          = { DisplayName = "Assist Range", Category = "Engage", Index = 3, Tooltip = "Distance to the target before you engage.", Default = Config.Constants.RGCasters:contains(Config.Globals.CurLoadedClass) and 90 or 45, Min = 0, Max = 200, ConfigType = "Advanced", },
    ['AutoAssistAt']         = { DisplayName = "Auto Assist At", Category = "Engage", Index = 2, Tooltip = "Melee attack when target hits [x] HP %.", Default = 98, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['StickHow']             = { DisplayName = "Stick How", Category = "Engage", Index = 6, Tooltip = "Custom /stick command", Default = "", ConfigType = "Advanced", },
    ['AllowMezBreak']        = { DisplayName = "Allow Mez Break", Category = "Engage", Index = 10, Tooltip = "Allow Mez Breaking.", Default = false, ConfigType = "Advanced", },
    ['DoAutoTarget']         = { DisplayName = "Auto Target", Category = "Engage", Index = 7, Tooltip = "Automatically change targets.", Default = true, ConfigType = "Normal", },
    ['StayOnTarget']         = { DisplayName = "Stay On Target", Category = "Engage", Index = 9, Tooltip = "Stick to your target. Default: true; Tank Mode Defaults: false. false allows intelligent target swapping based on aggro/named/ etc.", Default = (not Config.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName())), ConfigType = "Advanced", },
    ['DoAutoEngage']         = { DisplayName = "Auto Engage", Category = "Engage", Index = 1, Tooltip = "Automatically engage targets.", Default = true, ConfigType = "Advanced", },
    ['DoMelee']              = { DisplayName = "Enable Melee Combat", Category = "Engage", Index = 4, Tooltip = "Melee targets.", Default = Config.Constants.RGMelee:contains(Config.Globals.CurLoadedClass), ConfigType = "Normal", },
    ['AutoStandFD']          = { DisplayName = "Stand from FD in Combat", Category = "Engage", Index = 12, Tooltip = "Auto stands you up from FD if combat starts.", Default = true, ConfigType = "Normal", },
    ['FaceTarget']           = { DisplayName = "Face Target in Combat", Category = "Engage", Index = 5, Tooltip = "Periodically /face your target while in combat.", Default = true, ConfigType = "Advanced", },
    ['FollowMarkTarget']     = { DisplayName = "Follow Mark Target", Category = "Engage", Index = 15, Tooltip = "Auto target MA target Marks.", Default = false, ConfigType = "Advanced", },
    ['OutsideAssistList']    = { DisplayName = "List of Outsiders to Assist", Category = "Engage", Index = 14, Tooltip = "List of Outsiders to Assist", Type = "Custom", Default = {}, ConfigType = "Advanced", },

    -- [SPELLS/ABILS] --
    ['ManaToNuke']           = { DisplayName = "Mana to Nuke", Category = "Spells/Abils", Index = 1, Tooltip = "Minimum % Mana in order to continue to cast nukes.", Default = 30, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['ManaToDot']            = { DisplayName = "Mana to Dot", Category = "Spells/Abils", Index = 2, Tooltip = "Minimum % Mana in order to continue to cast dots.", Default = 40, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['ManaToDebuff']         = { DisplayName = "Mana to Debuff", Category = "Spells/Abils", Index = 4, Tooltip = "Minimum % Mana in order to continue to cast debuffs.", Default = 1, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['HPStopDOT']            = { DisplayName = "Stop Dots (Trash):", Category = "Spells/Abils", Index = 2, Tooltip = "Stop casting DOTs when trash mobs hit [x] HP %.", Default = 50, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['NamedStopDOT']         = { DisplayName = "Stop Dots (Named):", Category = "Spells/Abils", Index = 3, Tooltip = "Stop casting DOTs when named mobs hit [x] HP %.", Default = 25, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['CastReadyDelayFact']   = { DisplayName = "Cast Ready Delay Factor", Category = "Spells/Abils", Index = 8, Tooltip = "Wait Ping * [n] ms before saying we are ready to cast.", Default = 0, Min = 0, Max = 10, ConfigType = "Advanced", },
    ['SongClipDelayFact']    = { DisplayName = "Song Clip Delay Factor", Category = "Spells/Abils", Index = 9, Tooltip = "Wait Ping * [n] ms to allow songs to take effect before singing the next.", Default = 2, Min = 1, Max = 10, ConfigType = "Advanced", },
    ['DebuffMinCon']         = { DisplayName = "Debuff Min Con", Category = "Spells/Abils", Index = 5, Tooltip = "Min Con to use debuffs on", Default = 4, Min = 1, Max = #Config.Constants.ConColors, Type = "Combo", ComboOptions = Config.Constants.ConColors, ConfigType = "Advanced", },
    ['DebuffNamedAlways']    = { DisplayName = "Always Debuff Named", Category = "Spells/Abils", Index = 6, Tooltip = "Debuff named regardless of con color", Default = true, ConfigType = "Advanced", },
    ['WaitOnGlobalCooldown'] = { DisplayName = "Wait on Global Cooldown", Category = "Spells/Abils", Index = 7, Tooltip = "Wait on Global Cooldown before trying to cast more spells (Should NOT be used by classes that have Weave rotations!)", Default = false, ConfigType = "Advanced", },
    ['DoAlliance']           = { DisplayName = "Do Alliance", Category = "Spells/Abils", Index = 10, Tooltip = "Automatically cast Alliance spells.", Default = true, ConfigType = "Advanced", },
    ['StandFailedFD']        = { DisplayName = "Stand on Failed FD", Category = "Spells/Abils", Index = 11, Tooltip = "Auto stands you up if you fall to the ground.", Default = true, ConfigType = "Advanced", },

    -- [ Tank/MA ] --
    ['MovebackWhenTank']     = { DisplayName = "Moveback as Tank", Category = "Tank/MA", Index = 1, Tooltip = "Adds 'moveback' to stick command when tanking. Helpful to keep mobs from getting behind you.", Default = false, ConfigType = "Advanced", },
    ['MovebackWhenBehind']   = { DisplayName = "Moveback if Mob Behind", Category = "Tank/MA", Index = 2, Tooltip = "Causes you to move back if we detect an XTarget is behind you when tanking.", Default = true, ConfigType = "Advanced", },
    ['MovebackDistance']     = { DisplayName = "Units to Moveback", Category = "Tank/MA", Index = 3, Tooltip = "Default: 20. May require adjustment based on runspeed.", Default = 20, Min = 1, Max = 40, ConfigType = "Advanced", },
    ['ForceKillPet']         = { DisplayName = "Force Kill Pet", Category = "Tank/MA", Index = 4, Tooltip = "Force kill pcpet if on xtarget.", Default = true, ConfigType = "Advanced", },
    ['OnlyScanXT']           = { DisplayName = "Only Scan XTargets", Category = "Tank/MA", Index = 5, Tooltip = "When MA looks for a target use only XTargets instead of doing an area scan, area scan can cause aggro to unintentional mobs use wih caution.", Default = true, ConfigType = "Advanced", },
    ['MAScanZRange']         = { DisplayName = "Main Assist Scan ZRange", Category = "Tank/MA", Index = 6, Tooltip = "Distance in Z direction to look for targets.", Default = 45, Min = 15, Max = 200, ConfigType = "Advanced", },

    -- [ BUFFS ] --
    ['DoBuffs']              = { DisplayName = "Do Buffs", Category = "Buffs", Index = 1, Tooltip = "Do Non-Class Specific Buffs.", Default = true, ConfigType = "Advanced", },
    ['BuffWaitMoveTimer']    = { DisplayName = "Buff Wait Timer", Category = "Buffs", Index = 2, Tooltip = "Seconds to wait after stoping movement before doing buffs.", Default = 5, Min = 0, Max = 60, ConfigType = "Advanced", },
    ['WardsPlease']          = { DisplayName = "Enable Wards", Category = "Buffs", Index = 8, Tooltip = "Enable Ward Type Spells", Default = true, ConfigType = "Normal", },
    ['MountItem']            = { DisplayName = "Mount Item", Category = "Buffs", Index = 5, Tooltip = "Item to use to cast mount", Type = "ClickyItem", Default = "", ConfigType = "Normal", },
    ['DoMount']              = { DisplayName = "Summon Mount:", Category = "Buffs", Index = 4, Tooltip = "Choose how/when to use mounts.", Type = "Combo", ComboOptions = { 'Never', 'For use as mount', 'For buff only', }, Default = 1, Min = 1, Max = 3, ConfigType = "Normal", },
    ['ShrinkItem']           = { DisplayName = "Shrink Item", Category = "Buffs", Index = 7, Tooltip = "Item to use to Shrink yourself", Type = "ClickyItem", Default = "", ConfigType = "Normal", },
    ['DoShrink']             = { DisplayName = "Do Shrink", Category = "Buffs", Index = 6, Tooltip = "Enable auto shrinking", Default = false, ConfigType = "Normal", },
    ['BuffRezables']         = { DisplayName = "Buff Rezables", Category = "Buffs", Index = 3, Tooltip = "If this PC has a corpse near us buff them even though they are likely to get rezed.", Default = false, ConfigType = "Advanced", },

    -- [ HEAL/REZ] --
    ['PriorityHealing']      = { DisplayName = "Priority Healing", Category = "Heal/Rez", Index = 10, Tooltip = "Standby for healing over engaging in combat actions.", Default = false, ConfigType = "Advanced", },
    ['BreakInvis']           = { DisplayName = "Break Invis", Category = "Heal/Rez", Index = 9, Tooltip = "Break invis to heal when out of combat only. Healers will always break invis in combat.", Default = false, ConfigType = "Advanced", },
    ['MainHealPoint']        = { DisplayName = "Main Heal Point", Category = "Heal/Rez", Index = 3, Tooltip = "Minimum PctHPs to use the Main Heal Rotation.", Default = 90, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['BigHealPoint']         = { DisplayName = "Big Heal Point", Category = "Heal/Rez", Index = 4, Tooltip = "Minimum PctHPs to use the Big Heal Rotation.", Default = 50, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['GroupHealPoint']       = { DisplayName = "Group Heal Point", Category = "Heal/Rez", Index = 5, Tooltip = "Minimum PctHPs to use the Group Heal Rotation.", Default = 85, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['PetHealPoint']         = { DisplayName = "Pet Heal Point", Category = "Heal/Rez", Index = 8, Tooltip = "Minimum PctHPs to use the Pet Heal Rotation.", Default = 85, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['GroupInjureCnt']       = { DisplayName = "Group Injured Count", Category = "Heal/Rez", Index = 6, Tooltip = "Number of group members that must be under the above threshold.", Default = 3, Min = 1, Max = 5, ConfigType = "Advanced", },
    ['DoPetHeals']           = { DisplayName = "Do Pet Heals", Category = "Heal/Rez", Index = 7, Tooltip = "Heal pets in your group", Default = false, ConfigType = "Advanced", },
    ['MaxHealPoint']         = { DisplayName = "Healing Threshold", Category = "Heal/Rez", Index = 1, Tooltip = "Minimum PctHPs to check if a target needs healing.", Default = 90, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['LightHealPoint']       = { DisplayName = "Light Heal Point", Category = "Heal/Rez", Index = 2, Tooltip = "Minimum PctHPs to use the Light Heal Rotation.", Default = 65, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['CureInterval']         = { DisplayName = "Cure Check Interval", Category = "Heal/Rez", Index = 11, Tooltip = "Perform check to see if cures are needed every X seconds. ***WARNING: RESOURCE INTENSIVE*** Default: 5", Default = 5, Min = 1, Max = 30, ConfigType = "Advanced", },
    ['RetryRezDelay']        = { DisplayName = "Retry Rez Delay", Category = "Heal/Rez", Index = 12, Tooltip = "Attempt to rez a corpse every X seconds.", Default = 6, Min = 1, Max = 60, ConfigType = "Advanced", },
    ['DoBattleRez']          = { DisplayName = "Do Battle Rez", Category = "Heal/Rez", Index = 13, Tooltip = "Use Rez while in combat", Default = RGMercUtils.MyClassIs("clr"), ConfigType = "Advanced", },
    ['InstantRelease']       = { DisplayName = "Instant Release", Category = "Heal/Rez", Index = 14, Tooltip = "Instantly release when you die.", Default = false, ConfigType = "Advanced", },

    -- [ BURNS ] --
    ['BurnAuto']             = { DisplayName = "Auto Burn", Category = "Burns", Index = 1, Tooltip = "Automatically burn when the conditions below are met.", Default = false, ConfigType = "Normal", },
    ['BurnAlways']           = { DisplayName = "Auto Burn Always", Category = "Burns", Index = 2, Tooltip = "Burn on any/every target.", Default = false, ConfigType = "Advanced", },
    ['BurnMobCount']         = { DisplayName = "Auto Burn Mob Count", Category = "Burns", Index = 4, Tooltip = "Number of haters before we start burning.", Default = 3, Min = 1, Max = 10, ConfigType = "Advanced", },
    ['BurnNamed']            = { DisplayName = "Auto Burn Named", Category = "Burns", Index = 5, Tooltip = "Automatically burn named mobs (must be present in RGMerc Named List or SpawnMaster ini).", Default = false, ConfigType = "Advanced", },

    -- [ UI ] --
    ['BgOpacity']            = { DisplayName = "Background Opacity", Category = "UI", Tooltip = "Opacity for the RGMercs UI", Default = 100, Min = 20, Max = 100, },
    ['ShowAllOptionsMain']   = { DisplayName = "Show All Options on Main", Category = "UI", Tooltip = "Show all options on the main panel", Default = true, },
    ['FrameEdgeRounding']    = { DisplayName = "Frame Edge Rounding", Category = "UI", Tooltip = "Frame Edge Rounding for the RGMercs UI", Default = 6, Min = 0, Max = 50, },
    ['ScrollBarRounding']    = { DisplayName = "Scroll Bar Rounding", Category = "UI", Tooltip = "Frame Edge Rounding for the RGMercs UI", Default = 10, Min = 0, Max = 50, },
    ['ShowAdvancedOpts']     = { DisplayName = "Show Advanced Options", Category = "UI", Tooltip = "Show Advanced Options", Type = "Custom", Default = false, ConfigType = "Advanced", },
    ['EscapeMinimizes']      = { DisplayName = "Minimize on Escape", Category = "UI", Tooltip = "Minimizes the window if focused and Escape is pressed", Default = false, ConfigType = "Normal", },

    -- [ Debug ] --
    ['LogLevel']             = { DisplayName = "Log Level", Category = "Debug", Tooltip = "1 = Errors, 2 = Warnings, 3 = Info, 4 = Debug, 5 = Verbose", Type = "Custom", Default = 3, Min = 1, Max = 5, ConfigType = "Advanced", },
    ['LogToFile']            = { DisplayName = "Log To File", Category = "Debug", Tooltip = "Write all logs to the mqlog file.", Type = "Custom", Default = false, ConfigType = "Advanced", },

    -- [ ANNOUNCEMENTS ] --
    ['AnnounceTarget']       = { DisplayName = "Announce Target", Category = "Announcements", Tooltip = "Announces Target over DanNet in kissassist format, incase you are running a mixed set on your group.Config", Default = false, ConfigType = "Advanced", },
    ['AnnounceTargetGroup']  = { DisplayName = "Announce Target to Group", Category = "Announcements", Tooltip = "Announces Target over /gsay", Default = false, ConfigType = "Advanced", },
    ['MezAnnounce']          = { DisplayName = "Mez Announce", Category = "Announcements", Default = false, Tooltip = "Set to announce mez casts.", ConfigType = "Advanced", },
    ['MezAnnounceGroup']     = { DisplayName = "Mez Announce to Group", Category = "Announcements", Default = false, Tooltip = "Set to announce mez casts In group.", ConfigType = "Advanced", },
    ['CharmAnnounce']        = { DisplayName = "Charm Announce", Category = "Announcements", Default = false, Tooltip = "Set to announce Charm casts.", ConfigType = "Advanced", },
    ['CharmAnnounceGroup']   = { DisplayName = "Charm Announce to Group", Category = "Announcements", Default = false, Tooltip = "Set to announce Charm casts In group.", ConfigType = "Advanced", },
    ['HealAnnounce']         = { DisplayName = "Heal Announce", Category = "Announcements", Default = false, Tooltip = "Set to announce Heal casts.", ConfigType = "Advanced", },
    ['HealAnnounceGroup']    = { DisplayName = "Heal Announce to Group", Category = "Announcements", Default = false, Tooltip = "Set to announce Heal casts In group.", ConfigType = "Advanced", },
    ['CureAnnounce']         = { DisplayName = "Cure Announce", Category = "Announcements", Default = false, Tooltip = "Set to announce Cure casts.", ConfigType = "Advanced", },
    ['CureAnnounceGroup']    = { DisplayName = "Cure Announce to Group", Category = "Announcements", Default = false, Tooltip = "Set to announce Cure casts In group.", ConfigType = "Advanced", },
}

Config.DefaultCategories = Set.new({})
for _, v in pairs(Config.DefaultConfig) do
    if v.Type ~= "Custom" then
        Config.DefaultCategories:add(v.Category)
    end
end

Config.CommandHandlers = {}

function Config:GetConfigFileName()
    return mq.configDir ..
        '/rgmercs/PCConfigs/RGMerc_' .. self.Globals.CurServer .. "_" .. self.Globals.CurLoadedChar .. '.lua'
end

function Config:SaveSettings(doBroadcast)
    mq.pickle(self:GetConfigFileName(), self.settings)
    RGMercsLogger.set_log_level(RGMercUtils.GetSetting('LogLevel'))
    RGMercsLogger.set_log_to_file(RGMercUtils.GetSetting('LogToFile'))

    if doBroadcast == true then
        RGMercUtils.BroadcastUpdate("main", "LoadSettings")
    end
end

function Config:LoadSettings()
    self.Globals.CurLoadedChar  = mq.TLO.Me.DisplayName()
    self.Globals.CurLoadedClass = mq.TLO.Me.Class.ShortName()
    self.Globals.CurServer      = mq.TLO.EverQuest.Server():gsub(" ", "")
    RGMercsLogger.log_info(
        "\ayLoading Main Settings for %s!",
        self.Globals.CurLoadedChar)

    local needSave = false

    local config, err = loadfile(self:GetConfigFileName())
    if err or not config then
        RGMercsLogger.log_error("\ayUnable to load global settings file(%s), creating a new one!",
            self:GetConfigFileName())
        self.settings = {}
        needSave = true
    else
        self.settings = config()
    end

    local settingsChanged = false

    -- Setup Defaults
    self.settings, settingsChanged = RGMercUtils.ResolveDefaults(Config.DefaultConfig, self.settings)

    if needSave or settingsChanged then
        self:SaveSettings(false)
    end

    return true
end

function Config:UpdateCommandHandlers()
    self.CommandHandlers = {}

    local submoduleSettings = RGMercModules:ExecAll("GetSettings")
    local submoduleDefaults = RGMercModules:ExecAll("GetDefaultSettings")

    submoduleSettings["Core"] = self.settings
    submoduleDefaults["Core"] = Config.DefaultConfig

    for moduleName, moduleSettings in pairs(submoduleSettings) do
        for setting, _ in pairs(moduleSettings or {}) do
            local handled, usageString = self:GetUsageText(setting or "", true, submoduleDefaults[moduleName] or {})

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
    end
end

---@param config string
---@param showUsageText boolean
---@param defaults table
---@return boolean
---@return string
function Config:GetUsageText(config, showUsageText, defaults)
    local handledType = false
    local usageString = showUsageText and string.format("/rgl set %s ", RGMercUtils.PadString(config, 25, false)) or ""
    local configData = defaults[config]

    local rangeText = ""
    local defaultText = ""
    local currentText = ""

    if type(configData.Default) == 'number' then
        rangeText = string.format("\aw<\a-y%d\aw-\a-y%d\ax>", configData.Min or 0, configData.Max or 999)
        defaultText = string.format("[\a-tDefault: %d\ax]", configData.Default)
        currentText = string.format("[\a-gCurrent: %d\ax]", RGMercUtils.GetSetting(config))
        handledType = true
    elseif type(configData.Default) == 'boolean' then
        rangeText = string.format("\aw<\a-yon\aw|\a-yoff\ax>")
        ---@diagnostic disable-next-line: param-type-mismatch
        defaultText = string.format("[\a-tDefault: %s\ax]", RGMercUtils.BoolToString(configData.Default))
        currentText = string.format("[\a-gCurrent: %s\ax]", RGMercUtils.BoolToString(RGMercUtils.GetSetting(config)))
        handledType = true
    elseif type(configData.Default) == 'string' then
        rangeText = string.format("\aw<\"str\">")
        defaultText = string.format("[\a-tDefault: \"%s\"\ax]", configData.Default)
        currentText = string.format("[\a-gCurrent: \"%s\"\ax]", RGMercUtils.GetSetting(config))
        handledType = true
    end

    usageString = usageString ..
        string.format("%s %s %s", RGMercUtils.PadString(rangeText, 20, false),
            RGMercUtils.PadString(currentText, 20, false), RGMercUtils.PadString(defaultText, 20, false)
        )

    return handledType, usageString
end

function Config:GetSettings()
    return self.settings
end

function Config:SettingsLoaded()
    return self.settings ~= nil
end

function Config:GetTimeSinceLastMove()
    return os.clock() - self.Globals.LastMove.TimeAtMove
end

function Config:GetCommandHandlers()
    return { module = "Config", CommandHandlers = self.CommandHandlers, }
end

---@param config string
---@param value any
---@return boolean
function Config:HandleBind(config, value)
    local handled = false

    if not config or config:lower() == "show" or config:len() == 0 then
        self:UpdateCommandHandlers()

        local allModules = {}
        local submoduleSettings = RGMercModules:ExecAll("GetSettings")
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
            if not RGMercUtils.TableContains(sortedCategories[d.subModule], d.category) then
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
                            RGMercUtils.PadString(d.usage, 100, false), d.about)
                    end
                end
            end
        end
        return true
    end

    if self.CommandHandlers[config:lower()] ~= nil then
        RGMercUtils.SetSetting(config, value)
        handled = true
    else
        RGMercsLogger.log_error("\at%s\aw - \arNot a valid config setting!\ax", config)
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

return Config
