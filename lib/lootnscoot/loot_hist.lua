--[[
	Title: Looted
	Author: Grimmier
	Description:

	Simple output console for looted items and links. 
	can be run standalone or imported into other scripts. 

	Standalone Mode
	/lua run looted start 		-- start in standalone mode
	/lua run looted hidenames 	-- will start with player names hidden and class names used instead.

	Standalone Commands
	/looted show 				-- toggles show hide on window.
	/looted stop 				-- exit sctipt.
	/looted reported			-- prints out a report of items looted by who and qty. 
	/looted hidenames 			-- Toggles showing names or class names. default is class.

	Or you can Import into another Lua.

	Import Mode

	1. place in your scripts folder name it looted.Lua.
	2. local guiLoot = require('looted')
	3. guiLoot.imported = true
	4. guiLoot.openGUI = true|false to show or hide window.
	5. guiLoot.hideNames = true|false toggle masking character names default is true (class).

	* You can export menu items from your lua into the console. 
	* Do this by passing your menu into guiLoot.importGUIElements table. 

	Follow this example export.

	local function guiExport()
		-- Define a new menu element function
		local function myCustomMenuElement()
			if ImGui.BeginMenu('My Custom Menu') then
				-- Add menu items here
				_, guiLoot.console.autoScroll = ImGui.MenuItem('Auto-scroll', nil, guiLoot.console.autoScroll)
				local activated = false
				activated, guiLoot.hideNames = ImGui.MenuItem('Hide Names', activated, guiLoot.hideNames)
				if activated then
					if guiLoot.hideNames then
						guiLoot.console:AppendText("\ay[Looted]\ax Hiding Names\ax")
					else
						guiLoot.console:AppendText("\ay[Looted]\ax Showing Names\ax")
					end
				end
				local act = false
				act, guiLoot.showLinks = ImGui.MenuItem('Show Links', act, guiLoot.showLinks)
				if act then
					guiLoot.linkdb = mq.TLO.Plugin('mq2linkdb').IsLoaded()
					if guiLoot.showLinks then
						if not guiLoot.linkdb then guiLoot.loadLDB() end
						guiLoot.console:AppendText("\ay[Looted]\ax Link Lookup Enabled\ax")
					else
						guiLoot.console:AppendText("\ay[Looted]\ax Link Lookup Disabled\ax")
					end
				end
				ImGui.EndMenu()
			end
		end
		-- Add the custom menu element function to the importGUIElements table
		table.insert(guiLoot.importGUIElements, myCustomMenuElement)
	end

]]
local mq = require('mq')
local imgui = require('ImGui')
local actor = require('actors')
local Icons = require('mq.ICONS')
local theme, settings = {}, {}
local script = 'Looted'
local ColorCount, ColorCountConf, StyleCount, StyleCountConf = 0, 0, 0, 0
local ColorCountRep, StyleCountRep = 0,0
local openConfigGUI, locked, zoom = false, false, false
local themeFile = mq.configDir .. '/MyThemeZ.lua'
local configFile = mq.configDir .. '/MyUI_Configs.lua'
local ZoomLvl = 1.0
local showReport = false
local ThemeName = 'Default'
local gIcon = Icons.MD_SETTINGS
local globalNewIcon = Icons.FA_GLOBE
local globeIcon = Icons.FA_GLOBE
local changed = false
local txtBuffer = {}
local defaults = {
	LoadTheme = 'Default',
	Scale = 1.0,
	Zoom = false,
	txtAutoScroll = true,
	bottomPosition = 0,
	lastScrollPos = 0,
}

local guiLoot = {
	SHOW = false,
	openGUI = false,
	shouldDrawGUI = false,
	imported = true,
	hideNames = false,
	showLinks = false,
	linkdb = false,
	importGUIElements = {},

	---@type ConsoleWidget
	console = nil,
	localEcho = false,
	resetPosition = false,
	recordData = true,
	UseActors = true,
	winFlags = bit32.bor(ImGuiWindowFlags.MenuBar)
}

local lootTable = {}

---@param names boolean
---@param links boolean
---@param record boolean
---@param imported boolean
---@param useactors boolean
---@param caller string
function guiLoot.GetSettings(names,links,record,imported,useactors,caller)
	guiLoot.imported =imported
	guiLoot.hideNames = names
	guiLoot.showLinks = links
	guiLoot.recordData = record
	guiLoot.UseActors = useactors
	guiLoot.caller = caller
end

function guiLoot.loadLDB()
	if guiLoot.linkdb or guiLoot.UseActors then return end
	local sWarn = "MQ2LinkDB not loaded, Can't lookup links.\n Attempting to Load MQ2LinkDB"
	guiLoot.console:AppendText(sWarn)
	print(sWarn)
	mq.cmdf("/plugin mq2linkdb noauto")
	guiLoot.linkdb = mq.TLO.Plugin('mq2linkdb').IsLoaded()
end

-- draw any imported exported menus from outside this script.
local function drawImportedMenu()
	for _, menuElement in ipairs(guiLoot.importGUIElements) do
		menuElement()
	end
end

