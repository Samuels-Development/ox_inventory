import React, { useMemo, useSyncExternalStore } from 'react';
import { InjuryState, getInjuryState, subscribeInjuries } from '../../store/injuries';
import { InjuryPartDef } from '../../typings';

interface Entry {
  label: string;
  severity: number;
}

interface Marker {
  key: string;
  part: InjuryPartDef;
  color: string;
  severity: number;
  entries: Entry[];
}

const FLIP_AT = 50;

const EMPTY: Marker[] = [];

const buildMarkers = (state: InjuryState): Marker[] => {
  const { config, injuries } = state;

  if (!config || injuries.length === 0) return EMPTY;

  const byPart: Record<string, Marker> = {};
  const order: string[] = [];

  for (const injury of injuries) {
    const part = config.parts[injury.part];
    const type = config.types[injury.type];

    if (!part || !type) continue;

    let marker = byPart[injury.part];

    if (!marker) {
      marker = { key: injury.part, part, color: type.color, severity: 0, entries: [] };
      byPart[injury.part] = marker;
      order.push(injury.part);
    }

    marker.entries.push({ label: type.label, severity: type.severity });

    if (type.severity > marker.severity) {
      marker.severity = type.severity;
      marker.color = type.color;
    }
  }

  const markers: Marker[] = [];

  for (const key of order) {
    const marker = byPart[key];

    if (marker.entries.length > 1) marker.entries.sort((a, b) => b.severity - a.severity);

    markers.push(marker);
  }

  return markers;
};

const InjuryMarkers: React.FC = () => {
  const state = useSyncExternalStore(subscribeInjuries, getInjuryState);

  const markers = useMemo(() => {
    try {
      return buildMarkers(state);
    } catch (error) {
      console.error('failed to build injury markers', error);

      return EMPTY;
    }
  }, [state]);

  if (markers.length === 0) return null;

  return (
    <div className="injury-markers">
      {markers.map((marker) => {
        const flip = marker.part.x > FLIP_AT;
        const style = {
          left: `${marker.part.x}%`,
          top: `${marker.part.y}%`,
          '--injury-color': marker.color,
        } as React.CSSProperties;

        return (
          <div
            key={marker.key}
            className={`injury-marker${marker.severity >= 3 ? ' injury-marker-pulse' : ''}`}
            style={style}
          >
            <span className="injury-marker-ring" />
            <span className="injury-marker-dot" />
            {marker.entries.length > 1 && <span className="injury-marker-count">{marker.entries.length}</span>}

            <div className={`injury-tag${flip ? ' injury-tag-flip' : ''}`}>
              <span className="injury-tag-part">{marker.part.label}</span>
              <span className="injury-tag-list">{marker.entries.map((entry) => entry.label).join(', ')}</span>
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default React.memo(InjuryMarkers);
