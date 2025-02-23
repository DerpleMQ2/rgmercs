-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

-- [ NOTE ON ORDERING ] --
-- Order matters! Lua will implicitly iterate everything in an array
-- in order by default so always put the first thing you want checked
-- towards the top of the list.

local mq        = require('mq')
local Config    = require('utils.config')
local Core      = require("utils.core")
local Modules   = require("utils.modules")
local Targeting = require("utils.targeting")
local Movement  = require("utils.movement")
local Casting   = require("utils.casting")
local Strings   = require("utils.strings")
local Logger    = require("utils.logger")

local Tooltips  = {
    ArrowOpener         = "Spell Line: Archery Attack with High Crit Chance when not in Combat. Consumes a 50 range CLASS 3 Wood Silver Tip Arrow when cast.",
    PullOpener          = "Spell Line: Archery Attack when not in Combat. Consumes a 50 range CLASS 3 Wood Silver Tip Arrow when cast.",
    CalledShotsArrow    = "Spell Line: Quad Archery Attack + Increase Archery Dmg Against Target",
    FocusedArrows       = "Spell Line: Quad Archery Attack",
    DichoSpell          = "Spell Line: Cast best Summer's Cyclone + Double Massive Archery Attack + Lower Hatred",
    SummerNuke          = "Spell Line: Fire Nuke + Cold Nuke + Increase Hatred",
    SwarmDot            = "Spell Line: Magic DoT",
    ShortSwarmDot       = "Spell Line: Prismatic DoT + ToT Damage Shield",
    UnityBuff           = "AA: Casts Highest Level of Scribed Buffs (ParryProcBuff, Hunt, Protectionbuff, Eyes)",
    Protectionbuff      = "Spell Line: Increase AC + Self Damage Shield",
    ShoutBuff           = "Spell Line: Increase Attack and Double Attack Chance",
    AgroBuff            = "Spell Line: Harms Target HP and Hatred Increase",
    AgroReducerBuff     = "Spell Line: Hatred Decrease Proc",
    AggroKick           = "Spell Line: Two Kicks w/ Increased Accuracy that Increase Hatred",
    ParryProcBuff       = "Spell Line: Magic Nuke w/ Parry Chance Proc",
    Eyes                = "Spell Line: Increase Chance to Hit with Archery",
    GroupStrengthBuff   = "Spell Line: Increase Group's Attack",
    GroupPredatorBuff   = "Spell Line: Increase Group's Attack",
    GroupEnrichmentBuff = "Spell Line: Increase Group's Base Damage",
    Rathe               = "Spell Line: Increase AC + Damage Shield",
    BowDisc             = "Discipline: Increase Archery Skill Check and Damage Modifier",
    MeleeDisc           = "Discipline: Add Melee Damage DoT Proc",
    DefenseDisc         = "Discpline: Parry Chance 100%",
    Fireboon            = "Spell Line: Fire Nuke + Additional Damage w/ Fire Spells",
    Firenuke            = "Spell Line: Fire Nuke",
    Iceboon             = "Spell Line: Cold Nuke + Additional Damage w/ Cold Spells",
    Icenuke             = "Spell Line: Cold Nuke",
    Heartshot           = "Spell Line: Archery Attack. Consumes a 50 range CLASS 3 Wood Silver Tip Arrow when cast.",
    EndRegenDisc        = "Discipline: Endurance Regen + Self Slow",
    Coat                = "Spell Line: Increase AC + Self Damage Shield",
    Mask                = "Spell Line: Increase Magnification + Mana Regen + See Invis",
    Hunt                = "Spell Line: Add Crit Chance and Accuracy Buff Proc on Killshot",
    Heal                = "Spell Line: Heal",
    Fastheal            = "Spell Line: Fast Cast Heal",
    Totheal             = "Spell Line: Heals Target of Target if Used on an Enemy",
    RegenSpells         = "Spell Line: Increase Regeneration",
    SnareSpells         = "Spell Line: Decrease Enemy Movement Speed",
    FireFist            = "Spell Line: Self Increase Attack",
    DsBuff              = "Spell Line: Damage Shield",
    SkinLike            = "Spell Line: Increase AC + Increase Max HP",
    MoveSpells          = "Spell Line: Increase Movement Speed",
    Alliance            = "Spell Line: Alliance (Requires Multiple of Same Class). Adds Fire Damage to other Ranger Spells and triggers a massive Fire and Cold Nuke",
    AgiBuff             = "Spell Line: Increase Agility",
    Cloak               = "Spell Line: Melee Absorb Proc + ATK/AC/Fire Resist Debuff",
    Veil                = "Spell Line: Add Parry Proc",
    JoltingKicks        = "Spell Line: Two Kicks w/ Increased Accuracy that Decrease Hatred",
    AEBlades            = "Spell Line: Quad Attack against up to 8 targets in Front of You",
    FocusedBlades       = "Spell Line: Quad Attack w/ Increased Accuracy",
    ReflexSlashHeal     = "Spell Line: Quad Attack w/ Increase Accuracy + Group HoT",
    AEArrows            = "Spell Line: Quad Archery Attack w/ Increased Accuracy against up to 8 targets in Front of You",
    Entrap              = "AA: Snare",
    Kick                = "Use Kick Ability",
    Taunt               = "Use Taunt Ability",
    Epic                = 'Item: Casts Epic Weapon Ability',
    GotF                = "AA: Wolf Form + v3 Haste + Regen + Attack + Increase Skill Damage",
    GGotF               = "AA: Group Wolf Form + v3 Haste + Regen + Attack + Increase Skill Damage",
    OA                  = "AA: Increase Melee Damage + Accuracy + Attack + Crit Chance + Minimum Damage + Minimum Base Damage",
    EA                  = "AA: Increase Fire and Cold Spell Damage against Target",
    AotH                = "AA: Increase Skill, Spell, and Heal Crit Chance + Accuracy + Attack",
    OE                  = "AA: Decrease Melee Damage + Increase Chance to Avoid Melee + Increase Movement Speed",
    PackHunt            = "AA: Summons a pack of wolves",
    PoisonArrow         = "AA: Adds Archery proc that consumes mana to deal high damage",
    FlamingArrow        = "AA: Adds Archery proc that consumes mana to deal high damage",
    PotSW               = "AA: Mitigate Melee and Spell Damage + Increase Magic Resistance",
    CG                  = "AA: Decrease Hatred and Hatred Generation when HP drops below 50%",
    SS                  = "AA: Reduce Hatred Generation",
    IF                  = "AA: Melee Proc Chance 100% + Decrease Hatred Generation",
    BotB                = "AA: Decrease Hatred + Decrease Hatred Proc when hit in Melee + 100% Parry Chance when below 50% HP",
    EB                  = "AA: Increase 1H Attack Damage + Increase 2H Minimum Attack Damage",
    SCF                 = "AA: Group Buff that drains Mana or Endurance and Twin Casts Spells or Abilities Depending on Class",
    SotP                = "AA: Increase Max HP and Dex Cap + Decreased Hatred Generation + Increased Melee Proc Chance + Increased Melee Minimum Damage",
    EoN                 = "AA: High Chance to Dispel Your Target",
    RangedMode          = "Skill: Use /autofire instead of using Melee",
}

