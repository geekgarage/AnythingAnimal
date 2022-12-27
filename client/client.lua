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

--Freeze stamina and make animal faster
CreateThread(function()
    while true do
        Wait(100)
        RestorePlayerStamina(PlayerId(), 1.0)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
        --SetPlayerInvincible(PlayerId(), true)
        SetPedConfigFlag(PlayerPedId(), 184, true)
        SetPedDiesInWater(PlayerPedId(), false)
        --SetPedDiesInstantlyInWater(PlayerPedId(), false)
    end
end)



--WaterFix
--SetPlayerInvincible(PlayerId(), true)