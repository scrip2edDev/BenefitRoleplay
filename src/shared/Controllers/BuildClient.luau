-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")

local UI = Assets:WaitForChild("UI")
local BuildingSystem = Modules:WaitForChild("BuildingSystem")
local BuildingModules = BuildingSystem:WaitForChild("BuildModules")

local ClientPlacer = require(BuildingModules:WaitForChild("ClientPlacer"))
local ClientDelete = require(BuildingModules:WaitForChild("ClientDelete"))
local ClientPainter = require(BuildingModules:WaitForChild("ClientPainter"))
local BuildClient = Knit.CreateController({ Name = "BuildClient" })
local BuildMode_Template = UI:WaitForChild("BuildMode")

local BuildMode_Config = require(BuildingSystem:WaitForChild("Build_Mode_Config"))

local placer = nil
local painter = nil
local deleter = nil
local BuildModeUi = nil
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local selectedTool = ""
local connections = {}

-- // Functions \\ --

local function loadDecoratingCategoryItems(CategoryName, CategoryData)
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

local function loadDecoratingGuiItems()
	local Decorating = BuildModeUi:WaitForChild("Decorating")
	for CategoryName, CategoryData in pairs(BuildMode_Config.Categories) do
		local Template = Decorating.Categories.Template
		local Category: TextButton = Template:Clone()
		Category.Parent = Decorating.Categories.ScrollingFrame
		Category.Visible = true
		Category.Name = CategoryName
		Category.Text = CategoryName
		Category.MouseButton1Click:Connect(function()
			loadDecoratingCategoryItems(CategoryName, CategoryData)
		end)
	end
end

local function unloadDecoratingGuiItems()
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

local function loadPaintingGuiItems()
	local Painting = BuildModeUi:WaitForChild("Painting")
	local Colours = Painting:WaitForChild("Colours")
	local Textures = Painting:WaitForChild("Textures")

	local ColourTemplate = Colours:WaitForChild("ColourTemplate")
	local TextureTemplate = Colours:WaitForChild("TextureTemplate")

	for ColourName, Colour in BuildMode_Config.PaintingSystem.Colours do
		local ColourTemplateClone = ColourTemplate:Clone()
		ColourTemplateClone.Parent = Colours:WaitForChild("ScrollingFrame")
		ColourTemplateClone.Visible = true
		ColourTemplateClone.BackgroundColor3 = Colour
		ColourTemplateClone.Name = ColourName
		ColourTemplateClone.Text = ColourName
		ColourTemplateClone.MouseButton1Click:Connect(function()
			Painting.Visible = false

			local plot = Knit.GetService("PlotService"):GetPlot()
			painter = ClientPainter.new(plot, Colour, function()
				Painting.Visible = true
				if painter then
					painter:Destroy()
					painter = nil
				end
			end)
		end)
	end
	for TextureName, Texture in BuildMode_Config.PaintingSystem.Textures do
		local TextureTemplateClone = TextureTemplate:Clone()
		TextureTemplateClone.Parent = Textures:WaitForChild("ScrollingFrame")
		TextureTemplateClone.Visible = true
		TextureTemplateClone.Image = Texture
		TextureTemplateClone.Name = TextureName
		TextureTemplateClone.Text = TextureName
	end
end

local function unloadPaintingGuiItems()
	local Painting = BuildModeUi:WaitForChild("Painting")
	local Colours = Painting:WaitForChild("Colours")
	local Textures = Painting:WaitForChild("Textures")

	for _, Colour in pairs(Colours.ScrollingFrame:GetChildren()) do
		if Colour:IsA("GuiPart") then
			Colour:Destroy()
		end
	end
	for _, Texture in pairs(Textures.ScrollingFrame:GetChildren()) do
		if Texture:IsA("GuiPart") then
			Texture:Destroy()
		end
	end
end

local function cleanupTools()
	if placer then
		placer:Destroy()
		placer = nil
	end

	if painter then
		painter:Destroy()
		painter = nil
	end

	if deleter then
		deleter:Destroy()
		deleter = nil
	end
end

local function onToolChange(newTool: string?)
	cleanupTools()

	BuildModeUi.Decorating.Visible = false
	BuildModeUi.Painting.Visible = false
	BuildModeUi.ToolBar.Build.ImageColor3 = Color3.fromRGB(255, 255, 255)
	BuildModeUi.ToolBar.Paint.ImageColor3 = Color3.fromRGB(255, 255, 255)
	BuildModeUi.ToolBar.Delete.ImageColor3 = Color3.fromRGB(255, 255, 255)
	selectedTool = newTool
	unloadDecoratingGuiItems()
	unloadPaintingGuiItems()

	if newTool == "Build" then
		loadDecoratingGuiItems()
		BuildModeUi.Decorating.Visible = true
		BuildModeUi.ToolBar.Build.ImageColor3 = Color3.fromRGB(52, 52, 52)
	elseif newTool == "Paint" then
		loadPaintingGuiItems()
		BuildModeUi.Painting.Visible = true
		BuildModeUi.ToolBar.Paint.ImageColor3 = Color3.fromRGB(52, 52, 52)
	elseif newTool == "Delete" then
		BuildModeUi.ToolBar.Delete.ImageColor3 = Color3.fromRGB(52, 52, 52)

		local plot = Knit.GetService("PlotService"):GetPlot()
		deleter = ClientDelete.new(plot)
	end
end

-- // Main \\ --

function BuildClient:SetVisibility(SetVisibility: boolean)
	if BuildModeUi then
		BuildModeUi.Enabled = SetVisibility
	end
end

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
						placer:Rotate(45)
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
