local jelvenyData = {
    --id = {fraki id, rövid neve};
    [1] = {1,"LSPD"},
    [2] = {3,"FBI"},
    [3] = {58,"SASD"},
    [4] = {57,"SWAT"},
}
function addJelveny(player,command,fid,...)
	if exports.cosmo_groups:isPlayerHavePermission(player, "cuff") then
		if not fid or not tonumber(fid) or not ... then 
			outputChatBox("#ff9428[CosmoMTA - Jelvény]#FFFFFF ".."/"..command.." [Tipus] [Szöveg]",player,255,255,255,true);
			outputChatBox("#ff9428[CosmoMTA - Jelvény]#FFFFFF Tipusok: \n #32b3ef1 #FFFFFF- LSPD | #32b3ef2 #FFFFFF- FBI | #32b3ef3 #FFFFFF- SASD | #32b3ef4 #FFFFFF- SWAT |",player,255,255,255,true);
		   -- local types = "";
			--for k,v in pairs(jelvenyData) do 
				--types = types .. "  #32b3ef" ..k.. "#FFFFFF - "..v[2].." | ";
			--end
			--outputChatBox(types,player,255,255,255,true);
		   -- return;
		end
		local fid = math.floor(tonumber(fid));
		local text = table.concat({...}," ");
		if exports.cosmo_groups:isPlayerLeaderInGroup(player, jelvenyData[fid][1]) then
			local jelvenyText = jelvenyData[fid][2].." "..text;
			exports.cosmo_inventory:giveItem(player,86,1,jelvenyData[fid][2],text,text)
			outputChatBox("#ff9428[Jelvény]#FFFFFF Sikeresen létrehoztál egy jelvényt!",player,255,255,255,true)
		else 
			outputChatBox("#ff9428[Jelvény]#FFFFFF Nincs jogosultságod a parancs használatához!",player,255,255,255,true)
		end
	end	
end
addCommandHandler("addjelveny",addJelveny,false,false);

con = exports.cosmo_database:getConnection()

function alnev(thePlayer, commandName, state, ...)
	if exports.cosmo_groups:isPlayerHavePermission(thePlayer, "cuff") then
		
		if not (state) then
			outputChatBox("#ff9428[CosmoMTA]:#ffffff /" .. commandName .. " [be/ki] [Új_Név]", thePlayer, 255, 255, 255, true)
		else
		
			local state = tostring(state)
			local name = table.concat({...}, " "):gsub("_"," ")
			local qh = dbQuery(con, "SELECT * FROM characters WHERE name='" .. name .. "'")
			local result, num = dbPoll(qh, -1)
			if num > 0 then outputChatBox("#dc143c[Hiba]:#ffffff Már van ilyen név.", thePlayer, 255, 255, 255, true) return end
			
			for _, value in ipairs(getElementsByType("player")) do 
				if getElementData(value, "char.Name") == name then outputChatBox("#dc143c[Hiba]:#ffffff Már van ilyen név.", thePlayer, 255, 255, 255, true) return end
			end
			
			if state == "be" then
				if getElementData(thePlayer, "char:oldNev") then outputChatBox("#dc143c[Hiba]:#ffffff Már viselsz álnevet.", thePlayer, 255, 255, 255, true) return end
				if not (name) then
					outputChatBox("#ff9428[CosmoMTA]:#ffffff /" .. commandName .. " [be/ki] [Új_Név]", thePlayer, 255, 255, 255, true)
				else
					setElementData(thePlayer, "char:oldNev", getElementData(thePlayer, "char.Name"))
					setElementData(thePlayer, "char.Name", name)
                    setElementData(thePlayer, "visibleName", name)
					setPlayerName(thePlayer, name:gsub(" ", "_"))
						exports.cosmo_core:sendMessageToAdmins("#ff9428" .. getElementData(thePlayer, "char:oldNev"):gsub("_"," ") .. "#ffffff nevet váltott. Új név: #ff9428" .. name .. "#ffffff.")
				end
			elseif state == "ki" then
				if not getElementData(thePlayer, "char:oldNev") then outputChatBox("#dc143c[Hiba]:#ffffff Még nem viselsz álnevet.", thePlayer, 255, 255, 255, true) return end
				
				setElementData(thePlayer, "char.Name", getElementData(thePlayer, "char:oldNev"))
                setElementData(thePlayer, "visibleName", getElementData(thePlayer, "char:oldNev"))
				setPlayerName(thePlayer, getElementData(thePlayer, "char:oldNev"):gsub(" ","_"))
				exports.cosmo_core:sendMessageToAdmins("#ff9428" .. getElementData(thePlayer, "char:oldNev") .. "#ffffff kikapcsolta az álnevet.")

				setElementData(thePlayer, "char:oldNev", false)
			end
		end
	end
