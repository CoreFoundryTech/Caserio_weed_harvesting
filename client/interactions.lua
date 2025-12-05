local QBCore = exports['qb-core']:GetCoreObject()
local placing = false

-- Raycast helper
function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, 1, -1, 1))
    return b, c, e
end

function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

-- Pot placement with preview
local previewObject = nil

RegisterNetEvent('weed:client:usePot', function()
    if placing then return end
    placing = true
    
    local model = GetHashKey(Config.PotModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    
    -- Create preview object
    previewObject = CreateObject(model, 0, 0, 0, false, false, false)
    SetEntityAlpha(previewObject, 150, false)
    SetEntityCollision(previewObject, false, false)
    
    if Config.Debug then print('^2[Weed]^7 Pot placement mode started') end
    
    CreateThread(function()
        while placing do
            Wait(0)
            local hit, coords = RayCastGamePlayCamera(10.0)
            
            if hit then
                SetEntityCoords(previewObject, coords.x, coords.y, coords.z)
                PlaceObjectOnGroundProperly(previewObject)
            end
            
            -- Help text
            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName(_L('place_pot'))
            EndTextCommandDisplayHelp(0, 0, 1, -1)
            
            -- Confirm placement
            if IsControlJustPressed(0, 38) then -- E
                placing = false
                local finalCoords = GetEntityCoords(previewObject)
                local heading = GetEntityHeading(previewObject)
                DeleteEntity(previewObject)
                previewObject = nil
                
                -- Use progressbar with animation
                QBCore.Functions.Progressbar("place_pot", _L('placing_pot'), 3000, false, true, {
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
                    TriggerServerEvent('weed:server:removePotItem')
                    
                    -- Spawn final pot
                    local pot = CreateObject(model, finalCoords.x, finalCoords.y, finalCoords.z, true, true, false)
                    SetEntityHeading(pot, heading)
                    PlaceObjectOnGroundProperly(pot)
                    FreezeEntityPosition(pot, true)
                    
                    QBCore.Functions.Notify(_L('pot_placed'), "success")
                    if Config.Debug then print('^2[Weed]^7 Pot placed at', finalCoords) end
                end, function() -- Cancel
                    ClearPedTasks(PlayerPedId())
                    QBCore.Functions.Notify(_L('canceled'), "error")
                end)
            end
            
            -- Cancel
            if IsControlJustPressed(0, 177) then -- ESC
                placing = false
                DeleteEntity(previewObject)
                previewObject = nil
                QBCore.Functions.Notify(_L('canceled'), "error")
            end
        end
    end)
end)

-- Plant seed in pot with progressbar
local function PlantSeed(strain, potEntity)
    local coords = GetEntityCoords(potEntity)
    local heading = GetEntityHeading(potEntity)
    
    if Config.Debug then print('^2[Weed]^7 Starting to plant', strain) end
    
    QBCore.Functions.Progressbar("plant_seed", _L('planting'), 5000, false, true, {
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
        
        -- Delete pot
        if DoesEntityExist(potEntity) then
            DeleteEntity(potEntity)
        end
        
        -- Notify server to create plant
        if Config.Debug then print('^2[Weed]^7 Triggering server to plant at:', coords) end
        TriggerServerEvent('weed:server:plantSeed', strain, vector4(coords.x, coords.y, coords.z, heading))
        QBCore.Functions.Notify(_L('planted', Config.Strains[strain].label), "success")
    end, function() -- Cancel
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify(_L('canceled'), "error")
    end)
end

-- Register seed items
for strain, data in pairs(Config.Strains) do
    RegisterNetEvent('weed:client:useSeed:' .. strain, function()
        if Config.Debug then print('^2[Weed]^7 Using seed:', strain) end
        
        -- Check for nearby pot
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local potModel = GetHashKey(Config.PotModel)
        local pot = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, potModel, false, false, false)
        
        if pot and pot ~= 0 then
            PlantSeed(strain, pot)
        else
            QBCore.Functions.Notify(_L('need_empty_pot'), "error")
        end
    end)
end

-- Target for plants (to open UI)
CreateThread(function()
    Wait(1000) -- Let everything load
    
    if Config.Target == 'qb-target' then
        local models = {}
        for _, data in pairs(Config.Strains) do
            table.insert(models, GetHashKey(data.model_small))
            table.insert(models, GetHashKey(data.model_med))
            table.insert(models, GetHashKey(data.model_large))
        end
        
        exports['qb-target']:AddTargetModel(models, {
            options = {
                {
                    type = "client",
                    action = function(entity)
                        local plantId = exports[GetCurrentResourceName()]:GetPlantIdFromEntity(entity)
                        if plantId then
                            TriggerEvent('weed:client:openUI', plantId)
                        end
                    end,
                    icon = "fas fa-cannabis",
                    label = _L('ui_growth'),
                },
            },
            distance = 2.5,
        })
    end
end)

-- DrawText3D Helper
local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Help text for planting near empty pot (NO SOUND SPAM)
CreateThread(function()
    local potModel = GetHashKey(Config.PotModel)
    
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local nearPot = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.5, potModel, false, false, false)
        
        if nearPot and nearPot ~= 0 then
            local potCoords = GetEntityCoords(nearPot)
            local dist = #(coords - potCoords)
            
            if dist < 2.0 then
                -- Check if player has any seeds
                local hasSeed = false
                for strain, _ in pairs(Config.Strains) do
                    if QBCore.Functions.HasItem(Config.Items.seed_prefix .. strain) then
                        hasSeed = true
                        break
                    end
                end
                
                if hasSeed then
                    DrawText3D(potCoords.x, potCoords.y, potCoords.z + 0.5, _L('use_seed_on_pot'))
                    
                    -- Listen for E key here directly
                    if IsControlJustPressed(0, 38) then
                        -- Find which seed to use (first one found)
                        for strain, _ in pairs(Config.Strains) do
                            if QBCore.Functions.HasItem(Config.Items.seed_prefix .. strain) then
                                TriggerEvent('weed:client:useSeed:' .. strain)
                                break
                            end
                        end
                        Wait(1000) -- Cooldown
                    end
                end
            end
        else
            Wait(500)
        end
    end
end)

-- Cleanup on resource stop to prevent crashes
local previewObject = nil

-- Store preview object reference
RegisterNetEvent('weed:client:storePreview', function(obj)
    previewObject = obj
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        -- Delete preview object if exists
        if previewObject and DoesEntityExist(previewObject) then
            DeleteEntity(previewObject)
            if Config.Debug then print('^3[Weed]^7 Cleaned up preview object on restart') end
        end
        
        -- Reset placement state
        placing = false
        
        -- Clear any active progressbar
        if QBCore.Functions.CancelProgressbar then
            QBCore.Functions.CancelProgressbar()
        end
        
        if Config.Debug then print('^3[Weed]^7 Resource stopped safely') end
    end
end)

