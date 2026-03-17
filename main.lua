local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 設定
local Settings = {
Aimbot = false,
SilentAim = false,
LockHead = false,

WallCheck = true,
KillCheck = true,

Fly = false,
FlySpeed = 80,

Noclip = false,

ESP = false,

FOV = 150
}

-- FOV 圓圈
local Circle = Drawing.new("Circle")
Circle.Visible = false
Circle.Radius = Settings.FOV
Circle.Filled = false
Circle.Thickness = 2
Circle.Transparency = 1

RunService.RenderStepped:Connect(function()

Circle.Position = Vector2.new(
Camera.ViewportSize.X/2,
Camera.ViewportSize.Y/2
)

Circle.Visible = Settings.Aimbot
Circle.Radius = Settings.FOV

end)

-- Wall Check
function WallCheck(part)

local origin = Camera.CFrame.Position
local ray = Ray.new(origin,(part.Position-origin).Unit*500)

local hit = workspace:FindPartOnRay(ray,LP.Character)

return hit == part

end

-- 找最近敵人
function GetTarget()

local closest = nil
local shortest = Settings.FOV

for _,plr in pairs(Players:GetPlayers()) do

if plr ~= LP and plr.Character then

local head = plr.Character:FindFirstChild("Head")
local hum = plr.Character:FindFirstChild("Humanoid")

if head and hum then

if Settings.KillCheck and hum.Health <= 0 then
continue
end

local pos,vis = Camera:WorldToViewportPoint(head.Position)

if vis then

local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude

if dist < shortest then

if Settings.WallCheck then
if not WallCheck(head) then
continue
end
end

shortest = dist
closest = head

end
end
end
end
end

return closest
end

-- Aimbot
RunService.RenderStepped:Connect(function()

if not Settings.Aimbot then return end

local target = GetTarget()

if target and Settings.LockHead then

Camera.CFrame = CFrame.new(Camera.CFrame.Position,target.Position)

end

end)

-- ESP
local ESPTable = {}

function CreateESP(player)

local box = Drawing.new("Square")
box.Thickness = 2
box.Filled = false
box.Visible = false

ESPTable[player] = box

end

for _,p in pairs(Players:GetPlayers()) do
if p ~= LP then
CreateESP(p)
end
end

Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()

for player,box in pairs(ESPTable) do

if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

local root = player.Character.HumanoidRootPart
local pos,vis = Camera:WorldToViewportPoint(root.Position)

if vis and Settings.ESP then

box.Visible = true
box.Size = Vector2.new(40,60)
box.Position = Vector2.new(pos.X-20,pos.Y-30)

else

box.Visible = false

end

end

end

end)

-- Fly
local BV

RunService.RenderStepped:Connect(function()

if Settings.Fly and LP.Character then

local root = LP.Character:FindFirstChild("HumanoidRootPart")

if root then

if not BV then
BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(999999,999999,999999)
BV.Parent = root
end

local dir = Vector3.new()

if UIS:IsKeyDown(Enum.KeyCode.W) then
dir += Camera.CFrame.LookVector
end

if UIS:IsKeyDown(Enum.KeyCode.S) then
dir -= Camera.CFrame.LookVector
end

if UIS:IsKeyDown(Enum.KeyCode.A) then
dir -= Camera.CFrame.RightVector
end

if UIS:IsKeyDown(Enum.KeyCode.D) then
dir += Camera.CFrame.RightVector
end

BV.Velocity = dir * Settings.FlySpeed

end

else

if BV then
BV:Destroy()
BV = nil
end

end

end)

-- Noclip (超穩定版)

local SafeHeight = 10

RunService.Stepped:Connect(function()

if Settings and Settings.Noclip and LP.Character then

local char = LP.Character
local root = char:FindFirstChild("HumanoidRootPart")

-- 穿牆
for _,v in pairs(char:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide = false
end
end

-- 防掉出地圖
if root then

-- 如果掉到虛空
if root.Position.Y < -20 then
root.CFrame = CFrame.new(root.Position.X, SafeHeight, root.Position.Z)
end

-- 向下偵測地板
local rayOrigin = root.Position
local rayDir = Vector3.new(0,-200,0)

local result = workspace:Raycast(rayOrigin, rayDir)

if not result then
root.CFrame = CFrame.new(root.Position.X, SafeHeight, root.Position.Z)
end

end

end

end)

-- UI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,220,0,300)
frame.Position = UDim2.new(0,20,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = gui

frame.Active = true
frame.Draggable = true

function Button(text,callback)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1,0,0,30)
btn.Text = text
btn.Parent = frame

btn.MouseButton1Click:Connect(callback)

end

Button("Aimbot",function()
Settings.Aimbot = not Settings.Aimbot
end)

Button("Silent Aim",function()
Settings.SilentAim = not Settings.SilentAim
end)

Button("ESP",function()
Settings.ESP = not Settings.ESP
end)

Button("Fly",function()
Settings.Fly = not Settings.Fly
end)

Button("Noclip",function()
Settings.Noclip = not Settings.Noclip
end)

Button("Wall Check",function()
Settings.WallCheck = not Settings.WallCheck
end)

Button("Kill Check",function()
Settings.KillCheck = not Settings.KillCheck
end)

-- K 隱藏
UIS.InputBegan:Connect(function(input,gp)

if gp then return end

if input.KeyCode == Enum.KeyCode.K then

frame.Visible = not frame.Visible

end

end)
