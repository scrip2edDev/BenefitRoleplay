-- // Variables \\ --

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PollDataStore = DataStoreService:GetDataStore("COUNCIL_ESTATE_ROLEPLAY_GLOBALPOLLS")
local ActivePollsStore = DataStoreService:GetDataStore("COUNCIL_ESTATE_ROLEPLAY_ACTIVEPOLLS")
local POLL_DURATION = 24 * 60 * 60

local DISCORD_WEBHOOK_URL =
	"https://webhook.newstargeted.com/api/webhooks/1432715511485173891/o0f1HrSGmS8Xr4GmkYdzwTz7YFjjNGtkNrvyvtaymwexcF8Bn6--nF-jGBB1_jB8KqQk"

local PollService = Knit.CreateService({
	Name = "PollService",
	Client = { SendVote = Knit.CreateSignal() },
})

-- // Functions \\ --

local function generatePollID()
	return HttpService:GenerateGUID(false)
end

local function SendPollResultsToDiscord(PollID: string, PollData: any)
	local results = {}
	local totalVotes = 0

	for _, answer in ipairs(PollData.Answers) do
		results[answer] = 0
	end

	for userId, answer in pairs(PollData.PlayersWhoVoted) do
		if results[answer] then
			results[answer] = results[answer] + 1
			totalVotes = totalVotes + 1
		end
	end

	local starterName = "Unknown"
	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(PollData.StartedBy)
	end)
	if success then
		starterName = result
	end

	local resultsText = ""
	for _, answer in ipairs(PollData.Answers) do
		local voteCount = results[answer]
		local percentage = totalVotes > 0 and math.floor((voteCount / totalVotes) * 100) or 0
		resultsText = resultsText .. string.format("**%s**: %d votes (%d%%)\n", answer, voteCount, percentage)
	end

	local startedDate = os.date("%Y-%m-%d %H:%M:%S UTC", PollData.StartedAt)
	local expiredDate = os.date("%Y-%m-%d %H:%M:%S UTC", PollData.ExpiresAt)

	local embed = {
		title = "📊 Poll Results @everyone",
		description = string.format("**Question:** %s", PollData.Question),
		color = 3447003,
		fields = {
			{
				name = "Results",
				value = resultsText ~= "" and resultsText or "No votes were cast",
				inline = false,
			},
			{
				name = "Total Votes",
				value = tostring(totalVotes),
				inline = true,
			},
			{
				name = "Started By",
				value = starterName,
				inline = true,
			},
			{
				name = "Poll ID",
				value = PollID,
				inline = false,
			},
			{
				name = "Started At",
				value = startedDate,
				inline = true,
			},
			{
				name = "Expired At",
				value = expiredDate,
				inline = true,
			},
		},
		footer = {
			text = "Council Estate Roleplay - Poll System",
		},
		timestamp = os.date("!%Y-%m-%dT%H:%M:%S", os.time()),
	}

	local payload = {
		embeds = { embed },
	}

	local succ, response = pcall(function()
		return HttpService:PostAsync(
			DISCORD_WEBHOOK_URL,
			HttpService:JSONEncode(payload),
			Enum.HttpContentType.ApplicationJson,
			false
		)
	end)

	if succ then
		print("Poll results sent to Discord successfully for poll:", PollID)
	else
		warn("Failed to send poll results to Discord:", response)
	end
end

-- // Main \\ --

function PollService:StartGlobalPoll(Player: Player, Question: string, Answers: any)
	local PollID = generatePollID()
	local CurrentTime = os.time()

	local PollData = {
		StartedBy = Player.UserId,
		Question = Question,
		Answers = Answers,
		PlayersWhoVoted = {},
		StartedAt = CurrentTime,
		ExpiresAt = CurrentTime + POLL_DURATION,
		ResultsSent = false,
	}

	local success, err = pcall(function()
		PollDataStore:SetAsync(PollID, PollData)
	end)

	if not success then
		warn("Failed to save poll:", err)
		return nil
	end

	pcall(function()
		local activePollsList = ActivePollsStore:GetAsync("ActivePolls") or {}
		table.insert(activePollsList, PollID)
		ActivePollsStore:SetAsync("ActivePolls", activePollsList)
	end)

	MessagingService:PublishAsync("COUNCIL_ESTATE_ROLEPLAY_GLOBALPOLLS", PollID)

	return PollID
end

