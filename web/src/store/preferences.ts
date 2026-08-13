
import { fetchNui } from '../utils/fetchNui';
import { UiConfig } from './uiConfig';

export type PrefKind = 'boolean' | 'number' | 'enum' | 'stringArray';

export type PrefGroup = 'display' | 'accessibility' | 'behaviour' | 'inventory';

export const PREF_GROUPS: readonly PrefGroup[] = ['display', 'accessibility', 'behaviour', 'inventory'];

export type PrefValue = boolean | number | string | readonly string[];

export type PrefKey =
  | 'uiScale'
  | 'backgroundDim'
  | 'reduceMotion'
  | 'slotSize'
  | 'slotSpacing'
  | 'cornerStyle'
  | 'textSize'
  | 'itemImageSize'
  | 'slotContrast'
  | 'panelSurface'
  | 'showSlotNoise'
  | 'showDurability'
  | 'showItemPlaceholder'
  | 'slotBorder'
  | 'figureOpacity'
  | 'showWeightRing'
  | 'showPanelIcon'
  | 'showSlotNumber'
  | 'rarityDisplay'
  | 'rarityPalette'
  | 'fontFamily'
  | 'boldText'
  | 'highContrast'
  | 'reduceTransparency'
  | 'focusRing'
  | 'tooltipDelay'
  | 'showTooltips'
  | 'showSearchBar'
  | 'showFilterChips'
  | 'showItemNotifications'
  | 'hotbarAlwaysOn'
  | 'hotbarTimeout'
  | 'fastSlotCount'
  | 'showSlotLabel'
  | 'showSlotCount'
  | 'showSlotWeight'
  | 'sortMode'
  | 'sortDirection'
  | 'favouritesFirst'
  | 'pageSize'
  | 'favourites';

export const PREF_CHANGE_EVENT = 'ox_inventory:prefchange';

export const RARITY_DISPLAY_MODES = ['off', 'border', 'glow'] as const;
export type RarityDisplayMode = (typeof RARITY_DISPLAY_MODES)[number];

export const RARITY_PALETTES = ['default', 'deuteranopia', 'protanopia', 'tritanopia'] as const;
export type RarityPalette = (typeof RARITY_PALETTES)[number];

export const SORT_MODES = ['slot', 'name', 'weight', 'rarity', 'count'] as const;
export type SortMode = (typeof SORT_MODES)[number];

export const CORNER_STYLES = ['sharp', 'soft', 'round'] as const;
export type CornerStyle = (typeof CORNER_STYLES)[number];

export const SORT_DIRECTIONS = ['ascending', 'descending'] as const;
export type SortDirection = (typeof SORT_DIRECTIONS)[number];

export const FONT_FAMILIES = ['default', 'system', 'mono', 'serif'] as const;

const FONT_STACKS: Record<string, string> = {
  system: "'Segoe UI', system-ui, -apple-system, 'Helvetica Neue', Arial, sans-serif",
  mono: "'Cascadia Mono', 'Consolas', 'SF Mono', 'Menlo', 'Roboto Mono', monospace",
  serif: "'Georgia', 'Cambria', 'Times New Roman', serif",
};

const CORNER_FACTORS: Record<string, number> = { sharp: 0, soft: 1, round: 1.8 };

const setRootFactor = (property: string, value: string | null) => {
  const root = document.documentElement;

  if (!root) return;

  if (value === null) root.style.removeProperty(property);
  else root.style.setProperty(property, value);
};

export const FAVOURITE_PATTERN = /^[A-Za-z0-9_]+$/;

export const FAVOURITE_MAX_LENGTH = 64;

export const FAVOURITES_MAX = 64;

interface PrefDefBase {
  key: PrefKey;
  group: PrefGroup;
  label: string;
  description?: string;
  hidden?: boolean;
  available?: () => boolean;
}

export interface BooleanPrefDef extends PrefDefBase {
  kind: 'boolean';
  default: boolean;
  apply?: (value: boolean) => void;
}

export interface NumberPrefDef extends PrefDefBase {
  kind: 'number';
  default: number;
  min: number;
  max: number;
  step: number;
  unit?: string;
  apply?: (value: number) => void;
}

