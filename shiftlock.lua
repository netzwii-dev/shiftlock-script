local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService") 

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- --- GUI FIXED ---
local ShiftLockGui = Instance.new("ScreenGui")
ShiftLockGui.Name = "FinalShiftlock"
ShiftLockGui.ResetOnSpawn = false
ShiftLockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ShiftLockGui.IgnoreGuiInset = true
ShiftLockGui.Parent = PlayerGui

local LockButton = Instance.new("ImageButton")
LockButton.Name = "LockButton"
LockButton.Parent = ShiftLockGui
LockButton.AnchorPoint = Vector2.new(0,0)

-- Base Roblox mobile padrão
local baseX = 800
local baseY = 400

-- Aplicando deslocamento: +15px direita, -60px para cima
LockButton.Position = UDim2.new(0, baseX + 15, 0, baseY - 60)
LockButton.Size = UDim2.new(0, 80, 0, 80) -- menor botão

LockButton.BackgroundTransparency = 1
LockButton.BorderSizePixel = 0
LockButton.AutoButtonColor = true
LockButton.Image = "rbxasset://textures/ui/mouseLock_off.png"

local UIAspect = Instance.new("UIAspectRatioConstraint")
UIAspect.AspectRatio = 1
UIAspect.Parent = LockButton

-- Crosshair menor
local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "ShiftLockCrosshair"
Crosshair.Parent = ShiftLockGui
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0) -- meio da tela
Crosshair.Size = UDim2.new(0, 30, 0, 30) -- menor
Crosshair.BackgroundTransparency = 1
Crosshair.Image = "rbxasset://textures/MouseLockedCursor.png"
Crosshair.Visible = false
Crosshair.ZIndex = 10

local CrossAspect = Instance.new("UIAspectRatioConstraint")
CrossAspect.AspectRatio = 1
CrossAspect.Parent = Crosshair

-- --- Core Variables ---
local isShiftLockEnabled = false
local userGameSettings = nil

-- --- Core Sync Loop ---
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
        pcall(function() userGameSettings.RotationType = Enum.RotationType.CameraRelative end)
    end

    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    -- NÃO HÁ DESLOCAMENTO
end

-- --- Toggle ShiftLock ---
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
        LockButton.Image = "rbxasset://textures/ui/mouseLock_on.png"
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
    else
        LockButton.Image = "rbxasset://textures/ui/mouseLock_off.png"
        if userGameSettings then
            pcall(function() userGameSettings.RotationType = Enum.RotationType.MovementRelative end)
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

-- CLICK SIMPLES SEM DRAG
LockButton.MouseButton1Click:Connect(function()
    ToggleShiftLock(not isShiftLockEnabled)
end)

-- RESET AO RESPAWN
LocalPlayer.CharacterAdded:Connect(function()
    RunService:UnbindFromRenderStep("FinalNailSync")
    RunService.RenderStepped:Wait()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    
    if isShiftLockEnabled then
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
    end
end)
