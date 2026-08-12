import {
  canRotateItem,
  canStack,
  findAvailableGridSlot,
  getBaseSlotCount,
  getGridOccupancy,
  getItemSize,
  getTargetInventory,
  isSlotWithItem,
  resolveInventoryPanel,
} from '../helpers';
import { validateMove } from '../thunks/validateItems';
import { store } from '../store';
import { DragSource, DropTarget, Inventory, SlotWithItem } from '../typings';
import { moveSlots, stackSlots, swapSlots } from '../store/inventory';
import { Items } from '../store/items';
import { UiConfig } from '../store/uiConfig';
import { isContainerPanel } from './onDrop';

export interface GridDimensions {
  cols: number;
  rows: number;
  cells: number;
}

export interface SpatialTarget {
  anchor: number;
  slot: number;
  width: number;
  height: number;
  valid: boolean;
}

const clamp = (value: number, min: number, max: number) => (value < min ? min : value > max ? max : value);

export const getGridDimensions = (inventory: Inventory): GridDimensions => {
  const cols = Math.max(1, Math.floor(UiConfig.grid.columns) || 1);
  const cells = getBaseSlotCount(inventory);

  return { cols, rows: Math.ceil(cells / cols), cells };
};

export const getDragItemSize = (source: DragSource, rotated: boolean): [number, number] =>
  getItemSize({ slot: source.item.slot, name: source.item.name, metadata: { rotated } });

export const isBlockedContainerMove = (source: DragSource, targetInventory: Inventory): boolean => {
  if (!source?.item) return false;

  const { inventory: state } = store.getState();
  const sourceSlot = resolveInventoryPanel(state, source.inventory).items[source.item.slot - 1];
  const container = sourceSlot?.metadata?.container;

  if (container === undefined) return false;

  return isContainerPanel(targetInventory.type) || state.rightInventory.id === container;
};

export const resolveSpatialTarget = (
  source: DragSource,
  targetInventory: Inventory,
  cursorCell: number,
  rotated: boolean,
  ignoreSlot?: number
): SpatialTarget | undefined => {
  const { cols, rows, cells } = getGridDimensions(targetInventory);

  if (rows < 1 || cursorCell < 0 || cursorCell >= cols * rows) return;

  const [width, height] = getDragItemSize(source, rotated);

  if (width > cols || height > rows) return;

  const offsetX = clamp(source.offset?.x ?? 0, 0, width - 1);
  const offsetY = clamp(source.offset?.y ?? 0, 0, height - 1);

  const anchorX = clamp((cursorCell % cols) - offsetX, 0, cols - width);
  const anchorY = clamp(Math.floor(cursorCell / cols) - offsetY, 0, rows - height);
  const anchor = anchorY * cols + anchorX;

  const occupancy = getGridOccupancy(targetInventory.items, cols, rows);

  const probe = (probeX: number, probeY: number): { fits: boolean; hit: number[] } => {
    const hit: number[] = [];

    if (probeX < 0 || probeY < 0 || probeX + width > cols || probeY + height > rows) return { fits: false, hit };

    for (let y = probeY; y < probeY + height; y++) {
      for (let x = probeX; x < probeX + width; x++) {
        const cell = y * cols + x;

        if (cell >= cells) return { fits: false, hit };

        const occupant = occupancy[cell];

        if (occupant !== null && occupant !== ignoreSlot && hit.indexOf(occupant) === -1) hit.push(occupant);
      }
    }

    return { fits: true, hit };
  };

  let { fits, hit } = probe(anchorX, anchorY);
  let dropAnchor = anchor;

  if (fits && hit.length === 1 && hit[0] - 1 !== anchor) {
    const swapAnchor = hit[0] - 1;
    const swap = probe(swapAnchor % cols, Math.floor(swapAnchor / cols));

    if (swap.fits) {
      dropAnchor = swapAnchor;
      hit = swap.hit;
    } else {
      fits = false;
    }
  }

  return {
    anchor: dropAnchor,
    slot: dropAnchor + 1,
    width,
    height,
    valid: fits && hit.length <= 1,
  };
};

export const onSpatialDrop = (source: DragSource, target: DropTarget | undefined, rotated: boolean) => {
  const { inventory: state } = store.getState();

  const { sourceInventory, targetInventory } = getTargetInventory(state, source.inventory, target?.inventory);

  const sourceSlot = sourceInventory.items[source.item.slot - 1] as SlotWithItem | undefined;

  if (!sourceSlot?.name) return console.error('Source slot is no longer present!');

  const sourceData = Items[sourceSlot.name];

  if (sourceData === undefined) return console.error(`${sourceSlot.name} item data undefined!`);

  if (sourceSlot.metadata?.container !== undefined) {
    if (isContainerPanel(targetInventory.type))
      return console.error(`Cannot store container ${sourceSlot.name} inside another container`);

    if (state.rightInventory.id === sourceSlot.metadata.container)
      return console.error(`Cannot move container ${sourceSlot.name} when opened`);
  }

  let targetSlot = target ? targetInventory.items[target.item.slot - 1] : undefined;

  if (!target) {
    const { cols, rows, cells } = getGridDimensions(targetInventory);
    const quickSlot = findAvailableGridSlot(sourceSlot, sourceData, targetInventory.items, cols, rows, cells);

    if (quickSlot !== undefined) targetSlot = targetInventory.items[quickSlot - 1];
  }

  if (targetSlot === undefined) return console.error('Target slot undefined!');

  if (targetSlot.metadata?.container !== undefined && state.rightInventory.id === targetSlot.metadata.container)
    return console.error(`Cannot swap item ${sourceSlot.name} with container ${targetSlot.name} when opened`);

  const count =
    state.shiftPressed && sourceSlot.count > 1 && sourceInventory.type !== 'shop'
      ? Math.floor(sourceSlot.count / 2)
      : state.itemAmount === 0 || state.itemAmount > sourceSlot.count
      ? sourceSlot.count
      : state.itemAmount;

  const data = {
    fromSlot: sourceSlot,
    toSlot: targetSlot,
    fromType: sourceInventory.type,
    toType: targetInventory.type,
    count: count,
  };

  const payload: Parameters<typeof validateMove>[0] = {
    fromSlot: sourceSlot.slot,
    toSlot: targetSlot.slot,
    fromType: data.fromType,
    toType: data.toType,
    count: data.count,
  };

  if (canRotateItem(sourceSlot.name)) payload.rotated = rotated;

  store.dispatch(validateMove(payload));

  isSlotWithItem(targetSlot, true)
    ? sourceData.stack && canStack(sourceSlot, targetSlot)
      ? store.dispatch(
          stackSlots({
            ...data,
            toSlot: targetSlot,
          })
        )
      : store.dispatch(
          swapSlots({
            ...data,
            toSlot: targetSlot,
          })
        )
    : store.dispatch(moveSlots(data));
};
