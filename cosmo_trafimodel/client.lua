
function loadMod ( f, m )
	if fileExists ( f ..'.txd' ) then
		txd = engineLoadTXD ( f ..'.txd' )
		engineImportTXD ( txd, m )
	end
	if fileExists ( f ..'.dff' ) then
		dff = engineLoadDFF ( f ..'.dff', m )
		engineReplaceModel ( dff, m )
	end
	if fileExists( f ..'.col') then
		col = engineLoadCOL(f ..'.col')
		engineReplaceCOL ( col, m )
	end
end



addEventHandler("onClientResourceStart", resourceRoot, 
function ()
	loadMod ( "traffi3", 1337 )
end
)

engineSetAsynchronousLoading ( true, false )