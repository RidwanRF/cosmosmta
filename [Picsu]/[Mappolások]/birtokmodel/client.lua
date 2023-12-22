local modellname = "8462";
local modellID = 8462;

col_floors = engineLoadCOL ( modellname..".col" )
engineReplaceCOL ( col_floors, modellID )
txd_floors = engineLoadTXD ( modellname..".txd" )
engineImportTXD ( txd_floors, modellID )
dff_floors = engineLoadDFF ( modellname..".dff")
engineReplaceModel ( dff_floors, modellID )



