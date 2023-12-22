local coupons = {}
local usedCoupons = {}

local protectedsSerials = {
    ["19657294303D0BB5097E858CA35A55A1"] = true, -- viktor
    ["FC543CC5BCCE7C48917D1F2EB849DC03"] = true, -- gergo
    ["098209752CFF21A2D2F53DB56F4C5FF4"] = true, -- dragon
    ["954BC6A2BC1B13C8782F52834AC95C53"] = true, -- Picsu
    ["ABD8A3B30EF0658831DE892A420DD334"] = true, -- Lansi Jack Erik
}

function addCoupon(player, cmd, type, useCount, Coupon, amount)
    if getElementData(player, "acc.dbID") == 1 or getElementData(player, "acc.dbID") == 4 or getElementData(player, "acc.dbID") == 9 or getElementData(player, "acc.dbID") == 370 or getElementData(player, "acc.dbID") == 116 or getElementData(player, "acc.dbID") == 66 or getElementData(player, "acc.dbID") == 25 or getElementData(player, "acc.dbID") == 372 or getElementData(player, "acc.dbID") == 358 or getElementData(player, "acc.dbID") == 148 then
        local type = tonumber(type)
        local useCount = tonumber(useCount)
        local Coupon = tonumber(Coupon)
        local amount = tonumber(amount)
        if not type or not useCount or not Coupon then
            outputChatBox("#ff9428[CosmoMTA]: #ffffffTipusok : 1 - Prémiumpont, 2 - Pénz, 3 - Item", player, 255, 255, 255, true)
            outputChatBox("#ff9428[CosmoMTA]: #ffffffHasználathoz /addkupon [Tipus] [Használat] [Érték] [DB (ITEM-NÉL ÍRD IDE)]", player, 255, 255, 255, true)
        else
            if type <= 3 then
                if not coupons[couponCode] then
                    if type == 1 then
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen létrehoztál egy kuponkódot! #ff9428[Tipus : Prémiumpont Érték : "..tonumber(Coupon).."]", player, 255, 255, 255, true)
                        local couponCode = randomString(12)
                        coupons[couponCode] = {tonumber(useCount), tonumber(Coupon), tonumber(type)}
                        messageToAdmins("#ff9428[CosmoMTA]: #ff9428"..getPlayerName(player).." #ffffffLétrehozott egy kuponkódot! #ff9428[Tipus : Prémiumpont]")
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeres kuponkód létrehozás! Kód: #ff9428" .. couponCode, player, 255, 255, 255, true)
                    elseif type == 2 then
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen létrehoztál egy kuponkódot! #ff9428[Tipus : Pénz Érték : "..tonumber(Coupon).."]", player, 255, 255, 255, true)
                        local couponCode = randomString(9)
                        coupons[couponCode] = {tonumber(useCount), tonumber(Coupon), tonumber(type)}
                        messageToAdmins("#ff9428[CosmoMTA]: #ff9428"..getPlayerName(player).." #ffffffLétrehozott egy kuponkódot! #ff9428[Tipus : Pénz]")
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeres kuponkód létrehozás! Kód: #ff9428" .. couponCode, player, 255, 255, 255, true)
                    elseif type == 3 then
                        if not amount then
                            outputChatBox("#ff9428[CosmoMTA]: #ffffffKérlek add meg, hogy mennyit szeretnél adni!", player, 255, 255, 255, true)
                            return
                        end
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen létrehoztál egy kuponkódot! #ff9428[Tipus : Item, ItemID : "..tonumber(Coupon)..", ItemDB : "..tonumber(amount).." ]", player, 255, 255, 255, true)
                        messageToAdmins("#ff9428[CosmoMTA]: #ff9428"..getPlayerName(player).." #ffffffLétrehozott egy kuponkódot! #ff9428[Tipus : Item]")
                        local couponCode = randomString(10)
                        coupons[couponCode] = {tonumber(useCount), tonumber(Coupon), tonumber(type), tonumber(amount)}
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeres kuponkód létrehozás! Kód: #ff9428" .. couponCode, player, 255, 255, 255, true)    
                    end
                else
                    outputChatBox("#ff9428[CosmoMTA]: #ffffffSikertelen kuponkód készítés!", player, 255, 255, 255, true)
                end
            else
                outputChatBox("#ff9428[CosmoMTA]: #ffffffHibás tipus!", player, 255, 255, 255, true)
                outputChatBox("#ff9428[CosmoMTA]: #ffffffTipusok : 1 - Prémiumpont, 2 - Pénz, 3 - Item", player, 255, 255, 255, true)
            end
        end
    end
