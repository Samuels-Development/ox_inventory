import React, { useState, useEffect } from 'react';
import InventoryComponent from './components/inventory';
import useNuiEvent from './hooks/useNuiEvent';
import { Items } from './store/items';
import { Locale } from './store/locale';
import { setImagePath } from './store/imagepath';
import { setUiConfig } from './store/uiConfig';
import { setPrefs } from './store/preferences';
import { setupInventory } from './store/inventory';
import { Inventory, UiConfigMessage } from './typings';
import { useAppDispatch } from './store';
import { debugData } from './utils/debugData';
import DragPreview from './components/utils/DragPreview';
import { fetchNui } from './utils/fetchNui';
import { useDragDropManager } from 'react-dnd';
import KeyPress from './components/utils/KeyPress';

debugData([
  {
    action: 'init',
    data: {
      locale: {},
      imagepath: 'images',
      leftInventory: { id: 'test', type: 'player', slots: 60, maxWeight: 5000, items: [] },
      items: {
        iron: { name: 'iron', label: 'Iron', stack: true, usable: false, close: false, count: 0, rarity: 'common' },
        copper: {
          name: 'copper',
          label: 'Copper',
          stack: true,
          usable: false,
          close: false,
          count: 0,
          rarity: 'uncommon',
        },
        powersaw: {
          name: 'powersaw',
          label: 'Power Saw',
          stack: false,
          usable: false,
          close: false,
          count: 0,
          rarity: 'rare',
          grid: [2, 1],
        },
        lockpick: {
          name: 'lockpick',
          label: 'Lockpick',
          stack: false,
          usable: true,
          close: true,
          count: 0,
          rarity: 'uncommon',
          grid: [1, 2],
        },
        backwoods: {
          name: 'backwoods',
          label: 'Backwoods',
          stack: false,
          usable: true,
          close: false,
          count: 0,
          rarity: 'legendary',
        },
        armour: {
          name: 'armour',
          label: 'Body Armour',
          stack: false,
          usable: true,
          close: true,
          count: 0,
          rarity: 'epic',
          grid: [2, 2],
          clothing: 'armour',
        },
      },
      uiConfig: {
        layout: 'slots',
        grid: { columns: 10, allowRotate: true },
        clothing: {
          enabled: true,
          slots: [
            { index: 51, name: 'hat', label: 'Hat', side: 'left' },
            { index: 52, name: 'glasses', label: 'Glasses', side: 'left' },
            { index: 53, name: 'mask', label: 'Mask', side: 'left' },
            { index: 54, name: 'earpiece', label: 'Earpiece', side: 'left' },
            { index: 55, name: 'torso', label: 'Torso', side: 'left' },
            { index: 56, name: 'armour', label: 'Armour', side: 'right' },
            { index: 57, name: 'backpack', label: 'Backpack', side: 'right' },
            { index: 58, name: 'gloves', label: 'Gloves', side: 'right' },
            { index: 59, name: 'legs', label: 'Legs', side: 'right' },
            { index: 60, name: 'shoes', label: 'Shoes', side: 'right' },
          ],
        },
        rarity: {
          enabled: true,
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
      },
    },
  },
]);

debugData([
  {
    action: 'setupInventory',
    data: {
      leftInventory: {
        id: 'test',
        type: 'player',
        slots: 60,
        label: 'Bob Smith',
        weight: 3000,
        maxWeight: 5000,
        items: [
          {
            slot: 1,
            name: 'iron',
            weight: 3000,
            metadata: {
              description: `name: Svetozar Miletic  \n Gender: Male`,
              ammo: 3,
              mustard: '60%',
              ketchup: '30%',
              mayo: '10%',
            },
            count: 5,
          },
          { slot: 2, name: 'powersaw', weight: 0, count: 1, metadata: { durability: 75 } },
          { slot: 3, name: 'copper', weight: 100, count: 12, metadata: { type: 'Special' } },
          {
            slot: 4,
            name: 'water',
            weight: 100,
            count: 1,
            metadata: { description: 'Generic item description' },
          },
          { slot: 5, name: 'water', weight: 100, count: 1 },
          {
            slot: 6,
            name: 'backwoods',
            weight: 100,
            count: 1,
            metadata: {
              label: 'Russian Cream',
              imageurl: 'https://i.imgur.com/2xHhTTz.png',
            },
          },
          { slot: 7, name: 'armour', weight: 3000, count: 1 },
        ],
      },
      rightInventory: {
        id: 'shop',
        type: 'crafting',
        slots: 5000,
        label: 'Bob Smith',
        weight: 3000,
        maxWeight: 5000,
        items: [
          {
            slot: 1,
            name: 'lockpick',
            weight: 500,
            price: 300,
            ingredients: {
              iron: 5,
              copper: 12,
              powersaw: 0.1,
            },
            metadata: {
              description: 'Simple lockpick that breaks easily and can pick basic door locks',
            },
          },
        ],
      },
    },
  },
]);

const App: React.FC = () => {
  const dispatch = useAppDispatch();
  const manager = useDragDropManager();
  const [noBackdrop, setNoBackdrop] = useState(false);

  useNuiEvent<{
    locale: { [key: string]: string };
    items: typeof Items;
    leftInventory: Inventory;
    imagepath: string;
    uiConfig?: UiConfigMessage;
    backpackInventory?: Inventory;
  }>('init', ({ locale, items, leftInventory, imagepath, uiConfig, backpackInventory }) => {
    for (const name in locale) Locale[name] = locale[name];
    for (const name in items) Items[name] = items[name];

    setImagePath(imagepath);
    setUiConfig(uiConfig);
    setPrefs(uiConfig?.prefs);
    dispatch(setupInventory({ leftInventory, backpackInventory }));
  });

  fetchNui('uiLoaded', {});

  useNuiEvent('closeInventory', () => {
    manager.dispatch({ type: 'dnd-core/END_DRAG' });
    setNoBackdrop(false); // Reset on close
  });

  useNuiEvent<boolean>('setNoBackdrop', setNoBackdrop);

  // Apply no-backdrop-mode class to body and #root for proper pointer-events passthrough
  useEffect(() => {
    const root = document.getElementById('root');
    if (noBackdrop) {
      document.body.classList.add('no-backdrop-mode');
      root?.classList.add('no-backdrop-mode');
    } else {
      document.body.classList.remove('no-backdrop-mode');
      root?.classList.remove('no-backdrop-mode');
    }
  }, [noBackdrop]);

  // When in no-backdrop mode, detect clicks on the right side and transfer focus to sd-crafting
  useEffect(() => {
    if (!noBackdrop) return;

    const handleClick = (e: MouseEvent) => {
      const screenMidpoint = window.innerWidth / 2;
      if (e.clientX > screenMidpoint) {
        // Click was on the right side - transfer focus to sd-crafting
        fetchNui('transferFocusToCrafting', {});
      }
    };

    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, [noBackdrop]);

  return (
    <div className={`app-wrapper${noBackdrop ? ' no-backdrop-mode' : ''}`}>
      <InventoryComponent />
      <DragPreview />
      <KeyPress />
    </div>
  );
};

addEventListener("dragstart", function(event) {
  event.preventDefault()
})

export default App;
