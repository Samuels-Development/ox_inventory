if not lib then return end

require 'modules.bridge.server'
require 'modules.crafting.server'
require 'modules.shops.server'
require 'modules.pefcl.server'

if GetConvar('inventory:versioncheck', 'true') == 'true' then
	lib.versionCheck('communityox/ox_inventory')
end

local TriggerEventHooks = require 'modules.hooks.server'
local db = require 'modules.mysql.server'
local Items = require 'modules.items.server'
local Inventory = require 'modules.inventory.server'


---The only keys that may ever be stored, matching `ThemeColors` in `web/src/typings/uiConfig.ts`.
local themeColorKeys = {
	'backgroundColor1',
	'backgroundColor2',
	'backgroundColor3',
	'rgbColor1',
	'rgbColor2',
	'mainColor',
	'secondaryColor',
	'textShadow',
	'photoShadowColor',
}

local isThemeColorKey = {}

for i = 1, #themeColorKeys do
	isThemeColorKey[themeColorKeys[i]] = true
end

---Longest legal value is `rgba(255, 255, 255, 0.000)`-ish; 64 is generous and bounds the work.
local MAX_COLOR_LENGTH = 64

---@param value string
---@param max number
---@return boolean
local function inRange(value, max)
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
		return inRange(r, 255) and inRange(g, 255) and inRange(b, 255)
	end

	local a
	r, g, b, a = value:match('^rgba%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d*%.?%d+)%s*%)$')

	if not r then return false end

	return inRange(r, 255) and inRange(g, 255) and inRange(b, 255) and inRange(a, 1)
end

---@param value any
---@return boolean
local function isThemeColor(value)
	if type(value) ~= 'string' then return false end

	local length = #value

	if length < 4 or length > MAX_COLOR_LENGTH then return false end

	return isHexColor(value) or isRgbColor(value)
end

---All nine keys are required and no others are tolerated - a partial or padded payload is
---rejected outright rather than silently repaired.
---@param colors any
---@return table? colors a fresh table containing only the validated values
local function validateThemeColors(colors)
	if type(colors) ~= 'table' then return end

	local validated = {}

	for i = 1, #themeColorKeys do
		local key = themeColorKeys[i]

		if not isThemeColor(colors[key]) then return end

		validated[key] = colors[key]
	end

	for key in pairs(colors) do
		if not isThemeColorKey[key] then return end
	end

	return validated
end

---@param name any must be a key of `shared.ui.themes`, or the literal 'custom'
---@param colors any only read when `name` is 'custom'
---@return string? name
---@return table? colors
local function validateTheme(name, colors)
	if type(name) ~= 'string' then return end

	if name == 'custom' then
		local validated = validateThemeColors(colors)

		if not validated then return end

		return name, validated
	end

	if type(shared.ui.themes) ~= 'table' or type(shared.ui.themes[name]) ~= 'table' then return end

	return name
end

