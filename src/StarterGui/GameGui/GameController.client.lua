local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local modules = ReplicatedStorage:WaitForChild("Modules")
local health = require(modules:WaitForChild("Health"))

local gold = Players.LocalPlayer:WaitForChild("Gold")
local towers = game.ReplicatedStorage:WaitForChild("Towers")

local functions = ReplicatedStorage:WaitForChild("Functions")
local requestTowerFunction = functions:WaitForChild("RequestTower")
local spawnTowerFunction = functions:WaitForChild("SpawnTower")
local sellTowerFunction = functions:WaitForChild("SellTower")

local camera = workspace.CurrentCamera
local gui = script.Parent
local map = workspace:WaitForChild("GrassLands")
local base = map:WaitForChild("Base")
local info = workspace:WaitForChild("Info")

local hoveredInstance = nil
local selectedTower = nil
local towerToSpawn = nil
local canPlace = false
local rotation = 0
local placedTowers = 0
local maxTowers = 25

health.Setup(base)

local function SetupGui()
	health.Setup(base, gui.Info.Health)

	workspace.Mobs.ChildAdded:Connect(function(mob)
		health.Setup(mob)
	end)

	info.Message.Changed:Connect(function(change)
		gui.Info.Message.Text = change
		if change == "" then
			gui.Info.Message.Visible = false
		else
			gui.Info.Message.Visible = true
		end
	end)

	info.Wave.Changed:Connect(function(change)
		gui.Info.Stats.Wave.Text = "Wave: " .. change
	end)

	gold.Changed:Connect(function(change)
		gui.Info.Stats.Gold.Text = "$" .. change
	end)
	gui.Info.Stats.Gold.Text = "$" .. gold.Value
end

SetupGui()


local function MouseRaycast(blacklist)
	local mousePosition = UserInputService:GetMouseLocation()
	local mouseRay = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local raycastParams = RaycastParams.new()

	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = blacklist

	local raycastResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)

	return raycastResult
end

local function CreateRangeCirlce(tower, placeholder)
	
	local range = tower.Config.Range.Value
	local height = (tower.PrimaryPart.Size.Y / 2)
	local offset = CFrame.new(0, -height, 0)
	
	local p = Instance.new("Part")
	p.Name = "Range"
	p.Shape = Enum.PartType.Cylinder
	p.Material = Enum.Material.Neon
	p.Transparency = 0.9
	p.Size = Vector3.new(1, range * 2, range * 2)
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CFrame = tower.PrimaryPart.CFrame * offset * CFrame.Angles(0, 0, math.rad(90))
	p.CanCollide = false
	p.Anchored = true
	p.Parent = workspace.Camera
	
	if placeholder then
		p.Anchored = false
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = p
		weld.Part1 = tower.PrimaryPart
		weld.Parent = p
		p.Parent = tower
		p.Transparency = 0.1
		p.Material = Enum.Material.ForceField
	else
		p.Transparency = 0.9
		p.Material = Enum.Material.Neon
		p.Anchored = true
		p.Parent = workspace.Camera
	end
	
end

local function RemovePlaceholderTower()
	if towerToSpawn then
		towerToSpawn:Destroy()
		towerToSpawn = nil
		rotation = 0
	end
end

local function AddPlaceholderTower(name)

	local towerExist = towers:FindFirstChild(name)
	if towerExist then
		RemovePlaceholderTower()
		towerToSpawn = towerExist:Clone()
		towerToSpawn.Parent = workspace
		
		CreateRangeCirlce(towerToSpawn, true)

		for i, object in ipairs(towerToSpawn:GetDescendants()) do
			if object:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(object, "Tower")
				if object.Name ~= "Range" then
					object.Material = Enum.Material.ForceField
					object.Transparency = 0.3
				end
			end
		end
	end
end

local function ColorPlaceholderTower(color)
	for i, object in ipairs(towerToSpawn:GetDescendants()) do
		if object:IsA("BasePart") then
			object.Color = color
		end
	end
end

