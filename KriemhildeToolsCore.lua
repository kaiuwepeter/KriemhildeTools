-- KriemhildeTools Core
local addonName = "KriemhildeTools"
local addonVersion = (C_AddOns and C_AddOns.GetAddOnMetadata("KriemhildeTools", "Version")) or GetAddOnMetadata("KriemhildeTools", "Version") or "@project-version@"
local KT = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
local LK = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")
local icon = LibStub("LibDBIcon-1.0")

-- Minimap Button Icon
local minimapIcon = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
    type = "launcher",
    text = addonName,
    icon = "Interface\\Icons\\INV_Misc_QuestionMark",
    OnClick = function(self, button)
        if button == "LeftButton" then
            KT:ToggleMainFrame()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText("KriemhildeTools v" .. addonVersion)
        tooltip:AddLine("|cFFFFFFFFLinksklick:|r Hauptfenster öffnen", 1, 1, 1)
        tooltip:Show()
    end,
})

-- Addon Initialization
function KT:OnInitialize()
    -- Initialize saved variables
    self.db = LibStub("AceDB-3.0"):New("KriemhildeToolsDB", {
        profile = {
            minimap = {
                hide = false,
            },
            lastVersion = nil,
            tooltipIDs = {
                enabled = false,
                showItemID = false,
                showSpellID = false,
                showAuraID = false,
                showUnitID = false,
                showMountID = false,
            },
            questAnnouncer = {
                enabled = false,
                announceInGroup = true,
            },
        },
        global = {
            -- Charakter-spezifisches Tracking für eingesammelte Berufswissen-Items
            -- Struktur: collectedProfessionItems["CharName-RealmName"][itemID] = true
            collectedProfessionItems = {},
        },
    })

    -- Register minimap button
    icon:Register(addonName, minimapIcon, self.db.profile.minimap)

    -- Register slash commands
    self:RegisterChatCommand("kt", "SlashCommand")
    self:RegisterChatCommand("kriemhilde", "SlashCommand")

    -- Register /rl alias for /reload
    SLASH_RELOAD1 = "/rl"
    SlashCmdList["RELOAD"] = function()
        ReloadUI()
    end
end

function KT:OnEnable()
    -- Check for version update
    local lastVersion = self.db.profile.lastVersion
    if lastVersion and lastVersion ~= addonVersion then
        self:Print("|cFF00FF00" .. LK["Neue Version installiert"] .. "|r " .. addonVersion)
        self:Print(LK["Willkommen zurück"] .. " (" .. LK["Aktualisiert von"] .. " " .. lastVersion .. " " .. LK["auf"] .. " " .. addonVersion .. ")")
    elseif not lastVersion then
        self:Print(LK["Willkommen"] .. " v" .. addonVersion .. "!")
    end

    -- Update stored version
    self.db.profile.lastVersion = addonVersion

    -- Enable TooltipIDs module if configured
    if self.db.profile.tooltipIDs.enabled then
        local tooltipModule = self:GetModule("TooltipIDs")
        if tooltipModule then
            tooltipModule:Enable()
        end
    end

    -- Enable QuestAnnouncer module if configured
    if self.db.profile.questAnnouncer.enabled then
        local qaModule = self:GetModule("QuestAnnouncer")
        if qaModule then
            qaModule:Enable()
        end
    end

    -- Enable Farmbar module if configured
    if self.db.profile.farmbar and self.db.profile.farmbar.enabled then
        local farmbarModule = self:GetModule("Farmbar")
        if farmbarModule then
            farmbarModule:Enable()
        end
    end

    -- Enable FishingTracker module (always active)
    local fishingModule = self:GetModule("FishingTracker")
    if fishingModule then
        fishingModule:Enable()
    end

    self:Print(LK["Addon geladen"])
end

-- Slash Command Handler
function KT:SlashCommand(input)
    if input == "show" then
        self:ToggleMainFrame()
    elseif input == "hide" then
        if self.mainFrame then
            self.mainFrame:Hide()
        end
    elseif input == "fishing debug" then
        local fishingModule = self:GetModule("FishingTracker", true)
        if fishingModule then
            fishingModule:ToggleDebug()
        end
    else
        self:Print("Verfügbare Befehle:")
        self:Print("/kt show - Hauptfenster öffnen")
        self:Print("/kt hide - Hauptfenster schließen")
        self:Print("/kt fishing debug - Fishing Debug an/aus")
    end
end

-- Main Frame Toggle
function KT:ToggleMainFrame()
    if self.mainFrame then
        if self.mainFrame:IsShown() then
            self.mainFrame:Hide()
        else
            self.mainFrame:Show()
            -- Always show Start menu when reopening (after Show() so content is visible)
            self:ShowMenuContent("Start")
        end
    else
        self:CreateMainFrame()
    end
end

-- Create Main GUI Frame
function KT:CreateMainFrame()
    -- Create main frame (larger like Leatrix Plus)
    local frame = CreateFrame("Frame", "KriemhildeToolsMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(750, 500)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(600, 400, 1200, 900)

    -- Solid background
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.15, 1)

    -- Border
    frame:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

    -- Header bar
    local header = CreateFrame("Frame", nil, frame)
    header:SetPoint("TOPLEFT", 8, -8)
    header:SetPoint("TOPRIGHT", -8, -8)
    header:SetHeight(50)

    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetAllPoints()
    headerBg:SetColorTexture(0.2, 0.25, 0.35, 1)

    -- Title text
    local title = header:CreateFontString(nil, "OVERLAY")
    title:SetPoint("LEFT", 20, 0)
    title:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
    title:SetText(LK["Willkommen bei KriemhildeTools"] .. " v" .. addonVersion)
    title:SetTextColor(1, 1, 1, 1)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, header)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPoint("RIGHT", -10, 0)

    local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints()
    closeBg:SetColorTexture(0.8, 0.2, 0.2, 0.5)

    local closeX = closeBtn:CreateFontString(nil, "OVERLAY")
    closeX:SetAllPoints()
    closeX:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    closeX:SetText("×")
    closeX:SetTextColor(1, 1, 1, 1)

    closeBtn:SetScript("OnEnter", function(self)
        closeBg:SetColorTexture(0.9, 0.3, 0.3, 0.6)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        closeBg:SetColorTexture(0.8, 0.2, 0.2, 0.5)
    end)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Make header draggable
    header:EnableMouse(true)
    header:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frame:StartMoving()
        end
    end)
    header:SetScript("OnMouseUp", function(self, button)
        frame:StopMovingOrSizing()
    end)

    -- Resize grip (bottom-right corner)
    local resizeGrip = CreateFrame("Button", nil, frame)
    resizeGrip:SetSize(16, 16)
    resizeGrip:SetPoint("BOTTOMRIGHT", -4, 4)
    resizeGrip:EnableMouse(true)

    local resizeTexture = resizeGrip:CreateTexture(nil, "ARTWORK")
    resizeTexture:SetAllPoints()
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

    resizeGrip:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    resizeGrip:SetScript("OnMouseUp", function(self, button)
        frame:StopMovingOrSizing()
    end)

    -- Left Navigation Panel
    local navPanel = CreateFrame("Frame", nil, frame)
    navPanel:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 8, -10)
    navPanel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 8)
    navPanel:SetWidth(140)

    local navBg = navPanel:CreateTexture(nil, "BACKGROUND")
    navBg:SetAllPoints()
    navBg:SetColorTexture(0.08, 0.08, 0.12, 1)

    -- Navigation separator line
    local navSeparator = navPanel:CreateTexture(nil, "ARTWORK")
    navSeparator:SetPoint("TOPRIGHT")
    navSeparator:SetPoint("BOTTOMRIGHT")
    navSeparator:SetWidth(1)
    navSeparator:SetColorTexture(0.3, 0.3, 0.35, 1)

    -- Content area (right side)
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", navPanel, "TOPRIGHT", 15, 0)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 8)

    -- Store references
    frame.content = content
    frame.selectedMenu = "Start"
    frame.menuButtons = {}
    frame.expandedMenus = {} -- Track which parent menus are expanded
    frame.navPanel = navPanel -- Store nav panel reference

    -- Menu items (hierarchical structure with submenus)
    frame.menuItems = {
        {key = "Start", display = LK["Start"]},
        {key = "QoL", display = LK["QoL"]},
        {
            key = "Farmbar",
            display = LK["Farmbar"],
            children = {
                {key = "Farmbar_Konfiguration", display = LK["Konfiguration"], parent = "Farmbar"}
            }
        },
        {key = "punkt3", display = LK["punkt3"]},
        {
            key = "Berufswissen",
            display = LK["Berufswissen"],
            children = {
                {key = "Berufswissen_Bergbau", display = LK["Bergbau"], parent = "Berufswissen"},
                {key = "Berufswissen_Kraeuterkunde", display = LK["Kräuterkunde"], parent = "Berufswissen"},
                {key = "Berufswissen_Schmiedekunst", display = LK["Schmiedekunst"], parent = "Berufswissen"},
                {key = "Berufswissen_Kuerschnerei", display = LK["Kürschnerei"], parent = "Berufswissen"},
                {key = "Berufswissen_Lederverarbeitung", display = LK["Lederverarbeitung"], parent = "Berufswissen"}
            }
        },
        {key = "FishingStats", display = LK["Angel-Statistik"]},
        {key = "Profile", display = LK["Profile"]}
    }

    -- Function to create menu button
    local function CreateMenuButton(parent, menuKey, displayText, yOffset, indent, hasChildren, isChild)
        local btn = CreateFrame("Button", nil, parent)
        -- Submenu buttons are smaller to not overlap the separator line
        local btnWidth = isChild and 120 or 130
        btn:SetSize(btnWidth, 32)
        btn:SetPoint("TOPLEFT", 5 + (indent or 0), yOffset)
        btn.menuKey = menuKey
        btn.hasChildren = hasChildren
        btn.isExpanded = false
        btn.isChild = isChild

        -- Background (only for child items, not for parent items with children)
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.08, 0.08, 0.12, 0)
        btn.bg = bg

        -- Highlight (only show for items without children)
        local highlight = btn:CreateTexture(nil, "BORDER")
        highlight:SetAllPoints()
        highlight:SetColorTexture(0.25, 0.35, 0.55, 0)
        btn.highlight = highlight

        -- Text
        local btnText = btn:CreateFontString(nil, "OVERLAY")
        btnText:SetPoint("LEFT", 10, 0)
        btnText:SetFont("Fonts\\FRIZQT__.TTF", isChild and 12 or 13)
        btnText:SetText(displayText)
        btnText:SetTextColor(isChild and 0.7 or 0.8, isChild and 0.7 or 0.8, isChild and 0.75 or 0.85, 1)
        btnText:SetJustifyH("LEFT")
        btn.text = btnText

        -- Left accent line
        local accent = btn:CreateTexture(nil, "OVERLAY")
        accent:SetPoint("LEFT", 0, 0)
        accent:SetSize(3, 32)
        accent:SetColorTexture(0.3, 0.6, 1, 0)
        btn.accent = accent

        -- Hover effect (only for items without children or child items)
        btn:SetScript("OnEnter", function(self)
            -- No hover effect for parent items with children
            if not hasChildren and frame.selectedMenu ~= menuKey then
                self.bg:SetColorTexture(0.15, 0.15, 0.2, 0.5)
            end
        end)

        btn:SetScript("OnLeave", function(self)
            if not hasChildren and frame.selectedMenu ~= menuKey then
                self.bg:SetColorTexture(0.08, 0.08, 0.12, 0)
            end
        end)

        -- Click handler
        btn:SetScript("OnClick", function(self)
            if hasChildren then
                -- Toggle expand/collapse
                KT:ToggleMenuExpand(menuKey)
            else
                -- Show content
                KT:ShowMenuContent(menuKey)
            end
        end)

        return btn
    end

    -- Function to rebuild menu buttons (local function with access to parent scope)
    local function RebuildMenuButtons()
        -- Clear existing buttons
        for _, btn in pairs(frame.menuButtons) do
            btn:Hide()
            btn:SetParent(nil)
        end
        frame.menuButtons = {}

        local yOffset = -5
        local buttonIndex = 0

        -- Create buttons for all menu items and their children
        for i, menuItem in ipairs(frame.menuItems) do
            -- Create parent button
            local btn = CreateMenuButton(navPanel, menuItem.key, menuItem.display, yOffset, 0, menuItem.children ~= nil, false)
            frame.menuButtons[menuItem.key] = btn
            yOffset = yOffset - 34
            buttonIndex = buttonIndex + 1

            -- If menu has children and is expanded, create child buttons
            if menuItem.children and frame.expandedMenus[menuItem.key] then
                btn.isExpanded = true

                for j, child in ipairs(menuItem.children) do
                    local childBtn = CreateMenuButton(navPanel, child.key, child.display, yOffset, 15, false, true)
                    frame.menuButtons[child.key] = childBtn
                    yOffset = yOffset - 34
                    buttonIndex = buttonIndex + 1
                end
            end
        end

        -- Update selected state
        KT:UpdateMenuSelection(frame.selectedMenu)
    end

    -- Store function reference
    frame.RebuildMenuButtons = RebuildMenuButtons

    -- Initial menu build
    RebuildMenuButtons()

    -- Show initial content
    self:ShowMenuContent("Start")

    frame:Show()
    self.mainFrame = frame
