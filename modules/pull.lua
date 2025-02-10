-- Sample Pull Class Module
local mq                                  = require('mq')
local Config                              = require('utils.config')
local Math                                = require('utils.math')
local Combat                              = require("utils.combat")
local Casting                             = require("utils.casting")
local Core                                = require("utils.core")
local Targeting                           = require("utils.targeting")
local Ui                                  = require("utils.ui")
local Comms                               = require("utils.comms")
local Modules                             = require("utils.modules")
local Strings                             = require("utils.strings")
local Files                               = require("utils.files")
local Logger                              = require("utils.logger")
local Set                                 = require("mq.Set")
local Icons                               = require('mq.ICONS')

local Module                              = { _version = '0.1a', _name = "Pull", _author = 'Derple', }
Module.__index                            = Module
Module.settings                           = {}
Module.ModuleLoaded                       = false
Module.TempSettings                       = {}
Module.TempSettings.BuffCount             = 0
Module.TempSettings.LastPullOrCombatEnded = os.clock()
Module.TempSettings.TargetSpawnID         = 0
Module.TempSettings.CurrentWP             = 1
Module.TempSettings.PullTargets           = {}
Module.TempSettings.PullTargetsMetaData   = {}
Module.TempSettings.AbortPull             = false
Module.TempSettings.PullID                = 0
Module.TempSettings.LastPullAbilityCheck  = 0
Module.TempSettings.LastPullerMercCheck   = 0
Module.TempSettings.LastFoundGroupCorpse  = 0
Module.TempSettings.HuntX                 = 0
Module.TempSettings.HuntY                 = 0
Module.TempSettings.HuntZ                 = 0
Module.TempSettings.MyPaths               = {}
Module.TempSettings.SelectedPath          = "None"
Module.FAQ                                = {}
Module.ClassFAQ                           = {}

local PullStates                          = {
    ['PULL_IDLE']               = 1,
    ['PULL_GROUPWATCH_WAIT']    = 2,
    ['PULL_NAV_INTERRUPT']      = 3,
    ['PULL_SCAN']               = 4,
    ['PULL_PULLING']            = 5,
    ['PULL_MOVING_TO_WP']       = 6,
    ['PULL_NAV_TO_TARGET']      = 7,
    ['PULL_RETURN_TO_CAMP']     = 8,
    ['PULL_WAITING_ON_MOB']     = 9,
    ['PULL_WAITING_SHOULDPULL'] = 10,
}

