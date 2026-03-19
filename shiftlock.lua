--[[ ShiftLock Script (No Camera Offset, Fixed Button)
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
-- Posicionado 20px à direita e 5px acima da posição anterior
LockButton.Position = UDim2.new(0.85, 50, 0.5, -30)
LockButton.Size = UDim2.new(0.075, -17, 0.075, -17) -- Tamanho reduzido
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

    -- Apenas bloqueia o mouse, sem mover a câmera
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

-- --- Tap Only ---
LockButton.MouseButton1Click:Connect(function()
    ToggleShiftLock(not isShiftLockEnabled)
end)
