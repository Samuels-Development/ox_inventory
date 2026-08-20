import { useSyncExternalStore } from 'react';
import { fetchNui } from '../utils/fetchNui';

export const FAST_SLOT_CHANGE_EVENT = 'ox_inventory:fastslotchange';

let bindings: readonly number[] = [];

const emit = () => window.dispatchEvent(new CustomEvent(FAST_SLOT_CHANGE_EVENT));

export const setFastSlots = (list?: unknown) => {
  bindings = Array.isArray(list) ? list.map((slot) => (typeof slot === 'number' && slot > 0 ? slot : 0)) : [];

  emit();
};

export const getFastSlots = (): readonly number[] => bindings;

export const getFastSlot = (index: number): number | undefined => bindings[index - 1] || undefined;

export const getFastSlotOf = (slot?: number): number | undefined => {
  if (!slot) return undefined;

  const index = bindings.indexOf(slot);

  return index === -1 ? undefined : index + 1;
};

export const assignFastSlot = (index: number, slot?: number) => {
  const next = bindings.slice();

  while (next.length < index) next.push(0);

  if (slot) {
    const existing = next.indexOf(slot);

    if (existing !== -1) next[existing] = 0;
  }

  next[index - 1] = slot ?? 0;
  bindings = next;

  emit();

  fetchNui('setFastSlot', slot ? { index, slot } : { index });
};

const subscribe = (onStoreChange: () => void) => {
  window.addEventListener(FAST_SLOT_CHANGE_EVENT, onStoreChange);

  return () => window.removeEventListener(FAST_SLOT_CHANGE_EVENT, onStoreChange);
};

export const useFastSlots = (): readonly number[] => useSyncExternalStore(subscribe, getFastSlots);
