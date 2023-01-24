Config = {}

-- Framework Options
Config.QBCore = true
Config.ESX = false

-- Thirdeye Script
Config.THIRDEYE = 'qb-target'-- Tested and works with ox_target and qb_target

-- Inventory scripts options
Config.ox_inventory = false
Config.QbInventory = true

-- Business Cut and Money rewarded for distance traveled
Config.BUSINESSCUT = 20 -- Percentage
Config.MONEYPERDISTANCE = 0.20 -- Money per distance traveled
Config.MONEY = 'moneybag' -- Money item

-- Secret Reward Configs
Config.SECRETREWARD = true -- Whether or not you want the players to recieve things other than money
Config.ONESECRETREWARD = true -- Whether or not you want one secret reward rewarded

--Dirty Money Configs
Config.MONEYLAUNDERING = true -- Whether or not you want to clean dirty money to clean money
Config.PERCENTTOCLEAN = 20 -- Percent chance to clean the money
Config.DIRTYMONEYAMOUNT = 20 -- How much dirty money you want cleaned
Config.DIRTYMONEY = 'markedbills' -- Dirty money item
Config.PERCENTLOST = 20 -- Percent lost when cleaning the dirty money

-- Items for the secret reward
Config.REWARDS = {
    -- Example on how to add an item to secret rewards
    -- ['usb_fleeca'] = { 
    --     CHANCE = 10, -- Percentage
    --     AMOUNT = 1, -- Amount you recieve
    -- },
}

Config.DEFAULTLOCATIONS = {
    vector4(-1183.0575, -1556.7136, 5.0370, 122.6497),
}

Config.RESTAURANT = {
    --Example on how to add a delivery location
    -- ['pizzeria'] = { --business name in database to add funds to
    --     JOB = 'pizzeria', -- player job to add deliveries
    --     STOCK = 'glass', -- item needed to stock deliveries
    --     DELIVERY = 'glass', -- item needed to run deliveries
    --     PROPS = { -- if you want an item to spawn on top of another item spawn it after the item you want it on top of
    --         {
    --             PROP = 'prop_table_07', -- prop Hashname
    --             COORDS = vector4(-1205.7290, -1541.3876, 4.2859, 327.3159), -- location to spawn item
    --         },
    --         {
    --             PROP = 'prop_pizza_box_02', -- prop Hashname
    --             COORDS = vector4(-1205.7290, -1541.3876, 4.2859, 327.3159), -- location to spawn item
    --         },
    --     },
    --     TARGET = {
    --         LABEL = "Run a delivery for Pizzeria", -- What it will say for your third eye
    --         ICON = "fas fa-pizza-slice", -- font awesome icon for the thirdeye
    --     },
    --     LOCATIONS = { -- only add this table if you want custom locations for this restaurant
            
    --     }
    -- },
}