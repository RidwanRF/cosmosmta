local placeDoCache = {}

function placeDo(playerSource,cmd,...)
	if getElementData(playerSource,"loggedIn") then
		if getElementData(playerSource,"placedo") > 5 then outputChatBox(exports.fv_engine:getServerSyntax("PlaceDo","red").."Egyszerre lerakott do száma 5! Töröld a jelenlegieket ha szeretnél újat lerakni.",playerSource,255,255,255,true) return end;
		if(...)then
			local message = table.concat({...}, " ")
			if(#message >= 3 and #message <= 50)then
				local x,y,z = getElementPosition(playerSource)
				local dbid = getElementData(playerSource,"acc >> id")
				local name = getElementData(playerSource,"char >> name"):gsub("_", " ") or getPlayerName(playerSource):gsub("_", " ")
				local id = #placeDoCache+1;
				placeDoCache[id] = {
					["x"] = x,
					["y"] = y,
					["z"] = z,
					["owner"] = dbid,
					["ownerName"] = name,
					["message"] = message,
				}
				setTimer(function()
					if placeDoCache[id] then 
						local doOwner = findByAccountID(placeDoCache[id]["owner"]);
						if doOwner then 
							setElementData(doOwner,"placedo",getElementData(doOwner,"placedo") - 1);
						end
						table.remove(placeDoCache,id);
						triggerClientEvent(root,"receivePlaceDo",root,placeDoCache);
					end
				end,1000*60*10,1);
				triggerClientEvent(root,"receivePlaceDo",root,placeDoCache);
				setElementData(playerSource,"placedo",getElementData(playerSource,"placedo") + 1);
				outputChatBox(exports.fv_engine:getServerSyntax("PlaceDo","orange").."Do lerakva, ha nem törlöd 10 perc múlva automatikusan törlésre kerül!",playerSource,255,255,255,true);
			else
				outputChatBox(exports.fv_engine:getServerSyntax("PlaceDo","red").."A szöveg minimum 3, és maximum 50 karakter lehet.", playerSource,61,122,188,true)
			end
		else
			outputChatBox(exports.fv_engine:getServerSyntax("Használat","orange").."/" .. cmd .. " [szöveg]", playerSource,61,122,188,true)
		end
	end
end
addCommandHandler("placedo",placeDo,false,false)

addEvent("deleteMyOnePlaceDo",true)
addEventHandler("deleteMyOnePlaceDo",getRootElement(),function(playerSource,id)
	table.remove(placeDoCache,id);
	triggerClientEvent(root,"receivePlaceDo",root,placeDoCache);
	outputChatBox(exports.fv_engine:getServerSyntax("PlaceDo","orange").."Sikeresen törölve!",playerSource,255,255,255,true);
end);

addEvent("placeDoSync",true)
addEventHandler("placeDoSync",getRootElement(),function(playerSource)
	triggerClientEvent(root,"receivePlaceDo",root,placeDoCache);
end);

function findByAccountID(id)
	local found = false;
	for k, v in pairs(getElementsByType("player")) do 
		if (getElementData(v,"acc >> id") or 0) == id then 
			found = v;
			break;
		end
	end
	return found;
end