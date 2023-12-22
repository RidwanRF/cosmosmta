local sql = exports.cosmo_database:getConnection(getThisResource());
local frakik = exports.cosmo_groups:getPlayerGroups(localPlayer) 


function onTrafiHit(thePlayer, Penz)
	setElementData(thePlayer,"char.Money",getElementData(thePlayer, "char.Money") - tonumber(Penz))
	getVehicleDatas(getPedOccupiedVehicle(thePlayer))
end
addEvent("onTrafiHit", true)
addEventHandler("onTrafiHit", getRootElement(), onTrafiHit)

function getVehicleDatas(veh)
	dbQuery(function(qh)
		local res = dbPoll(qh,0);
		if #res > 0 then 
			local vehDatas = {};
			for k,v in pairs(res) do 
				vehDatas[1] = getVehiclePlateText(veh)
				vehDatas[2] = exports.cosmo_mods_veh:getVehicleNameFromModel(getElementModel(veh));
				vehDatas[3] = v.reason;
			end
			local x, y, z = getElementPosition(veh);
			local zoneName = getZoneName(x, y, z)
			for k, v in ipairs(getElementsByType("player")) do


				if exports.cosmo_groups:isPlayerHavePermission(v, "cuff") then
		
		
					outputChatBox ("#F9BF3B[Rendvédelem] #ffffffEgy körözött jármű áthaladt a " ..zoneName .. "-nél lehelyezett traffipax előtt." ,v,255,255,255,true)
					outputChatBox ("#F9BF3B[Rendvédelem] #ffffffInformáció: Típus: ".. vehDatas[2] ,v,255,255,255,true)
					outputChatBox ("#F9BF3B[Rendvédelem] #ffffffInformáció: Rendszám: ".. vehDatas[1] ,v,255,255,255,true)
					outputChatBox ("#F9BF3B[Rendvédelem] #ffffffInformáció: Körözési indok: ".. vehDatas[3] ,v,220,220,220,true)
					--outputChatBox (">> Információ: Körözési indok ".. vehDatas[3] ,v,220,220,220)
				end
			end
			attachBlipToPolice(getVehicleController(veh));
		end
	end,sql,"SELECT * FROM mdcwantedcars WHERE numberplate = ?",getVehiclePlateText(veh));
end

function attachBlipToPolice(player)
	for i,v in ipairs(getElementsByType("player")) do
		if exports.cosmo_groups:isPlayerHavePermission(v, "cuff") then
			triggerClientEvent(v, "getBlipFromWantedVehicle", v, player)
		end
	end
end

