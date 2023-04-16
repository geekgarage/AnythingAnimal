RegisterNetEvent('AnythingAnimal:VerifyEmoteSpeed', function(speed, isAnimal, speedType)
    if not isAnimal then return end

    if speedType == "walk" then
        speed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
    elseif speedType == "jog" then
        speed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
    elseif speedType == "sprint" then
        speed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
    elseif speedType == "swim" then
        speed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
    end
    
    TriggerClientEvent('AnythingAnimal:UpdMovementSpeed', source, speed, speedType)
end)

/*
RegisterNetEvent('JumpPED', function(isAnimal, jumpCoords)
    if isAnimal then
        if jumpCoords then
            --local ped = GetPlayerPed(source)
            SetEntityCoords(source, jumpCoords.x, jumpCoords.y, jumpCoords.z, false, false, false, false)
        else
            TriggerClientEvent('GetOffsetInWorld', source)
        end
    end
end)
*/

RegisterNetEvent('AnythingAnimal:syncPlayerMovement', function(speedType, speedValue, isAnimal)
    if isAnimal then
        TriggerClientEvent('AnythingAnimal:syncPlayerMovement', -1, source, speedType, speedValue)
    end
end)
