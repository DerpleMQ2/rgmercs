# Loot N Scoot

This is a port of the RedGuides copy of `ninjadvloot.inc` with some updates as well.  

I may have glossed over some of the events or edge cases so it may have some issues around things like:  
- lore items  
- full inventory  
- not full inventory but no slot large enough for an item  
- ...  

Or those things might just work, I just haven't tested it very much using lvl 1 toons on project lazarus.  

This script can be used in two ways:  

1. Included within a larger script using require, for example if you have some KissAssist-like lua script:

To loot mobs, call `lootutils.lootMobs()`:  

```
local mq = require 'mq'
local lootutils = require 'lootnscoot'
while true do
    lootutils.lootMobs()
    mq.delay(1000)
end
```

`lootUtils.lootMobs()` will run until it has attempted to loot all corpses within the defined radius.  

To sell to a vendor, call `lootutils.sellStuff()`:  

```
local mq = require 'mq'
local lootutils = require 'lootutils'
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
```

`lootutils.sellStuff()` will run until it has attempted to sell all items marked as sell to the targeted vendor.  

Note that in the above example, loot.sellStuff() isn't being called directly from the bind callback.  
Selling may take some time and includes delays, so it is best to be called from your main loop.  

Optionally, configure settings using:  

* Set the radius within which corpses should be looted (radius from you, not a camp location)  
    `lootutils.CorpseRadius = number`  
* Set whether loot.ini should be updated based off of sell item events to add manually sold items.  
    `lootutils.AddNewSales = boolean`  
* Set your own instance of Write.lua to configure a different prefix, log level, etc.  
    `lootutils.logger = Write`
* Several other settings can be found in the "loot" table defined in the code.  

2. Run as a standalone script:  

* `/lua run lootutils standalone`  
    Will keep the script running, checking for corpses once per second.  
* `/lua run lootutils once`  
    Will run one iteration of loot.lootMobs().  
* `/lua run lootutils sell`  
    Will run one iteration of loot.sellStuff().  

The script will setup a bind for "/lootutils":  

* `/lootutils <action> "${Cursor.Name}"`  
    Set the loot rule for an item. "action" may be one of:  
        - Keep  
        - Bank  
        - Sell  
        - Ignore  
        - Destroy  
        - Quest|#  

* `/lootutils reload`  
    Reload the contents of `Loot.ini`  
* `/lootutils bank`  
    Put all items from inventory marked as Bank into the bank  
* `/lootutils tsbank`  
    Mark all tradeskill items in inventory as Bank  

If running in standalone mode, the bind also supports:  

* `/lootutils sell`  
    Runs lootutils.sellStuff() one time  

The following events are used:  

* eventCantLoot - `#*#may not loot this corpse#*#`  
    Add corpse to list of corpses to avoid for a few minutes if someone is already looting it.  
* eventSell - `#*#You receive#*# for the #1#(s)#*#`  
    Set item rule to Sell when an item is manually sold to a vendor  
* eventInventoryFull - `#*#Your inventory appears full!#*#`  
    Stop attempting to loot once inventory is full. Note that currently this never gets set back to false even if inventory space is made available.  
* eventNovalue - `#*#give you absolutely nothing for the #1#.#*#`  
    Warn and move on when attempting to sell an item which the merchant will not buy.  

This script depends on having <a href="https://gitlab.com/Knightly1/knightlinc/-/blob/master/Write.lua" target="_blank">Write.lua</a> in your `lua/lib` folder.  

This does not include the buy routines from ninjadvloot. It does include the sell routines but lootly sell routines seem more robust than the code that was in ninjadvloot.inc.  
The forage event handling also does not handle fishing events like ninjadvloot did.  
There is also no flag for combat looting. It will only loot if no mobs are within the radius.  