local PullStateDisplayStrings             = {
    ['PULL_IDLE']               = { Display = Icons.FA_CLOCK_O, Text = "Idle", Color = { r = 0.02, g = 0.8, b = 0.2, a = 1.0, }, },
    ['PULL_GROUPWATCH_WAIT']    = { Display = Icons.MD_GROUP, Text = "Waiting on GroupWatch", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_NAV_INTERRUPT']      = { Display = Icons.MD_PAUSE_CIRCLE_OUTLINE, Text = "Navigation Interrupted", Color = { r = 0.8, g = 0.02, b = 0.02, a = 1.0, }, },
    ['PULL_SCAN']               = { Display = Icons.FA_EYE, Text = "Scanning for Targets", Color = { r = 0.02, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_PULLING']            = { Display = Icons.FA_BULLSEYE, Text = "Pulling", Color = { r = 0.8, g = 0.03, b = 0.02, a = 1.0, }, },
    ['PULL_MOVING_TO_WP']       = { Display = Icons.MD_DIRECTIONS_RUN, Text = "Moving to Next WP", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_NAV_TO_TARGET']      = { Display = Icons.MD_DIRECTIONS_RUN, Text = "Naving to Target", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_RETURN_TO_CAMP']     = { Display = Icons.FA_FREE_CODE_CAMP, Text = "Returning to Camp", Color = { r = 0.08, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_WAITING_ON_MOB']     = { Display = Icons.FA_CLOCK_O, Text = "Waiting on Mob", Color = { r = 0.8, g = 0.8, b = 0.02, a = 1.0, }, },
    ['PULL_WAITING_SHOULDPULL'] = { Display = Icons.FA_CLOCK_O, Text = "Waiting for Should Pull", Color = { r = 0.8, g = 0.04, b = 0.02, a = 1.0, }, },
}

local PullStatesIDToName                  = {}
for k, v in pairs(PullStates) do PullStatesIDToName[v] = k end

Module.TempSettings.PullState          = PullStates.PULL_IDLE
Module.TempSettings.PullStateReason    = ""

Module.Constants                       = {}
Module.Constants.PullModes             = {
    "Normal",
    "Chain",
    "Hunt",
    "Farm",
}

Module.Constants.PullAbilities         = {
    {
        id = "PetPull",
        Type = "Special",
        AbilityRange = 100,
        DisplayName = "Pet Pull",
        LOS = false,
        cond = function(self)
            return Config.Constants.RGPetClass:contains(Config.Globals.CurLoadedClass)
        end,
    },
    {
        id = "Taunt",
        Type = "Ability",
        DisplayName = "Taunt",
        AbilityName = "Taunt",
        AbilityRange = 10,
        cond = function(self)
            return mq.TLO.Me.Skill("Taunt")() > 0
        end,
    },
    {
        id = "AutoAttack",
        Type = "Special",
        DisplayName = "Auto Attack",
        AbilityRange = function()
            if Targeting.GetTargetID() == 0 then return 2 end

            return Targeting.GetTargetMaxRangeTo() * .9
        end,
        cond = function(self)
            return true
        end,
    },
    {
        id = "Ranged",
        Type = "Special",
        DisplayName = "Ranged",
        AbilityRange = function() return mq.TLO.Me.Inventory("ranged").Range() end,
        cond = function(self)
            local rangedType = (mq.TLO.Me.Inventory("ranged").Type() or ""):lower()
            local rangedTypes = Set.new({ "archery", "bow", "throwingv1", "throwing", "throwingv2", "ammo", })
            return rangedTypes:contains(rangedType)
        end,
    },
    {
        id = "Kick",
        Type = "Ability",
        DisplayName = "Kick",
        AbilityName = "Kick",
        AbilityRange = 10,
        cond = function(self)
            return mq.TLO.Me.Skill("Kick")() > 0
        end,
    },
    {
        id = "Face",
        Type = "Special",
        AbilityRange = 5,
        DisplayName = "Face Pull",
        cond = function(self)
            return true
        end,
    },
    {
        id = "Staff of Viral Flux",
        Type = "Item",
        AbilityRange = 200,
        DisplayName = "Staff of Viral Flux",
        ItemName = "Staff of Viral Flux",
        cond = function(self)
            return mq.TLO.FindItemCount("Staff of Viral Flux")() > 0
        end,
    },
}

local PullAbilityIDToName              = {}

Module.TempSettings.ValidPullAbilities = {}

Module.DefaultConfig                   = {
    ['DoPull']                                 = {
        DisplayName = "Enable Pulling",
        Category = "Pulling",
        Tooltip = "Enable pulling",
        Default = false,
        FAQ = "My Puller isn't Pulling, what do I do?",
        Answer = "Make sure you have [DoPull] enabled.",
    },
    ['PullDebuffed']                           = {
        DisplayName = "Pull While Debuffed",
        Category = "Pulling",
        Tooltip = "Pull in spite of being debuffed (Not ignored: Rez Sickness, Root.)",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "I keep stopping pulls while diseased or debuffed, how do I fix this?",
        Answer = "Enable [PullDebuffed] and you will pull even if you are debuffed.",
    },
    ['StopPullAfterDeath']                     = {
        DisplayName = "Stop Pulling After Death",
        Category = "Pulling",
        Tooltip = "Stop pulling after you die and are rezed back.",
        Default = true,
        FAQ = "I keep trying to pull after I die, how do I stop this?",
        Answer = "Enable [StopPullAfterDeath] and you will stop pulling after you die.",
    },
    ['PullBackwards']                          = {
        DisplayName = "Pull Facing Backwards",
        Category = "Pulling",
        Tooltip = "Run back to camp facing the mmob",
        Default = true,
        FAQ = "I don't like getting backstabbed when I pull, how do I fix this?",
        Answer = "Enable [PullBackwards] and you will run back to camp facing the mob.",
    },
    ['AutoSetRoles']                           = {
        DisplayName = "Auto Set Roles",
        Category = "Pulling",
        Tooltip = "Make yourself MA and Puller when you start pulls.",
        Default = true,
        FAQ = "I keep forgetting to set myself as MA and Puller, how do I fix this?",
        Answer = "Enable [AutoSetRoles] and you will be set as MA and Puller when you start pulls.",
    },
    ['PullAbility']                            = {
        DisplayName = "Pull Ability",
        Category = "Pulling",
        Tooltip = "What should we pull with?",
        Default = 1,
        Type = "Custom",
        FAQ = "I want to use a different ability to pull, how do I change it?",
        Answer = "Select a different ability from the [PullAbility] dropdown.",
    },
    ['PullMode']                               = {
        DisplayName = "Pull Mode",
        Category = "Pulling",
        Tooltip = "1 = Normal, 2 = Chain, 3 = Hunt, 4 = Farm",
        Type = "Custom",
        Default = 1,
        Min = 1,
        Max = 4,
        FAQ = "What are the different Pull Modes and how do I use them?",
        Answer = "Select a different mode from the [PullMode] dropdown.\n" ..
            "Normal = Pull to Camp Location and attempt to pull 1 mob at a time.\n" ..
            "Chain = Pull to Camp Location and attempt to pull multiple mobs at a time. You can set the Number in [ChainCount]\n" ..
            "Hunt = Roam the Hunt Pull Radius moving to each mob to fight.\n" ..
            "Farm = Follow the Farm Path waypoints and kill at each stop.\n",
    },
    ['ChainCount']                             = {
        DisplayName = "Chain Count",
        Category = "Pulling",
        Tooltip = "Number of mobs in chain pull mode on xtarg before we stop pulling",
        Default = 3,
        Min = 1,
        Max = 100,
        FAQ = "Can I adjust the number of mobs I pull in Chain Mode?",
        Answer = "Yes, you can adjust the number of mobs in the chain with [ChainCount].",
    },
    ['PullDelay']                              = {
        DisplayName = "Pull Delay",
        Category = "Pulling",
        Tooltip = "Seconds between pulls",
        Default = 5,
        Min = 1,
        Max = 300,
        FAQ = "I want to adjust the time between pulls so I have time to Manually Loot, how do I do that?",
        Answer = "You can adjust the time between pulls with [PullDelay].",
    },
    ['MaxPathRange']                           = {
        DisplayName = "Max Path Range",
        Category = "Pull Distance",
        Tooltip = "Maximum distance to pull using navigation pathing distance",
        Default = 1000,
        Min = 1,
        Max = 10000,
        FAQ = "A mob is with in range but the path to get to them is very long, how can I adjust how far I will path to my target?",
        Answer = "You can adjust the path distance you pull from with [MaxPathRange].",
    },
    ['PullRadius']                             = {
        DisplayName = "Pull Radius",
        Category = "Pull Distance",
        Tooltip = "Distnace to pull",
        Default = 350,
        Min = 1,
        Max = 10000,
        FAQ = "I want to adjust the distance I pull from, how do I do that?",
        Answer = "You can adjust the distance you pull from with [PullRadius].",
    },
    ['PullZRadius']                            = {
        DisplayName = "Pull Z Radius",
        Category = "Pull Distance",
        Tooltip = "Distnace to pull on Z axis",
        Default = 90,
        Min = 1,
        Max = 350,
        FAQ = "I can't seem to pull mobs on this ledge/hill/pit?",
        Answer = "You can adjust the distance you pull on the Z axis with [PullZRadius].",
    },
    ['PullRadiusFarm']                         = {
        DisplayName = "Pull Radius Farm",
        Category = "Pull Distance",
        Tooltip = "Distnace to pull in Farm mode",
        Default = 90,
        Min = 1,
        Max = 10000,
        FAQ = "I want to adjust the distance I pull from at the waypoint stops in Farm Mode, how do I do that?",
        Answer = "You can adjust how far you pull from at the stops using the [PullRadiusFarm] setting.",
    },
    ['HuntFromPlayer']                         = {
        DisplayName = "Hunt from Player",
        Category = "Pull Distance",
        Tooltip =
        "Off means that we always scan from the hunt starting position, On means that we scan from your current player location",
        Default = false,
        FAQ = "How do I just Hunt then entire zone?",
        Answer = "Enable [HuntFromPlayer] and you will scan from your current location after every pull, instead of the Hunt Starting Position.",
    },
    ['PullRadiusHunt']                         = {
        DisplayName = "Pull Radius Hunt",
        Category = "Pull Distance",
        Tooltip = "Distnace to pull in Hunt mode from your starting position",
        Default = 500,
        Min = 1,
        Max = 10000,
        FAQ = "I run out of spawns to pull in Hunt Mode, how do I fix this?",
        Answer = "You can adjust the distance you pull from in Hunt Mode with [PullRadiusHunt].",
    },
    ['PullMinCon']                             = {
        DisplayName = "Pull Min Con",
        Category = "Pull Targets",
        Index = 1,
        Tooltip = "Min Con Mobs to consider pulling",
        Default = 2,
        Min = 1,
        Max = #Config.Constants.ConColors,
        Type =
        "Combo",
        ComboOptions = Config.Constants.ConColors,
        FAQ = "Why am I pulling Grey con mobs?",
        Answer = "You probably have your [PullMinCon] set too low, adjust it to the lowest con you want to pull.",

    },
    ['PullMaxCon']                             = {
        DisplayName = "Pull Max Con",
        Category = "Pull Targets",
        Index = 2,
        Tooltip = "Max Con Mobs to consider pulling",
        Default = 5,
        Min = 1,
        Max = #Config.Constants.ConColors,
        Type = "Combo",
        ComboOptions = Config.Constants.ConColors,
        FAQ = "Why am I not pulling Red con mobs?",
        Answer = "You probably have your [PullMaxCon] set too low, adjust it to the highest con you want to pull.",
    },
    ['MaxLevelDiff']                           = {
        DisplayName = "Max Level Diff",
        Category = "Pull Targets",
        Index = 3,
        Tooltip = "If set to pull Red con mobs, limit the level gap to this value.",
        Default = 6,
        Min = 4,
        Max = 20,
        FAQ = "Why am I pulling deep Red con mobs?",
        Answer = "You can set your Max Level Diff to control whether deep red mobs will be pulled.",
    },
    ['UsePullLevels']                          = {
        DisplayName = "Use Pull Levels",
        Category = "Pull Targets",
        Index = 4,
        Tooltip = "Use Min and Max Levels Instead of Con.",
        Default = false,
        ConfigType = "Advanced",
        FAQ = "Con colors have to wide of a range, can I use levels instead?",
        Answer = "Enable [UsePullLevels] and you will use Min and Max Levels instead of Con Colors.",
    },
    ['PullMinLevel']                           = {
        DisplayName = "Pull Min Level",
        Category = "Pull Targets",
        Index = 5,
        Tooltip = "Min Level Mobs to consider pulling",
        Default = mq.TLO.Me.Level() - 3,
        Min = 1,
        Max = 150,
        ConfigType = "Advanced",
        FAQ = "I keep pulling low level mobs, how do I fix this?",
        Answer = "You probably have your [PullMinLevel] set too low, adjust it to the lowest level you want to pull.",
    },
    ['PullMaxLevel']                           = {
        DisplayName = "Pull Max Level",
        Category = "Pull Targets",
        Index = 6,
        Tooltip = "Max Level Mobs to consider pulling",
        Default = mq.TLO.Me.Level() + 3,
        Min = 1,
        Max = 150,
        ConfigType = "Advanced",
        FAQ = "I keep pulling high level mobs, how do I fix this?",
        Answer = "You probably have your [PullMaxLevel] set too high, adjust it to the highest level you want to pull.",
    },
    ['GroupWatch']                             = {
        DisplayName = "Enable Group Watch",
        Category = "Group Watch",
        Index = 1,
        Tooltip = "1 = Off, 2 = Healers, 3 = Everyone",
        Type = "Combo",
        ComboOptions = { 'Off', 'Healers', 'Everyone', },
        Default = 2,
        Min = 1,
        Max = 3,
        FAQ = "I want to make sure my group is ready before I pull, how do I do that?",
        Answer = "Select a different mode from the [GroupWatch] dropdown.\n" ..
            "Off = Don't check group members.\n" ..
            "Healers = Check Healers for Mana, HP, or Endurance.\n" ..
            "Everyone = Check Everyone for Mana, HP, or Endurance.",
    },
    ['GroupWatchEnd']                          = {
        DisplayName = "Watch Group Endurance",
        Category = "Group Watch",
        Index = 4,
        Tooltip = "Check for Endurance on Group Members",
        Default = false,
        FAQ = "I want to make sure my group has enough Endurance before I pull, how do I do that?",
        Answer = "Enable [GroupWatchEnd] and you will check for Endurance on Group Members.",
    },
    ['GroupWatchStartPct']                     = {
        DisplayName = "Group Watch Start %",
        Category = "Group Watch",
        Index = 2,
        Tooltip = "If your group member is above [X]% resource, start pulls again.",
        Default = 80,
        Min = 1,
        Max = 100,
        FAQ = "My Cleric never meds to full, how do I fix this?",
        Answer = "You can adjust the start % for pulls with [GroupWatchStartPct] and you will not pull until they are above that setting.",
    },
    ['GroupWatchStopPct']                      = {
        DisplayName = "Group Watch Stop %",
        Category = "Group Watch",
        Index = 3,
        Tooltip = "If your group member is below [X]% resource, stop pulls.",
        Default = 40,
        Min = 1,
        Max = 100,
        FAQ = "Why are my group members always OOM?",
        Answer = "Make sure [GroupWatch] is enabled. \n" ..
            "You can adjust the stop % for pulls with [GroupWatchStopPct] and you will stop pulling until they are above that setting.",
    },
    ['PullHPPct']                              = {
        DisplayName = "Pull HP %",
        Category = "Group Watch",
        Index = 5,
        Tooltip = "Make sure you have at least this much HP %",
        Default = 60,
        Min = 1,
        Max = 100,
        FAQ = "I keep trying to pull when I have half health. I don't want to die, how do I fix this?",
        Answer = "You can adjust the HP % for pulls with [PullHPPct] and you will not pull until you are above that setting.",
    },
    ['PullManaPct']                            = {
        DisplayName = "Pull Mana %",
        Category = "Group Watch",
        Index = 7,
        Tooltip = "Make sure you have at least this much Mana %",
        Default = 60,
        Min = 0,
        Max = 100,
        FAQ = "I keep trying to pull when I have half mana. I don't want to run out, how do I fix this?",
        Answer = "You can adjust the Mana % for pulls with [PullManaPct] and you will not pull until you are above that setting.",
    },
    ['PullEndPct']                             = {
        DisplayName = "Pull End %",
        Category = "Group Watch",
        Index = 6,
        Tooltip = "Make sure you have at least this much Endurance %",
        Default = 30,
        Min = 0,
        Max = 100,
        FAQ = "I keep trying to pull when I have half endurance. I don't want to run out, how do I fix this?",
        Answer = "You can adjust the Endurance % for pulls with [PullEndPct] and you will not pull until you are above that setting.",
    },
    ['PullRespectMedState']                    = {
        DisplayName = "Respect Med State",
        Category = "Group Watch",
        Index = 8,
        Tooltip = "Hold pulls if you are currently meditating.",
        Default = false,
        FAQ = "My puller only meds long enough to meet the pull minimums, what can be done?",
        Answer = "If you turn on Respect Med State in the Group Watch options, your puller will remain medding until those thresholds are reached.",
    },
    ['PullWaitCorpse']                         = {
        DisplayName = "Hold for Corpses",
        Category = "Group Watch",
        Index = 9,
        Tooltip = "Hold pulls while we detect a groupmember's corpse in the vicinity.",
        Default = true,
        FAQ = "Why do I stop pulling every time someone dies?",
        Answer = "By default, the puller will hold pulls when the corpse of a groupmember is nearby. You can turn this off in the Group Watch options.",
    },
    ['WaitAfterRez']                           = {
        DisplayName = "Wait After Rez",
        Category = "Group Watch",
        Index = 10,
        Tooltip = "If the puller detected a group corpse and held pulls, allow x seconds for the group to rebuff after the corpse is rezzed.\n" ..
            "**Only respected when \"Hold for Corpses\" is enabled and a corpse was detected by that process!**",
        Default = 0,
        Min = 0,
        Max = 90,
        FAQ = "How can I pause pulls to allow more time to rebuff after death?",
        Answer = "You can adjust the Wait After Rez setting in the Group Watch tab to allow time for your group to rebuff after a death.",
    },
    ['FarmWayPoints']                          = {
        DisplayName = "Farming Waypoints",
        Category = "",
        Tooltip = "",
        Type = "Custom",
        Default = {},
        FAQ = "How can I set a path for my characters to follow while farming?",
        Answer = "You can set a path for your characters to follow while farming by adding waypoints to the [FarmWayPoints] list.",
    },
    ['PullAllowList']                          = {
        DisplayName = "Allow List",
        Category = "",
        Tooltip = "",
        Type = "Custom",
        Default = {},
        FAQ = "Can I manually add a mob to the pull list?",
        Answer = "You can add a mob to the [PullAllowList] and it will be pulled.",
    },
    ['PullDenyList']                           = {
        DisplayName = "Deny List",
        Category = "",
        Tooltip = "",
        Type = "Custom",
        Default = {},
        FAQ = "Can I manually add a mob to the pull deny list?",
        Answer = "You can add a mob to the [PullDenyList] and it will not be pulled.",
    },
    ['PullMobsInWater']                        = {
        DisplayName = "Pull Mobs In Water",
        Category = "Pulling",
        Tooltip = "Pull Mobs that are in water bodies? If you are low level you might drown.",
        Default = false,
        FAQ = "I keep pulling mobs in the water and drowning, how do I fix this?",
        Answer = "Disable [PullMobsInWater] and you will NOT pull mobs in the water.",
    },
    ['PullSafeZones']                          = {
        DisplayName = "SafeZones",
        Category = "",
        Tooltip = "",
        Type = "Custom",
        Default = { "poknowledge", "neighborhood", "guildhall", "guildlobby", "bazaar", },
        FAQ = "How do I make it so my puller doesn't pull in certain zones?",
        Answer = "You can add a zone to the [PullSafeZones] and it will not pull in that zone.\n" ..
            "This list is found in /config/rgmercs/PCConfigs/Pull_<Server>_<Character>.lua",
    },
    ['PullBuffCount']                          = {
        DisplayName = "Min Buff Count",
        Category = "Pulling",
        Tooltip = "The minimum number of buffs in our buff window we should have before pulling (0 disables).",
        Default = 0,
        Min = 0,
        Max = 40,
        FAQ = "How do I make it so my puller doesn't pull with no buffs?",
        Answer = "Set the min number of buffs before pulling with Min Buff Count and the pulling will pause to wait for that number of buffs.",
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Category = "Custom",
        Tooltip = Module._name .. " Pop Out Into Window",
        Default = false,
        FAQ = "Can I pop out the " .. Module._name .. " module into its own window?",
        Answer =
        "You can set the click the popout button at the top of a tab or heading to pop it into its own window.\n Simply close the window and it will snap back to the main window.",
    },
}

Module.DefaultCategories               = Set.new({})
for k, v in pairs(Module.DefaultConfig or {}) do
    if v.Type ~= "Custom" then
        Module.DefaultCategories:add(v.Category)
    end
    Module.FAQ[k] = { Question = v.FAQ or 'None', Answer = v.Answer or 'None', Settings_Used = k, }
end

Module.CommandHandlers = {
    pulltarget = {
        usage = "/rgl pulltarget",
        about = "Pulls your current target using your rgmercs pull ability",
        handler = function(self, ...)
            self:SetPullTarget()
            return true
        end,
    },
    pulldeny = {
        usage = "/rgl pulldeny \"<name>\"",
        about = "Adds <name> to the Pull Deny List.",
        handler = function(self, name)
            self:AddMobToList("PullDenyList", name)
            return true
        end,
    },
    pullallow = {
        usage = "/rgl pullallow \"<name>\"",
        about = "Adds <name> to the Pull Allow List.",
        handler = function(self, name)
            self:AddMobToList("PullAllowList", name)
            return true
        end,
    },
    -- These are broken. Would need to adjust the delete function to look up the ID with name
    -- pulldenyrm = {
    --     usage = "/rgl pulldenyrm \"<name>\"",
    --     about = "Removes <name> from the pull deny list",
    --     handler = function(self, name)
    --         self:AddMobToList("PullDenyList", name)
    --         return true
    --     end,
    -- },
    -- pullallowrm = {
    --     usage = "/rgl pullallowrm \"<name>\"",
    --     about = "Removes <name> from the pull allow list",
    --     handler = function(self, name)
    --         self:AddMobToList("PullAllowList", name)
    --         return true
    --     end,
    -- },
}

local function getConfigFileName()
    local oldFile = mq.configDir ..
        '/rgmercs/PCConfigs/' ..
        Module._name .. "_" .. Config.Globals.CurServer .. "_" .. Config.Globals.CurLoadedChar .. '.lua'
    local newFile = mq.configDir ..
        '/rgmercs/PCConfigs/' ..
        Module._name .. "_" .. Config.Globals.CurServer .. "_" .. Config.Globals.CurLoadedChar .. "_" .. Config.Globals.CurLoadedClass:lower() .. '.lua'

    if Files.file_exists(newFile) then
        return newFile
    end

    Files.copy_file(oldFile, newFile)

    return newFile
end

function Module:SaveSettings(doBroadcast)
    mq.pickle(getConfigFileName(), self.settings)

    if doBroadcast == true then
        Comms.BroadcastUpdate(self._name, "LoadSettings")
    end
end

function Module:LoadSettings()
    Logger.log_debug("Pull Combat Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Pull]: Unable to load global settings file(%s), creating a new one!",
            settings_pickle_path)
        self:SaveSettings(false)
    else
        self.settings = config()
    end
    local pathsFile = string.format('%s/MyUI/MyPaths/MyPaths_Paths.lua', mq.configDir)
    local pathsConfig, err = loadfile(pathsFile)
    if not err and pathsConfig then
        Module.TempSettings.MyPaths = pathsConfig()
    end
    -- turn off at startup for safety
    self.settings.DoPull = false

    local settingsChanged = false

    -- Setup Defaults
    self.settings, settingsChanged = Config.ResolveDefaults(self.DefaultConfig, self.settings)

    if settingsChanged then
        self:SaveSettings(false)
    end
end

function Module:GetSettings()
    return self.settings
end

function Module:GetDefaultSettings()
    return self.DefaultConfig
end

function Module:GetSettingCategories()
    return self.DefaultCategories
end

---@param id number
---@return string
function Module:getPullAbilityDisplayName(id)
    local displayName = self.TempSettings.ValidPullAbilities[id].DisplayName

    if type(displayName) == 'function' then displayName = displayName() end

    return displayName or "Error"
end

function Module:SetValidPullAbilities()
    if os.clock() - self.TempSettings.LastPullAbilityCheck < 10 then return end

    self.TempSettings.LastPullAbilityCheck = os.clock()
    local tmpValidPullAbilities = {}
    local tmpPullAbilityIDToName = {}

    for _, v in ipairs(Module.Constants.PullAbilities) do
        if Core.SafeCallFunc("Checking Pull Ability Condition", v.cond, self) then
            table.insert(tmpValidPullAbilities, v)
        end
    end

    -- pull in class specific configs.
    for _, v in ipairs(Modules:ExecModule("Class", "GetPullAbilities")) do
        if Core.SafeCallFunc("Checking Pull Ability Condition", v.cond, self) then
            table.insert(tmpValidPullAbilities, v)
        end
    end

    for k, v in ipairs(tmpValidPullAbilities) do
        tmpPullAbilityIDToName[v.id] = k
    end

    self.TempSettings.ValidPullAbilities = tmpValidPullAbilities
    PullAbilityIDToName = tmpPullAbilityIDToName
end

function Module:OnCombatModeChanged()
    self:SetValidPullAbilities()
end

function Module.New()
    local newModule = setmetatable({ settings = {}, }, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Pull Module Loaded.")
    self:LoadSettings()
    self.ModuleLoaded = true
    return { self = self, settings = self.settings, defaults = self.DefaultConfig, categories = self.DefaultCategories, }
end

function Module:RenderMobList(displayName, settingName)
    if ImGui.CollapsingHeader(string.format("Pull %s", displayName)) then
        if mq.TLO.Target() and Targeting.TargetIsType("NPC") then
            ImGui.PushID("##_small_btn_allow_target_" .. settingName)
            if ImGui.SmallButton(string.format("Add Target To %s", displayName)) then
                self:AddMobToList(settingName, mq.TLO.Target.CleanName())
            end
            ImGui.PopID()
        end

        if ImGui.BeginTable("settingName", 4, bit32.bor(ImGuiTableFlags.Borders)) then
            ImGui.TableSetupColumn('Id', (ImGuiTableColumnFlags.WidthFixed), 40.0)
            ImGui.TableSetupColumn('Count', (ImGuiTableColumnFlags.WidthFixed), 40.0)
            ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.WidthStretch), 150.0)
            ImGui.TableSetupColumn('Controls', (ImGuiTableColumnFlags.WidthFixed), 80.0)
            ImGui.TableHeadersRow()

            for idx, mobName in pairs(self.settings[settingName][mq.TLO.Zone.ShortName()] or {}) do
                ImGui.TableNextColumn()
                ImGui.Text(tostring(idx))
                ImGui.TableNextColumn()
                ImGui.Text(tostring(mq.TLO.SpawnCount(string.format("NPC %s", mobName))))
                ImGui.TableNextColumn()
                ImGui.Text(mobName)
                ImGui.TableNextColumn()
                ImGui.PushID("##_small_btn_delete_mob_" .. settingName .. tostring(idx))
                if ImGui.SmallButton(Icons.FA_TRASH) then
                    self:DeleteMobFromList(settingName, idx)
                end
                ImGui.PopID()
            end

            ImGui.EndTable()
        end
    end
end

function Module:RenderPullTargets()
    if ImGui.BeginTable("Pull Targets", 5, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Index', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Name', (ImGuiTableColumnFlags.None), 250.0)
        ImGui.TableSetupColumn('Level', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.TableSetupColumn('Distance', (ImGuiTableColumnFlags.WidthFixed), 60.0)
        ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthFixed), 160.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, spawn in ipairs(self.TempSettings.PullTargets) do
            if spawn.ID() > 0 then
                ImGui.TableNextColumn()
                ImGui.Text("%d", idx)
                ImGui.TableNextColumn()
                ImGui.PushStyleColor(ImGuiCol.Text, Ui.GetConColorBySpawn(spawn))
                ImGui.PushID(string.format("##select_pull_npc_%d", idx))
                local _, clicked = ImGui.Selectable(spawn.CleanName() or "Unknown")
                if clicked then
                    Logger.log_debug("Targeting: %d", spawn.ID() or 0)
                    spawn.DoTarget()
                end
                ImGui.PopID()
                ImGui.TableNextColumn()
                ImGui.Text("%d", spawn.Level() or 0)
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                ImGui.Text("%0.2f", spawn.Distance() or 0)
                ImGui.TableNextColumn()
                Ui.NavEnabledLoc(spawn.LocYXZ() or "0,0,0")
            end
        end

        ImGui.EndTable()
    end
end

function Module:ShouldRender()
    return true
end

function Module:Render()
    if not self.settings[self._name .. "_Popped"] then
        if ImGui.SmallButton(Icons.MD_OPEN_IN_NEW) then
            self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
            self:SaveSettings(false)
        end
        Ui.Tooltip(string.format("Pop the %s tab out into its own window.", self._name))
        ImGui.NewLine()
    end

    local pressed

    -- dead... whoops
    if mq.TLO.Me.Hovering() then return end

    if self.ModuleLoaded and Config.Globals.SubmodulesLoaded then
        if mq.TLO.Navigation.MeshLoaded() then
            if Config:GetSetting('DoPull') then
                ImGui.PushStyleColor(ImGuiCol.Button, 0.5, 0.02, 0.02, 1)
            else
                ImGui.PushStyleColor(ImGuiCol.Button, 0.02, 0.5, 0.0, 1)
            end

            if ImGui.Button(Config:GetSetting('DoPull') and "Stop Pulls" or "Start Pulls", ImGui.GetWindowWidth() * .3, 25) then
                self.settings.DoPull = not self.settings.DoPull
                if Config:GetSetting('AutoSetRoles') and mq.TLO.Group.Leader() == mq.TLO.Me.DisplayName() then
                    -- in hunt mode we follow around.

                    if self.Constants.PullModes[self.settings.PullMode] ~= "Hunt" then
                        Core.DoCmd("/grouproles %s %s 3", Config:GetSetting('DoPull') and "set" or "unset", mq.TLO.Me.DisplayName()) -- set puller
                    end
                    Core.DoCmd("/grouproles set %s 2", Config.Globals.MainAssist)                                                    -- set MA
                end
                self:SaveSettings(false)
            end
            ImGui.PopStyleColor()
        else
            ImGui.PushStyleColor(ImGuiCol.Button, 0.5, 0.02, 0.02, 1)
            ImGui.Button("No Nav Mesh Loaded!", ImGui.GetWindowWidth() * .3, 25)
            ImGui.PopStyleColor()
        end

        if mq.TLO.Target() and Targeting.TargetIsType("NPC") then
            ImGui.SameLine()
            if ImGui.Button("Pull Target " .. Icons.FA_BULLSEYE, ImGui.GetWindowWidth() * .3, 25) then
                self:SetPullTarget()
            end
        end

        local campData = Modules:ExecModule("Movement", "GetCampData")

        ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImGui.GetStyle().FramePadding.x, 0)
        if campData.returnToCamp then
            if ImGui.Button("Break Group Camp", ImGui.GetWindowWidth() * .3, 18) then
                Core.DoGroupCmd("/rgl campoff")
            end
        else
            if ImGui.Button("Set Group Camp Here", ImGui.GetWindowWidth() * .3, 18) then
                Core.DoGroupCmd("/rgl campon")
            end
        end
        ImGui.SameLine()
        if campData.returnToCamp then
            if ImGui.Button("Break My Camp", ImGui.GetWindowWidth() * .3, 18) then
                Core.DoCmd("/rgl campoff")
            end
        else
            if ImGui.Button("Set My Camp Here", ImGui.GetWindowWidth() * .3, 18) then
                Core.DoCmd("/rgl campon")
            end
        end
        ImGui.PopStyleVar(1)

        self.settings.PullMode, pressed = ImGui.Combo("Pull Mode", self.settings.PullMode, self.Constants.PullModes, #self.Constants.PullModes)
        if pressed then
            self:SaveSettings(false)
        end
        if #self.TempSettings.ValidPullAbilities > 0 then
            self.settings.PullAbility, pressed = ImGui.Combo("Pull Ability", self.settings.PullAbility, function(id) return self:getPullAbilityDisplayName(id) end,
                #self.TempSettings.ValidPullAbilities) --, self.TempSettings.ValidPullAbilities, #self.TempSettings.ValidPullAbilities)
            if pressed then
                self:SaveSettings(false)
            end
        end

        local nextPull = self.settings.PullDelay - (os.clock() - self.TempSettings.LastPullOrCombatEnded)
        if nextPull < 0 then nextPull = 0 end
        if ImGui.BeginTable("PullState", 2, bit32.bor(ImGuiTableFlags.Borders)) then
            ImGui.TableNextColumn()
            ImGui.Text("Pull State")
            ImGui.TableNextColumn()
            local stateData = PullStateDisplayStrings[PullStatesIDToName[self.TempSettings.PullState]]
            local stateColor = stateData and ImGui.GetColorU32(stateData.Color.r or 1.0, stateData.Color.g or 1.0, stateData.Color.b or 1.0, stateData.Color.a or 1.0) or
                ImGui.GetColorU32(1.0, 1.0, 1.0, 1.0)
            ImGui.PushStyleColor(ImGuiCol.Text, stateColor)
            if not stateData then
                ImGui.Text("Invalid State Data... This should auto resolve.")
            else
                ImGui.Text(stateData.Display .. " " .. stateData.Text)
            end
            ImGui.PopStyleColor()
            ImGui.TableNextColumn()
            ImGui.Text("Pull State Reason")
            ImGui.TableNextColumn()
            ImGui.PushStyleColor(ImGuiCol.Text, stateColor)
            ImGui.Text(self.TempSettings.PullStateReason:len() > 0 and self.TempSettings.PullStateReason or "N/A")
            ImGui.PopStyleColor()
            ImGui.TableNextColumn()
            ImGui.Text("Pull Delay")
            ImGui.TableNextColumn()
            ImGui.Text(Strings.FormatTime(self.settings.PullDelay))
            ImGui.TableNextColumn()
            ImGui.Text("Last Pull Attempt")
            ImGui.TableNextColumn()
            ImGui.Text(Strings.FormatTime((os.clock() - self.TempSettings.LastPullOrCombatEnded)))
            ImGui.TableNextColumn()
            ImGui.Text("Next Pull Attempt")
            ImGui.TableNextColumn()
            ImGui.Text(Strings.FormatTime(nextPull))
            ImGui.TableNextColumn()
            ImGui.Text("Pull Ability Range")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(self:GetPullAbilityRange()))
            ImGui.TableNextColumn()
            ImGui.Text("Pull ID")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(self.TempSettings.PullID))
            ImGui.TableNextColumn()
            ImGui.Text("Pull Target Count")
            ImGui.TableNextColumn()
            ImGui.Text(tostring(#self.TempSettings.PullTargets))
            ImGui.TableNextColumn()
            ImGui.Text("Hunt X,Y,Z")
            ImGui.TableNextColumn()
            ImGui.Text("%d, %d, %d", self.TempSettings.HuntX, self.TempSettings.HuntY, self.TempSettings.HuntZ)
            ImGui.TableNextColumn()
            ImGui.Text("Current WP")
            ImGui.TableNextColumn()
            local wpId = self:GetCurrentWpId()
            local wpData = self:GetWPById(wpId)
            ImGui.Text(wpId == 0 and "<None>" or string.format("%d [y: %0.2f, x: %0.2f, z: %0.2f]", wpId, wpData.y, wpData.x, wpData.z))
            ImGui.TableNextColumn()
            ImGui.Text("Buff Count")
            ImGui.TableNextColumn()
            ImGui.Text("%s", self.TempSettings.BuffCount)
            ImGui.EndTable()
        end

        ImGui.NewLine()
        ImGui.Separator()
        ImGui.Text("Note: Allow List will supersede Deny List")
        self:RenderMobList("Allow List", "PullAllowList")
        self:RenderMobList("Deny List", "PullDenyList")
        ImGui.NewLine()
        ImGui.Separator()

        if Config:GetSetting('DoPull') then
            if ImGui.CollapsingHeader("Pull Targets") then
                self:RenderPullTargets()
            end
        end

        if ImGui.CollapsingHeader("Farm Waypoints") then
            ImGui.PushID("##_small_btn_create_wp")
            if ImGui.SmallButton("Create Waypoint Here") then
                self:CreateWayPointHere()
            end
            ImGui.PopID()
            if self.TempSettings.MyPaths[mq.TLO.Zone.ShortName()] then
                ImGui.SameLine()
                if ImGui.SmallButton('Reload Paths##ReloadPaths') then
                    self.TempSettings.MyPaths = dofile(string.format('%s/MyUI/MyPaths/MyPaths_Paths.lua', mq.configDir))
                end
                ImGui.SetNextItemWidth(120)
                if ImGui.BeginCombo("MyPaths Path Avail##SelectPath", self.TempSettings.SelectedPath) then
                    for name, data in pairs(self.TempSettings.MyPaths[mq.TLO.Zone.ShortName()]) do
                        local isSelected = name == self.TempSettings.SelectedPath
                        if ImGui.Selectable(name, isSelected) then
                            self.TempSettings.SelectedPath = name
                        end
                    end
                    ImGui.EndCombo()
                end
                if self.TempSettings.SelectedPath ~= "None" then
                    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] = {}
                    for step, data in pairs(self.TempSettings.MyPaths[mq.TLO.Zone.ShortName()][self.TempSettings.SelectedPath]) do
                        local mpy, mpx, mpz = data.loc:match("([^,]+),%s*([^,]+),%s*([^,]+)")
                        self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][step] = { x = tonumber(mpx), y = tonumber(mpy), z = tonumber(mpz), }
                    end
                    self.TempSettings.SelectedPath = "None"
                end
            else
                Module.TempSettings.MyPaths = 'None'
            end

            if ImGui.BeginTable("Waypoints", 3, bit32.bor(ImGuiTableFlags.Borders)) then
                ImGui.TableSetupColumn('Id', (ImGuiTableColumnFlags.WidthFixed), 40.0)
                ImGui.TableSetupColumn('Loc', (ImGuiTableColumnFlags.WidthStretch), 150.0)
                ImGui.TableSetupColumn('Controls', (ImGuiTableColumnFlags.WidthFixed), 80.0)
                ImGui.TableHeadersRow()

                local waypointList = self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] or {}

                for idx, wpData in ipairs(waypointList) do
                    ImGui.TableNextColumn()
                    ImGui.Text(tostring(idx))
                    ImGui.TableNextColumn()
                    ImGui.Text("[y: %0.2f, x: %0.2f, z: %0.2f]", wpData.y, wpData.x, wpData.z)
                    ImGui.TableNextColumn()
                    ImGui.PushID("##_small_btn_delete_wp_" .. tostring(idx))
                    if ImGui.SmallButton(Icons.FA_TRASH) then
                        self:DeleteWayPoint(idx)
                    end
                    ImGui.PopID()
                    ImGui.SameLine()
                    ImGui.PushID("##_small_btn_up_wp_" .. tostring(idx))
                    if idx == 1 then
                        ImGui.InvisibleButton(Icons.FA_CHEVRON_UP, ImVec2(22, 1))
                    else
                        if ImGui.SmallButton(Icons.FA_CHEVRON_UP) then
                            self:MoveWayPointUp(idx)
                        end
                    end
                    ImGui.PopID()
                    ImGui.SameLine()
                    ImGui.PushID("##_small_btn_dn_wp_" .. tostring(idx))
                    if idx == #waypointList then
                        ImGui.InvisibleButton(Icons.FA_CHEVRON_DOWN, ImVec2(22, 1))
                    else
                        if ImGui.SmallButton(Icons.FA_CHEVRON_DOWN) then
                            self:MoveWayPointDown(idx)
                        end
                    end
                    ImGui.PopID()
                end

                ImGui.EndTable()
            end
        end
    end

    ImGui.Separator()

    if ImGui.CollapsingHeader("Config Options") then
        if self.ModuleLoaded then
            self.settings, pressed, _ = Ui.RenderSettings(self.settings, self.DefaultConfig, self.DefaultCategories)
            if pressed then
                self:SaveSettings(false)
            end
        end
    end
end

---@return integer
function Module:GetCurrentWpId()
    if not self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then return 0 end
    return (self.TempSettings.CurrentWP <= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()]) and self.TempSettings.CurrentWP or 0
end

---comment
---@param id number
---@return table
function Module:GetWPById(id)
    return (self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] and
            (id <= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()])) and
        self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id] or { x = 0, y = 0, z = 0, }
