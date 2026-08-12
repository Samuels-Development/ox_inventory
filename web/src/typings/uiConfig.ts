export type LayoutMode = 'slots' | 'grid';

export interface RarityTier {
  label: string;
  color: string;
  order: number;
}

export interface ClothingSlotDef {
  index: number;
  name: string;
  label: string;
  side: 'left' | 'right';
}

export interface ThemeColors {
  backgroundColor1: string;
  backgroundColor2: string;
  backgroundColor3: string;
  rgbColor1: string;
  rgbColor2: string;
  mainColor: string;
  secondaryColor: string;
  textShadow: string;
  photoShadowColor: string;
}

export interface UiConfig {
  layout: LayoutMode;
  grid: { columns: number; allowRotate: boolean };
  clothing: { enabled: boolean; slots: ClothingSlotDef[] };
  rarity: { enabled: boolean; default: string; tiers: Record<string, RarityTier> };
  theme: { name: string; colors: ThemeColors };
}


export interface InjuryPartDef {
  label: string;
  x: number;
  y: number;
}

export interface InjuryTypeDef {
  label: string;
  severity: number;
  color: string;
}

export interface InjuriesConfig {
  enabled: boolean;
  parts: Record<string, InjuryPartDef>;
  types: Record<string, InjuryTypeDef>;
}

export interface Injury {
  id: number;
  part: string;
  type: string;
  at?: number;
}

export interface InjuriesMessage {
  injuries?: unknown;
}

export interface UiConfigMessage extends Partial<UiConfig> {
  defaultTheme?: { name?: string; colors?: Partial<ThemeColors> };
  prefs?: Record<string, unknown>;
  injuries?: unknown;
}

export const DEFAULT_UI_CONFIG: UiConfig = {
  layout: 'slots',
  grid: {
    columns: 10,
    allowRotate: true,
  },
  clothing: {
    enabled: false,
    slots: [],
  },
  rarity: {
    enabled: false,
    default: 'common',
    tiers: {
      common: { label: 'Common', color: '#9CA3AF', order: 1 },
      uncommon: { label: 'Uncommon', color: '#4ADE80', order: 2 },
      rare: { label: 'Rare', color: '#38BDF8', order: 3 },
      epic: { label: 'Epic', color: '#A855F7', order: 4 },
      legendary: { label: 'Legendary', color: '#F59E0B', order: 5 },
      mythic: { label: 'Mythic', color: '#FB7185', order: 6 },
    },
  },
  theme: {
    name: 'white',
    colors: {
      backgroundColor1: 'rgba(74, 75, 74, 0)',
      backgroundColor2: 'rgba(77, 77, 77, 0.05)',
      backgroundColor3: 'rgba(138, 138, 138, 0.1)',
      rgbColor1: 'rgba(224, 224, 224, 0.1)',
      rgbColor2: 'rgba(228, 228, 228, 0.05)',
      mainColor: '#d6d6d6',
      secondaryColor: '#757575',
      textShadow: 'rgba(226, 226, 226, 0.36)',
      photoShadowColor: 'rgba(221, 221, 221, 0.3)',
    },
  },
};
