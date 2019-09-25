local MOD = {}
MOD.Type = "suffix"
MOD.Name = "Shocking"
MOD.Tags = {
	"shock"
}
MOD.ModType = "special"

function MOD:IsNegative(roll)
	return roll < 0
end

function MOD:GetDescription(rolls)
	local roll = rolls[1]
	return string.format("Hits have a %.01f%% to shock", roll)
end

MOD.Tiers = {
	{ 5,   10  },
	{ 2.5, 5   },
	{ 1,   2.5 },
}

MOD.Hooks = {}

function MOD.Hooks:Ass(wep, mod1, ...)
end

return MOD