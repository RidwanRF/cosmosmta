facelifts = {
	[445] = {
		{"lights", "1.png", "BMW m5 e60", false},
		{"lights", "2.png", "BMW m5 e60", false},
		{"lights", "3.png", "BMW m5 e60", false},
		{"lights", "4.png", "BMW m5 e60", false},
		{"lights", "5.png", "BMW m5 e60", false},
		{"lights", "6.png", "BMW m5 e60", false},
	},
	[400] = {
		{"lights", "1.png", "BMW X5", false},
		{"lights", "2.png", "BMW X5", false},
		{"lights", "3.png", "BMW X5", false},
	},
	[558] = {
		{"lights", "1.png", "BMW M3 E46", false},
	},
	[420] = {
		{"lights", "1.png", "BMW M5 E34", false},
		{"lights", "2.png", "BMW M5 E34", false},
		{"lights", "3.png", "BMW M5 E34", false},
		{"lights", "4.png", "BMW M5 E34", false},
		{"lights", "5.png", "BMW M5 E34", false},
		{"lights", "6.png", "BMW M5 E34", false},
	},
	[551] = {
		{"01", "1.png", "BMW 750", false},
		{"01", "2.png", "BMW 750", false},
		{"01", "3.png", "BMW 750", false},
		{"01", "4.png", "BMW 750", false},
	},
	[529] = {
		{"lights", "1.png", "Seat Leon", false},
	},
	[466] = {
		{"lights", "1.png", "Mercedes-Benz C63 AMG", false},
	},
	
	[421] = {
		{"lampa", "1.png", "BMW 7 Series F01", false},
		{"lampa", "2.png", "BMW 7 Series F01", false},
		{"lampa", "3.png", "BMW 7 Series F01", false},
		{"lampa", "4.png", "BMW 7 Series F01", false},
	},
	
	[547] = {
		{"lights", "boralights.png", "Volkswagen Bora", false},
	},
}

function getVehicleFacelifts(vehicle)
    if not vehicle then
        return false
    end

    local modelID = getElementModel(vehicle)
    if facelifts[modelID] then
        return #facelifts[modelID]
    end
    return 0
end


function getModelfacelifts(modelID)
    if not modelID then
        return false
    end

    if facelifts[modelID] then
        return facelifts[modelID]
    end
    return false
end