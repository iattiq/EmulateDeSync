local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Camera = workspace.CurrentCamera

local Client = Players.LocalPlayer
local Character = Client.Character or Client.CharacterAdded:Wait()

local ServerCharacter = Character

if not Client:HasAppearanceLoaded() then
	Client.CharacterAppearanceLoaded:Wait()
end

Character.Archivable = true

local NewCharacterClone = Character:Clone()
NewCharacterClone.Name = ("%s2"):format(Client.Name)
NewCharacterClone.Parent = Client.Character.Parent

Client.Character = NewCharacterClone
Camera.CameraSubject = NewCharacterClone:WaitForChild("Humanoid", 10)

Client.Character.Animate.Enabled = false
Client.Character.Animate.Enabled = true


for _, obj in ServerCharacter:GetDescendants() do
	if not obj:IsA("BasePart") then
		obj:Destroy()
	else
		if obj:IsA("BasePart") then
			obj.Transparency = 0.5
			obj.Color = Color3.fromRGB(0, 150, 0)
		end	
	end
end


NewCharacterClone.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

local cache = {}
local cacheSize = 20 --200
local interpolationSpeed = 100


local use_vel = false



RunService.RenderStepped:Connect(function(delta)
	Client.Character = NewCharacterClone
	Camera.CameraSubject = NewCharacterClone:WaitForChild("Humanoid", 10)

	local currentFrame = {}
	for _, Object in NewCharacterClone:GetDescendants() do
		if Object:IsA("BasePart") then
			currentFrame[Object.Name] = Object.CFrame
		end
	end
	table.insert(cache, currentFrame)

	if #cache > cacheSize then
		table.remove(cache, 1)
	end

	if #cache >= cacheSize then
		local targetFrame = cache[1]

		for _, Object in ServerCharacter:GetDescendants() do
			if Object:IsA("BasePart") then
				Object.CanCollide = false
				Object.Massless = true
				Object.Velocity = Vector3.zero
				Object.AssemblyLinearVelocity = Vector3.zero
				Object.AssemblyAngularVelocity = Vector3.zero

				local targetCFrame = targetFrame[Object.Name]
				if targetCFrame then
					Object.CFrame = Object.CFrame:Lerp(targetCFrame, delta * interpolationSpeed)
				end
			end
		end
	end
	
	if use_vel then
		ServerCharacter.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(math.random(1, 2000), math.random(1, 2000), math.random(1, 2000)) * 24679
	end
	
end)

Client.CharacterAdded:Connect(function(c)
	Character = c
end)
