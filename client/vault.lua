function loadPlayerVault()
    local playerMoney = TriggerCallback('codem-bossmenu:server:getPlayerMoneyandCompanyMoney')
    if playerMoney then
        NuiMessage('PLAYER_MONEY_AND_COMPANY_MONEY', playerMoney)
    end
end

RegisterNUICallback('depositMoney', function(data, cb)
    TriggerServerEvent('codem-bossmenu:server:depositMoney', data)
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    TriggerServerEvent('codem-bossmenu:server:withdrawMoney', data)
end)

RegisterNetEvent('codem-bossmenu:client:updateMoneyData', function(data)
    NuiMessage('PLAYER_MONEY_AND_COMPANY_MONEY', data)
end)

RegisterNetEvent('codem-bossmenu:updateMoneyLogData', function(data)
    NuiMessage('UPDATE_COMPANY_MONEY_LOG', data)
end)

RegisterNetEvent('codem-bossmenu:firstUpdateMoneyLog', function(data)
    NuiMessage('FIRST_UPDATE_COMPANY_MONEY_LOG', data)
end)
