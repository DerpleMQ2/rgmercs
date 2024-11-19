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

local mq           = require 'mq'
local Logger       = require("utils.logger")
local SQLite3      = require('lsqlite3')

local eqServer     = string.gsub(mq.TLO.EverQuest.Server(), ' ', '_')
-- Check for looted module, if found use that. else fall back on our copy, which may be outdated.

local Config       = require('utils.config')
local Core         = require("utils.core")
local Comms        = require("utils.comms")
local Targeting    = require("utils.targeting")
local Files        = require("utils.files")
local Modules      = require("utils.modules")
local SettingsFile = mq.configDir .. '/LootNScoot_' .. eqServer .. '_' .. Config.Globals.CurLoadedChar .. '.ini'
local LootFile     = mq.configDir .. '/Loot.ini'
local version      = 1.9
local imported     = true
-- Public default settings, also read in from Loot.ini [Settings] section
local loot         = {
    Settings = {
        Version = '"' .. tostring(version) .. '"',
        LootFile = mq.configDir .. '/Loot.ini',
        SettingsFile = mq.configDir .. '/LootNScoot_' .. eqServer .. '_' .. Config.Globals.CurLoadedChar .. '.ini',
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
        LootMyCorpse = false,                      -- Loot your own corpse if its nearby (Does not check for REZ)
    },
}
loot.MyClass       = Config.Globals.CurLoadedClass:lower()
-- SQL information
local ItemsDB      = string.format('%s/LootRules_%s.db', mq.configDir, eqServer)

loot.guiLoot       = require('lib.lootnscoot.loot_hist')
if loot.guiLoot ~= nil then
    loot.UseActors = true
    loot.guiLoot.GetSettings(loot.HideNames, loot.LookupLinks, loot.RecordData, true, loot.UseActors, 'lootnscoot')
end

-- Internal settings
local lootData, cantLootList = {}, {}
local areFull = false
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
loot.BuyItems = {}
loot.GlobalItems = {}
loot.NormalItems = {}
loot.NormalItemsClasses = {}
loot.GlobalItemsClasses = {}
-- FORWARD DECLARATIONS

-- local loot.eventForage, loot.eventSell, loot.eventCantLoot, loot.eventTribute, loot.eventNoSlot

-- UTILITIES
--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function loot.load(fileName, sec)
    if sec == nil then sec = "items" end
    -- this came from Knightly's LIP.lua
    assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
    local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
    local data = {};
    local section;
    local count = 0
    for line in file:lines() do
        local tempSection = line:match('^%[([^%[%]]+)%]$');
        if (tempSection) then
            -- print(tempSection)
            section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
            -- data[section] = data[section] or {};
            count = 0
        end
        local param, value = line:match("^([%w|_'.%s-]+)=%s-(.+)$");

        if (param and value ~= nil) then
            if (tonumber(value)) then
                value = tonumber(value);
            elseif (value == 'true') then
                value = true;
            elseif (value == 'false') then
                value = false;
            end
            if (tonumber(param)) then
                param = tonumber(param);
            end
            if string.find(tostring(param), 'Spawn') then
                count = count + 1
                param = string.format("Spawn%d", count)
            end
            if sec == "items" and param ~= nil then
                if section ~= "Settings" and section ~= "GlobalItems" then
                    data[param] = value;
                end
            elseif section == sec and param ~= nil then
                data[param] = value;
            end
        end
    end
    file:close();
    Logger.log_debug("Loot::load()")
    return data;
end

function loot.writeSettings()
    for option, value in pairs(loot.Settings) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            Core.DoCmd('/ini "%s" "%s" "%s" "%s"', SettingsFile, 'Settings', option, value)
            loot.Settings[option] = value
        end
    end
    for option, value in pairs(loot.BuyItems) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            Core.DoCmd('/ini "%s" "%s" "%s" "%s"', SettingsFile, 'BuyItems', option, value)
            loot.BuyItems[option] = value
        end
    end
    for option, value in pairs(loot.GlobalItems) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            Core.DoCmd('/ini "%s" "%s" "%s" "%s"', LootFile, 'GlobalItems', option, value)
            loot.modifyItem(option, value, 'Global_Rules')
            loot.GlobalItems[option] = value
        end
    end
    Logger.log_debug("Loot::writeSettings()")
    Modules:ExecModule("Loot", "ModifyLootSettings")
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

function loot.UpdateDB()
    loot.NormalItems = loot.load(LootFile, 'items')
    loot.GlobalItems = loot.load(LootFile, 'GlobalItems')

    local db = SQLite3.open(ItemsDB)
    local batchSize = 500
    local count = 0

    db:exec("BEGIN TRANSACTION") -- Start transaction for NormalItems

    -- Insert NormalItems in batches
    for k, v in pairs(loot.NormalItems) do
        local stmt, err = db:prepare("INSERT INTO Normal_Rules (item_name, item_rule) VALUES (?, ?)")
        stmt:bind_values(k, v)
        stmt:step()
        stmt:finalize()

        count = count + 1
        if count % batchSize == 0 then
            Logger.log_debug("Inserted " .. count .. " NormalItems so far...")
            db:exec("COMMIT")
            db:exec("BEGIN TRANSACTION")
        end
    end

    db:exec("COMMIT")
    Logger.log_debug("Inserted all " .. count .. " NormalItems.")

    -- Reset counter for GlobalItems
    count = 0

    db:exec("BEGIN TRANSACTION")

    -- Insert GlobalItems in batches
    for k, v in pairs(loot.GlobalItems) do
        local stmt, err = db:prepare("INSERT INTO Global_Rules (item_name, item_rule) VALUES (?, ?)")
        stmt:bind_values(k, v)
        stmt:step()
        stmt:finalize()

        count = count + 1
        if count % batchSize == 0 then
            Logger.log_debug("Inserted " .. count .. " GlobalItems so far...")
            db:exec("COMMIT")
            db:exec("BEGIN TRANSACTION")
        end
    end

    db:exec("COMMIT")
    Logger.log_debug("Inserted all " .. count .. " GlobalItems.")
    db:close()
end

