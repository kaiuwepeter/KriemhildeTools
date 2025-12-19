--[[
	KriemhildeTools Farmbar
	Zeigt farmbaren Items in verschiedenen Kategorien
	Items werden aus GatherMate2 bezogen (falls vorhanden)
]]

local addonName = "KriemhildeTools"
local KT = LibStub("AceAddon-3.0"):GetAddon(addonName)
local LK = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- Farmbar Modul
local Farmbar = KT:NewModule("Farmbar", "AceEvent-3.0")

-- Lokale Variablen
local db
local categoryBars = {}
local updateTimer

-- Kategorie-Definitionen
local CATEGORIES = {
	{
		key = "mining",
		name = LK["Erze"],
		icon = "Interface\\Icons\\Trade_Mining",
		color = {r = 1, g = 0, b = 0},
	},
	{
		key = "herbalism",
		name = LK["Blumen"],
		icon = "Interface\\Icons\\Trade_Herbalism",
		color = {r = 0, g = 1, b = 0},
	},
	{
		key = "fishing",
		name = LK["Fische"],
		icon = "Interface\\Icons\\Trade_Fishing",
		color = {r = 0, g = 0.5, b = 1},
	},
	{
		key = "logging",
		name = LK["Holz"],
		icon = "Interface\\Icons\\ui_resourcelumberwarwithin",
		color = {r = 0.6, g = 0.4, b = 0.2},
	},
	{
		key = "skinning",
		name = LK["Leder"],
		icon = "Interface\\Icons\\Trade_LeatherWorking",
		color = {r = 0.8, g = 0.6, b = 0.4},
	},
	{
		key = "knowledge",
		name = LK["Berufswissen"],
		icon = "Interface\\Icons\\inv_scroll_11",
		color = {r = 0.8, g = 0.6, b = 1},
	},
}

-- Item-Datenbank wird aus KTFBItems.lua geladen
-- Farmbar.ItemDatabase wird dort definiert

-- Standard-Einstellungen
local defaults = {
	profile = {
		enabled = true,
		locked = false,
		showEmptyBars = true,
		barScale = 1.0,
		buttonSize = 32,
		categories = {
			mining = {
				enabled = true,
				items = {},
				position = {point = "BOTTOMLEFT", x = 10, y = 150},
			},
			herbalism = {
				enabled = true,
				items = {},
				position = {point = "BOTTOMLEFT", x = 180, y = 150},
			},
			fishing = {
				enabled = true,
				items = {},
				position = {point = "BOTTOMLEFT", x = 350, y = 150},
			},
			logging = {
				enabled = true,
				items = {},
				position = {point = "BOTTOMLEFT", x = 520, y = 150},
			},
			skinning = {
				enabled = true,
				items = {},
				position = {point = "BOTTOMLEFT", x = 690, y = 150},
			},
			knowledge = {
				enabled = true,
				items = {},
				position = {point = "BOTTOMLEFT", x = 10, y = 80},
			},
		},
	},
}

-- Initialisierung
function Farmbar:OnInitialize()
	-- In die Haupt-DB von KriemhildeTools integrieren
	if not KT.db.profile.farmbar then
		KT.db.profile.farmbar = defaults.profile
	end
	db = KT.db.profile.farmbar

	-- Slash Commands
	KT:RegisterChatCommand("farmbar", function(input) Farmbar:SlashCommand(input) end)
	KT:RegisterChatCommand("fb", function(input) Farmbar:SlashCommand(input) end)
end

function Farmbar:OnEnable()
	if not db.enabled then return end

	-- Events registrieren
	self:RegisterEvent("BAG_UPDATE_DELAYED", "UpdateBars")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CreateBars")

	-- Bars erstellen
	self:CreateBars()

	-- Initiales Update
	C_Timer.After(1, function()
		self:UpdateBars()
	end)
end

function Farmbar:OnDisable()
	self:HideBars()
end

