--[[
loot.lua v1.7 - aquietone, grimmier

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

local mq                                    = require 'mq'
local lootutils                                    = require 'lootnscoot'
while true do
lootutils.lootMobs()
mq.delay(1000)
end

lootUtils.lootMobs() will run until it has attempted to loot all corpses within the defined radius.

To sell to a vendor, call lootutils.sellStuff():

local mq                                    = require 'mq'
local lootutils                                    = require 'lootnscoot'
local doSell                                    = false
local function binds(...)
local args                                    = {...}
if args[1]                                    == 'sell' then doSell                                    = true end
end
mq.bind('/myscript', binds)
while true do
lootutils.lootMobs()
if doSell then lootutils.sellStuff() doSell                                    = false end
mq.delay(1000)
end

lootutils.sellStuff() will run until it has attempted to sell all items marked as sell to the targeted vendor.

Note that in the above example, loot.sellStuff() isn't being called directly from the bind callback.
Selling may take some time and includes delays, so it is best to be called from your main loop.

Optionally, configure settings using:
Set the radius within which corpses should be looted (radius from you, not a camp location)
lootutils.CorpseRadius                                    = number
Set whether loot.ini should be updated based off of sell item events to add manually sold items.
lootutils.AddNewSales                                    = boolean
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
---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field

local mq              = require 'mq'
local PackageMan      = require('mq.PackageMan')
local SQLite3         = PackageMan.Require('lsqlite3')
local Icons           = require('mq.ICONS')
local success, Logger = pcall(require, 'lib.Write')

if not success then
    printf('\arERROR: Write.lua could not be loaded\n%s\ax', Logger)
    return
end
local eqServer                       = string.gsub(mq.TLO.EverQuest.Server(), ' ', '_')
-- Check for looted module, if found use that. else fall back on our copy, which may be outdated.

local version                        = 5
local MyName                         = mq.TLO.Me.CleanName()
local Mode                           = 'once'
local Files                          = require('mq.Utils')
local SettingsFile                   = string.format('%s/LootNScoot/%s/%s.lua', mq.configDir, eqServer, MyName)
local imported                       = true
local lootDBUpdateFile               = string.format('%s/LootNScoot/%s/DB_Updated.lua', mq.configDir, eqServer)
local zoneID                         = 0
local lootedCorpses                  = {}
local tmpRules, tmpClasses, tmpLinks = {}, {}, {}
local ProcessItemsState              = nil
local reportPrefix                   = '/%s \a-t[\at%s\a-t][\ax\ayLootUtils\ax\a-t]\ax '
Logger.prefix                        = "[\atLootnScoot\ax] "
-- Public default settings, also read in from Loot.ini [Settings] section
local loot                           = {}
loot.Settings                        = {
    Version          = '"' .. tostring(version) .. '"',
    GlobalLootOn     = true,   -- Enable Global Loot Items. not implimented yet
    CombatLooting    = false,  -- Enables looting during combat. Not recommended on the MT
    CorpseRadius     = 100,    -- Radius to activly loot corpses
    MobsTooClose     = 40,     -- Don't loot if mobs are in this range.
    SaveBagSlots     = 3,      -- Number of bag slots you would like to keep empty at all times. Stop looting if we hit this number
    TributeKeep      = false,  -- Keep items flagged Tribute
    MinTributeValue  = 100,    -- Minimun Tribute points to keep item if TributeKeep is enabled.
    MinSellPrice     = -1,     -- Minimum Sell price to keep item. -1                                    = any
    StackPlatValue   = 0,      -- Minimum sell value for full stack
    StackableOnly    = false,  -- Only loot stackable items
    AlwaysEval       = false,  -- Re-Evaluate all *Non Quest* items. useful to update loot.ini after changing min sell values.
    BankTradeskills  = true,   -- Toggle flagging Tradeskill items as Bank or not.
    DoLoot           = true,   -- Enable auto looting in standalone mode
    LootForage       = true,   -- Enable Looting of Foraged Items
    LootNoDrop       = false,  -- Enable Looting of NoDrop items.
    LootNoDropNew    = false,  -- Enable looting of new NoDrop items.
    LootQuest        = false,  -- Enable Looting of Items Marked 'Quest', requires LootNoDrop on to loot NoDrop quest items
    DoDestroy        = false,  -- Enable Destroy functionality. Otherwise 'Destroy' acts as 'Ignore'
    AlwaysDestroy    = false,  -- Always Destroy items to clean corpese Will Destroy Non-Quest items marked 'Ignore' items REQUIRES DoDestroy set to true
    QuestKeep        = 10,     -- Default number to keep if item not set using Quest|# format.
    LootChannel      = "dgt",  -- Channel we report loot to.
    GroupChannel     = "dgze", -- Channel we use for Group Commands Default(dgze)
    ReportLoot       = true,   -- Report loot items to group or not.
    SpamLootInfo     = false,  -- Echo Spam for Looting
    LootForageSpam   = false,  -- Echo spam for Foraged Items
    AddNewSales      = true,   -- Adds 'Sell' Flag to items automatically if you sell them while the script is running.
    AddNewTributes   = true,   -- Adds 'Tribute' Flag to items automatically if you Tribute them while the script is running.
    GMLSelect        = true,   -- not implimented yet
    LootLagDelay     = 0,      -- not implimented yet
    HideNames        = false,  -- Hides names and uses class shortname in looted window
    LookupLinks      = false,  -- Enables Looking up Links for items not on that character. *recommend only running on one charcter that is monitoring.
    RecordData       = false,  -- Enables recording data to report later.
    AutoTag          = false,  -- Automatically tag items to sell if they meet the MinSellPrice
    AutoRestock      = false,  -- Automatically restock items from the BuyItems list when selling
    LootMyCorpse     = false,  -- Loot your own corpse if its nearby (Does not check for REZ)
    LootAugments     = false,  -- Loot Augments
    CheckCorpseOnce  = false,  -- Check Corpse once and move on. Ignore the next time it is in range if enabled
    AutoShowNewItem  = false,  -- Automatically show new items in the looted window
    KeepSpells       = true,   -- Keep spells
    CanWear          = false,  -- Only loot items you can wear
    ShowInfoMessages = true,
    ShowConsole      = false,
    ShowReport       = false,
    BuyItemsTable    = {
        ['Iron Ration'] = 20,
        ['Water Flask'] = 20,
    },
}

loot.MyClass                         = mq.TLO.Me.Class.ShortName():lower()
loot.MyRace                          = mq.TLO.Me.Race.Name()
-- SQL information
local resourceDir                    = mq.TLO.MacroQuest.Path('resources')() .. "/"
local RulesDB                        = string.format('%s/LootNScoot/%s/AdvLootRules.db', resourceDir, eqServer)
local lootDB                         = string.format('%s/LootNScoot/%s/Items.db', resourceDir, eqServer)
local HistoryDB                      = string.format('%s/LootNScoot/%s/LootHistory.db', resourceDir, eqServer)
local newItem                        = nil
loot.guiLoot                         = require('loot_hist')
if loot.guiLoot ~= nil then
    loot.UseActors = true
    loot.guiLoot.GetSettings(loot.Settings.HideNames, loot.Settings.LookupLinks, true, true, true, 'lootnscoot', false)
end
local debugPrint                        = false
local iconAnimation                     = mq.FindTextureAnimation('A_DragItem')
-- Internal settings
local cantLootList                      = {}
local cantLootID                        = 0
local noDropItems, loreItems            = {}, {}
local allItems                          = {}
-- Constants
local spawnSearch                       = '%s radius %d zradius 50'
-- If you want destroy to actually loot and destroy items, change DoDestroy=false to DoDestroy=true in the Settings Ini.
-- Otherwise, destroy behaves the same as ignore.
local shouldLootActions                 = { CanUse = false, Ask = false, Keep = true, Bank = true, Sell = true, Destroy = false, Ignore = false, Tribute = false, }
local validActions                      = {
    canuse = "CanUse",
    ask = "Ask",
    keep = 'Keep',
    bank = 'Bank',
    sell = 'Sell',
    ignore = 'Ignore',
    destroy = 'Destroy',
    quest = 'Quest',
    tribute = 'Tribute',
}
local saveOptionTypes                   = { string = 1, number = 1, boolean = 1, }
local NEVER_SELL                        = { ['Diamond Coin'] = true, ['Celestial Crest'] = true, ['Gold Coin'] = true, ['Taelosian Symbols'] = true, ['Planar Symbols'] = true, }
local tmpCmd                            = loot.GroupChannel or 'dgae'
local showNewItem                       = false
local lookupDate                        = ''
local Actors                            = require('actors')
loot.DirectorScript                     = 'none'
loot.BuyItemsTable                      = {}
loot.ALLITEMS                           = {}
loot.GlobalItemsRules                   = {}
loot.NormalItemsRules                   = {}
loot.NormalItemsClasses                 = {}
loot.GlobalItemsClasses                 = {}
loot.NormalItemsLink                    = {}
loot.GlobalItemsLink                    = {}
loot.NewItems                           = {}
loot.TempSettings                       = {}
loot.PersonalItemsRules                 = {}
loot.PersonalItemsClasses               = {}
loot.PersonalItemsLink                  = {}
loot.NewItemDecisions                   = nil
loot.ItemNames                          = {}
loot.NewItemsCount                      = 0
loot.TempItemClasses                    = "All"
loot.itemSelectionPending               = false -- Flag to indicate an item selection is in progress
loot.pendingItemData                    = nil   -- Temporary storage for item data
loot.doImportInventory                  = false
loot.TempModClass                       = false
loot.ShowUI                             = false
loot.Terminate                          = true
loot.Boxes                              = {}
loot.LootNow                            = false
loot.histCurrentPage                    = 1
loot.histItemsPerPage                   = 25
loot.histTotalPages                     = 1
loot.histTotalItems                     = 0
loot.HistoricalDates                    = {}
loot.HistoryDataDate                    = {}
loot.PersonalTableName                  = string.format("%s_Rules", MyName)
-- FORWARD DECLARATIONS
loot.AllItemColumnListIndex             = {
    [1]  = 'name',
    [2]  = 'sell_value',
    [3]  = 'tribute_value',
    [4]  = 'stackable',
    [5]  = 'stack_size',
    [6]  = 'nodrop',
    [7]  = 'notrade',
    [8]  = 'tradeskill',
    [9]  = 'quest',
    [10] = 'lore',
    [11] = 'collectible',
    [12] = 'augment',
    [13] = 'augtype',
    [14] = 'clickable',
    [15] = 'weight',
    [16] = 'ac',
    [17] = 'damage',
    [18] = 'strength',
    [19] = 'dexterity',
    [20] = 'agility',
    [21] = 'stamina',
    [22] = 'intelligence',
    [23] = 'wisdom',
    [24] = 'charisma',
    [25] = 'hp',
    [26] = 'regen_hp',
    [27] = 'mana',
    [28] = 'regen_mana',
    [29] = 'haste',
    [30] = 'classes',
    [31] = 'class_list',
    [32] = 'svfire',
    [33] = 'svcold',
    [34] = 'svdisease',
    [35] = 'svpoison',
    [36] = 'svcorruption',
    [37] = 'svmagic',
    [38] = 'spelldamage',
    [39] = 'spellshield',
    [40] = 'item_size',
    [41] = 'weightreduction',
    [42] = 'races',
    [43] = 'race_list',
    [44] = 'item_range',
    [45] = 'attack',
    [46] = 'strikethrough',
    [47] = 'heroicagi',
    [48] = 'heroiccha',
    [49] = 'heroicdex',
    [50] = 'heroicint',
    [51] = 'heroicsta',
    [52] = 'heroicstr',
    [53] = 'heroicsvcold',
    [54] = 'heroicsvcorruption',
    [55] = 'heroicsvdisease',
    [56] = 'heroicsvfire',
    [57] = 'heroicsvmagic',
    [58] = 'heroicsvpoison',
    [59] = 'heroicwis',
}

local settingsEnum                      = {
    checkcorpseonce = 'CheckCorpseOnce',
    autoshownewitem = 'AutoShowNewItem',
    keepspells = 'KeepSpells',
    canwear = 'CanWear',
    globallooton = 'GlobalLootOn',
    combatlooting = 'CombatLooting',
    corpseradius = 'CorpseRadius',
    mobstooclose = 'MobsTooClose',
    savebagslots = 'SaveBagSlots',
    tributekeep = 'TributeKeep',
    mintributevalue = 'MinTributeValue',
    minsellprice = 'MinSellPrice',
    stackplatvalue = 'StackPlatValue',
    stackableonly = 'StackableOnly',
    alwayseval = 'AlwaysEval',
    banktradeskills = 'BankTradeskills',
    doloot = 'DoLoot',
    lootforage = 'LootForage',
    lootnodrop = 'LootNoDrop',
    lootnodropnew = 'LootNoDropNew',
    lootquest = 'LootQuest',
    dodestroy = 'DoDestroy',
    alwaysdestroy = 'AlwaysDestroy',
    questkeep = 'QuestKeep',
    lootchannel = 'LootChannel',
    groupchannel = 'GroupChannel',
    reportloot = 'ReportLoot',
    spamlootinfo = 'SpamLootInfo',
    lootforagespam = 'LootForageSpam',
    addnewsales = 'AddNewSales',
    addnewtributes = 'AddNewTributes',
    gmlselect = 'GMLSelect',
    lootlagdelay = 'LootLagDelay',
    hidenames = 'HideNames',
    lookuplinks = 'LookupLinks',
    recorddata = 'RecordData',
    autotag = 'AutoTag',
    autorestock = 'AutoRestock',
    lootmycorpse = 'LootMyCorpse',
    lootaugments = 'LootAugments',
    showinfomessages = 'ShowInfoMessages',
    showconsole = 'ShowConsole',
    showreport = 'ShowReport',

}
local tableList                         = {
    "Global_Items", "Normal_Items", loot.PersonalTableName,
}
local tableListRules                    = {
    "Global_Rules", "Normal_Rules", loot.PersonalTableName,
}
local doSell, doBuy, doTribute, areFull = false, false, false, false
local settingList                       = {
    "CanUse",
    "Keep",
    "Ignore",
    "Destroy",
    "Quest",
    "Sell",
    "Tribute",
    "Bank",
}

local settingsNoDraw                    = {
    Version = true,
    logger = true,
    LootFile = true,
    SettingsFile = true,
    NoDropDefaults = true,
    CorpseRotTime = true,
    LootLagDelay = true,
    Terminate = true,
    BuyItemsTable = true,
    ShowReport = true,
    ShowConsole = true,
}

local selectedIndex                     = 1

-- Pagination state
local ITEMS_PER_PAGE                    = 25
loot.CurrentPage                        = loot.CurrentPage or 1

-- UTILITIES



---
---This will keep your table sorted by columns instead of rows.
---@param input_table table|nil the table to sort (optional) You can send a set of sorted keys if you have already custom sorted it.
---@param sorted_keys table|nil  the sorted keys table (optional) if you have already sorted the keys
---@param num_columns integer  the number of column groups to sort the keys into
---@return table
function loot.SortTableColums(input_table, sorted_keys, num_columns)
    if input_table == nil and sorted_keys == nil then return {} end

    -- If sorted_keys is provided, use it, otherwise extract the keys from the input_table
    local keys = sorted_keys or {}
    if #keys == 0 then
        for k, _ in pairs(input_table) do
            table.insert(keys, k)
        end
        table.sort(keys, function(a, b)
            return a < b
        end)
    end

    local total_items = #keys
    local num_rows = math.ceil(total_items / num_columns)
    local column_sorted = {}

    -- Reorganize the keys to fill vertically by columns
    for row = 1, num_rows do
        for col = 1, num_columns do
            local index = (col - 1) * num_rows + row
            if index <= total_items then
                table.insert(column_sorted, keys[index])
            end
        end
    end

    return column_sorted
end

function loot.SortKeys(input_table)
    local keys = {}
    for k, _ in pairs(input_table) do
        table.insert(keys, k)
    end

    table.sort(keys) -- Sort the keys
    return keys
end

---comment: Returns a table containing all the data from the INI file.
---@param fileName string The name of the INI file to parse. [string]
---@param sec string The section of the INI file to parse. [string]
---@return table DataTable containing all data from the INI file. [table]
function loot.load(fileName, sec)
    if sec == nil then sec = "items" end
    -- this came from Knightly's LIP.lua
    assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
    local file  = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
    local data  = {};
    local section;
    local count = 0
    for line in file:lines() do
        local tempSection = line:match('^%[([^%[%]]+)%]$');
        if (tempSection) then
            -- print(tempSection)
            section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
            -- data[section]                                    = data[section] or {};
            count   = 0
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
    Logger.Debug(loot.guiLoot.console, "Loot::load()")
    return data;
end

function loot.writeSettings()
    loot.Settings.BuyItemsTable = loot.BuyItemsTable
    mq.pickle(SettingsFile, loot.Settings)
    Logger.Debug(loot.guiLoot.console, "Loot::writeSettings()")
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

function loot.drawIcon(iconID, iconSize)
    if iconSize == nil then iconSize = 16 end
    if iconID ~= nil then
        iconAnimation:SetTextureCell(iconID - 500)
        ImGui.DrawTextureAnimation(iconAnimation, iconSize, iconSize)
    end
end

function loot.OpenItemsSQL()
    local db = SQLite3.open(lootDB)
    db:exec("PRAGMA journal_mode=WAL;")
    return db
end

function loot.LoadHistoricalData()
    loot.HistoricalDates = {}
    local db = SQLite3.open(HistoryDB)
    db:exec("PRAGMA journal_mode=WAL;")
    db:exec("BEGIN TRANSACTION")
    db:exec([[
        CREATE TABLE IF NOT EXISTS LootHistory (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "Item" TEXT NOT NULL,
            "CorpseName" TEXT NOT NULL,
            "Action" TEXT NOT NULL,
            "Date" TEXT NOT NULL,
            "TimeStamp" TEXT NOT NULL ,
            "Link" TEXT NOT NULL,
            "Looter" TEXT NOT NULL,
            "Zone" TEXT NOT NULL
        );
    ]])
    db:exec("COMMIT")

    db:exec("BEGIN TRANSACTION")

    local stmt = db:prepare("SELECT DISTINCT Date FROM LootHistory")

    for row in stmt:nrows() do
        table.insert(loot.HistoricalDates, row.Date)
    end

    stmt:finalize()
    db:exec("COMMIT")
    db:close()
end

function loot.LoadDateHistory(lookup_Date)
    local db = SQLite3.open(HistoryDB)
    db:exec("PRAGMA journal_mode=WAL;")
    db:exec("BEGIN TRANSACTION")

    loot.HistoryDataDate = {}
    local stmt = db:prepare("SELECT * FROM LootHistory WHERE Date = ?")
    stmt:bind_values(lookup_Date)
    for row in stmt:nrows() do
        table.insert(loot.HistoryDataDate, row)
    end

    stmt:finalize()
    db:exec("COMMIT")
    db:close()
end

local function convertTimestamp(timeStr)
    local h, mi, s = timeStr:match("(%d+):(%d+):(%d+)")
    local hour = tonumber(h)
    local min = tonumber(mi)
    local sec = tonumber(s)
    local timeSeconds = (hour * 3600) + (min * 60) + sec
    return timeSeconds
end

---comment
---@param itemName string the name of the item
---@param corpseName string the name of the corpse
---@param action string the action taken
---@param date string the date the item was looted (YYYY-MM-DD)
---@param timestamp string the time the item was looted (HH:MM:SS)
---@param link string the item link
---@param looter string the name of the looter
---@param zone string the zone the item was looted in (ShortName)
---@param allItems table items table sent to looted.
---@param cantWear boolean|nil if the item can be worn
function loot.insertIntoHistory(itemName, corpseName, action, date, timestamp, link, looter, zone, allItems, cantWear)
    if itemName == nil then return end
    local db = SQLite3.open(HistoryDB)
    if not db then
        print("Error: Failed to open database.")
        return
    end

    db:exec("PRAGMA journal_mode=WAL;")

    -- Convert current date+time to epoch
    local currentTime = convertTimestamp(timestamp)

    -- Skip if a duplicate "Ignore" or "Left" action exists within the last minute
    if action == "Ignore" or action == "Left" then
        local checkStmt = db:prepare([[
                SELECT Date, TimeStamp FROM LootHistory
                WHERE Item = ? AND CorpseName = ? AND Action = ? AND Date = ?
                ORDER BY Date DESC, TimeStamp DESC LIMIT 1
            ]])
        if checkStmt then
            checkStmt:bind_values(itemName, corpseName, action, date)
            local res = checkStmt:step()
            if res == SQLite3.ROW then
                local lastTimestamp = checkStmt:get_value(1)
                local recoredTime = convertTimestamp(lastTimestamp)
                if (currentTime - recoredTime) <= 60 then
                    checkStmt:finalize()
                    db:close()
                    return
                end
            end
            checkStmt:finalize()
        end
    end

    db:exec("BEGIN TRANSACTION")
    local stmt = db:prepare([[
            INSERT INTO LootHistory (Item, CorpseName, Action, Date, TimeStamp, Link, Looter, Zone)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ]])
    if stmt then
        stmt:bind_values(itemName, corpseName, action, date, timestamp, link, looter, zone)
        local res, err = stmt:step()
        if res ~= SQLite3.DONE then
            printf("Error inserting data: %s ", err)
        end
        stmt:finalize()
    else
        print("Error preparing statement")
    end

    db:exec("COMMIT")
    db:close()
    mq.delay(1)
    local eval = action == 'Ignore' and 'Left' or action
    local actLabel = action == 'Destroy' and 'Destroyed' or action
    if action ~= 'Destroy' and action ~= 'Ignore' then
        actLabel = 'Looted'
    end
    table.insert(allItems,
        {
            Name = itemName,
            CorpseName = corpseName,
            Action = actLabel,
            Link = link,
            Eval = eval,
            cantWear = cantWear,
        })
end

function loot.LoadRuleDB()
    -- Open the database once
    local db = SQLite3.open(RulesDB)
    local charTableName = string.format("%s_Rules", MyName)

    -- Create tables only if necessary (wrapped in a single transaction)
    db:exec("PRAGMA journal_mode=WAL;")
    db:exec("BEGIN TRANSACTION")
    db:exec(string.format([[
        CREATE TABLE IF NOT EXISTS Global_Rules (
            "item_id" INTEGER PRIMARY KEY NOT NULL UNIQUE,
            "item_name" TEXT NOT NULL,
            "item_rule" TEXT NOT NULL,
            "item_rule_classes" TEXT,
            "item_link" TEXT
        );
        CREATE TABLE IF NOT EXISTS Normal_Rules (
            "item_id" INTEGER PRIMARY KEY NOT NULL UNIQUE,
            "item_name" TEXT NOT NULL,
            "item_rule" TEXT NOT NULL,
            "item_rule_classes" TEXT,
            "item_link" TEXT
        );
        CREATE TABLE IF NOT EXISTS %s (
            "item_id" INTEGER PRIMARY KEY NOT NULL UNIQUE,
            "item_name" TEXT NOT NULL,
            "item_rule" TEXT NOT NULL,
            "item_rule_classes" TEXT,
            "item_link" TEXT
        );
    ]], charTableName))
    db:exec("COMMIT")

    -- Function to process rules in a table
    local function processRules(stmt, ruleTable, classTable, linkTable)
        for row in stmt:nrows() do
            local id = row.item_id
            local classes = row.item_rule_classes or 'All'
            if classes == 'None' or classes:gsub(' ', '') then classes = 'All' end
            ruleTable[id] = row.item_rule
            classTable[id] = classes
            linkTable[id] = row.item_link or "NULL"
            loot.ItemNames[id] = loot.ItemNames[id] or row.item_name
        end
    end

    -- Load rules efficiently
    db:exec("BEGIN TRANSACTION")
    local stmt = db:prepare("SELECT * FROM Global_Rules")
    processRules(stmt, loot.GlobalItemsRules, loot.GlobalItemsClasses, loot.GlobalItemsLink)
    stmt:finalize()

    stmt = db:prepare("SELECT * FROM Normal_Rules")
    processRules(stmt, loot.NormalItemsRules, loot.NormalItemsClasses, loot.NormalItemsLink)
    stmt:finalize()

    stmt = db:prepare(string.format("SELECT * FROM %s", charTableName))
    processRules(stmt, loot.PersonalItemsRules, loot.PersonalItemsClasses, loot.PersonalItemsLink)
    stmt:finalize()
    db:exec("COMMIT")

    db:close()
end

---comment
---@param firstRun boolean|nil if passed true then we will load the DB's again
---@return boolean
function loot.loadSettings(firstRun)
    if firstRun == nil then firstRun = false end
    if firstRun then
        loot.NormalItemsRules     = {}
        loot.GlobalItemsRules     = {}
        loot.NormalItemsClasses   = {}
        loot.GlobalItemsClasses   = {}
        loot.NormalItemsLink      = {}
        loot.GlobalItemsLink      = {}
        loot.BuyItemsTable        = {}
        loot.PersonalItemsRules   = {}
        loot.PersonalItemsClasses = {}
        loot.PersonalItemsLink    = {}
        loot.ItemNames            = {}
        loot.ALLITEMS             = {}
    end
    local needDBUpdate = false
    local needSave     = false
    local tmpSettings  = {}

    if not Files.File.Exists(SettingsFile) then
        Logger.Warn(loot.guiLoot.console, "Settings file not found, creating it now.")
        needSave = true
        mq.pickle(SettingsFile, loot.Settings)
    else
        tmpSettings = dofile(SettingsFile)
    end
    -- check if the DB structure needs updating

    if not Files.File.Exists(lootDBUpdateFile) then
        needDBUpdate        = true
        tmpSettings.Version = version
        needSave            = true
    else
        local tmp = dofile(lootDBUpdateFile)
        if tmp.version < version then
            needDBUpdate        = true
            tmpSettings.Version = version
            needSave            = true
        end
    end

    if not Files.File.Exists(RulesDB) then
        -- touch path to create the directory
        mq.pickle(RulesDB .. "touch", {})
    end
    -- process settings file

    for k, v in pairs(loot.Settings) do
        if type(v) ~= 'table' then
            if tmpSettings[k] == nil then
                tmpSettings[k] = loot.Settings[k]
                needSave       = true
                Logger.Info(loot.guiLoot.console, "\agAdded\ax \ayNEW\ax \aySetting\ax: \at%s \aoDefault\ax: \at(\ay%s\ax)", k, v)
            end
        end
    end
    if tmpSettings.BuyItemsTable == nil then
        tmpSettings.BuyItemsTable = loot.Settings.BuyItemsTable
        needSave                  = true
        Logger.Info(loot.guiLoot.console, "\agAdded\ax \ayNEW\ax \aySetting\ax: \atBuyItemsTable\ax")
    end
    -- -- check for deprecated settings and remove them
    -- for k, v in pairs(tmpSettings) do
    --     if type(tmpSettings[k]) ~= 'table' then
    --         if loot.Settings[k] == nil and settingsNoDraw[k] == nil then
    --             tmpSettings[k] = nil
    --             needSave       = true
    --             Logger.Warn(loot.guiLoot.console, "\arRemoved\ax \atdeprecated setting\ax: \ao%s", k)
    --         end
    --     end
    -- end
    Logger.loglevel = loot.Settings.ShowInfoMessages and 'info' or 'warn'

    tmpCmd = loot.Settings.GroupChannel or 'dgge'
    if tmpCmd == string.find(tmpCmd, 'dg') then
        tmpCmd = '/' .. tmpCmd
    elseif tmpCmd == string.find(tmpCmd, 'bc') then
        tmpCmd = '/' .. tmpCmd .. ' /'
    end

    shouldLootActions.Destroy = loot.Settings.DoDestroy
    shouldLootActions.Tribute = loot.Settings.TributeKeep
    loot.BuyItemsTable        = tmpSettings.BuyItemsTable

    if firstRun then
        -- SQL setup
        if not Files.File.Exists(RulesDB) then
            Logger.Warn(loot.guiLoot.console, "\ayLoot Rules Database \arNOT found\ax, \atCreating it now\ax. Please run \at/rgl lootimport\ax to Import your \atloot.ini \axfile.")
            Logger.Warn(loot.guiLoot.console, "\arOnly run this one One Character\ax. use \at/rgl lootreload\ax to update the data on the other characters.")
        else
            Logger.Info(loot.guiLoot.console, "Loot Rules Database found, loading it now.")
        end

        -- load the rules database
        loot.LoadRuleDB()

        -- check if the DB structure needs updating
        local db = loot.OpenItemsSQL()
        db:exec("BEGIN TRANSACTION")
        db:exec([[
        CREATE TABLE IF NOT EXISTS Items (
        item_id INTEGER PRIMARY KEY NOT NULL UNIQUE,
        name TEXT NOT NULL,
        nodrop INTEGER DEFAULT 0,
        notrade INTEGER DEFAULT 0,
        tradeskill INTEGER DEFAULT 0,
        quest INTEGER DEFAULT 0,
        lore INTEGER DEFAULT 0,
        augment INTEGER DEFAULT 0,
        stackable INTEGER DEFAULT 0,
        sell_value INTEGER DEFAULT 0,
        tribute_value INTEGER DEFAULT 0,
        stack_size INTEGER DEFAULT 0,
        clickable TEXT,
        augtype INTEGER DEFAULT 0,
        strength INTEGER DEFAULT 0,
        dexterity INTEGER DEFAULT 0,
        agility INTEGER DEFAULT 0,
        stamina INTEGER DEFAULT 0,
        intelligence INTEGER DEFAULT 0,
        wisdom INTEGER DEFAULT 0,
        charisma INTEGER DEFAULT 0,
        mana INTEGER DEFAULT 0,
        hp INTEGER DEFAULT 0,
        ac INTEGER DEFAULT 0,
        regen_hp INTEGER DEFAULT 0,
        regen_mana INTEGER DEFAULT 0,
        haste INTEGER DEFAULT 0,
        classes INTEGER DEFAULT 0,
        class_list TEXT DEFAULT 'All',
        svfire INTEGER DEFAULT 0,
        svcold INTEGER DEFAULT 0,
        svdisease INTEGER DEFAULT 0,
        svpoison INTEGER DEFAULT 0,
        svcorruption INTEGER DEFAULT 0,
        svmagic INTEGER DEFAULT 0,
        spelldamage INTEGER DEFAULT 0,
        spellshield INTEGER DEFAULT 0,
        damage INTEGER DEFAULT 0,
        weight INTEGER DEFAULT 0,
        item_size INTEGER DEFAULT 0,
        weightreduction INTEGER DEFAULT 0,
        races INTEGER DEFAULT 0,
        race_list TEXT DEFAULT 'All',
        icon INTEGER,
        item_range INTEGER DEFAULT 0,
        attack INTEGER DEFAULT 0,
        collectible INTEGER DEFAULT 0,
        strikethrough INTEGER DEFAULT 0,
        heroicagi INTEGER DEFAULT 0,
        heroiccha INTEGER DEFAULT 0,
        heroicdex INTEGER DEFAULT 0,
        heroicint INTEGER DEFAULT 0,
        heroicsta INTEGER DEFAULT 0,
        heroicstr INTEGER DEFAULT 0,
        heroicsvcold INTEGER DEFAULT 0,
        heroicsvcorruption INTEGER DEFAULT 0,
        heroicsvdisease INTEGER DEFAULT 0,
        heroicsvfire INTEGER DEFAULT 0,
        heroicsvmagic INTEGER DEFAULT 0,
        heroicsvpoison INTEGER DEFAULT 0,
        heroicwis INTEGER DEFAULT 0,
        link TEXT
        );
        ]])
        db:exec("CREATE INDEX IF NOT EXISTS idx_item_name ON Items (name);")
        db:exec("COMMIT")
        db:close()

        -- load the items database
        db = loot.OpenItemsSQL()
        -- Set up the Items DB
        db:exec("BEGIN TRANSACTION")

        for id, name in pairs(loot.ItemNames) do
            loot.GetItemFromDB(name, id, true, db)
        end

        db:exec("COMMIT")
        db:close()

        loot.LoadHistoricalData()
    end
    loot.Settings = {}
    loot.Settings = tmpSettings

    loot.guiLoot.openGUI = loot.Settings.ShowConsole
    -- Modules:ExecModule("Loot", "ModifyLootSettings")


    return needSave
end

---comment Retrieve item data from the DB
---@param itemName string The name of the item to retrieve. [string]
---@param itemID integer|nil The ID of the item to retrieve. [integer] [optional]
---@param rules boolean|nil If true, only load items with rules (exact name matches) [boolean] [optional]
---@param db any DB Connection SQLite3 [optional]
---@return integer Quantity of items found
function loot.GetItemFromDB(itemName, itemID, rules, db)
    if not itemID and not itemName then return 0 end

    itemID = itemID or 0
    itemName = itemName or 'NULL'
    db = db or loot.OpenItemsSQL()

    local query = rules and "SELECT * FROM Items WHERE item_id = ? ORDER BY name"
        or "SELECT * FROM Items WHERE item_id = ? OR name LIKE ? ORDER BY name"

    local stmt = db:prepare(query)
    stmt:bind(1, itemID)
    if not rules then stmt:bind(2, "%" .. itemName .. "%") end

    local rowsFetched = 0
    for row in stmt:nrows() do
        local id = row.item_id
        if id then
            local itemData = {
                Name = row.name or 'NULL',
                NoDrop = row.nodrop == 1,
                NoTrade = row.notrade == 1,
                Tradeskills = row.tradeskill == 1,
                Quest = row.quest == 1,
                Lore = row.lore == 1,
                Augment = row.augment == 1,
                Stackable = row.stackable == 1,
                Value = loot.valueToCoins(row.sell_value),
                Tribute = row.tribute_value,
                StackSize = row.stack_size,
                Clicky = row.clickable or 'None',
                AugType = row.augtype,
                STR = row.strength,
                DEX = row.dexterity,
                AGI = row.agility,
                STA = row.stamina,
                INT = row.intelligence,
                WIS = row.wisdom,
                CHA = row.charisma,
                Mana = row.mana,
                HP = row.hp,
                AC = row.ac,
                HPRegen = row.regen_hp,
                ManaRegen = row.regen_mana,
                Haste = row.haste,
                Classes = row.classes,
                ClassList = row.class_list:gsub(" ", '') ~= '' and row.class_list or 'All',
                svFire = row.svfire,
                svCold = row.svcold,
                svDisease = row.svdisease,
                svPoison = row.svpoison,
                svCorruption = row.svcorruption,
                svMagic = row.svmagic,
                SpellDamage = row.spelldamage,
                SpellShield = row.spellshield,
                Damage = row.damage,
                Weight = row.weight / 10,
                Size = row.item_size,
                WeightReduction = row.weightreduction,
                Races = row.races,
                RaceList = row.race_list or 'All',
                Icon = row.icon,
                Attack = row.attack,
                Collectible = row.collectible == 1,
                StrikeThrough = row.strikethrough,
                HeroicAGI = row.heroicagi,
                HeroicCHA = row.heroiccha,
                HeroicDEX = row.heroicdex,
                HeroicINT = row.heroicint,
                HeroicSTA = row.heroicsta,
                HeroicSTR = row.heroicstr,
                HeroicSvCold = row.heroicsvcold,
                HeroicSvCorruption = row.heroicsvcorruption,
                HeroicSvDisease = row.heroicsvdisease,
                HeroicSvFire = row.heroicsvfire,
                HeroicSvMagic = row.heroicsvmagic,
                HeroicSvPoison = row.heroicsvpoison,
                HeroicWIS = row.heroicwis,
                Link = row.link,
            }
            loot.ALLITEMS[id] = itemData
            rowsFetched = rowsFetched + 1
        end
    end
    stmt:finalize()

    return rowsFetched
end

function loot.addMyInventoryToDB()
    local counter = 0
    local counterBank = 0
    Logger.Info(loot.guiLoot.console, "\atImporting Inventory\ax into the DB")

    for i = 1, 22 do
        if i < 11 then
            -- Items in Bags and Main Inventory
            local bagSlot       = mq.TLO.InvSlot('pack' .. i).Item
            local containerSize = bagSlot.Container()
            if bagSlot() ~= nil then
                loot.addToItemDB(bagSlot)
                counter = counter + 1
                if containerSize then
                    mq.delay(5) -- Delay to prevent spamming the DB
                    for j = 1, containerSize do
                        local item = bagSlot.Item(j)
                        if item and item.ID() then
                            loot.addToItemDB(item)
                            counter = counter + 1
                            mq.delay(10)
                        end
                    end
                end
            end
        else
            -- Worn Items
            local invItem = mq.TLO.Me.Inventory(i)
            if invItem() ~= nil then
                loot.addToItemDB(invItem)
                counter = counter + 1
                mq.delay(10) -- Delay to prevent spamming the DB
            end
        end
    end
    -- Banked Items
    for i = 1, 24 do
        local bankSlot = mq.TLO.Me.Bank(i)
        local bankBagSize = bankSlot.Container()
        if bankSlot() ~= nil then
            loot.addToItemDB(bankSlot)
            counterBank = counterBank + 1
            if bankBagSize then
                mq.delay(5) -- Delay to prevent spamming the DB
                for j = 1, bankBagSize do
                    local item = bankSlot.Item(j)
                    if item and item.ID() then
                        loot.addToItemDB(item)
                        counterBank = counterBank + 1
                        mq.delay(10)
                    end
                end
            end
        end
    end
    Logger.Info(loot.guiLoot.console, "\at%s \axImported \ag%d\ax items from \aoInventory\ax, and \ag%d\ax items from the \ayBank\ax, into the DB", MyName, counter, counterBank)
    loot.report(string.format("%s Imported %d items from Inventory, and %d items from the Bank, into the DB", MyName, counter, counterBank))
    local message = { who = MyName, Server = eqServer, action = 'ItemsDB_UPDATE', }
    loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, message)
    loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, message)
