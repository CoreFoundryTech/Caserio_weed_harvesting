Config = {}

-- Framework
Config.Framework = 'qb' -- 'qb', 'esx', 'qbx'
Config.Target = 'qb-target' -- 'qb-target', 'ox_target'

-- General Settings
Config.MaxPlantsPerPlayer = 10
Config.PlantDistance = 2.0 -- Minimum distance between plants
Config.RequirePot = true -- Require a pot to plant
Config.PotModel = 'bkr_prop_weed_bucket_open_01a' -- Valid empty bucket model
Config.Debug = true

-- Growth Times (in minutes)
-- Total growth time: 72 hours (4320 minutes) by default
-- For testing, you might want to lower these values significantly
Config.GrowthStages = {
    [0] = 2,  -- Small -> Med: 2 mins
    [1] = 2,  -- Med -> Large: 2 mins
    [2] = 2,  -- Large -> Harvestable: 2 mins
}

-- Items Configuration
Config.Items = {
    seed_prefix = 'weed_seed_',  -- e.g., weed_seed_blue
    weed_prefix = 'weed_',       -- e.g., weed_blue
}

-- Strains Configuration
Config.Strains = {
    blue = {
        label = 'Blue Dream',
        model_small = 'mriprops_weed__small_blue_s',
        model_med = 'mriprops_weed_med_blue_s',
        model_large = 'mriprops_weed_lrg_blue_s',
        yield = {min = 5, max = 7},
        seed_chance = 30, -- 30% chance to get a seed back
    },
    green = {
        label = 'Green Crack',
        model_small = 'mriprops_weed__small_green_s',
        model_med = 'mriprops_weed_med_green_s',
        model_large = 'mriprops_weed_lrg_green_s',
        yield = {min = 4, max = 6},
        seed_chance = 40,
    },
    orange = {
        label = 'Orange Kush',
        model_small = 'mriprops_weed__small_orange_s',
        model_med = 'mriprops_weed_med_orange_s',
        model_large = 'mriprops_weed_lrg_orange_s',
        yield = {min = 5, max = 7},
        seed_chance = 30,
    },
    pink = {
        label = 'Pink Panther',
        model_small = 'mriprops_weed__small_pink_s',
        model_med = 'mriprops_weed_med_pink_s',
        model_large = 'mriprops_weed_lrg_pink_s',
        yield = {min = 4, max = 6},
        seed_chance = 35,
    },
    purple = {
        label = 'Purple Haze',
        model_small = 'mriprops_weed__small_purple_s',
        model_med = 'mriprops_weed_med_purple_s',
        model_large = 'mriprops_weed_lrg_purple_s',
        yield = {min = 6, max = 8},
        seed_chance = 25,
    },
    red = {
        label = 'Red Dragon',
        model_small = 'mriprops_weed__small_red_s',
        model_med = 'mriprops_weed_med_red_s',
        model_large = 'mriprops_weed_lrg_red_s',
        yield = {min = 4, max = 6},
        seed_chance = 35,
    },
    yellow = {
        label = 'Yellow Submarine',
        model_small = 'mriprops_weed__small_yellow_s',
        model_med = 'mriprops_weed_med_yellow_s',
        model_large = 'mriprops_weed_lrg_yellow_s',
        yield = {min = 3, max = 5},
        seed_chance = 50,
    },
}
