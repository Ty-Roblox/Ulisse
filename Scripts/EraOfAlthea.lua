local Players=game:service'Players'
local HttpService=game:service'HttpService'
local TeleportService=game:service'TeleportService'
local ReplicatedStorage=game:service'ReplicatedStorage'
local TweenService=game:service'TweenService'
local VirtualUser=game:service'VirtualUser'
local CoreGui=game:service'CoreGui'
local RunService=game:service'RunService'

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

local FFPart=Instance.new'Part'
FFPart.Size=Vector3.new(8,.5,8)
FFPart.Anchored=true
FFPart.Material=Enum.Material.ForceField
FFPart.Color=Color3.fromRGB(255,0,255)
FFPart.Transparency=1
FFPart.Parent=workspace

local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local NPCS=workspace:WaitForChild'NPCS'

local Events=Character:WaitForChild'Client':WaitForChild'Events'
local EquipRem=Events:WaitForChild'ActivateWeapon'

local LastPos

local NPCList={
    'Golem';
    'Rog, The Bearded One';
    'Hleam Eyes';
    'Stork';
    'G-Knight';
    'Vedalia';
    'Orc';
    'Abu';
    'Dire Wolf';
    'Scorpion';
    'Wolf';
}

local function GetSword()
    local Tool
    for i,v in ipairs(Character:GetChildren()) do
        if v:IsA'Tool' and v:FindFirstChild'Weapon Handler' then
            Tool=v
            break
        end
    end
    if not Tool then
        EquipRem:FireServer()
        wait(.35)
        for i,v in ipairs(Character:GetChildren()) do
            if v:IsA'Tool' and v:FindFirstChild'Weapon Handler' then
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
    if shared.CurrentTween then
        shared.CurrentTween:Cancel()
        shared.CurrentTween=nil
    end
    if HRP then
        local Mag=(Pos.Position-HRP.Position).Magnitude
        FFPart.CFrame=HRP.CFrame*CFrame.new(0,-2.5,0)
        shared.CurrentTween=TweenService:Create(HRP, TweenInfo.new((Mag/225),Enum.EasingStyle.Linear), {CFrame=Pos+Vector3.new(0,2,0)}):Play()
    end
end

local function GetQuestPapers()
    local Tab={}
    for i,v in ipairs(Map:GetChildren()) do
        if v:IsA'Model' and v.Name=='Quest Board' and v:FindFirstChild'Papers' then
            for i,Val in ipairs(v.Papers:GetChildren()) do
                table.insert(Tab, Val)
            end
        end
    end
    for i,v in ipairs(workspace:GetChildren()) do
        if v:IsA'Model' and v.Name=='Quest Board' and v:FindFirstChild'Papers' then
            for i,Val in ipairs(v.Papers:GetChildren()) do
                table.insert(Tab, Val)
            end
        end
    end
    return Tab
end

local MobName='Wolf'
local function GetQuest(HRP)
    if not HRP then
        return
    end
    if PlayerGui:FindFirstChild'Quest' then
        return true
    end
    local Level=1
    local MenuV2=PlayerGui:FindFirstChild'MenuV2'
    if MenuV2 then  
        local StatFrame=MenuV2:FindFirstChild'StatFrame'
        if StatFrame then 
            local LevelObj=StatFrame:FindFirstChild'Level'
            if LevelObj then
                Level=string.gsub(LevelObj.Text, '[%a%s%p%W+]', '')
                Level=tonumber(Level)
            end
        end
    end    
    local GotPaper
    local BestLevel=1
    for i,v in ipairs(GetQuestPapers()) do
        local SurfaceGui=v:FindFirstChild'SurfaceGui'
        if SurfaceGui then
            local Frame=SurfaceGui:FindFirstChild'Frame' 
            if Frame then
                local QuestName=Frame:FindFirstChild'QuestName'
                local LevelReq=Frame:FindFirstChild'LevelReq'
                local Description=Frame:FindFirstChild'Description'
                if QuestName and LevelReq and Description and (not string.find(string.lower(Description.Text), 'dungeon')) and (not string.find(string.lower(Description.Text), 'labyrinth')) then
                    local LevelReqstr=string.gsub(LevelReq.Text, '[%a%s%p%W+]', '')
                    local RequiredLevel=tonumber(LevelReqstr)
                    if RequiredLevel>BestLevel and Level>=RequiredLevel then
                        BestLevel=RequiredLevel
                        GotPaper=v
                    end
                end
            end
        end
    end
    if not GotPaper then
        return
    end
    local Mag=(GotPaper.Position-HRP.Position).Magnitude
    if Mag>10 then
        TweenTo(HRP, GotPaper.CFrame) 
    else
        fireclickdetector(GotPaper.ClickDetector)
    end
end

local function GetClosestNPC(Name)
    local HRP=Character:FindFirstChild'HumanoidRootPart'
    if HRP then
        local NPC
        local Distance=1e5
        for i,v in ipairs(NPCS:GetChildren()) do
            local HP=v:FindFirstChild'Health'
            if string.find(string.lower(v.Name), string.lower(Name)) and HP and HP.Value>1 and (not v:FindFirstChild'Immune') and v:FindFirstChild'Hitbox' then
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
        if shared.Noclip then
            for i,v in ipairs(Character:GetChildren()) do
                if v:IsA'BasePart' then
                    v.CanCollide=false
                    v.Velocity=Vector3.new()
                end
            end
        end
        Stepped:Wait()
    end
end)()

local UI=Ulisse.UI:Main()
local Tab=UI:Tab'P To Toggle'
local Section=Tab:Section'Swordclover online:tm:'
Section:Item('toggle','Autofarm',function(v)
    shared.NPCAutofarm=v
    if shared.CurrentTween then
        shared.CurrentTween:Cancel()
        shared.CurrentTween=nil
    end
end)
Section:Item('toggle','Noclip',function(v)
    shared.Noclip=v
end)

local Offset=8

Section:Item('slider', 'Hitbox offset', function(v)
    Offset=v
end,{Min=-22, Max=22})

Section:Item('textbox', 'NPC To Farm',function(v)
    MobName=v
    warn(v)
end,{Placeholder='Wolf'})

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
            local Target=GetClosestNPC(MobName)
            if Target then
                for i,v in ipairs(Target:GetChildren()) do
                    if v:IsA'BasePart' then
                        v.Velocity=Vector3.new()
                    end
                end
                if Target:FindFirstChild'Humanoid' and Target:FindFirstChild'Hitbox' and isnetworkowner(Target.Hitbox) then
                    Target.Humanoid.Health=0
                end
                local Weapon=GetSword()
                if Weapon then
                    local TargetRoot=Target:FindFirstChild'Hitbox'
                    if TargetRoot then
                        LastPos=TargetRoot.CFrame
                        local Mag=(TargetRoot.Position-HRP.Position).Magnitude
                        if Mag>45 then
                            TweenTo(HRP, TargetRoot.CFrame)
                        else
                            HRP.CFrame=TargetRoot.CFrame*CFrame.new(0,0,Offset)
                            FFPart.CFrame=HRP.CFrame*CFrame.new(0,-2.5,0)
                            Weapon:Activate()
                        end
                    end
                end
            else
                if LastPos then
                    TweenTo(HRP, LastPos)
                else
                    TweenTo(HRP, workspace:FindFirstChild'Part'.CFrame)
                end
            end
        end
    end
    Heartbeat:Wait()
end
