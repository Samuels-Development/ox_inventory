import React, { useCallback, useEffect, useMemo, useRef } from 'react';
import { useDrag, useDragDropManager } from 'react-dnd';
import { DragSource, Inventory, InventoryType, SlotWithItem } from '../../typings';
import { useAppDispatch } from '../../store';
import WeightBar from '../utils/WeightBar';
import ItemImage from '../utils/ItemImage';
import { Items } from '../../store/items';
import {
  canCraftItem,
  canPurchaseItem,
  getItemRarity,
  getItemRarityKey,
  getItemSize,
  getItemUrl,
  isSlotWithItem,
} from '../../helpers';
import { onSpatialDrop } from '../../dnd/onSpatialDrop';
import { onUse } from '../../dnd/onUse';
import useNuiEvent from '../../hooks/useNuiEvent';
import { ItemsPayload } from '../../reducers/refreshSlots';
import { closeTooltip, openTooltip } from '../../store/tooltip';
import { openContextMenu } from '../../store/contextMenu';
import { getBooleanPref } from '../../store/preferences';

const NEUTRAL_RARITY = 'common';

const formatSlotWeight = (weight?: number): string => {
  if (!weight) return '';

  return weight >= 1000
    ? `${(weight / 1000).toLocaleString('en-us', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}kg`
    : `${weight.toLocaleString('en-us', { maximumFractionDigits: 0 })}g`;
};

export const spatialCellStyle = (x: number, y: number, width: number, height: number): React.CSSProperties => ({
  left: `calc((var(--ox-cell) + var(--ox-cell-gap)) * ${x})`,
  top: `calc((var(--ox-cell) + var(--ox-cell-gap)) * ${y})`,
  width: `calc(var(--ox-cell) * ${width} + var(--ox-cell-gap) * ${width - 1})`,
  height: `calc(var(--ox-cell) * ${height} + var(--ox-cell-gap) * ${height - 1})`,
});

const RotateIcon: React.FC = () => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2.5"
    strokeLinecap="round"
    strokeLinejoin="round"
  >
    <path d="M21 12a9 9 0 1 1-3.2-6.9" />
    <path d="M21 3v5h-5" />
  </svg>
);

interface SpatialSlotProps {
  item: SlotWithItem;
  inventoryId: Inventory['id'];
  inventoryType: Inventory['type'];
  inventoryGroups: Inventory['groups'];
  cols: number;
  dimmed: boolean;
}

