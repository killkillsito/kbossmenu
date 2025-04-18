function loadPlayerInventory()
    local PlayerInventory = TriggerCallback('codem-bossmenu:serverGetPlayerInventory')
    local companyInventory = TriggerCallback('codem-bossmenu:serverGetCompanyInventory')
    if PlayerInventory then
        NuiMessage('PLAYER_INVENTORY', PlayerInventory)
        NuiMessage('COMPANY_INVENTORY', companyInventory)
    end
end

RegisterNUICallback('inventoryItemCheck', function(data, cb)
    local itemCheck = TriggerCallback('codem-bossmenu:serverInventoryItemCheck', data)
    cb(itemCheck)
end)

RegisterNUICallback('inventoryCompanyItemCheck', function(data, cb)
    local itemCheck = TriggerCallback('codem-bossmenu:serverInventoryCompanyItemCheck', data)
    cb(itemCheck)
end)