export interface EnumPrefDef extends PrefDefBase {
  kind: 'enum';
  default: string;
  options: readonly string[];
  apply?: (value: string) => void;
}

export interface StringArrayPrefDef extends PrefDefBase {
  kind: 'stringArray';
  default: readonly string[];
  maxLength: number;
  apply?: (value: readonly string[]) => void;
}

export type PrefDef = BooleanPrefDef | NumberPrefDef | EnumPrefDef | StringArrayPrefDef;

export const PREFERENCES: readonly PrefDef[] = [
  {
    key: 'uiScale',
    kind: 'number',
    group: 'display',
    label: 'Interface scale',
    description: 'Scales every structural size token, so the layout reflows and text stays crisp.',
    default: 1,
    min: 0.75,
    max: 1.5,
    step: 0.05,
    apply: (value: number) => {
      const root = document.documentElement;

      if (!root) return;

      root.style.setProperty('--ox-scale', String(value));
    },
  },
  {
    key: 'backgroundDim',
    kind: 'number',
    group: 'display',
    label: 'Background dim',
    description: 'How much the world behind the inventory is darkened.',
    default: 0.9,
    min: 0,
    max: 1,
    step: 0.05,
    available: () => UiConfig.dim.enabled,
    apply: (value: number) => {
      const root = document.documentElement;

      if (!root) return;

      const amount = UiConfig.dim.enabled ? value : 0;

      root.style.setProperty('--ox-dim', String(amount));
      root.style.setProperty('--ox-dim-k', String(amount / 0.9));
    },
  },
  {
    key: 'reduceMotion',
    kind: 'boolean',
    group: 'display',
    label: 'Reduce motion',
    description: 'Removes transitions and animations across the interface.',
    default: false,
    apply: (value: boolean) => {
      const root = document.documentElement;

      if (!root) return;

      root.classList.toggle('reduce-motion', value);
    },
  },

  {
    key: 'slotSize',
    kind: 'number',
    group: 'display',
    label: 'Slot size',
    description: 'Scales the item slots and grid cells without changing text or spacing.',
    default: 1,
    min: 0.8,
    max: 1.25,
    step: 0.05,
    apply: (value: number) => setRootFactor('--ox-slot-k', value === 1 ? null : String(value)),
  },
  {
    key: 'slotSpacing',
    kind: 'number',
    group: 'display',
    label: 'Slot spacing',
    description: 'How much room sits between slots. Zero packs them edge to edge.',
    default: 1,
    min: 0,
    max: 2,
    step: 0.1,
    apply: (value: number) => setRootFactor('--ox-gap-k', value === 1 ? null : String(value)),
  },
  {
    key: 'cornerStyle',
    kind: 'enum',
    group: 'display',
    label: 'Corner style',
    description: 'How rounded slots, panels and menus are.',
    default: 'soft',
    options: CORNER_STYLES,
    apply: (value: string) => {
      const factor = CORNER_FACTORS[value];

      setRootFactor('--ox-radius-k', factor === undefined || factor === 1 ? null : String(factor));
    },
  },
  {
    key: 'textSize',
    kind: 'number',
    group: 'display',
    label: 'Text size',
    description: 'Scales every label independently of the interface scale.',
    default: 1,
    min: 0.85,
    max: 1.2,
    step: 0.05,
    apply: (value: number) => setRootFactor('--ox-text-k', value === 1 ? null : String(value)),
  },
  {
    key: 'itemImageSize',
    kind: 'number',
    group: 'display',
    label: 'Item image size',
    description: 'How much of a slot the item artwork fills.',
    default: 1,
    min: 0.7,
    max: 1.2,
    step: 0.05,
    apply: (value: number) => setRootFactor('--ox-img-k', value === 1 ? null : String(value)),
  },
  {
    key: 'slotContrast',
    kind: 'number',
    group: 'display',
    label: 'Slot background',
    description: 'How strongly a slot stands out from the background behind it. Zero is invisible.',
    default: 1,
    min: 0,
    max: 3,
    step: 0.1,
    apply: (value: number) => setRootFactor('--ox-fill-k', value === 1 ? null : String(value)),
  },
  {
    key: 'panelSurface',
    kind: 'number',
    group: 'display',
    label: 'Panel surface',
    description: 'Puts a solid panel behind each inventory. Zero is the chrome-less default.',
    default: 0,
    min: 0,
    max: 0.6,
    step: 0.05,
    apply: (value: number) =>
      setRootFactor('--ox-panel-fill', value === 0 ? null : `rgba(10, 12, 16, ${value})`),
  },
  {
    key: 'showSlotNoise',
    kind: 'boolean',
    group: 'display',
    label: 'Slot texture',
    description: 'The fine grain over each slot.',
    default: true,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('hide-slot-noise', !value);
    },
  },
  {
    key: 'showDurability',
    kind: 'boolean',
    group: 'display',
    label: 'Show durability bars',
    description: 'Condition bars on slots. The tooltip always reports durability either way.',
    default: true,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('hide-slot-durability', !value);
    },
  },
  {
    key: 'showItemPlaceholder',
    kind: 'boolean',
    group: 'display',
    label: 'Placeholder for missing art',
    description: 'Draws a picture icon for items with no image, instead of leaving the slot empty.',
    default: true,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('hide-item-placeholder', !value);
    },
  },

  {
    key: 'slotBorder',
    kind: 'number',
    group: 'display',
    label: 'Slot outline',
    description: 'How visible the edge of each slot is. Zero removes it entirely.',
    default: 1,
    min: 0,
    max: 4,
    step: 0.1,
    apply: (value: number) => setRootFactor('--ox-border-k', value === 1 ? null : String(value)),
  },
  {
    key: 'figureOpacity',
    kind: 'number',
    group: 'display',
    label: 'Character figure',
    description: 'How strongly the mannequin between the equipment columns is drawn.',
    default: 0.26,
    min: 0,
    max: 1,
    step: 0.02,
    apply: (value: number) => setRootFactor('--ox-figure-opacity', value === 0.26 ? null : String(value)),
  },
  {
    key: 'showWeightRing',
    kind: 'boolean',
    group: 'display',
    label: 'Show weight gauge',
    description: 'The ring beside each panel’s weight readout. The numbers stay either way.',
    default: true,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('hide-weight-ring', !value);
    },
  },
  {
    key: 'showPanelIcon',
    kind: 'boolean',
    group: 'display',
    label: 'Show panel icons',
    description: 'The coloured tile at the start of each panel header.',
    default: true,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('hide-panel-icon', !value);
    },
  },
  {
    key: 'showSlotNumber',
    kind: 'boolean',
    group: 'display',
    label: 'Show slot numbers',
    description: 'The 1-5 badges on the number-key slots. The keybinds still work.',
    default: true,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('hide-slot-number', !value);
    },
  },

  {
    key: 'fontFamily',
    kind: 'enum',
    group: 'accessibility',
    label: 'Typeface',
    description: 'Swap the interface font. Useful when Inter is hard to read at small sizes.',
    default: 'default',
    options: FONT_FAMILIES,
    apply: (value: string) => setRootFactor('--ox-font', FONT_STACKS[value] || null),
  },
  {
    key: 'boldText',
    kind: 'boolean',
    group: 'accessibility',
    label: 'Bold text',
    description: 'Thickens every label without changing its size or the layout.',
    default: false,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('bold-text', value);
    },
  },
  {
    key: 'highContrast',
    kind: 'boolean',
    group: 'accessibility',
    label: 'High contrast',
    description: 'Brightens secondary text and strengthens every outline.',
    default: false,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('high-contrast', value);
    },
  },
  {
    key: 'reduceTransparency',
    kind: 'boolean',
    group: 'accessibility',
    label: 'Reduce transparency',
    description: 'Makes menus, tooltips and badges opaque so text never sits over artwork.',
    default: false,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('reduce-transparency', value);
    },
  },
  {
    key: 'focusRing',
    kind: 'boolean',
    group: 'accessibility',
    label: 'Keyboard focus ring',
    description: 'Outlines whichever control has keyboard focus.',
    default: false,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('focus-ring', value);
    },
  },
  {
    key: 'rarityDisplay',
    kind: 'enum',
    group: 'accessibility',
    label: 'Rarity display',
    description: 'How item rarity is shown on a slot. The tooltip always names the tier.',
    default: 'glow',
    options: RARITY_DISPLAY_MODES,
    available: () => UiConfig.rarity.enabled,
    apply: (value: string) => {
      const root = document.documentElement;

      if (!root) return;

      const enabled = UiConfig.rarity.enabled;

      for (const mode of RARITY_DISPLAY_MODES) root.classList.toggle(`rarity-display-${mode}`, enabled && mode === value);
    },
  },
  {
    key: 'rarityPalette',
    kind: 'enum',
    group: 'accessibility',
    label: 'Rarity colours',
    description: 'Alternative rarity palettes that stay distinguishable with colour vision deficiency.',
    default: 'default',
    options: RARITY_PALETTES,
    available: () => UiConfig.rarity.enabled,
    apply: (value: string) => {
      const root = document.documentElement;

      if (!root) return;

      const tiers = ['common', 'uncommon', 'rare', 'epic', 'legendary', 'mythic'];
      const palettes: Record<string, readonly string[]> = {
        deuteranopia: ['#8C9199', '#31B631', '#90B0F1', '#DBB8DE', '#ECD89A', '#FCEDE5'],
        protanopia: ['#8C9199', '#3DB520', '#90B0F1', '#D3BCDE', '#E5DC75', '#FCEDE5'],
        tritanopia: ['#889199', '#65B057', '#1CC1E1', '#EFADF5', '#E9DC4A', '#F3EFEF'],
      };
      const palette = palettes[value];
      const style = root.style;

      for (let i = 0; i < tiers.length; i++) {
        const tier = tiers[i];
        const baseProperty = `--ox-rarity-${tier}-base`;
        let base = style.getPropertyValue(baseProperty).trim();

        if (!base) {
          base = getComputedStyle(root).getPropertyValue(`--ox-rarity-${tier}`).trim();

          if (base) style.setProperty(baseProperty, base);
        }

        const next = (palette && palette[i]) || base;

        if (!next) continue;

        style.setProperty(`--ox-rarity-${tier}`, next);

        const configured = UiConfig.rarity.tiers[tier];

        if (configured) configured.color = next;
      }
    },
  },

  {
    key: 'tooltipDelay',
    kind: 'number',
    group: 'behaviour',
    label: 'Tooltip delay',
    description: 'How long to hover a slot before its tooltip appears.',
    default: 500,
    min: 0,
    max: 1500,
    step: 50,
    unit: 'ms',
  },
  {
    key: 'showTooltips',
    kind: 'boolean',
    group: 'behaviour',
    label: 'Show tooltips',
    description: 'Item detail panels on hover. Off, nothing pops up over the grid at all.',
    default: true,
  },
  {
    key: 'showSearchBar',
    kind: 'boolean',
    group: 'behaviour',
    label: 'Show search bar',
    description: 'The search field above each inventory.',
    default: true,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('hide-search', !value);
    },
  },
  {
    key: 'showFilterChips',
    kind: 'boolean',
    group: 'behaviour',
    label: 'Show category filters',
    description: 'The category buttons above the grid. The sort control stays either way.',
    default: true,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('hide-filter-chips', !value);
    },
  },
  {
    key: 'showItemNotifications',
    kind: 'boolean',
    group: 'behaviour',
    label: 'Show pickup notifications',
    description: 'The toasts that announce items arriving in or leaving your inventory.',
    default: true,
    apply: (value: boolean) => {
      document.documentElement.classList.toggle('hide-item-notifications', !value);
    },
  },
  {
    key: 'hotbarAlwaysOn',
    kind: 'boolean',
    group: 'behaviour',
    label: 'Always show hotbar',
    description: 'Keeps the hotbar on screen instead of hiding it after a moment.',
    default: false,
    apply: (value) => {
      document.documentElement.classList.toggle('hotbar-always-on', value);
    },
  },
  {
    key: 'hotbarTimeout',
    kind: 'number',
    group: 'behaviour',
    label: 'Hotbar timeout',
    description: 'How long the hotbar stays visible after you show it.',
    default: 3000,
    min: 1000,
    max: 10000,
    step: 500,
    unit: 'ms',
  },
  {
    key: 'fastSlotCount',
    kind: 'number',
    group: 'behaviour',
    label: 'Fast slots shown',
    description: 'How many of the number-key slots are drawn. The keybinds themselves never change.',
    default: 5,
    min: 0,
    max: 5,
    step: 1,
  },
  {
    key: 'showSlotLabel',
    kind: 'boolean',
    group: 'behaviour',
    label: 'Show item names',
    default: true,
    apply: (value) => {
      document.documentElement.classList.toggle('hide-slot-label', !value);
    },
  },
  {
    key: 'showSlotCount',
    kind: 'boolean',
    group: 'behaviour',
    label: 'Show item counts',
    default: true,
    apply: (value) => {
      document.documentElement.classList.toggle('hide-slot-count', !value);
    },
  },
  {
    key: 'showSlotWeight',
    kind: 'boolean',
    group: 'behaviour',
    label: 'Show item weights',
    default: true,
    apply: (value) => {
      document.documentElement.classList.toggle('hide-slot-weight', !value);
    },
  },

  {
    key: 'sortMode',
    kind: 'enum',
    group: 'inventory',
    label: 'Sort items by',
    description: 'Display order only - nothing here moves an item. Unavailable in grid layout.',
    default: 'slot',
    options: SORT_MODES,
  },
  {
    key: 'sortDirection',
    kind: 'enum',
    group: 'inventory',
    label: 'Sort direction',
    description: 'Which end of the order comes first. Empty slots stay at the back either way.',
    default: 'ascending',
    options: SORT_DIRECTIONS,
  },
  {
    key: 'favouritesFirst',
    kind: 'boolean',
    group: 'inventory',
    label: 'Favourites first',
    description: 'Pin favourited items to the front of every panel. They stay starred either way.',
    default: true,
  },
  {
    key: 'pageSize',
    kind: 'number',
    group: 'inventory',
    label: 'Slots per page',
    description: 'How many slots are drawn before scrolling loads more. Lower is lighter.',
    default: 30,
    min: 10,
    max: 100,
    step: 10,
  },
  {
    key: 'favourites',
    kind: 'stringArray',
    group: 'inventory',
    label: 'Favourite items',
    description: 'Pinned to the front of every panel. Toggle from an item’s context menu.',
    default: [],
    maxLength: FAVOURITES_MAX,
    hidden: true,
  },
];

