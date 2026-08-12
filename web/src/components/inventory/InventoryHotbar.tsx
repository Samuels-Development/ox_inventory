import React, { useCallback, useEffect, useRef, useState, useSyncExternalStore } from 'react';
import { getItemUrl, isSlotWithItem } from '../../helpers';
import useNuiEvent from '../../hooks/useNuiEvent';
import { Items } from '../../store/items';
import WeightBar from '../utils/WeightBar';
import ItemImage from '../utils/ItemImage';
import { useAppSelector } from '../../store';
import { selectLeftInventory } from '../../store/inventory';
import { SlotWithItem } from '../../typings';
import { getBooleanPref, getNumberPref, PREF_CHANGE_EVENT } from '../../store/preferences';

export const HOTBAR_KEYBIND_COUNT = 5;

const subscribeToPrefs = (onStoreChange: () => void) => {
  window.addEventListener(PREF_CHANGE_EVENT, onStoreChange);

  return () => window.removeEventListener(PREF_CHANGE_EVENT, onStoreChange);
};

const readFastSlotCount = (): number => {
  const value = Math.round(getNumberPref('fastSlotCount'));

  if (!Number.isFinite(value) || value < 0) return 0;

  return value > HOTBAR_KEYBIND_COUNT ? HOTBAR_KEYBIND_COUNT : value;
};

export const useFastSlotCount = (): number => useSyncExternalStore(subscribeToPrefs, readFastSlotCount);

const InventoryHotbar: React.FC = () => {
  const [hotbarVisible, setHotbarVisible] = useState(false);
  const fastSlotCount = useFastSlotCount();
  const items = useAppSelector(selectLeftInventory).items.slice(0, fastSlotCount);
  const hideTimer = useRef<number | null>(null);

  const clearHideTimer = useCallback(() => {
    if (hideTimer.current === null) return;

    clearTimeout(hideTimer.current);
    hideTimer.current = null;
  }, []);

  useEffect(() => clearHideTimer, [clearHideTimer]);

  useNuiEvent('toggleHotbar', () => {
    if (getBooleanPref('hotbarAlwaysOn')) return clearHideTimer();

    clearHideTimer();

    if (hotbarVisible) return setHotbarVisible(false);

    setHotbarVisible(true);

    hideTimer.current = window.setTimeout(() => {
      hideTimer.current = null;
      setHotbarVisible(false);
    }, getNumberPref('hotbarTimeout'));
  });

  if (fastSlotCount < 1) return null;

  return (
    <div className={`hotbar-wrapper ${hotbarVisible ? 'hotbar-visible' : ''}`}>
      <div className="hotbar-container">
        {items.map((item) => (
          <div
            className={`hotbar-item-slot ${isSlotWithItem(item) ? '' : 'hotbar-slot-empty'}`}
            key={`hotbar-${item.slot}`}
          >
            <div className="hotbar-slot-noise" />
            <div className="hotbar-slot-number">{item.slot}</div>

            {isSlotWithItem(item) && (
              <div className="hotbar-item-wrapper">
                {item.count !== undefined && item.count > 0 && (
                  <div className="hotbar-slot-count">{item.count}</div>
                )}

                <ItemImage src={getItemUrl(item as SlotWithItem)} className="hotbar-slot-image" />

                <div className="hotbar-slot-label">
                  {item.metadata?.label ? item.metadata.label : Items[item.name]?.label || item.name}
                </div>

                {item?.durability !== undefined && (
                  <div className="hotbar-slot-durability">
                    <WeightBar percent={item.durability} durability />
                  </div>
                )}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default InventoryHotbar;
