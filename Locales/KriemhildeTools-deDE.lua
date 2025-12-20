-- KriemhildeTools
-- Please use the Localization App on Curseforge to Update this
-- https://legacy.curseforge.com/wow/addons/kriemhildetools/localization

local LK = LibStub("AceLocale-3.0"):NewLocale("KriemhildeTools", "deDE", true)
if not LK then return end

-- Menu items
LK["Willkommen bei KriemhildeTools"] = true
LK["Willkommensnachricht"] = "Vielen Dank für die Nutzung von KriemhildeTools! Dieses Addon bietet nützliche Werkzeuge zur Verbesserung deines Spielerlebnisses."
LK["Schließen"] = true
LK["Start"] = true

-- Startup Messages
LK["Addon geladen"] = "Addon geladen! Tippe /kt für weitere Befehle."
LK["Willkommen"] = "Willkommen bei KriemhildeTools"
LK["Neue Version installiert"] = "Neue Version installiert:"
LK["Aktualisiert von"] = true
LK["auf"] = true
LK["Willkommen zurück"] = "Willkommen zurück! Das Addon wurde aktualisiert."
LK["QoL"] = true
LK["Farmbar"] = true
LK["Konfiguration"] = true
LK["punkt3"] = true
LK["punkt4"] = true
LK["punkt5"] = true
LK["Profile"] = true
LK["Weitere Funktionen Info"] = "Weitere Funktionen werden in zukünftigen Updates hinzugefügt."
LK["Inhalt für"] = true
LK["kommt bald"] = true

-- TooltipIDs
LK["Tooltip IDs anzeigen"] = true
LK["Tooltip IDs Beschreibung"] = "Zeige verschiedene IDs in Tooltips an (Items, Zauber, Auren, NPCs, Mounts)."
LK["Item ID anzeigen"] = true
LK["Item ID anzeigen Beschreibung"] = "Zeigt die Item-ID im Item-Tooltip an."
LK["Zauber ID anzeigen"] = true
LK["Zauber ID anzeigen Beschreibung"] = "Zeigt die Zauber-ID im Zauber-Tooltip an."
LK["Aura ID anzeigen"] = true
LK["Aura ID anzeigen Beschreibung"] = "Zeigt die Aura-ID im Aura-Tooltip an."
LK["Einheiten ID anzeigen"] = true
LK["Einheiten ID anzeigen Beschreibung"] = "Zeigt die NPC-ID im Einheiten-Tooltip an."
LK["Mount ID anzeigen"] = true
LK["Mount ID anzeigen Beschreibung"] = "Zeigt die Mount-ID im Mount-Tooltip an."
LK["TOOLTIP_ITEM"] = "Item"
LK["TOOLTIP_SPELL"] = "Zauber"
LK["TOOLTIP_AURA"] = "Aura"
LK["TOOLTIP_UNIT"] = "Einheit"
LK["TOOLTIP_MOUNT"] = "Mount"
LK["Tooltip IDs aktiviert"] = true
LK["Tooltip IDs deaktiviert"] = true

-- QuestAnnouncer
LK["Quest Announcer"] = true
LK["Quest Announcer Beschreibung"] = "Zeigt Quest-Fortschritt als Raid-Warnung und optional im Gruppenchat an."
LK["Quest Announcer aktivieren"] = true
LK["Quest Announcer aktivieren Beschreibung"] = "Aktiviert die Anzeige von Quest-Fortschritt."
LK["In Gruppe ankündigen"] = true
LK["In Gruppe ankündigen Beschreibung"] = "Sendet Quest-Fortschritt zusätzlich in den Gruppenchat (Party/Raid)."
LK["Fortschritt"] = true
LK["Quest abgeschlossen"] = true
LK["KTQA Quest komplett"] = "KTQA: %s - Quest abgeschlossen"
LK["KTQA Quest Fortschritt"] = "KTQA: %s"
LK["Quest Announcer aktiviert"] = true
LK["Quest Announcer deaktiviert"] = true

