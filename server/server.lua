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
    end
    print("Calling client!")
    TriggerClientEvent('UpdMovementSpeed', source, speed, adjDir, typeAdj, true)
end)