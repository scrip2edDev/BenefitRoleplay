-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Assets = Shared:WaitForChild("Assets")
local UI = Assets:WaitForChild("UI")

local Player = Players.LocalPlayer
local MainMenuController = Knit.CreateController({ Name = "MainMenuController" })
local MainMenuUI

local avalogModule

-- // Functions \\ --

local function formatMoney(amount)
	local formatted = string.format("%.2f", amount)
	local int, dec = formatted:match("^([%-]?%d+)%.(%d+)$")

	if not int then
		return "£" .. formatted
	end

	local negative = false
	if int:sub(1, 1) == "-" then
		negative = true
		int = int:sub(2)
	end

	int = int:reverse():gsub("(%d%d%d)", "%1,"):reverse()

	if int:sub(1, 1) == "," then
		int = int:sub(2)
	end

	if negative then
		return "-£" .. int .. "." .. dec
	else
		return "£" .. int .. "." .. dec
	end
end

local function handleMoneyUpdate()
	local leaderstats = Player:WaitForChild("leaderstats")
	local money = leaderstats:WaitForChild("Money")

	local moneyText = MainMenuUI:WaitForChild("MoneyFrame"):WaitForChild("Money")

	if leaderstats and money and moneyText then
		moneyText.Text = formatMoney(money.Value)
		money:GetPropertyChangedSignal("Value"):Connect(function()
			moneyText.Text = formatMoney(money.Value)
		end)
	end
end

-- // Main \\ --

function MainMenuController:SetVisibility(SetVisibility: boolean)
	if MainMenuUI then
		MainMenuUI.Enabled = SetVisibility
	end
end

function MainMenuController:KnitStart()
	MainMenuUI = UI:WaitForChild("MainMenu"):Clone()
	MainMenuUI.Parent = Player.PlayerGui

	local TopbarButtons = MainMenuUI:WaitForChild("TopbarButtons")

	-- // Shop Gui \\ --

	local shopMenuTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
	TopbarButtons.Shop.MouseButton1Click:Connect(function()
		if MainMenuUI.SupportUs.Visible == false then
			MainMenuUI.SupportUs.Visible = true
			TweenService:Create(MainMenuUI.SupportUs, shopMenuTweenInfo, { Position = UDim2.new(0.5, 0, 0.5, 0) })
				:Play()
		else
			local tween =
				TweenService:Create(MainMenuUI.SupportUs, shopMenuTweenInfo, { Position = UDim2.new(0.5, 0, 2, 0) })
			tween:Play()
			tween.Completed:Connect(function()
				MainMenuUI.SupportUs.Visible = false
			end)
		end
	end)

	-- // Other Topbar Buttons \\ --

	TopbarButtons.TeleportHouse.MouseButton1Click:Connect(function()
		Knit.GetService("PlotService"):TeleportHome()
	end)

	TopbarButtons.Avatar.MouseButton1Click:Connect(function()
		avalogModule:ToggleOpen()
	end)

	TopbarButtons.LockHouse.MouseButton1Click:Connect(function()
		local locked_Status = Knit.GetService("PlotService"):ToggleHouseLock()
		if locked_Status then
			TopbarButtons.LockHouse.ImageLabel.Image = "rbxassetid://3610239960"
		else
			TopbarButtons.LockHouse.ImageLabel.Image = "rbxassetid://3610242099"
		end
	end)

	-- // Avatar Topbar Button \\ --

	local Avalog = require(game.Workspace:WaitForChild("Avalog"):WaitForChild("Avalog")) :: any
	local Config =
		require(game.Workspace:WaitForChild("Avalog"):WaitForChild("EasyLoader"):WaitForChild("Config")) :: any

	Avalog.Config:Update(Config)
	Avalog:Start()

	avalogModule = Avalog

	-- // Money Update \\ --

	handleMoneyUpdate()
end

-- // Return \\ --

return MainMenuController
