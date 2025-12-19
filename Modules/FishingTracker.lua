-- FishingTracker Module
-- Trackt welcher Fisch aus welchem Fischschwarm geangelt wurde

local addonName = "KriemhildeTools"
local KT = LibStub("AceAddon-3.0"):GetAddon(addonName)
local FishingTracker = KT:NewModule("FishingTracker", "AceEvent-3.0")
local LK = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- Lokale Variablen
local currentPool = nil
local currentPoolGUID = nil
local lastCastTime = 0
local debugMode = false
local fishingSpellIDs = {
	[131474] = true, -- Angeln (Primär)
	[7620] = true,   -- Fishing (alt)
	[7731] = true,   -- Fishing (alt2)
	[7732] = true,   -- Fishing (alt3)
	[18248] = true,  -- Fishing (alt4)
}

-- Namen die KEINE Pools sind (Bobber, etc.)
local ignoreNames = {
	["Schwimmer"] = true,
	["Bobber"] = true,
	["Fishing Bobber"] = true,
}

-- Debug print helper
local function DebugPrint(...)
	if debugMode then
		print("[FishingTracker]", ...)
	end
end

function FishingTracker:OnInitialize()
	-- Initialisiere eigene SavedVariable
	if not KriemhildeToolsFishingDB then
		KriemhildeToolsFishingDB = {
			-- Struktur: [poolName] = {items = {[fishID] = {count, name, quality}}, objectID = number}
			pools = {},
			-- Gesamtstatistik
			totalCasts = 0,
			totalPoolCasts = 0,
		}
	end

	self.db = KriemhildeToolsFishingDB

	-- Migriere alte Datenbank-Struktur falls nötig
	for poolName, poolData in pairs(self.db.pools) do
		if poolData.count or poolData.name then
			-- Alte Struktur erkannt, migriere
			local oldData = {}
			for k, v in pairs(poolData) do
				oldData[k] = v
			end
			self.db.pools[poolName] = {
				items = oldData,
				objectID = nil
			}
		elseif not poolData.items then
			-- Sehr alte Struktur, erstelle neue
			local oldData = {}
			for k, v in pairs(poolData) do
				if type(k) == "number" then
					oldData[k] = v
				end
			end
			self.db.pools[poolName] = {
				items = oldData,
				objectID = poolData.objectID
			}
		end
	end
end

function FishingTracker:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
	self:RegisterEvent("LOOT_READY")
	self:RegisterEvent("LOOT_CLOSED")
	KT:Print(LK["FishingTracker aktiviert"])
end

function FishingTracker:OnDisable()
	self:UnregisterAllEvents()
	KT:Print(LK["FishingTracker deaktiviert"])
end

-- Event: Zauber-Cast gesendet (GatherMate2-Methode!)
function FishingTracker:UNIT_SPELLCAST_SENT(event, unit, target, castGUID, spellID)
	if unit ~= "player" then return end

	-- Prüfe ob es ein Angel-Zauber ist
	if not fishingSpellIDs[spellID] then return end

	self.db.totalCasts = self.db.totalCasts + 1
	lastCastTime = GetTime()

	DebugPrint("Angel-Cast gesendet! SpellID:", spellID, "Target:", target)

	-- Helper: Extrahiere Objekt-ID aus GUID
	local function GetObjectIDFromGUID(guid)
		if not guid then return nil end
		-- GUID Format: "GameObject-0-SERVER-INSTANCE-SPAWN-OBJECT_ID-SPAWN_UID"
		local objectID = select(6, strsplit("-", guid))
		return objectID and tonumber(objectID, 16) or nil
	end

	-- Methode 1: target Parameter (wenn auf Pool geklickt)
	if target and target ~= "" and not ignoreNames[target] then
		currentPool = target
		-- Versuche GUID vom mouseover zu bekommen
		if UnitExists("mouseover") then
			currentPoolGUID = UnitGUID("mouseover")
		end
		DebugPrint(">>> POOL ERKANNT (via target):", currentPool, "GUID:", currentPoolGUID)
	else
		-- Methode 2: mouseover prüfen (Fallback)
		if UnitExists("mouseover") then
			local mouseoverName = UnitName("mouseover")
			local mouseoverGUID = UnitGUID("mouseover")

			DebugPrint("Kein Target, prüfe Mouseover:", mouseoverName, "GUID:", mouseoverGUID)

			if mouseoverName and mouseoverName ~= "" and mouseoverName ~= UnitName("player") and not ignoreNames[mouseoverName] then
				currentPool = mouseoverName
				currentPoolGUID = mouseoverGUID
				DebugPrint(">>> POOL ERKANNT (via Mouseover):", currentPool, "GUID:", currentPoolGUID)
			else
				currentPool = nil
				currentPoolGUID = nil
				if ignoreNames[mouseoverName] then
					DebugPrint("Ignoriere:", mouseoverName, "(Schwimmer/Bobber)")
				else
					DebugPrint("Kein Pool (normales Wasser)")
				end
			end
		else
			-- Methode 3: GameTooltip als letzter Fallback
			local tooltipText = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText()
			DebugPrint("Kein Mouseover, prüfe Tooltip:", tooltipText)

			if tooltipText and tooltipText ~= "" and tooltipText ~= UnitName("player") and not ignoreNames[tooltipText] then
				currentPool = tooltipText
				currentPoolGUID = nil -- Kein GUID verfügbar über Tooltip
				DebugPrint(">>> POOL ERKANNT (via Tooltip):", currentPool)
			else
				currentPool = nil
				currentPoolGUID = nil
				if ignoreNames[tooltipText] then
					DebugPrint("Ignoriere:", tooltipText, "(Schwimmer/Bobber)")
				else
					DebugPrint("Kein Pool (normales Wasser)")
				end
			end
		end
	end

	-- Initialisiere Pool in DB falls vorhanden
	if currentPool then
		if not self.db.pools[currentPool] then
			self.db.pools[currentPool] = {
				items = {},
				objectID = nil
			}
		end

		-- Speichere Objekt-ID falls verfügbar
		if currentPoolGUID and not self.db.pools[currentPool].objectID then
			local objectID = GetObjectIDFromGUID(currentPoolGUID)
			if objectID then
				self.db.pools[currentPool].objectID = objectID
				DebugPrint("Objekt-ID gespeichert:", objectID, "für Pool:", currentPool)
			end
		end

		self.db.totalPoolCasts = self.db.totalPoolCasts + 1
	end
