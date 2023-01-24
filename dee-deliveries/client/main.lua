local scriptobjects = {}
local targets = {}
local onDelivery = false
local restaurantStocks = {}

Citizen.CreateThread(function()
    if Config.ESX == true then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
    
        Player = ESX.GetPlayerData()
    elseif Config.QBCore then
        QBCore = exports['qb-core']:GetCoreObject()
        Player = QBCore.Functions.GetPlayerData()
    end
    GrabRestaurantsStocks()
    SpawnTargets()
    while true do 
        Wait(500)
        for restaurantName, restaurant in pairs(Config.RESTAURANT) do
            SpawnObjects(restaurant.PROPS)
        end
    end
end)

-- props = send it a table of props with names and COORDS
function SpawnObjects(props)
    local playerCoords = GetEntityCoords(PlayerPedId())

    for i=1, #props, 1 do
        local distance = GetDistanceBetweenCoords(playerCoords, props[i].COORDS, true)
        if distance <= 10 then
            local object = GetClosestObjectOfType(props[i].COORDS.x,props[i].COORDS.y,props[i].COORDS.z, 5.0, GetHashKey(props[i].PROP), false, false, false)
            if not DoesEntityExist(object) then
                local object = CreateObject(GetHashKey(props[i].PROP),props[i].COORDS.x,props[i].COORDS.y,props[i].COORDS.z, 1, 1, 0)
                PlaceObjectOnGroundProperly(object)
                FreezeEntityPosition(object, true)
                SetEntityHeading(object, props[i].COORDS.w)

                table.insert(scriptobjects, object)
            end
        end
    end
end

-- Spawns Polyzones for thirdeye and adds targets to a table
function SpawnTargets()
    for restaurantName, restaurant in pairs(Config.RESTAURANT) do
        for i=1, #restaurant.PROPS, 1 do
            exports[Config.THIRDEYE]:AddBoxZone(restaurantName..'prop'..i, vector3(restaurant.PROPS[i].COORDS.x,restaurant.PROPS[i].COORDS.y,restaurant.PROPS[i].COORDS.z), 1.00, 1.00, {
                name= restaurantName..'prop'..i,
                heading=restaurant.PROPS[i].COORDS.w,
                debugPoly=true,
                minZ=restaurant.PROPS[i].COORDS.z-1,
                maxZ=restaurant.PROPS[i].COORDS.z+1,
                }, {
                    options = {
                        {
                            label = restaurant.TARGET.LABEL,
                            icon = restaurant.TARGET.ICON,
                            event = 'dee-deliveries:client:startDeliveryCheck',
                            restaurant = restaurant,
                            restaurantName = restaurantName,
                        },
                        {
                            label = 'Stock Delivery',
                            icon = restaurant.TARGET.ICON,
                            event = 'dee-deliveries:client:stockDeliveryCheck',
                            restaurant = restaurant,
                            restaurantName = restaurantName,
                            job = restaurant.JOB
                        }
                    },
                    distance = 3.5
            })
            table.insert(targets,restaurantName..'prop'..i)
        end
    end   
end

function GrabRestaurantsStocks()
    TriggerServerEvent('dee-deliveries:server:grabRestaurantStocks')
end

RegisterNetEvent('dee-deliveries:client:returnRestaurantStocks') 
AddEventHandler('dee-deliveries:client:returnRestaurantStocks', function(data)
    restaurantStocks = data
end)

RegisterNetEvent('dee-deliveries:client:stockDeliveryCheck', function(data)
    if not PlayerClientHasItem(data.restaurant.STOCK, 1) then
        return print('Player does not have the required item')
    end

    TriggerServerEvent('dee-deliveries:server:takeStockItem', data.restaurantName, data.restaurant.STOCK)
end)

RegisterNetEvent('dee-deliveries:client:startDeliveryCheck', function(data)
    if restaurantStocks[data.restaurantName] <= 0 then
        return print('Restaurant doesnt have the stock required')
    end

    if onDelivery then
        return print('Player is on a delivery')
    end

    TriggerServerEvent('dee-deliveries:server:giveDeliveryItem',data.restaurantName ,data.restaurant.DELIVERY)
    TriggerEvent('dee-deliveries:client:startDelivery', data.restaurantName, data.restaurant)
end)

--- @param item string
--- @param amount number
function PlayerClientHasItem(item, amount)
    if Config.ox_inventory then
        return exports.ox_inventory:Search('count', item) >= amount
    end
    if Config.QbInventory then
        return QBCore.Functions.HasItem(item, amount)
    end
end

RegisterNetEvent('dee-deliveries:client:startDelivery', function(restaurantName, restaurant)
    local locations = {}
    onDelivery = true
    if restaurant.LOCATIONS[1] ~= nil then
        locations = restaurant.LOCATIONS
    else
        locations = Config.DEFAULTLOCATIONS
    end

    local location = math.random(#locations)

    --Creating the blip
    info = AddBlipForCoord(locations[location])
    SetBlipSprite(info, 280)
    SetBlipDisplay(info, 4)
    SetBlipScale(info, 0.8)
    SetBlipColour(info, 4)
    SetBlipAsShortRange(info, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Delivery Dropoff')
    EndTextCommandSetBlipName(info)
    SetNewWaypoint(locations[location])

    local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),locations[location]) 

    exports[Config.THIRDEYE]:AddBoxZone(restaurantName..'DeliveryDropOff'..location, vector3(locations[location].x,locations[location].y,locations[location].z), 1.00, 1.00, {
        name= restaurantName..'DeliveryDropOff'..location,
        heading=locations[location].w,
        debugPoly=true,
        minZ=locations[location].z-1,
        maxZ=locations[location].z+1,
        }, {
            options = {
                {
                    label = 'Delivery Dropoff',
                    icon = restaurant.TARGET.ICON,
                    event = 'dee-deliveries:client:dropOffCheck',
                    restaurant = restaurant,
                    restaurantName = restaurantName,
                    distance = distance,
                    blip = info,
                    target = restaurantName..'DeliveryDropOff'..location
                }
            },
            distance = 3.5
    })
    table.insert(targets,restaurantName..'DeliveryDropOff'..location)
end)

RegisterNetEvent('dee-deliveries:client:dropOffCheck', function(data)
    local hasItemRequired = PlayerClientHasItem(data.restaurant.DELIVERY,1)
    if not onDelivery then
        return print('Player is not on a delivery')
    end
    if DoesBlipExist(data.blip) then
        RemoveBlip(data.blip)
    end
    if not hasItemRequired then
        return print("Player doesn't have the item required for the delivery")
    end

    onDelivery = false
    exports[Config.THIRDEYE]:RemoveZone(data.target)
    TriggerServerEvent('dee-deliveries:server:finishDelivery', data)

end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        for i=1, #scriptobjects, 1 do
            DeleteObject(scriptobjects[i])
        end
        for k, v in pairs(targets) do
            exports[Config.THIRDEYE]:RemoveZone(v)
        end
	end
end)