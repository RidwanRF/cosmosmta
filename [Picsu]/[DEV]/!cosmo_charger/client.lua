local modellname = "sc";
local modellID = 7648;

txd_floors = engineLoadTXD ( modellname..".txd" )
engineImportTXD ( txd_floors, modellID )
dff_floors = engineLoadDFF ( modellname..".dff")
engineReplaceModel ( dff_floors, modellID )

addEventHandler("onClientRender",root,
	function()
		for k,v in ipairs(getElementsByType("vehicle")) do
			local id = getElementModel ( v )
			if id == 426 then
				if getElementData(v,"danihe->tuning->supercharger") == 1 then
					if not getElementData(v,"chargerInVehicle") then
						triggerServerEvent("chargerInServer", source, source, v)
						print("Charger rárakás")
					end
				end
			end
		end
	end
)