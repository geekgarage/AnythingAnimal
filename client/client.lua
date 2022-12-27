local animalHashList = {}
local isPlayerAnimal = false
local pedMaxHealth = 200
local pedAnimPlaying = false

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

            if IsEntityInWater(ped) == 1 then -- If In Water
                SetPedCanRagdoll(ped, false) -- Disable ragdoll of animals in water
                SetRunSprintMultiplierForPlayer(player, Config.SpeedMultiplierWater) -- Make animals normal speed in water
                ResetPlayerStamina(player, 0.0) -- remove stamina to avoid super swim when sprint as turning radius with full body swim animation is non-existing
                if not pedAnimPlaying then
                    dogSwimAnim()
                    pedAnimPlaying = true
                end
            else
                SetPedCanRagdoll(ped, true) -- Enable ragdoll again
                SetRunSprintMultiplierForPlayer(player, Config.SpeedMultiplierLand) -- Make animals faster on land
                ResetPlayerStamina(player)
                if pedAnimPlaying then
                    ClearPedTasks(ped)
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



exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
-- DEBUG: print(exports['AnythingAnimal']:getIsPlayerAnimal())