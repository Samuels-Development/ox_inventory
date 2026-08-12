
export interface Rgba {
  r: number;
  g: number;
  b: number;
  a: number;
}

export interface Hsv {
  h: number;
  s: number;
  v: number;
}

const HEX_PATTERN = /^#([0-9a-f]+)$/i;
const RGB_PATTERN =
  /^rgba?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*(?:,\s*(\d+(?:\.\d+)?|\.\d+)\s*)?\)$/i;

const inRange = (n: number, max: number) => Number.isFinite(n) && n >= 0 && n <= max;

export const clamp = (n: number, min: number, max: number) => (n < min ? min : n > max ? max : n);

export const parseColor = (value: string): Rgba | null => {
  const input = value.trim();
  const hex = HEX_PATTERN.exec(input);

  if (hex) {
    const digits = hex[1];
    const short = digits.length === 3 || digits.length === 4;

    if (!short && digits.length !== 6 && digits.length !== 8) return null;

    const step = short ? 1 : 2;
    const channel = (index: number) => {
      const raw = digits.substr(index * step, step);

      return parseInt(short ? raw + raw : raw, 16);
    };

    const hasAlpha = digits.length === 4 || digits.length === 8;

    return { r: channel(0), g: channel(1), b: channel(2), a: hasAlpha ? channel(3) / 255 : 1 };
  }

  const rgb = RGB_PATTERN.exec(input);

  if (!rgb) return null;

  const alphaRaw: string | undefined = rgb[4];
  const parsed: Rgba = {
    r: Number(rgb[1]),
    g: Number(rgb[2]),
    b: Number(rgb[3]),
    a: alphaRaw === undefined ? 1 : Number(alphaRaw),
  };

  if (!inRange(parsed.r, 255) || !inRange(parsed.g, 255) || !inRange(parsed.b, 255) || !inRange(parsed.a, 1)) {
    return null;
  }

  return { r: Math.round(parsed.r), g: Math.round(parsed.g), b: Math.round(parsed.b), a: parsed.a };
};

export const toHexPair = (n: number) => clamp(Math.round(n), 0, 255).toString(16).padStart(2, '0');

export const formatColor = (rgba: Rgba, functional: boolean): string => {
  if (rgba.a >= 1 && !functional) return `#${toHexPair(rgba.r)}${toHexPair(rgba.g)}${toHexPair(rgba.b)}`;

  const alpha = Math.round(rgba.a * 1000) / 1000;

  return `rgba(${Math.round(rgba.r)}, ${Math.round(rgba.g)}, ${Math.round(rgba.b)}, ${alpha})`;
};

export const isFunctionalNotation = (value: string) => /^rgba?\(/i.test(value.trim());

export const toHex = (rgba: Rgba): string => `#${toHexPair(rgba.r)}${toHexPair(rgba.g)}${toHexPair(rgba.b)}`;

export const toCss = (rgba: Rgba): string =>
  `rgba(${Math.round(rgba.r)}, ${Math.round(rgba.g)}, ${Math.round(rgba.b)}, ${Math.round(rgba.a * 1000) / 1000})`;

export const rgbToHsv = ({ r, g, b }: Rgba): Hsv => {
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const d = max - min;

  let h = 0;

  if (d !== 0) {
    if (max === r) h = ((g - b) / d) % 6;
    else if (max === g) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;

    h *= 60;

    if (h < 0) h += 360;
  }

  return { h, s: max === 0 ? 0 : d / max, v: max / 255 };
};

export const hsvToRgb = ({ h, s, v }: Hsv): { r: number; g: number; b: number } => {
  const c = v * s;
  const hp = (((h % 360) + 360) % 360) / 60;
  const x = c * (1 - Math.abs((hp % 2) - 1));

  let r = 0;
  let g = 0;
  let b = 0;

  if (hp < 1) [r, g, b] = [c, x, 0];
  else if (hp < 2) [r, g, b] = [x, c, 0];
  else if (hp < 3) [r, g, b] = [0, c, x];
  else if (hp < 4) [r, g, b] = [0, x, c];
  else if (hp < 5) [r, g, b] = [x, 0, c];
  else [r, g, b] = [c, 0, x];

  const m = v - c;

  return { r: Math.round((r + m) * 255), g: Math.round((g + m) * 255), b: Math.round((b + m) * 255) };
};

export const sameColor = (a: Rgba | null, b: Rgba | null): boolean => {
  if (!a || !b) return a === b;

  return a.r === b.r && a.g === b.g && a.b === b.b && Math.abs(a.a - b.a) < 0.001;
};
