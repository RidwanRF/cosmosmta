setElementData(localPlayer, "rappelstate", false)
setElementData(localPlayer,"rappeling",false)

local detecter

local tempPeds = {}

function startRopeDown()
	if(getElementData(localPlayer, "rappeling") ~= true) then
		if isPedOnGround ( localPlayer ) then 
			setElementFrozen(localPlayer, true)
			if isElement(detecter) then destroyElement(detecter) end
			local x,y,z = getElementPosition(localPlayer)
			detecter = createObject(1901,x,y,z)
			setElementAlpha(detecter,0)
			attachElements(detecter,localPlayer,0,0.8,-0.9)

			setElementData(localPlayer,"rappeling",true)

			setTimer(function()
				local dx,dy,dz = getElementPosition(detecter)
				local hx,hy,hz = getPedBonePosition(localPlayer,8)
				if isLineOfSightClear(dx,dy,dz,dx,dy,dz-6) and isLineOfSightClear(dx,dy,dz,hx,hy,hz,true,true,false) then
					triggerServerEvent("startRope",localPlayer,localPlayer, dx,dy,dz)
				else
					setElementData(localPlayer,"rappeling",false)
					setElementFrozen(localPlayer, false)
					if isElement(detecter) then destroyElement(detecter) end
					exports.cosmo_hud:showInfobox("error", "Nem vagy az épület szélén!")
				end
			end,500,1)
		end
	end
end

local streamedPlayers = {}

addEventHandler ( "onClientRender", root, function()
	for v,k in pairs (streamedPlayers) do -- kötél szinkron
		if getElementData(v,"rappelstate") then
			local rx,ry,rz, rx2,ry2,rz2 = unpack(getElementData(v, "rappelfrom"))
			if not isElement(tempPeds[v]) then
				local modelid = getElementModel(v)
				local dx,dy,dz = getElementPosition(v)
				local _,_,prot = getElementRotation(v)
				tempPeds[v] = createPed(modelid,dx,dy,dz)
				setElementAlpha(v, 0)
				setElementData(tempPeds[v], "ropPed", true)
				attachElements(tempPeds[v],v)
				setPedAnimation(tempPeds[v],"ped","abseil",-1)
				setPedRotation(tempPeds[v],prot - 180)
			end
			local bx,by,bz = getPedBonePosition(tempPeds[v],25)
			local bx2,by2,bz2 = getPedBonePosition(tempPeds[v],35)
			if getElementData(v,"rappelstate") == "climbing" then
				local Block, Anim = getPedAnimation(tempPeds[v])
				if Anim ~= "CLIMB_Pull" then
					setPedAnimation(tempPeds[v], false)
					setPedAnimation(tempPeds[v],"ped","CLIMB_Pull",-1)
				end
			end
			dxDrawLine3D(rx,ry,rz,rx2,ry2,rz2,tocolor(0,0,0,255),2,false,0)
			dxDrawLine3D(rx2,ry2,rz2,bx2,by2,bz2,tocolor(0,0,0,255),2,false,0)
			dxDrawLine3D(bx,by,bz,bx2,by2,bz2,tocolor(0,0,0,255),2,false,0)

			setElementFrozen(v,true)
		else
			if isElement( tempPeds[v] ) then 
				destroyElement( tempPeds[v] )
				setElementAlpha(v, 255)
			end
		end
	end
	if getElementData(localPlayer,"rappelstate") then
		local x,y,z = getElementPosition(localPlayer)
		local height = getGroundPosition(x,y,z)

		local rx,ry,rz, rx2,ry2,rz2 = unpack(getElementData(localPlayer, "rappelfrom"))
		local bx,by,bz = getPedBonePosition(localPlayer,25)
		local bx2,by2,bz2 = getPedBonePosition(localPlayer,35)

		--Minimális csúsztatás miután kikerül a játékos a kötélre.
		local startdistance = getDistanceBetweenPoints3D(x,y,z,rx2,ry,rz)
		if getElementData(localPlayer,"rappelstate") == "start" then
			if startdistance < 3 then
				setElementPosition(localPlayer,x,y,z-0.09)
			else
				setElementData(localPlayer,"rappelstate","rappeling")
			end
		end
		--Mozgás
		if getElementData(localPlayer,"rappelstate") == "rappeling" then
			if getKeyState("s") then
				setElementPosition(localPlayer,x,y,z-0.09)
			elseif getKeyState("w") then
				setElementPosition(localPlayer,x,y,z+0.09)
			end
		end
		
		--Felmászás
		local distance2 = getDistanceBetweenPoints3D(x,y,z,rx,ry,rz+0.7)
		if distance2 < 2 and getElementData(localPlayer,"rappelstate") == "rappeling" then
			setElementData(localPlayer,"rappelstate","climbing")
			triggerServerEvent("endRope",localPlayer,localPlayer, rx,ry,rz)
		end
		--Leszállás + igazolja ha a játékos a kötélen van és mozgásra kész.
		local distance = getDistanceBetweenPoints3D(x,y,z,x,y,height)
		if distance > 1 then 
			if not getElementData(localPlayer,"rappel:moving") then
				setElementData(localPlayer,"rappel:moving",true)
			end
		else 
			if getElementData(localPlayer,"rappel:moving") then
				setElementData(localPlayer,"rappel:moving",false)
				setElementData(localPlayer,"rappeling",false)
				setElementData(localPlayer,"rappelstate",false)
				setElementFrozen(localPlayer,false)
			end
		end
	end
end )

addEventHandler ( "onClientElementDataChange", getRootElement(),
function ( dataName )
	if getElementType ( source ) == "player" and dataName == "rappelstate" then
		if getElementData(source,"rappelstate") then
			streamedPlayers[source] = true
		end
	end
end )

addEventHandler( "onClientElementStreamIn", getRootElement( ),
    function ( )
        if getElementType( source ) == "player" then
        	if getElementData(source,"rappelstate") then
            	streamedPlayers[source] = true
            end
        end
    end
);

addEventHandler( "onClientElementStreamOut", getRootElement( ),
    function ( )
        if getElementType( source ) == "player" then
        	if streamedPlayers[source] then
            	streamedPlayers[source] = nil
            end
        end
    end
);