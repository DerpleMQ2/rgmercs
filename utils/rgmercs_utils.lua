local mq            = require('mq')
local RGMercsLogger = require("rgmercs.utils.rgmercs_logger")
local animSpellGems = mq.FindTextureAnimation('A_SpellGems')
local ICONS         = require('mq.Icons')
local ICON_SIZE     = 20
local USEGEM        = mq.TLO.Me.NumGems()
-- Global
Memorizing          = false

local Utils         = { _version = '0.1a', author = 'Derple' }
Utils.__index       = Utils
Utils.Actors        = require('actors')
Utils.ScriptName    = "RGMercs"

function Utils.BroadcastUpdate(module, event)
    Utils.Actors.send({ from = RGMercConfig.CurLoadedChar, script = Utils.ScriptName, module = module, event = event })
end

function Utils.PrintGroupMessage(msg)
    mq.cmdf("/dgt group_%s_%s %s", RGMercConfig.CurServer, mq.TLO.Group.Leader() or "None", msg)
end

---@param t table
function Utils.CheckPlugins(t)
    for _, p in pairs(t) do
        if not mq.TLO.Plugin(p)() then
            mq.cmdf("/squelch /plugin %s noauto", p)
            RGMercsLogger.log_info("\aw %s \ar not detected! \aw This macro requires it! Loading ...", p)
        end
    end
end

---@param t table
---@return table
function Utils.UnCheckPlugins(t)
    local r = {}
    for _, p in pairs(t) do
        if mq.TLO.Plugin(p)() then
            mq.cmdf("/squelch /plugin %s unload noauto", p)
            RGMercsLogger.log_info("\ar %s detected! \aw Unloading it due to known conflicts with RGMercs!", p)
            table.insert(r, p)
        end
    end

    return r
end

function Utils.GetBestItem(t)
    local selectedItem = nil

    for _, i in ipairs(t or {}) do
        if mq.TLO.FindItem("=" .. i)() then
            selectedItem = i
            break
        end
    end

    if selectedItem then
        RGMercsLogger.log_debug("\agFound\ax %s!", selectedItem)
    else
        RGMercsLogger.log_debug("\arNo items found for slot!")
    end

    return selectedItem
end

function Utils.GetBestSpell(t)
    local highestLevel = 0
    local selectedSpell = nil

    for _, s in ipairs(t or {}) do
        local spell = mq.TLO.Spell(s)
        --RGMercsLogger.log_debug("Found %s level(%d) rank(%s)", s, spell.Level(), spell.RankName())
        if spell.Level() <= mq.TLO.Me.Level() then
            if mq.TLO.Me.Book(spell.RankName())() or mq.TLO.Me.CombatAbility(spell.RankName())() then
                if spell.Level() > highestLevel then
                    highestLevel = spell.Level()
                    selectedSpell = spell
                end
            else
                Utils.PrintGroupMessage(string.format(
                    "%s \aw [%s] \ax \ar MISSING SPELL \ax -- \ag %s \ax -- \aw LVL: %d \ax", mq.TLO.Me.CleanName(), s,
                    spell.RankName(), spell.Level()))
            end
        end
    end

    if selectedSpell then
        RGMercsLogger.log_debug("\agFound\ax %s level(%d) rank(%s)", selectedSpell.BaseName(), selectedSpell.Level(),
            selectedSpell.RankName())
    else
        RGMercsLogger.log_debug("\arNo spell found for slot!")
    end

    return selectedSpell
end

function Utils.WaitCastFinish()
    while mq.TLO.Me.Casting() and (not mq.TLO.Cast.Ready()) do
        mq.delay(100)
    end
end

function Utils.ManaCheck(config)
    return mq.TLO.Me.PctMana() >= config.ManaToNuke
end

function Utils.MemorizeSpell(gem, spell)
    RGMercsLogger.log_info("\ag Meming \aw %s in \ag slot %d", spell, gem)
    mq.cmdf("/memspell %d \"%s\"", gem, spell)

    while mq.TLO.Me.Gem(gem)() ~= spell do
        RGMercsLogger.log_debug("\ayWaiting for '%s' to load in slot %d'...", spell, gem)
        mq.delay(100)
    end
end

function Utils.WaitCastReady(spell)
    while not mq.TLO.Cast.Ready(spell)() do
        mq.delay(100)
        RGMercsLogger.log_debug("Waiting for spell '%s' to be ready...", spell)
    end
end