const defByKey: Partial<Record<string, PrefDef>> = {};

for (const def of PREFERENCES) defByKey[def.key] = def;

export const getPrefDef = (key: string): PrefDef | undefined => defByKey[key];

export const getPreferences = (group: PrefGroup): PrefDef[] =>
  PREFERENCES.filter((def) => def.group === group && !def.hidden && (!def.available || def.available()));


export const prefLabelKey = (key: string) => `ui_pref_${key}`;
export const prefDescriptionKey = (key: string) => `ui_pref_desc_${key}`;
export const prefOptionKey = (key: string, option: string) => `ui_pref_opt_${key}_${option}`;
export const prefGroupKey = (group: PrefGroup) => `ui_prefs_${group}`;


const EMPTY_LIST: readonly string[] = [];

export const isValidFavourite = (name: unknown): name is string =>
  typeof name === 'string' && name.length > 0 && name.length <= FAVOURITE_MAX_LENGTH && FAVOURITE_PATTERN.test(name);

const clampNumber = (def: NumberPrefDef, value: number): number => {
  let next = value;

  if (next < def.min) next = def.min;
  else if (next > def.max) next = def.max;

  return def.step >= 1 ? Math.round(next) : Math.round(next * 10000) / 10000;
};

const coerce = (def: PrefDef, value: unknown): PrefValue | undefined => {
  switch (def.kind) {
    case 'boolean':
      return typeof value === 'boolean' ? value : undefined;

    case 'number':
      return typeof value === 'number' && Number.isFinite(value) ? clampNumber(def, value) : undefined;

    case 'enum':
      return typeof value === 'string' && def.options.indexOf(value) !== -1 ? value : undefined;

    case 'stringArray': {
      if (!Array.isArray(value) || value.length > def.maxLength) return undefined;

      const list: string[] = [];

      for (const entry of value) {
        if (!isValidFavourite(entry)) return undefined;
        if (list.indexOf(entry) === -1) list.push(entry);
      }

      return list;
    }
  }
};


