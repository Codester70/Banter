-- Banter/target.lua
-- Target info helper for banter logic + token formatting.

Banter = Banter or {}

local function SafeStr(v, fallback)
    if v == nil or v == "" then return fallback end
    return v
end

local function GetPronouns(sex)
  if sex == 2 then
    return {
      they="he", them="him", their="his", theirs="his", themself="himself",
      theyre="he's", theyve="he's", theyll="he'll",
    }
  elseif sex == 3 then
    return {
      they="she", them="her", their="her", theirs="hers", themself="herself",
      theyre="she's", theyve="she's", theyll="she'll",
    }
  end
  return {
    they="they", them="them", their="their", theirs="theirs", themself="themself",
    theyre="they're", theyve="they've", theyll="they'll",
  }
end

function Banter.GetTargetInfo(unit)
    unit = unit or "target"
    if not UnitExists(unit) then return nil end

    local name = UnitName(unit)
    name = SafeStr(name, "that one")

    local isPlayer = UnitIsPlayer(unit) and true or false
    local isDead = UnitIsDeadOrGhost(unit) and true or false
    local isSelf = UnitIsUnit(unit, "player") and true or false

    local isFriend = UnitIsFriend("player", unit) and true or false
    local isEnemy = UnitIsEnemy("player", unit) and true or false
    local reaction = UnitReaction(unit, "player") -- 1..8 or nil

    local sex = UnitSex(unit)
    local pronouns = GetPronouns(sex)

    local className, classFile = UnitClass(unit) -- players only (className nil for NPC)
    className = SafeStr(className, "")

    local raceName = nil
    if isPlayer then
        raceName = UnitRace(unit)
    end
    raceName = SafeStr(raceName, "")

    local creatureType = UnitCreatureType(unit) -- NPCs often
    creatureType = SafeStr(creatureType, "")

    return {
        unit = unit,
        name = name,

        isPlayer = isPlayer,
        isDead = isDead,
        isSelf = isSelf,

        isFriend = isFriend,
        isEnemy = isEnemy,
        reaction = reaction,

        sex = sex,
        pronouns = pronouns,

        className = className,
        classFile = classFile,

        raceName = raceName,
        creatureType = creatureType,
    }
end
