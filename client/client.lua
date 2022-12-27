local animalHashList = {}
local isPlayerAnimal = false

for _, v in ipairs(AnimalPed) do
    table.insert(animalHashList, GetHashKey(v))
end

CreateThread(function()
    while true do
        Wait(1000)

        -- General vars
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

        -- Land and Water fixes
        RestorePlayerStamina(player, 1.4) -- Reset stamina (crude fix but works)
        SetPedDiesInWater(ped, false) -- Disable animal dies in water instantly
        if IsEntityInWater(ped) == 1 then -- If In Water
            SetPedCanRagdoll(ped, false) -- Disable ragdoll of animals in water
            SetRunSprintMultiplierForPlayer(player, 1.0) -- Make animals normal speed in water
        else
            SetPedCanRagdoll(ped, true) -- Enable ragdoll again
            SetRunSprintMultiplierForPlayer(player, 1.49) -- Make animals faster on land
        end

        -- Health Fixes
        local pedMaxHealth = GetEntityMaxHealth(ped)
        local pedCurrentHealth = GetEntityHealth(ped)
        SetMaxHealthHudDisplay(pedMaxHealth)
        
        print(pedCurrentHealth)
        
        if pedCurrentHealth < pedMaxHealth then
            local tempHealth = pedCurrentHealth + 2
            if tempHealth > pedMaxHealth then
                tempHealth = pedMaxHealth
            end
            SetEntityHealth(ped, tempHealth)
            SetHealthHudDisplayValues(tempHealth, pedMaxHealth, true)
        end
    end
end)


exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
-- DEBUG: print(exports['AnythingAnimal']:getIsPlayerAnimal())