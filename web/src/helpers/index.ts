import { ClothingSlotDef, Inventory, InventoryType, ItemData, RarityTier, Slot, SlotWithItem, State } from '../typings';
import { isEqual } from 'lodash';
import { store } from '../store';
import { Items } from '../store/items';
import { imagepath } from '../store/imagepath';
import { isGridLayout, UiConfig } from '../store/uiConfig';
import {
  FAVOURITES_MAX,
  getBooleanPref,
  getEnumPref,
  getListPref,
  isValidFavourite,
  PrefValue,
  setPrefs,
  SORT_MODES,
  SortMode,
} from '../store/preferences';
import { fetchNui } from '../utils/fetchNui';

export const canPurchaseItem = (item: Slot, inventory: { type: Inventory['type']; groups: Inventory['groups'] }) => {
  if (inventory.type !== 'shop' || !isSlotWithItem(item)) return true;

  if (item.count !== undefined && item.count === 0) return false;

  if (item.grade === undefined || !inventory.groups) return true;

  const leftInventory = store.getState().inventory.leftInventory;

  // Shop requires groups but player has none
  if (!leftInventory.groups) return false;

  const reqGroups = Object.keys(inventory.groups);

  if (Array.isArray(item.grade)) {
    for (let i = 0; i < reqGroups.length; i++) {
      const reqGroup = reqGroups[i];

      if (leftInventory.groups[reqGroup] !== undefined) {
        const playerGrade = leftInventory.groups[reqGroup];
        for (let j = 0; j < item.grade.length; j++) {
          const reqGrade = item.grade[j];

          if (playerGrade === reqGrade) return true;
        }
      }
    }

    return false;
  } else {
    for (let i = 0; i < reqGroups.length; i++) {
      const reqGroup = reqGroups[i];
      if (leftInventory.groups[reqGroup] !== undefined) {
        const playerGrade = leftInventory.groups[reqGroup];

        if (playerGrade >= item.grade) return true;
      }
    }

    return false;
  }
};

export const canCraftItem = (item: Slot, inventoryType: string) => {
  if (!isSlotWithItem(item) || inventoryType !== 'crafting') return true;
  if (!item.ingredients) return true;
  const leftInventory = store.getState().inventory.leftInventory;
  const ingredientItems = Object.entries(item.ingredients);

  const remainingItems = ingredientItems.filter((ingredient) => {
    const [item, count] = [ingredient[0], ingredient[1]];
    const globalItem = Items[item];

    if (count >= 1) {
      if (globalItem && globalItem.count >= count) return false;
    }

    const hasItem = leftInventory.items.find((playerItem) => {
      if (isSlotWithItem(playerItem) && playerItem.name === item) {
        if (count < 1) {
          if (playerItem.metadata?.durability >= count * 100) return true;

          return false;
        }
      }
    });

    return !hasItem;
  });

  return remainingItems.length === 0;
};

export const isSlotWithItem = (slot: Slot, strict: boolean = false): slot is SlotWithItem =>
  (slot.name !== undefined && slot.weight !== undefined) ||
  (strict && slot.name !== undefined && slot.count !== undefined && slot.weight !== undefined);

export const canStack = (sourceSlot: Slot, targetSlot: Slot) =>
  sourceSlot.name === targetSlot.name && isEqual(sourceSlot.metadata, targetSlot.metadata);

export const OTHER_PLAYER_INVENTORY_TYPE = 'otherplayer';

export const hasPlayerSlotLayout = (type: Inventory['type']): boolean =>
  type === InventoryType.PLAYER || type === OTHER_PLAYER_INVENTORY_TYPE;

export const getBaseSlotCount = (inventory: Pick<Inventory, 'slots' | 'type'>): number => {
  let count = Math.max(0, Math.floor(inventory.slots) || 0);

  if (!hasPlayerSlotLayout(inventory.type)) return count;

  if (UiConfig.clothing.enabled) {
    const defs = UiConfig.clothing.slots;

    for (let i = 0; i < defs.length; i++) {
      const index = defs[i].index;

      if (index > 0 && index - 1 < count) count = index - 1;
    }
  }

  return count;
};