local prefDefs = {
	-- §3 Display
	{ key = 'uiScale',           kind = 'number',      default = 1.0,       min = 0.75, max = 1.5,   step = 0.05 },
	{ key = 'backgroundDim',     kind = 'number',      default = 0.9,       min = 0.0,  max = 1.0,   step = 0.05 },
	{ key = 'reduceMotion',      kind = 'boolean',     default = false },
	{ key = 'slotSize',            kind = 'number',  default = 1.0,      min = 0.8,  max = 1.25,  step = 0.05 },
	{ key = 'slotSpacing',         kind = 'number',  default = 1.0,      min = 0.0,  max = 2.0,   step = 0.1 },
	{ key = 'cornerStyle',         kind = 'enum',    default = 'soft',   options = { 'sharp', 'soft', 'round' } },
	{ key = 'textSize',            kind = 'number',  default = 1.0,      min = 0.85, max = 1.2,   step = 0.05 },
	{ key = 'itemImageSize',       kind = 'number',  default = 1.0,      min = 0.7,  max = 1.2,   step = 0.05 },
	{ key = 'slotContrast',        kind = 'number',  default = 1.0,      min = 0.0,  max = 3.0,   step = 0.1 },
	{ key = 'panelSurface',        kind = 'number',  default = 0.0,      min = 0.0,  max = 0.6,   step = 0.05 },
	{ key = 'showSlotNoise',       kind = 'boolean', default = true },
	{ key = 'showDurability',      kind = 'boolean', default = true },
	{ key = 'showItemPlaceholder', kind = 'boolean', default = true },
	{ key = 'slotBorder',          kind = 'number',  default = 1.0,      min = 0.0,  max = 4.0,   step = 0.1 },
	{ key = 'figureOpacity',       kind = 'number',  default = 0.26,     min = 0.0,  max = 1.0,   step = 0.02 },
	{ key = 'showWeightRing',      kind = 'boolean', default = true },
	{ key = 'showPanelIcon',       kind = 'boolean', default = true },
	{ key = 'showSlotNumber',      kind = 'boolean', default = true },
	-- §4 Accessibility
	{ key = 'rarityDisplay',     kind = 'enum',        default = 'glow',    options = { 'off', 'border', 'glow' } },
	{ key = 'rarityPalette',     kind = 'enum',        default = 'default', options = { 'default', 'deuteranopia', 'protanopia', 'tritanopia' } },
	{ key = 'fontFamily',          kind = 'enum',    default = 'default', options = { 'default', 'system', 'mono', 'serif' } },
	{ key = 'boldText',            kind = 'boolean', default = false },
	{ key = 'highContrast',        kind = 'boolean', default = false },
	{ key = 'reduceTransparency',  kind = 'boolean', default = false },
	{ key = 'focusRing',           kind = 'boolean', default = false },
	-- §5 Behaviour
	{ key = 'tooltipDelay',      kind = 'number',      default = 500,       min = 0,    max = 1500,  step = 50 },
	{ key = 'showTooltips',          kind = 'boolean', default = true },
	{ key = 'showSearchBar',         kind = 'boolean', default = true },
	{ key = 'showFilterChips',       kind = 'boolean', default = true },
	{ key = 'showItemNotifications', kind = 'boolean', default = true },
	{ key = 'hotbarAlwaysOn',    kind = 'boolean',     default = false },
	{ key = 'hotbarTimeout',     kind = 'number',      default = 3000,      min = 1000, max = 10000, step = 500 },
	{ key = 'fastSlotCount',     kind = 'number',      default = 5,         min = 0,    max = 5,     step = 1 },
	{ key = 'showSlotLabel',     kind = 'boolean',     default = true },
	{ key = 'showSlotCount',     kind = 'boolean',     default = true },
	{ key = 'showSlotWeight',    kind = 'boolean',     default = true },
	-- §6 Sorting & favourites
	{ key = 'sortMode',          kind = 'enum',        default = 'slot',    options = { 'slot', 'name', 'weight', 'rarity', 'count' } },
	{ key = 'sortDirection',       kind = 'enum',    default = 'ascending', options = { 'ascending', 'descending' } },
	{ key = 'favouritesFirst',     kind = 'boolean', default = true },
	{ key = 'pageSize',            kind = 'number',  default = 30,       min = 10,   max = 100,   step = 10 },
	{ key = 'favourites',        kind = 'stringArray', default = {},        maxLength = 64, pattern = '^[%w_]+$' },
}

local prefDefByKey = {}

for i = 1, #prefDefs do
	prefDefByKey[prefDefs[i].key] = prefDefs[i]
end

---Bounds the work a crafted payload can force. The whitelist already caps how many keys can be
---*useful*; this stops ten thousand junk keys being walked before the first one is rejected.
local MAX_PREF_KEYS = #prefDefs

---Longest an individual favourite may be. Item names in this codebase are an order shorter.
local MAX_FAVOURITE_LENGTH = 64

---Clamp, then quantise. Mirrors `clampNumber` in `web/src/store/preferences.ts` exactly, so a
---value the client stores round-trips through the database unchanged.
---@param def table
---@param value number
---@return number
local function clampPrefNumber(def, value)
	if value < def.min then
		value = def.min
	elseif value > def.max then
		value = def.max
	end

	if def.step >= 1 then return math.floor(value + 0.5) end

	return math.floor(value * 10000 + 0.5) / 10000
end

