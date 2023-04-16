RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal)
    if not isAnimal then return end
    local adjDir = "Both"

    if typeAdj == "walk" then
        speed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
    elseif typeAdj == "jog" then
        speed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
    elseif typeAdj == "sprint" then
        speed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
    elseif typeAdj == "swim" then
        speed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
    end
    
    TriggerClientEvent('UpdMovementSpeed', source, speed, true)
end)


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

RegisterNetEvent('syncPlayerMovement', function(speedType, speedValue)
    TriggerClientEvent('syncPlayerMovement', -1, source, speedType, speedValue)
end)