function loot.loadSettings()
    loot.NormalItems = {}
    loot.GlobalItems = {}
    loot.NormalItemsClasses = {}
    loot.GlobalItemsClasses = {}
    -- SQL setup
    if not Files.file_exists(ItemsDB) then
        Logger.log_warn("\ayLoot Rules Database \arNOT found\ax, \atCreating it now\ax. Please run \at/rgl lootimport\ax to Import your \atloot.ini \axfile.")
        Logger.log_warn("\arOnly run this one One Character\ax. use \at/rgl lootreload\ax to update the data on the other characters.")
    else
        Logger.log_info("Loot Rules Database found, loading it now.")
    end
    -- Create the database and its table if it doesn't exist
    local db = SQLite3.open(ItemsDB)
    db:exec([[
                CREATE TABLE IF NOT EXISTS Global_Rules (
                "item_name" TEXT NOT NULL UNIQUE,
                "item_rule" TEXT NOT NULL,
                "item_classes" TEXT,
                "id" INTEGER PRIMARY KEY AUTOINCREMENT
            );
                CREATE TABLE IF NOT EXISTS Normal_Rules (
                "item_name" TEXT NOT NULL UNIQUE,
                "item_rule" TEXT NOT NULL,
                "item_classes" TEXT,
                "id" INTEGER PRIMARY KEY AUTOINCREMENT
            );
        ]])
    db:close()

    local db = SQLite3.open(ItemsDB)
    local stmt = db:prepare("SELECT * FROM Global_Rules")
    for row in stmt:nrows() do
        loot.GlobalItems[row.item_name] = row.item_rule
        loot.GlobalItemsClasses[row.item_name] = row.item_classes ~= nil and row.item_classes or 'All'
    end
    stmt:finalize()
    stmt = db:prepare("SELECT * FROM Normal_Rules")
    for row in stmt:nrows() do
        loot.NormalItems[row.item_name] = row.item_rule
        loot.NormalItemsClasses[row.item_name] = row.item_classes ~= nil and row.item_classes or 'All'
    end
    stmt:finalize()
    db:close()

    local tmpSettings = loot.load(SettingsFile, 'Settings')
    local needSave = false
    for k, v in pairs(loot.Settings) do
        if tmpSettings[k] == nil then
            tmpSettings[k] = loot.Settings[k]
            needSave = true
        end
    end
    tmpCmd = loot.Settings.GroupChannel or 'dgae'
    if tmpCmd == string.find(tmpCmd, 'dg') then
        tmpCmd = '/' .. tmpCmd
    elseif tmpCmd == string.find(tmpCmd, 'bc') then
        tmpCmd = '/' .. tmpCmd .. ' /'
    end
    shouldLootActions.Destroy = loot.Settings.DoDestroy
    shouldLootActions.Tribute = loot.Settings.TributeKeep
    loot.BuyItems = loot.load(SettingsFile, 'BuyItems')

    return needSave
end

function loot.checkCursor()
    local currentItem = nil
    while mq.TLO.Cursor() do
        -- can't do anything if there's nowhere to put the item, either due to no free inventory space
        -- or no slot of appropriate size
        if mq.TLO.Me.FreeInventory() == 0 or mq.TLO.Cursor() == currentItem then
            if loot.Settings.SpamLootInfo then Logger.log_debug('Inventory full, item stuck on cursor') end
            Core.DoCmd('/autoinv')
            return
        end
        currentItem = mq.TLO.Cursor()
        Core.DoCmd('/autoinv')
        mq.delay(100)
    end
end

function loot.navToID(spawnID)
    Core.DoCmd('/nav id %d log=off', spawnID)
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

function loot.modifyItem(item, action, tableName, classes)
    local db = SQLite3.open(ItemsDB)
    if not db then
        Logger.log_warn("Failed to open database.")
        return
    end
    if action == 'delete' then
        local stmt, err = db:prepare("DELETE FROM " .. tableName .. " WHERE item_name = ?")
        if not stmt then
            Logger.log_warn("Failed to prepare statement: %s", err)
            db:close()
            return
        end
        stmt:bind_values(item)
        stmt:step()
        stmt:finalize()
    else
        if classes == nil then
            local sql = string.format(
                [[
            INSERT OR REPLACE INTO %s (item_name, item_rule)
            VALUES (?, ?)
            ]], tableName)

            local stmt, err = db:prepare(sql)
            if not stmt then
                Logger.log_warn("Failed to prepare statement: %s\nSQL: %s", err, sql)
                db:close()
                return
            end
            stmt:bind_values(item, action)
            stmt:step()
            stmt:finalize()
        else
            local sql = string.format([[
            INSERT OR REPLACE INTO %s (item_name, item_rule, item_classes)
            VALUES (?, ?, ?)
        ]], tableName)

            local stmt, err = db:prepare(sql)
            if not stmt then
                Logger.log_warn("Failed to prepare statement: %s\nSQL: %s", err, sql)
                db:close()
                return
            end
            stmt:bind_values(item, action, classes)
            stmt:step()
            stmt:finalize()
        end
    end

    db:close()
end

function loot.addRule(itemName, section, rule, classes)
    if not lootData[section] then
        lootData[section] = {}
    end
    Logger.log_info('item %s section %s rule %s, classes %s', itemName, section, rule, (classes ~= nil and classes or 'All'))
    lootData[section][itemName] = rule
    if section == 'GlobalItems' then
        loot.GlobalItems[itemName] = rule
        loot.modifyItem(itemName, rule, 'Global_Rules', classes)
    else
        loot.NormalItems[itemName] = rule
        loot.modifyItem(itemName, rule, 'Normal_Rules', classes)
    end
    loot.lootActor:send({ mailbox = 'lootnscoot', }, { who = Config.Globals.CurLoadedChar, action = 'addrule', item = itemName, rule = rule, section = section, })

    Core.DoCmd('/ini "%s" "%s" "%s" "%s"', LootFile, section, itemName, rule)
    Modules:ExecModule("Loot", "ModifyLootSettings")
end

function loot.lookupLootRule(section, key)
    if key == nil then return 'NULL', 'All' end
    local db = SQLite3.open(ItemsDB)
    local sql = "SELECT item_rule FROM Normal_Rules WHERE item_name = ?"
    local stmt = db:prepare(sql)

    if not stmt then
        db:close()
        return 'NULL', 'All'
    end

    stmt:bind_values(key)
    local stepResult = stmt:step()

    local rule = 'NULL'
    local classes = 'All'
    if stepResult == SQLite3.ROW then
        local row = stmt:get_named_values()
        rule = row.item_rule or 'NULL'
        classes = row.item_classes or 'All'
    end

    stmt:finalize()
    db:close()
    return rule, classes
end

