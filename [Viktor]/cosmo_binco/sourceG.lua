availableSkins = {
	["Férfi"] = {
		{7, 100000},
		{14, 100000},
		{15, 100000},
		{16, 100000},
		{17, 100000},
		{18, 100000},
		{19, 100000},
		{20, 100000},
		{21, 100000},
		{22, 100000},
		{23, 100000},
		{29, 100000},
		{30, 100000},
		{32, 100000},
		{33, 100000},
		{34, 100000},
		{35, 100000},
		{36, 100000},
		{37, 100000},
		{43, 100000},
		{44, 100000},
		{45, 100000},
		{46, 100000},
		{47, 100000},
		{48, 100000},
		{49, 100000},
		{51, 100000},
		{52, 100000},
		{57, 100000},
		{59, 100000},
		{60, 100000},
		{62, 100000},
		{66, 100000},
		{67, 100000},
		{68, 100000},
		{70, 100000},
		{71, 100000},
		{72, 100000},
		{73, 100000},
		{75, 100000},
		{78, 100000},
		{79, 100000},
		{102, 100000},
		{103, 100000},
		{104, 100000},
		{105, 100000},
		{106, 100000},
		{107, 100000},
		{122, 100000},
		{124, 100000},
		{125, 100000},
		{126, 100000},
		{127, 100000},
		{128, 100000},
		{170, 100000},
		{173, 100000},
		{174, 100000},
		{175, 100000},
		{176, 100000},
		{177, 100000},
		{179, 100000},
		{202, 100000},
		{203, 100000},
		{206, 100000},
		{209, 100000},
		{221, 100000},
		{222, 100000},
		{247, 100000},
		{248, 100000},
		{292, 100000},
		{293, 100000},
	},
	["Női"] = {
		{9, 100000},
		{10, 100000},
		{11, 100000},
		{12, 100000},
		{13, 100000},
		{41, 100000},
		{58, 100000},
		{85, 100000},
		{172, 100000},
		{178, 100000},
		{191, 100000},
	}
}

availableShops = {
	{214.50526428223, -128.58570861816, 1003.5078125-1.2, 180, 3, 219, "Női"},
	{215.24014282227, -132.77117919922, 1003.5078125-1.2, 90, 3, 219, "Férfi"}
}

function getSkinsByType(type)
	if type then
		if availableSkins[type] then
			return availableSkins[type]
		else
			return false
		end
	else
		return false
	end
end