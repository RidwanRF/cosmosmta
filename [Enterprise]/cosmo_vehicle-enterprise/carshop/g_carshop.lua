function countVehicleRealPrice(veh)
    --local money = exports.ex_carshop:getVehiclePrice(getElementModel(veh)) or 1000
    local money = exports.nlrp_carshop:getVehicleOriginalPrice(veh) or 1000
    local level1 = tonumber(getElementData(veh, "veh:Level1")) or 0
    local level2 = tonumber(getElementData(veh, "veh:Level2")) or 0
    local level3 = tonumber(getElementData(veh, "veh:Level3")) or 0
    local neonID = tonumber(getElementData(veh, "veh:Neon")) or 0
    local doorType = tonumber(getElementData(veh, "vDoorType")) or 0

    if(level1==1)then
        money = money + 30000000
    elseif(level1==2)then
        money = money + 30000000 + 50000000
    elseif(level1==3)then
        money = money + 30000000 + 50000000 + 80000000
    end

    if(level2==1)then
        money = money + 15000000
    elseif(level2==2)then
        money = money + 15000000 + 20000000
    elseif(level2==3)then
        money = money + 15000000 + 20000000 + 25000000
    end

    if(level3==1)then
        money = money + 5000000
    elseif(level3==2)then
        money = money + 5000000 + 10000000
    elseif(level3==3)then
        money = money + 5000000 + 10000000 + 15000000
    end

    if(neonID>0)then
        money = money + 16000000
    end

    if getElementData(veh, "veh:Chip") or false then
        money = money + 5000000
    end

    if (getElementData(veh, "veh:Noen") or -1) > 0 then
        money = money + 5000000
    end

    if getElementData(veh, "veh:AirRide") or false then
        money = money + 500000
    end

    if doorType == "scissor" then
        money = money + 120000
    end

    local upgrades = getVehicleUpgrades (veh)

    for k, v in ipairs ( upgrades ) do
        if(v == 1010 or v == 1087)then
            money = money + 30000000
        elseif(getVehicleUpgradeSlotName(k) == "Spoiler")then
           money = money + 2000000
        elseif(getVehicleUpgradeSlotName(k) == "Sideskirt")then
           money = money + 1500000
        elseif(getVehicleUpgradeSlotName(k) == "Front Bumper" or getVehicleUpgradeSlotName(k) == "Rear Bumper" or getVehicleUpgradeSlotName(k) == "Front Bullbars" or getVehicleUpgradeSlotName(k) == "Rear Bullbars")then
           money = money + 3000000
        elseif(getVehicleUpgradeSlotName(k) == "Roof")then
           money = money + 2000000
        elseif(getVehicleUpgradeSlotName(k) == "Wheels")then
           money = money + 1000000
        elseif(getVehicleUpgradeSlotName(k) == "Exhaust")then
           money = money + 1500000
        end
    end

    local paintjob = getElementData(veh, "veh:PaintJob") or -1
    if(paintjob > 0)then
        local ptype, pcost = exports.ex_graphics:getPaintJobPrice(getElementModel(veh), paintjob)
        if(pcost ~= 9999999999)then
            if(ptype == "ft")then
                money = money + pcost
            else
                money = money + (pcost * 3000)
            end
        end
    end

    local lightColor = getElementData(veh, "veh:headlightColor")
    if lightColor and type(lightColor) == "table" then
        money = money + 5000000
    end
    
    return money
end

function formatMoney(amount, spacer)
	if not spacer then spacer = "," end
	amount = math.floor(amount)
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1'..spacer):reverse())..right
end