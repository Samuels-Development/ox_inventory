import React, { useMemo } from 'react';
import InventoryGrid from './InventoryGrid';
import SpatialGrid from './SpatialGrid';
import { useAppSelector } from '../../store';
import { selectRightInventory } from '../../store/inventory';
import { getBaseSlotCount } from '../../helpers';
import { UiConfig } from '../../store/uiConfig';

const RightInventory: React.FC = () => {
  const rightInventory = useAppSelector(selectRightInventory);

  const isSpatial =
    UiConfig.layout === 'grid' && rightInventory.type !== 'shop' && rightInventory.type !== 'crafting';

  const slots = useMemo(() => {
    const baseSlotCount = getBaseSlotCount(rightInventory);

    return baseSlotCount < rightInventory.items.length ? rightInventory.items.slice(0, baseSlotCount) : undefined;
  }, [rightInventory]);

  if (isSpatial) return <SpatialGrid inventory={rightInventory} />;

  return <InventoryGrid inventory={rightInventory} slots={slots} />;
};

export default RightInventory;
