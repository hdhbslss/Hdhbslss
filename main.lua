local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 設定
local Settings = {

Fly = false,
FlySpeed = 80,

Noclip = false,

ESP = false,

Aimbot = false,
SilentAim = false,
WallCheck = true,

FOV = 120

}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,240,0,360)
frame.Position = UDim2.new(0.5,-120,0.5,-180)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- 手機按鈕
local mobile = Instance.new("TextButton")
mobile.Size = UDim2.new(0,40,0,40)
mobile.Position = UDim2.new(0.5,-20,0,10)
mobile.Text = "-"
mobile.TextColor3 = Color3.new(1,1,1)
mobile.BackgroundColor3 = Color3.fromRGB(40,40,40)
mobile.Parent = gui

mobile.MouseButton1Click:Connect(function()
frame.Visible = not frame.Visible
frame.Position = UDim2.new(0.5,-120,0,60)
end)

-- 按鈕
local function Button(text,y,callback)

local b = Instance.new("TextButton")
b.Size = UDim2.new(0,220,0,35)
b.Position = UDim2.new(0,10,0,y)
b.BackgroundColor3 = Color3.fromRGB(35,35,35)
b.TextColor3 = Color3.new(1,1,1)
b.Text = text
b.Parent = frame

b.MouseButton1Click:Connect(callback)

end

-- Fly
local control = {F=0,B=0,L=0,R=0,U=0,D=0}
local flyConn

Button("Fly",10,function()

Settings.Fly = not Settings.Fly

local char = LP.Character
if not char then return end
local hrp = char:FindFirstChild("HumanoidRootPart")

if Settings.Fly then

local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1e9,1e9,1e9)
bv.Velocity = Vector3.new()
bv.Name = "Fly"
bv.Parent = hrp

flyConn = RunService.RenderStepped:Connect(function()

local cam = Camera.CFrame

local move =
(cam.LookVector * (control.F + control.B)) +
(cam.RightVector * (control.R + control.L)) +
(Vector3.new(0,1,0) * (control.U + control.D))

if hrp:FindFirstChild("Fly") then
hrp.Fly.Velocity = move * Settings.FlySpeed
end

end)

else

if hrp:FindFirstChild("Fly") then
hrp.Fly:Destroy()
end

if flyConn then
flyConn:Disconnect()
end

end

end)

-- Fly速度
Button("Fly Speed +",50,function()
Settings.FlySpeed = Settings.FlySpeed + 20
end)

Button("Fly Speed -",90,function()
Settings.FlySpeed = math.max(20,Settings.FlySpeed - 20)
end)

-- 控制
UIS.InputBegan:Connect(function(i,g)

if g then return end

if i.KeyCode == Enum.KeyCode.W then control.F = 1 end
if i.KeyCode == Enum.KeyCode.S then control.B = -1 end
if i.KeyCode == Enum.KeyCode.A then control.L = -1 end
if i.KeyCode == Enum.KeyCode.D then control.R = 1 end
if i.KeyCode == Enum.KeyCode.Space then control.U = 1 end
if i.KeyCode == Enum.KeyCode.LeftShift then control.D = -1 end

end)

UIS.InputEnded:Connect(function(i)

if i.KeyCode == Enum.KeyCode.W then control.F = 0 end
if i.KeyCode == Enum.KeyCode.S then control.B = 0 end
if i.KeyCode == Enum.KeyCode.A then control.L = 0 end
if i.KeyCode == Enum.KeyCode.D then control.R = 0 end
if i.KeyCode == Enum.KeyCode.Space then control.U = 0 end
if i.KeyCode == Enum.KeyCode.LeftShift then control.D = 0 end

end)

-- Noclip
Button("Noclip",130,function()
Settings.Noclip = not Settings.Noclip
end)

RunService.Stepped:Connect(function()

if Settings.Noclip and LP.Character then

for _,v in pairs(LP.Character:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide = false
end
end

end

end)

-- ESP
Button("ESP",170,function()

Settings.ESP = not Settings.ESP

for _,p in pairs(Players:GetPlayers()) do

if p ~= LP and p.Character then

if Settings.ESP then

local h = Instance.new("Highlight")
h.FillColor = Color3.fromRGB(255,0,0)
h.OutlineColor = Color3.new(1,1,1)
h.Parent = p.Character

else

local h = p.Character:FindFirstChildOfClass("Highlight")
if h then h:Destroy() end

end

end
end

end)

-- Aimbot
Button("Aimbot",210,function()
Settings.Aimbot = not Settings.Aimbot
circle.Visible = Settings.Aimbot
end)

-- Silent Aim
Button("Silent Aim",250,function()
Settings.SilentAim = not Settings.SilentAim
end)

-- FOV
Button("FOV +",290,function()
Settings.FOV = Settings.FOV + 20
circle.Radius = Settings.FOV
end)

Button("FOV -",330,function()
Settings.FOV = math.max(40,Settings.FOV - 20)
circle.Radius = Settings.FOV
end)

-- 圓圈
local circle = Drawing.new("Circle")
circle.Color = Color3.new(1,1,1)
circle.Thickness = 2
circle.NumSides = 100
circle.Filled = false
circle.Radius = Settings.FOV
circle.Visible = false

RunService.RenderStepped:Connect(function()

local size = Camera.ViewportSize
local center = Vector2.new(size.X/2,size.Y/2)

circle.Position = center

end)

-- K鍵隱藏
UIS.InputBegan:Connect(function(input,gpe)

if gpe then return end

if input.KeyCode == Enum.KeyCode.K then
frame.Visible = not frame.Visible
end

end)
