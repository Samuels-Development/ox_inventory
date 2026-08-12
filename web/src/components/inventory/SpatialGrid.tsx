import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { useDragLayer, useDrop } from 'react-dnd';
import { DragSource, Inventory, InventoryType, SlotWithItem } from '../../typings';
import { getGridOccupancy, getTotalWeight, isSlotWithItem } from '../../helpers';
import { useAppDispatch, useAppSelector } from '../../store';
import { Items } from '../../store/items';
import { Locale } from '../../store/locale';
import { fetchNui } from '../../utils/fetchNui';
import { closeTooltip } from '../../store/tooltip';
import { onBuy } from '../../dnd/onBuy';
import { onCraft } from '../../dnd/onCraft';
import { getGridDimensions, onSpatialDrop, resolveSpatialTarget, SpatialTarget } from '../../dnd/onSpatialDrop';
import useRotateKey from '../../hooks/useRotateKey';
import SpatialSlot, { spatialCellStyle } from './SpatialSlot';
import InventoryFilters, { FilterId, InventorySort, matchesFilter, usePanelSortMode } from './InventoryFilters';
import { BagIcon, CloseIcon, GridIcon, SearchIcon, WeightIcon } from '../utils/icons';

const formatWeight = (weight: number): string => {
  if (weight >= 1000) return `${(weight / 1000).toFixed(1)}kg`;

  return `${Math.round(weight)}g`;
};

const getWeightColorClass = (percent: number): string => {
  if (percent >= 100) return 'weight-critical';
  if (percent >= 80) return 'weight-warning';

  return '';
};

const resolveCellDrop = (
  source: DragSource,
  inventory: Inventory,
  cursorCell: number,
  rotated: boolean
): SpatialTarget | undefined => {
  if (!source?.item) return;

  const sameInventory = source.inventory === inventory.type;

  const dropRotated =
    source.inventory === InventoryType.SHOP || source.inventory === InventoryType.CRAFTING
      ? source.rotated === true
      : rotated;

  const target = resolveSpatialTarget(
    source,
    inventory,
    cursorCell,
    dropRotated,
    sameInventory ? source.item.slot : undefined
  );

  if (!target) return;
  if (sameInventory && target.slot === source.item.slot) return;

  return target;
};

interface SpatialCellProps {
  index: number;
  inventory: Inventory;
  rotated: boolean;
  covered: boolean;
  onHover: (index: number) => void;
}

const SpatialCell: React.FC<SpatialCellProps> = ({ index, inventory, rotated, covered, onHover }) => {
  const dispatch = useAppDispatch();

  const [, drop] = useDrop<DragSource, void, unknown>(
    () => ({
      accept: 'SLOT',
      hover: () => onHover(index),
      canDrop: (source) => {
        if (inventory.type === InventoryType.SHOP || inventory.type === InventoryType.CRAFTING) return false;

        const target = resolveCellDrop(source, inventory, index, rotated);

        return target !== undefined && target.valid;
      },
      drop: (source) => {
        const target = resolveCellDrop(source, inventory, index, rotated);

        if (!target || !target.valid) return;

        dispatch(closeTooltip());

        const dropTarget = { inventory: inventory.type, item: { slot: target.slot } };

        switch (source.inventory) {
          case InventoryType.SHOP:
            onBuy(source, dropTarget);
            break;
          case InventoryType.CRAFTING:
            onCraft(source, dropTarget);
            break;
          default:
            onSpatialDrop(source, dropTarget, rotated);
            break;
        }
      },
    }),
    [inventory, index, rotated, onHover, dispatch]
  );

  return <div ref={drop} className={`spatial-cell${covered ? ' spatial-cell-covered' : ''}`} />;
};

const MemoSpatialCell = React.memo(SpatialCell);