end
addCommandHandler("álnév", alnev, false, false)
addCommandHandler("alnev", alnev, false, false)

addCommandHandler("szerel", function(sourcePlayer, commandName, targetPlayer)
	if exports.cosmo_groups:isPlayerInGroup(sourcePlayer, 105) then
		if not targetPlayer then
			outputUsageText(commandName, "[Játékos név / ID]", sourcePlayer)
		else
			targetPlayer = exports.cosmo_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				if isPedInVehicle(targetPlayer) then
					local theVehicle = getPedOccupiedVehicle(targetPlayer)
					local vehicleId = getElementData(theVehicle, "vehicle.dbID") or "Ideiglenes"

					fixVehicle(theVehicle)
					setVehicleDamageProof(theVehicle, false)
				   
				else
					outputErrorText("A kiválasztott játékos nem ül járműben.", sourcePlayer)
				end
			end
		end
	end
end)

addCommandHandler("felszed",
	function (sourcePlayer, cmd, target)
		if exports.cosmo_groups:isPlayerInGroup(sourcePlayer, 105) then
			if not target then
				outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Játékos név / ID]", sourcePlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetPlayerName = exports.cosmo_core:findPlayer(sourcePlayer, target)

				if targetPlayer then
					if getElementHealth(targetPlayer) <= 20 or isPedDead(targetPlayer) then
						local playerPosX, playerPosY, playerPosZ = getElementPosition(targetPlayer)
						local playerInterior = getElementInterior(targetPlayer)
						local playerDimension = getElementDimension(targetPlayer)
						local playerSkin = getElementModel(targetPlayer)

						spawnPlayer(targetPlayer, playerPosX, playerPosY, playerPosZ, getPedRotation(targetPlayer), playerSkin, playerInterior, playerDimension)
						healPlayer(targetPlayer)
						setPedAnimation(targetPlayer)
						setCameraTarget(targetPlayer, targetPlayer)
					else
						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A kiválasztott játékos nem ájult és/vagy nincs meghalva.", sourcePlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end
)

addCommandHandler("heal",
	function (sourcePlayer, cmd, target)
		if exports.cosmo_groups:isPlayerInGroup(sourcePlayer, 52) then
			if not target then
				outputChatBox(exports.cosmo_core:getServerTag("usage") .. "/" .. cmd .. " [Játékos név / ID]", sourcePlayer, 0, 0, 0, true)
			else
				local targetPlayer, targetPlayerName = exports.cosmo_core:findPlayer(sourcePlayer, target)

				if targetPlayer then
					if isPedDead(targetPlayer) then
						outputChatBox(exports.cosmo_core:getServerTag("admin") .. "A kiválasztott játékos halott!", sourcePlayer, 0, 0, 0, true)
					else
						healPlayer(targetPlayer)
						setPedAnimation(targetPlayer)
						setCameraTarget(targetPlayer, targetPlayer)
                    					
                    end
				end
			end
		end
	end
)

function healPlayer(playerElement)
	if isElement(playerElement) then
		setElementHealth(playerElement, 100)
		setElementData(playerElement, "isPlayerDeath", false)
		setElementData(playerElement, "bulletDamages", false)
		setElementData(playerElement, "char.bone", {true, true, true, true, true})
		setElementData(playerElement, "bloodLevel", 100)
		setElementData(playerElement, "deathReason", false)
		setElementData(playerElement, "customDeath", false)
		setElementData(playerElement, "char.Hunger", 100)
		setElementData(playerElement, "char.Thirst", 100)
	end
end

