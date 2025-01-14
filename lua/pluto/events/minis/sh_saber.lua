--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
-- Author: add___123

local name = "saber"

if (SERVER) then
    local sabers = {}

    hook.Add("TTTBeginRound", "pluto_mini_" .. name, function()
        if (not pluto.rounds.minis[name]) then
            return
        end

		pluto.rounds.minis[name] = nil

        pluto.rounds.Notify("Lightsabers have spawned around the map!", pluto.currency.byname._lightsaber.Color)

        for k, ply in ipairs(player.GetAll()) do
            if (not ply:Alive()) then
                continue
            end
            table.insert(sabers, pluto.currency.spawnfor(ply, "_lightsaber", nil, true))
        end

        hook.Add("TTTEndRound", "pluto_mini_" .. name, function()
            hook.Remove("TTTEndRound", "pluto_mini_" .. name)
            for k, cur in ipairs(sabers) do
                cur:Remove()
            end

            sabers = {}
        end)
    end)
else

end