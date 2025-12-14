-- QuestAnnouncer Module für KriemhildeTools
local addonName = "KriemhildeTools"
local KT = LibStub("AceAddon-3.0"):GetAddon(addonName)
local LK = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- Module erstellen
local QuestAnnouncer = KT:NewModule("QuestAnnouncer", "AceEvent-3.0")

-- Lokale Variablen
local moduleActive = false
local announcedQuests = {}
local origUIErrorsAddMessage

-- Regex für Quest-Nachrichten (angepasst an Locale)
local QUEST_PATTERN = "(.-):%s*([-%d]+)%s*/%s*([-%d]+)%s*$"
if (GetLocale() == "zhCN") then
	QUEST_PATTERN = "(.-)：%s*([-%d]+)%s*/%s*([-%d]+)%s*$"
end

-- Filter: Blizzard Quest-Messages unterdrücken
local function FilterQuestMessages(self, text, ...)
	-- Prüfe ob es eine Quest-Message ist
	if text and string.match(text, QUEST_PATTERN) then
		-- Unterdrücke die Blizzard-Message
		return
	end
	-- Alle anderen Messages normal anzeigen
	return origUIErrorsAddMessage(self, text, ...)
end

-- Helper: Prüfe ob in Gruppe
local function InActiveGroup()
	if IsInRaid() then
		return GetNumGroupMembers() > 1
	elseif IsInGroup() then
		return GetNumSubgroupMembers() > 0
	end
	return false
end

-- Helper: Nachricht anzeigen
local function DisplayMessage(text)
	if not KT.db.profile.questAnnouncer.enabled then
		return
	end

	-- Wenn in Gruppe: Nur Chat
	if InActiveGroup() then
		if KT.db.profile.questAnnouncer.announceInGroup then
			if IsInRaid() then
				SendChatMessage(text, "RAID")
			else
				SendChatMessage(text, "PARTY")
			end
		end
	else
		-- Wenn alleine: Nur Raid Warning
		RaidNotice_AddMessage(RaidWarningFrame, text, ChatTypeInfo["RAID_WARNING"])
	end
end

-- Event Handler: UI_INFO_MESSAGE
function QuestAnnouncer:UI_INFO_MESSAGE(event, msgType, msgText)
	if not moduleActive then return end

	if (msgText ~= nil) then
		if (KT.db.profile.questAnnouncer.enabled) then
			-- Prüfe ob Nachricht Quest-Info enthält
			local cleanText = gsub(msgText, QUEST_PATTERN, "%1", 1)

			if (cleanText ~= msgText) then
				-- Parse Quest-Daten
				local _, _, objectiveName, numCurrent, numTotal = string.find(msgText, QUEST_PATTERN)
				local numRemaining = numTotal - numCurrent

				-- Fortschritt anzeigen
				if (numRemaining >= 0) then
					DisplayMessage(string.format(LK["KTQA Quest Fortschritt"], msgText))

					-- Wenn Objective komplett, prüfe ob gesamte Quest fertig
					if (numRemaining == 0) then
						local questID = C_QuestLog.GetSelectedQuest()
						if not questID then
							for i = 1, C_QuestLog.GetNumQuestLogEntries() do
								local info = C_QuestLog.GetInfo(i)
								if info and not info.isHeader and info.questID then
									questID = info.questID
									break
								end
							end
						end

						if questID then
							-- Prüfe ob bereits announced
							if not announcedQuests[questID] then
								C_Timer.After(0.5, function()
									local objectives = C_QuestLog.GetQuestObjectives(questID)
									if objectives then
										local allDone = true
										for _, obj in ipairs(objectives) do
											if obj.numRequired and obj.numRequired > 0 then
												if not obj.numFulfilled or obj.numFulfilled < obj.numRequired then
													allDone = false
													break
												end
											end
										end

										if allDone and not announcedQuests[questID] then
											announcedQuests[questID] = true
											local questTitle = C_QuestLog.GetTitleForQuestID(questID)
											DisplayMessage(string.format(LK["KTQA Quest komplett"], questTitle or "Quest"))

											-- Clear nach 30 Sekunden
											C_Timer.After(30, function()
												announcedQuests[questID] = nil
											end)
										end
									end
								end)
							end
						end
					end
				end
			end
		end
	end
end

-- Event Handler: QUEST_TURNED_IN
function QuestAnnouncer:QUEST_TURNED_IN(event, questID)
	if not moduleActive then return end

	if questID then
		announcedQuests[questID] = nil
	end
end

-- Enable
function QuestAnnouncer:OnEnable()
	if moduleActive then return end

	self:RegisterEvent("UI_INFO_MESSAGE")
	self:RegisterEvent("QUEST_TURNED_IN")

	-- Hook UIErrorsFrame um Blizzard Quest-Messages zu unterdrücken
	if not origUIErrorsAddMessage then
		origUIErrorsAddMessage = UIErrorsFrame.AddMessage
		UIErrorsFrame.AddMessage = FilterQuestMessages
	end

	moduleActive = true
	KT:Print(LK["Quest Announcer aktiviert"])
end

-- Disable
function QuestAnnouncer:OnDisable()
	if not moduleActive then return end

	self:UnregisterEvent("UI_INFO_MESSAGE")
	self:UnregisterEvent("QUEST_TURNED_IN")

	-- Restore original UIErrorsFrame function
	if origUIErrorsAddMessage then
		UIErrorsFrame.AddMessage = origUIErrorsAddMessage
		origUIErrorsAddMessage = nil
	end

	moduleActive = false
	KT:Print(LK["Quest Announcer deaktiviert"])
end

-- Initialisierung
function QuestAnnouncer:OnInitialize()
	-- Nichts zu tun
end

-- Check if enabled
function QuestAnnouncer:IsModuleEnabled()
	return moduleActive
end
