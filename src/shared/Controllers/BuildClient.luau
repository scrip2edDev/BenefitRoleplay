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

local connections = {}

-- // Functions \\ --

local function setupMobileControls()
	if not isMobile then
		return
	end

	if not BuildModeUi:FindFirstChild("MobileControls") then
		local mobileControls = Instance.new("Frame")
		mobileControls.Name = "MobileControls"
		mobileControls.Size = UDim2.new(0, 200, 0, 60)
		mobileControls.Position = UDim2.new(0.5, -100, 0.9, -30)
		mobileControls.BackgroundTransparency = 1
		mobileControls.Visible = false
		mobileControls.ZIndex = 100
		mobileControls.Parent = BuildModeUi

		local rotateLeft = Instance.new("TextButton")
		rotateLeft.Name = "RotateLeft"
		rotateLeft.Size = UDim2.new(0, 50, 0, 50)
		rotateLeft.Position = UDim2.new(0, 0, 0, 0)
		rotateLeft.Text = "↺"
		rotateLeft.TextSize = 24
		rotateLeft.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		rotateLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
		rotateLeft.BorderSizePixel = 2
		rotateLeft.ZIndex = 11
		rotateLeft.Parent = mobileControls

		local rotateLeftCorner = Instance.new("UICorner")
		rotateLeftCorner.CornerRadius = UDim.new(0, 8)
		rotateLeftCorner.Parent = rotateLeft

		local rotateRight = Instance.new("TextButton")
		rotateRight.Name = "RotateRight"
		rotateRight.Size = UDim2.new(0, 50, 0, 50)
		rotateRight.Position = UDim2.new(0, 60, 0, 0)
		rotateRight.Text = "↻"
		rotateRight.TextSize = 24
		rotateRight.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		rotateRight.TextColor3 = Color3.fromRGB(255, 255, 255)
		rotateRight.BorderSizePixel = 2
		rotateRight.ZIndex = 11
		rotateRight.Parent = mobileControls

		local rotateRightCorner = Instance.new("UICorner")
		rotateRightCorner.CornerRadius = UDim.new(0, 8)
		rotateRightCorner.Parent = rotateRight

		local confirm = Instance.new("TextButton")
		confirm.Name = "Confirm"
		confirm.Size = UDim2.new(0, 50, 0, 50)
		confirm.Position = UDim2.new(0, 120, 0, 0)
		confirm.Text = "✓"
		confirm.TextSize = 24
		confirm.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
		confirm.BorderSizePixel = 2
		confirm.ZIndex = 11
		confirm.Parent = mobileControls

		local confirmCorner = Instance.new("UICorner")
		confirmCorner.CornerRadius = UDim.new(0, 8)
		confirmCorner.Parent = confirm
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

-- // Main \\ --

function BuildClient:KnitStart()
	BuildModeUi = BuildMode_Template:Clone()
	BuildModeUi.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	setupMobileControls()

	BuildModeUi.BuildButton.MouseButton1Click:Connect(function()
		if placer ~= nil then
			placer:Destroy()
			placer = nil
			BuildModeUi.Decorating.Visible = true
		end
		if BuildModeUi.Decorating.Visible == false then
			loadGuiItems()
			BuildModeUi.Decorating.Visible = true
		end
	end)

	BuildModeUi.Decorating.Exit.MouseButton1Click:Connect(function()
		if BuildModeUi.Decorating.Visible == true then
			BuildModeUi.Decorating.Visible = false
			unloadGuiItems()
		end
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

			if isMobile and BuildModeUi.Decorating:FindFirstChild("MobileControls") then
				BuildModeUi.Decorating.MobileControls.Visible = true
			end

			placer = ClientPlacer.new(plot, ItemData.Model, nil, function()
				BuildModeUi.Decorating.Visible = true
				if BuildModeUi.Decorating:FindFirstChild("MobileControls") then
					BuildModeUi.Decorating.MobileControls.Visible = false
				end
				if placer then
					placer:Destroy()
					placer = nil
				end
			end)

			if isMobile and placer then
				local mobileControls = BuildModeUi.MobileControls

				if connections["RotateLeft"] then
					connections["RotateLeft"]:Disconnect()
				end
				if connections["RotateRight"] then
					connections["RotateRight"]:Disconnect()
				end
				if connections["Confirm"] then
					connections["Confirm"]:Disconnect()
				end

				connections["RotateLeft"] = mobileControls.RotateLeft.MouseButton1Click:Connect(function()
					if placer and placer.Rotate then
						placer:Rotate(-90)
					end
				end)

				connections["RotateRight"] = mobileControls.RotateRight.MouseButton1Click:Connect(function()
					if placer and placer.Rotate then
						placer:Rotate(90)
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
