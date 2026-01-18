-- Banter/tokens.lua
-- Token formatting for templated lines.

Banter = Banter or {}

local function safe(v, fallback)
	if v == nil or v == "" then return fallback end
	return v
end

local function gsub_word(text, from, to)
	-- whole-word replacement only (prevents "you" inside "young")
	return text:gsub("(%f[%a])" .. from .. "(%f[^%a])", "%1" .. to .. "%2")
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

	local weatherText = nil
	if text:find("{weather}") then
		local weather = Banter.GetWeather and Banter:GetWeather()
		if weather then
			weatherText = weather.type:lower()
		else
			weatherText = "the weather"
		end
	end

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

	if weatherText then
		text = text:gsub("{weather}", weatherText)
	end

	return text
end

local function Scottishify(text)
	if not text or text == "" then return text end

	-- Work on a copy
	local t = text

	-- Phrase swaps first (more specific before more general)
	t = t:gsub("(%f[%a])you are(%f[^%a])", "%1ye are%2")
	t = t:gsub("(%f[%a])i am(%f[^%a])", "%1ah am%2")

	-- Contractions / common words (lowercase only; we keep it simple & readable)
	t = gsub_word(t, "don't", "dinnae")
	t = gsub_word(t, "can't", "cannae")
	t = gsub_word(t, "won't", "winnae")
	t = gsub_word(t, "isn't", "isnae")
	t = gsub_word(t, "doesn't", "doesnae")
	t = gsub_word(t, "couldn't", "couldnae")
	t = gsub_word(t, "shouldn't", "shouldnae")
	t = gsub_word(t, "wouldn't", "wouldnae")
	t = gsub_word(t, "won't", "winnae")
	t = gsub_word(t, "not", "no'")
	t = gsub_word(t, "nothing", "nae thin'")
	t = gsub_word(t, "your", "yer")
	t = gsub_word(t, "you", "ye")
	t = gsub_word(t, "my", "me")
	t = gsub_word(t, "to", "tae")
	t = gsub_word(t, "of", "o'")
	t = gsub_word(t, "and", "an'")
	t = gsub_word(t, "for", "fer")

	-- Drop trailing "g" in gerunds: "walking" -> "walkin'"
	-- Avoid words where "ing" is part of the root (e.g., "spring").
	local ingExceptions = {
		spring = true,
		thing  = true,
		king   = true,
		ring   = true,
		wing   = true,
		sing   = true,
		bring  = true, -- not a gerund
		sting  = true,
		sling  = true,
		fling  = true,
		swing = true
	}

	t = t:gsub("(%f[%a])([A-Za-z]+)(%f[^%a])", function(prefix, word, suffix)
		-- NOTE: prefix/suffix are empty strings from frontier captures; we return them unchanged.
		local lower = word:lower()

		-- Only transform words ending in "ing"
		if not lower:match("ing$") then
			return prefix .. word .. suffix
		end

		-- Exclude common false positives like "spring"
		if ingExceptions[lower] then
			return prefix .. word .. suffix
		end

		-- Require at least 4 letters before "ing" (helps avoid oddities)
		local stem = word:sub(1, -4) -- remove "ing"
		if #stem < 4 then
			return prefix .. word .. suffix
		end

		return prefix .. stem .. "in'" .. suffix
	end)

	return t
end

Banter.Scottishify = Scottishify
