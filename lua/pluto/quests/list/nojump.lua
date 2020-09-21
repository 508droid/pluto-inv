QUEST.Name = "Cemented"
QUEST.Description = "Kill people rightfully in one round without jumping"
QUEST.Credits = "add__123"
QUEST.Color = Color(204, 61, 5)

function QUEST:GetRewardText(seed)
	return "gun with at most 4 mods and a random implicit"
end

function QUEST:Init(data)
	local current = 0
	data:Hook("TTTBeginRound", function(data, gren)
		current = 0
	end)

	data:Hook("KeyPress", function(data, ply, key)
		if (ply == data.Player and key == IN_JUMP and ply:IsOnGround()) then
			current = 0
		end
	end)

	data:Hook("PlayerDeath", function(data, vic, inf, atk)
		if (atk == data.Player and atk:GetRoleTeam() ~= vic:GetRoleTeam()) then
			current = current + 1

			if (current == data.ProgressLeft) then
				data:UpdateProgress(data.ProgressLeft)
			end
		end
	end)
end

function QUEST:Reward(data)
	local gun = pluto.weapons.randomgun()
	local new_item = pluto.weapons.generatetier(pluto.tiers.filter(baseclass.Get(gun), function(t)
		return t.affixes <= 4
	end), gun)

	local mod = table.shuffle(pluto.mods.getfor(baseclass.Get(new_item.ClassName), function(mod)
		return mod.Type == "implicit" and not mod.PreventChange and not mod.NoCoined
	end))[1]

	pluto.weapons.addmod(new_item, mod.InternalName)

	pluto.inv.savebufferitem(data.Player, new_item):Run()

	data.Player:ChatPrint(white_text, "You have received ", startswithvowel(new_item.Tier.Name) and "an " or "a ", new_item, white_text, " with the ", mod, white_text, " modifier completing ", self.Color, self.Name, white_text, "! Check your inventory.")
end

function QUEST:IsType(type)
	return type == 1
end

function QUEST:GetProgressNeeded(type)
	return math.random(2, 3)
end