local weightLimits = {}

defaultSettings = {
	slotLimit = 50,
	width = 10,
	slotBoxWidth = 36,
	slotBoxHeight = 36,
	weightLimit = {
		player = 35,
		vehicle = 100,
		object = 60
	},
	trashModels = {
		[1359] = true,
		[1439] = true
	},
	safeModel = 2332
}

craftItems = {
	[1] = {"Horgászbot",200, 0,0,0,0,0,0,255,0,0,0,0,256,257,0,0,0,258,0,0,0,0,0,0,0,0},--7,12,13,17
	[2] = {"Szárított Marihuána",287, 0,0,0,0,0,0,0,0,0,0,0,287,280,0,0,0,0,0,0,0,0,0,0,0,0},--7,12,13
	[3] = {"Füvescigi",282, 0,0,0,0,0,0,0,0,0,0,0,295,286,0,0,0,0,0,0,0,0,0,0,0,0},--7,12,13
	[4] = {"Kokain",264, 0,0,0,0,0,0,259,0,0,0,0,260,262,0,0,0,0,0,0,0,0,0,0,0,0},--7,12,13
	[5] = {"Heroin por",125, 0,0,0,0,0,0,267,0,0,0,0,268,269,0,0,0,265,0,0,0,0,0,0,0,0},--7,12,13,17
	[6] = {"Heroinos fecskendő",126, 0,0,0,0,0,0,267,0,0,0,0,268,269,0,0,0,266,0,0,0,0,0,0,0,0},--7,12,13,17
	[7] = {"Colt-45",9, 0,0,0,0,0,0,230,0,0,0,0,225,228,0,0,0,226,227,229,0,0,0,0,0,0},--7,12,13,17,18,19
	[8] = {"UZI",12, 0,0,0,0,0,0,241,0,0,0,0,240,238,237,0,0,239,0,0,0,0,0,0,0,0},--7,12,13,14,17
	[9] = {"TEC-9",13, 0,0,0,0,0,0,241,0,0,0,0,240,238,237,0,0,239,0,0,0,0,0,0,0,0},--7,12,13,14,17
	[10] = {"AK-47",15, 0,0,0,0,0,0,221,0,0,0,0,222,228,0,0,0,223,224,0,0,0,0,0,0,0},--7,12,13,17,18
	[11] = {"Vadászpuska",17, 0,0,0,0,0,0,234,0,0,0,0,235,228,0,0,0,236,0,0,0,0,0,0,0,0},--7,12,13,17
	[12] = {"Sörétespuska",19, 0,0,0,0,0,0,0,231,0,0,0,0,232,0,0,0,0,233,0,0,0,0,0,0,0},--8,13,18
}

craftingName = ""
craftingId = 0
craftingSlot1 = 0
craftingSlot2 = 0
craftingSlot3 = 0
craftingSlot4 = 0
craftingSlot5 = 0
craftingSlot6 = 0
craftingSlot7 = 0
craftingSlot8 = 0
craftingSlot9 = 0
craftingSlot10 = 0
craftingSlot11 = 0
craftingSlot12 = 0
craftingSlot13 = 0
craftingSlot14 = 0
craftingSlot15 = 0
craftingSlot16 = 0
craftingSlot17 = 0
craftingSlot18 = 0
craftingSlot19 = 0
craftingSlot20 = 0
craftingSlot21 = 0
craftingSlot22 = 0
craftingSlot23 = 0
craftingSlot24 = 0
craftingSlot25 = 0

craftingHasItem1 = 0
craftingHasItem2 = 0
craftingHasItem3 = 0
craftingHasItem4 = 0
craftingHasItem5 = 0
craftingHasItem6 = 0
craftingHasItem7 = 0
craftingHasItem8 = 0
craftingHasItem9 = 0
craftingHasItem10 = 0
craftingHasItem11 = 0
craftingHasItem12 = 0
craftingHasItem13 = 0
craftingHasItem14 = 0
craftingHasItem15 = 0
craftingHasItem16 = 0
craftingHasItem17 = 0
craftingHasItem18 = 0
craftingHasItem19 = 0
craftingHasItem20 = 0
craftingHasItem21 = 0
craftingHasItem22 = 0
craftingHasItem23 = 0
craftingHasItem24 = 0
craftingHasItem25 = 0

sirenPos = {
	[445] = {-0.4,0.08, 0.75, 0, 0, 0}, -- BMW M5 E60
	[420] = {-0.4,0.08, 0.85, 0, 0, 0}, -- BMW M5 e34
	[492] = {-0.4,0.08, 0.82, 0, 0, 0}, -- BMW M5 F10
	[559] = {-0.45,0.18, 0.92, -5, 0, 0}, -- BMW M3 E92
	[566] = {-0.4,0.08, 0.95, -5, 0, 0}, -- Ford Crown Civil
	[426] = {-0.4,0.15, 0.78, 0, 0, 0}, -- Dodge Demon
	[541] = {-0.4,0.08, 0.75, 0, 0, 0}, -- Camaro Zl1
	[540] = {-0.4,0.08, 0.96, 0, 0, 0}, -- Subaru Impreza
	[405] = {-0.4,-0.26, 1.1, 0, 0, 0}, -- Tesla
	[580] = {-0.4,0.10,0.93,0,0,0}, -- Audi RS4
	[404] = {-0.45,0.15,0.65,0,0,0}, -- Audi RS6
	[400] = {-0.6,0.3,1.16,0,0,0}, -- Mercedes G65
	[495] = {-0.55,0.5,1.2,-5,0,0}, -- Ford Raptor
	[579] = {-0.55,0,1.2,0,0,0}, -- Range Rover
	[561] = {-0.4, 0.10, 0.80, 0, 0, 0}, -- Evo X
}

