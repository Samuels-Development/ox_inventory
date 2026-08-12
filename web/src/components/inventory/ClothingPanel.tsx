import React, { useState } from 'react';
import ClothingSlot from './ClothingSlot';
import BodySilhouette, { REGION_FOR_CATEGORY } from '../utils/BodySilhouette';
import { UiConfig } from '../../store/uiConfig';

const ClothingPanel: React.FC = () => {
  const { enabled, slots } = UiConfig.clothing;
  const mode = (UiConfig as { pedPreview?: { mode?: string } }).pedPreview?.mode ?? 'silhouette';
  const [hovered, setHovered] = useState<string | null>(null);

  if (!enabled || slots.length === 0) return null;

  const left = slots.filter((def) => def.side === 'left');
  const right = slots.filter((def) => def.side !== 'left');

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