end

-- Toggle menu expand/collapse
function KT:ToggleMenuExpand(menuKey)
    local frame = self.mainFrame
    if not frame then return end

    -- Toggle expanded state
    frame.expandedMenus[menuKey] = not frame.expandedMenus[menuKey]

    -- Rebuild menu to show/hide children
    if frame.RebuildMenuButtons then
        frame.RebuildMenuButtons()
    end
end

-- Update menu selection visual state
function KT:UpdateMenuSelection(menuName)
    local frame = self.mainFrame
    if not frame then return end

    for name, btn in pairs(frame.menuButtons) do
        -- Only highlight items without children (leaf nodes)
        if name == menuName and not btn.hasChildren then
            btn.bg:SetColorTexture(0.2, 0.25, 0.35, 1)
            btn.highlight:SetColorTexture(0.25, 0.35, 0.55, 0.3)
            btn.accent:SetColorTexture(0.3, 0.6, 1, 1)
            btn.text:SetTextColor(1, 1, 1, 1)
        else
            -- Reset to default state
            local isChild = btn.isChild or false
            btn.bg:SetColorTexture(0.08, 0.08, 0.12, 0)
            btn.highlight:SetColorTexture(0.25, 0.35, 0.55, 0)
            btn.accent:SetColorTexture(0.3, 0.6, 1, 0)
            btn.text:SetTextColor(isChild and 0.7 or 0.8, isChild and 0.7 or 0.8, isChild and 0.75 or 0.85, 1)
        end
    end
end

-- Function to show content for selected menu
function KT:ShowMenuContent(menuName)
    local frame = self.mainFrame
    if not frame then return end

    frame.selectedMenu = menuName
    self:UpdateMenuSelection(menuName)

    -- Clear existing content
    if frame.contentFrame then
        frame.contentFrame:Hide()
        frame.contentFrame = nil
    end

    -- Create new content based on selection
    local contentFrame = CreateFrame("Frame", nil, frame.content)
    contentFrame:SetAllPoints()
    frame.contentFrame = contentFrame

    if menuName == "Start" then
        -- Welcome message
        local welcomeText = contentFrame:CreateFontString(nil, "OVERLAY")
        welcomeText:SetPoint("TOPLEFT", 10, -10)
        welcomeText:SetPoint("TOPRIGHT", -10, -10)
        welcomeText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        welcomeText:SetText(LK["Willkommensnachricht"])
        welcomeText:SetTextColor(0.9, 0.9, 0.95, 1)
        welcomeText:SetJustifyH("LEFT")
        welcomeText:SetJustifyV("TOP")
        welcomeText:SetWordWrap(true)

        -- Accent line
        local accentLine = contentFrame:CreateTexture(nil, "ARTWORK")
        accentLine:SetPoint("TOPLEFT", welcomeText, "BOTTOMLEFT", 0, -10)
        accentLine:SetSize(100, 2)
        accentLine:SetColorTexture(0.3, 0.6, 1, 0.8)

        -- Info box
        local infoBox = CreateFrame("Frame", nil, contentFrame)
        infoBox:SetPoint("TOPLEFT", welcomeText, "BOTTOMLEFT", -10, -30)
        infoBox:SetPoint("TOPRIGHT", welcomeText, "BOTTOMRIGHT", 10, -30)
        infoBox:SetHeight(80)

        local infoBg = infoBox:CreateTexture(nil, "BACKGROUND")
        infoBg:SetAllPoints()
        infoBg:SetColorTexture(0.15, 0.2, 0.3, 0.7)

        local infoText = infoBox:CreateFontString(nil, "OVERLAY")
        infoText:SetPoint("CENTER")
        infoText:SetFont("Fonts\\FRIZQT__.TTF", 12)
        infoText:SetText(LK["Weitere Funktionen Info"])
        infoText:SetTextColor(0.7, 0.8, 0.9, 1)
        infoText:SetJustifyH("CENTER")
    elseif menuName == "QoL" then
        -- QoL Menu mit TooltipIDs
        self:CreateQoLContent(contentFrame)
    elseif menuName == "Profile" then
        -- Profile Management
        self:CreateProfileContent(contentFrame)
    elseif menuName == "Farmbar_Konfiguration" then
        -- Farmbar Configuration
        self:CreateFarmbarConfig(contentFrame)
    elseif menuName == "Berufswissen_Bergbau" then
        -- Profession Knowledge - Mining
        self:CreateProfessionKnowledgeContent(contentFrame, "mining")
    elseif menuName == "Berufswissen_Kraeuterkunde" then
        -- Profession Knowledge - Herbalism
        self:CreateProfessionKnowledgeContent(contentFrame, "herbalism")
    elseif menuName == "Berufswissen_Schmiedekunst" then
        -- Profession Knowledge - Blacksmithing
        self:CreateProfessionKnowledgeContent(contentFrame, "blacksmithing")
    elseif menuName == "Berufswissen_Kuerschnerei" then
        -- Profession Knowledge - Skinning
        self:CreateProfessionKnowledgeContent(contentFrame, "skinning")
    elseif menuName == "Berufswissen_Lederverarbeitung" then
        -- Profession Knowledge - Leatherworking
        self:CreateProfessionKnowledgeContent(contentFrame, "leatherworking")
    elseif menuName == "FishingStats" then
        -- Fishing Statistics
        self:CreateFishingStatsContent(contentFrame)
    else
        -- Placeholder for other menu items
        local displayName = LK[menuName] or menuName
        local title = contentFrame:CreateFontString(nil, "OVERLAY")
        title:SetPoint("TOP", 0, -20)
        title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        title:SetText(displayName)
        title:SetTextColor(1, 1, 1, 1)

        local desc = contentFrame:CreateFontString(nil, "OVERLAY")
        desc:SetPoint("TOP", title, "BOTTOM", 0, -20)
        desc:SetFont("Fonts\\FRIZQT__.TTF", 12)
        desc:SetText(LK["Inhalt für"] .. " " .. displayName .. " " .. LK["kommt bald"] .. "...")
        desc:SetTextColor(0.7, 0.7, 0.75, 1)
    end

    contentFrame:Show()
end

