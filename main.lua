if getgenv().HubPro then return end
getgenv().HubPro=true

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")

local LP=Players.LocalPlayer
local Camera=workspace.CurrentCamera

local Settings={
Aimbot=false,
SilentAim=false,
ESP=false,
Fly=false,
Noclip=false,

WallCheck=true,
KillCheck=true,

FlySpeed=80,
FOV=120
}

-- FOV Circle
local circle=Drawing.new("Circle")
circle.Color=Color3.fromRGB(0,170,255)
circle.Thickness=2
circle.NumSides=100
circle.Filled=false
circle.Visible=false

RunService.RenderStepped:Connect(function()
local size=Camera.ViewportSize
circle.Position=Vector2.new(size.X/2,size.Y/2)
circle.Radius=Settings.FOV
end)

-- UI
local gui=Instance.new("ScreenGui",game.CoreGui)

local frame=Instance.new("Frame",gui)
frame.Size=UDim2.new(0,260,0,540)
frame.Position=UDim2.new(.5,-130,.5,-270)
frame.BackgroundColor3=Color3.fromRGB(20,20,20)
frame.Active=true
frame.Draggable=true
Instance.new("UICorner",frame)

local stroke=Instance.new("UIStroke",frame)
stroke.Color=Color3.fromRGB(0,170,255)

local title=Instance.new("TextLabel",frame)
title.Size=UDim2.new(1,0,0,40)
title.BackgroundTransparency=1
title.Text="Script Hub Pro"
title.TextColor3=Color3.fromRGB(0,170,255)
title.Font=Enum.Font.GothamBold
title.TextSize=22

local info=Instance.new("TextLabel",frame)
info.Size=UDim2.new(1,0,0,20)
info.Position=UDim2.new(0,0,0,40)
info.BackgroundTransparency=1
info.TextColor3=Color3.new(1,1,1)
info.Font=Enum.Font.Gotham
info.TextSize=14

-- Button
local function Button(text,y,func)

local b=Instance.new("TextButton",frame)
b.Size=UDim2.new(0,220,0,35)
b.Position=UDim2.new(0,20,0,y)
b.BackgroundColor3=Color3.fromRGB(35,35,35)
b.TextColor3=Color3.new(1,1,1)
b.Text=text
Instance.new("UICorner",b)

b.MouseButton1Click:Connect(func)

return b
end

-- Toggle
local function Toggle(text,y,setting)

local b=Button(text,y)

local function update()

if Settings[setting] then
b.Text=text.." ✔"
b.TextColor3=Color3.fromRGB(0,255,0)
else
b.Text=text
b.TextColor3=Color3.new(1,1,1)
end

end

update()

b.MouseButton1Click:Connect(function()

Settings[setting]=not Settings[setting]
update()

if setting=="Aimbot" then
circle.Visible=Settings.Aimbot
end

end)

end

-- Fly
local flyConn
local control={F=0,B=0,L=0,R=0,U=0,D=0}

UIS.InputBegan:Connect(function(i,g)
if g then return end
if i.KeyCode==Enum.KeyCode.W then control.F=1 end
if i.KeyCode==Enum.KeyCode.S then control.B=-1 end
if i.KeyCode==Enum.KeyCode.A then control.L=-1 end
if i.KeyCode==Enum.KeyCode.D then control.R=1 end
if i.KeyCode==Enum.KeyCode.Space then control.U=1 end
if i.KeyCode==Enum.KeyCode.LeftShift then control.D=-1 end
end)

UIS.InputEnded:Connect(function(i)
if i.KeyCode==Enum.KeyCode.W then control.F=0 end
if i.KeyCode==Enum.KeyCode.S then control.B=0 end
if i.KeyCode==Enum.KeyCode.A then control.L=0 end
if i.KeyCode==Enum.KeyCode.D then control.R=0 end
if i.KeyCode==Enum.KeyCode.Space then control.U=0 end
if i.KeyCode==Enum.KeyCode.LeftShift then control.D=0 end
end)

local function StartFly()

local char=LP.Character
if not char then return end

local hrp=char:FindFirstChild("HumanoidRootPart")

local bv=Instance.new("BodyVelocity")
bv.MaxForce=Vector3.new(1e9,1e9,1e9)
bv.Parent=hrp

flyConn=RunService.RenderStepped:Connect(function()

local cam=Camera.CFrame

local move=
(cam.LookVector*(control.F+control.B))+
(cam.RightVector*(control.R+control.L))+
(Vector3.new(0,1,0)*(control.U+control.D))

bv.Velocity=move*Settings.FlySpeed

end)

end

Toggle("Fly",70,"Fly")

Button("Fly Speed +",110,function()
Settings.FlySpeed+=20
end)

Button("Fly Speed -",150,function()
Settings.FlySpeed=math.max(20,Settings.FlySpeed-20)
end)

-- ESP
Toggle("ESP",190,"ESP")

local function AddESP(player)

if player==LP then return end

player.CharacterAdded:Connect(function(char)

if not Settings.ESP then return end

local h=Instance.new("Highlight")
h.FillColor=Color3.fromRGB(255,0,0)
h.Parent=char

end)

end

for _,p in pairs(Players:GetPlayers()) do
AddESP(p)
end

Players.PlayerAdded:Connect(AddESP)

-- Target
local CurrentTarget=nil

local function GetClosest()

local closest=nil
local dist=Settings.FOV

for _,p in pairs(Players:GetPlayers()) do

if p~=LP and p.Character and p.Character:FindFirstChild("Head") then

local hum=p.Character:FindFirstChild("Humanoid")

if Settings.KillCheck then
if not hum or hum.Health<=0 then continue end
end

local head=p.Character.Head

local pos,vis=Camera:WorldToViewportPoint(head.Position)

if vis then

local diff=(Vector2.new(pos.X,pos.Y)-circle.Position).Magnitude

if diff<dist then
dist=diff
closest=head
end

end

end

end

return closest
end

task.spawn(function()

while true do
task.wait(0.05)
CurrentTarget=GetClosest()
end

end)

-- Aimbot
Toggle("Aimbot",230,"Aimbot")

RunService.RenderStepped:Connect(function()

info.Text="FlySpeed: "..Settings.FlySpeed.." | FOV: "..Settings.FOV

if Settings.Aimbot and CurrentTarget then
Camera.CFrame=CFrame.new(Camera.CFrame.Position,CurrentTarget.Position)
end

end)

-- Toggles
Toggle("Wall Check",270,"WallCheck")
Toggle("Kill Check",310,"KillCheck")

Button("FOV +",350,function()
Settings.FOV+=10
end)

Button("FOV -",390,function()
Settings.FOV=math.max(30,Settings.FOV-10)
end)

UIS.InputBegan:Connect(function(i,g)
if g then return end
if i.KeyCode==Enum.KeyCode.K then
frame.Visible=not frame.Visible
end
end)
