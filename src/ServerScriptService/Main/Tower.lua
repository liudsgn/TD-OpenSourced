local PhysicsService = game:GetService("PhysicsService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage:WaitForChild("Events")
local animateTowerEvent = events:WaitForChild("AnimateTower")
local functions = ReplicatedStorage:WaitForChild("Functions")
local spawnTowerFunction = functions:WaitForChild("SpawnTower")
local requestTowerFunction = functions:WaitForChild("RequestTower")
local sellTowerFunction = functions:WaitForChild("SellTower")

local maxTowers = 25
local tower = {}

function FindNearestTarget(newTower, range)
	local nearestTarget = nil

	for i, target in ipairs(workspace.Mobs:GetChildren()) do
		local distance = (target.HumanoidRootPart.Position - newTower.HumanoidRootPart.Position).Magnitude
		print(target.Name, distance)
		if distance < range then
			print(target.Name, "Is the nearest target found so far")
			nearestTarget = target
			range = distance
		end
	end

	return nearestTarget
end

function tower.Attack(newTower, player)
	local config = newTower.Config
	local target = FindNearestTarget(newTower, config.Range.Value)
	if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
		
		local targetCFrame = CFrame.lookAt(newTower.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
		newTower.HumanoidRootPart.BodyGyro.CFrame = targetCFrame
		
		animateTowerEvent:FireAllClients(newTower, "Attack")
		
		target.Humanoid:TakeDamage(config.Damage.Value)
		
		if target.Humanoid.Health <= 0 then
			player.Gold.Value += target.Humanoid.MaxHealth
		end
		
		task.wait(config.Cooldown.Value)
	end

	task.wait(0.1)
	
	if newTower and newTower.Parent then
		tower.Attack(newTower, player)	
	end
end

function tower.Sell(player, model)
	if model and model:FindFirstChild("Config") then
		if model.Config.Owner.Value == player.Name then
			player.PlacedTowers.Value -= 1
			player.Gold.Value += model.Config.Price.Value
			model:Destroy()
			return true
		end
	end
	
	warn("Unable to sell this Tower")
	return false
end
sellTowerFunction.OnServerInvoke = tower.Sell

function tower.Spawn(player, name, cframe, previous)
	local allowedToSpawn = tower.CheckSpawn(player, name)
	
	if allowedToSpawn then
		
		local newTower
		if previous then
			previous:Destroy()
			newTower = ReplicatedStorage.Towers.Upgrades[name]:Clone()
		else
			newTower = ReplicatedStorage.Towers[name]:Clone()
			player.PlacedTowers.Value += 1
		end
		
		local ownerValue = Instance.new("StringValue")
		ownerValue.Name = "Owner"
		ownerValue.Value = player.Name
		ownerValue.Parent = newTower.Config
		
		newTower.HumanoidRootPart.CFrame = cframe
		newTower.Parent = workspace.Towers
		newTower.HumanoidRootPart:SetNetworkOwner(nil)
		
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.D = 0
		bodyGyro.CFrame = newTower.HumanoidRootPart.CFrame
		bodyGyro.Parent = newTower.HumanoidRootPart

		for i, object in ipairs(newTower:GetDescendants()) do
			if object:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(object, "Tower")
			end
			
		end
		
		player.Gold.Value -= newTower.Config.Price.Value
		
		coroutine.wrap(tower.Attack)(newTower, player)
		
		return newTower
	else
		warn("Requested tower Does not exit", name)
		return false
	end
end
spawnTowerFunction.OnServerInvoke = tower.Spawn

function tower.CheckSpawn(player, name)
	local towerExist = ReplicatedStorage.Towers:FindFirstChild(name, true)

	if towerExist then
		if towerExist.Config.Price.Value <= player.Gold.Value then
			if player.PlacedTowers.Value < maxTowers then
				return true
			else
				warn("Player has reached max Limit")
			end
		else
			warn("Player is too poor, lol")
		end
	else
		warn("That tower never existed")
	end
	
	return false
end
requestTowerFunction.OnServerInvoke = tower.CheckSpawn

return tower