const SpatialSlot: React.FC<SpatialSlotProps> = ({
  item,
  inventoryId,
  inventoryType,
  inventoryGroups,
  cols,
  dimmed,
}) => {
  const manager = useDragDropManager();
  const dispatch = useAppDispatch();
  const timerRef = useRef<number | null>(null);
  const nodeRef = useRef<HTMLDivElement | null>(null);

  const anchor = item.slot - 1;
  const x = anchor % cols;
  const y = Math.floor(anchor / cols);
  const [width, height] = getItemSize(item);
  const rotated = item.metadata?.rotated === true;

  const canDrag = useCallback(() => {
    return canPurchaseItem(item, { type: inventoryType, groups: inventoryGroups }) && canCraftItem(item, inventoryType);
  }, [item, inventoryType, inventoryGroups]);

  const [{ isDragging }, drag] = useDrag<DragSource, void, { isDragging: boolean }>(
    () => ({
      type: 'SLOT',
      collect: (monitor) => ({
        isDragging: monitor.isDragging(),
      }),
      item: (monitor) => {
        if (!isSlotWithItem(item, inventoryType !== InventoryType.SHOP)) return null;

        const rect = nodeRef.current?.getBoundingClientRect();
        const grab = monitor.getInitialClientOffset();
        let offset = { x: 0, y: 0 };

        if (rect && grab && rect.width > 0 && rect.height > 0) {
          const cellX = Math.floor(((grab.x - rect.left) / rect.width) * width);
          const cellY = Math.floor(((grab.y - rect.top) / rect.height) * height);

          offset = {
            x: Math.min(Math.max(cellX, 0), width - 1),
            y: Math.min(Math.max(cellY, 0), height - 1),
          };
        }

        return {
          inventory: inventoryType,
          item: {
            name: item.name,
            slot: item.slot,
          },
          image: item?.name && `url(${getItemUrl(item) || 'none'}`,
          offset,
          rotated,
        };
      },
      canDrag,
    }),
    [inventoryType, item, width, height, rotated, canDrag]
  );

  useEffect(() => {
    if (!isDragging) return;

    if (timerRef.current) {
      clearTimeout(timerRef.current);
      timerRef.current = null;
    }

    dispatch(closeTooltip());
  }, [isDragging, dispatch]);

  useNuiEvent('refreshSlots', (data: { items?: ItemsPayload | ItemsPayload[] }) => {
    if (!isDragging && !data.items) return;
    if (!Array.isArray(data.items)) return;

    const itemSlot = data.items.find(
      (dataItem) => dataItem.item.slot === item.slot && dataItem.inventory === inventoryId
    );

    if (!itemSlot) return;

    manager.dispatch({ type: 'dnd-core/END_DRAG' });
  });

  const connectRef = (element: HTMLDivElement | null) => {
    nodeRef.current = element;
    drag(element);
  };

  const handleContext = (event: React.MouseEvent<HTMLDivElement>) => {
    event.preventDefault();
    if (inventoryType !== 'player') return;

    dispatch(openContextMenu({ item, coords: { x: event.clientX, y: event.clientY } }));
  };

  const handleClick = (event: React.MouseEvent<HTMLDivElement>) => {
    dispatch(closeTooltip());
    if (timerRef.current) clearTimeout(timerRef.current);

    if (event.ctrlKey && inventoryType !== 'shop' && inventoryType !== 'crafting') {
      onSpatialDrop({ item, inventory: inventoryType }, undefined, rotated);
    } else if (event.altKey && inventoryType === 'player') {
      onUse(item);
    }
  };

  const rarity = useMemo(() => getItemRarity(item), [item]);
  const rarityKey = useMemo(() => getItemRarityKey(item), [item]);
  const hasRarityAccent = rarityKey !== undefined && rarityKey !== NEUTRAL_RARITY;

  const className = `spatial-item inventory-slot${rotated ? ' spatial-item-rotated' : ''}${
    dimmed ? ' spatial-item-dimmed' : ''
  }${rarityKey ? ` rarity-${rarityKey}` : ''}`;

  const style: React.CSSProperties = {
    ...spatialCellStyle(x, y, width, height),
    filter:
      !canPurchaseItem(item, { type: inventoryType, groups: inventoryGroups }) || !canCraftItem(item, inventoryType)
        ? 'brightness(80%) grayscale(100%)'
        : undefined,
    opacity: isDragging ? 0.4 : undefined,
    ...(rarity ? ({ '--slot-rarity': rarity.color } as React.CSSProperties) : null),
  };

  return (
    <div ref={connectRef} onContextMenu={handleContext} onClick={handleClick} className={className} style={style}>
      {hasRarityAccent && <div className="inventory-slot-rarity-glow" />}
      <div
        className="item-slot-wrapper"
        onMouseEnter={() => {
          if (!getBooleanPref('showTooltips')) return;

          timerRef.current = window.setTimeout(() => {
            dispatch(openTooltip({ item, inventoryType }));
          }, 500) as unknown as number;
        }}
        onMouseLeave={() => {
          dispatch(closeTooltip());
          if (timerRef.current) {
            clearTimeout(timerRef.current);
            timerRef.current = null;
          }
        }}
      >
        <div className="inventory-slot-noise" />

        <ItemImage src={getItemUrl(item)} className="inventory-slot-image" />

        {inventoryType === 'player' && item.slot <= 5 && <div className="inventory-slot-number">{item.slot}</div>}

        <div className="inventory-slot-count">
          <span>{formatSlotWeight(item.weight)}</span>
          <span>{item.count ? `${item.count.toLocaleString('en-us')}x` : ''}</span>
        </div>

        {item.durability !== undefined && (
          <div className="inventory-slot-durability">
            <WeightBar percent={item.durability} durability />
          </div>
        )}

        <div className="inventory-slot-label">
          {item.metadata?.label ? item.metadata.label : Items[item.name]?.label || item.name}
        </div>

        {rotated && (
          <div className="spatial-item-rotate-icon">
            <RotateIcon />
          </div>
        )}
      </div>
      {hasRarityAccent && <div className="inventory-slot-rarity-corner" />}
    </div>
  );
};

export default React.memo(SpatialSlot);
