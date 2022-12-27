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

        -- Check if player is animal vars
        local PlayerPedHash = GetEntityModel(ped)
        local tempAnimalStatus = false

        -- Health Fixes vars
        SetEntityMaxHealth(ped, 500)
        local pedMaxHealth = GetEntityMaxHealth(ped)
        local pedCurrentHealth = GetEntityHealth(ped)

        -- Check if player is animal
        for _, ListedPedHash in ipairs(animalHashList) do
            if ListedPedHash == PlayerPedHash then
                tempAnimalStatus = true
                break
            end
        end
        isPlayerAnimal = tempAnimalStatus

        -- Land and Water fixes
        RestorePlayerStamina(player, 1.5) -- Reset stamina
        SetPedDiesInWater(ped, false) -- Disable animal dies in water instantly
        if IsEntityInWater(ped) == 1 then -- If In Water
            SetPedCanRagdoll(ped, false) -- Disable ragdoll of animals in water
            SetRunSprintMultiplierForPlayer(player, 1.01) -- Make animals normal speed in water
        else
            SetPedCanRagdoll(ped, true) -- Enable ragdoll again
            SetRunSprintMultiplierForPlayer(player, 1.49) -- Make animals faster on land
        end


        -- Health Fixes
        if pedCurrentHealth < pedMaxHealth then
            local tempHealth = pedCurrentHealth + 10
            if tempHealth > pedMaxHealth then
                SetEntityHealth(ped, pedMaxHealth)
            else
                SetEntityHealth(ped, tempHealth)
            end
        end
    end
end)


exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
-- DEBUG: print(exports['AnythingAnimal']:getIsPlayerAnimal())