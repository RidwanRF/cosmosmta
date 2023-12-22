parkingZone = {
	[1] = {2209.68774, -2236.44800, 13.54688, 145.79693603516}
}

deliveryPoints = {
	[1] = {
		name = "San Fierro Kamion állomás",
		position = {-2455.892578125, 732.990234375, 35.015625},
		ped = {-1751.6672363281, 150.29629516602, 3.7520859241486, 180},	
		dropPoint = {-1744.669921875, 161.28125, 3.5546875, 180},
		pickupPoint = {-1735.400390625, 137.34375, 3.5546875, 0.5, 180},
	},
	[2] = {
		name = "Los Santos Warehouse",
		position = {2200.24902, -2245.57861, 16.33210},
		ped = {2576.7897949219, -2237.0961914062, 16.109375, 223.52308654785, 270},
		dropPoint = {2593.5830078125, -2212.380859375, 13.546875, 90},
		pickupPoint = {2597.2060546875, -2211.3359375, 13.546875, 0.9, 180.00000000},
	},
	[3] = {
		name = "Las Venturas Kamion állomás",
		position = {1717.96484375, 925.1962890625, 10.8203125},
		ped = {1713.173828125, 913.7783203125, 10.8203125},
		dropPoint = {1696.9541015625, 959.1591796875, 10.816518783569, 90},
		pickupPoint = {1726.6123046875, 923.5341796875, 10.8203125, 0.5, 180},
	},

}

freights = {
	[1] = {
		name = "Vas csövek",
		reward = 30000,
		model = 435
	},
	[2] = {
		name = "Ló szállító",
		reward = 35000,
		model = 584
	},
	[3] = {
		name = "Olaj",
		reward = 40000,
		model = 450
	},
	[4] = {
		name = "Ló szállító",
		reward = 35000,
		model = 584
	},
	[5] = {
		name = "Vas csövek",
		reward = 30000,
		model = 435
	},
	[6] = {
		name = "Hús",
		reward = 44000,
		model = 591
	},
}

function getPositionFromElementOffset(element, offsetX, offsetY, offsetZ)
	local m = getElementMatrix(element)
	return offsetX * m[1][1] + offsetY * m[2][1] + offsetZ * m[3][1] + m[4][1],
          offsetX * m[1][2] + offsetY * m[2][2] + offsetZ * m[3][2] + m[4][2],
          offsetX * m[1][3] + offsetY * m[2][3] + offsetZ * m[3][3] + m[4][3]
end

function getPositionFromOffset(m, offsetX, offsetY, offsetZ)
	return offsetX * m[1][1] + offsetY * m[2][1] + offsetZ * m[3][1] + m[4][1],
          offsetX * m[1][2] + offsetY * m[2][2] + offsetZ * m[3][2] + m[4][2],
          offsetX * m[1][3] + offsetY * m[2][3] + offsetZ * m[3][3] + m[4][3]
end

function rotateAround(angle, offsetX, offsetY, baseX, baseY)
	angle = math.rad(angle)

	offsetX = offsetX or 0
	offsetY = offsetY or 0

	baseX = baseX or 0
	baseY = baseY or 0

	return baseX + offsetX * math.cos(angle) - offsetY * math.sin(angle),
          baseY + offsetX * math.sin(angle) + offsetY * math.cos(angle)
end