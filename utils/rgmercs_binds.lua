local mq            = require('mq')
local RGMercUtils   = require("utils.rgmercs_utils")
local RGMercsLogger = require("utils.rgmercs_logger")

local Bind          = { _version = '0.1a', _name = "RGMercsBinds", _author = 'Derple', }

Bind.MainHandler    = function(cmd, ...)
    if RGMercsBinds.Handlers[cmd] then
        return RGMercsBinds.Handlers[cmd].handler(...)
    end

    local results = RGMercModules:ExecAll("HandleBind", cmd, ...)

    local processed = false

    for _, r in pairs(results) do processed = processed or r end

    if not processed then
        RGMercsLogger.log_warning("\ayWarning:\ay '\at%s\ay' is not a valid command", cmd)
    end
end

Bind.Handlers       = {
    ['qsay'] = {
        usage = "/rgl qsay <text>",
        about = "All RGMercs will target your target and say your <text>",
        handler = function(...)
            local text = ...
            RGMercUtils.DoCmd("/squelch /dggaexecute /target id %d", RGMercUtils.GetTargetID())
            mq.delay(5)
            RGMercUtils.DoCmd("/squelch /dggaexecute /say %s", text)
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
            RGMercUtils.DoCmd("squelch /dggeexecute /rgl pause")
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
            RGMercUtils.DoCmd("squelch /dggeexecute /rgl unpause")
        end,
    },
    ['yes'] = {
        usage = "/rgl yes",
        about = "Will cause all of your Group RGMercs to click on every possible 'Yes' Dialogue they have up.",
        handler = function()
            RGMercUtils.DoCmd("/dggaexecute /notify LargeDialogWindow LDW_YesButton leftmouseup")
            RGMercUtils.DoCmd("/dggaexecute /notify LargeDialogWindow LDW_OkButton leftmouseup")
            RGMercUtils.DoCmd("/dggaexecute /notify ConfirmationDialogBox CD_Yes_Button leftmouseup")
            RGMercUtils.DoCmd("/dggaexecute /notify ConfirmationDialogBox CD_OK_Button leftmouseup")
            RGMercUtils.DoCmd("/dggaexecute /notify TradeWND TRDW_Trade_Button leftmouseup")
            RGMercUtils.DoCmd("/dggaexecute /notify GiveWnd GVW_Give_Button leftmouseup ")
            RGMercUtils.DoCmd("/dggaexecute /notify ProgressionSelectionWnd ProgressionTemplateSelectAcceptButton leftmouseup ; /notify TaskSelectWnd TSEL_AcceptButton leftmouseup")
            RGMercUtils.DoCmd("/dggaexecute /notify RaidWindow RAID_AcceptButton leftmouseup")
        end,
    },
    ['help'] =
    {
        handler = function()
            printf("RGMercs [%s/%s] by: %s running for %s (%s)", RGMercConfig._version, RGMercConfig._subVersion, RGMercConfig._author,
                RGMercConfig.Globals.CurLoadedChar,
                RGMercConfig.Globals.CurLoadedClass)
            printf("\nCommand Help\n------------\n")
            for c, d in pairs(RGMercsBinds.Handlers) do
                if c ~= "help" then
                    printf("%-20s - Usage: %-20s | %s", c, d.usage, d.about)
                end
            end
        end,
    },

}

return Bind
