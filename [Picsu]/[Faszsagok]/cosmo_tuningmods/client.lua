addEventHandler( "onClientResourceStart", root, 
function (startedResource) 

	local dff = engineLoadDFF("spl_c_s_b.dff", 1060) 
	engineReplaceModel(dff, 1060)
	
end)