end

---@param listName string
---@return boolean
function Module:HaveList(listName)
    return self.settings[listName][mq.TLO.Zone.ShortName()] and #self.settings[listName][mq.TLO.Zone.ShortName()] > 0
end

---@param listName string
---@param mobName string
---@param defaultNoList boolean # Default to return if there is no list.
---@return boolean
function Module:IsMobInList(listName, mobName, defaultNoList)
    -- no list so everything is allowed.
    if not self:HaveList(listName) then return defaultNoList end

    for _, v in pairs(self.settings[listName][mq.TLO.Zone.ShortName()]) do
        if v == mobName then return true end
    end

    return false
end

---@param list string
---@param mobName string
function Module:AddMobToList(list, mobName)
    self.settings[list][mq.TLO.Zone.ShortName()] = self.settings[list][mq.TLO.Zone.ShortName()] or {}
    table.insert(self.settings[list][mq.TLO.Zone.ShortName()], mobName)
    self:SaveSettings(false)

    -- if we are pulling start over.
    if Config:GetSetting('DoPull') then
        Core.DoCmd("/multiline ; /rgl set DoPull false ; /timed 10 /rgl set DoPull true")
    end
end

---@param list string
---@param idx number
function Module:DeleteMobFromList(list, idx)
    self.settings[list][mq.TLO.Zone.ShortName()] = self.settings[list][mq.TLO.Zone.ShortName()] or {}
    self.settings[list][mq.TLO.Zone.ShortName()][idx] = nil
    self:SaveSettings(false)

    -- if we are pulling start over.
    if Config:GetSetting('DoPull') then
        Core.DoCmd("/multiline ; /rgl set DoPull false ; /timed 10 /rgl set DoPull true")
    end
