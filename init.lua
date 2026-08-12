local function addDeferral(err)
    err = err:gsub("%^%d", "")

    AddEventHandler('playerConnecting', function(_, _, deferrals)
        deferrals.defer()
        deferrals.done(err)
    end)
end

-- Do not modify this file at all. This isn't a "config" file. You want to change
-- resource settings? Use convars like you were told in the documentation.
-- You did read the docs, right? Probably not, if you're here.
-- https://coxdocs.dev/ox_inventory#config

shared = {
    resource = GetCurrentResourceName(),
    framework = GetConvar('inventory:framework', 'esx'),
    playerslots = GetConvarInt('inventory:slots', 50),
    playerweight = GetConvarInt('inventory:weight', 30000),
    target = GetConvarInt('inventory:target', 0) == 1,
    police = json.decode(GetConvar('inventory:police', '["police", "sheriff"]')),
    networkdumpsters = GetConvarInt('inventory:networkdumpsters', 0) == 1
}

shared.dropslots = GetConvarInt('inventory:dropslots', shared.playerslots)
shared.dropweight = GetConvarInt('inventory:dropweight', shared.playerweight)

do
    if type(shared.police) == 'string' then
        shared.police = { shared.police }
    end

    local police = table.create(0, shared.police and #shared.police or 0)

    for i = 1, #shared.police do
        police[shared.police[i]] = 0
    end

    shared.police = police
end

if IsDuplicityVersion() then
    server = {
        bulkstashsave = GetConvarInt('inventory:bulkstashsave', 1) == 1,
        loglevel = GetConvarInt('inventory:loglevel', 1),
        randomprices = GetConvarInt('inventory:randomprices', 0) == 1,
        randomloot = GetConvarInt('inventory:randomloot', 1) == 1,
        evidencegrade = GetConvarInt('inventory:evidencegrade', 2),
        trimplate = GetConvarInt('inventory:trimplate', 1) == 1,
        vehicleloot = json.decode(GetConvar('inventory:vehicleloot', [[
			[
				["sprunk", 1, 1],
				["water", 1, 1],
				["garbage", 1, 2, 50],
				["panties", 1, 1, 5],
				["money", 1, 50],
				["money", 200, 400, 5],
				["bandage", 1, 1]
			]
		]])),
        dumpsterloot = json.decode(GetConvar('inventory:dumpsterloot', [[
			[
				["mustard", 1, 1],
				["garbage", 1, 3],
				["money", 1, 10],
				["burger", 1, 1]
			]
		]])),
    }

    local accounts = json.decode(GetConvar('inventory:accounts', '["money"]'))
    server.accounts = table.create(0, #accounts)

    for i = 1, #accounts do
        server.accounts[accounts[i]] = 0
    end
else
    PlayerData = {}
    client = {
        autoreload = GetConvarInt('inventory:autoreload', 0) == 1,
        screenblur = GetConvarInt('inventory:screenblur', 1) == 1,
        keys = json.decode(GetConvar('inventory:keys', '')) or { 'F2', 'K', 'TAB' },
        enablekeys = json.decode(GetConvar('inventory:enablekeys', '[249]')),
        aimedfiring = GetConvarInt('inventory:aimedfiring', 0) == 1,
        giveplayerlist = GetConvarInt('inventory:giveplayerlist', 0) == 1,
        weaponanims = GetConvarInt('inventory:weaponanims', 1) == 1,
        itemnotify = GetConvarInt('inventory:itemnotify', 1) == 1,
        weaponnotify = GetConvarInt('inventory:weaponnotify', 1) == 1,
        imagepath = GetConvar('inventory:imagepath', 'nui://ox_inventory/web/images'),
        dropprops = GetConvarInt('inventory:dropprops', 0) == 1,
        dropmodel = joaat(GetConvar('inventory:dropmodel', 'prop_med_bag_01b')),
        weaponmismatch = GetConvarInt('inventory:weaponmismatch', 1) == 1,
        ignoreweapons = json.decode(GetConvar('inventory:ignoreweapons', '[]')),
        suppresspickups = GetConvarInt('inventory:suppresspickups', 1) == 1,
        disableweapons = GetConvarInt('inventory:disableweapons', 0) == 1,
        disablesetupnotification = GetConvarInt('inventory:disablesetupnotification', 0) == 1,
        enablestealcommand = GetConvarInt('inventory:enablestealcommand', 1) == 1,
    }

    local ignoreweapons = table.create(0, (client.ignoreweapons and #client.ignoreweapons or 0) + 3)

    for i = 1, #client.ignoreweapons do
        local weapon = client.ignoreweapons[i]
        ignoreweapons[tonumber(weapon) or joaat(weapon)] = true
    end

    ignoreweapons[`WEAPON_UNARMED`] = true
    ignoreweapons[`WEAPON_HANDCUFFS`] = true
    ignoreweapons[`WEAPON_GARBAGEBAG`] = true
    ignoreweapons[`OBJECT`] = true
    ignoreweapons[`WEAPON_HOSE`] = true

    client.ignoreweapons = ignoreweapons

    local fallbackmarker = {
        type = 0,
        colour = {150, 150, 150},
        scale = {0.5, 0.5, 0.5}
    }

    client.shopmarker = json.decode(GetConvar('inventory:shopmarker', [[
        {
            "type": 29,
            "colour": [30, 150, 30],
            "scale": [0.5, 0.5, 0.5]
        }
    ]])) or fallbackmarker

    client.evidencemarker = json.decode(GetConvar('inventory:evidencemarker', [[
        {
            "type": 2,
            "colour": [30, 30, 150],
            "scale": [0.3, 0.2, 0.15]
        }
    ]])) or fallbackmarker

    client.craftingmarker = json.decode(GetConvar('inventory:craftingmarker', [[
        {
            "type": 2,
            "colour": [150, 150, 30],
            "scale": [0.3, 0.2, 0.15]
        }
    ]])) or fallbackmarker

    client.dropmarker = json.decode(GetConvar('inventory:dropmarker', [[
        {
            "type": 2,
            "colour": [150, 30, 30],
            "scale": [0.3, 0.2, 0.15]
        }
    ]])) or fallbackmarker
end

function shared.print(...) print(string.strjoin(' ', ...)) end

function shared.info(...) lib.print.info(string.strjoin(' ', ...)) end

---Throws a formatted type error.
---```lua
---error("expected %s to have type '%s' (received %s)")
---```
---@param variable string
---@param expected string
---@param received string
function TypeError(variable, expected, received)
    error(("expected %s to have type '%s' (received %s)"):format(variable, expected, received))
end

-- People like ignoring errors for some reason
local function spamError(err)
    shared.ready = false

    CreateThread(function()
        while true do
            Wait(10000)
            CreateThread(function()
                error(err, 0)
            end)
        end
    end)

    addDeferral(err)
    error(err, 0)
end

---@param name string
---@return table
---@deprecated
function data(name)
    if shared.server and shared.ready == nil then return {} end
    local file = ('data/%s.lua'):format(name)
    local datafile = LoadResourceFile(shared.resource, file)
    local path = ('@@%s/%s'):format(shared.resource, file)

    if not datafile then
        warn(('no datafile found at path %s'):format(path:gsub('@@', '')))
        return {}
    end

    local func, err = load(datafile, path)

    if not func or err then
        shared.ready = false
        ---@diagnostic disable-next-line: return-type-mismatch
        return spamError(err)
    end

    return func()
end

if not lib then
    return spamError('ox_inventory requires the ox_lib resource, refer to the documentation.')
end

local success, msg = lib.checkDependency('oxmysql', '2.7.3')

if success then
    success, msg = lib.checkDependency('ox_lib', '3.27.0')
end

if not success then
    return spamError(msg)
end

if not LoadResourceFile(shared.resource, 'web/build/index.html') then
    return spamError(
        'UI has not been built, refer to the documentation or download a release build.\n	^3https://coxdocs.dev/ox_inventory^0')
end

-- No we're not going to support qtarget any longer.
if shared.target and GetResourceState('ox_target') ~= 'started' then
    shared.target = false
    warn('ox_target is not loaded - it should start before ox_inventory')
end

do
    -- Mirrors data/ui.lua so the resource still starts when that file is missing or broken.
    -- Only the 'white' theme is duplicated here; the other six live in data/ui.lua alone.
    local default = {
        layout = 'slots',
        pedPreview = {
            mode = 'silhouette',
            distance = 2.4,
            height = -0.9,
            side = 0.0,
            turn = 0.0,
            light = true,
            lightRange = 3.0,
            lightIntensity = 2.0,
        },
        grid = {
            columns = 10,
            allowRotate = true,
            defaultSize = { 1, 1 },
            defaults = {
                weapon    = { 2, 2 },
                ammo      = { 1, 1 },
                component = { 1, 1 },
                tint      = { 1, 1 },
            },
        },
        clothing = {
            enabled = true,
            slots = {
                { name = 'hat',      label = 'Hat',      side = 'left'  },
                { name = 'glasses',  label = 'Glasses',  side = 'left'  },
                { name = 'mask',     label = 'Mask',     side = 'left'  },
                { name = 'earpiece', label = 'Earpiece', side = 'left'  },
                { name = 'torso',    label = 'Torso',    side = 'left'  },
                { name = 'armour',   label = 'Armour',   side = 'right' },
                { name = 'backpack', label = 'Backpack', side = 'right' },
                { name = 'gloves',   label = 'Gloves',   side = 'right' },
                { name = 'legs',     label = 'Legs',     side = 'right' },
                { name = 'shoes',    label = 'Shoes',    side = 'right' },
            },
        },
        rarity = {
            enabled = true,
            default = 'common',
            tiers = {
                common    = { label = 'Common',    color = '#9CA3AF', order = 1 },
                uncommon  = { label = 'Uncommon',  color = '#4ADE80', order = 2 },
                rare      = { label = 'Rare',      color = '#38BDF8', order = 3 },
                epic      = { label = 'Epic',      color = '#A855F7', order = 4 },
                legendary = { label = 'Legendary', color = '#F59E0B', order = 5 },
                mythic    = { label = 'Mythic',    color = '#FB7185', order = 6 },
            },
        },
        injuries = {
            enabled = false,
            parts = {},
            types = {},
        },
        theme = 'white',
        themes = {
            white = {
                backgroundColor1 = 'rgba(74, 75, 74, 0)',
                backgroundColor2 = 'rgba(77, 77, 77, 0.05)',
                backgroundColor3 = 'rgba(138, 138, 138, 0.1)',
                rgbColor1        = 'rgba(224, 224, 224, 0.1)',
                rgbColor2        = 'rgba(228, 228, 228, 0.05)',
                mainColor        = '#d6d6d6ff',
                secondaryColor   = '#757575ff',
                textShadow       = 'rgba(226, 226, 226, 0.36)',
                photoShadowColor = 'rgba(221, 221, 221, 0.3)',
            },
        },
    }

    local success, ui = pcall(lib.load, 'data.ui')

    if not success or type(ui) ~= 'table' then
        warn('unable to load data/ui.lua - using default interface settings')
        ui = default
    end

    for key, value in pairs(default) do
        if type(value) == 'table' then
            if type(ui[key]) ~= 'table' then ui[key] = value end
        elseif ui[key] == nil then
            ui[key] = value
        end
    end

    if type(ui.grid.defaults) ~= 'table' then ui.grid.defaults = default.grid.defaults end
    if type(ui.grid.defaultSize) ~= 'table' then ui.grid.defaultSize = default.grid.defaultSize end
    if type(ui.clothing.slots) ~= 'table' then ui.clothing.slots = default.clothing.slots end
    if type(ui.rarity.tiers) ~= 'table' then ui.rarity.tiers = default.rarity.tiers end
    if type(ui.injuries.parts) ~= 'table' then ui.injuries.parts = {} end
    if type(ui.injuries.types) ~= 'table' then ui.injuries.types = {} end

    local layout = GetConvar('inventory:layout', '')
    local gridcolumns = GetConvarInt('inventory:gridcolumns', 0)
    local clothing = GetConvarInt('inventory:clothing', -1)
    local rarity = GetConvarInt('inventory:rarity', -1)
    local injuries = GetConvarInt('inventory:injuries', -1)
    local theme = GetConvar('inventory:theme', '')

    if layout ~= '' then ui.layout = layout end
    if gridcolumns > 0 then ui.grid.columns = gridcolumns end
    if clothing >= 0 then ui.clothing.enabled = clothing == 1 end
    if rarity >= 0 then ui.rarity.enabled = rarity == 1 end
    if injuries >= 0 then ui.injuries.enabled = injuries == 1 end
    if theme ~= '' then ui.theme = theme end

    if ui.layout ~= 'slots' and ui.layout ~= 'grid' then
        warn(("unknown inventory layout '%s' - falling back to 'slots'"):format(tostring(ui.layout)))
        ui.layout = 'slots'
    end

    local columns = math.floor(tonumber(ui.grid.columns) or default.grid.columns)
    ui.grid.columns = columns < 5 and 5 or columns > 14 and 14 or columns
    ui.grid.allowRotate = ui.grid.allowRotate ~= false
    ui.clothing.enabled = ui.clothing.enabled ~= false
    ui.rarity.enabled = ui.rarity.enabled ~= false

    if type(ui.rarity.default) ~= 'string' or not ui.rarity.tiers[ui.rarity.default] then
        warn(("unknown default item rarity '%s' - falling back to 'common'"):format(tostring(ui.rarity.default)))
        ui.rarity.tiers.common = ui.rarity.tiers.common or default.rarity.tiers.common
        ui.rarity.default = 'common'
    end

    if type(ui.themes[ui.theme]) ~= 'table' then
        warn(("unknown inventory theme '%s' - falling back to 'white'"):format(tostring(ui.theme)))
        ui.themes.white = ui.themes.white or default.themes.white
        ui.theme = 'white'
    end

    local slots = {}

    for i = 1, #ui.clothing.slots do
        local slot = ui.clothing.slots[i]

        if type(slot) == 'table' and type(slot.name) == 'string' then
            slots[#slots + 1] = {
                name = slot.name,
                label = type(slot.label) == 'string' and slot.label or slot.name,
                side = slot.side == 'right' and 'right' or 'left',
            }
        else
            warn(('ignoring malformed clothing slot at index %s in data/ui.lua'):format(i))
        end
    end

    ui.clothing.slots = slots

    local MAX_COLOR_LENGTH = 64

    ---@param value string
    ---@param max number
    ---@return boolean
    local function inColorRange(value, max)
        -- The patterns below only ever capture plain digits, so `tonumber` cannot see `0x`/`1e9`.
        local number = tonumber(value)

        return number ~= nil and number >= 0 and number <= max
    end

    ---`#rgb`, `#rrggbb` or `#rrggbbaa`. Lua's `$` anchors the whole subject, so a trailing newline
    ---or `; background-image: ...` cannot slip past.
    ---@param value string
    ---@return boolean
    local function isHexColor(value)
        local hex = value:match('^#(%x+)$')

        if not hex then return false end

        local length = #hex

        return length == 3 or length == 6 or length == 8
    end

    ---`rgb(r, g, b)` or `rgba(r, g, b, a)` with integer channels 0-255 and alpha 0-1.
    ---@param value string
    ---@return boolean
    local function isRgbColor(value)
        local r, g, b = value:match('^rgb%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)$')

        if r then
            return inColorRange(r, 255) and inColorRange(g, 255) and inColorRange(b, 255)
        end

        local a
        r, g, b, a = value:match('^rgba%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d*%.?%d+)%s*%)$')

        if not r then return false end

        return inColorRange(r, 255) and inColorRange(g, 255) and inColorRange(b, 255) and inColorRange(a, 1)
    end

    ---@param value any
    ---@return boolean
    local function isUiColor(value)
        if type(value) ~= 'string' then return false end

        local length = #value

        if length < 4 or length > MAX_COLOR_LENGTH then return false end

        return isHexColor(value) or isRgbColor(value)
    end

    ---Part and type keys travel to the UI as object keys and come back in from other resources via
    ---the exports, so they are held to an identifier shape rather than accepted verbatim.
    ---@param key any
    ---@return boolean
    local function isInjuryKey(key)
        return type(key) == 'string' and #key <= 32 and key:match('^%a[%w_]*$') ~= nil
    end

    ---@param value any
    ---@param fallback number
    ---@return number 0..100
    local function clampAnchor(value, fallback)
        local number = tonumber(value)

        -- NaN fails its own equality test; either infinity would otherwise clamp onto a bound.
        if number == nil or number ~= number or number == math.huge or number == -math.huge then
            number = fallback
        end

        return number < 0 and 0 or number > 100 and 100 or number
    end

    local injuryParts, injuryTypes = {}, {}
    local hasInjuryPart, hasInjuryType = false, false

    for key, part in pairs(ui.injuries.parts) do
        if not isInjuryKey(key) or type(part) ~= 'table' then
            warn(('ignoring malformed injury part \'%s\' in data/ui.lua'):format(tostring(key)))
        else
            -- Rebuilt field by field, so anything else the entry carries is dropped here.
            injuryParts[key] = {
                label = type(part.label) == 'string' and part.label or key,
                x = clampAnchor(part.x, 50),
                y = clampAnchor(part.y, 50),
            }
            hasInjuryPart = true
        end
    end

    for key, injury in pairs(ui.injuries.types) do
        if not isInjuryKey(key) or type(injury) ~= 'table' then
            warn(('ignoring malformed injury type \'%s\' in data/ui.lua'):format(tostring(key)))
        else
            local severity = tonumber(injury.severity)
            local color = injury.color

            -- NaN would survive both comparisons in the clamp below and reach the payload.
            if severity == nil or severity ~= severity then severity = 1 end

            severity = math.floor(severity)

            if not isUiColor(color) then
                -- Falling back keeps the type usable rather than making a mistyped colour look
                -- like a broken export; the rejected string never leaves this block.
                warn(('injury type \'%s\' has an invalid colour - falling back to \'#9CA3AF\''):format(key))
                color = '#9CA3AF'
            end

            injuryTypes[key] = {
                label = type(injury.label) == 'string' and injury.label or key,
                severity = severity < 1 and 1 or severity > 3 and 3 or severity,
                color = color,
            }
            hasInjuryType = true
        end
    end

    ui.injuries.parts = injuryParts
    ui.injuries.types = injuryTypes
    -- Nothing to anchor a marker to, or nothing to draw in it, is the same as "off".
    ui.injuries.enabled = ui.injuries.enabled ~= false and hasInjuryPart and hasInjuryType

    ---Resolved interface configuration, shared by both sides.
    shared.ui = ui
    ---Number of equipment slots appended after `shared.playerslots`; 0 when clothing is disabled.
    shared.equipslots = ui.clothing.enabled and #slots or 0
    shared.totalplayerslots = shared.playerslots + shared.equipslots
end

if lib.context == 'server' then
    shared.ready = false
    return require 'server'
end

require 'client'
