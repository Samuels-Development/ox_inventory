if not lib then return end

local Grid = require 'modules.grid.shared'

local Inventory = {}

---@type table<any, OxInventory>
local Inventories = {}

---@class OxInventory
---@field backpack? string
local OxInventory = {}
OxInventory.__index = OxInventory

---Open a player's inventory, optionally with a secondary inventory.
---@param inv? inventory
function OxInventory:openInventory(inv)
	if not self?.player then return end

	inv = Inventory(inv)

	if not inv then return end

	inv:set('open', true)
	inv.openedBy[self.id] = true
	self.open = inv.id

	TriggerEvent('ox_inventory:openedInventory', self.id, inv.id)
end

---Close a player's inventory.
---@param noEvent? boolean
function OxInventory:closeInventory(noEvent)
	if not self.player or not self.open then return end

	local inv = Inventory(self.open)

	if not inv then return end

	local container = Inventory.GetOpenContainer(self)

	if container then container.openedBy[self.id] = nil end

	inv.openedBy[self.id] = nil
	inv:set('open', false)
	self.open = false
	self.currentShop = nil
	self.containerSlot = nil

	if not noEvent then
		TriggerClientEvent('ox_inventory:closeInventory', self.id, true)
	end

	TriggerEvent('ox_inventory:closedInventory', self.id, inv.id)
end

---@alias updateSlot { item: SlotWithItem | { slot: number }, inventory: string|number }

---Sync a player's inventory state.
---@param slots updateSlot[]
---@param weight { left?: number, right?: number } | number
function OxInventory:syncSlotsWithPlayer(slots, weight)
	TriggerClientEvent('ox_inventory:updateSlots', self.id, slots, weight)
end

---Sync an inventory's state with all player's accessing it.
---@param slots updateSlot[]
---@param syncOwner? boolean
function OxInventory:syncSlotsWithClients(slots, syncOwner)
	for playerId in pairs(self.openedBy) do
		if self.id ~= playerId then
            local target = Inventories[playerId]

            if target then
			    TriggerClientEvent('ox_inventory:updateSlots', playerId, slots, target.weight)
            end
		end
	end

	if syncOwner and self.player then
		TriggerClientEvent('ox_inventory:updateSlots', self.id, slots, self.weight)
	end
end

local Vehicles = lib.load('data.vehicles')
local RegisteredStashes = {}

for _, stash in pairs(lib.load('data.stashes') or {}) do
	RegisteredStashes[stash.name] = {
		name = stash.name,
		label = stash.label,
		owner = stash.owner,
		slots = stash.slots,
		maxWeight = stash.weight,
		groups = stash.groups or stash.jobs,
		coords = shared.target and stash.target?.loc or stash.coords,
        distance = stash.distance or 10,
        gridRows = tonumber(stash.gridRows)
	}
end

local GetVehicleNumberPlateText = GetVehicleNumberPlateText

---Atempts to lazily load inventory data from the database or create a new player-owned instance for "personal" stashes
---@param data table
---@param player table
---@param ignoreSecurityChecks boolean
---@return OxInventory | false | nil
local function loadInventoryData(data, player, ignoreSecurityChecks)
	local source = source
	local inventory

	if not data.type and type(data.id) == 'string' then
		if data.id:find('^glove') then
			data.type = 'glovebox'
		elseif data.id:find('^trunk') then
			data.type = 'trunk'
		elseif data.id:find('^evidence-') then
			data.type = 'policeevidence'
		end
	end

	if data.type == 'trunk' or data.type == 'glovebox' then
		local plate = data.id:sub(6)

		if server.trimplate then
			plate = string.strtrim(plate)
			data.id = ('%s%s'):format(data.id:sub(1, 5), plate)
		end

		inventory = Inventories[data.id]

		if not inventory then
			local entity

			if data.netid then
				entity = NetworkGetEntityFromNetworkId(data.netid)

				if not entity then
					return shared.info('Failed to load vehicle inventory data (no entity exists with given netid).')
				end

                data.entityId = entity
			else
				local vehicles = GetAllVehicles()

				for i = 1, #vehicles do
					local vehicle = vehicles[i]
					local _plate = GetVehicleNumberPlateText(vehicle)

					if _plate:find(plate) then
						entity = vehicle
                        data.entityId = entity
						data.netid = NetworkGetNetworkIdFromEntity(entity)
						break
					end
				end

				if not entity then
					return shared.info('Failed to load vehicle inventory data (no entity exists with given plate).')
				end
			end

			if not source then
				source = NetworkGetEntityOwner(entity)

				if not source then
					return shared.info('Failed to load vehicle inventory data (entity is unowned).')
				end
			end

			local model, class = lib.callback.await('ox_inventory:getVehicleData', source, data.netid)
			local storage = Vehicles[data.type].models[model] or Vehicles[data.type][class]
            local dbId

            if server.getOwnedVehicleId then
                dbId = server.getOwnedVehicleId(entity)
            else
                dbId = data.id:sub(6)
            end

            inventory = Inventory.Create(data.id, plate, data.type, storage[1], 0, storage[2], false, nil, nil, dbId)
		end
	elseif data.type == 'policeevidence' then
		inventory = Inventory.Create(data.id, locale('police_evidence'), data.type, 100, 0, 100000, false)
	else
		local stash = RegisteredStashes[data.id]

		if stash then
			if stash.jobs then stash.groups = stash.jobs end
			if not ignoreSecurityChecks and player and stash.groups and not server.hasGroup(player, stash.groups) then return end

			local owner

			if stash.owner then
				if stash.owner == true then
					owner = data.owner or player?.owner
				else
					owner = stash.owner
				end
			end

			inventory = Inventories[owner and ('%s:%s'):format(stash.name, owner) or stash.name]

			if not inventory then
				inventory = Inventory.Create(stash.name, stash.label or stash.name, 'stash', stash.slots, 0, stash.maxWeight, owner, nil, stash.groups, nil, stash.gridRows)
                inventory.coords = stash.coords
                inventory.distance = stash.distance
			end
		end
	end

	if data.netid then
        inventory.entityId = data.entityId or NetworkGetEntityFromNetworkId(data.netid)
		inventory.netid = data.netid
	end

	return inventory or false
end

setmetatable(Inventory, {
	__call = function(self, inv, player, ignoreSecurityChecks)
        if Inventory.Lock then return false end

		if not inv then
			return self
		elseif type(inv) == 'table' then
			if inv.__index then return inv end

			return not inv.owner and Inventories[inv.id] or loadInventoryData(inv, player, ignoreSecurityChecks)
		end

		return Inventories[inv] or loadInventoryData({ id = inv }, player, ignoreSecurityChecks)
	end
})

---@cast Inventory +fun(inv: inventory, player?: inventory, ignoreSecurityChecks?: boolean): OxInventory|false|nil

---@param inv inventory
---@param owner? string | number
local function getInventory(inv, owner)
	if not inv then return Inventory end

	local type = type(inv)

	if type == 'table' or type == 'number' then
		return Inventory(inv)
	else
		return Inventory({ id = inv, owner = owner })
	end
end

exports('Inventory', getInventory)
exports('GetInventory', getInventory)

---@param inv inventory
---@param owner? string | number
---@return table?
exports('GetInventoryItems', function(inv, owner)
	return getInventory(inv, owner)?.items
end)

---@param inv inventory
---@param slotId number
---@return OxInventory?
function Inventory.GetContainerFromSlot(inv, slotId)
	local inventory = Inventory(inv)
	local slotData = inventory and inventory.items[slotId]

	if not slotData then return end

	local container = Inventory(slotData.metadata.container)

	if not container then
		container = Inventory.Create(slotData.metadata.container, slotData.label, 'container', slotData.metadata.size[1], 0, slotData.metadata.size[2], false)
	end

	return container
end

exports('GetContainerFromSlot', Inventory.GetContainerFromSlot)

---@param inv? inventory
---@param ignoreId? number|false
function Inventory.CloseAll(inv, ignoreId)
	if not inv then
		for _, data in pairs(Inventories) do
			for playerId in pairs(data.openedBy) do
				local playerInv = Inventory(playerId)

				if playerInv then playerInv:closeInventory(true) end
			end
		end

		return TriggerClientEvent('ox_inventory:closeInventory', -1, true)
	end

	inv = Inventory(inv) --[[@as OxInventory?]]

	if not inv then return end

	for playerId in pairs(inv.openedBy) do
		local playerInv = Inventory(playerId)

		if playerInv and playerId ~= ignoreId then
            playerInv:closeInventory()
        end
	end
end

---@param inv inventory
---@param k string
---@param v any
function Inventory.Set(inv, k, v)
	inv = Inventory(inv) --[[@as OxInventory]]

	if inv then
		if type(v) == 'number' then
			v = math.floor(v + 0.5)
		end

		if k == 'open' and v == false then
			if inv.type ~= 'player' then
				if inv.player then
					inv.type = 'player'
				elseif inv.type == 'drop' and not next(inv.items) and not next(inv.openedBy) then
					return Inventory.Remove(inv)
				else
					inv.time = os.time()
				end
			end

			if inv.player then
				inv.containerSlot = nil
			end
		elseif k == 'maxWeight' and v < 1000 then
			v *= 1000
		end

		inv[k] = v
	end
end

---@param inv inventory
---@param key string
function Inventory.Get(inv, key)
	inv = Inventory(inv) --[[@as OxInventory]]
	if inv then
		return inv[key]
	end
end

---@class MinimalInventorySlot
---@field name string
---@field count number
---@field slot number
---@field metadata? table

---@param inv inventory
---@return MinimalInventorySlot[] items
local function minimal(inv)
	inv = Inventory(inv) --[[@as OxInventory]]
	local inventory, count = {}, 0
	for k, v in pairs(inv.items) do
		if v.name and v.count > 0 then
			count += 1
			inventory[count] = {
				name = v.name,
				count = v.count,
				slot = k,
				metadata = next(v.metadata) and v.metadata or nil
			}
		end
	end
	return inventory
end

---@param inv OxInventory?
---@return table? bindings
local function fastSlots(inv)
	if type(inv) ~= 'table' or inv.type ~= 'player' then return end
	if Grid.getFastSlotCount() == 0 then return end

	local list = inv.fastSlots

	if not list then
		list = {}
		inv.fastSlots = list
	end

	return list
end

---@param list table
---@param slot number
---@return number? index
local function fastSlotIndexOf(list, slot)
	for index, bound in pairs(list) do
		if bound == slot then return index end
	end
end

---@param inv OxInventory
local function syncFastSlots(inv)
	inv.fastSlotsChanged = true

	TriggerClientEvent('ox_inventory:setFastSlots', inv.id, inv.fastSlots or {})
end

---@param inv OxInventory?
---@param fromSlot number
---@param toSlot number?
local function moveFastSlot(inv, fromSlot, toSlot)
	local list = type(inv) == 'table' and inv.type == 'player' and inv.fastSlots or nil

	if not list then return end

	local index = fastSlotIndexOf(list, fromSlot)

	if not index then return end

	if toSlot and fastSlotIndexOf(list, toSlot) then toSlot = nil end

	list[index] = toSlot

	syncFastSlots(inv)
end

---@param inv OxInventory?
---@param sync boolean?
---@return boolean changed
local function pruneFastSlots(inv, sync)
	local list = type(inv) == 'table' and inv.type == 'player' and inv.fastSlots or nil

	if not list then return false end

	local changed = false
	local baseSlots = Grid.getBaseSlots(inv)

	for index, slot in pairs(list) do
		if not Grid.isFastSlot(index) or not Grid.isSlotId(slot, baseSlots) or not inv.items[slot] then
			list[index] = nil
			changed = true
		end
	end

	if changed and sync then syncFastSlots(inv) end

	return changed
end

---@param fromInventory OxInventory
---@param toInventory OxInventory
---@param data SwapSlotData
---@param action string 'swap' | 'stack' | 'move'
---@param vacated boolean the source stack left the source slot entirely
local function rebindAfterSwap(fromInventory, toInventory, data, action, vacated)
	local fromList = fromInventory.type == 'player' and fromInventory.fastSlots or nil
	local toList = toInventory.type == 'player' and toInventory.fastSlots or nil

	if not fromList and not toList then return end

	local sameInventory = fromInventory.id == toInventory.id
	local fromIndex = fromList and fastSlotIndexOf(fromList, data.fromSlot) or nil
	local toIndex = toList and fastSlotIndexOf(toList, data.toSlot) or nil

	if not fromIndex and not toIndex then return end

	if action == 'swap' then
		if sameInventory then
			if fromIndex then fromList[fromIndex] = data.toSlot end
			if toIndex then toList[toIndex] = data.fromSlot end

			return syncFastSlots(fromInventory)
		end

		if fromIndex then
			fromList[fromIndex] = nil
			syncFastSlots(fromInventory)
		end

		if toIndex then
			toList[toIndex] = nil
			syncFastSlots(toInventory)
		end

		return
	end

	if not fromIndex or not vacated then return end

	moveFastSlot(fromInventory, data.fromSlot, sameInventory and data.toSlot or nil)
end

