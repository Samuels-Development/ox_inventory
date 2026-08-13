if not lib then return end

local Grid = {}

local DEFAULT_COLUMNS = 10
local MIN_COLUMNS = 5
local MAX_COLUMNS = 14
local MAX_HEIGHT = 6
local DEFAULT_PLAYER_SLOTS = 50

local floor = math.floor
local ceil = math.ceil

---@return table?
local function getConfig()
    local ui = type(shared) == 'table' and shared.ui or nil

    return type(ui) == 'table' and ui or nil
end

---Number of slots a player inventory has before equipment slots are appended.
---@return number
local function normalSlotCount()
    local slots = type(shared) == 'table' and tonumber(shared.playerslots) or nil

    return slots and floor(slots) or DEFAULT_PLAYER_SLOTS
end

---@return boolean
function Grid.isGridLayout()
    local ui = getConfig()

    return ui ~= nil and ui.layout == 'grid'
end

---@param slots number?
---@param rows number? grid rows for this inventory alone, overriding `containerRows`
---@return number?
function Grid.scaleContainerSlots(slots, rows)
    local count = tonumber(slots)

    if not count or not Grid.isGridLayout() then return slots end

    local ui = getConfig()
    local grid = ui and type(ui.grid) == 'table' and ui.grid or nil

    if not grid then return slots end

    local override = tonumber(rows)

    if override then return floor(math.max(1, override)) * Grid.getColumns() end

    local containerRows = tonumber(grid.containerRows)

    if containerRows then return floor(math.max(1, containerRows)) * Grid.getColumns() end

    local scale = tonumber(grid.containerScale)

    if not scale or scale <= 1 then return slots end

    return ceil(count * scale)
end

---@return number
function Grid.getColumns()
    local ui = getConfig()
    local grid = ui and type(ui.grid) == 'table' and ui.grid or nil
    local columns = grid and tonumber(grid.columns) or nil

    if not columns then return DEFAULT_COLUMNS end

    columns = floor(columns)

    if columns < MIN_COLUMNS then return MIN_COLUMNS end
    if columns > MAX_COLUMNS then return MAX_COLUMNS end

    return columns
end

---@return boolean
function Grid.allowRotate()
    if not Grid.isGridLayout() then return false end

    local ui = getConfig()
    local grid = ui and type(ui.grid) == 'table' and ui.grid or nil

    return grid ~= nil and grid.allowRotate == true
end

---Ordered equipment slot definitions, or nil when clothing is disabled.
---@return table[]?
function Grid.getEquipSlots()
    local ui = getConfig()
    local clothing = ui and ui.clothing

    if type(clothing) ~= 'table' or not clothing.enabled then return end

    local slots = clothing.slots

    if type(slots) ~= 'table' or #slots == 0 then return end

    return slots
end

---@return number
function Grid.getEquipCount()
    local slots = Grid.getEquipSlots()

    return slots and #slots or 0
end

---First slot index reserved for equipment, or nil when clothing is disabled.
---@return number?
function Grid.getEquipStart()
    if Grid.getEquipCount() == 0 then return end

    return normalSlotCount() + 1
end

---Total slot count of a player inventory, including equipment slots.
---@return number
function Grid.getPlayerSlots()
    return normalSlotCount() + Grid.getEquipCount()
end

---@param slot any
---@param maxSlots number?
---@return boolean
function Grid.isSlotId(slot, maxSlots)
    if type(slot) ~= 'number' or slot < 1 or slot % 1 ~= 0 then return false end

    return slot <= (tonumber(maxSlots) or 0)
end

---@param inv table? inventory-like table with `type` and `slots`
---@param slot any
---@return boolean
function Grid.isEquipSlot(inv, slot)
    local count = Grid.getEquipCount()

    if count == 0 or type(slot) ~= 'number' then return false end
    if type(inv) ~= 'table' or inv.type ~= 'player' then return false end

    local base = normalSlotCount()

    return slot > base and slot <= base + count
