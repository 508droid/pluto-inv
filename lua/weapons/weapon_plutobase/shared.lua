SWEP.Base = "weapon_tttbase_old"
DEFINE_BASECLASS "weapon_tttbase_old"

local WEAPON = FindMetaTable "Weapon"

function WEAPON:GetPrintName()
	if (self.GetPlutoPrintName) then
		return self:GetPlutoPrintName() or self.PrintName
	end

	return self.PrintName
end

pluto.wpn_db = pluto.wpn_db or {}

function WEAPON:GetInventoryItem()
	return pluto.wpn_db[self:GetPlutoID()]
end

function SWEP:ReceivePlutoData()
	if (self.AlreadyReceived) then
		pwarnf("Already received data!")
		return
	end

	self.AlreadyReceived = true

	if (CLIENT and self:GetOwner() == ttt.GetHUDTarget()) then
		self:DisplayPlutoData()
	end

	local data = self:GetInventoryItem()

	for _, modlist in pairs(data.Mods or {}) do
		for _, mod_data in pairs(modlist) do
			local mod = pluto.mods.byname[mod_data.Mod]
			if (mod and mod.ModifyWeapon) then
				mod:ModifyWeapon(self, pluto.mods.getrolls(mod, mod_data.Tier, mod_data.Roll))
			end
		end
	end
end

pluto.CurrentID = pluto.CurrentID or 0
function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetVar("PlutoID", "Int")
	if (SERVER) then
		self:SetPlutoID(pluto.CurrentID)
		pluto.CurrentID = pluto.CurrentID + 1
	end
end

local function default_translate(old, pct)
	if (pct < 0) then
		pct = 1 / (2 - pct)
	end
	return old * pct
end

function SWEP:DefinePlutoOverrides(type, default, translate)
	if (self.Pluto[type]) then
		return
	end

	self.Pluto[type] = default or 1

	translate = translate or default_translate
	local old = self["Get" .. type]
	self["Get" .. type] = function(self)
		return translate(old(self), self.Pluto[type])
	end
end

function SWEP:ScaleRollType(type, roll, init)
	return roll
end

-- TODO: Make this not do this????
local PenetrationValues = {}

local function set(values, ...)
	for i = 1, select("#", ...) do
		PenetrationValues[select(i, ...)] = values
	end
end
-- flPenetrationModifier, flDamageModifier
-- flDamageModifier should always be less than flPenetrationModifier
set({0.3, 0.1},  MAT_CONCRETE, MAT_METAL)
set({0.8, 0.7},  MAT_FOLIAGE, MAT_SAND, MAT_GRASS, MAT_DIRT, MAT_FLESH, MAT_GLASS, MAT_COMPUTER, MAT_TILE, MAT_WOOD, MAT_PLASTIC, MAT_SLOSH, MAT_SNOW)
set({0.5, 0.45}, MAT_FLESH, MAT_ALIENFLESH, MAT_ANTLION, MAT_BLOODYFLESH, MAT_SLOSH, MAT_CLIP)
set({1, 0.99},   MAT_GRATE)
set({0.5, 0.45}, MAT_DEFAULT)
function SWEP:TraceToExit(start, dir, endpos, stepsize, maxdistance)

	local flDistance = 0
	local last = start

	while (flDistance < maxdistance) do
		flDistance = flDistance + stepsize

		endpos:Set(start + flDistance *dir)

		if bit.band(util.PointContents(endpos), MASK_SOLID) == 0 then
			return true, endpos
		end
	end

	return false

end
function SWEP:ImpactTrace(tr)
	local e = EffectData()
	e:SetOrigin(tr.HitPos)
	e:SetStart(tr.StartPos)
	e:SetSurfaceProp(tr.SurfaceProps)
	e:SetDamageType(DMG_BULLET)
	e:SetHitBox(0)
	if CLIENT then
		e:SetEntity(game.GetWorld())
	else
		e:SetEntIndex(0)
	end
	util.Effect("Impact", e)
end

