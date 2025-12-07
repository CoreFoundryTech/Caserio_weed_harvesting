local QBCore = exports['qb-core']:GetCoreObject()
local SpawnedPlants = {}
local Plants = {}
local CurrentUIPlantId = nil

-- Constants
local POT_MODEL = Config.PotModel

-- Helper Functions
local function GetPlantModel(strain, stage)
    local strainData = Config.Strains[strain]
    if not strainData then return nil end
    if stage == 0 then return strainData.model_small end
    if stage == 1 then return strainData.model_med end
    if stage >= 2 then return strainData.model_large end
    return strainData.model_small
end

local function RayCastCamera(dist)
    local camRot = GetGameplayCamRot()
    local camCoords = GetGameplayCamCoord()
    local direction = vector3(
        -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
        math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
        math.sin(math.rad(camRot.x))
    )
    local dest = camCoords + (direction * dist)
    local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, dest.x, dest.y, dest.z, 1, -1, 1)
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(ray)
    return hit, endCoords, entityHit
end

-- Check if player is inside their property
local function IsInsideOwnedProperty()
    if not Config.RequireProperty then return true end
    
    -- Try ps-housing
    local success, result = pcall(function()
        return exports['ps-housing']:IsInOwnedApartment()
    end)
    if success and result then return true end
    
    -- Try qb-apartments
    success, result = pcall(function()
        return exports['qb-apartments']:GetCurrentApartment()
    end)
    if success and result then return true end
    
    -- Try qb-houses
    success, result = pcall(function()
        return exports['qb-houses']:GetCurrentHouse()
    end)
    if success and result then return true end
    
    -- If no housing system detected or not in property
    if Config.Debug then print('^3[Weed]^7 No property detected or not inside') end
    return false
end

-- Get player's current plant count
local function GetMyPlantCount()
    local citizenid = QBCore.Functions.GetPlayerData().citizenid
    local count = 0
    for _, plant in pairs(Plants) do
        if plant.owner == citizenid then
            count = count + 1
        end
    end
    return count
end

-- Spawn Plant
local function SpawnPlantObject(plant)
    if SpawnedPlants[plant.id] then return end
    
    local model = GetPlantModel(plant.strain, plant.stage)
    if not model then return end
    
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    
    local obj = CreateObject(hash, plant.coords.x, plant.coords.y, plant.coords.z, false, false, false)
    SetEntityHeading(obj, plant.coords.w or 0.0)
    FreezeEntityPosition(obj, true)
    PlaceObjectOnGroundProperly(obj)
    
    SpawnedPlants[plant.id] = obj
end

-- Delete Plant
local function DeletePlantObject(plantId)
    if SpawnedPlants[plantId] then
        if DoesEntityExist(SpawnedPlants[plantId]) then
            DeleteEntity(SpawnedPlants[plantId])
        end
        SpawnedPlants[plantId] = nil
    end
end

-- Sync from Server
RegisterNetEvent('weed:client:syncPlants', function(serverPlants)
    Plants = serverPlants
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    
    for _, plant in pairs(Plants) do
        local pLoc = vector3(plant.coords.x, plant.coords.y, plant.coords.z)
        if #(pCoords - pLoc) < 50.0 then
            if SpawnedPlants[plant.id] then
                local currentModel = GetEntityModel(SpawnedPlants[plant.id])
                local expectedModel = GetHashKey(GetPlantModel(plant.strain, plant.stage))
                if currentModel ~= expectedModel then
                    DeletePlantObject(plant.id)
                    Wait(50)
                    SpawnPlantObject(plant)
                end
            else
                SpawnPlantObject(plant)
            end
        else
            DeletePlantObject(plant.id)
        end
    end
    
    for id, _ in pairs(SpawnedPlants) do
        local exists = false
        for _, p in pairs(Plants) do
            if p.id == id then exists = true break end
        end
        if not exists then DeletePlantObject(id) end
    end
    
    -- Update UI if open
    if CurrentUIPlantId then
        for _, plant in pairs(Plants) do
            if plant.id == CurrentUIPlantId then
                SendPlantDataToUI(plant, 'update')
                break
            end
        end
    end
end)