end

---Definition of the equipment slot occupying `slot`, if any.
---@param inv table?
---@param slot any
---@return table?
function Grid.getEquipSlotDef(inv, slot)
    if not Grid.isEquipSlot(inv, slot) then return end

    local slots = Grid.getEquipSlots()

    return slots and slots[slot - normalSlotCount()]
end

---@param inv table?
---@param slot any
---@param item table? item definition
---@return boolean, string?
function Grid.canEquip(inv, slot, item)
    local def = Grid.getEquipSlotDef(inv, slot)

    if not def then return false, 'invalid_slot' end
    if type(item) ~= 'table' then return false, 'invalid_item' end

    local clothing = item.clothing

    if type(clothing) == 'string' then
        if clothing == def.name then return true end
    elseif type(clothing) == 'table' then
        for i = 1, #clothing do
            if clothing[i] == def.name then return true end
        end
    end

    return false, 'cannot_equip'
end

---Number of slots that belong to the item grid, i.e. excluding equipment slots.
---@param inv table?
---@return number
function Grid.getBaseSlots(inv)
    if type(inv) ~= 'table' then return 0 end

    local total = tonumber(inv.slots) or 0

    if total < 1 then return 0 end

    if inv.type == 'player' and Grid.getEquipCount() > 0 then
        local base = normalSlotCount()

        return total < base and total or base
    end

    return total
end

local resolveItem

---Inject the item lookup used to size items already sitting in an inventory.
---@param fn fun(name: string): table?
function Grid.setItemResolver(fn)
    resolveItem = fn
end

---@param name any
---@return table?
function Grid.getItem(name)
    if not resolveItem or type(name) ~= 'string' then return end

    return resolveItem(name)
end

---Footprint of an item in grid cells. Rotation is only honoured for non-stackable items -
---writing `metadata.rotated` onto a stackable item would stop it merging with its own kind.
---@param item table? item definition (anything carrying `grid` and `stack`)
---@param metadata table?
---@return number width, number height
function Grid.getItemSize(item, metadata)
    local width, height = 1, 1
    local isTable = type(item) == 'table'

    if isTable and type(item.grid) == 'table' then
        local size = item.grid
        width = tonumber(size[1] or size.width) or 1
        height = tonumber(size[2] or size.height) or 1
    end

    width = floor(width)
    height = floor(height)

    local columns = Grid.getColumns()

    if width < 1 then width = 1 elseif width > columns then width = columns end
    if height < 1 then height = 1 elseif height > MAX_HEIGHT then height = MAX_HEIGHT end

    if isTable and not item.stack and type(metadata) == 'table' and metadata.rotated then
        return height, width
    end

    return width, height
end

---@param slot number 1-based slot index
---@param cols? number
---@return number x, number y both 0-based
function Grid.getCoords(slot, cols)
    cols = cols or Grid.getColumns()

    local index = slot - 1

    return index % cols, floor(index / cols)
end

---@param x number 0-based column
---@param y number 0-based row
---@param cols? number
---@return number slot
function Grid.getSlot(x, y, cols)
    cols = cols or Grid.getColumns()

    return y * cols + x + 1
end

---@class GridLayout
---@field cols number
---@field rows number
---@field slots number grid slot count, equipment slots excluded
---@field occupied table<number, true>

---An empty layout, used when packing a freshly generated inventory.
---@param slots? number pass nil/0 when the eventual slot count is unknown
---@return GridLayout
function Grid.newLayout(slots)
    local cols = Grid.getColumns()

    slots = tonumber(slots) or 0

    if slots < 0 then slots = 0 end

    return {
        cols = cols,
        rows = ceil(slots / cols),
        slots = floor(slots),
        occupied = {}
    }
end

