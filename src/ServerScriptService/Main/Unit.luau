local PhysicsService = game:GetService("PhysicsService")
local ServerStorage = game:GetService("ServerStorage")

local unit = {}

function unit.Move(unit, map)
	local humanoid = unit:WaitForChild("Humanoid")
	local waypoints = workspace.GrassLands.UnitWaypoints

	for waypoint=1, #waypoints:GetChildren() do
		humanoid:MoveTo(waypoints[waypoint].Position)
		humanoid.MoveToFinished:Wait()
	end
	unit:Destroy()
end

function unit.Spawn(name, quantity , map)
	local unitExists = ServerStorage.Units:FindFirstChild(name)

	if unitExists then
		for i=1, quantity do
			task.wait(1.2)
			local newUnit = unitExists:Clone()
			newUnit.HumanoidRootPart.CFrame = workspace.GrassLands.End.CFrame
			newUnit.Parent = workspace.Units
			newUnit.HumanoidRootPart:SetNetworkOwner(nil)

			for i, object in ipairs(newUnit:GetDescendants()) do
				if object:IsA("BasePart") then
					object.CollisionGroup = "Unit"
				end
			end

			newUnit.PrimaryPart.Touched:Connect(function(hit)
				if hit.Parent.Parent.Name == "Mobs" then
					if hit.Name == "HumanoidRootPart" then
						local targetHealth = Instance.new("NumberValue")
						targetHealth.Value = hit.Parent.Humanoid.Health
						hit.Parent.Humanoid:TakeDamage(newUnit.Humanoid.Health)
						newUnit.Humanoid:TakeDamage(targetHealth.Value)
					end
				end
			end)

			newUnit.Humanoid.Died:Connect(function()
				wait(0.1)
				newUnit:Destroy()
			end)

			coroutine.wrap(unit.Move)(newUnit, map)
		end

	else
		warn("Requested unit does not exist: ", name)
	end
end

return unit