-- Create QoL Content with TooltipIDs Options
function KT:CreateQoLContent(contentFrame)
    -- Helper: Create modern option card
    local function CreateOptionCard(parent, xPos, yPos, width, height)
        local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        card:SetPoint("TOPLEFT", xPos, yPos)
        card:SetSize(width, height)

        -- Background
        local bg = card:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.12, 0.14, 0.18, 0.95)

        -- Border with gradient effect
        card:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        card:SetBackdropBorderColor(0.25, 0.35, 0.5, 0.8)

        -- Subtle top accent
        local accent = card:CreateTexture(nil, "ARTWORK")
        accent:SetPoint("TOPLEFT", 3, -3)
        accent:SetPoint("TOPRIGHT", -3, -3)
        accent:SetHeight(2)
        accent:SetColorTexture(0.3, 0.6, 1, 0.6)

        return card
    end

    -- Helper: Create compact horizontal checkbox
    local function CreateCompactCheckbox(parent, xPos, yPos, labelText, tooltipText, dbKey, onClick)
        local container = CreateFrame("Frame", nil, parent)
        container:SetPoint("TOPLEFT", xPos, yPos)
        container:SetSize(90, 24)

        local checkbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
        checkbox:SetPoint("LEFT", 0, 0)
        checkbox:SetSize(18, 18)

        local label = container:CreateFontString(nil, "OVERLAY")
        label:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
        label:SetFont("Fonts\\FRIZQT__.TTF", 10)
        label:SetText(labelText)
        label:SetTextColor(0.95, 0.95, 1, 1)

        -- Hover effect
        container:EnableMouse(true)
        container:SetScript("OnEnter", function(self)
            if checkbox:IsEnabled() then
                label:SetTextColor(1, 1, 1, 1)
            end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(labelText, 1, 1, 1)
            if tooltipText then
                GameTooltip:AddLine(tooltipText, 0.7, 0.8, 0.9, true)
            end
            GameTooltip:Show()
        end)
        container:SetScript("OnLeave", function(self)
            if checkbox:IsEnabled() then
                label:SetTextColor(0.95, 0.95, 1, 1)
            else
                label:SetTextColor(0.5, 0.5, 0.55, 1)
            end
            GameTooltip:Hide()
        end)
        container:SetScript("OnMouseDown", function(self)
            if checkbox:IsEnabled() then
                checkbox:Click()
            end
        end)

        -- Set initial state
        checkbox:SetChecked(dbKey and KT.db.profile.tooltipIDs[dbKey] or false)

        -- Click handler
        checkbox:SetScript("OnClick", function(self)
            local isChecked = self:GetChecked()
            if dbKey then
                KT.db.profile.tooltipIDs[dbKey] = isChecked
            end
            if onClick then
                onClick(isChecked)
            end
        end)

        container.checkbox = checkbox
        container.label = label
        return container
    end

    -- Create Tooltip IDs Card (compact size)
    local card = CreateOptionCard(contentFrame, 15, -15, 530, 150)

    -- Card Title
    local cardTitle = card:CreateFontString(nil, "OVERLAY")
    cardTitle:SetPoint("TOPLEFT", 12, -10)
    cardTitle:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    cardTitle:SetText(LK["Tooltip IDs anzeigen"])
    cardTitle:SetTextColor(0.4, 0.7, 1, 1)

    -- Card Description
    local cardDesc = card:CreateFontString(nil, "OVERLAY")
    cardDesc:SetPoint("TOPLEFT", cardTitle, "BOTTOMLEFT", 0, -4)
    cardDesc:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, -28)
    cardDesc:SetFont("Fonts\\FRIZQT__.TTF", 9)
    cardDesc:SetText(LK["Tooltip IDs Beschreibung"])
    cardDesc:SetTextColor(0.65, 0.7, 0.75, 1)
    cardDesc:SetJustifyH("LEFT")
    cardDesc:SetWordWrap(true)
    cardDesc:SetMaxLines(2)

    -- Divider line
    local divider = card:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPLEFT", cardDesc, "BOTTOMLEFT", -8, -6)
    divider:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -52)
    divider:SetHeight(1)
    divider:SetColorTexture(0.2, 0.3, 0.4, 0.5)

    -- Master Enable Checkbox (compact)
    local masterContainer = CreateFrame("Frame", nil, card)
    masterContainer:SetPoint("TOPLEFT", 12, -60)
    masterContainer:SetSize(card:GetWidth() - 24, 28)

    local masterCheckbox = CreateFrame("CheckButton", nil, masterContainer, "UICheckButtonTemplate")
    masterCheckbox:SetPoint("LEFT", 0, 0)
    masterCheckbox:SetSize(20, 20)

    local masterLabel = masterContainer:CreateFontString(nil, "OVERLAY")
    masterLabel:SetPoint("LEFT", masterCheckbox, "RIGHT", 6, 0)
    masterLabel:SetFont("Fonts\\FRIZQT__.TTF", 11)
    masterLabel:SetText(LK["Tooltip IDs anzeigen"])
    masterLabel:SetTextColor(0.95, 0.95, 1, 1)

    masterContainer:EnableMouse(true)
    masterContainer:SetScript("OnEnter", function(self)
        masterLabel:SetTextColor(1, 1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(LK["Tooltip IDs anzeigen"], 1, 1, 1)
        GameTooltip:AddLine(LK["Tooltip IDs Beschreibung"], 0.7, 0.8, 0.9, true)
        GameTooltip:Show()
    end)
    masterContainer:SetScript("OnLeave", function(self)
        masterLabel:SetTextColor(0.95, 0.95, 1, 1)
        GameTooltip:Hide()
    end)
    masterContainer:SetScript("OnMouseDown", function(self)
        masterCheckbox:Click()
    end)

    masterCheckbox:SetChecked(KT.db.profile.tooltipIDs.enabled or false)

    -- Store ID checkboxes for enabling/disabling
    local idCheckboxes = {}

    -- Create horizontal row of ID checkboxes (compact spacing)
    local startY = -95
    local startX = 12
    local spacing = 95

    idCheckboxes.item = CreateCompactCheckbox(card, startX, startY, "Item ID", LK["Item ID anzeigen Beschreibung"], "showItemID", nil)
    idCheckboxes.spell = CreateCompactCheckbox(card, startX + spacing, startY, "Spell ID", LK["Zauber ID anzeigen Beschreibung"], "showSpellID", nil)
    idCheckboxes.aura = CreateCompactCheckbox(card, startX + spacing * 2, startY, "Aura ID", LK["Aura ID anzeigen Beschreibung"], "showAuraID", nil)
    idCheckboxes.unit = CreateCompactCheckbox(card, startX + spacing * 3, startY, "Unit ID", LK["Einheiten ID anzeigen Beschreibung"], "showUnitID", nil)
    idCheckboxes.mount = CreateCompactCheckbox(card, startX + spacing * 4, startY, "Mount ID", LK["Mount ID anzeigen Beschreibung"], "showMountID", nil)

    -- Function to update ID checkbox states
    local function UpdateIDCheckboxStates()
        local enabled = masterCheckbox:GetChecked()
        for _, container in pairs(idCheckboxes) do
            if enabled then
                container.checkbox:Enable()
                container.label:SetTextColor(0.95, 0.95, 1, 1)
            else
                container.checkbox:Disable()
                container.label:SetTextColor(0.5, 0.5, 0.55, 1)
            end
        end
    end

    -- Master checkbox click handler
    masterCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        KT.db.profile.tooltipIDs.enabled = isChecked

        local tooltipModule = KT:GetModule("TooltipIDs")
        if tooltipModule then
            if isChecked then
                tooltipModule:Enable()
            else
                tooltipModule:Disable()
            end
        end

        UpdateIDCheckboxStates()
    end)

    -- Initialize checkbox states
    UpdateIDCheckboxStates()

    -- QuestAnnouncer Card (below TooltipIDs)
    local qaCard = CreateOptionCard(contentFrame, 15, -180, 530, 120)

    -- Card Title
    local qaTitle = qaCard:CreateFontString(nil, "OVERLAY")
    qaTitle:SetPoint("TOPLEFT", 12, -10)
    qaTitle:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    qaTitle:SetText(LK["Quest Announcer"])
    qaTitle:SetTextColor(0.4, 0.7, 1, 1)

    -- Card Description
    local qaDesc = qaCard:CreateFontString(nil, "OVERLAY")
    qaDesc:SetPoint("TOPLEFT", qaTitle, "BOTTOMLEFT", 0, -4)
    qaDesc:SetPoint("TOPRIGHT", qaCard, "TOPRIGHT", -12, -28)
    qaDesc:SetFont("Fonts\\FRIZQT__.TTF", 9)
    qaDesc:SetText(LK["Quest Announcer Beschreibung"])
    qaDesc:SetTextColor(0.65, 0.7, 0.75, 1)
    qaDesc:SetJustifyH("LEFT")
    qaDesc:SetWordWrap(true)
    qaDesc:SetMaxLines(2)

    -- Divider line
    local qaDivider = qaCard:CreateTexture(nil, "ARTWORK")
    qaDivider:SetPoint("TOPLEFT", qaDesc, "BOTTOMLEFT", -8, -6)
    qaDivider:SetPoint("TOPRIGHT", qaCard, "TOPRIGHT", -8, -52)
    qaDivider:SetHeight(1)
    qaDivider:SetColorTexture(0.2, 0.3, 0.4, 0.5)

    -- Enable Checkbox
    local qaEnableContainer = CreateFrame("Frame", nil, qaCard)
    qaEnableContainer:SetPoint("TOPLEFT", 12, -60)
    qaEnableContainer:SetSize(qaCard:GetWidth() - 24, 24)

    local qaEnableCheckbox = CreateFrame("CheckButton", nil, qaEnableContainer, "UICheckButtonTemplate")
    qaEnableCheckbox:SetPoint("LEFT", 0, 0)
    qaEnableCheckbox:SetSize(18, 18)

    local qaEnableLabel = qaEnableContainer:CreateFontString(nil, "OVERLAY")
    qaEnableLabel:SetPoint("LEFT", qaEnableCheckbox, "RIGHT", 4, 0)
    qaEnableLabel:SetFont("Fonts\\FRIZQT__.TTF", 10)
    qaEnableLabel:SetText(LK["Quest Announcer aktivieren"])
    qaEnableLabel:SetTextColor(0.95, 0.95, 1, 1)

    qaEnableContainer:EnableMouse(true)
    qaEnableContainer:SetScript("OnEnter", function(self)
        if qaEnableCheckbox:IsEnabled() then
            qaEnableLabel:SetTextColor(1, 1, 1, 1)
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(LK["Quest Announcer aktivieren"], 1, 1, 1)
        GameTooltip:AddLine(LK["Quest Announcer aktivieren Beschreibung"], 0.7, 0.8, 0.9, true)
        GameTooltip:Show()
    end)
    qaEnableContainer:SetScript("OnLeave", function(self)
        if qaEnableCheckbox:IsEnabled() then
            qaEnableLabel:SetTextColor(0.95, 0.95, 1, 1)
        else
            qaEnableLabel:SetTextColor(0.5, 0.5, 0.55, 1)
        end
        GameTooltip:Hide()
    end)
    qaEnableContainer:SetScript("OnMouseDown", function(self)
        if qaEnableCheckbox:IsEnabled() then
            qaEnableCheckbox:Click()
        end
    end)

    qaEnableCheckbox:SetChecked(KT.db.profile.questAnnouncer.enabled or false)

    -- Group Announce Checkbox
    local qaGroupContainer = CreateFrame("Frame", nil, qaCard)
    qaGroupContainer:SetPoint("TOPLEFT", 12, -88)
    qaGroupContainer:SetSize(qaCard:GetWidth() - 24, 24)

    local qaGroupCheckbox = CreateFrame("CheckButton", nil, qaGroupContainer, "UICheckButtonTemplate")
    qaGroupCheckbox:SetPoint("LEFT", 0, 0)
    qaGroupCheckbox:SetSize(18, 18)

    local qaGroupLabel = qaGroupContainer:CreateFontString(nil, "OVERLAY")
    qaGroupLabel:SetPoint("LEFT", qaGroupCheckbox, "RIGHT", 4, 0)
    qaGroupLabel:SetFont("Fonts\\FRIZQT__.TTF", 10)
    qaGroupLabel:SetText(LK["In Gruppe ankündigen"])
    qaGroupLabel:SetTextColor(0.95, 0.95, 1, 1)

    qaGroupContainer:EnableMouse(true)
    qaGroupContainer:SetScript("OnEnter", function(self)
        if qaGroupCheckbox:IsEnabled() then
            qaGroupLabel:SetTextColor(1, 1, 1, 1)
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(LK["In Gruppe ankündigen"], 1, 1, 1)
        GameTooltip:AddLine(LK["In Gruppe ankündigen Beschreibung"], 0.7, 0.8, 0.9, true)
        GameTooltip:Show()
    end)
    qaGroupContainer:SetScript("OnLeave", function(self)
        if qaGroupCheckbox:IsEnabled() then
            qaGroupLabel:SetTextColor(0.95, 0.95, 1, 1)
        else
            qaGroupLabel:SetTextColor(0.5, 0.5, 0.55, 1)
        end
        GameTooltip:Hide()
    end)
    qaGroupContainer:SetScript("OnMouseDown", function(self)
        if qaGroupCheckbox:IsEnabled() then
            qaGroupCheckbox:Click()
        end
    end)

    qaGroupCheckbox:SetChecked(KT.db.profile.questAnnouncer.announceInGroup or false)

    -- Enable checkbox click handler
    qaEnableCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        KT.db.profile.questAnnouncer.enabled = isChecked

        local qaModule = KT:GetModule("QuestAnnouncer")
        if qaModule then
            if isChecked then
                qaModule:Enable()
            else
                qaModule:Disable()
            end
        end
    end)

    -- Group checkbox click handler
    qaGroupCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        KT.db.profile.questAnnouncer.announceInGroup = isChecked
    end)
end

