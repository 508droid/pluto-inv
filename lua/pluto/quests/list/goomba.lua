QUEST.Name = "Noob Stomper"
QUEST.Description = "Goomba stomp people rightfully"
QUEST.Credits = "Eppen"
QUEST.Color = Color(204, 43, 75)

function QUEST:GetReward(seed)
	local items = {
		crate3_n = 4,
		crate3 = 3,
		crate1 = 10,
	}

	local max = 0

	for _, amt in pairs(items) do
		max = max + amt
	end

	local item

	local num = max * seed
	for cur, amt in pairs(items) do
		num = num - amt
		if (num <= 0) then
			item = cur
			break
		end
	end

	local amount = ({
		crate3_n = 20,
		crate3 = 3,
		crate1 = 5
	})[item]

	return amount, item
end

function QUEST:GetRewardText(seed)
	local amount, cur = self:GetReward(seed)
	return "set of " .. amount .. " " .. pluto.currency.byname[cur].Name .. "s"
end

function QUEST:Init(data)
	data:Hook("DoPlayerDeath", function(data, vic, atk, dmg)
		if (atk == data.Player and atk:GetRoleTeam() ~= vic:GetRoleTeam() and atk:Health() == atk:GetMaxHealth() and dmg:IsDamageType(DMG_FALL)) then
			data:UpdateProgress(1)
		end
	end)
end

function QUEST:Reward(data)
	local amount, item = self:GetReward(data.Seed)

	pluto.inv.addcurrency(data.Player, item, amount)

	data.Player:ChatPrint(white_text, "You have received ", amount, " ", pluto.currency.byname[item], "s", white_text, "!")
end

function QUEST:IsType(type)
	return type == 2
end

function QUEST:GetProgressNeeded(type)
	return math.random(10, 15)
end