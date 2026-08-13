import React, { useState } from 'react';
import ClothingSlot from './ClothingSlot';
import BodySilhouette, { REGION_FOR_CATEGORY } from '../utils/BodySilhouette';
import { UiConfig } from '../../store/uiConfig';

const ClothingPanel: React.FC = () => {
  const { enabled, slots } = UiConfig.clothing;
  const mode = (UiConfig as { pedPreview?: { mode?: string } }).pedPreview?.mode ?? 'silhouette';
  const [hovered, setHovered] = useState<string | null>(null);

  if (!enabled || slots.length === 0) return null;

  const configuredLeft = slots.filter((def) => def.side === 'left');
  const configuredRight = slots.filter((def) => def.side !== 'left');
  const lopsided = configuredLeft.length === 0 || configuredRight.length === 0;
  const half = Math.ceil(slots.length / 2);
  const left = lopsided ? slots.slice(0, half) : configuredLeft;
  const right = lopsided ? slots.slice(half) : configuredRight;

  const column = (defs: typeof slots, side: 'left' | 'right') => (
    <div className={`clothes-col ${side}`}>
      {defs.map((def) => (
        <div
          key={`cloth-${def.index}`}
          className="clothes-slot-wrap"
          onMouseEnter={() => setHovered(REGION_FOR_CATEGORY[def.name] || null)}
          onMouseLeave={() => setHovered(null)}
        >
          <ClothingSlot def={def} />
        </div>
      ))}
    </div>
  );

  return (
    <div className="clothes">
      {column(left, 'left')}

      <div className={`ped-gap${mode === 'silhouette' ? ' ped-gap-silhouette' : ''}`}>
        {mode === 'silhouette' && <BodySilhouette highlight={hovered} />}
      </div>

      {column(right, 'right')}
    </div>
  );
};

export default React.memo(ClothingPanel);