end

function loot.addToItemDB(item)
    if item == nil then
        if mq.TLO.Cursor() ~= nil then
            item = mq.TLO.Cursor
        else
            Logger.Error(loot.guiLoot.console, "Item is \arnil.")
            return
        end
    end
    if loot.ItemNames[item.ID()] ~= nil then return end

    -- insert the item into the database

    local db = SQLite3.open(lootDB)

    if not db then
        Logger.Error(loot.guiLoot.console, "\arFailed to open\ax loot database.")
        return
    end
    db:exec("PRAGMA journal_mode=WAL;")
    local sql  = [[
        INSERT INTO Items (
        item_id, name, nodrop, notrade, tradeskill, quest, lore, augment,
        stackable, sell_value, tribute_value, stack_size, clickable, augtype,
        strength, dexterity, agility, stamina, intelligence, wisdom,
        charisma, mana, hp, ac, regen_hp, regen_mana, haste, link, weight, classes, class_list,
        svfire, svcold, svdisease, svpoison, svcorruption, svmagic, spelldamage, spellshield, races, race_list, collectible,
        attack, damage, weightreduction, item_size, icon, strikethrough, heroicagi, heroiccha, heroicdex, heroicint,
        heroicsta, heroicstr, heroicsvcold, heroicsvcorruption, heroicsvdisease, heroicsvfire, heroicsvmagic, heroicsvpoison,
        heroicwis
        )
        VALUES (
        ?,?,?,?,?,?,?,?,?,?,
        ?,?,?,?,?,?,?,?,?,?,
        ?,?,?,?,?,?,?,?,?,?,
        ?,?,?,?,?,?,?,?,?,?,
        ?,?,?,?,?,?,?,?,?,?,
        ?,?,?,?,?,?,?,?,?,?,
        ?
        )
        ON CONFLICT(item_id) DO UPDATE SET
        name                                    = excluded.name,
        nodrop                                    = excluded.nodrop,
        notrade                                    = excluded.notrade,
        tradeskill                                    = excluded.tradeskill,
        quest                                    = excluded.quest,
        lore                                    = excluded.lore,
        augment                                    = excluded.augment,
        stackable                                    = excluded.stackable,
        sell_value                                    = excluded.sell_value,
        tribute_value                                    = excluded.tribute_value,
        stack_size                                    = excluded.stack_size,
        clickable                                    = excluded.clickable,
        augtype                                    = excluded.augtype,
        strength                                    = excluded.strength,
        dexterity                                    = excluded.dexterity,
        agility                                    = excluded.agility,
        stamina                                    = excluded.stamina,
        intelligence                                    = excluded.intelligence,
        wisdom                                    = excluded.wisdom,
        charisma                                    = excluded.charisma,
        mana                                    = excluded.mana,
        hp                                    = excluded.hp,
        ac                                    = excluded.ac,
        regen_hp                                    = excluded.regen_hp,
        regen_mana                                    = excluded.regen_mana,
        haste                                    = excluded.haste,
        link                                    = excluded.link,
        weight                                    = excluded.weight,
        item_size                                    = excluded.item_size,
        classes                                    = excluded.classes,
        class_list                                    = excluded.class_list,
        svfire                                    = excluded.svfire,
        svcold                                    = excluded.svcold,
        svdisease                                    = excluded.svdisease,
        svpoison                                    = excluded.svpoison,
        svcorruption                                    = excluded.svcorruption,
        svmagic                                    = excluded.svmagic,
        spelldamage                                    = excluded.spelldamage,
        spellshield                                    = excluded.spellshield,
        races                                    = excluded.races,
        race_list                               = excluded.race_list,
        collectible                                    = excluded.collectible,
        attack                                    = excluded.attack,
        damage                                    = excluded.damage,
        weightreduction                                    = excluded.weightreduction,
        strikethrough                                    = excluded.strikethrough,
        heroicagi                                    = excluded.heroicagi,
        heroiccha                                    = excluded.heroiccha,
        heroicdex                                    = excluded.heroicdex,
        heroicint                                    = excluded.heroicint,
        heroicsta                                    = excluded.heroicsta,
        heroicstr                                    = excluded.heroicstr,
        heroicsvcold                                    = excluded.heroicsvcold,
        heroicsvcorruption                                    = excluded.heroicsvcorruption,
        heroicsvdisease                                    = excluded.heroicsvdisease,
        heroicsvfire                                    = excluded.heroicsvfire,
        heroicsvmagic                                    = excluded.heroicsvmagic,
        heroicsvpoison                                    = excluded.heroicsvpoison,
        heroicwis                                    = excluded.heroicwis
        ]]
    local stmt = db:prepare(sql)
    if not stmt then
        Logger.Error(loot.guiLoot.console, "\arFailed to prepare \ax[\ayINSERT\ax] \aoSQL\ax statement: \at%s", db:errmsg())
        db:close()
        return
    end

    local success, errmsg = pcall(function()
        stmt:bind_values(
            item.ID(),
            item.Name(),
            item.NoDrop() and 1 or 0,
            item.NoTrade() and 1 or 0,
            item.Tradeskills() and 1 or 0,
            item.Quest() and 1 or 0,
            item.Lore() and 1 or 0,
            item.AugType() > 0 and 1 or 0,
            item.Stackable() and 1 or 0,
            item.Value() or 0,
            item.Tribute() or 0,
            item.StackSize() or 0,
            item.Clicky() or nil,
            item.AugType() or 0,
            item.STR() or 0,
            item.DEX() or 0,
            item.AGI() or 0,
            item.STA() or 0,
            item.INT() or 0,
            item.WIS() or 0,
            item.CHA() or 0,
            item.Mana() or 0,
            item.HP() or 0,
            item.AC() or 0,
            item.HPRegen() or 0,
            item.ManaRegen() or 0,
            item.Haste() or 0,
            item.ItemLink('CLICKABLE')() or nil,
            (item.Weight() or 0) * 10,
            item.Classes() or 0,
            loot.retrieveClassList(item),
            item.svFire() or 0,
            item.svCold() or 0,
            item.svDisease() or 0,
            item.svPoison() or 0,
            item.svCorruption() or 0,
            item.svMagic() or 0,
            item.SpellDamage() or 0,
            item.SpellShield() or 0,
            item.Races() or 0,
            loot.retrieveRaceList(item),
            item.Collectible() and 1 or 0,
            item.Attack() or 0,
            item.Damage() or 0,
            item.WeightReduction() or 0,
            item.Size() or 0,
            item.Icon() or 0,
            item.StrikeThrough() or 0,
            item.HeroicAGI() or 0,
            item.HeroicCHA() or 0,
            item.HeroicDEX() or 0,
            item.HeroicINT() or 0,
            item.HeroicSTA() or 0,
            item.HeroicSTR() or 0,
            item.HeroicSvCold() or 0,
            item.HeroicSvCorruption() or 0,
            item.HeroicSvDisease() or 0,
            item.HeroicSvFire() or 0,
            item.HeroicSvMagic() or 0,
            item.HeroicSvPoison() or 0,
            item.HeroicWIS() or 0
        )
        stmt:step()
    end)

    if not success then
        Logger.Error(loot.guiLoot.console, "Error executing SQL statement: %s", errmsg)
    end
    db:exec("BEGIN TRANSACTION")
    stmt:finalize()
    db:exec("COMMIT")
    db:close()

    -- insert the item into the lua table for easier lookups

    local itemID                             = item.ID()
    loot.ItemNames[itemID]                   = item.Name()
    loot.ALLITEMS[itemID]                    = {}
    loot.ALLITEMS[itemID].Name               = item.Name()
    loot.ALLITEMS[itemID].NoDrop             = item.NoDrop()
    loot.ALLITEMS[itemID].NoTrade            = item.NoTrade()
    loot.ALLITEMS[itemID].Tradeskills        = item.Tradeskills()
    loot.ALLITEMS[itemID].Quest              = item.Quest()
    loot.ALLITEMS[itemID].Lore               = item.Lore()
    loot.ALLITEMS[itemID].Augment            = item.AugType() > 0
    loot.ALLITEMS[itemID].Stackable          = item.Stackable()
    loot.ALLITEMS[itemID].Value              = loot.valueToCoins(item.Value())
    loot.ALLITEMS[itemID].Tribute            = item.Tribute()
    loot.ALLITEMS[itemID].StackSize          = item.StackSize()
    loot.ALLITEMS[itemID].Clicky             = item.Clicky()
    loot.ALLITEMS[itemID].AugType            = item.AugType()
    loot.ALLITEMS[itemID].STR                = item.STR()
    loot.ALLITEMS[itemID].DEX                = item.DEX()
    loot.ALLITEMS[itemID].AGI                = item.AGI()
    loot.ALLITEMS[itemID].STA                = item.STA()
    loot.ALLITEMS[itemID].INT                = item.INT()
    loot.ALLITEMS[itemID].WIS                = item.WIS()
    loot.ALLITEMS[itemID].CHA                = item.CHA()
    loot.ALLITEMS[itemID].Mana               = item.Mana()
    loot.ALLITEMS[itemID].HP                 = item.HP()
    loot.ALLITEMS[itemID].AC                 = item.AC()
    loot.ALLITEMS[itemID].HPRegen            = item.HPRegen()
    loot.ALLITEMS[itemID].ManaRegen          = item.ManaRegen()
    loot.ALLITEMS[itemID].Haste              = item.Haste()
    loot.ALLITEMS[itemID].Classes            = item.Classes()
    loot.ALLITEMS[itemID].ClassList          = loot.retrieveClassList(item)
    loot.ALLITEMS[itemID].svFire             = item.svFire()
    loot.ALLITEMS[itemID].svCold             = item.svCold()
    loot.ALLITEMS[itemID].svDisease          = item.svDisease()
    loot.ALLITEMS[itemID].svPoison           = item.svPoison()
    loot.ALLITEMS[itemID].svCorruption       = item.svCorruption()
    loot.ALLITEMS[itemID].svMagic            = item.svMagic()
    loot.ALLITEMS[itemID].SpellDamage        = item.SpellDamage()
    loot.ALLITEMS[itemID].SpellShield        = item.SpellShield()
    loot.ALLITEMS[itemID].Damage             = item.Damage()
    loot.ALLITEMS[itemID].Weight             = item.Weight()
    loot.ALLITEMS[itemID].Size               = item.Size()
    loot.ALLITEMS[itemID].WeightReduction    = item.WeightReduction()
    loot.ALLITEMS[itemID].Races              = item.Races() or 0
    loot.ALLITEMS[itemID].RaceList           = loot.retrieveRaceList(item)
    loot.ALLITEMS[itemID].Icon               = item.Icon()
    loot.ALLITEMS[itemID].Attack             = item.Attack()
    loot.ALLITEMS[itemID].Collectible        = item.Collectible()
    loot.ALLITEMS[itemID].StrikeThrough      = item.StrikeThrough()
    loot.ALLITEMS[itemID].HeroicAGI          = item.HeroicAGI()
    loot.ALLITEMS[itemID].HeroicCHA          = item.HeroicCHA()
    loot.ALLITEMS[itemID].HeroicDEX          = item.HeroicDEX()
    loot.ALLITEMS[itemID].HeroicINT          = item.HeroicINT()
    loot.ALLITEMS[itemID].HeroicSTA          = item.HeroicSTA()
    loot.ALLITEMS[itemID].HeroicSTR          = item.HeroicSTR()
    loot.ALLITEMS[itemID].HeroicSvCold       = item.HeroicSvCold()
    loot.ALLITEMS[itemID].HeroicSvCorruption = item.HeroicSvCorruption()
    loot.ALLITEMS[itemID].HeroicSvDisease    = item.HeroicSvDisease()
    loot.ALLITEMS[itemID].HeroicSvFire       = item.HeroicSvFire()
    loot.ALLITEMS[itemID].HeroicSvMagic      = item.HeroicSvMagic()
    loot.ALLITEMS[itemID].HeroicSvPoison     = item.HeroicSvPoison()
    loot.ALLITEMS[itemID].HeroicWIS          = item.HeroicWIS()
    loot.ALLITEMS[itemID].Link               = item.ItemLink('CLICKABLE')()
end

function loot.valueToCoins(sellVal)
    local platVal   = math.floor(sellVal / 1000)
    local goldVal   = math.floor((sellVal % 1000) / 100)
    local silverVal = math.floor((sellVal % 100) / 10)
    local copperVal = sellVal % 10
    return string.format("%s pp %s gp %s sp %s cp", platVal, goldVal, silverVal, copperVal)
end

function loot.checkSpells(item_name)
    if string.find(item_name, "Spell: ") then
        return true
    end
    return false
end

function loot.addNewItem(corpseItem, itemRule, itemLink, corpseID)
    if not corpseItem or not itemRule then
        Logger.Warn(loot.guiLoot.console, "\aoInvalid parameters for addNewItem:\ax corpseItem=\at%s\ax, itemRule=\ag%s",
            tostring(corpseItem), tostring(itemRule))
        return
    end
    if loot.TempSettings.NewItemIDs == nil then
        loot.TempSettings.NewItemIDs = {}
    end
    -- Retrieve the itemID from corpseItem
    local itemID = corpseItem.ID()
    if not itemID then
        Logger.Warn(loot.guiLoot.console, "\arFailed to retrieve \axitemID\ar for corpseItem:\ax %s", tostring(corpseItem.Name()))
        return
    end
    if loot.NewItems[itemID] ~= nil then return end
    local isNoDrop        = corpseItem.NoDrop()
    loot.TempItemClasses  = loot.retrieveClassList(corpseItem)
    loot.TempItemRaces    = loot.retrieveRaceList(corpseItem)
    -- Add the new item to the loot.NewItems table
    loot.NewItems[itemID] = {
        Name       = corpseItem.Name(),
        ItemID     = itemID, -- Include itemID for display and handling
        Link       = itemLink,
        Rule       = isNoDrop and "CanUse" or itemRule,
        NoDrop     = isNoDrop,
        Icon       = corpseItem.Icon(),
        Lore       = corpseItem.Lore(),
        Tradeskill = corpseItem.Tradeskills(),
        Aug        = corpseItem.AugType() > 0,
        Stackable  = corpseItem.Stackable(),
        MaxStacks  = corpseItem.StackSize() or 0,
        SellPrice  = loot.valueToCoins(corpseItem.Value()),
        Classes    = loot.TempItemClasses,
        Races      = loot.TempItemRaces,
        CorpseID   = corpseID,
    }
    table.insert(loot.TempSettings.NewItemIDs, itemID)

    -- Increment the count of new items
    loot.NewItemsCount = loot.NewItemsCount + 1

    if loot.Settings.AutoShowNewItem then
        showNewItem = true
    end

    -- Notify the loot actor of the new item
    Logger.Info(loot.guiLoot.console, "\agNew Loot\ay Item Detected! \ax[\at %s\ax ]\ao Sending actors", corpseItem.Name())
    local newMessage = {
        who        = MyName,
        action     = 'new',
        item       = corpseItem.Name(),
        itemID     = itemID,
        Server     = eqServer,
        rule       = isNoDrop and "CanUse" or itemRule,
        classes    = loot.retrieveClassList(corpseItem),
        races      = loot.retrieveRaceList(corpseItem),
        link       = itemLink,
        lore       = corpseItem.Lore(),
        icon       = corpseItem.Icon(),
        aug        = corpseItem.AugType() > 0 and true or false,
        noDrop     = isNoDrop,
        tradeskill = corpseItem.Tradeskills(),
        stackable  = corpseItem.Stackable(),
        maxStacks  = corpseItem.StackSize() or 0,
        sellPrice  = loot.valueToCoins(corpseItem.Value()),
        corpse     = corpseID,
    }
    loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, newMessage)
    loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, newMessage)

    Logger.Info(loot.guiLoot.console, "\agAdding \ayNEW\ax item: \at%s \ay(\axID: \at%s\at) \axwith rule: \ag%s", corpseItem.Name(), itemID, itemRule)
end

function loot.checkCursor()
    local currentItem = nil
    while mq.TLO.Cursor() do
        -- can't do anything if there's nowhere to put the item, either due to no free inventory space
        -- or no slot of appropriate size
        if mq.TLO.Me.FreeInventory() == 0 or mq.TLO.Cursor() == currentItem then
            if loot.Settings.SpamLootInfo then Logger.Debug(loot.guiLoot.console, 'Inventory full, item stuck on cursor') end
            mq.cmdf('/autoinv')
            return
        end
        currentItem = mq.TLO.Cursor()
        mq.cmdf('/autoinv')
        mq.delay(10000, function() return not mq.TLO.Cursor() end)
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