-- moved this function up so we can report Quest Items.
local reportPrefix = '/%s \a-t[\at%s\a-t][\ax\ayLootUtils\ax\a-t]\ax '
function loot.report(message, ...)
    if loot.Settings.ReportLoot then
        local prefixWithChannel = reportPrefix:format(loot.Settings.LootChannel, mq.TLO.Time())
        Core.DoCmd(prefixWithChannel .. message, ...)
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
function loot.getRule(item, from)
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
    local globalItem = loot.GlobalItems[itemName] ~= nil and loot.GlobalItems[itemName] or 'NULL'
    globalItem = loot.BuyItems[itemName] ~= nil and 'Keep' or globalItem
    local globalClasses = loot.GlobalItemsClasses[itemName] ~= nil and loot.GlobalItemsClasses[itemName] or 'All'
    local newRule = false
    local lootClasses = 'All'
    lootData[firstLetter] = lootData[firstLetter] or {}
    lootData[firstLetter][itemName], lootClasses = loot.lookupLootRule(firstLetter, itemName)
    -- Re-Evaluate the settings if AlwaysEval is on. Items that do not meet the Characters settings are reset to NUll and re-evaluated as if they were new items.
    if loot.Settings.AlwaysEval then
        local oldDecision = lootData[firstLetter][itemName] -- whats on file
        local resetDecision = 'NULL'
        if string.find(oldDecision, 'Quest') or oldDecision == 'Keep' or oldDecision == 'Destroy' then resetDecision = oldDecision end
        -- If sell price changed and item doesn't meet the new value re-evalute it otherwise keep it set to sell
        if oldDecision == 'Sell' and not stackable and sellPrice >= loot.Settings.MinSellPrice then resetDecision = oldDecision end
        -- -- Do the same for stackable items.
        if (oldDecision == 'Sell' and stackable) and (sellPrice * stackSize >= loot.Settings.StackPlatValue) then resetDecision = oldDecision end
        -- if banking tradeskills settings changed re-evaluate
        if oldDecision == 'Bank' and tradeskill and loot.Settings.BankTradeskills then resetDecision = oldDecision end
        lootData[firstLetter][itemName] = resetDecision -- pass value on to next check. Items marked 'NULL' will be treated as new and evaluated properly.
    end
    if lootData[firstLetter][itemName] == 'NULL' then
        if tradeskill and loot.Settings.BankTradeskills then lootDecision = 'Bank' end
        if not stackable and sellPrice < loot.Settings.MinSellPrice then lootDecision = 'Ignore' end -- added stackable check otherwise it would stay set to Ignore when checking Stackable items in next steps.
        if not stackable and loot.Settings.StackableOnly then lootDecision = 'Ignore' end
        if (stackable and loot.Settings.StackPlatValue > 0) and (sellPrice * stackSize < loot.Settings.StackPlatValue) then lootDecision = 'Ignore' end
        -- set Tribute flag if tribute value is greater than minTributeValue and the sell price is less than min sell price or has no value
        if tributeValue >= loot.Settings.MinTributeValue and (sellPrice < loot.Settings.MinSellPrice or sellPrice == 0) then lootDecision = 'Tribute' end
        loot.addRule(itemName, firstLetter, lootDecision)
        if loot.Settings.AutoTag and lootDecision == 'Keep' then                                       -- Do we want to automatically tag items 'Sell'
            if not stackable and sellPrice > loot.Settings.MinSellPrice then lootDecision = 'Sell' end -- added stackable check otherwise it would stay set to Ignore when checking Stackable items in next steps.
            if (stackable and loot.Settings.StackPlatValue > 0) and (sellPrice * stackSize >= loot.Settings.StackPlatValue) then lootDecision = 'Sell' end
            loot.addRule(itemName, firstLetter, lootDecision)
        end
        newRule = true
    end

    -- check this before quest item checks. so we have the proper rule to compare.
    -- Check if item is on global Items list, ignore everything else and use those rules insdead.
    local globalFound = false
    local globalClassSkip = false
    if loot.Settings.GlobalLootOn and globalItem ~= 'NULL' then
        if globalClasses:lower() ~= 'all' and from == 'loot' then
            if string.find(globalClasses:lower(), loot.MyClass) then
                lootData[firstLetter][itemName] = globalItem or lootData[firstLetter][itemName]
                Logger.log_info("Item \at%s\ax is \agIN GlobalItem \axclass list \ay%s", itemName, globalClasses)
            else
                lootData[firstLetter][itemName] = 'Ignore'
                Logger.log_info("Item \at%s\ax \arNOT in GlobalItem \axclass list \ay%s", itemName, globalClasses)
                globalClassSkip = true
            end
        else
            lootData[firstLetter][itemName] = globalItem or lootData[firstLetter][itemName]
        end
        globalFound = true
    end
    -- Check if item marked Quest
    if string.find(lootData[firstLetter][itemName], 'Quest') then
        local qVal = 'Ignore'
        -- do we want to loot quest items?
        if loot.Settings.LootQuest then
            --look to see if Quantity attached to Quest|qty
            local _, position = string.find(lootData[firstLetter][itemName], '|')
            if position then qKeep = string.sub(lootData[firstLetter][itemName], position + 1) else qKeep = '0' end
            -- if Quantity is tied to the entry then use that otherwise use default Quest Keep Qty.
            if qKeep == '0' then
                qKeep = tostring(loot.Settings.QuestKeep)
            end
            -- If we have less than we want to keep loot it.
            if countHave < tonumber(qKeep) then
                qVal = 'Keep'
            end
            if loot.Settings.AlwaysDestroy and qVal == 'Ignore' then qVal = 'Destroy' end
        end
        return qVal, tonumber(qKeep) or 0
    end

    if loot.Settings.AlwaysDestroy and lootData[firstLetter][itemName] == 'Ignore' and not globalClassSkip then return 'Destroy', 0 end
    -- check Classes
    if lootClasses == nil then lootClasses = 'All' end
    if lootClasses:lower() ~= 'all' and not globalFound and from == 'loot' then
        if string.find(lootClasses:lower(), loot.MyClass) then
            lootDecision = lootData[firstLetter][itemName]
            Logger.log_info("Item \at%s\ax is \agIN \axclass list \ay%s", itemName, lootClasses)
        else
            Logger.log_info("Item \at%s\ax \arNOT in \axclass list \ay%s", itemName, lootClasses)
            lootDecision = 'Ignore'
        end
        return lootDecision, 0, newRule
    end


    return lootData[firstLetter][itemName], 0, newRule
end

-- EVENTS
function loot.RegisterActors()
    loot.lootActor = Comms.Actors.register('lootnscoot', function(message)
        local lootMessage = message()
        local who = lootMessage.who
        local action = lootMessage.action
        if action == 'lootreload' then
            loot.commandHandler('reload')
        end
        if who == Config.Globals.CurLoadedChar then return end
        if action == 'addrule' then
            local item = lootMessage.item
            local rule = lootMessage.rule
            local section = lootMessage.section
            if section == 'GlobalItems' then
                loot.GlobalItems[item] = rule
                loot.GlobalItemsClasses[item] = nil
            else
                loot.NormalItems[item] = rule
                loot.NormalItemsClasses[item] = lootMessage.classes
            end
            Modules:ExecModule("Loot", "ModifyLootSettings")
        elseif action == 'deleteitem' then
            local item = lootMessage.item
            local section = lootMessage.section
            if section == 'GlobalItems' then
                loot.GlobalItems[item] = nil
                loot.GlobalItemsClasses[item] = nil
            else
                loot.NormalItems[item] = nil
                loot.NormalItemsClasses[item] = nil
            end
            Modules:ExecModule("Loot", "ModifyLootSettings")
        elseif action == 'modifyitem' then
            local item = lootMessage.item
            local rule = lootMessage.rule
            local section = lootMessage.section
            if section == 'GlobalItems' then
                loot.GlobalItems[item] = rule
                loot.GlobalItemsClasses[item] = lootMessage.classes
            else
                loot.NormalItems[item] = rule
                loot.NormalItemsClasses[item] = lootMessage.classes
            end
            Modules:ExecModule("Loot", "ModifyLootSettings")
        end
    end)
end

local itemNoValue = nil
function loot.eventNovalue(line, item)
    itemNoValue = item
end