function guiLoot.ReportLoot()
	if guiLoot.recordData then
		showReport = true
		guiLoot.console:AppendText("\ay[Looted]\at[Loot Report]")
		for looter, lootData in pairs(lootTable) do
			guiLoot.console:AppendText("\at[%s] \ax: ", looter)
			for item, data in pairs(lootData) do
				local itemName = item
				local itemLink = data["Link"]
				local itemCount = data["Count"]
				guiLoot.console:AppendText("\ao\t%s \ax: \ax(%d)", itemLink, itemCount)
			end
		end
	else
		guiLoot.recordData = true
		guiLoot.console:AppendText("\ay[Looted]\ag[Recording Data Enabled]\ax Check back later for Data.")
	end
end

---comment Check to see if the file we want to work on exists.
---@param name string -- Full Path to file
---@return boolean -- returns true if the file exists and false otherwise
local function File_Exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end


---comment Writes settings from the settings table passed to the setting file (full path required)
-- Uses mq.pickle to serialize the table and write to file
---@param file string -- File Name and path
---@param settings table -- Table of settings to write
local function writeSettings(file, settings)
	mq.pickle(file, settings)
end

-- local function loadTheme()
-- 	if File_Exists(themeFile) then
-- 		theme = dofile(themeFile)
-- 		else
-- 		theme = require('themes')
-- 	end
-- 	ThemeName = theme.LoadTheme or 'notheme'
-- end

local function loadSettings()
	local temp = {}
	if not File_Exists(configFile) then
		mq.pickle(configFile, defaults)
		loadSettings()
		else
        
		-- Load settings from the Lua config file
		temp = {}
		settings = dofile(configFile)
		if not settings[script] then
			settings[script] = {}
		settings[script] = defaults end
		temp = settings[script]
	end
    
	-- loadTheme()
    
	if settings[script].locked == nil then
		settings[script].locked = false
	end
    
	if settings[script].Scale == nil then
		settings[script].Scale = 1
	end
    
	if settings[script].txtAutoScroll == nil then
		settings[script].txtAutoScroll = true
	end
	
	if settings[script].bottomPosition == nil then
		settings[script].bottomPosition = 20
	end
	
	if settings[script].lastScrollPos == nil then
		settings[script].lastScrollPos = 20
	end
	
	if settings[script].Zoom == nil then
		settings[script].Zoom = false
	end

	if not settings[script].LoadTheme then
		settings[script].LoadTheme = theme.LoadTheme
	end
	zoom = settings[script].Zoom
	locked = settings[script].locked
	ZoomLvl = settings[script].Scale
	ThemeName = settings[script].LoadTheme
    
	writeSettings(configFile, settings)
    
	temp = settings[script]
end
-- ---comment
-- ---@param themeName string -- name of the theme to load form table
-- ---@return integer, integer -- returns the new counter values 
-- local function DrawTheme(themeName)
-- 	local StyleCounter = 0
-- 	local ColorCounter = 0
-- 	for tID, tData in pairs(theme.Theme) do
-- 		if tData.Name == themeName then
-- 			for pID, cData in pairs(theme.Theme[tID].Color) do
-- 				ImGui.PushStyleColor(pID, ImVec4(cData.Color[1], cData.Color[2], cData.Color[3], cData.Color[4]))
-- 				ColorCounter = ColorCounter + 1
-- 			end
-- 			if tData['Style'] ~= nil then
-- 				if next(tData['Style']) ~= nil then
                    
-- 					for sID, sData in pairs (theme.Theme[tID].Style) do
-- 						if sData.Size ~= nil then
-- 							ImGui.PushStyleVar(sID, sData.Size)
-- 							StyleCounter = StyleCounter + 1
-- 							elseif sData.X ~= nil then
-- 							ImGui.PushStyleVar(sID, sData.X, sData.Y)
-- 							StyleCounter = StyleCounter + 1
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return ColorCounter, StyleCounter
-- end

