import React, { useCallback, useRef } from 'react';
import { useDrag, useDrop } from 'react-dnd';
import { DragSource, Slot, SlotWithItem } from '../../typings';
import { useAppDispatch } from '../../store';
import WeightBar from '../utils/WeightBar';
import ItemImage from '../utils/ItemImage';
import { Items } from '../../store/items';
import { getItemUrl, isSlotWithItem } from '../../helpers';
import { onDrop } from '../../dnd/onDrop';
import { onUse } from '../../dnd/onUse';
import { closeTooltip, openTooltip } from '../../store/tooltip';
import { openContextMenu } from '../../store/contextMenu';
import { getBooleanPref, getNumberPref } from '../../store/preferences';
import { assignFastSlot } from '../../store/fastSlots';

export const FAST_SLOT_DRAG_TYPE = 'FAST_SLOT';

interface FastSlotDrag {
  index: number;
  slot: number;
  image?: string;
}

interface FastSlotProps {
  index: number;
  item: Slot;
}

const FastSlot: React.FC<FastSlotProps> = ({ index, item }) => {
  const dispatch = useAppDispatch();
  const timerRef = useRef<number | null>(null);
  const hasItem = isSlotWithItem(item);

  const [{ isDragging }, drag] = useDrag<FastSlotDrag, void, { isDragging: boolean }>(
    () => ({
      type: FAST_SLOT_DRAG_TYPE,
      collect: (monitor) => ({ isDragging: monitor.isDragging() }),
      item: () =>
        hasItem ? { index, slot: item.slot, image: `url(${getItemUrl(item as SlotWithItem) || 'none'}` } : null,
      end: (dragged, monitor) => {
        if (!dragged || monitor.didDrop()) return;

        assignFastSlot(dragged.index);
      },
    }),
    [index, item, hasItem]
  );

  const [{ isOver }, drop] = useDrop<DragSource | FastSlotDrag, void, { isOver: boolean }>(
    () => ({
      accept: ['SLOT', FAST_SLOT_DRAG_TYPE],
      collect: (monitor) => ({ isOver: monitor.isOver() }),
      drop: (source) => {
        dispatch(closeTooltip());

        if ('index' in source) {
          if (source.index === index) return;

          const displaced = item.slot || undefined;

          assignFastSlot(index, source.slot);
          assignFastSlot(source.index, displaced);

          return;
        }

        assignFastSlot(index, source.item.slot);
      },
      canDrop: (source) => ('index' in source ? true : source.inventory === 'player'),
    }),
    [index, item]
  );

  const connectRef = useCallback((element: HTMLDivElement | null) => drag(drop(element)), [drag, drop]);

  const handleContext = (event: React.MouseEvent<HTMLDivElement>) => {
    event.preventDefault();

    if (!hasItem) return;

    dispatch(openContextMenu({ item, coords: { x: event.clientX, y: event.clientY } }));
  };

  const handleClick = (event: React.MouseEvent<HTMLDivElement>) => {
    dispatch(closeTooltip());

    if (timerRef.current) clearTimeout(timerRef.current);
    if (!hasItem) return;

    if (event.ctrlKey) return onDrop({ item: item as SlotWithItem, inventory: 'player' });
    if (event.altKey) onUse(item);
  };

  const className = `inventory-slot${hasItem ? '' : ' inventory-slot-empty'}${
    isOver ? ' inventory-slot-hover' : ''
  }`;

  return (
    <div
      ref={connectRef}
      onContextMenu={handleContext}
      onClick={handleClick}
      className={className}
      style={{ opacity: isDragging ? 0.4 : 1.0 }}
    >
      <div className="inventory-slot-number">{index}</div>

      {hasItem && (
        <div
          className="item-slot-wrapper"
          onMouseEnter={() => {
            if (!getBooleanPref('showTooltips')) return;

            timerRef.current = window.setTimeout(() => {
              dispatch(openTooltip({ item, inventoryType: 'player' }));
            }, getNumberPref('tooltipDelay')) as unknown as number;
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

          <ItemImage src={getItemUrl(item as SlotWithItem)} className="inventory-slot-image" />

          <div className="inventory-slot-count">
            <span className="inventory-slot-quantity">
              {item.count ? `${item.count.toLocaleString('en-us')}x` : ''}
            </span>
          </div>

          {item.durability !== undefined && (
            <div className="inventory-slot-durability">
              <WeightBar percent={item.durability} durability />
            </div>
          )}

          <div className="inventory-slot-label">
            {item.metadata?.label ? item.metadata.label : Items[item.name]?.label || item.name}
          </div>
        </div>
      )}
    </div>
  );
};

export default React.memo(FastSlot);