gui.Towers.Title.Text = "Towers: ".. placedTowers .. "/" .. maxTowers
for i, tower in pairs(towers:GetChildren()) do
	if tower:IsA("Model") then
		local button = gui.Towers.Template:Clone()
		local config = tower:WaitForChild("Config")
		button.Name = tower.Name
		button.Image = config.Image.Texture
		button.Visible = true
		button.LayoutOrder = config.Price.Value
		button.Price.Text = config.Price.Value

		local ClonedTower = tower:Clone()
		local camera = Instance.new("Camera")
		camera.CameraType = Enum.CameraType.Scriptable
		local WorldModel = button.ViewportFrame:WaitForChild("WorldModel")
		local Animations = button.ViewportFrame.WorldModel.Animations
		local mainPart = ClonedTower

		local ViewPortPoint = Vector3.new(0,0,0)

		local Viewportframe = button:WaitForChild("ViewportFrame")
		button.ViewportFrame.CurrentCamera = camera

		mainPart:SetPrimaryPartCFrame(CFrame.new(ViewPortPoint))
		mainPart.Parent = Viewportframe

		local cframe, size = tower:GetBoundingBox()

		local MaxSize = math.max(size.X,size.Y,size.Z)

		local Distance = (MaxSize/math.tan(math.rad(camera.FieldOfView))) * 1.5

		local CurrentDistance = (MaxSize/2) * Distance

		camera.CFrame = CFrame.new(0, -0.3, -40) * CFrame.Angles(0, math.rad(180), 0)

		Animations.Parent = ClonedTower
		camera.Parent = button.ViewportFrame
		camera.CameraSubject = ClonedTower
		ClonedTower.Parent = button.ViewportFrame.WorldModel
		Animations.Disabled = false
		camera.FieldOfView = 7
		button.Parent = gui.Towers

		button.Activated:Connect(function()
			local allowedToSpawn = requestTowerFunction:InvokeServer(tower.Name)
			if allowedToSpawn then
				AddPlaceholderTower(tower.Name)
			end
		end)
	end
end

local function toggleTowerInfo()
	workspace.Camera:ClearAllChildren()
	gui.Towers.Title.Text = "Towers: ".. placedTowers .. "/" .. maxTowers
	
	if selectedTower then
		CreateRangeCirlce(selectedTower)
		gui.Selection.Visible = true
		local config = selectedTower.Config
		gui.Selection.Stats.Damage.Value.Text = config.Damage.Value
		gui.Selection.Stats.Range.Value.Text = config.Range.Value
		gui.Selection.Stats.Cooldown.Value.Text = config.Cooldown.Value
		gui.Selection.Title.TowerName.Text = selectedTower.Name
		gui.Selection.Title.TowerImage.Image = config.Image.Texture
		gui.Selection.Title.OwnerName.Text = config.Owner.Value .. "'s"
		
		if config.Owner.Value == Players.LocalPlayer.Name then
			gui.Selection.Action.Visible = true
			
			local upgradeTower = config:FindFirstChild("Upgrade")
			if upgradeTower then
				gui.Selection.Action.Upgrade.Visible = true
				gui.Selection.Action.Upgrade.Title.Text = "Upgrade (" .. upgradeTower.Value.Config.Price.Value .. ")"
			else
				gui.Selection.Action.Upgrade.Visible = false
			end
		else
			gui.Selection.Action.Visible = false
		end
	else
		gui.Selection.Visible = false
	end
end

gui.Selection.Action.Upgrade.Activated:Connect(function()
	if selectedTower then
		local upgradeTower = selectedTower.Config.Upgrade.Value
		local allowedToUpgrade = requestTowerFunction:InvokeServer(upgradeTower.Name)
		
		if allowedToUpgrade then
			selectedTower = spawnTowerFunction:InvokeServer(upgradeTower.Name, selectedTower.PrimaryPart.CFrame, selectedTower)
			toggleTowerInfo()
		end
	end
end)

gui.Selection.Action.Sell.Activated:Connect(function()
	if selectedTower then
		local soldTower = sellTowerFunction:InvokeServer(selectedTower)
		
		if soldTower then
			selectedTower = nil
			placedTowers -= 1
			toggleTowerInfo()
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if towerToSpawn then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if canPlace then
				local placedTower = spawnTowerFunction:InvokeServer(towerToSpawn.Name, towerToSpawn.PrimaryPart.CFrame)
				if placedTower then
					placedTowers += 1
					RemovePlaceholderTower()
					toggleTowerInfo()
				end
			end
		elseif input.KeyCode == Enum.KeyCode.R then
			rotation += 90
		end
	elseif hoveredInstance and input.UserInputType == Enum.UserInputType.MouseButton1 then
		local model = hoveredInstance:FindFirstAncestorOfClass("Model")
		
		if model and model.Parent == workspace.Towers then
			selectedTower = model
		else
			selectedTower = nil
		end
		
		toggleTowerInfo()
	end
end)

RunService.RenderStepped:Connect(function()
	local result = MouseRaycast({towerToSpawn})
	if result and result.Instance then
		if towerToSpawn then
			hoveredInstance = nil
			
			if result.Instance.Parent.Name == "TowerArea" then
				canPlace = true
				ColorPlaceholderTower(Color3.new(0.384314, 0.8, 0.411765))
			else
				canPlace = false
				ColorPlaceholderTower(Color3.new(1, 0.341176, 0.407843))
			end
			local x = result.Position.X
			local y = result.Position.Y + towerToSpawn.Humanoid.HipHeight + (towerToSpawn.PrimaryPart.Size.Y * 1.5)
			local z = result.Position.Z

			local cframe = CFrame.new(x,y,z) * CFrame.Angles(0, math.rad(rotation), 0)
			towerToSpawn:SetPrimaryPartCFrame(cframe)
		else
			hoveredInstance = result.Instance
		end
	else
		hoveredInstance = nil
	end
end)