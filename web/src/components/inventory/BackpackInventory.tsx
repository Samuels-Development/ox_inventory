import React from 'react';
import InventoryGrid from './InventoryGrid';
import SpatialGrid from './SpatialGrid';
import { useAppSelector } from '../../store';
import { hasBackpack, selectBackpackInventory } from '../../store/inventory';
import { UiConfig } from '../../store/uiConfig';

export const useShowBackpack = (): boolean =>
  useAppSelector(
    (state) => hasBackpack(state) && state.inventory.backpackInventory.id !== state.inventory.rightInventory.id
  );

const BackpackInventory: React.FC = () => {
  const backpackInventory = useAppSelector(selectBackpackInventory);
  const show = useShowBackpack();

  if (!show) return null;

  return UiConfig.layout === 'grid' ? (
    <SpatialGrid inventory={backpackInventory} />
  ) : (
    <InventoryGrid inventory={backpackInventory} />
  );
};

export default BackpackInventory;
