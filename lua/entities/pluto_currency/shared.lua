AddCSLuaFile()
ENT.Base = "ttt_point_info"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Icon")
end

function ENT:Initialize()
	self.Size = 20
	local maxs = Vector(self.Size / 2, self.Size / 2, self.Size / 2)
	self:SetCollisionBounds(-maxs, maxs)
	if (SERVER) then
		self:SV_Initialize()
	end

	self.random = math.random()
	hook.Add("ShouldCollide", self, self.ShouldCollide)
end

function ENT:ShouldCollide(e1, e2)
	if (e1 ~= self and e2 ~= self) then
		return
	end

	local other = e1 == self and e2 or e1

	return other == self:GetOwner()
end