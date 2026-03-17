-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
getgenv().IceySettings = {
    Aimbot = false,
    ESP = false,
    Fly = false,
    Noclip = false,
    FOV = 150,
    FlySpeed = 70
}

-- GUI
local ScreenGui = Instance.new("ScreenGui",game.CoreGui)
local Frame = Instance.new("Frame",ScreenGui)
Frame.Size = UDim2.new(0,200,0,250)
Frame.Position = UDim2.new(0,20,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local Layout = Instance.new("UIListLayout",Frame)

function ToggleButton(name,setting)

    local Btn = Instance.new("TextButton",Frame)
    Btn.Size = UDim2.new(1,0,0,40)
    Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Btn.TextColor3 = Color3.new(1,1,1)

    local function Update()
        if IceySettings[setting] then
            Btn.Text = name.." : ON"
        else
            Btn.Text = name.." : OFF"
        end
    end

    Update()

    Btn.MouseButton1Click:Connect(function()
        IceySettings[setting] = not IceySettings[setting]
        Update()
    end)

end

ToggleButton("Aimbot","Aimbot")
ToggleButton("ESP","ESP")
ToggleButton("Fly","Fly")
ToggleButton("Noclip","Noclip")

-- FOV Circle
local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Color = Color3.new(1,1,1)
Circle.Thickness = 2
Circle.Filled = false
Circle.Radius = IceySettings.FOV

-- ESP
local ESP = {}

function CreateESP(player)

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1,0,0)
    Box.Thickness = 2

    ESP[player] = Box

end

for _,p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer then
CreateESP(p)
end
end

Players.PlayerAdded:Connect(function(p)
CreateESP(p)
end)

-- Get Closest
function GetClosest()

local closest
local dist = IceySettings.FOV

for _,p in pairs(Players:GetPlayers()) do

if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then

local pos,visible = Camera:WorldToViewportPoint(p.Character.Head.Position)

if visible then

local mag = (Vector2.new(pos.X,pos.Y) -
Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude

if mag < dist then
dist = mag
closest = p
end

end
end
end

return closest

end

-- Fly
local FlyVel

function StartFly()

local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

FlyVel = Instance.new("BodyVelocity")
FlyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
FlyVel.Parent = root

end

-- Main Loop
RunService.RenderStepped:Connect(function()

Circle.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
Circle.Radius = IceySettings.FOV

-- Aimbot
if IceySettings.Aimbot then

local target = GetClosest()

if target and target.Character then
Camera.CFrame = CFrame.new(Camera.CFrame.Position,target.Character.Head.Position)
end

end

-- ESP
for player,box in pairs(ESP) do

if IceySettings.ESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

local pos,visible = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

if visible then
box.Visible = true
box.Size = Vector2.new(40,60)
box.Position = Vector2.new(pos.X-20,pos.Y-30)
else
box.Visible = false
end

else
box.Visible = false
end

end

-- Fly
if IceySettings.Fly then

if not FlyVel then
StartFly()
end

FlyVel.Velocity = Camera.CFrame.LookVector * IceySettings.FlySpeed

end

end)

-- Noclip
RunService.Stepped:Connect(function()

if IceySettings.Noclip and LocalPlayer.Character then

for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide = false
end
end

end

end)

print("Icey Script Loaded")
