return {
    ['testburger'] = {
        label = 'Test Burger',
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
        weight = 115,
    },

    ['burger'] = {
        label = 'Burger',
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
        weight = 500,
        stack = false,
        close = true,
        description = "A usable megaphone"
    },

    ["ttt_teleporter"] = {
        label = "Teleporter Beacon",
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
    
    ["ttt_fake_id"] = {
        label = "Innocent ID Card",
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
        weight = 8000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
    },

    ['garbage'] = {
        label = 'Garbage',
    },

    ["bands"] = {
        label = "Band Of Notes",
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
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['panties'] = {
        label = 'Knickers',
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
        weight = 160,
    },

    ['phone'] = {
        label = 'Phone',
        weight = 190,
        stack = false,
        consume = 0,
        client = {
            add = function(total)
                if total > 0 then
                    pcall(function() return exports.npwd:setPhoneDisabled(false) end)
                end
            end,

            remove = function(total)
                if total < 1 then
                    pcall(function() return exports.npwd:setPhoneDisabled(true) end)
                end
            end
        }
    },

    ['mustard'] = {
        label = 'Mustard',
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
        weight = 3000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500
        }
    },

    ['clothing'] = {
        label = 'Clothing',
        consume = 0,
    },

    ['money'] = {
        label = 'Money',
    },

    ['black_money'] = {
        label = 'Dirty Money',
    },

    ['id_card'] = {
        label = 'Identification Card',
    },

    ["metaldetector_1"] = {
        label = "Basic Metal Detector",
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
		weight = 25
	},

	['md_crushedcan'] = {
		label = 'Crushed Can',
		weight = 25
	},

	['md_lighter'] = {
		label = 'Lighter',
		weight = 25
	},

	['md_metalcan'] = {
		label = 'Metal Can',
		weight = 25
	},

	['md_nails'] = {
		label = 'Nails',
		weight = 25
	},

	['md_needle'] = {
		label = 'Needle',
		weight = 25
	},

	['md_nickle'] = {
		label = 'Nickle',
		weight = 25
	},

	['md_nut'] = {
		label = 'Nut',
		weight = 25
	},

	['md_oldshotgunshell'] = {
		label = 'Old Shotgun Shell',
		weight = 25
	},

	['md_paperclip'] = {
		label = 'Paper Clip',
		weight = 25
	},

	['md_pulltab'] = {
		label = 'Pull Tab',
		weight = 25
	},

	['md_quarter'] = {
		label = 'Quarter',
		weight = 25
	},

	['md_rustyball'] = {
		label = 'Rusty Ball',
		weight = 25
	},

	['md_rustyironball'] = {
		label = 'Rusty Iron Ball',
		weight = 25
	},

	['md_rustyjunk'] = {
		label = 'Rusty Junk',
		weight = 25
	},

	['md_rustynails'] = {
		label = 'Rusty Nails',
		weight = 25
	},

	['md_rustypliers'] = {
		label = 'Rusty Pliers',
		weight = 25
	},

	['md_rustyring'] = {
		label = 'Rusty Ring',
		weight = 25
	},

	['md_rustyscissors'] = {
		label = 'Rusty Scissors',
		weight = 25
	},

	['md_rustyscrewdriver'] = {
		label = 'Rusty Screwdriver',
		weight = 25
	},

	['md_rustyspring'] = {
		label = 'Rusty Spring',
		weight = 25
	},

	['md_screw'] = {
		label = 'Screw',
		weight = 25
	},

	['md_wheatpenny'] = {
		label = 'Wheat Penny',
		weight = 25
	},

	['md_ancientcoin'] = {
		label = 'Ancient Coin',
		weight = 25
	},

	['md_blackwatch'] = {
		label = 'Watch',
		weight = 25
	},

	['md_coppernugget'] = {
		label = 'Copper Nugget',
		weight = 25
	},

	['md_diamondearings'] = {
		label = 'Diamond Earings',
		weight = 25
	},

	['md_diamondnecklace'] = {
		label = 'Diamond Necklace',
		weight = 25
	},

	['md_diamondring'] = {
		label = 'Diamond Ring',
		weight = 25
	},

	['md_earpod'] = {
		label = 'Ear Pod',
		weight = 25
	},

	['md_golddollar'] = {
		label = 'Gold Dollar',
		weight = 25
	},

	['md_goldearings'] = {
		label = 'Gold Earings',
		weight = 25
	},

	['md_goldnecklace'] = {
		label = 'Gold Necklace',
		weight = 25
	},

	['md_goldnugget'] = {
		label = 'Gold Nugget',
		weight = 25
	},

	['md_goldounce'] = {
		label = '1oz Gold Bar',
		weight = 25
	},

	['md_goldring'] = {
		label = 'Gold Ring',
		weight = 25
	},

	['md_halfdollar'] = {
		label = 'Half Dollar',
		weight = 25
	},

	['md_ironnugget'] = {
		label = 'Iron Nugget',
		weight = 25
	},

	['md_platinumnugget'] = {
		label = 'Platinum Nugget',
		weight = 25
	},

	['md_presidentialwatch'] = {
		label = 'Presidential Watch',
		weight = 25
	},

	['md_relicrevolver'] = {
		label = 'Relic Revolver',
		weight = 25
	},

	['md_silverdime'] = {
		label = 'Silver Dime',
		weight = 25
	},

	['md_silverearings'] = {
		label = 'Silver Earings',
		weight = 25
	},

	['md_silverounce'] = {
		label = '1oz Silver Bar',
		weight = 25
	},

	['md_silverring'] = {
		label = 'Silver Ring',
		weight = 25
	},

    ['driver_license'] = {
        label = 'Drivers License',
    },

    ['weaponlicense'] = {
        label = 'Weapon License',
    },

    ['lawyerpass'] = {
        label = 'Lawyer Pass',
    },

    ["bee-smoker"] = {
        label       = "Bee Smoker",
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
		weight = 300,
		stack = false,
		close = true,
		description = "A piece of paper used for pharmacies"
	},
	['prescriptionpad'] = {
		label = 'Prescription Pad',
		weight = 300,
		stack = false,
		close = true,
		description = "A prescription pad used by doctors to write prescriptions"
	},
    
    ["revivekit"] = {
        label = "Revival Kit",
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
        weight = 1000,
        allowArmed = true,
        consume = 0,
        client = {
            event = 'mm_radio:client:use'
        }
    },

    ['jammer'] = {
        label = 'Radio Jammer',
        weight = 10000,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:usejammer'
        }
    },

    ['radiocell'] = {
        label = 'AAA Cells',
        weight = 1000,
        stack = true,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:recharge'
        }
    },

    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        weight = 500,
    },

    ['screwdriverset'] = {
        label = 'Screwdriver Set',
        weight = 500,
    },

    ['electronickit'] = {
        label = 'Electronic Kit',
        weight = 500,
    },

    ['cleaningkit'] = {
        label = 'Cleaning Kit',
        weight = 500,
    },

    ['repairkit'] = {
        label = 'Repair Kit',
        weight = 2500,
    },

    ['advancedrepairkit'] = {
        label = 'Advanced Repair Kit',
        weight = 4000,
    },

    ['diamond_ring'] = {
        label = 'Diamond',
        weight = 1500,
    },

    ['rolex'] = {
        label = 'Golden Watch',
        weight = 1500,
    },

    ['goldbar'] = {
        label = 'Gold Bar',
        weight = 1500,
    },

    ['goldchain'] = {
        label = 'Golden Chain',
        weight = 1500,
    },

    ['crack_baggy'] = {
        label = 'Crack Baggy',
        weight = 100,
    },

    ['cokebaggy'] = {
        label = 'Bag of Coke',
        weight = 100,
    },

    ['coke_brick'] = {
        label = 'Coke Brick',
        weight = 2000,
    },

    ['coke_small_brick'] = {
        label = 'Coke Package',
        weight = 1000,
    },

    ['xtcbaggy'] = {
        label = 'Bag of Ecstasy',
        weight = 100,
    },

    ['meth'] = {
        label = 'Methamphetamine',
        weight = 100,
    },

    ['oxy'] = {
        label = 'Oxycodone',
        weight = 100,
    },

    ['weed_ak47'] = {
        label = 'AK47 2g',
        weight = 200,
    },

    ['weed_ak47_seed'] = {
        label = 'AK47 Seed',
        weight = 1,
    },

    ['weed_skunk'] = {
        label = 'Skunk 2g',
        weight = 200,
    },

    ['weed_skunk_seed'] = {
        label = 'Skunk Seed',
        weight = 1,
    },

    ['weed_amnesia'] = {
        label = 'Amnesia 2g',
        weight = 200,
    },

    ['weed_amnesia_seed'] = {
        label = 'Amnesia Seed',
        weight = 1,
    },

    ['weed_og-kush'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_og-kush_seed'] = {
        label = 'OGKush Seed',
        weight = 1,
    },

    ['weed_white-widow'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_white-widow_seed'] = {
        label = 'White Widow Seed',
        weight = 1,
    },

    ['weed_purple-haze'] = {
        label = 'Purple Haze 2g',
        weight = 200,
    },

    ['weed_purple-haze_seed'] = {
        label = 'Purple Haze Seed',
        weight = 1,
    },

    ['weed_brick'] = {
        label = 'Weed Brick',
        weight = 2000,
    },

    ["wood"] = {
        label = "Wood",
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
        weight = 2000,
    },

    ['joint'] = {
        label = 'Joint',
        weight = 200,
    },

    ['rolling_paper'] = {
        label = 'Rolling Paper',
        weight = 0,
    },

    ['empty_weed_bag'] = {
        label = 'Empty Weed Bag',
        weight = 0,
    },

    ['firstaid'] = {
        label = 'First Aid',
        weight = 2500,
    },

    ['ifaks'] = {
        label = 'Individual First Aid Kit',
        weight = 2500,
    },

    ['painkillers'] = {
        label = 'Painkillers',
        weight = 400,
    },

    ['firework1'] = {
        label = '2Brothers',
        weight = 1000,
    },

    ['firework2'] = {
        label = 'Poppelers',
        weight = 1000,
    },

    ['firework3'] = {
        label = 'WipeOut',
        weight = 1000,
    },

    ['firework4'] = {
        label = 'Weeping Willow',
        weight = 1000,
    },

    ['steel'] = {
        label = 'Steel',
        weight = 100,
    },

    ['rubber'] = {
        label = 'Rubber',
        weight = 100,
    },

    ['metalscrap'] = {
        label = 'Metal Scrap',
        weight = 100,
    },

    ['iron'] = {
        label = 'Iron',
        weight = 100,
    },

    ['copper'] = {
        label = 'Copper',
        weight = 100,
    },

    ['aluminium'] = {
        label = 'Aluminium',
        weight = 100,
    },

    ['plastic'] = {
        label = 'Plastic',
        weight = 100,
    },

    ['glass'] = {
        label = 'Glass',
        weight = 100,
    },

    ['gatecrack'] = {
        label = 'Gatecrack',
        weight = 1000,
    },

    ['cryptostick'] = {
        label = 'Crypto Stick',
        weight = 100,
    },

    ['trojan_usb'] = {
        label = 'Trojan USB',
        weight = 100,
    },

    ['toaster'] = {
        label = 'Toaster',
        weight = 5000,
    },

    ['small_tv'] = {
        label = 'Small TV',
        weight = 100,
    },

    ['security_card_01'] = {
        label = 'Security Card A',
        weight = 100,
    },

    ['security_card_02'] = {
        label = 'Security Card B',
        weight = 100,
    },

    ['drill'] = {
        label = 'Drill',
        weight = 5000,
    },

    ['thermite'] = {
        label = 'Thermite',
        weight = 1000,
    },

    ["flower"] = {
        label = "Fresh Flower",
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
        weight = 1000,
    },

    ['dendrogyra_coral'] = {
        label = 'Dendrogyra',
        weight = 1000,
    },

    ['jerry_can'] = {
        label = 'Jerrycan',
        weight = 3000,
    },

    ['nitrous'] = {
        label = 'Nitrous',
        weight = 1000,
    },

    ['wine'] = {
        label = 'Wine',
        weight = 500,
    },

    ['grape'] = {
        label = 'Grape',
        weight = 10,
    },

    ['grapejuice'] = {
        label = 'Grape Juice',
        weight = 200,
    },

    ['coffee'] = {
        label = 'Coffee',
        weight = 200,
    },

    ['vodka'] = {
        label = 'Vodka',
        weight = 500,
    },

    ['whiskey'] = {
        label = 'Whiskey',
        weight = 200,
    },

    ['beer'] = {
        label = 'beer',
        weight = 200,
    },

    ['sandwich'] = {
        label = 'beer',
        weight = 200,
    },

    ['walking_stick'] = {
        label = 'Walking Stick',
        weight = 1000,
    },

    ['lighter'] = {
        label = 'Lighter',
        weight = 200,
    },

    ['binoculars'] = {
        label = 'Binoculars',
        weight = 800,
    },

    ['stickynote'] = {
        label = 'Sticky Note',
        weight = 0,
    },

    ['empty_evidence_bag'] = {
        label = 'Empty Evidence Bag',
        weight = 200,
    },

    ['filled_evidence_bag'] = {
        label = 'Filled Evidence Bag',
        weight = 200,
    },

    ['harness'] = {
        label = 'Harness',
        weight = 200,
    },

    ['handcuffs'] = {
        label = 'Handcuffs',
        weight = 200,
    },

["workbench"] = {
    label = "Basic Workbench",
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
    weight = 100,
    stack = true,
    close = true,
    description = "A blueprint containing instructions for crafting an advanced lockpick. Add to crafting inventory to unlock the recipe.",
    consume = 0,
    client = {
        image = "blueprint_advancedlockpick.png",
    }
},
}