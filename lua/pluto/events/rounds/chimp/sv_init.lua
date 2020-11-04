resource.AddFile("sound/pluto/dkrap.ogg") -- REMOVE ME

ROUND.Name = "Monke Mania"
ROUND.BananasPerPlayer = 6
ROUND.KillStealMin = 0.25
ROUND.KillStealMax = 0.45
ROUND.HealthPerBanana = 10
ROUND.BananasPerEgg = 10
ROUND.WinnerBonus = 3
ROUND.CollisionGroup = COLLISION_GROUP_DEBRIS_TRIGGER

util.AddNetworkString "chimp_data"

ROUND.Boss = true

function ROUND:Prepare(state)
	timer.Create("pluto_event_timer", 5, 0, function()
		if (not state.playerscores) then
			return
		end
		for ply, count in pairs(state.playerscores) do
			if (IsValid(ply) and not ply:Alive()) then
				ttt.ForcePlayerSpawn(ply)
			end
		end
	end)

	timer.Pause("tttrw_afk")
end

function ROUND:Finish()
	timer.Remove "pluto_event_timer"
end

function ROUND:Loadout(ply)
	ply:StripWeapons()
	ply:Give "tfa_cso_ruyi"
end

ROUND:Hook("TTTSelectRoles", function(self, state, plys)
	plys = table.shuffle(plys)

	local roles_needed = {
		["Banna Boss"] = 1,
	}

	for i, ply in ipairs(plys) do
		local role, amt = next(roles_needed)
		if (role) then
			if (amt == 1) then
				roles_needed[role] = nil
			else
				roles_needed[role] = amt - 1
			end
		else
			role = "Monke"
		end

		ply:StripWeapons()
		pluto.NextWeaponSpawn = false
		ply:Give "tfa_cso_ruyi"

		round.Players[i] = {
			Player = ply,
			SteamID = ply:SteamID(),
			Nick = ply:Nick(),
			Role = ttt.roles[role]
		}
	end

	return true
end)

local Doors = {
	"func_door", "func_door_rotating", "prop_door_rotating", "func_breakable", "func_breakable_surf"
}

for _, v in pairs(Doors) do
	Doors[v] = true
end

ROUND:Hook("TTTBeginRound", function(self, state)
	for _, ent in pairs(ents.GetAll()) do
		if (Doors[ent:GetClass()]) then
			ent:Remove()
		end
	end

	local monkes = round.GetActivePlayersByRole "Monke"
	local banna = round.GetActivePlayersByRole "Banna Boss"
	state.players = {}
	state.playerscores = {}

	for k, ply in pairs(monkes) do
		state.playerscores[ply] = 0
		table.insert(state.players, ply)
		if (ply:Alive()) then
			self:Initialize(state, ply)
		end
	end

	for k, ply in pairs(banna) do
		state.leader = ply
		state.playerscores[ply] = 0
		table.insert(state.players, ply)
		if (ply:Alive()) then
			self:Initialize(state, ply)
		end
	end

	state.bananas = {}

	for k, ply in ipairs(state.players) do
		if IsValid(ply) then
			local tospawn = self.BananasPerPlayer
			while (tospawn > 0) do
				tospawn = tospawn - 1
				table.insert(state.bananas, pluto.currency.spawnfor(ply, "_banna", nil, true))
			end

			self:UpdateScore(state, ply, 0)
		end
	end

	net.Start "chimp_data"
		net.WriteString "currency_left"
		net.WriteUInt(#state.bananas, 32)
	net.Broadcast()

	self:ChooseLeader(state)

	GetConVar("ttt_karma"):SetBool(false)
	
	timer.Simple(1, function()
		round.SetRoundEndTime(CurTime() + 190)
		ttt.SetVisibleRoundEndTime(CurTime() + 190)
	end)
end)

ROUND:Hook("TTTUpdatePlayerSpeed", function(self, state, ply, data)
	if (state.playerscores and state.playerscores[ply]) then
		data["chimp"] = 1.2 + math.min(0.4, (state.playerscores[ply] * 0.08))
	end
end)

ROUND:Hook("PostPlayerDeath", function(self, state, ply)
	ply:Extinguish()
	return true
end)

function ROUND:Initialize(state, ply)
	self:PlayerSetModel(state, ply)
	self:Spawn(state, ply)
	local pos = self:ResetPosition(state, ply)
	if (pos) then
		ply.ForcePos = pos
	end
end

function ROUND:ChooseLeader(state)
	local new = table.SortByKey(state.playerscores)[1]

	if (IsValid(new)) then
		if (IsValid(state.leader) and new ~= state.leader) then
			state.leader:SetRole("Monke")
			state.leader:SetModelScale(1, 0)
			ttt.chat(ttt.roles["Banna Boss"].Color, new:Nick(), white_text, " new banna boss!")
		end
		state.leader = new
		--new:SetModelScale(1.2, 1)
		new:SetRole("Banna Boss")
		net.Start "chimp_data"
			net.WriteString "current_leader"
			net.WriteString(new:Nick() .. " hav " .. state.playerscores[new] .. " banna")
		net.Broadcast()
	end
end

function ROUND:UpdateScore(state, ply, amt)
	state.playerscores[ply] = (state.playerscores[ply] or 0) + amt

	net.Start "chimp_data"
		net.WriteString "currency_collected"
		net.WriteUInt(state.playerscores[ply], 32)
	net.Send(ply)

	self:ChooseLeader(state)
end

ROUND:Hook("SetupMove", function(self, state, ply, mv)
	if (ply.ForcePos) then
		mv:SetOrigin(ply.ForcePos)
		ply.ForcePos = nil
	end
end)

function ROUND:Spawn(state, ply)
	ply:SetCollisionGroup(self.CollisionGroup)
	if (state.players and state.players[ply]) then
		ply:SetHealth(100)
		ply:SetMaxHealth(100)
	end
	ply.LastBannaAttacker = nil
end

ROUND:Hook("PlayerSpawn", ROUND.Spawn)

local hull_mins, hull_maxs = Vector(-22, -22, 0), Vector(22, 22, 90)

function ROUND:ResetPosition(state, ply)
	return select(1, pluto.currency.randompos(hull_mins, hull_maxs))
end

ROUND:Hook("PlayerSelectSpawnPosition", ROUND.ResetPosition)

function ROUND:TTTEndRound(state)
	for _, ent in pairs(state.bananas) do
		if (IsValid(ent)) then
			ent:Remove() -- DOES NOT WORK, PLEASE FIX
		end
	end

	self:ChooseLeader(state)

	state.leader:SetModelScale(1, 0)

	for ply, score in pairs(state.playerscores) do
		local togive = math.floor((score + self.BananasPerEgg / 2) / self.BananasPerEgg)
		pluto.db.instance(function(db)
			pluto.inv.addcurrency(db, ply, "brainegg", togive)
			ply:ChatPrint(white_text, "Monke get ", togive, " ", pluto.currency.byname.brainegg, white_text, " for hav ", score, " ", pluto.currency.byname._banna, white_text, "!")
		end)
	end

	if (IsValid(state.leader)) then
		ttt.chat(ttt.roles["Banna Boss"].Color, state.leader:Nick(), white_text, " banna king!")
		pluto.db.instance(function(db)
			pluto.inv.addcurrency(db, state.leader, "brainegg", self.WinnerBonus)
			state.leader:ChatPrint(white_text, "Monke get ", self.WinnerBonus	, " extra ", pluto.currency.byname.brainegg, white_text, " for be banna king!")
		end)
	else
		ttt.chat("All monke suck")
	end

	GetConVar("ttt_karma"):Revert()

	timer.UnPause("tttrw_afk")
end

function ROUND:SendUpdateBananas(state)
	local left = -1
	for _, ent in ipairs(state.bananas) do
		if (IsValid(ent)) then
			left = left + 1
		end
	end

	net.Start "chimp_data"
		net.WriteString "currency_left"
		net.WriteUInt(left, 32)
	net.Broadcast()
end

ROUND:Hook("PlutoBannaPickup", function(self, state, ply)
	self:SendUpdateBananas(state)

	if (ply:Alive()) then
		ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + self.HealthPerBanana))
	end

	self:UpdateScore(state, ply, 1)