---@param inv OxInventory
local function reclaimStrandedSlots(inv)
	local list = fastSlots(inv)

	if not list then return end

	local total = inv.slots
	local stranded, count = {}, 0

	for slot, item in pairs(inv.items) do
		if slot > total then
			count += 1
			stranded[count] = { band = slot - total, slot = slot, item = item }
		end
	end

	if count == 0 then return end

	table.sort(stranded, function(a, b) return a.band < b.band end)

	local gridLayout = Grid.isGridLayout()
	local layout = gridLayout and Grid.getLayout(inv) or nil
	local baseSlots = Grid.getBaseSlots(inv)

	for i = 1, count do
		local entry = stranded[i]
		local item = entry.item
		local width, height = Grid.getItemSize(Grid.getItem(item.name), item.metadata)

		for target = 1, baseSlots do
			if not inv.items[target] and (not layout or Grid.fits(layout, target, width, height)) then
				inv.items[entry.slot] = nil
				item.slot = target
				inv.items[target] = item

				if layout then Grid.mark(layout, target, width, height) end
				if Grid.isFastSlot(entry.band) then list[entry.band] = target end

				inv.changed = true
				inv.fastSlotsChanged = true
				break
			end
		end

		if inv.items[entry.slot] then
			warn(("no room to reclaim %sx %s from the removed hotbar band for '%s'; it stays hidden until a cell frees up"):format(item.count, item.name, tostring(inv.owner)))
		end
	end
end

---@param inv OxInventory
local function saveFastSlots(inv)
	if not inv.fastSlotsChanged or inv.type ~= 'player' or not server.saveFastSlots then return end

	inv.fastSlotsChanged = false

	server.saveFastSlots(inv, inv.fastSlots or {})
end

---@param inv OxInventory?
---@return table bindings a copy, safe to hand out
function Inventory.GetFastSlots(inv)
	local list = fastSlots(Inventory(inv))

	return list and table.clone(list) or {}
end

exports('GetFastSlots', Inventory.GetFastSlots)

---@param inv inventory
---@param index number fast slot, 1-based
---@param slot number? grid slot holding the stack to bind
---@return boolean success
function Inventory.SetFastSlot(inv, index, slot)
	inv = Inventory(inv) --[[@as OxInventory]]

	local list = fastSlots(inv)

	if not list or not Grid.isFastSlot(index) then return false end

	if slot ~= nil then
		if not Grid.isSlotId(slot, Grid.getBaseSlots(inv)) or not inv.items[slot] then return false end

		local existing = fastSlotIndexOf(list, slot)

		if existing == index then return true end
		if existing then list[existing] = nil end
	elseif list[index] == nil then
		return false
	end

	list[index] = slot

	syncFastSlots(inv)

	return true
end

exports('SetFastSlot', Inventory.SetFastSlot)

---@param inv OxInventory?
---@param list table?
function Inventory.RestoreFastSlots(inv, list)
	if not fastSlots(inv) then return end

	local restored = type(list) == 'table' and next(list) ~= nil

	if restored then inv.fastSlots = list end

	local pruned = pruneFastSlots(inv, false)

	if restored and not pruned then inv.fastSlotsChanged = false end
end

Inventory.ClearFastSlot = function(inv, slot) moveFastSlot(inv, slot, nil) end

---@param inv OxInventory?
local function refreshBackpackDeferred(inv)
	if not Inventory.RefreshBackpack(inv) then return end

	CreateThread(function() Inventory.SyncBackpack(inv) end)
end

---@param inv inventory
---@param item table
---@param count number
---@param metadata any
---@param slot any
function Inventory.SetSlot(inv, item, count, metadata, slot)
	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv then return end

	local currentSlot = inv.items[slot]

	if not currentSlot then
		if not Grid.isSlotId(slot, inv.slots) then return end
		if Grid.isEquipSlot(inv, slot) and not Grid.canEquip(inv, slot, item) then return end
	end

	local newCount = currentSlot and currentSlot.count + count or count
	local newWeight = currentSlot and inv.weight - currentSlot.weight or inv.weight

	if currentSlot and newCount < 1 then
		TriggerClientEvent('ox_inventory:itemNotify', inv.id, { currentSlot, 'ui_removed', currentSlot.count })
		currentSlot = nil
	else
		currentSlot = {name = item.name, label = item.label, weight = item.weight, slot = slot, count = newCount, description = item.description, metadata = metadata, stack = item.stack, close = item.close}
		local slotWeight = Inventory.SlotWeight(item, currentSlot)
		currentSlot.weight = slotWeight
		newWeight += slotWeight

		TriggerClientEvent('ox_inventory:itemNotify', inv.id, { currentSlot, count < 0 and 'ui_removed' or 'ui_added', math.abs(count) })
	end

	inv.weight = newWeight
	inv.items[slot] = currentSlot
	inv.changed = true

	if not currentSlot then moveFastSlot(inv, slot, nil) end

	Inventory.RefreshEquipment(inv, slot)

	return currentSlot
end

local Items = require 'modules.items.server'

Grid.setItemResolver(function(name) return Items(name) end)

CreateThread(function()
    Inventory.accounts = server.accounts
    TriggerEvent('ox_inventory:loadInventory', Inventory)
end)

function Inventory.GetAccountItemCounts(inv)
    inv = Inventory(inv)

    if not inv then return end

    local accounts = table.clone(server.accounts)

	for _, v in pairs(inv.items) do
		if accounts[v.name] then
			accounts[v.name] += v.count
		end
	end

    return accounts
end

---@param item table
---@param slot table
function Inventory.SlotWeight(item, slot, ignoreCount)
	local weight = ignoreCount and item.weight or item.weight * (slot.count or 1)

	if not slot.metadata then slot.metadata = {} end

	if item.ammoname and slot.metadata.ammo then
		local ammoWeight = Items(item.ammoname)?.weight

		if ammoWeight then
			weight += (ammoWeight * slot.metadata.ammo)
		end
	end

    if item.hash == `WEAPON_PETROLCAN` then
        slot.metadata.weight = 15000 * (slot.metadata.ammo / 100)
    end

	if slot.metadata.components then
		for i = #slot.metadata.components, 1, -1 do
			local componentWeight = Items(slot.metadata.components[i])?.weight

			if componentWeight then
				weight += componentWeight
			end
		end
	end

	if slot.metadata.weight then
		weight += ignoreCount and slot.metadata.weight or (slot.metadata.weight * (slot.count or 1))
	end

	return weight
end

---@param items table
function Inventory.CalculateWeight(items)
	local weight = 0
	for _, v in pairs(items) do
		local item = Items(v.name)
		if item then
			weight = weight + Inventory.SlotWeight(item, v)
		end
	end
	return weight
end

-- This should be handled by frameworks, but sometimes isn't or is exploitable in some way.
local activeIdentifiers = {}

local function hasActiveInventory(playerId, owner)
	local activePlayer = activeIdentifiers[owner]

	if activePlayer then
        if activePlayer == playerId then
            error('attempted to load active player\'s inventory a secondary time', 0)
        end

		local inventory = Inventory(activePlayer)

		if inventory then
			local endpoint = GetPlayerEndpoint(activePlayer)

			if endpoint then
				DropPlayer(playerId, ("Character identifier '%s' is already active."):format(owner))

                -- Supposedly still getting stuck? Print info and hope somebody reports back (lol)
				print(('kicked player.%s (charid is already in use)'):format(playerId), json.encode({
					oldId = activePlayer,
					newId = playerId,
					charid = owner,
					endpoint = endpoint,
					playerName = GetPlayerName(activePlayer),
					fivem = GetPlayerIdentifierByType(activePlayer, 'fivem'),
					license = GetPlayerIdentifierByType(activePlayer, 'license2') or GetPlayerIdentifierByType(activePlayer, 'license'),
				}, {
					indent = true,
                    sort_keys = true
				}))

				return true
			end

			Inventory.CloseAll(inventory)
			db.savePlayer(owner, json.encode(inventory:minimal()))
			Inventory.Remove(inventory)
			Wait(100)
		end
	end

	activeIdentifiers[owner] = playerId
end

---Manually clear an inventory state tied to the given identifier.
---Temporary workaround until somebody actually gives me info.
RegisterCommand('clearActiveIdentifier', function(source, args)
    ---Server console only.
    if source ~= 0 then return end

	local activePlayer = activeIdentifiers[args[1]] or activeIdentifiers[tonumber(args[1])]
    local inventory = activePlayer and Inventory(activePlayer)

    if not inventory then return end

    local endpoint = GetPlayerEndpoint(activePlayer)

    if endpoint then
        DropPlayer(activePlayer, 'Kicked')

        -- Supposedly still getting stuck? Print info and hope somebody reports back (lol)
        print(('kicked player.%s (clearActiveIdentifier)'):format(activePlayer), json.encode({
            oldId = activePlayer,
            charid = inventory.owner,
            endpoint = endpoint,
            playerName = GetPlayerName(activePlayer),
            fivem = GetPlayerIdentifierByType(activePlayer, 'fivem'),
            license = GetPlayerIdentifierByType(activePlayer, 'license2') or GetPlayerIdentifierByType(activePlayer, 'license'),
        }, {
            indent = true,
            sort_keys = true
        }))
    end

    Inventory.CloseAll(inventory)
    db.savePlayer(inventory.owner, json.encode(inventory:minimal()))
    Inventory.Remove(inventory)
end, true)

---@param id string|number
---@param label string|nil
---@param invType string
---@param slots number
---@param weight number
---@param maxWeight number
---@param owner string | number | boolean
---@param items? table
---@param dbId? string | number
---@param gridRows? number grid rows for this inventory alone, overriding `containerRows`
---@return OxInventory?
--- This should only be utilised internally!
--- To create a stash, please use `exports.ox_inventory:RegisterStash` instead.
function Inventory.Create(id, label, invType, slots, weight, maxWeight, owner, items, groups, dbId, gridRows)
	if invType == 'player' and hasActiveInventory(id, owner) then return end

	if invType == 'player' then
		slots = (slots or 0) + Grid.getReservedCount()
	elseif invType ~= 'shop' and invType ~= 'crafting' then
		slots = Grid.scaleContainerSlots(slots, gridRows)
	end

	local self = {
		id = id,
		label = label or id,
		type = invType,
		slots = slots,
		weight = weight,
		maxWeight = maxWeight or shared.playerweight,
		owner = owner,
		items = type(items) == 'table' and items,
		open = false,
		set = Inventory.Set,
		get = Inventory.Get,
		minimal = minimal,
		time = os.time(),
		groups = groups,
		openedBy = {},
        dbId = dbId
	}

	if invType == 'drop' or invType == 'temp' or invType == 'dumpster' then
		self.datastore = true
	else
		self.changed = false

		if invType ~= 'glovebox' and invType ~= 'trunk' then
			self.dbId = id

			if invType ~= 'player' and owner and type(owner) ~= 'boolean' then
				self.id = ('%s:%s'):format(self.id, owner)
			end
		end
	end

	if not items then
		self.items, self.weight = Inventory.Load(self.dbId, invType, owner)

		if invType ~= 'player' and Inventories[self.id] then return Inventories[self.id] end
	elseif weight == 0 and next(items) then
		self.weight = Inventory.CalculateWeight(items)
	end

	Inventories[self.id] = setmetatable(self, OxInventory)

	if invType == 'player' then
		reclaimStrandedSlots(Inventories[self.id])
		Inventory.RefreshWorn(Inventories[self.id])

		-- The worn bag has to be resolved before the inventory is handed out; it is the only
		-- source of truth for the `backpack` swap endpoint. No-op unless clothing is enabled.
		Inventory.RefreshBackpack(Inventories[self.id])
		Inventory.RefreshBelt(Inventories[self.id])
	end

	return Inventories[self.id]
end

---@param inv inventory
function Inventory.Remove(inv)
	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv then return end

    if inv.type == 'drop' then
        TriggerClientEvent('ox_inventory:removeDrop', -1, inv.id)
        Inventory.Drops[inv.id] = nil
    elseif inv.player then
        activeIdentifiers[inv.owner] = nil
    end

    for playerId in pairs(inv.openedBy) do
        if inv.id ~= playerId then
            local target = Inventories[playerId]

            if target then
                target:closeInventory()
            end
        end
    end

    if not inv.datastore and inv.changed then
        Inventory.Save(inv)
    end

    Inventories[inv.id] = nil
end

exports('RemoveInventory', Inventory.Remove)

---Update the internal reference to vehicle stashes. Does not trigger a save or update the database.
---@param oldPlate string
---@param newPlate string
function Inventory.UpdateVehicle(oldPlate, newPlate)
	oldPlate = oldPlate:upper()
	newPlate = newPlate:upper()

	if server.trimplate then
		oldPlate = string.strtrim(oldPlate)
		newPlate = string.strtrim(newPlate)
	end

	local trunk = Inventory(('trunk%s'):format(oldPlate))
	local glove = Inventory(('glove%s'):format(oldPlate))

	if trunk then
		Inventory.CloseAll(trunk)

		Inventories[trunk.id] = nil
		trunk.label = newPlate
		trunk.dbId = type(trunk.id) == 'number' and trunk.dbId or newPlate
		trunk.id = ('trunk%s'):format(newPlate)
		Inventories[trunk.id] = trunk
	end

	if glove then
		Inventory.CloseAll(glove)

		Inventories[glove.id] = nil
		glove.label = newPlate
		glove.dbId = type(glove.id) == 'number' and glove.dbId or newPlate
		glove.id = ('glove%s'):format(newPlate)
		Inventories[glove.id] = glove
	end
