-- shiftlock teste 2
local TEST_NUMBER = 2

local success, Players = pcall(function() return game:GetService("Players") end)
if not success then return end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local success2, UserInputService = pcall(function() return game:GetService("UserInputService") end)
if not success2 then return end

local success3, RunService = pcall(function() return game:GetService("RunService") end)
if not success3 then return end

local success4, HapticService = pcall(function() return game:GetService("HapticService") end)
if not success4 then HapticService = nil end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local ShiftLockGui = Instance.new("ScreenGui")
ShiftLockGui.Name = "FinalShiftlock_Teste"..TEST_NUMBER
ShiftLockGui.ResetOnSpawn = false
ShiftLockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ShiftLockGui.Parent = PlayerGui

-- Botão ShiftLock
local LockButton = Instance.new("ImageButton")
LockButton.Name = "LockButton"
LockButton.Parent = ShiftLockGui
LockButton.AnchorPoint = Vector2.new(0,0)
LockButton.Size = UDim2.new(0, 60, 0, 60) -- tamanho oficial
LockButton.BackgroundTransparency = 1
LockButton.BorderSizePixel = 0
LockButton.AutoButtonColor = true
LockButton.Image = "rbxasset://textures/ui/mouseLock_off.png"

local UIAspect = Instance.new("UIAspectRatioConstraint")
UIAspect.AspectRatio = 1
UIAspect.Parent = LockButton

-- Posicionar botão no canto direito, central vertical
local function updateButtonPosition()
    local screenSize = PlayerGui.AbsoluteSize
    local x = screenSize.X - LockButton.AbsoluteSize.X - 10 -- margem direita
    local y = (screenSize.Y - LockButton.AbsoluteSize.Y)/2      -- central vertical
    LockButton.Position = UDim2.new(0, x, 0, y)
end
updateButtonPosition()
PlayerGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateButtonPosition)

-- Crosshair
local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "ShiftLockCrosshair"
Crosshair.Parent = ShiftLockGui
Crosshair.AnchorPoint = Vector2.new(0.5,0.5)
Crosshair.Position = UDim2.new(0.5,0,0.5,0)
Crosshair.Size = UDim2.new(0,30,0,30)
Crosshair.BackgroundTransparency = 1
Crosshair.Image = "rbxasset://textures/MouseLockedCursor.png"
Crosshair.Visible = false
Crosshair.ZIndex = 10

local CrossAspect = Instance.new("UIAspectRatioConstraint")
CrossAspect.AspectRatio = 1
CrossAspect.Parent = Crosshair

-- Core
local isShiftLockEnabled = false
local userGameSettings = nil

local function enforceOfficialSync()
    if not isShiftLockEnabled then
        RunService:UnbindFromRenderStep("FinalNailSync")
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not userGameSettings then
        pcall(function() userGameSettings = UserSettings():GetService("UserGameSettings") end)
    end
    if userGameSettings then
        pcall(function() userGameSettings.RotationType = Enum.RotationType.CameraRelative end)
    end
    -- MOBILE: sem deslocamento
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

local function ToggleShiftLock(enabled)
    isShiftLockEnabled = enabled
    Crosshair.Visible = enabled
    if HapticService then
        task.spawn(function()
            pcall(function()
                HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small,0.35)
                task.wait(0.05)
                HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small,0)
            end)
        end)
    end
    RunService:UnbindFromRenderStep("FinalNailSync")
    if enabled then
        LockButton.Image = "rbxasset://textures/ui/mouseLock_on.png"
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value+1, enforceOfficialSync)
    else
        LockButton.Image = "rbxasset://textures/ui/mouseLock_off.png"
        if userGameSettings then
            pcall(function() userGameSettings.RotationType = Enum.RotationType.MovementRelative end)
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

LockButton.MouseButton1Click:Connect(function()
    ToggleShiftLock(not isShiftLockEnabled)
end)

LocalPlayer.CharacterAdded:Connect(function()
    RunService:UnbindFromRenderStep("FinalNailSync")
    RunService.RenderStepped:Wait()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    if isShiftLockEnabled then
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value+1, enforceOfficialSync)
    end
end)
