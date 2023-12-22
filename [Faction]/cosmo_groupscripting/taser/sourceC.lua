local func = {};
local tazers = {};

func.start = function()
	setElementData(localPlayer, "player.Tazed",false)
	engineImportTXD (engineLoadTXD("files/taser.txd"), 2044)
	engineReplaceModel(engineLoadDFF("files/taser.dff", 2044), 2044)
end
addEventHandler("onClientResourceStart",getResourceRootElement(),func.start)

func.quit = function()
	if isElement(tazers[source]) then
		destroyElement(tazers[source])
	end
end
addEventHandler("onClientPlayerQuit", getRootElement(),func.quit)

func.wasted = function()
	if isElement(tazers[source]) then
		destroyElement(tazers[source])
	end
end
addEventHandler("onClientPlayerWasted", getRootElement(),func.wasted)

function cancelTazerDamage(attacker, weapon, bodypart, loss)
	if (weapon==24) then -- deagle
		local mode = getElementData(attacker, "tazerState")
		if (mode==true) then
			cancelEvent()
		end
	end
end
addEventHandler("onClientPlayerDamage", localPlayer, cancelTazerDamage)

func.dataChange = function(dataName)
	if dataName == "tazerState" then
		if getElementData(source, "tazerState") then
			tazers[source] = createObject(2044,0,0,0)
			if isElement(tazers[source]) then
				setElementCollisionsEnabled(tazers[source], false)
				setObjectScale(tazers[source], 1)
				setElementInterior(tazers[source], getElementInterior(source))
				setElementDimension(tazers[source], getElementDimension(source))
				exports["cosmo_boneattach"]:attachElementToBone(tazers[source], source, 12, 0, 0, 0, 0, -90, 0)
			end
		else
			if isElement(tazers[source]) then
				exports["cosmo_boneattach"]:detachElementFromBone(tazers[source]);
				destroyElement(tazers[source])
			end
		end
	end
end
addEventHandler("onClientElementDataChange", getRootElement(),func.dataChange)

local cFunc = {}
local cSetting = {}

cSetting["shots"] = {}
cSetting["shot_calcs"] = {}
local last_shot = 1

cFunc["draw_shot"] = function(x1, y1, z1, x2, y2, z2)
	table.insert(cSetting["shots"], last_shot, {x1, y1, z1, x2, y2, z2})
	local lastx, lasty, lastz = x1, y1, z1
	local dis = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
	cSetting["shot_calcs"][last_shot] = {}

	last_shot = last_shot+1	
end

cFunc["wait_shot"] = function()
	toggleControl("fire", false)
	toggleControl("action", false)
	setTimer(function()
		toggleControl("fire", true)
		toggleControl("action", true)
	end, 2000, 1)
end

func.weaponFire = function(wp, _, _, hitX, hitY, hitZ, element, startX, startY, startZ)
	if(wp == 24) and (getElementData(localPlayer,"tazerState"))then
		
		cancelEvent()
		if(source == localPlayer) then
			cFunc["wait_shot"]()
		end
	end
end
addEventHandler("onClientPlayerWeaponFire", getRootElement(),func.weaponFire)

cFunc["anim_check"] = function(attacker, wep, bodypart,loss)
	if(wep == 24) and (getElementData(localPlayer,"tazerState"))then
		local playerX,playerY,playerZ = getElementPosition(localPlayer)
		local targetX,targetY,targetZ = getElementPosition(source)
		if getDistanceBetweenPoints3D(playerX,playerY,playerZ,targetX,targetY,targetZ) <= 12 then
			triggerServerEvent("onTazerShoot", localPlayer, source) 
			exports.cosmo_chat:sendLocalMeAction(localPlayer, "lesokkolt valakit. ((" .. getElementData(source, "visibleName"):gsub("_", " ") .. "))")
		end
	end
end

addEventHandler("onClientPedDamage", getRootElement(),cFunc["anim_check"])
addEventHandler("onClientPlayerDamage", getRootElement(),cFunc["anim_check"])

