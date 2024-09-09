--[[
lootnscoot.lua v1.7 - aquietone, grimmier

This is a port of the RedGuides copy of ninjadvloot.inc with some updates as well.
I may have glossed over some of the events or edge cases so it may have some issues
around things like:
- lore items
- full inventory
- not full inventory but no slot large enough for an item
- ...
Or those things might just work, I just haven't tested it very much using lvl 1 toons
on project lazarus.

Settings are saved per character in config\LootNScoot_[ServerName]_[CharName].ini
if you would like to use a global settings file. you can Change this inside the above file to point at your global file instead.
example= SettingsFile=D:\MQ_EMU\Config/LootNScoot_GlobalSettings.ini

This script can be used in two ways:
    1. Included within a larger script using require, for example if you have some KissAssist-like lua script:
        To loot mobs, call lootutils.lootMobs():

            local mq = require 'mq'
            local lootutils = require 'lootnscoot'
            while true do
                lootutils.lootMobs()
                mq.delay(1000)
            end

        lootUtils.lootMobs() will run until it has attempted to loot all corpses within the defined radius.

        To sell to a vendor, call lootutils.sellStuff():

            local mq = require 'mq'
            local lootutils = require 'lootnscoot'
            local doSell = false
            local function binds(...)
                local args = {...}
                if args[1] == 'sell' then doSell = true end
            end
            mq.bind('/myscript', binds)
            while true do
                lootutils.lootMobs()
                if doSell then lootutils.sellStuff() doSell = false end
                mq.delay(1000)
            end

        lootutils.sellStuff() will run until it has attempted to sell all items marked as sell to the targeted vendor.

        Note that in the above example, loot.sellStuff() isn't being called directly from the bind callback.
        Selling may take some time and includes delays, so it is best to be called from your main loop.

        Optionally, configure settings using:
            Set the radius within which corpses should be looted (radius from you, not a camp location)
                lootutils.CorpseRadius = number
            Set whether loot.ini should be updated based off of sell item events to add manually sold items.
                lootutils.AddNewSales = boolean
            Several other settings can be found in the "loot" table defined in the code.

    2. Run as a standalone script:
        /lua run lootnscoot standalone
            Will keep the script running, checking for corpses once per second.
        /lua run lootnscoot once
            Will run one iteration of loot.lootMobs().
        /lua run lootnscoot sell
            Will run one iteration of loot.sellStuff().
        /lua run lootnscoot cleanup
            Will run one iteration of loot.cleanupBags().

The script will setup a bind for "/lootutils":
    /lootutils <action> "${Cursor.Name}"
        Set the loot rule for an item. "action" may be one of:
            - Keep
            - Bank
            - Sell
            - Tribute
            - Ignore
            - Destroy
            - Quest|#

    /lootutils reload
        Reload the contents of Loot.ini
    /lootutils bank
        Put all items from inventory marked as Bank into the bank
    /lootutils tsbank
        Mark all tradeskill items in inventory as Bank

If running in standalone mode, the bind also supports:
    /lootutils sellstuff
        Runs lootutils.sellStuff() one time
    /lootutils tributestuff
        Runs lootutils.tributeStuff() one time
    /lootutils cleanup
        Runs lootutils.cleanupBags() one time

The following events are used:
    - eventCantLoot - #*#may not loot this corpse#*#
        Add corpse to list of corpses to avoid for a few minutes if someone is already looting it.
    - eventSell - #*#You receive#*# for the #1#(s)#*#
        Set item rule to Sell when an item is manually sold to a vendor
    - eventInventoryFull - #*#Your inventory appears full!#*#
        Stop attempting to loot once inventory is full. Note that currently this never gets set back to false
        even if inventory space is made available.
    - eventNovalue - #*#give you absolutely nothing for the #1#.#*#
        Warn and move on when attempting to sell an item which the merchant will not buy.

This does not include the buy routines from ninjadvloot. It does include the sell routines
but lootly sell routines seem more robust than the code that was in ninjadvloot.inc.
The forage event handling also does not handle fishing events like ninjadvloot did.
There is also no flag for combat looting. It will only loot if no mobs are within the radius.

]]

local mq = require 'mq'

local eqServer = string.gsub(mq.TLO.EverQuest.Server(), ' ', '_')
-- Check for looted module, if found use that. else fall back on our copy, which may be outdated.

local eqChar = mq.TLO.Me.Name()
local actors = require('actors')
local SettingsFile = mq.configDir .. '/LootNScoot_' .. eqServer .. '_' .. eqChar .. '.ini'
local version = 1.9
local imported = true
-- Public default settings, also read in from Loot.ini [Settings] section
local loot = {
    Version = '"' .. tostring(version) .. '"',
    LootFile = mq.configDir .. '/Loot.ini',
    SettingsFile = mq.configDir .. '/LootNScoot_' .. eqServer .. '_' .. eqChar .. '.ini',
    GlobalLootOn = true,                       -- Enable Global Loot Items. not implimented yet
    CombatLooting = false,                     -- Enables looting during combat. Not recommended on the MT
    CorpseRadius = 100,                        -- Radius to activly loot corpses
    MobsTooClose = 40,                         -- Don't loot if mobs are in this range.
    SaveBagSlots = 3,                          -- Number of bag slots you would like to keep empty at all times. Stop looting if we hit this number
    TributeKeep = false,                       -- Keep items flagged Tribute
    MinTributeValue = 100,                     -- Minimun Tribute points to keep item if TributeKeep is enabled.
    MinSellPrice = -1,                         -- Minimum Sell price to keep item. -1 = any
    StackPlatValue = 0,                        -- Minimum sell value for full stack
    StackableOnly = false,                     -- Only loot stackable items
    AlwaysEval = false,                        -- Re-Evaluate all *Non Quest* items. useful to update loot.ini after changing min sell values.
    BankTradeskills = true,                    -- Toggle flagging Tradeskill items as Bank or not.
    DoLoot = true,                             -- Enable auto looting in standalone mode
    LootForage = true,                         -- Enable Looting of Foraged Items
    LootNoDrop = false,                        -- Enable Looting of NoDrop items.
    LootNoDropNew = false,                     -- Enable looting of new NoDrop items.
    LootQuest = false,                         -- Enable Looting of Items Marked 'Quest', requires LootNoDrop on to loot NoDrop quest items
    DoDestroy = false,                         -- Enable Destroy functionality. Otherwise 'Destroy' acts as 'Ignore'
    AlwaysDestroy = false,                     -- Always Destroy items to clean corpese Will Destroy Non-Quest items marked 'Ignore' items REQUIRES DoDestroy set to true
    QuestKeep = 10,                            -- Default number to keep if item not set using Quest|# format.
    LootChannel = "dgt",                       -- Channel we report loot to.
    GroupChannel = "dgae",                     -- Channel we use for Group Commands
    ReportLoot = true,                         -- Report loot items to group or not.
    SpamLootInfo = false,                      -- Echo Spam for Looting
    LootForageSpam = false,                    -- Echo spam for Foraged Items
    AddNewSales = true,                        -- Adds 'Sell' Flag to items automatically if you sell them while the script is running.
    AddNewTributes = true,                     -- Adds 'Tribute' Flag to items automatically if you Tribute them while the script is running.
    GMLSelect = true,                          -- not implimented yet
    ExcludeBag1 = "Extraplanar Trade Satchel", -- Name of Bag to ignore items in when selling
    NoDropDefaults = "Quest|Keep|Ignore",      -- not implimented yet
    LootLagDelay = 0,                          -- not implimented yet
    CorpseRotTime = "440s",                    -- not implimented yet
    HideNames = false,                         -- Hides names and uses class shortname in looted window
    LookupLinks = false,                       -- Enables Looking up Links for items not on that character. *recommend only running on one charcter that is monitoring.
    RecordData = false,                        -- Enables recording data to report later.
    AutoTag = false,                           -- Automatically tag items to sell if they meet the MinSellPrice
    AutoRestock = false,                       -- Automatically restock items from the BuyItems list when selling
    Terminate = true,
}
loot.guiLoot = require('lib.lootnscoot.loot_hist')
if loot.guiLoot ~= nil then
    loot.UseActors = true
    loot.guiLoot.GetSettings(loot.HideNames, loot.LookupLinks, loot.RecordData, true, loot.UseActors, 'lootnscoot')
