return function(obj)
	local db = {
		queries = {},
		prepared = {},
		db = obj
	}

	local function err(...)
		pwarnf("DATABASE ERROR: %s\n%s", string.format(...), debug.traceback())
	end


	function db.query(query, args, cb, data, nostart)
		local q

		if (args) then
			q = db.prepared[query]
			if (not q) then
				q = db.db:prepare(query)
				db.prepared[query] = q
				q.args = {}
			elseif (q.args) then
				for ind in pairs(q.args) do
					q:setNull(ind)
				end
			end
			for ind, arg in pairs(args) do
				if (type(arg) == "number") then
					q:setNumber(ind, arg)
				elseif (type(arg) == "string") then
					q:setString(ind, arg)
				elseif (type(arg) == "boolean") then
					q:setBoolean(ind, arg)
				else
					q:setNull(ind)
				end

				q.args[ind] = true
			end
		else
			q = db.db:query(query)
		end

		function q:onAborted()
			err("abort")
			if (not cb) then
				return
			end

			cb("aborted", self)
		end

		function q:onError(e, sql)
			err("%s: %s", e, sql)
			if (not cb) then
				return
			end

			cb(e, self, sql)
		end

		function q:onSuccess(d)
			if (not cb) then
				return
			end

			cb(nil, self, d)
		end

		if (data) then
			function q:onData(d)
				data(self, d)
			end
		end

		if (not nostart) then
			q:start()
		end

		return q
	end

	function db.transact(queries, cb, nostart)
		local transact = db.db:createTransaction()

		local start

		for i, query in ipairs(queries) do
			if (type(query) == "table") then
				query[5] = true -- nostart
				queries[i] = db.query(unpack(query, 1, 5))
			elseif (type(query) == "string") then
				queries[i] = db.query(query, nil, nil, nil, true)
			end

			transact:addQuery(queries[i])
			if (type(query) == "table" and query[2]) then
				for ind in pairs(query[2]) do
					queries[i]:setNull(ind)
				end
			end
		end

		function transact:onSuccess(...)
			if (not cb) then
				return
			end

			cb(nil, self)
		end

		function transact:onError(e)
			err("%s", e)
			if (not cb) then
				return
			end

			cb(e, self)
		end

		start = SysTime()

		if (not nostart) then
			transact:start()
		end

		return transact, queries
	end

	function db.steamid64(obj)
		if (TypeID(obj) == TYPE_ENTITY) then
			return obj:SteamID64()
		end

		if (type(obj) == "string" and obj:StartWith "S") then
			obj = util.SteamIDTo64(obj)
		end

		if (not obj) then
			error("Bad object to convert to steamid: " .. tostring(obj))
		end

		return obj
	end

	return db
end