end

function Module:IncrementWpId()
    if not self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then return end

    if (self.TempSettings.CurrentWP + 1) <= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then
        self.TempSettings.CurrentWP = self.TempSettings.CurrentWP + 1
    else
        self.TempSettings.CurrentWP = 1
    end
end

---@param id number
function Module:MoveWayPointUp(id)
    local newId = id - 1

    if newId < 1 then return end
    if id > #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then return end

    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId], self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id] =
        self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id], self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId]
    self:SaveSettings(false)
end

---@param id number
function Module:MoveWayPointDown(id)
    local newId = id + 1

    if id < 1 then return end
    if newId > #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then return end

    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId], self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id] =
        self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][id], self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][newId]

    self:SaveSettings(false)
end

function Module:CreateWayPointHere()
    self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] = self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] or {}
    table.insert(self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()], { x = mq.TLO.Me.X(), y = mq.TLO.Me.Y(), z = mq.TLO.Me.Z(), })
    self:SaveSettings(false)
    Logger.log_info("\axNew waypoint \at%d\ax created at location \ag%02.f, %02.f, %02.f", #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()],
        mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z())
end

function Module:DeleteWayPoint(idx)
    if idx <= #self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()] then
        Logger.log_info("\axWaypoint \at%d\ax at location \ag%s\ax - \arDeleted!\ax", idx, self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()][idx].Loc)
        table.remove(self.settings.FarmWayPoints[mq.TLO.Zone.ShortName()], idx)
        self:SaveSettings(false)
    else
        Logger.log_error("\ar%d is not a valid waypoint ID!", idx)
    end
end

-- because mq.TLO.Me.BuffCount() fails to update when gaining buffs without targeting yourself.
-- it does update when you lose buffs though.
---@return number -- # of buffs you have currently
function Module:CountBuffs()
    local count = 0
    for i = 1, mq.TLO.Me.MaxBuffSlots() do
        local buff = mq.TLO.Me.Buff(i)()
        if buff ~= nil then
            count = count + 1
        end
    end
    self.TempSettings.BuffCount = count
    return count