-- Send plant data to UI
function SendPlantDataToUI(plant, action)
    action = action or 'open'
    
    local stageNames = {
        [0] = _L('stage_0'),
        [1] = _L('stage_1'),
        [2] = _L('stage_2')
    }
    
    local growthPct = ((plant.stage + 1) / 3) * 100
    if plant.stage >= 2 then growthPct = 100 end
    
    -- Calculate time remaining
    local timeRemaining = 0
    if plant.stage < 2 then
        local stageMinutes = Config.GrowthStages[plant.stage] or 2
        timeRemaining = stageMinutes * 60
    end
    
    local data = {
        action = action,
        plant = {
            id = plant.id,
            strain = plant.strain,
            stage = plant.stage,
            stageName = stageNames[plant.stage] or 'Desconocido',
            label = Config.Strains[plant.strain].label,
            health = 100,
            water = 100,
            growthPercent = math.floor(growthPct),
            isReady = plant.stage >= 2,
            timeRemaining = timeRemaining,
            plantCount = GetMyPlantCount(),
            maxPlants = Config.MaxPlantsPerPlayer
        }
    }
    
    if Config.Debug then
        print('^2[Weed UI]^7 Sending NUI message: action=' .. action .. ', plantId=' .. plant.id)
    end
    
    SendNUIMessage(data)
end

-- Planting Seed
local function AttemptPlantSeed(strain)
    -- Check property
    if not IsInsideOwnedProperty() then
        QBCore.Functions.Notify(_L('not_in_property') or 'Debes estar en tu propiedad', 'error')
        return
    end
    
    -- Check plant limit
    local currentCount = GetMyPlantCount()
    if currentCount >= Config.MaxPlantsPerPlayer then
        QBCore.Functions.Notify(string.format(_L('plant_limit') or 'Límite alcanzado (%d/%d)', currentCount, Config.MaxPlantsPerPlayer), 'error')
        return
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local potHash = GetHashKey(POT_MODEL)
    local pot = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, potHash, false, false, false)
    
    if pot and pot ~= 0 then
        local pCoords = GetEntityCoords(pot)
        local pHeading = GetEntityHeading(pot)
        
        QBCore.Functions.Progressbar("plant_seed", _L('planting'), 3000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@world_human_gardener_plant@male@base",
            anim = "base",
            flags = 16,
        }, {}, {}, function()
            ClearPedTasks(ped)
            if DoesEntityExist(pot) then
                DeleteEntity(pot)
            end
            TriggerServerEvent('weed:server:plantSeed', strain, vector4(pCoords.x, pCoords.y, pCoords.z, pHeading))
        end, function()
            ClearPedTasks(ped)
            QBCore.Functions.Notify(_L('canceled'), "error")
        end)
    else
        QBCore.Functions.Notify(_L('need_empty_pot'), "error")
    end
end

-- Register Seed Events
for strain, _ in pairs(Config.Strains) do
    RegisterNetEvent('weed:client:useSeed:' .. strain, function()
        AttemptPlantSeed(strain)
    end)
end

-- Target System
CreateThread(function()
    Wait(1000)
    if Config.Target == 'qb-target' then
        local targetModels = {}
        for _, s in pairs(Config.Strains) do
            table.insert(targetModels, GetHashKey(s.model_small))
            table.insert(targetModels, GetHashKey(s.model_med))
            table.insert(targetModels, GetHashKey(s.model_large))
        end
        
        exports['qb-target']:AddTargetModel(targetModels, {
            options = {
                {
                    icon = "fas fa-leaf",
                    label = _L('ui_growth'),
                    action = function(entity)
                        local plantId = nil
                        for id, e in pairs(SpawnedPlants) do
                            if e == entity then plantId = id break end
                        end
                        if plantId then TriggerEvent('weed:client:openUI', plantId) end
                    end,
                },
                {
                    icon = "fas fa-hand-holding-seedling",
                    label = _L('ui_harvest'),
                    action = function(entity)
                        local plantId = nil
                        for id, e in pairs(SpawnedPlants) do
                            if e == entity then plantId = id break end
                        end
                        if plantId then TriggerEvent('weed:client:harvest', {plantId = plantId}) end
                    end,
                    canInteract = function(entity)
                        for id, e in pairs(SpawnedPlants) do
                            if e == entity then
                                for _, p in pairs(Plants) do
                                    if p.id == id then return p.stage >= 2 end
                                end
                            end
                        end
                        return false
                    end
                }
            },
            distance = 2.5
        })
    end
end)

-- NUI Logic
RegisterNetEvent('weed:client:openUI', function(plantId)
    local plant = nil
    for _, p in pairs(Plants) do if p.id == plantId then plant = p break end end
    
    if plant then
        CurrentUIPlantId = plantId
        SetNuiFocus(true, true)
        SendPlantDataToUI(plant, 'open')
    end
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    CurrentUIPlantId = nil
    cb('ok')
end)

