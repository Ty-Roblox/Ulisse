local LocalPlayer=game:service'Players'.LocalPlayer
local Avatar=game:service'ReplicatedStorage'.Events.Avatar
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

for i,v in ipairs(Character:GetChildren()) do
    if v:IsA'Accessory' then
        Avatar:FireServer('Remove', 'Hats', tonumber(v.Name))
        wait(.1)
    end
end

local function Badonkers()
	Avatar:FireServer('Remove', 'Hats', 617605556)
	Avatar:FireServer('Wear', 'Hats', 4546422467)
	Avatar:FireServer('Remove', 'Hats', 3033910400)
	Avatar:FireServer('Wear', 'Hats', 4508445398)
	Avatar:FireServer('Remove', 'Hats', 3403874988)
	Avatar:FireServer('Wear', 'Hats', 172327379)
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'R', Vector3.new(-0.000000,-0.000000,0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'P', Vector3.new(0.000000,0.000000,-1.300000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'S', Vector3.new(1.350000,1.350000,1.350000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'C', Vector3.new(19.000000,14.000000,12.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'P', Vector3.new(0.000000,-1.100000,-1.300000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4546422467', 'P', Vector3.new(0.000000,0.000000,-1.900000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4546422467', 'R', Vector3.new(-0.000000,-0.000000,-3.141593))
	Avatar:FireServer('Tune', Character:FindFirstChild'4546422467', 'S', Vector3.new(1.200000,1.200000,1.200000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4546422467', 'R', Vector3.new(3.141593,-0.000000,-3.141593))
	Avatar:FireServer('Tune', Character:FindFirstChild'4546422467', 'P', Vector3.new(0.000000,-1.100000,-1.900000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4546422467', 'P', Vector3.new(-0.800000,-1.100000,-1.900000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4546422467', 'P', Vector3.new(-0.800000,-1.100000,-0.200000))
	Avatar:FireServer('Tune', Character:FindFirstChild'172327379', 'P', Vector3.new(0.600000,0.000000,0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'172327379', 'P', Vector3.new(0.600000,-1.200000,0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'172327379', 'P', Vector3.new(0.600000,-1.200000,-0.400000))
	Avatar:FireServer('Tune', Character:FindFirstChild'172327379', 'P', Vector3.new(0.600000,-1.500000,-0.400000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4546422467', 'P', Vector3.new(-0.800000,-1.400000,-0.200000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'S', Vector3.new(1.300000,1.300000,1.300000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'S', Vector3.new(1.300000,1.300000,1.300000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'R', Vector3.new(-0.000000,0.000000,-0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'R', Vector3.new(-0.000000,0.000000,0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'R', Vector3.new(-0.392699,0.000000,0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'R', Vector3.new(-0.392699,0.000000,0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'S', Vector3.new(1.300000,1.300000,1.300000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'P', Vector3.new(0.000000,-1.100000,-1.500000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'S', Vector3.new(1.450000,1.450000,1.450000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'R', Vector3.new(-0.392699,0.000000,0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'R', Vector3.new(-0.392699,0.000000,-0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4508445398', 'R', Vector3.new(-0.785398,0.000000,-0.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'4546422467', 'C', Vector3.new(19.000000,16.000000,12.000000))
	Avatar:FireServer('Tune', Character:FindFirstChild'172327379', 'C', Vector3.new(19.000000,16.000000,12.000000))
end

Badonkers()
wait(.5)
Badonkers()