function changeLock(thePlayer, commandName)
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then return end
	local groupID = getElementData(vehicle, "vehicle.group") or 0
	if exports.cosmo_groups:isPlayerLeaderInGroup(thePlayer, groupID) then
		local vehID = getElementData(vehicle, "vehicle.dbID")
		if vehID then
			local playerGroups = exports.cosmo_groups:getPlayerGroups(thePlayer)
			local groupID = tonumber(groupID)
			local name = getElementData(thePlayer, "visibleName")
			exports.cosmo_inventory:giveItem(thePlayer, 2, 1, vehID)
			outputChatBox("#ff9428[CosmoMTA - Changelock]#FFFFFF Sikeres kulcs másolás.",thePlayer,255,255,255,true)
		end
	else
		exports.cosmo_hud:showInfobox(thePlayer, "error", "Nincs jogosultságod a parancs ilyen felhasználatához!")
	end
end
addCommandHandler("changelock", changeLock, false, false)

function adminChangeLock(thePlayer, commandName)
	if tonumber(getElementData(thePlayer, "acc.adminLevel") or 0) >= 5 then
		if isPedInVehicle(thePlayer) then
			local veh = getPedOccupiedVehicle(thePlayer)
			if veh then
				local vehid = getElementData(veh, "vehicle.dbID")
				local adutyname = getElementData(thePlayer, "acc.adminNick")
				if vehid > 0 then
					exports.cosmo_inventory:giveItem(thePlayer, 2, 1, vehid)
					outputChatBox("#ff9428[CosmoMTA - Changelock]#FFFFFF Sikeres kulcs másolás.",thePlayer,255,255,255,true)
					exports.cosmo_core:sendMessageToAdmins(adutyname .." Lemásolta a(z) " .. vehid .. " azonosítóval rendelkező jármű kulcsát.", 6)
				end
			end
		end
	end
end
addCommandHandler("achangelock", adminChangeLock, false, false)

--function lefoglal(player,command)
	--if exports.cosmo_groups:isPlayerHavePermission(player, "impoundVehicle") or exports.cosmo_groups:isPlayerHavePermission(player, "cuff") then
		--local px, py, pz = getElementPosition(player)
	
		--for k, v in ipairs(getElementsByType("vehicle")) do 
			--vx, vy, vz = getElementPosition(v)
			--local dist = getDistanceBetweenPoints3D ( px, py, pz, vx, vy, vz )
			--if dist <= 5 then
				--kocsiid = getElementData(v, "vehicle.dbID")
				
				--outputChatBox("#ff9428[Lefoglalás]#FFFFFF Sikeresen lefoglaltál egy járművet! Jármű ID: #ff9428"..kocsiid.."",player,255,255,255,true)
				
				--local reason = "Tilosban parkolás"
				--local price = 6000000
				--local impoundedDate = getRealTime().timestamp
				--local expireDate = getRealTime().timestamp + (86400 * 0)
				--local impoundedBy = getElementData(player, "char.ID")

				--triggerEvent("impoundVehiclePicsu", v, player, v, reason, price, true, impoundedDate, expireDate, impoundedBy)
			--end
		--end	
	--end	
--end
--addCommandHandler("lefoglal",lefoglal,false,false);

local connection = false

addEventHandler("onResourceStart", getRootElement(),
    function (startedResource)
        if getResourceName(startedResource) == "cosmo_database" then
            connection = exports.cosmo_database:getConnection()
        elseif source == getResourceRootElement() then
            if getResourceFromName("cosmo_database") and getResourceState(getResourceFromName("cosmo_database")) == "running" then
                connection = exports.cosmo_database:getConnection()
            end
        end
    end
)


function registerEvent(eventName, element, ...)
	addEvent(eventName, true)
	addEventHandler(eventName, element, ...)
end

function impoundVehiclePicsu(player, vehicle, reason, price, canGet, impoundedDate, expiredDate, impoundedBy)
    local impoundText = reason .. "/" .. price .. "/" .. tostring(canGet) .. "/" .. impoundedDate .. "/" .. expiredDate .. "/" .. impoundedBy
    dbExec(connection, "UPDATE vehicles SET impound = ? WHERE vehicleID = ?", impoundText, getElementData(vehicle, "vehicle.dbID"))
    setElementData(vehicle, "vehicle.impound", impoundText)

    for k, v in pairs(getVehicleOccupants(vehicle)) do
        removePedFromVehicle(v)
    end

    setElementDimension(vehicle, 65000)
	setElementPosition(vehicle, 1717.0002441406, -3266.2478027344, -9.4034767150879)