function SWEP:PenetrateBullet(dir, vecStart, flDistance, iPenetration, iDamage,
	flRangeModifier, fPenetrationPower, flPenetrationDistance, flCurrentDistance, alreadyHit)
	alreadyHit = alreadyHit or {}
	flCurrentDistance = flCurrentDistance or 0
	self:SetBulletsShot(self:GetBulletsShot() + 1)

	self:FireBullets {
		AmmoType = self.Primary.Ammo,
		Distance = flDistance,
		Tracer = 1,
		Attacker = self:GetOwner(),
		Damage = iDamage,
		Src = vecStart,
		Dir = dir,
		Spread = vector_origin,
		Num = 1,
		IgnoreEntity = lasthit,
		Callback = function( hitent , trace , dmginfo )
			--TODO: penetration
			--unfortunately this can't be done with a static function or we'd need to set global variables for range and shit

			if flRangeModifier then
				--Jvs: the damage modifier valve actually uses
				local flCurrentDistance = trace.Fraction * flDistance
				dmginfo:SetDamage( dmginfo:GetDamage() * math.pow( flRangeModifier, ( flCurrentDistance / 500 ) ) )
			end

			if (alreadyHit[trace.Entity]) then
				dmginfo:SetDamage(0)
			end
			alreadyHit[trace.Entity] = true

			if (IsValid(self)) then
				self:FireBulletsCallback(trace, dmginfo)
			end

			if (trace.Fraction == 1) then
				return
			end
			-- TODO: convert this to physprops? there doesn't seem to be a way to get penetration from those

			local flPenetrationModifier, flDamageModifier = unpack(PenetrationValues[trace.MatType] or PenetrationValues[MAT_DEFAULT])

			flCurrentDistance = flCurrentDistance + trace.Fraction * (trace.HitPos - vecStart):Length()
			iDamage = iDamage * flRangeModifier ^ (flCurrentDistance / 500)

			if (flCurrentDistance > flPenetrationDistance && iPenetration > 0) then
				iPenetration = 0;
			end

			if iPenetration == 0 and not trace.MatType == MAT_GRATE then
				return
			end

			if iPenetration < 0 then
				return
			end

			local penetrationEnd = Vector()

			if not self:TraceToExit(trace.HitPos, dir, penetrationEnd, 24, 128) then
				return
			end

			local tr = util.TraceLine{
				start = penetrationEnd + trace.Normal * 2,
				endpos = trace.HitPos,
				mask = MASK_SHOT,
				collisiongroup = COLLISION_GROUP_NONE,
			}

			bHitGrate = tr.MatType == MAT_GRATE and bHitGrate

			local iExitMaterial = tr.MatType

			if (iExitMaterial == trace.MatType) then
				if (iExitMaterial == MAT_WOOD or iExitMaterial == MAT_METAL) then
					flPenetrationModifier = flPenetrationModifier * 2
				end
			end

			local flTraceDistance = tr.HitPos:Distance(trace.HitPos)

			if (flTraceDistance > (fPenetrationPower * flPenetrationModifier)) then
				return
			end
			self:ImpactTrace(tr)
			fPenetrationPower = fPenetrationPower - flTraceDistance / flPenetrationModifier
			flCurrentDistance = flCurrentDistance + flTraceDistance

			vecStart = tr.HitPos
			flDistance = (flDistance - flCurrentDistance) * .5

			iDamage = iDamage * flDamageModifier

			iPenetration = iPenetration - 1

			self:PenetrateBullet(dir, vecStart, flDistance, iPenetration, iDamage, flRangeModifier, fPenetrationPower, flPenetrationDistance, flCurrentDistance, alreadyHit)
		end
	}
end

function SWEP:DoFireBullets(...)
	if (self.Primary and self.Primary.PenetrationValue) then
		self:PenetrateBullet(self:GetOwner():GetAimVector(), self:GetOwner():GetShootPos(), 8192, 4, self:GetDamage(),
			0.99, self.PenetrationValue, 8000)
		return 1
	else
		return BaseClass.DoFireBullets(self, ...)
	end
end
