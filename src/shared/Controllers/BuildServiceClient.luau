-- // Variables  \\ --

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

local Knit = require(ReplicatedStorage.Packages.Knit)
local BuildingSystem = Knit.CreateController({ Name = "BuildServiceClient" })
BuildingSystem.__index = BuildingSystem

local Builds = workspace

-- // Functions \\ --

function BuildingSystem:Initialize()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		self:HandleInput(input)
	end)

	RunService.Heartbeat:Connect(function()
		if self.isBuilding then
			self:UpdatePreview()
		end
	end)
end

function BuildingSystem:HandleInput(input)
	if input.KeyCode == Enum.KeyCode.B then
		self:ToggleBuildMode()
	elseif input.KeyCode == Enum.KeyCode.One then
		self:SetBuildType("Foundation")
	elseif input.KeyCode == Enum.KeyCode.Two then
		self:SetBuildType("Wall")
	elseif input.KeyCode == Enum.KeyCode.Three then
		self:SetBuildType("Window Frame")
	elseif input.KeyCode == Enum.KeyCode.Four then
		self:SetBuildType("Door Frame")
	elseif input.KeyCode == Enum.KeyCode.Five then
		self:SetBuildType("Door")
	elseif input.KeyCode == Enum.KeyCode.Six then
		self:SetBuildType("Roof")
	elseif input.KeyCode == Enum.KeyCode.Seven then
		self:SetBuildType("Stairs")
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and self.isBuilding then
		self:PlaceBuilding()
	elseif input.KeyCode == Enum.KeyCode.R and self.isBuilding then
		self:RotatePreview()
	end
end

function BuildingSystem:ToggleBuildMode()
	if self.isBuilding then
		self:ExitBuildMode()
	else
		self:EnterBuildMode()
	end
end

function BuildingSystem:EnterBuildMode()
	self.isBuilding = true
	self.currentRotation = 0
	self.rotatedAmount = 0
	self:CreatePreviewModel()
end

function BuildingSystem:ExitBuildMode()
	self.isBuilding = false
	self:DestroyPreviewModel()
	self:DisableRoofs()
	self:DisableStairs()
end

function BuildingSystem:SetBuildType(buildType)
	self.selectedBuildType = buildType
	if self.isBuilding then
		self.currentRotation = 0
		self.rotatedAmount = 0
		self:CreatePreviewModel()
	end
end

function BuildingSystem:CreatePreviewModel()
	self:DestroyPreviewModel()

	local Assets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")
	local originalModel = Assets:FindFirstChild(self.selectedBuildType)

	if not originalModel then
		warn("Could not find model:", self.selectedBuildType)
		return
	end

	self.previewModel = originalModel:Clone()
	self.previewModel.Name = "BuildPreview"
	self.previewModel.Parent = workspace

	self:ApplyPreviewMaterial(self.previewModel)
	self:SetCollisionEnabled(self.previewModel, false)

	-- Enable roof/stair querying if needed
	if self.selectedBuildType == "Roof" then
		self:EnableRoofs()
	elseif self.selectedBuildType == "Stairs" then
		self:EnableStairs()
	end
end