---@param def table
---@param value any
---@return any? validated `nil` rejects. A *legal* value may itself be `false` or `0`, so callers
---must compare against nil rather than test truthiness.
local function validatePrefValue(def, value)
	local kind = def.kind

	if kind == 'boolean' then
		if type(value) ~= 'boolean' then return end

		return value
	end

	if kind == 'number' then
		-- NaN fails its own equality test; either infinity would otherwise clamp neatly onto a
		-- bound and be accepted, and neither is a value any control can produce.
		if type(value) ~= 'number' or value ~= value or value == math.huge or value == -math.huge then return end

		return clampPrefNumber(def, value)
	end

	if kind == 'enum' then
		if type(value) ~= 'string' then return end

		for i = 1, #def.options do
			if def.options[i] == value then return value end
		end

		return
	end

	if kind == 'stringArray' then
		if type(value) ~= 'table' then return end

		local count = 0

		for _ in pairs(value) do
			count += 1

			if count > def.maxLength then return end
		end

		local list, seen = {}, {}

		for i = 1, count do
			local entry = value[i]

			if type(entry) ~= 'string' then return end
			if #entry == 0 or #entry > MAX_FAVOURITE_LENGTH then return end
			if not entry:match(def.pattern) then return end

			if not seen[entry] then
				seen[entry] = true
				list[#list + 1] = entry
			end
		end

		return list
	end
end

---@param prefs any
---@return table? validated a fresh table holding only validated values; nil rejects the payload
local function validatePrefs(prefs)
	if type(prefs) ~= 'table' then return end

	local validated = {}
	local count = 0

	for key, value in pairs(prefs) do
		local def = type(key) == 'string' and prefDefByKey[key]

		-- An unrecognised key means the payload did not come from this UI. Reject all of it
		-- rather than storing the half we happen to understand.
		if not def then return end

		count += 1

		if count > MAX_PREF_KEYS then return end

		local ok = validatePrefValue(def, value)

		if ok == nil then return end

		validated[key] = ok
	end

	return validated
end

---@return { name: string, colors: table }
local function defaultTheme()
	return { name = shared.ui.theme, colors = shared.ui.themes[shared.ui.theme] }
end

---The settings row is keyed on the inventory owner, i.e. the character identifier.
---@param inv OxInventory?
---@return string?
local function settingsOwner(inv)
	local owner = inv and inv.owner

	if type(owner) == 'number' then owner = tostring(owner) end

	if type(owner) ~= 'string' or owner == '' then return end

	return owner
end

---@type table<string, table>
local settingsCache = {}

---@param owner string?
function server.forgetSettings(owner)
	if type(owner) == 'string' then settingsCache[owner] = nil end
end

---@param inv OxInventory?
---@return table settings
local function loadSettings(inv)
	local owner = settingsOwner(inv)

	if not owner then return {} end

	local cached = settingsCache[owner]

	if cached then return cached end

	local success, settings = pcall(db.loadSettings, owner)

	settings = (success and type(settings) == 'table') and settings or {}
	settingsCache[owner] = settings

	return settings
end

local MAX_FAST_SLOTS = 5
local MAX_BOUND_SLOT = 4096

---@param list any sparse map of fast slot index to inventory slot
---@return table? dense array, 0 where nothing is bound
local function encodeFastSlots(list)
	if type(list) ~= 'table' then return end

	local encoded = table.create(MAX_FAST_SLOTS, 0)
	local bound = false

	for i = 1, MAX_FAST_SLOTS do
		local slot = list[i]

		if type(slot) == 'number' and slot % 1 == 0 and slot > 0 and slot <= MAX_BOUND_SLOT then
			encoded[i] = slot
			bound = true
		else
			encoded[i] = 0
		end
	end

	return bound and encoded or nil
end

---@param encoded any
---@return table? sparse map of fast slot index to inventory slot
local function decodeFastSlots(encoded)
	if type(encoded) ~= 'table' then return end

	local list = {}

	for i = 1, MAX_FAST_SLOTS do
		local slot = encoded[i]

		if type(slot) == 'number' and slot % 1 == 0 and slot > 0 and slot <= MAX_BOUND_SLOT then
			list[i] = slot
		end
	end

	return next(list) and list or nil
end

---Resolves the theme sent in the `init` payload. Always returns a usable theme.
---@param settings table
---@return { name: string, colors: table }
local function resolveTheme(settings)
	local name, colors = validateTheme(settings.theme, settings.colors)

	if not name then return defaultTheme() end

	return { name = name, colors = colors or shared.ui.themes[name] }
end

---@param settings table
---@return table? prefs nil when nothing is stored, which omits the field from the payload
local function resolvePrefs(settings)
	local prefs = validatePrefs(settings.prefs)

	if not prefs or not next(prefs) then return end

	return prefs
end

---@param inv OxInventory
---@param patch { theme: { name: string, colors: table? }?, prefs: table? } already validated
---@return boolean
local function writeSettings(inv, patch)
	local owner = settingsOwner(inv)

	if not owner then return false end

	local existing = loadSettings(inv)
	local blob = {}

	if patch.theme then
		blob.theme = patch.theme.name
		blob.colors = patch.theme.colors
	else
		-- Re-validated on the way back out: a row hand-edited in the database is no more trusted
		-- than a payload from a client.
		blob.theme, blob.colors = validateTheme(existing.theme, existing.colors)
	end

	local prefs = validatePrefs(existing.prefs)

	if patch.prefs then
		prefs = prefs or {}

		-- Merged rather than replaced, so the panel may send only what the player changed.
		for key, value in pairs(patch.prefs) do prefs[key] = value end
	end

	blob.prefs = prefs
	blob.fastSlots = patch.fastSlots and encodeFastSlots(patch.fastSlots) or encodeFastSlots(decodeFastSlots(existing.fastSlots))

	settingsCache[owner] = blob

	local success, saved = pcall(db.saveSettings, owner, blob)

	return success and saved == true
end

---@param inv OxInventory?
---@return table? bindings
function server.loadFastSlots(inv)
	return decodeFastSlots(loadSettings(inv).fastSlots)
end

---@param inv OxInventory?
---@param list table bindings
---@return boolean
function server.saveFastSlots(inv, list)
	return writeSettings(inv, { fastSlots = list })
end

---@param source number
---@param data { name: string, colors: table? }
---@return boolean
lib.callback.register('ox_inventory:saveTheme', function(source, data)
	if type(data) ~= 'table' then return false end

	local inv = Inventory(source)

	if not inv or not inv.player then return false end

	local name, colors = validateTheme(data.name, data.colors)

	if not name then return false end

	return writeSettings(inv, { theme = { name = name, colors = colors } })
end)

---@param source number
---@param data { index: number, slot: number? }
---@return boolean
lib.callback.register('ox_inventory:setFastSlot', function(source, data)
	if type(data) ~= 'table' then return false end

	local inv = Inventory(source)

	if not inv or not inv.player then return false end

	local index = tonumber(data.index)

	if not index then return false end

	return Inventory.SetFastSlot(inv, index, data.slot ~= nil and tonumber(data.slot) or nil)
end)

---@param source number
---@param data { prefs: table }
---@return boolean
lib.callback.register('ox_inventory:savePrefs', function(source, data)
	if type(data) ~= 'table' then return false end

	local inv = Inventory(source)

	if not inv or not inv.player then return false end

	local prefs = validatePrefs(data.prefs)

	-- Whole-payload rejection: an unknown key, a wrong type, a non-member enum or a malformed
	-- favourites list stores nothing at all, rather than the part we happened to understand.
	if not prefs then return false end

	return writeSettings(inv, { prefs = prefs })
end)

---@param player table
---@param data table?
--- player requires source, identifier, and name
--- optionally, it should contain jobs/groups, sex, and dateofbirth
function server.setPlayerInventory(player, data)
	while not shared.ready do Wait(0) end

	if not data then
		data = db.loadPlayer(player.identifier)
	end

	local inventory = {}
	local totalWeight = 0

	if type(data) == 'table' then
		local ostime = os.time()

		for _, v in pairs(data) do
			if type(v) == 'number' or not v.count or not v.slot then
				if server.convertInventory then
					inventory, totalWeight = server.convertInventory(player.source, data)
					break
				else
					return error(('Inventory for player.%s (%s) contains invalid data. Ensure you have converted inventories to the correct format.'):format(player.source, GetPlayerName(player.source)))
				end
			else
				local item = Items(v.name)

				if item then
					v.metadata = Items.CheckMetadata(v.metadata or {}, item, v.name, ostime)
					local weight = Inventory.SlotWeight(item, v)
					totalWeight = totalWeight + weight

					inventory[v.slot] = {name = item.name, label = item.label, weight = weight, slot = v.slot, count = v.count, description = item.description, metadata = v.metadata, stack = item.stack, close = item.close}
				end
			end
		end
	end

	player.source = tonumber(player.source)
	local inv = Inventory.Create(player.source, player.name, 'player', shared.playerslots, totalWeight, shared.playerweight, player.identifier, inventory)

	if inv then
		inv.player = server.setPlayerData(player)
		inv.player.ped = GetPlayerPed(player.source)

		if server.syncInventory then server.syncInventory(inv) end

		-- Sent ahead of the payload below so the client has the worn bag cached by the time it
		-- builds the `init` message. Sends nothing at all when no bag is worn.
		Inventory.SyncBackpack(inv)

		local settings = loadSettings(inv)
		local theme = resolveTheme(settings)
		local prefs = resolvePrefs(settings)

		Inventory.RestoreFastSlots(inv, server.loadFastSlots(inv))

		TriggerClientEvent('ox_inventory:setPlayerInventory', player.source, Inventory.Drops, inventory, totalWeight, inv.player, theme, prefs, Inventory.GetFastSlots(inv), Inventory.GetWorn(inv))
	end
end
exports('setPlayerInventory', server.setPlayerInventory)
AddEventHandler('ox_inventory:setPlayerInventory', server.setPlayerInventory)

local registeredDumpsters = {}

---@param coords vector3
---@return string?
local function getDumpsterFromCoords(coords)
	local found

	for i = 1, #registeredDumpsters do
		local distance = #(coords - registeredDumpsters[i])

		if distance < 0.1 then
			found = i
			break
		end
	end

	return found
end

---@param playerPed number
---@param stash OxInventory
---@return vector3?
local function getClosestStashCoords(playerPed, stash)
	local playerCoords = GetEntityCoords(playerPed)
	local distance = stash.distance or 10
    local coordinates = stash.coords

    if not coordinates then return end

	if type(coordinates) == 'table' then
		for i = 1, #coordinates do
			local coords = coordinates[i] --[[@as vector3]]

			if #(coords - playerCoords) < distance then
				return coords
			end
		end

		return
	end

	return #(coordinates - playerCoords) < distance and coordinates or nil
end

---@param source number
---@param invType string
---@param data? string|number|table
---@param ignoreSecurityChecks boolean?
---@return table | false | nil, table | false | nil, string?
local function openInventory(source, invType, data, ignoreSecurityChecks)
	if Inventory.Lock then return false end

	local left = Inventory(source)
	local right, closestCoords

    if not left then return end

    left:closeInventory(true)
	Inventory.CloseAll(left, source)

    if invType == 'player' and data == source then
        data = nil
    end

    local playerPed = left.player.ped

	if data then
        local isDataTable = type(data) == 'table'

		if invType == 'stash' then
			right = Inventory(data, left, ignoreSecurityChecks)
			if right == false then return false end
		elseif isDataTable then
			if data.netid then
                local entity = NetworkGetEntityFromNetworkId(data.netid)

                if not entity then return end

                if not ignoreSecurityChecks then
                    if #(GetEntityCoords(playerPed) - GetEntityCoords(entity)) > 16 then return end
                end

                if invType == 'glovebox' then
                    if not ignoreSecurityChecks and GetVehiclePedIsIn(playerPed, false) ~= entity then
                        return
                    end
                end

                if invType == 'trunk' then
                    local lockStatus = ignoreSecurityChecks and 0 or GetVehicleDoorLockStatus(entity)

                    -- 0: no lock; 1: unlocked; 8: boot unlocked
                    if lockStatus > 1 and lockStatus ~= 8 then
                        return false, false, 'vehicle_locked'
                    end
                end

                local plate = (invType == 'glovebox' or invType == 'trunk') and GetVehicleNumberPlateText(entity)

                if plate then
                    if server.trimplate then plate = string.strtrim(plate) end

                    if not data.id  then
                        data.id = (invType == 'glovebox' and 'glove' or 'trunk') .. plate
                    end
                end

				data.type = invType
				right = Inventory(data)

				if right and data.netid ~= right.netid then
					local invEntity = NetworkGetEntityFromNetworkId(right.netid)

					if not (invEntity > 0 and DoesEntityExist(invEntity)) or (plate and not string.match(GetVehicleNumberPlateText(invEntity) or '', plate)) then
						Inventory.Remove(right)
						right = Inventory(data)
					end
				end
			elseif invType == 'drop' then
				right = Inventory(data.id)
			else
				return
			end
		elseif invType == 'policeevidence' then
			if ignoreSecurityChecks or server.hasGroup(left, shared.police) then
				right = Inventory(('evidence-%s'):format(data))
			end
		elseif invType == 'dumpster' then
			if shared.networkdumpsters then
				local dumpsterId = getDumpsterFromCoords(data)
				right = dumpsterId and Inventory(('dumpster-%s'):format(dumpsterId))

				if not right then
					dumpsterId = #registeredDumpsters + 1
					right = Inventory.Create(('dumpster-%s'):format(dumpsterId), locale('dumpster'), invType, 15, 0, 100000, false)
					registeredDumpsters[dumpsterId] = data
				end
			else
				---@cast data string
				right = Inventory(data)

				if not right then
					local netid = tonumber(data:sub(9))

					if netid and NetworkGetEntityFromNetworkId(netid) > 0 then
						right = Inventory.Create(data, locale('dumpster'), invType, 15, 0, 100000, false)
					end
				end
			end
		elseif invType == 'container' then
			left.containerSlot = data --[[@as number]]
			data = left.items[data]

			if data then
				right = Inventory(data.metadata.container)

				if not right then
					right = Inventory.Create(data.metadata.container, data.label, invType, data.metadata.size[1], 0, data.metadata.size[2], false)
				end
			else left.containerSlot = nil end
		else right = Inventory(data) end

		if not right then return end

        -- Security check to make sure the requested inventory type is the same as the found inventory
        -- Only case where a missmatch is tolerated is for temporary stashes
        if right.type ~= invType and not (right.type == 'temp' and invType == 'stash') then
            DropPlayer(source, 'sussy')
            return
        end

		if not ignoreSecurityChecks and right.groups and not server.hasGroup(left, right.groups) then return end

		local hookPayload = {
			source = source,
			inventoryId = right.id,
			inventoryType = right.type,
		}

		if invType == 'container' then hookPayload.slot = left.containerSlot end
		if isDataTable and data.netid then hookPayload.netId = data.netid end

		if not TriggerEventHooks('openInventory', hookPayload) then return end

        if left == right then return end

		if right.player then
			if right.open then return end

			right.coords = not ignoreSecurityChecks and GetEntityCoords(right.player.ped) or nil
		end

		if not ignoreSecurityChecks and right.coords then
			closestCoords = getClosestStashCoords(playerPed, right)

			if not closestCoords then return end
		end

		left:openInventory(right)
	else
		left:openInventory(left)
	end

	return {
		id = left.id,
		label = left.label,
		type = left.type,
		slots = left.slots,
		weight = left.weight,
		maxWeight = left.maxWeight
	}, right and {
		id = right.id,
		label = right.player and '' or right.label,
		type = right.player and 'otherplayer' or right.type,
		slots = right.slots,
		weight = right.weight,
		maxWeight = right.maxWeight,
		items = right.items,
		coords = closestCoords or right.coords,
		distance = right.distance
	}
end

---@param source number
---@param invType string
---@param data string|number|table
lib.callback.register('ox_inventory:openInventory', function(source, invType, data)
    if invType == 'player' and source ~= data then
        local serverId = type(data) == 'table' and data.id or data

        if source == serverId or type(serverId) ~= 'number' then return end

        local left = Inventory(source)
        if not left then return end

        local isPolice = server.hasGroup(left, shared.police)
        local isTargetStealable = Player(serverId).state.canSteal

        if not isPolice and not isTargetStealable then return end
    end

    return openInventory(source, invType, data)
end)

---@param netId number
lib.callback.register('ox_inventory:isVehicleATrailer', function(source, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local retval = GetVehicleType(entity)
	return retval == 'trailer'
end)

---@param playerId number
---@param invType string
---@param data string|number|table
function server.forceOpenInventory(playerId, invType, data)
	local left, right = openInventory(playerId, invType, data, true)

	if left and right then
		TriggerClientEvent('ox_inventory:forceOpenInventory', playerId, left, right)
		return right.id
	end
end

exports('forceOpenInventory', server.forceOpenInventory)

local Licenses = lib.load('data.licenses')

lib.callback.register('ox_inventory:buyLicense', function(source, id)
	local license = Licenses[id]
	if not license then return end

	local inventory = Inventory(source)
	if not inventory then return end

	return server.buyLicense(inventory, license)
end)

lib.callback.register('ox_inventory:getItemCount', function(source, item, metadata, target)
	local inventory = target and Inventory(target) or Inventory(source)
	return (inventory and Inventory.GetItemCount(inventory, item, metadata, true))
end)

lib.callback.register('ox_inventory:getInventory', function(source, id)
	local inventory = Inventory(id or source)
	return inventory and {
		id = inventory.id,
		label = inventory.label,
		type = inventory.type,
		slots = inventory.slots,
		weight = inventory.weight,
		maxWeight = inventory.maxWeight,
		owned = inventory.owner and true or false,
		items = inventory.items
	}
end)

RegisterNetEvent('ox_inventory:usedItemInternal', function(slot)
    local inventory = Inventory(source)

    if not inventory then return end

    local item = inventory.usingItem

    if not item or item.slot ~= slot then
        ---@todo
        DropPlayer(inventory.id, 'sussy')

        return
    end

    TriggerEvent('ox_inventory:usedItem', inventory.id, item.name, item.slot, next(item.metadata) and item.metadata)

    inventory.usingItem = nil
end)

---@param source number
---@param itemName string
---@param slot number?
---@param metadata { [string]: any }?
---@return table | boolean | nil
lib.callback.register('ox_inventory:useItem', function(source, itemName, slot, metadata, noAnim)
	local inventory = Inventory(source)

	if inventory and inventory.player then
		local item = Items(itemName)
		local data = item and (slot and inventory.items[slot] or Inventory.GetSlotWithItem(inventory, item.name, metadata, true))

		if not data then return end

		slot = data.slot
		local durability = data.metadata.durability --[[@as number|boolean|nil]]
		local consume = item.consume
		local label = data.metadata.label or item.label

		if durability and consume then
			if durability > 100 then
				local ostime = os.time()

				if ostime > durability then
                    Items.UpdateDurability(inventory, data, item, 0)
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
				elseif consume ~= 0 and consume < 1 then
					local degrade = (data.metadata.degrade or item.degrade) * 60
					local percentage = ((durability - ostime) * 100) / degrade

					if percentage < consume * 100 then
						return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('not_enough_durability', label) })
					end
				end
			elseif durability <= 0 then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
			elseif consume ~= 0 and consume < 1 and durability < consume * 100 then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('not_enough_durability', label) })
			end

			if data.count > 1 and consume < 1 and consume > 0 and not Inventory.GetEmptySlot(inventory, item) then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('cannot_use', label) })
			end
		end

		if item and data and data.count > 0 and data.name == item.name then
			data = {name=data.name, label=label, count=data.count, slot=slot, metadata=data.metadata, weight=data.weight}

			if item.ammo then
				if inventory.weapon then
					local weapon = inventory.items[inventory.weapon]

					if weapon and weapon?.metadata.durability > 0 then
						consume = nil
					end
				else return false end
			elseif item.component or item.tint then
				consume = 1
				data.component = true
			elseif consume then
				if data.count >= consume then
					local result = item.cb and item.cb('usingItem', item, inventory, slot)

					if result == false then return end

					if result ~= nil then
						data.server = result
					end
				else
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('item_not_enough', item.name) })
				end
			elseif not item.weapon and server.UseItem then
                inventory.usingItem = data
				-- This is used to call an external useItem function, i.e. ESX.UseItem
				-- If an error is being thrown on item use there is no internal solution. We previously kept a list
				-- of usable items which led to issues when restarting resources (for obvious reasons), but config
				-- developers complained the inventory broke their items. Safely invoking registered item callbacks
				-- should resolve issues, i.e. https://github.com/esx-framework/esx-legacy/commit/9fc382bbe0f5b96ff102dace73c424a53458c96e
				return pcall(server.UseItem, source, data.name, data)
			end

			data.consume = consume

            if not TriggerEventHooks('usingItem', {
				source = source,
                inventoryId = inventory and inventory.id,
                item = inventory.items[slot],
                consume = consume
			}) then return false end

            ---@type boolean
			local success = lib.callback.await('ox_inventory:usingItem', source, data, noAnim)

			if item.weapon then
				inventory.weapon = success and slot or nil
			end

			if not success then return end

            inventory.usingItem = data

			if consume and consume ~= 0 and not data.component then
				data = inventory.items[data.slot]

				if not data then return end

				durability = consume ~= 0 and consume < 1 and data.metadata.durability --[[@as number | false]]

				if durability then
					if durability > 100 then
						local degrade = (data.metadata.degrade or item.degrade) * 60
						durability -= degrade * consume
					else
						durability -= consume * 100
					end

					if data.count > 1 then
						local emptySlot = Inventory.GetEmptySlot(inventory, item)

						if emptySlot then
							local newItem = Inventory.SetSlot(inventory, item, 1, table.deepclone(data.metadata), emptySlot)

							if newItem then
                                Items.UpdateDurability(inventory, newItem, item, durability)
							end
						end

						durability = 0
					else
                        Items.UpdateDurability(inventory, data, item, durability)
					end

					if durability <= 0 then
						durability = false
					end
				end

				if not durability then
					Inventory.RemoveItem(inventory.id, data.name, consume < 1 and 1 or consume, nil, data.slot)
				else
					inventory.changed = true

					if server.syncInventory then server.syncInventory(inventory) end
				end

				if item?.cb then
					item.cb('usedItem', item, inventory, data.slot)
				end
			end

			return true
		end
	end
