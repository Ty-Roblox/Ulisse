if shared.HBCon then
    shared.HBCon:Disconnect()
end
if shared.CACon then
    shared.CACon:Disconnect()
end
if shared.NoclipCon then
    shared.NoclipCon:Disconnect()
end
shared.GPOEnabled=false
local RunService=game:service'RunService'
local Players=game:service'Players'
local TweenService=game:service'TweenService'
local ReplicatedStorage=game:service'ReplicatedStorage'
local Events=ReplicatedStorage:WaitForChild'Events'
local CombatRemote=Events:WaitForChild'CombatRegister'
local QuestRemote=Events:WaitForChild'Quest'
local LocalPlayer=Players.LocalPlayer
local HB=RunService.Heartbeat
local Stepped=RunService.Stepped
local Char=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Hum=Char:FindFirstChildOfClass'Humanoid'
local HRP=Char:FindFirstChild'HumanoidRootPart' or Char.PrimaryPart
local NPCFolder=workspace:WaitForChild'NPCs'

local FFPart=Instance.new'Part'
FFPart.Size=Vector3.new(8,.5,8)
FFPart.Anchored=true
FFPart.Material=Enum.Material.ForceField
FFPart.Parent=workspace

local AutofarmQuest=false
local Tweening=nil
local SelectedQuestGiver=nil
local StartPos=nil
local LastCalledQuest=tick()

local function Weapon()
    if not Hum then
        return
    end
    for i,v in ipairs(Char:GetChildren()) do 
        if v:IsA'Tool' and v:FindFirstChild'SwordEquip' then
            return v
        end
    end
    for i,v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA'Tool' and v:FindFirstChild'SwordEquip' then
            Hum:EquipTool(v)
            if v.Parent==Char then
                return v
            end
        end
    end
end

local function GetQuestGiver()
    if not HRP then
        return
    end
    local NPC
    local Closest=9e9
    for i,v in ipairs(NPCFolder:GetChildren()) do
        local QuestMark=v:FindFirstChild'QuestMark'
        local NHRP=v:FindFirstChild'HumanoidRootPart'
        if NHRP and QuestMark then
            local Mag=(NHRP.Position-HRP.Position).Magnitude
            if Mag<Closest then
                Closest=Mag
                NPC={NHRP,v}
            end
        end
    end
    return NPC
end

local function GetClosest(Name)
    if not HRP then
        return
    end
    local NPC
    local Closest=9e9
    for i,v in ipairs(NPCFolder:GetChildren()) do
        local NHum=v:FindFirstChildOfClass'Humanoid'
        local NHRP=v:FindFirstChild'HumanoidRootPart'
        if NHRP and NHum and NHum.Health>0 then
            if not Name then
                local Mag=(NHRP.Position-HRP.Position).Magnitude
                if Mag<Closest then
                    Closest=Mag
                    NPC={NHRP,v}
                end
            elseif Name and string.find(v.Name:lower(),Name:lower()) then
                local Mag=(NHRP.Position-HRP.Position).Magnitude
                if Mag<Closest then
                    Closest=Mag
                    NPC={NHRP,v}
                end
            end
        end
    end
    return NPC
end

local function TweenTo(Pos) 
    if Tweening then
        Tweening:Cancel()
        Tweening=nil
    end
    local Mag=(Pos.Position-HRP.Position).Magnitude
    Tweening=TweenService:Create(HRP, TweenInfo.new((Mag/90),Enum.EasingStyle.Linear), {CFrame=Pos-Vector3.new(0,2,0)}):Play()
end

