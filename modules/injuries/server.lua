if not lib then return end


local Inventory = require 'modules.inventory.server'

---Resolved on load. `init.lua` guarantees the shape, but a broken data/ui.lua must not be able to
---stop the server module loading, so it is defended anyway.
local config = shared.ui and shared.ui.injuries

if type(config) ~= 'table' or type(config.parts) ~= 'table' or type(config.types) ~= 'table' then
    config = { enabled = false, parts = {}, types = {} }
end

local enabled = config.enabled == true

---`[source] = { owner = string?, nextId = integer, list = injury[] }`
---@type table<number, table>
local state = {}

local Injuries = {}

-- ------------------------------------------------------------------ validation

---Bounds what a caller passing an endless stream of junk can grow. Once the budget is spent the
---warnings stop; the rejections do not.
local MAX_WARNED = 64

local warned = {}
local warnedCount = 0

---@param kind string
---@param value any
local function warnOnce(kind, value)
    if warnedCount >= MAX_WARNED then return end

    -- Truncated because the value came from outside and may be arbitrarily long.
    local text = tostring(value):sub(1, 64)
    local key = ('%s:%s'):format(kind, text)

    if warned[key] then return end

    warned[key] = true
    warnedCount += 1

    warn(('unknown injury %s \'%s\''):format(kind, text))
end

---Exports are called from other resources, so `source` is whatever the caller felt like passing.
---@param source any
---@return number? source a positive integer, or nil when the argument is not a player id
local function validSource(source)
    source = tonumber(source)

    -- NaN fails its own equality test; either infinity leaves a non-zero remainder.
    if type(source) ~= 'number' or source ~= source or source % 1 ~= 0 or source < 1 then return end

    return source
end

---@param part any
---@return string? part
local function validPart(part)
    if type(part) ~= 'string' or not config.parts[part] then
        warnOnce('part', part)
        return
    end

    return part
end

---@param injuryType any
---@return string? injuryType
local function validType(injuryType)
    if type(injuryType) ~= 'string' or not config.types[injuryType] then
        warnOnce('type', injuryType)
        return
    end

    return injuryType
end

-- ------------------------------------------------------------------ state

---@param source number
---@return string? owner
local function getOwner(source)
    local success, inv = pcall(Inventory, source)

    if not success then return end

    local owner = inv and inv.owner

    if type(owner) == 'number' then owner = tostring(owner) end
    if type(owner) ~= 'string' or owner == '' then return end

    return owner
end

---@param source number already validated
---@param create boolean? create an entry when the player has none
---@return table? entry
local function getState(source, create)
    local entry = state[source]
    local owner = getOwner(source)

    if entry and owner and entry.owner and entry.owner ~= owner then
        entry = nil
        state[source] = nil
    end

    if entry then
        -- Adopted late for anything added before the inventory existed.
        if owner and not entry.owner then entry.owner = owner end

        return entry
    end

    if not create then return end

    entry = { owner = owner, nextId = 1, list = {} }
    state[source] = entry

    return entry
end

---A defensive copy, so neither the wire payload nor an export's caller can reach into the state.
---@param entry table?
---@return table injuries
local function serialise(entry)
    local list = {}

    if not entry then return list end

    for i = 1, #entry.list do
        local injury = entry.list[i]

        list[i] = { id = injury.id, part = injury.part, type = injury.type, at = injury.at }
    end

    return list
end

-- ------------------------------------------------------------------ sync

---Pushes the whole list to its owner. Sent on inventory setup and after every mutation; never
---sent at all while the feature is off.
---@param source any
function Injuries.sync(source)
    if not enabled then return end

    source = validSource(source)

    if not source then return end

    -- Read through `getState` rather than the table directly: the setup push is the moment a
    -- second character on a recycled server id is discovered, and it must not inherit the list.
    TriggerClientEvent('ox_inventory:setInjuries', source, serialise(getState(source, false)))
end

---Drops everything held for a server id without notifying anyone - the player is gone.
---@param source any
function Injuries.clear(source)
    source = validSource(source)

    if not source then return end

    state[source] = nil
end

-- Runtime state belongs to the session. A player who disconnects leaves nothing behind, and the
-- server id they release must not hand their injuries to whoever connects onto it next.
AddEventHandler('playerDropped', function()
    Injuries.clear(source)
end)

-- ------------------------------------------------------------------ exports

