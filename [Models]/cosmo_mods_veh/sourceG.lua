availableMods = {
	-- [index] = {model id, model elérése, csak a fájl neve kiterjesztés nélkül, jármű neve - ha nincs az alap model neve lesz, kikapcsolható-e}
	[1] = {445, "civil/admiral", "BMW M5 e60", true},
	[2] = {602, "civil/alpha", "Audi Sport Quattro '83", true},
	[3] = {429, "civil/banshee", "Chevrolet Corvette C8", true},
	[4] = {526, "civil/fortune", "BMW M4", true},
	[5] = {433, "civil/barracks", "Barracks", true},
	[6] = {490, "civil/fbiranch", "Chevrolet Suburban", true},
	[7] = {528, "civil/fbitruck", "Armored Truck", true},
	[8] = {481, "civil/bmx", "BMX", true},
	[9] = {498, "civil/boxville", "boxville", true},
	[10] = {402, "civil/buffalo", "Potiac Firebird", true},
	[11] = {541, "civil/bullet", "Chevrolet Camaro ZL1", true},
	[12] = {438, "civil/cabbie", "Mercedes-Benz e250 Estate", true},
	[13] = {483, "civil/camper", "Barkas B1000-1", true},
	[14] = {527, "civil/cadrona", "Ford Shelby GT500", true},
	[15] = {548, "civil/cargobob", "Cargobob", true},
	[16] = {525, "civil/towtruck", "Chevrolette Silverado Towtruck", true},
	[17] = {403, "civil/roadtrain", "Mercedes-Benz Actros", true},
	[18] = {415, "civil/cheetah", "McLaren P1", true},
	[19] = {542, "civil/clover", "Honda CR-X SiR '90", true},
	[20] = {589, "civl/club", "Volkswagen Golf IV", true},
	[21] = {480, "civil/comet", "Porsche 911 Turbo S", true},
	[22] = {597, "civil/copcarsf", "Dodge Charger SRT Police", true},
	[23] = {596, "civil/copcarvg", "Ford Explorer", true},
	[24] = {598, "civil/copcarla", "Ford Crown Victoria Police", true},
	[25] = {507, "civil/elegant", "Mercedes-Benz e500 w124", true},
	[26] = {585, "civil/emperor", "Audi 80", true},
	[27] = {427, "civil/Enforcer", "Enforcer", true},
	[28] = {587, "civil/euros", "BMW M6", true},
	[29] = {462, "civil/faggio", "Honda Click", true},
	[30] = {573, "civil/dune", "Dune", false},
	[31] = {562, "civil/elegy", "Nissan Skyline R32", true},
	[32] = {521, "civil/fcr900", "Ducati Desmosedici RR", true},
	[33] = {533, "civil/feltzer", "Audi R8 Spyder", true},
	[34] = {463, "civil/freeway", "Harley Davidson Knucklehead", true},
	[35] = {492, "civil/greenwood", "BMW M5 F90", true},
	[36] = {497, "civil/maverick", "Maverick", true},
	[37] = {474, "civil/hermes", "Volkswagen Beetle 1963", true},
	[38] = {494, "civil/hotrina", "Ferrari F12 Berlinetta", true},
	[39] = {535, "premium/slamvan", "Walton Van 1", true},
	[40] = {503, "civil/hotring", "Bugatti Divo", true},
	[41] = {579, "civil/huntley", "Range Rover Sport SC", true},
	[42] = {411, "civil/infernus", "Ferrari 488 Pista",true},
	[43] = {546, "civil/intruder", "Dodge Charger SRT8", true},
	[44] = {545, "civil/hustler", "BMW M8", true},
	[45] = {493, "civil/jesseboat", "Lampadati Toro", true},
	[46] = {517, "civil/majestic", "Dodge Coronet", true},
	[47] = {410, "civil/manana", "Volkswagen Golf 1", true},
	[48] = {551, "civil/merit", "BMW 750i e38", true},
	[49] = {500, "civil/mesa", "Jeep Grand Cherokee", true},
	[50] = {479, "civil/regina", "Ford Explorer Police", true},
	[51] = {510, "civil/mtbike", "Merida Dual Thrust", true},
	[52] = {516, "civil/nebula", "Dodge Charger SRT Hellcat", true},
	[53] = {522, "civil/nrg500", "BMW S 1000", true},
	[54] = {467, "civil/oceanic", "Chevrolet Caprice '87", true},
	[55] = {443, "civil/packer", "Packer", false},
	[56] = {470, "civil/patriot", "Hummer H1", true},
	[57] = {404, "civil/perennial", "Audi RS6 C7", true},
	[58] = {413, "civil/pony", "Ford Econoline", true},
	[59] = {426, "civil/premier", "Dodge Demon", true},
	[60] = {547, "civil/primo", "Volkswagen Golf MK8", true},
	[61] = {400, "civil/rancher", "Mercedes Benz G65", true},
	[62] = {453, "civil/reefer", "Reefer", true},
	[63] = {475, "civil/sabre", "Plymouth Hemi Cuda 70", true},
	[64] = {401, "civil/bravura", "Nissan GT-R", true},
	[65] = {543, "civil/sadlshit", "Ford F-150", true},
	[66] = {468, "civil/sanchez", "Sanchez", true},
	[67] = {495, "civil/sandking", "Ford F-150 Raptor '17", true},
	[68] = {405, "civil/sentinel", "Alfa Romeo Giulia", true},
	[69] = {458, "civil/solair", "Mitsubishi Lancer EVO IX", true},
	[70] = {452, "civil/speeder", "Wellcraft 38 Scarab KV", true},
	[71] = {580, "civil/stafford", "Audi RS4 Avant", true},
	[72] = {439, "civil/stallion", "Dodge Charger 69 R/T", true},
	[73] = {409, "civil/stretch", "Lincoln Town Car", true},
	[74] = {550, "civil/sunrise", "Mercedes-Benz e420 w210", true},
	[75] = {506, "civil/supergt", "Koenigsegg Jesko", true},
	[76] = {466, "civil/glendale", "Mercedes-Benz Maybach S650", true},
	[77] = {420, "civil/taxi", "BMW M5 e34", true},
	[78] = {454, "civil/tropic", "Tropic", true},
	[79] = {451, "civil/turismo", "Lamborghini Gallardo", true},
	[80] = {540, "civil/vincent", "Subaru Impreza WRX STI", true},
	[81] = {491, "civil/virgo", "BMW M635 CSi e24", true},
	[82] = {421, "civil/washing", "BMW 7 Series F01", true},
	[83] = {586, "civil/wayfarer", "Harley Davidson Fat Boy", true},
	[84] = {529, "civil/willard", "Seat Leon", true},
	[85] = {555, "civil/windsor", "Lexus LC500", true},
	[86] = {554, "civil/yosemite", "Dodge Ram 3500 HD", true},
	[87] = {477, "civil/zr350", "Mazda RX-7", true},
	[88] = {558, "civil/uranus", "BMW M3 e46", true},
	[89] = {561, "civil/stratum", "Mitsubishi Lancer EVO X", true},
	[90] = {559, "civil/jester", "Toyota Supra MK4", true},
	[91] = {560, "civil/sultan", "Nissan 240SX", true},
	[92] = {435, "civil/pot1", "Trailer 1", true},
	[93] = {563, "civil/raindance", "Raindance", true},
	[94] = {442, "civil/romero", "Mercedes-Benz Project ONE", true},
	[95] = {496, "civil/496", "Volkswagen Golf VII", true},
	[96] = {566, "civil/566", "Ford Crown Victoria", true},
	[97] = {600, "premium/600", "Lamborghini Terzo Millenio", true},
	[98] = {440, "premium/440", "Mercedes Benz 190E Evo II", true},
	[99] = {434, "premium/434", "Bugatti Bolide", true},
	[100] = {549, "premium/549", "BMW i8 2018", true},
	[101] = {482, "premium/482", "Honda Integra R", true},
-- [103] = {604, "premium/mower", "Volkswagen Passat B8", true},
-- [104] = {418, "premium/moonbeam", "BMW M5 E39", true},
-- [105] = {575, "premium/broadway", "BMW M3 E30", true},
-- [106] = {534, "premium/remington", "Rolls Royce Wraith", true},
}

vehicleNames = {}

for k, v in pairs(availableMods) do
	local model = tonumber(v[1]) or getVehicleModelFromName(v[1])

	if model then
		vehicleNames[model] = v[3]
	end
end

_getVehicleNameFromModel = getVehicleNameFromModel
_getVehicleName = getVehicleName

function getVehicleNameFromModel(model)
	if vehicleNames[model] then
		return vehicleNames[model]
	end

	return _getVehicleNameFromModel(model)
end

function getVehicleName(vehicleElement)
	local model = getElementModel(vehicleElement)

	if vehicleNames[model] then
		return vehicleNames[model]
	end

	return _getVehicleName(vehicleElement)
end

function getVehicleNameList()
	local list = {}

	for k, v in pairs(availableMods) do
		table.insert(list, v[3])
	end

	return list
end