if fileExists("Kliens.lua") then
	fileDelete("Kliens.lua")
end
if fileExists("Kliens.luac") then
	fileDelete("Kliens.luac")
end


addEventHandler("onClientResourceStart", root, function()
engineSetAsynchronousLoading ( true, true )
setOcclusionsEnabled(false)
end)


local dir = "models"
function loadMod(f, m, isLod)
	local txdFile = dir.."/"..f..".txd"
	local dffFile = dir.."/"..f..".dff"
	local colFile = dir.."/"..f..".col"
	if fileExists(txdFile) then
		local txd = EngineTXD(txdFile)
		if txd then
			txd:import(m)
		end
	end
	if fileExists(dffFile) then
		local dff = EngineDFF(dffFile,m)
		if dff then
			dff:replace(m)
		end
	end
	if not isLod then
		if fileExists(colFile) then
			local col = EngineCOL(colFile)
			if col then
				col:replace(m)
			end
		end
	end
end



addEventHandler("onClientResourceStart", resourceRoot, function()

	-- Modellezések
	loadMod("small", 14798) -- Kis garázs
	loadMod("med", 14776) -- Közepes garázs
	
	loadMod("big",14795) -- Nagy garázs
	loadMod("letter",8583) -- Nagy garázs
	loadMod("elfmodel",1669) -- Nagy garázs
	--loadMod("vh2", 4103) -- Városháza
	--loadMod("vh_lod1",4105,true)
	--loadMod("vh_lod2",4104,true)
	
	
	--loadMod("plaza",6908)
	
	
	--loadMod("bank2",4600)
	--loadMod("eszaki",5853)
	
	--loadMod("KUT",3465)
	--loadMod("burger",5418)
	--loadMod("big",4866)

	
	--engineSetModelLODDistance(7507,10000)
	--engineSetModelLODDistance(5489,10000)
	--engineSetModelLODDistance(9076,10000)
	

	--setFarClipDistance( 10000 ) -- We adjust visibility range to 3000 metres


end)
--[[Városháza
addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("texture.txd")
	engineImportTXD(txd, 3980)
	
	local dff = engineLoadDFF("sl_vh.dff", 3980)
	engineReplaceModel(dff, 3980)
	
	local col = engineLoadCOL("vh.col")
	engineReplaceCOL(col, 3980)
	
	engineSetModelLODDistance(3980, 500)
end
)
]]--


--Kiszedések
removeWorldModel(5681,10000,0,0,0) --Autómosó délin
removeWorldModel(1676,10000,0,0,0) --Felrobbantható benyakút


