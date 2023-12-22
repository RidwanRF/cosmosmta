local lockCode = "SohasemJoszRaAkodraTeCiganyFaszopó"
local lockString = 65536

function FileUnProtection(path,key)
	local file = fileOpen(path)
	local size = fileGetSize(file)
	local FirstPart = fileRead(file,lockString+4)
	fileSetPos(file,lockString+4)
	local SecondPart = fileRead(file,size-(lockString+4))
	fileClose(file)
	return decodeString("tea",FirstPart,{ key = key })..SecondPart
end

function replaceModel()

txd = engineLoadTXD( "files/vh_berendezes.txd", 3980 )
engineImportTXD(txd, 3980 )


dff = engineLoadDFF(FileUnProtection("files/vh.lifeline",lockCode))
engineReplaceModel(dff, 3980, true )
engineSetModelLODDistance(3980,5000) 

col = engineLoadCOL ( "files/vh.col" )
engineReplaceCOL ( col, 3980 )

txd = engineLoadTXD( "files/vh_berendezes.txd", 4002 )
engineImportTXD(txd, 4002 )

dff = engineLoadDFF( "files/berendezes.dff", 4002 )
engineReplaceModel(dff, 4002, true )

col = engineLoadCOL ( "files/berendezes.col" )
engineReplaceCOL ( col, 4002 )


txd = engineLoadTXD( "files/vh_berendezes.txd", 3997 )
engineImportTXD(txd, 3997 )

dff = engineLoadDFF( "files/glass.dff", 3997 )
engineReplaceModel(dff, 3997, true )
engineSetModelLODDistance(3997,5000) 

col = engineLoadCOL ( "files/glass.col" )
engineReplaceCOL ( col, 3997 )


--[[txd = engineLoadTXD( "files/logo.txd", 3979 )
engineImportTXD(txd, 3979 )

dff = engineLoadDFF( "files/logo.dff", 3979 )
engineReplaceModel(dff, 3979, true )

col = engineLoadCOL ( "files/logo.col" )
engineReplaceCOL ( col, 3979 )]]


txd = engineLoadTXD( "files/textures.txd", 8201 )
engineImportTXD(txd, 8201 )

dff = engineLoadDFF( "files/Armchair.dff", 8201 )
engineReplaceModel(dff, 8201, true )

col = engineLoadCOL ( "files/Armchair.col" )
engineReplaceCOL ( col, 8201 )


txd = engineLoadTXD( "files/textures.txd", 8333 )
engineImportTXD(txd, 8333 )

dff = engineLoadDFF( "files/Bookshelf.dff", 8333 )
engineReplaceModel(dff, 8333, true )

col = engineLoadCOL ( "files/Bookshelf.col" )
engineReplaceCOL ( col, 8333 )


txd = engineLoadTXD( "files/textures.txd", 7983 )
engineImportTXD(txd, 7983 )

dff = engineLoadDFF( "files/Carpet.dff", 7983 )
engineReplaceModel(dff, 7983, true )

col = engineLoadCOL ( "files/Carpet.col" )
engineReplaceCOL ( col, 7983 )


txd = engineLoadTXD( "files/textures.txd", 8419 )
engineImportTXD(txd, 8419 )

dff = engineLoadDFF( "files/Couch.dff", 8419 )
engineReplaceModel(dff, 8419, true )

col = engineLoadCOL ( "files/Couch.col" )
engineReplaceCOL ( col, 8419 )


txd = engineLoadTXD( "files/textures.txd", 8421 )
engineImportTXD(txd, 8421 )

dff = engineLoadDFF( "files/Desk_lamp.dff", 8421 )
engineReplaceModel(dff, 8421, true )

col = engineLoadCOL ( "files/Desk_lamp.col" )
engineReplaceCOL ( col, 8421 )


txd = engineLoadTXD( "files/textures.txd", 7627 )
engineImportTXD(txd, 7627 )

dff = engineLoadDFF( "files/Lamp.dff", 7627 )
engineReplaceModel(dff, 7627, true )

col = engineLoadCOL ( "files/Lamp.col" )
engineReplaceCOL ( col, 7627 )


txd = engineLoadTXD( "files/textures.txd", 7035 )
engineImportTXD(txd, 7035 )

dff = engineLoadDFF( "files/Monitor.dff", 7035 )
engineReplaceModel(dff, 7035, true )

col = engineLoadCOL ( "files/Monitor.col" )
engineReplaceCOL ( col, 7035 )


txd = engineLoadTXD( "files/textures.txd", 7492 )
engineImportTXD(txd, 7492 )

