--// Services
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")

local LP=Players.LocalPlayer
local Camera=workspace.CurrentCamera
local Mouse=LP:GetMouse()

--// Settings
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

--// FOV Circle
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

--// UI
local gui=Instance.new("ScreenGui",game.CoreGui)

local frame=Instance.new("Frame",gui)
frame.Size=UDim2.new(0,250,0,520)
frame.Position=UDim2.new(.5,-125,.5,-260)
frame.BackgroundColor3=Color3.fromRGB(20,20,20)
frame.Active=true
frame.Draggable=true
Instance.new("UICorner",frame)

local stroke=Instance.new("UIStroke",frame)
stroke.Color=Color3.fromRGB(0,170,255)

local title=Instance.new("TextLabel",frame)
title.Size=UDim2.new(1,0,0,40)
title.BackgroundTransparency=1
title.Text="Script Hub"
title.TextColor3=Color3.fromRGB(0,170,255)
title.Font=Enum.Font.GothamBold
title.TextSize=22

--// Mobile Button
local mobile=Instance.new("TextButton",gui)
mobile.Size=UDim2.new(0,40,0,40)
mobile.Position=UDim2.new(.5,-20,0,10)
mobile.Text="-"
mobile.BackgroundColor3=Color3.fromRGB(30,30,30)
mobile.TextColor3=Color3.new(1,1,1)
Instance.new("UICorner",mobile)

mobile.MouseButton1Click:Connect(function()
frame.Visible=not frame.Visible
end)

--// Button Creator
local function Toggle(text,y,setting,callback)

local b=Instance.new("TextButton",frame)
b.Size=UDim2.new(0,220,0,35)
b.Position=UDim2.new(0,15,0,y)
b.BackgroundColor3=Color3.fromRGB(35,35,35)
Instance.new("UICorner",b)

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
if callback then callback() end
end)

end

local function Button(text,y,func)

local b=Instance.new("TextButton",frame)
b.Size=UDim2.new(0,220,0,35)
b.Position=UDim2.new(0,15,0,y)
b.BackgroundColor3=Color3.fromRGB(35,35,35)
b.TextColor3=Color3.new(1,1,1)
b.Text=text
Instance.new("UICorner",b)

b.MouseButton1Click:Connect(func)

end

--// Fly
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
local v=char.HumanoidRootPart:FindFirstChild("Fly")
if v then v:Destroy() end
end

if flyConn then flyConn:Disconnect() end

end

local function StartFly()

StopFly()

local char=LP.Character
if not char then return end

local hrp=char:FindFirstChild("HumanoidRootPart")

local bv=Instance.new("BodyVelocity",hrp)
bv.Name="Fly"
bv.MaxForce=Vector3.new(1e9,1e9,1e9)

flyConn=RunService.RenderStepped:Connect(function()

local cam=Camera.CFrame

local move=
(cam.LookVector*(control.F+control.B))+
(cam.RightVector*(control.R+control.L))+
(Vector3.new(0,1,0)*(control.U+control.D))

bv.Velocity=move*Settings.FlySpeed

end)

end

Toggle("Fly",50,"Fly",function()
if Settings.Fly then StartFly() else StopFly() end
end)

Button("Fly Speed +",90,function()
Settings.FlySpeed+=20
end)

Button("Fly Speed -",130,function()
Settings.FlySpeed=math.max(20,Settings.FlySpeed-20)
end)

LP.CharacterAdded:Connect(function()
task.wait(1)
if Settings.Fly then StartFly() end
end)

--// Noclip
Toggle("Noclip",170,"Noclip")

RunService.Stepped:Connect(function()
if Settings.Noclip and LP.Character then
for _,v in pairs(LP.Character:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide=false
end
end
end
end)

--// ESP
Toggle("ESP",210,"ESP")

local function AddESP(char)

if char:FindFirstChild("Highlight") then return end

local h=Instance.new("Highlight",char)
h.FillColor=Color3.fromRGB(255,0,0)

end

RunService.RenderStepped:Connect(function()

if Settings.ESP then

for _,p in pairs(Players:GetPlayers()) do
if p~=LP and p.Character then
AddESP(p.Character)
end
end

else

for _,p in pairs(Players:GetPlayers()) do
if p.Character and p.Character:FindFirstChild("Highlight") then
p.Character.Highlight:Destroy()
end
end

end

end)

--// WallCheck
local function WallCheck(target)

local origin=Camera.CFrame.Position
local direction=(target.Position-origin)

local params=RaycastParams.new()
params.FilterType=Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances={LP.Character}

local result=workspace:Raycast(origin,direction,params)

if result then
return result.Instance:IsDescendantOf(target.Parent)
end

return true

end

--// Get Target
local function GetClosest()

local closest=nil
local dist=Settings.FOV

for _,p in pairs(Players:GetPlayers()) do

if p~=LP and p.Character and p.Character:FindFirstChild("Head") then

local hum=p.Character:FindFirstChild("Humanoid")

if Settings.KillCheck then
if not hum or hum.Health<=0 then
continue
end
end

local head=p.Character.Head

if Settings.WallCheck and not WallCheck(head) then
continue
end

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

--// Aimbot
Toggle("Aimbot",250,"Aimbot",function()
circle.Visible=Settings.Aimbot
end)

RunService.RenderStepped:Connect(function()

if Settings.Aimbot then

local target=GetClosest()

if target then
Camera.CFrame=CFrame.new(Camera.CFrame.Position,target.Position)
end

end

end)

--// Silent Aim
Toggle("Silent Aim",290,"SilentAim")

local mt=getrawmetatable(game)
local old=mt.__index
setreadonly(mt,false)

mt.__index=newcclosure(function(self,key)

if self==Mouse and key=="Hit" and Settings.SilentAim then

local target=GetClosest()

if target then
return CFrame.new(target.Position)
end

end

return old(self,key)

end)

--// Toggles
Toggle("Wall Check",330,"WallCheck")
Toggle("Kill Check",370,"KillCheck")

Button("FOV +",410,function()
Settings.FOV+=10
end)

Button("FOV -",450,function()
Settings.FOV=math.max(30,Settings.FOV-10)
end)

--// Hide UI
UIS.InputBegan:Connect(function(i,g)
if g then return end
if i.KeyCode==Enum.KeyCode.K then
frame.Visible=not frame.Visible
end
end)
