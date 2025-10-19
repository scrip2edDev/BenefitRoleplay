-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = Shared:WaitForChild("Assets")

local Plots = workspace:WaitForChild("Plots")
local PlotSpawns = Plots:WaitForChild("PlotSpawns")

local Knit = require(ReplicatedStorage.Packages.Knit)
local PlotClaimController = Knit.CreateController({ Name = "PlotClaimController" })
local PlotClaimGui = nil

local Player = game:GetService("Players").LocalPlayer

-- // Main \\ --

function PlotClaimController:UpdateClaimButtons()
	for _, Button: TextButton in pairs(PlotClaimGui:GetChildren()) do
		local ButtonPlotSpawn = PlotSpawns:FindFirstChild(Button.Name)
		if Button:IsA("TextButton") and ButtonPlotSpawn then
			local plotClaimed = Knit.GetService("PlotService"):IsPlotClaimed(ButtonPlotSpawn)
			if plotClaimed then
				Button.BackgroundColor3 = Color3.new(0.886275, 0.231373, 0.231373)
			else
				Button.BackgroundColor3 = Color3.new(0.231373, 0.886275, 0.262745)
			end
		end
	end
end

function PlotClaimController:KnitStart()
	repeat
		task.wait()
	until workspace:WaitForChild("Plots"):WaitForChild("PlotSpawns") ~= nil
	local HouseClaiming = Assets:WaitForChild("HouseClaiming")
	if HouseClaiming then
		PlotClaimGui = HouseClaiming:Clone()
		PlotClaimGui.Parent = Player.PlayerGui

		for _, Button: TextButton in pairs(PlotClaimGui:GetChildren()) do
			if Button:IsA("TextButton") then
				Button.MouseButton1Click:Connect(function()
					local response = Knit.GetService("PlotService"):ClaimPlot(PlotSpawns:FindFirstChild(Button.Name))
					if response then
						PlotClaimGui.Enabled = false
						PlotClaimController:UpdateClaimButtons()
					end
				end)
			end
		end

		task.spawn(function()
			while task.wait(5) do
				PlotClaimController:UpdateClaimButtons()
			end
		end)
	else
		warn(`{script.Name} Error :: HouseClaiming Gui not found`)
	end
end

-- // Return \\ --

return PlotClaimController
