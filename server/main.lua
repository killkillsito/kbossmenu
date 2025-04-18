--$$$$$$$\  $$\      $$\       $$$$$$$$\ $$\   $$\  $$$$$$\  $$\      $$\   $$\  $$$$$$\  $$$$$$\ $$\    $$\ $$$$$$$$\      $$$$$$\   $$$$$$\  $$$$$$$\  $$$$$$\ $$$$$$$\ $$$$$$$$\  $$$$$$\  
--$$  ____| $$$\    $$$ |      $$  _____|$$ |  $$ |$$  __$$\ $$ |     $$ |  $$ |$$  __$$\ \_$$  _|$$ |   $$ |$$  _____|    $$  __$$\ $$  __$$\ $$  __$$\ \_$$  _|$$  __$$\\__$$  __|$$  __$$\ 
--$$ |      $$$$\  $$$$ |      $$ |      \$$\ $$  |$$ /  \__|$$ |     $$ |  $$ |$$ /  \__|  $$ |  $$ |   $$ |$$ |          $$ /  \__|$$ /  \__|$$ |  $$ |  $$ |  $$ |  $$ |  $$ |   $$ /  \__|
--$$$$$$$\  $$\$$\$$ $$ |      $$$$$\     \$$$$  / $$ |      $$ |     $$ |  $$ |\$$$$$$\    $$ |  \$$\  $$  |$$$$$\ $$$$$$\\$$$$$$\  $$ |      $$$$$$$  |  $$ |  $$$$$$$  |  $$ |   \$$$$$$\  
--\_____$$\ $$ \$$$  $$ |      $$  __|    $$  $$<  $$ |      $$ |     $$ |  $$ | \____$$\   $$ |   \$$\$$  / $$  __|\______|\____$$\ $$ |      $$  __$$<   $$ |  $$  ____/   $$ |    \____$$\ 
--$$\   $$ |$$ |\$  /$$ |      $$ |      $$  /\$$\ $$ |  $$\ $$ |     $$ |  $$ |$$\   $$ |  $$ |    \$$$  /  $$ |          $$\   $$ |$$ |  $$\ $$ |  $$ |  $$ |  $$ |        $$ |   $$\   $$ |
--\$$$$$$  |$$ | \_/ $$ |      $$$$$$$$\ $$ /  $$ |\$$$$$$  |$$$$$$$$\\$$$$$$  |\$$$$$$  |$$$$$$\    \$  /   $$$$$$$$\     \$$$$$$  |\$$$$$$  |$$ |  $$ |$$$$$$\ $$ |        $$ |   \$$$$$$  |
-- \______/ \__|     \__|      \________|\__|  \__| \______/ \________|\______/  \______/ \______|    \_/    \________|     \______/  \______/ \__|  \__|\______|\__|        \__|    \______/ 
-- JOIN OUR DISCORD FOR MORE LEAKS: discord.gg/5mscripts
Core = nil
Companies = {}
CreateThread(function()
    Core, Config.Framework = GetCore()
end)
CreateThread(function()
    local result = ExecuteSql("SELECT * FROM `mboss_general`")
    for _, v in pairs(result) do
        v.pageaccess = json.decode(v.pageaccess)
        v.location = json.decode(v.location)
        v.employees = {}
        v.logs = {}
        v.inventoryDisabled = tonumber(v.inventoryDisabled)
        v.vaultDisabled = tonumber(v.vaultDisabled)
    end
    Companies = result
    local result = ExecuteSql("SELECT * FROM `mboss_employees`")
    for _, v in pairs(result) do
        v.certifications = json.decode(v.certifications)
        local company = GetCompanyByName(v.company)
        if company then
            if not company.employees then company.employees = {} end
            company.employees[#company.employees + 1] = v
        end
    end
    local result = ExecuteSql("SELECT * FROM `mboss_general_logs`")
    for _,v in pairs(result) do
        local company = GetCompanyByName(v.company)
        if company then
            company.logs[#company.logs + 1] = v  
        end
    end

    local result = ExecuteSql("SELECT * FROM `mboss_permissions`")
    for _,v in pairs(result) do
        local company = GetCompanyByName(v.company)
        if company then
            if not company.permissions then company.permissions = {} end
        
           company.permissions[tostring(v.ranklevel)] = json.decode(v.permissions) 
        end
    end

    
    local result = ExecuteSql("SELECT * FROM `mboss_outfits`")
    for _,v in pairs(result) do
        local company = GetCompanyByName(v.name)
        if company then
            if not company.outfits then company.outfits = {} end
            for _,vv in pairs(result) do
                vv.preset_code = json.decode(vv.preset_code)
            end
           company.outfits =  result 
        end
    end
end)

function CreateLog(company, message, type, identifier)
    local companyData = GetCompanyByName(company)
    if companyData then
        local logid = #companyData.logs + 1
        companyData.logs[logid] = {
            message = message,
            identifier = identifier,
            date = os.time(),
            type = type or 'general'
        }
        identifier = identifier or ""
        local result = ExecuteSql("INSERT INTO `mboss_general_logs` (`company`, `identifier`,  `date`, `type`, `message`) VALUES ('" ..company .. "', '" .. identifier .. "', '" ..  companyData.logs[logid].date .. "', '" .. companyData.logs[logid].type .."', '" .. companyData.logs[logid].message .."')")
        companyData.logs[logid].id = result.insertId
        SyncCompanyByKey(company, "logs")

    end
    
end

function GetCompanyByName(name)
    for _, v in pairs(Companies) do
        if v.company == name then
            return v
        end
    end
    return false
end

function GetPlayerCompanyByIdentifier(identifier) 
    for _, v in pairs(Companies) do
        for __, employee in pairs(v.employees) do
            if employee.identifier == identifier then
                return v, employee, __
            end
        end
    end
    return false
end

function GetPlayerCompany(source)
    local identifier = GetIdentifier(source)
    for _, v in pairs(Companies) do
        for __, employee in pairs(v.employees) do
            if employee.identifier == identifier then
                return v, employee, __
            end
        end
    end
    return false
end

function GetJob(source)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            return Player.getJob().name, Player.getJob().grade, Player.getJob().label, Player.getJob().grade_label
        else
            return Player.PlayerData.job.name, Player.PlayerData.job.grade.level, Player.PlayerData.job.label,
                Player.PlayerData.job.grade.name
        end
    end
    return false
end

function GetJobByIdentifier(identifier)
    local Player = GetPlayerFromIdentifier(identifier)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            return Player.getJob().name,  Player.getJob().grade
        else
            return Player.PlayerData.job.name, Player.PlayerData.job.grade.level
        end
    else
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            local result = ExecuteSql("SELECT job, job_grade FROM `users` WHERE `identifier` ='" .. identifier .. "'")
            if result[1] then
                return result[1].job, result[1].job_grade
            end
        else
            local Player = Core.Player.GetOfflinePlayer(citizenid)
            return Player.PlayerData.job.name, Player.PlayerData.job.grade.level
        end
    end
end

function CheckPlayerJob(source, job)
    local Player = GetPlayer(tonumber(source))
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        if Player.getJob().name == job then
            return true
        end
    else
        if Player.PlayerData.job.name == job then
            return true
        end
    end
    return false
end

function GetPlayerFromIdentifier(identifier)
    local Player = false
    WaitCore()
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        Player = Core.GetPlayerFromIdentifier(identifier)
    else
        Player = Core.Functions.GetPlayerByCitizenId(identifier)
    end
    return Player
end

function GetPlayer(source)
    local Player = false
    WaitCore()
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        Player = Core.GetPlayerFromId(source)
    else
        Player = Core.Functions.GetPlayer(source)
    end
    return Player
end

RegisterServerEvent("mBossmenu:SyncCompany")
AddEventHandler("mBossmenu:SyncCompany", function()
    local src = source
    SyncCompany(GetJob(src))
end)

function SetJob(src, job, grade)
    local Player = GetPlayer(src)
    if Player then
        local newGrade = grade or 0
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            if Core.DoesJobExist(job, newGrade) then
                Player.setJob(job, newGrade)
            end
        else
            if Core.Shared.Jobs[job] and Core.Shared.Jobs[job].grades[tostring(newGrade)] then
                Player.Functions.SetJob(job, newGrade)
            end
        end
    end
end

function SetJobByIdentifier(identifier, jobb, grade)
    local Player = GetPlayerFromIdentifier(identifier)
    
    if Player then
        local newGrade = grade or 0
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            Player.setJob(tostring(jobb), tonumber(newGrade))
        else
            if Core.Shared.Jobs[jobb] and Core.Shared.Jobs[jobb].grades[newGrade] then
                Player.Functions.SetJob(jobb, newGrade)
            end
        end
    else
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            local newGrade = grade or 0            
            ExecuteSql("UPDATE users SET `job` = '" ..
            jobb .. "', `job_grade` = '"..grade.."' WHERE `identifier` = '" .. identifier .. "'")
        else   
            local jobbb = {
                name = jobb,         
                grade = {
                    level = newGrade
                }                
            } 
            ExecuteSql("UPDATE players SET `job` = '" ..
            json.encode(jobbb) .. "' WHERE `identifier` = '" .. identifier .. "'")
        end
    end
end


RegisterServerEvent("mBossmenu:setRank")
AddEventHandler("mBossmenu:setRank", function(identifier, rankLevel, name)
    local src = source
    local targetJob, targetJobLevel =  GetJobByIdentifier(identifier)
    local job, jobLevel = GetJob(src)
    local targetPlayer = GetPlayerFromIdentifier(identifier)
    local Player = GetPlayer(src)
    local company, employee, employeeI = GetPlayerCompanyByIdentifier(identifier)
    if identifier == (Player.identifier or Player.PlayerData.identifier) then
        return
    end

    if company and CheckPlayerJob(src, targetJob) and tonumber(jobLevel) >= tonumber(rankLevel) then
        local playerName = GetPlayerRPName(src)        
        SetJobByIdentifier(identifier, name, rankLevel)
        CreateLog(job, playerName.. " changed  "..employee.name.." rank to "..rankLevel, "general", Player.identifier)
        TriggerClientEvent("mBossmenu:sendNotification", src, "Rango cambiado con éxito")
        SyncCompanyByKey(job, "employees")
   
    end
end)

RegisterServerEvent("mBossmenu:fire")
AddEventHandler("mBossmenu:fire", function(identifier)
    local src = source
    local targetJob, targetJobLevel =  GetJobByIdentifier(identifier)
    local job, jobLevel = GetJob(src)
    local targetPlayer = GetPlayerFromIdentifier(identifier)
    local Player = GetPlayer(src)
    local company, employee, employeeI = GetPlayerCompanyByIdentifier(identifier)
    if identifier == (Player.identifier or Player.PlayerData.identifier) then
        return
    end
    if company and ((CheckPlayerJob(src, targetJob) and jobLevel > targetJobLevel) or CheckIsAdmin(src)) then
        if not HasPermission(src, 'fireEmployee') and not CheckIsAdmin(src) then TriggerClientEvent("mBossmenu:sendNotification", src, "No tienes permisos.") return end
        if targetPlayer then
            local targetSrc = (Config.Framework == 'esx' or Config.Framework == 'oldesx') and targetPlayer.source or targetPlayer.PlayerData.source
            SetJob(targetSrc, "unemployed", 0)
        else
            SetJobByIdentifier(identifier, "unemployed", 0)
        end
        local playerName = GetPlayerRPName(src)        
        CreateLog(job, playerName.. " fired "..employee.name, "general", Player.identifier)
        TriggerClientEvent("mBossmenu:sendNotification", src, "Has sido despedido "..employee.name)

        table.remove(company.employees, employeeI)
        ExecuteSql("DELETE FROM `mboss_employees` WHERE `identifier` ='" .. identifier .. "'")
        SyncCompany(job)
    end
end)

RegisterServerEvent("mBossmenu:SelectRank")
AddEventHandler("mBossmenu:SelectRank", function(id, grade)
    local src = source
    local job, jobLevel = GetJob(src)
    local Player = GetPlayer(src)
    local targetPlayer = GetPlayer(tonumber(id))
    local company = GetCompanyByName(job)
    if targetPlayer and company and tonumber(company.bossrank) >= tonumber(jobLevel) and company.company == job then
        if not HasPermission(src, 'recruitNewEmployee') then TriggerClientEvent("mBossmenu:sendNotification", src, "No tienes permiso.") return end
        SetJob(tonumber(id), job, grade)
        local playerName = GetPlayerRPName(src)        
        CreateLog(job, playerName.. " hired ".. GetPlayerRPName(tonumber(id)) , "general", Player.identifier)
        TriggerClientEvent("mBossmenu:sendNotification", src, "Le has despedido exitósamente")
        SyncCompanyByKey(job, "employees")
   
    end
end)

RegisterServerEvent("mBossmenu:ToggleCertification")
AddEventHandler("mBossmenu:ToggleCertification", function(identifier, certification)
    local src = source
    local targetJob, targetJobLevel =  GetJobByIdentifier(identifier)
    local job, jobLevel = GetJob(src)
    local playerName = GetPlayerRPName(src)        
    local Player = GetPlayer(src)

    if job == targetJob then
        local company, employee, employeeI = GetPlayerCompanyByIdentifier(identifier)
        if not HasPermission(src, 'changeEmployeeCertifications') then TriggerClientEvent("mBossmenu:sendNotification", src, "No tienes permiso.") return end

        local hasCertification = false
        for _,v in pairs(employee.certifications) do
            if v == certification then
                table.remove(employee.certifications, _)
                hasCertification = true
                CreateLog(job, playerName.. " removed ".. certification .." certification from "..employee.name , "general", Player.identifier)
                TriggerClientEvent("mBossmenu:sendNotification", src, "Certificado eliminado con éxito.")
            
            end
        end
        if not hasCertification then
            table.insert(employee.certifications, certification)
            CreateLog(job, playerName.. " added ".. certification .." certification to "..employee.name , "general", Player.identifier)
            TriggerClientEvent("mBossmenu:sendNotification", src, "Certificado añadido con éxito.")

        end

        ExecuteSql("UPDATE mboss_employees SET `certifications` = '" ..
        json.encode(employee.certifications) .. "' WHERE `identifier` = '" .. identifier .. "'")
        SyncCompanyByKey(job, "employees")
    end
end)

function SyncCompany(name)
    local company = GetCompanyByName(name)
    if company then
        for _, v in pairs(GetPlayers()) do
            if CheckPlayerJob(v, company.company) then
                TriggerClientEvent("mBossmenu:SyncCompany", v, company)
            end
        end
    end
end

function SyncCompanyByKey(name, key)
    local company = GetCompanyByName(name)
    if company then
        for _, v in pairs(GetPlayers()) do
            if CheckPlayerJob(v, company.company) then
                TriggerClientEvent("mBossmenu:SyncCompanyByKey", v, company[key], key)
            end
        end
    end
end
RegisterServerEvent("mBossmenu:ClearLogs")
AddEventHandler("mBossmenu:ClearLogs", function()
    local src = source
    local job, gradeLevel = GetJob(src)
    local company = GetCompanyByName(job)
    if job and company and company.company == job and tonumber(company.bossrank) == tonumber(gradeLevel) then
        company.logs = {}
        ExecuteSql("DELETE FROM `mboss_general_logs` WHERE `company` ='" .. job .. "'")

        SyncCompanyByKey(job, "logs")
    end
end)


RegisterServerEvent("mBossmenu:CheckPlayerData")
AddEventHandler("mBossmenu:CheckPlayerData", function()
    local src = source
    local jobName, gradeLevel, jobLabel, rankLabel = GetJob(src)
    local company, employee, employeeI = GetPlayerCompany(src)
    if company then
        local identifier = GetIdentifier(src)

        if company.company == jobName then
            if employee.rankLabel ~= rankLabel then
                
                ExecuteSql("UPDATE mboss_employees SET `rankLabel` = '" ..
                    rankLabel .. "', `rankLevel` = '"..gradeLevel.."' WHERE `identifier` = '" .. identifier .. "'")
                employee.rankLabel = rankLabel
                employee.rankLevel = gradeLevel
                local avatar = GetDiscordAvatar(src) or GetSteamPP(src)
                if avatar ~= employee.profilepicture then
                    employee.profilepicture = avatar
                    ExecuteSql("UPDATE mboss_employees SET `profilepicture` = '" ..
                    employee.profilepicture .. "' WHERE `identifier` = '" .. identifier .. "'")
                end
                SyncCompanyByKey(jobName, "employees")
            end
        else
            table.remove(company.employees, employeeI)
            ExecuteSql("DELETE FROM `mboss_employees` WHERE `identifier` ='" .. identifier .. "'")
            local newCompany = GetCompanyByName(jobName)
            if newCompany then
                CreateEmployeeData(src, jobName, jobLabel, rankLabel, gradeLevel)
            end
        end
    else
        local newCompany = GetCompanyByName(jobName)
        if newCompany then
            CreateEmployeeData(src, jobName, jobLabel, rankLabel, gradeLevel)
        end
    end
end)

function CreateEmployeeData(src, jobName, jobLabel, rankLabel, gradeLevel)
    local newCompany = GetCompanyByName(jobName)

    local employee =
    {
        name = GetPlayerRPName(src),
        profilepicture = GetDiscordAvatar(src) or GetSteamPP(src),
        joindate = os.time(),
        badgenumber = badgenumber(src),
        certifications = {},
        online = 1,
        rankLabel = rankLabel,
        jobLabel = jobLabel,
        identifier = GetIdentifier(src),
        company = jobName,
        note = "",
        rankLevel = gradeLevel,
    }

   
    local result = ExecuteSql(
        "INSERT INTO `mboss_employees` (`identifier`, `company`, `name`,  `profilepicture`, `badgenumber`, `certifications`, `online`, `joindate`, `rankLabel`, `jobLabel`, `rankLevel`, `note`) VALUES ('" ..
        employee.identifier .. "', '" ..
        jobName ..
        "', '" ..
        employee.name ..
        "',  '" ..
        employee.profilepicture ..
        "', '" ..
        employee.badgenumber ..
        "', '" ..
        json.encode(employee.certifications) ..
        "', '" .. employee.online ..
        "', '" .. employee.joindate .. "', '" .. employee.rankLabel .. "', '" .. employee.jobLabel .. "', '"..employee.rankLevel.."', '"..employee.note.."') ON DUPLICATE KEY UPDATE identifier = '"..employee.identifier.."'")
    employee.id = result.insertId
    table.insert(newCompany.employees, employee)


    SyncCompanyByKey(jobName, "employees")
end

RegisterServerEvent("mBossmenu:ChangeTheme")
AddEventHandler("mBossmenu:ChangeTheme", function(theme, name)
    local src = source
    local company = GetPlayerCompany(src)
    if name then
        company = GetCompanyByName(name)
    end
    if company then
        company.theme = theme
        ExecuteSql("UPDATE `mboss_general` SET `theme` = '" ..
        company.theme .. "' WHERE company = '" .. company.company .. "'")
        local name = GetPlayerRPName(src)
        CreateLog(company.company, name.." changed theme to "..theme, "general", GetIdentifier(src))
        SyncCompanyByKey(company.company, "theme")
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local job = GetJob(src)
    local company, employee = GetPlayerCompany(src)

    if employee then
        local name = GetPlayerRPName(src)
        CreateLog(job, name.." is offline", "activity", GetIdentifier(src))
        employee.online = 0
        ExecuteSql("UPDATE `mboss_employees` SET `online` = '" ..
            employee.online .. "' WHERE identifier = '" .. GetIdentifier(src) .. "'")

        SyncCompanyByKey(job, "employees")
    end
end)
RegisterServerEvent("mBossmenu:DeleteBusiness")
AddEventHandler("mBossmenu:DeleteBusiness", function(logo)
    local src = source
    local job, jobLevel = GetJob(src)
    local Player = GetPlayer(src)
    local company = GetCompanyByName(job)
    if company and tonumber(company.bossrank) >= tonumber(jobLevel) and company.company == job then
        TriggerClientEvent("mBossmenu:sendNotification", src, "Eliminando compañía...")            
        Wait(2000)
        for _, v in pairs(GetPlayers()) do
            if CheckPlayerJob(v, company.company) then
                TriggerClientEvent("mBossmenu:DeleteBusiness", v)
            end
        end

        ExecuteSql("DELETE FROM `mboss_employees` WHERE `company` ='" .. job .. "'")
        ExecuteSql("DELETE FROM `mboss_general` WHERE `company` ='" .. job .. "'")
        ExecuteSql("DELETE FROM `mboss_general_logs` WHERE `company` ='" .. job .. "'")
        ExecuteSql("DELETE FROM `mboss_inventory` WHERE `jobname` ='" .. job .. "'")
        ExecuteSql("DELETE FROM `mboss_vault_logs` WHERE `company` ='" .. job .. "'")
        for _, v in pairs(Companies) do
            if v.company == job then
                table.remove(Companies, _)
            end
        end
        
    end
end)
RegisterServerEvent("mBossmenu:UploadNewLogo")
AddEventHandler("mBossmenu:UploadNewLogo", function(logo, name)
    local src = source
    local job = GetJob(src)
    local company, employee = GetPlayerCompany(src)
    if name then
        company = GetCompanyByName(name)
    end
    if company then
        
        if not HasPermission(src, 'uploadNewLogo') and not CheckIsAdmin(src) then TriggerClientEvent("mBossmenu:sendNotification", src, "No tienes permiso.") return end
    
        company.logo = logo
        ExecuteSql("UPDATE `mboss_general` SET `logo` = '" ..
        company.logo .. "' WHERE company = '" ..company.company .. "'")
        local name = GetPlayerRPName(src)

        CreateLog(job, name.." changed company logo", "general", GetIdentifier(src))
        TriggerClientEvent("mBossmenu:sendNotification", src, "Logo actualizado")
        
        SyncCompanyByKey(job, "logo")

    end
end)

RegisterServerEvent("mBossmenu:SetPlayerOnline")
AddEventHandler("mBossmenu:SetPlayerOnline", function()
    local src = source
    local job = GetJob(src)
    local company, employee = GetPlayerCompany(src)
    if employee then
        employee.online = 1
        local name = GetPlayerRPName(src)
        ExecuteSql("UPDATE `mboss_employees` SET `online` = '" ..
            employee.online .. "' WHERE identifier = '" .. GetIdentifier(src) .. "'")
            CreateLog(job, name.." is online", "activity", GetIdentifier(src))
        SyncCompanyByKey(job, "employees")
    end
end)

RegisterServerEvent("mBossmenu:ToggleInventoryAccess")
AddEventHandler("mBossmenu:ToggleInventoryAccess", function()
    local src = source
    local job = GetJob(src) 
    local company = GetCompanyByName(job)
    if company then
        if not HasPermission(src, 'inventoryDisableEnableActions') then TriggerClientEvent("mBossmenu:sendNotification", src, "No tienes permiso.") return end
        if company.inventoryDisabled == 0 then company.inventoryDisabled = 1  else company.inventoryDisabled = 0 end
        SyncCompanyByKey(job, "inventoryDisabled")
    end
end)

RegisterServerEvent("mBossmenu:ToggleVaultAccess")
AddEventHandler("mBossmenu:ToggleVaultAccess", function()
    local src = source
    local job = GetJob(src) 
    local company = GetCompanyByName(job)
    if company then
        if not HasPermission(src, 'vaultDisableEnableActions') then TriggerClientEvent("mBossmenu:sendNotification", src, "No tienes permiso.") return end
        if company.vaultDisabled == 0 then company.vaultDisabled = 1  else company.vaultDisabled = 0 end
        SyncCompanyByKey(job, "vaultDisabled")     
    end
end)

RegisterServerEvent("mBossmenu:updateBusinessAccessPage")
AddEventHandler("mBossmenu:updateBusinessAccessPage", function(name, pageaccess)
    local company = GetCompanyByName(name)
    if company then 
        company.pageaccess = pageaccess
        ExecuteSql("UPDATE mboss_general SET `pageaccess` = '" ..
        json.encode(pageaccess) .. "' WHERE `company` = '" .. name .. "'")
        SyncCompanyByKey(name, "pageaccess")     
    end
end)

RegisterServerEvent("mBossmenu:updateBusinessLocation")
AddEventHandler("mBossmenu:updateBusinessLocation", function(name, location)
    local company = GetCompanyByName(name)
    if company then 
        company.location = location
        ExecuteSql("UPDATE mboss_general SET `location` = '" ..
        json.encode(location) .. "' WHERE `company` = '" .. name .. "'")
        SyncCompanyByKey(name, "location")     
    end
end)

RegisterServerEvent("mBossmenu:createMenu")
AddEventHandler("mBossmenu:createMenu", function(data)
    local src = source
    if GetCompanyByName(data.company) then return end
    local pageaccess = data.pageaccess
    local company = data.company
    local logo = data.logo
    local bossrank = data.bossrank
    local location = data.location
    local jobName, gradeLevel, jobLabel, rankLabel = GetJob(src)
    local companyData = {
        pageaccess = pageaccess,
        company = company,
        logo = logo or 'assets/images/default-logo.png',
        bossrank = bossrank,
        location = location,
        theme = data.theme,
        companylabel = data.joblabel,
        creationdate = os.time(),
        logs = {},
        vault = 0,
        inventoryDisabled = 0,
        vaultDisabled = 0,
        permissions = {},
        employees = {},
        outfits = {},
        vault_income = 0,
        vault_expense = 0,
    }
    
    ExecuteSql(
        "INSERT INTO `mboss_general` (`company`, `vault`,  `logo`, `bossrank`, `pageaccess`, `location`,`companylabel`, `creationdate`, `theme`, `inventoryDisabled`, `vaultDisabled`, `vault_income`, `vault_expense`) VALUES ('" ..
        company ..
        "', '0',  '" .. companyData.logo .. "', '" .. bossrank ..
        "', '" .. json.encode(pageaccess) .. "', '" .. json.encode(location) .. "', '"..data.joblabel.."', '"..companyData.creationdate.."', '"..data.theme.."', '0', '0', '0', '0')")
    ExecuteSql(
        'INSERT INTO mboss_inventory (jobname, inventory) VALUES (:jobname, :inventory) ',
        {
            jobname = company,
            inventory = json.encode({}),
        }
    )

    companyData.permissions = InsertPermissions(company)
    table.insert(Companies, companyData)
    TriggerClientEvent("mBossmenu:sendNotification", src, "El menú ha sido creado...")
    TriggerClientEvent("mBossmenu:checkJob", -1)
    
    SyncCompany(company)
end)

RegisterServerEvent("mBossmenu:EditPreset")
AddEventHandler("mBossmenu:EditPreset", function(selectedOutfit)
    local src = source
    local job, gradeLevel = GetJob(src)
    local company = GetCompanyByName(job)
    if company then
        for _,v in pairs(company.outfits) do
           if v.id == selectedOutfit.id then
             v.preset_name = selectedOutfit.preset_name
             company.outfits[_].preset_code = selectedOutfit.preset_code
           end
        end
        ExecuteSql("UPDATE mboss_outfits SET `preset_code` = '" ..
        json.encode(selectedOutfit.preset_code) .. "', `preset_name` = '" ..  selectedOutfit.preset_name .."'  WHERE `id` = '" .. selectedOutfit.id .. "'")
        SyncCompanyByKey(company.company, "outfits")
        TriggerClientEvent("mBossmenu:sendNotification", src, "Outfit editado por favor seleccionalo de nuevo...")

    end
end)

RegisterServerEvent("mBossmenu:DeleteClothes")
AddEventHandler("mBossmenu:DeleteClothes", function(id)
    local src = source
    local job, gradeLevel = GetJob(src)
    local company = GetCompanyByName(job)
    if company then
        for _,v in pairs(company.outfits) do
            if tonumber(v.id) == tonumber(id) then
                table.remove(company.outfits, _)
            end
        end
        ExecuteSql("DELETE FROM `mboss_outfits` WHERE `id` ='" .. id .. "'")
        SyncCompanyByKey(company.company, "outfits")
        TriggerClientEvent("mBossmenu:sendNotification", src, "Outfit has been deleted...")

    end
end)

RegisterServerEvent("mBossmenu:SaveOutfit")
AddEventHandler("mBossmenu:SaveOutfit", function(outfit, preset_name)
    local src = source
    local job, gradeLevel = GetJob(src)
    local company = GetCompanyByName(job)
    if company then
        local res = ExecuteSql(
            'INSERT INTO mboss_outfits (name, preset_code, preset_name) VALUES (:name, :preset_code, :preset_name) ',
            {
                name = company.company,
                preset_code = json.encode(outfit),
                preset_name = preset_name
            }
        )
        if not company.outfits then company.outfits = {} end
        table.insert(company.outfits, {
            id = res.insertId,
            preset_code = outfit,
            preset_name = preset_name,
        })
        SyncCompanyByKey(company.company, "outfits")
        TriggerClientEvent("mBossmenu:sendNotification", src, "El outfit ha sido creado...")

    end
end)


RegisterServerEvent("mBossmenu:SaveNote")
AddEventHandler("mBossmenu:SaveNote", function(identifier, note)
    local src = source
    local Player = GetPlayer(src)
    local company, employee =  GetPlayerCompanyByIdentifier(identifier) 
    if company and employee then
        
        if not HasPermission(src, 'editNote') then TriggerClientEvent("mBossmenu:sendNotification", src, "No tienes permiso.") return end
        
        if employee.note == note then
            return 
        end
        local playerName = GetPlayerRPName(src)
        TriggerClientEvent("mBossmenu:sendNotification", src, "Nota actualizada")
        CreateLog(company.company, playerName.. " updated  "..employee.name.."s note. ", "general", Player.identifier)

        employee.note = note
        ExecuteSql("UPDATE mboss_employees SET `note` = '" ..
        note .. "' WHERE `identifier` = '" .. identifier .. "'")
        SyncCompanyByKey(company.company, "employees")
    end
end)

function FormatJobData(jobs)
    local data = {}
    for job, v in pairs(jobs) do
        data[#data + 1] = {
            name = job,
            label = v.label
        }
    end
    return data
end

function GetJobRanks(job)
    WaitCore()
    local data = {}
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        while not next(Core.Jobs) do
            Wait(500)
            Core.Jobs = Core.GetJobs()
        end
        if Core.Jobs[job] then
            for _, v in pairs(Core.Jobs[job].grades) do
                local isboss = false
                if GetCompanyByName(job) and tonumber(GetCompanyByName(job).bossrank) == tonumber(v.grade) then
                    isboss = true
                end
                table.insert(data, {
                    label = v.label,
                    grade = v.grade,
                    name = job.label,
                    job_name = job,
                    job_label = Core.Jobs[job].label,
                    isboss = isboss
                })
            end
        end
    else
        if Core.Shared.Jobs[job] then
            for gradeLevel, v in pairs(Core.Shared.Jobs[job].grades) do
                local isboss = false
                if GetCompanyByName(job) and tonumber(GetCompanyByName(job).bossrank) == tonumber(v.grade) then
                    isboss = true
                end
                table.insert(data, {
                    label = v.name,
                    grade = tonumber(gradeLevel),
                    name = job,
                    job_name = job,
                    isboss = isboss,
                    job_label = Core.Shared.Jobs[job].label,
                
                })
            end
        end
    end
    return data
end

function GetAdmins()
    local admins = {}
    for _,v in pairs(GetPlayers()) do
        local src = tonumber(v)
        if CheckIsAdmin(src) then
            table.insert(admins, {
                name = GetPlayerRPName(src),
                pp = GetDiscordAvatar(src)
            })
        end
    end
    return admins
end

CreateThread(function()
    WaitCore()

    
    RegisterCallback("mBossmenu:checkIsAdmin", function(source, cb)
        cb(CheckIsAdmin(source))
    end)
    RegisterCallback("mBossmenu:GetAdmins", function(source, cb)
        cb(GetAdmins())
    end)
    RegisterCallback("mBossmenu:getCompanies", function(source, cb)
        cb(Companies)
    end)
    RegisterCallback('mBossmenu:getPlayerPPById', function(source, cb, id)
        local Player = GetPlayer(tonumber(id))
        if Player then
            cb( GetDiscordAvatar(tonumber(id)) or GetSteamPP(tonumber(id)))
        else
            cb(false)
        end
    end)
    RegisterCallback('mBossmenu:getJobs', function(source, cb)
        local data = {}
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            data = FormatJobData(Core.Jobs)
        else
            data = FormatJobData(Core.Shared.Jobs)
        end
        cb(data)
    end)
    RegisterCallback('mBossmenu:getRanksByName', function(source, cb, job)
        cb(GetJobRanks(job))
    end)
    RegisterCallback('mBossmenu:getInventoryByName', function(source, cb, job)
        local result = ExecuteSql("SELECT `inventory`  FROM `mboss_inventory` WHERE `jobname` = '" .. job .. "'")
        if result[1] then
            cb(json.decode(result[1].inventory))
        else
            cb({})
        end
    end)
 
    RegisterCallback('mBossmenu:getRanks', function(source, cb)
        local job = GetJob(source)
        cb(GetJobRanks(job))
    end)
    RegisterCallback('mBossmenu:getPlayerName', function(source, cb)
        cb(GetPlayerRPName(source))
    end)
    RegisterCallback('mBossmenu:getPlayerPP', function(source, cb)
        cb(GetDiscordAvatar(source) or GetSteamPP(source))
    end)
    RegisterCallback('mBossmenu:getPlayerNameById', function(source, cb, id)
        cb(GetPlayerRPName(tonumber(id)))
    end)
    RegisterCallback('mBossmenu:getVaultByName', function(source, cb, name)
        cb(GetSocietyMoney(name))
    end)
    
end)
