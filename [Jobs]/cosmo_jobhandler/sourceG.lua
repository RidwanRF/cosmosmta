availableJobs = {
	[1] = {
		name = "Takarító",
		instructions = {
			--"Menj és #ff9428takarítsd#ffffff ki az épületeket.",
			--"#ff9428Munkajármű#ffffff kéréséhez menj a kis, #ff9428teherautó#ffffff jelzéshez."
		},
	},
	[2] = {
		name = "Pizza készítő",
		instructions = {
			--"A feladatod, hogy szállítsd ki a #d75959pizzákat#ffffff.",
			--"Menj a pizzázóhoz, és vedd fel a rendeléseket a főnöködtől, #598ed7Joe#ffffff-tól. (Kattints az NPC-re.)",
			--"#ff9428Munkajármű#ffffff kéréséhez menj a kis, #ff9428teherautó#ffffff jelzéshez."
		},
	},
	[3] = {
		name = "Kertész (Szünetel!)",
		instructions = {
			--"Menj végig a #ff9428buszmegállókon#ffffff és szállítsd az utasokat.",
			--"#ff9428Munkajármű#ffffff kéréséhez menj a kis, #ff9428teherautó#ffffff jelzéshez."
		},
	},
	[4] = {
		name = "Pénztáros",
		instructions = {
			"Menj a #ff9428munkahelyedre#ffffff, majd szolgáld ki a vásárlókat.",
			"#ff9428SHOP#ffffff jelzés a térképen, mutatja hova kell menned!"
		},
	},
	[5] = {
		name = "Benzinszállító",
		instructions = {
			"Menj a #ff9428munkahelyedre#ffffff, majd szállítsd ki az üzemanyagot.",
			"#ff9428Munkajármű#ffffff kéréséhez menj a kis, #ff9428teherautó#ffffff jelzéshez."
		},
	},
	[6] = {
		name = "Etikus Hacker",
		instructions = {
			"Menj a #ff9428munkahelyedre#ffffff, majd törd fel a NASA-t!"
			--"#ff9428Munkajármű#ffffff kéréséhez menj a kis, #ff9428teherautó#ffffff jelzéshez."
		},
	},
}

function getJobName(id)
	if id and availableJobs[id] then
		return availableJobs[id].name
	end

	return "Ismeretlen"
end

function getJobNames()
	local jobNames = {}

	for k, v in pairs(availableJobs) do
		jobNames[k] = availableJobs[k].name
	end

	return jobNames
end

addCommandHandler("getcam",
	function()
		camX, camY, camZ, camRotX, camRotY, camRotZ = getCameraMatrix()
		setClipboard(camX .. ", " .. camY .. ", " .. camZ .. ", " .. camRotX .. ", " .. camRotY .. ", " .. camRotZ)
	end
)