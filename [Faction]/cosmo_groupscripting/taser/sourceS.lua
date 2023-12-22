--[[addEvent("onTazerShoot", true)
addEventHandler("onTazerShoot", getRootElement(),
	function (targetPlayer)
		if isElement(source) and isElement(targetPlayer) then
			if not getElementData(targetPlayer, "player.Tazed") then
				setElementData(targetPlayer, "player.Tazed", true)

				exports.cosmo_controls:toggleControl(targetPlayer, {"jump", "crouch", "walk", "aim_weapon", "fire", "enter_passenger"}, false)
				toggleAllControls(targetPlayer, false, false, false)
				fadeCamera ( targetPlayer, false, 0.8, 255, 255, 255 )
				setPedAnimation(targetPlayer, "ped", "FLOOR_hit_f", -1, false, false, true)

				setTimer(
					function(player)
						if isElement(player) then
							setPedAnimation(player,"sweet","sweet_injuredloop",-1,false,false,false)

							setTimer(
								function(player)
									if isElement(player) then
										fadeCamera(player, true, 0.7)
										exports.cosmo_controls:toggleControl(player, {"jump", "crouch", "walk", "aim_weapon", "fire", "enter_passenger"}, true)
										setPedAnimation(player, false)
										toggleAllControls(player, true, true, true)

										setElementData(player, "player.Tazed", false)
									end
								end,
							10000, 1, player)
						end
					end,
				20000, 1, targetPlayer)

				exports.cosmo_chat:sendLocalMeAction(source, "lesokkolt valakit. ((" .. getElementData(targetPlayer, "visibleName"):gsub("_", " ") .. "))")
			end
		end
	end
)]]

local cFunc = {}
local cSetting = {}

function onTazerShoot(target)
	if (isElement(target) and getElementType(target)=="player") then
		fadeCamera ( target, false, 1.0, 255, 255, 255 )
		setElementData(target, "player.Tazed", true)
		toggleAllControls(target, false, false, false)
		setPedAnimation(target, "ped", "FLOOR_hit_f", -1, false, false, true)
		exports.cosmo_controls:toggleControl(targetPlayer, {"jump", "crouch", "walk", "aim_weapon", "fire", "enter_passenger"}, false)
		setElementFrozen(target, true)
		setTimer(removeAnimation, 30000, 1, target)
	end
end
addEvent("onTazerShoot", true )
addEventHandler("onTazerShoot", getRootElement(), onTazerShoot)

function removeAnimation(thePlayer)
	if (isElement(thePlayer) and getElementType(thePlayer)=="player") then
		fadeCamera(thePlayer, true, 0.5)
		if getElementData(thePlayer,"isAnim") then
			setPedAnimation(thePlayer,"sweet","sweet_injuredloop",-1,false,false,false)
			setElementFrozen(thePlayer,true)
		else
			setPedAnimation(thePlayer,nil,nil)
			toggleAllControls(thePlayer, true, true, true)
			--exports.cosmo_controls:toggleControl(thePlayer, {"jump", "crouch", "walk", "aim_weapon", "fire", "enter_passenger"}, true)
		end
		setElementData(thePlayer, "player.Tazed", false)
		setElementFrozen(thePlayer, false)
		--exports.cosmo_controls:toggleControl(thePlayer, {"jump", "crouch", "walk", "aim_weapon", "fire", "enter_passenger"}, true)
	end
end