-- Banter_Config.lua
-- Stable options UI (same pattern as Auto Pet Summoner)

Banter = Banter or {}

local CONFIG_TITLE = "Banter"


local function EnsureDefaults()
    BanterDB = BanterDB or {}
    BanterDB.speech = BanterDB.speech or {}
    BanterDB.ui = BanterDB.ui or {}

    if BanterDB.speech.chance_attack == nil then BanterDB.speech.chance_attack = 20 end
    if BanterDB.speech.chance_interrupt == nil then BanterDB.speech.chance_interrupt = 20 end
    if BanterDB.speech.chance_defensive == nil then BanterDB.speech.chance_defensive = 20 end
    if BanterDB.speech.chance_burst == nil then BanterDB.speech.chance_burst = 20 end
    if BanterDB.speech.chance_heal == nil then BanterDB.speech.chance_heal = 20 end
    if BanterDB.ui.hideSpeakButton == nil then BanterDB.ui.hideSpeakButton = false end
    if BanterDB.disableMode == nil then BanterDB.disableMode = Banter.DISABLE_MODES.NEVER end
    if BanterDB.speech.chance_idle_emote == nil then BanterDB.speech.chance_idle_emote = 15 end
end

local function Clamp(v)
    v = tonumber(v) or 0
    if v < 0 then v = 0 end
    if v > 100 then v = 100 end
    return v
end

InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory or nil

local function OpenOptionsFrame(frame, categoryName)
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(categoryName)
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(frame)
        InterfaceOptionsFrame_OpenToCategory(frame) -- called twice due to Blizzard bug
    end
end

-- Main config frame
local frame = CreateFrame("Frame", "BanterConfigFrame", UIParent)
frame.name = CONFIG_TITLE

-- Title
local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Banter")

local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetWidth(560)
subtitle:SetJustifyH("LEFT")
subtitle:SetText(
    "Configure how often Banter speaks when triggered from combat macros. The Speak button is unaffected and always speaks.")

local hideSpeakCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
hideSpeakCheck:SetPoint("TOPLEFT", 16, -64)
hideSpeakCheck.Text:SetText("Hide Speak button (use macro instead)")
hideSpeakCheck.tooltipText = "Hides the on-screen Speak button. You can still use /click Banter_SpeakButton in a macro."

local disableDropdownLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
disableDropdownLabel:SetPoint("TOPLEFT", hideSpeakCheck, "BOTTOMLEFT", 0, -16)
disableDropdownLabel:SetText("Disable Banter:")

local disableDropdown = CreateFrame("Frame", "BanterDisableDropdown", frame, "UIDropDownMenuTemplate")
disableDropdown:SetPoint("TOPLEFT", disableDropdownLabel, "BOTTOMLEFT", -16, -4)


-- Helper to create sliders
local function CreateSlider(labelText, tooltipText, yOffset)
    local slider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 24, yOffset)
    slider:SetMinMaxValues(0, 100)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(300)

    slider.Text:SetText(labelText)

    slider.valueText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    slider.valueText:SetPoint("LEFT", slider, "RIGHT", 12, 0)

    slider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(labelText, 1, 1, 1)
        if tooltipText then
            GameTooltip:AddLine(tooltipText, 0.9, 0.9, 0.9, true)
        end
        GameTooltip:Show()
    end)

    slider:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    slider:SetScript("OnValueChanged", function(self, value)
        value = Clamp(value)
        self.valueText:SetText(value .. "%")
    end)

    return slider
end

-- Sliders
local attackSlider = CreateSlider(
    "Attack macro speak chance",
    "Chance that /click Banter_ClickAttack will say something.",
    -220
)

local interruptSlider = CreateSlider(
    "Interrupt macro speak chance",
    "Chance that /click Banter_ClickInterrupt will say something.",
    -280
)

local defensiveSlider = CreateSlider(
    "Defensive macro speak chance",
    "Chance that /click Banter_ClickDefensive will say something.",
    -340
)

local burstSlider = CreateSlider(
    "Burst macro speak chance",
    "Chance that /click Banter_ClickBurst will say something.",
    -400
)

local healSlider = CreateSlider(
    "Heal macro speak chance",
    "Chance that /click Banter_ClickHeal will say something.",
    -460
)

-- local emoteSlider = CreateSlider(
--     "Emote macro speak chance",
--     "Chance for idle emotes.",
--     -520
-- )


local orderedDisableValues = {
    Banter.DISABLE_MODES.NEVER,
    Banter.DISABLE_MODES.PARTY,
    Banter.DISABLE_MODES.RAID,
    Banter.DISABLE_MODES.PARTY_AND_RAID,
}

