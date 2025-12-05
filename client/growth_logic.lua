local function HotSwapPlant(currentEntity, nextStageModel, plantData)
    local coords = GetEntityCoords(currentEntity)
    local heading = GetEntityHeading(currentEntity)
    
    -- Limpieza (The Purge)
    if DoesEntityExist(currentEntity) then
        SetEntityAsMissionEntity(currentEntity, true, true)
        DeleteEntity(currentEntity)
    end

    -- Generación (The Rebirth)
    local modelHash = GetHashKey(nextStageModel)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(10) end
    
    -- Create object (Networked = false for better performance/sync control manually)
    local newObj = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(newObj, heading)
    FreezeEntityPosition(newObj, true)
    PlaceObjectOnGroundProperly(newObj)
    
    -- Inyección de Estado (State Injection)
    Entity(newObj).state:set('plantData', plantData, true)
    
    return newObj
end

-- Export function to be used in main.lua
exports('HotSwapPlant', HotSwapPlant)