end)

ROUND:Hook("PlayerCanPickupWeapon", function(self, state, ply, wep)
	return wep:GetClass() == "tfa_cso_ruyi"
end)

ROUND:Hook("TTTHasRoundBeenWon", function(self, state)
	if (#round.GetActivePlayersByRole "Monke" == 0) then
		return true, "traitor", false
	end

	return false
end)

ROUND:Hook("EntityTakeDamage", function(self, state, targ, dmg)
	local atk = dmg:GetAttacker()
	if (not IsValid(targ) or not targ:IsPlayer()) then
		return
	end
	if (not IsValid(atk) or not atk:IsPlayer()) then
		return
	end

	targ.LastBannaAttacker = atk
end)

ROUND:Hook("PlayerDisconnected", function(self, state, ply)
	if (not state.playerscores or not state.playerscores[ply]) then
		return
	end

	local tosteal = state.playerscores[ply]

	for i = 1, tosteal do
		table.insert(state.bananas, pluto.currency.spawnfor(player.GetAll()[1], "_banna", nil, true))
	end
	self:SendUpdateBananas(state)
	state.playerscores[ply] = nil
end)

ROUND:Hook("PlayerDeath", function(self, state, vic, inf, att)
	if (not IsValid(vic)) then
		return
	end

	if (not state.playerscores or not state.playerscores[vic]) then
		return
	end

	local tosteal = state.playerscores[vic] > 0 and math.ceil(Lerp(math.random(), self.KillStealMin, self.KillStealMax) * state.playerscores[vic]) or 0

	if (vic == att and IsValid(vic.LastBannaAttacker)) then
		att = vic.LastBannaAttacker
	end

	if (not IsValid(att) or not att:IsPlayer() or vic == att) then
		self:UpdateScore(state, vic, -tosteal)
		for i = 1, tosteal do
			table.insert(state.bananas, pluto.currency.spawnfor(vic, "_banna", nil, true))
		end
		self:SendUpdateBananas(state)
	
		vic:ChatPrint(ttt.teams.traitor.Color, "Monke", white_text, " lose ", tosteal, " banna!")
		return
	end

	self:UpdateScore(state, vic, -tosteal)
	self:UpdateScore(state, att, tosteal)

	if (tosteal > 0) then
		vic:ChatPrint(ttt.teams.traitor.Color, att:Nick(), white_text, " take ", tosteal, " banna from Monke!")
		att:ChatPrint(ttt.roles.Monke.Color, "Monke", white_text, " take ", tosteal, " banna from ", vic:Nick(), "!")
	end

	if (att:Alive()) then
		att:SetHealth(math.min(att:GetMaxHealth(), att:Health() + tosteal * self.HealthPerBanana))
	end
end)

ROUND:Hook("PlayerRagdollCreated", function(self, state, ply, rag, atk, dmg)
	timer.Simple(5, function()
		if (IsValid(rag)) then
			rag:Remove()
		end
	end)
end)

function ROUND:PlayerSetModel(state, ply)
	ply:SetModel(pluto.models["chimp"].Model)

	return true
end