local function GetQuest(QuestGiver)
    local QuestGui=LocalPlayer.PlayerGui:FindFirstChild'Quest'
    if QuestGiver and QuestGui and HRP then
        local QuestFrame=QuestGui:FindFirstChild'Quest'
        if QuestFrame and (not QuestFrame.Visible) then
            local Q=QuestFrame:FindFirstChild'Q'
            if Q then
                local Progress=Q:FindFirstChild'progress'
                if Progress and HRP then
                    local QHRP=QuestGiver:FindFirstChild'HumanoidRootPart'
                    local Mag=(HRP.Position-QHRP.Position).Magnitude
                    if Mag<5 then
                        if tick()-LastCalledQuest>16 then
                            LastCalledQuest=tick()
                            local Questname
                            if QuestGiver.Name=='Waby' then
                                Questname='Help Waby'
                            elseif QuestGiver.Name=='Chef Rice' then
                                Questname='Help Rice'
                            elseif QuestGiver.Name=='Zen' then
                                Questname='Help Zen'
                            elseif QuestGiver.Name=='Miska' then
                                Questname='Help Miska'
                            elseif QuestGiver.Name=='Vego' then
                                Questname='Help Vego'
                            else
                                Questname=string.format('Help %s',string.lower(QuestGiver.Name))
                            end
                            warn(Questname)
                            QuestRemote:InvokeServer({'takequest', Questname})
                            warn'Take quest'
                        end
                    else
                        TweenTo(QHRP.CFrame)
                        warn'Tween'
                    end
                end
            end
        else
            local Q=QuestFrame:FindFirstChild'Q'
            if Q then
                local Progress=Q:FindFirstChild'progress'
                if Progress then
                    return Progress.Text:gsub('[%(%)%/%d+]',''):sub(1, -2):sub(4)
                end
            end
        end
    end
end

local UI=Ulisse.UI:Main()
local Tab=UI:Tab'P To Toggle'
local Section=Tab:Section'GPO'
Section:Item('toggle','Killaura',function(v)
    shared.GPOEnabled=v
end)

Section:Item('toggle', 'Autofarm Quest',function(v)
    AutofarmQuest=v
end)
Section:Item('button', 'Set Quest',function()
    local QuestGiver=GetQuestGiver()
    if QuestGiver and QuestGiver[2] then
        SelectedQuestGiver=QuestGiver[2]
        StartPos=QuestGiver[1].CFrame+Vector3.new(0,2,0)
        print(SelectedQuestGiver.Name)
    end
end)

local HitType=1
local LastAttack=tick()
local LastHit=tick()

shared.CACon=LocalPlayer.CharacterAdded:Connect(function(NewChar)
    Char=NewChar
    HRP=Char:WaitForChild'HumanoidRootPart' 
    Hum=Char:WaitForChild'Humanoid'
    warn('Newchar', Char, HRP, Hum)
end)

shared.NoclipCon=Stepped:Connect(function()
    if AutofarmQuest and HRP and Hum then
        for i,v in ipairs(Char:GetDescendants()) do
            if v:IsA'BasePart' then
                v.CanCollide=false
                v.Velocity=Vector3.new()
            end
        end
    end
end)

shared.HBCon=HB:Connect(function()
    if shared.GPOEnabled and HRP and Hum then
        local Target=GetClosest()
        if Target and Target[1] then
            local Mag=(Target[1].Position-HRP.Position).Magnitude
            if Mag<=11.25 and tick()-LastAttack>=.35 and tick()-LastHit>=1.6 then
                local Tool=Weapon()
                if Tool and Tool.Parent==Char then
                    LastAttack=tick()
                    CombatRemote:InvokeServer({'swingsfx', 'Sword', HitType})
                    CombatRemote:InvokeServer({'damage', Target[1], 'Sword', {HitType, 'Ground', 'Sword'}, true})
                    HitType+=1
                    if HitType>5 then
                        HitType=1
                        LastHit=tick()
                    end
                end
            end
        end
        if AutofarmQuest then
            FFPart.CFrame=HRP.CFrame*CFrame.new(0,-2.35,0)
            if SelectedQuestGiver then
                if Tweening then
                    Tweening:Cancel()
                    Tweening=nil
                end
                local QuestNPC=GetQuest(SelectedQuestGiver)
                if QuestNPC then
                    local TargetNPC=GetClosest(QuestNPC)
                    if TargetNPC and TargetNPC[1] then
                        local Mag=(TargetNPC[1].Position-HRP.Position).Magnitude
                        if Mag>30 then
                            if Tweening then
                                Tweening:Cancel()
                                Tweening=nil
                            end
                            TweenTo(TargetNPC[1].CFrame)
                        else
                            HRP.CFrame=TargetNPC[1].CFrame*CFrame.new(0,-8,0)*CFrame.Angles(math.rad(90),0,0)
                        end
                    else
                        if StartPos then
                            TweenTo(StartPos)
                        end
                    end
                end
            end
        end
    end
end)

