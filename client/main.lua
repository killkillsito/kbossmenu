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
CreateThread(function()
    Core, Config.Framework = GetCore()
end)

nuiLoaded = false
isMenuOpen = false
jobInfo = {
    name = '',
    level = '',
    grade_label = '',
}
companyData = {}

RegisterNUICallback("updateBusinessAccessPage", function(data, cb)
    TriggerServerEvent("mBossmenu:updateBusinessAccessPage", data.name, data.pageaccess)
end)



RegisterNUICallback("updateBusinessLocation", function(data, cb)
    TriggerServerEvent("mBossmenu:updateBusinessLocation", data.name, data.location)
end)

RegisterNUICallback("fire", function(data)
    local identifier = data
    TriggerServerEvent("mBossmenu:fire", identifier)
end)

RegisterNUICallback("openClothingMenu", function(data, cb)
    NuiMessage("close")
    openClothingMenu()
end)


RegisterNetEvent("mBossmenu:DeleteBusiness")
AddEventHandler("mBossmenu:DeleteBusiness", function()
    companyData = {}
    NuiMessage("close")
end)
RegisterNetEvent("mBossmenu:checkJob")
AddEventHandler("mBossmenu:checkJob", function()
    SetPlayerJob()
end)
RegisterNUICallback('DeleteBusiness', function(data, cb)
    TriggerServerEvent("mBossmenu:DeleteBusiness")
end)
RegisterNUICallback('copyCoords', function(data, cb)
    local coords = GetEntityCoords(PlayerPedId())
    cb(json.encode(coords))
end)
RegisterNUICallback('ToggleInventoryAccess', function(data, cb)
    TriggerServerEvent("mBossmenu:ToggleInventoryAccess")
end)

RegisterNUICallback('ToggleVaultAccess', function(data, cb)
    TriggerServerEvent("mBossmenu:ToggleVaultAccess")
end)
CreateCamera = function()
    local invehicle = IsPedInAnyVehicle(PlayerPedId(), false)
    if invehicle then return end
    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 1.38, -1.7, 0)
    RenderScriptCams(true, true, 500, true, true)
    DestroyCam(cam, false)
    if (not DoesCamExist(cam)) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, true)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 0.2)
        SetCamRot(cam, 5.0, 0.0, GetEntityHeading(PlayerPedId())) -- Change here
        SetCamNearClip(cam, 0.1)                                  -- Adjust the near clip distance
        SetCamFarClip(cam, 1000.0)                                -- Adjust the far clip distance
        SetCamFov(cam, 68.0)                                      -- Adjust the field of view
        SetCamDofFnumberOfLens(camera, 24.0)                      -- Number of lens in the camera's focus
        SetCamDofFocalLengthMultiplier(camera, 50.0)              -- Focal length of the camera's lens
    end
end


function OpenMenu(type, page)
    if type == 'main' then
        NuiMessage('setCompanyData', companyData)
        NuiMessage("setPermissions", companyData.permissions[tostring(jobInfo.level)])
    end
    if type == 'admin' then
        
        NuiMessage('setCompanies', TriggerCallback("mBossmenu:getCompanies"))
    end 
    NuiMessage('openMenu', {
        type = type,
        page = page
    })
    onBossMenuOpen()
    ToggleTablet(true)

    SetNuiFocus(true, true)
    isMenuOpen = true
    CreateCamera()
end

RegisterNetEvent('mBossmenu:OpenMenu')
AddEventHandler('mBossmenu:OpenMenu', function()
    if CanOpenMenu() then
        OpenMenu('main', 'employees')
        loadPlayerInventory()
        loadPlayerVault()
    else
        Config.Notify(locales.no_permission_2)
    end
end)



RegisterNUICallback("getRanksByName", function(data, cb)
    local name = data.name
    cb(TriggerCallback("mBossmenu:getRanksByName", name))
end)
RegisterNUICallback("getInventoryByName", function(data, cb)
    local name = data.name
    cb(TriggerCallback("mBossmenu:getInventoryByName", name))
end)



RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, true)
    ClearFocus()
    onBossMenuClose()
    ToggleTablet(false)
    cb('ok')
end)

RegisterNUICallback("changeTheme", function(data, cb)
    TriggerServerEvent("mBossmenu:ChangeTheme", data.theme, data.companyName)
    cb("ok")
end)


