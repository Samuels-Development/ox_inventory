import React, { useEffect, useState } from 'react';
import useNuiEvent from '../../hooks/useNuiEvent';
import InventoryControl from './InventoryControl';
import SettingsPanel from './SettingsPanel';
import InventoryHotbar from './InventoryHotbar';
import ClothingPanel from './ClothingPanel';
import { useAppDispatch } from '../../store';
import { refreshSlots, setAdditionalMetadata, setupInventory } from '../../store/inventory';
import { useExitListener } from '../../hooks/useExitListener';
import type { Inventory as InventoryProps } from '../../typings';
import BackpackInventory, { useShowBackpack } from './BackpackInventory';
import RightInventory from './RightInventory';
import LeftInventory from './LeftInventory';
import Tooltip from '../utils/Tooltip';
import { closeTooltip } from '../../store/tooltip';
import InventoryContext from './InventoryContext';
import { closeContextMenu } from '../../store/contextMenu';
import Fade from '../utils/transitions/Fade';
import { Locale } from '../../store/locale';
import { UiConfig } from '../../store/uiConfig';
import { SettingsIcon } from '../utils/icons';
import { fetchNui } from '../../utils/fetchNui';

const Inventory: React.FC = () => {
  const [inventoryVisible, setInventoryVisible] = useState(false);
  const [settingsVisible, setSettingsVisible] = useState(false);
  const dispatch = useAppDispatch();
  const showBackpack = useShowBackpack();

  useNuiEvent<boolean>('setInventoryVisible', setInventoryVisible);
  useNuiEvent<false>('closeInventory', () => {
    setInventoryVisible(false);
    dispatch(closeContextMenu());
    dispatch(closeTooltip());
  });
  useExitListener(setInventoryVisible);

  useNuiEvent<{
    leftInventory?: InventoryProps;
    rightInventory?: InventoryProps;
    backpackInventory?: InventoryProps;
  }>('setupInventory', (data) => {
    dispatch(setupInventory(data));
    !inventoryVisible && setInventoryVisible(true);
  });

  useNuiEvent('refreshSlots', (data) => dispatch(refreshSlots(data)));

  useNuiEvent('displayMetadata', (data: Array<{ metadata: string; value: string }>) => {
    dispatch(setAdditionalMetadata(data));
  });

  useEffect(() => {
    if (!inventoryVisible) setSettingsVisible(false);
  }, [inventoryVisible]);

  const pedFocus = UiConfig.clothing.enabled && UiConfig.clothing.slots.length > 0;

  return (
    <>
      <Fade in={inventoryVisible}>
        <div className={`inventory-wrapper${pedFocus ? ' ped-focus' : ''}`}>
          <div className={`inventory-stage layout-${UiConfig.layout === 'grid' ? 'grid' : 'slots'}`}>
            <div className="inventory-side left">
              <LeftInventory />
            </div>

            <div className="inventory-centre">
              {pedFocus && <ClothingPanel />}
              <InventoryControl />
            </div>

            <div className={`inventory-side right${showBackpack ? ' split' : ''}`}>
              <RightInventory />
              <BackpackInventory />
            </div>
          </div>

          <div className="inventory-chrome">
            <button
              className="inventory-chrome-icon"
              type="button"
              title={Locale.ui_settings || 'Settings'}
              aria-label={Locale.ui_settings || 'Settings'}
              onClick={() => setSettingsVisible(true)}
            >
              <SettingsIcon />
            </button>

            <button className="inventory-close" type="button" onClick={() => fetchNui('exit')}>
              <span className="inventory-close-label">{Locale.ui_closeInv || 'Close Inventory'}</span>
              <span className="inventory-close-key">{Locale.ui_esc || 'ESC'}</span>
            </button>
          </div>

          <Tooltip />
          <InventoryContext />
        </div>
      </Fade>
      <SettingsPanel visible={settingsVisible} setVisible={setSettingsVisible} />
      <InventoryHotbar />
    </>
  );
};

export default Inventory;
