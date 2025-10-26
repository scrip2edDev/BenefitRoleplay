-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {},
})

-- // Functions \\ --

local function setupLeaderstats(Player: Player)
	local PlayerData = Knit.GetService("PlayerData"):GetProfile(Player)
	if PlayerData then
		local leaderstats = Instance.new("Folder", Player)
		leaderstats.Name = "leaderstats"
		local Money = Instance.new("NumberValue", leaderstats)
		Money.Name = "Money"
		Money.Value = PlayerData.MoneyData.Money
	end
end

local function setupOverhead(Player: Player, Character: Model)
	--[[local OverheadService = Knit.GetService("OverheadService")
	OverheadService:LoadOverhead(Player)]]
end

-- // Main \\ --

function PlayerService:GetLeaderstat(Player: Player, leaderstat: string)
	local leaderstats = Player:FindFirstChild("leaderstats")
	local foundleaderstat = leaderstats:FindFirstChild(leaderstat)
	if leaderstats and foundleaderstat then
		return foundleaderstat
	end
	return nil
end

function PlayerService:KnitStart()
	local function characterAdded(Player: Player, Character: Model)
		setupOverhead(Player, Character)
	end
	local function playerAdded(Player: Player)
		repeat
			task.wait()
		until Knit.GetService("PlayerData"):GetProfile(Player) ~= nil

		setupLeaderstats(Player)
		if Player.Character then
			characterAdded(Player, Player.Character)
		end
		Player.CharacterAdded:Connect(function(Character: Model)
			characterAdded(Player, Character)
		end)
	end

	for _, player in Players:GetPlayers() do
		task.spawn(playerAdded, player)
	end
	Players.PlayerAdded:Connect(playerAdded)
end

-- // Return \\ --

return PlayerService
