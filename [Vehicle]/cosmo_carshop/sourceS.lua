connection = exports.cosmo_database:getConnection()

for k,v in pairs(carshoppos) do 
    pickup = createPickup(v[1],v[2],v[3],3, 1239)
end 

function pickupHit(thePlayer)
    if not getPedOccupiedVehicle(thePlayer) then 
        cancelEvent()
        triggerClientEvent(thePlayer,"triggerCarshop",thePlayer,thePlayer)
    end
end
addEventHandler("onPickupHit",pickup,pickupHit)

function getVehicleModelInSQL(sourcePlayer,model)
    local source = client
    if model then
        dbQuery(function(qh, sourcePlayer)
	    	local result = dbPoll(qh, 0)[1]	
			if result then
                triggerClientEvent(source, "getServerExportInClient", source, tonumber(result.piece))
            else
                triggerClientEvent(source, "getServerExportInClient", source, -1)
			end
		end, {sourcePlayer}, connection, "SELECT piece from vehicleincarshop WHERE model = ?", model)
    end
end
addEvent("getVehicleModelInSQL",true)
addEventHandler("getVehicleModelInSQL",getRootElement(),getVehicleModelInSQL)

function openCarshop(thePlayer,number)
    setElementDimension(thePlayer,number)
end 
addEvent("openCarshop",true)
addEventHandler("openCarshop",root,openCarshop) 

function quitCarshop(thePlayer)
    setElementDimension(thePlayer,0)
end 
addEvent("quitCarshop",true)
addEventHandler("quitCarshop",root,quitCarshop)

local rand = math.random(1,#spawnpos)
local pos = spawnpos[rand]
local carposition = {pos[1],pos[2],pos[3],0,0,pos[4],0,0}

function buyVehicle(thePlayer,modelID,name,R,G,B,x,y,z,rot,price)
local money = getElementData(thePlayer,"char.Money")
    if money >= price then 
        triggerClientEvent(thePlayer,"triggerQuitAfterSuccessBuy",thePlayer,thePlayer)
        exports.cosmo_hud:showInfobox("success", "Sikeresen vásároltál egy járművet.")
        exports["cosmo_vehicles"]:makeVehicle(modelID,thePlayer,0,carposition,R,G,B,1)
        setElementData(thePlayer,"char.Money",getElementData(thePlayer,"char.Money") - price)
        if modelID then
            dbQuery(function(qh, thePlayer)
                local result = dbPoll(qh, 0)[1]	
                if result then
                    dbExec(connection, "UPDATE vehicleincarshop SET piece = ? WHERE model = ?", tonumber(result.piece)+1, modelID)
                end
            end, {thePlayer}, connection, "SELECT piece from vehicleincarshop WHERE model = ?", modelID)
        end
    else 
        exports.cosmo_hud:showInfobox("error", "Nincs elég péndez a vásárláshoz.",thePlayer)
    end 
end 
addEvent("buyVehicle",true)
addEventHandler("buyVehicle",root,buyVehicle)

function buyVehiclepp(thePlayer,modelID,name,R,G,B,x,y,z,rot,ppprice)
local pp = getElementData(thePlayer,"char.PP")
    if pp >= ppprice then 
        triggerClientEvent(thePlayer,"triggerQuitAfterSuccessBuy",thePlayer,thePlayer)
        exports.cosmo_hud:showInfobox("success", "Sikeresen vásároltál egy járművet.")
        exports["cosmo_vehicles"]:makeVehicle(modelID,thePlayer,0,carposition,R,G,B,1)
        setElementData(thePlayer,"char.PP",getElementData(thePlayer,"char.PP") - ppprice)
    else 
        exports.cosmo_hud:showInfobox("error", "Nincs elég prémiumpontod a vásárláshoz.",thePlayer)
    end 
end 
addEvent("buyVehiclepp",true)
addEventHandler("buyVehiclepp",root,buyVehiclepp)

function buyVehicleColorpp(thePlayer,modelID,name,R,G,B,x,y,z,rot,cppprice)
local money = getElementData(thePlayer,"char.Money")
    if money >= cppprice then 
        triggerClientEvent(thePlayer,"triggerQuitAfterSuccessBuy",thePlayer,thePlayer)
        setElementData(thePlayer,"char.Money",getElementData(thePlayer,"char.Money") - cppprice)
    else 
        exports.cosmo_hud:showInfobox("error", "Nincs elég pénzed a vásárláshoz.",thePlayer)
     end 
end 
addEvent("buyVehicleColorpp",true)
addEventHandler("buyVehicleColorpp",root,buyVehicleColorpp)