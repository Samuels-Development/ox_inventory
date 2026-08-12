import React, { useEffect, useRef, useState } from 'react';
import { Items } from '../../store/items';
import { Locale } from '../../store/locale';
import { prefOptionKey, SORT_MODES, SortMode } from '../../store/preferences';
import { UiConfig } from '../../store/uiConfig';
import { getSortMode, isSortAvailable, PREF_CHANGE_EVENT } from '../../helpers';
import Dropdown from '../utils/Dropdown';
import { FoodIcon, MedicalIcon, ShirtIcon, WeaponIcon } from '../utils/icons';

export type FilterId = 'weapon' | 'medical' | 'food' | 'clothing';

const DEFAULT_FILTER_ITEMS: Record<FilterId, string[]> = {
  weapon: [],
  medical: ['bandage', 'medikit', 'medkit', 'firstaid', 'painkillers', 'ifak', 'defibrillator'],
  food: ['burger', 'sandwich', 'taco', 'pizza', 'water', 'water_bottle', 'cola', 'coffee'],
  clothing: [],
};

const FILTERS: { id: FilterId; localeKey: string; fallback: string; icon: React.FC }[] = [
  { id: 'weapon', localeKey: 'ui_filter_weapons', fallback: 'Weapons', icon: WeaponIcon },
  { id: 'medical', localeKey: 'ui_filter_medical', fallback: 'Medical', icon: MedicalIcon },
  { id: 'food', localeKey: 'ui_filter_food', fallback: 'Food', icon: FoodIcon },
  { id: 'clothing', localeKey: 'ui_filter_clothing', fallback: 'Clothing', icon: ShirtIcon },
];

const getFilterItems = (id: FilterId): string[] => {
  const configured = (UiConfig as { filters?: Record<string, string[]> }).filters?.[id];

  return Array.isArray(configured) && configured.length > 0 ? configured : DEFAULT_FILTER_ITEMS[id];
};

export const matchesFilter = (name: string, id: FilterId): boolean => {
  const lowerName = name.toLowerCase();

  if (getFilterItems(id).includes(lowerName)) return true;

  switch (id) {
    case 'weapon':
      return lowerName.startsWith('weapon_') || lowerName.startsWith('ammo-') || Items[name]?.ammoName !== undefined;
    case 'clothing':
      return Items[name]?.clothing !== undefined;
    default:
      return false;
  }
};

interface InventoryFiltersProps {
  active: FilterId | null;
  onChange: (next: FilterId | null) => void;
  showChips?: boolean;
  sort?: React.ReactNode;
}

const InventoryFilters: React.FC<InventoryFiltersProps> = ({ active, onChange, showChips = true, sort }) => (
  <div className="filters">
    {showChips && (
      <>
        <button
          type="button"
          className={`filter ${active === null ? 'filter-active' : ''}`}
          title={Locale.ui_filter_all || 'All'}
          onClick={() => onChange(null)}
        >
          <span className="filter-text">{Locale.ui_filter_all || 'All'}</span>
        </button>
        {FILTERS.map(({ id, localeKey, fallback, icon: Icon }) => (
          <button
            type="button"
            key={`filter-${id}`}
            className={`filter ${active === id ? 'filter-active' : ''}`}
            title={Locale[localeKey] || fallback}
            onClick={() => onChange(active === id ? null : id)}
          >
            <Icon />
          </button>
        ))}
      </>
    )}

    {sort && (
      <div className="filters-sort">
        <span className="filters-sort-label">{Locale.ui_sort || 'Sort'}</span>
        {sort}
      </div>
    )}
  </div>
);

export default InventoryFilters;


export const usePrefsRevision = (): number => {
  const [revision, setRevision] = useState(0);

  useEffect(() => {
    const onChange = () => setRevision((current) => current + 1);

    window.addEventListener(PREF_CHANGE_EVENT, onChange);

    return () => window.removeEventListener(PREF_CHANGE_EVENT, onChange);
  }, []);

  return revision;
};

const SORT_LABELS: Record<SortMode, string> = {
  slot: 'Slot',
  name: 'Name',
  weight: 'Weight',
  rarity: 'Rarity',
  count: 'Count',
};

const GRID_UNAVAILABLE_FALLBACK =
  'Sorting is unavailable in grid layout: an item covers several cells from its slot, so ' +
  'reordering the display alone would tear its footprint apart. Repacking would have to happen ' +
  'on the server.';

export const usePanelSortMode = (): [SortMode, (next: SortMode) => void] => {
  const prefsRevision = usePrefsRevision();
  const preferred = getSortMode();
  const [mode, setMode] = useState<SortMode>(preferred);
  const lastPreferred = useRef(preferred);

  useEffect(() => {
    if (lastPreferred.current === preferred) return;

    lastPreferred.current = preferred;
    setMode(preferred);
  }, [preferred, prefsRevision]);

  return [mode, setMode];
};

interface InventorySortProps {
  value: SortMode;
  onChange: (next: SortMode) => void;
}

export const InventorySort: React.FC<InventorySortProps> = ({ value, onChange }) => {
  const available = isSortAvailable();

  const label = Locale.ui_pref_sortMode || 'Sort items by';
  const title = available ? label : Locale.ui_sort_unavailable_grid || GRID_UNAVAILABLE_FALLBACK;

  const options = SORT_MODES.map((option) => ({
    value: option,
    label: Locale[prefOptionKey('sortMode', option)] || SORT_LABELS[option],
  }));

  return (
    <Dropdown
      className="inventory-sort"
      value={value}
      options={options}
      disabled={!available}
      title={title}
      ariaLabel={label}
      onChange={(next) => onChange(next as SortMode)}
    />
  );
};