weaponModels = {
	[15] = {355, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- ak
	[16] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- m4
	[20] = {350, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- sawnedoff
	[18] = {358, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- sniper
	[11] = {348, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- deagle
	[14] = {353, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- mp5
	[21] = {351, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- spaz
	[19] = {349, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- shotgun
	[17] = {357, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- vadász
	[35] = {339, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Katana

	-- Skines fegyverek
		-- AK-47
	[128] = {355, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Hello kitty ak
	[129] = {355, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Winter ak
	[130] = {355, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Camo ak
	[131] = {355, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Digit ak
	[132] = {355, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Golden1 ak
	[133] = {355, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Golden2 ak
	[134] = {355, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Sticker ak

	[172] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Camo M4
	[173] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Gold M4
	[174] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Hello M4
	[175] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Painted M4
	[176] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Winter M4
	[213] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Gold M4
	[214] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Ice M4
	[215] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Painted M4
	[216] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Winter M4
	[217] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Winter M4

		-- Kések
	[135] = {335, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[136] = {335, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[137] = {335, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[138] = {335, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[139] = {335, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[140] = {335, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[269] = {335, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[270] = {335, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},

		-- Deaglek
	[141] = {348, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[142] = {348, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[143] = {348, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},

		-- MP5
	[144] = {353, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[145] = {353, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[146] = {353, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[147] = {353, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[271] = {353, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[272] = {353, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},

		-- Sniper
	[148] = {358, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[149] = {358, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[185] = {358, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	[186] = {358, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},

    [182] = {349, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- shotgun
    [183] = {349, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- shotgun
    [184] = {349, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- shotgun

	-- Spaz
	[218] = {351, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- spaz
	[219] = {351, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- spaz
	[220] = {351, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- spaz
	[221] = {351, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- spaz
	[222] = {351, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- spaz

	-- Lefü
	[223] = {350, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- sawnedoff
	[224] = {350, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- sawnedoff
	[225] = {350, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- sawnedoff
	[226] = {350, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- sawnedoff
	[229] = {356, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Rose M4
	
	[261] = {339, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Katana
	[262] = {339, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1}, -- Katana

		--TEC
	--[150] = {372, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	--[151] = {372, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	--[152] = {372, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
	--[153] = {372, x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, scale = 1},
}

weaponPosition = {
	[30] = {6, -0.09, -0.1, 0.2, 10, 155, 95}, -- ak
	[31] = {5, 0.15, -0.1, 0.2, -10, 155, 90}, -- m4
	--[26] = {5, 0.15, 0.06, 0.2, 0, 172, 90}, --sawnedoff
	[26] = {13, -0.05, 0.05, -0.1, 0, -90, 90},	--sawnedoff
	[34] = {6, -0.09, 0.02, 0.2, 10, 155, 90}, -- sniper --[34] = {5, 0.15, -0.1, 0.2, -10, 155, 90}, -- sniper
	[24] = {14, 0.10, 0, 0, 0, 264, 90}, -- deagle
	[29] = {13, -0.07, 0.04, 0.06, 0, -90, 95}, -- mp5
	[27] = {6, -0.09, 0.02, 0.2, 10, 155, 95}, -- spaz
	[25] = {5, 0.15, -0.1, 0.2, 0, 155, 90}, -- shotgun
	[33] = {6, -0.09, -0.1, 0.2, 10, 155, 95}, -- vadász
	[4] = {14, 0.15, -0.10, 0.2, 0, 0, 90}, -- kések
	[24] = {14, 0.10, 0, 0, 0, 264, 90}, -- deagle
	[8] = {6, -0.08, 0, -0.02, 10, -90, 100}, --katana
}

availableItems = {
	-- [ItemID] = {Név, Leírás, Súly, Stackelhető, Fegyver ID, Töltény item ID}
	[1] = {"Lakás kulcs", false, 0},
	[2] = {"Jármű kulcs", false, 0},

	[3] = {"5x9mm-es töltény", "Colt45, Desert 5x9mm-es töltény", 0.001, true},
	[4] = {"Kis gépfegyver töltények", "Kis gépfegyver töltények (UZI,TEC-9,MP5)", 0.001, true},
	[5] = {"AK47-es töltény", "AK47-es töltény.", 0.001, true},
	[6] = {"M4-es gépfegyver töltény", "M4-es gépfegyver töltény.", 0.001, true},
	[7] = {"Vadászpuska töltény", "Hosszú Vadászpuska töltény", 0.001, true},
	[8] = {"Sörétes töltény", "Sörétes töltény.", 0.001, true},

	[9] = {"Colt-45", "Egy Colt-45.", 3, false, 22, 3},
	[10] = {"Hangtompítós Colt-45", "Egy Colt45-ös hangtompítóval szerelve.", 3, false, 23, 3},
	[11] = {"Desert Eagle", "Nagy kaliberű Desert Eagle pisztoly.", 3, false, 24, 3},

	[12] = {"UZI", "Uzi géppisztoly.", 3, false, 28, 4},
	[13] = {"TEC-9", "TEC-9-es gépfegyver.", 3, false, 32, 4},
	[14] = {"MP5", "Egy MP5-ös.", 3, false, 29, 4},

	[15] = {"AK-47", "AK-47-es gépfegyver.", 3, false, 30, 5},
	[16] = {"M4", "M4-es gépfegyver.", 3, false, 31, 6},

	[17] = {"Vadászpuska", "Vadász puska a pontos és határozott lövéshez.", 3, false, 33, 7},
	[18] = {"Mesterlövész", "Mesterlövész puska a pontos és határozott lövéshez.", 3, false, 34, 7},

	[19] = {"Sörétes puska", "Nagy kaliberű sörétes puska.", 3, false, 25, 8},
	[20] = {"Rövid csövű sörétes puska", "Nagy kaliberű sörétes puska levágott csővel.", 3, false, 26, 8},
	[21] = {"SPAZ-12 taktikai sörétes puska", "SPAZ-12 taktikai sörétes puska elit fegyver.", 3, false, 27, 8},

	[22] = {"Molotov koktél", "Molotov koktél.", 1, false, 18, 22},
	[23] = {"Gránát", false, 1, false, 16, 23},
	[24] = {"Könnygázgránát", false, 1, false, 17, 24},

	[25] = {"Festékszóró", "Egy festékpatronnal működő festékszóró.", 1, false, 41, 42},
	[26] = {"Könnygáz spray", "Tömegoszlatásra, önvédelemre kitalált, hatásos spray.", 1, false, 41, 43},
	[27] = {"Porral oltó", "Egy porral oltó, mely hatásos védelmet nyújt kisebb tüzek ellen.", 1, false, 42},
	[28] = {"Fényképezőgép", "Egy fényképezőgép mellyel megörökítheted a pillanatokat.", 1, false, 43, 44},

	[29] = {"Gumibot", false, 1, false, 3, 29},
	[30] = {"Golfütő", false, 1, false, 2, 30},
	[31] = {"Kés", "Egy fegyvernek minősülő kés.", 1, false, 4, 31},
	[32] = {"Baseball ütő", false, 1, false, 5, 32},
	[33] = {"Csákány", false, 1, false, 6, 33},
	[34] = {"Biliárd ütő", false, 1, false, 7, 34},
	[35] = {"Katana", "Ősi japán ereklye.", 1, false, 8, 35},
	[36] = {"Láncfűrész", false, 1, false, 9, 36},

	[37] = {"Balta", false, 1, false, 10, 37},
	[38] = {"Dildo", false, 1, false, 12, 38},
	[39] = {"Vibrator", false, 1, false, 12, 39},
	[40] = {"Virág", false, 1, false, 14, 40},
	[41] = {"Járó bot", false, 1, false, 15, 41},

	[42] = {"Festék patron", false, 0.05, true},
	[43] = {"Könnygáz patron", false, 0.05, true},
	[44] = {"SD Kártya", "Kamerába való SD kártya", 0.005, true},

	[45] = {"Hamburger", "Egy guszta, jól megpakolt hamburger.", 0.8},
	[46] = {"Hot-dog", false, 0.8},
	[47] = {"Szendvics", false, 0.8},
	[48] = {"Taco", false, 0.8},
	[49] = {"Fánk", false, 0.8},
	[50] = {"Süti", false, 0.8},
	[51] = {"Puding", false, 0.8},

	[52] = {"Fanta", "Üdítő.", 0.8},
	[53] = {"Coca Cola", "Üdítő.", 0.8},
	[54] = {"PEPSI Cola", "Üdítő.", 0.8},
	[55] = {"7up", "Üdítő.", 0.8},
	[56] = {"Dr Pepper", "Üdítő.", 0.8},

	[57] = {"Red Bull", "Energia ital.", 0.8},
	[58] = {"Monster", "Energia ital.", 0.8},
	[59] = {"Burn", "Energia ital.", 0.8},

	[60] = {"Indigo H2O", "Ásványvíz.", 0.8},
	[61] = {"FIJI Water", "Ásványvíz.", 0.8},

	[62] = {"Bud Light", "Sör.", 0.8},
	[63] = {"Budweiser", "Sör.", 0.8},

	[64] = {"Spring 44", "Vodka.", 0.8},
	[65] = {"Hangar One", "Vodka.", 0.8},
	[66] = {"Tito’s", "Vodka.", 0.8},

	[67] = {"Buffalo Trace", "Whisky.", 0.8},
	[68] = {"Jim Beam", "Whisky.", 0.8},
	[69] = {"Jack Daniel's", "Whisky.", 0.8},

	[70] = {"Kávé", false, 0.8},

	[71] = {"Telefon", false, 0.05},
	[72] = {"Unused slot", false, 0.8},
	[73] = {"Telefon könyv", false, 0.8},
	[74] = {"Gáz maszk", false, 0.8},
	[75] = {"Fény rúd", false, 0.005, true},
	[76] = {"Faltörő kos", false, 0.8},
	[77] = {"Bilincs", false, 0.025, true},
	[78] = {"Bilincs kulcs", false, 0.025, true},
	[79] = {"Rádió", false, 0.8},
	[80] = {"Kötél", false, 0.8},
	[81] = {"Szonda", false, 0.8},
	[82] = {"Hi-Fi", false, 0.8},
	[83] = {"Sí maszk", false, 0.8},
	[84] = {"Benzin kanna", false, 0.8},
	[85] = {"Széf", "A lerakáshoz kattints rá jobb klikkel.", 0.8},
	[86] = {"Jelvény", false, 0.05},
	[87] = {"Azonosító", false, 0.8},
	[88] = {"Kendő", false, 0.8},
	[89] = {"GPS", false, 0.8},
	[90] = {"Elsősegély doboz", "Egészségügyi doboz.", 0.8},
	[91] = {"Rohampajzs", false, 0.8},
	[92] = {"Hűtőszekrény", false, 0.8},
	[93] = {"Sisak", false, 0.8},
	[94] = {"Láda", false, 0},
	[95] = {"Pénzes zsák", false, 0.8},
	[96] = {"Kapu kulcs", false, 0},
	[97] = {"Cigaretta", false, 0.8},
	[98] = {"Egy doboz cigi", false, 0.8},
	[99] = {"Öngyújtó", false, 0.01},
	[100] = {"Befizetési Csekk", false, 0},
	[101] = {"Csekk tömb", false, 0.01},
	[102] = {"Kifizetési utalvány", false, 0},
	[103] = {"Üres kifizetési utalvány", false, 0},
	[104] = {"Üres befizetési csekl", false, 0},
	[105] = {"Gyógyszer", "Életmentő kapszula.", 0.01},
	[106] = {"Vitamin", false, 0.8},
	[107] = {"Defiblirátor", false, 0.8},
	[108] = {"Orvosi táska", false, 0.8},
	[109] = {"GPS", false, 0.8},
	[110] = {"Sokkoló", "Sokkoló pisztoly", 0.25, false, 24, -1},
	[111] = {"Jogosítvány", "Jogosítvány", 0},
	[112] = {"Személyigazolvány", "Személyi", 0},
	[113] = {"Vizsga záradék", "Vizsgának az eredményei papírra írva", 0},
	[114] = {"Megafon", false, 0.01},

	[115] = {"Szén", false, 0.25, true},
	[116] = {"Aranyrög", false, 0.75, true},
	[117] = {"Gyémánt", false, 0.5, true},

	[118] = {"Parkolási bírság", false, 0},
	[119] = {"Bírság", false, 0},
	[120] = {"Bírság tömb", false, 0.01},
	[121] = {"Parkolási bírság tömb", false, 0.01},

	[122] = {"Kötszer", "Kötszer a vérzés lassítására", 0.001, true},

	[123] = {"Marihuana cserje", false, 0.01,true},
	[124] = {"Kokacserje", false, 0.01,true},
	[125] = {"Pocs", false, 0.01,true},
	[126] = {"Pocs", false, 0.01,true},

	-- Új itemek
	[127] = {"Széfkulcs", false, 0},
	[128] = {"Hello Kitty AK-47"," Festett AK-47-es gépfegyver.", 3, false, 30, 5},
	[129] = {"Digit AK-47"," Festett AK-47-es gépfegyver.", 3, false, 30, 5},
	[130] = {"Camo AK-47"," Festett AK-47-es gépfegyver.", 3, false, 30, 5},
	[131] = {"Winter AK-47"," Festett AK-47-es gépfegyver.", 3, false, 30, 5},
	[132] = {"Golden AK-47"," Festett AK-47-es gépfegyver.(ver. 1.)", 3, false, 30, 5},
	[133] = {"Golden AK-47"," Festett AK-47-es gépfegyver.(ver. 2.)", 3, false, 30, 5},
	[134] = {"Silver AK-47"," Festett AK-47-es gépfegyver.", 3, false, 30, 5},

	[135] = {"Camo Knife", "Camo mintás kés", 1, false, 4, 135},
	[136] = {"Rust Knife", "Rozsdás kés", 1, false, 4, 136},
	[137] = {"Carbon Knife", "Carbonból készült kés", 1, false, 4, 137},
	[138] = {"Tiger Knife", "Tigris mintás kés", 1, false, 4, 138},
	[139] = {"Spider Knife", "Spider camo kés", 1, false, 4, 139},
	[140] = {"Digit Knife", "Digit mintás kés", 1, false, 4, 140},

	[141] = {"Camo Desert Eagle", "Terep mintás Desert Eagle pisztoly.", 3, false, 24, 3},
	[142] = {"Gold Desert Eagle", "Arany mintás Desert Eagle pisztoly.", 3, false, 24, 3},
	[143] = {"Hello Desert Eagle", "Pink Desert Eagle pisztoly.", 3, false, 24, 3},

	[144] = {"Camo MP5", "Camo MP-5-ös.", 3, false, 29, 4},
	[145] = {"Golden MP5", "Gold MP-5-ös.", 3, false, 29, 4},
	[146] = {"Hotline Miami MP5", "Hotline Miami MP-5-ös.", 3, false, 29, 4},
	[147] = {"Winter MP5", "Winter MP-5-ös.", 3, false, 29, 4},

	[148] = {"Winter Sniper", "Camo sniper.", 3, false, 34, 7},
	[149] = {"Camo Sniper", "Winter Camo sniper.", 3, false, 34, 7},

	[150] = {"Bronz TEC-9", "Bronz TEC-9-es gépfegyver.", 3, false, 32, 4},
	[151] = {"Camo TEC-9", "Terep mintás TEC-9.", 3, false, 32, 4},
	[152] = {"Golden TEC-9", "Arany TEC-9-es gépfegyver.", 3, false, 32, 4},
	[153] = {"Winter TEC-9", "Winter style TEC-9.", 3, false, 32, 4},

	[154] = {"Bronz UZI", "Bronz UZI géppisztoly.", 3, false, 28, 4},
	[155] = {"Camo UZI", "Terepmintás UZI géppisztoly.", 3, false, 28, 4},
	[156] = {"Gold UZI", "Arany UZI géppisztoly.", 3, false, 28, 4},
	[157] = {"Winter UZI", "Téli terepmintás UZI géppisztoly.", 3, false, 28, 4},
	
	[158] = {"Fix kártya", "Amikor egy isteni erő újjáéleszti az autódat, amiben ülsz.", 0, true},
	[159] = {"Tankoló kártya","S lőn, teli a tank, ha a kocsiba ülsz.", 0, true},
	[160] = {"Heal kártya", "S lőn, egy isteni csoda felsegít téged.", 0, true},
	
	[161] = {"Colt mesterkönyv", "Mesterkönyv", 1, true},
	[162] = {"Hangtompítós Colt mesterkönyv", "Mesterkönyv", 1, true},
	[163] = {"Desert Eagle mesterkönyv", "Mesterkönyv", 1, true},
	[164] = {"TEC-9 mesterkönyv", "Mesterkönyv", 1, true},
	[165] = {"MP-5 mesterkönyv", "Mesterkönyv", 1, true},
	[166] = {"AK-47 mesterkönyv", "Mesterkönyv", 1, true},
	[167] = {"M4 mesterkönyv", "Mesterkönyv", 1, true},
	[168] = {"Vadászpuska mesterkönyv", "Mesterkönyv", 1, true},
	[169] = {"Shotgun mesterkönyv", "Mesterkönyv", 1, true},
	[170] = {"Taktikai shotgun mesterkönyv", "Mesterkönyv", 1, true},
	[171] = {"Lefűrészelt mesterkönyv", "Mesterkönyv", 1, true},

	[172] = {"Camo M4", "M4-es gépfegyver.", 3, false, 31, 6},
	[173] = {"Gold M4", "M4-es gépfegyver.", 3, false, 31, 6},
	[174] = {"Hello Kitty M4", "M4-es gépfegyver.", 3, false, 31, 6},
	[175] = {"Rust M4", "M4-es gépfegyver.", 3, false, 31, 6},
	[176] = {"Winter M4", "M4-es gépfegyver.", 3, false, 31, 6},
	
	[177] = {"Kis petárda", "petárda", 0, true},
	[178] = {"Nagy petárda", "petárda", 0, true},
	
	[179] = {"Villogó", "sziréna", 0, false},
	[180] = {"Flex", "Szerszám", 2, false},
	[181] = {"Pénzkazetta", false, 2},

    [182] = {"Camo Sörétes puska", "Nagy kaliberű sörétes puska.", 3, false, 25, 8},
    [183] = {"Gold Sörétes puska", "Nagy kaliberű sörétes puska.", 3, false, 25, 8},
    [184] = {"Rust Sörétes puska", "Nagy kaliberű sörétes puska.", 3, false, 25, 8},

    [185] = {"Gold Sniper", "Gold sniper.", 3, false, 34, 7},
    [186] = {"Hello Kitty Sniper", "Hello Kitty sniper.", 3, false, 34, 7},
    [187] = {"Minigun", "Minigun", 0, false, 38, 6},

	[188] = {"Retek mag", "", 0.05, true},
	[189] = {"Sárgarépa mag", "", 0.05, true},
	[190] = {"Petrezselyem mag", "", 0.05, true},
	[191] = {"Saláta mag", "", 0.05, true},
	[192] = {"Hagyma mag", "", 0.05, true},
	[193] = {"Kender mag", "", 0.05, true},

	[194] = {"Retek", "", 0.3, true},
	[195] = {"Sárgarépa", "", 0.15, true},
	[196] = {"Petrezselyem", "", 0.15, true},
	[197] = {"Saláta", "", 0.2, true},
	[198] = {"Hagyma", "", 0.05, true},

	[199] = {"Fuvarlevél", "", 0.05, false},
	[200] = {"Horgászbot", "Kapd el a halakat.", 0.05, false},
	[201] = {"Harcsa", "", 1.0, false},
	[202] = {"Ponty", "", 1.0, false},
	[203] = {"Cápa", "", 3.0, false},
	[204] = {"Polip", "", 3.5, false},
	[205] = {"C4", "", 3.5, false},
	[206] = {"Aranyrúd", "", 5.0, false},
	[207] = {"Elszáradt növény", "", 1.0, false},
	[208] = {"Rák", "", 1.0, false},
	[209] = {"Ismeretlen hal", "", 1.0, false},
	[210] = {"Tengericsillag", "", 1.0, false},
	[211] = {"Hínár", "", 1.0, false},
	[212] = {"Konzervesdoboz", "", 1.0, false},
	[213] = {"Digit M4", "M4-es gépfegyver.", 3, false, 31, 6},
	[214] = {"Ice M4", "M4-es gépfegyver.", 3, false, 31, 6},
	[215] = {"Silver M4", "M4-es gépfegyver.", 3, false, 31, 6},
	[216] = {"Wandal M4", "M4-es gépfegyver.", 3, false, 31, 6},
	[217] = {"Rust M4", "M4-es gépfegyver.", 3, false, 31, 6},
	[218] = {"Camo SPAZ-12 taktikai sörétes puska", "SPAZ-12 taktikai sörétes puska elit fegyver.", 3, false, 27, 8},
	[219] = {"Gold SPAZ-12 taktikai sörétes puska", "SPAZ-12 taktikai sörétes puska elit fegyver.", 3, false, 27, 8},
	[220] = {"Hello-Kitty SPAZ-12 taktikai sörétes puska", "SPAZ-12 taktikai sörétes puska elit fegyver.", 3, false, 27, 8},
	[221] = {"Tiger SPAZ-12 taktikai sörétes puska", "SPAZ-12 taktikai sörétes puska elit fegyver.", 3, false, 27, 8},
	[222] = {"Winter SPAZ-12 taktikai sörétes puska", "SPAZ-12 taktikai sörétes puska elit fegyver.", 3, false, 27, 8},
	[223] = {"Camo Lefűrészelt Csövű Sörétes", "Nagy kaliberű sörétes puska levágott csővel.", 3, false, 26, 8},
	[224] = {"Gold Lefűrészelt Csövű Sörétes", "Nagy kaliberű sörétes puska levágott csővel.", 3, false, 26, 8},
	[225] = {"Tiger Lefűrészelt Csövű Sörétes", "Nagy kaliberű sörétes puska levágott csővel.", 3, false, 26, 8},
	[226] = {"Winter Camo Lefűrészelt Csövű Sörétes", "Nagy kaliberű sörétes puska levágott csővel.", 3, false, 26, 8},
	[227] = {"Szar", "M4-es gépfegyver.", 3, false, 31, 6},
	[228] = {"Szar", "M4-es gépfegyver.", 3, false, 31, 6},
	[229] = {"Rose M4", "M4-es gépfegyver.", 3, false, 31, 6},

	[230] = {"Marihuána", false, 0.01,true},
	[231] = {"Kokain", false, 0.01,true},
	[232] = {"Füzet", false, 0.01,true},
	[233] = {"Füzetlap", false, 0.01,true},
	[234] = {"Zseblámpa", false, 1, true},
	[235] = {"Fegyver láda (Kicsi) NINCS", false, 0},
	[236] = {"Fegyver láda (Közepes) NINCS", false, 0},
	[237] = {"Fegyver láda (Nagy) NINCS", false, 0},

	[238] = {"Róka Bőr", false, 0.01},
	[239] = {"Farkas Bőr", false, 0.01},
	[240] = {"Medve Bőr", false, 0.01},
	[241] = {"Róka Trófea", false, 0.01},
	[242] = {"Farkas Trófea", false, 0.01},
	[243] = {"Medve Trófea", false, 0.01},
	[244] = {"Pénzkazetta", false, 2},
	[245] = {"Taxilámpa", false, 0.1, false},
	[246] = {"Névcédula", "Nevezd el a tárgyaid", 0, true},
    [247] = {"téboly carl", "", 0.1, false, -1, -1},

	[248] = {"Tár", false, 0.5, true},
	[249] = {"Markolat", false, 0.5, true},
	[250] = {"Cső", false, 0.5, true},
	[251] = {"Ravasz", false, 0.5, true},
	[252] = {"Felső rész", false, 0.5, true},
	[253] = {"Tus", false, 0.5, true},
	-- [ItemID] = {Név, Leírás, Súly, Stackelhető, Fegyver ID, Töltény item ID}
	[254] = {"Metamfetamin", false, 0.01,true},

	--husvet anyad
	[255] = {"Záptojás", "Húsvéti ajándék", 0.01,false},
	[256] = {"Csokitojás", "Húsvéti ajándék", 0.01,false},
	[257] = {"Bónusztojás", "Húsvéti ajándék", 0.01,false},
	[258] = {"lada", "Húsvéti ajándék", 0.01,false},

	[259] = {"Mészkő", false, 0.25, true},
	[260] = {"Vasérc", false, 0.75, true},
	
	[261] = {"Galaxy Katana", "Ősi japán ereklye.", 1, false, 8, 261},
	[262] = {"Gold Katana", "Ősi japán ereklye.", 1, false, 8, 262},
	[263] = {"Fegyverengedély", "", 0.05, false},

	[264] = {"Vargánya", "", 0.05, false},
	[265] = {"Gyilkos galóca", "", 0.05, false},
	[266] = {"Barna csiperke", "", 0.05, false},
	[267] = {"Erdelyi pöfeteg", "", 0.05, false},
	[268] = {"Őzláb gomba", "", 0.05, false},
	
	[269] = {"Wandal Knife", "Wandal mintás kés", 1, false, 4, 269},
	[270] = {"Hello Kitty Knife", "Hello Kitty mintás kés", 1, false, 4, 270},
	
	[271] = {"Hello Kitty MP5", "Hello Kitty MP-5-ös.", 3, false, 29, 4},
	[272] = {"Rose MP5", "Rose MP-5-ös.", 3, false, 29, 4},
	
		
	[273] = {"Boxer", "Boxer.", 1, false, 1, 273},
	
	[274] = {"Hello Silenced", "Hello Kitty Hangtompított Colt.", 3, false, 23, 3},
	
	[275] = {"Prémium kártya NINCS", "Prémium kártya ((5000pp))", 0.05, false},
	[276] = {"Prémium kártya NINCS", "Prémium kártya ((10.000pp))", 0.05, false},
	[277] = {"Prémium kártya NINCS", "Prémium kártya ((20.000pp))", 0.05, false},

	[278] = {"Mangós Elfbar", "Mangós bolond elf", 0.05, false},
	[279] = {"Gold Silenced", "Arany Hangtompított Colt.", 3, false, 23, 3},
	
	[280] = {"Bibe", false, 0.01,true},
	[281] = {"Kokalevél", false, 0.01,true},
	[282] = {"Füvescigi", false, 0.01,true},
	[283] = {"Mákszalma", false, 0.01,true},
	[284] = {"Heroin por", false, 0.01,true},
	[285] = {"Heroinos fecskendő", false, 0.01,true},
	[286] = {"Szárított Marihuana", false, 0.01,true},
	[287] = {"UV lámpa", false, 0.01,true},
	[288] = {"Öngyújtó", false, 0.01,true},
	[289] = {"Akkumulátor sav", false, 0.01,true},
	[290] = {"Öngyújtó benzin", false, 0.01,true},
	[291] = {"Kanál", false, 0.01,true},
	[292] = {"Fecskendő", false, 0.01,true},
	[293] = {"Szódabikarbóna", false, 0.01,true},
	[294] = {"Granulátum", false, 0.01,true},
	[295] = {"Cigi papír", false, 0.01,true},
}

printerPos = {
	--{x, y, z, rot, dim, int},
	{368.02066040039, 188.3616027832, 1008.3828125, 270, 11, 3},
	{368.02066040039, 186.3616027832, 1008.3828125, 270, 11, 3},
	{368.02066040039, 184.3616027832, 1008.3828125, 270, 11, 3},
	{368.02066040039, 182.3616027832, 1008.3828125, 270, 11, 3},
}

canPrintItems = {
	[112] = true,
	[111] = true,
	[233] = true
}

winterBox = {
	[1] = {35, "Katana", 20},
	[2] = {46, "Hot-dog", 80},
	[3] = {58, "Monster", 80},
	[4] = {59, "Burn", 80},
	[5] = {142, "Golden Deagle", 20},
	[6] = {148, "Winter Sniper", 20},
	[7] = {158, "Fix kártya", 50},
	[8] = {159, "Tankoló kártya", 50},
	[9] = {160, "Heal kártya", 50},
	[10] = {53, "Coca Cola", 80},
	[11] = {194, "Retek", 20},
	[12] = {195, "Sárgarépa", 20},
	[13] = {196, "Petrezselyem", 20},
	[14] = {197, "Saláta", 20},
}

bonusEgg = {
	[1] = {35, "Katana", 20},
	[2] = {46, "Hot-dog", 80},
	[3] = {58, "Monster", 80},
	[4] = {59, "Burn", 80},
	[5] = {142, "Golden Deagle", 20},
	[6] = {148, "Winter Sniper", 20},
	[7] = {158, "Fix kártya", 50},
	[8] = {159, "Tankoló kártya", 50},
	[9] = {160, "Heal kártya", 50},
	[10] = {53, "Coca Cola", 80},
	[11] = {194, "Retek", 20},
	[12] = {195, "Sárgarépa", 20},
	[13] = {196, "Petrezselyem", 20},
	[14] = {197, "Saláta", 20},
}

function isItemCanBePrint(itemId)
	return canPrintItems[itemId]
end

function isKeyItem(itemId)
	return itemId <= 2 or itemId == 96 or itemId == 127
end

function isPaperItem(itemId)
	return (itemId >= 100 and itemId <= 104) or (itemId >= 111 and itemId <= 113) or (itemId >= 118 and itemId <= 121) or itemId == 199 or itemId == 263
end

function isSpecialItem(itemId)
	return (itemId >= 45 and itemId <= 70) or itemId == 97 or itemId == 98 or itemId == 278
end

function isFoodItem(itemId)
	return itemId >= 45 and itemId <= 51
end

function isDrinkItem(itemId)
	return itemId >= 52 and itemId <= 70
end

function getFoodItems()
	local items = {}

	for i = 1, #availableItems do
		if isFoodItem(i) then
			table.insert(items, i)
		end
	end

	return items
end

function getDrinkItems()
	local items = {}

	for i = 1, #availableItems do
		if isDrinkItem(i) then
			table.insert(items, i)
		end
	end

	return items
end

function isPhoneItem(itemId)
	return itemId == 71 or itemId == 72
end

specialItemUsage = {
	[97] = 5,
	[278] = 2,
	[98] = 2
}

for i = 45, 70 do
	if i <= 51 then
		specialItemUsage[i] = 15
	else
		specialItemUsage[i] = 5
	end
end

perishableItems = {
    --[66] = 270 -- 4 és fél óra (270 perc)
    [45] = 300,
    [46] = 300,
    [47] = 300,
    [48] = 300,
    [49] = 300,
    [50] = 300,
    [51] = 300,
    [105] = 480, --8 óra, gyógyszer
    [106] = 480, --8 óra, vitamin
    [118] = 2880, -- parkolási bírság
    [119] = 2880, -- bírság
}

perishableEvent = {
	[118] = "ticketPerishableEvent",
	[119] = "ticketPerishableEvent2"
}

function getItemList()
	return availableItems
end

function getItemInfoForShop(itemId)
	return getItemName(itemId), getItemDescription(itemId), getItemWeight(itemId)
end

function getItemNameList()
	local nameList = {}

	for i = 1, #availableItems do
		nameList[i] = getItemName(i)
	end

	return nameList
end

function getItemDescriptionList()
	local descriptionList = {}

	for i = 1, #availableItems do
		descriptionList[i] = getItemDescription(i)
	end

	return descriptionList
end

function getItemName(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][1]
	end
	return false
end

function getItemDescription(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][2]
	end
	return false
end

function getItemWeight(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][3]
	end
	return false
end

function isItemStackable(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][4]
	end
	return false
end

function getItemWeaponID(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][5] or 0
	end
	return false
end

function getItemAmmoID(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][6]
	end
	return false
end

function isWeaponItem(itemId)
	if availableItems[itemId] and getItemWeaponID(itemId) > 0 then
		return true
	end
	return false
end

function isAmmoItem(itemId)
	return (itemId >= 3 and itemId <= 8) or (itemId >= 42 and itemId <= 44)
end

local nonStackableItems = {}

for i = 1, #availableItems do
	if not isItemStackable(i) then
		nonStackableItems[i] = true
	end
end

function getNonStackableItems()
	return nonStackableItems
end

disabledVehicleTypes = {
	["BMX"] = true,
	["Train"] = true,
	["Trailer"] = true
}

function getWeightLimit(elementType, element)
	if element and getElementType(element) == "vehicle" and disabledVehicleTypes[getVehicleType(element)] then
		return 0
	end

	if element and getElementType(element) == "vehicle" then
		if getVehicleType(element) == "Bike" or getVehicleType(element) == "Quad" then
			return 15
		end
	end

	return weightLimits[getElementModel(element)] or defaultSettings.weightLimit[elementType]
end

function isTrashModel(model)
	if defaultSettings.trashModels[model] then
		return true
	end

	return false
end

function isSafeModel(model)
	if model == defaultSettings.safeModel then
		return true
	end

	return false
end

function getElementDatabaseId(element, elementType)
	local elementType = elementType or getElementType(element)

	if elementType == "player" then
		return getElementData(element, "char.ID")
	elseif elementType == "vehicle" then
		return getElementData(element, "vehicle.dbID")
	elseif elementType == "object" then
		if isSafeModel(getElementModel(element)) then
			return getElementData(element, "safeId")
		end
	end
end


function takeItemInCraft(itemID, itemCount)
	local haveItem = hasItem(itemID)

	if haveItem then
		triggerServerEvent("takeItem", localPlayer, localPlayer, "itemId", haveItem.itemId, itemCount)
	end
end

function givaItemInCraft(itemID,sourcePlayer)
    triggerServerEvent("addItem", sourcePlayer, sourcePlayer, itemID, 1)
end