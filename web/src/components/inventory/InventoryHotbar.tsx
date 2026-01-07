import React, { useState } from 'react';
import { getItemUrl, isSlotWithItem } from '../../helpers';
import useNuiEvent from '../../hooks/useNuiEvent';
import { Items } from '../../store/items';
import WeightBar from '../utils/WeightBar';
import { useAppSelector } from '../../store';
import { selectLeftInventory } from '../../store/inventory';
import { SlotWithItem } from '../../typings';

const InventoryHotbar: React.FC = () => {
  const [hotbarVisible, setHotbarVisible] = useState(false);
  const items = useAppSelector(selectLeftInventory).items.slice(0, 5);

  const [handle, setHandle] = useState<NodeJS.Timeout>();
  useNuiEvent('toggleHotbar', () => {
    if (hotbarVisible) {
      setHotbarVisible(false);
    } else {
      if (handle) clearTimeout(handle);
      setHotbarVisible(true);
      setHandle(setTimeout(() => setHotbarVisible(false), 3000));
    }
  });

  return (
    <div className={`hotbar-wrapper ${hotbarVisible ? 'hotbar-visible' : ''}`}>
      <div className="hotbar-container">
        {items.map((item) => (
          <div
            className={`hotbar-slot ${isSlotWithItem(item) ? '' : 'hotbar-slot-empty'}`}
            key={`hotbar-${item.slot}`}
          >
            {isSlotWithItem(item) ? (
              <div className="hotbar-item-wrapper">
                {/* Noise texture */}
                <div className="hotbar-slot-noise" />

                {/* Slot number - top left */}
                <div className="hotbar-slot-number">{item.slot}</div>

                {/* Count badge - top right */}
                {item.count && item.count > 0 && (
                  <div className="hotbar-slot-count">{item.count}</div>
                )}

                {/* Item image */}
                <img
                  src={getItemUrl(item as SlotWithItem)}
                  alt={item.name}
                  className="hotbar-slot-image"
                  draggable={false}
                />

                {/* Item label */}
                <div className="hotbar-slot-label">
                  {item.metadata?.label ? item.metadata.label : Items[item.name]?.label || item.name}
                </div>

                {/* Durability bar */}
                {item?.durability !== undefined && (
                  <div className="hotbar-slot-durability">
                    <WeightBar percent={item.durability} durability />
                  </div>
                )}
              </div>
            ) : (
              <>
                <div className="hotbar-slot-number">{item.slot}</div>
                <div className="hotbar-empty-icon-wrapper">
                  <div className="hotbar-empty-icon-bg">
                    <svg
                      className="hotbar-empty-icon"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 4v16m8-8H4" />
                    </svg>
                  </div>
                </div>
              </>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default InventoryHotbar;
