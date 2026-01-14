-- Banter/pools.lua
-- Shuffle-bag pools: no repeats until exhausted; boundary guard on reshuffle.

Banter = Banter or {}

local function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

Banter.PoolManager = {
    _bags = {}, -- category -> { bag = {idx...}, pos = 1, last = nil, n = #lines }
}

function Banter.PoolManager:_buildBag(category)
    local lines = Banter.LinePools[category]
    if not lines or #lines == 0 then
        return nil
    end

    local n = #lines
    local bag = {}
    for i = 1, n do bag[i] = i end
    shuffle(bag)

    local state = self._bags[category]
    local last = state and state.last or nil

    -- boundary guard: first in new bag shouldn't equal last from prior cycle
    if last and n > 1 and bag[1] == last then
        bag[1], bag[2] = bag[2], bag[1]
    end

    self._bags[category] = {
        bag = bag,
        pos = 1,
        last = last,
        n = n,
    }

    return self._bags[category]
end

function Banter.PoolManager:GetNextLine(category)
    local lines = Banter.LinePools[category]
    if not lines or #lines == 0 then
        return nil
    end

    local state = self._bags[category]
    if not state or state.n ~= #lines then
        state = self:_buildBag(category)
    end

    if not state then
        return nil
    end

    if state.pos > #state.bag then
        -- exhausted: rebuild
        state = self:_buildBag(category)
    end

    local idx = state.bag[state.pos]
    state.pos = state.pos + 1
    state.last = idx

    return lines[idx]
end