end

-- Internal settings
local lootData, cantLootList = {}, {}
local doSell, doBuy, doTribute, areFull = false, false, false, false
local cantLootID = 0
-- Constants
local spawnSearch = '%s radius %d zradius 50'
-- If you want destroy to actually loot and destroy items, change DoDestroy=false to DoDestroy=true in the Settings Ini.
-- Otherwise, destroy behaves the same as ignore.
local shouldLootActions = { Keep = true, Bank = true, Sell = true, Destroy = false, Ignore = false, Tribute = false, }
local validActions = { keep = 'Keep', bank = 'Bank', sell = 'Sell', ignore = 'Ignore', destroy = 'Destroy', quest = 'Quest', tribute = 'Tribute', }
local saveOptionTypes = { string = 1, number = 1, boolean = 1, }
local NEVER_SELL = { ['Diamond Coin'] = true, ['Celestial Crest'] = true, ['Gold Coin'] = true, ['Taelosian Symbols'] = true, ['Planar Symbols'] = true, }
local tmpCmd = loot.GroupChannel or 'dgae'
local BuyItems = {}
-- FORWARD DECLARATIONS

-- local loot.eventForage, loot.eventSell, loot.eventCantLoot, loot.eventTribute, loot.eventNoSlot

-- UTILITIES

function loot.writeSettings()
    for option, value in pairs(loot) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            mq.cmdf('/ini "%s" "%s" "%s" "%s"', SettingsFile, 'Settings', option, value)
        end
    end
    for option, value in pairs(BuyItems) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            mq.cmdf('/ini "%s" "%s" "%s" "%s"', SettingsFile, 'BuyItems', option, value)
        end
    end
end

function loot.split(input, sep)
    if sep == nil then
        sep = "|"
    end
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function loot.loadSettings()
    local iniSettings = mq.TLO.Ini.File(SettingsFile).Section('Settings')
    local keyCount = iniSettings.Key.Count()
    for i = 1, keyCount do
        local key = iniSettings.Key.KeyAtIndex(i)()
        local value = iniSettings.Key(key).Value()
        if key == 'Version' then
            loot[key] = tostring(value)
        elseif value == 'true' or value == 'false' then
            loot[key] = value == 'true' and true or false
        elseif tonumber(value) then
            loot[key] = tonumber(value)
        else
            loot[key] = value
        end
    end
    if tonumber(loot.Version) < tonumber(version) then
        loot.Version = tostring(version)
        print('Updating Settings File to Version ' .. tostring(version))
        loot.writeSettings()
    end
    tmpCmd = loot.GroupChannel or 'dgae'
    if tmpCmd == string.find(tmpCmd, 'dg') then
        tmpCmd = '/' .. tmpCmd
    elseif tmpCmd == string.find(tmpCmd, 'bc') then
        tmpCmd = '/' .. tmpCmd .. ' /'
    end
    shouldLootActions.Destroy = loot.DoDestroy
    shouldLootActions.Tribute = loot.TributeKeep
    local iniBuyItems = mq.TLO.Ini.File(SettingsFile).Section('BuyItems')
    local buyKeyCount = iniBuyItems.Key.Count()
    for i = 1, buyKeyCount do
        local key = iniBuyItems.Key.KeyAtIndex(i)()
        local value = iniBuyItems.Key(key).Value()
        BuyItems[key] = value
    end
end

function loot.checkCursor()
    local currentItem = nil
    while mq.TLO.Cursor() do
        -- can't do anything if there's nowhere to put the item, either due to no free inventory space
        -- or no slot of appropriate size
        if mq.TLO.Me.FreeInventory() == 0 or mq.TLO.Cursor() == currentItem then
            if loot.SpamLootInfo then RGMercsLogger.log_debug('Inventory full, item stuck on cursor') end
            mq.cmd('/autoinv')
            return
        end
        currentItem = mq.TLO.Cursor()
        mq.cmd('/autoinv')
        mq.delay(100)
    end
end

function loot.navToID(spawnID)
    mq.cmdf('/nav id %d log=off', spawnID)
    mq.delay(50)
    if mq.TLO.Navigation.Active() then
        local startTime = os.time()
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
            if os.difftime(os.time(), startTime) > 5 then
                break
            end
        end
    end
end

function loot.addRule(itemName, section, rule)
    if not lootData[section] then
        lootData[section] = {}
    end
    lootData[section][itemName] = rule
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', loot.LootFile, section, itemName, rule)
end

function loot.lookupIniLootRule(section, key)
    return mq.TLO.Ini.File(loot.LootFile).Section(section).Key(key).Value()
end

-- moved this function up so we can report Quest Items.
local reportPrefix = '/%s \a-t[\at%s\a-t][\ax\ayLootUtils\ax\a-t]\ax '
function loot.report(message, ...)
    if loot.ReportLoot then
        local prefixWithChannel = reportPrefix:format(loot.LootChannel, mq.TLO.Time())
        mq.cmdf(prefixWithChannel .. message, ...)
    end
end

function loot.AreBagsOpen()
    local total = {
        bags = 0,
        open = 0,
    }
    for i = 23, 32 do
        local slot = mq.TLO.Me.Inventory(i)
        if slot and slot.Container() and slot.Container() > 0 then
            total.bags = total.bags + 1
            ---@diagnostic disable-next-line: undefined-field
            if slot.Open() then
                total.open = total.open + 1
            end
        end
    end
    if total.bags == total.open then
        return true
    else
        return false
    end
end

