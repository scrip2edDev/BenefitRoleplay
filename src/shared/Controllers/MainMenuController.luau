-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Assets = Shared:WaitForChild("Assets")
local UI = Assets:WaitForChild("UI")

local Player = Players.LocalPlayer
local MainMenuController = Knit.CreateController({ Name = "MainMenuController" })
local MainMenuUI

-- // Functions \\ --

-- // Main \\ --

function MainMenuController:SetVisibility(SetVisibility: boolean)
	if MainMenuUI then
		MainMenuUI.Enabled = SetVisibility
	end
end

function MainMenuController:KnitStart()
	MainMenuUI = UI:WaitForChild("MainMenu"):Clone()
	MainMenuUI.Parent = Player.PlayerGui
end

-- // Return \\ --

return MainMenuController