end

-- Event: Loot ist bereit
function FishingTracker:LOOT_READY()
	DebugPrint("LOOT_READY Event gefeuert!")

	-- Prüfe ob dieser Loot von einem Angel-Cast kommt (innerhalb 20 Sekunden - kann länger dauern!)
	local timeSinceCast = GetTime() - lastCastTime
	if timeSinceCast > 20 then
		DebugPrint("Loot zu alt (", timeSinceCast, "Sekunden seit Cast)")
		return
	end

	DebugPrint("Loot ist", timeSinceCast, "Sekunden nach Cast")

	-- Nur tracken wenn wir einen Pool haben
	if not currentPool then
		DebugPrint("Kein Pool aktiv - ignoriere Loot")
		return
	end

	DebugPrint("Tracke Loot für Pool:", currentPool)

	-- Lese alle Loot-Items aus
	local numItems = GetNumLootItems()
	DebugPrint("Anzahl Loot-Items:", numItems)

	for slot = 1, numItems do
		local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(slot)

		DebugPrint("Slot", slot, ":", lootName, "Menge:", lootQuantity)

		if lootName and not currencyID then
			-- Versuche Item-Link zu bekommen
			local lootLink = GetLootSlotLink(slot)

			if lootLink then
				local itemID = tonumber(lootLink:match("item:(%d+)"))

				if itemID then
					DebugPrint(">>> FISCH GEFANGEN:", lootName, "ID:", itemID, "aus Pool:", currentPool)

					-- Stelle sicher dass Pool-Struktur existiert
					if not self.db.pools[currentPool].items then
						self.db.pools[currentPool].items = {}
					end

					-- Speichere in Datenbank
					if not self.db.pools[currentPool].items[itemID] then
						self.db.pools[currentPool].items[itemID] = {
							count = 0,
							name = lootName,
							quality = lootQuality,
						}
					end

					self.db.pools[currentPool].items[itemID].count = self.db.pools[currentPool].items[itemID].count + (lootQuantity or 1)

					DebugPrint("Gesamt", lootName, "aus", currentPool, ":", self.db.pools[currentPool].items[itemID].count)
				end
			end
		end
	end
end

-- Event: Loot-Fenster geschlossen
function FishingTracker:LOOT_CLOSED()
	-- Optional: Cleanup
end

-- Hole alle getrackte Pools
function FishingTracker:GetTrackedPools()
	local pools = {}
	for poolName, fishData in pairs(self.db.pools) do
		table.insert(pools, poolName)
	end
	table.sort(pools)
	return pools
end

-- Hole Fisch-Daten für einen Pool
function FishingTracker:GetPoolData(poolName)
	local poolData = self.db.pools[poolName]
	if not poolData then return {} end
	-- Rückwärtskompatibilität: Falls alte Struktur, gib sie direkt zurück
	if poolData.items then
		return poolData.items
	else
		return poolData
	end
end

-- Hole Objekt-ID für einen Pool
function FishingTracker:GetPoolObjectID(poolName)
	local poolData = self.db.pools[poolName]
	if not poolData then return nil end
	return poolData.objectID
end

-- Lösche alle Daten
function FishingTracker:ResetAllData()
	self.db.pools = {}
	self.db.totalCasts = 0
	self.db.totalPoolCasts = 0
end

-- Lösche Daten für einen Pool
function FishingTracker:ResetPoolData(poolName)
	self.db.pools[poolName] = nil
end

-- Toggle Debug Mode
function FishingTracker:ToggleDebug()
	debugMode = not debugMode
	if debugMode then
		KT:Print("Fishing Debug: |cff00ff00AN|r")
	else
		KT:Print("Fishing Debug: |cffff0000AUS|r")
	end
	return debugMode
end