end

---@param campData table
---@return boolean, string
function Module:ShouldPull(campData)
    local me = mq.TLO.Me

    if me.PctHPs() < self.settings.PullHPPct then
        Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax PctHPs < %d", self.settings.PullHPPct)
        return false, string.format("PctHPs < %d", self.settings.PullHPPct)
    end

    if me.PctEndurance() < self.settings.PullEndPct then
        Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax PctEnd < %d", self.settings.PullEndPct)
        return false, string.format("PctEnd < %d", self.settings.PullEndPct)
    end

    if me.MaxMana() > 0 and me.PctMana() < self.settings.PullManaPct then
        Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax PctMana < %d", self.settings.PullManaPct)
        return false, string.format("PctMana < %d", self.settings.PullManaPct)
    end

    if Config:GetSetting('PullRespectMedState') and Config.Globals.InMedState then
        Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax Meditating.")
        return false, string.format("Meditating")
    end

    if Casting.BuffActiveByName("Resurrection Sickness") then
        Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax Rez Sickness for %d seconds.",
            mq.TLO.Me.Buff("Resurrection Sickness")() and mq.TLO.Me.Buff("Resurrection Sickness").Duration.TotalSeconds() or 0)
        return false, string.format("Resurrection Sickness")
    end

    if Config:GetSetting('PullWaitCorpse') then
        if mq.TLO.SpawnCount("pccorpse group radius 100 zradius 50")() > 0 then
            self.TempSettings.LastFoundGroupCorpse = os.clock()
            Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax %d group corpses in-range.", mq.TLO.SpawnCount("pccorpse group radius 100 zradius 50")())
            return false, string.format("Group Corpse Detected")
        elseif os.clock() - self.TempSettings.LastFoundGroupCorpse < Config:GetSetting('WaitAfterRez') then
            Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax Giving time for rebuffs after a groupmember was rezzed.")
            return false, string.format("Groupmember Recently Rezzed")
        end
    end

    if (me.Rooted.ID() or 0 > 0) then
        Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am rooted!")
        return false, string.format("Rooted")
    end

    if not Config:GetSetting('PullDebuffed') then
        if (me.Snared.ID() or 0 > 0) then
            Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am snared!")
            return false, string.format("Snared")
        end

        if Casting.SongActiveByName("Restless Ice") then
            Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax I Have Restless Ice!")
            return false, string.format("Restless Ice")
        end

        if Casting.SongActiveByName("Restless Ice Infection") then
            Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax I Have Restless Ice Infection!")
            return false, string.format("Ice Infection")
        end

        if (me.Poisoned.ID() or 0 > 0) and not (me.Tashed.ID()) or 0 > 0 then
            Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am poisoned!")
            return false, string.format("Poisoned")
        end

        if (me.Diseased.ID() or 0 > 0) then
            Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am diseased!")
            return false, string.format("Diseased")
        end

        if (me.Cursed.ID() or 0 > 0) then
            Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am cursed!")
            return false, string.format("Cursed")
        end

        if (me.Corrupted.ID() or 0 > 0) then
            Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax I am corrupted!")
            return false, string.format("Corrupted")
        end
    end

    if self.settings.PullBuffCount > 0 then
        if self:CountBuffs() < self.settings.PullBuffCount then
            Logger.log_info("\ay::PULL:: \arAborted!\ax Waiting for Buffs! BuffCount < %d", self.settings.PullBuffCount)
            return false, string.format("BuffCount < %d", self.settings.PullBuffCount)
        end
    end

    if self:IsPullMode("Chain") and Targeting.GetXTHaterCount() >= self.settings.ChainCount then
        Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax XTargetCount(%d) >= ChainCount(%d)", Targeting.GetXTHaterCount(), self.settings.ChainCount)
        return false, string.format("XTargetCount(%d) > ChainCount(%d)", Targeting.GetXTHaterCount(), self.settings.ChainCount)
    end

    if not self:IsPullMode("Chain") and Targeting.GetXTHaterCount() > 0 then
        Logger.log_super_verbose("\ay::PULL:: \arAborted!\ax XTargetCount(%d) > 0", Targeting.GetXTHaterCount())
        return false, string.format("XTargetCount(%d) > 0", Targeting.GetXTHaterCount())
    end

    if campData.returnToCamp and Math.GetDistanceSquared(me.X(), me.Y(), campData.campSettings.AutoCampX, campData.campSettings.AutoCampY) > math.max(Config:GetSetting('AutoCampRadius') ^ 2, 200 ^ 2) then
        Comms.PrintGroupMessage("I am too far away from camp - Holding pulls!")
        return false,
            string.format("I am Too Far (%d) (%d,%d) (%d,%d)", Math.GetDistanceSquared(me.X(), me.Y(), campData.campSettings.AutoCampX, campData.campSettings.AutoCampY),
                me.X(), me.Y(), campData.campSettings.AutoCampX, campData.campSettings.AutoCampY)
    end

    return true, ""
end

function Module:FarmFullInvActions()
    -- Bags are full. We now try and do the following...
    -- 1. Call a specifical sub defined in rgcustom.inc if it exists
    -- 2. Call origin if we have it and its ready so we can go home and sell
    -- 3. Stop farming
    --/if (${SubDefined[Farm_${Zone.ShortName}_FullInventory]}) {
    --    -/call Farm_${Zone.ShortName}_FullInventory
    -- } else /if (${RG_AAReady[Origin]}) {
    --    /call AANow ${Me.AltAbility[Origin].ID} ${Me.ID}
    -- } else {
    --    /echo Bags are full, can't origin back home. Stopping and beeping.
    --    /rg DoPull 0
    --    /beep
    -- }

    Logger.log_error("\arStopping Pulls - Bags are full!")
    self.settings.DoPull = false
    Core.DoCmd("/beep")
end

---comment
---@param classes table|nil # mq.Set type
---@param resourceResumePct number -- Resume pulls at this pct
---@param resourcePausePct number -- Hold pulls at this pct
---@param campData table
---@return boolean, string
function Module:CheckGroupForPull(classes, resourceResumePct, resourcePausePct, campData)
    local groupCount = mq.TLO.Group.Members()

    if not groupCount or groupCount == 0 then return true, "" end
    local maxDist = math.max(Config:GetSetting('AutoCampRadius') ^ 2, 200 ^ 2)

    for i = 1, groupCount do
        local member = mq.TLO.Group.Member(i)

        if member and member.ID() > 0 then
            if not classes or classes:contains(member.Class.ShortName()) then
                local resourcePct = self.TempSettings.PullState == PullStates.PULL_GROUPWATCH_WAIT and resourceResumePct or resourcePausePct
                if member.PctHPs() < resourcePct then
                    Comms.PrintGroupMessage("%s is low on hp - Holding pulls!", member.CleanName())
                    Logger.log_verbose("\arMember is low on Health - \ayHolding pulls!\ax\ag ResourcePCT:\ax \at%d \aoStopPct: \at%d \ayStartPct: \at%d \aoPullState: \at%d",
                        resourcePct, resourcePausePct, resourceResumePct, self.TempSettings.PullState)
                    return false, string.format("%s Low HP", member.CleanName())
                end
                if member.Class.CanCast() and member.Class.ShortName() ~= "BRD" and member.PctMana() < resourcePct then
                    Comms.PrintGroupMessage("%s is low on mana - Holding pulls!", member.CleanName())
                    Logger.log_verbose("\arMember is low on Mana - \ayHolding pulls!\ax\ag ResourcePCT:\ax \at%d \aoStopPct: \at%d \ayStartPct: \at%d \aoPullState: \at%d",
                        resourcePct, resourcePausePct, resourceResumePct, self.TempSettings.PullState)
                    return false, string.format("%s Low Mana", member.CleanName())
                end
                if Config:GetSetting('GroupWatchEnd') and member.Class.ShortName() ~= "BRD" and member.PctEndurance() < resourcePct then
                    Comms.PrintGroupMessage("%s is low on endurance - Holding pulls!", member.CleanName())
                    Logger.log_verbose(
                        "\arMember is low on Endurance - \ayHolding pulls!\ax\ag ResourcePCT:\ax \at%d \aoStopPct: \at%d \ayStartPct: \at%d \aoPullState: \at%d", resourcePct,
                        resourcePausePct, resourceResumePct, self.TempSettings.PullState)
                    return false, string.format("%s Low End", member.CleanName())
                end

                if member.Hovering() then
                    Comms.PrintGroupMessage("%s is dead - Holding pulls!", member.CleanName())
                    return false, string.format("%s Dead", member.CleanName())
                end

                if member.OtherZone() then
                    Comms.PrintGroupMessage("%s is in another zone - Holding pulls!", member.CleanName())
                    return false, string.format("%s Out of Zone", member.CleanName())
                end

                if campData.returnToCamp then
                    if Math.GetDistanceSquared(member.X(), member.Y(), campData.campSettings.AutoCampX, campData.campSettings.AutoCampY) > maxDist then
                        Comms.PrintGroupMessage("%s is too far away - Holding pulls!", member.CleanName())
                        return false,
                            string.format("%s Too Far (%d) (%d,%d) (%d,%d)", member.CleanName(),
                                Math.GetDistance(member.X(), member.Y(), campData.campSettings.AutoCampX, campData.campSettings.AutoCampY), member.X(), member.Y(),
                                campData.campSettings.AutoCampX, campData.campSettings.AutoCampY)
                    end
                else
                    if (member.Distance() or 0) > math.max(Config:GetSetting('AutoCampRadius'), 200) then
                        Comms.PrintGroupMessage("%s is too far away - Holding pulls!", member.CleanName())
                        return false,
                            string.format("%s Too Far (%d) (%d,%d) (%d,%d)", member.CleanName(),
                                Math.GetDistance(member.X(), member.Y(), campData.campSettings.AutoCampX, campData.campSettings.AutoCampY), member.X(), member.Y(),
                                mq.TLO.Me.X(),
                                mq.TLO.Me.Y())
                    end
                end

                if self.Constants.PullModes[self.settings.PullMode] == "Chain" then
                    if member.ID() == Core.GetMainAssistId() then
                        if campData.returnToCamp and Math.GetDistanceSquared(member.X(), member.Y(), campData.campSettings.AutoCampX, campData.campSettings.AutoCampY) > maxDist then
                            Comms.PrintGroupMessage("%s (assist target) is beyond AutoCampRadius from %d, %d, %d : %d. Holding pulls.", member.CleanName(),
                                campData.campSettings.AutoCampY,
                                campData.campSettings.AutoCampX, campData.campSettings.AutoCampZ, Config:GetSetting('AutoCampRadius'))
                            return false, string.format("%s Beyond AutoCampRadius", member.CleanName())
                        end
                    else
                        if Math.GetDistanceSquared(member.X(), member.Y(), mq.TLO.Me.X(), mq.TLO.Me.Y()) > maxDist then
                            Comms.PrintGroupMessage("%s (assist target) is beyond AutoCampRadius from me : %d. Holding pulls.", member.CleanName(),
                                Config:GetSetting('AutoCampRadius'))
                            return false, string.format("%s Beyond AutoCampRadius", member.CleanName())
                        end
                    end
                end
            end
        end
    end

    return true, ""
end

