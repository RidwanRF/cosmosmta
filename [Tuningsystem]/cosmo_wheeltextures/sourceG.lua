wheeltextures = {
	[466] = {
		{"*c63_wheel*", "1.png", "Mercedes-Benz C63 AMG", false},
	},
	[404] = {
		{"*rs6_wheel*", "1.png", "Audi RS6 C7", false},
	},
	[526] = {
		{"*nosegrillm4_wheel*", "1.png", "BMW M4 GTS", false},
		{"*nosegrillm4_wheel*", "2.png", "BMW M4 GTS", false},
		{"*nosegrillm4_wheel*", "3.png", "BMW M4 GTS", false},
		{"*nosegrillm4_wheel*", "4.png", "BMW M4 GTS", false},
		{"*nosegrillm4_wheel*", "5.png", "BMW M4 GTS", false},
	},
	[438] = {
		{"*unnamed*", "1.png", "Mercedes E250", false},
	},
	[550] = {
		{"*unnamed*", "1.png", "Mercedes-Benz e420 w210", false},
	},
	[540] = {
		{"*wheel*", "1.png", "Subaru Impreza WRX STI", false},
	},
	[541] = {
		{"*zl1_wheel13_th*", "1.png", "Chevrolet Camaro ZL1", false},
	},
	
	[420] = {
		{"*face*", "1.dds", "BMW M5 E34", false},
		{"*face*", "2.dds", "BMW M5 E34", false},
		{"*face*", "3.dds", "BMW M5 E34", false},
	},
	
	[547] = {
		{"*borarim*", "borarim.png", "Volkswagen Bora", false},
	},
	
	[546] = {
		{"*wheel*", "1.png", "Dodge Charger SRT8", false},
	},
}

function getVehicleWheeltextures(vehicle)
    if not vehicle then
        return false
    end

    local modelID = getElementModel(vehicle)
    if wheeltextures[modelID] then
        return #wheeltextures[modelID]
    end
    return 0
end


function getModelwheeltextures(modelID)
    if not modelID then
        return false
    end

    if wheeltextures[modelID] then
        return wheeltextures[modelID]
    end
    return false
end