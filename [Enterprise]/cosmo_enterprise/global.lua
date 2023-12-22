function isInEnterprise(player, ent)
    if all_enterprise[ent] then
        local dbid = getElementData(player, "char.ID")
        for i, k in pairs(all_enterprise[ent]["members"]) do
            if k["account"] == dbid then
                return true
            end
        end
    end
    return false
end

function getEnterpriseType(ent)
    if all_enterprise[ent] then
        return all_enterprise[ent]["type"], types[all_enterprise[ent]["type"]]
    end
    return nil
end

function getPlayerEnterpriseRank(player, ent)
    if all_enterprise[ent] then
        local dbid = getElementData(player, "char.ID")
        for i, k in pairs(all_enterprise[ent]["members"]) do
            if k["account"] == dbid then
                local rank, rankname, rankpay = k["rank"], all_enterprise[ent]["rank_names"][k["rank"]], all_enterprise[ent]["rank_pays"][k["rank"]]
                return rank, rankname, rankpay
            end
        end
    end
    return 0
end

function getEnterpriseMoney(ent)
    if all_enterprise[ent] then
        return all_enterprise[ent]["balance"]
    end
    return 0
end

function getEnterpriseLicense(ent)
    if all_enterprise[ent] then
        return all_enterprise[ent]["license"]
    end
    return false
end

function getPlayerEnterprises(player)
    local dbid = getElementData(player, "char.ID")
    local temp = {}
    for i, k in pairs(all_enterprise) do
        local id = i
        local membersTemp = all_enterprise[id]["members"]
        for j=1, #membersTemp do
            if membersTemp[j]["account"] == dbid then
                if membersTemp[j]["leader"] == 1 then 
                    table.insert(temp, k)
                end
            end
        end
    end
    return temp
end

function getPlayerEnterprisesNotLeader(player)
    local dbid = getElementData(player, "char.ID")
    local temp = {}
    for i, k in pairs(all_enterprise) do
        local id = i
        local membersTemp = all_enterprise[id]["members"]
        for j=1, #membersTemp do
            if membersTemp[j]["account"] == dbid then
				table.insert(temp, k)
            end
        end
    end
    return temp
end

function takeEnterpriseMoney(player, ent, money, update)
	if ent == 16 then
		return true
	end
    if all_enterprise[ent] then
        local balance = all_enterprise[ent]["balance"]
        local newBalance = math.floor(balance-money)
        if newBalance >= 0 then
            triggerServerEvent("server->removeMoney", player, ent, newBalance, update, money)
            return true
        else
            return false
        end
    end
    return false
end

function giveEnterpriseMoney(player, ent, money, update)
    if all_enterprise[ent] then
        local balance = all_enterprise[ent]["balance"]
        local money = money*0.85
        local newBalance = balance+money
        if newBalance >= 0 then
            triggerServerEvent("server->addMoney", player, ent, newBalance, update, money)
            return true
        else
            return false
        end
    end
    return false
end

function hasPermission(player, ent, permission)
    if all_enterprise[ent] then
        local dbid = getElementData(player, "char.ID")
        local membersTemp = all_enterprise[ent]["members"]
        for j=1, #membersTemp do
            if membersTemp[j]["account"] == dbid then
                local permissions = fromJSON(membersTemp[j]["permissions"])
                for i, k in pairs(permissions) do
                    if i == permission then
                        if k then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

types = {
    [4] = "Autókereskedés",
}


function formatMoney(amount, spacer)
	if not spacer then spacer = "," end
	amount = math.floor(amount)
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1'..spacer):reverse())..right
end