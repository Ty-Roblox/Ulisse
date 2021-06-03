if shared.DACon then
    shared.DACon:Disconnect()
end
if shared.OwnerShip then
    shared.OwnerShip:Disconnect()
end

local Players=game:service'Players'
local RunService=game:service'RunService'
local HB=RunService.Heartbeat
local Stepped=RunService.Stepped
local LocalPlayer=Players.LocalPlayer
local Char=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Owned={}

local function CheckOwnership(Obj)
    if Obj and Obj.Parent and Obj:IsA'BasePart' and (not Obj.Anchored) and isnetworkowner(Obj) and (not Obj:IsDescendantOf(Char)) then
        return true
    end
end

setscriptable(LocalPlayer, 'SimulationRadius', true)
shared.OwnerShip=HB:Connect(function()
    local Physics=settings().Physics
    Physics.AllowSleep=false
    Physics.ThrottleAdjustTime=0/0
    LocalPlayer.SimulationRadius=9e9
    setsimulationradius(9e9, 9e9)
    Stepped:Wait()
end)

shared.DACon=workspace.DescendantAdded:Connect(function(Obj)
    if CheckOwnership(Obj) then
        table.insert(Owned,Obj)
    end
end)

coroutine.wrap(function()
    for i,v in ipairs(workspace:GetDescendants()) do
        if CheckOwnership(v) then
            table.insert(Owned,v)
        end
    end
end)()

local UI=Ulisse.UI:Main()
local Tab=UI:Tab'P To Toggle'
local Section=Tab:Section'Section'
Section:Item('button', 'Bring Unanchored',function()
    for i,v in ipairs(Owned) do
        v.CFrame=Char.PrimaryPart.CFrame+Vector3.new(0,10,0)
    end    
end)
Section:Item('button', 'ReScan',function(v)
    Owned={}
    for i,v in ipairs(workspace:GetDescendants()) do
        if CheckOwnership(v) then
            table.insert(Owned,v)
        end
    end
    Ulisse.UI.Warn('Unanchored Count', string.format('#[%i]', #Owned))
end)
--[[
Section:Item('toggle', 'Fly Part', function(v)
    local Camera=workspace.CurrentCamera
    if v then

    else
        if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            Camera.CameraSubject=LocalPlayer.Character.PrimaryPart
        end 
    end
end)]]