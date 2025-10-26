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

local DataKey = game:GetService("RunService"):IsStudio() and "Development" or "Production"
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

function PlayerData:ChangeData(
	player: Player,
	dataKey: string,
	operation: string,
	value: string | number,
	leaderstatToUpdate: string?
)
	local profile = Profiles[player]
	if not profile then
		warn(`Cannot change data for {player.Name}: Profile not found`)
		return false, nil
	end

	local data = profile["Data"]

	local keys = string.split(dataKey, ".")
	local currentTable = data
	local finalKey = nil

	for i, key in ipairs(keys) do
		if i == #keys then
			finalKey = key
			break
		else
			if currentTable[key] == nil then
				warn(`Cannot change data for {player.Name}: Path "{dataKey}" does not exist (missing "{key}")`)
				return false, nil
			end
			if type(currentTable[key]) ~= "table" then
				warn(`Cannot change data for {player.Name}: "{key}" in path "{dataKey}" is not a table`)
				return false, nil
			end
			currentTable = currentTable[key]
		end
	end

	if currentTable[finalKey] == nil then
		warn(`Cannot change data for {player.Name}: Data key "{dataKey}" does not exist`)
		return false, nil
	end

	local currentValue = currentTable[finalKey]
	local currentType = type(currentValue)
	local newValue = currentValue

	if currentType == "number" then
		local numValue = tonumber(value)
		if numValue == nil then
			warn(`Cannot change data for {player.Name}: Cannot convert "{value}" to a number`)
			return false, nil
		end

		if operation == "add" then
			newValue = currentValue + numValue
		elseif operation == "subtract" then
			newValue = currentValue - numValue
		elseif operation == "multiply" then
			newValue = currentValue * numValue
		elseif operation == "divide" then
			if numValue == 0 then
				warn(`Cannot divide by zero for {player.Name}`)
				return false, nil
			end
			newValue = currentValue / numValue
		elseif operation == "set" then
			newValue = numValue
		else
			warn(`Invalid operation "{operation}" for numeric data on {player.Name}`)
			return false, nil
		end
	elseif currentType == "string" then
		if operation ~= "set" then
			warn(
				`Cannot perform operation "{operation}" on string data for {player.Name}. Only "set" is allowed for strings`
			)
			return false, nil
		end
		newValue = tostring(value)
	else
		warn(`Cannot change data for {player.Name}: Data key "{dataKey}" has unsupported type "{currentType}"`)
		return false, nil
	end

	currentTable[finalKey] = newValue
	if leaderstatToUpdate then
		local playerService = Knit.GetService("PlayerService")
		local leaderstat = playerService:GetLeaderstat(player, leaderstatToUpdate)
		if leaderstat then
			leaderstat.Value = newValue
		end
	end
	return true, newValue
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