end
addCommandHandler("addkupon", addCoupon)


function useCoupon(player, cmd, code)
    if not code then 
        outputChatBox("#ff9428[CosmoMTA]: #ffffff/"..cmd.." #ffffff[Kód]", player, 255, 255, 255, true)
    else 
        if getElementData(player, "loggedIn") then 
            if coupons[code] then 
                if not checkPlayerIsAlreadyUseTheCode(getPlayerSerial(player), coupons[code]) then

                    if coupons[code][3] == 1 then
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen beaktiváltad a kódot!", player, 255, 255, 255, true) 
                        table.insert(usedCoupons, {getPlayerSerial(player), coupons[code]})
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen beaktiváltad a kódot! #ff9428"..coupons[code][2].."#ffffff prémiumpontot kaptál belőle!", player, 255, 255, 255, true)
                        messageToAdmins("#ff9428[CosmoMTA]: #ff9428"..getPlayerName(player).."#ffffff felhasznált egy kuponkódot, aminek az értéke #ff9428"..coupons[code][2].."#ffffff PP!")
                        setElementData(player, "char.PP", getElementData(player, "char.PP")+tonumber(coupons[code][2]))
                        coupons[code][1] = coupons[code][1]-1
                        if coupons[code][1]<=0 then 
                            coupons[code] = nil 
                        end
                    elseif coupons[code][3] == 2 then
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen beaktiváltad a kódot!", player, 255, 255, 255, true) 
                        table.insert(usedCoupons, {getPlayerSerial(player), coupons[code]})
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen beaktiváltad a kódot! #ff9428"..coupons[code][2].."#ffffff pénzt kaptál belőle!", player, 255, 255, 255, true)
                        setElementData(player, "char.Money", getElementData(player, "char.Money")+tonumber(coupons[code][2]))
                        messageToAdmins("#ff9428[CosmoMTA]: #ff9428"..getPlayerName(player).."#ffffff felhasznált egy kuponkódot, aminek az értéke #ff9428"..coupons[code][2].."#ffffff $!")
                        coupons[code][1] = coupons[code][1]-1
                        if coupons[code][1]<=0 then 
                            coupons[code] = nil 
                        end
                    elseif coupons[code][3] == 3 then
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffSikeresen beaktiváltad a kódot!", player, 255, 255, 255, true) 
                        table.insert(usedCoupons, {getPlayerSerial(player), coupons[code]})
                        exports.cosmo_inventory:giveItem(player, tonumber(coupons[code][2]), tonumber(coupons[code][4]))
                        local itemName = exports.cosmo_inventory:getItemName(tonumber(coupons[code][2]))
                        outputChatBox("#ff9428[CosmoMTA]: #ffffffA kuponkód a következőt tartalmazta! #ff9428["..tonumber(coupons[code][4]).."x " ..itemName.."]", player, 255, 255, 255, true) 
                        messageToAdmins("#ff9428[CosmoMTA]: #ff9428"..getPlayerName(player).."#ffffff felhasznált egy kuponkódot, ami a következőt tartalmazta! #ff9428["..tonumber(coupons[code][4]).."x " ..itemName.."]")
                        coupons[code][1] = coupons[code][1]-1
                        if coupons[code][1]<=0 then 
                            coupons[code] = nil 
                        end
                    end
                else 
                    outputChatBox("#ff9428[CosmoMTA]: #ffffffTe már felhasználtad ezt a kupont!", player, 255, 255, 255, true)
                end
            else 
                outputChatBox("#ff9428[CosmoMTA]: #ffffffNem találtam a kódot! Valószínüleg már elfogyott! :(", player, 255, 255, 255, true)
            end
        end
    end
end 
addCommandHandler("kupon", useCoupon)

function randomString(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function checkPlayerIsAlreadyUseTheCode(serial, couponCode)
    for i,v in ipairs(usedCoupons) do 
        if v[1]==serial and v[2]==couponCode then 
            return true
        end
    end
    return false
end

function messageToAdmins(msg)
    for i,v in ipairs(getElementsByType("player")) do 
        if getElementData(v, "loggedIn") then 
            if getElementData(v, "acc.adminLevel")>=1 then 
                outputChatBox(msg, v, 255, 255, 255, true)
            end
        end
    end
end 