return {
    ['paper_map'] = {
        label = 'Map',
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 200,
        stack = false,
        close = true,
        consume = 0, -- required: frp_map keeps the item, using it just opens the atlas
        description = 'A folded paper map of the region. Whatever you have charted is inked in; the rest is blank.',
        client = {
            export = 'frp_map.useMap',
        },
        -- frp_racing's route picker. The item belongs to frp_map; racing only adds
        -- this button and its own frp*-prefixed metadata keys.
        buttons = {
            {
                label = 'Racing routes',
                action = function(slot)
                    if GetResourceState('frp_racing') ~= 'started' then return end
                    exports.frp_racing:openRoutes(slot)
                end,
            },
        },
    },

    ['map_board'] = {
        label = 'Community Board',
        rarity = 'uncommon',
        grid = { 2, 2 },
        weight = 3500,
        stack = true,
        close = true,
        consume = 0, -- required: frp_map takes the item itself, only once placement succeeds
        description = 'A cork noticeboard and a bag of pins. Put it up somewhere and anyone can pin notes to it.',
        client = {
            export = 'frp_map.useBoardItem',
        },
    },

    ['racing_tablet'] = {
        label = 'Racing Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 500,
        stack = false,
        close = true,
        consume = 0,
        description = 'Street racing tablet — events, tracks and rankings.',
        server = {
            export = 'sd-racing.useRacing_tablet',
        },
    },

    ['sim_card'] = {
        label = 'SIM Card',
        rarity = 'uncommon',
        weight = 5,
        stack = false,
        close = true,
        consume = 0, -- required: sd-phone consumes the item itself on install
        server = { export = 'sd-phone.useSim_card' },
    },

    ['testburger'] = {
        label = 'Test Burger',
        rarity = 'common',
        weight = 220,
        degrade = 60,
        client = {
            image = 'burger_chicken.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            export = 'ox_inventory_examples.testburger'
        },
        server = {
            export = 'ox_inventory_examples.testburger',
            test = 'what an amazingly delicious burger, amirite?'
        },
        buttons = {
            {
                label = 'Lick it',
                action = function(slot)
                    print('You licked the burger')
                end
            },
            {
                label = 'Squeeze it',
                action = function(slot)
                    print('You squeezed the burger :(')
                end
            },
            {
                label = 'What do you call a vegan burger?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('A misteak.')
                end
            },
            {
                label = 'What do frogs like to eat with their hamburgers?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('French flies.')
                end
            },
            {
                label = 'Why were the burger and fries running?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('Because they\'re fast food.')
                end
            }
        },
        consume = 0.3
    },

    ['bandage'] = {
        label = 'Bandage',
        rarity = 'common',
        weight = 115,
    },

    ['burger'] = {
        label = 'Burger',
        rarity = 'common',
        weight = 220,
        client = {
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'You ate a delicious burger'
        },
    },

    ["megaphone"] = {
        label = "Megaphone",
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 500,
        stack = false,
        close = true,
        description = "A usable megaphone"
    },

    ["ttt_teleporter"] = {
        label = "Teleporter Beacon",
        rarity = 'epic',
        weight = 500,
        stack = false,
        close = true,
        consume = 0,
        description = "Advanced teleportation device. Place a beacon and teleport back to it when needed.",
        client = {
            image = "ttt_teleporter.png",
        },
        server = {
            export = 'sd-ttt.useTtt_teleporter'
        }
    },
    
    ["ttt_portable_tester"] = {
        label = "Portable DNA Scanner",
        rarity = 'rare',
        weight = 300,
        stack = false,
        close = true,
        consume = 1,
        description = "Single-use device that can identify if a player is a traitor. Detective equipment only.",
        client = {
            image = "ttt_portable_tester.png",
        },
        server = {
            export = 'sd-ttt.useTtt_portable_tester'
        }
    },
    
    ["ttt_health_station"] = {
        label = "Health Station",
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 1000,
        stack = false,
        close = true,
        consume = 1,
        description = "Deployable medical station that heals nearby innocents. Contains 200HP worth of healing.",
        client = {
            image = "ttt_health_station.png",
        },
        server = {
            export = 'sd-ttt.useTtt_health_station'
        }
    },
    
    ["ttt_c4"] = {
        label = "C4 Explosive",
        rarity = 'epic',
        weight = 800,
        stack = true,
        close = true,
        consume = 1,
        description = "Remote detonated explosive with adjustable timer. Massive area damage. Traitor equipment.",
        client = {
            image = "ttt_c4.png",
        },
        server = {
            export = 'sd-ttt.useTtt_c4'
        }
    },
    
    ["ttt_defuser"] = {
        label = "Bomb Defuser Kit",
        rarity = 'rare',
        weight = 200,
        stack = false,
        close = true,
        consume = 0,
        description = "Professional defusal kit that reduces bomb defuse time by 50%. Detective equipment.",
        client = {
            image = "ttt_defuser.png",
        },
        server = {
            export = 'sd-ttt.useTtt_defuser'
        }
    },
    
    ["ttt_radar"] = {
        label = "Player Radar",
        rarity = 'rare',
        weight = 250,
        stack = false,
        close = true,
        consume = 0,
        description = "Shows all player positions for 5 seconds. 15 second cooldown between uses.",
        client = {
            image = "ttt_radar.png",
        },
        server = {
            export = 'sd-ttt.useTtt_radar'
        }
    },

    ['screwdriver'] = {
    label = 'Screwdriver',
    rarity = 'common',
    weight = 300,
    stack = true,
    close = true,
    description = 'A flathead screwdriver for prying coin boxes and unbolting fixtures.',
},
['wirecutter'] = {
    label = 'Wire Cutters',
    rarity = 'common',
    weight = 600,
    stack = true,
    close = true,
    description = 'Sharp wire cutters that slice through brake lines and wiring.',
},
['cutter'] = {
    label = 'Box Cutter',
    rarity = 'common',
    weight = 200,
    stack = true,
    close = true,
    description = 'A retractable box cutter - sharp enough to slash tyres and puncture tanks.',
},
['multitool'] = {
    label = 'Multitool',
    rarity = 'uncommon',
    weight = 400,
    stack = true,
    close = true,
    description = 'A folding multitool that handles meters, news racks, and signs.',
},
['powersaw'] = {
    label = 'Power Saw',
    rarity = 'uncommon',
    grid = { 2, 2 },
    weight = 4000,
    stack = true,
    close = true,
    description = 'A cordless reciprocating saw for cutting through metal.',
},
['anglegrinder'] = {
    label = 'Angle Grinder',
    rarity = 'uncommon',
    grid = { 2, 2 },
    weight = 3500,
    stack = true,
    close = true,
    description = 'A battery angle grinder that chews through converters and AC units.',
},
['bolt_cutter'] = {
    label = 'Bolt Cutters',
    rarity = 'uncommon',
    grid = { 2, 1 },
    weight = 2500,
    stack = true,
    close = true,
    description = 'Long-handled bolt cutters for chains, bolts, and converter mounts.',
},
['oxycutter'] = {
    label = 'Oxy Cutter',
    rarity = 'rare',
    grid = { 2, 2 },
    weight = 4000,
    stack = true,
    close = true,
    description = 'An oxy-acetylene cutting torch that slices through catalytic converters and AC units in seconds.',
},
['brick'] = {
    label = 'Brick',
    rarity = 'common',
    weight = 2000,
    stack = true,
    close = true,
    description = 'A heavy clay brick. Wedge it on a gas pedal to send a car running.',
},
['porch_package'] = {
    label = 'Porch Package',
    rarity = 'uncommon',
    grid = { 2, 2 },
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = 'A swiped porch delivery. Use it to open it up and see what was inside.',
    server = { export = 'sd-pettycrime.usePorch_package' },
},
['mail_package'] = {
    label = 'Mail Bundle',
    rarity = 'common',
    grid = { 2, 1 },
    weight = 300,
    stack = false,
    close = true,
    consume = 0,
    description = 'A bundle of stolen mail. Use it to open it up and see what was inside.',
    server = { export = 'sd-pettycrime.useMail_package' },
},
['skimmer'] = {
    label = 'Card Skimmer',
    rarity = 'rare',
    weight = 250,
    stack = true,
    close = true,
    description = 'Install on an ATM, then slot in a USB to record card data. Wears out the longer it runs.',
},
['atm_skimmer_usb'] = {
    label = 'Card Data USB',
    rarity = 'uncommon',
    weight = 50,
    stack = true,
    close = true,
    description = 'A USB stick for an ATM card skimmer. Stores stolen card data when slotted into an installed skimmer.',
},
['speed_bomb'] = {
    label = 'Speedbomb',
    rarity = 'epic',
    grid = { 2, 1 },
    weight = 1500,
    stack = true,
    close = true,
    description = 'Wire it under a parked vehicle. Arms when driven fast and blows if the speed drops.',
},
['catalytic_converter'] = {
    label = 'Catalytic Converter',
    rarity = 'rare',
    grid = { 2, 2 },
    weight = 2500,
    stack = true,
    close = true,
    description = 'A sawn-off catalytic converter, packed with precious metals and worth a fortune to the right buyer.',
},
    
    ["ttt_fake_id"] = {
        label = "Innocent ID Card",
        rarity = 'rare',
        weight = 50,
        stack = false,
        close = true,
        consume = 1,
        description = "Shows as innocent when tested. Single use. Traitor equipment.",
        client = {
            image = "ttt_fake_id.png",
        },
        server = {
            export = 'sd-ttt.useTtt_fake_id'
        }
    },
    
    ["ttt_flare_gun"] = {
        label = "Flare Gun",
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 400,
        stack = false,
        close = true,
        consume = 0,
        description = "Burns corpses to hide evidence. Single shot. Traitor equipment.",
        client = {
            image = "ttt_flare_gun.png",
        },
        server = {
            export = 'sd-ttt.useTtt_flare_gun'
        }
    },
    
    ["ttt_poison_smoke"] = {
        label = "Poison Smoke Grenade",
        rarity = 'epic',
        weight = 300,
        stack = true,
        close = true,
        consume = 1,
        description = "Toxic gas grenade that damages over time. Area denial weapon. Traitor equipment.",
        client = {
            image = "ttt_poison_smoke.png",
        },
        server = {
            export = 'sd-ttt.useTtt_poison_smoke'
        }
    },
    
    ["ttt_dna_scanner"] = {
        label = "DNA Scanner",
        rarity = 'rare',
        grid = { 2, 1 },
        weight = 200,
        stack = false,
        close = true,
        consume = 0,
        description = "Scan corpses to find the killer's last location. Detective equipment.",
        client = {
            image = "ttt_dna_scanner.png",
        },
        server = {
            export = 'sd-ttt.useTtt_dna_scanner'
        }
    },

    ['sprunk'] = {
        label = 'Sprunk',
        rarity = 'common',
        weight = 350,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'You quenched your thirst with a sprunk'
        }
    },

    ['parachute'] = {
        label = 'Parachute',
        rarity = 'rare',
        grid = { 2, 2 },
        clothing = 'backpack',
        weight = 8000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
    },

    ['garbage'] = {
        label = 'Garbage',
        rarity = 'common',
    },

    ["bands"] = {
        label = "Band Of Notes",
        rarity = 'uncommon',
        weight = 100,
        stack = true,
        close = false,
        description = "A band of small notes..",
        consume = 0,
        client = {
            image = "bands.png",
        }
    },
    
    ["rolls"] = {
        label = "Roll Of Small Notes",
        rarity = 'common',
        weight = 100,
        stack = true,
        close = false,
        description = "A roll of small notes..",
        consume = 0,
        client = {
            image = "rolls.png",
        }
    },

    ["fleeca_case"] = {
        label = "Fleeca Bank Case",
        rarity = 'epic',
        grid = { 2, 2 },
        weight = 2000,
        stack = true,
        close = true,
        description = "A mysterious case from a Fleeca Bank heist. Contains random loot.",
        consume = 0,
        client = {
            image = "case_1.png",
        },
        server = {
            export = 'sd-cases.useFleeca_case',
        }
    },
    
    ["house_case"] = {
        label = "House Robbery Case",
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 2000,
        stack = true,
        close = true,
        description = "A case filled with items from house burglaries. Contents unknown.",
        consume = 0,
        client = {
            image = "case_2.png",
        },
        server = {
            export = 'sd-cases.useHouse_case',
        }
    },
    
    ["chopshop_case"] = {
        label = "Chop Shop Case",
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 2500,
        stack = true,
        close = true,
        description = "A case containing random car parts from the chop shop.",
        consume = 0,
        client = {
            image = "case_3.png",
        },
        server = {
            export = 'sd-cases.useChopshop_case',
        }
    },
    
    ["jewelry_case"] = {
        label = "Jewelry Store Case",
        rarity = 'epic',
        grid = { 2, 2 },
        weight = 1500,
        stack = true,
        close = true,
        description = "A luxury case from Vangelico's. May contain valuable jewelry.",
        consume = 0,
        client = {
            image = "case_4.png",
        },
        server = {
            export = 'sd-cases.useJewelry_case',
        }
    },
    
    ["pacific_case"] = {
        label = "Pacific Bank Case",
        rarity = 'legendary',
        grid = { 2, 2 },
        weight = 3000,
        stack = true,
        close = true,
        description = "A high-security case from the Pacific Standard vault. Extremely valuable.",
        consume = 0,
        client = {
            image = "case_5.png",
        },
        server = {
            export = 'sd-cases.usePacific_case',
        }
    },
    
    ["casino_case"] = {
        label = "Casino Heist Case",
        rarity = 'legendary',
        grid = { 2, 2 },
        weight = 2500,
        stack = true,
        close = true,
        description = "A case stolen from the Diamond Casino vault. Contains premium loot.",
        consume = 0,
        client = {
            image = "case_6.png",
        },
        server = {
            export = 'sd-cases.useCasino_case',
        }
    },
    
    ["package"] = {
        label = "Suspicious Package",
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 10000,
        stack = false,
        close = false,
        description = "A mysterious package.. Scary!",
        consume = 0,
        client = {
            image = "package.png",
        }
    },

    ['hunting_bait_1'] = {
        label = 'Basic Bait',
        rarity = 'common',
        weight = 150,
        stack = true,
        close = true,
        description = 'Simple grain mixture - takes 3-5 minutes to attract nearby wildlife',
        client = {
            image = 'hunting_bait_1.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },
    
    ['hunting_bait_2'] = {
        label = 'Scented Bait',
        rarity = 'common',
        weight = 200,
        stack = true,
        close = true,
        description = 'Aromatic blend with natural scents - attracts animals in 2-4 minutes',
        client = {
            image = 'hunting_bait_2.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },
    
    ['hunting_bait_3'] = {
        label = 'Premium Bait',
        rarity = 'uncommon',
        weight = 250,
        stack = true,
        close = true,
        description = 'Enhanced formula with pheromones - draws wildlife within 1-3 minutes',
        client = {
            image = 'hunting_bait_3.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },
    
    ['hunting_bait_4'] = {
        label = 'Professional Bait',
        rarity = 'uncommon',
        weight = 300,
        stack = true,
        close = true,
        description = 'Concentrated attractant blend - animals respond in 30-90 seconds',
        client = {
            image = 'hunting_bait_4.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },
    
    ['hunting_bait_5'] = {
        label = 'Master Hunter Bait',
        rarity = 'rare',
        weight = 350,
        stack = true,
        close = true,
        description = 'Irresistible expert formula - instant attraction within 15-45 seconds',
        client = {
            image = 'hunting_bait_5.png',
        },
        server = {
            export = 'sd-civjobs.useHuntingBait'
        }
    },
    
    -- Deer Carcass Items (3 tiers)
    ['carcass_1'] = {
        label = 'Poor Deer Carcass',
        rarity = 'common',
        grid = { 2, 2 },
        weight = 2000,
        stack = true,
        close = true,
        description = 'Low quality deer carcass - damaged during hunt',
        client = {
            image = 'carcass_1.png',
        }
    },
    
    ['carcass_2'] = {
        label = 'Good Deer Carcass',
        rarity = 'uncommon',
        grid = { 2, 2 },
        weight = 2500,
        stack = true,
        close = true,
        description = 'Good quality deer carcass - cleanly hunted',
        client = {
            image = 'carcass_2.png',
        }
    },
    
    ['carcass_3'] = {
        label = 'Perfect Deer Carcass',
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 3000,
        stack = true,
        close = true,
        description = 'Pristine deer carcass - expertly hunted',
        client = {
            image = 'carcass_3.png',
        }
    },
    
    -- Mountain Lion Carcass Items (3 tiers)
    ['redcarcass_1'] = {
        label = 'Poor Mountain Lion Carcass',
        rarity = 'uncommon',
        grid = { 2, 2 },
        weight = 3000,
        stack = true,
        close = true,
        description = 'Low quality mountain lion carcass - damaged pelt',
        client = {
            image = 'redcarcass_1.png',
        }
    },
    
    ['redcarcass_2'] = {
        label = 'Good Mountain Lion Carcass',
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 3500,
        stack = true,
        close = true,
        description = 'Good quality mountain lion carcass - valuable game',
        client = {
            image = 'redcarcass_2.png',
        }
    },
    
    ['redcarcass_3'] = {
        label = 'Perfect Mountain Lion Carcass',
        rarity = 'epic',
        grid = { 2, 2 },
        weight = 4000,
        stack = true,
        close = true,
        description = 'Pristine mountain lion carcass - trophy quality',
        client = {
            image = 'redcarcass_3.png',
        }
    },
    
    -- Single tier items (no quality variations)
    ['deerhide'] = {
        label = 'Deer Hide',
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 800,
        stack = true,
        close = true,
        description = 'Quality deer hide suitable for leather crafting',
        client = {
            image = 'deerhide.png',
        }
    },
    
    ['antlers'] = {
        label = 'Deer Antlers',
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 600,
        stack = true,
        close = true,
        description = 'Pristine deer antlers - valuable trophy item',
        client = {
            image = 'antlers.png',
        }
    },
    
    ['mtlionpelt'] = {
        label = 'Mountain Lion Pelt',
        rarity = 'rare',
        grid = { 2, 1 },
        weight = 1200,
        stack = true,
        close = true,
        description = 'Rare mountain lion pelt - highly valued by traders',
        client = {
            image = 'mtlionpelt.png',
        }
    },
    
    ['mtlionfang'] = {
        label = 'Mountain Lion Fangs',
        rarity = 'rare',
        weight = 150,
        stack = true,
        close = true,
        description = 'Sharp predator fangs - prized collector item',
        client = {
            image = 'mtlionfang.png',
        }
    },
    
    ['coyotepelt'] = {
        label = 'Coyote Pelt',
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 600,
        stack = true,
        close = true,
        description = 'Warm coyote fur pelt - good for crafting',
        client = {
            image = 'coyotepelt.png',
        }
    },
    
    ['boarmeat'] = {
        label = 'Wild Boar Meat',
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 1800,
        stack = true,
        close = true,
        description = 'Fresh wild boar meat - a hearty game meat',
        client = {
            image = 'boarmeat.png',
        }
    },
    

    ['paperbag'] = {
        label = 'Paper Bag',
        rarity = 'common',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['panties'] = {
        label = 'Knickers',
        rarity = 'common',
        weight = 10,
        consume = 0,
        client = {
            status = { thirst = -100000, stress = -25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
            usetime = 2500,
        }
    },

    ['lockpick'] = {
        label = 'Lockpick',
        rarity = 'common',
        weight = 160,
    },

    ['phone'] = {
        label = 'Phone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 190,
        stack = false,
        consume = 0, -- never consumed on use; opens sd-phone (black frame)
        server = {
            export = 'sd-phone.usePhone'
        }
    },

    ['phone_black'] = {
        label = 'Phone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 190,
        stack = false,
        consume = 0, -- never consumed on use; opens sd-phone (black frame). Named phone_black
        server = {   -- because a bare 'phone' item name is intercepted by another resource.
            export = 'sd-phone.usePhone_black'
        },
        buttons = {
            { label = 'SIM Tray', action = function(slot) exports['sd-phone']:openSimTray(slot) end },
        }
    },

    ['phone_blue'] = {
        label = 'Blue Phone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 190,
        stack = false,
        consume = 0,
        server = { export = 'sd-phone.usePhone_blue' },
        buttons = {
            { label = 'SIM Tray', action = function(slot) exports['sd-phone']:openSimTray(slot) end },
        }
    },

    ['phone_green'] = {
        label = 'Green Phone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 190,
        stack = false,
        consume = 0,
        server = { export = 'sd-phone.usePhone_green' },
        buttons = {
            { label = 'SIM Tray', action = function(slot) exports['sd-phone']:openSimTray(slot) end },
        }
    },

    ['phone_orange'] = {
        label = 'Orange Phone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 190,
        stack = false,
        consume = 0,
        server = { export = 'sd-phone.usePhone_orange' },
        buttons = {
            { label = 'SIM Tray', action = function(slot) exports['sd-phone']:openSimTray(slot) end },
        }
    },

    ['phone_pink'] = {
        label = 'Pink Phone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 190,
        stack = false,
        consume = 0,
        server = { export = 'sd-phone.usePhone_pink' },
        buttons = {
            { label = 'SIM Tray', action = function(slot) exports['sd-phone']:openSimTray(slot) end },
        }
    },

    ['phone_purple'] = {
        label = 'Purple Phone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 190,
        stack = false,
        consume = 0,
        server = { export = 'sd-phone.usePhone_purple' },
        buttons = {
            { label = 'SIM Tray', action = function(slot) exports['sd-phone']:openSimTray(slot) end },
        }
    },

    ['phone_red'] = {
        label = 'Red Phone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 190,
        stack = false,
        consume = 0,
        server = { export = 'sd-phone.usePhone_red' },
        buttons = {
            { label = 'SIM Tray', action = function(slot) exports['sd-phone']:openSimTray(slot) end },
        }
    },

    ['phone_yellow'] = {
        label = 'Yellow Phone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 190,
        stack = false,
        consume = 0,
        server = { export = 'sd-phone.usePhone_yellow' },
        buttons = {
            { label = 'SIM Tray', action = function(slot) exports['sd-phone']:openSimTray(slot) end },
        }
    },

    ['tablet'] = {
        label       = 'Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight      = 700,
        stack       = false,
        close       = true,
        consume     = 0,
        description = 'A tablet. Everything your phone does, except calls.',
        client      = { image = 'tablet_black.png' },
        server      = { export = 'sd-tablet.useTablet' },
    },

    ['tablet_black'] = {
        label       = 'Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight      = 700,
        stack       = false,
        close       = true,
        consume     = 0,
        description = 'A tablet. Everything your phone does, except calls.',
        client      = { image = 'tablet_black.png' },
        server      = { export = 'sd-tablet.useTablet_black' },
    },

    ['tablet_blue'] = {
        label       = 'Blue Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight      = 700,
        stack       = false,
        close       = true,
        consume     = 0,
        description = 'A tablet. Everything your phone does, except calls.',
        client      = { image = 'tablet_blue.png' },
        server      = { export = 'sd-tablet.useTablet_blue' },
    },

    ['tablet_green'] = {
        label       = 'Green Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight      = 700,
        stack       = false,
        close       = true,
        consume     = 0,
        description = 'A tablet. Everything your phone does, except calls.',
        client      = { image = 'tablet_green.png' },
        server      = { export = 'sd-tablet.useTablet_green' },
    },

    ['tablet_orange'] = {
        label       = 'Orange Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight      = 700,
        stack       = false,
        close       = true,
        consume     = 0,
        description = 'A tablet. Everything your phone does, except calls.',
        client      = { image = 'tablet_orange.png' },
        server      = { export = 'sd-tablet.useTablet_orange' },
    },

    ['tablet_pink'] = {
        label       = 'Pink Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight      = 700,
        stack       = false,
        close       = true,
        consume     = 0,
        description = 'A tablet. Everything your phone does, except calls.',
        client      = { image = 'tablet_pink.png' },
        server      = { export = 'sd-tablet.useTablet_pink' },
    },

    ['tablet_purple'] = {
        label       = 'Purple Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight      = 700,
        stack       = false,
        close       = true,
        consume     = 0,
        description = 'A tablet. Everything your phone does, except calls.',
        client      = { image = 'tablet_purple.png' },
        server      = { export = 'sd-tablet.useTablet_purple' },
    },

    ['tablet_red'] = {
        label       = 'Red Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight      = 700,
        stack       = false,
        close       = true,
        consume     = 0,
        description = 'A tablet. Everything your phone does, except calls.',
        client      = { image = 'tablet_red.png' },
        server      = { export = 'sd-tablet.useTablet_red' },
    },

    ['tablet_yellow'] = {
        label       = 'Yellow Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight      = 700,
        stack       = false,
        close       = true,
        consume     = 0,
        description = 'A tablet. Everything your phone does, except calls.',
        client      = { image = 'tablet_yellow.png' },
        server      = { export = 'sd-tablet.useTablet_yellow' },
    },

    ['phone_powerbank'] = {
        label = 'Power Bank',
        rarity = 'uncommon',
        weight = 250,
        stack = false,
        close = true,
        consume = 0,
        server = { export = 'sd-phone.usePhone_powerbank' },
    },

    -- Using it latches charging on, using it again latches it off.
    ['phone_cable'] = {
        label = 'Charging Cable',
        rarity = 'common',
        weight = 80,
        stack = false,
        close = true,
        consume = 0,
        server = { export = 'sd-phone.usePhone_cable' },
    },

    ['mustard'] = {
        label = 'Mustard',
        rarity = 'common',
        weight = 500,
        client = {
            status = { hunger = 25000, thirst = 25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
            usetime = 2500,
            notification = 'You... drank mustard'
        }
    },

    ['water'] = {
        label = 'Water',
        rarity = 'common',
        weight = 500,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            cancel = true,
            notification = 'You drank some refreshing water'
        }
    },

    ['armour'] = {
        label = 'Bulletproof Vest',
        rarity = 'rare',
        grid = { 2, 2 },
        clothing = 'armour',
        weight = 3000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500
        }
    },

    ['clothing'] = {
        label = 'Clothing',
        rarity = 'common',
        consume = 0,
    },

    ['money'] = {
        label = 'Money',
        rarity = 'common',
    },

    ['black_money'] = {
        label = 'Dirty Money',
        rarity = 'common',
    },

    ['id_card'] = {
        label = 'Identification Card',
        rarity = 'common',
    },

    ["metaldetector_1"] = {
        label = "Basic Metal Detector",
        rarity = 'common',
        grid = { 2, 2 },
        weight = 2500,
        stack = false,
        close = true,
        consume = 0,
        description = "Entry-level detector with 5m range and 60% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_1.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },
    
    ["metaldetector_2"] = {
        label = "Amateur Metal Detector",
        rarity = 'uncommon',
        grid = { 2, 2 },
        weight = 2300,
        stack = false,
        close = true,
        consume = 0,
        description = "Improved detector with 7m range and 70% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_2.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },
    
    ["metaldetector_3"] = {
        label = "Professional Metal Detector",
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 2100,
        stack = false,
        close = true,
        consume = 0,
        description = "Professional-grade detector with 9m range and 80% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_3.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },
    
    ["metaldetector_4"] = {
        label = "Advanced Metal Detector",
        rarity = 'epic',
        grid = { 2, 2 },
        weight = 2000,
        stack = false,
        close = true,
        consume = 0,
        description = "Advanced detector with 11m range and 90% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_4.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },
    
    ["metaldetector_5"] = {
        label = "Elite Metal Detector",
        rarity = 'legendary',
        grid = { 2, 2 },
        weight = 1800,
        stack = false,
        close = true,
        consume = 0,
        description = "Top-tier detector with 13m range and 95% accuracy. Use to start detecting metals.",
        client = {
            image = "metaldetector_5.png",
        },
        server = {
            export = 'sd-civjobs.useMetalDetector'
        }
    },

    ["detecting_shovel"] = {
        label = "Shovel",
        rarity = 'common',
        grid = { 1, 3 },
        weight = 1500,
        stack = false,
        close = true,
        consume = 0,
        description = "High-quality shovel for metal detecting excavations.",
        client = {
            image = "detecting_shovel.png",
        }
    },

    ['md_brokenjunk'] = {
		label = 'Broken Junk',
		rarity = 'common',
		weight = 25
	},

	['md_crushedcan'] = {
		label = 'Crushed Can',
		rarity = 'common',
		weight = 25
	},

	['md_lighter'] = {
		label = 'Lighter',
		rarity = 'common',
		weight = 25
	},

	['md_metalcan'] = {
		label = 'Metal Can',
		rarity = 'common',
		weight = 25
	},

	['md_nails'] = {
		label = 'Nails',
		rarity = 'common',
		weight = 25
	},

	['md_needle'] = {
		label = 'Needle',
		rarity = 'common',
		weight = 25
	},

	['md_nickle'] = {
		label = 'Nickle',
		rarity = 'common',
		weight = 25
	},

	['md_nut'] = {
		label = 'Nut',
		rarity = 'common',
		weight = 25
	},

	['md_oldshotgunshell'] = {
		label = 'Old Shotgun Shell',
		rarity = 'common',
		weight = 25
	},

	['md_paperclip'] = {
		label = 'Paper Clip',
		rarity = 'common',
		weight = 25
	},

	['md_pulltab'] = {
		label = 'Pull Tab',
		rarity = 'common',
		weight = 25
	},

	['md_quarter'] = {
		label = 'Quarter',
		rarity = 'common',
		weight = 25
	},

	['md_rustyball'] = {
		label = 'Rusty Ball',
		rarity = 'common',
		weight = 25
	},

	['md_rustyironball'] = {
		label = 'Rusty Iron Ball',
		rarity = 'common',
		weight = 25
	},

	['md_rustyjunk'] = {
		label = 'Rusty Junk',
		rarity = 'common',
		weight = 25
	},

	['md_rustynails'] = {
		label = 'Rusty Nails',
		rarity = 'common',
		weight = 25
	},

	['md_rustypliers'] = {
		label = 'Rusty Pliers',
		rarity = 'common',
		weight = 25
	},

	['md_rustyring'] = {
		label = 'Rusty Ring',
		rarity = 'common',
		weight = 25
	},

	['md_rustyscissors'] = {
		label = 'Rusty Scissors',
		rarity = 'common',
		weight = 25
	},

	['md_rustyscrewdriver'] = {
		label = 'Rusty Screwdriver',
		rarity = 'common',
		weight = 25
	},

	['md_rustyspring'] = {
		label = 'Rusty Spring',
		rarity = 'common',
		weight = 25
	},

	['md_screw'] = {
		label = 'Screw',
		rarity = 'common',
		weight = 25
	},

	['md_wheatpenny'] = {
		label = 'Wheat Penny',
		rarity = 'common',
		weight = 25
	},

	['md_ancientcoin'] = {
		label = 'Ancient Coin',
		rarity = 'epic',
		weight = 25
	},

	['md_blackwatch'] = {
		label = 'Watch',
		rarity = 'rare',
		weight = 25
	},

	['md_coppernugget'] = {
		label = 'Copper Nugget',
		rarity = 'uncommon',
		weight = 25
	},

	['md_diamondearings'] = {
		label = 'Diamond Earings',
		rarity = 'epic',
		weight = 25
	},

	['md_diamondnecklace'] = {
		label = 'Diamond Necklace',
		rarity = 'epic',
		weight = 25
	},

	['md_diamondring'] = {
		label = 'Diamond Ring',
		rarity = 'epic',
		weight = 25
	},

	['md_earpod'] = {
		label = 'Ear Pod',
		rarity = 'uncommon',
		weight = 25
	},

	['md_golddollar'] = {
		label = 'Gold Dollar',
		rarity = 'rare',
		weight = 25
	},

	['md_goldearings'] = {
		label = 'Gold Earings',
		rarity = 'rare',
		weight = 25
	},

	['md_goldnecklace'] = {
		label = 'Gold Necklace',
		rarity = 'rare',
		weight = 25
	},

	['md_goldnugget'] = {
		label = 'Gold Nugget',
		rarity = 'rare',
		weight = 25
	},

	['md_goldounce'] = {
		label = '1oz Gold Bar',
		rarity = 'epic',
		weight = 25
	},

	['md_goldring'] = {
		label = 'Gold Ring',
		rarity = 'rare',
		weight = 25
	},

	['md_halfdollar'] = {
		label = 'Half Dollar',
		rarity = 'uncommon',
		weight = 25
	},

	['md_ironnugget'] = {
		label = 'Iron Nugget',
		rarity = 'uncommon',
		weight = 25
	},

	['md_platinumnugget'] = {
		label = 'Platinum Nugget',
		rarity = 'epic',
		weight = 25
	},

	['md_presidentialwatch'] = {
		label = 'Presidential Watch',
		rarity = 'legendary',
		weight = 25
	},

	['md_relicrevolver'] = {
		label = 'Relic Revolver',
		rarity = 'legendary',
		weight = 25
	},

	['md_silverdime'] = {
		label = 'Silver Dime',
		rarity = 'uncommon',
		weight = 25
	},

	['md_silverearings'] = {
		label = 'Silver Earings',
		rarity = 'uncommon',
		weight = 25
	},

	['md_silverounce'] = {
		label = '1oz Silver Bar',
		rarity = 'rare',
		weight = 25
	},

	['md_silverring'] = {
		label = 'Silver Ring',
		rarity = 'uncommon',
		weight = 25
	},

    ['driver_license'] = {
        label = 'Drivers License',
        rarity = 'common',
    },

    ['weaponlicense'] = {
        label = 'Weapon License',
        rarity = 'uncommon',
    },

    ['lawyerpass'] = {
        label = 'Lawyer Pass',
        rarity = 'uncommon',
    },

    ["bee-smoker"] = {
        label       = "Bee Smoker",
        rarity = 'uncommon',
        grid = { 2, 2 },
        weight      = 1500,
        stack       = false,
        description = "A handheld smoker used to calm bees, making bee management safer and easier.",
        consume     = 0,
        client = {
            image = "bee-smoker.png",
        }
    },

    ["bee-hive"] = {
        label = "Bee Hive",
        rarity = 'uncommon',
        grid = { 2, 2 },
        weight = 1000,
        stack = false,
        close = true,
        description = "",
        consume = 0,
        client = {
            image = "bee-hive.png",
        },
        server = {
            export = 'sd-beekeeping.useBee-hive',
        }
    },
        
    -- Bee Honey (Basic)
    ["bee-honey"] = {
        label = "Bee Honey",
        rarity = 'common',
        weight = 1000,
        stack = true,
        close = true,
        description = "Pure honey harvested directly from the hive, rich in natural sweetness.",
        consume = 0,
        client = {
            image = "bee-honey.png",
        }
    },
    
    -- Chiliad Honey
    ["chiliad-honey"] = {
        label = "Chiliad Honey",
        rarity = 'uncommon',
        weight = 1000,
        stack = true,
        close = true,
        description = "A robust honey infused with the essence of Chiliad's wild flora.",
        consume = 0,
        client = {
            image = "chiliad-honey.png",
        }
    },
    
    -- Green Hills Honey
    ["green-hills-honey"] = {
        label = "Green Hills Honey",
        rarity = 'uncommon',
        weight = 1000,
        stack = true,
        close = true,
        description = "Delicate honey crafted from the abundant clover fields of Green Hills.",
        consume = 0,
        client = {
            image = "green-hills-honey.png",
        }
    },
    
    -- Alamo Honey
    ["alamo-honey"] = {
        label = "Alamo Honey",
        rarity = 'rare',
        weight = 1000,
        stack = true,
        close = true,
        description = "Exquisite honey sourced from the serene Alamo Grove, known for its unique taste.",
        consume = 0,
        client = {
            image = "alamo-honey.png",
        }
    },
    
    -- Bee Wax
    ["bee-wax"] = {
        label = "Bee Wax",
        rarity = 'common',
        weight = 500,
        stack = true,
        close = true,
        description = "Versatile beeswax, perfect for crafting candles, cosmetics, and artisanal goods.",
        consume = 0,
        client = {
            image = "bee-wax.png",
        }
    },
        
    ["bee-house"] = {
        label = "Bee House",
        rarity = 'uncommon',
        grid = { 2, 2 },
        weight = 1000,
        stack = false,
        close = true,
        description = "",
        consume = 0,
        client = {
            image = "bee-house.png",
        },
        server = {
            export = 'sd-beekeeping.useBee-house',
        }
    },
        
    ["bee-queen"] = {
        label = "Bee Queen",
        rarity = 'rare',
        weight = 1000,
        stack = true,
        close = true,
        description = "",
        consume = 0,
        client = {
            image = "bee-queen.png",
        }
    },
    
    ["bee-worker"] = {
        label = "Worker Bee",
        rarity = 'common',
        weight = 1000,
        stack = true,
        close = true,
        description = "",
        consume = 0,
        client = {
            image = "bee-worker.png",
        }
    },
    
    ["thymol"] = {
        label = "Thymol",
        rarity = 'uncommon',
        weight = 500,
        stack = true,
        close = true,
        description = "A natural treatment derived from thyme oil, effective in combating hive infections and supporting bee health.",
        consume = 0,
        client = {
            image = "thymol.png",
        }
    },

    ["yachtcodes"] = {
        label = "Yacht Access Codes",
        rarity = 'epic',
        weight = 200,
        stack = false,
        close = true,
        description = "The first half of codes for the Yacht",
        consume = 0,
        client = {
            image = "yachtcodes.png",
        },
        server = {
            export = 'sd-yacht.useYachtcodes',
        }
    },
    
    ["casinocodes"] = {
        label = "Casino Access Codes",
        rarity = 'epic',
        weight = 200,
        stack = false,
        close = true,
        description = "The first half of codes for the Casino",
        consume = 0,
        client = {
            image = "casinocodes.png",
        },
        server = {
            export = 'sd-yacht.useCasinocodes',
        }
    },
    
    ["secured_safe"] = {
        label = "Safe",
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 200,
        stack = false,
        close = true,
        description = "Meant to protect valuables",
        consume = 0,
        client = {
            image = "secured_safe.png",
        },
    },
    
    ["expensive_champagne"] = {
        label = "Champagne",
        rarity = 'rare',
        grid = { 1, 2 },
        weight = 200,
        stack = true,
        close = true,
        description = "A sparkling wine from France",
        consume = 0,
        client = {
            image = "expensive_champagne.png",
        },
    },
    
    ["default_gateway_override"] = {
        label = "Gateway Override",
        rarity = 'rare',
        weight = 200,
        stack = false,
        close = true,
        description = "A default gateway override on a usb",
        consume = 0,
        client = {
            image = "default_gateway_override.png",
        },
    },

    ['prescription'] = {
		label = 'Prescription',
		rarity = 'common',
		weight = 300,
		stack = false,
		close = true,
		description = "A piece of paper used for pharmacies"
	},
	['prescriptionpad'] = {
		label = 'Prescription Pad',
		rarity = 'uncommon',
		weight = 300,
		stack = false,
		close = true,
		description = "A prescription pad used by doctors to write prescriptions"
	},
    
    ["revivekit"] = {
        label = "Revival Kit",
        rarity = 'epic',
        grid = { 2, 2 },
        weight = 3000,
        stack = false,
        close = false,
        description = "When your pal needs that pick me up",
        consume = 0,
        client = {
            image = "revivekit.png",
        },
        server = {
            export = 'sd-yacht.useRevivekit',
        }
    },
    

    ['radio'] = {
        label = 'Radio',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 1000,
        allowArmed = true,
        consume = 0,
        client = {
            event = 'mm_radio:client:use'
        }
    },

    ['jammer'] = {
        label = 'Radio Jammer',
        rarity = 'epic',
        grid = { 2, 2 },
        weight = 10000,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:usejammer'
        }
    },

    ['radiocell'] = {
        label = 'AAA Cells',
        rarity = 'common',
        weight = 1000,
        stack = true,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:recharge'
        }
    },

    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        rarity = 'uncommon',
        weight = 500,
    },

    ['screwdriverset'] = {
        label = 'Screwdriver Set',
        rarity = 'common',
        weight = 500,
    },

    ['electronickit'] = {
        label = 'Electronic Kit',
        rarity = 'uncommon',
        weight = 500,
    },

    ['cleaningkit'] = {
        label = 'Cleaning Kit',
        rarity = 'common',
        weight = 500,
    },

    ['repairkit'] = {
        label = 'Repair Kit',
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 2500,
    },

    ['advancedrepairkit'] = {
        label = 'Advanced Repair Kit',
        rarity = 'rare',
        grid = { 2, 1 },
        weight = 4000,
    },

    ['diamond_ring'] = {
        label = 'Diamond',
        rarity = 'epic',
        weight = 1500,
    },

    ['rolex'] = {
        label = 'Golden Watch',
        rarity = 'rare',
        weight = 1500,
    },

    ['goldbar'] = {
        label = 'Gold Bar',
        rarity = 'legendary',
        grid = { 2, 1 },
        weight = 1500,
    },

    ['goldchain'] = {
        label = 'Golden Chain',
        rarity = 'rare',
        weight = 1500,
    },

    ['crack_baggy'] = {
        label = 'Crack Baggy',
        rarity = 'uncommon',
        weight = 100,
    },

    ['cokebaggy'] = {
        label = 'Bag of Coke',
        rarity = 'uncommon',
        weight = 100,
    },

    ['coke_brick'] = {
        label = 'Coke Brick',
        rarity = 'rare',
        grid = { 2, 1 },
        weight = 2000,
    },

    ['coke_small_brick'] = {
        label = 'Coke Package',
        rarity = 'uncommon',
        weight = 1000,
    },

    ['xtcbaggy'] = {
        label = 'Bag of Ecstasy',
        rarity = 'uncommon',
        weight = 100,
    },

    ['meth'] = {
        label = 'Methamphetamine',
        rarity = 'uncommon',
        weight = 100,
    },

    ['oxy'] = {
        label = 'Oxycodone',
        rarity = 'uncommon',
        weight = 100,
    },

    ['weed_ak47'] = {
        label = 'AK47 2g',
        rarity = 'common',
        weight = 200,
    },

    ['weed_ak47_seed'] = {
        label = 'AK47 Seed',
        rarity = 'common',
        weight = 1,
    },

    ['weed_skunk'] = {
        label = 'Skunk 2g',
        rarity = 'common',
        weight = 200,
    },

    ['weed_skunk_seed'] = {
        label = 'Skunk Seed',
        rarity = 'common',
        weight = 1,
    },

    ['weed_amnesia'] = {
        label = 'Amnesia 2g',
        rarity = 'common',
        weight = 200,
    },

    ['weed_amnesia_seed'] = {
        label = 'Amnesia Seed',
        rarity = 'common',
        weight = 1,
    },

    ['weed_og-kush'] = {
        label = 'OGKush 2g',
        rarity = 'common',
        weight = 200,
    },

    ['weed_og-kush_seed'] = {
        label = 'OGKush Seed',
        rarity = 'common',
        weight = 1,
    },

    ['weed_white-widow'] = {
        label = 'OGKush 2g',
        rarity = 'common',
        weight = 200,
    },

    ['weed_white-widow_seed'] = {
        label = 'White Widow Seed',
        rarity = 'common',
        weight = 1,
    },

    ['weed_purple-haze'] = {
        label = 'Purple Haze 2g',
        rarity = 'common',
        weight = 200,
    },

    ['weed_purple-haze_seed'] = {
        label = 'Purple Haze Seed',
        rarity = 'common',
        weight = 1,
    },

    ['weed_brick'] = {
        label = 'Weed Brick',
        rarity = 'rare',
        grid = { 2, 1 },
        weight = 2000,
    },

    ["wood"] = {
        label = "Wood",
        rarity = 'common',
        grid = { 2, 1 },
        weight = 500,
        stack = true,
        close = false,
        consume = 0,
        description = "A piece of raw wood that can be processed into planks.",
        client = {
            image = "wood.png",
        }
    },
    
    ["powersaw"] = {
        label = "Power Saw",
        rarity = 'uncommon',
        grid = { 2, 2 },
        weight = 2000,
        stack = false,
        close = false,
        consume = 0,
        description = "A powerful electric saw used for cutting trees and logs.",
        client = {
            image = "powersaw.png",
        }
    },

    ['wood_planks'] = {
        label = 'Wood Planks',
        rarity = 'common',
        grid = { 2, 1 },
        weight = 90,
        stack = true,
        close = false,
        consume = 0,
        description = 'Several short, rough-cut wooden planks. Useful for repairs or crafting.',
        client = {
            image = "wood_planks.png",
        }
    },

    ['weed_nutrition'] = {
        label = 'Plant Fertilizer',
        rarity = 'common',
        weight = 2000,
    },

    ['joint'] = {
        label = 'Joint',
        rarity = 'common',
        weight = 200,
    },

    ['rolling_paper'] = {
        label = 'Rolling Paper',
        rarity = 'common',
        weight = 0,
    },

    ['empty_weed_bag'] = {
        label = 'Empty Weed Bag',
        rarity = 'common',
        weight = 0,
    },

    ['firstaid'] = {
        label = 'First Aid',
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 2500,
    },

    ['ifaks'] = {
        label = 'Individual First Aid Kit',
        rarity = 'uncommon',
        weight = 2500,
    },

    ['painkillers'] = {
        label = 'Painkillers',
        rarity = 'common',
        weight = 400,
    },

    ['firework1'] = {
        label = '2Brothers',
        rarity = 'uncommon',
        weight = 1000,
    },

    ['firework2'] = {
        label = 'Poppelers',
        rarity = 'uncommon',
        weight = 1000,
    },

    ['firework3'] = {
        label = 'WipeOut',
        rarity = 'uncommon',
        weight = 1000,
    },

    ['firework4'] = {
        label = 'Weeping Willow',
        rarity = 'uncommon',
        weight = 1000,
    },

    ['steel'] = {
        label = 'Steel',
        rarity = 'common',
        weight = 100,
    },

    ['rubber'] = {
        label = 'Rubber',
        rarity = 'common',
        weight = 100,
    },

    ['metalscrap'] = {
        label = 'Metal Scrap',
        rarity = 'common',
        weight = 100,
    },

    ['iron'] = {
        label = 'Iron',
        rarity = 'common',
        weight = 100,
    },

    ['copper'] = {
        label = 'Copper',
        rarity = 'common',
        weight = 100,
    },

    ['aluminium'] = {
        label = 'Aluminium',
        rarity = 'common',
        weight = 100,
    },

    ['plastic'] = {
        label = 'Plastic',
        rarity = 'common',
        weight = 100,
    },

    ['glass'] = {
        label = 'Glass',
        rarity = 'common',
        weight = 100,
    },

    ['gatecrack'] = {
        label = 'Gatecrack',
        rarity = 'rare',
        weight = 1000,
    },

    ['cryptostick'] = {
        label = 'Crypto Stick',
        rarity = 'rare',
        weight = 100,
    },

    ['trojan_usb'] = {
        label = 'Trojan USB',
        rarity = 'rare',
        weight = 100,
    },

    ['toaster'] = {
        label = 'Toaster',
        rarity = 'common',
        grid = { 2, 2 },
        weight = 5000,
    },

    ['small_tv'] = {
        label = 'Small TV',
        rarity = 'uncommon',
        grid = { 2, 2 },
        weight = 100,
    },

    ['security_card_01'] = {
        label = 'Security Card A',
        rarity = 'rare',
        weight = 100,
    },

    ['security_card_02'] = {
        label = 'Security Card B',
        rarity = 'rare',
        weight = 100,
    },

    ['drill'] = {
        label = 'Drill',
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 5000,
    },

    ['thermite'] = {
        label = 'Thermite',
        rarity = 'epic',
        weight = 1000,
    },

    ["flower"] = {
        label = "Fresh Flower",
        rarity = 'common',
        weight = 50,
        stack = true,
        close = true,
        consume = 0,
        description = "A beautiful fresh flower picked from the garden. Can be used for decoration or sold.",
        client = {
            image = "flower.png",
        }
    },

-- Add this to your regular items.lua (or replace if they already exist)
["diving_gear_1"] = {
    label = "Basic Scuba Gear",
    rarity = 'common',
    grid = { 2, 2 },
    clothing = 'backpack',
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Basic diving equipment with 120 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_1.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},

["diving_gear_2"] = {
    label = "Improved Scuba Gear",
    rarity = 'uncommon',
    grid = { 2, 2 },
    clothing = 'backpack',
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Improved diving equipment with 180 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_2.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},

["diving_gear_3"] = {
    label = "Advanced Scuba Gear",
    rarity = 'rare',
    grid = { 2, 2 },
    clothing = 'backpack',
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Advanced diving equipment with 240 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_3.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},

["diving_gear_4"] = {
    label = "Professional Scuba Gear",
    rarity = 'epic',
    grid = { 2, 2 },
    clothing = 'backpack',
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Professional diving equipment with 300 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_4.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},

["diving_gear_5"] = {
    label = "Elite Scuba Gear",
    rarity = 'legendary',
    grid = { 2, 2 },
    clothing = 'backpack',
    weight = 1000,
    stack = false,
    close = true,
    consume = 0,
    description = "Elite diving equipment with 360 seconds of oxygen. Use to put on diving suit.",
    client = {
        image = "diving_gear_5.png",
    },
    server = {
        export = 'sd-civjobs.useDivingGear'
    }
},
    
    ["diving_fill"] = {
        label = "Diving Tube",
        rarity = 'common',
        grid = { 1, 2 },
        weight = 1000,
        stack = false,
        close = true,
        consume = 0,
        description = "Refill your oxygen tank with this diving tube.",
        client = {
            image = "diving_tube.png",
        },
        server = {
            export = 'sd-civjobs.useDivingFill'
        }
    },

    ["welding_torch"] = {
        label = "Welding Torch",
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 2000,
        stack = false,
        close = true,
        consume = 0,
        description = "Professional welding torch for electrical repairs. Use near electrical equipment.",
        client = {
            image = "welding_torch.png",
        },
        server = {
            export = 'sd-civjobs.useWeldingTorch'
        }
    },

    ["diving_crate"] = {
        label = "Diving Crate",
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 500,
        stack = true,
        close = true,
        consume = 0,
        description = "A mysterious crate found while diving. Use to open and discover its contents.",
        client = {
            image = "diving_crate.png",
        },
        server = {
            export = 'sd-civjobs.openDivingCrate'
        }
    },    
    ["garden_shovel"] = {
        label = "Garden Shovel",
        rarity = 'common',
        grid = { 1, 3 },
        weight = 500,
        stack = true,
        close = true,
        consume = 0,
        description = "A sturdy garden shovel required for picking flowers. Essential tool for florist work.",
        client = {
            image = "garden_shovel.png",
        }
    },

    ["rose"] = {
        label = "Rose",
        rarity = 'common',
        weight = 40,
        stack = true,
        close = true,
        consume = 0,
        description = "A beautiful red rose with a sweet fragrance. A classic symbol of love and romance.",
        client = {
            image = "flowers.png",
        }
    },
    
    ["tulip"] = {
        label = "Tulip",
        rarity = 'common',
        weight = 35,
        stack = true,
        close = true,
        consume = 0,
        description = "A colorful tulip flower. Perfect for brightening up any space.",
        client = {
            image = "flowers.png",
        }
    },
    
    ["sunflower"] = {
        label = "Sunflower",
        rarity = 'common',
        weight = 60,
        stack = true,
        close = true,
        consume = 0,
        description = "A large, bright sunflower that always faces the sun. Symbol of happiness and positivity.",
        client = {
            image = "flowers.png",
        }
    },
    
    ["lily"] = {
        label = "Lily",
        rarity = 'common',
        weight = 45,
        stack = true,
        close = true,
        consume = 0,
        description = "An elegant lily flower with a delicate fragrance. Often used in formal arrangements.",
        client = {
            image = "flowers.png",
        }
    },
    
    ["orchid"] = {
        label = "Orchid",
        rarity = 'rare',
        weight = 30,
        stack = true,
        close = true,
        consume = 0,
        description = "A rare and exotic orchid. Highly prized by collectors and florists.",
        client = {
            image = "flowers.png",
        }
    },

    ['antipatharia_coral'] = {
        label = 'Antipatharia',
        rarity = 'rare',
        weight = 1000,
    },

    ['dendrogyra_coral'] = {
        label = 'Dendrogyra',
        rarity = 'rare',
        weight = 1000,
    },

    ['jerry_can'] = {
        label = 'Jerrycan',
        rarity = 'common',
        grid = { 2, 2 },
        weight = 3000,
    },

    ['nitrous'] = {
        label = 'Nitrous',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 1000,
    },

    ['wine'] = {
        label = 'Wine',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 500,
    },

    ['grape'] = {
        label = 'Grape',
        rarity = 'common',
        weight = 10,
    },

    ['grapejuice'] = {
        label = 'Grape Juice',
        rarity = 'common',
        weight = 200,
    },

    ['coffee'] = {
        label = 'Coffee',
        rarity = 'common',
        weight = 200,
    },

    ['vodka'] = {
        label = 'Vodka',
        rarity = 'common',
        grid = { 1, 2 },
        weight = 500,
    },

    ['whiskey'] = {
        label = 'Whiskey',
        rarity = 'common',
        grid = { 1, 2 },
        weight = 200,
    },

    ['beer'] = {
        label = 'beer',
        rarity = 'common',
        weight = 200,
    },

    ['sandwich'] = {
        label = 'beer',
        rarity = 'common',
        weight = 200,
    },

    ['walking_stick'] = {
        label = 'Walking Stick',
        rarity = 'common',
        grid = { 1, 3 },
        weight = 1000,
    },

    ['lighter'] = {
        label = 'Lighter',
        rarity = 'common',
        weight = 200,
    },

    ['binoculars'] = {
        label = 'Binoculars',
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 800,
    },

    ['stickynote'] = {
        label = 'Sticky Note',
        rarity = 'common',
        weight = 0,
    },

    ['empty_evidence_bag'] = {
        label = 'Empty Evidence Bag',
        rarity = 'common',
        weight = 200,
    },

    ['filled_evidence_bag'] = {
        label = 'Filled Evidence Bag',
        rarity = 'common',
        weight = 200,
    },

    ['harness'] = {
        label = 'Harness',
        rarity = 'uncommon',
        clothing = 'torso',
        weight = 200,
    },

    ['flat_cap'] = {
        label = 'Flat Cap',
        rarity = 'common',
        clothing = 'hat',
        weight = 150,
        stack = false,
        close = false,
        consume = 0,
        wear = {
            male   = { prop = 0, drawable = 15, texture = 0 },
            female = { prop = 0, drawable = 15, texture = 0 },
        },
    },

    ['ski_mask'] = {
        label = 'Ski Mask',
        rarity = 'uncommon',
        clothing = 'mask',
        weight = 120,
        stack = false,
        close = false,
        consume = 0,
        wear = {
            male   = { component = 1, drawable = 52, texture = 0 },
            female = { component = 1, drawable = 52, texture = 0 },
        },
    },

    ['work_gloves'] = {
        label = 'Work Gloves',
        rarity = 'common',
        clothing = 'gloves',
        weight = 100,
        stack = false,
        close = false,
        consume = 0,
        wear = {
            male   = { component = 3, drawable = 4, texture = 0 },
            female = { component = 3, drawable = 6, texture = 0 },
        },
    },

    ['handcuffs'] = {
        label = 'Handcuffs',
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 200,
    },

["workbench"] = {
    label = "Basic Workbench",
    rarity = 'rare',
    grid = { 3, 2 },
    weight = 5000,
    stack = false,
    close = true,
    description = "A small workbench for crafting basic stuff.",
    consume = 0,
    client = {
        image = "workbench.png",
    },
    server = {
        export = 'sd-crafting.useWorkbench',
    }
},

["advanced_workbench"] = {
    label = "Advanced Workbench",
    rarity = 'epic',
    grid = { 3, 2 },
    weight = 10000,
    stack = false,
    close = true,
    description = "A high-tech workbench with advanced crafting capabilities.",
    consume = 0,
    client = {
        image = "advanced_workbench.png",
    },
    server = {
        export = 'sd-crafting.useAdvanced_workbench',
    }
},

-- Crafting Blueprints
["blueprint_advancedlockpick"] = {
    label = "Advanced Lockpick Blueprint",
    rarity = 'rare',
    weight = 100,
    stack = true,
    close = true,
    description = "A blueprint containing instructions for crafting an advanced lockpick. Add to crafting inventory to unlock the recipe.",
    consume = 0,
    client = {
        image = "blueprint_advancedlockpick.png",
    }
},

    ['deaddrop_item_1'] = {
        label = 'Dead Drop Item 1 (Alpha)',
        rarity = 'rare',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_2'] = {
        label = 'Dead Drop Item 2 (Bravo)',
        rarity = 'rare',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_3'] = {
        label = 'Dead Drop Item 3 (Charlie)',
        rarity = 'rare',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_4'] = {
        label = 'Dead Drop Item 4 (Delta)',
        rarity = 'rare',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_5'] = {
        label = 'Dead Drop Item 5 (Echo)',
        rarity = 'rare',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_6'] = {
        label = 'Dead Drop Item 6 (Foxtrot)',
        rarity = 'rare',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_7'] = {
        label = 'Dead Drop Item 7 (Golf)',
        rarity = 'epic',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_8'] = {
        label = 'Dead Drop Item 8 (Hotel)',
        rarity = 'epic',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_9'] = {
        label = 'Dead Drop Item 9 (India)',
        rarity = 'epic',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_10'] = {
        label = 'Dead Drop Item 10 (Juliett)',
        rarity = 'epic',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_11'] = {
        label = 'Dead Drop Item 11 (Kilo)',
        rarity = 'legendary',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['deaddrop_item_12'] = {
        label = 'Dead Drop Item 12 (Lima)',
        rarity = 'legendary',
        weight = 100,
        consume = 0,
        client = { export = 'sd-deaddrop.openLootGrid' },
    },

    ['merryweather_tablet'] = {
        label = 'Merryweather Tablet',
        rarity = 'legendary',
        grid = { 2, 2 },
        weight = 2000,
        stack = false,
        consume = 0,
        description = 'A ruggedized Merryweather field tablet, reflashed with a custom intrusion terminal.',
        client = { export = 'sd-deaddrop.useTablet', image = 'merryweather_tablet.png' },
        buttons = {
            {
                label = 'USB Storage',
                action = function(slot)
                    exports['sd-deaddrop']:openTabletStash(slot)
                end,
            },
        },
    },

    ['deaddrop_usb_1'] = {
        label = 'Intrusion USB - Runner Kit',
        rarity = 'rare',
        weight = 50,
        stack = false,
        description = 'A scuffed USB carrying two intrusion daemons - net-maze.exe and highway-evade.exe. Provides both to the terminal while it sits in the tablet\'s USB storage.',
        client = { image = 'deaddrop_usb_1.png' },
    },

    ['deaddrop_usb_2'] = {
        label = 'Intrusion USB - Breaker Kit',
        rarity = 'rare',
        weight = 50,
        stack = false,
        description = 'A scuffed USB carrying two intrusion daemons - node-grab.exe and code-inject.exe. Provides both to the terminal while it sits in the tablet\'s USB storage.',
        client = { image = 'deaddrop_usb_2.png' },
    },

    ['deaddrop_usb_3'] = {
        label = 'Intrusion USB - Decrypt Suite',
        rarity = 'epic',
        weight = 50,
        stack = false,
        description = 'A sealed USB carrying three heavier daemons - cipher-lock.exe, sig-replay.exe and pipe-route.exe. Provides all three to the terminal while it sits in the tablet\'s USB storage.',
        client = { image = 'deaddrop_usb_3.png' },
    },

    ['deaddrop_usb_4'] = {
        label = 'Intrusion USB - Black ICE Suite',
        rarity = 'legendary',
        weight = 50,
        stack = false,
        description = 'A blacked-out USB carrying three elite daemons - data-worm.exe, fw-defense.exe and ice-break.exe. Provides all three to the terminal while it sits in the tablet\'s USB storage.',
        client = { image = 'deaddrop_usb_4.png' },
    },

    -- frp_mdt: printed record (REPORTS.EXE / CASES.EXE Print button). The
    -- metadata carries the frozen record snapshot; using it opens the document.
    ['mdt_document'] = {
        label = 'Printed Document',
        rarity = 'common',
        weight = 50,
        stack = false,
        close = true,
        consume = 0,
        description = 'An official printed record from a department terminal.',
        client = { export = 'frp_mdt.mdt_document' },
    },


    ['traffic_cone'] = {
        label = 'Traffic Cone',
        rarity = 'common',
        grid = { 1, 2 },
        weight = 500,
        stack = true,
        close = false,
        consume = 0,
        description = 'A road cone. Someone told you a bloke out west collects them.',
    },

    ['racing_traffic_cone'] = {
        label = 'Racing Traffic Cone',
        rarity = 'uncommon',
        grid = { 1, 2 },
        weight = 250,
        stack = true,
        close = false,
        consume = 0,
        description = 'A road cone wrapped in racing tape. The crews leave these ones alone.',
    },

    ['road_map'] = {
        label = 'Road Map',
        rarity = 'uncommon',
        grid = { 2, 1 },
        weight = 200,
        stack = false,
        close = true,
        consume = 0,
        description = 'A folded road map, marked up in biro. Tracks you have driven get added to it.',
        client = {
            export = 'frp_racing.useRoadMap',
        },
    },

    ['race_timer'] = {
        label = 'Race Timer',
        rarity = 'uncommon',
        weight = 250,
        stack = false,
        close = true,
        consume = 0,
        description = 'A little black plastic stopwatch. Shows your last run, and whatever name you etched on it.',
        client = {
            export = 'frp_racing.useTimer',
        },
    },

    ['turnin_slip'] = {
        label = 'Recycling Turn-In Slip',
        rarity = 'common',
        weight = 100,
        stack = true,
        close = false,
        description = 'Issued after dropping off a recyclable box. Can be redeemed for rewards.',
    },

    ['backpack_fashion'] = {
        label = 'Mini Backpack',
        rarity = 'common',
        grid = { 2, 2 },
        clothing = 'backpack',
        weight = 600,
        stack = false,
        close = false,
        consume = 0,
        description = 'More of a statement than a bag. Holds a phone, a wallet, and very little else.',
    },

    ['backpack_small'] = {
        label = 'Small Backpack',
        rarity = 'common',
        grid = { 2, 2 },
        clothing = 'backpack',
        weight = 800,
        stack = false,
        close = false,
        consume = 0,
        description = 'A compact daypack. Ten pockets and not much shoulder strain.',
    },

    ['backpack_urban'] = {
        label = 'Street Backpack',
        rarity = 'uncommon',
        grid = { 2, 2 },
        clothing = 'backpack',
        weight = 1100,
        stack = false,
        close = false,
        consume = 0,
        description = 'Loud panels, cheap zips, surprising amount of room. Built for a commute, used for worse.',
    },

    ['backpack_gamer'] = {
        label = 'Tech Backpack',
        rarity = 'uncommon',
        grid = { 2, 2 },
        clothing = 'backpack',
        weight = 1300,
        stack = false,
        close = false,
        consume = 0,
        description = 'Padded sleeves, cable ports, and a light strip nobody asked for. The padding does earn its keep.',
    },

    ['backpack_medium'] = {
        label = 'Backpack',
        rarity = 'uncommon',
        grid = { 2, 2 },
        clothing = 'backpack',
        weight = 1400,
        stack = false,
        close = false,
        consume = 0,
        description = 'A standard hiking pack. Twice the room of a daypack and still easy to run in.',
    },

    ['backpack_hiking'] = {
        label = 'Trail Backpack',
        rarity = 'rare',
        grid = { 2, 3 },
        clothing = 'backpack',
        weight = 2000,
        stack = false,
        close = false,
        consume = 0,
        description = 'Weatherproof shell, hip belt, and enough straps to lose a thumb in. Made for long days.',
    },

    ['backpack_large'] = {
        label = 'Large Backpack',
        rarity = 'rare',
        grid = { 2, 3 },
        clothing = 'backpack',
        weight = 2200,
        stack = false,
        close = false,
        consume = 0,
        description = 'A heavy-duty hauler. Thirty pockets, and you will feel every one of them.',
    },

    ['duffel_bag_sport'] = {
        label = 'Sports Duffel',
        rarity = 'epic',
        grid = { 3, 2 },
        clothing = 'backpack',
        weight = 2700,
        stack = false,
        close = false,
        consume = 0,
        description = 'Gym bag on paper. Nobody has ever checked what is actually inside one.',
    },

    ['duffel_bag'] = {
        label = 'Duffel Bag',
        rarity = 'epic',
        grid = { 3, 2 },
        clothing = 'backpack',
        weight = 3000,
        stack = false,
        close = false,
        consume = 0,
        description = 'A holdall built for moving a lot at once. Heavy before you put anything in it.',
    },

    ['briefcase'] = {
        label = 'Briefcase',
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 1500,
        stack = false,
        close = false,
        consume = 0,
        description = 'Brushed aluminium with a combination catch. Carried in hand, and it shows.',
    },

    ['medic_bag'] = {
        label = 'Medical Bag',
        rarity = 'rare',
        grid = { 3, 2 },
        weight = 2500,
        stack = false,
        close = false,
        consume = 0,
        description = 'Reflective trauma bag with a wide mouth. Everything inside is meant to be found fast.',
    },

    ['police_duty_belt'] = {
        label = 'Duty Belt',
        rarity = 'rare',
        grid = { 2, 1 },
        clothing = 'belt',
        weight = 1200,
        stack = false,
        close = false,
        consume = 0,
        description = 'Moulded pouches on a rigid belt. Spreads the load across your hips — carry 8kg more while worn.',
    },

    ['police_duty_belt_heavy'] = {
        label = 'Tactical Duty Belt',
        rarity = 'epic',
        grid = { 2, 1 },
        clothing = 'belt',
        weight = 1500,
        stack = false,
        close = false,
        consume = 0,
        description = 'The loaded-out version, with a drop leg strap taking the worst of it — carry 14kg more while worn.',
    },

    -- ==================== sd-restoration ====================
    ['salvage_tablet'] = {
        label = 'Salvage Tablet',
        rarity = 'rare',
        grid = { 2, 2 },
        weight = 700,
        stack = false,
        close = true,
        consume = 0,
        description = 'A battered trade tablet with a broker login saved on it. Opens the salvage catalog from anywhere.',
    },

    -- ---------------------------------------------------------------------------------------
    -- Raw materials (also what scrapping a project returns)
    -- ---------------------------------------------------------------------------------------
    ['steel_scrap']     = { label = 'Scrap Steel',      weight = 400, stack = true, close = false, description = 'Cut-up body steel. Worth more melted than it is bolted to anything.' },
    ['aluminium_scrap'] = { label = 'Scrap Aluminium',  weight = 220, stack = true, close = false, description = 'Light alloy offcuts — heads, wheels, the odd intake manifold.' },
    ['copper_wire']     = { label = 'Copper Wire',      weight = 120, stack = true, close = false, description = 'Stripped loom copper, coiled by hand.' },
    ['rubber_scrap']    = { label = 'Scrap Rubber',     weight = 180, stack = true, close = false, description = 'Perished hoses and dead tyre carcass.' },
    ['carbon_offcut']   = { label = 'Carbon Offcut',    weight = 90,  stack = true, close = false, description = 'Trimmings from a carbon panel. Sharp, light, and expensive.' },
    ['steel_stock']     = { label = 'Steel Stock',      weight = 900, stack = true, close = false, description = 'Fresh box section for cutting frame repair patches out of.' },
    ['welding_rod']     = { label = 'Welding Rod',      weight = 150, stack = true, close = false, description = 'Filler rod. Consumable, and you will always want one more.' },
    ['cutting_disc']    = { label = 'Cutting Disc',     weight = 100, stack = true, close = false, description = 'Thin abrasive disc for an angle grinder. Lasts about one arch.' },

    -- ---------------------------------------------------------------------------------------
    -- Chassis, suspension, brakes
    -- ---------------------------------------------------------------------------------------
    ['suspension_kit']  = { label = 'Suspension Kit',   weight = 2400, stack = true, close = false, description = 'Struts, springs and bushes for one corner.' },
    ['brake_kit']       = { label = 'Brake Kit',        weight = 1600, stack = true, close = false, description = 'Discs, pads and a caliper rebuild for one axle.' },
    ['brake_fluid']     = { label = 'Brake Fluid',      weight = 500,  stack = true, close = false, description = 'DOT 4. Eats paint, so do not spill it on the car you just sprayed.' },
    ['restored_wheel']  = { label = 'Restored Wheel',   weight = 8000, stack = true, close = false, description = 'A straightened rim with a fresh tyre on it, balanced and ready to hang.' },
    ['lug_nut']         = { label = 'Lug Nut',          weight = 40,   stack = true, close = false, description = 'One wheel nut. You will need five per corner and you will lose one.' },

    -- ---------------------------------------------------------------------------------------
    -- Engine and drivetrain
    -- ---------------------------------------------------------------------------------------
    ['engine_block']    = { label = 'Engine Block',     weight = 30000, stack = true, close = false, description = 'A rebuilt short block on a stand. Do not try to carry two.' },
    ['engine_mount']    = { label = 'Engine Mount',     weight = 700,   stack = true, close = false, description = 'Rubber and steel. The thing that stops the engine leaving the car.' },
    ['cylinder_head']   = { label = 'Cylinder Head',    weight = 9000,  stack = true, close = false, description = 'Skimmed flat, valves lapped, ready to torque down.' },
    ['head_gasket']     = { label = 'Head Gasket',      weight = 200,   stack = true, close = false, description = 'Multi-layer steel. Fit it once, fit it right.' },
    ['head_bolt']       = { label = 'Head Bolt',        weight = 90,    stack = true, close = false, description = 'Torque-to-yield. Single use, no arguments.' },
    ['timing_kit']      = { label = 'Timing Kit',       weight = 1200,  stack = true, close = false, description = 'Belt, tensioner and idlers. Cheaper than the valves it saves.' },
    ['transmission']    = { label = 'Transmission',     weight = 22000, stack = true, close = false, description = 'A rebuilt gearbox, drained and sealed for transport.' },
    ['gear_oil']        = { label = 'Gear Oil',         weight = 900,   stack = true, close = false, description = 'Heavy and foul-smelling. Everything about it is correct.' },
    ['radiator']        = { label = 'Radiator',         weight = 3500,  stack = true, close = false, description = 'Recored and pressure-tested.' },
    ['coolant_hose']    = { label = 'Coolant Hose',     weight = 250,   stack = true, close = false, description = 'Silicone hose in a length that is never quite the length you needed.' },
    ['exhaust_section'] = { label = 'Exhaust Section',  weight = 4000,  stack = true, close = false, description = 'Mandrel-bent tubing, one section of a system.' },
    ['exhaust_clamp']   = { label = 'Exhaust Clamp',    weight = 120,   stack = true, close = false, description = 'A band clamp. Cheap insurance against a drone you cannot find.' },
    ['fuel_pump']       = { label = 'Fuel Pump',        weight = 1100,  stack = true, close = false, description = 'In-tank pump and sender assembly.' },
    ['fuel_line']       = { label = 'Fuel Line',        weight = 300,   stack = true, close = false, description = 'Braided line, rated well past anything this engine will make.' },
    ['car_battery']     = { label = 'Car Battery',      weight = 14000, stack = true, close = false, description = 'Charged and load-tested. The last thing you fit before it starts.' },
    ['motor_oil']       = { label = 'Motor Oil',        weight = 1000,  stack = true, close = false, description = 'Five litres of the correct grade.' },
    ['coolant']         = { label = 'Coolant',          weight = 1000,  stack = true, close = false, description = 'Pre-mixed. Bright enough to find on the floor when it leaks.' },

    -- ---------------------------------------------------------------------------------------
    -- Electrical
    -- ---------------------------------------------------------------------------------------
    ['wiring_harness']  = { label = 'Wiring Harness',   weight = 3000, stack = true, close = false, description = 'A whole loom, labelled by somebody who cared. Rare and precious.' },
    ['electrical_tape'] = { label = 'Electrical Tape',  weight = 80,   stack = true, close = false, description = 'Cloth tape, because the sticky kind turns to soup in an engine bay.' },
    ['dash_cluster']    = { label = 'Dash Cluster',     weight = 2200, stack = true, close = false, description = 'Instrument binnacle with every bulb replaced.' },
    ['headlight_set']   = { label = 'Headlight Set',    weight = 3000, stack = true, close = false, description = 'A matched pair, polished clear.' },
    ['taillight_set']   = { label = 'Taillight Set',    weight = 2000, stack = true, close = false, description = 'A matched pair, no cracks, correct lenses.' },

    -- ---------------------------------------------------------------------------------------
    -- Body, glass and paint
    -- ---------------------------------------------------------------------------------------
    ['body_panel']      = { label = 'Body Panel',       weight = 7000, stack = true, close = false, description = 'A straight replacement panel. Getting it to line up is the hard part.' },
    ['panel_bolt']      = { label = 'Panel Bolt',       weight = 40,   stack = true, close = false, description = 'One captive bolt with a shouldered washer.' },
    ['door_hinge']      = { label = 'Door Hinge',       weight = 800,  stack = true, close = false, description = 'New pins and bushes, so the door stops dropping.' },
    ['bumper_shell']    = { label = 'Bumper Shell',     weight = 5000, stack = true, close = false, description = 'Unpainted bumper skin, ready for prep.' },
    ['widebody_arch']   = { label = 'Widebody Arch',    weight = 4000, stack = true, close = false, description = 'A moulded over-fender. Fitting it means cutting the wing you already own.' },
    ['auto_glass']      = { label = 'Auto Glass',       weight = 6000, stack = true, close = false, description = 'Laminated glass cut to pattern. Handle with two hands.' },
    ['urethane_tube']   = { label = 'Urethane Tube',    weight = 400,  stack = true, close = false, description = 'Glass bonding adhesive. One continuous bead or it leaks.' },
    ['sandpaper']       = { label = 'Sandpaper',        weight = 60,   stack = true, close = false, description = 'Wet-and-dry sheets. Never enough of them.' },
    ['body_filler']     = { label = 'Body Filler',      weight = 1200, stack = true, close = false, description = 'Two-part filler and hardener. A skim, not a sculpture.' },
    ['primer_can']      = { label = 'Primer',           weight = 1400, stack = true, close = false, description = 'High-build primer. Grey, dull, and the reason the colour looks right.' },
    ['paint_can']       = { label = 'Paint',            weight = 1400, stack = true, close = false, description = 'Base coat, mixed to whatever code you gave the shop.' },
    ['clearcoat_can']   = { label = 'Clearcoat',        weight = 1400, stack = true, close = false, description = 'Two-pack clear. The shine is entirely this.' },

    -- ---------------------------------------------------------------------------------------
    -- Interior
    -- ---------------------------------------------------------------------------------------
    ['seat_kit']        = { label = 'Seat Kit',         weight = 12000, stack = true, close = false, description = 'A retrimmed seat with new foam.' },
    ['trim_set']        = { label = 'Trim Set',         weight = 4000,  stack = true, close = false, description = 'Door cards, sills and pillar trims, with most of the clips.' },
}