-- helper function for advanced logic to see if we want to use Windstalker's Unity
local function castWSU()
    local unityAction = Modules:ExecModule("Class", "GetResolvedActionMapItem", "Protectionbuff")
    if not unityAction then return false end

    local res = unityAction.Level() <=
        (mq.TLO.Me.AltAbility("Wildstalker's Unity (Azia)").Spell.Level() or 0) and
        mq.TLO.Me.AltAbility("Wildstalker's Unity (Azia)").MinLevel() <= mq.TLO.Me.Level() and
        mq.TLO.Me.AltAbility("Wildstalker's Unity (Azia)").Rank() > 0

    return res
end

local _ClassConfig = {
    _version              = "1.0 - Project Lazarus",
    _author               = "MrInfernal",
    ['CommandHandlers']   = {
        makeammo = {
            usage = "/rgl makeammo ##",
            about = "Make ## number of Class 3 Wood Silver Tip Arrows. Minimum of 5",
            handler =
                function(self, amount)
                    local packSlots = {
                        { slot = 23, name = 'pack1', }, { slot = 24, name = 'pack2', }, { slot = 25, name = 'pack3', }, { slot = 26, name = 'pack4', },
                        { slot = 27, name = 'pack5', }, { slot = 28, name = 'pack6', }, { slot = 29, name = 'pack7', }, { slot = 30, name = 'pack8', },
                    }
                    local delay = 5
                    local matTable = { 'Several Shield Cut Fletchings', 'Small Groove Nocks', 'Bundled Wooden Arrow Shafts', 'Silver Tipped Arrowheads', }
                    local kitSlot = ''

                    -- How many bundles to make. Dividing as each combine makes 5 arrows
                    if amount == nil then
                        amount = 5
                    end
                    local toMake = tonumber(amount) / 5

                    --Check for and open fletching kit in inventory
                    local kitsToFind = { 'Fletching Kit', 'Planar Fletching Kit', 'Collapsible Fletching Kit', 'Surefall Fletching Kit', }
                    local fletchKit = ''

                    -- Iterates through top level inventory
                    -- If a bag matches a medicine bag, it's set to medBag
                    -- Also stores the inventory slot in bagSlot
                    for packIndex = 23, 32 do
                        local packNum = mq.TLO.Me.Inventory(packIndex).Name()

                        -- Check if packNum's name is in the list of bags to find
                        if table.concat(kitsToFind, ","):find(packNum) then
                            for _, packInfo in ipairs(packSlots) do
                                if packInfo.slot == packIndex then
                                    fletchKit = packNum
                                    kitSlot = packInfo.name
                                    break
                                end
                            end
                        end
                    end

                    -- Ensure a kit was found then open it and enter Experimentation mode
                    -- To Do: Find a way to see if container is open
                    if fletchKit ~= '' then
                        Core.DoCmd('/timed %d /itemnotify "%s" rightmouseup', delay, fletchKit)
                        delay = delay + 5
                        Core.DoCmd('/timed %d /notify TradeskillWnd COMBW_ExperimentButton leftmouseup', delay)
                        delay = delay + 5
                    end

                    -- j is how many bundles to make (toMake)
                    -- Iterates through matTable to place one of each item in the fletching kit
                    -- When all are added, hits Combine and autoinventories the item
                    for j = 1, toMake do
                        for i = 1, toMake do
                            local matName = matTable[i]

                            Core.DoCmd('/timed %d /nomodkey /ctrl /itemnotify "%s" leftmouseup', delay, matName)
                            delay = delay + 5
                            Core.DoCmd('/timed %d /itemnotify in %s %d leftmouseup', delay, kitSlot, i)
                            delay = delay + 5
                            if i == #matTable then
                                Core.DoCmd('/timed %d /combine %s', delay, kitSlot)
                                delay = delay + 7
                                Core.DoCmd('/timed %d /autoinventory', delay)
                                delay = delay + 5
                                Core.DoCmd('/timed %d /echo Combine #%d', delay, j)
                                delay = delay + 13
                            end
                        end
                    end

                    return true
                end,
        },
    },
    ['ModeChecks']        = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
        IsHealing = function() return Core.IsModeActive("Healer") or Core.IsModeActive("Hybrid") end,
    },
    ['Modes']             = {
        'DPS',
        'Tank',
        'Healer',
        'Hybrid',
    },
    ['Themes']            = {
        ['Tank'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabActive,        color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.5, g = 0.05, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.3, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.2, g = 0.05, b = 0.05, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.0, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.0, g = 0.05, b = 0.05, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
        },
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.5, g = 0.05, b = 1.0, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.4, g = 0.05, b = 0.8, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.TabActive,        color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.1, g = 0.05, b = 0.5, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.2, g = 0.05, b = 0.6, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.1, g = 0.05, b = 0.5, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.1, g = 0.05, b = 0.5, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.1, g = 0.05, b = 0.5, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.5, g = 0.05, b = 1.0, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.5, g = 0.05, b = 1.0, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
        },
        ['Healer'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.05, g = 0.2, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabActive,        color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.05, g = 0.5, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.05, g = 0.2, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.05, g = 0.5, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.05, g = 0.5, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.05, g = 0.3, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.05, g = 0.5, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.05, g = 0.5, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.05, g = 0.2, b = 0.05, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.05, g = 0.2, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.05, g = 1.0, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.05, g = 1.0, b = 0.05, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.05, g = 0.5, b = 0.05, a = 1.0, }, },
        },
        ['Hybrid'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.275, g = 0.275, b = 0.525, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.225, g = 0.275, b = 0.425, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.125, g = 0.125, b = 0.325, a = .8, }, },
            { element = ImGuiCol.TabActive,        color = { r = 0.125, g = 0.275, b = 0.325, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.125, g = 0.275, b = 0.325, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.075, g = 0.075, b = 0.275, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.125, g = 0.275, b = 0.325, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.125, g = 0.275, b = 0.325, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.125, g = 0.275, b = 0.325, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.075, g = 0.2, b = 0.275, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.125, g = 0.275, b = 0.325, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.125, g = 0.275, b = 0.325, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.075, g = 0.075, b = 0.275, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.075, g = 0.075, b = 0.275, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.275, g = 0.525, b = 0.525, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.275, g = 0.525, b = 0.525, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.125, g = 0.275, b = 0.325, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Heartwood Blade",
            "Aurora, the Heartwood Blade",
        },
    },
    ['AbilitySets']       = {
        ["ArrowOpener"] = {
            "Stealthy Shot",
            "Silent Shot",
        },
        ["PullOpener"] = {
            "Deadfall",
            "Heartpierce",
            "Heartrend",
            "Heartrip",
            "Heartspike",
        },
        ["CalledShotsArrow"] = {
            "Called Shots",
            "Announced Shots",
            "Forecasted Shots",
            "Anticipated Shots",
            "Foreseen Shots",
            "Marked Shots",
            "Claimed Shots",
            "Inevitable Shots",
        },
        ["FocusedArrows"] = {
            "Focused Frenzy of Arrows",
            "Focused Storm of Arrows",
            "Focused Tempest of Arrows",
            "Focused Arrow Swarm",
            "Focused Rain of Arrows",
            "Focused Arrowrain",
            "Focused Arrowgale",
            "Focused Blizzard of Arrows",
            "Focused Whirlwind of Arrows",
        },
        ["DichoSpell"] = {
            "Dichotomic Fusillade",
            "Dissident Fusillade",
            "Composite Fusillade",
            "Ecliptic Fusillade",
        },
        ["SummerNuke"] = {
            "Summer's Deluge",
            "Summer's Torrent",
            "Summer's Viridity",
            "Summer's Mist",
            "Summer's Storm",
            "Summer's Squall",
            "Summer's Gale",
            "Summer's Cyclone",
            "Summer's Tempest",
            "Summer's Sleet",
        },
        ["SwarmDot"] = {
            "Stinging Swarm",
            "Swarm of Pain",
            "Drones of Doom",
            "Fire Swarm",
            "Drifting Death",
            "Locust Swarm",
            "Wasp Swarm",
            "Hornet Swarm",
            "Beetle Swarm",
            "Scarab Swarm",
            "Vespid Swarm",
            "Dreadbeetle Swarm",
            "Blisterbeetle Swarm",
            "Bonecrawler Swarm",
            "Ice Burrower Swarm",
            "Bloodbeetle Swarm",
            "Hotaria Swarm",
        },
        ["ShortSwarmDot"] = {
            "Swarm of Fernflies",
            "Swarm of Bloodflies",
            "Swarm of Hyperboreads",
            "Swarm of Glistenwings",
            "Swarm of Vespines",
            "Swarm of Sand Wasps",
            "Swarm of Hornets",
            "Swarm of Bees",
        },
        ["UnityBuff"] = {
            "Bosquetender's Unity",
            "Copsestalker's Unity",
            "Wildstalker's Unity",
        },
        ["Protectionbuff"] = {
            "Force of Nature",
            "Warder's Protection",
            "Protection of the Wild",
            "Protection of the Minohten",
            "Protection of the Kirkoten",
            "Protection of the Paw",
            "Protection of the Vale",
            "Protection of the Copse",
            "Protection of the Bosque",
            "Protection of the Forest",
            "Protection of the Woodlands",
            "Protection of the Wakening Land",
            "Protection of the Valley",
        },
        ["ShoutBuff"] = {
            "Shout of the Predator",
            "Shout of the Bosquestalker",
            "Shout of the Copsestalker",
            "Shout of the Wildstalker",
            "Shout of the Arbor Stalker",
            "Shout of the Dusksage Stalker",
        },
        ["AgroBuff"] = {
            "Devastating Blades",
            "Devastating Edges",
            "Devastating Slashes",
            "Devastating Impact",
            "Devastating Swords",
            "Devastating Steel",
            "Devastating Velium",
            "Devastating Barrage",
        },
        ["AgroReducerBuff"] = {
            "Jolting Blades",
            "Jolting Strikes",
            "Jolting Swings",
            "Jolting Edges",
            "Jolting Impact",
            "Jolting Shock",
            "Jolting Swords",
            "Jolting Steel",
            "Jolting Velium",
            "Jolting Luclinite",
        },
        ["AggroKick"] = {
            "Enraging Roundhouse Kicks",
            "Enraging Axe Kicks",
            "Enraging Wheel Kicks",
            "Enraging Cut Kicks",
            "Enraging Heel Kicks",
            "Enraging Crescent Kicks",
        },
        ["ParryProcBuff"] = {
            "Thundering Blades",
            "Crackling Blades",
            "Crackling Edges",
            "Deafening Edges",
            "Deafening Weapons",
            "Roaring Weapons",
            "Roaring Blades",
            "Howling Blades",
            "Vociferous Blades",
        },
        ["Eyes"] = {
            "Hawk Eye",
            "Falcon Eye",
            "Eagle Eye",
            "Eyes of the Owl",
            "Eyes of the Peregrine",
            "Eyes of the Nocturnal",
            "Eyes of the Wolf",
            "Eyes of the Raptor",
            "Eyes of the Howler",
            "Eyes of the Harrier",
            "Eyes of the Sabertooth",
            "Eyes of the Visionary",
            "Eyes of the Senshali",
            "Eyes of the Phoenix",
        },
        ["GroupStrengthBuff"] = {
            "Nature's Precision",
            "Strength of Nature",
            "Strength of Tunare",
            "Strength of the Hunter",
            "Strength of the Forest Stalker",
            "Strength of the Gladewalker",
            "Strength of the Tracker",
            "Strength of the Thicket Stalker",
            "Strength of the Gladetender",
            "Strength of the Bosquestalker",
            "Strength of the Copsestalker",
            "Strength of the Wildstalker",
            "Strength of the Arbor Stalker",
            "Shout of the Dusksage Stalker",
            "Shout of the Fernstalker",
        },
        ["GroupPredatorBuff"] = {
            "Mark of the Predator",
            "Call of the Predator",
            "Spirit of the Predator",
            "Howl of the Predator",
            "Snarl of the Predator",
            "Gnarl of the Predator",
            "Yowl of the Predator",
            "Roar of the Predator",
            "Cry of the Predator",
            "Shout of the Predator",
            "Shout of the Bosquestalker",
            "Bellow of the Predator",
            "Wail of the Predator",
            "Frostroar of the Predator",
            "Shout of the Dusksage Stalker",
            "Shout of the Fernstalker",
        },
        ["GroupEnrichmentBuff"] = {
            "Arbor Stalker's Enrichment",
            "Copsestalker's Enrichment",
            "Wildstalker's Enrichment",
        },
        ["Rathe"] = {
            "Cloak of Needlespikes",
            "Cloak of Bloodbarbs",
            "Cloak of Rimespurs",
            "Cloak of Needlebarbs",
            "Cloak of Nettlespears",
            "Cloak of Spurs",
            "Cloak of Burrs",
            "Cloak of Quills",
            "Cloak of Feathers",
            "Cloak of Scales",
            "Guard of the Earth",
            "Call of the Rathe",
            "Call of Earth",
            "Riftwind's Protection",
        },
        ["BowDisc"] = {
            "Trueshot Discipline",
            "Aimshot Discipline",
            "Sureshot Discipline",
            "Pureshot Discipline",
        },
        ["MeleeDisc"] = {
            "Fernstalker's Discipline",
            "Dusksage Stalker's Discipline",
            "Bosquestalker's Discipline",
            "Copsestalker's Discipline",
            "Wildstalker's Discipline",
            "Arbor Stalker's Discipline",
        },
        ["DefenseDisc"] = {
            "Weapon Shield Discipline",
        },
        ["Fireboon"] = {
            "Fernflash Boon",
            "Lunarflare Boon",
            "Pyroclastic Boon",
            "Skyfire Boon",
            "Wildfire Boon",
            "Ashcloud Boon",
        },
        ["FireboonBuff"] = {
            "Fernflash Burn",
            "Lunarflare Burn",
            "Pyroclastic Burn",
            "Skyfire Burn",
            "Wildfire Burn",
            "Ashcloud Burn",
        },
        ["Firenuke"] = {
            "Flame Lick",
            "Burst of Fire",
            "Ignite",
            "Flaming Arrow",
            "Burning Arrow",
            "Call of Flame",
            "FireStrike",
            "Brushfire",
            "Sylvan Burn",
            "Ancient: Burning Chaos",
            "Hearth Embers",
            "Scorched Earth",
            "Volcanic Ash",
            "Galvanic Ash",
            "Cataclysm Ash",
            "Burning Ash",
            "Beastwood Ash",
            "Vileoak Ash",
            "Wildfire Ash",
            "Skyfire Ash",
            "Pyroclastic Ash",
            "Lunarflare Ash",
        },
        ["Iceboon"] = {
            "Frostsquall Boon",
            "Nocturnal Boon",
            "Mistral Boon",
            "Windshear Boon",
            "Windgale Boon",
            "Windblast Boon",
        },
        ["IceboonBuff"] = {
            "Frostsquall Freeze",
            "Nocturnal Freeze",
            "Mistral Freeze",
            "Windshear Freeze",
            "Windgale Freeze",
            "Windblast Freeze",
        },
        ["Icenuke"] = {
            "Gelid Wind",
            "Coagulated Wind",
            "Restless Wind",
            "Frigid Wind",
            "Frozen Wind", -- lvl 102. Spell ID: 43478
            "Bitter Wind",
            "Biting Wind",
            "Windwhip Bite",
            "Rimefall Bite",
            "Icefall Chill",
            "Ancient North Wind",
            "Frost Wind",
            "Frozen Wind", -- lvl 63. Spell ID: 3418
            "Icewind",
        },
        ["Heartshot"] = {
            "Heartshot",
            "Heartsting",
            "Heartsting",
            "Heartslice",
            "Heartslash",
            "Heartsplit",
            "Heartcleave",
            "Heartsunder",
            "Heartruin",
        },
        ["EndRegenDisc"] = {
            "Second Wind",
            "Third Wind",
            "Fourth Wind",
            "Respite",
            "Reprieve",
            "Rest",
            "Breather",
            "Hiatus",
            "Relax",
            "Night's Calming",
            "Convalesce",
        },
        ["Coat"] = {
            "Thistlecoat",
            "Barbcoat",
            "Bramblecoat",
            "Spikecoat",
            "Thorncoat",
            "Bladecoat",
            "Briarcoat",
            "Spinecoat",
            "Quillcoat",
            "Burrcoat",
            "Spurcoat",
            "Nettlespear",
            "Needlebarb",
            "Rimespur",
            "Moonthorn",
            "Needlespike",
        },
        ["Mask"] = {
            "Mask of the Stalker",
        },
        ["Hunt"] = {
            "Engulfed by the Hunt",
            "Steeled by the Hunt",
            "Provoked by the Hunt",
            "Spurred by the Hunt",
            "Energized by the Hunt",
            "Inspired by the Hunt",
            "Galvanized by the Hunt",
            "Invigorated by the Hunt",
            "Consumed by the Hunt",
        },
        ["Heal"] = {
            "Elizerain Spring",
            "Darkflow Spring",
            "Meltwater Spring",
            "Wellspring",
            "Cloudfont",
            "Cloudburst",
            "Purespring",
            "Purefont",
            "Oceangreen Aquifer",
            "Dragonscale Aquifer",
            "Sunderock Springwater",
            "Sylvan Water",
            "Sylvan Light",
            "Chloroblast",
            "Greater Healing",
            "Light Healing",
            "Healing",
            "Minor Healing",
            "Salve",
        },
        ["Fastheal"] = { -- 30s recast. ToT
            "Desperate Quenching",
            "Desperate Geyser",
            "Desperate Meltwater",
            "Desperate Dewcloud",
            "Desperate Dousing",
            "Desperate Drenching",
            "Desperate Downpour",
            "Desperate Deluge", -- lvl 89
        },
        ["Totheal"] = {
            "Desperate Quenching",
            "Desperate Geyser",
            "Darkflow Spring",
            "Desperate Meltwater",
            "Meltwater Spring", -- lvl 111
        },
        ["RegenSpells"] = {
            "Fernstalker's Vigor",
            "Dusksage Stalker's Vigor",
            "Arbor Stalker's Vigor",
            "Wildstalker's Vigor",
            "Copsestalker's Vigor",
            "Bosquestalker's Vigor",
            "Gladewalker's Vigor",
            "Stalker's Vigor",
            "Hunter's Vigor",
            "Regrowth",
            "Chloroplast",
        },
        ["SnareSpells"] = {
            "Snare",
            "Tangling Weeds",
            "Ensnare",
            "Earthen Embrace",
            "Earthen Shackles",
        },
        ["FireFist"] = {
            "Nature's Precision",
            "Wolf Form",
            "Greater Wolf Form",
            "Feral Form",
            "Firefist",
        },
        ["DsBuff"] = {
            "Shield of Thistles",
            "Shield of Brambles",
            "Shield of Spikes",
            "Shield of Thorns",
            "Shield of Briar",
            "Shield of Needles",
            "Shield of Spurs",
            "Shield of DrySpines",
            "Shield of Nettlespikes",
            "Shield of Bramblespikes",
            "Shield of Nettlespines",
            "Shield of Nettlespears",
            "Shield of Needlebarbs",
            "Shield of Rimespurs",
            "Shield of Shadethorns",
            "Shield of Needlespikes",
        },
        ["SkinLike"] = {
            "Skin Like Wood",
            "Skin Like Rock",
            "Skin Like Steel",
            "Skin Like Diamond",
            "Skin Like Nature",
            "Natureskin",
        },
        ["MoveSpells"] = {
            "Spirit of Falcons",
            "Spirit of Eagle",
            "Pack Shrew",
            "Spirit of the Shrew",
            "Spirit of Wolf",
        },
        ["Alliance"] = {
            "Bosquestalker's Alliance",
            "Wildstalker's Covenant",
            "Arbor Stalker's Coalition",
            "Dusksage Stalker's Conjunction",
        },
        ["AgiBuff"] = {
            "Feet Like Cat",
        },
        ["Cloak"] = {
            "Shalowain's Crucible Cloak",
            "Luclin's Darkfire Cloak",
            "Outrider's Ever-Burning Cloak",
            "Lavastorm Cloak",
            "Ro's Burning Cloak",
        },
        ["Veil"] = {
            "Shadowveil",
            "Duskveil",
            "Frostveil",
            "Vaporous Veil",
            "Shimmering Veil",
            "Arbor Veil",
            "Veil of Alaris",
            "Nature Veil",
        },
        ["JoltingKicks"] = {
            "Jolting Frontkicks",
            "Jolting Hook Kicks",
            "Jolting Crescent Kicks",
            "Jolting Heel Kicks",
            "Jolting Cut Kicks",
            "Jolting Wheel Kicks",
            "Jolting Axe Kicks",
            "Jolting Roundhouse Kicks",
            "Jolting Drop Kicks",
        },
        ["AEBlades"] = {
            "Storm of Blades",
            "Squall Of Blades",
            "Gale of Blades",
            "Blizzard of Blades",
            "Tempest of Blades",
            "Maelstrom of Blades",
        },
        ["FocusedBlades"] = {
            "Focused Storm of Blades",
            "Focused Squall of Blades",
            "Focused Gale of Blades",
            "Focused Blizzard of Blades",
            "Focused Tempest of Blades",
        },
        ["ReflexSlashHeal"] = {
            "Reflexive Bladespurs",
            "Reflexive Nettlespears",
            "Reflexive Rimespurs",
        },
        ["AEArrows"] = {
            "Frenzy of Arrows",
            "Whirlwind of Arrows",
            "Blizzard of Arrows",
            "Gale of Arrows",
            "Cyclone of Arrows",
            "Rain of Arrows",
            "Squall of Arrows",
            "Arrow Swarm",
            "Swarm of Arrows",
            "Tempest of Arrows",
            "Fusillade of Arrows",
            "Storm of Arrows",
            "Barrage of Arrows",
            "Arc of Arrows",
            "Hail of Arrows",
        },
    },
    -- These are handled differently from normal rotations in that we try to make some intelligent decisions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        {
            name  = 'LowLevelHealPoint', -- Fastheal
            state = 1,
            steps = 1,
            cond  = function(self, target)
                return mq.TLO.Me.Level() >= 89 and Core.GetMainAssistPctHPs() <= Config:GetSetting('MainHealPoint')
            end,
        },
        {
            name = 'MainHealPoint', -- Heal
            state = 1,
            steps = 1,
            cond = function(self, target) return Core.GetMainAssistPctHPs() <= Config:GetSetting('MainHealPoint') end,
        },
        {
            name = 'GroupHealPoint', -- TotHeal
            state = 1,
            steps = 1,
            cond = function(self, target) return mq.TLO.Group() and mq.TLO.Group.Injured(Config:GetSetting('GroupHealPoint'))() > Config:GetSetting('GroupInjureCnt') end,
        },
    },
    ['HealRotations']     = {
        ["LowLevelHealPoint"] = {
            {
                name = "Fastheal",
                type = "Spell",
                cond = function(self, _, target)
                    return Config:GetSetting('DoHeals')
                end,
            },

        },
        ["MainHealPoint"] = {
            {
                name = "Heal",
                type = "Spell",
                cond = function(self, _, target)
                    return Config:GetSetting('DoHeals')
                end,
            },
        },
        ["GroupHealPoint"] = {
            {
                name = "Heal",
                type = "Spell",
                cond = function(self, _, target)
                    return Config:GetSetting('DoHeals')
                end,
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    Casting.DoBuffCheck() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            timer = 60, -- only run every 60 seconds top.
            targetId = function(self)
                return Casting.GetBuffableGroupIDs()
            end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.DoBuffCheck()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck()
            end,
        },
        {
            name = 'Ranged Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Config:GetSetting('DoMelee') and not Core.IsModeActive("Healer")
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Core.IsModeActive("Healer")
            end,
        },
        {
            name = 'DPS Buffs',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Core.IsModeActive("Healer")
            end,
        },
        {
            name = 'Defense',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Tank',
            state = 1,
            steps = 1,
            targetId = function(self) return mq.TLO.Target.ID() == Config.Globals.AutoTargetID and { Config.Globals.AutoTargetID, } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.IsTanking()
            end,
        },
    },
    ['Rotations']         = {
        ['Downtime'] = {
            {
                name = "Wildstalker's Unity (Azia)",
                type = "AA",
                tooltip = Tooltips.UnityBuff,
                active_cond = function(self, aaName) return Casting.TargetHasBuff(mq.TLO.Me.AltAbility(aaName).Spell, mq.TLO.Me) end,
                cond = function(self, aaName)
                    return castWSU() and not Casting.SpellStacksOnMe(mq.TLO.Me.AltAbility(aaName).Spell) and
                        not Casting.TargetHasBuff(mq.TLO.Me.AltAbility(aaName).Spell, mq.TLO.Me)
                end,
            },
            {
                name = "Protectionbuff",
                type = "Spell",
                tooltip = Tooltips.Protectionbuff,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not castWSU() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "ParryProcBuff",
                type = "Spell",
                tooltip = Tooltips.ParryProcBuff,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not castWSU() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Hunt",
                type = "Spell",
                tooltip = Tooltips.Hunt,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not castWSU() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Eyes",
                type = "Spell",
                tooltip = Tooltips.Eyes,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return not castWSU() and Casting.SelfBuffCheck(spell) and not Casting.BuffActiveByID(spell.ID()) and not Config:GetSetting('DoMask')
                end,
            },
            {
                name = "GroupPredatorBuff",
                type = "Spell",
                tooltip = Tooltips.GroupPredatorBuff,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Casting.SpellStacksOnMe(spell)
                end,
            },
            {
                name = "ShoutBuff",
                type = "Spell",
                tooltip = Tooltips.ShoutBuff,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Casting.SpellStacksOnMe(spell) and not Casting.BuffActiveByName("Shared " .. spell.Name())
                end,
            },
            {
                name = "GroupStrengthBuff",
                type = "Spell",
                tooltip = Tooltips.GroupStrengthBuff,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and not Casting.BuffActiveByName("Shared " .. spell.Name()) and Casting.SpellStacksOnMe(spell)
                end,
            },
            {
                name = "Rathe",
                type = "Spell",
                tooltip = Tooltips.Rathe,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and not Casting.BuffActiveByName("Shared " .. spell.Name())
                end,
            },
            {
                name = "GroupEnrichmentBuff",
                type = "Spell",
                tooltip = Tooltips.GroupEnrichmentBuff,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Coat",
                type = "Spell",
                tooltip = Tooltips.Coat,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Casting.SpellStacksOnMe(spell)
                end,
            },
            {
                name = "Mask",
                type = "Spell",
                tooltip = Tooltips.Mask,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Config:GetSetting('DoMask') and Casting.SpellStacksOnMe(spell)
                end,
            },
            {
                name = "FireFist",
                type = "Spell",
                tooltip = Tooltips.FireFist,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Config:GetSetting('DoFireFist')
                        and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "DsBuff",
                type = "Spell",
                tooltip = Tooltips.DsBuff,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Casting.SpellStacksOnMe(spell)
                end,
            },
            {
                name = "SkinLike",
                type = "Spell",
                tooltip = Tooltips.SkinLike,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and Casting.SpellStacksOnMe(spell)
                end,
            },
            {
                name = "MoveSpells",
                type = "Spell",
                tooltip = Tooltips.MoveSpells,
                active_cond = function(self, spell) return Config:GetSetting('DoRunSpeed') and Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "AgiBuff",
                type = "Spell",
                tooltip = Tooltips.AgiBuff,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Cloak",
                type = "Spell",
                tooltip = Tooltips.Cloak,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Veil",
                type = "Spell",
                tooltip = Tooltips.Veil,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "AgroReducerBuff",
                type = "Spell",
                tooltip = Tooltips.AgroReducerBuff,
                active_cond = function(self, spell) return not Core.IsTanking() end,
                cond = function(self, spell)
                    return Config:GetSetting('DoAgroReducerBuff') and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "AgroBuff",
                type = "Spell",
                tooltip = Tooltips.AgroBuff,
                active_cond = function(self, spell) return Core.IsTanking() end,
                cond = function(self, spell)
                    return not Config:GetSetting('DoAgroReducerBuff') and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "RegenSpells",
                type = "Spell",
                tooltip = Tooltips.RegenSpells,
                active_cond = function(self, spell) return Config:GetSetting('DoRegen') end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Poison Arrows",
                type = "AA",
                tooltip = Tooltips.PoisonArrow,
                active_cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
                cond = function(self, spell)
                    return Casting.DetAACheck(927) and Config:GetSetting('DoPoisonArrow')
                end,
            },
            {
                name = "Flaming Arrows",
                type = "AA",
                tooltip = Tooltips.FlamingArrow,
                active_cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
                cond = function(self, spell)
                    return Casting.DetAACheck(289) and (mq.TLO.Me.Level() < 86 or not Config:GetSetting('DoPoisonArrow'))
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Rathe",
                type = "Spell",
                tooltip = Tooltips.Rathe,
                active_cond = function(self, spell) return Casting.BuffActiveByID(spell.RankName.ID()) end,
                cond = function(self, spell, target)
                    Targeting.SetTarget(target.ID() or 0)
                    return Casting.SpellStacksOnTarget(spell) and not Casting.TargetHasBuff(spell) and not Casting.TargetHasBuffByName("Shared " .. spell.Name())
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Pack Hunt",
                type = "AA",
                tooltip = Tooltips.PackHunt,
                cond = function(self, spell)
                    return Casting.DetAACheck(43)
                end,
            },
            {
                name = "Entropy of Nature",
                type = "AA",
                tooltip = Tooltips.EoN,
                cond = function(self, spell)
                    return Casting.DetAACheck(682)
                end,
            },
            {
                name = "Spire of the Pathfinders",
                type = "AA",
                tooltip = Tooltips.SotP,
                cond = function(self, spell)
                    return Casting.DetAACheck(1460)
                end,
            },
            {
                name = "Scarlet Cheetah's Fang",
                type = "AA",
                tooltip = Tooltips.SCF,
                cond = function(self, spell)
                    return Casting.DetAACheck(1107)
                end,
            },
            {
                name = "Empowered Blades",
                type = "AA",
                tooltip = Tooltips.EB,
                cond = function(self, spell)
                    return Casting.DetAACheck(683)
                end,
            },
            {
                name = "Auspice of the Hunter",
                type = "AA",
                tooltip = Tooltips.AotH,
                cond = function(self, spell)
                    return Casting.DetAACheck(462)
                end,
            },
            {
                name = "BowDisc",
                type = "Disc",
                tooltip = Tooltips.BowDisc,
                cond = function(self)
                    return not mq.TLO.Me.ActiveDisc.ID() and not Config:GetSetting('DoMelee')
                end,
            },
            {
                name = "MeleeDisc",
                type = "Disc",
                tooltip = Tooltips.MeleeDisc,
                cond = function(self)
                    return not mq.TLO.Me.ActiveDisc.ID() and Config:GetSetting('DoMelee')
                end,
            },
        },
        ['Tank'] = {
            {
                name = "Taunt",
                type = "Ability",
                tooltip = Tooltips.Taunt,
                cond = function(self, abilityName)
                    return Core.IsTanking() and mq.TLO.Me.AbilityReady(abilityName)() and
                        mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and Targeting.GetTargetID() > 0 and
                        Targeting.GetTargetDistance() < 30
                end,
            },
            {
                name = "AggroKick",
                type = "Disc",
                tooltip = Tooltips.AggroKick,
                cond = function(self)
                    return Targeting.GetTargetDistance() <= 50 and mq.TLO.Me.PctAggro() > 50
                end,
            },
            {
                name = "SummerNuke",
                type = "Spell",
                tooltip = Tooltips.SummerNuke,
                active_cond = function(self, spell) return Core.IsTanking() end,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and (mq.TLO.Me.PctAggro() < 100 or mq.TLO.Me.SecondaryPctAggro() > 50)
                end,
            },
        },
        ['Ranged Combat'] = {
            {
                name = "Ranged Mode",
                type = "CustomFunc",
                tooltip = Tooltips.RangedMode,
                cond = function(self, combat_state) return not Config:GetSetting('DoMelee') end,
                custom_func = function(self)
                    Core.SafeCallFunc("Ranger Custom Nav", self.ClassConfig.HelperFunctions.combatNav, false)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "ArrowOpener",
                type = "Spell",
                tooltip = Tooltips.ArrowOpener,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and Config:GetSetting('DoOpener') and Config:GetSetting('DoReagentArrow')
                end,
            },
            {
                name = "PullOpener",
                type = "Spell",
                tooltip = Tooltips.PullOpener,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and Config:GetSetting('DoReagentArrow')
                end,
            },
            {
                name = "CalledShotsArrow",
                type = "Spell",
                tooltip = Tooltips.CalledShotsArrow,
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "FocusedArrows",
                type = "Spell",
                tooltip = Tooltips.FocusedArrows,
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                tooltip = Tooltips.DichoSpell,
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Heartshot",
                type = "Spell",
                tooltip = Tooltips.Heartshot,
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Fireboon",
                type = "Spell",
                tooltip = Tooltips.Fireboon,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and not Casting.BuffActiveByName("FireboonBuff")
                end,
            },
            {
                name = "Iceboon",
                type = "Spell",
                tooltip = Tooltips.Iceboon,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and not Casting.BuffActiveByName("IceboonBuff")
                end,
            },
            {
                name = "Entrap",
                tooltip = Tooltips.Entrap,
                type = "AA",
                cond = function(self)
                    return Config:GetSetting('DoSnare') and Casting.DetAACheck(219)
                end,
            },
            {
                name = "SnareSpells",
                type = "Spell",
                tooltip = Tooltips.SnareSpells,

                cond = function(self, spell)
                    return Config:GetSetting('DoSnare') and Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "AEArrows",
                type = "Spell",
                tooltip = Tooltips.AEArrows,
                cond = function(self, spell)
                    return Casting.HaveManaToNuke() and Config:GetSetting('DoAoE')
                end,
            },
            {
                name = "SwarmDot",
                type = "Spell",
                tooltip = Tooltips.SwarmDot,
                cond = function(self, spell)
                    return Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "ShortSwarmDot",
                type = "Spell",
                tooltip = Tooltips.ShortSwarmDot,
                cond = function(self, spell)
                    return Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "Firenuke",
                type = "Spell",
                tooltip = Tooltips.Firenuke,
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Icenuke",
                type = "Spell",
                tooltip = Tooltips.Icenuke,
                cond = function(self, spell)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Elemental Arrow",
                tooltip = Tooltips.EA,
                type = "AA",
                cond = function(self)
                    return Casting.DetAACheck(32)
                end,
            },
            {
                name = "AEBlades",
                type = "Disc",
                tooltip = Tooltips.AEBlades,
                cond = function(self)
                    return Config:GetSetting('DoAoE') and Targeting.GetTargetDistance() < 50 and Config:GetSetting('DoMelee')
                end,
            },
            {
                name = "FocusedBlades",
                type = "Disc",
                tooltip = Tooltips.FocusedBlades,
                cond = function(self)
                    return Targeting.GetTargetDistance() < 50 and Config:GetSetting('DoMelee')
                end,
            },
            {
                name = "ReflexSlashHeal",
                type = "Disc",
                tooltip = Tooltips.ReflexSlashHeal,
                cond = function(self)
                    return Targeting.GetTargetDistance() < 50 and Config:GetSetting('DoMelee')
                end,
            },
            {
                name = "EndRegenDisc",
                type = "Disc",
                tooltip = Tooltips.EndRegenDisc,
                cond = function(self, discSpell)
                    return not mq.TLO.Me.ActiveDisc.ID() and not Casting.SongActiveByName(discSpell.RankName.Name() or "") and mq.TLO.Me.PctEndurance() < 30
                end,
            },
        },
        ['DPS Buffs'] = {
            {
                name = "Guardian of the Forest",
                type = "AA",
                tooltip = Tooltips.GotF,
                cond = function(self, spell)
                    return not Casting.SongActiveByName("Group Guardian of the Forest") and not Casting.SongActiveByName("Outrider's Accuracy")
                end,
            },
            {
                name = "Outrider's Accuracy",
                type = "AA",
                tooltip = Tooltips.OA,
                cond = function(self, spell)
                    return not Casting.SongActiveByName("Group Guardian of the Forest") and not Casting.SongActiveByName("Guardian of the Forest")
                end,
            },
            {
                name = "Group Guardian of the Forest",
                type = "AA",
                tooltip = Tooltips.GGotF,
                cond = function(self, spell)
                    return not Casting.SongActiveByName("Guardian of the Forest") and not Casting.SongActiveByName("Outrider's Accuracy")
                end,
            },
            {
                name = "Epic",
                type = "Item",
                tooltip = Tooltips.Epic,
                cond = function(self, itemName)
                    return mq.TLO.FindItemCount(itemName)() ~= 0 and mq.TLO.FindItem(itemName).TimerReady() == 0 and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
        },
        ['Defense'] = {
            {
                name = "DefenseDisc",
                type = "Disc",
                tooltip = Tooltips.DefenseDisc,
                cond = function(self)
                    return mq.TLO.Me.PctHPs() < 20 and not mq.TLO.Me.ActiveDisc.ID()
                end,
            },
            {
                name = "Outrider's Evasion",
                tooltip = Tooltips.OE,
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctHPs() < 30 and Casting.DetAACheck(876)
                end,
            },
            {
                name = "Protection of the Spirit Wolf",
                tooltip = Tooltips.PotSW,
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctHPs() < 40 and Casting.DetAACheck(778)
                end,
            },
            {
                name = "Bulwark of the Brownies",
                tooltip = Tooltips.BotB,
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctHPs() < 50 and Casting.DetAACheck(306)
                end,
            },
            {
                name = "JoltingKicks",
                type = "Disc",
                tooltip = Tooltips.JoltingKicks,
                active_cond = function(self) return not Core.IsTanking() and mq.TLO.Me.PctAggro() > 30 end,
                cond = function(self)
                    return not mq.TLO.Me.ActiveDisc.ID() and Targeting.GetTargetDistance() <= 50
                end,
            },
            {
                name = "Imbued Ferocity",
                type = "AA",
                tooltip = Tooltips.IF,
                active_cond = function(self) return not Core.IsTanking() end,
                cond = function(self, spell)
                    return mq.TLO.Me.PctAggro() > 45 and Casting.DetAACheck(2235)
                end,
            },
            {
                name = "Silent Strikes",
                type = "AA",
                tooltip = Tooltips.SS,
                active_cond = function(self, spell) return not Core.IsTanking() end,
                cond = function(self, spell)
                    return mq.TLO.Me.PctAggro() > 60 and Casting.DetAACheck(1109)
                end,
            },
            {
                name = "Chamelon's Gift",
                type = "AA",
                tooltip = Tooltips.CG,
                active_cond = function(self, spell) return not Core.IsTanking() and Casting.DetAACheck(2037) end,
                cond = function(self, spell)
                    return mq.TLO.Me.PctAggro() > 70 and mq.TLO.Me.PctHPs() < 50 and Casting.DetAACheck(2037)
                end,
            },
            {
                name = "SummerNuke",
                type = "Spell",
                tooltip = Tooltips.SummerNuke,
                active_cond = function(self, spell) return not Core.IsTanking() and mq.TLO.Me.Level() >= 98 end,
                cond = function(self, spell)
                    return mq.TLO.Me.PctAggro() < 60
                end,
            },
        },
    },
    ['Spells']            = {
        { -- Spell Gem 1 Is For Our Heal gem from 3 and Changes over to fast heal @ 89.
            gem = 1,
            spells = {
                { name = "Fastheal", cond = function(self) return mq.TLO.Me.Level() <= 89 end, },
                { name = "Heal", },
            },
        },
        { -- SpellGem2 - Is Our Standard Fire Nuke 3-115
            gem = 2,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Firenuke", },
            },
        },
        { -- SpellGem 3 - This is Our Swarm Dot From 25 to 115
            gem = 3,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SwarmDot", },
            },
        },
        { -- Use ArrowOpener if enabled or Snare if no AASnare
            gem = 4,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ArrowOpener", cond = function(self) return Config:GetSetting('DoOpener') end, },
                { name = "SnareSpells", cond = function(self) return not Casting.DetAACheck(219) and Config:GetSetting('DoSnare') end, },
            },
        },
        {
            gem = 5,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DichoSpell", cond = function(self) return mq.TLO.Me.Level() >= 101 end, },
                { name = "Icenuke", },
            },
        },
        {
            gem = 6,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "CalledShotsArrow", },
            },
        },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "FocusedArrows", },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Heartshot", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SummerNuke", },
                { name = "AEArrows",   cond = function(self) return Config:GetSetting('DoAoE') end, },
                { name = "Veil", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ShortSwarmDot", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Iceboon", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Fireboon", },
                { name = "Icenuke", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Alliance", },
            },
        },
    },
    ['HelperFunctions']   = {
        combatNav = function(forceMove)
            if not Config:GetSetting('DoMelee') and not mq.TLO.Me.AutoFire() then
                Core.DoCmd('/squelch face')
                Core.DoCmd('/autofire on')
            end

            if Config:GetSetting('NavCircle') and ((Targeting.GetTargetDistance() <= 30 or Targeting.GetTargetDistance() >= 75) or forceMove) then
                Movement.NavAroundCircle(mq.TLO.Target, Config:GetSetting('NavCircleDist'))
            end

            if not Config:GetSetting('NavCircle') and Targeting.GetTargetDistance() <= 30 then
                Core.DoCmd("/stick %d moveback", Config:GetSetting('NavCircleDist'))
            end

            if not Config:GetSetting('NavCircle') and (Targeting.GetTargetDistance() >= 75 or forceMove) then
                Core.DoCmd("/squelch /nav id %d facing=backward distance=%d", Config.Globals.AutoTargetID, Config:GetSetting('NavCircleDist'))
            end
        end,

        PreEngage = function(target)
            local openerAbility = Core.GetResolvedActionMapItem('ArrowOpener')

            if not openerAbility then return end

            Logger.log_debug("\ayPreEngage(): Testing Opener ability = %s", openerAbility.RankName.Name() or "None")

            if openerAbility and openerAbility() and mq.TLO.Me.PctMana() >= Config:GetSetting("ManaToNuke") and Casting.TargetedSpellReady(openerAbility, target.ID(), false) then
                Core.DoCmd("/squelch /face")
                Casting.UseSpell(openerAbility.RankName.Name(), target.ID(), false)
                Logger.log_debug("\agPreEngage(): Using Opener ability = %s", openerAbility.RankName.Name() or "None")
            else
                Logger.log_debug("\arPreEngage(): NOT using Opener ability = %s, DoOpener = %sd", openerAbility.RankName.Name() or "None",
                    Strings.BoolToColorString(Config:GetSetting("DoOpener")))
            end
        end,
    },
    ['PullAbilities']     = {
        {
            id = 'Snare',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('SnareSpells')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('SnareSpells')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('SnareSpells')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = {
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 4,
            FAQ = "What do the different Modes Do?",
            Help = "Modes are used to change the behavior of the Mercenary based on the current situation. The modes are as follows:\n\n" ..
                "1. DPS - This mode is used for general DPS and is the default mode.\n" ..
                "2. Tank - This mode is used when you are tanking.\n" ..
                "3. Healer - This mode is used when you are healing.\n" ..
                "4. Hybrid - This mode is a combination of the other 3 and will attempt to be a jack of all trades.",
        },
        ['NavCircle']         = {
            DisplayName = "Nav Circle",
            Category = "Combat",
            Tooltip = "Use Nav to Circle your target.",
            Default = true,
            FAQ = "Can Circle the target on my map?",
            Answer = "Enabling [NavCircle] will draw a circle around your target on the map.",
        },
        ['NavCircleDist']     = {
            DisplayName = "Nav Circle Dist",
            Category = "Combat",
            Tooltip = "Use Nav to Circle your target.",
            Default = 45,
            Min = 30,
            Max = 150,
            FAQ = "I want a larger / smaller circle around my target?",
            Answer = "You can adjust the size of the circle by changing the [NavCircleDist] setting.",
        },
        ['DoSnare']           = {
            DisplayName = "Cast Snares",
            Category = "Spells and Abilities",
            Tooltip = "Enable casting Snare spells.",
            Default = true,
            FAQ = "Why am I not casting my snare spells?",
            Answer = "Make sure you have [DoSnare] Enabled and you will cast your Snare Spells.",
        },
        ['DoDot']             = {
            DisplayName = "Cast DOTs",
            Category = "Spells and Abilities",
            Tooltip = "Enable casting Damage Over Time spells.",
            Default = true,
            FAQ = "Why am I not casting my DOT spells?",
            Answer = "Make sure you have [DoDot] Enabled and you will cast your DOT Spells.",
        },
        ['DoHeals']           = {
            DisplayName = "Cast Heals",
            Category = "Spells and Abilities",
            Tooltip = "Enable casting of Healing spells.",
            Default = true,
            FAQ = "Why am I not casting my Heal spells?",
            Answer = "Make sure you have [DoHeals] Enabled and you will cast your Heal Spells.",
        },
        ['DoRegen']           = {
            DisplayName = "Cast Regen Spells",
            Category = "Spells and Abilities",
            Tooltip = "Enable casting of Regen spells.",
            Default = true,
            FAQ = "Why am I not casting my Regen spells?",
            Answer = "Make sure you have [DoRegen] Enabled and you will cast your Regen Spells.",
        },
        ['DoRunSpeed']        = {
            DisplayName = "Cast Run Speed Buffs",
            Category = "Spells and Abilities",
            Tooltip = "Use Ranger Run Speed Buffs.",
            Default = true,
            FAQ = "Why am I not casting my Run Speed Buffs?",
            Answer = "Make sure you have [DoRunSpeed] Enabled and you will cast your Run Speed Buffs.",
        },
        ['DoMask']            = {
            DisplayName = "Cast Mask Spell",
            Category = "Spells and Abilities",
            Tooltip = "Use Ranger Mask Spell",
            Default = false,
            FAQ = "Why am I not casting my Mask Spell?",
            Answer = "Make sure you have [DoMask] Enabled and you will cast your Mask Spell.",
        },
        ['DoFireFist']        = {
            DisplayName = "Cast FireFist",
            Category = "Spells and Abilities",
            Tooltip = "Use Ranger FireFist Line of Spells",
            Default = true,
            FAQ = "Why am I not casting my FireFist Spells?",
            Answer = "Make sure you have [DoFireFist] Enabled and you will cast your FireFist Spells.",
        },
        ['DoAoE']             = {
            DisplayName = "Use AoEs",
            Category = "Spells and Abilities",
            Tooltip = "Enable AoE abilities and spells.",
            Default = false,
            FAQ = "Why am I not casting my AoE spells?",
            Answer = "Make sure you have [DoAoE] Enabled and you will cast your AoE Spells.",
        },
        ['DoOpener']          = {
            DisplayName = "Use Openers",
            Category = "Spells and Abilities",
            Tooltip = "Use Opening Arrow Shot Silent Shot Line.",
            Default = true,
            FAQ = "Why am I not casting my Opener spells?",
            Answer = "Make sure you have [DoOpener] Enabled and you will cast your Opener Spells.",
        },
        ['DoPoisonArrow']     = {
            DisplayName = "Use Poison Arrow",
            Category = "Spells and Abilities",
            Tooltip = "Enable use of Poison Arrow.",
            Default = true,
            FAQ = "Why am I not casting my Poison Arrow spells?",
            Answer = "Make sure you have [DoPoisonArrow] Enabled and you will cast your Poison Arrow Spells.",
        },
        ['DoReagentArrow']    = {
            DisplayName = "Use Reagent Arrow",
            Category = "Spells and Abilities",
            Tooltip = "Toggle usage of Spells and Openers that require Reagent arrows.",
            Default = false,
            FAQ = "Why am I not casting my Reagent Arrow spells?",
            Answer = "Make sure you have [DoReagentArrow] Enabled and you will cast your Reagent Arrow Spells.",
        },
        ['DoAgroReducerBuff'] = {
            DisplayName = "Cast Agro Reducer Buff",
            Category = "Spells and Abilities",
            Tooltip = "Use Agro Reduction Buffs.",
            Default = true,
            FAQ = "How do I manage aggro as a Ranger?",
            Answer = "Make sure you have [DoAgroReducerBuff] Enabled and you will cast your Agro Reducer Buffs.",
        },
    },
}

return _ClassConfig