function loot.setupEvents()
    mq.event("CantLoot", "#*#may not loot this corpse#*#", loot.eventCantLoot)
    mq.event("NoSlot", "#*#There are no open slots for the held item in your inventory#*#", loot.eventNoSlot)
    mq.event("Sell", "#*#You receive#*# for the #1#(s)#*#", loot.eventSell)
    -- if loot.Settings.LootForage then
    mq.event("ForageExtras", "Your forage mastery has enabled you to find something else!", loot.eventForage)
    mq.event("Forage", "You have scrounged up #*#", loot.eventForage)
    -- end
    mq.event("Novalue", "#*#give you absolutely nothing for the #1#.#*#", loot.eventNovalue)
    mq.event("Tribute", "#*#We graciously accept your #1# as tribute, thank you!#*#", loot.eventTribute)
end

-- BINDS
function loot.setBuyItem(item, qty)
    loot.BuyItems[item] = qty
    Core.DoCmd('/ini "%s" "BuyItems" "%s" "%s"', SettingsFile, item, qty)
    Modules:ExecModule("Loot", "ModifyLootSettings")
end

function loot.setGlobalItem(item, val, classes)
    loot.GlobalItems[item] = val ~= 'delete' and val or nil
    loot.GlobalItemsClasses[item] = classes or 'All'
    loot.modifyItem(item, val, 'Global_Rules', classes)
    Modules:ExecModule("Loot", "ModifyLootSettings")
end

function loot.ChangeClasses(item, classes, tableName)
    if tableName == 'GlobalItems' then
        loot.GlobalItemsClasses[item] = classes
        loot.modifyItem(item, loot.GlobalItems[item], 'Global_Rules', classes)
    elseif tableName == 'NormalItems' then
        loot.NormalItemsClasses[item] = classes
        loot.modifyItem(item, loot.NormalItems[item], 'Normal_Rules', classes)
    end
    Modules:ExecModule("Loot", "ModifyLootSettings")
end

function loot.setNormalItem(item, val, classes)
    loot.NormalItems[item] = val ~= 'delete' and val or nil
    loot.NormalItemsClasses[item] = classes or 'All'
    loot.modifyItem(item, val, 'Normal_Rules', classes)
    Modules:ExecModule("Loot", "ModifyLootSettings")
end

function loot.setGlobalBind(value)
    loot.setGlobalItem(mq.TLO.Cursor(), value)
end

function loot.commandHandler(...)
    local args = { ..., }
    Logger.log_debug("arg1 %s, arg2 %s, arg3 %s", args[1], args[2], args[3])
    if #args == 1 then
        if args[1] == 'sellstuff' then
            loot.processItems('Sell')
        elseif args[1] == 'restock' then
            loot.processItems('Buy')
        elseif args[1] == 'reload' then
            lootData = {}
            local needSave = loot.loadSettings()
            if needSave then
                loot.writeSettings()
            end
            if loot.guiLoot ~= nil then
                loot.guiLoot.GetSettings(loot.Settings.HideNames, loot.Settings.LookupLinks, loot.Settings.RecordData, true, loot.Settings.UseActors,
                    'lootnscoot')
            end
            Logger.log_info("\ayReloaded Settings \axAnd \atLoot Files")
        elseif args[1] == 'update' then
            lootData = {}
            if loot.guiLoot ~= nil then
                loot.guiLoot.GetSettings(loot.Settings.HideNames, loot.Settings.LookupLinks, loot.Settings.RecordData, true, loot.Settings.UseActors,
                    'lootnscoot')
            end
            loot.UpdateDB()
            Logger.log_info("\ayUpdating the DB from loot.ini \ax and \at Reloading Settings")
        elseif args[1] == 'bankstuff' then
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
            for key, value in pairs(loot.Settings) do
                if type(value) ~= "function" and type(value) ~= "table" then
                    confReport = confReport .. string.format("\n\at%s\ax = \ag%s\ax", key, tostring(value))
                end
            end
            Logger.log_info(confReport)
        elseif args[1] == 'tributestuff' then
            loot.processItems('Tribute')
        elseif args[1] == 'loot' then
            loot.lootMobs()
        elseif args[1] == 'tsbank' then
            loot.markTradeSkillAsBank()
        elseif validActions[args[1]] and mq.TLO.Cursor() then
            loot.addRule(mq.TLO.Cursor(), mq.TLO.Cursor():sub(1, 1):upper(), validActions[args[1]])
            Logger.log_info(string.format("Setting \ay%s\ax to \ay%s\ax", mq.TLO.Cursor(), validActions[args[1]]))
        elseif string.find(args[1], "quest%|") and mq.TLO.Cursor() then
            local val = string.gsub(args[1], "quest", "Quest")
            loot.addRule(mq.TLO.Cursor(), mq.TLO.Cursor():sub(1, 1):upper(), val)
            Logger.log_info(string.format("Setting \ay%s\ax to \ay%s\ax", mq.TLO.Cursor(), val))
        end
    elseif #args == 2 then
        if args[1] == 'quest' and mq.TLO.Cursor() then
            loot.addRule(mq.TLO.Cursor(), mq.TLO.Cursor():sub(1, 1):upper(), 'Quest|' .. args[2])
            Logger.log_info("Setting \ay%s\ax to \ayQuest|%s\ax", mq.TLO.Cursor(), args[2])
        elseif args[1] == 'buy' and mq.TLO.Cursor() then
            loot.BuyItems[mq.TLO.Cursor()] = args[2]
            Core.DoCmd('/ini "%s" "BuyItems" "%s" "%s"', SettingsFile, mq.TLO.Cursor(), args[2])
            Logger.log_info("Setting \ay%s\ax to \ayBuy|%s\ax", mq.TLO.Cursor(), args[2])
        elseif args[1] == 'globalitem' and validActions[args[2]] and mq.TLO.Cursor() then
            loot.GlobalItems[mq.TLO.Cursor()] = validActions[args[2]]
            loot.addRule(mq.TLO.Cursor(), 'GlobalItems', validActions[args[2]])
            Logger.log_info("Setting \ay%s\ax to \agGlobal Item \ay%s\ax", mq.TLO.Cursor(), validActions[args[2]])
        elseif args[1] == 'classes' and mq.TLO.Cursor() then
            loot.ChangeClasses(mq.TLO.Cursor(), args[2], 'NormalItems')
        elseif args[1] == 'gclasses' and mq.TLO.Cursor() then
            loot.ChangeClasses(mq.TLO.Cursor(), args[2], 'GlobalItems')
        elseif validActions[args[1]] and args[2] ~= 'NULL' then
            loot.addRule(args[2], args[2]:sub(1, 1):upper(), validActions[args[1]])
            Logger.log_info("Setting \ay%s\ax to \ay%s\ax", args[2], validActions[args[1]])
        end
    elseif #args == 3 then
        if args[1] == 'globalitem' and args[2] == 'quest' and mq.TLO.Cursor() then
            loot.addRule(mq.TLO.Cursor(), 'GlobalItems', 'Quest|' .. args[3])
            Logger.log_info("Setting \ay%s\ax to \agGlobal Item \ayQuest|%s\ax", mq.TLO.Cursor(), args[3])
        elseif args[1] == 'globalitem' and validActions[args[2]] and args[3] ~= 'NULL' then
            loot.addRule(args[3], 'GlobalItems', validActions[args[2]])
            Logger.log_info("Setting \ay%s\ax to \agGlobal Item \ay%s\ax", args[3], validActions[args[2]])
        elseif args[1] == 'buy' then
            loot.BuyItems[args[2]] = args[3]
            Core.DoCmd('/ini "%s" "BuyItems" "%s" "%s"', SettingsFile, args[2], args[3])
            Logger.log_info("Setting \ay%s\ax to \ayBuy|%s\ax", args[2], args[3])
        elseif args[1] == 'classes' and args[2] ~= 'NULL' and args[3] ~= 'NULL' then
            local item = args[2]
            local classes = args[3]
            loot.ChangeClasses(item, classes, 'NormalItems')
        elseif args[1] == 'gclasses' and args[2] ~= 'NULL' and args[3] ~= 'NULL' then
            local item = args[2]
            local classes = args[3]
            loot.ChangeClasses(item, classes, 'GlobalItems')
        elseif validActions[args[1]] and args[2] ~= 'NULL' then
            loot.addRule(args[2], args[2]:sub(1, 1):upper(), validActions[args[1]] .. '|' .. args[3])
            Logger.log_info("Setting \ay%s\ax to \ay%s|%s\ax", args[2], validActions[args[1]], args[3])
        end
    elseif #args == 4 then
        if args[1] == 'globalitem' and validActions[args[2]] and args[3] ~= 'NULL' then
            loot.addRule(args[3], 'GlobalItems', validActions[args[2]] .. '|' .. args[4])
            Logger.log_info("Setting \ay%s\ax to \agGlobal Item \ay%s|%s\ax", args[3], validActions[args[2]], args[4])
        end
    end
    loot.writeSettings()
