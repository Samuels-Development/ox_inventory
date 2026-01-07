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
            className={`hotbar-slot ${isSlotWithItem(item) ? 'hotbar-slot-filled' : 'hotbar-slot-empty'}`}
            key={`hotbar-${item.slot}`}
          >
            {/* Slot number badge */}
            <div className="hotbar-slot-number">{item.slot}</div>

            {/* Item content */}
            {isSlotWithItem(item) ? (
              <>
                <div
                  className="hotbar-slot-image"
                  style={{
                    backgroundImage: `url(${getItemUrl(item as SlotWithItem)}`,
                  }}
                />
                <div className="hotbar-slot-info">
                  {item.count && item.count > 1 && (
                    <span className="hotbar-slot-count">{item.count}x</span>
                  )}
                </div>
                {item?.durability !== undefined && (
                  <div className="hotbar-slot-durability">
                    <WeightBar percent={item.durability} durability />
                  </div>
                )}
                <div className="hotbar-slot-label">
                  {item.metadata?.label ? item.metadata.label : Items[item.name]?.label || item.name}
                </div>
              </>
            ) : (
              <div className="hotbar-slot-empty-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
                </svg>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default InventoryHotbar;
