import React, { useCallback, useEffect, useLayoutEffect, useRef, useState } from 'react';
import {
  FloatingFocusManager,
  FloatingOverlay,
  FloatingPortal,
  useDismiss,
  useFloating,
  useInteractions,
  useTransitionStyles,
} from '@floating-ui/react';
import { Locale } from '../../store/locale';
import {
  CUSTOM_THEME_NAME,
  resetTheme,
  setUiConfig,
  THEME_PRESET_NAMES,
  THEME_PRESETS,
  UiConfig,
} from '../../store/uiConfig';
import {
  getBooleanPref,
  getEnumPref,
  getListPref,
  getNumberPref,
  getPref,
  getPreferences,
  NumberPrefDef,
  PREF_GROUPS,
  PrefDef,
  PrefGroup,
  PrefKey,
  PrefValue,
  prefDescriptionKey,
  prefGroupKey,
  prefLabelKey,
  prefOptionKey,
  setPrefs,
} from '../../store/preferences';
import { flushPrefs, persistPrefs, PREF_CHANGE_EVENT } from '../../helpers';
import { ThemeColors } from '../../typings/uiConfig';
import { fetchNui } from '../../utils/fetchNui';
import { formatColor, isFunctionalNotation, parseColor, Rgba } from '../../utils/color';
import { CloseIcon } from '../utils/icons';
import ColorPicker from '../utils/ColorPicker';

interface Props {
  visible: boolean;
  setVisible: React.Dispatch<React.SetStateAction<boolean>>;
}

const SAVE_DEBOUNCE = 400;

type SaveStatus = 'idle' | 'saving' | 'saved' | 'error';

type TabId = 'appearance' | PrefGroup;

const TABS: readonly TabId[] = ['appearance', ...PREF_GROUPS];

const GROUP_LABELS: Record<PrefGroup, string> = {
  display: 'Display',
  accessibility: 'Accessibility',
  behaviour: 'Behaviour',
  inventory: 'Inventory',
};

const GROUP_DESCRIPTIONS: Record<PrefGroup, string> = {
  display: 'Size, spacing, dimming and motion.',
  accessibility: 'Make item rarity readable without relying on colour alone.',
  behaviour: 'Tooltips, the hotbar and what a slot shows.',
  inventory: 'How items are ordered on screen. Nothing here moves an item.',
};

const prefGroupDescriptionKey = (group: PrefGroup) => `ui_prefs_desc_${group}`;

const THEME_TOKENS: ReadonlyArray<{ key: keyof ThemeColors; fallback: string }> = [
  { key: 'mainColor', fallback: 'Accent' },
  { key: 'secondaryColor', fallback: 'Secondary' },
  { key: 'rgbColor1', fallback: 'Icon tile centre' },
  { key: 'rgbColor2', fallback: 'Icon tile edge' },
  { key: 'backgroundColor1', fallback: 'Panel surface' },
  { key: 'backgroundColor2', fallback: 'Slot tint' },
  { key: 'backgroundColor3', fallback: 'Hover fill' },
  { key: 'textShadow', fallback: 'Text glow' },
  { key: 'photoShadowColor', fallback: 'Character glow' },
];


const localeToken = (key: keyof ThemeColors, fallback: string) => Locale[`ui_theme_${key}`] || fallback;

const PRESET_SWATCHES: readonly string[] = (() => {
  const seen: string[] = [];

  for (const name of THEME_PRESET_NAMES) {
    const preset = THEME_PRESETS[name];

    if (!preset) continue;

    for (const colour of [preset.mainColor, preset.secondaryColor]) {
      if (typeof colour === 'string' && colour && seen.indexOf(colour) === -1) seen.push(colour);
    }
  }

  return seen;
})();


const decimalsForStep = (step: number): number => {
  if (!Number.isFinite(step) || step >= 1) return 0;

  const text = String(step);
  const dot = text.indexOf('.');

  return dot === -1 ? 0 : Math.min(4, text.length - dot - 1);
};

const formatNumber = (def: NumberPrefDef, value: number): string => {
  const text = value.toFixed(decimalsForStep(def.step));

  return def.unit ? `${text} ${def.unit}` : text;
};

type PrefWriter = (key: PrefKey, value: PrefValue) => void;

