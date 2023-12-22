debugMode = false

tankDepotModelId = 3073
tankStationModelId = 2908
truckModelId = 573
jobId = 5

jobStartPositions = {
	{2432.0734863281, -2116.2072753906, 13.546875 - 1},
}

startDestinations = {
	[1] = {
		name = "Globe Oil, Tartály #1",
		tankPosition = {2445.2319335938, -2119.4763183594, 12.546875},
		tankRotation = 90
	},
	[2] = {
		name = "Globe Oil, Tartály #2",
		tankPosition = {2455.2319335938, -2119.4763183594, 12.546875},
		tankRotation = 90
	},
	[3] = {
		name = "Globe Oil, Tartály #2",
		tankPosition = {2465.2319335938, -2119.4763183594, 12.546875},
		tankRotation = 90
	},
	[4] = {
		name = "Globe Oil, Tartály #2",
		tankPosition = {2475.2319335938, -2119.4763183594, 12.546875},
		tankRotation = 90
	},
	[5] = {
		name = "Globe Oil, Tartály #2",
		tankPosition = {2485.2319335938, -2119.4763183594, 12.546875},
		tankRotation = 90
	},
	[6] = {
		name = "Globe Oil, Tartály #2",
		tankPosition = {2495.2319335938, -2119.4763183594, 12.546875},
		tankRotation = 90
	},
	[7] = {
		name = "Globe Oil, Tartály #2",
		tankPosition = {2505.2319335938, -2119.4763183594, 12.546875},
		tankRotation = 90
	},
	[8] = {
		name = "Globe Oil, Tartály #2",
		tankPosition = {2515.2319335938, -2119.4763183594, 12.546875},
		tankRotation = 90
	}
}

finalDestinations = {
	[1] = {
		name = "Déli Benzinkút (Los Santos)",
		tankPosition = {1895.8146972656, -1796.822265625, 12.546875},
		tankRotation = 180
	},
	[2] = {
		name = "Whetstone Benzinkút",
		tankPosition = {-1585.97265625, -2715.4914550781, 47.5390625},
		tankRotation = 240
	},
	[3] = {
		name = "Easter Basin Benzinkút (San Fierro)",
		tankPosition = {-1706.3751220703, 407.17999267578, 6.1796875},
		tankRotation = -50
	},
	[4] = {
		name = "Doherty Benzinkút (San Fierro)",
		tankPosition = {-2046.9077148438, 146.12973022461, 27.8359375},
		tankRotation = -90
	},
	[5] = {
		name = "Palomino Creek Benzinkút",
		tankPosition = {2286.4543457031, 19.946250915527, 25.484375},
		tankRotation = 90
	},
	[6] = {
		name = "Montgomery Benzinkút",
		tankPosition = {1409.5213623047, 459.44033813477, 19.220197677612},
		tankRotation = -120
	},
	[7] = {
		name = "Északi Benzinkút (Los Santos)",
		tankPosition = {1018, -894.22583007812, 41.3},
		tankRotation = -90
	},
}

function rotateAround(angle, offsetX, offsetY, baseX, baseY)
	angle = math.rad(angle)

	offsetX = offsetX or 0
	offsetY = offsetY or 0

	baseX = baseX or 0
	baseY = baseY or 0

	return baseX + offsetX * math.cos(angle) - offsetY * math.sin(angle),
          baseY + offsetX * math.sin(angle) + offsetY * math.cos(angle)
end

function getPositionFromElementOffset(element, x, y, z)
	local m = getElementMatrix(element)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
          x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
          x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end

function getPositionFromOffset(m, x, y, z)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
          x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
          x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end