const defaultValues = (): Record<string, PrefValue> => {
  const values: Record<string, PrefValue> = {};

  for (const def of PREFERENCES) values[def.key] = def.kind === 'stringArray' ? def.default.slice() : def.default;

  return values;
};

export let Prefs: Record<string, PrefValue> = defaultValues();

const readValue = (key: string): PrefValue | undefined => {
  const value = Prefs[key];

  if (value !== undefined) return value;

  return defByKey[key]?.default;
};

export const getPref = <T extends PrefValue = PrefValue>(key: PrefKey): T => readValue(key) as unknown as T;

export const getBooleanPref = (key: PrefKey): boolean => {
  const value = readValue(key);

  return typeof value === 'boolean' ? value : false;
};

export const getNumberPref = (key: PrefKey): number => {
  const value = readValue(key);

  return typeof value === 'number' ? value : 0;
};

export const getEnumPref = (key: PrefKey): string => {
  const value = readValue(key);

  return typeof value === 'string' ? value : '';
};

export const getListPref = (key: PrefKey): readonly string[] => {
  const value = readValue(key);

  return Array.isArray(value) ? value : EMPTY_LIST;
};

export const getPrefsSnapshot = (): Record<string, PrefValue> => {
  const snapshot: Record<string, PrefValue> = {};

  for (const def of PREFERENCES) {
    const value = Prefs[def.key];

    snapshot[def.key] = Array.isArray(value) ? value.slice() : (value as PrefValue);
  }

  return snapshot;
};