---@param source number player server id
---@param part string a key of `shared.ui.injuries.parts`
---@param injuryType string a key of `shared.ui.injuries.types`
---@return number|false id the new or refreshed injury's id, or false when anything was rejected
local function addInjury(source, part, injuryType)
    if not enabled then return false end

    source = validSource(source)
    part = validPart(part)
    injuryType = validType(injuryType)

    if not source or not part or not injuryType then return false end

    local entry = getState(source, true) --[[@as table]]
    local list = entry.list
    local ostime = os.time()

    -- The same part may hold several injuries, but only one of each type: a repeat refreshes the
    -- timestamp in place rather than stacking a second identical marker.
    for i = 1, #list do
        local injury = list[i]

        if injury.part == part and injury.type == injuryType then
            injury.at = ostime
            Injuries.sync(source)

            return injury.id
        end
    end

    local id = entry.nextId

    entry.nextId = id + 1
    list[#list + 1] = { id = id, part = part, type = injuryType, at = ostime }

    Injuries.sync(source)

    return id
end

---@param source number player server id
---@param id number an id previously returned by `addInjury`
---@return boolean removed
local function removeInjury(source, id)
    if not enabled then return false end

    source = validSource(source)
    id = tonumber(id)

    if not source or type(id) ~= 'number' then return false end

    local entry = getState(source, false)

    if not entry then return false end

    local list = entry.list

    for i = 1, #list do
        if list[i].id == id then
            table.remove(list, i)
            Injuries.sync(source)

            return true
        end
    end

    return false
end

---Removes everything matching a predicate and returns how many went.
---@param source number already validated
---@param match fun(injury: table): boolean
---@return number healed
local function healWhere(source, match)
    local entry = getState(source, false)

    if not entry then return 0 end

    local list = entry.list
    local healed = 0

    -- Backwards so removal cannot skip the element that shifts into the current index.
    for i = #list, 1, -1 do
        if match(list[i]) then
            table.remove(list, i)
            healed += 1
        end
    end

    if healed > 0 then Injuries.sync(source) end

    return healed
end

---@param source number player server id
---@param part string a key of `shared.ui.injuries.parts`
---@return number healed
local function healPart(source, part)
    if not enabled then return 0 end

    source = validSource(source)
    part = validPart(part)

    if not source or not part then return 0 end

    return healWhere(source, function(injury) return injury.part == part end)
end

---@param source number player server id
---@param injuryType string a key of `shared.ui.injuries.types`
---@return number healed
local function healInjuryType(source, injuryType)
    if not enabled then return 0 end

    source = validSource(source)
    injuryType = validType(injuryType)

    if not source or not injuryType then return 0 end

    return healWhere(source, function(injury) return injury.type == injuryType end)
end

---@param source number player server id
---@return number healed
local function healAll(source)
    if not enabled then return 0 end

    source = validSource(source)

    if not source then return 0 end

    return healWhere(source, function() return true end)
end

---@param source number player server id
---@return table injuries `{ id, part, type, at }[]`, empty when there are none
local function getInjuries(source)
    if not enabled then return {} end

    source = validSource(source)

    if not source then return {} end

    return serialise(getState(source, false))
end

---With neither filter, answers "is this player hurt at all". An unknown part or type is a
---rejection, not a wildcard.
---@param source number player server id
---@param part string? a key of `shared.ui.injuries.parts`
---@param injuryType string? a key of `shared.ui.injuries.types`
---@return boolean
local function hasInjury(source, part, injuryType)
    if not enabled then return false end

    source = validSource(source)

    if not source then return false end

    if part ~= nil then
        part = validPart(part)

        if not part then return false end
    end

    if injuryType ~= nil then
        injuryType = validType(injuryType)

        if not injuryType then return false end
    end

    local entry = getState(source, false)

    if not entry then return false end

    local list = entry.list

    for i = 1, #list do
        local injury = list[i]

        if (not part or injury.part == part) and (not injuryType or injury.type == injuryType) then
            return true
        end
    end

    return false
end

exports('addInjury', addInjury)
exports('removeInjury', removeInjury)
exports('healPart', healPart)
exports('healInjuryType', healInjuryType)
exports('healAll', healAll)
exports('getInjuries', getInjuries)
exports('hasInjury', hasInjury)

Injuries.addInjury = addInjury
Injuries.removeInjury = removeInjury
Injuries.healPart = healPart
Injuries.healInjuryType = healInjuryType
Injuries.healAll = healAll
Injuries.getInjuries = getInjuries
Injuries.hasInjury = hasInjury

return Injuries
