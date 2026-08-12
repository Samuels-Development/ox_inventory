import { useEffect, useState } from 'react';
import { canRotateItem } from '../helpers';
import { DragSource } from '../typings';

const isTextEntry = (target: EventTarget | null): boolean => {
  const element = target as HTMLElement | null;

  if (!element || !element.tagName) return false;

  return element.tagName === 'INPUT' || element.tagName === 'TEXTAREA' || element.isContentEditable;
};

export const useRotateKey = (source: DragSource | null): boolean => {
  const name = source?.item?.name;
  const rotatable = canRotateItem(name);
  const initial = source?.rotated === true;
  const [rotated, setRotated] = useState(initial);

  useEffect(() => {
    setRotated(initial);
  }, [source, initial]);

  useEffect(() => {
    if (!source || !rotatable) return;

    const onKeyDown = (event: KeyboardEvent) => {
      if (event.repeat || (event.key !== 'r' && event.key !== 'R') || isTextEntry(event.target)) return;

      event.preventDefault();
      setRotated((previous) => !previous);
    };

    window.addEventListener('keydown', onKeyDown);

    return () => window.removeEventListener('keydown', onKeyDown);
  }, [source, rotatable]);

  return rotatable ? rotated : initial;
};

export default useRotateKey;
