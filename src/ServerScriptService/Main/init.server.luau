local ServerStorage = game:GetService("ServerStorage")

local bindables = ServerStorage:WaitForChild("Bindables")
local gameOverEvent = bindables:WaitForChild("GameOver")

local mob = require(script.Mob)
local tower = require(script.Tower)
local unit = require(script.Unit)
local map = workspace.GrassLands
local waves = 10
local gameCountdown = 10
local waveCountdown = 5

local info = workspace.Info
local gameOver = false


map.Base.Humanoid.HealthChanged:Connect(function(health)
	if health <= 0 then
		gameOver = true
	end
end)


for i=gameCountdown, 0, -1 do
	info.Message.Value = "Game starting in..." .. i
	task.wait(1)
end

for wave=1, waves do
	info.Wave.Value = wave
	info.Message.Value = ""

	print("Wave Starting!:", wave)
	if wave <= waves*0.1 then
		mob.Spawn("Zombie", 4 * wave, map)
		mob.Spawn("LostSoul", 4 * wave, map)
		mob.Spawn("Skeleton", 4 * wave, map)
		mob.Spawn("Abnormal", 6 * wave, map)
	elseif wave <= waves*0.2 then
		mob.Spawn("LostSoul", 5 * wave, map)
		mob.Spawn("Speeds", 5 * wave, map)
		mob.Spawn("Skeleton", 6 * wave, map)
		mob.Spawn("Abnormal", 6 * wave, map)
		mob.Spawn("Reviver", 1, map)
	elseif wave <= waves*0.4 then
		mob.Spawn("LostSoul", 5 * wave, map)
		mob.Spawn("Abnormal", 6 * wave, map)
		mob.Spawn("Skeleton", 6 * wave, map)
		mob.Spawn("Reviver", 3 * wave, map)
	elseif wave <= waves*0.6 then
		mob.Spawn("Abnormal", 6 * wave, map)
		mob.Spawn("LostSoul", 5 * wave, map)
		mob.Spawn("Skeleton", 6 * wave, map)
		mob.Spawn("Reviver", 3 * wave, map)
		mob.Spawn("Boss1", 1, map)
	elseif wave <= waves*0.7 then
		mob.Spawn("Abnormal", 6 * wave, map)
		mob.Spawn("LostSoul", 5 * wave, map)
		mob.Spawn("Skeleton", 6 * wave, map)
		mob.Spawn("Reviver", 3 * wave, map)
		mob.Spawn("Boss1", 2 * wave, map)
		mob.Spawn("Swordmaster", 1, map)
	elseif wave <= waves*0.8 then
		mob.Spawn("Abnormal", 6 * wave, map)
		mob.Spawn("LostSoul", 5 * wave, map)
		mob.Spawn("Skeleton", 6 * wave, map)
		mob.Spawn("Reviver", 3 * wave, map)
		mob.Spawn("Boss1", 2 * wave, map)
		mob.Spawn("Swordmaster", 1, map)
		mob.Spawn("Prince", 1, map)
	elseif wave <= waves*0.9 then
		mob.Spawn("Abnormal", 6 * wave, map)
		mob.Spawn("LostSoul", 5 * wave, map)
		mob.Spawn("Skeleton", 6 * wave, map)
		mob.Spawn("Reviver", 3 * wave, map)
		mob.Spawn("Boss1", 4 * wave, map)
		mob.Spawn("Swordmaster", 4 * wave, map)
		mob.Spawn("Prince", 2 * wave, map)
		mob.Spawn("Umbra", 1, map)
	else
		mob.Spawn("Abnormal", 6 * wave, map)
		mob.Spawn("LostSoul", 5 * wave, map)
		mob.Spawn("Skeleton", 6 * wave, map)
		mob.Spawn("Reviver", 3 * wave, map)
		mob.Spawn("Boss1", 4 * wave, map)
		mob.Spawn("Swordmaster", 4 * wave, map)
		mob.Spawn("Prince", 2 * wave, map)
		mob.Spawn("Umbra", 1 * wave, map)
		mob.Spawn("DarkLord", 1, map)
	end

	repeat
		task.wait(1)
	until #workspace.Mobs:GetChildren() == 0 or gameOver

	if gameOver then
		info.Message.Value = "Game Over"
		break
	end

	for i=waveCountdown, 0, -1 do
		info.Message.Value = "Next wave starting in..." .. i
		task.wait(1)
	end
end
