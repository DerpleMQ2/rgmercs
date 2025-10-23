-- Clicky Module
local mq                                = require('mq')
local Config                            = require('utils.config')
local Core                              = require('utils.core')
local Casting                           = require("utils.casting")
local Strings                           = require("utils.strings")
local Ui                                = require("utils.ui")
local Comms                             = require("utils.comms")
local Logger                            = require("utils.logger")
local Targeting                         = require("utils.targeting")
local Files                             = require("utils.files")
local Set                               = require("mq.Set")
local Icons                             = require('mq.ICONS')
local animItems                         = mq.FindTextureAnimation("A_DragItem")

local Module                            = { _version = '0.1a', _name = "Clickies", _author = 'Derple', }
Module.__index                          = Module
Module.FAQ                              = {
    [1] = {
        Question = "How do I set RGmercs up to use a clicky item?",
        Answer = "  Using the GUI on the Clickies tab, you can add, remove and organize clickies you would like your PCs to use, under customizable conditions.\n\n" ..
            "  If we don't currently support the clicky by default***, you can use the GUI to add items and conditions as you see fit.\nCan't quite find the right conditions in the Clickies Logic Blocks? Feedback is highly welcome. Please bear in mind that some conditions are restricted due to technical limitations.\n\n" ..
            "  Ultimately, it is important to realize that class configs have better access to functions and conditions to fine-tune the use of a clicky, and for best results, some clickies may need to be added there instead.\n\n" ..
            "  Feedback on the default configs is welcome, but creating a custom config of your own is another possibility.\n\n" ..
            "  *** - Some clickies are already handled by default, or by a class config (like modrods). Options for these items are generally found in (Options > Items > Clickies). Additionally, some non-optional defaults may have Rotation Entries, which can be viewed on the Class tab.",
        Settings_Used = "",
    },
}
Module.SaveRequested                    = nil
Module.ClickyRotationIndex              = 1

Module.TempSettings                     = {}
Module.TempSettings.ClickyState         = {}
Module.TempSettings.CombatClickiesTimer = 0

Module.DefaultServerClickies            = {
    ['Project Lazarus'] = {
        [1] = {
            ['conditions'] = {
                [1] = {
                    target = 'Self',
                    args = {
                        [1] = 0,
                        [2] = 30,
                    },
                    type = 'HP Threshold',
                },
            },
            ['iconId'] = 2484,
            ['itemName'] = 'Draught of Opulent Healing I',
            ['target'] = 'Self',
            ['combat_state'] = 'Combat',
        },
        [2] = {
            ['conditions'] = {
                [1] = {
                    ['target'] = 'Main Assist',
                    ['args'] = {
                        [1] = 0,
                        [2] = 40,
                    },
                    ['type'] = 'HP Threshold',
                },
            },
            ['iconId'] = 1002,
            ['itemName'] = 'Orb of Shadows',
            ['target'] = 'Main Assist',
            ['combat_state'] = 'Combat',
        },
        [3] = {
            ['conditions'] = {
                [1] = {
                    ['target'] = 'Self',
                    ['args'] = {
                        [1] = 0,
                        [2] = 40,
                    },
                    ['type'] = 'HP Threshold',
                },
            },
            ['iconId'] = 936,
            ['itemName'] = 'Sanguine Mind Crystal III',
            ['target'] = 'Self',
            ['combat_state'] = 'Combat',
        },
        [4] = {
            ['conditions'] = {
                [1] = {
                    ['target'] = 'Self',
                    ['args'] = {
                        [1] = 0,
                        [2] = 40,
                        [3] = 0,
                        [4] = 40,
                        [5] = 0,
                        [6] = 40,
                    },
                    ['type'] = 'Any Threshold',
                },
            },
            ['iconId'] = 178,
            ['itemName'] = 'Forsaken Fungus Covered Scale Tunic',
            ['target'] = 'Self',
            ['combat_state'] = 'Combat',
        },
        [5] = {
            ['conditions'] = {
                [1] = {
                    ['target'] = 'Self',
                    ['args'] = {
                        [1] = 0,
                        [2] = 50,
                    },
                    ['type'] = 'HP Threshold',
                },
            },
            ['iconId'] = 1002,
            ['itemName'] = 'Orb of Shadows',
            ['target'] = 'Self',
            ['combat_state'] = 'Combat',
        },
    },

    ['EQ Might']        = {
        [1] = {
            ['target'] = 'Self',
            ['combat_state'] = 'Combat',
            ['itemName'] = 'Veeshan\'s Distillate of Celestial Healing',
            ['conditions'] = {
                [1] = {
                    ['target'] = 'Self',
                    ['type'] = 'HP Threshold',
                    ['args'] = {
                        [1] = 0,
                        [2] = 65,
                    },
                },
                [2] = {
                    ['target'] = 'Self',
                    ['type'] = 'None',
                    ['args'] = {},
                },
            },
            ['iconId'] = 656,
        },
        [2] = {
            ['target'] = 'Self',
            ['combat_state'] = 'Downtime',
            ['itemName'] = 'Ring of the Warden',
            ['conditions'] = {},
            ['iconId'] = 6136,
        },
    },
}

Module.DefaultConfig                    = {
    ['MaxClickiesPerFrame']                    = {
        DisplayName = "Max Clickies Per Frame",
        Group = "Items",
        Header = "Clickies",
        Category = "User Clickies",
        Index = 1,
        Tooltip =
        "The max number of clickies that can successfully be used per frame/processing cycle before we move on, 0 for no limit.\nThis setting may help prevent delays in other processing if a high number of clickies are used.",
        Default = 0,
        Min = 0,
        Max = 99,
        ConfigType = "Advanced",
    },
    ['Clickies']                               = {
        DisplayName = "Item %d",
        Category    = "Clickies",
        Tooltip     = "Clicky Item to use",
        Type        = "Custom",
        Default     = {},
        ConfigType  = "Normal",
    },
    [string.format("%s_Popped", Module._name)] = {
        DisplayName = Module._name .. " Popped",
        Type = "Custom",
        Default = false,
    },
}

Module.CombatTargetTypes                = { 'Self', 'Pet', 'Main Assist', 'Auto Target', }
Module.NonCombatTargetTypes             = { 'Self', 'Pet', 'Main Assist', }
Module.CombatStates                     = { 'Downtime', 'Combat', 'Any', }

