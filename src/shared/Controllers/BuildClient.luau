-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")

local ClientPlacer = require(Modules:WaitForChild("ClientPlacer"))
local BuildClient = Knit.CreateController({ Name = "BuildClient" })
local BuildMode_Template = Assets:WaitForChild("BuildMode")

local placer = nil
local BuildModeUi = nil

-- // Functions \\ --

local function setPlacementActive(_, state, _)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	if not placer then
		local plot = Knit.GetService("PlotService").GetPlot()
		placer = ClientPlacer.new(plot)
		BuildModeUi.Decorating.Visible = true
	else
		placer:Destroy()
		placer = nil
		BuildModeUi.Decorating.Visible = false
	end
end

-- // Main \\ --

function BuildClient:KnitStart()
	BuildModeUi = BuildMode_Template:Clone()
	BuildModeUi.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	ContextActionService:BindAction("ActivatePlacement", setPlacementActive, true, Enum.KeyCode.B)
end

-- // Return \\ --

return BuildClient