---comment: Takes in an item to modify the rules for, You can add, delete, or modify the rules for an item.
---Upon completeion it will notify the loot actor to update the loot settings, for any other character that is using the loot actor.
---@param itemID integer The ID for the item we are modifying
---@param action string The action to perform (add, delete, modify)
---@param tableName string The table to modify
---@param classes string The classes to apply the rule to
---@param link string|nil The item link if available for the item
function loot.modifyItemRule(itemID, action, tableName, classes, link)
    if not itemID or not tableName or not action then
        Logger.Warn(loot.guiLoot.console, "Invalid parameters for modifyItemRule. itemID: %s, tableName: %s, action: %s",
            tostring(itemID), tostring(tableName), tostring(action))
        return
    end

    local section = tableName == "Normal_Rules" and "NormalItems" or "GlobalItems"
    section = tableName == loot.PersonalTableName and 'PersonalItems' or section
    -- Validate RulesDB
    if not RulesDB or type(RulesDB) ~= "string" then
        Logger.Warn(loot.guiLoot.console, "Invalid RulesDB path: %s", tostring(RulesDB))
        return
    end

    -- Retrieve the item name from loot.ALLITEMS
    local itemName = loot.ALLITEMS[itemID] and loot.ALLITEMS[itemID].Name
    if not itemName then
        Logger.Warn(loot.guiLoot.console, "Item ID \at%s\ax \arNOT\ax found in \ayloot.ALLITEMS", tostring(itemID))
        return
    end

    -- Set default values
    if link == nil then
        link = loot.ALLITEMS[itemID].Link or 'NULL'
    end
    classes  = classes or 'All'

    -- Open the database
    local db = SQLite3.open(RulesDB)
    if not db then
        Logger.Warn(loot.guiLoot.console, "Failed to open database.")
        return
    end

    local stmt
    local sql
    db:exec("PRAGMA journal_mode=WAL;")
    db:exec("BEGIN TRANSACTION")
    if action == 'delete' then
        -- DELETE operation
        Logger.Info(loot.guiLoot.console, "\aoloot.modifyItemRule\ax \arDeleting rule\ax for item \at%s\ax in table \at%s", itemName, tableName)
        sql = string.format("DELETE FROM %s WHERE item_id = ?", tableName)
        stmt = db:prepare(sql)

        if stmt then
            stmt:bind_values(itemID)
        end
    else
        -- UPSERT operation
        -- if tableName == "Normal_Rules" then
        sql  = string.format([[
                INSERT INTO %s
                (item_id, item_name, item_rule, item_rule_classes, item_link)
                VALUES (?, ?, ?, ?, ?)
                ON CONFLICT(item_id) DO UPDATE SET
                item_name                                    = excluded.item_name,
                item_rule                                    = excluded.item_rule,
                item_rule_classes                                    = excluded.item_rule_classes,
                item_link                                    = excluded.item_link
                ]], tableName)
        stmt = db:prepare(sql)
        if stmt then
            stmt:bind_values(itemID, itemName, action, classes, link)
        end
    end

    if not stmt then
        Logger.Warn(loot.guiLoot.console, "Failed to prepare SQL statement for table: %s, item:%s (%s), rule: %s, classes: %s", tableName, itemName, itemID, action, classes)
        db:close()
        return
    end

    -- Execute the statement
    local success, errmsg = pcall(function() stmt:step() end)
    if not success then
        Logger.Warn(loot.guiLoot.console, "Failed to execute SQL statement for table %s. Error: %s", tableName, errmsg)
    else
        Logger.Debug(loot.guiLoot.console, "SQL statement executed successfully for item %s in table %s.", itemName, tableName)
    end

    -- Finalize and close the database
    stmt:finalize()
    db:exec("COMMIT")
    db:close()

    if success then
        -- Notify other actors about the rule change
        local message = {
            who     = MyName,
            Server  = eqServer,
            action  = action ~= 'delete' and 'addrule' or 'deleteitem',
            item    = itemName,
            itemID  = itemID,
            rule    = action,
            section = section,
            link    = link,
            classes = classes,
        }
        loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, message)
        loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, message)
    end
end

---comment
---@param itemID integer
---@param section string
---@param rule string
---@param classes string
---@param link string
---@return boolean success
function loot.addRule(itemID, section, rule, classes, link)
    if not itemID or not section or not rule then
        Logger.Warn(loot.guiLoot.console, "Invalid parameters for addRule. itemID: %s, section: %s, rule: %s",
            tostring(itemID), tostring(section), tostring(rule))
        return false
    end

    -- Retrieve the item name from loot.ALLITEMS
    local itemName = loot.ALLITEMS[itemID] and loot.ALLITEMS[itemID].Name or nil
    if not itemName then
        Logger.Warn(loot.guiLoot.console, "Item ID \at%s\ax \arNOT\ax found in \ayloot.ALLITEMS", tostring(itemID))
        return false
    end

    -- Set default values for optional parameters
    classes                            = classes or 'All'
    link                               = link or 'NULL'

    -- Log the action
    -- Logger.Info(loot.guiLoot.console,"\agAdding\ax rule for item \at%s\ax\ao (\ayID\ax:\ag %s\ax\ao)\ax in [section] \at%s \axwith [rule] \at%s\ax and [classes] \at%s",
    -- itemName, itemID, section, rule, classes)

    -- Update the in-memory data structure
    loot.ItemNames[itemID]             = itemName

    loot[section .. "Rules"][itemID]   = rule
    loot[section .. "Classes"][itemID] = classes
    loot[section .. "Link"][itemID]    = link
    local tblName                      = section == 'GlobalItems' and 'Global_Rules' or 'Normal_Rules'
    if section == 'PersonalItems' then
        tblName = loot.PersonalTableName
    end
    loot.modifyItemRule(itemID, rule, tblName, classes, link)


    -- Refresh the loot settings to apply the changes
    return true
end

function loot.actorAddRule(itemID, itemName, tableName, rule, classes, link)
    loot.ItemNames[itemID]               = itemName

    loot[tableName .. "Rules"][itemID]   = rule
    loot[tableName .. "Classes"][itemID] = classes
    loot[tableName .. "Link"][itemID]    = link
    local tblName                        = tableName == 'GlobalItems' and 'Global_Rules' or 'Normal_Rules'
    if tableName == 'PersonalItems' then
        tblName = loot.PersonalTableName
    end
    loot.modifyItemRule(itemID, rule, tblName, classes, link)
end

---@param itemID any
---@param tablename any|nil
---@return string rule
---@return string classes
---@return string link
function loot.lookupLootRule(itemID, tablename)
    if not itemID then
        return 'NULL', 'All', 'NULL'
    end
    -- check lua tables first
    if tablename == 'Global_Rules' then
        if loot.GlobalItemsRules[itemID] ~= nil then
            return loot.GlobalItemsRules[itemID], loot.GlobalItemsClasses[itemID], loot.GlobalItemsLink[itemID]
        end
    elseif tablename == 'Normal_Rules' then
        if loot.NormalItemsRules[itemID] ~= nil then
            return loot.NormalItemsRules[itemID], loot.NormalItemsClasses[itemID], loot.NormalItemsLink[itemID]
        end
    elseif tablename == loot.PersonalTableName then
        if loot.PersonalItemsRules[itemID] ~= nil then
            return loot.PersonalItemsRules[itemID], loot.PersonalItemsClasses[itemID], loot.PersonalItemsLink[itemID]
        end
    elseif tablename == nil then
        if loot.PersonalItemsRules[itemID] ~= nil then
            return loot.PersonalItemsRules[itemID], loot.PersonalItemsClasses[itemID], loot.PersonalItemsLink[itemID]
        end
        if loot.GlobalItemsRules[itemID] ~= nil then
            return loot.GlobalItemsRules[itemID], loot.GlobalItemsClasses[itemID], loot.GlobalItemsLink[itemID]
        end
        if loot.NormalItemsRules[itemID] ~= nil then
            return loot.NormalItemsRules[itemID], loot.NormalItemsClasses[itemID], loot.NormalItemsLink[itemID]
        end
    end

    -- check SQLite DB if lua tables don't have the data
    local function checkDB(id, tbl)
        local db = SQLite3.open(RulesDB)
        local found = false
        if not db then
            Logger.Warn(loot.guiLoot.console, "\atSQL \arFailed\ax to open \atRulesDB:\ax for \aolookupLootRule\ax.")
            return found, 'NULL', 'All', 'NULL'
        end
        db:exec("PRAGMA journal_mode=WAL;")
        local sql  = string.format("SELECT item_rule, item_rule_classes, item_link FROM %s WHERE item_id = ?", tbl)
        local stmt = db:prepare(sql)

        if not stmt then
            Logger.Warn(loot.guiLoot.console, "\atSQL \arFAILED \axto prepare statement for \atlookupLootRule\ax.")
            db:close()
            return found, 'NULL', 'All', 'NULL'
        end

        stmt:bind_values(id)
        local stepResult = stmt:step()

        local rule       = 'NULL'
        local classes    = 'All'
        local link       = 'NULL'

        -- Extract values if a row is returned
        if stepResult == SQLite3.ROW then
            local row = stmt:get_named_values()
            rule      = row.item_rule or 'NULL'
            classes   = row.item_rule_classes or 'All'
            link      = row.item_link or 'NULL'
            found     = true
        end
        if classes == 'None' or classes:gsub(" ", '') == '' then
            classes = 'All'
        end
        -- Finalize the statement and close the database
        stmt:finalize()
        db:close()
        return found, rule, classes, link
    end

    local rule    = 'NULL'
    local classes = 'All'
    local link    = 'NULL'

    if tablename == nil then
        -- check global rules
        local found = false
        found, rule, classes, link = checkDB(itemID, loot.PersonalTableName)
        if not found then
            found, rule, classes, link = checkDB(itemID, 'Global_Rules')
        end
        if not found then
            found, rule, classes, link = checkDB(itemID, 'Normal_Rules')
        end

        if not found then
            rule = 'NULL'
            classes = 'All'
            link = 'NULL'
        end
    else
        _, rule, classes, link = checkDB(itemID, tablename)
    end

    -- if SQL has the item add the rules to the lua table for next time

    if rule ~= 'NULL' then
        local localTblName                      = tablename == 'Global_Rules' and 'GlobalItems' or 'NormalItems'
        localTblName                            = tablename == loot.PersonalTableName and 'PersonalItems' or localTblName

        loot[localTblName .. 'Rules'][itemID]   = rule
        loot[localTblName .. 'Classes'][itemID] = classes
        loot[localTblName .. 'Link'][itemID]    = link
        loot.ItemNames[itemID]                  = loot.ALLITEMS[itemID].Name
    end
    return rule, classes, link
end

function loot.report(message, ...)
    if loot.Settings.ReportLoot then
        local prefixWithChannel = reportPrefix:format(loot.Settings.LootChannel, mq.TLO.Time())
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

function loot.processPendingItem()
    if not loot.pendingItemData and not loot.pendingItemData.selectedItem then
        Logger.Warn(loot.guiLoot.console, "No item selected for processing.")
        return
    end

    -- Extract the selected item and callback
    local selectedItem = loot.pendingItemData.selectedItem
    local callback     = loot.pendingItemData.callback

    -- Call the callback with the selected item
    if callback then
        callback(selectedItem)
    else
        Logger.Warn(loot.guiLoot.console, "No callback defined for selected item.")
    end

    -- Clear pending data after processing
    loot.pendingItemData = nil
end

function loot.resolveDuplicateItems(itemName, duplicates, callback)
    loot.itemSelectionPending = true
    loot.pendingItemData      = { callback = callback, }

    -- Render the selection UI
    ImGui.SetNextWindowSize(400, 300, ImGuiCond.FirstUseEver)
    local open = ImGui.Begin("Resolve Duplicates", true)
    if open then
        ImGui.Text("Multiple items found for: " .. itemName)
        ImGui.Separator()

        for _, item in ipairs(duplicates) do
            if ImGui.Button("Select##" .. item.ID) then
                loot.itemSelectionPending         = false
                loot.pendingItemData.selectedItem = item.ID
                ImGui.CloseCurrentPopup()
                callback(item.ID) -- Trigger the callback with the selected ID
                break
            end
            ImGui.SameLine()
            ImGui.Text(item.Link)
        end
    end
    ImGui.End()
end

function loot.getMatchingItemsByName(itemName)
    local matches = {}
    for _, item in pairs(loot.ALLITEMS) do
        if item.Name == itemName then
            table.insert(matches, item)
        end
    end
    return matches
end

function loot.getRuleIndex(rule, ruleList)
    for i, v in ipairs(ruleList) do
        if v == rule then
            return i
        end
    end
    return 1
end

function loot.retrieveClassList(item)
    local classList = ""
    local numClasses = item.Classes()
    if numClasses == 0 then return 'None' end
    if numClasses < 16 then
        for i = 1, numClasses do
            classList = string.format("%s %s", classList, item.Class(i).ShortName())
        end
    else
        classList = "All"
    end
    return classList
end

function loot.retrieveRaceList(item)
    local racesShort = {
        ['Human'] = 'HUM',
        ['Barbarian'] = 'BAR',
        ['Erudite'] = 'ERU',
        ['Wood Elf'] = 'ELF',
        ['High Elf'] = 'HIE',
        ['Dark Elf'] = 'DEF',
        ['Half Elf'] = 'HEF',
        ['Dwarf'] = 'DWF',
        ['Troll'] = 'TRL',
        ['Ogre'] = 'OGR',
        ['Halfling'] = 'HFL',
        ['Gnome'] = 'GNM',
        ['Iksar'] = 'IKS',
        ['Vah Shir'] = 'VAH',
        ['Froglok'] = 'FRG',
        ['Drakkin'] = 'DRK',
    }
    local raceList = ""
    local numRaces = item.Races() or 16
    if numRaces < 16 then
        for i = 1, numRaces do
            local raceName = racesShort[item.Race(i).Name()] or ''
            raceList = string.format("%s %s", raceList, raceName)
        end
    else
        raceList = "All"
    end
    return raceList
end

---@param itemName string Item's Name
---@param allowDuplicates boolean|nil optional just return first matched item_id
---@return integer|nil ItemID or nil if no matches found
function loot.resolveItemIDbyName(itemName, allowDuplicates)
    if allowDuplicates == nil then allowDuplicates = false end
    local matches = {}

    local foundItems = loot.GetItemFromDB(itemName, 0)

    if foundItems > 1 and not allowDuplicates then
        Logger.Warn(loot.guiLoot.console, "\ayMultiple \atMatches Found for ItemName: \am%s \ax #\ag%d\ax", itemName, foundItems)
    end

    for id, item in pairs(loot.ALLITEMS or {}) do
        if item.Name:lower() == itemName:lower() then
            if allowDuplicates and item.Value ~= '0 pp 0 gp 0 sp 0 cp' and item.Value ~= nil then
                table.insert(matches,
                    { ID = id, Link = item.Link, Name = item.Name, Value = item.Value, })
            else
                table.insert(matches,
                    { ID = id, Link = item.Link, Name = item.Name, Value = item.Value, })
            end
        end
    end

    if allowDuplicates then
        return matches[1].ID
    end

    if #matches == 0 then
        return nil           -- No matches found
    elseif #matches == 1 then
        return matches[1].ID -- Single match
    else
        -- Display a selection window to the user
        loot.resolveDuplicateItems(itemName, matches, function(selectedItemID)
            loot.pendingItemData.selectedItem = selectedItemID
        end)
        return nil -- Wait for user resolution
    end
end

function loot.sendMySettings()
    local tmpTable = {}
    for k, v in pairs(loot.Settings) do
        if type(v) == 'table' then
            tmpTable[k] = {}
            for kk, vv in pairs(v) do
                tmpTable[k][kk] = vv
            end
        else
            tmpTable[k] = v
        end
    end
    local message = {
        who      = MyName,
        action   = 'sendsettings',
        settings = tmpTable,
    }
    loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, message)
    loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, message)

    loot.Boxes[MyName] = {}
    for k, v in pairs(loot.Settings) do
        if type(v) == 'table' then
            loot.Boxes[MyName][k] = {}
            for kk, vv in pairs(v) do
                loot.Boxes[MyName][k][kk] = vv
            end
        else
            loot.Boxes[MyName][k] = v
        end
    end
    loot.TempSettings.LastSent = os.time()
end

--- Evaluate and return the rule for an item.
---@param item MQItem Item object
---@param from string Source of the of the callback (loot, bank, etc.)
---@return string Rule The Loot Rule or decision of no Rule
---@return integer Count The number of items to keep if Quest Item
---@return boolean newRule True if Item does not exist in the Rules Tables
---@return boolean|nil cantWear True if the item is not wearable by the character
function loot.getRule(item, from, index)
    if item == nil then return 'NULL', 0, false end
    local itemID = item.ID() or 0
    if itemID == 0 then return 'NULL', 0, false end

    -- Initialize values
    local lootDecision                    = 'Keep'
    local tradeskill                      = item.Tradeskills()
    local sellPrice                       = (item.Value() or 0) / 1000
    local stackable                       = item.Stackable()
    local isAug                           = (item.AugType() or 0) > 0
    local tributeValue                    = item.Tribute() or 0
    local stackSize                       = item.StackSize()
    local countHave                       = mq.TLO.FindItemCount(item.Name())() + mq.TLO.FindItemBankCount(item.Name())()
    local itemName                        = item.Name()
    local newRule                         = false
    local alwaysAsk                       = false
    local qKeep                           = 0
    local iCanUse                         = true
    local freeSpace                       = mq.TLO.Me.FreeInventory()
    local lootActionPreformed             = "Looted"
    local equpiable                       = (item.WornSlots() or 0) > 0
    local newNoDrop                       = false
    -- Lookup existing rule in the databases
    local lootRule, lootClasses, lootLink = loot.lookupLootRule(itemID)
    Logger.Info(loot.guiLoot.console, "\aoLookup Rule\ax: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootRule, lootClasses, itemName, lootLink)
    if lootRule == 'NULL' and item.NoDrop() then
        lootRule = "Ask"
        loot.addRule(itemID, 'NormalItems', lootRule, lootClasses, item.ItemLink('CLICKABLE')())
    end


    if lootRule == 'Ask' then alwaysAsk = true end

    -- -- Update link if missing and rule exists
    -- if lootRule ~= "NULL" and lootLink == "NULL" then
    --     loot.addRule(itemID, 'NormalItems', lootRule, lootClasses, item.ItemLink('CLICKABLE')())
    -- end

    if tradeskill and not loot.Settings.BankTradeskills and lootRule == "Bank" then
        lootRule = "NULL"
    end


    -- Re-evaluate settings if AlwaysEval is enabled
    if loot.Settings.AlwaysEval then
        local resetDecision = "NULL"
        if lootRule == "Quest" or lootRule == "Keep" or lootRule == "Destroy" or lootRule == 'CanUse' then
            resetDecision = lootRule
        elseif lootRule == "Sell" then
            if (not stackable and sellPrice >= loot.Settings.MinSellPrice) or
                (stackable and sellPrice * stackSize >= loot.Settings.StackPlatValue) then
                resetDecision = lootRule
            end
        elseif lootRule == "Bank" and tradeskill and loot.Settings.BankTradeskills then
            resetDecision = lootRule
        end
        lootRule = resetDecision
    end
    -- local baseRule = "Ignore"

    local function checkDecision()
        -- handle sell and tribute
        if not stackable and sellPrice < loot.Settings.MinSellPrice then lootDecision = "Ignore" end
        if not stackable and loot.Settings.StackableOnly then lootDecision = "Ignore" end
        if stackable and sellPrice * stackSize < loot.Settings.StackPlatValue then lootDecision = "Ignore" end
        if tributeValue >= loot.Settings.MinTributeValue and sellPrice < loot.Settings.MinSellPrice then lootDecision = "Tribute" end
        if loot.Settings.AutoTag and lootDecision == "Keep" then
            if not stackable and sellPrice > loot.Settings.MinSellPrice then lootDecision = "Sell" end
            if stackable and sellPrice * stackSize >= loot.Settings.StackPlatValue then lootDecision = "Sell" end
        end

        -- if sellPrice > 0 then baseRule = "Sell" end
        -- if sellPrice == 0 and tributeValue > 0 then baseRule = "Tribute" end
    end

    local function checkWearable()
        if equpiable then
            if (loot.Settings.CanWear and lootDecision == 'Keep') or lootDecision == 'CanUse' or isNoDrop then
                if not item.CanUse() then
                    lootDecision = 'Ignore'
                    iCanUse = false
                    Logger.Debug(loot.guiLoot.console, "\aoLookup Decision \ax\agWEARABLE\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision,
                        lootClasses, itemName, lootLink)
                end
            end
        else
            if isNoDrop then
                iCanUse = false
            end
        end
    end
    -- if lootRule:lower() == ('sell' or 'tribute') then
    --     checkDecision()
    -- end

    -- Evaluate new rules if no valid rule exists
    if lootRule:lower() == "null" then
        checkDecision()
        -- if baseRule ~= 'Ignore' then
        --     loot.addRule(itemID, 'NormalItems', baseRule, "All", item.ItemLink('CLICKABLE')())
        --     newRule = true
        -- else
        loot.addRule(itemID, 'NormalItems', lootDecision, "All", item.ItemLink('CLICKABLE')())
        newRule = true
        -- end
    else
        lootDecision = lootRule
    end

    -- if baseRule ~= lootRule then
    -- loot.addRule(itemID, 'NormalItems', baseRule, "All", item.ItemLink('CLICKABLE')())
    -- newRule = true
    -- end
    local personalRule, personalClasses = loot.PersonalItemsRules[itemID] or "NULL", loot.PersonalItemsClasses[itemID] or "All"
    local globalRule, globalClasses = loot.GlobalItemsRules[itemID] or "NULL", loot.GlobalItemsClasses[itemID] or "All"

    -- Handle GlobalItems override
    if personalRule ~= "NULL" then
        lootDecision = personalRule
        lootClasses = personalClasses
    elseif loot.Settings.GlobalLootOn and globalRule ~= "NULL" then
        lootDecision = globalRule
        lootClasses = globalClasses
    end
    Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agOVERRIDES\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses, itemName,
        lootLink)

    -- Handle specific class-based rules
    if lootClasses:lower() ~= "all" and lootDecision:lower() == 'keep' then
        if from == "loot" and not string.find(lootClasses:lower(), loot.MyClass) then
            lootDecision = "Ignore"
        end
    end

    -- Handle augments
    if loot.Settings.LootAugments and isAug then
        lootDecision = "Keep"
        Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agAUGMENT\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses, itemName,
            lootLink)

        goto decided
    end

    -- Handle Quest items
    if string.find(lootDecision, "Quest") then
        if loot.Settings.LootQuest then
            local _, position = string.find(lootDecision, "|")
            if position then qKeep = tonumber(lootDecision:sub(position + 1)) else qKeep = loot.Settings.QuestKeep end
            if countHave < qKeep then
                lootDecision = "Keep"
            else
                lootDecision = "Ignore"
            end
            Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agQUEST\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses,
                itemName,
                lootLink)

            goto decided
        end
    end

    -- Handle Optionally Loot Only items you can use.


    if tradeskill and loot.Settings.BankTradeskills then
        lootDecision = "Bank"
        Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agBANK\ax Decision:: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses, itemName,
            lootLink)

        goto decided
    end

    -- Handle AlwaysKeep setting
    if alwaysAsk then
        newRule = true
        lootDecision = "Ask"
        Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agASK\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses, itemName,
            lootLink)
    end

    ::decided::
    if loot.Settings.CanWear or (isNoDrop and newRule) then
        checkWearable()
    end
    -- Handle Spell Drops
    if loot.Settings.KeepSpells and loot.checkSpells(itemName) then
        lootDecision = "Keep"
        Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agSPELLS\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses, itemName,
            lootLink)
    end

    -- Handle AlwaysDestroy setting
    if loot.Settings.AlwaysDestroy and lootDecision == "Ignore" then
        lootDecision = "Destroy"
        Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agALWAYSDESTROY\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses,
            itemName, lootLink)
    end


    -- Handle LootStackableOnly setting incase this was changed after the first check.
    if not stackable and loot.Settings.StackableOnly then
        lootDecision = "Ignore"
        Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agSTACKABLE_ONLY\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses,
            itemName, lootLink)
    end

    Logger.Debug(loot.guiLoot.console, "\aoLookup Decision \ax\ay Start\ax\ao FINAL CHECKS\ax: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision,
        lootClasses,
        itemName,
        lootLink)

    local freeStack = item.FreeStack()
    local isLore    = item.Lore()

    if isLore then
        local haveItem     = mq.TLO.FindItem(('=%s'):format(item.Name()))()
        local haveItemBank = mq.TLO.FindItemBank(('=%s'):format(item.Name()))()
        if haveItem or haveItemBank or freeSpace <= loot.Settings.SaveBagSlots then
            table.insert(loreItems, itemLink)
            lootDecision = 'Ignore'
            -- loot.lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
        elseif isNoDrop then
            if not loot.Settings.LootNoDrop then
                table.insert(noDropItems, itemLink)
                lootDecision = 'Ignore'
                -- loot.lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
            end
            -- else
            --     loot.lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
        end
        Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agLORE\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses, itemName,
            lootLink)
    end
    if isNoDrop then
        if not loot.Settings.LootNoDrop then
            table.insert(noDropItems, itemLink)
            lootDecision = 'Ignore'
        else
            if not newRule and not iCanUse then
                --         loot.lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                --     end
                -- else
                table.insert(noDropItems, itemLink)
                lootDecision = 'Ignore'
            elseif (newRule and loot.Settings.LootNoDropNew) and not iCanUse then
                table.insert(noDropItems, itemLink)
                lootDecision = 'Ask'
                -- loot.lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
            elseif (newRule and loot.Settings.LootNoDropNew) and iCanUse then
                lootDecision = 'Keep'
            end
        end
        Logger.Debug(loot.guiLoot.console, "\aoLookup \ax\agNODROP\ax Decision: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", lootDecision, lootClasses, itemName,
            lootLink)
    end
    if not (freeSpace > loot.Settings.SaveBagSlots or (stackable and freeStack > 0)) then
        -- loot.lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
        lootDecision = 'Ignore'
    end

    if newRule then
        -- if isNoDrop then itemRule = 'CanUse' end
        loot.addNewItem(item, lootDecision, itemLink, corpseID)
    end
    Logger.Debug(loot.guiLoot.console, "\aoLookup Decision \ax\agFINAL\ax: \at%s\ax, \ayClasses\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s",
        lootDecision, lootClasses, itemName, lootLink)

    if from == 'loot' then
        loot.lootItem(index, lootDecision, 'leftmouseup', qKeep)
    end

    return lootDecision, qKeep, newRule, iCanUse
end

-- EVENTS

