local mq                             = require('mq')
local RGMercUtils                    = require("utils.rgmercs_utils")
local Set                            = require("mq.Set")

local Config                         = { _version = '0.5a', _subVersion = "2023 Larions Song!", _name = "RGMercs Lua Edition", _author = 'Derple, Morisato, Greyn', }
Config.__index                       = Config
Config.settings                      = {}

-- Global State
Config.Globals                       = {}
Config.Globals.MainAssist            = ""
Config.Globals.AutoTargetID          = 0
Config.Globals.BurnNow               = false
Config.Globals.PauseMain             = false
Config.Globals.LastMove              = nil
Config.Globals.BackOffFlag           = false
Config.Globals.InMedState            = false
Config.Globals.LastPetCmd            = 0
Config.Globals.LastFaceTime          = 0
Config.Globals.CurLoadedChar         = mq.TLO.Me.DisplayName()
Config.Globals.CurLoadedClass        = mq.TLO.Me.Class.ShortName()
Config.Globals.CurServer             = mq.TLO.EverQuest.Server():gsub(" ", "")
Config.Globals.CastResult            = 0

-- Constants
Config.Constants                     = {}
Config.Constants.RGCasters           = Set.new({ "BRD", "BST", "CLR", "DRU", "ENC", "MAG", "NEC", "PAL", "RNG", "SHD", "SHM", "WIZ", })
Config.Constants.RGMelee             = Set.new({ "BRD", "SHD", "PAL", "WAR", "ROG", "BER", "MNK", "RNG", "BST", })
Config.Constants.RGHybrid            = Set.new({ "SHD", "PAL", "RNG", "BST", "BRD", })
Config.Constants.RGTank              = Set.new({ "WAR", "PAL", "SHD", })
Config.Constants.RGModRod            = Set.new({ "BST", "CLR", "DRU", "SHM", "MAG", "ENC", "WIZ", "NEC", "PAL", "RNG", "SHD", })
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

Config.SubModuleSettings   = {}

