-- Banter/macrobuttons.lua
-- Creates hidden buttons callable via /click in macros.

Banter = Banter or {}

Banter.MacroButtons = {}

local function createHiddenClickButton(name, category)
    local btn = CreateFrame("Button", name, UIParent)
    btn:SetSize(1, 1)
    btn:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -10000, -10000)
    btn:Hide()

    btn:RegisterForClicks("AnyUp")

    btn:SetScript("OnClick", function()
        Banter.Speech:SpeakCategory(category)
    end)

    return btn
end

function Banter.MacroButtons:Init()
    if self._inited then return end
    self._inited   = true

    self.attack    = createHiddenClickButton("Banter_ClickAttack", "ATTACK")
    self.interrupt = createHiddenClickButton("Banter_ClickInterrupt", "INTERRUPT")
    self.defensive = createHiddenClickButton("Banter_ClickDefensive", "DEFENSIVE")
    self.burst     = createHiddenClickButton("Banter_ClickBurst", "BURST")
    self.heal      = createHiddenClickButton("Banter_ClickHeal", "HEAL")
end
