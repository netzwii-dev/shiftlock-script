--[[ ShiftLock Script (Finished) 
Creator: Heveladizaar93847
Testing & Fixing: NPC_PlayersNoob
Uploader & Update: NPC_PlayersNoob
Note: Do not break or change those codes.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService") 

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- --- 1. DPI Adaptive GUI System ---
local ShiftLockGui = Instance.new("ScreenGui")
ShiftLockGui.Name = "FinalShiftlock"
ShiftLockGui.ResetOnSpawn = false
ShiftLockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ShiftLockGui.Parent = PlayerGui

local LockButton = Instance.new("ImageButton")
LockButton.Name = "LockButton"
LockButton.Parent = ShiftLockGui
LockButton.AnchorPoint = Vector2.new(0.5, 0.5)
-- Fixed position: 70px right, 10px up
LockButton.Position = UDim2.new(0.85, 30, 0.5, -25)
-- Fixed size, slightly smaller
LockButton.Size = UDim2.new(0.075, -17, 0.075, -17)
LockButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
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
ButtonIcon.Position = UDim2.new(0.15, 0, 0.15, 0)
ButtonIcon.Size = UDim2.new(0.67, 0, 0.67, 0)
-- Official Roblox Shift Lock icon
ButtonIcon.Image = "rbxasset://textures/ui/ShiftLockIcon.png"
ButtonIcon.ScaleType = Enum.ScaleType.Fit
ButtonIcon.ImageColor3 = Color3.fromRGB(255, 0, 100) 

Instance.new("UICorner", LockButton).CornerRadius = UDim.new(1, 0)
local ButtonStroke = Instance.new("UIStroke", LockButton)
ButtonStroke.Color = Color3.fromRGB(255, 0, 100)
ButtonStroke.Thickness = 2

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

-- --- 2. Core Variables ---
local isShiftLockEnabled = false
local userGameSettings = nil
local OFFSET_VAL = 1.75 

-- --- 3. Core Sync Loop ---
local function enforceOfficialSync()
    if not isShiftLockEnabled then 
        RunService:UnbindFromRenderStep("FinalNailSync")
        return 
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    if not hum then return end

    if not userGameSettings then
        pcall(function() userGameSettings = UserSettings():GetService("UserGameSettings") end)
    end
    if userGameSettings then
        if userGameSettings.RotationType ~= Enum.RotationType.CameraRelative then
            pcall(function() userGameSettings.RotationType = Enum.RotationType.CameraRelative end)
        end
    end

    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

    local dist = (cam.Focus.Position - cam.CFrame.Position).Magnitude
    
    if dist > 0.80 then 
        local rawCFrame = cam.CFrame
        cam.CFrame = rawCFrame * CFrame.new(OFFSET_VAL, 0, 0)
        cam.Focus = cam.CFrame * CFrame.new(0, 0, -dist)
    end
end

-- --- 4. Toggle Function ---
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
        ButtonIcon.ImageColor3 = Color3.fromRGB(0, 255, 150) 
        ButtonStroke.Color = Color3.fromRGB(0, 255, 150)
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
    else
        ButtonIcon.ImageColor3 = Color3.fromRGB(255, 0, 100) 
        ButtonStroke.Color = Color3.fromRGB(255, 0, 100)
        
        if userGameSettings then
            pcall(function() userGameSettings.RotationType = Enum.RotationType.MovementRelative end)
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        
        local cam = workspace.CurrentCamera
        local dist = (cam.Focus.Position - cam.CFrame.Position).Magnitude
        if dist > 0.1 then
             cam.CFrame = cam.CFrame * CFrame.new(-OFFSET_VAL, 0, 0)
             cam.Focus = cam.CFrame * CFrame.new(0, 0, -dist)
        end
    end
end

-- --- 5. Event Binding (Modified for Spawn Reset) ---
LocalPlayer.CharacterAdded:Connect(function(char)
    RunService:UnbindFromRenderStep("FinalNailSync")
    RunService.RenderStepped:Wait()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    if isShiftLockEnabled then
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
    end
end)

-- --- 6. Tap Only Logic (Draggable Removed) ---
LockButton.MouseButton1Click:Connect(function()
    ToggleShiftLock(not isShiftLockEnabled)
end)