function loot.RegisterActors()
    loot.lootActor = Actors.register('lootnscoot', function(message)
        local lootMessage = message()
        local who         = lootMessage.who or ''
        local action      = lootMessage.action or ''
        local itemID      = lootMessage.itemID or 0
        local rule        = lootMessage.rule or 'NULL'
        local section     = lootMessage.section or 'NormalItems'
        local server      = lootMessage.Server or 'NULL'
        local itemName    = lootMessage.item or 'NULL'
        local itemLink    = lootMessage.link or 'NULL'
        local itemClasses = lootMessage.classes or 'All'
        local itemRaces   = lootMessage.races or 'All'
        local boxSettings = lootMessage.settings or {}
        local directions  = lootMessage.directions or 'NULL'
        if directions == 'doloot' then
            loot.LootNow = true
            return
        end
        if itemName == 'NULL' then
            itemName = loot.ALLITEMS[itemID] and loot.ALLITEMS[itemID].Name or 'NULL'
        end
        if action == 'Hello' and who ~= MyName then
            loot.sendMySettings()
            return
        end
        Logger.Debug(loot.guiLoot.console, "loot.RegisterActors: \agReceived\ax message:\atSub \ay%s\aw, \atItem \ag%s\aw, \atRule \ag%s", action, itemID, rule)
        if action == 'sendsettings' and who ~= MyName then
            if loot.Boxes[who] ~= nil and os.difftime(os.time(), loot.TempSettings.LastSent) > 60 then
                return
            end
            if loot.Boxes[who] == nil then loot.Boxes[who] = {} end

            loot.Boxes[who] = {}
            for k, v in pairs(boxSettings) do
                if type(k) ~= 'table' then
                    loot.Boxes[who][k] = v
                else
                    loot.Boxes[who][k] = {}
                    for i, j in pairs(v) do
                        loot.Boxes[who][k][i] = j
                    end
                end
            end
        end

        if action == 'updatesettings' and who == MyName then
            for k, v in pairs(boxSettings) do
                if type(k) ~= 'table' then
                    loot.Settings[k] = v
                else
                    for i, j in pairs(v) do
                        loot.Settings[k][i] = j
                    end
                end
            end
            mq.pickle(SettingsFile, loot.Settings)
            loot.loadSettings()
            loot.sendMySettings()
        end
        if server ~= eqServer then return end

        -- Reload loot settings
        if action == 'reloadrules' and who ~= MyName then
            loot[lootMessage.bulkLabel .. 'Rules']   = {}
            loot[lootMessage.bulkLabel .. 'Classes'] = {}
            loot[lootMessage.bulkLabel .. 'Link']    = {}
            loot[lootMessage.bulkLabel .. 'Rules']   = lootMessage.bulkRules or {}
            loot[lootMessage.bulkLabel .. 'Classes'] = lootMessage.bulkClasses or {}
            loot[lootMessage.bulkLabel .. 'Link']    = lootMessage.bulkLink or {}
            return
        end
        -- Handle actions
        if lootMessage.noChange then
            if lootedCorpses[lootMessage.corpse] then
                lootedCorpses[lootMessage.corpse] = nil
            end

            loot.NewItems[itemID] = nil
            if loot.TempSettings.NewItemIDs ~= nil then
                for idx, id in ipairs(loot.TempSettings.NewItemIDs) do
                    if id == itemID then
                        table.remove(loot.TempSettings.NewItemIDs, idx)
                        break
                    end
                end
            end
            loot.NewItemsCount = loot.NewItemsCount - 1
            Logger.Info(loot.guiLoot.console, "loot.RegisterActors: \atNew Item Rule \ax\agConfirmed:\ax [\ay%s\ax] NewItemCount Remaining \ag%s\ax", itemLink, loot.NewItemsCount)
            return
        end

        if action == 'addrule' or action == 'modifyitem' then
            if section == 'PersonalItems' and who == MyName then
                loot.PersonalItemsRules[itemID]   = rule
                loot.PersonalItemsClasses[itemID] = itemClasses
                loot.PersonalItemsLink[itemID]    = itemLink
                loot.ItemNames[itemID]            = itemName
                Logger.Info(loot.guiLoot.console, "loot.RegisterActors: \atAction:\ax [\ay%s\ax]  \ayPersonal Rule\ax: \ag%s\ax for item \at%s\ax", action, rule, lootMessage.item)
            elseif section == 'GlobalItems' then
                loot.GlobalItemsRules[itemID]   = rule
                loot.GlobalItemsClasses[itemID] = itemClasses
                loot.GlobalItemsLink[itemID]    = itemLink
                loot.ItemNames[itemID]          = itemName
                Logger.Info(loot.guiLoot.console, "loot.RegisterActors: \atAction:\ax [\ay%s\ax] \atGlobal Rule\ax: \ag%s\ax for item \at%s\ax", action, rule, lootMessage.item)
            elseif section == 'NormalItems' then
                loot.NormalItemsRules[itemID]   = rule
                loot.NormalItemsClasses[itemID] = itemClasses
                loot.NormalItemsLink[itemID]    = itemLink
                loot.ItemNames[itemID]          = itemName
                Logger.Info(loot.guiLoot.console, "loot.RegisterActors: \atAction:\ax [\ay%s\ax] \aoNormal Rule\ax: \ag%s\ax for item \at%s\ax", action, rule, lootMessage.item)
            end

            if lootMessage.entered then
                if lootedCorpses[lootMessage.corpse] then
                    lootedCorpses[lootMessage.corpse] = nil
                end

                loot.NewItems[itemID] = nil
                if loot.TempSettings.NewItemIDs ~= nil then
                    for idx, id in ipairs(loot.TempSettings.NewItemIDs) do
                        if id == itemID then
                            table.remove(loot.TempSettings.NewItemIDs, idx)
                            break
                        end
                    end
                end
                loot.NewItemsCount = loot.NewItemsCount - 1
                Logger.Info(loot.guiLoot.console, "loot.RegisterActors: \atNew Item Rule \ax\agUpdated:\ax [\ay%s\ax] NewItemCount Remaining \ag%s\ax", lootMessage.entered,
                    loot.NewItemsCount)
            end

            local db = loot.OpenItemsSQL()
            loot.GetItemFromDB(itemName, itemID)
            db:close()
            loot.lookupLootRule(itemID)

            -- clean bags of items marked as destroy so we don't collect garbage
            if rule:lower() == 'destroy' then
                loot.TempSettings.NeedsCleanup = true
            end
        elseif action == 'deleteitem' and who ~= MyName then
            loot[section .. 'Rules'][itemID]   = nil
            loot[section .. 'Classes'][itemID] = nil
            loot[section .. 'Link'][itemID]    = nil
            Logger.Info(loot.guiLoot.console, "loot.RegisterActors: \atAction:\ax [\ay%s\ax] \ag%s\ax rule for item \at%s\ax", action, rule, lootMessage.item)
        elseif action == 'new' and who ~= MyName and loot.NewItems[itemID] == nil then
            loot.NewItems[itemID] = {
                Name       = lootMessage.item,
                Rule       = rule,
                Link       = itemLink,
                Lore       = lootMessage.lore,
                NoDrop     = lootMessage.noDrop,
                SellPrice  = lootMessage.sellPrice,
                Tradeskill = lootMessage.tradeskill,
                Icon       = lootMessage.icon or 0,
                MaxStacks  = lootMessage.maxStacks,
                Aug        = lootMessage.aug,
                Classes    = itemClasses,
                Races      = itemRaces,
                CorpseID   = lootMessage.corpse,
            }
            if loot.TempSettings.NewItemIDs == nil then
                loot.TempSettings.NewItemIDs = {}
            end
            table.insert(loot.TempSettings.NewItemIDs, itemID)
            Logger.Info(loot.guiLoot.console, "loot.RegisterActors: \atAction:\ax [\ay%s\ax] \ag%s\ax rule for item \at%s\ax", action, rule, lootMessage.item)
            loot.NewItemsCount = loot.NewItemsCount + 1
            if loot.Settings.AutoShowNewItem then
                showNewItem = true
            end
        elseif action == 'ItemsDB_UPDATE' and who ~= MyName then
            -- loot.LoadItemsDB()
        end

        -- Notify modules of loot setting changes
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
    mq.event("ForageExtras", "Your forage mastery has enabled you to find something else!", loot.eventForage)
    mq.event("Forage", "You have scrounged up #*#", loot.eventForage)
    mq.event("Novalue", "#*#give you absolutely nothing for the #1#.#*#", loot.eventNovalue)
    mq.event("Tribute", "#*#We graciously accept your #1# as tribute, thank you!#*#", loot.eventTribute)
end

-- BINDS

function loot.setBuyItem(itemID, qty)
    loot.BuyItemsTable[itemID] = qty
end

-- Changes the class restriction for an item
function loot.ChangeClasses(itemID, classes, tableName)
    if tableName == 'GlobalItems' then
        loot.GlobalItemsClasses[itemID] = classes
        loot.modifyItemRule(itemID, loot.GlobalItemsRules[itemID], 'Global_Rules', classes)
    elseif tableName == 'NormalItems' then
        loot.NormalItemsClasses[itemID] = classes
        loot.modifyItemRule(itemID, loot.NormalItemsRules[itemID], 'Normal_Rules', classes)
    elseif tableName == 'PersonalItems' then
        loot.PersonalItemsClasses[itemID] = classes
        loot.modifyItemRule(itemID, loot.PersonalItemsRules[itemID], loot.PersonalTableName, classes)
    end
end

-- Sets a Global Item rule
function loot.setGlobalItem(itemID, val, classes, link)
    if itemID == nil then
        Logger.Warn(loot.guiLoot.console, "Invalid itemID for setGlobalItem.")
        return
    end
    loot.modifyItemRule(itemID, val, 'Global_Rules', classes, link)

    loot.GlobalItemsRules[itemID] = val ~= 'delete' and val or nil
    if val ~= 'delete' then
        loot.GlobalItemsClasses[itemID] = classes or 'All'
        loot.GlobalItemsLink[itemID]    = link or 'NULL'
    else
        loot.GlobalItemsClasses[itemID] = nil
        loot.GlobalItemsLink[itemID]    = nil
    end
end

-- Sets a Normal Item rule
function loot.setNormalItem(itemID, val, classes, link)
    if itemID == nil then
        Logger.Warn(loot.guiLoot.console, "Invalid itemID for setNormalItem.")
        return
    end
    loot.NormalItemsRules[itemID] = val ~= 'delete' and val or nil
    if val ~= 'delete' then
        loot.NormalItemsClasses[itemID] = classes or 'All'
        loot.NormalItemsLink[itemID]    = link or 'NULL'
    else
        loot.NormalItemsClasses[itemID] = nil
        loot.NormalItemsLink[itemID]    = nil
    end
    loot.modifyItemRule(itemID, val, 'Normal_Rules', classes, link)
end

function loot.setPersonalItem(itemID, val, classes, link)
    if itemID == nil then
        Logger.Warn(loot.guiLoot.console, "Invalid itemID for setPersonalItem.")
        return
    end
    loot.PersonalItemsRules[itemID] = val ~= 'delete' and val or nil
    if val ~= 'delete' then
        loot.PersonalItemsClasses[itemID] = classes or 'All'
        loot.PersonalItemsLink[itemID]    = link or 'NULL'
    else
        loot.PersonalItemsClasses[itemID] = nil
        loot.PersonalItemsLink[itemID]    = nil
    end
    loot.modifyItemRule(itemID, val, loot.PersonalTableName, classes, link)
end

-- Sets a Global Item rule for the item currently on the cursor
function loot.setGlobalBind(value)
    local itemID = mq.TLO.Cursor.ID()
    loot.setGlobalItem(itemID, value)
end

-- Main command handler
function loot.commandHandler(...)
    local args = { ..., }
    local item = mq.TLO.Cursor -- Capture the cursor item early for reuse

    if args[1] == 'set' then
        local setting    = args[2]:lower()
        local settingVal = args[3]
        if settingsEnum[setting] ~= nil then
            local settingName = settingsEnum[setting]
            if type(loot.Settings[settingName]) == 'table' then
                Logger.Error(loot.guiLoot.console, "Setting \ay%s\ax is a table and cannot be set directly.", settingName)
                return
            end
            if type(loot.Settings[settingName]) == 'boolean' then
                loot.Settings[settingName] = settingVal == 'on'
            elseif type(loot.Settings[settingName]) == 'number' then
                loot.Settings[settingName] = tonumber(settingVal)
            else
                loot.Settings[settingName] = settingVal
            end
            Logger.Info(loot.guiLoot.console, "Setting \ay%s\ax to \ag%s\ax", settingName, settingVal)
            loot.writeSettings()
        else
            Logger.Warn(loot.guiLoot.console, "Invalid setting name: %s", setting)
        end
        loot.writeSettings()
        loot.sendMySettings()
        return
    end
    Logger.Debug(loot.guiLoot.console, "arg1: %s, arg2: %s, arg3: %s, arg4: %s", tostring(args[1]), tostring(args[2]), tostring(args[3]), tostring(args[4]))

    if args[1] == 'find' and args[2] ~= nil then
        if tonumber(args[2]) then
            loot.findItemInDb(nil, tonumber(args[2]))
        else
            loot.findItemInDb(args[2])
        end
    end
    if #args == 1 then
        local command = args[1]
        if command == 'sellstuff' then
            loot.processItems('Sell')
        elseif command == 'restock' then
            loot.processItems('Buy')
        elseif command == 'debug' then
            debugPrint = not debugPrint
            Logger.Info(loot.guiLoot.console, "\ayDebugging\ax is now %s", debugPrint and "\agon" or "\aroff")
        elseif command == 'reload' then
            local needSave = loot.loadSettings()
            if needSave then
                loot.writeSettings()
            end
            if loot.guiLoot then
                loot.guiLoot.GetSettings(
                    loot.Settings.HideNames,
                    loot.Settings.LookupLinks,
                    loot.Settings.RecordData,
                    true,
                    loot.Settings.UseActors,
                    'lootnscoot', false
                )
            end
            Logger.Info(loot.guiLoot.console, "\ayReloaded Settings \axand \atLoot Files")
        elseif command == 'update' then
            if loot.guiLoot then
                loot.guiLoot.GetSettings(
                    loot.Settings.HideNames,
                    loot.Settings.LookupLinks,
                    loot.Settings.RecordData,
                    true,
                    loot.Settings.UseActors,
                    'lootnscoot', false
                )
            end
            loot.UpdateDB()
            Logger.Info(loot.guiLoot.console, "\ayUpdated the DB from loot.ini \axand \atreloaded settings")
        elseif command == 'importinv' then
            loot.addMyInventoryToDB()
        elseif command == 'bank' then
            loot.processItems('Bank')
        elseif command == 'cleanup' then
            loot.processItems('Destroy')
        elseif command == 'gui' or command == 'console' and loot.guiLoot then
            loot.guiLoot.openGUI = not loot.guiLoot.openGUI
        elseif command == 'report' and loot.guiLoot then
            loot.guiLoot.ReportLoot()
        elseif command == 'hidenames' and loot.guiLoot then
            loot.guiLoot.hideNames = not loot.guiLoot.hideNames
        elseif command == 'config' then
            local confReport = "\ayLoot N Scoot Settings\ax"
            for key, value in pairs(loot.Settings) do
                if type(value) ~= "function" and type(value) ~= "table" then
                    confReport = confReport .. string.format("\n\at%s\ax                                    = \ag%s\ax", key, tostring(value))
                end
            end
            Logger.Info(loot.guiLoot.console, confReport)
        elseif command == 'tributestuff' then
            loot.processItems('Tribute')
        elseif command == 'shownew' or command == 'newitems' then
            showNewItem = not showNewItem
        elseif command == 'loot' then
            loot.lootMobs()
        elseif command == 'show' then
            loot.ShowUI = not loot.ShowUI
        elseif command == 'tsbank' then
            loot.markTradeSkillAsBank()
        elseif validActions[command] and item() then
            local itemID = item.ID()
            loot.addRule(itemID, 'NormalItems', validActions[command], 'All', item.ItemLink('CLICKABLE')())
            Logger.Info(loot.guiLoot.console, "Setting \ay%s\ax to \ay%s\ax", item.Name(), validActions[command])
        elseif string.find(command, "quest%|") and item() then
            local itemID = item.ID()
            local val    = string.gsub(command, "quest", "Quest")
            loot.addRule(itemID, 'NormalItems', val, 'All', item.ItemLink('CLICKABLE')())
            Logger.Info(loot.guiLoot.console, "Setting \ay%s\ax to \ay%s\ax", item.Name(), val)
        elseif command == 'quit' or command == 'exit' then
            loot.Terminate = true
        end
    elseif #args == 2 then
        local action, itemName = args[1], args[2]
        if validActions[action] then
            local lootID = loot.resolveItemIDbyName(itemName, false)
            Logger.Warn(loot.guiLoot.console, "lootID: %s", lootID)
            if lootID then
                if loot.ALLITEMS[lootID] then
                    loot.addRule(lootID, 'NormalItems', validActions[action], 'All', loot.ALLITEMS[lootID].Link)
                    Logger.Info(loot.guiLoot.console, "Setting \ay%s (%s)\ax to \ay%s\ax", itemName, lootID, validActions[action])
                end
            end
        end
    elseif #args == 3 then
        if args[1] == 'globalitem' and args[2] == 'quest' and item() then
            local itemID = item.ID()
            loot.addRule(itemID, 'GlobalItems', 'Quest|' .. args[3], 'All', item.ItemLink('CLICKABLE')())
            Logger.Info(loot.guiLoot.console, "Setting \ay%s\ax to \agGlobal Item \ayQuest|%s\ax", item.Name(), args[3], item.ItemLink('CLICKABLE')())
        elseif args[1] == 'globalitem' and validActions[args[2]] and item() then
            loot.addRule(item.ID(), 'GlobalItems', validActions[args[2]], args[3] or 'All', item.ItemLink('CLICKABLE')())
            Logger.Info(loot.guiLoot.console, "Setting \ay%s\ax to \agGlobal Item \ay%s \ax(\at%s\ax)", item.Name(), item.ID(), validActions[args[2]])
        elseif args[1] == 'globalitem' and validActions[args[2]] and args[3] ~= nil then
            local itemName = args[3]
            local itemID   = loot.resolveItemIDbyName(itemName, false)
            if itemID then
                if loot.ALLITEMS[itemID] then
                    loot.addRule(itemID, 'GlobalItems', validActions[args[2]], 'All', loot.ALLITEMS[itemID].Link)
                    Logger.Info(loot.guiLoot.console, "Setting \ay%s\ax to \agGlobal Item \ay%s|%s\ax", loot.ALLITEMS[itemID].Name, validActions[args[2]], args[3])
                end
            else
                Logger.Warn(loot.guiLoot.console, "Item \ay%s\ax ID: %s\ax not found in loot.ALLITEMS.", itemName, itemID)
            end
        end
    end
    loot.writeSettings()
end

function loot.findItemInDb(itemName, itemId)
    local db = loot.OpenItemsSQL()
    local query = "SELECT * FROM Items"
    if itemId ~= nil then
        query = string.format("SELECT * FROM Items WHERE item_id = %d", itemId)
    elseif itemName ~= nil then
        query = string.format("SELECT * FROM Items WHERE name LIKE '%%%s%%'", itemName)
    end
    db:exec("BEGIN TRANSACTION")
    local stmt = db:prepare(query)
    local counter = 0
    for row in stmt:nrows() do
        if counter > 20 then break end
        Logger.Info(loot.guiLoot.console, "\ao[\ax\ayLNS Find Item\ao]\ax:\ax\ay %s\ax \ayID:\ax \at%d\ax, \aoValue:\ax \ag%s\ax Link: %s,", row.name, row.item_id, row.sell_value,
            row.link)
        counter = counter + 1
    end
    stmt:finalize()
    db:exec("COMMIT")
    db:close()
    if counter > 20 then Logger.Info(loot.guiLoot.console, "\aoMore than\ax \ay20\ax items found, \aoonly showing first\ax \at20\ax.") end
end

function loot.setupBinds()
    mq.bind('/lootutils', loot.commandHandler)
    mq.bind('/lns', loot.commandHandler)
end

-- LOOTING

function loot.CheckBags()
    if loot.Settings.SaveBagSlots == nil then return false end
    -- Logger.Warn(loot.guiLoot.console,"\agBag CHECK\ax free: \at%s\ax, save: \ag%s\ax", mq.TLO.Me.FreeInventory(), loot.Settings.SaveBagSlots)
    areFull = mq.TLO.Me.FreeInventory() <= loot.Settings.SaveBagSlots
end

function loot.eventCantLoot()
    cantLootID = mq.TLO.Target.ID()
end

function loot.eventNoSlot()
    -- we don't have a slot big enough for the item on cursor. Dropping it to the ground.
    local cantLootItemName = mq.TLO.Cursor()
    mq.cmdf('/drop')
    mq.delay(1)
    loot.report("\ay[WARN]\arI can't loot %s, dropping it on the ground!\ax", cantLootItemName)
end

---@param index number @The current index in the loot window, 1-based.
---@param doWhat string @The action to take for the item.
---@param button string @The mouse button to use to loot the item. Only "leftmouseup" is currently implemented.
---@param qKeep number @The count to keep for quest items.
---@param cantWear boolean|nil @ Whether the character canwear the item
function loot.lootItem(index, doWhat, button, qKeep, cantWear)
    Logger.Debug(loot.guiLoot.console, 'Enter lootItem')
    local corpseName = mq.TLO.Corpse.CleanName() or 'none'
    local corpseItem = mq.TLO.Corpse.Item(index)
    if not corpseItem then return end
    local curZone        = mq.TLO.Zone.ShortName() or 'none'
    local corpseItemID   = corpseItem.ID() or 0
    local itemName       = corpseItem.Name() or 'none'
    local itemLink       = corpseItem.ItemLink('CLICKABLE')()
    local isGlobalItem   = loot.Settings.GlobalLootOn and (loot.GlobalItemsRules[corpseItemID] ~= nil or loot.BuyItemsTable[corpseItemID] ~= nil)
    local isPersonalItem = loot.PersonalItemsRules[corpseItemID] ~= nil
    local tmpLabel       = corpseName:sub(1, corpseName:find("corpse") - 4)
    corpseName           = tmpLabel
    local eval           = doWhat

    Logger.Debug(loot.guiLoot.console, "\aoINSERT HISTORY CHECK 1\ax:  \ayAction\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", eval, itemName, itemLink)

    if corpseItem and not shouldLootActions[doWhat] then
        if (doWhat == 'Ignore' and not (loot.Settings.DoDestroy and loot.Settings.AlwaysDestroy)) or
            (doWhat == 'Destroy' and not loot.Settings.DoDestroy) then
            doWhat = doWhat == 'Ignore' and 'Left' or doWhat
            Logger.Debug(loot.guiLoot.console, "\aoINSERT HISTORY CHECK 2\ax:  \ayAction\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", eval, itemName, itemLink)

            loot.insertIntoHistory(itemName, corpseName, doWhat,
                os.date('%Y-%m-%d'), os.date('%H:%M:%S'), itemLink, MyName, curZone, allItems, cantWear)
            return
        end
    end


    mq.cmdf('/nomodkey /shift /itemnotify loot%s %s', index, button)
    mq.delay(1) -- Small delay to ensure command execution.

    mq.delay(5000, function()
        return mq.TLO.Window('ConfirmationDialogBox').Open() or mq.TLO.Cursor() ~= nil
    end)

    -- Handle confirmation dialog for no-drop items
    if mq.TLO.Window('ConfirmationDialogBox').Open() then
        mq.cmdf('/nomodkey /notify ConfirmationDialogBox Yes_Button leftmouseup')
    end

    mq.delay(5000, function()
        return mq.TLO.Cursor() ~= nil or not mq.TLO.Window('LootWnd').Open()
    end)

    -- Ensure next frame processes
    mq.delay(1)

    -- If loot window closes unexpectedly, exit the function
    if not mq.TLO.Window('LootWnd').Open() then
        -- table.insert(allItems,
        --     { Name = itemName, Action = 'Looted', Link = itemLink, Eval = doWhat, cantWear = cantWear, CorpseName = corpseName, })

        -- loot.insertIntoHistory(itemName, corpseName, doWhat,
        --     os.date('%Y-%m-%d'), os.date('%H:%M:%S'), itemLink, MyName, curZone, allItems, cantWear)
        return
    end
    eval = doWhat
    if doWhat == 'Destroy' then
        mq.delay(10000, function() return mq.TLO.Cursor.ID() == corpseItemID end)
        eval = isGlobalItem and 'Global Destroy' or 'Destroy'
        eval = isPersonalItem and 'Personal Destroy' or eval
        mq.cmdf('/destroy')
        -- table.insert(allItems,
        --     { Name = itemName, Action = 'Destroyed', CorpseName = corpseName, Link = itemLink, Eval = eval, cantWear = cantWear, })
        Logger.Debug(loot.guiLoot.console, "\aoINSERT HISTORY CHECK 3\ax: \ayAction\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", eval, itemName, itemLink)
    end

    loot.checkCursor()

    -- Handle quest item logic
    if qKeep > 0 and doWhat == 'Keep' then
        eval            = isGlobalItem and 'Global Quest' or 'Quest'
        eval            = isPersonalItem and 'Personal Quest' or eval
        local countHave = mq.TLO.FindItemCount(itemName)() + mq.TLO.FindItemBankCount(itemName)()
        loot.report("\awQuest Item:\ag %s \awCount:\ao %s \awof\ag %s", itemLink, tostring(countHave), qKeep)
    else
        eval = isGlobalItem and 'Global ' .. doWhat or doWhat
        eval = isPersonalItem and 'Personal ' .. doWhat or eval
        loot.report('%sing \ay%s\ax', eval, itemLink)
    end

    -- Log looted items
    Logger.Debug(loot.guiLoot.console, "\aoINSERT HISTORY CHECK 4\ax: \ayAction\ax: \at%s\ax, Item: \ao%s\ax, \atLink: %s", eval, itemName, itemLink)


    loot.insertIntoHistory(itemName, corpseName, eval,
        os.date('%Y-%m-%d'), os.date('%H:%M:%S'), itemLink, MyName, curZone, allItems, cantWear)


    loot.CheckBags()

    -- Check for full inventory
    if areFull == true then
        loot.report('My bags are full, I can\'t loot anymore! Turning OFF Looting Items until we sell.')
    end
end

function loot.reportSkippedItems(noDropItems, loreItems, corpseName, corpseID)
    -- Ensure parameters are valid
    noDropItems = noDropItems or {}
    loreItems   = loreItems or {}

    -- Log skipped items
    if next(noDropItems) then
        Logger.Info(loot.guiLoot.console, "Skipped NoDrop items from corpse %s (ID: %s): %s",
            corpseName, tostring(corpseID), table.concat(noDropItems, ", "))
    end

    if next(loreItems) then
        Logger.Info(loot.guiLoot.console, "Skipped Lore items from corpse %s (ID: %s): %s",
            corpseName, tostring(corpseID), table.concat(loreItems, ", "))
    end
end

function loot.lootCorpse(corpseID)
    Logger.Debug(loot.guiLoot.console, 'Enter lootCorpse')
    shouldLootActions.Destroy = loot.Settings.DoDestroy
    shouldLootActions.Tribute = loot.Settings.TributeKeep

    allItems = {}
    if mq.TLO.Cursor() then loot.checkCursor() end

    for i = 1, 3 do
        mq.cmdf('/loot')
        mq.delay(1000, function() return mq.TLO.Window('LootWnd').Open() end)
        if mq.TLO.Window('LootWnd').Open() then break end
    end

    mq.doevents('CantLoot')
    mq.delay(3000, function() return cantLootID > 0 or mq.TLO.Window('LootWnd').Open() end)

    if not mq.TLO.Window('LootWnd').Open() then
        if mq.TLO.Target.CleanName() then
            Logger.Warn(loot.guiLoot.console, "lootCorpse(): Can't loot %s right now", mq.TLO.Target.CleanName())
            cantLootList[corpseID] = os.time()
        end
        return
    end

    mq.delay(1000, function() return mq.TLO.Corpse.Items() end)
    local items = mq.TLO.Corpse.Items() or 0
    Logger.Debug(loot.guiLoot.console, "lootCorpse(): Loot window open. Items: %s", items)

    if mq.TLO.Window('LootWnd').Open() and items > 0 then
        if mq.TLO.Corpse.DisplayName() == mq.TLO.Me.DisplayName() then
            if loot.Settings.LootMyCorpse then
                mq.cmdf('/lootall')
                mq.delay("45s", function() return not mq.TLO.Window('LootWnd').Open() end)
            end
            return
        end

        noDropItems, loreItems = {}, {}

        for i = 1, items do
            local freeSpace           = mq.TLO.Me.FreeInventory()
            local corpseItem          = mq.TLO.Corpse.Item(i)
            local lootActionPreformed = "Looted"
            if corpseItem() then
                local corpseItemID = corpseItem.ID()
                local itemLink     = corpseItem.ItemLink('CLICKABLE')()
                local isNoDrop     = corpseItem.NoDrop()
                local newNoDrop    = false
                if loot.ItemNames[corpseItemID] == nil then
                    loot.addToItemDB(corpseItem)
                    if isNoDrop then
                        loot.addRule(corpseItemID, 'NormalItems', 'CanUse', 'All', itemLink)
                        newNoDrop = true
                    end
                end
                local itemRule, qKeep, newRule, cantWear = loot.getRule(corpseItem, 'loot', i)

                Logger.Info(loot.guiLoot.console, "LootCorpse(): itemID=\ao%s\ax, rule=\at%s\ax, qKeep=\ay%s\ax, newRule=\ag%s", corpseItemID, itemRule, qKeep, newRule)
                newRule = newNoDrop == true and true or newRule
            end

            mq.delay(1)
            if mq.TLO.Cursor() then loot.checkCursor() end
            mq.delay(1)
            if not mq.TLO.Window('LootWnd').Open() then break end
        end

        loot.reportSkippedItems(noDropItems, loreItems, corpseName, corpseID)
    end

    if mq.TLO.Cursor() then loot.checkCursor() end
    mq.cmdf('/nomodkey /notify LootWnd LW_DoneButton leftmouseup')
    mq.delay(5000, function() return not mq.TLO.Window('LootWnd').Open() end)

    if mq.TLO.Spawn(('corpse id %s'):format(corpseID))() then
        cantLootList[corpseID] = os.time()
    end

    if #allItems > 0 then
        local message = {
            ID = corpseID,
            Items = allItems,
            Zone = mq.TLO.Zone.ShortName(),
            Server = eqServer,
            LootedAt = mq.TLO.Time(),
            CorpseName = corpseName,
            LootedBy = MyName,
        }
        loot.lootActor:send({ mailbox = 'looted', script = 'lootnscoot', }, message)
        loot.lootActor:send({ mailbox = 'looted', script = 'rgmercs/lib/lootnscoot', }, message)
    end
end

function loot.finishedLooting()
    if Mode == 'directed' then
        loot.lootActor:send({ mailbox = 'loot_module', script = loot.DirectorScript, },
            { Subject = 'done_looting', Who = MyName, })
    end
end

function loot.corpseLocked(corpseID)
    if not cantLootList[corpseID] then return false end
    if os.difftime(os.time(), cantLootList[corpseID]) > 1 then
        cantLootList[corpseID] = nil
        return false
    end
    return true
end

function loot.lootMobs(limit)
    if zoneID ~= mq.TLO.Zone.ID() then
        zoneID        = mq.TLO.Zone.ID()
        lootedCorpses = {}
    end

    -- Logger.Debug(loot.guiLoot.console, 'lootMobs(): Entering lootMobs function.')
    local deadCount     = mq.TLO.SpawnCount(string.format('npccorpse radius %s zradius 50', loot.Settings.CorpseRadius or 100))()
    local mobsNearby    = mq.TLO.SpawnCount(string.format('xtarhater radius %s zradius 50', loot.Settings.MobsTooClose or 40))()
    local corpseList    = {}

    -- Logger.Debug(loot.guiLoot.console, 'lootMobs(): Found %s corpses in range.', deadCount)

    -- Handle looting of the player's own corpse
    local myCorpseCount = mq.TLO.SpawnCount(string.format("pccorpse %s radius %d zradius 100", mq.TLO.Me.CleanName(), loot.Settings.CorpseRadius))()

    if loot.Settings.LootMyCorpse and myCorpseCount > 0 then
        for i = 1, (limit or myCorpseCount) do
            local corpse = mq.TLO.NearestSpawn(string.format("%d, pccorpse %s radius %d zradius 100", i, mq.TLO.Me.CleanName(), loot.Settings.CorpseRadius))
            if corpse() then
                -- Logger.Debug(loot.guiLoot.console, 'lootMobs(): Adding my corpse to loot list. Corpse ID: %d', corpse.ID())
                table.insert(corpseList, corpse)
            end
        end
    end

    -- Stop looting if conditions aren't met
    if (deadCount + myCorpseCount) == 0 or ((mobsNearby > 0 or mq.TLO.Me.Combat()) and not loot.Settings.CombatLooting) then
        loot.finishedLooting()
        return false
    end

    -- Add other corpses to the loot list if not limited by the player's own corpse
    if myCorpseCount == 0 then
        for i = 1, (limit or deadCount) do
            local corpse = mq.TLO.NearestSpawn(('%d,' .. spawnSearch):format(i, 'npccorpse', loot.Settings.CorpseRadius))
            if corpse() and (not lootedCorpses[corpse.ID()] or not loot.Settings.CheckCorpseOnce) then
                table.insert(corpseList, corpse)
            end
        end
    else
        Logger.Debug(loot.guiLoot.console, 'lootMobs(): Skipping other corpses due to nearby player corpse.')
    end

    -- Process the collected corpse list
    local didLoot = false
    if #corpseList > 0 then
        Logger.Debug(loot.guiLoot.console, 'lootMobs(): Attempting to loot %d corpses.', #corpseList)
        for _, corpse in ipairs(corpseList) do
            local corpseID = corpse.ID()

            if not corpseID or corpseID <= 0 or loot.corpseLocked(corpseID) or
                (mq.TLO.Navigation.PathLength('spawn id ' .. corpseID)() or 100) > loot.Settings.CorpseRadius then
                Logger.Debug(loot.guiLoot.console, 'lootMobs(): Skipping corpse ID: %d.', corpseID)
                goto continue
            end

            -- Attempt to move and loot the corpse
            if corpse.DisplayName() == mq.TLO.Me.DisplayName() then
                Logger.Debug(loot.guiLoot.console, 'lootMobs(): Pulling own corpse closer. Corpse ID: %d', corpseID)
                mq.cmdf("/corpse")
                mq.delay(10)
            end

            Logger.Debug(loot.guiLoot.console, 'lootMobs(): Navigating to corpse ID=%d.', corpseID)
            loot.navToID(corpseID)

            if mobsNearby > 0 and not loot.Settings.CombatLooting then
                Logger.Debug(loot.guiLoot.console, 'lootMobs(): Stopping looting due to aggro.')
                return didLoot
            end

            corpse.DoTarget()
            loot.lootCorpse(corpseID)
            didLoot                 = true
            lootedCorpses[corpseID] = true

            ::continue::
        end
        -- Logger.Debug(loot.guiLoot.console, 'lootMobs(): Finished processing corpse list.')
    end

    loot.finishedLooting()

    return didLoot
end

-- SELLING
function loot.eventSell(_, itemName)
    if ProcessItemsState ~= nil then return end
    -- Resolve the item ID from the given name
    local itemID = loot.resolveItemIDbyName(itemName, false)

    if not itemID then
        Logger.Warn(loot.guiLoot.console, "Unable to resolve item ID for: " .. itemName)
        return
    end

    -- Add a rule to mark the item as "Sell"
    loot.addRule(itemID, "NormalItems", "Sell", "All", loot.ALLITEMS[itemID].Link)
    Logger.Info(loot.guiLoot.console, "Added rule: \ay%s\ax set to \agSell\ax.", itemName)
end

function loot.goToVendor()
    if not mq.TLO.Target() then
        Logger.Warn(loot.guiLoot.console, 'Please target a vendor')
        return false
    end
    local vendorID = mq.TLO.Target.ID()
    if mq.TLO.Target.Distance() > 15 then
        loot.navToID(vendorID)
    end
    return true
end

function loot.openVendor()
    Logger.Debug(loot.guiLoot.console, 'Opening merchant window')
    mq.cmdf('/nomodkey /click right target')
    mq.delay(5000, function() return mq.TLO.Window('MerchantWnd').Open() end)
    return mq.TLO.Window('MerchantWnd').Open()
end

function loot.SellToVendor(itemID, bag, slot, name)
    local itemName = loot.ALLITEMS[itemID] ~= nil and loot.ALLITEMS[itemID].Name or 'Unknown'
    if itemName == 'Unknown' and name ~= nil then itemName = name end
    if NEVER_SELL[itemName] then return end
    if mq.TLO.Window('MerchantWnd').Open() then
        Logger.Info(loot.guiLoot.console, 'Selling item: %s', itemName)
        local notify = slot == (nil or -1)
            and ('/itemnotify %s leftmouseup'):format(bag)
            or ('/itemnotify in pack%s %s leftmouseup'):format(bag, slot)
        mq.cmdf(notify)
        mq.delay(5000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == itemName end)
        mq.cmdf('/nomodkey /shiftkey /notify merchantwnd MW_Sell_Button leftmouseup')
        mq.delay(5000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == '' end)
    end
end

-- BANKING
function loot.openBanker()
    Logger.Debug(loot.guiLoot.console, 'Opening bank window')
    mq.cmdf('/nomodkey /click right target')
    mq.delay(1000, function() return mq.TLO.Window('BigBankWnd').Open() end)
    return mq.TLO.Window('BigBankWnd').Open()
end

function loot.bankItem(itemID, bag, slot)
    local notify = slot == nil or slot == -1
        and ('/shift /itemnotify %s leftmouseup'):format(bag)
        or ('/shift /itemnotify in pack%s %s leftmouseup'):format(bag, slot)
    mq.cmdf(notify)
    mq.delay(10000, function() return mq.TLO.Cursor() end)
    mq.cmdf('/notify BigBankWnd BIGB_AutoButton leftmouseup')
    mq.delay(10000, function() return not mq.TLO.Cursor() end)
end

function loot.markTradeSkillAsBank()
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        if bagSlot.ID() and bagSlot.Tradeskills() then
            loot.NormalItemsRules[bagSlot.ID()] = 'Bank'
            loot.addRule(bagSlot.ID(), 'NormalItems', 'Bank', 'All', bagSlot.ItemLink('CLICKABLE')())
        end
    end
end

-- BUYING

function loot.RestockItems()
    local rowNum = 0
    for itemName, qty in pairs(loot.BuyItemsTable) do
        Logger.Info(loot.guiLoot.console, 'Checking \ao%s \axfor \at%s \axto \agRestock', mq.TLO.Target.CleanName(), itemName)
        local tmpVal = tonumber(qty) or 0
        rowNum       = mq.TLO.Window("MerchantWnd/MW_ItemList").List(string.format("=%s", itemName), 2)() or 0
        mq.delay(20)
        local onHand = mq.TLO.FindItemCount(itemName)()
        local tmpQty = tmpVal - onHand
        if rowNum ~= 0 and tmpQty > 0 then
            Logger.Info(loot.guiLoot.console, "\ayRestocking \ax%s \aoHave\ax: \at%s\ax \agBuying\ax: \ay%s", itemName, onHand, tmpVal)
            mq.TLO.Window("MerchantWnd/MW_ItemList").Select(rowNum)()
            mq.delay(100)
            mq.TLO.Window("MerchantWnd/MW_Buy_Button").LeftMouseUp()
            mq.delay(500, function() return mq.TLO.Window("QuantityWnd").Open() end)
            mq.TLO.Window("QuantityWnd/QTYW_SliderInput").SetText(tostring(tmpQty))()
            mq.delay(100, function() return mq.TLO.Window("QuantityWnd/QTYW_SliderInput").Text() == tostring(tmpQty) end)
            Logger.Info(loot.guiLoot.console, "\agBuying\ay " .. mq.TLO.Window("QuantityWnd/QTYW_SliderInput").Text() .. "\at " .. itemName)
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
    Logger.Debug(loot.guiLoot.console, 'Opening Tribute Window')
    mq.cmdf('/nomodkey /click right target')
    Logger.Debug(loot.guiLoot.console, 'Waiting for Tribute Window to populate')
    mq.delay(1000, function() return mq.TLO.Window('TributeMasterWnd').Open() end)
    if not mq.TLO.Window('TributeMasterWnd').Open() then return false end
    return mq.TLO.Window('TributeMasterWnd').Open()
end

function loot.eventTribute(_, itemName)
    if ProcessItemsState ~= nil then return end

    -- Resolve the item ID from the given name
    local itemID = loot.resolveItemIDbyName(itemName)

    if not itemID then
        Logger.Warn(loot.guiLoot.console, "Unable to resolve item ID for: " .. itemName)
        return
    end

    -- Add a rule to mark the item as "Tribute"
    loot.addRule(itemID, "NormalItems", "Tribute", "All", loot.ALLITEMS[itemID].Link)
    Logger.Info(loot.guiLoot.console, "Added rule: \ay%s\ax set to \agTribute\ax.", itemName)
end

function loot.TributeToVendor(itemToTrib, bag, slot)
    if NEVER_SELL[itemToTrib.Name()] then return end
    if mq.TLO.Window('TributeMasterWnd').Open() then
        Logger.Info(loot.guiLoot.console, 'Tributeing ' .. itemToTrib.Name())
        loot.report('\ayTributing \at%s \axfor\ag %s \axpoints!', itemToTrib.Name(), itemToTrib.Tribute())
        mq.cmdf('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
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
    if itemToDestroy == nil then return end
    if NEVER_SELL[itemToDestroy.Name()] then return end
    Logger.Info(loot.guiLoot.console, '!!Destroying!! ' .. itemToDestroy.Name())
    -- Logger.Info(loot.guiLoot.console, "Bag: %s, Slot: %s", bag, slot)
    mq.cmdf('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
    mq.delay(10000, function() return mq.TLO.Cursor.Name() == itemToDestroy.Name() end) -- progress frame
    mq.cmdf('/destroy')
    mq.delay(1)
    mq.delay(1000, function() return not mq.TLO.Cursor() end)
    mq.delay(1)
end

-- FORAGING

function loot.eventForage()
    if not loot.Settings.LootForage then return end
    Logger.Debug(loot.guiLoot.console, 'Enter eventForage')
    -- allow time for item to be on cursor incase message is faster or something?
    mq.delay(1000, function() return mq.TLO.Cursor() end)
    -- there may be more than one item on cursor so go until its cleared
    while mq.TLO.Cursor() do
        local cursorItem        = mq.TLO.Cursor
        local foragedItem       = cursorItem.Name()
        local forageRule        = loot.split(loot.getRule(cursorItem, 'forage', {}, 0))
        local ruleAction        = forageRule[1] -- what to do with the item
        local ruleAmount        = forageRule[2] -- how many of the item should be kept
        local currentItemAmount = mq.TLO.FindItemCount('=' .. foragedItem)()
        -- >= because .. does finditemcount not count the item on the cursor?
        if not shouldLootActions[ruleAction] or (ruleAction == 'Quest' and currentItemAmount >= ruleAmount) then
            if mq.TLO.Cursor.Name() == foragedItem then
                if loot.Settings.LootForageSpam then Logger.Info(loot.guiLoot.console, 'Destroying foraged item ' .. foragedItem) end
                mq.cmdf('/destroy')
                mq.delay(500)
            end
            -- will a lore item we already have even show up on cursor?
            -- free inventory check won't cover an item too big for any container so may need some extra check related to that?
        elseif (shouldLootActions[ruleAction] or currentItemAmount < ruleAmount) and (not cursorItem.Lore() or currentItemAmount == 0) and (mq.TLO.Me.FreeInventory() or (cursorItem.Stackable() and cursorItem.FreeStack())) then
            if loot.Settings.LootForageSpam then Logger.Info(loot.guiLoot.console, 'Keeping foraged item ' .. foragedItem) end
            mq.cmdf('/autoinv')
        else
            if loot.Settings.LootForageSpam then Logger.Warn(loot.guiLoot.console, 'Unable to process item ' .. foragedItem) end
            break
        end
        mq.delay(50)
    end
end

-- Process Items

function loot.processItems(action)
    local flag        = false
    local totalPlat   = 0
    ProcessItemsState = action
    loot.informProcessing()
    -- Helper function to process individual items based on action
    local function processItem(item, action, bag, slot)
        if not item or not item.ID() then return end
        local itemID = item.ID()
        local rule   = loot.GlobalItemsRules[itemID] and loot.GlobalItemsRules[itemID] or loot.NormalItemsRules[itemID]
        rule         = loot.PersonalItemsRules[itemID] and loot.PersonalItemsRules[itemID] or rule
        if rule == action then
            if action == 'Sell' then
                if not mq.TLO.Window('MerchantWnd').Open() then
                    if not loot.goToVendor() or not loot.openVendor() then return end
                end
                local sellPrice = item.Value() and item.Value() / 1000 or 0
                if sellPrice == 0 then
                    Logger.Warn(loot.guiLoot.console, 'Item \ay%s\ax is set to Sell but has no sell value!', item.Name())
                elseif not (loot.Settings.KeepSpells and loot.checkSpells(item.Name())) then
                    loot.SellToVendor(itemID, bag, slot, item.Name())
                    -- loot.SellToVendor(item.Name(), bag, slot, item.ItemLink('CLICKABLE')() or "NULL")
                    totalPlat = totalPlat + sellPrice
                    mq.delay(1)
                end
            elseif action == 'Tribute' then
                if not mq.TLO.Window('TributeMasterWnd').Open() then
                    if not loot.goToVendor() or not loot.openTribMaster() then return end
                end
                mq.cmdf('/keypress OPEN_INV_BAGS')
                mq.delay(1000, loot.AreBagsOpen)
                loot.TributeToVendor(item, bag, slot)
            elseif action == ('Destroy' or 'Cleanup') then
                -- loot.TempSettings.NeedsDestroy = { item = item, container = bag, slot = slot, }
                loot.DestroyItem(item, bag, slot)
            elseif action == 'Bank' then
                if not mq.TLO.Window('BigBankWnd').Open() then
                    if not loot.goToVendor() or not loot.openBanker() then return end
                end
                loot.bankItem(item.Name(), bag, slot)
            end
        end
    end

    -- Temporarily disable AlwaysEval during processing
    if loot.Settings.AlwaysEval then
        flag, loot.Settings.AlwaysEval = true, false
    end

    -- Iterate through bags and process items

    for i = 1, 10 do
        local bagSlot       = mq.TLO.InvSlot('pack' .. i).Item
        local containerSize = bagSlot.Container()

        if containerSize then
            for j = 1, containerSize do
                local item = bagSlot.Item(j)
                if item and item.ID() then
                    processItem(item, action, i, j)
                end
            end
        end
    end

    -- Handle restocking if AutoRestock is enabled
    if action == 'Sell' and loot.Settings.AutoRestock then
        loot.RestockItems()
    end

    -- Handle buying items
    if action == 'Buy' then
        if not mq.TLO.Window('MerchantWnd').Open() then
            if not loot.goToVendor() or not loot.openVendor() then return end
        end
        loot.RestockItems()
    end

    -- Restore AlwaysEval state if it was modified
    if flag then
        flag, loot.Settings.AlwaysEval = false, true
    end

    -- Handle specific post-action tasks
    if action == 'Tribute' then
        mq.flushevents('Tribute')
        if mq.TLO.Window('TributeMasterWnd').Open() then
            mq.TLO.Window('TributeMasterWnd').DoClose()
        end
        mq.cmdf('/keypress CLOSE_INV_BAGS')
    elseif action == 'Sell' then
        if mq.TLO.Window('MerchantWnd').Open() then
            mq.TLO.Window('MerchantWnd').DoClose()
        end
        totalPlat = math.floor(totalPlat)
        loot.report('Total plat value sold: \ag%s\ax', totalPlat)
    elseif action == 'Bank' then
        if mq.TLO.Window('BigBankWnd').Open() then
            mq.TLO.Window('BigBankWnd').DoClose()
        end
    end

    -- Final check for bag status
    loot.CheckBags()
    ProcessItemsState = nil
    loot.doneProcessing()
end

function loot.sellStuff()
    loot.processItems('Sell')
end

function loot.bankStuff()
    loot.processItems('Bank')
end

function loot.cleanupBags()
    loot.processItems('Destroy')
end

function loot.tributeStuff()
    loot.processItems('Tribute')
end

function loot.guiExport()
    -- Define a new menu element function
    local function customMenu()
        ImGui.PushID('LootNScootMenu_Imported')
        if ImGui.BeginMenu('Loot N Scoot##') then
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

            if ImGui.BeginMenu('Group Commands##') then
                -- Add menu items here
                if ImGui.MenuItem("Sell Stuff##group") then
                    mq.cmdf(string.format('/%s /lootutils sellstuff', tmpCmd))
                end

                if ImGui.MenuItem('Restock Items##group') then
                    mq.cmdf(string.format('/%s /lootutils restock', tmpCmd))
                end

                if ImGui.MenuItem("Tribute Stuff##group") then
                    mq.cmdf(string.format('/%s /lootutils tributestuff', tmpCmd))
                end

                if ImGui.MenuItem("Bank##group") then
                    mq.cmdf(string.format('/%s /lootutils bank', tmpCmd))
                end

                if ImGui.MenuItem("Cleanup##group") then
                    mq.cmdf(string.format('/%s /lootutils cleanup', tmpCmd))
                end

                ImGui.Separator()

                if ImGui.MenuItem("Reload##group") then
                    mq.cmdf(string.format('/%s /lootutils reload', tmpCmd))
                end

                ImGui.EndMenu()
            end

            if ImGui.MenuItem('Sell Stuff##') then
                mq.cmdf('/lootutils sellstuff')
            end

            if ImGui.MenuItem('Restock##') then
                mq.cmdf('/lootutils restock')
            end

            if ImGui.MenuItem('Tribute Stuff##') then
                mq.cmdf('/lootutils tributestuff')
            end

            if ImGui.MenuItem('Bank##') then
                mq.cmdf('/lootutils bank')
            end

            if ImGui.MenuItem('Cleanup##') then
                mq.cmdf('/lootutils cleanup')
            end

            ImGui.Separator()

            if ImGui.MenuItem('Reload##') then
                mq.cmdf('/lootutils reload')
            end

            ImGui.EndMenu()
        end
        ImGui.PopID()
    end
    -- Add the custom menu element function to the importGUIElements table
    if loot.guiLoot ~= nil then loot.guiLoot.importGUIElements[1] = customMenu end
end

function loot.handleSelectedItem(itemID)
    -- Process the selected item (e.g., add to a rule, perform an action, etc.)
    local itemData = loot.ALLITEMS[itemID]
    if not itemData then
        Logger.Error(loot.guiLoot.console, "Invalid item selected: " .. tostring(itemID))
        return
    end

    Logger.Info(loot.guiLoot.console, "Item selected: " .. itemData.Name .. " (ID: " .. itemID .. ")")
    -- You can now use itemID for further actions
end

function loot.drawYesNo(decision)
    if decision then
        loot.drawIcon(4494, 20) -- Checkmark icon
    else
        loot.drawIcon(4495, 20) -- X icon
    end
end

---comment
---@param search any Search string we are looking for, can be a string or number
---@param key any Table field we are checking against, for Lookups this is only Name. for other tables this can be ItemId, Name, Class, Race
---@param value any Field value we are checking against
---@return boolean True if the search string is found in the key or value, false otherwise
function loot.SearchLootTable(search, key, value)
    if key == nil or value == nil or search == nil then return false end
    key = tostring(key)
    search = tostring(search)
    search = search and search:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1") or ""
    if (search == nil or search == "") or key:lower():find(search:lower()) or value:lower():find(search:lower()) then
        return true
    else
        return false
    end
end

local fontScale = 1
local iconSize = 16
local tempValues = {}

function loot.SortTables()
    loot.TempSettings.SortedGlobalItemKeys = {}
    loot.TempSettings.SortedBuyItemKeys    = {}
    loot.TempSettings.SortedNormalItemKeys = {}
    loot.TempSettings.SortedSettingsKeys   = {}
    loot.TempSettings.SortedToggleKeys     = {}

    for k in pairs(loot.GlobalItemsRules) do
        table.insert(loot.TempSettings.SortedGlobalItemKeys, k)
    end
    table.sort(loot.TempSettings.SortedGlobalItemKeys, function(a, b) return a < b end)

    for k in pairs(loot.BuyItemsTable) do
        table.insert(loot.TempSettings.SortedBuyItemKeys, k)
    end
    table.sort(loot.TempSettings.SortedBuyItemKeys, function(a, b) return a < b end)

    for k in pairs(loot.NormalItemsRules) do
        table.insert(loot.TempSettings.SortedNormalItemKeys, k)
    end

    table.sort(loot.TempSettings.SortedNormalItemKeys, function(a, b) return a < b end)

    for k in pairs(loot.Settings) do
        if settingsNoDraw[k] == nil then
            if type(loot.Settings[k]) == 'boolean' then
                table.insert(loot.TempSettings.SortedToggleKeys, k)
            else
                table.insert(loot.TempSettings.SortedSettingsKeys, k)
            end
        end
    end
    table.sort(loot.TempSettings.SortedToggleKeys, function(a, b) return a < b end)
    table.sort(loot.TempSettings.SortedSettingsKeys, function(a, b) return a < b end)
end

function loot.RenderModifyItemWindow()
    if not loot.TempSettings.ModifyItemRule then
        Logger.Error(loot.guiLoot.console, "Item not found in ALLITEMS %s %s", loot.TempSettings.ModifyItemID, loot.TempSettings.ModifyItemTable)
        loot.TempSettings.ModifyItemRule = false
        loot.TempSettings.ModifyItemID = nil
        tempValues = {}
        return
    end
    if loot.TempSettings.ModifyItemTable == 'Personal_Items' then
        loot.TempSettings.ModifyItemTable = loot.PersonalTableName
    end
    local classes = loot.TempSettings.ModifyClasses
    local rule = loot.TempSettings.ModifyItemSetting

    ImGui.SetNextWindowSizeConstraints(ImVec2(300, 200), ImVec2(-1, -1))
    local open, show = ImGui.Begin("Modify Item", nil, ImGuiWindowFlags.AlwaysAutoResize)
    if show then
        local item = loot.ALLITEMS[loot.TempSettings.ModifyItemID]
        if not item then
            item = {
                Name = loot.TempSettings.ModifyItemName,
                Link = loot.TempSettings.ModifyItemLink,
                RaceList = loot.TempSettings.ModifyItemRaceList,
            }
        end
        local questRule = "Quest"
        if item == nil then
            Logger.Error(loot.guiLoot.console, "Item not found in ALLITEMS %s %s", loot.TempSettings.ModifyItemID, loot.TempSettings.ModifyItemTable)
            ImGui.End()
            return
        end
        ImGui.TextUnformatted("Item:")
        ImGui.SameLine()
        ImGui.TextColored(ImVec4(0, 1, 1, 1), item.Name)
        ImGui.SameLine()
        ImGui.TextUnformatted("ID:")
        ImGui.SameLine()
        ImGui.TextColored(ImVec4(1, 1, 0, 1), "%s", loot.TempSettings.ModifyItemID)

        if ImGui.BeginCombo("Table", loot.TempSettings.ModifyItemTable) then
            for i, v in ipairs(tableList) do
                if ImGui.Selectable(v, loot.TempSettings.ModifyItemTable == v) then
                    loot.TempSettings.ModifyItemTable = v
                end
            end
            ImGui.EndCombo()
        end

        if tempValues.Classes == nil and classes ~= nil then
            tempValues.Classes = classes
        end

        ImGui.SetNextItemWidth(100)
        tempValues.Classes = ImGui.InputTextWithHint("Classes", "who can loot or all ex: shm clr dru", tempValues.Classes)

        ImGui.SameLine()
        loot.TempModClass = ImGui.Checkbox("All", loot.TempModClass)

        if tempValues.Rule == nil and rule ~= nil then
            tempValues.Rule = rule
        end

        ImGui.SetNextItemWidth(100)
        if ImGui.BeginCombo("Rule", tempValues.Rule) then
            for i, v in ipairs(settingList) do
                if ImGui.Selectable(v, tempValues.Rule == v) then
                    tempValues.Rule = v
                end
            end
            ImGui.EndCombo()
        end

        if tempValues.Rule == "Quest" then
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            tempValues.Qty = ImGui.InputInt("QuestQty", tempValues.Qty, 1, 1)
            if tempValues.Qty > 0 then
                questRule = string.format("Quest|%s", tempValues.Qty)
            end
        end

        if ImGui.Button("Set Rule") then
            local newRule = tempValues.Rule == "Quest" and questRule or tempValues.Rule
            if tempValues.Classes == nil or tempValues.Classes == '' or loot.TempModClass then
                tempValues.Classes = "All"
            end
            -- loot.modifyItemRule(loot.TempSettings.ModifyItemID, newRule, loot.TempSettings.ModifyItemTable, tempValues.Classes, item.Link)
            if loot.TempSettings.ModifyItemTable == loot.PersonalTableName then
                loot.PersonalItemsRules[loot.TempSettings.ModifyItemID] = newRule
                loot.setPersonalItem(loot.TempSettings.ModifyItemID, newRule, tempValues.Classes, item.Link)
            elseif loot.TempSettings.ModifyItemTable == "Global_Items" then
                loot.GlobalItemsRules[loot.TempSettings.ModifyItemID] = newRule
                loot.setGlobalItem(loot.TempSettings.ModifyItemID, newRule, tempValues.Classes, item.Link)
            else
                loot.NormalItemsRules[loot.TempSettings.ModifyItemID] = newRule
                loot.setNormalItem(loot.TempSettings.ModifyItemID, newRule, tempValues.Classes, item.Link)
            end
            -- loot.setNormalItem(loot.TempSettings.ModifyItemID, newRule,  tempValues.Classes, item.Link)
            loot.TempSettings.ModifyItemRule = false
            loot.TempSettings.ModifyItemID = nil
            loot.TempSettings.ModifyItemTable = nil
            loot.TempSettings.ModifyItemClasses = 'All'
            loot.TempSettings.ModifyItemName = nil
            loot.TempSettings.ModifyItemLink = nil
            loot.TempModClass = false

            ImGui.End()
            return
        end
        ImGui.SameLine()

        ImGui.PushStyleColor(ImGuiCol.Button, ImVec4(1.0, 0.4, 0.4, 0.4))
        if ImGui.Button(Icons.FA_TRASH) then
            if loot.TempSettings.ModifyItemTable == loot.PersonalTableName then
                loot.PersonalItemsRules[loot.TempSettings.ModifyItemID] = nil
                loot.setPersonalItem(loot.TempSettings.ModifyItemID, 'delete', 'All', 'NULL')
            elseif loot.TempSettings.ModifyItemTable == "Global_Items" then
                -- loot.GlobalItemsRules[loot.TempSettings.ModifyItemID] = nil
                loot.setGlobalItem(loot.TempSettings.ModifyItemID, 'delete', 'All', 'NULL')
            else
                loot.setNormalItem(loot.TempSettings.ModifyItemID, 'delete', 'All', 'NULL')
            end
            loot.TempSettings.ModifyItemRule = false
            loot.TempSettings.ModifyItemID = nil
            loot.TempSettings.ModifyItemTable = nil
            loot.TempSettings.ModifyItemClasses = 'All'
            ImGui.PopStyleColor()

            ImGui.End()
            return
        end
        ImGui.PopStyleColor()

        ImGui.SameLine()
        if ImGui.Button("Cancel") then
            loot.TempSettings.ModifyItemRule = false
            loot.TempSettings.ModifyItemID = nil
            loot.TempSettings.ModifyItemTable = nil
            loot.TempSettings.ModifyItemClasses = 'All'
            loot.TempSettings.ModifyItemName = nil
            loot.TempSettings.ModifyItemLink = nil
        end
    end
    if not open then
        loot.TempSettings.ModifyItemRule = false
        loot.TempSettings.ModifyItemID = nil
        loot.TempSettings.ModifyItemTable = nil
        loot.TempSettings.ModifyItemClasses = 'All'
        loot.TempSettings.ModifyItemName = nil
        loot.TempSettings.ModifyItemLink = nil
    end
    ImGui.End()
end

function loot.drawNewItemsTable()
    local itemsToRemove = {}
    if loot.NewItems == nil then showNewItem = false end
    if #loot.NewItems < 0 then
        showNewItem = false
        loot.NewItemsCount = 0
    end
    if loot.NewItemsCount > 0 then
        if ImGui.BeginTable('##newItemTable', 3, bit32.bor(
                ImGuiTableFlags.Borders, ImGuiTableFlags.ScrollX,
                ImGuiTableFlags.Reorderable,
                ImGuiTableFlags.RowBg)) then
            -- Setup Table Columns
            ImGui.TableSetupColumn('Item', bit32.bor(ImGuiTableColumnFlags.WidthStretch), 130)
            ImGui.TableSetupColumn('Classes', ImGuiTableColumnFlags.NoResize, 150)
            ImGui.TableSetupColumn('Rule', bit32.bor(ImGuiTableColumnFlags.NoResize), 90)
            ImGui.TableHeadersRow()

            -- Iterate Over New Items
            for idx, itemID in ipairs(loot.TempSettings.NewItemIDs) do
                local item = loot.NewItems[itemID]

                -- Ensure tmpRules has a default value
                if itemID == nil or item == nil then
                    Logger.Error(loot.guiLoot.console, "Invalid item in NewItems table: %s", itemID)
                    loot.NewItemsCount = 0
                    break
                end
                ImGui.PushID(itemID)
                tmpRules[itemID] = tmpRules[itemID] or item.Rule or settingList[1]
                if loot.tempLootAll == nil then
                    loot.tempLootAll = {}
                end
                ImGui.TableNextRow()
                -- Item Name and Link
                ImGui.TableNextColumn()

                ImGui.Indent(2)

                loot.drawIcon(item.Icon, 20)
                if ImGui.IsItemHovered() and ImGui.IsMouseClicked(0) then
                    -- if ImGui.SmallButton(Icons.FA_EYE .. "##" .. itemID) then
                    mq.cmdf('/executelink %s', item.Link)
                end
                ImGui.SameLine()
                ImGui.Text(item.Name or "Unknown")

                ImGui.Unindent(2)
                ImGui.Indent(2)

                if ImGui.BeginTable("SellData", 2, bit32.bor(ImGuiTableFlags.Borders,
                        ImGuiTableFlags.Reorderable)) then
                    ImGui.TableSetupColumn('Value', ImGuiTableColumnFlags.WidthStretch)
                    ImGui.TableSetupColumn('Stacks', ImGuiTableColumnFlags.WidthFixed, 30)
                    ImGui.TableHeadersRow()
                    ImGui.TableNextRow()
                    -- Sell Price
                    ImGui.TableNextColumn()
                    if item.SellPrice ~= '0 pp 0 gp 0 sp 0 cp' then
                        ImGui.Text(item.SellPrice or "0")
                    end
                    ImGui.TableNextColumn()
                    ImGui.Text("%s", item.MaxStacks > 0 and item.MaxStacks or "No")
                    ImGui.EndTable()
                end

                ImGui.Unindent(2)

                -- Classes

                ImGui.TableNextColumn()

                ImGui.Indent(2)

                ImGui.SetNextItemWidth(ImGui.GetColumnWidth(-1) - 50)
                tmpClasses[itemID] = ImGui.InputText('##Classes' .. itemID, tmpClasses[itemID] or item.Classes)
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip("Classes: %s", item.Classes)
                end

                ImGui.SameLine()
                loot.tempLootAll[itemID] = ImGui.Checkbox('All', loot.tempLootAll[itemID])

                ImGui.Unindent(2)


                ImGui.Indent(2)
                if ImGui.BeginTable('ItemFlags', 4, bit32.bor(ImGuiTableFlags.Borders,
                        ImGuiTableFlags.Reorderable)) then
                    ImGui.TableSetupColumn('NoDrop', ImGuiTableColumnFlags.WidthFixed, 30)
                    ImGui.TableSetupColumn('Lore', ImGuiTableColumnFlags.WidthFixed, 30)
                    ImGui.TableSetupColumn("Aug", ImGuiTableColumnFlags.WidthFixed, 30)
                    ImGui.TableSetupColumn('TS', ImGuiTableColumnFlags.WidthFixed, 30)
                    ImGui.TableHeadersRow()
                    ImGui.TableNextRow()
                    -- Flags (NoDrop, Lore, Augment, TradeSkill)
                    ImGui.TableNextColumn()
                    loot.drawYesNo(item.NoDrop)
                    ImGui.TableNextColumn()
                    loot.drawYesNo(item.Lore)
                    ImGui.TableNextColumn()
                    loot.drawYesNo(item.Aug)
                    ImGui.TableNextColumn()
                    loot.drawYesNo(item.Tradeskill)
                    ImGui.EndTable()
                end
                ImGui.Unindent(2)
                -- Rule
                ImGui.TableNextColumn()

                item.selectedIndex = item.selectedIndex or loot.getRuleIndex(item.Rule, settingList)

                ImGui.Indent(2)

                ImGui.SetNextItemWidth(ImGui.GetColumnWidth(-1))
                if ImGui.BeginCombo('##Setting' .. itemID, settingList[item.selectedIndex]) then
                    for i, setting in ipairs(settingList) do
                        local isSelected = item.selectedIndex == i
                        if ImGui.Selectable(setting, isSelected) then
                            item.selectedIndex = i
                            tmpRules[itemID]   = setting
                        end
                    end
                    ImGui.EndCombo()
                end
                ImGui.Unindent(2)

                ImGui.Spacing()
                ImGui.Spacing()

                ImGui.SetCursorPosX(ImGui.GetCursorPosX() + (ImGui.GetColumnWidth(-1) / 6))
                ImGui.PushStyleColor(ImGuiCol.Button, ImVec4(0.040, 0.294, 0.004, 1.000))
                if ImGui.Button('Save Rule') then
                    local classes = loot.tempLootAll[itemID] and "All" or tmpClasses[itemID]


                    loot.addRule(itemID, "NormalItems", tmpRules[itemID], classes, item.Link)
                    loot.enterNewItemRuleInfo({
                        ID = itemID,
                        ItemName = item.Name,
                        Rule = tmpRules[itemID],
                        Classes = classes,
                        Link = item.Link,
                        CorpseID = item.CorpseID,
                    })
                    table.remove(loot.TempSettings.NewItemIDs, idx)
                    table.insert(itemsToRemove, itemID)
                    Logger.Debug(loot.guiLoot.console, "\agSaving\ax --\ayNEW ITEM RULE\ax-- Item: \at%s \ax(ID:\ag %s\ax) with rule: \at%s\ax, classes: \at%s\ax, link: \at%s\ax",
                        item.Name, itemID, tmpRules[itemID], tmpClasses[itemID], item.Link)
                end
                ImGui.PopStyleColor()
                ImGui.PopID()
            end


            ImGui.EndTable()
        end
    end

    -- Remove Processed Items
    for _, itemID in ipairs(itemsToRemove) do
        loot.NewItems[itemID]    = nil
        tmpClasses[itemID]       = nil
        tmpRules[itemID]         = nil
        tmpLinks[itemID]         = nil
        loot.tempLootAll[itemID] = nil
        -- loot.NewItemsCount       = loot.NewItemsCount - 1
    end

    -- Update New Items Count
    if loot.NewItemsCount < 0 then loot.NewItemsCount = 0 end
    if loot.NewItemsCount == 0 then showNewItem = false end
end

function loot.SafeText(write_value)
    local tmpValue = write_value
    if write_value == nil then
        tmpValue = "N/A"
    end
    if tostring(write_value) == 'true' then
        ImGui.TextColored(ImVec4(0.0, 1.0, 0.0, 1.0), "True")
    elseif tostring(write_value) == 'false' or tostring(write_value) == '0' or tostring(write_value) == 'None' then
    elseif tmpValue == "N/A" then
        ImGui.Indent()
        ImGui.TextColored(ImVec4(1.0, 0.0, 0.0, 1.0), tmpValue)
        ImGui.Unindent()
    else
        ImGui.Indent()
        ImGui.Text(tmpValue)
        ImGui.Unindent()
    end
end

function loot.drawTable(label)
    local varSub = label .. 'Items'

    if ImGui.BeginTabItem(varSub .. "##") then
        if loot.TempSettings.varSub == nil then
            loot.TempSettings.varSub = {}
        end
        if loot.TempSettings[varSub .. 'Classes'] == nil then
            loot.TempSettings[varSub .. 'Classes'] = {}
        end
        local sizeX, _ = ImGui.GetContentRegionAvail()
        ImGui.PushStyleColor(ImGuiCol.ChildBg, ImVec4(0.0, 0.6, 0.0, 0.1))
        if ImGui.BeginChild("Add Rule Drop Area", ImVec2(sizeX, 40), ImGuiChildFlags.Border) then
            ImGui.TextDisabled("Drop Item Here to Add to a %s Rule", label)
            if ImGui.IsWindowHovered() and ImGui.IsMouseClicked(0) then
                if mq.TLO.Cursor() ~= nil then
                    local itemCursor = mq.TLO.Cursor
                    loot.addToItemDB(mq.TLO.Cursor)
                    loot.TempSettings.ModifyItemRule = true
                    loot.TempSettings.ModifyItemName = itemCursor.Name()
                    loot.TempSettings.ModifyItemLink = itemCursor.ItemLink('CLICKABLE')() or "NULL"
                    loot.TempSettings.ModifyItemID = itemCursor.ID()
                    loot.TempSettings.ModifyItemTable = label .. "_Items"
                    loot.TempSettings.ModifyClasses = loot.ALLITEMS[itemCursor.ID()].ClassList or "All"
                    loot.TempSettings.ModifyItemSetting = "Ask"
                    tempValues = {}
                    mq.cmdf("/autoinv")
                end
            end
        end
        ImGui.EndChild()
        ImGui.PopStyleColor()
        ImGui.Spacing()
        ImGui.Spacing()
        ImGui.PushID(varSub .. 'Search')
        ImGui.SetNextItemWidth(180)
        loot.TempSettings['Search' .. varSub] = ImGui.InputTextWithHint("Search", "Search by Name or Rule",
            loot.TempSettings['Search' .. varSub]) or nil
        ImGui.PopID()
        if ImGui.IsItemHovered() and mq.TLO.Cursor() then
            loot.TempSettings['Search' .. varSub] = mq.TLO.Cursor()
            mq.cmdf("/autoinv")
        end

        ImGui.SameLine()

        if ImGui.SmallButton(Icons.MD_DELETE_SWEEP) then
            loot.TempSettings['Search' .. varSub] = nil
        end
        if ImGui.IsItemHovered() then ImGui.SetTooltip("Clear Search") end

        local col = 3
        col = math.max(3, math.floor(ImGui.GetContentRegionAvail() / 140))
        local colCount = col + (col % 3)
        if colCount % 3 ~= 0 then
            if (colCount - 1) % 3 == 0 then
                colCount = colCount - 1
            else
                colCount = colCount - 2
            end
        end

        local filteredItems = {}
        local filteredItemKeys = {}
        for id, rule in pairs(loot[varSub .. 'Rules']) do
            if loot.SearchLootTable(loot.TempSettings['Search' .. varSub], loot.ItemNames[id], rule) then
                local iconID = 0
                local itemLink = ''
                if loot.ALLITEMS[id] then
                    iconID = loot.ALLITEMS[id].Icon or 0
                    itemLink = loot.ALLITEMS[id].Link or ''
                end
                if loot[varSub .. 'Link'][id] then
                    itemLink = loot[varSub .. 'Link'][id]
                end
                table.insert(filteredItems, {
                    id = id,
                    data = loot.ItemNames[id],
                    setting = loot[varSub .. 'Rules'][id],
                    icon = iconID,
                    link = itemLink,
                })
                table.insert(filteredItemKeys, loot.ItemNames[id])
            end
        end
        table.sort(filteredItems, function(a, b) return a.data < b.data end)

        local totalItems = #filteredItems
        local totalPages = math.ceil(totalItems / ITEMS_PER_PAGE)

        -- Clamp CurrentPage to valid range
        loot.CurrentPage = math.max(1, math.min(loot.CurrentPage, totalPages))

        -- Navigation buttons
        if ImGui.Button(Icons.FA_BACKWARD) then
            loot.CurrentPage = 1
        end
        ImGui.SameLine()
        if ImGui.ArrowButton("##Previous", ImGuiDir.Left) and loot.CurrentPage > 1 then
            loot.CurrentPage = loot.CurrentPage - 1
        end
        ImGui.SameLine()
        ImGui.Text(("Page %d of %d"):format(loot.CurrentPage, totalPages))
        ImGui.SameLine()
        if ImGui.ArrowButton("##Next", ImGuiDir.Right) and loot.CurrentPage < totalPages then
            loot.CurrentPage = loot.CurrentPage + 1
        end
        ImGui.SameLine()
        if ImGui.Button(Icons.FA_FORWARD) then
            loot.CurrentPage = totalPages
        end

        ImGui.SameLine()
        ImGui.SetNextItemWidth(80)
        if ImGui.BeginCombo("Max Items", tostring(ITEMS_PER_PAGE)) then
            for i = 10, 100, 10 do
                if ImGui.Selectable(tostring(i), ITEMS_PER_PAGE == i) then
                    ITEMS_PER_PAGE = i
                end
            end
            ImGui.EndCombo()
        end
        -- Calculate the range of items to display
        local startIndex = (loot.CurrentPage - 1) * ITEMS_PER_PAGE + 1
        local endIndex = math.min(startIndex + ITEMS_PER_PAGE - 1, totalItems)

        if ImGui.CollapsingHeader('BulkSet') then
            ImGui.Indent(2)
            ImGui.Text("Set all items to the same rule")
            ImGui.SetNextItemWidth(100)
            ImGui.PushID("BulkSet")
            if loot.TempSettings.BulkRule == nil then
                loot.TempSettings.BulkRule = settingList[1]
            end
            if ImGui.BeginCombo("Rule", loot.TempSettings.BulkRule) then
                for i, setting in ipairs(settingList) do
                    local isSelected = loot.TempSettings.BulkRulee == setting
                    if ImGui.Selectable(setting, isSelected) then
                        loot.TempSettings.BulkRule = setting
                    end
                end
                ImGui.EndCombo()
            end
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            if loot.TempSettings.BulkClasses == nil then
                loot.TempSettings.BulkClasses = "All"
            end
            loot.TempSettings.BulkClasses = ImGui.InputTextWithHint("Classes", "who can loot or all ex: shm clr dru", loot.TempSettings.BulkClasses)

            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            if loot.TempSettings.BulkSetTable == nil then
                loot.TempSettings.BulkSetTable = label .. "_Rules"
            end
            if ImGui.BeginCombo("Table", loot.TempSettings.BulkSetTable) then
                for i, v in ipairs(tableListRules) do
                    if ImGui.Selectable(v, loot.TempSettings.BulkSetTable == v) then
                        loot.TempSettings.BulkSetTable = v
                    end
                end
                ImGui.EndCombo()
            end

            ImGui.PopID()
            ImGui.SameLine()
            if ImGui.Button("Set All") then
                loot.TempSettings.BulkSet = {}
                for i = startIndex, endIndex do
                    local itemID = filteredItems[i].id
                    loot.TempSettings.BulkSet[itemID] = loot.TempSettings.BulkRule
                end
                loot.TempSettings.doBulkSet = true
            end
            ImGui.SameLine()
            if ImGui.Button("Delete All") then
                loot.TempSettings.BulkSet = {}
                for i = startIndex, endIndex do
                    local itemID = filteredItems[i].id
                    loot.TempSettings.BulkSet[itemID] = "Delete"
                end
                loot.TempSettings.doBulkSet = true
                loot.TempSettings.bulkDelete = true
            end
            ImGui.Unindent(2)
        end

        if ImGui.BeginTable(label .. " Items", colCount, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable, ImGuiTableFlags.ScrollY), ImVec2(0.0, 0.0)) then
            ImGui.TableSetupScrollFreeze(colCount, 1)
            for i = 1, colCount / 3 do
                ImGui.TableSetupColumn("Item", ImGuiTableColumnFlags.WidthStretch)
                ImGui.TableSetupColumn("Rule", ImGuiTableColumnFlags.WidthFixed, 40)
                ImGui.TableSetupColumn('Classes', ImGuiTableColumnFlags.WidthFixed, 90)
            end
            ImGui.TableHeadersRow()

            if loot[label .. 'ItemsRules'] ~= nil then
                for i = startIndex, endIndex do
                    local itemID = filteredItems[i].id
                    local item = filteredItems[i].data
                    local setting = filteredItems[i].setting
                    local iconID = filteredItems[i].icon
                    local itemLink = filteredItems[i].link

                    ImGui.PushID(itemID)
                    local classes = loot[label .. 'ItemsClasses'][itemID] or "All"
                    local itemName = loot.ItemNames[itemID] or item.Name
                    if loot.SearchLootTable(loot.TempSettings['Search' .. varSub], item, setting) then
                        ImGui.TableNextColumn()
                        ImGui.Indent(2)
                        local btnColor, btnText = ImVec4(0.0, 0.6, 0.0, 0.4), Icons.FA_PENCIL
                        if loot.ALLITEMS[itemID] == nil then
                            btnColor, btnText = ImVec4(0.6, 0.0, 0.0, 0.4), Icons.MD_CLOSE
                        end
                        ImGui.PushStyleColor(ImGuiCol.Button, btnColor)
                        if ImGui.SmallButton(btnText) then
                            loot.TempSettings.ModifyItemRule = true
                            loot.TempSettings.ModifyItemName = itemName
                            loot.TempSettings.ModifyItemLink = itemLink
                            loot.TempSettings.ModifyItemID = itemID
                            loot.TempSettings.ModifyItemTable = label .. "_Items"
                            loot.TempSettings.ModifyClasses = classes
                            loot.TempSettings.ModifyItemSetting = setting
                            tempValues = {}
                        end
                        ImGui.PopStyleColor()

                        ImGui.SameLine()
                        if iconID then
                            loot.drawIcon(iconID, iconSize * fontScale) -- icon
                        else
                            loot.drawIcon(4493, iconSize * fontScale)   -- icon
                        end
                        if ImGui.IsItemHovered() and ImGui.IsMouseClicked(0) then
                            mq.cmdf('/executelink %s', itemLink)
                        end
                        ImGui.SameLine(0, 0)

                        ImGui.Text(itemName)
                        if ImGui.IsItemHovered() then
                            loot.DrawRuleToolTip(itemName, setting, classes:upper())

                            if ImGui.IsMouseClicked(1) and itemLink ~= nil then
                                mq.cmdf('/executelink %s', itemLink)
                            end
                        end
                        ImGui.Unindent(2)
                        ImGui.TableNextColumn()
                        ImGui.Indent(2)
                        loot.drawSettingIcon(setting)

                        if ImGui.IsItemHovered() then
                            loot.DrawRuleToolTip(itemName, setting, classes:upper())
                            if ImGui.IsMouseClicked(1) and itemLink ~= nil then
                                mq.cmdf('/executelink %s', itemLink)
                            end
                        end
                        ImGui.Unindent(2)
                        ImGui.TableNextColumn()
                        ImGui.Indent(2)
                        if classes ~= 'All' then
                            ImGui.TextColored(ImVec4(0, 1, 1, 0.8), classes:upper())
                        else
                            ImGui.TextDisabled(classes:upper())
                        end

                        if ImGui.IsItemHovered() then
                            loot.DrawRuleToolTip(itemName, setting, classes:upper())
                            if ImGui.IsMouseClicked(1) and itemLink ~= nil then
                                mq.cmdf('/executelink %s', itemLink)
                            end
                        end
                        ImGui.Unindent(2)
                    end
                    ImGui.PopID()
                end
            end

            ImGui.EndTable()
        end
        ImGui.EndTabItem()
    end
end

function loot.drawItemsTables()
    ImGui.SetNextItemWidth(100)
    fontScale = ImGui.SliderFloat("Font Scale", fontScale, 1, 2)
    ImGui.SetWindowFontScale(fontScale)

    if ImGui.BeginTabBar("Items", bit32.bor(ImGuiTabBarFlags.Reorderable, ImGuiTabBarFlags.FittingPolicyScroll)) then
        local col = math.max(2, math.floor(ImGui.GetContentRegionAvail() / 150))
        col = col + (col % 2)

        -- Buy Items
        if ImGui.BeginTabItem("Buy Items") then
            if loot.TempSettings.BuyItems == nil then
                loot.TempSettings.BuyItems = {}
            end
            ImGui.Text("Delete the Item Name to remove it from the table")

            if ImGui.SmallButton("Save Changes##BuyItems") then
                for k, v in pairs(loot.TempSettings.UpdatedBuyItems) do
                    if k ~= "" then
                        loot.BuyItemsTable[k] = v
                    end
                end

                for k in pairs(loot.TempSettings.DeletedBuyKeys) do
                    loot.BuyItemsTable[k] = nil
                end

                loot.TempSettings.UpdatedBuyItems = {}
                loot.TempSettings.DeletedBuyKeys = {}

                loot.TempSettings.NeedSave = true
            end

            ImGui.SeparatorText("Add New Item")
            if ImGui.BeginTable("AddItem", 2, ImGuiTableFlags.Borders) then
                ImGui.TableSetupColumn("Item", ImGuiTableColumnFlags.WidthFixed, 280)
                ImGui.TableSetupColumn("Qty", ImGuiTableColumnFlags.WidthFixed, 150)
                ImGui.TableHeadersRow()
                ImGui.TableNextColumn()

                ImGui.SetNextItemWidth(150)
                ImGui.PushID("NewBuyItem")
                loot.TempSettings.NewBuyItem = ImGui.InputText("New Item##BuyItems", loot.TempSettings.NewBuyItem)
                ImGui.PopID()
                if ImGui.IsItemHovered() and mq.TLO.Cursor() ~= nil then
                    loot.TempSettings.NewBuyItem = mq.TLO.Cursor()
                    mq.cmdf("/autoinv")
                end
                ImGui.SameLine()
                ImGui.PushStyleColor(ImGuiCol.Button, ImVec4(0.4, 1.0, 0.4, 0.4))
                if ImGui.SmallButton(Icons.MD_ADD) then
                    loot.BuyItemsTable[loot.TempSettings.NewBuyItem] = loot.TempSettings.NewBuyQty
                    loot.setBuyItem(loot.TempSettings.NewBuyItem, loot.TempSettings.NewBuyQty)
                    loot.TempSettings.NeedSave = true
                    loot.TempSettings.NewBuyItem = ""
                    loot.TempSettings.NewBuyQty = 1
                end
                ImGui.PopStyleColor()

                ImGui.SameLine()
                ImGui.PushStyleColor(ImGuiCol.Button, ImVec4(1.0, 0.4, 0.4, 0.4))
                if ImGui.SmallButton(Icons.MD_DELETE_SWEEP) then
                    loot.TempSettings.NewBuyItem = ""
                end
                ImGui.PopStyleColor()
                ImGui.TableNextColumn()
                ImGui.SetNextItemWidth(120)

                loot.TempSettings.NewBuyQty = ImGui.InputInt("New Qty##BuyItems", (loot.TempSettings.NewBuyQty or 1),
                    1, 50)
                if loot.TempSettings.NewBuyQty > 1000 then loot.TempSettings.NewBuyQty = 1000 end

                ImGui.EndTable()
            end
            ImGui.SeparatorText("Buy Items Table")
            if ImGui.BeginTable("Buy Items", col, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.ScrollY), ImVec2(0.0, 0.0)) then
                ImGui.TableSetupScrollFreeze(col, 1)
                for i = 1, col / 2 do
                    ImGui.TableSetupColumn("Item")
                    ImGui.TableSetupColumn("Qty")
                end
                ImGui.TableHeadersRow()

                local numDisplayColumns = col / 2

                if loot.BuyItemsTable ~= nil and loot.TempSettings.SortedBuyItemKeys ~= nil then
                    loot.TempSettings.UpdatedBuyItems = {}
                    loot.TempSettings.DeletedBuyKeys = {}

                    local numItems = #loot.TempSettings.SortedBuyItemKeys
                    local numRows = math.ceil(numItems / numDisplayColumns)

                    for row = 1, numRows do
                        for column = 0, numDisplayColumns - 1 do
                            local index = row + column * numRows
                            local k = loot.TempSettings.SortedBuyItemKeys[index]
                            if k then
                                local v = loot.BuyItemsTable[k]

                                loot.TempSettings.BuyItems[k] = loot.TempSettings.BuyItems[k] or
                                    { Key = k, Value = v, }

                                ImGui.TableNextColumn()

                                ImGui.SetNextItemWidth(ImGui.GetColumnWidth(-1))
                                local newKey = ImGui.InputText("##Key" .. k, loot.TempSettings.BuyItems[k].Key)

                                ImGui.TableNextColumn()
                                ImGui.SetNextItemWidth(ImGui.GetColumnWidth(-1))
                                local newValue = ImGui.InputText("##Value" .. k,
                                    loot.TempSettings.BuyItems[k].Value)

                                if newValue ~= v and newKey == k then
                                    if newValue == "" then newValue = "NULL" end
                                    loot.TempSettings.UpdatedBuyItems[newKey] = newValue
                                elseif newKey ~= "" and newKey ~= k then
                                    loot.TempSettings.DeletedBuyKeys[k] = true
                                    if newValue == "" then newValue = "NULL" end
                                    loot.TempSettings.UpdatedBuyItems[newKey] = newValue
                                elseif newKey ~= k and newKey == "" then
                                    loot.TempSettings.DeletedBuyKeys[k] = true
                                end

                                loot.TempSettings.BuyItems[k].Key = newKey
                                loot.TempSettings.BuyItems[k].Value = newValue
                                -- end
                            end
                        end
                    end
                end

                ImGui.EndTable()
            end
            ImGui.EndTabItem()
        end


        -- Personal Items
        loot.drawTable("Personal")

        -- Global Items

        loot.drawTable("Global")

        -- Normal Items
        loot.drawTable("Normal")

        -- Lookup Items

        if loot.ALLITEMS ~= nil then
            if ImGui.BeginTabItem("Item Lookup") then
                ImGui.TextWrapped("This is a list of All Items you have Rules for, or have looked up this session from the Items DB")
                ImGui.Spacing()
                ImGui.Text("Import your inventory to the DB with /rgl importinv")
                local sizeX, sizeY = ImGui.GetContentRegionAvail()
                ImGui.PushStyleColor(ImGuiCol.ChildBg, ImVec4(0.0, 0.6, 0.0, 0.1))
                if ImGui.BeginChild("Add Item Drop Area", ImVec2(sizeX, 40), ImGuiChildFlags.Border) then
                    ImGui.TextDisabled("Drop Item Here to Add to DB")
                    if ImGui.IsWindowHovered() and ImGui.IsMouseClicked(0) then
                        if mq.TLO.Cursor() ~= nil then
                            loot.addToItemDB(mq.TLO.Cursor)
                            Logger.Info(loot.guiLoot.console, "Added Item to DB: %s", mq.TLO.Cursor.Name())
                            mq.cmdf("/autoinv")
                        end
                    end
                end
                ImGui.EndChild()
                ImGui.PopStyleColor()

                -- search field
                ImGui.PushID("DBLookupSearch")
                ImGui.SetNextItemWidth(180)

                loot.TempSettings.SearchItems = ImGui.InputTextWithHint("Search Items##AllItems", "Lookup Name or Filter Class",
                    loot.TempSettings.SearchItems) or nil
                ImGui.PopID()
                if ImGui.IsItemHovered() and mq.TLO.Cursor() then
                    loot.TempSettings.SearchItems = mq.TLO.Cursor.Name()
                    mq.cmdf("/autoinv")
                end
                ImGui.SameLine()

                if ImGui.SmallButton(Icons.MD_DELETE_SWEEP) then
                    loot.TempSettings.SearchItems = nil
                end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Clear Search") end

                ImGui.SameLine()

                ImGui.PushStyleColor(ImGuiCol.Button, ImVec4(0.78, 0.20, 0.05, 0.6))
                if ImGui.SmallButton("LookupItem##AllItems") then
                    loot.TempSettings.LookUpItem = true
                end
                ImGui.PopStyleColor()
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Lookup Item in DB") end

                -- setup the filteredItems for sorting
                local filteredItems = {}
                for id, item in pairs(loot.ALLITEMS) do
                    if loot.SearchLootTable(loot.TempSettings.SearchItems, item.Name, item.ClassList) or
                        loot.SearchLootTable(loot.TempSettings.SearchItems, id, item.ClassList) then
                        table.insert(filteredItems, { id = id, data = item, })
                    end
                end
                table.sort(filteredItems, function(a, b) return a.data.Name < b.data.Name end)
                -- Calculate total pages
                local totalItems = #filteredItems
                local totalPages = math.ceil(totalItems / ITEMS_PER_PAGE)

                -- Clamp CurrentPage to valid range
                loot.CurrentPage = math.max(1, math.min(loot.CurrentPage, totalPages))

                -- Navigation buttons
                if ImGui.Button(Icons.FA_BACKWARD) then
                    loot.CurrentPage = 1
                end
                ImGui.SameLine()
                if ImGui.ArrowButton("##Previous", ImGuiDir.Left) and loot.CurrentPage > 1 then
                    loot.CurrentPage = loot.CurrentPage - 1
                end
                ImGui.SameLine()
                ImGui.Text(("Page %d of %d"):format(loot.CurrentPage, totalPages))
                ImGui.SameLine()
                if ImGui.ArrowButton("##Next", ImGuiDir.Right) and loot.CurrentPage < totalPages then
                    loot.CurrentPage = loot.CurrentPage + 1
                end
                ImGui.SameLine()
                if ImGui.Button(Icons.FA_FORWARD) then
                    loot.CurrentPage = totalPages
                end

                ImGui.SameLine()
                ImGui.SetNextItemWidth(80)
                if ImGui.BeginCombo("Max Items", tostring(ITEMS_PER_PAGE)) then
                    for i = 10, 100, 10 do
                        if ImGui.Selectable(tostring(i), ITEMS_PER_PAGE == i) then
                            ITEMS_PER_PAGE = i
                        end
                    end
                    ImGui.EndCombo()
                end

                -- Calculate the range of items to display
                local startIndex = (loot.CurrentPage - 1) * ITEMS_PER_PAGE + 1
                local endIndex = math.min(startIndex + ITEMS_PER_PAGE - 1, totalItems)

                if ImGui.CollapsingHeader('BulkSet') then
                    ImGui.Indent(2)
                    ImGui.Text("Set all items to the same rule")
                    ImGui.SetNextItemWidth(100)
                    ImGui.PushID("BulkSet")
                    if loot.TempSettings.BulkRule == nil then
                        loot.TempSettings.BulkRule = settingList[1]
                    end
                    if ImGui.BeginCombo("Rule", loot.TempSettings.BulkRule) then
                        for i, setting in ipairs(settingList) do
                            local isSelected = loot.TempSettings.BulkRulee == setting
                            if ImGui.Selectable(setting, isSelected) then
                                loot.TempSettings.BulkRule = setting
                            end
                        end
                        ImGui.EndCombo()
                    end
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(100)
                    if loot.TempSettings.BulkClasses == nil then
                        loot.TempSettings.BulkClasses = "All"
                    end
                    loot.TempSettings.BulkClasses = ImGui.InputTextWithHint("Classes", "who can loot or all ex: shm clr dru", loot.TempSettings.BulkClasses)

                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(100)
                    if loot.TempSettings.BulkSetTable == nil then
                        loot.TempSettings.BulkSetTable = "Normal_Rules"
                    end
                    if ImGui.BeginCombo("Table", loot.TempSettings.BulkSetTable) then
                        for i, v in ipairs(tableListRules) do
                            if ImGui.Selectable(v, loot.TempSettings.BulkSetTable == v) then
                                loot.TempSettings.BulkSetTable = v
                            end
                        end
                        ImGui.EndCombo()
                    end

                    ImGui.PopID()
                    ImGui.SameLine()
                    if ImGui.Button("Set All") then
                        loot.TempSettings.BulkSet = {}
                        for i = startIndex, endIndex do
                            local itemID = filteredItems[i].id
                            loot.TempSettings.BulkSet[itemID] = loot.TempSettings.BulkRule
                        end
                        loot.TempSettings.doBulkSet = true
                    end

                    ImGui.Unindent(2)
                end


                -- Render the table
                if ImGui.BeginTable("DB", 59, bit32.bor(ImGuiTableFlags.Borders,
                        ImGuiTableFlags.Hideable, ImGuiTableFlags.Resizable, ImGuiTableFlags.ScrollX, ImGuiTableFlags.ScrollY, ImGuiTableFlags.Reorderable)) then
                    -- Set up column headers
                    for idx, label in pairs(loot.AllItemColumnListIndex) do
                        if label == 'name' then
                            ImGui.TableSetupColumn(label, ImGuiTableColumnFlags.NoHide)
                        else
                            ImGui.TableSetupColumn(label, ImGuiTableColumnFlags.DefaultHide)
                        end
                    end
                    ImGui.TableSetupScrollFreeze(1, 1)
                    ImGui.TableHeadersRow()

                    -- Render only the current page's items
                    for i = startIndex, endIndex do
                        local id = filteredItems[i].id
                        local item = filteredItems[i].data

                        ImGui.PushID(id)

                        -- Render each column for the item
                        ImGui.TableNextColumn()
                        ImGui.Indent(2)
                        loot.drawIcon(item.Icon, iconSize * fontScale)
                        if ImGui.IsItemHovered() and ImGui.IsMouseClicked(0) then
                            mq.cmdf('/executelink %s', item.Link)
                        end
                        ImGui.SameLine()
                        if ImGui.Selectable(item.Name, false) then
                            loot.TempSettings.ModifyItemRule = true
                            loot.TempSettings.ModifyItemID = id
                            loot.TempSettings.ModifyClasses = item.ClassList
                            loot.TempSettings.ModifyItemRaceList = item.RaceList
                            tempValues = {}
                        end
                        if ImGui.IsItemHovered() and ImGui.IsMouseClicked(1) then
                            mq.cmdf('/executelink %s', item.Link)
                        end
                        ImGui.Unindent(2)
                        ImGui.TableNextColumn()
                        -- sell_value
                        if item.Value ~= '0 pp 0 gp 0 sp 0 cp' then
                            loot.SafeText(item.Value)
                        end
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Tribute)     -- tribute_value
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Stackable)   -- stackable
                        ImGui.TableNextColumn()
                        loot.SafeText(item.StackSize)   -- stack_size
                        ImGui.TableNextColumn()
                        loot.SafeText(item.NoDrop)      -- nodrop
                        ImGui.TableNextColumn()
                        loot.SafeText(item.NoTrade)     -- notrade
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Tradeskills) -- tradeskill
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Quest)       -- quest
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Lore)        -- lore
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Collectible) -- collectible
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Augment)     -- augment
                        ImGui.TableNextColumn()
                        loot.SafeText(item.AugType)     -- augtype
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Clicky)      -- clickable
                        ImGui.TableNextColumn()
                        local tmpWeight = item.Weight ~= nil and item.Weight or 0
                        loot.SafeText(tmpWeight)      -- weight
                        ImGui.TableNextColumn()
                        loot.SafeText(item.AC)        -- ac
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Damage)    -- damage
                        ImGui.TableNextColumn()
                        loot.SafeText(item.STR)       -- strength
                        ImGui.TableNextColumn()
                        loot.SafeText(item.DEX)       -- dexterity
                        ImGui.TableNextColumn()
                        loot.SafeText(item.AGI)       -- agility
                        ImGui.TableNextColumn()
                        loot.SafeText(item.STA)       -- stamina
                        ImGui.TableNextColumn()
                        loot.SafeText(item.INT)       -- intelligence
                        ImGui.TableNextColumn()
                        loot.SafeText(item.WIS)       -- wisdom
                        ImGui.TableNextColumn()
                        loot.SafeText(item.CHA)       -- charisma
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HP)        -- hp
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HPRegen)   -- regen_hp
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Mana)      -- mana
                        ImGui.TableNextColumn()
                        loot.SafeText(item.ManaRegen) -- regen_mana
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Haste)     -- haste
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Classes)   -- classes
                        ImGui.TableNextColumn()
                        -- class_list
                        local tmpClassList = item.ClassList ~= nil and item.ClassList or "All"
                        if tmpClassList:lower() ~= 'all' then
                            ImGui.Indent(2)
                            ImGui.TextColored(ImVec4(0, 1, 1, 0.8), tmpClassList)
                            ImGui.Unindent(2)
                        else
                            ImGui.Indent(2)
                            ImGui.TextDisabled(tmpClassList)
                            ImGui.Unindent(2)
                        end
                        if ImGui.IsItemHovered() then
                            ImGui.BeginTooltip()
                            ImGui.Text(item.Name)
                            ImGui.PushTextWrapPos(200)
                            ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0, 1, 1, 0.8))
                            ImGui.TextWrapped("Classes: %s", tmpClassList)
                            ImGui.PopStyleColor()
                            ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0.852, 0.589, 0.259, 1.000))
                            ImGui.TextWrapped("Races: %s", item.RaceList)
                            ImGui.PopStyleColor()
                            ImGui.PopTextWrapPos()
                            ImGui.EndTooltip()
                        end
                        ImGui.TableNextColumn()
                        loot.SafeText(item.svFire)          -- svfire
                        ImGui.TableNextColumn()
                        loot.SafeText(item.svCold)          -- svcold
                        ImGui.TableNextColumn()
                        loot.SafeText(item.svDisease)       -- svdisease
                        ImGui.TableNextColumn()
                        loot.SafeText(item.svPoison)        -- svpoison
                        ImGui.TableNextColumn()
                        loot.SafeText(item.svCorruption)    -- svcorruption
                        ImGui.TableNextColumn()
                        loot.SafeText(item.svMagic)         -- svmagic
                        ImGui.TableNextColumn()
                        loot.SafeText(item.SpellDamage)     -- spelldamage
                        ImGui.TableNextColumn()
                        loot.SafeText(item.SpellShield)     -- spellshield
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Size)            -- item_size
                        ImGui.TableNextColumn()
                        loot.SafeText(item.WeightReduction) -- weightreduction
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Races)           -- races
                        ImGui.TableNextColumn()
                        -- race_list
                        if item.RaceList ~= nil then
                            if item.RaceList:lower() ~= 'all' then
                                ImGui.Indent(2)
                                ImGui.TextColored(ImVec4(0.852, 0.589, 0.259, 1.000), item.RaceList)
                                ImGui.Unindent(2)
                            else
                                ImGui.Indent(2)
                                ImGui.TextDisabled(item.RaceList)
                                ImGui.Unindent(2)
                            end
                            if ImGui.IsItemHovered() then
                                ImGui.BeginTooltip()
                                ImGui.Text(item.Name)
                                ImGui.PushTextWrapPos(200)
                                ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0, 1, 1, 0.8))
                                ImGui.TextWrapped("Classes: %s", tmpClassList)
                                ImGui.PopStyleColor()
                                ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0.852, 0.589, 0.259, 1.000))
                                ImGui.TextWrapped("Races: %s", item.RaceList)
                                ImGui.PopStyleColor()
                                ImGui.PopTextWrapPos()
                                ImGui.EndTooltip()
                            end
                        end
                        ImGui.TableNextColumn()

                        loot.SafeText(item.Range)              -- item_range
                        ImGui.TableNextColumn()
                        loot.SafeText(item.Attack)             -- attack
                        ImGui.TableNextColumn()
                        loot.SafeText(item.StrikeThrough)      -- strikethrough
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicAGI)          -- heroicagi
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicCHA)          -- heroiccha
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicDEX)          -- heroicdex
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicINT)          -- heroicint
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicSTA)          -- heroicsta
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicSTR)          -- heroicstr
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicSvCold)       -- heroicsvcold
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicSvCorruption) -- heroicsvcorruption
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicSvDisease)    -- heroicsvdisease
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicSvFire)       -- heroicsvfire
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicSvMagic)      -- heroicsvmagic
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicSvPoison)     -- heroicsvpoison
                        ImGui.TableNextColumn()
                        loot.SafeText(item.HeroicWIS)          -- heroicwis

                        ImGui.PopID()
                    end
                    ImGui.EndTable()
                end
                ImGui.EndTabItem()
            end
        end
    end

    if loot.NewItems ~= nil and loot.NewItemsCount > 0 then
        if ImGui.BeginTabItem("New Items") then
            loot.drawNewItemsTable()
            ImGui.EndTabItem()
        end
    end
    ImGui.EndTabBar()
