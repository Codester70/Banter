-- Banter/core.lua
-- Initialization + SavedVariables + slash commands

Banter = Banter or {}

function Banter:Debug(msg)
    if not BanterDB then return end
    msg = msg or "nil"

    DEFAULT_CHAT_FRAME:AddMessage(
        "|cffb48efcBanter:|r " .. tostring(msg)
    )
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, addonName)
    if event ~= "ADDON_LOADED" or addonName ~= "Banter" then
        return
    end

    -- SavedVariables init
    BanterDB = BanterDB or {}
    BanterDB.ui = BanterDB.ui or {}

    if BanterDB.ui.locked == nil then BanterDB.ui.locked = true end
    -- store x/y offsets relative to UIParent center
    if BanterDB.ui.x == nil then BanterDB.ui.x = 0 end
    if BanterDB.ui.y == nil then BanterDB.ui.y = -140 end

    BanterDB.speech = BanterDB.speech or {}
    if BanterDB.speech.macroChance == nil then BanterDB.speech.macroChance = 0.20 end -- 20%

    -- Speech defaults (per-category % chances for macro endpoints)
    BanterDB.speech = BanterDB.speech or {}
    if BanterDB.speech.chance_attack == nil then BanterDB.speech.chance_attack = 20 end
    if BanterDB.speech.chance_interrupt == nil then BanterDB.speech.chance_interrupt = 20 end
    if BanterDB.speech.chance_defensive == nil then BanterDB.speech.chance_defensive = 20 end
    if BanterDB.speech.chance_burst == nil then BanterDB.speech.chance_burst = 20 end
    if BanterDB.speech.chance_idle_emote == nil then BanterDB.speech.chance_idle_emote = 15 end
    BanterDB.debug = BanterDB.debug or false

    -- Settings panel
    if Banter.Settings and Banter.Settings.Init then
        Banter.Settings:Init()
    end

    -- Init modules (guarded, in case a file didn't load)
    if Banter.UI and Banter.UI.Init then
        Banter.UI:Init()
    else
        print("Banter: UI module missing (ui.lua not loaded?)")
    end

    if Banter.MacroButtons and Banter.MacroButtons.Init then
        Banter.MacroButtons:Init()
    else
        print("Banter: MacroButtons module missing (macrobuttons.lua not loaded?)")
    end

    -- Slash commands
    SLASH_BANTER1 = "/banter"
    SlashCmdList["BANTER"] = function(msg)
        msg = msg or ""
        msg = msg:gsub("^%s+", ""):gsub("%s+$", "")

        local cmd, a, b = msg:match("^(%S+)%s*(%-?%d*%.?%d*)%s*(%-?%d*%.?%d*)$")
        cmd = (cmd and cmd:lower()) or ""

        if cmd == "hide" then
            if Banter.UI and Banter.UI.speakButton then Banter.UI.speakButton:Hide() end
            print("Banter: Speak button hidden.")
            return
        end

        if cmd == "show" then
            if Banter.UI and Banter.UI.speakButton then Banter.UI.speakButton:Show() end
            print("Banter: Speak button shown.")
            return
        end

        if cmd == "unlock" then
            if Banter.UI and Banter.UI.SetLocked then
                Banter.UI:SetLocked(false)
                print("Banter: Speak button unlocked (drag to move).")
            end
            return
        end

        if cmd == "lock" then
            if Banter.UI and Banter.UI.SetLocked then
                Banter.UI:SetLocked(true)
                print("Banter: Speak button locked.")
            end
            return
        end

        if cmd == "reset" then
            if Banter.UI and Banter.UI.ResetPosition then
                Banter.UI:ResetPosition()
                print("Banter: Speak button position reset.")
            end
            return
        end

        if cmd == "pos" then
            local x = tonumber(a)
            local y = tonumber(b)
            if not x or not y then
                print("Banter: usage: /banter pos <x> <y>   (relative to screen center)")
                return
            end
            if Banter.UI and Banter.UI.SetPosition then
                Banter.UI:SetPosition(x, y)
                print(string.format("Banter: Speak button moved to x=%.0f y=%.0f.", x, y))
            end
            return
        end

        if cmd == "test" then
            if Banter.Speech and Banter.Speech.SpeakContextual then
                Banter.Speech:SpeakContextual()
            end
            return
        end

        -- Help
        print("Banter commands:")
        print("  /banter show|hide")
        print("  /banter lock|unlock  (unlock to drag)")
        print("  /banter pos <x> <y>  (relative to screen center)")
        print("  /banter reset        (reset position)")
        print("  /banter options  (open options UI)")
        print("  /banter test")
    end

    print("Banter loaded. /banter for help. Default keybind: CTRL-SHIFT-B (changeable).")
end)
