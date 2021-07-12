local Players=game:service'Players'
local Lighting=game:service'Lighting'
local ReplicatedStorage=game:service'ReplicatedStorage'
local TeleportService=game:service'TeleportService'
local HttpService=game:service'HttpService'
local RunService=game:service'RunService'
local CoreGui=game:service'CoreGui'
local Stepped=RunService.Stepped
local MainPrompt=CoreGui:FindFirstChild('promptOverlay', true)
if not MainPrompt then
    repeat 
        MainPrompt=CoreGui:FindFirstChild('promptOverlay', true)
        Stepped:Wait()
    until MainPrompt
end
MainPrompt.ChildAdded:Connect(function(Child)
    if Child.Name=='ErrorPrompt' then
		rconsoleprint'Got Error Box\n'
		while true do
			local Success, Return = pcall(function()
				Env:JoinServer(game.PlaceId, 'Asc', 200, false)
			end)
			wait(10)
		end
    end
end)

syn.queue_on_teleport(readfile'Ulisse/Scripts/FishingSimCrateFarm.lua')

local Communication=ReplicatedStorage:WaitForChild'CloudClientResources':WaitForChild'Communication'
local StateChanged=Communication:WaitForChild'Events':WaitForChild'StateChanged'
local Remote=Communication:WaitForChild'Functions':WaitForChild'OpenChest'
local LocalPlayer=Players.LocalPlayer or Players.PlayerAdded:Wait()
local Char=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP=Char:WaitForChild'HumanoidRootPart'
local Camera=workspace.CurrentCamera

if LocalPlayer.PlayerGui:WaitForChild('LoadingScreen',1) then
	repeat wait()
	until (not LocalPlayer.PlayerGui:FindFirstChild'LoadingScreen')
end
local StartScreen=LocalPlayer.PlayerGui:FindFirstChild'StartScreen'
if StartScreen then
	StateChanged:FireServer('Gameplay', 'StartScreen')
	warn'Got'
	StartScreen:Destroy()
	local Blur=Lighting:FindFirstChild'Blur'
	if Blur then
		Blur:Destroy()
	end
	Camera.CameraType='Custom'
	Camera.CameraSubject=HRP
end

for i,v in ipairs(workspace:GetChildren()) do
	if v:IsA'Model' and string.find(string.lower(v.Name), 'shipmodel') then
		local Success,Return = pcall(function()
			rconsoleprint(string.format('Got: %s [%s]\n', v.Name, v.RarityString.Value))
			local Chests={}
			for idx,val in ipairs(v:GetChildren()) do
				if val:IsA'Model' and string.find(string.lower(val.Name), 'chest_') then
					table.insert(Chests, val)
				end
			end
			for Idx,Chest in ipairs(Chests) do
				local Chestroot=Chest:FindFirstChild'HumanoidRootPart'
				if Chestroot then
					local Success,Return = pcall(function()
						HRP.CFrame=Chestroot.CFrame
					end)
					wait(.5)
					local Success,Return = pcall(function()
						Remote:InvokeServer(Chest)
					end)
					rconsoleprint(string.format('Got: %s\n', Chest.Name))
					wait(1)
				end
			end
		end)
	end
end

for i,v in ipairs(workspace.RandomChests:GetChildren()) do
	local Success,Return = pcall(function()
		local Chest
		if v:IsA'Model' and string.find(string.lower(v.Name), 'chest_') then
			Chest=v
		end
		if Chest then
			local Chestroot=Chest:FindFirstChild'HumanoidRootPart'
			if Chestroot then
				local Success,Return = pcall(function()
					HRP.CFrame=Chestroot.CFrame
				end)
				wait(.5)
				local Success,Return = pcall(function()
					Remote:InvokeServer(Chest)
				end)
				rconsoleprint(string.format('Got: %s\n', Chest.Name))
				wait(1)
			end
		end
	end)
end

while true do
	local Success, Return = pcall(function()
		Env:JoinServer(game.PlaceId, 'Asc', 200, false)
	end)
	wait(10)
end