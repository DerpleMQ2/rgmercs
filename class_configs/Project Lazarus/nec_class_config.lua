local mq           = require('mq')
local Config       = require('utils.config')
local Comms        = require("utils.comms")
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Casting      = require("utils.casting")

local _ClassConfig = {
    _version            = "2.0 - Project Lazarus",
    _author             = "Algar, Derple",
    ['Modes']           = {
        'DPS',
    },
    ['ModeChecks']      = {
        CanCharm   = function() return true end,
        IsCharming = function() return (Config:GetSetting('CharmOn') and mq.TLO.Pet.ID() == 0) end,
    },
    ['Themes']          = {
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
    },
    ['CommandHandlers'] = {
        startlich = {
            usage = "/rgl startlich",
            about = "Start your Lich Spell [Note: This will enabled DoLich if it is not already].",
            handler =
                function(self)
                    Config:SetSetting('DoLich', true)
                    Core.SafeCallFunc("Start Necro Lich", self.ClassConfig.HelperFunctions.StartLich, self)

                    return true
                end,
        },
        stoplich = {
            usage = "/rgl stoplich",
            about = "Stop your Lich Spell [Note: This will NOT disable DoLich].",
            handler =
                function(self)
                    Core.SafeCallFunc("Stop Necro Lich", self.ClassConfig.HelperFunctions.CancelLich, self)

                    return true
                end,
        },
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Deathwhisper",
            "Soulwhisper",
        },
        ['OoW_Chest'] = {
            "Blightbringer's Tunic of the Grave",
            "Deathcaller's Robe",
        },
    },
    ['AbilitySets']     = {
        ['SelfHPBuff'] = {
            "Shadow Guard",
            "Shield of Maelin",
            "Shield of the Arcane",
            "Shield of the Magi",
            "Arch Shielding",
            "Greater Shielding",
            "Major Shielding",
            "Shielding",
            "Lesser Shielding",
            "Minor Shielding",
        },
        ['SelfRune'] = {
            "Dull Pain",
            "Force Shield",
            "Manaskin",
            "Diamondskin",
            "Steelskin",
            "Leatherskin",
            "Shieldskin",
        },
        ['CharmSpell'] = {
            "Word of Chaos",
            "Word of Terris",
            "Enslave Death",
            "Thrall of Bones",
            "Cajole Undead",
            "Beguile Undead",
            "Dominate Undead",
        },
        ['LifeTap'] = {
            "Ancient: Touch of Orshilak",
            "Soulspike",
            "Touch of Mujaki",
            -- "Gangrenous Touch of Zum`uul",
            "Touch of Night",
            "Deflux",
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Lifedraw",
            "Lifespike",
            "Lifetap",
        },
        -- ['DurationTap'] = {
        --     "Fang of Death",
        --     "Night's Beckon",
        --     "Saryrn's Kiss",
        --     "Vexing Replenishment",
        --     "Auspice",
        --     "Bond of Death",
        --     "Vampiric Curse",
        --     "Shadow Compact",
        --     "Leech",
        -- },
        ['PoisonNuke'] = {
            "Call for Blood",
            "Acikin",
            "Neurotoxin",
            "Ancient: Lifebane",
            "Torbas' Venom Blast",
            "Torbas' Poison Blast",
            "Torbas' Acid Blast",
            "Shock of Poison",
        },
        ['FireDot'] = {
            "Dread Pyre",
            "Pyre of Mori",
            "Night Fire",
            "Funeral Pyre of Kelador",
            "Pyrocruor",
            "Ignite Blood",
            "Boil Blood",
            "Heat Blood",
        },
        ['FireDot2'] = { -- because of dots that trigger other dots on laz, this is the only second fire dot feasible for use
            "Pyre of Mori",
        },
        -- ['SplurtDot'] = {
        --     "Splort",
        --     "Splurt",
        -- },
        ['CurseDot'] = {
            "Ancient: Curse of Mori",
            "Dark Nightmare",
            "Horror",
            "Imprecation",
            "Dark Soul",
        },
        ['CurseDot2'] = { -- because of dots that trigger other dots on laz, this is the only second curse dot feasible for use
            "Dark Nightmare",
        },
        ['PlagueDot'] = {
            "Chaos Plague",
            "Dark Plague",
            "Cessation of Cor",
        },
        -- ['DebuffDot'] = {
        --     "Grip of Mori",
        --     "Plague",
        --     "Asystole",
        --     "Scourge",
        --     "Heart Flutter",
        --     "Infectious Cloud",
        --     "Disease Cloud",
        -- },
        ['PoisonDotDD'] = {
            "Venom of Anguish",
        },
        ['PoisonDot'] = {
            "Chaos Venom",
            "Blood of Thule",
            "Envenomed Bolt",
            "Chilling Embrace",
            "Venom of the Snake",
            "Poison Bolt",
        },
        ['SnareDot'] = {
            "Desecrating Darkness",
            "Embracing Darkness",
            "Devouring Darkness",
            "Cascading Darkness",
            "Scent of Darkness",
            "Dooming Darkness",
            "Engulfing Darkness",
            "Clinging Darkness",
        },
        ['ScentDebuff'] = {
            "Scent of Terris",
            "Scent of Darkness",
            "Scent of Shadow",
            "Scent of Dusk",
        },
        ['ScentDebuff2'] = {
            "Scent of Midnight",
        },
        ['LichSpell'] = {
            "Ancient: Allure of Extinction",
            -- "Dark Possession", -- Listed in spell file, does not appear to be in game?
            "Grave Pact",
            "Ancient: Seduction of Chaos",
            "Seduction of Saryrn",
            "Ancient: Master of Death",
            "Arch Lich",
            "Demi Lich",
            "Lich",
            "Call of Bones",
            "Allure of Death",
            "Dark Pact",
        },
        ['PetSpellRog'] = {
            "Dark Assassin",
            "Child of Bertoxxulous",
            "Saryrn's Companion",
            "Minion of Shadows",
        },
        ['PetSpellWar'] = {
            "Lost Soul",
            "Child of Bertoxxulous",
            "Legacy of Zek",
            "Emissary of Thule",
            "Servant of Bones",
            "Invoke Death",
            "Cackling Bones",
            "Malignant Dead",
            "Invoke Shadow",
            "Summon Dead",
            "Haunting Corpse",
            "Animate Dead",
            "Restless Bones",
            "Convoke Shadow",
            "Bone Walk",
            "Leering Corpse",
            "Cavorting Bones",
        },
        ['PetHaste'] = {
            "Glyph of Darkness",
            "Rune of Death",
            "Augmentation of Death",
            "Augment Death",
            "Intensify Death",
            "Focus Death",
        },
        ['UndeadNuke'] = {
            "Desolate Undead",
            "Destroy Undead",
            "Exile Undead",
            "Banish Undead",
            "Expel Undead",
            "Dismiss Undead",
            "Expulse Undead",
            "Ward Undead",
        },
        ['OrbNuke'] = {
            "Shadow Orb",
            "Soul Orb",
        },
        -- ['Calliav'] = { --35s refresh on mem, and this does not seem worth a gem slot currently
        --     "Bulwark of Calliav",
        --     "Protection of Calliav",
        --     "Guard of Calliav",
        --     "Ward of Calliav",
        -- },
        ['PetHealSpell'] = { -- Also has cure effect for pet
            "Dark Salve",
            "Touch of Death",
            "Renew Bones",
            "Mend Bones",
        },
        ['Pustules'] = {
            "Necrotic Pustules",
        },
        -- ['GroupLeech'] = {
        --     "Night Stalker",
        --     "Zevfeer's Theft of Vitae",
        -- },
        ['FeignSpell'] = {
            "Death Peace",
            "Comatose",
            "Feign Death",
        },
        ['HarmshieldSpell'] = {
            "Quivering Veil of Xarn",
            "Harmshield",
        },
        -- ['UndeadConvert'] = {
        --     "Chill Bones",
        --     "Ignite Bones",
        -- },
    },
    ['RotationOrder']   = {
        { --Summon pet even when buffs are off on emu
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 30,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        {
            name = 'Pustules',
            timer = 10,
            load_cond = function() return Config:GetSetting('DoPustules') end,
            targetId = function(self) return { Core.GetMainAssistId(), } or {} end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and Casting.OkayToBuff()
                local burning = combat_state == "Combat" and Casting.BurnCheck() and not Casting.IAmFeigning()
                return downtime or burning
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or (Targeting.IsNamed(Targeting.GetAutoTarget()) and mq.TLO.Me.PctAggro() > 99))
            end,
        },
        {
            name = 'Scent(Terris)',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('ScentDebuffUse') == 2 end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and Casting.OkayToDebuff()
            end,
        },
        { -- On Laz, this hits slightly different resists, and in different slots, it is a choice.
            name = 'Scent(Midnight)',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('ScentDebuffUse') == 3 end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and Casting.OkayToDebuff()
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and not Targeting.IsNamed(Targeting.GetAutoTarget()) and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck() and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS(MobHighHP)',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and Targeting.MobNotLowHP(Targeting.GetAutoTarget())
            end,
        },
        {
            name = 'DPS(MobLowHP)',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and Targeting.MobHasLowHP(Targeting.GetAutoTarget())
            end,
        },
        {
            name = 'CombatBuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'ArcanumWeave',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoArcanumWeave') and Casting.CanUseAA("Acute Focus of Arcanum") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and not mq.TLO.Me.Buff("Focus of Arcanum")()
            end,
        },
        {
            name = 'PetHealing',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, target) return (mq.TLO.Me.Pet.PctHPs() or 100) < Config:GetSetting('PetHealPct') end,
        },
    },
    ['Rotations']       = {
        ['Emergency']       = {
            {
                name = "Death's Effigy",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('AggroFeign') then return false end
                    return (Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() > 99) or (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Targeting.IHaveAggro(100))
                end,
            },
            {
                name = "Embalmer's Carapace",
                type = "AA",
            },
            {
                name = "Harm Shield",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Targeting.IHaveAggro(100))
                end,
            },
        },
        ['Scent(Terris)']   = {
            {
                name = "Scent of Terris",
                type = "AA",
                load_cond = function(self) return Casting.CanUseAA("Scent of Terris") end,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "ScentDebuff",
                type = "Spell",
                load_cond = function(self) return not Casting.CanUseAA("Scent of Terris") end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Scent(Midnight)'] = {
            {
                name = "ScentDebuff2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Snare']           = {
            {
                name = "Encroaching Darkness",
                type = "AA",
                load_cond = function(self) return Casting.CanUseAA("Encroaching Darkness") end,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
            {
                name = "SnareDot",
                type = "Spell",
                load_cond = function(self) return not Casting.CanUseAA("Encroaching Darkness") end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
        },
        ['CombatBuff']      = {
            {
                name = "Death Bloom",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('DeathBloomPercent') and mq.TLO.Me.PctHPs() > 50
                end,
            },
            {
                name = "Reluctant Benevolence",
                type = "AA",
                cond = function(self, aaName) return not mq.TLO.Me.Song(aaName)() end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if Config:GetSetting('UseEpic') == 1 then return false end
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "LichSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLich') end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and mq.TLO.Me.PctHPs() > Config:GetSetting('StopLichHP') and mq.TLO.Me.PctMana() < Config:GetSetting('StartLichMana')
                end,
            },
            {
                name = "LichControl",
                type = "CustomFunc",
                load_cond = function(self) return Config:GetSetting('DoLich') end,
                cond = function(self, _)
                    local lichSpell = Core.GetResolvedActionMapItem('LichSpell')

                    return lichSpell and lichSpell() and Casting.IHaveBuff(lichSpell) and
                        (mq.TLO.Me.PctHPs() <= Config:GetSetting('StopLichHP') or mq.TLO.Me.PctMana() >= Config:GetSetting('StopLichMana'))
                end,
                custom_func = function(self)
                    Core.SafeCallFunc("Stop Necro Lich", self.ClassConfig.HelperFunctions.CancelLich, self)
                end,
            },
        },
        ['DPS(MobHighHP)']  = {
            {
                name = "PoisonDotDD",
                type = "Spell",
                cond = function(self, spell, target)
                    if Targeting.IsNamed(target) then return false end
                    return Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "FireDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "CurseDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "PoisonDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "PlagueDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "PoisonDotDD",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Targeting.IsNamed(target) then return false end
                    return Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "FireDot2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "CurseDot2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "Scythe of the Shadowed Soul",
                type = "Item",
                load_cond = function(self) return mq.TLO.FindItem("=Scythe of the Shadowed Soul")() end,
                cond = function(self, itemName, target)
                    return Casting.DotItemCheck(itemName, target)
                end,
            },
            {
                name = "Dagger of Death",
                type = "Item",
                load_cond = function(self) return mq.TLO.FindItem("=Dagger of Death")() end,
                cond = function(self, itemName, target)
                    return Casting.DotItemCheck(itemName, target)
                end,
            },
            {
                name = "PoisonNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
        },
        ['DPS(MobLowHP)']   = {
            {
                name = "OrbNuke",
                type = "Spell",
                load_cond = function() return Config:GetSetting('DoOrbNuke') end,
                cond = function(self, spell, target)
                    return (mq.TLO.FindItemCount("=Orb of Shadows")() or 0) < 101
                end,
            },
            {
                name = "UndeadNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoUndeadNuke') end,
                cond = function(self, spell, target)
                    if not Targeting.TargetBodyIs(target, "Undead") then return false end

                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "LifeTap",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLifetap') end,
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "PoisonNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
        },
        ['Burn']            = {
            {
                name = "OoW_Chest",
                type = "Item",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.SelfBuffAACheck(aaName) and Targeting.IsNamed(target)
                end,
            },
            {
                name_func = function(self)
                    return Casting.GetFirstAA({ "Army of the Dead", "Wake the Dead", })
                end,
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.SpawnCount("corpse radius 100")() >= Config:GetSetting('WakeDeadCorpseCnt') and Targeting.IsNamed(target)
                end,
            },
            {
                name = "Swarm of Decay",
                type = "AA",
            },
            {
                name = "Rise of Bones",
                type = "AA",
            },
            {
                name = "Graverobber's Icon",
                type = "Item",
            },
            {
                name = "Frenzy of the Dead",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not mq.TLO.Me.Buff("Twincast")()
                end,
            },
            { -- Spire, the SpireChoice setting will determine which ability is displayed/used.
                name_func = function(self)
                    local spireAbil = string.format("Fundament: %s Spire of Necromancy", Config.Constants.SpireChoices[Config:GetSetting('SpireChoice') or 4])
                    return Casting.CanUseAA(spireAbil) and spireAbil or "Spire Not Purchased/Selected"
                end,
                type = "AA",
            },
            {
                name = "Silent Casting",
                type = "AA",
            },
            {
                name = "Gathering Dusk",
                type = "AA",
                cond = function(self, aaName, target) return Targeting.IsNamed(target) and Targeting.GetAutoTargetPctHPs() < 85 and mq.TLO.Me.PctAggro() <= 25 end,
            },
            {
                name = "Life Burn",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoLifeBurn') end,
                cond = function(self, aaName, target)
                    return Targeting.IsNamed(target) and mq.TLO.Me.PctAggro() <= 25
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['PetHealing']      = {
            {
                name = "Companion's Blessing",
                type = "AA",
                cond = function(self, aaName, target)
                    return (mq.TLO.Me.Pet.PctHPs() or 999) <= Config:GetSetting('BigHealPoint')
                end,
            },
            {
                name = "Minion's Memento",
                type = "Item",
            },
            {
                name_func = function() return Casting.CanUseAA("Replenish Companion") and "Replenish Companion" or "Mend Companion" end,
                type = "AA",
            },
            {
                name = "PetHealSpell",
                type = "Spell",
                load_cond = function(self) Config:GetSetting('DoPetHealSpell') end,
            },
        },
        ['ArcanumWeave']    = {
            {
                name = "Empowered Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Enlightened Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Acute Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['Downtime']        = {
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "Reluctant Benevolence",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.AltAbility(aaName).Spell.RankName()) end,
                cond = function(self, aaName) return not mq.TLO.Me.Song(aaName)() end,
            },
            {
                name = "LichSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLich') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell) and mq.TLO.Me.PctHPs() > Config:GetSetting('StopLichHP') and mq.TLO.Me.PctMana() < Config:GetSetting('StartLichMana')
                end,
            },
            {
                name = "LichControl",
                type = "CustomFunc",
                load_cond = function(self) return Config:GetSetting('DoLich') end,
                active_cond = function(self, spell) return true end,
                cond = function(self, _)
                    local lichSpell = Core.GetResolvedActionMapItem('LichSpell')

                    return lichSpell and lichSpell() and Casting.IHaveBuff(lichSpell) and
                        (mq.TLO.Me.PctHPs() <= Config:GetSetting('StopLichHP') or mq.TLO.Me.PctMana() >= Config:GetSetting('StopLichMana'))
                end,
                custom_func = function(self)
                    Core.SafeCallFunc("Stop Necro Lich", self.ClassConfig.HelperFunctions.CancelLich, self)
                end,
            },
        },
        ['PetSummon']       = {
            {
                name = "PetSpellWar",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('PetType') == 1 end,
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 and mq.TLO.Me.Pet.Class.ShortName():lower() == ("war" or "mnk") end,
                cond = function(self, spell)
                    return Casting.ReagentCheck(spell)
                end,
                post_activate = function(self, spell, success)
                    local pet = mq.TLO.Me.Pet
                    if success and pet.ID() > 0 then
                        Comms.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(), pet.Class.Name(), pet.CleanName(), spell.RankName())
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
            {
                name = "PetSpellRog",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('PetType') == 2 end,
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 and mq.TLO.Me.Pet.Class.ShortName():lower() == "rog" end,
                cond = function(self, spell)
                    return Casting.ReagentCheck(spell)
                end,
                post_activate = function(self, spell, success)
                    local pet = mq.TLO.Me.Pet
                    if success and pet.ID() > 0 then
                        Comms.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(), pet.Class.Name(), pet.CleanName(), spell.RankName())
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['PetBuff']         = {
            {
                name = "PetHaste",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },
            {
                name = "Aegis of Kildrukaun",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
        },
        ['Pustules']        = {
            {
                name = "Pustules",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetClassIs({ "PAL", "WAR", }, target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
    },
    ['HelperFunctions'] = {
        CancelLich = function(self)
            -- detspa means detremental spell affect
            -- spa is positive spell affect
            local lichName = mq.TLO.Me.FindBuff("detspa hp and spa mana")()
            Core.DoCmd("/removebuff %s", lichName)
        end,
        StartLich = function(self)
            local lichSpell = Core.GetResolvedActionMapItem('LichSpell')

            if lichSpell and lichSpell() then
                local targetId = mq.TLO.Me.ID()
                table.insert(self.TempSettings.QueuedAbilities, {
                    name = lichSpell,
                    targetId = targetId,
                    target = mq.TLO.Spawn(targetId),
                    type = "spell",
                    queuedTime = os.clock(),
                })
            end
        end,
    },
    ['SpellList']       = { -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
        {
            name = "Default Mode",
            -- cond = function(self) return true end, --Code kept here for illustration, if there is no condition to check, this line is not required
            spells = {
                { name = "PetHealSpell", cond = function(self) return Config:GetSetting('DoPetHealSpell') end, },
                { name = "CharmSpell",   cond = function(self) return Config:GetSetting('CharmOn') end, },
                { name = "ScentDebuff",  cond = function(self) return Config:GetSetting('ScentDebuffUse') == 2 and not Casting.CanUseAA("Scent of Terris") end, },
                { name = "ScentDebuff",  cond = function(self) return Config:GetSetting('ScentDebuffUse') == 3 end, },
                { name = "PoisonNuke", },
                { name = "PoisonDotDD", },
                { name = "FireDot", },
                { name = "FireDot2",     cond = function(self) return mq.TLO.Me.Book("Dread Pyre")() end, },
                { name = "CurseDot", },
                { name = "CurseDot2",    cond = function(self) return mq.TLO.Me.Book("Ancient: Curse of Mori")() end, },
                { name = "PoisonDot", },
                { name = "PlagueDot", },
                { name = "LichSpell",    cond = function(self) return Config:GetSetting('DoLich') end, },
                { name = "Pustules",     cond = function(self) return Config:GetSetting('DoPustules') end, },
                { name = "OrbNuke",      cond = function(self) return Config:GetSetting('DoOrbNuke') end, },
                { name = "LifeTap",      cond = function(self) return Config:GetSetting('DoLifetap') end, },
                { name = "UndeadNuke",   cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
            },
        },
    },
    ['DefaultConfig']   = {
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes Do?",
            Answer = "Currently Necros only have one mode, which is DPS. This mode will focus on DPS and some utility.",
        },

        --Pet
        ['PetType']           = {
            DisplayName = "Pet Class",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Summoning",
            Index = 101,
            Tooltip = "Choose which pet you wish to summon. Please note that rogue pets have uneven spacing at lower levels.",
            Type = "Combo",
            ComboOptions = { 'War', 'Rog', },
            Default = 1,
            Min = 1,
            Max = 2,
        },
        ['DoPetHealSpell']    = {
            DisplayName = "Pet Heal Spell",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Mem and cast your Pet Heal (Salve) spell. AA Pet Heals are always used in emergencies.",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['PetHealPct']        = {
            DisplayName = "Pet Heal Spell HP%",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Healing Thresholds",
            Index = 101,
            Tooltip = "Use your pet heal spell when your pet is at or below this HP percentage.",

            Default = 60,
            Min = 1,
            Max = 99,
        },

        --Debuffs
        ['ScentDebuffUse']    = {
            DisplayName = "Scent Debuff:",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Index = 101,
            Tooltip =
                "Choose which scent resist debuff to use, if any.\n" ..
                "Terris denotes the standard scent debuffs, up to and including Scent of Terris (and the AA version).\n" ..
                "Midnight denotes the level 70 Scent of Midnight, which uses different slots and has different stacking.",
            Type = "Combo",
            ComboOptions = { 'Disabled', 'Terris', 'Midnight', },
            Default = 2,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why is Scent of Midnight a separate option from Scent of Terris?",
            Answer = "Scent of Midnight has been customized on Laz to use different slots, but also stack with other resist debuffs.",
        },
        ['DoSnare']           = {
            DisplayName = "Use Snares",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Index = 101,
            Tooltip = "Use Snare(Snare Dot used until AA is available).",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['SnareCount']        = {
            DisplayName = "Snare Max Mob Count",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Index = 102,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
            Min = 1,
            Max = 99,
        },

        --Combat
        ['DoLifetap']         = {
            DisplayName = "Do Lifetap",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 101,
            Tooltip = "Use the your ST Lifetap nuke line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoUndeadNuke']      = {
            DisplayName = "Do Undead Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Use the Undead nuke line.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['WakeDeadCorpseCnt'] = {
            DisplayName = "WtD Corpse Count",
            Group = "Abilities",
            Header = "Pet",
            Category = "Swarm Pets",
            Index = 101,
            Tooltip = "Number of Corpses before we cast Wake the Dead",
            Default = 5,
            Min = 1,
            Max = 20,
            ConfigType = "Advanced",
        },
        ['DoLifeBurn']        = {
            DisplayName = "Use Life Burn",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 102,
            Tooltip = "Use Life Burn AA if your aggro is below 25%.",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
        },
        ['UseEpic']           = {
            DisplayName = "Epic Use:",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['SpireChoice']       = {
            DisplayName = "Spire Choice:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip = "Choose which Fundament you would like to use during burns:\n" ..
                "First Spire: DoT Crit Chance Buff.\n" ..
                "Second Spire: Pet Damage Proc Buff.\n" ..
                "Third Spire: DoT Crit Damage Buff.",
            Type = "Combo",
            ComboOptions = Config.Constants.SpireChoices,
            Default = 3,
            Min = 1,
            Max = #Config.Constants.SpireChoices,
        },
        ['EmergencyStart']    = {
            DisplayName = "Emergency HP%",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 101,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['AggroFeign']        = {
            DisplayName = "Emergency Feign",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 102,
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a RGMercsNamed/SpawnMaster mob.",
            Default = true,
        },

        --Utility
        ['DoLich']            = {
            DisplayName = "Cast Lich",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = "Enable casting Lich spells.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['StopLichHP']        = {
            DisplayName = "Stop Lich HP",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 102,
            Tooltip = "Cancel your Lich spell once your health has dropped to this percentage.",
            RequiresLoadoutChange = false,
            Default = 25,
            Min = 1,
            Max = 99,
        },
        ['StartLichMana']     = {
            DisplayName = "Start Lich Mana",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 103,
            Tooltip = "Use your Lich spell when your mana has dropped to this percentage.",
            RequiresLoadoutChange = false,
            Default = 70,
            Min = 1,
            Max = 100,
        },
        ['StopLichMana']      = {
            DisplayName = "Stop Lich Mana",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 104,
            Tooltip = "Cancel your Lich spell when your mana has increased to this percentage.",
            RequiresLoadoutChange = false,
            Default = 100,
            Min = 1,
            Max = 100,
        },
        ['DeathBloomPercent'] = {
            DisplayName = "Death Bloom %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 101,
            Tooltip = "Use Death Bloom when your mana has dropped to this percentage.",
            Default = 40,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['DoPustules']        = {
            DisplayName = "Use Pustules",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip = "Use your Necrotic Pustules spell on the (non-SHD) MA.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['DoArcanumWeave']    = {
            DisplayName = "Weave Arcanums",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 105,
            Tooltip = "Weave Empowered/Enlighted/Acute Focus of Arcanum into your standard combat routine (Focus of Arcanum is saved for burns).",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = true,
            ConfigType = "Advanced",
        },
        ['DoOrbNuke']         = {
            DisplayName = "Summon Orbs",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 103,
            Tooltip = "Use your Orb nuke to summon more Soul/Shadow orbs when needed.",
            RequiresLoadoutChange = true,
            Default = true,
        },
    },
}

return _ClassConfig
