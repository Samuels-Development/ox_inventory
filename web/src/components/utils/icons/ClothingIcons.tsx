import React from 'react';

export interface ClothingIconProps {
  className?: string;
}

export type ClothingIcon = React.FC<ClothingIconProps>;

const IconFrame: React.FC<React.PropsWithChildren<ClothingIconProps>> = ({ className, children }) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    className={className}
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth={1.5}
    strokeLinecap="round"
    strokeLinejoin="round"
    aria-hidden="true"
    focusable="false"
  >
    {children}
  </svg>
);

export const HatIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M8 14V9a4 4 0 0 1 8 0v5" />
    <path d="M3 16.5c0-1.4 4-2.5 9-2.5s9 1.1 9 2.5S17 19 12 19s-9-1.1-9-2.5Z" />
  </IconFrame>
);

export const GlassesIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <circle cx="6.5" cy="14" r="3.5" />
    <circle cx="17.5" cy="14" r="3.5" />
    <path d="M10 13.4c.6-.6 3.4-.6 4 0" />
    <path d="M3 12.5 5.2 9" />
    <path d="M21 12.5 18.8 9" />
  </IconFrame>
);

export const MaskIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M4 9h16v3.5a8 8 0 0 1-16 0V9Z" />
    <path d="M4 10H2.6a1.5 1.5 0 0 0 0 3H4" />
    <path d="M20 10h1.4a1.5 1.5 0 0 1 0 3H20" />
    <path d="M4.6 12.5h14.8" />
  </IconFrame>
);

export const EarpieceIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M4 14v-2a8 8 0 0 1 16 0v2" />
    <rect x="2" y="13" width="4.5" height="7" rx="2.25" />
    <rect x="17.5" y="13" width="4.5" height="7" rx="2.25" />
  </IconFrame>
);

export const TorsoIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M8.5 3 5 4.5 3 9l3 1.5V21h12V10.5L21 9l-2-4.5L15.5 3a3.5 3.5 0 0 1-7 0Z" />
  </IconFrame>
);

export const ArmourIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M12 3 4.5 6v6c0 4.4 3.1 8.1 7.5 9 4.4-.9 7.5-4.6 7.5-9V6L12 3Z" />
    <path d="m9 12 2 2 4-4" />
  </IconFrame>
);

export const BackpackIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M5 11a7 7 0 0 1 14 0v8a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-8Z" />
    <path d="M9 6.5V5.5a3 3 0 0 1 6 0v1" />
    <path d="M9 15h6v6H9z" />
  </IconFrame>
);

export const BeltIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <rect x="2" y="9" width="20" height="6" rx="1.5" />
    <rect x="8.5" y="6.75" width="7" height="10.5" rx="1.75" />
    <path d="M12 12h3.5" />
    <path d="M18.5 12h.01" />
    <path d="M20.5 12h.01" />
  </IconFrame>
);

export const GlovesIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M8 13v-2.5a1.5 1.5 0 0 0-3 0V15a6 6 0 0 0 6 6h1a6 6 0 0 0 6-6V7a1.5 1.5 0 0 0-3 0v4" />
    <path d="M14 11V5.5a1.5 1.5 0 0 0-3 0V11" />
    <path d="M11 11V6.5a1.5 1.5 0 0 0-3 0V13" />
  </IconFrame>
);

export const LegsIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M6 3h12v3l-.8 15H13l-.5-9h-1L11 21H6.8L6 6V3Z" />
    <path d="M6 6.5h12" />
  </IconFrame>
);

export const ShoesIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M6 4h4v8.5c0 1.4.9 2.6 2.2 3l5.3 1.7c1.5.5 2.5 1.9 2.5 3.5V21H6V4Z" />
    <path d="M6 17h5" />
  </IconFrame>
);

export const GenericClothingIcon: ClothingIcon = (props) => (
  <IconFrame {...props}>
    <path d="M12 8a2 2 0 1 1 2-2" />
    <path d="M12 8v2" />
    <path d="M12 10 3.6 15.7A1.2 1.2 0 0 0 4.3 18h15.4a1.2 1.2 0 0 0 .7-2.3L12 10Z" />
  </IconFrame>
);

const CLOTHING_ICONS: Record<string, ClothingIcon> = {
  hat: HatIcon,
  glasses: GlassesIcon,
  mask: MaskIcon,
  earpiece: EarpieceIcon,
  torso: TorsoIcon,
  armour: ArmourIcon,
  backpack: BackpackIcon,
  belt: BeltIcon,
  gloves: GlovesIcon,
  legs: LegsIcon,
  shoes: ShoesIcon,
};

export const getClothingIcon = (category: string): ClothingIcon => CLOTHING_ICONS[category] || GenericClothingIcon;

export default getClothingIcon;
