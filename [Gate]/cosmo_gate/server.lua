local sql = exports.cosmo_gate_engine:getConnection(getThisResource());
local white = "#FFFFFF";
local gates = {};

function loadGate(id)
    dbQuery(function(qh)
        local res = dbPoll(qh,0);
        if #res > 0 then 
            for k,v in pairs(res) do 
                local open = fromJSON(v.open);
                local close = fromJSON(v.close);
                local obj = createObject(v.model,close[1],close[2],close[3], close[4],close[5],close[6]);
                setElementInterior(obj,v.interior);
                setElementDimension(obj,v.dimension);

                setElementData(obj,"gate.id",v.id);
                setElementData(obj,"gate.open",open);
                setElementData(obj,"gate.close",close);
                setElementData(obj,"gate.time",v.time*400);
                setElementData(obj,"gate.state","close");
                setElementData(obj,"gate.factionid",v.factionid);
                gates[v.id] = obj;
            end
        end
    end,sql,"SELECT * FROM kapuk WHERE id=?",id);
end

function loadAllGate()
    dbQuery(function(qh)
        local res = dbPoll(qh,0);
        if #res > 0 then 
            local count = 0;
            for k,v in pairs(res) do 
                loadGate(v.id);
                count = count + 1;
            end
            outputDebugString("Gate: "..count.." kapu betöltve.");
        end
    end,sql,"SELECT id FROM kapuk");
end
addEventHandler("onResourceStart",resourceRoot,loadAllGate);

addEvent("gate.create",true);
addEventHandler("gate.create",root,function(player,pos)
    dbQuery(function(qh)
        local res,_,id = dbPoll(qh,0);
        if id > 0 then 
            loadGate(id);
        end
    end,sql,"INSERT INTO kapuk SET open=?, close=?, model=?, interior=?, dimension=?, time=?, factionid=?",toJSON(pos["open"]),toJSON(pos["close"]),tonumber(pos["model"]),tonumber(pos["interior"]),tonumber(pos["dimension"]),tonumber(pos["time"]),0);
end);

function setGateState(id,player)
    if id and gates[id] then 
        local obj = gates[id];
        if getElementData(obj,"gate.state") == "close" then 
            exports.cosmo_chat:sendLocalMeAction(player, "kinyit egy közelben lévő kaput.")
            local x,y,z,rx,ry,rz = unpack(getElementData(obj,"gate.open"));
            local close = getElementData(obj,"gate.close");
            local rotZ = calculateDifferenceBetweenAngles(close[6], rz);
            local rotY = calculateDifferenceBetweenAngles(close[5],ry);
            setElementData(obj,"gate.moving",true);
            if moveObject(obj,getElementData(obj,"gate.time"),x,y,z,rx,rotY,rotZ) then 
                setElementData(obj,"gate.state","open");
                setTimer(function()
                    setElementData(obj,"gate.moving",false);
                end,getElementData(obj,"gate.time")+100,1);
            end
        else 
            exports.cosmo_chat:sendLocalMeAction(player, "bezár egy közelben lévő kaput.")
            local x,y,z,rx,ry,rz = unpack(getElementData(obj,"gate.close"));
            local open = getElementData(obj,"gate.open");
            local rotZ = calculateDifferenceBetweenAngles(open[6], rz);
            local rotY = calculateDifferenceBetweenAngles(open[5],ry);
            setElementData(obj,"gate.moving",true);
            if moveObject(obj,getElementData(obj,"gate.time"),x,y,z,rx,rotY,rotZ) then 
                setElementData(obj,"gate.state","close");
                setTimer(function()
                    setElementData(obj,"gate.moving",false);
                end,getElementData(obj,"gate.time")+100,1);
            end
        end
    end
end

