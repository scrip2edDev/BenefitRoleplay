return {
	["Door_Run"] = function(Door)
		local LeftDoor = Door:FindFirstChild("LeftDoor")
		local RightDoor = Door:FindFirstChild("RightDoor")

		local LeftDoorHinge = Door.Frame.LeftHinge.HingeConstraint
		local RightDoorHinge = Door.Frame.RightHinge.HingeConstraint

		local LeftDoorHandle = LeftDoor.Handle
		local RightDoorHandle = RightDoor.Handle

		if LeftDoor and LeftDoorHinge then
			local LeftOpened = false
			local LeftCooldown = false
			local LeftClickDetector = Instance.new("ClickDetector")
			LeftClickDetector.Parent = LeftDoorHandle
			LeftClickDetector.MouseClick:Connect(function(Player)
				if LeftCooldown then
					return
				end
				LeftCooldown = true
				LeftClickDetector.MaxActivationDistance = 0
				if LeftOpened == false then
					LeftOpened = true
					LeftDoorHinge.TargetAngle = 95
				else
					LeftOpened = false
					LeftDoorHinge.TargetAngle = 0
				end
				task.delay(1, function()
					LeftCooldown = false
					LeftClickDetector.MaxActivationDistance = 32
				end)
			end)
		end

		if RightDoor and RightDoorHinge then
			local RightOpened = false
			local RightCooldown = false
			local RightClickDetector = Instance.new("ClickDetector")
			RightClickDetector.Parent = RightDoorHandle
			RightClickDetector.MouseClick:Connect(function(Player)
				if RightCooldown then
					return
				end
				RightCooldown = true
				RightClickDetector.MaxActivationDistance = 0
				if RightOpened == false then
					RightOpened = true
					RightDoorHinge.TargetAngle = -95
				else
					RightOpened = false
					RightDoorHinge.TargetAngle = 0
				end
				task.delay(1, function()
					RightCooldown = false
					RightClickDetector.MaxActivationDistance = 32
				end)
			end)
		end
	end,
}
