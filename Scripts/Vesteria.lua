if not game:IsLoaded() then
	game.Loaded:Wait()
end
rconsolename'Ulisse'
local Players=game:service'Players'
local ReplicatedStorage=game:service'ReplicatedStorage'
local CoreGui=game:service'CoreGui'
local HttpService=game:service'HttpService'
local PlaceFolder=workspace:WaitForChild'placeFolders'
local Items=PlaceFolder:WaitForChild'items'
local Mobs=PlaceFolder:WaitForChild'entityManifestCollection' 
local Modules=ReplicatedStorage:WaitForChild'modules'
local Network=Modules:WaitForChild'network'
local PickupRem=Network:WaitForChild'pickUpItemRequest'
local FireEvent=Network:WaitForChild'fireEvent'
local DamageRem=Network:WaitForChild'playerRequest_damageEntity'
local ReqRem=Network:WaitForChild'requestEntityDamageDealt'
local AnimRem=Network:WaitForChild'replicatePlayerAnimationSequence'
local LocalPlayer=Players.LocalPlayer
local UID=tostring(LocalPlayer.UserId)
local FireServer=Instance.new'RemoteEvent'.FireServer
if CoreGui:FindFirstChild'ESPFolder' then
    CoreGui.ESPFolder:Destroy()
end
local Folder=Instance.new'Folder'
Folder.Name='ESPFolder'
syn.protect_gui(Folder)
Folder.Parent=CoreGui
local GodMode=false
local Autopickup=false
local Killaura=false
local ESPs={}
local OldFS
OldFS=hookfunction(FireServer, newcclosure(function(Self, ...)
	if not checkcaller() then
		local Args={...}
		if Args and Args[3] and typeof(Args[3])=='string' and Args[3]=='monster' and GodMode then
			return
		end
	end
	return OldFS(Self,...)
end))
local UI=Ulisse.UI:Main()
local Tab=UI:Tab'P To Toggle'
local Section=Tab:Section'Section'
Section:Item('toggle','Monster Godmode',function(v)
    GodMode=v
end)
Section:Item('toggle', 'Auto pickup',function(v)
    Autopickup=v
end)
Section:Item('toggle', 'Killaura',function(v)
    Killaura=v
end)

local function CheckOwner(Obj) 
    if Obj then
        if Obj.Name==UID then
            return true
        end
    end
end

local function AddESP(Obj)
    local Gui = Instance.new'BillboardGui'
    local Holder = Instance.new'Frame'
    local Name = Instance.new'TextLabel'
    local Distance = Instance.new'TextLabel'

    Gui.Name = "Gui"
    Gui.Active = true
    Gui.Adornee = Obj
    Gui.AlwaysOnTop = true
    Gui.ExtentsOffset = Vector3.new(0, 2, 0)
    Gui.LightInfluence = 1.000
    Gui.Size = UDim2.new(0, 100, 0, 50)
    Gui.MaxDistance = 5e5
    Gui.Parent = Folder

    Holder.Name = "Holder"
    Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Holder.BackgroundTransparency = 1.000
    Holder.Size = UDim2.new(1, 0, 1, 0)
    Holder.Parent = Gui

    Name.Name = "Name"
    Name.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
    Name.BorderSizePixel = 2
    Name.Size = UDim2.new(1, 0, 0.400000006, 0)
    Name.Font = Enum.Font.Roboto
    Name.Text = Obj.Name
    Name.TextColor3 = Color3.fromRGB(0,0,0)
    Name.TextSize = 12
    Name.BackgroundTransparency = 1.000
    Name.TextWrapped = true
    Name.BorderColor3 = Color3.fromRGB(255,255,255)
    Name.Parent = Holder
    
    Distance.Name = "Distance"
    Distance.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
    Distance.BorderSizePixel = 2
    Distance.Position = UDim2.new(0, 0, 0.449999988, 0)
    Distance.Size = UDim2.new(1, 0, 0.300000012, 0)
    Distance.Font = Enum.Font.Roboto
    Distance.Text = '[ 100 ]'
    Distance.TextColor3 = Color3.fromRGB(0,0,0)
    Distance.TextSize = 10
    Distance.BorderColor3 = Color3.fromRGB(255,255,255)
    Distance.BackgroundTransparency = 1.000
    Distance.TextWrapped = true
    Distance.Parent = Holder
    table.insert(ESPs, {Obj, Gui, Distance, Name})
end
local function Damage(Obj)
    local HRP=(LocalPlayer.Character and LocalPlayer.Character.PrimaryPart) or nil
    if HRP and Obj:IsDescendantOf(workspace) then
        AnimRem:FireServer('swordAnimations','strike1',{attackSpeed=0})
        ReqRem:Fire(Obj, HRP.Position, 'equipment', nil, HttpService:GenerateGUID(false))
        DamageRem:FireServer(Obj, HRP.Position, 'equipment')
    end
end

local function CheckMob(Obj)
    if Obj and Obj:IsA'BasePart' then
        --AddESP(Obj)
    end
end

for i,v in ipairs(Mobs:GetChildren()) do
    CheckMob(v)
end
 
Mobs.ChildAdded:Connect(function(Obj)
    wait()
    CheckMob(v)
end)

warn'Done1'
while true do
    if LocalPlayer.Character then
        local HRP=LocalPlayer.Character.PrimaryPart
        if HRP then
            if Killaura then
                for i,v in ipairs(Mobs:GetChildren()) do
                    if v:IsA'BasePart' then
                        local Mag=(HRP.Position-v.Position).Magnitude
                        if Mag<20 then
                            coroutine.wrap(Damage)(v)
                        end
                    end
                end
            end
            if Autopickup then
                for i,v in ipairs(Items:GetChildren()) do
                    local Owners=v:FindFirstChild'owners'
                    local PartObject=v:FindFirstChild'HumanoidRootPart'
                    local IsOwner=false
                    if Owners then
                        for Idx,Val in ipairs(Owners:GetChildren()) do
                            if CheckOwner(Val) then
                                IsOwner=true
                                break
                            end
                        end
                    end 
                    if IsOwner and PartObject then
                        local Mag=(HRP.Position-PartObject.Position).Magnitude
                        if Mag<30 then
                            coroutine.wrap(PickupRem.InvokeServer)(PickupRem, v)
                        end
                    end
                end
            end
            for i,v in ipairs(ESPs) do
                local Mag=(HRP.Position-v[1].Position).Magnitude  
                v[3].Text=string.format('[ %i ]',math.round(Mag))
            end
        end
    end
    wait(.25)
end