end
registerEvent("impoundVehiclePicsu", root, impoundVehiclePicsu)

local maxCost = 300000000
local before = "#1E8BC3[Büntetés]:#ffffff"
local between = "büntetést"

function ticketPlayer(thePlayer, commandName, targetPlayer, cost, ...)
	if exports.cosmo_groups:isPlayerHavePermission(thePlayer, "ticket") then
		if not (targetPlayer) or not (cost) or not (...) then
			outputChatBox("#ff9428Használat:#ffffff /" ..commandName .. " [Név / ID] [Összeg] [Indok]", thePlayer, 255, 255, 255, true)
		else
			
			local targetPlayer, targetPlayerName = exports.cosmo_core:findPlayer(thePlayer, targetPlayer)
			if targetPlayer == thePlayer then outputChatBox("#dc143c[Hiba]:#ffffff Magadat nem tudod ticketelni.", thePlayer, 255, 255, 255, true) return end
			local cost = tonumber(cost)
			local reason = table.concat({...}, " ")
			
			local x, y, z = getElementPosition(thePlayer)
			local tx, ty, tz = getElementPosition(targetPlayer)
			local int, dim = getElementInterior(thePlayer), getElementDimension(thePlayer)
			local tint, tdim = getElementInterior(targetPlayer), getElementDimension(targetPlayer)
			local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
			
			if cost <= 0 then outputChatBox("#dc143c[Hiba]:#ffffff 0-nál nagyobb összeget kellene megadni.", thePlayer, 255, 255, 255, true) return end
			if maxCost < cost then outputChatBox("#dc143c[Hiba]:#ffffff Az összeg meghaladja a maximális keretet. (" .. maxCost .. "$)", thePlayer, 255, 255, 255, true) return end
			
			if distance <= 4 and int == tint and dim == tdim then
				
				sendGroupMessageWithoutPlayer(thePlayer, factionid, getPlayerName(thePlayer):gsub("_"," ") .. " kiadott egy " .. between .. " " .. targetPlayerName:gsub("_", " ") .. " játékosnak.")
				sendGroupMessageWithoutPlayer(thePlayer, factionid, "Összeg: " .. convertNumber(cost) .. "$")
				sendGroupMessageWithoutPlayer(thePlayer, factionid, "Indok: " .. reason)
				
				outputChatBox(before .. " #ff9428" .. getPlayerName(thePlayer):gsub("_"," ") .. "#ffffff kiadott neked egy " .. between .. ". Összeg: #ff9428" .. convertNumber(cost) .. "$", targetPlayer, 255, 255, 255, true)
				outputChatBox(before .. " Indok: #ff9428" .. reason, targetPlayer, 255, 255, 255, true)
				
				--exports.exg_dashboard:giveGroupBalance(factionid, cost)
				--setElementData(targetPlayer, "char:money", getElementData(targetPlayer, "char:money")-cost)
				triggerEvent("setGroupBalancePicsu", targetPlayer, 1, cost)
				
				outputChatBox(before .. " Kiadtál egy " .. between .. " #ff9428" .. getPlayerName(targetPlayer):gsub("_"," ") .. "#ffffff játékosnak. Összeg: #ff9428" .. convertNumber(cost) .. "$", thePlayer, 255, 255, 255, true)
				outputChatBox(before .. " Indok: #ff9428" .. reason, thePlayer, 255, 255, 255, true)
			else
				outputChatBox("#dc143c[Hiba]:#ffffff Túl messze vagy a játékostól.", thePlayer, 255, 255, 255, true)
			end
		end
	end
end
addCommandHandler("ticket", ticketPlayer, false, false);

local factionNames = {
	[1]="Los Santos Police Department",
	[32]="SWAT",
	[4]="FBI",
}


function sendGroupMessageWithoutPlayer(player, factionid, msg)
	for k, v in ipairs(getElementsByType("player")) do
		if exports.cosmo_groups:isPlayerInGroup(v, factionid) and getPlayerName(v) ~= getPlayerName(player) then
			outputChatBox("#F9BF3B[" .. factionNames[factionid] .. "]#ffffff " .. msg, v, 255, 255, 255, true)
		end
	end
end

function convertNumber(number)  
	local formatted = number;
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2'); 
		if (k==0) then      
			break;
		end  
	end  
	return formatted;
end