end

function loot.DrawRuleToolTip(name, setting, classes)
    ImGui.BeginTooltip()

    ImGui.Text("Item:")
    ImGui.SameLine()
    ImGui.TextColored(1, 1, 0.50, 1, name)

    ImGui.Text("Setting:")
    ImGui.SameLine()
    ImGui.TextColored(0.5, 1, 1, 1, setting)

    ImGui.Text("Classes:")
    ImGui.SameLine()
    ImGui.TextColored(0.5, 1, 0.5, 1, classes)

    ImGui.Separator()
    ImGui.Text("Right Click to View Item Details")

    ImGui.EndTooltip()
end

---comment
---@param item_table table Index of ItemId's to set
---@param setting any Setting to set all items to
---@param classes any Classes to set all items to
---@param which_table string Which Rules table
---@param delete_items boolean Delete items from the table
function loot.bulkSet(item_table, setting, classes, which_table, delete_items)
    if item_table == nil or type(item_table) ~= "table" then return end
    local localName = which_table == 'Normal_Rules' and 'NormalItems' or 'GlobalItems'
    localName = which_table == loot.PersonalTableName and 'PersonalItems' or localName

    local db = SQLite3.open(RulesDB)
    if not db then return end
    db:exec("PRAGMA journal_mode=WAL;")

    local qry = string.format([[
        INSERT INTO %s (item_id, item_name, item_rule, item_rule_classes, item_link)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(item_id) DO UPDATE SET
            item_name = excluded.item_name,
            item_rule = excluded.item_rule,
            item_rule_classes = excluded.item_rule_classes,
            item_link = excluded.item_link;
    ]], which_table)
    if delete_items then
        qry = string.format([[
            DELETE FROM %s WHERE item_id = ?;
        ]], which_table)
    end
    local stmt = db:prepare(qry)

    if not stmt then
        db:close()
        return
    end

    db:exec("BEGIN TRANSACTION;")

    for itemID, data in pairs(item_table) do
        local item = loot.ALLITEMS[itemID]
        if item then
            if not delete_items then
                stmt:bind_values(itemID, item.Name, setting, classes, item.Link)
                stmt:step()
                stmt:reset()
                loot[localName .. 'Rules'][itemID] = setting
                loot[localName .. 'Classes'][itemID] = classes
                loot[localName .. 'Link'][itemID] = item.Link
                loot.ItemNames[itemID] = item.Name
            else
                stmt:bind_values(itemID)
                stmt:step()
                stmt:reset()
                loot[localName .. 'Rules'][itemID] = nil
                loot[localName .. 'Classes'][itemID] = nil
                loot[localName .. 'Link'][itemID] = nil
                loot.ItemNames[itemID] = nil
            end
        end
    end

    db:exec("COMMIT;")
    stmt:finalize()
    db:close()
    if localName ~= 'PersonalItems' then
        loot.TempSettings.NeedSave = true
        local message = {
            action = 'reloadrules',
            who = MyName,
            Server = eqServer,
            bulkLabel = localName,
            bulkRules = loot[localName .. 'Rules'],
            bulkClasses = loot[localName .. 'Classes'],
            bulkLink = loot[localName .. 'Link'],
        }
        loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, message)
        loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, message)
    end
    loot.TempSettings.BulkSet = {}
