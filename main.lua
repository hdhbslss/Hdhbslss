local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

local Settings={
Fly=false,
FlySpeed=80,
Noclip=false,
ESP=false,
Aimbot=false,
SilentAim=false,
WallCheck=true,
KillCheck=true,
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

-- GUI
local gui=Instance.new("ScreenGui",game.CoreGui)

local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,240,0,500)
frame.Position=UDim2.new(0.5,-120,0.5,-250)
frame.BackgroundColor3=Color3.fromRGB(20,20,20)
frame.Active=true
frame.Draggable=true
frame.Parent=gui
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)

local stroke=Instance.new("UIStroke",frame)
stroke.Color=Color3.fromRGB(0,170,255)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,40)
title.BackgroundTransparency=1
title.Text="Script Hub"
title.TextColor3=Color3.fromRGB(0,170,255)
title.Font=Enum.Font.GothamBold
title.TextSize=22
title.Parent=frame

-- Mobile Button
local mobile=Instance.new("TextButton")
mobile.Size=UDim2.new(0,40,0,40)
mobile.Position=UDim2.new(0.5,-20,0,10)
mobile.Text="-"
mobile.TextColor3=Color3.new(1,1,1)
mobile.BackgroundColor3=Color3.fromRGB(30,30,30)
mobile.Parent=gui
Instance.new("UICorner",mobile).CornerRadius=UDim.new(1,0)

mobile.MouseButton1Click:Connect(function()
frame.Visible=not frame.Visible
frame.Position=UDim2.new(0.5,-120,0,60)
end)

-- Toggle Button
local function ToggleButton(text,y,setting,callback)

local b=Instance.new("TextButton")
b.Size=UDim2.new(0,220,0,35)
b.Position=UDim2.new(0,10,0,y)
b.BackgroundColor3=Color3.fromRGB(35,35,35)
b.Parent=frame
Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)

local function Update()
if Settings[setting] then
b.Text=text.." ✔"
b.TextColor3=Color3.fromRGB(0,255,0)
else
b.Text=text
b.TextColor3=Color3.new(1,1,1)
end
end

Update()

b.MouseButton1Click:Connect(function()
Settings[setting]=not Settings[setting]
if callback then callback() end
Update()
end)

end

local function Button(text,y,callback)

local b=Instance.new("TextButton")
b.Size=UDim2.new(0,220,0,35)
b.Position=UDim2.new(0,10,0,y)
b.BackgroundColor3=Color3.fromRGB(35,35,35)
b.TextColor3=Color3.new(1,1,1)
b.Text=text
b.Parent=frame
Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)

b.MouseButton1Click:Connect(callback)

end

-- Fly Control
local control={F=0,B=0,L=0,R=0,U=0,D=0}
local flyConn

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

local function StopFly()
local char=LP.Character
if char and char:FindFirstChild("HumanoidRootPart") then
local v=char.HumanoidRootPart:FindFirstChild("FlyVelocity")
if v then v:Destroy() end
end
if flyConn then flyConn:Disconnect() end
end

local function StartFly()
StopFly()
local char=LP.Character
if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")

local bv=Instance.new("BodyVelocity")
bv.Name="FlyVelocity"
bv.MaxForce=Vector3.new(1e9,1e9,1e9)
bv.Parent=hrp

flyConn=RunService.RenderStepped:Connect(function()

local cam=Camera.CFrame

local move=
(cam.LookVector*(control.F+control.B))+
(cam.RightVector*(control.R+control.L))+
(Vector3.new(0,1,0)*(control.U+control.D))

hrp.FlyVelocity.Velocity=move*Settings.FlySpeed

end)
end

ToggleButton("Fly",50,"Fly",function()
if Settings.Fly then StartFly() else StopFly() end
end)

Button("Fly Speed +",90,function()
Settings.FlySpeed+=20
end)

Button("Fly Speed -",130,function()
Settings.FlySpeed=math.max(20,Settings.FlySpeed-20)
end)

-- Respawn Fly
LP.CharacterAdded:Connect(function()
task.wait(1)
if Settings.Fly then StartFly() end
end)

-- Noclip
ToggleButton("Noclip",170,"Noclip")

RunService.Stepped:Connect(function()
if Settings.Noclip and LP.Character then
for _,v in pairs(LP.Character:GetDescendants()) do
if v:IsA("BasePart") then v.CanCollide=false end
end
end
end)

-- ESP
ToggleButton("ESP",210,"ESP")

RunService.RenderStepped:Connect(function()

for _,p in pairs(Players:GetPlayers()) do
if p~=LP and p.Character then

local h=p.Character:FindFirstChildOfClass("Highlight")

if Settings.ESP then
if not h then
h=Instance.new("Highlight")
h.FillColor=Color3.fromRGB(255,0,0)
h.Parent=p.Character
end
else
if h then h:Destroy() end
end

end
end

end)

-- Aimbot
ToggleButton("Aimbot",250,"Aimbot",function()
circle.Visible=Settings.Aimbot
end)

ToggleButton("Silent Aim",290,"SilentAim")
ToggleButton("Wall Check",330,"WallCheck")
ToggleButton("Kill Check",370,"KillCheck")

Button("FOV +",410,function()
Settings.FOV+=10
end)

Button("FOV -",450,function()
Settings.FOV=math.max(30,Settings.FOV-10)
end)

-- Target Finder
local function GetClosest()

local closest=nil
local dist=Settings.FOV

for _,p in pairs(Players:GetPlayers()) do
if p~=LP and p.Character and p.Character:FindFirstChild("Head") then

local humanoid=p.Character:FindFirstChild("Humanoid")

if Settings.KillCheck and humanoid and humanoid.Health<=0 then
continue
end

local head=p.Character.Head
local pos,visible=Camera:WorldToViewportPoint(head.Position)

if visible then

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

RunService.RenderStepped:Connect(function()

local target=GetClosest()

if Settings.Aimbot and target then
Camera.CFrame=CFrame.new(Camera.CFrame.Position,target.Position)
end

end)

-- Silent Aim (bullet tracking)
local mt=getrawmetatable(game)
local old=mt.__namecall
setreadonly(mt,false)

mt.__namecall=newcclosure(function(self,...)

local args={...}
local method=getnamecallmethod()

if Settings.SilentAim and method=="Raycast" then

local target=GetClosest()

if target then
args[2]=(target.Position-args[1]).Unit*1000
return old(self,unpack(args))
end

end

return old(self,...)

end)

-- Hide UI
UIS.InputBegan:Connect(function(i,g)
if g then return end
if i.KeyCode==Enum.KeyCode.K then
frame.Visible=not frame.Visible
end
end)
