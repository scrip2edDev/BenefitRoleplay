-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")

local ClientPlacer = require(Modules:WaitForChild("ClientPlacer"))
local BuildClient = Knit.CreateController({ Name = "BuildClient" })
local BuildMode_Template = Assets:WaitForChild("BuildMode")

local BuildMode_Config = require(Modules:WaitForChild("Build_Mode_Config"))

local placer = nil
local BuildModeUi = nil
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local selectedTool = ""
local connections = {}

local deleteToolActive = false
local hoveredObject = nil
local originalColors = {}

-- // Functions \\ --

local function resetHoveredObject()
	if hoveredObject then
		for part, color in pairs(originalColors) do
			if part and part.Parent then
				part.Color = color
			end
		end
		originalColors = {}
		hoveredObject = nil
	end
end

local function highlightObject(object: Model | BasePart)
	resetHoveredObject()
	hoveredObject = object

	local parts = {}
	if object:IsA("Model") then
		for _, part in object:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end
	elseif object:IsA("BasePart") then
		table.insert(parts, object)
	end

	for _, part in parts do
		originalColors[part] = part.Color
		part.Color = Color3.fromRGB(255, 0, 0)
	end
end

local function updateDeleteToolHover()
	if not deleteToolActive then
		return
	end

	local mouse = game.Players.LocalPlayer:GetMouse()
	local camera = workspace.CurrentCamera
	local plot = Knit.GetService("PlotService"):GetPlot()

	if not plot then
		resetHoveredObject()
		return
	end

	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {}
	params.FilterType = Enum.RaycastFilterType.Include

	local objectsFolder = plot:FindFirstChild("Objects")
	if objectsFolder then
		params.FilterDescendantsInstances = objectsFolder:GetDescendants()
	end

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)

	if result and result.Instance then
		local hitPart = result.Instance
		local objectToDelete = hitPart

		if objectsFolder then
			while objectToDelete and objectToDelete.Parent ~= objectsFolder do
				objectToDelete = objectToDelete.Parent
			end
		end

		if objectToDelete and objectToDelete ~= hoveredObject then
			highlightObject(objectToDelete)
		end
	else
		resetHoveredObject()
	end
end

local function startDeleteTool()
	deleteToolActive = true
	resetHoveredObject()

	connections["DeleteHover"] = game:GetService("RunService").RenderStepped:Connect(function()
		updateDeleteToolHover()
	end)

	connections["DeleteClick"] = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		local validInput = input.UserInputType == Enum.UserInputType.MouseButton1
			or (isMobile and input.UserInputType == Enum.UserInputType.Touch)

		if validInput and hoveredObject then
			local success = Knit.GetService("PlotService"):Delete(hoveredObject)
			if success then
				resetHoveredObject()
			end
		end
	end)
end

local function stopDeleteTool()
	deleteToolActive = false
	resetHoveredObject()

	if connections["DeleteHover"] then
		connections["DeleteHover"]:Disconnect()
		connections["DeleteHover"] = nil
	end

	if connections["DeleteClick"] then
		connections["DeleteClick"]:Disconnect()
		connections["DeleteClick"] = nil
	end
end

local function loadCategoryItems(CategoryName, CategoryData)
	local Decorating = BuildModeUi:WaitForChild("Decorating")
	local Template = Decorating.ItemFrame_Template
	for _, ItemInFrame in pairs(Decorating.ItemFrame:GetChildren()) do
		if ItemInFrame:IsA("ImageButton") then
			ItemInFrame:Destroy()
		end
	end
	for _, ItemName in pairs(CategoryData) do
		local ItemData = BuildMode_Config.Items[ItemName]
		if ItemData then
			local Item = Template:Clone()
			Item.Parent = Decorating.ItemFrame
			Item.Visible = true
			Item.Name = ItemName
			Item.ItemName.Text = ItemName
			Item.MouseButton1Click:Connect(function()
				if Decorating.PriceFrame.ItemViewport:FindFirstChild("ViewportModel") then
					Decorating.PriceFrame.ItemViewport.ViewportModel:Destroy()
				end
				if Decorating.PriceFrame.ItemViewport:FindFirstChild("Camera") then
					Decorating.PriceFrame.ItemViewport.Camera:Destroy()
				end
				Decorating.PriceFrame.ItemName.Text = ItemName
				Decorating.PriceFrame.Price.Text = "Price: £" .. tostring(ItemData.Price)
				local camera = Instance.new("Camera", Decorating.PriceFrame.ItemViewport)
				Decorating.PriceFrame.ItemViewport.CurrentCamera = camera
				local viewportModel = ItemData.Model
				local viewportClone = viewportModel:Clone()
				viewportClone.Parent = Decorating.PriceFrame.ItemViewport
				if viewportClone:FindFirstChild("CameraPoint") then
					Decorating.PriceFrame.ItemViewport.CurrentCamera.CFrame = viewportClone.CameraPoint.CFrame
				end
				viewportClone.Name = "ViewportModel"
			end)

			local camera = Instance.new("Camera", Item.ViewportFrame)
			Item.ViewportFrame.CurrentCamera = camera
			local viewportModel = ItemData.Model
			local viewportClone = viewportModel:Clone()
			viewportClone.Parent = Item.ViewportFrame
			if viewportClone:FindFirstChild("CameraPoint") then
				Item.ViewportFrame.CurrentCamera.CFrame = viewportClone.CameraPoint.CFrame
			end
			viewportClone.Name = "ViewportModel"
		end
	end
end