function guiLoot.GUI()
	if not guiLoot.openGUI then return end
	local windowName = 'Looted Items##'..mq.TLO.Me.DisplayName()
	ImGui.SetNextWindowSize(260, 300, ImGuiCond.FirstUseEver)
	--imgui.PushStyleVar(ImGuiStyleVar.WindowPadding, ImVec2(1, 0));
	-- ColorCount, StyleCount = DrawTheme(ThemeName)
	if guiLoot.imported then windowName = 'Looted Items Local##Imported_'..mq.TLO.Me.DisplayName() end
	guiLoot.openGUI, show = ImGui.Begin(windowName, nil, guiLoot.winFlags)
	if not show then
		-- if ColorCount > 0 then ImGui.PopStyleColor(ColorCount) end
		-- if StyleCount > 0 then ImGui.PopStyleVar(StyleCount) end
		imgui.End()
		--imgui.PopStyleVar()
		-- guiLoot.shouldDrawGUI = false
		return show
	end
	
	-- Main menu bar
	if imgui.BeginMenuBar() then
		-- ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 4,7)
		if imgui.BeginMenu('Options') then
			local activated = false
			activated, guiLoot.console.autoScroll = imgui.MenuItem('Auto-scroll', nil, guiLoot.console.autoScroll)
			activated, openConfigGUI = imgui.MenuItem('Config', nil, openConfigGUI)
			activated, guiLoot.hideNames = imgui.MenuItem('Hide Names', nil, guiLoot.hideNames)
			activated, zoom = imgui.MenuItem('Zoom', nil, zoom)
			if activated then
				if guiLoot.hideNames then
					guiLoot.console:AppendText("\ay[Looted]\ax Hiding Names\ax")
				else
					guiLoot.console:AppendText("\ay[Looted]\ax Showing Names\ax")
				end
			end
		if not guiLoot.UseActors then
			activated, guiLoot.showLinks = imgui.MenuItem('Show Links', nil, guiLoot.showLinks)
			if activated then
				guiLoot.linkdb = mq.TLO.Plugin('mq2linkdb').IsLoaded()
				if guiLoot.showLinks then
					if not guiLoot.linkdb then guiLoot.loadLDB() end
					guiLoot.console:AppendText("\ay[Looted]\ax Link Lookup Enabled\ax")
				else
					guiLoot.console:AppendText("\ay[Looted]\ax Link Lookup Disabled\ax")
				end
			end
		end
			activated, guiLoot.recordData = imgui.MenuItem('Record Data', nil, guiLoot.recordData)
			if activated then
				if guiLoot.recordData then
					guiLoot.console:AppendText("\ay[Looted]\ax Recording Data\ax")
				else
					lootTable = {}
					guiLoot.console:AppendText("\ay[Looted]\ax Data Cleared\ax")
				end
			end

			if imgui.MenuItem('View Report') then
				guiLoot.ReportLoot()
				showReport = true
			end

			imgui.Separator()

			if imgui.MenuItem('Reset Position') then
				guiLoot.resetPosition = true
			end

			if imgui.MenuItem('Clear Console') then
				guiLoot.console:Clear()
				txtBuffer = {}
			end

			imgui.Separator()

			if imgui.MenuItem('Close Console') then
				guiLoot.openGUI = false
			end

			if imgui.MenuItem('Exit') then
				if not guiLoot.imported then
					guiLoot.SHOW = false
				else
					guiLoot.openGUI = false
					guiLoot.console:AppendText("\ay[Looted]\ax Can Not Exit in Imported Mode.\ar Closing Window instead.\ax")
				end
			end

			imgui.Separator()

			imgui.Spacing()

			imgui.EndMenu()
		end
		-- inside main menu bar draw section
		if guiLoot.imported and #guiLoot.importGUIElements > 0 then
			drawImportedMenu()
		end
		if imgui.BeginMenu('Hide Corpse') then
			if imgui.MenuItem('alwaysnpc') then
				mq.cmd('/hidecorpse alwaysnpc')
			end
			if imgui.MenuItem('looted') then
				mq.cmd('/hidecorpse looted')
			end
			if imgui.MenuItem('all') then
				mq.cmd('/hidecorpse all')
			end
			if imgui.MenuItem('none') then
				mq.cmd('/hidecorpse none')
			end
			imgui.EndMenu()
		end
		imgui.EndMenuBar()

		-- ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 4,3)
	end
	-- End of menu bar
	ImGui.SetWindowFontScale(ZoomLvl)
	if zoom then
		local footerHeight = 30
		local contentSizeX, contentSizeY = ImGui.GetContentRegionAvail()
		contentSizeY = contentSizeY - footerHeight
			
		ImGui.BeginChild("ZoomScrollRegion##"..script, ImVec2(contentSizeX, contentSizeY), ImGuiWindowFlags.HorizontalScrollbar)
		ImGui.BeginTable('##channelID_'..script, 1, bit32.bor(ImGuiTableFlags.NoBordersInBody, ImGuiTableFlags.RowBg))
		ImGui.TableSetupColumn("##txt"..script, ImGuiTableColumnFlags.NoHeaderLabel)
		--- draw rows ---
			
		ImGui.TableNextRow()
		ImGui.TableSetColumnIndex(0)
		ImGui.SetWindowFontScale(ZoomLvl)
			
		for line, data in pairs(txtBuffer) do
			-- ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(data.color[1], data.color[2], data.color[3], data.color[4]))
			if ImGui.Selectable("##selectable" .. line, false, ImGuiSelectableFlags.None) then end
			ImGui.SameLine()
			ImGui.TextWrapped(data.Text)
			if ImGui.IsItemHovered() and ImGui.IsKeyDown(ImGuiMod.Ctrl) and ImGui.IsKeyDown(ImGuiKey.C) then
				ImGui.LogToClipboard()
				ImGui.LogText(data.Text)
				ImGui.LogFinish()
			end
			ImGui.TableNextRow()
			ImGui.TableSetColumnIndex(0)
			-- ImGui.PopStyleColor()
		end
			
		ImGui.SetWindowFontScale(1)
			
		--Scroll to the bottom if autoScroll is enabled
		local autoScroll = settings[script].txtAutoScroll
		if autoScroll then
			ImGui.SetScrollHereY()
			settings[script].bottomPosition = ImGui.GetCursorPosY()
		end
			
		local bottomPosition = settings[script].bottomPosition or 0
		-- Detect manual scroll
		local lastScrollPos = settings[script].lastScrollPos or 0
		local scrollPos = ImGui.GetScrollY()
			
		if scrollPos < lastScrollPos then
			settings[script].txtAutoScroll = false  -- Turn off autoscroll if scrolled up manually
			elseif scrollPos >= bottomPosition-(30 * ZoomLvl) then
			settings[script].txtAutoScroll = true
		end
			
		lastScrollPos = scrollPos
		settings[script].lastScrollPos = lastScrollPos
			
		ImGui.EndTable()
			
		ImGui.EndChild()
		-- if ColorCount > 0 then ImGui.PopStyleColor(ColorCount) end
		-- if StyleCount > 0 then ImGui.PopStyleVar(StyleCount)  end
		ImGui.SetWindowFontScale(1)
		ImGui.End()
		else
		local footerHeight = imgui.GetStyle().ItemSpacing.y + imgui.GetFrameHeightWithSpacing()

		if imgui.BeginPopupContextWindow() then
			if imgui.Selectable('Clear') then
				guiLoot.console:Clear()
				txtBuffer = {}
			end
			imgui.EndPopup()
		end

		-- Reduce spacing so everything fits snugly together
		-- imgui.PushStyleVar(ImGuiStyleVar.ItemSpacing, ImVec2(0, 0))
		local contentSizeX, contentSizeY = imgui.GetContentRegionAvail()
		contentSizeY = contentSizeY - footerHeight

		guiLoot.console:Render(ImVec2(contentSizeX,0))
		-- imgui.PopStyleVar(1)
		-- if ColorCount > 0 then ImGui.PopStyleColor(ColorCount) end
		-- if StyleCount > 0 then ImGui.PopStyleVar(StyleCount)  end
		ImGui.SetWindowFontScale(1)
		ImGui.End()
	end