-- Profile Management
LK["Profile Verwaltung"] = true
LK["Profile Beschreibung"] = "Verwalte deine Addon-Profile. Erstelle separate Profile für jeden Charakter oder nutze ein gemeinsames Profil für alle."
LK["Aktuelles Profil"] = true
LK["Verfügbare Profile"] = true
LK["Neues Profil erstellen"] = true
LK["Profilname"] = true
LK["Erstellen"] = true
LK["Profil wählen"] = true
LK["Profil kopieren"] = true
LK["Von Profil kopieren"] = true
LK["Kopieren"] = true
LK["Profil löschen"] = true
LK["Löschen"] = true
LK["Profil umbenennen"] = true
LK["Neuer Name"] = true
LK["Umbenennen"] = true
LK["Standard-Profil verwenden"] = true
LK["Standard"] = true
LK["Profil wurde erstellt"] = true
LK["Profil wurde gelöscht"] = true
LK["Profil wurde umbenannt"] = true
LK["Profil wurde kopiert"] = true
LK["Wechsel zu Profil"] = true
LK["Bitte gib einen Profilnamen ein"] = true
LK["Dieses Profil existiert bereits"] = true
LK["Du kannst das aktuelle Profil nicht löschen"] = true
LK["Standard-Profil kann nicht gelöscht werden"] = true

-- Farmbar
LK["Erze"] = true
LK["Blumen"] = "Kräuter"
LK["Fische"] = true
LK["Holz"] = true
LK["Leder"] = true
LK["Stoffe"] = true
LK["Berufswissen"] = true
LK["Farmbar aktiviert"] = true
LK["Farmbar deaktiviert"] = true
LK["gesperrt"] = true
LK["entsperrt"] = true
LK["Befehle"] = true
LK["ein/ausschalten"] = true
LK["sperren/entsperren"] = true
LK["Einstellungen öffnen"] = true
LK["Farmbar Tooltip Info"] = "Zeigt getrackte Items dieser Kategorie"
LK["Rechtsklick für Einstellungen"] = true
LK["Im Inventar"] = true
LK["Keine Items für diese Erweiterung"] = true
LK["Farmbar-Modul konnte nicht geladen werden"] = true
LK["Farmbar Konfig Beschreibung"] = "Wähle einzelne Items oder alle in der Kategorie. Master-Checkboxen aktivieren alle Qualitätsstufen."
LK["Alle auswählen"] = true
LK["Alle abwählen"] = true
LK["Weiße Fische"] = true
LK["Grüne Fische"] = true
LK["Blaue Fische"] = true

-- Berufswissen
LK["Berufswissen"] = true
LK["Bergbau"] = true
LK["Kräuterkunde"] = true
LK["Schmiedekunst"] = true
LK["Kürschnerei"] = true
LK["Lederverarbeitung"] = true
LK["Bereits eingesammelt"] = true

-- FishingTracker
LK["FishingTracker aktiviert"] = "Angel-Tracker aktiviert"
LK["FishingTracker deaktiviert"] = "Angel-Tracker deaktiviert"
LK["Angel-Statistik"] = true
LK["Gesamte Würfe"] = true
LK["Würfe in Schwärmen"] = true
LK["Würfe in normalem Wasser"] = true
LK["Meistbesuchter Schwarm"] = true
LK["Wenigstbesuchter Schwarm"] = true
LK["Gefangene Fische"] = true
LK["Schwarm"] = true
LK["Würfe"] = true
LK["Noch keine Angel-Daten"] = "Du hast noch nicht geangelt! Gehe angeln um Statistiken zu sehen."
LK["Schwarm-Übersicht"] = true
LK["Fisch-Übersicht"] = true
LK["Alle Statistiken zurücksetzen"] = true
LK["Statistiken wurden zurückgesetzt"] = true

--@localization(locale="deDE", format="lua_additive_table", same-key-is-true=true, namespace="Konfiguration", table-name="LK", handle-unlocalized="ignore")@
