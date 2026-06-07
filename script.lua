local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SpecialIncome = Workspace:WaitForChild("Tycoon9"):WaitForChild("Remotes"):WaitForChild("SpecialIncome")
local ClickFruitRemote = ReplicatedStorage:WaitForChild("Core"):WaitForChild("RemoteSignal"):WaitForChild("ClickFruitService.Clicked")

local TreesFolder = Workspace:WaitForChild("Tycoon9"):WaitForChild("Constant"):WaitForChild("Trees")

local AutoFruitRunning = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FruitAutoGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 50)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -10, 1, -10)
button.Position = UDim2.new(0, 5, 0, 5)
button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
button.Text = "Auto Fruit: OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.BorderSizePixel = 0
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = button

local dragging, dragStart, startPos
button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

button.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

button.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local function FireFruitRemotes(fruitPosition)
	local timestamp = tick()
	firesignal(SpecialIncome.OnClientEvent, "ClickFruit", timestamp)
	firesignal(ClickFruitRemote.OnClientEvent, timestamp, fruitPosition, false)
end

local function AutoFruitLoop()
	while AutoFruitRunning do
		for _, tree in ipairs(TreesFolder:GetChildren()) do
			if not AutoFruitRunning then break end
			local fruit = tree:FindFirstChild("Fruit")
			if fruit then
				local pos = Vector3.zero
				if fruit:IsA("BasePart") then
					pos = fruit.Position
				elseif fruit:IsA("Model") then
					if fruit.PrimaryPart then
						pos = fruit.PrimaryPart.Position
					else
						for _, desc in ipairs(fruit:GetDescendants()) do
							if desc:IsA("BasePart") then
								pos = desc.Position
								break
							end
						end
					end
				end
				if pos ~= Vector3.zero then
					FireFruitRemotes(pos)
				end
			end
		end
		task.wait(0.05)
	end
end

button.MouseButton1Click:Connect(function()
	AutoFruitRunning = not AutoFruitRunning

	if AutoFruitRunning then
		button.Text = "Auto Fruit: ON"
		button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 50)}):Play()
		task.spawn(AutoFruitLoop)
	else
		button.Text = "Auto Fruit: OFF"
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
	end
end)
