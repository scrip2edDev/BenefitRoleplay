-- Services
local inputService = game:GetService("UserInputService")
local playerService = game:GetService("Players")

-- Objects
local plr = playerService.LocalPlayer
local char = plr.Character or plr.CharacterAdded:wait()

local normalSpeed = 18 -- The player's walking speed (Roblox default is 16)
local sprintSpeed = 26 -- The player's speed while running
local running = false

inputService.InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.LeftShift or key.KeyCode == Enum.KeyCode.RightShift then
		running = true
		if char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = sprintSpeed
		end
	end
end)

inputService.InputEnded:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.LeftShift or key.KeyCode == Enum.KeyCode.RightShift then
		running = false
		if char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = normalSpeed
		end
	end
end)