-- Slash Command Handler
function Farmbar:SlashCommand(input)
	input = string.lower(input or "")

	if input == "" or input == "toggle" then
		db.enabled = not db.enabled
		if db.enabled then
			self:CreateBars()
			KT:Print(LK["Farmbar aktiviert"])
		else
			self:HideBars()
			KT:Print(LK["Farmbar deaktiviert"])
		end
	elseif input == "lock" then
		db.locked = not db.locked
		KT:Print("Farmbar " .. (db.locked and LK["gesperrt"] or LK["entsperrt"]))
		self:UpdateBars()
	elseif input == "test" then
		-- Temporärer Test-Command: Füge einige Beispiel-Items hinzu
		KT:Print("Füge Test-Items zur Farmbar hinzu...")

		-- Kräuter
		self:AddItemToCategory("herbalism", 210796) -- Mycobloom
		self:AddItemToCategory("herbalism", 239690) -- Phantomlüte
		self:AddItemToCategory("herbalism", 191460) -- Hochland-Lotusblüte

		-- Erze
		self:AddItemToCategory("mining", 210930) -- Bismuth
		self:AddItemToCategory("mining", 189143) -- Draconium Ore

		-- Berufswissen
		self:AddItemToCategory("knowledge", 224583) -- Riesen-Steintafel
		self:AddItemToCategory("knowledge", 224835) -- Tiefenhainwurzel
		self:AddItemToCategory("knowledge", 224752) -- Durchnässter Tagebucheintrag

		self:UpdateBars()
		KT:Print("Test-Items hinzugefügt! Die Bars sollten jetzt sichtbar sein (wenn du die Items im Inventar hast).")
	elseif input == "config" or input == "settings" then
		KT:ToggleMainFrame()
		-- Navigation zur Farmbar-Konfiguration
		if KT.mainFrame then
			KT:ShowMenuContent("Farmbar_Konfiguration")
		end
	else
		KT:Print("Farmbar " .. LK["Befehle"] .. ":")
		KT:Print("/farmbar toggle - Farmbar " .. LK["ein/ausschalten"])
		KT:Print("/farmbar lock - Bars " .. LK["sperren/entsperren"])
		KT:Print("/farmbar test - Test-Items hinzufügen")
		KT:Print("/farmbar config - " .. LK["Einstellungen öffnen"])
	end
end

-- Hole Items für eine Kategorie
function Farmbar:GetAvailableItemsForCategory(categoryKey)
	-- Hole Items aus der manuellen Datenbank
	-- GatherMate2 wird nicht direkt für Items verwendet, da es nur Nodes trackt
	return self.ItemDatabase[categoryKey] or {}
end

-- Finde Item-Info anhand der ItemID
function Farmbar:GetItemInfoByID(itemID)
	for categoryKey, items in pairs(self.ItemDatabase) do
		for _, item in ipairs(items) do
			if item.id == itemID then
				return item
			end
		end
	end
	return nil
end

-- Hole den passenden Quality-Atlas basierend auf Expansion und Quality
function Farmbar:GetQualityAtlas(expansion, quality)
	if expansion == "MN" then
		-- Midnight verwendet andere Atlas-Icons (Patch 12.x)
		-- Bronze/Silber teilen sich quality = 1
		if quality == 1 then
			return "Professions-Icon-Quality-12-Tier1-Inv" -- Bronze/Silber
		elseif quality == 2 then
			return "Professions-Icon-Quality-12-Tier2-Inv" -- Gold
		end
	elseif expansion == "TWW" or expansion == "DF" then
		-- TWW/DF verwenden die Standard Professions-ChatIcon
		if quality == 1 then
			return "Professions-ChatIcon-Quality-Tier1"
		elseif quality == 2 then
			return "Professions-ChatIcon-Quality-Tier2"
		elseif quality == 3 then
			return "Professions-ChatIcon-Quality-Tier3"
		end
	end
	return nil
end

-- Gruppiere Items nach Expansion
function Farmbar:GetItemsByExpansion(categoryKey)
	local items = self:GetAvailableItemsForCategory(categoryKey)
	local byExpansion = {}

	for _, item in ipairs(items) do
		local exp = item.expansion or "Other"
		if not byExpansion[exp] then
			byExpansion[exp] = {}
		end
		table.insert(byExpansion[exp], item)
	end

	return byExpansion
end

-- Bar-Erstellung (gleich wie vorher, aber mit SetClampedToScreen)
function Farmbar:CreateBars()
	if not db.enabled then return end

	for _, category in ipairs(CATEGORIES) do
		if not categoryBars[category.key] then
			categoryBars[category.key] = self:CreateCategoryBar(category)
		end
	end

	self:UpdateBars()
end