-- Create Farmbar Configuration Content
function KT:CreateFarmbarConfig(contentFrame)
	local farmbarModule = self:GetModule("Farmbar", true)
	if not farmbarModule then
		local errorText = contentFrame:CreateFontString(nil, "OVERLAY")
		errorText:SetPoint("CENTER")
		errorText:SetFont("Fonts\\FRIZQT__.TTF", 14)
		errorText:SetText(LK["Farmbar-Modul konnte nicht geladen werden"])
		errorText:SetTextColor(1, 0.2, 0.2, 1)
		return
	end

	local db = KT.db.profile.farmbar

	-- Kategorien und Expansionen
	local categories = {
		{key = "herbalism", name = LK["Blumen"], icon = "Interface\\Icons\\Trade_Herbalism"},
		{key = "mining", name = LK["Erze"], icon = "Interface\\Icons\\Trade_Mining"},
		{key = "fishing", name = LK["Fische"], icon = "Interface\\Icons\\Trade_Fishing"},
		{key = "logging", name = LK["Holz"], icon = "Interface\\Icons\\ui_resourcelumberwarwithin"},
		{key = "skinning", name = LK["Leder"], icon = "Interface\\Icons\\Trade_LeatherWorking"},
		{key = "knowledge", name = LK["Berufswissen"], icon = "Interface\\Icons\\inv_scroll_11"},
	}

	local expansions = {
		{key = "MN", name = "Midnight", order = 1},
		{key = "TWW", name = "TWW", order = 2},
		{key = "DF", name = "DF", order = 3},
		{key = "SL", name = "SL", order = 4},
		{key = "BFA", name = "BFA", order = 5},
		{key = "Legion", name = "Legion", order = 6},
		{key = "WoD", name = "WoD", order = 7},
		{key = "MoP", name = "MoP", order = 8},
		{key = "Cata", name = "Cata", order = 9},
		{key = "Wrath", name = "Wrath", order = 10},
		{key = "TBC", name = "TBC", order = 11},
		{key = "Classic", name = "Classic", order = 12},
	}

	-- State
	local selectedCategory = "herbalism"
	local selectedExpansion = "TWW"

	-- Container
	local container = CreateFrame("Frame", nil, contentFrame)
	container:SetAllPoints()

	-- Title
	local title = container:CreateFontString(nil, "OVERLAY")
	title:SetPoint("TOP", 0, -5)
	title:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
	title:SetText(LK["Farmbar"] .. " - " .. LK["Konfiguration"])
	title:SetTextColor(1, 1, 1, 1)

	-- Kategorie-Tabs (horizontal)
	local tabContainer = CreateFrame("Frame", nil, container)
	tabContainer:SetPoint("TOP", title, "BOTTOM", 0, -5)
	tabContainer:SetSize(560, 32)

	-- Expansion-Buttons Container (früher erstellen für Click-Handler)
	local expContainer = CreateFrame("Frame", nil, container)
	expContainer:SetPoint("TOP", tabContainer, "BOTTOM", 0, -3)
	expContainer:SetSize(560, 22)

	-- Items ScrollFrame (früher erstellen für Click-Handler)
	local itemsFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
	itemsFrame:SetPoint("TOPLEFT", expContainer, "BOTTOMLEFT", 0, -3)
	itemsFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -25, 5)

	local itemsContent = CreateFrame("Frame", nil, itemsFrame)
	itemsContent:SetSize(560, 1)
	itemsFrame:SetScrollChild(itemsContent)
	itemsFrame.content = itemsContent

	-- Variablen vordeklarieren
	local categoryTabs = {}
	local expansionButtons = {}

	-- Kategorie-Tabs erstellen
	local tabWidth = 560 / #categories
	for i, category in ipairs(categories) do
		local tab = CreateFrame("Button", nil, tabContainer)
		tab:SetSize(tabWidth - 2, 30)
		tab:SetPoint("LEFT", (i-1) * tabWidth, 0)

		local bg = tab:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.15, 0.15, 0.2, 0.8)
		tab.bg = bg

		local icon = tab:CreateTexture(nil, "ARTWORK")
		icon:SetSize(20, 20)
		icon:SetPoint("CENTER")
		icon:SetTexture(category.icon)
		tab.icon = icon

		tab:SetScript("OnEnter", function(self)
			if selectedCategory ~= category.key then
				self.bg:SetColorTexture(0.2, 0.2, 0.3, 0.9)
			end
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(category.name)
			GameTooltip:Show()
		end)

		tab:SetScript("OnLeave", function(self)
			if selectedCategory ~= category.key then
				self.bg:SetColorTexture(0.15, 0.15, 0.2, 0.8)
			end
			GameTooltip:Hide()
		end)

		tab:SetScript("OnClick", function(self)
			selectedCategory = category.key
			KT:UpdateFarmbarConfig(container, selectedCategory, selectedExpansion, categoryTabs, expansionButtons, itemsFrame, farmbarModule, db)
		end)

		categoryTabs[category.key] = tab
	end

	-- Expansion-Buttons erstellen
	local expWidth = 560 / #expansions
	for i, expansion in ipairs(expansions) do
		local btn = CreateFrame("Button", nil, expContainer)
		btn:SetSize(expWidth - 1, 20)
		btn:SetPoint("LEFT", (i-1) * expWidth, 0)

		local bg = btn:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.1, 0.1, 0.15, 0.9)
		btn.bg = bg

		local text = btn:CreateFontString(nil, "OVERLAY")
		text:SetAllPoints()
		text:SetFont("Fonts\\FRIZQT__.TTF", 9)
		text:SetText(expansion.name)
		text:SetTextColor(0.7, 0.7, 0.75, 1)
		btn.text = text

		btn:SetScript("OnEnter", function(self)
			if selectedExpansion ~= expansion.key then
				self.bg:SetColorTexture(0.15, 0.15, 0.22, 1)
			end
		end)

		btn:SetScript("OnLeave", function(self)
			if selectedExpansion ~= expansion.key then
				self.bg:SetColorTexture(0.1, 0.1, 0.15, 0.9)
			end
		end)

		btn:SetScript("OnClick", function(self)
			selectedExpansion = expansion.key
			KT:UpdateFarmbarConfig(container, selectedCategory, selectedExpansion, categoryTabs, expansionButtons, itemsFrame, farmbarModule, db)
		end)

		expansionButtons[expansion.key] = btn
	end

	-- Initial update
	KT:UpdateFarmbarConfig(container, selectedCategory, selectedExpansion, categoryTabs, expansionButtons, itemsFrame, farmbarModule, db)
end

