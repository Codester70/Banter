-- Banter/ui.lua
Banter = Banter or {}
Banter.UI = {}

function Banter.UI:ApplySpeakButtonVisibility()
  if not self.speakButton then return end
  if not BanterDB then return end

  local hideBySetting = BanterDB.ui and BanterDB.ui.hideSpeakButton
  local hideByGroup = Banter.IsDisabledByGroup and Banter:IsDisabledByGroup()

  if hideBySetting or hideByGroup then
    self.speakButton:Hide()
  else
    self.speakButton:Show()
  end
end

local function applyPosition(btn)
    local x = (BanterDB and BanterDB.ui and BanterDB.ui.x) or 0
    local y = (BanterDB and BanterDB.ui and BanterDB.ui.y) or -140
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

local function savePosition(btn)
    local _, _, _, x, y = btn:GetPoint(1)
    BanterDB.ui.x = x
    BanterDB.ui.y = y
end

local function isLocked()
    return BanterDB and BanterDB.ui and BanterDB.ui.locked
end

local function createSpeakButton()
    local btn = CreateFrame("Button", "Banter_SpeakButton", UIParent, "UIPanelButtonTemplate")
    btn:SetSize(120, 28)
    btn:SetText("Speak")

    applyPosition(btn)

    btn:SetScript("OnClick", function()
        Banter.Speech:SpeakContextual()
    end)

    -- Dragging
    btn:SetMovable(true)
    btn:EnableMouse(true)
    btn:RegisterForDrag("LeftButton")

    btn:SetScript("OnDragStart", function(self)
        if isLocked() then return end
        self:StartMoving()
    end)

    btn:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        savePosition(self)
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local cat = Banter.Speech:PickContextCategory()
        GameTooltip:SetText("Banter: Speak", 1, 1, 1)
        GameTooltip:AddLine("Context: " .. cat, 0.9, 0.9, 0.9)

        if isLocked() then
            GameTooltip:AddLine("Position: locked (/banter unlock)", 0.7, 0.7, 0.7)
        else
            GameTooltip:AddLine("Drag to move. (/banter lock)", 0.7, 0.7, 0.7)
        end

        local x = (BanterDB and BanterDB.ui and BanterDB.ui.x) or 0
        local y = (BanterDB and BanterDB.ui and BanterDB.ui.y) or -140
        GameTooltip:AddLine(string.format("Pos: x=%.0f y=%.0f", x, y), 0.7, 0.7, 0.7)

        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return btn
end

function Banter.UI:SetLocked(locked)
    BanterDB.ui.locked = locked and true or false
end

function Banter.UI:ResetPosition()
    BanterDB.ui.x = 0
    BanterDB.ui.y = -140
    if self.speakButton then applyPosition(self.speakButton) end
end

function Banter.UI:SetPosition(x, y)
    BanterDB.ui.x = x
    BanterDB.ui.y = y
    if self.speakButton then applyPosition(self.speakButton) end
end

function Banter.UI:Init()
    if self._inited then return end
    self._inited = true
    self.speakButton = createSpeakButton()
    self:ApplySpeakButtonVisibility()
end
