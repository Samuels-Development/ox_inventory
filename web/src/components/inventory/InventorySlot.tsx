import React, { useCallback, useRef } from 'react';
import { DragSource, Inventory, InventoryType, Slot, SlotWithItem } from '../../typings';
import { useDrag, useDragDropManager, useDrop } from 'react-dnd';
import { useAppDispatch } from '../../store';
import WeightBar from '../utils/WeightBar';
import { onDrop } from '../../dnd/onDrop';
import { onBuy } from '../../dnd/onBuy';
import { Items } from '../../store/items';
import { canCraftItem, canPurchaseItem, getItemUrl, isSlotWithItem } from '../../helpers';
import { onUse } from '../../dnd/onUse';
import { Locale } from '../../store/locale';
import { onCraft } from '../../dnd/onCraft';
import useNuiEvent from '../../hooks/useNuiEvent';
import { ItemsPayload } from '../../reducers/refreshSlots';
import { closeTooltip, openTooltip } from '../../store/tooltip';
import { openContextMenu } from '../../store/contextMenu';
import { useMergeRefs } from '@floating-ui/react';

interface SlotProps {
  inventoryId: Inventory['id'];
  inventoryType: Inventory['type'];
  inventoryGroups: Inventory['groups'];
  item: Slot;
}

const InventorySlot: React.ForwardRefRenderFunction<HTMLDivElement, SlotProps> = (
  { item, inventoryId, inventoryType, inventoryGroups },
  ref
) => {
  const manager = useDragDropManager();
  const dispatch = useAppDispatch();
  const timerRef = useRef<number | null>(null);

  const canDrag = useCallback(() => {
    return canPurchaseItem(item, { type: inventoryType, groups: inventoryGroups }) && canCraftItem(item, inventoryType);
  }, [item, inventoryType, inventoryGroups]);

  const [{ isDragging }, drag] = useDrag<DragSource, void, { isDragging: boolean }>(
    () => ({
      type: 'SLOT',
      collect: (monitor) => ({
        isDragging: monitor.isDragging(),
      }),
      item: () =>
        isSlotWithItem(item, inventoryType !== InventoryType.SHOP)
          ? {
              inventory: inventoryType,
              item: {
                name: item.name,
                slot: item.slot,
              },
              image: item?.name && `url(${getItemUrl(item) || 'none'}`,
            }
          : null,
      canDrag,
    }),
    [inventoryType, item]
  );

  const [{ isOver }, drop] = useDrop<DragSource, void, { isOver: boolean }>(
    () => ({
      accept: 'SLOT',
      collect: (monitor) => ({
        isOver: monitor.isOver(),
      }),
      drop: (source) => {
        dispatch(closeTooltip());
        switch (source.inventory) {
          case InventoryType.SHOP:
            onBuy(source, { inventory: inventoryType, item: { slot: item.slot } });
            break;
          case InventoryType.CRAFTING:
            onCraft(source, { inventory: inventoryType, item: { slot: item.slot } });
            break;
          default:
            onDrop(source, { inventory: inventoryType, item: { slot: item.slot } });
            break;
        }
      },
      canDrop: (source) =>
        (source.item.slot !== item.slot || source.inventory !== inventoryType) &&
        inventoryType !== InventoryType.SHOP &&
        inventoryType !== InventoryType.CRAFTING,
    }),
    [inventoryType, item]
  );

  useNuiEvent('refreshSlots', (data: { items?: ItemsPayload | ItemsPayload[] }) => {
    if (!isDragging && !data.items) return;
    if (!Array.isArray(data.items)) return;

    const itemSlot = data.items.find(
      (dataItem) => dataItem.item.slot === item.slot && dataItem.inventory === inventoryId
    );

    if (!itemSlot) return;

    manager.dispatch({ type: 'dnd-core/END_DRAG' });
  });

  const connectRef = (element: HTMLDivElement) => drag(drop(element));

  const handleContext = (event: React.MouseEvent<HTMLDivElement>) => {
    event.preventDefault();
    if (inventoryType !== 'player' || !isSlotWithItem(item)) return;

    dispatch(openContextMenu({ item, coords: { x: event.clientX, y: event.clientY } }));
  };

  const handleClick = (event: React.MouseEvent<HTMLDivElement>) => {
    dispatch(closeTooltip());
    if (timerRef.current) clearTimeout(timerRef.current);
    if (event.ctrlKey && isSlotWithItem(item) && inventoryType !== 'shop' && inventoryType !== 'crafting') {
      onDrop({ item: item, inventory: inventoryType });
    } else if (event.altKey && isSlotWithItem(item) && inventoryType === 'player') {
      onUse(item);
    }
  };

  const refs = useMergeRefs([connectRef, ref]);

  const isEmpty = !item?.name;

  return (
    <div
      ref={refs}
      onContextMenu={handleContext}
      onClick={handleClick}
      className={`inventory-slot ${isEmpty ? 'inventory-slot-empty' : ''}`}
      style={{
        filter:
          !isEmpty && (!canPurchaseItem(item, { type: inventoryType, groups: inventoryGroups }) || !canCraftItem(item, inventoryType))
            ? 'brightness(80%) grayscale(100%)'
            : undefined,
        opacity: isDragging ? 0.4 : 1.0,
        border: isOver ? '1px dashed rgba(74, 222, 128, 0.5)' : '',
        backgroundColor: isOver && isEmpty ? 'rgba(74, 222, 128, 0.1)' : undefined,
      }}
    >
      {/* Empty slot + icon */}
      {isEmpty && (
        <div className="empty-slot-icon-wrapper">
          <div className="empty-slot-icon-bg">
            <svg
              className="empty-slot-icon"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 4v16m8-8H4" />
            </svg>
          </div>
        </div>
      )}
      {isSlotWithItem(item) && (
        <div
          className="item-slot-wrapper"
          onMouseEnter={() => {
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
          {/* Noise texture overlay */}
          <div className="inventory-slot-noise" />

          {/* Hotbar slot number - top left */}
          {inventoryType === 'player' && item.slot <= 5 && (
            <div className="inventory-slot-number">{item.slot}</div>
          )}

          {/* Count badge - top right */}
          {item.count && item.count > 0 && (
            <div className="inventory-slot-count">{item.count}</div>
          )}

          {/* Centered item image */}
          <img
            src={getItemUrl(item as SlotWithItem)}
            alt={item.name}
            className="inventory-slot-image"
            draggable={false}
          />

          {/* Item label */}
          <div className="inventory-slot-label">
            {item.metadata?.label ? item.metadata.label : Items[item.name]?.label || item.name}
          </div>

          {/* Durability bar */}
          {inventoryType !== 'shop' && item?.durability !== undefined && (
            <div className="inventory-slot-durability">
              <WeightBar percent={item.durability} durability />
            </div>
          )}

          {/* Shop price */}
          {inventoryType === 'shop' && item?.price !== undefined && item.price > 0 && (
            <div className="inventory-slot-price">
              {item?.currency !== 'money' && item.currency !== 'black_money' && item.currency ? (
                <>
                  <img
                    src={getItemUrl(item.currency)}
                    alt="currency"
                    className="inventory-slot-currency-icon"
                  />
                  <span>{item.price.toLocaleString('en-us')}</span>
                </>
              ) : (
                <span style={{ color: item.currency === 'money' || !item.currency ? '#4ade80' : '#f87171' }}>
                  {Locale.$ || '$'}{item.price.toLocaleString('en-us')}
                </span>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default React.memo(React.forwardRef(InventorySlot));