const SpatialGrid: React.FC<{ inventory: Inventory; showFilters?: boolean }> = ({ inventory, showFilters }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [activeFilter, setActiveFilter] = useState<FilterId | null>(null);
  const [hoverCell, setHoverCell] = useState<number | null>(null);
  const isBusy = useAppSelector((state) => state.inventory.isBusy);

  const isPlayer = inventory.type === 'player';

  const [sortMode, setSortMode] = usePanelSortMode();

  const weight = useMemo(
    () => (inventory.maxWeight !== undefined ? Math.floor(getTotalWeight(inventory.items) * 1000) / 1000 : 0),
    [inventory.maxWeight, inventory.items]
  );

  const weightPercent = useMemo(
    () => (inventory.maxWeight ? (weight / inventory.maxWeight) * 100 : 0),
    [weight, inventory.maxWeight]
  );

  const itemCount = useMemo(() => inventory.items.filter((item) => item.name).length, [inventory.items]);

  const { cols, rows, cells } = useMemo(() => getGridDimensions(inventory), [inventory.slots, inventory.type]);

  const occupancy = useMemo(() => getGridOccupancy(inventory.items, cols, rows), [inventory.items, cols, rows]);

  const cellsStyle = useMemo(
    () =>
      ({
        gridTemplateColumns: `repeat(${cols}, var(--ox-cell))`,
        '--ox-cell-fit': `calc((50vw - var(--ox-centre-reserve) / 2 - var(--ox-gap-panel) - 2 * var(--ox-spatial-pad) - ${
          cols - 1
        } * var(--ox-cell-gap) - 0.2vh) / ${cols})`,
      } as React.CSSProperties),
    [cols]
  );

  const { dragSource, isDragging } = useDragLayer((monitor) => ({
    dragSource: monitor.getItem() as DragSource | null,
    isDragging: monitor.isDragging(),
  }));

  const rotated = useRotateKey(isDragging ? dragSource : null);

  const [{ isOverGrid }, dropGrid] = useDrop<DragSource, void, { isOverGrid: boolean }>(
    () => ({
      accept: 'SLOT',
      collect: (monitor) => ({ isOverGrid: monitor.isOver() }),
      canDrop: () => false,
    }),
    []
  );

  useEffect(() => {
    if (!isDragging) setHoverCell(null);
  }, [isDragging]);

  const handleHover = useCallback((index: number) => {
    setHoverCell((previous) => (previous === index ? previous : index));
  }, []);

  const preview = useMemo(() => {
    if (!isDragging || !isOverGrid || hoverCell === null || !dragSource?.item) return;

    return resolveCellDrop(dragSource, inventory, hoverCell, rotated);
  }, [isDragging, isOverGrid, hoverCell, dragSource, inventory, rotated]);

  const matches = useMemo(() => {
    if (!searchTerm && !activeFilter) return;

    const lowerSearch = searchTerm.toLowerCase();
    const matched = new Set<number>();

    for (let i = 0; i < inventory.items.length; i++) {
      const item = inventory.items[i];

      if (!item.name) continue;

      const label = item.metadata?.label || Items[item.name]?.label || item.name;
      const matchesSearch =
        !lowerSearch || item.name.toLowerCase().includes(lowerSearch) || label.toLowerCase().includes(lowerSearch);

      if (matchesSearch && (!activeFilter || matchesFilter(item.name, activeFilter))) matched.add(item.slot);
    }

    return matched;
  }, [inventory.items, searchTerm, activeFilter]);

  const items = useMemo(
    () =>
      inventory.items.filter(
        (item): item is SlotWithItem => isSlotWithItem(item) && item.slot > 0 && item.slot <= cells
      ),
    [inventory.items, cells]
  );

  const fallbackTitle = isPlayer
    ? Locale.ui_inventory || 'Inventory'
    : inventory.type === InventoryType.BACKPACK
    ? Locale.ui_backpack || 'Backpack'
    : Locale.ui_other_inventory || 'Other Inventory';

  return (
    <div className="inventory-grid-wrapper" style={{ pointerEvents: isBusy ? 'none' : 'auto' }}>
      <div className="inventory-grid-header-wrapper">
        <div className="panel-icon">{isPlayer ? <GridIcon /> : <BagIcon />}</div>
        <div className="panel-title">{inventory.label || fallbackTitle}</div>
        <div className="panel-description">
          {itemCount} {Locale.ui_items || 'items'}
        </div>
        {inventory.maxWeight !== undefined && inventory.maxWeight > 0 && (
          <div className={`inventory-weight-display ${getWeightColorClass(weightPercent)}`}>
            <WeightIcon />
            <span>
              {formatWeight(weight)} / {formatWeight(inventory.maxWeight)}
            </span>
          </div>
        )}
      </div>

      <div className="inventory-search-wrapper">
        <div className="inventory-search-container">
          <input
            type="text"
            placeholder={Locale.ui_search_items || 'Search items...'}
            value={searchTerm}
            onChange={(event) => setSearchTerm(event.target.value)}
            onClick={(event) => {
              event.stopPropagation();
              (event.target as HTMLInputElement).focus();
            }}
            onMouseDown={(event) => event.stopPropagation()}
            onFocus={() => fetchNui('lockControls', true)}
            onBlur={() => fetchNui('lockControls', false)}
            className="inventory-search-input"
          />
          {searchTerm ? (
            <button
              onClick={(event) => {
                event.stopPropagation();
                setSearchTerm('');
              }}
              onMouseDown={(event) => event.stopPropagation()}
              className="inventory-search-clear"
              type="button"
            >
              <CloseIcon />
            </button>
          ) : (
            <span className="inventory-search-icon">
              <SearchIcon />
            </span>
          )}
        </div>
      </div>

      <InventoryFilters
        active={activeFilter}
        onChange={setActiveFilter}
        showChips={showFilters}
        sort={<InventorySort value={sortMode} onChange={setSortMode} />}
      />

      <div ref={dropGrid} className={`spatial-grid ${isDragging ? 'spatial-grid-dragging' : ''}`}>
        <div className="spatial-grid-cells" style={cellsStyle}>
          {Array.from({ length: cells }, (_, index) => (
            <MemoSpatialCell
              key={`cell-${index}`}
              index={index}
              inventory={inventory}
              rotated={rotated}
              covered={occupancy[index] !== null}
              onHover={handleHover}
            />
          ))}

          {items.map((item) => (
            <SpatialSlot
              key={`${inventory.type}-${inventory.id}-${item.slot}`}
              item={item}
              cols={cols}
              inventoryType={inventory.type}
              inventoryGroups={inventory.groups}
              inventoryId={inventory.id}
              dimmed={matches !== undefined && !matches.has(item.slot)}
            />
          ))}

          {preview && (
            <div
              className={`spatial-ghost ${preview.valid ? 'spatial-drop-valid' : 'spatial-drop-invalid'}`}
              style={spatialCellStyle(
                preview.anchor % cols,
                Math.floor(preview.anchor / cols),
                preview.width,
                preview.height
              )}
            />
          )}
        </div>
      </div>
    </div>
  );
};

export default SpatialGrid;