end

function loot.setupBinds()
    mq.bind('/lootutils', loot.commandHandler)
end

-- LOOTING

function loot.CheckBags()
    areFull = mq.TLO.Me.FreeInventory() <= loot.Settings.SaveBagSlots
end

function loot.eventCantLoot()
    cantLootID = mq.TLO.Target.ID()
end

function loot.eventNoSlot()
    -- we don't have a slot big enough for the item on cursor. Dropping it to the ground.
    local cantLootItemName = mq.TLO.Cursor()
    Core.DoCmd('/drop')
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
    Logger.log_debug('Enter lootItem')
    local corpseItem = mq.TLO.Corpse.Item(index)
    if not shouldLootActions[doWhat] then
        table.insert(allItems, { Name = corpseItem.Name(), Action = 'Left', Link = corpseItem.ItemLink('CLICKABLE')(), Eval = doWhat, })
        return
    end
    local corpseItemID = corpseItem.ID()
    local itemName = corpseItem.Name()
    local itemLink = corpseItem.ItemLink('CLICKABLE')()
    local globalItem = (loot.Settings.GlobalLootOn and (loot.GlobalItems[itemName] ~= nil or loot.BuyItems[itemName] ~= nil)) and true or false

    Core.DoCmd('/nomodkey /shift /itemnotify loot%s %s', index, button)
    -- Looting of no drop items is currently disabled with no flag to enable anyways
    -- added check to make sure the cursor isn't empty so we can exit the pause early.-- or not mq.TLO.Corpse.Item(index).NoDrop()
    mq.delay(1) -- for good measure.
    mq.delay(5000, function() return mq.TLO.Window('ConfirmationDialogBox').Open() or mq.TLO.Cursor() == nil end)
    if mq.TLO.Window('ConfirmationDialogBox').Open() then Core.DoCmd('/nomodkey /notify ConfirmationDialogBox Yes_Button leftmouseup') end
    mq.delay(5000, function() return mq.TLO.Cursor() ~= nil or not mq.TLO.Window('LootWnd').Open() end)
    mq.delay(1) -- force next frame
    -- The loot window closes if attempting to loot a lore item you already have, but lore should have already been checked for
    if not mq.TLO.Window('LootWnd').Open() then return end
    if doWhat == 'Destroy' and mq.TLO.Cursor.ID() == corpseItemID then
        eval = globalItem and 'Global Destroy' or 'Destroy'
        Core.DoCmd('/destroy')
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
    if areFull then loot.report('My bags are full, I can\'t loot anymore! Turning OFF Looting Items until we sell.') end
end