const applyFailed: Record<string, boolean> = {};

const runApply = (def: PrefDef) => {
  try {
    switch (def.kind) {
      case 'boolean':
        if (def.apply) def.apply(getBooleanPref(def.key));
        break;

      case 'number':
        if (def.apply) def.apply(getNumberPref(def.key));
        break;

      case 'enum':
        if (def.apply) def.apply(getEnumPref(def.key));
        break;

      case 'stringArray':
        if (def.apply) def.apply(getListPref(def.key));
        break;
    }
  } catch (error) {
    if (applyFailed[def.key]) return;

    applyFailed[def.key] = true;
    console.error(`failed to apply preference "${def.key}"`, error);
  }
};

const notifyPrefChange = () => {
  try {
    window.dispatchEvent(new Event(PREF_CHANGE_EVENT));
  } catch (error) {
    console.error('failed to announce a preference change', error);
  }
};

const applyAll = () => {
  for (const def of PREFERENCES) runApply(def);

  notifyPrefChange();
};

export const setPrefs = (partial?: Record<string, unknown> | null) => {
  if (partial && typeof partial === 'object' && !Array.isArray(partial)) {
    const next: Record<string, PrefValue> = { ...Prefs };
    let changed = false;

    for (const key of Object.keys(partial)) {
      const def = defByKey[key];

      if (!def) continue;

      const value = coerce(def, partial[key]);

      if (value === undefined) continue;

      next[key] = value;
      changed = true;
    }

    if (changed) Prefs = next;
  }

  applyAll();
};

