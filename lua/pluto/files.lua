local function realfile(fname)
	if (file.Exists(fname, "LUA")) then
		return fname
	end

	local upv = debug.getinfo(2, "S").short_src:GetPathFromFilename():gsub("^addons/[^/]+/", ""):gsub("^lua/", "") .. fname

	if (file.Exists(upv, "LUA")) then
		return upv
	end

	if (file.Exists("pluto/" .. fname, "LUA")) then
		return "pluto/" .. fname
	end

	return fname
end

return function(self)
	for _, file in ipairs(self.Shared) do
		file = realfile(file)
		if (SERVER) then
			AddCSLuaFile(file)
		end
		include(file)
	end

	for _, file in ipairs(SERVER and self.Server or self.Client) do
		file = realfile(file)
		include(file)
	end

	if (CLIENT) then return end
	
	for _, file in ipairs(self.Resources) do
		resource.AddFile(file)
	end

	for _, file in ipairs(self.Client) do
		file = realfile(file)
		AddCSLuaFile(file)
	end
end