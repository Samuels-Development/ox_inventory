import React, { useEffect, useRef, useState } from 'react';
import {
  autoUpdate,
  flip,
  FloatingFocusManager,
  FloatingPortal,
  offset,
  shift,
  useClick,
  useDismiss,
  useFloating,
  useInteractions,
  useRole,
  useTransitionStyles,
} from '@floating-ui/react';
import {
  clamp,
  Hsv,
  hsvToRgb,
  parseColor,
  Rgba,
  rgbToHsv,
  sameColor,
  toCss,
  toHex,
} from '../../utils/color';
import { fetchNui } from '../../utils/fetchNui';

interface ColorPickerProps {
  value: string;
  onChange: (next: Rgba) => void;
  swatches?: readonly string[];
  ariaLabel?: string;
}

const FALLBACK: Rgba = { r: 0, g: 0, b: 0, a: 1 };

const useDragTrack = (onMove: (x: number, y: number, rect: DOMRect) => void) => {
  const ref = useRef<HTMLDivElement>(null);

  const emit = (clientX: number, clientY: number) => {
    const node = ref.current;

    if (!node) return;

    const rect = node.getBoundingClientRect();

    if (rect.width === 0 || rect.height === 0) return;

    onMove(clamp((clientX - rect.left) / rect.width, 0, 1), clamp((clientY - rect.top) / rect.height, 0, 1), rect);
  };

  const onPointerDown = (event: React.PointerEvent<HTMLDivElement>) => {
    event.preventDefault();
    event.stopPropagation();
    event.currentTarget.setPointerCapture(event.pointerId);
    emit(event.clientX, event.clientY);
  };

  const onPointerMove = (event: React.PointerEvent<HTMLDivElement>) => {
    if (!event.currentTarget.hasPointerCapture(event.pointerId)) return;

    emit(event.clientX, event.clientY);
  };

  return { ref, onPointerDown, onPointerMove };
};

