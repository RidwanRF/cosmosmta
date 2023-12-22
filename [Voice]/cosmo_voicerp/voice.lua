local sx, sy = guiGetScreenSize()

local w = 175
local h = 20

local posX, posY = sx / 2 - w / 2, sy / 2 - h / 2

local textX, textY = sx / 2, sy / 2

local RobotoFont = false
local voiceState = "local"

local time = 0

local broadCastedPlayer = {}
local broadCastedPlayerClient = {}

setTimer(
    function()
        for k,v in pairs(getElementsByType("player", root, false)) do 
            setSoundVolume(v, 0)
        end 
    end, 5000, 0
)

addEventHandler("onClientPreRender", root,
	function ()
        if getElementData(localPlayer, "loggedIn") then
            local nColor = tocolor(255, 148, 40)
            local rColor = tocolor(255, 255, 255, 120)

            if getElementData(localPlayer, "char.voice") == "local" then
                nColor = tocolor(255, 148, 40)
                rColor = tocolor(255, 255, 255, 120)
            elseif getElementData(localPlayer, "char.voice") == "radio" then
                nColor = tocolor(255, 255, 255, 120)
                rColor = tocolor(255, 148, 40)
            end

            dxDrawRectangle(posX + posX - 80, posY + posY, w, h, tocolor(0, 0, 0, 175))

            dxDrawText("Normál voice", posX + posX - 35, posY + posY + 10, _, _, nColor, 1, RobotoFont, "center", "center")
            dxDrawText("Rádió voice", posX + posX + 55, posY + posY + 10, _, _, rColor, 1, RobotoFont, "center", "center")

            local players = getElementsByType("player", root, true)

            local myTune = getElementData(localPlayer, "currentRadioTune")
            local myCH = 0

            if myTune then
                myCH = myTune[1]
            end

            for k, v in pairs(players) do
                if v ~= localPlayer and localPlayer.dimension == v.dimension and localPlayer.interior == v.interior then
                    local radioTune = getElementData(v, "currentRadioTune")

                    if radioTune then
                        local radioCH = radioTune[1]
            
                        if radioCH == myCH and radioCH > 0 then
                            if myTune[2] ~= "N" then
                                if getElementData(v, "char.voice") == "radio" then
                                    local vecSoundPos = v.position
                                    local vecCamPos = Camera.position
                                    local fDistance = (vecSoundPos - vecCamPos).length
                                    local fMaxVol = v:getData("maxVol") or 75 -- Hangerőt itt tudjátok átírni (( Bármi 5000 felett már earrape ))
                                    local fMinDistance = v:getData("minDist") or 5
                                    local fMaxDistance = v:getData("maxDist") or 50

                                    local fPanSharpness = 1.0


                                    local fPanLimit = (0.65 * fPanSharpness + 0.35)

                                    local vecLook = Camera.matrix.forward.normalized
                                    local vecSound = (vecSoundPos - vecCamPos).normalized
                                    local cross = vecLook:cross(vecSound)
                                    local fPan = 0

                                    local fDistDiff = fMaxDistance - fMinDistance;

                                    local fVolume = 100

                                    setSoundPan(v, fPan)

                                    if isLineOfSightClear(localPlayer.position, vecSoundPos, true, true, false, true, false, true, true, localPlayer) then
                                        setSoundVolume(v, fVolume)
                                        --setSoundEffectEnabled(v, "compressor", false)
                                    else
                                        local fVolume = fVolume * 0.5
                                        local fVolume = fVolume < 0.01 and 0 or fVolume
                                        setSoundVolume(v, fVolume)
                                        --setSoundEffectEnabled(v, "compressor", true)
                                    end
                                elseif getElementData(v, "char.voice") == "local" then
                                    local vecSoundPos = v.position
                                    local vecCamPos = Camera.position
                                    local fDistance = (vecSoundPos - vecCamPos).length
                                    local fMaxVol = v:getData("maxVol") or 75 -- Hangerőt itt tudjátok átírni (( Bármi 5000 felett már earrape ))
                                    local fMinDistance = v:getData("minDist") or 5
                                    local fMaxDistance = v:getData("maxDist") or 25
                        
                                    local fPanSharpness = 1.0
                                    if (fMinDistance ~= fMinDistance * 2) then
                                        fPanSharpness = math.max(0, math.min(1, (fDistance - fMinDistance) / ((fMinDistance * 2) - fMinDistance)))
                                    end
                        
                                    local fPanLimit = (0.65 * fPanSharpness + 0.35)
                        
                        
                                    local vecLook = Camera.matrix.forward.normalized
                                    local vecSound = (vecSoundPos - vecCamPos).normalized
                                    local cross = vecLook:cross(vecSound)
                                    local fPan = math.max(-fPanLimit, math.min(-cross.z, fPanLimit))
                        
                                    local fDistDiff = fMaxDistance - fMinDistance;
                        
                                    local fVolume
                                    if (fDistance <= fMinDistance) then
                                        fVolume = fMaxVol
                                    elseif (fDistance >= fMaxDistance) then
                                        fVolume = 0.0
                                    else
                                        fVolume = math.exp(-(fDistance - fMinDistance) * (5.0 / fDistDiff)) * fMaxVol
                                    end
                                    setSoundPan(v, fPan)
                        
                                    if isLineOfSightClear(localPlayer.position, vecSoundPos, true, true, false, true, false, true, true, localPlayer) then
                                        setSoundVolume(v, fVolume)
                                        --setSoundEffectEnabled(v, "compressor", false)
                                    else
                                        local fVolume = fVolume * 0.5
                                        local fVolume = fVolume < 0.01 and 0 or fVolume
                                        setSoundVolume(v, fVolume)
                                        --setSoundEffectEnabled(v, "compressor", true)
                                    end
                                end
                            else
                                local vecSoundPos = v.position
                                local vecCamPos = Camera.position
                                local fDistance = (vecSoundPos - vecCamPos).length
                                local fMaxVol = v:getData("maxVol") or 75 -- Hangerőt itt tudjátok átírni (( Bármi 5000 felett már earrape ))
                                local fMinDistance = v:getData("minDist") or 5
                                local fMaxDistance = v:getData("maxDist") or 25
                    
                                local fPanSharpness = 1.0
                                if (fMinDistance ~= fMinDistance * 2) then
                                    fPanSharpness = math.max(0, math.min(1, (fDistance - fMinDistance) / ((fMinDistance * 2) - fMinDistance)))
                                end
                    
                                local fPanLimit = (0.65 * fPanSharpness + 0.35)
                    
                    
                                local vecLook = Camera.matrix.forward.normalized
                                local vecSound = (vecSoundPos - vecCamPos).normalized
                                local cross = vecLook:cross(vecSound)
                                local fPan = math.max(-fPanLimit, math.min(-cross.z, fPanLimit))
                    
                                local fDistDiff = fMaxDistance - fMinDistance;
                    
                                local fVolume
                                if (fDistance <= fMinDistance) then
                                    fVolume = fMaxVol
                                elseif (fDistance >= fMaxDistance) then
                                    fVolume = 0.0
                                else
                                    fVolume = math.exp(-(fDistance - fMinDistance) * (5.0 / fDistDiff)) * fMaxVol
                                end
                                setSoundPan(v, fPan)
                    
                                if isLineOfSightClear(localPlayer.position, vecSoundPos, true, true, false, true, false, true, true, localPlayer) then
                                    setSoundVolume(v, fVolume)
                                    --setSoundEffectEnabled(v, "compressor", false)
                                else
                                    local fVolume = fVolume * 0.5
                                    local fVolume = fVolume < 0.01 and 0 or fVolume
                                    setSoundVolume(v, fVolume)
                                   -- setSoundEffectEnabled(v, "compressor", true)
                                end
                            end
                        else
                            local vecSoundPos = v.position
                            local vecCamPos = Camera.position
                            local fDistance = (vecSoundPos - vecCamPos).length
                            local fMaxVol = v:getData("maxVol") or 75 -- Hangerőt itt tudjátok átírni (( Bármi 5000 felett már earrape ))
                            local fMinDistance = v:getData("minDist") or 5
                            local fMaxDistance = v:getData("maxDist") or 25
                
                            local fPanSharpness = 1.0
                            if (fMinDistance ~= fMinDistance * 2) then
                                fPanSharpness = math.max(0, math.min(1, (fDistance - fMinDistance) / ((fMinDistance * 2) - fMinDistance)))
                            end
                
                            local fPanLimit = (0.65 * fPanSharpness + 0.35)
                
                
                            local vecLook = Camera.matrix.forward.normalized
                            local vecSound = (vecSoundPos - vecCamPos).normalized
                            local cross = vecLook:cross(vecSound)
                            local fPan = math.max(-fPanLimit, math.min(-cross.z, fPanLimit))
                
                            local fDistDiff = fMaxDistance - fMinDistance;
                
                            local fVolume
                            if (fDistance <= fMinDistance) then
                                fVolume = fMaxVol
                            elseif (fDistance >= fMaxDistance) then
                                fVolume = 0.0
                            else
                                fVolume = math.exp(-(fDistance - fMinDistance) * (5.0 / fDistDiff)) * fMaxVol
                            end
                            setSoundPan(v, fPan)
                
                            if isLineOfSightClear(localPlayer.position, vecSoundPos, true, true, false, true, false, true, true, localPlayer) then
                                setSoundVolume(v, fVolume)
                                --setSoundEffectEnabled(v, "compressor", false)
                            else
                                local fVolume = fVolume * 0.5
                                local fVolume = fVolume < 0.01 and 0 or fVolume
                                setSoundVolume(v, fVolume)
                                --setSoundEffectEnabled(v, "compressor", true)
                            end
                        end
                    else
                        local vecSoundPos = v.position
                        local vecCamPos = Camera.position
                        local fDistance = (vecSoundPos - vecCamPos).length
                        local fMaxVol = v:getData("maxVol") or 75 -- Hangerőt itt tudjátok átírni (( Bármi 5000 felett már earrape ))
                        local fMinDistance = v:getData("minDist") or 5
                        local fMaxDistance = v:getData("maxDist") or 25
            
                        local fPanSharpness = 1.0
                        if (fMinDistance ~= fMinDistance * 2) then
                            fPanSharpness = math.max(0, math.min(1, (fDistance - fMinDistance) / ((fMinDistance * 2) - fMinDistance)))
                        end
            
                        local fPanLimit = (0.65 * fPanSharpness + 0.35)
            
            
                        local vecLook = Camera.matrix.forward.normalized
                        local vecSound = (vecSoundPos - vecCamPos).normalized
                        local cross = vecLook:cross(vecSound)
                        local fPan = math.max(-fPanLimit, math.min(-cross.z, fPanLimit))
            
                        local fDistDiff = fMaxDistance - fMinDistance;
            
                        local fVolume
                        if (fDistance <= fMinDistance) then
                            fVolume = fMaxVol
                        elseif (fDistance >= fMaxDistance) then
                            fVolume = 0.0
                        else
                            fVolume = math.exp(-(fDistance - fMinDistance) * (5.0 / fDistDiff)) * fMaxVol
                        end
                        setSoundPan(v, fPan)
            
                        if isLineOfSightClear(localPlayer.position, vecSoundPos, true, true, false, true, false, true, true, localPlayer) then
                            setSoundVolume(v, fVolume)
                            --setSoundEffectEnabled(v, "compressor", false)
                        else
                            local fVolume = fVolume * 0.5
                            local fVolume = fVolume < 0.01 and 0 or fVolume
                            setSoundVolume(v, fVolume)
                            --setSoundEffectEnabled(v, "compressor", true)
                        end
                    end
                end
            end
        end
    end
, false)

