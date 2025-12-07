local QBCore = exports['qb-core']:GetCoreObject()

-- Smoking Effects Configuration (duration in milliseconds)
local SmokingEffects = {
    blue = {
        name = "Blue Dream",
        duration = 240000, -- 4 minutes (strongest)
        screenEffect = "DrugsMichaelAliensFightIn",
        walkStyle = "move_m@drunk@verydrunk"
    },
    green = {
        name = "Green Crack",
        duration = 180000, -- 3 minutes
        screenEffect = "DrugsTrevorClownsFight",
        walkStyle = "move_m@drunk@moderatedrunk"
    },
    orange = {
        name = "Orange Kush",
        duration = 150000, -- 2.5 minutes
        screenEffect = "ChopVision",
        walkStyle = "move_m@drunk@slightlydrunk"
    },
    pink = {
        name = "Pink Panther",
        duration = 120000, -- 2 minutes
        screenEffect = "DrugsDrivingIn",
        walkStyle = "move_m@drunk@slightlydrunk"
    },
    purple = {
        name = "Purple Haze",
        duration = 240000, -- 4 minutes (strongest)
        screenEffect = "DrugsMichaelAliensFight",
        walkStyle = "move_m@drunk@verydrunk"
    },
    red = {
        name = "Red Dragon",
        duration = 180000, -- 3 minutes
        screenEffect = "DrugsTrevorClownsFightIn",
        walkStyle = "move_m@drunk@moderatedrunk"
    },
    yellow = {
        name = "Yellow Submarine",
        duration = 150000, -- 2.5 minutes
        screenEffect = "DMT_flight",
        walkStyle = "move_m@drunk@slightlydrunk"
    }
}

local isHigh = false
local highEndTime = 0
local currentEffect = nil

-- Smoke Animation
local function PlaySmokeAnimation()
    local ped = PlayerPedId()
    local animDict = "amb@world_human_smoking@male@male_a@enter"
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end
    
    TaskPlayAnim(ped, animDict, "enter", 8.0, -8.0, 3000, 49, 0, false, false, false)
    Wait(3000)
    ClearPedTasks(ped)
end

-- Apply Effects
local function ApplyHighEffects(strain)
    local effectData = SmokingEffects[strain]
    if not effectData then return end
    
    local ped = PlayerPedId()
    
    -- Already high? Extend duration
    if isHigh then
        highEndTime = GetGameTimer() + effectData.duration
        QBCore.Functions.Notify("El efecto de " .. effectData.name .. " se intensifica", "success")
        return
    end
    
    isHigh = true
    highEndTime = GetGameTimer() + effectData.duration
    currentEffect = effectData.screenEffect
    
    -- Apply screen effect
    StartScreenEffect(currentEffect, 0, true)
    
    -- Apply walk style
    RequestAnimSet(effectData.walkStyle)
    while not HasAnimSetLoaded(effectData.walkStyle) do Wait(10) end
    SetPedMovementClipset(ped, effectData.walkStyle, 1.0)
    
    -- Motion blur
    SetPedMotionBlur(ped, true)
    
    QBCore.Functions.Notify("¡Estás fumando " .. effectData.name .. "!", "success")
    
    -- Effect loop
    CreateThread(function()
        while isHigh and GetGameTimer() < highEndTime do
            Wait(1000)
            
            -- Keep effect active
            if not HasScreenEffectStarted(currentEffect) then
                StartScreenEffect(currentEffect, 0, true)
            end
            
            -- Random stumble
            if math.random(1, 100) <= 5 then
                local ped = PlayerPedId()
                SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)
            end
        end
        
        -- Clear effects
        ClearHighEffects()
    end)
end

-- Clear Effects
function ClearHighEffects()
    if not isHigh then return end
    
    local ped = PlayerPedId()
    
    isHigh = false
    highEndTime = 0
    
    if currentEffect then
        StopScreenEffect(currentEffect)
    end
    currentEffect = nil
    
    -- Reset walk
    ResetPedMovementClipset(ped, 1.0)
    SetPedMotionBlur(ped, false)
    
    QBCore.Functions.Notify("El efecto ha pasado", "info")
end

-- Smoke Weed Function
local function SmokeWeed(strain)
    -- Play animation first
    PlaySmokeAnimation()
    
    -- Then apply effects
    ApplyHighEffects(strain)
end

-- Register smoking events for each strain
for strain, _ in pairs(SmokingEffects) do
    RegisterNetEvent('weed:client:smoke:' .. strain, function()
        if Config.Debug then
            print('^2[Weed Effects]^7 Smoking ' .. strain)
        end
        SmokeWeed(strain)
    end)
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        if isHigh then
            ClearHighEffects()
        end
    end
end)

-- Export for external use
exports('IsPlayerHigh', function()
    return isHigh
end)

exports('ClearHighEffects', function()
    ClearHighEffects()
end)
