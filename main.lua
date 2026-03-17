-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,260,0,220)
Frame.Position = UDim2.new(0.5,-130,0.5,-110)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "Script Menu"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.TextScaled = true

-- Button maker
function Button(name,pos)

	local b = Instance.new("TextButton")
	b.Parent = Frame
	b.Size = UDim2.new(0,200,0,35)
	b.Position = UDim2.new(0.5,-100,0,pos)
	b.Text = name.." : OFF"
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)

	return b
end

local ESP = Button("ESP",50)
local AIM = Button("Aimbot",90)
local FLY = Button("Fly",130)
local NOCLIP = Button("Noclip",170)

-- Mobile Hide
local Hide = Instance.new("TextButton")
Hide.Parent = ScreenGui
Hide.Size = UDim2.new(0,50,0,50)
Hide.Position = UDim2.new(0.5,-25,0,5)
Hide.Text = "-"
Hide.BackgroundColor3 = Color3.fromRGB(40,40,40)
Hide.TextColor3 = Color3.new(1,1,1)

-- Toggle UI
local visible = true

local function ToggleUI()
	visible = not visible
	Frame.Visible = visible
end

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	
	if i.KeyCode == Enum.KeyCode.K then
		ToggleUI()
	end
end)

Hide.MouseButton1Click:Connect(ToggleUI)

-- States
local espOn=false
local aimOn=false
local flyOn=false
local noclipOn=false

ESP.MouseButton1Click:Connect(function()
	espOn=not espOn
	ESP.Text="ESP : "..(espOn and "ON" or "OFF")
end)

AIM.MouseButton1Click:Connect(function()
	aimOn=not aimOn
	AIM.Text="Aimbot : "..(aimOn and "ON" or "OFF")
end)

FLY.MouseButton1Click:Connect(function()
	flyOn=not flyOn
	FLY.Text="Fly : "..(flyOn and "ON" or "OFF")
end)

NOCLIP.MouseButton1Click:Connect(function()
	noclipOn=not noclipOn
	NOCLIP.Text="Noclip : "..(noclipOn and "ON" or "OFF")
end)

-- FOV Circle
local circle = Drawing.new("Circle")
circle.Radius = 120
circle.Color = Color3.fromRGB(255,255,255)
circle.Thickness = 2
circle.Filled = false
circle.Visible = false

-- Aimbot
RunService.RenderStepped:Connect(function()

	circle.Position = UIS:GetMouseLocation()
	circle.Visible = aimOn

	if aimOn then

		local target=nil
		local dist=9999

		for i,v in pairs(Players:GetPlayers()) do
			if v~=player and v.Character and v.Character:FindFirstChild("Head") then

				local pos,vis=Camera:WorldToViewportPoint(v.Character.Head.Position)

				if vis then

					local mag=(Vector2.new(pos.X,pos.Y)-UIS:GetMouseLocation()).Magnitude

					if mag<circle.Radius and mag<dist then
						dist=mag
						target=v
					end

				end

			end
		end

		if target then
			Camera.CFrame=CFrame.new(Camera.CFrame.Position,target.Character.Head.Position)
		end

	end

end)

-- ESP
RunService.RenderStepped:Connect(function()

	if espOn then

		for i,v in pairs(Players:GetPlayers()) do

			if v~=player and v.Character and v.Character:FindFirstChild("Head") then

				if not v.Character.Head:FindFirstChild("ESP") then

					local bill=Instance.new("BillboardGui",v.Character.Head)
					bill.Name="ESP"
					bill.Size=UDim2.new(0,100,0,40)
					bill.AlwaysOnTop=true

					local txt=Instance.new("TextLabel",bill)
					txt.Size=UDim2.new(1,0,1,0)
					txt.BackgroundTransparency=1
					txt.TextColor3=Color3.new(1,0,0)
					txt.TextScaled=true

					RunService.RenderStepped:Connect(function()
						if v.Character and v.Character:FindFirstChild("Humanoid") then
							txt.Text=v.Name.." | "..math.floor(v.Character.Humanoid.Health)
						end
					end)

				end

			end

		end

	end

end)

-- Noclip
RunService.Stepped:Connect(function()
	if noclipOn and player.Character then
		for i,v in pairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide=false
			end
		end
	end
end)
