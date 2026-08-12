import React from 'react';

const strokeProps = {
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.6,
  strokeLinecap: 'round',
  strokeLinejoin: 'round',
} as const;

export const GridIcon: React.FC = () => (
  <svg viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg" fill="currentColor" aria-hidden="true">
    <path
      fillRule="evenodd"
      clipRule="evenodd"
      d="M0 3a3 3 0 0 1 3-3h2.25a3 3 0 0 1 3 3v2.25a3 3 0 0 1-3 3H3a3 3 0 0 1-3-3V3Zm9.75 0a3 3 0 0 1 3-3H15a3 3 0 0 1 3 3v2.25a3 3 0 0 1-3 3h-2.25a3 3 0 0 1-3-3V3ZM0 12.75a3 3 0 0 1 3-3h2.25a3 3 0 0 1 3 3V15a3 3 0 0 1-3 3H3a3 3 0 0 1-3-3v-2.25Zm9.75 0a3 3 0 0 1 3-3H15a3 3 0 0 1 3 3V15a3 3 0 0 1-3 3h-2.25a3 3 0 0 1-3-3v-2.25Z"
    />
  </svg>
);

export const BagIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <path d="M5 9a3 3 0 0 1 3-3h8a3 3 0 0 1 3 3v9a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3V9Z" />
    <path d="M9 6V5a3 3 0 0 1 6 0v1" />
    <path d="M9 13h6" />
  </svg>
);

export const LayersIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <path d="m12 3 9 5-9 5-9-5 9-5Z" />
    <path d="m3 13 9 5 9-5" />
    <path d="m3 17.5 9 5 9-5" />
  </svg>
);

export const SearchIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <circle cx="11" cy="11" r="7" />
    <path d="m20 20-3.6-3.6" />
  </svg>
);

export const CloseIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <path d="M18 6 6 18" />
    <path d="m6 6 12 12" />
  </svg>
);

export const WeightIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <circle cx="12" cy="5" r="2" />
    <path d="M10.5 7h3l3.8 12.2a1 1 0 0 1-.95 1.3H7.65a1 1 0 0 1-.95-1.3L10.5 7Z" />
  </svg>
);

export const WeightGlyphIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
    <path
      d="M8.6 8.6V7.2a3.4 3.4 0 0 1 6.8 0v1.4"
      fill="none"
      stroke="currentColor"
      strokeWidth={2.2}
      strokeLinecap="round"
    />
    <path
      d="M8.9 8.2h6.2a2.2 2.2 0 0 1 2.16 1.78l1.86 9.6A2 2 0 0 1 17.16 22H6.84a2 2 0 0 1-1.96-2.42l1.86-9.6A2.2 2.2 0 0 1 8.9 8.2Z"
      fill="currentColor"
    />
  </svg>
);

export const UseIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <path d="M11 12V4.5a1.5 1.5 0 0 1 3 0V12" />
    <path d="M14 10.5a1.5 1.5 0 0 1 3 0V13" />
    <path d="M17 11.5a1.5 1.5 0 0 1 3 0V16a5 5 0 0 1-5 5h-2.2a4 4 0 0 1-3.1-1.48L5.2 14.6a1.5 1.5 0 0 1 2.3-1.9L11 16" />
  </svg>
);

export const GiveIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <path d="M4 8.5 12 4l8 4.5v7L12 20l-8-4.5v-7Z" />
    <path d="m4 8.5 8 4.5 8-4.5" />
    <path d="M12 13v7" />
  </svg>
);

export const SettingsIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <circle cx="12" cy="12" r="3.2" />
    <circle cx="12" cy="12" r="7" />
    <path d="M12 2.2v2.8M12 19v2.8M2.2 12H5M19 12h2.8" />
    <path d="M5.07 5.07 7.05 7.05M16.95 16.95l1.98 1.98M18.93 5.07 16.95 7.05M7.05 16.95l-1.98 1.98" />
  </svg>
);

export const WeaponIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <g transform="translate(2 -1.5)">
      <path d="M2 7h16v4h-4l-1.5 3.5A3 3 0 0 1 9.75 16H8l-.8 3.2a1 1 0 0 1-.97.76H4.6a1 1 0 0 1-.97-1.24L5 13H4a2 2 0 0 1-2-2V7Z" />
    </g>
  </svg>
);

export const MedicalIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" fill="currentColor" aria-hidden="true">
    <path d="M9.5 2h5A1.5 1.5 0 0 1 16 3.5V8h4.5A1.5 1.5 0 0 1 22 9.5v5a1.5 1.5 0 0 1-1.5 1.5H16v4.5a1.5 1.5 0 0 1-1.5 1.5h-5A1.5 1.5 0 0 1 8 20.5V16H3.5A1.5 1.5 0 0 1 2 14.5v-5A1.5 1.5 0 0 1 3.5 8H8V3.5A1.5 1.5 0 0 1 9.5 2Z" />
  </svg>
);

export const FoodIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <path d="M3 11h18a9 9 0 0 0-18 0Z" />
    <path d="M2 14h20" />
    <path d="M4 17h16a3 3 0 0 1-3 3H7a3 3 0 0 1-3-3Z" />
  </svg>
);

export const ShirtIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <path d="M9 3 4 5.5 5.5 10 8 9.2V21h8V9.2l2.5.8L20 5.5 15 3a3 3 0 0 1-6 0Z" />
  </svg>
);

export const ChevronIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <path d="m6 9 6 6 6-6" />
  </svg>
);

export const CheckIcon: React.FC = () => (
  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" {...strokeProps} aria-hidden="true">
    <path d="m5 12.5 4.5 4.5L19 7.5" />
  </svg>
);
