Interaction.Interactions = {}

--{"Bezárás", ":cosmo_assets/images/sarplogo_big.png", "function"},

function addInteraction(type, model, name, image, executeFunction)
	if not Interaction.Interactions[type][model] then
		Interaction.Interactions[type][model] = {} 
		print("Tábla nem létezik, létrehozás...")        
	end
 
	table.insert(Interaction.Interactions[type][model], {name, image, executeFunction})
	print(name .. " interakció beszúrva")
end

addEventHandler("onClientResourceStart", resourceRoot, function()

end)

function getInteractions(element)
	local interactions = {}
	local type = getElementType(element)
	local model = getElementModel(element)

	table.insert(interactions, {"Bezárás", ":cosmo_assets/images/cross_x.png",
		function ()
			Interaction.Close()
		end
	})

	if type == "player" then
		if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "cuff") then
			if getElementData(element, "player.Cuffed") then
				if getElementData(element, "player.Grabbed") then
					table.insert(interactions, {"Vezetőszár levétele", "icons/uncuff.png",
						function (player, target)
							triggerServerEvent("grabPlayerOff", localPlayer, target)
						end
					})
				else
					table.insert(interactions, {"Vezetőszár rátétele", "icons/cuff.png",
						function (player, target)
							triggerServerEvent("grabPlayer", localPlayer, target)
						end
					})

					table.insert(interactions, {"Bilincs levétele", "icons/uncuff.png",
						function (player, target)
							triggerServerEvent("cuffPlayer", localPlayer, target)
						end
					})
				end
			else
				table.insert(interactions, {"Megbilincselés", "icons/cuff.png",
					function (player, target)
						triggerServerEvent("cuffPlayer", localPlayer, target)
					end
				})
			end
		end

		table.insert(interactions, {"Ruházat átvizsgálása", "icons/detector.png",
			function (player, target)
				triggerServerEvent("friskPlayer", localPlayer, target)
			end
		})

		--if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "heal") then
			table.insert(interactions, {"Megvizsgálás", "icons/heart.png",
				function (player, target)
					triggerEvent("examinePlayerBody", localPlayer, target)
				end
			})

			if not isPedHeadless(element) then
				if getElementHealth(element) <= 20 and getElementHealth(element) > 0 then -- ha menthető állapotban van (ájult vagy elő-halál, össz. 10 perc)
					table.insert(interactions, {"Felsegítés", "icons/heart.png",
						function (player, target)
							triggerEvent("tryToHelpUpPerson", localPlayer, target)
						end
					})
				end
			end
		--end

		if getElementData(element, "player.Cuffed") or getElementData(element, "player.Grabbed") then
			table.insert(interactions, {"Berakás a járműbe", "icons/heart.png",
				function (player, target)
					triggerEvent("cosmo_detainC:detainMode", localPlayer, element)
				end
			})
		end
	elseif type == "vehicle" then
		table.insert(interactions, {"Csomagtartó", "icons/trunk.png",
			function (player, target)
				if getPedOccupiedVehicle(localPlayer) then
					exports.cosmo_hud:showInfobox("error", "Járműben ülve nem nézhetsz bele a csomagtartóba!")
				else
					if getVehicleType(element) == "Automobile" then
						if not exports.cosmo_inventory:bootCheck(element) then
							exports.cosmo_hud:showInfobox("error", "Csak a jármű csomagtartójánál állva nézhetsz bele a csomagtérbe!")
							return
						end
					end

					triggerServerEvent("requestItems", localPlayer, element, tonumber(getElementData(element, "vehicle.dbID")), "vehicle", getElementsByType("player", getRootElement(), true))
				end
			end
		})

		if getElementData(element, "vehicle.locked") then
			table.insert(interactions, {"Jármű kinyitása", "icons/unlock.png",
				function (player, target)
					triggerServerEvent("toggleVehicleLock", localPlayer, element, getElementsByType("player", getRootElement(), true), {getPedTask(localPlayer, "primary", 3)})
				end
			})
		else
			table.insert(interactions, {"Jármű bezárása", "icons/lock.png",
				function (player, target)
					triggerServerEvent("toggleVehicleLock", localPlayer, element, getElementsByType("player", getRootElement(), true), {getPedTask(localPlayer, "primary", 3)})
				end
			})
		end

		table.insert(interactions, {"Tuningok", "icons/vehtuning.png",
			function (player)
				local occvehicle = getPedOccupiedVehicle(localPlayer)
				if getPedOccupiedVehicle(localPlayer) then
					local motor = getElementData(occvehicle, "danihe->tuning->engine") or 0, scale
                    local turbo = getElementData(occvehicle, "danihe->tuning->turbo") or 0, scale
                    local ecu = getElementData(occvehicle, "danihe->tuning->ecu") or 0, scale
                    local valto = getElementData(occvehicle, "danihe->tuning->gear") or 0, scale
                    local felfugg = getElementData(occvehicle, "danihe->tuning->chassis") or 0, scale
                    local fek = getElementData(occvehicle, "danihe->tuning->brakes") or 0, scale
                    local suly = getElementData(occvehicle, "danihe->tuning->weight") or 0, scale
                    local backfire = getElementData(occvehicle, "danihe->tuning->backfire") or 0, scale

                    if backfire == 0 then
                    	backfire = "Nincs"
                    elseif backfire == 1 then
                    	backfire = "Van"
                    end

					outputChatBox("#ff9428[Motor]: #ffffffSzint: #ff9428" .. motor, 255, 255, 255, true)
					outputChatBox("#ff9428[Turbó]: #ffffffSzint: #ff9428" .. turbo, 255, 255, 255, true)
					outputChatBox("#ff9428[ECU]: #ffffffSzint: #ff9428" .. ecu, 255, 255, 255, true)
					outputChatBox("#ff9428[Váltó]: #ffffffSzint: #ff9428" .. valto, 255, 255, 255, true)
					outputChatBox("#ff9428[Felfüggesztés]: #ffffffSzint: #ff9428" .. felfugg, 255, 255, 255, true)
					outputChatBox("#ff9428[Fék]: #ffffffSzint: #ff9428" .. fek, 255, 255, 255, true)
					outputChatBox("#ff9428[Súlycsökkentés]: #ffffffSzint: #ff9428" .. suly, 255, 255, 255, true)

					outputChatBox("#ff9428[Backfire]: #ffffffÁllapot: #ff9428" .. backfire, 255, 255, 255, true)

				else
					outputChatBox("#ff9428[TUNING]: #ffffffCsak autóban lehetséges!", 255, 255, 255, true)
				end
			end
		})


		--if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "wheelClamp") then
			--if getElementData(element, "vehicle.wheelClamp") then
				--table.insert(interactions, {"Kerékbilincs leszedése", "icons/wheelclamp.png",
					--function (player, target)
						--local cX, cY, cZ = getVehicleComponentPosition(target, "wheel_lf_dummy", "world")
						--if getDistanceBetweenPoints3D(cX, cY, cZ, getElementPosition(localPlayer)) <= 1.5 then
							--setElementData(target, "vehicle.wheelClamp", false)
							--exports.cosmo_groupscripting:startWheelClampingAnimation(getElementData(element, "vehicle.wheelClamp"))
						--else
							--exports.cosmo_hud:showAlert("error", "Túl messze vagy a bal első keréktől")
						--end
					--end
				--})
			--else
				--table.insert(interactions, {"Kerékbilincs felrakása", "icons/wheelclamp.png",
					--function (player, target)
						--local cX, cY, cZ = getVehicleComponentPosition(target, "wheel_lf_dummy", "world")
						--if getDistanceBetweenPoints3D(cX, cY, cZ, getElementPosition(localPlayer)) <= 1.5 then
							--setElementData(target, "vehicle.wheelClamp", true)
							--exports.cosmo_groupscripting:startWheelClampingAnimation(getElementData(element, "vehicle.wheelClamp"))
						--else
							--exports.cosmo_hud:showAlert("error", "Túl messze vagy a bal első keréktől")
						--end
					--end
				--})
			--end
		--end
		
		if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "impoundVehicle") or exports.cosmo_groups:isPlayerHavePermission(localPlayer, "cuff") or getElementData(localPlayer, "acc.adminLevel") >= 1 then
			table.insert(interactions, {"Jármű lefoglalása", "icons/wheelclamp.png",
				function (player, target)
					if not getPedOccupiedVehicle(player) then
						if getElementData(target, "vehicle.group") == 1 or getElementData(target, "vehicle.group") == 4 or getElementData(target, "vehicle.group") == 28 or getElementData(target, "vehicle.group") == 58 or getElementData(target, "vehicle.group") == 57 then
							outputChatBox("#ff9428[Lefoglalás]#FFFFFF Legális frakció járművet nem foglalhatsz le.",255,255,255,true)
						else
							kocsiid = getElementData(target, "vehicle.dbID")
						
							outputChatBox("#ff9428[Lefoglalás]#FFFFFF Sikeresen lefoglaltál egy járművet! Jármű ID: #ff9428"..kocsiid.."",255,255,255,true)
							
							local reason = "Tilosban parkolás"
							local price = 6000000
							local impoundedDate = getRealTime().timestamp
							local expireDate = getRealTime().timestamp + (86400 * 0)
							local impoundedBy = getElementData(player, "char.ID")

							triggerServerEvent("impoundVehiclePicsu", target, player, target, reason, price, true, impoundedDate, expireDate, impoundedBy)
						end
					else
						outputChatBox("#ff9428[Lefoglalás] #ffffffMielőtt lefoglalnád a gépjárművet, előbb szállj ki az autóból!", 255, 255, 255, true)
					end
				end
			})
		end

		if model == 407 or model == 544 then
			--if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "wheelClamp") then
				if not getElementData(localPlayer, "player.hasCutter") then
					table.insert(interactions, {"Hidraulikus vágó kivétele", "icons/wheelclamp.png",
						function (player, target)
							triggerServerEvent("cosmo_cutterS:giveCutter", localPlayer)
						end
					})
				else
					table.insert(interactions, {"Hidraulikus vágó visszarakása", "icons/wheelclamp.png",
						function (player, target)
							triggerServerEvent("cosmo_cutterS:takeCutter", localPlayer)
						end
					})
				end

			--end
		end
		
		if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "repair") then
		if exports.cosmo_service:isElementInServiceZone(element) then
			table.insert(interactions, {"Jármű megszerelése", "icons/icon.png",
				function (player, target)
					triggerEvent("cosmo_serviceC:showService", element, element)
				end
			})
		end
	end
	
	elseif type == "object" then
		if getElementData(element, "isFactoryObject") then
			local tempActions = exports.cosmo_job_storekeeper:getCurrentInteractionList(model)

			for k,v in pairs(tempActions) do
				table.insert(interactions, v)
			end

			tempActions = nil
		elseif getElementData(element, "isFuelPump") then
			local tempActions = exports.cosmo_fuel:getCurrentInteractionList(model)

			for k,v in pairs(tempActions) do
				table.insert(interactions, v)
			end

			tempActions = nil
		elseif getElementData(element, "poolTableId") then
			local tempActions = exports.cosmo_billiard:getCurrentInteractionList()

			for k,v in pairs(tempActions) do
				table.insert(interactions, v)
			end

			tempActions = nil
		elseif getElementData(element, "isWeaponBox") then
			table.insert(interactions, {"Doboz felvétele","icons/pickUpCrate.png",
				function(player, target)
                    if exports.cosmo_groups:isPlayerHavePermission(localPlayer, "weaponShip") then
                        if not getElementData(localPlayer, "weaponBoxInHand") then
                            exports.cosmo_weaponship:pickupCreate(getElementData(element, "weaponBox.id"))
                        end
                    end
				end
			})
		elseif getElementData(element, "safeId") then
			table.insert(interactions, {"Széf megtekintés", "icons/safe.png",
				function(player, target)
					if not (exports.cosmo_inventory:hasItemWithData(127, "data1", getElementData(element, "safeId")) or getElementData(localPlayer, "acc.adminLevel") >= 8) then
						return
					end
					triggerServerEvent("requestItems", localPlayer, element, tonumber(getElementData(element, "safeId")), "object", getElementsByType("player", getRootElement(), true))				
				end
			})
		end
	end
	
	return interactions
end
