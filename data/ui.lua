
return {
    -- 'slots' | 'grid'
    layout = 'grid',

    pedPreview = {
        mode = 'silhouette',
        distance = 2.4,       -- metres in front of the camera
        height = -0.9,        -- vertical offset from the camera, metres (negative = lower)
        side = 0.0,           -- lateral offset, metres (positive = right)
        turn = 0.0,           -- degrees to turn the clone away from facing you
        light = true,         -- a soft key light so the preview reads at night and indoors
        lightRange = 3.0,
        lightIntensity = 2.0,
    },

    grid = {
        columns = 10,
        rows = 8,
        containerRows = 8,
        allowRotate = true,
        defaultSize = { 1, 1 },
        -- fallbacks by item class when an item has no explicit `grid`
        defaults = {
            weapon    = { 2, 2 },
            ammo      = { 1, 1 },
            component = { 1, 1 },
            tint      = { 1, 1 },
        },
    },

    clothing = {
        enabled = true,
        -- display order; `side` places the slot column left or right of the ped
        slots = {
            { name = 'hat',       label = 'Hat',       side = 'left'  },
            { name = 'glasses',   label = 'Glasses',   side = 'left'  },
            { name = 'mask',      label = 'Mask',      side = 'left'  },
            { name = 'earpiece',  label = 'Earpiece',  side = 'left'  },
            { name = 'torso',     label = 'Torso',     side = 'left'  },
            { name = 'armour',    label = 'Armour',    side = 'right' },
            { name = 'backpack',  label = 'Backpack',  side = 'right' },
            { name = 'gloves',    label = 'Gloves',    side = 'right' },
            { name = 'belt',      label = 'Belt',      side = 'right' },
            { name = 'legs',      label = 'Legs',      side = 'right' },
            { name = 'shoes',     label = 'Shoes',     side = 'right' },
        },
    },

    rarity = {
        enabled = true,
        default = 'common',
        -- ordered low -> high; `order` drives sorting and the tooltip bar
        tiers = {
            common    = { label = 'Common',    color = '#9CA3AF', order = 1 },
            uncommon  = { label = 'Uncommon',  color = '#4ADE80', order = 2 },
            rare      = { label = 'Rare',      color = '#38BDF8', order = 3 },
            epic      = { label = 'Epic',      color = '#A855F7', order = 4 },
            legendary = { label = 'Legendary', color = '#F59E0B', order = 5 },
            mythic    = { label = 'Mythic',    color = '#FB7185', order = 6 },
        },
    },

    injuries = {
        enabled = true,
        parts = {
            head      = { label = 'Head',       x = 50, y = 9  },
            chest     = { label = 'Chest',      x = 50, y = 25 },
            abdomen   = { label = 'Abdomen',    x = 49, y = 39 },
            leftArm   = { label = 'Left Arm',   x = 31, y = 40 },
            rightArm  = { label = 'Right Arm',  x = 69, y = 40 },
            leftHand  = { label = 'Left Hand',  x = 28, y = 56 },
            rightHand = { label = 'Right Hand', x = 72, y = 56 },
            leftLeg   = { label = 'Left Leg',   x = 43, y = 73 },
            rightLeg  = { label = 'Right Leg',  x = 57, y = 73 },
            feet      = { label = 'Feet',       x = 50, y = 95 },
        },
        types = {
            scratch  = { label = 'Scratched', severity = 1, color = '#9CA3AF' },
            bruise   = { label = 'Bruised',   severity = 1, color = '#A855F7' },
            cut      = { label = 'Cut',       severity = 2, color = '#F59E0B' },
            burn     = { label = 'Burned',    severity = 2, color = '#FB7185' },
            bleeding = { label = 'Bleeding',  severity = 3, color = '#EF4444' },
            gunshot  = { label = 'Gunshot',   severity = 3, color = '#DC2626' },
            fracture = { label = 'Fractured', severity = 3, color = '#38BDF8' },
        },
    },

    theme = 'white',

    themes = {
        yellow = {
            backgroundColor1 = 'rgba(75, 83, 24, 0)',
            backgroundColor2 = 'rgba(71, 80, 18, 0.05)',
            backgroundColor3 = 'rgba(118, 134, 24, 0.1)',
            rgbColor1        = 'rgba(192, 224, 15, 0.10)',
            rgbColor2        = 'rgba(192, 224, 15, 0.05)',
            mainColor        = '#C0E00F',
            secondaryColor   = '#697A08',
            textShadow       = 'rgba(192, 224, 15, 0.36)',
            photoShadowColor = 'rgba(192, 224, 15, 0.30)',
        },

        blue = {
            backgroundColor1 = 'rgba(24, 71, 83, 0)',
            backgroundColor2 = 'rgba(18, 73, 80, 0.05)',
            backgroundColor3 = 'rgba(24, 121, 134, 0.1)',
            rgbColor1        = 'rgba(15, 210, 224, 0.1)',
            rgbColor2        = 'rgba(15, 182, 224, 0.05)',
            mainColor        = '#0fb6e0ff',
            secondaryColor   = '#086d7aff',
            textShadow       = 'rgba(15, 200, 224, 0.36)',
            photoShadowColor = 'rgba(15, 210, 224, 0.3)',
        },

        red = {
            backgroundColor1 = 'rgba(83, 24, 24, 0)',
            backgroundColor2 = 'rgba(80, 18, 18, 0.05)',
            backgroundColor3 = 'rgba(134, 24, 24, 0.1)',
            rgbColor1        = 'rgba(224, 15, 15, 0.1)',
            rgbColor2        = 'rgba(224, 15, 15, 0.05)',
            mainColor        = '#e00f2bff',
            secondaryColor   = '#7a0808ff',
            textShadow       = 'rgba(224, 15, 15, 0.36)',
            photoShadowColor = 'rgba(224, 15, 15, 0.3)',
        },

        purple = {
            backgroundColor1 = 'rgba(61, 24, 83, 0)',
            backgroundColor2 = 'rgba(42, 18, 80, 0.05)',
            backgroundColor3 = 'rgba(94, 24, 134, 0.1)',
            rgbColor1        = 'rgba(112, 15, 224, 0.1)',
            rgbColor2        = 'rgba(106, 15, 224, 0.05)',
            mainColor        = '#6a0fe0ff',
            secondaryColor   = '#39087aff',
            textShadow       = 'rgba(106, 15, 224, 0.36)',
            photoShadowColor = 'rgba(123, 15, 224, 0.3)',
        },

        green = {
            backgroundColor1 = 'rgba(46, 83, 24, 0)',
            backgroundColor2 = 'rgba(28, 80, 18, 0.05)',
            backgroundColor3 = 'rgba(37, 134, 24, 0.1)',
            rgbColor1        = 'rgba(15, 224, 25, 0.1)',
            rgbColor2        = 'rgba(15, 224, 32, 0.05)',
            mainColor        = '#16e00fff',
            secondaryColor   = '#157a08ff',
            textShadow       = 'rgba(15, 224, 25, 0.36)',
            photoShadowColor = 'rgba(15, 224, 43, 0.3)',
        },

        white = {
            backgroundColor1 = 'rgba(74, 75, 74, 0)',
            backgroundColor2 = 'rgba(77, 77, 77, 0.05)',
            backgroundColor3 = 'rgba(138, 138, 138, 0.1)',
            rgbColor1        = 'rgba(224, 224, 224, 0.1)',
            rgbColor2        = 'rgba(228, 228, 228, 0.05)',
            mainColor        = '#d6d6d6ff',
            secondaryColor   = '#757575ff',
            textShadow       = 'rgba(226, 226, 226, 0.36)',
            photoShadowColor = 'rgba(221, 221, 221, 0.3)',
        },

        orange = {
            backgroundColor1 = 'rgba(83, 55, 24, 0)',
            backgroundColor2 = 'rgba(80, 46, 18, 0.05)',
            backgroundColor3 = 'rgba(134, 68, 24, 0.1)',
            rgbColor1        = 'rgba(224, 109, 15, 0.1)',
            rgbColor2        = 'rgba(224, 92, 15, 0.05)',
            mainColor        = '#e04a0fff',
            secondaryColor   = '#7a3608ff',
            textShadow       = 'rgba(224, 109, 15, 0.36)',
            photoShadowColor = 'rgba(224, 116, 15, 0.3)',
        },
    },
}
