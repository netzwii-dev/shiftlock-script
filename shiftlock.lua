--[[ 
ShiftLock Script (No Camera Offset, Mobile Drag Hold 0.5s, Modern Icon)
Base: Heveladizaar93847
Fixes/adjustments by: nyhito]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local HOLD_TO_DRAG_TIME = 0.5

--// GUI
local ShiftLockGui = Instance.new("ScreenGui")
ShiftLockGui.Name = "FinalShiftlock"
ShiftLockGui.ResetOnSpawn = false
ShiftLockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ShiftLockGui.Parent = PlayerGui

local LockButton = Instance.new("ImageButton")
LockButton.Name = "LockButton"
LockButton.Parent = ShiftLockGui
LockButton.AnchorPoint = Vector2.new(0.5, 0.5)
LockButton.Position = UDim2.new(0.85, 10, 0.5, 12)
LockButton.Size = UDim2.new(0.075, -17, 0.075, -17)
LockButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LockButton.BackgroundTransparency = 0.18
LockButton.BorderSizePixel = 0
LockButton.AutoButtonColor = false
LockButton.Image = ""
LockButton.Active = true
LockButton.Selectable = false
LockButton.ZIndex = 20
LockButton:SetAttribute("LastDragTime", 0)

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(1, 0)
LockCorner.Parent = LockButton

local UIAspect = Instance.new("UIAspectRatioConstraint")
UIAspect.AspectRatio = 1
UIAspect.AspectType = Enum.AspectType.ScaleWithParentSize
UIAspect.Parent = LockButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Parent = LockButton
ButtonStroke.Color = Color3.fromRGB(150, 150, 150)
ButtonStroke.Thickness = 2
ButtonStroke.Transparency = 0.08

--// Modern icon container
local IconHolder = Instance.new("Frame")
IconHolder.Name = "ModernIcon"
IconHolder.Parent = LockButton
IconHolder.AnchorPoint = Vector2.new(0.5, 0.5)
IconHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
IconHolder.Size = UDim2.new(0.62, 0, 0.62, 0)
IconHolder.BackgroundTransparency = 1
IconHolder.ZIndex = 21

local IconAspect = Instance.new("UIAspectRatioConstraint")
IconAspect.AspectRatio = 1
IconAspect.Parent = IconHolder

-- Outer ring
local Ring = Instance.new("Frame")
Ring.Name = "Ring"
Ring.Parent = IconHolder
Ring.AnchorPoint = Vector2.new(0.5, 0.5)
Ring.Position = UDim2.new(0.5, 0, 0.5, 0)
Ring.Size = UDim2.new(1, 0, 1, 0)
Ring.BackgroundTransparency = 1
Ring.ZIndex = 21

local RingStroke = Instance.new("UIStroke")
RingStroke.Parent = Ring
RingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RingStroke.Thickness = 4
RingStroke.Color = Color3.fromRGB(150, 150, 150)

local RingCorner = Instance.new("UICorner")
RingCorner.CornerRadius = UDim.new(1, 0)
RingCorner.Parent = Ring

local function makeTick(name, pos, size)
	local tick = Instance.new("Frame")
	tick.Name = name
	tick.Parent = IconHolder
	tick.AnchorPoint = Vector2.new(0.5, 0.5)
	tick.Position = pos
	tick.Size = size
	tick.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	tick.BorderSizePixel = 0
	tick.ZIndex = 22

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = tick

	return tick
end

local TickTop = makeTick("TickTop", UDim2.new(0.5, 0, 0.08, 0), UDim2.new(0.14, 0, 0.06, 0))
local TickBottom = makeTick("TickBottom", UDim2.new(0.5, 0, 0.92, 0), UDim2.new(0.14, 0, 0.06, 0))
local TickLeft = makeTick("TickLeft", UDim2.new(0.08, 0, 0.5, 0), UDim2.new(0.06, 0, 0.14, 0))
local TickRight = makeTick("TickRight", UDim2.new(0.92, 0, 0.5, 0), UDim2.new(0.06, 0, 0.14, 0))

-- Lock body
local LockBody = Instance.new("Frame")
LockBody.Name = "LockBody"
LockBody.Parent = IconHolder
LockBody.AnchorPoint = Vector2.new(0.5, 0.5)
LockBody.Position = UDim2.new(0.5, 0, 0.60, 0)
LockBody.Size = UDim2.new(0.42, 0, 0.30, 0)
LockBody.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
LockBody.BorderSizePixel = 0
LockBody.ZIndex = 23

local LockBodyCorner = Instance.new("UICorner")
LockBodyCorner.CornerRadius = UDim.new(0.08, 0)
LockBodyCorner.Parent = LockBody

local LockBodyInner = Instance.new("Frame")
LockBodyInner.Name = "Inner"
LockBodyInner.Parent = LockBody
LockBodyInner.AnchorPoint = Vector2.new(0.5, 0.5)
LockBodyInner.Position = UDim2.new(0.5, 0, 0.5, 0)
LockBodyInner.Size = UDim2.new(0.76, 0, 0.58, 0)
LockBodyInner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LockBodyInner.BorderSizePixel = 0
LockBodyInner.ZIndex = 24

local LockBodyInnerCorner = Instance.new("UICorner")
LockBodyInnerCorner.CornerRadius = UDim.new(0.05, 0)
LockBodyInnerCorner.Parent = LockBodyInner

-- Lock shackle
local ShackleOuter = Instance.new("Frame")
ShackleOuter.Name = "ShackleOuter"
ShackleOuter.Parent = IconHolder
ShackleOuter.AnchorPoint = Vector2.new(0.5, 0.5)
ShackleOuter.Position = UDim2.new(0.5, 0, 0.38, 0)
ShackleOuter.Size = UDim2.new(0.28, 0, 0.26, 0)
ShackleOuter.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
ShackleOuter.BorderSizePixel = 0
ShackleOuter.ZIndex = 23

local ShackleOuterCorner = Instance.new("UICorner")
ShackleOuterCorner.CornerRadius = UDim.new(1, 0)
ShackleOuterCorner.Parent = ShackleOuter

local ShackleCut = Instance.new("Frame")
ShackleCut.Name = "ShackleCut"
ShackleCut.Parent = ShackleOuter
ShackleCut.AnchorPoint = Vector2.new(0.5, 1)
ShackleCut.Position = UDim2.new(0.5, 0, 1, 1)
ShackleCut.Size = UDim2.new(0.70, 0, 0.62, 0)
ShackleCut.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ShackleCut.BorderSizePixel = 0
ShackleCut.ZIndex = 24

local function setIconState(enabled)
	local iconColor = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
	local strokeColor = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)

	RingStroke.Color = strokeColor
	TickTop.BackgroundColor3 = iconColor
	TickBottom.BackgroundColor3 = iconColor
	TickLeft.BackgroundColor3 = iconColor
	TickRight.BackgroundColor3 = iconColor
	LockBody.BackgroundColor3 = iconColor
	ShackleOuter.BackgroundColor3 = iconColor
	ButtonStroke.Color = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
	LockButton.BackgroundTransparency = enabled and 0.10 or 0.18
