inventoryData = {}
Citizen.CreateThread(function()

end)

Citizen.CreateThread(function()
    WaitCore()
    RegisterCallback('codem-bossmenu:serverGetPlayerInventory', function(source, cb)
        local src = source
        local data = GetPlayerInventory(src)
        cb(data)
    end)
    RegisterCallback('codem-bossmenu:serverGetCompanyInventory', function(source, cb)
        local src = source
        local job = GetJob(src)
        local result = ExecuteSql("SELECT `inventory`  FROM `mboss_inventory` WHERE `jobname` = '" .. job .. "'")
        if result[1] then
            cb(json.decode(result[1].inventory))
        else
            cb({})
        end
    end)
    RegisterCallback('codem-bossmenu:serverInventoryItemCheck', function(source, cb, data)
        local src = source
        local PlayerInventory = GetPlayerInventory(src)
        local found = false
        local name = GetPlayerRPName(src)
        local identifier = GetIdentifier(src)
        local job = GetJob(src)
        local company = GetCompanyByName(job)
        if company and company.inventoryDisabled == 1 then
            TriggerClientEvent("mBossmenu:sendNotification", src, locales.inventory_disabled)

            return 
        end
        for k, v in pairs(PlayerInventory) do
            if v.name == data.itemname then
                if tonumber(v.amount) >= tonumber(data.itemamount) then
                    found = false
                    RemoveItem(src, data.itemname, data.itemamount)
                    CreateLog(job, string.format(locales.log_1, name, data.itemamount, data.label), "activity",
                        GetIdentifier(src))
                    savePlayerCompanyInventory(src, data)
                    local discordLogData = {
                        name = GetPlayerRPName(src),
                        id = src,
                        job = job,
                        identifier = GetIdentifier(src),
                        itemname = data.itemname,
                        itemamount = data.itemamount,
                        type = "removeitem"
                    }
                    cb(true)
                    return;
                end
            end
        end
        if not found then
            cb(false)
        end
    end)

    RegisterCallback('codem-bossmenu:serverInventoryCompanyItemCheck', function(source, cb, data)
        local src = source
        local job = GetJob(src)
        local result = ExecuteSql("SELECT `inventory` FROM `mboss_inventory` WHERE `jobname` = '" .. job .. "'")
        local name = GetPlayerRPName(src)
        local identifier = GetIdentifier(src)
        local company = GetCompanyByName(job)
        if company and company.inventoryDisabled == 1 then
            TriggerClientEvent("mBossmenu:sendNotification", src, locales.inventory_disabled)
            return 
        end
        if result and result[1] then
            local inventory = json.decode(result[1].inventory)
            local found = false
            for k, v in pairs(inventory) do
                if v.name == data.itemname then
                    found = true
                    AddItem(src, data.itemname, data.itemamount, {}, data.metadata)
                    CreateLog(job, string.format(locales.log_2, name, data.itemamount, data.label), "activity",
                        GetIdentifier(src))
                    removeCompanyInventory(src, data.itemname, tonumber(data.itemamount))
                    local discordLogData = {
                        name = GetPlayerRPName(src),
                        id = src,
                        job = job,
                        identifier = GetIdentifier(src),
                        itemname = data.itemname,
                        itemamount = data.itemamount,
                        type = "additem"
                    }
                    cb(true)
                    return
                end
            end
            if not found then
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)


function removeCompanyInventory(src, item, amount)
    local job = GetJob(src)
    local result = ExecuteSql("SELECT `inventory` FROM `mboss_inventory` WHERE `jobname` = '" .. job .. "'")
    if result then
        local inventory = json.decode(result[1].inventory)
        for k, v in pairs(inventory) do
            if v.name == item then
                v.amount = v.amount - amount
                if v.amount <= 0 then
                    table.remove(inventory, k)
                end
                break
            end
        end
        ExecuteSql("UPDATE `mboss_inventory` SET `inventory` = '" ..
            json.encode(inventory) .. "' WHERE `jobname` = '" .. job .. "'")
    end
end

function savePlayerCompanyInventory(src, data)
    local job = GetJob(src)
    local result = ExecuteSql("SELECT `inventory` FROM `mboss_inventory` WHERE `jobname` = '" .. job .. "'")
    local inventory

    if result and result[1] then
        inventory = json.decode(result[1].inventory)
    else
        inventory = {}
    end

    local found = false
    for k, v in pairs(inventory) do
        if v.name == data.itemname and not data.metadata then
            v.amount = v.amount + data.itemamount
            found = true
            break
        end
    end

    if not found then
        table.insert(inventory, {
            name = data.itemname,
            amount = data.itemamount,
            label = data.label,
            metadata = data.metadata
        })
    end

    if result and result[1] then
        ExecuteSql("UPDATE `mboss_inventory` SET `inventory` = '" ..
            json.encode(inventory) .. "' WHERE `jobname` = '" .. job .. "'")
    else
        ExecuteSql("INSERT INTO `mboss_inventory` (`jobname`, `inventory`) VALUES ('" ..
            job .. "', '" .. json.encode(inventory) .. "')")
    end
end