---@return string,number,boolean|nil
function loot.getRule(item)
    local itemName = item.Name()
    local lootDecision = 'Keep'
    local tradeskill = item.Tradeskills()
    local sellPrice = item.Value() and item.Value() / 1000 or 0
    local stackable = item.Stackable()
    local tributeValue = item.Tribute()
    local firstLetter = itemName:sub(1, 1):upper()
    local stackSize = item.StackSize()
    local countHave = mq.TLO.FindItemCount(string.format("%s", itemName))() + mq.TLO.FindItemBankCount(string.format("%s", itemName))()
    local qKeep = '0'
    local globalItem = loot.lookupIniLootRule('GlobalItems', itemName)
    local newRule = false

    lootData[firstLetter] = lootData[firstLetter] or {}
    lootData[firstLetter][itemName] = lootData[firstLetter][itemName] or loot.lookupIniLootRule(firstLetter, itemName)

    -- Re-Evaluate the settings if AlwaysEval is on. Items that do not meet the Characters settings are reset to NUll and re-evaluated as if they were new items.
    if loot.AlwaysEval then
        local oldDecision = lootData[firstLetter][itemName] -- whats on file
        local resetDecision = 'NULL'
        if string.find(oldDecision, 'Quest') or oldDecision == 'Keep' or oldDecision == 'Destroy' then resetDecision = oldDecision end
        -- If sell price changed and item doesn't meet the new value re-evalute it otherwise keep it set to sell
        if oldDecision == 'Sell' and not stackable and sellPrice >= loot.MinSellPrice then resetDecision = oldDecision end
        -- -- Do the same for stackable items.
        if (oldDecision == 'Sell' and stackable) and (sellPrice * stackSize >= loot.StackPlatValue) then resetDecision = oldDecision end
        -- if banking tradeskills settings changed re-evaluate
        if oldDecision == 'Bank' and tradeskill and loot.BankTradeskills then resetDecision = oldDecision end

        lootData[firstLetter][itemName] = resetDecision -- pass value on to next check. Items marked 'NULL' will be treated as new and evaluated properly.
    end
    if lootData[firstLetter][itemName] == 'NULL' then
        if tradeskill and loot.BankTradeskills then lootDecision = 'Bank' end
        if not stackable and sellPrice < loot.MinSellPrice then lootDecision = 'Ignore' end -- added stackable check otherwise it would stay set to Ignore when checking Stackable items in next steps.
        if not stackable and loot.StackableOnly then lootDecision = 'Ignore' end
        if (stackable and loot.StackPlatValue > 0) and (sellPrice * stackSize < loot.StackPlatValue) then lootDecision = 'Ignore' end
        -- set Tribute flag if tribute value is greater than minTributeValue and the sell price is less than min sell price or has no value
        if tributeValue >= loot.MinTributeValue and (sellPrice < loot.MinSellPrice or sellPrice == 0) then lootDecision = 'Tribute' end
        loot.addRule(itemName, firstLetter, lootDecision)
        if loot.AutoTag and lootDecision == 'Keep' then                                       -- Do we want to automatically tag items 'Sell'
            if not stackable and sellPrice > loot.MinSellPrice then lootDecision = 'Sell' end -- added stackable check otherwise it would stay set to Ignore when checking Stackable items in next steps.
            if (stackable and loot.StackPlatValue > 0) and (sellPrice * stackSize >= loot.StackPlatValue) then lootDecision = 'Sell' end
            loot.addRule(itemName, firstLetter, lootDecision)
        end
        newRule = true
    end
    -- check this before quest item checks. so we have the proper rule to compare.
    -- Check if item is on global Items list, ignore everything else and use those rules insdead.
    if loot.GlobalLootOn and globalItem ~= 'NULL' then
        lootData[firstLetter][itemName] = globalItem or lootData[firstLetter][itemName]
    end
    -- Check if item marked Quest
    if string.find(lootData[firstLetter][itemName], 'Quest') then
        local qVal = 'Ignore'
        -- do we want to loot quest items?
        if loot.LootQuest then
            --look to see if Quantity attached to Quest|qty
            local _, position = string.find(lootData[firstLetter][itemName], '|')
            if position then qKeep = string.sub(lootData[firstLetter][itemName], position + 1) else qKeep = '0' end
            -- if Quantity is tied to the entry then use that otherwise use default Quest Keep Qty.
            if qKeep == '0' then
                qKeep = tostring(loot.QuestKeep)
            end
            -- If we have less than we want to keep loot it.
            if countHave < tonumber(qKeep) then
                qVal = 'Keep'
            end
            if loot.AlwaysDestroy and qVal == 'Ignore' then qVal = 'Destroy' end
        end
        return qVal, tonumber(qKeep) or 0
    end
    if loot.AlwaysDestroy and lootData[firstLetter][itemName] == 'Ignore' then return 'Destroy', 0 end

    return lootData[firstLetter][itemName], 0, newRule
end

-- EVENTS

local lootActor = actors.register('lootnscoot', function(message) end)

local itemNoValue = nil
function loot.eventNovalue(line, item)
    itemNoValue = item
end

function loot.setupEvents()
    mq.event("CantLoot", "#*#may not loot this corpse#*#", loot.eventCantLoot)
    mq.event("NoSlot", "#*#There are no open slots for the held item in your inventory#*#", loot.eventNoSlot)
    mq.event("Sell", "#*#You receive#*# for the #1#(s)#*#", loot.eventSell)
    if loot.LootForage then
        mq.event("ForageExtras", "Your forage mastery has enabled you to find something else!", loot.eventForage)
        mq.event("Forage", "You have scrounged up #*#", loot.eventForage)
    end
    mq.event("Novalue", "#*#give you absolutely nothing for the #1#.#*#", loot.eventNovalue)
    mq.event("Tribute", "#*#We graciously accept your #1# as tribute, thank you!#*#", loot.eventTribute)
end

-- BINDS