end

local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "ShiftLockCrosshair"
Crosshair.Parent = ShiftLockGui
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, -29)
Crosshair.Size = UDim2.new(0.04, 0, 0.04, 0)
Crosshair.BackgroundTransparency = 1
Crosshair.Image = "rbxasset://textures/MouseLockedCursor.png"
Crosshair.Visible = false
Crosshair.ZIndex = 10

local CrossAspect = Instance.new("UIAspectRatioConstraint")
CrossAspect.AspectRatio = 1
CrossAspect.Parent = Crosshair

--// Core
local isShiftLockEnabled = false
local userGameSettings = nil

local function enforceOfficialSync()
	if not isShiftLockEnabled then
		RunService:UnbindFromRenderStep("FinalNailSync")
		return
	end

	if not userGameSettings then
		pcall(function()
			userGameSettings = UserSettings():GetService("UserGameSettings")
		end)
	end

	if userGameSettings then
		if userGameSettings.RotationType ~= Enum.RotationType.CameraRelative then
			pcall(function()
				userGameSettings.RotationType = Enum.RotationType.CameraRelative
			end)
		end
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

local function ToggleShiftLock(enabled)
	isShiftLockEnabled = enabled
	Crosshair.Visible = enabled
	setIconState(enabled)

	task.spawn(function()
		pcall(function()
			if HapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1) or UserInputService.TouchEnabled then
				HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0.35)
				task.wait(0.05)
				HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
			end
		end)
	end)

	RunService:UnbindFromRenderStep("FinalNailSync")

	if enabled then
		RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
	else
		if userGameSettings then
			pcall(function()
				userGameSettings.RotationType = Enum.RotationType.MovementRelative
			end)
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

--// Character sync
LocalPlayer.CharacterAdded:Connect(function()
	RunService:UnbindFromRenderStep("FinalNailSync")
	RunService.RenderStepped:Wait()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	if isShiftLockEnabled then
		RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
	end
end)

--// Reliable tap/drag logic (same feel as Wallhop hold-drag)
local activeInput = nil
local dragStart = nil
local startPos = nil
local holdSatisfied = false
local holdCanceled = false
local holdId = 0
local dragging = false

local function canUseTap(obj)
	local lastDragTime = obj:GetAttribute("LastDragTime")
	if typeof(lastDragTime) == "number" then
		return (tick() - lastDragTime) > 0.12
	end
	return true
end

LockButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		activeInput = input
		dragStart = input.Position
		startPos = LockButton.Position
		holdSatisfied = false
		holdCanceled = false
		dragging = false
		holdId += 1

		local myHoldId = holdId

		task.delay(HOLD_TO_DRAG_TIME, function()
			if activeInput == input and not holdCanceled and holdId == myHoldId then
				holdSatisfied = true
				LockButton.BackgroundTransparency = 0.45
				LockButton:SetAttribute("LastDragTime", tick())
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input ~= activeInput then
		return
	end

	if not dragStart or not startPos then
		return
	end

	local delta = input.Position - dragStart

	if not holdSatisfied then
		if delta.Magnitude >= 8 then
			holdCanceled = true
		end
		return
	end

	dragging = true

	if delta.Magnitude >= 1 then
		LockButton:SetAttribute("LastDragTime", tick())
	end

	LockButton.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if input ~= activeInput then
		return
	end

	local didDrag = dragging

	LockButton.BackgroundTransparency = isShiftLockEnabled and 0.10 or 0.18

	activeInput = nil
	dragStart = nil
	startPos = nil
	holdSatisfied = false
	holdCanceled = false
	dragging = false
	holdId += 1

	if not didDrag and canUseTap(LockButton) then
		ToggleShiftLock(not isShiftLockEnabled)
	end
end)

LockButton.Activated:Connect(function()
	if activeInput == nil and canUseTap(LockButton) then
		ToggleShiftLock(not isShiftLockEnabled)
	end
end)

setIconState(false)

print("ShiftLock Script Loaded successfully ✅")
