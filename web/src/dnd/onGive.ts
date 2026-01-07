import { store } from '../store';
import { Slot } from '../typings';
import { fetchNui } from '../utils/fetchNui';

export const onGive = (item: Slot) => {
  const {
    inventory: { itemAmount, leftInventory },
  } = store.getState();

  const sourceItem = leftInventory.items.find((i) => i.slot === item.slot);
  const sourceCount = sourceItem?.count || 1;

  const count = itemAmount === 0 || itemAmount > sourceCount
    ? sourceCount
    : itemAmount;

  fetchNui('giveItem', { slot: item.slot, count: count });
};
