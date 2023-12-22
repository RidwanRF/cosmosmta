local modellname = "pump";
local modellID = 3465;

col_floors = engineLoadCOL ( modellname..".col" )
engineReplaceCOL ( col_floors, modellID )
txd_floors = engineLoadTXD ( modellname..".txd" )
engineImportTXD ( txd_floors, modellID )
dff_floors = engineLoadDFF ( modellname..".dff")
engineReplaceModel ( dff_floors, modellID )

txd_floors1 = engineLoadTXD ("pumppistol.txd" )
engineImportTXD ( txd_floors1, 330 )
dff_floors1 = engineLoadDFF ("pumppistol.dff")
engineReplaceModel ( dff_floors1, 330 )

col_floors2 = engineLoadCOL ( "fuelprices.col" )
engineReplaceCOL ( col_floors2, 8246 )
txd_floors2 = engineLoadTXD ( "fuelprices.txd" )
engineImportTXD ( txd_floors2, 8246 )
dff_floors2 = engineLoadDFF ( "fuelprices.dff")
engineReplaceModel ( dff_floors2, 8246 )