-- Update Farmbar Config (Items anzeigen)
function KT:UpdateFarmbarConfig(container, selectedCategory, selectedExpansion, categoryTabs, expansionButtons, itemsFrame, farmbarModule, db)
	-- Update Tab-Highlights
	for key, tab in pairs(categoryTabs) do
		if key == selectedCategory then
			tab.bg:SetColorTexture(0.25, 0.35, 0.55, 1)
		else
			tab.bg:SetColorTexture(0.15, 0.15, 0.2, 0.8)
		end
	end

	-- Update Expansion-Button-Highlights
	for key, btn in pairs(expansionButtons) do
		if key == selectedExpansion then
			btn.bg:SetColorTexture(0.2, 0.3, 0.5, 1)
			btn.text:SetTextColor(1, 1, 1, 1)
		else
			btn.bg:SetColorTexture(0.1, 0.1, 0.15, 0.9)
			btn.text:SetTextColor(0.7, 0.7, 0.75, 1)
		end
	end

	-- Clear old items
	if itemsFrame.content.items then
		for _, item in ipairs(itemsFrame.content.items) do
			item:Hide()
			item:SetParent(nil)
		end
	end
	itemsFrame.content.items = {}

	-- Get items for selected category and expansion
	local itemsByExp = farmbarModule:GetItemsByExpansion(selectedCategory)
	local items = itemsByExp[selectedExpansion] or {}

	if #items == 0 then
		local noItems = itemsFrame.content:CreateFontString(nil, "OVERLAY")
		noItems:SetPoint("CENTER")
		noItems:SetFont("Fonts\\FRIZQT__.TTF", 11)
		noItems:SetText(LK["Keine Items für diese Erweiterung"])
		noItems:SetTextColor(0.6, 0.6, 0.65, 1)
		table.insert(itemsFrame.content.items, noItems)
		return
	end

	local yOffset = -5

	-- Beschreibung
	local desc = itemsFrame.content:CreateFontString(nil, "OVERLAY")
	desc:SetPoint("TOPLEFT", 5, yOffset)
	desc:SetPoint("RIGHT", -5, 0)
	desc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	desc:SetText(LK["Farmbar Konfig Beschreibung"])
	desc:SetTextColor(0.7, 0.7, 0.75, 1)
	desc:SetJustifyH("LEFT")
	desc:SetWordWrap(true)
	table.insert(itemsFrame.content.items, desc)
	yOffset = yOffset - 30

	-- Alle auswählen/abwählen Button
	local selectAllBtn = CreateFrame("Button", nil, itemsFrame.content, "UIPanelButtonTemplate")
	selectAllBtn:SetSize(120, 22)
	selectAllBtn:SetPoint("TOPLEFT", 5, yOffset)
	selectAllBtn:SetText(LK["Alle auswählen"])
	selectAllBtn:SetScript("OnClick", function(self)
		local allSelected = true
		-- Prüfe ob alle bereits ausgewählt sind
		for _, item in ipairs(items) do
			local found = false
			for _, id in ipairs(db.categories[selectedCategory].items) do
				if id == item.id then
					found = true
					break
				end
			end
			if not found then
				allSelected = false
				break
			end
		end

		if allSelected then
			-- Alle abwählen
			for _, item in ipairs(items) do
				farmbarModule:RemoveItemFromCategory(selectedCategory, item.id)
			end
			self:SetText(LK["Alle auswählen"])
		else
			-- Alle auswählen
			for _, item in ipairs(items) do
				farmbarModule:AddItemToCategory(selectedCategory, item.id)
			end
			self:SetText(LK["Alle abwählen"])
		end
		farmbarModule:UpdateBars()
		KT:UpdateFarmbarConfig(container, selectedCategory, selectedExpansion, categoryTabs, expansionButtons, itemsFrame, farmbarModule, db)
	end)
	table.insert(itemsFrame.content.items, selectAllBtn)
	yOffset = yOffset - 30

	-- Spezielle Gruppierung für MN-Fische (nach Farbe)
	if selectedCategory == "fishing" and selectedExpansion == "MN" then
		-- Gruppiere MN-Fische nach Farbe (W, G, B)
		local fishByColor = {W = {}, G = {}, B = {}}
		for _, item in ipairs(items) do
			local color = item.quality or "W"
			if fishByColor[color] then
				table.insert(fishByColor[color], item)
			end
		end

		-- Zeige Farbgruppen an
		local colorOrder = {"W", "G", "B"}
		local colorNames = {W = LK["Weiße Fische"], G = LK["Grüne Fische"], B = LK["Blaue Fische"]}

		-- Sammle alle Fische sortiert nach Farbe (W, G, B)
		local allFishes = {}
		for _, color in ipairs(colorOrder) do
			for _, fish in ipairs(fishByColor[color]) do
				table.insert(allFishes, fish)
			end
		end

		-- Zeige 3 Fische pro Zeile (kompakt, ohne Überschriften)
		local fishesPerRow = 3
		for i = 1, #allFishes, fishesPerRow do
			local rowFishes = {}
			for j = i, math.min(i + fishesPerRow - 1, #allFishes) do
				table.insert(rowFishes, allFishes[j])
			end
			local groupRow = KT:CreateFishColorGroup(itemsFrame.content, rowFishes, selectedCategory, db, farmbarModule, container, selectedExpansion, categoryTabs, expansionButtons, itemsFrame)
			groupRow:SetPoint("TOPLEFT", 5, yOffset)
			table.insert(itemsFrame.content.items, groupRow)
			yOffset = yOffset - 36
		end
	else
		-- Standard-Gruppierung nach Namen (für Quality-Varianten)
		local itemGroups = {}
		local groupOrder = {}
		for _, item in ipairs(items) do
			if not itemGroups[item.name] then
				itemGroups[item.name] = {}
				table.insert(groupOrder, item.name)
			end
			table.insert(itemGroups[item.name], item)
		end

		-- Sortiere jede Gruppe nach Quality
		for _, group in pairs(itemGroups) do
			table.sort(group, function(a, b)
				local qA = a.quality or 0
				local qB = b.quality or 0
				return qA < qB
			end)
		end

		-- Zeige Gruppen nacheinander an
		for _, groupName in ipairs(groupOrder) do
			local group = itemGroups[groupName]
			local groupRow = KT:CreateItemGroupRow(itemsFrame.content, group, selectedCategory, db, farmbarModule, container, selectedExpansion, categoryTabs, expansionButtons, itemsFrame)
			groupRow:SetPoint("TOPLEFT", 5, yOffset)
			table.insert(itemsFrame.content.items, groupRow)
			yOffset = yOffset - 40
		end
	end

	-- Update content height
	itemsFrame.content:SetHeight(math.abs(yOffset) + 20)
end

-- Hole Farbcode für Fisch-Qualitäten (W, G, B)
function KT:GetFishQualityColor(quality)
	if quality == "W" then
		return 1, 1, 1 -- Weiß
	elseif quality == "G" then
		return 0.1, 1, 0.1 -- Grün
	elseif quality == "B" then
		return 0.3, 0.7, 1 -- Blau
	end
	return 1, 1, 1 -- Standard: Weiß
end

-- Create Fish Color Group (3 Fische pro Zeile, kompakt mit Icon VOR Name)
function KT:CreateFishColorGroup(parent, fishGroup, category, db, farmbarModule, container, selectedExpansion, categoryTabs, expansionButtons, itemsFrame)
	local row = CreateFrame("Frame", nil, parent)
	row:SetSize(550, 32)

	local iconSize = 28
	local xOffset = 5

	for _, fish in ipairs(fishGroup) do
		-- Icon/Checkbox für diesen Fisch
		local checkbox = KT:CreateItemCheckbox(row, fish, category, db, farmbarModule, iconSize)
		checkbox:SetPoint("LEFT", xOffset, 0)

		-- Fisch-Name (rechts vom Icon)
		local nameLabel = row:CreateFontString(nil, "OVERLAY")
		nameLabel:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
		nameLabel:SetFont("Fonts\\FRIZQT__.TTF", 9)
		nameLabel:SetText(fish.name)
		local r, g, b = KT:GetFishQualityColor(fish.quality)
		nameLabel:SetTextColor(r, g, b, 1)
		nameLabel:SetWidth(135)
		nameLabel:SetJustifyH("LEFT")
		nameLabel:SetWordWrap(false)

		xOffset = xOffset + iconSize + 4 + 135 + 10 -- Icon + Spacing + Name + Extra
	end

	return row
end

-- Create Item Group Row (Name + Master-Checkbox + Icons)
function KT:CreateItemGroupRow(parent, itemGroup, category, db, farmbarModule, container, selectedExpansion, categoryTabs, expansionButtons, itemsFrame)
	local row = CreateFrame("Frame", nil, parent)
	row:SetSize(550, 36)

	-- Item Name (mit Farbcodierung für Fische)
	local nameLabel = row:CreateFontString(nil, "OVERLAY")
	nameLabel:SetPoint("LEFT", 5, 0)
	nameLabel:SetFont("Fonts\\FRIZQT__.TTF", 11)
	nameLabel:SetText(itemGroup[1].name)

	-- Farbcodierung für MN-Fische basierend auf Qualität (W, G, B)
	if category == "fishing" and itemGroup[1].expansion == "MN" and itemGroup[1].quality then
		local r, g, b = KT:GetFishQualityColor(itemGroup[1].quality)
		nameLabel:SetTextColor(r, g, b, 1)
	else
		nameLabel:SetTextColor(1, 1, 1, 1)
	end

	nameLabel:SetWidth(150)
	nameLabel:SetJustifyH("LEFT")

	-- Master-Checkbox (aktiviert alle Qualitätsstufen)
	local masterCheck = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
	masterCheck:SetSize(20, 20)
	masterCheck:SetPoint("LEFT", nameLabel, "RIGHT", 5, 0)

	-- Update Master-Checkbox Status
	local function updateMasterCheckbox()
		if not db.categories[category] then
			masterCheck:SetChecked(false)
			return
		end
		local allSelected = true
		for _, item in ipairs(itemGroup) do
			local found = false
			for _, id in ipairs(db.categories[category].items) do
				if id == item.id then
					found = true
					break
				end
			end
			if not found then
				allSelected = false
				break
			end
		end
		masterCheck:SetChecked(allSelected)
	end

	masterCheck:SetScript("OnClick", function(self)
		local isChecked = self:GetChecked()
		if isChecked then
			-- Alle Qualitätsstufen auswählen
			for _, item in ipairs(itemGroup) do
				farmbarModule:AddItemToCategory(category, item.id)
			end
		else
			-- Alle Qualitätsstufen abwählen
			for _, item in ipairs(itemGroup) do
				farmbarModule:RemoveItemFromCategory(category, item.id)
			end
		end
		farmbarModule:UpdateBars()
		KT:UpdateFarmbarConfig(container, category, selectedExpansion, categoryTabs, expansionButtons, itemsFrame, farmbarModule, db)
	end)

	updateMasterCheckbox()

	-- Item Icons
	local iconSize = 32
	local xOffset = 35
	for i, item in ipairs(itemGroup) do
		local checkbox = KT:CreateItemCheckbox(row, item, category, db, farmbarModule, iconSize)
		checkbox:SetPoint("LEFT", masterCheck, "RIGHT", xOffset, 0)
		xOffset = xOffset + iconSize + 4
	end

	return row
end

-- Create Item Checkbox (Icon-basiert, kompakt)
function KT:CreateItemCheckbox(parent, item, category, db, farmbarModule, size)
	local frame = CreateFrame("CheckButton", nil, parent)
	frame:SetSize(size, size)

	-- Background
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0.1, 0.1, 0.15, 0.9)

	-- Icon
	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("CENTER")
	icon:SetSize(size - 4, size - 4)
	local itemIcon = C_Item.GetItemIconByID(item.id)
	if itemIcon then
		icon:SetTexture(itemIcon)
	else
		icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	end

	-- Quality Border (Rarity)
	local rarity = C_Item.GetItemQualityByID(item.id) or 1
	if rarity > 1 then
		local r, g, b = C_Item.GetItemQualityColor(rarity)
		local border = frame:CreateTexture(nil, "OVERLAY", nil, 1)
		border:SetAllPoints(icon)
		border:SetAtlas("bags-glow-white")
		border:SetVertexColor(r, g, b, 0.7)
	end

	-- Quality Atlas Overlay (für MN/DF/TWW)
	if item.quality then
		local atlasName = farmbarModule:GetQualityAtlas(item.expansion, item.quality)
		if atlasName then
			local qualityOverlay = frame:CreateTexture(nil, "OVERLAY", nil, 2)
			-- MN Icons größer machen (0.75 statt 0.5)
			local overlaySize = item.expansion == "MN" and (size * 0.75) or (size * 0.5)
			qualityOverlay:SetSize(overlaySize, overlaySize)
			qualityOverlay:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
			qualityOverlay:SetAtlas(atlasName)
		end
	end

	-- Checkbox Indicator (kleines Häkchen)
	local check = frame:CreateTexture(nil, "OVERLAY", nil, 3)
	check:SetSize(size * 0.6, size * 0.6)
	check:SetPoint("BOTTOMRIGHT", 2, -2)
	check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	check:SetVertexColor(0.2, 1, 0.2, 1)
	frame.check = check

	-- Initial state
	local isChecked = false
	if db.categories[category] and db.categories[category].items then
		for _, id in ipairs(db.categories[category].items) do
			if id == item.id then
				isChecked = true
				break
			end
		end
	end
	check:SetShown(isChecked)

	-- Click handler
	frame:SetScript("OnClick", function(self)
		local nowChecked = not isChecked

		if nowChecked then
			farmbarModule:AddItemToCategory(category, item.id)
		else
			farmbarModule:RemoveItemFromCategory(category, item.id)
		end

		isChecked = nowChecked
		self.check:SetShown(isChecked)
		farmbarModule:UpdateBars()
	end)

	-- Tooltip
	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetItemByID(item.id)
		GameTooltip:Show()
	end)

	frame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	return frame
end

