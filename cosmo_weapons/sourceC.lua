addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
	
	txd = engineLoadTXD ( "weapon/desert.txd" ) 
	engineImportTXD ( txd, 348) 
	dff = engineLoadDFF ( "weapon/desert.dff", 348) 
	engineReplaceModel ( dff, 348)

	--txd = engineLoadTXD ( "weapon/desertk.txd" ) 
	--engineImportTXD ( txd, 19191) 
	--dff = engineLoadDFF ( "weapon/desert.dff", 19191) 
	--engineReplaceModel ( dff, 19191)

	--[[txd = engineLoadTXD ( "weapon/desertw.txd" ) 
	engineImportTXD ( txd, 17926) 
	dff = engineLoadDFF ( "weapon/desert.dff", 17926) 
	engineReplaceModel ( dff, 17926)]]
	
	
	txd = engineLoadTXD ( "weapon/cuntgun.txd" ) 
	engineImportTXD ( txd, 357) 
	dff = engineLoadDFF ( "weapon/cuntgun.dff", 357) 
	engineReplaceModel ( dff, 357)
	
	txd = engineLoadTXD ( "weapon/brass.txd" ) 
	engineImportTXD ( txd, 331) 
	dff = engineLoadDFF ( "weapon/brass.dff", 331) 
	engineReplaceModel ( dff, 331)
	
	txd = engineLoadTXD ( "weapon/flowers.txd" ) 
	engineImportTXD ( txd, 325) 
	dff = engineLoadDFF ( "weapon/flowers.dff", 325) 
	engineReplaceModel ( dff, 325)
	
	txd = engineLoadTXD ( "weapon/laser.txd" ) 
	engineImportTXD ( txd, 322) 
	dff = engineLoadDFF ( "weapon/laser.dff", 322) 
	engineReplaceModel ( dff, 322)
	
	txd = engineLoadTXD ( "weapon/satchel.txd" ) 
	engineImportTXD ( txd, 363) 
	dff = engineLoadDFF ( "weapon/satchel.dff", 363) 
	engineReplaceModel ( dff, 363)
end)