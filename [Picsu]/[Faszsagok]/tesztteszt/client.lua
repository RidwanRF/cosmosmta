setElementData(localPlayer, "hasBox", false)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k,v in ipairs(getElementsByType("vehicle")) do
			if getElementModel(v) == 422 then
				setElementData(v,"train.boxinplato",false)
			end
		end
    end
)

local lerako = dxCreateTexture("lerako.png")

x,y,z = 1507.66479, -1748.73694, 13.54688

size = 5


addEventHandler("onClientRender", root, function()
	kocak = dxDrawMaterialLine3D(1507.84692-0.3, -1752.47925, 13.54688-0.95, 1507.84692-0.3, -1745.05432+1, 13.54688-0.95, lerako, size,tocolor(255, 255, 255, 255), x, y, z+90)
end)