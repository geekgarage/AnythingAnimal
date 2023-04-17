RegisterNetEvent('AnythingAnimal:VerifyEmoteSpeed', function(newSpeed, isAnimal, speedType)
    if not isAnimal then return end

    if speedType == "walk" then
        newSpeed = math.min(math.max(newSpeed, Config.WalkSpeedMin), Config.WalkSpeedMax)
    elseif speedType == "jog" then
        newSpeed = math.min(math.max(newSpeed, Config.JogSpeedMin), Config.JogSpeedMax)
    elseif speedType == "sprint" then
        newSpeed = math.min(math.max(newSpeed, Config.SprintSpeedMin), Config.SprintSpeedMax)
    elseif speedType == "swim" then
        newSpeed = math.min(math.max(newSpeed, Config.SwimSpeedMin), Config.SwimSpeedMax)
    end
    
    TriggerClientEvent('AnythingAnimal:UpdMovementSpeed', source, newSpeed, speedType)
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

RegisterNetEvent('AnythingAnimal:syncPlayerMovement', function(speedType, speedValue, isSourceAnimal)
    if isSourceAnimal then
        TriggerClientEvent('AnythingAnimal:syncPlayerMovement', -1, source, speedType, speedValue)
    end
end)