-- Create Profile Management Content
function KT:CreateProfileContent(contentFrame)
    -- Title
    local title = contentFrame:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOP", 0, -20)
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    title:SetText(LK["Profile Verwaltung"])
    title:SetTextColor(1, 1, 1, 1)

    -- Description
    local desc = contentFrame:CreateFontString(nil, "OVERLAY")
    desc:SetPoint("TOP", title, "BOTTOM", 0, -10)
    desc:SetPoint("LEFT", contentFrame, "LEFT", 20, 0)
    desc:SetPoint("RIGHT", contentFrame, "RIGHT", -20, 0)
    desc:SetFont("Fonts\\FRIZQT__.TTF", 11)
    desc:SetText(LK["Profile Beschreibung"])
    desc:SetTextColor(0.7, 0.7, 0.75, 1)
    desc:SetJustifyH("LEFT")
    desc:SetWordWrap(true)

    -- Content container
    local container = CreateFrame("Frame", nil, contentFrame)
    container:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 10, -20)
    container:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -20, 10)

    -- Helper: Create section card
    local function CreateSectionCard(parent, xPos, yPos, width, height, titleText)
        local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        card:SetPoint("TOPLEFT", xPos, yPos)
        card:SetSize(width, height)

        local bg = card:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.12, 0.14, 0.18, 0.95)

        card:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        card:SetBackdropBorderColor(0.25, 0.35, 0.5, 0.8)

        local accent = card:CreateTexture(nil, "ARTWORK")
        accent:SetPoint("TOPLEFT", 3, -3)
        accent:SetPoint("TOPRIGHT", -3, -3)
        accent:SetHeight(2)
        accent:SetColorTexture(0.3, 0.6, 1, 0.6)

        local cardTitle = card:CreateFontString(nil, "OVERLAY")
        cardTitle:SetPoint("TOPLEFT", 12, -12)
        cardTitle:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        cardTitle:SetText(titleText)
        cardTitle:SetTextColor(0.4, 0.7, 1, 1)

        return card
    end

    -- Helper: Create button
    local function CreateButton(parent, text, xPos, yPos, width, onClick)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(width or 90, 26)
        btn:SetPoint("TOPLEFT", xPos, yPos)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.2, 0.3, 0.5, 0.8)
        btn.bg = bg

        local btnText = btn:CreateFontString(nil, "OVERLAY")
        btnText:SetAllPoints()
        btnText:SetFont("Fonts\\FRIZQT__.TTF", 10)
        btnText:SetText(text)
        btnText:SetTextColor(1, 1, 1, 1)

        btn:SetScript("OnEnter", function(self)
            if self:IsEnabled() then
                self.bg:SetColorTexture(0.3, 0.4, 0.6, 1)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if self:IsEnabled() then
                self.bg:SetColorTexture(0.2, 0.3, 0.5, 0.8)
            else
                self.bg:SetColorTexture(0.15, 0.15, 0.2, 0.6)
            end
        end)
        btn:SetScript("OnClick", onClick)

        return btn
    end

    -- Helper: Create EditBox
    local function CreateEditBox(parent, xPos, yPos, width)
        local editBox = CreateFrame("EditBox", nil, parent)
        editBox:SetSize(width, 26)
        editBox:SetPoint("TOPLEFT", xPos, yPos)
        editBox:SetFontObject("GameFontNormal")
        editBox:SetAutoFocus(false)
        editBox:SetMaxLetters(50)

        local bg = editBox:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.15, 0.9)

        local border = CreateFrame("Frame", nil, editBox, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        border:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)

        editBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)

        return editBox
    end

    -- Helper: Create dropdown (without arrow)
    local function CreateDropdown(parent, xPos, yPos, width, items, onSelect)
        local dropdown = CreateFrame("Frame", nil, parent)
        dropdown:SetSize(width, 26)
        dropdown:SetPoint("TOPLEFT", xPos, yPos)

        local bg = dropdown:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.15, 0.9)

        local border = CreateFrame("Frame", nil, dropdown, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        border:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)

        local text = dropdown:CreateFontString(nil, "OVERLAY")
        text:SetPoint("LEFT", 8, 0)
        text:SetPoint("RIGHT", -8, 0)
        text:SetFont("Fonts\\FRIZQT__.TTF", 10)
        text:SetTextColor(1, 1, 1, 1)
        text:SetText(items[1] or "")
        text:SetJustifyH("LEFT")
        dropdown.text = text

        local button = CreateFrame("Button", nil, dropdown)
        button:SetAllPoints()

        local menu
        button:SetScript("OnClick", function()
            if menu and menu:IsShown() then
                menu:Hide()
                return
            end

            if not menu then
                menu = CreateFrame("Frame", nil, dropdown, "BackdropTemplate")
                menu:SetFrameStrata("FULLSCREEN_DIALOG")
                menu:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -2)
                menu:SetSize(width, math.min(#items * 24, 200))
                menu:SetBackdrop({
                    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    edgeSize = 10,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                })
                menu:SetBackdropColor(0.1, 0.1, 0.15, 1)
                menu:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)

                local scroll = CreateFrame("ScrollFrame", nil, menu, "UIPanelScrollFrameTemplate")
                scroll:SetPoint("TOPLEFT", 4, -4)
                scroll:SetPoint("BOTTOMRIGHT", -22, 4)

                local content = CreateFrame("Frame", nil, scroll)
                content:SetSize(width - 26, #items * 24)
                scroll:SetScrollChild(content)

                for i, item in ipairs(items) do
                    local btn = CreateFrame("Button", nil, content)
                    btn:SetSize(width - 26, 24)
                    btn:SetPoint("TOPLEFT", 0, -(i-1) * 24)

                    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
                    btnBg:SetAllPoints()
                    btnBg:SetColorTexture(0, 0, 0, 0)

                    local btnText = btn:CreateFontString(nil, "OVERLAY")
                    btnText:SetPoint("LEFT", 5, 0)
                    btnText:SetFont("Fonts\\FRIZQT__.TTF", 10)
                    btnText:SetText(item)
                    btnText:SetTextColor(1, 1, 1, 1)

                    btn:SetScript("OnEnter", function(self)
                        btnBg:SetColorTexture(0.2, 0.3, 0.5, 0.5)
                    end)
                    btn:SetScript("OnLeave", function(self)
                        btnBg:SetColorTexture(0, 0, 0, 0)
                    end)
                    btn:SetScript("OnClick", function()
                        text:SetText(item)
                        onSelect(item)
                        menu:Hide()
                    end)
                end
            end

            menu:Show()
        end)

        dropdown.SetItems = function(self, newItems)
            items = newItems
            if menu then
                menu:Hide()
                menu = nil
            end
        end

        return dropdown
    end

    local profileList = self.db:GetProfiles()
    local cardWidth = 255
    local cardSpacing = 12

    -- Row 1: Current Profile & Select Profile
    local card1 = CreateSectionCard(container, 0, 0, cardWidth, 85, LK["Aktuelles Profil"])
    local currentProfileText = card1:CreateFontString(nil, "OVERLAY")
    currentProfileText:SetPoint("CENTER", 0, -5)
    currentProfileText:SetFont("Fonts\\FRIZQT__.TTF", 13)
    currentProfileText:SetText("|cff71D5FF" .. (self.db:GetCurrentProfile() or "Default") .. "|r")
    currentProfileText:SetTextColor(1, 1, 1, 1)

    local card2 = CreateSectionCard(container, cardWidth + cardSpacing, 0, cardWidth, 85, LK["Profil wählen"])
    local selectDropdown = CreateDropdown(card2, 10, -40, cardWidth - 20, profileList, function(selected)
        self.db:SetProfile(selected)
        KT:Print(LK["Wechsel zu Profil"] .. ": " .. selected)
        self:ShowMenuContent("Profile")
    end)

    -- Row 2: Create New Profile & Copy Profile
    local card3 = CreateSectionCard(container, 0, -97, cardWidth, 85, LK["Neues Profil erstellen"])
    local newProfileBox = CreateEditBox(card3, 10, -40, cardWidth - 90)
    newProfileBox:SetScript("OnEnterPressed", function(self)
        local profileName = self:GetText()
        if profileName and profileName ~= "" then
            if not tContains(KT.db:GetProfiles(), profileName) then
                KT.db:SetProfile(profileName)
                KT:Print(LK["Profil wurde erstellt"] .. ": " .. profileName)
                self:SetText("")
                KT:ShowMenuContent("Profile")
            else
                KT:Print("|cffff0000" .. LK["Dieses Profil existiert bereits"])
            end
        else
            KT:Print("|cffff0000" .. LK["Bitte gib einen Profilnamen ein"])
        end
        self:ClearFocus()
    end)
    CreateButton(card3, LK["Erstellen"], cardWidth - 78, -40, 68, function()
        newProfileBox:GetScript("OnEnterPressed")(newProfileBox)
    end)

    local card4 = CreateSectionCard(container, cardWidth + cardSpacing, -97, cardWidth, 85, LK["Profil kopieren"])
    local copyDropdown = CreateDropdown(card4, 10, -40, cardWidth - 90, profileList, function(selected)
        card4.copyFrom = selected
    end)
    CreateButton(card4, LK["Kopieren"], cardWidth - 78, -40, 68, function()
        if card4.copyFrom then
            KT.db:CopyProfile(card4.copyFrom)
            KT:Print(LK["Profil wurde kopiert"] .. ": " .. card4.copyFrom)
            KT:ShowMenuContent("Profile")
        end
    end)

    -- Row 3: Delete Profile (with safety checkbox) & Reset to Default
    local card5 = CreateSectionCard(container, 0, -194, cardWidth, 105, LK["Profil löschen"])
    local deleteDropdown = CreateDropdown(card5, 10, -40, cardWidth - 20, profileList, function(selected)
        card5.deleteProfile = selected
        card5.deleteCheckbox:SetChecked(false)
        card5.deleteBtn:Disable()
        card5.deleteBtn.bg:SetColorTexture(0.15, 0.15, 0.2, 0.6)
    end)

    -- Safety checkbox
    local deleteCheckbox = CreateFrame("CheckButton", nil, card5, "UICheckButtonTemplate")
    deleteCheckbox:SetPoint("TOPLEFT", 10, -68)
    deleteCheckbox:SetSize(18, 18)
    card5.deleteCheckbox = deleteCheckbox

    local deleteCheckLabel = card5:CreateFontString(nil, "OVERLAY")
    deleteCheckLabel:SetPoint("LEFT", deleteCheckbox, "RIGHT", 4, 0)
    deleteCheckLabel:SetFont("Fonts\\FRIZQT__.TTF", 9)
    deleteCheckLabel:SetText("|cffff6666Löschen bestätigen|r")
    deleteCheckLabel:SetTextColor(1, 0.4, 0.4, 1)

    local deleteBtn = CreateButton(card5, LK["Löschen"], cardWidth - 78, -66, 68, function()
        if card5.deleteProfile and deleteCheckbox:GetChecked() then
            local currentProfile = KT.db:GetCurrentProfile()
            if card5.deleteProfile == currentProfile then
                KT:Print("|cffff0000" .. LK["Du kannst das aktuelle Profil nicht löschen"])
            elseif card5.deleteProfile == "Default" then
                KT:Print("|cffff0000" .. LK["Standard-Profil kann nicht gelöscht werden"])
            else
                KT.db:DeleteProfile(card5.deleteProfile)
                KT:Print(LK["Profil wurde gelöscht"] .. ": " .. card5.deleteProfile)
                KT:ShowMenuContent("Profile")
            end
        end
    end)
    deleteBtn:Disable()
    deleteBtn.bg:SetColorTexture(0.15, 0.15, 0.2, 0.6)
    card5.deleteBtn = deleteBtn

    deleteCheckbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            deleteBtn:Enable()
            deleteBtn.bg:SetColorTexture(0.2, 0.3, 0.5, 0.8)
        else
            deleteBtn:Disable()
            deleteBtn.bg:SetColorTexture(0.15, 0.15, 0.2, 0.6)
        end
    end)

    local card6 = CreateSectionCard(container, cardWidth + cardSpacing, -194, cardWidth, 105, LK["Standard-Profil verwenden"])
    local resetDesc = card6:CreateFontString(nil, "OVERLAY")
    resetDesc:SetPoint("TOPLEFT", 10, -35)
    resetDesc:SetPoint("TOPRIGHT", -10, -35)
    resetDesc:SetFont("Fonts\\FRIZQT__.TTF", 9)
    resetDesc:SetText("Setzt alle Einstellungen auf das Standard-Profil zurück.")
    resetDesc:SetTextColor(0.7, 0.7, 0.75, 1)
    resetDesc:SetJustifyH("LEFT")
    resetDesc:SetWordWrap(true)

    CreateButton(card6, LK["Standard"], (cardWidth - 80) / 2, -68, 80, function()
        KT.db:SetProfile("Default")
        KT:Print(LK["Wechsel zu Profil"] .. ": Default")
        KT:ShowMenuContent("Profile")
    end)
end

-- ========================================
-- PROFESSION KNOWLEDGE SYSTEM
-- ========================================

-- Hole den aktuellen Charakter-Key (Name-Realm)
function KT:GetCharacterKey()
    local name = UnitName("player")
    local realm = GetRealmName()
    return name .. "-" .. realm
end

