local mq          = require('mq')
local Config      = require('utils.config')
local Core        = require("utils.core")
local Modules     = require("utils.modules")
local Casting     = require("utils.casting")
local Targeting   = require("utils.targeting")
local Strings     = require("utils.strings")
local Logger      = require("utils.logger")

local Binds       = { _version = '0.1a', _name = "Binds", _author = 'Derple', }

Binds.MainHandler = function(cmd, ...)
    if not cmd or cmd:len() == 0 then cmd = "help" end

    if Binds.Handlers[cmd] then
        return Binds.Handlers[cmd].handler(...)
    end

    local processed = false
    local results = Modules:ExecAll("HandleBind", cmd, ...)

    for _, r in pairs(results) do processed = processed or r end

    if not processed then
        Logger.log_warn("\ayWarning:\ay '\at%s\ay' is not a valid command", cmd)
    end
end

Binds.Handlers    = {
    ['set'] = {
        usage = "/rgl set [show | <setting> <value>]",
        about = "Show all settings or set a specific RGMercs setting.",
        handler = function(config, value)
            Config:HandleBind(config, value)
        end,
    },
    ['forcecombat'] = {
        usage = "/rgl forcecombat",
        about = "Will force combat to be enabled on your XTarget[1]. If you have no XTarget[1] it will use your current target.",
        handler = function()
            Targeting.ForceCombat = not Targeting.ForceCombat
            Logger.log_info("\awForced Combat: %s", Strings.BoolToColorString(Targeting.ForceCombat))

            if Targeting.ForceCombat then
                if mq.TLO.Target.ID() == 0 or (mq.TLO.Target.Type() or "none"):lower() ~= "npc" then
                    Logger.log_info("\awForced Combat: Requires a target - Disabling...")
                    Targeting.ForceCombat = false
                    return
                end
                Core.DoCmd("/xtarget set 1 currenttarget")
                mq.delay("5s", function() return mq.TLO.Me.XTarget(1).ID() == mq.TLO.Target.ID() end)
                Logger.log_info("\awForced Combat Targeting: %s", mq.TLO.Me.XTarget(1).CleanName())
            else
                Targeting.ResetXTSlot(1)
                Targeting.ForceNamed = false
                Core.DoCmd("/attack off")
            end
        end,
    },
    ['forcetarget'] = {
        usage = "/rgl forcetarget",
        about = "Will force the current target to be your autotarget no matter what until it is no longer valid.",
        handler = function()
            if mq.TLO.Target.ID() > 0 and (Targeting.TargetIsType("npc") or Targeting.TargetIsType("npcpet")) then
                Config.Globals.ForceTargetID = mq.TLO.Target.ID()
                Logger.log_info("\awForced Target: %s", mq.TLO.Target.CleanName() or "None")
            end
        end,
    },
    ['forcenamed'] = {
        usage = "/rgl forcenamed",
        about = "Will force the current target to be considered a Named (this flag does not persist and is for testing purposes).",
        handler = function()
            Targeting.ForceNamed = not Targeting.ForceNamed
            Logger.log_info("\awForced Named: %s", Strings.BoolToColorString(Targeting.ForceNamed))
        end,
    },
    ['burnnow'] = {
        usage = "/rgl burnnow <id?>",
        about = "Will force the target <id> or your current target to trigger all burn checks - resets when combat ends.",
        handler = function(targetId)
            Targeting.SetForceBurn(targetId)
        end,
    },
    ['addoa'] = {
        usage = "/rgl addoa <Name>",
        about = "Adds <Name> to your Outside Assist List. If no name is entered, your target's name is used.",
        handler = function(name)
            if not name then name = mq.TLO.Target.CleanName() end
            if not name then
                Logger.log_error("/rgl addoa - no name given and no valid target exists!")
                return
            end
            Logger.log_info("Adding %s to your Outside Assist list!", name)
            Config:AddOA(name)
        end,
    },
    ['deloa'] = {
        usage = "/rgl deloa <Name>",
        about = "Deletes <Name> from your Outside Assist List. If no name is entered, your target's name is used.",
        handler = function(name)
            if not name then name = mq.TLO.Target.CleanName() end
            if not name then
                Logger.log_error("/rgl deloa - no name given and no valid target exists!")
                return
            end
            Logger.log_info("Adding %s to your Outside Assist list!", name)
            Config:DeleteOAByName(name)
        end,
    },
    ['backoff'] = {
        usage = "/rgl backoff <on|off>",
        about = "Toggles or sets backoff flag, which temporarily stops the PC from assisting or engaging.",
        handler = function(value)
            if value == nil then
                Config.Globals.BackOffFlag = not Config.Globals.BackOffFlag
            elseif value:lower() == "on" or value == "1" then
                Config.Globals.BackOffFlag = true
            else
                Config.Globals.BackOffFlag = false
            end

            Logger.log_info("\ayBackoff \awset to: %s", Strings.BoolToColorString(Config.Globals.BackOffFlag))
        end,
    },
    ['qsay'] = {
        usage = "/rgl qsay <text>",
        about = "All groupmembers running RGMercs will target your target and say the <text> with a random delay.",
        handler = function(...)
            local allText = { ..., }
            local text
            for _, t in ipairs(allText) do
                text = (text and text .. " " or "") .. t
            end
            Core.DoCmd("/squelch /dggaexecute /mqtarget id %d", Targeting.GetTargetID())
            mq.delay(5)
            Core.DoCmd("/squelch /dggaexecute /docommand /timed $\\{Math.Rand[1,60]} /say %s", text)
        end,
    },
    ['say'] = {
        usage = "/rgl say <text>",
        about = "All groupmembers running RGMercs will target your target and say the <text> after a very short delay.",
        handler = function(...)
            local allText = { ..., }
            local text
            for _, t in ipairs(allText) do
                text = (text and text .. " " or "") .. t
            end
            Core.DoCmd("/squelch /dggaexecute /mqtarget id %d", Targeting.GetTargetID())
            mq.delay(5)
            Core.DoCmd("/squelch /dggaexecute /docommand /timed 5 /say %s", text)
        end,
    },
    ['cast'] = {
        usage = "/rgl cast \"<spell>\" <targetId?>",
        about = "Uses a spell or AA (memorizes if necessary). If no targetId is entered, your target is used.",
        handler = function(spell, targetId)
            targetId = targetId and tonumber(targetId)
            targetId = targetId or (mq.TLO.Target.ID() > 0 and mq.TLO.Target.ID() or mq.TLO.Me.ID())
            Logger.log_debug("\atCasting: \aw\"\am%s\aw\" on targetId(\am%d\aw)", spell, tonumber(targetId) or mq.TLO.Target.ID())

            if not Casting.UseSpell(spell, targetId, true) then
                Casting.UseAA(spell, targetId)
            end
        end,
    },
    ['castaa'] = {
        usage = "/rgl castaa \"<AAName>\" <targetId?>",
        about = "Uses an AA. If no targetId is entered, your target is used.",
        handler = function(spell, targetId)
            targetId = targetId and tonumber(targetId)
            targetId = targetId or (mq.TLO.Target.ID() > 0 and mq.TLO.Target.ID() or mq.TLO.Me.ID())
            Logger.log_debug("\atUsing AA: \aw\"\am%s\aw\" on targetId(\am%d\aw)", spell, tonumber(targetId) or mq.TLO.Target.ID())

            Casting.UseAA(spell, targetId)
        end,
    },
    ['usemap'] = {
        usage = "/rgl usemap \"<maptype>\" \"<mapname>\" <targetId?>",
        about = "RGMercs will use the mapped spell, song, AA, disc, or item (using smart targeting, or, if provided, on the specified <targetID>).",
        handler = function(mapType, mapName, targetId)
            local action = Modules:ExecModule("Class", "GetResolvedActionMapItem", mapName)
            if not action or not action() then
                Logger.log_debug("\arUseMap: \"\ay%s\ar\" does not appear to be a valid mapped action! \awPlease note this value is case-sensitive.", mapName)
                return false
            end
            targetId = targetId and tonumber(targetId)
            targetId = targetId or (mq.TLO.Target.ID() > 0 and mq.TLO.Target.ID() or mq.TLO.Me.ID())

            local actionHandlers = {
                spell = function() return Casting.UseSpell(action.RankName, targetId, true) end,
                song = function() return Casting.UseSong(action.RankName, targetId, true) end,
                aa = function() return Casting.UseAA(action, targetId) end, --AFAIK we don't have any AA mapped, but, future proof.
                item = function() return Casting.UseItem(action, targetId) end,
                disc = function() return Casting.UseDisc(action, targetId) end,
            }

            local handlerFunc = actionHandlers[mapType:lower()]
            if handlerFunc then
                handlerFunc()
            else
                Logger.log_debug("\arUseMap: \"\ay%s\ar\" is an invalid maptype. \awValid maptypes are : \agspell \aw| \agsong \aw| \agAA \aw| \agdisc \aw| \agitem", mapType)
            end
        end,
    },
    ['setlogfilter'] = {
        usage = "/rgl setlogfilter <filter|filter|filter|...>",
        about = "Set a Lua regex filter to match log lines against before printing (does not effect file logging).",
        handler = function(text)
            Logger.set_log_filter(text)
        end,
    },
    ['clearlogfilter'] = {
        usage = "/rgl clearlogfilter",
        about = "Clear log regex filter.",
        handler = function(...)
            Logger.clear_log_filter()
        end,
    },
    ['togglepause'] = {
        usage = "/rgl togglepause",
        about = "Toggle the pause state of your RGMercs Main Loop.",
        handler = function()
            Config.Globals.PauseMain = not Config.Globals.PauseMain
        end,
    },
    ['pause'] = {
        usage = "/rgl pause",
        about = "Pauses your RGMercs Main Loop.",
        handler = function()
            Config.Globals.PauseMain = true
        end,
    },
    ['pauseall'] = {
        usage = "/rgl pauseall",
        about = "Pauses the RGMercs Main Loop for every groupmember.",
        handler = function()
            Config.Globals.PauseMain = true
            Core.DoCmd("/squelch /dgge /rgl pause")
            Logger.log_info("\ayAll clients paused!")
        end,
    },
    ['unpause'] = {
        usage = "/rgl unpause",
        about = "Unpauses your RGMercs Main Loop.",
        handler = function()
            Config.Globals.PauseMain = false
        end,
    },
    ['unpauseall'] = {
        usage = "/rgl unpauseall",
        about = "Unpauses the RGMercs Main Loop for every groupmember.",
        handler = function()
            Config.Globals.PauseMain = false
            Core.DoCmd("/squelch /dgge /rgl unpause")
            Logger.log_info("\agAll clients paused!")
        end,
    },
    ['yes'] = {
        usage = "/rgl yes",
        about = "All groupmembers running RGMercs will click on every possible 'Yes' Dialogue they have up.",
        handler = function()
            Core.DoCmd("/dgga /notify LargeDialogWindow LDW_YesButton leftmouseup")
            Core.DoCmd("/dgga /notify LargeDialogWindow LDW_OkButton leftmouseup")
            Core.DoCmd("/dgga /notify ConfirmationDialogBox CD_Yes_Button leftmouseup")
            Core.DoCmd("/dgga /notify ConfirmationDialogBox CD_OK_Button leftmouseup")
            Core.DoCmd("/dgga /notify TradeWND TRDW_Trade_Button leftmouseup")
            Core.DoCmd("/dgga /notify GiveWnd GVW_Give_Button leftmouseup ")
            Core.DoCmd("/dgga /notify ProgressionSelectionWnd ProgressionTemplateSelectAcceptButton leftmouseup")
            Core.DoCmd("/dgga /notify TaskSelectWnd TSEL_AcceptButton leftmouseup")
            Core.DoCmd("/dgga /notify RaidWindow RAID_AcceptButton leftmouseup")
        end,
    },
    ['circle'] = {
        usage = "/rgl circle <radius>",
        about = "All groupmembers running RGMercss will form a circle around you using the entered radius.",
        handler = function(radius)
            if not radius then radius = 15 end

            local groupCount = mq.TLO.Group.Members()
            if groupCount < 1 then return end
            local multiplier = 90

            if groupCount == 2 then
                multiplier = 318
            elseif groupCount == 3 then
                multiplier = 270
            elseif groupCount == 4 then
                multiplier = 245
            elseif groupCount == 5 then
                multiplier = 196
            end

            local myHeading = mq.TLO.Me.Heading.Degrees() - multiplier
            local baseRadian = 360 / groupCount

            for i = 1, groupCount do
                local member = mq.TLO.Group.Member(i)
                if member and member() then
                    local xMove = math.cos(baseRadian * (i + myHeading))
                    local yMove = math.sin(baseRadian * (i + myHeading))

                    local xOff = mq.TLO.Me.X() + math.floor(radius * xMove)
                    local yOff = mq.TLO.Me.Y() + math.floor(radius * yMove)

                    Core.DoCmd("/dex %s /nav locyxz %2.3f %2.3f %2.3f", member.DisplayName(), yOff, xOff, mq.TLO.Me.Z())
                    Core.DoCmd("/dex %s /timed 50 /face %s", member.DisplayName(), mq.TLO.Me.DisplayName())
                end
            end
        end,
    },
    ['mini'] = {
        usage = "/rgl mini",
        about = "Toggle minimizing of the RGMercs window to a small icon.",
        handler = function()
            Config.Globals.Minimized = not Config.Globals.Minimized
        end,
    },
    ['help'] = {
        handler = function()
            printf("RGMercs [%s/%s] by: %s running for %s (%s)", Config._version, Config._subVersion, Config._author,
                Config.Globals.CurLoadedChar,
                Config.Globals.CurLoadedClass)
            printf("\n\agCore \awCommand Help\aw\n------------\n")
            for c, d in pairs(Binds.Handlers) do
                if c ~= "help" then
                    printf("\am%-20s\aw - \atUsage: \ay%-30s\aw | %s", c, d.usage, d.about)
                end
            end

            local moduleCommands = Modules:ExecAll("GetCommandHandlers")

            for _, info in pairs(moduleCommands) do
                local printHeader = true
                if info.CommandHandlers then
                    for c, d in pairs(info.CommandHandlers or {}) do
                        if printHeader then
                            printf("\n\ag%s\aw Specific Commands Help\n------------\n", info.module)
                            printHeader = false
                        end
                        printf("\am%-20s\aw - \atUsage: \ay%-60s\aw | %s", c, d.usage, d.about)
                    end
                end
            end
        end,
    },
    ['pop'] = {
        usage = "/rgl pop <modulename>",
        about = "Toggles between popped and docked states for <modulename>.",
        handler = function(config, value)
            if config == 'debug' or config == 'console' then
                Config:SetSetting("PopOutConsole", not Config:GetSetting("PopOutConsole"))
            else
                Modules:ExecModule(config, "Pop")
            end
        end,
    },
    ['faq'] = {
        usage = "/rgl faq \"<search terms>\"",
        about = "Search the FAQ and display the results in the mq2 console. Please see the FAQ tab for a friendlier experience!",
        handler = function(config, value)
            Modules:ExecModule('FAQ', "FaqFind", config)
        end,
    },
}

return Binds