local function loadGuiItems()
	local Decorating = BuildModeUi:WaitForChild("Decorating")
	for CategoryName, CategoryData in pairs(BuildMode_Config.Categories) do
		local Template = Decorating.Categories.Template
		local Category: TextButton = Template:Clone()
		Category.Parent = Decorating.Categories.ScrollingFrame
		Category.Visible = true
		Category.Name = CategoryName
		Category.Text = CategoryName
		Category.MouseButton1Click:Connect(function()
			loadCategoryItems(CategoryName, CategoryData)
		end)
	end
end

local function unloadGuiItems()
	local Decorating = BuildModeUi:WaitForChild("Decorating")
	Decorating.PriceFrame.ItemName.Text = "Item Name"
	Decorating.PriceFrame.Price.Text = "Price: £-"
	if Decorating.PriceFrame.ItemViewport:FindFirstChild("ViewportModel") then
		Decorating.PriceFrame.ItemViewport.ViewportModel:Destroy()
	end
	if Decorating.PriceFrame.ItemViewport:FindFirstChild("Camera") then
		Decorating.PriceFrame.ItemViewport.Camera:Destroy()
	end
	for _, ItemInFrame in pairs(Decorating.ItemFrame:GetChildren()) do
		if ItemInFrame:IsA("ImageButton") then
			ItemInFrame:Destroy()
		end
	end
	for _, CategoryItem in pairs(Decorating.Categories.ScrollingFrame:GetChildren()) do
		if CategoryItem:IsA("TextButton") then
			CategoryItem:Destroy()
		end
	end

	if Decorating:FindFirstChild("MobileControls") then
		Decorating.MobileControls.Visible = false
	end

	if placer then
		placer:Destroy()
		placer = nil
	end
end

local function onToolChange(newTool: string?)
	if placer ~= nil then
		placer:Destroy()
		placer = nil
	end

	if deleteToolActive then
		stopDeleteTool()
	end

	BuildModeUi.Decorating.Visible = false
	BuildModeUi.Painting.Visible = false
	BuildModeUi.ToolBar.Build.ImageColor3 = Color3.fromRGB(52, 52, 52)
	BuildModeUi.ToolBar.Paint.ImageColor3 = Color3.fromRGB(52, 52, 52)
	BuildModeUi.ToolBar.Delete.ImageColor3 = Color3.fromRGB(52, 52, 52)
	selectedTool = newTool
	unloadGuiItems()
	if newTool == "Build" then
		loadGuiItems()
		BuildModeUi.Decorating.Visible = true
		BuildModeUi.ToolBar.Build.ImageColor3 = Color3.fromRGB(255, 255, 255)
	elseif newTool == "Paint" then
		BuildModeUi.Painting.Visible = true
		BuildModeUi.ToolBar.Paint.ImageColor3 = Color3.fromRGB(255, 255, 255)
	elseif newTool == "Delete" then
		BuildModeUi.ToolBar.Delete.ImageColor3 = Color3.fromRGB(255, 255, 255)
		startDeleteTool()
	end
end

-- // Main \\ --

function BuildClient:KnitStart()
	BuildModeUi = BuildMode_Template:Clone()
	BuildModeUi.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	BuildModeUi.ToolBar.Build.MouseButton1Click:Connect(function()
		if BuildModeUi.Decorating.Visible == true then
			onToolChange()
		else
			onToolChange("Build")
		end
	end)

	BuildModeUi.ToolBar.Paint.MouseButton1Click:Connect(function()
		if BuildModeUi.Painting.Visible == true then
			onToolChange()
		else
			onToolChange("Paint")
		end
	end)

	BuildModeUi.ToolBar.Delete.MouseButton1Click:Connect(function()
		if selectedTool == "Delete" then
			onToolChange()
		else
			onToolChange("Delete")
		end
	end)

	BuildModeUi.Decorating.Exit.MouseButton1Click:Connect(function()
		onToolChange()
	end)

	BuildModeUi.Decorating.BuyFrame.BuyButton.MouseButton1Click:Connect(function()
		local ItemName = BuildModeUi.Decorating.PriceFrame.ItemName.Text
		local ItemData = BuildMode_Config.Items[ItemName]
		if ItemData then
			if placer then
				placer:Destroy()
				placer = nil
			end
			BuildModeUi.Decorating.Visible = false
			local plot = Knit.GetService("PlotService"):GetPlot()

			if isMobile and BuildModeUi:FindFirstChild("MobileControls") then
				BuildModeUi.MobileControls.Visible = true
			end

			placer = ClientPlacer.new(plot, ItemData.Model, nil, function()
				BuildModeUi.Decorating.Visible = true
				if BuildModeUi:FindFirstChild("MobileControls") then
					BuildModeUi.MobileControls.Visible = false
				end
				if placer then
					placer:Destroy()
					placer = nil
				end
			end)

			if isMobile and placer then
				local mobileControls = BuildModeUi.MobileControls

				if connections["Rotate"] then
					connections["Rotate"]:Disconnect()
				end
				if connections["Confirm"] then
					connections["Confirm"]:Disconnect()
				end

				connections["Rotate"] = mobileControls.Rotate.MouseButton1Click:Connect(function()
					if placer and placer.Rotate then
						placer:Rotate(25)
					end
				end)

				connections["Confirm"] = mobileControls.Confirm.MouseButton1Click:Connect(function()
					if placer and placer.Place then
						placer:Place()
					end
				end)
			end
		end
	end)
end

-- // Return \\ --

return BuildClient
