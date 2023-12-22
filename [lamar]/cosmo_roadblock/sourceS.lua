local createdObjectTable = {}


function syncObjectToServer(index, modelid, x, y, z, rx, ry, rz)
    if not createdObjectTable[source] then
        createdObjectTable[source] = {}
    end
    createdObjectTable[source][index] = createObject(modelid, x, y, z, rx, ry, rz)
end
addEvent("syncObjectToServer", true)
addEventHandler("syncObjectToServer", getRootElement(), syncObjectToServer)


function deleteObjectServerSide(index)
    if isElement(createdObjectTable[source][index]) then
        destroyElement(createdObjectTable[source][index])
        createdObjectTable[source][index] = nil
    end
end
addEvent("deleteObjectServerSide", true)
addEventHandler("deleteObjectServerSide", getRootElement(), deleteObjectServerSide)
