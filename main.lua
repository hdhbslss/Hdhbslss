-- Icey Hub Final

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- 設定
local Settings = {
Fly = false,
ESP = false,
Aimbot = false,
Noclip = false
}

local AimbotMode = "Lock"
local FOV = 120

-- GUI
local gui = Instance.new("ScreenGui",game.CoreGui)

local frame = Instance.new("Frame",gui)
frame.Size = UDim2.new(0,220,0,300)
frame.Position = UDim2.new(0,100,0,100)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel",frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "Icey Hub"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- 手機隱藏
local hideBtn = Instance.new("TextButton",frame)
hideBtn.Size = UDim2.new(0,30,0,30)
hideBtn.Position = UDim2.new(1,-35,0,5)
hideBtn.Text = "-"

local openBtn = Instance.new("TextButton",gui)
openBtn.Size = UDim2.new(0,120,0,35)
openBtn.Position = UDim2.new(0.5,-60,0,10)
openBtn.Text = "Open Icey Hub"
openBtn.Visible = false

hideBtn.MouseButton1Click:Connect(function()
frame.Visible = false
openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
frame.Visible = true
openBtn.Visible = false
end)

-- K 隱藏
UIS.InputBegan:Connect(function(input,gp)
if gp then return end
if input.KeyCode == Enum.KeyCode.K then
frame.Visible = not frame.Visible
end
end)

-- 拖動
local dragging
local dragStart
local startPos

title.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
dragStart = input.Position
startPos = frame.Position
end
end)

UIS.InputChanged:Connect(function(input)
if dragging then
local delta = input.Position - dragStart
frame.Position = UDim2.new(
startPos.X.Scale,
startPos.X.Offset + delta.X,
startPos.Y.Scale,
startPos.Y.Offset + delta.Y
)
end
end)

UIS.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
end
end)

-- 按鈕
local function Button(text,y,callback)

local b = Instance.new("TextButton",frame)
b.Size = UDim2.new(1,-20,0,30)
b.Position = UDim2.new(0,10,0,y)
b.Text = text
b.Parent = frame

b.MouseButton1Click:Connect(callback)

end

-- Fly
local flyVel

Button("Fly",50,function()

Settings.Fly = not Settings.Fly

if Settings.Fly then
flyVel = Instance.new("BodyVelocity")
flyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
flyVel.Parent = player.Character.HumanoidRootPart
else
if flyVel then flyVel:Destroy() end
end

end)

RunService.RenderStepped:Connect(function()

if Settings.Fly and flyVel then
flyVel.Velocity = camera.CFrame.LookVector * 60
end

end)

-- Noclip
Button("Noclip",90,function()

Settings.Noclip = not Settings.Noclip

end)

RunService.Stepped:Connect(function()

if Settings.Noclip and player.Character then

for _,v in pairs(player.Character:GetDescendants()) do

if v:IsA("BasePart") then

if Settings.Fly then
v.CanCollide = false
else
if v.Name ~= "HumanoidRootPart" then
v.CanCollide = false
end
end

end

end

end

end)

-- ESP
Button("ESP",130,function()

Settings.ESP = not Settings.ESP

for _,plr in pairs(Players:GetPlayers()) do

if plr ~= player and plr.Character then

if Settings.ESP then

local h = Instance.new("Highlight")
h.Name = "IceESP"
h.FillColor = Color3.new(1,0,0)
h.Parent = plr.Character

else

if plr.Character:FindFirstChild("IceESP") then
plr.Character.IceESP:Destroy()
end

end

end

end

end)

-- FOV 圓圈
local circle = Drawing.new("Circle")
circle.Radius = FOV
circle.Thickness = 2
circle.Color = Color3.new(1,1,1)
circle.Filled = false
circle.Visible = true

RunService.RenderStepped:Connect(function()

circle.Position = Vector2.new(mouse.X,mouse.Y)
circle.Radius = FOV

end)

-- Kill Check + Wall Check
local function WallCheck(target)

local origin = camera.CFrame.Position
local direction = (target.Position - origin).Unit * 500

local params = RaycastParams.new()
params.FilterDescendantsInstances = {player.Character}
params.FilterType = Enum.RaycastFilterType.Blacklist

local ray = workspace:Raycast(origin,direction,params)

if ray then
return ray.Instance:IsDescendantOf(target.Parent)
end

return false

end

-- 找最近敵人
local function GetClosest()

local closest
local dist = math.huge

for _,plr in pairs(Players:GetPlayers()) do

if plr ~= player
and plr.Character
and plr.Character:FindFirstChild("Head")
and plr.Character:FindFirstChild("Humanoid")
and plr.Character.Humanoid.Health > 0 then

local pos,vis = camera:WorldToViewportPoint(plr.Character.Head.Position)

if vis then

local diff = (Vector2.new(pos.X,pos.Y) - Vector2.new(mouse.X,mouse.Y)).Magnitude

if diff < FOV and diff < dist and WallCheck(plr.Character.Head) then

dist = diff
closest = plr

end

end

end

end

return closest

end

-- Aimbot
Button("Aimbot",170,function()

Settings.Aimbot = not Settings.Aimbot

end)

Button("Switch Mode",210,function()

if AimbotMode == "Lock" then
AimbotMode = "Silent"
else
AimbotMode = "Lock"
end

end)

Button("FOV +",250,function()
FOV = FOV + 20
end)

Button("FOV -",290,function()
FOV = math.max(40,FOV - 20)
end)

RunService.RenderStepped:Connect(function()

if not Settings.Aimbot then return end

local target = GetClosest()

if target and AimbotMode == "Lock" then

camera.CFrame = CFrame.new(
camera.CFrame.Position,
target.Character.Head.Position
)

end

end)