end

local function evalRule(item)
	if string.find(item,'Destroy') then
		ImGui.TextColored(0.860, 0.104, 0.104, 1.000, Icons.MD_DELETE)
		if ImGui.IsItemHovered() then
			ImGui.BeginTooltip()
			ImGui.Text("Destroy Item")
			ImGui.EndTooltip()
		end
	elseif string.find(item,'Quest') then
		ImGui.TextColored(1.000, 0.914, 0.200, 1.000, Icons.MD_SEARCH)
		if ImGui.IsItemHovered() then
			ImGui.BeginTooltip()
			ImGui.Text("Quest Item")
			ImGui.EndTooltip()
		end
	elseif string.find(item,"Tribute") then
		ImGui.TextColored(0.991, 0.506, 0.230, 1.000, Icons.FA_GIFT)
		if ImGui.IsItemHovered() then
			ImGui.BeginTooltip()
			ImGui.Text("Tribute Item")
			ImGui.EndTooltip()
		end
	elseif string.find(item, 'Sell') then
		ImGui.TextColored(0, 1, 0, 1, Icons.MD_ATTACH_MONEY)
		if ImGui.IsItemHovered() then
			ImGui.BeginTooltip()
			ImGui.Text("Sell Item")
			ImGui.EndTooltip()
		end
	elseif string.find(item, 'Keep') then
		ImGui.TextColored(0.916, 0.094, 0.736, 1.000, Icons.MD_FAVORITE_BORDER)
		if ImGui.IsItemHovered() then
			ImGui.BeginTooltip()
			ImGui.Text("Keep Item")
			ImGui.EndTooltip()
		end
	elseif string.find(item, 'Unknown') then
		ImGui.TextColored(0.5, 0.5, 0.5, 1.000, Icons.FA_QUESTION)
		if ImGui.IsItemHovered() then
			ImGui.BeginTooltip()
			ImGui.Text("Not Set")
			ImGui.EndTooltip()
		end
	else
		ImGui.Text(item)
	end
end