-- Prüfe, ob ein Berufswissen-Item bereits eingesammelt wurde
function KT:IsProfessionItemCollected(itemID)
    local charKey = self:GetCharacterKey()
    if not self.db.global.collectedProfessionItems[charKey] then
        return false
    end
    return self.db.global.collectedProfessionItems[charKey][itemID] == true
end

-- Markiere ein Berufswissen-Item als eingesammelt/nicht eingesammelt
function KT:SetProfessionItemCollected(itemID, collected)
    local charKey = self:GetCharacterKey()
    if not self.db.global.collectedProfessionItems[charKey] then
        self.db.global.collectedProfessionItems[charKey] = {}
    end

    if collected then
        self.db.global.collectedProfessionItems[charKey][itemID] = true
    else
        self.db.global.collectedProfessionItems[charKey][itemID] = nil
    end
end

-- Create Profession Knowledge Content
function KT:CreateProfessionKnowledgeContent(contentFrame, profession)
    local farmbarModule = self:GetModule("Farmbar")
    if not farmbarModule or not farmbarModule.ItemDatabase then
        local errorText = contentFrame:CreateFontString(nil, "OVERLAY")
        errorText:SetPoint("CENTER")
        errorText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        errorText:SetText(LK["Farmbar-Modul konnte nicht geladen werden"])
        errorText:SetTextColor(1, 0.2, 0.2, 1)
        return
    end

    -- Title
    local professionName = profession == "mining" and LK["Bergbau"] or LK["Kräuterkunde"]
    local title = contentFrame:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOP", 0, -10)
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    title:SetText(LK["Berufswissen"] .. " - " .. professionName)
    title:SetTextColor(1, 1, 1, 1)

    -- Scroll Frame für Items
    local scrollFrame = CreateFrame("ScrollFrame", nil, contentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(560, 1)
    scrollFrame:SetScrollChild(scrollChild)

    -- Hole alle Berufswissen-Items für diesen Beruf
    local allKnowledgeItems = farmbarModule.ItemDatabase.knowledge or {}
    local professionItems = {}

    for _, item in ipairs(allKnowledgeItems) do
        if item.profession == profession then
            table.insert(professionItems, item)
        end
    end

    -- Sortiere nach ID
    table.sort(professionItems, function(a, b) return a.id < b.id end)

    if #professionItems == 0 then
        local noItems = scrollChild:CreateFontString(nil, "OVERLAY")
        noItems:SetPoint("CENTER")
        noItems:SetFont("Fonts\\FRIZQT__.TTF", 12)
        noItems:SetText(LK["Keine Items für diese Erweiterung"])
        noItems:SetTextColor(0.6, 0.6, 0.65, 1)
        return
    end

    -- Zeige Items
    local yOffset = -10
    for _, item in ipairs(professionItems) do
        local row = self:CreateProfessionKnowledgeRow(scrollChild, item)
        row:SetPoint("TOPLEFT", 10, yOffset)
        yOffset = yOffset - 50
    end

    scrollChild:SetHeight(math.abs(yOffset) + 10)
end

-- Create Profession Knowledge Row (Item mit Checkbox)
function KT:CreateProfessionKnowledgeRow(parent, item)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetSize(530, 44)

    -- Background
    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    local isCollected = self:IsProfessionItemCollected(item.id)
    if isCollected then
        bg:SetColorTexture(0.1, 0.15, 0.1, 0.5) -- Grün-Grau für eingesammelt
    else
        bg:SetColorTexture(0.12, 0.14, 0.18, 0.8)
    end
    row.bg = bg

    -- Border
    row:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    if isCollected then
        row:SetBackdropBorderColor(0.2, 0.6, 0.2, 0.6)
    else
        row:SetBackdropBorderColor(0.25, 0.35, 0.5, 0.6)
    end
    row.border = row

    -- Icon
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 10, 0)
    local itemIcon = C_Item.GetItemIconByID(item.id)
    if itemIcon then
        icon:SetTexture(itemIcon)
    else
        icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    if isCollected then
        icon:SetDesaturated(true) -- Graustufen für eingesammelt
        icon:SetAlpha(0.5)
    end

    -- Item Name
    local nameLabel = row:CreateFontString(nil, "OVERLAY")
    nameLabel:SetPoint("LEFT", icon, "RIGHT", 10, 8)
    nameLabel:SetFont("Fonts\\FRIZQT__.TTF", 12)
    nameLabel:SetText(item.name)
    if isCollected then
        nameLabel:SetTextColor(0.5, 0.7, 0.5, 1)
    else
        nameLabel:SetTextColor(1, 1, 1, 1)
    end

    -- Item ID (klein)
    local idLabel = row:CreateFontString(nil, "OVERLAY")
    idLabel:SetPoint("LEFT", icon, "RIGHT", 10, -8)
    idLabel:SetFont("Fonts\\FRIZQT__.TTF", 9)
    idLabel:SetText("ID: " .. item.id)
    idLabel:SetTextColor(0.6, 0.6, 0.65, 1)

    -- Coordinates (falls vorhanden)
    if item.coords then
        local coordsLabel = row:CreateFontString(nil, "OVERLAY")
        coordsLabel:SetPoint("LEFT", idLabel, "RIGHT", 15, 0)
        coordsLabel:SetFont("Fonts\\FRIZQT__.TTF", 9)
        coordsLabel:SetText(string.format("%s: %.2f, %.2f", item.coords.zone or "MapID "..item.coords.mapID, item.coords.x, item.coords.y))
        coordsLabel:SetTextColor(0.5, 0.8, 1, 1)
    end

    -- Checkbox
    local checkbox = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("RIGHT", -10, 0)
    checkbox:SetChecked(isCollected)

    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        KT:SetProfessionItemCollected(item.id, checked)

        -- Update visuals
        if checked then
            bg:SetColorTexture(0.1, 0.15, 0.1, 0.5)
            row.border:SetBackdropBorderColor(0.2, 0.6, 0.2, 0.6)
            icon:SetDesaturated(true)
            icon:SetAlpha(0.5)
            nameLabel:SetTextColor(0.5, 0.7, 0.5, 1)
        else
            bg:SetColorTexture(0.12, 0.14, 0.18, 0.8)
            row.border:SetBackdropBorderColor(0.25, 0.35, 0.5, 0.6)
            icon:SetDesaturated(false)
            icon:SetAlpha(1)
            nameLabel:SetTextColor(1, 1, 1, 1)
        end
    end)

    -- Tooltip
    row:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(item.id)
        if isCollected then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(LK["Bereits eingesammelt"], 0.5, 0.8, 0.5)
        end
        GameTooltip:Show()
    end)

    row:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    return row
end

