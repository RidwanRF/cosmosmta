mainCategories = {}
availableItems = {}
itemBasePrices = {}
itemCategories = {}

function addAnItem(itemId, basePrice)
	if type(itemId) == "string" then
		table.insert(mainCategories, itemId)
	else
		availableItems[itemId] = true
		itemBasePrices[itemId] = math.floor(basePrice)
		itemCategories[itemId] = #mainCategories
	end
end

addAnItem("Gyorsételek")
addAnItem(45, 50000)
addAnItem(46, 50000)
addAnItem(47, 50000)
addAnItem(48, 50000)
addAnItem(49, 50000)
addAnItem(50, 50000)
addAnItem(51, 50000)
addAnItem("Üdítők")
addAnItem(52, 45000)
addAnItem(53, 45000)
addAnItem(54, 45000)
addAnItem(55, 45000)
addAnItem(56, 45000)
--addAnItem(57, 20)
addAnItem(58, 45000)
--addAnItem(59, 20)
addAnItem(60, 45000)
addAnItem(61, 45000)
addAnItem("Forró italok")
addAnItem(70, 60000)
addAnItem("Alkohol/Cigaretta")
addAnItem(62, 70000)
addAnItem(63, 70000)
addAnItem(64, 70000)
addAnItem(65, 70000)
addAnItem(66, 70000)
addAnItem(67, 70000)
addAnItem(68, 70000)
addAnItem(69, 70000)
addAnItem(97, 70000)
addAnItem(98, 70000)
addAnItem("Műszaki")
addAnItem(28, 200000)
addAnItem(44, 150000)
addAnItem(71, 400000)
addAnItem(79, 320000)
addAnItem(82, 500000)
addAnItem("Szerszámok")
addAnItem(33, 250000)
addAnItem(37, 250000)
addAnItem(180, 700000)
addAnItem("Hobby")
addAnItem(32, 700000)
addAnItem(25, 150000)
addAnItem(42, 10000)
addAnItem(200, 85000)
addAnItem("Egészség")
addAnItem(105, 75000)
addAnItem(106, 50000)
addAnItem(90, 115000)
addAnItem(122, 35000)
addAnItem("Lőszerek")
addAnItem(3, 10000)
addAnItem(4, 10000)
addAnItem(5, 10000)
addAnItem(6, 10000)
addAnItem(7, 10000)
addAnItem(8, 10000)
addAnItem("FegyverNPC")
addAnItem(9, 400000)
addAnItem(10, 400000)
addAnItem(11, 400000)
addAnItem(12, 400000)
addAnItem(13, 400000)
addAnItem(14, 400000)
addAnItem(15, 400000)
addAnItem(16, 400000)
addAnItem(17, 400000)
addAnItem(18, 800000)
addAnItem(19, 400000)
addAnItem(20, 800000)
addAnItem(21, 200000)
addAnItem(31, 400000)


function deepcopy(t)
	if type(t) ~= "table" then return t end
	local meta = getmetatable(t)
	local target = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			target[k] = deepcopy(v)
		else
			target[k] = v
		end
	end
	setmetatable(target, meta)
	return target
end

function table_eq(table1, table2)
	local avoid_loops = {}
	local function recurse(t1, t2)
		-- compare value types
		if type(t1) ~= type(t2) then return false end
		-- Base case: compare simple values
		if type(t1) ~= "table" then return t1 == t2 end
		-- Now, on to tables.
		-- First, let's avoid looping forever.
		if avoid_loops[t1] then return avoid_loops[t1] == t2 end
		avoid_loops[t1] = t2
		-- Copy keys from t2
		local t2keys = {}
		local t2tablekeys = {}
		for k, _ in pairs(t2) do
			if type(k) == "table" then table.insert(t2tablekeys, k) end
			t2keys[k] = true
		end
		-- Let's iterate keys from t1
		for k1, v1 in pairs(t1) do
			local v2 = t2[k1]
			if type(k1) == "table" then
				-- if key is a table, we need to find an equivalent one.
				local ok = false
				for i, tk in ipairs(t2tablekeys) do
					if table_eq(k1, tk) and recurse(v1, t2[tk]) then
						table.remove(t2tablekeys, i)
						t2keys[tk] = nil
						ok = true
						break
					end
				end
				if not ok then return false end
			else
				-- t1 has a key which t2 doesn't have, fail.
				if v2 == nil then return false end
				t2keys[k1] = nil
				if not recurse(v1, v2) then return false end
			end
		end
		-- if t2 has a key which t1 doesn't have, fail.
		if next(t2keys) then return false end
		return true
	end
	return recurse(table1, table2)
end