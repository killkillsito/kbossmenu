--$$$$$$$\  $$\      $$\       $$$$$$$$\ $$\   $$\  $$$$$$\  $$\      $$\   $$\  $$$$$$\  $$$$$$\ $$\    $$\ $$$$$$$$\      $$$$$$\   $$$$$$\  $$$$$$$\  $$$$$$\ $$$$$$$\ $$$$$$$$\  $$$$$$\  
--$$  ____| $$$\    $$$ |      $$  _____|$$ |  $$ |$$  __$$\ $$ |     $$ |  $$ |$$  __$$\ \_$$  _|$$ |   $$ |$$  _____|    $$  __$$\ $$  __$$\ $$  __$$\ \_$$  _|$$  __$$\\__$$  __|$$  __$$\ 
--$$ |      $$$$\  $$$$ |      $$ |      \$$\ $$  |$$ /  \__|$$ |     $$ |  $$ |$$ /  \__|  $$ |  $$ |   $$ |$$ |          $$ /  \__|$$ /  \__|$$ |  $$ |  $$ |  $$ |  $$ |  $$ |   $$ /  \__|
--$$$$$$$\  $$\$$\$$ $$ |      $$$$$\     \$$$$  / $$ |      $$ |     $$ |  $$ |\$$$$$$\    $$ |  \$$\  $$  |$$$$$\ $$$$$$\\$$$$$$\  $$ |      $$$$$$$  |  $$ |  $$$$$$$  |  $$ |   \$$$$$$\  
--\_____$$\ $$ \$$$  $$ |      $$  __|    $$  $$<  $$ |      $$ |     $$ |  $$ | \____$$\   $$ |   \$$\$$  / $$  __|\______|\____$$\ $$ |      $$  __$$<   $$ |  $$  ____/   $$ |    \____$$\ 
--$$\   $$ |$$ |\$  /$$ |      $$ |      $$  /\$$\ $$ |  $$\ $$ |     $$ |  $$ |$$\   $$ |  $$ |    \$$$  /  $$ |          $$\   $$ |$$ |  $$\ $$ |  $$ |  $$ |  $$ |        $$ |   $$\   $$ |
--\$$$$$$  |$$ | \_/ $$ |      $$$$$$$$\ $$ /  $$ |\$$$$$$  |$$$$$$$$\\$$$$$$  |\$$$$$$  |$$$$$$\    \$  /   $$$$$$$$\     \$$$$$$  |\$$$$$$  |$$ |  $$ |$$$$$$\ $$ |        $$ |   \$$$$$$  |
-- \______/ \__|     \__|      \________|\__|  \__| \______/ \________|\______/  \______/ \______|    \_/    \________|     \______/  \______/ \__|  \__|\______|\__|        \__|    \______/ 
-- JOIN OUR DISCORD FOR MORE LEAKS: discord.gg/5mscripts
local permissionsTemplate = {
    accessToEmployeePage = true,
    recruitNewEmployee = true,
    accessToEmployeeDetails = true,
    fireEmployee = true,
    changeEmployeeCertifications = true,
    uploadNewLogo = true,
    accessToRanksPage = true,    
    editNote = true,
    changeRankLevel = true,
    accessToCompanyPage = true,
    depositMoney = true,
    withdrawMoney = true,
    vaultDisableEnableActions = true,
    viewMoneyLog = true,
    accessToInventory = true,
    takeItem = true,
    inventoryDisableEnableActions = true,
    accessToClothingPage = true,
    addDressCode = true,
    editDressCode = true,
    deleteDressCode = true,
    accessToBusinessPage = true,
}

function HasPermission(source, name)
    local job, jobLevel = GetJob(source)
    local company = GetCompanyByName(job)       
    if company and company.permissions[tostring(jobLevel)][name] then
        return true
    end
    return false
end

function InsertPermissions(company)
    if company then
        for __,rank in pairs(GetJobRanks(company)) do
            ExecuteSql("INSERT INTO `mboss_permissions` (`company`, `ranklevel`, `permissions`) VALUES ('"..company.."', '"..rank.grade.."', '"..json.encode(permissionsTemplate).."') ON DUPLICATE KEY UPDATE company = '"..company.."', ranklevel = '"..rank.grade.."'")
        end
        local data = {}
        for __,rank in pairs(GetJobRanks(company)) do
            data[tostring(rank.grade)] =permissionsTemplate
        end
        return data
    else

        local result = ExecuteSql("SELECT company FROM `mboss_general`")
        for _,v in pairs(result) do
            for __,rank in pairs(GetJobRanks(v.company)) do
                ExecuteSql("INSERT INTO `mboss_permissions` (`company`, `ranklevel`, `permissions`) VALUES ('"..v.company.."', '"..rank.grade.."', '"..json.encode(permissionsTemplate).."') ON DUPLICATE KEY UPDATE company = '"..v.company.."', ranklevel = '"..rank.grade.."'")
            end
        end
    end
end

CreateThread(function()
    InsertPermissions(company)
end)

RegisterServerEvent("mBossmenu:TogglePermission")
AddEventHandler("mBossmenu:TogglePermission", function(rank, name)
    local src = source
    local job = GetJob(src)
    local company = GetCompanyByName(job)
    if company then
        if tonumber(rank) == tonumber(company.bossrank) then
            TriggerClientEvent("mBossmenu:sendNotification", src, "No puedes editar el rango del JEFE. ¿No querrás que se entere, verdad?.")
            return
        end
        if company.permissions[tostring(rank)][name] then
            company.permissions[tostring(rank)][name] = false
        else
            company.permissions[tostring(rank)][name] = true
        end
        ExecuteSql("UPDATE `mboss_permissions` SET `permissions` = '" ..
        json.encode(company.permissions[tostring(rank)]) .. "' WHERE company = '" .. job .. "' AND ranklevel = '"..rank.."'")
        SyncCompanyByKey(company.company, "permissions")
    end
end)