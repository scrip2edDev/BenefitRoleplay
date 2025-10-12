return {
	["Door_Run"] = function(Door)
		local DoorModel = Door:FindFirstChild("DoorModel")
		local Frame = Door:FindFirstChild("Frame")

		local Hinge = Frame and Frame:FindFirstChild("Hinge")
		local Handle = DoorModel:FindFirstChild("Handle")

		if Handle and Hinge then
			local Opened = false
			local Cooldown = false
			local ClickDetector = Instance.new("ClickDetector")
			ClickDetector.Parent = Handle

			ClickDetector.MouseClick:Connect(function(Player)
				if Cooldown then
					return
				end
				Cooldown = true
				ClickDetector.MaxActivationDistance = 0
				if Opened == false then
					Opened = true
					Hinge.HingeConstraint.TargetAngle = 95
				else
					Opened = false
					Hinge.HingeConstraint.TargetAngle = 0
				end
				task.delay(1, function()
					Cooldown = false
					ClickDetector.MaxActivationDistance = 32
				end)
			end)
		end
	end,
}
