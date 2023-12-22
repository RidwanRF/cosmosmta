local screen = {guiGetScreenSize()}
local pTimer = {}
local toltve = 0
local showloading = false
local betoltendoObjektek = {
	{"wheel_gn1",1082},
	{"wheel_gn2",1077},
	{"wheel_gn3",1079},
	{"wheel_gn4",1075},
	{"wheel_gn5",1081},
	{"wheel_lr1",1073},
	{"wheel_lr2",1098},
	{"wheel_lr3",1096},
	{"wheel_lr4",1025},
	{"wheel_lr5",1085},
	{"wheel_sr1",1080},
	{"wheel_sr2",1078},
	{"wheel_sr3",1076},
	{"wheel_sr4",1074},
	{"wheel_sr5",1097},
	{"wheel_sr6",932},
	{"wheel1",1369},
	{"wheel_lr3",3933},
	{"wheel_lr4",18005},
	{"wheel_lr5",18003},
	{"wheel_sr1",14725},
	{"wheel_sr2",14724},
	{"wheel_sr3",14723},
	{"wheel_sr4",14722},
	{"wheel_sr5",14727},
	{"wheel_sr6",14726},
	{"wheel1",14715},
}

function startLoading(s)
	if s then
	--	showloading = true
	--	pTimer[getLocalPlayer()] = setTimer(function()
		--	toltve = toltve + 1
		--	--if toltve == #betoltendoObjektek then
			--	killTimer(pTimer[getLocalPlayer()])
				--showloading = false
				for i,c in ipairs(betoltendoObjektek) do
					if tostring(i) ~= tostring(c) then
						ChangeObjectModel(c[1],c[2],c[3])
					end
				end
		--	end
		--end--,#betoltendoObjektek * 20,#betoltendoObjektek)
	end
end

function load()
	startLoading(true)
end
addEventHandler("onClientResourceStart",getResourceRootElement(),load)

function ChangeObjectModel (filename,id)
	if id and filename then
		--if fileExists("files/wheels.txd") then
			txd = engineLoadTXD( "files/wheels.txd", true)
			engineImportTXD( txd, 1082 )
		--end
		if fileExists("files/"..filename..".dff") then
			dff = engineLoadDFF("files/"..filename..".dff", 0 )
			engineReplaceModel( dff, id )
		end
	end
end