export const resetPrefs = (group?: PrefGroup): Record<string, PrefValue> => {
  const reset: Record<string, PrefValue> = {};
  const next: Record<string, PrefValue> = { ...Prefs };

  for (const def of PREFERENCES) {
    if (group && def.group !== group) continue;

    const value = def.kind === 'stringArray' ? def.default.slice() : def.default;

    next[def.key] = value;
    reset[def.key] = value;
  }

  Prefs = next;
  applyAll();

  return reset;
};

type PrefValueForKind<K extends PrefKind> = K extends 'boolean'
  ? boolean
  : K extends 'number'
  ? number
  : K extends 'enum'
  ? string
  : readonly string[];

export const registerPrefApply = <K extends PrefKind>(
  key: PrefKey,
  kind: K,
  apply: (value: PrefValueForKind<K>) => void
): boolean => {
  const def = defByKey[key];

  if (!def || def.kind !== kind) return false;

  switch (def.kind) {
    case 'boolean':
      def.apply = apply as (value: boolean) => void;
      break;

    case 'number':
      def.apply = apply as (value: number) => void;
      break;

    case 'enum':
      def.apply = apply as (value: string) => void;
      break;

    case 'stringArray':
      def.apply = apply as (value: readonly string[]) => void;
      break;
  }

  runApply(def);
  notifyPrefChange();

  return true;
};
