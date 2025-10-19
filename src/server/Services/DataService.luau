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

function PlayerData:ChangeData(player: Player, dataKey: string, operation: string, value: number)
	local profile = Profiles[player]
	if not profile then
		warn(`Cannot change data for {player.Name}: Profile not found`)
		return false
	end

	local data = profile["Data"]
	if data[dataKey] == nil then
		warn(`Cannot change data for {player.Name}: Data key "{dataKey}" does not exist`)
		return false
	end

	local currentValue = data[dataKey]
	if type(currentValue) ~= "number" then
		warn(`Cannot change data for {player.Name}: Data key "{dataKey}" is not a number`)
		return false
	end

	local newValue = currentValue

	if operation == "add" then
		newValue = currentValue + value
	elseif operation == "subtract" then
		newValue = currentValue - value
	elseif operation == "multiply" then
		newValue = currentValue * value
	elseif operation == "divide" then
		if value == 0 then
			warn(`Cannot divide by zero for {player.Name}`)
			return false
		end
		newValue = currentValue / value
	elseif operation == "set" then
		newValue = value
	else
		warn(`Invalid operation "{operation}" for {player.Name}`)
		return false
	end

	data[dataKey] = newValue

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local stat = leaderstats:FindFirstChild(dataKey)
		if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
			stat.Value = newValue
		end
	end

	return true
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
				PlotService.UnclaimPlot(player)

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

				if profile["Data"].MoneyTransferCompleted == false then
					local benefitsMoney = game:GetService("DataStoreService"):GetDataStore("BenefitsMoney")
					local oldMoney = benefitsMoney:GetAsync(player.UserId)
					profile["Data"].Money = oldMoney
					profile["Data"].MoneyTransferCompleted = true
				end

				local leaderstats = Instance.new("Folder", player)
				leaderstats.Name = "leaderstats"
				local Money = Instance.new("IntValue", leaderstats)
				Money.Name = "Money"
				print(profile["Data"])
				Money.Value = profile["Data"].Money
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
