local QBCore = exports['qb-core']:GetCoreObject()

-- Helper function to get plant data
local function GetPlant(plantId)
    local result = MySQL.query.await('SELECT * FROM weed_plants WHERE id = ?', {plantId})
    if result and result[1] then
        result[1].coords = json.decode(result[1].coords)
        return result[1]
    end
    return nil
end

-- Helper to get all plants
local function GetAllPlants()
    local plants = MySQL.query.await('SELECT * FROM weed_plants')
    for i = 1, #plants do
        plants[i].coords = json.decode(plants[i].coords)
    end
    return plants
end

-- Sync plants to all clients
local function SyncPlants()
    local plants = GetAllPlants()
    TriggerClientEvent('weed:client:syncPlants', -1, plants)
end

-- Sync plants to specific client
local function SyncPlantsToClient(source)
    local plants = GetAllPlants()
    TriggerClientEvent('weed:client:syncPlants', source, plants)
end

-- Remove Pot Item (Placement)
RegisterNetEvent('weed:server:removePotItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.RemoveItem('weed_pot', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['weed_pot'], "remove")
    end
end)

-- Plant Seed Event
RegisterNetEvent('weed:server:plantSeed', function(strain, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Config.Debug then print('^2[Weed Server]^7 plantSeed called. Strain:', strain, 'Coords:', coords) end
    
    if not Player then 
        if Config.Debug then print('^1[Weed Server]^7 No player found') end
        return 
    end
    
    -- Validate strain
    if not Config.Strains[strain] then 
        if Config.Debug then print('^1[Weed Server]^7 Invalid strain:', strain) end
        return 
    end
    
    -- Check item
    local seedItem = Config.Items.seed_prefix .. strain
    if Config.Debug then print('^2[Weed Server]^7 Checking for item:', seedItem) end
    
    if Player.Functions.GetItemByName(seedItem) then
        if Player.Functions.RemoveItem(seedItem, 1) then
            -- Insert into DB
            local coordsJson = json.encode(coords)
            if Config.Debug then print('^2[Weed Server]^7 Inserting plant into DB...') end
            
            MySQL.insert('INSERT INTO weed_plants (owner, strain, stage, coords) VALUES (?, ?, ?, ?)',
                {Player.PlayerData.citizenid, strain, 0, coordsJson}, function(id)
                    if id then
                        if Config.Debug then print('^2[Weed Server]^7 Plant created with ID:', id) end
                        -- Wait a bit before syncing to prevent duplication
                        Wait(500)
                        SyncPlants()
                        TriggerClientEvent('QBCore:Notify', src, _L('planted', Config.Strains[strain].label), 'success')
                    else
                        if Config.Debug then print('^1[Weed Server]^7 Failed to insert plant into DB') end
                    end
                end)
        else
            if Config.Debug then print('^1[Weed Server]^7 Failed to remove seed item') end
            TriggerClientEvent('QBCore:Notify', src, _L('no_seeds'), 'error')
        end
    else
        if Config.Debug then print('^1[Weed Server]^7 Player does not have seed:', seedItem) end
        TriggerClientEvent('QBCore:Notify', src, _L('no_seeds'), 'error')
    end
end)

-- Harvest Plant Event
RegisterNetEvent('weed:server:harvestPlant', function(plantId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local plant = GetPlant(plantId)
    if not plant then return end
    
    if plant.stage < 2 then
        TriggerClientEvent('QBCore:Notify', src, _L('not_ready'), 'error')
        return
    end
    
    -- Calculate rewards
    local strainData = Config.Strains[plant.strain]
    local amount = math.random(strainData.yield.min, strainData.yield.max)
    local weedItem = Config.Items.weed_prefix .. plant.strain
    
    -- Give weed
    if Player.Functions.AddItem(weedItem, amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[weedItem], "add")
        
        -- Chance for seed back
        if math.random(1, 100) <= strainData.seed_chance then
            local seedItem = Config.Items.seed_prefix .. plant.strain
            Player.Functions.AddItem(seedItem, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[seedItem], "add")
        end
        
        -- Remove plant from DB
        MySQL.query('DELETE FROM weed_plants WHERE id = ?', {plantId}, function()
            SyncPlants()
            TriggerClientEvent('QBCore:Notify', src, _L('harvested', amount, strainData.label), 'success')
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, _L('inventory_full'), 'error')
    end
end)

-- Growth Loop (Optimized)
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        -- Only query plants that are ready to grow (stage < 2 and time elapsed)
        for stage = 0, 1 do
            local minutesNeeded = Config.GrowthStages[stage]
            
            -- SQL query finds ONLY plants ready to upgrade this stage
            local result = MySQL.query.await(
                'SELECT id FROM weed_plants WHERE stage = ? AND TIMESTAMPDIFF(MINUTE, last_update, NOW()) >= ?',
                {stage, minutesNeeded}
            )
            
            if result and #result > 0 then
                if Config.Debug then print('^2[Weed]^7 Growing', #result, 'plants from stage', stage) end
                
                for _, row in ipairs(result) do
                    MySQL.update('UPDATE weed_plants SET stage = ?, last_update = NOW() WHERE id = ?', 
                        {stage + 1, row.id}
                    )
                end
                
                -- Sync all clients once after batch update
                SyncPlants()
            end
        end
    end
end)

-- Initial Sync
RegisterNetEvent('weed:server:requestSync', function()
    SyncPlantsToClient(source)
end)

-- Admin command to spawn seed (for testing)
QBCore.Commands.Add('giveseed', 'Give weed seed (Admin)', {{name='strain', help='blue, green, etc'}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local strain = args[1]
    
    if Config.Strains[strain] then
        local item = Config.Items.seed_prefix .. strain
        Player.Functions.AddItem(item, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
    else
        TriggerClientEvent('QBCore:Notify', src, 'Invalid strain', 'error')
    end
end, 'admin')

-- Usable Items
QBCore.Functions.CreateUseableItem('weed_pot', function(source, item)
    local src = source
    if Config.Debug then print('^2[Weed]^7 Used weed_pot on server') end
    TriggerClientEvent('weed:client:usePot', src)
end)

for strain, data in pairs(Config.Strains) do
    local seedItem = Config.Items.seed_prefix .. strain
    QBCore.Functions.CreateUseableItem(seedItem, function(source, item)
        local src = source
        TriggerClientEvent('weed:client:useSeed:' .. strain, src)
    end)
    
    -- Make weed buds usable (smokeable)
    local weedItem = Config.Items.weed_prefix .. strain
    QBCore.Functions.CreateUseableItem(weedItem, function(source, item)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.Functions.RemoveItem(weedItem, 1) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[weedItem], "remove")
            TriggerClientEvent('weed:client:smoke:' .. strain, src)
        end
    end)
end