end

function loot.drawSettingIcon(setting)
    if string.find(setting, 'Destroy') then
        ImGui.TextColored(0.860, 0.104, 0.104, 1.000, Icons.MD_DELETE)
    elseif string.find(setting, 'Quest') then
        ImGui.TextColored(1.000, 0.914, 0.200, 1.000, Icons.MD_SEARCH)
        if string.find(setting, "|") then
            ImGui.PushID(setting)
            local qty = string.sub(setting, string.find(setting, "|") + 1)
            ImGui.SameLine()
            ImGui.TextColored(0.00, 0.614, 0.800, 1.000, qty)
            ImGui.PopID()
        end
    elseif string.find(setting, "Tribute") then
        ImGui.TextColored(0.991, 0.506, 0.230, 1.000, Icons.FA_GIFT)
    elseif string.find(setting, 'Sell') then
        ImGui.TextColored(0, 1, 0, 1, Icons.MD_ATTACH_MONEY)
    elseif string.find(setting, 'Keep') then
        ImGui.TextColored(0.916, 0.094, 0.736, 1.000, Icons.MD_FAVORITE_BORDER)
    elseif string.find(setting, 'Unknown') then
        ImGui.TextColored(0.5, 0.5, 0.5, 1.000, Icons.FA_QUESTION)
    elseif string.find(setting, 'Ignore') then
        ImGui.TextColored(0.976, 0.218, 0.244, 1.000, Icons.MD_NOT_INTERESTED)
    elseif string.find(setting, 'Bank') then
        ImGui.TextColored(0.162, 0.785, 0.877, 1.000, Icons.MD_ACCOUNT_BALANCE)
    elseif string.find(setting, 'CanUse') then
        ImGui.TextColored(0.411, 0.462, 0.678, 1.000, Icons.FA_USER_O)
    else
        ImGui.Text(setting)
    end