local function InitDisableDropdown()
    UIDropDownMenu_Initialize(disableDropdown, function(self, level)
        for _, value in ipairs(orderedDisableValues) do
            local label = Banter.DISABLE_LABELS[value]

            local info = UIDropDownMenu_CreateInfo()
            info.text = label
            info.value = value
            info.func = function()
                BanterDB.disableMode = value
                UIDropDownMenu_SetSelectedValue(disableDropdown, value)
                UIDropDownMenu_SetText(disableDropdown, label)
                if Banter and Banter.UI and Banter.UI.ApplySpeakButtonVisibility then
                    Banter.UI:ApplySpeakButtonVisibility()
                end
            end

            UIDropDownMenu_AddButton(info, level)
        end
    end)
end

-- Sync UI from DB
local function Refresh()
    EnsureDefaults()
    attackSlider:SetValue(BanterDB.speech.chance_attack)
    interruptSlider:SetValue(BanterDB.speech.chance_interrupt)
    defensiveSlider:SetValue(BanterDB.speech.chance_defensive)
    burstSlider:SetValue(BanterDB.speech.chance_burst)
    healSlider:SetValue(BanterDB.speech.chance_heal)
    --emoteSlider:SetValue(BanterDB.speech.chance_idle_emote)
    hideSpeakCheck:SetChecked(BanterDB.ui.hideSpeakButton and true or false)
    UIDropDownMenu_SetSelectedValue(disableDropdown, BanterDB.disableMode)
    UIDropDownMenu_SetText(disableDropdown, Banter.DISABLE_LABELS[BanterDB.disableMode])
end

-- Write-through handlers
attackSlider:SetScript("OnValueChanged", function(_, value)
    EnsureDefaults()
    BanterDB.speech.chance_attack = Clamp(value)
    attackSlider.valueText:SetText(Clamp(value) .. "%")
end)

interruptSlider:SetScript("OnValueChanged", function(_, value)
    EnsureDefaults()
    BanterDB.speech.chance_interrupt = Clamp(value)
    interruptSlider.valueText:SetText(Clamp(value) .. "%")
end)

defensiveSlider:SetScript("OnValueChanged", function(_, value)
    EnsureDefaults()
    BanterDB.speech.chance_defensive = Clamp(value)
    defensiveSlider.valueText:SetText(Clamp(value) .. "%")
end)

burstSlider:SetScript("OnValueChanged", function(_, value)
    EnsureDefaults()
    BanterDB.speech.chance_burst = Clamp(value)
    burstSlider.valueText:SetText(Clamp(value) .. "%")
end)

healSlider:SetScript("OnValueChanged", function(_, value)
    EnsureDefaults()
    BanterDB.speech.chance_heal = Clamp(value)
    healSlider.valueText:SetText(Clamp(value) .. "%")
end)

-- emoteSlider:SetScript("OnValueChanged", function(_, value)
--     EnsureDefaults()
--     BanterDB.speech.chance_idle_emote = Clamp(value)
--     emoteSlider.valueText:SetText(Clamp(value) .. "%")
-- end)

-- Reset button
local resetBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
resetBtn:SetPoint("BOTTOMLEFT", 16, 16)
resetBtn:SetSize(140, 24)
resetBtn:SetText("Reset Defaults")
resetBtn:SetScript("OnClick", function()
    EnsureDefaults()
    BanterDB.speech.chance_attack = 20
    BanterDB.speech.chance_interrupt = 20
    BanterDB.speech.chance_defensive = 20
    BanterDB.speech.chance_burst = 20
    BanterDB.speech.chance_heal = 30
    BanterDB.speech.chance_idle_emote = 15
    Refresh()
end)

frame:SetScript("OnShow", Refresh)

hideSpeakCheck:SetScript("OnClick", function(self)
    EnsureDefaults()
    BanterDB.ui.hideSpeakButton = self:GetChecked() and true or false

    -- Apply immediately if the button exists
    if Banter and Banter.UI and Banter.UI.ApplySpeakButtonVisibility then
        Banter.UI:ApplySpeakButtonVisibility()
    end
end)

InitDisableDropdown()

InterfaceOptions_AddCategory = InterfaceOptions_AddCategory or nil

-- Register with Settings
if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(frame, CONFIG_TITLE)
    Settings.RegisterAddOnCategory(category)
else
    InterfaceOptions_AddCategory(frame)
end

BanterConfigFrame = BanterConfigFrame or frame
-- Expose opener
function Banter.OpenConfig()

    OpenOptionsFrame(BanterConfigFrame, "Banter")
end
