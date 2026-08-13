import {
  ClothingSlotDef,
  DEFAULT_UI_CONFIG,
  LayoutMode,
  RarityTier,
  ThemeColors,
  UiConfig as UiConfigShape,
  UiConfigMessage,
} from '../typings/uiConfig';

export let UiConfig: UiConfigShape = DEFAULT_UI_CONFIG;

export const THEME_PRESETS: Readonly<Record<string, ThemeColors>> = {
  white: {
    backgroundColor1: 'rgba(74, 75, 74, 0)',
    backgroundColor2: 'rgba(77, 77, 77, 0.05)',
    backgroundColor3: 'rgba(138, 138, 138, 0.1)',
    rgbColor1: 'rgba(224, 224, 224, 0.1)',
    rgbColor2: 'rgba(228, 228, 228, 0.05)',
    mainColor: '#d6d6d6ff',
    secondaryColor: '#757575ff',
    textShadow: 'rgba(226, 226, 226, 0.36)',
    photoShadowColor: 'rgba(221, 221, 221, 0.3)',
  },
  yellow: {
    backgroundColor1: 'rgba(75, 83, 24, 0)',
    backgroundColor2: 'rgba(71, 80, 18, 0.05)',
    backgroundColor3: 'rgba(118, 134, 24, 0.1)',
    rgbColor1: 'rgba(192, 224, 15, 0.10)',
    rgbColor2: 'rgba(192, 224, 15, 0.05)',
    mainColor: '#C0E00F',
    secondaryColor: '#697A08',
    textShadow: 'rgba(192, 224, 15, 0.36)',
    photoShadowColor: 'rgba(192, 224, 15, 0.30)',
  },
  orange: {
    backgroundColor1: 'rgba(83, 55, 24, 0)',
    backgroundColor2: 'rgba(80, 46, 18, 0.05)',
    backgroundColor3: 'rgba(134, 68, 24, 0.1)',
    rgbColor1: 'rgba(224, 109, 15, 0.1)',
    rgbColor2: 'rgba(224, 92, 15, 0.05)',
    mainColor: '#e04a0fff',
    secondaryColor: '#7a3608ff',
    textShadow: 'rgba(224, 109, 15, 0.36)',
    photoShadowColor: 'rgba(224, 116, 15, 0.3)',
  },
  red: {
    backgroundColor1: 'rgba(83, 24, 24, 0)',
    backgroundColor2: 'rgba(80, 18, 18, 0.05)',
    backgroundColor3: 'rgba(134, 24, 24, 0.1)',
    rgbColor1: 'rgba(224, 15, 15, 0.1)',
    rgbColor2: 'rgba(224, 15, 15, 0.05)',
    mainColor: '#e00f2bff',
    secondaryColor: '#7a0808ff',
    textShadow: 'rgba(224, 15, 15, 0.36)',
    photoShadowColor: 'rgba(224, 15, 15, 0.3)',
  },
  purple: {
    backgroundColor1: 'rgba(61, 24, 83, 0)',
    backgroundColor2: 'rgba(42, 18, 80, 0.05)',
    backgroundColor3: 'rgba(94, 24, 134, 0.1)',
    rgbColor1: 'rgba(112, 15, 224, 0.1)',
    rgbColor2: 'rgba(106, 15, 224, 0.05)',
    mainColor: '#6a0fe0ff',
    secondaryColor: '#39087aff',
    textShadow: 'rgba(106, 15, 224, 0.36)',
    photoShadowColor: 'rgba(123, 15, 224, 0.3)',
  },
  blue: {
    backgroundColor1: 'rgba(24, 71, 83, 0)',
    backgroundColor2: 'rgba(18, 73, 80, 0.05)',
    backgroundColor3: 'rgba(24, 121, 134, 0.1)',
    rgbColor1: 'rgba(15, 210, 224, 0.1)',
    rgbColor2: 'rgba(15, 182, 224, 0.05)',
    mainColor: '#0fb6e0ff',
    secondaryColor: '#086d7aff',
    textShadow: 'rgba(15, 200, 224, 0.36)',
    photoShadowColor: 'rgba(15, 210, 224, 0.3)',
  },
  green: {
    backgroundColor1: 'rgba(46, 83, 24, 0)',
    backgroundColor2: 'rgba(28, 80, 18, 0.05)',
    backgroundColor3: 'rgba(37, 134, 24, 0.1)',
    rgbColor1: 'rgba(15, 224, 25, 0.1)',
    rgbColor2: 'rgba(15, 224, 32, 0.05)',
    mainColor: '#16e00fff',
    secondaryColor: '#157a08ff',
    textShadow: 'rgba(15, 224, 25, 0.36)',
    photoShadowColor: 'rgba(15, 224, 43, 0.3)',
  },
};

export const THEME_PRESET_NAMES: readonly string[] = ['white', 'yellow', 'orange', 'red', 'purple', 'blue', 'green'];

