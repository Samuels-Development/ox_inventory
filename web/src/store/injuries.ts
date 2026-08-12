import { Injury, InjuriesConfig, InjuriesMessage, InjuryPartDef, InjuryTypeDef } from '../typings/uiConfig';


const MAX_COLOR_LENGTH = 64;
const MAX_LABEL_LENGTH = 48;
const KEY_PATTERN = /^[A-Za-z0-9_]+$/;
const MAX_KEY_LENGTH = 32;
const MAX_ENTRIES = 64;
const MAX_INJURIES = 128;

const HEX_COLOR = /^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/;
const RGB_COLOR = /^rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)$/;
const RGBA_COLOR = /^rgba\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d*\.?\d+)\s*\)$/;

const inRange = (value: string, max: number): boolean => {
  const number = Number(value);

  return Number.isFinite(number) && number >= 0 && number <= max;
};

export const isInjuryColor = (value: unknown): value is string => {
  if (typeof value !== 'string') return false;
  if (value.length < 4 || value.length > MAX_COLOR_LENGTH) return false;
  if (HEX_COLOR.test(value)) return true;

  const rgb = RGB_COLOR.exec(value);

  if (rgb) return inRange(rgb[1], 255) && inRange(rgb[2], 255) && inRange(rgb[3], 255);

  const rgba = RGBA_COLOR.exec(value);

  if (!rgba) return false;

  return inRange(rgba[1], 255) && inRange(rgba[2], 255) && inRange(rgba[3], 255) && inRange(rgba[4], 1);
};

const isKey = (value: unknown): value is string =>
  typeof value === 'string' && value.length > 0 && value.length <= MAX_KEY_LENGTH && KEY_PATTERN.test(value);

const label = (value: unknown, fallback: string): string => {
  if (typeof value !== 'string' || value.length === 0) return fallback;

  return value.length > MAX_LABEL_LENGTH ? value.slice(0, MAX_LABEL_LENGTH) : value;
};

const clamp = (value: number, min: number, max: number) => (value < min ? min : value > max ? max : value);

const anchor = (value: unknown): number | undefined =>
  typeof value === 'number' && Number.isFinite(value) ? clamp(value, 0, 100) : undefined;

const readPart = (key: string, value: unknown): InjuryPartDef | undefined => {
  if (!value || typeof value !== 'object') return;

  const raw = value as { label?: unknown; x?: unknown; y?: unknown };
  const x = anchor(raw.x);
  const y = anchor(raw.y);

  if (x === undefined || y === undefined) return;

  return { label: label(raw.label, key), x, y };
};

const readType = (key: string, value: unknown): InjuryTypeDef | undefined => {
  if (!value || typeof value !== 'object') return;

  const raw = value as { label?: unknown; severity?: unknown; color?: unknown };

  if (!isInjuryColor(raw.color)) return;

  const severity =
    typeof raw.severity === 'number' && Number.isFinite(raw.severity) ? clamp(Math.round(raw.severity), 1, 3) : 1;

  return { label: label(raw.label, key), severity, color: raw.color };
};

export const readInjuryConfig = (value: unknown): InjuriesConfig | undefined => {
  if (!value || typeof value !== 'object') return;

  const raw = value as { enabled?: unknown; parts?: unknown; types?: unknown };

  if (raw.enabled !== true) return;
  if (!raw.parts || typeof raw.parts !== 'object') return;
  if (!raw.types || typeof raw.types !== 'object') return;

  const parts: Record<string, InjuryPartDef> = {};
  const types: Record<string, InjuryTypeDef> = {};
  const rawParts = raw.parts as Record<string, unknown>;
  const rawTypes = raw.types as Record<string, unknown>;
  let count = 0;

  for (const key of Object.keys(rawParts)) {
    if (++count > MAX_ENTRIES) break;
    if (!isKey(key)) continue;

    const part = readPart(key, rawParts[key]);

    if (part) parts[key] = part;
  }

  count = 0;

  for (const key of Object.keys(rawTypes)) {
    if (++count > MAX_ENTRIES) break;
    if (!isKey(key)) continue;

    const type = readType(key, rawTypes[key]);

    if (type) types[key] = type;
  }

  if (Object.keys(parts).length === 0 || Object.keys(types).length === 0) return;

  return { enabled: true, parts, types };
};

const readInjuries = (value: unknown): Injury[] => {
  if (!Array.isArray(value)) return [];

  const list: Injury[] = [];

  for (const entry of value) {
    if (list.length >= MAX_INJURIES) break;
    if (!entry || typeof entry !== 'object') continue;

    const raw = entry as { id?: unknown; part?: unknown; type?: unknown; at?: unknown };

    if (typeof raw.id !== 'number' || !Number.isFinite(raw.id)) continue;
    if (!isKey(raw.part) || !isKey(raw.type)) continue;

    list.push({
      id: raw.id,
      part: raw.part,
      type: raw.type,
      at: typeof raw.at === 'number' && Number.isFinite(raw.at) ? raw.at : undefined,
    });
  }

  return list;
};


export interface InjuryState {
  config?: InjuriesConfig;
  injuries: readonly Injury[];
}

const EMPTY_INJURIES: readonly Injury[] = [];
const EMPTY_STATE: InjuryState = { injuries: EMPTY_INJURIES };

let received: readonly Injury[] = EMPTY_INJURIES;
let config: InjuriesConfig | undefined;
let state: InjuryState = EMPTY_STATE;

const listeners = new Set<() => void>();

const resolve = (): InjuryState => {
  if (!config) return EMPTY_STATE;

  const resolved: Injury[] = [];

  for (const injury of received) {
    if (!config.parts[injury.part] || !config.types[injury.type]) continue;

    resolved.push(injury);
  }

  return { config, injuries: resolved.length > 0 ? resolved : EMPTY_INJURIES };
};

const sameInjuries = (a: readonly Injury[], b: readonly Injury[]): boolean => {
  if (a === b) return true;
  if (a.length !== b.length) return false;

  for (let i = 0; i < a.length; i++) {
    if (a[i].id !== b[i].id || a[i].part !== b[i].part || a[i].type !== b[i].type) return false;
  }

  return true;
};

const publish = () => {
  const next = resolve();

  if (next.config === state.config && sameInjuries(next.injuries, state.injuries)) return;

  state = next;

  for (const listener of listeners) {
    try {
      listener();
    } catch (error) {
      console.error('injury listener failed', error);
    }
  }
};

export const setInjuryConfig = (value: unknown) => {
  config = readInjuryConfig(value);
  publish();
};

export const setInjuries = (value: unknown) => {
  received = readInjuries(value);
  publish();
};

export const subscribeInjuries = (listener: () => void): (() => void) => {
  listeners.add(listener);

  return () => {
    listeners.delete(listener);
  };
};

export const getInjuryState = (): InjuryState => state;


interface NuiMessage {
  action?: unknown;
  data?: unknown;
}

const onMessage = (event: MessageEvent<NuiMessage>) => {
  try {
    const message = event.data;

    if (!message || typeof message !== 'object') return;

    if (message.action === 'init') {
      const data = message.data as { uiConfig?: { injuries?: unknown } } | undefined;

      setInjuryConfig(data?.uiConfig?.injuries);
    } else if (message.action === 'setInjuries') {
      const data = message.data as InjuriesMessage | undefined;

      setInjuries(data?.injuries);
    }
  } catch (error) {
    console.error('failed to handle an injury message', error);
  }
};

if (typeof window !== 'undefined') window.addEventListener('message', onMessage);
