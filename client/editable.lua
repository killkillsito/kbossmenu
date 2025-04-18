--$$$$$$$\  $$\      $$\       $$$$$$$$\ $$\   $$\  $$$$$$\  $$\      $$\   $$\  $$$$$$\  $$$$$$\ $$\    $$\ $$$$$$$$\      $$$$$$\   $$$$$$\  $$$$$$$\  $$$$$$\ $$$$$$$\ $$$$$$$$\  $$$$$$\  
--$$  ____| $$$\    $$$ |      $$  _____|$$ |  $$ |$$  __$$\ $$ |     $$ |  $$ |$$  __$$\ \_$$  _|$$ |   $$ |$$  _____|    $$  __$$\ $$  __$$\ $$  __$$\ \_$$  _|$$  __$$\\__$$  __|$$  __$$\ 
--$$ |      $$$$\  $$$$ |      $$ |      \$$\ $$  |$$ /  \__|$$ |     $$ |  $$ |$$ /  \__|  $$ |  $$ |   $$ |$$ |          $$ /  \__|$$ /  \__|$$ |  $$ |  $$ |  $$ |  $$ |  $$ |   $$ /  \__|
--$$$$$$$\  $$\$$\$$ $$ |      $$$$$\     \$$$$  / $$ |      $$ |     $$ |  $$ |\$$$$$$\    $$ |  \$$\  $$  |$$$$$\ $$$$$$\\$$$$$$\  $$ |      $$$$$$$  |  $$ |  $$$$$$$  |  $$ |   \$$$$$$\  
--\_____$$\ $$ \$$$  $$ |      $$  __|    $$  $$<  $$ |      $$ |     $$ |  $$ | \____$$\   $$ |   \$$\$$  / $$  __|\______|\____$$\ $$ |      $$  __$$<   $$ |  $$  ____/   $$ |    \____$$\ 
--$$\   $$ |$$ |\$  /$$ |      $$ |      $$  /\$$\ $$ |  $$\ $$ |     $$ |  $$ |$$\   $$ |  $$ |    \$$$  /  $$ |          $$\   $$ |$$ |  $$\ $$ |  $$ |  $$ |  $$ |        $$ |   $$\   $$ |
--\$$$$$$  |$$ | \_/ $$ |      $$$$$$$$\ $$ /  $$ |\$$$$$$  |$$$$$$$$\\$$$$$$  |\$$$$$$  |$$$$$$\    \$  /   $$$$$$$$\     \$$$$$$  |\$$$$$$  |$$ |  $$ |$$$$$$\ $$ |        $$ |   \$$$$$$  |
-- \______/ \__|     \__|      \________|\__|  \__| \______/ \________|\______/  \______/ \______|    \_/    \________|     \______/  \______/ \__|  \__|\______|\__|        \__|    \______/ 
-- JOIN OUR DISCORD FOR MORE LEAKS: discord.gg/5mscripts

local targetCache = {}
function InitInteraction()
    if Config.InteractionHandler == 'ox_target'  then
        if targetCache[companyData.company] then return end
        targetCache[companyData.company] = true
        exports.ox_target:addBoxZone({
            name = 'mBoss'..companyData.company,
            coords = vector3(companyData.location.x, companyData.location.y, companyData.location.z),
            size = vec3(3.6, 3.6, 3.6),
            drawSprite = true,
            options =  {
                {
                    name = 'mBoss'..companyData.company,
                    event = 'mBossmenu:OpenMenu',
                    icon = 'fas fa-gears',
                    label = locales.open_menu,
                }
            }
        })
    end
    if Config.InteractionHandler == 'qb_target'  then
        if targetCache[companyData.company] then return end
        targetCache[companyData.company] = true
        exports['qb-target']:AddBoxZone('mBoss'..companyData.company, vector3(companyData.location.x, companyData.location.y, companyData.location.z), 1.5, 1.6,
            {
                name = 'mBoss'..companyData.company,
                heading = 12.0,
                debugPoly = false,
                minZ = companyData.location.z - 1,
                maxZ = companyData.location.z + 1,
            }, 
            {
            options = {
                {
                    num = 1,
                    type = "client",
                    icon = 'fas fa-gears',
                    label = locales.open_menu,
                    targeticon = 'fas fa-gears',
                    action = function()
                        TriggerEvent("mBossmenu:OpenMenu")
                    end
                }
            },
            distance = 4.5,
        })
    end
    if Config.InteractionHandler == 'qb_textui' then
        
        if targetCache[companyData.company] then return end
        targetCache[companyData.company] = true
        CreateThread(function()
            while true do
                local show = false
                local cd = 1500
                if companyData.location then
                    local plyCoords = GetEntityCoords(PlayerPedId())
                    local vec = vector3(companyData.location.x, companyData.location.y, companyData.location.z)
                    local dist = #(vec - plyCoords)
                    if dist < 5.0 and CanOpenMenu() then
                        cd = 0
                        if not show then
                            Core.TextUI(locales.press)
                            show = true
                        end
                        if IsControlJustPressed(0, Config.MenuKey) then
                            OpenMenu('main', 'employees')
                            loadPlayerInventory()
                            loadPlayerVault()
                        end
                    else
                        if show then
                            show = false
                            Core.HideUI()
                        end
                    end
                else
                    if show then
                        show = false
                        Core.HideUI()

                    end
                end
                Wait(cd)
            end
        end)
    end 
    if Config.InteractionHandler == 'esx_textui' then
        if targetCache[companyData.company] then return end
        targetCache[companyData.company] = true

        CreateThread(function()
            local show = false
            while true do
                
                local cd = 1500
                if companyData.location then
                    local plyCoords = GetEntityCoords(PlayerPedId())
                    local vec = vector3(companyData.location.x, companyData.location.y, companyData.location.z)
                    local dist = #(vec - plyCoords)
                    if dist < 5.0 and CanOpenMenu() then
                        cd = 0
                        if not show then
                            Core.TextUI(locales.press)
                            show = true
                        end
                        if IsControlJustPressed(0, Config.MenuKey) then
                            OpenMenu('main', 'employees')
                            loadPlayerInventory()
                            loadPlayerVault()
                        end
                    else
                        if show then
                            show = false
                            Core.HideUI()
                        end
                    end
                else
                    if show then
                        show = false
                        Core.HideUI()

                    end
                end
                Wait(cd)
            end
        end)
    end 
    if Config.InteractionHandler == 'drawtext' then
        if targetCache[companyData.company] then return end
        targetCache[companyData.company] = true
        CreateThread(function()
            while true do
                local cd = 1500
                if companyData.location then
                    local plyCoords = GetEntityCoords(PlayerPedId())
                    local vec = vector3(companyData.location.x, companyData.location.y, companyData.location.z)
                    local dist = #(vec - plyCoords)
                    if dist < 4.0 and CanOpenMenu() then
                        cd = 0
                        DrawMarker(2, vec, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 255, false, false, false,
                            true, false, false, false)
                        DrawText3D(vec.x, vec.y, vec.z, "press e")
                        if IsControlJustPressed(0, Config.MenuKey) then
                            OpenMenu('main', 'employees')
                            loadPlayerInventory()
                            loadPlayerVault()
                        end
                    end
                end
                Wait(cd)
            end
        end)
    end
end

RegisterCommand(Config.AdminMenuCommand, function()
    local isAdmin = TriggerCallback("mBossmenu:checkIsAdmin")
    if isAdmin then
        OpenMenu('admin', 'adminlist')
    else
        Config.Notify(locales.no_permission_2)
    end
end)