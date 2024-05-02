local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local MainFrame = script.Parent.MainFrame
local HPText = MainFrame.HPLeft

local function findNearestBoss(fromPos)
	local target
	local distance = 100
	for _,v in pairs(workspace.Mobs:GetChildren()) do -- We get all the childrens inside of Workspace.Mobs folder
		local humanoid = v:FindFirstChild("Humanoid") -- We get their humanoid
		local IsABoss = v:FindFirstChild("IsABoss")   -- We also check if they have a BooleanValue named IsABoss
		if humanoid and IsABoss then -- If a Humanoid and IsABoss(boolvalue) exists, then we execute the following things from line 17 - 20 
			if (fromPos - v.PrimaryPart.Position).magnitude < distance then
				distance = (fromPos-v.PrimaryPart.Position).magnitude
				target = v
			end
		end
	end
	return target -- We return it
end

local function renderStepped()
	Character = player.Character or player.CharacterAdded:Wait() -- Waiting for the player and character to be loaded..
	local Boss = findNearestBoss(Character.HumanoidRootPart.Position) -- Looking for the boss!
	
	if Boss then -- If a boss is inside of our requested renderDistance, we execute the following code from line 30 - 44
		local Boss_HUMANOID = Boss.Humanoid -- Setting up a ariable for the Boss'es Humanoid
		MainFrame.Visible = true -- Mkaing the GUI visible
		MainFrame.BossName.Text = Boss.Name -- Setting up the GUI elemnts
		HPText.Text = Boss_HUMANOID.Health .."/".. Boss_HUMANOID.MaxHealth
		MainFrame.Bar.Size = UDim2.new( -- We update the HP Bar's size with UDim2
			Boss_HUMANOID.Health/Boss_HUMANOID.MaxHealth,
			0,
			1,		
			0
		)
		Boss_HUMANOID.Died:Connect(function() -- If the boss dies, we make the frame invisible
			MainFrame.Visible = false
		end)	
	else
		MainFrame.Visible = false -- If a boss doesn't exist in our renderDistance, we make the GUI invisible.
	end
end

RunService.RenderStepped:Connect(renderStepped)