----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

config = config or {}

-- Debug
config.debug = false -- Toggle script debug prints

-- Resource settings
config.resource_settings = {
    framework = 'boii_base', -- Choose your framework here. Available options; 'boii_base', 'qb-core', 'ox_core', 'esx_legacy', 'custom'
    notifications = 'boii_ui', -- Choose your notifications here. Available options; 'boii_ui', 'qb-core', 'esx_legacy', 'custom'
    drawtext_ui = 'boii_ui' -- Choose your drawtext ui here. Available options; 'boii_ui', 'qb-core', 'esx_legacy', 'custom'
}

-- SQL settings
config.sql = {
    table_name = 'job_reputation' -- Set the name of the job reputation sql table here
}

-- Multijobs
config.multijobs = true -- Enable/disable multijob functions; This is required for 'boii_base' users

-- Location settings 
config.locations = {
    ['alta_apartments'] = {
        ['blip'] = {
            ['id'] = 'job_center_1',
            ['label'] = 'Job Center', 
            ['coords'] = vector3(-254.1, -970.85, 31.22), 
            ['category'] = 'job_center', 
            ['sprite'] = 407, 
            ['colour'] = 0, 
            ['scale'] = 0.7,
            ['show'] = true
        },
        ['ped'] = {
            ['id'] = 'job_center_ped_1',
            ['label'] = 'Job Center Employee',
            ['model'] = 'ig_paper',
            ['coords'] = vector4(-254.07, -971.05, 31.22, 160.5),
            ['scenario'] = 'WORLD_HUMAN_STAND_MOBILE',
            ['category'] = 'job_center',
            ['use'] = true
        },
    }
}

-- Jobs
config.jobs_data = {
    ['trucker'] = {
        ['job'] = {
            ['location'] = vector3(1716.96, -1590.33, 112.51),
            ['job_name'] = 'trucker',
            ['job_grade'] = 0
        },
        ['reputation'] = {
            ['level'] = 0,
            ['current_rep'] = 0,
            ['first_level_rep'] = 5000,
            ['growth_factor'] = 1.5,
            ['max_level'] = 5
        },
        ['ui'] = {
            ['icon'] = 'fa-solid fa-truck-front',
            ['title'] = 'Truck Driver',
            ['salary'] = 'Average $500 per route with bonuses.',
            ['role'] = 'HGV Driver',
            ['description'] = 'Truckers keep the economy moving.',
            ['images_folder'] = 'trucker',
            ['images'] = {'trucker_1.jpg', 'trucker_2.jpg', 'trucker_3.jpg'},
            ['guide'] = {
                ['title'] = 'How to get started as a trucker!',
                ['content'] = 'This is the guide for the Trucker job. Follow these steps to be a successful trucker...'
            }
        }
    },
    ['scrapper'] = {
        ['job'] = {
            ['location'] = vector3(-502.9, -1715.73, 19.32),
            ['job_name'] = 'scrapper',
            ['job_grade'] = 0
        },
        ['reputation'] = {
            ['level'] = 0,
            ['current_rep'] = 0,
            ['first_level_rep'] = 5000,
            ['growth_factor'] = 1.5,
            ['max_level'] = 5
        },
        ['ui'] = {
            ['icon'] = 'fa-solid fa-recycle',
            ['title'] = 'Scrap Collector',
            ['salary'] = 'Average $150 per collection with bonuses.',
            ['role'] = 'Scrap Collector',
            ['description'] = 'One mans trash is another mans treasure.',
            ['images_folder'] = 'scrapper',
            ['images'] = {'scrapper_1.jpg', 'scrapper_2.jpg', 'scrapper_3.jpg'},
            ['guide'] = {
                ['title'] = 'How to get started as a scrapper!',
                ['content'] = 'This is the guide for the Scrapper job. Follow these steps to be a successful scrapper...'
            }
        }
    }
    -- add more jobs as required
}