function Module:FixPullerMerc()
    if os.clock() - self.TempSettings.LastPullerMercCheck < 15 then return end
    self.TempSettings.LastPullerMercCheck = os.clock()

    if mq.TLO.Group.Leader() ~= mq.TLO.Me.DisplayName() then return end

    local groupCount = mq.TLO.Group.Members()

    for i = 1, groupCount do
        local merc = mq.TLO.Group.Member(i)

        ---@diagnostic disable-next-line: param-type-mismatch
        if merc and merc() and Targeting.TargetIsType("Mercenary", merc) and merc.Owner.DisplayName() == mq.TLO.Group.Puller() then
            if (merc.Distance() or 0) > Config:GetSetting('AutoCampRadius') and (merc.Owner.Distance() or 0) < Config:GetSetting('AutoCampRadius') then
                Core.DoCmd("/grouproles unset %s 3", merc.Owner.DisplayName())
                mq.delay("10s", function() return (merc.Distance() or 0) < Config:GetSetting('AutoCampRadius') end)
                Core.DoCmd("/grouproles set %s 3", merc.Owner.DisplayName())
            end
        end
    end
end

function Module:GetPullableSpawns()
    local pullRadius = Config:GetSetting('PullRadius')
    local maxPathRange = Config:GetSetting('MaxPathRange')

    local metaDataCache = {}

    if self:IsPullMode("Farm") then
        pullRadius = Config:GetSetting('PullRadiusFarm')
    elseif self:IsPullMode("Hunt") then
        pullRadius = Config:GetSetting('PullRadiusHunt')
    end

    local pullRadiusSqr = pullRadius * pullRadius

    local spawnFilter = function(spawn)
        if not spawn() or spawn.ID() == 0 then return false end
        if not spawn.Targetable() then return false end
        if spawn.Type() ~= "NPC" and spawn.Type() ~= "NPCPET" then
            Logger.log_verbose("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \aois type %s not an NPC or NPCPET -- Skipping", spawn.CleanName(), spawn.ID(),
                spawn.Type())
            return false
        end

        if spawn.Master.Type() == 'PC' then
            Logger.log_debug("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \aois Charmed Pet -- Skipping", spawn.CleanName(), spawn.ID())
            return false
        elseif self:IsPullMode("Chain") then
            if Targeting.IsSpawnXTHater(spawn.ID()) then
                Logger.log_debug("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \aoAlready on XTarget -- Skipping", spawn.CleanName(), spawn.ID())
                return false
            end
        end

        if self:HaveList("PullAllowList") then
            if self:IsMobInList("PullAllowList", spawn.CleanName(), true) == false then
                Logger.log_debug("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \ar -> Not Found in Allow List!", spawn.CleanName(), spawn.ID())
                return false
            end
        elseif self:HaveList("PullDenyList") then
            if self:IsMobInList("PullDenyList", spawn.CleanName(), false) == true then
                Logger.log_debug("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \ar -> Found in Deny List!", spawn.CleanName(), spawn.ID())
                return false
            end
        end

        if spawn.FeetWet() and not Config:GetSetting('PullMobsInWater') then
            Logger.log_debug("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \agIgnoring mob in water water", spawn.CleanName(), spawn.ID())
            return false
        end

        -- Level Checks
        if self.settings.UsePullLevels then
            if spawn.Level() < self.settings.PullMinLevel then
                Logger.log_verbose("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \aoLevel too low - %d", spawn.CleanName(), spawn.ID(),
                    spawn.Level())
                return false
            end
            if spawn.Level() > self.settings.PullMaxLevel then
                Logger.log_verbose("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \aoLevel too high - %d", spawn.CleanName(), spawn.ID(),
                    spawn.Level())
                return false
            end
        else
            -- check cons.
            local conLevel = Config.Constants.ConColorsNameToId[spawn.ConColor()]
            if conLevel > self.settings.PullMaxCon or conLevel < self.settings.PullMinCon then
                Logger.log_verbose("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw)  - Ignoring mob due to con color. Min = %d, Max = %d, Mob = %d (%s)",
                    spawn.CleanName(), spawn.ID(),
                    self.settings.PullMinCon,
                    self.settings.PullMaxCon, conLevel, spawn.ConColor())
                return false
            end
            -- check max level difference
            local maxLvl = mq.TLO.Me.Level() + self.settings.MaxLevelDiff
            if spawn.Level() > maxLvl then
                Logger.log_verbose("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw)  - Ignoring mob due to max level difference. Max Level = %d, Mob = %d",
                    spawn.CleanName(), spawn.ID(), maxLvl, spawn.Level())
                return false
            end
        end

        local checkX, checkY, checkZ = mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z()

        if self:IsPullMode("Farm") then
            local wpId = self:GetCurrentWpId()
            local wpData = self:GetWPById(wpId)
            checkX, checkY, checkZ = wpData.x, wpData.y, wpData.z
        elseif self:IsPullMode("Hunt") then
            checkX, checkY, checkZ = self.TempSettings.HuntX, self.TempSettings.HuntY, self.TempSettings.HuntZ
        end

        -- do distance checks.
        if math.abs(spawn.Z() - checkZ) > self.settings.PullZRadius then
            Logger.log_verbose("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \aoZDistance too far - %d > %d", spawn.CleanName(), spawn.ID(),
                math.abs(spawn.Z() - checkZ),
                self.settings.PullZRadius)
            return false
        end

        local distSqr = Math.GetDistanceSquared(spawn.X(), spawn.Y(), checkX, checkY)

        if distSqr > pullRadiusSqr then
            Logger.log_verbose("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \aoDistance too far - distSq(%d) > pullRadiusSq(%d)",
                spawn.CleanName(), spawn.ID(), distSqr,
                pullRadiusSqr)
            return false
        end

        local navDist = 0
        local canPath = true

        if maxPathRange > 0 then
            navDist = mq.TLO.Navigation.PathLength("id " .. spawn.ID())()
            canPath = navDist > 0
        else
            canPath = mq.TLO.Navigation.PathExists("id " .. spawn.ID())()
        end

        if not canPath or navDist > maxPathRange then
            Logger.log_debug("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \aoPath check failed - dist(%d) canPath(%s)", spawn.CleanName(),
                spawn.ID(), navDist, Strings.BoolToColorString(canPath))
            return false
        end

        if Config:GetSetting('SafeTargeting') and Targeting.IsSpawnFightingStranger(spawn, 500) then
            Logger.log_debug("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \ar mob is fighting a stranger and safe targeting is enabled!",
                spawn.CleanName(), spawn.ID())
            return false
        end

        Logger.log_debug("\atPULL::FindTarget \awFindTarget :: Spawn \am%s\aw (\at%d\aw) \agPotential Pull Added to List", spawn.CleanName(), spawn.ID())

        metaDataCache[spawn.ID()] = { distance = navDist, }

        return true
    end

    local pullTargets = mq.getFilteredSpawns(spawnFilter)

    table.sort(pullTargets, function(a, b)
        -- spawn could be invalid by now so double check
        if a.ID() == 0 or a.Dead() then return false end
        if b.ID() == 0 or b.Dead() then return true end

        return metaDataCache[a.ID()].distance < metaDataCache[b.ID()].distance
    end)

    return pullTargets, metaDataCache
end

function Module:FindTarget()
    local pullTargets, metaData = self:GetPullableSpawns()

    self.TempSettings.PullTargets = pullTargets
    self.TempSettings.PullTargetsMetaData = metaData

    if #pullTargets > 0 then
        local pullTarget = pullTargets[1]
        Logger.log_info("\atPULL::FindTarget \agPulling %s [%d] with Distance: %d", pullTarget.CleanName(), pullTarget.ID(), metaData[pullTarget.ID()].distance)
        return pullTarget.ID()
    end

    return 0
end

---@param pullID number
---@return boolean
function Module:CheckForAbort(pullID)
    if self.TempSettings.AbortPull then
        Logger.log_debug("\ar ALERT: Aborting pull on user request. \ax")
        self.TempSettings.AbortPull = false
        return true
    end

    if (not Config:GetSetting('DoPull') and self.TempSettings.TargetSpawnID == 0) or Config.Globals.PauseMain then
        Logger.log_debug("\ar ALERT: Pulling Disabled at user request. \ax")
        return true
    end

    if pullID == 0 then return true end

    Logger.log_verbose("Checking for abort on spawn id: %d", pullID)
    local spawn = mq.TLO.Spawn(pullID)

    if not spawn or spawn.Dead() or not spawn.ID() or spawn.ID() == 0 then
        Logger.log_debug("\ar ALERT: Aborting mob died or despawned \ax")
        return true
    end

    -- ignore distance if this is a manually requested pull
    if pullID ~= self.TempSettings.TargetSpawnID then
        if not self:IsPullMode("Farm") and spawn.Distance() > self.settings.PullRadius then
            Logger.log_debug("\ar ALERT: Aborting mob moved out of spawn distance \ax")
            return true
        end


        if self:IsPullMode("Farm") and spawn.Distance() > self.settings.PullRadiusFarm then
            Logger.log_debug("\ar ALERT: Aborting mob moved out of spawn distance \ax")
            return true
        end

        if Config:GetSetting('SafeTargeting') and Targeting.IsSpawnFightingStranger(spawn, 500) then
            Logger.log_debug("\ar ALERT: Aborting mob is fighting a stranger and safe targeting is enabled! \ax")
            return true
        end
    end
    return false
end

---@param mode string
---@return boolean
function Module:IsPullMode(mode)
    return self.Constants.PullModes[self.settings.PullMode] == mode
end

---@return integer
function Module:GetPullState()
    return self.TempSettings.PullState
end

---@param state string
---@return boolean
function Module:IsPullState(state)
    return self.TempSettings.PullState == PullStates[state]
end

---@param state number
---@param reason string
function Module:SetPullState(state, reason)
    self.TempSettings.PullState = state
    self.TempSettings.PullStateReason = reason
end

function Module:NavToWaypoint(loc, ignoreAggro)
    -- if DoMed is set it will take care of standing us up
    if mq.TLO.Me.Sitting() then
        Config.Globals.InMedState = false
    end

    mq.TLO.Me.Stand()

    Core.DoCmd("/nav locyxz %s, log=off", loc)
    mq.delay("2s")

    while mq.TLO.Navigation.Active() do
        Logger.log_verbose("NavToWaypoint Aggro Count: %d", Targeting.GetXTHaterCount())

        if Targeting.GetXTHaterCount() > 0 and not ignoreAggro then
            if mq.TLO.Navigation.Active() then
                Core.DoCmd("/nav stop log=off")
            end
            return false
        end

        if mq.TLO.Navigation.Velocity() == 0 then
            Logger.log_warn("NavToWaypoint Velocity is 0 - Are we stuck?")
            if mq.TLO.Navigation.Paused() then
                Core.DoCmd("/nav pause log=off")
            end
        end

        mq.delay(10)
    end

    return true
end

function Module:GetPullAbilityRange()
    if not self.ModuleLoaded then return 0 end
    local pullAbility = self.TempSettings.ValidPullAbilities[self.settings.PullAbility]
    if not pullAbility then return 0 end

    local ret = pullAbility.AbilityRange
    if type(ret) == 'function' then ret = ret() end
    return ret
end

function Module:GetPullStateTargetInfo()
    return string.format("%s(%d) Dist(%d)", Targeting.GetTargetCleanName(), Targeting.GetTargetID(), Targeting.GetTargetDistance())
end

