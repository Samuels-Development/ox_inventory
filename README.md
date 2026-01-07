# ox_inventory (SD UI Fork)

> **This is a modified fork of [ox_inventory](https://github.com/overextended/ox_inventory) with a completely redesigned UI to match the visual style of sd-crafting.**

If you have any issues or suggestions, feel free to PR, create an issue or join my discord: https://discord.gg/FzPehMQaBQ

## Preview
<img width="1920" height="1080" alt="FiveM_GTAProcess_6C1HAisT6o" src="https://github.com/user-attachments/assets/46561d25-7998-4134-ad11-4d33a22a0674" />

<img width="1920" height="1080" alt="FiveM_GTAProcess_VhzFiz3DF4" src="https://github.com/user-attachments/assets/eb7a1120-3220-474b-bbc7-981bc9e5694c" />

![FiveM_GTAProcess_bBgveoHGWF](https://github.com/user-attachments/assets/c8689320-92ba-4bfa-aa1a-c1eed1f5b44e)

## Works Great With

<img width="3840" height="2160" alt="image_2026-01-05_182906460" src="https://github.com/user-attachments/assets/127eef89-a41d-4fd7-820d-9bb15c28a62f" />


Advanced Crafting (Source): https://fivem.samueldev.shop/product/7203651

Advanced Crafting (Encrypted): https://fivem.samueldev.shop/product/7203650

## What's Different

- **Completely redesigned UI** - Modern dark theme matching sd-crafting's visual style
- **Search functionality** - Filter items by name or label in any inventory
- **Noise texture overlays** - Subtle noise effects with overlay blend mode for depth
- **Weight display** - Color-coded weight indicator (green/yellow/red based on capacity)
- **Item count display** - Shows total item count in inventory header
- **Improved slot design** - Rounded corners, better spacing, and cleaner item presentation
- **Hotbar slot numbers** - Clear slot indicators for quick-use items (1-5)
- **Durability bars** - Color-gradient durability indicators on items
- **Modern tooltips** - Redesigned item tooltips with better formatting
- **Item notifications** - Styled popup notifications for item actions (use, give, receive)

# Original ox_inventory

A complete inventory system for FiveM, implementing items, weapons, shops, and more without any strict framework dependency.

![](https://img.shields.io/github/downloads/communityox/ox_inventory/total?logo=github)
![](https://img.shields.io/github/downloads/communityox/ox_inventory/latest/total?logo=github)
![](https://img.shields.io/github/contributors/communityox/ox_inventory?logo=github)
![](https://img.shields.io/github/v/release/communityox/ox_inventory?logo=github)

## 📚 Documentation

https://coxdocs.dev/ox_inventory

## 💾 Download

https://github.com/communityox/ox_inventory/releases/latest/download/ox_inventory.zip

## Supported frameworks

We do not guarantee compatibility or support for third-party resources.

- [ox_core](https://github.com/communityox/ox_core)
- [esx](https://github.com/esx-framework/esx_core)
- [qbox](https://github.com/Qbox-project/qbx_core)
- [nd_core](https://github.com/ND-Framework/ND_Core)

## ✨ Features

- Server-side security ensures interactions with items, shops, and stashes are all validated.
- Logging for important events, such as purchases, item movement, and item creation or removal.
- Supports player-owned vehicles, licenses, and group systems implemented by frameworks.
- Fully synchronised, allowing multiple players to [access the same inventory](https://user-images.githubusercontent.com/65407488/230926091-c0033732-d293-48c9-9d62-6f6ae0a8a488.mp4).

### Items

- Inventory items are stored per-slot, with customisable metadata to support item uniqueness.
- Overrides default weapon-system with weapons as items.
- Weapon attachments and ammo system, including special ammo types.
- Durability, allowing items to be depleted or removed overtime.
- Internal item system provides secure and easy handling for item use effects.
- Compatibility with 3rd party framework item registration.

### Shops

- Restricted access based on groups and licenses.
- Support different currency for items (black money, poker chips, etc).

### Stashes

- Personal stashes, linking a stash with a specific identifier or creating per-player instances.
- Restricted access based on groups.
- Registration of new stashes from any resource.
- Containers allow access to stashes when using an item, like a paperbag or backpack.
- Access gloveboxes and trunks for any vehicle.
- Random item generation inside dumpsters and unowned vehicles.

## Copyright

Copyright © 2024 Overextended <https://github.com/overextended>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
