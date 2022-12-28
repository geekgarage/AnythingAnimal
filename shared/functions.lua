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

function unloadAnimDict(dict)
    if HasAnimDictLoaded(dict) then 
        RemoveAnimDict(dict)
    end
    while HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

function dogSwimAnim()
    loadAnimDict('creatures@rottweiler@swim@')
    TaskPlayAnim(PlayerPedId(), "creatures@rottweiler@swim@", "swim", 8.0, 8.0, -1, 49, 0, false, false, false)
end

function dogRunAnim()
    loadAnimDict('creatures@rottweiler@move')
    TaskPlayAnim(PlayerPedId(), "creatures@rottweiler@move", "gallop", 8.0, 8.0, -1, 47, 0, false, false, false)
end

function dogWalkAnim()
    unloadAnimDict('creatures@rottweiler@move')
end