function Module:GiveTime(combat_state)
    if combat_state ~= "Downtime" then
        Logger.log_verbose("PULL:GiveTime() we are in %s, not ready for pulling.", combat_state)
        return
    end
    if (os.clock() - self.TempSettings.LastPullOrCombatEnded) < self.settings.PullDelay then
        Logger.log_verbose("PULL:GiveTime() waiting for Pull Delay, next attempt in %d seconds.", self.settings.PullDelay - (os.clock() - self.TempSettings.LastPullOrCombatEnded))
        return
    end

    Logger.log_verbose("PULL:GiveTime() - Enter")
    self:SetValidPullAbilities()
    self:FixPullerMerc()
    if Config:GetSetting('DoPull') then
        for _, v in pairs(self.settings.PullSafeZones) do
            if v == mq.TLO.Zone.ShortName() then
                local safeZone = mq.TLO.Zone.ShortName()
                Logger.log_debug("\ar ALERT: In a safe zone \at%s \ax-\ar Disabling Pulling. \ax", safeZone)
                self.settings.DoPull = false
                break
            end
        end
    end

    if not Config:GetSetting('DoPull') and (self.TempSettings.HuntX ~= 0 or self.TempSettings.HuntY ~= 0 or self.TempSettings.HuntZ ~= 0) then
        self.TempSettings.HuntX = 0
        self.TempSettings.HuntY = 0
        self.TempSettings.HuntZ = 0
        Core.DoCmd("/mapfilter pullradius off")
    end

    Logger.log_verbose("PULL:GiveTime() - DoPull: %s", Strings.BoolToColorString(Config:GetSetting('DoPull')))
    if not Config:GetSetting('DoPull') and self.TempSettings.TargetSpawnID == 0 then return end

    if Config:GetSetting('DoPull') and self:IsPullMode("Hunt") and ((self.TempSettings.HuntX == 0 or self.TempSettings.HuntY == 0 or self.TempSettings.HuntZ == 0) or Config:GetSetting('HuntFromPlayer')) then
        self.TempSettings.HuntX = mq.TLO.Me.X()
        self.TempSettings.HuntY = mq.TLO.Me.Y()
        self.TempSettings.HuntZ = mq.TLO.Me.Z()
        Core.DoCmd("/squelch /mapfilter pullradius %d", Config:GetSetting('PullRadiusHunt'))
    end

    if not mq.TLO.Navigation.MeshLoaded() then
        Logger.log_error("\ar ERROR: There's no mesh for this zone. Can't pull. \ax")
        Logger.log_error("\ar Disabling Pulling. \ax")
        self.settings.DoPull = false
        return
    end

    local campData = Modules:ExecModule("Movement", "GetCampData")

    if self.settings.PullAbility == PullAbilityIDToName.PetPull and (mq.TLO.Me.Pet.ID() or 0) == 0 then
        Comms.PrintGroupMessage("Need to create a new pet to throw as mob fodder.")
        return
    end

    local shouldPull, reason = self:ShouldPull(campData)

    Logger.log_verbose("PULL:GiveTime() - ShouldPull: %s", Strings.BoolToColorString(shouldPull))

    if not shouldPull then
        if not mq.TLO.Navigation.Active() and combat_state == "Downtime" then
            -- go back to camp.
            self:SetPullState(PullStates.PULL_WAITING_SHOULDPULL, reason)
            if campData.returnToCamp then
                local distanceToCampSq = Math.GetDistanceSquared(mq.TLO.Me.Y(), mq.TLO.Me.X(), campData.campSettings.AutoCampY, campData.campSettings.AutoCampX)
                if distanceToCampSq > (Config:GetSetting('AutoCampRadius') ^ 2) then
                    Logger.log_debug("Distance to camp is %d and radius is %d - going closer.", math.sqrt(distanceToCampSq), Config:GetSetting('AutoCampRadius'))
                    Core.DoCmd("/nav locyxz %0.2f %0.2f %0.2f log=off", campData.campSettings.AutoCampY, campData.campSettings.AutoCampX, campData.campSettings.AutoCampZ)
                end
            end
        end
        return
    end

    -- GROUPWATCH and NAVINTERRUPT are the two states we can't reset. In the future it may be best to
    -- limit this to only the states we know should be transitionable to the IDLE state.
    if self.TempSettings.PullState ~= PullStates.PULL_GROUPWATCH_WAIT and self.TempSettings.PullState ~= PullStates.PULL_NAV_INTERRUPT then
        self:SetPullState(PullStates.PULL_IDLE, "")
    end

    self:SetLastPullOrCombatEndedTimer()

    if self.settings.GroupWatch == 2 then
        local groupReady, groupReason = self:CheckGroupForPull(Set.new({ "CLR", "DRU", "SHM", }), self.settings.GroupWatchStartPct, self.settings.GroupWatchStopPct, campData)
        if not groupReady then
            Logger.log_verbose("PULL:GiveTime() - GroupWatch Failed")
            self:SetPullState(PullStates.PULL_GROUPWATCH_WAIT, groupReason)
            return
        end
    elseif self.settings.GroupWatch == 3 then
        local groupReady, groupReason = self:CheckGroupForPull(nil, self.settings.GroupWatchStartPct, self.settings.GroupWatchStopPct, campData)
        if not groupReady then
            Logger.log_verbose("PULL:GiveTime() - GroupWatch2 Failed")
            self:SetPullState(PullStates.PULL_GROUPWATCH_WAIT, groupReason)
            return
        end
    end

    self:SetPullState(PullStates.PULL_IDLE, "")

    -- We're ready to pull, but first, check if we're in farm mode and if we were interrupted
    if self:IsPullMode("Farm") then
        local currentWpId = self:GetCurrentWpId()
        if currentWpId == 0 then
            Logger.log_error("\arYou do not have a valid WP ID(%d) for this zone(%s::%s) - Aborting!", self.TempSettings.CurrentWP, mq.TLO.Zone.Name(),
                mq.TLO.Zone.ShortName())
            self:SetPullState(PullStates.PULL_IDLE, "")
            self.settings.DoPull = false
            return
        end

        if self.TempSettings.PullState == PullStates.PULL_NAV_INTERRUPT then
            -- if we still have haters let combat handle it first.
            if Targeting.GetXTHaterCount() > 0 then
                return
            end

            -- We're not ready to pull yet as we haven't made it to our waypoint. Keep navigating if we don't have a full inventory
            if mq.TLO.Me.FreeInventory() == 0 then self:FarmFullInvActions() end

            self:SetPullState(PullStates.PULL_MOVING_TO_WP, string.format("WP Id: %d", currentWpId))
            -- TODO: PreNav Actions
            if not self:NavToWaypoint(self:GetWPById(currentWpId)) then
                self:SetPullState(PullStates.PULL_NAV_INTERRUPT, "")
                return
            else
                self:SetPullState(PullStates.PULL_IDLE, "")
            end
            self:SetPullState(PullStates.PULL_IDLE, "")
        end

        -- We're not in an interrupted state if we make it this far -- so
        -- now make sure we have free inventory or not.
        if mq.TLO.Me.FreeInventory() == 0 then self:FarmFullInvActions() end
    end

    self:SetPullState(PullStates.PULL_SCAN, "")

    self.TempSettings.PullID = 0

    if self.TempSettings.TargetSpawnID > 0 then
        local targetSpawn = mq.TLO.Spawn(self.TempSettings.TargetSpawnID)
        if not targetSpawn() or targetSpawn.Dead() then
            Logger.log_debug("\arDropping Manual target id %d - it is dead.", self.TempSettings.TargetSpawnID)
            self.TempSettings.TargetSpawnID = 0
        end
    end

    if self.TempSettings.TargetSpawnID > 0 then
        self.TempSettings.PullID = self.TempSettings.TargetSpawnID
    else
        Logger.log_debug("Finding Pull Target")
        self.TempSettings.PullID = self:FindTarget()
    end

    if self.TempSettings.PullID == 0 and self:IsPullMode("Farm") then
        -- move to next WP
        self:IncrementWpId()
        -- Here we want to nav to our current waypoint. If we engage an enemy while
        -- we are currently traveling to our waypoint, we need to set our state to
        -- PULL_NAVINTERRUPT so that when Pulling re-engages after combat, we continue
        -- to travel to our next waypoint.

        -- TODO: PreNav()
        --/if (${SubDefined[${Zone.ShortName}_PreNav_${Pull_FarmWPNum}]}) /call ${Zone.ShortName}_PreNav_${Pull_FarmWPNum}

        local wpData = self:GetWPById(self:GetCurrentWpId())
        self:SetPullState(PullStates.PULL_MOVING_TO_WP, string.format("%0.2f, %0.2f, %0.2f", wpData.y, wpData.x, wpData.z))
        if not self:NavToWaypoint(string.format("%0.2f, %0.2f, %0.2f", wpData.y, wpData.x, wpData.z)) then
            self:SetPullState(PullStates.PULL_NAV_INTERRUPT, "")
            return
        else
            -- TODO: AtWP()
            --/if (${SubDefined[${Zone.ShortName}_AtWaypoint_${Pull_FarmWPNum}]}) /call ${Zone.ShortName}_AtWaypoint_${Pull_FarmWPNum}
        end

        self:SetPullState(PullStates.PULL_IDLE, "")
        return
    end

    self:SetPullState(PullStates.PULL_IDLE, "")

    if self.TempSettings.PullID == 0 then
        Logger.log_debug("\ayNothing to pull - better luck next time")
        return
    end

    local start_x = mq.TLO.Me.X()
    local start_y = mq.TLO.Me.Y()
    local start_z = mq.TLO.Me.Z()

    if campData.returnToCamp then
        Logger.log_debug("\ayRTB: Storing Camp info to return to")
        start_x = campData.campSettings.AutoCampX
        start_y = campData.campSettings.AutoCampY
        start_z = campData.campSettings.AutoCampZ
    end

    Logger.log_debug("\ayRTB Location: %d %d %d", start_y, start_x, start_z)

    -- if DoMed is set it will take care of standing us up
    if mq.TLO.Me.Sitting() then
        Config.Globals.InMedState = false
    end

    mq.TLO.Me.Stand()

    self:SetPullState(PullStates.PULL_NAV_TO_TARGET, string.format("Id: %d", self.TempSettings.PullID))
    Logger.log_debug("\ayFound Target: %d - Attempting to Nav", self.TempSettings.PullID)

    local pullAbility = self.TempSettings.ValidPullAbilities[self.settings.PullAbility]
    local startingXTargs = Targeting.GetXTHaterIDs()
    local requireLOS = "on"

    if pullAbility and pullAbility.LOS == false then
        requireLOS = "off"
    end

    Core.DoCmd("/squelch /attack off")

    Core.DoCmd("/nav id %d distance=%d lineofsight=%s log=off", self.TempSettings.PullID, self:GetPullAbilityRange(), requireLOS)

    mq.delay(1000)

    local abortPull = false

    while mq.TLO.Navigation.Active() and mq.TLO.Navigation.Velocity() > 0 do
        Logger.log_super_verbose("Pathing to pull id...")
        if self:IsPullMode("Chain") then
            if Targeting.GetXTHaterCount() >= self.settings.ChainCount then
                Logger.log_info("\awNOTICE:\ax Gained aggro -- aborting chain pull!")
                abortPull = true
                break
            end
            if Targeting.DiffXTHaterIDs(startingXTargs) then
                Logger.log_info("\awNOTICE:\ax XTarget List Changed -- aborting chain pull!")
                abortPull = true
                break
            end
        else
            if Targeting.GetXTHaterCount() > 0 then
                Logger.log_info("\awNOTICE:\ax Gained aggro -- aborting pull!")
                abortPull = true
                break
            end
        end

        if self:CheckForAbort(self.TempSettings.PullID) then
            abortPull = true
            break
        end

        mq.delay(100)
        mq.doevents()
    end

    mq.delay("2s", function() return not mq.TLO.Me.Moving() end)

    -- TODO: PrePullTarget()

    Targeting.SetTarget(self.TempSettings.PullID)

    if mq.TLO.Target.Master.Type() == 'PC' then
        Logger.log_debug("\atPULL::PullTarget \awPullTarget :: Spawn \am%s\aw (\at%d\aw) is Charmed Pet -- Skipping", mq.TLO.Target.CleanName(), mq.TLO.Target.ID())
        abortPull = true
    end

    if Config:GetSetting('SafeTargeting') then
        -- Hard coding 500 units as our radius as it's probably twice our effective spell range.
        if Targeting.IsSpawnFightingStranger(mq.TLO.Spawn(self.TempSettings.PullID), 500) then
            abortPull = true
        end
    end

    if abortPull == false then
        local target = mq.TLO.Target
        self:SetPullState(PullStates.PULL_PULLING, self:GetPullStateTargetInfo())

        if target and target.ID() > 0 then
            Logger.log_info("\agPulling %s [%d]", target.CleanName(), target.ID())

            local successFn = function() return Targeting.GetXTHaterCount() > 0 end

            if self:IsPullMode("Chain") then
                successFn = function() return Targeting.GetXTHaterCount() >= self.settings.ChainCount end
            end

            if self.settings.PullAbility == PullAbilityIDToName.PetPull then -- PetPull
                Combat.PetAttack(self.TempSettings.PullID, false)
                while not successFn() do
                    Logger.log_super_verbose("Waiting on pet pull to finish...")
                    Combat.PetAttack(self.TempSettings.PullID, false)
                    mq.doevents()
                    if self:IsPullMode("Chain") and Targeting.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(self.TempSettings.PullID) then
                        break
                    end
                    mq.delay(10)
                end

                if Casting.CanUseAA("Companion's Discipline") then
                    Core.DoCmd("/squelch /pet ghold on")
                end
                Core.DoCmd("/squelch /pet back off")
                mq.delay("1s", function() return (mq.TLO.Pet.PlayerState() or 0) == 0 end)
                Core.DoCmd("/squelch /pet follow")
            elseif self.settings.PullAbility == PullAbilityIDToName.Face then -- Face pull
                -- Make sure we're looking straight ahead at our mob and delay
                -- until we're facing them.
                Core.DoCmd("/look 0")

                mq.delay("3s", function() return mq.TLO.Me.Heading.ShortName() == target.HeadingTo.ShortName() end)

                -- We will continue to fire arrows until we aggro our target
                while not successFn() do
                    Logger.log_super_verbose("Waiting on face pull to finish...")
                    mq.doevents()

                    Core.DoCmd("/nav id %d distance=%d lineofsight=%s log=off", self.TempSettings.PullID, self:GetPullAbilityRange(), "on")

                    if self:IsPullMode("Chain") and Targeting.DiffXTHaterIDs(startingXTargs) then
                        Logger.log_debug("\arXtargs changed heading back to camp!")
                        break
                    end

                    if self:CheckForAbort(self.TempSettings.PullID) then
                        break
                    end
                    mq.delay(10)
                end
            elseif self.settings.PullAbility == PullAbilityIDToName.Ranged then -- Ranged pull
                -- Make sure we're looking straight ahead at our mob and delay
                -- until we're facing them.
                Core.DoCmd("/look 0")

                mq.delay("3s", function() return mq.TLO.Me.Heading.ShortName() == target.HeadingTo.ShortName() end)

                -- We will continue to fire arrows until we aggro our target
                while not successFn() do
                    Logger.log_super_verbose("Waiting on ranged pull to finish... %s", Strings.BoolToColorString(successFn()))

                    if Targeting.GetTargetDistance() > self:GetPullAbilityRange() then
                        Core.DoCmd("/nav id %d distance=%d lineofsight=%s log=off", self.TempSettings.PullID, self:GetPullAbilityRange() / 2, requireLOS)
                        mq.delay("5s", function() return not mq.TLO.Navigation.Active() end)
                    end

                    Core.DoCmd("/ranged %d", self.TempSettings.PullID)
                    mq.doevents()
                    if self:IsPullMode("Chain") and Targeting.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(self.TempSettings.PullID) then
                        break
                    end
                    mq.delay(10)
                end
            elseif self.settings.PullAbility == PullAbilityIDToName.AutoAttack then -- Auto Attack pull
                -- Make sure we're looking straight ahead at our mob and delay
                -- until we're facing them.
                Core.DoCmd("/look 0")

                mq.delay("3s", function() return mq.TLO.Me.Heading.ShortName() == target.HeadingTo.ShortName() end)

                -- We will continue to fire arrows until we aggro our target
                while not successFn() do
                    Logger.log_super_verbose("Waiting on ranged pull to finish... %s", Strings.BoolToColorString(successFn()))
                    Core.DoCmd("/attack")

                    if Targeting.GetTargetDistance() > self:GetPullAbilityRange() then
                        Core.DoCmd("/nav id %d distance=%d lineofsight=%s log=off", self.TempSettings.PullID, self:GetPullAbilityRange() / 2, requireLOS)
                        mq.delay("5s", function() return not mq.TLO.Navigation.Active() end)
                    end

                    mq.doevents()
                    if self:IsPullMode("Chain") and Targeting.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(self.TempSettings.PullID) then
                        break
                    end
                    mq.delay(10)
                end
            else -- AA/Spell/Ability pull
                mq.delay(5)
                while not successFn() do
                    Logger.log_super_verbose("Waiting on ability pull to finish...%s", Strings.BoolToColorString(successFn()))
                    Targeting.SetTarget(self.TempSettings.PullID)
                    mq.doevents()

                    if mq.TLO.Target.FeetWet() ~= mq.TLO.Me.FeetWet() then
                        Logger.log_debug("\ar ALERT: Feet wet mismatch - Moving around\ax")
                        Core.DoCmd("/nav id %d distance=%d lineofsight=%s log=off", self.TempSettings.PullID, Targeting.GetTargetDistance() * 0.9, requireLOS)
                    end

                    if Targeting.GetTargetDistance() > self:GetPullAbilityRange() then
                        Core.DoCmd("/nav id %d distance=%d lineofsight=%s log=off", self.TempSettings.PullID, self:GetPullAbilityRange() / 2, requireLOS)
                        mq.delay(500, function() return mq.TLO.Navigation.Active() end)
                        mq.delay("5s", function() return not mq.TLO.Navigation.Active() end)
                    end

                    if pullAbility.Type:lower() == "ability" then
                        if mq.TLO.Me.AbilityReady(pullAbility.id)() then
                            local abilityName = pullAbility.AbilityName
                            if type(abilityName) == 'function' then abilityName = abilityName() end
                            Casting.UseAbility(abilityName)
                        end
                    elseif pullAbility.Type:lower() == "spell" then
                        local abilityName = pullAbility.AbilityName
                        if type(abilityName) == 'function' then abilityName = abilityName() end
                        Casting.UseSpell(abilityName, self.TempSettings.PullID, false, false, true)
                    elseif pullAbility.Type:lower() == "aa" then
                        local aaName = pullAbility.AbilityName
                        if type(aaName) == 'function' then aaName = aaName() end
                        Casting.UseAA(aaName, self.TempSettings.PullID)
                    elseif pullAbility.Type:lower() == "item" then
                        local itemName = pullAbility.ItemName
                        if type(itemName) == 'function' then itemName = itemName() end
                        Logger.log_debug("Attempting to pull with Item: %s", itemName)
                        Casting.UseItem(itemName, self.TempSettings.PullID)
                    else
                        Logger.log_error("\arInvalid PullAbilityType: %s :: %s", pullAbility.Type, pullAbility.id)
                    end

                    if self:IsPullMode("Chain") and Targeting.DiffXTHaterIDs(startingXTargs) then
                        break
                    end

                    if self:CheckForAbort(self.TempSettings.PullID) then
                        break
                    end
                    mq.delay(10)
                end
            end
        end
    else
        Logger.log_debug("\arNOTICE:\ax Pull Aborted!")
        Core.DoCmd("/nav stop log=off")
        mq.delay("2s", function() return not mq.TLO.Navigation.Active() end)
    end

    if self:IsPullMode("Normal") or self:IsPullMode("Chain") then
        -- Nav back to camp.
        self:SetPullState(PullStates.PULL_RETURN_TO_CAMP, string.format("Camp Loc: %0.2f %0.2f %0.2f", start_y, start_x, start_z))

        Core.DoCmd("/nav locyxz %0.2f %0.2f %0.2f log=off %s", start_y, start_x, start_z, Config:GetSetting('PullBackwards') and "facing=backward" or "")
        mq.delay("5s", function() return mq.TLO.Navigation.Active() end)

        while mq.TLO.Navigation.Active() and (combat_state == "Downtime" or Targeting.GetXTHaterCount() > 0) do
            Logger.log_super_verbose("Pathing to camp...")
            if mq.TLO.Me.State():lower() == "feign" or mq.TLO.Me.Sitting() then
                Logger.log_debug("Standing up to Engage Target")
                mq.TLO.Me.Stand()
                Core.DoCmd("/nav locyxz %0.2f %0.2f %0.2f log=off %s", start_y, start_x, start_z, Config:GetSetting('PullBackwards') and "facing=backward" or "")
                mq.delay("5s", function() return mq.TLO.Navigation.Active() end)
            end

            if mq.TLO.Navigation.Paused() then
                Core.DoCmd("/nav pause")
            end
            mq.doevents()
            mq.delay(10)
        end

        Core.DoCmd("/face id %d", self.TempSettings.PullID)

        self:SetPullState(PullStates.PULL_WAITING_ON_MOB, self:GetPullStateTargetInfo())

        -- give the mob 2 mins to get to us.
        local maxPullWait = 1000 * 120 -- 2 mins
        -- wait for the mob to reach us.
        while mq.TLO.Target.ID() == self.TempSettings.PullID and Targeting.GetTargetDistance() > Config:GetSetting('AutoCampRadius') and maxPullWait > 0 do
            self:SetPullState(PullStates.PULL_WAITING_ON_MOB, self:GetPullStateTargetInfo())
            mq.delay(100)
            if mq.TLO.Me.Pet.Combat() then
                Core.DoCmd("/squelch /pet back off")
                mq.delay("1s", function() return (mq.TLO.Pet.PlayerState() or 0) == 0 end)
                Core.DoCmd("/squelch /pet follow")
            end
            maxPullWait = maxPullWait - 100

            if self:CheckForAbort(self.TempSettings.PullID) then
                break
            end

            -- they ain't coming!
            if not Targeting.IsSpawnXTHater(self.TempSettings.PullID) then
                break
            end
        end
        -- TODO PostPullCampFunc()
    end

    self.TempSettings.TargetSpawnID = 0
    self:SetPullState(PullStates.PULL_IDLE, "")
