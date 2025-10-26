type ObjectInfo = {
	Name: string,
	Cframe: { number },
}

-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlotsFolder = workspace:WaitForChild("Plots")

local Assets = Shared:WaitForChild("Assets")
local Modules = Shared:WaitForChild("Modules")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlacementValidator = require(Modules:WaitForChild("PlacementValidator"))
local FurnitureFolder = Assets:WaitForChild("Furniture")
local Build_Mode_Config = require(Modules:WaitForChild("Build_Mode_Config"))

local plotSpawns = PlotsFolder:WaitForChild("PlotSpawns")
local allPlots = plotSpawns:GetChildren()

local plots: { Model } = {}
local claimedPlots: { [BasePart]: Player } = {}
local playerPlots: { [Player]: BasePart } = {}

local PlotService = Knit.CreateService({
	Name = "PlotService",
	Client = {},
})

-- // Functions \\ --

local function makeTemplateHome(plotSpawn: BasePart)
	local Plot = Assets.Plot_Template:Clone()
	Plot.Name = `Plot_DECOY{plotSpawn.Name}`
	Plot.Parent = PlotsFolder
	Plot:PivotTo(plotSpawn.CFrame)
end

local function removeTemplateHome(plotSpawn: BasePart)
	local plotDecoy = PlotsFolder:FindFirstChild(`Plot_DECOY{plotSpawn.Name}`)
	if plotDecoy then
		plotDecoy:Destroy()
	end
end

function PlotService.serializePlot(plot: Model)
	local data = {}
	local objectsFolder = plot:FindFirstChild("Objects")
	if not objectsFolder then
		return data
	end

	for _, object in objectsFolder:GetChildren() do
		if object:IsA("Model") or object:IsA("BasePart") then
			local objectCFrame = plot:GetPivot():ToObjectSpace(object:GetPivot())
			local info: ObjectInfo = {
				Name = object.Name,
				Cframe = table.pack(objectCFrame:GetComponents()),
			}
			table.insert(data, info)
		end
	end
	return data
end

-- // Main \\ --

function PlotService.Place(player: Player, name: string, targetCFrame: CFrame): boolean
	local object = FurnitureFolder:FindFirstChild(name)
	local objectInConfig = Build_Mode_Config.Items[name]
	local plot = PlotService.GetPlot(player)

	if not object or not plot or not objectInConfig then
		warn(
			`{name} - could not be placed because object or plot is nil or object was not found in config! Plot: {plot} Object: {object} ObjectInConfig: {objectInConfig}`
		)
		return false
	end

	local playerDataService = Knit.GetService("PlayerData")
	local PlayerData = playerDataService:GetProfile(player)

	if PlayerData.MoneyData.Money >= objectInConfig.Price then
	else
		warn(`{player.Name} does not have enough money to buy {name}!`)
		return false
	end

	local objectSize = object:GetExtentsSize()

	if not PlacementValidator:WithinBounds(plot, objectSize, targetCFrame) then
		warn(`{name} - could not be placed because it is not within bounds`)
		return false
	end
	if not PlacementValidator:IsSupported(plot, objectSize, targetCFrame) then
		warn(`{name} - could not be placed because it is not supported (floating in air)`)
		return false
	end

	local newObject = object:Clone()

	newObject:PivotTo(targetCFrame)
	newObject.Parent = plot.Objects

	local cameraPoint = newObject:FindFirstChild("CameraPoint")
	if cameraPoint then
		cameraPoint:Destroy()
	end

	local _success, _data =
		playerDataService:ChangeData(player, "MoneyData.Money", "subtract", objectInConfig.Price, "Money")
	return true
end

function PlotService.Delete(player: Player, object: Part): boolean
	local plot = PlotService.GetPlot(player)
	local objectInConfig = Build_Mode_Config.Items[object.Name]
	if not plot or not object or not object:IsDescendantOf(plot.Objects) then
		return false
	end

	local actualObject = object
	while actualObject.Parent ~= plot.Objects do
		actualObject = actualObject:FindFirstAncestorWhichIsA("Model")
		if not actualObject then
			return false
		end
	end
	actualObject:Destroy()

	local playerDataService = Knit.GetService("PlayerData")
	local _success, _data =
		playerDataService:ChangeData(player, "MoneyData.Money", "add", objectInConfig.Price, "Money")

	return true
end

function PlotService.GetPlot(player: Player): Model | nil
	return plots[player.UserId]
end

function PlotService.GetAvailablePlots(): { BasePart }
	local availablePlots = {}
	for _, plotSpawn in ipairs(allPlots) do
		if not claimedPlots[plotSpawn] then
			table.insert(availablePlots, plotSpawn)
		end
	end
	return availablePlots
