local Players=game:service'Players'
local HttpService=game:service'HttpService'
local TeleportService=game:service'TeleportService'
local ReplicatedStorage=game:service'ReplicatedStorage'
local TweenService=game:service'TweenService'
local VirtualUser=game:service'VirtualUser'
local CoreGui=game:service'CoreGui'
local RunService=game:service'RunService'
local CoreGui=game:service'CoreGui'

syn.queue_on_teleport(readfile'Ulisse/Scripts/EraOfAlthea.lua')

local Map=workspace:WaitForChild'Map'

local Events = ReplicatedStorage:WaitForChild'Events'
local ServerSettings = ReplicatedStorage:WaitForChild'ServerSettings'
local Reserve = ServerSettings:WaitForChild'ReservedServer'
local JoinRem=ReplicatedStorage:WaitForChild'Events':WaitForChild'JoinPrivateServer'

if not Reserve.Value then
    while wait(5) do
        pcall(JoinRem.FireServer, JoinRem, 'HEzo9')
    end
end

local Heartbeat=RunService.Heartbeat
local Stepped=RunService.Stepped
local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

if shared.CharAdded then
    shared.DontKillLoop=false
    shared.CharAdded:Disconnect()
end

local MainPrompt=CoreGui:FindFirstChild('promptOverlay', true)
MainPrompt.ChildAdded:Connect(function(Child)
    if Child.Name=='ErrorPrompt' then
        Ulisse:SetColor'red'
        Ulisse:PrintConsole'ErrorPrompt Found, Teleport called'
        Ulisse:SetColor()
        while wait(1) do
            pcall(TeleportService.Teleport, TeleportService, 6244193981)
        end
    end
end)

shared.NPCAutofarm=true

local FFPart=Instance.new'Part'
FFPart.Size=Vector3.new(8,.5,8)
FFPart.Anchored=true
FFPart.Material=Enum.Material.ForceField
FFPart.Color=Color3.fromRGB(255,0,255)
FFPart.Parent=workspace

local Tweening
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local NPCS=workspace:WaitForChild'NPCS'

local Events=Character:WaitForChild'Client':WaitForChild'Events'
local EquipRem=Events:WaitForChild'ActivateWeapon'

local function GetSword()
    local Tool
    for i,v in ipairs(Character:GetChildren()) do
        if v:IsA'Tool' and string.find(string.lower(v.Name), 'sword') then
            Tool=v
            break
        end
    end
    if not Tool then
        EquipRem:FireServer()
        wait(.35)
        for i,v in ipairs(Character:GetChildren()) do
            if v:IsA'Tool' and string.find(string.lower(v.Name), 'sword') then
                Tool=v
                break
            end
        end
    end
    if Tool then
        return Tool
    end
end

local function TweenTo(HRP, Pos) 
    if Tweening then
        Tweening:Cancel()
        Tweening=nil
    end
    if HRP then
        local Mag=(Pos.Position-HRP.Position).Magnitude
        FFPart.CFrame=HRP.CFrame*CFrame.new(0,-2.5,0)
        Tweening=TweenService:Create(HRP, TweenInfo.new((Mag/225),Enum.EasingStyle.Linear), {CFrame=Pos+Vector3.new(0,2,0)}):Play()
    end
end

local Once=false
local function GetQuest(HRP)
    if not HRP then
        return
    end
    if PlayerGui:FindFirstChild'Quest' then
        return true
    end
    for i,v in ipairs(Map:GetChildren()) do
        if v:IsA'Model' and v.Name=='Quest Board' then
            local Papers=v:FindFirstChild'Papers'
            if Papers then
                for i,v in ipairs(Papers:GetChildren()) do
                    if v then
                        local SurfaceGui=v:FindFirstChild'SurfaceGui'
                        if SurfaceGui then
                            local Frame=SurfaceGui:FindFirstChild'Frame' 
                            if Frame then
                                local QuestName=Frame:FindFirstChild'QuestName'
                                if QuestName then
                                    if string.find(string.lower(QuestName.Text), 'wolves') then
                                        if not Once then
                                            Once=true
                                            print'a'
                                        end
                                        local CD=v:FindFirstChild'ClickDetector'
                                        local Mag=(HRP.Position-v.Position).Magnitude
                                        if CD and Mag<10 then
                                            fireclickdetector(CD)
                                        else
                                            TweenTo(HRP, v.CFrame)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function GetClosestNPC(Name)
    local HRP=Character:FindFirstChild'HumanoidRootPart'
    if HRP then
        local NPC
        local Distance=1e5
        for i,v in ipairs(NPCS:GetChildren()) do
            local HP=v:FindFirstChild'Health'
            if string.find(string.lower(v.Name), string.lower(Name)) and v.PrimaryPart and HP and HP.Value>1 and (not v:FindFirstChild'Immune') then
                local TargetRoot=v:FindFirstChild'HumanoidRootPart'
                local Magnitude=(TargetRoot.Position-HRP.Position).Magnitude
                if Magnitude<Distance then
                    Distance=Magnitude
                    NPC=v
                end
            end
        end
        return NPC
    end
end

shared.CharAdded=LocalPlayer.CharacterAdded:Connect(function(NewChar)
    Character=NewChar
    Events=Character:WaitForChild'Client':WaitForChild'Events'
    EquipRem=Events:WaitForChild'ActivateWeapon'
end)

shared.DontKillLoop=true

coroutine.wrap(function()
    while shared.DontKillLoop do
        for i,v in ipairs(Character:GetChildren()) do
            if v:IsA'BasePart' then
                v.CanCollide=false
                v.Velocity=Vector3.new()
            end
        end
        Stepped:Wait()
    end
end)()

while shared.DontKillLoop do
    if shared.NPCAutofarm then
        local HRP=Character:FindFirstChild'HumanoidRootPart'
        local Quest=GetQuest(HRP)
        if Quest and HRP then
            for i,v in ipairs(Character:GetChildren()) do
                if v:IsA'BasePart' then
                    v.Velocity=Vector3.new()
                end
            end
            local Target=GetClosestNPC('WoLF')
            if Target then
                for i,v in ipairs(Target:GetChildren()) do
                    if v:IsA'BasePart' then
                        v.Velocity=Vector3.new()
                    end
                end
                local Weapon=GetSword()
                if Weapon then
                    local TargetRoot=Target:FindFirstChild'HumanoidRootPart'
                    if TargetRoot then
                        local Mag=(TargetRoot.Position-HRP.Position).Magnitude
                        if Mag>45 then
                            TweenTo(HRP, TargetRoot.CFrame)
                        else
                            HRP.CFrame=TargetRoot.CFrame*CFrame.new(0,0,6)--*CFrame.Angles(math.rad(90),0,0)
                            FFPart.CFrame=HRP.CFrame*CFrame.new(0,-2.5,0)
                            Weapon:Activate()
                        end
                    end
                end
            end
        end
    end
    Heartbeat:Wait()
end
