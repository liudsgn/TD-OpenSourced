local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage:WaitForChild("Events")

local animateTowerEvent = events:WaitForChild("AnimateTower")

local function setAnimation(object, animName)
	local humanoid = object:WaitForChild("Humanoid")
	local animationsFolder = object:WaitForChild("Animations")

	if humanoid and animationsFolder then
		local animationObject = animationsFolder:WaitForChild(animName)
		
		if animationObject then
			local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
			
			local playingTracks = animator:GetPlayingAnimationTracks()
			for i, track in pairs(playingTracks) do
				if track.Name == animName then
					return track
				end
			end
			
			local animationTrack = animator:LoadAnimation(animationObject)
			return animationTrack
		end
	end
end

local function playAnimation(object, animName)
	local animationTrack = setAnimation(object, animName)
	
	if animationTrack then
		animationTrack:Play()
	else
		warn("Lol animation doesn't exist")
		return
	end
	print(animationTrack.IsPlaying, animName)
end

workspace.Mobs.ChildAdded:Connect(function(object)
	playAnimation(object, "Walk")
end)

workspace.Units.ChildAdded:Connect(function(object)
	playAnimation(object, "Walk")
end)

workspace.Towers.ChildAdded:Connect(function(object)
	playAnimation(object, "Idle")
end)

animateTowerEvent.OnClientEvent:Connect(function(tower, animName)
	playAnimation(tower, animName)
end)