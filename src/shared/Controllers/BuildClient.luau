-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")

local ClientPlacer = require(Modules:WaitForChild("ClientPlacer"))
local BuildClient = Knit.CreateController({ Name = "BuildClient" })

local placer = nil

-- // Functions \\ --

local function setPlacementActive(_, state, _)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	if not placer then
		local plot = Knit.GetService("PlotService"):GetPlot()
		placer = ClientPlacer.new(plot)
	else
		placer:Destroy()
		placer = nil
	end
end

-- // Main \\ --

function BuildClient:KnitStart()
	ContextActionService:BindAction("ActivatePlacement", setPlacementActive, true, Enum.KeyCode.B)
end

-- // Return \\ --

return BuildClient
