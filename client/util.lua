function WaitCore()
    while Core == nil do
        Wait(0)
    end
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end


function TriggerCallback(name, data)
    local incomingData = false
    local status = 'UNKOWN'
    local counter = 0
    WaitCore()
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        Core.TriggerServerCallback(name, function(payload)
            status = 'SUCCESS'
            incomingData = payload
        end, data)
    else
        Core.Functions.TriggerCallback(name, function(payload)
            status = 'SUCCESS'
            incomingData = payload
        end, data)
    end
    CreateThread(function()
        while incomingData == 'UNKOWN' do
            Wait(1000)
            if counter == 4 then
                status = 'FAILED'
                incomingData = false
                break
            end
            counter = counter + 1
        end
    end)

    while status == 'UNKOWN' do
        Wait(0)
    end
    return incomingData
end

function WaitPlayer()
    if Config.Framework == "esx" or Config.Framework == 'oldesx' then
        WaitCore()
        while Core.GetPlayerData() == nil do
            Wait(0)
        end
        while Core.GetPlayerData().job == nil do
            Wait(0)
        end
    else
        WaitCore()
        while Core.Functions.GetPlayerData() == nil do
            Wait(0)
        end
        while Core.Functions.GetPlayerData().metadata == nil do
            Wait(0)
        end
    end
end

function WaitNui()
    while not nuiLoaded do
        Wait(0)
    end
end