function BuildingSystem:ApplyPreviewMaterial(model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Material = self.previewMaterial.Material
			part.Transparency = self.previewMaterial.Transparency
			part.Color = self.previewMaterial.Color
			part.CanCollide = false
			part.Anchored = true
		end
	end
end

function BuildingSystem:SetCollisionEnabled(model, enabled)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = enabled
		end
	end
end

function BuildingSystem:EnableRoofs()
	for _, v in pairs(Builds:GetDescendants()) do
		if v.Name == "RoofPart" then
			v.CanQuery = true
		end
	end
end

function BuildingSystem:DisableRoofs()
	for _, v in pairs(Builds:GetDescendants()) do
		if v.Name == "RoofPart" then
			v.CanQuery = false
		end
	end
end

function BuildingSystem:EnableStairs()
	for _, v in pairs(Builds:GetDescendants()) do
		if v.Name == "StairsPart" then
			v.CanQuery = true
		end
	end
end

function BuildingSystem:DisableStairs()
	for _, v in pairs(Builds:GetDescendants()) do
		if v.Name == "StairsPart" then
			v.CanQuery = false
		end
	end
end

function BuildingSystem:UnitRay()
	local ur = Mouse.UnitRay
	return ur.Origin, ur.Direction * 10000
end

function BuildingSystem:CantPlace()
	self.goodToPlace = false
	for _, v in pairs(self.previewModel:GetChildren()) do
		if v:IsA("BasePart") then
			v.Color = Color3.fromRGB(255, 0, 0)
		end
	end
end

function BuildingSystem:CanPlace()
	self.goodToPlace = true
	for _, v in pairs(self.previewModel:GetChildren()) do
		if v:IsA("BasePart") then
			v.Color = Color3.fromRGB(0, 255, 0)
		end
	end
end

function BuildingSystem:UpdatePreview()
	if not self.previewModel then
		return
	end

	local Origin, Direction = self:UnitRay()

	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = { Character, self.previewModel }

	local Raycast = workspace:Raycast(Origin, Direction, Params)

	if Raycast and Raycast.Instance then
		self:HandleBuildingLogic(Raycast)
	end
end

function BuildingSystem:HandleBuildingLogic(Raycast)
	local buildType = self.selectedBuildType

	if buildType == "Wall" or buildType == "Window Frame" or buildType == "Door Frame" then
		self:HandleWallBuilding(Raycast)
	elseif buildType == "Door" then
		self:HandleDoorBuilding(Raycast)
	elseif buildType == "Foundation" then
		self:HandleFoundationBuilding(Raycast)
	elseif buildType == "Roof" then
		self:HandleRoofBuilding(Raycast)
	elseif buildType == "Stairs" then
		self:HandleStairsBuilding(Raycast)
	end
end

function BuildingSystem:HandleWallBuilding(Raycast)
	local RaycastInstance = Raycast.Instance
	local nearestAttachment = nil

	for _, attachment in pairs(RaycastInstance:GetChildren()) do
		if attachment:IsA("Attachment") and attachment.Name == "WallAttachment" then
			local attachmentPosition = attachment.WorldPosition
			local RaycastPosition = Raycast.Position
			local playerPosition = Character.PrimaryPart.Position

			if (RaycastPosition - playerPosition).Magnitude <= self.placingDistance then
				if (RaycastPosition - attachmentPosition).Magnitude < self.distance then
					if attachment:GetAttribute("Placed") == false then
						nearestAttachment = attachment
						self.attachmentThatIsBeingAttachedTo = attachment

						local wallCFrame = RaycastInstance.CFrame * CFrame.new(attachment.Position)

						for _, v in pairs(self.previewModel:GetDescendants()) do
							if v:IsA("Attachment") and v.Name == "FloorAttachment" then
								wallCFrame = wallCFrame * CFrame.new(-v.Position)
								self.attachment = v
							end
						end

						wallCFrame = wallCFrame * CFrame.Angles(0, math.rad(attachment.Orientation.Y), 0)
						self.previewModel:SetPrimaryPartCFrame(wallCFrame)
						self:CanPlace()
					end
				end
			else
				self:CantPlace()
			end
		end
	end

	if nearestAttachment == nil then
		self.previewModel:SetPrimaryPartCFrame(
			CFrame.new(
				Raycast.Position.X,
				Raycast.Position.Y + self.previewModel.PrimaryPart.Size.Y / 2,
				Raycast.Position.Z
			)
		)
		self:CantPlace()
	end
end

function BuildingSystem:HandleDoorBuilding(Raycast)
	local RaycastInstance = Raycast.Instance
	local nearestAttachment = nil

	for _, attachment in pairs(RaycastInstance:GetChildren()) do
		if attachment:IsA("Attachment") and attachment.Name == "DoorSnapAttachment" then
			local attachmentPosition = attachment.WorldPosition
			local RaycastPosition = Raycast.Position
			local playerPosition = Character.PrimaryPart.Position

			if (RaycastPosition - playerPosition).Magnitude <= self.placingDistance then
				if (RaycastPosition - attachmentPosition).Magnitude < self.distance then
					if attachment:GetAttribute("Placed") == false then
						nearestAttachment = attachment
						self.attachmentThatIsBeingAttachedTo = attachment

						local doorCFrame = RaycastInstance.CFrame * CFrame.new(attachment.Position)

						for _, v in pairs(self.previewModel:GetDescendants()) do
							if v:IsA("Attachment") and v.Name == "DoorAttachment" then
								doorCFrame = doorCFrame * CFrame.new(-v.Position)
								self.attachment = v
							end
						end

						doorCFrame = doorCFrame
							* CFrame.new(Vector3.new(6.5, -2.55, -0.1))
							* CFrame.Angles(0, 0, math.rad(90))
						self.previewModel:SetPrimaryPartCFrame(doorCFrame)
						self:CanPlace()
					end
				end
			else
				self:CantPlace()
			end
		end
	end

	if nearestAttachment == nil then
		self.previewModel:SetPrimaryPartCFrame(
			CFrame.new(
				Raycast.Position.X,
				Raycast.Position.Y + self.previewModel.PrimaryPart.Size.Y / 2,
				Raycast.Position.Z
			)
		)
		self:CantPlace()
	end
end

function BuildingSystem:HandleFoundationBuilding(Raycast)
	local RaycastInstance = Raycast.Instance
	local onwater = false
	local ontop = false
	local colliding = false
	local nearestAttachment = nil

	-- Check for foundation attachments
	for _, attachment in pairs(RaycastInstance:GetChildren()) do
		if attachment:IsA("Attachment") and attachment.Name == "FloorAttachment" then
			local attachmentPosition = attachment.WorldPosition
			local RaycastPosition = Raycast.Position
			local playerPosition = Character.PrimaryPart.Position

			if (RaycastPosition - playerPosition).Magnitude <= self.placingDistance then
				if (RaycastPosition - attachmentPosition).Magnitude < self.distance then
					if attachment:GetAttribute("Placed") == false then
						if attachment and attachment:FindFirstChildWhichIsA("StringValue") then
							nearestAttachment = attachment
							self.attachmentThatIsBeingAttachedTo = attachment

							local foundationCFrame = RaycastInstance.CFrame * CFrame.new(attachment.Position)
							local Amount = 4
							local SideFoundationIsOn = attachment:FindFirstChildWhichIsA("StringValue").Name

							if SideFoundationIsOn == "Front" then
								foundationCFrame = foundationCFrame
									* CFrame.new(attachment.CFrame.Position)
									* CFrame.new(Vector3.new(0, -(self.previewModel.PrimaryPart.Size.Y + 0.5), Amount))
									* CFrame.Angles(0, self.previewModel.PrimaryPart.Rotation.Y, 0)
							elseif SideFoundationIsOn == "Back" then
								foundationCFrame = foundationCFrame
									* CFrame.new(attachment.CFrame.Position)
									* CFrame.new(Vector3.new(0, -(self.previewModel.PrimaryPart.Size.Y + 0.5), -Amount))
									* CFrame.Angles(0, self.previewModel.PrimaryPart.Rotation.Y, 0)
							elseif SideFoundationIsOn == "Left" then
								foundationCFrame = foundationCFrame
									* CFrame.new(attachment.CFrame.Position)
									* CFrame.new(Vector3.new(Amount, -(self.previewModel.PrimaryPart.Size.Y + 0.5), 0))
									* CFrame.Angles(0, self.previewModel.PrimaryPart.Rotation.Y, 0)
							elseif SideFoundationIsOn == "Right" then
								foundationCFrame = foundationCFrame
									* CFrame.new(attachment.CFrame.Position)
									* CFrame.new(Vector3.new(-Amount, -(self.previewModel.PrimaryPart.Size.Y + 0.5), 0))
									* CFrame.Angles(0, self.previewModel.PrimaryPart.Rotation.Y, 0)
							end

							-- Find closest attachment in structure
							local targetAttachment = attachment
							local closestAttachment = nil
							local closestDistance = math.huge

							for _, v2 in pairs(self.previewModel:GetDescendants()) do
								if
									v2:IsA("Attachment")
									and v2 ~= targetAttachment
									and v2.Name == "FloorAttachment"
									and v2:GetAttribute("Placed") == false
								then
									local distance = (v2.WorldPosition - targetAttachment.WorldPosition).Magnitude
									if distance < closestDistance then
										closestDistance = distance
										closestAttachment = v2
									end
								end
							end

							self.attachment = closestAttachment
							self.previewModel:SetPrimaryPartCFrame(foundationCFrame)

							if not colliding and not ontop and not onwater then
								self:CanPlace()
							end
						end
					end
				end
			else
				self:CantPlace()
			end
		end
	end

	-- Check for water, ontop, and collision
	local MaxDistance = 10
	local Result = workspace:Raycast(self.previewModel.PrimaryPart.Position, Vector3.new(0, -1 * MaxDistance, 0))

	if Result then
		if Result.Material == Enum.Material.Water then
			onwater = true
		else
			onwater = false
		end

		if Result.Instance.Parent:FindFirstChild("Structure") then
			ontop = true
		else
			ontop = false
		end
	end

	-- Collision detection
	colliding = self:DetectCollisions(self.previewModel, RaycastInstance)

	if ontop then
		self:CantPlace()
	end

	if colliding then
		self:CantPlace()
	end

	if onwater then
		self:CantPlace()
	end

	if nearestAttachment == nil then
		self.attachment = nil
		self.previewModel:SetPrimaryPartCFrame(
			CFrame.new(
				Raycast.Position.X,
				Raycast.Position.Y + self.previewModel.PrimaryPart.Size.Y / 2,
				Raycast.Position.Z
			)
		)

		local RaycastPosition = Raycast.Position
		local playerPosition = Character.PrimaryPart.Position

		if (RaycastPosition - playerPosition).Magnitude <= self.placingDistance then
			if not colliding and not ontop and not onwater then
				self:CanPlace()
			end
		else
			self:CantPlace()
		end
	end
end

function BuildingSystem:HandleRoofBuilding(Raycast)
	local RaycastInstance = Raycast.Instance
	local nearestAttachment = nil

	for _, attachment in pairs(RaycastInstance:GetChildren()) do
		if attachment:IsA("Attachment") and attachment.Name == "RoofSnapAttachment" then
			local attachmentPosition = attachment.WorldPosition
			local RaycastPosition = Raycast.Position
			local playerPosition = Character.PrimaryPart.Position

			if (RaycastPosition - playerPosition).Magnitude <= self.placingDistance then
				if (RaycastPosition - attachmentPosition).Magnitude < self.distance then
					if attachment:GetAttribute("Placed") == false then
						local canPlaceRoof = false

						if attachment.Parent.Parent.Name == "Foundation" then
							if
								attachment.Parent.Parent
									:FindFirstChild("StairsPart")
									:FindFirstChild("StairsSnapAttachment")
									:GetAttribute("Placed") == false
							then
								local wallsUp = self:CountWallsUp(attachment.Parent.Parent)
								if wallsUp > 0 then
									canPlaceRoof = true
								end
							end
						elseif attachment.Parent.Parent.Name == "Roof" or attachment.Parent.Parent.Name == "Stairs" then
							local wallsUp = self:CountNearbyWalls(attachment.WorldPosition)
							if wallsUp > 0 then
								canPlaceRoof = true
							end
						end

						if canPlaceRoof then
							nearestAttachment = attachment
							self.attachmentThatIsBeingAttachedTo = attachment

							local roofCFrame = RaycastInstance.CFrame * CFrame.new(attachment.Position)

							for _, v in pairs(self.previewModel:GetDescendants()) do
								if v:IsA("Attachment") and v.Name == "RoofAttachment" then
									roofCFrame = roofCFrame * CFrame.new(-v.Position)
									self.attachment = v
								end
							end

							self.previewModel:SetPrimaryPartCFrame(roofCFrame)
							self.previewModel.PrimaryPart.Orientation = Vector3.new(90, 0, 0)
							self:CanPlace()
						else
							self.previewModel:SetPrimaryPartCFrame(
								CFrame.new(Raycast.Position.X, Raycast.Position.Y, Raycast.Position.Z)
									* CFrame.Angles(math.pi / 2, 0, 0)
							)
							self:CantPlace()
						end
					end
				end
			else
				self:CantPlace()
			end
		end
	end

	if nearestAttachment == nil then
		self.previewModel:SetPrimaryPartCFrame(
			CFrame.new(Raycast.Position.X, Raycast.Position.Y, Raycast.Position.Z) * CFrame.Angles(math.pi / 2, 0, 0)
		)
		self:CantPlace()
	end
end

function BuildingSystem:HandleStairsBuilding(Raycast)
	local RaycastInstance = Raycast.Instance
	local nearestAttachment = nil

	for _, attachment in pairs(RaycastInstance:GetChildren()) do
		if attachment:IsA("Attachment") and attachment.Name == "StairsSnapAttachment" then
			local attachmentPosition = attachment.WorldPosition
			local RaycastPosition = Raycast.Position
			local playerPosition = Character.PrimaryPart.Position

			if (RaycastPosition - playerPosition).Magnitude <= self.placingDistance then
				if (RaycastPosition - attachmentPosition).Magnitude < self.distance then
					if attachment:GetAttribute("Placed") == false then
						local canPlaceStairs = false

						if attachment.Parent.Parent.Name == "Foundation" then
							if
								attachment.Parent.Parent
									:FindFirstChild("RoofPart")
									:FindFirstChild("RoofSnapAttachment")
									:GetAttribute("Placed") == false
							then
								canPlaceStairs = true
							end
						elseif attachment.Parent.Parent.Name == "Roof" then
							if
								attachment.Parent.Parent
									:FindFirstChild("RoofPart")
									:FindFirstChild("RoofSnapAttachment")
									:GetAttribute("Placed") == false
							then
								canPlaceStairs = true
							end
						end

						if canPlaceStairs then
							nearestAttachment = attachment
							self.attachmentThatIsBeingAttachedTo = attachment
							self.attachment = self.previewModel.PrimaryPart:FindFirstChild("StairsAttachment")

							local stairsCFrame = RaycastInstance.CFrame * CFrame.new(attachment.Position)
							stairsCFrame = stairsCFrame
								* CFrame.new(attachment.CFrame.Position)
								* CFrame.new(Vector3.new(0, -attachment.Position.Y, 0))
								* CFrame.Angles(0, self.rotatedAmount, 0)

							self.previewModel:SetPrimaryPartCFrame(stairsCFrame)
							self:CanPlace()
						end
					end
				end
			else
				self:CantPlace()
			end
		end
	end

	if nearestAttachment == nil then
		self.previewModel:SetPrimaryPartCFrame(
			CFrame.new(
				Raycast.Position.X,
				Raycast.Position.Y + self.previewModel.PrimaryPart.Size.Y / 2,
				Raycast.Position.Z
			) * CFrame.Angles(0, self.rotatedAmount, 0)
		)
		self:CantPlace()
	end
end

function BuildingSystem:CountWallsUp(foundation)
	local wallsUp = 0
	for _, v in pairs(foundation:GetDescendants()) do
		if v.Name == "WallAttachment" then
			if v:GetAttribute("Placed") == true then
				wallsUp = wallsUp + 1
			end
		end
	end
	return wallsUp
end

function BuildingSystem:CountNearbyWalls(position)
	local wallsUp = 0
	for _, v in pairs(Builds:GetDescendants()) do
		if
			v:IsA("Attachment")
			and v.Name == "WallAttachment"
			and v:GetAttribute("Placed") == true
			and v:FindFirstChild("Top")
		then
			local lengthBetween = (position - v.WorldPosition).Magnitude
			if lengthBetween < 10 then
				wallsUp = wallsUp + 1
			end
		end
	end
	return wallsUp
end

function BuildingSystem:DetectCollisions(model, raycastInstance)
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local overlappingParts = workspace:GetPartsInPart(part)

			for _, otherPart in pairs(overlappingParts) do
				if not otherPart:IsDescendantOf(model) then
					if otherPart.CanCollide == true then
						if not otherPart:IsDescendantOf(workspace.CurrentCamera) then
							if otherPart.Parent:FindFirstChild("Structure") then
								continue
							end

							if not raycastInstance.Parent:FindFirstChild("Structure") then
								return true
							end

							if otherPart:IsDescendantOf(raycastInstance.Parent) then
								continue
							else
								return true
							end
						end
					end
				end
			end
		end
	end
	return false
end

function BuildingSystem:RotatePreview()
	if not self.previewModel then
		return
	end

	if self.selectedBuildType == "Stairs" then
		self.rotatedAmount = self.rotatedAmount + math.pi / 2
	else
		self.currentRotation = (self.currentRotation + 90) % 360
	end
end

function BuildingSystem:PlaceBuilding()
	if not self.previewModel or not self.previewModel.PrimaryPart then
		return
	end

	if self.goodToPlace == true then
		local buildData = {
			Type = self.selectedBuildType,
			CFrame = self.previewModel.PrimaryPart.CFrame,
		}

		-- Add attachment data if needed
		if self.selectedBuildType == "Foundation" then
			if self.attachment then
				buildData.Side = self.attachment:FindFirstChildWhichIsA("StringValue").Name
				buildData.AttachmentThatIsBeingAttachedTo = self.attachmentThatIsBeingAttachedTo
				buildData.AttachmentName = self.attachment.Name
			else
				buildData.Side = nil
				buildData.AttachmentThatIsBeingAttachedTo = self.attachmentThatIsBeingAttachedTo
				buildData.AttachmentName = nil
			end
		else
			if self.attachment then
				buildData.AttachmentThatIsBeingAttachedTo = self.attachmentThatIsBeingAttachedTo
				buildData.AttachmentName = self.attachment.Name
			end
		end

		Knit.GetService("BuildServer").build:Fire(buildData)

		-- Reset attachment references
		self.attachment = nil
		self.attachmentThatIsBeingAttachedTo = nil
		self.goodToPlace = false
	end
end

function BuildingSystem:DestroyPreviewModel()
	if self.previewModel then
		self.previewModel:Destroy()
		self.previewModel = nil
	end
end

function BuildingSystem:KnitStart()
	local self = setmetatable({
		isBuilding = false,
		previewModel = nil,
		selectedBuildType = "Foundation",
		maxBuildDistance = 50,
		currentRotation = 0,
		rotatedAmount = 0,
		distance = 10,
		placingDistance = 30,
		goodToPlace = false,
		attachment = nil,
		attachmentThatIsBeingAttachedTo = nil,

		previewMaterial = {
			Material = Enum.Material.ForceField,
			Transparency = 0.5,
			Color = Color3.fromRGB(0, 255, 0),
			CannotBuildColor = Color3.fromRGB(255, 0, 0),
		},
	}, BuildingSystem)

	self:Initialize()
	return self
end

-- // Return \\ --

return BuildingSystem