end

function loot.drawSwitch(settingName, who)
    if who == MyName then
        if loot.Settings[settingName] then
            ImGui.TextColored(0.3, 1.0, 0.3, 0.9, Icons.FA_TOGGLE_ON)
        else
            ImGui.TextColored(1.0, 0.3, 0.3, 0.8, Icons.FA_TOGGLE_OFF)
        end
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip("%s %s", settingName, loot.Settings[settingName] and "Enabled" or "Disabled")
        end
        if ImGui.IsItemHovered() and ImGui.IsMouseClicked(0) then
            loot.Settings[settingName] = not loot.Settings[settingName]
            loot.TempSettings.NeedSave = true
        end
    elseif loot.Boxes[who] ~= nil then
        if loot.Boxes[who][settingName] then
            ImGui.TextColored(0.3, 1.0, 0.3, 0.9, Icons.FA_TOGGLE_ON)
        else
            ImGui.TextColored(1.0, 0.3, 0.3, 0.8, Icons.FA_TOGGLE_OFF)
        end
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip("%s %s", settingName, loot.Boxes[who][settingName] and "Enabled" or "Disabled")
        end
        if ImGui.IsItemHovered() and ImGui.IsMouseClicked(0) then
            loot.Boxes[who][settingName] = not loot.Boxes[who][settingName]
        end
    end
end

