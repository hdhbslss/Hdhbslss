if getgenv().ScriptHubFinal then return end
getgenv().ScriptHubFinal=true

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")

local LP=Players.LocalPlayer
local Camera=workspace.CurrentCamera
local Mouse=LP:GetMouse()

-- Settings
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
frame.Size=UDim2.new(0,260,0,520)
frame.Position=UDim2.new(.5,-130,.5,-260)
frame.BackgroundColor3=Color3.fromRGB(20,20,20)
frame.Active=true
frame.Draggable=true
Instance.new("UICorner",frame)

local title=Instance.new("TextLabel",frame)
title.Size=UDim2.new(1,0,0,40)
title.BackgroundTransparency=1
title.Text="Script Hub"
title.TextColor3=Color3.fromRGB(0,170,255)
title.Font=Enum.Font.GothamBold
title.TextSize=22

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

RunService.RenderStepped:Connect(function()

local cam=Camera.CFrame

local move=
(cam.LookVector*(control.F+control.B))+
(cam.RightVector*(control.R+control.L))+
(Vector3.new(0,1,0)*(control.U+control.D))

bv.Velocity=move*Settings.FlySpeed

end)

end

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

-- ESP (隊友綠 敵人紅)
Toggle("ESP",220,"ESP")

RunService.RenderStepped:Connect(function()

for _,p in pairs(Players:GetPlayers()) do

if p~=LP and p.Character then

local char=p.Character
local esp=char:FindFirstChild("Highlight")

if Settings.ESP then

if not esp then
esp=Instance.new("Highlight")
esp.Parent=char
end

if p.Team==LP.Team then
esp.FillColor=Color3.fromRGB(0,255,0)
else
esp.FillColor=Color3.fromRGB(255,0,0)
end

else

if esp then esp:Destroy() end

end

end

end

end)

-- WallCheck
local function WallCheck(target)

local origin=Camera.CFrame.Position
local direction=target.Position-origin

local params=RaycastParams.new()
params.FilterType=Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances={LP.Character,target.Parent}

local result=workspace:Raycast(origin,direction,params)

return not result
end

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

task.spawn(function()

while true do
task.wait(0.05)
CurrentTarget=GetClosest()
end

end)

-- Aimbot
Toggle("Aimbot",260,"Aimbot")

RunService.RenderStepped:Connect(function()

if Settings.Aimbot and CurrentTarget then
Camera.CFrame=CFrame.new(Camera.CFrame.Position,CurrentTarget.Position)
end

end)

-- Silent Aim
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

-- FOV
Button("FOV +",340,function()
Settings.FOV+=10
end)

Button("FOV -",380,function()
Settings.FOV=math.max(30,Settings.FOV-10)
end)

Toggle("Wall Check",420,"WallCheck")
Toggle("Kill Check",460,"KillCheck")

-- Hide UI
UIS.InputBegan:Connect(function(i,g)

if g then return end

if i.KeyCode==Enum.KeyCode.K then
frame.Visible=not frame.Visible
end

end)
