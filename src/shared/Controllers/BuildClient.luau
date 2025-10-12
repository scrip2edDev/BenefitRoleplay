-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")

local ClientPlacer = require(Modules:WaitForChild("ClientPlacer"))
local BuildClient = Knit.CreateController({ Name = "BuildClient" })
local BuildMode_Template = Assets:WaitForChild("BuildMode")

local BuildMode_Config = require(Modules:WaitForChild("Build_Mode_Config"))

local placer = nil
local BuildModeUi = nil

-- // Functions \\ --

local function loadGuiItems()
	local Decorating = BuildModeUi:WaitForChild("Decorating")
	for CategoryName, CategoryData in pairs(BuildMode_Config.Categories) do
		local Category: TextButton = Decorating.Categories.Template:Clone()
		Category.Parent = Decorating.Categories.ScrollingFrame
		Category.Visible = true
		Category.Name = CategoryName
		Category.Text = CategoryName
	end
end

local function setPlacementActive(_, state, _)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	if not placer then
		--[[local plot = Knit.GetService("PlotService").GetPlot()
		--placer = ClientPlacer.new(plot)]]
		loadGuiItems()
		BuildModeUi.Decorating.Visible = true
	else
		--[[placer:Destroy()
		placer = nil]]
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
