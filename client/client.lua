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
        SetRunSprintMultiplierForPlayer(player, 1.49) -- Make animals faster
        SetPedConfigFlag(ped, 184, true) -- Avoid drivers seat
        SetPedDiesInWater(ped, false) -- Disable animal dies in water instantly

        if IsEntityInWater(ped) == 1 then -- Disable ragdoll of animals in water
            SetPedCanRagdoll(ped, false)
        else
            SetPedCanRagdoll(ped, true)
        end
    end
end)