export const hasFastSlotBindings = (type: Inventory['type']): boolean =>
  UiConfig.hotbar.enabled && UiConfig.hotbar.count > 0 && type === InventoryType.PLAYER;

export const getFastSlotItems = (items: Slot[], bindings: readonly number[]): Slot[] => {
  const { count } = UiConfig.hotbar;
  const slots: Slot[] = [];

  for (let i = 0; i < count; i++) {
    const slot = bindings[i];
    const item = slot ? items[slot - 1] : undefined;

    slots.push(item?.name ? item : { slot: 0 });
  }

  return slots;
};

export const findAvailableSlot = (item: Slot, data: ItemData, items: Slot[]) => {
  if (!data.stack) return items.find((target) => target.name === undefined);

  const stackableSlot = items.find((target) => target.name === item.name && isEqual(target.metadata, item.metadata));

  return stackableSlot || items.find((target) => target.name === undefined);
};

export const resolveInventoryPanel = (state: State, type: Inventory['type']): Inventory => {
  if (type === InventoryType.PLAYER) return state.leftInventory;
  if (type === InventoryType.BACKPACK) return state.backpackInventory;
  if (type === InventoryType.CONTAINER) return state.containerInventory;

  return state.rightInventory;
};

export const getTargetInventory = (
  state: State,
  sourceType: Inventory['type'],
  targetType?: Inventory['type']
): { sourceInventory: Inventory; targetInventory: Inventory } => ({
  sourceInventory: resolveInventoryPanel(state, sourceType),
  targetInventory: targetType
    ? resolveInventoryPanel(state, targetType)
    : sourceType === InventoryType.PLAYER
    ? state.rightInventory
    : state.leftInventory,
});

export const itemDurability = (metadata: any, curTime: number) => {
  // sorry dunak
  // it's ok linden i fix inventory
  if (metadata?.durability === undefined) return;

  let durability = metadata.durability;

  if (durability > 100 && metadata.degrade)
    durability = ((metadata.durability - curTime) / (60 * metadata.degrade)) * 100;

  if (durability < 0) durability = 0;

  return durability;
};

export const getTotalWeight = (items: Inventory['items']) =>
  items.reduce((totalWeight, slot) => (isSlotWithItem(slot) ? totalWeight + slot.weight : totalWeight), 0);

export const isContainer = (inventory: Inventory) => inventory.type === InventoryType.CONTAINER;

export const getItemData = async (itemName: string) => {
  const resp: ItemData | null = await fetchNui('getItemData', itemName);

  if (resp?.name) {
    Items[itemName] = resp;
    return resp;
  }
};

export const getItemUrl = (item: string | SlotWithItem) => {
  const isObj = typeof item === 'object';

  if (isObj) {
    if (!item.name) return;

    const metadata = item.metadata;

    // @todo validate urls and support webp
    if (metadata?.imageurl) return `${metadata.imageurl}`;
    if (metadata?.image) return `${imagepath}/${metadata.image}.png`;
  }

  const itemName = isObj ? (item.name as string) : item;
  const itemData = Items[itemName];

  if (!itemData) return `${imagepath}/${itemName}.png`;
  if (itemData.image) return itemData.image;

  itemData.image = `${imagepath}/${itemName}.png`;

  return itemData.image;
};

export const getItemRarityKey = (item: Slot | SlotWithItem): string | undefined => {
  if (!UiConfig.rarity.enabled || !item.name) return;

  const tierName = Items[item.name]?.rarity || UiConfig.rarity.default;

  return tierName && UiConfig.rarity.tiers[tierName] ? tierName : undefined;
};

export const getItemRarity = (item: Slot | SlotWithItem): RarityTier | undefined => {
  const tierName = getItemRarityKey(item);

  return tierName ? UiConfig.rarity.tiers[tierName] : undefined;
};