addEventHandler("onClientRender",getRootElement(),function()
	if getElementData(localPlayer, "player.Tazed") == true then
		toggleAllControls(false, false, false)
		toggleControl("fire", false)
		toggleControl("action", false)
		toggleControl("sprint", false)
		toggleControl("crouch", false)
		toggleControl("jump", false)
		toggleControl('next_weapon',false)
		toggleControl('previous_weapon',false)
		toggleControl('aim_weapon',false)
	end
end)
--[[local tazerModel = 2044

local playerTazerObject = {}
local playerTazerShader = {}

local emptyTexture = dxCreateTexture("files/empty.png")

local tazerShootEffect = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local txd = engineLoadTXD("files/taser.txd")
		engineImportTXD(txd, tazerModel)

		local dff = engineLoadDFF("files/taser.dff")
		engineReplaceModel(dff, tazerModel)

		setElementData(localPlayer, "tazerState", false)
		setElementData(localPlayer, "player.Tazed", false)
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "tazerState" then
			if isElement(playerTazerObject[source]) then
				destroyElement(playerTazerObject[source])
			end

			if isElement(playerTazerShader[source]) then
				destroyElement(playerTazerShader[source])
			end

			if getElementData(source, dataName) then
				local playerInterior = getElementInterior(source)
				local playerDimension = getElementDimension(source)
				local tazerObject = createObject(tazerModel, 0, 0, 0)

				if isElement(tazerObject) then
					setElementInterior(tazerObject, playerInterior)
					setElementDimension(tazerObject, playerDimension)
					setElementCollisionsEnabled(tazerObject, false)
					setObjectScale(tazerObject, 0.75)

					exports.cosmo_boneattach:attachElementToBone(tazerObject, source, 12, 0, 0, 0, 0, -90, 0)

					playerTazerObject[source] = tazerObject
					playerTazerShader[source] = dxCreateShader("files/texturechanger.fx", 0, 0, false, "ped")
					
					if isElement(playerTazerShader[source]) then
						dxSetShaderValue(playerTazerShader[source], "gTexture", emptyTexture)
						
						for k, v in ipairs(engineGetModelTextureNames("348")) do
							engineApplyShaderToWorldTexture(playerTazerShader[source], v, source)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientPlayerQuit", getRootElement(),
	function ()
		if isElement(playerTazerObject[source]) then
			destroyElement(playerTazerObject[source])
		end
	end
)

addEventHandler("onClientPlayerWasted", getRootElement(),
	function ()
		if isElement(playerTazerObject[source]) then
			destroyElement(playerTazerObject[source])
		end
	end
)

addEventHandler("onClientPlayerWeaponFire", getRootElement(),
	function (weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
		if weapon == 24 and getElementData(source, "tazerState") then
			if isElement(hitElement) then
				if getElementType(hitElement) == "player" and not getPedOccupiedVehicle(hitElement) then
					if not getElementData(hitElement, "player.Tazed") and not getElementData(hitElement, "adminDuty") and not getElementData(source, "adminDuty") then
						local playerPosX, playerPosY, playerPosZ = getElementPosition(source)
						local targetPosX, targetPosY, targetPosZ = getElementPosition(hitElement)

						tazerShootEffect[hitElement] = {
							tazedBy = source,
							startTick = getTickCount(),
							effectElement = createEffect("prt_spark_2", targetPosX, targetPosY, targetPosZ)
						}

						local playerInterior = getElementInterior(source)
						local playerDimension = getElementDimension(source)
						local sound = playSound3D("files/taser.ogg", playerPosX, playerPosY, playerPosZ)

						setElementInterior(sound, playerInterior)
						setElementDimension(sound, playerDimension)
					end
				end
			end

			if source == localPlayer then
				setElementData(localPlayer, "tazerReloadNeeded", true)
				exports.cosmo_controls:toggleControl({"fire", "vehicle_fire"}, false)
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local currentTick = getTickCount()

		for k, v in pairs(tazerShootEffect) do
			if isElement(v.tazedBy) and isElement(k) then
				local officerPosX, officerPosY, officerPosZ = getPedBonePosition(v.tazedBy, 26)
				local targetPosX, targetPosY, targetPosZ = getPedBonePosition(k, 3)

				local elapsedTime = currentTick - v.startTick
				local progress = elapsedTime / 750

				local linePosX, linePosY, linePosZ = interpolateBetween(
					officerPosX, officerPosY, officerPosZ,
					targetPosX, targetPosY, targetPosZ,
					progress, "Linear"
				)

				dxDrawLine3D(officerPosX, officerPosY, officerPosZ, linePosX, linePosY, linePosZ, tocolor(100, 100, 100, 100), 0.5, false)
				dxDrawLine3D(officerPosX, officerPosY + 0.02, officerPosZ, linePosX, linePosY + 0.02, linePosZ, tocolor(100, 100, 100, 100), 0.5, false)

				if elapsedTime >= 300 and isElement(v.effectElement) then
					destroyElement(v.effectElement)
				end

				if elapsedTime >= 2390 then
					tazerShootEffect[k] = nil
				end
			else
				tazerShootEffect[k] = nil
			end
		end
	end
)]]