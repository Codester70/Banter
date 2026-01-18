-- Banter/state.lua
-- Tracks combat state, HP%, and victory window timing.



Banter = Banter or {}

Banter.DISABLE_MODES = {
    NEVER = 1,
    PARTY = 2,
    RAID = 3,
    PARTY_AND_RAID = 4,
}

Banter.DISABLE_LABELS = {
    [Banter.DISABLE_MODES.NEVER] = "Never",
    [Banter.DISABLE_MODES.PARTY] = "In party",
    [Banter.DISABLE_MODES.RAID] = "In raid",
    [Banter.DISABLE_MODES.PARTY_AND_RAID] = "In party and raid",
}

Banter.State = {
    inCombat = false,
    lastCombatEndTime = nil,
}

Banter.Constants = {
    LOWHP_THRESHOLD = 35, -- percent
    VICTORY_WINDOW  = 8, -- seconds
}

local f = CreateFrame("Frame")
Banter.State._frame = f

local function hpPct()
    local cur = UnitHealth("player")
    local max = UnitHealthMax("player")
    if not max or max == 0 then return 100 end
    return (cur / max) * 100
end

function Banter.State:GetHpPct()
    return hpPct()
end

f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        Banter.State.inCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        Banter.State.inCombat = false
        Banter.State.lastCombatEndTime = GetTime()
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- reset minimal state on load/reload
        Banter.State.inCombat = InCombatLockdown() or UnitAffectingCombat("player") or false
    end
end)

function Banter:IsDisabledByGroup()
  local mode = BanterDB and BanterDB.disableMode
  if not mode or mode == Banter.DISABLE_MODES.NEVER then
    return false
  end

  local inInstance, instanceType = IsInInstance()
  local inParty = IsInGroup() and not IsInRaid()
  local inRaid = IsInRaid()

  if mode == Banter.DISABLE_MODES.PARTY and inParty then
    return true
  end
  if mode == Banter.DISABLE_MODES.RAID and inRaid then
    return true
  end
  if mode == Banter.DISABLE_MODES.PARTY_AND_RAID and (inParty or inRaid) then
    return true
  end

  return false
end

function Banter:IsDwarvenRace()
    local raceName, raceFile = UnitRace("player")
    -- raceFile is usually stable-ish; raceName is localized. We'll use both defensively.
    local rf = (raceFile or ""):lower()
    local rn = (raceName or ""):lower()

    local dwarf = rf:find("dwarf", 1, true)
    local earthen = false--rf:find("earthen", 1, true)

    -- Covers Dwarf / Dark Iron Dwarf / Earthen (and future “dwarf-ish” strings)
    if dwarf or earthen then return true end

    return false
end

function Banter:GetPlayerFaction()
    local faction = UnitFactionGroup("player")
    if faction == "Alliance" then
        return "ALLIANCE"
    elseif faction == "Horde" then
        return "HORDE"
    end
    return nil
end

function Banter:GetWeather()
    -- Retail clients have been migrating/removing globals. Guard everything.
    local fn = _G.GetZoneWeatherInfo
    if type(fn) == "function" then
        local weatherType, intensity = fn()
        if not weatherType then return nil end
        return {
            type = tostring(weatherType):upper(),
            intensity = intensity or 0,
        }
    end

    -- Try likely namespaced alternatives (if Blizzard added one)
    if _G.C_Weather and type(_G.C_Weather.GetZoneWeatherInfo) == "function" then
        local weatherType, intensity = _G.C_Weather.GetZoneWeatherInfo()
        if not weatherType then return nil end
        return {
            type = tostring(weatherType):upper(),
            intensity = intensity or 0,
        }
    end

    -- No weather API available on this client/build
    return nil
end