-- ESC key backup (in case NUI doesn't respond)
CreateThread(function()
    while true do
        Wait(0)
        if CurrentUIPlantId and IsControlJustPressed(0, 177) then -- ESC
            SetNuiFocus(false, false)
            CurrentUIPlantId = nil
            if Config.Debug then print('^3[Weed UI]^7 Closed via ESC key') end
        end
    end
end)

RegisterNUICallback('harvest', function(data, cb)
    SetNuiFocus(false, false)
    CurrentUIPlantId = nil
    if data.plantId then
        TriggerEvent('weed:client:harvest', {plantId = data.plantId})
    end
    cb('ok')
end)

-- Harvest Event
RegisterNetEvent('weed:client:harvest', function(data)
    local plantId = data.plantId
    if not plantId then return end
    
    local plant = nil
    for _, p in pairs(Plants) do if p.id == plantId then plant = p break end end
    if not plant or plant.stage < 2 then
        QBCore.Functions.Notify(_L('not_ready'), 'error')
        return
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
    }, {}, {}, function()
        ClearPedTasks(PlayerPedId())
        local entity = SpawnedPlants[plantId]
        if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
        SpawnedPlants[plantId] = nil
        TriggerServerEvent('weed:server:harvestPlant', plantId)
    end, function()
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify(_L('canceled'), "error")
    end)
end)

-- Pot Placement
local placemode = false
local previewObj = nil

RegisterNetEvent('weed:client:usePot', function()
    if placemode then return end
    
    -- Check property
    if not IsInsideOwnedProperty() then
        QBCore.Functions.Notify(_L('not_in_property') or 'Debes estar en tu propiedad', 'error')
        return
    end
    
    -- Check plant limit BEFORE placing pot
    local currentCount = GetMyPlantCount()
    if currentCount >= Config.MaxPlantsPerPlayer then
        QBCore.Functions.Notify(string.format(_L('plant_limit') or 'Límite alcanzado (%d/%d)', currentCount, Config.MaxPlantsPerPlayer), 'error')
        return
    end
    
    placemode = true
    
    local model = GetHashKey(POT_MODEL)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    
    previewObj = CreateObject(model, 0, 0, 0, false, false, false)
    SetEntityAlpha(previewObj, 150, false)
    SetEntityCollision(previewObj, false, false)
    
    CreateThread(function()
        while placemode do
            Wait(0)
            local hit, coords, _ = RayCastCamera(10.0)
            
            if hit then
                SetEntityCoords(previewObj, coords.x, coords.y, coords.z)
                PlaceObjectOnGroundProperly(previewObj)
            end
            
            DrawText3D(coords.x, coords.y, coords.z + 0.5, _L('place_pot'))
            
            if IsControlJustPressed(0, 38) then
                placemode = false
                local finalCoords = GetEntityCoords(previewObj)
                local heading = GetEntityHeading(previewObj)
                DeleteEntity(previewObj)
                previewObj = nil
                
                QBCore.Functions.Progressbar("place_pot", _L('placing_pot'), 2000, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "amb@world_human_gardener_plant@male@base",
                    anim = "base",
                    flags = 16,
                }, {}, {}, function()
                    ClearPedTasks(PlayerPedId())
                    TriggerServerEvent('weed:server:removePotItem')
                    local pot = CreateObject(model, finalCoords.x, finalCoords.y, finalCoords.z, true, true, false)
                    SetEntityHeading(pot, heading)
                    PlaceObjectOnGroundProperly(pot)
                    FreezeEntityPosition(pot, true)
                    QBCore.Functions.Notify(_L('pot_placed'), 'success')
                end, function()
                    ClearPedTasks(PlayerPedId())
                    QBCore.Functions.Notify(_L('canceled'), "error")
                end)
            end
            
            if IsControlJustPressed(0, 177) then
                placemode = false
                if DoesEntityExist(previewObj) then DeleteEntity(previewObj) end
                previewObj = nil
                QBCore.Functions.Notify(_L('canceled'), "error")
            end
        end
    end)
end)

-- Helper DrawText3D
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Initial Sync
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('weed:server:requestSync')
end)

-- Cleanup
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for _, e in pairs(SpawnedPlants) do
            if DoesEntityExist(e) then DeleteEntity(e) end
        end
        if previewObj and DoesEntityExist(previewObj) then DeleteEntity(previewObj) end
    end
end)
