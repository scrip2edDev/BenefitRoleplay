-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local ServerPackages = ServerScriptService:WaitForChild("ServerPackages")
local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")

local Knit = require(Packages:WaitForChild("Knit") or Packages.Knit)
local ProfileStore = require(ServerPackages:WaitForChild("ProfileStore") or ServerPackages.ProfileStore)

local PlayerData = Knit.CreateService({
	Name = "PlayerData",
	Client = {},
})

local PROFILE_TEMPLATE = require(Modules:WaitForChild("Player_Data_Template"))

local DataKey = game:GetService("RunService"):IsStudio() and "Dev" or "Prod"
local PlayerStore = ProfileStore.New(DataKey, PROFILE_TEMPLATE)
local Profiles: { [Player]: typeof(PlayerStore:StartSessionAsync()) } = {}

-- // Main \\ --

function PlayerData:GetProfile(player: Player)
	local profile = Profiles[player]
	if profile then
		return profile["Data"]
	end
	return nil
end

function PlayerData:KnitStart()
	local function PlayerAdded(player)
		local PlotService = Knit.GetService("PlotService")
		local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})

		if profile ~= nil then
			profile:AddUserId(player.UserId)
			profile:Reconcile()

			profile.OnSessionEnd:Connect(function()
				local plot = PlotService.GetPlot(player)
				if plot then
					local plotData = PlotService.serializePlot(plot)
					print(plotData)
					profile["Data"].PlayerBuildData = plotData
				end

				PlotService.ReturnAvailablePlot(player)
				print(`{player.Name}'s Data:`)
				print(profile["Data"])
				Profiles[player] = nil

				print(`Profile session ended for {player.Name}!`)
				player:Kick("Profile session ended - Please rejoin")
			end)

			if player.Parent == Players then
				Profiles[player] = profile
				print(`Profile loaded for {player.Name}!`)
				print(`{player.Name}'s Data:`)
				print(profile["Data"])
			else
				profile:EndSession()
			end
		else
			player:Kick(`Profile load fail - Please rejoin`)
		end
	end

	for _, player in Players:GetPlayers() do
		task.spawn(PlayerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)

	Players.PlayerRemoving:Connect(function(player)
		local profile = Profiles[player]
		if profile ~= nil then
			profile:EndSession()
		end
	end)
end

-- // Return \\ --

return PlayerData
