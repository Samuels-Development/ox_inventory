import { useSyncExternalStore } from 'react';

const collapsed = new Set<string>();
const listeners = new Set<() => void>();

const emit = () => listeners.forEach((listener) => listener());

const subscribe = (listener: () => void) => {
  listeners.add(listener);

  return () => {
    listeners.delete(listener);
  };
};

export const togglePanelCollapsed = (id: string) => {
  if (!id) return;

  if (collapsed.has(id)) collapsed.delete(id);
  else collapsed.add(id);

  emit();
};

export const resetCollapsedPanels = () => {
  if (collapsed.size === 0) return;

  collapsed.clear();
  emit();
};

export const usePanelCollapsed = (id: string): boolean =>
  useSyncExternalStore(subscribe, () => collapsed.has(id));
