import React from 'react';
import { useDrop } from 'react-dnd';
import { useAppDispatch, useAppSelector } from '../../store';
import { selectItemAmount, setItemAmount } from '../../store/inventory';
import { DragSource } from '../../typings';
import { onUse } from '../../dnd/onUse';
import { onGive } from '../../dnd/onGive';
import { Locale } from '../../store/locale';
import { GiveIcon, UseIcon } from '../utils/icons';

const MAX_AMOUNT = 99999;

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

  const inputHandler = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = parseInt(event.target.value) || 0;

    dispatch(setItemAmount(Math.max(0, Math.min(MAX_AMOUNT, value))));
  };

  return (
    <div className="inventory-control">
      <div className="inventory-control-wrapper">
        <button className="inventory-control-button" ref={use} type="button">
          <UseIcon />
          <div className="text">{Locale.ui_use || 'Use'}</div>
        </button>

        <div className="inventory-control-amount">
          <input
            className="inventory-control-input"
            type="number"
            value={itemAmount}
            onChange={inputHandler}
            min={0}
            max={MAX_AMOUNT}
            placeholder="0"
          />
          <div className="text">{Locale.ui_amount || 'Amount'}</div>
        </div>

        <button className="inventory-control-button" ref={give} type="button">
          <GiveIcon />
          <div className="text">{Locale.ui_give || 'Give'}</div>
        </button>
      </div>
    </div>
  );
};

export default InventoryControl;
