import React, { RefObject, useMemo, useRef } from 'react';
import { DragLayerMonitor, useDragLayer, XYCoord } from 'react-dnd';
import { getItemSize } from '../../helpers';
import useRotateKey from '../../hooks/useRotateKey';
import { isGridLayout } from '../../store/uiConfig';
import { DragSource } from '../../typings';

interface DragLayerProps {
  data: DragSource;
  currentOffset: XYCoord | null;
  isDragging: boolean;
}

const subtract = (a: XYCoord, b: XYCoord): XYCoord => {
  return {
    x: a.x - b.x,
    y: a.y - b.y,
  };
};

const calculateParentOffset = (monitor: DragLayerMonitor): XYCoord => {
  const client = monitor.getInitialClientOffset();
  const source = monitor.getInitialSourceClientOffset();
  if (client === null || source === null || client.x === undefined || client.y === undefined) {
    return { x: 0, y: 0 };
  }
  return subtract(client, source);
};

export const calculatePointerPosition = (monitor: DragLayerMonitor, childRef: RefObject<Element>): XYCoord | null => {
  const offset = monitor.getClientOffset();
  if (offset === null) {
    return null;
  }

  if (!childRef.current || !childRef.current.getBoundingClientRect) {
    return subtract(offset, calculateParentOffset(monitor));
  }

  const bb = childRef.current.getBoundingClientRect();
  const middle = { x: bb.width / 2, y: bb.height / 2 };
  return subtract(offset, middle);
};

const readCellMetrics = (): { cell: string; gap: string } => {
  const grid = document.querySelector('.spatial-grid-cells');
  const styles = getComputedStyle(grid ?? document.documentElement);

  return {
    cell: styles.getPropertyValue('--ox-cell').trim() || 'var(--ox-cell)',
    gap: styles.getPropertyValue('--ox-cell-gap').trim() || 'var(--ox-cell-gap)',
  };
};

const span = (count: number, cell: string, gap: string): string =>
  count <= 1 ? cell : `calc(${cell} * ${count} + ${gap} * ${count - 1})`;

const DragPreview: React.FC = () => {
  const element = useRef<HTMLDivElement>(null);

  const { data, isDragging, currentOffset } = useDragLayer<DragLayerProps>((monitor) => ({
    data: monitor.getItem(),
    currentOffset: calculatePointerPosition(monitor, element),
    isDragging: monitor.isDragging(),
  }));

  const rotated = useRotateKey(isDragging && data?.item ? data : null);

  const footprint = useMemo(() => {
    if (!isGridLayout() || !isDragging || !data?.item?.name) return;

    const [width, height] = getItemSize({
      slot: data.item.slot,
      name: data.item.name,
      metadata: { rotated },
    });

    const { cell, gap } = readCellMetrics();

    return { width: span(width, cell, gap), height: span(height, cell, gap) };
  }, [isDragging, data?.item?.name, data?.item?.slot, rotated]);

  return (
    <>
      {isDragging && currentOffset && data.item && (
        <div
          className={`item-drag-preview${footprint ? ' item-drag-preview-grid' : ''}`}
          ref={element}
          style={{
            transform: `translate(${currentOffset.x}px, ${currentOffset.y}px)`,
            backgroundImage: data.image,
            ...(footprint ? { width: footprint.width, height: footprint.height } : null),
          }}
        />
      )}
    </>
  );
};

export default DragPreview;
