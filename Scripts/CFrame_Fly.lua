shared.CFlyEnabled=false
local LocalPlayer=game:GetService'Players'.LocalPlayer
local RS=game:GetService'RunService'.RenderStepped
local UIS=game:GetService'UserInputService'
local Mouse=LocalPlayer:GetMouse()
local Camera=workspace.CurrentCamera
local ZeroVector=Vector3.new()
local CF=CFrame.new()
local Ch=LocalPlayer.Character
if Ch then
	local RootPart = Ch.PrimaryPart or Ch:FindFirstChild'HumanoidRootPart'
	if RootPart then
		CF=RootPart.CFrame
	end
end
local PartIgnore={}
local Enabled=false
if getgenv().Connects then
	warn'Disconnecting previous signals.'
	for i,Signal in ipairs(Connects)do
		Signal:Disconnect()
	end
end
getgenv().Connects={}
Connects[#Connects+1]=UIS.InputBegan:Connect(function(Key,GC)
	if GC then return end
	if Key.KeyCode==Enum.KeyCode.C and not UIS:GetFocusedTextBox()then
		local Ch=LocalPlayer.Character
		if Ch then
			local RootPart = Ch.PrimaryPart or Ch:FindFirstChild'HumanoidRootPart'
			if RootPart then
				CF=RootPart.CFrame
				Enabled=true
			end
		end
    end
end)
Connects[#Connects+1]=UIS.InputEnded:Connect(function(Key,GC)
	if GC then return end
	if Key.KeyCode==Enum.KeyCode.C then
		Enabled=false
		CF=CFrame.new()
	end
end)
local function GetIndex(Value)
    for i, v in ipairs(PartIgnore) do
        if v == Value then
            return i
        end
    end
    return -1
end
local function DisableClip(Part)
    if Part:IsA'BasePart' and Part.CanCollide then
        local OldTransparency=Part.Transparency
        table.insert(PartIgnore, Part)
        while Enabled and LocalPlayer.Character do
            Part.CanCollide = false
            Part.Transparency = .35
            wait(.125)
        end
        table.remove(PartIgnore, GetIndex(Part))
        Part.Transparency = OldTransparency
        Part.CanCollide = true
    end
end
shared.CFlyEnabled=true
while shared.CFlyEnabled do
    local Ch=LocalPlayer.Character
	if Enabled and Ch then
		local RootPart = Ch.PrimaryPart or Ch:FindFirstChild'HumanoidRootPart'
		if RootPart then
			RootPart.Velocity = ZeroVector
			RootPart.RotVelocity = ZeroVector
			local MaxY=1e9
			local Direction = ZeroVector +
				(UIS:IsKeyDown'W'and Vector3.new(0, 0, -1)or ZeroVector) +
				(UIS:IsKeyDown'S'and Vector3.new(0, 0, 1)or ZeroVector) +
				(UIS:IsKeyDown'D'and Vector3.new(1, 0, 0)or ZeroVector) +
				(UIS:IsKeyDown'A'and Vector3.new(-1, 0, 0)or ZeroVector)
			Direction = Direction*2*(UIS:IsKeyDown'LeftControl'and 6 or 1.25)
			if not UIS:GetFocusedTextBox()then
				CF = CF * CFrame.new(Direction)
			end
			local Direction=(Mouse.Hit.Position-Camera.CFrame.Position) 
			for i, v in ipairs(RootPart:GetTouchingParts())do
				if not v:IsDescendantOf(Ch)and GetIndex(v)<0 then
					coroutine.wrap(DisableClip)(v)
				end
			end
			Direction = Camera.CFrame.Position + (Direction.Unit * 10000)
			if not UIS:GetFocusedTextBox()then
				if CF.Y > MaxY then
					CF = CFrame.new(CF.X, math.clamp(CF.Y, -1000, MaxY), CF.Z)
				end
				CF = CFrame.new(CF.Position, Direction)
				Ch:SetPrimaryPartCFrame(CF)
				RootPart.CFrame = CF
			end
		end
	end
    wait()
end