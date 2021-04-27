if not game:IsLoaded() then
	game.Loaded:Wait()
end
rconsolename'Ulisse'
local Players=game:service'Players'
local ReplicatedStorage=game:service'ReplicatedStorage'
local PlaceFolder=workspace:WaitForChild'placeFolders'
local Items=PlaceFolder:WaitForChild'items'
local Modules=ReplicatedStorage:WaitForChild'modules'
local Network=Modules:WaitForChild'network'
local PickupRem=Network:WaitForChild'pickUpItemRequest'
local LocalPlayer=Players.LocalPlayer
local UID=tostring(LocalPlayer.UserId)
local FireServer=Instance.new'RemoteEvent'.FireServer
local OldFS
local GodMode=false
local Autopickup=false
OldFS=hookfunction(FireServer, newcclosure(function(Self, ...)
	if not checkcaller() then
		local Args={...}
		if Args and Args[3] and typeof(Args[3])=='string' and Args[3]=='monster' and GodMode then
			return
		end
	end
	return OldFS(Self,...)
end))
local UI=UlisseUI:Main()
local Tab=UI:Tab'Tab 1'
local Section=Tab:Section'Section'
Section:Item('toggle','Monster Godmode',function(v)
    GodMode=v
end)
Section:Item('toggle', 'Auto pickup',function(v)
    Autopickup=v
end)

local function CheckOwner(Obj) 
    if Obj then
        if Obj.Name==UID then
            return true
        end
    end
end

while true do
    if Autopickup and LocalPlayer.Character then
        local HRP=LocalPlayer.Character.PrimaryPart
        if HRP then
            warn'hrp'
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
                    if Mag<18 then
                        coroutine.wrap(PickupRem.InvokeServer)(PickupRem, v)
                    end
                end
            end
        end
    end
    wait(.3)
end