function Utils.ExecEntry(e, map)
    if e.type:lower() == "item" then
        local i = map[e.name]
        cmd = string.format("/useitem \"%s\"", i)
        mq.cmdf(cmd)
        RGMercsLogger.debug_log("Running: \at'%s'", cmd)
        return
    end

    if e.type:lower() == "spell" then
        local s = map[e.name]
        RGMercsLogger.log_debug("%s - %s", e.name, s)
        if s then
            if not mq.TLO.Me.Book(s.RankName())() then
                --RGMercsLogger.log_error("\arSpell '\at%s\ar' is not in your book!", s.Name())
                return
            end

            if not mq.TLO.Me.Gem(s.RankName())() then
                RGMercsLogger.log_debug("\ay%s is not memorized - meming!", s.RankName())
                Utils.MemorizeSpell(USEGEM, s.RankName())
            end

            Utils.WaitCastReady(s.RankName())
            cmd = string.format("/casting \"%s\" -maxtries|5", s.RankName())
            mq.cmdf(cmd)
            RGMercsLogger.log_debug("Running: \at'%s'", cmd)
        else
            RGMercsLogger.log_error("Entry Key: %s not found in map!", e.name)
        end

        Utils.WaitCastFinish()

        return
    end
end

function Utils.RunRotation(s, r, map)
    local oldSpellInSlot = mq.TLO.Me.Gem(USEGEM)
    for _, entry in ipairs(r) do
        if entry.cond then
            local pass = entry.cond(s, map[entry.name] or mq.TLO.Spell(entry.name))
            if pass == true then
                Utils.ExecEntry(entry, map)
            end
        else
            Utils.ExecEntry(entry, map)
        end
    end

    if oldSpellInSlot and mq.TLO.Me.Gem(USEGEM)() ~= oldSpellInSlot.Name() then
        RGMercsLogger.log_debug("\ayRestoring %s in slot %d", oldSpellInSlot, USEGEM)
        Utils.MemorizeSpell(USEGEM, oldSpellInSlot.Name())
    end
end

function Utils.SelfBuffPetCheck(spell)
    if not spell then return false end
    return not mq.TLO.Me.PetBuff(spell.Name())() and spell.StacksPet() and mq.TLO.Me.Pet.ID() > 0
end

function Utils.SelfBuffCheck(spell)
    if not spell then return false end
    local res = not mq.TLO.Me.FindBuff("id " .. tostring(spell.ID())).ID() and spell.Stacks()
    return res
end

function Utils.SelfBuffAACheck(aaName)
    return not mq.TLO.Me.FindBuff("id " .. tostring(mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName)).ID())).ID() and
        not mq.TLO.Me.FindBuff("id " .. tostring(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())).ID() and
        not mq.TLO.Me.Aura(tostring(mq.TLO.Spell(aaName).RankName())).ID() and
        mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName).Spell.RankName()).Stacks() and
        mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1)).Stacks()
end

function Utils.DotSpellCheck(config, spell)
    if not spell then return false end
    return not mq.TLO.Target.FindBuff("id " .. tostring(spell.ID())).ID() and spell.StacksTarget() and
        Utils.GetTragetPctHPs() > config.HPStopDOT
end

function Utils.DetSpellCheck(spell)
    if not spell then return false end
    return not mq.TLO.Target.FindBuff("id " .. tostring(spell.ID())).ID() and spell.StacksTarget()
end

function Utils.TargetHasBuff(spell)
    return mq.TLO.Target() and mq.TLO.Target.FindBuff("id " .. tostring(spell.ID())).ID() > 0
end

function Utils.GetTargetDistance()
    return (mq.TLO.Target.Distance() or 9999)
end

function Utils.GetTragetPctHPs()
    return (mq.TLO.Target.PctHPs() or 0)
end

function Utils.BurnCheck(config)
    return ((config.BurnAuto and (mq.TLO.XAssist.XTFullHaterCount >= config.BurnMobCount or (mq.TLO.Target.Named() and config.BurnNamed) or (config.BurnAlways and config.BurnAuto))) or (not config.BurnAuto and config.BurnSize))
end

function Utils.SmallBurn(config)
    return config.BurnSize >= 1
end

function Utils.MedBurn(config)
    return config.BurnSize >= 2
end

function Utils.BigBurn(config)
    return config.BurnSize >= 3
end

function Utils.DetAACheck(aaId)
    if not mq.TLO.Target.ID() then return false end
    local Target = mq.TLO.Target
    local Me     = mq.TLO.Me

    return (not Target.FindBuff("id " .. tostring(Me.AltAbility(aaId).Spell.ID())).ID() and
            not Target.FindBuff("id " .. tostring(Me.AltAbility(aaId).Spell.Trigger(1).ID()))) and
        (Me.AltAbility(aaId).Spell.StacksTarget() or Me.AltAbility(aaId).Spell.Trigger(1).StacksTarget())