loot.TempSettings.Edit = {}
function loot.renderSettingsSection(who)
    if who == nil then who = MyName end
    local col = 2
    col = math.max(2, math.floor(ImGui.GetContentRegionAvail() / 140))
    local colCount = col + (col % 2)
    if colCount % 2 ~= 0 then
        if (colCount - 1) % 2 == 0 then
            colCount = colCount - 1
        else
            colCount = colCount - 2
        end
    end
    ImGui.SameLine()
    if ImGui.SmallButton("Send Settings##LootnScoot") then
        if who == MyName then
            for k, v in pairs(loot.Boxes[MyName]) do
                if type(v) == 'table' then
                    for k2, v2 in pairs(v) do
                        loot.Settings[k][k2] = v2
                    end
                else
                    loot.Settings[k] = v
                end
            end
            loot.writeSettings()
            loot.sendMySettings()
        else
            local tmpSet = {}
            for k, v in pairs(loot.Boxes[who]) do
                if type(v) == 'table' then
                    tmpSet[k] = {}
                    for k2, v2 in pairs(v) do
                        tmpSet[k][k2] = v2
                    end
                else
                    tmpSet[k] = v
                end
            end
            local message = {
                action = 'updatesettings',
                who = who,
                settings = tmpSet,
            }
            loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, message)
            loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, message)
        end
    end
    ImGui.SeparatorText("Clone Settings")
    ImGui.SetNextItemWidth(120)
    local source
    if loot.TempSettings.CloneWho == nil then
        source = "Select Source"
    else
        source = loot.TempSettings.CloneWho
    end
    if ImGui.BeginCombo('##Source', source) then
        for k, v in pairs(loot.Boxes) do
            if ImGui.Selectable(k, source == k) then
                loot.TempSettings.CloneWho = k
            end
        end
        ImGui.EndCombo()
    end
    ImGui.SameLine()
    local dest
    if loot.TempSettings.CloneTo == nil then
        dest = "Select Destination"
    else
        dest = loot.TempSettings.CloneTo
    end
    ImGui.SetNextItemWidth(120)
    if ImGui.BeginCombo('##Dest', dest) then
        for k, v in pairs(loot.Boxes) do
            if ImGui.Selectable(k, dest == k) then
                loot.TempSettings.CloneTo = k
            end
        end
        ImGui.EndCombo()
    end
    if loot.TempSettings.CloneWho and loot.TempSettings.CloneTo then
        ImGui.SameLine()

        if ImGui.SmallButton("Clone Settings") then
            loot.Boxes[loot.TempSettings.CloneTo] = {}
            for k, v in pairs(loot.Boxes[loot.TempSettings.CloneWho]) do
                if type(v) == 'table' then
                    loot.Boxes[loot.TempSettings.CloneTo][k] = {}
                    for k2, v2 in pairs(v) do
                        loot.Boxes[loot.TempSettings.CloneTo][k][k2] = v2
                    end
                else
                    loot.Boxes[loot.TempSettings.CloneTo][k] = v
                end
            end
            local tmpSet = {}
            for k, v in pairs(loot.Boxes[loot.TempSettings.CloneTo]) do
                if type(v) == 'table' then
                    tmpSet[k] = {}
                    for k2, v2 in pairs(v) do
                        tmpSet[k][k2] = v2
                    end
                else
                    tmpSet[k] = v
                end
            end
            local message = {
                action = 'updatesettings',
                who = loot.TempSettings.CloneTo,
                settings = tmpSet,
            }
            loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, message)
            loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, message)

            loot.TempSettings.CloneTo = nil
        end
    end


    local sorted_settings = loot.SortTableColums(nil, loot.TempSettings.SortedSettingsKeys, colCount / 2)
    local sorted_toggles = loot.SortTableColums(nil, loot.TempSettings.SortedToggleKeys, colCount / 2)
    if ImGui.BeginTable("##Settings", colCount, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.AutoResizeY, ImGuiTableFlags.Resizable)) then
        ImGui.TableSetupScrollFreeze(colCount, 1)
        for i = 1, colCount / 2 do
            ImGui.TableSetupColumn("Setting", ImGuiTableColumnFlags.WidthStretch)
            ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthFixed, 80)
        end
        ImGui.TableHeadersRow()

        for i, settingName in ipairs(sorted_settings) do
            if settingsNoDraw[settingName] == nil or settingsNoDraw[settingName] == false then
                if type(loot.Boxes[who][settingName]) ~= "boolean" then
                    ImGui.PushID(settingName)
                    ImGui.TableNextColumn()
                    ImGui.Indent(2)
                    ImGui.Text(settingName)
                    ImGui.Unindent(2)
                    ImGui.TableNextColumn()
                    if type(loot.Boxes[who][settingName]) == "number" then
                        ImGui.SetNextItemWidth(ImGui.GetColumnWidth(-1))
                        loot.Boxes[who][settingName] = ImGui.InputInt("##" .. settingName, loot.Boxes[who][settingName])
                    elseif type(loot.Boxes[who][settingName]) == "string" then
                        ImGui.SetNextItemWidth(ImGui.GetColumnWidth(-1))
                        loot.Boxes[who][settingName] = ImGui.InputText("##" .. settingName, loot.Boxes[who][settingName])
                    end
                    ImGui.PopID()
                end
            end
        end
        ImGui.EndTable()
    end
    if ImGui.BeginTable("Toggles##1", colCount, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable, ImGuiTableFlags.ScrollY)) then
        ImGui.TableSetupScrollFreeze(colCount, 1)
        for i = 1, colCount / 2 do
            ImGui.TableSetupColumn("Setting", ImGuiTableColumnFlags.WidthStretch)
            ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthFixed, 80)
        end
        ImGui.TableHeadersRow()

        for i, settingName in ipairs(sorted_toggles) do
            if settingsNoDraw[settingName] == nil or settingsNoDraw[settingName] == false then
                if type(loot.Boxes[who][settingName]) == "boolean" then
                    ImGui.PushID(settingName)
                    ImGui.TableNextColumn()
                    ImGui.Indent(2)
                    -- ImGui.Text(settingName)
                    if ImGui.Selectable(settingName) then
                        loot.Boxes[who][settingName] = not loot.Boxes[who][settingName]
                        if who == MyName then
                            loot.Settings[settingName] = loot.Boxes[who][settingName]
                            loot.TempSettings.NeedSave = true
                        end
                    end
                    ImGui.Unindent(2)
                    ImGui.TableNextColumn()

                    local posX, posY = ImGui.GetCursorPos()
                    ImGui.SetCursorPosX(posX + (ImGui.GetColumnWidth(-1) / 2) - 5)
                    loot.drawSwitch(settingName, who)
                    ImGui.PopID()
                end
            end
        end
        ImGui.EndTable()
    end
end

function loot.drawRecord(tableToDraw)
    if not loot.TempSettings.PastHistory then return end
    if tableToDraw == nil then tableToDraw = loot.TempSettings.SessionHistory or {} end
    if loot.HistoryDataDate ~= nil then
        if #loot.HistoryDataDate > 0 then tableToDraw = loot.HistoryDataDate end
    end
    local openWin, showRecord = ImGui.Begin("Loot PastHistory##", true)
    if not openWin then
        loot.TempSettings.PastHistory = false
    end

    if showRecord then
        if loot.TempSettings.DateLookup == nil then
            loot.TempSettings.DateLookup = os.date("%Y-%m-%d")
        end
        ImGui.SetNextItemWidth(150)
        if ImGui.BeginCombo('##', loot.TempSettings.DateLookup) then
            for i, v in ipairs(loot.HistoricalDates) do
                if ImGui.Selectable(v, loot.TempSettings.DateLookup == v) then
                    loot.TempSettings.DateLookup = v
                end
            end
            ImGui.EndCombo()
        end
        ImGui.SameLine()
        if ImGui.SmallButton(Icons.FA_CALENDAR .. "Load Date") then
            loot.TempSettings.LookUpDateData = true
            lookupDate = loot.TempSettings.DateLookup
        end
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip("Load Data for %s", loot.TempSettings.DateLookup)
        end
        ImGui.SameLine()
        if ImGui.SmallButton(Icons.MD_TIMELAPSE .. 'Session') then
            loot.TempSettings.ClearDateData = true
        end
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip("This Session Only", loot.TempSettings.DateLookup)
        end
        if loot.TempSettings.FilterHistory == nil then
            loot.TempSettings.FilterHistory = ''
        end
        -- Pagination Variables
        local filteredTable = {}
        for i = 1, #tableToDraw do
            local item = tableToDraw[i]
            if item then
                if loot.TempSettings.FilterHistory ~= '' then
                    local filterString = loot.TempSettings.FilterHistory:lower()
                    filterString = filterString:gsub("%:", ""):gsub("%-", "")
                    local filterTS = item.TimeStamp:gsub("%:", ""):gsub("%-", "")
                    local filterDate = item.Date:gsub("%:", ""):gsub("%-", "")
                    if not (string.find(item.Item:lower(), filterString) or
                            string.find(filterDate, filterString) or
                            string.find(filterTS, filterString) or
                            string.find(item.Looter:lower(), filterString) or
                            string.find(item.Action:lower(), filterString) or
                            string.find(item.CorpseName:lower(), filterString) or
                            string.find(item.Zone:lower(), filterString)) then
                        goto continue
                    end
                end
                table.insert(filteredTable, item)
            end
            ::continue::
        end
        table.sort(filteredTable, function(a, b)
            return a.Date .. a.TimeStamp > b.Date .. b.TimeStamp
        end)
        ImGui.SeparatorText("Loot History")
        loot.histItemsPerPage = loot.histItemsPerPage or 20 -- Items per page
        loot.histCurrentPage = loot.histCurrentPage or 1
        local totalItems = #tableToDraw
        local totalFilteredItems = #filteredTable
        local totalPages = math.max(1, math.ceil(totalFilteredItems / loot.histItemsPerPage))

        -- Filter Input

        ImGui.SetNextItemWidth(150)
        loot.TempSettings.FilterHistory = ImGui.InputTextWithHint("##FilterHistory", "Filter by Fields", loot.TempSettings.FilterHistory)
        ImGui.SameLine()
        if ImGui.SmallButton(Icons.MD_DELETE_SWEEP) then
            loot.TempSettings.FilterHistory = ''
        end
        ImGui.SameLine()
        ImGui.Text("Found: ")
        ImGui.SameLine()
        ImGui.TextColored(ImVec4(0, 1, 1, 1), tostring(totalFilteredItems))
        ImGui.SameLine()
        ImGui.Text("Total: ")
        ImGui.SameLine()
        ImGui.TextColored(ImVec4(1, 1, 0, 1), tostring(totalItems))

        -- Clamp the current page
        loot.histCurrentPage = math.max(1, math.min(loot.histCurrentPage, totalPages))

        -- Navigation Buttons
        if ImGui.Button(Icons.FA_BACKWARD) then
            loot.histCurrentPage = 1
        end
        ImGui.SameLine()
        if ImGui.ArrowButton("##Previous", ImGuiDir.Left) and loot.histCurrentPage > 1 then
            loot.histCurrentPage = loot.histCurrentPage - 1
        end
        ImGui.SameLine()
        ImGui.Text(string.format("Page %d of %d", loot.histCurrentPage, totalPages))
        ImGui.SameLine()
        if ImGui.ArrowButton("##Next", ImGuiDir.Right) and loot.histCurrentPage < totalPages then
            loot.histCurrentPage = loot.histCurrentPage + 1
        end
        ImGui.SameLine()
        if ImGui.Button(Icons.FA_FORWARD) then
            loot.histCurrentPage = totalPages
        end

        ImGui.SameLine()

        ImGui.Text("Items Per Page")
        ImGui.SameLine()
        ImGui.SetNextItemWidth(80)
        if ImGui.BeginCombo('##pageSize', tostring(loot.histItemsPerPage)) then
            for i = 1, 200 do
                if i % 25 == 0 then
                    if ImGui.Selectable(tostring(i), loot.histItemsPerPage == i) then
                        loot.histItemsPerPage = i
                    end
                end
            end
            ImGui.EndCombo()
        end


        -- Table

        if ImGui.BeginTable("Items History", 7, bit32.bor(ImGuiTableFlags.ScrollX, ImGuiTableFlags.ScrollY,
                ImGuiTableFlags.Hideable, ImGuiTableFlags.Reorderable, ImGuiTableFlags.Resizable, ImGuiTableFlags.Borders, ImGuiTableFlags.RowBg)) then
            ImGui.TableSetupColumn("Date", ImGuiTableColumnFlags.WidthFixed, 100)
            ImGui.TableSetupColumn("TimeStamp", ImGuiTableColumnFlags.WidthFixed, 100)
            ImGui.TableSetupColumn("Item", ImGuiTableColumnFlags.WidthFixed, 150)
            ImGui.TableSetupColumn("Looter", ImGuiTableColumnFlags.WidthFixed, 75)
            ImGui.TableSetupColumn("Action", ImGuiTableColumnFlags.WidthFixed, 75)
            ImGui.TableSetupColumn("Corpse", ImGuiTableColumnFlags.WidthFixed, 100)
            ImGui.TableSetupColumn("Zone", ImGuiTableColumnFlags.WidthFixed, 100)
            ImGui.TableHeadersRow()

            -- Calculate start and end indices for pagination
            local startIdx = (loot.histCurrentPage - 1) * loot.histItemsPerPage + 1
            local endIdx = math.min(startIdx + loot.histItemsPerPage - 1, totalFilteredItems)

            for i = startIdx, endIdx do
                local item = filteredTable[i]
                if item then
                    if loot.TempSettings.FilterHistory ~= '' then
                        local filterString = loot.TempSettings.FilterHistory:lower()
                        filterString = filterString:gsub("%:", ""):gsub("%-", "")
                        local filterTS = item.TimeStamp:gsub("%:", ""):gsub("%-", "")
                        local filterDate = item.Date:gsub("%:", ""):gsub("%-", "")
                        if not (string.find(item.Item:lower(), filterString) or
                                string.find(filterDate, filterString) or
                                string.find(filterTS, filterString) or
                                string.find(item.Looter:lower(), filterString) or
                                string.find(item.Action:lower(), filterString) or
                                string.find(item.CorpseName:lower(), filterString) or
                                string.find(item.Zone:lower(), filterString)) then
                            goto continue
                        end
                    end

                    ImGui.TableNextColumn()
                    ImGui.TextColored(ImVec4(1, 1, 0, 1), item.Date)
                    ImGui.TableNextColumn()
                    ImGui.TextColored(ImVec4(0, 1, 1, 1), item.TimeStamp)
                    ImGui.TableNextColumn()
                    ImGui.Text(item.Item)
                    if ImGui.IsItemHovered() and ImGui.IsItemClicked(0) then
                        mq.cmdf('/executelink %s', item.Link)
                    end
                    ImGui.TableNextColumn()
                    ImGui.TextColored(ImVec4(1.000, 0.557, 0.000, 1.000), item.Looter)
                    ImGui.TableNextColumn()
                    ImGui.Text(item.Action == 'Looted' and 'Keep' or item.Action)
                    ImGui.TableNextColumn()
                    ImGui.TextColored(ImVec4(0.976, 0.518, 0.844, 1.000), item.CorpseName)
                    ImGui.TableNextColumn()
                    ImGui.Text(item.Zone)
                    ::continue::
                end
            end
            ImGui.EndTable()
        end
    end

    ImGui.End()
end

function loot.renderNewItem()
    if ((loot.Settings.AutoShowNewItem and loot.NewItemsCount > 0) and showNewItem) or showNewItem then
        ImGui.SetNextWindowSize(600, 400, ImGuiCond.FirstUseEver)
        local open, show = ImGui.Begin('New Items', true)
        if not open then
            show = false
            showNewItem = false
        end
        if show then
            loot.drawNewItemsTable()
        end
        ImGui.End()
    end
end

local animMini       = mq.FindTextureAnimation("A_DragItem")
local EQ_ICON_OFFSET = 500


local function renderBtn()
    -- apply_style()

    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, ImVec2(9, 9))
    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 0)
    local openBtn, showBtn = ImGui.Begin(string.format("LootNScoot##Mini"), true,
        bit32.bor(ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoCollapse))
    if not openBtn then
        showBtn = false
    end

    if showBtn then
        if loot.NewItemsCount > 0 then
            animMini:SetTextureCell(645 - EQ_ICON_OFFSET)
        else
            animMini:SetTextureCell(644 - EQ_ICON_OFFSET)
        end
        ImGui.DrawTextureAnimation(animMini, 34, 34, true)
    end
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.Text("LootnScoot")
        ImGui.Text("Click to Show/Hide")
        ImGui.Text("Right Click to Show New Items")
        ImGui.EndTooltip()
        if ImGui.IsMouseReleased(0) then
            loot.ShowUI = not loot.ShowUI
        elseif ImGui.IsMouseReleased(1) and loot.NewItemsCount > 0 then
            showNewItem = not showNewItem
        end
    end
    if (ImGui.IsKeyDown(ImGuiMod.Ctrl) and ImGui.IsMouseClicked(2)) then
        loot.ShowUI = not loot.ShowUI
    end
    ImGui.PopStyleVar(2)
    ImGui.End()
end

function loot.RenderUIs()
    local colCount, styCount = loot.guiLoot.DrawTheme()

    if loot.NewItemDecisions ~= nil then
        loot.enterNewItemRuleInfo(loot.NewItemDecisions)
        loot.NewItemDecisions = nil
    end

    if loot.TempSettings.ModifyItemRule then loot.RenderModifyItemWindow() end

    loot.renderNewItem()

    if loot.pendingItemData ~= nil then
        loot.processPendingItem()
    end

    loot.renderMainUI()

    renderBtn()

    if loot.TempSettings.PastHistory then
        loot.drawRecord()
    end

    if colCount > 0 then ImGui.PopStyleColor(colCount) end
    if styCount > 0 then ImGui.PopStyleVar(styCount) end
end

function loot.enterNewItemRuleInfo(data_table)
    if data_table == nil then
        if loot.NewItemDecisions == nil then return end
        data_table = loot.NewItemDecisions
    end

    if data_table.ID == nil then
        Logger.Error(loot.guiLoot.console, "loot.enterNewItemRuleInfo \arInvalid item \atID \axfor new item rule.")
        return
    end
    Logger.Debug(loot.guiLoot.console,
        "\aoloot.enterNewItemRuleInfo() \axSending \agNewItem Data\ax message \aoMailbox\ax \atlootnscoot actor\ax: item\at %s \ax, ID\at %s \ax, rule\at %s\ax, classes\at %s\ax, link\at %s\ax, corpseID\at %s\ax",
        data_table.ItemName, data_table.ItemID, data_table.Rule, data_table.Classes, data_table.Link, data_table.CorpseID)

    local itemID     = data_table.ID
    local item       = data_table.ItemName
    local rule       = data_table.Rule
    local classes    = data_table.Classes
    local link       = data_table.Link
    local corpse     = data_table.CorpseID
    local modMessage = {
        who      = MyName,
        action   = 'modifyitem',
        section  = "NormalItems",
        item     = item,
        itemID   = itemID,
        rule     = rule,
        link     = link,
        classes  = classes,
        entered  = true,
        corpse   = corpse,
        noChange = false,
        Server   = eqServer,
    }
    if (classes == loot.NormalItemsClasses[itemID] and rule == loot.NormalItemsRules[itemID]) then
        modMessage.noChange = true

        Logger.Debug(loot.guiLoot.console, "\ayNo Changes Made to Item: \at%s \ax(ID:\ag %s\ax) with rule: \at%s\ax, classes: \at%s\ax",
            ltem, itemID, rule, classes)
    else
        Logger.Debug(loot.guiLoot.console,
            "\aoloot.enterNewItemRuleInfo() \axSending \agENTERED ITEM\ax message \aoMailbox\ax \atlootnscoot actor\ax: item\at %s \ax, ID\at %s \ax, rule\at %s\ax, classes\at %s\ax, link\at %s\ax, corpseID\at %s\ax",
            item, itemID, rule, classes, link, corpse)
    end
    loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, modMessage)
    loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, modMessage)
end

local showSettings = false

function loot.renderMainUI()
    if loot.ShowUI then
        ImGui.SetNextWindowSize(800, 600, ImGuiCond.FirstUseEver)
        local open, show = ImGui.Begin('LootnScoot', true)
        if not open then
            show = false
            loot.ShowUI = false
        end
        if show then
            local sizeY = ImGui.GetWindowHeight() - 10
            if ImGui.BeginChild('Main', 0.0, 400, bit32.bor(ImGuiChildFlags.ResizeY, ImGuiChildFlags.Border)) then
                ImGui.PushStyleColor(ImGuiCol.PopupBg, ImVec4(0.002, 0.009, 0.082, 0.991))
                if ImGui.SmallButton(string.format("%s Report", Icons.MD_INSERT_CHART)) then
                    -- loot.guiLoot.showReport = not loot.guiLoot.showReport
                    loot.guiLoot.GetSettings(loot.Settings.HideNames, loot.Settings.LookupLinks, loot.Settings.RecordData, true, loot.Settings.UseActors, 'lootnscoot', true)
                    loot.Settings.ShowReport = loot.guiLoot.showReport
                    loot.TempSettings.NeedSave = true
                end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Show/Hide Report Window") end

                ImGui.SameLine()

                if ImGui.SmallButton(Icons.MD_HISTORY .. " Historical") then
                    loot.TempSettings.PastHistory = not loot.TempSettings.PastHistory
                end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Show/Hide Historical Data") end

                ImGui.SameLine()


                if ImGui.SmallButton(string.format("%s Console", Icons.FA_TERMINAL)) then
                    loot.guiLoot.openGUI = not loot.guiLoot.openGUI
                    loot.Settings.ShowConsole = loot.guiLoot.openGUI
                    loot.TempSettings.NeedSave = true
                end
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Show/Hide Console Window") end

                ImGui.SameLine()

                local labelBtn = not showSettings and
                    string.format("%s Settings", Icons.FA_COG) or string.format("%s   Items  ", Icons.FA_SHOPPING_BASKET)
                if showSettings and loot.NewItemsCount > 0 then
                    ImGui.PushStyleColor(ImGuiCol.Button, ImVec4(1.0, 0.4, 0.4, 0.4))
                    if ImGui.SmallButton(labelBtn) then
                        showSettings = not showSettings
                    end
                    ImGui.PopStyleColor()
                else
                    if ImGui.SmallButton(labelBtn) then
                        showSettings = not showSettings
                    end
                end


                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                -- Settings Section
                if showSettings then
                    if loot.TempSettings.SelectedActor == nil then
                        loot.TempSettings.SelectedActor = MyName
                    end
                    ImGui.Indent(2)
                    ImGui.TextWrapped("You can change any setting by issuing `/lootutils set settingname value` use [on|off] for true false values.")
                    ImGui.TextWrapped("You can also change settings for other characters by selecting them from the dropdown.")
                    ImGui.Unindent(2)
                    ImGui.Spacing()

                    ImGui.Separator()
                    ImGui.Spacing()
                    ImGui.SetNextItemWidth(180)
                    if ImGui.BeginCombo("Select Actor", loot.TempSettings.SelectedActor) then
                        for k, v in pairs(loot.Boxes) do
                            if ImGui.Selectable(k, loot.TempSettings.SelectedActor == k) then
                                loot.TempSettings.SelectedActor = k
                            end
                        end
                        ImGui.EndCombo()
                    end
                    loot.renderSettingsSection(loot.TempSettings.SelectedActor)
                else
                    -- Items and Rules Section
                    loot.drawItemsTables()
                end
                ImGui.PopStyleColor()
            end
            ImGui.EndChild()
        end

        ImGui.End()
    end
end

function loot.informProcessing()
    loot.lootActor:send({ mailbox = 'loot_module', script = loot.DirectorScript, }, { Subject = "processing", Who = MyName, })
end

function loot.doneProcessing()
    loot.lootActor:send({ mailbox = 'loot_module', script = loot.DirectorScript, }, { Subject = "done_processing", Who = MyName, })
end

function loot.processArgs(args)
    loot.Terminate = true
    local directorRunning = mq.TLO.Lua.Script(loot.DirectorScript).Status() == 'RUNNING' or false
    if args == nil then return end
    if args[1] == 'directed' and args[2] ~= nil then
        if loot.guiLoot ~= nil then
            loot.guiLoot.GetSettings(loot.Settings.HideNames, loot.Settings.LookupLinks, loot.Settings.RecordData, true, loot.Settings.UseActors, 'lootnscoot', false)
        end
        loot.DirectorScript = args[2]
        Mode = 'directed'
        loot.Terminate = false
        loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, { action = 'Hello', Server = eqServer, who = MyName, })
        loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, { action = 'Hello', Server = eqServer, who = MyName, })
    elseif args[1] == 'sellstuff' then
        loot.processItems('Sell')
    elseif args[1] == 'tributestuff' then
        loot.processItems('Tribute')
    elseif args[1] == 'cleanup' then
        loot.processItems('Destroy')
    elseif args[1] == 'once' then
        loot.lootMobs()
    elseif args[1] == 'standalone' then
        if loot.guiLoot ~= nil then
            loot.guiLoot.GetSettings(loot.Settings.HideNames, loot.Settings.LookupLinks, loot.Settings.RecordData, true, loot.Settings.UseActors, 'lootnscoot', false)
        end
        Mode = 'standalone'
        loot.Terminate = false
        loot.lootActor:send({ mailbox = 'lootnscoot', script = 'rgmercs/lib/lootnscoot', }, { action = 'Hello', Server = eqServer, who = MyName, })
        loot.lootActor:send({ mailbox = 'lootnscoot', script = 'lootnscoot', }, { action = 'Hello', Server = eqServer, who = MyName, })
    end
end

function loot.init(args)
    local needsSave = false
    if Mode ~= 'once' then
        loot.Terminate = false
    end
    needsSave = loot.loadSettings(true)
    loot.SortTables()
    loot.RegisterActors()
    loot.CheckBags()
    loot.setupEvents()
    loot.setupBinds()
    zoneID = mq.TLO.Zone.ID()
    Logger.Debug(loot.guiLoot.console, "Loot::init() \aoSaveRequired: \at%s", needsSave and "TRUE" or "FALSE")
    loot.processArgs(args)
    loot.sendMySettings()
    mq.imgui.init('LootnScoot', loot.RenderUIs)
    loot.guiLoot.GetSettings(loot.Settings.HideNames, loot.Settings.LookupLinks, loot.Settings.RecordData, true, loot.UseActors, 'lootnscoot', loot.Settings.ShowReport)

    if needsSave then loot.writeSettings() end
    return needsSave
end

if loot.guiLoot ~= nil then
    loot.guiLoot.GetSettings(loot.Settings.HideNames, loot.Settings.LookupLinks, loot.Settings.RecordData, true, loot.Settings.UseActors, 'lootnscoot', loot.Settings.ShowReport)
    loot.guiLoot.init(true, true, 'lootnscoot')
    loot.guiExport()
end

loot.init({ ..., })

while not loot.Terminate do
    local directorRunning = mq.TLO.Lua.Script(loot.DirectorScript).Status() == 'RUNNING' or false
    if not directorRunning and Mode == 'directed' then
        loot.Terminate = true
    end
    if mq.TLO.MacroQuest.GameState() ~= "INGAME" then loot.Terminate = true end -- exit sctipt if at char select.


    if debugPrint then
        Logger.loglevel = 'debug'
    elseif not loot.Settings.ShowInfoMessages then
        Logger.loglevel = 'warn'
    else
        Logger.loglevel = 'info'
    end

    if loot.Settings.DoLoot and Mode ~= 'directed' then loot.lootMobs() end
    if loot.LootNow then
        loot.LootNow = false
        loot.lootMobs()
    end
    if doSell then
        loot.processItems('Sell')
        doSell = false
    end
    if doBuy then
        loot.processItems('Buy')
        doBuy = false
    end
    if doTribute then
        loot.processItems('Tribute')
        doTribute = false
    end

    if loot.TempSettings.doBulkSet then
        local doDelete = false
        if loot.TempSettings.bulkDelete then
            doDelete = true
        end
        loot.bulkSet(loot.TempSettings.BulkSet, loot.TempSettings.BulkRule, loot.TempSettings.BulkClasses, loot.TempSettings.BulkSetTable, doDelete)
        loot.TempSettings.doBulkSet = false
        loot.TempSettings.bulkDelete = true
    end

    if loot.guiLoot ~= nil then
        if loot.guiLoot.SendHistory then
            loot.LoadHistoricalData()
            loot.guiLoot.SendHistory = false
        end
        if loot.guiLoot.showReport ~= loot.Settings.ShowReport then
            loot.Settings.ShowReport = loot.guiLoot.showReport
            loot.TempSettings.NeedSave = true
        end
        if loot.guiLoot.openGUI ~= loot.Settings.ShowConsole then
            loot.Settings.ShowConsole = loot.guiLoot.openGUI
            loot.TempSettings.NeedSave = true
        end
        loot.TempSettings.SessionHistory = loot.guiLoot.SessionLootRecord or {}
    end

    mq.doevents()

    if loot.TempSettings.ClearDateData then
        loot.TempSettings.ClearDateData = false
        loot.HistoryDataDate = {}
    end

    if loot.TempSettings.LookUpDateData then
        loot.TempSettings.LookUpDateData = false
        loot.LoadDateHistory(lookupDate)
    end

    if loot.TempSettings.NeedSave then
        loot.writeSettings()
        loot.TempSettings.NeedSave = false
        loot.sendMySettings()
    end

    if loot.TempSettings.LookUpItem then
        if loot.TempSettings.SearchItems ~= nil and loot.TempSettings.SearchItems ~= "" then
            loot.GetItemFromDB(loot.TempSettings.SearchItems, 0)
        end
        loot.TempSettings.LookUpItem = false
    end

    loot.NewItemsCount = loot.NewItemsCount <= 0 and 0 or loot.NewItemsCount

    if loot.NewItemsCount == 0 then
        showNewItem = false
    end

    if loot.TempSettings.NeedsCleanup then
        loot.TempSettings.NeedsCleanup = false
        loot.processItems('Destroy')
    end

    if loot.MyClass:lower() == 'brd' and loot.Settings.DoDestroy then
        loot.Settings.DoDestroy = false
        Logger.Warn(loot.guiLoot.console, "\ayBard Detected\ax, \arDisabling\ax [\atDoDestroy\ax].")
    end
    mq.delay(5)
end

if loot.Terminate then
    mq.unbind("/lootutils")
    mq.unbind("/lns")
    mq.unbind("/looted")
end
return loot
