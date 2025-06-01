# Loot N Scoot (Rewrite) ~ Now with more adv looting features.~

Because of the rewrite to fix some issues and add more advanced looting mechanics. There is a link to the old version on the Github Releases page.
https://github.com/aquietone/lootnscoot/releases/tag/Classic_Version

All configs, tables, etc are kept separate between the new version and the old. so you can swap back and forth if you so choose. 

### New Checks
- Check invis and don't loot if invis.

### Decision and Rules Logic
- Decision making happens for each item looted. and overrides some rules based on our settings. 
 - Items Marked as Sell will be checked to meet our settings thresholds before looting.
 - the same goes for items marked as Tribute
- New items that have a sell value will default to sell as the new rule, and similarly for tribute
- You will still see the new item popup and are more than welcome to change the rule. 
- NoDrop items we first see, default to `Ask` 
 - if LootNoDrop is enabled we will check against the `CanWear`  setting and it it is something we can wear we will keep otherwise ignore.
 - if `CanWear` is disabled we will just `Ask`

### New Mode
- Current modes of operation are 'once', 'standalone', and now 'directed'
  - Once is what happens when you call `/lua run lootnscoot` without any arguments or with arguments to sell,restock,tribute,bank etc.
  - Standalone is when the script is constantly running and doing its thing in the background `/lua run lootnscoot standalone`
  - Directed is where you call the script from another script `/lua run lootnscoot directed`
    - This mode will only loot when told over Actors or you directly issue the `/lns loot` command
    - If  you include the lootnscoot folder in your scripts folder you will want to make the path `yours_script_folder/lib/lootnscoot` and you would load from inside your script with `/lua run yourscript/lib/lootnscoot directed scriptname`
    - Check out the RGMercs Lua for an example of how to implement this.

### Items Table DB Changes
- The items DB will auto-add/update items as you and your party loot them.
- The items table has been changed to include more details about the items.
- Items are now keyed by the item ID:
  - Using item ID, we can now handle items where there are more than one with the same name but different stats/flags.