end

function Utils.SetLoadOut(caller, t, itemSets, abilitySets)
    local spellLoadOut = {}
    local resolvedActionMap = {}

    -- Map AbilitySet Items and Load Them
    for k, t in pairs(itemSets) do
        RGMercsLogger.log_debug("Finding best item for Set: %s", k)
        resolvedActionMap[k] = Utils.GetBestItem(t)
    end
    for k, t in pairs(abilitySets) do
        RGMercsLogger.log_debug("\ayFinding best spell for Set: \am%s", k)
        resolvedActionMap[k] = Utils.GetBestSpell(t)
    end

    for _, s in ipairs(t) do
        local spell = s.name
        if not s.cond then
            RGMercsLogger.log_debug("\ayGem %d will load \am%s", s.gem, s.name)
        else
            RGMercsLogger.log_debug("\ayGem %d will load \am%s\at or \am%s", s.gem, s.name, s.other)
            if s.cond(caller) then
                RGMercsLogger.log_debug("\ay   - Selected: \am%s", s.name)
            else
                spell = s.other
                RGMercsLogger.log_debug("\ay   - Selected: \am%s", s.other)
            end
        end

        local bestSpell = resolvedActionMap[spell]
        RGMercsLogger.log_debug("\awLoaded spell \at%s\aw for type \am%s\aw from ActionMap",
            (bestSpell and bestSpell.RankName() or "None Found!"), s
            .name)

        spellLoadOut[s.gem] = bestSpell
    end

    return resolvedActionMap, spellLoadOut
end

function Utils.Tooltip(desc)
    ImGui.SameLine()
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 25.0)
        ImGui.Text(desc)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

function Utils.DrawInspectableSpellIcon(iconID, spell)
    local cursor_x, cursor_y = ImGui.GetCursorPos()

    animSpellGems:SetTextureCell(iconID or 0)

    ImGui.DrawTextureAnimation(animSpellGems, ICON_SIZE, ICON_SIZE)

    ImGui.SetCursorPos(cursor_x, cursor_y)

    ImGui.PushID(tostring(iconID) .. spell.Name() .. "_invis_btn")
    ImGui.InvisibleButton(spell.Name(), ImVec2(ICON_SIZE, ICON_SIZE),
        bit32.bor(ImGuiButtonFlags.MouseButtonLeft))
    if ImGui.IsItemHovered() and ImGui.IsMouseReleased(ImGuiMouseButton.Left) then
        spell.Inspect()
    end
    ImGui.PopID()
end

function Utils.RenderLoadoutTable(t)
    if ImGui.BeginTable("Spells", 5, ImGuiTableFlags.Resizable + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Icon', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Gem', (ImGuiTableColumnFlags.WidthFixed), 20.0)
        ImGui.TableSetupColumn('Base Name', (ImGuiTableColumnFlags.WidthFixed), 150.0)
        ImGui.TableSetupColumn('Level', ImGuiTableColumnFlags.None, 20.0)
        ImGui.TableSetupColumn('Rank Name', ImGuiTableColumnFlags.None, 150.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for gem, spell in pairs(t) do
            ImGui.TableNextColumn()
            Utils.DrawInspectableSpellIcon(spell.SpellIcon(), spell)
            ImGui.TableNextColumn()
            ImGui.Text(tostring(gem))
            ImGui.TableNextColumn()
            ImGui.Text(spell.BaseName())
            ImGui.TableNextColumn()
            ImGui.Text(tostring(spell.Level()))
            ImGui.TableNextColumn()
            ImGui.Text(spell.RankName())
        end

        ImGui.EndTable()
    end
end

function Utils.RenderRotationTable(s, n, t, map)
    if ImGui.BeginTable("Rotation_" .. n, 3, ImGuiTableFlags.Resizable + ImGuiTableFlags.Borders) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('ID', ImGuiTableColumnFlags.WidthFixed, 20.0)
        ImGui.TableSetupColumn('Condition Met', ImGuiTableColumnFlags.WidthFixed, 20.0)
        ImGui.TableSetupColumn('Action', ImGuiTableColumnFlags.WidthStretch, 250.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for idx, entry in ipairs(t) do
            ImGui.TableNextColumn()
            ImGui.Text(tostring(idx))
            ImGui.TableNextColumn()
            if entry.cond then
                local pass = entry.cond(s, map[entry.name] or mq.TLO.Spell(entry.name))
                local active = entry.active_cond and
                    entry.active_cond(s, map[entry.name] or mq.TLO.Spell(entry.name)) or false

                if active == true then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                    ImGui.Text(ICONS.FA_SMILE_O)
                elseif pass == true then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.03, 1.0, 0.3, 1.0)
                    ImGui.Text(ICONS.MD_CHECK)
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.3, 0.3, 1.0)
                    ImGui.Text(ICONS.FA_EXCLAMATION)
                end
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 1.0, 1.0, 1.0)
                ImGui.Text(ICONS.MD_CHECK)
            end
            ImGui.PopStyleColor()
            if entry.tooltip then
                Utils.Tooltip(entry.tooltip)
            end
            ImGui.TableNextColumn()
            local mappedAction = map[entry.name]
            if mappedAction then
                if type(mappedAction) == "userdata" then
                    ImGui.Text(entry.name .. " ==> " .. mappedAction.RankName() or mappedAction.Name())
                else
                    ImGui.Text(entry.name .. " ==> " .. mappedAction)
                end
            else
                ImGui.Text(entry.name)
            end
        end

        ImGui.EndTable()
    end
