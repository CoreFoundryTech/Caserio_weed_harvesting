local QBCore = exports['qb-core']:GetCoreObject()

-- Smoking effects configuration
local SmokingEffects = {
    blue = {
        name = "Blue Dream",
        duration = 180000, -- 3 minutes
        screenEffect = "DrugsMichaelAliensFightIn",
        intensity = 0.5
    },
    green = {
        name = "Green Crack",
        duration = 180000, -- 3 minutes
        screenEffect = "DrugsTrevorClownsFight",
        intensity = 0.6
    },
    orange = {
        name = "Orange Kush",
        duration = 180000, -- 3 minutes
        screenEffect = "ChopVision",
        intensity = 0.7
    },
    pink = {
        name = "Pink Panther",
        duration = 180000, -- 3 minutes
        screenEffect = "DrugsDrivingIn",
        intensity = 0.5
    },
    purple = {
        name = "Purple Haze",
        duration = 180000, -- 3 minutes
        screenEffect = "DrugsMichaelAliensFight",
        intensity = 0.8
    },
    red = {
        name = "Red Dragon",
        duration = 180000, -- 3 minutes
        screenEffect = "DrugsTrevorClownsFightIn",
        intensity = 0.7
    },
    yellow = {
        name = "Yellow Submarine",
        duration = 180000, -- 3 minutes
        screenEffect = "DMT_flight",
        intensity = 0.6
    }
}

local isHigh = false

-- Smoke weed function
local function SmokeWeed(strain)
    if isHigh then
        QBCore.Functions.Notify("Ya estás volado!", "error")
        return
    end
    
    local effectData = SmokingEffects[strain]
    if not effectData then return end
    
    local ped = PlayerPedId()
    
    -- Play smoking animation
    RequestAnimDict("amb@world_human_smoking@male@male_a@enter")
    while not HasAnimDictLoaded("amb@world_human_smoking@male@male_a@enter") do Wait(10) end
    
    TaskPlayAnim(ped, "amb@world_human_smoking@male@male_a@enter", "enter", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    QBCore.Functions.Notify("Fumando " .. effectData.name .. "...", "success")
    
    Wait(5000) -- Smoke for 5 seconds
    ClearPedTasks(ped)
    
    -- Apply effects
    isHigh = true
    
    -- Screen effect
    StartScreenEffect(effectData.screenEffect, 0, true)
    
    -- Movement alteration
    SetPedMotionBlur(ped, true)
    SetPedIsDrunk(ped, true)
    
    QBCore.Functions.Notify("¡Estás volado con " .. effectData.name .. "!", "success")
    
    -- Duration thread
    CreateThread(function()
        local endTime = GetGameTimer() + effectData.duration
        
        while GetGameTimer() < endTime do
            Wait(1000)
            
            -- Pulse intensity
            local remaining = endTime - GetGameTimer()
            local pulseIntensity = effectData.intensity + (math.sin(GetGameTimer() / 1000) * 0.2)
            
            -- Keep effect active
            if not HasScreenEffectStarted(effectData.screenEffect) then
                StartScreenEffect(effectData.screenEffect, 0, true)
            end
        end
        
        -- Clear effects
        StopScreenEffect(effectData.screenEffect)
        SetPedMotionBlur(ped, false)
        SetPedIsDrunk(ped, false)
        isHigh = false
        
        QBCore.Functions.Notify("El efecto ha pasado", "info")
    end)
end

-- Register usable items for weed buds
for strain, data in pairs(Config.Strains) do
    local weedItem = Config.Items.weed_prefix .. strain
    
    RegisterNetEvent('weed:client:smoke:' .. strain, function()
        SmokeWeed(strain)
    end)
end
