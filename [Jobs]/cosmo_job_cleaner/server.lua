addEvent("job > newspaper > gotoInt", true)
addEventHandler("job > newspaper > gotoInt", resourceRoot, function(startpos)
    --outputChatBox("gotoint")
    setElementData(client, "cleaner:inJobInt", true)
    setElementData(client, "cleaner:startOutPos2", Vector3(getElementPosition(client)))
end)

addEvent("job > newspaper > gotoOut", true)
addEventHandler("job > newspaper > gotoOut", resourceRoot, function()
    setElementData(client, "cleaner:inJobInt", false)
end)

addEvent("cleaner > giveMoney", true)
addEventHandler("cleaner > giveMoney", resourceRoot, function(money)
    setElementData(client, "char.Money", getElementData(client, "char.Money")+money)
end)