function loot.commandHandler(...)
    local args = { ..., }
    if #args == 1 then
        if args[1] == 'sellstuff' and not loot.Terminate then
            doSell = true
        elseif args[1] == 'restock' and not loot.Terminate then
            doBuy = true
        elseif args[1] == 'reload' then
            lootData = {}
            loot.loadSettings()
            if loot.guiLoot ~= nil then loot.guiLoot.GetSettings(loot.HideNames, loot.LookupLinks, loot.RecordData, true, loot.UseActors, 'lootnscoot') end
            loot.Terminate = false
            RGMercsLogger.log_info("\ayReloaded Settings \axAnd \atLoot Files")
        elseif args[1] == 'bank' then
            loot.processItems('Bank')
        elseif args[1] == 'cleanup' then
            loot.processItems('Cleanup')
        elseif args[1] == 'gui' and loot.guiLoot ~= nil then
            loot.guiLoot.openGUI = not loot.guiLoot.openGUI
        elseif args[1] == 'report' and loot.guiLoot ~= nil then
            loot.guiLoot.ReportLoot()
        elseif args[1] == 'hidenames' and loot.guiLoot ~= nil then
            loot.guiLoot.hideNames = not loot.guiLoot.hideNames
        elseif args[1] == 'config' then
            local confReport = string.format("\ayLoot N Scoot Settings\ax")
            for key, value in pairs(loot) do
                if type(value) ~= "function" and type(value) ~= "table" then
                    confReport = confReport .. string.format("\n\at%s\ax = \ag%s\ax", key, tostring(value))
                end
            end
            RGMercsLogger.log_info(confReport)
        elseif args[1] == 'tributestuff' then
            doTribute = true
        elseif args[1] == 'loot' then
            loot.lootMobs()
        elseif args[1] == 'tsbank' then
            loot.markTradeSkillAsBank()
        elseif validActions[args[1]] and mq.TLO.Cursor() then
            loot.addRule(mq.TLO.Cursor(), mq.TLO.Cursor():sub(1, 1), validActions[args[1]])
            RGMercsLogger.log_info(string.format("Setting \ay%s\ax to \ay%s\ax", mq.TLO.Cursor(), validActions[args[1]]))
        end
    elseif #args == 2 then
        if args[1] == 'quest' and mq.TLO.Cursor() then
            loot.addRule(mq.TLO.Cursor(), mq.TLO.Cursor():sub(1, 1), 'Quest|' .. args[2])
            RGMercsLogger.log_info("Setting \ay%s\ax to \ayQuest|%s\ax", mq.TLO.Cursor(), args[2])
        elseif args[1] == 'buy' and mq.TLO.Cursor() then
            mq.cmdf('/ini "%s" "BuyItems" "%s" "%s"', SettingsFile, mq.TLO.Cursor(), args[2])
            RGMercsLogger.log_info("Setting \ay%s\ax to \ayBuy|%s\ax", mq.TLO.Cursor(), args[2])
        elseif args[1] == 'globalitem' and validActions[args[2]] and mq.TLO.Cursor() then
            loot.addRule(mq.TLO.Cursor(), 'GlobalItems', validActions[args[2]])
            RGMercsLogger.log_info("Setting \ay%s\ax to \agGlobal Item \ay%s\ax", mq.TLO.Cursor(), validActions[args[2]])
        elseif validActions[args[1]] and args[2] ~= 'NULL' then
            loot.addRule(args[2], args[2]:sub(1, 1), validActions[args[1]])
            RGMercsLogger.log_info("Setting \ay%s\ax to \ay%s\ax", args[2], validActions[args[1]])
        end
    elseif #args == 3 then
        if args[1] == 'globalitem' and args[2] == 'quest' and mq.TLO.Cursor() then
            loot.addRule(mq.TLO.Cursor(), 'GlobalItems', 'Quest|' .. args[3])
            RGMercsLogger.log_info("Setting \ay%s\ax to \agGlobal Item \ayQuest|%s\ax", mq.TLO.Cursor(), args[3])
        elseif args[1] == 'globalitem' and validActions[args[2]] and args[3] ~= 'NULL' then
            loot.addRule(args[3], 'GlobalItems', validActions[args[2]])
            RGMercsLogger.log_info("Setting \ay%s\ax to \agGlobal Item \ay%s\ax", args[3], validActions[args[2]])
        elseif args[1] == 'buy' then
            mq.cmdf('/ini "%s" "BuyItems" "%s" "%s"', SettingsFile, args[2], args[3])
            RGMercsLogger.log_info("Setting \ay%s\ax to \ayBuy|%s\ax", args[2], args[3])
        elseif validActions[args[1]] and args[2] ~= 'NULL' then
            loot.addRule(args[2], args[2]:sub(1, 1), validActions[args[1]] .. '|' .. args[3])
            RGMercsLogger.log_info("Setting \ay%s\ax to \ay%s|%s\ax", args[2], validActions[args[1]], args[3])
        end
    elseif #args == 4 then
        if args[1] == 'globalitem' and validActions[args[2]] and args[3] ~= 'NULL' then
            loot.addRule(args[3], 'GlobalItems', validActions[args[2]] .. '|' .. args[4])
            RGMercsLogger.log_info("Setting \ay%s\ax to \agGlobal Item \ay%s|%s\ax", args[3], validActions[args[2]], args[4])
        end
    end
end

function loot.setupBinds()
    mq.bind('/lootutils', loot.commandHandler)
end

-- LOOTING

function loot.CheckBags()
    areFull = mq.TLO.Me.FreeInventory() <= loot.SaveBagSlots
end

function loot.eventCantLoot()
    cantLootID = mq.TLO.Target.ID()
end

function loot.eventNoSlot()
    -- we don't have a slot big enough for the item on cursor. Dropping it to the ground.
    local cantLootItemName = mq.TLO.Cursor()
    mq.cmd('/drop')
    mq.delay(1)
    loot.report("\ay[WARN]\arI can't loot %s, dropping it on the ground!\ax", cantLootItemName)
end

---@param index number @The current index we are looking at in loot window, 1-based.
---@param doWhat string @The action to take for the item.
---@param button string @The mouse button to use to loot the item. Currently only leftmouseup implemented.
---@param qKeep number @The count to keep, for quest items.
---@param allItems table @Table of all items seen so far on the corpse, left or looted.
function loot.lootItem(index, doWhat, button, qKeep, allItems)
    local eval = doWhat
    RGMercsLogger.log_debug('Enter lootItem')
    local corpseItem = mq.TLO.Corpse.Item(index)
    if not shouldLootActions[doWhat] then
        table.insert(allItems, { Name = corpseItem.Name(), Action = 'Left', Link = corpseItem.ItemLink('CLICKABLE')(), Eval = doWhat, })
        return
    end
    local corpseItemID = corpseItem.ID()
    local itemName = corpseItem.Name()
    local itemLink = corpseItem.ItemLink('CLICKABLE')()
    local globalItem = (loot.GlobalLootOn and loot.lookupIniLootRule('GlobalItems', itemName) ~= "NULL") and true or false

    mq.cmdf('/nomodkey /shift /itemnotify loot%s %s', index, button)
    -- Looting of no drop items is currently disabled with no flag to enable anyways
    -- added check to make sure the cursor isn't empty so we can exit the pause early.-- or not mq.TLO.Corpse.Item(index).NoDrop()
    mq.delay(1) -- for good measure.
    mq.delay(5000, function() return mq.TLO.Window('ConfirmationDialogBox').Open() or mq.TLO.Cursor() == nil end)
    if mq.TLO.Window('ConfirmationDialogBox').Open() then mq.cmd('/nomodkey /notify ConfirmationDialogBox Yes_Button leftmouseup') end
    mq.delay(5000, function() return mq.TLO.Cursor() ~= nil or not mq.TLO.Window('LootWnd').Open() end)
    mq.delay(1) -- force next frame
    -- The loot window closes if attempting to loot a lore item you already have, but lore should have already been checked for
    if not mq.TLO.Window('LootWnd').Open() then return end
    if doWhat == 'Destroy' and mq.TLO.Cursor.ID() == corpseItemID then
        eval = globalItem and 'Global Destroy' or 'Destroy'
        mq.cmd('/destroy')
        table.insert(allItems, { Name = itemName, Action = 'Destroyed', Link = itemLink, Eval = eval, })
    end
    loot.checkCursor()
    if qKeep > 0 and doWhat == 'Keep' then
        eval = globalItem and 'Global Quest' or 'Quest'
        local countHave = mq.TLO.FindItemCount(string.format("%s", itemName))() + mq.TLO.FindItemBankCount(string.format("%s", itemName))()
        loot.report("\awQuest Item:\ag %s \awCount:\ao %s \awof\ag %s", itemLink, tostring(countHave), qKeep)
    else
        eval = globalItem and 'Global ' .. doWhat or doWhat
        loot.report('%sing \ay%s\ax', doWhat, itemLink)
    end
    if doWhat ~= 'Destroy' then
        if not string.find(eval, 'Quest') then
            eval = globalItem and 'Global ' .. doWhat or doWhat
        end
        table.insert(allItems, { Name = itemName, Action = 'Looted', Link = itemLink, Eval = eval, })
    end
    loot.CheckBags()
    if areFull then loot.report('My bags are full, I can\'t loot anymore! Turning OFF Looting until we sell.') end
