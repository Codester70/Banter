-- Banter/tokens.lua
-- Token formatting for templated lines.

Banter = Banter or {}

local function safe(v, fallback)
	if v == nil or v == "" then return fallback end
	return v
end

local function getRandomPlace()
	local list = Banter.RandomPlaces
	if not list or #list == 0 then
		return "somewhere"
	end
	return list[math.random(#list)]
end

function Banter.FormatTokens(text)
	if not text or text == "" then return text end

	-- Place info
	local info = Banter.GetPlaceInfo and Banter.GetPlaceInfo() or nil
	local zone = info and safe(info.zone, "somewhere") or "somewhere"
	local subzone = info and safe(info.subzone, zone) or zone
	local city = info and safe(info.city, zone) or zone
	local vibe = info and safe(info.vibe, "quiet") or "quiet"

	-- Target info
	local t = Banter.GetTargetInfo and Banter.GetTargetInfo("target") or nil
	local targetName = t and safe(t.name, "that one") or "that one"
	local className = t and safe(t.className, "") or ""
	local raceName = t and safe(t.raceName, "") or ""

	local they, them, their, theirs, themself = "they", "them", "their", "theirs", "themself"
	local theyre, theyve, theyll = "they're", "they've", "they'll"
	if t and t.pronouns then
		they = safe(t.pronouns.they, they)
		them = safe(t.pronouns.them, them)
		their = safe(t.pronouns.their, their)
		theirs = safe(t.pronouns.theirs, theirs)
		themself = safe(t.pronouns.themself, themself)
		theyre = safe(t.pronouns.theyre, theyre)
		theyve = safe(t.pronouns.theyve, theyve)
		theyll = safe(t.pronouns.theyll, theyll)
	end

	-- Replace tokens
	text = text:gsub("{zone}", zone)
	text = text:gsub("{subzone}", subzone)
	text = text:gsub("{city}", city)
	text = text:gsub("{vibe}", vibe)

	text = text:gsub("{target}", targetName)
	text = text:gsub("{class}", className)
	text = text:gsub("{race}", raceName)

	text = text:gsub("{they}", they)
	text = text:gsub("{them}", them)
	text = text:gsub("{their}", their)
	text = text:gsub("{theirs}", theirs)
	text = text:gsub("{themself}", themself)
	text = text:gsub("{theyre}", theyre)
	text = text:gsub("{theyve}", theyve)
	text = text:gsub("{theyll}", theyll)

	if text:find("{randomplace}") then
		local randomPlace = getRandomPlace()
		text = text:gsub("{randomplace}", randomPlace)
	end

	return text
end