function Farmbar:CreateCategoryBar(category)
	local catData = db.categories[category.key]
	if not catData or not catData.enabled then return nil end

	local bar = CreateFrame("Frame", "KriemhildeToolsFarmbar_" .. category.key, UIParent, "BackdropTemplate")
	bar:SetSize(100, 44)
	bar:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	bar:SetBackdropColor(0, 0, 0, 0.8)
	bar:SetBackdropBorderColor(category.color.r, category.color.g, category.color.b, 1)
	bar:SetScale(db.barScale)

	-- Position wiederherstellen
	local pos = catData.position
	bar:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)

	-- Bewegbarkeit - WICHTIG: SetClampedToScreen verhindert Bewegung aus Sichtfeld
	bar:SetMovable(true)
	bar:EnableMouse(true)
	bar:SetClampedToScreen(true)  -- Verhindert Bewegung aus dem Sichtfeld
	bar:RegisterForDrag("LeftButton")

	bar:SetScript("OnDragStart", function(self)
		if not db.locked then
			self:StartMoving()
		end
	end)

	bar:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, _, x, y = self:GetPoint()
		catData.position = {point = point, x = x, y = y}
	end)

	-- Icon
	bar.icon = bar:CreateTexture(nil, "ARTWORK")
	bar.icon:SetSize(32, 32)
	bar.icon:SetPoint("LEFT", bar, "LEFT", 6, 0)
	bar.icon:SetTexture(category.icon)

	-- Count Label
	bar.countLabel = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	bar.countLabel:SetPoint("LEFT", bar.icon, "RIGHT", 6, 0)
	bar.countLabel:SetText("0000")
	bar.countLabel:SetTextColor(category.color.r, category.color.g, category.color.b)
	bar.countLabel:SetJustifyH("LEFT")

	bar.categoryName = category.name
	bar.buttons = {}
	bar.categoryKey = category.key

	-- Tooltip mit intelligenter Positionierung
	bar:SetScript("OnEnter", function(self)
		-- Berechne beste Tooltip-Position basierend auf Bar-Position
		local barX = self:GetCenter()
		local barY = select(2, self:GetCenter())
		local screenWidth = GetScreenWidth()
		local screenHeight = GetScreenHeight()

		local anchor = "ANCHOR_RIGHT" -- Standard: Rechts

		-- Wenn Bar auf rechter Bildschirmhälfte, zeige Tooltip links
		if barX > screenWidth / 2 then
			anchor = "ANCHOR_LEFT"
		end

		-- Wenn Bar am oberen Rand, zeige Tooltip unten
		if barY > screenHeight * 0.75 then
			anchor = "ANCHOR_BOTTOM"
		-- Wenn Bar am unteren Rand, zeige Tooltip oben
		elseif barY < screenHeight * 0.25 then
			anchor = "ANCHOR_TOP"
		end

		GameTooltip:SetOwner(self, anchor)
		GameTooltip:AddLine(category.name, category.color.r, category.color.g, category.color.b)
		GameTooltip:AddLine(LK["Farmbar Tooltip Info"] or "Zeigt getrackte Items dieser Kategorie", 1, 1, 1)
		if not db.locked then
			GameTooltip:AddLine(LK["Rechtsklick für Einstellungen"] or "Rechtsklick für Einstellungen", 0.5, 0.5, 0.5)
		end
		GameTooltip:Show()
	end)

	bar:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	bar:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" and not db.locked then
			KT:ToggleMainFrame()
			if KT.mainFrame then
				KT:ShowMenuContent("Farmbar_Konfiguration")
			end
		end
	end)

	return bar
end

-- Bars aktualisieren
function Farmbar:UpdateBars()
	if not db.enabled then return end

	if updateTimer then return end
	updateTimer = C_Timer.NewTimer(0.1, function()
		updateTimer = nil
		Farmbar:DoUpdateBars()
	end)
end

function Farmbar:DoUpdateBars()
	for _, category in ipairs(CATEGORIES) do
		local bar = categoryBars[category.key]
		if bar then
			self:UpdateCategoryBar(bar, category)
		end
	end
end

function Farmbar:UpdateCategoryBar(bar, category)
	local catData = db.categories[category.key]
	if not catData then return end

	-- Alte Buttons entfernen
	for _, button in ipairs(bar.buttons) do
		button:Hide()
		button:SetParent(nil)
	end
	wipe(bar.buttons)

	-- Items im Inventar sammeln
	local inventoryItems = self:GetInventoryItemCounts()
	local buttonSize = db.buttonSize
	local spacing = 2
	local totalCount = 0
	local startX = 90

	local visibleIndex = 0
	for _, itemID in ipairs(catData.items) do
		local count = inventoryItems[itemID] or 0

		if count > 0 then
			totalCount = totalCount + count

			local button = self:CreateItemButton(bar, itemID, count)
			local x = startX + visibleIndex * (buttonSize + spacing)
			button:SetPoint("LEFT", bar, "LEFT", x, 0)
			button:Show()

			table.insert(bar.buttons, button)
			visibleIndex = visibleIndex + 1
		end
	end

	-- Count-Label aktualisieren
	bar.countLabel:SetText(string.format("%04d", totalCount))

	-- Bar-Breite anpassen
	local itemsWidth = visibleIndex > 0 and (visibleIndex * (buttonSize + spacing) - spacing) or 0
	local totalWidth = startX + itemsWidth + 10
	bar:SetSize(totalWidth, buttonSize + 12)

	-- Bar verstecken wenn leer
	if (visibleIndex == 0 and not db.showEmptyBars) or #catData.items == 0 then
		bar:Hide()
	else
		bar:Show()
	end
