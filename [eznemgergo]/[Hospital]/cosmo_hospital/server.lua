function replaceModel()

txd = engineLoadTXD( "hosp.txd", 5708 )
engineImportTXD(txd, 5708 )

dff = engineLoadDFF( "hosp.dff", 5708 )
engineReplaceModel(dff, 5708 )

col = engineLoadCOL ( "hosp.col" )
engineReplaceCOL ( col, 5708 )





end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), replaceModel)

