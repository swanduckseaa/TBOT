-- Triggerbot toggle switch for mobile-friendly use.
-- If Onion is available, it creates a switch in the Onion menu.
-- Otherwise it creates a simple on-screen toggle button.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

local Onion = rawget(_G, "Onion") or _G.Onion or {}
local state = {
	enabled = false,
	mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
	crosshair = {
		size = 12,
		thickness = 2,
		gap = 8,
		color = Color3.fromRGB(255, 255, 255),
		visible = true,
		dot = true,
		dotSize = 3,
	},
}

local function setEnabled(value)
	state.enabled = value == true
	print((state.enabled and "Triggerbot ON" or "Triggerbot OFF"))
end

local function toggleTriggerbot()
	setEnabled(not state.enabled)
end

local function isHumanoidTarget(instance)
	if not instance then
		return false
	end

	local model = instance:FindFirstAncestorOfClass("Model")
	if not model or model == player.Character then
		return false
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end

	return humanoid.Health > 0
end

local function mouseTargetIsEnemy()
	if not mouse or not mouse.Target then
		return false
	end

	return isHumanoidTarget(mouse.Target)
end

local function touchTargetIsEnemy()
	if not camera then
		return false
	end

	local cursor = UserInputService:GetMouseLocation()
	local ray = camera:ScreenPointToRay(cursor.X, cursor.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }

	local hit = Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
	if not hit or not hit.Instance then
		return false
	end

	return isHumanoidTarget(hit.Instance)
end

local function targetDetected()
	if state.mobile then
		return touchTargetIsEnemy()
	end

	return mouseTargetIsEnemy()
end

local function applyOnionToggle()
	if type(Onion.CreateToggle) == "function" then
		Onion:CreateToggle("Triggerbot", function(value)
			setEnabled(value)
		end)
		return true
	end

	if type(Onion.AddToggle) == "function" then
		Onion:AddToggle("Triggerbot", function(value)
			setEnabled(value)
		end)
		return true
	end

	if type(Onion.CreateSwitch) == "function" then
		Onion:CreateSwitch("Triggerbot", function(value)
			setEnabled(value)
		end)
		return true
	end

	if type(Onion.BindKey) == "function" then
		Onion:BindKey(Enum.KeyCode.E, toggleTriggerbot)
		return true
	end

	return false
end

local function buildCrosshair()
	local gui = Instance.new("ScreenGui")
	gui.Name = "TriggerbotCrosshairGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player:WaitForChild("PlayerGui")

	local crosshairLayer = Instance.new("Frame")
	crosshairLayer.Name = "CrosshairLayer"
	crosshairLayer.AnchorPoint = Vector2.new(0.5, 0.5)
	crosshairLayer.Position = UDim2.new(0.5, 0, 0.5, 0)
	crosshairLayer.Size = UDim2.new(0, 100, 0, 100)
	crosshairLayer.BackgroundTransparency = 1
	crosshairLayer.BorderSizePixel = 0
	crosshairLayer.Parent = gui

	local makeLine = function(name, dirX, dirY, length)
		local line = Instance.new("Frame")
		line.Name = name
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.BackgroundColor3 = state.crosshair.color
		line.BorderSizePixel = 0
		line.Size = UDim2.new(0, state.crosshair.thickness, 0, length)
		line.Position = UDim2.new(0.5 + dirX, 0, 0.5 + dirY, 0)
		line.Parent = crosshairLayer
		return line
	end

	local left = makeLine("Left", -0.5, 0, state.crosshair.size)
	left.Position = UDim2.new(0.5, -(state.crosshair.size + state.crosshair.gap + state.crosshair.thickness), 0.5, 0)
	left.Size = UDim2.new(0, state.crosshair.thickness, 0, state.crosshair.size)

	local right = makeLine("Right", 0.5, 0, state.crosshair.size)
	right.Position = UDim2.new(0.5, state.crosshair.size + state.crosshair.gap + state.crosshair.thickness, 0.5, 0)
	right.Size = UDim2.new(0, state.crosshair.thickness, 0, state.crosshair.size)

	local up = makeLine("Up", 0, -0.5, state.crosshair.size)
	up.Position = UDim2.new(0.5, 0, 0.5, -(state.crosshair.size + state.crosshair.gap + state.crosshair.thickness))
	up.Size = UDim2.new(0, state.crosshair.size, 0, state.crosshair.thickness)

	local down = makeLine("Down", 0, 0.5, state.crosshair.size)
	down.Position = UDim2.new(0.5, 0, 0.5, state.crosshair.size + state.crosshair.gap + state.crosshair.thickness)
	down.Size = UDim2.new(0, state.crosshair.size, 0, state.crosshair.thickness)

	if state.crosshair.dot then
		local dot = Instance.new("Frame")
		dot.Name = "Dot"
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = UDim2.new(0.5, 0, 0.5, 0)
		dot.Size = UDim2.new(0, state.crosshair.dotSize, 0, state.crosshair.dotSize)
		dot.BackgroundColor3 = state.crosshair.color
		dot.BorderSizePixel = 0
		dot.Parent = crosshairLayer
	end

	return gui
end

local function updateCrosshairVisibility(gui)
	if not gui then
		return
	end

	local layer = gui:FindFirstChild("CrosshairLayer", true)
	if layer then
		layer.Visible = state.crosshair.visible
	end
end

local function buildMobileToggle()
	local gui = Instance.new("ScreenGui")
	gui.Name = "TriggerbotSwitchGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 150, 0, 48)
	frame.Position = UDim2.new(1, -170, 1, -70)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.new(1, -12, 1, -12)
	switch.Position = UDim2.new(0, 6, 0, 6)
	switch.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	switch.BorderSizePixel = 0
	switch.Text = "OFF"
	switch.TextScaled = true
	switch.Font = Enum.Font.GothamBold
	switch.TextColor3 = Color3.fromRGB(255, 255, 255)
	switch.Parent = frame

	switch.MouseButton1Click:Connect(function()
		toggleTriggerbot()
		switch.Text = state.enabled and "ON" or "OFF"
		switch.BackgroundColor3 = state.enabled and Color3.fromRGB(55, 180, 90) or Color3.fromRGB(70, 70, 70)
	end)

	return gui
end

local function setupToggleUI()
	if applyOnionToggle() then
		return
	end

	buildMobileToggle()
	buildCrosshair()
end

setupToggleUI()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.E then
		toggleTriggerbot()
	end
end)

RunService.RenderStepped:Connect(function()
	if not state.enabled then
		return
	end

	if targetDetected() then
		print("Triggerbot active: target detected")
	end
end)