local function lootedReport_GUI()
--- Report Window
	if not showReport then return end
	-- ColorCountRep, StyleCountRep = DrawTheme(ThemeName)
	ImGui.SetNextWindowSize(300,200, ImGuiCond.Appearing)
	if changed and mq.TLO.Plugin('mq2dannet').IsLoaded() and guiLoot.caller == 'lootnscoot' then
		mq.cmd('/dgae /lootutils reload')
		changed = false
	end
	local openRepGUI, showRepGUI = ImGui.Begin("Loot Report##"..script, showReport, bit32.bor( ImGuiWindowFlags.NoCollapse))
	if not showRepGUI then
		-- if ColorCountRep > 0 then ImGui.PopStyleColor(ColorCountRep) end
		-- if StyleCountRep > 0 then ImGui.PopStyleVar(StyleCountRep) end
		ImGui.SetWindowFontScale(1)
		ImGui.End()
		return showRepGUI
	end
	if not openRepGUI then
		-- if ColorCountRep > 0 then ImGui.PopStyleColor(ColorCountRep) end
		-- if StyleCountRep > 0 then ImGui.PopStyleVar(StyleCountRep) end
		ImGui.SetWindowFontScale(1)
		ImGui.End()
		showReport = false
		return
	end
	if showReport then
		ImGui.SetWindowFontScale(ZoomLvl)
		local sizeX, sizeY = ImGui.GetContentRegionAvail()
		ImGui.BeginTable('##LootReport', 4, bit32.bor(ImGuiTableFlags.Borders,ImGuiTableFlags.ScrollY,ImGuiTableFlags.Resizable, ImGuiTableFlags.RowBg), ImVec2(sizeX, sizeY-10))
		ImGui.TableSetupScrollFreeze(0, 1)
		ImGui.TableSetupColumn("Looter", ImGuiTableColumnFlags.None, 100)
		ImGui.TableSetupColumn("Item", ImGuiTableColumnFlags.None,200)
		ImGui.TableSetupColumn("Count", ImGuiTableColumnFlags.NoResize, 50)
		ImGui.TableSetupColumn("Tagged", ImGuiTableColumnFlags.NoResize, 75)
		ImGui.TableHeadersRow()
		if ImGui.BeginPopupContextItem() then
			ImGui.SeparatorText("Tags:")
			ImGui.TextColored(0.523, 0.797, 0.944, 1.000,globeIcon)
			ImGui.SameLine()
			ImGui.Text('Global Item')
			ImGui.TextColored(0.898, 0.777, 0.000, 1.000,Icons.MD_STAR)
			ImGui.SameLine()
			ImGui.Text('Changed Rule')
			ImGui.TextColored(0.860, 0.104, 0.104, 1.000, Icons.MD_DELETE)
			ImGui.SameLine()
			ImGui.Text("Destroy")
			ImGui.TextColored(1.000, 0.914, 0.200, 1.000, Icons.MD_SEARCH)
			ImGui.SameLine()
			ImGui.Text("Quest")
			ImGui.TextColored(0.991, 0.506, 0.230, 1.000, Icons.FA_GIFT)
			ImGui.SameLine()
			ImGui.Text("Tribute")
			ImGui.TextColored(0, 1, 0, 1, Icons.MD_ATTACH_MONEY)
			ImGui.SameLine()
			ImGui.Text("Sell")
			ImGui.TextColored(0.916, 0.094, 0.736, 1.000, Icons.MD_FAVORITE_BORDER)
			ImGui.SameLine()
			ImGui.Text("Keep")
			ImGui.TextColored(0.5, 0.5, 0.5, 1.000, Icons.FA_QUESTION)
			ImGui.SameLine()
			ImGui.Text("Unknown")
			ImGui.EndPopup()
		end
		local row = 1
		for looter, lootData in pairs(lootTable) do
			for item, data in pairs(lootData) do
				local itemName = item
				local itemLink = data["Link"]
				local itemCount = data["Count"]
				local itemEval = data["Eval"] or 'Unknown'
				local itemNewEval = data["NewEval"] or 'NONE'
				local globalItem = false
				local globalNew = false

				globalItem = string.find(itemEval,'Global') ~= nil
				if globalItem then
					itemName = string.gsub(itemName, 'Global ', '')
				end
				globalNew = string.find(itemNewEval,'Global') ~= nil
				local rowID = string.format("%s_%d",item,row)
				ImGui.PushID(rowID)  
			
				ImGui.TableNextRow()
				ImGui.TableSetColumnIndex(0)
				ImGui.Text(looter)
				ImGui.TableSetColumnIndex(1)
				-- ImGui.BeginGroup()
				if string.find(itemName, "*") then
					itemName = string.gsub(itemName, "*", "")
				end
				if ImGui.Selectable(itemName .. "##" .. rowID, false, ImGuiSelectableFlags.SpanAllColumns) then
					mq.cmdf('/executelink %s', itemLink)
				end
				-- lootnscoot context menu for changing item evaluation rule
				if guiLoot.imported and mq.TLO.Lua.Script(guiLoot.caller).Status.Equal('RUNNING')() then
					if ImGui.BeginPopupContextItem(rowID) then
						if string.find(item, "*") then
							itemName = string.gsub(item, "*", '') 
						end
						ImGui.Text(itemName)
						ImGui.Separator()
						ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(1, 1, 0, 0.75))
						if ImGui.BeginMenu('Normal Item Settings##'..rowID) then
							local tmpName = string.gsub(itemName, "*", "")
							if ImGui.Selectable('Keep##'..rowID) then
								mq.cmdf('/lootutils keep "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Keep'
								changed = true
							end
							if ImGui.Selectable('Quest##'..rowID) then
								mq.cmdf('/lootutils quest "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Quest'
								changed = true
							end
							if ImGui.Selectable('Sell##'..rowID) then
								mq.cmdf('/lootutils sell "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Sell'
								changed = true
							end
							if ImGui.Selectable('Tribute##'..rowID) then
								mq.cmdf('/lootutils tribute "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Tribute'
								changed = true
							end
							if ImGui.Selectable('Destroy##'..rowID) then
								mq.cmdf('/lootutils destroy "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Destroy'
								changed = true
							end
							ImGui.EndMenu()
						end
						ImGui.PopStyleColor()
						ImGui.PushStyleColor(ImGuiCol.Text, ImVec4(0.523, 0.797, 0.944, 1.000))
						if ImGui.BeginMenu('Global Item Settings##'..rowID) then
							local tmpName = string.gsub(itemName, "*", "")
							if ImGui.Selectable('Global Keep##'..rowID) then
								mq.cmdf('/lootutils globalitem keep "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Global Keep'
								changed = true
							end
							if ImGui.Selectable('Global Quest##'..rowID) then
								mq.cmdf('/lootutils globalitem quest "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Global Quest'
								changed = true
							end
							if ImGui.Selectable('Global Sell##'..rowID) then
								mq.cmdf('/lootutils globalitem sell "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Global Sell'
								changed = true
							end
							if ImGui.Selectable('Global Tribute##'..rowID) then
								mq.cmdf('/lootutils globalitem tribute "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Global Tribute'
								changed = true
							end
							if ImGui.Selectable('Global Destroy##'..rowID) then
								mq.cmdf('/lootutils globalitem destroy "%s"', tmpName)
								lootTable[looter][item]["NewEval"] = 'Global Destroy'
								changed = true
							end
							ImGui.EndMenu()
						end
						ImGui.PopStyleColor()
						ImGui.EndPopup()
					end
				else
					if ImGui.IsItemHovered() then
						ImGui.BeginTooltip()
						ImGui.Text("Left Click to open item link")
						ImGui.EndTooltip()
					end
				end
				ImGui.TableSetColumnIndex(2)
				ImGui.Text("\t%d", itemCount)
				if ImGui.IsItemHovered() then
					ImGui.BeginTooltip()
					if string.find(itemEval, 'Unknown') then
						ImGui.Text("%s Looted: %d",looter, itemCount)
					else
						ImGui.Text("%s %sing: %d",looter, itemEval, itemCount)
					end
					ImGui.EndTooltip()
				end
				ImGui.TableSetColumnIndex(3)
				if itemEval == itemNewEval then itemNewEval = 'NONE' end
				if itemNewEval ~= 'NONE' then
					ImGui.TextColored(0.898, 0.777, 0.000, 1.000,Icons.MD_STAR)
					if ImGui.IsItemHovered() then
						ImGui.BeginTooltip()
						ImGui.TextColored(0.6, 0.6, 0.6, 1,"Old Rule: %s",itemEval)
						ImGui.TextColored(1.000, 0.914, 0.200, 1.000,"New Rule: %s", itemNewEval)
						ImGui.EndTooltip()
					end
					ImGui.SameLine()
					if globalNew then
						ImGui.TextColored(0.523, 0.797, 0.944, 1.000,globalNewIcon)
						if ImGui.IsItemHovered() then
							ImGui.BeginTooltip()
							ImGui.Text("Global Rule")
							ImGui.EndTooltip()
						end
						ImGui.SameLine()
					end
					ImGui.SameLine()
					evalRule(itemNewEval)
				else
					if globalItem then
						ImGui.TextColored(0.523, 0.797, 0.944, 1.000,globeIcon)
						if ImGui.IsItemHovered() then
							ImGui.BeginTooltip()
							ImGui.Text("Global Item")
							ImGui.EndTooltip()
						end
						ImGui.SameLine()
					end
					evalRule(itemEval)
				end
				-- ImGui.Text(data['Eval'])
				
				ImGui.PopID() 
				row = row + 1
			end
		end
	
		ImGui.EndTable()
		
		-- if ColorCountRep > 0 then ImGui.PopStyleColor(ColorCountRep) end
		-- if StyleCountRep > 0 then ImGui.PopStyleVar(StyleCountRep) end
		ImGui.SetWindowFontScale(1)
		ImGui.End()
	end
end

local function lootedConf_GUI(open)
	if not openConfigGUI then return end
	-- ColorCountConf = 0
	-- StyleCountConf = 0
	-- ColorCountConf, StyleCountConf = DrawTheme(ThemeName)
	open, openConfigGUI = ImGui.Begin("Looted Conf##"..script, open, bit32.bor(ImGuiWindowFlags.None, ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoCollapse))
	ImGui.SetWindowFontScale(ZoomLvl)
	if not openConfigGUI then
		openConfigGUI = false
		open = false
		-- if StyleCountConf > 0 then ImGui.PopStyleVar(StyleCountConf) end
		-- if ColorCountConf > 0 then ImGui.PopStyleColor(ColorCountConf) end
		ImGui.SetWindowFontScale(1)
		ImGui.End()
		return open
	end
	-- ImGui.SameLine()
	-- ImGui.SeparatorText('Theme')
	-- ImGui.Text("Cur Theme: %s", ThemeName)
	-- -- Combo Box Load Theme
    
	-- if ImGui.BeginCombo("Load Theme##"..script, ThemeName) then
	-- 	ImGui.SetWindowFontScale(ZoomLvl)
	-- 	for k, data in pairs(theme.Theme) do
	-- 		local isSelected = data.Name == ThemeName
	-- 		if ImGui.Selectable(data.Name, isSelected) then
	-- 			theme.LoadTheme = data.Name
	-- 			ThemeName = theme.LoadTheme
	-- 			settings[script].LoadTheme = ThemeName
	-- 		end
	-- 	end
	-- 	ImGui.EndCombo()
	-- end
    
	-- if ImGui.Button('Reload Theme File') then
	-- 	loadTheme()
	-- end
	--------------------- Sliders ----------------------
	ImGui.SeparatorText('Scaling')
	-- Slider for adjusting zoom level
	local tmpZoom = ZoomLvl
	if ZoomLvl then
		tmpZoom = ImGui.SliderFloat("Text Scale##"..script, tmpZoom, 0.5, 2.0)
	end
	if ZoomLvl ~= tmpZoom then
		ZoomLvl = tmpZoom
	end
    
    
	ImGui.SeparatorText('Save and Close')
    
	if ImGui.Button('Save and Close##'..script) then
		openConfigGUI = false
		settings = dofile(configFile)
		settings[script].Scale = ZoomLvl
		settings[script].LoadTheme = ThemeName
        
		writeSettings(configFile,settings)
	end
	-- if StyleCountConf > 0 then ImGui.PopStyleVar(StyleCountConf) end
	-- if ColorCountConf > 0 then ImGui.PopStyleColor(ColorCountConf) end
	ImGui.SetWindowFontScale(1)
	ImGui.End()
    
end

local function addRule(who, what ,link, eval)
	if not lootTable[who] then
		lootTable[who] = {}
	end
	if not lootTable[who][what] then
		lootTable[who][what] = {Count = 0}
	end
	lootTable[who][what]["Link"] = link
	lootTable[who][what]["Eval"] = eval or 'Unknown'
	lootTable[who][what]["Count"] = (lootTable[who][what]["Count"] or 0) + 1
end

---comment -- Checks for the last ID number in the table passed. returns the NextID
---@param table table -- the table we want to look up ID's in
---@return number -- returns the NextID that doesn't exist in the table yet.
local function getNextID(table)
	local maxChannelId = 0
	for channelId, _ in pairs(table) do
		local numericId = tonumber(channelId)
		if numericId and numericId > maxChannelId then
			maxChannelId = numericId
		end
	end
	return maxChannelId + 1
end

function guiLoot.RegisterActor()
	guiLoot.actor = actor.register('looted', function(message)
		local lootEntry = message()
		for _,item in ipairs(lootEntry.Items) do
			local link = item.Link
			local what = item.Name
			local eval = item.Eval
			local who = lootEntry.LootedBy
			if guiLoot.hideNames then
				if who ~= mq.TLO.Me() then who = mq.TLO.Spawn(string.format("%s", who)).Class.ShortName() else who = mq.TLO.Me.Class.ShortName() end
			end

			local text = string.format('\ao[%s] \at%s \ax%s %s (%s)', lootEntry.LootedAt, who, item.Action, link, lootEntry.ID)
			if item.Action == 'Destroyed' then
				text = string.format('\ao[%s] \at%s \ar%s \ax%s \ax(%s)', lootEntry.LootedAt, who, string.upper(item.Action), link, lootEntry.ID)
			elseif item.Action == 'Looted' then
				text = string.format('\ao[%s] \at%s \ag%s \ax%s \ax(%s)', lootEntry.LootedAt, who, item.Action, link, lootEntry.ID)
			end
			guiLoot.console:AppendText(text)
			local line = string.format('[%s] %s %s %s CorpseID (%s)', lootEntry.LootedAt, who, item.Action, what, lootEntry.ID)
			local i = getNextID(txtBuffer)
			-- ZOOM Console hack
			if i > 1 then
				if txtBuffer[i-1].Text == '' then i = i-1 end
			end
			-- Add the new line to the buffer
			txtBuffer[i] = {
				Text = line
			}
			-- cleanup zoom buffer
			-- Check if the buffer exceeds 1000 lines
			local bufferLength = #txtBuffer
			if bufferLength > 1000 then
				-- Remove excess lines
				for j = 1, bufferLength - 1000 do
					table.remove(txtBuffer, 1)
				end
			end
			-- do we want to record loot data?
			if guiLoot.recordData and item.Action == 'Looted' then
				addRule(who, what, link, eval)
			end
			if guiLoot.recordData and item.Action == 'Destroyed' then
				what = what ..'*'
				link = link ..' *Destroyed*'
				addRule(who, what, link, eval)
			end
		end
	end)
end

function guiLoot.EventLoot(line, who, what)
	local link = ''
	if guiLoot.console ~= nil then
		link = mq.TLO.FindItem(what).ItemLink('CLICKABLE')() or what
		if guiLoot.linkdb and guiLoot.showLinks then
			link = mq.TLO.LinkDB(string.format("=%s",what))() or link
		elseif not guiLoot.linkdb and guiLoot.showLinks then
			guiLoot.loadLDB()
			link = mq.TLO.LinkDB(string.format("=%s",what))() or link
		end
		if guiLoot.hideNames then
			if who ~= 'You' then who = mq.TLO.Spawn(string.format("%s",who)).Class.ShortName() else who = mq.TLO.Me.Class.ShortName() end
		end
		local text = string.format('\ao[%s] \at%s \axLooted %s', mq.TLO.Time(), who, link)
		guiLoot.console:AppendText(text)
		local zLine = string.format('[%s] %s Looted %s', mq.TLO.Time(), who, what)
		local i = getNextID(txtBuffer)
		-- ZOOM Console hack
		if i > 1 then
			if txtBuffer[i-1].Text == '' then i = i-1 end
		end
		-- Add the new line to the buffer
		txtBuffer[i] = {
			Text = zLine
		}
		-- cleanup zoom buffer
		-- Check if the buffer exceeds 1000 lines
		local bufferLength = #txtBuffer
		if bufferLength > 1000 then
			-- Remove excess lines
			for j = 1, bufferLength - 1000 do
				table.remove(txtBuffer, 1)
			end
		end
		-- do we want to record loot data?
		if not guiLoot.recordData then return end
		addRule(who, what, link, "Keep")
	end
end

local function bind(...)
	local args = {...}
	if args[1] == 'show' then
		guiLoot.openGUI = not guiLoot.openGUI
		guiLoot.shouldDrawGUI = not guiLoot.shouldDrawGUI
	elseif args[1] == 'stop' then
		guiLoot.SHOW = false
	elseif args[1] == 'clear' then
		lootTable = {}
	elseif args[1] == 'report' then
		guiLoot.openGUI = true
		guiLoot.shouldDrawGUI = true
		guiLoot.ReportLoot()
	elseif args[1] == 'hidenames' then
		guiLoot.hideNames = not guiLoot.hideNames
		if guiLoot.hideNames then
			guiLoot.console:AppendText("\ay[Looted]\ax Hiding Names\ax")
		else
			guiLoot.console:AppendText("\ay[Looted]\ax Showing Names\ax")
		end
	end
end

function guiLoot.init(actors, imported, caller)
	guiLoot.imported = imported
	guiLoot.UseActors = actors
	guiLoot.caller = caller
	if not actors then
	guiLoot.linkdb = mq.TLO.Plugin('mq2linkdb').IsLoaded()
	else guiLoot.linkdb = false end
	-- if imported set show to true.
	if guiLoot.imported then
		guiLoot.SHOW = true
		-- print("Imported Mode")
		mq.imgui.init('importedLootItemsGUI', guiLoot.GUI)
	else
		-- print("Normal Mode")
		mq.imgui.init('lootItemsGUI', guiLoot.GUI)
	end
	mq.imgui.init('lootConfigGUI', lootedConf_GUI)
	mq.imgui.init('lootReportGui', lootedReport_GUI)
	-- setup events
	if guiLoot.UseActors then
		-- print("Using Actors")
		guiLoot.RegisterActor()
		guiLoot.linkdb = false
	else
		-- print("Using Events")
		mq.event('echo_Loot', '--#1# ha#*# looted a #2#.#*#', guiLoot.EventLoot)
	end

	-- initialize the console
	if guiLoot.console == nil then
		if guiLoot.imported then
			guiLoot.console = imgui.ConsoleWidget.new("Loot_imported##Imported_Console")
		else
			guiLoot.console = imgui.ConsoleWidget.new("Loot##Console")
		end
	end

	-- load settings
	loadSettings()
end

local function init()
	guiLoot.linkdb = mq.TLO.Plugin('mq2linkdb').IsLoaded()

	-- if imported set show to true.
	if guiLoot.imported then
		guiLoot.SHOW = true
		-- print("Imported Mode")
		mq.imgui.init('importedLootItemsGUI', guiLoot.GUI)
	else
		-- print("Normal Mode")
		mq.imgui.init('lootItemsGUI', guiLoot.GUI)
	end
	mq.imgui.init('lootConfigGUI', lootedConf_GUI)
	mq.imgui.init('lootReportGui', lootedReport_GUI)
	-- setup events
	if guiLoot.UseActors then
		-- print("Using Actors")
		guiLoot.RegisterActor()
		guiLoot.linkdb = false
	else
		-- print("Using Events")
		mq.event('echo_Loot', '--#1# ha#*# looted a #2#.#*#', guiLoot.EventLoot)
	end

	-- initialize the console
	if guiLoot.console == nil then
		if guiLoot.imported then
			guiLoot.console = imgui.ConsoleWidget.new("Loot_imported##Imported_Console")
		else
			guiLoot.console = imgui.ConsoleWidget.new("Loot##Console")
		end
	end

	-- load settings
	loadSettings()
end

local args = {...}
local function checkArgs(args)
	
	if args[1] == 'start' then
		mq.bind('/looted', bind)
		guiLoot.SHOW = true
		guiLoot.openGUI = true
		guiLoot.imported = false
		guiLoot.UseActors = false
		init()
	elseif args[1] == 'hidenames' then
		mq.bind('/looted', bind)
		guiLoot.SHOW = true
		guiLoot.openGUI = true
		guiLoot.hideNames = true
		guiLoot.imported = false
		guiLoot.UseActors = false
		init()
	else
		local echo = "\ay[Looted]\ax Start in standalone mode with \ag/lua run looted start\n"
		print(echo)
		return
	end
	
	local echo = "\ay[Looted]\ax Commands:\n"
	echo = echo .. "\ay[Looted]\ax /looted show   \t\t\atToggles the Gui.\n\ax"
	echo = echo .. "\ay[Looted]\ax /looted report \t\t\atReports loot Data or Enables recording of data if not already.\n\ax"
	echo = echo .. "\ay[Looted]\ax /looted clear  \t\t\atClears Recorded Data.\n\ax"
	echo = echo .. "\ay[Looted]\ax /looted hidenames  \t\atHides names and shows Class instead.\n\ax"
	echo = echo .. "\ay[Looted]\ax /looted stop   \t\t\atExits script.\ax"
	print(echo)

	guiLoot.console:AppendText(echo)
	
	local i = getNextID(txtBuffer)
	-- ZOOM Console hack
	if i > 1 then
		if txtBuffer[i-1].Text == '' then i = i-1 end
	end
	-- Add the new line to the buffer
	txtBuffer[i] = {
		Text = "Looted Loaded \n/looted show \t Toggles the GUI\n /looted report \tReports loot Data or Enables recording of data if not already."
	}
	txtBuffer[i+1] = {
		Text = "/looted clear  \tClears Recorded Data.\n/looted hidenames  \tHides names and shows Class instead.\n/looted stop   \tExits script."
	}
end

local function loop()
	while guiLoot.SHOW do
		mq.delay(100)
		mq.doevents()
	end
end
checkArgs(args)
loop()

return guiLoot