const ColorPicker: React.FC<ColorPickerProps> = ({ value, onChange, swatches, ariaLabel }) => {
  const [open, setOpen] = useState(false);

  const parsed = parseColor(value) || FALLBACK;

  const [hsv, setHsv] = useState<Hsv>(() => rgbToHsv(parsed));
  const [alpha, setAlpha] = useState(parsed.a);

  const emitted = useRef<Rgba | null>(null);

  useEffect(() => {
    const next = parseColor(value);

    if (!next || sameColor(next, emitted.current)) return;

    const converted = rgbToHsv(next);

    setHsv((current) => ({ h: converted.s === 0 ? current.h : converted.h, s: converted.s, v: converted.v }));
    setAlpha(next.a);
  }, [value]);

  const commit = (nextHsv: Hsv, nextAlpha: number) => {
    const rgb = hsvToRgb(nextHsv);
    const next: Rgba = { ...rgb, a: nextAlpha };

    emitted.current = next;
    onChange(next);
  };

  const setOpenState = (next: boolean) => {
    setOpen(next);
    fetchNui('lockControls', next);
  };

  const { refs, floatingStyles, context } = useFloating({
    open,
    onOpenChange: setOpenState,
    placement: 'bottom-end',
    whileElementsMounted: autoUpdate,
    middleware: [offset(6), flip({ padding: 8 }), shift({ padding: 8 })],
  });

  const click = useClick(context);
  const dismiss = useDismiss(context, { outsidePressEvent: 'mousedown' });
  const role = useRole(context, { role: 'dialog' });

  const { getReferenceProps, getFloatingProps } = useInteractions([click, dismiss, role]);

  const { isMounted, styles: transitionStyles } = useTransitionStyles(context, {
    duration: 140,
    initial: { opacity: 0, transform: 'translateY(-0.4vh) scale(0.98)' },
  });

  const area = useDragTrack((x, y) => {
    const next = { ...hsv, s: x, v: 1 - y };

    setHsv(next);
    commit(next, alpha);
  });

  const hueTrack = useDragTrack((x) => {
    const next = { ...hsv, h: x * 360 };

    setHsv(next);
    commit(next, alpha);
  });

  const alphaTrack = useDragTrack((x) => {
    const next = Math.round(x * 100) / 100;

    setAlpha(next);
    commit(hsv, next);
  });

  const current: Rgba = { ...hsvToRgb(hsv), a: alpha };
  const opaque = toHex(current);
  const hueColor = toHex({ ...hsvToRgb({ h: hsv.h, s: 1, v: 1 }), a: 1 });

  return (
    <>
      <button
        type="button"
        ref={refs.setReference}
        className={`ox-color-swatch${open ? ' ox-color-swatch-open' : ''}`}
        aria-label={ariaLabel}
        title={ariaLabel}
        onMouseDown={(event) => event.stopPropagation()}
        {...getReferenceProps({ onClick: (event) => event.stopPropagation() })}
      >
        <span className="ox-color-swatch-fill" style={{ background: toCss(current) }} />
      </button>

      {isMounted && (
        <FloatingPortal>
          <FloatingFocusManager context={context} modal={false}>
            <div
              ref={refs.setFloating}
              className="ox-color-floating"
              style={floatingStyles}
              onMouseDown={(event) => event.stopPropagation()}
              {...getFloatingProps()}
            >
              <div className="ox-color-panel" style={transitionStyles}>
                <div
                  ref={area.ref}
                  className="ox-color-area"
                  style={{ backgroundColor: hueColor }}
                  onPointerDown={area.onPointerDown}
                  onPointerMove={area.onPointerMove}
                >
                  <div className="ox-color-area-white" />
                  <div className="ox-color-area-black" />
                  <span
                    className="ox-color-handle"
                    style={{ left: `${hsv.s * 100}%`, top: `${(1 - hsv.v) * 100}%`, background: opaque }}
                  />
                </div>

                <div className="ox-color-sliders">
                  <div
                    ref={hueTrack.ref}
                    className="ox-color-track ox-color-hue"
                    onPointerDown={hueTrack.onPointerDown}
                    onPointerMove={hueTrack.onPointerMove}
                  >
                    <span
                      className="ox-color-handle ox-color-handle-track"
                      style={{ left: `${(hsv.h / 360) * 100}%`, background: hueColor }}
                    />
                  </div>

                  <div
                    ref={alphaTrack.ref}
                    className="ox-color-track ox-color-alpha"
                    onPointerDown={alphaTrack.onPointerDown}
                    onPointerMove={alphaTrack.onPointerMove}
                  >
                    <span
                      className="ox-color-alpha-fill"
                      style={{ backgroundImage: `linear-gradient(to right, ${toCss({ ...current, a: 0 })}, ${opaque})` }}
                    />
                    <span
                      className="ox-color-handle ox-color-handle-track"
                      style={{ left: `${alpha * 100}%`, background: toCss(current) }}
                    />
                  </div>
                </div>

                {swatches && swatches.length > 0 && (
                  <div className="ox-color-swatches">
                    {swatches.map((preset, index) => {
                      const presetRgba = parseColor(preset);

                      if (!presetRgba) return null;

                      return (
                        <button
                          key={`${preset}-${index}`}
                          type="button"
                          className="ox-color-preset"
                          style={{ background: toCss(presetRgba) }}
                          title={preset}
                          aria-label={preset}
                          onClick={(event) => {
                            event.stopPropagation();

                            const converted = rgbToHsv(presetRgba);
                            const nextHsv = {
                              h: converted.s === 0 ? hsv.h : converted.h,
                              s: converted.s,
                              v: converted.v,
                            };

                            setHsv(nextHsv);
                            setAlpha(presetRgba.a);
                            commit(nextHsv, presetRgba.a);
                          }}
                        />
                      );
                    })}
                  </div>
                )}
              </div>
            </div>
          </FloatingFocusManager>
        </FloatingPortal>
      )}
    </>
  );
};

export default ColorPicker;
