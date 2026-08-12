import React from 'react';

interface ItemImageProps {
  src?: string;
  className?: string;
}

const showPlaceholder = (image: HTMLImageElement, missing: boolean) => {
  const placeholder = image.previousElementSibling as HTMLElement | null;

  image.style.display = missing ? 'none' : '';

  if (placeholder) placeholder.style.display = missing ? '' : 'none';
};

const ItemImage: React.FC<ItemImageProps> = ({ src, className }) => (
  <>
    <svg
      className={`${className ? `${className} ` : ''}item-image-missing`}
      style={{ display: 'none', pointerEvents: 'none', color: 'var(--ox-text-3)', opacity: 0.7 }}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.4}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
      focusable="false"
    >
      <rect x="3.75" y="5.25" width="16.5" height="13.5" rx="2.25" opacity="0.85" />
      <circle cx="9" cy="10.15" r="1.35" />
      <path d="M4.4 17.1 9.55 12.6a1.4 1.4 0 0 1 1.85 0l3.4 3.05" />
      <path d="M13.35 14.4 15.4 12.7a1.4 1.4 0 0 1 1.85 0l2.35 2.05" opacity="0.7" />
    </svg>
    <img
      src={src}
      alt=""
      className={className}
      draggable={false}
      onError={(event) => showPlaceholder(event.currentTarget, true)}
      onLoad={(event) => showPlaceholder(event.currentTarget, false)}
    />
  </>
);

export default React.memo(ItemImage);
