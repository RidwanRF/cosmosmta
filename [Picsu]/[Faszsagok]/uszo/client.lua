local modellname = "uszo";
local modellID = 1974;

txd_floors = engineLoadTXD ( modellname..".txd" )
engineImportTXD ( txd_floors, modellID )
dff_floors = engineLoadDFF ( modellname..".dff")
engineReplaceModel ( dff_floors, modellID )



