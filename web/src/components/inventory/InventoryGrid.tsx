import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Inventory } from '../../typings';
import InventorySlot from './InventorySlot';
import { getTotalWeight } from '../../helpers';
import { useAppSelector } from '../../store';
import { useIntersection } from '../../hooks/useIntersection';
import { Items } from '../../store/items';
import { fetchNui } from '../../utils/fetchNui';

const PAGE_SIZE = 30;

// Search icon component
const SearchIcon: React.FC = () => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
    strokeLinecap="round"
    strokeLinejoin="round"
  >
    <circle cx="11" cy="11" r="8" />
    <path d="m21 21-4.3-4.3" />
  </svg>
);

// X icon component for clear button
const XIcon: React.FC = () => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
    strokeLinecap="round"
    strokeLinejoin="round"
  >
    <path d="M18 6 6 18" />
    <path d="m6 6 12 12" />
  </svg>
);

// Weight/Scale icon component
const WeightIcon: React.FC = () => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    style={{ width: 'calc((0.729vw + 1.296vh) / 2)', height: 'calc((0.729vw + 1.296vh) / 2)' }}
    viewBox="0 0 20 20"
    fill="currentColor"
  >
    <path
      fillRule="evenodd"
      d="M10 2a1 1 0 011 1v1.323l3.954 1.582 1.599-.8a1 1 0 01.894 1.79l-1.233.616 1.738 5.42a1 1 0 01-.285 1.05A3.989 3.989 0 0115 15a3.989 3.989 0 01-2.667-1.019 1 1 0 01-.285-1.05l1.715-5.349L11 6.477V16h2a1 1 0 110 2H7a1 1 0 110-2h2V6.477L6.237 7.582l1.715 5.349a1 1 0 01-.285 1.05A3.989 3.989 0 015 15a3.989 3.989 0 01-2.667-1.019 1 1 0 01-.285-1.05l1.738-5.42-1.233-.617a1 1 0 01.894-1.788l1.599.799L9 4.323V3a1 1 0 011-1z"
      clipRule="evenodd"
    />
  </svg>
);

// Format weight helper
const formatWeight = (weight: number): string => {
  if (weight >= 1000) {
    return `${(weight / 1000).toFixed(1)}kg`;
  }
  return `${Math.round(weight)}g`;
};

// Get weight display color class based on capacity percentage
const getWeightColorClass = (percent: number): string => {
  if (percent >= 100) return 'weight-critical';
  if (percent >= 80) return 'weight-warning';
  return '';
};

const InventoryGrid: React.FC<{ inventory: Inventory }> = ({ inventory }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const weight = useMemo(
    () => (inventory.maxWeight !== undefined ? Math.floor(getTotalWeight(inventory.items) * 1000) / 1000 : 0),
    [inventory.maxWeight, inventory.items]
  );
  const weightPercent = useMemo(
    () => (inventory.maxWeight ? (weight / inventory.maxWeight) * 100 : 0),
    [weight, inventory.maxWeight]
  );
  const [page, setPage] = useState(0);
  const containerRef = useRef(null);
  const { ref, entry } = useIntersection({ threshold: 0.5 });
  const isBusy = useAppSelector((state) => state.inventory.isBusy);

  useEffect(() => {
    if (entry && entry.isIntersecting) {
      setPage((prev) => ++prev);
    }
  }, [entry]);

  // Filter items based on search term
  const filteredItems = useMemo(() => {
    if (!searchTerm) return inventory.items;

    const lowerSearch = searchTerm.toLowerCase();

    return inventory.items.map((item) => {
      if (!item.name) return item; // Empty slot, keep as is

      // Get label from metadata, Items store, or fallback to name
      const itemLabel = item.metadata?.label || Items[item.name]?.label || item.name;

      const matchesSearch =
        item.name.toLowerCase().includes(lowerSearch) ||
        itemLabel.toLowerCase().includes(lowerSearch);

      // If doesn't match, return empty slot placeholder
      if (!matchesSearch) {
        return { ...item, name: undefined, count: undefined, metadata: undefined };
      }

      return item;
    });
  }, [inventory.items, searchTerm]);

  // Count actual items (non-empty slots)
  const itemCount = useMemo(
    () => inventory.items.filter((item) => item.name).length,
    [inventory.items]
  );

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(e.target.value);
  };

  return (
    <div className="inventory-grid-wrapper" style={{ pointerEvents: isBusy ? 'none' : 'auto' }}>
      {/* Header */}
      <div className="inventory-grid-header-wrapper">
        <div style={{ display: 'flex', alignItems: 'center', gap: 'calc((0.417vw + 0.741vh) / 2)' }}>
          <p>{inventory.label || 'Secondary Inventory'}</p>
          <span style={{ fontSize: 'calc((0.625vw + 1.111vh) / 2)', color: 'rgba(107, 114, 128, 1)' }}>
            {itemCount} items
          </span>
        </div>
        {inventory.maxWeight !== undefined && inventory.maxWeight > 0 && (
          <div className={`inventory-weight-display ${getWeightColorClass(weightPercent)}`}>
            <WeightIcon />
            <span>{formatWeight(weight)}/{formatWeight(inventory.maxWeight)}</span>
          </div>
        )}
      </div>

      {/* Search Bar */}
      <div className="inventory-search-wrapper">
        <div className="inventory-search-container">
          <input
            type="text"
            placeholder="Search items..."
            value={searchTerm}
            onChange={handleSearchChange}
            onClick={(e) => {
              e.stopPropagation();
              (e.target as HTMLInputElement).focus();
            }}
            onMouseDown={(e) => e.stopPropagation()}
            onFocus={() => fetchNui('lockControls', true)}
            onBlur={() => fetchNui('lockControls', false)}
            className="inventory-search-input"
          />
          {searchTerm ? (
            <button
              onClick={(e) => {
                e.stopPropagation();
                setSearchTerm('');
              }}
              onMouseDown={(e) => e.stopPropagation()}
              className="inventory-search-clear"
              type="button"
            >
              <XIcon />
            </button>
          ) : (
            <span className="inventory-search-icon">
              <SearchIcon />
            </span>
          )}
        </div>
      </div>

      {/* Grid Container */}
      <div className="inventory-grid-container" ref={containerRef}>
        {filteredItems.slice(0, (page + 1) * PAGE_SIZE).map((item, index) => (
          <InventorySlot
            key={`${inventory.type}-${inventory.id}-${item.slot}`}
            item={item}
            ref={index === (page + 1) * PAGE_SIZE - 1 ? ref : null}
            inventoryType={inventory.type}
            inventoryGroups={inventory.groups}
            inventoryId={inventory.id}
          />
        ))}
      </div>
    </div>
  );
};

export default InventoryGrid;
