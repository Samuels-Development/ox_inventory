local function useExport(resource, export)
	return function(...)
		return exports[resource][export](nil, ...)
	end
end

local ItemList = {}
local isServer = IsDuplicityVersion()

local function setImagePath(path)
    if path then
        return path:match('^[%w]+://') and path or ('%s/%s'):format(client.imagepath, path)
    end
end

local uiConfig = shared.ui
local uiGrid = uiConfig and uiConfig.grid
local uiRarity = uiConfig and uiConfig.rarity
local rarityTiers = uiRarity and uiRarity.tiers or {}
local defaultRarity = uiRarity and uiRarity.default or 'common'
local gridDefaults = uiGrid and uiGrid.defaults or {}
local defaultGridSize = uiGrid and uiGrid.defaultSize or { 1, 1 }
local maxGridWidth = uiGrid and uiGrid.columns or 10
local maxGridHeight = 6
local clothingCategories = {}

if uiConfig and uiConfig.clothing and type(uiConfig.clothing.slots) == 'table' then
    for i = 1, #uiConfig.clothing.slots do
        clothingCategories[uiConfig.clothing.slots[i].name] = true
    end
end

local checkRarity = next(rarityTiers) ~= nil
local checkClothing = next(clothingCategories) ~= nil
local badRarity, badRarityCount = {}, 0
local badGrid, badGridCount = {}, 0
local badClothing, badClothingCount = {}, 0
local badWear, badWearCount = {}, 0

local MAX_DRAWABLE = 512
local MAX_TEXTURE = 64
local WEAR_MODELS = { 'male', 'female' }

---Records a bad value once, returning 1 the first time it is seen and 0 afterwards.
---@param set table<string, true>
---@param value any
---@return number
local function flagOnce(set, value)
    local key = tostring(value)

    if set[key] then return 0 end

    set[key] = true

    return 1
end

---@param value any
---@param max number
---@return number?
local function gridAxis(value, max)
    value = tonumber(value)

    if not value then return end

    value = math.floor(value)

    if value < 1 then return end

    return value > max and max or value
end

---@param value any
---@param max number
---@return number?
local function wearIndex(value, max)
    value = tonumber(value)

    if not value or value % 1 ~= 0 or value < 0 or value > max then return end

    return value
end

---@param variant any
---@return table? one of `{ prop = n, drawable = n, texture = n }` or `{ component = n, ... }`
local function wearVariant(variant)
    if type(variant) ~= 'table' then return end

    local prop = wearIndex(variant.prop, MAX_DRAWABLE)
    local component = prop == nil and wearIndex(variant.component, MAX_DRAWABLE) or nil

    if prop == nil and component == nil then return end

    local drawable = wearIndex(variant.drawable, MAX_DRAWABLE)

    if drawable == nil then return end

    return {
        prop = prop,
        component = component,
        drawable = drawable,
        texture = wearIndex(variant.texture, MAX_TEXTURE) or 0,
    }
end

---@param data OxItem
local normaliseClothing

---@param data OxItem
local function normaliseWear(data)
    local wear = data.wear

    if wear == nil then return end

    if type(wear) ~= 'table' or data.clothing == nil then
        badWearCount += flagOnce(badWear, data.name)
        data.wear = nil

        return
    end

    local shared = wearVariant(wear)
    local variants = shared and { male = shared, female = shared } or {}

    if not shared then
        for i = 1, #WEAR_MODELS do
            local model = WEAR_MODELS[i]
            local variant = wearVariant(wear[model])

            if variant then variants[model] = variant end
        end
    end

    if not variants.male and not variants.female then
        badWearCount += flagOnce(badWear, data.name)
        data.wear = nil

        return
    end

    variants.male = variants.male or variants.female
    variants.female = variants.female or variants.male

    data.wear = variants
end

---@param data OxItem
---@param class? string key of `shared.ui.grid.defaults` used when the item has no explicit size
local function normaliseItem(data, class)
    local rarity = data.rarity

    if rarity == nil then
        data.rarity = defaultRarity
    elseif checkRarity and not (type(rarity) == 'string' and rarityTiers[rarity]) then
        badRarityCount += flagOnce(badRarity, rarity)
        data.rarity = defaultRarity
    end

    local grid = data.grid
    local width, height

    if grid ~= nil then
        if type(grid) == 'table' then
            width = gridAxis(grid[1] or grid.width or grid.w, maxGridWidth)
            height = gridAxis(grid[2] or grid.height or grid.h, maxGridHeight)
        end

        if not width or not height then
            badGridCount += flagOnce(badGrid, data.name)
        end
    end

    if not width or not height then
        local fallback = class and gridDefaults[class] or defaultGridSize

        if type(fallback) ~= 'table' then fallback = defaultGridSize end

        width = width or gridAxis(fallback[1], maxGridWidth) or 1
        height = height or gridAxis(fallback[2], maxGridHeight) or 1
    end

    data.grid = { width, height }

    normaliseClothing(data)
    normaliseWear(data)
