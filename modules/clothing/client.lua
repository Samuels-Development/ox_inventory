local Items = require 'modules.items.client'
local Grid = require 'modules.grid.shared'

local APPEARANCE_RESOURCE = 'illenium-appearance'
local FEMALE_MODEL = `mp_f_freemode_01`
local WATCHDOG_INTERVAL = 500

local worn = {}
local applied = {}
local base = {}
local watching = false
local savedAppearance
local loading = false

---@return boolean
local function hasAppearanceResource()
    return GetResourceState(APPEARANCE_RESOURCE) == 'started'
end

---@param item table?
---@param ped number
---@return table? variant
local function resolveVariant(item, ped)
    local wear = item and item.wear

    if type(wear) ~= 'table' then return end

    return GetEntityModel(ped) == FEMALE_MODEL and wear.female or wear.male
end

---@param variant table
---@return string
local function variantKey(variant)
    if variant.prop then return ('prop:%s'):format(variant.prop) end

    return ('component:%s'):format(variant.component)
end

---@param variant table
---@return number? drawable, number? texture
local function savedValue(variant)
    if type(savedAppearance) ~= 'table' then return end

    local list = variant.prop and savedAppearance.props or savedAppearance.components

    if type(list) ~= 'table' then return end

    local field = variant.prop and 'prop_id' or 'component_id'
    local id = variant.prop or variant.component

    for i = 1, #list do
        local entry = list[i]

        if type(entry) == 'table' and entry[field] == id then
            return entry.drawable, entry.texture
        end
    end
end

---@param ped number
---@param variant table
---@return number drawable, number texture
local function readSlot(ped, variant)
    if variant.prop then
        return GetPedPropIndex(ped, variant.prop), GetPedPropTextureIndex(ped, variant.prop)
    end

    return GetPedDrawableVariation(ped, variant.component), GetPedTextureVariation(ped, variant.component)
end

---@param ped number
---@param variant table
---@param drawable number
---@param texture number
local function writeSlot(ped, variant, drawable, texture)
    local bridged = hasAppearanceResource()

    if variant.prop then
        if bridged then
            return exports[APPEARANCE_RESOURCE]:setPedProp(ped, {
                prop_id = variant.prop,
                drawable = drawable,
                texture = texture,
            })
        end

        if drawable == -1 then return ClearPedProp(ped, variant.prop) end

        return SetPedPropIndex(ped, variant.prop, drawable, texture, false)
    end

    if bridged then
        return exports[APPEARANCE_RESOURCE]:setPedComponent(ped, {
            component_id = variant.component,
            drawable = drawable,
            texture = texture,
        })
    end

    SetPedComponentVariation(ped, variant.component, drawable, texture, 0)
end

---@param ped number
---@return table[] variants in configured slot order
local function resolveWorn(ped)
    local slots = Grid.getEquipSlots()
    local variants = {}

    if not slots then return variants end

    for i = 1, #slots do
        local name = worn[slots[i].name]
        local variant = name and resolveVariant(Items[name], ped)

        if variant then variants[#variants + 1] = variant end
    end

    return variants
end

local function apply()
    local ped = cache.ped

    if not ped or ped == 0 then return end

    local variants = resolveWorn(ped)
    local seen = {}

    for i = 1, #variants do
        local variant = variants[i]
        local key = variantKey(variant)

        if not seen[key] then
            seen[key] = true

            local drawable, texture = readSlot(ped, variant)
            local ours = applied[key]

            if base[key] == nil then
                local savedDrawable, savedTexture = savedValue(variant)

                if savedDrawable then
                    base[key] = { drawable = savedDrawable, texture = savedTexture or 0, variant = variant }
                else
                    base[key] = { drawable = drawable, texture = texture, variant = variant }
                end
            elseif ours and (ours.drawable ~= drawable or ours.texture ~= texture) then
                base[key] = { drawable = drawable, texture = texture, variant = variant }
            end

            if drawable ~= variant.drawable or texture ~= variant.texture then
                writeSlot(ped, variant, variant.drawable, variant.texture)
            end

            applied[key] = { drawable = variant.drawable, texture = variant.texture }
        end
    end

    for key in pairs(applied) do
        if not seen[key] then
            local restore = base[key]

            if restore then writeSlot(ped, restore.variant, restore.drawable, restore.texture) end

            applied[key] = nil
            base[key] = nil
        end
    end
end

---@param force boolean? re-read even when a copy is already held
local function loadSavedAppearance(force)
    if loading or not hasAppearanceResource() then return end
    if savedAppearance and not force then return end

    loading = true

    CreateThread(function()
        local ok, appearance = pcall(lib.callback.await, 'illenium-appearance:server:getAppearance', false)

        if ok and type(appearance) == 'table' then savedAppearance = appearance end

        loading = false

        table.wipe(base)
        apply()
    end)
end

local function startWatchdog()
    if watching then return end

    watching = true

    CreateThread(function()
        while watching do
            Wait(WATCHDOG_INTERVAL)

            if not next(worn) then break end

            apply()
        end

        watching = false
    end)
end

---@param list table?
local function setWorn(list)
    table.wipe(worn)

    if type(list) == 'table' then
        for slot, name in pairs(list) do
            if type(slot) == 'string' and type(name) == 'string' then worn[slot] = name end
        end
    end

    loadSavedAppearance()
    apply()

    if next(worn) then startWatchdog() end
end

RegisterNetEvent('ox_inventory:setWorn', function(list)
    if source == '' then return end

    setWorn(list)
end)

AddEventHandler('illenium-appearance:client:changeOutfit', function() loadSavedAppearance(true) end)
AddEventHandler('illenium-appearance:client:loadJobOutfit', function() loadSavedAppearance(true) end)

AddEventHandler('playerSpawned', function()
    table.wipe(applied)
    table.wipe(base)

    loadSavedAppearance(true)
    SetTimeout(0, apply)
end)

return {
    setWorn = setWorn,
    apply = apply,
}
