local animalHashList = {}
local isPlayerAnimal = false

for _, v in ipairs(AnimalPed) do
    table.insert(animalHashList, GetHashKey(v))
end

CreateThread(function()
    while true do
        Wait(1000)
        local PlayerPedHash = GetEntityModel(PlayerPedId())
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

exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
-- DEBUG: print(exports['AnythingAnimal']:getIsPlayerAnimal())


CreateThread(function()
    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local player = PlayerId()

        RestorePlayerStamina(player, 1.0) -- Reset stamina
        SetPedDiesInWater(ped, false) -- Disable animal dies in water instantly

        if IsEntityInWater(ped) == 1 then -- If In Water
            SetPedCanRagdoll(ped, false) -- Disable ragdoll of animals in water
            SetRunSprintMultiplierForPlayer(player, 0.85) -- Make animals slower in water
        else
            SetPedCanRagdoll(ped, true) -- Enable ragdoll again
            SetRunSprintMultiplierForPlayer(player, 1.49) -- Make animals faster on land
        end
    end
end)

--[[ CreateThread(function()
    while true do
        Wait(100)

        local ped = PlayerPedId()
        local player = PlayerId()

        local maxHealth = GetPedMaxHealth(ped)


    end
end) ]]