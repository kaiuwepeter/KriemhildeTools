-- KriemhildeTools Core
local addonName = "KriemhildeTools"
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
        tooltip:SetText("KriemhildeTools")
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
        },
    })

    -- Register minimap button
    icon:Register(addonName, minimapIcon, self.db.profile.minimap)

    -- Register slash commands
    self:RegisterChatCommand("kt", "SlashCommand")
    self:RegisterChatCommand("kriemhilde", "SlashCommand")
end

function KT:OnEnable()
    self:Print("Addon geladen! Tippe /kt für weitere Befehle.")
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
    title:SetText(LK["Willkommen bei KriemhildeTools"])
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

    -- Menu items (using locale keys)
    local menuItems = {
        {key = "Start", display = LK["Start"]},
        {key = "QoL", display = LK["QoL"]},
        {key = "Farmbar", display = LK["Farmbar"]},
        {key = "punkt3", display = LK["punkt3"]},
        {key = "punkt4", display = LK["punkt4"]},
        {key = "punkt5", display = LK["punkt5"]},
        {key = "punkt6", display = LK["punkt6"]}
    }

    -- Function to create menu button
    local function CreateMenuButton(parent, menuKey, displayText, index)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(130, 32)
        btn:SetPoint("TOPLEFT", 5, -5 - ((index - 1) * 34))
        btn.menuKey = menuKey

        -- Background
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.08, 0.08, 0.12, 0)
        btn.bg = bg

        -- Highlight (selected state)
        local highlight = btn:CreateTexture(nil, "BORDER")
        highlight:SetAllPoints()
        highlight:SetColorTexture(0.25, 0.35, 0.55, 0)
        btn.highlight = highlight

        -- Text
        local btnText = btn:CreateFontString(nil, "OVERLAY")
        btnText:SetPoint("LEFT", 10, 0)
        btnText:SetFont("Fonts\\FRIZQT__.TTF", 13)
        btnText:SetText(displayText)
        btnText:SetTextColor(0.8, 0.8, 0.85, 1)
        btnText:SetJustifyH("LEFT")
        btn.text = btnText

        -- Left accent line
        local accent = btn:CreateTexture(nil, "OVERLAY")
        accent:SetPoint("LEFT", 0, 0)
        accent:SetSize(3, 32)
        accent:SetColorTexture(0.3, 0.6, 1, 0)
        btn.accent = accent

        -- Hover effect
        btn:SetScript("OnEnter", function(self)
            if frame.selectedMenu ~= menuKey then
                self.bg:SetColorTexture(0.15, 0.15, 0.2, 0.5)
            end
        end)

        btn:SetScript("OnLeave", function(self)
            if frame.selectedMenu ~= menuKey then
                self.bg:SetColorTexture(0.08, 0.08, 0.12, 0)
            end
        end)

        -- Click handler
        btn:SetScript("OnClick", function(self)
            KT:ShowMenuContent(menuKey)
        end)

        return btn
    end

    -- Create menu buttons
    for i, menuItem in ipairs(menuItems) do
        local btn = CreateMenuButton(navPanel, menuItem.key, menuItem.display, i)
        frame.menuButtons[menuItem.key] = btn
    end

    -- Show initial content
    self:ShowMenuContent("Start")

    frame:Show()
    self.mainFrame = frame
end

-- Function to show content for selected menu
function KT:ShowMenuContent(menuName)
    local frame = self.mainFrame
    if not frame then return end

    -- Update menu button states
    for name, btn in pairs(frame.menuButtons) do
        if name == menuName then
            btn.bg:SetColorTexture(0.2, 0.25, 0.35, 1)
            btn.highlight:SetColorTexture(0.25, 0.35, 0.55, 0.3)
            btn.accent:SetColorTexture(0.3, 0.6, 1, 1)
            btn.text:SetTextColor(1, 1, 1, 1)
        else
            btn.bg:SetColorTexture(0.08, 0.08, 0.12, 0)
            btn.highlight:SetColorTexture(0.25, 0.35, 0.55, 0)
            btn.accent:SetColorTexture(0.3, 0.6, 1, 0)
            btn.text:SetTextColor(0.8, 0.8, 0.85, 1)
        end
    end

    frame.selectedMenu = menuName

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
    else
        -- Placeholder for other menu items
        local title = contentFrame:CreateFontString(nil, "OVERLAY")
        title:SetPoint("TOP", 0, -20)
        title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        title:SetText(LK[menuName])
        title:SetTextColor(1, 1, 1, 1)

        local desc = contentFrame:CreateFontString(nil, "OVERLAY")
        desc:SetPoint("TOP", title, "BOTTOM", 0, -20)
        desc:SetFont("Fonts\\FRIZQT__.TTF", 12)
        desc:SetText(LK["Inhalt für"] .. " " .. LK[menuName] .. " " .. LK["kommt bald"] .. "...")
        desc:SetTextColor(0.7, 0.7, 0.75, 1)
    end

    contentFrame:Show()
end