dff = engineLoadDFF( "files/Notebook.dff", 7492 )
engineReplaceModel(dff, 7492, true )

col = engineLoadCOL ( "files/Notebook.col" )
engineReplaceCOL ( col, 7492 )


txd = engineLoadTXD( "files/textures.txd", 8422 )
engineImportTXD(txd, 8422 )

dff = engineLoadDFF( "files/Office_chair.dff", 8422 )
engineReplaceModel(dff, 8422, true )

col = engineLoadCOL ( "files/Office_chair.col" )
engineReplaceCOL ( col, 8422 )


txd = engineLoadTXD( "files/textures.txd", 8401 )
engineImportTXD(txd, 8401 )

dff = engineLoadDFF( "files/Outside_bench.dff", 8401 )
engineReplaceModel(dff, 8401, true )

col = engineLoadCOL ( "files/Outside_bench.col" )
engineReplaceCOL ( col, 8401 )


txd = engineLoadTXD( "files/textures.txd", 8432 )
engineImportTXD(txd, 8432 )

dff = engineLoadDFF( "files/PC.dff", 8432 )
engineReplaceModel(dff, 8432, true )

col = engineLoadCOL ( "files/PC.col" )
engineReplaceCOL ( col, 8432 )


txd = engineLoadTXD( "files/textures.txd", 8435 )
engineImportTXD(txd, 8435 )

dff = engineLoadDFF( "files/Plant.dff", 8435 )
engineReplaceModel(dff, 8435, true )

col = engineLoadCOL ( "files/Plant.col" )
engineReplaceCOL ( col, 8435 )


txd = engineLoadTXD( "files/textures.txd", 8494 )
engineImportTXD(txd, 8494 )

dff = engineLoadDFF( "files/Tv.dff", 8494 )
engineReplaceModel(dff, 8494, true )

col = engineLoadCOL ( "files/Tv.col" )
engineReplaceCOL ( col, 8494 )


txd = engineLoadTXD( "files/textures.txd", 8495 )
engineImportTXD(txd, 8495 )

dff = engineLoadDFF( "files/TvStand_1.dff", 8495 )
engineReplaceModel(dff, 8495, true )

col = engineLoadCOL ( "files/TvStand_1.col" )
engineReplaceCOL ( col, 8495 )


txd = engineLoadTXD( "files/textures.txd", 8496 )
engineImportTXD(txd, 8496 )

dff = engineLoadDFF( "files/Wall_lamp.dff", 8496 )
engineReplaceModel(dff, 8496, true )

col = engineLoadCOL ( "files/Wall_lamp.col" )
engineReplaceCOL ( col, 8496 )



txd = engineLoadTXD( "files/textures.txd", 8500 )
engineImportTXD(txd, 8500 )

dff = engineLoadDFF( "files/Dining_chair.dff", 8500 )
engineReplaceModel(dff, 8500, true )

col = engineLoadCOL ( "files/Dining_chair.col" )
engineReplaceCOL ( col, 8500 )


txd = engineLoadTXD( "files/textures.txd", 8493 )
engineImportTXD(txd, 8493 )

dff = engineLoadDFF( "files/Dining_table.dff", 8493 )
engineReplaceModel(dff, 8493, true )

col = engineLoadCOL ( "files/Dining_table.col" )
engineReplaceCOL ( col, 8493 )

txd = engineLoadTXD( "files/liftdoor.txd", 3406 )
engineImportTXD(txd, 3406 )

dff = engineLoadDFF( "files/liftdoor.dff", 3406 )
engineReplaceModel(dff, 3406, true )

col = engineLoadCOL ( "files/liftdoor.col" )
engineReplaceCOL ( col, 3406 )

txd = engineLoadTXD( "files/lift.txd", 11484 )
engineImportTXD(txd, 11484 )

dff = engineLoadDFF( "files/lift.dff", 11484 )
engineReplaceModel(dff, 11484, true )

col = engineLoadCOL ( "files/lift.col" )
engineReplaceCOL ( col, 11484 )
end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), replaceModel)

addEventHandler("onClientResourceStart",root,function()
	--local obj = createObject(11539,1479.3359,-1802.2891,12.5469)
	--createObject(3980,1479.3359,-1802.2891,12.5469)
	--createObject(11539,1479.3359,-1802.2891,12.5469)
	--createObject(4002,1479.3359,-1802.2891,12.5469)
	setOcclusionsEnabled(false) 
	engineSetAsynchronousLoading(false,false)
	--setElementDoubleSided(obj,true)
	for i = 1, #list do
		removeWorldModel(unpack(list[i]))
	end
end)