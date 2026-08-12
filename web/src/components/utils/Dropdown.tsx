import React, { useRef, useState } from 'react';
import {
  autoUpdate,
  flip,
  FloatingFocusManager,
  FloatingPortal,
  offset,
  shift,
  size,
  useClick,
  useDismiss,
  useFloating,
  useInteractions,
  useListNavigation,
  useRole,
  useTransitionStyles,
} from '@floating-ui/react';
import { CheckIcon, ChevronIcon } from './icons';
import { fetchNui } from '../../utils/fetchNui';

export interface DropdownOption {
  value: string;
  label: string;
}

interface DropdownProps {
  value: string;
  options: readonly DropdownOption[];
  onChange: (value: string) => void;
  disabled?: boolean;
  title?: string;
  ariaLabel?: string;
  className?: string;
}

const Dropdown: React.FC<DropdownProps> = ({
  value,
  options,
  onChange,
  disabled,
  title,
  ariaLabel,
  className,
}) => {
  const [open, setOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState<number | null>(null);
  const listRef = useRef<Array<HTMLElement | null>>([]);

  const selectedIndex = options.findIndex((option) => option.value === value);
  const selected = selectedIndex >= 0 ? options[selectedIndex] : undefined;

  const setOpenState = (next: boolean) => {
    if (disabled) return;

    setOpen(next);
    fetchNui('lockControls', next);
  };

  const { refs, floatingStyles, context } = useFloating({
    open,
    onOpenChange: setOpenState,
    placement: 'bottom-start',
    whileElementsMounted: autoUpdate,
    middleware: [
      offset(4),
      flip({ padding: 8 }),
      shift({ padding: 8 }),
      size({
        padding: 8,
        apply({ rects, availableHeight, elements }) {
          elements.floating.style.minWidth = `${rects.reference.width}px`;
          elements.floating.style.setProperty('--ox-dd-max-h', `${Math.max(96, availableHeight)}px`);
        },
      }),
    ],
  });

  const click = useClick(context, { enabled: !disabled });
  const dismiss = useDismiss(context, { outsidePressEvent: 'mousedown' });
  const role = useRole(context, { role: 'listbox' });
  const listNavigation = useListNavigation(context, {
    listRef,
    activeIndex,
    selectedIndex: selectedIndex >= 0 ? selectedIndex : null,
    onNavigate: setActiveIndex,
    loop: true,
  });

  const { getReferenceProps, getFloatingProps, getItemProps } = useInteractions([
    click,
    dismiss,
    role,
    listNavigation,
  ]);

  const { isMounted, styles: transitionStyles } = useTransitionStyles(context, {
    duration: 140,
    initial: { opacity: 0, transform: 'translateY(-0.4vh) scale(0.98)' },
  });

  const commit = (next: string) => {
    onChange(next);
    setOpenState(false);
  };

  return (
    <>
      <button
        type="button"
        ref={refs.setReference}
        className={`ox-dropdown${open ? ' ox-dropdown-open' : ''}${className ? ` ${className}` : ''}`}
        disabled={disabled}
        title={title}
        aria-label={ariaLabel || title}
        onMouseDown={(event) => event.stopPropagation()}
        {...getReferenceProps({ onClick: (event) => event.stopPropagation() })}
      >
        <span className="ox-dropdown-value">{selected ? selected.label : value}</span>
        <span className="ox-dropdown-chevron">
          <ChevronIcon />
        </span>
      </button>

      {isMounted && (
        <FloatingPortal>
          <FloatingFocusManager context={context} modal={false}>
            <div
              ref={refs.setFloating}
              className="ox-dropdown-floating"
              style={floatingStyles}
              onMouseDown={(event) => event.stopPropagation()}
              {...getFloatingProps()}
            >
              <div className="ox-dropdown-menu" style={transitionStyles}>
              {options.map((option, index) => {
                const isSelected = option.value === value;

                return (
                  <button
                    key={option.value}
                    type="button"
                    role="option"
                    aria-selected={isSelected}
                    ref={(node) => {
                      listRef.current[index] = node;
                    }}
                    className={`ox-dropdown-option${isSelected ? ' ox-dropdown-option-selected' : ''}${
                      activeIndex === index ? ' ox-dropdown-option-active' : ''
                    }`}
                    {...getItemProps({
                      onClick: (event) => {
                        event.stopPropagation();
                        commit(option.value);
                      },
                    })}
                  >
                    <span className="ox-dropdown-option-label">{option.label}</span>
                    <span className="ox-dropdown-option-check">{isSelected && <CheckIcon />}</span>
                  </button>
                );
              })}
              </div>
            </div>
          </FloatingFocusManager>
        </FloatingPortal>
      )}
    </>
  );
};

export default Dropdown;
