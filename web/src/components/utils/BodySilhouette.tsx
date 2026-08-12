import React, { useEffect, useState } from 'react';
import { imagepath } from '../../store/imagepath';
import InjuryMarkers from './InjuryMarkers';

export const REGION_FOR_CATEGORY: Record<string, string> = {
  hat: 'head',
  glasses: 'head',
  mask: 'head',
  earpiece: 'head',
  torso: 'torso',
  armour: 'torso',
  backpack: 'torso',
  gloves: 'hands',
  legs: 'legs',
  shoes: 'feet',
};

const REGIONS: Record<string, { top: number; bottom: number }> = {
  head: { top: 0, bottom: 17.5 },
  torso: { top: 17.5, bottom: 47 },
  legs: { top: 47, bottom: 85 },
  feet: { top: 85, bottom: 92 },
};

const HAND_BAND = { top: 44, bottom: 60 };
const HAND_INSET = 62;

interface BodySilhouetteProps {
  highlight?: string | null;
}

const BodySilhouette: React.FC<BodySilhouetteProps> = ({ highlight }) => {
  const src = `${imagepath}/body_anatomy.png`;

  const [litRegion, setLitRegion] = useState<string | null>(highlight ?? null);

  useEffect(() => {
    if (highlight) setLitRegion(highlight);
  }, [highlight]);

  const active = Boolean(highlight);
  const region = litRegion ? REGIONS[litRegion] : undefined;

  const glowClass = `body-figure-glow${active ? '' : ' body-figure-glow-out'}`;

  const layer = (...gradients: string[]): React.CSSProperties => {
    const images = [`url(${src})`, ...gradients];

    return {
      WebkitMaskImage: images.join(', '),
      maskImage: images.join(', '),
      WebkitMaskSize: ['contain', ...gradients.map(() => '100% 100%')].join(', '),
      maskSize: ['contain', ...gradients.map(() => '100% 100%')].join(', '),
      WebkitMaskPosition: images.map(() => 'center').join(', '),
      maskPosition: images.map(() => 'center').join(', '),
      WebkitMaskRepeat: images.map(() => 'no-repeat').join(', '),
      maskRepeat: images.map(() => 'no-repeat').join(', '),
      WebkitMaskComposite: 'source-in',
      maskComposite: 'intersect',
    } as React.CSSProperties;
  };

  const band = (top: number, bottom: number, feather = 5) =>
    `linear-gradient(to bottom, transparent ${top - feather}%, #000 ${top + feather}%,` +
    ` #000 ${bottom - feather}%, transparent ${bottom + feather}%)`;

  const side = (from: 'left' | 'right', edge: number, feather = 6) =>
    from === 'left'
      ? `linear-gradient(to right, #000 ${edge - feather}%, transparent ${edge + feather}%)`
      : `linear-gradient(to left, #000 ${edge - feather}%, transparent ${edge + feather}%)`;

  return (
    <div className="body-figure">
      <img className="body-figure-art" src={src} alt="" draggable={false} />

      {region && (
        <div key={litRegion} className={glowClass} style={layer(band(region.top, region.bottom))} />
      )}

      {litRegion === 'hands' && (
        <>
          <div
            className={glowClass}
            style={layer(band(HAND_BAND.top, HAND_BAND.bottom), side('left', 100 - HAND_INSET))}
          />
          <div
            className={glowClass}
            style={layer(band(HAND_BAND.top, HAND_BAND.bottom), side('right', 100 - HAND_INSET))}
          />
        </>
      )}

      <InjuryMarkers />
    </div>
  );
};

export default React.memo(BodySilhouette);