export const getItemSize = (item: Slot): [number, number] => {
  const grid = item.name ? Items[item.name]?.grid : undefined;
  const width = Math.max(1, Math.floor(Number(grid?.[0]) || 1));
  const height = Math.max(1, Math.floor(Number(grid?.[1]) || 1));

  return item.metadata?.rotated ? [height, width] : [width, height];
};

export const getClothingSlotDef = (slotIndex: number): ClothingSlotDef | undefined => {
  if (!UiConfig.clothing.enabled) return;

  return UiConfig.clothing.slots.find((slotDef) => slotDef.index === slotIndex);
};

export const canEquipItem = (itemName: string | undefined, def: ClothingSlotDef): boolean => {
  if (!itemName) return false;

  const clothing = Items[itemName]?.clothing;

  if (!clothing) return false;

  return Array.isArray(clothing) ? clothing.includes(def.name) : clothing === def.name;
};

export const canRotateItem = (itemName: string | undefined): boolean => {
  if (!itemName || !UiConfig.grid.allowRotate || !isGridLayout()) return false;

  const itemData = Items[itemName];

  if (!itemData || itemData.stack !== false || !itemData.grid) return false;

  return itemData.grid[0] !== itemData.grid[1];
};

export const getGridOccupancy = (items: Slot[], cols: number, rows: number): (number | null)[] => {
  const cells: (number | null)[] = new Array(Math.max(0, cols * rows)).fill(null);

  for (let i = 0; i < items.length; i++) {
    const item = items[i];

    if (!item?.name) continue;

    const anchor = item.slot - 1;

    if (anchor < 0) continue;

    const anchorX = anchor % cols;
    const anchorY = Math.floor(anchor / cols);

    if (anchorY >= rows) continue;

    const [width, height] = getItemSize(item);

    for (let y = anchorY; y < anchorY + height && y < rows; y++) {
      for (let x = anchorX; x < anchorX + width && x < cols; x++) {
        cells[y * cols + x] = item.slot;
      }
    }
  }

  return cells;
};

export const findAvailableGridSlot = (
  item: Slot,
  data: ItemData,
  items: Slot[],
  cols: number,
  rows: number,
  cells: number = cols * rows
): number | undefined => {
  if (data.stack) {
    const stackableSlot = items.find((target) => target.name === item.name && isEqual(target.metadata, item.metadata));

    if (stackableSlot) return stackableSlot.slot;
  }

  const [width, height] = getItemSize(item);
  const occupancy = getGridOccupancy(items, cols, rows);

  for (let y = 0; y + height <= rows; y++) {
    for (let x = 0; x + width <= cols; x++) {
      let fits = true;

      for (let dy = 0; dy < height && fits; dy++) {
        for (let dx = 0; dx < width; dx++) {
          const cell = (y + dy) * cols + (x + dx);

          if (cell >= cells || occupancy[cell] !== null) {
            fits = false;
            break;
          }
        }
      }

      if (fits) return y * cols + x + 1;
    }
  }

  return undefined;
};


export { PREF_CHANGE_EVENT } from '../store/preferences';

const PREF_SAVE_DEBOUNCE = 400;

type PrefSaveListener = (saved: boolean) => void;

let prefSaveTimer: number | undefined;
let pendingPrefs: Record<string, PrefValue> | undefined;
let pendingListeners: PrefSaveListener[] = [];

export const persistPrefs = (partial: Record<string, PrefValue>, onSaved?: PrefSaveListener): void => {
  pendingPrefs = { ...(pendingPrefs || {}), ...partial };

  if (onSaved) pendingListeners.push(onSaved);

  if (prefSaveTimer !== undefined) clearTimeout(prefSaveTimer);

  prefSaveTimer = window.setTimeout(flushPrefs, PREF_SAVE_DEBOUNCE);
};

