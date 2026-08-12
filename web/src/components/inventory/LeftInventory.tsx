import React, { useMemo } from 'react';
import InventoryGrid from './InventoryGrid';
import InventorySlot from './InventorySlot';
import SpatialGrid from './SpatialGrid';
import { useAppSelector } from '../../store';
import { selectLeftInventory } from '../../store/inventory';
import { getBaseSlotCount, getTotalWeight, isFavouriteItem } from '../../helpers';
import { Locale } from '../../store/locale';
import { UiConfig } from '../../store/uiConfig';
import { LayersIcon } from '../utils/icons';
import { useFastSlotCount } from './InventoryHotbar';
import { usePrefsRevision } from './InventoryFilters';

const LeftInventory: React.FC = () => {
  const leftInventory = useAppSelector(selectLeftInventory);

  const fastSlotCount = useFastSlotCount();

  usePrefsRevision();

  const isSpatial =
    UiConfig.layout === 'grid' && leftInventory.type !== 'shop' && leftInventory.type !== 'crafting';

  const hasFastSlots = leftInventory.type === 'player' && !isSpatial && fastSlotCount > 0;

  const baseSlotCount = getBaseSlotCount(leftInventory);

  const fastSlots = useMemo(
    () => (hasFastSlots ? leftInventory.items.slice(0, fastSlotCount) : []),
    [hasFastSlots, fastSlotCount, leftInventory.items]
  );

  const remainingSlots = useMemo(
    () => leftInventory.items.slice(hasFastSlots ? fastSlotCount : 0, baseSlotCount),
    [hasFastSlots, fastSlotCount, leftInventory.items, baseSlotCount]
  );

  const combinedWeight = useMemo(
    () => (hasFastSlots ? Math.floor(getTotalWeight(leftInventory.items) * 1000) / 1000 : undefined),
    [hasFastSlots, leftInventory.items]
  );

  if (isSpatial) return <SpatialGrid inventory={leftInventory} showFilters />;

  return (
    <>
      <InventoryGrid
        inventory={leftInventory}
        slots={remainingSlots}
        combinedWeight={combinedWeight}
        showFilters
      />

      {fastSlots.length > 0 && (
        <>
          <div className="fast-slot-wrapper">
            <div className="panel-icon">
              <LayersIcon />
            </div>
            <div className="panel-title">{Locale.ui_fastSlots || 'Fast Slots'}</div>
            <div className="panel-description">
              {Locale.ui_fastSlotsDescription || 'Bound to the number keys for quick use.'}
            </div>
          </div>

          <div className="first-five-slots-container">
            {fastSlots.map((item) => {
              const key = `${leftInventory.type}-${leftInventory.id}-${item.slot}`;
              const slot = (
                <InventorySlot
                  key={key}
                  item={item}
                  inventoryType={leftInventory.type}
                  inventoryGroups={leftInventory.groups}
                  inventoryId={leftInventory.id}
                />
              );

              if (!isFavouriteItem(item.name)) return slot;

              return (
                <div key={key} className="inventory-slot-favourite">
                  {slot}
                </div>
              );
            })}
          </div>
        </>
      )}
    </>
  );
};

export default LeftInventory;