function PollService:IsPollExpired(PollID: string): boolean
	local success, PollData = pcall(function()
		return PollDataStore:GetAsync(PollID)
	end)

	if not success or not PollData then
		warn("Failed to retrieve poll data for ID:", PollID)
		return true
	end

	local CurrentTime = os.time()
	return CurrentTime >= PollData.ExpiresAt
end

function PollService:GetPollData(PollID: string)
	local success, PollData = pcall(function()
		return PollDataStore:GetAsync(PollID)
	end)

	if not success or not PollData then
		return nil
	end

	return PollData
end

function PollService:GetActivePollsForPlayer(PlayerUserId: number)
	local activePollsList = {}

	local success, allActivePolls = pcall(function()
		return ActivePollsStore:GetAsync("ActivePolls") or {}
	end)

	if not success then
		warn("Failed to get active polls list")
		return activePollsList
	end

	for _, pollID in ipairs(allActivePolls) do
		local pollData = self:GetPollData(pollID)

		if pollData then
			local isExpired = self:IsPollExpired(pollID)
			local hasVoted = pollData.PlayersWhoVoted[PlayerUserId] ~= nil

			if not isExpired and not hasVoted then
				table.insert(activePollsList, {
					PollID = pollID,
					Question = pollData.Question,
					Answers = pollData.Answers,
				})
			end
		end
	end

	return activePollsList
end

function PollService:CleanupExpiredPolls()
	local success, allActivePolls = pcall(function()
		return ActivePollsStore:GetAsync("ActivePolls") or {}
	end)

	if not success then
		warn("Failed to get active polls for cleanup")
		return
	end

	local updatedPollsList = {}

	for _, pollID in ipairs(allActivePolls) do
		local pollData = self:GetPollData(pollID)

		if pollData then
			local isExpired = self:IsPollExpired(pollID)

			if isExpired then
				if not pollData.ResultsSent then
					SendPollResultsToDiscord(pollID, pollData)

					pollData.ResultsSent = true
					local saveSuccess = pcall(function()
						PollDataStore:SetAsync(pollID, pollData)
					end)

					if saveSuccess then
						print("Marked poll as results sent:", pollID)
					else
						warn("Failed to mark poll as results sent:", pollID)
					end
				end
			else
				table.insert(updatedPollsList, pollID)
			end
		end
	end

	local updateSuccess = pcall(function()
		ActivePollsStore:SetAsync("ActivePolls", updatedPollsList)
	end)

	if updateSuccess then
		print("Updated active polls list. Remaining active polls:", #updatedPollsList)
	else
		warn("Failed to update active polls list")
	end
end

function PollService.Client:RecordAnswer(Player: Player, PollID: string, Answer: string)
	if PollService:IsPollExpired(PollID) then
		warn("Cannot record answer: Poll has expired")
		return false
	end

	local PollData = PollService:GetPollData(PollID)
	if not PollData then
		warn("Poll data not found")
		return false
	end

	if PollData.PlayersWhoVoted[Player.UserId] then
		warn("Player has already voted on this poll")
		return false
	end

	local validAnswer = false
	for _, validAns in ipairs(PollData.Answers) do
		if validAns == Answer then
			validAnswer = true
			break
		end
	end

	if not validAnswer then
		warn("Invalid answer provided")
		return false
	end

	PollData.PlayersWhoVoted[Player.UserId] = Answer

	local success, err = pcall(function()
		PollDataStore:SetAsync(PollID, PollData)
	end)

	if not success then
		warn("Failed to save vote:", err)
		return false
	end

	return true
end

function PollService.Client:GetUnansweredPolls(Player: Player)
	return PollService:GetActivePollsForPlayer(Player.UserId)
end

function PollService:KnitStart()
	MessagingService:SubscribeAsync("COUNCIL_ESTATE_ROLEPLAY_GLOBALPOLLS", function(message)
		local PollID = message.Data
		local PollData = PollService:GetPollData(PollID)
		if PollData then
			PollService.Client.SendVote:FireAll(PollID, { Question = PollData.Question, Answers = PollData.Answers })
		end
	end)

	Players.PlayerAdded:Connect(function(Player)
		local unansweredPolls = PollService:GetActivePollsForPlayer(Player.UserId)

		for _, pollInfo in ipairs(unansweredPolls) do
			PollService.Client.SendVote:Fire(
				Player,
				pollInfo.PollID,
				{ Question = pollInfo.Question, Answers = pollInfo.Answers }
			)
		end
	end)

	while task.wait(300) do
		PollService:CleanupExpiredPolls()
	end
end

-- // Main \\ --

return PollService
