function listToNil(inputList)
    for k, v in ipairs(inputList) do
        inputList[k] = nil
    end
end

function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

function dogSwimAnim(flag)
    loadAnimDict('creatures@rottweiler@swim@')
    TaskPlayAnim(PlayerPedId(), "creatures@rottweiler@swim@", "swim", 8.0, 8.0, -1, flag, 0, false, false, false)
end

