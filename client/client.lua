local animalHashList = {}
local isPlayerAnimal = false
local pedMaxHealth = 200
local pedAnimPlaying = false
local walkSpeed = 1.00

for _, v in ipairs(AnimalPed) do
    table.insert(animalHashList, GetHashKey(v))
end
listToNil(AnimalPed)

-- Is Player Animal
CreateThread(function()
    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local player = PlayerId()

        -- Check if player is animal 
        local PlayerPedHash = GetEntityModel(ped)
        local tempAnimalStatus = false

        for _, ListedPedHash in ipairs(animalHashList) do
            if ListedPedHash == PlayerPedHash then
                tempAnimalStatus = true
                break
            end
        end
        isPlayerAnimal = tempAnimalStatus
        if isPlayerAnimal then
            SetPlayerLockonRangeOverride(player, 20.0)
        end
    end
end)

-- Land and Water fixes
CreateThread(function()
    while true do
        Wait(1000)
        if isPlayerAnimal then

            local ped = PlayerPedId()
            local player = PlayerId()

            SetPedDiesInWater(ped, false) -- Disable animal dies in water instantly
            ResetPlayerStamina(player)

            if IsEntityInWater(ped) == 1 then -- If In Water
                SetPlayerSprint(player, false)
                if not pedAnimPlaying then
                    SetPedCanRagdoll(ped, false) -- Disable ragdoll of animals in water
                    SetSwimMultiplierForPlayer(player, Config.SpeedMultiplierWater) -- Make animals normal speed in water
                    --dogSwimAnim()
                    pedAnimPlaying = true
                end
            else
                SetPlayerSprint(player, true)
                if pedAnimPlaying then
                    SetPedCanRagdoll(ped, true) -- Enable ragdoll again
                    SetRunSprintMultiplierForPlayer(player, Config.SpeedMultiplierLand) -- Make animals normal speed in water
                    --ClearPedTasks(ped)
                    pedAnimPlaying = false
                end
            end
        end
    end
end)

-- Health Fixes
CreateThread(function()
    while Config.UseHealthRegen do
        Wait(Config.HealthPointsTimer)
        if isPlayerAnimal then

            local ped = PlayerPedId()
            local player = PlayerId()
            local pedCurrentHealth = GetEntityHealth(ped)     
            
            if pedCurrentHealth < pedMaxHealth and not IsEntityDead(ped) then
                local tempHealth = pedCurrentHealth + Config.HealthPointsRegenerated
                if tempHealth > pedMaxHealth then
                    tempHealth = pedMaxHealth
                end
                SetEntityHealth(ped, tempHealth)
            end
        end
    end
end)

CreateThread(function()
    while Config.DisableIdleCamera do
        Wait(10000)
        if isPlayerAnimal then
            InvalidateIdleCam()
            InvalidateVehicleIdleCam()
        end
    end
end)

-- MLO and underground run speed
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local xyz = GetEntityCoords(ped)

        if not IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
            SetPedMoveRateOverride(ped, 1.75)
            Wait(0)
        else
            Wait(1000)
        end
    end
end)

-- Walk speed
local walkSpeed = tonumber(GetResourceKvpString("AnythingAnimal_Speed") == "1.0")
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedWalking(ped) and (IsControlPressed(0, 32) or IsControlPressed(0, 33) or IsControlPressed(0, 34) or IsControlPressed(0, 35)) and walkSpeed ~= 1.0  then
            SetPedMoveRateOverride(ped, walkSpeed)
            Wait(0)
        else
            Wait(1000)
        end
    end
end)

RegisterCommand('aaws', function(source, args, raw)
    TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal)
end, false)

TriggerEvent("chat:addSuggestion", "/aaws", "Set walk speed 0.00 to 1.75")

RegisterNetEvent('UpdWalkSpeed', function(speed)
    walkSpeed = speed
    SetResourceKvp("AnythingAnimal_Speed", tostring(walkSpeed))
end)

exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
-- DEBUG: print(exports['AnythingAnimal']:getIsPlayerAnimal())