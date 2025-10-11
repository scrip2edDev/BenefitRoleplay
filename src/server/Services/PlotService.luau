-- // Variables \\ --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlotsFolder = workspace:WaitForChild("Plots")
local Assets = Shared:WaitForChild("Assets")

local FurnitureFolder = Assets:WaitForChild("Furniture")

local plotSpawns = PlotsFolder:WaitForChild("PlotSpawns")
local allPlots = plotSpawns:GetChildren()

local plots: { Model } = {}
local usedplots: { BasePart } = {}
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlotService = Knit.CreateService({
	Name = "PlotService",
	Client = {},
})

-- // Functions \\ --

function PlotService.GetAvailablePlot(player: Player): BasePart
	local plotSpawn = table.remove(allPlots)
	usedplots[player.UserId] = plotSpawn
	return plotSpawn
end

function PlotService.ReturnAvailablePlot(player: Player)
	if not usedplots[player.UserId] then
		return
	end
	table.insert(allPlots, usedplots[player.UserId])
	usedplots[player.UserId] = nil
end

-- // Main \\ --

function PlotService.SpawnPlot(player: Player): Model
	local Plot = Assets.Plot_Template:Clone()
	Plot.Name = `Plot_{player.Name}`
	Plot.Parent = PlotsFolder
	Plot:PivotTo(PlotService.GetAvailablePlot(player).CFrame)
	plots[player.UserId] = Plot
	return Plot
end

function PlotService.Place(player: Player, name: string, targetCFrame: CFrame): boolean
	local object = FurnitureFolder:FindFirstChild(name)
	local plot = PlotService.GetPlot(player)

	if not object or not plot then
		return false
	end
	local newObject = object:Clone()
	newObject:PivotTo(targetCFrame)
	newObject.Parent = plot.Objects
	return true
end

function PlotService.GetPlot(player: Player): Model | nil
	return plots[player.UserId]
end

function PlotService.Client.GetPlot(player: Player): Model | nil
	return PlotService.GetPlot(player)
end

function PlotService.Client.Place(player: Player, name: string, targetCFrame: CFrame): boolean
	return PlotService.Place(player, name, targetCFrame)
end

function PlotService:KnitStart()
	Players.PlayerAdded:Connect(self.SpawnPlot)
end

-- // Return \\ --

return PlotService
