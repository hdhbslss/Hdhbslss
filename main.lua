local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,230,0,330)
frame.Position = UDim2.new(0.5,-115,0.5,-165)
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
frame.Position = UDim2.new(0.5,-115,0,60)

end)

-- 按鈕
local function Button(text,y,callback)

local b = Instance.new("TextButton")
b.Size = UDim2.new(0,210,0,35)
b.Position = UDim2.new(0,10,0,y)
b.BackgroundColor3 = Color3.fromRGB(35,35,35)
b.TextColor3 = Color3.new(1,1,1)
b.Text = text
b.Parent = frame

b.MouseButton1Click:Connect(callback)

end

-- Fly
local fly = false
local flySpeed = 70
local flyConn

Button("Fly",10,function()

fly = not fly

local char = LP.Character
if not char then return end

local hrp = char:FindFirstChild("HumanoidRootPart")

if fly then

local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1e9,1e9,1e9)
bv.Name = "Fly"
bv.Parent = hrp

flyConn = RunService.RenderStepped:Connect(function()

if hrp:FindFirstChild("Fly") then
hrp.Fly.Velocity = Camera.CFrame.LookVector * flySpeed
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

-- Noclip
local noclip = false

Button("Noclip",50,function()
noclip = not noclip
end)

RunService.Stepped:Connect(function()

if noclip and LP.Character then

for _,v in pairs(LP.Character:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide = false
end
end

local hrp = LP.Character:FindFirstChild("HumanoidRootPart")

if hrp and hrp.Position.Y < -25 then
hrp.CFrame = hrp.CFrame + Vector3.new(0,15,0)
end

end

end)

-- ESP
local esp = false

local function addESP(p)

if p ~= LP then

p.CharacterAdded:Connect(function(char)

if esp then

local h = Instance.new("Highlight")
h.FillColor = Color3.fromRGB(255,0,0)
h.OutlineColor = Color3.new(1,1,1)
h.Parent = char

end

end)

end

end

for _,p in pairs(Players:GetPlayers()) do
addESP(p)
end

Players.PlayerAdded:Connect(addESP)

Button("ESP",90,function()

esp = not esp

for _,p in pairs(Players:GetPlayers()) do

if p ~= LP and p.Character then

if esp then

local h = Instance.new("Highlight")
h.FillColor = Color3.fromRGB(255,0,0)
h.Parent = p.Character

else

if p.Character:FindFirstChildOfClass("Highlight") then
p.Character:FindFirstChildOfClass("Highlight"):Destroy()
end

end

end

end

end)

-- AIMBOT
local aimbot = false
local fov = 120

local circle = Drawing.new("Circle")
circle.Color = Color3.new(1,1,1)
circle.Thickness = 2
circle.NumSides = 100
circle.Filled = false
circle.Radius = fov
circle.Visible = false

Button("Aimbot",130,function()

aimbot = not aimbot
circle.Visible = aimbot

end)

Button("FOV +",170,function()

fov = fov + 20
circle.Radius = fov

end)

Button("FOV -",210,function()

fov = math.max(40,fov - 20)
circle.Radius = fov

end)

RunService.RenderStepped:Connect(function()

local size = Camera.ViewportSize
local center = Vector2.new(size.X/2,size.Y/2)

circle.Position = center

if aimbot then

local closest = nil
local dist = math.huge

for _,p in pairs(Players:GetPlayers()) do

if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then

local pos,visible = Camera:WorldToViewportPoint(p.Character.Head.Position)

if visible then

local mag = (Vector2.new(pos.X,pos.Y) - center).Magnitude

if mag < dist and mag < fov then
dist = mag
closest = p
end

end
end
end

if closest then
Camera.CFrame = CFrame.new(Camera.CFrame.Position,closest.Character.Head.Position)
end

end

end)

-- K鍵隱藏
UIS.InputBegan:Connect(function(input,gpe)

if gpe then return end

if input.KeyCode == Enum.KeyCode.K then
frame.Visible = not frame.Visible
end

end)
