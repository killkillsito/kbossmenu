function ExecuteSql(query, parameters)
    local IsBusy = true
    local result = nil
    if Config.SQL == "oxmysql" then
        if parameters then
            exports.oxmysql:execute(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            exports.oxmysql:execute(query, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.SQL == "ghmattimysql" then
        if parameters then
            exports.ghmattimysql:execute(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            exports.ghmattimysql:execute(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.SQL == "mysql-async" then
        if parameters then
            MySQL.Async.fetchAll(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            MySQL.Async.fetchAll(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end

function GetPlayerRPName(source)
    if Config.Framework == "oldesx" or Config.Framework == "esx" then
        local xPlayer = Core.GetPlayerFromId(tonumber(source))
        if xPlayer then
            return xPlayer.getName()
        end
    elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        local Player = Core.Functions.GetPlayer(tonumber(source))
        if Player then
            return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        end
    end
    return GetPlayerName(source)
end

function GetPlayerInventory(source)
    local data = {}
    local Player = GetPlayer(source)
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        for _, v in pairs(Player.getInventory()) do
            if v and tonumber(v.count) > 0 and not CheckBlacklistItem(v.name) then
                local formattedData = v
                formattedData.name = string.lower(v.name)
                formattedData.label = v.label
                formattedData.amount = v.count
                formattedData.image = v.image or (string.lower(v.name) .. '.png')

                local metadata = v.metadata or v.info

                if not metadata or next(metadata) == nil then
                    metadata = false
                end
                formattedData.metadata = metadata

                table.insert(data, formattedData)
            end
        end
    else
        for _, v in pairs(Player.PlayerData.items) do
            if v then
                local amount = v.count or v.amount
                if tonumber(amount) > 0 and not CheckBlacklistItem(v.name) then
                    local formattedData = v
                    formattedData.name = string.lower(v.name)
                    formattedData.label = v.label
                    formattedData.amount = amount
                    formattedData.image = v.image or (string.lower(v.name) .. '.png')
                    local metadata = v.metadata or v.info

                    if not metadata or next(metadata) == nil then
                        metadata = false
                    end
                    formattedData.metadata = metadata
                    table.insert(data, formattedData)
                end
            end
        end
    end
    return data
end

function RemoveItem(src, item, amount)
    local Player = GetPlayer(src)
    if Player then
        if Config.Inventory == "qb_inventory" then
            Player.Functions.RemoveItem(item, amount)
        elseif Config.Inventory == "esx_inventory" then
            Player.removeInventoryItem(item, amount)
        elseif Config.Inventory == "ox_inventory" then
            exports.ox_inventory:RemoveItem(src, item, amount)
        elseif Config.Inventory == "codem-inventory" then
            exports["codem-inventory"]:RemoveItem(src, item, amount)
        elseif Config.Inventory == "qs_inventory" then
            exports['qs-inventory']:RemoveItem(src, item, amount)
        end
    end
end

function AddItem(src, item, amount, slot, info)
    local Player = GetPlayer(src)
    if Player then
        if Config.Inventory == "qb_inventory" then
            Player.Functions.AddItem(item, amount)
        elseif Config.Inventory == "esx_inventory" then
            Player.addInventoryItem(item, amount)
        elseif Config.Inventory == "ox_inventory" then
            exports.ox_inventory:AddItem(src, item, amount)
        elseif Config.Inventory == "codem-inventory" then
            exports["codem-inventory"]:AddItem(src, item, amount, nil, info)
        elseif Config.Inventory == "qs_inventory" then
            exports['qs-inventory']:AddItem(src, item, amount)
        end
    end
end

function CheckBlacklistItem(item)
    for _, v in pairs(Config.BlacklistedItems) do
        if v == item then
            return true
        end
    end
    return false
end

function WaitCore()
    while not Core do
        Wait(0)
    end
end

function RegisterCallback(name, cbFunc)
    WaitCore()
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        Core.RegisterServerCallback(name, function(source, cb, data)
            cbFunc(source, cb, data)
        end)
    else
        Core.Functions.CreateCallback(name, function(source, cb, data)
            cbFunc(source, cb, data)
        end)
    end
end

local Avatars = {}

local FormattedToken = "Bot " .. botToken
function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/" .. endpoint, function(errorCode, resultData, resultHeaders)
            data = { data = resultData, code = errorCode, headers = resultHeaders }
        end, method, #jsondata > 0 and json.encode(jsondata) or "",
        { ["Content-Type"] = "application/json", ["Authorization"] = FormattedToken })

    while data == nil do
        Citizen.Wait(0)
    end

    return data
end

function GetIdentifier(source)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            return Player.getIdentifier()
        else
            return Player.PlayerData.citizenid
        end
    end
end

function RemoveSocietyMoney(job, givenAmount)
    if Config.Framework == "esx" or Config.Framework == "oldesx" then
        if job then
            local accountName = 'society_' .. job
            local societyAccountMoney = ExecuteSql("SELECT * FROM `addon_account_data` WHERE `account_name` = '" ..
                accountName .. "'")
            if societyAccountMoney and societyAccountMoney[1] then
                local currentAmount = societyAccountMoney[1].money
                local newAmount = currentAmount - givenAmount
                if newAmount < 0 then
                    print('NO HAY SUFICIENTE DINERO EN EL NEGOCIO')
                    return false
                else
                    ExecuteSql("UPDATE `addon_account_data` SET `money` = ? WHERE `account_name` = ?",
                        { newAmount, accountName })
                    return newAmount
                end
            else
                return false
            end
        end
    elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        if job then
            local accountName = job
            local societyAccountMoney = ExecuteSql("SELECT * FROM `management_funds` WHERE `job_name` = '" ..
                accountName .. "'")
            if societyAccountMoney and societyAccountMoney[1] then
                local currentAmount = societyAccountMoney[1].amount
                local newAmount = currentAmount - givenAmount
                if newAmount < 0 then
                    print('NO HAY SUFICIENTE DINERO EN EL NEGOCIO')
                    return false
                else
                    ExecuteSql("UPDATE `management_funds` SET `amount` = ? WHERE `job_name` = ?",
                        { newAmount, accountName })
                    return newAmount
                end
            else
                return false
            end
        end
    end
end

function GetPlayerMoney(source, value)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            if value == 'bank' then
                return Player.getAccount('bank').money
            end
            if value == 'cash' then
                return Player.getMoney()
            end
        elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if value == 'bank' then
                return Player.PlayerData.money['bank']
            end
            if value == 'cash' then
                return Player.PlayerData.money['cash']
            end
        end
    end
end

function RemoveMoney(source, type, value)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            if type == 'bank' then
                Player.removeAccountMoney('bank', value)
            end
            if type == 'cash' then
                Player.removeMoney(value)
            end
        elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if type == 'bank' then
                Player.Functions.RemoveMoney('bank', value)
            end
            if type == 'cash' then
                Player.Functions.RemoveMoney('cash', value)
            end
        end
    end
end

function AddMoney(source, type, value)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            if type == 'bank' then
                Player.addAccountMoney('bank', value)
            end
            if type == 'cash' then
                Player.addMoney(value)
            end
        elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if type == 'bank' then
                Player.Functions.AddMoney('bank', value)
            end
            if type == 'cash' then
                Player.Functions.AddMoney('cash', value)
            end
        end
    end
end

function GetSocietyMoney(job)
    if Config.Framework == "esx" or Config.Framework == "oldesx" then
        if job then
            local accountName = 'society_' .. job
            local societyAccountMoney = ExecuteSql("SELECT * FROM `addon_account_data` WHERE `account_name` = '" ..
                accountName .. "'")
            if next(societyAccountMoney) then
                return societyAccountMoney[1].money
            else
                return false
            end
        end
    elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        if job then
            local accountName = job
            local societyAccountMoney = ExecuteSql("SELECT * FROM `management_funds` WHERE `job_name` = '" ..
                accountName .. "'")
            if next(societyAccountMoney) then
                return societyAccountMoney[1].amount
            else
                return false
            end
        end
    end
end

function AddSocietyMoney(job, givenAmount)
    if Config.Framework == "esx" or Config.Framework == "oldesx" then
        if job then
            local accountName = 'society_' .. job
            local societyAccountMoney = ExecuteSql("SELECT * FROM `addon_account_data` WHERE `account_name` = '" ..
                accountName .. "'")
            if societyAccountMoney and societyAccountMoney[1] then
                local currentAmount = societyAccountMoney[1].money
                local newAmount = currentAmount + givenAmount
                if newAmount < 0 then
                    print('NO HAY SUFICIENTE DINERO EN EL NEGOCIO')
                    return false
                else
                    ExecuteSql("UPDATE `addon_account_data` SET `money` = ? WHERE `account_name` = ?",
                        { newAmount, accountName })
                    return newAmount
                end
            else
                return false
            end
        end
    elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        if job then
            local accountName = job
            local societyAccountMoney = ExecuteSql("SELECT * FROM `management_funds` WHERE `job_name` = '" ..
                accountName .. "'")
            if societyAccountMoney and societyAccountMoney[1] then
                local currentAmount = societyAccountMoney[1].amount
                local newAmount = currentAmount + givenAmount
                if newAmount < 0 then
                    print('NO HAY SUFICIENTE DINERO EN EL NEGOCIO')
                    return false
                else
                    ExecuteSql("UPDATE `management_funds` SET `amount` = ? WHERE `job_name` = ?",
                        { newAmount, accountName })
                    return newAmount
                end
            else
                print('ERROR NEGOCIO NO ENCONTRADO')
                return false
            end
        end
    end
end

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

function GetDiscordAvatar(user)
    local discordId = nil
    local imgURL = nil;
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end
    if discordId then
        if Avatars[discordId] == nil then
            local endpoint = ("users/%s"):format(discordId)
            local member = DiscordRequest("GET", endpoint, {})

            if member.code == 200 then
                local data = json.decode(member.data)
                if data ~= nil and data.avatar ~= nil then
                    if (data.avatar:sub(1, 1) and data.avatar:sub(2, 2) == "_") then
                        imgURL = "https://media.discordapp.net/avatars/" .. discordId .. "/" .. data.avatar .. ".gif";
                    else
                        imgURL = "https://media.discordapp.net/avatars/" .. discordId .. "/" .. data.avatar .. ".png"
                    end
                end
            else
                return Config.DefaultImage 
            end
            Avatars[discordId] = imgURL;
        else
            imgURL = Avatars[discordId];
        end   
    end
    if imgURL == nil or imgURL == false then
        imgURL = Config.DefaultImage 
    end
    return imgURL;
end



function CheckIsAdmin(source)
    if source == 0 then
        return false
    end
    if Config.Framework == 'esx' or Config.Framework == 'oldesx'  then
        local Player = Core.GetPlayerFromId(source)
        if Player then
            for _,v in pairs(Config.Admins) do
                if Player.getGroup() == v then
                    return true
                end
            end
        end
    elseif Config.Framework == 'qb' then
        for _, v in pairs(Config.Admins) do
            if Core.Functions.HasPermission(source, v) or IsPlayerAceAllowed(source, 'command') then
                return true
            end
        end
    elseif Config.Framework == 'oldqb' then
        for _,v in pairs(Config.Admins) do
            if Core.Functions.GetPermission(source) == v then                
                return true 
            end
        end
    end
    return false
end

function GetSteamPP(source)
    local idf =  nil
    for k,v in pairs(GetPlayerIdentifiers(source))do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            idf = v
        end
    end
    local avatar = "./assets/images/testpp.png"
    if idf == nil then
        return avatar
    end
    local callback = promise:new()
    PerformHttpRequest('http://steamcommunity.com/profiles/' .. tonumber(GetIDFromSource('steam', idf), 16) .. '/?xml=1', function(Error, Content, Head)
        local SteamProfileSplitted = stringsplit(Content, '\n')
        if SteamProfileSplitted ~= nil and next(SteamProfileSplitted) ~= nil then
            for i, Line in ipairs(SteamProfileSplitted) do
                if Line:find('<avatarFull>') then
                    callback:resolve(Line:gsub('<avatarFull><!%[CDATA%[', ''):gsub(']]></avatarFull>', ''))
                    for k,v in pairs(callback) do
                        return callback.value
                    end
                    break
                end
            end
        end
    end)
    return Citizen.Await(callback)
end