end

function PlotService.ClaimPlot(player: Player, plotSpawn: BasePart): boolean
	if playerPlots[player] then
		warn(`Player {player.Name} already has a claimed plot`)
		return false
	end

	if claimedPlots[plotSpawn] then
		warn(`Plot is already claimed by {claimedPlots[plotSpawn].Name}`)
		return false
	end

	claimedPlots[plotSpawn] = player
	playerPlots[player] = plotSpawn

	removeTemplateHome(plotSpawn)

	local Plot = Assets.Plot_Template:Clone()
	Plot.Name = `Plot_{player.Name}`
	Plot.Parent = PlotsFolder
	Plot:PivotTo(plotSpawn.CFrame)
	plots[player.UserId] = Plot

	local character = player.Character or player.CharacterAdded:Wait()
	if character then
		character.HumanoidRootPart.CFrame = Plot.PlotTeleport.CFrame
	end

	local profile = Knit.GetService("PlayerData"):GetProfile(player)
	if profile and profile.PlayerBuildData then
		for _, objectInfo in profile.PlayerBuildData do
			local object = FurnitureFolder:FindFirstChild(objectInfo.Name)
			if object then
				local objectClone = object:Clone()
				local relativeCFrame = CFrame.new(table.unpack(objectInfo.Cframe))

				objectClone:PivotTo(Plot:GetPivot():ToWorldSpace(relativeCFrame))
				objectClone.Parent = Plot.Objects

				local cameraPoint = objectClone:FindFirstChild("CameraPoint")
				if cameraPoint then
					cameraPoint:Destroy()
				end
			else
				warn(`Could not find furniture: {objectInfo.Name}`)
			end
		end
	end

	return true
end

function PlotService.UnclaimPlot(player: Player): boolean
	local plotSpawn = playerPlots[player]
	if not plotSpawn then
		warn(`Player {player.Name} does not have a claimed plot`)
		return false
	end

	local plot = plots[player.UserId]
	if plot then
		local profile = Knit.GetService("PlayerData"):GetProfile(player)
		if profile then
			profile.PlayerBuildData = PlotService.serializePlot(plot)
		end
		plot:Destroy()
	end

	makeTemplateHome(plotSpawn)

	claimedPlots[plotSpawn] = nil
	playerPlots[player] = nil
	plots[player.UserId] = nil

	return true
end

function PlotService.ToggleHouseLock(player: Player)
	local PlayerPlot = PlotService:GetPlot(player)
	if PlayerPlot then
		for _, Part in pairs(PlayerPlot:GetChildren()) do
			if Part.Name == "LockableDoor" then
				if Part.CanCollide == false then
					Part.CanCollide = true
				else
					Part.CanCollide = false
				end
			end
		end
	end
end

function PlotService.TeleportHome(player: Player)
	local PlayerPlot = PlotService:GetPlot(player)
	if PlayerPlot then
		local character = player.Character or player.CharacterAdded:Wait()
		character.HumanoidRootPart.CFrame = PlayerPlot.PlotTeleport.CFrame
	end
end

function PlotService.Client.GetPlot(_, player: Player): Model | nil
	return PlotService.GetPlot(player)
end

function PlotService.Client:Place(player: Player, name: string, targetCFrame: CFrame): boolean
	return PlotService.Place(player, name, targetCFrame)
end

function PlotService.Client:Delete(player: Player, object: Part): boolean
	return PlotService.Delete(player, object)
end

function PlotService.Client:GetAvailablePlots(player: Player): { BasePart }
	return PlotService.GetAvailablePlots()
end

function PlotService.Client:ClaimPlot(player: Player, plotSpawn: BasePart): boolean
	return PlotService.ClaimPlot(player, plotSpawn)
end

function PlotService.Client:UnclaimPlot(player: Player): boolean
	return PlotService.UnclaimPlot(player)
end

function PlotService.Client:IsPlotClaimed(player: Player, plot: BasePart): boolean
	if claimedPlots[plot] then
		return true
	else
		return false
	end
end

function PlotService.Client:HasPlot(player: Player): boolean
	return playerPlots[player] ~= nil
end

function PlotService.Client:TeleportHome(player: Player)
	return PlotService.TeleportHome(player)
end

function PlotService.Client:ToggleHouseLock(player: Player)
	return PlotService.ToggleHouseLock(player)
end

function PlotService:KnitStart()
	for _, plotSpawn in pairs(plotSpawns:GetChildren()) do
		makeTemplateHome(plotSpawn)
	end
end

-- // Return \\ --

return PlotService
