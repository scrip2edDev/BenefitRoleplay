-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = Shared:WaitForChild("Assets")

local UI = Assets:WaitForChild("UI")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game:GetService("Players").LocalPlayer
local PollController = Knit.CreateController({ Name = "PollController" })

-- // Functions \\ --

local function CreatePollUI(PollID: string, Question: string, Answers: any)
	local PollUIScreen = UI:WaitForChild("PollUI")
	local PollUI = PollUIScreen:Clone()
	PollUI.Parent = Player.PlayerGui
	PollUI.Name = "PollUI_" .. PollID

	local QuestionText = PollUI.Main.PollTopbar.Question
	QuestionText.Text = Question

	for _, Answer in pairs(Answers) do
		local Answer_Template = PollUI.Main.Answer_Template
		local Cloned_Answer_Template = Answer_Template:Clone()
		Cloned_Answer_Template.Parent = PollUI.Main.Choices
		Cloned_Answer_Template.Visible = true
		Cloned_Answer_Template.Text = Answer
		Cloned_Answer_Template.MouseButton1Click:Connect(function()
			PollUI:Destroy()
			Knit.GetService("PollService"):RecordAnswer(PollID, Answer)
		end)
	end
end

-- // Main \\ --

function PollController:KnitStart()
	Knit.GetService("PollService").SendVote:Connect(function(PollID: string, Data: any)
		CreatePollUI(PollID, Data.Question, Data.Answers)
	end)
end

-- // Return \\ --

return PollController
