local modellname = "phouse";
local modellID = 13756;

col_floors = engineLoadCOL ( modellname..".col" )
engineReplaceCOL ( col_floors, modellID )
txd_floors = engineLoadTXD ( modellname..".txd" )
engineImportTXD ( txd_floors, modellID )
dff_floors = engineLoadDFF ( modellname..".dff")
engineReplaceModel ( dff_floors, modellID )

function thaResourceStarting( )
	water = createWater ( 1363.0895996094, -759.52447509766, 89, 1384.5350341797, -759.31536865234, 89, 1370.5909423828, -748.27416992188, 89, 1390.3231201172, -748.54803466797, 89 )
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), thaResourceStarting)