-- each of these becomes a condition you can set per clickie
Module.LogicBlocks                      = {
    {
        name = "None",
        cond = function(self, target) return true end,
        tooltip = "No condition, always true.",
        render_header_text = function(self, cond)
            return string.format("No Condition")
        end,
        args = {},
    },

    {
        name = "HP Threshold",
        cond = function(self, target, aboveHP, belowHP)
            if not target or not target() then
                return false
            end

            local pctHPs = target.PctHPs() or 0

            Logger.log_super_verbose("\ayClicky: \ayClicky: \awHP Threshold condition check on \at%s\aw, aboveHP(\a-t%d\aw/%s) belowHP(\a-t%d\aw/%s) pctHPs(\a-t%d\aw)",
                target.CleanName() or "None", aboveHP, Strings.BoolToColorString((pctHPs >= aboveHP)), belowHP, Strings.BoolToColorString((pctHPs <= belowHP)),
                pctHPs)

            if not (pctHPs >= aboveHP) then
                return false
            end
            if not (pctHPs <= belowHP) then
                return false
            end

            return true
        end,
        cond_targets = Module.CombatTargetTypes,
        tooltip = "Only use if [target] HP is above/below this percent.",
        render_header_text = function(self, cond)
            return string.format("HP of %s is between %d%% and %d%%", cond.target or "Self", cond.args[1] or 0, cond.args[2] or 100)
        end,
        args = {
            { name = ">= HP %", type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= HP %", type = "number", default = 100, min = 0, max = 100, },
        },
    },

    {
        name = "Mana Threshold",
        cond = function(self, target, aboveMana, belowMana)
            if not target or not target() then
                return false
            end

            local pctMana = target.PctMana() or 0

            Logger.log_super_verbose("\ayClicky: \ayClicky: \awMana Threshold condition check on \at%s\aw, aboveMana(\a-t%d\aw/%s) belowMana(\a-t%d\aw/%s) pctMana(\a-t%d\aw)",
                target.CleanName() or "None", aboveMana, Strings.BoolToColorString((pctMana >= aboveMana)), belowMana, Strings.BoolToColorString((pctMana <= belowMana)), pctMana)

            if not (pctMana >= aboveMana) then
                return false
            end
            if not (pctMana <= belowMana) then
                return false
            end

            return true
        end,
        cond_targets = Module.NonCombatTargetTypes,
        tooltip = "Only use if [target] Mana is above/below this percent.",
        render_header_text = function(self, cond)
            return string.format("Mana of %s is between %d%% and %d%%", cond.target or "Self", cond.args[1] or 0, cond.args[2] or 100)
        end,
        args = {
            { name = ">= Mana %", type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= Mana %", type = "number", default = 100, min = 0, max = 100, },
        },
    },

    {
        name = "Endurance Threshold",
        cond = function(self, target, aboveEndurance, belowEndurance)
            if not target or not target() then
                return false
            end

            local pctEndurance = target.PctEndurance() or 0

            Logger.log_super_verbose(
                "\ayClicky: \ayClicky: \awEndurance Threshold condition check on \at%s\aw, aboveEndurance(\a-t%d\aw/%s) belowEndurance(\a-t%d\aw/%s) pctEndurance(\a-t%d\aw)",
                target.CleanName() or "None", aboveEndurance, Strings.BoolToColorString((pctEndurance >= aboveEndurance)), belowEndurance,
                Strings.BoolToColorString((pctEndurance <= belowEndurance)), pctEndurance)

            if not (pctEndurance >= aboveEndurance) then
                return false
            end
            if not (pctEndurance <= belowEndurance) then
                return false
            end

            return true
        end,
        cond_targets = Module.NonCombatTargetTypes,
        tooltip = "Only use if [target] Endurance is above/below this percent.",
        render_header_text = function(self, cond)
            return string.format("Endurance of %s is between %d%% and %d%%", cond.target or "Self", cond.args[1] or 0, cond.args[2] or 100)
        end,
        args = {
            { name = ">= Endurance %", type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= Endurance %", type = "number", default = 100, min = 0, max = 100, },
        },
    },

    {
        name = "Any Threshold",
        cond = function(self, target, aboveHP, belowHP, aboveMana, belowMana, aboveEndurance, belowEndurance)
            if not target or not target() then
                return false
            end

            local pctEndurance = target.PctEndurance() or 0
            local pctMana = target.PctMana() or 0
            local pctHPs = target.PctHPs() or 0

            if pctHPs >= aboveHP and pctHPs <= belowHP then
                return true
            end

            if pctMana >= aboveMana and pctMana <= belowMana then
                return true
            end

            if pctEndurance >= aboveEndurance and pctMana <= belowEndurance then
                return true
            end

            return false
        end,
        cond_targets = Module.NonCombatTargetTypes,
        tooltip = "Only use if [target] vitals are above/below these percents.",
        render_header_text = function(self, cond)
            return string.format("%s is between [%d%% >= HP <= %d%%] or [%d%% >= Mana <= %d%%] or [%d%% >= End <= %d%%]", cond.target or "Self",
                cond.args[1] or 0, cond.args[2] or 100,
                cond.args[3] or 0, cond.args[4] or 100,
                cond.args[5] or 0, cond.args[6] or 100)
        end,
        args = {
            { name = ">= HP %",        type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= HP %",        type = "number", default = 100, min = 0, max = 100, },
            { name = ">= Mana %",      type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= Mana %",      type = "number", default = 100, min = 0, max = 100, },
            { name = ">= Endurance %", type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= Endurance %", type = "number", default = 100, min = 0, max = 100, },
        },
    },

    {
        name = "Group Injured Count",
        cond = function(self, target, hp, cnt)
            return (mq.TLO.Group.Injured(hp)() or 0) >= cnt
        end,
        cond_targets = { 'Self', },
        tooltip = "Only use if [Count] group members are below [X] HP%.",
        render_header_text = function(self, cond)
            return string.format("%d group members are <= %d%% HP", cond.args[1] or 0, cond.args[2] or 100)
        end,
        args = {
            { name = "Grp Count", type = "number", default = 0,   min = 0, max = 6, },
            { name = "<= HP %",   type = "number", default = 100, min = 0, max = 100, },
        },
    },

    {
        name = "Target Aggro Percent",
        cond = function(self, target, aboveAggro, belowAggro)
            if not target or not target() then
                return false
            end

            if target.ID() ~= mq.TLO.Target.ID() then return false end

            local pctAggro = mq.TLO.Target.PctAggro() or 0

            Logger.log_super_verbose("\ayClicky: \ayClicky: \awTarget Aggro condition check on \at%s\aw, aboveAggro(\a-t%d\aw/%s) belowAggro(\a-t%d\aw/%s) pctAggro(\a-t%d\aw)",
                target.CleanName() or "None", aboveAggro, Strings.BoolToColorString((pctAggro >= aboveAggro)), belowAggro,
                Strings.BoolToColorString((pctAggro <= belowAggro)), pctAggro)

            if not (pctAggro >= aboveAggro) then
                return false
            end
            if not (pctAggro <= belowAggro) then
                return false
            end

            return true
        end,
        cond_targets = { "Auto Target", },
        tooltip = "Only use if your aggro on the auto target is above/below this percent.",
        render_header_text = function(self, cond)
            return string.format("Auto Target aggro is between %d%% and %d%%", cond.args[1] or 0, cond.args[2] or 100)
        end,
        args = {
            { name = ">= Aggro %", type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= Aggro %", type = "number", default = 100, min = 0, max = 100, },
        },
    },

    {
        name = "Target Secondary Aggro Percent",
        cond = function(self, target, aboveAggro, belowAggro)
            if not target or not target() then
                return false
            end

            if target.ID() ~= mq.TLO.Target.ID() then return false end

            local pctAggro = mq.TLO.Target.SecondaryPctAggro() or 0

            Logger.log_super_verbose(
                "\ayClicky: \ayClicky: \awSecondary Aggro Threshold condition check on \at%s\aw, aboveAggro(\a-t%d\aw/%s) belowAggro(\a-t%d\aw/%s) pctAggro(\a-t%d\aw)",
                target.CleanName() or "None", aboveAggro, Strings.BoolToColorString((pctAggro >= aboveAggro)), belowAggro,
                Strings.BoolToColorString((pctAggro <= belowAggro)), pctAggro)

            if not (pctAggro >= aboveAggro) then
                return false
            end
            if not (pctAggro <= belowAggro) then
                return false
            end

            return true
        end,
        cond_targets = { "Auto Target", },
        tooltip = "Only use if the secondary aggro on the auto target is above/below this percent.",
        render_header_text = function(self, cond)
            return string.format("Auto Target secondary aggro is between %d%% and %d%%", cond.args[1] or 0, cond.args[2] or 100)
        end,
        args = {
            { name = ">= Aggro %", type = "number", default = 0,   min = 0, max = 100, },
            { name = "<= Aggro %", type = "number", default = 100, min = 0, max = 100, },
        },
    },

    {
        name = "XT Hater Count",
        cond = function(self, target, aboveCount, belowCount)
            local haterCount = Targeting.GetXTHaterCount()

            Logger.log_super_verbose(
                "\ayClicky: \ayClicky: \awXT Hater Count condition check, aboveCount(\a-t%d\aw/%s) belowCount(\a-t%d\aw/%s) pctAggro(\a-t%d\aw)", aboveCount,
                Strings.BoolToColorString((haterCount >= aboveCount)), belowCount, Strings.BoolToColorString((haterCount <= belowCount)), haterCount)

            if not (haterCount >= aboveCount) then
                return false
            end
            if not (haterCount <= belowCount) then
                return false
            end

            return true
        end,
        tooltip = "Only use if haters on your XTarget are above/below this count.",
        render_header_text = function(self, cond)
            return string.format("XT Hater Count is between %d and %d", cond.args[1] or 0, cond.args[2] or 50)
        end,
        args = {
            { name = ">= Count", type = "number", default = 0,  min = 0, max = 50, },
            { name = "<= Count", type = "number", default = 50, min = 0, max = 50, },
        },
    },

    {
        name = "During Burns",
        cond = function(self, target, negate)
            local burning = Casting.BurnCheck()
            if negate then
                return not burning
            else
                return burning
            end
        end,
        tooltip = "Only use when burns are (not) active. (Optional Negate)",
        render_header_text = function(self, cond)
            return string.format("Burning is %sactivated", cond.args[1] and "not " or "")
        end,
        args = {
            { name = "Negate", type = "boolean", default = false, },
        },
    },

    {
        name = "Target Is Named",
        cond = function(self, target, negate)
            local isNamed = Targeting.IsNamed(Targeting.GetAutoTarget())
            if negate then
                return not isNamed
            else
                return isNamed
            end
        end,
        tooltip = "Only use when RGMercs or SpawnMaster has (not) identified a mob as Named. (Optional Negate)",
        render_header_text = function(self, cond)
            return string.format("Auto Target is %s", cond.args[1] and "not Named" or "Named")
        end,
        args = {
            { name = "Negate", type = "boolean", default = false, },
        },
    },

    {
        name = "I Have Effect",
        cond = function(self, target, effect, negate)
            local hasEffect = Casting.IHaveBuff(effect)
            if negate then
                return not hasEffect
            else
                return hasEffect
            end
        end,
        tooltip = "Only use when you (do not) have this buff or song effect on you. (Optional Negate)",
        render_header_text = function(self, cond)
            return string.format("You %s Effect '%s'", cond.args[2] and "don't have" or "have", cond.args[1] or "None")
        end,
        cond_targets = { "Self", },
        args = {
            { name = "Effect", type = "string",  default = "", },
            { name = "Negate", type = "boolean", default = false, },
        },
    },

    {
        name = "My Pet Has Effect",
        cond = function(self, target, effect, negate)
            local hasEffect = not Casting.PetBuffCheck(mq.TLO.Spell(effect)) -- this will return false if the pet has it
            if negate then
                return not hasEffect
            else
                return hasEffect
            end
        end,
        tooltip = "Only use when this effect is (not) present on your pet. (Optional Negate)",
        render_header_text = function(self, cond)
            return string.format("Your Pet %s Effect '%s'", cond.args[2] and "doesn't have" or "has", cond.args[1] or "None")
        end,
        cond_targets = { "Pet", },
        args = {
            { name = "Effect", type = "string",  default = "", },
            { name = "Negate", type = "boolean", default = false, },
        },
    },

    {
        name = "Auto Target Has Effect",
        cond = function(self, target, effect, negate)
            local hasEffect = Casting.TargetHasBuff(effect, target)
            if negate then
                return not hasEffect
            else
                return hasEffect
            end
        end,
        tooltip = "Only use when this effect is (not) present on the RGMercs AutoTarget. (Optional Negate)",
        render_header_text = function(self, cond)
            return string.format("RGMercs Auto Target %s Effect: '%s'", cond.args[2] and "doen't have" or "has", cond.args[1] or "None")
        end,
        cond_targets = { "Auto Target", },
        args = {
            { name = "Effect", type = "string",  default = "", },
            { name = "Negate", type = "boolean", default = false, },
        },
    },

    {
        name = "Item Count",
        cond = function(self, target, item, belowCount, aboveCount)
            local itemCount = mq.TLO.FindItemCount(string.format("=%s", item))()
            return itemCount <= aboveCount and itemCount >= belowCount
        end,
        tooltip = "Only use we have a certain quantity range of an item.",
        render_header_text = function(self, cond)
            return string.format("We have between %d and %d of %s", cond.args[2], cond.args[3], cond.args[1])
        end,
        args = {
            { name = "Item",     type = "string", default = "", },
            { name = ">= Count", type = "number", default = 0,    min = 0, max = 1000, },
            { name = "<= Count", type = "number", default = 1000, min = 0, max = 1000, },
        },
    },

    {
        name = "Config Setting",
        cond = function(self, target, setting, value)
            Logger.log_super_verbose("\ayClicky: \a-yChecking if GetSetting(%s) == %s", setting, tostring(value))

            return Config:HaveSetting(setting) and (Config:GetSetting(setting) == value) or false
        end,
        tooltip = "Only use if the specifed setting returns the specified value.",
        render_header_text = function(self, cond)
            return Config:HaveSetting(cond.args[1]) and string.format("The '%s' setting is %s", cond.args[1], tostring(cond.args[2])) or
                "Please set a valid setting name..."
        end,
        args = {
            {
                name = "Setting",
                type = "string",
                default = "",
                on_changed =
                    function(self, newValue, cond)
                        if Config:HaveSetting(newValue) then
                            local settingInfo = Config:GetSettingDefaults(newValue)
                            if settingInfo then
                                self:GetLogicBlockArgByTypeAndIndex(cond.type, 2).min = settingInfo.Min
                                self:GetLogicBlockArgByTypeAndIndex(cond.type, 2).max = settingInfo.Max
                                self:GetLogicBlockArgByTypeAndIndex(cond.type, 2).default = settingInfo.Default
                                cond.args[2] = settingInfo.Default
                            end
                        end
                    end,
            },
            { name = "Value", type = "setting_value", default = "", },
        },
    },

    {
        name = "Server Type",
        cond = function(self, target, onLive, onEmu, onLaz)
            Logger.log_super_verbose("\ayClicky: \a-yChecking Server Type is onLive(%s) onEmu(%s), onLaz(%s)", Strings.BoolToColorString(onLive),
                Strings.BoolToColorString(onEmu), Strings.BoolToColorString(onLaz))

            return (onLive and not Core.OnEMU()) or (onEmu and Core.OnEMU()) or (onLaz and Core.OnLaz())
        end,
        tooltip = "Only use if you are on one of these server types.",
        render_header_text = function(self, cond)
            local serverTypes = ""
            for k, v in pairs(cond.args) do
                if v == true then
                    serverTypes = serverTypes .. (serverTypes == "" and "" or " or ") .. self:GetLogicBlockArgByTypeAndIndex('Server Type', k).name
                end
            end

            return string.format("Server type is %s", serverTypes == "" and "None" or serverTypes)
        end,
        args = {
            { name = "Live",            type = "boolean", default = true, },
            { name = "Emu",             type = "boolean", default = true, },
            { name = "Project Lazarus", type = "boolean", default = true, },
        },
    },

    {
        name = "In Zone",
        cond = function(self, target, zoneName, bNotInZone)
            Logger.log_super_verbose("\ayClicky: \a-yChecking if we are in Zone(s): \at%s\aw CurZone: \at%s\aw/\at%s", zoneName, mq.TLO.Zone.Name() or "None",
                mq.TLO.Zone.ShortName() or "None")
            local zoneChecks = Strings.split(zoneName or "", ",")
            for i, v in ipairs(zoneChecks) do
                v = v:gsub("^%s*(.-)%s*$", "%1") -- trim spaces
                if v == (mq.TLO.Zone.Name() or "") or v == (mq.TLO.Zone.ShortName() or "") then
                    return not bNotInZone
                end
            end

            return bNotInZone
        end,
        tooltip = "Only use if you are (not) in the following zones. (Full or short name accepted, comma separated).",

        render_header_text = function(self, cond)
            local zoneList = ""
            local zoneChecks = Strings.split(cond.args[1] or "", ",")
            for _, v in pairs(zoneChecks) do
                zoneList = zoneList .. (zoneList == "" and "" or " or ") .. v
            end
            return string.format("%sIn Zone(s) %s", cond.args[2] and "Not " or "", zoneList == "" and "None" or zoneList)
        end,
        args = {
            { name = "Zone Name",   type = "string",  default = "ggh", },
            { name = "Not In Zone", type = "boolean", default = false, },
        },
    },
}

Module.LogicBlockTypeIDs                = {}

for id, block in ipairs(Module.LogicBlocks) do
    Module.LogicBlockTypeIDs[block.name] = id
    if block.cond_targets then
        for k, v in pairs(block.cond_targets) do
            block.cond_targetIDs = block.cond_targetIDs or {}
            block.cond_targetIDs[v] = k
        end
    end
end

Module.CombatTargetTypeIDs = {}
for k, v in pairs(Module.CombatTargetTypes) do
    Module.CombatTargetTypeIDs[v] = k
end
Module.NonCombatTargetTypeIDs = {}
for k, v in pairs(Module.NonCombatTargetTypes) do
    Module.NonCombatTargetTypeIDs[v] = k
end
Module.CombatStateIDs = {}
for k, v in pairs(Module.CombatStates) do
    Module.CombatStateIDs[v] = k
end

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
    self.SaveRequested = { time = os.time(), broadcast = doBroadcast or false, }
end

function Module:WriteSettings()
    if not self.SaveRequested then return end

    mq.pickle(getConfigFileName(), Config:GetModuleSettings(self._name))

    if self.SaveRequested.doBroadcast == true then
        Comms.BroadcastMessage(self._name, "LoadSettings")
    end

    Logger.log_debug("\ag%s Module settings saved to %s, requested %s ago.", self._name, getConfigFileName(), Strings.FormatTime(os.time() - self.SaveRequested.time))

    self.SaveRequested = nil
end

function Module:LoadSettings()
    Logger.log_debug("Clickies Module Loading Settings for: %s.", Config.Globals.CurLoadedChar)
    local settings_pickle_path = getConfigFileName()
    local settings = {}
    local firstSaveRequired = false

    local config, err = loadfile(settings_pickle_path)
    if err or not config then
        Logger.log_error("\ay[Drag]: Unable to load clicky settings file(%s), creating a new one!",
            settings_pickle_path)
        firstSaveRequired = true
    else
        settings = config()
    end

    local settingsChanged = false

    -- insert default server clickies on very first run per PC
    if not settings.Clickies then
        -- Live/Test use "Live". Emu servers use server-specific.
        local serverType = Config.Globals.BuildType:lower() ~= "emu" and "Live" or mq.TLO.EverQuest.Server()
        local defaultClickyList = self.DefaultServerClickies[serverType]
        settings.Clickies = defaultClickyList or {}
        settingsChanged = true
    end

    for _, clicky in ipairs(settings.DowntimeClickies or {}) do
        if type(clicky) == 'string' then
            -- convert old clickies
            table.insert(settings.Clickies,
                {
                    itemName = clicky,
                    target = 'Self',
                    combat_state = 'Downtime',
                    conditions = {},
                })
            settingsChanged = true
        end
    end

    for _, clicky in ipairs(settings.CombatClickies or {}) do
        if type(clicky) == 'string' then
            -- convert old clickies
            table.insert(settings.Clickies,
                {
                    itemName = clicky,
                    target = 'Self',
                    combat_state = 'Combat',
                    conditions = {},
                })
            settingsChanged = true
        end
    end

    settings.CombatClickies = nil
    settings.DowntimeClickies = nil

    if settingsChanged then
        self:SaveSettings(false)
    end

    Config:RegisterModuleSettings(self._name, settings, self.DefaultConfig, self.FAQ, firstSaveRequired)

    Logger.log_debug("\awClicky Module: \atLoaded \ag%d\at Clickies", #settings.Clickies or 0)
end

function Module.New()
    local newModule = setmetatable({}, Module)
    return newModule
end

function Module:Init()
    Logger.log_debug("Clicky Module Loaded.")
    self:LoadSettings()

    self.ModuleLoaded = true

    return { self = self, defaults = self.DefaultConfig, }
end

function Module:ShouldRender()
    return true
end

function Module:RenderClickyControls(clickies, clickyIdx, headerCursorPos, headerScreenPos, preRender)
    local startingPosVec = ImGui.GetCursorPosVec()
    local offset_trash = 40
    local offset_enable = 160

    self:RenderClickyHeaderIcon(clickies[clickyIdx], headerScreenPos)

    ImGui.SetCursorPos(ImGui.GetWindowWidth() - offset_enable, headerCursorPos.y)

    ImGui.PushID("##_small_btn_ctrl_clicky_" .. tostring(clickyIdx) .. (preRender and "_pre" or ""))

    if clickies[clickyIdx] then
        local changed = false
        local enabled = clickies[clickyIdx].enabled == nil or clickies[clickyIdx].enabled

        enabled, changed = Ui.RenderOptionToggle("##EnableDrawn" .. tostring(clickyIdx), "", enabled, true)
        if changed then
            clickies[clickyIdx].enabled = enabled
            self:SaveSettings(false)
        end
    end

    if clickyIdx > 1 then
        ImGui.SameLine()
        ImGui.PushID("##_small_btn_up_clicky_" .. tostring(clickyIdx) .. (preRender and "_pre" or ""))
        if ImGui.SmallButton(Icons.FA_CHEVRON_UP) then
            clickies[clickyIdx], clickies[clickyIdx - 1] = clickies[clickyIdx - 1], clickies[clickyIdx]
            self:SaveSettings(false)
        end
        ImGui.PopID()
    else
        ImGui.SameLine()
        ImGui.InvisibleButton(Icons.FA_CHEVRON_UP, ImVec2(22, 1))
    end

    if clickyIdx < #clickies then
        ImGui.SameLine()
        ImGui.PushID("##_small_btn_dn_clicky_" .. tostring(clickyIdx) .. (preRender and "_pre" or ""))
        if ImGui.SmallButton(Icons.FA_CHEVRON_DOWN) then
            clickies[clickyIdx], clickies[clickyIdx + 1] = clickies[clickyIdx + 1], clickies[clickyIdx]
            self:SaveSettings(false)
        end
        ImGui.PopID()
    else
        ImGui.SameLine()
        ImGui.InvisibleButton(Icons.FA_CHEVRON_DOWN, ImVec2(22, 1))
    end

    ImGui.SetCursorPos(ImGui.GetWindowWidth() - offset_trash, headerCursorPos.y + 3)

    if ImGui.SmallButton(Icons.FA_TRASH) then
        -- if we do this in the UI thread then there could be a race condition if the user is clicking fast
        clickies[clickyIdx].Delete = true
    end
    ImGui.PopID()

    ImGui.SetCursorPos(startingPosVec)
end

function Module:RenderConditionControls(clickyIdx, idx, conditionsTable, headerPos)
    local startingPosVec = ImGui.GetCursorPosVec()
    local offset = 110
    ImGui.SetCursorPos(ImGui.GetWindowWidth() - offset, headerPos.y)

    ImGui.PushID("##_small_btn_up_wp_" .. tostring(clickyIdx) .. "_" .. tostring(idx))
    if idx == 1 then
        ImGui.InvisibleButton(Icons.FA_CHEVRON_UP, ImVec2(22, 1))
    else
        if ImGui.SmallButton(Icons.FA_CHEVRON_UP) then
            conditionsTable[idx], conditionsTable[idx - 1] = conditionsTable[idx - 1], conditionsTable[idx]
            self:SaveSettings(false)
        end
    end
    ImGui.PopID()
    ImGui.SameLine()
    ImGui.PushID("##_small_btn_dn_cond_" .. tostring(clickyIdx) .. "_" .. tostring(idx))
    if idx == #conditionsTable then
        ImGui.InvisibleButton(Icons.FA_CHEVRON_DOWN, ImVec2(22, 1))
    else
        if ImGui.SmallButton(Icons.FA_CHEVRON_DOWN) then
            conditionsTable[idx], conditionsTable[idx + 1] = conditionsTable[idx + 1], conditionsTable[idx]
            self:SaveSettings(false)
        end
    end
    ImGui.PopID()
    ImGui.SameLine()
    ImGui.PushID("##_small_btn_delete_cond_" .. tostring(clickyIdx) .. "_" .. tostring(idx))
    if ImGui.SmallButton(Icons.FA_TRASH) then
        conditionsTable[idx].Delete = true
    end
    ImGui.PopID()


    ImGui.SetCursorPos(startingPosVec)
end

function Module:RenderConditionTypesCombo(cond, condIdx)
    if ImGui.BeginTable("##clicky_cond_type_table_" .. condIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 50)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)
        ImGui.TableNextColumn()
        ImGui.Text("Type")
        ImGui.TableNextColumn()
        local selectedNum, changed = ImGui.Combo("##clicky_cond_type_" .. "_" .. condIdx, self.LogicBlockTypeIDs[cond.type or "None"] or 1,
            function(idx)
                return self.LogicBlocks[idx].name or "None"
            end,
            #self.LogicBlocks)

        if changed then
            cond.type = self.LogicBlocks[selectedNum].name or "None"
            cond.args = {}
            for argIdx, arg in ipairs(self:GetLogicBlockArgsByType(cond.type) or {}) do
                cond.args[argIdx] = arg.default
            end
            self:SaveSettings(false)
        end
        ImGui.EndTable()
    end
end

function Module:RenderConditionTargetCombo(cond, condIdx)
    local condBlock = self:GetLogicBlockByType(cond.type)
    if not condBlock or not condBlock.cond_targets then
        return
    end
    if ImGui.BeginTable("##clicky_cond_target_table_" .. condIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 50)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)
        ImGui.TableNextColumn()
        ImGui.Text("Target")
        ImGui.TableNextColumn()
        local selectedNum, changed = ImGui.Combo("##clicky_cond_target_" .. "_" .. condIdx, tonumber(condBlock.cond_targetIDs[cond.target or "Self"]) or 1, condBlock.cond_targets,
            #condBlock.cond_targets)
        if changed then
            cond.target = condBlock.cond_targets[selectedNum] or "Self"
            self:SaveSettings(false)
        end
        ImGui.EndTable()
    end
end

function Module:RenderClickyTargetCombo(clicky, clickyIdx)
    if ImGui.BeginTable("##clicky_target_table_" .. clickyIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 100)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)
        ImGui.TableNextColumn()
        ImGui.Text("Target")
        ImGui.TableNextColumn()
        local targetTypeIDs = self.CombatTargetTypeIDs
        local targetTypes = self.CombatTargetTypes

        if clicky.combat_state == "Downtime" then
            targetTypeIDs = self.NonCombatTargetTypeIDs
            targetTypes = self.NonCombatTargetTypes
        end

        local selectedNum, changed = ImGui.Combo("##clicky_cond_target_" .. "_" .. clickyIdx, tonumber(targetTypeIDs[clicky.target or "Self"]) or 1,
            targetTypes,
            #targetTypes)
        if changed then
            clicky.target = targetTypes[selectedNum] or "Self"
            self:SaveSettings(false)
        end
        ImGui.EndTable()
    end
end

function Module:RenderClickyCombatStateCombo(clicky, clickyIdx)
    if ImGui.BeginTable("##clicky_combat_state_table_" .. clickyIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 100)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)
        ImGui.TableNextColumn()
        ImGui.Text("Combat State")
        ImGui.TableNextColumn()
        local selectedNum, changed = ImGui.Combo("##clicky_cond_combat_state_" .. "_" .. clickyIdx, tonumber(self.CombatStateIDs[clicky.combat_state or "Any"]) or 1,
            self.CombatStates,
            #self.CombatStates)
        if changed then
            clicky.combat_state = self.CombatStates[selectedNum] or "Any"
            self:SaveSettings(false)
        end
        ImGui.EndTable()
    end
end

function Module:RenderClickyOption(type, cond, condIdx, argIdx, clickyIdx)
    local changed = false

    if type == "number" then
        cond.args[argIdx], changed = Ui.RenderOptionNumber("##clicky_arg_" .. clickyIdx .. "_" .. condIdx .. "_" .. argIdx,
            "", cond.args[argIdx], self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).min, self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).max)
    elseif type == "boolean" then
        cond.args[argIdx], changed = Ui.RenderOptionToggle("##clicky_arg_" .. clickyIdx .. "_" .. condIdx .. "_" .. argIdx,
            "",
            cond.args[argIdx])
    elseif type == "string" then
        cond.args[argIdx], changed = ImGui.InputText("##clicky_arg_" .. clickyIdx .. "_" .. condIdx .. "_" .. argIdx,
            cond.args[argIdx])
    else
        ImGui.TextDisabled("Invalid Option Type: %s", type)
    end

    if changed then
        if self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).on_changed then
            Core.SafeCallFunc("On Changed Callback", self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).on_changed, self, cond.args[argIdx], cond)
        end

        self:SaveSettings(false)
    end
end

function Module:RenderConditionArgs(cond, condIdx, clickyIdx)
    if ImGui.BeginTable("##clicky_cond_args_table_" .. condIdx, 2, bit32.bor(ImGuiTableFlags.None)) then
        ImGui.TableSetupColumn("Key", ImGuiTableColumnFlags.WidthFixed, 80)
        ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthStretch, 0)

        for argIdx = 1, #cond.args do
            ImGui.TableNextColumn()
            ImGui.Text(self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).name or ("Arg " .. tostring(argIdx)))
            ImGui.TableNextColumn()

            if self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).type == "setting_value" then
                local changed = false

                -- the arg before this must be a valid setting for this to work.
                if argIdx == 1 or not Config:HaveSetting(cond.args[argIdx - 1]) then
                    ImGui.TextDisabled("Please select a valid setting in the previous argument.")
                else
                    local settingName = cond.args[argIdx - 1] or ""
                    local settingInfo = Config:GetSettingDefaults(settingName)

                    self:RenderClickyOption(type(settingInfo.Default), cond, condIdx, argIdx, clickyIdx)

                    if changed then
                        self:SaveSettings(false)
                    end
                end
            else
                self:RenderClickyOption(self:GetLogicBlockArgByTypeAndIndex(cond.type, argIdx).type, cond, condIdx, argIdx, clickyIdx)
            end
        end
        ImGui.EndTable()
    end
end

function Module:GetLogicBlockByType(type)
    return self.LogicBlocks[self.LogicBlockTypeIDs[type]]
end

function Module:GetLogicBlockTargetsByType(type)
    return self:GetLogicBlockByType(type).cond_targets or {}
end

function Module:GetLogicBlockArgsByType(type)
    return self:GetLogicBlockByType(type).args or {}
end

--- comment
--- @param type string
--- @param idx number
--- @return any
function Module:GetLogicBlockArgByTypeAndIndex(type, idx)
    return self:GetLogicBlockByType(type).args[idx] or "None"
end

function Module:GetLogicBlockArgCountByType(type)
    return #self:GetLogicBlockByType(type).args or 0
end

function Module:RenderClickyHeaderIcon(clicky, headerPos)
    local offset = 30

    if not clicky then return end

    if clicky.iconId == nil then
        local item = mq.TLO.FindItem(clicky.itemName)
        clicky.iconId = item() and tonumber((item.Icon() or 500) - 500) or 0
    end

    local draw_list = ImGui.GetWindowDrawList()
    animItems:SetTextureCell(tonumber(clicky.iconId) or 0)
    draw_list:AddTextureAnimation(animItems, ImVec2(headerPos.x + offset, headerPos.y), ImVec2(20, 20))
end

function Module:RenderClickiesWithConditions(type, clickies)
    if not mq.TLO.Cursor() then
        ImGui.BeginDisabled(true)
    end
    if ImGui.SmallButton(mq.TLO.Cursor.Name() and string.format("%s Add %s to %s", Icons.FA_PLUS, mq.TLO.Cursor.Name() or "N/A", type) or "Pickup an Item To Add") then
        if mq.TLO.Cursor() then
            table.insert(clickies, {
                itemName = mq.TLO.Cursor.Name(),
                target = 'Self',
                combat_state = 'Any',
                conditions = {},
            })
            self:SaveSettings(false)
        end
    end
    if not mq.TLO.Cursor() then
        ImGui.EndDisabled()
    end
    ImGui.SameLine()
    if ImGui.SmallButton("Add Server Defaults") then
        self:InsertDefaultClickies()
    end
    Ui.Tooltip("Add server-specific default clickies to the end of the list.")
    if #clickies > 0 then
        for clickyIdx, clicky in ipairs(clickies) do
            if clicky.itemName:len() > 0 then
                local headerScreenPos = ImGui.GetCursorScreenPosVec()
                local headerCursorPos = ImGui.GetCursorPosVec()
                self:RenderClickyControls(clickies, clickyIdx, headerCursorPos, headerScreenPos, true)

                ImGui.PushID("##clicky_header_" .. clickyIdx)
                if ImGui.CollapsingHeader("             " .. clicky.itemName) then
                    if clicky.enabled == false then
                        ImGui.BeginDisabled(true)
                    end
                    ImGui.Indent()
                    self:RenderClickyCombatStateCombo(clicky, clickyIdx)
                    self:RenderClickyTargetCombo(clicky, clickyIdx)
                    ImGui.SeparatorText("Usage Info")
                    self:RenderClickyData(clicky, clickyIdx)
                    ImGui.SeparatorText("Conditions");
                    ImGui.PushID("##clicky_conditions_btn_" .. clickyIdx)
                    if ImGui.SmallButton(Icons.FA_PLUS .. " Add Condition") then
                        table.insert(clicky.conditions, { type = 'None', args = {}, target = 'Self', })
                        self:SaveSettings(false)
                    end
                    ImGui.PopID()
                    ImGui.PushStyleVar(ImGuiStyleVar.ChildRounding, 5.0)

                    ImGui.BeginChild("##clicky_conditions_child_" .. clickyIdx, ImVec2(0, 0),
                        bit32.bor(ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.Border, ImGuiChildFlags.AutoResizeY),
                        bit32.bor(ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoTitleBar))

                    for condIdx, cond in ipairs(clicky.conditions or {}) do
                        if self:GetLogicBlockByType(cond.type) then
                            local headerPos = ImGui.GetCursorPosVec()
                            if ImGui.TreeNode(self:GetLogicBlockByType(cond.type).render_header_text(self, cond) .. "###clicky_cond_tree_" .. clickyIdx .. "_" .. condIdx) then
                                Ui.Tooltip(self:GetLogicBlockByType(cond.type).tooltip or "No Tooltip Available.")

                                self:RenderConditionTypesCombo(cond, condIdx)
                                ImGui.Indent()
                                ImGui.PushStyleVar(ImGuiStyleVar.ChildRounding, 5.0)
                                ImGui.BeginChild("##clicky_cond_child_" .. clickyIdx .. "_" .. condIdx, ImVec2(0, 0),
                                    bit32.bor(ImGuiChildFlags.AlwaysAutoResize, ImGuiChildFlags.Border, ImGuiChildFlags.AutoResizeY),
                                    bit32.bor(ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoTitleBar))
                                self:RenderConditionTargetCombo(cond, condIdx)
                                self:RenderConditionArgs(cond, condIdx, clickyIdx)
                                ImGui.EndChild()
                                ImGui.PopStyleVar(1)
                                ImGui.Unindent()
                                ImGui.TreePop()
                            else
                                Ui.Tooltip(self:GetLogicBlockByType(cond.type).tooltip or "No Tooltip Available.")
                            end

                            self:RenderConditionControls(clickyIdx, condIdx, clicky.conditions, headerPos)
                        end
                    end

                    if clicky.enabled == false then
                        ImGui.EndDisabled()
                    end

                    ImGui.EndChild()
                    ImGui.PopStyleVar(1)

                    ImGui.Unindent()
                end

                self:RenderClickyControls(clickies, clickyIdx, headerCursorPos, headerScreenPos, false)

                ImGui.PopID()
            end
        end
    end

    --    ImGui.Unindent()
    ImGui.Separator()
    -- end
end

function Module:RenderClickyData(clicky, clickyIdx)
    if ImGui.BeginTable("##clickies_table_" .. clicky.itemName .. tostring(clickyIdx), 3, bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders)) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Last Used', (ImGuiTableColumnFlags.WidthFixed), 100.0)
        ImGui.TableSetupColumn('Item', (ImGuiTableColumnFlags.WidthFixed), 150.0)
        ImGui.TableSetupColumn('Effect', (ImGuiTableColumnFlags.WidthStretch), 200.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        if clicky.itemName:len() > 0 then
            local lastUsed = self.TempSettings.ClickyState[clicky.itemName] and (self.TempSettings.ClickyState[clicky.itemName].lastUsed or 0) or 0
            local item = self.TempSettings.ClickyState[clicky.itemName] and
                (self.TempSettings.ClickyState[clicky.itemName].item and self.TempSettings.ClickyState[clicky.itemName].item.Clicky.Spell.RankName.Name() or "None")
                or "None"
            ImGui.TableNextColumn()
            ImGui.Text(lastUsed > 0 and Strings.FormatTime((os.clock() - lastUsed)) or "Never")
            ImGui.TableNextColumn()
            ImGui.Text(clicky.itemName)
            ImGui.TableNextColumn()
            ImGui.Text(item)
        end

        ImGui.EndTable()
    end
    ImGui.Separator()
end

function Module:Render()
    Ui.RenderPopAndSettings(self._name)

    self:RenderClickiesWithConditions("Clickies", Config:GetSetting('Clickies'))
end

function Module:Pop()
    Config:SetSetting(self._name .. "_Popped", not Config:GetSetting(self._name .. "_Popped"))
end

function Module:ValidateClickies()
    local clickies = Config:GetSetting('Clickies') or {}
    local clickiesChanged = false
    for idx = #clickies, 1, -1 do
        local clicky = clickies[idx]

        for idx = #clicky.conditions, 1, -1 do
            local condition = clicky.conditions[idx]
            if condition.Delete then
                table.remove(clicky.conditions, idx)
                clickiesChanged = true
            end
        end

        if clicky.itemName:len() == 0 or clicky.Delete then
            table.remove(clickies, idx)
            clickiesChanged = true
        end
    end

    if clickiesChanged then
        self:SaveSettings(false)
    end
end

function Module:InsertDefaultClickies()
    -- Live/Test use "Live". Emu servers use server-specific.
    local serverType = Config.Globals.BuildType:lower() ~= "emu" and "Live" or mq.TLO.EverQuest.Server()
    local defaultClickyList = self.DefaultServerClickies[serverType]
    if defaultClickyList then
        for _, defaultClicky in ipairs(defaultClickyList) do
            table.insert(Config:GetSetting('Clickies'), defaultClicky)
        end
        self:SaveSettings(false)
    end
end

function Module:GiveTime(combat_state)
    -- Main Module logic goes here.
    self:ValidateClickies()

    local maxClickiesPerFrame = Config:GetSetting('MaxClickiesPerFrame') or 0
    local clickiesUsedThisFrame = 0
    local startingClickyIdx = maxClickiesPerFrame > 0 and self.ClickyRotationIndex or 1
    local clickies = Config:GetSetting('Clickies') or {}
    local numClickies = #clickies
    for clickyIdx = startingClickyIdx, numClickies do
        local clicky = clickies[clickyIdx]
        if clicky.itemName:len() > 0 and (clicky.enabled == nil or clicky.enabled == true) then
            self.ClickyRotationIndex = (clickyIdx % numClickies) + 1
            Logger.log_super_verbose("\ayClicky: \awChecking clicky entry: \ay%s\aw[\at%d\aw]", clicky.itemName, clickyIdx)

            if clicky.combat_state == "Any" or clicky.combat_state == combat_state then
                local target = mq.TLO.Me
                local allConditionsMet = true
                for _, cond in ipairs(clicky.conditions or {}) do
                    local condBlock = self:GetLogicBlockByType(cond.type)
                    if condBlock then
                        if condBlock.cond_targets then
                            if cond.target == "Main Assist" then
                                ---@diagnostic disable-next-line: cast-local-type
                                target = Core.GetMainAssistSpawn()
                            elseif cond.target == "Pet" then
                                ---@diagnostic disable-next-line: cast-local-type
                                target = mq.TLO.Me.Pet
                            elseif cond.target == "Auto Target" then
                                ---@diagnostic disable-next-line: cast-local-type
                                target = Targeting.GetAutoTarget()
                            end
                        end
                        Logger.log_super_verbose("\ayClicky: \awTesting Condition: \at%s\aw on target: \at%s", cond.type, target and (target.CleanName() or "None") or "None")

                        if not Core.SafeCallFunc("Test clicky Condition", self:GetLogicBlockByType(cond.type).cond, self, target, unpack(cond.args or {})) then
                            Logger.log_super_verbose("\ayClicky: \aw\t|->\aw \arFailed!")
                            allConditionsMet = false
                            break
                        else
                            Logger.log_super_verbose("\ayClicky: \aw\t|->\aw \agSuccess!")
                        end
                    end
                end

                if allConditionsMet then
                    self.TempSettings.ClickyState[clicky.itemName] = self.TempSettings.ClickyState[clicky.itemName] or {}

                    local item = mq.TLO.FindItem(clicky.itemName)
                    Logger.log_verbose("\ayClicky: \awLooking for clicky item: \am%s \awfound: %s", clicky.itemName, Strings.BoolToColorString(item() ~= nil))

                    if item then
                        target = mq.TLO.Me
                        local buffCheckPassed = true
                        if clicky.target == "Self" then
                            target = mq.TLO.Me
                            buffCheckPassed = Casting.SelfBuffItemCheck(clicky.itemName)
                        elseif clicky.target == "Pet" then
                            ---@diagnostic disable-next-line: cast-local-type
                            target = mq.TLO.Me.Pet
                            buffCheckPassed = mq.TLO.Me.Pet.ID() > 0 and Casting.PetBuffItemCheck(clicky.itemName)
                        elseif clicky.target == "Main Assist" then
                            ---@diagnostic disable-next-line: cast-local-type
                            target = Core.GetMainAssistSpawn()
                            buffCheckPassed = Casting.PeerBuffCheck(item.Clicky.Spell.ID(), target, false)
                        elseif clicky.target == "Auto Target" then
                            ---@diagnostic disable-next-line: cast-local-type
                            target = Targeting.GetAutoTarget()
                            buffCheckPassed = Casting.DetItemCheck(clicky.itemName)
                        end

                        self.TempSettings.ClickyState[clicky.itemName].item = item
                        if buffCheckPassed and Casting.ItemReady(item()) then
                            Logger.log_verbose("\ayClicky: \awItem \am%s\aw Clicky Spell: \at%s\ag!", item.Name(), item.Clicky.Spell.RankName.Name())
                            Casting.UseItem(item.Name(), target.ID(), true)
                            clickiesUsedThisFrame = clickiesUsedThisFrame + 1
                            if maxClickiesPerFrame > 0 and clickiesUsedThisFrame >= maxClickiesPerFrame then
                                Logger.log_debug("\ayClicky: \a-tMax Clickies Per Frame of \am%d\a-t reached, stopping for this frame and picking up with %d next frame.",
                                    maxClickiesPerFrame, self.ClickyRotationIndex)
                                break
                            end
                            self.TempSettings.ClickyState[clicky.itemName].lastUsed = os.clock()
                            break --ensure we stop after we process a single clicky to allow rotations to continue
                        else
                            if not buffCheckPassed then
                                Logger.log_verbose("\ayClicky: \awItem \am%s\aw Clicky Spell: \at%s\ar already active or would not stack!", item.Name(),
                                    item.Clicky.Spell.RankName.Name())
                            else
                                Logger.log_verbose("\ayClicky: \awItem \am%s\aw Clicky: \at%s\ar Buff check failed, not using!", item.Name(), item.Clicky.Spell.RankName.Name())
                            end
                        end
                    end
                end
            else
                Logger.log_super_verbose("\ayClicky: \arSkipping clicky entry: \am%s\ar due to Combat State mismatch (Clicky State: \at%s \arCurrent State: \at%s\ar)",
                    clicky.itemName,
                    clicky.combat_state, combat_state)
            end
        end
    end
end

function Module:OnDeath()
    -- Death Handler
end

function Module:OnZone()
    -- Zone Handler
end

function Module:OnCombatModeChanged()
end

function Module:DoGetState()
    -- Reture a reasonable state if queried
    local result = string.format("\awLoaded \ag%d\at Downtime Clickies and \ag%d\at Combat Clickies\n\n", #Config:GetSetting('DowntimeClickies'),
        #Config:GetSetting('CombatClickies'))
    result = result .. "-=-=-=-=-=\n"

    for i, v in ipairs(Config:GetSetting('Clickies')) do
        result = result .. string.format("\atClicky %d: \ay%s\at\n", i, v.itemName)
    end

    return result
end

function Module:GetCommandHandlers()
    return { module = self._name, CommandHandlers = {}, }
end

function Module:GetFAQ()
    return { module = self._name, FAQ = self.FAQ or {}, }
end

---@param cmd string
---@param ... string
---@return boolean
function Module:HandleBind(cmd, ...)
    local params = ...
    local handled = false
    -- /rglua cmd handler
    return handled
end

function Module:Shutdown()
    Logger.log_debug("clicky Module Unloaded.")
end

return Module
