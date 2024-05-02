local admins = {"unclelemon01"}
local Players = game:GetService('Players')

Players.PlayerAdded:Connect(function(player)
	if not table.find(admins, player.Name) then
		return
	end

	player.Chatted:Connect(function(message)
		local split = string.split(message, ' ')

		if split[1] == '!cash' then
			player.Gold.Value += tonumber(split[2])
		elseif split[1] == '!unit' then
			local unitModule = require(script.Parent.Main.Unit)
			unitModule.Spawn(tostring(split[2]), 1, workspace.GrassLands)
		elseif split[1] == '!enemy' then
			local mobModule = require(script.Parent.Main.Mob)
			mobModule.Spawn(tostring(split[2]), 1, workspace.GrassLands)
		end
	end)
end)