QUEST.Name = "Perfect Crime"
QUEST.Description = "Prevent the bodies of your victims from being discovered"
QUEST.Credits = "Froggy & add__123"
QUEST.Color = Color(204, 43, 75)

function QUEST:GetRewardText(seed)
	return pluto.quests.poolrewardtext("daily", seed)
end

function QUEST:Init(data)
	local ragdolls = {}
	data:Hook("PlayerRagdollCreated", function(data, ply, rag, atk)
		print(ply, rag, atk)
		if (atk == data.Player and atk:GetRoleTeam() ~= ply:GetRoleTeam()) then
			ragdolls[rag] = true
		end
	end)

	data:Hook("TTTEndRound", function(data)
		data:UpdateProgress(table.Count(ragdolls))
		ragdolls = {}
	end)

	data:Hook("TTTRWPlayerInspectBody", function(data, ply, ent, pos, is_silent)
		if (not is_silent) then
			ragdolls[ent] = nil
		end
	end)
end

function QUEST:Reward(data)
	data.Name = self.Name
	data.Color = self.Color
	pluto.quests.poolreward("daily", data)
end

function QUEST:IsType(type)
	return type == 2
end

function QUEST:GetProgressNeeded(type)
	return math.random(50, 70)
end