end

function loot.lootCorpse(corpseID)
    RGMercsLogger.log_debug('Enter lootCorpse')
    if mq.TLO.Cursor() then loot.checkCursor() end
    for i = 1, 3 do
        mq.cmd('/loot')
        mq.delay(1000, function() return mq.TLO.Window('LootWnd').Open() end)
        if mq.TLO.Window('LootWnd').Open() then break end
    end
    mq.doevents('CantLoot')
    mq.delay(3000, function() return cantLootID > 0 or mq.TLO.Window('LootWnd').Open() end)
    if not mq.TLO.Window('LootWnd').Open() then
        if mq.TLO.Target.CleanName() ~= nil then
            RGMercsLogger.log_warn(('Can\'t loot %s right now'):format(mq.TLO.Target.CleanName()))
            cantLootList[corpseID] = os.time()
        end
        return
    end
    mq.delay(1000, function() return (mq.TLO.Corpse.Items() or 0) > 0 end)
    local items = mq.TLO.Corpse.Items() or 0
    RGMercsLogger.log_debug('Loot window open. Items: %s', items)
    local corpseName = mq.TLO.Corpse.Name()
    if mq.TLO.Window('LootWnd').Open() and items > 0 then
        if mq.TLO.Corpse.DisplayName() == mq.TLO.Me.DisplayName() then
            mq.cmd('/lootall')
            return
        end -- if its our own corpse just loot it.
        local noDropItems = {}
        local loreItems = {}
        local allItems = {}
        for i = 1, items do
            local freeSpace = mq.TLO.Me.FreeInventory()
            local corpseItem = mq.TLO.Corpse.Item(i)
            local itemLink = corpseItem.ItemLink('CLICKABLE')()
            if corpseItem() then
                local itemRule, qKeep, newRule = loot.getRule(corpseItem)
                local stackable = corpseItem.Stackable()
                local freeStack = corpseItem.FreeStack()
                if corpseItem.Lore() then
                    local haveItem = mq.TLO.FindItem(('=%s'):format(corpseItem.Name()))()
                    local haveItemBank = mq.TLO.FindItemBank(('=%s'):format(corpseItem.Name()))()
                    if haveItem or haveItemBank or freeSpace <= loot.SaveBagSlots then
                        table.insert(loreItems, itemLink)
                        loot.lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
                    elseif corpseItem.NoDrop() then
                        if loot.LootNoDrop then
                            if not newRule or (newRule and loot.LootNoDropNew) then
                                loot.lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                            end
                        else
                            table.insert(noDropItems, itemLink)
                            loot.lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
                        end
                    else
                        loot.lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                    end
                elseif corpseItem.NoDrop() then
                    if loot.LootNoDrop then
                        if not newRule or (newRule and loot.LootNoDropNew) then
                            loot.lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                        end
                    else
                        table.insert(noDropItems, itemLink)
                        loot.lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
                    end
                elseif freeSpace > loot.SaveBagSlots or (stackable and freeStack > 0) then
                    loot.lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                end
            end
            mq.delay(1)
            if mq.TLO.Cursor() then loot.checkCursor() end
            mq.delay(1)
            if not mq.TLO.Window('LootWnd').Open() then break end
        end
        if loot.ReportLoot and (#noDropItems > 0 or #loreItems > 0) then
            local skippedItems = '/%s Skipped loots (%s - %s) '
            for _, noDropItem in ipairs(noDropItems) do
                skippedItems = skippedItems .. ' ' .. noDropItem .. ' (nodrop) '
            end
            for _, loreItem in ipairs(loreItems) do
                skippedItems = skippedItems .. ' ' .. loreItem .. ' (lore) '
            end
            mq.cmdf(skippedItems, loot.LootChannel, corpseName, corpseID)
        end
        if #allItems > 0 then
            -- send to self and others running lootnscoot
            lootActor:send({ mailbox = 'looted', }, { ID = corpseID, Items = allItems, LootedAt = mq.TLO.Time(), LootedBy = eqChar, })
            -- send to standalone looted gui
            lootActor:send({ mailbox = 'looted', script = 'looted', }, { ID = corpseID, Items = allItems, LootedAt = mq.TLO.Time(), LootedBy = eqChar, })
        end
    end
    if mq.TLO.Cursor() then loot.checkCursor() end
    mq.cmd('/nomodkey /notify LootWnd LW_DoneButton leftmouseup')
    mq.delay(3000, function() return not mq.TLO.Window('LootWnd').Open() end)
    -- if the corpse doesn't poof after looting, there may have been something we weren't able to loot or ignored
    -- mark the corpse as not lootable for a bit so we don't keep trying
    if mq.TLO.Spawn(('corpse id %s'):format(corpseID))() then
        cantLootList[corpseID] = os.time()
    end
end

function loot.corpseLocked(corpseID)
    if not cantLootList[corpseID] then return false end
    if os.difftime(os.time(), cantLootList[corpseID]) > 60 then
        cantLootList[corpseID] = nil
        return false
    end
    return true
end

function loot.lootMobs(limit)
    loot.CheckBags()
    if areFull then return end
    RGMercsLogger.log_verbose('lootMobs(): Enter lootMobs')
    local deadCount = mq.TLO.SpawnCount(spawnSearch:format('npccorpse', loot.CorpseRadius))()
    RGMercsLogger.log_verbose('lootMobs(): here are %s corpses in range.', deadCount)
    local mobsNearby = mq.TLO.SpawnCount(spawnSearch:format('xtarhater', loot.MobsTooClose))()
    -- options for combat looting or looting disabled
    if deadCount == 0 or ((mobsNearby > 0 or mq.TLO.Me.Combat()) and not loot.CombatLooting) then return false end
    local corpseList = {}
    for i = 1, math.max(deadCount, limit or 0) do
        local corpse = mq.TLO.NearestSpawn(('%d,' .. spawnSearch):format(i, 'npccorpse', loot.CorpseRadius))
        table.insert(corpseList, corpse)
        -- why is there a deity check?
    end
    local didLoot = false
    if #corpseList > 0 then
        RGMercsLogger.log_debug('lootMobs(): Trying to loot %d corpses.', #corpseList)
        for i = 1, #corpseList do
            local corpse = corpseList[i]
            local corpseID = corpse.ID()
            if corpseID and corpseID > 0 and not loot.corpseLocked(corpseID) and (mq.TLO.Navigation.PathLength('spawn id ' .. tostring(corpseID))() or 100) < 60 then
                RGMercsLogger.log_debug('lootMobs(): Moving to corpse ID=' .. tostring(corpseID))
                loot.navToID(corpseID)
                corpse.DoTarget()
                loot.lootCorpse(corpseID)
                didLoot = true
                mq.doevents('InventoryFull')
            end
        end
        RGMercsLogger.log_debug('lootMobs(): Done with corpse list.')
    end
    return didLoot
end

-- SELLING

function loot.eventSell(_, itemName)
    if NEVER_SELL[itemName] then return end
    local firstLetter = itemName:sub(1, 1):upper()
    if lootData[firstLetter] and lootData[firstLetter][itemName] == 'Sell' then return end
    if loot.lookupIniLootRule(firstLetter, itemName) == 'Sell' then
        lootData[firstLetter] = lootData[firstLetter] or {}
        lootData[firstLetter][itemName] = 'Sell'
        return
    end
    if loot.AddNewSales then
        RGMercsLogger.log_info(string.format('Setting %s to Sell', itemName))
        if not lootData[firstLetter] then lootData[firstLetter] = {} end
        lootData[firstLetter][itemName] = 'Sell'
        mq.cmdf('/ini "%s" "%s" "%s" "%s"', loot.LootFile, firstLetter, itemName, 'Sell')
    end
end

function loot.goToVendor()
    if not mq.TLO.Target() then
        RGMercsLogger.log_warn('Please target a vendor')
        return false
    end
    local vendorName = mq.TLO.Target.CleanName()

    RGMercsLogger.log_info('Doing business with ' .. vendorName)
    if mq.TLO.Target.Distance() > 15 then
        loot.navToID(mq.TLO.Target.ID())
    end
    return true
end

function loot.openVendor()
    RGMercsLogger.log_debug('Opening merchant window')
    mq.cmd('/nomodkey /click right target')
    RGMercsLogger.log_debug('Waiting for merchant window to populate')
    mq.delay(1000, function() return mq.TLO.Window('MerchantWnd').Open() end)
    if not mq.TLO.Window('MerchantWnd').Open() then return false end
    mq.delay(5000, function() return mq.TLO.Merchant.ItemsReceived() end)
    return mq.TLO.Merchant.ItemsReceived()
end

function loot.SellToVendor(itemToSell, bag, slot)
    if NEVER_SELL[itemToSell] then return end
    if mq.TLO.Window('MerchantWnd').Open() then
        RGMercsLogger.log_info('Selling ' .. itemToSell)
        if slot == nil or slot == -1 then
            mq.cmdf('/nomodkey /itemnotify %s leftmouseup', bag)
        else
            mq.cmdf('/nomodkey /itemnotify in pack%s %s leftmouseup', bag, slot)
        end
        mq.delay(1000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == itemToSell end)
        mq.cmd('/nomodkey /shiftkey /notify merchantwnd MW_Sell_Button leftmouseup')
        mq.doevents('eventNovalue')
        if itemNoValue == itemToSell then
            loot.addRule(itemToSell, itemToSell:sub(1, 1), 'Ignore')
            itemNoValue = nil
        end
        -- TODO: handle vendor not wanting item / item can't be sold
        mq.delay(1000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == '' end)
    end
end

-- BUYING

function loot.RestockItems()
    local rowNum = 0
    for itemName, qty in pairs(BuyItems) do
        rowNum = mq.TLO.Window("MerchantWnd/MW_ItemList").List(itemName, 2)() or 0
        mq.delay(20)
        local tmpQty = qty - mq.TLO.FindItemCount(itemName)()
        if rowNum ~= 0 and tmpQty > 0 then
            mq.TLO.Window("MerchantWnd/MW_ItemList").Select(rowNum)()
            mq.delay(100)
            mq.TLO.Window("MerchantWnd/MW_Buy_Button").LeftMouseUp()
            mq.delay(500, function() return mq.TLO.Window("QuantityWnd").Open() end)
            mq.TLO.Window("QuantityWnd/QTYW_SliderInput").SetText(tostring(tmpQty))()
            mq.delay(100, function() return mq.TLO.Window("QuantityWnd/QTYW_SliderInput").Text() == tostring(tmpQty) end)
            RGMercsLogger.log_info("\agBuying\ay " .. tmpQty .. "\at " .. itemName)
            mq.TLO.Window("QuantityWnd/QTYW_Accept_Button").LeftMouseUp()
            mq.delay(100)
        end
        mq.delay(500, function() return mq.TLO.FindItemCount(itemName)() == qty end)
    end
    -- close window when done buying
    return mq.TLO.Window('MerchantWnd').DoClose()
end

-- TRIBUTEING

function loot.openTribMaster()
    RGMercsLogger.log_debug('Opening Tribute Window')
    mq.cmd('/nomodkey /click right target')
    RGMercsLogger.log_debug('Waiting for Tribute Window to populate')
    mq.delay(1000, function() return mq.TLO.Window('TributeMasterWnd').Open() end)
    if not mq.TLO.Window('TributeMasterWnd').Open() then return false end
    return mq.TLO.Window('TributeMasterWnd').Open()
end

function loot.eventTribute(line, itemName)
    local firstLetter = itemName:sub(1, 1):upper()
    if lootData[firstLetter] and lootData[firstLetter][itemName] == 'Tribute' then return end
    if loot.lookupIniLootRule(firstLetter, itemName) == 'Tribute' then
        lootData[firstLetter] = lootData[firstLetter] or {}
        lootData[firstLetter][itemName] = 'Tribute'
        return
    end
    if loot.AddNewTributes then
        RGMercsLogger.log_info(string.format('Setting %s to Tribute', itemName))
        if not lootData[firstLetter] then lootData[firstLetter] = {} end
        lootData[firstLetter][itemName] = 'Tribute'
        mq.cmdf('/ini "%s" "%s" "%s" "%s"', loot.LootFile, firstLetter, itemName, 'Tribute')
    end
end

function loot.TributeToVendor(itemToTrib, bag, slot)
    if NEVER_SELL[itemToTrib.Name()] then return end
    if mq.TLO.Window('TributeMasterWnd').Open() then
        RGMercsLogger.log_info('Tributeing ' .. itemToTrib.Name())
        loot.report('\ayTributing \at%s \axfor\ag %s \axpoints!', itemToTrib.Name(), itemToTrib.Tribute())
        mq.cmdf('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
        mq.delay(1) -- progress frame

        mq.delay(5000, function()
            return mq.TLO.Window('TributeMasterWnd').Child('TMW_ValueLabel').Text() == tostring(itemToTrib.Tribute()) and
                mq.TLO.Window('TributeMasterWnd').Child('TMW_DonateButton').Enabled()
        end)

        mq.TLO.Window('TributeMasterWnd').Child('TMW_DonateButton').LeftMouseUp()
        mq.delay(1)
        mq.delay(5000, function() return not mq.TLO.Window('TributeMasterWnd').Child('TMW_DonateButton').Enabled() end)
        mq.delay(1000) -- This delay is necessary because there is seemingly a delay between donating and selecting the next item.
    end
end

-- CLEANUP

function loot.DestroyItem(itemToDestroy, bag, slot)
    if NEVER_SELL[itemToDestroy.Name()] then return end
    RGMercsLogger.log_info('!!Destroying!! ' .. itemToDestroy.Name())
    mq.cmdf('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
    mq.delay(1) -- progress frame
    mq.cmdf('/destroy')
    mq.delay(1)
    mq.delay(1000, function() return not mq.TLO.Cursor() end)
    mq.delay(1)
end

-- BANKING

function loot.markTradeSkillAsBank()
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                if bagSlot.Tradeskills() then
                    local itemToMark = bagSlot.Name()
                    loot.addRule(itemToMark, itemToMark:sub(1, 1), 'Bank')
                end
            end
        end
    end
    -- sell any items in bags which are marked as sell
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        local containerSize = bagSlot.Container()
        if containerSize and containerSize > 0 then
            for j = 1, containerSize do
                local item = bagSlot.Item(j)
                if item.ID() and item.Tradeskills() then
                    local itemToMark = bagSlot.Item(j).Name()
                    loot.addRule(itemToMark, itemToMark:sub(1, 1), 'Bank')
                end
            end
        end
    end
end

function loot.bankItem(itemName, bag, slot)
    if not slot or slot == -1 then
        mq.cmdf('/shift /itemnotify %s leftmouseup', bag)
    else
        mq.cmdf('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
    end
    mq.delay(100, function() return mq.TLO.Cursor() end)
    mq.cmd('/notify BigBankWnd BIGB_AutoButton leftmouseup')
    mq.delay(100, function() return not mq.TLO.Cursor() end)
end

-- FORAGING

function loot.eventForage()
    RGMercsLogger.log_debug('Enter eventForage')
    -- allow time for item to be on cursor incase message is faster or something?
    mq.delay(1000, function() return mq.TLO.Cursor() end)
    -- there may be more than one item on cursor so go until its cleared
    while mq.TLO.Cursor() do
        local cursorItem = mq.TLO.Cursor
        local foragedItem = cursorItem.Name()
        local forageRule = loot.split(loot.getRule(cursorItem))
        local ruleAction = forageRule[1] -- what to do with the item
        local ruleAmount = forageRule[2] -- how many of the item should be kept
        local currentItemAmount = mq.TLO.FindItemCount('=' .. foragedItem)()
        -- >= because .. does finditemcount not count the item on the cursor?
        if not shouldLootActions[ruleAction] or (ruleAction == 'Quest' and currentItemAmount >= ruleAmount) then
            if mq.TLO.Cursor.Name() == foragedItem then
                if loot.LootForageSpam then RGMercsLogger.log_info('Destroying foraged item ' .. foragedItem) end
                mq.cmd('/destroy')
                mq.delay(500)
            end
            -- will a lore item we already have even show up on cursor?
            -- free inventory check won't cover an item too big for any container so may need some extra check related to that?
        elseif (shouldLootActions[ruleAction] or currentItemAmount < ruleAmount) and (not cursorItem.Lore() or currentItemAmount == 0) and (mq.TLO.Me.FreeInventory() or (cursorItem.Stackable() and cursorItem.FreeStack())) then
            if loot.LootForageSpam then RGMercsLogger.log_info('Keeping foraged item ' .. foragedItem) end
            mq.cmd('/autoinv')
        else
            if loot.LootForageSpam then RGMercsLogger.log_warn('Unable to process item ' .. foragedItem) end
            break
        end
        mq.delay(50)
    end
end

-- Process Items

function loot.processItems(action)
    local flag = false
    local totalPlat = 0

    local function processItem(item, action, bag, slot)
        local rule = loot.getRule(item)
        if rule == action then
            if action == 'Sell' then
                if not mq.TLO.Window('MerchantWnd').Open() then
                    if not loot.goToVendor() then return end
                    if not loot.openVendor() then return end
                end
                --totalPlat = mq.TLO.Me.Platinum()
                local sellPrice = item.Value() and item.Value() / 1000 or 0
                if sellPrice == 0 then
                    RGMercsLogger.log_warn(string.format('Item \ay%s\ax is set to Sell but has no sell value!', item.Name()))
                else
                    loot.SellToVendor(item.Name(), bag, slot)
                    totalPlat = totalPlat + sellPrice
                    mq.delay(1)
                end
            elseif action == 'Tribute' then
                if not mq.TLO.Window('TributeMasterWnd').Open() then
                    if not loot.goToVendor() then return end
                    if not loot.openTribMaster() then return end
                end
                mq.cmd('/keypress OPEN_INV_BAGS')
                mq.delay(1)
                -- tributes requires the bags to be open
                mq.delay(1000, loot.AreBagsOpen)
                mq.delay(1)
                loot.TributeToVendor(item, bag, slot)
                mq.delay(1)
            elseif action == 'Destroy' then
                loot.DestroyItem(item, bag, slot)
                mq.delay(1)
            elseif action == 'Bank' then
                if not mq.TLO.Window('BigBankWnd').Open() then
                    RGMercsLogger.log_warn('Bank window must be open!')
                    return
                end
                loot.bankItem(item.Name(), bag, slot)
                mq.delay(1)
            end
        end
    end

    if loot.AlwaysEval then
        flag, loot.AlwaysEval = true, false
    end

    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        local containerSize = bagSlot.Container()

        if containerSize then
            for j = 1, containerSize do
                local item = bagSlot.Item(j)
                if item.ID() then
                    if action == 'Cleanup' then
                        processItem(item, 'Destroy', i, j)
                    elseif action == 'Sell' then
                        processItem(item, 'Sell', i, j)
                    elseif action == 'Tribute' then
                        processItem(item, 'Tribute', i, j)
                    elseif action == 'Bank' then
                        processItem(item, 'Bank', i, j)
                    end
                end
            end
        end
    end
    if action == 'Sell' and loot.AutoRestock then
        loot.RestockItems()
    end
    if action == 'Buy' then
        if not mq.TLO.Window('MerchantWnd').Open() then
            if not loot.goToVendor() then return end
            if not loot.openVendor() then return end
        end
        loot.RestockItems()
    end

    if flag then
        flag, loot.AlwaysEval = false, true
    end

    if action == 'Tribute' then
        mq.flushevents('Tribute')
        if mq.TLO.Window('TributeMasterWnd').Open() then
            mq.TLO.Window('TributeMasterWnd').DoClose()
            mq.delay(1)
        end
        mq.cmd('/keypress CLOSE_INV_BAGS')
        mq.delay(1)
    elseif action == 'Sell' then
        if mq.TLO.Window('MerchantWnd').Open() then
            mq.TLO.Window('MerchantWnd').DoClose()
            mq.delay(1)
        end
        mq.delay(1)
        totalPlat = math.floor(totalPlat)
        loot.report('Total plat value sold: \ag%s\ax', totalPlat)
    elseif action == 'Bank' then
        if mq.TLO.Window('BigBankWnd').Open() then
            mq.TLO.Window('BigBankWnd').DoClose()
            mq.delay(1)
        end
    end

    loot.CheckBags()
end

-- Legacy functions for backward compatibility

function loot.sellStuff()
    loot.processItems('Sell')
end

function loot.bankStuff()
    loot.processItems('Bank')
end

function loot.cleanupBags()
    loot.processItems('Cleanup')
end

function loot.tributeStuff()
    loot.processItems('Tribute')
end

function loot.guiExport()
    -- Define a new menu element function
    local function customMenu()
        if ImGui.BeginMenu('Loot N Scoot') then
            -- Add menu items here
            if ImGui.BeginMenu('Toggles') then
                -- Add menu items here
                _, loot.DoLoot = ImGui.MenuItem("DoLoot", nil, loot.DoLoot)
                if _ then loot.writeSettings() end
                _, loot.GlobalLootOn = ImGui.MenuItem("GlobalLootOn", nil, loot.GlobalLootOn)
                if _ then loot.writeSettings() end
                _, loot.CombatLooting = ImGui.MenuItem("CombatLooting", nil, loot.CombatLooting)
                if _ then loot.writeSettings() end
                _, loot.LootNoDrop = ImGui.MenuItem("LootNoDrop", nil, loot.LootNoDrop)
                if _ then loot.writeSettings() end
                _, loot.LootNoDropNew = ImGui.MenuItem("LootNoDropNew", nil, loot.LootNoDropNew)
                if _ then loot.writeSettings() end
                _, loot.LootForage = ImGui.MenuItem("LootForage", nil, loot.LootForage)
                if _ then loot.writeSettings() end
                _, loot.LootQuest = ImGui.MenuItem("LootQuest", nil, loot.LootQuest)
                if _ then loot.writeSettings() end
                _, loot.TributeKeep = ImGui.MenuItem("TributeKeep", nil, loot.TributeKeep)
                if _ then loot.writeSettings() end
                _, loot.BankTradeskills = ImGui.MenuItem("BankTradeskills", nil, loot.BankTradeskills)
                if _ then loot.writeSettings() end
                _, loot.StackableOnly = ImGui.MenuItem("StackableOnly", nil, loot.StackableOnly)
                if _ then loot.writeSettings() end
                ImGui.Separator()
                _, loot.AlwaysEval = ImGui.MenuItem("AlwaysEval", nil, loot.AlwaysEval)
                if _ then loot.writeSettings() end
                _, loot.AddNewSales = ImGui.MenuItem("AddNewSales", nil, loot.AddNewSales)
                if _ then loot.writeSettings() end
                _, loot.AddNewTributes = ImGui.MenuItem("AddNewTributes", nil, loot.AddNewTributes)
                if _ then loot.writeSettings() end
                _, loot.AutoTag = ImGui.MenuItem("AutoTagSell", nil, loot.AutoTag)
                if _ then loot.writeSettings() end
                _, loot.AutoRestock = ImGui.MenuItem("AutoRestock", nil, loot.AutoRestock)
                if _ then loot.writeSettings() end
                ImGui.Separator()
                _, loot.DoDestroy = ImGui.MenuItem("DoDestroy", nil, loot.DoDestroy)
                if _ then loot.writeSettings() end
                _, loot.AlwaysDestroy = ImGui.MenuItem("AlwaysDestroy", nil, loot.AlwaysDestroy)
                if _ then loot.writeSettings() end

                ImGui.EndMenu()
            end
            if ImGui.BeginMenu('Group Commands') then
                -- Add menu items here
                if ImGui.MenuItem("Sell Stuff##group") then
                    mq.cmd(string.format('/%s /rgl sell', tmpCmd))
                end

                if ImGui.MenuItem('Restock Items##group') then
                    mq.cmd(string.format('/%s /rgl buy', tmpCmd))
                end

                if ImGui.MenuItem("Tribute Stuff##group") then
                    mq.cmd(string.format('/%s /rgl tribute', tmpCmd))
                end

                if ImGui.MenuItem("Bank##group") then
                    mq.cmd(string.format('/%s /rgl bank', tmpCmd))
                end

                if ImGui.MenuItem("Cleanup##group") then
                    mq.cmd(string.format('/%s /rgl cleanbags', tmpCmd))
                end

                ImGui.Separator()

                if ImGui.MenuItem("Reload##group") then
                    mq.cmd(string.format('/%s /rgl lootreload', tmpCmd))
                end

                ImGui.EndMenu()
            end
            if ImGui.MenuItem('Sell Stuff') then
                mq.cmd('/rgl sell')
            end

            if ImGui.MenuItem('Restock') then
                mq.cmd('/rgl buy')
            end

            if ImGui.MenuItem('Tribute Stuff') then
                mq.cmd('/rgl tribute')
            end

            if ImGui.MenuItem('Bank') then
                mq.cmd('/rgl bank')
            end

            if ImGui.MenuItem('Cleanup') then
                mq.cmd('/rgl cleanbags')
            end

            ImGui.Separator()

            if ImGui.MenuItem('Reload') then
                mq.cmd('/rgl lootreload')
            end

            ImGui.Separator()

            if ImGui.MenuItem('Exit LNS') then
                loot.Terminate = true
            end

            ImGui.EndMenu()
        end
    end
    -- Add the custom menu element function to the importGUIElements table
    if loot.guiLoot ~= nil then table.insert(loot.guiLoot.importGUIElements, customMenu) end
end

function loot.init()
    local iniFile = mq.TLO.Ini.File(SettingsFile)
    if not (iniFile.Exists() and iniFile.Section('Settings').Exists()) then
        loot.writeSettings()
    else
        loot.loadSettings()
    end
    loot.CheckBags()
    loot.setupEvents()
    loot.setupBinds()
    loot.guiExport()
end

loot.init()

if loot.guiLoot ~= nil then
    loot.guiLoot.GetSettings(loot.HideNames, loot.LookupLinks, loot.RecordData, true, loot.UseActors, 'lootnscoot')
    loot.guiLoot.init(true, true, 'lootnscoot')
end
return loot