-- Create Fishing Statistics Content
function KT:CreateFishingStatsContent(contentFrame)
	local fishingModule = self:GetModule("FishingTracker", true)
	if not fishingModule or not KriemhildeToolsFishingDB then
		local errorText = contentFrame:CreateFontString(nil, "OVERLAY")
		errorText:SetPoint("CENTER")
		errorText:SetFont("Fonts\\FRIZQT__.TTF", 14)
		errorText:SetText("FishingTracker konnte nicht geladen werden")
		errorText:SetTextColor(1, 0.2, 0.2, 1)
		return
	end

	local db = KriemhildeToolsFishingDB

	-- Prüfe ob Daten vorhanden sind
	if db.totalCasts == 0 then
		local noData = contentFrame:CreateFontString(nil, "OVERLAY")
		noData:SetPoint("CENTER")
		noData:SetFont("Fonts\\FRIZQT__.TTF", 13)
		noData:SetText(LK["Noch keine Angel-Daten"])
		noData:SetTextColor(0.7, 0.7, 0.75, 1)
		return
	end

	-- Container
	local container = CreateFrame("Frame", nil, contentFrame)
	container:SetAllPoints()

	-- Title
	local title = container:CreateFontString(nil, "OVERLAY")
	title:SetPoint("TOP", 0, -5)
	title:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
	title:SetText(LK["Angel-Statistik"])
	title:SetTextColor(1, 1, 1, 1)

	-- === STATISTIK-KARTEN (oben) ===
	local cardY = -40
	local cardWidth = 145
	local cardHeight = 60
	local cardSpacing = 10

	-- Helper: Create Stat Card
	local function CreateStatCard(parent, xPos, yPos, titleText, valueText, color)
		local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		card:SetPoint("TOPLEFT", xPos, yPos)
		card:SetSize(cardWidth, cardHeight)

		local bg = card:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.12, 0.14, 0.18, 0.95)

		card:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 12,
			insets = { left = 3, right = 3, top = 3, bottom = 3 }
		})
		card:SetBackdropBorderColor(0.25, 0.35, 0.5, 0.8)

		local accent = card:CreateTexture(nil, "ARTWORK")
		accent:SetPoint("TOPLEFT", 3, -3)
		accent:SetPoint("TOPRIGHT", -3, -3)
		accent:SetHeight(2)
		accent:SetColorTexture(color.r or 0.3, color.g or 0.6, color.b or 1, 0.6)

		local cardTitle = card:CreateFontString(nil, "OVERLAY")
		cardTitle:SetPoint("TOP", 0, -8)
		cardTitle:SetFont("Fonts\\FRIZQT__.TTF", 8)
		cardTitle:SetText(titleText)
		cardTitle:SetTextColor(0.7, 0.7, 0.75, 1)

		local cardValue = card:CreateFontString(nil, "OVERLAY")
		cardValue:SetPoint("CENTER", 0, -3)
		cardValue:SetFont("Fonts\\FRIZQT__.TTF", 11)
		cardValue:SetText(valueText)
		cardValue:SetTextColor(color.r or 1, color.g or 1, color.b or 1, 1)

		return card
	end

	-- Berechne Statistiken
	local totalCasts = db.totalCasts or 0
	local poolCasts = db.totalPoolCasts or 0
	local openWaterCasts = totalCasts - poolCasts

	-- Finde meistbesuchten und wenigstbesuchten Schwarm
	local mostFishedPool = nil
	local mostFishedCount = 0
	local leastFishedPool = nil
	local leastFishedCount = math.huge

	for poolName, poolData in pairs(db.pools or {}) do
		local fishData = poolData.items or poolData -- Rückwärtskompatibilität
		local poolTotal = 0

		for fishID, data in pairs(fishData) do
			if type(fishID) == "number" then
				poolTotal = poolTotal + (data.count or 0)
			end
		end

		if poolTotal > mostFishedCount then
			mostFishedCount = poolTotal
			mostFishedPool = poolName
		end

		if poolTotal < leastFishedCount and poolTotal > 0 then
			leastFishedCount = poolTotal
			leastFishedPool = poolName
		end
	end

	-- Stat Cards
	CreateStatCard(container, 10, cardY, LK["Gesamte Würfe"], tostring(totalCasts), {r=0.3, g=0.6, b=1})
	CreateStatCard(container, 10 + cardWidth + cardSpacing, cardY, LK["Würfe in Schwärmen"], tostring(poolCasts), {r=0.2, g=0.8, b=0.4})
	CreateStatCard(container, 10 + (cardWidth + cardSpacing) * 2, cardY, LK["Würfe in normalem Wasser"], tostring(openWaterCasts), {r=0.6, g=0.6, b=0.7})

	-- Zweite Reihe Stats
	local card2Y = cardY - cardHeight - cardSpacing
	if mostFishedPool then
		CreateStatCard(container, 10, card2Y, LK["Meistbesuchter Schwarm"], mostFishedPool .. " (" .. mostFishedCount .. ")", {r=1, g=0.8, b=0.2})
	end
	if leastFishedPool and leastFishedPool ~= mostFishedPool then
		CreateStatCard(container, 10 + cardWidth + cardSpacing, card2Y, LK["Wenigstbesuchter Schwarm"], leastFishedPool .. " (" .. leastFishedCount .. ")", {r=0.8, g=0.5, b=0.9})
	end

	-- === CONTENT AREA (unten) ===
	local tableY = card2Y - cardHeight - 15

	-- Reset Button
	local resetBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
	resetBtn:SetSize(180, 24)
	resetBtn:SetPoint("TOPRIGHT", -10, tableY)
	resetBtn:SetText(LK["Alle Statistiken zurücksetzen"])
	resetBtn:SetScript("OnClick", function()
		StaticPopup_Show("KTFISHING_RESET_CONFIRM")
	end)

	-- Reset Confirmation Dialog
	StaticPopupDialogs["KTFISHING_RESET_CONFIRM"] = {
		text = LK["Bist du sicher?"],
		button1 = LK["Löschen"],
		button2 = LK["Schließen"],
		OnAccept = function()
			fishingModule:ResetAllData()
			KT:Print(LK["Statistiken wurden zurückgesetzt"])
			KT:ShowMenuContent("FishingStats")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	}

	-- Scroll Frame
	local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 10, tableY - 30)
	scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(560, 1)
	scrollFrame:SetScrollChild(scrollChild)

	local yOffset = -5

	-- Helper: Create Small Card (for pools and items)
	local smallCardWidth = 170
	local smallCardHeight = 35
	local smallCardSpacing = 8
	local cardsPerRow = 3

	local function CreateSmallCard(parent, text, count, color, xPos, yPos)
		local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		card:SetPoint("TOPLEFT", xPos, yPos)
		card:SetSize(smallCardWidth, smallCardHeight)

		local bg = card:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.1, 0.12, 0.15, 0.8)

		card:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 8,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		card:SetBackdropBorderColor(0.2, 0.25, 0.3, 0.6)

		local nameText = card:CreateFontString(nil, "OVERLAY")
		nameText:SetPoint("LEFT", 8, 0)
		nameText:SetFont("Fonts\\FRIZQT__.TTF", 10)
		nameText:SetText(text)
		nameText:SetTextColor(1, 1, 1, 1)
		nameText:SetWidth(100)
		nameText:SetJustifyH("LEFT")

		local countText = card:CreateFontString(nil, "OVERLAY")
		countText:SetPoint("RIGHT", -8, 0)
		countText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		countText:SetText(count)
		countText:SetTextColor(color.r or 0.3, color.g or 0.8, color.b or 0.4, 1)

		return card
	end

	-- Helper: Create Item Card (with icon)
	local function CreateItemCard(parent, itemID, itemName, count, xPos, yPos)
		local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		card:SetPoint("TOPLEFT", xPos, yPos)
		card:SetSize(smallCardWidth, 40)

		local bg = card:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.1, 0.12, 0.15, 0.8)

		card:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 8,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		card:SetBackdropBorderColor(0.2, 0.25, 0.3, 0.6)

		-- Icon
		local icon = card:CreateTexture(nil, "ARTWORK")
		icon:SetSize(24, 24)
		icon:SetPoint("LEFT", 6, 0)
		local itemIcon = C_Item.GetItemIconByID(itemID)
		if itemIcon then
			icon:SetTexture(itemIcon)
		else
			icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		end

		-- Quality Border
		local rarity = C_Item.GetItemQualityByID(itemID) or 1
		if rarity > 1 then
			local r, g, b = C_Item.GetItemQualityColor(rarity)
			local border = card:CreateTexture(nil, "OVERLAY", nil, 1)
			border:SetAllPoints(icon)
			border:SetAtlas("bags-glow-white")
			border:SetVertexColor(r, g, b, 0.7)
		end

		-- Name
		local nameText = card:CreateFontString(nil, "OVERLAY")
		nameText:SetPoint("LEFT", icon, "RIGHT", 6, 0)
		nameText:SetFont("Fonts\\FRIZQT__.TTF", 9)
		nameText:SetText(itemName)
		nameText:SetTextColor(1, 1, 1, 1)
		nameText:SetWidth(100)
		nameText:SetJustifyH("LEFT")

		-- Count
		local countText = card:CreateFontString(nil, "OVERLAY")
		countText:SetPoint("RIGHT", -6, 0)
		countText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		countText:SetText(count .. "x")
		countText:SetTextColor(0.3, 0.8, 0.4, 1)

		-- Tooltip
		card:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetItemByID(itemID)
			GameTooltip:Show()
		end)
		card:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)

		return card
	end

	-- === SCHWARM-ÜBERSICHT als Cards ===
	local poolHeader = scrollChild:CreateFontString(nil, "OVERLAY")
	poolHeader:SetPoint("TOPLEFT", 10, yOffset)
	poolHeader:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	poolHeader:SetText("Übersicht der Anzahl von Gegenständen die aus einem Schwarm geangelt wurden")
	poolHeader:SetTextColor(0.4, 0.7, 1, 1)
	yOffset = yOffset - 20

	-- Sortiere Pools nach Anzahl
	local poolList = {}
	for poolName, poolData in pairs(db.pools or {}) do
		local poolTotal = 0
		local fishData = poolData.items or poolData -- Rückwärtskompatibilität
		local objectID = poolData.objectID

		for fishID, data in pairs(fishData) do
			if type(fishID) == "number" then -- Ignoriere non-numeric keys wie 'items', 'objectID'
				poolTotal = poolTotal + (data.count or 0)
			end
		end
		table.insert(poolList, {name = poolName, count = poolTotal, objectID = objectID})
	end
	table.sort(poolList, function(a, b) return a.count > b.count end)

	-- Zeige Pool-Cards (3 pro Reihe)
	local cardIndex = 0
	for _, pool in ipairs(poolList) do
		local row = math.floor(cardIndex / cardsPerRow)
		local col = cardIndex % cardsPerRow
		local xPos = 10 + col * (smallCardWidth + smallCardSpacing)
		local yPos = yOffset - row * (smallCardHeight + smallCardSpacing)

		-- Zeige Pool-Name und optional Objekt-ID
		local displayText = pool.name
		if pool.objectID then
			displayText = pool.name .. " (ID: " .. pool.objectID .. ")"
		end
		CreateSmallCard(scrollChild, displayText, pool.count, {r=0.3, g=0.8, b=0.4}, xPos, yPos)
		cardIndex = cardIndex + 1
	end

	-- Berechne neue yOffset Position
	local poolRows = math.ceil(#poolList / cardsPerRow)
	yOffset = yOffset - (poolRows * (smallCardHeight + smallCardSpacing)) - 15

	-- === FISCH-ÜBERSICHT ===
	-- Definiere Fisch-IDs aus KTFBItems.lua
	local fishIDs = {
		-- Midnight Fische (238365-238384)
		[238365] = true, [238366] = true, [238367] = true, [238368] = true,
		[238369] = true, [238370] = true, [238371] = true, [238372] = true,
		[238373] = true, [238374] = true, [238375] = true, [238376] = true,
		[238377] = true, [238378] = true, [238379] = true, [238380] = true,
		[238381] = true, [238382] = true, [238383] = true, [238384] = true,
		-- TWW Fische
		[220134] = true, [220135] = true, [220138] = true, [220139] = true,
		[220142] = true, [220144] = true, [220145] = true, [220146] = true,
		[220147] = true, [220149] = true, [220150] = true, [220151] = true,
		[220153] = true, [227673] = true,
		-- DF Fische
		[194730] = true, [194967] = true, [194968] = true, [194969] = true,
		[194970] = true, [194966] = true,
		-- SL Fische
		[173032] = true, [173033] = true, [173034] = true, [173035] = true,
	}

	-- Sammle alle Items
	local allItems = {}
	for poolName, poolData in pairs(db.pools or {}) do
		local itemData = poolData.items or poolData -- Rückwärtskompatibilität

		for itemID, data in pairs(itemData) do
			if type(itemID) == "number" then -- Nur Items, nicht Meta-Daten
				if not allItems[itemID] then
					allItems[itemID] = {
						id = itemID,
						name = data.name,
						count = 0,
					}
				end
				allItems[itemID].count = allItems[itemID].count + data.count
			end
		end
	end

	-- Trenne Fische und andere Items
	local fishes = {}
	local otherItems = {}
	for itemID, data in pairs(allItems) do
		if fishIDs[itemID] then
			table.insert(fishes, data)
		else
			table.insert(otherItems, data)
		end
	end

	-- Sortiere beide Listen
	table.sort(fishes, function(a, b) return a.count > b.count end)
	table.sort(otherItems, function(a, b) return a.count > b.count end)

	-- Zeige Fische
	local fishHeader = scrollChild:CreateFontString(nil, "OVERLAY")
	fishHeader:SetPoint("TOPLEFT", 10, yOffset)
	fishHeader:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	fishHeader:SetText("Fische")
	fishHeader:SetTextColor(0.4, 0.7, 1, 1)
	yOffset = yOffset - 20

	-- Zeige Fisch-Cards (3 pro Reihe)
	cardIndex = 0
	for _, fish in ipairs(fishes) do
		local row = math.floor(cardIndex / cardsPerRow)
		local col = cardIndex % cardsPerRow
		local xPos = 10 + col * (smallCardWidth + smallCardSpacing)
		local yPos = yOffset - row * (40 + smallCardSpacing)

		CreateItemCard(scrollChild, fish.id, fish.name, fish.count, xPos, yPos)
		cardIndex = cardIndex + 1
	end

	-- Berechne neue yOffset
	local fishRows = math.ceil(#fishes / cardsPerRow)
	yOffset = yOffset - (fishRows * (40 + smallCardSpacing)) - 15

	-- Zeige andere Items (falls vorhanden)
	if #otherItems > 0 then
		local otherHeader = scrollChild:CreateFontString(nil, "OVERLAY")
		otherHeader:SetPoint("TOPLEFT", 10, yOffset)
		otherHeader:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		otherHeader:SetText("Weitere Gegenstände die beim angeln gefunden wurden:")
		otherHeader:SetTextColor(0.4, 0.7, 1, 1)
		yOffset = yOffset - 20

		-- Zeige Other-Item-Cards (3 pro Reihe)
		cardIndex = 0
		for _, item in ipairs(otherItems) do
			local row = math.floor(cardIndex / cardsPerRow)
			local col = cardIndex % cardsPerRow
			local xPos = 10 + col * (smallCardWidth + smallCardSpacing)
			local yPos = yOffset - row * (40 + smallCardSpacing)

			CreateItemCard(scrollChild, item.id, item.name, item.count, xPos, yPos)
			cardIndex = cardIndex + 1
		end

		-- Berechne neue yOffset
		local otherRows = math.ceil(#otherItems / cardsPerRow)
		yOffset = yOffset - (otherRows * (40 + smallCardSpacing)) - 15
	end

	scrollChild:SetHeight(math.abs(yOffset) + 20)
end
