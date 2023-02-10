RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal, typeAdj)
    if not isAnimal then return end
    local adjDir = "Both"

    if typeAdj == "walk" then
        if speed > Config.WalkSpeedMax then
            speed = Config.WalkSpeedMax
            adjDir = "NotMax"
        elseif speed < 0 then
            speed = 0
            adjDir = "NotMin"
        elseif speed < Config.WalkSpeedMin then
            speed = Config.WalkSpeedMin
            adjDir = "NotMin"
        end
    elseif typeAdj == "inrun" then
        if speed > Config.InsideRunSpeedMax then
            speed = Config.InsideRunSpeedMax
            adjDir = "NotMax"
        elseif speed < 0 then
            speed = 0
            adjDir = "NotMin"
        elseif speed < Config.InsideRunSpeedMin then
            speed = Config.InsideRunSpeedMin
            adjDir = "NotMin"
        end
    elseif typeAdj == "outrun" then
        if speed > Config.OutsideRunSpeedMax then
            speed = Config.OutsideRunSpeedMax
            adjDir = "NotMax"
        elseif speed < 0 then
            speed = 0
            adjDir = "NotMin"
        elseif speed < Config.OutsideRunSpeedMin then
            speed = Config.OutsideRunSpeedMin
            adjDir = "NotMin"
        end
    elseif typeAdj == "swim" then
        if speed > Config.SwimSpeedMax then
            speed = Config.SwimSpeedMax
            adjDir = "NotMax"
        elseif speed < 0 then
            speed = 0
            adjDir = "NotMin"
        elseif speed < Config.SwimSpeedMin then
            speed = Config.SwimSpeedMin
            adjDir = "NotMin"
        end
    end
    
    TriggerClientEvent('UpdMovementSpeed', source, speed, adjDir, typeAdj, true)
end)


RegisterNetEvent('JumpPED', function(isAnimal, offsetPEDCoords)
    if isAnimal then
        local ped = GetPlayerPed(source)    
        local pedCurrentCoords = GetEntityCoords(ped)
        if offsetPEDCoords and ((offsetPEDCoords.y - pedCurrentCoords.y) == Config.JumpDistance) and ((offsetPEDCoords.z - pedCurrentCoords.z) == Config.JumpHeight) then
            print("O: " .. offsetPEDCoords)
            SetEntityCoords(source, offsetPEDCoords.x, offsetPEDCoords.y, offsetPEDCoords.z, false, false, false, false)
        else
            TriggerClientEvent('GetOffsetInWorld')
            print("C: " .. pedCurrentCoords)
        end
    end
end)