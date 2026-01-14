-- Banter/place.lua
-- Provides basic location info + optional zone/subzone overrides.

Banter = Banter or {}

-- Optional “hand-authored” flavor for iconic locations.
-- You can expand this over time. Keys can be zone OR subzone names.
local Overrides = {
    ["Stormwind City"] = { city = "Stormwind", vibe = "busy" },
    ["Orgrimmar"]      = { city = "Orgrimmar", vibe = "loud" },
    ["Ironforge"]      = { city = "Ironforge", vibe = "warm" },
    ["Darnassus"]      = { city = "Darnassus", vibe = "quiet" },
    ["Undercity"]      = { city = "Undercity", vibe = "grim" },
    ["Dalaran"]        = { city = "Dalaran", vibe = "strange" },
}

function Banter.GetPlaceInfo()
    local zone = GetZoneText() or ""
    local subzone = GetSubZoneText() or ""
    local minimapZone = GetMinimapZoneText() or ""

    -- Prefer a “real” subzone if it exists; minimap sometimes has better granularity.
    local bestSub = subzone
    if bestSub == "" and minimapZone ~= "" then
        bestSub = minimapZone
    end
    if bestSub == "" then
        bestSub = zone
    end

    local o = Overrides[bestSub] or Overrides[zone]

    return {
        zone = zone ~= "" and zone or "somewhere",
        subzone = bestSub ~= "" and bestSub or (zone ~= "" and zone or "somewhere"),
        city = o and o.city or nil,
        vibe = o and o.vibe or nil,
        resting = IsResting() and true or false,
    }
end

-- Curated, RP-friendly place names.
-- You can expand this over time without touching logic.
Banter.RandomPlaces = {
    -- Cities
    "Stormwind",
    "Ironforge",
    "Darnassus",
    "Orgrimmar",
    "Thunder Bluff",
    "Undercity",
    "Silvermoon",
    "Exodar",

    -- Zones
    "Elwynn Forest",
    "Westfall",
    "Redridge Mountains",
    "Duskwood",
    "Stranglethorn Vale",
    "The Barrens",
    "Ashenvale",
    "Desolace",
    "Tanaris",
    "Winterspring",

    -- Landmarks / regions
    "Blackrock Mountain",
    "The Plaguelands",
    "Deadwind Pass",
    "Alterac Valley",
    "Booty Bay",
}