end

exports('UpdateVehicle', Inventory.UpdateVehicle)

function Inventory.Save(inv)
	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv or inv.datastore then return end

    local buffer, n = {}, 0

    for k, v in pairs(inv.items) do
        if not Items.UpdateDurability(inv, v, Items(v.name), nil, os.time()) then
            n += 1
            buffer[n] = {
                name = v.name,
                count = v.count,
                slot = k,
                metadata = next(v.metadata) and v.metadata or nil
            }
        end
    end

    local data = next(buffer) and json.encode(buffer) or nil
    inv.changed = false

    saveFastSlots(inv)

    if inv.player then
        return shared.framework ~= 'esx' and db.savePlayer(inv.owner, data)
    elseif inv.type == 'trunk' then
        return db.saveTrunk(inv.dbId, data)
    elseif inv.type == 'glovebox' then
        return db.saveGlovebox(inv.dbId, data)
    end

    return db.saveStash(inv.owner, inv.dbId, data)
end

---@alias RandomLoot { [1]: string, [2]: number, [3]: number, [4]?: number }

---@param loot RandomLoot[]
---@param items RandomLoot[]
---@param size number
---@return RandomLoot
local function randomItem(loot, items, size)
    local itemIndex = math.random(1, size)
    local selectedItem = nil

    for _ = 1, size do
        selectedItem = loot[itemIndex]
        local found = false

        for i = 1, #items do
            if items[i][1] == selectedItem[1] then
                found = true
                break
            end
        end

        if not found then break end

        itemIndex = ((itemIndex - 1) % size) + 1
    end

    return selectedItem
end