end

-- Item Button erstellen
function Farmbar:CreateItemButton(parent, itemID, count)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(db.buttonSize, db.buttonSize)

	-- Icon
	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetAllPoints()
	local itemTexture = C_Item.GetItemIconByID(itemID)
	if itemTexture then
		button.icon:SetTexture(itemTexture)
	else
		button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	end

	-- Count Text
	button.count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	button.count:SetTextColor(1, 1, 1)
	button.count:SetShadowOffset(1, -1)
	if count > 0 then
		button.count:SetText(count)
		button.count:Show()
	else
		button.count:Hide()
	end

	-- Border
	button.border = button:CreateTexture(nil, "OVERLAY")
	button.border:SetAllPoints()
	button.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	button.border:SetBlendMode("ADD")

	-- Quality Color
	local itemQuality = C_Item.GetItemQualityByID(itemID)
	if itemQuality and itemQuality > 1 then
		local r, g, b = C_Item.GetItemQualityColor(itemQuality)
		button.border:SetVertexColor(r, g, b, 0.5)
		button.border:Show()
	else
		button.border:Hide()
	end

	-- Quality Atlas Overlay (für MN/DF/TWW Items)
	local itemInfo = self:GetItemInfoByID(itemID)
	if itemInfo and itemInfo.quality then
		local atlasName = self:GetQualityAtlas(itemInfo.expansion, itemInfo.quality)
		if atlasName then
			local qualityOverlay = button:CreateTexture(nil, "OVERLAY", nil, 2)
			-- MN Icons größer machen (0.75 statt 0.5)
			local overlaySize = itemInfo.expansion == "MN" and (db.buttonSize * 0.75) or (db.buttonSize * 0.5)
			qualityOverlay:SetSize(overlaySize, overlaySize)
			qualityOverlay:SetPoint("TOPLEFT", button.icon, "TOPLEFT", -2, 2)
			qualityOverlay:SetAtlas(atlasName)
			button.qualityOverlay = qualityOverlay
		end
	end

	-- Tooltip
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetItemByID(itemID)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(LK["Im Inventar"] .. ": " .. count, 1, 1, 1)
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	button.itemID = itemID
	return button
end

-- Inventar durchsuchen
function Farmbar:GetInventoryItemCounts()
	local items = {}

	for _, category in ipairs(CATEGORIES) do
		local catData = db.categories[category.key]
		if catData and catData.items then
			for _, itemID in ipairs(catData.items) do
				local count = GetItemCount(itemID, false) or 0
				if count > 0 then
					items[itemID] = count
				end
			end
		end
	end

	return items
end

-- Bars verstecken
function Farmbar:HideBars()
	for _, bar in pairs(categoryBars) do
		if bar then
			bar:Hide()
		end
	end
end

-- Item zu Kategorie hinzufügen
function Farmbar:AddItemToCategory(categoryKey, itemID)
	if type(itemID) == "string" then
		itemID = tonumber(string.match(itemID, "%d+"))
	end

	if not itemID then return end

	-- Von anderen Kategorien entfernen
	for _, category in ipairs(CATEGORIES) do
		if category.key ~= categoryKey then
			local catData = db.categories[category.key]
			if catData and catData.items then
				local items = catData.items
				for i = #items, 1, -1 do
					if items[i] == itemID then
						table.remove(items, i)
					end
				end
			end
		end
	end

	-- Zur neuen Kategorie hinzufügen
	-- Kategorie erstellen falls nicht vorhanden
	if not db.categories[categoryKey] then
		db.categories[categoryKey] = {
			enabled = true,
			items = {},
			position = {point = "BOTTOMLEFT", x = 10, y = 150}
		}
	end

	local items = db.categories[categoryKey].items
	local exists = false
	for _, id in ipairs(items) do
		if id == itemID then
			exists = true
			break
		end
	end

	if not exists then
		table.insert(items, itemID)
	end
end

-- Item von Kategorie entfernen
function Farmbar:RemoveItemFromCategory(categoryKey, itemID)
	if not db.categories[categoryKey] then return end
	local items = db.categories[categoryKey].items
	for i = #items, 1, -1 do
		if items[i] == itemID then
			table.remove(items, i)
			break
		end
	end
end
