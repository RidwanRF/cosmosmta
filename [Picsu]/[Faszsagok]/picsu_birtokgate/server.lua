local garazskapu = createObject(17951,2040.9,-1879.7,14.3)
setElementRotation(garazskapu,0,0,0)
setObjectScale(garazskapu, 1.05)
local ajtonyitva = false

-- <object id="object (cjgaragedoor) (3)" breakable="true" interior="0" alpha="255" model="17951" doublesided="false" scale="1.05" dimension="0" posX="2040.9" posY="-1879.7" posZ="14.3" rotX="0" rotY="0" rotZ="0"></object>

addCommandHandler("gate",
    function(player)
		if getElementData(player, "acc.adminLevel") >= 10 then
			local px, py, pz = getElementPosition(player)
			local x, y, z = getElementPosition(garazskapu)
			local distance = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
			if (distance < 5) then
				if not ajtonyitva then
					moveObject ( garazskapu, 5000, 2040.9,-1879.7,16.1 ,0,90,0)
					triggerClientEvent ( root, "addGarazshang", root)
					setTimer(function()
						ajtonyitva = true
					end, 5000, 1 )
				else
					moveObject ( garazskapu, 5000, 2040.9,-1879.7,14.3,0,-90,0)
					triggerClientEvent ( root, "addGarazshangclose", root)
					setTimer(function()
						ajtonyitva = false
					end, 5000, 1 )
				end
			end	
		end
    end
)