---@param loot RandomLoot[]
---@return RandomLoot[]
local function randomLoot(loot)
    ---@type RandomLoot[]
    local items = {}
    local size = #loot
    local itemCount = math.random(0, 3)

    for _ = 1, itemCount do
        if #items >= size then break end

        local item = randomItem(loot, items, size)

        if item and math.random(1, 100) <= (item[4] or 80) then
            local count = math.random(item[2], item[3])

            if count > 0 then
                items[#items + 1] = { item[1], count }
            end
        end
    end

    return items
end

---@param inv inventory
---@param invType string
---@param items? table
---@return table returnData, number totalWeight
local function generateItems(inv, invType, items)
	if items == nil then
		if invType == 'dumpster' then
			items = randomLoot(server.dumpsterloot)
		elseif invType == 'vehicle' then
			items = randomLoot(server.vehicleloot)
		end
	end

	if not items then
		items = {}
	end

	local returnData, totalWeight = table.create(#items, 0), 0
	local layout = Grid.isGridLayout() and Grid.newLayout(type(inv) == 'table' and inv.slots or nil) or nil

	for i = 1, #items do
		local v = items[i]
		local item = Items(v[1])
		if not item then
			warn('unable to generate', v[1], 'item does not exist')
		else
			local metadata, count = Items.Metadata(inv, item, v[3] or {}, v[2])
			local weight = Inventory.SlotWeight(item, {count=count, metadata=metadata})
			local slot = i
			totalWeight = totalWeight + weight

			if layout then
				slot = Grid.claim(layout, Grid.getItemSize(item, metadata))
			end

			returnData[slot] = {name = item.name, label = item.label, weight = weight, slot = slot, count = count, description = item.description, metadata = metadata, stack = item.stack, close = item.close}
		end
	end

	return returnData, totalWeight
end

---@param id string|number
---@param invType string
---@param owner string | number | boolean
function Inventory.Load(id, invType, owner)
    if not invType then return end

	local result

    if invType == 'trunk' or invType == 'glovebox' then
        result = id and (invType == 'trunk' and db.loadTrunk(id) or db.loadGlovebox(id))

        if not result then
            if server.randomloot then
                return generateItems(id, 'vehicle')
            end
        else
            result = result[invType]
        end
	elseif invType == 'dumpster' then
		if server.randomloot then
			return generateItems(id, invType)
		end
	elseif id then
		result = db.loadStash(owner or '', id)
	end

	local returnData, weight = {}, 0

	if result and type(result) == 'string' then
		result = json.decode(result)
	end

	if result then
		local ostime = os.time()

		for _, v in pairs(result) do
			local item = Items(v.name)
			if item then
				v.metadata = Items.CheckMetadata(v.metadata or {}, item, v.name, ostime)
				local slotWeight = Inventory.SlotWeight(item, v)
				weight += slotWeight
				returnData[v.slot] = {name = item.name, label = item.label, weight = slotWeight, slot = v.slot, count = v.count, description = item.description, metadata = v.metadata, stack = item.stack, close = item.close}
			end
		end
	end

	return returnData, weight
end

local function assertMetadata(metadata)
	if metadata and type(metadata) ~= 'table' then
		metadata = metadata and { type = metadata or nil }
	end

	return metadata
end

---@param inv inventory
---@param item table | string
---@param metadata? any
---@param returnsCount? boolean
---@return table | number | nil
function Inventory.GetItem(inv, item, metadata, returnsCount)
	if type(item) ~= 'table' then item = Items(item) end

	if item then
		item = returnsCount and item or table.clone(item)
		inv = Inventory(inv) --[[@as OxInventory]]
		local count = 0

		if inv then
			local ostime = os.time()
			metadata = assertMetadata(metadata)

			for _, v in pairs(inv.items) do
				if v.name == item.name and (not metadata or table.contains(v.metadata, metadata)) and not Items.UpdateDurability(inv, v, item, nil, ostime) then
                    count += v.count
				end
			end
		end

		if returnsCount then return count else
			item.count = count
			return item
		end
	end
end
exports('GetItem', Inventory.GetItem)

---@param fromInventory any
---@param toInventory any
---@param slot1 number
---@param slot2 number
function Inventory.SwapSlots(fromInventory, toInventory, slot1, slot2)
	local fromSlot = fromInventory.items[slot1] and table.clone(fromInventory.items[slot1]) or nil
	local toSlot = toInventory.items[slot2] and table.clone(toInventory.items[slot2]) or nil

	if fromSlot then fromSlot.slot = slot2 end
	if toSlot then toSlot.slot = slot1 end

	fromInventory.items[slot1], toInventory.items[slot2] = toSlot, fromSlot
	fromInventory.changed, toInventory.changed = true, true

	return fromSlot, toSlot
end
exports('SwapSlots', Inventory.SwapSlots)

function Inventory.ContainerWeight(container, metaWeight, playerInventory)
	playerInventory.weight -= container.weight
	container.weight = Items(container.name).weight
	container.weight += metaWeight
	container.metadata.weight = metaWeight
	playerInventory.weight += container.weight
end

local BACKPACK_CLOTHING_SLOT = 'backpack'
local backpackSlotId
local backpackSlotResolved = false

---@return number?
function Inventory.GetBackpackSlot()
	if backpackSlotResolved then return backpackSlotId end

	local equipStart = Grid.getEquipStart()
	local equipSlots = equipStart and Grid.getEquipSlots()

	if equipSlots then
		for i = 1, #equipSlots do
			if equipSlots[i].name == BACKPACK_CLOTHING_SLOT then
				-- `Grid.getEquipStart()` is the first equipment slot, so the i-th one is at
				-- `start + i - 1`. The index is never spelled out from `shared.playerslots` here.
				backpackSlotId = equipStart + i - 1
				break
			end
		end
	end

	backpackSlotResolved = true

	return backpackSlotId
end

---@param inv OxInventory?
---@return boolean changed whether `inv.backpack` now names something else
function Inventory.RefreshBackpack(inv)
	-- `inv.player` is only attached after `Inventory.Create` returns, so the type is the test.
	if not inv or inv.type ~= 'player' then return false end

	local previous = inv.backpack
	local slotId = Inventory.GetBackpackSlot()
	local slotData = slotId and inv.items[slotId]
	local metadata = slotData and slotData.metadata

	inv.backpack = (
		slotData
		and Items.containers[slotData.name]
		and type(metadata) == 'table'
		and type(metadata.container) == 'string'
		and type(metadata.size) == 'table'
	) and metadata.container or nil

	return inv.backpack ~= previous
end

local BELT_CLOTHING_SLOT = 'belt'
local beltSlotId
local beltSlotResolved = false

local beltCapacity = {
	police_duty_belt = 8000,
	police_duty_belt_heavy = 14000,
}

---@return number?
function Inventory.GetBeltSlot()
	if beltSlotResolved then return beltSlotId end

	local equipStart = Grid.getEquipStart()
	local equipSlots = equipStart and Grid.getEquipSlots()

	if equipSlots then
		for i = 1, #equipSlots do
			if equipSlots[i].name == BELT_CLOTHING_SLOT then
				beltSlotId = equipStart + i - 1
				break
			end
		end
	end

	beltSlotResolved = true

	return beltSlotId
end

---@param inv OxInventory?
---@return boolean changed
function Inventory.RefreshBelt(inv)
	if not inv or inv.type ~= 'player' then return false end

	local slotId = Inventory.GetBeltSlot()
	local slotData = slotId and inv.items[slotId]
	local bonus = slotData and beltCapacity[slotData.name] or 0
	local applied = inv.beltWeightBonus or 0

	if applied == bonus then return false end

	inv.beltWeightBonus = bonus

	Inventory.SetMaxWeight(inv, inv.maxWeight - applied + bonus)

	return true
end

---@param a table
---@param b table
---@return boolean
local function sameWorn(a, b)
	for name, item in pairs(a) do
		if b[name] ~= item then return false end
	end

	for name in pairs(b) do
		if a[name] == nil then return false end
	end

	return true
end

---@param inv OxInventory?
---@return table worn map of clothing slot name to the item name occupying it
function Inventory.GetWorn(inv)
	inv = Inventory(inv) --[[@as OxInventory]]

	local worn = {}

	if type(inv) ~= 'table' or inv.type ~= 'player' then return worn end

	local slots = Grid.getEquipSlots()
	local start = Grid.getEquipStart()

	if not slots or not start then return worn end

	for i = 1, #slots do
		local def = slots[i]

		if def.wearable then
			local item = inv.items[start + i - 1]

			if item then worn[def.name] = item.name end
		end
	end

	return worn
end

exports('GetWorn', Inventory.GetWorn)

---@param inv OxInventory?
---@param slot any
function Inventory.RefreshEquipment(inv, slot)
	if slot == Inventory.GetBackpackSlot() then refreshBackpackDeferred(inv) end
	if slot == Inventory.GetBeltSlot() then Inventory.RefreshBelt(inv) end

	Inventory.RefreshWorn(inv, slot)
end

---@param inv OxInventory?
---@param slot any? when given, does nothing unless it is a wearable equipment slot
---@return boolean changed
function Inventory.RefreshWorn(inv, slot)
	if type(inv) ~= 'table' or inv.type ~= 'player' then return false end

	if slot ~= nil then
		local def = Grid.getEquipSlotDef(inv, slot)

		if not def or not def.wearable then return false end
	end

	local worn = Inventory.GetWorn(inv)

	if inv.worn and sameWorn(inv.worn, worn) then return false end

	inv.worn = worn

	TriggerClientEvent('ox_inventory:setWorn', inv.id, worn)

	return true
end

---@param inv OxInventory?
---@return OxInventory?
function Inventory.GetBackpack(inv)
	if not inv then return end

	Inventory.RefreshBackpack(inv)

	if not inv.backpack then return end

	local backpack = Inventory(inv.backpack)

	if backpack then return backpack end

	return Inventory.GetContainerFromSlot(inv, Inventory.GetBackpackSlot()) or nil
end

---The worn bag serialised for the NUI, or nil when none is worn. Same shape as
---`leftInventory`/`rightInventory`; `type` is the literal selector the client sends back.
---@param inv OxInventory?
---@return table?
function Inventory.GetBackpackPayload(inv)
	local backpack = Inventory.GetBackpack(inv)

	if not backpack then return end

	return {
		id = backpack.id,
		label = backpack.label,
		type = BACKPACK_CLOTHING_SLOT,
		slots = backpack.slots,
		weight = backpack.weight,
		maxWeight = backpack.maxWeight,
		items = backpack.items,
	}
end

---Push the worn bag to its owner. Sending nothing is meaningful: the UI drops the third panel
---when the field is absent.
---@param inv OxInventory?
function Inventory.SyncBackpack(inv)
	if not inv or inv.type ~= 'player' then return end

	TriggerClientEvent('ox_inventory:setBackpack', inv.id, Inventory.GetBackpackPayload(inv))
end

---@param inv OxInventory?
---@return OxInventory?
function Inventory.GetOpenContainer(inv)
	if not inv or inv.type ~= 'player' or not inv.containerSlot then return end

	return Inventory.GetContainerFromSlot(inv, inv.containerSlot)
end

---@param inv OxInventory?
---@return table?
function Inventory.GetContainerPayload(inv)
	local container = Inventory.GetOpenContainer(inv)

	if not container then return end

	return {
		id = container.id,
		label = container.label,
		type = 'container',
		slots = container.slots,
		weight = container.weight,
		maxWeight = container.maxWeight,
		items = container.items,
	}
end

---@param inv inventory
---@param item table | string
---@param count number
---@param metadata? table
---@return boolean? success, string|SlotWithItem|nil response
function Inventory.SetItem(inv, item, count, metadata)
	if type(item) ~= 'table' then item = Items(item) end

	if not item then return false, 'invalid_item' end
	if type(count) ~= 'number' then return false, 'invalid_count' end

	count = math.floor(count + 0.5)
	if count < 0 then return false, 'negative_count' end

	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv then return false, 'invalid_inventory' end

	inv.changed = true
	local itemCount = Inventory.GetItem(inv, item.name, metadata, true) --[[@as number]]

	if count > itemCount then
		count -= itemCount
		return Inventory.AddItem(inv, item.name, count, metadata)
	elseif count < itemCount then
		itemCount -= count
		return Inventory.RemoveItem(inv, item.name, itemCount, metadata)
	end
end
exports('SetItem', Inventory.SetItem)

---@param inv inventory
function Inventory.GetCurrentWeapon(inv)
	inv = Inventory(inv) --[[@as OxInventory]]

	if inv?.player then
		local weapon = inv.items[inv.weapon]

		if weapon and Items(weapon.name).weapon then
			return weapon
		end

		inv.weapon = nil
	end
end
exports('GetCurrentWeapon', Inventory.GetCurrentWeapon)

---@param inv inventory
---@param slotId number
---@return table? item
function Inventory.GetSlot(inv, slotId)
	if not inv or type(slotId) ~= 'number' then return end

	inv = Inventory(inv) --[[@as OxInventory]]
	local slot = inv and inv.items?[slotId]

	if slot and not Items.UpdateDurability(inv, slot, Items(slot.name), nil, os.time()) then
        return slot
	end
end
exports('GetSlot', Inventory.GetSlot)

---@param inv inventory
---@param slotId number
---@param durability number
function Inventory.SetDurability(inv, slotId, durability)
	if not inv or type(slotId) ~= 'number' or type(durability) ~= 'number' then return end

	inv = Inventory(inv) --[[@as OxInventory]]
	local slot = inv and inv.items?[slotId]

	if not slot then return end

    Items.UpdateDurability(inv, slot, Items(slot.name), durability)

    if inv.player and server.syncInventory then
        server.syncInventory(inv)
    end
end
exports('SetDurability', Inventory.SetDurability)

local Utils = require 'modules.utils.server'

---@param inv inventory
---@param slotId number
---@param metadata { [string]: any }
function Inventory.SetMetadata(inv, slotId, metadata)
	if not inv or type(slotId) ~= 'number' then return end

	inv = Inventory(inv) --[[@as OxInventory]]
	local slot = inv and inv.items?[slotId]

	if not slot then return end

    local item = Items(slot.name)
    local imageurl = slot.metadata.imageurl
    slot.metadata = type(metadata) == 'table' and metadata or { type = metadata or nil }
    inv.changed = true

    if metadata.weight then
        inv.weight -= slot.weight
        slot.weight = Inventory.SlotWeight(item, slot)
        inv.weight += slot.weight
    end

    if metadata.durability ~= slot.metadata.durability then
        Items.UpdateDurability(inv, slot, item, metadata.durability)
    else
        inv:syncSlotsWithClients({
            {
                item = slot,
                inventory = inv.id
            }
        }, true)
    end

    if inv.player and server.syncInventory then
        server.syncInventory(inv)
    end

    if metadata.imageurl ~= imageurl and Utils.IsValidImageUrl then
        if Utils.IsValidImageUrl(metadata.imageurl) then
            Utils.DiscordEmbed('Valid image URL', ('Updated item "%s" (%s) with valid url in "%s".\n%s\nid: %s\nowner: %s'):format(metadata.label or slot.label, slot.name, inv.label, metadata.imageurl, inv.id, inv.owner, metadata.imageurl), metadata.imageurl, 65280)
        else
            Utils.DiscordEmbed('Invalid image URL', ('Updated item "%s" (%s) with invalid url in "%s".\n%s\nid: %s\nowner: %s'):format(metadata.label or slot.label, slot.name, inv.label, metadata.imageurl, inv.id, inv.owner, metadata.imageurl), metadata.imageurl, 16711680)
            metadata.imageurl = nil
        end
    end
end

exports('SetMetadata', Inventory.SetMetadata)

---@param inv inventory
---@param slots number
function Inventory.SetSlotCount(inv, slots)
	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv then return end
	if type(slots) ~= 'number' then return end

	inv.changed = true
	inv.slots = slots

	if inv.player then
        TriggerClientEvent('ox_inventory:refreshSlotCount', inv.id, {inventoryId = inv.id, slots = inv.slots})
    end

    for playerId in pairs(inv.openedBy) do
        if playerId ~= inv.id then
            TriggerClientEvent('ox_inventory:refreshSlotCount', playerId, {inventoryId = inv.id, slots = inv.slots})
        end
	end
end

exports('SetSlotCount', Inventory.SetSlotCount)

---@param inv inventory
---@param maxWeight number
function Inventory.SetMaxWeight(inv, maxWeight)
	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv then return end
	if type(maxWeight) ~= 'number' then return end

	inv.maxWeight = maxWeight

    if inv.player then
        TriggerClientEvent('ox_inventory:refreshMaxWeight', inv.id, {inventoryId = inv.id, maxWeight = inv.maxWeight})
    end

    for playerId in pairs(inv.openedBy) do
        if playerId ~= inv.id then
            TriggerClientEvent('ox_inventory:refreshMaxWeight', playerId, {inventoryId = inv.id, maxWeight = inv.maxWeight})
        end
	end
end

exports('SetMaxWeight', Inventory.SetMaxWeight)

---@param inv inventory
---@param item table | string
---@param count number
---@param metadata? table | string
---@param slot? number
---@param cb? fun(success?: boolean, response: string|SlotWithItem|nil)
---@return boolean? success, string|SlotWithItem|nil response
function Inventory.AddItem(inv, item, count, metadata, slot, cb)
	if type(item) ~= 'table' then item = Items(item) end

	if not item then return false, 'invalid_item' end
	if type(count) ~= 'number' then return false, 'invalid_count' end

	count = math.floor(count + 0.5)
	if count <= 0 then return false, 'negative_count' end

	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv?.slots then return false, 'invalid_inventory' end

	local toSlot, slotMetadata, slotCount
	local success, response = false

	metadata = assertMetadata(metadata)

	-- Equipment slots and grid geometry are never chosen automatically; an explicitly
	-- requested slot has to satisfy both before it is accepted.
	local baseSlots = Grid.getBaseSlots(inv)
	local gridLayout = Grid.isGridLayout()
	local width, height = Grid.getItemSize(item)

	if slot then
		local slotData = inv.items[slot]
		slotMetadata, slotCount = Items.Metadata(inv.id, item, metadata and table.clone(metadata) or {}, count)

		if Grid.isSlotId(slot, inv.slots) and (not slotData or (item.stack and slotData.name == item.name and table.matches(slotData.metadata, slotMetadata))) then
			if Grid.isEquipSlot(inv, slot) then
				if Grid.canEquip(inv, slot, item) then toSlot = slot end
			elseif slotData or not gridLayout or Grid.canPlace(inv, slot, width, height, slot) then
				toSlot = slot
			end
		end
	end

	if not toSlot then
		local items = inv.items
		slotMetadata, slotCount = Items.Metadata(inv.id, item, metadata and table.clone(metadata) or {}, count)

		local layout = gridLayout and Grid.getLayout(inv) or nil

		for i = 1, baseSlots do
			local slotData = items[i]
			local canPlace = slotData ~= nil or not layout or Grid.fits(layout, i, width, height)

			if item.stack and slotData ~= nil and slotData.name == item.name and table.matches(slotData.metadata, slotMetadata) then
				toSlot = i
				break
			elseif not item.stack and not slotData and canPlace then
				if not toSlot then toSlot = {} end

				toSlot[#toSlot + 1] = { slot = i, count = slotCount, metadata = slotMetadata }

				if layout then Grid.mark(layout, i, width, height) end

				if count == slotCount then
					break
				end

				count -= 1
				slotMetadata, slotCount = Items.Metadata(inv.id, item, metadata and table.clone(metadata) or {}, count)
			elseif not toSlot and not slotData and canPlace then
				toSlot = i
			end
		end
	end

	if not toSlot then return false, 'inventory_full' end

	inv.changed = true

	local invokingResource = server.loglevel > 1 and GetInvokingResource()
	local toSlotType = type(toSlot)

	if toSlotType == 'number' then
		Inventory.SetSlot(inv, item, slotCount, slotMetadata, toSlot)

		if inv.player and server.syncInventory then
			server.syncInventory(inv)
		end

		inv:syncSlotsWithClients({
			{
				item = inv.items[toSlot],
				inventory = inv.id
			}
		}, true)

		if invokingResource then
			lib.logger(inv.owner, 'addItem', ('"%s" added %sx %s to "%s"'):format(invokingResource, count, item.name, inv.label))
		end

		success = true
		response = inv.items[toSlot]
	elseif toSlotType == 'table' then
		local added = 0

		for i = 1, #toSlot do
			local data = toSlot[i]
			added += data.count
			Inventory.SetSlot(inv, item, data.count, data.metadata, data.slot)
			toSlot[i] = { item = inv.items[data.slot], inventory = inv.id }
		end

		if inv.player and server.syncInventory then
			server.syncInventory(inv)
		end

		inv:syncSlotsWithClients(toSlot, true)

		if invokingResource then
			lib.logger(inv.owner, 'addItem', ('"%s" added %sx %s to "%s"'):format(invokingResource, added, item.name, inv.label))
		end

		for i = 1, #toSlot do
			toSlot[i] = toSlot[i].item
		end

		success = true
		response = toSlot
	end

	if cb then
		return cb(success, response)
	end

	return success, response
end

exports('AddItem', Inventory.AddItem)

---@param inv inventory
---@param search string|number slots|1, count|2
---@param items table | string
---@param metadata? table | string
function Inventory.Search(inv, search, items, metadata)
	if items then
		inv = Inventory(inv) --[[@as OxInventory]]

		if inv then
			inv = inv.items

			if search == 'slots' then search = 1 elseif search == 'count' then search = 2 end
			if type(items) == 'string' then items = {items} end

			metadata = assertMetadata(metadata)
			local itemCount = #items
			local returnData = {}

			for i = 1, itemCount do
				local item = string.lower(items[i])
				if item:sub(0, 7) == 'weapon_' then item = string.upper(item) end

				if search == 1 then
					returnData[item] = {}
				elseif search == 2 then
					returnData[item] = 0
				end

				for _, v in pairs(inv) do
					if v.name == item then
						if not v.metadata then v.metadata = {} end

						if not metadata or table.contains(v.metadata, metadata) then
							if search == 1 then
								returnData[item][#returnData[item]+1] = inv[v.slot]
							elseif search == 2 then
								returnData[item] += v.count
							end
						end
					end
				end
			end

			if next(returnData) then return itemCount == 1 and returnData[items[1]] or returnData end
		end
	end

	return false
end
exports('Search', Inventory.Search)

---@param inv inventory
---@param item table | string
---@param metadata? table
---@param strict? boolean
function Inventory.GetItemSlots(inv, item, metadata, strict)
	if type(item) ~= 'table' then item = Items(item) end
	if not item then return end

	inv = Inventory(inv) --[[@as OxInventory]]
	if not inv?.slots then return end

	-- Equipment slots are not available for storage, so they never count as free space.
	local baseSlots = Grid.getBaseSlots(inv)
	local totalCount, slots, emptySlots = 0, {}, baseSlots

	if strict == nil then strict = true end
	local tablematch = strict and table.matches or table.contains

	for k, v in pairs(inv.items) do
		if k <= baseSlots then emptySlots -= 1 end

		if v.name == item.name then
			if metadata and v.metadata == nil then
				v.metadata = {}
			end
			if not metadata or tablematch(v.metadata, metadata) then
				totalCount = totalCount + v.count
				slots[k] = v.count
			end
		end
	end

	if Grid.isGridLayout() then
		-- Free cells mean nothing on their own; what matters is how many copies of this
		-- item's footprint could still be laid down.
		emptySlots = Grid.countPlacements(inv, Grid.getItemSize(item))
	end

	return slots, totalCount, emptySlots
end
exports('GetItemSlots', Inventory.GetItemSlots)

---@param inv inventory
---@param item table | string
---@param count integer
---@param metadata? table | string
---@param slot? number
---@param ignoreTotal? boolean
---@param strict? boolean
---@return boolean? success, string? response
function Inventory.RemoveItem(inv, item, count, metadata, slot, ignoreTotal, strict)
	if type(item) ~= 'table' then item = Items(item) end

	if not item then return false, 'invalid_item' end
	if type(count) ~= 'number' then return false, 'invalid_count' end

	count = math.floor(count + 0.5)
	if count <= 0 then return false, 'negative_count' end

	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv?.slots then return false, 'invalid_inventory' end

	metadata = assertMetadata(metadata)
	if strict == nil then strict = true end
	local itemSlots, totalCount = Inventory.GetItemSlots(inv, item, metadata, strict)

	if not itemSlots then return false end

	if totalCount and count > totalCount then
		if not ignoreTotal then return false, 'not_enough_items' end

		count = totalCount
	end

	local removed, total, slots = 0, count, {}

	if slot and itemSlots[slot] then
		removed = count
		Inventory.SetSlot(inv, item, -count, inv.items[slot].metadata, slot)
		slots[#slots+1] = inv.items[slot] or slot
	elseif itemSlots and totalCount > 0 then
		for k, v in pairs(itemSlots) do
			if removed < total then
				if v == count then
					TriggerClientEvent('ox_inventory:itemNotify', inv.id, { inv.items[k], 'ui_removed', v })

					removed = total
					inv.weight -= inv.items[k].weight
					inv.items[k] = nil
					moveFastSlot(inv, k, nil)
					slots[#slots+1] = inv.items[k] or k
				elseif v > count then
					Inventory.SetSlot(inv, item, -count, inv.items[k].metadata, k)
					slots[#slots+1] = inv.items[k] or k
					removed = total
					count = v - count
				else
					TriggerClientEvent('ox_inventory:itemNotify', inv.id, { inv.items[k], 'ui_removed', v })

					removed = removed + v
					count = count - v
					inv.weight -= inv.items[k].weight
					inv.items[k] = nil
					moveFastSlot(inv, k, nil)
					slots[#slots+1] = k
				end
			else break end
		end
	end

	if removed > 0 then
		inv.changed = true

		Inventory.RefreshWorn(inv)

		if inv.player and server.syncInventory then
			server.syncInventory(inv)
		end

		local array = table.create(#slots, 0)

		for k, v in pairs(slots) do
			array[k] = {item = type(v) == 'number' and { slot = v } or v, inventory = inv.id}
		end

		inv:syncSlotsWithClients(array, true)

		-- Any of the cleared slots could have been the equipment slot; the `inv.items[k] = nil`
		-- branches above bypass `Inventory.SetSlot` entirely. No-op with clothing disabled.
		refreshBackpackDeferred(inv)

		local invokingResource = server.loglevel > 1 and GetInvokingResource()

		if invokingResource then
			lib.logger(inv.owner, 'removeItem', ('"%s" removed %sx %s from "%s"'):format(invokingResource, removed, item.name, inv.label))
		end

		return true
	end

	return false, 'not_enough_items'
end
exports('RemoveItem', Inventory.RemoveItem)

---@param inv inventory
---@param item table | string
---@param count number
---@param metadata? table | string
function Inventory.CanCarryItem(inv, item, count, metadata)
	if type(item) ~= 'table' then item = Items(item) end

	if item then
		inv = Inventory(inv) --[[@as OxInventory]]

		if inv then
			local itemSlots, _, emptySlots = Inventory.GetItemSlots(inv, item, type(metadata) == 'table' and metadata or { type = metadata or nil })

			if not itemSlots then return end

			local weight = metadata and metadata.weight or item.weight

			if next(itemSlots) or emptySlots > 0 then
				if not count then count = 1 end
				if not item.stack and emptySlots < count then return false end
				if weight == 0 then return true end

				local newWeight = inv.weight + (weight * count)

				if newWeight > inv.maxWeight then
					return false
				end

				return true
			end
		end
	end
end
exports('CanCarryItem', Inventory.CanCarryItem)

---@param inv inventory
---@param item table | string
function Inventory.CanCarryAmount(inv, item)
    if type(item) ~= 'table' then item = Items(item) end
	inv = Inventory(inv) --[[@as OxInventory]]

    if inv and item then
		local availableWeight = inv.maxWeight - inv.weight
		return math.floor(availableWeight / item.weight)
    end
end

exports('CanCarryAmount', Inventory.CanCarryAmount)

---@param inv inventory
---@param weight number
function Inventory.CanCarryWeight(inv, weight)
	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv then return end

	local availableWeight = inv.maxWeight - inv.weight
	local canHold = availableWeight >= weight
	return canHold, availableWeight
end
exports('CanCarryWeight', Inventory.CanCarryWeight)

---@param inv inventory
---@param firstItem string
---@param firstItemCount number
---@param testItem string
---@param testItemCount number
function Inventory.CanSwapItem(inv, firstItem, firstItemCount, testItem, testItemCount)
	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv then return end

	local firstItemData = Inventory.GetItem(inv, firstItem)
	local testItemData = Inventory.GetItem(inv, testItem)

	if firstItemData and testItemData and firstItemData.count >= firstItemCount then
		local weightWithoutFirst = inv.weight - (firstItemData.weight * firstItemCount)
		local weightWithTest = weightWithoutFirst + (testItemData.weight * testItemCount)
		return weightWithTest <= inv.maxWeight
	end
end
exports('CanSwapItem', Inventory.CanSwapItem)

---Mostly for internal use, but deprecated.
---@param name string
---@param count number
---@param metadata { [string]: any }
---@param slot number
RegisterServerEvent('ox_inventory:removeItem', function(name, count, metadata, slot)
	Inventory.RemoveItem(source, name, count, metadata, slot)
end)

Inventory.Drops = {}

---@param prefix string?
---@return string
local function generateInvId(prefix)
	while true do
		local invId = ('%s-%s'):format(prefix or 'drop', math.random(100000, 999999))

		if not Inventories[invId] then return invId end

		Wait(0)
	end
end

local function CustomDrop(prefix, items, coords, slots, maxWeight, instance, model)
	local dropId = generateInvId()
	local inventory = Inventory.Create(dropId, ('%s %s'):format(prefix, dropId:gsub('%D', '')), 'drop', slots or shared.dropslots, 0, maxWeight or shared.dropweight, false, {})

	if not inventory then return end

	inventory.items, inventory.weight = generateItems(inventory, 'drop', items)
	inventory.coords = coords
	Inventory.Drops[dropId] = {
		coords = inventory.coords,
		instance = instance,
		model = model,
	}

	TriggerClientEvent('ox_inventory:createDrop', -1, dropId, Inventory.Drops[dropId])

    return dropId
end

AddEventHandler('ox_inventory:customDrop', CustomDrop)
exports('CustomDrop', CustomDrop)

exports('CreateDropFromPlayer', function(playerId)
	local playerInventory = Inventory(playerId)

	if not playerInventory or not next(playerInventory.items) then return end

	local dropId = generateInvId()
	local inventory = Inventory.Create(dropId, ('Drop %s'):format(dropId:gsub('%D', '')), 'drop', playerInventory.slots, playerInventory.weight, playerInventory.maxWeight, false, table.clone(playerInventory.items))

	if not inventory then return end

	local coords = GetEntityCoords(GetPlayerPed(playerId))
	inventory.coords = vec3(coords.x, coords.y, coords.z-0.2)
	Inventory.Drops[dropId] = {
		coords = inventory.coords,
		instance = Player(playerId).state.instance
	}

	Inventory.Clear(playerInventory)
	TriggerClientEvent('ox_inventory:createDrop', -1, dropId, Inventory.Drops[dropId])

	return dropId
end)

local TriggerEventHooks = require 'modules.hooks.server'

---@class SwapSlotData
---@field count number
---@field fromSlot number
---@field toSlot number
---@field instance any
---@field fromType string
---@field toType string
---@field coords? vector3
---@field rotated? boolean grid layout only, and only honoured for non-stackable items

---@param inventory OxInventory
---@param playerInventory OxInventory
---@return string|number
local function syncAddress(inventory, playerInventory)
	-- A bag can also be opened the old way, as the secondary inventory. It is then drawn by the
	-- right panel and the third panel is suppressed, so its id is the correct address after all.
	if playerInventory.backpack and inventory.id == playerInventory.backpack
		and inventory.id ~= playerInventory.open then
		return 'backpack'
	end

	return inventory.id
end

---@param source number
---@param playerInventory OxInventory
---@param fromInventory OxInventory the endpoint the item actually leaves, not necessarily the player
---@param fromData SlotWithItem?
---@param data SwapSlotData
local function dropItem(source, playerInventory, fromInventory, fromData, data)
    if not fromData then return end

	do
		local emptyDrop = { type = 'drop', slots = shared.dropslots, items = {} }
		local toSlot = Grid.isSlotId(data.toSlot, shared.dropslots) and data.toSlot or nil

		if toSlot and Grid.isGridLayout() then
			local width, height = Grid.getItemSize(Items(fromData.name), fromData.metadata)

			if not Grid.canPlace(emptyDrop, toSlot, width, height) then
				toSlot = Grid.findSlot(emptyDrop, width, height)
			end
		end

		if not toSlot then return false end

		data.toSlot = toSlot
	end

	local toData = table.clone(fromData)
	toData.slot = data.toSlot
	toData.count = data.count
	toData.weight = Inventory.SlotWeight(Items(toData.name), toData)

    if toData.weight > shared.dropweight then return end

    local dropId = generateInvId('drop')

	local ownSource = fromInventory == playerInventory

	if not TriggerEventHooks('swapItems', {
		source = source,
		fromInventory = fromInventory.id,
		fromSlot = fromData,
		fromType = fromInventory.type,
		toInventory = 'newdrop',
		toSlot = data.toSlot,
		toType = 'drop',
		count = data.count,
        action = 'move',
        dropId = dropId,
	}) then return end

    fromData.count -= data.count
    fromData.weight = Inventory.SlotWeight(Items(fromData.name), fromData)

    if fromData.count < 1 then
        fromData = nil
    else
        toData.metadata = table.clone(toData.metadata)
    end

	local slot = data.fromSlot
	fromInventory.weight -= toData.weight
	fromInventory.items[slot] = fromData

	if not fromData then moveFastSlot(fromInventory, slot, nil) end

	Inventory.RefreshWorn(fromInventory, slot)

	if ownSource and slot == playerInventory.weapon then
		playerInventory.weapon = nil
	end

	local inventory = Inventory.Create(dropId, ('Drop %s'):format(dropId:gsub('%D', '')), 'drop', shared.dropslots, toData.weight, shared.dropweight, false, {[data.toSlot] = toData})

	if not inventory then return end

	inventory.coords = data.coords
	Inventory.Drops[dropId] = {coords = inventory.coords, instance = data.instance}
	fromInventory.changed = true

	---@type updateSlot[]
	local items = {
		{
			item = fromData or { slot = slot },
			inventory = syncAddress(fromInventory, playerInventory)
		}
	}

	if not ownSource then
		local backpackItem = fromInventory.id == playerInventory.backpack
			and playerInventory.items[Inventory.GetBackpackSlot()] or nil

		if backpackItem then
			Inventory.ContainerWeight(backpackItem, fromInventory.weight, playerInventory)
			playerInventory.changed = true

			items[#items + 1] = {
				item = backpackItem,
				inventory = playerInventory.id
			}
		end
	end

	-- `slot` is only meaningful to the client as a player slot (it disarms a dropped weapon), so
	-- an index that belongs to some other inventory must not be sent.
	TriggerClientEvent('ox_inventory:createDrop', -1, dropId, Inventory.Drops[dropId], playerInventory.open and source, ownSource and slot or nil)

	if server.loglevel > 0 then
		lib.logger(playerInventory.owner, 'swapSlots', ('%sx %s transferred from "%s" to "%s"'):format(data.count, toData.name, fromInventory.label, dropId))
	end

	if server.syncInventory then server.syncInventory(playerInventory) end

	return true, {
		weight = playerInventory.weight,
		items = items
	}
end

local activeSlots = {}

---@param fromInventory OxInventory
---@param toInventory OxInventory
---@param fromData SlotWithItem
---@param toData SlotWithItem?
---@param data SwapSlotData
---@param width number footprint of the moved item, rotation already applied
---@param height number
---@return boolean
local function canSwapSlots(fromInventory, toInventory, fromData, toData, data, width, height)
	local toEquip = Grid.isEquipSlot(toInventory, data.toSlot)
	local fromEquip = Grid.isEquipSlot(fromInventory, data.fromSlot)

	if toEquip and not Grid.canEquip(toInventory, data.toSlot, Items(fromData.name)) then return false end
	if fromEquip and toData and not Grid.canEquip(fromInventory, data.fromSlot, Items(toData.name)) then return false end

	if not Grid.isGridLayout() then return true end

	local toReserved = toEquip
	local fromReserved = fromEquip

	local sameInventory = fromInventory.id == toInventory.id

	local vacatesSource = toData ~= nil or data.count >= fromData.count

	if not toReserved then
		local ignore = { [data.toSlot] = true }

		if sameInventory and vacatesSource then ignore[data.fromSlot] = true end

		if not Grid.canPlace(toInventory, data.toSlot, width, height, ignore) then return false end
	end

	if toData and not fromReserved then
		-- A displaced item lands in the slot being vacated, so its footprint has to fit there.
		local toWidth, toHeight = Grid.getItemSize(Items(toData.name), toData.metadata)
		local ignore = { [data.fromSlot] = true }

		if sameInventory then
			ignore[data.toSlot] = true

			local layout = Grid.getLayout(fromInventory, ignore)

			if not toReserved then Grid.mark(layout, data.toSlot, width, height) end

			-- `Grid.fits` repeats the bounds guard `Grid.canPlace` would have applied:
			-- `layout.slots` is `Grid.getBaseSlots(fromInventory)` by construction.
			if not Grid.fits(layout, data.fromSlot, toWidth, toHeight) then return false end
		elseif not Grid.canPlace(fromInventory, data.fromSlot, toWidth, toHeight, ignore) then
			return false
		end
	end

	return true
end

---@param playerInventory OxInventory
---@param invType string
---@return OxInventory?
local function resolveSwapEndpoint(playerInventory, invType)
	if invType == 'player' then return playerInventory end
	if invType == 'backpack' then return Inventory.GetBackpack(playerInventory) end

	if invType == 'container' and playerInventory.containerSlot then
		return Inventory.GetOpenContainer(playerInventory)
	end

	return Inventory(playerInventory.open)
end

---@param source number
---@param data SwapSlotData
lib.callback.register('ox_inventory:swapItems', function(source, data)
	if data.count < 1 then return end

	local playerInventory = Inventory(source)

	if not playerInventory then return end

	local toInventory = resolveSwapEndpoint(playerInventory, data.toType)
	local fromInventory = resolveSwapEndpoint(playerInventory, data.fromType)

	if not fromInventory or not toInventory then
		if data.fromType == 'backpack' or data.toType == 'backpack' then return false end

		playerInventory:closeInventory()
		return
	end

    if data.toType == 'inspect' or data.fromType == 'inspect' then return end

	-- Neither slot id was ever checked against the owning inventory's slot count. Malformed
	-- ids are rejected outright; the client rolls back on a falsy response.
	if not Grid.isSlotId(data.fromSlot, fromInventory.slots) then return false end
	if not Grid.isSlotId(data.toSlot, data.toType == 'newdrop' and shared.dropslots or toInventory.slots) then return false end

	local fromRef = ('%s:%s'):format(fromInventory.id, data.fromSlot)
	local toRef = ('%s:%s'):format(toInventory.id, data.toSlot)

	local fromAddress = syncAddress(fromInventory, playerInventory)
	local toAddress = syncAddress(toInventory, playerInventory)

	if activeSlots[fromRef] or activeSlots[toRef] then
		return false, {
			{
				item = toInventory.items[data.toSlot] or { slot = data.toSlot },
				inventory = toAddress
			},
			{
				item = fromInventory.items[data.fromSlot] or { slot = data.fromSlot },
				inventory = fromAddress
			}
		}
	end

	local sameInventory = fromInventory.id == toInventory.id
	local fromOtherPlayer = fromInventory.player and fromInventory ~= playerInventory
	local toOtherPlayer = toInventory.player and toInventory ~= playerInventory
	local toData = toInventory.items[data.toSlot]

	if not sameInventory and (fromInventory.type == 'policeevidence' or (toInventory.type == 'policeevidence' and toData)) then
		local group, rank = server.hasGroup(playerInventory, shared.police)

		if not group or server.evidencegrade > rank then
			return false, 'evidence_cannot_take'
		end
	end

	activeSlots[fromRef] = true
	activeSlots[toRef] = true

	local _ <close> = defer(function()
		activeSlots[fromRef] = nil
		activeSlots[toRef] = nil
	end)

	if toInventory and (data.toType == 'newdrop' or fromInventory ~= toInventory or data.fromSlot ~= data.toSlot) then
		local fromData = fromInventory.items[data.fromSlot]

		if not fromData then
			return false, {
				{
					item = { slot = data.fromSlot },
					inventory = fromAddress
				},
				{
					item = toData or { slot = data.toSlot },
					inventory = toAddress
				}
			}
		end

        if data.count > fromData.count then
            data.count = fromData.count
        end

        if data.toType == 'newdrop' then
            local dropped, response = dropItem(source, playerInventory, fromInventory, fromData, data)

            if dropped and fromInventory == playerInventory and data.fromSlot == Inventory.GetBackpackSlot()
                and Inventory.RefreshBackpack(playerInventory) then
                Inventory.SyncBackpack(playerInventory)
            end

            return dropped, response
        end

		local fromItem = Items(fromData.name)

		-- Rotation is only ever honoured for non-stackable items: a rotated and an unrotated
		-- instance of a stackable item would compare unequal and refuse to merge.
		local applyRotation = data.rotated ~= nil and Grid.allowRotate() and fromItem ~= nil and not fromItem.stack
		local rotated = applyRotation and data.rotated == true

		local width, height = Grid.getItemSize(fromItem, applyRotation and { rotated = rotated } or fromData.metadata)

		if not canSwapSlots(fromInventory, toInventory, fromData, toData, data, width, height) then
			return false, {
				{
					item = fromData,
					inventory = fromAddress
				},
				{
					item = toData or { slot = data.toSlot },
					inventory = toAddress
				}
			}
		end


		if fromData then
            if fromData.metadata.container and toInventory.type == 'container' then return false end
            if toData and toData.metadata.container and fromInventory.type == 'container' then return false end

			if fromData.metadata.container and fromData.metadata.container == toInventory.id then return false end
			if toData and toData.metadata.container and toData.metadata.container == fromInventory.id then return false end

			local container, containerItem

			if not sameInventory and playerInventory.containerSlot then
				container = (fromInventory.id == playerInventory.open and fromInventory)
					or (toInventory.id == playerInventory.open and toInventory)
					or nil

				if container then
					containerItem = playerInventory.items[playerInventory.containerSlot]
				end
			end

			---Is the opened container the destination? Was `toInventory.type == 'container'`, which
			---is now also true for the worn bag and would point the rollup at the wrong endpoint.
			local containerIsTarget = container ~= nil and container == toInventory

			local backpackId = playerInventory.backpack
			local backpackItem

			if backpackId and not sameInventory and (fromInventory.id == backpackId or toInventory.id == backpackId) then
				backpackItem = playerInventory.items[Inventory.GetBackpackSlot()]
			end

			if backpackItem and toInventory.id == backpackId then
				local rules = Items.containers[backpackItem.name]
				local whitelist = rules and rules.whitelist
				local blacklist = rules and rules.blacklist

				if (whitelist and not whitelist[fromData.name]) or (blacklist and blacklist[fromData.name]) then
					return false
				end
			end

			local hookPayload = {
				source = source,
				fromInventory = fromInventory.id,
				fromSlot = fromData,
				fromType = fromInventory.type,
				toInventory = toInventory.id,
				toSlot = toData or data.toSlot,
				toType = toInventory.type,
				count = data.count,
			}

			if toData and ((toData.name ~= fromData.name) or not toData.stack or (not table.matches(toData.metadata, fromData.metadata))) then
				-- Swap items
				local toWeight = not sameInventory and (toInventory.weight - toData.weight + fromData.weight) or 0
				local fromWeight = not sameInventory and (fromInventory.weight + toData.weight - fromData.weight) or 0
				hookPayload.action = 'swap'

				if not sameInventory then
					if (toWeight <= toInventory.maxWeight and fromWeight <= fromInventory.maxWeight) then
						if not TriggerEventHooks('swapItems', hookPayload) then return end

						if containerItem then
							local whitelist = Items.containers[containerItem.name]?.whitelist
							local blacklist = Items.containers[containerItem.name]?.blacklist
							local checkItem = containerIsTarget and fromData.name or toData.name

							if (whitelist and not whitelist[checkItem]) or (blacklist and blacklist[checkItem]) then
								return
							end

							Inventory.ContainerWeight(containerItem, containerIsTarget and toWeight or fromWeight, playerInventory)
						end

						if fromOtherPlayer then
							TriggerClientEvent('ox_inventory:itemNotify', fromInventory.id, { fromData, 'ui_removed', fromData.count })
							TriggerClientEvent('ox_inventory:itemNotify', fromInventory.id, { toData, 'ui_added', toData.count })
						elseif toOtherPlayer then
							TriggerClientEvent('ox_inventory:itemNotify', toInventory.id, { fromData, 'ui_added', fromData.count })
							TriggerClientEvent('ox_inventory:itemNotify', toInventory.id, { toData, 'ui_removed', toData.count })
						end

						fromInventory.weight = fromWeight
						toInventory.weight = toWeight
						toData, fromData = Inventory.SwapSlots(fromInventory, toInventory, data.fromSlot, data.toSlot) --[[@as table]]

						if server.loglevel > 0 then
							lib.logger(playerInventory.owner, 'swapSlots', ('%sx %s transferred from "%s" to "%s" for %sx %s'):format(fromData.count, fromData.name, fromInventory.owner and fromInventory.label or fromInventory.id, toInventory.owner and toInventory.label or toInventory.id, toData.count, toData.name))
						end
					else return false, 'cannot_carry' end
				else
					if not TriggerEventHooks('swapItems', hookPayload) then return end

					toData, fromData = Inventory.SwapSlots(fromInventory, toInventory, data.fromSlot, data.toSlot)
				end

			elseif toData and toData.name == fromData.name and table.matches(toData.metadata, fromData.metadata) then
				-- Stack items
				toData.count += data.count
				fromData.count -= data.count
				local toSlotWeight = Inventory.SlotWeight(Items(toData.name), toData)
				local totalWeight = toInventory.weight - toData.weight + toSlotWeight

				if fromInventory.type == 'container' or sameInventory or totalWeight <= toInventory.maxWeight then
					hookPayload.action = 'stack'

					if not TriggerEventHooks('swapItems', hookPayload) then
						toData.count -= data.count
						fromData.count += data.count
						return
					end

					local fromSlotWeight = Inventory.SlotWeight(Items(fromData.name), fromData)
					toData.weight = toSlotWeight

					if not sameInventory then
						fromInventory.weight = fromInventory.weight - fromData.weight + fromSlotWeight
						toInventory.weight = totalWeight

						if container then
							Inventory.ContainerWeight(containerItem, container.weight, playerInventory)
						end

						if fromOtherPlayer then
							TriggerClientEvent('ox_inventory:itemNotify', fromInventory.id, { fromData, 'ui_removed', data.count })
						elseif toOtherPlayer then
							TriggerClientEvent('ox_inventory:itemNotify', toInventory.id, { toData, 'ui_added', data.count })
						end

						if server.loglevel > 0 then
							lib.logger(playerInventory.owner, 'swapSlots', ('%sx %s transferred from "%s" to "%s"'):format(data.count, fromData.name, fromInventory.owner and fromInventory.label or fromInventory.id, toInventory.owner and toInventory.label or toInventory.id))
						end
					end

					fromData.weight = fromSlotWeight
				else
					toData.count -= data.count
					fromData.count += data.count
					return false, 'cannot_carry'
				end
			elseif data.count <= fromData.count then
				-- Move item to an empty slot
				toData = table.clone(fromData)
				toData.count = data.count
				toData.slot = data.toSlot
				toData.weight = Inventory.SlotWeight(Items(toData.name), toData)

				if fromInventory.type == 'container' or sameInventory or (toInventory.weight + toData.weight <= toInventory.maxWeight) then
					hookPayload.action = 'move'

					if not TriggerEventHooks('swapItems', hookPayload) then return end

					if not sameInventory then
						if container then
							if containerIsTarget and containerItem then
								local whitelist = Items.containers[containerItem.name]?.whitelist
								local blacklist = Items.containers[containerItem.name]?.blacklist

								if (whitelist and not whitelist[fromData.name]) or (blacklist and blacklist[fromData.name]) then
									return
								end
							end
						end

						fromInventory.weight -= toData.weight
						toInventory.weight += toData.weight

						if container then
							Inventory.ContainerWeight(containerItem, container.weight, playerInventory)
						end

						if fromOtherPlayer then
							TriggerClientEvent('ox_inventory:itemNotify', fromInventory.id, { fromData, 'ui_removed', data.count })
						elseif toOtherPlayer then
							TriggerClientEvent('ox_inventory:itemNotify', toInventory.id, { fromData, 'ui_added', data.count })
						end

						if server.loglevel > 0 then
							lib.logger(playerInventory.owner, 'swapSlots', ('%sx %s transferred from "%s" to "%s"'):format(data.count, fromData.name, fromInventory.owner and fromInventory.label or fromInventory.id, toInventory.owner and toInventory.label or toInventory.id))
						end
					end

					fromData.count -= data.count
					fromData.weight = Inventory.SlotWeight(Items(fromData.name), fromData)

					if fromData.count > 0 then
						toData.metadata = table.clone(toData.metadata)
					end
				else return false, 'cannot_carry_other' end
			end

			if fromData and fromData.count < 1 then fromData = nil end

			-- Every branch has finished adjusting both inventories' weights by now, so the bag
			-- item's weight can be rebuilt from what its container actually holds.
			if backpackItem then
				local backpack = Inventory(backpackId)

				if backpack then
					Inventory.ContainerWeight(backpackItem, backpack.weight, playerInventory)
				end
			end

			---@type updateSlot[]
			local items = {}

			if fromInventory.player and not fromOtherPlayer then
				if toInventory.type == 'container' and containerItem then
					items[#items + 1] = {
						item = containerItem,
						inventory = playerInventory.id
					}
				end
			end

			if toInventory.player and not toOtherPlayer then
				if fromInventory.type == 'container' and containerItem then
					items[#items + 1] = {
						item = containerItem,
						inventory = playerInventory.id
					}
				end
			end

			if backpackItem then
				items[#items + 1] = {
					item = backpackItem,
					inventory = playerInventory.id
				}
			end

			if applyRotation and toData then
				toData.metadata.rotated = rotated or nil
			end

			fromInventory.items[data.fromSlot] = fromData
			toInventory.items[data.toSlot] = toData

			rebindAfterSwap(fromInventory, toInventory, data, hookPayload.action or 'move', fromData == nil)

			if fromInventory.changed ~= nil then fromInventory.changed = true end
			if toInventory.changed ~= nil then toInventory.changed = true end

			local backpackSlot = Inventory.GetBackpackSlot()

			if backpackSlot then
				if data.fromSlot == backpackSlot and Inventory.RefreshBackpack(fromInventory) then
					Inventory.SyncBackpack(fromInventory)
				end

				if data.toSlot == backpackSlot and Inventory.RefreshBackpack(toInventory) then
					Inventory.SyncBackpack(toInventory)
				end
			end

			local beltSlot = Inventory.GetBeltSlot()

			if beltSlot then
				if data.fromSlot == beltSlot then Inventory.RefreshBelt(fromInventory) end
				if data.toSlot == beltSlot then Inventory.RefreshBelt(toInventory) end
			end

			Inventory.RefreshWorn(fromInventory, data.fromSlot)
			Inventory.RefreshWorn(toInventory, data.toSlot)

            CreateThread(function()
                if sameInventory then
                    fromInventory:syncSlotsWithClients({
                        {
                            item = fromInventory.items[data.toSlot] or { slot = data.toSlot },
                            inventory = fromInventory.id
                        },
                        {
                            item = fromInventory.items[data.fromSlot] or { slot = data.fromSlot },
                            inventory = fromInventory.id
                        }
                    }, true)
                else
                    toInventory:syncSlotsWithClients({
                        {
                            item = toInventory.items[data.toSlot] or { slot = data.toSlot },
                            inventory = toInventory.id
                        }
                    }, true)

                    fromInventory:syncSlotsWithClients({
                        {
                            item = fromInventory.items[data.fromSlot] or { slot = data.fromSlot },
                            inventory = fromInventory.id
                        }
                    }, true)
                end

                if backpackId then
                    local backpackSlots = {}

                    if fromInventory.id == backpackId then
                        backpackSlots[#backpackSlots + 1] = {
                            item = fromInventory.items[data.fromSlot] or { slot = data.fromSlot },
                            inventory = 'backpack'
                        }
                    end

                    if toInventory.id == backpackId then
                        backpackSlots[#backpackSlots + 1] = {
                            item = toInventory.items[data.toSlot] or { slot = data.toSlot },
                            inventory = 'backpack'
                        }
                    end

                    if next(backpackSlots) then
                        playerInventory:syncSlotsWithPlayer(backpackSlots, playerInventory.weight)
                    end
                end
            end)

			local resp

			if next(items) then
				resp = { weight = playerInventory.weight, items = items }
			end

			if server.syncInventory then
				if fromInventory.player then
					server.syncInventory(fromInventory)
				end

				if toInventory.player and not sameInventory then
					server.syncInventory(toInventory)
				end
			end

			local weaponSlot

			if toInventory.weapon == data.toSlot then
				if not sameInventory then
					toInventory.weapon = nil
					TriggerClientEvent('ox_inventory:disarm', toInventory.id)
				else
					weaponSlot = data.fromSlot
					toInventory.weapon = weaponSlot
				end
			end

			if fromInventory.weapon == data.fromSlot then
				if not sameInventory then
					fromInventory.weapon = nil
					TriggerClientEvent('ox_inventory:disarm', fromInventory.id)
				elseif not weaponSlot then
					weaponSlot = data.toSlot
					fromInventory.weapon = weaponSlot
				end
			end

			return containerItem and containerItem.weight or true, resp, weaponSlot
		end
	end
end)

function Inventory.Confiscate(source)
	local inv = Inventory(source)

	if inv?.player then
		db.saveStash(inv.owner, inv.owner, json.encode(minimal(inv)))
		table.wipe(inv.items)
		inv.weight = 0
		inv.changed = true

		TriggerClientEvent('ox_inventory:inventoryConfiscated', inv.id)

		-- The equipment slot went with everything else, so the endpoint must not outlive it.
		if Inventory.RefreshBackpack(inv) then Inventory.SyncBackpack(inv) end

		if server.syncInventory then server.syncInventory(inv) end
	end
end
exports('ConfiscateInventory', Inventory.Confiscate)

function Inventory.Return(source)
	local inv = Inventory(source)

	if not inv?.player then return end

	local items = MySQL.scalar.await('SELECT data FROM ox_inventory WHERE name = ?', { inv.owner })

    if not items then return end

	MySQL.update.await('DELETE FROM ox_inventory WHERE name = ?', { inv.owner })

    items = json.decode(items)
    local inventory, totalWeight = {}, 0

    if table.type(items) == 'array' then
        for i = 1, #items do
            local data = items[i]
            if type(data) == 'number' then break end

            local item = Items(data.name)

            if item then
                local weight = Inventory.SlotWeight(item, data)
                totalWeight = totalWeight + weight
                inventory[data.slot] = {name = data.name, label = item.label, weight = weight, slot = data.slot, count = data.count, description = item.description, metadata = data.metadata, stack = item.stack, close = item.close}
            end
        end
    end

    inv.changed = true
    inv.weight = totalWeight
    inv.items = inventory

    TriggerClientEvent('ox_inventory:inventoryReturned', source, { inventory, totalWeight })

    -- `inv.items` was replaced wholesale, so the equipment slot may now hold a different bag.
    if Inventory.RefreshBackpack(inv) then Inventory.SyncBackpack(inv) end

    if server.syncInventory then server.syncInventory(inv) end
end

exports('ReturnInventory', Inventory.Return)

---@param inv inventory
---@param keep? string | string[] an item or list of items to ignore while clearing items
function Inventory.Clear(inv, keep)
	inv = Inventory(inv) --[[@as OxInventory]]

	if not inv or not next(inv.items) then return end

	local updateSlots = {}
	local newWeight = 0
	local inc = 0

	if keep then
		local keptItems = {}
		local keepType = type(keep)

		if keepType == 'string' then
			for slot, v in pairs(inv.items) do
				if v.name == keep then
					keptItems[v.slot] = v
					newWeight += v.weight
				elseif updateSlots then
					inc += 1
					updateSlots[inc] = { item = { slot = slot }, inventory = inv.id }
				end
			end
		elseif keepType == 'table' and table.type(keep) == 'array' then
			for slot, v in pairs(inv.items) do
				for i = 1, #keep do
					if v.name == keep[i] then
						keptItems[v.slot] = v
						newWeight += v.weight
						goto foundItem
					end
				end

				if updateSlots then
					inc += 1
					updateSlots[inc] = { item = { slot = slot }, inventory = inv.id }
				end

				::foundItem::
			end
		end

		table.wipe(inv.items)
		inv.items = keptItems
	else
		if updateSlots then
			for slot in pairs(inv.items) do
				inc += 1
				updateSlots[inc] = { item = { slot = slot }, inventory = inv.id }
			end
		end

		table.wipe(inv.items)
	end

	inv.weight = newWeight
	inv.changed = true

	pruneFastSlots(inv, true)
	Inventory.RefreshWorn(inv)

	inv:syncSlotsWithClients(updateSlots, true)

	if not inv.player then
		if inv.open then
			local playerInv = Inventory(inv.open)

			if not playerInv then return end

			playerInv:closeInventory()
		end

		inv:openInventory(inv)

		return
	end

	-- Clearing a player inventory can take the worn bag with it.
	if Inventory.RefreshBackpack(inv) then Inventory.SyncBackpack(inv) end

	if server.syncInventory then server.syncInventory(inv) end

	inv.weapon = nil
end

exports('ClearInventory', Inventory.Clear)

---@param inv inventory
---@param item? table | string item the slot is intended for; sizes the search in grid layout
---@return integer?
function Inventory.GetEmptySlot(inv, item)
	local inventory = Inventory(inv)

	if not inventory then return end

	if Grid.isGridLayout() then
		if type(item) ~= 'table' then item = item and Items(item) or nil end

		return Grid.findSlot(inventory, Grid.getItemSize(item))
	end

	local items = inventory.items

	-- Equipment slots are never chosen automatically.
	for i = 1, Grid.getBaseSlots(inventory) do
		if not items[i] then
			return i
		end
	end
end

exports('GetEmptySlot', Inventory.GetEmptySlot)

---@param inv inventory
---@param itemName string
---@param metadata any
function Inventory.GetSlotForItem(inv, itemName, metadata)
	local inventory = Inventory(inv)
	local item = Items(itemName) --[[@as OxServerItem?]]

	if not inventory or not item then return end

	metadata = assertMetadata(metadata)
	local items = inventory.items
	local emptySlot
	local layout = Grid.isGridLayout() and Grid.getLayout(inventory) or nil
	local width, height = Grid.getItemSize(item)

	-- Equipment slots are never chosen automatically.
	for i = 1, Grid.getBaseSlots(inventory) do
		local slotData = items[i]

		if item.stack and slotData and slotData.name == item.name and table.matches(slotData.metadata, metadata) then
			return i
		elseif not item.stack and not slotData and not emptySlot and (not layout or Grid.fits(layout, i, width, height)) then
			emptySlot = i
		end
	end

	return emptySlot
end

exports('GetSlotForItem', Inventory.GetSlotForItem)

---@param inv inventory
---@param itemName string
---@param metadata? any
---@param strict? boolean Strictly match metadata properties, otherwise use partial matching.
---@return SlotWithItem?
function Inventory.GetSlotWithItem(inv, itemName, metadata, strict)
	local inventory = Inventory(inv)
	local item = Items(itemName) --[[@as OxServerItem?]]

	if not inventory or not item then return end

	metadata = assertMetadata(metadata)
	local tablematch = strict and table.matches or table.contains

	for _, slotData in pairs(inventory.items) do
		if slotData and slotData.name == item.name and (not metadata or tablematch(slotData.metadata, metadata)) then
            if not Items.UpdateDurability(inventory, slotData, item, nil, os.time()) then
                return slotData
            end
		end
	end
end

exports('GetSlotWithItem', Inventory.GetSlotWithItem)

---@param inv inventory
---@param itemName string
---@param metadata? any
---@param strict? boolean Strictly match metadata properties, otherwise use partial matching.
---@return number?
function Inventory.GetSlotIdWithItem(inv, itemName, metadata, strict)
	return Inventory.GetSlotWithItem(inv, itemName, metadata, strict)?.slot
end

exports('GetSlotIdWithItem', Inventory.GetSlotIdWithItem)

---@param inv inventory
---@param itemName string
---@param metadata? any
---@param strict? boolean Strictly match metadata properties, otherwise use partial matching.
---@return SlotWithItem[]?
function Inventory.GetSlotsWithItem(inv, itemName, metadata, strict)
	local inventory = Inventory(inv)
	local item = Items(itemName) --[[@as OxServerItem?]]

	if not inventory or not item then return end

	metadata = assertMetadata(metadata)
	local response = {}
	local n = 0
	local tablematch = strict and table.matches or table.contains

	for _, slotData in pairs(inventory.items) do
		if slotData and slotData.name == item.name and (not metadata or tablematch(slotData.metadata, metadata)) then
            if not Items.UpdateDurability(inventory, slotData, item, nil, os.time()) then
                n += 1
                response[n] = slotData
            end
		end
	end

	return response
end

exports('GetSlotsWithItem', Inventory.GetSlotsWithItem)

---@param inv inventory
---@param itemName string
---@param metadata? any
---@param strict? boolean Strictly match metadata properties, otherwise use partial matching.
---@return number[]?
function Inventory.GetSlotIdsWithItem(inv, itemName, metadata, strict)
	local items = Inventory.GetSlotsWithItem(inv, itemName, metadata, strict)

	if items then
		---@cast items +number[]
		for i = 1, #items do
			items[i] = items[i].slot
		end

		return items
	end
end

exports('GetSlotIdsWithItem', Inventory.GetSlotIdsWithItem)

---@param inv inventory
---@param itemName string
---@param metadata? any
---@param strict? boolean Strictly match metadata properties, otherwise use partial matching.
---@return number
function Inventory.GetItemCount(inv, itemName, metadata, strict)
	local inventory = Inventory(inv)
	local item = Items(itemName) --[[@as OxServerItem?]]

	if not inventory or not item then return 0 end

	metadata = assertMetadata(metadata)
	local count = 0
	local tablematch = strict and table.matches or table.contains

	for _, slotData in pairs(inventory.items) do
		if slotData and slotData.name == item.name and (not metadata or tablematch(slotData.metadata, metadata)) then
			count += slotData.count
		end
	end

	return count
end

exports('GetItemCount', Inventory.GetItemCount)

---@alias InventorySaveData { [1]: MinimalInventorySlot, [2]: string | number, [3]: string | number | nil }

---@param inv OxInventory
---@param buffer table
---@param time integer
---@return integer?
---@return InventorySaveData?
local function prepareInventorySave(inv, buffer, time)
    saveFastSlots(inv)

    local shouldSave = not inv.datastore and inv.changed
    local n = 0

    for k, v in pairs(inv.items) do
        if not Items.UpdateDurability(inv, v, Items(v.name), nil, time) and shouldSave then
            n += 1
            buffer[n] = {
                name = v.name,
                count = v.count,
                slot = k,
                metadata = next(v.metadata) and v.metadata or nil
            }
        end
	end

    if not shouldSave then return end

    local data = next(buffer) and json.encode(buffer) or nil
    inv.changed = false
    table.wipe(buffer)

    if inv.player then
        if shared.framework == 'esx' then return end

        return 1, { data, inv.owner }
    end

    if inv.type == 'trunk' then
        return 2, { data, inv.dbId }
    end

    if inv.type == 'glovebox' then
        return 3, { data, inv.dbId }
    end

    return 4, { data, inv.owner and tostring(inv.owner) or '', inv.dbId }
end

local isSaving = false
local inventoryClearTime = GetConvarInt('inventory:cleartime', 5) * 60

local function saveInventories(clearInventories)
	if isSaving then return end

	local time = os.time()
	local parameters = { {}, {}, {}, {} }
	local total = { 0, 0, 0, 0, 0 }
    local buffer = {}

	for _, inv in pairs(Inventories) do
        local index, data = prepareInventorySave(inv, buffer, time)

        if index and data then
            total[5] += 1

            if index == 4 and server.bulkstashsave then
                for i = 1, 3 do
					total[index] += 1
                    parameters[index][total[index]] = data[i]
                end
            else
				total[index] += 1
                parameters[index][total[index]] = data
            end
        end
	end

    if total[5] > 0 then
        isSaving = true
        local ok, err = pcall(db.saveInventories, parameters[1], parameters[2], parameters[3], parameters[4], total)
        isSaving = false

        if not ok and err then return lib.print.error(err) end
    end

    if not clearInventories then return end

    for _, inv in pairs(Inventories) do
        if not inv.open and not inv.player then
            -- clear inventory from memory if unused for x minutes, or on entity/netid mismatch
            if inv.type == 'glovebox' or inv.type == 'trunk' then
                if NetworkGetEntityFromNetworkId(inv.netid) ~= inv.entityId then
                    Inventory.Remove(inv)
                end
            elseif time - inv.time >= inventoryClearTime then
                Inventory.Remove(inv)
            end
        end
    end
end

lib.cron.new('*/5 * * * *', function()
    saveInventories(true)
end)

function Inventory.SaveInventories(lock, clearInventories)
	Inventory.Lock = lock or nil

	Inventory.CloseAll()
    saveInventories(clearInventories)
end

AddEventHandler('playerDropped', function()
	server.playerDropped(source)

	if GetNumPlayerIndices() == 0 then
		Inventory.SaveInventories(false, true)
	end
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function()
	Inventory.SaveInventories(true, false)
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining ~= 60 then return end

	Inventory.SaveInventories(true, true)
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == shared.resource then
		Inventory.SaveInventories(true, false)
	end
end)

RegisterServerEvent('ox_inventory:closeInventory', function()
	local inventory = Inventories[source]

	if inventory?.open then
		local secondary = Inventories[inventory.open]

		if secondary then
			secondary:closeInventory()
		end

		inventory:closeInventory(true)
	end
end)

local function giveItem(playerId, slot, target, count)
	local fromInventory = Inventory(playerId)
	local toInventory = Inventory(target)

	if not fromInventory or not toInventory then return end

	if type(count) ~= 'number' or count <= 0 then count = 1 end

	if toInventory.player then
		local data = fromInventory.items[slot]

		if not data then return end

        local targetState = Player(target).state

        if targetState.invBusy then
            return { 'cannot_give', count, data.label }
        end

		local item = Items(data.name)

		if not item or data.count < count or not Inventory.CanCarryItem(toInventory, item, count, data.metadata) or #(GetEntityCoords(fromInventory.player.ped) - GetEntityCoords(toInventory.player.ped)) > 15 then
			return { 'cannot_give', count, data.label }
		end

		local toSlot = Inventory.GetSlotForItem(toInventory, data.name, data.metadata)
		local fromRef = ('%s:%s'):format(fromInventory.id, slot)
		local toRef = ('%s:%s'):format(toInventory.id, toSlot)

		if activeSlots[fromRef] or activeSlots[toRef] then
			return { 'cannot_give', count, data.label }
		end

		activeSlots[fromRef] = true
		activeSlots[toRef] = true

		local _ <close> = defer(function()
			activeSlots[fromRef] = nil
			activeSlots[toRef] = nil
		end)

		if TriggerEventHooks('swapItems', {
			source = fromInventory.id,
			fromInventory = fromInventory.id,
			fromType = fromInventory.type,
			toInventory = toInventory.id,
			toType = toInventory.type,
			count = count,
			action = 'give',
			fromSlot = data,
		}) then
			---@todo manually call swapItems or something?
			if Inventory.AddItem(toInventory, item, count, data.metadata, toSlot) then
				if Inventory.RemoveItem(fromInventory, item, count, data.metadata, slot) then
					if server.loglevel > 0 then
						lib.logger(fromInventory.owner, 'giveItem', ('"%s" gave %sx %s to "%s"'):format(fromInventory.label, count, data.name, toInventory.label))
					end

					return
				else
					Inventory.RemoveItem(toInventory, item, count, data.metadata, toSlot)
				end
			end
		end

		return { 'cannot_give', count, data.label }
	end
end

lib.callback.register('ox_inventory:giveItem', giveItem)
RegisterServerEvent('ox_inventory:giveItem', function(...) giveItem(source, ...) end)

local function updateWeapon(source, action, value, slot, specialAmmo)
	local inventory = Inventory(source)

	if not inventory then return end

	if not action then
		inventory.weapon = nil
		return
	end

	local type = type(value)

	if type == 'table' and action == 'component' then
		local item = inventory.items[value.slot]

		if item then
			if item.metadata.components then
				for k, v in pairs(item.metadata.components) do
					if v == value.component then
						if not Inventory.AddItem(inventory, value.component, 1) then return end

						table.remove(item.metadata.components, k)
						inventory:syncSlotsWithPlayer({
							{ item = item }
						}, inventory.weight)

			            if server.syncInventory then server.syncInventory(inventory) end

						return true
					end
				end
			end
		end
	else
		if not slot then slot = inventory.weapon end
		local weapon = inventory.items[slot]

		if weapon and weapon.metadata then
			local item = Items(weapon.name)

			if not item.weapon then
				inventory.weapon = nil
				return
			end

			if action == 'load' and weapon.metadata.durability > 0 then
				local ammo = Items(weapon.name).ammoname
				local diff = value - (weapon.metadata.ammo or 0)

				if not Inventory.RemoveItem(inventory, ammo, diff, specialAmmo) then return end

				weapon.metadata.ammo = value
				weapon.metadata.specialAmmo = specialAmmo
				weapon.weight = Inventory.SlotWeight(item, weapon)
			elseif action == 'throw' then
				if not Inventory.RemoveItem(inventory, weapon.name, 1, weapon.metadata, weapon.slot) then return end
			elseif action == 'component' then
				if type == 'number' then
					if not Inventory.AddItem(inventory, weapon.metadata.components[value], 1) then return false end

					table.remove(weapon.metadata.components, value)
					weapon.weight = Inventory.SlotWeight(item, weapon)
				elseif type == 'string' then
					local component = inventory.items[tonumber(value)]

					if not Inventory.RemoveItem(inventory, component.name, 1) then return false end

					table.insert(weapon.metadata.components, component.name)
					weapon.weight = Inventory.SlotWeight(item, weapon)
				end
			elseif action == 'ammo' then
				if item.hash == `WEAPON_FIREEXTINGUISHER` or item.hash == `WEAPON_PETROLCAN` or item.hash == `WEAPON_HAZARDCAN` or item.hash == `WEAPON_FERTILIZERCAN` then
					weapon.metadata.durability = math.floor(value)
					weapon.metadata.ammo = weapon.metadata.durability
				elseif value < weapon.metadata.ammo then
					local durability = Items(weapon.name).durability * math.abs((weapon.metadata.ammo or 0.1) - value)
					weapon.metadata.ammo = value
					weapon.metadata.durability = weapon.metadata.durability - durability
					weapon.weight = Inventory.SlotWeight(item, weapon)
				end
			elseif action == 'melee' and value > 0 then
				weapon.metadata.durability = weapon.metadata.durability - ((Items(weapon.name).durability or 1) * value)
			end

            if (weapon.metadata.durability or 0) < 0 then
                weapon.metadata.durability = 0
            end

            if item.hash == `WEAPON_PETROLCAN` then
                weapon.weight = Inventory.SlotWeight(item, weapon)
            end

			if action ~= 'throw' then
				inventory:syncSlotsWithPlayer({
					{ item = weapon }
				}, inventory.weight)
			end

			if server.syncInventory then server.syncInventory(inventory) end

			return true
		end
	end
end

lib.callback.register('ox_inventory:updateWeapon', updateWeapon)

RegisterNetEvent('ox_inventory:updateWeapon', function(action, value, slot, specialAmmo)
	updateWeapon(source, action, value, slot, specialAmmo)
end)

lib.callback.register('ox_inventory:removeAmmoFromWeapon', function(source, slot)
	local inventory = Inventory(source)

	if not inventory then return end

	local slotData = inventory.items[slot]

	if not slotData or not slotData.metadata.ammo or slotData.metadata.ammo < 1 then return end

	local item = Items(slotData.name)

	if not item or not item.ammoname then return end
	local specialAmmo = slotData.metadata.specialAmmo and { type = slotData.metadata.specialAmmo } or nil


	if Inventory.AddItem(inventory, item.ammoname, slotData.metadata.ammo, specialAmmo) then
		slotData.metadata.ammo = 0
		slotData.weight = Inventory.SlotWeight(item, slotData)

		inventory:syncSlotsWithPlayer({
			{ item = slotData }
		}, inventory.weight)

		if server.syncInventory then server.syncInventory(inventory) end

		return true
	end
end)

local function checkStashProperties(properties)
	local name = properties.name
	local slots = properties.slots
	local maxWeight = properties.maxWeight
	local coords = properties.coords

	if type(name) ~= 'string' then
		error(('received %s for stash name (expected string)'):format(type(name)))
	end

	if type(slots) ~= 'number' then
		error(('received %s for stash slots (expected number)'):format(type(slots)))
	end

	if type(maxWeight) ~= 'number' then
		error(('received %s for stash maxWeight (expected number)'):format(type(maxWeight)))
	end

	if coords then
		local typeof = type(coords)

		if typeof ~= 'vector3' then
			if typeof == 'table' and table.type(coords) ~= 'array' then
				coords = vec3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
			else
				if table.type(coords) == 'array' then
					for i = 1, #coords do
						coords[i] = vec3(coords[i].x, coords[i].y, coords[i].z)
					end
				else
					error(('received %s for stash coords (expected vector3 or array of vector3)'):format(typeof))
				end
			end
		end
	end

	return name, slots, maxWeight, coords
end

---@param name string stash identifier when loading from the database
---@param label string display name when inventory is open
---@param slots number
---@param maxWeight number
---@param owner? string|number|boolean
---@param groups? table<string, number>
---@param coords? vector3|table<vector3>
---@param properties? { gridRows?: number } grid rows for this stash alone, overriding `containerRows`
--- For simple integration with other resources that want to create valid stashes.
--- This needs to be triggered before a player can open a stash.
--- ```
--- Owner sets the stash permissions.
--- string: can only access the stash linked to the owner (usually player identifier)
--- true: each player has a unique stash, but can request other player's stashes
--- nil: always shared
---
--- groups: { ['police'] = 0 }
--- ```
local function registerStash(name, label, slots, maxWeight, owner, groups, coords, properties)
	name, slots, maxWeight, coords = checkStashProperties({
		name = name,
		slots = slots,
		maxWeight = maxWeight,
		coords = coords,
	})

	local gridRows = type(properties) == 'table' and tonumber(properties.gridRows) or nil

	if gridRows then
		gridRows = math.floor(gridRows)

		if gridRows < 1 then gridRows = 1 end
	end

	local curStash = RegisteredStashes[name]

	if curStash then
		---@todo creating proper stash classes with inheritence would simplify updating data
		---i.e. all stashes with the same type share groups, maxweight, slots, dbid, etc.
		---only label, owner, weight, coords, and items really need to vary
		for _, stash in pairs(Inventories) do
			if stash.type == 'stash' and stash.dbId == name then
				stash.label = label or stash.label
				stash.owner = (owner and owner ~= true) and stash.owner or owner
				stash.slots = slots and Grid.scaleContainerSlots(slots, gridRows) or stash.slots
				stash.maxWeight = maxWeight or stash.maxWeight
				stash.groups = groups or stash.groups
				stash.coords = coords or stash.coords
			end
		end
	end

	RegisteredStashes[name] = {
		name = name,
		label = label,
		owner = owner,
		slots = slots,
		maxWeight = maxWeight,
		groups = groups,
		coords = coords,
		gridRows = gridRows
	}
end

exports('RegisterStash', registerStash)

---@param properties TemporaryStashProperties
function Inventory.CreateTemporaryStash(properties)
	properties.name = generateInvId('temp')

	local name, slots, maxWeight, coords = checkStashProperties(properties)
	local inventory = Inventory.Create(name, properties.label, 'temp', slots, 0, maxWeight, properties.owner, {}, properties.groups)

	if not inventory then return end

	inventory.items, inventory.weight = generateItems(inventory, 'drop', properties.items)
	inventory.coords = coords

	return inventory.id
end

exports('CreateTemporaryStash', Inventory.CreateTemporaryStash)

function Inventory.InspectInventory(playerId, invId)
	local inventory = invId ~= playerId and Inventory(invId)
	local playerInventory = Inventory(playerId)

	if playerInventory and inventory then
		playerInventory:openInventory(inventory)
		TriggerClientEvent('ox_inventory:viewInventory', playerId, playerInventory, inventory)
	end
end

exports('InspectInventory', Inventory.InspectInventory)

return Inventory