export const CUSTOM_THEME_NAME = 'custom';

const isLayoutMode = (value: unknown): value is LayoutMode => value === 'slots' || value === 'grid';

const mergeGrid = (grid?: Partial<UiConfigShape['grid']>): UiConfigShape['grid'] => ({
  columns: typeof grid?.columns === 'number' && grid.columns > 0 ? Math.floor(grid.columns) : UiConfig.grid.columns,
  allowRotate: typeof grid?.allowRotate === 'boolean' ? grid.allowRotate : UiConfig.grid.allowRotate,
});

const mergeClothing = (clothing?: Partial<UiConfigShape['clothing']>): UiConfigShape['clothing'] => {
  const slots = Array.isArray(clothing?.slots) ? (clothing?.slots as ClothingSlotDef[]) : UiConfig.clothing.slots;

  return {
    enabled: typeof clothing?.enabled === 'boolean' ? clothing.enabled : UiConfig.clothing.enabled,
    slots: slots.filter((slot) => typeof slot?.index === 'number' && typeof slot?.name === 'string'),
  };
};

const mergeRarity = (rarity?: Partial<UiConfigShape['rarity']>): UiConfigShape['rarity'] => ({
  enabled: typeof rarity?.enabled === 'boolean' ? rarity.enabled : UiConfig.rarity.enabled,
  default: typeof rarity?.default === 'string' ? rarity.default : UiConfig.rarity.default,
  tiers: rarity?.tiers ? { ...UiConfig.rarity.tiers, ...rarity.tiers } : UiConfig.rarity.tiers,
});

const mergeDim = (dim?: Partial<UiConfigShape['dim']>): UiConfigShape['dim'] => ({
  enabled: typeof dim?.enabled === 'boolean' ? dim.enabled : UiConfig.dim.enabled,
});

const mergeTheme = (theme?: Partial<UiConfigShape['theme']>): UiConfigShape['theme'] => ({
  name: typeof theme?.name === 'string' ? theme.name : UiConfig.theme.name,
  colors: theme?.colors ? { ...UiConfig.theme.colors, ...theme.colors } : UiConfig.theme.colors,
});

const applyTheme = (colors: ThemeColors) => {
  const style = document.documentElement?.style;

  if (!style) return;

  style.setProperty('--ox-bg-1', colors.backgroundColor1);
  style.setProperty('--ox-bg-2', colors.backgroundColor2);
  style.setProperty('--ox-bg-3', colors.backgroundColor3);
  style.setProperty('--ox-rgb-1', colors.rgbColor1);
  style.setProperty('--ox-rgb-2', colors.rgbColor2);
  style.setProperty('--ox-main', colors.mainColor);
  style.setProperty('--ox-secondary', colors.secondaryColor);
  style.setProperty('--ox-text-shadow', colors.textShadow);
  style.setProperty('--ox-photo-shadow', colors.photoShadowColor);

  for (const key in UiConfig.rarity.tiers) {
    const tier: RarityTier | undefined = UiConfig.rarity.tiers[key];

    if (tier?.color) style.setProperty(`--ox-rarity-${key}`, tier.color);
  }
};

let serverDefaultTheme: UiConfigShape['theme'] = DEFAULT_UI_CONFIG.theme;
let capturedServerDefault = false;

const normaliseTheme = (theme: NonNullable<UiConfigMessage['defaultTheme']>): UiConfigShape['theme'] => ({
  name: typeof theme.name === 'string' ? theme.name : DEFAULT_UI_CONFIG.theme.name,
  colors: { ...DEFAULT_UI_CONFIG.theme.colors, ...(theme.colors || {}) },
});

export const setUiConfig = (cfg?: UiConfigMessage) => {
  if (cfg) {
    UiConfig = {
      layout: isLayoutMode(cfg.layout) ? cfg.layout : UiConfig.layout,
      grid: mergeGrid(cfg.grid),
      clothing: mergeClothing(cfg.clothing),
      rarity: mergeRarity(cfg.rarity),
      dim: mergeDim(cfg.dim),
      theme: mergeTheme(cfg.theme),
    };

    if (cfg.defaultTheme) {
      serverDefaultTheme = normaliseTheme(cfg.defaultTheme);
      capturedServerDefault = true;
    } else if (!capturedServerDefault && cfg.theme) {
      serverDefaultTheme = { name: UiConfig.theme.name, colors: { ...UiConfig.theme.colors } };
      capturedServerDefault = true;
    }
  }

  applyTheme(UiConfig.theme.colors);
};

export const getServerDefaultTheme = (): UiConfigShape['theme'] => serverDefaultTheme;

export const resetTheme = (): UiConfigShape['theme'] => {
  setUiConfig({ theme: serverDefaultTheme });

  return UiConfig.theme;
};

export const isGridLayout = () => UiConfig.layout === 'grid';
