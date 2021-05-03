if not game:IsLoaded()then
	game.Loaded:Wait()
end
local G=getgenv
if G().TyStorage then
	for I=1,#G().TyStorage.Connections do
		G().TyStorage.Connections[I]:Disconnect()
	end
	for I=1,#G().TyStorage.Drawing do
		G().TyStorage.Drawing[I]:Remove()
	end
end
G().TyStorage={}
G().TyStorage.Connections={}
G().TyStorage.RainbowObjects={}
G().TyStorage.Drawing={}
local Library=loadstring(game:HttpGet('http://5.252.162.148/Library.lua'))()
local DrawingTable=G().TyStorage.Drawing
local Connections=G().TyStorage.Connections
local RainbowObjects=G().TyStorage.RainbowObjects
local UIS=game:service'UserInputService'
local Players=game:service'Players'
local RunService=game:service'RunService'
local StarterGui=game:service'StarterGui'
local HB=RunService.Heartbeat
local LocalPlayer=Players.LocalPlayer
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP=Character:WaitForChild'HumanoidRootPart'
local Mouse=LocalPlayer:GetMouse()
local Camera=workspace.CurrentCamera
local DGT=workspace.DistributedGameTime
local V3N=Vector3.new
local V2N=Vector2.new
local CFN=CFrame.new
local C3N=Color3.new
local RayNew=Ray.new
local MS=math.sin
local Screen2Ray=Camera.ScreenPointToRay
local FindOnRay=workspace.FindPartOnRay
local WTVP=Camera.WorldToViewportPoint
local Format=string.format
local Red=Color3.fromRGB(255,0,0)
local Green=Color3.fromRGB(0,255,0)
local TargetPlayer
local OldTarget
local Closelock=true
local LockRange=4
local Running=false

Library:MakeSection('Target Lock')
Library:MakeSlider('Lock Range', function(val)
	LockRange=val
end, {Default=4,Step=1,Min=-12,Max=12})

local function W2S(Point)
	return WTVP(Camera,Point)
end

local function GetPlayerClosestToMouse()
	local Highest={0,nil}
	for Idx,Player in ipairs(Players:GetPlayers()) do
		local Character=Player.Character
		if Player~=LocalPlayer and Character then
			local Head=Character:FindFirstChild'Head'
			local HRP=Character:FindFirstChild'HumanoidRootPart'
			local Hum=Character:FindFirstChildOfClass'Humanoid'
			if Head and HRP and Hum and Head.Position.X~=0 and Head.Position.Z~=0 then
				local Distance=(Camera.CFrame.p-Head.Position).Magnitude
				local Direction=-(Camera.CFrame.p-Mouse.Hit.p).unit
				local Relative=Player.Character.Head.Position-Camera.CFrame.p
				local Unit=Relative.unit
				local DP=Direction:Dot(Unit)
				if DP>.6 and DP>Highest[1] then
					Highest={DP,Player,Character,HRP,Hum}
				end
			end
		end
	end
	return Highest
end

local function Notification(Text,Color)
	if not Color then
		Color=Color3.new(1,1,1)
	end
	StarterGui:SetCore('ChatActive',true)
	StarterGui:SetCore('ChatMakeSystemMessage',{
		Text = '[SCRIPT]: '..Text;
		Color = Color;
		Font = Enum.Font.GothamBold;
		FontSize = Enum.FontSize.Size12;
	})
end

local Line=Drawing.new'Line'
local DistanceText=Drawing.new'Text'
local HitText=Drawing.new'Text'
local Circle=Drawing.new'Circle'

Connections[#Connections+1]=LocalPlayer.CharacterAdded:Connect(function(Character)
	HRP=Character:WaitForChild'HumanoidRootPart'
end)

Connections[#Connections+1]=Players.PlayerRemoving:Connect(function(Player)
	if Player==TargetPlayer then
		TargetPlayer=nil
		Notification('No Target',Red)
	end
end)

Connections[#Connections+1]=Players.PlayerAdded:Connect(function(Player)
	Connections[#Connections+1]=Player.CharacterRemoving:Connect(function(Char)
		if TargetPlayer and TargetPlayer[3] then
			if TargetPlayer[3]==Char then
				TargetPlayer=nil
				Notification('No Target',Red)
			end
		end
	end)
end)