bindKey("-", "down",
    function()
        if getTickCount() - time > 1000 then
            if voiceState == "local" then
                local myTune = getElementData(localPlayer, "currentRadioTune")
                if myTune then
                    if myTune[2] ~= "N" then
                        voiceState = "radio"
                        time = getTickCount()
                        broadcastToRadio()

                        setElementData(localPlayer, "char.voice", voiceState)
                    else
                        exports.cosmo_hud:showInfobox("warning", "A Walkie-Talkie némítva van, így nem használhatod a voice-t!")
                    end
                end
            elseif voiceState == "radio" then
                voiceState = "local"
                time = getTickCount()

                setElementData(localPlayer, "char.voice", voiceState)
                triggerServerEvent("proximity-voice::broadcastUpdate", localPlayer, getElementsByType("player", root, true))
            end
        end
    end
)

function broadcastToRadio()
    local a = {}
    local myTune = getElementData(localPlayer, "currentRadioTune")
    local myCH = 0
    if myTune then
        myCH = myTune[1]
    end

    for i, v in ipairs(getElementsByType("player", root, false)) do
        local radioTune = getElementData(v, "currentRadioTune")

        if radioTune then
            local radioCH = radioTune[1]

            if radioCH == myCH and radioCH > 0 then
                if v ~= localPlayer then
                    if radioTune[2] ~= "N" then
                        table.insert(a, v)
                    end
                end
            end
        end
    end

    for i, v in ipairs(getElementsByType("player", root, true)) do
        table.insert(a, v)
    end

    triggerServerEvent("broadcastToRadioPlayers", localPlayer, localPlayer, a)
end

addEventHandler("onClientElementStreamIn", root,
    function ()
        if source:getType() == "player" then

            if getElementData(localPlayer, "char.voice") == "local" then
                triggerServerEvent("proximity-voice::broadcastUpdate", localPlayer, getElementsByType("player", root, false))
            elseif getElementData(localPlayer, "char.voice") == "radio" then
                broadcastToRadio()
            end
        end
    end
)
addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        RobotoFont = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", 10, false, "antialiased")
        triggerServerEvent("proximity-voice::broadcastUpdate", localPlayer, getElementsByType("player", root, false))
        
        setElementData(localPlayer, "char.voice", "local")
    end
, false)

addEventHandler("onClientElementDataChange", root, 
    function(data, oldValue, newValue)
        if (getElementType(source) == "player") and (data == "currentRadioTune") then
            local myTune = getElementData(source, "currentRadioTune")

            if myTune[2] ~= "N" then
                broadcastToRadio()
            elseif myTune[2] ~= "Y" then
                triggerServerEvent("proximity-voice::broadcastUpdate", localPlayer, getElementsByType("player", root, false))
                setElementData(source, "char.voice", "local")
            end
         end
    end
)