function CanOpenMenu()
    local canOpen = false
    if companyData and jobInfo.name == companyData.company and companyData.permissions[tostring(jobInfo.level)] then
        for _,v in pairs(companyData.permissions[tostring(jobInfo.level)]) do
            if v then
                canOpen = true
            end
        end
    end
    return canOpen 
end


RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
    Wait(2000)
    SetPlayerJob()
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    Wait(2000)
    SetPlayerJob()
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    Wait(2000)
    SetPlayerJob()
end)

RegisterNetEvent("QBCore:Player:SetPlayerData")
AddEventHandler("QBCore:Player:SetPlayerData", function(data)
    Wait(1000)
    SetPlayerJob()
end)

CreateThread(function()
    Wait(3000)
    NuiMessage("setCertifications", Config.Certifications)
    SetPlayerJob()
    TriggerServerEvent("mBossmenu:SetPlayerOnline")
end)

function SetPlayerJob()
    Wait(500)
    WaitPlayer()

    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        local PlayerData = Core.GetPlayerData()
        jobInfo = {
            name = PlayerData.job.name,
            label = PlayerData.job.label,
            level = PlayerData.job.grade,
            grade_label = PlayerData.job.grade_label,

        }
    else
        local PlayerData = Core.Functions.GetPlayerData()
        jobInfo = {
            name = PlayerData["job"].name,
            label = PlayerData["job"].label,
            level = PlayerData["job"].grade.level,
            grade_label = PlayerData["job"].grade.name
        }
    end
    
    NuiMessage("setRanks")
    NuiMessage("setJobInfo", jobInfo)
    TriggerServerEvent("mBossmenu:SyncCompany")
    TriggerServerEvent("mBossmenu:CheckPlayerData")
end

function NuiMessage(action, payload)
    WaitNui()
    SendNUIMessage({
        action = action,
        payload = payload
    })
end

CreateThread(function()
    NuiMessage('setItemImagesFolder', Config.ItemImagesFolder)
    NuiMessage('setPlayerInfo', {
        type = "name",
        value = TriggerCallback("mBossmenu:getPlayerName")
    })

    NuiMessage('setPlayerInfo', {
        type = "pp",
        value = TriggerCallback("mBossmenu:getPlayerPP")
    })
    NuiMessage("setLocales", locales)
end)



CreateThread(function()
    while not nuiLoaded do
        Wait(2000)
        if NetworkIsSessionStarted() then
            SendNUIMessage({
                action = "checkNui",
            })
        end
    end
end)
RegisterNUICallback("loaded", function(data, cb)
    nuiLoaded = true
    cb("ok")
end)


RegisterNUICallback("ToggleCertification", function(data, cb)
    local identifier = data.identifier
    local certification = data.certification
    TriggerServerEvent("mBossmenu:ToggleCertification", identifier, certification)
end)

RegisterNUICallback("ClearLogs", function(data, cb)
    TriggerServerEvent("mBossmenu:ClearLogs")
end)

function SendNotification(message)
    NuiMessage('sendNotification', message)
end


RegisterNetEvent("mBossmenu:sendNotification")
AddEventHandler("mBossmenu:sendNotification", SendNotification)

RegisterNUICallback("getVaultByName", function(data, cb, name)
    local name = data.name
    local amount = TriggerCallback('mBossmenu:getVaultByName', name)
    cb(amount)
end)

RegisterNUICallback("getPlayerPP", function(data, cb)
    local id = data
    local pp = TriggerCallback('mBossmenu:getPlayerPPById', id)
    cb(pp)
end)

RegisterNUICallback("getPlayerName", function(data, cb)
    local id = data
    local name = TriggerCallback('mBossmenu:getPlayerNameById', id)
    cb(name)
end)

RegisterNUICallback("SelectRank", function(data, cb)
    local id = data.id
    local grade = data.grade
    TriggerServerEvent("mBossmenu:SelectRank", id, grade)
end)
RegisterNUICallback("setRank", function(data, cb)
    local identifier = data.identifier
    local rankLevel = data.rankLevel
    local name = data.name
    TriggerServerEvent("mBossmenu:setRank", identifier, rankLevel, name)
end)

RegisterNUICallback("getRanks", function(data, cb)
    local ranks = TriggerCallback('mBossmenu:getRanks')
    cb(ranks)
end)

RegisterNUICallback("getJobs", function(data, cb)
    local jobs = TriggerCallback('mBossmenu:getJobs')
    cb(jobs)
end)


