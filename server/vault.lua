jobMoneyLog = {}
Citizen.CreateThread(function()
    local result = ExecuteSql("SELECT * FROM `mboss_vault_logs`")
    for i = 1, #result do
        local companyData = result[i]
        local dataInfo = {
            companyName = companyData.company,
            message = json.decode(companyData.message)
        }
        if not jobMoneyLog[companyData.company] then
            jobMoneyLog[companyData.company] = dataInfo
        end
        jobMoneyLog[companyData.company] = dataInfo
    end
end)


Citizen.CreateThread(function()
    WaitCore()
    RegisterCallback('codem-bossmenu:server:getPlayerMoneyandCompanyMoney', function(source, cb)
        local src = source
        local money = GetPlayerMoney(src, 'bank')
        local job = GetJob(src)
        local companyMoney = GetSocietyMoney(job) or 0
        local dataInfo = {
            money = money,
            companyMoney = companyMoney,
        }
        local moneyLog = jobMoneyLog[job] and (jobMoneyLog[job].message  or {}) or {}
        TriggerClientEvent('codem-bossmenu:firstUpdateMoneyLog', src, moneyLog)
        cb(dataInfo)
    end)
end)


RegisterServerEvent('codem-bossmenu:server:depositMoney', function(data)
    local src = source
    local job = GetJob(src)
    local money = GetPlayerMoney(src, 'bank')
    local amount = tonumber(data.amount)
    if amount > money then
        -- TriggerClientEvent('codem-bossmenu:client:notify', src, 'You dont have enough money')
        return
    end
    local company = GetCompanyByName(job)
    if company and company.vaultDisabled == 1 then
        TriggerClientEvent("mBossmenu:sendNotification", src, "Baúl deshabilitado.")
        return 
    end
    if amount > 0 then
        RemoveMoney(src, 'bank', amount)
        AddSocietyMoney(job, amount)
        local newMoney = GetPlayerMoney(src, 'bank')
        local newcompanyMoney = GetSocietyMoney(job) or 0
        local dataInfo = {
            money = newMoney,
            companyMoney = newcompanyMoney
        }
        TriggerClientEvent('codem-bossmenu:client:updateMoneyData', src, dataInfo)
        local moneyLog = {

            from =GetPlayerRPName(src),
            to =  GetCompanyByName(job).companylabel,
            identifier = GetIdentifier(src),
            date = os.date('%Y.%m.%d %H:%M'),
            amount = amount,
            type = '+',
            avatar = GetDiscordAvatar(src)

        }
        addMoneyLog(src, moneyLog)
    
        company.vault_income = company.vault_income + amount
        ExecuteSql("UPDATE mboss_general SET `vault_income` = '" ..
        company.vault_income .. "' WHERE `company` = '" .. company.company .. "'")
        SyncCompanyByKey(company.company, "vault_income")

    end
end)


RegisterServerEvent('codem-bossmenu:server:withdrawMoney', function(data)
    local src = source
    local job = GetJob(src)
    local money = GetPlayerMoney(src, 'bank')
    local amount = tonumber(data.amount)
    local companyMoney = GetSocietyMoney(job) or 0
    if amount > companyMoney then
        -- TriggerClientEvent('codem-bossmenu:client:notify', src, 'You dont have enough money')
        return
    end
    local company = GetCompanyByName(job)
    if company and company.vaultDisabled == 1 then
        TriggerClientEvent("mBossmenu:sendNotification", src, "Baúl deshabilitado.")
        return 
    end
    if amount > 0 then
        RemoveSocietyMoney(job, amount)
        AddMoney(src, 'bank', amount)
        local newMoney = GetPlayerMoney(src, 'bank')
        local newcompanyMoney = GetSocietyMoney(job) or 0
        local dataInfo = {
            money = newMoney,
            companyMoney = newcompanyMoney
        }
        TriggerClientEvent('codem-bossmenu:client:updateMoneyData', src, dataInfo)
        local moneyLog = {

            from = GetCompanyByName(job).companylabel,
            to = GetPlayerRPName(src),
            identifier = GetIdentifier(src),
            date = os.date('%Y.%m.%d %H:%M'),
            amount = amount,
            type = '-',
            avatar = GetDiscordAvatar(src)
        }
        addMoneyLog(src, moneyLog)

    
        company.vault_expense = company.vault_expense + amount
        ExecuteSql("UPDATE mboss_general SET `vault_expense` = '" ..
        company.vault_expense .. "' WHERE `company` = '" .. company.company .. "'")
        SyncCompanyByKey(company.company, "vault_expense")
    end
end)

function addMoneyLog(src, data)
    local job = GetJob(src)
    if job then
        local insertData = jobMoneyLog[job]
        if not insertData then
            insertData = {
                companyName = job,
                message = {}
            }
        end
        table.insert(insertData.message, data)
        jobMoneyLog[job] = insertData
        saveJobData(insertData)
        TriggerClientEvent('codem-bossmenu:updateMoneyLogData', src, data)
    end
end

function saveJobData(data)
    local data = jobMoneyLog[data.companyName]
    if data then
        local message = json.encode(data.message)
        local result = ExecuteSql("SELECT * FROM `mboss_vault_logs` WHERE `company` = '" .. data.companyName .. "'")
        if result[1] then
            ExecuteSql("UPDATE `mboss_vault_logs` SET `message` = '" ..
                message .. "' WHERE `company` = '" .. data.companyName .. "'")
        else
            ExecuteSql("INSERT INTO `mboss_vault_logs` (`company`, `message`) VALUES ('" .. data.companyName .. "', '" ..
                message .. "')")
        end
    end
end