---Flag every cell covered by an item anchored at `slot`.
---@param layout GridLayout
---@param slot number
---@param width number
---@param height number
function Grid.mark(layout, slot, width, height)
    local cols = layout.cols
    local x, y = Grid.getCoords(slot, cols)

    for dy = 0, height - 1 do
        for dx = 0, width - 1 do
            if x + dx < cols then
                layout.occupied[(y + dy) * cols + x + dx + 1] = true
            end
        end
    end
end

---@param layout GridLayout
---@param slot number
---@param width number
---@param height number
---@param unbounded? boolean allow rows past the layout's slot count
---@return boolean, string?
function Grid.fits(layout, slot, width, height, unbounded)
    if type(slot) ~= 'number' or slot < 1 or slot % 1 ~= 0 then return false, 'out_of_bounds' end
    if not unbounded and slot > layout.slots then return false, 'out_of_bounds' end

    local cols = layout.cols
    local x, y = Grid.getCoords(slot, cols)

    if x + width > cols then return false, 'no_space' end

    for dy = 0, height - 1 do
        for dx = 0, width - 1 do
            local cell = (y + dy) * cols + x + dx + 1

            if not unbounded and cell > layout.slots then return false, 'no_space' end
            if layout.occupied[cell] then return false, 'slot_occupied' end
        end
    end

    return true
end

---Cell-occupancy map of an inventory's grid area.
---@param inv table? inventory-like table with `items`, `slots` and `type`
---@param ignoreSlot? number|table<number, true> slot(s) treated as empty
---@return GridLayout
function Grid.getLayout(inv, ignoreSlot)
    local layout = Grid.newLayout(Grid.getBaseSlots(inv))
    local items = type(inv) == 'table' and inv.items or nil

    if type(items) ~= 'table' then return layout end

    local ignoreTable = type(ignoreSlot) == 'table' and ignoreSlot or nil
    local slots = layout.slots

    for slot, data in pairs(items) do
        if type(slot) == 'number' and type(data) == 'table' and slot >= 1 and slot <= slots then
            local ignored = ignoreTable and ignoreTable[slot] or ignoreSlot == slot

            if not ignored then
                local width, height = Grid.getItemSize(Grid.getItem(data.name), data.metadata)

                Grid.mark(layout, slot, width, height)
            end
        end
    end

    return layout
end

---@param inv table?
---@param slot any
---@param width number
---@param height number
---@param ignoreSlot? number|table<number, true>
---@return boolean, string?
function Grid.canPlace(inv, slot, width, height, ignoreSlot)
    if not Grid.isSlotId(slot, Grid.getBaseSlots(inv)) then return false, 'out_of_bounds' end
    if not Grid.isGridLayout() then return true end

    return Grid.fits(Grid.getLayout(inv, ignoreSlot), slot, width, height)
end

---First slot an item of this footprint fits in.
---@param inv table?
---@param width number
---@param height number
---@param ignoreSlot? number|table<number, true>
---@return number?
function Grid.findSlot(inv, width, height, ignoreSlot)
    local layout = Grid.getLayout(inv, ignoreSlot)

    for slot = 1, layout.slots do
        if Grid.fits(layout, slot, width, height) then return slot end
    end
end

---How many further copies of an item of this footprint could be placed.
---@param inv table?
---@param width number
---@param height number
---@return number
function Grid.countPlacements(inv, width, height)
    local layout = Grid.getLayout(inv)
    local count = 0

    for slot = 1, layout.slots do
        if Grid.fits(layout, slot, width, height) then
            Grid.mark(layout, slot, width, height)
            count += 1
        end
    end

    return count
end

---@param layout GridLayout
---@param width number
---@param height number
---@return number slot
function Grid.claim(layout, width, height)
    if width > layout.cols then width = layout.cols end

    local slot

    for i = 1, layout.slots do
        if Grid.fits(layout, i, width, height) then
            slot = i
            break
        end
    end

    if not slot then
        slot = layout.slots + 1

        while not Grid.fits(layout, slot, width, height, true) do
            slot += 1
        end
    end

    Grid.mark(layout, slot, width, height)

    return slot
end

return Grid
