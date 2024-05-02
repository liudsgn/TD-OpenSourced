local Players = game:GetService("Players")

local health = {}

function health.Setup(model, screenGui)
	local newHealthBar = script.HealthGui:Clone()
	newHealthBar.Adornee =  model:WaitForChild("Head")
	newHealthBar.Parent = Players.LocalPlayer.PlayerGui:WaitForChild("Billboards")

	if model.Name == "Base" then
		newHealthBar.MaxDistance = 100
		newHealthBar.Size = UDim2.new(0, 0, 0, 0)
	else
		newHealthBar.MaxDistance = 20
		newHealthBar.Size = UDim2.new(0, 100, 0, 20)
	end

	health.UpdateHealth(newHealthBar, model)

	if screenGui then
		health.UpdateHealth(screenGui, model)
	end

	model.Humanoid.HealthChanged:Connect(function()
		health.UpdateHealth(newHealthBar, model)
		if screenGui then
			health.UpdateHealth(screenGui, model)
		end
	end)
end

function health.UpdateHealth(gui, model)
	local humanoid = model:WaitForChild("Humanoid")

	if humanoid and gui then
		local percent = humanoid.Health / humanoid.MaxHealth

		gui.CurrentHealth.Size = UDim2.new(math.max(percent, 0), 0, 1, 0)

		if humanoid.Health <= 0 then
			if model.Name == "Base" then
				gui.Title.Text = model.Name .. " Gone"
			else
				gui.Title.Text = model.Name .. " Dead"
				task.wait(0.5)
				gui:Destroy()
			end

		else
			gui.Title.Text = model.Name .. " : " .. humanoid.Health .. "/" .. humanoid.MaxHealth
		end
	end
end

return health