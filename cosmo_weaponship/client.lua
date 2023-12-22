e = exports.cosmo_gate_engine;

local sx,sy = guiGetScreenSize();
local panel = 0;
local clicked = false;

local fegyverek = {
	{9,1},	--Colt-45
	{10,1},	--USP
	{11,1},	--Desert
	{12,1},	--Uzi
	{13,1},	--Tec
	{14,1},	--mp5
	{15,1},	--Ak
	{16,1},	--m4
	{17,1},	--vadász
	{18,1},	--csipa
	{19,1},	--soti
	{20,1},	--rövid
	{21,1},	--spaz
	{30,1},	--Golf
	{31,1},	--kés
	{35,1},	--katana
	{94,1},	--láda
	
	{3,50},	--Colt töli
	{4,50},	--kisgép töli
	{5,50},	--ak töli
	{6,50},	--m4 töli
	{7,50},	--vadász töli
	{8,50},	--sörltes töli
};

local infoPed = createPed(43,2505.099609375, -2640.1318359375, 13.86225605011,-90);
setElementData(infoPed,"ped.name","Fegyverhajós");
setElementData(infoPed,"invulnerable",true);
setElementFrozen(infoPed,true);

addEventHandler("onClientResourceStart",resourceRoot,function()
		e = exports.cosmo_gate_engine;
		icons = e:getFont("AwesomeFont",20);
		font = e:getFont("rage",15);
		font2 = e:getFont("rage",12);
		sColor = {e:getServerColor("red",false)};
		red = {e:getServerColor("red",false)};
		tableRand(fegyverek);
end);

function render()
	local x,y,z = getElementPosition(localPlayer);
	local ox,oy,oz = getElementPosition(clicked);
	local distance = getDistanceBetweenPoints3D(x,y,z,ox,oy,oz);
	if distance > 3 or not clicked or not isElement(clicked) then 
		closePanel();
		outputChatBox(e:getServerSyntax("Fegyverhajó","red").."Mivel eltávolodtál a doboztól, a kifosztás megszakadt.",255,255,255,true);
	end

if panel == 1 then 
	dxDrawRectangle(sx/2-150,sy/2-50,300,150,tocolor(0,0,0,180));
	--dxDrawRectangle(sx/2-153,sy/2-50,3,150,tocolor(sColor[1],sColor[2],sColor[3],180));
	e:shadowedText("CosmoMTA - Fegyverláda",0,sy/2-80,sx,0,tocolor(255,255,255),1,font,"center","top");
	dxDrawText("Kiszeretnéd fosztani a dobozt?",0,sy/2-40,sx,0,tocolor(255,255,255),1,font2,"center","top");

	local yesColor = tocolor(sColor[1],sColor[2],sColor[3],180);
	if e:isInSlot(sx/2-150/2,sy/2,150,30) then 
		yesColor = tocolor(sColor[1],sColor[2],sColor[3]);
	end
	dxDrawRectangle(sx/2-150/2,sy/2,150,30,yesColor);
	dxDrawText("Igen",sx/2-150/2,sy/2,sx/2-150/2+150,sy/2+30,tocolor(255,255,255),1,font,"center","center");

	local noColor = tocolor(red[1],red[2],red[3],180);
	if e:isInSlot(sx/2-150/2,sy/2+50,150,30) then 
		noColor = tocolor(red[1],red[2],red[3]);
	end
	dxDrawRectangle(sx/2-150/2,sy/2+50,150,30,noColor);
	dxDrawText("Nem",sx/2-150/2,sy/2+50,sx/2-150/2+150,sy/2+50+30,tocolor(255,255,255),1,font,"center","center");
end
end

addEventHandler("onClientClick",root,function(button,state,x,y,wx,wy,wz,clickedElement)
	if state == "down" then 
		if clickedElement and clickedElement == infoPed then 
			local x,y,z = getElementPosition(localPlayer);
			local distance = getDistanceBetweenPoints3D(x,y,z,wx,wy,wz);			
			if distance < 3 then 
				if isFaction(localPlayer) then 
					triggerServerEvent("ship.getInfo",localPlayer,localPlayer);
				else 
					outputChatBox(e:getServerSyntax("Fegyverhajó","red").."Csak maffiás beszélgethet vele!",255,255,255,true);
				end
			end
		end

		if clickedElement and getElementData(clickedElement,"ship.box") then
			local x,y,z = getElementPosition(localPlayer);
			local distance = getDistanceBetweenPoints3D(x,y,z,wx,wy,wz);
			if distance < 2 then 
				if isFaction(localPlayer) then 
					if getElementData(clickedElement,"ship.state") then 
						if not (panel > 0) then 
							panel = 1;
							removeEventHandler("onClientRender",root,render);
							addEventHandler("onClientRender",root,render);
							clicked = clickedElement;
						end 
					else 
						outputChatBox(e:getServerSyntax("Fegyverhajó","red").."Ezt a dobozt már kifosztották.",255,255,255,true);
					end
				else 
					outputChatBox(e:getServerSyntax("Fegyverhajó","red").."Csak maffiás nyithatja ki a dobozt.",255,255,255,true);
				end
			end
		end
	end
end);
addEvent("onSuccessBoxOpen",true)
addEventHandler("onSuccessBoxOpen",root,function()
	openBox();
end)

addEvent("onFailedBoxOpen",true)
addEventHandler("onFailedBoxOpen",root,function()
	gameOver();
end)
addEventHandler("onClientKey",root,function(button,state)
	if panel == 1 then 
		if e:isInSlot(sx/2-150/2,sy/2,150,30) then --Igen
			panel = 0;
			exports.cosmo_minigames:startMinigame("balance", "onSuccessBoxOpen", "onFailedBoxOpen", 2, 20000)
			setElementData(clicked,"ship.state",false);
		end
		if e:isInSlot(sx/2-150/2,sy/2+50,150,30) then --Nem
			closePanel();
		end
	end
end);

function closePanel()
	removeEventHandler("onClientRender",root,render);
	panel = 0;

	if panel > 1 then 
		if isElement(clicked) then 
			setElementData(clicked,"ship.state",false);
			triggerServerEvent("ship.destroy",localPlayer,localPlayer,clicked);
		end
	end
	clicked = false;
end

function gameOver()
	triggerServerEvent("ship.destroy",localPlayer,localPlayer,clicked);
	outputChatBox(e:getServerSyntax("Fegyverhajó","red").."Elrontottad a láda kinyitását.",255,255,255,true);
	closePanel();
end

function openBox()
	tableRand(fegyverek);
	triggerServerEvent("ship.giveItems",localPlayer,localPlayer,clicked,fegyverek);
	closePanel();
end