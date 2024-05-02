local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players")

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

			for i, track in pairs (playingTracks) do
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
		warn("Animation track does not exist")
		return
	end
end

script.Parent.Humanoid:LoadAnimation(script.Parent.Animations.Idle):Play()