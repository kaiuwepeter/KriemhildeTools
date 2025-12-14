-- TooltipIDs Module für KriemhildeTools
local addonName = "KriemhildeTools"
local KT = LibStub("AceAddon-3.0"):GetAddon(addonName)
local LK = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- Module erstellen
local TooltipIDs = KT:NewModule("TooltipIDs", "AceEvent-3.0")

-- Lokale Variablen
local TooltipInfo = C_TooltipInfo
local TooltipProcessor = TooltipDataProcessor
local isEnabled = false
local callbacksRegistered = false -- Flag um mehrfache Registrierung zu verhindern

-- Helper: Prüfe ob Tooltip verboten ist
local function CheckForbidden(tooltip)
    return tooltip and tooltip:IsForbidden()
end

-- Helper: Füge ID-Zeile hinzu
local function AddLine(tooltip, id, type, color)
    if not tooltip or not id then return end

    if not KT.db then return end

    -- Prüfe ob dieser Typ angezeigt werden soll
    local typeKey = "show" .. type .. "ID"
    if not KT.db.profile.tooltipIDs[typeKey] then return end

    tooltip:AddLine(" ")
    tooltip:AddLine(LK["TOOLTIP_" .. type:upper()] .. " ID: |cff" .. (color or "FFFFCF") .. id .. "|r", 1, 1, 1)
end

-- Item ID Handler
local function ItemID(tooltip, data)
    if not isEnabled then return end
    if CheckForbidden(tooltip) then return end

    local itemID = data.id
    AddLine(tooltip, itemID, "Item", "FFFFCF")
end

-- Spell ID Handler
local function SpellID(tooltip, data)
    if not isEnabled then return end
    if CheckForbidden(tooltip) then return end

    local spellID = data.id
    AddLine(tooltip, spellID, "Spell", "71D5FF")
end

-- Aura ID Handler
local function AuraID(tooltip, data)
    if not isEnabled then return end
    if CheckForbidden(tooltip) then return end

    local auraID = data.id
    AddLine(tooltip, auraID, "Aura", "FF71D5")
end

-- Unit ID Handler
local function UnitID(tooltip, data)
    if not isEnabled then return end
    if CheckForbidden(tooltip) then return end

    -- Get GUID
    local unitGUID = data.guid
    if not unitGUID then return end

    -- Extract ID from GUID
    local unitID = select(6, strsplit("-", unitGUID))

    -- Check if ID exists (false for players)
    if not unitID then return end

    AddLine(tooltip, unitID, "Unit", "FFD571")
end

-- Mount ID Handler
local function MountID(tooltip, data)
    if not isEnabled then return end
    if CheckForbidden(tooltip) then return end

    local mountID = data.id
    AddLine(tooltip, mountID, "Mount", "D571FF")
end

-- Enable
function TooltipIDs:OnEnable()
    if isEnabled then return end

    -- Registriere Callbacks NUR EINMAL
    if not callbacksRegistered and TooltipProcessor then
        TooltipProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, ItemID)
        TooltipProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, SpellID)
        TooltipProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, AuraID)
        TooltipProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, UnitID)
        TooltipProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, MountID)
        callbacksRegistered = true
    end

    isEnabled = true
    KT:Print(LK["Tooltip IDs aktiviert"])
end

-- Disable
function TooltipIDs:OnDisable()
    if not isEnabled then return end

    -- Callbacks können nicht entfernt werden, setze nur Flag
    isEnabled = false

    KT:Print(LK["Tooltip IDs deaktiviert"])
end

-- Initialisierung
function TooltipIDs:OnInitialize()
    -- Nichts zu tun, Einstellungen werden über KT.db.profile.tooltipIDs verwaltet
end

-- Check if enabled
function TooltipIDs:IsModuleEnabled()
    return isEnabled
end
