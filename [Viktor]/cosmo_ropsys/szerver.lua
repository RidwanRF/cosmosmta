function startRope(player,dx,dy,dz)
	local x,y,z = getElementPosition(player)
	local prot = getPedRotation(player)
	setPedRotation(player,prot - 180)
	setElementFrozen(player,true)
	setElementPosition(player,dx,dy,dz)
	setElementData(player,"rappelstate","start")
	setElementData(player, "rappelfrom", {x,y,z-0.7, dx,dy,z-0.7})
end

addEvent( "startRope", true )
addEventHandler( "startRope", getRootElement(), function(player, dx,dy,dz) 
	setTimer(startRope,3400,1, player,dx,dy,dz)
end)

function endRope(player,rx,ry,rz)
	setElementPosition(player,rx,ry,rz)
	setElementData(player,"rappeling",false)
	setElementData(player,"rappelstate",false)
	setElementFrozen(player,false)
end

addEvent( "endRope", true )
addEventHandler( "endRope", getRootElement(), function(player,rx,ry,rz) 
	setTimer(endRope,800,1, player,rx,ry,rz)
end)