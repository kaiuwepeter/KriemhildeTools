--[[
	KriemhildeTools Farmbar Item Database
	Enthält alle farmbare Items nach Kategorien und Expansionen sortiert
]]

local addonName = "KriemhildeTools"
local KT = LibStub("AceAddon-3.0"):GetAddon(addonName)
local Farmbar = KT:GetModule("Farmbar")

-- Item-Datenbank
-- Struktur: {id = itemID, name = "Item Name", expansion = "ExpansionKey", quality = 1/2/3 (optional)}
Farmbar.ItemDatabase = {
	-- ========================================
	-- KRÄUTER / HERBS
	-- ========================================
	herbalism = {
		-- Midnight (MN)
		{id = 236779, name = "Manalilie", expansion = "MN", quality = 2},
		{id = 236778, name = "Manalilie", expansion = "MN", quality = 1},
		{id = 236767, name = "Harmonieblume", expansion = "MN", quality = 2},
		{id = 236761, name = "Harmonieblume", expansion = "MN", quality = 1},
		{id = 236771, name = "Rotdorn", expansion = "MN", quality = 2},
		{id = 236770, name = "Rotdorn", expansion = "MN", quality = 1},
		{id = 236775, name = "Azerwurz", expansion = "MN", quality = 2},
		{id = 236774, name = "Azerwurz", expansion = "MN", quality = 1},
		{id = 236777, name = "Argentumblatt", expansion = "MN", quality = 2},
		{id = 236776, name = "Argentumblatt", expansion = "MN", quality = 1},
		{id = 236780, name = "Nachtlotus", expansion = "MN"},

		-- The War Within (TWW)
		{id = 210796, name = "Mykopracht", expansion = "TWW", quality = 1},
		{id = 210797, name = "Mykopracht", expansion = "TWW", quality = 2},
		{id = 210798, name = "Mykopracht", expansion = "TWW", quality = 3},
		{id = 210799, name = "Reiztropfen", expansion = "TWW", quality = 1},
		{id = 210800, name = "Reiztropfen", expansion = "TWW", quality = 2},
		{id = 210801, name = "Reiztropfen", expansion = "TWW", quality = 3},
		{id = 210802, name = "Orbinid", expansion = "TWW", quality = 1},
		{id = 210803, name = "Orbinid", expansion = "TWW", quality = 2},
		{id = 210804, name = "Orbinid", expansion = "TWW", quality = 3},
		{id = 210805, name = "Segensblume", expansion = "TWW", quality = 1},
		{id = 210806, name = "Segensblume", expansion = "TWW", quality = 2},
		{id = 210807, name = "Segensblume", expansion = "TWW", quality = 3},
		{id = 210808, name = "Arathors Speer", expansion = "TWW", quality = 1},
		{id = 210809, name = "Arathors Speer", expansion = "TWW", quality = 2},
		{id = 210810, name = "Arathors Speer", expansion = "TWW", quality = 3},
		{id = 239690, name = "Phantomlüte", expansion = "TWW", quality = 1},
		{id = 239691, name = "Phantomlüte", expansion = "TWW", quality = 2},
		{id = 239692, name = "Phantomlüte", expansion = "TWW", quality = 3},
		{id = 213197, name = "Nulllotus", expansion = "TWW"},
		{id = 240194, name = "Lotus der K'areshi", expansion = "TWW"},

		-- Dragonflight (DF)
		{id = 191460, name = "Hochblume", expansion = "DF", quality = 1},
		{id = 191461, name = "Hochblume", expansion = "DF", quality = 2},
		{id = 191462, name = "Hochblume", expansion = "DF", quality = 3},
		{id = 191467, name = "Blasenmohn", expansion = "DF", quality = 1},
		{id = 191468, name = "Blasenmohn", expansion = "DF", quality = 2},
		{id = 191469, name = "Blasenmohn", expansion = "DF", quality = 3},
		{id = 191470, name = "Krümmrinde", expansion = "DF", quality = 1},
		{id = 191471, name = "Krümmrinde", expansion = "DF", quality = 2},
		{id = 191472, name = "Krümmrinde", expansion = "DF", quality = 3},
		{id = 191464, name = "Steinbrich", expansion = "DF", quality = 1},
		{id = 191465, name = "Steinbrich", expansion = "DF", quality = 2},
		{id = 191466, name = "Steinbrich", expansion = "DF", quality = 3},

		-- Shadowlands (SL) - Platzhalter + Beispiele
		{id = 168586, name = "Ruhmesstieg", expansion = "SL"},
		{id = 168589, name = "Markwurzel", expansion = "SL"},
		{id = 170554, name = "Wachtfackel", expansion = "SL"},
		{id = 168583, name = "Witwenblüte", expansion = "SL"},
		{id = 171315, name = "Nachtschatten", expansion = "SL"},
		{id = 168583, name = "Todesblüte", expansion = "SL"},

		-- Battle for Azeroth (BFA)
		{id = 152505, name = "Flussknospe", expansion = "BFA"},
		{id = 152511, name = "Meeresstängel", expansion = "BFA"},
		{id = 152506, name = "Sternmoos", expansion = "BFA"},
		{id = 152507, name = "Akundas Biss", expansion = "BFA"},
		{id = 152509, name = "Sierenenpollen", expansion = "BFA"},
		{id = 152508, name = "Winterkuss", expansion = "BFA"},
		{id = 999998, name = "Ankerkraut", expansion = "BFA"},
		-- bis hier alles ok
		
		-- Legion - Platzhalter
		{id = 999997, name = "Placeholder Herb (Legion)", expansion = "Legion"},
		-- TODO: Legion Kräuter hier hinzufügen

		-- Warlords of Draenor (WoD) - Platzhalter
		{id = 999996, name = "Placeholder Herb (WoD)", expansion = "WoD"},
		-- TODO: WoD Kräuter hier hinzufügen

		-- Mists of Pandaria (MoP) - Platzhalter
		{id = 999995, name = "Placeholder Herb (MoP)", expansion = "MoP"},
		-- TODO: MoP Kräuter hier hinzufügen

		-- Cataclysm (Cata) - Platzhalter
		{id = 999994, name = "Placeholder Herb (Cata)", expansion = "Cata"},
		-- TODO: Cata Kräuter hier hinzufügen

		-- Wrath of the Lich King (Wrath) - Platzhalter
		{id = 999993, name = "Placeholder Herb (Wrath)", expansion = "Wrath"},
		-- TODO: Wrath Kräuter hier hinzufügen

		-- The Burning Crusade (TBC) - Platzhalter
		{id = 999992, name = "Placeholder Herb (TBC)", expansion = "TBC"},
		-- TODO: TBC Kräuter hier hinzufügen

		-- Classic/Vanilla - Platzhalter
		{id = 999991, name = "Placeholder Herb (Classic)", expansion = "Classic"},
		-- TODO: Classic Kräuter hier hinzufügen
	},

	-- ========================================
	-- ERZE / ORES
	-- ========================================
	mining = {
		-- Midnight (MN) - Sortiert nach ID
		{id = 237359, name = "Glänzendes Kupfererz", expansion = "MN", quality = 1},
		{id = 237361, name = "Glänzendes Kupfererz", expansion = "MN", quality = 2},
		{id = 237362, name = "Umbralzinnerz", expansion = "MN", quality = 1},
		{id = 237363, name = "Umbralzinnerz", expansion = "MN", quality = 2},
		{id = 237364, name = "Brillantes Silbererz", expansion = "MN", quality = 1},
		{id = 237365, name = "Brillantes Silbererz", expansion = "MN", quality = 2},

		-- The War Within (TWW)
		{id = 210930, name = "Bismut", expansion = "TWW", quality = 1},
		{id = 210931, name = "Bismut", expansion = "TWW", quality = 2},
		{id = 210932, name = "Bismut", expansion = "TWW", quality = 3},
		{id = 210933, name = "Aqirit", expansion = "TWW", quality = 1},
		{id = 210934, name = "Aqirit", expansion = "TWW", quality = 2},
		{id = 210935, name = "Aqirit", expansion = "TWW", quality = 3},
		{id = 210936, name = "Eisenklauenerz", expansion = "TWW", quality = 1},
		{id = 210937, name = "Eisenklauenerz", expansion = "TWW", quality = 2},
		{id = 210938, name = "Eisenklauenerz", expansion = "TWW", quality = 3},
		{id = 210939, name = "Nullstein", expansion = "TWW"},
		{id = 238201, name = "Trostloser Schutt", expansion = "TWW", quality = 1},
		{id = 238212, name = "Trostloser Schutt", expansion = "TWW", quality = 2},
		{id = 238213, name = "Trostloser Schutt", expansion = "TWW", quality = 3},
		{id = 240216, name = "Reesonanzstein der K'areshi", expansion = "TWW"},

		-- Dragonflight (DF)
		{id = 189143, name = "Draconium Ore", expansion = "DF", quality = 1},
		{id = 188658, name = "Draconium Ore", expansion = "DF", quality = 2},
		{id = 190395, name = "Draconium Ore", expansion = "DF", quality = 3},
		{id = 190396, name = "Serevite Ore", expansion = "DF", quality = 1},
		{id = 190394, name = "Serevite Ore", expansion = "DF", quality = 2},
		{id = 190311, name = "Serevite Ore", expansion = "DF", quality = 3},

		-- Shadowlands (SL) - Platzhalter + Beispiele
		{id = 171828, name = "Laestrite Ore", expansion = "SL"},
		{id = 171829, name = "Solenium Ore", expansion = "SL"},
		{id = 171830, name = "Oxxein Ore", expansion = "SL"},
		{id = 171831, name = "Phaedrum Ore", expansion = "SL"},
		-- TODO: Weitere SL Erze hinzufügen

		-- Battle for Azeroth (BFA) - Platzhalter
		{id = 989998, name = "Placeholder Ore (BFA)", expansion = "BFA"},
		-- TODO: BFA Erze hier hinzufügen

		-- Legion - Platzhalter
		{id = 989997, name = "Placeholder Ore (Legion)", expansion = "Legion"},
		-- TODO: Legion Erze hier hinzufügen

		-- Warlords of Draenor (WoD) - Platzhalter
		{id = 989996, name = "Placeholder Ore (WoD)", expansion = "WoD"},
		-- TODO: WoD Erze hier hinzufügen

		-- Mists of Pandaria (MoP) - Platzhalter
		{id = 989995, name = "Placeholder Ore (MoP)", expansion = "MoP"},
		-- TODO: MoP Erze hier hinzufügen

		-- Cataclysm (Cata) - Platzhalter
		{id = 989994, name = "Placeholder Ore (Cata)", expansion = "Cata"},
		-- TODO: Cata Erze hier hinzufügen

		-- Wrath of the Lich King (Wrath) - Platzhalter
		{id = 989993, name = "Placeholder Ore (Wrath)", expansion = "Wrath"},
		-- TODO: Wrath Erze hier hinzufügen

		-- The Burning Crusade (TBC) - Platzhalter
		{id = 989992, name = "Placeholder Ore (TBC)", expansion = "TBC"},
		-- TODO: TBC Erze hier hinzufügen

		-- Classic/Vanilla - Platzhalter
		{id = 989991, name = "Placeholder Ore (Classic)", expansion = "Classic"},
		-- TODO: Classic Erze hier hinzufügen
	},

	-- ========================================
	-- FISCHE / FISH
	-- ========================================
	fishing = {
		-- Midnight (MN) - Fische mit Farbqualitäten (W=Weiß, G=Grün, B=Blau)
		-- Schwärme: Jägerwoge, Verschleierter Schwarm, Zähflüssige Leere, Blütenschwarm, Oberflächenkräuseln, Peitschende Wellen
		{id = 238365, name = "Sin'doreischwärmer", expansion = "MN", quality = "W"}, -- Oberflächenkräuseln
		{id = 238366, name = "Luchsfisch", expansion = "MN", quality = "W"}, -- Jägerwoge, Oberflächenkräuseln
		{id = 238367, name = "Wurzelkrabbe", expansion = "MN", quality = "G"}, -- Verschleierter Schwarm, Oberflächenkräuseln
		{id = 238368, name = "Verdrehter Tetra", expansion = "MN", quality = "B"}, -- Verschleierter Schwarm, Oberflächenkräuseln
		{id = 238369, name = "Blütenfinnenpfrille", expansion = "MN", quality = "G"}, -- Verschlampte Fracht
		{id = 238370, name = "Schimmernder Stachelfisch", expansion = "MN", quality = "G"}, -- Peitschende Wellen
		{id = 238371, name = "Arkanwyrmfisch", expansion = "MN", quality = "W"}, -- Peitschende Wellen
		{id = 238372, name = "Restaurierter Singfisch", expansion = "MN", quality = "G"}, -- Jägerwoge
		{id = 238373, name = "Ominöser Oktopus", expansion = "MN", quality = "B"}, -- Zähflüssige Leere
		{id = 238374, name = "Zarte Leuchtfinne", expansion = "MN", quality = "G"},
		{id = 238375, name = "Pilzhecht", expansion = "MN", quality = "G"}, -- Verschleierter Schwarm, Oberflächenkräuseln
		{id = 238376, name = "Glücklicher Loa", expansion = "MN", quality = "B"}, -- Verschleierter Schwarm, Oberflächenkräuseln
		{id = 238377, name = "Blutjäger", expansion = "MN", quality = "G"}, -- Zähflüssige Leere, Oberflächenkräuseln
		{id = 238378, name = "Schimmersirene", expansion = "MN", quality = "G"}, -- Blütenschwarm
		{id = 238379, name = "Verdrehter Weiser", expansion = "MN", quality = "B"}, -- Zähflüssige Leere
		{id = 238380, name = "Nullnichtigfisch", expansion = "MN", quality = "B"}, -- Zähflüssige Leere
		{id = 238381, name = "Hohlbarsch", expansion = "MN", quality = "B"}, -- Zähflüssige Leere
		{id = 238382, name = "Blutguppy", expansion = "MN", quality = "G"}, -- Oberflächenkräuseln
		{id = 238383, name = "Immersangforelle", expansion = "MN", quality = "B"}, -- Blütenschwarm
		{id = 238384, name = "Sonnenbrunnenfisch", expansion = "MN", quality = "G"}, -- Jägerwoge, Peitschende Wellen
		-- 20 Fische
		-- The War Within (TWW)
		{id = 220134, name = "Trödelnder Häsling", expansion = "TWW", quality = "W"},
		{id = 220135, name = "Blutbarsch", expansion = "TWW", quality = "W"},
		{id = 220138, name = "Knabberelritze", expansion = "TWW", quality = "G"},
		{id = 220139, name = "Flüsternder Sterngucker", expansion = "TWW", quality = "G"},
		{id = 220142, name = "Stiller Flussbarsch", expansion = "TWW", quality = "G"},
		{id = 220144, name = "Tosender Anglersucher", expansion = "TWW", quality = "G"},
		{id = 220145, name = "Arathorhammerfisch", expansion = "TWW", quality = "G"},
		{id = 220146, name = "Majestätischer Zwergbarsch", expansion = "TWW", quality = "B"},
		{id = 220147, name = "Slumhai der Kaheti", expansion = "TWW", quality = "G"},
		{id = 220149, name = "Blutroter Dornhai", expansion = "TWW", quality = "B"},
		{id = 220150, name = "Stacheliger Seerabe", expansion = "TWW", quality = "B"},
		{id = 220151, name = "Königinnenköderfisch", expansion = "TWW", quality = "B"},
		{id = 220153, name = "Erwachter Quastenflosser", expansion = "TWW", quality = "B"},
		{id = 227673, name = "\"Gold\"-Fisch", expansion = "TWW", quality = "B"},

		-- Dragonflight (DF)
		{id = 194730, name = "Cerulean Spinefish", expansion = "DF"},
		{id = 194967, name = "Temporal Dragonhead", expansion = "DF"},
		{id = 194968, name = "Thousandbite Piranha", expansion = "DF"},
		{id = 194969, name = "Aileron Seamoth", expansion = "DF"},
		{id = 194970, name = "Scalebelly Mackerel", expansion = "DF"},
		{id = 194966, name = "Islefin Dorado", expansion = "DF"},

		-- Shadowlands (SL)
		{id = 173032, name = "Lost Sole", expansion = "SL"},
		{id = 173033, name = "Iridescent Amberjack", expansion = "SL"},
		{id = 173034, name = "Silvergill Pike", expansion = "SL"},
		{id = 173035, name = "Pocked Bonefish", expansion = "SL"},
		-- TODO: Weitere SL Fische hinzufügen

		-- Battle for Azeroth (BFA) - Platzhalter
		{id = 979998, name = "Placeholder Fish (BFA)", expansion = "BFA"},
		-- TODO: BFA Fische hier hinzufügen

		-- Legion - Platzhalter
		{id = 979997, name = "Placeholder Fish (Legion)", expansion = "Legion"},
		-- TODO: Legion Fische hier hinzufügen

		-- Warlords of Draenor (WoD) - Platzhalter
		{id = 979996, name = "Placeholder Fish (WoD)", expansion = "WoD"},
		-- TODO: WoD Fische hier hinzufügen

		-- Mists of Pandaria (MoP) - Platzhalter
		{id = 979995, name = "Placeholder Fish (MoP)", expansion = "MoP"},
		-- TODO: MoP Fische hier hinzufügen

		-- Cataclysm (Cata) - Platzhalter
		{id = 979994, name = "Placeholder Fish (Cata)", expansion = "Cata"},
		-- TODO: Cata Fische hier hinzufügen

		-- Wrath of the Lich King (Wrath) - Platzhalter
		{id = 979993, name = "Placeholder Fish (Wrath)", expansion = "Wrath"},
		-- TODO: Wrath Fische hier hinzufügen

		-- The Burning Crusade (TBC) - Platzhalter
		{id = 979992, name = "Placeholder Fish (TBC)", expansion = "TBC"},
		-- TODO: TBC Fische hier hinzufügen

		-- Classic/Vanilla - Platzhalter
		{id = 979991, name = "Placeholder Fish (Classic)", expansion = "Classic"},
		-- TODO: Classic Fische hier hinzufügen
	},

	-- ========================================
	-- HOLZ / LUMBER
	-- ========================================
	logging = {
		-- Midnight (MN)
		{id = 256963, name = "Thalassian Lumber", expansion = "MN"},

		-- The War Within (TWW)
		{id = 248012, name = "Dornic Fir Lumber", expansion = "TWW"},

		-- Dragonflight (DF)
		{id = 251773, name = "Dragonpine Lumber", expansion = "DF"},

		-- Shadowlands (SL)
		{id = 251772, name = "Arden Lumber", expansion = "SL"},

		-- Battle for Azeroth (BFA)
		{id = 251768, name = "Darkpine Lumber", expansion = "BFA"},

		-- Legion
		{id = 251767, name = "Fel-Touched Lumber", expansion = "Legion"},

		-- Warlords of Draenor (WoD)
		{id = 251766, name = "Shadowmoon Lumber", expansion = "WoD"},

		-- Mists of Pandaria (MoP)
		{id = 251763, name = "Bamboo Lumber", expansion = "MoP"},

		-- Cataclysm (Cata)
		{id = 251764, name = "Ashwood Lumber", expansion = "Cata"},

		-- Wrath of the Lich King (Wrath)
		{id = 251762, name = "Coldwind Lumber", expansion = "Wrath"},

		-- The Burning Crusade (TBC)
		{id = 242691, name = "Olemba Lumber", expansion = "TBC"},

		-- Classic/Vanilla
		{id = 245586, name = "Ironwood Lumber", expansion = "Classic"},
	},

	-- ========================================
	-- LEDER / LEATHER
	-- ========================================
	skinning = {
		-- Midnight (MN)
		{id = 238511, name = "Leerengehärtetes Leder", expansion = "MN", quality = 1},
		{id = 238512, name = "Leerengehärtetes Leder", expansion = "MN", quality = 2},
		{id = 238513, name = "Leerengehärtete Schuppen", expansion = "MN", quality = 1},
		{id = 238514, name = "Leerengehärtete Schuppen", expansion = "MN", quality = 2},
		{id = 238520, name = "Leerengehärtete Panzerung", expansion = "MN", quality = 1},
		{id = 238521, name = "Leerengehärtete Panzerung", expansion = "MN", quality = 2},
		{id = 238522, name = "Unvergleichliches Geflieder", expansion = "MN"},
		{id = 238525, name = "Fantastisches Fell", expansion = "MN"},
		{id = 238528, name = "Majestätische Klaue", expansion = "MN"},
		{id = 238529, name = "Majestätisches Fell", expansion = "MN"},
		{id = 238530, name = "Majestätische Flosse", expansion = "MN"},
	},

	-- ========================================
	-- SCHNEIDEREI / TAILORING
	-- ========================================
	tailoring = {
		-- Midnight (MN)
		{id = 236963, name = "Helles Leinen", expansion = "MN", quality = 1},
		{id = 236965, name = "Helles Leinen", expansion = "MN", quality = 2},
		{id = 237015, name = "Sonnenfeuerseide", expansion = "MN", quality = 1},
		{id = 237016, name = "Sonnenfeuerseide", expansion = "MN", quality = 2},
		{id = 237017, name = "Arkanostoff", expansion = "MN", quality = 2},
		{id = 237018, name = "Arkanostoff", expansion = "MN", quality = 1},
		{id = 239198, name = "Arkanostoffballen", expansion = "MN", quality = 1},
		{id = 239200, name = "Arkanostoffballen", expansion = "MN", quality = 2},
		{id = 239201, name = "Sonnenfeuerseidenballen", expansion = "MN", quality = 1},
		{id = 239202, name = "Sonnenfeuerseidenballen", expansion = "MN", quality = 2},
		{id = 239700, name = "Ballen aus Hellem Leder", expansion = "MN", quality = 1},
		{id = 239701, name = "Ballen aus Hellem Leder", expansion = "MN", quality = 2},
		{id = 239702, name = "Machtgetränkter Ballen aus hellem Leder", expansion = "MN", quality = 1},
		{id = 239703, name = "Machtgetränkter Ballen aus hellem Leder", expansion = "MN", quality = 2},
	},

	-- ========================================
	-- BERUFSWISSEN / PROFESSION KNOWLEDGE
	-- ========================================
	knowledge = {
		-- Midnight (MN) - Berufswissen
		-- Bergbau
		{id = 238597, name = "Glücksbringer des Höhlenforschers", expansion = "MN", profession = "mining", coords = {mapID = 2437, x = 41.98, y = 46.50, zone = "Zul'Aman", note = "Auf dem Baumstamm"}},
		{id = 238599, name = "Massiver Erzstanzer", expansion = "MN", profession = "mining", coords = {mapID = 2395, x = 37.98, y = 45.36, zone = "Immersangwald"}},
		{id = 238601, name = "Meißel des Amaniexperten", expansion = "MN", profession = "mining", coords = {mapID = 2536, x = 33.33, y = 65.85, zone = "Atal'Aman"}},
		{id = 238603, name = "Ersatzexpeditionsfackel", expansion = "MN", profession = "mining", coords = {mapID = 2413, x = 38.82, y = 65.90, zone = "Harandar"}},
		-- Kräuterkunde
		{id = 238466, name = "Thalassischer Phönixschwanz", expansion = "MN", profession = "herbalism"}, -- bekommt man durch sammeln von Blumen
		-- Schmiedekunst
		{id = 238600, name = "Sorgfältig gehämmerter Speer", expansion = "MN", profession = "blacksmithing", coords = {mapID = 2536, x = 33.33, y = 65.85, zone = "Atal'Aman"}},
		{id = 246322, name = "Schimmer des Schmiedekunstwissens von Midnight", expansion = "MN", profession = "blacksmithing"},
		{id = 263455, name = "Tagebuch des thalassischen Schmieds", expansion = "MN", profession = "blacksmithing"},
		-- Kürschner
		{id = 238625, name = "Edler leerengehärteter Balg", expansion = "MN", profession = "skinning"}, -- bekommt man durch kürschnern
		{id = 238626, name = "Manaerfüllter Knochen", expansion = "MN", profession = "skinning"}, -- bekommt man durch kürschnern
		{id = 238627, name = "Manadurchsetzte Probe", expansion = "MN", profession = "skinning"}, -- bekommt man durch kürschnern
		{id = 238629, name = "Kürschnermesser des Kaders", expansion = "MN", profession = "skinning", coords = {mapID = 2536, x = 45.16, y = 45.11, zone = "Atal'aman"}},
		{id = 238633, name = "Gerböl der Sin'dorei", expansion = "MN", profession = "skinning", coords = {mapID = 2393, x = 43.15, y = 55.69, zone = "Silbermond"}},
		{id = 263461, name = "Notizen des thalassischen Kürschners", expansion = "MN", profession = "skinning"}, -- Berufe Weekly
		-- Lederverarbeitung
		{id = 238628, name = "Bündel der Schmuckstücke des Gerbers", expansion = "MN", profession = "leatherworking", coords = {mapID = 2536, x = 45.24, y = 45.32, zone = "Atal'aman"}},
		{id = 246332, name = "Schimmer des Lederverarbeitungswissens von Midnight", expansion = "MN", profession = "leatherworking"}, -- Handwerksauftrag ?
		{id = 259200, name = "Gerberöl der Amani", expansion = "MN", profession = "leatherworking"}, -- Schatz
		{id = 259201, name = "Thalassisches Manaöl", expansion = "MN", profession = "leatherworking"}, -- Schatz
		
		-- The War Within (TWW)
		-- Bergbau
		{id = 224583, name = "Riesen-Steintafel", expansion = "TWW"},
		{id = 224838, name = "Nullsplitter", expansion = "TWW"},
		{id = 224584, name = "Erosionspolierte Steintafel", expansion = "TWW"},
		-- Kräuterkunde
		{id = 224835, name = "Tiefenhainwurzel", expansion = "TWW"},
		{id = 224264, name = "Tiefenhainblüte", expansion = "TWW"},
		{id = 224265, name = "Tiefenhainrose", expansion = "TWW"},
		-- Fischer
		{id = 224752, name = "Durchnässter Tagebucheintrag", expansion = "TWW"},
		-- kontrolliert und ok

		-- Dragonflight (DF)
		{id = 201300, name = "Alchemy Knowledge (DF)", expansion = "DF"},


		-- Shadowlands und älter haben kein Berufswissen-System
	},
}
