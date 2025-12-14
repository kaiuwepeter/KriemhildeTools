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
    })

    -- Register minimap button
    icon:Register(addonName, minimapIcon, self.db.profile.minimap)

    -- Register slash commands
    self:RegisterChatCommand("kt", "SlashCommand")
    self:RegisterChatCommand("kriemhilde", "SlashCommand")
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
    else
        self:Print("Verfügbare Befehle:")
        self:Print("/kt show - Hauptfenster öffnen")
        self:Print("/kt hide - Hauptfenster schließen")
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
        {key = "punkt4", display = LK["punkt4"]},
        {key = "punkt5", display = LK["punkt5"]},
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
        local title = contentFrame:CreateFontString(nil, "OVERLAY")
        title:SetPoint("TOP", 0, -20)
        title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        title:SetText(LK["Farmbar"] .. " - " .. LK["Konfiguration"])
        title:SetTextColor(1, 1, 1, 1)

        local desc = contentFrame:CreateFontString(nil, "OVERLAY")
        desc:SetPoint("TOP", title, "BOTTOM", 0, -20)
        desc:SetFont("Fonts\\FRIZQT__.TTF", 12)
        desc:SetText(LK["Inhalt für"] .. " " .. LK["Farmbar"] .. " " .. LK["Konfiguration"] .. " " .. LK["kommt bald"] .. "...")
        desc:SetTextColor(0.7, 0.7, 0.75, 1)
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