end

function Module:SetPullTarget()
    self.TempSettings.TargetSpawnID = mq.TLO.Target.ID()
    table.insert(self.TempSettings.PullTargets, mq.TLO.Target)
    self.TempSettings.PullTargetsMetaData[mq.TLO.Target.ID()] = { distance = mq.TLO.Navigation.PathLength("id " .. mq.TLO.Target.ID())(), }
end

function Module:OnDeath()
    -- Death Handler
    if Config:GetSetting('StopPullAfterDeath') then
        self.settings.DoPull = false
    end
end

function Module:Pop()
    self.settings[self._name .. "_Popped"] = not self.settings[self._name .. "_Popped"]
    self:SaveSettings(false)
end

function Module:OnZone()
    -- Zone Handler
    if Config:GetSetting('StopPullAfterDeath') then
        self.settings.DoPull = false
    else
        local campData = Modules:ExecModule("Movement", "GetCampData")
        self.settings.DoPull = campData.returnToCamp and campData.campSettings.CampZoneId == mq.TLO.Zone.ID()
    end
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    return PullStatesIDToName[self.TempSettings.PullState]
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = self.CommandHandlers, }
end

function Module:GetFAQ()
    return { module = self._name, FAQ = self.FAQ or {}, }
end

function Module:GetClassFAQ()
    return { module = self._name, FAQ = self.ClassFAQ or {}, }
end

function Module:SetLastPullOrCombatEndedTimer()
    self.TempSettings.LastPullOrCombatEnded = os.clock()
    Logger.log_verbose("Last Pull or Combat Ended: %s", os.clock())
end

---@param cmd string
---@param ... string
---@return boolean
function Module:HandleBind(cmd, ...)
    local params = ...
    local handled = false

    if self.CommandHandlers[cmd:lower()] ~= nil then
        self.CommandHandlers[cmd:lower()].handler(self, params)
        handled = true
    end

    return handled
end

function Module:Shutdown()
    Logger.log_debug("Pull Combat Module Unloaded.")
end

return Module