Config.ExpansionNameToID   = {
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

Config.Constants.LogLevels = {
    "Errors",
    "Warnings",
    "Info",
    "Debug",
    "Verbose",
}

Config.ExpansionIDToName   = {}
for k, v in pairs(Config.ExpansionNameToID) do Config.ExpansionIDToName[v] = k end

-- Defaults
Config.DefaultConfig = {
    -- [ UTILITIES ] --
    ['MountItem']         = { DisplayName = "Mount Item", Category = "Utilities", Tooltip = "Item to use to cast Mount", Type = "ClickyItem", Default = "", ConfigType = "Normal", },
    ['DoMount']           = { DisplayName = "Do Mount", Category = "Utilities", Tooltip = "0 = Disabled, 1 = Enabled, 2 = Dismount but Keep Buff", Type = "Combo", ComboOptions = { 'Off', 'Mount', 'Buff Only', }, Default = 1, Min = 1, Max = 3, ConfigType = "Normal", },
    ['ShrinkItem']        = { DisplayName = "Shrink Item", Category = "Utilities", Tooltip = "Item to use to Shrink yourself", Type = "ClickyItem", Default = "", ConfigType = "Normal", },
    ['DoShrink']          = { DisplayName = "Do Shrink", Category = "Utilities", Tooltip = "Enable auto shrinking", Default = false, ConfigType = "Normal", },
    ['PriorityHealing']   = { DisplayName = "Priority Healing", Category = "Utilities", Tooltip = "Prioritize Healing over Combat", Default = false, ConfigType = "Advanced", },
    ['ModRodManaPct']     = { DisplayName = "Mod Rod Mana %", Category = "Utilities", Tooltip = "What Mana % to hit before using a rod.", Default = 30, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['ClarityPotion']     = { DisplayName = "Clarity Potion", Category = "Utilities", Tooltip = "Name of your Clarity Pot", Default = "Distillate of Clarity", ConfigType = "Advanced", },
    ['RunMovePaused']     = { DisplayName = "Run Movement on Pause", Category = "Utilities", Tooltip = "Runs the Movement/Chase module even if the Main loop is paused", Default = false, ConfigType = "Advanced", },

    -- [ MEDITATION ] --
    ['DoMed']             = { DisplayName = "Do Meditate", Category = "Meditation", Tooltip = "0 = No Auto Med, 1 = Auto Med Out of Combat, 2 = Auto Med In Combat", Type = "Combo", ComboOptions = { 'Off', 'Out of Combat', 'In Combat', }, Default = 2, Min = 1, Max = 3, ConfigType = "Normal", },
    ['HPMedPct']          = { DisplayName = "Med HP %", Category = "Meditation", Tooltip = "What HP % to hit before medding.", Default = 60, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['ManaMedPct']        = { DisplayName = "Med Mana %", Category = "Meditation", Tooltip = "What Mana % to hit before medding.", Default = 30, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['EndMedPct']         = { DisplayName = "Med Endurance %", Category = "Meditation", Tooltip = "What Endurance % to hit before medding.", Default = 30, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['ManaMedPctStop']    = { DisplayName = "Med Mana % Stop", Category = "Meditation", Tooltip = "What Mana % to hit before stopping medding.", Default = 90, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['EndMedPctStop']     = { DisplayName = "Med Endurance % Stop", Category = "Meditation", Tooltip = "What Endurance % to hit before stopping medding.", Default = 90, Min = 1, Max = 99, ConfigType = "Advanced", },
    ['HPMedPctStop']      = { DisplayName = "Med HP % Stop", Category = "Meditation", Tooltip = "What HP % to hit before stopping medding.", Default = 90, Min = 1, Max = 99, ConfigType = "Advanced", },

    -- [ MERCENCARY ] --
    ['DoMercenary']       = { DisplayName = "Use Mercenary", Category = "Mercenary", Tooltip = "Use Merc during combat.", Default = true, ConfigType = "Normal", },

    -- [ PET ] --
    ['DoPet']             = { DisplayName = "Do Pet", Category = "Pet", Tooltip = "Enable using Pets.", Default = true, ConfigType = "Normal", },
    ['PetEngagePct']      = { DisplayName = "Pet Engage HPs", Category = "Pet", Tooltip = "Send in pet when target hits [x] HP %.", Default = 90, Min = 1, Max = 100, ConfigType = "Advanced", },

    -- [ COMBAT ] --
    ['SafeTargeting']     = { DisplayName = "Use Safe Targeting", Category = "Combat", Tooltip = "Do not target mobs that are fighting others.", Default = true, ConfigType = "Advanced", },
    ['AssistOutside']     = { DisplayName = "Assist Outside of Group", Category = "Combat", Tooltip = "Allow assisting characters outside of your group.", Default = false, ConfigType = "Advanced", },
    ['AssistRange']       = { DisplayName = "Assist Range", Category = "Combat", Tooltip = "Distance to the target before you engage.", Default = Config.Constants.RGCasters:contains(Config.Globals.CurLoadedClass) and 90 or 45, Min = 15, Max = 200, ConfigType = "Advanced", },
    ['MAScanZRange']      = { DisplayName = "Main Assist Scan ZRange", Category = "Combat", Tooltip = "Distance in Z direction to look for targets.", Default = 45, Min = 15, Max = 200, ConfigType = "Advanced", },
    ['AutoAssistAt']      = { DisplayName = "Auto Assist At", Category = "Combat", Tooltip = "Melee attack when target hits [x] HP %.", Default = 98, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['StickHow']          = { DisplayName = "Stick How", Category = "Combat", Tooltip = "Custom /stick command", Type = "Custom", Default = "", ConfigType = "Advanced", },
    ['AllowMezBreak']     = { DisplayName = "Allow Mez Break", Category = "Combat", Tooltip = "Allow Mez Breaking.", Default = false, ConfigType = "Advanced", },
    ['InstantRelease']    = { DisplayName = "Instant Release", Category = "Combat", Tooltip = "Instantly release when you die.", Default = false, ConfigType = "Advanced", },
    ['DoAutoTarget']      = { DisplayName = "Auto Target", Category = "Combat", Tooltip = "Automatically change targets.", Default = true, ConfigType = "Normal", },
    ['DoAlliance']        = { DisplayName = "Do Alliance", Category = "Combat", Tooltip = "Automatically cast Alliance spells.", Default = true, ConfigType = "Advanced", },
    ['DoModRod']          = { DisplayName = "Do Mod Rod", Category = "Combat", Tooltip = "Auto use Mod Rods if we have them", Default = true, ConfigType = "Advanced", },
    ['StayOnTarget']      = { DisplayName = "Stay On Target", Category = "Combat", Tooltip = "Stick to your target. Default: true; Tank Mode Defaults: false. false allows intelligent target swapping based on aggro/named/ etc.", Default = (not Config.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName())), ConfigType = "Advanced", },
    ['DoAutoEngage']      = { DisplayName = "Auto Engage", Category = "Combat", Tooltip = "Automatically engage targets.", Default = true, ConfigType = "Advanced", },
    ['DoMelee']           = { DisplayName = "Enable Melee Combat", Category = "Combat", Tooltip = "Melee targets.", Default = Config.Constants.RGMelee:contains(Config.Globals.CurLoadedClass), ConfigType = "Normal", },
    ['ManaToNuke']        = { DisplayName = "Mana to Nuke", Category = "Combat", Tooltip = "Minimum % Mana in order to continue to cast nukes.", Default = 30, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['MovebackWhenTank']  = { DisplayName = "Moveback as Tank", Category = "Combat", Tooltip = "Adds 'moveback' to stick command when tanking. Helpful to keep mobs from getting behind you.", Default = true, ConfigType = "Advanced", },

    -- [ Wards ] --
    ['WardsPlease']       = { DisplayName = "Enable Wards", Category = "Wards", Tooltip = "Enable Ward Type Spells", Default = true, ConfigType = "Normal", },

    -- [ BUFF ] --
    ['DoTwist']           = { DisplayName = "Enable Bard Twisting", Category = "Buffs", Tooltip = "Use MQ2Twist", Default = true, ConfigType = "Advanced", },
    ['DoBuffs']           = { DisplayName = "Do Buffs", Category = "Buffs", Tooltip = "Do Non-Class Specific Buffs.", Default = true, ConfigType = "Advanced", },

    -- [ HEALING ] --
    ['BreakInvis']        = { DisplayName = "Break Invis", Category = "Heals", Tooltip = "Set to break invis to heal injured group or out of group members when out of combat only. Healers will always break invis in combat.", Default = false, ConfigType = "Advanced", },
    ['MainHealPoint']     = { DisplayName = "Main Heal Point", Category = "Heals", Tooltip = "Set to 0-100 for health point for Main Heal", Default = 90, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['BigHealPoint']      = { DisplayName = "Big Heal Point", Category = "Heals", Tooltip = "Set to 0-100 for health point for Intervention", Default = 50, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['GroupHealPoint']    = { DisplayName = "Group Heal Point", Category = "Heals", Tooltip = "Set to 0-100 for health point for Group Heal", Default = 85, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['PetHealPoint']      = { DisplayName = "Pet Heal Point", Category = "Heals", Tooltip = "Set to 0-100 for health point for Pet Heal", Default = 85, Min = 1, Max = 100, ConfigType = "Advanced", },
    ['GroupInjureCnt']    = { DisplayName = "Group Heal Point", Category = "Heals", Tooltip = "Number of group members to be injured before using a group heal spell.", Default = 3, Min = 1, Max = 5, ConfigType = "Advanced", },
    ['DoPetHeals']        = { DisplayName = "Do Pet Heals", Category = "Heals", Tooltip = "Heal Pets?", Default = false, ConfigType = "Advanced", },
    ['MaxHealPoint']      = { DisplayName = "Max Heal Point", Category = "Heals", Tooltip = "The point at which you stop healing.", Default = 90, Min = 1, Max = 99, ConfigType = "Advanced", },

    -- [ REZ ] --
    ['RetryRezDelay']     = { DisplayName = "Retry Rez Delay", Category = "Rez", Tooltip = "Time in seconds of how often to try to rez a corpse.", Default = 6, Min = 1, Max = 60, ConfigType = "Advanced", },
    ['DoBattleRez']       = { DisplayName = "Do Battle Rez", Category = "Rez", Tooltip = "Use Rez while in combat", Default = true, ConfigType = "Advanced", },

    -- [ FELLOWSHIP ] --
    ['DoFellow']          = { DisplayName = "Enable Fellowship Insignia", Category = "Fellowship", Tooltip = "Use fellowship insignia automatically.", Default = true, ConfigType = "Advanced", },

    -- [ TARGETING ] --
    ['FollowMarkTarget']  = { DisplayName = "Follow Mark Target", Category = "Targeting", Tooltip = "Auto target MA target Marks.", Default = false, ConfigType = "Advanced", },

    -- [ DEBUG ] --
    ['LogLevel']          = { DisplayName = "Log Level", Category = "Debug", Tooltip = "1 = Errors, 2 = Warnings, 3 = Info, 4 = Debug, 5 = Verbose", Type = "Custom", Default = 3, Min = 1, Max = 5, ConfigType = "Advanced", },

    -- [ ASSIST ] --
    ['OutsideAssistList'] = { DisplayName = "List of Outsiders to Assist", Category = "Assist", Tooltip = "List of Outsiders to Assist", Type = "Custom", Default = {}, ConfigType = "Advanced", },

    -- [ BURNS ] --
    ['BurnSize']          = { DisplayName = "Do Burn Size", Category = "Burns", Tooltip = "0=Off, 1=Small, 2=Medium, 3=Large", Default = 1, Min = 0, Max = 3, ConfigType = "Advanced", },
    ['BurnAuto']          = { DisplayName = "Auto Burn", Category = "Burns", Tooltip = "Automatically burn", Default = false, ConfigType = "Normal", },
    ['BurnAlways']        = { DisplayName = "Auto Burn Always", Category = "Burns", Tooltip = "Always Burn", Default = false, ConfigType = "Advanced", },
    ['BurnMobCount']      = { DisplayName = "Auto Burn Mob Count", Category = "Burns", Tooltip = "Number of haters before we start burning.", Default = 3, Min = 1, Max = 10, ConfigType = "Advanced", },
    ['BurnNamed']         = { DisplayName = "Auto Burn Named", Category = "Burns", Tooltip = "Automatically burn named mobs.", Default = false, ConfigType = "Advanced", },

    -- [ UI ] --
    ['BgOpacity']         = { DisplayName = "Background Opacity", Category = "UI", Tooltip = "Opacity for the RGMercs UI", Type = "Custom", Default = "1.0", ConfigType = "Advanced", },
}

Config.DefaultCategories = Set.new({})
for _, v in pairs(Config.DefaultConfig) do
    if v.Type ~= "Custom" then
        Config.DefaultCategories:add(v.Category)
    end
end

function Config:GetConfigFileName()
    return mq.configDir ..
        '/rgmercs/PCConfigs/RGMerc_' .. self.Globals.CurServer .. "_" .. self.Globals.CurLoadedChar .. '.lua'
end

function Config:SaveSettings(doBroadcast)
    mq.pickle(self:GetConfigFileName(), self.settings)

    RGMercsLogger.set_log_level(RGMercUtils.GetSetting('LogLevel'))

    if doBroadcast == true then
        RGMercUtils.BroadcastUpdate("main", "LoadSettings")
    end
end

function Config:LoadSettings()
    self.Globals.CurLoadedChar  = mq.TLO.Me.DisplayName()
    self.Globals.CurLoadedClass = mq.TLO.Me.Class.ShortName()
    self.Globals.CurServer      = mq.TLO.EverQuest.Server():gsub(" ", "")

    RGMercsLogger.log_info("\ayLoading Main Settings for %s!", self.Globals.CurLoadedChar)

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

    self.settings = RGMercUtils.ResolveDefaults(Config.DefaultConfig, self.settings)

    if needSave then
        self:SaveSettings(false)
    end

    return true
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