RegisterNetEvent("mBossmenu:SyncCompany")
AddEventHandler("mBossmenu:SyncCompany", function(data)
    companyData = data
    NuiMessage('setCompanyData', companyData)
    NuiMessage("setPermissions", companyData.permissions[tostring(jobInfo.level)])
    InitInteraction()
end)

RegisterNetEvent("mBossmenu:SyncCompanyByKey")
AddEventHandler("mBossmenu:SyncCompanyByKey", function(data, key)
    companyData[key] = data
    NuiMessage('setCompanyData', companyData)

end)
RegisterNUICallback("wearOriginalClothes", function(data, cb)
    RefreshSkin()
end)

RegisterNUICallback("togglePermission", function(data, cb)
    TriggerServerEvent("mBossmenu:TogglePermission", data.rank, data.name)
end)

RegisterNUICallback('createMenu', function(data, cb)
    TriggerServerEvent('mBossmenu:createMenu', data)
end)

RegisterNUICallback("SaveNote", function(data, cb)
    local identifier = data.identifier
    local note = data.note
    TriggerServerEvent('mBossmenu:SaveNote', identifier, note)
end)

RegisterNUICallback("UploadNewLogo", function(data, cb)
    local url = data.url
    local name = data.name
    TriggerServerEvent("mBossmenu:UploadNewLogo", url, name)
end)
RegisterNUICallback("getAdmins", function(data, cb)
    cb(TriggerCallback("mBossmenu:GetAdmins"))
end)

RegisterNUICallback("SaveOutfit", function(data, cb)
    TriggerServerEvent("mBossmenu:SaveOutfit", data.dressCode, data.presetName)
    cb("ok")
end)

RegisterNUICallback("DeleteClothes", function(data, cb)
    TriggerServerEvent("mBossmenu:DeleteClothes", data)
    cb("ok")
end)

RegisterNUICallback("EditPreset", function(data, cb)
    TriggerServerEvent("mBossmenu:EditPreset", data)
    cb("ok")
end)

RegisterNUICallback("WearClothes", function(data, cb)
    TriggerEvent('skinchanger:getSkin', function(skin) TriggerEvent("esx_skin:setLastSkin", skin) end)    
    ChangeClothes("jacket", data.jacket.val, data.jacket.tex)
    ChangeClothes("shirt", data.shirt.val, data.shirt.tex)
    ChangeClothes("arms", data.hands.val, data.hands.tex)
    ChangeClothes("legs", data.pants.val, data.pants.tex)
    ChangeClothes("shoes", data.shoes.val, data.shoes.tex)
    ChangeClothes("mask", data.mask.val, data.mask.tex)
    ChangeClothes("chain", data.chain.val, data.chain.tex)
    ChangeClothes("decals", data.decals.val, data.decals.tex)
    ChangeClothes("helmet", data.helmet.val, data.helmet.tex)
    ChangeClothes("glasses", data.glasses.val, data.glasses.tex)
    ChangeClothes("watches", data.watches.val, data.watches.tex)
    ChangeClothes("bracelets", data.bracelets.val, data.bracelets.tex)
end)


function ChangeClothes(key, value, texture)
    local playerPed = PlayerPedId()
    value = tonumber(value)
    texture = tonumber(texture)

    if key == 'jacket' then

        SetPedComponentVariation(playerPed, 11, value, texture, 2) 
    end
    if key == 'shirt' then
        SetPedComponentVariation(playerPed, 8, value, texture, 2)  
    end
    if key == 'arms' then
        SetPedComponentVariation(playerPed, 3, value, texture, 2)  
    end
    if key == 'legs' then
        SetPedComponentVariation(playerPed, 4, value, texture, 2)  
    end
    if key == 'shoes' then
        SetPedComponentVariation(playerPed, 6, value, texture, 2)  
    end
    if key == 'mask' then
        SetPedComponentVariation(playerPed, 1, value, texture, 2)  
    end
    if key == 'chain' then
        SetPedComponentVariation(playerPed, 7, value, texture, 2)  
    end
    if key == 'decals' then
        SetPedComponentVariation(playerPed, 10, value, texture, 2) 
    end
    if key == 'helmet' then
        SetPedPropIndex(playerPed, 0, value, texture, 2) 
    end
    if key == 'glasses' then
        SetPedPropIndex(playerPed, 1, value, texture, 2) 
    end
    if key == 'watches' then
        SetPedPropIndex(playerPed, 6, value, texture, 2)
    end
    if key == 'bracelets' then
        SetPedPropIndex(playerPed, 7, value, texture, 2)
    end
end