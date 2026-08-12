local containers = {}

---@class ItemContainerProperties
---@field slots number
---@field maxWeight number
---@field whitelist? table<string, true> | string[]
---@field blacklist? table<string, true> | string[]

local function arrayToSet(tbl)
	local size = #tbl
	local set = table.create(0, size)

	for i = 1, size do
		set[tbl[i]] = true
	end

	return set
end

---Registers items with itemName as containers (i.e. backpacks, wallets).
---@param itemName string
---@param properties ItemContainerProperties
---@todo Rework containers for flexibility, improved data structure; then export this method.
local function setContainerProperties(itemName, properties)
	local blacklist, whitelist = properties.blacklist, properties.whitelist

	if blacklist then
		local tableType = table.type(blacklist)

		if tableType == 'array' then
			blacklist = arrayToSet(blacklist)
		elseif tableType ~= 'hash' then
			TypeError('blacklist', 'table', type(blacklist))
		end
	end

	if whitelist then
		local tableType = table.type(whitelist)

		if tableType == 'array' then
			whitelist = arrayToSet(whitelist)
		elseif tableType ~= 'hash' then
			TypeError('whitelist', 'table', type(whitelist))
		end
	end

	containers[itemName] = {
		size = { properties.slots, properties.maxWeight },
		blacklist = blacklist,
		whitelist = whitelist,
	}
end

exports('setContainerProperties', setContainerProperties)

setContainerProperties('paperbag', {
	slots = 5,
	maxWeight = 1000,
	blacklist = { 'testburger' }
})

setContainerProperties('pizzabox', {
	slots = 5,
	maxWeight = 1000,
	whitelist = { 'pizza' }
})

local containerItems = {
	'paperbag', 'pizzabox',
	'backpack_fashion', 'backpack_small', 'backpack_urban', 'backpack_gamer', 'backpack_medium',
	'backpack_hiking', 'backpack_large',
	'duffel_bag_sport', 'duffel_bag',
	'briefcase', 'medic_bag',
}

local bags = {
	{ 'backpack_fashion',        8,  12000 },
	{ 'backpack_small',          10, 15000 },
	{ 'backpack_urban',          16, 25000 },
	{ 'backpack_gamer',          18, 28000 },
	{ 'backpack_medium',         20, 30000 },
	{ 'backpack_hiking',         26, 45000 },
	{ 'backpack_large',          30, 50000 },
	{ 'duffel_bag_sport',        36, 65000 },
	{ 'duffel_bag',              40, 70000 },
	{ 'briefcase',               12, 20000 },
	{ 'medic_bag',               20, 30000 },
}

for i = 1, #bags do
	local bag = bags[i]

	setContainerProperties(bag[1], {
		slots = bag[2],
		maxWeight = bag[3],
		blacklist = containerItems
	})
end

return containers