- The DB will also store link information so you can access loot information from the table with a right-click.
- a Default Items.db is avail [Here](https://github.com/grimmier378/emu_itemdb/releases) this has all of the items dumped from EQEMU server defaults. Custom servers will be missing any customized items. 
 - if your server has modified existing items you will get updated information in the db as you loot the item or import / add it. the links should still point to the correct itemID and show properly from the server either way.

### ADV Loot Rules DB
- A new rules DB accounts for using item IDs. Unfortunately, this invalidates the old rules table since we never had the ID data.
- NEW Rules Section (Personal Rules)
  - This is a per character set of rules for items.
  - These rules will override all other rule sets. 
  - Order of Authority `Personal > Global > Normal`

### Config and DB Locations
- **Config Files:**
  - Now reside in `mqfolder\config\LootNScoot\ServerName\` to keep things organized.
  - Changed the config file format to `.lua` for easier loading and saving.
- **DB Files:**
  - Reside in `mqfolder\resources\LootNScoot\ServerName\`.
  - Keeps data organized, especially if you play on multiple emulated servers, preventing overwrites.

### New Loot Pop-up / Tab
- Displays information so you can decide on rules for items looted without existing rules in the DB:
  - Item name, sell price, stack size, nodrop, lore, augment, tradeskill.
- On the first loot, the decision is based on your settings, with options to change them.
- **Optional Features:**
  - A pop-up window showing undecided items for the session.
  - A new "Items" tab in the loot window.
- **Additional Functionality:**
  - A button with an eye icon opens the inspect window for item stats.

### Item Lookup Tab
- Look up any item from your DB:
  - Shows items you have rules for or previously looked up.
  - With a fully exported DB from EQEmulator, over 117k items are available (before custom items).
- **Interactions:**
  - Right-clicking an item opens the inspect window.
  - Left-clicking an item opens the ModifyItem Rule Window to add a rule for the item.
- **Customizations:**
  - Right-clicking table headers allows toggling fields and rearranging their order.
  - Drag-and-drop items to add them to the table if missing.

### Bulk Set Item Rules
 - You can set the entire page worth of items to the same rule with the bulk set option. 
 - This will do only the items that are on the current page of your search results. 
 - You can adjust the number of items displayed in Increments of 10 
 - Added option to bulk delete rules from the current table
 - Added checkboxes to the items tables, you can select items from multiple pages. 

### Rules Tables
- **Searchable:** Filter by item name or rule type (e.g., Quest, Bank).
- **Right-click Interactions:** Opens the inspect window in-game.
- **Stored Links:** Includes links in case the items DB is deleted or rules DB is copied from another server.
- **Edit Item Button:**
  - **Green Button with Pencil:** Indicates the item exists in the main items DB.
  - **Red Button with X:** Indicates the item is missing from the Items DB but has a rule.
  - Clicking the button opens the ModifyItem Rule Window.

### Import Items
- Import items from your character's inventory/bank with `/rgl importinv`:
  - Bank data may not be fresh but refreshes when zoning or at the bank.
  - Useful for starting with an empty DB or migrating to a new server.

### Loot Settings
- **Loot Corpse Once:** Tracks looted corpses to avoid re-looting.
  - Unlocks the corpse if a new item rule is changed (e.g., from "Ignore" to another flag).
- **Can Use Only Flag:**
  - Loots only items you can use/wear flagged as "KEEP," either via rules or evaluations.
  - Ignores "Sell," "Bank," "Quest," etc., flags unless explicitly allowed.
  - Helpful with `lootnodrop` and `lootnodropnew` enabled.
- **KeepSpells:** Keeps all spell drops regardless of rules or sell values.
- Actors Settings:
 - You can edit any characters settings from the window, clicking save will send them the new settings and they will save them.
 - You can clone a characters settings from one char to another. making setting up new groups easier.
- Added `IgnoreBagSlot` setting. setting this will ignore anything in that slot\bag when it comes to selling\tributeing\banking\cleanup.
- AlwaysGlobal: (default off)
 - This will also make a global rule for new items when looting and when acknowledging the new item rules. 

### COMMANDS
- `/lns` or `/lootutils`
- Arguments
  - `sellstuff`         sell to targeted merchant
  - `restock`           restock items from targeted merchant (must be in buy table)
  - `tributestuff`      tribute items to the targeted merchant
  - `bank`              bank items to targeted banker
  - `show`              shows loot gui
  - `report`            shows report table 
  - `shownew`           shows the new item table
  - `set settingname value` example /lns set doquest on will till looting quest items on  or /lns set minsellprice 1 will set minsellprice to 1
  - `cleanup`           clean up bags or items marked 'Destroy'
  - `importinv`         imports your inventory and bank (if avail) items into the main items database
  - `pause`             pauses looting
  - `resume`            unpauses looting
  - `debug`             enable debug spam in loot console.

### NO DROP
- if `lootnodrop` is enabled you will loot items marked nodrop that you have rules for
- if `lootnodropnew` is enabled you will also loot new items that are nodrop
- regardless of these settings a new item with no rules that is nodrop will have the rule set to CanUse to prevent the first person deciding its ignore.

### UI
- New Graphical toggle button
  - Shows as a Plat Coin or a Gold Coin when there are new rules to confirm
  - Left Click will toggle the main LootNScoot window, you can also `/lns show`
  - Right Click will open the New Items window (if there are any new items to confirm) or you can also `/lns shownew`
- Main LootNScoot Window
  - This is where you will find buttons to open the console, loot report table. 
  - You will also find the settings and Item rules and lookup tables here. 
- Historical Data Window
 - You can view recoded Historical Data from in game and search using most of the fields.

## Bank Tradeskill Changes
the bank tradeskills flag will no longer auto flag items to bank

Instead it will be checked when issuing the bank command.

When banking:
check rules and if its 'Bank' toss it into the bank
if the rule is not Global or Personal then check if the item is a TS item, and if we have Bank TS enabled.
if both are true then bank it.

this way we don't have rules flip flopping from this setting. and it still serves a purpose for items without overrides in global or personal rules tables.

MEDIA

![image](https://github.com/user-attachments/assets/db9acb46-82ce-4c60-b76c-ee461785f619)

![Screenshot 2025-01-24 012020](https://github.com/user-attachments/assets/d313e977-196f-4952-bb37-3823f58404e3)

![Screenshot 2025-01-24 012123](https://github.com/user-attachments/assets/a37f7d26-ab3a-48fb-af66-db23b0852cc6)

![Screenshot 2025-01-24 012151](https://github.com/user-attachments/assets/782ba0a0-b58a-4bd1-9089-a610765c79ba)

![Screenshot 2025-01-24 012212](https://github.com/user-attachments/assets/7b58534f-e234-4f6e-897f-892045dbeafa)

![Screenshot 2025-01-24 021107](https://github.com/user-attachments/assets/7521f1ed-ffa5-4c8a-990d-a5cc4b7606a0)

[VIDEO PREVIEW](https://youtu.be/evhK7QYadxg)

[VIDEO PREVIEW4](https://www.youtube.com/watch?v=k3nETo_JStE)

[VIDEO PREVIEW5](https://youtu.be/_ebgzWZs33w)
