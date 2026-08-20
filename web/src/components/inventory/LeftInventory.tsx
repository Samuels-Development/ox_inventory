import React, { useMemo } from 'react';
import InventoryGrid from './InventoryGrid';
import InventorySlot from './InventorySlot';
import SpatialGrid from './SpatialGrid';
import { useAppSelector } from '../../store';
import { selectLeftInventory } from '../../store/inventory';
import { getBaseSlotCount, getFastSlotItems, getTotalWeight, hasFastSlotBindings, isFavouriteItem } from '../../helpers';
import { Locale } from '../../store/locale';
import { UiConfig } from '../../store/uiConfig';
import { LayersIcon } from '../utils/icons';
import { useFastSlotCount } from './InventoryHotbar';
import { usePrefsRevision } from './InventoryFilters';
import FastSlot from './FastSlot';
import { useFastSlots } from '../../store/fastSlots';

const LeftInventory: React.FC = () => {
  const leftInventory = useAppSelector(selectLeftInventory);

  const fastSlotCount = useFastSlotCount();

  usePrefsRevision();

  const isSpatial =
    UiConfig.layout === 'grid' && leftInventory.type !== 'shop' && leftInventory.type !== 'crafting';

  const useBindings = hasFastSlotBindings(leftInventory.type);
  const bindings = useFastSlots();

  const hasFastSlots = leftInventory.type === 'player' && (!isSpatial || useBindings) && fastSlotCount > 0;

  const baseSlotCount = getBaseSlotCount(leftInventory);

  const fastSlots = useMemo(
    () =>
      !hasFastSlots
        ? []
        : useBindings
        ? getFastSlotItems(leftInventory.items, bindings).slice(0, fastSlotCount)
        : leftInventory.items.slice(0, fastSlotCount),
    [hasFastSlots, useBindings, fastSlotCount, leftInventory.items, bindings]
  );

  const remainingSlots = useMemo(
    () => leftInventory.items.slice(hasFastSlots && !useBindings ? fastSlotCount : 0, baseSlotCount),
    [hasFastSlots, useBindings, fastSlotCount, leftInventory.items, baseSlotCount]
  );

  const combinedWeight = useMemo(
    () => (hasFastSlots ? Math.floor(getTotalWeight(leftInventory.items) * 1000) / 1000 : undefined),
    [hasFastSlots, leftInventory.items]
  );

  const fastSlotContent = (
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
        {fastSlots.map((item, index) => {
          const key = useBindings
            ? `fast-${index}`
            : `${leftInventory.type}-${leftInventory.id}-${item.slot}`;

          const slot = useBindings ? (
            <FastSlot key={key} index={index + 1} item={item} />
          ) : (
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
  );

  return (
    <>
      {isSpatial ? (
        <SpatialGrid inventory={leftInventory} showFilters />
      ) : (
        <InventoryGrid
          inventory={leftInventory}
          slots={remainingSlots}
          combinedWeight={combinedWeight}
          showFilters
        />
      )}

      {fastSlots.length > 0 &&
        (useBindings ? <div className="fast-slot-panel">{fastSlotContent}</div> : fastSlotContent)}
    </>
  );
};

export default LeftInventory;