coroutine.wrap(function()
	for i,v in ipairs(Players:GetPlayers()) do
		Connections[#Connections+1]=v.CharacterRemoving:Connect(function(Char)
			if TargetPlayer and TargetPlayer[3] then
				if TargetPlayer[3]==Char then
					TargetPlayer=nil
					Notification('No Target',Red)
				end
			end
		end)
	end
end)()

coroutine.wrap(function()
	DrawingTable[#DrawingTable+1]=Line
	DrawingTable[#DrawingTable+1]=HitText
	DrawingTable[#DrawingTable+1]=DistanceText
	DrawingTable[#DrawingTable+1]=Circle
	Line.Thickness=1
	Line.Color=Color3.new(1,1,1)
	Line.Transparency=.8
	Line.Visible=true
	HitText.Outline=true
	HitText.Size=18
	HitText.Color=Color3.new(1,1,1)
	HitText.Font=0
	DistanceText.Outline=true
	DistanceText.Size=24
	DistanceText.Color=Color3.new(1,0,0)
	DistanceText.Visible=false
	HitText.Visible=true
	Circle.Radius=5
	Circle.Filled=true
	Circle.Transparency=1
	Circle.Color=Color3.new(1,1,1)
	Circle.Visible=true
end)()

Connections[#Connections+1]=UIS.InputEnded:Connect(function(Key, GPE)
	if not GPE then
		if Key.KeyCode==Enum.KeyCode.Z then
			Running=not Running
			Notification(string.format('Lock On: %s',tostring(Running)),Green)
		elseif Key.KeyCode==Enum.KeyCode.X then
			if LocalPlayer.Character then
				if HRP then
					local Target=GetPlayerClosestToMouse()
					if Target[3] then
						if TargetPlayer and Target[2]==TargetPlayer[2] then
							Notification('No Target',Red)
							Target=nil
						else
							Notification('New target: '..Target[2].Name,Green)
							TargetPlayer=Target
						end
					else
						Notification('No Target',Red)
						TargetPlayer=nil
					end
				end
			end
		end
	end
end)

Connections[#Connections+1]=RunService.Heartbeat:Connect(function()
	if Running then
		if TargetPlayer and TargetPlayer[3] then
			if HRP and TargetPlayer[4] and TargetPlayer[5] and TargetPlayer[5].Health>0 then
				if (HRP.Position-TargetPlayer[4].Position).Magnitude<82 then
					local FF=TargetPlayer[2].Character:FindFirstChildOfClass'ForceField'
					if FF then
						HRP.Velocity=(TargetPlayer[4].Position-HRP.Position).Unit*300
					else
						HRP.CFrame=TargetPlayer[4].CFrame*CFN(0,0,LockRange)
					end
				end
			end
		end
	end
end)

Connections[#Connections+1]=RunService.RenderStepped:Connect(function()
	if TargetPlayer then
		local TargetPosition=TargetPlayer[4].Position
		local Position,Visible=W2S(TargetPosition)
		if Visible then
			local P=V2N(Position.X,Position.Y)
			Line.To=P
			Circle.Position=P
			local Distance=(HRP.Position-TargetPosition).Magnitude
			HitText.Text=tostring((Distance+0.5)-(Distance+0.5)%1)
			HitText.Position=V2N(Position.X+35,Position.Y)
		else 
			local CursorPos=UIS:GetMouseLocation()
			HitText.Position=V2N(Mouse.X+35,Mouse.Y)
			HitText.Text='Not In View'
			Line.From=V2N(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
			Line.To=CursorPos
			Circle.Position=CursorPos
		end
	else 
		local CursorPos=UIS:GetMouseLocation()
		HitText.Position=V2N(Mouse.X+35,Mouse.Y)
		HitText.Text='No Target'
		Line.From=V2N(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
		Line.To=CursorPos
		Circle.Position=CursorPos
	end
end)
Library:Build('Ty Sense')
Notification('Ran',Green)

