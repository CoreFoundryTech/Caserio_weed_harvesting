local QBCore = exports['qb-core']:GetCoreObject()
local SpawnedPlants = {}
local Plants = {}

-- Helper to get plant model based on stage and strain
local function GetPlantModel(strain, stage)
    local strainData = Config.Strains[strain]
    if not strainData then return nil end
    
    if stage == 0 then return strainData.model_small end
    if stage == 1 then return strainData.model_med end
    if stage == 2 then return strainData.model_large end
    
    return strainData.model_small
end

-- Spawn a single plant object
local function SpawnPlantObject(plant)
    if SpawnedPlants[plant.id] then return end
    
    local model = GetPlantModel(plant.strain, plant.stage)
    if not model then return end
    
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    
    local obj = CreateObject(GetHashKey(model), plant.coords.x, plant.coords.y, plant.coords.z, false, false, false)
    SetEntityHeading(obj, plant.coords.w or 0.0)
    FreezeEntityPosition(obj, true)
    PlaceObjectOnGroundProperly(obj)
    
    SpawnedPlants[plant.id] = obj
end

-- Delete a single plant object
local function DeletePlantObject(plantId)
    if SpawnedPlants[plantId] then
        if DoesEntityExist(SpawnedPlants[plantId]) then
            DeleteEntity(SpawnedPlants[plantId])
        end
        SpawnedPlants[plantId] = nil
    end
end

-- Sync plants from server
RegisterNetEvent('weed:client:syncPlants', function(serverPlants)
    Plants = serverPlants
    
    -- Refresh nearby plants
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for _, plant in pairs(Plants) do
        local dist = #(playerCoords - vector3(plant.coords.x, plant.coords.y, plant.coords.z))
        
        if dist < 50.0 then
            -- If close, ensure spawned and correct model
            if not SpawnedPlants[plant.id] then
                SpawnPlantObject(plant)
            else
                -- Check if model needs update (growth)
                local currentObj = SpawnedPlants[plant.id]
                local currentModel = GetEntityModel(currentObj)
                local expectedModel = GetHashKey(GetPlantModel(plant.strain, plant.stage))
                
                if currentModel ~= expectedModel then
                    if Config.Debug then print('^2[Weed]^7 Updating plant model for ID:', plant.id) end
                    DeletePlantObject(plant.id)
                    Wait(50) -- Small wait to ensure deletion
                    SpawnPlantObject(plant)
                end
            end
        else
            -- If far, delete
            DeletePlantObject(plant.id)
        end
    end
    
    -- Cleanup deleted plants (in SpawnedPlants but not in Plants)
    for id, obj in pairs(SpawnedPlants) do
        local exists = false
        for _, plant in pairs(Plants) do
            if plant.id == id then exists = true break end
        end
        
        if not exists then
            DeletePlantObject(id)
        end
    end
end)

-- Main loop to manage spawning based on distance
CreateThread(function()
    while true do
        Wait(2000)
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for _, plant in pairs(Plants) do
            local dist = #(playerCoords - vector3(plant.coords.x, plant.coords.y, plant.coords.z))
            
            if dist < 50.0 then
                if not SpawnedPlants[plant.id] then
                    SpawnPlantObject(plant)
                end
            else
                if SpawnedPlants[plant.id] then
                    DeletePlantObject(plant.id)
                end
            end
        end
    end
end)

-- Request sync on start
CreateThread(function()
    TriggerServerEvent('weed:server:requestSync')
end)

-- Cleanup on stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, obj in pairs(SpawnedPlants) do
            if DoesEntityExist(obj) then
                DeleteEntity(obj)
            end
        end
    end
end)

-- Export for interactions
exports('GetPlantIdFromEntity', function(entity)
    for id, obj in pairs(SpawnedPlants) do
        if obj == entity then
            return id
        end
    end
    return nil
end)

-- UI Events
RegisterNetEvent('weed:client:openUI', function(plantId)
    local plant = nil
    for _, p in pairs(Plants) do
        if p.id == plantId then
            plant = p
            break
        end
    end
    
    if plant then
        local strainData = Config.Strains[plant.strain]
        
        -- Calculate time remaining for current stage
        local timeRemaining = 0
        local growthPercent = 0
        
        if plant.stage < 2 then
            local stageMinutes = Config.GrowthStages[plant.stage]
            -- Simplified: assume last_update is recent (server handles this)
            timeRemaining = stageMinutes * 60 -- Convert to seconds
            growthPercent = ((plant.stage + 1) / 3) * 100
        else
            growthPercent = 100
        end
        
        local payload = {
            id = plant.id,
            strain = plant.strain,
            stage = plant.stage,
            label = strainData.label,
            health = math.random(95, 100),
            water = math.random(80, 100),
            timeRemaining = timeRemaining,
            growthPercent = math.floor(growthPercent)
        }
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            plant = payload,
            translations = Locale.Translations[Locale.CurrentLocale] or Locale.Translations[Locale.Fallback]
        })
    end
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('harvest', function(data, cb)
    SetNuiFocus(false, false)
    local plantId = data.plantId
    
    if plantId then
        -- Find and delete the plant entity immediately
        local plantEntity = SpawnedPlants[plantId]
        if plantEntity and DoesEntityExist(plantEntity) then
            if Config.Debug then print('^2[Weed]^7 Deleting plant entity for harvest') end
            DeleteEntity(plantEntity)
            SpawnedPlants[plantId] = nil
        end
        
        QBCore.Functions.Progressbar("harvest_weed", _L('harvesting'), 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        }, {}, {}, function() -- Done
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('weed:server:harvestPlant', plantId)
        end, function() -- Cancel
            ClearPedTasks(PlayerPedId())
            QBCore.Functions.Notify(_L('canceled'), "error")
        end)
    end
    cb('ok')
end)