function loot.lootCorpse(corpseID)
    Logger.log_debug('Enter lootCorpse')
    shouldLootActions.Destroy = loot.Settings.DoDestroy
    shouldLootActions.Tribute = loot.Settings.TributeKeep
    if mq.TLO.Cursor() then loot.checkCursor() end
    for i = 1, 3 do
        Core.DoCmd('/loot')
        mq.delay(1000, function() return mq.TLO.Window('LootWnd').Open() end)
        if mq.TLO.Window('LootWnd').Open() then break end
    end

    mq.doevents('CantLoot')
    mq.delay(3000, function() return cantLootID > 0 or mq.TLO.Window('LootWnd').Open() end)
    if not mq.TLO.Window('LootWnd').Open() then
        if mq.TLO.Target.CleanName() ~= nil then
            Logger.log_warn(('\awlootCorpse(): \ayCan\'t loot %s right now'):format(mq.TLO.Target.CleanName()))
            cantLootList[corpseID] = os.time()
        end
        return
    end
    mq.delay(1000, function() return (mq.TLO.Corpse.Items() or 0) > 0 end)
    local items = mq.TLO.Corpse.Items() or 0
    Logger.log_debug('\awlootCorpse(): \ayLoot window open. Items: %s', items)
    local corpseName = mq.TLO.Corpse.Name()
    if mq.TLO.Window('LootWnd').Open() and items > 0 then
        if mq.TLO.Corpse.DisplayName() == mq.TLO.Me.DisplayName() then
            if loot.Settings.LootMyCorpse then
                -- if its our own corpse and we want to loot our corpses then loot it all.
                Core.DoCmd('/lootall')
                -- dont return control to other functions until we are done looting.
                mq.delay("45s", function() return not mq.TLO.Window('LootWnd').Open() end)
            end
            return
        end
        local noDropItems = {}
        local loreItems = {}
        local allItems = {}
        for i = 1, items do
            local freeSpace = mq.TLO.Me.FreeInventory()
            local corpseItem = mq.TLO.Corpse.Item(i)
            local itemLink = corpseItem.ItemLink('CLICKABLE')()
            if corpseItem() then
                local itemRule, qKeep, newRule = loot.getRule(corpseItem, 'loot')
                Logger.log_debug("LootCorpse(): item=%s, rule=%s, qKeep=%s, newRule=%s", corpseItem.Name(), itemRule, qKeep, newRule)
                local stackable = corpseItem.Stackable()
                local freeStack = corpseItem.FreeStack()
                if corpseItem.Lore() then
                    local haveItem = mq.TLO.FindItem(('=%s'):format(corpseItem.Name()))()
                    local haveItemBank = mq.TLO.FindItemBank(('=%s'):format(corpseItem.Name()))()
                    if haveItem or haveItemBank or freeSpace <= loot.Settings.SaveBagSlots then
                        table.insert(loreItems, itemLink)
                        loot.lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
                    elseif corpseItem.NoDrop() then
                        if loot.Settings.LootNoDrop then
                            if not newRule or (newRule and loot.Settings.LootNoDropNew) then
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
                    if loot.Settings.LootNoDrop then
                        if not newRule or (newRule and loot.Settings.LootNoDropNew) then
                            loot.lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                        end
                    else
                        table.insert(noDropItems, itemLink)
                        loot.lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
                    end
                elseif freeSpace > loot.Settings.SaveBagSlots or (stackable and freeStack > 0) then
                    loot.lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                end
            end
            mq.delay(1)
            if mq.TLO.Cursor() then loot.checkCursor() end
            mq.delay(1)
            if not mq.TLO.Window('LootWnd').Open() then break end
        end
        if loot.Settings.ReportLoot and (#noDropItems > 0 or #loreItems > 0) then
            local skippedItems = '/%s Skipped loots (%s - %s) '
            for _, noDropItem in ipairs(noDropItems) do
                skippedItems = skippedItems .. ' ' .. noDropItem .. ' (nodrop) '
            end
            for _, loreItem in ipairs(loreItems) do
                skippedItems = skippedItems .. ' ' .. loreItem .. ' (lore) '
            end
            Core.DoCmd(skippedItems, loot.Settings.LootChannel, corpseName, corpseID)
        end
        if #allItems > 0 then
            -- send to self and others running lootnscoot
            loot.lootActor:send({ mailbox = 'looted', }, { ID = corpseID, Items = allItems, LootedAt = mq.TLO.Time(), LootedBy = Config.Globals.CurLoadedChar, })
            -- send to standalone looted gui
            loot.lootActor:send({ mailbox = 'looted', script = 'looted', },
                { ID = corpseID, Items = allItems, LootedAt = mq.TLO.Time(), LootedBy = Config.Globals.CurLoadedChar, })
        end
    end
    if mq.TLO.Cursor() then loot.checkCursor() end
    Core.DoCmd('/nomodkey /notify LootWnd LW_DoneButton leftmouseup')
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
    Logger.log_verbose('\awlootMobs(): \ayEnter lootMobs')
    local deadCount = mq.TLO.SpawnCount(spawnSearch:format('npccorpse', loot.Settings.CorpseRadius))()
    Logger.log_verbose('\awlootMobs(): \ayThere are %s corpses in range.', deadCount)
    local mobsNearby = Targeting.GetXTHaterCount()
    local corpseList = {}

    -- check for own corpse
    local myCorpseCount = mq.TLO.SpawnCount(string.format("pccorpse %s radius %d zradius 100", mq.TLO.Me.CleanName(), loot.Settings.CorpseRadius))()

    if loot.Settings.LootMyCorpse then
        -- if we want to loot our own corpses then add them to the list and loot them first so we have bags to put items into
        for i = 1, (limit or myCorpseCount) do
            local corpse = mq.TLO.NearestSpawn(string.format("%d, pccorpse %s radius %d zradius 100", i, mq.TLO.Me.CleanName(), loot.Settings.CorpseRadius))
            Logger.log_debug('\awlootMobs(): \ayMy Corpse ID: %d', corpse.ID())
            table.insert(corpseList, corpse)
        end
    end
    -- options for combat looting or looting disabled
    if (deadCount + myCorpseCount) == 0 or ((mobsNearby > 0 or mq.TLO.Me.Combat()) and not loot.Settings.CombatLooting) then return false end

    -- only loot mobs if I have no corspses near.
    if myCorpseCount == 0 then
        for i = 1, (limit or deadCount) do
            local corpse = mq.TLO.NearestSpawn(('%d,' .. spawnSearch):format(i, 'npccorpse', loot.Settings.CorpseRadius))
            table.insert(corpseList, corpse)
        end
    else
        Logger.log_debug('\awlootMobs(): \ayI have my own corpse nearby, not looting other corpses.')
    end

    local didLoot = false
    if #corpseList > 0 then
        Logger.log_debug('\awlootMobs(): \ayTrying to loot %d corpses.', #corpseList)
        for i = 1, #corpseList do
            if Config.Globals.PauseMain then break end
            local corpse = corpseList[i]
            local corpseID = corpse.ID()
            if corpseID and corpseID > 0 and not loot.corpseLocked(corpseID) and (mq.TLO.Navigation.PathLength('spawn id ' .. tostring(corpseID))() or 100) < 60 then
                -- try to pull our corpse closer if possible.
                if corpse.DisplayName() == mq.TLO.Me.DisplayName() then
                    Logger.log_debug('\awlootMobs(): \ayPulilng my Corpse ID: %d', corpse.ID())
                    Core.DoCmd("/corpse")
                    mq.delay(10)
                end

                Logger.log_debug('\awlootMobs(): \atMoving to corpse ID=' .. tostring(corpseID))
                loot.navToID(corpseID)

                if Targeting.GetXTHaterCount() > 0 and not loot.Settings.CombatLooting then
                    Logger.log_debug('\awlootMobs(): \arLooting stopped early due to aggro!')
                    return didLoot
                end

                corpse.DoTarget()
                loot.lootCorpse(corpseID)
                didLoot = true
            end
        end
        Logger.log_debug('\awlootMobs(): \agDone with corpse list.')
    end
    return didLoot
end

-- SELLING

function loot.eventSell(_, itemName)
    if NEVER_SELL[itemName] then return end
    local firstLetter = itemName:sub(1, 1):upper()
    if lootData[firstLetter] and lootData[firstLetter][itemName] == 'Sell' then return end
    if loot.lookupLootRule(firstLetter, itemName) == 'Sell' then
        lootData[firstLetter] = lootData[firstLetter] or {}
        lootData[firstLetter][itemName] = 'Sell'
        return
    end
    if loot.Settings.AddNewSales then
        Logger.log_info(string.format('Setting %s to Sell', itemName))
        if not lootData[firstLetter] then lootData[firstLetter] = {} end
        Core.DoCmd('/ini "%s" "%s" "%s" "%s"', LootFile, firstLetter, itemName, 'Sell')
        loot.modifyItem(itemName, 'Sell', 'Normal_Rules')
        lootData[firstLetter][itemName] = 'Sell'
        loot.NormalItems[itemName] = 'Sell'
        loot.lootActor:send({ mailbox = 'lootnscoot', },
            { who = Config.Globals.CurLoadedChar, action = 'modifyitem', item = itemName, rule = 'Sell', section = "NormalItems", })
        Modules:ExecModule("Loot", "ModifyLootSettings")
    end
end

function loot.goToVendor()
    if not mq.TLO.Target() then
        Logger.log_warn('Please target a vendor')
        return false
    end
    local vendorName = mq.TLO.Target.CleanName()

    Logger.log_info('Doing business with ' .. vendorName)
    if mq.TLO.Target.Distance() > 15 then
        loot.navToID(mq.TLO.Target.ID())
    end
    return true
end

function loot.openVendor()
    Logger.log_debug('Opening merchant window')
    Core.DoCmd('/nomodkey /click right target')
    Logger.log_debug('Waiting for merchant window to populate')
    mq.delay(1000, function() return mq.TLO.Window('MerchantWnd').Open() end)
    if not mq.TLO.Window('MerchantWnd').Open() then return false end
    mq.delay(5000, function() return mq.TLO.Merchant.ItemsReceived() end)
    return mq.TLO.Merchant.ItemsReceived()
end

function loot.SellToVendor(itemToSell, bag, slot)
    if NEVER_SELL[itemToSell] then return end
    if mq.TLO.Window('MerchantWnd').Open() then
        Logger.log_info('Selling ' .. itemToSell)
        if slot == nil or slot == -1 then
            Core.DoCmd('/nomodkey /itemnotify %s leftmouseup', bag)
        else
            Core.DoCmd('/nomodkey /itemnotify in pack%s %s leftmouseup', bag, slot)
        end
        mq.delay(1000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == itemToSell end)
        Core.DoCmd('/nomodkey /shiftkey /notify merchantwnd MW_Sell_Button leftmouseup')
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
    for itemName, qty in pairs(loot.BuyItems) do
        local tmpVal = tonumber(qty) or 0
        rowNum = mq.TLO.Window("MerchantWnd/MW_ItemList").List(itemName, 2)() or 0
        mq.delay(20)
        local tmpQty = tmpVal - mq.TLO.FindItemCount(itemName)()
        if rowNum ~= 0 and tmpQty > 0 then
            mq.TLO.Window("MerchantWnd/MW_ItemList").Select(rowNum)()
            mq.delay(100)
            mq.TLO.Window("MerchantWnd/MW_Buy_Button").LeftMouseUp()
            mq.delay(500, function() return mq.TLO.Window("QuantityWnd").Open() end)
            mq.TLO.Window("QuantityWnd/QTYW_SliderInput").SetText(tostring(tmpQty))()
            mq.delay(100, function() return mq.TLO.Window("QuantityWnd/QTYW_SliderInput").Text() == tostring(tmpQty) end)
            Logger.log_info("\agBuying\ay " .. tmpQty .. "\at " .. itemName)
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
    Logger.log_debug('Opening Tribute Window')
    Core.DoCmd('/nomodkey /click right target')
    Logger.log_debug('Waiting for Tribute Window to populate')
    mq.delay(1000, function() return mq.TLO.Window('TributeMasterWnd').Open() end)
    if not mq.TLO.Window('TributeMasterWnd').Open() then return false end
    return mq.TLO.Window('TributeMasterWnd').Open()
end

function loot.eventTribute(line, itemName)
    local firstLetter = itemName:sub(1, 1):upper()
    if lootData[firstLetter] and lootData[firstLetter][itemName] == 'Tribute' then return end
    if loot.lookupLootRule(firstLetter, itemName) == 'Tribute' then
        lootData[firstLetter] = lootData[firstLetter] or {}
        lootData[firstLetter][itemName] = 'Tribute'
        return
    end
    if loot.Settings.AddNewTributes then
        Logger.log_info(string.format('Setting %s to Tribute', itemName))
        if not lootData[firstLetter] then lootData[firstLetter] = {} end
        Core.DoCmd('/ini "%s" "%s" "%s" "%s"', LootFile, firstLetter, itemName, 'Tribute')

        loot.modifyItem(itemName, 'Tribute', 'Normal_Rules')
        lootData[firstLetter][itemName] = 'Tribute'
        loot.NormalItems[itemName] = 'Tribute'
        loot.lootActor:send({ mailbox = 'lootnscoot', },
            { who = Config.Globals.CurLoadedChar, action = 'modifyitem', item = itemName, rule = 'Tribute', section = "NormalItems", })
        Modules:ExecModule("Loot", "ModifyLootSettings")
    end
end

function loot.TributeToVendor(itemToTrib, bag, slot)
    if NEVER_SELL[itemToTrib.Name()] then return end
    if mq.TLO.Window('TributeMasterWnd').Open() then
        Logger.log_info('Tributeing ' .. itemToTrib.Name())
        loot.report('\ayTributing \at%s \axfor\ag %s \axpoints!', itemToTrib.Name(), itemToTrib.Tribute())
        Core.DoCmd('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
        mq.delay(1) -- progress frame

        mq.delay(5000, function()
            return mq.TLO.Window('TributeMasterWnd').Child('TMW_ValueLabel').Text() == tostring(itemToTrib.Tribute()) and
                mq.TLO.Window('TributeMasterWnd').Child('TMW_DonateButton').Enabled()
        end)

        mq.TLO.Window('TributeMasterWnd/TMW_DonateButton').LeftMouseUp()
        mq.delay(1)
        mq.delay(5000, function() return not mq.TLO.Window('TributeMasterWnd/TMW_DonateButton').Enabled() end)
        if mq.TLO.Window("QuantityWnd").Open() then
            mq.TLO.Window("QuantityWnd/QTYW_Accept_Button").LeftMouseUp()
            mq.delay(5000, function() return not mq.TLO.Window("QuantityWnd").Open() end)
        end
        mq.delay(1000) -- This delay is necessary because there is seemingly a delay between donating and selecting the next item.
    end
end

-- CLEANUP

function loot.DestroyItem(itemToDestroy, bag, slot)
    if NEVER_SELL[itemToDestroy.Name()] then return end
    Logger.log_info('!!Destroying!! ' .. itemToDestroy.Name())
    Core.DoCmd('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
    mq.delay(1) -- progress frame
    Core.DoCmd('/destroy')
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
                    loot.NormalItems[itemToMark] = 'Bank'
                    loot.addRule(itemToMark, itemToMark:sub(1, 1), 'Bank')
                    Modules:ExecModule("Loot", "ModifyLootSettings")
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
                    loot.NormalItems[itemToMark] = 'Bank'
                    loot.addRule(itemToMark, itemToMark:sub(1, 1), 'Bank')
                    Modules:ExecModule("Loot", "ModifyLootSettings")
                end
            end
        end
    end
end

function loot.bankItem(itemName, bag, slot)
    if not slot or slot == -1 then
        Core.DoCmd('/shift /itemnotify %s leftmouseup', bag)
    else
        Core.DoCmd('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
    end
    mq.delay(100, function() return mq.TLO.Cursor() end)
    Core.DoCmd('/notify BigBankWnd BIGB_AutoButton leftmouseup')
    mq.delay(100, function() return not mq.TLO.Cursor() end)
end

-- FORAGING

function loot.eventForage()
    if not loot.Settings.LootForage then return end
    Logger.log_debug('Enter eventForage')
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
                if loot.Settings.LootForageSpam then Logger.log_info('Destroying foraged item ' .. foragedItem) end
                Core.DoCmd('/destroy')
                mq.delay(500)
            end
            -- will a lore item we already have even show up on cursor?
            -- free inventory check won't cover an item too big for any container so may need some extra check related to that?
        elseif (shouldLootActions[ruleAction] or currentItemAmount < ruleAmount) and (not cursorItem.Lore() or currentItemAmount == 0) and (mq.TLO.Me.FreeInventory() or (cursorItem.Stackable() and cursorItem.FreeStack())) then
            if loot.Settings.LootForageSpam then Logger.log_info('Keeping foraged item ' .. foragedItem) end
            Core.DoCmd('/autoinv')
        else
            if loot.Settings.LootForageSpam then Logger.log_warn('Unable to process item ' .. foragedItem) end
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
                    Logger.log_warn(string.format('Item \ay%s\ax is set to Sell but has no sell value!', item.Name()))
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
                Core.DoCmd('/keypress OPEN_INV_BAGS')
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
                    Logger.log_warn('Bank window must be open!')
                    return
                end
                loot.bankItem(item.Name(), bag, slot)
                mq.delay(1)
            end
        end
    end

    if loot.Settings.AlwaysEval then
        flag, loot.Settings.AlwaysEval = true, false
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
    if action == 'Sell' and loot.Settings.AutoRestock then
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
        flag, loot.Settings.AlwaysEval = false, true
    end

    if action == 'Tribute' then
        mq.flushevents('Tribute')
        if mq.TLO.Window('TributeMasterWnd').Open() then
            mq.TLO.Window('TributeMasterWnd').DoClose()
            mq.delay(1)
        end
        Core.DoCmd('/keypress CLOSE_INV_BAGS')
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
                _, loot.Settings.DoLoot = ImGui.MenuItem("DoLoot", nil, loot.Settings.DoLoot)
                if _ then loot.writeSettings() end
                _, loot.Settings.GlobalLootOn = ImGui.MenuItem("GlobalLootOn", nil, loot.Settings.GlobalLootOn)
                if _ then loot.writeSettings() end
                _, loot.Settings.CombatLooting = ImGui.MenuItem("CombatLooting", nil, loot.Settings.CombatLooting)
                if _ then loot.writeSettings() end
                _, loot.Settings.LootNoDrop = ImGui.MenuItem("LootNoDrop", nil, loot.Settings.LootNoDrop)
                if _ then loot.writeSettings() end
                _, loot.Settings.LootNoDropNew = ImGui.MenuItem("LootNoDropNew", nil, loot.Settings.LootNoDropNew)
                if _ then loot.writeSettings() end
                _, loot.Settings.LootForage = ImGui.MenuItem("LootForage", nil, loot.Settings.LootForage)
                if _ then loot.writeSettings() end
                _, loot.Settings.LootQuest = ImGui.MenuItem("LootQuest", nil, loot.Settings.LootQuest)
                if _ then loot.writeSettings() end
                _, loot.Settings.TributeKeep = ImGui.MenuItem("TributeKeep", nil, loot.Settings.TributeKeep)
                if _ then loot.writeSettings() end
                _, loot.Settings.BankTradeskills = ImGui.MenuItem("BankTradeskills", nil, loot.Settings.BankTradeskills)
                if _ then loot.writeSettings() end
                _, loot.Settings.StackableOnly = ImGui.MenuItem("StackableOnly", nil, loot.Settings.StackableOnly)
                if _ then loot.writeSettings() end
                ImGui.Separator()
                _, loot.Settings.AlwaysEval = ImGui.MenuItem("AlwaysEval", nil, loot.Settings.AlwaysEval)
                if _ then loot.writeSettings() end
                _, loot.Settings.AddNewSales = ImGui.MenuItem("AddNewSales", nil, loot.Settings.AddNewSales)
                if _ then loot.writeSettings() end
                _, loot.Settings.AddNewTributes = ImGui.MenuItem("AddNewTributes", nil, loot.Settings.AddNewTributes)
                if _ then loot.writeSettings() end
                _, loot.Settings.AutoTag = ImGui.MenuItem("AutoTagSell", nil, loot.Settings.AutoTag)
                if _ then loot.writeSettings() end
                _, loot.Settings.AutoRestock = ImGui.MenuItem("AutoRestock", nil, loot.Settings.AutoRestock)
                if _ then loot.writeSettings() end
                ImGui.Separator()
                _, loot.Settings.DoDestroy = ImGui.MenuItem("DoDestroy", nil, loot.Settings.DoDestroy)
                if _ then loot.writeSettings() end
                _, loot.Settings.AlwaysDestroy = ImGui.MenuItem("AlwaysDestroy", nil, loot.Settings.AlwaysDestroy)
                if _ then loot.writeSettings() end

                ImGui.EndMenu()
            end
            if ImGui.BeginMenu('Group Commands') then
                -- Add menu items here
                if ImGui.MenuItem("Sell Stuff##group") then
                    Core.DoCmd(string.format('/%s /rgl sell', tmpCmd))
                end

                if ImGui.MenuItem('Restock Items##group') then
                    Core.DoCmd(string.format('/%s /rgl buy', tmpCmd))
                end

                if ImGui.MenuItem("Tribute Stuff##group") then
                    Core.DoCmd(string.format('/%s /rgl tribute', tmpCmd))
                end

                if ImGui.MenuItem("Bank##group") then
                    Core.DoCmd(string.format('/%s /rgl bank', tmpCmd))
                end

                if ImGui.MenuItem("Cleanup##group") then
                    Core.DoCmd(string.format('/%s /rgl cleanbags', tmpCmd))
                end

                ImGui.Separator()

                if ImGui.MenuItem("Reload##group") then
                    Core.DoCmd(string.format('/%s /rgl lootreload', tmpCmd))
                end

                ImGui.EndMenu()
            end
            if ImGui.MenuItem('Sell Stuff') then
                Core.DoCmd('/rgl sell')
            end

            if ImGui.MenuItem('Restock') then
                Core.DoCmd('/rgl buy')
            end

            if ImGui.MenuItem('Tribute Stuff') then
                Core.DoCmd('/rgl tribute')
            end

            if ImGui.MenuItem('Bank') then
                Core.DoCmd('/rgl bank')
            end

            if ImGui.MenuItem('Cleanup') then
                Core.DoCmd('/rgl cleanbags')
            end

            ImGui.Separator()

            if ImGui.MenuItem('Reload') then
                Core.DoCmd('/rgl lootreload')
            end


            ImGui.EndMenu()
        end
    end
    -- Add the custom menu element function to the importGUIElements table
    if loot.guiLoot ~= nil then table.insert(loot.guiLoot.importGUIElements, customMenu) end
end

function loot.init()
    local iniFile = mq.TLO.Ini.File(SettingsFile)
    local needsSave = false
    if not (iniFile.Exists() and iniFile.Section('Settings').Exists()) then
        needsSave = true
    else
        needsSave = loot.loadSettings()
    end
    loot.RegisterActors()
    loot.CheckBags()
    loot.setupEvents()
    loot.setupBinds()
    loot.guiExport()

    Logger.log_debug("Loot::init() SaveRequired: %s", needsSave and "TRUE" or "FALSE")
    return needsSave
end

if loot.guiLoot ~= nil then
    loot.guiLoot.GetSettings(loot.Settings.HideNames, loot.Settings.LookupLinks, loot.Settings.RecordData, true, loot.Settings.UseActors, 'lootnscoot')
    loot.guiLoot.init(true, true, 'lootnscoot')
end
return loot
