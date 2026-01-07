import React from 'react';
import { useDrop } from 'react-dnd';
import { useAppDispatch, useAppSelector } from '../../store';
import { selectItemAmount, setItemAmount } from '../../store/inventory';
import { DragSource } from '../../typings';
import { onUse } from '../../dnd/onUse';
import { onGive } from '../../dnd/onGive';
import { fetchNui } from '../../utils/fetchNui';
import { Locale } from '../../store/locale';

const InventoryControl: React.FC = () => {
  const itemAmount = useAppSelector(selectItemAmount);
  const dispatch = useAppDispatch();

  const [, use] = useDrop<DragSource, void, any>(() => ({
    accept: 'SLOT',
    drop: (source) => {
      source.inventory === 'player' && onUse(source.item);
    },
  }));

  const [, give] = useDrop<DragSource, void, any>(() => ({
    accept: 'SLOT',
    drop: (source) => {
      source.inventory === 'player' && onGive(source.item);
    },
  }));

  const handleAmountChange = (value: number) => {
    const newValue = Math.max(0, Math.min(999, value));
    dispatch(setItemAmount(newValue));
  };

  const inputHandler = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = parseInt(event.target.value) || 0;
    handleAmountChange(value);
  };

  return (
    <div className="inventory-control">
      <div className="inventory-control-wrapper">
        {/* Amount input with up/down arrows */}
        <div className="inventory-control-amount">
          <input
            className="inventory-control-input"
            type="number"
            value={itemAmount}
            onChange={inputHandler}
            min={0}
            max={999}
            placeholder="0"
          />
          <div className="inventory-control-arrows">
            <button
              className="inventory-control-arrow"
              onClick={() => handleAmountChange(itemAmount + 1)}
            >
              <svg viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M14.707 12.707a1 1 0 01-1.414 0L10 9.414l-3.293 3.293a1 1 0 01-1.414-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 010 1.414z" clipRule="evenodd" />
              </svg>
            </button>
            <button
              className="inventory-control-arrow arrow-down"
              onClick={() => handleAmountChange(itemAmount - 1)}
            >
              <svg viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
              </svg>
            </button>
          </div>
        </div>

        <button className="inventory-control-button" ref={use}>
          {Locale.ui_use || 'Use'}
        </button>
        <button className="inventory-control-button" ref={give}>
          {Locale.ui_give || 'Give'}
        </button>
        <button className="inventory-control-button" onClick={() => fetchNui('exit')}>
          {Locale.ui_close || 'Close'}
        </button>
      </div>
    </div>
  );
};

export default InventoryControl;
