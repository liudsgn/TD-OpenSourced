local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")


local mob = {}

function mob.Move(mob, map)
	local humanoid = mob:WaitForChild("Humanoid")
	local waypoints =  map.Waypoints

	for waypoint=1, #waypoints:GetChildren() do
		humanoid:MoveTo(waypoints[waypoint].Position)
		humanoid.MoveToFinished:Wait()
	end
	
	mob:Destroy()
	
	map.Base.Humanoid:TakeDamage(humanoid.Health)
	
end

function mob.Spawn(name, quantity, map)
	local mobExist = ServerStorage.Mobs:FindFirstChild(name)
	
	if mobExist then
		for i=1, quantity do
			task.wait(0.5)
			local newMob = mobExist:Clone()
			newMob.HumanoidRootPart.CFrame = map.Spawn.CFrame
			newMob.Parent = workspace.Mobs
			newMob.HumanoidRootPart:SetNetworkOwner(nil)
			
			for i, object in ipairs(newMob:GetDescendants()) do
				if object:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(object, "Mob")
				end
			end
			
			newMob.Humanoid.Died:Connect(function()
				task.wait(0.5)
				newMob:Destroy()
			end)

			coroutine.wrap(mob.Move)(newMob, map)
		end
		
	else
		warn("Requested mob Does not exit")
	end
end

return mob
