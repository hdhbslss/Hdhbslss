if getgenv().ScriptHubPro then return end
getgenv().ScriptHubPro=true

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")

local LP=Players.LocalPlayer
local Camera=workspace.CurrentCamera
local Mouse=LP:GetMouse()

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
circle.NumSides=50
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
frame.Size=UDim2.new(0,240,0,460)
frame.Position=UDim2.new(.5,-120,.5,-230)
frame.BackgroundColor3=Color3.fromRGB(20,20,20)
frame.Active=true
frame.Draggable=true
Instance.new("UICorner",frame)

local title=Instance.new("TextLabel",frame)
title.Size=UDim2.new(1,0,0,40)
title.BackgroundTransparency=1
title.Text="Script Hub Pro Lite"
title.TextColor3=Color3.fromRGB(0,170,255)
title.Font=Enum.Font.GothamBold
title.TextSize=22

local function Button(text,y,func)

local b=Instance.new("TextButton",frame)
b.Size=UDim2.new(0,200,0,32)
b.Position=UDim2.new(0,20,0,y)
b.BackgroundColor3=Color3.fromRGB(35,35,35)
b.TextColor3=Color3.new(1,1,1)
b.Text=text
Instance.new("UICorner",b)

b.MouseButton1Click:Connect(func)

return b

end

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
local control={F=0,B=0,L=0,R=0,U=0,D=0}
local flyBV=nil

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

RunService.RenderStepped:Connect(function()

if Settings.Fly and LP.Character then

local hrp=LP.Character:FindFirstChild("HumanoidRootPart")

if hrp then

if not flyBV then
flyBV=Instance.new("BodyVelocity")
flyBV.MaxForce=Vector3.new(1e9,1e9,1e9)
flyBV.Parent=hrp
end

local cam=Camera.CFrame

local move=
(cam.LookVector*(control.F+control.B))+
(cam.RightVector*(control.R+control.L))+
(Vector3.new(0,1,0)*(control.U+control.D))

flyBV.Velocity=move*Settings.FlySpeed

end

else

if flyBV then
flyBV:Destroy()
flyBV=nil
end

end

end)

Toggle("Fly",60,"Fly")

Button("Fly Speed +",100,function()
Settings.FlySpeed+=20
end)

Button("Fly Speed -",140,function()
Settings.FlySpeed=math.max(20,Settings.FlySpeed-20)
end)

-- Noclip
Toggle("Noclip",180,"Noclip")

RunService.Stepped:Connect(function()

if Settings.Noclip and LP.Character then

for _,v in pairs(LP.Character:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide=false
end
end

end

end)

-- ESP
Toggle("ESP",220,"ESP")

task.spawn(function()

while true do
task.wait(0.3)

if Settings.ESP then

for _,p in pairs(Players:GetPlayers()) do

if p~=LP and p.Character then

local char=p.Character
local esp=char:FindFirstChild("Highlight")

if not esp then
esp=Instance.new("Highlight")
esp.Parent=char
end

if p.Team==LP.Team then
esp.FillColor=Color3.fromRGB(0,255,0)
else
esp.FillColor=Color3.fromRGB(255,0,0)
end

end

end

end

end

end)

-- Target
local CurrentTarget=nil

local function GetClosest()

local closest=nil
local dist=Settings.FOV

for _,p in pairs(Players:GetPlayers()) do

if p~=LP and p.Character and p.Character:FindFirstChild("Head") then

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
task.wait(0.12)
CurrentTarget=GetClosest()
end

end)

Toggle("Aimbot",260,"Aimbot")

RunService.RenderStepped:Connect(function()

if Settings.Aimbot and CurrentTarget then
Camera.CFrame=CFrame.new(Camera.CFrame.Position,CurrentTarget.Position)
end

end)

Toggle("Silent Aim",300,"SilentAim")

local mt=getrawmetatable(game)
local old=mt.__index
setreadonly(mt,false)

mt.__index=newcclosure(function(self,key)

if self==Mouse and key=="Hit" and Settings.SilentAim then
if CurrentTarget then
return CFrame.new(CurrentTarget.Position)
end
end

return old(self,key)

end)

setreadonly(mt,true)

Button("FOV +",340,function()
Settings.FOV+=10
end)

Button("FOV -",380,function()
Settings.FOV=math.max(30,Settings.FOV-10)
end)

Toggle("Wall Check",420,"WallCheck")
Toggle("Kill Check",450,"KillCheck")

UIS.InputBegan:Connect(function(i,g)

if g then return end
if i.KeyCode==Enum.KeyCode.K then
frame.Visible=not frame.Visible
end

end)