export const flushPrefs = (): void => {
  if (prefSaveTimer !== undefined) {
    clearTimeout(prefSaveTimer);
    prefSaveTimer = undefined;
  }

  const prefs = pendingPrefs;
  const listeners = pendingListeners;

  pendingPrefs = undefined;
  pendingListeners = [];

  if (!prefs) return;

  const settle = (saved: boolean) => {
    for (const listener of listeners) {
      try {
        listener(saved);
      } catch {
      }
    }
  };

  try {
    fetchNui<boolean | undefined>('savePrefs', { prefs })
      .then((ok) => settle(!!ok))
      .catch(() => settle(false));
  } catch {
    settle(false);
  }
};

export const getFavourites = (): readonly string[] => getListPref('favourites');

export const isFavouriteItem = (name?: string): boolean =>
  name !== undefined && getFavourites().indexOf(name) !== -1;

export const isFavouritableItem = (name?: string): boolean => isValidFavourite(name);

export const canToggleFavourite = (name?: string): boolean => {
  if (!isFavouritableItem(name)) return false;

  return isFavouriteItem(name) || getFavourites().length < FAVOURITES_MAX;
};

export const toggleFavourite = (name: string): void => {
  if (!isFavouritableItem(name)) return;

  const current = getFavourites();
  const pinned = current.indexOf(name) !== -1;

  if (!pinned && current.length >= FAVOURITES_MAX) return;

  const next = pinned ? current.filter((entry) => entry !== name) : [...current, name];

  setPrefs({ favourites: next });
  persistPrefs({ favourites: next });
};

export const isSortAvailable = (): boolean => !isGridLayout();

export const getSortMode = (): SortMode => {
  const mode = getEnumPref('sortMode');

  return (SORT_MODES as readonly string[]).indexOf(mode) !== -1 ? (mode as SortMode) : 'slot';
};

export const setSortMode = (mode: SortMode): void => {
  setPrefs({ sortMode: mode });
  persistPrefs({ sortMode: mode });
};

export const getSortDescending = (): boolean => getEnumPref('sortDirection') === 'descending';

export const getPinFavourites = (): boolean => getBooleanPref('favouritesFirst');

const slotLabel = (item: Slot): string =>
  (item.metadata?.label || (item.name && Items[item.name]?.label) || item.name || '').toLowerCase();

type SlotComparator = (a: Slot, b: Slot) => number;

const bySlot: SlotComparator = (a, b) => a.slot - b.slot;

const COMPARATORS: Record<SortMode, SlotComparator> = {
  slot: bySlot,
  name: (a, b) => {
    const left = slotLabel(a);
    const right = slotLabel(b);

    return left < right ? -1 : left > right ? 1 : 0;
  },
  weight: (a, b) => (b.weight || 0) - (a.weight || 0),
  rarity: (a, b) => (getItemRarity(b)?.order || 0) - (getItemRarity(a)?.order || 0),
  count: (a, b) => (b.count || 0) - (a.count || 0),
};

const FAVOURITE_RANK = 0;
const ITEM_RANK = 1;
const EMPTY_RANK = 2;

export const sortSlots = (
  slots: Slot[],
  mode: SortMode = getSortMode(),
  favourites: readonly string[] = getFavourites(),
  descending: boolean = getSortDescending()
): Slot[] => {
  if (!isSortAvailable()) return slots;

  const pinning = favourites.length > 0;

  if (mode === 'slot' && !pinning && !descending) return slots;

  const flip = descending ? -1 : 1;

  const compare = COMPARATORS[mode] || bySlot;
  const rank = (item: Slot): number => {
    if (!item.name) return EMPTY_RANK;

    return pinning && favourites.indexOf(item.name) !== -1 ? FAVOURITE_RANK : ITEM_RANK;
  };

  return slots.slice().sort((a, b) => {
    const rankA = rank(a);
    const rankB = rank(b);

    if (rankA !== rankB) return rankA - rankB;
    if (rankA === EMPTY_RANK) return bySlot(a, b);

    const delta = compare(a, b) * flip;

    return delta !== 0 ? delta : bySlot(a, b);
  });
};
