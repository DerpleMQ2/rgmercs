local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

local Bind        = { _version = '0.1a', _name = "RGMercsBinds", _author = 'Derple', }

Bind.MainHandler  = function(cmd, ...)
    if not cmd or cmd:len() == 0 then cmd = "help" end

    if RGMercsBinds.Handlers[cmd] then
        return RGMercsBinds.Handlers[cmd].handler(...)
    end

    local processed = false
    local results = RGMercModules:ExecAll("HandleBind", cmd, ...)

    for _, r in pairs(results) do processed = processed or r end

    if not processed then
        RGMercsLogger.log_warn("\ayWarning:\ay '\at%s\ay' is not a valid command", cmd)
    end
end

Bind.Handlers     = {
    ['set'] = {
        usage = "/rgl set [show | <setting> <value>]",
        about = "Show All Settings or Set a specific RGMercs setting",
        handler = function(config, value)
            RGMercConfig:HandleBind(config, value)
        end,
    },
    ['backoff'] = {
        usage = "/rgl backoff <on|off>",
        about = "Toggles or sets backoff flag",
        handler = function(config, value)
            if value ~= nil then
                RGMercConfig.Globals.BackOffFlag = not RGMercConfig.Globals.BackOffFlag
            elseif value:lower() == "on" then
                RGMercConfig.Globals.BackOffFlag = true
            else
                RGMercConfig.Globals.BackOffFlag = false
            end

            RGMercsLogger.log_info("\ayBackoff \awset to: ", RGMercUtils.BoolToColorString(RGMercUtils.Globals.BackOffFlag))
        end,
    },
    ['qsay'] = {
        usage = "/rgl qsay <text>",
        about = "All RGMercs will target your target and say your <text>",
        handler = function(text)
            RGMercUtils.DoCmd("/squelch /dggaexecute /target id %d", RGMercUtils.GetTargetID())
            mq.delay(5)
            RGMercUtils.DoCmd("/squelch /dggaexecute /docommand /timed $\\{Math.Rand[1,40]} /say %s", text)
        end,
    },
    ['setlogfilter'] = {
        usage = "/rgl setlogfilter <filter|filter|filter|...>",
        about = "Set a Lua regex filter to match log lines against before printing (does not effect file logging)",
        handler = function(text)
            RGMercsLogger.set_log_filter(text)
        end,
    },
    ['clearlogfilter'] = {
        usage = "/rgl clearlogfilter",
        about = "Clear log regex filter.",
        handler = function(...)
            RGMercsLogger.clear_log_filter()
        end,
    },
    ['togglepause'] = {
        usage = "/rgl togglepause",
        about = "Will toggle the pause state of your RGMerc Main Loop",
        handler = function()
            RGMercConfig.Globals.PauseMain = not RGMercConfig.Globals.PauseMain
        end,
    },
    ['pause'] = {
        usage = "/rgl pause",
        about = "Will pause your RGMerc Main Loop",
        handler = function()
            RGMercConfig.Globals.PauseMain = true
        end,
    },
    ['pauseall'] = {
        usage = "/rgl pauseall",
        about = "Will pause all of your Group RGMercs' Main Loop",
        handler = function()
            RGMercConfig.Globals.PauseMain = true
            RGMercUtils.DoCmd("/squelch /dgge /rgl pause")
        end,
    },
    ['unpause'] = {
        usage = "/rgl unpause",
        about = "Will unpause your RGMerc Main Loop",
        handler = function()
            RGMercConfig.Globals.PauseMain = false
        end,
    },
    ['unpauseall'] = {
        usage = "/rgl unpauseall",
        about = "Will unpause all of your Group RGMercs' Main Loop",
        handler = function()
            RGMercConfig.Globals.PauseMain = false
            RGMercUtils.DoCmd("/squelch /dgge /rgl unpause")
        end,
    },
    ['yes'] = {
        usage = "/rgl yes",
        about = "Will cause all of your Group RGMercs to click on every possible 'Yes' Dialogue they have up.",
        handler = function()
            RGMercUtils.DoCmd("/dgga /notify LargeDialogWindow LDW_YesButton leftmouseup")
            RGMercUtils.DoCmd("/dgga /notify LargeDialogWindow LDW_OkButton leftmouseup")
            RGMercUtils.DoCmd("/dgga /notify ConfirmationDialogBox CD_Yes_Button leftmouseup")
            RGMercUtils.DoCmd("/dgga /notify ConfirmationDialogBox CD_OK_Button leftmouseup")
            RGMercUtils.DoCmd("/dgga /notify TradeWND TRDW_Trade_Button leftmouseup")
            RGMercUtils.DoCmd("/dgga /notify GiveWnd GVW_Give_Button leftmouseup ")
            RGMercUtils.DoCmd("/dgga /notify ProgressionSelectionWnd ProgressionTemplateSelectAcceptButton leftmouseup ; /notify TaskSelectWnd TSEL_AcceptButton leftmouseup")
            RGMercUtils.DoCmd("/dgga /notify RaidWindow RAID_AcceptButton leftmouseup")
        end,
    },
    ['circle'] = {
        usage = "/rgl circle <radius>",
        about = "Will cause all of your Group RGMercs form a circle around you of radius.",
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

                    RGMercUtils.DoCmd("/dex %s /nav locyxz %2.3f %2.3f %2.3f", member.DisplayName(), yOff, xOff, mq.TLO.Me.Z())
                    RGMercUtils.DoCmd("/dex %s /timed 50 /face %s", member.DisplayName(), mq.TLO.Me.DisplayName())
                end
            end
        end,
    },
    ['help'] =
    {
        handler = function()
            printf("RGMercs [%s/%s] by: %s running for %s (%s)", RGMercConfig._version, RGMercConfig._subVersion, RGMercConfig._author,
                RGMercConfig.Globals.CurLoadedChar,
                RGMercConfig.Globals.CurLoadedClass)
            printf("\n\agCore \awCommand Help\aw\n------------\n")
            for c, d in pairs(RGMercsBinds.Handlers) do
                if c ~= "help" then
                    printf("\am%-20s\aw - \atUsage: \ay%-30s\aw | %s", c, d.usage, d.about)
                end
            end

            local moduleCommands = RGMercModules:ExecAll("GetCommandHandlers")

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

}

return Bind