function useGate(player)
	local posX, posY, posZ = getElementPosition(player);
	for k, object in ipairs(getElementsByType("object", getResourceRootElement())) do
		local gateID = getElementData(object, "gate.id");
		if gateID then
			local gX, gY, gZ = getElementPosition(object);
			local distance = getDistanceBetweenPoints3D(posX, posY, posZ, gX, gY, gZ);
            if (distance<=8) then
                if not getElementData(object,"gate.moving") then
                    local item = exports.cosmo_inventory:hasItem(player,96,1,gateID);
                    if exports.cosmo_groups:isPlayerInGroup(player, getElementData(object,"gate.factionid"))  or getElementData(player,"acc.adminLevel") >= 1 and getElementData(player,"adminDuty") or getElementData(player,"acc.adminLevel") > 7 or exports.cosmo_inventory:hasItemWithData(player, 96, "data1", gateID) then
                        print(getElementData(object,"gate.factionid"), exports.cosmo_groups:isPlayerInGroup(player, getElementData(object,"gate.factionid")))
                        setGateState(gateID, player);
                    else 
                        outputChatBox(exports.cosmo_gate_engine
                        :getServerSyntax("Gate","red").."Nincs kulcsod a kapuhoz!",player,255,255,255,true);
                    end
                end
			end
		end
	end
end
addCommandHandler("gate", useGate)

function deleteGate(player,command,id)
    if getElementData(player,"acc.adminLevel") >= 6 then 
        if not id or not tonumber(id) then outputChatBox(exports.cosmo_gate_engine
        :getServerSyntax("Használat","red").."/"..command.." [id]",player,255,255,255,true) return end;
        local id = tonumber(id);
        if gates[id] then 
            local obj = gates[id];
            if obj then 
                destroyElement(obj);
            end
            dbExec(sql,"DELETE FROM kapuk WHERE id=?",id);
            outputChatBox(exports.cosmo_gate_engine
            :getServerSyntax("Gate","servercolor").."Kapu sikeresen törölve! ID: " ..exports.cosmo_gate_engine
        :getServerColor("servercolor",true)..id..white..".",player,255,255,255,true);
        else 
            outputChatBox(exports.cosmo_gate_engine
            :getServerSyntax("Gate","red").."Nincs ilyen gate.",player,255,255,255,true);
        end
    end
end
addCommandHandler("delgate",deleteGate,false,false);
addCommandHandler("deletegate",deleteGate,false,false);

function setgateFactionID(player,cmd,gateid,factionid)
    if getElementData(player,"acc.adminLevel") >= 6 then 
        if not gateid or not factionid then
            outputChatBox("#ff9428[CosmoMTA - Gate]#ffffff: /"..cmd.." [Kapu ID] [Frakció ID]",player,255,255,255,true)
        return
        end
        local kapuid = tonumber(gateid)
        if gates[kapuid] then
            local obj = gates[kapuid]
            if obj then
                local factionid = tonumber(factionid)
                dbExec(sql, "UPDATE kapuk SET factionid = ? WHERE id = ?",factionid,kapuid)
                outputChatBox("#ff9428[CosmoMTA]#ffffff: Sikeresen beállítottad a #ff9428"..kapuid.."#ffffff-es/as kapu frakció idjét #ff9428"..factionid.."#ffffff!",player,255,255,255,true)
            end
        else
            outputChatBox("#dc4949[Hiba]#ffffff: Hibás kapu id!",player,255,255,255,true)
        end
    end
end
addCommandHandler("setgatefaction",setgateFactionID)
addCommandHandler("setfactiongate",setgateFactionID)

function allowFaction(element)
    local found = false;
    for k, v in pairs(alertedFactions) do  
        if getElementData(element,"faction_"..v) then 
            found = true;
            break;
        end
    end
    return found;
end

--UTILS--
function calculateDifferenceBetweenAngles(firstAngle, secondAngle) 
    difference = secondAngle - firstAngle; 
    while (difference < -180) do 
        difference = difference + 360 
    end 
    while (difference > 180) do 
        difference = difference - 360 
    end 
    return difference 
end 
