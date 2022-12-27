local animalHashList = {}
local isPlayerAnimal = false

for _, v in ipairs(AnimalPed) do
    table.insert(animalHashList, GetHashKey(v))
end

CreateThread(function()
    while true do
        Wait(0)
        local PlayerPedHash = GetEntityModel(PlayerPedId())
        local tempAnimalStatus = false
        for _, ListedPedHash in ipairs(animalHashList) do
            if ListedPedHash == PlayerPedHash then
                tempAnimalStatus = true
                break
            else
                tempAnimalStatus = false
            end
        end
        isPlayerAnimal = tempAnimalStatus
        print(isPlayerAnimal)
    end
end)

exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
-- DEBUG: print(exports['AnythingAnimal']:getIsPlayerAnimal())