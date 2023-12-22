white = "#FFFFFF";


function isFaction(player)
    return exports.cosmo_groups:isPlayerHavePermission(player,"weaponShip")
end

function tableRand(tbl)
    local size = #tbl
    for i = size, 1, -1 do
        local rand = math.random(size)
        tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end
    return tbl
end