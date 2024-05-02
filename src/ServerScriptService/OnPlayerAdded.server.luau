local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

Players.PlayerAdded:Connect(function(player)
	
	local gold = Instance.new("IntValue")
	gold.Name = "Gold"
	gold.Value = 1500
	gold.Parent = player
	
	local placedTowers = Instance.new("IntValue")
	placedTowers.Name = "PlacedTowers"
	placedTowers.Value = 0
	placedTowers.Parent = player
	
	player.CharacterAdded:Connect(function(character)
		for i, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(object, "Player")
			end
		end
	end)
end)