end)

local function conversionScript()
	shared.ready = false

	local file = 'setup/convert.lua'
	local import = LoadResourceFile(shared.resource, file)
	local func = load(import, ('@@%s/%s'):format(shared.resource, file)) --[[@as function]]

	conversionScript = func()
end

RegisterCommand('convertinventory', function(source, args)
	if source ~= 0 then return warn('This command can only be executed with the server console.') end
	if type(conversionScript) == 'function' then conversionScript() end
	local arg = args[1]

	local convert = arg and conversionScript[arg]

	if not convert then
		return warn('Invalid conversion argument. Valid options: esx, esxproperty')
	end

	CreateThread(convert)
end, true)


lib.addCommand({'additem', 'giveitem'}, {
	help = 'Gives an item to a player with the given id',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to receive the item' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of the item to give', optional = true },
		{ name = 'type', help = 'Sets the "type" metadata to the value', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = Items(args.item)

	if item then
		local inventory = Inventory(args.target) --[[@as OxInventory]]
		local count = args.count and math.max(args.count, 1) or 1

		local success, response = Inventory.AddItem(inventory, item.name, count, args.type and { type = tonumber(args.type) or args.type })

		if not success then
			return Citizen.Trace(('Failed to give %sx %s to player %s (%s)'):format(count, item.name, args.target, response))
		end

		source = Inventory(source) or { label = 'console', owner = 'console' }

		if server.loglevel > 0 then
			lib.logger(source.owner, 'admin', ('"%s" gave %sx %s to "%s"'):format(source.label, count, item.name, inventory.label))
		end
	end
end)

lib.addCommand('removeitem', {
	help = 'Removes an item to a player with the given id',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to remove the item from' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of the item to take', optional = true },
		{ name = 'type', help = 'Only remove items with a matching metadata "type"', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = Items(args.item)

	if item then
		local inventory = Inventory(args.target) --[[@as OxInventory]]
		local count = args.count and math.max(args.count, 1) or 1

		local success, response = Inventory.RemoveItem(inventory, item.name, count, args.type and { type = tonumber(args.type) or args.type }, nil, true)

		if not success then
			return Citizen.Trace(('Failed to remove %sx %s from player %s (%s)'):format(count, item.name, args.target, response))
		end

		source = Inventory(source) or {label = 'console', owner = 'console'}

		if server.loglevel > 0 then
			lib.logger(source.owner, 'admin', ('"%s" removed %sx %s from "%s"'):format(source.label, count, item.name, inventory.label))
		end
	end
end)

lib.addCommand('setitem', {
	help = 'Sets the item count for a player, removing or adding as needed',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to set the items for' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of items to set', optional = true },
		{ name = 'type', help = 'Add or remove items with the metadata "type"', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = Items(args.item)

	if item then
		local inventory = Inventory(args.target) --[[@as OxInventory]]
		local count = args.count and math.max(args.count, 0) or 0

		local success, response = Inventory.SetItem(inventory, item.name, count or 0, args.type and { type = tonumber(args.type) or args.type })

		if not success then
			return Citizen.Trace(('Failed to set %s count to %sx for player %s (%s)'):format(item.name, count, args.target, response))
		end

		source = Inventory(source) or {label = 'console', owner = 'console'}

		if server.loglevel > 0 then
			lib.logger(source.owner, 'admin', ('"%s" set "%s" %s count to %sx'):format(source.label, inventory.label, item.name, count))
		end
	end
end)

lib.addCommand('clearevidence', {
	help = 'Clears a police evidence locker with the given id',
	params = {
		{ name = 'locker', type = 'number', help = 'The locker id to clear' },
	},
}, function(source, args)
	if not server.isPlayerBoss then return end

	local inventory = Inventory(source)
	if not inventory then return end

	local group, grade = server.hasGroup(inventory, shared.police)
	local hasPermission = group and server.isPlayerBoss(source, group, grade)

	if hasPermission then
		MySQL.query('DELETE FROM ox_inventory WHERE name = ?', {('evidence-%s'):format(args.locker)})
	end
end)

lib.addCommand('takeinv', {
	help = 'Confiscates the target inventory, to restore with /restoreinv',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to confiscate items from' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.Confiscate(args.target)
end)

lib.addCommand({'restoreinv', 'returninv'}, {
	help = 'Restores a previously confiscated inventory for the target',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to restore items to' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.Return(args.target)
end)

lib.addCommand('clearinv', {
	help = 'Wipes all items from the target inventory',
	params = {
		{ name = 'invId', help = 'The inventory to wipe items from' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.Clear(tonumber(args.invId) or args.invId == 'me' and source or args.invId)
end)

lib.addCommand('saveinv', {
	help = 'Save all pending inventory changes to the database',
	params = {
		{ name = 'lock', help = 'Lock inventory access, until restart or saved without a lock', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.SaveInventories(args.lock == 'true', false)
end)

lib.addCommand('viewinv', {
	help = 'Inspect the target inventory without allowing interactions',
	params = {
		{ name = 'invId', help = 'The inventory to inspect' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.InspectInventory(source, tonumber(args.invId) or args.invId)
end)

lib.callback.register('ox_inventory:openContainer', function(source, slot)
	local left = Inventory(source)

	if not left or not left.open then return end
	if type(slot) ~= 'number' then return end

	local slotData = left.items[slot]

	if not slotData or not slotData.metadata or type(slotData.metadata.container) ~= 'string' then return end
	if not Items.containers[slotData.name] then return end
	if left.open == slotData.metadata.container then return end

	local container = Inventory.GetContainerFromSlot(left, slot)

	if not container then return end

	local previous = Inventory.GetOpenContainer(left)

	if previous and previous ~= container then previous.openedBy[source] = nil end

	left.containerSlot = slot
	container.openedBy[source] = true

	return Inventory.GetContainerPayload(left)
end)

lib.callback.register('ox_inventory:closeContainer', function(source)
	local left = Inventory(source)

	if left then
		local container = Inventory.GetOpenContainer(left)

		if container then container.openedBy[source] = nil end

		left.containerSlot = nil
	end

	return true
end)