end

---@param data OxItem
normaliseClothing = function(data)
    local clothing = data.clothing

    if clothing == nil or not checkClothing then return end

    if type(clothing) == 'string' then
        if not clothingCategories[clothing] then
            badClothingCount += flagOnce(badClothing, clothing)
            data.clothing = nil
        end

        return
    end

    if type(clothing) ~= 'table' then
        badClothingCount += flagOnce(badClothing, clothing)
        data.clothing = nil

        return
    end

    local categories = {}

    for i = 1, #clothing do
        local category = clothing[i]

        if type(category) == 'string' and clothingCategories[category] then
            categories[#categories + 1] = category
        else
            badClothingCount += flagOnce(badClothing, category)
        end
    end

    data.clothing = categories[1] and categories or nil
end

---@param set table<string, true>
---@return string
local function listKeys(set)
    local keys = {}

    for key in pairs(set) do
        keys[#keys + 1] = key
    end

    table.sort(keys)

    return table.concat(keys, ', ')
end

---@param data OxItem
local function newItem(data)
	data.weight = data.weight or 0

	if data.close == nil then
		data.close = true
	end

	if data.stack == nil then
		data.stack = true
	end

	normaliseItem(data)

	local clientData, serverData = data.client, data.server
	---@cast clientData -nil
	---@cast serverData -nil

	if not data.consume and (clientData and (clientData.status or clientData.usetime or clientData.export) or serverData?.export) then
		data.consume = 1
	end

	if isServer then
        ---@cast data OxServerItem
        serverData = data.server
		data.client = nil

		if not data.durability then
			if data.degrade or (data.consume and data.consume ~= 0 and data.consume < 1) then
				data.durability = true
			end
		end

        if not serverData then goto continue end

        if serverData.export then
            data.cb = useExport(string.strsplit('.', serverData.export))
        end
	else
        ---@cast data OxClientItem
        clientData = data.client
		data.server = nil
		data.count = 0

        if not clientData then goto continue end

        if clientData.export then
            data.export = useExport(string.strsplit('.', clientData.export))
        end

        clientData.image = setImagePath(clientData.image)

        if clientData.propTwo then
            clientData.prop = clientData.prop and { clientData.prop, clientData.propTwo } or clientData.propTwo
            clientData.propTwo = nil
        end
	end

    ::continue::
	ItemList[data.name] = data
end

for type, data in pairs(lib.load('data.weapons') or {}) do
	for k, v in pairs(data) do
		v.name = k
		v.close = type == 'Ammo' and true or false
        v.weight = v.weight or 0

		if type == 'Weapons' then
			---@cast v OxWeapon
			v.model = v.model or k -- actually weapon type or such? model for compatibility
			v.hash = joaat(v.model)
			v.stack = v.throwable and true or false
			v.durability = v.durability or 0.05
			v.weapon = true
		else
			v.stack = true
		end

		local class = type == 'Ammo' and 'ammo' or type == 'Components' and 'component' or type == 'Tints' and 'tint' or 'weapon'

		v[class] = true

		normaliseItem(v, class)

		if isServer then v.client = nil else
			v.count = 0
			v.server = nil
			local clientData = v.client

			if clientData?.image then
                clientData.image = setImagePath(clientData.image)
			end
		end

		ItemList[k] = v
	end
end

for k, v in pairs(lib.load('data.items') or {}) do
	v.name = k
	local success, response = pcall(newItem, v)

    if not success then
        warn(('An error occurred while creating item "%s" callback!\n^1SCRIPT ERROR: %s^0'):format(k, response))
    end
end

ItemList.cash = ItemList.money

if badRarityCount > 0 then
    warn(('%s unknown item rarity value(s) replaced with "%s": %s'):format(badRarityCount, defaultRarity, listKeys(badRarity)))
end

if badGridCount > 0 then
    warn(('%s item(s) have an invalid "grid" size and fell back to the class default: %s'):format(badGridCount, listKeys(badGrid)))
end

if badClothingCount > 0 then
    warn(('%s unknown "clothing" categor(y/ies) ignored: %s'):format(badClothingCount, listKeys(badClothing)))
end

if badWearCount > 0 then
    warn(('%s item(s) have an invalid "wear" block and will not be worn: %s'):format(badWearCount, listKeys(badWear)))
end

return ItemList
