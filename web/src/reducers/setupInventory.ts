import { CaseReducer, PayloadAction } from '@reduxjs/toolkit';
import { getItemData, itemDurability } from '../helpers';
import { Items } from '../store/items';
import { createEmptyInventory, Inventory, Slot, State } from '../typings';

const densifyItems = (inventory: Inventory, curTime: number): Slot[] =>
  Array.from(Array(inventory.slots), (_, index) => {
    const item = Object.values(inventory.items).find((item) => item?.slot === index + 1) || {
      slot: index + 1,
    };

    if (!item.name) return item;

    if (typeof Items[item.name] === 'undefined') {
      getItemData(item.name);
    }

    item.durability = itemDurability(item.metadata, curTime);
    return item;
  });

export const setupInventoryReducer: CaseReducer<
  State,
  PayloadAction<{
    leftInventory?: Inventory;
    rightInventory?: Inventory;
    backpackInventory?: Inventory;
  }>
> = (state, action) => {
  const { leftInventory, rightInventory, backpackInventory } = action.payload;
  const curTime = Math.floor(Date.now() / 1000);

  if (leftInventory)
    state.leftInventory = {
      ...leftInventory,
      items: densifyItems(leftInventory, curTime),
    };

  if (rightInventory)
    state.rightInventory = {
      ...rightInventory,
      items: densifyItems(rightInventory, curTime),
    };

  if (backpackInventory) {
    state.backpackInventory = {
      ...backpackInventory,
      items: densifyItems(backpackInventory, curTime),
    };
  } else if (state.backpackInventory.id !== '') {
    state.backpackInventory = createEmptyInventory();
  }

  state.shiftPressed = false;
  state.isBusy = false;
};
