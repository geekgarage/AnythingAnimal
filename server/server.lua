RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal)
    if not isAnimal then return end
    local stopReq = false

    if speed > Config.WalkSpeedMax then
        speed = Config.WalkSpeedMax
        local stopReq = "StopMax"
    elseif speed < 0 then
        speed = 0
        local stopReq = "StopMin"
    elseif speed < Config.WalkSpeedMin then
        speed = Config.WalkSpeedMin
        local stopReq = "StopMin"
    end

    TriggerClientEvent('UpdWalkSpeed', source, speed, stopReq)
end)