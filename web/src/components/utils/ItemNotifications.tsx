import React, { useContext } from 'react';
import { createPortal } from 'react-dom';
import { TransitionGroup } from 'react-transition-group';
import useNuiEvent from '../../hooks/useNuiEvent';
import useQueue from '../../hooks/useQueue';
import { Locale } from '../../store/locale';
import { getItemUrl } from '../../helpers';
import { SlotWithItem } from '../../typings';
import { Items } from '../../store/items';
import Fade from './transitions/Fade';

interface ItemNotificationProps {
  item: SlotWithItem;
  text: string;
}

export const ItemNotificationsContext = React.createContext<{
  add: (item: ItemNotificationProps) => void;
} | null>(null);

export const useItemNotifications = () => {
  const itemNotificationsContext = useContext(ItemNotificationsContext);
  if (!itemNotificationsContext) throw new Error(`ItemNotificationsContext undefined`);
  return itemNotificationsContext;
};

const ItemNotification = React.forwardRef(
  (props: { item: ItemNotificationProps; style?: React.CSSProperties }, ref: React.ForwardedRef<HTMLDivElement>) => {
    const slotItem = props.item.item;
    const itemLabel = slotItem.metadata?.label || Items[slotItem.name]?.label || slotItem.name;

    return (
      <div className="item-notification-box" style={props.style} ref={ref}>
        {/* Action badge */}
        <div className="item-notification-action">
          <span>{props.item.text}</span>
        </div>

        {/* Item image */}
        <div className="item-notification-image-wrapper">
          <img
            src={getItemUrl(slotItem)}
            alt={slotItem.name}
            className="item-notification-image"
            draggable={false}
          />
        </div>

        {/* Item label */}
        <div className="item-notification-label">
          {itemLabel}
        </div>
      </div>
    );
  }
);

export const ItemNotificationsProvider = ({ children }: { children: React.ReactNode }) => {
  const queue = useQueue<{
    id: number;
    item: ItemNotificationProps;
    ref: React.RefObject<HTMLDivElement>;
  }>();

  const add = (item: ItemNotificationProps) => {
    const ref = React.createRef<HTMLDivElement>();
    const notification = { id: Date.now(), item, ref: ref };

    queue.add(notification);

    const timeout = setTimeout(() => {
      queue.remove();
      clearTimeout(timeout);
    }, 2500);
  };

  useNuiEvent<[item: SlotWithItem, text: string, count?: number]>('itemNotify', ([item, text, count]) => {
    add({ item: item, text: count ? `${Locale[text]} ${count}x` : `${Locale[text]}` });
  });

  return (
    <ItemNotificationsContext.Provider value={{ add }}>
      {children}
      {createPortal(
        <TransitionGroup className="item-notification-container">
          {queue.values.map((notification, index) => (
            <Fade key={`item-notification-${index}`}>
              <ItemNotification item={notification.item} ref={notification.ref} />
            </Fade>
          ))}
        </TransitionGroup>,
        document.body
      )}
    </ItemNotificationsContext.Provider>
  );
};
