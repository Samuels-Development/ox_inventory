import React, { useCallback, useMemo, useRef } from 'react';
import { useDrag, useDragDropManager, useDrop } from 'react-dnd';
import { useAppDispatch, useAppSelector } from '../../store';
import { ClothingSlotDef, DragSource, InventoryType, Slot, SlotWithItem } from '../../typings';
import { canEquipItem, getItemRarityKey, getItemUrl, isSlotWithItem } from '../../helpers';
import { UiConfig } from '../../store/uiConfig';
import { onBuy } from '../../dnd/onBuy';
import { onCraft } from '../../dnd/onCraft';
import { onDrop } from '../../dnd/onDrop';
import { onUse } from '../../dnd/onUse';
import useNuiEvent from '../../hooks/useNuiEvent';
import { ItemsPayload } from '../../reducers/refreshSlots';
import { closeTooltip, openTooltip } from '../../store/tooltip';
import { openContextMenu } from '../../store/contextMenu';
import { getClothingIcon } from '../utils/icons/ClothingIcons';
import ItemImage from '../utils/ItemImage';
import { getBooleanPref } from '../../store/preferences';

interface ClothingSlotProps {
  def: ClothingSlotDef;
}

const ClothingSlot: React.FC<ClothingSlotProps> = ({ def }) => {
  const manager = useDragDropManager();
  const dispatch = useAppDispatch();
  const timerRef = useRef<number | null>(null);

  const inventoryId = useAppSelector((state) => state.inventory.leftInventory.id);
  const storedItem = useAppSelector((state) => state.inventory.leftInventory.items[def.index - 1]) as Slot | undefined;

  const item = useMemo<Slot>(() => storedItem ?? { slot: def.index }, [storedItem, def.index]);

  const canDrag = useCallback(() => isSlotWithItem(item), [item]);

  const [{ isDragging }, drag] = useDrag<DragSource, void, { isDragging: boolean }>(
    () => ({
      type: 'SLOT',
      collect: (monitor) => ({
        isDragging: monitor.isDragging(),
      }),
      item: () =>
        isSlotWithItem(item)
          ? {
              inventory: InventoryType.PLAYER,
              item: {
                name: item.name,
                slot: item.slot,
              },
              image: item?.name && `url(${getItemUrl(item) || 'none'}`,
            }
          : null,
      canDrag,
    }),
    [item, canDrag]
  );

  const [{ isOver, canDrop }, drop] = useDrop<DragSource, void, { isOver: boolean; canDrop: boolean }>(
    () => ({
      accept: 'SLOT',
      collect: (monitor) => ({
        isOver: monitor.isOver(),
        canDrop: monitor.canDrop(),
      }),
      drop: (source) => {
        dispatch(closeTooltip());

        const target = { inventory: InventoryType.PLAYER, item: { slot: def.index } };

        switch (source.inventory) {
          case InventoryType.SHOP:
            onBuy(source, target);
            break;
          case InventoryType.CRAFTING:
            onCraft(source, target);
            break;
          default:
            onDrop(source, target);
            break;
        }
      },
      canDrop: (source) =>
        (source.item.slot !== def.index || source.inventory !== InventoryType.PLAYER) &&
        canEquipItem(source.item.name, def),
    }),
    [def, dispatch]
  );

  useNuiEvent('refreshSlots', (data: { items?: ItemsPayload | ItemsPayload[] }) => {
    if (!isDragging && !data.items) return;
    if (!Array.isArray(data.items)) return;

    const itemSlot = data.items.find(
      (dataItem) => dataItem.item.slot === def.index && dataItem.inventory === inventoryId
    );

    if (!itemSlot) return;

    manager.dispatch({ type: 'dnd-core/END_DRAG' });
  });

  const connectRef = (element: HTMLDivElement | null) => drag(drop(element));

  const handleContext = (event: React.MouseEvent<HTMLDivElement>) => {
    event.preventDefault();
    if (!isSlotWithItem(item)) return;

    dispatch(openContextMenu({ item, coords: { x: event.clientX, y: event.clientY } }));
  };

  const handleClick = (event: React.MouseEvent<HTMLDivElement>) => {
    dispatch(closeTooltip());
    if (timerRef.current) clearTimeout(timerRef.current);
    if (!isSlotWithItem(item)) return;

    if (event.ctrlKey) {
      onDrop({ item, inventory: InventoryType.PLAYER });
    } else if (event.altKey) {
      onUse(item);
    }
  };

  const handleMouseEnter = () => {
    if (!isSlotWithItem(item)) return;
    if (!getBooleanPref('showTooltips')) return;

    timerRef.current = window.setTimeout(() => {
      dispatch(openTooltip({ item, inventoryType: InventoryType.PLAYER }));
    }, 500) as unknown as number;
  };

  const handleMouseLeave = () => {
    dispatch(closeTooltip());
    if (timerRef.current) {
      clearTimeout(timerRef.current);
      timerRef.current = null;
    }
  };

  const isEmpty = !isSlotWithItem(item);
  const Icon = getClothingIcon(def.name);

  const rarityKey = isEmpty ? undefined : getItemRarityKey(item);
  const rarityColor =
    rarityKey && rarityKey !== UiConfig.rarity.default
      ? `var(--ox-rarity-${rarityKey}, ${UiConfig.rarity.tiers[rarityKey].color})`
      : undefined;

  const style = {
    opacity: isDragging ? 0.4 : undefined,
    ...(rarityColor ? { '--slot-rarity': rarityColor } : {}),
  } as React.CSSProperties;

  const className = [
    'cloth',
    isEmpty ? 'cloth-empty' : '',
    isOver ? (canDrop ? 'cloth-drop-valid' : 'cloth-drop-invalid') : '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <div
      ref={connectRef}
      className={className}
      style={style}
      onContextMenu={handleContext}
      onClick={handleClick}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      {isEmpty ? (
        <>
          <Icon className="cloth-icon" />
          <div className="cloth-label">{def.label}</div>
        </>
      ) : (
        <ItemImage className="cloth-image" src={getItemUrl(item as SlotWithItem)} />
      )}
    </div>
  );
};

export default React.memo(ClothingSlot);
