<div align="center">

# ox_inventory (SD UI)

**A rebuilt interface for [ox_inventory](https://github.com/CommunityOx/ox_inventory).**
Equipment slots, backpacks that open as a separate stash panel below the other inventory, item rarities, your choice of a slot or grid inventory, and a settings panel players can tune themselves.

Everything from upstream ox_inventory still works: items, weapons, shops, stashes, crafting, and the same exports. Only the interface and the systems listed below are new.

[![Release](https://img.shields.io/github/v/release/Samuels-Development/ox_inventory?label=Release&logo=github)](https://github.com/Samuels-Development/ox_inventory/releases)
[![Stars](https://img.shields.io/github/stars/Samuels-Development/ox_inventory?label=Stars&logo=github)](https://github.com/Samuels-Development/ox_inventory)
[![Discord](https://img.shields.io/discord/842045164951437383?label=Discord&logo=discord&logoColor=white)](https://discord.gg/FzPehMQaBQ)
[![Licence](https://img.shields.io/badge/Licence-GPL--3.0-94DD0C)](LICENSE)

![Framework](https://img.shields.io/badge/Framework-QBox%20%7C%20QBCore%20%7C%20ESX%20%7C%20ox__core%20%7C%20ND-3b82f6)
![Layout](https://img.shields.io/badge/Layout-slots%20or%20grid-3b82f6)
![Upstream](https://img.shields.io/badge/Upstream-CommunityOx%2Fox__inventory-3b82f6)

[**Store**](https://fivem.samueldev.shop) · [**Discord**](https://discord.gg/FzPehMQaBQ) · [**Upstream docs**](https://coxdocs.dev/ox_inventory)

</div>

---

> [!IMPORTANT]
> **Download the packaged `ox_inventory.zip` from [releases](https://github.com/Samuels-Development/ox_inventory/releases), not the source.**
> The green **Code > Download ZIP** button gives you source only. `web/build/` is gitignored, so the interface will not load. If you did clone the source, [build it yourself](#building-from-source).

## Preview

<img alt="The inventory with equipment slots and fast slots" src=".github/preview/inventory-default.png" width="100%" />

<img alt="An equipped backpack open as a separate stash panel below the other inventory" src=".github/preview/inventory-backpack.png" width="100%" />

<img alt="The grid inventory, where every item occupies a footprint in cells" src=".github/preview/inventory-grid.png" width="100%" />

<img alt="The in-game settings panel" src=".github/preview/inventory-settings.png" width="100%" />

## What this fork adds

| | |
|---|---|
| **Equipment slots** | Eleven wearable slots around a character figure: hat, glasses, mask, earpiece, torso, armour, backpack, gloves, belt, legs, shoes. Items declare which slot they fit. |
| **Wearable clothing** | Drag a clothing item into its slot and the player actually puts it on. Take it out and they take it off, going back to whatever they were wearing underneath. |
| **Backpacks** | Equip a bag in the backpack slot and it opens as a separate panel below the other inventory, working like a stash you carry around with you. It has its own slot count and weight limit, on top of what the player can already carry. |
| **Item rarities** | Six tiers, from Common to Mythic. Each one tints the item's slot and tooltip so players can see at a glance what is worth picking up. You can sort and filter by rarity. |
| **Slot or grid inventory** | Pick one. Slots is the classic inventory where every item takes one square, big or small. Grid is a Tarkov style inventory where a rifle takes more room than a sandwich, and items can be rotated to fit. |
| **Settings panel** | A settings menu inside the inventory. Players change size, spacing, contrast, fonts, tooltips, notifications and colour theme themselves, and their choices are saved to their character. |
| **Fast slots** | Five slots bound to the number keys. In grid layout you assign any item to one and the item stays in the grid, free to move around; in slots layout they are the first five inventory slots. |
| **Colour themes** | Seven ready made colour schemes, and players can pick their own colours instead. |
| **Scales to any resolution** | Sizes are worked out from the screen height rather than fixed pixels, so it looks the same on 1080p, 1440p and ultrawide. |

## Configuration

Everything below lives in **`data/ui.lua`**.

### Layout

```lua
layout = 'slots',   -- 'slots' | 'grid'
```

Pick one or the other. **This fork ships with `slots`.** Change it to `grid` for the Tarkov style inventory.

- `slots` is the classic inventory. Every item takes exactly one square, whether it is a rifle or a sandwich.
- `grid` is a Tarkov style inventory. Items take up room based on their size, and players can rotate them with <kbd>R</kbd> to make things fit.

The block below only matters when you are using `grid`:

```lua
grid = {
    columns = 10,
    rows = 8,
    containerRows = 8,
    allowRotate = true,
    defaultSize = { 1, 1 },
    defaults = {
        weapon    = { 2, 2 },
        ammo      = { 1, 1 },
        component = { 1, 1 },
        tint      = { 1, 1 },
    },
},
```

| Field | Purpose |
|---|---|
| `columns` | How many cells wide every inventory is. Minimum 5, maximum 14. |
| `rows` | How many cells tall the player's own inventory is, so they get `rows * columns` cells in total. Grid only. |
| `containerRows` | Same thing for every stash, trunk, glovebox, drop and bag. Grid only. |
| `allowRotate` | Lets players press <kbd>R</kbd> while dragging to turn an item sideways. |
| `defaultSize` | Size used for an item that has no `grid` of its own. |
| `defaults` | Same, but per kind of item, so every weapon can default to 2x2 without listing them one by one. |

**Why `rows` and `containerRows` exist.** In slots, a backpack and a sandwich each take one slot, so 50 slots means 50 items. In grid, that same backpack takes six cells, so 50 cells holds far fewer things. If grid reused the slot numbers, every inventory on your server would quietly get smaller the moment you switched. So grid ignores them and uses these two values instead. Both are ignored entirely when `layout = 'slots'`.

Keep the two numbers equal and both sides of the screen come out the same size, which is what you want visually. Lower `containerRows` if you would rather stashes held less than the player.

**Sizing one stash differently.** `containerRows` is the default for every container, so on its own it cannot give you a small lockbox and a large warehouse. Pass `gridRows` when registering a stash to override it for that stash alone:

```lua
exports.ox_inventory:RegisterStash('lockbox', 'Lockbox', 50, 100000, nil, nil, nil, {
    gridRows = 2 -- 2 * columns cells, instead of containerRows * columns
})
```

The same key works on entries in `data/stashes.lua`. It is ignored when `layout = 'slots'`, where the stash uses its `slots` count as normal.

> [!WARNING]
> Switching an existing server from `slots` to `grid` does not reflow inventories that already have items in them. Positions were assigned under the old layout and will overlap. Change it on a fresh database, or expect players to rearrange.

### Background dim

```lua
dim = {
    enabled = true,
},
```

The dark scrim drawn over the world behind the interface. Players can adjust how strong it is from the settings panel.

Set `enabled = false` and the scrim is gone entirely — the world shows through at full brightness, and the **Background dim** slider disappears from the settings panel, so players cannot turn it back on. A value a player saved earlier is ignored while it is off. Convar override: `setr inventory:dim 0`.

This does not touch the blur GTA itself applies behind the inventory. That is separate and stays on `setr inventory:screenblur 0`.

### Equipment slots

```lua
clothing = {
    enabled = true,
    slots = {
        { name = 'hat',      label = 'Hat',      side = 'left'  },
        { name = 'backpack', label = 'Backpack', side = 'right', wearable = false },
        { name = 'belt',     label = 'Belt',     side = 'right', wearable = false },
    },
},
```

These are the slots down either side of the character. `side` decides which side a slot appears on, and they appear top to bottom in the order you list them.

`wearable` decides whether putting an item in that slot changes how the player looks. It defaults to **on**, so you only ever write it when you want to turn a slot off. `armour`, `backpack` and `belt` ship with it off, because those slots already do something mechanical and most servers do not want a second thing happening as well. Turn one on and it works exactly like the rest — see [Wearable clothing](#wearable-clothing).

**Adding a slot:**

1. Add a line to `clothing.slots` in `data/ui.lua`.
2. Optionally give it an icon in `web/src/components/utils/icons/ClothingIcons.tsx`, adding yours to the `CLOTHING_ICONS` list under the same `name`. Skip this and the slot still works, it just shows a generic icon.
3. If you did step 2, rebuild (`cd web && npm run build`). If you skipped it, just restart the resource.

You can have as many slots as you like, but each one permanently reserves a slot on every player's inventory, so do not add them for the sake of it.

Set `enabled = false` to remove equipment slots completely — no columns, no character preview focus, and no slots reserved on any inventory. Convar override: `setr inventory:clothing 0`.

Keeping only a couple of slots works too. If every slot you keep sits on the same `side`, they are split evenly across both sides instead, so the character stays centred rather than being pushed off to one side by an empty column. When both sides have slots, your `side` values are used exactly as written.

### Rarities

```lua
rarity = {
    enabled = true,
    default = 'common',
    tiers = {
        common    = { label = 'Common',    color = '#9CA3AF', order = 1 },
        uncommon  = { label = 'Uncommon',  color = '#4ADE80', order = 2 },
        rare      = { label = 'Rare',      color = '#38BDF8', order = 3 },
        epic      = { label = 'Epic',      color = '#A855F7', order = 4 },
        legendary = { label = 'Legendary', color = '#F59E0B', order = 5 },
        mythic    = { label = 'Mythic',    color = '#FB7185', order = 6 },
    },
},
```

`order` is what "sort by rarity" actually sorts on, so number them 1 upwards with no gaps. Any item that does not set a `rarity` is treated as `default`. Add, remove or rename tiers as you like; nothing is hardcoded, the interface just reads this table.

Set `enabled = false` to remove rarity entirely — no glow, no colours, no mention in tooltips, and the **Rarity display** and **Rarity colours** entries disappear from the settings panel. Convar override: `setr inventory:rarity 0`.

### Themes

`theme` picks the active preset from `themes`. Seven ship by default (`white`, `yellow`, `orange`, `red`, `purple`, `blue`, `green`) and players can override individual colours from the settings panel.

## Defining items

Items live in **`data/items.lua`**. Beyond the stock ox_inventory fields, this fork reads `rarity`, `grid`, `clothing` and `wear`.

```lua
['trail_backpack'] = {
    label = 'Trail Backpack',
    weight = 2000,
    stack = false,
    close = false,
    consume = 0,
    rarity = 'rare',            -- tier key from ui.lua
    grid = { 2, 3 },            -- { width, height } in cells, grid layout only
    clothing = 'backpack',      -- equipment slot this item occupies
    description = 'Weatherproof shell, hip belt, and enough straps to lose a thumb in.',
},
```

| Field | Purpose |
|---|---|
| `rarity` | One of the tier names from `ui.lua`. Tints the item's slot and tooltip. Leave it out and the item is `common`. |
| `grid` | How many cells the item takes, as `{ width, height }`. Only matters in grid layout; harmless in slots. |
| `clothing` | Which equipment slot the item goes in. Use a table like `{ 'hat', 'mask' }` if it fits more than one. Names are checked against `ui.lua` on startup and a wrong one is printed in the server console. |
| `wear` | What the item looks like once it is in that slot, so the player visibly puts it on. Needs `clothing` as well. See [Wearable clothing](#wearable-clothing). |
| `client.image` | Almost always unnecessary. Name the PNG after the item and it is found automatically. Only set this when the file name has to differ. |

### Wearable clothing

Adding `clothing` puts an item **in** a slot. Adding `wear` as well makes the player actually **put it on** — drag it into the slot and it appears on them, drag it out and it comes off again.

```lua
['flat_cap'] = {
    label = 'Flat Cap',
    weight = 150,
    stack = false,
    close = false,
    consume = 0,
    clothing = 'hat',
    wear = {
        male   = { prop = 0, drawable = 15, texture = 0 },
        female = { prop = 0, drawable = 14, texture = 0 },
    },
},
```

That is the whole thing. `clothing` says which slot it goes in, `wear` says what it looks like.

**Is it a prop or a component?**

GTA splits clothing in two, and you need to know which one you are dealing with:

| | Use | Slots this means |
|---|---|---|
| **`prop`** | Things worn *on* the body, which can be taken off leaving nothing behind | hat, glasses, earpiece |
| **`component`** | Things that *replace* part of the body model, so removing one reveals whatever is underneath | mask, torso, gloves, legs, shoes, armour, backpack |

Masks catch people out: they look like something you put on, but GTA models them as a component.

Write whichever one applies. Never both:

```lua
wear = { prop = 0, drawable = 15, texture = 0 },        -- a hat
wear = { component = 3, drawable = 4, texture = 0 },    -- gloves
```

**What to write for each slot**

This is the table you actually want. Find the slot your item goes in, and write that line:

| Slot | Write | Covers |
|---|---|---|
| `hat` | `prop = 0` | Hats, caps, helmets |
| `glasses` | `prop = 1` | Glasses, goggles |
| `earpiece` | `prop = 2` | Earpieces, earrings |
| `mask` | `component = 1` | Masks, balaclavas, bandanas |
| `gloves` | `component = 3` | Gloves — but see the note below |
| `legs` | `component = 4` | Trousers, shorts, skirts |
| `shoes` | `component = 6` | Shoes, boots |
| `torso` | `component = 11` | Jackets, shirts, hoodies |
| `backpack` | `component = 5` | Bags, parachutes |
| `armour` | `component = 9` | Body armour |
| `belt` | — | GTA has no belt id; see the note below |

Three of those need a word of warning:

- **`gloves` is really the whole arms.** Component `3` controls hands *and* sleeve length together, so a pair of gloves also decides whether the player's sleeves are long or short. Pick a drawable whose sleeves suit the jackets people wear, or accept that it changes both.
- **`torso` has a second layer underneath it.** Component `11` is the outer top. Component `8` is the undershirt below it — use that one for t-shirts that should still show when a jacket is on.
- **`belt` has no id of its own.** GTA does not model belts separately; a belt has to ride `torso` or `legs`, which means it fights whatever is in those slots. That is why the belt slot ships with `wearable` off.

Nothing enforces these pairings. The slot name is just a label you chose in `data/ui.lua` — the id in `wear` is what actually changes the model. The table is convention, not a rule, so a custom slot can use any id you like.

**The full id list**

These are GTA’s own ids, useful if you are adding a custom slot:

| `prop` | | `component` | |
|---|---|---|---|
| `0` | Hat | `1` | Mask |
| `1` | Glasses | `3` | Arms / gloves |
| `2` | Earpiece | `4` | Legs |
| `6` | Watch | `5` | Bag / parachute |
| `7` | Bracelet | `6` | Shoes |
| | | `7` | Neck / chain |
| | | `8` | Undershirt |
| | | `9` | Body armour |
| | | `11` | Torso / jacket |

**Male and female are different numbers.** Drawable `15` is not the same hat on both body types — the two freemode models have separate clothing lists. Give each one its own numbers:

```lua
wear = {
    male   = { component = 3, drawable = 4, texture = 0 },
    female = { component = 3, drawable = 6, texture = 0 },
},
```

If a garment genuinely uses the same number on both, you can skip the split and write it flat. It gets used for everyone:

```lua
wear = { prop = 0, drawable = 15, texture = 0 },
```

**`texture` is the colour variant** of that drawable. It defaults to `0`, so leave it out unless you want a specific colour.

**Finding the numbers:** open a clothing store, put the garment on, and note the numbers your clothing menu shows. Most menus display the drawable and texture directly. Otherwise, `illenium-appearance` stores exactly these ids for the player's saved outfit, so anything you can wear in a store you can turn into an item.

**Getting it wrong is safe.** A `wear` block with no valid `prop` or `component`, or with no `drawable`, is dropped when items load and the server console names the item. The item still exists and still fits its slot — it just will not change how anyone looks.

**Things worth knowing**

- Taking a garment off restores whatever the player was wearing underneath, not a blank slot. Remove someone's jacket item and their normal shirt comes back.
- Changing outfits at a clothing store does not knock equipped items off. The item is re-applied on top of the new outfit.
- Other players see it. Nothing extra to configure.
- `wear` only does something if the slot has `wearable` turned on. The eight cosmetic slots are on by default; `armour`, `backpack` and `belt` are off — see [Equipment slots](#equipment-slots).
- This needs an appearance resource running to work properly. It is built against **`illenium-appearance`**, and uses it to find out what the player is wearing underneath. Without one, garments still apply, but taking them off can restore the wrong thing.

### Item images

Drop a PNG into `web/images/` named after the item (`trail_backpack.png`) and it is picked up automatically. No config, no restart of anything but the resource.

Size is forgiving. Most of the stock icons are 100 x 100 and the bags that ship with this fork are 145 x 124, and both look fine, because every icon is scaled down to fit its slot without being stretched. Use a transparent background and keep the item roughly filling the image.

### Containers

A container is any item that holds other items, like a bag or a pizza box. Adding the item to `data/items.lua` is not enough on its own; you also have to register it in **`modules/items/containers.lua`**, or it will just be an item that does nothing:

```lua
setContainerProperties('trail_backpack', {
    slots = 26,
    maxWeight = 45000,          -- grams, so this is 45kg
    blacklist = containerItems,
})
```

`blacklist` is a list of items the container refuses. Passing `containerItems` refuses every other container, which is what stops players hiding a duffel bag inside a duffel bag to dodge weight limits. `whitelist` is the opposite and allows nothing except what you list, which is how the pizza box only ever holds pizza.

There are two ways a container can behave, and the only difference is whether it declares a `clothing` field.

- **Equipped**, when it declares `clothing = 'backpack'`. The player wears it in the backpack slot, and it opens automatically as a separate stash panel below the other inventory every time they open their inventory. Nothing to click.
- **Carried**, when it declares no `clothing` field. It sits in the inventory grid taking up space like any other item, and opens as a stash only when the player uses it.

### Bags that ship with this fork

Thirteen container items, all sharing one icon set.

| Item | Slots | Max load | Carry |
|---|---|---|---|
| `backpack_fashion` | 8 | 12 kg | Equipped |
| `backpack_small` | 10 | 15 kg | Equipped |
| `backpack_urban` | 16 | 25 kg | Equipped |
| `backpack_gamer` | 18 | 28 kg | Equipped |
| `backpack_medium` | 20 | 30 kg | Equipped |
| `backpack_hiking` | 26 | 45 kg | Equipped |
| `backpack_large` | 30 | 50 kg | Equipped |
| `duffel_bag_sport` | 36 | 65 kg | Equipped |
| `duffel_bag` | 40 | 70 kg | Equipped |
| `briefcase` | 12 | 20 kg | Carried |
| `medic_bag` | 20 | 30 kg | Carried |
| `police_duty_belt` | n/a | +8 kg carry weight | Equipped, belt slot |
| `police_duty_belt_heavy` | n/a | +14 kg carry weight | Equipped, belt slot |

The two duty belts work differently to everything else in that table. They hold nothing at all. Wearing one simply lets the player carry more weight in their own inventory, and taking it off removes the bonus again. If another resource has also changed that player's carry weight, the belt adds to it rather than overwriting it. Change the amounts in `beltCapacity` in `modules/inventory/server.lua`.

## Installation

### Dependencies

| Resource | What it is for |
| --- | --- |
| [ox_lib](https://github.com/CommunityOx/ox_lib) | Shared library |
| [oxmysql](https://github.com/CommunityOx/oxmysql) | Database access |

### Supported frameworks

[ox_core](https://github.com/communityox/ox_core), [esx](https://github.com/esx-framework/esx_core), [qbox](https://github.com/Qbox-project/qbx_core), [nd_core](https://github.com/ND-Framework/ND_Core), and QBCore. Compatibility with third-party resources is not guaranteed.

### Steps

1. Download `ox_inventory.zip` from [releases](https://github.com/Samuels-Development/ox_inventory/releases) and extract it into your resources folder.
2. Start it after its dependencies:

```cfg
ensure ox_lib
ensure oxmysql
ensure ox_inventory
```

3. Adjust `data/ui.lua` to taste. Nothing there is required to boot.

### Building from source

Cloned the repo instead of using a release? `web/build/` is gitignored, so build the interface yourself:

```bash
cd web
npm ci
npm run build
```

**When you need to rebuild, and when you don't:**

- Changed something in `data/`, like `ui.lua` or `items.lua`? **No rebuild.** Those are sent to the interface while the server runs, so a `restart ox_inventory` is enough.
- Changed something in `web/src/`, like adding an icon? **Rebuild.** Nothing under `web/src/` reaches the game until it is built.

## Staying current with upstream

This fork follows [CommunityOx/ox_inventory](https://github.com/CommunityOx/ox_inventory) and is currently level with it.

> [!IMPORTANT]
> **`git merge upstream/main` does not work here, and never will.** This repository was started fresh rather than forked on GitHub, so it shares no commit history with upstream. Git has no common ancestor to merge from and will refuse outright. Upstream changes have to be ported by hand.

A scheduled workflow (`.github/workflows/upstream-sync.yml`) runs daily and compares the two. When upstream is ahead it opens or updates a single issue listing exactly which commits are new, so you know what to port without watching their repo. You can also run it on demand from the Actions tab.

To check by hand:

```bash
git remote add upstream https://github.com/CommunityOx/ox_inventory.git
git fetch upstream
git log --oneline upstream/main -5
```

Then read the commits you care about and apply the changes yourself. Most upstream work touches server and shared Lua, which usually drops in unchanged. Anything touching their `web/` will not apply at all, because the interface here is a full rewrite.

## Credits

- **[Overextended](https://github.com/overextended)** wrote the original ox_inventory, and this is still their resource underneath.
- **[CommunityOx](https://github.com/CommunityOx/ox_inventory)** maintain it now, and are the upstream this fork tracks.
- **[DemiAutomatic/ox_inv_redesign](https://github.com/DemiAutomatic/ox_inv_redesign)** is the redesign this interface grew out of.
- Bag and container icons come from **[swkeep/keep-bags](https://github.com/swkeep/keep-bags)**, used unmodified under GPL-3.0. See [`web/images/CREDITS.md`](web/images/CREDITS.md) for the per-file mapping.

## Copyright

Copyright © 2024 Overextended <https://github.com/overextended>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
