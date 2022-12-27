local animalHashList = {}
local isPlayerAnimal = false

for _, v in ipairs(AnimalPed) do
    table.insert(animalHashList, GetHashKey(v))
end

CreateThread(function()
    while true do
        Wait(0)
        local PlayerPedHash = GetEntityModel(PlayerPedId())
        for _, ListedPedHash in ipairs(animalHashList) do
            if ListedPedHash == PlayerPedHash then
                isPlayerAnimal = true
            end
        end
        isPlayerAnimal = false
    end
end)

exports('getIsPlayerAnimal', function() return isPlayerAnimal end)