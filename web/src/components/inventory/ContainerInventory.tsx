import React from 'react';
import InventoryGrid from './InventoryGrid';
import SpatialGrid from './SpatialGrid';
import { useAppSelector } from '../../store';
import { hasContainer, selectContainerInventory } from '../../store/inventory';
import { UiConfig } from '../../store/uiConfig';

export const useShowContainer = (): boolean =>
  useAppSelector(
    (state) => hasContainer(state) && state.inventory.containerInventory.id !== state.inventory.rightInventory.id
  );

const ContainerInventory: React.FC = () => {
  const containerInventory = useAppSelector(selectContainerInventory);
  const show = useShowContainer();

  if (!show) return null;

  return UiConfig.layout === 'grid' ? (
    <SpatialGrid inventory={containerInventory} />
  ) : (
    <InventoryGrid inventory={containerInventory} />
  );
};

export default ContainerInventory;
