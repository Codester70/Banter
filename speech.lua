-- Banter/speech.lua
-- Implements Speak button logic (debounced, always speaks) and macro category speech (cooldowned).

Banter = Banter or {}

Banter.Speech = {
    -- Speak button debounce
    _lastSpeakPress = 0,
    DEBOUNCE_SEC = 0.25,

    -- Macro cooldowns
    macroCooldowns = {
        ATTACK    = 4,
        INTERRUPT = 7,
        DEFENSIVE = 10,
        BURST     = 18,
        HEAL      = 6
    },
    _macroLastSpoke = {},
}

local function say(text)
    if not text or text == "" then return end

    C_ChatInfo.SendChatMessage(text, "SAY")
end


local lastIdleEmoteTime = 0
local IDLE_EMOTE_COOLDOWN = 12 -- seconds (tune later)

local function canIdleEmote()
    if UnitAffectingCombat("player") then return false end
    if Banter:IsDisabledByGroup() then return false end
    return (GetTime() - lastIdleEmoteTime) >= IDLE_EMOTE_COOLDOWN
end

local function tryEmoteTaggedLine(line)
    if not line or not canIdleEmote() then return false end

    -- Format: @EMOTE:TOKEN (TOKEN is like SIGH, YAWN, etc.)
    local token = line:match("^@EMOTE:([A-Z_]+)$")
    if not token then
        return false
    end

    DoEmote(token)
    return true
end

local function matchesFactionTag(line)
    if not line then return true end

    local tag = line:match("^%[(%u+)%]")
    if not tag then
        return true -- no faction tag = neutral line
    end

    local playerFaction = Banter.GetPlayerFaction and Banter:GetPlayerFaction()
    return tag == playerFaction
end

local function stripFactionTag(line)
    return line:gsub("^%[%u+%]%s*", "")
end

local function matchesWeatherTag(line)
    if not line then return true end

    local tag = line:match("^%[WEATHER:(%u+)%]")
    if not tag then
        return true -- no weather tag = always allowed
    end

    local weather = Banter.GetWeather and Banter:GetWeather()
    if not weather then
        return false -- line requires weather but none exists
    end

    return tag == weather.type
end

local function stripWeatherTag(line)
    return line:gsub("^%[WEATHER:%u+%]%s*", "")
end

function Banter.Speech:PickContextCategory()
    local st = Banter.State
    local c = Banter.Constants
    local now = GetTime()
    local hp = st:GetHpPct()

    if hp <= c.LOWHP_THRESHOLD then
        return "LOWHP"
    end
    if st.inCombat then
        return "COMBAT"
    end
    if st.lastCombatEndTime and (now - st.lastCombatEndTime) <= c.VICTORY_WINDOW then
        return "VICTORY"
    end

    -- IDLE is special: we choose IDLE_GENERIC vs IDLE_PLACE at speak time
    return "IDLE"
end

local function hasUsableTarget()
    local t = Banter.GetTargetInfo and Banter.GetTargetInfo("target") or nil
    if not t then return false end
    if t.isDead then return false end
    if t.isSelf then return false end
    return true
end

local function hasLivingEnemy(unit)
    return UnitExists(unit)
        and not UnitIsDeadOrGhost(unit)
        and UnitCanAttack("player", unit)
end

local function pickIdleTargetCategory()
    local t = Banter.GetTargetInfo("target")
    if not t then return nil end

    if t.isPlayer then
        if t.isFriend then
            return "IDLE_TARGET_PLAYER_FRIENDLY"
        else
            -- Treat non-friend players as hostile-ish for banter purposes
            return "IDLE_TARGET_PLAYER_HOSTILE"
        end
    else
        -- NPC
        if t.isFriend then
            return "IDLE_TARGET_NPC_FRIENDLY"
        end
        return "IDLE_TARGET_NPC_HOSTILE"
    end
end

local function pickIdleNonTargetCategory()
    -- keep your existing place vs generic weighting
    local info = Banter.GetPlaceInfo and Banter.GetPlaceInfo() or nil
    local resting = info and info.resting
    local placeChance = resting and 0.40 or 0.60
    return (math.random() < placeChance) and "IDLE_PLACE" or "IDLE_GENERIC"
end

function Banter.Speech:SpeakContextual()
    if Banter:IsDisabledByGroup() then
        return
    end

    local now = GetTime()
    if (now - self._lastSpeakPress) < self.DEBOUNCE_SEC then
        return
    end
    self._lastSpeakPress = now

    local cat = self:PickContextCategory()

    -- Special handling for IDLE
    if cat == "IDLE" then
        local idleCat = nil

        if hasUsableTarget() then
            idleCat = pickIdleTargetCategory()
        end
        if not idleCat then
            idleCat = pickIdleNonTargetCategory()
        end

        local line = Banter.PoolManager:GetNextLine(idleCat)

        -- Both place + target pools use tokens
        if line and (idleCat:find("^IDLE_") ~= nil) then
            -- Only token-format the pools that contain tokens; safe to run regardless
            line = Banter.FormatTokens and Banter.FormatTokens(line) or line
        end

        local tries = 0
        while line
            and (not matchesFactionTag(line) or not matchesWeatherTag(line))
            and tries < 5
        do
            tries = tries + 1
            line = Banter.PoolManager:GetNextLine(idleCat)
        end

        if not line then return end

        line = stripFactionTag(line)
        line = stripWeatherTag(line)

        if tryEmoteTaggedLine(line) then
            return
        end

        if Banter.IsDwarvenRace and Banter:IsDwarvenRace() and Banter.Scottishify then
            line = Banter.Scottishify(line)
        end

        say(line)
        return
    end

    local line = Banter.PoolManager:GetNextLine(cat)
    say(line)
end

function Banter.Speech:SpeakCategory(category)
    if Banter:IsDisabledByGroup() then
        return
    end

    if category == "INTERRUPT" then
        -- Don’t announce interrupts unless we’re actually targeting a living enemy
        if not (hasLivingEnemy("target") or hasLivingEnemy("mouseover") or hasLivingEnemy("focus")) then
            return
        end
    end

    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()

    -- Cooldown gate (macros only)
    local cd = self.macroCooldowns and self.macroCooldowns[category]
    if cd then
        self._macroLastSpoke = self._macroLastSpoke or {}
        local last = self._macroLastSpoke[category] or 0
        if (now - last) < cd then
            return
        end
    end

    -- Random chance gate (macros only) - per-category percent stored in BanterDB
    local chancePct = 20
    if BanterDB and BanterDB.speech then
        if category == "ATTACK" then chancePct = BanterDB.speech.chance_attack or 20 end
        if category == "INTERRUPT" then chancePct = BanterDB.speech.chance_interrupt or 20 end
        if category == "DEFENSIVE" then chancePct = BanterDB.speech.chance_defensive or 20 end
        if category == "BURST" then chancePct = BanterDB.speech.chance_burst or 20 end
        if category == "HEAL" then chancePct = BanterDB.speech.chance_heal or 30 end
    end
    chancePct = math.max(0, math.min(100, chancePct))
    local chance = chancePct / 100

    if math.random() > chance then
        return
    end

    -- Passed gates: consume cooldown timestamp and speak
    if cd then
        self._macroLastSpoke[category] = now
    end

    local line = Banter.PoolManager:GetNextLine(category)
    say(line)
end
