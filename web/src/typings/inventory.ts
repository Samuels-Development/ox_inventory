import { Slot } from './slot';

export enum InventoryType {
  PLAYER = 'player',
  SHOP = 'shop',
  CONTAINER = 'container',
  CRAFTING = 'crafting',
  BACKPACK = 'backpack',
}

export type Inventory = {
  id: string;
  type: string;
  slots: number;
  items: Slot[];
  maxWeight?: number;
  label?: string;
  groups?: Record<string, number>;
};

export const createEmptyInventory = (): Inventory => ({
  id: '',
  type: '',
  slots: 0,
  maxWeight: 0,
  items: [],
});