end

function Utils.RenderOptionToggle(id, text, on)
    local toggled = false
    local state   = on
    ImGui.PushID(id .. "_togg_btn")
    if on then
        if ImGui.SmallButton(ICONS.FA_TOGGLE_ON) then
            toggled = true
            state   = false
        end
    else
        if ImGui.SmallButton(ICONS.FA_TOGGLE_OFF) then
            toggled = true
            state   = true
        end
    end
    ImGui.PopID()
    ImGui.SameLine()
    ImGui.Text(text)

    return state, toggled
end

function Utils.RenderOptionNumber(id, text, cur, min, max)
    ImGui.PushID("##num_spin_" .. id)
    local input, changed = ImGui.InputInt(text, cur)
    ImGui.PopID()

    if input > max then input = max end
    if input < min then input = min end

    changed = cur ~= input

    return input, changed
end

function Utils.RenderSettings(settings, defaults)
    local any_pressed = false
    local new_loadout = false
    local pressed = false

    local settingNames = {}
    for k, _ in pairs(settings) do
        table.insert(settingNames, k)
    end

    table.sort(settingNames, function(k1, k2) return defaults[k1].DisplayName < defaults[k2].DisplayName end)

    if ImGui.BeginTable("Options", 2, ImGuiTableFlags.BordersH) then
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.0, 1.0, 1)
        ImGui.TableSetupColumn('Set', (ImGuiTableColumnFlags.WidthFixed), 130.0)
        ImGui.TableSetupColumn('Option', (ImGuiTableColumnFlags.WidthStretch), 150.0)
        ImGui.PopStyleColor()
        ImGui.TableHeadersRow()

        for _, k in ipairs(settingNames) do
            if defaults[k].Type ~= "Custom" then
                ImGui.TableNextColumn()
                if type(settings[k]) == 'boolean' then
                    settings[k], pressed = Utils.RenderOptionToggle(k, "", settings[k])
                    new_loadout = (pressed and (defaults[k].RequiresLoadoutChange or false))
                    any_pressed = any_pressed or pressed
                elseif type(settings[k]) == 'number' then
                    settings[k], pressed = Utils.RenderOptionNumber(k, "", settings[k], defaults[k].Min,
                        defaults[k].Max)
                    new_loadout = (pressed and (defaults[k].RequiresLoadoutChange or false))
                    any_pressed = any_pressed or pressed
                end
                ImGui.TableNextColumn()
                ImGui.Text((defaults[k].DisplayName or "None"))
                Utils.Tooltip(defaults[k].Tooltip)
            end
        end
        ImGui.EndTable()
    end

    return settings, any_pressed, new_loadout
end

function Utils.LoadSpellLoadOut(t)
    local selectedRank = ""

    for gem, spell in pairs(t) do
        if mq.TLO.Me.SpellRankCap() > 1 then
            selectedRank = spell.RankName()
        else
            selectedRank = spell.BaseName()
        end

        if mq.TLO.Me.Gem(gem)() ~= selectedRank then
            Utils.MemorizeSpell(gem, selectedRank)
        end
    end
end

mq.event('Being Memo', "Beginning to memorize #1#...", function(spell)
    Memorizing = true
end)

mq.event('End Memo', "You have finished memorizing #1#", function(spell)
    Memorizing = false
end)

mq.event('Abort Memo', "Aborting memorization of spell.", function()
    Memorizing = false
end)

return Utils
