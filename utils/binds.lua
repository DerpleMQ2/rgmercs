local mq          = require('mq')
local Config      = require('utils.config')
local Core        = require("utils.core")
local Modules     = require("utils.modules")
local Targeting   = require("utils.targeting")
local Strings     = require("utils.strings")
local Logger      = require("utils.logger")
local ConfigShare = require("utils.rg_config_share")

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
    ['export_config'] = {
        usage = "/rgl export_config <module>",
        about = "Exports your current RGMercs configuration to chat",
        handler = function(module)
            local configTable = {}

            configTable = Config:GetModuleSettings((not module or module:len() <= 0) and "Core" or module)

            local encodedConfig = ConfigShare.ExportConfig(configTable)
            Logger.log_info("[RGConfigShare] :: %s", encodedConfig)
        end,
    },
    ['set'] = {
        usage = "/rgl set [show | <setting> <value>]",
        about = "Show all settings or set a specific RGMercs setting.",
        handler = function(config, value)
            Config:HandleBind(config, value)
        end,
    },
    ['peer_set'] = {
        usage = "/rgl peer_set <peer> <setting> <value>",
        about = "Sets a specific setting for an RGMercs peer.",
        handler = function(peer, config, value)
            Config:PeerSetSetting(peer, config, value)
        end,
    },
    ['tempset'] = {
        usage = "/rgl tempset <setting> <value>",
        about = "Temporarily sets a specific RGMercs setting until you reload or restart.",
        handler = function(config, value)
            Config:HandleTempSet(config, value)
        end,
    },
    ['cleartempset'] = {
        usage = "/rgl tempset <setting>",
        about = "Clears a specific Temporarily set RGMercs setting back to the saved value.",

        handler = function(config)
            Config:ClearTempSetting(config)
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
        usage = "/rgl forcetarget <id?>",
        about = "Will force the current target or <id> to be your autotarget no matter what until it is no longer valid.",
        handler = function(targetId)
            local forcedTarget = targetId and mq.TLO.Spawn(targetId) or mq.TLO.Target
            if forcedTarget and forcedTarget() and forcedTarget.ID() > 0 and (Targeting.TargetIsType("npc", forcedTarget) or Targeting.TargetIsType("npcpet", forcedTarget)) then
                Config.Globals.ForceTargetID = forcedTarget.ID()
                Logger.log_info("\awForced Target: %s", forcedTarget.CleanName() or "None")
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
    ['assistadd'] = {
        usage = "/rgl assistadd <Name>",
        about = "Adds <Name> to the Assist List. If no name is entered, your target's name is used.",
        handler = function(name)
            if not name then name = mq.TLO.Target.CleanName() end
            if not name then
                Logger.log_error("/rgl assistadd - no name given and no valid target exists!")
                return
            end
            Config:AssistAdd(name)
        end,
    },
    ['assistdelete'] = {
        usage = "/rgl assistdelete (<Name> or <List#>)",
        about = "Deletes (<Name> or <List#>) from the Assist List. If no name is entered, your target's name is used.",
        handler = function(name)
            if not name then name = mq.TLO.Target.CleanName() end
            if not name then
                Logger.log_error("/rgl assistdelete - no name given and no valid target exists!")
                return
            end
            Config:AssistDelete(name)
        end,
    },
    ['assistup'] = {
        usage = "/rgl assistup (<Name> or <List#>)",
        about = "Moves (<Name> or <List#>) one position up on the Assist List. If no name is entered, your target's name is used.",
        handler = function(name)
            if not name then name = mq.TLO.Target.CleanName() end
            if not name then
                Logger.log_error("/rgl assistup - no name given and no valid target exists!")
                return
            end
            Config:AssistMoveUp(name)
        end,
    },
    ['assistdown'] = {
        usage = "/rgl assistdown (<Name> or <List#>)",
        about = "Moves (<Name> or <List#>) one position down on the Assist List. If no name is entered, your target's name is used.",
        handler = function(name)
            if not name then name = mq.TLO.Target.CleanName() end
            if not name then
                Logger.log_error("/rgl assistdown - no name given and no valid target exists!")
                return
            end
            Config:AssistMoveDown(name)
        end,
    },
    ['assistclear'] = {
        usage = "/rgl assistclear",
        about = "Completely clears the Assist List.",
        handler = function()
            Config:AssistClear()
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
            if Config:GetSetting('BreakInvisForSay') then
                Core.DoCmd("/squelch /dggaexecute /docommand /timed $\\{Math.Rand[1,60]} /makemevisible")
                mq.delay(100) -- we can't callback for someone else's invis. Give time for everyone to be visible.
            end
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
            if Config:GetSetting('BreakInvisForSay') then
                Core.DoCmd("/squelch /dggaexecute /makemevisible")
                mq.delay(50) -- we can't callback for someone else's invis. Slight delay for execution.
            end
            Core.DoCmd("/squelch /dggaexecute /docommand /timed 5 /say %s", text)
        end,
    },
    ['rsay'] = {
        usage = "/rgl rsay <text>",
        about = "All raidmembers running RGMercs will target your target and say the <text> after a very short delay.",
        handler = function(...)
            local allText = { ..., }
            local text
            for _, t in ipairs(allText) do
                text = (text and text .. " " or "") .. t
            end
            Core.DoCmd("/squelch /dgraexecute /mqtarget id %d", Targeting.GetTargetID())
            mq.delay(5)
            if Config:GetSetting('BreakInvisForSay') then
                Core.DoCmd("/squelch /dgraexecute /makemevisible")
                mq.delay(50) -- we can't callback for someone else's invis. Slight delay for execution.
            end
            Core.DoCmd("/squelch /dgraexecute /docommand /timed 5 /say %s", text)
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

            local peerCount = mq.TLO.DanNet.PeerCount()
            if peerCount < 1 then return end
            local angle_step = (2 * math.pi) / peerCount

            --local myHeading = mq.TLO.Me.Heading.Degrees() - multiplier
            --local baseRadian = 360 / peerCount

            for i = 1, peerCount do
                ---@diagnostic disable-next-line: redundant-parameter
                local peer = mq.TLO.DanNet.Peers(i)()
                if peer and peer:len() > 0 then
                    local radians = i * angle_step
                    local xMove = math.cos(radians) * (i + radius)
                    local yMove = math.sin(radians) * (i + radius)

                    local xOff = mq.TLO.Me.X() + math.floor(xMove)
                    local yOff = mq.TLO.Me.Y() + math.floor(yMove)

                    Core.DoCmd("/dex %s /nav locyxz %2.3f %2.3f %2.3f", peer, yOff, xOff, mq.TLO.Me.Z())
                    Core.DoCmd("/dex %s /timed 50 /face %s", peer, mq.TLO.Me.DisplayName())
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
