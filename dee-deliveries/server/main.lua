restaurantStocks = {}
Citizen.CreateThread(function()
    if Config.ESX then
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    elseif Config.QBCore then
        QBCore = exports['qb-core']:GetCoreObject()
    end
    PullDeliveriesSQL()
    Wait(250)
    CheckConfig()
end)

RegisterServerEvent('dee-deliveries:server:grabRestaurantStocks', function()
    TriggerClientEvent('dee-deliveries:client:returnRestaurantStocks', source, restaurantStocks)
end)

RegisterServerEvent('dee-deliveries:server:takeStockItem', function(restaurant, item)
    UpdateDeliveries(restaurant, restaurantStocks[restaurant]+1)
    PlayerRemoveItem(source,item, 1)
    TriggerClientEvent('dee-deliveries:client:returnRestaurantStocks', -1, restaurantStocks)
end)

RegisterServerEvent('dee-deliveries:server:giveDeliveryItem', function(restaurant, item)
    UpdateDeliveries(restaurant, restaurantStocks[restaurant]-1)
    PlayerAddItem(source, item, 1)
    TriggerClientEvent('dee-deliveries:client:returnRestaurantStocks', -1, restaurantStocks)
end)

RegisterServerEvent('dee-deliveries:server:finishDelivery', function(data)
    local MONEYREWARDED = math.ceil(Config.MONEYPERDISTANCE*data.distance)
    local BUSINESSCUT = math.ceil((Config.BUSINESSCUT/100)*MONEYREWARDED)
    local PLAYERHASDIRTYMONEY = PlayerServerHasItem(source,Config.DIRTYMONEY,Config.DIRTYMONEYAMOUNT)
    if Config.SECRETREWARD then
        for item, info in pairs(Config.REWARDS) do
            local CHANCENUMBER = math.random(0,10000)
            if CHANCENUMBER <= info.CHANCE*100 then
                PlayerAddItem(source, item, info.AMOUNT)
                if Config.ONESECRETREWARD then
                    break
                end
            end
        end
    end
    BusinessAddMoney(data.restaurantName, BUSINESSCUT)
    PlayerRemoveItem(source,data.restaurant.DELIVERY, 1)
    PlayerAddMoney(source, MONEYREWARDED-BUSINESSCUT)
    if not PLAYERHASDIRTYMONEY then
        return print('Player does not have the required amount of dirty money')
    end
    local CHANCECLEAN = math.random(0,100)
    if CHANCECLEAN <= Config.PERCENTTOCLEAN then
        PlayerRemoveItem(source,Config.DIRTYMONEY, Config.DIRTYMONEYAMOUNT)
        PlayerAddMoney(source,Config.DIRTYMONEYAMOUNT-Config.DIRTYMONEYAMOUNT*(Config.PERCENTLOST/100))
    end
end)

function CheckConfig()
    local newRestaurants = {}
    for restaurant, info in pairs(Config.RESTAURANT) do
        if restaurantStocks[restaurant] == nil then
            restaurantStocks[restaurant] = 0
            newRestaurants[restaurant] = 0      
        end
    end
    if newRestaurants ~= nil then
        InsertDeliveriesSQL(newRestaurants)
    end
end

function PullDeliveriesSQL()
    exports.oxmysql:query('SELECT * FROM `dee-deliveries`',{}, function(result)
        for i=1, #result do
            restaurantStocks[result[i].restaurant] = result[i].stored
        end
    end)
end

--- @param newRestaurants table
function InsertDeliveriesSQL(newRestaurants)
    for restaurant, stock in pairs(newRestaurants) do
        exports.oxmysql:insert('INSERT INTO `dee-deliveries` (`restaurant`, `stored`) VALUES (?,?)',
        {
            restaurant,
            stock,
        }, 
          function()
        end)
    end
end

--- @param restaurant string
--- @param stored number
function UpdateDeliveries(restaurant, stored)
    restaurantStocks[restaurant] = stored
    UpdateDeliveriesSQL(restaurant,stored)
end

--- @param restaurant string
--- @param stored number
function UpdateDeliveriesSQL(restaurant, stored)
    exports.oxmysql:update('UPDATE `dee-deliveries` SET stored = ? WHERE restaurant = ?',{stored,restaurant}, function(affectedRows)
    end)
end

--- @param business string
--- @param amount number
function BusinessAddMoney(business, amount)
    if Config.ESX then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..business, function(account)
			account.addMoney(amount)
		end)
    end
    if Config.QBCore then
        exports['qb-management']:AddMoney(business,amount)
    end
end

--- @param source number
--- @param item string
--- @param amount number
function PlayerServerHasItem(source, item, amount)
    if Config.ox_inventory then
        return exports.ox_inventory:Search(source, 'count',item) >= amount 
    end
    if Config.QbInventory then
        local Player = QBCore.Functions.GetPlayer(source)
        print('Player Has item: '..tostring(QBCore.Functions.HasItem(source,item, amount)))
        return QBCore.Functions.HasItem(source,item, amount)
    end
end

--- @param source number
--- @param amount number
function PlayerAddMoney(source, amount)
    if Config.ox_inventory then
        exports.ox_inventory:AddItem(source,item,amount)
    end
    if Config.QbInventory then
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddMoney('cash',amount)
    end
end

--- @param source number
--- @param item string
--- @param amount number
function PlayerAddItem(source, item, amount)
    if Config.ox_inventory then
        if exports.ox_inventory:CanCarryItem(source, item, amount) then
            exports.ox_inventory:AddItem(source,item,amount)
        else
            print('Player couldnt carry the item so it wasnt given')
        end
    end
    if Config.QbInventory then
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddItem(item,amount)
    end
end

--- @param source number
--- @param item string
--- @param amount number
function PlayerRemoveItem(source, item, amount)
    if Config.ox_inventory then
        exports.ox_inventory:RemoveItem(source,item,amount)
    end
    if Config.QbInventory then
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.RemoveItem(item,amount)
    end
end