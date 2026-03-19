--[[ ShiftLock Script (No Camera Offset, Movable Button)
Creator: Heveladizaar93847
Testing & Fixing: NPC_PlayersNoob
Uploader & Update: NPC_PlayersNoob
Note: Camera will not move when ShiftLock is activated.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService") 

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- --- UI ---
local ShiftLockGui = Instance.new("ScreenGui")
ShiftLockGui.Name = "FinalShiftlock"
ShiftLockGui.ResetOnSpawn = false
ShiftLockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ShiftLockGui.Parent = PlayerGui

local LockButton = Instance.new("ImageButton")
LockButton.Name = "LockButton"
LockButton.Parent = ShiftLockGui
LockButton.AnchorPoint = Vector2.new(0.5, 0.5)
LockButton.Position = UDim2.new(0.85, 10, 0.5, 12) -- posição inicial
LockButton.Size = UDim2.new(0.075, -17, 0.075, -17)
LockButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
LockButton.BackgroundTransparency = 0.2
LockButton.BorderSizePixel = 0
LockButton.AutoButtonColor = true
LockButton.Image = ""

local UIAspect = Instance.new("UIAspectRatioConstraint")
UIAspect.AspectRatio = 1
UIAspect.AspectType = Enum.AspectType.ScaleWithParentSize
UIAspect.Parent = LockButton

local ButtonIcon = Instance.new("ImageLabel")
ButtonIcon.Name = "btnIcon"
ButtonIcon.Parent = LockButton
ButtonIcon.BackgroundTransparency = 1
ButtonIcon.Position = UDim2.new(0.15,0,0.15,0)
ButtonIcon.Size = UDim2.new(0.67,0,0.67,0)
ButtonIcon.Image = "rbxasset://textures/ui/ShiftLockIcon.png"
ButtonIcon.ScaleType = Enum.ScaleType.Fit

Instance.new("UICorner", LockButton).CornerRadius = UDim.new(1,0)
local ButtonStroke = Instance.new("UIStroke", LockButton)
ButtonStroke.Color = Color3.fromRGB(255,0,100)
ButtonStroke.Thickness = 2

local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "ShiftLockCrosshair"
Crosshair.Parent = ShiftLockGui
Crosshair.AnchorPoint = Vector2.new(0.5,0.5)
Crosshair.Position = UDim2.new(0.5,0,0.5,-29)
Crosshair.Size = UDim2.new(0.04,0,0.04,0)
Crosshair.BackgroundTransparency = 1
Crosshair.Image = "rbxasset://textures/MouseLockedCursor.png"
Crosshair.Visible = false
Crosshair.ZIndex = 10

local CrossAspect = Instance.new("UIAspectRatioConstraint")
CrossAspect.AspectRatio = 1
CrossAspect.Parent = Crosshair

-- --- Core ---
local isShiftLockEnabled = false
local userGameSettings = nil

local function enforceOfficialSync()
    if not isShiftLockEnabled then
        RunService:UnbindFromRenderStep("FinalNailSync")
        return
    end

    if not userGameSettings then
        pcall(function() userGameSettings = UserSettings():GetService("UserGameSettings") end)
    end
    if userGameSettings then
        if userGameSettings.RotationType ~= Enum.RotationType.CameraRelative then
            pcall(function() userGameSettings.RotationType = Enum.RotationType.CameraRelative end)
        end
    end

    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

local function ToggleShiftLock(enabled)
    isShiftLockEnabled = enabled
    Crosshair.Visible = enabled

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
            pcall(function() userGameSettings.RotationType = Enum.RotationType.MovementRelative end)
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

-- --- Events ---
LocalPlayer.CharacterAdded:Connect(function()
    RunService:UnbindFromRenderStep("FinalNailSync")
    RunService.RenderStepped:Wait()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    if isShiftLockEnabled then
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
    end
end)

-- --- Movable Button Logic ---
local dragging = false
local canDrag = false
local pressStartTime = 0
local dragStart, startPos

local function isTouchInsideButton(position)
    local btnPos = LockButton.AbsolutePosition
    local btnSize = LockButton.AbsoluteSize
    return position.X >= btnPos.X and position.X <= btnPos.X + btnSize.X and
           position.Y >= btnPos.Y and position.Y <= btnPos.Y + btnSize.Y
end

LockButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isTouchInsideButton(input.Position) then
            pressStartTime = tick()
            canDrag = false
            dragging = false
            dragStart = input.Position
            startPos = LockButton.Position

            task.delay(0.30, function()
                if (tick() - pressStartTime >= 0.30) and isTouchInsideButton(input.Position) then
                    if input.UserInputState ~= Enum.UserInputState.End then
                        canDrag = true
                        LockButton.BackgroundTransparency = 0.5
                    end
                end
            end)
        else
            pressStartTime = 0
        end
    end
end)

LockButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        local inside = isTouchInsideButton(input.Position)
        if not inside and not dragging then
            pressStartTime = 0
        end

        if canDrag then
            dragging = true
            local delta = input.Position - dragStart
            LockButton.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pressDuration = tick() - pressStartTime
        local insideAtEnd = isTouchInsideButton(input.Position)

        LockButton.BackgroundTransparency = 0.2

        if pressStartTime > 0 and pressDuration < 0.30 and not dragging and insideAtEnd then
            ToggleShiftLock(not isShiftLockEnabled)
        end

        dragging = false
        canDrag = false
        pressStartTime = 0
    end
end)