const PrefRow: React.FC<{ def: PrefDef; onChange: PrefWriter }> = ({ def, onChange }) => {
  const label = Locale[prefLabelKey(def.key)] || def.label;
  const description = Locale[prefDescriptionKey(def.key)] || def.description;

  return (
    <div className="settings-pref" data-pref={def.key}>
      <div className="settings-pref-head">
        <span className="settings-pref-label">{label}</span>

        {def.kind === 'number' && (
          <span className="settings-pref-value">{formatNumber(def, getNumberPref(def.key))}</span>
        )}

        {def.kind === 'boolean' && (
          <button
            type="button"
            role="switch"
            aria-checked={getBooleanPref(def.key)}
            aria-label={label}
            className={`settings-toggle${getBooleanPref(def.key) ? ' settings-toggle-on' : ''}`}
            onClick={() => onChange(def.key, !getBooleanPref(def.key))}
          >
            <span className="settings-toggle-knob" />
          </button>
        )}

        {def.kind === 'stringArray' && <span className="settings-pref-value">{getListPref(def.key).length}</span>}
      </div>

      {description && <p className="settings-pref-desc">{description}</p>}

      {def.kind === 'number' && (
        <input
          className="settings-range"
          type="range"
          min={def.min}
          max={def.max}
          step={def.step}
          value={getNumberPref(def.key)}
          aria-label={label}
          aria-valuetext={formatNumber(def, getNumberPref(def.key))}
          onChange={(event) => onChange(def.key, Number(event.target.value))}
        />
      )}

      {def.kind === 'enum' && (
        <div className="settings-segment" role="group" aria-label={label}>
          {def.options.map((option) => {
            const active = getEnumPref(def.key) === option;

            return (
              <button
                key={option}
                type="button"
                aria-pressed={active}
                className={`settings-segment-option${active ? ' settings-segment-active' : ''}`}
                onClick={() => onChange(def.key, option)}
              >
                {Locale[prefOptionKey(def.key, option)] || option}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
};

const SettingsPanel: React.FC<Props> = ({ visible, setVisible }) => {
  const { refs, context } = useFloating({
    open: visible,
    onOpenChange: setVisible,
  });

  const dismiss = useDismiss(context, {
    outsidePressEvent: 'mousedown',
    escapeKey: false,
  });

  const { isMounted, styles } = useTransitionStyles(context);
  const { getFloatingProps } = useInteractions([dismiss]);

  const [tab, setTab] = useState<TabId>('appearance');
  const [direction, setDirection] = useState(1);
  const [indicator, setIndicator] = useState({ x: 0, y: 0, width: 0, height: 0, ready: false });
  const tabsRef = useRef<HTMLDivElement | null>(null);

  const selectTab = (id: TabId) => {
    if (id === tab) return;

    setDirection(TABS.indexOf(id) > TABS.indexOf(tab) ? 1 : -1);
    setTab(id);
  };

  useLayoutEffect(() => {
    const strip = tabsRef.current;

    if (!strip) return;

    const measure = () => {
      const active = strip.querySelector<HTMLElement>('.settings-tab-active');

      if (!active) return;

      setIndicator((prev) => ({
        x: active.offsetLeft,
        y: active.offsetTop,
        width: active.offsetWidth,
        height: active.offsetHeight,
        ready: prev.ready || active.offsetWidth > 0,
      }));
    };

    measure();

    const observer = new ResizeObserver(measure);

    observer.observe(strip);

    for (const child of Array.from(strip.children)) observer.observe(child);

    return () => observer.disconnect();
  }, [tab, isMounted]);

  const [themeName, setThemeName] = useState<string>(UiConfig.theme.name);
  const [text, setText] = useState<ThemeColors>(UiConfig.theme.colors);
  const [applied, setApplied] = useState<ThemeColors>(UiConfig.theme.colors);
  const [status, setStatus] = useState<SaveStatus>('idle');
  const [, setRevision] = useState(0);

  const mountedRef = useRef(true);
  const openRef = useRef(visible);
  const timerRef = useRef<number | undefined>(undefined);
  const themePendingRef = useRef<{ name: string; colors: ThemeColors } | undefined>(undefined);
  const swallowKeyupRef = useRef(false);

  openRef.current = visible;

  const settle = useCallback((saved: boolean) => {
    if (mountedRef.current) setStatus(saved ? 'saved' : 'error');
  }, []);

  const flush = useCallback(() => {
    if (timerRef.current !== undefined) {
      clearTimeout(timerRef.current);
      timerRef.current = undefined;
    }

    flushPrefs();

    const theme = themePendingRef.current;

    themePendingRef.current = undefined;

    if (!theme) return;

    if (mountedRef.current) setStatus('saving');

    fetchNui<boolean | undefined>('saveTheme', theme)
      .then((ok) => settle(!!ok))
      .catch(() => settle(false));
  }, [settle]);

  const arm = useCallback(() => {
    if (timerRef.current !== undefined) clearTimeout(timerRef.current);

    timerRef.current = window.setTimeout(flush, SAVE_DEBOUNCE);
  }, [flush]);

  const commit = useCallback(
    (name: string, colors: ThemeColors) => {
      setThemeName(name);
      setApplied(colors);
      setUiConfig({ theme: { name, colors } });

      themePendingRef.current = { name, colors };
      arm();
    },
    [arm]
  );

  const commitPrefs = useCallback(
    (partial: Record<string, PrefValue>) => {
      setPrefs(partial);

      if (mountedRef.current) setStatus('saving');

      persistPrefs(partial, settle);

      setRevision((current) => current + 1);
    },
    [settle]
  );

  const onPrefChange = useCallback<PrefWriter>(
    (key, value) => {
      if (getPref(key) === value) return;

      commitPrefs({ [key]: value });
    },
    [commitPrefs]
  );

  useEffect(() => {
    if (!visible) return;

    setThemeName(UiConfig.theme.name);
    setText(UiConfig.theme.colors);
    setApplied(UiConfig.theme.colors);
    setStatus('idle');
  }, [visible]);

  useEffect(() => {
    if (visible) return;

    flush();
  }, [visible, flush]);

  useEffect(() => {
    if (!visible) return;

    fetchNui('lockControls', true).catch(() => {});

    return () => {
      fetchNui('lockControls', false).catch(() => {});
    };
  }, [visible]);

  useEffect(() => {
    mountedRef.current = true;

    return () => {
      mountedRef.current = false;
      flush();
    };
  }, [flush]);

  useEffect(() => {
    if (!visible) return;

    const onChanged = () => setRevision((current) => current + 1);

    window.addEventListener(PREF_CHANGE_EVENT, onChanged);

    return () => window.removeEventListener(PREF_CHANGE_EVENT, onChanged);
  }, [visible]);

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.code !== 'Escape' || !openRef.current) return;

      event.preventDefault();
      event.stopImmediatePropagation();
      swallowKeyupRef.current = true;
      setVisible(false);
    };

    const onKeyUp = (event: KeyboardEvent) => {
      if (event.code !== 'Escape' || !swallowKeyupRef.current) return;

      swallowKeyupRef.current = false;
      event.preventDefault();
      event.stopImmediatePropagation();
    };

    window.addEventListener('keydown', onKeyDown, true);
    window.addEventListener('keyup', onKeyUp, true);

    return () => {
      window.removeEventListener('keydown', onKeyDown, true);
      window.removeEventListener('keyup', onKeyUp, true);
    };
  }, [setVisible]);

  const applyPreset = (name: string) => {
    const preset = THEME_PRESETS[name];

    if (!preset) return;

    setText(preset);
    commit(name, preset);
  };

  const setToken = (key: keyof ThemeColors, value: string) => {
    setText((current) => ({ ...current, [key]: value }));

    const parsed = parseColor(value);

    if (!parsed) return;

    commit(CUSTOM_THEME_NAME, {
      ...applied,
      [key]: formatColor(parsed, isFunctionalNotation(value) || parsed.a < 1),
    });
  };

  const setTokenFromPicker = (key: keyof ThemeColors, picked: Rgba) => {
    const value = formatColor(picked, isFunctionalNotation(applied[key]) || picked.a < 1);

    setText((state) => ({ ...state, [key]: value }));
    commit(CUSTOM_THEME_NAME, { ...applied, [key]: value });
  };

  const onReset = () => {
    if (tab === 'appearance') {
      const theme = resetTheme();

      setText(theme.colors);
      commit(theme.name, theme.colors);

      return;
    }

    const defaults: Record<string, PrefValue> = {};

    for (const def of getPreferences(tab)) {
      defaults[def.key] = def.kind === 'stringArray' ? def.default.slice() : def.default;
    }

    commitPrefs(defaults);
  };

  const tabLabel = (id: TabId) =>
    id === 'appearance' ? Locale.ui_appearance || 'Appearance' : Locale[prefGroupKey(id)] || GROUP_LABELS[id];

  const description =
    tab === 'appearance'
      ? Locale.ui_appearance_description || 'Pick a colour scheme for your inventory.'
      : Locale[prefGroupDescriptionKey(tab)] || GROUP_DESCRIPTIONS[tab];

  const statusLabel =
    status === 'saving'
      ? Locale.ui_settings_saving || Locale.ui_theme_saving || 'Saving…'
      : status === 'saved'
      ? Locale.ui_settings_saved || Locale.ui_theme_saved || 'Saved'
      : status === 'error'
      ? Locale.ui_settings_save_failed || Locale.ui_theme_save_failed || 'Not saved on this server'
      : '';

  const resetLabel =
    tab === 'appearance'
      ? Locale.ui_theme_reset || 'Reset to default'
      : Locale.ui_prefs_reset || 'Reset all to defaults';

  return (
    <>
      {isMounted && (
        <FloatingPortal>
          <FloatingOverlay lockScroll className="useful-controls-dialog-overlay" data-open={visible} style={styles}>
            <FloatingFocusManager context={context}>
              <div
                ref={refs.setFloating}
                {...getFloatingProps()}
                className="useful-controls-dialog settings-dialog"
                style={styles}
              >
                <div className="useful-controls-dialog-title">
                  <p>{Locale.ui_settings || 'Settings'}</p>
                  <div
                    className="useful-controls-dialog-close settings-dialog-close"
                    onClick={() => setVisible(false)}
                  >
                    <CloseIcon />
                  </div>
                </div>

                <div className="settings-tabs" role="tablist" ref={tabsRef}>
                  <span
                    aria-hidden="true"
                    className={`settings-tab-indicator${indicator.ready ? ' settings-tab-indicator-ready' : ''}`}
                    style={{
                      transform: `translate(${indicator.x}px, ${indicator.y}px)`,
                      width: indicator.width,
                      height: indicator.height,
                    }}
                  />
                  {TABS.map((id) => (
                    <button
                      key={id}
                      type="button"
                      role="tab"
                      aria-selected={tab === id}
                      className={`settings-tab${tab === id ? ' settings-tab-active' : ''}`}
                      onClick={() => selectTab(id)}
                    >
                      {tabLabel(id)}
                    </button>
                  ))}
                </div>

                <div className="settings-body">
                  <div key={tab} className="settings-tabpanel" data-direction={direction}>
                  <p className="settings-description">{description}</p>

                  {tab === 'appearance' ? (
                    <>
                      <section className="settings-section">
                        <p className="settings-section-title">{Locale.ui_theme_presets || 'Presets'}</p>
                        <div className="settings-presets">
                          {THEME_PRESET_NAMES.map((name) => {
                            const preset = THEME_PRESETS[name];

                            if (!preset) return null;

                            return (
                              <button
                                key={name}
                                type="button"
                                className={`settings-preset${themeName === name ? ' settings-preset-active' : ''}`}
                                onClick={() => applyPreset(name)}
                                aria-pressed={themeName === name}
                              >
                                <span
                                  className="settings-preset-swatch"
                                  style={{
                                    background: `linear-gradient(135deg, ${preset.mainColor} 0%, ${preset.secondaryColor} 100%)`,
                                  }}
                                />
                                <span className="settings-preset-label">{Locale[`ui_theme_${name}`] || name}</span>
                              </button>
                            );
                          })}
                        </div>
                      </section>

                      <section className="settings-section">
                        <div className="settings-section-head">
                          <p className="settings-section-title">{Locale.ui_theme_custom || 'Custom colours'}</p>
                          <span
                            className={`settings-section-tag${
                              themeName === CUSTOM_THEME_NAME ? ' settings-section-tag-on' : ''
                            }`}
                            aria-hidden={themeName !== CUSTOM_THEME_NAME}
                          >
                            {Locale.ui_theme_custom_active || 'Active'}
                          </span>
                        </div>

                        <div className="settings-tokens">
                          {THEME_TOKENS.map(({ key, fallback }) => {
                            const value = text[key];
                            const invalid = parseColor(value) === null;

                            return (
                              <div className="settings-token" key={key}>
                                <span className="settings-token-label">{localeToken(key, fallback)}</span>
                                <ColorPicker
                                  value={value}
                                  onChange={(picked) => setTokenFromPicker(key, picked)}
                                  swatches={PRESET_SWATCHES}
                                  ariaLabel={localeToken(key, fallback)}
                                />
                                <input
                                  className={`settings-token-text${invalid ? ' settings-token-invalid' : ''}`}
                                  type="text"
                                  value={value}
                                  spellCheck={false}
                                  onChange={(event) => setToken(key, event.target.value)}
                                  aria-label={localeToken(key, fallback)}
                                />
                              </div>
                            );
                          })}
                        </div>
                      </section>
                    </>
                  ) : (
                    <section className="settings-section">
                      <div className="settings-prefs">
                        {getPreferences(tab).map((def) => (
                          <PrefRow key={def.key} def={def} onChange={onPrefChange} />
                        ))}
                      </div>
                    </section>
                  )}
                  </div>
                </div>

                <div className="settings-footer">
                  <span className="settings-status">{statusLabel}</span>
                  <div className="settings-footer-actions">
                    <button type="button" className="settings-button" onClick={onReset}>
                      {resetLabel}
                    </button>
                    <button
                      type="button"
                      className="settings-button settings-button-primary"
                      onClick={() => setVisible(false)}
                    >
                      {Locale.ui_close || 'Close'}
                    </button>
                  </div>
                </div>
              </div>
            </FloatingFocusManager>
          </FloatingOverlay>
        </FloatingPortal>
      )}
    </>
  );
};

export default SettingsPanel;
